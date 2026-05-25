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
// Checked In :  2016-02-05 18:54:56 +0000 (Fri, 05 Feb 2016)
// Revision : 206478
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_axi4.v
//-----------------------------------------------------------------------------
// Purpose : Full, protocol/qvn config specific bridge
//-----------------------------------------------------------------------------


module adb400_r3_axi4
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

      AW_OPREG            = 1,
      W_OPREG             = 1,
      B_OPREG             = 1,
      AR_OPREG            = 1,
      R_OPREG             = 1,

      SI_SYNC_LEVELS      = 2,
      MI_SYNC_LEVELS      = 2
  )
  (
    //
    // SI side
    //

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
    input  wire [((AWUSER_WIDTH>0)?(AWUSER_WIDTH-1):0):0] awusers,

    // W channel signalling
    input  wire                      wvalids,
    output wire                      wreadys,
    input  wire [DATA_WIDTH-1:0]     wdatas,
    input  wire [(DATA_WIDTH/8)-1:0] wstrbs,
    input  wire                      wlasts,
    input  wire [((WUSER_WIDTH>0)?(WUSER_WIDTH-1):0):0] wusers,

    // B channel signalling
    output wire                      bvalids,
    input  wire                      breadys,
    output wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] bids,
    output wire [1:0]                bresps,
    output wire [((BUSER_WIDTH>0)?(BUSER_WIDTH-1):0):0] busers,

    // AR channel signalling
    input  wire                      arvalids,
    output wire                      arreadys,
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
    input  wire [((ARUSER_WIDTH>0)?(ARUSER_WIDTH-1):0):0] arusers,

    // R channel signalling
    output wire                      rvalids,
    input  wire                      rreadys,
    output wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] rids,
    output wire [DATA_WIDTH-1:0]     rdatas,
    output wire [1:0]                rresps,
    output wire                      rlasts,
    output wire [((RUSER_WIDTH>0)?(RUSER_WIDTH-1):0):0] rusers,



    // Debug signalling
    input  wire                      dftrstdisables,

    //
    // MI side
    //

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

  // -----------------------------------------------------
  // Wires between halves
  // -----------------------------------------------------

  // CLKQ/PWRQ inter-domain communication
  wire slvmustacceptreqn_async;
  wire slvcandenyreqn_async;
  wire slvacceptn_async;
  wire slvdeny_async;
  wire si_to_mi_wakeup_async;
  wire mi_to_si_wakeup_async;


  // AW channel signalling
  wire [AW_FIFO_DEPTH-1:0] aw_wr_ptr_async;
  wire [AW_FIFO_DEPTH-1:0] aw_rd_ptr_async;
  wire [((AW_PAYLOAD_WIDTH+AW_VN)*AW_FIFO_DEPTH)-1:0] aw_payld_async;

  // W channel signalling
  wire [ W_FIFO_DEPTH-1:0]  w_wr_ptr_async;
  wire [ W_FIFO_DEPTH-1:0]  w_rd_ptr_async;
  wire [(( W_PAYLOAD_WIDTH+AW_VN)* W_FIFO_DEPTH)-1:0] w_payld_async;

  // B channel signalling
  wire [ B_FIFO_DEPTH-1:0]  b_wr_ptr_async;
  wire [ B_FIFO_DEPTH-1:0]  b_rd_ptr_async;
  wire [( B_PAYLOAD_WIDTH* B_FIFO_DEPTH)-1:0] b_payld_async;

  // AR channel signalling
  wire [AR_FIFO_DEPTH-1:0] ar_wr_ptr_async;
  wire [AR_FIFO_DEPTH-1:0] ar_rd_ptr_async;
  wire [((AR_PAYLOAD_WIDTH+AR_VN)*AR_FIFO_DEPTH)-1:0] ar_payld_async;

  // R channel signalling
  wire [ R_FIFO_DEPTH-1:0]  r_wr_ptr_async;
  wire [ R_FIFO_DEPTH-1:0]  r_rd_ptr_async;
  wire [( R_PAYLOAD_WIDTH* R_FIFO_DEPTH)-1:0] r_payld_async;


  //-----------------------------------------------------
  //-----------------------------------------------------
  // Slave interface half
  //-----------------------------------------------------
  //-----------------------------------------------------

  adb400_r3_axi4_slv
    #(
      .ADDR_WIDTH       (ADDR_WIDTH),
      .DATA_WIDTH       (DATA_WIDTH),
      .AWID_WIDTH       (AWID_WIDTH),
      .ARID_WIDTH       (ARID_WIDTH),
      .AWUSER_WIDTH     (AWUSER_WIDTH),
      .WUSER_WIDTH      (WUSER_WIDTH),
      .BUSER_WIDTH      (BUSER_WIDTH),
      .ARUSER_WIDTH     (ARUSER_WIDTH),
      .RUSER_WIDTH      (RUSER_WIDTH),
      .AW_FIFO_DEPTH    (AW_FIFO_DEPTH),
      .W_FIFO_DEPTH     (W_FIFO_DEPTH),
      .B_FIFO_DEPTH     (B_FIFO_DEPTH),
      .AR_FIFO_DEPTH    (AR_FIFO_DEPTH),
      .R_FIFO_DEPTH     (R_FIFO_DEPTH),
      .B_OPREG          (B_OPREG),
      .R_OPREG          (R_OPREG),
      .SI_SYNC_LEVELS   (SI_SYNC_LEVELS)
    )
  u_slv
    (
    .pwrq_permit_deny_sar_i (pwrq_permit_deny_sar_i),

    .aclks                  (aclks),                   
    .aresetns               (aresetns),

    .clkqreqns_i            (clkqreqns_i),
    .clkqacceptns_o         (clkqacceptns_o),
    .clkqdenys_o            (clkqdenys_o),
    .clkqactives_o          (clkqactives_o),
    .pwrqreqns_i            (pwrqreqns_i),
    .pwrqacceptns_o         (pwrqacceptns_o),
    .pwrqdenys_o            (pwrqdenys_o),
    .pwrqactives_o          (pwrqactives_o),

    .wakeups_i              (wakeups_i),

    .awvalids               (awvalids),
    .awreadys               (awreadys),
    .awusers                (awusers),
    .awids                  (awids),
    .awaddrs                (awaddrs),
    .awregions              (awregions),
    .awlens                 (awlens),
    .awsizes                (awsizes),
    .awlocks                (awlocks),
    .awcaches               (awcaches),
    .awprots                (awprots),
    .awqoss                 (awqoss),
    .awbursts               (awbursts),
    .wvalids                (wvalids),
    .wreadys                (wreadys),
    .wusers                 (wusers),
    .wdatas                 (wdatas),
    .wstrbs                 (wstrbs),
    .wlasts                 (wlasts),
    .bvalids                (bvalids),
    .breadys                (breadys),
    .busers                 (busers),
    .bids                   (bids),
    .bresps                 (bresps),
    .arvalids               (arvalids),
    .arreadys               (arreadys),
    .arusers                (arusers),
    .arids                  (arids),
    .araddrs                (araddrs),
    .arregions              (arregions),
    .arlens                 (arlens),
    .arsizes                (arsizes),
    .arlocks                (arlocks),
    .arcaches               (arcaches),
    .arprots                (arprots),
    .arqoss                 (arqoss),
    .arbursts               (arbursts),
    .rvalids                (rvalids),
    .rreadys                (rreadys),
    .rusers                 (rusers),
    .rids                   (rids),
    .rdatas                 (rdatas),
    .rresps                 (rresps),
    .rlasts                 (rlasts),



    .slvmustacceptreqn_async (slvmustacceptreqn_async),
    .slvcandenyreqn_async   (slvcandenyreqn_async),
    .slvacceptn_async       (slvacceptn_async),
    .slvdeny_async          (slvdeny_async),
    .si_to_mi_wakeup_async  (si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async  (mi_to_si_wakeup_async),

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

    .dftrstdisables         (dftrstdisables)
    );


  //-----------------------------------------------------
  //-----------------------------------------------------
  // Master interface half
  //-----------------------------------------------------
  //-----------------------------------------------------

  adb400_r3_axi4_mst
    #(
      .ADDR_WIDTH       (ADDR_WIDTH),
      .DATA_WIDTH       (DATA_WIDTH),
      .AWID_WIDTH       (AWID_WIDTH),
      .ARID_WIDTH       (ARID_WIDTH),
      .AWUSER_WIDTH     (AWUSER_WIDTH),
      .WUSER_WIDTH      (WUSER_WIDTH),
      .BUSER_WIDTH      (BUSER_WIDTH),
      .ARUSER_WIDTH     (ARUSER_WIDTH),
      .RUSER_WIDTH      (RUSER_WIDTH),
      .AW_FIFO_DEPTH    (AW_FIFO_DEPTH),
      .W_FIFO_DEPTH     (W_FIFO_DEPTH),
      .B_FIFO_DEPTH     (B_FIFO_DEPTH),
      .AR_FIFO_DEPTH    (AR_FIFO_DEPTH),
      .R_FIFO_DEPTH     (R_FIFO_DEPTH),
      .AW_OPREG         (AW_OPREG),
      .W_OPREG          (W_OPREG),
      .AR_OPREG         (AR_OPREG),
      .MI_SYNC_LEVELS   (MI_SYNC_LEVELS)
    )
  u_mst
    (

    .aclkm                  (aclkm),                   
    .aresetnm               (aresetnm),

    .clkqreqnm_i            (clkqreqnm_i),
    .clkqacceptnm_o         (clkqacceptnm_o),
    .clkqdenym_o            (clkqdenym_o),
    .clkqactivem_o          (clkqactivem_o),

    .wakeupm_o              (wakeupm_o),

    .awvalidm               (awvalidm),
    .awreadym               (awreadym),
    .awuserm                (awuserm),
    .awidm                  (awidm),
    .awaddrm                (awaddrm),
    .awregionm              (awregionm),
    .awlenm                 (awlenm),
    .awsizem                (awsizem),
    .awlockm                (awlockm),
    .awcachem               (awcachem),
    .awprotm                (awprotm),
    .awqosm                 (awqosm),
    .awburstm               (awburstm),
    .wvalidm                (wvalidm),
    .wreadym                (wreadym),
    .wuserm                 (wuserm),
    .wdatam                 (wdatam),
    .wstrbm                 (wstrbm),
    .wlastm                 (wlastm),
    .bvalidm                (bvalidm),
    .breadym                (breadym),
    .buserm                 (buserm),
    .bidm                   (bidm),
    .brespm                 (brespm),
    .arvalidm               (arvalidm),
    .arreadym               (arreadym),
    .aruserm                (aruserm),
    .aridm                  (aridm),
    .araddrm                (araddrm),
    .arregionm              (arregionm),
    .arlenm                 (arlenm),
    .arsizem                (arsizem),
    .arlockm                (arlockm),
    .arcachem               (arcachem),
    .arprotm                (arprotm),
    .arqosm                 (arqosm),
    .arburstm               (arburstm),
    .rvalidm                (rvalidm),
    .rreadym                (rreadym),
    .ruserm                 (ruserm),
    .ridm                   (ridm),
    .rdatam                 (rdatam),
    .rrespm                 (rrespm),
    .rlastm                 (rlastm),



    .slvmustacceptreqn_async (slvmustacceptreqn_async),
    .slvcandenyreqn_async   (slvcandenyreqn_async),
    .slvacceptn_async       (slvacceptn_async),
    .slvdeny_async          (slvdeny_async),
    .si_to_mi_wakeup_async  (si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async  (mi_to_si_wakeup_async),

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


    .dftrstdisablem         (dftrstdisablem)
    );

endmodule

