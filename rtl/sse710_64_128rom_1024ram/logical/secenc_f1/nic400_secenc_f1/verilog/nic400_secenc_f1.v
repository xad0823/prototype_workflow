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




module nic400_secenc_f1 (
  

  awid_master_if0,
  awaddr_master_if0,
  awlen_master_if0,
  awsize_master_if0,
  awburst_master_if0,
  awlock_master_if0,
  awcache_master_if0,
  awprot_master_if0,
  awvalid_master_if0,
  awready_master_if0,
  wdata_master_if0,
  wstrb_master_if0,
  wlast_master_if0,
  wvalid_master_if0,
  wready_master_if0,
  bid_master_if0,
  bresp_master_if0,
  bvalid_master_if0,
  bready_master_if0,
  arid_master_if0,
  araddr_master_if0,
  arlen_master_if0,
  arsize_master_if0,
  arburst_master_if0,
  arlock_master_if0,
  arcache_master_if0,
  arprot_master_if0,
  arvalid_master_if0,
  arready_master_if0,
  rid_master_if0,
  rdata_master_if0,
  rresp_master_if0,
  rlast_master_if0,
  rvalid_master_if0,
  rready_master_if0,
  awuser_master_if0,
  aruser_master_if0,
  

  awaddr_master_if1,
  awlen_master_if1,
  awsize_master_if1,
  awburst_master_if1,
  awlock_master_if1,
  awcache_master_if1,
  awprot_master_if1,
  awvalid_master_if1,
  awready_master_if1,
  wdata_master_if1,
  wstrb_master_if1,
  wlast_master_if1,
  wvalid_master_if1,
  wready_master_if1,
  bresp_master_if1,
  bvalid_master_if1,
  bready_master_if1,
  araddr_master_if1,
  arlen_master_if1,
  arsize_master_if1,
  arburst_master_if1,
  arlock_master_if1,
  arcache_master_if1,
  arprot_master_if1,
  arvalid_master_if1,
  arready_master_if1,
  rdata_master_if1,
  rresp_master_if1,
  rlast_master_if1,
  rvalid_master_if1,
  rready_master_if1,
  

  hselx_master_if2,
  haddr_master_if2,
  htrans_master_if2,
  hwrite_master_if2,
  hsize_master_if2,
  hburst_master_if2,
  hprot_master_if2,
  hwdata_master_if2,
  hrdata_master_if2,
  hreadyout_master_if2,
  hready_master_if2,
  hresp_master_if2,
  hauser_master_if2,
  

  haddr_master_if3,
  htrans_master_if3,
  hwrite_master_if3,
  hsize_master_if3,
  hburst_master_if3,
  hprot_master_if3,
  hwdata_master_if3,
  hrdata_master_if3,
  hready_master_if3,
  hresp_master_if3,
  

  haddr_slave_if0,
  htrans_slave_if0,
  hwrite_slave_if0,
  hsize_slave_if0,
  hburst_slave_if0,
  hprot_slave_if0,
  hwdata_slave_if0,
  hrdata_slave_if0,
  hready_slave_if0,
  hresp_slave_if0,
  

  haddr_slave_if1,
  htrans_slave_if1,
  hwrite_slave_if1,
  hsize_slave_if1,
  hburst_slave_if1,
  hprot_slave_if1,
  hwdata_slave_if1,
  hselx_slave_if1,
  hrdata_slave_if1,
  hready_slave_if1,
  hreadyout_slave_if1,
  hresp_slave_if1,
  hauser_slave_if1,


  clk0clk,
  clk0resetn

);






output        awid_master_if0;
output [31:0] awaddr_master_if0;
output [7:0]  awlen_master_if0;
output [2:0]  awsize_master_if0;
output [1:0]  awburst_master_if0;
output        awlock_master_if0;
output [3:0]  awcache_master_if0;
output [2:0]  awprot_master_if0;
output        awvalid_master_if0;
input         awready_master_if0;
output [31:0] wdata_master_if0;
output [3:0]  wstrb_master_if0;
output        wlast_master_if0;
output        wvalid_master_if0;
input         wready_master_if0;
input         bid_master_if0;
input  [1:0]  bresp_master_if0;
input         bvalid_master_if0;
output        bready_master_if0;
output        arid_master_if0;
output [31:0] araddr_master_if0;
output [7:0]  arlen_master_if0;
output [2:0]  arsize_master_if0;
output [1:0]  arburst_master_if0;
output        arlock_master_if0;
output [3:0]  arcache_master_if0;
output [2:0]  arprot_master_if0;
output        arvalid_master_if0;
input         arready_master_if0;
input         rid_master_if0;
input  [31:0] rdata_master_if0;
input  [1:0]  rresp_master_if0;
input         rlast_master_if0;
input         rvalid_master_if0;
output        rready_master_if0;
output [1:0]  awuser_master_if0;
output [1:0]  aruser_master_if0;


output [31:0] awaddr_master_if1;
output [7:0]  awlen_master_if1;
output [2:0]  awsize_master_if1;
output [1:0]  awburst_master_if1;
output        awlock_master_if1;
output [3:0]  awcache_master_if1;
output [2:0]  awprot_master_if1;
output        awvalid_master_if1;
input         awready_master_if1;
output [31:0] wdata_master_if1;
output [3:0]  wstrb_master_if1;
output        wlast_master_if1;
output        wvalid_master_if1;
input         wready_master_if1;
input  [1:0]  bresp_master_if1;
input         bvalid_master_if1;
output        bready_master_if1;
output [31:0] araddr_master_if1;
output [7:0]  arlen_master_if1;
output [2:0]  arsize_master_if1;
output [1:0]  arburst_master_if1;
output        arlock_master_if1;
output [3:0]  arcache_master_if1;
output [2:0]  arprot_master_if1;
output        arvalid_master_if1;
input         arready_master_if1;
input  [31:0] rdata_master_if1;
input  [1:0]  rresp_master_if1;
input         rlast_master_if1;
input         rvalid_master_if1;
output        rready_master_if1;


output        hselx_master_if2;
output [31:0] haddr_master_if2;
output [1:0]  htrans_master_if2;
output        hwrite_master_if2;
output [2:0]  hsize_master_if2;
output [2:0]  hburst_master_if2;
output [3:0]  hprot_master_if2;
output [31:0] hwdata_master_if2;
input  [31:0] hrdata_master_if2;
input         hreadyout_master_if2;
output        hready_master_if2;
input         hresp_master_if2;
output [1:0]  hauser_master_if2;


output [31:0] haddr_master_if3;
output [1:0]  htrans_master_if3;
output        hwrite_master_if3;
output [2:0]  hsize_master_if3;
output [2:0]  hburst_master_if3;
output [3:0]  hprot_master_if3;
output [31:0] hwdata_master_if3;
input  [31:0] hrdata_master_if3;
input         hready_master_if3;
input         hresp_master_if3;


input  [31:0] haddr_slave_if0;
input  [1:0]  htrans_slave_if0;
input         hwrite_slave_if0;
input  [2:0]  hsize_slave_if0;
input  [2:0]  hburst_slave_if0;
input  [3:0]  hprot_slave_if0;
input  [31:0] hwdata_slave_if0;
output [31:0] hrdata_slave_if0;
output        hready_slave_if0;
output        hresp_slave_if0;


input  [31:0] haddr_slave_if1;
input  [1:0]  htrans_slave_if1;
input         hwrite_slave_if1;
input  [2:0]  hsize_slave_if1;
input  [2:0]  hburst_slave_if1;
input  [3:0]  hprot_slave_if1;
input  [31:0] hwdata_slave_if1;
input         hselx_slave_if1;
output [31:0] hrdata_slave_if1;
input         hready_slave_if1;
output        hreadyout_slave_if1;
output        hresp_slave_if1;
input  [1:0]  hauser_slave_if1;


input         clk0clk;
input         clk0resetn;




wire   [31:0]  araddr_master_if0;
wire   [31:0]  araddr_master_if1;
wire   [1:0]   arburst_master_if0;
wire   [1:0]   arburst_master_if1;
wire   [3:0]   arcache_master_if0;
wire   [3:0]   arcache_master_if1;
wire           arid_master_if0;
wire   [7:0]   arlen_master_if0;
wire   [7:0]   arlen_master_if1;
wire           arlock_master_if0;
wire           arlock_master_if1;
wire   [2:0]   arprot_master_if0;
wire   [2:0]   arprot_master_if1;
wire   [2:0]   arsize_master_if0;
wire   [2:0]   arsize_master_if1;
wire   [1:0]   aruser_master_if0;
wire           arvalid_master_if0;
wire           arvalid_master_if1;
wire   [31:0]  awaddr_master_if0;
wire   [31:0]  awaddr_master_if1;
wire   [1:0]   awburst_master_if0;
wire   [1:0]   awburst_master_if1;
wire   [3:0]   awcache_master_if0;
wire   [3:0]   awcache_master_if1;
wire           awid_master_if0;
wire   [7:0]   awlen_master_if0;
wire   [7:0]   awlen_master_if1;
wire           awlock_master_if0;
wire           awlock_master_if1;
wire   [2:0]   awprot_master_if0;
wire   [2:0]   awprot_master_if1;
wire   [2:0]   awsize_master_if0;
wire   [2:0]   awsize_master_if1;
wire   [1:0]   awuser_master_if0;
wire           awvalid_master_if0;
wire           awvalid_master_if1;
wire           bready_master_if0;
wire           bready_master_if1;
wire   [31:0]  haddr_master_if2;
wire   [31:0]  haddr_master_if3;
wire   [1:0]   hauser_master_if2;
wire   [2:0]   hburst_master_if2;
wire   [2:0]   hburst_master_if3;
wire   [3:0]   hprot_master_if2;
wire   [3:0]   hprot_master_if3;
wire   [31:0]  hrdata_slave_if0;
wire   [31:0]  hrdata_slave_if1;
wire           hready_master_if2;
wire           hready_slave_if0;
wire           hreadyout_slave_if1;
wire           hresp_slave_if0;
wire           hresp_slave_if1;
wire           hselx_master_if2;
wire   [2:0]   hsize_master_if2;
wire   [2:0]   hsize_master_if3;
wire   [1:0]   htrans_master_if2;
wire   [1:0]   htrans_master_if3;
wire   [31:0]  hwdata_master_if2;
wire   [31:0]  hwdata_master_if3;
wire           hwrite_master_if2;
wire           hwrite_master_if3;
wire           rready_master_if0;
wire           rready_master_if1;
wire   [31:0]  wdata_master_if0;
wire   [31:0]  wdata_master_if1;
wire           wlast_master_if0;
wire           wlast_master_if1;
wire   [3:0]   wstrb_master_if0;
wire   [3:0]   wstrb_master_if1;
wire           wvalid_master_if0;
wire           wvalid_master_if1;
wire           arready_bm0_master_if0_master_if0_s;
wire           awready_bm0_master_if0_master_if0_s;
wire           bid_bm0_master_if0_master_if0_s;
wire   [1:0]   bresp_bm0_master_if0_master_if0_s;
wire           bvalid_bm0_master_if0_master_if0_s;
wire   [31:0]  rdata_bm0_master_if0_master_if0_s;
wire           rid_bm0_master_if0_master_if0_s;
wire           rlast_bm0_master_if0_master_if0_s;
wire   [1:0]   rresp_bm0_master_if0_master_if0_s;
wire           rvalid_bm0_master_if0_master_if0_s;
wire           wready_bm0_master_if0_master_if0_s;
wire           arready_bm0_master_if1_master_if1_s;
wire           awready_bm0_master_if1_master_if1_s;
wire           bid_bm0_master_if1_master_if1_s;
wire   [1:0]   bresp_bm0_master_if1_master_if1_s;
wire           bvalid_bm0_master_if1_master_if1_s;
wire   [31:0]  rdata_bm0_master_if1_master_if1_s;
wire           rid_bm0_master_if1_master_if1_s;
wire           rlast_bm0_master_if1_master_if1_s;
wire   [1:0]   rresp_bm0_master_if1_master_if1_s;
wire           rvalid_bm0_master_if1_master_if1_s;
wire           wready_bm0_master_if1_master_if1_s;
wire           arready_bm0_master_if2_master_if2_s;
wire           awready_bm0_master_if2_master_if2_s;
wire           bid_bm0_master_if2_master_if2_s;
wire   [1:0]   bresp_bm0_master_if2_master_if2_s;
wire           bvalid_bm0_master_if2_master_if2_s;
wire   [31:0]  rdata_bm0_master_if2_master_if2_s;
wire           rid_bm0_master_if2_master_if2_s;
wire           rlast_bm0_master_if2_master_if2_s;
wire   [1:0]   rresp_bm0_master_if2_master_if2_s;
wire           rvalid_bm0_master_if2_master_if2_s;
wire           wready_bm0_master_if2_master_if2_s;
wire           arready_bm0_master_if3_master_if3_s;
wire           awready_bm0_master_if3_master_if3_s;
wire           bid_bm0_master_if3_master_if3_s;
wire   [1:0]   bresp_bm0_master_if3_master_if3_s;
wire           bvalid_bm0_master_if3_master_if3_s;
wire   [31:0]  rdata_bm0_master_if3_master_if3_s;
wire           rid_bm0_master_if3_master_if3_s;
wire           rlast_bm0_master_if3_master_if3_s;
wire   [1:0]   rresp_bm0_master_if3_master_if3_s;
wire           rvalid_bm0_master_if3_master_if3_s;
wire           wready_bm0_master_if3_master_if3_s;
wire   [31:0]  araddr_slave_if0_bm0_axi_s_0;
wire   [1:0]   arburst_slave_if0_bm0_axi_s_0;
wire   [3:0]   arcache_slave_if0_bm0_axi_s_0;
wire           arid_slave_if0_bm0_axi_s_0;
wire   [7:0]   arlen_slave_if0_bm0_axi_s_0;
wire           arlock_slave_if0_bm0_axi_s_0;
wire   [2:0]   arprot_slave_if0_bm0_axi_s_0;
wire   [3:0]   arqv_slave_if0_bm0_axi_s_0;
wire   [2:0]   arsize_slave_if0_bm0_axi_s_0;
wire           arvalid_slave_if0_bm0_axi_s_0;
wire   [3:0]   arvalid_vect_slave_if0_bm0_axi_s_0;
wire   [31:0]  awaddr_slave_if0_bm0_axi_s_0;
wire   [1:0]   awburst_slave_if0_bm0_axi_s_0;
wire   [3:0]   awcache_slave_if0_bm0_axi_s_0;
wire           awid_slave_if0_bm0_axi_s_0;
wire   [7:0]   awlen_slave_if0_bm0_axi_s_0;
wire           awlock_slave_if0_bm0_axi_s_0;
wire   [2:0]   awprot_slave_if0_bm0_axi_s_0;
wire   [3:0]   awqv_slave_if0_bm0_axi_s_0;
wire   [2:0]   awsize_slave_if0_bm0_axi_s_0;
wire           awvalid_slave_if0_bm0_axi_s_0;
wire   [3:0]   awvalid_vect_slave_if0_bm0_axi_s_0;
wire           bready_slave_if0_bm0_axi_s_0;
wire           rready_slave_if0_bm0_axi_s_0;
wire   [31:0]  wdata_slave_if0_bm0_axi_s_0;
wire           wlast_slave_if0_bm0_axi_s_0;
wire   [3:0]   wstrb_slave_if0_bm0_axi_s_0;
wire           wvalid_slave_if0_bm0_axi_s_0;
wire   [31:0]  araddr_slave_if1_bm0_axi_s_1;
wire   [1:0]   arburst_slave_if1_bm0_axi_s_1;
wire   [3:0]   arcache_slave_if1_bm0_axi_s_1;
wire           arid_slave_if1_bm0_axi_s_1;
wire   [7:0]   arlen_slave_if1_bm0_axi_s_1;
wire           arlock_slave_if1_bm0_axi_s_1;
wire   [2:0]   arprot_slave_if1_bm0_axi_s_1;
wire   [3:0]   arqv_slave_if1_bm0_axi_s_1;
wire   [2:0]   arsize_slave_if1_bm0_axi_s_1;
wire   [1:0]   aruser_slave_if1_bm0_axi_s_1;
wire           arvalid_slave_if1_bm0_axi_s_1;
wire   [2:0]   arvalid_vect_slave_if1_bm0_axi_s_1;
wire   [31:0]  awaddr_slave_if1_bm0_axi_s_1;
wire   [1:0]   awburst_slave_if1_bm0_axi_s_1;
wire   [3:0]   awcache_slave_if1_bm0_axi_s_1;
wire           awid_slave_if1_bm0_axi_s_1;
wire   [7:0]   awlen_slave_if1_bm0_axi_s_1;
wire           awlock_slave_if1_bm0_axi_s_1;
wire   [2:0]   awprot_slave_if1_bm0_axi_s_1;
wire   [3:0]   awqv_slave_if1_bm0_axi_s_1;
wire   [2:0]   awsize_slave_if1_bm0_axi_s_1;
wire   [1:0]   awuser_slave_if1_bm0_axi_s_1;
wire           awvalid_slave_if1_bm0_axi_s_1;
wire   [2:0]   awvalid_vect_slave_if1_bm0_axi_s_1;
wire           bready_slave_if1_bm0_axi_s_1;
wire           rready_slave_if1_bm0_axi_s_1;
wire   [31:0]  wdata_slave_if1_bm0_axi_s_1;
wire           wlast_slave_if1_bm0_axi_s_1;
wire   [3:0]   wstrb_slave_if1_bm0_axi_s_1;
wire           wvalid_slave_if1_bm0_axi_s_1;
wire   [31:0]  araddr_bm0_master_if3_master_if3_s;
wire   [31:0]  araddr_bm0_master_if1_master_if1_s;
wire   [31:0]  araddr_bm0_master_if0_master_if0_s;
wire   [31:0]  araddr_bm0_master_if2_master_if2_s;
wire   [1:0]   arburst_bm0_master_if3_master_if3_s;
wire   [1:0]   arburst_bm0_master_if1_master_if1_s;
wire   [1:0]   arburst_bm0_master_if0_master_if0_s;
wire   [1:0]   arburst_bm0_master_if2_master_if2_s;
wire   [3:0]   arcache_bm0_master_if3_master_if3_s;
wire   [3:0]   arcache_bm0_master_if1_master_if1_s;
wire   [3:0]   arcache_bm0_master_if0_master_if0_s;
wire   [3:0]   arcache_bm0_master_if2_master_if2_s;
wire           arid_bm0_master_if3_master_if3_s;
wire           arid_bm0_master_if1_master_if1_s;
wire           arid_bm0_master_if0_master_if0_s;
wire           arid_bm0_master_if2_master_if2_s;
wire           arid_bm0_ds_1_axi_s_0;
wire   [7:0]   arlen_bm0_master_if3_master_if3_s;
wire   [7:0]   arlen_bm0_master_if1_master_if1_s;
wire   [7:0]   arlen_bm0_master_if0_master_if0_s;
wire   [7:0]   arlen_bm0_master_if2_master_if2_s;
wire   [7:0]   arlen_bm0_ds_1_axi_s_0;
wire           arlock_bm0_master_if3_master_if3_s;
wire           arlock_bm0_master_if1_master_if1_s;
wire           arlock_bm0_master_if0_master_if0_s;
wire           arlock_bm0_master_if2_master_if2_s;
wire   [2:0]   arprot_bm0_master_if3_master_if3_s;
wire   [2:0]   arprot_bm0_master_if1_master_if1_s;
wire   [2:0]   arprot_bm0_master_if0_master_if0_s;
wire   [2:0]   arprot_bm0_master_if2_master_if2_s;
wire           arready_slave_if0_bm0_axi_s_0;
wire           arready_slave_if1_bm0_axi_s_1;
wire   [2:0]   arsize_bm0_master_if3_master_if3_s;
wire   [2:0]   arsize_bm0_master_if1_master_if1_s;
wire   [2:0]   arsize_bm0_master_if0_master_if0_s;
wire   [2:0]   arsize_bm0_master_if2_master_if2_s;
wire   [1:0]   aruser_bm0_master_if0_master_if0_s;
wire   [1:0]   aruser_bm0_master_if2_master_if2_s;
wire           arvalid_bm0_master_if3_master_if3_s;
wire           arvalid_bm0_master_if1_master_if1_s;
wire           arvalid_bm0_master_if0_master_if0_s;
wire           arvalid_bm0_master_if2_master_if2_s;
wire           arvalid_bm0_ds_1_axi_s_0;
wire   [31:0]  awaddr_bm0_master_if3_master_if3_s;
wire   [31:0]  awaddr_bm0_master_if1_master_if1_s;
wire   [31:0]  awaddr_bm0_master_if0_master_if0_s;
wire   [31:0]  awaddr_bm0_master_if2_master_if2_s;
wire   [1:0]   awburst_bm0_master_if3_master_if3_s;
wire   [1:0]   awburst_bm0_master_if1_master_if1_s;
wire   [1:0]   awburst_bm0_master_if0_master_if0_s;
wire   [1:0]   awburst_bm0_master_if2_master_if2_s;
wire   [3:0]   awcache_bm0_master_if3_master_if3_s;
wire   [3:0]   awcache_bm0_master_if1_master_if1_s;
wire   [3:0]   awcache_bm0_master_if0_master_if0_s;
wire   [3:0]   awcache_bm0_master_if2_master_if2_s;
wire           awid_bm0_master_if3_master_if3_s;
wire           awid_bm0_master_if1_master_if1_s;
wire           awid_bm0_master_if0_master_if0_s;
wire           awid_bm0_master_if2_master_if2_s;
wire           awid_bm0_ds_1_axi_s_0;
wire   [7:0]   awlen_bm0_master_if3_master_if3_s;
wire   [7:0]   awlen_bm0_master_if1_master_if1_s;
wire   [7:0]   awlen_bm0_master_if0_master_if0_s;
wire   [7:0]   awlen_bm0_master_if2_master_if2_s;
wire           awlock_bm0_master_if3_master_if3_s;
wire           awlock_bm0_master_if1_master_if1_s;
wire           awlock_bm0_master_if0_master_if0_s;
wire           awlock_bm0_master_if2_master_if2_s;
wire   [2:0]   awprot_bm0_master_if3_master_if3_s;
wire   [2:0]   awprot_bm0_master_if1_master_if1_s;
wire   [2:0]   awprot_bm0_master_if0_master_if0_s;
wire   [2:0]   awprot_bm0_master_if2_master_if2_s;
wire           awready_slave_if0_bm0_axi_s_0;
wire           awready_slave_if1_bm0_axi_s_1;
wire   [2:0]   awsize_bm0_master_if3_master_if3_s;
wire   [2:0]   awsize_bm0_master_if1_master_if1_s;
wire   [2:0]   awsize_bm0_master_if0_master_if0_s;
wire   [2:0]   awsize_bm0_master_if2_master_if2_s;
wire   [1:0]   awuser_bm0_master_if0_master_if0_s;
wire   [1:0]   awuser_bm0_master_if2_master_if2_s;
wire           awvalid_bm0_master_if3_master_if3_s;
wire           awvalid_bm0_master_if1_master_if1_s;
wire           awvalid_bm0_master_if0_master_if0_s;
wire           awvalid_bm0_master_if2_master_if2_s;
wire           awvalid_bm0_ds_1_axi_s_0;
wire           bid_slave_if0_bm0_axi_s_0;
wire           bid_slave_if1_bm0_axi_s_1;
wire           bready_bm0_master_if3_master_if3_s;
wire           bready_bm0_master_if1_master_if1_s;
wire           bready_bm0_master_if0_master_if0_s;
wire           bready_bm0_master_if2_master_if2_s;
wire           bready_bm0_ds_1_axi_s_0;
wire   [1:0]   bresp_slave_if0_bm0_axi_s_0;
wire   [1:0]   bresp_slave_if1_bm0_axi_s_1;
wire           bvalid_slave_if0_bm0_axi_s_0;
wire           bvalid_slave_if1_bm0_axi_s_1;
wire   [31:0]  rdata_slave_if0_bm0_axi_s_0;
wire   [31:0]  rdata_slave_if1_bm0_axi_s_1;
wire           rid_slave_if0_bm0_axi_s_0;
wire           rid_slave_if1_bm0_axi_s_1;
wire           rlast_slave_if0_bm0_axi_s_0;
wire           rlast_slave_if1_bm0_axi_s_1;
wire           rready_bm0_master_if3_master_if3_s;
wire           rready_bm0_master_if1_master_if1_s;
wire           rready_bm0_master_if0_master_if0_s;
wire           rready_bm0_master_if2_master_if2_s;
wire           rready_bm0_ds_1_axi_s_0;
wire   [1:0]   rresp_slave_if0_bm0_axi_s_0;
wire   [1:0]   rresp_slave_if1_bm0_axi_s_1;
wire           rvalid_slave_if0_bm0_axi_s_0;
wire           rvalid_slave_if1_bm0_axi_s_1;
wire   [31:0]  wdata_bm0_master_if3_master_if3_s;
wire   [31:0]  wdata_bm0_master_if1_master_if1_s;
wire   [31:0]  wdata_bm0_master_if0_master_if0_s;
wire   [31:0]  wdata_bm0_master_if2_master_if2_s;
wire           wlast_bm0_master_if3_master_if3_s;
wire           wlast_bm0_master_if1_master_if1_s;
wire           wlast_bm0_master_if0_master_if0_s;
wire           wlast_bm0_master_if2_master_if2_s;
wire           wlast_bm0_ds_1_axi_s_0;
wire           wready_slave_if0_bm0_axi_s_0;
wire           wready_slave_if1_bm0_axi_s_1;
wire   [3:0]   wstrb_bm0_master_if3_master_if3_s;
wire   [3:0]   wstrb_bm0_master_if1_master_if1_s;
wire   [3:0]   wstrb_bm0_master_if0_master_if0_s;
wire   [3:0]   wstrb_bm0_master_if2_master_if2_s;
wire           wvalid_bm0_master_if3_master_if3_s;
wire           wvalid_bm0_master_if1_master_if1_s;
wire           wvalid_bm0_master_if0_master_if0_s;
wire           wvalid_bm0_master_if2_master_if2_s;
wire           wvalid_bm0_ds_1_axi_s_0;
wire           arready_bm0_ds_1_axi_s_0;
wire           awready_bm0_ds_1_axi_s_0;
wire           bid_bm0_ds_1_axi_s_0;
wire   [1:0]   bresp_bm0_ds_1_axi_s_0;
wire           bvalid_bm0_ds_1_axi_s_0;
wire           rid_bm0_ds_1_axi_s_0;
wire           rlast_bm0_ds_1_axi_s_0;
wire   [1:0]   rresp_bm0_ds_1_axi_s_0;
wire           rvalid_bm0_ds_1_axi_s_0;
wire           wready_bm0_ds_1_axi_s_0;
wire           arready_master_if0;
wire           arready_master_if1;
wire           awready_master_if0;
wire           awready_master_if1;
wire           bid_master_if0;
wire   [1:0]   bresp_master_if0;
wire   [1:0]   bresp_master_if1;
wire           bvalid_master_if0;
wire           bvalid_master_if1;
wire           clk0clk;
wire           clk0resetn;
wire   [31:0]  haddr_slave_if0;
wire   [31:0]  haddr_slave_if1;
wire   [1:0]   hauser_slave_if1;
wire   [2:0]   hburst_slave_if0;
wire   [2:0]   hburst_slave_if1;
wire   [3:0]   hprot_slave_if0;
wire   [3:0]   hprot_slave_if1;
wire   [31:0]  hrdata_master_if2;
wire   [31:0]  hrdata_master_if3;
wire           hready_master_if3;
wire           hready_slave_if1;
wire           hreadyout_master_if2;
wire           hresp_master_if2;
wire           hresp_master_if3;
wire           hselx_slave_if1;
wire   [2:0]   hsize_slave_if0;
wire   [2:0]   hsize_slave_if1;
wire   [1:0]   htrans_slave_if0;
wire   [1:0]   htrans_slave_if1;
wire   [31:0]  hwdata_slave_if0;
wire   [31:0]  hwdata_slave_if1;
wire           hwrite_slave_if0;
wire           hwrite_slave_if1;
wire   [31:0]  rdata_master_if0;
wire   [31:0]  rdata_master_if1;
wire           rid_master_if0;
wire           rlast_master_if0;
wire           rlast_master_if1;
wire   [1:0]   rresp_master_if0;
wire   [1:0]   rresp_master_if1;
wire           rvalid_master_if0;
wire           rvalid_master_if1;
wire           wready_master_if0;
wire           wready_master_if1;




nic400_amib_master_if0_secenc_f1     u_amib_master_if0 (
  .awid_master_if0_m    (awid_master_if0),
  .awaddr_master_if0_m  (awaddr_master_if0),
  .awlen_master_if0_m   (awlen_master_if0),
  .awsize_master_if0_m  (awsize_master_if0),
  .awburst_master_if0_m (awburst_master_if0),
  .awlock_master_if0_m  (awlock_master_if0),
  .awcache_master_if0_m (awcache_master_if0),
  .awprot_master_if0_m  (awprot_master_if0),
  .awvalid_master_if0_m (awvalid_master_if0),
  .awready_master_if0_m (awready_master_if0),
  .wdata_master_if0_m   (wdata_master_if0),
  .wstrb_master_if0_m   (wstrb_master_if0),
  .wlast_master_if0_m   (wlast_master_if0),
  .wvalid_master_if0_m  (wvalid_master_if0),
  .wready_master_if0_m  (wready_master_if0),
  .bid_master_if0_m     (bid_master_if0),
  .bresp_master_if0_m   (bresp_master_if0),
  .bvalid_master_if0_m  (bvalid_master_if0),
  .bready_master_if0_m  (bready_master_if0),
  .arid_master_if0_m    (arid_master_if0),
  .araddr_master_if0_m  (araddr_master_if0),
  .arlen_master_if0_m   (arlen_master_if0),
  .arsize_master_if0_m  (arsize_master_if0),
  .arburst_master_if0_m (arburst_master_if0),
  .arlock_master_if0_m  (arlock_master_if0),
  .arcache_master_if0_m (arcache_master_if0),
  .arprot_master_if0_m  (arprot_master_if0),
  .arvalid_master_if0_m (arvalid_master_if0),
  .arready_master_if0_m (arready_master_if0),
  .rid_master_if0_m     (rid_master_if0),
  .rdata_master_if0_m   (rdata_master_if0),
  .rresp_master_if0_m   (rresp_master_if0),
  .rlast_master_if0_m   (rlast_master_if0),
  .rvalid_master_if0_m  (rvalid_master_if0),
  .rready_master_if0_m  (rready_master_if0),
  .awuser_master_if0_m  (awuser_master_if0),
  .aruser_master_if0_m  (aruser_master_if0),
  .awid_master_if0_s    (awid_bm0_master_if0_master_if0_s),
  .awaddr_master_if0_s  (awaddr_bm0_master_if0_master_if0_s),
  .awlen_master_if0_s   (awlen_bm0_master_if0_master_if0_s),
  .awsize_master_if0_s  (awsize_bm0_master_if0_master_if0_s),
  .awburst_master_if0_s (awburst_bm0_master_if0_master_if0_s),
  .awlock_master_if0_s  (awlock_bm0_master_if0_master_if0_s),
  .awcache_master_if0_s (awcache_bm0_master_if0_master_if0_s),
  .awprot_master_if0_s  (awprot_bm0_master_if0_master_if0_s),
  .awvalid_master_if0_s (awvalid_bm0_master_if0_master_if0_s),
  .awready_master_if0_s (awready_bm0_master_if0_master_if0_s),
  .wdata_master_if0_s   (wdata_bm0_master_if0_master_if0_s),
  .wstrb_master_if0_s   (wstrb_bm0_master_if0_master_if0_s),
  .wlast_master_if0_s   (wlast_bm0_master_if0_master_if0_s),
  .wvalid_master_if0_s  (wvalid_bm0_master_if0_master_if0_s),
  .wready_master_if0_s  (wready_bm0_master_if0_master_if0_s),
  .bid_master_if0_s     (bid_bm0_master_if0_master_if0_s),
  .bresp_master_if0_s   (bresp_bm0_master_if0_master_if0_s),
  .bvalid_master_if0_s  (bvalid_bm0_master_if0_master_if0_s),
  .bready_master_if0_s  (bready_bm0_master_if0_master_if0_s),
  .arid_master_if0_s    (arid_bm0_master_if0_master_if0_s),
  .araddr_master_if0_s  (araddr_bm0_master_if0_master_if0_s),
  .arlen_master_if0_s   (arlen_bm0_master_if0_master_if0_s),
  .arsize_master_if0_s  (arsize_bm0_master_if0_master_if0_s),
  .arburst_master_if0_s (arburst_bm0_master_if0_master_if0_s),
  .arlock_master_if0_s  (arlock_bm0_master_if0_master_if0_s),
  .arcache_master_if0_s (arcache_bm0_master_if0_master_if0_s),
  .arprot_master_if0_s  (arprot_bm0_master_if0_master_if0_s),
  .arvalid_master_if0_s (arvalid_bm0_master_if0_master_if0_s),
  .arready_master_if0_s (arready_bm0_master_if0_master_if0_s),
  .rid_master_if0_s     (rid_bm0_master_if0_master_if0_s),
  .rdata_master_if0_s   (rdata_bm0_master_if0_master_if0_s),
  .rresp_master_if0_s   (rresp_bm0_master_if0_master_if0_s),
  .rlast_master_if0_s   (rlast_bm0_master_if0_master_if0_s),
  .rvalid_master_if0_s  (rvalid_bm0_master_if0_master_if0_s),
  .rready_master_if0_s  (rready_bm0_master_if0_master_if0_s),
  .awuser_master_if0_s  (awuser_bm0_master_if0_master_if0_s),
  .aruser_master_if0_s  (aruser_bm0_master_if0_master_if0_s),
  .aclk                 (clk0clk),
  .aresetn              (clk0resetn)
);


nic400_amib_master_if1_secenc_f1     u_amib_master_if1 (
  .awaddr_master_if1_m  (awaddr_master_if1),
  .awlen_master_if1_m   (awlen_master_if1),
  .awsize_master_if1_m  (awsize_master_if1),
  .awburst_master_if1_m (awburst_master_if1),
  .awlock_master_if1_m  (awlock_master_if1),
  .awcache_master_if1_m (awcache_master_if1),
  .awprot_master_if1_m  (awprot_master_if1),
  .awvalid_master_if1_m (awvalid_master_if1),
  .awready_master_if1_m (awready_master_if1),
  .wdata_master_if1_m   (wdata_master_if1),
  .wstrb_master_if1_m   (wstrb_master_if1),
  .wlast_master_if1_m   (wlast_master_if1),
  .wvalid_master_if1_m  (wvalid_master_if1),
  .wready_master_if1_m  (wready_master_if1),
  .bresp_master_if1_m   (bresp_master_if1),
  .bvalid_master_if1_m  (bvalid_master_if1),
  .bready_master_if1_m  (bready_master_if1),
  .araddr_master_if1_m  (araddr_master_if1),
  .arlen_master_if1_m   (arlen_master_if1),
  .arsize_master_if1_m  (arsize_master_if1),
  .arburst_master_if1_m (arburst_master_if1),
  .arlock_master_if1_m  (arlock_master_if1),
  .arcache_master_if1_m (arcache_master_if1),
  .arprot_master_if1_m  (arprot_master_if1),
  .arvalid_master_if1_m (arvalid_master_if1),
  .arready_master_if1_m (arready_master_if1),
  .rdata_master_if1_m   (rdata_master_if1),
  .rresp_master_if1_m   (rresp_master_if1),
  .rlast_master_if1_m   (rlast_master_if1),
  .rvalid_master_if1_m  (rvalid_master_if1),
  .rready_master_if1_m  (rready_master_if1),
  .awid_master_if1_s    (awid_bm0_master_if1_master_if1_s),
  .awaddr_master_if1_s  (awaddr_bm0_master_if1_master_if1_s),
  .awlen_master_if1_s   (awlen_bm0_master_if1_master_if1_s),
  .awsize_master_if1_s  (awsize_bm0_master_if1_master_if1_s),
  .awburst_master_if1_s (awburst_bm0_master_if1_master_if1_s),
  .awlock_master_if1_s  (awlock_bm0_master_if1_master_if1_s),
  .awcache_master_if1_s (awcache_bm0_master_if1_master_if1_s),
  .awprot_master_if1_s  (awprot_bm0_master_if1_master_if1_s),
  .awvalid_master_if1_s (awvalid_bm0_master_if1_master_if1_s),
  .awready_master_if1_s (awready_bm0_master_if1_master_if1_s),
  .wdata_master_if1_s   (wdata_bm0_master_if1_master_if1_s),
  .wstrb_master_if1_s   (wstrb_bm0_master_if1_master_if1_s),
  .wlast_master_if1_s   (wlast_bm0_master_if1_master_if1_s),
  .wvalid_master_if1_s  (wvalid_bm0_master_if1_master_if1_s),
  .wready_master_if1_s  (wready_bm0_master_if1_master_if1_s),
  .bid_master_if1_s     (bid_bm0_master_if1_master_if1_s),
  .bresp_master_if1_s   (bresp_bm0_master_if1_master_if1_s),
  .bvalid_master_if1_s  (bvalid_bm0_master_if1_master_if1_s),
  .bready_master_if1_s  (bready_bm0_master_if1_master_if1_s),
  .arid_master_if1_s    (arid_bm0_master_if1_master_if1_s),
  .araddr_master_if1_s  (araddr_bm0_master_if1_master_if1_s),
  .arlen_master_if1_s   (arlen_bm0_master_if1_master_if1_s),
  .arsize_master_if1_s  (arsize_bm0_master_if1_master_if1_s),
  .arburst_master_if1_s (arburst_bm0_master_if1_master_if1_s),
  .arlock_master_if1_s  (arlock_bm0_master_if1_master_if1_s),
  .arcache_master_if1_s (arcache_bm0_master_if1_master_if1_s),
  .arprot_master_if1_s  (arprot_bm0_master_if1_master_if1_s),
  .arvalid_master_if1_s (arvalid_bm0_master_if1_master_if1_s),
  .arready_master_if1_s (arready_bm0_master_if1_master_if1_s),
  .rid_master_if1_s     (rid_bm0_master_if1_master_if1_s),
  .rdata_master_if1_s   (rdata_bm0_master_if1_master_if1_s),
  .rresp_master_if1_s   (rresp_bm0_master_if1_master_if1_s),
  .rlast_master_if1_s   (rlast_bm0_master_if1_master_if1_s),
  .rvalid_master_if1_s  (rvalid_bm0_master_if1_master_if1_s),
  .rready_master_if1_s  (rready_bm0_master_if1_master_if1_s),
  .aclk                 (clk0clk),
  .aresetn              (clk0resetn)
);


nic400_amib_master_if2_secenc_f1     u_amib_master_if2 (
  .hsel_master_if2_m    (hselx_master_if2),
  .haddr_master_if2_m   (haddr_master_if2),
  .htrans_master_if2_m  (htrans_master_if2),
  .hwrite_master_if2_m  (hwrite_master_if2),
  .hsize_master_if2_m   (hsize_master_if2),
  .hburst_master_if2_m  (hburst_master_if2),
  .hprot_master_if2_m   (hprot_master_if2),
  .hwdata_master_if2_m  (hwdata_master_if2),
  .hrdata_master_if2_m  (hrdata_master_if2),
  .hready_master_if2_m  (hreadyout_master_if2),
  .hreadymux_master_if2_m (hready_master_if2),
  .hresp_master_if2_m   (hresp_master_if2),
  .hauser_master_if2_m  (hauser_master_if2),
  .awid_master_if2_s    (awid_bm0_master_if2_master_if2_s),
  .awaddr_master_if2_s  (awaddr_bm0_master_if2_master_if2_s),
  .awlen_master_if2_s   (awlen_bm0_master_if2_master_if2_s),
  .awsize_master_if2_s  (awsize_bm0_master_if2_master_if2_s),
  .awburst_master_if2_s (awburst_bm0_master_if2_master_if2_s),
  .awlock_master_if2_s  (awlock_bm0_master_if2_master_if2_s),
  .awcache_master_if2_s (awcache_bm0_master_if2_master_if2_s),
  .awprot_master_if2_s  (awprot_bm0_master_if2_master_if2_s),
  .awvalid_master_if2_s (awvalid_bm0_master_if2_master_if2_s),
  .awready_master_if2_s (awready_bm0_master_if2_master_if2_s),
  .wdata_master_if2_s   (wdata_bm0_master_if2_master_if2_s),
  .wstrb_master_if2_s   (wstrb_bm0_master_if2_master_if2_s),
  .wlast_master_if2_s   (wlast_bm0_master_if2_master_if2_s),
  .wvalid_master_if2_s  (wvalid_bm0_master_if2_master_if2_s),
  .wready_master_if2_s  (wready_bm0_master_if2_master_if2_s),
  .bid_master_if2_s     (bid_bm0_master_if2_master_if2_s),
  .bresp_master_if2_s   (bresp_bm0_master_if2_master_if2_s),
  .bvalid_master_if2_s  (bvalid_bm0_master_if2_master_if2_s),
  .bready_master_if2_s  (bready_bm0_master_if2_master_if2_s),
  .arid_master_if2_s    (arid_bm0_master_if2_master_if2_s),
  .araddr_master_if2_s  (araddr_bm0_master_if2_master_if2_s),
  .arlen_master_if2_s   (arlen_bm0_master_if2_master_if2_s),
  .arsize_master_if2_s  (arsize_bm0_master_if2_master_if2_s),
  .arburst_master_if2_s (arburst_bm0_master_if2_master_if2_s),
  .arlock_master_if2_s  (arlock_bm0_master_if2_master_if2_s),
  .arcache_master_if2_s (arcache_bm0_master_if2_master_if2_s),
  .arprot_master_if2_s  (arprot_bm0_master_if2_master_if2_s),
  .arvalid_master_if2_s (arvalid_bm0_master_if2_master_if2_s),
  .arready_master_if2_s (arready_bm0_master_if2_master_if2_s),
  .rid_master_if2_s     (rid_bm0_master_if2_master_if2_s),
  .rdata_master_if2_s   (rdata_bm0_master_if2_master_if2_s),
  .rresp_master_if2_s   (rresp_bm0_master_if2_master_if2_s),
  .rlast_master_if2_s   (rlast_bm0_master_if2_master_if2_s),
  .rvalid_master_if2_s  (rvalid_bm0_master_if2_master_if2_s),
  .rready_master_if2_s  (rready_bm0_master_if2_master_if2_s),
  .awuser_master_if2_s  (awuser_bm0_master_if2_master_if2_s),
  .aruser_master_if2_s  (aruser_bm0_master_if2_master_if2_s),
  .aclk                 (clk0clk),
  .aresetn              (clk0resetn)
);


nic400_amib_master_if3_secenc_f1     u_amib_master_if3 (
  .haddr_master_if3_m   (haddr_master_if3),
  .htrans_master_if3_m  (htrans_master_if3),
  .hwrite_master_if3_m  (hwrite_master_if3),
  .hsize_master_if3_m   (hsize_master_if3),
  .hburst_master_if3_m  (hburst_master_if3),
  .hprot_master_if3_m   (hprot_master_if3),
  .hwdata_master_if3_m  (hwdata_master_if3),
  .hrdata_master_if3_m  (hrdata_master_if3),
  .hready_master_if3_m  (hready_master_if3),
  .hresp_master_if3_m   (hresp_master_if3),
  .awid_master_if3_s    (awid_bm0_master_if3_master_if3_s),
  .awaddr_master_if3_s  (awaddr_bm0_master_if3_master_if3_s),
  .awlen_master_if3_s   (awlen_bm0_master_if3_master_if3_s),
  .awsize_master_if3_s  (awsize_bm0_master_if3_master_if3_s),
  .awburst_master_if3_s (awburst_bm0_master_if3_master_if3_s),
  .awlock_master_if3_s  (awlock_bm0_master_if3_master_if3_s),
  .awcache_master_if3_s (awcache_bm0_master_if3_master_if3_s),
  .awprot_master_if3_s  (awprot_bm0_master_if3_master_if3_s),
  .awvalid_master_if3_s (awvalid_bm0_master_if3_master_if3_s),
  .awready_master_if3_s (awready_bm0_master_if3_master_if3_s),
  .wdata_master_if3_s   (wdata_bm0_master_if3_master_if3_s),
  .wstrb_master_if3_s   (wstrb_bm0_master_if3_master_if3_s),
  .wlast_master_if3_s   (wlast_bm0_master_if3_master_if3_s),
  .wvalid_master_if3_s  (wvalid_bm0_master_if3_master_if3_s),
  .wready_master_if3_s  (wready_bm0_master_if3_master_if3_s),
  .bid_master_if3_s     (bid_bm0_master_if3_master_if3_s),
  .bresp_master_if3_s   (bresp_bm0_master_if3_master_if3_s),
  .bvalid_master_if3_s  (bvalid_bm0_master_if3_master_if3_s),
  .bready_master_if3_s  (bready_bm0_master_if3_master_if3_s),
  .arid_master_if3_s    (arid_bm0_master_if3_master_if3_s),
  .araddr_master_if3_s  (araddr_bm0_master_if3_master_if3_s),
  .arlen_master_if3_s   (arlen_bm0_master_if3_master_if3_s),
  .arsize_master_if3_s  (arsize_bm0_master_if3_master_if3_s),
  .arburst_master_if3_s (arburst_bm0_master_if3_master_if3_s),
  .arlock_master_if3_s  (arlock_bm0_master_if3_master_if3_s),
  .arcache_master_if3_s (arcache_bm0_master_if3_master_if3_s),
  .arprot_master_if3_s  (arprot_bm0_master_if3_master_if3_s),
  .arvalid_master_if3_s (arvalid_bm0_master_if3_master_if3_s),
  .arready_master_if3_s (arready_bm0_master_if3_master_if3_s),
  .rid_master_if3_s     (rid_bm0_master_if3_master_if3_s),
  .rdata_master_if3_s   (rdata_bm0_master_if3_master_if3_s),
  .rresp_master_if3_s   (rresp_bm0_master_if3_master_if3_s),
  .rlast_master_if3_s   (rlast_bm0_master_if3_master_if3_s),
  .rvalid_master_if3_s  (rvalid_bm0_master_if3_master_if3_s),
  .rready_master_if3_s  (rready_bm0_master_if3_master_if3_s),
  .aclk                 (clk0clk),
  .aresetn              (clk0resetn)
);


nic400_asib_slave_if0_secenc_f1     u_asib_slave_if0 (
  .awid_slave_if0_m     (awid_slave_if0_bm0_axi_s_0),
  .awaddr_slave_if0_m   (awaddr_slave_if0_bm0_axi_s_0),
  .awlen_slave_if0_m    (awlen_slave_if0_bm0_axi_s_0),
  .awsize_slave_if0_m   (awsize_slave_if0_bm0_axi_s_0),
  .awburst_slave_if0_m  (awburst_slave_if0_bm0_axi_s_0),
  .awlock_slave_if0_m   (awlock_slave_if0_bm0_axi_s_0),
  .awcache_slave_if0_m  (awcache_slave_if0_bm0_axi_s_0),
  .awprot_slave_if0_m   (awprot_slave_if0_bm0_axi_s_0),
  .awvalid_slave_if0_m  (awvalid_slave_if0_bm0_axi_s_0),
  .awvalid_vect_slave_if0_m (awvalid_vect_slave_if0_bm0_axi_s_0),
  .awready_slave_if0_m  (awready_slave_if0_bm0_axi_s_0),
  .wdata_slave_if0_m    (wdata_slave_if0_bm0_axi_s_0),
  .wstrb_slave_if0_m    (wstrb_slave_if0_bm0_axi_s_0),
  .wlast_slave_if0_m    (wlast_slave_if0_bm0_axi_s_0),
  .wvalid_slave_if0_m   (wvalid_slave_if0_bm0_axi_s_0),
  .wready_slave_if0_m   (wready_slave_if0_bm0_axi_s_0),
  .bid_slave_if0_m      (bid_slave_if0_bm0_axi_s_0),
  .bresp_slave_if0_m    (bresp_slave_if0_bm0_axi_s_0),
  .bvalid_slave_if0_m   (bvalid_slave_if0_bm0_axi_s_0),
  .bready_slave_if0_m   (bready_slave_if0_bm0_axi_s_0),
  .arid_slave_if0_m     (arid_slave_if0_bm0_axi_s_0),
  .araddr_slave_if0_m   (araddr_slave_if0_bm0_axi_s_0),
  .arlen_slave_if0_m    (arlen_slave_if0_bm0_axi_s_0),
  .arsize_slave_if0_m   (arsize_slave_if0_bm0_axi_s_0),
  .arburst_slave_if0_m  (arburst_slave_if0_bm0_axi_s_0),
  .arlock_slave_if0_m   (arlock_slave_if0_bm0_axi_s_0),
  .arcache_slave_if0_m  (arcache_slave_if0_bm0_axi_s_0),
  .arprot_slave_if0_m   (arprot_slave_if0_bm0_axi_s_0),
  .arvalid_slave_if0_m  (arvalid_slave_if0_bm0_axi_s_0),
  .arvalid_vect_slave_if0_m (arvalid_vect_slave_if0_bm0_axi_s_0),
  .arready_slave_if0_m  (arready_slave_if0_bm0_axi_s_0),
  .rid_slave_if0_m      (rid_slave_if0_bm0_axi_s_0),
  .rdata_slave_if0_m    (rdata_slave_if0_bm0_axi_s_0),
  .rresp_slave_if0_m    (rresp_slave_if0_bm0_axi_s_0),
  .rlast_slave_if0_m    (rlast_slave_if0_bm0_axi_s_0),
  .rvalid_slave_if0_m   (rvalid_slave_if0_bm0_axi_s_0),
  .rready_slave_if0_m   (rready_slave_if0_bm0_axi_s_0),
  .awqv_slave_if0_m     (awqv_slave_if0_bm0_axi_s_0),
  .arqv_slave_if0_m     (arqv_slave_if0_bm0_axi_s_0),
  .aclk                 (clk0clk),
  .aresetn              (clk0resetn),
  .haddr_slave_if0_s    (haddr_slave_if0),
  .htrans_slave_if0_s   (htrans_slave_if0),
  .hwrite_slave_if0_s   (hwrite_slave_if0),
  .hsize_slave_if0_s    (hsize_slave_if0),
  .hburst_slave_if0_s   (hburst_slave_if0),
  .hprot_slave_if0_s    (hprot_slave_if0),
  .hwdata_slave_if0_s   (hwdata_slave_if0),
  .hrdata_slave_if0_s   (hrdata_slave_if0),
  .hready_slave_if0_s   (hready_slave_if0),
  .hresp_slave_if0_s    (hresp_slave_if0)
);


nic400_asib_slave_if1_secenc_f1     u_asib_slave_if1 (
  .awid_slave_if1_m     (awid_slave_if1_bm0_axi_s_1),
  .awaddr_slave_if1_m   (awaddr_slave_if1_bm0_axi_s_1),
  .awlen_slave_if1_m    (awlen_slave_if1_bm0_axi_s_1),
  .awsize_slave_if1_m   (awsize_slave_if1_bm0_axi_s_1),
  .awburst_slave_if1_m  (awburst_slave_if1_bm0_axi_s_1),
  .awlock_slave_if1_m   (awlock_slave_if1_bm0_axi_s_1),
  .awcache_slave_if1_m  (awcache_slave_if1_bm0_axi_s_1),
  .awprot_slave_if1_m   (awprot_slave_if1_bm0_axi_s_1),
  .awvalid_slave_if1_m  (awvalid_slave_if1_bm0_axi_s_1),
  .awvalid_vect_slave_if1_m (awvalid_vect_slave_if1_bm0_axi_s_1),
  .awready_slave_if1_m  (awready_slave_if1_bm0_axi_s_1),
  .wdata_slave_if1_m    (wdata_slave_if1_bm0_axi_s_1),
  .wstrb_slave_if1_m    (wstrb_slave_if1_bm0_axi_s_1),
  .wlast_slave_if1_m    (wlast_slave_if1_bm0_axi_s_1),
  .wvalid_slave_if1_m   (wvalid_slave_if1_bm0_axi_s_1),
  .wready_slave_if1_m   (wready_slave_if1_bm0_axi_s_1),
  .bid_slave_if1_m      (bid_slave_if1_bm0_axi_s_1),
  .bresp_slave_if1_m    (bresp_slave_if1_bm0_axi_s_1),
  .bvalid_slave_if1_m   (bvalid_slave_if1_bm0_axi_s_1),
  .bready_slave_if1_m   (bready_slave_if1_bm0_axi_s_1),
  .arid_slave_if1_m     (arid_slave_if1_bm0_axi_s_1),
  .araddr_slave_if1_m   (araddr_slave_if1_bm0_axi_s_1),
  .arlen_slave_if1_m    (arlen_slave_if1_bm0_axi_s_1),
  .arsize_slave_if1_m   (arsize_slave_if1_bm0_axi_s_1),
  .arburst_slave_if1_m  (arburst_slave_if1_bm0_axi_s_1),
  .arlock_slave_if1_m   (arlock_slave_if1_bm0_axi_s_1),
  .arcache_slave_if1_m  (arcache_slave_if1_bm0_axi_s_1),
  .arprot_slave_if1_m   (arprot_slave_if1_bm0_axi_s_1),
  .arvalid_slave_if1_m  (arvalid_slave_if1_bm0_axi_s_1),
  .arvalid_vect_slave_if1_m (arvalid_vect_slave_if1_bm0_axi_s_1),
  .arready_slave_if1_m  (arready_slave_if1_bm0_axi_s_1),
  .rid_slave_if1_m      (rid_slave_if1_bm0_axi_s_1),
  .rdata_slave_if1_m    (rdata_slave_if1_bm0_axi_s_1),
  .rresp_slave_if1_m    (rresp_slave_if1_bm0_axi_s_1),
  .rlast_slave_if1_m    (rlast_slave_if1_bm0_axi_s_1),
  .rvalid_slave_if1_m   (rvalid_slave_if1_bm0_axi_s_1),
  .rready_slave_if1_m   (rready_slave_if1_bm0_axi_s_1),
  .awuser_slave_if1_m   (awuser_slave_if1_bm0_axi_s_1),
  .aruser_slave_if1_m   (aruser_slave_if1_bm0_axi_s_1),
  .awqv_slave_if1_m     (awqv_slave_if1_bm0_axi_s_1),
  .arqv_slave_if1_m     (arqv_slave_if1_bm0_axi_s_1),
  .aclk                 (clk0clk),
  .aresetn              (clk0resetn),
  .haddr_slave_if1_s    (haddr_slave_if1),
  .htrans_slave_if1_s   (htrans_slave_if1),
  .hwrite_slave_if1_s   (hwrite_slave_if1),
  .hsize_slave_if1_s    (hsize_slave_if1),
  .hburst_slave_if1_s   (hburst_slave_if1),
  .hprot_slave_if1_s    (hprot_slave_if1),
  .hwdata_slave_if1_s   (hwdata_slave_if1),
  .hselx_slave_if1_s    (hselx_slave_if1),
  .hrdata_slave_if1_s   (hrdata_slave_if1),
  .hready_slave_if1_s   (hready_slave_if1),
  .hreadyout_slave_if1_s (hreadyout_slave_if1),
  .hresp_slave_if1_s    (hresp_slave_if1),
  .hauser_slave_if1_s   (hauser_slave_if1)
);


nic400_bm0_secenc_f1     u_busmatrix_bm0 (
  .awid_axi_m_0         (awid_bm0_master_if3_master_if3_s),
  .awaddr_axi_m_0       (awaddr_bm0_master_if3_master_if3_s),
  .awlen_axi_m_0        (awlen_bm0_master_if3_master_if3_s),
  .awsize_axi_m_0       (awsize_bm0_master_if3_master_if3_s),
  .awburst_axi_m_0      (awburst_bm0_master_if3_master_if3_s),
  .awlock_axi_m_0       (awlock_bm0_master_if3_master_if3_s),
  .awcache_axi_m_0      (awcache_bm0_master_if3_master_if3_s),
  .awprot_axi_m_0       (awprot_bm0_master_if3_master_if3_s),
  .awvalid_axi_m_0      (awvalid_bm0_master_if3_master_if3_s),
  .awvalid_vect_axi_m_0 (),
  .awready_axi_m_0      (awready_bm0_master_if3_master_if3_s),
  .wdata_axi_m_0        (wdata_bm0_master_if3_master_if3_s),
  .wstrb_axi_m_0        (wstrb_bm0_master_if3_master_if3_s),
  .wlast_axi_m_0        (wlast_bm0_master_if3_master_if3_s),
  .wvalid_axi_m_0       (wvalid_bm0_master_if3_master_if3_s),
  .wready_axi_m_0       (wready_bm0_master_if3_master_if3_s),
  .bid_axi_m_0          (bid_bm0_master_if3_master_if3_s),
  .bresp_axi_m_0        (bresp_bm0_master_if3_master_if3_s),
  .bvalid_axi_m_0       (bvalid_bm0_master_if3_master_if3_s),
  .bready_axi_m_0       (bready_bm0_master_if3_master_if3_s),
  .arid_axi_m_0         (arid_bm0_master_if3_master_if3_s),
  .araddr_axi_m_0       (araddr_bm0_master_if3_master_if3_s),
  .arlen_axi_m_0        (arlen_bm0_master_if3_master_if3_s),
  .arsize_axi_m_0       (arsize_bm0_master_if3_master_if3_s),
  .arburst_axi_m_0      (arburst_bm0_master_if3_master_if3_s),
  .arlock_axi_m_0       (arlock_bm0_master_if3_master_if3_s),
  .arcache_axi_m_0      (arcache_bm0_master_if3_master_if3_s),
  .arprot_axi_m_0       (arprot_bm0_master_if3_master_if3_s),
  .arvalid_axi_m_0      (arvalid_bm0_master_if3_master_if3_s),
  .arvalid_vect_axi_m_0 (),
  .arready_axi_m_0      (arready_bm0_master_if3_master_if3_s),
  .rid_axi_m_0          (rid_bm0_master_if3_master_if3_s),
  .rdata_axi_m_0        (rdata_bm0_master_if3_master_if3_s),
  .rresp_axi_m_0        (rresp_bm0_master_if3_master_if3_s),
  .rlast_axi_m_0        (rlast_bm0_master_if3_master_if3_s),
  .rvalid_axi_m_0       (rvalid_bm0_master_if3_master_if3_s),
  .rready_axi_m_0       (rready_bm0_master_if3_master_if3_s),
  .awuser_axi_m_0       (),
  .aruser_axi_m_0       (),
  .aw_qv_axi_m_0        (),
  .ar_qv_axi_m_0        (),
  .awid_axi_m_1         (awid_bm0_master_if1_master_if1_s),
  .awaddr_axi_m_1       (awaddr_bm0_master_if1_master_if1_s),
  .awlen_axi_m_1        (awlen_bm0_master_if1_master_if1_s),
  .awsize_axi_m_1       (awsize_bm0_master_if1_master_if1_s),
  .awburst_axi_m_1      (awburst_bm0_master_if1_master_if1_s),
  .awlock_axi_m_1       (awlock_bm0_master_if1_master_if1_s),
  .awcache_axi_m_1      (awcache_bm0_master_if1_master_if1_s),
  .awprot_axi_m_1       (awprot_bm0_master_if1_master_if1_s),
  .awvalid_axi_m_1      (awvalid_bm0_master_if1_master_if1_s),
  .awvalid_vect_axi_m_1 (),
  .awready_axi_m_1      (awready_bm0_master_if1_master_if1_s),
  .wdata_axi_m_1        (wdata_bm0_master_if1_master_if1_s),
  .wstrb_axi_m_1        (wstrb_bm0_master_if1_master_if1_s),
  .wlast_axi_m_1        (wlast_bm0_master_if1_master_if1_s),
  .wvalid_axi_m_1       (wvalid_bm0_master_if1_master_if1_s),
  .wready_axi_m_1       (wready_bm0_master_if1_master_if1_s),
  .bid_axi_m_1          (bid_bm0_master_if1_master_if1_s),
  .bresp_axi_m_1        (bresp_bm0_master_if1_master_if1_s),
  .bvalid_axi_m_1       (bvalid_bm0_master_if1_master_if1_s),
  .bready_axi_m_1       (bready_bm0_master_if1_master_if1_s),
  .arid_axi_m_1         (arid_bm0_master_if1_master_if1_s),
  .araddr_axi_m_1       (araddr_bm0_master_if1_master_if1_s),
  .arlen_axi_m_1        (arlen_bm0_master_if1_master_if1_s),
  .arsize_axi_m_1       (arsize_bm0_master_if1_master_if1_s),
  .arburst_axi_m_1      (arburst_bm0_master_if1_master_if1_s),
  .arlock_axi_m_1       (arlock_bm0_master_if1_master_if1_s),
  .arcache_axi_m_1      (arcache_bm0_master_if1_master_if1_s),
  .arprot_axi_m_1       (arprot_bm0_master_if1_master_if1_s),
  .arvalid_axi_m_1      (arvalid_bm0_master_if1_master_if1_s),
  .arvalid_vect_axi_m_1 (),
  .arready_axi_m_1      (arready_bm0_master_if1_master_if1_s),
  .rid_axi_m_1          (rid_bm0_master_if1_master_if1_s),
  .rdata_axi_m_1        (rdata_bm0_master_if1_master_if1_s),
  .rresp_axi_m_1        (rresp_bm0_master_if1_master_if1_s),
  .rlast_axi_m_1        (rlast_bm0_master_if1_master_if1_s),
  .rvalid_axi_m_1       (rvalid_bm0_master_if1_master_if1_s),
  .rready_axi_m_1       (rready_bm0_master_if1_master_if1_s),
  .awuser_axi_m_1       (),
  .aruser_axi_m_1       (),
  .aw_qv_axi_m_1        (),
  .ar_qv_axi_m_1        (),
  .awid_axi_m_2         (awid_bm0_master_if0_master_if0_s),
  .awaddr_axi_m_2       (awaddr_bm0_master_if0_master_if0_s),
  .awlen_axi_m_2        (awlen_bm0_master_if0_master_if0_s),
  .awsize_axi_m_2       (awsize_bm0_master_if0_master_if0_s),
  .awburst_axi_m_2      (awburst_bm0_master_if0_master_if0_s),
  .awlock_axi_m_2       (awlock_bm0_master_if0_master_if0_s),
  .awcache_axi_m_2      (awcache_bm0_master_if0_master_if0_s),
  .awprot_axi_m_2       (awprot_bm0_master_if0_master_if0_s),
  .awvalid_axi_m_2      (awvalid_bm0_master_if0_master_if0_s),
  .awvalid_vect_axi_m_2 (),
  .awready_axi_m_2      (awready_bm0_master_if0_master_if0_s),
  .wdata_axi_m_2        (wdata_bm0_master_if0_master_if0_s),
  .wstrb_axi_m_2        (wstrb_bm0_master_if0_master_if0_s),
  .wlast_axi_m_2        (wlast_bm0_master_if0_master_if0_s),
  .wvalid_axi_m_2       (wvalid_bm0_master_if0_master_if0_s),
  .wready_axi_m_2       (wready_bm0_master_if0_master_if0_s),
  .bid_axi_m_2          (bid_bm0_master_if0_master_if0_s),
  .bresp_axi_m_2        (bresp_bm0_master_if0_master_if0_s),
  .bvalid_axi_m_2       (bvalid_bm0_master_if0_master_if0_s),
  .bready_axi_m_2       (bready_bm0_master_if0_master_if0_s),
  .arid_axi_m_2         (arid_bm0_master_if0_master_if0_s),
  .araddr_axi_m_2       (araddr_bm0_master_if0_master_if0_s),
  .arlen_axi_m_2        (arlen_bm0_master_if0_master_if0_s),
  .arsize_axi_m_2       (arsize_bm0_master_if0_master_if0_s),
  .arburst_axi_m_2      (arburst_bm0_master_if0_master_if0_s),
  .arlock_axi_m_2       (arlock_bm0_master_if0_master_if0_s),
  .arcache_axi_m_2      (arcache_bm0_master_if0_master_if0_s),
  .arprot_axi_m_2       (arprot_bm0_master_if0_master_if0_s),
  .arvalid_axi_m_2      (arvalid_bm0_master_if0_master_if0_s),
  .arvalid_vect_axi_m_2 (),
  .arready_axi_m_2      (arready_bm0_master_if0_master_if0_s),
  .rid_axi_m_2          (rid_bm0_master_if0_master_if0_s),
  .rdata_axi_m_2        (rdata_bm0_master_if0_master_if0_s),
  .rresp_axi_m_2        (rresp_bm0_master_if0_master_if0_s),
  .rlast_axi_m_2        (rlast_bm0_master_if0_master_if0_s),
  .rvalid_axi_m_2       (rvalid_bm0_master_if0_master_if0_s),
  .rready_axi_m_2       (rready_bm0_master_if0_master_if0_s),
  .awuser_axi_m_2       (awuser_bm0_master_if0_master_if0_s),
  .aruser_axi_m_2       (aruser_bm0_master_if0_master_if0_s),
  .aw_qv_axi_m_2        (),
  .ar_qv_axi_m_2        (),
  .awid_axi_m_3         (awid_bm0_master_if2_master_if2_s),
  .awaddr_axi_m_3       (awaddr_bm0_master_if2_master_if2_s),
  .awlen_axi_m_3        (awlen_bm0_master_if2_master_if2_s),
  .awsize_axi_m_3       (awsize_bm0_master_if2_master_if2_s),
  .awburst_axi_m_3      (awburst_bm0_master_if2_master_if2_s),
  .awlock_axi_m_3       (awlock_bm0_master_if2_master_if2_s),
  .awcache_axi_m_3      (awcache_bm0_master_if2_master_if2_s),
  .awprot_axi_m_3       (awprot_bm0_master_if2_master_if2_s),
  .awvalid_axi_m_3      (awvalid_bm0_master_if2_master_if2_s),
  .awvalid_vect_axi_m_3 (),
  .awready_axi_m_3      (awready_bm0_master_if2_master_if2_s),
  .wdata_axi_m_3        (wdata_bm0_master_if2_master_if2_s),
  .wstrb_axi_m_3        (wstrb_bm0_master_if2_master_if2_s),
  .wlast_axi_m_3        (wlast_bm0_master_if2_master_if2_s),
  .wvalid_axi_m_3       (wvalid_bm0_master_if2_master_if2_s),
  .wready_axi_m_3       (wready_bm0_master_if2_master_if2_s),
  .bid_axi_m_3          (bid_bm0_master_if2_master_if2_s),
  .bresp_axi_m_3        (bresp_bm0_master_if2_master_if2_s),
  .bvalid_axi_m_3       (bvalid_bm0_master_if2_master_if2_s),
  .bready_axi_m_3       (bready_bm0_master_if2_master_if2_s),
  .arid_axi_m_3         (arid_bm0_master_if2_master_if2_s),
  .araddr_axi_m_3       (araddr_bm0_master_if2_master_if2_s),
  .arlen_axi_m_3        (arlen_bm0_master_if2_master_if2_s),
  .arsize_axi_m_3       (arsize_bm0_master_if2_master_if2_s),
  .arburst_axi_m_3      (arburst_bm0_master_if2_master_if2_s),
  .arlock_axi_m_3       (arlock_bm0_master_if2_master_if2_s),
  .arcache_axi_m_3      (arcache_bm0_master_if2_master_if2_s),
  .arprot_axi_m_3       (arprot_bm0_master_if2_master_if2_s),
  .arvalid_axi_m_3      (arvalid_bm0_master_if2_master_if2_s),
  .arvalid_vect_axi_m_3 (),
  .arready_axi_m_3      (arready_bm0_master_if2_master_if2_s),
  .rid_axi_m_3          (rid_bm0_master_if2_master_if2_s),
  .rdata_axi_m_3        (rdata_bm0_master_if2_master_if2_s),
  .rresp_axi_m_3        (rresp_bm0_master_if2_master_if2_s),
  .rlast_axi_m_3        (rlast_bm0_master_if2_master_if2_s),
  .rvalid_axi_m_3       (rvalid_bm0_master_if2_master_if2_s),
  .rready_axi_m_3       (rready_bm0_master_if2_master_if2_s),
  .awuser_axi_m_3       (awuser_bm0_master_if2_master_if2_s),
  .aruser_axi_m_3       (aruser_bm0_master_if2_master_if2_s),
  .aw_qv_axi_m_3        (),
  .ar_qv_axi_m_3        (),
  .awid_axi_m_4         (awid_bm0_ds_1_axi_s_0),
  .awaddr_axi_m_4       (),
  .awlen_axi_m_4        (),
  .awsize_axi_m_4       (),
  .awburst_axi_m_4      (),
  .awlock_axi_m_4       (),
  .awcache_axi_m_4      (),
  .awprot_axi_m_4       (),
  .awvalid_axi_m_4      (awvalid_bm0_ds_1_axi_s_0),
  .awvalid_vect_axi_m_4 (),
  .awready_axi_m_4      (awready_bm0_ds_1_axi_s_0),
  .wdata_axi_m_4        (),
  .wstrb_axi_m_4        (),
  .wlast_axi_m_4        (wlast_bm0_ds_1_axi_s_0),
  .wvalid_axi_m_4       (wvalid_bm0_ds_1_axi_s_0),
  .wready_axi_m_4       (wready_bm0_ds_1_axi_s_0),
  .bid_axi_m_4          (bid_bm0_ds_1_axi_s_0),
  .bresp_axi_m_4        (bresp_bm0_ds_1_axi_s_0),
  .bvalid_axi_m_4       (bvalid_bm0_ds_1_axi_s_0),
  .bready_axi_m_4       (bready_bm0_ds_1_axi_s_0),
  .arid_axi_m_4         (arid_bm0_ds_1_axi_s_0),
  .araddr_axi_m_4       (),
  .arlen_axi_m_4        (arlen_bm0_ds_1_axi_s_0),
  .arsize_axi_m_4       (),
  .arburst_axi_m_4      (),
  .arlock_axi_m_4       (),
  .arcache_axi_m_4      (),
  .arprot_axi_m_4       (),
  .arvalid_axi_m_4      (arvalid_bm0_ds_1_axi_s_0),
  .arvalid_vect_axi_m_4 (),
  .arready_axi_m_4      (arready_bm0_ds_1_axi_s_0),
  .rid_axi_m_4          (rid_bm0_ds_1_axi_s_0),
  .rdata_axi_m_4        (32'b0),
  .rresp_axi_m_4        (rresp_bm0_ds_1_axi_s_0),
  .rlast_axi_m_4        (rlast_bm0_ds_1_axi_s_0),
  .rvalid_axi_m_4       (rvalid_bm0_ds_1_axi_s_0),
  .rready_axi_m_4       (rready_bm0_ds_1_axi_s_0),
  .awuser_axi_m_4       (),
  .aruser_axi_m_4       (),
  .aw_qv_axi_m_4        (),
  .ar_qv_axi_m_4        (),
  .aclk                 (clk0clk),
  .aresetn              (clk0resetn),
  .awid_axi_s_0         (awid_slave_if0_bm0_axi_s_0),
  .awaddr_axi_s_0       (awaddr_slave_if0_bm0_axi_s_0),
  .awlen_axi_s_0        (awlen_slave_if0_bm0_axi_s_0),
  .awsize_axi_s_0       (awsize_slave_if0_bm0_axi_s_0),
  .awburst_axi_s_0      (awburst_slave_if0_bm0_axi_s_0),
  .awlock_axi_s_0       (awlock_slave_if0_bm0_axi_s_0),
  .awcache_axi_s_0      (awcache_slave_if0_bm0_axi_s_0),
  .awprot_axi_s_0       (awprot_slave_if0_bm0_axi_s_0),
  .awvalid_axi_s_0      (awvalid_slave_if0_bm0_axi_s_0),
  .awvalid_vect_axi_s_0 (awvalid_vect_slave_if0_bm0_axi_s_0),
  .awready_axi_s_0      (awready_slave_if0_bm0_axi_s_0),
  .wdata_axi_s_0        (wdata_slave_if0_bm0_axi_s_0),
  .wstrb_axi_s_0        (wstrb_slave_if0_bm0_axi_s_0),
  .wlast_axi_s_0        (wlast_slave_if0_bm0_axi_s_0),
  .wvalid_axi_s_0       (wvalid_slave_if0_bm0_axi_s_0),
  .wready_axi_s_0       (wready_slave_if0_bm0_axi_s_0),
  .bid_axi_s_0          (bid_slave_if0_bm0_axi_s_0),
  .bresp_axi_s_0        (bresp_slave_if0_bm0_axi_s_0),
  .bvalid_axi_s_0       (bvalid_slave_if0_bm0_axi_s_0),
  .bready_axi_s_0       (bready_slave_if0_bm0_axi_s_0),
  .arid_axi_s_0         (arid_slave_if0_bm0_axi_s_0),
  .araddr_axi_s_0       (araddr_slave_if0_bm0_axi_s_0),
  .arlen_axi_s_0        (arlen_slave_if0_bm0_axi_s_0),
  .arsize_axi_s_0       (arsize_slave_if0_bm0_axi_s_0),
  .arburst_axi_s_0      (arburst_slave_if0_bm0_axi_s_0),
  .arlock_axi_s_0       (arlock_slave_if0_bm0_axi_s_0),
  .arcache_axi_s_0      (arcache_slave_if0_bm0_axi_s_0),
  .arprot_axi_s_0       (arprot_slave_if0_bm0_axi_s_0),
  .arvalid_axi_s_0      (arvalid_slave_if0_bm0_axi_s_0),
  .arvalid_vect_axi_s_0 (arvalid_vect_slave_if0_bm0_axi_s_0),
  .arready_axi_s_0      (arready_slave_if0_bm0_axi_s_0),
  .rid_axi_s_0          (rid_slave_if0_bm0_axi_s_0),
  .rdata_axi_s_0        (rdata_slave_if0_bm0_axi_s_0),
  .rresp_axi_s_0        (rresp_slave_if0_bm0_axi_s_0),
  .rlast_axi_s_0        (rlast_slave_if0_bm0_axi_s_0),
  .rvalid_axi_s_0       (rvalid_slave_if0_bm0_axi_s_0),
  .rready_axi_s_0       (rready_slave_if0_bm0_axi_s_0),
  .awuser_axi_s_0       (2'b0),
  .aruser_axi_s_0       (2'b0),
  .aw_qv_axi_s_0        (awqv_slave_if0_bm0_axi_s_0),
  .ar_qv_axi_s_0        (arqv_slave_if0_bm0_axi_s_0),
  .awid_axi_s_1         (awid_slave_if1_bm0_axi_s_1),
  .awaddr_axi_s_1       (awaddr_slave_if1_bm0_axi_s_1),
  .awlen_axi_s_1        (awlen_slave_if1_bm0_axi_s_1),
  .awsize_axi_s_1       (awsize_slave_if1_bm0_axi_s_1),
  .awburst_axi_s_1      (awburst_slave_if1_bm0_axi_s_1),
  .awlock_axi_s_1       (awlock_slave_if1_bm0_axi_s_1),
  .awcache_axi_s_1      (awcache_slave_if1_bm0_axi_s_1),
  .awprot_axi_s_1       (awprot_slave_if1_bm0_axi_s_1),
  .awvalid_axi_s_1      (awvalid_slave_if1_bm0_axi_s_1),
  .awvalid_vect_axi_s_1 (awvalid_vect_slave_if1_bm0_axi_s_1),
  .awready_axi_s_1      (awready_slave_if1_bm0_axi_s_1),
  .wdata_axi_s_1        (wdata_slave_if1_bm0_axi_s_1),
  .wstrb_axi_s_1        (wstrb_slave_if1_bm0_axi_s_1),
  .wlast_axi_s_1        (wlast_slave_if1_bm0_axi_s_1),
  .wvalid_axi_s_1       (wvalid_slave_if1_bm0_axi_s_1),
  .wready_axi_s_1       (wready_slave_if1_bm0_axi_s_1),
  .bid_axi_s_1          (bid_slave_if1_bm0_axi_s_1),
  .bresp_axi_s_1        (bresp_slave_if1_bm0_axi_s_1),
  .bvalid_axi_s_1       (bvalid_slave_if1_bm0_axi_s_1),
  .bready_axi_s_1       (bready_slave_if1_bm0_axi_s_1),
  .arid_axi_s_1         (arid_slave_if1_bm0_axi_s_1),
  .araddr_axi_s_1       (araddr_slave_if1_bm0_axi_s_1),
  .arlen_axi_s_1        (arlen_slave_if1_bm0_axi_s_1),
  .arsize_axi_s_1       (arsize_slave_if1_bm0_axi_s_1),
  .arburst_axi_s_1      (arburst_slave_if1_bm0_axi_s_1),
  .arlock_axi_s_1       (arlock_slave_if1_bm0_axi_s_1),
  .arcache_axi_s_1      (arcache_slave_if1_bm0_axi_s_1),
  .arprot_axi_s_1       (arprot_slave_if1_bm0_axi_s_1),
  .arvalid_axi_s_1      (arvalid_slave_if1_bm0_axi_s_1),
  .arvalid_vect_axi_s_1 (arvalid_vect_slave_if1_bm0_axi_s_1),
  .arready_axi_s_1      (arready_slave_if1_bm0_axi_s_1),
  .rid_axi_s_1          (rid_slave_if1_bm0_axi_s_1),
  .rdata_axi_s_1        (rdata_slave_if1_bm0_axi_s_1),
  .rresp_axi_s_1        (rresp_slave_if1_bm0_axi_s_1),
  .rlast_axi_s_1        (rlast_slave_if1_bm0_axi_s_1),
  .rvalid_axi_s_1       (rvalid_slave_if1_bm0_axi_s_1),
  .rready_axi_s_1       (rready_slave_if1_bm0_axi_s_1),
  .awuser_axi_s_1       (awuser_slave_if1_bm0_axi_s_1),
  .aruser_axi_s_1       (aruser_slave_if1_bm0_axi_s_1),
  .aw_qv_axi_s_1        (awqv_slave_if1_bm0_axi_s_1),
  .ar_qv_axi_s_1        (arqv_slave_if1_bm0_axi_s_1)
);


nic400_default_slave_ds_1_secenc_f1     u_default_slave_ds_1 (
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
  .aclk                 (clk0clk),
  .aresetn              (clk0resetn)
);



endmodule
