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
// Checked In :  2016-04-19 11:26:23 +0100 (Tue, 19 Apr 2016)
// Revision : 209554
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_axi4_mst.v
//-----------------------------------------------------------------------------
// Purpose : Master half of protocol/qvn config specific bridge
//-----------------------------------------------------------------------------


module adb400_r3_axi4_mst
  #(parameter
      // Parameters that the user can be set from the top level (in some cases)
      ADDR_WIDTH          = 40,
      DATA_WIDTH          = 128,
      AWID_WIDTH          = 1,
      ARID_WIDTH          = 1,
      AWUSER_WIDTH        = 1,
      WUSER_WIDTH         = 1,
      BUSER_WIDTH         = 1,
      ARUSER_WIDTH        = 1,
      RUSER_WIDTH         = 1,
      AW_FIFO_DEPTH       = 4,
      W_FIFO_DEPTH        = 6,
      B_FIFO_DEPTH        = 2,
      AR_FIFO_DEPTH       = 4,
      R_FIFO_DEPTH        = 6,
      AW_OPREG            = 1,
      W_OPREG             = 1,
      AR_OPREG            = 1,
      MI_SYNC_LEVELS      = 2
  )
  (
    // Configuration inputs

    // Global signals
    input  wire                      aclkm,
    input  wire                      aresetnm,

    // Clock control
    input  wire                      clkqreqnm_i,
    output wire                      clkqacceptnm_o,
    output wire                      clkqdenym_o,

    // Clock requirement
    output wire                      clkqactivem_o,


    // Wake-up
    output wire                      wakeupm_o,

    // AW channel signalling
    output wire                      awvalidm,
    input  wire                      awreadym,
    output wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] awidm,
    output wire [ADDR_WIDTH-1:0]     awaddrm,
    output wire [3:0]                awregionm,
    output wire [7:0]                awlenm,
    output wire [2:0]                awsizem,
    output wire [1:0]                awburstm,
    output wire                      awlockm,
    output wire [3:0]                awcachem,
    output wire [2:0]                awprotm,
    output wire [3:0]                awqosm,
    output wire [((AWUSER_WIDTH>0)?(AWUSER_WIDTH-1):0):0] awuserm,

    // W channel signalling
    output wire                      wvalidm,
    input  wire                      wreadym,
    output wire [DATA_WIDTH-1:0]     wdatam,
    output wire [(DATA_WIDTH/8)-1:0] wstrbm,
    output wire                      wlastm,
    output wire [((WUSER_WIDTH>0)?(WUSER_WIDTH-1):0):0] wuserm,

    // B channel signalling
    input  wire                      bvalidm,
    output wire                      breadym,
    input  wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] bidm,
    input  wire [1:0]                brespm,
    input  wire [((BUSER_WIDTH>0)?(BUSER_WIDTH-1):0):0] buserm,

    // AR channel signalling
    output wire                      arvalidm,
    input  wire                      arreadym,
    output wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] aridm,
    output wire [ADDR_WIDTH-1:0]     araddrm,
    output wire [3:0]                arregionm,
    output wire [7:0]                arlenm,
    output wire [2:0]                arsizem,
    output wire [1:0]                arburstm,
    output wire                      arlockm,
    output wire [3:0]                arcachem,
    output wire [2:0]                arprotm,
    output wire [3:0]                arqosm,
    output wire [((ARUSER_WIDTH>0)?(ARUSER_WIDTH-1):0):0] aruserm,

    // R channel signalling
    input  wire                      rvalidm,
    output wire                      rreadym,
    input  wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] ridm,
    input  wire [DATA_WIDTH-1:0]     rdatam,
    input  wire [1:0]                rrespm,
    input  wire                      rlastm,
    input  wire [((RUSER_WIDTH>0)?(RUSER_WIDTH-1):0):0] ruserm,



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


    // AW channel signalling
    input  wire [AW_FIFO_DEPTH-1:0] aw_wr_ptr_async,
    output wire [AW_FIFO_DEPTH-1:0] aw_rd_ptr_async,
    input  wire [((aw_payload_width_fn(AWUSER_WIDTH,AWID_WIDTH,ADDR_WIDTH)+0)*AW_FIFO_DEPTH)-1:0] aw_payld_async,

    // W channel signalling
    input  wire [ W_FIFO_DEPTH-1:0]  w_wr_ptr_async,
    output wire [ W_FIFO_DEPTH-1:0]  w_rd_ptr_async,
    input  wire [((w_payload_width_fn(WUSER_WIDTH,AWID_WIDTH,DATA_WIDTH)+0)* W_FIFO_DEPTH)-1:0] w_payld_async,

    // B channel signalling
    output wire [ B_FIFO_DEPTH-1:0]  b_wr_ptr_async,
    input  wire [ B_FIFO_DEPTH-1:0]  b_rd_ptr_async,
    output wire [(b_payload_width_fn(BUSER_WIDTH,AWID_WIDTH)* B_FIFO_DEPTH)-1:0] b_payld_async,

    // AR channel signalling
    input  wire [AR_FIFO_DEPTH-1:0] ar_wr_ptr_async,
    output wire [AR_FIFO_DEPTH-1:0] ar_rd_ptr_async,
    input  wire [((ar_payload_width_fn(ARUSER_WIDTH,ARID_WIDTH,ADDR_WIDTH)+0)*AR_FIFO_DEPTH)-1:0] ar_payld_async,

    // R channel signalling
    output wire [ R_FIFO_DEPTH-1:0]  r_wr_ptr_async,
    input  wire [ R_FIFO_DEPTH-1:0]  r_rd_ptr_async,
    output wire [(r_payload_width_fn(RUSER_WIDTH,ARID_WIDTH,DATA_WIDTH)* R_FIFO_DEPTH)-1:0] r_payld_async,


    // Debug signalling
    input  wire                      dftrstdisablem
  );

  localparam AW_VN = 0;
  localparam AR_VN = 0;

`include "adb400_r3_functions.v"

  //-----------------------------------------------------
  // Return the width of the AW payload
  //-----------------------------------------------------
  function automatic integer aw_payload_width_fn
    (
      input integer awuser_width,
      input integer awid_width,
      input integer awaddr_width
    ); 
    begin : fn_aw_payload_width_fn
// ACS_off ARITHMETIC_OVERFLOW Some elements on RHS are integers, but no chance of overflow calculating a payload width
      aw_payload_width_fn =
               awuser_width +
               awid_width +
               awaddr_width +
               4 +            // awregion
               8 +            // awlen
               3 +            // awsize
               2 +            // awburst
               1 +            // awlock
               4 +            // awcache
               3 +            // awprot
               4 +            // awqos
               0;
    end
  endfunction

  //-----------------------------------------------------
  // Return the width of the W payload
  //-----------------------------------------------------
  function automatic integer w_payload_width_fn
    (
      input integer wuser_width,
      input integer wid_width,
      input integer wdata_width
    ); 
    begin : fn_w_payload_width_fn
// ACS_off ARITHMETIC_OVERFLOW Some elements on RHS are integers, but no chance of overflow calculating a payload width
      w_payload_width_fn =
               wuser_width +
               wdata_width +
               (wdata_width/8) + // wstrb
               1 +            // wlast
               0;
    end
  endfunction

  //-----------------------------------------------------
  // Return the width of the B payload
  //-----------------------------------------------------
  function automatic integer b_payload_width_fn
    (
      input integer buser_width,
      input integer bid_width
    ); 
    begin : fn_b_payload_width_fn
// ACS_off ARITHMETIC_OVERFLOW Some elements on RHS are integers, but no chance of overflow calculating a payload width
      b_payload_width_fn =
               buser_width +
               bid_width +
               2 +            // bresp
               0;
    end
  endfunction

  //-----------------------------------------------------
  // Return the width of the AR payload
  //-----------------------------------------------------
  function automatic integer ar_payload_width_fn
    (
      input integer aruser_width,
      input integer arid_width,
      input integer araddr_width
    ); 
    begin : fn_ar_payload_width_fn
// ACS_off ARITHMETIC_OVERFLOW Some elements on RHS are integers, but no chance of overflow calculating a payload width
      ar_payload_width_fn =
               aruser_width +
               arid_width +
               araddr_width +
               4 +            // arregion
               8 +            // arlen
               3 +            // arsize
               2 +            // arburst
               1 +            // arlock
               4 +            // arcache
               3 +            // arprot
               4 +            // arqos
               0;
    end
  endfunction

  //-----------------------------------------------------
  // Return the width of the R payload
  //-----------------------------------------------------
  function automatic integer r_payload_width_fn
    (
      input integer ruser_width,
      input integer rid_width,
      input integer rdata_width
    ); 
    begin : fn_r_payload_width_fn
// ACS_off ARITHMETIC_OVERFLOW Some elements on RHS are integers, but no chance of overflow calculating a payload width
      r_payload_width_fn =
               ruser_width +
               rid_width +
               rdata_width +
               2 +            // rresp
               1 +            // rlast
               0;
    end
  endfunction


  localparam AW_PAYLOAD_WIDTH = aw_payload_width_fn(AWUSER_WIDTH,AWID_WIDTH,               ADDR_WIDTH  );
  localparam W_PAYLOAD_WIDTH  =  w_payload_width_fn( WUSER_WIDTH,AWID_WIDTH,               DATA_WIDTH  );
  localparam B_PAYLOAD_WIDTH  =  b_payload_width_fn( BUSER_WIDTH,AWID_WIDTH                            );
  localparam AR_PAYLOAD_WIDTH = ar_payload_width_fn(ARUSER_WIDTH,ARID_WIDTH,               ADDR_WIDTH  );
  localparam R_PAYLOAD_WIDTH  =  r_payload_width_fn( RUSER_WIDTH,ARID_WIDTH,               DATA_WIDTH  );

  //-----------------------------------------------------
  // Wires for bundling payloads
  //-----------------------------------------------------

  wire [AW_PAYLOAD_WIDTH-1:0] aw_payload_m;
  wire [ W_PAYLOAD_WIDTH-1:0]  w_payload_m;
  wire [ B_PAYLOAD_WIDTH-1:0]  b_payload_m;
  wire [AR_PAYLOAD_WIDTH-1:0] ar_payload_m;
  wire [ R_PAYLOAD_WIDTH-1:0]  r_payload_m;


  //-----------------------------------------------------
  //-----------------------------------------------------
  // Pack the individual signals into a payload for each channel
  //-----------------------------------------------------
  //-----------------------------------------------------

  // If signals can be parameterised away, conditionally assign them
  // to/from the bottom bits, so there is no need to calculate what
  // position they are in.

  // AW
  assign
    {
      awaddrm,
      awregionm,
      awlenm,
      awsizem,
      awlockm,
      awcachem,
      awprotm,
      awqosm,    // 4b
      awburstm   // 2b
    } = aw_payload_m[AW_PAYLOAD_WIDTH-1:(AWUSER_WIDTH+AWID_WIDTH)];

  generate
    if (AWUSER_WIDTH>0)
      begin : g_assign_awuser
        assign awuserm = aw_payload_m[0+:AWUSER_WIDTH];
      end
    else
      begin : g_no_assign_awuser
        assign awuserm = 1'b0;
      end
    if (AWID_WIDTH>0)
      begin : g_assign_awid
        assign awidm = aw_payload_m[AWUSER_WIDTH+:AWID_WIDTH];
      end
    else
      begin : g_no_assign_awid
        assign awidm = 1'b0;
      end
  endgenerate



  // W
  assign
    {
      wdatam,
      wstrbm,
      wlastm
    } =   w_payload_m[W_PAYLOAD_WIDTH-1:WUSER_WIDTH];

  generate
    if (WUSER_WIDTH>0)
      begin : g_assign_wuser
        assign wuserm = w_payload_m[0+:WUSER_WIDTH];
      end
    else
      begin : g_noassign_wuser
        assign wuserm = 1'b0;
      end
  endgenerate


  localparam WLAST_OFFSET        = 0+(WUSER_WIDTH);

  // B
  assign b_payload_m[B_PAYLOAD_WIDTH-1:(BUSER_WIDTH+AWID_WIDTH)] =
    {
      brespm
    };

  generate
    if (BUSER_WIDTH>0)
      begin : g_buser_assign
        assign b_payload_m[0+:BUSER_WIDTH] = buserm;
      end
    else
      begin : g_buser_noassign
        wire busers_unused = buserm;
      end
    if (AWID_WIDTH>0)
      begin : g_bid_assign
        assign b_payload_m[BUSER_WIDTH+:AWID_WIDTH] = bidm;
      end
    else
      begin : g_bid_noassign
        wire bids_unused = bidm;
      end
  endgenerate

  // AR
  assign
    {
      arregionm,
      arlenm,
      arsizem,
      arlockm,
      arcachem,
      arprotm,
      araddrm,
      arqosm,   // 4b
      arburstm  // 2b
    } = ar_payload_m[AR_PAYLOAD_WIDTH-1:(ARUSER_WIDTH+ARID_WIDTH)];

  generate
    if (ARUSER_WIDTH>0)
      begin : g_assign_aruser
        assign aruserm = ar_payload_m[0+:ARUSER_WIDTH];
      end
    else
      begin : g_no_assign_aruser
        assign aruserm = 1'b0;
      end
    if (ARID_WIDTH>0)
      begin : g_assign_arid
        assign aridm = ar_payload_m[ARUSER_WIDTH+:ARID_WIDTH];
      end
    else
      begin : g_no_assign_arid
        assign aridm = 1'b0;
      end
  endgenerate




  // R
  assign r_payload_m[R_PAYLOAD_WIDTH-1:(RUSER_WIDTH+ARID_WIDTH)] =
    {
      rdatam,
      rrespm,
      rlastm
    };

  generate
    if (RUSER_WIDTH>0)
      begin : g_ruser_assign
        assign r_payload_m[0+:RUSER_WIDTH] = ruserm;
      end
    else
      begin : g_ruser_noassign
        wire ruserm_unused = ruserm;
      end
    if (ARID_WIDTH>0)
      begin : g_rid_assign
        assign r_payload_m[RUSER_WIDTH+:ARID_WIDTH] = ridm;
      end
    else
      begin : g_rid_noassign
        wire ridm_unused = ridm;
      end
  endgenerate

  localparam RLAST_OFFSET        = (RUSER_WIDTH+ARID_WIDTH);




  // Declare signals to connect to unused ports so no port is unconnected
  wire pwrqactivem_unused;
  wire acreadym_unused;
  wire crvalidm_unused;
  wire cr_payloadm_unused;
  wire cdvalidm_unused;
  wire cd_payloadm_unused;
  wire wackm_unused;
  wire rackm_unused;
  wire varvalidm_unused;
  wire varqosm_unused;
  wire vawvalidm_unused;
  wire vawqosm_unused;
  wire vwvalidm_unused;
  wire p_rd_ptr_async_unused;
  wire t_wr_ptr_async_unused;
  wire t_payld_async_unused;
  wire ac_wr_ptr_async_unused;
  wire ac_payld_async_unused;
  wire cr_rd_ptr_async_unused;
  wire cd_rd_ptr_async_unused;
  wire wack_rd_ptr_async_unused;
  wire rack_rd_ptr_async_unused;

  adb400_r3_mst_core
    #(
      .AW_FIFO_DEPTH    (AW_FIFO_DEPTH),
      .W_FIFO_DEPTH     (W_FIFO_DEPTH),
      .B_FIFO_DEPTH     (B_FIFO_DEPTH),
      .AR_FIFO_DEPTH    (AR_FIFO_DEPTH),
      .R_FIFO_DEPTH     (R_FIFO_DEPTH),
      .AC_FIFO_DEPTH    (0),
      .CR_FIFO_DEPTH    (0),
      .CD_FIFO_DEPTH    (0),
      .ACK_FIFO_DEPTH   (0),
      .AW_OPREG         (AW_OPREG),
      .W_OPREG          (W_OPREG),
      .AR_OPREG         (AR_OPREG),
      .AW_VN            (AW_VN),
      .AR_VN            (AR_VN),
      .WLAST_OFFSET     (WLAST_OFFSET),
      .RLAST_OFFSET     (RLAST_OFFSET),
      .AWBAR_OFFSET     (-1),
      .ARBAR_OFFSET     (-1),
      .AWSNOOP_OFFSET   (-1),
      .AW_PAYLOAD_WIDTH (AW_PAYLOAD_WIDTH),
      .W_PAYLOAD_WIDTH  (W_PAYLOAD_WIDTH),
      .B_PAYLOAD_WIDTH  (B_PAYLOAD_WIDTH),
      .AR_PAYLOAD_WIDTH (AR_PAYLOAD_WIDTH),
      .R_PAYLOAD_WIDTH  (R_PAYLOAD_WIDTH),
      .SYNC_LEVELS      (MI_SYNC_LEVELS)
    )
  u_mst
    (
    .var_prealloc_sar_i     (1'b0),
    .vaw_prealloc_sar_i     (1'b0),

    .aclk                   (aclkm),                   
    .aresetn                (aresetnm),

    .clkqreqn_i             (clkqreqnm_i),
    .clkqacceptn_o          (clkqacceptnm_o),
    .clkqdeny_o             (clkqdenym_o),
    .clkqactive_o           (clkqactivem_o),

    .pwrqactive_o           (pwrqactivem_unused),
    .wakeup_i               (1'b0),
    .wakeup_o               (wakeupm_o),

    .awvalid                (awvalidm),
    .awready                (awreadym),
    .aw_payld               (aw_payload_m),
    .wvalid                 (wvalidm),
    .wready                 (wreadym),
    .w_payld                (w_payload_m),
    .bvalid                 (bvalidm),
    .bready                 (breadym),
    .b_payld                (b_payload_m),
    .arvalid                (arvalidm),
    .arready                (arreadym),
    .ar_payld               (ar_payload_m),
    .rvalid                 (rvalidm),
    .rready                 (rreadym),
    .r_payld                (r_payload_m),

    .acvalid                (1'b0),
    .acready                (acreadym_unused),
    .ac_payld               (1'b0),
    .crvalid                (crvalidm_unused),
    .crready                (1'b0),
    .cr_payld               (cr_payloadm_unused),
    .cdvalid                (cdvalidm_unused),
    .cdready                (1'b0),
    .cd_payld               (cd_payloadm_unused),
    .wack                   (wackm_unused),
    .rack                   (rackm_unused),

    .varvalid               (varvalidm_unused),
    .varready               (1'b0),
    .varqos                 (varqosm_unused),
    .vawvalid               (vawvalidm_unused),
    .vawready               (1'b0),
    .vawqos                 (vawqosm_unused),
    .vwvalid                (vwvalidm_unused),
    .vwready                (1'b0),

    .slvmustacceptreqn_async (slvmustacceptreqn_async),
    .slvcandenyreqn_async   (slvcandenyreqn_async),
    .slvacceptn_async       (slvacceptn_async),
    .slvdeny_async          (slvdeny_async),
    .si_to_mi_wakeup_async  (si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async  (mi_to_si_wakeup_async),

    .p_wr_ptr_async         (1'b0),
    .p_rd_ptr_async         (p_rd_ptr_async_unused),
    .p_payld_async          (1'b0),
    .t_wr_ptr_async         (t_wr_ptr_async_unused),
    .t_rd_ptr_async         (1'b0),
    .t_payld_async          (t_payld_async_unused),
    .aw_wr_ptr_async        (aw_wr_ptr_async),
    .aw_rd_ptr_async        (aw_rd_ptr_async),
    .aw_payld_async         (aw_payld_async),
    .w_wr_ptr_async         (w_wr_ptr_async),
    .w_rd_ptr_async         (w_rd_ptr_async),
    .w_payld_async          (w_payld_async),
    .b_wr_ptr_async         (b_wr_ptr_async),
    .b_rd_ptr_async         (b_rd_ptr_async),
    .b_payld_async          (b_payld_async),
    .ar_wr_ptr_async        (ar_wr_ptr_async),
    .ar_rd_ptr_async        (ar_rd_ptr_async),
    .ar_payld_async         (ar_payld_async),
    .r_wr_ptr_async         (r_wr_ptr_async),
    .r_rd_ptr_async         (r_rd_ptr_async),
    .r_payld_async          (r_payld_async),

    .ac_wr_ptr_async        (ac_wr_ptr_async_unused),
    .ac_rd_ptr_async        (1'b0),
    .ac_payld_async         (ac_payld_async_unused),
    .cr_wr_ptr_async        (1'b0),
    .cr_rd_ptr_async        (cr_rd_ptr_async_unused),
    .cr_payld_async         (1'b0),
    .cd_wr_ptr_async        (1'b0),
    .cd_rd_ptr_async        (cd_rd_ptr_async_unused),
    .cd_payld_async         (1'b0),
    .wack_wr_ptr_async      (1'b0),
    .wack_rd_ptr_async      (wack_rd_ptr_async_unused),
    .rack_wr_ptr_async      (1'b0),
    .rack_rd_ptr_async      (rack_rd_ptr_async_unused),

    .dftrstdisable          (dftrstdisablem)
    );


//------------------------------------------------------------------------------
// OVL assertions
//------------------------------------------------------------------------------
`ifdef ASSERT_ON
`ifdef ARM_ASSERT_ON
`ifdef OVL_ASSERT_ON

// ACS_off start COVERAGE_OFF Do not collect coverage data on OVLs

  `include "std_ovl_defines.h"

  assert_always #(
    .severity_level (`OVL_FATAL),
    .property_type  (`OVL_ASSERT),
    .msg            ("Parameter out of specification: 32 <= ADDR_WIDTH <= 64"))
  assert_parameter_ADDR_WIDTH (
    .clk             (aclkm),
    .reset_n         (aresetnm),
    .test_expr       (
                      (ADDR_WIDTH >= 32) &&
                      (ADDR_WIDTH <= 64)
                     )
  );
  
  assert_always #(
    .severity_level (`OVL_FATAL),
    .property_type  (`OVL_ASSERT),
    .msg            ("Parameter out of specification: DATA_WIDTH must be one of {8, 16, 32, 64, 128, 256, 512, 1024}"))
  assert_parameter_DATA_WIDTH (
    .clk             (aclkm),
    .reset_n         (aresetnm),
    .test_expr       (
                      (DATA_WIDTH ==    8) ||
                      (DATA_WIDTH ==   16) ||
                      (DATA_WIDTH ==   32) ||
                      (DATA_WIDTH ==   64) ||
                      (DATA_WIDTH ==  128) ||
                      (DATA_WIDTH ==  256) ||
                      (DATA_WIDTH ==  512) ||
                      (DATA_WIDTH == 1024)
                     )
  );
  
  assert_always #(
    .severity_level (`OVL_FATAL),
    .property_type  (`OVL_ASSERT),
    .msg            ("Parameter out of specification: 0 <= AWID_WIDTH <= 32"))
  assert_parameter_AWID_WIDTH (
    .clk             (aclkm),
    .reset_n         (aresetnm),
    .test_expr       (
                      (AWID_WIDTH >=  0) &&
                      (AWID_WIDTH <= 32)
                     )
  );
  
  assert_always #(
    .severity_level (`OVL_FATAL),
    .property_type  (`OVL_ASSERT),
    .msg            ("Parameter out of specification: 0 <= ARID_WIDTH <= 32"))
  assert_parameter_ARID_WIDTH (
    .clk             (aclkm),
    .reset_n         (aresetnm),
    .test_expr       (
                      (ARID_WIDTH >=  0) &&
                      (ARID_WIDTH <= 32)
                     )
  );
  
  assert_always #(
    .severity_level (`OVL_FATAL),
    .property_type  (`OVL_ASSERT),
    .msg            ("Parameter out of specification: 0 <= AWUSER_WIDTH <= 256"))
  assert_parameter_AWUSER_WIDTH (
    .clk             (aclkm),
    .reset_n         (aresetnm),
    .test_expr       (
                      (AWUSER_WIDTH >=   0) &&
                      (AWUSER_WIDTH <= 256)
                     )
  );
  
  assert_always #(
    .severity_level (`OVL_FATAL),
    .property_type  (`OVL_ASSERT),
    .msg            ("Parameter out of specification: 0 <= WUSER_WIDTH <= 256"))
  assert_parameter_WUSER_WIDTH (
    .clk             (aclkm),
    .reset_n         (aresetnm),
    .test_expr       (
                      (WUSER_WIDTH >=   0) &&
                      (WUSER_WIDTH <= 256)
                     )
  );
  
  assert_always #(
    .severity_level (`OVL_FATAL),
    .property_type  (`OVL_ASSERT),
    .msg            ("Parameter out of specification: 0 <= BUSER_WIDTH <= 256"))
  assert_parameter_BUSER_WIDTH (
    .clk             (aclkm),
    .reset_n         (aresetnm),
    .test_expr       (
                      (BUSER_WIDTH >=   0) &&
                      (BUSER_WIDTH <= 256)
                     )
  );
  
  assert_always #(
    .severity_level (`OVL_FATAL),
    .property_type  (`OVL_ASSERT),
    .msg            ("Parameter out of specification: 0 <= ARUSER_WIDTH <= 256"))
  assert_parameter_ARUSER_WIDTH (
    .clk             (aclkm),
    .reset_n         (aresetnm),
    .test_expr       (
                      (ARUSER_WIDTH >=   0) &&
                      (ARUSER_WIDTH <= 256)
                     )
  );
  
  assert_always #(
    .severity_level (`OVL_FATAL),
    .property_type  (`OVL_ASSERT),
    .msg            ("Parameter out of specification: 0 <= RUSER_WIDTH <= 256"))
  assert_parameter_RUSER_WIDTH (
    .clk             (aclkm),
    .reset_n         (aresetnm),
    .test_expr       (
                      (RUSER_WIDTH >=   0) &&
                      (RUSER_WIDTH <= 256)
                     )
  );
  
  assert_always #(
    .severity_level (`OVL_FATAL),
    .property_type  (`OVL_ASSERT),
    .msg            ("Parameter out of specification: 2 <= AW_FIFO_DEPTH <= 10"))
  assert_parameter_AW_FIFO_DEPTH (
    .clk             (aclkm),
    .reset_n         (aresetnm),
    .test_expr       (
                      (AW_FIFO_DEPTH >=  2) &&
                      (AW_FIFO_DEPTH <= 10)
                     )
  );
  
  assert_always #(
    .severity_level (`OVL_FATAL),
    .property_type  (`OVL_ASSERT),
    .msg            ("Parameter out of specification: 2 <= W_FIFO_DEPTH <= 10"))
  assert_parameter_W_FIFO_DEPTH (
    .clk             (aclkm),
    .reset_n         (aresetnm),
    .test_expr       (
                      (W_FIFO_DEPTH >=  2) &&
                      (W_FIFO_DEPTH <= 10)
                     )
  );
  
  assert_always #(
    .severity_level (`OVL_FATAL),
    .property_type  (`OVL_ASSERT),
    .msg            ("Parameter out of specification: 2 <= B_FIFO_DEPTH <= 10"))
  assert_parameter_B_FIFO_DEPTH (
    .clk             (aclkm),
    .reset_n         (aresetnm),
    .test_expr       (
                      (B_FIFO_DEPTH >=  2) &&
                      (B_FIFO_DEPTH <= 10)
                     )
  );
  
  assert_always #(
    .severity_level (`OVL_FATAL),
    .property_type  (`OVL_ASSERT),
    .msg            ("Parameter out of specification: 2 <= AR_FIFO_DEPTH <= 10"))
  assert_parameter_AR_FIFO_DEPTH (
    .clk             (aclkm),
    .reset_n         (aresetnm),
    .test_expr       (
                      (AR_FIFO_DEPTH >=  2) &&
                      (AR_FIFO_DEPTH <= 10)
                     )
  );
  
  assert_always #(
    .severity_level (`OVL_FATAL),
    .property_type  (`OVL_ASSERT),
    .msg            ("Parameter out of specification: 2 <= R_FIFO_DEPTH <= 10"))
  assert_parameter_R_FIFO_DEPTH (
    .clk             (aclkm),
    .reset_n         (aresetnm),
    .test_expr       (
                      (R_FIFO_DEPTH >=  2) &&
                      (R_FIFO_DEPTH <= 10)
                     )
  );



// ACS_off end COVERAGE_OFF

`endif
`endif
`endif

endmodule

