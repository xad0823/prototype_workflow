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


module nic400_switch0_ml_build_sse710_dbg3s1m
  (


    awuser_s0,
    awid_s0,
    awaddr_s0,
    awlen_s0,
    awsize_s0,
    awburst_s0,
    awlock_s0,
    awcache_s0,
    awprot_s0,
    awvalid_s0,
    awvalid_vect_s0,
    awready_s0,
    aw_qv_s0,
   
    wdata_s0,
    wstrb_s0,
    wlast_s0,
    wvalid_s0,
    wready_s0,

    bid_s0,
    bresp_s0,
    bvalid_s0,
    bready_s0,

    aruser_s0,
    arid_s0,
    araddr_s0,
    arlen_s0,
    arsize_s0,
    arburst_s0,
    arlock_s0,
    arcache_s0,
    arprot_s0,
    arvalid_s0,
    arvalid_vect_s0,
    arready_s0,
    ar_qv_s0,
   
    rid_s0,
    rdata_s0,
    rresp_s0,
    rlast_s0,
    rvalid_s0,
    rready_s0,


    awuser_s1,
    awid_s1,
    awaddr_s1,
    awlen_s1,
    awsize_s1,
    awburst_s1,
    awlock_s1,
    awcache_s1,
    awprot_s1,
    awvalid_s1,
    awvalid_vect_s1,
    awready_s1,
    aw_qv_s1,
   
    wdata_s1,
    wstrb_s1,
    wlast_s1,
    wvalid_s1,
    wready_s1,

    bid_s1,
    bresp_s1,
    bvalid_s1,
    bready_s1,

    aruser_s1,
    arid_s1,
    araddr_s1,
    arlen_s1,
    arsize_s1,
    arburst_s1,
    arlock_s1,
    arcache_s1,
    arprot_s1,
    arvalid_s1,
    arvalid_vect_s1,
    arready_s1,
    ar_qv_s1,
   
    rid_s1,
    rdata_s1,
    rresp_s1,
    rlast_s1,
    rvalid_s1,
    rready_s1,


    awuser_s2,
    awid_s2,
    awaddr_s2,
    awlen_s2,
    awsize_s2,
    awburst_s2,
    awlock_s2,
    awcache_s2,
    awprot_s2,
    awvalid_s2,
    awvalid_vect_s2,
    awready_s2,
    aw_qv_s2,
   
    wdata_s2,
    wstrb_s2,
    wlast_s2,
    wvalid_s2,
    wready_s2,

    bid_s2,
    bresp_s2,
    bvalid_s2,
    bready_s2,

    aruser_s2,
    arid_s2,
    araddr_s2,
    arlen_s2,
    arsize_s2,
    arburst_s2,
    arlock_s2,
    arcache_s2,
    arprot_s2,
    arvalid_s2,
    arvalid_vect_s2,
    arready_s2,
    ar_qv_s2,
   
    rid_s2,
    rdata_s2,
    rresp_s2,
    rlast_s2,
    rvalid_s2,
    rready_s2,


    awuser_0_0,
    awid_0_0,
    awaddr_0_0,
    awlen_0_0,
    awsize_0_0,
    awburst_0_0,
    awlock_0_0,
    awcache_0_0,
    awprot_0_0,
    awvalid_0_0,
    awvalid_vect_0_0,
    awready_0_0,
    aw_qv_0_0,
   
    wdata_0_0,
    wstrb_0_0,
    wlast_0_0,
    wvalid_0_0,
    wready_0_0,

    bid_0_0,
    bresp_0_0,
    bvalid_0_0,
    bready_0_0,

    aruser_0_0,
    arid_0_0,
    araddr_0_0,
    arlen_0_0,
    arsize_0_0,
    arburst_0_0,
    arlock_0_0,
    arcache_0_0,
    arprot_0_0,
    arvalid_0_0,
    arvalid_vect_0_0,
    arready_0_0,
    ar_qv_0_0,
   
    rid_0_0,
    rdata_0_0,
    rresp_0_0,
    rlast_0_0,
    rvalid_0_0,
    rready_0_0,


    awuser_1_0,
    awid_1_0,
    awaddr_1_0,
    awlen_1_0,
    awsize_1_0,
    awburst_1_0,
    awlock_1_0,
    awcache_1_0,
    awprot_1_0,
    awvalid_1_0,
    awvalid_vect_1_0,
    awready_1_0,
    aw_qv_1_0,
   
    wdata_1_0,
    wstrb_1_0,
    wlast_1_0,
    wvalid_1_0,
    wready_1_0,

    bid_1_0,
    bresp_1_0,
    bvalid_1_0,
    bready_1_0,

    aruser_1_0,
    arid_1_0,
    araddr_1_0,
    arlen_1_0,
    arsize_1_0,
    arburst_1_0,
    arlock_1_0,
    arcache_1_0,
    arprot_1_0,
    arvalid_1_0,
    arvalid_vect_1_0,
    arready_1_0,
    ar_qv_1_0,
   
    rid_1_0,
    rdata_1_0,
    rresp_1_0,
    rlast_1_0,
    rvalid_1_0,
    rready_1_0,


    awuser_2_0,
    awid_2_0,
    awaddr_2_0,
    awlen_2_0,
    awsize_2_0,
    awburst_2_0,
    awlock_2_0,
    awcache_2_0,
    awprot_2_0,
    awvalid_2_0,
    awvalid_vect_2_0,
    awready_2_0,
    aw_qv_2_0,
   
    wdata_2_0,
    wstrb_2_0,
    wlast_2_0,
    wvalid_2_0,
    wready_2_0,

    bid_2_0,
    bresp_2_0,
    bvalid_2_0,
    bready_2_0,

    aruser_2_0,
    arid_2_0,
    araddr_2_0,
    arlen_2_0,
    arsize_2_0,
    arburst_2_0,
    arlock_2_0,
    arcache_2_0,
    arprot_2_0,
    arvalid_2_0,
    arvalid_vect_2_0,
    arready_2_0,
    ar_qv_2_0,
   
    rid_2_0,
    rdata_2_0,
    rresp_2_0,
    rlast_2_0,
    rvalid_2_0,
    rready_2_0,
 
    aclk,
    aresetn
  );



  input [2:0]       awuser_s0;
  input [3:0]       awid_s0;
  input [31:0]      awaddr_s0;
  input [7:0]       awlen_s0;
  input [2:0]       awsize_s0;
  input [1:0]       awburst_s0;
  input             awlock_s0;
  input [3:0]       awcache_s0;
  input [2:0]       awprot_s0;
  input             awvalid_s0;
  input             awvalid_vect_s0;
  output            awready_s0;
  input [3:0]       aw_qv_s0;
    
  input [31:0]      wdata_s0;
  input [3:0]       wstrb_s0;
  input             wlast_s0;
  input             wvalid_s0;
  output            wready_s0;

  output [3:0]      bid_s0;
  output [1:0]      bresp_s0;
  output            bvalid_s0;
  input             bready_s0;

  input [2:0]       aruser_s0;
  input [3:0]       arid_s0;
  input [31:0]      araddr_s0;
  input [7:0]       arlen_s0;
  input [2:0]       arsize_s0;
  input [1:0]       arburst_s0;
  input             arlock_s0;
  input [3:0]       arcache_s0;
  input [2:0]       arprot_s0;
  input             arvalid_s0;
  input             arvalid_vect_s0;
  output            arready_s0;
  input [3:0]       ar_qv_s0;
   
  output [3:0]      rid_s0;
  output [31:0]     rdata_s0;
  output [1:0]      rresp_s0;
  output            rlast_s0;
  output            rvalid_s0;
  input             rready_s0;


  input [2:0]       awuser_s1;
  input [3:0]       awid_s1;
  input [31:0]      awaddr_s1;
  input [7:0]       awlen_s1;
  input [2:0]       awsize_s1;
  input [1:0]       awburst_s1;
  input             awlock_s1;
  input [3:0]       awcache_s1;
  input [2:0]       awprot_s1;
  input             awvalid_s1;
  input             awvalid_vect_s1;
  output            awready_s1;
  input [3:0]       aw_qv_s1;
    
  input [31:0]      wdata_s1;
  input [3:0]       wstrb_s1;
  input             wlast_s1;
  input             wvalid_s1;
  output            wready_s1;

  output [3:0]      bid_s1;
  output [1:0]      bresp_s1;
  output            bvalid_s1;
  input             bready_s1;

  input [2:0]       aruser_s1;
  input [3:0]       arid_s1;
  input [31:0]      araddr_s1;
  input [7:0]       arlen_s1;
  input [2:0]       arsize_s1;
  input [1:0]       arburst_s1;
  input             arlock_s1;
  input [3:0]       arcache_s1;
  input [2:0]       arprot_s1;
  input             arvalid_s1;
  input             arvalid_vect_s1;
  output            arready_s1;
  input [3:0]       ar_qv_s1;
   
  output [3:0]      rid_s1;
  output [31:0]     rdata_s1;
  output [1:0]      rresp_s1;
  output            rlast_s1;
  output            rvalid_s1;
  input             rready_s1;


  input [2:0]       awuser_s2;
  input [3:0]       awid_s2;
  input [31:0]      awaddr_s2;
  input [7:0]       awlen_s2;
  input [2:0]       awsize_s2;
  input [1:0]       awburst_s2;
  input             awlock_s2;
  input [3:0]       awcache_s2;
  input [2:0]       awprot_s2;
  input             awvalid_s2;
  input             awvalid_vect_s2;
  output            awready_s2;
  input [3:0]       aw_qv_s2;
    
  input [31:0]      wdata_s2;
  input [3:0]       wstrb_s2;
  input             wlast_s2;
  input             wvalid_s2;
  output            wready_s2;

  output [3:0]      bid_s2;
  output [1:0]      bresp_s2;
  output            bvalid_s2;
  input             bready_s2;

  input [2:0]       aruser_s2;
  input [3:0]       arid_s2;
  input [31:0]      araddr_s2;
  input [7:0]       arlen_s2;
  input [2:0]       arsize_s2;
  input [1:0]       arburst_s2;
  input             arlock_s2;
  input [3:0]       arcache_s2;
  input [2:0]       arprot_s2;
  input             arvalid_s2;
  input             arvalid_vect_s2;
  output            arready_s2;
  input [3:0]       ar_qv_s2;
   
  output [3:0]      rid_s2;
  output [31:0]     rdata_s2;
  output [1:0]      rresp_s2;
  output            rlast_s2;
  output            rvalid_s2;
  input             rready_s2;


  output [2:0]      awuser_0_0;
  output [3:0]      awid_0_0;
  output [31:0]     awaddr_0_0;
  output [7:0]      awlen_0_0;
  output [2:0]      awsize_0_0;
  output [1:0]      awburst_0_0;
  output            awlock_0_0;
  output [3:0]      awcache_0_0;
  output [2:0]      awprot_0_0;
  output            awvalid_0_0;
  output             awvalid_vect_0_0;
  input             awready_0_0;
  output [3:0]      aw_qv_0_0;
   
  output  [31:0]    wdata_0_0;
  output  [3:0]     wstrb_0_0;
  output            wlast_0_0;
  output            wvalid_0_0;
  input             wready_0_0;

  input [3:0]       bid_0_0;
  input [1:0]       bresp_0_0;
  input             bvalid_0_0;
  output            bready_0_0;

  output  [2:0]     aruser_0_0;
  output  [3:0]     arid_0_0;
  output  [31:0]    araddr_0_0;
  output  [7:0]     arlen_0_0;
  output  [2:0]     arsize_0_0;
  output  [1:0]     arburst_0_0;
  output            arlock_0_0;
  output  [3:0]     arcache_0_0;
  output  [2:0]     arprot_0_0;
  output            arvalid_0_0;
  output            arvalid_vect_0_0;
  input             arready_0_0;
  output  [3:0]     ar_qv_0_0;

  input [3:0]       rid_0_0;
  input [31:0]      rdata_0_0;
  input [1:0]       rresp_0_0;
  input             rlast_0_0;
  input             rvalid_0_0;
  output            rready_0_0;


  output [2:0]      awuser_1_0;
  output [3:0]      awid_1_0;
  output [31:0]     awaddr_1_0;
  output [7:0]      awlen_1_0;
  output [2:0]      awsize_1_0;
  output [1:0]      awburst_1_0;
  output            awlock_1_0;
  output [3:0]      awcache_1_0;
  output [2:0]      awprot_1_0;
  output            awvalid_1_0;
  output             awvalid_vect_1_0;
  input             awready_1_0;
  output [3:0]      aw_qv_1_0;
   
  output  [31:0]    wdata_1_0;
  output  [3:0]     wstrb_1_0;
  output            wlast_1_0;
  output            wvalid_1_0;
  input             wready_1_0;

  input [3:0]       bid_1_0;
  input [1:0]       bresp_1_0;
  input             bvalid_1_0;
  output            bready_1_0;

  output  [2:0]     aruser_1_0;
  output  [3:0]     arid_1_0;
  output  [31:0]    araddr_1_0;
  output  [7:0]     arlen_1_0;
  output  [2:0]     arsize_1_0;
  output  [1:0]     arburst_1_0;
  output            arlock_1_0;
  output  [3:0]     arcache_1_0;
  output  [2:0]     arprot_1_0;
  output            arvalid_1_0;
  output            arvalid_vect_1_0;
  input             arready_1_0;
  output  [3:0]     ar_qv_1_0;

  input [3:0]       rid_1_0;
  input [31:0]      rdata_1_0;
  input [1:0]       rresp_1_0;
  input             rlast_1_0;
  input             rvalid_1_0;
  output            rready_1_0;


  output [2:0]      awuser_2_0;
  output [3:0]      awid_2_0;
  output [31:0]     awaddr_2_0;
  output [7:0]      awlen_2_0;
  output [2:0]      awsize_2_0;
  output [1:0]      awburst_2_0;
  output            awlock_2_0;
  output [3:0]      awcache_2_0;
  output [2:0]      awprot_2_0;
  output            awvalid_2_0;
  output             awvalid_vect_2_0;
  input             awready_2_0;
  output [3:0]      aw_qv_2_0;
   
  output  [31:0]    wdata_2_0;
  output  [3:0]     wstrb_2_0;
  output            wlast_2_0;
  output            wvalid_2_0;
  input             wready_2_0;

  input [3:0]       bid_2_0;
  input [1:0]       bresp_2_0;
  input             bvalid_2_0;
  output            bready_2_0;

  output  [2:0]     aruser_2_0;
  output  [3:0]     arid_2_0;
  output  [31:0]    araddr_2_0;
  output  [7:0]     arlen_2_0;
  output  [2:0]     arsize_2_0;
  output  [1:0]     arburst_2_0;
  output            arlock_2_0;
  output  [3:0]     arcache_2_0;
  output  [2:0]     arprot_2_0;
  output            arvalid_2_0;
  output            arvalid_vect_2_0;
  input             arready_2_0;
  output  [3:0]     ar_qv_2_0;

  input [3:0]       rid_2_0;
  input [31:0]      rdata_2_0;
  input [1:0]       rresp_2_0;
  input             rlast_2_0;
  input             rvalid_2_0;
  output            rready_2_0;
 
  input             aclk;
  input             aresetn;





nic400_switch0_ml_blayer_0_sse710_dbg3s1m u_nic400_switch0_ml_blayer_0_sse710_dbg3s1m
  (    

        .awuser_s       (awuser_s0),
        .awid_s         (awid_s0),
        .awaddr_s       (awaddr_s0),
        .awlen_s        (awlen_s0),
        .awsize_s       (awsize_s0),
        .awburst_s      (awburst_s0),
        .awlock_s       (awlock_s0),
        .awcache_s      (awcache_s0),
        .awprot_s       (awprot_s0),
        .awvalid_s      (awvalid_s0),
        .awvalid_vect_s (awvalid_vect_s0),
        .awready_s      (awready_s0),
        .aw_qv_s        (aw_qv_s0),
   
        .wdata_s        (wdata_s0),
        .wstrb_s        (wstrb_s0),   
        .wlast_s        (wlast_s0),
        .wvalid_s       (wvalid_s0),
        .wready_s       (wready_s0),

        .bid_s          (bid_s0),
        .bresp_s        (bresp_s0),
        .bvalid_s       (bvalid_s0),
        .bready_s       (bready_s0),  

        .aruser_s       (aruser_s0),
        .arid_s         (arid_s0),
        .araddr_s       (araddr_s0),
        .arlen_s        (arlen_s0),
        .arsize_s       (arsize_s0),
        .arburst_s      (arburst_s0),
        .arlock_s       (arlock_s0),
        .arcache_s      (arcache_s0),
        .arprot_s       (arprot_s0),
        .arvalid_s      (arvalid_s0),
        .arvalid_vect_s (arvalid_vect_s0),
        .arready_s      (arready_s0),
        .ar_qv_s        (ar_qv_s0),
   
        .rid_s          (rid_s0),
        .rdata_s        (rdata_s0),
        .rresp_s        (rresp_s0),
        .rlast_s        (rlast_s0),
        .rvalid_s       (rvalid_s0),
        .rready_s       (rready_s0),





        .awuser_m0       (awuser_0_0),
        .awid_m0         (awid_0_0),
        .awaddr_m0       (awaddr_0_0),
        .awlen_m0        (awlen_0_0),
        .awsize_m0       (awsize_0_0),
        .awburst_m0      (awburst_0_0),
        .awlock_m0       (awlock_0_0),
        .awcache_m0      (awcache_0_0),
        .awprot_m0       (awprot_0_0),
        .awvalid_m0      (awvalid_0_0),
        .awvalid_vect_m0 (awvalid_vect_0_0),
        .awready_m0      (awready_0_0),
        .aw_qv_m0        (aw_qv_0_0),
   
        .wdata_m0        (wdata_0_0),
        .wstrb_m0        (wstrb_0_0),   
        .wlast_m0        (wlast_0_0),
        .wvalid_m0       (wvalid_0_0),
        .wready_m0       (wready_0_0),

        .bid_m0          (bid_0_0),
        .bresp_m0        (bresp_0_0),
        .bvalid_m0       (bvalid_0_0),
        .bready_m0       (bready_0_0),

        .aruser_m0       (aruser_0_0),
        .arid_m0         (arid_0_0),
        .araddr_m0       (araddr_0_0),
        .arlen_m0        (arlen_0_0),
        .arsize_m0       (arsize_0_0),
        .arburst_m0      (arburst_0_0),
        .arlock_m0       (arlock_0_0),
        .arcache_m0      (arcache_0_0),
        .arprot_m0       (arprot_0_0),
        .arvalid_m0      (arvalid_0_0),
        .arvalid_vect_m0 (arvalid_vect_0_0),
        .arready_m0      (arready_0_0),
        .ar_qv_m0        (ar_qv_0_0),
   
        .rid_m0          (rid_0_0),
        .rdata_m0        (rdata_0_0),
        .rresp_m0        (rresp_0_0),
        .rlast_m0        (rlast_0_0),
        .rvalid_m0       (rvalid_0_0),
        .rready_m0       (rready_0_0)
  ); 

nic400_switch0_ml_blayer_1_sse710_dbg3s1m u_nic400_switch0_ml_blayer_1_sse710_dbg3s1m
  (    

        .awuser_s       (awuser_s1),
        .awid_s         (awid_s1),
        .awaddr_s       (awaddr_s1),
        .awlen_s        (awlen_s1),
        .awsize_s       (awsize_s1),
        .awburst_s      (awburst_s1),
        .awlock_s       (awlock_s1),
        .awcache_s      (awcache_s1),
        .awprot_s       (awprot_s1),
        .awvalid_s      (awvalid_s1),
        .awvalid_vect_s (awvalid_vect_s1),
        .awready_s      (awready_s1),
        .aw_qv_s        (aw_qv_s1),
   
        .wdata_s        (wdata_s1),
        .wstrb_s        (wstrb_s1),   
        .wlast_s        (wlast_s1),
        .wvalid_s       (wvalid_s1),
        .wready_s       (wready_s1),

        .bid_s          (bid_s1),
        .bresp_s        (bresp_s1),
        .bvalid_s       (bvalid_s1),
        .bready_s       (bready_s1),  

        .aruser_s       (aruser_s1),
        .arid_s         (arid_s1),
        .araddr_s       (araddr_s1),
        .arlen_s        (arlen_s1),
        .arsize_s       (arsize_s1),
        .arburst_s      (arburst_s1),
        .arlock_s       (arlock_s1),
        .arcache_s      (arcache_s1),
        .arprot_s       (arprot_s1),
        .arvalid_s      (arvalid_s1),
        .arvalid_vect_s (arvalid_vect_s1),
        .arready_s      (arready_s1),
        .ar_qv_s        (ar_qv_s1),
   
        .rid_s          (rid_s1),
        .rdata_s        (rdata_s1),
        .rresp_s        (rresp_s1),
        .rlast_s        (rlast_s1),
        .rvalid_s       (rvalid_s1),
        .rready_s       (rready_s1),





        .awuser_m0       (awuser_1_0),
        .awid_m0         (awid_1_0),
        .awaddr_m0       (awaddr_1_0),
        .awlen_m0        (awlen_1_0),
        .awsize_m0       (awsize_1_0),
        .awburst_m0      (awburst_1_0),
        .awlock_m0       (awlock_1_0),
        .awcache_m0      (awcache_1_0),
        .awprot_m0       (awprot_1_0),
        .awvalid_m0      (awvalid_1_0),
        .awvalid_vect_m0 (awvalid_vect_1_0),
        .awready_m0      (awready_1_0),
        .aw_qv_m0        (aw_qv_1_0),
   
        .wdata_m0        (wdata_1_0),
        .wstrb_m0        (wstrb_1_0),   
        .wlast_m0        (wlast_1_0),
        .wvalid_m0       (wvalid_1_0),
        .wready_m0       (wready_1_0),

        .bid_m0          (bid_1_0),
        .bresp_m0        (bresp_1_0),
        .bvalid_m0       (bvalid_1_0),
        .bready_m0       (bready_1_0),

        .aruser_m0       (aruser_1_0),
        .arid_m0         (arid_1_0),
        .araddr_m0       (araddr_1_0),
        .arlen_m0        (arlen_1_0),
        .arsize_m0       (arsize_1_0),
        .arburst_m0      (arburst_1_0),
        .arlock_m0       (arlock_1_0),
        .arcache_m0      (arcache_1_0),
        .arprot_m0       (arprot_1_0),
        .arvalid_m0      (arvalid_1_0),
        .arvalid_vect_m0 (arvalid_vect_1_0),
        .arready_m0      (arready_1_0),
        .ar_qv_m0        (ar_qv_1_0),
   
        .rid_m0          (rid_1_0),
        .rdata_m0        (rdata_1_0),
        .rresp_m0        (rresp_1_0),
        .rlast_m0        (rlast_1_0),
        .rvalid_m0       (rvalid_1_0),
        .rready_m0       (rready_1_0)
  ); 

nic400_switch0_ml_blayer_2_sse710_dbg3s1m u_nic400_switch0_ml_blayer_2_sse710_dbg3s1m
  (    

        .awuser_s       (awuser_s2),
        .awid_s         (awid_s2),
        .awaddr_s       (awaddr_s2),
        .awlen_s        (awlen_s2),
        .awsize_s       (awsize_s2),
        .awburst_s      (awburst_s2),
        .awlock_s       (awlock_s2),
        .awcache_s      (awcache_s2),
        .awprot_s       (awprot_s2),
        .awvalid_s      (awvalid_s2),
        .awvalid_vect_s (awvalid_vect_s2),
        .awready_s      (awready_s2),
        .aw_qv_s        (aw_qv_s2),
   
        .wdata_s        (wdata_s2),
        .wstrb_s        (wstrb_s2),   
        .wlast_s        (wlast_s2),
        .wvalid_s       (wvalid_s2),
        .wready_s       (wready_s2),

        .bid_s          (bid_s2),
        .bresp_s        (bresp_s2),
        .bvalid_s       (bvalid_s2),
        .bready_s       (bready_s2),  

        .aruser_s       (aruser_s2),
        .arid_s         (arid_s2),
        .araddr_s       (araddr_s2),
        .arlen_s        (arlen_s2),
        .arsize_s       (arsize_s2),
        .arburst_s      (arburst_s2),
        .arlock_s       (arlock_s2),
        .arcache_s      (arcache_s2),
        .arprot_s       (arprot_s2),
        .arvalid_s      (arvalid_s2),
        .arvalid_vect_s (arvalid_vect_s2),
        .arready_s      (arready_s2),
        .ar_qv_s        (ar_qv_s2),
   
        .rid_s          (rid_s2),
        .rdata_s        (rdata_s2),
        .rresp_s        (rresp_s2),
        .rlast_s        (rlast_s2),
        .rvalid_s       (rvalid_s2),
        .rready_s       (rready_s2),





        .awuser_m0       (awuser_2_0),
        .awid_m0         (awid_2_0),
        .awaddr_m0       (awaddr_2_0),
        .awlen_m0        (awlen_2_0),
        .awsize_m0       (awsize_2_0),
        .awburst_m0      (awburst_2_0),
        .awlock_m0       (awlock_2_0),
        .awcache_m0      (awcache_2_0),
        .awprot_m0       (awprot_2_0),
        .awvalid_m0      (awvalid_2_0),
        .awvalid_vect_m0 (awvalid_vect_2_0),
        .awready_m0      (awready_2_0),
        .aw_qv_m0        (aw_qv_2_0),
   
        .wdata_m0        (wdata_2_0),
        .wstrb_m0        (wstrb_2_0),   
        .wlast_m0        (wlast_2_0),
        .wvalid_m0       (wvalid_2_0),
        .wready_m0       (wready_2_0),

        .bid_m0          (bid_2_0),
        .bresp_m0        (bresp_2_0),
        .bvalid_m0       (bvalid_2_0),
        .bready_m0       (bready_2_0),

        .aruser_m0       (aruser_2_0),
        .arid_m0         (arid_2_0),
        .araddr_m0       (araddr_2_0),
        .arlen_m0        (arlen_2_0),
        .arsize_m0       (arsize_2_0),
        .arburst_m0      (arburst_2_0),
        .arlock_m0       (arlock_2_0),
        .arcache_m0      (arcache_2_0),
        .arprot_m0       (arprot_2_0),
        .arvalid_m0      (arvalid_2_0),
        .arvalid_vect_m0 (arvalid_vect_2_0),
        .arready_m0      (arready_2_0),
        .ar_qv_m0        (ar_qv_2_0),
   
        .rid_m0          (rid_2_0),
        .rdata_m0        (rdata_2_0),
        .rresp_m0        (rresp_2_0),
        .rlast_m0        (rlast_2_0),
        .rvalid_m0       (rvalid_2_0),
        .rready_m0       (rready_2_0)
  ); 





  endmodule


