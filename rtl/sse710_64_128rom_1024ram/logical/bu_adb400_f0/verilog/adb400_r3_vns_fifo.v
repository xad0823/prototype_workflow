//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
// (C) COPYRIGHT 2011-2016 ARM Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
// Checked In :  2016-01-21 15:26:03 +0000 (Thu, 21 Jan 2016)
// Revision : 205793
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_vns_fifo.v
//-----------------------------------------------------------------------------
// Purpose : A multi-VN FIFO - deals with token procurement and use, and
//           indicates the highest QoS value of an un-tokened entry in the
//           FIFO. If the relevant VN FIFO is completely empty and a token
//           is available having been prefetched it can act in passthrough
//           mode, storing the transfer if it doesn't get handshaked.
//
//           Assumes that vnet is in the bottom 4b of the payload.
//-----------------------------------------------------------------------------

module adb400_r3_vns_fifo
  #(parameter
    FIFO_WIDTH    = 40,
    FIFO_DEPTH    = 4,
    VN            = 4,
    QOS_PRESENT   = 4,  // set to 0 to remove QV-based arbitration
    REARB_CONTROL_PRESENT = 0
  )
  (
    input  wire                  aclk,
    input  wire                  aresetn,

    input  wire [VN-1:0]         vnpid_1h,
    input  wire                  valid_src,
    output wire                  ready_src,
    input  wire [FIFO_WIDTH-1:0] payld_src,
    input  wire                  bar_src,
    input  wire [((QOS_PRESENT>0)?3:0):0] qv_src,
    input  wire                  promotion_qv_update,
    input  wire [((QOS_PRESENT>0)?((4*VN)-1):0):0] promotion_qv,

    output wire                  valid_dst,
    input  wire                  ready_dst,
    output wire [FIFO_WIDTH-1:0] payld_dst,
    input  wire                  vn_rearb,

    output wire [VN-1:0]         tkn_req,
    input  wire [VN-1:0]         tkn_gnt,
    output wire [((QOS_PRESENT>0)?((4*VN)-1):0):0] tkn_qv,
    output wire [VN-1:0]         tkn_release,

    input  wire [VN-1:0]         tkn_prealloc_i
  );

`include "adb400_r3_functions.v"

  // Vectors for the handshake signals on each end of each FIFO
  wire [VN-1:0] valid_src_vn;
  wire [VN-1:0] valid_dst_vn;
  wire [VN-1:0] ready_dst_vn;
  // Array for the payloads at the egress end of the VN FIFOs
  wire [FIFO_WIDTH-1:0] payld_dst_vn [VN-1:0];
  // Transpose of the above to enable multiplexing
  wire [VN-1:0] payld_dst_vn_t [FIFO_WIDTH-1:0];

  // Array of the promotion QVs
  wire [((QOS_PRESENT>0)?3:0):0] promotion_qv_vn [VN-1:0];

  // A non-empty per VN
  wire [VN-1:0] emptyn_vn_m;

  wire [((QOS_PRESENT>0)?3:0):0] arbitration_qv_vn [VN-1:0];
  wire [((QOS_PRESENT>0)?3:0):0] tkn_qv_vn [VN-1:0];

  genvar i, j, k;
  generate

    for (i=0 ; i<VN ; i=i+1)
      begin : g_i_fifo

        // If there are no promotion QVs, tie the signals off
// ACS_off UNEQUAL_WIDTH_REL_ARGS Inequality is only in parameter and constant
        if (QOS_PRESENT>0)
          begin : g_promo_qv
            assign promotion_qv_vn[i] = promotion_qv[(4*i)+:4];
          end
        else
          begin : g_no_promo_qv
            assign promotion_qv_vn[i] = 1'b0;
          end

        // Instantiate each VN FIFO. 

        adb400_r3_vn_fifo
          #(
            .FIFO_DEPTH (FIFO_DEPTH),
            .FIFO_WIDTH (FIFO_WIDTH),
            .QOS_PRESENT (QOS_PRESENT)
          )
        u_vn_fifo
          (
            .aclk      (aclk),
            .aresetn   (aresetn),
            .valid_src (valid_src_vn[i]),
            .payld_src (payld_src),
            .qv_src    (qv_src),
            .promotion_qv_update (promotion_qv_update),
            .promotion_qv (promotion_qv_vn[i]),
            .valid_dst (valid_dst_vn[i]),
            .ready_dst (ready_dst_vn[i]),
            .payld_dst (payld_dst_vn[i]),
            .max_qv    (arbitration_qv_vn[i]),
            .tkn_req   (tkn_req[i]),
            .tkn_gnt   (tkn_gnt[i]),
            .tkn_qv    (tkn_qv_vn[i]),
            .tkn_prealloc (tkn_prealloc_i[i]),
            .emptyn    (emptyn_vn_m[i])
          );

      end

    for (i=0 ; i<VN ; i=i+1)
      begin : g_payload_int_t
        // Create the transpose matrices
        for (j=0 ; j<(FIFO_WIDTH) ; j=j+1)
          begin : g_i_j_payld_t
            assign payld_dst_vn_t[j][i] = payld_dst_vn[i][j];
          end
      end // g_payload_int_t

  endgenerate

  // Arbitration choice of the arbiter
  wire [VN-1:0] vn_sel_mux;
  // Arbitration choice that the multiplexer is actually switching
  wire [VN-1:0] vn_sel_arb;

  generate
// ACS_off UNEQUAL_WIDTH_REL_ARGS Inequality is only in parameter and constant
    if (QOS_PRESENT<=0)
      begin : g_no_qv

        assign tkn_qv = 1'b0;

        //--------------------------------------------------------------------
        // Find VN that is LRU
        //--------------------------------------------------------------------

        adb400_r3_arbiter_lru
          #(
            .WAYS (VN)
          )
        u_arb_lru
          (
            .aclk      (aclk),
            .aresetn   (aresetn),
            .request_i (valid_dst_vn),
            .select_i  (vn_sel_mux),
            .ready_i   (ready_dst),
            .select_o  (vn_sel_arb)
          );

      end
    else
      begin : g_qv

        // Concatenation of the QoS signals from each VN for inter-VN arbitration
        wire [(4*VN)-1:0] qos_int;

       for (i=0 ; i<VN ; i=i+1)
          begin : g_tkn_qv
            assign tkn_qv [(i*4)+:4] = tkn_qv_vn[i];
            assign qos_int[(i*4)+:4] = arbitration_qv_vn[i];
          end // g_tkn_qv

        //--------------------------------------------------------------------
        // Find VN with highest priority entry in it
        //--------------------------------------------------------------------
        adb400_r3_arbiter_qos_lru
          #(
            .WAYS (VN),
            .QV_SIZE (4)
          )
        u_arb_qos_lru
          (
            .aclk      (aclk),
            .aresetn   (aresetn),
            .request_i (valid_dst_vn),
            .qos_i     (qos_int),
            .select_i  (vn_sel_mux),
            .ready_i   (ready_dst),
            .select_o  (vn_sel_arb)
          );

      end
  endgenerate

  //--------------------------------------------------------------------
  // Mux the VN FIFOs
  //--------------------------------------------------------------------
  
  // Staticise the arb mux select when the channel is sticky
  
  // First detect the fundamental channel stickiness
  reg  sticky;
  wire sticky_nxt = valid_dst & ~ready_dst;
  wire sticky_upd_en = sticky ? ready_dst : valid_dst;
  
  always @(posedge aclk or negedge aresetn)
    begin : p_sticky
      if (! aresetn)
        sticky <= 1'b0;
      else if (sticky_upd_en)
        sticky <= sticky_nxt;
    end
  
  // Next capture the select when going sticky
  reg  [VN-1:0] vn_sel_mux_sticky;
  wire vn_sel_mux_sticky_upd_en = ~sticky & sticky_nxt & sticky_upd_en;
  
  always @(posedge aclk or negedge aresetn)
    begin : p_vn_sel_mux_sticky
      if (! aresetn)
        vn_sel_mux_sticky <= {VN{1'b0}};
      else if (vn_sel_mux_sticky_upd_en)
        vn_sel_mux_sticky <= vn_sel_mux;
    end

  // Choose the registered version if sticky, else the last handshaked
  // version if that is still valid and the last was not a WLAST, else
  // a new arbitration
  generate
    if (REARB_CONTROL_PRESENT == 0)
      begin : g_rearb_control_absent

        assign vn_sel_mux = sticky ?
                              vn_sel_mux_sticky :
                              vn_sel_arb;

      end
    else
      begin : g_rearb_control_present

        // Stick with the same arbitration outcome unless
        // either that VN cannot send a transfer or the vn_rearb
        // input indicates otherwise
      
        // Record where the last handshake went
        reg  [VN-1:0] vn_sel_mux_last_hs;
        wire vn_sel_mux_last_hs_upd_en = valid_dst & ready_dst;
        always @(posedge aclk or negedge aresetn)
          begin : p_vn_sel_mux_last_hs
            if (! aresetn)
              vn_sel_mux_last_hs <= {VN{1'b0}};
            else if (vn_sel_mux_last_hs_upd_en)
              vn_sel_mux_last_hs <= vn_sel_mux;
          end

        wire last_hndshk_still_valid = (|(vn_sel_mux_last_hs & valid_dst_vn));

        assign vn_sel_mux = sticky ?
                              vn_sel_mux_sticky :
                              ((last_hndshk_still_valid && ~vn_rearb) ?
                               vn_sel_mux_last_hs:
                               vn_sel_arb);

      end
  endgenerate

  // Deal with the handshake signals

  assign valid_src_vn = ((valid_src && ~bar_src) ? vnpid_1h : {VN{1'b0}});

  wire barrier_pass_through = (~(|(emptyn_vn_m))  & bar_src); 
  assign ready_src = (bar_src ? (barrier_pass_through & ready_dst) : 1'b1);

  assign valid_dst = (barrier_pass_through ? valid_src : (|(valid_dst_vn)));
  assign ready_dst_vn = ready_dst ? vn_sel_mux : {VN{1'b0}};

  genvar m;
  generate

    // Mux the payloads according to the staticised select
    for (m=0 ; m<(FIFO_WIDTH) ; m=m+1)
      begin : g_m_payld_dst_mux
        assign payld_dst[m] = (barrier_pass_through ? payld_src[m] : (|(vn_sel_mux & payld_dst_vn_t[m])));
      end

  endgenerate

  assign tkn_release = ready_dst_vn;

endmodule
