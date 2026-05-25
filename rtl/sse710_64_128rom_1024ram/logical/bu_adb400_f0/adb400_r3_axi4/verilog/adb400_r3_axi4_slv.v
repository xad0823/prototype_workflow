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
// Checked In :  2016-02-10 15:33:14 +0000 (Wed, 10 Feb 2016)
// Revision : 206653
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_axi4_slv.v
//-----------------------------------------------------------------------------
// Purpose : Slave half of protocol/qvn config specific bridge
//-----------------------------------------------------------------------------


module adb400_r3_axi4_slv
  #(parameter
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
      B_OPREG             = 1,
      R_OPREG             = 1,
      SI_SYNC_LEVELS      = 2
  )
  (
    // Configuration inputs

    input  wire                 pwrq_permit_deny_sar_i,

    // Global signals
    input  wire                      aclks,
    input  wire                      aresetns,

    // Power state control
    input  wire                      pwrqreqns_i,
    output wire                      pwrqacceptns_o,
    output wire                      pwrqdenys_o,

    // Clock control
    input  wire                      clkqreqns_i,
    output wire                      clkqacceptns_o,
    output wire                      clkqdenys_o,

    // Clock requirement
    output wire                      clkqactives_o,

    // Power requirement
    output wire                      pwrqactives_o,

    // Wake-up
    input  wire                      wakeups_i,

    // AW channel signalling
    input  wire                      awvalids,
    output wire                      awreadys,
    input  wire [((AWUSER_WIDTH>0)?(AWUSER_WIDTH-1):0):0] awusers,
    input  wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] awids,
    input  wire [ADDR_WIDTH-1:0]     awaddrs,
    input  wire [3:0]                awregions,
    input  wire [7:0]                awlens,
    input  wire [2:0]                awsizes,
    input  wire [1:0]                awbursts,
    input  wire                      awlocks,
    input  wire [3:0]                awcaches,
    input  wire [2:0]                awprots,
    input  wire [3:0]                awqoss,

    // W channel signalling
    input  wire                      wvalids,
    output wire                      wreadys,
    input  wire [((WUSER_WIDTH>0)?(WUSER_WIDTH-1):0):0] wusers,
    input  wire [DATA_WIDTH-1:0]     wdatas,
    input  wire [(DATA_WIDTH/8)-1:0] wstrbs,
    input  wire                      wlasts,

    // B channel signalling
    output wire                      bvalids,
    input  wire                      breadys,
    output wire [((BUSER_WIDTH>0)?(BUSER_WIDTH-1):0):0] busers,
    output wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] bids,
    output wire [1:0]                bresps,

    // AR channel signalling
    input  wire                      arvalids,
    output wire                      arreadys,
    input  wire [((ARUSER_WIDTH>0)?(ARUSER_WIDTH-1):0):0] arusers,
    input  wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] arids,
    input  wire [ADDR_WIDTH-1:0]     araddrs,
    input  wire [3:0]                arregions,
    input  wire [7:0]                arlens,
    input  wire [2:0]                arsizes,
    input  wire [1:0]                arbursts,
    input  wire                      arlocks,
    input  wire [3:0]                arcaches,
    input  wire [2:0]                arprots,
    input  wire [3:0]                arqoss,

    // R channel signalling
    output wire                      rvalids,
    input  wire                      rreadys,
    output wire [((RUSER_WIDTH>0)?(RUSER_WIDTH-1):0):0] rusers,
    output wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] rids,
    output wire [DATA_WIDTH-1:0]     rdatas,
    output wire [1:0]                rresps,
    output wire                      rlasts,



    //
    // Asynchronous interfaces
    //

    // Cross-domain power state control
    output wire                   slvmustacceptreqn_async,
    output wire                   slvcandenyreqn_async,
    input  wire                   slvacceptn_async,
    input  wire                   slvdeny_async,

    // Cross-domain wakeup
    output wire                   si_to_mi_wakeup_async,
    input  wire                   mi_to_si_wakeup_async,


    // AW channel signalling
    output wire [AW_FIFO_DEPTH-1:0] aw_wr_ptr_async,
    input  wire [AW_FIFO_DEPTH-1:0] aw_rd_ptr_async,
    output wire [((aw_payload_width_fn(AWUSER_WIDTH,AWID_WIDTH,ADDR_WIDTH)+0)*AW_FIFO_DEPTH)-1:0] aw_payld_async,

    // W channel signalling
    output wire [ W_FIFO_DEPTH-1:0]  w_wr_ptr_async,
    input  wire [ W_FIFO_DEPTH-1:0]  w_rd_ptr_async,
    output wire [((w_payload_width_fn(WUSER_WIDTH,AWID_WIDTH,DATA_WIDTH)+0)* W_FIFO_DEPTH)-1:0] w_payld_async,

    // B channel signalling
    input  wire [ B_FIFO_DEPTH-1:0]  b_wr_ptr_async,
    output wire [ B_FIFO_DEPTH-1:0]  b_rd_ptr_async,
    input  wire [(b_payload_width_fn(BUSER_WIDTH,AWID_WIDTH)* B_FIFO_DEPTH)-1:0] b_payld_async,

    // AR channel signalling
    output wire [AR_FIFO_DEPTH-1:0] ar_wr_ptr_async,
    input  wire [AR_FIFO_DEPTH-1:0] ar_rd_ptr_async,
    output wire [((ar_payload_width_fn(ARUSER_WIDTH,ARID_WIDTH,ADDR_WIDTH)+0)*AR_FIFO_DEPTH)-1:0] ar_payld_async,

    // R channel signalling
    input  wire [ R_FIFO_DEPTH-1:0]  r_wr_ptr_async,
    output wire [ R_FIFO_DEPTH-1:0]  r_rd_ptr_async,
    input  wire [(r_payload_width_fn(RUSER_WIDTH,ARID_WIDTH,DATA_WIDTH)* R_FIFO_DEPTH)-1:0] r_payld_async,


    // Debug signalling
    input  wire                      dftrstdisables
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
               4 +            // awqos
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

  wire [AW_PAYLOAD_WIDTH-1:0] aw_payload_s;
  wire [ W_PAYLOAD_WIDTH-1:0]  w_payload_s;
  wire [ B_PAYLOAD_WIDTH-1:0]  b_payload_s;
  wire [AR_PAYLOAD_WIDTH-1:0] ar_payload_s;
  wire [ R_PAYLOAD_WIDTH-1:0]  r_payload_s;


  //-----------------------------------------------------
  //-----------------------------------------------------
  // Pack the individual signals into a payload for each channel
  //-----------------------------------------------------
  //-----------------------------------------------------

  // If signals can be parameterised away, conditionally assign them
  // to/from the bottom bits, so there is no need to calculate what
  // position they are in.

  // AW
  assign aw_payload_s[AW_PAYLOAD_WIDTH-1:(AWUSER_WIDTH+AWID_WIDTH)] = {
      awaddrs,
      awregions,
      awlens,
      awsizes,
      awlocks,
      awcaches,
      awprots,
      awqoss,    // 4b
      awbursts   // 2b
    };

  generate
    if (AWUSER_WIDTH>0)
      begin : g_assign_awuser
        assign aw_payload_s[0+:AWUSER_WIDTH] = awusers;
      end
    else
      begin : g_no_assign_awuser
        wire awusers_unused = awusers;
      end
    if (AWID_WIDTH>0)
      begin : g_assign_awid
        assign aw_payload_s[AWUSER_WIDTH+:AWID_WIDTH] = awids;
      end
    else
      begin : g_no_assign_awid
        wire awids_unused = awids;
      end
  endgenerate



  // W
  assign  w_payload_s[W_PAYLOAD_WIDTH-1:WUSER_WIDTH] = 
    {
      wdatas,
      wstrbs,
      wlasts    // 1b
    };

  generate
    if (WUSER_WIDTH>0)
      begin : g_assign_wuser
        assign w_payload_s[0+:WUSER_WIDTH] = wusers;
      end
    else
      begin : g_noassign_wuser
        wire wusers_unused = wusers;
      end
  endgenerate


  localparam WLAST_OFFSET        = 0+(WUSER_WIDTH);

  // B
  assign 
    {
      bresps
    } = b_payload_s[B_PAYLOAD_WIDTH-1:(BUSER_WIDTH+AWID_WIDTH)];

  generate
    if (BUSER_WIDTH>0)
      begin : g_buser_assign
        assign busers = b_payload_s[0+:BUSER_WIDTH];
      end
    else
      begin : g_buser_noassign
        assign busers = 1'b0;
      end
    if (AWID_WIDTH>0)
      begin : g_bid_assign
        assign bids = b_payload_s[BUSER_WIDTH+:AWID_WIDTH];
      end
    else
      begin : g_bid_noassign
        assign bids = 1'b0;
      end
  endgenerate

  // AR
  assign ar_payload_s[AR_PAYLOAD_WIDTH-1:(ARUSER_WIDTH+ARID_WIDTH)] =
    {
      arregions,
      arlens,
      arsizes,
      arlocks,
      arcaches,
      arprots, 
      araddrs,
      arqoss,   // 4b
      arbursts  // 2b
    };

  generate
    if (ARUSER_WIDTH>0)
      begin : g_assign_aruser
        assign ar_payload_s[0+:ARUSER_WIDTH] = arusers;
      end
    else
      begin : g_no_assign_aruser
        wire arusers_unused = arusers;
      end
    if (ARID_WIDTH>0)
      begin : g_assign_arid
        assign ar_payload_s[ARUSER_WIDTH+:ARID_WIDTH] = arids;
      end
    else
      begin : g_no_assign_arid
        wire arids_unused = arids;
      end
  endgenerate




  // R
  assign 
    {
      rdatas,
      rresps,
      rlasts
    } = r_payload_s[R_PAYLOAD_WIDTH-1:(RUSER_WIDTH+ARID_WIDTH)];

  generate
    if (RUSER_WIDTH>0)
      begin : g_ruser_assign
        assign rusers = r_payload_s[0+:RUSER_WIDTH];
      end
    else
      begin : g_ruser_noassign
        assign rusers = 1'b0;
      end
    if (ARID_WIDTH>0)
      begin : g_rid_assign
        assign rids = r_payload_s[RUSER_WIDTH+:ARID_WIDTH];
      end
    else
      begin : g_rid_noassign
        assign rids = 1'b0;
      end
  endgenerate

  localparam RLAST_OFFSET        = (RUSER_WIDTH+ARID_WIDTH);




  // Declare signals to connect to unused ports so no port is unconnected
  wire wakeups_o_unused;
  wire acvalids_unused;
  wire ac_payload_s_unused;
  wire crreadys_unused;
  wire cdreadys_unused;
  wire varreadys_unused;
  wire vawreadys_unused;
  wire vwreadys_unused;
  wire p_wr_ptr_async_unused;
  wire p_payld_async_unused;
  wire t_rd_ptr_async_unused;
  wire ac_rd_ptr_async_unused;
  wire cr_wr_ptr_async_unused;
  wire cr_payld_async_unused;
  wire cd_wr_ptr_async_unused;
  wire cd_payld_async_unused;
  wire wack_wr_ptr_async_unused;
  wire rack_wr_ptr_async_unused;

  adb400_r3_slv_core
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
      .B_OPREG          (B_OPREG),
      .R_OPREG          (R_OPREG),
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
      .SYNC_LEVELS      (SI_SYNC_LEVELS)
    )
  u_slv
    (
    .var_prealloc_sar_i     (1'b0),
    .var_id_sar_i           (1'b0),
    .vaw_prealloc_sar_i     (1'b0),
    .vaw_id_sar_i           (1'b0),
    .pwrq_permit_deny_sar_i (pwrq_permit_deny_sar_i),

    .aclk                   (aclks),                   
    .aresetn                (aresetns),

    .clkqreqn_i             (clkqreqns_i),
    .clkqacceptn_o          (clkqacceptns_o),
    .clkqdeny_o             (clkqdenys_o),
    .clkqactive_o           (clkqactives_o),
    .pwrqreqn_i             (pwrqreqns_i),
    .pwrqacceptn_o          (pwrqacceptns_o),
    .pwrqdeny_o             (pwrqdenys_o),
    .pwrqactive_o           (pwrqactives_o),

    .wakeup_i               (wakeups_i),
    .wakeup_o               (wakeups_o_unused),
    .awvalid                (awvalids),
    .awready                (awreadys),
    .aw_payld               (aw_payload_s),
    .wvalid                 (wvalids),
    .wready                 (wreadys),
    .w_payld                (w_payload_s),
    .bvalid                 (bvalids),
    .bready                 (breadys),
    .b_payld                (b_payload_s),
    .arvalid                (arvalids),
    .arready                (arreadys),
    .ar_payld               (ar_payload_s),
    .rvalid                 (rvalids),
    .rready                 (rreadys),
    .r_payld                (r_payload_s),
    .acvalid                (acvalids_unused),
    .acready                (1'b0),
    .ac_payld               (ac_payload_s_unused),
    .crvalid                (1'b0),
    .crready                (crreadys_unused),
    .cr_payld               (1'b0),
    .cdvalid                (1'b0),
    .cdready                (cdreadys_unused),
    .cd_payld               (1'b0),
    .wack                   (1'b0),
    .rack                   (1'b0),
    .varvalid               (1'b0),
    .varready               (varreadys_unused),
    .varqos                 (1'b0),
    .vawvalid               (1'b0),
    .vawready               (vawreadys_unused),
    .vawqos                 (1'b0),
    .vwvalid                (1'b0),
    .vwready                (vwreadys_unused),

    .slvmustacceptreqn_async (slvmustacceptreqn_async),
    .slvcandenyreqn_async   (slvcandenyreqn_async),
    .slvacceptn_async       (slvacceptn_async),
    .slvdeny_async          (slvdeny_async),
    .si_to_mi_wakeup_async  (si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async  (mi_to_si_wakeup_async),

    .p_wr_ptr_async         (p_wr_ptr_async_unused),
    .p_rd_ptr_async         (1'b0),
    .p_payld_async          (p_payld_async_unused),
    .t_wr_ptr_async         (1'b0),
    .t_rd_ptr_async         (t_rd_ptr_async_unused),
    .t_payld_async          (1'b0),
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
    .ac_wr_ptr_async        (1'b0),
    .ac_rd_ptr_async        (ac_rd_ptr_async_unused),
    .ac_payld_async         (1'b0),
    .cr_wr_ptr_async        (cr_wr_ptr_async_unused),
    .cr_rd_ptr_async        (1'b0),
    .cr_payld_async         (cr_payld_async_unused),
    .cd_wr_ptr_async        (cd_wr_ptr_async_unused),
    .cd_rd_ptr_async        (1'b0),
    .cd_payld_async         (cd_payld_async_unused),
    .wack_wr_ptr_async      (wack_wr_ptr_async_unused),
    .wack_rd_ptr_async      (1'b0),
    .rack_wr_ptr_async      (rack_wr_ptr_async_unused),
    .rack_rd_ptr_async      (1'b0),

    .dftrstdisable          (dftrstdisables)
    );


//------------------------------------------------------------------------------
// OVL assertionsin
//------------------------------------------------------------------------------
`ifdef ASSERT_ON
`ifdef ARM_ASSERT_ON
`ifdef OVL_ASSERT_ON

// ACS_off start COVERAGE_OFF Do not collect coverage data on OVLs

  `include "std_ovl_defines.h"

  wire powered = 1'b1;
  reg  has_been_reset_if_not_x;
  always @(posedge powered or negedge aresetns)
    if ((has_been_reset_if_not_x === 1'bx) & (aresetns === 1'b0))
      has_been_reset_if_not_x <= 1'b1;

  assert_always #(
    .severity_level (`OVL_FATAL),
    .property_type  (`OVL_ASSERT),
    .msg            ("Parameter out of specification: 32 <= ADDR_WIDTH <= 64"))
  assert_parameter_ADDR_WIDTH (
    .clk             (aclks),
    .reset_n         (aresetns),
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
    .clk             (aclks),
    .reset_n         (aresetns),
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
    .clk             (aclks),
    .reset_n         (aresetns),
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
    .clk             (aclks),
    .reset_n         (aresetns),
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
    .clk             (aclks),
    .reset_n         (aresetns),
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
    .clk             (aclks),
    .reset_n         (aresetns),
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
    .clk             (aclks),
    .reset_n         (aresetns),
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
    .clk             (aclks),
    .reset_n         (aresetns),
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
    .clk             (aclks),
    .reset_n         (aresetns),
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
    .clk             (aclks),
    .reset_n         (aresetns),
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
    .clk             (aclks),
    .reset_n         (aresetns),
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
    .clk             (aclks),
    .reset_n         (aresetns),
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
    .clk             (aclks),
    .reset_n         (aresetns),
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
    .clk             (aclks),
    .reset_n         (aresetns),
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

