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


module nic400_switch1_ml_map_sse710_main
  (

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




    awuser_0_1,
    awid_0_1,
    awaddr_0_1,
    awlen_0_1,
    awsize_0_1,
    awburst_0_1,
    awlock_0_1,
    awcache_0_1,
    awprot_0_1,
    awvalid_0_1,
    awvalid_vect_0_1,
    awready_0_1,
    aw_qv_0_1,
   
    wdata_0_1,
    wstrb_0_1,   
    wlast_0_1,
    wvalid_0_1,
    wready_0_1,

    buser_0_1,
    bid_0_1,
    bresp_0_1,
    bvalid_0_1,
    bready_0_1,  

    aruser_0_1,
    arid_0_1,
    araddr_0_1,
    arlen_0_1,
    arsize_0_1,
    arburst_0_1,
    arlock_0_1,
    arcache_0_1,
    arprot_0_1,
    arvalid_0_1,
    arvalid_vect_0_1,
    arready_0_1,
    ar_qv_0_1,
   
    ruser_0_1,
    rid_0_1,
    rdata_0_1,
    rresp_0_1,
    rlast_0_1,
    rvalid_0_1,
    rready_0_1,



    awuser_0_2,
    awid_0_2,
    awaddr_0_2,
    awlen_0_2,
    awsize_0_2,
    awburst_0_2,
    awlock_0_2,
    awcache_0_2,
    awprot_0_2,
    awvalid_0_2,
    awvalid_vect_0_2,
    awready_0_2,
    aw_qv_0_2,
   
    wdata_0_2,
    wstrb_0_2,   
    wlast_0_2,
    wvalid_0_2,
    wready_0_2,

    buser_0_2,
    bid_0_2,
    bresp_0_2,
    bvalid_0_2,
    bready_0_2,  

    aruser_0_2,
    arid_0_2,
    araddr_0_2,
    arlen_0_2,
    arsize_0_2,
    arburst_0_2,
    arlock_0_2,
    arcache_0_2,
    arprot_0_2,
    arvalid_0_2,
    arvalid_vect_0_2,
    arready_0_2,
    ar_qv_0_2,
   
    ruser_0_2,
    rid_0_2,
    rdata_0_2,
    rresp_0_2,
    rlast_0_2,
    rvalid_0_2,
    rready_0_2,



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

    buser_1_0,
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
   
    ruser_1_0,
    rid_1_0,
    rdata_1_0,
    rresp_1_0,
    rlast_1_0,
    rvalid_1_0,
    rready_1_0,



    awuser_1_2,
    awid_1_2,
    awaddr_1_2,
    awlen_1_2,
    awsize_1_2,
    awburst_1_2,
    awlock_1_2,
    awcache_1_2,
    awprot_1_2,
    awvalid_1_2,
    awvalid_vect_1_2,
    awready_1_2,
    aw_qv_1_2,
   
    wdata_1_2,
    wstrb_1_2,   
    wlast_1_2,
    wvalid_1_2,
    wready_1_2,

    buser_1_2,
    bid_1_2,
    bresp_1_2,
    bvalid_1_2,
    bready_1_2,  

    aruser_1_2,
    arid_1_2,
    araddr_1_2,
    arlen_1_2,
    arsize_1_2,
    arburst_1_2,
    arlock_1_2,
    arcache_1_2,
    arprot_1_2,
    arvalid_1_2,
    arvalid_vect_1_2,
    arready_1_2,
    ar_qv_1_2,
   
    ruser_1_2,
    rid_1_2,
    rdata_1_2,
    rresp_1_2,
    rlast_1_2,
    rvalid_1_2,
    rready_1_2,


    aclk,
    aresetn
  );




    output [9:0]        awuser_m0;
    output [11:0]        awid_m0;
    output [39:0]       awaddr_m0;
    output [7:0]        awlen_m0;
    output [2:0]        awsize_m0;
    output [1:0]        awburst_m0;
    output              awlock_m0;
    output [3:0]        awcache_m0;
    output [2:0]        awprot_m0;
    output              awvalid_m0;
    output [9:0]             awvalid_vect_m0;
    input               awready_m0;
    output [3:0]        aw_qv_m0;
   
    output [31:0]       wdata_m0;
    output [3:0]        wstrb_m0;   
    output              wlast_m0;
    output              wvalid_m0;
    input               wready_m0;

    input               buser_m0;
    input  [11:0]             bid_m0;
    input  [1:0]        bresp_m0;
    input               bvalid_m0;
    output              bready_m0;  

    output [9:0]        aruser_m0;
    output [11:0]        arid_m0;
    output [39:0]       araddr_m0;
    output [7:0]        arlen_m0;
    output [2:0]        arsize_m0;
    output [1:0]        arburst_m0;
    output              arlock_m0;
    output [3:0]        arcache_m0;
    output [2:0]        arprot_m0;
    output              arvalid_m0;
    output [9:0]             arvalid_vect_m0;
    input               arready_m0;
    output [3:0]        ar_qv_m0;
   
    input               ruser_m0;
    input  [11:0]        rid_m0;
    input  [31:0]       rdata_m0;
    input  [1:0]        rresp_m0;
    input               rlast_m0;
    input               rvalid_m0;
    output              rready_m0;

    output [9:0]        awuser_m1;
    output [11:0]        awid_m1;
    output [39:0]       awaddr_m1;
    output [7:0]        awlen_m1;
    output [2:0]        awsize_m1;
    output [1:0]        awburst_m1;
    output              awlock_m1;
    output [3:0]        awcache_m1;
    output [2:0]        awprot_m1;
    output              awvalid_m1;
    output              awvalid_vect_m1;
    input               awready_m1;
    output [3:0]        aw_qv_m1;
   
    output [31:0]       wdata_m1;
    output [3:0]        wstrb_m1;   
    output              wlast_m1;
    output              wvalid_m1;
    input               wready_m1;

    input               buser_m1;
    input  [11:0]             bid_m1;
    input  [1:0]        bresp_m1;
    input               bvalid_m1;
    output              bready_m1;  

    output [9:0]        aruser_m1;
    output [11:0]        arid_m1;
    output [39:0]       araddr_m1;
    output [7:0]        arlen_m1;
    output [2:0]        arsize_m1;
    output [1:0]        arburst_m1;
    output              arlock_m1;
    output [3:0]        arcache_m1;
    output [2:0]        arprot_m1;
    output              arvalid_m1;
    output              arvalid_vect_m1;
    input               arready_m1;
    output [3:0]        ar_qv_m1;
   
    input               ruser_m1;
    input  [11:0]        rid_m1;
    input  [31:0]       rdata_m1;
    input  [1:0]        rresp_m1;
    input               rlast_m1;
    input               rvalid_m1;
    output              rready_m1;

    output [9:0]        awuser_m2;
    output [11:0]        awid_m2;
    output [39:0]       awaddr_m2;
    output [7:0]        awlen_m2;
    output [2:0]        awsize_m2;
    output [1:0]        awburst_m2;
    output              awlock_m2;
    output [3:0]        awcache_m2;
    output [2:0]        awprot_m2;
    output              awvalid_m2;
    output              awvalid_vect_m2;
    input               awready_m2;
    output [3:0]        aw_qv_m2;
   
    output [31:0]       wdata_m2;
    output [3:0]        wstrb_m2;   
    output              wlast_m2;
    output              wvalid_m2;
    input               wready_m2;

    input               buser_m2;
    input  [11:0]             bid_m2;
    input  [1:0]        bresp_m2;
    input               bvalid_m2;
    output              bready_m2;  

    output [9:0]        aruser_m2;
    output [11:0]        arid_m2;
    output [39:0]       araddr_m2;
    output [7:0]        arlen_m2;
    output [2:0]        arsize_m2;
    output [1:0]        arburst_m2;
    output              arlock_m2;
    output [3:0]        arcache_m2;
    output [2:0]        arprot_m2;
    output              arvalid_m2;
    output              arvalid_vect_m2;
    input               arready_m2;
    output [3:0]        ar_qv_m2;
   
    input               ruser_m2;
    input  [11:0]        rid_m2;
    input  [31:0]       rdata_m2;
    input  [1:0]        rresp_m2;
    input               rlast_m2;
    input               rvalid_m2;
    output              rready_m2;




    input  [9:0]        awuser_0_1;
    input  [11:0]        awid_0_1;
    input  [39:0]       awaddr_0_1;
    input  [7:0]        awlen_0_1;
    input  [2:0]        awsize_0_1;
    input  [1:0]        awburst_0_1;
    input               awlock_0_1;
    input  [3:0]        awcache_0_1;
    input  [2:0]        awprot_0_1;
    input               awvalid_0_1;
    input               awvalid_vect_0_1;
    output              awready_0_1;
    input [3:0]         aw_qv_0_1;
   
    input [31:0]        wdata_0_1;
    input [3:0]         wstrb_0_1;   
    input               wlast_0_1;
    input               wvalid_0_1;
    output              wready_0_1;

    output              buser_0_1;
    output [11:0]        bid_0_1;
    output [1:0]        bresp_0_1;
    output              bvalid_0_1;
    input               bready_0_1;  

    input  [9:0]        aruser_0_1;
    input  [11:0]        arid_0_1;
    input  [39:0]       araddr_0_1;
    input  [7:0]        arlen_0_1;
    input  [2:0]        arsize_0_1;
    input  [1:0]        arburst_0_1;
    input               arlock_0_1;
    input  [3:0]        arcache_0_1;
    input  [2:0]        arprot_0_1;
    input               arvalid_0_1;
    input               arvalid_vect_0_1;
    output              arready_0_1;
    input [3:0]         ar_qv_0_1;
   
    output              ruser_0_1;
    output [11:0]        rid_0_1;
    output [31:0]       rdata_0_1;
    output [1:0]        rresp_0_1;
    output              rlast_0_1;
    output              rvalid_0_1;
    input               rready_0_1;



    input  [9:0]        awuser_0_2;
    input  [11:0]        awid_0_2;
    input  [39:0]       awaddr_0_2;
    input  [7:0]        awlen_0_2;
    input  [2:0]        awsize_0_2;
    input  [1:0]        awburst_0_2;
    input               awlock_0_2;
    input  [3:0]        awcache_0_2;
    input  [2:0]        awprot_0_2;
    input               awvalid_0_2;
    input               awvalid_vect_0_2;
    output              awready_0_2;
    input [3:0]         aw_qv_0_2;
   
    input [31:0]        wdata_0_2;
    input [3:0]         wstrb_0_2;   
    input               wlast_0_2;
    input               wvalid_0_2;
    output              wready_0_2;

    output              buser_0_2;
    output [11:0]        bid_0_2;
    output [1:0]        bresp_0_2;
    output              bvalid_0_2;
    input               bready_0_2;  

    input  [9:0]        aruser_0_2;
    input  [11:0]        arid_0_2;
    input  [39:0]       araddr_0_2;
    input  [7:0]        arlen_0_2;
    input  [2:0]        arsize_0_2;
    input  [1:0]        arburst_0_2;
    input               arlock_0_2;
    input  [3:0]        arcache_0_2;
    input  [2:0]        arprot_0_2;
    input               arvalid_0_2;
    input               arvalid_vect_0_2;
    output              arready_0_2;
    input [3:0]         ar_qv_0_2;
   
    output              ruser_0_2;
    output [11:0]        rid_0_2;
    output [31:0]       rdata_0_2;
    output [1:0]        rresp_0_2;
    output              rlast_0_2;
    output              rvalid_0_2;
    input               rready_0_2;



    input  [9:0]        awuser_1_0;
    input  [11:0]        awid_1_0;
    input  [39:0]       awaddr_1_0;
    input  [7:0]        awlen_1_0;
    input  [2:0]        awsize_1_0;
    input  [1:0]        awburst_1_0;
    input               awlock_1_0;
    input  [3:0]        awcache_1_0;
    input  [2:0]        awprot_1_0;
    input               awvalid_1_0;
    input  [9:0]             awvalid_vect_1_0;
    output              awready_1_0;
    input [3:0]         aw_qv_1_0;
   
    input [31:0]        wdata_1_0;
    input [3:0]         wstrb_1_0;   
    input               wlast_1_0;
    input               wvalid_1_0;
    output              wready_1_0;

    output              buser_1_0;
    output [11:0]        bid_1_0;
    output [1:0]        bresp_1_0;
    output              bvalid_1_0;
    input               bready_1_0;  

    input  [9:0]        aruser_1_0;
    input  [11:0]        arid_1_0;
    input  [39:0]       araddr_1_0;
    input  [7:0]        arlen_1_0;
    input  [2:0]        arsize_1_0;
    input  [1:0]        arburst_1_0;
    input               arlock_1_0;
    input  [3:0]        arcache_1_0;
    input  [2:0]        arprot_1_0;
    input               arvalid_1_0;
    input  [9:0]             arvalid_vect_1_0;
    output              arready_1_0;
    input [3:0]         ar_qv_1_0;
   
    output              ruser_1_0;
    output [11:0]        rid_1_0;
    output [31:0]       rdata_1_0;
    output [1:0]        rresp_1_0;
    output              rlast_1_0;
    output              rvalid_1_0;
    input               rready_1_0;



    input  [9:0]        awuser_1_2;
    input  [11:0]        awid_1_2;
    input  [39:0]       awaddr_1_2;
    input  [7:0]        awlen_1_2;
    input  [2:0]        awsize_1_2;
    input  [1:0]        awburst_1_2;
    input               awlock_1_2;
    input  [3:0]        awcache_1_2;
    input  [2:0]        awprot_1_2;
    input               awvalid_1_2;
    input               awvalid_vect_1_2;
    output              awready_1_2;
    input [3:0]         aw_qv_1_2;
   
    input [31:0]        wdata_1_2;
    input [3:0]         wstrb_1_2;   
    input               wlast_1_2;
    input               wvalid_1_2;
    output              wready_1_2;

    output              buser_1_2;
    output [11:0]        bid_1_2;
    output [1:0]        bresp_1_2;
    output              bvalid_1_2;
    input               bready_1_2;  

    input  [9:0]        aruser_1_2;
    input  [11:0]        arid_1_2;
    input  [39:0]       araddr_1_2;
    input  [7:0]        arlen_1_2;
    input  [2:0]        arsize_1_2;
    input  [1:0]        arburst_1_2;
    input               arlock_1_2;
    input  [3:0]        arcache_1_2;
    input  [2:0]        arprot_1_2;
    input               arvalid_1_2;
    input               arvalid_vect_1_2;
    output              arready_1_2;
    input [3:0]         ar_qv_1_2;
   
    output              ruser_1_2;
    output [11:0]        rid_1_2;
    output [31:0]       rdata_1_2;
    output [1:0]        rresp_1_2;
    output              rlast_1_2;
    output              rvalid_1_2;
    input               rready_1_2;


    input               aclk;
    input               aresetn;




nic400_switch1_ml_mlayer_0_sse710_main u_nic400_switch1_ml_mlayer0_sse710_main (
        .awuser_m       (awuser_m0),
        .awid_m         (awid_m0),
        .awaddr_m       (awaddr_m0),
        .awlen_m        (awlen_m0),
        .awsize_m       (awsize_m0),
        .awburst_m      (awburst_m0),
        .awlock_m       (awlock_m0),
        .awcache_m      (awcache_m0),
        .awprot_m       (awprot_m0),
        .awvalid_m      (awvalid_m0),
        .awvalid_vect_m (awvalid_vect_m0),
        .awready_m      (awready_m0),
        .aw_qv_m        (aw_qv_m0),
   
        .wdata_m        (wdata_m0),
        .wstrb_m        (wstrb_m0),   
        .wlast_m        (wlast_m0),
        .wvalid_m       (wvalid_m0),
        .wready_m       (wready_m0),

        .buser_m        (buser_m0),
        .bid_m          (bid_m0),
        .bresp_m        (bresp_m0),
        .bvalid_m       (bvalid_m0),
        .bready_m       (bready_m0),  

        .aruser_m       (aruser_m0),
        .arid_m         (arid_m0),
        .araddr_m       (araddr_m0),
        .arlen_m        (arlen_m0),
        .arsize_m       (arsize_m0),
        .arburst_m      (arburst_m0),
        .arlock_m       (arlock_m0),
        .arcache_m      (arcache_m0),
        .arprot_m       (arprot_m0),
        .arvalid_m      (arvalid_m0),
        .arvalid_vect_m (arvalid_vect_m0),
        .arready_m      (arready_m0),
        .ar_qv_m        (ar_qv_m0),
   
        .ruser_m        (ruser_m0),
        .rid_m          (rid_m0),
        .rdata_m        (rdata_m0),
        .rresp_m        (rresp_m0),
        .rlast_m        (rlast_m0),
        .rvalid_m       (rvalid_m0),
        .rready_m       (rready_m0),

        .awuser_s0       (awuser_1_0),
        .awid_s0         (awid_1_0),
        .awaddr_s0       (awaddr_1_0),
        .awlen_s0        (awlen_1_0),
        .awsize_s0       (awsize_1_0),
        .awburst_s0      (awburst_1_0),
        .awlock_s0       (awlock_1_0),
        .awcache_s0      (awcache_1_0),
        .awprot_s0       (awprot_1_0),
        .awvalid_s0      (awvalid_1_0),
        .awvalid_vect_s0 (awvalid_vect_1_0),
        .awready_s0      (awready_1_0),
        .aw_qv_s0        (aw_qv_1_0),
   
        .wdata_s0        (wdata_1_0),
        .wstrb_s0        (wstrb_1_0),   
        .wlast_s0        (wlast_1_0),
        .wvalid_s0       (wvalid_1_0),
        .wready_s0       (wready_1_0),

        .buser_s0        (buser_1_0),
        .bid_s0          (bid_1_0),
        .bresp_s0        (bresp_1_0),
        .bvalid_s0       (bvalid_1_0),
        .bready_s0       (bready_1_0),  

        .aruser_s0       (aruser_1_0),
        .arid_s0         (arid_1_0),
        .araddr_s0       (araddr_1_0),
        .arlen_s0        (arlen_1_0),
        .arsize_s0       (arsize_1_0),
        .arburst_s0      (arburst_1_0),
        .arlock_s0       (arlock_1_0),
        .arcache_s0      (arcache_1_0),
        .arprot_s0       (arprot_1_0),
        .arvalid_s0      (arvalid_1_0),
        .arvalid_vect_s0 (arvalid_vect_1_0),
        .arready_s0      (arready_1_0),
        .ar_qv_s0        (ar_qv_1_0),
   
        .ruser_s0        (ruser_1_0),
        .rid_s0          (rid_1_0),
        .rdata_s0        (rdata_1_0),
        .rresp_s0        (rresp_1_0),
        .rlast_s0        (rlast_1_0),
        .rvalid_s0       (rvalid_1_0),
        .rready_s0       (rready_1_0),


        .aclk       (aclk),
        .aresetn    (aresetn)
  ); 

nic400_switch1_ml_mlayer_1_sse710_main u_nic400_switch1_ml_mlayer1_sse710_main (
        .awuser_m       (awuser_m1),
        .awid_m         (awid_m1),
        .awaddr_m       (awaddr_m1),
        .awlen_m        (awlen_m1),
        .awsize_m       (awsize_m1),
        .awburst_m      (awburst_m1),
        .awlock_m       (awlock_m1),
        .awcache_m      (awcache_m1),
        .awprot_m       (awprot_m1),
        .awvalid_m      (awvalid_m1),
        .awvalid_vect_m (awvalid_vect_m1),
        .awready_m      (awready_m1),
        .aw_qv_m        (aw_qv_m1),
   
        .wdata_m        (wdata_m1),
        .wstrb_m        (wstrb_m1),   
        .wlast_m        (wlast_m1),
        .wvalid_m       (wvalid_m1),
        .wready_m       (wready_m1),

        .buser_m        (buser_m1),
        .bid_m          (bid_m1),
        .bresp_m        (bresp_m1),
        .bvalid_m       (bvalid_m1),
        .bready_m       (bready_m1),  

        .aruser_m       (aruser_m1),
        .arid_m         (arid_m1),
        .araddr_m       (araddr_m1),
        .arlen_m        (arlen_m1),
        .arsize_m       (arsize_m1),
        .arburst_m      (arburst_m1),
        .arlock_m       (arlock_m1),
        .arcache_m      (arcache_m1),
        .arprot_m       (arprot_m1),
        .arvalid_m      (arvalid_m1),
        .arvalid_vect_m (arvalid_vect_m1),
        .arready_m      (arready_m1),
        .ar_qv_m        (ar_qv_m1),
   
        .ruser_m        (ruser_m1),
        .rid_m          (rid_m1),
        .rdata_m        (rdata_m1),
        .rresp_m        (rresp_m1),
        .rlast_m        (rlast_m1),
        .rvalid_m       (rvalid_m1),
        .rready_m       (rready_m1),

        .awuser_s0       (awuser_0_1),
        .awid_s0         (awid_0_1),
        .awaddr_s0       (awaddr_0_1),
        .awlen_s0        (awlen_0_1),
        .awsize_s0       (awsize_0_1),
        .awburst_s0      (awburst_0_1),
        .awlock_s0       (awlock_0_1),
        .awcache_s0      (awcache_0_1),
        .awprot_s0       (awprot_0_1),
        .awvalid_s0      (awvalid_0_1),
        .awvalid_vect_s0 (awvalid_vect_0_1),
        .awready_s0      (awready_0_1),
        .aw_qv_s0        (aw_qv_0_1),
   
        .wdata_s0        (wdata_0_1),
        .wstrb_s0        (wstrb_0_1),   
        .wlast_s0        (wlast_0_1),
        .wvalid_s0       (wvalid_0_1),
        .wready_s0       (wready_0_1),

        .buser_s0        (buser_0_1),
        .bid_s0          (bid_0_1),
        .bresp_s0        (bresp_0_1),
        .bvalid_s0       (bvalid_0_1),
        .bready_s0       (bready_0_1),  

        .aruser_s0       (aruser_0_1),
        .arid_s0         (arid_0_1),
        .araddr_s0       (araddr_0_1),
        .arlen_s0        (arlen_0_1),
        .arsize_s0       (arsize_0_1),
        .arburst_s0      (arburst_0_1),
        .arlock_s0       (arlock_0_1),
        .arcache_s0      (arcache_0_1),
        .arprot_s0       (arprot_0_1),
        .arvalid_s0      (arvalid_0_1),
        .arvalid_vect_s0 (arvalid_vect_0_1),
        .arready_s0      (arready_0_1),
        .ar_qv_s0        (ar_qv_0_1),
   
        .ruser_s0        (ruser_0_1),
        .rid_s0          (rid_0_1),
        .rdata_s0        (rdata_0_1),
        .rresp_s0        (rresp_0_1),
        .rlast_s0        (rlast_0_1),
        .rvalid_s0       (rvalid_0_1),
        .rready_s0       (rready_0_1),


        .aclk       (aclk),
        .aresetn    (aresetn)
  ); 

nic400_switch1_ml_mlayer_2_sse710_main u_nic400_switch1_ml_mlayer2_sse710_main (
        .awuser_m       (awuser_m2),
        .awid_m         (awid_m2),
        .awaddr_m       (awaddr_m2),
        .awlen_m        (awlen_m2),
        .awsize_m       (awsize_m2),
        .awburst_m      (awburst_m2),
        .awlock_m       (awlock_m2),
        .awcache_m      (awcache_m2),
        .awprot_m       (awprot_m2),
        .awvalid_m      (awvalid_m2),
        .awvalid_vect_m (awvalid_vect_m2),
        .awready_m      (awready_m2),
        .aw_qv_m        (aw_qv_m2),
   
        .wdata_m        (wdata_m2),
        .wstrb_m        (wstrb_m2),   
        .wlast_m        (wlast_m2),
        .wvalid_m       (wvalid_m2),
        .wready_m       (wready_m2),

        .buser_m        (buser_m2),
        .bid_m          (bid_m2),
        .bresp_m        (bresp_m2),
        .bvalid_m       (bvalid_m2),
        .bready_m       (bready_m2),  

        .aruser_m       (aruser_m2),
        .arid_m         (arid_m2),
        .araddr_m       (araddr_m2),
        .arlen_m        (arlen_m2),
        .arsize_m       (arsize_m2),
        .arburst_m      (arburst_m2),
        .arlock_m       (arlock_m2),
        .arcache_m      (arcache_m2),
        .arprot_m       (arprot_m2),
        .arvalid_m      (arvalid_m2),
        .arvalid_vect_m (arvalid_vect_m2),
        .arready_m      (arready_m2),
        .ar_qv_m        (ar_qv_m2),
   
        .ruser_m        (ruser_m2),
        .rid_m          (rid_m2),
        .rdata_m        (rdata_m2),
        .rresp_m        (rresp_m2),
        .rlast_m        (rlast_m2),
        .rvalid_m       (rvalid_m2),
        .rready_m       (rready_m2),

        .awuser_s0       (awuser_0_2),
        .awid_s0         (awid_0_2),
        .awaddr_s0       (awaddr_0_2),
        .awlen_s0        (awlen_0_2),
        .awsize_s0       (awsize_0_2),
        .awburst_s0      (awburst_0_2),
        .awlock_s0       (awlock_0_2),
        .awcache_s0      (awcache_0_2),
        .awprot_s0       (awprot_0_2),
        .awvalid_s0      (awvalid_0_2),
        .awvalid_vect_s0 (awvalid_vect_0_2),
        .awready_s0      (awready_0_2),
        .aw_qv_s0        (aw_qv_0_2),
   
        .wdata_s0        (wdata_0_2),
        .wstrb_s0        (wstrb_0_2),   
        .wlast_s0        (wlast_0_2),
        .wvalid_s0       (wvalid_0_2),
        .wready_s0       (wready_0_2),

        .buser_s0        (buser_0_2),
        .bid_s0          (bid_0_2),
        .bresp_s0        (bresp_0_2),
        .bvalid_s0       (bvalid_0_2),
        .bready_s0       (bready_0_2),  

        .aruser_s0       (aruser_0_2),
        .arid_s0         (arid_0_2),
        .araddr_s0       (araddr_0_2),
        .arlen_s0        (arlen_0_2),
        .arsize_s0       (arsize_0_2),
        .arburst_s0      (arburst_0_2),
        .arlock_s0       (arlock_0_2),
        .arcache_s0      (arcache_0_2),
        .arprot_s0       (arprot_0_2),
        .arvalid_s0      (arvalid_0_2),
        .arvalid_vect_s0 (arvalid_vect_0_2),
        .arready_s0      (arready_0_2),
        .ar_qv_s0        (ar_qv_0_2),
   
        .ruser_s0        (ruser_0_2),
        .rid_s0          (rid_0_2),
        .rdata_s0        (rdata_0_2),
        .rresp_s0        (rresp_0_2),
        .rlast_s0        (rlast_0_2),
        .rvalid_s0       (rvalid_0_2),
        .rready_s0       (rready_0_2),


        .awuser_s1       (awuser_1_2),
        .awid_s1         (awid_1_2),
        .awaddr_s1       (awaddr_1_2),
        .awlen_s1        (awlen_1_2),
        .awsize_s1       (awsize_1_2),
        .awburst_s1      (awburst_1_2),
        .awlock_s1       (awlock_1_2),
        .awcache_s1      (awcache_1_2),
        .awprot_s1       (awprot_1_2),
        .awvalid_s1      (awvalid_1_2),
        .awvalid_vect_s1 (awvalid_vect_1_2),
        .awready_s1      (awready_1_2),
        .aw_qv_s1        (aw_qv_1_2),
   
        .wdata_s1        (wdata_1_2),
        .wstrb_s1        (wstrb_1_2),   
        .wlast_s1        (wlast_1_2),
        .wvalid_s1       (wvalid_1_2),
        .wready_s1       (wready_1_2),

        .buser_s1        (buser_1_2),
        .bid_s1          (bid_1_2),
        .bresp_s1        (bresp_1_2),
        .bvalid_s1       (bvalid_1_2),
        .bready_s1       (bready_1_2),  

        .aruser_s1       (aruser_1_2),
        .arid_s1         (arid_1_2),
        .araddr_s1       (araddr_1_2),
        .arlen_s1        (arlen_1_2),
        .arsize_s1       (arsize_1_2),
        .arburst_s1      (arburst_1_2),
        .arlock_s1       (arlock_1_2),
        .arcache_s1      (arcache_1_2),
        .arprot_s1       (arprot_1_2),
        .arvalid_s1      (arvalid_1_2),
        .arvalid_vect_s1 (arvalid_vect_1_2),
        .arready_s1      (arready_1_2),
        .ar_qv_s1        (ar_qv_1_2),
   
        .ruser_s1        (ruser_1_2),
        .rid_s1          (rid_1_2),
        .rdata_s1        (rdata_1_2),
        .rresp_s1        (rresp_1_2),
        .rlast_s1        (rlast_1_2),
        .rvalid_s1       (rvalid_1_2),
        .rready_s1       (rready_1_2),


        .aclk       (aclk),
        .aresetn    (aresetn)
  ); 




  endmodule


