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




module nic400_sse710_integration_example_f0_flash (
  

  awid_xnvm_axi_m,
  awaddr_xnvm_axi_m,
  awlen_xnvm_axi_m,
  awsize_xnvm_axi_m,
  awburst_xnvm_axi_m,
  awlock_xnvm_axi_m,
  awcache_xnvm_axi_m,
  awprot_xnvm_axi_m,
  awvalid_xnvm_axi_m,
  awready_xnvm_axi_m,
  wdata_xnvm_axi_m,
  wstrb_xnvm_axi_m,
  wlast_xnvm_axi_m,
  wvalid_xnvm_axi_m,
  wready_xnvm_axi_m,
  bid_xnvm_axi_m,
  bresp_xnvm_axi_m,
  bvalid_xnvm_axi_m,
  bready_xnvm_axi_m,
  arid_xnvm_axi_m,
  araddr_xnvm_axi_m,
  arlen_xnvm_axi_m,
  arsize_xnvm_axi_m,
  arburst_xnvm_axi_m,
  arlock_xnvm_axi_m,
  arcache_xnvm_axi_m,
  arprot_xnvm_axi_m,
  arvalid_xnvm_axi_m,
  arready_xnvm_axi_m,
  rid_xnvm_axi_m,
  rdata_xnvm_axi_m,
  rresp_xnvm_axi_m,
  rlast_xnvm_axi_m,
  rvalid_xnvm_axi_m,
  rready_xnvm_axi_m,
  

  awid_xnvm_axi_s,
  awaddr_xnvm_axi_s,
  awlen_xnvm_axi_s,
  awsize_xnvm_axi_s,
  awburst_xnvm_axi_s,
  awlock_xnvm_axi_s,
  awcache_xnvm_axi_s,
  awprot_xnvm_axi_s,
  awvalid_xnvm_axi_s,
  awready_xnvm_axi_s,
  wdata_xnvm_axi_s,
  wstrb_xnvm_axi_s,
  wlast_xnvm_axi_s,
  wvalid_xnvm_axi_s,
  wready_xnvm_axi_s,
  bid_xnvm_axi_s,
  bresp_xnvm_axi_s,
  bvalid_xnvm_axi_s,
  bready_xnvm_axi_s,
  arid_xnvm_axi_s,
  araddr_xnvm_axi_s,
  arlen_xnvm_axi_s,
  arsize_xnvm_axi_s,
  arburst_xnvm_axi_s,
  arlock_xnvm_axi_s,
  arcache_xnvm_axi_s,
  arprot_xnvm_axi_s,
  arvalid_xnvm_axi_s,
  arready_xnvm_axi_s,
  rid_xnvm_axi_s,
  rdata_xnvm_axi_s,
  rresp_xnvm_axi_s,
  rlast_xnvm_axi_s,
  rvalid_xnvm_axi_s,
  rready_xnvm_axi_s,


  aclkoutclk,
  aclkoutresetn

);






output [11:0] awid_xnvm_axi_m;
output [31:0] awaddr_xnvm_axi_m;
output [7:0]  awlen_xnvm_axi_m;
output [2:0]  awsize_xnvm_axi_m;
output [1:0]  awburst_xnvm_axi_m;
output        awlock_xnvm_axi_m;
output [3:0]  awcache_xnvm_axi_m;
output [2:0]  awprot_xnvm_axi_m;
output        awvalid_xnvm_axi_m;
input         awready_xnvm_axi_m;
output [127:0] wdata_xnvm_axi_m;
output [15:0] wstrb_xnvm_axi_m;
output        wlast_xnvm_axi_m;
output        wvalid_xnvm_axi_m;
input         wready_xnvm_axi_m;
input  [11:0] bid_xnvm_axi_m;
input  [1:0]  bresp_xnvm_axi_m;
input         bvalid_xnvm_axi_m;
output        bready_xnvm_axi_m;
output [11:0] arid_xnvm_axi_m;
output [31:0] araddr_xnvm_axi_m;
output [7:0]  arlen_xnvm_axi_m;
output [2:0]  arsize_xnvm_axi_m;
output [1:0]  arburst_xnvm_axi_m;
output        arlock_xnvm_axi_m;
output [3:0]  arcache_xnvm_axi_m;
output [2:0]  arprot_xnvm_axi_m;
output        arvalid_xnvm_axi_m;
input         arready_xnvm_axi_m;
input  [11:0] rid_xnvm_axi_m;
input  [127:0] rdata_xnvm_axi_m;
input  [1:0]  rresp_xnvm_axi_m;
input         rlast_xnvm_axi_m;
input         rvalid_xnvm_axi_m;
output        rready_xnvm_axi_m;


input  [11:0] awid_xnvm_axi_s;
input  [31:0] awaddr_xnvm_axi_s;
input  [7:0]  awlen_xnvm_axi_s;
input  [2:0]  awsize_xnvm_axi_s;
input  [1:0]  awburst_xnvm_axi_s;
input         awlock_xnvm_axi_s;
input  [3:0]  awcache_xnvm_axi_s;
input  [2:0]  awprot_xnvm_axi_s;
input         awvalid_xnvm_axi_s;
output        awready_xnvm_axi_s;
input  [63:0] wdata_xnvm_axi_s;
input  [7:0]  wstrb_xnvm_axi_s;
input         wlast_xnvm_axi_s;
input         wvalid_xnvm_axi_s;
output        wready_xnvm_axi_s;
output [11:0] bid_xnvm_axi_s;
output [1:0]  bresp_xnvm_axi_s;
output        bvalid_xnvm_axi_s;
input         bready_xnvm_axi_s;
input  [11:0] arid_xnvm_axi_s;
input  [31:0] araddr_xnvm_axi_s;
input  [7:0]  arlen_xnvm_axi_s;
input  [2:0]  arsize_xnvm_axi_s;
input  [1:0]  arburst_xnvm_axi_s;
input         arlock_xnvm_axi_s;
input  [3:0]  arcache_xnvm_axi_s;
input  [2:0]  arprot_xnvm_axi_s;
input         arvalid_xnvm_axi_s;
output        arready_xnvm_axi_s;
output [11:0] rid_xnvm_axi_s;
output [63:0] rdata_xnvm_axi_s;
output [1:0]  rresp_xnvm_axi_s;
output        rlast_xnvm_axi_s;
output        rvalid_xnvm_axi_s;
input         rready_xnvm_axi_s;


input         aclkoutclk;
input         aclkoutresetn;




wire   [31:0]  araddr_xnvm_axi_m;
wire   [1:0]   arburst_xnvm_axi_m;
wire   [3:0]   arcache_xnvm_axi_m;
wire   [11:0]  arid_xnvm_axi_m;
wire   [7:0]   arlen_xnvm_axi_m;
wire           arlock_xnvm_axi_m;
wire   [2:0]   arprot_xnvm_axi_m;
wire           arready_xnvm_axi_s;
wire   [2:0]   arsize_xnvm_axi_m;
wire           arvalid_xnvm_axi_m;
wire   [31:0]  awaddr_xnvm_axi_m;
wire   [1:0]   awburst_xnvm_axi_m;
wire   [3:0]   awcache_xnvm_axi_m;
wire   [11:0]  awid_xnvm_axi_m;
wire   [7:0]   awlen_xnvm_axi_m;
wire           awlock_xnvm_axi_m;
wire   [2:0]   awprot_xnvm_axi_m;
wire           awready_xnvm_axi_s;
wire   [2:0]   awsize_xnvm_axi_m;
wire           awvalid_xnvm_axi_m;
wire   [11:0]  bid_xnvm_axi_s;
wire           bready_xnvm_axi_m;
wire   [1:0]   bresp_xnvm_axi_s;
wire           bvalid_xnvm_axi_s;
wire   [63:0]  rdata_xnvm_axi_s;
wire   [11:0]  rid_xnvm_axi_s;
wire           rlast_xnvm_axi_s;
wire           rready_xnvm_axi_m;
wire   [1:0]   rresp_xnvm_axi_s;
wire           rvalid_xnvm_axi_s;
wire   [127:0] wdata_xnvm_axi_m;
wire           wlast_xnvm_axi_m;
wire           wready_xnvm_axi_s;
wire   [15:0]  wstrb_xnvm_axi_m;
wire           wvalid_xnvm_axi_m;
wire           arready_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire           awready_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire   [11:0]  bid_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire   [1:0]   bresp_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire           bvalid_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire   [127:0] rdata_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire   [11:0]  rid_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire           rlast_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire   [1:0]   rresp_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire           rvalid_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire           wready_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire   [31:0]  araddr_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [1:0]   arburst_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [3:0]   arcache_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [11:0]  arid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [7:0]   arlen_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire           arlock_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [2:0]   arprot_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [2:0]   arsize_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [1:0]   arvalid_vect_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire           arvalid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [31:0]  awaddr_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [1:0]   awburst_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [3:0]   awcache_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [11:0]  awid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [7:0]   awlen_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire           awlock_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [2:0]   awprot_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [2:0]   awsize_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [1:0]   awvalid_vect_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire           awvalid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire           bready_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire           rready_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [63:0]  wdata_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire           wlast_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [7:0]   wstrb_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire           wvalid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [31:0]  araddr_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire   [1:0]   arburst_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire   [3:0]   arcache_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire   [11:0]  arid_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire   [11:0]  arid_bm0_ds_1_axi_s_0;
wire   [7:0]   arlen_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire   [7:0]   arlen_bm0_ds_1_axi_s_0;
wire           arlock_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire   [2:0]   arprot_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire           arready_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [2:0]   arsize_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire           arvalid_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire           arvalid_bm0_ds_1_axi_s_0;
wire   [31:0]  awaddr_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire   [1:0]   awburst_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire   [3:0]   awcache_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire   [11:0]  awid_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire   [11:0]  awid_bm0_ds_1_axi_s_0;
wire   [7:0]   awlen_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire           awlock_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire   [2:0]   awprot_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire           awready_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [2:0]   awsize_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire           awvalid_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire           awvalid_bm0_ds_1_axi_s_0;
wire   [11:0]  bid_xnvm_axi_s_ib_bm0_axi_s_0;
wire           bready_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire           bready_bm0_ds_1_axi_s_0;
wire   [1:0]   bresp_xnvm_axi_s_ib_bm0_axi_s_0;
wire           bvalid_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [127:0] rdata_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [11:0]  rid_xnvm_axi_s_ib_bm0_axi_s_0;
wire           rlast_xnvm_axi_s_ib_bm0_axi_s_0;
wire           rready_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire           rready_bm0_ds_1_axi_s_0;
wire   [1:0]   rresp_xnvm_axi_s_ib_bm0_axi_s_0;
wire           rvalid_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [127:0] wdata_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire           wlast_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire           wlast_bm0_ds_1_axi_s_0;
wire           wready_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [15:0]  wstrb_bm0_xnvm_axi_m_xnvm_axi_m_s;
wire           wvalid_bm0_xnvm_axi_m_xnvm_axi_m_s;
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
wire           ar_ready_xnvm_axi_s_ib_int;
wire   [31:0]  araddr_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [1:0]   arburst_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [3:0]   arcache_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [11:0]  arid_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [7:0]   arlen_xnvm_axi_s_ib_bm0_axi_s_0;
wire           arlock_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [2:0]   arprot_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [3:0]   arqv_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [2:0]   arsize_xnvm_axi_s_ib_bm0_axi_s_0;
wire           arvalid_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [1:0]   arvalid_vect_xnvm_axi_s_ib_bm0_axi_s_0;
wire           aw_ready_xnvm_axi_s_ib_int;
wire   [31:0]  awaddr_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [1:0]   awburst_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [3:0]   awcache_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [11:0]  awid_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [7:0]   awlen_xnvm_axi_s_ib_bm0_axi_s_0;
wire           awlock_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [2:0]   awprot_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [3:0]   awqv_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [2:0]   awsize_xnvm_axi_s_ib_bm0_axi_s_0;
wire           awvalid_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [1:0]   awvalid_vect_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [13:0]  b_data_xnvm_axi_s_ib_int;
wire           b_valid_xnvm_axi_s_ib_int;
wire           bready_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [142:0] r_data_xnvm_axi_s_ib_int;
wire           r_valid_xnvm_axi_s_ib_int;
wire           rready_xnvm_axi_s_ib_bm0_axi_s_0;
wire           w_ready_xnvm_axi_s_ib_int;
wire   [127:0] wdata_xnvm_axi_s_ib_bm0_axi_s_0;
wire           wlast_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [15:0]  wstrb_xnvm_axi_s_ib_bm0_axi_s_0;
wire           wvalid_xnvm_axi_s_ib_bm0_axi_s_0;
wire   [66:0]  ar_data_xnvm_axi_s_ib_int;
wire           ar_valid_xnvm_axi_s_ib_int;
wire           arready_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [66:0]  aw_data_xnvm_axi_s_ib_int;
wire           aw_valid_xnvm_axi_s_ib_int;
wire           awready_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire           b_ready_xnvm_axi_s_ib_int;
wire   [11:0]  bid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [1:0]   bresp_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire           bvalid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire           r_ready_xnvm_axi_s_ib_int;
wire   [63:0]  rdata_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [11:0]  rid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire           rlast_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [1:0]   rresp_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire           rvalid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire   [144:0] w_data_xnvm_axi_s_ib_int;
wire           w_valid_xnvm_axi_s_ib_int;
wire           wready_xnvm_axi_s_xnvm_axi_s_ib_axi4_s;
wire           aclkoutclk;
wire           aclkoutresetn;
wire   [31:0]  araddr_xnvm_axi_s;
wire   [1:0]   arburst_xnvm_axi_s;
wire   [3:0]   arcache_xnvm_axi_s;
wire   [11:0]  arid_xnvm_axi_s;
wire   [7:0]   arlen_xnvm_axi_s;
wire           arlock_xnvm_axi_s;
wire   [2:0]   arprot_xnvm_axi_s;
wire           arready_xnvm_axi_m;
wire   [2:0]   arsize_xnvm_axi_s;
wire           arvalid_xnvm_axi_s;
wire   [31:0]  awaddr_xnvm_axi_s;
wire   [1:0]   awburst_xnvm_axi_s;
wire   [3:0]   awcache_xnvm_axi_s;
wire   [11:0]  awid_xnvm_axi_s;
wire   [7:0]   awlen_xnvm_axi_s;
wire           awlock_xnvm_axi_s;
wire   [2:0]   awprot_xnvm_axi_s;
wire           awready_xnvm_axi_m;
wire   [2:0]   awsize_xnvm_axi_s;
wire           awvalid_xnvm_axi_s;
wire   [11:0]  bid_xnvm_axi_m;
wire           bready_xnvm_axi_s;
wire   [1:0]   bresp_xnvm_axi_m;
wire           bvalid_xnvm_axi_m;
wire   [127:0] rdata_xnvm_axi_m;
wire   [11:0]  rid_xnvm_axi_m;
wire           rlast_xnvm_axi_m;
wire           rready_xnvm_axi_s;
wire   [1:0]   rresp_xnvm_axi_m;
wire           rvalid_xnvm_axi_m;
wire   [63:0]  wdata_xnvm_axi_s;
wire           wlast_xnvm_axi_s;
wire           wready_xnvm_axi_m;
wire   [7:0]   wstrb_xnvm_axi_s;
wire           wvalid_xnvm_axi_s;




nic400_amib_xnvm_axi_m_sse710_integration_example_f0_flash     u_amib_xnvm_axi_m (
  .awid_xnvm_axi_m_m    (awid_xnvm_axi_m),
  .awaddr_xnvm_axi_m_m  (awaddr_xnvm_axi_m),
  .awlen_xnvm_axi_m_m   (awlen_xnvm_axi_m),
  .awsize_xnvm_axi_m_m  (awsize_xnvm_axi_m),
  .awburst_xnvm_axi_m_m (awburst_xnvm_axi_m),
  .awlock_xnvm_axi_m_m  (awlock_xnvm_axi_m),
  .awcache_xnvm_axi_m_m (awcache_xnvm_axi_m),
  .awprot_xnvm_axi_m_m  (awprot_xnvm_axi_m),
  .awvalid_xnvm_axi_m_m (awvalid_xnvm_axi_m),
  .awready_xnvm_axi_m_m (awready_xnvm_axi_m),
  .wdata_xnvm_axi_m_m   (wdata_xnvm_axi_m),
  .wstrb_xnvm_axi_m_m   (wstrb_xnvm_axi_m),
  .wlast_xnvm_axi_m_m   (wlast_xnvm_axi_m),
  .wvalid_xnvm_axi_m_m  (wvalid_xnvm_axi_m),
  .wready_xnvm_axi_m_m  (wready_xnvm_axi_m),
  .bid_xnvm_axi_m_m     (bid_xnvm_axi_m),
  .bresp_xnvm_axi_m_m   (bresp_xnvm_axi_m),
  .bvalid_xnvm_axi_m_m  (bvalid_xnvm_axi_m),
  .bready_xnvm_axi_m_m  (bready_xnvm_axi_m),
  .arid_xnvm_axi_m_m    (arid_xnvm_axi_m),
  .araddr_xnvm_axi_m_m  (araddr_xnvm_axi_m),
  .arlen_xnvm_axi_m_m   (arlen_xnvm_axi_m),
  .arsize_xnvm_axi_m_m  (arsize_xnvm_axi_m),
  .arburst_xnvm_axi_m_m (arburst_xnvm_axi_m),
  .arlock_xnvm_axi_m_m  (arlock_xnvm_axi_m),
  .arcache_xnvm_axi_m_m (arcache_xnvm_axi_m),
  .arprot_xnvm_axi_m_m  (arprot_xnvm_axi_m),
  .arvalid_xnvm_axi_m_m (arvalid_xnvm_axi_m),
  .arready_xnvm_axi_m_m (arready_xnvm_axi_m),
  .rid_xnvm_axi_m_m     (rid_xnvm_axi_m),
  .rdata_xnvm_axi_m_m   (rdata_xnvm_axi_m),
  .rresp_xnvm_axi_m_m   (rresp_xnvm_axi_m),
  .rlast_xnvm_axi_m_m   (rlast_xnvm_axi_m),
  .rvalid_xnvm_axi_m_m  (rvalid_xnvm_axi_m),
  .rready_xnvm_axi_m_m  (rready_xnvm_axi_m),
  .awid_xnvm_axi_m_s    (awid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awaddr_xnvm_axi_m_s  (awaddr_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awlen_xnvm_axi_m_s   (awlen_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awsize_xnvm_axi_m_s  (awsize_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awburst_xnvm_axi_m_s (awburst_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awlock_xnvm_axi_m_s  (awlock_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awcache_xnvm_axi_m_s (awcache_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awprot_xnvm_axi_m_s  (awprot_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awvalid_xnvm_axi_m_s (awvalid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awready_xnvm_axi_m_s (awready_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .wdata_xnvm_axi_m_s   (wdata_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .wstrb_xnvm_axi_m_s   (wstrb_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .wlast_xnvm_axi_m_s   (wlast_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .wvalid_xnvm_axi_m_s  (wvalid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .wready_xnvm_axi_m_s  (wready_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .bid_xnvm_axi_m_s     (bid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .bresp_xnvm_axi_m_s   (bresp_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .bvalid_xnvm_axi_m_s  (bvalid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .bready_xnvm_axi_m_s  (bready_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arid_xnvm_axi_m_s    (arid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .araddr_xnvm_axi_m_s  (araddr_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arlen_xnvm_axi_m_s   (arlen_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arsize_xnvm_axi_m_s  (arsize_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arburst_xnvm_axi_m_s (arburst_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arlock_xnvm_axi_m_s  (arlock_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arcache_xnvm_axi_m_s (arcache_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arprot_xnvm_axi_m_s  (arprot_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arvalid_xnvm_axi_m_s (arvalid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arready_xnvm_axi_m_s (arready_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .rid_xnvm_axi_m_s     (rid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .rdata_xnvm_axi_m_s   (rdata_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .rresp_xnvm_axi_m_s   (rresp_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .rlast_xnvm_axi_m_s   (rlast_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .rvalid_xnvm_axi_m_s  (rvalid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .rready_xnvm_axi_m_s  (rready_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn)
);


nic400_asib_xnvm_axi_s_sse710_integration_example_f0_flash     u_asib_xnvm_axi_s (
  .awid_xnvm_axi_s_m    (awid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awaddr_xnvm_axi_s_m  (awaddr_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awlen_xnvm_axi_s_m   (awlen_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awsize_xnvm_axi_s_m  (awsize_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awburst_xnvm_axi_s_m (awburst_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awlock_xnvm_axi_s_m  (awlock_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awcache_xnvm_axi_s_m (awcache_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awprot_xnvm_axi_s_m  (awprot_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awvalid_xnvm_axi_s_m (awvalid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awvalid_vect_xnvm_axi_s_m (awvalid_vect_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awready_xnvm_axi_s_m (awready_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .wdata_xnvm_axi_s_m   (wdata_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .wstrb_xnvm_axi_s_m   (wstrb_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .wlast_xnvm_axi_s_m   (wlast_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .wvalid_xnvm_axi_s_m  (wvalid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .wready_xnvm_axi_s_m  (wready_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .bid_xnvm_axi_s_m     (bid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .bresp_xnvm_axi_s_m   (bresp_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .bvalid_xnvm_axi_s_m  (bvalid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .bready_xnvm_axi_s_m  (bready_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arid_xnvm_axi_s_m    (arid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .araddr_xnvm_axi_s_m  (araddr_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arlen_xnvm_axi_s_m   (arlen_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arsize_xnvm_axi_s_m  (arsize_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arburst_xnvm_axi_s_m (arburst_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arlock_xnvm_axi_s_m  (arlock_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arcache_xnvm_axi_s_m (arcache_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arprot_xnvm_axi_s_m  (arprot_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arvalid_xnvm_axi_s_m (arvalid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arvalid_vect_xnvm_axi_s_m (arvalid_vect_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arready_xnvm_axi_s_m (arready_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .rid_xnvm_axi_s_m     (rid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .rdata_xnvm_axi_s_m   (rdata_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .rresp_xnvm_axi_s_m   (rresp_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .rlast_xnvm_axi_s_m   (rlast_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .rvalid_xnvm_axi_s_m  (rvalid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .rready_xnvm_axi_s_m  (rready_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn),
  .awid_xnvm_axi_s_s    (awid_xnvm_axi_s),
  .awaddr_xnvm_axi_s_s  (awaddr_xnvm_axi_s),
  .awlen_xnvm_axi_s_s   (awlen_xnvm_axi_s),
  .awsize_xnvm_axi_s_s  (awsize_xnvm_axi_s),
  .awburst_xnvm_axi_s_s (awburst_xnvm_axi_s),
  .awlock_xnvm_axi_s_s  (awlock_xnvm_axi_s),
  .awcache_xnvm_axi_s_s (awcache_xnvm_axi_s),
  .awprot_xnvm_axi_s_s  (awprot_xnvm_axi_s),
  .awvalid_xnvm_axi_s_s (awvalid_xnvm_axi_s),
  .awready_xnvm_axi_s_s (awready_xnvm_axi_s),
  .wdata_xnvm_axi_s_s   (wdata_xnvm_axi_s),
  .wstrb_xnvm_axi_s_s   (wstrb_xnvm_axi_s),
  .wlast_xnvm_axi_s_s   (wlast_xnvm_axi_s),
  .wvalid_xnvm_axi_s_s  (wvalid_xnvm_axi_s),
  .wready_xnvm_axi_s_s  (wready_xnvm_axi_s),
  .bid_xnvm_axi_s_s     (bid_xnvm_axi_s),
  .bresp_xnvm_axi_s_s   (bresp_xnvm_axi_s),
  .bvalid_xnvm_axi_s_s  (bvalid_xnvm_axi_s),
  .bready_xnvm_axi_s_s  (bready_xnvm_axi_s),
  .arid_xnvm_axi_s_s    (arid_xnvm_axi_s),
  .araddr_xnvm_axi_s_s  (araddr_xnvm_axi_s),
  .arlen_xnvm_axi_s_s   (arlen_xnvm_axi_s),
  .arsize_xnvm_axi_s_s  (arsize_xnvm_axi_s),
  .arburst_xnvm_axi_s_s (arburst_xnvm_axi_s),
  .arlock_xnvm_axi_s_s  (arlock_xnvm_axi_s),
  .arcache_xnvm_axi_s_s (arcache_xnvm_axi_s),
  .arprot_xnvm_axi_s_s  (arprot_xnvm_axi_s),
  .arvalid_xnvm_axi_s_s (arvalid_xnvm_axi_s),
  .arready_xnvm_axi_s_s (arready_xnvm_axi_s),
  .rid_xnvm_axi_s_s     (rid_xnvm_axi_s),
  .rdata_xnvm_axi_s_s   (rdata_xnvm_axi_s),
  .rresp_xnvm_axi_s_s   (rresp_xnvm_axi_s),
  .rlast_xnvm_axi_s_s   (rlast_xnvm_axi_s),
  .rvalid_xnvm_axi_s_s  (rvalid_xnvm_axi_s),
  .rready_xnvm_axi_s_s  (rready_xnvm_axi_s)
);


nic400_bm0_sse710_integration_example_f0_flash     u_busmatrix_bm0 (
  .awid_axi_m_0         (awid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awaddr_axi_m_0       (awaddr_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awlen_axi_m_0        (awlen_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awsize_axi_m_0       (awsize_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awburst_axi_m_0      (awburst_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awlock_axi_m_0       (awlock_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awcache_axi_m_0      (awcache_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awprot_axi_m_0       (awprot_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awvalid_axi_m_0      (awvalid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .awvalid_vect_axi_m_0 (),
  .awready_axi_m_0      (awready_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .wdata_axi_m_0        (wdata_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .wstrb_axi_m_0        (wstrb_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .wlast_axi_m_0        (wlast_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .wvalid_axi_m_0       (wvalid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .wready_axi_m_0       (wready_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .bid_axi_m_0          (bid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .bresp_axi_m_0        (bresp_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .bvalid_axi_m_0       (bvalid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .bready_axi_m_0       (bready_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arid_axi_m_0         (arid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .araddr_axi_m_0       (araddr_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arlen_axi_m_0        (arlen_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arsize_axi_m_0       (arsize_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arburst_axi_m_0      (arburst_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arlock_axi_m_0       (arlock_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arcache_axi_m_0      (arcache_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arprot_axi_m_0       (arprot_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arvalid_axi_m_0      (arvalid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .arvalid_vect_axi_m_0 (),
  .arready_axi_m_0      (arready_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .rid_axi_m_0          (rid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .rdata_axi_m_0        (rdata_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .rresp_axi_m_0        (rresp_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .rlast_axi_m_0        (rlast_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .rvalid_axi_m_0       (rvalid_bm0_xnvm_axi_m_xnvm_axi_m_s),
  .rready_axi_m_0       (rready_bm0_xnvm_axi_m_xnvm_axi_m_s),
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
  .rdata_axi_m_1        (128'b0),
  .rresp_axi_m_1        (rresp_bm0_ds_1_axi_s_0),
  .rlast_axi_m_1        (rlast_bm0_ds_1_axi_s_0),
  .rvalid_axi_m_1       (rvalid_bm0_ds_1_axi_s_0),
  .rready_axi_m_1       (rready_bm0_ds_1_axi_s_0),
  .aw_qv_axi_m_1        (),
  .ar_qv_axi_m_1        (),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn),
  .awid_axi_s_0         (awid_xnvm_axi_s_ib_bm0_axi_s_0),
  .awaddr_axi_s_0       (awaddr_xnvm_axi_s_ib_bm0_axi_s_0),
  .awlen_axi_s_0        (awlen_xnvm_axi_s_ib_bm0_axi_s_0),
  .awsize_axi_s_0       (awsize_xnvm_axi_s_ib_bm0_axi_s_0),
  .awburst_axi_s_0      (awburst_xnvm_axi_s_ib_bm0_axi_s_0),
  .awlock_axi_s_0       (awlock_xnvm_axi_s_ib_bm0_axi_s_0),
  .awcache_axi_s_0      (awcache_xnvm_axi_s_ib_bm0_axi_s_0),
  .awprot_axi_s_0       (awprot_xnvm_axi_s_ib_bm0_axi_s_0),
  .awvalid_axi_s_0      (awvalid_xnvm_axi_s_ib_bm0_axi_s_0),
  .awvalid_vect_axi_s_0 (awvalid_vect_xnvm_axi_s_ib_bm0_axi_s_0),
  .awready_axi_s_0      (awready_xnvm_axi_s_ib_bm0_axi_s_0),
  .wdata_axi_s_0        (wdata_xnvm_axi_s_ib_bm0_axi_s_0),
  .wstrb_axi_s_0        (wstrb_xnvm_axi_s_ib_bm0_axi_s_0),
  .wlast_axi_s_0        (wlast_xnvm_axi_s_ib_bm0_axi_s_0),
  .wvalid_axi_s_0       (wvalid_xnvm_axi_s_ib_bm0_axi_s_0),
  .wready_axi_s_0       (wready_xnvm_axi_s_ib_bm0_axi_s_0),
  .bid_axi_s_0          (bid_xnvm_axi_s_ib_bm0_axi_s_0),
  .bresp_axi_s_0        (bresp_xnvm_axi_s_ib_bm0_axi_s_0),
  .bvalid_axi_s_0       (bvalid_xnvm_axi_s_ib_bm0_axi_s_0),
  .bready_axi_s_0       (bready_xnvm_axi_s_ib_bm0_axi_s_0),
  .arid_axi_s_0         (arid_xnvm_axi_s_ib_bm0_axi_s_0),
  .araddr_axi_s_0       (araddr_xnvm_axi_s_ib_bm0_axi_s_0),
  .arlen_axi_s_0        (arlen_xnvm_axi_s_ib_bm0_axi_s_0),
  .arsize_axi_s_0       (arsize_xnvm_axi_s_ib_bm0_axi_s_0),
  .arburst_axi_s_0      (arburst_xnvm_axi_s_ib_bm0_axi_s_0),
  .arlock_axi_s_0       (arlock_xnvm_axi_s_ib_bm0_axi_s_0),
  .arcache_axi_s_0      (arcache_xnvm_axi_s_ib_bm0_axi_s_0),
  .arprot_axi_s_0       (arprot_xnvm_axi_s_ib_bm0_axi_s_0),
  .arvalid_axi_s_0      (arvalid_xnvm_axi_s_ib_bm0_axi_s_0),
  .arvalid_vect_axi_s_0 (arvalid_vect_xnvm_axi_s_ib_bm0_axi_s_0),
  .arready_axi_s_0      (arready_xnvm_axi_s_ib_bm0_axi_s_0),
  .rid_axi_s_0          (rid_xnvm_axi_s_ib_bm0_axi_s_0),
  .rdata_axi_s_0        (rdata_xnvm_axi_s_ib_bm0_axi_s_0),
  .rresp_axi_s_0        (rresp_xnvm_axi_s_ib_bm0_axi_s_0),
  .rlast_axi_s_0        (rlast_xnvm_axi_s_ib_bm0_axi_s_0),
  .rvalid_axi_s_0       (rvalid_xnvm_axi_s_ib_bm0_axi_s_0),
  .rready_axi_s_0       (rready_xnvm_axi_s_ib_bm0_axi_s_0),
  .aw_qv_axi_s_0        (awqv_xnvm_axi_s_ib_bm0_axi_s_0),
  .ar_qv_axi_s_0        (arqv_xnvm_axi_s_ib_bm0_axi_s_0)
);


nic400_default_slave_ds_1_sse710_integration_example_f0_flash     u_default_slave_ds_1 (
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


nic400_ib_xnvm_axi_s_ib_master_domain_sse710_integration_example_f0_flash     u_ib_xnvm_axi_s_ib_m (
  .awid_axi4_m          (awid_xnvm_axi_s_ib_bm0_axi_s_0),
  .awaddr_axi4_m        (awaddr_xnvm_axi_s_ib_bm0_axi_s_0),
  .awlen_axi4_m         (awlen_xnvm_axi_s_ib_bm0_axi_s_0),
  .awsize_axi4_m        (awsize_xnvm_axi_s_ib_bm0_axi_s_0),
  .awburst_axi4_m       (awburst_xnvm_axi_s_ib_bm0_axi_s_0),
  .awlock_axi4_m        (awlock_xnvm_axi_s_ib_bm0_axi_s_0),
  .awcache_axi4_m       (awcache_xnvm_axi_s_ib_bm0_axi_s_0),
  .awprot_axi4_m        (awprot_xnvm_axi_s_ib_bm0_axi_s_0),
  .awvalid_axi4_m       (awvalid_xnvm_axi_s_ib_bm0_axi_s_0),
  .awvalid_vect_axi4_m  (awvalid_vect_xnvm_axi_s_ib_bm0_axi_s_0),
  .awready_axi4_m       (awready_xnvm_axi_s_ib_bm0_axi_s_0),
  .wdata_axi4_m         (wdata_xnvm_axi_s_ib_bm0_axi_s_0),
  .wstrb_axi4_m         (wstrb_xnvm_axi_s_ib_bm0_axi_s_0),
  .wlast_axi4_m         (wlast_xnvm_axi_s_ib_bm0_axi_s_0),
  .wvalid_axi4_m        (wvalid_xnvm_axi_s_ib_bm0_axi_s_0),
  .wready_axi4_m        (wready_xnvm_axi_s_ib_bm0_axi_s_0),
  .bid_axi4_m           (bid_xnvm_axi_s_ib_bm0_axi_s_0),
  .bresp_axi4_m         (bresp_xnvm_axi_s_ib_bm0_axi_s_0),
  .bvalid_axi4_m        (bvalid_xnvm_axi_s_ib_bm0_axi_s_0),
  .bready_axi4_m        (bready_xnvm_axi_s_ib_bm0_axi_s_0),
  .arid_axi4_m          (arid_xnvm_axi_s_ib_bm0_axi_s_0),
  .araddr_axi4_m        (araddr_xnvm_axi_s_ib_bm0_axi_s_0),
  .arlen_axi4_m         (arlen_xnvm_axi_s_ib_bm0_axi_s_0),
  .arsize_axi4_m        (arsize_xnvm_axi_s_ib_bm0_axi_s_0),
  .arburst_axi4_m       (arburst_xnvm_axi_s_ib_bm0_axi_s_0),
  .arlock_axi4_m        (arlock_xnvm_axi_s_ib_bm0_axi_s_0),
  .arcache_axi4_m       (arcache_xnvm_axi_s_ib_bm0_axi_s_0),
  .arprot_axi4_m        (arprot_xnvm_axi_s_ib_bm0_axi_s_0),
  .arvalid_axi4_m       (arvalid_xnvm_axi_s_ib_bm0_axi_s_0),
  .arvalid_vect_axi4_m  (arvalid_vect_xnvm_axi_s_ib_bm0_axi_s_0),
  .arready_axi4_m       (arready_xnvm_axi_s_ib_bm0_axi_s_0),
  .rid_axi4_m           (rid_xnvm_axi_s_ib_bm0_axi_s_0),
  .rdata_axi4_m         (rdata_xnvm_axi_s_ib_bm0_axi_s_0),
  .rresp_axi4_m         (rresp_xnvm_axi_s_ib_bm0_axi_s_0),
  .rlast_axi4_m         (rlast_xnvm_axi_s_ib_bm0_axi_s_0),
  .rvalid_axi4_m        (rvalid_xnvm_axi_s_ib_bm0_axi_s_0),
  .rready_axi4_m        (rready_xnvm_axi_s_ib_bm0_axi_s_0),
  .awqv_axi4_m          (awqv_xnvm_axi_s_ib_bm0_axi_s_0),
  .arqv_axi4_m          (arqv_xnvm_axi_s_ib_bm0_axi_s_0),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn),
  .aw_data              (aw_data_xnvm_axi_s_ib_int),
  .aw_valid             (aw_valid_xnvm_axi_s_ib_int),
  .aw_ready             (aw_ready_xnvm_axi_s_ib_int),
  .b_data               (b_data_xnvm_axi_s_ib_int),
  .b_valid              (b_valid_xnvm_axi_s_ib_int),
  .b_ready              (b_ready_xnvm_axi_s_ib_int),
  .ar_data              (ar_data_xnvm_axi_s_ib_int),
  .ar_valid             (ar_valid_xnvm_axi_s_ib_int),
  .ar_ready             (ar_ready_xnvm_axi_s_ib_int),
  .r_data               (r_data_xnvm_axi_s_ib_int),
  .r_valid              (r_valid_xnvm_axi_s_ib_int),
  .r_ready              (r_ready_xnvm_axi_s_ib_int),
  .w_data               (w_data_xnvm_axi_s_ib_int),
  .w_valid              (w_valid_xnvm_axi_s_ib_int),
  .w_ready              (w_ready_xnvm_axi_s_ib_int)
);


nic400_ib_xnvm_axi_s_ib_slave_domain_sse710_integration_example_f0_flash     u_ib_xnvm_axi_s_ib_s (
  .awid_axi4_s          (awid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awlen_axi4_s         (awlen_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awsize_axi4_s        (awsize_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awburst_axi4_s       (awburst_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awlock_axi4_s        (awlock_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awcache_axi4_s       (awcache_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awprot_axi4_s        (awprot_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awvalid_vect_axi4_s  (awvalid_vect_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .awready_axi4_s       (awready_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .wdata_axi4_s         (wdata_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .wlast_axi4_s         (wlast_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .wready_axi4_s        (wready_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .bid_axi4_s           (bid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .bresp_axi4_s         (bresp_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .bready_axi4_s        (bready_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arid_axi4_s          (arid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .araddr_axi4_s        (araddr_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arlen_axi4_s         (arlen_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arsize_axi4_s        (arsize_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arburst_axi4_s       (arburst_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arlock_axi4_s        (arlock_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arcache_axi4_s       (arcache_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arprot_axi4_s        (arprot_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arvalid_vect_axi4_s  (arvalid_vect_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .arready_axi4_s       (arready_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .rid_axi4_s           (rid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .rdata_axi4_s         (rdata_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .rresp_axi4_s         (rresp_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .rlast_axi4_s         (rlast_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .rready_axi4_s        (rready_xnvm_axi_s_xnvm_axi_s_ib_axi4_s),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn),
  .aw_data              (aw_data_xnvm_axi_s_ib_int),
  .aw_valid             (aw_valid_xnvm_axi_s_ib_int),
  .aw_ready             (aw_ready_xnvm_axi_s_ib_int),
  .b_data               (b_data_xnvm_axi_s_ib_int),
  .b_valid              (b_valid_xnvm_axi_s_ib_int),
  .b_ready              (b_ready_xnvm_axi_s_ib_int),
  .ar_data              (ar_data_xnvm_axi_s_ib_int),
  .ar_valid             (ar_valid_xnvm_axi_s_ib_int),
  .ar_ready             (ar_ready_xnvm_axi_s_ib_int),
  .r_data               (r_data_xnvm_axi_s_ib_int),
  .r_valid              (r_valid_xnvm_axi_s_ib_int),
  .r_ready              (r_ready_xnvm_axi_s_ib_int),
  .w_data               (w_data_xnvm_axi_s_ib_int),
  .w_valid              (w_valid_xnvm_axi_s_ib_int),
  .w_ready              (w_ready_xnvm_axi_s_ib_int)
);



endmodule
