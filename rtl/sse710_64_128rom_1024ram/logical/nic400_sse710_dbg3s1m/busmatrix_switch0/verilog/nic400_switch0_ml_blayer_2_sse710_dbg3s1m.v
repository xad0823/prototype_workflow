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


module nic400_switch0_ml_blayer_2_sse710_dbg3s1m
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
    rready_m0
  );



  input [2:0]       awuser_s;
  input [3:0]       awid_s;
  input [31:0]      awaddr_s;
  input [7:0]       awlen_s;
  input [2:0]       awsize_s;
  input [1:0]       awburst_s;
  input             awlock_s;
  input [3:0]       awcache_s;
  input [2:0]       awprot_s;
  input             awvalid_s;
  input             awvalid_vect_s;
  output            awready_s;
  input [3:0]       aw_qv_s;

  input  [31:0]     wdata_s;
  input  [3:0]      wstrb_s;
  input             wlast_s;
  input             wvalid_s;
  output            wready_s;

  output [3:0]      bid_s;
  output [1:0]      bresp_s;
  output            bvalid_s;
  input             bready_s;

  input [2:0]       aruser_s;
  input [3:0]       arid_s;
  input [31:0]      araddr_s;
  input [7:0]       arlen_s;
  input [2:0]       arsize_s;
  input [1:0]       arburst_s;
  input             arlock_s;
  input [3:0]       arcache_s;
  input [2:0]       arprot_s;
  input             arvalid_s;
  input             arvalid_vect_s;
  output            arready_s;
  input [3:0]       ar_qv_s;

  output [3:0]      rid_s;
  output [31:0]     rdata_s;
  output [1:0]      rresp_s;
  output            rlast_s;
  output            rvalid_s;
  input             rready_s;


  output [2:0]                      awuser_m0;
  output [3:0]      awid_m0;
  output [31:0]     awaddr_m0;
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

  input [3:0]       bid_m0;
  input [1:0]       bresp_m0;
  input             bvalid_m0;
  output            bready_m0;

  output  [2:0]          aruser_m0;
  output  [3:0]     arid_m0;
  output  [31:0]    araddr_m0;
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
   
  input [3:0]       rid_m0;
  input [31:0]      rdata_m0;
  input [1:0]       rresp_m0;
  input             rlast_m0;
  input             rvalid_m0;
  output            rready_m0;



  wire            aw_enable;
  wire            awready_s_int;
  wire            wready_s_int;
  wire            arready_s_int;
  wire            tt_enable_wr;
  wire            wr_enable;
  wire            tt_enable_rd;
  wire            bvalid_s_int;
  wire [3:0]           bid_s_int;
  wire [1:0]           bresp_s_int;
  wire            rvalid_s_int;
  wire            rlast_s_int;
  wire [3:0]           rid_s_int;
  wire [31:0]           rdata_s_int;
  wire [1:0]           rresp_s_int;




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
  assign awvalid_m0 = awvalid_s & aw_enable;
  assign awvalid_vect_m0 = awvalid_vect_s & aw_enable;

  assign awready_s_int = awready_m0 & aw_enable; 
  assign awready_s = awready_s_int;


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
  assign arvalid_m0 = arvalid_s;
  assign arvalid_vect_m0 = arvalid_vect_s;

  assign arready_s_int = arready_m0; 
  assign arready_s = arready_s_int;



  assign aw_enable    = 1'b1;
  assign wr_enable    = 1'b1;
  assign tt_enable_wr = 1'b1;
  assign tt_enable_rd = 1'b1;


  assign wdata_m0 = wdata_s;
  assign wstrb_m0 = wstrb_s;
  assign wlast_m0 = wlast_s;
  assign wvalid_m0 = wvalid_s & wr_enable;
  assign wready_s_int = wready_m0 & wr_enable;
  
  assign wready_s = wready_s_int;





  assign bid_s_int[3:0] = bid_m0 & {4{tt_enable_wr}};
  assign bresp_s_int[1:0] = bresp_m0 & {2{tt_enable_wr}};
  assign bvalid_s_int = bvalid_m0 & tt_enable_wr;
  assign bready_m0 = bready_s & tt_enable_wr;
  assign bvalid_s = bvalid_s_int;
  assign bid_s = bid_s_int[3:0];
  assign bresp_s = bresp_s_int[1:0];

  assign rid_s_int[3:0] = rid_m0 & {4{tt_enable_rd}};
  assign rdata_s_int[31:0] = rdata_m0 & {32{tt_enable_rd}};
  assign rresp_s_int[1:0] = rresp_m0 & {2{tt_enable_rd}};
  assign rlast_s_int = rlast_m0 & tt_enable_rd;
  assign rvalid_s_int = rvalid_m0 & tt_enable_rd;
  assign rready_m0 = rready_s & tt_enable_rd;
  assign rvalid_s = rvalid_s_int;
  assign rlast_s = rlast_s_int;
  assign rid_s = rid_s_int[3:0];
  assign rresp_s = rresp_s_int[1:0];
  assign rdata_s = rdata_s_int[31:0];

  endmodule


