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


module nic400_switch0_ml_map_sse710_dbg3s1m
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




    output [2:0]        awuser_m0;
    output [3:0]        awid_m0;
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

    input  [3:0]             bid_m0;
    input  [1:0]        bresp_m0;
    input               bvalid_m0;
    output              bready_m0;  

    output [2:0]        aruser_m0;
    output [3:0]        arid_m0;
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
   
    input  [3:0]        rid_m0;
    input  [31:0]       rdata_m0;
    input  [1:0]        rresp_m0;
    input               rlast_m0;
    input               rvalid_m0;
    output              rready_m0;




    input  [2:0]        awuser_0_0;
    input  [3:0]        awid_0_0;
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

    output [3:0]        bid_0_0;
    output [1:0]        bresp_0_0;
    output              bvalid_0_0;
    input               bready_0_0;  

    input  [2:0]        aruser_0_0;
    input  [3:0]        arid_0_0;
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
   
    output [3:0]        rid_0_0;
    output [31:0]       rdata_0_0;
    output [1:0]        rresp_0_0;
    output              rlast_0_0;
    output              rvalid_0_0;
    input               rready_0_0;



    input  [2:0]        awuser_1_0;
    input  [3:0]        awid_1_0;
    input  [31:0]       awaddr_1_0;
    input  [7:0]        awlen_1_0;
    input  [2:0]        awsize_1_0;
    input  [1:0]        awburst_1_0;
    input               awlock_1_0;
    input  [3:0]        awcache_1_0;
    input  [2:0]        awprot_1_0;
    input               awvalid_1_0;
    input               awvalid_vect_1_0;
    output              awready_1_0;
    input [3:0]         aw_qv_1_0;
   
    input [31:0]        wdata_1_0;
    input [3:0]         wstrb_1_0;   
    input               wlast_1_0;
    input               wvalid_1_0;
    output              wready_1_0;

    output [3:0]        bid_1_0;
    output [1:0]        bresp_1_0;
    output              bvalid_1_0;
    input               bready_1_0;  

    input  [2:0]        aruser_1_0;
    input  [3:0]        arid_1_0;
    input  [31:0]       araddr_1_0;
    input  [7:0]        arlen_1_0;
    input  [2:0]        arsize_1_0;
    input  [1:0]        arburst_1_0;
    input               arlock_1_0;
    input  [3:0]        arcache_1_0;
    input  [2:0]        arprot_1_0;
    input               arvalid_1_0;
    input               arvalid_vect_1_0;
    output              arready_1_0;
    input [3:0]         ar_qv_1_0;
   
    output [3:0]        rid_1_0;
    output [31:0]       rdata_1_0;
    output [1:0]        rresp_1_0;
    output              rlast_1_0;
    output              rvalid_1_0;
    input               rready_1_0;



    input  [2:0]        awuser_2_0;
    input  [3:0]        awid_2_0;
    input  [31:0]       awaddr_2_0;
    input  [7:0]        awlen_2_0;
    input  [2:0]        awsize_2_0;
    input  [1:0]        awburst_2_0;
    input               awlock_2_0;
    input  [3:0]        awcache_2_0;
    input  [2:0]        awprot_2_0;
    input               awvalid_2_0;
    input               awvalid_vect_2_0;
    output              awready_2_0;
    input [3:0]         aw_qv_2_0;
   
    input [31:0]        wdata_2_0;
    input [3:0]         wstrb_2_0;   
    input               wlast_2_0;
    input               wvalid_2_0;
    output              wready_2_0;

    output [3:0]        bid_2_0;
    output [1:0]        bresp_2_0;
    output              bvalid_2_0;
    input               bready_2_0;  

    input  [2:0]        aruser_2_0;
    input  [3:0]        arid_2_0;
    input  [31:0]       araddr_2_0;
    input  [7:0]        arlen_2_0;
    input  [2:0]        arsize_2_0;
    input  [1:0]        arburst_2_0;
    input               arlock_2_0;
    input  [3:0]        arcache_2_0;
    input  [2:0]        arprot_2_0;
    input               arvalid_2_0;
    input               arvalid_vect_2_0;
    output              arready_2_0;
    input [3:0]         ar_qv_2_0;
   
    output [3:0]        rid_2_0;
    output [31:0]       rdata_2_0;
    output [1:0]        rresp_2_0;
    output              rlast_2_0;
    output              rvalid_2_0;
    input               rready_2_0;


    input               aclk;
    input               aresetn;




nic400_switch0_ml_mlayer_0_sse710_dbg3s1m u_nic400_switch0_ml_mlayer0_sse710_dbg3s1m (
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


        .awuser_s1       (awuser_1_0),
        .awid_s1         (awid_1_0),
        .awaddr_s1       (awaddr_1_0),
        .awlen_s1        (awlen_1_0),
        .awsize_s1       (awsize_1_0),
        .awburst_s1      (awburst_1_0),
        .awlock_s1       (awlock_1_0),
        .awcache_s1      (awcache_1_0),
        .awprot_s1       (awprot_1_0),
        .awvalid_s1      (awvalid_1_0),
        .awvalid_vect_s1 (awvalid_vect_1_0),
        .awready_s1      (awready_1_0),
        .aw_qv_s1        (aw_qv_1_0),
   
        .wdata_s1        (wdata_1_0),
        .wstrb_s1        (wstrb_1_0),   
        .wlast_s1        (wlast_1_0),
        .wvalid_s1       (wvalid_1_0),
        .wready_s1       (wready_1_0),

        .bid_s1          (bid_1_0),
        .bresp_s1        (bresp_1_0),
        .bvalid_s1       (bvalid_1_0),
        .bready_s1       (bready_1_0),  

        .aruser_s1       (aruser_1_0),
        .arid_s1         (arid_1_0),
        .araddr_s1       (araddr_1_0),
        .arlen_s1        (arlen_1_0),
        .arsize_s1       (arsize_1_0),
        .arburst_s1      (arburst_1_0),
        .arlock_s1       (arlock_1_0),
        .arcache_s1      (arcache_1_0),
        .arprot_s1       (arprot_1_0),
        .arvalid_s1      (arvalid_1_0),
        .arvalid_vect_s1 (arvalid_vect_1_0),
        .arready_s1      (arready_1_0),
        .ar_qv_s1        (ar_qv_1_0),
   
        .rid_s1          (rid_1_0),
        .rdata_s1        (rdata_1_0),
        .rresp_s1        (rresp_1_0),
        .rlast_s1        (rlast_1_0),
        .rvalid_s1       (rvalid_1_0),
        .rready_s1       (rready_1_0),


        .awuser_s2       (awuser_2_0),
        .awid_s2         (awid_2_0),
        .awaddr_s2       (awaddr_2_0),
        .awlen_s2        (awlen_2_0),
        .awsize_s2       (awsize_2_0),
        .awburst_s2      (awburst_2_0),
        .awlock_s2       (awlock_2_0),
        .awcache_s2      (awcache_2_0),
        .awprot_s2       (awprot_2_0),
        .awvalid_s2      (awvalid_2_0),
        .awvalid_vect_s2 (awvalid_vect_2_0),
        .awready_s2      (awready_2_0),
        .aw_qv_s2        (aw_qv_2_0),
   
        .wdata_s2        (wdata_2_0),
        .wstrb_s2        (wstrb_2_0),   
        .wlast_s2        (wlast_2_0),
        .wvalid_s2       (wvalid_2_0),
        .wready_s2       (wready_2_0),

        .bid_s2          (bid_2_0),
        .bresp_s2        (bresp_2_0),
        .bvalid_s2       (bvalid_2_0),
        .bready_s2       (bready_2_0),  

        .aruser_s2       (aruser_2_0),
        .arid_s2         (arid_2_0),
        .araddr_s2       (araddr_2_0),
        .arlen_s2        (arlen_2_0),
        .arsize_s2       (arsize_2_0),
        .arburst_s2      (arburst_2_0),
        .arlock_s2       (arlock_2_0),
        .arcache_s2      (arcache_2_0),
        .arprot_s2       (arprot_2_0),
        .arvalid_s2      (arvalid_2_0),
        .arvalid_vect_s2 (arvalid_vect_2_0),
        .arready_s2      (arready_2_0),
        .ar_qv_s2        (ar_qv_2_0),
   
        .rid_s2          (rid_2_0),
        .rdata_s2        (rdata_2_0),
        .rresp_s2        (rresp_2_0),
        .rlast_s2        (rlast_2_0),
        .rvalid_s2       (rvalid_2_0),
        .rready_s2       (rready_2_0),


        .aclk       (aclk),
        .aresetn    (aresetn)
  ); 




  endmodule


