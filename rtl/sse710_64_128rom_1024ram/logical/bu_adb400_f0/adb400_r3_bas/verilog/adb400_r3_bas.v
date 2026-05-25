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
// File: adb400_r3_bas.v
//-----------------------------------------------------------------------------
// Purpose : Domain bridge with bi-directional AXI4-Stream interfaces.
//-----------------------------------------------------------------------------

module adb400_r3_bas
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
      RV_OPREG          = 1,

      SI_SYNC_LEVELS    = 2,
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
    // 'SI' side
    //

    // Configuration inputs
    input  wire                   pwrq_permit_deny_sar_i,

    // Power state control
    input  wire                   pwrqreqns_i,
    output wire                   pwrqacceptns_o,
    output wire                   pwrqdenys_o,

    // Global signals
    input  wire                   aclks,
    input  wire                   aresetns,
    input  wire                   dftrstdisables,

    // Clock control
    input  wire                   clkqreqns_i,
    output wire                   clkqacceptns_o,
    output wire                   clkqdenys_o,

    // Clock requirement
    output wire                   clkqactives_o,

    // Power requirement
    output wire                   pwrqactives_o,

    // Wake-up
    input  wire                   wakeups_i,
    output wire                   wakeups_o,

    //
    // Synchronous interfaces
    //

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


    //
    // 'MI' side
    //

    // Global signals
    input  wire                   aclkm,
    input  wire                   aresetnm,
    input  wire                   dftrstdisablem,

    // Clock control
    input  wire                   clkqreqnm_i,
    output wire                   clkqacceptnm_o,
    output wire                   clkqdenym_o,

    // Clock requirement
    output wire                   clkqactivem_o,

    // Power requirement
    output wire                   pwrqactivem_o,

    // Wake-up
    input  wire                   wakeupm_i,
    output wire                   wakeupm_o,

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
    input  wire [((RV_USER_WIDTH>0)?(RV_USER_WIDTH-1):0):0] trvuserm
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

  //
  // Wires between interfaces
  //

  wire [FW_FIFO_DEPTH-1:0] fw_wr_ptr_async;
  wire [FW_FIFO_DEPTH-1:0] fw_rd_ptr_async;
  wire [((FW_PAYLOAD_WIDTH>0)?((FW_PAYLOAD_WIDTH*FW_FIFO_DEPTH)-1):0):0] fw_payld_async;

  wire [RV_FIFO_DEPTH-1:0] rv_wr_ptr_async;
  wire [RV_FIFO_DEPTH-1:0] rv_rd_ptr_async;
  wire [((RV_PAYLOAD_WIDTH>0)?((RV_PAYLOAD_WIDTH*RV_FIFO_DEPTH)-1):0):0] rv_payld_async;

  wire                     slvmustacceptreqn_async;
  wire                     slvcandenyreqn_async;
  wire                     slvacceptn_async;
  wire                     slvdeny_async;

  wire                     si_to_mi_wakeup_async;
  wire                     mi_to_si_wakeup_async;

  adb400_r3_bas_slv
    #(
      .FW_DATA_WIDTH       (FW_DATA_WIDTH),
      .FW_STRB_WIDTH       (FW_STRB_WIDTH),
      .FW_KEEP_WIDTH       (FW_KEEP_WIDTH),
      .FW_LAST_WIDTH       (FW_LAST_WIDTH),
      .FW_ID_WIDTH         (FW_ID_WIDTH),
      .FW_DEST_WIDTH       (FW_DEST_WIDTH),
      .FW_USER_WIDTH       (FW_USER_WIDTH),
      .FW_FIFO_DEPTH       (FW_FIFO_DEPTH),
      .RV_DATA_WIDTH       (RV_DATA_WIDTH),
      .RV_STRB_WIDTH       (RV_STRB_WIDTH),
      .RV_KEEP_WIDTH       (RV_KEEP_WIDTH),
      .RV_LAST_WIDTH       (RV_LAST_WIDTH),
      .RV_ID_WIDTH         (RV_ID_WIDTH),
      .RV_DEST_WIDTH       (RV_DEST_WIDTH),
      .RV_USER_WIDTH       (RV_USER_WIDTH),
      .RV_FIFO_DEPTH       (RV_FIFO_DEPTH),
      .RV_OPREG            (RV_OPREG),
      .SI_SYNC_LEVELS      (SI_SYNC_LEVELS)
    )
  u_slv
    (
      .pwrq_permit_deny_sar_i  (pwrq_permit_deny_sar_i),

      .pwrqreqns_i             (pwrqreqns_i),
      .pwrqacceptns_o          (pwrqacceptns_o),
      .pwrqdenys_o             (pwrqdenys_o),

      .aclks                   (aclks),
      .aresetns                (aresetns),

      .dftrstdisables          (dftrstdisables),

      .clkqreqns_i             (clkqreqns_i),
      .clkqacceptns_o          (clkqacceptns_o),
      .clkqdenys_o             (clkqdenys_o),
      .clkqactives_o           (clkqactives_o),
      .pwrqactives_o           (pwrqactives_o),
      .wakeups_i               (wakeups_i),
      .wakeups_o               (wakeups_o),

      .tfwvalids               (tfwvalids),
      .tfwreadys               (tfwreadys),
      .tfwdatas                (tfwdatas),
      .tfwstrbs                (tfwstrbs),
      .tfwkeeps                (tfwkeeps),
      .tfwlasts                (tfwlasts),
      .tfwids                  (tfwids),
      .tfwdests                (tfwdests),
      .tfwusers                (tfwusers),

      .trvvalids               (trvvalids),
      .trvreadys               (trvreadys),
      .trvdatas                (trvdatas),
      .trvstrbs                (trvstrbs),
      .trvkeeps                (trvkeeps),
      .trvlasts                (trvlasts),
      .trvids                  (trvids),
      .trvdests                (trvdests),
      .trvusers                (trvusers),

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

  adb400_r3_bas_mst
    #(
      .FW_DATA_WIDTH       (FW_DATA_WIDTH),
      .FW_STRB_WIDTH       (FW_STRB_WIDTH),
      .FW_KEEP_WIDTH       (FW_KEEP_WIDTH),
      .FW_LAST_WIDTH       (FW_LAST_WIDTH),
      .FW_ID_WIDTH         (FW_ID_WIDTH),
      .FW_DEST_WIDTH       (FW_DEST_WIDTH),
      .FW_USER_WIDTH       (FW_USER_WIDTH),
      .FW_FIFO_DEPTH       (FW_FIFO_DEPTH),
      .FW_OPREG            (FW_OPREG),
      .RV_DATA_WIDTH       (RV_DATA_WIDTH),
      .RV_STRB_WIDTH       (RV_STRB_WIDTH),
      .RV_KEEP_WIDTH       (RV_KEEP_WIDTH),
      .RV_LAST_WIDTH       (RV_LAST_WIDTH),
      .RV_ID_WIDTH         (RV_ID_WIDTH),
      .RV_DEST_WIDTH       (RV_DEST_WIDTH),
      .RV_USER_WIDTH       (RV_USER_WIDTH),
      .RV_FIFO_DEPTH       (RV_FIFO_DEPTH),
      .MI_SYNC_LEVELS      (MI_SYNC_LEVELS)
    )
  u_mst
    (
      .aclkm                   (aclkm),
      .aresetnm                (aresetnm),

      .dftrstdisablem          (dftrstdisablem),

      .clkqreqnm_i             (clkqreqnm_i),
      .clkqacceptnm_o          (clkqacceptnm_o),
      .clkqdenym_o             (clkqdenym_o),
      .clkqactivem_o           (clkqactivem_o),
      .pwrqactivem_o           (pwrqactivem_o),
      .wakeupm_i               (wakeupm_i),
      .wakeupm_o               (wakeupm_o),

      .tfwvalidm               (tfwvalidm),
      .tfwreadym               (tfwreadym),
      .tfwdatam                (tfwdatam),
      .tfwstrbm                (tfwstrbm),
      .tfwkeepm                (tfwkeepm),
      .tfwlastm                (tfwlastm),
      .tfwidm                  (tfwidm),
      .tfwdestm                (tfwdestm),
      .tfwuserm                (tfwuserm),

      .trvvalidm               (trvvalidm),
      .trvreadym               (trvreadym),
      .trvdatam                (trvdatam),
      .trvstrbm                (trvstrbm),
      .trvkeepm                (trvkeepm),
      .trvlastm                (trvlastm),
      .trvidm                  (trvidm),
      .trvdestm                (trvdestm),
      .trvuserm                (trvuserm),

      .slvmustacceptreqn_async (slvmustacceptreqn_async),
      .slvcandenyreqn_async    (slvcandenyreqn_async),
      .slvacceptn_async        (slvacceptn_async),
      .slvdeny_async           (slvdeny_async),

      .si_to_mi_wakeup_async   (si_to_mi_wakeup_async),
      .mi_to_si_wakeup_async   (mi_to_si_wakeup_async),

      .fw_wr_ptr_async    (fw_wr_ptr_async),
      .fw_rd_ptr_async    (fw_rd_ptr_async),
      .fw_payld_async     (fw_payld_async),
     
      .rv_wr_ptr_async    (rv_wr_ptr_async),
      .rv_rd_ptr_async    (rv_rd_ptr_async),
      .rv_payld_async     (rv_payld_async)
    );

endmodule

