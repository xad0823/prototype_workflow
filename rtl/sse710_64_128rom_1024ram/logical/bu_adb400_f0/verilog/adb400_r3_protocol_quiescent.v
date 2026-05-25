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
// Checked In :  2016-02-10 15:33:14 +0000 (Wed, 10 Feb 2016)
// Revision : 206653
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_protocol_quiescent.v
//-----------------------------------------------------------------------------
// Purpose : Track whether a protocol has transactions outstanding upstream,
//           downstream or both..
//-----------------------------------------------------------------------------

module adb400_r3_protocol_quiescent
  #(
    parameter PROTOCOL_CHANNELS = 10,
              AR_VN             = 0,
              AW_VN             = 0,
              AR_QVN_DEPTH      = 4,
              AW_QVN_DEPTH      = 4,
              W_QVN_DEPTH       = 6,
              RD_OT_WIDTH       = 9,
              WR_OT_WIDTH       = 8,
              SN_OT_WIDTH       = 8
  )
  (
    // Global signals
    input  wire                   aclk,
    input  wire                   aresetn,

    // Deliberately falling edge is 1 cycle behind the true state
    // to remove timing paths
    output wire                   read_write_quiescent_o,
    output wire                   snoop_quiescent_o,
    output wire                   dvm_sync_complete_quiescent_o,
    // Indicate quiescent and stalled to allow Q channel interface state machines to rely on it
    output wire                   read_write_quiescent_and_stalled_o,
    output wire                   snoop_quiescent_and_stalled_o,

    // Signals to stall channels to prevent overflow or force quiescence
    input  wire                   force_read_write_quiescence_n_i,
    input  wire                   force_snoop_quiescence_n_i,
    output wire                   stall_ar_n_o,
    output wire                   stall_aw_n_o,
    output wire                   stall_w_n_o,
    output wire                   stall_b_n_o,
    output wire                   stall_ac_n_o,

    // Channel signals for AXI*
    input  wire                   arvalid_i,
    input  wire                   arready_i,
    input  wire                   rvalid_i,
    input  wire                   rready_i,
    input  wire                   rlast_i,
    input  wire                   awvalid_i,
    input  wire                   awready_i,
    input  wire                   awbar_i, // Needed to know if an AW has associated W
    input  wire                   wvalid_i,
    input  wire                   wready_i,
    input  wire                   wlast_i,
    input  wire                   bvalid_i,
    input  wire                   bready_i,
    // Channel signals for ACE-Lite+DVM
    input  wire                   ar_dvm_sync_i,
    input  wire                   ar_dvm_complete_i,
    input  wire                   acvalid_i,
    input  wire                   acready_i,
    input  wire                   ac_dvm_sync_i,
    input  wire                   ac_dvm_complete_i,
    input  wire                   crvalid_i,
    input  wire                   crready_i,
    // Channel signals for ACE-F
    input  wire                   aw_evict_i, // Needed to know if an AW has associated W
    input  wire                   cr_pass_data_i,
    input  wire                   cdvalid_i,
    input  wire                   cdready_i,
    input  wire                   cdlast_i,
    input  wire                   rack_i,
    input  wire                   wack_i,

    // QVN-related signals
    input  wire                                     arbar_i, // Only needed for token accounting
    input  wire [((AR_VN>0)?(AR_VN-1):0):0]         varvalid_i,
    input  wire [((AR_VN>0)?(AR_VN-1):0):0]         varready_i,
    input  wire [((AR_VN>0)?(AR_VN-1):0):0]         arvnpid_i,
    input  wire [((AW_VN>0)?(AW_VN-1):0):0]         vawvalid_i,
    input  wire [((AW_VN>0)?(AW_VN-1):0):0]         vawready_i,
    input  wire [((AW_VN>0)?(AW_VN-1):0):0]         awvnpid_i,
    input  wire [((AW_VN>0)?(AW_VN-1):0):0]         vwvalid_i,
    input  wire [((AW_VN>0)?(AW_VN-1):0):0]         vwready_i,
    input  wire [((AW_VN>0)?(AW_VN-1):0):0]         wvnpid_i,
    output wire [((AR_VN>0)?(AR_VN-1):0):0]         stall_var_n_o,
    output wire [((AW_VN>0)?(AW_VN-1):0):0]         stall_vaw_n_o,
    output wire [((AW_VN>0)?(AW_VN-1):0):0]         stall_vw_n_o
  );

`include "adb400_r3_functions.v"

  genvar i;

  // ----------------------------------------------------------------------
  // Some limits on types of transactions from the ACE Specification
  // ----------------------------------------------------------------------

  // Maximum number of AR DVM-Sync that have not had an AC DVM-Complete
  localparam MAX_AR_TO_AC_DVM_SYNC = 1;   // From the ACE spec C12.2
  // Maximum number of AC DVM-Sync that have not had an AR DVM-Complete
  localparam MAX_AC_TO_AR_DVM_SYNC = 256; // From the ACE spec C12.2

  // ----------------------------------------------------------------------
  // Counter values
  // ----------------------------------------------------------------------

  // For writes
  localparam [WR_OT_WIDTH-1:0] WR_OT_X       = {WR_OT_WIDTH{1'bx}};
  localparam [WR_OT_WIDTH-1:0] WR_OT_ZERO    = {WR_OT_WIDTH{1'b0}};
  localparam [WR_OT_WIDTH-1:0] WR_OT_ONE     = {{(WR_OT_WIDTH-1){1'b0}},1'b1};
  localparam [WR_OT_WIDTH-1:0] WR_OT_MAX     = {WR_OT_WIDTH{1'b1}};
  localparam [WR_OT_WIDTH-1:0] WR_OT_MAX_M1  = {{(WR_OT_WIDTH-1){1'b1}},1'b0};
  localparam [WR_OT_WIDTH-1:0] WR_OT_MAX_M2  = {{(WR_OT_WIDTH-2){1'b1}},2'b01};
  
  // The AW->WLAST counter adds an extra bit because it can be -ve for leading W
  localparam WL_OT_WIDTH = WR_OT_WIDTH + 1;
  localparam [WL_OT_WIDTH-1:0] WL_OT_X       = {WL_OT_WIDTH{1'bx}};
  localparam [WL_OT_WIDTH-1:0] WL_OT_ZERO    = {WL_OT_WIDTH{1'b0}};
  localparam [WL_OT_WIDTH-1:0] WL_OT_ONE     = {{(WL_OT_WIDTH-1){1'b0}},1'b1};
  localparam [WL_OT_WIDTH-1:0] WL_OT_M1      = {WL_OT_WIDTH{1'b1}};
  localparam [WL_OT_WIDTH-1:0] WL_OT_MAX     = {1'b0,{(WL_OT_WIDTH-1){1'b1}}};
  localparam [WL_OT_WIDTH-1:0] WL_OT_MAX_M1  = {1'b0,{(WL_OT_WIDTH-2){1'b1}},1'b0};
  localparam [WL_OT_WIDTH-1:0] WL_OT_MAX_M2  = {1'b0,{(WL_OT_WIDTH-3){1'b1}},2'b01};
  localparam [WL_OT_WIDTH-1:0] WL_OT_MIN     = {1'b1,{(WL_OT_WIDTH-1){1'b0}}};
  localparam [WL_OT_WIDTH-1:0] WL_OT_MIN_P2  = {1'b1,{(WL_OT_WIDTH-3){1'b0}},2'b10};
// ACS_off start ARITHMETIC_TRUNCATION UNEQUAL_WIDTH_OP_ARGS Adding small +ve numbers to a large -ve number, so no loss of information
  localparam [WL_OT_WIDTH-1:0] WL_OT_MIN_PT       = WL_OT_MIN + W_QVN_DEPTH;
  localparam [WL_OT_WIDTH-1:0] WL_OT_MIN_PTP1     = WL_OT_MIN_PT + 1;
  localparam [WL_OT_WIDTH-1:0] WL_OT_MIN_PTP2     = WL_OT_MIN_PT + 2;
// ACS_off end ARITHMETIC_TRUNCATION UNEQUAL_WIDTH_OP_ARGS

  // For reads
  localparam [RD_OT_WIDTH-1:0] RD_OT_X       = {RD_OT_WIDTH{1'bx}};
  localparam [RD_OT_WIDTH-1:0] RD_OT_ZERO    = {RD_OT_WIDTH{1'b0}};
  localparam [RD_OT_WIDTH-1:0] RD_OT_ONE     = {{(RD_OT_WIDTH-1){1'b0}},1'b1};
  localparam [RD_OT_WIDTH-1:0] RD_OT_MAX     = {RD_OT_WIDTH{1'b1}};
  localparam [RD_OT_WIDTH-1:0] RD_OT_MAX_M1  = {{(RD_OT_WIDTH-1){1'b1}},1'b0};
  localparam [RD_OT_WIDTH-1:0] RD_OT_MAX_M2  = {{(RD_OT_WIDTH-2){1'b1}},2'b01};

  
  // For snoops
  localparam [SN_OT_WIDTH-1:0] SN_OT_X       = {SN_OT_WIDTH{1'bx}};
  localparam [SN_OT_WIDTH-1:0] SN_OT_ZERO    = {SN_OT_WIDTH{1'b0}};
  localparam [SN_OT_WIDTH-1:0] SN_OT_ONE     = {{(SN_OT_WIDTH-1){1'b0}},1'b1};
  localparam [SN_OT_WIDTH-1:0] SN_OT_MAX     = {SN_OT_WIDTH{1'b1}};
  localparam [SN_OT_WIDTH-1:0] SN_OT_MAX_M1  = {{(SN_OT_WIDTH-1){1'b1}},1'b0};
  localparam [SN_OT_WIDTH-1:0] SN_OT_MAX_M2  = {{(SN_OT_WIDTH-2){1'b1}},2'b01};

  
  // For snoop<->read interactions
  localparam COUNT_AR_TO_AC_WIDTH = clogb2(MAX_AR_TO_AC_DVM_SYNC);
  localparam [COUNT_AR_TO_AC_WIDTH-1:0] COUNT_AR_TO_AC_X    = {COUNT_AR_TO_AC_WIDTH{1'bx}};
  localparam [COUNT_AR_TO_AC_WIDTH-1:0] COUNT_AR_TO_AC_ZERO = {COUNT_AR_TO_AC_WIDTH{1'b0}};

  localparam COUNT_AC_TO_AR_WIDTH = clogb2(MAX_AC_TO_AR_DVM_SYNC);
  localparam [COUNT_AC_TO_AR_WIDTH-1:0] COUNT_AC_TO_AR_X    = {COUNT_AC_TO_AR_WIDTH{1'bx}};
  localparam [COUNT_AC_TO_AR_WIDTH-1:0] COUNT_AC_TO_AR_ZERO = {COUNT_AC_TO_AR_WIDTH{1'b0}};

  // NOTE: With QVN tokens, the counter size must be capable of holding an extra 2
  //       as they could be in a reg slice (and so not have decremented), but
  //       replacements could be in the VN FIFO and the VN FIFO requesting tokens
  //       for them
  // AR QVN tokens
  localparam VAR_OT_WIDTH = clogb2(AR_QVN_DEPTH+1+2); // Counts init to 1
  localparam [VAR_OT_WIDTH-1:0] VAR_OT_X       = {VAR_OT_WIDTH{1'bx}};
  localparam [VAR_OT_WIDTH-1:0] VAR_OT_ZERO    = {VAR_OT_WIDTH{1'b0}};
  localparam [VAR_OT_WIDTH-1:0] VAR_OT_ONE     = {{(VAR_OT_WIDTH-1){1'b0}},1'b1};

  // AW QVN tokens
  localparam VAW_OT_WIDTH = clogb2(AW_QVN_DEPTH+1+2); // Counts init to 1
  localparam [VAW_OT_WIDTH-1:0] VAW_OT_X       = {VAW_OT_WIDTH{1'bx}};
  localparam [VAW_OT_WIDTH-1:0] VAW_OT_ZERO    = {VAW_OT_WIDTH{1'b0}};
  localparam [VAW_OT_WIDTH-1:0] VAW_OT_ONE     = {{(VAW_OT_WIDTH-1){1'b0}},1'b1};

  // W QVN tokens
  localparam VW_OT_WIDTH = clogb2(W_QVN_DEPTH+2);
  localparam [VW_OT_WIDTH-1:0] VW_OT_X       = {VW_OT_WIDTH{1'bx}};
  localparam [VW_OT_WIDTH-1:0] VW_OT_ZERO    = {VW_OT_WIDTH{1'b0}};


  // -----------------------------------------------------------------
  //  READ
  // -----------------------------------------------------------------
  wire count_ar_to_rend_inc;
  wire count_ar_to_rend_dec;
  generate
    if (PROTOCOL_CHANNELS < 10)
      begin : g_read_no_rack

        // Make explicit that things are unused
        wire rack_i_unused = rack_i;

        // Tracker for AR->RLAST is required for protocols that don't have RACK

        // When to increment and decrement the counters
        assign count_ar_to_rend_inc = (arvalid_i & arready_i);
        assign count_ar_to_rend_dec = (rvalid_i  & rready_i & rlast_i);

      end
    else
      begin : g_read_has_ack

        // Make explicit that things are unused
        wire rvalid_i_unused = rvalid_i;
        wire rready_i_unused = rready_i;
        wire rlast_i_unused  = rlast_i;

        // Tracker for AR->RACK is required for protocols that have RACK

        // When to increment and decrement the counters
        assign count_ar_to_rend_inc = (arvalid_i & arready_i);
        assign count_ar_to_rend_dec = (rack_i);


      end
  endgenerate

  // AR->RACK counter
  reg  [RD_OT_WIDTH-1:0] count_ar_to_rend_q;
  wire                   count_ar_to_rend_ovrflw;
  wire [RD_OT_WIDTH-1:0] count_ar_to_rend_p1;
  wire [RD_OT_WIDTH-1:0] count_ar_to_rend_m1;
  reg  [RD_OT_WIDTH-1:0] count_ar_to_rend_nxt;
  wire                   count_ar_to_rend_upd_en;
  reg                    count_ar_to_rend_ez_q;
  wire                   count_ar_to_rend_ez_nxt;
  reg                    count_ar_to_rend_gemm1_q;
  wire                   count_ar_to_rend_gemm1_nxt;

// ACS_off start UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1 to guide synthesis to an incrementer/decrementer
   assign {count_ar_to_rend_ovrflw,count_ar_to_rend_p1} = count_ar_to_rend_q + 1'b1;
   assign                          count_ar_to_rend_m1  = count_ar_to_rend_q - 1'b1;
// ACS_off end UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING

  always @*
    begin : p_count_ar_to_rend_nxt
      case ({count_ar_to_rend_inc,count_ar_to_rend_dec})
        2'b00,
        2'b11:
          count_ar_to_rend_nxt = count_ar_to_rend_q;
        2'b01:
          count_ar_to_rend_nxt = count_ar_to_rend_m1;
        2'b10:
          count_ar_to_rend_nxt = count_ar_to_rend_p1;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
        default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
          count_ar_to_rend_nxt = RD_OT_X;
      endcase
    end

  assign count_ar_to_rend_ez_nxt    = (RD_OT_ZERO   == count_ar_to_rend_nxt);
  assign count_ar_to_rend_gemm1_nxt = (RD_OT_MAX_M1 <= count_ar_to_rend_nxt);

  assign count_ar_to_rend_upd_en = (count_ar_to_rend_inc | count_ar_to_rend_dec);

  always @(posedge aclk or negedge aresetn)
    begin : p_count_ar_to_rend_q
      if (! aresetn)
        begin
          count_ar_to_rend_q       <= RD_OT_ZERO;
          count_ar_to_rend_ez_q    <= 1'b1;
          count_ar_to_rend_gemm1_q <= 1'b0;
        end
      else if (count_ar_to_rend_upd_en)
        begin
// ACS_off start CDC_END Where this register exists, it is an expected CDC endpoint.
          count_ar_to_rend_q       <= count_ar_to_rend_nxt;
          count_ar_to_rend_ez_q    <= count_ar_to_rend_ez_nxt;
          count_ar_to_rend_gemm1_q <= count_ar_to_rend_gemm1_nxt;
// ACS_off end CDC_END
        end
    end

  // Stall the AR channel
  reg  stall_ar_n_q;
  // Stalling is dependent on whether there are VNs or not.
  wire stall_ar_n_nxt;
  // Whenever a transaction could be starting or ending, or the quiescence is requested
  wire stall_ar_n_upd_en = 1'b1;
  always @(posedge aclk or negedge aresetn)
    begin : p_stall_ar_n_q
      if (! aresetn)
        stall_ar_n_q <= 1'b0;
      else if (stall_ar_n_upd_en)
        stall_ar_n_q <= stall_ar_n_nxt;
    end

  assign stall_ar_n_o = stall_ar_n_q;

  wire read_quiescent_nxt;

  generate
    if (AR_VN<=0)
      begin : g_ar_vn_absent

        // Make explicit that things are unused
        wire varvalid_i_unused = varvalid_i;
        wire varready_i_unused = varready_i;
        wire arvnpid_i_unused  = arvnpid_i;

        assign read_quiescent_nxt  = (
                                      count_ar_to_rend_ez_q & ~arvalid_i
                                     );

        // Stall AR when either the counter could overflow or quiescence is
        // requested and the channel is not sticky
        assign stall_ar_n_nxt = (
                               (arvalid_i & ~arready_i) |          // Sticky valid
                               (
                                (~count_ar_to_rend_gemm1_q) &      // Not the max count
                                (force_read_write_quiescence_n_i)  // Not trying to force quiescence
                               )
                              );

        assign stall_var_n_o = 1'b0;

      end
    else
      begin : g_ar_vn_present

        // To forcibly quiesce read QVN:
        // - For each VN, Fence VAR until all it has 0 or prealloc credits upstream
        // - When that is true for all VNs, fence AR
        // - For each VN, unfence VAR until it has prealloc (which may be 0) credits upstream
        //
        // So the credit fence is active when:
        // - (trying to quiesce AND
        // -  ((credit counter >= 1) OR
        // -   ((credit_counter == 0) AND
        // -    channel fence is active)))
        //
        // To avoid having to sample the prealloc value, init the counter to 1 and
        // if there is no prealloc it will never go down to 0, but if there is prealloc it can.

        reg  [VAR_OT_WIDTH-1:0] count_var_to_ar_q      [AR_VN-1:0];
        wire [VAR_OT_WIDTH-1:0] count_var_to_ar_p1     [AR_VN-1:0];
        wire [VAR_OT_WIDTH-1:0] count_var_to_ar_m1     [AR_VN-1:0];
        reg  [VAR_OT_WIDTH-1:0] count_var_to_ar_nxt    [AR_VN-1:0];
        wire [AR_VN-1:0]        count_var_to_ar_inc;
        wire [AR_VN-1:0]        count_var_to_ar_dec;
        wire [AR_VN-1:0]        count_var_to_ar_upd_en;
        reg  [AR_VN-1:0]        count_var_to_ar_ez_q;
        wire [AR_VN-1:0]        count_var_to_ar_ez_nxt;
        reg  [AR_VN-1:0]        count_var_to_ar_eo_q;
        wire [AR_VN-1:0]        count_var_to_ar_eo_nxt;

        wire [AR_VN-1:0]        stall_var_n_nxt;

        for (i=0 ; i<AR_VN ; i=i+1)
          begin : g_i

            wire count_var_to_ar_ovrflw;

// ACS_off start UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1 to guide synthesis to an incrementer/decrementer
            assign {count_var_to_ar_ovrflw,count_var_to_ar_p1[i]} = count_var_to_ar_q[i] + 1'b1;
            assign                         count_var_to_ar_m1[i]  = count_var_to_ar_q[i] - 1'b1;
// ACS_off end UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING

            assign count_var_to_ar_inc[i] = (varvalid_i[i] & varready_i[i]);
            assign count_var_to_ar_dec[i] = (arvalid_i & arready_i &               // There is a handshake
                                             ~arbar_i &                            // that uses a token
                                             arvnpid_i[i]);                        // and is for this VN

            always @*
              begin : p_count_var_to_ar_nxt
                case ({count_var_to_ar_inc[i],count_var_to_ar_dec[i]})
                  2'b00,
                  2'b11:
                    count_var_to_ar_nxt[i] = count_var_to_ar_q[i];
                  2'b01:
                    count_var_to_ar_nxt[i] = count_var_to_ar_m1[i];
                  2'b10:
                    count_var_to_ar_nxt[i] = count_var_to_ar_p1[i];
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
                  default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                    count_var_to_ar_nxt[i] = VAR_OT_X;
                endcase
              end
        
            assign count_var_to_ar_ez_nxt[i]    = (VAR_OT_ZERO   == count_var_to_ar_nxt[i]);
            assign count_var_to_ar_eo_nxt[i]    = (VAR_OT_ONE    == count_var_to_ar_nxt[i]);
        
            assign count_var_to_ar_upd_en[i] = (count_var_to_ar_inc[i] | count_var_to_ar_dec[i]);
        
            always @(posedge aclk or negedge aresetn)
              begin : p_count_var_to_ar_q
                if (! aresetn)
                  begin
                    count_var_to_ar_q[i]       <= VAR_OT_ONE;
                    count_var_to_ar_ez_q[i]    <= 1'b0;
                    count_var_to_ar_eo_q[i]    <= 1'b1;
                  end
                else if (count_var_to_ar_upd_en[i])
                  begin
                    count_var_to_ar_q[i]       <= count_var_to_ar_nxt[i];
                    count_var_to_ar_ez_q[i]    <= count_var_to_ar_ez_nxt[i];
                    count_var_to_ar_eo_q[i]    <= count_var_to_ar_eo_nxt[i];
                  end
              end

            assign stall_var_n_nxt[i] = (
                                         ((varvalid_i[i] & ~varready_i[i]) | // the request is not sticky OR
                                          force_read_write_quiescence_n_i |  // not trying to quiesce OR
                                          (count_var_to_ar_ez_nxt[i] &         // credit_counter == 0 AND
                                           ~stall_ar_n_o))                   // channel fence is active
                                        );
          end

        reg  [AR_VN-1:0]       stall_var_n_q;
        wire                   stall_var_n_upd_en = 1'b1;

        always @(posedge aclk or negedge aresetn)
          begin : p_stall_var_n_q
            if (! aresetn)
              stall_var_n_q <= {AR_VN{1'b0}};
            else if (stall_var_n_upd_en)
              stall_var_n_q <= stall_var_n_nxt;
          end

        assign stall_var_n_o = stall_var_n_q;

        assign read_quiescent_nxt  = (
                                      count_ar_to_rend_ez_q & ~arvalid_i &
                                      (&(count_var_to_ar_eo_q)) & // All credits are where they should be
                                      ~(|(varvalid_i))            // And will be staying there
                                     );

        // Stall AR when either the counter could overflow or quiescence is
        // requested and the channel is not sticky
        assign stall_ar_n_nxt = (
                                 (arvalid_i & ~arready_i) |          // Sticky valid
                                 (
                                  (~count_ar_to_rend_gemm1_q) &      // Not the max count
                                  (force_read_write_quiescence_n_i | // Not trying to force quiescence
                                   ~(&(count_var_to_ar_ez_q |      // Tokens upstream that need to be used
                                       count_var_to_ar_eo_q)))
                                 )
                                );
      end
  endgenerate


  // -----------------------------------------------------------------
  //  WRITE
  // -----------------------------------------------------------------

  wire stall_aw_n_nxt;
  wire stall_w_n_nxt;

  wire write_quiescent_nxt;

  // AW->B/WACK counter
  wire count_aw_to_wend_inc;
  wire count_aw_to_wend_dec;

  generate

    if (PROTOCOL_CHANNELS < 10)
      begin : g_write_no_wack

        // Make explicit that things are unused
        wire wack_i_unused = wack_i;

        // Tracker for AW->B is required for protocols that don't have WACK

        // When to increment and decrement the counters
        assign count_aw_to_wend_inc = (awvalid_i & awready_i);
        assign count_aw_to_wend_dec = (bvalid_i  & bready_i);

      end
    else
      begin : g_write_has_wack

        // Make explicit that things are unused
        wire bvalid_i_unused = bvalid_i;
        wire bready_i_unused = bready_i;

        // Trackers for AW->WACK is required for protocols that have WACK

        // When to increment and decrement the counters
        assign count_aw_to_wend_inc = (awvalid_i & awready_i);
        assign count_aw_to_wend_dec = (wack_i);
      end

  endgenerate

  reg  [WR_OT_WIDTH-1:0] count_aw_to_wend_q;
  wire                   count_aw_to_wend_ovrflw;
  wire [WR_OT_WIDTH-1:0] count_aw_to_wend_p1;
  wire [WR_OT_WIDTH-1:0] count_aw_to_wend_m1;
  reg  [WR_OT_WIDTH-1:0] count_aw_to_wend_nxt;
  wire                   count_aw_to_wend_upd_en;
  reg                    count_aw_to_wend_ez_q;
  wire                   count_aw_to_wend_ez_nxt;
  reg                    count_aw_to_wend_gemm1_q;
  wire                   count_aw_to_wend_gemm1_nxt;
        
// ACS_off start UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1 to guide synthesis to an incrementer/decrementer
  assign {count_aw_to_wend_ovrflw,count_aw_to_wend_p1} = count_aw_to_wend_q + 1'b1;
  assign                          count_aw_to_wend_m1  = count_aw_to_wend_q - 1'b1;
// ACS_off end UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING
        
  always @*
    begin : p_count_aw_to_wend_nxt
      case ({count_aw_to_wend_inc,count_aw_to_wend_dec})
        2'b00,
        2'b11:
          count_aw_to_wend_nxt = count_aw_to_wend_q;
        2'b01:
          count_aw_to_wend_nxt = count_aw_to_wend_m1;
        2'b10:
          count_aw_to_wend_nxt = count_aw_to_wend_p1;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
        default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
          count_aw_to_wend_nxt = WR_OT_X;
      endcase
    end
        
  assign count_aw_to_wend_ez_nxt    = (WR_OT_ZERO   == count_aw_to_wend_nxt);
  assign count_aw_to_wend_gemm1_nxt = (WR_OT_MAX_M1 <= count_aw_to_wend_nxt);
        
  assign count_aw_to_wend_upd_en = (count_aw_to_wend_inc | count_aw_to_wend_dec);
        
  always @(posedge aclk or negedge aresetn)
    begin : p_count_aw_to_wend_q
      if (! aresetn)
        begin
          count_aw_to_wend_q       <= WR_OT_ZERO;
          count_aw_to_wend_ez_q    <= 1'b1;
          count_aw_to_wend_gemm1_q <= 1'b0;
        end
      else if (count_aw_to_wend_upd_en)
        begin
          count_aw_to_wend_q       <= count_aw_to_wend_nxt;
          count_aw_to_wend_ez_q    <= count_aw_to_wend_ez_nxt;
          count_aw_to_wend_gemm1_q <= count_aw_to_wend_gemm1_nxt;
        end
    end

  wire aw_is_dataless;

  generate

    if (PROTOCOL_CHANNELS < 10)
      begin : g_write_no_evict

        // Make explicit that things are unused
        wire aw_evict_i_unused = aw_evict_i;

        assign aw_is_dataless = awbar_i;

      end
    else
      begin : g_write_has_evict

        assign aw_is_dataless = (awbar_i | aw_evict_i);

      end

  endgenerate

  generate
    if (AW_VN<=0)
      begin : g_aw_vn_absent

        // Make explicit that things are unused
        wire vawvalid_i_unused = vawvalid_i;
        wire vawready_i_unused = vawready_i;
        wire awvnpid_i_unused  = awvnpid_i;
        wire vwvalid_i_unused  = vwvalid_i;
        wire vwready_i_unused  = vwready_i;
        wire wvnpid_i_unused   = wvnpid_i;

        assign stall_vaw_n_o = 1'b0;
        assign stall_vw_n_o = 1'b0;

        // Can determine leading/pending W by counting AW versus WLAST
        // and recording whether last W was a WLAST:
        // more AW than WLAST -> pending W
        // same WLAST as AW and most recent W was WLAST -> no pending or leading W
        // otherwise -> leading W

        // Increase count widths by 1 so we can use as signed
        // NOTE: do not need overflow or underflow prevention because the
        //       channel-level prevention will do that implicitly as part
        //       of the AW->B/WACK and W(first)->B/WACK overflow prevention.
        reg  [WL_OT_WIDTH-1:0] count_aw_to_wlast_q;
        wire [WL_OT_WIDTH-1:0] count_aw_to_wlast_p1;
        wire [WL_OT_WIDTH-1:0] count_aw_to_wlast_m1;
        wire                   count_aw_to_wlast_ep1;
        wire                   count_aw_to_wlast_em1;
        wire                   count_aw_to_wlast_emp2;
        wire                   count_aw_to_wlast_em;
        reg  [WL_OT_WIDTH-1:0] count_aw_to_wlast_nxt;
        wire                   count_aw_to_wlast_inc;
        wire                   count_aw_to_wlast_dec;
        wire                   count_aw_to_wlast_upd_en;
        reg                    count_aw_to_wlast_ez_q;
        reg                    count_aw_to_wlast_ez_nxt;
        reg                    count_aw_to_wlast_lz_q;
        reg                    count_aw_to_wlast_lz_nxt;
        reg                    count_aw_to_wlast_gz_q;
        reg                    count_aw_to_wlast_gz_nxt;
        reg                    count_aw_to_wlast_lemp1_q;
        reg                    count_aw_to_wlast_lemp1_nxt;

        reg                    w_first_q;
        wire                   w_first_nxt;
        wire                   w_first_upd_en;

        reg                    pending_w_q;
        reg                    pending_w_nxt;
        wire                   pending_w_upd_en;

        reg                    leading_w_q;
        reg                    leading_w_nxt;

        // Count AW to WLAST outstanding activity

        //   NOTE: is signed as there can be leading W

        wire count_aw_to_wlast_ovrflw;

// ACS_off start UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1 to guide synthesis to an incrementer/decrementer
        assign {count_aw_to_wlast_ovrflw,count_aw_to_wlast_p1} = count_aw_to_wlast_q + 1'b1;
        assign                           count_aw_to_wlast_m1  = count_aw_to_wlast_q - 1'b1;
// ACS_off end UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING
        assign count_aw_to_wlast_ep1  = (WL_OT_ONE    == count_aw_to_wlast_q);
        assign count_aw_to_wlast_em1  = (WL_OT_M1     == count_aw_to_wlast_q);
        assign count_aw_to_wlast_emp2 = (WL_OT_MIN_P2 == count_aw_to_wlast_q);
        assign count_aw_to_wlast_em   = (WL_OT_MIN    == count_aw_to_wlast_q);

        assign count_aw_to_wlast_inc = (awvalid_i & awready_i & ~aw_is_dataless);
        assign count_aw_to_wlast_dec = (wvalid_i  & wready_i  &  wlast_i);

        always @*
          begin : p_count_aw_to_wlast_nxt
            case ({count_aw_to_wlast_inc,count_aw_to_wlast_dec})
              2'b00,
              2'b11:
                begin
                  count_aw_to_wlast_nxt       = count_aw_to_wlast_q;
                  count_aw_to_wlast_ez_nxt    = count_aw_to_wlast_ez_q;
                  count_aw_to_wlast_gz_nxt    = count_aw_to_wlast_gz_q;
                  count_aw_to_wlast_lz_nxt    = count_aw_to_wlast_lz_q;
                  count_aw_to_wlast_lemp1_nxt = count_aw_to_wlast_lemp1_q;
                end
              2'b01:
                begin
                  count_aw_to_wlast_nxt       = count_aw_to_wlast_m1;
                  count_aw_to_wlast_ez_nxt    = count_aw_to_wlast_ep1;
                  count_aw_to_wlast_gz_nxt    = ~(count_aw_to_wlast_ep1 | count_aw_to_wlast_ez_q | count_aw_to_wlast_lz_q);
                  count_aw_to_wlast_lz_nxt    = (count_aw_to_wlast_ez_q | count_aw_to_wlast_lz_q);
                  count_aw_to_wlast_lemp1_nxt = (count_aw_to_wlast_lemp1_q | count_aw_to_wlast_emp2);
                end
              2'b10:
                begin
                  count_aw_to_wlast_nxt       = count_aw_to_wlast_p1;
                  count_aw_to_wlast_ez_nxt    = count_aw_to_wlast_em1;
                  count_aw_to_wlast_gz_nxt    = (count_aw_to_wlast_gz_q | count_aw_to_wlast_ez_q);
                  count_aw_to_wlast_lz_nxt    = ~(count_aw_to_wlast_gz_q | count_aw_to_wlast_ez_q | count_aw_to_wlast_em1);
                  count_aw_to_wlast_lemp1_nxt = count_aw_to_wlast_em;
                end
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
              default:
// ACS_off start UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                begin
                  count_aw_to_wlast_nxt       = WL_OT_X;
                  count_aw_to_wlast_ez_nxt    = 1'bx;
                  count_aw_to_wlast_gz_nxt    = 1'bx;
                  count_aw_to_wlast_lz_nxt    = 1'bx;
                  count_aw_to_wlast_lemp1_nxt = 1'bx;
                end
// ACS_off end UNREACHABLE_DEFAULT_STATEMENT
            endcase
          end
        
        assign count_aw_to_wlast_upd_en = (count_aw_to_wlast_inc | count_aw_to_wlast_dec);
        
        always @(posedge aclk or negedge aresetn)
          begin : p_count_aw_to_wlast_q
            if (! aresetn)
              begin
                count_aw_to_wlast_q       <= WL_OT_ZERO;
                count_aw_to_wlast_ez_q    <= 1'b1;
                count_aw_to_wlast_lz_q    <= 1'b0;
                count_aw_to_wlast_gz_q    <= 1'b0;
                count_aw_to_wlast_lemp1_q <= 1'b0;
              end
            else if (count_aw_to_wlast_upd_en)
              begin
                count_aw_to_wlast_q       <= count_aw_to_wlast_nxt;
                count_aw_to_wlast_ez_q    <= count_aw_to_wlast_ez_nxt;
                count_aw_to_wlast_lz_q    <= count_aw_to_wlast_lz_nxt;
                count_aw_to_wlast_gz_q    <= count_aw_to_wlast_gz_nxt;
                count_aw_to_wlast_lemp1_q <= count_aw_to_wlast_lemp1_nxt;
              end
          end

        assign w_first_nxt = wlast_i;
        assign w_first_upd_en = (wvalid_i & wready_i);

        always @(posedge aclk or negedge aresetn)
          begin : p_w_first_q
            if (! aresetn)
              w_first_q <= 1'b1;
            else if (w_first_upd_en)
              w_first_q <= w_first_nxt;
          end

        // There will be pending W next cycle if:
        // - there is a non-last W this cycle: there must be a W to follow it (wvalid_i & wready_i & ~wlast_i)
        // - there is a dataful-AW handshake (count_aw_to_wlast_inc)
        // - there is more than one pending WLAST this cycle (count_aw_to_wlast_gz_q & ~count_aw_to_wlast_ep1)
        // - there is exactly one pending WLAST and no W handshake (count_aw_to_wlast_ep1 & ~(wvalid_i & wready_i))
        assign pending_w_upd_en = (count_aw_to_wlast_inc | w_first_upd_en);
        
        always @*
          begin : p_pending_leading_w_nxt
            case ({count_aw_to_wlast_inc,count_aw_to_wlast_dec})
              2'b00:
                begin
                  // non-last-W sets pending W
                  pending_w_nxt            = (pending_w_q |
                                              (w_first_upd_en & ~w_first_nxt));
                  // Any W will set if aw_to_wlast<=0
                  leading_w_nxt            = (leading_w_q |
                                              (w_first_upd_en & ~count_aw_to_wlast_gz_q));
                end
              2'b01:
                begin
                  // WLAST clears it if the count >1 
                  pending_w_nxt            = (count_aw_to_wlast_gz_q &
                                              ~count_aw_to_wlast_ep1);
                  // If aw_to_wlast<=0 then *any* W will be leading
                  leading_w_nxt            = ~count_aw_to_wlast_gz_q;
                end
              2'b11:
                begin
                  // Clears if the WLAST must be behind the AW
                  pending_w_nxt            = count_aw_to_wlast_gz_q;
                  // If the WLAST must be ahead of the AW
                  leading_w_nxt            = count_aw_to_wlast_lz_q;
                end
              2'b10:
                begin
                  // Set if the AW is not completely clearing a backlog
                  pending_w_nxt            = (~count_aw_to_wlast_lz_q |
                                              (~w_first_q | w_first_upd_en));
                  // An AW from aw_to_wlast>=0 clears, and from ==-1 clears if w_first and no W at all
                  leading_w_nxt            = ~(~count_aw_to_wlast_lz_q | 
                                               (count_aw_to_wlast_em1 & (w_first_q & ~w_first_upd_en)));
                end
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
              default:
// ACS_off start UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                begin
                  pending_w_nxt            = 1'bx;
                  leading_w_nxt            = 1'bx;
                end
// ACS_off end UNREACHABLE_DEFAULT_STATEMENT
            endcase
          end
        
        always@(posedge aclk or negedge aresetn)
          begin : p_pending_leading_w_q
            if (! aresetn)
              begin
                pending_w_q <= 1'b0;
                leading_w_q <= 1'b0;
              end
            else if (pending_w_upd_en)
              begin
                pending_w_q <= pending_w_nxt;
                leading_w_q <= leading_w_nxt;
              end
          end

        assign write_quiescent_nxt = (
                                      count_aw_to_wend_ez_q  & ~awvalid_i &
                                      ~wvalid_i &
                                      ~leading_w_nxt & ~pending_w_nxt
                                     );

        // For count limited stalling, the AW for a transaction that has no W
        // (Barriers and Evict) will increment the W(first)->WACK counter as well as a
        // true W(first). As there could be sticky valid on both AW and W, the
        // W(first)->WACK counter must cause both to start to stall when it reaches
        // MAX-1. That will allow the channel that *didn't* manage to stall 
        // because it was sticky to handshake without the counter exceeding the
        // maximum value.
        //
        // In addition, it must always be possible to have an AW start when none
        // are outstanding and the maximum number of leading W have occurred, so
        // the W channel must stall one count earlier than the AW channel because
        // of the W(first)->WACK counter. Therefore W must stall when it reaches 
        // MAX-2

        // Stall AW when either the counter could overflow or quiescence is
        // requested and the channel is not sticky
        assign stall_aw_n_nxt = (
                                 (awvalid_i & ~awready_i) |          // Sticky valid
                                 (
                                  (~count_aw_to_wend_gemm1_q) &      // Not the max count
                                  (force_read_write_quiescence_n_i | // Not trying to force quiescence
                                   leading_w_nxt)                    // There is leading W
                                 )
                                );

        // Stall W when either the counter could overflow or quiescence is
        // requested and the channel is not sticky
        assign stall_w_n_nxt  = (
                                 (wvalid_i & ~wready_i) |            // Sticky valid
                                 (
                                  (~count_aw_to_wlast_lemp1_q) &     // Not the min count
                                  (force_read_write_quiescence_n_i | // Not trying to force quiescence
                                   pending_w_nxt)                    // There will be AW without W
                                 )
                                );

      end
    else
      begin : g_aw_vn_present

        // To forcibly quiesce write QVN:
        //
        // - For each VN, fence VW unless there are no outstanding tokens and
        //   pending W
        //      NOTE: this could cause temporary quiescence until an AW uses
        //            up a granted token and causes pending W again
        // - For each VN, fence VAW unless there are no outstanding tokens and
        //   either leading W or some W tokens outstanding while there is no
        //   pending W .... OR when AW is fenced and a prealloc needs to be granted
        //
        // No need to fence W until all VAW and VW are quiescent because without
        // a credit there will be no W and no credits outstanding upstream is
        // required for VAW and VW quiescence.
        //
        // Fence AW when no VN has:
        // - leading W
        // - W credits outstanding AND no pending W
        // - outstanding tokens upstream (except maybe prealloc)
        //
        // To avoid having to sample the prealloc value, init the counter to 1 and
        // if there is no prealloc it will never go down to 0, but if there is prealloc it can.

        reg  [VAW_OT_WIDTH-1:0] count_vaw_to_aw_q      [AW_VN-1:0];
        wire [VAW_OT_WIDTH-1:0] count_vaw_to_aw_p1     [AW_VN-1:0];
        wire [VAW_OT_WIDTH-1:0] count_vaw_to_aw_m1     [AW_VN-1:0];
        reg  [VAW_OT_WIDTH-1:0] count_vaw_to_aw_nxt    [AW_VN-1:0];
        wire [AW_VN-1:0]        count_vaw_to_aw_inc;
        wire [AW_VN-1:0]        count_vaw_to_aw_dec;
        wire [AW_VN-1:0]        count_vaw_to_aw_upd_en;
        reg  [AW_VN-1:0]        count_vaw_to_aw_ez_q;
        wire [AW_VN-1:0]        count_vaw_to_aw_ez_nxt;
        reg  [AW_VN-1:0]        count_vaw_to_aw_eo_q;
        wire [AW_VN-1:0]        count_vaw_to_aw_eo_nxt;

        reg  [VW_OT_WIDTH-1:0] count_vw_to_w_q      [AW_VN-1:0];
        wire [VW_OT_WIDTH-1:0] count_vw_to_w_p1     [AW_VN-1:0];
        wire [VW_OT_WIDTH-1:0] count_vw_to_w_m1     [AW_VN-1:0];
        reg  [VW_OT_WIDTH-1:0] count_vw_to_w_nxt    [AW_VN-1:0];
        wire [AW_VN-1:0]       count_vw_to_w_inc;
        wire [AW_VN-1:0]       count_vw_to_w_dec;
        wire [AW_VN-1:0]       count_vw_to_w_upd_en;
        reg  [AW_VN-1:0]       count_vw_to_w_ez_q;
        wire [AW_VN-1:0]       count_vw_to_w_ez_nxt;


        // Can determine leading/pending W by counting AW versus WLAST
        // and recording whether last W was a WLAST:
        // more AW than WLAST -> pending W
        // same WLAST as AW and most recent W was WLAST -> no pending or leading W
        // otherwise -> leading W

        // Increase count widths by 1 so we can use as signed
        // NOTE: do not need overflow or underflow prevention because the
        //       channel-level prevention will do that implicitly as part
        //       of the AW->B/WACK and W->B/WACK overflow prevention.
        reg  [WL_OT_WIDTH-1:0] count_aw_to_wlast_q      [AW_VN-1:0];
        wire [WL_OT_WIDTH-1:0] count_aw_to_wlast_p1     [AW_VN-1:0];
        wire [WL_OT_WIDTH-1:0] count_aw_to_wlast_m1     [AW_VN-1:0];
        wire [AW_VN-1:0]       count_aw_to_wlast_ep1;
        wire [AW_VN-1:0]       count_aw_to_wlast_em1;
        wire [AW_VN-1:0]       count_aw_to_wlast_emptp1;
        wire [AW_VN-1:0]       count_aw_to_wlast_emptp2;
        reg  [WL_OT_WIDTH-1:0] count_aw_to_wlast_nxt    [AW_VN-1:0];
        wire [AW_VN-1:0]       count_aw_to_wlast_inc;
        wire [AW_VN-1:0]       count_aw_to_wlast_dec;
        wire [AW_VN-1:0]       count_aw_to_wlast_upd_en;
        reg  [AW_VN-1:0]       count_aw_to_wlast_ez_q;
        reg  [AW_VN-1:0]       count_aw_to_wlast_ez_nxt;
        reg  [AW_VN-1:0]       count_aw_to_wlast_lz_q;
        reg  [AW_VN-1:0]       count_aw_to_wlast_lz_nxt;
        reg  [AW_VN-1:0]       count_aw_to_wlast_gz_q;
        reg  [AW_VN-1:0]       count_aw_to_wlast_gz_nxt;
        reg  [AW_VN-1:0]       count_aw_to_wlast_lemptp1_q;
        reg  [AW_VN-1:0]       count_aw_to_wlast_lemptp1_nxt;

        reg  [AW_VN-1:0]       w_first_q;
        wire [AW_VN-1:0]       w_first_nxt;
        wire [AW_VN-1:0]       w_first_upd_en;

        reg  [AW_VN-1:0]       pending_w_q;
        reg  [AW_VN-1:0]       pending_w_nxt;
        wire [AW_VN-1:0]       pending_w_upd_en;

        reg  [AW_VN-1:0]       leading_w_q;
        reg  [AW_VN-1:0]       leading_w_nxt;

        reg  [AW_VN-1:0]       stall_vaw_n_q;
        wire [AW_VN-1:0]       stall_vaw_n_nxt;
        wire [AW_VN-1:0]       stall_vaw_n_upd_en;
        reg  [AW_VN-1:0]       stall_vw_n_q;
        wire [AW_VN-1:0]       stall_vw_n_nxt;
        wire [AW_VN-1:0]       stall_vw_n_upd_en;

        wire forced_quiescence_stall_aw_n_nxt;

        for (i=0 ; i<AW_VN ; i=i+1)
          begin : g_i

            // Count VAW to AW outstanding credits
            wire count_vaw_to_aw_ovrflw;

// ACS_off start UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1 to guide synthesis to an incrementer/decrementer
            assign {count_vaw_to_aw_ovrflw,count_vaw_to_aw_p1[i]} = count_vaw_to_aw_q[i] + 1'b1;
            assign                         count_vaw_to_aw_m1[i]  = count_vaw_to_aw_q[i] - 1'b1;
// ACS_off end UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING
        
            assign count_vaw_to_aw_inc[i] = (vawvalid_i[i] & vawready_i[i]);
            assign count_vaw_to_aw_dec[i] = (awvalid_i & awready_i &               // There is a handshake
                                             ~awbar_i &                            // that uses a token
                                             awvnpid_i[i]);                        // and is for this VN

            always @*
              begin : p_count_vaw_to_aw_nxt
                case ({count_vaw_to_aw_inc[i],count_vaw_to_aw_dec[i]})
                  2'b00,
                  2'b11:
                    count_vaw_to_aw_nxt[i] = count_vaw_to_aw_q[i];
                  2'b01:
                    count_vaw_to_aw_nxt[i] = count_vaw_to_aw_m1[i];
                  2'b10:
                    count_vaw_to_aw_nxt[i] = count_vaw_to_aw_p1[i];
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
                  default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                    count_vaw_to_aw_nxt[i] = VAW_OT_X;
                endcase
              end
        
            assign count_vaw_to_aw_ez_nxt[i]    = (VAW_OT_ZERO   == count_vaw_to_aw_nxt[i]);
            assign count_vaw_to_aw_eo_nxt[i]    = (VAW_OT_ONE    == count_vaw_to_aw_nxt[i]);
        
            assign count_vaw_to_aw_upd_en[i] = (count_vaw_to_aw_inc[i] | count_vaw_to_aw_dec[i]);
        
            always @(posedge aclk or negedge aresetn)
              begin : p_count_vaw_to_aw_q
                if (! aresetn)
                  begin
                    count_vaw_to_aw_q[i]       <= VAW_OT_ONE;
                    count_vaw_to_aw_ez_q[i]    <= 1'b0;
                    count_vaw_to_aw_eo_q[i]    <= 1'b1;
                  end
                else if (count_vaw_to_aw_upd_en[i])
                  begin
                    count_vaw_to_aw_q[i]       <= count_vaw_to_aw_nxt[i];
                    count_vaw_to_aw_ez_q[i]    <= count_vaw_to_aw_ez_nxt[i];
                    count_vaw_to_aw_eo_q[i]    <= count_vaw_to_aw_eo_nxt[i];
                  end
              end

            // Count VW to W outstanding credits
            wire count_vw_to_w_ovrflw;

// ACS_off start UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1 to guide synthesis to an incrementer/decrementer
            assign {count_vw_to_w_ovrflw,count_vw_to_w_p1[i]} = count_vw_to_w_q[i] + 1'b1;
            assign                       count_vw_to_w_m1[i]  = count_vw_to_w_q[i] - 1'b1;
// ACS_off end UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING
        
            assign count_vw_to_w_inc[i] = (vwvalid_i[i] & vwready_i[i]);
            assign count_vw_to_w_dec[i] = (wvalid_i & wready_i &               // There is a handshake
                                           wvnpid_i[i]);                        // and is for this VN

            always @*
              begin : p_count_vw_to_w_nxt
                case ({count_vw_to_w_inc[i],count_vw_to_w_dec[i]})
                  2'b00,
                  2'b11:
                    count_vw_to_w_nxt[i] = count_vw_to_w_q[i];
                  2'b01:
                    count_vw_to_w_nxt[i] = count_vw_to_w_m1[i];
                  2'b10:
                    count_vw_to_w_nxt[i] = count_vw_to_w_p1[i];
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
                  default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                    count_vw_to_w_nxt[i] = VW_OT_X;
                endcase
              end
        
            assign count_vw_to_w_ez_nxt[i] = (VW_OT_ZERO   == count_vw_to_w_nxt[i]);
        
            assign count_vw_to_w_upd_en[i] = (count_vw_to_w_inc[i] | count_vw_to_w_dec[i]);
        
            always @(posedge aclk or negedge aresetn)
              begin : p_count_vw_to_w_q
                if (! aresetn)
                  begin
                    count_vw_to_w_q[i]       <= VW_OT_ZERO;
                    count_vw_to_w_ez_q[i]    <= 1'b1;
                  end
                else if (count_vw_to_w_upd_en[i])
                  begin
                    count_vw_to_w_q[i]       <= count_vw_to_w_nxt[i];
                    count_vw_to_w_ez_q[i]    <= count_vw_to_w_ez_nxt[i];
                  end
              end

            // Count AW to WLAST outstanding activity

            //   NOTE: is signed as there can be leading W

            wire count_aw_to_wlast_ovrflw;

// ACS_off start UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1 to guide synthesis to an incrementer/decrementer
            assign {count_aw_to_wlast_ovrflw,count_aw_to_wlast_p1[i]} = count_aw_to_wlast_q[i] + 1'b1;
            assign                           count_aw_to_wlast_m1[i]  = count_aw_to_wlast_q[i] - 1'b1;
// ACS_off end UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING
            assign count_aw_to_wlast_ep1[i]  = (WL_OT_ONE    == count_aw_to_wlast_q[i]);
            assign count_aw_to_wlast_em1[i]  = (WL_OT_M1     == count_aw_to_wlast_q[i]);
            assign count_aw_to_wlast_emptp2[i] = (WL_OT_MIN_PTP2 == count_aw_to_wlast_q[i]);
            assign count_aw_to_wlast_emptp1[i] = (WL_OT_MIN_PTP1 == count_aw_to_wlast_q[i]);
        
            assign count_aw_to_wlast_inc[i] = (awvalid_i & awready_i & ~aw_is_dataless & awvnpid_i[i]);
            assign count_aw_to_wlast_dec[i] = (wvalid_i  & wready_i  &  wlast_i        & wvnpid_i[i]);

            always @*
              begin : p_count_aw_to_wlast_nxt
                case ({count_aw_to_wlast_inc[i],count_aw_to_wlast_dec[i]})
                  2'b00,
                  2'b11:
                    begin
                      count_aw_to_wlast_nxt[i]       = count_aw_to_wlast_q[i];
                      count_aw_to_wlast_ez_nxt[i]    = count_aw_to_wlast_ez_q[i];
                      count_aw_to_wlast_gz_nxt[i]    = count_aw_to_wlast_gz_q[i];
                      count_aw_to_wlast_lz_nxt[i]    = count_aw_to_wlast_lz_q[i];
                      count_aw_to_wlast_lemptp1_nxt[i] = count_aw_to_wlast_lemptp1_q[i];
                    end
                  2'b01:
                    begin
                      count_aw_to_wlast_nxt[i]       = count_aw_to_wlast_m1[i];
                      count_aw_to_wlast_ez_nxt[i]    = count_aw_to_wlast_ep1[i];
                      count_aw_to_wlast_gz_nxt[i]    = ~(count_aw_to_wlast_ep1[i] | count_aw_to_wlast_ez_q[i] | count_aw_to_wlast_lz_q[i]);
                      count_aw_to_wlast_lz_nxt[i]    = (count_aw_to_wlast_ez_q[i] | count_aw_to_wlast_lz_q[i]);
                      count_aw_to_wlast_lemptp1_nxt[i] = (count_aw_to_wlast_lemptp1_q[i] | count_aw_to_wlast_emptp2[i]);
                    end
                  2'b10:
                    begin
                      count_aw_to_wlast_nxt[i]       = count_aw_to_wlast_p1[i];
                      count_aw_to_wlast_ez_nxt[i]    = count_aw_to_wlast_em1[i];
                      count_aw_to_wlast_gz_nxt[i]    = (count_aw_to_wlast_gz_q[i] | count_aw_to_wlast_ez_q[i]);
                      count_aw_to_wlast_lz_nxt[i]    = ~(count_aw_to_wlast_gz_q[i] | count_aw_to_wlast_ez_q[i] | count_aw_to_wlast_em1[i]);
                      count_aw_to_wlast_lemptp1_nxt[i] = (count_aw_to_wlast_lemptp1_q[i] & ~count_aw_to_wlast_emptp1[i]);
                    end
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
                  default:
// ACS_off start UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                    begin
                      count_aw_to_wlast_nxt[i]       = WL_OT_X;
                      count_aw_to_wlast_ez_nxt[i]    = 1'bx;
                      count_aw_to_wlast_gz_nxt[i]    = 1'bx;
                      count_aw_to_wlast_lz_nxt[i]    = 1'bx;
                      count_aw_to_wlast_lemptp1_nxt[i] = 1'bx;
                    end
// ACS_off end UNREACHABLE_DEFAULT_STATEMENT
                endcase
              end
        
            assign count_aw_to_wlast_upd_en[i] = (count_aw_to_wlast_inc[i] | count_aw_to_wlast_dec[i]);
        
            always @(posedge aclk or negedge aresetn)
              begin : p_count_aw_to_wlast_q
                if (! aresetn)
                  begin
                    count_aw_to_wlast_q[i]       <= WL_OT_ZERO;
                    count_aw_to_wlast_ez_q[i]    <= 1'b1;
                    count_aw_to_wlast_lz_q[i]    <= 1'b0;
                    count_aw_to_wlast_gz_q[i]    <= 1'b0;
                    count_aw_to_wlast_lemptp1_q[i] <= 1'b0;
                  end
                else if (count_aw_to_wlast_upd_en[i])
                  begin
                    count_aw_to_wlast_q[i]       <= count_aw_to_wlast_nxt[i];
                    count_aw_to_wlast_ez_q[i]    <= count_aw_to_wlast_ez_nxt[i];
                    count_aw_to_wlast_lz_q[i]    <= count_aw_to_wlast_lz_nxt[i];
                    count_aw_to_wlast_gz_q[i]    <= count_aw_to_wlast_gz_nxt[i];
                    count_aw_to_wlast_lemptp1_q[i] <= count_aw_to_wlast_lemptp1_nxt[i];
                 end
              end

            assign w_first_nxt[i] = wlast_i;
            assign w_first_upd_en[i] = (wvalid_i & wready_i & wvnpid_i[i]);

            always @(posedge aclk or negedge aresetn)
              begin : p_w_first_q
                if (! aresetn)
                  w_first_q[i] <= 1'b1;
                else if (w_first_upd_en[i])
                  w_first_q[i] <= w_first_nxt[i];
              end

            // There will be pending W next cycle if:
            // - there is a non-last W this cycle: there must be a W to follow it (wvalid_i & wready_i & ~wlast_i)
            // - there is a dataful-AW handshake (count_aw_to_wlast_inc)
            // - there is more than one pending WLAST this cycle (count_aw_to_wlast_gz_q & ~count_aw_to_wlast_ep1)
            // - there is exactly one pending WLAST and no W handshake (count_aw_to_wlast_ep1 & ~(wvalid_i & wready_i))
            assign pending_w_upd_en[i] = (count_aw_to_wlast_inc[i] | w_first_upd_en[i]);
            
            always @*
              begin : p_pending_leading_w_nxt
                case ({count_aw_to_wlast_inc[i],count_aw_to_wlast_dec[i]})
                  2'b00:
                    begin
                      // non-last-W sets pending W
                      pending_w_nxt[i]            = (pending_w_q[i] |
                                                     (w_first_upd_en[i] & ~w_first_nxt[i]));
                      // Any W will set if aw_to_wlast<=0
                      leading_w_nxt[i]            = (leading_w_q[i] |
                                                     (w_first_upd_en[i] & ~count_aw_to_wlast_gz_q[i]));
                    end
                  2'b01:
                    begin
                      // WLAST clears it if the count >1 
                      pending_w_nxt[i]            = (count_aw_to_wlast_gz_q[i] &
                                                     ~count_aw_to_wlast_ep1[i]);
                      // If aw_to_wlast<=0 then *any* W will be leading
                      leading_w_nxt[i]            = ~count_aw_to_wlast_gz_q[i];
                    end
                  2'b11:
                    begin
                      // Clears if the WLAST must be behind the AW
                      pending_w_nxt[i]            = count_aw_to_wlast_gz_q[i];
                      // If the WLAST must be ahead of the AW
                      leading_w_nxt[i]            = count_aw_to_wlast_lz_q[i];
                    end
                  2'b10:
                    begin
                      // Set if the AW is not completely clearing a backlog 
                      pending_w_nxt[i]            = (~count_aw_to_wlast_lz_q[i] |
                                                     (~w_first_q[i] | w_first_upd_en[i]));
                      // An AW from aw_to_wlast>=0 clears, and from ==-1 clears if w_first and no W at all
                      leading_w_nxt[i]            = ~(~count_aw_to_wlast_lz_q[i] |
                                                      (count_aw_to_wlast_em1[i] & (w_first_q[i] & ~w_first_upd_en[i])));
                    end
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
                  default:
// ACS_off start UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                    begin
                      pending_w_nxt[i]            = 1'bx;
                      leading_w_nxt[i]            = 1'bx;
                    end
// ACS_off end UNREACHABLE_DEFAULT_STATEMENT
                endcase
              end
            
            always@(posedge aclk or negedge aresetn)
              begin : p_pending_leading_w_q
                if (! aresetn)
                  begin
                    pending_w_q[i] <= 1'b0;
                    leading_w_q[i] <= 1'b0;
                  end
                else if (pending_w_upd_en[i])
                  begin
                    pending_w_q[i] <= pending_w_nxt[i];
                    leading_w_q[i] <= leading_w_nxt[i];
                  end
              end

            // Allow VW grant while there is pending W and 0 outstanding VW
            // Allow VAW grant while there is leading W and 0 or 1 outstanding VAW
            //
            // When no pending data, no leading data, AW->WALST OT==0 (implicit in no leading or pending W),
            // 0 outstanding VW and 0 or 1 outstanding VAW, stall AW.
            //
            // Also allow VAW grant when all VNs have completely quiesced and AW is stalled

            // NOTE: have to include count_vaw_to_aw_eo_q here because it is unknown whether
            //       there is a prealloc or not. If it *is* prealloc then an extra AW *could*
            //       be let through, but the W will follow it and none will be let through once 
            //       the W must be behind the AW.
            assign stall_vaw_n_nxt[i] = (force_read_write_quiescence_n_i |  // not trying to quiesce OR
                                         (vawvalid_i[i] & ~vawready_i[i]) | // the request is sticky OR
                                         ((count_vaw_to_aw_ez_nxt[i] |      // ((credit_counter == 0 OR
                                           count_vaw_to_aw_eo_nxt[i]) &     //   credit_counter == 1) AND
                                          leading_w_nxt[i]) |               //  leading W) OR
                                         (count_vaw_to_aw_ez_nxt[i] &       // (credit_counter == 0 AND
                                          ~stall_aw_n_o &                   //  channel fence is active AND
                                          ~forced_quiescence_stall_aw_n_nxt & // forced quiescence has been achieved AND
                                          ~count_aw_to_wend_gemm1_q)        // it doesn't coincide with capacity stalling
                                        );

            assign stall_vw_n_nxt[i] = ((vwvalid_i[i] & ~vwready_i[i]) |      // the request is not sticky OR
                                        (~count_aw_to_wlast_lemptp1_q[i] &    // Not the min count AND
                                         (force_read_write_quiescence_n_i |   // not trying to quiesce OR
                                          (count_vw_to_w_ez_nxt[i] &          // credit_counter == 0 AND
                                           pending_w_nxt[i])                  // pending W
                                         )
                                        )
                                       );

            assign stall_vaw_n_upd_en[i] = 1'b1;
    
            always @(posedge aclk or negedge aresetn)
              begin : p_stall_vaw_n_q
                if (! aresetn)
                  stall_vaw_n_q[i] <= 1'b0;
                else if (stall_vaw_n_upd_en[i])
                  stall_vaw_n_q[i] <= stall_vaw_n_nxt[i];
              end
    
            assign stall_vaw_n_o[i] = stall_vaw_n_q[i];
    
            assign           stall_vw_n_upd_en[i] = 1'b1;
    
            always @(posedge aclk or negedge aresetn)
              begin : p_stall_vw_n_q
                if (! aresetn)
                  stall_vw_n_q[i] <= 1'b0;
                else if (stall_vw_n_upd_en[i])
                  stall_vw_n_q[i] <= stall_vw_n_nxt[i];
              end
    
            assign stall_vw_n_o[i] = stall_vw_n_q[i];


          end

        // Stall AW when either the counter could overflow or quiescence is
        // requested and the channel is not sticky.
        //
        // Only allow the AW channel to be fenced when there is no VN with
        // leading W, AW credits outstanding in excess of prealloc or W
        // credits outstanding but no pending W (it requires an AW to accompany
        // the W that must occur to use up the W credit)

        assign forced_quiescence_stall_aw_n_nxt =
                 (
                  force_read_write_quiescence_n_i |   // Not trying to force quiescence
                  (|(leading_w_nxt)) |                // There is leading W - will need an AW to match up.
                  (|(pending_w_nxt)) |                // There is pending W
                  (|(~(count_vaw_to_aw_eo_nxt |
                       count_vaw_to_aw_ez_nxt))) |    // Outstanding AW credits
                  (|(~count_vw_to_w_ez_nxt &          // Outstanding W credits ...
                     ~pending_w_nxt))               // ... and no pending W - will need an AW to use them up
                 );

        assign stall_aw_n_nxt = (
                                 (awvalid_i & ~awready_i) |            // Sticky valid
                                 (
                                  (~count_aw_to_wend_gemm1_q) &        // Not the max count
                                  forced_quiescence_stall_aw_n_nxt     // Not achieved forced quiescence stalling
                                 )
                                );

        // Stall W when quiescence is
        // requested and the channel is not sticky
        assign stall_w_n_nxt  = (
                                 (wvalid_i & ~wready_i) |            // Sticky valid
                                 (
                                  (force_read_write_quiescence_n_i | // Not trying to force quiescence
                                   (|(pending_w_nxt)) |              // There will be AW without W
                                   (|(~count_vw_to_w_ez_q)))         // Tokens upstream that need to be used
                                 )
                                );


        assign write_quiescent_nxt = (
                                      count_aw_to_wend_ez_q & ~awvalid_i & // No unfinished transactions
                                      ~wvalid_i &
                                      (&(~pending_w_nxt)) &                // No pending W
                                      (&(~leading_w_nxt)) &                // No leading W
                                      (&(count_vaw_to_aw_eo_q)) &          // All credits are where they should be
                                      (&(count_vw_to_w_ez_q)) &            // All credits are where they should be
                                      ~(|(vawvalid_i)) &                   // And will be staying there
                                      ~(|(vwvalid_i))                      // And will be staying there
                                     );

      end

  endgenerate

  // Stall the AW channel
  reg  stall_aw_n_q;
  // Whenever a transaction could be starting or ending, or the quiescence is requested
  wire stall_aw_n_upd_en = 1'b1;
  always @(posedge aclk or negedge aresetn)
    begin : p_stall_aw_n_q
      if (! aresetn)
        stall_aw_n_q <= 1'b0;
      else if (stall_aw_n_upd_en)
        stall_aw_n_q <= stall_aw_n_nxt;
    end

  assign stall_aw_n_o = stall_aw_n_q;

  // Stall the W channel
  reg  stall_w_n_q;
  // Whenever a transaction could be starting or ending, or the quiescence is requested
  wire stall_w_n_upd_en = 1'b1;
  always @(posedge aclk or negedge aresetn)
    begin : p_stall_w_n_q
      if (! aresetn)
        stall_w_n_q <= 1'b0;
      else if (stall_w_n_upd_en)
        stall_w_n_q <= stall_w_n_nxt;
    end

  assign stall_w_n_o = stall_w_n_q;

  // Do not allow a B until there is at least some AW.
  assign stall_b_n_o = ~count_aw_to_wend_ez_q;

  // -----------------------------------------------------------------
  //  READ/WRITE quiescence
  // -----------------------------------------------------------------
  // All combinations have read and write quiescence
  reg  read_write_quiescent_q;
  wire read_write_quiescent_nxt = (
                                   read_quiescent_nxt &
                                   write_quiescent_nxt
                                  );

  wire read_write_quiescent_upd_en = 1'b1;

  always @(posedge aclk or negedge aresetn)
    begin : p_read_write_quiescent
      if (! aresetn)
        read_write_quiescent_q <= 1'b1;
      else if (read_write_quiescent_upd_en)
        read_write_quiescent_q <= read_write_quiescent_nxt;
    end

  assign read_write_quiescent_o = read_write_quiescent_q;

  reg  read_write_quiescent_and_stalled_q;
  wire read_write_quiescent_and_stalled_nxt = (
                                               ~force_read_write_quiescence_n_i &
                                               read_write_quiescent_nxt
                                              );

  always @(posedge aclk or negedge aresetn)
    begin : p_read_write_quiescent_and_stalled
      if (! aresetn)
        read_write_quiescent_and_stalled_q <= 1'b1;
      else if (read_write_quiescent_upd_en)
        read_write_quiescent_and_stalled_q <= read_write_quiescent_and_stalled_nxt;
    end

  assign read_write_quiescent_and_stalled_o = read_write_quiescent_and_stalled_q;


  // -----------------------------------------------------------------
  //  SNOOP
  // -----------------------------------------------------------------
  generate
    if (PROTOCOL_CHANNELS < 7)
      begin : g_no_snoop

        // Make explicit that things are unused
        wire acvalid_i_unused = acvalid_i;
        wire acready_i_unused = acready_i;
        wire crvalid_i_unused = crvalid_i;
        wire crready_i_unused = crready_i;
        wire cr_pass_data_i_unused = cr_pass_data_i;
        wire cdvalid_i_unused = cdvalid_i;
        wire cdready_i_unused = cdready_i;
        wire cdlast_i_unused  = cdlast_i;
        wire force_snoop_quiescence_n_i_unused = force_snoop_quiescence_n_i;

        assign snoop_quiescent_o = 1'b1;
        assign snoop_quiescent_and_stalled_o = 1'b1;
        assign dvm_sync_complete_quiescent_o = 1'b1;
        assign stall_ac_n_o = 1'b1;
      end
    else
      begin : g_has_snoop

        // AC->CR counter

        // When to increment and decrement the counter
        wire                   count_ac_to_cr_inc = (acvalid_i & acready_i);
        wire                   count_ac_to_cr_dec = (crvalid_i & crready_i);

        reg  [SN_OT_WIDTH-1:0] count_ac_to_cr_q;
        wire                   count_ac_to_cr_ovrflw;
        wire [SN_OT_WIDTH-1:0] count_ac_to_cr_p1;
        wire [SN_OT_WIDTH-1:0] count_ac_to_cr_m1;
        reg  [SN_OT_WIDTH-1:0] count_ac_to_cr_nxt;
        wire                   count_ac_to_cr_upd_en;
        reg                    count_ac_to_cr_ez_q;
        wire                   count_ac_to_cr_ez_nxt;
        reg                    count_ac_to_cr_gemm1_q;
        wire                   count_ac_to_cr_gemm1_nxt;
    
// ACS_off start UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1 to guide synthesis to an incrementer/decrementer
        assign {count_ac_to_cr_ovrflw,count_ac_to_cr_p1} = count_ac_to_cr_q + 1'b1;
        assign                        count_ac_to_cr_m1  = count_ac_to_cr_q - 1'b1;
// ACS_off end UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING
    
        always @*
          begin : p_count_ac_to_cr_nxt
            case ({count_ac_to_cr_inc,count_ac_to_cr_dec})
              2'b00,
              2'b11:
                count_ac_to_cr_nxt = count_ac_to_cr_q;
              2'b01:
                count_ac_to_cr_nxt = count_ac_to_cr_m1;
              2'b10:
                count_ac_to_cr_nxt = count_ac_to_cr_p1;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
              default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                count_ac_to_cr_nxt = SN_OT_X;
            endcase
          end
    
        assign count_ac_to_cr_ez_nxt    = (SN_OT_ZERO   == count_ac_to_cr_nxt);
        assign count_ac_to_cr_gemm1_nxt = (SN_OT_MAX_M1 <= count_ac_to_cr_nxt);

        assign count_ac_to_cr_upd_en = (count_ac_to_cr_inc | count_ac_to_cr_dec);

        always @(posedge aclk or negedge aresetn)
          begin : p_count_ac_to_cr_q
            if (! aresetn)
              begin
                count_ac_to_cr_q       <= SN_OT_ZERO;
                count_ac_to_cr_ez_q    <= 1'b1;
                count_ac_to_cr_gemm1_q <= 1'b0;
              end
            else if (count_ac_to_cr_upd_en)
              begin
                count_ac_to_cr_q       <= count_ac_to_cr_nxt;
                count_ac_to_cr_ez_q    <= count_ac_to_cr_ez_nxt;
                count_ac_to_cr_gemm1_q <= count_ac_to_cr_gemm1_nxt;
              end
          end

        // AC->AR (for AC DVM-Sync -> AR DVM-Complete)

        // When to increment and decrement the counter
        wire                            count_ac_to_ar_inc = (acvalid_i & acready_i & ac_dvm_sync_i);
        wire                            count_ac_to_ar_dec = (arvalid_i & arready_i & ar_dvm_complete_i);

        reg  [COUNT_AC_TO_AR_WIDTH-1:0] count_ac_to_ar_q;
        wire                            count_ac_to_ar_ovrflw;
        wire [COUNT_AC_TO_AR_WIDTH-1:0] count_ac_to_ar_p1;
        wire [COUNT_AC_TO_AR_WIDTH-1:0] count_ac_to_ar_m1;
        reg  [COUNT_AC_TO_AR_WIDTH-1:0] count_ac_to_ar_nxt;
        wire                            count_ac_to_ar_upd_en;
        wire                            count_ac_to_ar_ez_nxt;

// ACS_off start UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1 to guide synthesis to an incrementer/decrementer
        assign {count_ac_to_ar_ovrflw,count_ac_to_ar_p1} = count_ac_to_ar_q + 1'b1;
        assign                        count_ac_to_ar_m1  = count_ac_to_ar_q - 1'b1;
// ACS_off end UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING
    
        always @*
          begin : p_count_ac_to_ar_nxt
            case ({count_ac_to_ar_inc,count_ac_to_ar_dec})
              2'b00,
              2'b11:
                count_ac_to_ar_nxt = count_ac_to_ar_q;
              2'b01:
                count_ac_to_ar_nxt = count_ac_to_ar_m1;
              2'b10:
                count_ac_to_ar_nxt = count_ac_to_ar_p1;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
              default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                count_ac_to_ar_nxt = COUNT_AC_TO_AR_X;
            endcase
          end
    
        assign count_ac_to_ar_ez_nxt = (COUNT_AC_TO_AR_ZERO == count_ac_to_ar_nxt);

        assign count_ac_to_ar_upd_en = (count_ac_to_ar_inc | count_ac_to_ar_dec);

        always @(posedge aclk or negedge aresetn)
          begin : p_count_ac_to_ar_q
            if (! aresetn)
              begin
                count_ac_to_ar_q    <= COUNT_AC_TO_AR_ZERO;
              end
            else if (count_ac_to_ar_upd_en)
              begin
                count_ac_to_ar_q    <= count_ac_to_ar_nxt;
              end
          end

        // AR->AC (for AR DVM-Sync -> AC DVM-Complete)

        // When to increment and decrement the counter
        wire                            count_ar_to_ac_inc = (arvalid_i & arready_i & ar_dvm_sync_i);
        wire                            count_ar_to_ac_dec = (acvalid_i & acready_i & ac_dvm_complete_i);

        reg  [COUNT_AR_TO_AC_WIDTH-1:0] count_ar_to_ac_q;
        wire                            count_ar_to_ac_ovrflw;
        wire [COUNT_AR_TO_AC_WIDTH-1:0] count_ar_to_ac_p1;
        wire [COUNT_AR_TO_AC_WIDTH-1:0] count_ar_to_ac_m1;
        reg  [COUNT_AR_TO_AC_WIDTH-1:0] count_ar_to_ac_nxt;
        wire                            count_ar_to_ac_upd_en;
        wire                            count_ar_to_ac_ez_nxt;

// ACS_off start UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1 to guide synthesis to an incrementer/decrementer
        assign {count_ar_to_ac_ovrflw,count_ar_to_ac_p1} = count_ar_to_ac_q + 1'b1;
        assign                        count_ar_to_ac_m1  = count_ar_to_ac_q - 1'b1;
// ACS_off end UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING
    
        always @*
          begin : p_count_ar_to_ac_nxt
            case ({count_ar_to_ac_inc,count_ar_to_ac_dec})
              2'b00,
              2'b11:
                count_ar_to_ac_nxt = count_ar_to_ac_q;
              2'b01:
                count_ar_to_ac_nxt = count_ar_to_ac_m1;
              2'b10:
                count_ar_to_ac_nxt = count_ar_to_ac_p1;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
              default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                count_ar_to_ac_nxt = COUNT_AR_TO_AC_X;
            endcase
          end
    
        assign count_ar_to_ac_ez_nxt = (COUNT_AR_TO_AC_ZERO == count_ar_to_ac_nxt);

        assign count_ar_to_ac_upd_en = (count_ar_to_ac_inc | count_ar_to_ac_dec);

        always @(posedge aclk or negedge aresetn)
          begin : p_count_ar_to_ac_q
            if (! aresetn)
              begin
                count_ar_to_ac_q    <= COUNT_AR_TO_AC_ZERO;
              end
            else if (count_ar_to_ac_upd_en)
              begin
                count_ar_to_ac_q    <= count_ar_to_ac_nxt;
              end
          end

        reg  dvm_sync_complete_quiescent_q;
        wire dvm_sync_complete_quiescent_nxt = (count_ar_to_ac_ez_nxt &
                                                count_ac_to_ar_ez_nxt);
        wire dvm_sync_complete_quiescent_upd_en = (count_ar_to_ac_upd_en |
                                                   count_ac_to_ar_upd_en);

        always @(posedge aclk or negedge aresetn)
          begin : p_dvm_sync_complete_quiescent
            if (! aresetn)
              dvm_sync_complete_quiescent_q <= 1'b1;
            else if (dvm_sync_complete_quiescent_upd_en)
              dvm_sync_complete_quiescent_q <= dvm_sync_complete_quiescent_nxt;
          end

        assign dvm_sync_complete_quiescent_o = dvm_sync_complete_quiescent_q;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// OVL assertions
//------------------------------------------------------------------------------
`ifdef ASSERT_ON
`ifdef ARM_ASSERT_ON
`ifdef OVL_ASSERT_ON

// ACS_off start COVERAGE_OFF Do not collect coverage data on OVLs

  `include "std_ovl_defines.h"

  wire powered = 1'b1;
  reg  has_been_reset_if_not_x;
  always @(posedge powered or negedge aresetn)
    if ((has_been_reset_if_not_x === 1'bx) & (aresetn === 1'b0))
      has_been_reset_if_not_x <= 1'b1;

  // ----------------------------------------------------------------------------------
  // OVL_ASSERT: should not have an AR DVM-Sync when there are already the maximum number of AR->AC Sync/Complete outstanding
  // ----------------------------------------------------------------------------------
  assert_never #(
    .severity_level (`OVL_ERROR),
    .property_type  (`OVL_ASSERT),
    .msg            ("There is already the maximum number of AR->AC DVM Sync/Complete transactions outstanding, so there should not be another starting (From the ACE spec C12.2)"))
  assert_no_ar_to_ac_overflow (
    .clk        (aclk),
    .reset_n    (aresetn),
    .test_expr  ((has_been_reset_if_not_x !== 1'bx) & ((MAX_AR_TO_AC_DVM_SYNC[COUNT_AR_TO_AC_WIDTH-1:0]==count_ar_to_ac_q) & arvalid_i & ar_dvm_sync_i))
  );

  // ----------------------------------------------------------------------------------
  // OVL_ASSERT: should not have an AC DVM-Sync when there are already the maximum number of AC->AR Sync/Complete outstanding
  // ----------------------------------------------------------------------------------
  assert_never #(
    .severity_level (`OVL_ERROR),
    .property_type  (`OVL_ASSERT),
    .msg            ("There is already the maximum number of AC->AR DVM Sync/Complete transactions outstanding, so there should not be another starting (From the ACE spec C12.2)"))
  assert_no_ac_to_ar_overflow (
    .clk        (aclk),
    .reset_n    (aresetn),
    .test_expr  ((has_been_reset_if_not_x !== 1'bx) & ((MAX_AC_TO_AR_DVM_SYNC[COUNT_AC_TO_AR_WIDTH-1:0]==count_ac_to_ar_q) & acvalid_i & ac_dvm_sync_i))
  );

// ACS_off end COVERAGE_OFF

`endif
`endif
`endif

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

        reg  snoop_quiescent_q;
        wire snoop_quiescent_nxt;
        wire snoop_quiescent_upd_en = 1'b1;

        always @(posedge aclk or negedge aresetn)
          begin : p_snoop_quiescent
            if (! aresetn)
              snoop_quiescent_q <= 1'b1;
            else if (snoop_quiescent_upd_en)
              snoop_quiescent_q <= snoop_quiescent_nxt;
          end

        assign snoop_quiescent_o = snoop_quiescent_q;

        reg  snoop_quiescent_and_stalled_q;
        wire snoop_quiescent_and_stalled_nxt = (
                                                ~force_snoop_quiescence_n_i &
                                                snoop_quiescent_nxt
                                               );

        always @(posedge aclk or negedge aresetn)
          begin : p_snoop_quiescent_and_stalled
            if (! aresetn)
              snoop_quiescent_and_stalled_q <= 1'b1;
            else if (snoop_quiescent_upd_en)
              snoop_quiescent_and_stalled_q <= snoop_quiescent_and_stalled_nxt;
          end
      
        assign snoop_quiescent_and_stalled_o = snoop_quiescent_and_stalled_q;

        // Stall the AC channel
        reg  stall_ac_n_q;
        // Whenever a transaction could be starting or ending, or the quiescence is requested
        wire stall_ac_n_upd_en = 1'b1;
        wire stall_ac_n_nxt;
        always @(posedge aclk or negedge aresetn)
          begin : p_stall_ac_n_q
            if (! aresetn)
              stall_ac_n_q <= 1'b0;
            else if (stall_ac_n_upd_en)
              stall_ac_n_q <= stall_ac_n_nxt;
          end

        assign stall_ac_n_o = stall_ac_n_q;

        if (PROTOCOL_CHANNELS < 10)
          begin : g_dvm_only_snoop
          
            // Make explicit that things are unused
            wire cdvalid_i_unused = cdvalid_i;
            wire cdready_i_unused = cdready_i;
            wire cdlast_i_unused  = cdlast_i;

            assign snoop_quiescent_nxt = (
                                          count_ac_to_cr_ez_q & ~acvalid_i
                                         );

            // Stall AC when either the counter could overflow or quiescence is
            // requested and the channel is not sticky
            assign stall_ac_n_nxt = (
                                     (acvalid_i & ~acready_i) |
                                     (
                                      (~count_ac_to_cr_gemm1_q) &
                                      force_snoop_quiescence_n_i
                                     )
                                    );
          
          end
        else
          begin : g_full_snoop
        
            wire                   count_ac_to_cr_or_cd_inc = (acvalid_i & acready_i);
            wire                   count_ac_to_cr_or_cd_non_pd_dec = (crvalid_i & crready_i & ~cr_pass_data_i);
            wire                   count_ac_to_cr_or_cd_pd_dec = (cdvalid_i & cdready_i & cdlast_i);
        
            // AC->CR/CD counter
            //
            // Some CRs are the last part of a snoop, some end on a CDLAST
            //
            reg  [SN_OT_WIDTH-1:0] count_ac_to_cr_or_cd_q;
            wire                   count_ac_to_cr_or_cd_ovrflw;
            wire [SN_OT_WIDTH-1:0] count_ac_to_cr_or_cd_p1;
            wire [SN_OT_WIDTH-1:0] count_ac_to_cr_or_cd_m1;
            wire [SN_OT_WIDTH-1:0] count_ac_to_cr_or_cd_m2;
            reg  [SN_OT_WIDTH-1:0] count_ac_to_cr_or_cd_nxt;
            wire                   count_ac_to_cr_or_cd_upd_en;
            reg                    count_ac_to_cr_or_cd_ez_q;
            wire                   count_ac_to_cr_or_cd_ez_nxt;
            reg                    count_ac_to_cr_or_cd_gemm1_q;
            wire                   count_ac_to_cr_or_cd_gemm1_nxt;
        
  // ACS_off start UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1/2'b10 to guide synthesis to an incrementer/decrementer
            assign {count_ac_to_cr_or_cd_ovrflw,count_ac_to_cr_or_cd_p1} = count_ac_to_cr_or_cd_q + 1'b1;
            assign                              count_ac_to_cr_or_cd_m1  = count_ac_to_cr_or_cd_q - 1'b1;
            assign                              count_ac_to_cr_or_cd_m2  = count_ac_to_cr_or_cd_q - 2'b10;
  // ACS_off end UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING
        
            always @*
              begin : p_count_ac_to_cr_or_cd_nxt
                case ({count_ac_to_cr_or_cd_inc,count_ac_to_cr_or_cd_non_pd_dec,count_ac_to_cr_or_cd_pd_dec})
                  3'b000,
                  3'b101,
                  3'b110:
                    count_ac_to_cr_or_cd_nxt = count_ac_to_cr_or_cd_q;
                  3'b001,
                  3'b010,
                  3'b111:
                    count_ac_to_cr_or_cd_nxt = count_ac_to_cr_or_cd_m1;
                  3'b011:
                    count_ac_to_cr_or_cd_nxt = count_ac_to_cr_or_cd_m2;
                  3'b100:
                    count_ac_to_cr_or_cd_nxt = count_ac_to_cr_or_cd_p1;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
                  default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                    count_ac_to_cr_or_cd_nxt = SN_OT_X;
                endcase
              end
        
            assign count_ac_to_cr_or_cd_ez_nxt    = (SN_OT_ZERO   == count_ac_to_cr_or_cd_nxt);
            assign count_ac_to_cr_or_cd_gemm1_nxt = (SN_OT_MAX_M1 <= count_ac_to_cr_or_cd_nxt);
        
            assign count_ac_to_cr_or_cd_upd_en = (
                                                  count_ac_to_cr_or_cd_inc |
                                                  count_ac_to_cr_or_cd_non_pd_dec |
                                                  count_ac_to_cr_or_cd_pd_dec
                                                 );
        
            always @(posedge aclk or negedge aresetn)
              begin : p_count_ac_to_cr_or_cd_q
                if (! aresetn)
                  begin
                    count_ac_to_cr_or_cd_q       <= SN_OT_ZERO;
                    count_ac_to_cr_or_cd_ez_q    <= 1'b1;
                    count_ac_to_cr_or_cd_gemm1_q <= 1'b0;
                  end
                else if (count_ac_to_cr_or_cd_upd_en)
                  begin
                    count_ac_to_cr_or_cd_q       <= count_ac_to_cr_or_cd_nxt;
                    count_ac_to_cr_or_cd_ez_q    <= count_ac_to_cr_or_cd_ez_nxt;
                    count_ac_to_cr_or_cd_gemm1_q <= count_ac_to_cr_or_cd_gemm1_nxt;
                  end
              end
        
            assign snoop_quiescent_nxt = (
                                          count_ac_to_cr_ez_q & ~acvalid_i &
                                          count_ac_to_cr_or_cd_ez_q & ~acvalid_i
                                         );
        
            // Stall AC when either the counter could overflow or quiescence is
            // requested and the channel is not sticky
            assign stall_ac_n_nxt = (
                                     (acvalid_i & ~acready_i) |
                                     (
                                      (~count_ac_to_cr_gemm1_q) &
                                      (~count_ac_to_cr_or_cd_gemm1_q) &
                                      force_snoop_quiescence_n_i
                                     )
                                    );
          end

      end

  endgenerate

endmodule
