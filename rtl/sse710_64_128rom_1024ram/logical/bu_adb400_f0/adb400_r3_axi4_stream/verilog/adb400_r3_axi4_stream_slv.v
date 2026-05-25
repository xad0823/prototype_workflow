//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
// (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
// Checked In :  2016-02-07 15:48:44 +0000 (Sun, 07 Feb 2016)
// Revision : 206511
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_axi4_stream_slv.v
//-----------------------------------------------------------------------------
// Purpose : Slave side of bridge with AXI4-Stream interfaces.
//-----------------------------------------------------------------------------

module adb400_r3_axi4_stream_slv
  #(parameter
      DATA_WIDTH     = 8,
      ID_WIDTH       = 1,
      DEST_WIDTH     = 1,
      USER_WIDTH     = 1,

      FIFO_DEPTH     = 6,

      SI_SYNC_LEVELS = 2,

      // If they are overridden is should only be to 0.

      // These are generally derived from DATA width.
      STRB_WIDTH     = (DATA_WIDTH/8),
      KEEP_WIDTH     = (DATA_WIDTH/8),

      // Normally present, but can be removed
      LAST_WIDTH     = 1
  )
  (
    // Configuration inputs
    input  wire                                             pwrq_permit_deny_sar_i,

    // Power state control
    input  wire                                             pwrqreqns_i,
    output wire                                             pwrqacceptns_o,
    output wire                                             pwrqdenys_o,

    //
    // Synchronous interfaces
    //

    // Global signals
    input  wire                                             aclks,
    input  wire                                             aresetns,
    input  wire                                             dftrstdisables,

    // Clock control
    input  wire                                             clkqreqns_i,
    output wire                                             clkqacceptns_o,
    output wire                                             clkqdenys_o,

    // Clock requirement
    output wire                                             clkqactives_o,

    // Power requirement
    output wire                                             pwrqactives_o,

    // Wake-up
    input  wire                                             wakeups_i,

    // Channel signalling
    input  wire                                             tvalids,
    output wire                                             treadys,
    input  wire [((DATA_WIDTH>0)?(DATA_WIDTH-1):0):0]       tdatas,
    input  wire [((STRB_WIDTH>0)?(STRB_WIDTH-1):0):0]       tstrbs,
    input  wire [((KEEP_WIDTH>0)?(KEEP_WIDTH-1):0):0]       tkeeps,
    input  wire                                             tlasts,
    input  wire [((ID_WIDTH>0)?(ID_WIDTH-1):0):0]           tids,
    input  wire [((DEST_WIDTH>0)?(DEST_WIDTH-1):0):0]       tdests,
    input  wire [((USER_WIDTH>0)?(USER_WIDTH-1):0):0]       tusers,

    // Async interfacess

    output wire                                             slvmustacceptreqn_async,
    output wire                                             slvcandenyreqn_async,
    input  wire                                             slvacceptn_async,
    input  wire                                             slvdeny_async,

    output wire                                             si_to_mi_wakeup_async,
    input  wire                                             mi_to_si_wakeup_async,

    output wire [FIFO_DEPTH-1:0]                            wr_ptr_async,
    input  wire [FIFO_DEPTH-1:0]                            rd_ptr_async,
    output wire [((payload_width_fn(
                                    LAST_WIDTH,
                                    DATA_WIDTH,
                                    STRB_WIDTH,
                                    KEEP_WIDTH,
                                    ID_WIDTH,
                                    DEST_WIDTH,
                                    USER_WIDTH
                                   )>0)?
                  ((payload_width_fn(
                                     LAST_WIDTH,
                                     DATA_WIDTH,
                                     STRB_WIDTH,
                                     KEEP_WIDTH,
                                     ID_WIDTH,
                                     DEST_WIDTH,
                                     USER_WIDTH
                                     )*FIFO_DEPTH)-1):
                  0):0]                                     payld_async
   );


  function automatic integer payload_width_fn
    (
      input integer last_width,
      input integer data_width,
      input integer strb_width,
      input integer keep_width,
      input integer id_width,
      input integer dest_width,
      input integer user_width
    );
    begin : fn_payload_width_fn
// ACS_off ARITHMETIC_OVERFLOW Some elements on RHS are integers, but no chance of overflow calculating a payload width
      payload_width_fn = 
               ((last_width>0)?1:0) +
               data_width +
               strb_width +
               keep_width +
               id_width +
               dest_width +
               user_width +
               0;
    end
  endfunction

  localparam PAYLOAD_WIDTH =
    payload_width_fn (
                      LAST_WIDTH,
                      DATA_WIDTH,
                      STRB_WIDTH,
                      KEEP_WIDTH,
                      ID_WIDTH,
                      DEST_WIDTH,
                      USER_WIDTH
                     );

  wire [((PAYLOAD_WIDTH>0)?(PAYLOAD_WIDTH-1):0):0] tpaylds;

  generate
    if (PAYLOAD_WIDTH==0)
      begin : g_no_payload
        assign tpaylds = 1'b0;
        wire tlasts_unused = tlasts;
        wire tdatas_unused = tdatas;
        wire tstrbs_unused = tstrbs;
        wire tkeeps_unused = tkeeps;
        wire tids_unused   = tids;
        wire tdests_unused = tdests;
        wire tusers_unused = tusers;
      end
    else
      begin : g_has_payload
        if (LAST_WIDTH>0)
          begin : g_has_last
            assign tpaylds[
                           DATA_WIDTH +
                           STRB_WIDTH +
                           KEEP_WIDTH +
                           ID_WIDTH +
                           DEST_WIDTH +
                           USER_WIDTH +
                           0 +: 1] = tlasts;
          end
    
        if (DATA_WIDTH>0)
          begin : g_has_data
            assign tpaylds[
                           STRB_WIDTH +
                           KEEP_WIDTH +
                           ID_WIDTH +
                           DEST_WIDTH +
                           USER_WIDTH +
                           0 +: DATA_WIDTH] = tdatas;
          end
    
        if (STRB_WIDTH>0)
          begin : g_has_strb
            assign tpaylds[
                           KEEP_WIDTH +
                           ID_WIDTH +
                           DEST_WIDTH +
                           USER_WIDTH +
                           0 +: STRB_WIDTH] = tstrbs;
          end
    
        if (KEEP_WIDTH>0)
          begin : g_has_keep
            assign tpaylds[
                           ID_WIDTH +
                           DEST_WIDTH +
                           USER_WIDTH +
                           0 +: KEEP_WIDTH] = tkeeps;
          end
    
        if (ID_WIDTH>0)
          begin : g_has_id
            assign tpaylds[
                           DEST_WIDTH +
                           USER_WIDTH +
                           0 +: ID_WIDTH] = tids;
          end
    
        if (DEST_WIDTH>0)
          begin : g_has_dest
            assign tpaylds[
                           USER_WIDTH +
                           0 +: DEST_WIDTH] = tdests;
          end
    
        if (USER_WIDTH>0)
          begin : g_has_user
            assign tpaylds[
                           0 +: USER_WIDTH] = tusers;
          end
      end

  endgenerate

  adb400_r3_slv_transport_f1
    #(
      .FIFO_DEPTH       (FIFO_DEPTH),
      .SYNC_LEVELS      (SI_SYNC_LEVELS),
      .PAYLOAD_WIDTH    (PAYLOAD_WIDTH)
    )
  u_slv
    (
      .pwrq_permit_deny_sar_i  (pwrq_permit_deny_sar_i),

      .pwrqreqn_i              (pwrqreqns_i),
      .pwrqacceptn_o           (pwrqacceptns_o),
      .pwrqdeny_o              (pwrqdenys_o),

      .aclk                    (aclks),
      .aresetn                 (aresetns),

      .dftrstdisable           (dftrstdisables),

      .clkqreqn_i              (clkqreqns_i),
      .clkqacceptn_o           (clkqacceptns_o),
      .clkqdeny_o              (clkqdenys_o),
      .clkqactive_o            (clkqactives_o),
      .pwrqactive_o            (pwrqactives_o),
      .wakeup_i                (wakeups_i),

      .valid                   (tvalids),
      .ready                   (treadys),
      .payld                   (tpaylds),

      .slvmustacceptreqn_async (slvmustacceptreqn_async),
      .slvcandenyreqn_async    (slvcandenyreqn_async),
      .slvacceptn_async        (slvacceptn_async),
      .slvdeny_async           (slvdeny_async),

      .si_to_mi_wakeup_async   (si_to_mi_wakeup_async),
      .mi_to_si_wakeup_async   (mi_to_si_wakeup_async),

      .wr_ptr_async            (wr_ptr_async),
      .rd_ptr_async            (rd_ptr_async),
      .payld_async             (payld_async)
    );

endmodule

