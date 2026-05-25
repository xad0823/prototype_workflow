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
// File: adb400_r3_bas_slv.v
//-----------------------------------------------------------------------------
// Purpose : Slave side of bridge with bi-directional AXI4-Stream interfaces.
//-----------------------------------------------------------------------------

module adb400_r3_bas_slv
  #(parameter
      FW_DATA_WIDTH     = 8,
      FW_ID_WIDTH       = 1,
      FW_DEST_WIDTH     = 1,
      FW_USER_WIDTH     = 1,

      RV_DATA_WIDTH     = FW_DATA_WIDTH,
      RV_ID_WIDTH       = FW_ID_WIDTH,
      RV_DEST_WIDTH     = FW_DEST_WIDTH,
      RV_USER_WIDTH     = FW_USER_WIDTH,

      FW_FIFO_DEPTH     = 6,
      RV_FIFO_DEPTH     = 6,
      RV_OPREG          = 1,

      SI_SYNC_LEVELS    = 2,

      // If they are overridden is should only be to 0.

      // These are generally derived from DATA width.
      FW_STRB_WIDTH     = (FW_DATA_WIDTH/8),
      FW_KEEP_WIDTH     = (FW_DATA_WIDTH/8),
      RV_STRB_WIDTH     = (RV_DATA_WIDTH/8),
      RV_KEEP_WIDTH     = (RV_DATA_WIDTH/8),

      // Normally present, but can be removed
      FW_LAST_WIDTH     = 1,
      RV_LAST_WIDTH     = 1
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
    output wire                                             wakeups_o,

    // FW channel signalling
    input  wire                                             tfwvalids,
    output wire                                             tfwreadys,
    input  wire [((FW_DATA_WIDTH>0)?(FW_DATA_WIDTH-1):0):0] tfwdatas,
    input  wire [((FW_STRB_WIDTH>0)?(FW_STRB_WIDTH-1):0):0] tfwstrbs,
    input  wire [((FW_KEEP_WIDTH>0)?(FW_KEEP_WIDTH-1):0):0] tfwkeeps,
    input  wire                                             tfwlasts,
    input  wire [((FW_ID_WIDTH>0)?(FW_ID_WIDTH-1):0):0]     tfwids,
    input  wire [((FW_DEST_WIDTH>0)?(FW_DEST_WIDTH-1):0):0] tfwdests,
    input  wire [((FW_USER_WIDTH>0)?(FW_USER_WIDTH-1):0):0] tfwusers,

    // RV channel signalling
    output wire                                             trvvalids,
    input  wire                                             trvreadys,
    output wire [((RV_DATA_WIDTH>0)?(RV_DATA_WIDTH-1):0):0] trvdatas,
    output wire [((RV_STRB_WIDTH>0)?(RV_STRB_WIDTH-1):0):0] trvstrbs,
    output wire [((RV_KEEP_WIDTH>0)?(RV_KEEP_WIDTH-1):0):0] trvkeeps,
    output wire                                             trvlasts,
    output wire [((RV_ID_WIDTH>0)?(RV_ID_WIDTH-1):0):0]     trvids,
    output wire [((RV_DEST_WIDTH>0)?(RV_DEST_WIDTH-1):0):0] trvdests,
    output wire [((RV_USER_WIDTH>0)?(RV_USER_WIDTH-1):0):0] trvusers,

    // Async interfaces 

    output wire                                             slvmustacceptreqn_async,
    output wire                                             slvcandenyreqn_async,
    input  wire                                             slvacceptn_async,
    input  wire                                             slvdeny_async,

    output wire                                             si_to_mi_wakeup_async,
    input  wire                                             mi_to_si_wakeup_async,

    output wire [FW_FIFO_DEPTH-1:0]                         fw_wr_ptr_async,
    input  wire [FW_FIFO_DEPTH-1:0]                         fw_rd_ptr_async,
    output wire [((payload_width_fn(
                                    FW_LAST_WIDTH,
                                    FW_DATA_WIDTH,
                                    FW_STRB_WIDTH,
                                    FW_KEEP_WIDTH,
                                    FW_ID_WIDTH,
                                    FW_DEST_WIDTH,
                                    FW_USER_WIDTH
                                   )>0)?
                  ((payload_width_fn(
                                     FW_LAST_WIDTH,
                                     FW_DATA_WIDTH,
                                     FW_STRB_WIDTH,
                                     FW_KEEP_WIDTH,
                                     FW_ID_WIDTH,
                                     FW_DEST_WIDTH,
                                     FW_USER_WIDTH
                                     )*FW_FIFO_DEPTH)-1):
                  0):0]                                     fw_payld_async,
    input  wire [RV_FIFO_DEPTH-1:0]                         rv_wr_ptr_async,
    output wire [RV_FIFO_DEPTH-1:0]                         rv_rd_ptr_async,
    input  wire [((payload_width_fn(
                                    RV_LAST_WIDTH,
                                    RV_DATA_WIDTH,
                                    RV_STRB_WIDTH,
                                    RV_KEEP_WIDTH,
                                    RV_ID_WIDTH,
                                    RV_DEST_WIDTH,
                                    RV_USER_WIDTH
                                   )>0)?
                  ((payload_width_fn(
                                     RV_LAST_WIDTH,
                                     RV_DATA_WIDTH,
                                     RV_STRB_WIDTH,
                                     RV_KEEP_WIDTH,
                                     RV_ID_WIDTH,
                                     RV_DEST_WIDTH,
                                     RV_USER_WIDTH
                                     )*RV_FIFO_DEPTH)-1):
                  0):0]                                     rv_payld_async   );


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

  localparam FW_PAYLOAD_WIDTH =
    payload_width_fn (
                      FW_LAST_WIDTH,
                      FW_DATA_WIDTH,
                      FW_STRB_WIDTH,
                      FW_KEEP_WIDTH,
                      FW_ID_WIDTH,
                      FW_DEST_WIDTH,
                      FW_USER_WIDTH
                     );

  localparam RV_PAYLOAD_WIDTH =
    payload_width_fn (
                      RV_LAST_WIDTH,
                      RV_DATA_WIDTH,
                      RV_STRB_WIDTH,
                      RV_KEEP_WIDTH,
                      RV_ID_WIDTH,
                      RV_DEST_WIDTH,
                      RV_USER_WIDTH
                     );

  wire [((FW_PAYLOAD_WIDTH>0)?(FW_PAYLOAD_WIDTH-1):0):0] tfwpaylds;
  wire [((RV_PAYLOAD_WIDTH>0)?(RV_PAYLOAD_WIDTH-1):0):0] trvpaylds;

  generate
    if (FW_PAYLOAD_WIDTH==0)
      begin : g_fw_no_payload
        assign tfwpaylds = 1'b0;
        wire tfwlasts_unused = tfwlasts;
        wire tfwdatas_unused = tfwdatas;
        wire tfwstrbs_unused = tfwstrbs;
        wire tfwkeeps_unused = tfwkeeps;
        wire tfwids_unused   = tfwids;
        wire tfwdests_unused = tfwdests;
        wire tfwusers_unused = tfwusers;
      end
    else
      begin : g_fw_has_payload
        if (FW_LAST_WIDTH>0)
          begin : g_fw_has_last
            assign tfwpaylds[
                             FW_DATA_WIDTH +
                             FW_STRB_WIDTH +
                             FW_KEEP_WIDTH +
                             FW_ID_WIDTH +
                             FW_DEST_WIDTH +
                             FW_USER_WIDTH +
                             0 +: 1] = tfwlasts;
          end
    
        if (FW_DATA_WIDTH>0)
          begin : g_fw_has_data
            assign tfwpaylds[
                             FW_STRB_WIDTH +
                             FW_KEEP_WIDTH +
                             FW_ID_WIDTH +
                             FW_DEST_WIDTH +
                             FW_USER_WIDTH +
                             0 +: FW_DATA_WIDTH] = tfwdatas;
          end
    
        if (FW_STRB_WIDTH>0)
          begin : g_fw_has_strb
            assign tfwpaylds[
                             FW_KEEP_WIDTH +
                             FW_ID_WIDTH +
                             FW_DEST_WIDTH +
                             FW_USER_WIDTH +
                             0 +: FW_STRB_WIDTH] = tfwstrbs;
          end
    
        if (FW_KEEP_WIDTH>0)
          begin : g_fw_has_keep
            assign tfwpaylds[
                             FW_ID_WIDTH +
                             FW_DEST_WIDTH +
                             FW_USER_WIDTH +
                             0 +: FW_KEEP_WIDTH] = tfwkeeps;
          end
    
        if (FW_ID_WIDTH>0)
          begin : g_fw_has_id
            assign tfwpaylds[
                             FW_DEST_WIDTH +
                             FW_USER_WIDTH +
                             0 +: FW_ID_WIDTH] = tfwids;
          end
    
        if (FW_DEST_WIDTH>0)
          begin : g_fw_has_dest
            assign tfwpaylds[
                             FW_USER_WIDTH +
                             0 +: FW_DEST_WIDTH] = tfwdests;
          end
    
        if (FW_USER_WIDTH>0)
          begin : g_fw_has_user
            assign tfwpaylds[
                             0 +: FW_USER_WIDTH] = tfwusers;
          end
      end

    if (RV_PAYLOAD_WIDTH==0)
      begin : g_rv_no_payld
        wire trvpaylds_unused = trvpaylds;
        assign trvlasts = 1'b0;
        assign trvdatas = 1'b0;
        assign trvstrbs = 1'b0;
        assign trvkeeps = 1'b0;
        assign trvids   = 1'b0;
        assign trvdests = 1'b0;
        assign trvusers = 1'b0;
      end
    else
      begin : g_rv_has_payld
        if (RV_LAST_WIDTH>0)
          begin : g_rv_has_last
            assign trvlasts = trvpaylds[
                                        RV_DATA_WIDTH +
                                        RV_STRB_WIDTH +
                                        RV_KEEP_WIDTH +
                                        RV_ID_WIDTH +
                                        RV_DEST_WIDTH +
                                        RV_USER_WIDTH +
                                        0 +: 1];
          end
        else
          begin : g_rv_no_last
            assign trvlasts = 1'b0;
          end
         
    
        if (RV_DATA_WIDTH>0)
          begin : g_rv_has_data
            assign trvdatas = trvpaylds[
                                        RV_STRB_WIDTH +
                                        RV_KEEP_WIDTH +
                                        RV_ID_WIDTH +
                                        RV_DEST_WIDTH +
                                        RV_USER_WIDTH +
                                        0 +: RV_DATA_WIDTH];
          end
        else
          begin : g_rv_no_data
            assign trvdatas = 1'b0;
          end
    
        if (RV_STRB_WIDTH>0)
          begin : g_rv_has_strb
            assign trvstrbs = trvpaylds[
                                        RV_KEEP_WIDTH +
                                        RV_ID_WIDTH +
                                        RV_DEST_WIDTH +
                                        RV_USER_WIDTH +
                                        0 +: RV_STRB_WIDTH];
          end
        else
          begin : g_rv_no_strb
            assign trvstrbs = 1'b0;
          end
    
        if (RV_KEEP_WIDTH>0)
          begin : g_rv_has_keep
            assign trvkeeps = trvpaylds[
                                        RV_ID_WIDTH +
                                        RV_DEST_WIDTH +
                                        RV_USER_WIDTH +
                                        0 +: RV_KEEP_WIDTH];
          end
        else
          begin : g_rv_no_keep
            assign trvkeeps = 1'b0;
          end
    
        if (RV_ID_WIDTH>0)
          begin : g_rv_has_id
            assign trvids   = trvpaylds[
                                        RV_DEST_WIDTH +
                                        RV_USER_WIDTH +
                                        0 +: RV_ID_WIDTH];
          end
        else
          begin : g_rv_no_id
            assign trvids   = 1'b0;
          end
    
        if (RV_DEST_WIDTH>0)
          begin : g_rv_has_dest
            assign trvdests = trvpaylds[
                                        RV_USER_WIDTH +
                                        0 +: RV_DEST_WIDTH];
          end
        else
          begin : g_rv_no_dest
            assign trvdests = 1'b0;
          end
    
        if (RV_USER_WIDTH>0)
          begin : g_rv_has_user
            assign trvusers = trvpaylds[
                                        0 +: RV_USER_WIDTH];
          end
        else
          begin : g_rv_no_user
            assign trvusers = 1'b0;
          end
      end

  endgenerate

  adb400_r3_slv_transport_f1r1
    #(
      .FW_FIFO_DEPTH       (FW_FIFO_DEPTH),
      .RV_FIFO_DEPTH       (RV_FIFO_DEPTH),
      .RV_OPREG            (RV_OPREG),
      .SYNC_LEVELS         (SI_SYNC_LEVELS),
      .FW_PAYLOAD_WIDTH    (FW_PAYLOAD_WIDTH),
      .RV_PAYLOAD_WIDTH    (RV_PAYLOAD_WIDTH)
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
      .wakeup_o                (wakeups_o),

      .fwvalid                 (tfwvalids),
      .fwready                 (tfwreadys),
      .fw_payld                (tfwpaylds),

      .rvvalid                 (trvvalids),
      .rvready                 (trvreadys),
      .rv_payld                (trvpaylds),

      .slvmustacceptreqn_async (slvmustacceptreqn_async),
      .slvcandenyreqn_async    (slvcandenyreqn_async),
      .slvacceptn_async        (slvacceptn_async),
      .slvdeny_async           (slvdeny_async),

      .si_to_mi_wakeup_async   (si_to_mi_wakeup_async),
      .mi_to_si_wakeup_async   (mi_to_si_wakeup_async),

      .fw_wr_ptr_async         (fw_wr_ptr_async),
      .fw_rd_ptr_async         (fw_rd_ptr_async),
      .fw_payld_async          (fw_payld_async),
     
      .rv_wr_ptr_async         (rv_wr_ptr_async),
      .rv_rd_ptr_async         (rv_rd_ptr_async),
      .rv_payld_async          (rv_payld_async)
    );

endmodule

