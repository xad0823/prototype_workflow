//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------


module nic400_switch3_ml_blayer_0_sse710_main
  (

    awuser_s,
    awid_s,
    awaddr_s,
    awlen_s,
    awsize_s,
    awburst_s,
    awlock_s,
    awcache_s,
    awprot_s,
    awvalid_s,
    awvalid_vect_s,
    awready_s,
    aw_qv_s,
   
    wdata_s,
    wstrb_s,
    wlast_s,
    wvalid_s,
    wready_s,

    buser_s,
    bid_s,
    bresp_s,
    bvalid_s,
    bready_s,

    aruser_s,
    arid_s,
    araddr_s,
    arlen_s,
    arsize_s,
    arburst_s,
    arlock_s,
    arcache_s,
    arprot_s,
    arvalid_s,
    arvalid_vect_s,
    arready_s,
    ar_qv_s,
   
    ruser_s,
    rid_s,
    rdata_s,
    rresp_s,
    rlast_s,
    rvalid_s,
    rready_s,



    awuser_m0,
    awid_m0,
    awaddr_m0,
    awlen_m0,
    awsize_m0,
    awburst_m0,
    awlock_m0,
    awcache_m0,
    awprot_m0,
    awvalid_m0,
    awvalid_vect_m0,
    awready_m0,
    aw_qv_m0,
   
    wdata_m0,
    wstrb_m0,
    wlast_m0,
    wvalid_m0,
    wready_m0,

    buser_m0,
    bid_m0,
    bresp_m0,
    bvalid_m0,
    bready_m0,

    aruser_m0,
    arid_m0,
    araddr_m0,
    arlen_m0,
    arsize_m0,
    arburst_m0,
    arlock_m0,
    arcache_m0,
    arprot_m0,
    arvalid_m0,
    arvalid_vect_m0,
    arready_m0,
    ar_qv_m0,
   
    ruser_m0,
    rid_m0,
    rdata_m0,
    rresp_m0,
    rlast_m0,
    rvalid_m0,
    rready_m0,

    awuser_m1,
    awid_m1,
    awaddr_m1,
    awlen_m1,
    awsize_m1,
    awburst_m1,
    awlock_m1,
    awcache_m1,
    awprot_m1,
    awvalid_m1,
    awvalid_vect_m1,
    awready_m1,
    aw_qv_m1,
   
    wdata_m1,
    wstrb_m1,
    wlast_m1,
    wvalid_m1,
    wready_m1,

    buser_m1,
    bid_m1,
    bresp_m1,
    bvalid_m1,
    bready_m1,

    aruser_m1,
    arid_m1,
    araddr_m1,
    arlen_m1,
    arsize_m1,
    arburst_m1,
    arlock_m1,
    arcache_m1,
    arprot_m1,
    arvalid_m1,
    arvalid_vect_m1,
    arready_m1,
    ar_qv_m1,
   
    ruser_m1,
    rid_m1,
    rdata_m1,
    rresp_m1,
    rlast_m1,
    rvalid_m1,
    rready_m1,

    awuser_m2,
    awid_m2,
    awaddr_m2,
    awlen_m2,
    awsize_m2,
    awburst_m2,
    awlock_m2,
    awcache_m2,
    awprot_m2,
    awvalid_m2,
    awvalid_vect_m2,
    awready_m2,
    aw_qv_m2,
   
    wdata_m2,
    wstrb_m2,
    wlast_m2,
    wvalid_m2,
    wready_m2,

    buser_m2,
    bid_m2,
    bresp_m2,
    bvalid_m2,
    bready_m2,

    aruser_m2,
    arid_m2,
    araddr_m2,
    arlen_m2,
    arsize_m2,
    arburst_m2,
    arlock_m2,
    arcache_m2,
    arprot_m2,
    arvalid_m2,
    arvalid_vect_m2,
    arready_m2,
    ar_qv_m2,
   
    ruser_m2,
    rid_m2,
    rdata_m2,
    rresp_m2,
    rlast_m2,
    rvalid_m2,
    rready_m2,

    awuser_m3,
    awid_m3,
    awaddr_m3,
    awlen_m3,
    awsize_m3,
    awburst_m3,
    awlock_m3,
    awcache_m3,
    awprot_m3,
    awvalid_m3,
    awvalid_vect_m3,
    awready_m3,
    aw_qv_m3,
   
    wdata_m3,
    wstrb_m3,
    wlast_m3,
    wvalid_m3,
    wready_m3,

    buser_m3,
    bid_m3,
    bresp_m3,
    bvalid_m3,
    bready_m3,

    aruser_m3,
    arid_m3,
    araddr_m3,
    arlen_m3,
    arsize_m3,
    arburst_m3,
    arlock_m3,
    arcache_m3,
    arprot_m3,
    arvalid_m3,
    arvalid_vect_m3,
    arready_m3,
    ar_qv_m3,
   
    ruser_m3,
    rid_m3,
    rdata_m3,
    rresp_m3,
    rlast_m3,
    rvalid_m3,
    rready_m3,
    aclk,
    aresetn
  );



  input [9:0]       awuser_s;
  input [11:0]       awid_s;
  input [39:0]      awaddr_s;
  input [7:0]       awlen_s;
  input [2:0]       awsize_s;
  input [1:0]       awburst_s;
  input             awlock_s;
  input [3:0]       awcache_s;
  input [2:0]       awprot_s;
  input             awvalid_s;
  input [3:0]            awvalid_vect_s;
  output            awready_s;
  input [3:0]       aw_qv_s;

  input  [31:0]     wdata_s;
  input  [3:0]      wstrb_s;
  input             wlast_s;
  input             wvalid_s;
  output            wready_s;

  output                 buser_s;
  output [11:0]      bid_s;
  output [1:0]      bresp_s;
  output            bvalid_s;
  input             bready_s;

  input [9:0]       aruser_s;
  input [11:0]       arid_s;
  input [39:0]      araddr_s;
  input [7:0]       arlen_s;
  input [2:0]       arsize_s;
  input [1:0]       arburst_s;
  input             arlock_s;
  input [3:0]       arcache_s;
  input [2:0]       arprot_s;
  input             arvalid_s;
  input [3:0]            arvalid_vect_s;
  output            arready_s;
  input [3:0]       ar_qv_s;

  output            ruser_s;
  output [11:0]      rid_s;
  output [31:0]     rdata_s;
  output [1:0]      rresp_s;
  output            rlast_s;
  output            rvalid_s;
  input             rready_s;


  output [9:0]                      awuser_m0;
  output [11:0]      awid_m0;
  output [39:0]     awaddr_m0;
  output [7:0]      awlen_m0;
  output [2:0]      awsize_m0;
  output [1:0]      awburst_m0;
  output            awlock_m0;
  output [3:0]      awcache_m0;
  output [2:0]      awprot_m0;
  output            awvalid_m0;
  output           awvalid_vect_m0;
  input             awready_m0;
  output [3:0]      aw_qv_m0;
   
  output  [31:0]    wdata_m0;
  output  [3:0]     wstrb_m0;
  output            wlast_m0;
  output            wvalid_m0;
  input             wready_m0;

  input                  buser_m0;
  input [11:0]       bid_m0;
  input [1:0]       bresp_m0;
  input             bvalid_m0;
  output            bready_m0;

  output  [9:0]          aruser_m0;
  output  [11:0]     arid_m0;
  output  [39:0]    araddr_m0;
  output  [7:0]     arlen_m0;
  output  [2:0]     arsize_m0;
  output  [1:0]     arburst_m0;
  output            arlock_m0;
  output  [3:0]     arcache_m0;
  output  [2:0]     arprot_m0;
  output            arvalid_m0;
  output            arvalid_vect_m0;
  input             arready_m0;
  output  [3:0]     ar_qv_m0;
   
  input                  ruser_m0;
  input [11:0]       rid_m0;
  input [31:0]      rdata_m0;
  input [1:0]       rresp_m0;
  input             rlast_m0;
  input             rvalid_m0;
  output            rready_m0;


  output [9:0]                      awuser_m1;
  output [11:0]      awid_m1;
  output [39:0]     awaddr_m1;
  output [7:0]      awlen_m1;
  output [2:0]      awsize_m1;
  output [1:0]      awburst_m1;
  output            awlock_m1;
  output [3:0]      awcache_m1;
  output [2:0]      awprot_m1;
  output            awvalid_m1;
  output           awvalid_vect_m1;
  input             awready_m1;
  output [3:0]      aw_qv_m1;
   
  output  [31:0]    wdata_m1;
  output  [3:0]     wstrb_m1;
  output            wlast_m1;
  output            wvalid_m1;
  input             wready_m1;

  input                  buser_m1;
  input [11:0]       bid_m1;
  input [1:0]       bresp_m1;
  input             bvalid_m1;
  output            bready_m1;

  output  [9:0]          aruser_m1;
  output  [11:0]     arid_m1;
  output  [39:0]    araddr_m1;
  output  [7:0]     arlen_m1;
  output  [2:0]     arsize_m1;
  output  [1:0]     arburst_m1;
  output            arlock_m1;
  output  [3:0]     arcache_m1;
  output  [2:0]     arprot_m1;
  output            arvalid_m1;
  output            arvalid_vect_m1;
  input             arready_m1;
  output  [3:0]     ar_qv_m1;
   
  input                  ruser_m1;
  input [11:0]       rid_m1;
  input [31:0]      rdata_m1;
  input [1:0]       rresp_m1;
  input             rlast_m1;
  input             rvalid_m1;
  output            rready_m1;


  output [9:0]                      awuser_m2;
  output [11:0]      awid_m2;
  output [39:0]     awaddr_m2;
  output [7:0]      awlen_m2;
  output [2:0]      awsize_m2;
  output [1:0]      awburst_m2;
  output            awlock_m2;
  output [3:0]      awcache_m2;
  output [2:0]      awprot_m2;
  output            awvalid_m2;
  output           awvalid_vect_m2;
  input             awready_m2;
  output [3:0]      aw_qv_m2;
   
  output  [31:0]    wdata_m2;
  output  [3:0]     wstrb_m2;
  output            wlast_m2;
  output            wvalid_m2;
  input             wready_m2;

  input                  buser_m2;
  input [11:0]       bid_m2;
  input [1:0]       bresp_m2;
  input             bvalid_m2;
  output            bready_m2;

  output  [9:0]          aruser_m2;
  output  [11:0]     arid_m2;
  output  [39:0]    araddr_m2;
  output  [7:0]     arlen_m2;
  output  [2:0]     arsize_m2;
  output  [1:0]     arburst_m2;
  output            arlock_m2;
  output  [3:0]     arcache_m2;
  output  [2:0]     arprot_m2;
  output            arvalid_m2;
  output            arvalid_vect_m2;
  input             arready_m2;
  output  [3:0]     ar_qv_m2;
   
  input                  ruser_m2;
  input [11:0]       rid_m2;
  input [31:0]      rdata_m2;
  input [1:0]       rresp_m2;
  input             rlast_m2;
  input             rvalid_m2;
  output            rready_m2;


  output [9:0]                      awuser_m3;
  output [11:0]      awid_m3;
  output [39:0]     awaddr_m3;
  output [7:0]      awlen_m3;
  output [2:0]      awsize_m3;
  output [1:0]      awburst_m3;
  output            awlock_m3;
  output [3:0]      awcache_m3;
  output [2:0]      awprot_m3;
  output            awvalid_m3;
  output           awvalid_vect_m3;
  input             awready_m3;
  output [3:0]      aw_qv_m3;
   
  output  [31:0]    wdata_m3;
  output  [3:0]     wstrb_m3;
  output            wlast_m3;
  output            wvalid_m3;
  input             wready_m3;

  input                  buser_m3;
  input [11:0]       bid_m3;
  input [1:0]       bresp_m3;
  input             bvalid_m3;
  output            bready_m3;

  output  [9:0]          aruser_m3;
  output  [11:0]     arid_m3;
  output  [39:0]    araddr_m3;
  output  [7:0]     arlen_m3;
  output  [2:0]     arsize_m3;
  output  [1:0]     arburst_m3;
  output            arlock_m3;
  output  [3:0]     arcache_m3;
  output  [2:0]     arprot_m3;
  output            arvalid_m3;
  output            arvalid_vect_m3;
  input             arready_m3;
  output  [3:0]     ar_qv_m3;
   
  input                  ruser_m3;
  input [11:0]       rid_m3;
  input [31:0]      rdata_m3;
  input [1:0]       rresp_m3;
  input             rlast_m3;
  input             rvalid_m3;
  output            rready_m3;

  input             aclk;
  input             aresetn;


  wire [3:0]           aw_enable;
  wire [3:0]           awready_s_int;
  wire [3:0]           wready_s_int;
  wire [3:0]           arready_s_int;
  wire [3:0]           awsel;
  wire [3:0]           arsel;
  wire [3:0]           tt_enable_wr;
  wire [3:0]           wr_enable;
  wire [3:0]           tt_enable_rd;
  wire [3:0]           buser_s_int;
  wire [3:0]           bvalid_s_int;
  wire [47:0]           bid_s_int;
  wire [7:0]           bresp_s_int;
  wire [3:0]           ruser_s_int;
  wire [3:0]           rvalid_s_int;
  wire [3:0]           rlast_s_int;
  wire [47:0]           rid_s_int;
  wire [127:0]           rdata_s_int;
  wire [7:0]           rresp_s_int;




  assign awuser_m0 = awuser_s;
  assign awid_m0 = awid_s;
  assign awaddr_m0 = awaddr_s;
  assign awlen_m0 = awlen_s;
  assign awsize_m0 = awsize_s;
  assign awburst_m0 = awburst_s;
  assign awlock_m0 = awlock_s;
  assign awcache_m0 = awcache_s;
  assign awprot_m0 = awprot_s;
  assign aw_qv_m0 = aw_qv_s;
  assign awvalid_m0 = awvalid_s & aw_enable[0];
  assign awvalid_vect_m0 = awvalid_vect_s[0] & aw_enable[0]; 

  assign awuser_m1 = awuser_s;
  assign awid_m1 = awid_s;
  assign awaddr_m1 = awaddr_s;
  assign awlen_m1 = awlen_s;
  assign awsize_m1 = awsize_s;
  assign awburst_m1 = awburst_s;
  assign awlock_m1 = awlock_s;
  assign awcache_m1 = awcache_s;
  assign awprot_m1 = awprot_s;
  assign aw_qv_m1 = aw_qv_s;
  assign awvalid_m1 = awvalid_s & aw_enable[1];
  assign awvalid_vect_m1 = awvalid_vect_s[1] & aw_enable[1]; 

  assign awuser_m2 = awuser_s;
  assign awid_m2 = awid_s;
  assign awaddr_m2 = awaddr_s;
  assign awlen_m2 = awlen_s;
  assign awsize_m2 = awsize_s;
  assign awburst_m2 = awburst_s;
  assign awlock_m2 = awlock_s;
  assign awcache_m2 = awcache_s;
  assign awprot_m2 = awprot_s;
  assign aw_qv_m2 = aw_qv_s;
  assign awvalid_m2 = awvalid_s & aw_enable[2];
  assign awvalid_vect_m2 = awvalid_vect_s[2] & aw_enable[2]; 

  assign awuser_m3 = awuser_s;
  assign awid_m3 = awid_s;
  assign awaddr_m3 = awaddr_s;
  assign awlen_m3 = awlen_s;
  assign awsize_m3 = awsize_s;
  assign awburst_m3 = awburst_s;
  assign awlock_m3 = awlock_s;
  assign awcache_m3 = awcache_s;
  assign awprot_m3 = awprot_s;
  assign aw_qv_m3 = aw_qv_s;
  assign awvalid_m3 = awvalid_s & aw_enable[3];
  assign awvalid_vect_m3 = awvalid_vect_s[3] & aw_enable[3]; 

  assign awready_s_int[0] = awready_m0 & aw_enable[0];
  assign awready_s_int[1] = awready_m1 & aw_enable[1];
  assign awready_s_int[2] = awready_m2 & aw_enable[2];
  assign awready_s_int[3] = awready_m3 & aw_enable[3]; 
  assign awready_s = |awready_s_int;


  assign aruser_m0 = aruser_s;
  assign arid_m0 = arid_s;
  assign araddr_m0 = araddr_s;
  assign arlen_m0 = arlen_s;
  assign arsize_m0 = arsize_s;
  assign arburst_m0 = arburst_s;
  assign arlock_m0 = arlock_s;
  assign arcache_m0 = arcache_s;
  assign arprot_m0 = arprot_s;
  assign ar_qv_m0 = ar_qv_s;
  assign arvalid_m0 = arsel[0];
  assign arvalid_vect_m0 = arvalid_vect_s[0];

  assign aruser_m1 = aruser_s;
  assign arid_m1 = arid_s;
  assign araddr_m1 = araddr_s;
  assign arlen_m1 = arlen_s;
  assign arsize_m1 = arsize_s;
  assign arburst_m1 = arburst_s;
  assign arlock_m1 = arlock_s;
  assign arcache_m1 = arcache_s;
  assign arprot_m1 = arprot_s;
  assign ar_qv_m1 = ar_qv_s;
  assign arvalid_m1 = arsel[1];
  assign arvalid_vect_m1 = arvalid_vect_s[1];

  assign aruser_m2 = aruser_s;
  assign arid_m2 = arid_s;
  assign araddr_m2 = araddr_s;
  assign arlen_m2 = arlen_s;
  assign arsize_m2 = arsize_s;
  assign arburst_m2 = arburst_s;
  assign arlock_m2 = arlock_s;
  assign arcache_m2 = arcache_s;
  assign arprot_m2 = arprot_s;
  assign ar_qv_m2 = ar_qv_s;
  assign arvalid_m2 = arsel[2];
  assign arvalid_vect_m2 = arvalid_vect_s[2];

  assign aruser_m3 = aruser_s;
  assign arid_m3 = arid_s;
  assign araddr_m3 = araddr_s;
  assign arlen_m3 = arlen_s;
  assign arsize_m3 = arsize_s;
  assign arburst_m3 = arburst_s;
  assign arlock_m3 = arlock_s;
  assign arcache_m3 = arcache_s;
  assign arprot_m3 = arprot_s;
  assign ar_qv_m3 = ar_qv_s;
  assign arvalid_m3 = arsel[3];
  assign arvalid_vect_m3 = arvalid_vect_s[3];

  assign arready_s_int[0] = arready_m0 & arsel[0];
  assign arready_s_int[1] = arready_m1 & arsel[1];
  assign arready_s_int[2] = arready_m2 & arsel[2];
  assign arready_s_int[3] = arready_m3 & arsel[3]; 
  assign arready_s = |arready_s_int;


  assign awsel[0] = awvalid_s & awvalid_vect_s[0];
  assign arsel[0] = arvalid_s & arvalid_vect_s[0];
  assign awsel[1] = awvalid_s & awvalid_vect_s[1];
  assign arsel[1] = arvalid_s & arvalid_vect_s[1];
  assign awsel[2] = awvalid_s & awvalid_vect_s[2];
  assign arsel[2] = arvalid_s & arvalid_vect_s[2];
  assign awsel[3] = awvalid_s & awvalid_vect_s[3];
  assign arsel[3] = arvalid_s & arvalid_vect_s[3];

  nic400_switch3_wr_spi_tt_s0_sse710_main u_nic400_switch3_wr_spi_tt_18_4m_sse710_main (
        .aw_enable    (aw_enable),
        .tt_enable    (tt_enable_wr),
        .wr_enable    (wr_enable),
        .asel         (awsel),
        .aready       (awready_s),
        .wvalid       (wvalid_s),
        .wready       (wready_s),
        .wlast        (wlast_s),
        .resp_valid   (bvalid_s),
        .resp_ready   (bready_s),
        .bvalid_m0    (bvalid_m0),
        .bvalid_m1    (bvalid_m1),
        .bvalid_m2    (bvalid_m2),
        .bvalid_m3    (bvalid_m3),
        .aclk         (aclk),
        .aresetn      (aresetn)
  );

  nic400_switch3_rd_spi_tt_s0_sse710_main u_nic400_switch3_rd_spi_tt_18_4m_sse710_main (
        .tt_enable    (tt_enable_rd),
        .resp_valid   (rvalid_s),
        .resp_last    (rlast_s),
        .resp_ready   (rready_s),
        .rvalid_m0    (rvalid_m0),
        .rvalid_m1    (rvalid_m1),
        .rvalid_m2    (rvalid_m2),
        .rvalid_m3    (rvalid_m3),

        .aclk         (aclk),
        .aresetn      (aresetn)
  );

  assign wdata_m0 = wdata_s;
  assign wstrb_m0 = wstrb_s;
  assign wlast_m0 = wlast_s;
  assign wvalid_m0 = wvalid_s & wr_enable[0];
  assign wready_s_int[0] = wready_m0 & wr_enable[0];

  assign wdata_m1 = wdata_s;
  assign wstrb_m1 = wstrb_s;
  assign wlast_m1 = wlast_s;
  assign wvalid_m1 = wvalid_s & wr_enable[1];
  assign wready_s_int[1] = wready_m1 & wr_enable[1];

  assign wdata_m2 = wdata_s;
  assign wstrb_m2 = wstrb_s;
  assign wlast_m2 = wlast_s;
  assign wvalid_m2 = wvalid_s & wr_enable[2];
  assign wready_s_int[2] = wready_m2 & wr_enable[2];

  assign wdata_m3 = wdata_s;
  assign wstrb_m3 = wstrb_s;
  assign wlast_m3 = wlast_s;
  assign wvalid_m3 = wvalid_s & wr_enable[3];
  assign wready_s_int[3] = wready_m3 & wr_enable[3];
  
  assign wready_s = |wready_s_int;





  assign buser_s_int[0] = buser_m0 & tt_enable_wr[0];
  assign bid_s_int[11:0] = bid_m0 & {12{tt_enable_wr[0]}};
  assign bresp_s_int[1:0] = bresp_m0 & {2{tt_enable_wr[0]}};
  assign bvalid_s_int[0] = bvalid_m0 & tt_enable_wr[0];
  assign bready_m0 = bready_s & tt_enable_wr[0];

  assign buser_s_int[1] = buser_m1 & tt_enable_wr[1];
  assign bid_s_int[23:12] = bid_m1 & {12{tt_enable_wr[1]}};
  assign bresp_s_int[3:2] = bresp_m1 & {2{tt_enable_wr[1]}};
  assign bvalid_s_int[1] = bvalid_m1 & tt_enable_wr[1];
  assign bready_m1 = bready_s & tt_enable_wr[1];

  assign buser_s_int[2] = buser_m2 & tt_enable_wr[2];
  assign bid_s_int[35:24] = bid_m2 & {12{tt_enable_wr[2]}};
  assign bresp_s_int[5:4] = bresp_m2 & {2{tt_enable_wr[2]}};
  assign bvalid_s_int[2] = bvalid_m2 & tt_enable_wr[2];
  assign bready_m2 = bready_s & tt_enable_wr[2];

  assign buser_s_int[3] = buser_m3 & tt_enable_wr[3];
  assign bid_s_int[47:36] = bid_m3 & {12{tt_enable_wr[3]}};
  assign bresp_s_int[7:6] = bresp_m3 & {2{tt_enable_wr[3]}};
  assign bvalid_s_int[3] = bvalid_m3 & tt_enable_wr[3];
  assign bready_m3 = bready_s & tt_enable_wr[3];
  assign bvalid_s = |bvalid_s_int;
  assign bid_s = bid_s_int[11:0]
                 | bid_s_int[23:12]
                 | bid_s_int[35:24]
                 | bid_s_int[47:36];
  assign bresp_s = bresp_s_int[1:0]
                 | bresp_s_int[3:2]
                 | bresp_s_int[5:4]
                 | bresp_s_int[7:6];
  assign buser_s = buser_s_int[0]
                 | buser_s_int[1]
                 | buser_s_int[2]
                 | buser_s_int[3];

  assign ruser_s_int[0] = ruser_m0 & tt_enable_rd[0];
  assign rid_s_int[11:0] = rid_m0 & {12{tt_enable_rd[0]}};
  assign rdata_s_int[31:0] = rdata_m0 & {32{tt_enable_rd[0]}};
  assign rresp_s_int[1:0] = rresp_m0 & {2{tt_enable_rd[0]}};
  assign rlast_s_int[0] = rlast_m0 & tt_enable_rd[0];
  assign rvalid_s_int[0] = rvalid_m0 & tt_enable_rd[0];
  assign rready_m0 = rready_s & tt_enable_rd[0];

  assign ruser_s_int[1] = ruser_m1 & tt_enable_rd[1];
  assign rid_s_int[23:12] = rid_m1 & {12{tt_enable_rd[1]}};
  assign rdata_s_int[63:32] = rdata_m1 & {32{tt_enable_rd[1]}};
  assign rresp_s_int[3:2] = rresp_m1 & {2{tt_enable_rd[1]}};
  assign rlast_s_int[1] = rlast_m1 & tt_enable_rd[1];
  assign rvalid_s_int[1] = rvalid_m1 & tt_enable_rd[1];
  assign rready_m1 = rready_s & tt_enable_rd[1];

  assign ruser_s_int[2] = ruser_m2 & tt_enable_rd[2];
  assign rid_s_int[35:24] = rid_m2 & {12{tt_enable_rd[2]}};
  assign rdata_s_int[95:64] = rdata_m2 & {32{tt_enable_rd[2]}};
  assign rresp_s_int[5:4] = rresp_m2 & {2{tt_enable_rd[2]}};
  assign rlast_s_int[2] = rlast_m2 & tt_enable_rd[2];
  assign rvalid_s_int[2] = rvalid_m2 & tt_enable_rd[2];
  assign rready_m2 = rready_s & tt_enable_rd[2];

  assign ruser_s_int[3] = ruser_m3 & tt_enable_rd[3];
  assign rid_s_int[47:36] = rid_m3 & {12{tt_enable_rd[3]}};
  assign rdata_s_int[127:96] = rdata_m3 & {32{tt_enable_rd[3]}};
  assign rresp_s_int[7:6] = rresp_m3 & {2{tt_enable_rd[3]}};
  assign rlast_s_int[3] = rlast_m3 & tt_enable_rd[3];
  assign rvalid_s_int[3] = rvalid_m3 & tt_enable_rd[3];
  assign rready_m3 = rready_s & tt_enable_rd[3];
  assign rvalid_s = |rvalid_s_int;
  assign rlast_s = |rlast_s_int;
  assign rid_s = rid_s_int[11:0]
                 | rid_s_int[23:12]
                 | rid_s_int[35:24]
                 | rid_s_int[47:36];
  assign rresp_s = rresp_s_int[1:0]
                 | rresp_s_int[3:2]
                 | rresp_s_int[5:4]
                 | rresp_s_int[7:6];
  assign rdata_s = rdata_s_int[31:0]
                 | rdata_s_int[63:32]
                 | rdata_s_int[95:64]
                 | rdata_s_int[127:96];
  assign ruser_s = ruser_s_int[0]
                 | ruser_s_int[1]
                 | ruser_s_int[2]
                 | ruser_s_int[3];

  endmodule


