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
// Checked In :  2016-02-12 14:23:46 +0000 (Fri, 12 Feb 2016)
// Revision : 206763
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_mst_transport_f1r1.v
//-----------------------------------------------------------------------------
// Purpose : Master interface half of a 2-channel transport bridge (i.e. no
//           protocol). This is wrapped in an additional layer to
//           provide specific parameters setting and remove unused ports.
//-----------------------------------------------------------------------------

module adb400_r3_mst_transport_f1
  #(parameter
      FIFO_DEPTH       = 6,
      OPREG            = 1,
      SYNC_LEVELS      = 2,
      PAYLOAD_WIDTH    = 1
  )
  (
    // Global signals
    input  wire                   aclk,
    input  wire                   aresetn,
    input  wire                   dftrstdisable,

    // Clock control
    input  wire                   clkqreqn_i,
    output wire                   clkqacceptn_o,
    output wire                   clkqdeny_o,

    // Clock requirement
    output wire                   clkqactive_o,

    // Wake-up
    output wire                   wakeup_o,

    //
    // Synchronous interfaces
    //

    // FW channel signalling
    output wire valid,
    input  wire ready,
    output wire [((PAYLOAD_WIDTH>0)?(PAYLOAD_WIDTH-1):0):0] payld,

    //
    // Asynchronous interfaces
    //

    // Cross-domain power state control
    input  wire                   slvmustacceptreqn_async,
    input  wire                   slvcandenyreqn_async,
    output wire                   slvacceptn_async,
    output wire                   slvdeny_async,

    // Cross-domain wakeup
    input  wire                   si_to_mi_wakeup_async,
    output wire                   mi_to_si_wakeup_async,

    // FW channel signalling
    input  wire [FIFO_DEPTH-1:0] wr_ptr_async,
    output wire [FIFO_DEPTH-1:0] rd_ptr_async,
    input  wire [((PAYLOAD_WIDTH>0)?((PAYLOAD_WIDTH*FIFO_DEPTH)-1):0):0] payld_async
  );

  // ----------------------------------------------------------------------------
  // Reset Synchroniser
  // ----------------------------------------------------------------------------

  wire aresetn_ss;
  wire internal_reset_n;

  adb400_r3_syncn
    #(
      .LEVELS           (SYNC_LEVELS)
    )
    u_syncn_aresetn
    (
      .aclk    (aclk),
      .aresetn (aresetn),
      .din     (1'b1),
      .dout    (aresetn_ss)
    );

  wire resetn_unforced = (dftrstdisable | aresetn_ss);
  wire resetn_forced   = (dftrstdisable | (aresetn_ss & internal_reset_n));

  //---------------------------------------------------------------------------
  // Control the fences, draining, and the MI side, plus interface to the 
  // upstream Q channels
  //---------------------------------------------------------------------------

  wire initiator_quiescent;
  reg  responder_quiescentn_q;
  wire initiator_quiescent_and_stalled;
  reg  responder_quiescent_and_stalledn_q;

  wire wakeup_local;

  wire initiator_fence_n_unused;
  wire responder_fence_n;
  wire inner_fence_n;
  wire outer_fence_n;
  wire pwrqactive_unused;

  adb400_r3_mi_ctrl
    #(
      .SYNC_LEVELS (SYNC_LEVELS)
    )
  u_mi_ctrl
    (
      .aclk                   (aclk),
      .aresetn                (resetn_unforced),

      .clkqreqn_i             (clkqreqn_i),
      .clkqacceptn_o          (clkqacceptn_o),
      .clkqdeny_o             (clkqdeny_o),
      .clkqactive_o           (clkqactive_o),

      .pwrqactive_o           (pwrqactive_unused),

      .wakeup_i               (1'b0),
      .wakeup_o               (wakeup_o),
      .wakeup_sync_i          (wakeup_local),

      .slvmustacceptreqn_async_i (slvmustacceptreqn_async),
      .slvcandenyreqn_async_i (slvcandenyreqn_async),
      .slvacceptn_o           (slvacceptn_async),
      .slvdeny_o              (slvdeny_async),

      .wakeup_async_i         (si_to_mi_wakeup_async),
      .wakeup_async_o         (mi_to_si_wakeup_async),

      .ar_dvm_multipart_quiescent_i (1'b1),
      .ac_dvm_multipart_quiescent_i (1'b1),
      .dvm_sync_complete_quiescent_i (1'b1),
      .initiator_quiescent_i  (initiator_quiescent),
      .responder_quiescent_i  (~responder_quiescentn_q),
      .initiator_quiescent_and_stalled_i  (initiator_quiescent_and_stalled),
      .responder_quiescent_and_stalled_i  (~responder_quiescent_and_stalledn_q),

      .initiator_fencen_o     (initiator_fence_n_unused),   
      .responder_fencen_o     (responder_fence_n),
      .inner_fencen_o         (inner_fence_n),       
      .outer_fencen_o         (outer_fence_n),       
      .internal_resetn_o      (internal_reset_n)     
    );


  //---------------------------------------------------------------------------
  // Apply the Q channel outer fence and the quiescence-enforcer fence
  // to the bare interfaces before using them everywhere else
  //---------------------------------------------------------------------------

  reg    hndshk_sticky_q;

  wire   valid_int;
  assign valid      = (outer_fence_n & (responder_fence_n | hndshk_sticky_q) & valid_int);
  wire   ready_int  = (outer_fence_n & (responder_fence_n | hndshk_sticky_q) & ready);

  wire hndshk_sticky_nxt = (valid_int & ~ready_int);
  wire hndshk_sticky_upd_en = 1'b1;
  always @(posedge aclk or negedge resetn_forced)
    begin : p_hndshk_sticky
      if (! resetn_forced)
        hndshk_sticky_q <= 1'b0;
      else if (hndshk_sticky_upd_en)
        hndshk_sticky_q <= hndshk_sticky_nxt;
    end

  //---------------------------------------------------------------------------
  // Signals for all the channel components to use to indicate their non-emptiness
  //---------------------------------------------------------------------------

  wire chan_cactive;
  wire reg_cactive;
  wire valid_reg;

  //--------------------------------------------------------------------
  // Combine the activity indicators
  //--------------------------------------------------------------------

  assign initiator_quiescent = 1'b1;
  assign initiator_quiescent_and_stalled = 1'b1;


  // Must avoid a chan_cactive *alone* causing quiescentn to go high
  // as that would only happen in the reset phase, which we want to avoid.
  
  // Predeclared above
  //reg  responder_quiescentn_q;
  wire responder_quiescentn_nxt    = (// Drive high because of a new transfer
                                      valid_reg |
                                      // Keep high till the transfer has completely left the channel
                                      (responder_quiescentn_q & (chan_cactive | reg_cactive))
                                     );
  wire responder_quiescentn_upd_en = (responder_quiescentn_q | responder_quiescentn_nxt);

  always @(posedge aclk or negedge resetn_forced)
    begin : p_responder_quiescentn
      if (! resetn_forced)
        responder_quiescentn_q <= 1'b0;
      else if (responder_quiescentn_upd_en)
        responder_quiescentn_q <= responder_quiescentn_nxt;
    end

  // Predeclared above
  //reg  responder_quiescent_and_stalledn_q;
  wire responder_quiescent_and_stalledn_nxt    = (// Drive high because of a new transfer
                                                  valid_reg |
                                                  // The channel is not stalled
                                                  responder_fence_n |
                                                  // Keep high till the transfer has completely left the channel
                                                  (responder_quiescent_and_stalledn_q & (chan_cactive | reg_cactive))
                                                 );
  wire responder_quiescent_and_stalledn_upd_en = (responder_quiescent_and_stalledn_q | responder_quiescent_and_stalledn_nxt);

  always @(posedge aclk or negedge resetn_forced)
    begin : p_responder_quiescent_and_stalledn
      if (! resetn_forced)
        responder_quiescent_and_stalledn_q <= 1'b0;
      else if (responder_quiescent_and_stalledn_upd_en)
        responder_quiescent_and_stalledn_q <= responder_quiescent_and_stalledn_nxt;
    end


  //--------------------------------------------------------------------
  // The upstream and downstream channel half instances.
  //--------------------------------------------------------------------

  // Channel

  // Predeclared above
  //wire                         valid_reg;
  wire                         ready_reg;
  wire [((PAYLOAD_WIDTH>0)?(PAYLOAD_WIDTH-1):0):0] payld_reg;

  wire valid_chan;
  assign valid_reg = (valid_chan & inner_fence_n);

  assign wakeup_local = (valid_reg | valid_int);

  adb400_r3_dnstrm_payld
    #(
      .WIDTH            (PAYLOAD_WIDTH),
      .DEPTH            (FIFO_DEPTH),
      .SYNC_LEVELS      (SYNC_LEVELS),
      .CACTIVE_OUTPUT   (1)
    )
  u_dnstrm
    (
      .aclk      (aclk),
      .aresetn   (resetn_forced),
      .cactive   (chan_cactive),

      .dst_valid (valid_chan),
      .dst_ready (ready_reg),
      .dst_payld (payld_reg),
     
      .wr_ptr_async    (wr_ptr_async),
      .rd_ptr_async    (rd_ptr_async),
      .payld_async     (payld_async)
    );

  generate
    if ((OPREG==0) || (PAYLOAD_WIDTH==0))
      begin : g_no_opreg
        assign valid_int = valid_reg;
        assign ready_reg = ready_int;
        assign payld     = payld_reg;

        assign reg_cactive = 1'b0;
      end
    else
      begin : g_opreg
        assign reg_cactive = valid_int;

        adb400_r3_ful_regd_slice
          #(.PAYLD_WIDTH(PAYLOAD_WIDTH))
        u_opreg
          (
           .aclk      (aclk),
           .aresetn   (resetn_forced),
           .valid_src (valid_reg),
           .ready_src (ready_reg),
           .payld_src (payld_reg),
           .valid_dst (valid_int),
           .ready_dst (ready_int),
           .payld_dst (payld)
          );
      end
  endgenerate

endmodule

