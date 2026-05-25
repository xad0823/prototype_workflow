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




module nic400_sse710_integration_example_f0_cvm (
  

  AWID_cvm_master_if,
  AWADDR_cvm_master_if,
  AWLEN_cvm_master_if,
  AWSIZE_cvm_master_if,
  AWBURST_cvm_master_if,
  AWLOCK_cvm_master_if,
  AWCACHE_cvm_master_if,
  AWPROT_cvm_master_if,
  AWVALID_cvm_master_if,
  AWREADY_cvm_master_if,
  WDATA_cvm_master_if,
  WSTRB_cvm_master_if,
  WLAST_cvm_master_if,
  WVALID_cvm_master_if,
  WREADY_cvm_master_if,
  BID_cvm_master_if,
  BRESP_cvm_master_if,
  BVALID_cvm_master_if,
  BREADY_cvm_master_if,
  ARID_cvm_master_if,
  ARADDR_cvm_master_if,
  ARLEN_cvm_master_if,
  ARSIZE_cvm_master_if,
  ARBURST_cvm_master_if,
  ARLOCK_cvm_master_if,
  ARCACHE_cvm_master_if,
  ARPROT_cvm_master_if,
  ARVALID_cvm_master_if,
  ARREADY_cvm_master_if,
  RID_cvm_master_if,
  RDATA_cvm_master_if,
  RRESP_cvm_master_if,
  RLAST_cvm_master_if,
  RVALID_cvm_master_if,
  RREADY_cvm_master_if,
  

  AWID_cvm_slave_if,
  AWADDR_cvm_slave_if,
  AWLEN_cvm_slave_if,
  AWSIZE_cvm_slave_if,
  AWBURST_cvm_slave_if,
  AWLOCK_cvm_slave_if,
  AWCACHE_cvm_slave_if,
  AWPROT_cvm_slave_if,
  AWVALID_cvm_slave_if,
  AWREADY_cvm_slave_if,
  WDATA_cvm_slave_if,
  WSTRB_cvm_slave_if,
  WLAST_cvm_slave_if,
  WVALID_cvm_slave_if,
  WREADY_cvm_slave_if,
  BID_cvm_slave_if,
  BRESP_cvm_slave_if,
  BVALID_cvm_slave_if,
  BREADY_cvm_slave_if,
  ARID_cvm_slave_if,
  ARADDR_cvm_slave_if,
  ARLEN_cvm_slave_if,
  ARSIZE_cvm_slave_if,
  ARBURST_cvm_slave_if,
  ARLOCK_cvm_slave_if,
  ARCACHE_cvm_slave_if,
  ARPROT_cvm_slave_if,
  ARVALID_cvm_slave_if,
  ARREADY_cvm_slave_if,
  RID_cvm_slave_if,
  RDATA_cvm_slave_if,
  RRESP_cvm_slave_if,
  RLAST_cvm_slave_if,
  RVALID_cvm_slave_if,
  RREADY_cvm_slave_if,


  aclkoutclk,
  aclkoutresetn

);






output [11:0] AWID_cvm_master_if;
output [31:0] AWADDR_cvm_master_if;
output [7:0]  AWLEN_cvm_master_if;
output [2:0]  AWSIZE_cvm_master_if;
output [1:0]  AWBURST_cvm_master_if;
output        AWLOCK_cvm_master_if;
output [3:0]  AWCACHE_cvm_master_if;
output [2:0]  AWPROT_cvm_master_if;
output        AWVALID_cvm_master_if;
input         AWREADY_cvm_master_if;
output [63:0] WDATA_cvm_master_if;
output [7:0]  WSTRB_cvm_master_if;
output        WLAST_cvm_master_if;
output        WVALID_cvm_master_if;
input         WREADY_cvm_master_if;
input  [11:0] BID_cvm_master_if;
input  [1:0]  BRESP_cvm_master_if;
input         BVALID_cvm_master_if;
output        BREADY_cvm_master_if;
output [11:0] ARID_cvm_master_if;
output [31:0] ARADDR_cvm_master_if;
output [7:0]  ARLEN_cvm_master_if;
output [2:0]  ARSIZE_cvm_master_if;
output [1:0]  ARBURST_cvm_master_if;
output        ARLOCK_cvm_master_if;
output [3:0]  ARCACHE_cvm_master_if;
output [2:0]  ARPROT_cvm_master_if;
output        ARVALID_cvm_master_if;
input         ARREADY_cvm_master_if;
input  [11:0] RID_cvm_master_if;
input  [63:0] RDATA_cvm_master_if;
input  [1:0]  RRESP_cvm_master_if;
input         RLAST_cvm_master_if;
input         RVALID_cvm_master_if;
output        RREADY_cvm_master_if;


input  [11:0] AWID_cvm_slave_if;
input  [31:0] AWADDR_cvm_slave_if;
input  [7:0]  AWLEN_cvm_slave_if;
input  [2:0]  AWSIZE_cvm_slave_if;
input  [1:0]  AWBURST_cvm_slave_if;
input         AWLOCK_cvm_slave_if;
input  [3:0]  AWCACHE_cvm_slave_if;
input  [2:0]  AWPROT_cvm_slave_if;
input         AWVALID_cvm_slave_if;
output        AWREADY_cvm_slave_if;
input  [63:0] WDATA_cvm_slave_if;
input  [7:0]  WSTRB_cvm_slave_if;
input         WLAST_cvm_slave_if;
input         WVALID_cvm_slave_if;
output        WREADY_cvm_slave_if;
output [11:0] BID_cvm_slave_if;
output [1:0]  BRESP_cvm_slave_if;
output        BVALID_cvm_slave_if;
input         BREADY_cvm_slave_if;
input  [11:0] ARID_cvm_slave_if;
input  [31:0] ARADDR_cvm_slave_if;
input  [7:0]  ARLEN_cvm_slave_if;
input  [2:0]  ARSIZE_cvm_slave_if;
input  [1:0]  ARBURST_cvm_slave_if;
input         ARLOCK_cvm_slave_if;
input  [3:0]  ARCACHE_cvm_slave_if;
input  [2:0]  ARPROT_cvm_slave_if;
input         ARVALID_cvm_slave_if;
output        ARREADY_cvm_slave_if;
output [11:0] RID_cvm_slave_if;
output [63:0] RDATA_cvm_slave_if;
output [1:0]  RRESP_cvm_slave_if;
output        RLAST_cvm_slave_if;
output        RVALID_cvm_slave_if;
input         RREADY_cvm_slave_if;


input         aclkoutclk;
input         aclkoutresetn;




wire   [31:0]  ARADDR_cvm_master_if;
wire   [1:0]   ARBURST_cvm_master_if;
wire   [3:0]   ARCACHE_cvm_master_if;
wire   [11:0]  ARID_cvm_master_if;
wire   [7:0]   ARLEN_cvm_master_if;
wire           ARLOCK_cvm_master_if;
wire   [2:0]   ARPROT_cvm_master_if;
wire           ARREADY_cvm_slave_if;
wire   [2:0]   ARSIZE_cvm_master_if;
wire           ARVALID_cvm_master_if;
wire   [31:0]  AWADDR_cvm_master_if;
wire   [1:0]   AWBURST_cvm_master_if;
wire   [3:0]   AWCACHE_cvm_master_if;
wire   [11:0]  AWID_cvm_master_if;
wire   [7:0]   AWLEN_cvm_master_if;
wire           AWLOCK_cvm_master_if;
wire   [2:0]   AWPROT_cvm_master_if;
wire           AWREADY_cvm_slave_if;
wire   [2:0]   AWSIZE_cvm_master_if;
wire           AWVALID_cvm_master_if;
wire   [11:0]  BID_cvm_slave_if;
wire           BREADY_cvm_master_if;
wire   [1:0]   BRESP_cvm_slave_if;
wire           BVALID_cvm_slave_if;
wire   [63:0]  RDATA_cvm_slave_if;
wire   [11:0]  RID_cvm_slave_if;
wire           RLAST_cvm_slave_if;
wire           RREADY_cvm_master_if;
wire   [1:0]   RRESP_cvm_slave_if;
wire           RVALID_cvm_slave_if;
wire   [63:0]  WDATA_cvm_master_if;
wire           WLAST_cvm_master_if;
wire           WREADY_cvm_slave_if;
wire   [7:0]   WSTRB_cvm_master_if;
wire           WVALID_cvm_master_if;
wire           arready_bm0_cvm_master_if_cvm_master_if_s;
wire           awready_bm0_cvm_master_if_cvm_master_if_s;
wire   [11:0]  bid_bm0_cvm_master_if_cvm_master_if_s;
wire   [1:0]   bresp_bm0_cvm_master_if_cvm_master_if_s;
wire           bvalid_bm0_cvm_master_if_cvm_master_if_s;
wire   [63:0]  rdata_bm0_cvm_master_if_cvm_master_if_s;
wire   [11:0]  rid_bm0_cvm_master_if_cvm_master_if_s;
wire           rlast_bm0_cvm_master_if_cvm_master_if_s;
wire   [1:0]   rresp_bm0_cvm_master_if_cvm_master_if_s;
wire           rvalid_bm0_cvm_master_if_cvm_master_if_s;
wire           wready_bm0_cvm_master_if_cvm_master_if_s;
wire   [31:0]  araddr_cvm_slave_if_bm0_axi_s_0;
wire   [1:0]   arburst_cvm_slave_if_bm0_axi_s_0;
wire   [3:0]   arcache_cvm_slave_if_bm0_axi_s_0;
wire   [11:0]  arid_cvm_slave_if_bm0_axi_s_0;
wire   [7:0]   arlen_cvm_slave_if_bm0_axi_s_0;
wire           arlock_cvm_slave_if_bm0_axi_s_0;
wire   [2:0]   arprot_cvm_slave_if_bm0_axi_s_0;
wire   [3:0]   arqv_cvm_slave_if_bm0_axi_s_0;
wire   [2:0]   arsize_cvm_slave_if_bm0_axi_s_0;
wire           arvalid_cvm_slave_if_bm0_axi_s_0;
wire   [1:0]   arvalid_vect_cvm_slave_if_bm0_axi_s_0;
wire   [31:0]  awaddr_cvm_slave_if_bm0_axi_s_0;
wire   [1:0]   awburst_cvm_slave_if_bm0_axi_s_0;
wire   [3:0]   awcache_cvm_slave_if_bm0_axi_s_0;
wire   [11:0]  awid_cvm_slave_if_bm0_axi_s_0;
wire   [7:0]   awlen_cvm_slave_if_bm0_axi_s_0;
wire           awlock_cvm_slave_if_bm0_axi_s_0;
wire   [2:0]   awprot_cvm_slave_if_bm0_axi_s_0;
wire   [3:0]   awqv_cvm_slave_if_bm0_axi_s_0;
wire   [2:0]   awsize_cvm_slave_if_bm0_axi_s_0;
wire           awvalid_cvm_slave_if_bm0_axi_s_0;
wire   [1:0]   awvalid_vect_cvm_slave_if_bm0_axi_s_0;
wire           bready_cvm_slave_if_bm0_axi_s_0;
wire           rready_cvm_slave_if_bm0_axi_s_0;
wire   [63:0]  wdata_cvm_slave_if_bm0_axi_s_0;
wire           wlast_cvm_slave_if_bm0_axi_s_0;
wire   [7:0]   wstrb_cvm_slave_if_bm0_axi_s_0;
wire           wvalid_cvm_slave_if_bm0_axi_s_0;
wire   [31:0]  araddr_bm0_cvm_master_if_cvm_master_if_s;
wire   [1:0]   arburst_bm0_cvm_master_if_cvm_master_if_s;
wire   [3:0]   arcache_bm0_cvm_master_if_cvm_master_if_s;
wire   [11:0]  arid_bm0_cvm_master_if_cvm_master_if_s;
wire   [11:0]  arid_bm0_ds_1_axi_s_0;
wire   [7:0]   arlen_bm0_cvm_master_if_cvm_master_if_s;
wire   [7:0]   arlen_bm0_ds_1_axi_s_0;
wire           arlock_bm0_cvm_master_if_cvm_master_if_s;
wire   [2:0]   arprot_bm0_cvm_master_if_cvm_master_if_s;
wire           arready_cvm_slave_if_bm0_axi_s_0;
wire   [2:0]   arsize_bm0_cvm_master_if_cvm_master_if_s;
wire           arvalid_bm0_cvm_master_if_cvm_master_if_s;
wire           arvalid_bm0_ds_1_axi_s_0;
wire   [31:0]  awaddr_bm0_cvm_master_if_cvm_master_if_s;
wire   [1:0]   awburst_bm0_cvm_master_if_cvm_master_if_s;
wire   [3:0]   awcache_bm0_cvm_master_if_cvm_master_if_s;
wire   [11:0]  awid_bm0_cvm_master_if_cvm_master_if_s;
wire   [11:0]  awid_bm0_ds_1_axi_s_0;
wire   [7:0]   awlen_bm0_cvm_master_if_cvm_master_if_s;
wire           awlock_bm0_cvm_master_if_cvm_master_if_s;
wire   [2:0]   awprot_bm0_cvm_master_if_cvm_master_if_s;
wire           awready_cvm_slave_if_bm0_axi_s_0;
wire   [2:0]   awsize_bm0_cvm_master_if_cvm_master_if_s;
wire           awvalid_bm0_cvm_master_if_cvm_master_if_s;
wire           awvalid_bm0_ds_1_axi_s_0;
wire   [11:0]  bid_cvm_slave_if_bm0_axi_s_0;
wire           bready_bm0_cvm_master_if_cvm_master_if_s;
wire           bready_bm0_ds_1_axi_s_0;
wire   [1:0]   bresp_cvm_slave_if_bm0_axi_s_0;
wire           bvalid_cvm_slave_if_bm0_axi_s_0;
wire   [63:0]  rdata_cvm_slave_if_bm0_axi_s_0;
wire   [11:0]  rid_cvm_slave_if_bm0_axi_s_0;
wire           rlast_cvm_slave_if_bm0_axi_s_0;
wire           rready_bm0_cvm_master_if_cvm_master_if_s;
wire           rready_bm0_ds_1_axi_s_0;
wire   [1:0]   rresp_cvm_slave_if_bm0_axi_s_0;
wire           rvalid_cvm_slave_if_bm0_axi_s_0;
wire   [63:0]  wdata_bm0_cvm_master_if_cvm_master_if_s;
wire           wlast_bm0_cvm_master_if_cvm_master_if_s;
wire           wlast_bm0_ds_1_axi_s_0;
wire           wready_cvm_slave_if_bm0_axi_s_0;
wire   [7:0]   wstrb_bm0_cvm_master_if_cvm_master_if_s;
wire           wvalid_bm0_cvm_master_if_cvm_master_if_s;
wire           wvalid_bm0_ds_1_axi_s_0;
wire           arready_bm0_ds_1_axi_s_0;
wire           awready_bm0_ds_1_axi_s_0;
wire   [11:0]  bid_bm0_ds_1_axi_s_0;
wire   [1:0]   bresp_bm0_ds_1_axi_s_0;
wire           bvalid_bm0_ds_1_axi_s_0;
wire   [11:0]  rid_bm0_ds_1_axi_s_0;
wire           rlast_bm0_ds_1_axi_s_0;
wire   [1:0]   rresp_bm0_ds_1_axi_s_0;
wire           rvalid_bm0_ds_1_axi_s_0;
wire           wready_bm0_ds_1_axi_s_0;
wire   [31:0]  ARADDR_cvm_slave_if;
wire   [1:0]   ARBURST_cvm_slave_if;
wire   [3:0]   ARCACHE_cvm_slave_if;
wire   [11:0]  ARID_cvm_slave_if;
wire   [7:0]   ARLEN_cvm_slave_if;
wire           ARLOCK_cvm_slave_if;
wire   [2:0]   ARPROT_cvm_slave_if;
wire           ARREADY_cvm_master_if;
wire   [2:0]   ARSIZE_cvm_slave_if;
wire           ARVALID_cvm_slave_if;
wire   [31:0]  AWADDR_cvm_slave_if;
wire   [1:0]   AWBURST_cvm_slave_if;
wire   [3:0]   AWCACHE_cvm_slave_if;
wire   [11:0]  AWID_cvm_slave_if;
wire   [7:0]   AWLEN_cvm_slave_if;
wire           AWLOCK_cvm_slave_if;
wire   [2:0]   AWPROT_cvm_slave_if;
wire           AWREADY_cvm_master_if;
wire   [2:0]   AWSIZE_cvm_slave_if;
wire           AWVALID_cvm_slave_if;
wire   [11:0]  BID_cvm_master_if;
wire           BREADY_cvm_slave_if;
wire   [1:0]   BRESP_cvm_master_if;
wire           BVALID_cvm_master_if;
wire   [63:0]  RDATA_cvm_master_if;
wire   [11:0]  RID_cvm_master_if;
wire           RLAST_cvm_master_if;
wire           RREADY_cvm_slave_if;
wire   [1:0]   RRESP_cvm_master_if;
wire           RVALID_cvm_master_if;
wire   [63:0]  WDATA_cvm_slave_if;
wire           WLAST_cvm_slave_if;
wire           WREADY_cvm_master_if;
wire   [7:0]   WSTRB_cvm_slave_if;
wire           WVALID_cvm_slave_if;
wire           aclkoutclk;
wire           aclkoutresetn;




nic400_amib_cvm_master_if_sse710_integration_example_f0_cvm     u_amib_cvm_master_if (
  .awid_cvm_master_if_m (AWID_cvm_master_if),
  .awaddr_cvm_master_if_m (AWADDR_cvm_master_if),
  .awlen_cvm_master_if_m (AWLEN_cvm_master_if),
  .awsize_cvm_master_if_m (AWSIZE_cvm_master_if),
  .awburst_cvm_master_if_m (AWBURST_cvm_master_if),
  .awlock_cvm_master_if_m (AWLOCK_cvm_master_if),
  .awcache_cvm_master_if_m (AWCACHE_cvm_master_if),
  .awprot_cvm_master_if_m (AWPROT_cvm_master_if),
  .awvalid_cvm_master_if_m (AWVALID_cvm_master_if),
  .awready_cvm_master_if_m (AWREADY_cvm_master_if),
  .wdata_cvm_master_if_m (WDATA_cvm_master_if),
  .wstrb_cvm_master_if_m (WSTRB_cvm_master_if),
  .wlast_cvm_master_if_m (WLAST_cvm_master_if),
  .wvalid_cvm_master_if_m (WVALID_cvm_master_if),
  .wready_cvm_master_if_m (WREADY_cvm_master_if),
  .bid_cvm_master_if_m  (BID_cvm_master_if),
  .bresp_cvm_master_if_m (BRESP_cvm_master_if),
  .bvalid_cvm_master_if_m (BVALID_cvm_master_if),
  .bready_cvm_master_if_m (BREADY_cvm_master_if),
  .arid_cvm_master_if_m (ARID_cvm_master_if),
  .araddr_cvm_master_if_m (ARADDR_cvm_master_if),
  .arlen_cvm_master_if_m (ARLEN_cvm_master_if),
  .arsize_cvm_master_if_m (ARSIZE_cvm_master_if),
  .arburst_cvm_master_if_m (ARBURST_cvm_master_if),
  .arlock_cvm_master_if_m (ARLOCK_cvm_master_if),
  .arcache_cvm_master_if_m (ARCACHE_cvm_master_if),
  .arprot_cvm_master_if_m (ARPROT_cvm_master_if),
  .arvalid_cvm_master_if_m (ARVALID_cvm_master_if),
  .arready_cvm_master_if_m (ARREADY_cvm_master_if),
  .rid_cvm_master_if_m  (RID_cvm_master_if),
  .rdata_cvm_master_if_m (RDATA_cvm_master_if),
  .rresp_cvm_master_if_m (RRESP_cvm_master_if),
  .rlast_cvm_master_if_m (RLAST_cvm_master_if),
  .rvalid_cvm_master_if_m (RVALID_cvm_master_if),
  .rready_cvm_master_if_m (RREADY_cvm_master_if),
  .awid_cvm_master_if_s (awid_bm0_cvm_master_if_cvm_master_if_s),
  .awaddr_cvm_master_if_s (awaddr_bm0_cvm_master_if_cvm_master_if_s),
  .awlen_cvm_master_if_s (awlen_bm0_cvm_master_if_cvm_master_if_s),
  .awsize_cvm_master_if_s (awsize_bm0_cvm_master_if_cvm_master_if_s),
  .awburst_cvm_master_if_s (awburst_bm0_cvm_master_if_cvm_master_if_s),
  .awlock_cvm_master_if_s (awlock_bm0_cvm_master_if_cvm_master_if_s),
  .awcache_cvm_master_if_s (awcache_bm0_cvm_master_if_cvm_master_if_s),
  .awprot_cvm_master_if_s (awprot_bm0_cvm_master_if_cvm_master_if_s),
  .awvalid_cvm_master_if_s (awvalid_bm0_cvm_master_if_cvm_master_if_s),
  .awready_cvm_master_if_s (awready_bm0_cvm_master_if_cvm_master_if_s),
  .wdata_cvm_master_if_s (wdata_bm0_cvm_master_if_cvm_master_if_s),
  .wstrb_cvm_master_if_s (wstrb_bm0_cvm_master_if_cvm_master_if_s),
  .wlast_cvm_master_if_s (wlast_bm0_cvm_master_if_cvm_master_if_s),
  .wvalid_cvm_master_if_s (wvalid_bm0_cvm_master_if_cvm_master_if_s),
  .wready_cvm_master_if_s (wready_bm0_cvm_master_if_cvm_master_if_s),
  .bid_cvm_master_if_s  (bid_bm0_cvm_master_if_cvm_master_if_s),
  .bresp_cvm_master_if_s (bresp_bm0_cvm_master_if_cvm_master_if_s),
  .bvalid_cvm_master_if_s (bvalid_bm0_cvm_master_if_cvm_master_if_s),
  .bready_cvm_master_if_s (bready_bm0_cvm_master_if_cvm_master_if_s),
  .arid_cvm_master_if_s (arid_bm0_cvm_master_if_cvm_master_if_s),
  .araddr_cvm_master_if_s (araddr_bm0_cvm_master_if_cvm_master_if_s),
  .arlen_cvm_master_if_s (arlen_bm0_cvm_master_if_cvm_master_if_s),
  .arsize_cvm_master_if_s (arsize_bm0_cvm_master_if_cvm_master_if_s),
  .arburst_cvm_master_if_s (arburst_bm0_cvm_master_if_cvm_master_if_s),
  .arlock_cvm_master_if_s (arlock_bm0_cvm_master_if_cvm_master_if_s),
  .arcache_cvm_master_if_s (arcache_bm0_cvm_master_if_cvm_master_if_s),
  .arprot_cvm_master_if_s (arprot_bm0_cvm_master_if_cvm_master_if_s),
  .arvalid_cvm_master_if_s (arvalid_bm0_cvm_master_if_cvm_master_if_s),
  .arready_cvm_master_if_s (arready_bm0_cvm_master_if_cvm_master_if_s),
  .rid_cvm_master_if_s  (rid_bm0_cvm_master_if_cvm_master_if_s),
  .rdata_cvm_master_if_s (rdata_bm0_cvm_master_if_cvm_master_if_s),
  .rresp_cvm_master_if_s (rresp_bm0_cvm_master_if_cvm_master_if_s),
  .rlast_cvm_master_if_s (rlast_bm0_cvm_master_if_cvm_master_if_s),
  .rvalid_cvm_master_if_s (rvalid_bm0_cvm_master_if_cvm_master_if_s),
  .rready_cvm_master_if_s (rready_bm0_cvm_master_if_cvm_master_if_s),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn)
);


nic400_asib_cvm_slave_if_sse710_integration_example_f0_cvm     u_asib_cvm_slave_if (
  .awid_cvm_slave_if_m  (awid_cvm_slave_if_bm0_axi_s_0),
  .awaddr_cvm_slave_if_m (awaddr_cvm_slave_if_bm0_axi_s_0),
  .awlen_cvm_slave_if_m (awlen_cvm_slave_if_bm0_axi_s_0),
  .awsize_cvm_slave_if_m (awsize_cvm_slave_if_bm0_axi_s_0),
  .awburst_cvm_slave_if_m (awburst_cvm_slave_if_bm0_axi_s_0),
  .awlock_cvm_slave_if_m (awlock_cvm_slave_if_bm0_axi_s_0),
  .awcache_cvm_slave_if_m (awcache_cvm_slave_if_bm0_axi_s_0),
  .awprot_cvm_slave_if_m (awprot_cvm_slave_if_bm0_axi_s_0),
  .awvalid_cvm_slave_if_m (awvalid_cvm_slave_if_bm0_axi_s_0),
  .awvalid_vect_cvm_slave_if_m (awvalid_vect_cvm_slave_if_bm0_axi_s_0),
  .awready_cvm_slave_if_m (awready_cvm_slave_if_bm0_axi_s_0),
  .wdata_cvm_slave_if_m (wdata_cvm_slave_if_bm0_axi_s_0),
  .wstrb_cvm_slave_if_m (wstrb_cvm_slave_if_bm0_axi_s_0),
  .wlast_cvm_slave_if_m (wlast_cvm_slave_if_bm0_axi_s_0),
  .wvalid_cvm_slave_if_m (wvalid_cvm_slave_if_bm0_axi_s_0),
  .wready_cvm_slave_if_m (wready_cvm_slave_if_bm0_axi_s_0),
  .bid_cvm_slave_if_m   (bid_cvm_slave_if_bm0_axi_s_0),
  .bresp_cvm_slave_if_m (bresp_cvm_slave_if_bm0_axi_s_0),
  .bvalid_cvm_slave_if_m (bvalid_cvm_slave_if_bm0_axi_s_0),
  .bready_cvm_slave_if_m (bready_cvm_slave_if_bm0_axi_s_0),
  .arid_cvm_slave_if_m  (arid_cvm_slave_if_bm0_axi_s_0),
  .araddr_cvm_slave_if_m (araddr_cvm_slave_if_bm0_axi_s_0),
  .arlen_cvm_slave_if_m (arlen_cvm_slave_if_bm0_axi_s_0),
  .arsize_cvm_slave_if_m (arsize_cvm_slave_if_bm0_axi_s_0),
  .arburst_cvm_slave_if_m (arburst_cvm_slave_if_bm0_axi_s_0),
  .arlock_cvm_slave_if_m (arlock_cvm_slave_if_bm0_axi_s_0),
  .arcache_cvm_slave_if_m (arcache_cvm_slave_if_bm0_axi_s_0),
  .arprot_cvm_slave_if_m (arprot_cvm_slave_if_bm0_axi_s_0),
  .arvalid_cvm_slave_if_m (arvalid_cvm_slave_if_bm0_axi_s_0),
  .arvalid_vect_cvm_slave_if_m (arvalid_vect_cvm_slave_if_bm0_axi_s_0),
  .arready_cvm_slave_if_m (arready_cvm_slave_if_bm0_axi_s_0),
  .rid_cvm_slave_if_m   (rid_cvm_slave_if_bm0_axi_s_0),
  .rdata_cvm_slave_if_m (rdata_cvm_slave_if_bm0_axi_s_0),
  .rresp_cvm_slave_if_m (rresp_cvm_slave_if_bm0_axi_s_0),
  .rlast_cvm_slave_if_m (rlast_cvm_slave_if_bm0_axi_s_0),
  .rvalid_cvm_slave_if_m (rvalid_cvm_slave_if_bm0_axi_s_0),
  .rready_cvm_slave_if_m (rready_cvm_slave_if_bm0_axi_s_0),
  .awqv_cvm_slave_if_m  (awqv_cvm_slave_if_bm0_axi_s_0),
  .arqv_cvm_slave_if_m  (arqv_cvm_slave_if_bm0_axi_s_0),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn),
  .awid_cvm_slave_if_s  (AWID_cvm_slave_if),
  .awaddr_cvm_slave_if_s (AWADDR_cvm_slave_if),
  .awlen_cvm_slave_if_s (AWLEN_cvm_slave_if),
  .awsize_cvm_slave_if_s (AWSIZE_cvm_slave_if),
  .awburst_cvm_slave_if_s (AWBURST_cvm_slave_if),
  .awlock_cvm_slave_if_s (AWLOCK_cvm_slave_if),
  .awcache_cvm_slave_if_s (AWCACHE_cvm_slave_if),
  .awprot_cvm_slave_if_s (AWPROT_cvm_slave_if),
  .awvalid_cvm_slave_if_s (AWVALID_cvm_slave_if),
  .awready_cvm_slave_if_s (AWREADY_cvm_slave_if),
  .wdata_cvm_slave_if_s (WDATA_cvm_slave_if),
  .wstrb_cvm_slave_if_s (WSTRB_cvm_slave_if),
  .wlast_cvm_slave_if_s (WLAST_cvm_slave_if),
  .wvalid_cvm_slave_if_s (WVALID_cvm_slave_if),
  .wready_cvm_slave_if_s (WREADY_cvm_slave_if),
  .bid_cvm_slave_if_s   (BID_cvm_slave_if),
  .bresp_cvm_slave_if_s (BRESP_cvm_slave_if),
  .bvalid_cvm_slave_if_s (BVALID_cvm_slave_if),
  .bready_cvm_slave_if_s (BREADY_cvm_slave_if),
  .arid_cvm_slave_if_s  (ARID_cvm_slave_if),
  .araddr_cvm_slave_if_s (ARADDR_cvm_slave_if),
  .arlen_cvm_slave_if_s (ARLEN_cvm_slave_if),
  .arsize_cvm_slave_if_s (ARSIZE_cvm_slave_if),
  .arburst_cvm_slave_if_s (ARBURST_cvm_slave_if),
  .arlock_cvm_slave_if_s (ARLOCK_cvm_slave_if),
  .arcache_cvm_slave_if_s (ARCACHE_cvm_slave_if),
  .arprot_cvm_slave_if_s (ARPROT_cvm_slave_if),
  .arvalid_cvm_slave_if_s (ARVALID_cvm_slave_if),
  .arready_cvm_slave_if_s (ARREADY_cvm_slave_if),
  .rid_cvm_slave_if_s   (RID_cvm_slave_if),
  .rdata_cvm_slave_if_s (RDATA_cvm_slave_if),
  .rresp_cvm_slave_if_s (RRESP_cvm_slave_if),
  .rlast_cvm_slave_if_s (RLAST_cvm_slave_if),
  .rvalid_cvm_slave_if_s (RVALID_cvm_slave_if),
  .rready_cvm_slave_if_s (RREADY_cvm_slave_if)
);


nic400_bm0_sse710_integration_example_f0_cvm     u_busmatrix_bm0 (
  .awid_axi_m_0         (awid_bm0_cvm_master_if_cvm_master_if_s),
  .awaddr_axi_m_0       (awaddr_bm0_cvm_master_if_cvm_master_if_s),
  .awlen_axi_m_0        (awlen_bm0_cvm_master_if_cvm_master_if_s),
  .awsize_axi_m_0       (awsize_bm0_cvm_master_if_cvm_master_if_s),
  .awburst_axi_m_0      (awburst_bm0_cvm_master_if_cvm_master_if_s),
  .awlock_axi_m_0       (awlock_bm0_cvm_master_if_cvm_master_if_s),
  .awcache_axi_m_0      (awcache_bm0_cvm_master_if_cvm_master_if_s),
  .awprot_axi_m_0       (awprot_bm0_cvm_master_if_cvm_master_if_s),
  .awvalid_axi_m_0      (awvalid_bm0_cvm_master_if_cvm_master_if_s),
  .awvalid_vect_axi_m_0 (),
  .awready_axi_m_0      (awready_bm0_cvm_master_if_cvm_master_if_s),
  .wdata_axi_m_0        (wdata_bm0_cvm_master_if_cvm_master_if_s),
  .wstrb_axi_m_0        (wstrb_bm0_cvm_master_if_cvm_master_if_s),
  .wlast_axi_m_0        (wlast_bm0_cvm_master_if_cvm_master_if_s),
  .wvalid_axi_m_0       (wvalid_bm0_cvm_master_if_cvm_master_if_s),
  .wready_axi_m_0       (wready_bm0_cvm_master_if_cvm_master_if_s),
  .bid_axi_m_0          (bid_bm0_cvm_master_if_cvm_master_if_s),
  .bresp_axi_m_0        (bresp_bm0_cvm_master_if_cvm_master_if_s),
  .bvalid_axi_m_0       (bvalid_bm0_cvm_master_if_cvm_master_if_s),
  .bready_axi_m_0       (bready_bm0_cvm_master_if_cvm_master_if_s),
  .arid_axi_m_0         (arid_bm0_cvm_master_if_cvm_master_if_s),
  .araddr_axi_m_0       (araddr_bm0_cvm_master_if_cvm_master_if_s),
  .arlen_axi_m_0        (arlen_bm0_cvm_master_if_cvm_master_if_s),
  .arsize_axi_m_0       (arsize_bm0_cvm_master_if_cvm_master_if_s),
  .arburst_axi_m_0      (arburst_bm0_cvm_master_if_cvm_master_if_s),
  .arlock_axi_m_0       (arlock_bm0_cvm_master_if_cvm_master_if_s),
  .arcache_axi_m_0      (arcache_bm0_cvm_master_if_cvm_master_if_s),
  .arprot_axi_m_0       (arprot_bm0_cvm_master_if_cvm_master_if_s),
  .arvalid_axi_m_0      (arvalid_bm0_cvm_master_if_cvm_master_if_s),
  .arvalid_vect_axi_m_0 (),
  .arready_axi_m_0      (arready_bm0_cvm_master_if_cvm_master_if_s),
  .rid_axi_m_0          (rid_bm0_cvm_master_if_cvm_master_if_s),
  .rdata_axi_m_0        (rdata_bm0_cvm_master_if_cvm_master_if_s),
  .rresp_axi_m_0        (rresp_bm0_cvm_master_if_cvm_master_if_s),
  .rlast_axi_m_0        (rlast_bm0_cvm_master_if_cvm_master_if_s),
  .rvalid_axi_m_0       (rvalid_bm0_cvm_master_if_cvm_master_if_s),
  .rready_axi_m_0       (rready_bm0_cvm_master_if_cvm_master_if_s),
  .aw_qv_axi_m_0        (),
  .ar_qv_axi_m_0        (),
  .awid_axi_m_1         (awid_bm0_ds_1_axi_s_0),
  .awaddr_axi_m_1       (),
  .awlen_axi_m_1        (),
  .awsize_axi_m_1       (),
  .awburst_axi_m_1      (),
  .awlock_axi_m_1       (),
  .awcache_axi_m_1      (),
  .awprot_axi_m_1       (),
  .awvalid_axi_m_1      (awvalid_bm0_ds_1_axi_s_0),
  .awvalid_vect_axi_m_1 (),
  .awready_axi_m_1      (awready_bm0_ds_1_axi_s_0),
  .wdata_axi_m_1        (),
  .wstrb_axi_m_1        (),
  .wlast_axi_m_1        (wlast_bm0_ds_1_axi_s_0),
  .wvalid_axi_m_1       (wvalid_bm0_ds_1_axi_s_0),
  .wready_axi_m_1       (wready_bm0_ds_1_axi_s_0),
  .bid_axi_m_1          (bid_bm0_ds_1_axi_s_0),
  .bresp_axi_m_1        (bresp_bm0_ds_1_axi_s_0),
  .bvalid_axi_m_1       (bvalid_bm0_ds_1_axi_s_0),
  .bready_axi_m_1       (bready_bm0_ds_1_axi_s_0),
  .arid_axi_m_1         (arid_bm0_ds_1_axi_s_0),
  .araddr_axi_m_1       (),
  .arlen_axi_m_1        (arlen_bm0_ds_1_axi_s_0),
  .arsize_axi_m_1       (),
  .arburst_axi_m_1      (),
  .arlock_axi_m_1       (),
  .arcache_axi_m_1      (),
  .arprot_axi_m_1       (),
  .arvalid_axi_m_1      (arvalid_bm0_ds_1_axi_s_0),
  .arvalid_vect_axi_m_1 (),
  .arready_axi_m_1      (arready_bm0_ds_1_axi_s_0),
  .rid_axi_m_1          (rid_bm0_ds_1_axi_s_0),
  .rdata_axi_m_1        (64'b0),
  .rresp_axi_m_1        (rresp_bm0_ds_1_axi_s_0),
  .rlast_axi_m_1        (rlast_bm0_ds_1_axi_s_0),
  .rvalid_axi_m_1       (rvalid_bm0_ds_1_axi_s_0),
  .rready_axi_m_1       (rready_bm0_ds_1_axi_s_0),
  .aw_qv_axi_m_1        (),
  .ar_qv_axi_m_1        (),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn),
  .awid_axi_s_0         (awid_cvm_slave_if_bm0_axi_s_0),
  .awaddr_axi_s_0       (awaddr_cvm_slave_if_bm0_axi_s_0),
  .awlen_axi_s_0        (awlen_cvm_slave_if_bm0_axi_s_0),
  .awsize_axi_s_0       (awsize_cvm_slave_if_bm0_axi_s_0),
  .awburst_axi_s_0      (awburst_cvm_slave_if_bm0_axi_s_0),
  .awlock_axi_s_0       (awlock_cvm_slave_if_bm0_axi_s_0),
  .awcache_axi_s_0      (awcache_cvm_slave_if_bm0_axi_s_0),
  .awprot_axi_s_0       (awprot_cvm_slave_if_bm0_axi_s_0),
  .awvalid_axi_s_0      (awvalid_cvm_slave_if_bm0_axi_s_0),
  .awvalid_vect_axi_s_0 (awvalid_vect_cvm_slave_if_bm0_axi_s_0),
  .awready_axi_s_0      (awready_cvm_slave_if_bm0_axi_s_0),
  .wdata_axi_s_0        (wdata_cvm_slave_if_bm0_axi_s_0),
  .wstrb_axi_s_0        (wstrb_cvm_slave_if_bm0_axi_s_0),
  .wlast_axi_s_0        (wlast_cvm_slave_if_bm0_axi_s_0),
  .wvalid_axi_s_0       (wvalid_cvm_slave_if_bm0_axi_s_0),
  .wready_axi_s_0       (wready_cvm_slave_if_bm0_axi_s_0),
  .bid_axi_s_0          (bid_cvm_slave_if_bm0_axi_s_0),
  .bresp_axi_s_0        (bresp_cvm_slave_if_bm0_axi_s_0),
  .bvalid_axi_s_0       (bvalid_cvm_slave_if_bm0_axi_s_0),
  .bready_axi_s_0       (bready_cvm_slave_if_bm0_axi_s_0),
  .arid_axi_s_0         (arid_cvm_slave_if_bm0_axi_s_0),
  .araddr_axi_s_0       (araddr_cvm_slave_if_bm0_axi_s_0),
  .arlen_axi_s_0        (arlen_cvm_slave_if_bm0_axi_s_0),
  .arsize_axi_s_0       (arsize_cvm_slave_if_bm0_axi_s_0),
  .arburst_axi_s_0      (arburst_cvm_slave_if_bm0_axi_s_0),
  .arlock_axi_s_0       (arlock_cvm_slave_if_bm0_axi_s_0),
  .arcache_axi_s_0      (arcache_cvm_slave_if_bm0_axi_s_0),
  .arprot_axi_s_0       (arprot_cvm_slave_if_bm0_axi_s_0),
  .arvalid_axi_s_0      (arvalid_cvm_slave_if_bm0_axi_s_0),
  .arvalid_vect_axi_s_0 (arvalid_vect_cvm_slave_if_bm0_axi_s_0),
  .arready_axi_s_0      (arready_cvm_slave_if_bm0_axi_s_0),
  .rid_axi_s_0          (rid_cvm_slave_if_bm0_axi_s_0),
  .rdata_axi_s_0        (rdata_cvm_slave_if_bm0_axi_s_0),
  .rresp_axi_s_0        (rresp_cvm_slave_if_bm0_axi_s_0),
  .rlast_axi_s_0        (rlast_cvm_slave_if_bm0_axi_s_0),
  .rvalid_axi_s_0       (rvalid_cvm_slave_if_bm0_axi_s_0),
  .rready_axi_s_0       (rready_cvm_slave_if_bm0_axi_s_0),
  .aw_qv_axi_s_0        (awqv_cvm_slave_if_bm0_axi_s_0),
  .ar_qv_axi_s_0        (arqv_cvm_slave_if_bm0_axi_s_0)
);


nic400_default_slave_ds_1_sse710_integration_example_f0_cvm     u_default_slave_ds_1 (
  .awid                 (awid_bm0_ds_1_axi_s_0),
  .awvalid              (awvalid_bm0_ds_1_axi_s_0),
  .awready              (awready_bm0_ds_1_axi_s_0),
  .wlast                (wlast_bm0_ds_1_axi_s_0),
  .wvalid               (wvalid_bm0_ds_1_axi_s_0),
  .wready               (wready_bm0_ds_1_axi_s_0),
  .bid                  (bid_bm0_ds_1_axi_s_0),
  .bresp                (bresp_bm0_ds_1_axi_s_0),
  .bvalid               (bvalid_bm0_ds_1_axi_s_0),
  .bready               (bready_bm0_ds_1_axi_s_0),
  .arid                 (arid_bm0_ds_1_axi_s_0),
  .arlen                (arlen_bm0_ds_1_axi_s_0),
  .arvalid              (arvalid_bm0_ds_1_axi_s_0),
  .arready              (arready_bm0_ds_1_axi_s_0),
  .rid                  (rid_bm0_ds_1_axi_s_0),
  .rresp                (rresp_bm0_ds_1_axi_s_0),
  .rlast                (rlast_bm0_ds_1_axi_s_0),
  .rvalid               (rvalid_bm0_ds_1_axi_s_0),
  .rready               (rready_bm0_ds_1_axi_s_0),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn)
);



endmodule
