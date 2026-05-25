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




module nic400_sse710_integration_example_f0_upsizer (
  

  awid_axi_m,
  awaddr_axi_m,
  awlen_axi_m,
  awsize_axi_m,
  awburst_axi_m,
  awlock_axi_m,
  awcache_axi_m,
  awprot_axi_m,
  awvalid_axi_m,
  awready_axi_m,
  wdata_axi_m,
  wstrb_axi_m,
  wlast_axi_m,
  wvalid_axi_m,
  wready_axi_m,
  bid_axi_m,
  bresp_axi_m,
  bvalid_axi_m,
  bready_axi_m,
  arid_axi_m,
  araddr_axi_m,
  arlen_axi_m,
  arsize_axi_m,
  arburst_axi_m,
  arlock_axi_m,
  arcache_axi_m,
  arprot_axi_m,
  arvalid_axi_m,
  arready_axi_m,
  rid_axi_m,
  rdata_axi_m,
  rresp_axi_m,
  rlast_axi_m,
  rvalid_axi_m,
  rready_axi_m,
  

  awid_axi_m_s,
  awaddr_axi_m_s,
  awlen_axi_m_s,
  awsize_axi_m_s,
  awburst_axi_m_s,
  awlock_axi_m_s,
  awcache_axi_m_s,
  awprot_axi_m_s,
  awvalid_axi_m_s,
  awready_axi_m_s,
  wdata_axi_m_s,
  wstrb_axi_m_s,
  wlast_axi_m_s,
  wvalid_axi_m_s,
  wready_axi_m_s,
  bid_axi_m_s,
  bresp_axi_m_s,
  bvalid_axi_m_s,
  bready_axi_m_s,
  arid_axi_m_s,
  araddr_axi_m_s,
  arlen_axi_m_s,
  arsize_axi_m_s,
  arburst_axi_m_s,
  arlock_axi_m_s,
  arcache_axi_m_s,
  arprot_axi_m_s,
  arvalid_axi_m_s,
  arready_axi_m_s,
  rid_axi_m_s,
  rdata_axi_m_s,
  rresp_axi_m_s,
  rlast_axi_m_s,
  rvalid_axi_m_s,
  rready_axi_m_s,


  clk0clk,
  clk0resetn

);






output        awid_axi_m;
output [31:0] awaddr_axi_m;
output [7:0]  awlen_axi_m;
output [2:0]  awsize_axi_m;
output [1:0]  awburst_axi_m;
output        awlock_axi_m;
output [3:0]  awcache_axi_m;
output [2:0]  awprot_axi_m;
output        awvalid_axi_m;
input         awready_axi_m;
output [63:0] wdata_axi_m;
output [7:0]  wstrb_axi_m;
output        wlast_axi_m;
output        wvalid_axi_m;
input         wready_axi_m;
input         bid_axi_m;
input  [1:0]  bresp_axi_m;
input         bvalid_axi_m;
output        bready_axi_m;
output        arid_axi_m;
output [31:0] araddr_axi_m;
output [7:0]  arlen_axi_m;
output [2:0]  arsize_axi_m;
output [1:0]  arburst_axi_m;
output        arlock_axi_m;
output [3:0]  arcache_axi_m;
output [2:0]  arprot_axi_m;
output        arvalid_axi_m;
input         arready_axi_m;
input         rid_axi_m;
input  [63:0] rdata_axi_m;
input  [1:0]  rresp_axi_m;
input         rlast_axi_m;
input         rvalid_axi_m;
output        rready_axi_m;


input         awid_axi_m_s;
input  [31:0] awaddr_axi_m_s;
input  [7:0]  awlen_axi_m_s;
input  [2:0]  awsize_axi_m_s;
input  [1:0]  awburst_axi_m_s;
input         awlock_axi_m_s;
input  [3:0]  awcache_axi_m_s;
input  [2:0]  awprot_axi_m_s;
input         awvalid_axi_m_s;
output        awready_axi_m_s;
input  [31:0] wdata_axi_m_s;
input  [3:0]  wstrb_axi_m_s;
input         wlast_axi_m_s;
input         wvalid_axi_m_s;
output        wready_axi_m_s;
output        bid_axi_m_s;
output [1:0]  bresp_axi_m_s;
output        bvalid_axi_m_s;
input         bready_axi_m_s;
input         arid_axi_m_s;
input  [31:0] araddr_axi_m_s;
input  [7:0]  arlen_axi_m_s;
input  [2:0]  arsize_axi_m_s;
input  [1:0]  arburst_axi_m_s;
input         arlock_axi_m_s;
input  [3:0]  arcache_axi_m_s;
input  [2:0]  arprot_axi_m_s;
input         arvalid_axi_m_s;
output        arready_axi_m_s;
output        rid_axi_m_s;
output [31:0] rdata_axi_m_s;
output [1:0]  rresp_axi_m_s;
output        rlast_axi_m_s;
output        rvalid_axi_m_s;
input         rready_axi_m_s;


input         clk0clk;
input         clk0resetn;




wire   [31:0]  araddr_axi_m;
wire   [1:0]   arburst_axi_m;
wire   [3:0]   arcache_axi_m;
wire           arid_axi_m;
wire   [7:0]   arlen_axi_m;
wire           arlock_axi_m;
wire   [2:0]   arprot_axi_m;
wire           arready_axi_m_s;
wire   [2:0]   arsize_axi_m;
wire           arvalid_axi_m;
wire   [31:0]  awaddr_axi_m;
wire   [1:0]   awburst_axi_m;
wire   [3:0]   awcache_axi_m;
wire           awid_axi_m;
wire   [7:0]   awlen_axi_m;
wire           awlock_axi_m;
wire   [2:0]   awprot_axi_m;
wire           awready_axi_m_s;
wire   [2:0]   awsize_axi_m;
wire           awvalid_axi_m;
wire           bid_axi_m_s;
wire           bready_axi_m;
wire   [1:0]   bresp_axi_m_s;
wire           bvalid_axi_m_s;
wire   [31:0]  rdata_axi_m_s;
wire           rid_axi_m_s;
wire           rlast_axi_m_s;
wire           rready_axi_m;
wire   [1:0]   rresp_axi_m_s;
wire           rvalid_axi_m_s;
wire   [63:0]  wdata_axi_m;
wire           wlast_axi_m;
wire           wready_axi_m_s;
wire   [7:0]   wstrb_axi_m;
wire           wvalid_axi_m;
wire           arready_axi_m_ib_axi_m_axi_m_s;
wire           awready_axi_m_ib_axi_m_axi_m_s;
wire           bid_axi_m_ib_axi_m_axi_m_s;
wire   [1:0]   bresp_axi_m_ib_axi_m_axi_m_s;
wire           bvalid_axi_m_ib_axi_m_axi_m_s;
wire   [63:0]  rdata_axi_m_ib_axi_m_axi_m_s;
wire           rid_axi_m_ib_axi_m_axi_m_s;
wire           rlast_axi_m_ib_axi_m_axi_m_s;
wire   [1:0]   rresp_axi_m_ib_axi_m_axi_m_s;
wire           rvalid_axi_m_ib_axi_m_axi_m_s;
wire           wready_axi_m_ib_axi_m_axi_m_s;
wire           ar_ready_axi_m_ib_int;
wire   [31:0]  araddr_axi_m_ib_axi_m_axi_m_s;
wire   [1:0]   arburst_axi_m_ib_axi_m_axi_m_s;
wire   [3:0]   arcache_axi_m_ib_axi_m_axi_m_s;
wire           arid_axi_m_ib_axi_m_axi_m_s;
wire   [7:0]   arlen_axi_m_ib_axi_m_axi_m_s;
wire           arlock_axi_m_ib_axi_m_axi_m_s;
wire   [2:0]   arprot_axi_m_ib_axi_m_axi_m_s;
wire   [2:0]   arsize_axi_m_ib_axi_m_axi_m_s;
wire           arvalid_axi_m_ib_axi_m_axi_m_s;
wire           aw_ready_axi_m_ib_int;
wire   [31:0]  awaddr_axi_m_ib_axi_m_axi_m_s;
wire   [1:0]   awburst_axi_m_ib_axi_m_axi_m_s;
wire   [3:0]   awcache_axi_m_ib_axi_m_axi_m_s;
wire           awid_axi_m_ib_axi_m_axi_m_s;
wire   [7:0]   awlen_axi_m_ib_axi_m_axi_m_s;
wire           awlock_axi_m_ib_axi_m_axi_m_s;
wire   [2:0]   awprot_axi_m_ib_axi_m_axi_m_s;
wire   [2:0]   awsize_axi_m_ib_axi_m_axi_m_s;
wire           awvalid_axi_m_ib_axi_m_axi_m_s;
wire   [2:0]   b_data_axi_m_ib_int;
wire           b_valid_axi_m_ib_int;
wire           bready_axi_m_ib_axi_m_axi_m_s;
wire   [67:0]  r_data_axi_m_ib_int;
wire           r_valid_axi_m_ib_int;
wire           rready_axi_m_ib_axi_m_axi_m_s;
wire           w_ready_axi_m_ib_int;
wire   [63:0]  wdata_axi_m_ib_axi_m_axi_m_s;
wire           wlast_axi_m_ib_axi_m_axi_m_s;
wire   [7:0]   wstrb_axi_m_ib_axi_m_axi_m_s;
wire           wvalid_axi_m_ib_axi_m_axi_m_s;
wire   [53:0]  ar_data_axi_m_ib_int;
wire           ar_valid_axi_m_ib_int;
wire   [53:0]  aw_data_axi_m_ib_int;
wire           aw_valid_axi_m_ib_int;
wire           b_ready_axi_m_ib_int;
wire           r_ready_axi_m_ib_int;
wire   [72:0]  w_data_axi_m_ib_int;
wire           w_valid_axi_m_ib_int;
wire   [31:0]  araddr_axi_m_s;
wire   [1:0]   arburst_axi_m_s;
wire   [3:0]   arcache_axi_m_s;
wire           arid_axi_m_s;
wire   [7:0]   arlen_axi_m_s;
wire           arlock_axi_m_s;
wire   [2:0]   arprot_axi_m_s;
wire           arready_axi_m;
wire   [2:0]   arsize_axi_m_s;
wire           arvalid_axi_m_s;
wire   [31:0]  awaddr_axi_m_s;
wire   [1:0]   awburst_axi_m_s;
wire   [3:0]   awcache_axi_m_s;
wire           awid_axi_m_s;
wire   [7:0]   awlen_axi_m_s;
wire           awlock_axi_m_s;
wire   [2:0]   awprot_axi_m_s;
wire           awready_axi_m;
wire   [2:0]   awsize_axi_m_s;
wire           awvalid_axi_m_s;
wire           bid_axi_m;
wire           bready_axi_m_s;
wire   [1:0]   bresp_axi_m;
wire           bvalid_axi_m;
wire           clk0clk;
wire           clk0resetn;
wire   [63:0]  rdata_axi_m;
wire           rid_axi_m;
wire           rlast_axi_m;
wire           rready_axi_m_s;
wire   [1:0]   rresp_axi_m;
wire           rvalid_axi_m;
wire   [31:0]  wdata_axi_m_s;
wire           wlast_axi_m_s;
wire           wready_axi_m;
wire   [3:0]   wstrb_axi_m_s;
wire           wvalid_axi_m_s;




nic400_amib_axi_m_sse710_integration_example_f0_upsizer     u_amib_axi_m (
  .awid_axi_m           (awid_axi_m),
  .awaddr_axi_m         (awaddr_axi_m),
  .awlen_axi_m          (awlen_axi_m),
  .awsize_axi_m         (awsize_axi_m),
  .awburst_axi_m        (awburst_axi_m),
  .awlock_axi_m         (awlock_axi_m),
  .awcache_axi_m        (awcache_axi_m),
  .awprot_axi_m         (awprot_axi_m),
  .awvalid_axi_m        (awvalid_axi_m),
  .awready_axi_m        (awready_axi_m),
  .wdata_axi_m          (wdata_axi_m),
  .wstrb_axi_m          (wstrb_axi_m),
  .wlast_axi_m          (wlast_axi_m),
  .wvalid_axi_m         (wvalid_axi_m),
  .wready_axi_m         (wready_axi_m),
  .bid_axi_m            (bid_axi_m),
  .bresp_axi_m          (bresp_axi_m),
  .bvalid_axi_m         (bvalid_axi_m),
  .bready_axi_m         (bready_axi_m),
  .arid_axi_m           (arid_axi_m),
  .araddr_axi_m         (araddr_axi_m),
  .arlen_axi_m          (arlen_axi_m),
  .arsize_axi_m         (arsize_axi_m),
  .arburst_axi_m        (arburst_axi_m),
  .arlock_axi_m         (arlock_axi_m),
  .arcache_axi_m        (arcache_axi_m),
  .arprot_axi_m         (arprot_axi_m),
  .arvalid_axi_m        (arvalid_axi_m),
  .arready_axi_m        (arready_axi_m),
  .rid_axi_m            (rid_axi_m),
  .rdata_axi_m          (rdata_axi_m),
  .rresp_axi_m          (rresp_axi_m),
  .rlast_axi_m          (rlast_axi_m),
  .rvalid_axi_m         (rvalid_axi_m),
  .rready_axi_m         (rready_axi_m),
  .awid_axi_m_s         (awid_axi_m_ib_axi_m_axi_m_s),
  .awaddr_axi_m_s       (awaddr_axi_m_ib_axi_m_axi_m_s),
  .awlen_axi_m_s        (awlen_axi_m_ib_axi_m_axi_m_s),
  .awsize_axi_m_s       (awsize_axi_m_ib_axi_m_axi_m_s),
  .awburst_axi_m_s      (awburst_axi_m_ib_axi_m_axi_m_s),
  .awlock_axi_m_s       (awlock_axi_m_ib_axi_m_axi_m_s),
  .awcache_axi_m_s      (awcache_axi_m_ib_axi_m_axi_m_s),
  .awprot_axi_m_s       (awprot_axi_m_ib_axi_m_axi_m_s),
  .awvalid_axi_m_s      (awvalid_axi_m_ib_axi_m_axi_m_s),
  .awready_axi_m_s      (awready_axi_m_ib_axi_m_axi_m_s),
  .wdata_axi_m_s        (wdata_axi_m_ib_axi_m_axi_m_s),
  .wstrb_axi_m_s        (wstrb_axi_m_ib_axi_m_axi_m_s),
  .wlast_axi_m_s        (wlast_axi_m_ib_axi_m_axi_m_s),
  .wvalid_axi_m_s       (wvalid_axi_m_ib_axi_m_axi_m_s),
  .wready_axi_m_s       (wready_axi_m_ib_axi_m_axi_m_s),
  .bid_axi_m_s          (bid_axi_m_ib_axi_m_axi_m_s),
  .bresp_axi_m_s        (bresp_axi_m_ib_axi_m_axi_m_s),
  .bvalid_axi_m_s       (bvalid_axi_m_ib_axi_m_axi_m_s),
  .bready_axi_m_s       (bready_axi_m_ib_axi_m_axi_m_s),
  .arid_axi_m_s         (arid_axi_m_ib_axi_m_axi_m_s),
  .araddr_axi_m_s       (araddr_axi_m_ib_axi_m_axi_m_s),
  .arlen_axi_m_s        (arlen_axi_m_ib_axi_m_axi_m_s),
  .arsize_axi_m_s       (arsize_axi_m_ib_axi_m_axi_m_s),
  .arburst_axi_m_s      (arburst_axi_m_ib_axi_m_axi_m_s),
  .arlock_axi_m_s       (arlock_axi_m_ib_axi_m_axi_m_s),
  .arcache_axi_m_s      (arcache_axi_m_ib_axi_m_axi_m_s),
  .arprot_axi_m_s       (arprot_axi_m_ib_axi_m_axi_m_s),
  .arvalid_axi_m_s      (arvalid_axi_m_ib_axi_m_axi_m_s),
  .arready_axi_m_s      (arready_axi_m_ib_axi_m_axi_m_s),
  .rid_axi_m_s          (rid_axi_m_ib_axi_m_axi_m_s),
  .rdata_axi_m_s        (rdata_axi_m_ib_axi_m_axi_m_s),
  .rresp_axi_m_s        (rresp_axi_m_ib_axi_m_axi_m_s),
  .rlast_axi_m_s        (rlast_axi_m_ib_axi_m_axi_m_s),
  .rvalid_axi_m_s       (rvalid_axi_m_ib_axi_m_axi_m_s),
  .rready_axi_m_s       (rready_axi_m_ib_axi_m_axi_m_s),
  .aclk                 (clk0clk),
  .aresetn              (clk0resetn)
);


nic400_ib_axi_m_ib_master_domain_sse710_integration_example_f0_upsizer     u_ib_axi_m_ib_m (
  .awid_axi4_m          (awid_axi_m_ib_axi_m_axi_m_s),
  .awaddr_axi4_m        (awaddr_axi_m_ib_axi_m_axi_m_s),
  .awlen_axi4_m         (awlen_axi_m_ib_axi_m_axi_m_s),
  .awsize_axi4_m        (awsize_axi_m_ib_axi_m_axi_m_s),
  .awburst_axi4_m       (awburst_axi_m_ib_axi_m_axi_m_s),
  .awlock_axi4_m        (awlock_axi_m_ib_axi_m_axi_m_s),
  .awcache_axi4_m       (awcache_axi_m_ib_axi_m_axi_m_s),
  .awprot_axi4_m        (awprot_axi_m_ib_axi_m_axi_m_s),
  .awvalid_axi4_m       (awvalid_axi_m_ib_axi_m_axi_m_s),
  .awready_axi4_m       (awready_axi_m_ib_axi_m_axi_m_s),
  .wdata_axi4_m         (wdata_axi_m_ib_axi_m_axi_m_s),
  .wstrb_axi4_m         (wstrb_axi_m_ib_axi_m_axi_m_s),
  .wlast_axi4_m         (wlast_axi_m_ib_axi_m_axi_m_s),
  .wvalid_axi4_m        (wvalid_axi_m_ib_axi_m_axi_m_s),
  .wready_axi4_m        (wready_axi_m_ib_axi_m_axi_m_s),
  .bid_axi4_m           (bid_axi_m_ib_axi_m_axi_m_s),
  .bresp_axi4_m         (bresp_axi_m_ib_axi_m_axi_m_s),
  .bvalid_axi4_m        (bvalid_axi_m_ib_axi_m_axi_m_s),
  .bready_axi4_m        (bready_axi_m_ib_axi_m_axi_m_s),
  .arid_axi4_m          (arid_axi_m_ib_axi_m_axi_m_s),
  .araddr_axi4_m        (araddr_axi_m_ib_axi_m_axi_m_s),
  .arlen_axi4_m         (arlen_axi_m_ib_axi_m_axi_m_s),
  .arsize_axi4_m        (arsize_axi_m_ib_axi_m_axi_m_s),
  .arburst_axi4_m       (arburst_axi_m_ib_axi_m_axi_m_s),
  .arlock_axi4_m        (arlock_axi_m_ib_axi_m_axi_m_s),
  .arcache_axi4_m       (arcache_axi_m_ib_axi_m_axi_m_s),
  .arprot_axi4_m        (arprot_axi_m_ib_axi_m_axi_m_s),
  .arvalid_axi4_m       (arvalid_axi_m_ib_axi_m_axi_m_s),
  .arready_axi4_m       (arready_axi_m_ib_axi_m_axi_m_s),
  .rid_axi4_m           (rid_axi_m_ib_axi_m_axi_m_s),
  .rdata_axi4_m         (rdata_axi_m_ib_axi_m_axi_m_s),
  .rresp_axi4_m         (rresp_axi_m_ib_axi_m_axi_m_s),
  .rlast_axi4_m         (rlast_axi_m_ib_axi_m_axi_m_s),
  .rvalid_axi4_m        (rvalid_axi_m_ib_axi_m_axi_m_s),
  .rready_axi4_m        (rready_axi_m_ib_axi_m_axi_m_s),
  .aclk                 (clk0clk),
  .aresetn              (clk0resetn),
  .aw_data              (aw_data_axi_m_ib_int),
  .aw_valid             (aw_valid_axi_m_ib_int),
  .aw_ready             (aw_ready_axi_m_ib_int),
  .b_data               (b_data_axi_m_ib_int),
  .b_valid              (b_valid_axi_m_ib_int),
  .b_ready              (b_ready_axi_m_ib_int),
  .ar_data              (ar_data_axi_m_ib_int),
  .ar_valid             (ar_valid_axi_m_ib_int),
  .ar_ready             (ar_ready_axi_m_ib_int),
  .r_data               (r_data_axi_m_ib_int),
  .r_valid              (r_valid_axi_m_ib_int),
  .r_ready              (r_ready_axi_m_ib_int),
  .w_data               (w_data_axi_m_ib_int),
  .w_valid              (w_valid_axi_m_ib_int),
  .w_ready              (w_ready_axi_m_ib_int)
);


nic400_ib_axi_m_ib_slave_domain_sse710_integration_example_f0_upsizer     u_ib_axi_m_ib_s (
  .awid_axi4_s          (awid_axi_m_s),
  .awaddr_axi4_s        (awaddr_axi_m_s),
  .awlen_axi4_s         (awlen_axi_m_s),
  .awsize_axi4_s        (awsize_axi_m_s),
  .awburst_axi4_s       (awburst_axi_m_s),
  .awlock_axi4_s        (awlock_axi_m_s),
  .awcache_axi4_s       (awcache_axi_m_s),
  .awprot_axi4_s        (awprot_axi_m_s),
  .awvalid_axi4_s       (awvalid_axi_m_s),
  .awready_axi4_s       (awready_axi_m_s),
  .wdata_axi4_s         (wdata_axi_m_s),
  .wstrb_axi4_s         (wstrb_axi_m_s),
  .wlast_axi4_s         (wlast_axi_m_s),
  .wvalid_axi4_s        (wvalid_axi_m_s),
  .wready_axi4_s        (wready_axi_m_s),
  .bid_axi4_s           (bid_axi_m_s),
  .bresp_axi4_s         (bresp_axi_m_s),
  .bvalid_axi4_s        (bvalid_axi_m_s),
  .bready_axi4_s        (bready_axi_m_s),
  .arid_axi4_s          (arid_axi_m_s),
  .araddr_axi4_s        (araddr_axi_m_s),
  .arlen_axi4_s         (arlen_axi_m_s),
  .arsize_axi4_s        (arsize_axi_m_s),
  .arburst_axi4_s       (arburst_axi_m_s),
  .arlock_axi4_s        (arlock_axi_m_s),
  .arcache_axi4_s       (arcache_axi_m_s),
  .arprot_axi4_s        (arprot_axi_m_s),
  .arvalid_axi4_s       (arvalid_axi_m_s),
  .arready_axi4_s       (arready_axi_m_s),
  .rid_axi4_s           (rid_axi_m_s),
  .rdata_axi4_s         (rdata_axi_m_s),
  .rresp_axi4_s         (rresp_axi_m_s),
  .rlast_axi4_s         (rlast_axi_m_s),
  .rvalid_axi4_s        (rvalid_axi_m_s),
  .rready_axi4_s        (rready_axi_m_s),
  .aclk                 (clk0clk),
  .aresetn              (clk0resetn),
  .aw_data              (aw_data_axi_m_ib_int),
  .aw_valid             (aw_valid_axi_m_ib_int),
  .aw_ready             (aw_ready_axi_m_ib_int),
  .b_data               (b_data_axi_m_ib_int),
  .b_valid              (b_valid_axi_m_ib_int),
  .b_ready              (b_ready_axi_m_ib_int),
  .ar_data              (ar_data_axi_m_ib_int),
  .ar_valid             (ar_valid_axi_m_ib_int),
  .ar_ready             (ar_ready_axi_m_ib_int),
  .r_data               (r_data_axi_m_ib_int),
  .r_valid              (r_valid_axi_m_ib_int),
  .r_ready              (r_ready_axi_m_ib_int),
  .w_data               (w_data_axi_m_ib_int),
  .w_valid              (w_valid_axi_m_ib_int),
  .w_ready              (w_ready_axi_m_ib_int)
);



endmodule
