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


module nic400_bm0_ml_map_secenc_f1
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
   
    rid_1_2,
    rdata_1_2,
    rresp_1_2,
    rlast_1_2,
    rvalid_1_2,
    rready_1_2,



    awuser_1_3,
    awid_1_3,
    awaddr_1_3,
    awlen_1_3,
    awsize_1_3,
    awburst_1_3,
    awlock_1_3,
    awcache_1_3,
    awprot_1_3,
    awvalid_1_3,
    awvalid_vect_1_3,
    awready_1_3,
    aw_qv_1_3,
   
    wdata_1_3,
    wstrb_1_3,   
    wlast_1_3,
    wvalid_1_3,
    wready_1_3,

    bid_1_3,
    bresp_1_3,
    bvalid_1_3,
    bready_1_3,  

    aruser_1_3,
    arid_1_3,
    araddr_1_3,
    arlen_1_3,
    arsize_1_3,
    arburst_1_3,
    arlock_1_3,
    arcache_1_3,
    arprot_1_3,
    arvalid_1_3,
    arvalid_vect_1_3,
    arready_1_3,
    ar_qv_1_3,
   
    rid_1_3,
    rdata_1_3,
    rresp_1_3,
    rlast_1_3,
    rvalid_1_3,
    rready_1_3,



    awuser_1_4,
    awid_1_4,
    awaddr_1_4,
    awlen_1_4,
    awsize_1_4,
    awburst_1_4,
    awlock_1_4,
    awcache_1_4,
    awprot_1_4,
    awvalid_1_4,
    awvalid_vect_1_4,
    awready_1_4,
    aw_qv_1_4,
   
    wdata_1_4,
    wstrb_1_4,   
    wlast_1_4,
    wvalid_1_4,
    wready_1_4,

    bid_1_4,
    bresp_1_4,
    bvalid_1_4,
    bready_1_4,  

    aruser_1_4,
    arid_1_4,
    araddr_1_4,
    arlen_1_4,
    arsize_1_4,
    arburst_1_4,
    arlock_1_4,
    arcache_1_4,
    arprot_1_4,
    arvalid_1_4,
    arvalid_vect_1_4,
    arready_1_4,
    ar_qv_1_4,
   
    rid_1_4,
    rdata_1_4,
    rresp_1_4,
    rlast_1_4,
    rvalid_1_4,
    rready_1_4,


    aclk,
    aresetn
  );




    output [1:0]        awuser_m0;
    output              awid_m0;
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

    input                    bid_m0;
    input  [1:0]        bresp_m0;
    input               bvalid_m0;
    output              bready_m0;  

    output [1:0]        aruser_m0;
    output              arid_m0;
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
   
    input               rid_m0;
    input  [31:0]       rdata_m0;
    input  [1:0]        rresp_m0;
    input               rlast_m0;
    input               rvalid_m0;
    output              rready_m0;

    output [1:0]        awuser_m1;
    output              awid_m1;
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

    input                    bid_m1;
    input  [1:0]        bresp_m1;
    input               bvalid_m1;
    output              bready_m1;  

    output [1:0]        aruser_m1;
    output              arid_m1;
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
   
    input               rid_m1;
    input  [31:0]       rdata_m1;
    input  [1:0]        rresp_m1;
    input               rlast_m1;
    input               rvalid_m1;
    output              rready_m1;

    output [1:0]        awuser_m2;
    output              awid_m2;
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

    input                    bid_m2;
    input  [1:0]        bresp_m2;
    input               bvalid_m2;
    output              bready_m2;  

    output [1:0]        aruser_m2;
    output              arid_m2;
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
   
    input               rid_m2;
    input  [31:0]       rdata_m2;
    input  [1:0]        rresp_m2;
    input               rlast_m2;
    input               rvalid_m2;
    output              rready_m2;

    output [1:0]        awuser_m3;
    output              awid_m3;
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

    input                    bid_m3;
    input  [1:0]        bresp_m3;
    input               bvalid_m3;
    output              bready_m3;  

    output [1:0]        aruser_m3;
    output              arid_m3;
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
   
    input               rid_m3;
    input  [31:0]       rdata_m3;
    input  [1:0]        rresp_m3;
    input               rlast_m3;
    input               rvalid_m3;
    output              rready_m3;

    output [1:0]        awuser_m4;
    output              awid_m4;
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

    input                    bid_m4;
    input  [1:0]        bresp_m4;
    input               bvalid_m4;
    output              bready_m4;  

    output [1:0]        aruser_m4;
    output              arid_m4;
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
   
    input               rid_m4;
    input  [31:0]       rdata_m4;
    input  [1:0]        rresp_m4;
    input               rlast_m4;
    input               rvalid_m4;
    output              rready_m4;




    input  [1:0]        awuser_0_0;
    input               awid_0_0;
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

    output              bid_0_0;
    output [1:0]        bresp_0_0;
    output              bvalid_0_0;
    input               bready_0_0;  

    input  [1:0]        aruser_0_0;
    input               arid_0_0;
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
   
    output              rid_0_0;
    output [31:0]       rdata_0_0;
    output [1:0]        rresp_0_0;
    output              rlast_0_0;
    output              rvalid_0_0;
    input               rready_0_0;



    input  [1:0]        awuser_0_1;
    input               awid_0_1;
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

    output              bid_0_1;
    output [1:0]        bresp_0_1;
    output              bvalid_0_1;
    input               bready_0_1;  

    input  [1:0]        aruser_0_1;
    input               arid_0_1;
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
   
    output              rid_0_1;
    output [31:0]       rdata_0_1;
    output [1:0]        rresp_0_1;
    output              rlast_0_1;
    output              rvalid_0_1;
    input               rready_0_1;



    input  [1:0]        awuser_0_2;
    input               awid_0_2;
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

    output              bid_0_2;
    output [1:0]        bresp_0_2;
    output              bvalid_0_2;
    input               bready_0_2;  

    input  [1:0]        aruser_0_2;
    input               arid_0_2;
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
   
    output              rid_0_2;
    output [31:0]       rdata_0_2;
    output [1:0]        rresp_0_2;
    output              rlast_0_2;
    output              rvalid_0_2;
    input               rready_0_2;



    input  [1:0]        awuser_0_4;
    input               awid_0_4;
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

    output              bid_0_4;
    output [1:0]        bresp_0_4;
    output              bvalid_0_4;
    input               bready_0_4;  

    input  [1:0]        aruser_0_4;
    input               arid_0_4;
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
   
    output              rid_0_4;
    output [31:0]       rdata_0_4;
    output [1:0]        rresp_0_4;
    output              rlast_0_4;
    output              rvalid_0_4;
    input               rready_0_4;



    input  [1:0]        awuser_1_2;
    input               awid_1_2;
    input  [31:0]       awaddr_1_2;
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

    output              bid_1_2;
    output [1:0]        bresp_1_2;
    output              bvalid_1_2;
    input               bready_1_2;  

    input  [1:0]        aruser_1_2;
    input               arid_1_2;
    input  [31:0]       araddr_1_2;
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
   
    output              rid_1_2;
    output [31:0]       rdata_1_2;
    output [1:0]        rresp_1_2;
    output              rlast_1_2;
    output              rvalid_1_2;
    input               rready_1_2;



    input  [1:0]        awuser_1_3;
    input               awid_1_3;
    input  [31:0]       awaddr_1_3;
    input  [7:0]        awlen_1_3;
    input  [2:0]        awsize_1_3;
    input  [1:0]        awburst_1_3;
    input               awlock_1_3;
    input  [3:0]        awcache_1_3;
    input  [2:0]        awprot_1_3;
    input               awvalid_1_3;
    input               awvalid_vect_1_3;
    output              awready_1_3;
    input [3:0]         aw_qv_1_3;
   
    input [31:0]        wdata_1_3;
    input [3:0]         wstrb_1_3;   
    input               wlast_1_3;
    input               wvalid_1_3;
    output              wready_1_3;

    output              bid_1_3;
    output [1:0]        bresp_1_3;
    output              bvalid_1_3;
    input               bready_1_3;  

    input  [1:0]        aruser_1_3;
    input               arid_1_3;
    input  [31:0]       araddr_1_3;
    input  [7:0]        arlen_1_3;
    input  [2:0]        arsize_1_3;
    input  [1:0]        arburst_1_3;
    input               arlock_1_3;
    input  [3:0]        arcache_1_3;
    input  [2:0]        arprot_1_3;
    input               arvalid_1_3;
    input               arvalid_vect_1_3;
    output              arready_1_3;
    input [3:0]         ar_qv_1_3;
   
    output              rid_1_3;
    output [31:0]       rdata_1_3;
    output [1:0]        rresp_1_3;
    output              rlast_1_3;
    output              rvalid_1_3;
    input               rready_1_3;



    input  [1:0]        awuser_1_4;
    input               awid_1_4;
    input  [31:0]       awaddr_1_4;
    input  [7:0]        awlen_1_4;
    input  [2:0]        awsize_1_4;
    input  [1:0]        awburst_1_4;
    input               awlock_1_4;
    input  [3:0]        awcache_1_4;
    input  [2:0]        awprot_1_4;
    input               awvalid_1_4;
    input               awvalid_vect_1_4;
    output              awready_1_4;
    input [3:0]         aw_qv_1_4;
   
    input [31:0]        wdata_1_4;
    input [3:0]         wstrb_1_4;   
    input               wlast_1_4;
    input               wvalid_1_4;
    output              wready_1_4;

    output              bid_1_4;
    output [1:0]        bresp_1_4;
    output              bvalid_1_4;
    input               bready_1_4;  

    input  [1:0]        aruser_1_4;
    input               arid_1_4;
    input  [31:0]       araddr_1_4;
    input  [7:0]        arlen_1_4;
    input  [2:0]        arsize_1_4;
    input  [1:0]        arburst_1_4;
    input               arlock_1_4;
    input  [3:0]        arcache_1_4;
    input  [2:0]        arprot_1_4;
    input               arvalid_1_4;
    input               arvalid_vect_1_4;
    output              arready_1_4;
    input [3:0]         ar_qv_1_4;
   
    output              rid_1_4;
    output [31:0]       rdata_1_4;
    output [1:0]        rresp_1_4;
    output              rlast_1_4;
    output              rvalid_1_4;
    input               rready_1_4;


    input               aclk;
    input               aresetn;




nic400_bm0_ml_mlayer_0_secenc_f1 u_nic400_bm0_ml_mlayer0_secenc_f1 (
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

nic400_bm0_ml_mlayer_1_secenc_f1 u_nic400_bm0_ml_mlayer1_secenc_f1 (
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

nic400_bm0_ml_mlayer_2_secenc_f1 u_nic400_bm0_ml_mlayer2_secenc_f1 (
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
   
        .rid_s1          (rid_1_2),
        .rdata_s1        (rdata_1_2),
        .rresp_s1        (rresp_1_2),
        .rlast_s1        (rlast_1_2),
        .rvalid_s1       (rvalid_1_2),
        .rready_s1       (rready_1_2),


        .aclk       (aclk),
        .aresetn    (aresetn)
  ); 

nic400_bm0_ml_mlayer_3_secenc_f1 u_nic400_bm0_ml_mlayer3_secenc_f1 (
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

        .awuser_s0       (awuser_1_3),
        .awid_s0         (awid_1_3),
        .awaddr_s0       (awaddr_1_3),
        .awlen_s0        (awlen_1_3),
        .awsize_s0       (awsize_1_3),
        .awburst_s0      (awburst_1_3),
        .awlock_s0       (awlock_1_3),
        .awcache_s0      (awcache_1_3),
        .awprot_s0       (awprot_1_3),
        .awvalid_s0      (awvalid_1_3),
        .awvalid_vect_s0 (awvalid_vect_1_3),
        .awready_s0      (awready_1_3),
        .aw_qv_s0        (aw_qv_1_3),
   
        .wdata_s0        (wdata_1_3),
        .wstrb_s0        (wstrb_1_3),   
        .wlast_s0        (wlast_1_3),
        .wvalid_s0       (wvalid_1_3),
        .wready_s0       (wready_1_3),

        .bid_s0          (bid_1_3),
        .bresp_s0        (bresp_1_3),
        .bvalid_s0       (bvalid_1_3),
        .bready_s0       (bready_1_3),  

        .aruser_s0       (aruser_1_3),
        .arid_s0         (arid_1_3),
        .araddr_s0       (araddr_1_3),
        .arlen_s0        (arlen_1_3),
        .arsize_s0       (arsize_1_3),
        .arburst_s0      (arburst_1_3),
        .arlock_s0       (arlock_1_3),
        .arcache_s0      (arcache_1_3),
        .arprot_s0       (arprot_1_3),
        .arvalid_s0      (arvalid_1_3),
        .arvalid_vect_s0 (arvalid_vect_1_3),
        .arready_s0      (arready_1_3),
        .ar_qv_s0        (ar_qv_1_3),
   
        .rid_s0          (rid_1_3),
        .rdata_s0        (rdata_1_3),
        .rresp_s0        (rresp_1_3),
        .rlast_s0        (rlast_1_3),
        .rvalid_s0       (rvalid_1_3),
        .rready_s0       (rready_1_3),


        .aclk       (aclk),
        .aresetn    (aresetn)
  ); 

nic400_bm0_ml_mlayer_4_secenc_f1 u_nic400_bm0_ml_mlayer4_secenc_f1 (
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


        .awuser_s1       (awuser_1_4),
        .awid_s1         (awid_1_4),
        .awaddr_s1       (awaddr_1_4),
        .awlen_s1        (awlen_1_4),
        .awsize_s1       (awsize_1_4),
        .awburst_s1      (awburst_1_4),
        .awlock_s1       (awlock_1_4),
        .awcache_s1      (awcache_1_4),
        .awprot_s1       (awprot_1_4),
        .awvalid_s1      (awvalid_1_4),
        .awvalid_vect_s1 (awvalid_vect_1_4),
        .awready_s1      (awready_1_4),
        .aw_qv_s1        (aw_qv_1_4),
   
        .wdata_s1        (wdata_1_4),
        .wstrb_s1        (wstrb_1_4),   
        .wlast_s1        (wlast_1_4),
        .wvalid_s1       (wvalid_1_4),
        .wready_s1       (wready_1_4),

        .bid_s1          (bid_1_4),
        .bresp_s1        (bresp_1_4),
        .bvalid_s1       (bvalid_1_4),
        .bready_s1       (bready_1_4),  

        .aruser_s1       (aruser_1_4),
        .arid_s1         (arid_1_4),
        .araddr_s1       (araddr_1_4),
        .arlen_s1        (arlen_1_4),
        .arsize_s1       (arsize_1_4),
        .arburst_s1      (arburst_1_4),
        .arlock_s1       (arlock_1_4),
        .arcache_s1      (arcache_1_4),
        .arprot_s1       (arprot_1_4),
        .arvalid_s1      (arvalid_1_4),
        .arvalid_vect_s1 (arvalid_vect_1_4),
        .arready_s1      (arready_1_4),
        .ar_qv_s1        (ar_qv_1_4),
   
        .rid_s1          (rid_1_4),
        .rdata_s1        (rdata_1_4),
        .rresp_s1        (rresp_1_4),
        .rlast_s1        (rlast_1_4),
        .rvalid_s1       (rvalid_1_4),
        .rready_s1       (rready_1_4),


        .aclk       (aclk),
        .aresetn    (aresetn)
  ); 




  endmodule


