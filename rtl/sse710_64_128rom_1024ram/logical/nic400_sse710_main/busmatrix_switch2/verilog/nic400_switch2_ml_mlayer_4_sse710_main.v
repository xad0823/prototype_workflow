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


module nic400_switch2_ml_mlayer_4_sse710_main
  (
    awuser_m,
    awid_m,
    awaddr_m,
    awlen_m,
    awsize_m,
    awburst_m,
    awlock_m,
    awcache_m,
    awprot_m,
    awvalid_m,
    awvalid_vect_m,
    awready_m,
    aw_qv_m,
   
    wdata_m,
    wstrb_m,
    wlast_m,
    wvalid_m,
    wready_m,

    buser_m,
    bid_m,
    bresp_m,
    bvalid_m,
    bready_m,

    aruser_m,
    arid_m,
    araddr_m,
    arlen_m,
    arsize_m,
    arburst_m,
    arlock_m,
    arcache_m,
    arprot_m,
    arvalid_m,
    arvalid_vect_m,
    arready_m,
    ar_qv_m,
   
    ruser_m,
    rid_m,
    rdata_m,
    rresp_m,
    rlast_m,
    rvalid_m,
    rready_m,

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

    buser_s0,
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
   
    ruser_s0,
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

    buser_s1,
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
   
    ruser_s1,
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

    buser_s2,
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
   
    ruser_s2,
    rid_s2,
    rdata_s2,
    rresp_s2,
    rlast_s2,
    rvalid_s2,
    rready_s2,

    awuser_s3,
    awid_s3,
    awaddr_s3,
    awlen_s3,
    awsize_s3,
    awburst_s3,
    awlock_s3,
    awcache_s3,
    awprot_s3,
    awvalid_s3,
    awvalid_vect_s3,
    awready_s3,
    aw_qv_s3,
   
    wdata_s3,
    wstrb_s3,   
    wlast_s3,
    wvalid_s3,
    wready_s3,

    buser_s3,
    bid_s3,
    bresp_s3,
    bvalid_s3,
    bready_s3,  

    aruser_s3,
    arid_s3,
    araddr_s3,
    arlen_s3,
    arsize_s3,
    arburst_s3,
    arlock_s3,
    arcache_s3,
    arprot_s3,
    arvalid_s3,
    arvalid_vect_s3,
    arready_s3,
    ar_qv_s3,
   
    ruser_s3,
    rid_s3,
    rdata_s3,
    rresp_s3,
    rlast_s3,
    rvalid_s3,
    rready_s3,

    awuser_s4,
    awid_s4,
    awaddr_s4,
    awlen_s4,
    awsize_s4,
    awburst_s4,
    awlock_s4,
    awcache_s4,
    awprot_s4,
    awvalid_s4,
    awvalid_vect_s4,
    awready_s4,
    aw_qv_s4,
   
    wdata_s4,
    wstrb_s4,   
    wlast_s4,
    wvalid_s4,
    wready_s4,

    buser_s4,
    bid_s4,
    bresp_s4,
    bvalid_s4,
    bready_s4,  

    aruser_s4,
    arid_s4,
    araddr_s4,
    arlen_s4,
    arsize_s4,
    arburst_s4,
    arlock_s4,
    arcache_s4,
    arprot_s4,
    arvalid_s4,
    arvalid_vect_s4,
    arready_s4,
    ar_qv_s4,
   
    ruser_s4,
    rid_s4,
    rdata_s4,
    rresp_s4,
    rlast_s4,
    rvalid_s4,
    rready_s4,

    awuser_s5,
    awid_s5,
    awaddr_s5,
    awlen_s5,
    awsize_s5,
    awburst_s5,
    awlock_s5,
    awcache_s5,
    awprot_s5,
    awvalid_s5,
    awvalid_vect_s5,
    awready_s5,
    aw_qv_s5,
   
    wdata_s5,
    wstrb_s5,   
    wlast_s5,
    wvalid_s5,
    wready_s5,

    buser_s5,
    bid_s5,
    bresp_s5,
    bvalid_s5,
    bready_s5,  

    aruser_s5,
    arid_s5,
    araddr_s5,
    arlen_s5,
    arsize_s5,
    arburst_s5,
    arlock_s5,
    arcache_s5,
    arprot_s5,
    arvalid_s5,
    arvalid_vect_s5,
    arready_s5,
    ar_qv_s5,
   
    ruser_s5,
    rid_s5,
    rdata_s5,
    rresp_s5,
    rlast_s5,
    rvalid_s5,
    rready_s5,

    awuser_s6,
    awid_s6,
    awaddr_s6,
    awlen_s6,
    awsize_s6,
    awburst_s6,
    awlock_s6,
    awcache_s6,
    awprot_s6,
    awvalid_s6,
    awvalid_vect_s6,
    awready_s6,
    aw_qv_s6,
   
    wdata_s6,
    wstrb_s6,   
    wlast_s6,
    wvalid_s6,
    wready_s6,

    buser_s6,
    bid_s6,
    bresp_s6,
    bvalid_s6,
    bready_s6,  

    aruser_s6,
    arid_s6,
    araddr_s6,
    arlen_s6,
    arsize_s6,
    arburst_s6,
    arlock_s6,
    arcache_s6,
    arprot_s6,
    arvalid_s6,
    arvalid_vect_s6,
    arready_s6,
    ar_qv_s6,
   
    ruser_s6,
    rid_s6,
    rdata_s6,
    rresp_s6,
    rlast_s6,
    rvalid_s6,
    rready_s6,

    aclk,
    aresetn
  );




  output [9:0]      awuser_m;
  output [11:0]      awid_m;
  output [39:0]     awaddr_m;
  output [7:0]      awlen_m;
  output [2:0]      awsize_m;
  output [1:0]      awburst_m;
  output            awlock_m;
  output [3:0]      awcache_m;
  output [2:0]      awprot_m;
  output            awvalid_m;
  output            awvalid_vect_m;
  input             awready_m;
  output [3:0]      aw_qv_m;
   
  output  [63:0]    wdata_m;
  output  [7:0]     wstrb_m;
  output            wlast_m;
  output            wvalid_m;
  input             wready_m;

  input             buser_m;
  input [11:0]       bid_m;
  input [1:0]       bresp_m;
  input             bvalid_m;
  output            bready_m;

  output [9:0]      aruser_m;
  output [11:0]      arid_m;
  output [39:0]     araddr_m;
  output [7:0]      arlen_m;
  output [2:0]      arsize_m;
  output [1:0]      arburst_m;
  output            arlock_m;
  output [3:0]      arcache_m;
  output [2:0]      arprot_m;
  output            arvalid_m;
  output            arvalid_vect_m;
  input             arready_m;
  output [3:0]      ar_qv_m;
   
  input             ruser_m;
  input [11:0]       rid_m;
  input [63:0]      rdata_m;
  input [1:0]       rresp_m;
  input             rlast_m;
  input             rvalid_m;
  output            rready_m;


  input  [9:0]      awuser_s0;
  input  [11:0]      awid_s0;
  input  [39:0]     awaddr_s0;
  input  [7:0]      awlen_s0;
  input  [2:0]      awsize_s0;
  input  [1:0]      awburst_s0;
  input             awlock_s0;
  input  [3:0]      awcache_s0;
  input  [2:0]      awprot_s0;
  input             awvalid_s0;
  input             awvalid_vect_s0;
  output            awready_s0;
  input  [3:0]      aw_qv_s0;
   
  input  [63:0]     wdata_s0;
  input  [7:0]      wstrb_s0;   
  input             wlast_s0;
  input             wvalid_s0;
  output            wready_s0;

  output            buser_s0;
  output [11:0]      bid_s0;
  output [1:0]      bresp_s0;
  output            bvalid_s0;
  input             bready_s0;  

  input  [9:0]      aruser_s0;
  input  [11:0]      arid_s0;
  input  [39:0]     araddr_s0;
  input  [7:0]      arlen_s0;
  input  [2:0]      arsize_s0;
  input  [1:0]      arburst_s0;
  input             arlock_s0;
  input  [3:0]      arcache_s0;
  input  [2:0]      arprot_s0;
  input             arvalid_s0;
  input             arvalid_vect_s0;
  output            arready_s0;
  input  [3:0]      ar_qv_s0;

  output            ruser_s0;
  output  [11:0]     rid_s0;
  output  [63:0]    rdata_s0;
  output [1:0]      rresp_s0;
  output            rlast_s0;
  output            rvalid_s0;
  input             rready_s0;

  input  [9:0]      awuser_s1;
  input  [11:0]      awid_s1;
  input  [39:0]     awaddr_s1;
  input  [7:0]      awlen_s1;
  input  [2:0]      awsize_s1;
  input  [1:0]      awburst_s1;
  input             awlock_s1;
  input  [3:0]      awcache_s1;
  input  [2:0]      awprot_s1;
  input             awvalid_s1;
  input             awvalid_vect_s1;
  output            awready_s1;
  input  [3:0]      aw_qv_s1;
   
  input  [63:0]     wdata_s1;
  input  [7:0]      wstrb_s1;   
  input             wlast_s1;
  input             wvalid_s1;
  output            wready_s1;

  output            buser_s1;
  output [11:0]      bid_s1;
  output [1:0]      bresp_s1;
  output            bvalid_s1;
  input             bready_s1;  

  input  [9:0]      aruser_s1;
  input  [11:0]      arid_s1;
  input  [39:0]     araddr_s1;
  input  [7:0]      arlen_s1;
  input  [2:0]      arsize_s1;
  input  [1:0]      arburst_s1;
  input             arlock_s1;
  input  [3:0]      arcache_s1;
  input  [2:0]      arprot_s1;
  input             arvalid_s1;
  input             arvalid_vect_s1;
  output            arready_s1;
  input  [3:0]      ar_qv_s1;

  output            ruser_s1;
  output  [11:0]     rid_s1;
  output  [63:0]    rdata_s1;
  output [1:0]      rresp_s1;
  output            rlast_s1;
  output            rvalid_s1;
  input             rready_s1;

  input  [9:0]      awuser_s2;
  input  [11:0]      awid_s2;
  input  [39:0]     awaddr_s2;
  input  [7:0]      awlen_s2;
  input  [2:0]      awsize_s2;
  input  [1:0]      awburst_s2;
  input             awlock_s2;
  input  [3:0]      awcache_s2;
  input  [2:0]      awprot_s2;
  input             awvalid_s2;
  input             awvalid_vect_s2;
  output            awready_s2;
  input  [3:0]      aw_qv_s2;
   
  input  [63:0]     wdata_s2;
  input  [7:0]      wstrb_s2;   
  input             wlast_s2;
  input             wvalid_s2;
  output            wready_s2;

  output            buser_s2;
  output [11:0]      bid_s2;
  output [1:0]      bresp_s2;
  output            bvalid_s2;
  input             bready_s2;  

  input  [9:0]      aruser_s2;
  input  [11:0]      arid_s2;
  input  [39:0]     araddr_s2;
  input  [7:0]      arlen_s2;
  input  [2:0]      arsize_s2;
  input  [1:0]      arburst_s2;
  input             arlock_s2;
  input  [3:0]      arcache_s2;
  input  [2:0]      arprot_s2;
  input             arvalid_s2;
  input             arvalid_vect_s2;
  output            arready_s2;
  input  [3:0]      ar_qv_s2;

  output            ruser_s2;
  output  [11:0]     rid_s2;
  output  [63:0]    rdata_s2;
  output [1:0]      rresp_s2;
  output            rlast_s2;
  output            rvalid_s2;
  input             rready_s2;

  input  [9:0]      awuser_s3;
  input  [11:0]      awid_s3;
  input  [39:0]     awaddr_s3;
  input  [7:0]      awlen_s3;
  input  [2:0]      awsize_s3;
  input  [1:0]      awburst_s3;
  input             awlock_s3;
  input  [3:0]      awcache_s3;
  input  [2:0]      awprot_s3;
  input             awvalid_s3;
  input             awvalid_vect_s3;
  output            awready_s3;
  input  [3:0]      aw_qv_s3;
   
  input  [63:0]     wdata_s3;
  input  [7:0]      wstrb_s3;   
  input             wlast_s3;
  input             wvalid_s3;
  output            wready_s3;

  output            buser_s3;
  output [11:0]      bid_s3;
  output [1:0]      bresp_s3;
  output            bvalid_s3;
  input             bready_s3;  

  input  [9:0]      aruser_s3;
  input  [11:0]      arid_s3;
  input  [39:0]     araddr_s3;
  input  [7:0]      arlen_s3;
  input  [2:0]      arsize_s3;
  input  [1:0]      arburst_s3;
  input             arlock_s3;
  input  [3:0]      arcache_s3;
  input  [2:0]      arprot_s3;
  input             arvalid_s3;
  input             arvalid_vect_s3;
  output            arready_s3;
  input  [3:0]      ar_qv_s3;

  output            ruser_s3;
  output  [11:0]     rid_s3;
  output  [63:0]    rdata_s3;
  output [1:0]      rresp_s3;
  output            rlast_s3;
  output            rvalid_s3;
  input             rready_s3;

  input  [9:0]      awuser_s4;
  input  [11:0]      awid_s4;
  input  [39:0]     awaddr_s4;
  input  [7:0]      awlen_s4;
  input  [2:0]      awsize_s4;
  input  [1:0]      awburst_s4;
  input             awlock_s4;
  input  [3:0]      awcache_s4;
  input  [2:0]      awprot_s4;
  input             awvalid_s4;
  input             awvalid_vect_s4;
  output            awready_s4;
  input  [3:0]      aw_qv_s4;
   
  input  [63:0]     wdata_s4;
  input  [7:0]      wstrb_s4;   
  input             wlast_s4;
  input             wvalid_s4;
  output            wready_s4;

  output            buser_s4;
  output [11:0]      bid_s4;
  output [1:0]      bresp_s4;
  output            bvalid_s4;
  input             bready_s4;  

  input  [9:0]      aruser_s4;
  input  [11:0]      arid_s4;
  input  [39:0]     araddr_s4;
  input  [7:0]      arlen_s4;
  input  [2:0]      arsize_s4;
  input  [1:0]      arburst_s4;
  input             arlock_s4;
  input  [3:0]      arcache_s4;
  input  [2:0]      arprot_s4;
  input             arvalid_s4;
  input             arvalid_vect_s4;
  output            arready_s4;
  input  [3:0]      ar_qv_s4;

  output            ruser_s4;
  output  [11:0]     rid_s4;
  output  [63:0]    rdata_s4;
  output [1:0]      rresp_s4;
  output            rlast_s4;
  output            rvalid_s4;
  input             rready_s4;

  input  [9:0]      awuser_s5;
  input  [11:0]      awid_s5;
  input  [39:0]     awaddr_s5;
  input  [7:0]      awlen_s5;
  input  [2:0]      awsize_s5;
  input  [1:0]      awburst_s5;
  input             awlock_s5;
  input  [3:0]      awcache_s5;
  input  [2:0]      awprot_s5;
  input             awvalid_s5;
  input             awvalid_vect_s5;
  output            awready_s5;
  input  [3:0]      aw_qv_s5;
   
  input  [63:0]     wdata_s5;
  input  [7:0]      wstrb_s5;   
  input             wlast_s5;
  input             wvalid_s5;
  output            wready_s5;

  output            buser_s5;
  output [11:0]      bid_s5;
  output [1:0]      bresp_s5;
  output            bvalid_s5;
  input             bready_s5;  

  input  [9:0]      aruser_s5;
  input  [11:0]      arid_s5;
  input  [39:0]     araddr_s5;
  input  [7:0]      arlen_s5;
  input  [2:0]      arsize_s5;
  input  [1:0]      arburst_s5;
  input             arlock_s5;
  input  [3:0]      arcache_s5;
  input  [2:0]      arprot_s5;
  input             arvalid_s5;
  input             arvalid_vect_s5;
  output            arready_s5;
  input  [3:0]      ar_qv_s5;

  output            ruser_s5;
  output  [11:0]     rid_s5;
  output  [63:0]    rdata_s5;
  output [1:0]      rresp_s5;
  output            rlast_s5;
  output            rvalid_s5;
  input             rready_s5;

  input  [9:0]      awuser_s6;
  input  [11:0]      awid_s6;
  input  [39:0]     awaddr_s6;
  input  [7:0]      awlen_s6;
  input  [2:0]      awsize_s6;
  input  [1:0]      awburst_s6;
  input             awlock_s6;
  input  [3:0]      awcache_s6;
  input  [2:0]      awprot_s6;
  input             awvalid_s6;
  input             awvalid_vect_s6;
  output            awready_s6;
  input  [3:0]      aw_qv_s6;
   
  input  [63:0]     wdata_s6;
  input  [7:0]      wstrb_s6;   
  input             wlast_s6;
  input             wvalid_s6;
  output            wready_s6;

  output            buser_s6;
  output [11:0]      bid_s6;
  output [1:0]      bresp_s6;
  output            bvalid_s6;
  input             bready_s6;  

  input  [9:0]      aruser_s6;
  input  [11:0]      arid_s6;
  input  [39:0]     araddr_s6;
  input  [7:0]      arlen_s6;
  input  [2:0]      arsize_s6;
  input  [1:0]      arburst_s6;
  input             arlock_s6;
  input  [3:0]      arcache_s6;
  input  [2:0]      arprot_s6;
  input             arvalid_s6;
  input             arvalid_vect_s6;
  output            arready_s6;
  input  [3:0]      ar_qv_s6;

  output            ruser_s6;
  output  [11:0]     rid_s6;
  output  [63:0]    rdata_s6;
  output [1:0]      rresp_s6;
  output            rlast_s6;
  output            rvalid_s6;
  input             rready_s6;

  input             aclk;
  input             aresetn;


  wire   [6:0]      aw_sel;
  wire              wr_cnt_empty;




nic400_switch2_add_sel_ml4_sse710_main u_nic400_switch2_add_sel_ml4_sse710_main (
        .awuser_m       (awuser_m),
        .awid_m         (awid_m),
        .awaddr_m       (awaddr_m),
        .awlen_m        (awlen_m),
        .awsize_m       (awsize_m),
        .awburst_m      (awburst_m),
        .awlock_m       (awlock_m),
        .awcache_m      (awcache_m),
        .awprot_m       (awprot_m),
        .awvalid_m      (awvalid_m),
        .awvalid_vect_m (awvalid_vect_m),
        .awready_m      (awready_m),
        .aw_qv_m        (aw_qv_m),
        
        .aruser_m       (aruser_m),
        .arid_m         (arid_m),
        .araddr_m       (araddr_m),
        .arlen_m        (arlen_m),
        .arsize_m       (arsize_m),
        .arburst_m      (arburst_m),
        .arlock_m       (arlock_m),
        .arcache_m      (arcache_m),
        .arprot_m       (arprot_m),
        .arvalid_m      (arvalid_m),
        .arvalid_vect_m (arvalid_vect_m),
        .arready_m      (arready_m),
        .ar_qv_m        (ar_qv_m),
        .aw_sel         (aw_sel),
        .wvalid_m       (wvalid_m),
        .wready_m       (wready_m),
        .wlast_m        (wlast_m),
        .bvalid_m       (bvalid_m),
        .bready_m       (bready_m),
        .rvalid_m       (rvalid_m),
        .rready_m       (rready_m),
        .rlast_m        (rlast_m),
        .awuser_s0       (awuser_s0),
        .awid_s0         (awid_s0),
        .awaddr_s0       (awaddr_s0),
        .awlen_s0        (awlen_s0),
        .awsize_s0       (awsize_s0),
        .awburst_s0      (awburst_s0),
        .awlock_s0       (awlock_s0),
        .awcache_s0      (awcache_s0),
        .awprot_s0       (awprot_s0),
        .awvalid_s0      (awvalid_s0),
        .awvalid_vect_s0 (awvalid_vect_s0),
        .awready_s0      (awready_s0),
        .aw_qv_s0        (aw_qv_s0),
        .aruser_s0       (aruser_s0),
        .arid_s0         (arid_s0),
        .araddr_s0       (araddr_s0),
        .arlen_s0        (arlen_s0),
        .arsize_s0       (arsize_s0),
        .arburst_s0      (arburst_s0),
        .arlock_s0       (arlock_s0),
        .arcache_s0      (arcache_s0),
        .arprot_s0       (arprot_s0),
        .arvalid_s0      (arvalid_s0),
        .arvalid_vect_s0 (arvalid_vect_s0),
        .arready_s0      (arready_s0),
        .ar_qv_s0        (ar_qv_s0),

        .awuser_s1       (awuser_s1),
        .awid_s1         (awid_s1),
        .awaddr_s1       (awaddr_s1),
        .awlen_s1        (awlen_s1),
        .awsize_s1       (awsize_s1),
        .awburst_s1      (awburst_s1),
        .awlock_s1       (awlock_s1),
        .awcache_s1      (awcache_s1),
        .awprot_s1       (awprot_s1),
        .awvalid_s1      (awvalid_s1),
        .awvalid_vect_s1 (awvalid_vect_s1),
        .awready_s1      (awready_s1),
        .aw_qv_s1        (aw_qv_s1),
        .aruser_s1       (aruser_s1),
        .arid_s1         (arid_s1),
        .araddr_s1       (araddr_s1),
        .arlen_s1        (arlen_s1),
        .arsize_s1       (arsize_s1),
        .arburst_s1      (arburst_s1),
        .arlock_s1       (arlock_s1),
        .arcache_s1      (arcache_s1),
        .arprot_s1       (arprot_s1),
        .arvalid_s1      (arvalid_s1),
        .arvalid_vect_s1 (arvalid_vect_s1),
        .arready_s1      (arready_s1),
        .ar_qv_s1        (ar_qv_s1),

        .awuser_s2       (awuser_s2),
        .awid_s2         (awid_s2),
        .awaddr_s2       (awaddr_s2),
        .awlen_s2        (awlen_s2),
        .awsize_s2       (awsize_s2),
        .awburst_s2      (awburst_s2),
        .awlock_s2       (awlock_s2),
        .awcache_s2      (awcache_s2),
        .awprot_s2       (awprot_s2),
        .awvalid_s2      (awvalid_s2),
        .awvalid_vect_s2 (awvalid_vect_s2),
        .awready_s2      (awready_s2),
        .aw_qv_s2        (aw_qv_s2),
        .aruser_s2       (aruser_s2),
        .arid_s2         (arid_s2),
        .araddr_s2       (araddr_s2),
        .arlen_s2        (arlen_s2),
        .arsize_s2       (arsize_s2),
        .arburst_s2      (arburst_s2),
        .arlock_s2       (arlock_s2),
        .arcache_s2      (arcache_s2),
        .arprot_s2       (arprot_s2),
        .arvalid_s2      (arvalid_s2),
        .arvalid_vect_s2 (arvalid_vect_s2),
        .arready_s2      (arready_s2),
        .ar_qv_s2        (ar_qv_s2),

        .awuser_s3       (awuser_s3),
        .awid_s3         (awid_s3),
        .awaddr_s3       (awaddr_s3),
        .awlen_s3        (awlen_s3),
        .awsize_s3       (awsize_s3),
        .awburst_s3      (awburst_s3),
        .awlock_s3       (awlock_s3),
        .awcache_s3      (awcache_s3),
        .awprot_s3       (awprot_s3),
        .awvalid_s3      (awvalid_s3),
        .awvalid_vect_s3 (awvalid_vect_s3),
        .awready_s3      (awready_s3),
        .aw_qv_s3        (aw_qv_s3),
        .aruser_s3       (aruser_s3),
        .arid_s3         (arid_s3),
        .araddr_s3       (araddr_s3),
        .arlen_s3        (arlen_s3),
        .arsize_s3       (arsize_s3),
        .arburst_s3      (arburst_s3),
        .arlock_s3       (arlock_s3),
        .arcache_s3      (arcache_s3),
        .arprot_s3       (arprot_s3),
        .arvalid_s3      (arvalid_s3),
        .arvalid_vect_s3 (arvalid_vect_s3),
        .arready_s3      (arready_s3),
        .ar_qv_s3        (ar_qv_s3),

        .awuser_s4       (awuser_s4),
        .awid_s4         (awid_s4),
        .awaddr_s4       (awaddr_s4),
        .awlen_s4        (awlen_s4),
        .awsize_s4       (awsize_s4),
        .awburst_s4      (awburst_s4),
        .awlock_s4       (awlock_s4),
        .awcache_s4      (awcache_s4),
        .awprot_s4       (awprot_s4),
        .awvalid_s4      (awvalid_s4),
        .awvalid_vect_s4 (awvalid_vect_s4),
        .awready_s4      (awready_s4),
        .aw_qv_s4        (aw_qv_s4),
        .aruser_s4       (aruser_s4),
        .arid_s4         (arid_s4),
        .araddr_s4       (araddr_s4),
        .arlen_s4        (arlen_s4),
        .arsize_s4       (arsize_s4),
        .arburst_s4      (arburst_s4),
        .arlock_s4       (arlock_s4),
        .arcache_s4      (arcache_s4),
        .arprot_s4       (arprot_s4),
        .arvalid_s4      (arvalid_s4),
        .arvalid_vect_s4 (arvalid_vect_s4),
        .arready_s4      (arready_s4),
        .ar_qv_s4        (ar_qv_s4),

        .awuser_s5       (awuser_s5),
        .awid_s5         (awid_s5),
        .awaddr_s5       (awaddr_s5),
        .awlen_s5        (awlen_s5),
        .awsize_s5       (awsize_s5),
        .awburst_s5      (awburst_s5),
        .awlock_s5       (awlock_s5),
        .awcache_s5      (awcache_s5),
        .awprot_s5       (awprot_s5),
        .awvalid_s5      (awvalid_s5),
        .awvalid_vect_s5 (awvalid_vect_s5),
        .awready_s5      (awready_s5),
        .aw_qv_s5        (aw_qv_s5),
        .aruser_s5       (aruser_s5),
        .arid_s5         (arid_s5),
        .araddr_s5       (araddr_s5),
        .arlen_s5        (arlen_s5),
        .arsize_s5       (arsize_s5),
        .arburst_s5      (arburst_s5),
        .arlock_s5       (arlock_s5),
        .arcache_s5      (arcache_s5),
        .arprot_s5       (arprot_s5),
        .arvalid_s5      (arvalid_s5),
        .arvalid_vect_s5 (arvalid_vect_s5),
        .arready_s5      (arready_s5),
        .ar_qv_s5        (ar_qv_s5),

        .awuser_s6       (awuser_s6),
        .awid_s6         (awid_s6),
        .awaddr_s6       (awaddr_s6),
        .awlen_s6        (awlen_s6),
        .awsize_s6       (awsize_s6),
        .awburst_s6      (awburst_s6),
        .awlock_s6       (awlock_s6),
        .awcache_s6      (awcache_s6),
        .awprot_s6       (awprot_s6),
        .awvalid_s6      (awvalid_s6),
        .awvalid_vect_s6 (awvalid_vect_s6),
        .awready_s6      (awready_s6),
        .aw_qv_s6        (aw_qv_s6),
        .aruser_s6       (aruser_s6),
        .arid_s6         (arid_s6),
        .araddr_s6       (araddr_s6),
        .arlen_s6        (arlen_s6),
        .arsize_s6       (arsize_s6),
        .arburst_s6      (arburst_s6),
        .arlock_s6       (arlock_s6),
        .arcache_s6      (arcache_s6),
        .arprot_s6       (arprot_s6),
        .arvalid_s6      (arvalid_s6),
        .arvalid_vect_s6 (arvalid_vect_s6),
        .arready_s6      (arready_s6),
        .ar_qv_s6        (ar_qv_s6),

        .wr_cnt_empty   (wr_cnt_empty),
        .aclk           (aclk),
        .aresetn        (aresetn)
);

nic400_switch2_wr_sel_ml4_sse710_main u_nic400_switch2_wr_sel_ml4_sse710_main (
        .wdata_s0     (wdata_s0),
        .wstrb_s0     (wstrb_s0),
        .wlast_s0     (wlast_s0),
        .wvalid_s0    (wvalid_s0),
        .wready_s0    (wready_s0),

        .wdata_s1     (wdata_s1),
        .wstrb_s1     (wstrb_s1),
        .wlast_s1     (wlast_s1),
        .wvalid_s1    (wvalid_s1),
        .wready_s1    (wready_s1),

        .wdata_s2     (wdata_s2),
        .wstrb_s2     (wstrb_s2),
        .wlast_s2     (wlast_s2),
        .wvalid_s2    (wvalid_s2),
        .wready_s2    (wready_s2),

        .wdata_s3     (wdata_s3),
        .wstrb_s3     (wstrb_s3),
        .wlast_s3     (wlast_s3),
        .wvalid_s3    (wvalid_s3),
        .wready_s3    (wready_s3),

        .wdata_s4     (wdata_s4),
        .wstrb_s4     (wstrb_s4),
        .wlast_s4     (wlast_s4),
        .wvalid_s4    (wvalid_s4),
        .wready_s4    (wready_s4),

        .wdata_s5     (wdata_s5),
        .wstrb_s5     (wstrb_s5),
        .wlast_s5     (wlast_s5),
        .wvalid_s5    (wvalid_s5),
        .wready_s5    (wready_s5),

        .wdata_s6     (wdata_s6),
        .wstrb_s6     (wstrb_s6),
        .wlast_s6     (wlast_s6),
        .wvalid_s6    (wvalid_s6),
        .wready_s6    (wready_s6),

        .aw_sel       (aw_sel),
        .awready_m    (awready_m),
        .aclk         (aclk),
        .aresetn      (aresetn),
        .wdata_m      (wdata_m),
        .wstrb_m      (wstrb_m),
        .wlast_m      (wlast_m),
        .wvalid_m     (wvalid_m),
        .wready_m     (wready_m)
);



nic400_switch2_ret_sel_ml4_sse710_main u_nic400_switch2_ret_sel_ml4_sse710_main (
        .wr_cnt_empty (wr_cnt_empty),
        .buser_s0     (buser_s0),
        .bid_s0       (bid_s0),
        .bresp_s0     (bresp_s0),
        .bvalid_s0    (bvalid_s0),
        .bready_s0    (bready_s0),
        .ruser_s0     (ruser_s0),
        .rid_s0       (rid_s0),
        .rdata_s0     (rdata_s0),
        .rresp_s0     (rresp_s0),
        .rlast_s0     (rlast_s0),
        .rvalid_s0    (rvalid_s0),
        .rready_s0    (rready_s0),
        .buser_s1     (buser_s1),
        .bid_s1       (bid_s1),
        .bresp_s1     (bresp_s1),
        .bvalid_s1    (bvalid_s1),
        .bready_s1    (bready_s1),
        .ruser_s1     (ruser_s1),
        .rid_s1       (rid_s1),
        .rdata_s1     (rdata_s1),
        .rresp_s1     (rresp_s1),
        .rlast_s1     (rlast_s1),
        .rvalid_s1    (rvalid_s1),
        .rready_s1    (rready_s1),
        .buser_s2     (buser_s2),
        .bid_s2       (bid_s2),
        .bresp_s2     (bresp_s2),
        .bvalid_s2    (bvalid_s2),
        .bready_s2    (bready_s2),
        .ruser_s2     (ruser_s2),
        .rid_s2       (rid_s2),
        .rdata_s2     (rdata_s2),
        .rresp_s2     (rresp_s2),
        .rlast_s2     (rlast_s2),
        .rvalid_s2    (rvalid_s2),
        .rready_s2    (rready_s2),
        .buser_s3     (buser_s3),
        .bid_s3       (bid_s3),
        .bresp_s3     (bresp_s3),
        .bvalid_s3    (bvalid_s3),
        .bready_s3    (bready_s3),
        .ruser_s3     (ruser_s3),
        .rid_s3       (rid_s3),
        .rdata_s3     (rdata_s3),
        .rresp_s3     (rresp_s3),
        .rlast_s3     (rlast_s3),
        .rvalid_s3    (rvalid_s3),
        .rready_s3    (rready_s3),
        .buser_s4     (buser_s4),
        .bid_s4       (bid_s4),
        .bresp_s4     (bresp_s4),
        .bvalid_s4    (bvalid_s4),
        .bready_s4    (bready_s4),
        .ruser_s4     (ruser_s4),
        .rid_s4       (rid_s4),
        .rdata_s4     (rdata_s4),
        .rresp_s4     (rresp_s4),
        .rlast_s4     (rlast_s4),
        .rvalid_s4    (rvalid_s4),
        .rready_s4    (rready_s4),
        .buser_s5     (buser_s5),
        .bid_s5       (bid_s5),
        .bresp_s5     (bresp_s5),
        .bvalid_s5    (bvalid_s5),
        .bready_s5    (bready_s5),
        .ruser_s5     (ruser_s5),
        .rid_s5       (rid_s5),
        .rdata_s5     (rdata_s5),
        .rresp_s5     (rresp_s5),
        .rlast_s5     (rlast_s5),
        .rvalid_s5    (rvalid_s5),
        .rready_s5    (rready_s5),
        .buser_s6     (buser_s6),
        .bid_s6       (bid_s6),
        .bresp_s6     (bresp_s6),
        .bvalid_s6    (bvalid_s6),
        .bready_s6    (bready_s6),
        .ruser_s6     (ruser_s6),
        .rid_s6       (rid_s6),
        .rdata_s6     (rdata_s6),
        .rresp_s6     (rresp_s6),
        .rlast_s6     (rlast_s6),
        .rvalid_s6    (rvalid_s6),
        .rready_s6    (rready_s6),
        .buser_m      (buser_m),
        .bid_m        (bid_m),
        .bresp_m      (bresp_m),
        .bvalid_m     (bvalid_m),
        .bready_m     (bready_m),
        .ruser_m      (ruser_m),
        .rid_m        (rid_m),
        .rdata_m      (rdata_m),
        .rresp_m      (rresp_m),
        .rlast_m      (rlast_m),
        .rvalid_m     (rvalid_m),
        .rready_m     (rready_m)
);


 
    `ifdef ARM_ASSERT_ON

 wire [6:0] rsel;
 wire [6:0] bsel;
 assign rsel = u_nic400_switch2_ret_sel_ml4_sse710_main.rsel;
 assign bsel = u_nic400_switch2_ret_sel_ml4_sse710_main.rsel;

      assert_zero_one_hot #(0,7,0,"ERROR, More than one read response destination")
         ovl_rsel_en4
           (
            .clk       (aclk),
            .reset_n   (aresetn),
            .test_expr (rsel)
            );
      assert_zero_one_hot #(0,7,0,"ERROR, More than one buffered response destination")
         ovl_bsel_en4
           (
            .clk       (aclk),
            .reset_n   (aresetn),
            .test_expr (bsel)
            );


    `endif

  endmodule


