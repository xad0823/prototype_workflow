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


module nic400_switch0_ml_map_sse710_sys_apb
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
   
    rid_m3,
    rdata_m3,
    rresp_m3,
    rlast_m3,
    rvalid_m3,
    rready_m3,

    awuser_m4,
    awid_m4,
    awaddr_m4,
    awlen_m4,
    awsize_m4,
    awburst_m4,
    awlock_m4,
    awcache_m4,
    awprot_m4,
    awvalid_m4,
    awvalid_vect_m4,
    awready_m4,
    aw_qv_m4,
   
    wdata_m4,
    wstrb_m4,   
    wlast_m4,
    wvalid_m4,
    wready_m4,

    bid_m4,
    bresp_m4,
    bvalid_m4,
    bready_m4,  

    aruser_m4,
    arid_m4,
    araddr_m4,
    arlen_m4,
    arsize_m4,
    arburst_m4,
    arlock_m4,
    arcache_m4,
    arprot_m4,
    arvalid_m4,
    arvalid_vect_m4,
    arready_m4,
    ar_qv_m4,
   
    rid_m4,
    rdata_m4,
    rresp_m4,
    rlast_m4,
    rvalid_m4,
    rready_m4,

    awuser_m5,
    awid_m5,
    awaddr_m5,
    awlen_m5,
    awsize_m5,
    awburst_m5,
    awlock_m5,
    awcache_m5,
    awprot_m5,
    awvalid_m5,
    awvalid_vect_m5,
    awready_m5,
    aw_qv_m5,
   
    wdata_m5,
    wstrb_m5,   
    wlast_m5,
    wvalid_m5,
    wready_m5,

    bid_m5,
    bresp_m5,
    bvalid_m5,
    bready_m5,  

    aruser_m5,
    arid_m5,
    araddr_m5,
    arlen_m5,
    arsize_m5,
    arburst_m5,
    arlock_m5,
    arcache_m5,
    arprot_m5,
    arvalid_m5,
    arvalid_vect_m5,
    arready_m5,
    ar_qv_m5,
   
    rid_m5,
    rdata_m5,
    rresp_m5,
    rlast_m5,
    rvalid_m5,
    rready_m5,

    awuser_m6,
    awid_m6,
    awaddr_m6,
    awlen_m6,
    awsize_m6,
    awburst_m6,
    awlock_m6,
    awcache_m6,
    awprot_m6,
    awvalid_m6,
    awvalid_vect_m6,
    awready_m6,
    aw_qv_m6,
   
    wdata_m6,
    wstrb_m6,   
    wlast_m6,
    wvalid_m6,
    wready_m6,

    bid_m6,
    bresp_m6,
    bvalid_m6,
    bready_m6,  

    aruser_m6,
    arid_m6,
    araddr_m6,
    arlen_m6,
    arsize_m6,
    arburst_m6,
    arlock_m6,
    arcache_m6,
    arprot_m6,
    arvalid_m6,
    arvalid_vect_m6,
    arready_m6,
    ar_qv_m6,
   
    rid_m6,
    rdata_m6,
    rresp_m6,
    rlast_m6,
    rvalid_m6,
    rready_m6,




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
   
    rid_0_2,
    rdata_0_2,
    rresp_0_2,
    rlast_0_2,
    rvalid_0_2,
    rready_0_2,



    awuser_0_3,
    awid_0_3,
    awaddr_0_3,
    awlen_0_3,
    awsize_0_3,
    awburst_0_3,
    awlock_0_3,
    awcache_0_3,
    awprot_0_3,
    awvalid_0_3,
    awvalid_vect_0_3,
    awready_0_3,
    aw_qv_0_3,
   
    wdata_0_3,
    wstrb_0_3,   
    wlast_0_3,
    wvalid_0_3,
    wready_0_3,

    bid_0_3,
    bresp_0_3,
    bvalid_0_3,
    bready_0_3,  

    aruser_0_3,
    arid_0_3,
    araddr_0_3,
    arlen_0_3,
    arsize_0_3,
    arburst_0_3,
    arlock_0_3,
    arcache_0_3,
    arprot_0_3,
    arvalid_0_3,
    arvalid_vect_0_3,
    arready_0_3,
    ar_qv_0_3,
   
    rid_0_3,
    rdata_0_3,
    rresp_0_3,
    rlast_0_3,
    rvalid_0_3,
    rready_0_3,



    awuser_0_4,
    awid_0_4,
    awaddr_0_4,
    awlen_0_4,
    awsize_0_4,
    awburst_0_4,
    awlock_0_4,
    awcache_0_4,
    awprot_0_4,
    awvalid_0_4,
    awvalid_vect_0_4,
    awready_0_4,
    aw_qv_0_4,
   
    wdata_0_4,
    wstrb_0_4,   
    wlast_0_4,
    wvalid_0_4,
    wready_0_4,

    bid_0_4,
    bresp_0_4,
    bvalid_0_4,
    bready_0_4,  

    aruser_0_4,
    arid_0_4,
    araddr_0_4,
    arlen_0_4,
    arsize_0_4,
    arburst_0_4,
    arlock_0_4,
    arcache_0_4,
    arprot_0_4,
    arvalid_0_4,
    arvalid_vect_0_4,
    arready_0_4,
    ar_qv_0_4,
   
    rid_0_4,
    rdata_0_4,
    rresp_0_4,
    rlast_0_4,
    rvalid_0_4,
    rready_0_4,



    awuser_0_5,
    awid_0_5,
    awaddr_0_5,
    awlen_0_5,
    awsize_0_5,
    awburst_0_5,
    awlock_0_5,
    awcache_0_5,
    awprot_0_5,
    awvalid_0_5,
    awvalid_vect_0_5,
    awready_0_5,
    aw_qv_0_5,
   
    wdata_0_5,
    wstrb_0_5,   
    wlast_0_5,
    wvalid_0_5,
    wready_0_5,

    bid_0_5,
    bresp_0_5,
    bvalid_0_5,
    bready_0_5,  

    aruser_0_5,
    arid_0_5,
    araddr_0_5,
    arlen_0_5,
    arsize_0_5,
    arburst_0_5,
    arlock_0_5,
    arcache_0_5,
    arprot_0_5,
    arvalid_0_5,
    arvalid_vect_0_5,
    arready_0_5,
    ar_qv_0_5,
   
    rid_0_5,
    rdata_0_5,
    rresp_0_5,
    rlast_0_5,
    rvalid_0_5,
    rready_0_5,



    awuser_0_6,
    awid_0_6,
    awaddr_0_6,
    awlen_0_6,
    awsize_0_6,
    awburst_0_6,
    awlock_0_6,
    awcache_0_6,
    awprot_0_6,
    awvalid_0_6,
    awvalid_vect_0_6,
    awready_0_6,
    aw_qv_0_6,
   
    wdata_0_6,
    wstrb_0_6,   
    wlast_0_6,
    wvalid_0_6,
    wready_0_6,

    bid_0_6,
    bresp_0_6,
    bvalid_0_6,
    bready_0_6,  

    aruser_0_6,
    arid_0_6,
    araddr_0_6,
    arlen_0_6,
    arsize_0_6,
    arburst_0_6,
    arlock_0_6,
    arcache_0_6,
    arprot_0_6,
    arvalid_0_6,
    arvalid_vect_0_6,
    arready_0_6,
    ar_qv_0_6,
   
    rid_0_6,
    rdata_0_6,
    rresp_0_6,
    rlast_0_6,
    rvalid_0_6,
    rready_0_6,


    aclk,
    aresetn
  );




    output [13:0]        awuser_m0;
    output [11:0]        awid_m0;
    output [31:0]       awaddr_m0;
    output [7:0]        awlen_m0;
    output [2:0]        awsize_m0;
    output [1:0]        awburst_m0;
    output              awlock_m0;
    output [3:0]        awcache_m0;
    output [2:0]        awprot_m0;
    output              awvalid_m0;
    output              awvalid_vect_m0;
    input               awready_m0;
    output [3:0]        aw_qv_m0;
   
    output [31:0]       wdata_m0;
    output [3:0]        wstrb_m0;   
    output              wlast_m0;
    output              wvalid_m0;
    input               wready_m0;

    input  [11:0]             bid_m0;
    input  [1:0]        bresp_m0;
    input               bvalid_m0;
    output              bready_m0;  

    output [13:0]        aruser_m0;
    output [11:0]        arid_m0;
    output [31:0]       araddr_m0;
    output [7:0]        arlen_m0;
    output [2:0]        arsize_m0;
    output [1:0]        arburst_m0;
    output              arlock_m0;
    output [3:0]        arcache_m0;
    output [2:0]        arprot_m0;
    output              arvalid_m0;
    output              arvalid_vect_m0;
    input               arready_m0;
    output [3:0]        ar_qv_m0;
   
    input  [11:0]        rid_m0;
    input  [31:0]       rdata_m0;
    input  [1:0]        rresp_m0;
    input               rlast_m0;
    input               rvalid_m0;
    output              rready_m0;

    output [13:0]        awuser_m1;
    output [11:0]        awid_m1;
    output [31:0]       awaddr_m1;
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

    input  [11:0]             bid_m1;
    input  [1:0]        bresp_m1;
    input               bvalid_m1;
    output              bready_m1;  

    output [13:0]        aruser_m1;
    output [11:0]        arid_m1;
    output [31:0]       araddr_m1;
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
   
    input  [11:0]        rid_m1;
    input  [31:0]       rdata_m1;
    input  [1:0]        rresp_m1;
    input               rlast_m1;
    input               rvalid_m1;
    output              rready_m1;

    output [13:0]        awuser_m2;
    output [11:0]        awid_m2;
    output [31:0]       awaddr_m2;
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

    input  [11:0]             bid_m2;
    input  [1:0]        bresp_m2;
    input               bvalid_m2;
    output              bready_m2;  

    output [13:0]        aruser_m2;
    output [11:0]        arid_m2;
    output [31:0]       araddr_m2;
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
   
    input  [11:0]        rid_m2;
    input  [31:0]       rdata_m2;
    input  [1:0]        rresp_m2;
    input               rlast_m2;
    input               rvalid_m2;
    output              rready_m2;

    output [13:0]        awuser_m3;
    output [11:0]        awid_m3;
    output [31:0]       awaddr_m3;
    output [7:0]        awlen_m3;
    output [2:0]        awsize_m3;
    output [1:0]        awburst_m3;
    output              awlock_m3;
    output [3:0]        awcache_m3;
    output [2:0]        awprot_m3;
    output              awvalid_m3;
    output              awvalid_vect_m3;
    input               awready_m3;
    output [3:0]        aw_qv_m3;
   
    output [31:0]       wdata_m3;
    output [3:0]        wstrb_m3;   
    output              wlast_m3;
    output              wvalid_m3;
    input               wready_m3;

    input  [11:0]             bid_m3;
    input  [1:0]        bresp_m3;
    input               bvalid_m3;
    output              bready_m3;  

    output [13:0]        aruser_m3;
    output [11:0]        arid_m3;
    output [31:0]       araddr_m3;
    output [7:0]        arlen_m3;
    output [2:0]        arsize_m3;
    output [1:0]        arburst_m3;
    output              arlock_m3;
    output [3:0]        arcache_m3;
    output [2:0]        arprot_m3;
    output              arvalid_m3;
    output              arvalid_vect_m3;
    input               arready_m3;
    output [3:0]        ar_qv_m3;
   
    input  [11:0]        rid_m3;
    input  [31:0]       rdata_m3;
    input  [1:0]        rresp_m3;
    input               rlast_m3;
    input               rvalid_m3;
    output              rready_m3;

    output [13:0]        awuser_m4;
    output [11:0]        awid_m4;
    output [31:0]       awaddr_m4;
    output [7:0]        awlen_m4;
    output [2:0]        awsize_m4;
    output [1:0]        awburst_m4;
    output              awlock_m4;
    output [3:0]        awcache_m4;
    output [2:0]        awprot_m4;
    output              awvalid_m4;
    output              awvalid_vect_m4;
    input               awready_m4;
    output [3:0]        aw_qv_m4;
   
    output [31:0]       wdata_m4;
    output [3:0]        wstrb_m4;   
    output              wlast_m4;
    output              wvalid_m4;
    input               wready_m4;

    input  [11:0]             bid_m4;
    input  [1:0]        bresp_m4;
    input               bvalid_m4;
    output              bready_m4;  

    output [13:0]        aruser_m4;
    output [11:0]        arid_m4;
    output [31:0]       araddr_m4;
    output [7:0]        arlen_m4;
    output [2:0]        arsize_m4;
    output [1:0]        arburst_m4;
    output              arlock_m4;
    output [3:0]        arcache_m4;
    output [2:0]        arprot_m4;
    output              arvalid_m4;
    output              arvalid_vect_m4;
    input               arready_m4;
    output [3:0]        ar_qv_m4;
   
    input  [11:0]        rid_m4;
    input  [31:0]       rdata_m4;
    input  [1:0]        rresp_m4;
    input               rlast_m4;
    input               rvalid_m4;
    output              rready_m4;

    output [13:0]        awuser_m5;
    output [11:0]        awid_m5;
    output [31:0]       awaddr_m5;
    output [7:0]        awlen_m5;
    output [2:0]        awsize_m5;
    output [1:0]        awburst_m5;
    output              awlock_m5;
    output [3:0]        awcache_m5;
    output [2:0]        awprot_m5;
    output              awvalid_m5;
    output              awvalid_vect_m5;
    input               awready_m5;
    output [3:0]        aw_qv_m5;
   
    output [31:0]       wdata_m5;
    output [3:0]        wstrb_m5;   
    output              wlast_m5;
    output              wvalid_m5;
    input               wready_m5;

    input  [11:0]             bid_m5;
    input  [1:0]        bresp_m5;
    input               bvalid_m5;
    output              bready_m5;  

    output [13:0]        aruser_m5;
    output [11:0]        arid_m5;
    output [31:0]       araddr_m5;
    output [7:0]        arlen_m5;
    output [2:0]        arsize_m5;
    output [1:0]        arburst_m5;
    output              arlock_m5;
    output [3:0]        arcache_m5;
    output [2:0]        arprot_m5;
    output              arvalid_m5;
    output              arvalid_vect_m5;
    input               arready_m5;
    output [3:0]        ar_qv_m5;
   
    input  [11:0]        rid_m5;
    input  [31:0]       rdata_m5;
    input  [1:0]        rresp_m5;
    input               rlast_m5;
    input               rvalid_m5;
    output              rready_m5;

    output [13:0]        awuser_m6;
    output [11:0]        awid_m6;
    output [31:0]       awaddr_m6;
    output [7:0]        awlen_m6;
    output [2:0]        awsize_m6;
    output [1:0]        awburst_m6;
    output              awlock_m6;
    output [3:0]        awcache_m6;
    output [2:0]        awprot_m6;
    output              awvalid_m6;
    output              awvalid_vect_m6;
    input               awready_m6;
    output [3:0]        aw_qv_m6;
   
    output [31:0]       wdata_m6;
    output [3:0]        wstrb_m6;   
    output              wlast_m6;
    output              wvalid_m6;
    input               wready_m6;

    input  [11:0]             bid_m6;
    input  [1:0]        bresp_m6;
    input               bvalid_m6;
    output              bready_m6;  

    output [13:0]        aruser_m6;
    output [11:0]        arid_m6;
    output [31:0]       araddr_m6;
    output [7:0]        arlen_m6;
    output [2:0]        arsize_m6;
    output [1:0]        arburst_m6;
    output              arlock_m6;
    output [3:0]        arcache_m6;
    output [2:0]        arprot_m6;
    output              arvalid_m6;
    output              arvalid_vect_m6;
    input               arready_m6;
    output [3:0]        ar_qv_m6;
   
    input  [11:0]        rid_m6;
    input  [31:0]       rdata_m6;
    input  [1:0]        rresp_m6;
    input               rlast_m6;
    input               rvalid_m6;
    output              rready_m6;




    input  [13:0]        awuser_0_0;
    input  [11:0]        awid_0_0;
    input  [31:0]       awaddr_0_0;
    input  [7:0]        awlen_0_0;
    input  [2:0]        awsize_0_0;
    input  [1:0]        awburst_0_0;
    input               awlock_0_0;
    input  [3:0]        awcache_0_0;
    input  [2:0]        awprot_0_0;
    input               awvalid_0_0;
    input               awvalid_vect_0_0;
    output              awready_0_0;
    input [3:0]         aw_qv_0_0;
   
    input [31:0]        wdata_0_0;
    input [3:0]         wstrb_0_0;   
    input               wlast_0_0;
    input               wvalid_0_0;
    output              wready_0_0;

    output [11:0]        bid_0_0;
    output [1:0]        bresp_0_0;
    output              bvalid_0_0;
    input               bready_0_0;  

    input  [13:0]        aruser_0_0;
    input  [11:0]        arid_0_0;
    input  [31:0]       araddr_0_0;
    input  [7:0]        arlen_0_0;
    input  [2:0]        arsize_0_0;
    input  [1:0]        arburst_0_0;
    input               arlock_0_0;
    input  [3:0]        arcache_0_0;
    input  [2:0]        arprot_0_0;
    input               arvalid_0_0;
    input               arvalid_vect_0_0;
    output              arready_0_0;
    input [3:0]         ar_qv_0_0;
   
    output [11:0]        rid_0_0;
    output [31:0]       rdata_0_0;
    output [1:0]        rresp_0_0;
    output              rlast_0_0;
    output              rvalid_0_0;
    input               rready_0_0;



    input  [13:0]        awuser_0_1;
    input  [11:0]        awid_0_1;
    input  [31:0]       awaddr_0_1;
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

    output [11:0]        bid_0_1;
    output [1:0]        bresp_0_1;
    output              bvalid_0_1;
    input               bready_0_1;  

    input  [13:0]        aruser_0_1;
    input  [11:0]        arid_0_1;
    input  [31:0]       araddr_0_1;
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
   
    output [11:0]        rid_0_1;
    output [31:0]       rdata_0_1;
    output [1:0]        rresp_0_1;
    output              rlast_0_1;
    output              rvalid_0_1;
    input               rready_0_1;



    input  [13:0]        awuser_0_2;
    input  [11:0]        awid_0_2;
    input  [31:0]       awaddr_0_2;
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

    output [11:0]        bid_0_2;
    output [1:0]        bresp_0_2;
    output              bvalid_0_2;
    input               bready_0_2;  

    input  [13:0]        aruser_0_2;
    input  [11:0]        arid_0_2;
    input  [31:0]       araddr_0_2;
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
   
    output [11:0]        rid_0_2;
    output [31:0]       rdata_0_2;
    output [1:0]        rresp_0_2;
    output              rlast_0_2;
    output              rvalid_0_2;
    input               rready_0_2;



    input  [13:0]        awuser_0_3;
    input  [11:0]        awid_0_3;
    input  [31:0]       awaddr_0_3;
    input  [7:0]        awlen_0_3;
    input  [2:0]        awsize_0_3;
    input  [1:0]        awburst_0_3;
    input               awlock_0_3;
    input  [3:0]        awcache_0_3;
    input  [2:0]        awprot_0_3;
    input               awvalid_0_3;
    input               awvalid_vect_0_3;
    output              awready_0_3;
    input [3:0]         aw_qv_0_3;
   
    input [31:0]        wdata_0_3;
    input [3:0]         wstrb_0_3;   
    input               wlast_0_3;
    input               wvalid_0_3;
    output              wready_0_3;

    output [11:0]        bid_0_3;
    output [1:0]        bresp_0_3;
    output              bvalid_0_3;
    input               bready_0_3;  

    input  [13:0]        aruser_0_3;
    input  [11:0]        arid_0_3;
    input  [31:0]       araddr_0_3;
    input  [7:0]        arlen_0_3;
    input  [2:0]        arsize_0_3;
    input  [1:0]        arburst_0_3;
    input               arlock_0_3;
    input  [3:0]        arcache_0_3;
    input  [2:0]        arprot_0_3;
    input               arvalid_0_3;
    input               arvalid_vect_0_3;
    output              arready_0_3;
    input [3:0]         ar_qv_0_3;
   
    output [11:0]        rid_0_3;
    output [31:0]       rdata_0_3;
    output [1:0]        rresp_0_3;
    output              rlast_0_3;
    output              rvalid_0_3;
    input               rready_0_3;



    input  [13:0]        awuser_0_4;
    input  [11:0]        awid_0_4;
    input  [31:0]       awaddr_0_4;
    input  [7:0]        awlen_0_4;
    input  [2:0]        awsize_0_4;
    input  [1:0]        awburst_0_4;
    input               awlock_0_4;
    input  [3:0]        awcache_0_4;
    input  [2:0]        awprot_0_4;
    input               awvalid_0_4;
    input               awvalid_vect_0_4;
    output              awready_0_4;
    input [3:0]         aw_qv_0_4;
   
    input [31:0]        wdata_0_4;
    input [3:0]         wstrb_0_4;   
    input               wlast_0_4;
    input               wvalid_0_4;
    output              wready_0_4;

    output [11:0]        bid_0_4;
    output [1:0]        bresp_0_4;
    output              bvalid_0_4;
    input               bready_0_4;  

    input  [13:0]        aruser_0_4;
    input  [11:0]        arid_0_4;
    input  [31:0]       araddr_0_4;
    input  [7:0]        arlen_0_4;
    input  [2:0]        arsize_0_4;
    input  [1:0]        arburst_0_4;
    input               arlock_0_4;
    input  [3:0]        arcache_0_4;
    input  [2:0]        arprot_0_4;
    input               arvalid_0_4;
    input               arvalid_vect_0_4;
    output              arready_0_4;
    input [3:0]         ar_qv_0_4;
   
    output [11:0]        rid_0_4;
    output [31:0]       rdata_0_4;
    output [1:0]        rresp_0_4;
    output              rlast_0_4;
    output              rvalid_0_4;
    input               rready_0_4;



    input  [13:0]        awuser_0_5;
    input  [11:0]        awid_0_5;
    input  [31:0]       awaddr_0_5;
    input  [7:0]        awlen_0_5;
    input  [2:0]        awsize_0_5;
    input  [1:0]        awburst_0_5;
    input               awlock_0_5;
    input  [3:0]        awcache_0_5;
    input  [2:0]        awprot_0_5;
    input               awvalid_0_5;
    input               awvalid_vect_0_5;
    output              awready_0_5;
    input [3:0]         aw_qv_0_5;
   
    input [31:0]        wdata_0_5;
    input [3:0]         wstrb_0_5;   
    input               wlast_0_5;
    input               wvalid_0_5;
    output              wready_0_5;

    output [11:0]        bid_0_5;
    output [1:0]        bresp_0_5;
    output              bvalid_0_5;
    input               bready_0_5;  

    input  [13:0]        aruser_0_5;
    input  [11:0]        arid_0_5;
    input  [31:0]       araddr_0_5;
    input  [7:0]        arlen_0_5;
    input  [2:0]        arsize_0_5;
    input  [1:0]        arburst_0_5;
    input               arlock_0_5;
    input  [3:0]        arcache_0_5;
    input  [2:0]        arprot_0_5;
    input               arvalid_0_5;
    input               arvalid_vect_0_5;
    output              arready_0_5;
    input [3:0]         ar_qv_0_5;
   
    output [11:0]        rid_0_5;
    output [31:0]       rdata_0_5;
    output [1:0]        rresp_0_5;
    output              rlast_0_5;
    output              rvalid_0_5;
    input               rready_0_5;



    input  [13:0]        awuser_0_6;
    input  [11:0]        awid_0_6;
    input  [31:0]       awaddr_0_6;
    input  [7:0]        awlen_0_6;
    input  [2:0]        awsize_0_6;
    input  [1:0]        awburst_0_6;
    input               awlock_0_6;
    input  [3:0]        awcache_0_6;
    input  [2:0]        awprot_0_6;
    input               awvalid_0_6;
    input               awvalid_vect_0_6;
    output              awready_0_6;
    input [3:0]         aw_qv_0_6;
   
    input [31:0]        wdata_0_6;
    input [3:0]         wstrb_0_6;   
    input               wlast_0_6;
    input               wvalid_0_6;
    output              wready_0_6;

    output [11:0]        bid_0_6;
    output [1:0]        bresp_0_6;
    output              bvalid_0_6;
    input               bready_0_6;  

    input  [13:0]        aruser_0_6;
    input  [11:0]        arid_0_6;
    input  [31:0]       araddr_0_6;
    input  [7:0]        arlen_0_6;
    input  [2:0]        arsize_0_6;
    input  [1:0]        arburst_0_6;
    input               arlock_0_6;
    input  [3:0]        arcache_0_6;
    input  [2:0]        arprot_0_6;
    input               arvalid_0_6;
    input               arvalid_vect_0_6;
    output              arready_0_6;
    input [3:0]         ar_qv_0_6;
   
    output [11:0]        rid_0_6;
    output [31:0]       rdata_0_6;
    output [1:0]        rresp_0_6;
    output              rlast_0_6;
    output              rvalid_0_6;
    input               rready_0_6;


    input               aclk;
    input               aresetn;




nic400_switch0_ml_mlayer_0_sse710_sys_apb u_nic400_switch0_ml_mlayer0_sse710_sys_apb (
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
   
        .rid_m          (rid_m0),
        .rdata_m        (rdata_m0),
        .rresp_m        (rresp_m0),
        .rlast_m        (rlast_m0),
        .rvalid_m       (rvalid_m0),
        .rready_m       (rready_m0),

        .awuser_s0       (awuser_0_0),
        .awid_s0         (awid_0_0),
        .awaddr_s0       (awaddr_0_0),
        .awlen_s0        (awlen_0_0),
        .awsize_s0       (awsize_0_0),
        .awburst_s0      (awburst_0_0),
        .awlock_s0       (awlock_0_0),
        .awcache_s0      (awcache_0_0),
        .awprot_s0       (awprot_0_0),
        .awvalid_s0      (awvalid_0_0),
        .awvalid_vect_s0 (awvalid_vect_0_0),
        .awready_s0      (awready_0_0),
        .aw_qv_s0        (aw_qv_0_0),
   
        .wdata_s0        (wdata_0_0),
        .wstrb_s0        (wstrb_0_0),   
        .wlast_s0        (wlast_0_0),
        .wvalid_s0       (wvalid_0_0),
        .wready_s0       (wready_0_0),

        .bid_s0          (bid_0_0),
        .bresp_s0        (bresp_0_0),
        .bvalid_s0       (bvalid_0_0),
        .bready_s0       (bready_0_0),  

        .aruser_s0       (aruser_0_0),
        .arid_s0         (arid_0_0),
        .araddr_s0       (araddr_0_0),
        .arlen_s0        (arlen_0_0),
        .arsize_s0       (arsize_0_0),
        .arburst_s0      (arburst_0_0),
        .arlock_s0       (arlock_0_0),
        .arcache_s0      (arcache_0_0),
        .arprot_s0       (arprot_0_0),
        .arvalid_s0      (arvalid_0_0),
        .arvalid_vect_s0 (arvalid_vect_0_0),
        .arready_s0      (arready_0_0),
        .ar_qv_s0        (ar_qv_0_0),
   
        .rid_s0          (rid_0_0),
        .rdata_s0        (rdata_0_0),
        .rresp_s0        (rresp_0_0),
        .rlast_s0        (rlast_0_0),
        .rvalid_s0       (rvalid_0_0),
        .rready_s0       (rready_0_0),


        .aclk       (aclk),
        .aresetn    (aresetn)
  ); 

nic400_switch0_ml_mlayer_1_sse710_sys_apb u_nic400_switch0_ml_mlayer1_sse710_sys_apb (
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
   
        .rid_s0          (rid_0_1),
        .rdata_s0        (rdata_0_1),
        .rresp_s0        (rresp_0_1),
        .rlast_s0        (rlast_0_1),
        .rvalid_s0       (rvalid_0_1),
        .rready_s0       (rready_0_1),


        .aclk       (aclk),
        .aresetn    (aresetn)
  ); 

nic400_switch0_ml_mlayer_2_sse710_sys_apb u_nic400_switch0_ml_mlayer2_sse710_sys_apb (
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
   
        .rid_s0          (rid_0_2),
        .rdata_s0        (rdata_0_2),
        .rresp_s0        (rresp_0_2),
        .rlast_s0        (rlast_0_2),
        .rvalid_s0       (rvalid_0_2),
        .rready_s0       (rready_0_2),


        .aclk       (aclk),
        .aresetn    (aresetn)
  ); 

nic400_switch0_ml_mlayer_3_sse710_sys_apb u_nic400_switch0_ml_mlayer3_sse710_sys_apb (
        .awuser_m       (awuser_m3),
        .awid_m         (awid_m3),
        .awaddr_m       (awaddr_m3),
        .awlen_m        (awlen_m3),
        .awsize_m       (awsize_m3),
        .awburst_m      (awburst_m3),
        .awlock_m       (awlock_m3),
        .awcache_m      (awcache_m3),
        .awprot_m       (awprot_m3),
        .awvalid_m      (awvalid_m3),
        .awvalid_vect_m (awvalid_vect_m3),
        .awready_m      (awready_m3),
        .aw_qv_m        (aw_qv_m3),
   
        .wdata_m        (wdata_m3),
        .wstrb_m        (wstrb_m3),   
        .wlast_m        (wlast_m3),
        .wvalid_m       (wvalid_m3),
        .wready_m       (wready_m3),

        .bid_m          (bid_m3),
        .bresp_m        (bresp_m3),
        .bvalid_m       (bvalid_m3),
        .bready_m       (bready_m3),  

        .aruser_m       (aruser_m3),
        .arid_m         (arid_m3),
        .araddr_m       (araddr_m3),
        .arlen_m        (arlen_m3),
        .arsize_m       (arsize_m3),
        .arburst_m      (arburst_m3),
        .arlock_m       (arlock_m3),
        .arcache_m      (arcache_m3),
        .arprot_m       (arprot_m3),
        .arvalid_m      (arvalid_m3),
        .arvalid_vect_m (arvalid_vect_m3),
        .arready_m      (arready_m3),
        .ar_qv_m        (ar_qv_m3),
   
        .rid_m          (rid_m3),
        .rdata_m        (rdata_m3),
        .rresp_m        (rresp_m3),
        .rlast_m        (rlast_m3),
        .rvalid_m       (rvalid_m3),
        .rready_m       (rready_m3),

        .awuser_s0       (awuser_0_3),
        .awid_s0         (awid_0_3),
        .awaddr_s0       (awaddr_0_3),
        .awlen_s0        (awlen_0_3),
        .awsize_s0       (awsize_0_3),
        .awburst_s0      (awburst_0_3),
        .awlock_s0       (awlock_0_3),
        .awcache_s0      (awcache_0_3),
        .awprot_s0       (awprot_0_3),
        .awvalid_s0      (awvalid_0_3),
        .awvalid_vect_s0 (awvalid_vect_0_3),
        .awready_s0      (awready_0_3),
        .aw_qv_s0        (aw_qv_0_3),
   
        .wdata_s0        (wdata_0_3),
        .wstrb_s0        (wstrb_0_3),   
        .wlast_s0        (wlast_0_3),
        .wvalid_s0       (wvalid_0_3),
        .wready_s0       (wready_0_3),

        .bid_s0          (bid_0_3),
        .bresp_s0        (bresp_0_3),
        .bvalid_s0       (bvalid_0_3),
        .bready_s0       (bready_0_3),  

        .aruser_s0       (aruser_0_3),
        .arid_s0         (arid_0_3),
        .araddr_s0       (araddr_0_3),
        .arlen_s0        (arlen_0_3),
        .arsize_s0       (arsize_0_3),
        .arburst_s0      (arburst_0_3),
        .arlock_s0       (arlock_0_3),
        .arcache_s0      (arcache_0_3),
        .arprot_s0       (arprot_0_3),
        .arvalid_s0      (arvalid_0_3),
        .arvalid_vect_s0 (arvalid_vect_0_3),
        .arready_s0      (arready_0_3),
        .ar_qv_s0        (ar_qv_0_3),
   
        .rid_s0          (rid_0_3),
        .rdata_s0        (rdata_0_3),
        .rresp_s0        (rresp_0_3),
        .rlast_s0        (rlast_0_3),
        .rvalid_s0       (rvalid_0_3),
        .rready_s0       (rready_0_3),


        .aclk       (aclk),
        .aresetn    (aresetn)
  ); 

nic400_switch0_ml_mlayer_4_sse710_sys_apb u_nic400_switch0_ml_mlayer4_sse710_sys_apb (
        .awuser_m       (awuser_m4),
        .awid_m         (awid_m4),
        .awaddr_m       (awaddr_m4),
        .awlen_m        (awlen_m4),
        .awsize_m       (awsize_m4),
        .awburst_m      (awburst_m4),
        .awlock_m       (awlock_m4),
        .awcache_m      (awcache_m4),
        .awprot_m       (awprot_m4),
        .awvalid_m      (awvalid_m4),
        .awvalid_vect_m (awvalid_vect_m4),
        .awready_m      (awready_m4),
        .aw_qv_m        (aw_qv_m4),
   
        .wdata_m        (wdata_m4),
        .wstrb_m        (wstrb_m4),   
        .wlast_m        (wlast_m4),
        .wvalid_m       (wvalid_m4),
        .wready_m       (wready_m4),

        .bid_m          (bid_m4),
        .bresp_m        (bresp_m4),
        .bvalid_m       (bvalid_m4),
        .bready_m       (bready_m4),  

        .aruser_m       (aruser_m4),
        .arid_m         (arid_m4),
        .araddr_m       (araddr_m4),
        .arlen_m        (arlen_m4),
        .arsize_m       (arsize_m4),
        .arburst_m      (arburst_m4),
        .arlock_m       (arlock_m4),
        .arcache_m      (arcache_m4),
        .arprot_m       (arprot_m4),
        .arvalid_m      (arvalid_m4),
        .arvalid_vect_m (arvalid_vect_m4),
        .arready_m      (arready_m4),
        .ar_qv_m        (ar_qv_m4),
   
        .rid_m          (rid_m4),
        .rdata_m        (rdata_m4),
        .rresp_m        (rresp_m4),
        .rlast_m        (rlast_m4),
        .rvalid_m       (rvalid_m4),
        .rready_m       (rready_m4),

        .awuser_s0       (awuser_0_4),
        .awid_s0         (awid_0_4),
        .awaddr_s0       (awaddr_0_4),
        .awlen_s0        (awlen_0_4),
        .awsize_s0       (awsize_0_4),
        .awburst_s0      (awburst_0_4),
        .awlock_s0       (awlock_0_4),
        .awcache_s0      (awcache_0_4),
        .awprot_s0       (awprot_0_4),
        .awvalid_s0      (awvalid_0_4),
        .awvalid_vect_s0 (awvalid_vect_0_4),
        .awready_s0      (awready_0_4),
        .aw_qv_s0        (aw_qv_0_4),
   
        .wdata_s0        (wdata_0_4),
        .wstrb_s0        (wstrb_0_4),   
        .wlast_s0        (wlast_0_4),
        .wvalid_s0       (wvalid_0_4),
        .wready_s0       (wready_0_4),

        .bid_s0          (bid_0_4),
        .bresp_s0        (bresp_0_4),
        .bvalid_s0       (bvalid_0_4),
        .bready_s0       (bready_0_4),  

        .aruser_s0       (aruser_0_4),
        .arid_s0         (arid_0_4),
        .araddr_s0       (araddr_0_4),
        .arlen_s0        (arlen_0_4),
        .arsize_s0       (arsize_0_4),
        .arburst_s0      (arburst_0_4),
        .arlock_s0       (arlock_0_4),
        .arcache_s0      (arcache_0_4),
        .arprot_s0       (arprot_0_4),
        .arvalid_s0      (arvalid_0_4),
        .arvalid_vect_s0 (arvalid_vect_0_4),
        .arready_s0      (arready_0_4),
        .ar_qv_s0        (ar_qv_0_4),
   
        .rid_s0          (rid_0_4),
        .rdata_s0        (rdata_0_4),
        .rresp_s0        (rresp_0_4),
        .rlast_s0        (rlast_0_4),
        .rvalid_s0       (rvalid_0_4),
        .rready_s0       (rready_0_4),


        .aclk       (aclk),
        .aresetn    (aresetn)
  ); 

nic400_switch0_ml_mlayer_5_sse710_sys_apb u_nic400_switch0_ml_mlayer5_sse710_sys_apb (
        .awuser_m       (awuser_m5),
        .awid_m         (awid_m5),
        .awaddr_m       (awaddr_m5),
        .awlen_m        (awlen_m5),
        .awsize_m       (awsize_m5),
        .awburst_m      (awburst_m5),
        .awlock_m       (awlock_m5),
        .awcache_m      (awcache_m5),
        .awprot_m       (awprot_m5),
        .awvalid_m      (awvalid_m5),
        .awvalid_vect_m (awvalid_vect_m5),
        .awready_m      (awready_m5),
        .aw_qv_m        (aw_qv_m5),
   
        .wdata_m        (wdata_m5),
        .wstrb_m        (wstrb_m5),   
        .wlast_m        (wlast_m5),
        .wvalid_m       (wvalid_m5),
        .wready_m       (wready_m5),

        .bid_m          (bid_m5),
        .bresp_m        (bresp_m5),
        .bvalid_m       (bvalid_m5),
        .bready_m       (bready_m5),  

        .aruser_m       (aruser_m5),
        .arid_m         (arid_m5),
        .araddr_m       (araddr_m5),
        .arlen_m        (arlen_m5),
        .arsize_m       (arsize_m5),
        .arburst_m      (arburst_m5),
        .arlock_m       (arlock_m5),
        .arcache_m      (arcache_m5),
        .arprot_m       (arprot_m5),
        .arvalid_m      (arvalid_m5),
        .arvalid_vect_m (arvalid_vect_m5),
        .arready_m      (arready_m5),
        .ar_qv_m        (ar_qv_m5),
   
        .rid_m          (rid_m5),
        .rdata_m        (rdata_m5),
        .rresp_m        (rresp_m5),
        .rlast_m        (rlast_m5),
        .rvalid_m       (rvalid_m5),
        .rready_m       (rready_m5),

        .awuser_s0       (awuser_0_5),
        .awid_s0         (awid_0_5),
        .awaddr_s0       (awaddr_0_5),
        .awlen_s0        (awlen_0_5),
        .awsize_s0       (awsize_0_5),
        .awburst_s0      (awburst_0_5),
        .awlock_s0       (awlock_0_5),
        .awcache_s0      (awcache_0_5),
        .awprot_s0       (awprot_0_5),
        .awvalid_s0      (awvalid_0_5),
        .awvalid_vect_s0 (awvalid_vect_0_5),
        .awready_s0      (awready_0_5),
        .aw_qv_s0        (aw_qv_0_5),
   
        .wdata_s0        (wdata_0_5),
        .wstrb_s0        (wstrb_0_5),   
        .wlast_s0        (wlast_0_5),
        .wvalid_s0       (wvalid_0_5),
        .wready_s0       (wready_0_5),

        .bid_s0          (bid_0_5),
        .bresp_s0        (bresp_0_5),
        .bvalid_s0       (bvalid_0_5),
        .bready_s0       (bready_0_5),  

        .aruser_s0       (aruser_0_5),
        .arid_s0         (arid_0_5),
        .araddr_s0       (araddr_0_5),
        .arlen_s0        (arlen_0_5),
        .arsize_s0       (arsize_0_5),
        .arburst_s0      (arburst_0_5),
        .arlock_s0       (arlock_0_5),
        .arcache_s0      (arcache_0_5),
        .arprot_s0       (arprot_0_5),
        .arvalid_s0      (arvalid_0_5),
        .arvalid_vect_s0 (arvalid_vect_0_5),
        .arready_s0      (arready_0_5),
        .ar_qv_s0        (ar_qv_0_5),
   
        .rid_s0          (rid_0_5),
        .rdata_s0        (rdata_0_5),
        .rresp_s0        (rresp_0_5),
        .rlast_s0        (rlast_0_5),
        .rvalid_s0       (rvalid_0_5),
        .rready_s0       (rready_0_5),


        .aclk       (aclk),
        .aresetn    (aresetn)
  ); 

nic400_switch0_ml_mlayer_6_sse710_sys_apb u_nic400_switch0_ml_mlayer6_sse710_sys_apb (
        .awuser_m       (awuser_m6),
        .awid_m         (awid_m6),
        .awaddr_m       (awaddr_m6),
        .awlen_m        (awlen_m6),
        .awsize_m       (awsize_m6),
        .awburst_m      (awburst_m6),
        .awlock_m       (awlock_m6),
        .awcache_m      (awcache_m6),
        .awprot_m       (awprot_m6),
        .awvalid_m      (awvalid_m6),
        .awvalid_vect_m (awvalid_vect_m6),
        .awready_m      (awready_m6),
        .aw_qv_m        (aw_qv_m6),
   
        .wdata_m        (wdata_m6),
        .wstrb_m        (wstrb_m6),   
        .wlast_m        (wlast_m6),
        .wvalid_m       (wvalid_m6),
        .wready_m       (wready_m6),

        .bid_m          (bid_m6),
        .bresp_m        (bresp_m6),
        .bvalid_m       (bvalid_m6),
        .bready_m       (bready_m6),  

        .aruser_m       (aruser_m6),
        .arid_m         (arid_m6),
        .araddr_m       (araddr_m6),
        .arlen_m        (arlen_m6),
        .arsize_m       (arsize_m6),
        .arburst_m      (arburst_m6),
        .arlock_m       (arlock_m6),
        .arcache_m      (arcache_m6),
        .arprot_m       (arprot_m6),
        .arvalid_m      (arvalid_m6),
        .arvalid_vect_m (arvalid_vect_m6),
        .arready_m      (arready_m6),
        .ar_qv_m        (ar_qv_m6),
   
        .rid_m          (rid_m6),
        .rdata_m        (rdata_m6),
        .rresp_m        (rresp_m6),
        .rlast_m        (rlast_m6),
        .rvalid_m       (rvalid_m6),
        .rready_m       (rready_m6),

        .awuser_s0       (awuser_0_6),
        .awid_s0         (awid_0_6),
        .awaddr_s0       (awaddr_0_6),
        .awlen_s0        (awlen_0_6),
        .awsize_s0       (awsize_0_6),
        .awburst_s0      (awburst_0_6),
        .awlock_s0       (awlock_0_6),
        .awcache_s0      (awcache_0_6),
        .awprot_s0       (awprot_0_6),
        .awvalid_s0      (awvalid_0_6),
        .awvalid_vect_s0 (awvalid_vect_0_6),
        .awready_s0      (awready_0_6),
        .aw_qv_s0        (aw_qv_0_6),
   
        .wdata_s0        (wdata_0_6),
        .wstrb_s0        (wstrb_0_6),   
        .wlast_s0        (wlast_0_6),
        .wvalid_s0       (wvalid_0_6),
        .wready_s0       (wready_0_6),

        .bid_s0          (bid_0_6),
        .bresp_s0        (bresp_0_6),
        .bvalid_s0       (bvalid_0_6),
        .bready_s0       (bready_0_6),  

        .aruser_s0       (aruser_0_6),
        .arid_s0         (arid_0_6),
        .araddr_s0       (araddr_0_6),
        .arlen_s0        (arlen_0_6),
        .arsize_s0       (arsize_0_6),
        .arburst_s0      (arburst_0_6),
        .arlock_s0       (arlock_0_6),
        .arcache_s0      (arcache_0_6),
        .arprot_s0       (arprot_0_6),
        .arvalid_s0      (arvalid_0_6),
        .arvalid_vect_s0 (arvalid_vect_0_6),
        .arready_s0      (arready_0_6),
        .ar_qv_s0        (ar_qv_0_6),
   
        .rid_s0          (rid_0_6),
        .rdata_s0        (rdata_0_6),
        .rresp_s0        (rresp_0_6),
        .rlast_s0        (rlast_0_6),
        .rvalid_s0       (rvalid_0_6),
        .rready_s0       (rready_0_6),


        .aclk       (aclk),
        .aresetn    (aresetn)
  ); 




  endmodule


