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


module nic400_bm0_ml_blayer_0_sse710_integration_example_f0_cvm
  (

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
    aclk,
    aresetn
  );



  input [11:0]       awid_s;
  input [31:0]      awaddr_s;
  input [7:0]       awlen_s;
  input [2:0]       awsize_s;
  input [1:0]       awburst_s;
  input             awlock_s;
  input [3:0]       awcache_s;
  input [2:0]       awprot_s;
  input             awvalid_s;
  input [1:0]            awvalid_vect_s;
  output            awready_s;
  input [3:0]       aw_qv_s;

  input  [63:0]     wdata_s;
  input  [7:0]      wstrb_s;
  input             wlast_s;
  input             wvalid_s;
  output            wready_s;

  output [11:0]      bid_s;
  output [1:0]      bresp_s;
  output            bvalid_s;
  input             bready_s;

  input [11:0]       arid_s;
  input [31:0]      araddr_s;
  input [7:0]       arlen_s;
  input [2:0]       arsize_s;
  input [1:0]       arburst_s;
  input             arlock_s;
  input [3:0]       arcache_s;
  input [2:0]       arprot_s;
  input             arvalid_s;
  input [1:0]            arvalid_vect_s;
  output            arready_s;
  input [3:0]       ar_qv_s;

  output [11:0]      rid_s;
  output [63:0]     rdata_s;
  output [1:0]      rresp_s;
  output            rlast_s;
  output            rvalid_s;
  input             rready_s;


  output [11:0]      awid_m0;
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
   
  output  [63:0]    wdata_m0;
  output  [7:0]     wstrb_m0;
  output            wlast_m0;
  output            wvalid_m0;
  input             wready_m0;

  input [11:0]       bid_m0;
  input [1:0]       bresp_m0;
  input             bvalid_m0;
  output            bready_m0;

  output  [11:0]     arid_m0;
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
   
  input [11:0]       rid_m0;
  input [63:0]      rdata_m0;
  input [1:0]       rresp_m0;
  input             rlast_m0;
  input             rvalid_m0;
  output            rready_m0;


  output [11:0]      awid_m1;
  output [31:0]     awaddr_m1;
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
   
  output  [63:0]    wdata_m1;
  output  [7:0]     wstrb_m1;
  output            wlast_m1;
  output            wvalid_m1;
  input             wready_m1;

  input [11:0]       bid_m1;
  input [1:0]       bresp_m1;
  input             bvalid_m1;
  output            bready_m1;

  output  [11:0]     arid_m1;
  output  [31:0]    araddr_m1;
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
   
  input [11:0]       rid_m1;
  input [63:0]      rdata_m1;
  input [1:0]       rresp_m1;
  input             rlast_m1;
  input             rvalid_m1;
  output            rready_m1;

  input             aclk;
  input             aresetn;


  wire [1:0]           aw_enable;
  wire [1:0]           ar_enable;
  wire [1:0]           awready_s_int;
  wire [1:0]           wready_s_int;
  wire [1:0]           arready_s_int;
  wire [1:0]           awsel;
  wire [1:0]           arsel;
  wire [1:0]           tt_enable_wr;
  wire [1:0]           wr_enable;
  wire [1:0]           tt_enable_rd;
  wire [1:0]           bvalid_s_int;
  wire [23:0]           bid_s_int;
  wire [3:0]           bresp_s_int;
  wire [1:0]           rvalid_s_int;
  wire [1:0]           rlast_s_int;
  wire [23:0]           rid_s_int;
  wire [127:0]           rdata_s_int;
  wire [3:0]           rresp_s_int;




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

  assign awready_s_int[0] = awready_m0 & aw_enable[0];
  assign awready_s_int[1] = awready_m1 & aw_enable[1]; 
  assign awready_s = |awready_s_int;


  assign arid_m0 = arid_s;
  assign araddr_m0 = araddr_s;
  assign arlen_m0 = arlen_s;
  assign arsize_m0 = arsize_s;
  assign arburst_m0 = arburst_s;
  assign arlock_m0 = arlock_s;
  assign arcache_m0 = arcache_s;
  assign arprot_m0 = arprot_s;
  assign ar_qv_m0 = ar_qv_s;
  assign arvalid_m0 = arvalid_s & ar_enable[0];
  assign arvalid_vect_m0 = arvalid_vect_s[0]  & ar_enable[0];

  assign arid_m1 = arid_s;
  assign araddr_m1 = araddr_s;
  assign arlen_m1 = arlen_s;
  assign arsize_m1 = arsize_s;
  assign arburst_m1 = arburst_s;
  assign arlock_m1 = arlock_s;
  assign arcache_m1 = arcache_s;
  assign arprot_m1 = arprot_s;
  assign ar_qv_m1 = ar_qv_s;
  assign arvalid_m1 = arvalid_s & ar_enable[1];
  assign arvalid_vect_m1 = arvalid_vect_s[1]  & ar_enable[1];

  assign arready_s_int[0] = arready_m0 & ar_enable[0];
  assign arready_s_int[1] = arready_m1 & ar_enable[1]; 
  assign arready_s = |arready_s_int;


  assign awsel[0] = awvalid_s & awvalid_vect_s[0];
  assign arsel[0] = arvalid_s & arvalid_vect_s[0];
  assign awsel[1] = awvalid_s & awvalid_vect_s[1];
  assign arsel[1] = arvalid_s & arvalid_vect_s[1];

  nic400_bm0_wr_ss_tt_s0_sse710_integration_example_f0_cvm u_nic400_bm0_wr_ss_tt_2_2m_sse710_integration_example_f0_cvm (
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
        .aclk         (aclk),
        .aresetn      (aresetn)
  );

  nic400_bm0_rd_ss_tt_s0_sse710_integration_example_f0_cvm u_nic400_bm0_rd_ss_tt_2_2m_sse710_integration_example_f0_cvm (
        .ar_enable    (ar_enable),
        .tt_enable    (tt_enable_rd),

        .asel         (arsel),
        .aready       (arready_s),
        .resp_valid   (rvalid_s),
        .resp_last    (rlast_s),
        .resp_ready   (rready_s),

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
  
  assign wready_s = |wready_s_int;





  assign bid_s_int[11:0] = bid_m0 & {12{tt_enable_wr[0]}};
  assign bresp_s_int[1:0] = bresp_m0 & {2{tt_enable_wr[0]}};
  assign bvalid_s_int[0] = bvalid_m0 & tt_enable_wr[0];
  assign bready_m0 = bready_s & tt_enable_wr[0];

  assign bid_s_int[23:12] = bid_m1 & {12{tt_enable_wr[1]}};
  assign bresp_s_int[3:2] = bresp_m1 & {2{tt_enable_wr[1]}};
  assign bvalid_s_int[1] = bvalid_m1 & tt_enable_wr[1];
  assign bready_m1 = bready_s & tt_enable_wr[1];
  assign bvalid_s = |bvalid_s_int;
  assign bid_s = bid_s_int[11:0]
                 | bid_s_int[23:12];
  assign bresp_s = bresp_s_int[1:0]
                 | bresp_s_int[3:2];

  assign rid_s_int[11:0] = rid_m0 & {12{tt_enable_rd[0]}};
  assign rdata_s_int[63:0] = rdata_m0 & {64{tt_enable_rd[0]}};
  assign rresp_s_int[1:0] = rresp_m0 & {2{tt_enable_rd[0]}};
  assign rlast_s_int[0] = rlast_m0 & tt_enable_rd[0];
  assign rvalid_s_int[0] = rvalid_m0 & tt_enable_rd[0];
  assign rready_m0 = rready_s & tt_enable_rd[0];

  assign rid_s_int[23:12] = rid_m1 & {12{tt_enable_rd[1]}};
  assign rdata_s_int[127:64] = rdata_m1 & {64{tt_enable_rd[1]}};
  assign rresp_s_int[3:2] = rresp_m1 & {2{tt_enable_rd[1]}};
  assign rlast_s_int[1] = rlast_m1 & tt_enable_rd[1];
  assign rvalid_s_int[1] = rvalid_m1 & tt_enable_rd[1];
  assign rready_m1 = rready_s & tt_enable_rd[1];
  assign rvalid_s = |rvalid_s_int;
  assign rlast_s = |rlast_s_int;
  assign rid_s = rid_s_int[11:0]
                 | rid_s_int[23:12];
  assign rresp_s = rresp_s_int[1:0]
                 | rresp_s_int[3:2];
  assign rdata_s = rdata_s_int[63:0]
                 | rdata_s_int[127:64];

  endmodule


