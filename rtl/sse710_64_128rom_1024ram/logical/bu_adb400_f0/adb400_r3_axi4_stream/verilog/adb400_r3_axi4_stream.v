//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
// (C) COPYRIGHT 2013-2016 ARM Limited or its affiliates.
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
// File: adb400_r3_axi4_stream.v
//-----------------------------------------------------------------------------
// Purpose : Domain bridge with AXI4-Stream interfaces.
//-----------------------------------------------------------------------------

module adb400_r3_axi4_stream
  #(parameter
      DATA_WIDTH     = 8,
      ID_WIDTH       = 1,
      DEST_WIDTH     = 1,
      USER_WIDTH     = 1,

      FIFO_DEPTH     = 6,
      OPREG          = 1,

      SI_SYNC_LEVELS    = 2,
      MI_SYNC_LEVELS    = 2,

      // If they are overridden is should only be to 0.

      // These are generally derived from DATA width.
      STRB_WIDTH     = (DATA_WIDTH/8),
      KEEP_WIDTH     = (DATA_WIDTH/8),

      // Normally present, but can be removed
      LAST_WIDTH     = 1
  )
  (
    //
    // 'SI' side
    //

    // Configuration inputs
    input  wire                                             pwrq_permit_deny_sar_i,

    // Power state control
    input  wire                                             pwrqreqns_i,
    output wire                                             pwrqacceptns_o,
    output wire                                             pwrqdenys_o,

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

    //
    // Synchronous interfaces
    //

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


    //
    // 'MI' side
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

    // Wake-up
    output wire                                             wakeupm_o,

    // Channel signalling
    output wire                                             tvalidm,
    input  wire                                             treadym,
    output wire [((DATA_WIDTH>0)?(DATA_WIDTH-1):0):0]       tdatam,
    output wire [((STRB_WIDTH>0)?(STRB_WIDTH-1):0):0]       tstrbm,
    output wire [((KEEP_WIDTH>0)?(KEEP_WIDTH-1):0):0]       tkeepm,
    output wire                                             tlastm,
    output wire [((ID_WIDTH>0)?(ID_WIDTH-1):0):0]           tidm,
    output wire [((DEST_WIDTH>0)?(DEST_WIDTH-1):0):0]       tdestm,
    output wire [((USER_WIDTH>0)?(USER_WIDTH-1):0):0]       tuserm
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

  //
  // Wires between interfaces
  //

  wire [FIFO_DEPTH-1:0] wr_ptr_async;
  wire [FIFO_DEPTH-1:0] rd_ptr_async;
  wire [((PAYLOAD_WIDTH>0)?((PAYLOAD_WIDTH*FIFO_DEPTH)-1):0):0] payld_async;

  wire                     slvmustacceptreqn_async;
  wire                     slvcandenyreqn_async;
  wire                     slvacceptn_async;
  wire                     slvdeny_async;

  wire                     si_to_mi_wakeup_async;
  wire                     mi_to_si_wakeup_async;

  adb400_r3_axi4_stream_slv
    #(
      .DATA_WIDTH       (DATA_WIDTH),
      .STRB_WIDTH       (STRB_WIDTH),
      .KEEP_WIDTH       (KEEP_WIDTH),
      .LAST_WIDTH       (LAST_WIDTH),
      .ID_WIDTH         (ID_WIDTH),
      .DEST_WIDTH       (DEST_WIDTH),
      .USER_WIDTH       (USER_WIDTH),
      .FIFO_DEPTH       (FIFO_DEPTH),
      .SI_SYNC_LEVELS   (SI_SYNC_LEVELS)
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

      .tvalids                 (tvalids),
      .treadys                 (treadys),
      .tdatas                  (tdatas),
      .tstrbs                  (tstrbs),
      .tkeeps                  (tkeeps),
      .tlasts                  (tlasts),
      .tids                    (tids),
      .tdests                  (tdests),
      .tusers                  (tusers),

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

  adb400_r3_axi4_stream_mst
    #(
      .DATA_WIDTH       (DATA_WIDTH),
      .STRB_WIDTH       (STRB_WIDTH),
      .KEEP_WIDTH       (KEEP_WIDTH),
      .LAST_WIDTH       (LAST_WIDTH),
      .ID_WIDTH         (ID_WIDTH),
      .DEST_WIDTH       (DEST_WIDTH),
      .USER_WIDTH       (USER_WIDTH),
      .FIFO_DEPTH       (FIFO_DEPTH),
      .OPREG            (OPREG),
      .MI_SYNC_LEVELS   (MI_SYNC_LEVELS)
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
      .wakeupm_o               (wakeupm_o),

      .tvalidm                 (tvalidm),
      .treadym                 (treadym),
      .tdatam                  (tdatam),
      .tstrbm                  (tstrbm),
      .tkeepm                  (tkeepm),
      .tlastm                  (tlastm),
      .tidm                    (tidm),
      .tdestm                  (tdestm),
      .tuserm                  (tuserm),

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

