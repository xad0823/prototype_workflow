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
// File: adb400_r3_bas_mst.v
//-----------------------------------------------------------------------------
// Purpose : Master side of bridge with bi-directional AXI4-Stream interfaces.
//-----------------------------------------------------------------------------

module adb400_r3_bas_mst
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
      FW_OPREG          = 1,

      MI_SYNC_LEVELS    = 2,

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
    //
    // Synchronous interfaces
    //

    // Global signals
    input  wire                                             aclkm,
    input  wire                                             aresetnm,
    input  wire                                             dftrstdisablem,

    // Clock control
    input  wire                                             clkqreqnm_i,
    output wire                                             clkqacceptnm_o,
    output wire                                             clkqdenym_o,

    // Clock requirement
    output wire                                             clkqactivem_o,

    // Power requirement
    output wire                                             pwrqactivem_o,

    // Wake-up
    input  wire                                             wakeupm_i,
    output wire                                             wakeupm_o,

    // FW channel signalling
    output wire                                             tfwvalidm,
    input  wire                                             tfwreadym,
    output wire [((FW_DATA_WIDTH>0)?(FW_DATA_WIDTH-1):0):0] tfwdatam,
    output wire [((FW_STRB_WIDTH>0)?(FW_STRB_WIDTH-1):0):0] tfwstrbm,
    output wire [((FW_KEEP_WIDTH>0)?(FW_KEEP_WIDTH-1):0):0] tfwkeepm,
    output wire                                             tfwlastm,
    output wire [((FW_ID_WIDTH>0)?(FW_ID_WIDTH-1):0):0]     tfwidm,
    output wire [((FW_DEST_WIDTH>0)?(FW_DEST_WIDTH-1):0):0] tfwdestm,
    output wire [((FW_USER_WIDTH>0)?(FW_USER_WIDTH-1):0):0] tfwuserm,

    // RV channel signalling
    input  wire                                             trvvalidm,
    output wire                                             trvreadym,
    input  wire [((RV_DATA_WIDTH>0)?(RV_DATA_WIDTH-1):0):0] trvdatam,
    input  wire [((RV_STRB_WIDTH>0)?(RV_STRB_WIDTH-1):0):0] trvstrbm,
    input  wire [((RV_KEEP_WIDTH>0)?(RV_KEEP_WIDTH-1):0):0] trvkeepm,
    input  wire                                             trvlastm,
    input  wire [((RV_ID_WIDTH>0)?(RV_ID_WIDTH-1):0):0]     trvidm,
    input  wire [((RV_DEST_WIDTH>0)?(RV_DEST_WIDTH-1):0):0] trvdestm,
    input  wire [((RV_USER_WIDTH>0)?(RV_USER_WIDTH-1):0):0] trvuserm,

    // Async interfaces 

    input  wire                                             slvmustacceptreqn_async,
    input  wire                                             slvcandenyreqn_async,
    output wire                                             slvacceptn_async,
    output wire                                             slvdeny_async,

    input  wire                                             si_to_mi_wakeup_async,
    output wire                                             mi_to_si_wakeup_async,

    input  wire [FW_FIFO_DEPTH-1:0]                         fw_wr_ptr_async,
    output wire [FW_FIFO_DEPTH-1:0]                         fw_rd_ptr_async,
    input  wire [((payload_width_fn(
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

    output wire [RV_FIFO_DEPTH-1:0]                         rv_wr_ptr_async,
    input  wire [RV_FIFO_DEPTH-1:0]                         rv_rd_ptr_async,
    output wire [((payload_width_fn(
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
                  0):0]                                     rv_payld_async
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

  wire [((FW_PAYLOAD_WIDTH>0)?(FW_PAYLOAD_WIDTH-1):0):0] tfwpayldm;
  wire [((RV_PAYLOAD_WIDTH>0)?(RV_PAYLOAD_WIDTH-1):0):0] trvpayldm;

  generate

    if (FW_PAYLOAD_WIDTH==0)
      begin : g_fw_no_payld
        wire tfwpayldm_unused = tfwpayldm;
        assign tfwlastm = 1'b0;
        assign tfwdatam = 1'b0;
        assign tfwstrbm = 1'b0;
        assign tfwkeepm = 1'b0;
        assign tfwidm   = 1'b0;
        assign tfwdestm = 1'b0;
        assign tfwuserm = 1'b0;
      end
    else
      begin : g_fw_has_payld
        if (FW_LAST_WIDTH>0)
          begin : g_fw_has_last
            assign tfwlastm = tfwpayldm[
                                        FW_DATA_WIDTH +
                                        FW_STRB_WIDTH +
                                        FW_KEEP_WIDTH +
                                        FW_ID_WIDTH +
                                        FW_DEST_WIDTH +
                                        FW_USER_WIDTH +
                                        0 +: 1];
          end
        else
          begin : g_fw_no_last
            assign tfwlastm = 1'b0;
          end

        if (FW_DATA_WIDTH>0)
          begin : g_fw_has_data
            assign tfwdatam = tfwpayldm[
                                        FW_STRB_WIDTH +
                                        FW_KEEP_WIDTH +
                                        FW_ID_WIDTH +
                                        FW_DEST_WIDTH +
                                        FW_USER_WIDTH +
                                        0 +: FW_DATA_WIDTH];
          end
        else
          begin : g_fw_no_data
            assign tfwdatam = 1'b0;
          end
    
        if (FW_STRB_WIDTH>0)
          begin : g_fw_has_strb
            assign tfwstrbm = tfwpayldm[
                                        FW_KEEP_WIDTH +
                                        FW_ID_WIDTH +
                                        FW_DEST_WIDTH +
                                        FW_USER_WIDTH +
                                        0 +: FW_STRB_WIDTH];
          end
        else
          begin : g_fw_no_strb
            assign tfwstrbm = 1'b0;
          end
    
        if (FW_KEEP_WIDTH>0)
          begin : g_fw_has_keep
            assign tfwkeepm = tfwpayldm[
                                        FW_ID_WIDTH +
                                        FW_DEST_WIDTH +
                                        FW_USER_WIDTH +
                                        0 +: FW_KEEP_WIDTH];
          end
        else
          begin : g_fw_no_keep
            assign tfwkeepm = 1'b0;
          end
    
        if (FW_ID_WIDTH>0)
          begin : g_fw_has_id
            assign tfwidm   = tfwpayldm[
                                        FW_DEST_WIDTH +
                                        FW_USER_WIDTH +
                                        0 +: FW_ID_WIDTH];
          end
        else
          begin : g_fw_no_id
            assign tfwidm   = 1'b0;
          end
    
        if (FW_DEST_WIDTH>0)
          begin : g_fw_has_dest
            assign tfwdestm = tfwpayldm[
                                        FW_USER_WIDTH +
                                        0 +: FW_DEST_WIDTH];
          end
        else
          begin : g_fw_no_dest
            assign tfwdestm = 1'b0;
          end
    
        if (FW_USER_WIDTH>0)
          begin : g_fw_has_user
            assign tfwuserm = tfwpayldm[
                                        0 +: FW_USER_WIDTH];
          end
        else
          begin : g_fw_no_user
            assign tfwuserm = 1'b0;
          end
      end

    if (RV_PAYLOAD_WIDTH==0)
      begin : g_rv_no_payload
        assign trvpayldm = 1'b0;
        wire trvlastm_unused = trvlastm;
        wire trvdatam_unused = trvdatam;
        wire trvstrbm_unused = trvstrbm;
        wire trvkeepm_unused = trvkeepm;
        wire trvidm_unused   = trvidm;
        wire trvdestm_unused = trvdestm;
        wire trvuserm_unused = trvuserm;
      end
    else
      begin : g_rv_has_payload
        if (RV_LAST_WIDTH>0)
          begin : g_rv_has_last
            assign trvpayldm[
                             RV_DATA_WIDTH +
                             RV_STRB_WIDTH +
                             RV_KEEP_WIDTH +
                             RV_ID_WIDTH +
                             RV_DEST_WIDTH +
                             RV_USER_WIDTH +
                             0 +: 1] = trvlastm;
          end
     
        if (RV_DATA_WIDTH>0)
          begin : g_rv_has_data
            assign trvpayldm[
                             RV_STRB_WIDTH +
                             RV_KEEP_WIDTH +
                             RV_ID_WIDTH +
                             RV_DEST_WIDTH +
                             RV_USER_WIDTH +
                             0 +: RV_DATA_WIDTH] = trvdatam;
          end
     
        if (RV_STRB_WIDTH>0)
          begin : g_rv_has_strb
            assign trvpayldm[
                             RV_KEEP_WIDTH +
                             RV_ID_WIDTH +
                             RV_DEST_WIDTH +
                             RV_USER_WIDTH +
                             0 +: RV_STRB_WIDTH] = trvstrbm;
          end
     
        if (RV_KEEP_WIDTH>0)
          begin : g_rv_has_keep
            assign trvpayldm[
                             RV_ID_WIDTH +
                             RV_DEST_WIDTH +
                             RV_USER_WIDTH +
                             0 +: RV_KEEP_WIDTH] = trvkeepm;
          end
     
        if (RV_ID_WIDTH>0)
          begin : g_rv_has_id
            assign trvpayldm[
                             RV_DEST_WIDTH +
                             RV_USER_WIDTH +
                             0 +: RV_ID_WIDTH] = trvidm;
          end
     
        if (RV_DEST_WIDTH>0)
          begin : g_rv_has_dest
            assign trvpayldm[
                             RV_USER_WIDTH +
                             0 +: RV_DEST_WIDTH] = trvdestm;
          end
     
        if (RV_USER_WIDTH>0)
          begin : g_rv_has_user
            assign trvpayldm[
                             0 +: RV_USER_WIDTH] = trvuserm;
          end
      end

  endgenerate

  adb400_r3_mst_transport_f1r1
    #(
      .FW_FIFO_DEPTH       (FW_FIFO_DEPTH),
      .RV_FIFO_DEPTH       (RV_FIFO_DEPTH),
      .FW_OPREG            (FW_OPREG),
      .SYNC_LEVELS         (MI_SYNC_LEVELS),
      .FW_PAYLOAD_WIDTH    (FW_PAYLOAD_WIDTH),
      .RV_PAYLOAD_WIDTH    (RV_PAYLOAD_WIDTH)
    )
  u_mst
    (
      .aclk                    (aclkm),
      .aresetn                 (aresetnm),

      .dftrstdisable           (dftrstdisablem),

      .clkqreqn_i              (clkqreqnm_i),
      .clkqacceptn_o           (clkqacceptnm_o),
      .clkqdeny_o              (clkqdenym_o),
      .clkqactive_o            (clkqactivem_o),
      .pwrqactive_o            (pwrqactivem_o),
      .wakeup_i                (wakeupm_i),
      .wakeup_o                (wakeupm_o),

      .fwvalid                 (tfwvalidm),
      .fwready                 (tfwreadym),
      .fw_payld                (tfwpayldm),

      .rvvalid                 (trvvalidm),
      .rvready                 (trvreadym),
      .rv_payld                (trvpayldm),

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

