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


module nic400_switch1_ml_map_sse710_dbgaxi2apb
  (

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


    aclk,
    aresetn
  );




    output [8:0]        awid_m0;
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

    input  [8:0]             bid_m0;
    input  [1:0]        bresp_m0;
    input               bvalid_m0;
    output              bready_m0;  

    output [8:0]        arid_m0;
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
   
    input  [8:0]        rid_m0;
    input  [31:0]       rdata_m0;
    input  [1:0]        rresp_m0;
    input               rlast_m0;
    input               rvalid_m0;
    output              rready_m0;

    output [8:0]        awid_m1;
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

    input  [8:0]             bid_m1;
    input  [1:0]        bresp_m1;
    input               bvalid_m1;
    output              bready_m1;  

    output [8:0]        arid_m1;
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
   
    input  [8:0]        rid_m1;
    input  [31:0]       rdata_m1;
    input  [1:0]        rresp_m1;
    input               rlast_m1;
    input               rvalid_m1;
    output              rready_m1;




    input  [8:0]        awid_0_0;
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

    output [8:0]        bid_0_0;
    output [1:0]        bresp_0_0;
    output              bvalid_0_0;
    input               bready_0_0;  

    input  [8:0]        arid_0_0;
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
   
    output [8:0]        rid_0_0;
    output [31:0]       rdata_0_0;
    output [1:0]        rresp_0_0;
    output              rlast_0_0;
    output              rvalid_0_0;
    input               rready_0_0;



    input  [8:0]        awid_0_1;
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

    output [8:0]        bid_0_1;
    output [1:0]        bresp_0_1;
    output              bvalid_0_1;
    input               bready_0_1;  

    input  [8:0]        arid_0_1;
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
   
    output [8:0]        rid_0_1;
    output [31:0]       rdata_0_1;
    output [1:0]        rresp_0_1;
    output              rlast_0_1;
    output              rvalid_0_1;
    input               rready_0_1;


    input               aclk;
    input               aresetn;




nic400_switch1_ml_mlayer_0_sse710_dbgaxi2apb u_nic400_switch1_ml_mlayer0_sse710_dbgaxi2apb (
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

nic400_switch1_ml_mlayer_1_sse710_dbgaxi2apb u_nic400_switch1_ml_mlayer1_sse710_dbgaxi2apb (
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




  endmodule


