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




module nic400_cd_clk0_sse710_boot_reg (
  

  awid_slave_if0_0_m_s,
  awaddr_slave_if0_0_m_s,
  awlen_slave_if0_0_m_s,
  awsize_slave_if0_0_m_s,
  awburst_slave_if0_0_m_s,
  awlock_slave_if0_0_m_s,
  awcache_slave_if0_0_m_s,
  awprot_slave_if0_0_m_s,
  awvalid_slave_if0_0_m_s,
  awready_slave_if0_0_m_s,
  wdata_slave_if0_0_m_s,
  wstrb_slave_if0_0_m_s,
  wlast_slave_if0_0_m_s,
  wvalid_slave_if0_0_m_s,
  wready_slave_if0_0_m_s,
  bid_slave_if0_0_m_s,
  bresp_slave_if0_0_m_s,
  bvalid_slave_if0_0_m_s,
  bready_slave_if0_0_m_s,
  arid_slave_if0_0_m_s,
  araddr_slave_if0_0_m_s,
  arlen_slave_if0_0_m_s,
  arsize_slave_if0_0_m_s,
  arburst_slave_if0_0_m_s,
  arlock_slave_if0_0_m_s,
  arcache_slave_if0_0_m_s,
  arprot_slave_if0_0_m_s,
  arvalid_slave_if0_0_m_s,
  arready_slave_if0_0_m_s,
  rid_slave_if0_0_m_s,
  rdata_slave_if0_0_m_s,
  rresp_slave_if0_0_m_s,
  rlast_slave_if0_0_m_s,
  rvalid_slave_if0_0_m_s,
  rready_slave_if0_0_m_s,
  

  a_data_slave_if0_0_m_ib_int_async,
  a_rpntr_gry_slave_if0_0_m_ib_int_async,
  a_rpntr_bin_slave_if0_0_m_ib_int_async,
  a_wpntr_gry_slave_if0_0_m_ib_int_async,
  d_data_slave_if0_0_m_ib_int_async,
  d_rpntr_gry_slave_if0_0_m_ib_int_async,
  d_rpntr_bin_slave_if0_0_m_ib_int_async,
  d_wpntr_gry_slave_if0_0_m_ib_int_async,
  w_data_slave_if0_0_m_ib_int_async,
  w_rpntr_gry_slave_if0_0_m_ib_int_async,
  w_rpntr_bin_slave_if0_0_m_ib_int_async,
  w_wpntr_gry_slave_if0_0_m_ib_int_async,
  empty_slave_if0_0_m_ib_int_async,


  clk0clk,
  clk0resetn

);






input  [9:0]  awid_slave_if0_0_m_s;
input  [31:0] awaddr_slave_if0_0_m_s;
input  [7:0]  awlen_slave_if0_0_m_s;
input  [2:0]  awsize_slave_if0_0_m_s;
input  [1:0]  awburst_slave_if0_0_m_s;
input         awlock_slave_if0_0_m_s;
input  [3:0]  awcache_slave_if0_0_m_s;
input  [2:0]  awprot_slave_if0_0_m_s;
input         awvalid_slave_if0_0_m_s;
output        awready_slave_if0_0_m_s;
input  [31:0] wdata_slave_if0_0_m_s;
input  [3:0]  wstrb_slave_if0_0_m_s;
input         wlast_slave_if0_0_m_s;
input         wvalid_slave_if0_0_m_s;
output        wready_slave_if0_0_m_s;
output [9:0]  bid_slave_if0_0_m_s;
output [1:0]  bresp_slave_if0_0_m_s;
output        bvalid_slave_if0_0_m_s;
input         bready_slave_if0_0_m_s;
input  [9:0]  arid_slave_if0_0_m_s;
input  [31:0] araddr_slave_if0_0_m_s;
input  [7:0]  arlen_slave_if0_0_m_s;
input  [2:0]  arsize_slave_if0_0_m_s;
input  [1:0]  arburst_slave_if0_0_m_s;
input         arlock_slave_if0_0_m_s;
input  [3:0]  arcache_slave_if0_0_m_s;
input  [2:0]  arprot_slave_if0_0_m_s;
input         arvalid_slave_if0_0_m_s;
output        arready_slave_if0_0_m_s;
output [9:0]  rid_slave_if0_0_m_s;
output [31:0] rdata_slave_if0_0_m_s;
output [1:0]  rresp_slave_if0_0_m_s;
output        rlast_slave_if0_0_m_s;
output        rvalid_slave_if0_0_m_s;
input         rready_slave_if0_0_m_s;


output [63:0] a_data_slave_if0_0_m_ib_int_async;
input  [1:0]  a_rpntr_gry_slave_if0_0_m_ib_int_async;
input         a_rpntr_bin_slave_if0_0_m_ib_int_async;
output [1:0]  a_wpntr_gry_slave_if0_0_m_ib_int_async;
input  [45:0] d_data_slave_if0_0_m_ib_int_async;
output [1:0]  d_rpntr_gry_slave_if0_0_m_ib_int_async;
output        d_rpntr_bin_slave_if0_0_m_ib_int_async;
input  [1:0]  d_wpntr_gry_slave_if0_0_m_ib_int_async;
output [36:0] w_data_slave_if0_0_m_ib_int_async;
input  [1:0]  w_rpntr_gry_slave_if0_0_m_ib_int_async;
input         w_rpntr_bin_slave_if0_0_m_ib_int_async;
output [1:0]  w_wpntr_gry_slave_if0_0_m_ib_int_async;
output        empty_slave_if0_0_m_ib_int_async;


input         clk0clk;
input         clk0resetn;




wire   [63:0]  a_data_slave_if0_0_m_ib_int_async;
wire   [1:0]   a_wpntr_gry_slave_if0_0_m_ib_int_async;
wire           arready_slave_if0_0_m_s;
wire           awready_slave_if0_0_m_s;
wire   [9:0]   bid_slave_if0_0_m_s;
wire   [1:0]   bresp_slave_if0_0_m_s;
wire           bvalid_slave_if0_0_m_s;
wire           d_rpntr_bin_slave_if0_0_m_ib_int_async;
wire   [1:0]   d_rpntr_gry_slave_if0_0_m_ib_int_async;
wire           empty_slave_if0_0_m_ib_int_async;
wire   [31:0]  rdata_slave_if0_0_m_s;
wire   [9:0]   rid_slave_if0_0_m_s;
wire           rlast_slave_if0_0_m_s;
wire   [1:0]   rresp_slave_if0_0_m_s;
wire           rvalid_slave_if0_0_m_s;
wire   [36:0]  w_data_slave_if0_0_m_ib_int_async;
wire   [1:0]   w_wpntr_gry_slave_if0_0_m_ib_int_async;
wire           wready_slave_if0_0_m_s;
wire           a_rpntr_bin_slave_if0_0_m_ib_int_async;
wire   [1:0]   a_rpntr_gry_slave_if0_0_m_ib_int_async;
wire   [31:0]  araddr_slave_if0_0_m_s;
wire   [1:0]   arburst_slave_if0_0_m_s;
wire   [3:0]   arcache_slave_if0_0_m_s;
wire   [9:0]   arid_slave_if0_0_m_s;
wire   [7:0]   arlen_slave_if0_0_m_s;
wire           arlock_slave_if0_0_m_s;
wire   [2:0]   arprot_slave_if0_0_m_s;
wire   [2:0]   arsize_slave_if0_0_m_s;
wire           arvalid_slave_if0_0_m_s;
wire   [31:0]  awaddr_slave_if0_0_m_s;
wire   [1:0]   awburst_slave_if0_0_m_s;
wire   [3:0]   awcache_slave_if0_0_m_s;
wire   [9:0]   awid_slave_if0_0_m_s;
wire   [7:0]   awlen_slave_if0_0_m_s;
wire           awlock_slave_if0_0_m_s;
wire   [2:0]   awprot_slave_if0_0_m_s;
wire   [2:0]   awsize_slave_if0_0_m_s;
wire           awvalid_slave_if0_0_m_s;
wire           bready_slave_if0_0_m_s;
wire           clk0clk;
wire           clk0resetn;
wire   [45:0]  d_data_slave_if0_0_m_ib_int_async;
wire   [1:0]   d_wpntr_gry_slave_if0_0_m_ib_int_async;
wire           rready_slave_if0_0_m_s;
wire           w_rpntr_bin_slave_if0_0_m_ib_int_async;
wire   [1:0]   w_rpntr_gry_slave_if0_0_m_ib_int_async;
wire   [31:0]  wdata_slave_if0_0_m_s;
wire           wlast_slave_if0_0_m_s;
wire   [3:0]   wstrb_slave_if0_0_m_s;
wire           wvalid_slave_if0_0_m_s;




nic400_ib_slave_if0_0_m_ib_slave_domain_sse710_boot_reg     u_ib_slave_if0_0_m_ib_s (
  .awid_axi4_s          (awid_slave_if0_0_m_s),
  .awaddr_axi4_s        (awaddr_slave_if0_0_m_s),
  .awlen_axi4_s         (awlen_slave_if0_0_m_s),
  .awsize_axi4_s        (awsize_slave_if0_0_m_s),
  .awburst_axi4_s       (awburst_slave_if0_0_m_s),
  .awlock_axi4_s        (awlock_slave_if0_0_m_s),
  .awcache_axi4_s       (awcache_slave_if0_0_m_s),
  .awprot_axi4_s        (awprot_slave_if0_0_m_s),
  .awvalid_axi4_s       (awvalid_slave_if0_0_m_s),
  .awready_axi4_s       (awready_slave_if0_0_m_s),
  .wdata_axi4_s         (wdata_slave_if0_0_m_s),
  .wstrb_axi4_s         (wstrb_slave_if0_0_m_s),
  .wlast_axi4_s         (wlast_slave_if0_0_m_s),
  .wvalid_axi4_s        (wvalid_slave_if0_0_m_s),
  .wready_axi4_s        (wready_slave_if0_0_m_s),
  .bid_axi4_s           (bid_slave_if0_0_m_s),
  .bresp_axi4_s         (bresp_slave_if0_0_m_s),
  .bvalid_axi4_s        (bvalid_slave_if0_0_m_s),
  .bready_axi4_s        (bready_slave_if0_0_m_s),
  .arid_axi4_s          (arid_slave_if0_0_m_s),
  .araddr_axi4_s        (araddr_slave_if0_0_m_s),
  .arlen_axi4_s         (arlen_slave_if0_0_m_s),
  .arsize_axi4_s        (arsize_slave_if0_0_m_s),
  .arburst_axi4_s       (arburst_slave_if0_0_m_s),
  .arlock_axi4_s        (arlock_slave_if0_0_m_s),
  .arcache_axi4_s       (arcache_slave_if0_0_m_s),
  .arprot_axi4_s        (arprot_slave_if0_0_m_s),
  .arvalid_axi4_s       (arvalid_slave_if0_0_m_s),
  .arready_axi4_s       (arready_slave_if0_0_m_s),
  .rid_axi4_s           (rid_slave_if0_0_m_s),
  .rdata_axi4_s         (rdata_slave_if0_0_m_s),
  .rresp_axi4_s         (rresp_slave_if0_0_m_s),
  .rlast_axi4_s         (rlast_slave_if0_0_m_s),
  .rvalid_axi4_s        (rvalid_slave_if0_0_m_s),
  .rready_axi4_s        (rready_slave_if0_0_m_s),
  .aclk_s               (clk0clk),
  .aresetn_s            (clk0resetn),
  .a_data_async         (a_data_slave_if0_0_m_ib_int_async),
  .a_rpntr_gry_async    (a_rpntr_gry_slave_if0_0_m_ib_int_async),
  .a_rpntr_bin          (a_rpntr_bin_slave_if0_0_m_ib_int_async),
  .a_wpntr_gry_async    (a_wpntr_gry_slave_if0_0_m_ib_int_async),
  .d_data_async         (d_data_slave_if0_0_m_ib_int_async),
  .d_rpntr_gry_async    (d_rpntr_gry_slave_if0_0_m_ib_int_async),
  .d_rpntr_bin          (d_rpntr_bin_slave_if0_0_m_ib_int_async),
  .d_wpntr_gry_async    (d_wpntr_gry_slave_if0_0_m_ib_int_async),
  .w_data_async         (w_data_slave_if0_0_m_ib_int_async),
  .w_rpntr_gry_async    (w_rpntr_gry_slave_if0_0_m_ib_int_async),
  .w_rpntr_bin          (w_rpntr_bin_slave_if0_0_m_ib_int_async),
  .w_wpntr_gry_async    (w_wpntr_gry_slave_if0_0_m_ib_int_async),
  .empty_async          (empty_slave_if0_0_m_ib_int_async)
);



endmodule
