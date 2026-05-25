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


module nic400_bm0_ml_build_secenc_f1
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



  input [1:0]       awuser_s0;
  input             awid_s0;
  input [31:0]      awaddr_s0;
  input [7:0]       awlen_s0;
  input [2:0]       awsize_s0;
  input [1:0]       awburst_s0;
  input             awlock_s0;
  input [3:0]       awcache_s0;
  input [2:0]       awprot_s0;
  input             awvalid_s0;
  input [3:0]            awvalid_vect_s0;
  output            awready_s0;
  input [3:0]       aw_qv_s0;
    
  input [31:0]      wdata_s0;
  input [3:0]       wstrb_s0;
  input             wlast_s0;
  input             wvalid_s0;
  output            wready_s0;

  output            bid_s0;
  output [1:0]      bresp_s0;
  output            bvalid_s0;
  input             bready_s0;

  input [1:0]       aruser_s0;
  input             arid_s0;
  input [31:0]      araddr_s0;
  input [7:0]       arlen_s0;
  input [2:0]       arsize_s0;
  input [1:0]       arburst_s0;
  input             arlock_s0;
  input [3:0]       arcache_s0;
  input [2:0]       arprot_s0;
  input             arvalid_s0;
  input [3:0]            arvalid_vect_s0;
  output            arready_s0;
  input [3:0]       ar_qv_s0;
   
  output            rid_s0;
  output [31:0]     rdata_s0;
  output [1:0]      rresp_s0;
  output            rlast_s0;
  output            rvalid_s0;
  input             rready_s0;


  input [1:0]       awuser_s1;
  input             awid_s1;
  input [31:0]      awaddr_s1;
  input [7:0]       awlen_s1;
  input [2:0]       awsize_s1;
  input [1:0]       awburst_s1;
  input             awlock_s1;
  input [3:0]       awcache_s1;
  input [2:0]       awprot_s1;
  input             awvalid_s1;
  input [2:0]            awvalid_vect_s1;
  output            awready_s1;
  input [3:0]       aw_qv_s1;
    
  input [31:0]      wdata_s1;
  input [3:0]       wstrb_s1;
  input             wlast_s1;
  input             wvalid_s1;
  output            wready_s1;

  output            bid_s1;
  output [1:0]      bresp_s1;
  output            bvalid_s1;
  input             bready_s1;

  input [1:0]       aruser_s1;
  input             arid_s1;
  input [31:0]      araddr_s1;
  input [7:0]       arlen_s1;
  input [2:0]       arsize_s1;
  input [1:0]       arburst_s1;
  input             arlock_s1;
  input [3:0]       arcache_s1;
  input [2:0]       arprot_s1;
  input             arvalid_s1;
  input [2:0]            arvalid_vect_s1;
  output            arready_s1;
  input [3:0]       ar_qv_s1;
   
  output            rid_s1;
  output [31:0]     rdata_s1;
  output [1:0]      rresp_s1;
  output            rlast_s1;
  output            rvalid_s1;
  input             rready_s1;


  output [1:0]      awuser_0_0;
  output            awid_0_0;
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

  input             bid_0_0;
  input [1:0]       bresp_0_0;
  input             bvalid_0_0;
  output            bready_0_0;

  output  [1:0]     aruser_0_0;
  output            arid_0_0;
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

  input             rid_0_0;
  input [31:0]      rdata_0_0;
  input [1:0]       rresp_0_0;
  input             rlast_0_0;
  input             rvalid_0_0;
  output            rready_0_0;


  output [1:0]      awuser_0_1;
  output            awid_0_1;
  output [31:0]     awaddr_0_1;
  output [7:0]      awlen_0_1;
  output [2:0]      awsize_0_1;
  output [1:0]      awburst_0_1;
  output            awlock_0_1;
  output [3:0]      awcache_0_1;
  output [2:0]      awprot_0_1;
  output            awvalid_0_1;
  output             awvalid_vect_0_1;
  input             awready_0_1;
  output [3:0]      aw_qv_0_1;
   
  output  [31:0]    wdata_0_1;
  output  [3:0]     wstrb_0_1;
  output            wlast_0_1;
  output            wvalid_0_1;
  input             wready_0_1;

  input             bid_0_1;
  input [1:0]       bresp_0_1;
  input             bvalid_0_1;
  output            bready_0_1;

  output  [1:0]     aruser_0_1;
  output            arid_0_1;
  output  [31:0]    araddr_0_1;
  output  [7:0]     arlen_0_1;
  output  [2:0]     arsize_0_1;
  output  [1:0]     arburst_0_1;
  output            arlock_0_1;
  output  [3:0]     arcache_0_1;
  output  [2:0]     arprot_0_1;
  output            arvalid_0_1;
  output            arvalid_vect_0_1;
  input             arready_0_1;
  output  [3:0]     ar_qv_0_1;

  input             rid_0_1;
  input [31:0]      rdata_0_1;
  input [1:0]       rresp_0_1;
  input             rlast_0_1;
  input             rvalid_0_1;
  output            rready_0_1;


  output [1:0]      awuser_0_2;
  output            awid_0_2;
  output [31:0]     awaddr_0_2;
  output [7:0]      awlen_0_2;
  output [2:0]      awsize_0_2;
  output [1:0]      awburst_0_2;
  output            awlock_0_2;
  output [3:0]      awcache_0_2;
  output [2:0]      awprot_0_2;
  output            awvalid_0_2;
  output             awvalid_vect_0_2;
  input             awready_0_2;
  output [3:0]      aw_qv_0_2;
   
  output  [31:0]    wdata_0_2;
  output  [3:0]     wstrb_0_2;
  output            wlast_0_2;
  output            wvalid_0_2;
  input             wready_0_2;

  input             bid_0_2;
  input [1:0]       bresp_0_2;
  input             bvalid_0_2;
  output            bready_0_2;

  output  [1:0]     aruser_0_2;
  output            arid_0_2;
  output  [31:0]    araddr_0_2;
  output  [7:0]     arlen_0_2;
  output  [2:0]     arsize_0_2;
  output  [1:0]     arburst_0_2;
  output            arlock_0_2;
  output  [3:0]     arcache_0_2;
  output  [2:0]     arprot_0_2;
  output            arvalid_0_2;
  output            arvalid_vect_0_2;
  input             arready_0_2;
  output  [3:0]     ar_qv_0_2;

  input             rid_0_2;
  input [31:0]      rdata_0_2;
  input [1:0]       rresp_0_2;
  input             rlast_0_2;
  input             rvalid_0_2;
  output            rready_0_2;


  output [1:0]      awuser_0_4;
  output            awid_0_4;
  output [31:0]     awaddr_0_4;
  output [7:0]      awlen_0_4;
  output [2:0]      awsize_0_4;
  output [1:0]      awburst_0_4;
  output            awlock_0_4;
  output [3:0]      awcache_0_4;
  output [2:0]      awprot_0_4;
  output            awvalid_0_4;
  output             awvalid_vect_0_4;
  input             awready_0_4;
  output [3:0]      aw_qv_0_4;
   
  output  [31:0]    wdata_0_4;
  output  [3:0]     wstrb_0_4;
  output            wlast_0_4;
  output            wvalid_0_4;
  input             wready_0_4;

  input             bid_0_4;
  input [1:0]       bresp_0_4;
  input             bvalid_0_4;
  output            bready_0_4;

  output  [1:0]     aruser_0_4;
  output            arid_0_4;
  output  [31:0]    araddr_0_4;
  output  [7:0]     arlen_0_4;
  output  [2:0]     arsize_0_4;
  output  [1:0]     arburst_0_4;
  output            arlock_0_4;
  output  [3:0]     arcache_0_4;
  output  [2:0]     arprot_0_4;
  output            arvalid_0_4;
  output            arvalid_vect_0_4;
  input             arready_0_4;
  output  [3:0]     ar_qv_0_4;

  input             rid_0_4;
  input [31:0]      rdata_0_4;
  input [1:0]       rresp_0_4;
  input             rlast_0_4;
  input             rvalid_0_4;
  output            rready_0_4;


  output [1:0]      awuser_1_2;
  output            awid_1_2;
  output [31:0]     awaddr_1_2;
  output [7:0]      awlen_1_2;
  output [2:0]      awsize_1_2;
  output [1:0]      awburst_1_2;
  output            awlock_1_2;
  output [3:0]      awcache_1_2;
  output [2:0]      awprot_1_2;
  output            awvalid_1_2;
  output             awvalid_vect_1_2;
  input             awready_1_2;
  output [3:0]      aw_qv_1_2;
   
  output  [31:0]    wdata_1_2;
  output  [3:0]     wstrb_1_2;
  output            wlast_1_2;
  output            wvalid_1_2;
  input             wready_1_2;

  input             bid_1_2;
  input [1:0]       bresp_1_2;
  input             bvalid_1_2;
  output            bready_1_2;

  output  [1:0]     aruser_1_2;
  output            arid_1_2;
  output  [31:0]    araddr_1_2;
  output  [7:0]     arlen_1_2;
  output  [2:0]     arsize_1_2;
  output  [1:0]     arburst_1_2;
  output            arlock_1_2;
  output  [3:0]     arcache_1_2;
  output  [2:0]     arprot_1_2;
  output            arvalid_1_2;
  output            arvalid_vect_1_2;
  input             arready_1_2;
  output  [3:0]     ar_qv_1_2;

  input             rid_1_2;
  input [31:0]      rdata_1_2;
  input [1:0]       rresp_1_2;
  input             rlast_1_2;
  input             rvalid_1_2;
  output            rready_1_2;


  output [1:0]      awuser_1_3;
  output            awid_1_3;
  output [31:0]     awaddr_1_3;
  output [7:0]      awlen_1_3;
  output [2:0]      awsize_1_3;
  output [1:0]      awburst_1_3;
  output            awlock_1_3;
  output [3:0]      awcache_1_3;
  output [2:0]      awprot_1_3;
  output            awvalid_1_3;
  output             awvalid_vect_1_3;
  input             awready_1_3;
  output [3:0]      aw_qv_1_3;
   
  output  [31:0]    wdata_1_3;
  output  [3:0]     wstrb_1_3;
  output            wlast_1_3;
  output            wvalid_1_3;
  input             wready_1_3;

  input             bid_1_3;
  input [1:0]       bresp_1_3;
  input             bvalid_1_3;
  output            bready_1_3;

  output  [1:0]     aruser_1_3;
  output            arid_1_3;
  output  [31:0]    araddr_1_3;
  output  [7:0]     arlen_1_3;
  output  [2:0]     arsize_1_3;
  output  [1:0]     arburst_1_3;
  output            arlock_1_3;
  output  [3:0]     arcache_1_3;
  output  [2:0]     arprot_1_3;
  output            arvalid_1_3;
  output            arvalid_vect_1_3;
  input             arready_1_3;
  output  [3:0]     ar_qv_1_3;

  input             rid_1_3;
  input [31:0]      rdata_1_3;
  input [1:0]       rresp_1_3;
  input             rlast_1_3;
  input             rvalid_1_3;
  output            rready_1_3;


  output [1:0]      awuser_1_4;
  output            awid_1_4;
  output [31:0]     awaddr_1_4;
  output [7:0]      awlen_1_4;
  output [2:0]      awsize_1_4;
  output [1:0]      awburst_1_4;
  output            awlock_1_4;
  output [3:0]      awcache_1_4;
  output [2:0]      awprot_1_4;
  output            awvalid_1_4;
  output             awvalid_vect_1_4;
  input             awready_1_4;
  output [3:0]      aw_qv_1_4;
   
  output  [31:0]    wdata_1_4;
  output  [3:0]     wstrb_1_4;
  output            wlast_1_4;
  output            wvalid_1_4;
  input             wready_1_4;

  input             bid_1_4;
  input [1:0]       bresp_1_4;
  input             bvalid_1_4;
  output            bready_1_4;

  output  [1:0]     aruser_1_4;
  output            arid_1_4;
  output  [31:0]    araddr_1_4;
  output  [7:0]     arlen_1_4;
  output  [2:0]     arsize_1_4;
  output  [1:0]     arburst_1_4;
  output            arlock_1_4;
  output  [3:0]     arcache_1_4;
  output  [2:0]     arprot_1_4;
  output            arvalid_1_4;
  output            arvalid_vect_1_4;
  input             arready_1_4;
  output  [3:0]     ar_qv_1_4;

  input             rid_1_4;
  input [31:0]      rdata_1_4;
  input [1:0]       rresp_1_4;
  input             rlast_1_4;
  input             rvalid_1_4;
  output            rready_1_4;
 
  input             aclk;
  input             aresetn;





nic400_bm0_ml_blayer_0_secenc_f1 u_nic400_bm0_ml_blayer_0_secenc_f1
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
        .rready_m0       (rready_0_0),


        .awuser_m1       (awuser_0_1),
        .awid_m1         (awid_0_1),
        .awaddr_m1       (awaddr_0_1),
        .awlen_m1        (awlen_0_1),
        .awsize_m1       (awsize_0_1),
        .awburst_m1      (awburst_0_1),
        .awlock_m1       (awlock_0_1),
        .awcache_m1      (awcache_0_1),
        .awprot_m1       (awprot_0_1),
        .awvalid_m1      (awvalid_0_1),
        .awvalid_vect_m1 (awvalid_vect_0_1),
        .awready_m1      (awready_0_1),
        .aw_qv_m1        (aw_qv_0_1),
   
        .wdata_m1        (wdata_0_1),
        .wstrb_m1        (wstrb_0_1),   
        .wlast_m1        (wlast_0_1),
        .wvalid_m1       (wvalid_0_1),
        .wready_m1       (wready_0_1),

        .bid_m1          (bid_0_1),
        .bresp_m1        (bresp_0_1),
        .bvalid_m1       (bvalid_0_1),
        .bready_m1       (bready_0_1),

        .aruser_m1       (aruser_0_1),
        .arid_m1         (arid_0_1),
        .araddr_m1       (araddr_0_1),
        .arlen_m1        (arlen_0_1),
        .arsize_m1       (arsize_0_1),
        .arburst_m1      (arburst_0_1),
        .arlock_m1       (arlock_0_1),
        .arcache_m1      (arcache_0_1),
        .arprot_m1       (arprot_0_1),
        .arvalid_m1      (arvalid_0_1),
        .arvalid_vect_m1 (arvalid_vect_0_1),
        .arready_m1      (arready_0_1),
        .ar_qv_m1        (ar_qv_0_1),
   
        .rid_m1          (rid_0_1),
        .rdata_m1        (rdata_0_1),
        .rresp_m1        (rresp_0_1),
        .rlast_m1        (rlast_0_1),
        .rvalid_m1       (rvalid_0_1),
        .rready_m1       (rready_0_1),


        .awuser_m2       (awuser_0_2),
        .awid_m2         (awid_0_2),
        .awaddr_m2       (awaddr_0_2),
        .awlen_m2        (awlen_0_2),
        .awsize_m2       (awsize_0_2),
        .awburst_m2      (awburst_0_2),
        .awlock_m2       (awlock_0_2),
        .awcache_m2      (awcache_0_2),
        .awprot_m2       (awprot_0_2),
        .awvalid_m2      (awvalid_0_2),
        .awvalid_vect_m2 (awvalid_vect_0_2),
        .awready_m2      (awready_0_2),
        .aw_qv_m2        (aw_qv_0_2),
   
        .wdata_m2        (wdata_0_2),
        .wstrb_m2        (wstrb_0_2),   
        .wlast_m2        (wlast_0_2),
        .wvalid_m2       (wvalid_0_2),
        .wready_m2       (wready_0_2),

        .bid_m2          (bid_0_2),
        .bresp_m2        (bresp_0_2),
        .bvalid_m2       (bvalid_0_2),
        .bready_m2       (bready_0_2),

        .aruser_m2       (aruser_0_2),
        .arid_m2         (arid_0_2),
        .araddr_m2       (araddr_0_2),
        .arlen_m2        (arlen_0_2),
        .arsize_m2       (arsize_0_2),
        .arburst_m2      (arburst_0_2),
        .arlock_m2       (arlock_0_2),
        .arcache_m2      (arcache_0_2),
        .arprot_m2       (arprot_0_2),
        .arvalid_m2      (arvalid_0_2),
        .arvalid_vect_m2 (arvalid_vect_0_2),
        .arready_m2      (arready_0_2),
        .ar_qv_m2        (ar_qv_0_2),
   
        .rid_m2          (rid_0_2),
        .rdata_m2        (rdata_0_2),
        .rresp_m2        (rresp_0_2),
        .rlast_m2        (rlast_0_2),
        .rvalid_m2       (rvalid_0_2),
        .rready_m2       (rready_0_2),


        .awuser_m3       (awuser_0_4),
        .awid_m3         (awid_0_4),
        .awaddr_m3       (awaddr_0_4),
        .awlen_m3        (awlen_0_4),
        .awsize_m3       (awsize_0_4),
        .awburst_m3      (awburst_0_4),
        .awlock_m3       (awlock_0_4),
        .awcache_m3      (awcache_0_4),
        .awprot_m3       (awprot_0_4),
        .awvalid_m3      (awvalid_0_4),
        .awvalid_vect_m3 (awvalid_vect_0_4),
        .awready_m3      (awready_0_4),
        .aw_qv_m3        (aw_qv_0_4),
   
        .wdata_m3        (wdata_0_4),
        .wstrb_m3        (wstrb_0_4),   
        .wlast_m3        (wlast_0_4),
        .wvalid_m3       (wvalid_0_4),
        .wready_m3       (wready_0_4),

        .bid_m3          (bid_0_4),
        .bresp_m3        (bresp_0_4),
        .bvalid_m3       (bvalid_0_4),
        .bready_m3       (bready_0_4),

        .aruser_m3       (aruser_0_4),
        .arid_m3         (arid_0_4),
        .araddr_m3       (araddr_0_4),
        .arlen_m3        (arlen_0_4),
        .arsize_m3       (arsize_0_4),
        .arburst_m3      (arburst_0_4),
        .arlock_m3       (arlock_0_4),
        .arcache_m3      (arcache_0_4),
        .arprot_m3       (arprot_0_4),
        .arvalid_m3      (arvalid_0_4),
        .arvalid_vect_m3 (arvalid_vect_0_4),
        .arready_m3      (arready_0_4),
        .ar_qv_m3        (ar_qv_0_4),
   
        .rid_m3          (rid_0_4),
        .rdata_m3        (rdata_0_4),
        .rresp_m3        (rresp_0_4),
        .rlast_m3        (rlast_0_4),
        .rvalid_m3       (rvalid_0_4),
        .rready_m3       (rready_0_4),
        .aclk    (aclk),
        .aresetn    (aresetn)
  ); 

nic400_bm0_ml_blayer_1_secenc_f1 u_nic400_bm0_ml_blayer_1_secenc_f1
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





        .awuser_m0       (awuser_1_2),
        .awid_m0         (awid_1_2),
        .awaddr_m0       (awaddr_1_2),
        .awlen_m0        (awlen_1_2),
        .awsize_m0       (awsize_1_2),
        .awburst_m0      (awburst_1_2),
        .awlock_m0       (awlock_1_2),
        .awcache_m0      (awcache_1_2),
        .awprot_m0       (awprot_1_2),
        .awvalid_m0      (awvalid_1_2),
        .awvalid_vect_m0 (awvalid_vect_1_2),
        .awready_m0      (awready_1_2),
        .aw_qv_m0        (aw_qv_1_2),
   
        .wdata_m0        (wdata_1_2),
        .wstrb_m0        (wstrb_1_2),   
        .wlast_m0        (wlast_1_2),
        .wvalid_m0       (wvalid_1_2),
        .wready_m0       (wready_1_2),

        .bid_m0          (bid_1_2),
        .bresp_m0        (bresp_1_2),
        .bvalid_m0       (bvalid_1_2),
        .bready_m0       (bready_1_2),

        .aruser_m0       (aruser_1_2),
        .arid_m0         (arid_1_2),
        .araddr_m0       (araddr_1_2),
        .arlen_m0        (arlen_1_2),
        .arsize_m0       (arsize_1_2),
        .arburst_m0      (arburst_1_2),
        .arlock_m0       (arlock_1_2),
        .arcache_m0      (arcache_1_2),
        .arprot_m0       (arprot_1_2),
        .arvalid_m0      (arvalid_1_2),
        .arvalid_vect_m0 (arvalid_vect_1_2),
        .arready_m0      (arready_1_2),
        .ar_qv_m0        (ar_qv_1_2),
   
        .rid_m0          (rid_1_2),
        .rdata_m0        (rdata_1_2),
        .rresp_m0        (rresp_1_2),
        .rlast_m0        (rlast_1_2),
        .rvalid_m0       (rvalid_1_2),
        .rready_m0       (rready_1_2),


        .awuser_m1       (awuser_1_3),
        .awid_m1         (awid_1_3),
        .awaddr_m1       (awaddr_1_3),
        .awlen_m1        (awlen_1_3),
        .awsize_m1       (awsize_1_3),
        .awburst_m1      (awburst_1_3),
        .awlock_m1       (awlock_1_3),
        .awcache_m1      (awcache_1_3),
        .awprot_m1       (awprot_1_3),
        .awvalid_m1      (awvalid_1_3),
        .awvalid_vect_m1 (awvalid_vect_1_3),
        .awready_m1      (awready_1_3),
        .aw_qv_m1        (aw_qv_1_3),
   
        .wdata_m1        (wdata_1_3),
        .wstrb_m1        (wstrb_1_3),   
        .wlast_m1        (wlast_1_3),
        .wvalid_m1       (wvalid_1_3),
        .wready_m1       (wready_1_3),

        .bid_m1          (bid_1_3),
        .bresp_m1        (bresp_1_3),
        .bvalid_m1       (bvalid_1_3),
        .bready_m1       (bready_1_3),

        .aruser_m1       (aruser_1_3),
        .arid_m1         (arid_1_3),
        .araddr_m1       (araddr_1_3),
        .arlen_m1        (arlen_1_3),
        .arsize_m1       (arsize_1_3),
        .arburst_m1      (arburst_1_3),
        .arlock_m1       (arlock_1_3),
        .arcache_m1      (arcache_1_3),
        .arprot_m1       (arprot_1_3),
        .arvalid_m1      (arvalid_1_3),
        .arvalid_vect_m1 (arvalid_vect_1_3),
        .arready_m1      (arready_1_3),
        .ar_qv_m1        (ar_qv_1_3),
   
        .rid_m1          (rid_1_3),
        .rdata_m1        (rdata_1_3),
        .rresp_m1        (rresp_1_3),
        .rlast_m1        (rlast_1_3),
        .rvalid_m1       (rvalid_1_3),
        .rready_m1       (rready_1_3),


        .awuser_m2       (awuser_1_4),
        .awid_m2         (awid_1_4),
        .awaddr_m2       (awaddr_1_4),
        .awlen_m2        (awlen_1_4),
        .awsize_m2       (awsize_1_4),
        .awburst_m2      (awburst_1_4),
        .awlock_m2       (awlock_1_4),
        .awcache_m2      (awcache_1_4),
        .awprot_m2       (awprot_1_4),
        .awvalid_m2      (awvalid_1_4),
        .awvalid_vect_m2 (awvalid_vect_1_4),
        .awready_m2      (awready_1_4),
        .aw_qv_m2        (aw_qv_1_4),
   
        .wdata_m2        (wdata_1_4),
        .wstrb_m2        (wstrb_1_4),   
        .wlast_m2        (wlast_1_4),
        .wvalid_m2       (wvalid_1_4),
        .wready_m2       (wready_1_4),

        .bid_m2          (bid_1_4),
        .bresp_m2        (bresp_1_4),
        .bvalid_m2       (bvalid_1_4),
        .bready_m2       (bready_1_4),

        .aruser_m2       (aruser_1_4),
        .arid_m2         (arid_1_4),
        .araddr_m2       (araddr_1_4),
        .arlen_m2        (arlen_1_4),
        .arsize_m2       (arsize_1_4),
        .arburst_m2      (arburst_1_4),
        .arlock_m2       (arlock_1_4),
        .arcache_m2      (arcache_1_4),
        .arprot_m2       (arprot_1_4),
        .arvalid_m2      (arvalid_1_4),
        .arvalid_vect_m2 (arvalid_vect_1_4),
        .arready_m2      (arready_1_4),
        .ar_qv_m2        (ar_qv_1_4),
   
        .rid_m2          (rid_1_4),
        .rdata_m2        (rdata_1_4),
        .rresp_m2        (rresp_1_4),
        .rlast_m2        (rlast_1_4),
        .rvalid_m2       (rvalid_1_4),
        .rready_m2       (rready_1_4),
        .aclk    (aclk),
        .aresetn    (aresetn)
  ); 





  endmodule


