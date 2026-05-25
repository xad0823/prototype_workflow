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




module nic400_sse710_dbg3s1m (
  

  awid_dbg_axim,
  awaddr_dbg_axim,
  awlen_dbg_axim,
  awsize_dbg_axim,
  awburst_dbg_axim,
  awlock_dbg_axim,
  awcache_dbg_axim,
  awprot_dbg_axim,
  awvalid_dbg_axim,
  awready_dbg_axim,
  wdata_dbg_axim,
  wstrb_dbg_axim,
  wlast_dbg_axim,
  wvalid_dbg_axim,
  wready_dbg_axim,
  bid_dbg_axim,
  bresp_dbg_axim,
  bvalid_dbg_axim,
  bready_dbg_axim,
  arid_dbg_axim,
  araddr_dbg_axim,
  arlen_dbg_axim,
  arsize_dbg_axim,
  arburst_dbg_axim,
  arlock_dbg_axim,
  arcache_dbg_axim,
  arprot_dbg_axim,
  arvalid_dbg_axim,
  arready_dbg_axim,
  rid_dbg_axim,
  rdata_dbg_axim,
  rresp_dbg_axim,
  rlast_dbg_axim,
  rvalid_dbg_axim,
  rready_dbg_axim,
  awuser_dbg_axim,
  aruser_dbg_axim,
  

  awid_p0_axis,
  awaddr_p0_axis,
  awlen_p0_axis,
  awsize_p0_axis,
  awburst_p0_axis,
  awlock_p0_axis,
  awcache_p0_axis,
  awprot_p0_axis,
  awvalid_p0_axis,
  awready_p0_axis,
  wdata_p0_axis,
  wstrb_p0_axis,
  wlast_p0_axis,
  wvalid_p0_axis,
  wready_p0_axis,
  bid_p0_axis,
  bresp_p0_axis,
  bvalid_p0_axis,
  bready_p0_axis,
  arid_p0_axis,
  araddr_p0_axis,
  arlen_p0_axis,
  arsize_p0_axis,
  arburst_p0_axis,
  arlock_p0_axis,
  arcache_p0_axis,
  arprot_p0_axis,
  arvalid_p0_axis,
  arready_p0_axis,
  rid_p0_axis,
  rdata_p0_axis,
  rresp_p0_axis,
  rlast_p0_axis,
  rvalid_p0_axis,
  rready_p0_axis,
  awuser_p0_axis,
  aruser_p0_axis,
  

  awid_p1_axis,
  awaddr_p1_axis,
  awlen_p1_axis,
  awsize_p1_axis,
  awburst_p1_axis,
  awlock_p1_axis,
  awcache_p1_axis,
  awprot_p1_axis,
  awvalid_p1_axis,
  awready_p1_axis,
  wdata_p1_axis,
  wstrb_p1_axis,
  wlast_p1_axis,
  wvalid_p1_axis,
  wready_p1_axis,
  bid_p1_axis,
  bresp_p1_axis,
  bvalid_p1_axis,
  bready_p1_axis,
  arid_p1_axis,
  araddr_p1_axis,
  arlen_p1_axis,
  arsize_p1_axis,
  arburst_p1_axis,
  arlock_p1_axis,
  arcache_p1_axis,
  arprot_p1_axis,
  arvalid_p1_axis,
  arready_p1_axis,
  rid_p1_axis,
  rdata_p1_axis,
  rresp_p1_axis,
  rlast_p1_axis,
  rvalid_p1_axis,
  rready_p1_axis,
  awuser_p1_axis,
  aruser_p1_axis,
  

  awid_p2_axis,
  awaddr_p2_axis,
  awlen_p2_axis,
  awsize_p2_axis,
  awburst_p2_axis,
  awlock_p2_axis,
  awcache_p2_axis,
  awprot_p2_axis,
  awvalid_p2_axis,
  awready_p2_axis,
  wdata_p2_axis,
  wstrb_p2_axis,
  wlast_p2_axis,
  wvalid_p2_axis,
  wready_p2_axis,
  bid_p2_axis,
  bresp_p2_axis,
  bvalid_p2_axis,
  bready_p2_axis,
  arid_p2_axis,
  araddr_p2_axis,
  arlen_p2_axis,
  arsize_p2_axis,
  arburst_p2_axis,
  arlock_p2_axis,
  arcache_p2_axis,
  arprot_p2_axis,
  arvalid_p2_axis,
  arready_p2_axis,
  rid_p2_axis,
  rdata_p2_axis,
  rresp_p2_axis,
  rlast_p2_axis,
  rvalid_p2_axis,
  rready_p2_axis,
  awuser_p2_axis,
  aruser_p2_axis,
  

  cactive_cd_main,
  csysreq_cd_main,
  csysack_cd_main,


  mainclk,
  mainresetn

);






output [3:0]  awid_dbg_axim;
output [31:0] awaddr_dbg_axim;
output [7:0]  awlen_dbg_axim;
output [2:0]  awsize_dbg_axim;
output [1:0]  awburst_dbg_axim;
output        awlock_dbg_axim;
output [3:0]  awcache_dbg_axim;
output [2:0]  awprot_dbg_axim;
output        awvalid_dbg_axim;
input         awready_dbg_axim;
output [63:0] wdata_dbg_axim;
output [7:0]  wstrb_dbg_axim;
output        wlast_dbg_axim;
output        wvalid_dbg_axim;
input         wready_dbg_axim;
input  [3:0]  bid_dbg_axim;
input  [1:0]  bresp_dbg_axim;
input         bvalid_dbg_axim;
output        bready_dbg_axim;
output [3:0]  arid_dbg_axim;
output [31:0] araddr_dbg_axim;
output [7:0]  arlen_dbg_axim;
output [2:0]  arsize_dbg_axim;
output [1:0]  arburst_dbg_axim;
output        arlock_dbg_axim;
output [3:0]  arcache_dbg_axim;
output [2:0]  arprot_dbg_axim;
output        arvalid_dbg_axim;
input         arready_dbg_axim;
input  [3:0]  rid_dbg_axim;
input  [63:0] rdata_dbg_axim;
input  [1:0]  rresp_dbg_axim;
input         rlast_dbg_axim;
input         rvalid_dbg_axim;
output        rready_dbg_axim;
output [2:0]  awuser_dbg_axim;
output [2:0]  aruser_dbg_axim;


input  [1:0]  awid_p0_axis;
input  [31:0] awaddr_p0_axis;
input  [7:0]  awlen_p0_axis;
input  [2:0]  awsize_p0_axis;
input  [1:0]  awburst_p0_axis;
input         awlock_p0_axis;
input  [3:0]  awcache_p0_axis;
input  [2:0]  awprot_p0_axis;
input         awvalid_p0_axis;
output        awready_p0_axis;
input  [31:0] wdata_p0_axis;
input  [3:0]  wstrb_p0_axis;
input         wlast_p0_axis;
input         wvalid_p0_axis;
output        wready_p0_axis;
output [1:0]  bid_p0_axis;
output [1:0]  bresp_p0_axis;
output        bvalid_p0_axis;
input         bready_p0_axis;
input  [1:0]  arid_p0_axis;
input  [31:0] araddr_p0_axis;
input  [7:0]  arlen_p0_axis;
input  [2:0]  arsize_p0_axis;
input  [1:0]  arburst_p0_axis;
input         arlock_p0_axis;
input  [3:0]  arcache_p0_axis;
input  [2:0]  arprot_p0_axis;
input         arvalid_p0_axis;
output        arready_p0_axis;
output [1:0]  rid_p0_axis;
output [31:0] rdata_p0_axis;
output [1:0]  rresp_p0_axis;
output        rlast_p0_axis;
output        rvalid_p0_axis;
input         rready_p0_axis;
input  [2:0]  awuser_p0_axis;
input  [2:0]  aruser_p0_axis;


input  [1:0]  awid_p1_axis;
input  [31:0] awaddr_p1_axis;
input  [7:0]  awlen_p1_axis;
input  [2:0]  awsize_p1_axis;
input  [1:0]  awburst_p1_axis;
input         awlock_p1_axis;
input  [3:0]  awcache_p1_axis;
input  [2:0]  awprot_p1_axis;
input         awvalid_p1_axis;
output        awready_p1_axis;
input  [31:0] wdata_p1_axis;
input  [3:0]  wstrb_p1_axis;
input         wlast_p1_axis;
input         wvalid_p1_axis;
output        wready_p1_axis;
output [1:0]  bid_p1_axis;
output [1:0]  bresp_p1_axis;
output        bvalid_p1_axis;
input         bready_p1_axis;
input  [1:0]  arid_p1_axis;
input  [31:0] araddr_p1_axis;
input  [7:0]  arlen_p1_axis;
input  [2:0]  arsize_p1_axis;
input  [1:0]  arburst_p1_axis;
input         arlock_p1_axis;
input  [3:0]  arcache_p1_axis;
input  [2:0]  arprot_p1_axis;
input         arvalid_p1_axis;
output        arready_p1_axis;
output [1:0]  rid_p1_axis;
output [31:0] rdata_p1_axis;
output [1:0]  rresp_p1_axis;
output        rlast_p1_axis;
output        rvalid_p1_axis;
input         rready_p1_axis;
input  [2:0]  awuser_p1_axis;
input  [2:0]  aruser_p1_axis;


input  [1:0]  awid_p2_axis;
input  [31:0] awaddr_p2_axis;
input  [7:0]  awlen_p2_axis;
input  [2:0]  awsize_p2_axis;
input  [1:0]  awburst_p2_axis;
input         awlock_p2_axis;
input  [3:0]  awcache_p2_axis;
input  [2:0]  awprot_p2_axis;
input         awvalid_p2_axis;
output        awready_p2_axis;
input  [31:0] wdata_p2_axis;
input  [3:0]  wstrb_p2_axis;
input         wlast_p2_axis;
input         wvalid_p2_axis;
output        wready_p2_axis;
output [1:0]  bid_p2_axis;
output [1:0]  bresp_p2_axis;
output        bvalid_p2_axis;
input         bready_p2_axis;
input  [1:0]  arid_p2_axis;
input  [31:0] araddr_p2_axis;
input  [7:0]  arlen_p2_axis;
input  [2:0]  arsize_p2_axis;
input  [1:0]  arburst_p2_axis;
input         arlock_p2_axis;
input  [3:0]  arcache_p2_axis;
input  [2:0]  arprot_p2_axis;
input         arvalid_p2_axis;
output        arready_p2_axis;
output [1:0]  rid_p2_axis;
output [31:0] rdata_p2_axis;
output [1:0]  rresp_p2_axis;
output        rlast_p2_axis;
output        rvalid_p2_axis;
input         rready_p2_axis;
input  [2:0]  awuser_p2_axis;
input  [2:0]  aruser_p2_axis;


output        cactive_cd_main;
input         csysreq_cd_main;
output        csysack_cd_main;


input         mainclk;
input         mainresetn;




wire   [31:0]  araddr_dbg_axim;
wire   [1:0]   arburst_dbg_axim;
wire   [3:0]   arcache_dbg_axim;
wire   [3:0]   arid_dbg_axim;
wire   [7:0]   arlen_dbg_axim;
wire           arlock_dbg_axim;
wire   [2:0]   arprot_dbg_axim;
wire           arready_p0_axis;
wire           arready_p1_axis;
wire           arready_p2_axis;
wire   [2:0]   arsize_dbg_axim;
wire   [2:0]   aruser_dbg_axim;
wire           arvalid_dbg_axim;
wire   [31:0]  awaddr_dbg_axim;
wire   [1:0]   awburst_dbg_axim;
wire   [3:0]   awcache_dbg_axim;
wire   [3:0]   awid_dbg_axim;
wire   [7:0]   awlen_dbg_axim;
wire           awlock_dbg_axim;
wire   [2:0]   awprot_dbg_axim;
wire           awready_p0_axis;
wire           awready_p1_axis;
wire           awready_p2_axis;
wire   [2:0]   awsize_dbg_axim;
wire   [2:0]   awuser_dbg_axim;
wire           awvalid_dbg_axim;
wire   [1:0]   bid_p0_axis;
wire   [1:0]   bid_p1_axis;
wire   [1:0]   bid_p2_axis;
wire           bready_dbg_axim;
wire   [1:0]   bresp_p0_axis;
wire   [1:0]   bresp_p1_axis;
wire   [1:0]   bresp_p2_axis;
wire           bvalid_p0_axis;
wire           bvalid_p1_axis;
wire           bvalid_p2_axis;
wire           cactive_cd_main;
wire           csysack_cd_main;
wire   [31:0]  rdata_p0_axis;
wire   [31:0]  rdata_p1_axis;
wire   [31:0]  rdata_p2_axis;
wire   [1:0]   rid_p0_axis;
wire   [1:0]   rid_p1_axis;
wire   [1:0]   rid_p2_axis;
wire           rlast_p0_axis;
wire           rlast_p1_axis;
wire           rlast_p2_axis;
wire           rready_dbg_axim;
wire   [1:0]   rresp_p0_axis;
wire   [1:0]   rresp_p1_axis;
wire   [1:0]   rresp_p2_axis;
wire           rvalid_p0_axis;
wire           rvalid_p1_axis;
wire           rvalid_p2_axis;
wire   [63:0]  wdata_dbg_axim;
wire           wlast_dbg_axim;
wire           wready_p0_axis;
wire           wready_p1_axis;
wire           wready_p2_axis;
wire   [7:0]   wstrb_dbg_axim;
wire           wvalid_dbg_axim;
wire           arready_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire           awready_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [3:0]   bid_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [1:0]   bresp_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire           bvalid_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [63:0]  rdata_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [3:0]   rid_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire           rlast_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [1:0]   rresp_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire           rvalid_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire           wready_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [31:0]  araddr_p0_axis_p0_axis_ib_axi4_s;
wire   [1:0]   arburst_p0_axis_p0_axis_ib_axi4_s;
wire   [3:0]   arcache_p0_axis_p0_axis_ib_axi4_s;
wire   [1:0]   arid_p0_axis_p0_axis_ib_axi4_s;
wire   [7:0]   arlen_p0_axis_p0_axis_ib_axi4_s;
wire           arlock_p0_axis_p0_axis_ib_axi4_s;
wire   [2:0]   arprot_p0_axis_p0_axis_ib_axi4_s;
wire   [2:0]   arsize_p0_axis_p0_axis_ib_axi4_s;
wire   [2:0]   aruser_p0_axis_p0_axis_ib_axi4_s;
wire           arvalid_p0_axis_p0_axis_ib_axi4_s;
wire           arvalid_vect_p0_axis_p0_axis_ib_axi4_s;
wire   [31:0]  awaddr_p0_axis_p0_axis_ib_axi4_s;
wire   [1:0]   awburst_p0_axis_p0_axis_ib_axi4_s;
wire   [3:0]   awcache_p0_axis_p0_axis_ib_axi4_s;
wire   [1:0]   awid_p0_axis_p0_axis_ib_axi4_s;
wire   [7:0]   awlen_p0_axis_p0_axis_ib_axi4_s;
wire           awlock_p0_axis_p0_axis_ib_axi4_s;
wire   [2:0]   awprot_p0_axis_p0_axis_ib_axi4_s;
wire   [2:0]   awsize_p0_axis_p0_axis_ib_axi4_s;
wire   [2:0]   awuser_p0_axis_p0_axis_ib_axi4_s;
wire           awvalid_p0_axis_p0_axis_ib_axi4_s;
wire           awvalid_vect_p0_axis_p0_axis_ib_axi4_s;
wire           bready_p0_axis_p0_axis_ib_axi4_s;
wire           cactive_p0_axis_hcg;
wire           cactive_p0_axis_wakeup_hcg;
wire           rready_p0_axis_p0_axis_ib_axi4_s;
wire   [31:0]  wdata_p0_axis_p0_axis_ib_axi4_s;
wire           wlast_p0_axis_p0_axis_ib_axi4_s;
wire   [3:0]   wstrb_p0_axis_p0_axis_ib_axi4_s;
wire           wvalid_p0_axis_p0_axis_ib_axi4_s;
wire   [31:0]  araddr_p1_axis_p1_axis_ib_axi4_s;
wire   [1:0]   arburst_p1_axis_p1_axis_ib_axi4_s;
wire   [3:0]   arcache_p1_axis_p1_axis_ib_axi4_s;
wire   [1:0]   arid_p1_axis_p1_axis_ib_axi4_s;
wire   [7:0]   arlen_p1_axis_p1_axis_ib_axi4_s;
wire           arlock_p1_axis_p1_axis_ib_axi4_s;
wire   [2:0]   arprot_p1_axis_p1_axis_ib_axi4_s;
wire   [2:0]   arsize_p1_axis_p1_axis_ib_axi4_s;
wire   [2:0]   aruser_p1_axis_p1_axis_ib_axi4_s;
wire           arvalid_p1_axis_p1_axis_ib_axi4_s;
wire           arvalid_vect_p1_axis_p1_axis_ib_axi4_s;
wire   [31:0]  awaddr_p1_axis_p1_axis_ib_axi4_s;
wire   [1:0]   awburst_p1_axis_p1_axis_ib_axi4_s;
wire   [3:0]   awcache_p1_axis_p1_axis_ib_axi4_s;
wire   [1:0]   awid_p1_axis_p1_axis_ib_axi4_s;
wire   [7:0]   awlen_p1_axis_p1_axis_ib_axi4_s;
wire           awlock_p1_axis_p1_axis_ib_axi4_s;
wire   [2:0]   awprot_p1_axis_p1_axis_ib_axi4_s;
wire   [2:0]   awsize_p1_axis_p1_axis_ib_axi4_s;
wire   [2:0]   awuser_p1_axis_p1_axis_ib_axi4_s;
wire           awvalid_p1_axis_p1_axis_ib_axi4_s;
wire           awvalid_vect_p1_axis_p1_axis_ib_axi4_s;
wire           bready_p1_axis_p1_axis_ib_axi4_s;
wire           cactive_p1_axis_hcg;
wire           cactive_p1_axis_wakeup_hcg;
wire           rready_p1_axis_p1_axis_ib_axi4_s;
wire   [31:0]  wdata_p1_axis_p1_axis_ib_axi4_s;
wire           wlast_p1_axis_p1_axis_ib_axi4_s;
wire   [3:0]   wstrb_p1_axis_p1_axis_ib_axi4_s;
wire           wvalid_p1_axis_p1_axis_ib_axi4_s;
wire   [31:0]  araddr_p2_axis_switch0_axi_s_2;
wire   [1:0]   arburst_p2_axis_switch0_axi_s_2;
wire   [3:0]   arcache_p2_axis_switch0_axi_s_2;
wire   [3:0]   arid_p2_axis_switch0_axi_s_2;
wire   [7:0]   arlen_p2_axis_switch0_axi_s_2;
wire           arlock_p2_axis_switch0_axi_s_2;
wire   [2:0]   arprot_p2_axis_switch0_axi_s_2;
wire   [3:0]   arqv_p2_axis_switch0_axi_s_2;
wire   [2:0]   arsize_p2_axis_switch0_axi_s_2;
wire   [2:0]   aruser_p2_axis_switch0_axi_s_2;
wire           arvalid_p2_axis_switch0_axi_s_2;
wire           arvalid_vect_p2_axis_switch0_axi_s_2;
wire   [31:0]  awaddr_p2_axis_switch0_axi_s_2;
wire   [1:0]   awburst_p2_axis_switch0_axi_s_2;
wire   [3:0]   awcache_p2_axis_switch0_axi_s_2;
wire   [3:0]   awid_p2_axis_switch0_axi_s_2;
wire   [7:0]   awlen_p2_axis_switch0_axi_s_2;
wire           awlock_p2_axis_switch0_axi_s_2;
wire   [2:0]   awprot_p2_axis_switch0_axi_s_2;
wire   [3:0]   awqv_p2_axis_switch0_axi_s_2;
wire   [2:0]   awsize_p2_axis_switch0_axi_s_2;
wire   [2:0]   awuser_p2_axis_switch0_axi_s_2;
wire           awvalid_p2_axis_switch0_axi_s_2;
wire           awvalid_vect_p2_axis_switch0_axi_s_2;
wire           bready_p2_axis_switch0_axi_s_2;
wire           cactive_p2_axis_hcg;
wire           cactive_p2_axis_wakeup_hcg;
wire           rready_p2_axis_switch0_axi_s_2;
wire   [31:0]  wdata_p2_axis_switch0_axi_s_2;
wire           wlast_p2_axis_switch0_axi_s_2;
wire   [3:0]   wstrb_p2_axis_switch0_axi_s_2;
wire           wvalid_p2_axis_switch0_axi_s_2;
wire   [31:0]  araddr_switch0_dbg_axim_ib_axi4_s;
wire   [1:0]   arburst_switch0_dbg_axim_ib_axi4_s;
wire   [3:0]   arcache_switch0_dbg_axim_ib_axi4_s;
wire   [3:0]   arid_switch0_dbg_axim_ib_axi4_s;
wire   [7:0]   arlen_switch0_dbg_axim_ib_axi4_s;
wire           arlock_switch0_dbg_axim_ib_axi4_s;
wire   [2:0]   arprot_switch0_dbg_axim_ib_axi4_s;
wire           arready_p0_axis_ib_switch0_axi_s_0;
wire           arready_p1_axis_ib_switch0_axi_s_1;
wire           arready_p2_axis_switch0_axi_s_2;
wire   [2:0]   arsize_switch0_dbg_axim_ib_axi4_s;
wire   [2:0]   aruser_switch0_dbg_axim_ib_axi4_s;
wire           arvalid_switch0_dbg_axim_ib_axi4_s;
wire   [31:0]  awaddr_switch0_dbg_axim_ib_axi4_s;
wire   [1:0]   awburst_switch0_dbg_axim_ib_axi4_s;
wire   [3:0]   awcache_switch0_dbg_axim_ib_axi4_s;
wire   [3:0]   awid_switch0_dbg_axim_ib_axi4_s;
wire   [7:0]   awlen_switch0_dbg_axim_ib_axi4_s;
wire           awlock_switch0_dbg_axim_ib_axi4_s;
wire   [2:0]   awprot_switch0_dbg_axim_ib_axi4_s;
wire           awready_p0_axis_ib_switch0_axi_s_0;
wire           awready_p1_axis_ib_switch0_axi_s_1;
wire           awready_p2_axis_switch0_axi_s_2;
wire   [2:0]   awsize_switch0_dbg_axim_ib_axi4_s;
wire   [2:0]   awuser_switch0_dbg_axim_ib_axi4_s;
wire           awvalid_switch0_dbg_axim_ib_axi4_s;
wire   [3:0]   bid_p0_axis_ib_switch0_axi_s_0;
wire   [3:0]   bid_p1_axis_ib_switch0_axi_s_1;
wire   [3:0]   bid_p2_axis_switch0_axi_s_2;
wire           bready_switch0_dbg_axim_ib_axi4_s;
wire   [1:0]   bresp_p0_axis_ib_switch0_axi_s_0;
wire   [1:0]   bresp_p1_axis_ib_switch0_axi_s_1;
wire   [1:0]   bresp_p2_axis_switch0_axi_s_2;
wire           bvalid_p0_axis_ib_switch0_axi_s_0;
wire           bvalid_p1_axis_ib_switch0_axi_s_1;
wire           bvalid_p2_axis_switch0_axi_s_2;
wire   [31:0]  rdata_p0_axis_ib_switch0_axi_s_0;
wire   [31:0]  rdata_p1_axis_ib_switch0_axi_s_1;
wire   [31:0]  rdata_p2_axis_switch0_axi_s_2;
wire   [3:0]   rid_p0_axis_ib_switch0_axi_s_0;
wire   [3:0]   rid_p1_axis_ib_switch0_axi_s_1;
wire   [3:0]   rid_p2_axis_switch0_axi_s_2;
wire           rlast_p0_axis_ib_switch0_axi_s_0;
wire           rlast_p1_axis_ib_switch0_axi_s_1;
wire           rlast_p2_axis_switch0_axi_s_2;
wire           rready_switch0_dbg_axim_ib_axi4_s;
wire   [1:0]   rresp_p0_axis_ib_switch0_axi_s_0;
wire   [1:0]   rresp_p1_axis_ib_switch0_axi_s_1;
wire   [1:0]   rresp_p2_axis_switch0_axi_s_2;
wire           rvalid_p0_axis_ib_switch0_axi_s_0;
wire           rvalid_p1_axis_ib_switch0_axi_s_1;
wire           rvalid_p2_axis_switch0_axi_s_2;
wire   [31:0]  wdata_switch0_dbg_axim_ib_axi4_s;
wire           wlast_switch0_dbg_axim_ib_axi4_s;
wire           wready_p0_axis_ib_switch0_axi_s_0;
wire           wready_p1_axis_ib_switch0_axi_s_1;
wire           wready_p2_axis_switch0_axi_s_2;
wire   [3:0]   wstrb_switch0_dbg_axim_ib_axi4_s;
wire           wvalid_switch0_dbg_axim_ib_axi4_s;
wire           port_enable_p0_axis_port_enable_hcg;
wire           port_enable_p1_axis_port_enable_hcg;
wire           port_enable_p2_axis_port_enable_hcg;
wire           ar_ready_dbg_axim_ib_int;
wire   [31:0]  araddr_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [1:0]   arburst_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [3:0]   arcache_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [3:0]   arid_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [7:0]   arlen_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire           arlock_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [2:0]   arprot_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [2:0]   arsize_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [2:0]   aruser_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire           arvalid_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [2:0]   aw_rpntr_bin_dbg_axim_ib_int;
wire   [3:0]   aw_rpntr_gry_dbg_axim_ib_int;
wire   [31:0]  awaddr_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [1:0]   awburst_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [3:0]   awcache_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [3:0]   awid_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [7:0]   awlen_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire           awlock_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [2:0]   awprot_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [2:0]   awsize_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [2:0]   awuser_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire           awvalid_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [5:0]   b_data_dbg_axim_ib_int;
wire   [4:0]   b_wpntr_gry_dbg_axim_ib_int;
wire           bready_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [70:0]  r_data_dbg_axim_ib_int;
wire           r_valid_dbg_axim_ib_int;
wire           rready_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [2:0]   w_rpntr_bin_dbg_axim_ib_int;
wire   [3:0]   w_rpntr_gry_dbg_axim_ib_int;
wire   [63:0]  wdata_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire           wlast_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [7:0]   wstrb_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire           wvalid_dbg_axim_ib_dbg_axim_expmstr1_axim_s;
wire   [59:0]  ar_data_dbg_axim_ib_int;
wire           ar_valid_dbg_axim_ib_int;
wire           arready_switch0_dbg_axim_ib_axi4_s;
wire   [59:0]  aw_data_dbg_axim_ib_int;
wire   [3:0]   aw_wpntr_gry_dbg_axim_ib_int;
wire           awready_switch0_dbg_axim_ib_axi4_s;
wire   [3:0]   b_rpntr_bin_dbg_axim_ib_int;
wire   [4:0]   b_rpntr_gry_dbg_axim_ib_int;
wire   [3:0]   bid_switch0_dbg_axim_ib_axi4_s;
wire   [1:0]   bresp_switch0_dbg_axim_ib_axi4_s;
wire           bvalid_switch0_dbg_axim_ib_axi4_s;
wire           r_ready_dbg_axim_ib_int;
wire   [31:0]  rdata_switch0_dbg_axim_ib_axi4_s;
wire   [3:0]   rid_switch0_dbg_axim_ib_axi4_s;
wire           rlast_switch0_dbg_axim_ib_axi4_s;
wire   [1:0]   rresp_switch0_dbg_axim_ib_axi4_s;
wire           rvalid_switch0_dbg_axim_ib_axi4_s;
wire   [72:0]  w_data_dbg_axim_ib_int;
wire   [3:0]   w_wpntr_gry_dbg_axim_ib_int;
wire           wready_switch0_dbg_axim_ib_axi4_s;
wire           ar_ready_p0_axis_ib_int;
wire   [31:0]  araddr_p0_axis_ib_switch0_axi_s_0;
wire   [1:0]   arburst_p0_axis_ib_switch0_axi_s_0;
wire   [3:0]   arcache_p0_axis_ib_switch0_axi_s_0;
wire   [3:0]   arid_p0_axis_ib_switch0_axi_s_0;
wire   [7:0]   arlen_p0_axis_ib_switch0_axi_s_0;
wire           arlock_p0_axis_ib_switch0_axi_s_0;
wire   [2:0]   arprot_p0_axis_ib_switch0_axi_s_0;
wire   [3:0]   arqv_p0_axis_ib_switch0_axi_s_0;
wire   [2:0]   arsize_p0_axis_ib_switch0_axi_s_0;
wire   [2:0]   aruser_p0_axis_ib_switch0_axi_s_0;
wire           arvalid_p0_axis_ib_switch0_axi_s_0;
wire           arvalid_vect_p0_axis_ib_switch0_axi_s_0;
wire   [2:0]   aw_rpntr_bin_p0_axis_ib_int;
wire   [3:0]   aw_rpntr_gry_p0_axis_ib_int;
wire   [31:0]  awaddr_p0_axis_ib_switch0_axi_s_0;
wire   [1:0]   awburst_p0_axis_ib_switch0_axi_s_0;
wire   [3:0]   awcache_p0_axis_ib_switch0_axi_s_0;
wire   [3:0]   awid_p0_axis_ib_switch0_axi_s_0;
wire   [7:0]   awlen_p0_axis_ib_switch0_axi_s_0;
wire           awlock_p0_axis_ib_switch0_axi_s_0;
wire   [2:0]   awprot_p0_axis_ib_switch0_axi_s_0;
wire   [3:0]   awqv_p0_axis_ib_switch0_axi_s_0;
wire   [2:0]   awsize_p0_axis_ib_switch0_axi_s_0;
wire   [2:0]   awuser_p0_axis_ib_switch0_axi_s_0;
wire           awvalid_p0_axis_ib_switch0_axi_s_0;
wire           awvalid_vect_p0_axis_ib_switch0_axi_s_0;
wire   [3:0]   b_data_p0_axis_ib_int;
wire   [2:0]   b_wpntr_gry_p0_axis_ib_int;
wire           bready_p0_axis_ib_switch0_axi_s_0;
wire   [36:0]  r_data_p0_axis_ib_int;
wire           r_valid_p0_axis_ib_int;
wire           rready_p0_axis_ib_switch0_axi_s_0;
wire   [2:0]   w_rpntr_bin_p0_axis_ib_int;
wire   [3:0]   w_rpntr_gry_p0_axis_ib_int;
wire   [31:0]  wdata_p0_axis_ib_switch0_axi_s_0;
wire           wlast_p0_axis_ib_switch0_axi_s_0;
wire   [3:0]   wstrb_p0_axis_ib_switch0_axi_s_0;
wire           wvalid_p0_axis_ib_switch0_axi_s_0;
wire   [58:0]  ar_data_p0_axis_ib_int;
wire           ar_valid_p0_axis_ib_int;
wire           arready_p0_axis_p0_axis_ib_axi4_s;
wire   [58:0]  aw_data_p0_axis_ib_int;
wire   [3:0]   aw_wpntr_gry_p0_axis_ib_int;
wire           awready_p0_axis_p0_axis_ib_axi4_s;
wire   [1:0]   b_rpntr_bin_p0_axis_ib_int;
wire   [2:0]   b_rpntr_gry_p0_axis_ib_int;
wire   [1:0]   bid_p0_axis_p0_axis_ib_axi4_s;
wire   [1:0]   bresp_p0_axis_p0_axis_ib_axi4_s;
wire           bvalid_p0_axis_p0_axis_ib_axi4_s;
wire           r_ready_p0_axis_ib_int;
wire   [31:0]  rdata_p0_axis_p0_axis_ib_axi4_s;
wire   [1:0]   rid_p0_axis_p0_axis_ib_axi4_s;
wire           rlast_p0_axis_p0_axis_ib_axi4_s;
wire   [1:0]   rresp_p0_axis_p0_axis_ib_axi4_s;
wire           rvalid_p0_axis_p0_axis_ib_axi4_s;
wire   [36:0]  w_data_p0_axis_ib_int;
wire   [3:0]   w_wpntr_gry_p0_axis_ib_int;
wire           wready_p0_axis_p0_axis_ib_axi4_s;
wire           ar_ready_p1_axis_ib_int;
wire   [31:0]  araddr_p1_axis_ib_switch0_axi_s_1;
wire   [1:0]   arburst_p1_axis_ib_switch0_axi_s_1;
wire   [3:0]   arcache_p1_axis_ib_switch0_axi_s_1;
wire   [3:0]   arid_p1_axis_ib_switch0_axi_s_1;
wire   [7:0]   arlen_p1_axis_ib_switch0_axi_s_1;
wire           arlock_p1_axis_ib_switch0_axi_s_1;
wire   [2:0]   arprot_p1_axis_ib_switch0_axi_s_1;
wire   [3:0]   arqv_p1_axis_ib_switch0_axi_s_1;
wire   [2:0]   arsize_p1_axis_ib_switch0_axi_s_1;
wire   [2:0]   aruser_p1_axis_ib_switch0_axi_s_1;
wire           arvalid_p1_axis_ib_switch0_axi_s_1;
wire           arvalid_vect_p1_axis_ib_switch0_axi_s_1;
wire   [2:0]   aw_rpntr_bin_p1_axis_ib_int;
wire   [3:0]   aw_rpntr_gry_p1_axis_ib_int;
wire   [31:0]  awaddr_p1_axis_ib_switch0_axi_s_1;
wire   [1:0]   awburst_p1_axis_ib_switch0_axi_s_1;
wire   [3:0]   awcache_p1_axis_ib_switch0_axi_s_1;
wire   [3:0]   awid_p1_axis_ib_switch0_axi_s_1;
wire   [7:0]   awlen_p1_axis_ib_switch0_axi_s_1;
wire           awlock_p1_axis_ib_switch0_axi_s_1;
wire   [2:0]   awprot_p1_axis_ib_switch0_axi_s_1;
wire   [3:0]   awqv_p1_axis_ib_switch0_axi_s_1;
wire   [2:0]   awsize_p1_axis_ib_switch0_axi_s_1;
wire   [2:0]   awuser_p1_axis_ib_switch0_axi_s_1;
wire           awvalid_p1_axis_ib_switch0_axi_s_1;
wire           awvalid_vect_p1_axis_ib_switch0_axi_s_1;
wire   [3:0]   b_data_p1_axis_ib_int;
wire   [2:0]   b_wpntr_gry_p1_axis_ib_int;
wire           bready_p1_axis_ib_switch0_axi_s_1;
wire   [36:0]  r_data_p1_axis_ib_int;
wire           r_valid_p1_axis_ib_int;
wire           rready_p1_axis_ib_switch0_axi_s_1;
wire   [2:0]   w_rpntr_bin_p1_axis_ib_int;
wire   [3:0]   w_rpntr_gry_p1_axis_ib_int;
wire   [31:0]  wdata_p1_axis_ib_switch0_axi_s_1;
wire           wlast_p1_axis_ib_switch0_axi_s_1;
wire   [3:0]   wstrb_p1_axis_ib_switch0_axi_s_1;
wire           wvalid_p1_axis_ib_switch0_axi_s_1;
wire   [58:0]  ar_data_p1_axis_ib_int;
wire           ar_valid_p1_axis_ib_int;
wire           arready_p1_axis_p1_axis_ib_axi4_s;
wire   [58:0]  aw_data_p1_axis_ib_int;
wire   [3:0]   aw_wpntr_gry_p1_axis_ib_int;
wire           awready_p1_axis_p1_axis_ib_axi4_s;
wire   [1:0]   b_rpntr_bin_p1_axis_ib_int;
wire   [2:0]   b_rpntr_gry_p1_axis_ib_int;
wire   [1:0]   bid_p1_axis_p1_axis_ib_axi4_s;
wire   [1:0]   bresp_p1_axis_p1_axis_ib_axi4_s;
wire           bvalid_p1_axis_p1_axis_ib_axi4_s;
wire           r_ready_p1_axis_ib_int;
wire   [31:0]  rdata_p1_axis_p1_axis_ib_axi4_s;
wire   [1:0]   rid_p1_axis_p1_axis_ib_axi4_s;
wire           rlast_p1_axis_p1_axis_ib_axi4_s;
wire   [1:0]   rresp_p1_axis_p1_axis_ib_axi4_s;
wire           rvalid_p1_axis_p1_axis_ib_axi4_s;
wire   [36:0]  w_data_p1_axis_ib_int;
wire   [3:0]   w_wpntr_gry_p1_axis_ib_int;
wire           wready_p1_axis_p1_axis_ib_axi4_s;
wire   [31:0]  araddr_p0_axis;
wire   [31:0]  araddr_p1_axis;
wire   [31:0]  araddr_p2_axis;
wire   [1:0]   arburst_p0_axis;
wire   [1:0]   arburst_p1_axis;
wire   [1:0]   arburst_p2_axis;
wire   [3:0]   arcache_p0_axis;
wire   [3:0]   arcache_p1_axis;
wire   [3:0]   arcache_p2_axis;
wire   [1:0]   arid_p0_axis;
wire   [1:0]   arid_p1_axis;
wire   [1:0]   arid_p2_axis;
wire   [7:0]   arlen_p0_axis;
wire   [7:0]   arlen_p1_axis;
wire   [7:0]   arlen_p2_axis;
wire           arlock_p0_axis;
wire           arlock_p1_axis;
wire           arlock_p2_axis;
wire   [2:0]   arprot_p0_axis;
wire   [2:0]   arprot_p1_axis;
wire   [2:0]   arprot_p2_axis;
wire           arready_dbg_axim;
wire   [2:0]   arsize_p0_axis;
wire   [2:0]   arsize_p1_axis;
wire   [2:0]   arsize_p2_axis;
wire   [2:0]   aruser_p0_axis;
wire   [2:0]   aruser_p1_axis;
wire   [2:0]   aruser_p2_axis;
wire           arvalid_p0_axis;
wire           arvalid_p1_axis;
wire           arvalid_p2_axis;
wire   [31:0]  awaddr_p0_axis;
wire   [31:0]  awaddr_p1_axis;
wire   [31:0]  awaddr_p2_axis;
wire   [1:0]   awburst_p0_axis;
wire   [1:0]   awburst_p1_axis;
wire   [1:0]   awburst_p2_axis;
wire   [3:0]   awcache_p0_axis;
wire   [3:0]   awcache_p1_axis;
wire   [3:0]   awcache_p2_axis;
wire   [1:0]   awid_p0_axis;
wire   [1:0]   awid_p1_axis;
wire   [1:0]   awid_p2_axis;
wire   [7:0]   awlen_p0_axis;
wire   [7:0]   awlen_p1_axis;
wire   [7:0]   awlen_p2_axis;
wire           awlock_p0_axis;
wire           awlock_p1_axis;
wire           awlock_p2_axis;
wire   [2:0]   awprot_p0_axis;
wire   [2:0]   awprot_p1_axis;
wire   [2:0]   awprot_p2_axis;
wire           awready_dbg_axim;
wire   [2:0]   awsize_p0_axis;
wire   [2:0]   awsize_p1_axis;
wire   [2:0]   awsize_p2_axis;
wire   [2:0]   awuser_p0_axis;
wire   [2:0]   awuser_p1_axis;
wire   [2:0]   awuser_p2_axis;
wire           awvalid_p0_axis;
wire           awvalid_p1_axis;
wire           awvalid_p2_axis;
wire   [3:0]   bid_dbg_axim;
wire           bready_p0_axis;
wire           bready_p1_axis;
wire           bready_p2_axis;
wire   [1:0]   bresp_dbg_axim;
wire           bvalid_dbg_axim;
wire           csysreq_cd_main;
wire           mainclk;
wire           mainresetn;
wire   [63:0]  rdata_dbg_axim;
wire   [3:0]   rid_dbg_axim;
wire           rlast_dbg_axim;
wire           rready_p0_axis;
wire           rready_p1_axis;
wire           rready_p2_axis;
wire   [1:0]   rresp_dbg_axim;
wire           rvalid_dbg_axim;
wire   [31:0]  wdata_p0_axis;
wire   [31:0]  wdata_p1_axis;
wire   [31:0]  wdata_p2_axis;
wire           wlast_p0_axis;
wire           wlast_p1_axis;
wire           wlast_p2_axis;
wire           wready_dbg_axim;
wire   [3:0]   wstrb_p0_axis;
wire   [3:0]   wstrb_p1_axis;
wire   [3:0]   wstrb_p2_axis;
wire           wvalid_p0_axis;
wire           wvalid_p1_axis;
wire           wvalid_p2_axis;




nic400_amib_dbg_axim_sse710_dbg3s1m     u_amib_dbg_axim (
  .awid_dbg_axim_m      (awid_dbg_axim),
  .awaddr_dbg_axim_m    (awaddr_dbg_axim),
  .awlen_dbg_axim_m     (awlen_dbg_axim),
  .awsize_dbg_axim_m    (awsize_dbg_axim),
  .awburst_dbg_axim_m   (awburst_dbg_axim),
  .awlock_dbg_axim_m    (awlock_dbg_axim),
  .awcache_dbg_axim_m   (awcache_dbg_axim),
  .awprot_dbg_axim_m    (awprot_dbg_axim),
  .awvalid_dbg_axim_m   (awvalid_dbg_axim),
  .awready_dbg_axim_m   (awready_dbg_axim),
  .wdata_dbg_axim_m     (wdata_dbg_axim),
  .wstrb_dbg_axim_m     (wstrb_dbg_axim),
  .wlast_dbg_axim_m     (wlast_dbg_axim),
  .wvalid_dbg_axim_m    (wvalid_dbg_axim),
  .wready_dbg_axim_m    (wready_dbg_axim),
  .bid_dbg_axim_m       (bid_dbg_axim),
  .bresp_dbg_axim_m     (bresp_dbg_axim),
  .bvalid_dbg_axim_m    (bvalid_dbg_axim),
  .bready_dbg_axim_m    (bready_dbg_axim),
  .arid_dbg_axim_m      (arid_dbg_axim),
  .araddr_dbg_axim_m    (araddr_dbg_axim),
  .arlen_dbg_axim_m     (arlen_dbg_axim),
  .arsize_dbg_axim_m    (arsize_dbg_axim),
  .arburst_dbg_axim_m   (arburst_dbg_axim),
  .arlock_dbg_axim_m    (arlock_dbg_axim),
  .arcache_dbg_axim_m   (arcache_dbg_axim),
  .arprot_dbg_axim_m    (arprot_dbg_axim),
  .arvalid_dbg_axim_m   (arvalid_dbg_axim),
  .arready_dbg_axim_m   (arready_dbg_axim),
  .rid_dbg_axim_m       (rid_dbg_axim),
  .rdata_dbg_axim_m     (rdata_dbg_axim),
  .rresp_dbg_axim_m     (rresp_dbg_axim),
  .rlast_dbg_axim_m     (rlast_dbg_axim),
  .rvalid_dbg_axim_m    (rvalid_dbg_axim),
  .rready_dbg_axim_m    (rready_dbg_axim),
  .awuser_dbg_axim_m    (awuser_dbg_axim),
  .aruser_dbg_axim_m    (aruser_dbg_axim),
  .awid_expmstr1_axim_s (awid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awaddr_expmstr1_axim_s (awaddr_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awlen_expmstr1_axim_s (awlen_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awsize_expmstr1_axim_s (awsize_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awburst_expmstr1_axim_s (awburst_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awlock_expmstr1_axim_s (awlock_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awcache_expmstr1_axim_s (awcache_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awprot_expmstr1_axim_s (awprot_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awvalid_expmstr1_axim_s (awvalid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awready_expmstr1_axim_s (awready_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .wdata_expmstr1_axim_s (wdata_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .wstrb_expmstr1_axim_s (wstrb_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .wlast_expmstr1_axim_s (wlast_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .wvalid_expmstr1_axim_s (wvalid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .wready_expmstr1_axim_s (wready_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .bid_expmstr1_axim_s  (bid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .bresp_expmstr1_axim_s (bresp_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .bvalid_expmstr1_axim_s (bvalid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .bready_expmstr1_axim_s (bready_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arid_expmstr1_axim_s (arid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .araddr_expmstr1_axim_s (araddr_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arlen_expmstr1_axim_s (arlen_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arsize_expmstr1_axim_s (arsize_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arburst_expmstr1_axim_s (arburst_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arlock_expmstr1_axim_s (arlock_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arcache_expmstr1_axim_s (arcache_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arprot_expmstr1_axim_s (arprot_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arvalid_expmstr1_axim_s (arvalid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arready_expmstr1_axim_s (arready_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .rid_expmstr1_axim_s  (rid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .rdata_expmstr1_axim_s (rdata_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .rresp_expmstr1_axim_s (rresp_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .rlast_expmstr1_axim_s (rlast_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .rvalid_expmstr1_axim_s (rvalid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .rready_expmstr1_axim_s (rready_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awuser_expmstr1_axim_s (awuser_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .aruser_expmstr1_axim_s (aruser_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .aclk                 (mainclk),
  .aresetn              (mainresetn)
);


nic400_asib_p0_axis_sse710_dbg3s1m     u_asib_p0_axis (
  .p0_axis_cactive      (cactive_p0_axis_hcg),
  .p0_axis_port_enable  (port_enable_p0_axis_port_enable_hcg),
  .awid_p0_axis_s       (awid_p0_axis),
  .awaddr_p0_axis_s     (awaddr_p0_axis),
  .awlen_p0_axis_s      (awlen_p0_axis),
  .awsize_p0_axis_s     (awsize_p0_axis),
  .awburst_p0_axis_s    (awburst_p0_axis),
  .awlock_p0_axis_s     (awlock_p0_axis),
  .awcache_p0_axis_s    (awcache_p0_axis),
  .awprot_p0_axis_s     (awprot_p0_axis),
  .awvalid_p0_axis_s    (awvalid_p0_axis),
  .awready_p0_axis_s    (awready_p0_axis),
  .wdata_p0_axis_s      (wdata_p0_axis),
  .wstrb_p0_axis_s      (wstrb_p0_axis),
  .wlast_p0_axis_s      (wlast_p0_axis),
  .wvalid_p0_axis_s     (wvalid_p0_axis),
  .wready_p0_axis_s     (wready_p0_axis),
  .bid_p0_axis_s        (bid_p0_axis),
  .bresp_p0_axis_s      (bresp_p0_axis),
  .bvalid_p0_axis_s     (bvalid_p0_axis),
  .bready_p0_axis_s     (bready_p0_axis),
  .arid_p0_axis_s       (arid_p0_axis),
  .araddr_p0_axis_s     (araddr_p0_axis),
  .arlen_p0_axis_s      (arlen_p0_axis),
  .arsize_p0_axis_s     (arsize_p0_axis),
  .arburst_p0_axis_s    (arburst_p0_axis),
  .arlock_p0_axis_s     (arlock_p0_axis),
  .arcache_p0_axis_s    (arcache_p0_axis),
  .arprot_p0_axis_s     (arprot_p0_axis),
  .arvalid_p0_axis_s    (arvalid_p0_axis),
  .arready_p0_axis_s    (arready_p0_axis),
  .rid_p0_axis_s        (rid_p0_axis),
  .rdata_p0_axis_s      (rdata_p0_axis),
  .rresp_p0_axis_s      (rresp_p0_axis),
  .rlast_p0_axis_s      (rlast_p0_axis),
  .rvalid_p0_axis_s     (rvalid_p0_axis),
  .rready_p0_axis_s     (rready_p0_axis),
  .awuser_p0_axis_s     (awuser_p0_axis),
  .aruser_p0_axis_s     (aruser_p0_axis),
  .p0_axis_cactive_wakeup (cactive_p0_axis_wakeup_hcg),
  .awid_secenc_axis_m   (awid_p0_axis_p0_axis_ib_axi4_s),
  .awaddr_secenc_axis_m (awaddr_p0_axis_p0_axis_ib_axi4_s),
  .awlen_secenc_axis_m  (awlen_p0_axis_p0_axis_ib_axi4_s),
  .awsize_secenc_axis_m (awsize_p0_axis_p0_axis_ib_axi4_s),
  .awburst_secenc_axis_m (awburst_p0_axis_p0_axis_ib_axi4_s),
  .awlock_secenc_axis_m (awlock_p0_axis_p0_axis_ib_axi4_s),
  .awcache_secenc_axis_m (awcache_p0_axis_p0_axis_ib_axi4_s),
  .awprot_secenc_axis_m (awprot_p0_axis_p0_axis_ib_axi4_s),
  .awvalid_secenc_axis_m (awvalid_p0_axis_p0_axis_ib_axi4_s),
  .awvalid_vect_secenc_axis_m (awvalid_vect_p0_axis_p0_axis_ib_axi4_s),
  .awready_secenc_axis_m (awready_p0_axis_p0_axis_ib_axi4_s),
  .wdata_secenc_axis_m  (wdata_p0_axis_p0_axis_ib_axi4_s),
  .wstrb_secenc_axis_m  (wstrb_p0_axis_p0_axis_ib_axi4_s),
  .wlast_secenc_axis_m  (wlast_p0_axis_p0_axis_ib_axi4_s),
  .wvalid_secenc_axis_m (wvalid_p0_axis_p0_axis_ib_axi4_s),
  .wready_secenc_axis_m (wready_p0_axis_p0_axis_ib_axi4_s),
  .bid_secenc_axis_m    (bid_p0_axis_p0_axis_ib_axi4_s),
  .bresp_secenc_axis_m  (bresp_p0_axis_p0_axis_ib_axi4_s),
  .bvalid_secenc_axis_m (bvalid_p0_axis_p0_axis_ib_axi4_s),
  .bready_secenc_axis_m (bready_p0_axis_p0_axis_ib_axi4_s),
  .arid_secenc_axis_m   (arid_p0_axis_p0_axis_ib_axi4_s),
  .araddr_secenc_axis_m (araddr_p0_axis_p0_axis_ib_axi4_s),
  .arlen_secenc_axis_m  (arlen_p0_axis_p0_axis_ib_axi4_s),
  .arsize_secenc_axis_m (arsize_p0_axis_p0_axis_ib_axi4_s),
  .arburst_secenc_axis_m (arburst_p0_axis_p0_axis_ib_axi4_s),
  .arlock_secenc_axis_m (arlock_p0_axis_p0_axis_ib_axi4_s),
  .arcache_secenc_axis_m (arcache_p0_axis_p0_axis_ib_axi4_s),
  .arprot_secenc_axis_m (arprot_p0_axis_p0_axis_ib_axi4_s),
  .arvalid_secenc_axis_m (arvalid_p0_axis_p0_axis_ib_axi4_s),
  .arvalid_vect_secenc_axis_m (arvalid_vect_p0_axis_p0_axis_ib_axi4_s),
  .arready_secenc_axis_m (arready_p0_axis_p0_axis_ib_axi4_s),
  .rid_secenc_axis_m    (rid_p0_axis_p0_axis_ib_axi4_s),
  .rdata_secenc_axis_m  (rdata_p0_axis_p0_axis_ib_axi4_s),
  .rresp_secenc_axis_m  (rresp_p0_axis_p0_axis_ib_axi4_s),
  .rlast_secenc_axis_m  (rlast_p0_axis_p0_axis_ib_axi4_s),
  .rvalid_secenc_axis_m (rvalid_p0_axis_p0_axis_ib_axi4_s),
  .rready_secenc_axis_m (rready_p0_axis_p0_axis_ib_axi4_s),
  .awuser_secenc_axis_m (awuser_p0_axis_p0_axis_ib_axi4_s),
  .aruser_secenc_axis_m (aruser_p0_axis_p0_axis_ib_axi4_s),
  .aclk                 (mainclk),
  .aresetn              (mainresetn)
);


nic400_asib_p1_axis_sse710_dbg3s1m     u_asib_p1_axis (
  .p1_axis_cactive      (cactive_p1_axis_hcg),
  .awid_p1_axis_m       (awid_p1_axis_p1_axis_ib_axi4_s),
  .awaddr_p1_axis_m     (awaddr_p1_axis_p1_axis_ib_axi4_s),
  .awlen_p1_axis_m      (awlen_p1_axis_p1_axis_ib_axi4_s),
  .awsize_p1_axis_m     (awsize_p1_axis_p1_axis_ib_axi4_s),
  .awburst_p1_axis_m    (awburst_p1_axis_p1_axis_ib_axi4_s),
  .awlock_p1_axis_m     (awlock_p1_axis_p1_axis_ib_axi4_s),
  .awcache_p1_axis_m    (awcache_p1_axis_p1_axis_ib_axi4_s),
  .awprot_p1_axis_m     (awprot_p1_axis_p1_axis_ib_axi4_s),
  .awvalid_p1_axis_m    (awvalid_p1_axis_p1_axis_ib_axi4_s),
  .awvalid_vect_p1_axis_m (awvalid_vect_p1_axis_p1_axis_ib_axi4_s),
  .awready_p1_axis_m    (awready_p1_axis_p1_axis_ib_axi4_s),
  .wdata_p1_axis_m      (wdata_p1_axis_p1_axis_ib_axi4_s),
  .wstrb_p1_axis_m      (wstrb_p1_axis_p1_axis_ib_axi4_s),
  .wlast_p1_axis_m      (wlast_p1_axis_p1_axis_ib_axi4_s),
  .wvalid_p1_axis_m     (wvalid_p1_axis_p1_axis_ib_axi4_s),
  .wready_p1_axis_m     (wready_p1_axis_p1_axis_ib_axi4_s),
  .bid_p1_axis_m        (bid_p1_axis_p1_axis_ib_axi4_s),
  .bresp_p1_axis_m      (bresp_p1_axis_p1_axis_ib_axi4_s),
  .bvalid_p1_axis_m     (bvalid_p1_axis_p1_axis_ib_axi4_s),
  .bready_p1_axis_m     (bready_p1_axis_p1_axis_ib_axi4_s),
  .arid_p1_axis_m       (arid_p1_axis_p1_axis_ib_axi4_s),
  .araddr_p1_axis_m     (araddr_p1_axis_p1_axis_ib_axi4_s),
  .arlen_p1_axis_m      (arlen_p1_axis_p1_axis_ib_axi4_s),
  .arsize_p1_axis_m     (arsize_p1_axis_p1_axis_ib_axi4_s),
  .arburst_p1_axis_m    (arburst_p1_axis_p1_axis_ib_axi4_s),
  .arlock_p1_axis_m     (arlock_p1_axis_p1_axis_ib_axi4_s),
  .arcache_p1_axis_m    (arcache_p1_axis_p1_axis_ib_axi4_s),
  .arprot_p1_axis_m     (arprot_p1_axis_p1_axis_ib_axi4_s),
  .arvalid_p1_axis_m    (arvalid_p1_axis_p1_axis_ib_axi4_s),
  .arvalid_vect_p1_axis_m (arvalid_vect_p1_axis_p1_axis_ib_axi4_s),
  .arready_p1_axis_m    (arready_p1_axis_p1_axis_ib_axi4_s),
  .rid_p1_axis_m        (rid_p1_axis_p1_axis_ib_axi4_s),
  .rdata_p1_axis_m      (rdata_p1_axis_p1_axis_ib_axi4_s),
  .rresp_p1_axis_m      (rresp_p1_axis_p1_axis_ib_axi4_s),
  .rlast_p1_axis_m      (rlast_p1_axis_p1_axis_ib_axi4_s),
  .rvalid_p1_axis_m     (rvalid_p1_axis_p1_axis_ib_axi4_s),
  .rready_p1_axis_m     (rready_p1_axis_p1_axis_ib_axi4_s),
  .awuser_p1_axis_m     (awuser_p1_axis_p1_axis_ib_axi4_s),
  .aruser_p1_axis_m     (aruser_p1_axis_p1_axis_ib_axi4_s),
  .aclk                 (mainclk),
  .aresetn              (mainresetn),
  .p1_axis_port_enable  (port_enable_p1_axis_port_enable_hcg),
  .awid_p1_axis_s       (awid_p1_axis),
  .awaddr_p1_axis_s     (awaddr_p1_axis),
  .awlen_p1_axis_s      (awlen_p1_axis),
  .awsize_p1_axis_s     (awsize_p1_axis),
  .awburst_p1_axis_s    (awburst_p1_axis),
  .awlock_p1_axis_s     (awlock_p1_axis),
  .awcache_p1_axis_s    (awcache_p1_axis),
  .awprot_p1_axis_s     (awprot_p1_axis),
  .awvalid_p1_axis_s    (awvalid_p1_axis),
  .awready_p1_axis_s    (awready_p1_axis),
  .wdata_p1_axis_s      (wdata_p1_axis),
  .wstrb_p1_axis_s      (wstrb_p1_axis),
  .wlast_p1_axis_s      (wlast_p1_axis),
  .wvalid_p1_axis_s     (wvalid_p1_axis),
  .wready_p1_axis_s     (wready_p1_axis),
  .bid_p1_axis_s        (bid_p1_axis),
  .bresp_p1_axis_s      (bresp_p1_axis),
  .bvalid_p1_axis_s     (bvalid_p1_axis),
  .bready_p1_axis_s     (bready_p1_axis),
  .arid_p1_axis_s       (arid_p1_axis),
  .araddr_p1_axis_s     (araddr_p1_axis),
  .arlen_p1_axis_s      (arlen_p1_axis),
  .arsize_p1_axis_s     (arsize_p1_axis),
  .arburst_p1_axis_s    (arburst_p1_axis),
  .arlock_p1_axis_s     (arlock_p1_axis),
  .arcache_p1_axis_s    (arcache_p1_axis),
  .arprot_p1_axis_s     (arprot_p1_axis),
  .arvalid_p1_axis_s    (arvalid_p1_axis),
  .arready_p1_axis_s    (arready_p1_axis),
  .rid_p1_axis_s        (rid_p1_axis),
  .rdata_p1_axis_s      (rdata_p1_axis),
  .rresp_p1_axis_s      (rresp_p1_axis),
  .rlast_p1_axis_s      (rlast_p1_axis),
  .rvalid_p1_axis_s     (rvalid_p1_axis),
  .rready_p1_axis_s     (rready_p1_axis),
  .awuser_p1_axis_s     (awuser_p1_axis),
  .aruser_p1_axis_s     (aruser_p1_axis),
  .p1_axis_cactive_wakeup (cactive_p1_axis_wakeup_hcg)
);


nic400_asib_p2_axis_sse710_dbg3s1m     u_asib_p2_axis (
  .p2_axis_cactive      (cactive_p2_axis_hcg),
  .awid_p2_axis_m       (awid_p2_axis_switch0_axi_s_2),
  .awaddr_p2_axis_m     (awaddr_p2_axis_switch0_axi_s_2),
  .awlen_p2_axis_m      (awlen_p2_axis_switch0_axi_s_2),
  .awsize_p2_axis_m     (awsize_p2_axis_switch0_axi_s_2),
  .awburst_p2_axis_m    (awburst_p2_axis_switch0_axi_s_2),
  .awlock_p2_axis_m     (awlock_p2_axis_switch0_axi_s_2),
  .awcache_p2_axis_m    (awcache_p2_axis_switch0_axi_s_2),
  .awprot_p2_axis_m     (awprot_p2_axis_switch0_axi_s_2),
  .awvalid_p2_axis_m    (awvalid_p2_axis_switch0_axi_s_2),
  .awvalid_vect_p2_axis_m (awvalid_vect_p2_axis_switch0_axi_s_2),
  .awready_p2_axis_m    (awready_p2_axis_switch0_axi_s_2),
  .wdata_p2_axis_m      (wdata_p2_axis_switch0_axi_s_2),
  .wstrb_p2_axis_m      (wstrb_p2_axis_switch0_axi_s_2),
  .wlast_p2_axis_m      (wlast_p2_axis_switch0_axi_s_2),
  .wvalid_p2_axis_m     (wvalid_p2_axis_switch0_axi_s_2),
  .wready_p2_axis_m     (wready_p2_axis_switch0_axi_s_2),
  .bid_p2_axis_m        (bid_p2_axis_switch0_axi_s_2),
  .bresp_p2_axis_m      (bresp_p2_axis_switch0_axi_s_2),
  .bvalid_p2_axis_m     (bvalid_p2_axis_switch0_axi_s_2),
  .bready_p2_axis_m     (bready_p2_axis_switch0_axi_s_2),
  .arid_p2_axis_m       (arid_p2_axis_switch0_axi_s_2),
  .araddr_p2_axis_m     (araddr_p2_axis_switch0_axi_s_2),
  .arlen_p2_axis_m      (arlen_p2_axis_switch0_axi_s_2),
  .arsize_p2_axis_m     (arsize_p2_axis_switch0_axi_s_2),
  .arburst_p2_axis_m    (arburst_p2_axis_switch0_axi_s_2),
  .arlock_p2_axis_m     (arlock_p2_axis_switch0_axi_s_2),
  .arcache_p2_axis_m    (arcache_p2_axis_switch0_axi_s_2),
  .arprot_p2_axis_m     (arprot_p2_axis_switch0_axi_s_2),
  .arvalid_p2_axis_m    (arvalid_p2_axis_switch0_axi_s_2),
  .arvalid_vect_p2_axis_m (arvalid_vect_p2_axis_switch0_axi_s_2),
  .arready_p2_axis_m    (arready_p2_axis_switch0_axi_s_2),
  .rid_p2_axis_m        (rid_p2_axis_switch0_axi_s_2),
  .rdata_p2_axis_m      (rdata_p2_axis_switch0_axi_s_2),
  .rresp_p2_axis_m      (rresp_p2_axis_switch0_axi_s_2),
  .rlast_p2_axis_m      (rlast_p2_axis_switch0_axi_s_2),
  .rvalid_p2_axis_m     (rvalid_p2_axis_switch0_axi_s_2),
  .rready_p2_axis_m     (rready_p2_axis_switch0_axi_s_2),
  .awuser_p2_axis_m     (awuser_p2_axis_switch0_axi_s_2),
  .aruser_p2_axis_m     (aruser_p2_axis_switch0_axi_s_2),
  .awqv_p2_axis_m       (awqv_p2_axis_switch0_axi_s_2),
  .arqv_p2_axis_m       (arqv_p2_axis_switch0_axi_s_2),
  .aclk                 (mainclk),
  .aresetn              (mainresetn),
  .p2_axis_port_enable  (port_enable_p2_axis_port_enable_hcg),
  .awid_p2_axis_s       (awid_p2_axis),
  .awaddr_p2_axis_s     (awaddr_p2_axis),
  .awlen_p2_axis_s      (awlen_p2_axis),
  .awsize_p2_axis_s     (awsize_p2_axis),
  .awburst_p2_axis_s    (awburst_p2_axis),
  .awlock_p2_axis_s     (awlock_p2_axis),
  .awcache_p2_axis_s    (awcache_p2_axis),
  .awprot_p2_axis_s     (awprot_p2_axis),
  .awvalid_p2_axis_s    (awvalid_p2_axis),
  .awready_p2_axis_s    (awready_p2_axis),
  .wdata_p2_axis_s      (wdata_p2_axis),
  .wstrb_p2_axis_s      (wstrb_p2_axis),
  .wlast_p2_axis_s      (wlast_p2_axis),
  .wvalid_p2_axis_s     (wvalid_p2_axis),
  .wready_p2_axis_s     (wready_p2_axis),
  .bid_p2_axis_s        (bid_p2_axis),
  .bresp_p2_axis_s      (bresp_p2_axis),
  .bvalid_p2_axis_s     (bvalid_p2_axis),
  .bready_p2_axis_s     (bready_p2_axis),
  .arid_p2_axis_s       (arid_p2_axis),
  .araddr_p2_axis_s     (araddr_p2_axis),
  .arlen_p2_axis_s      (arlen_p2_axis),
  .arsize_p2_axis_s     (arsize_p2_axis),
  .arburst_p2_axis_s    (arburst_p2_axis),
  .arlock_p2_axis_s     (arlock_p2_axis),
  .arcache_p2_axis_s    (arcache_p2_axis),
  .arprot_p2_axis_s     (arprot_p2_axis),
  .arvalid_p2_axis_s    (arvalid_p2_axis),
  .arready_p2_axis_s    (arready_p2_axis),
  .rid_p2_axis_s        (rid_p2_axis),
  .rdata_p2_axis_s      (rdata_p2_axis),
  .rresp_p2_axis_s      (rresp_p2_axis),
  .rlast_p2_axis_s      (rlast_p2_axis),
  .rvalid_p2_axis_s     (rvalid_p2_axis),
  .rready_p2_axis_s     (rready_p2_axis),
  .awuser_p2_axis_s     (awuser_p2_axis),
  .aruser_p2_axis_s     (aruser_p2_axis),
  .p2_axis_cactive_wakeup (cactive_p2_axis_wakeup_hcg)
);


nic400_switch0_sse710_dbg3s1m     u_busmatrix_switch0 (
  .awid_axi_m_1         (awid_switch0_dbg_axim_ib_axi4_s),
  .awaddr_axi_m_1       (awaddr_switch0_dbg_axim_ib_axi4_s),
  .awlen_axi_m_1        (awlen_switch0_dbg_axim_ib_axi4_s),
  .awsize_axi_m_1       (awsize_switch0_dbg_axim_ib_axi4_s),
  .awburst_axi_m_1      (awburst_switch0_dbg_axim_ib_axi4_s),
  .awlock_axi_m_1       (awlock_switch0_dbg_axim_ib_axi4_s),
  .awcache_axi_m_1      (awcache_switch0_dbg_axim_ib_axi4_s),
  .awprot_axi_m_1       (awprot_switch0_dbg_axim_ib_axi4_s),
  .awvalid_axi_m_1      (awvalid_switch0_dbg_axim_ib_axi4_s),
  .awvalid_vect_axi_m_1 (),
  .awready_axi_m_1      (awready_switch0_dbg_axim_ib_axi4_s),
  .wdata_axi_m_1        (wdata_switch0_dbg_axim_ib_axi4_s),
  .wstrb_axi_m_1        (wstrb_switch0_dbg_axim_ib_axi4_s),
  .wlast_axi_m_1        (wlast_switch0_dbg_axim_ib_axi4_s),
  .wvalid_axi_m_1       (wvalid_switch0_dbg_axim_ib_axi4_s),
  .wready_axi_m_1       (wready_switch0_dbg_axim_ib_axi4_s),
  .bid_axi_m_1          (bid_switch0_dbg_axim_ib_axi4_s),
  .bresp_axi_m_1        (bresp_switch0_dbg_axim_ib_axi4_s),
  .bvalid_axi_m_1       (bvalid_switch0_dbg_axim_ib_axi4_s),
  .bready_axi_m_1       (bready_switch0_dbg_axim_ib_axi4_s),
  .arid_axi_m_1         (arid_switch0_dbg_axim_ib_axi4_s),
  .araddr_axi_m_1       (araddr_switch0_dbg_axim_ib_axi4_s),
  .arlen_axi_m_1        (arlen_switch0_dbg_axim_ib_axi4_s),
  .arsize_axi_m_1       (arsize_switch0_dbg_axim_ib_axi4_s),
  .arburst_axi_m_1      (arburst_switch0_dbg_axim_ib_axi4_s),
  .arlock_axi_m_1       (arlock_switch0_dbg_axim_ib_axi4_s),
  .arcache_axi_m_1      (arcache_switch0_dbg_axim_ib_axi4_s),
  .arprot_axi_m_1       (arprot_switch0_dbg_axim_ib_axi4_s),
  .arvalid_axi_m_1      (arvalid_switch0_dbg_axim_ib_axi4_s),
  .arvalid_vect_axi_m_1 (),
  .arready_axi_m_1      (arready_switch0_dbg_axim_ib_axi4_s),
  .rid_axi_m_1          (rid_switch0_dbg_axim_ib_axi4_s),
  .rdata_axi_m_1        (rdata_switch0_dbg_axim_ib_axi4_s),
  .rresp_axi_m_1        (rresp_switch0_dbg_axim_ib_axi4_s),
  .rlast_axi_m_1        (rlast_switch0_dbg_axim_ib_axi4_s),
  .rvalid_axi_m_1       (rvalid_switch0_dbg_axim_ib_axi4_s),
  .rready_axi_m_1       (rready_switch0_dbg_axim_ib_axi4_s),
  .awuser_axi_m_1       (awuser_switch0_dbg_axim_ib_axi4_s),
  .aruser_axi_m_1       (aruser_switch0_dbg_axim_ib_axi4_s),
  .aw_qv_axi_m_1        (),
  .ar_qv_axi_m_1        (),
  .awid_axi_s_0         (awid_p0_axis_ib_switch0_axi_s_0),
  .awaddr_axi_s_0       (awaddr_p0_axis_ib_switch0_axi_s_0),
  .awlen_axi_s_0        (awlen_p0_axis_ib_switch0_axi_s_0),
  .awsize_axi_s_0       (awsize_p0_axis_ib_switch0_axi_s_0),
  .awburst_axi_s_0      (awburst_p0_axis_ib_switch0_axi_s_0),
  .awlock_axi_s_0       (awlock_p0_axis_ib_switch0_axi_s_0),
  .awcache_axi_s_0      (awcache_p0_axis_ib_switch0_axi_s_0),
  .awprot_axi_s_0       (awprot_p0_axis_ib_switch0_axi_s_0),
  .awvalid_axi_s_0      (awvalid_p0_axis_ib_switch0_axi_s_0),
  .awvalid_vect_axi_s_0 (awvalid_vect_p0_axis_ib_switch0_axi_s_0),
  .awready_axi_s_0      (awready_p0_axis_ib_switch0_axi_s_0),
  .wdata_axi_s_0        (wdata_p0_axis_ib_switch0_axi_s_0),
  .wstrb_axi_s_0        (wstrb_p0_axis_ib_switch0_axi_s_0),
  .wlast_axi_s_0        (wlast_p0_axis_ib_switch0_axi_s_0),
  .wvalid_axi_s_0       (wvalid_p0_axis_ib_switch0_axi_s_0),
  .wready_axi_s_0       (wready_p0_axis_ib_switch0_axi_s_0),
  .bid_axi_s_0          (bid_p0_axis_ib_switch0_axi_s_0),
  .bresp_axi_s_0        (bresp_p0_axis_ib_switch0_axi_s_0),
  .bvalid_axi_s_0       (bvalid_p0_axis_ib_switch0_axi_s_0),
  .bready_axi_s_0       (bready_p0_axis_ib_switch0_axi_s_0),
  .arid_axi_s_0         (arid_p0_axis_ib_switch0_axi_s_0),
  .araddr_axi_s_0       (araddr_p0_axis_ib_switch0_axi_s_0),
  .arlen_axi_s_0        (arlen_p0_axis_ib_switch0_axi_s_0),
  .arsize_axi_s_0       (arsize_p0_axis_ib_switch0_axi_s_0),
  .arburst_axi_s_0      (arburst_p0_axis_ib_switch0_axi_s_0),
  .arlock_axi_s_0       (arlock_p0_axis_ib_switch0_axi_s_0),
  .arcache_axi_s_0      (arcache_p0_axis_ib_switch0_axi_s_0),
  .arprot_axi_s_0       (arprot_p0_axis_ib_switch0_axi_s_0),
  .arvalid_axi_s_0      (arvalid_p0_axis_ib_switch0_axi_s_0),
  .arvalid_vect_axi_s_0 (arvalid_vect_p0_axis_ib_switch0_axi_s_0),
  .arready_axi_s_0      (arready_p0_axis_ib_switch0_axi_s_0),
  .rid_axi_s_0          (rid_p0_axis_ib_switch0_axi_s_0),
  .rdata_axi_s_0        (rdata_p0_axis_ib_switch0_axi_s_0),
  .rresp_axi_s_0        (rresp_p0_axis_ib_switch0_axi_s_0),
  .rlast_axi_s_0        (rlast_p0_axis_ib_switch0_axi_s_0),
  .rvalid_axi_s_0       (rvalid_p0_axis_ib_switch0_axi_s_0),
  .rready_axi_s_0       (rready_p0_axis_ib_switch0_axi_s_0),
  .awuser_axi_s_0       (awuser_p0_axis_ib_switch0_axi_s_0),
  .aruser_axi_s_0       (aruser_p0_axis_ib_switch0_axi_s_0),
  .aw_qv_axi_s_0        (awqv_p0_axis_ib_switch0_axi_s_0),
  .ar_qv_axi_s_0        (arqv_p0_axis_ib_switch0_axi_s_0),
  .awid_axi_s_1         (awid_p1_axis_ib_switch0_axi_s_1),
  .awaddr_axi_s_1       (awaddr_p1_axis_ib_switch0_axi_s_1),
  .awlen_axi_s_1        (awlen_p1_axis_ib_switch0_axi_s_1),
  .awsize_axi_s_1       (awsize_p1_axis_ib_switch0_axi_s_1),
  .awburst_axi_s_1      (awburst_p1_axis_ib_switch0_axi_s_1),
  .awlock_axi_s_1       (awlock_p1_axis_ib_switch0_axi_s_1),
  .awcache_axi_s_1      (awcache_p1_axis_ib_switch0_axi_s_1),
  .awprot_axi_s_1       (awprot_p1_axis_ib_switch0_axi_s_1),
  .awvalid_axi_s_1      (awvalid_p1_axis_ib_switch0_axi_s_1),
  .awvalid_vect_axi_s_1 (awvalid_vect_p1_axis_ib_switch0_axi_s_1),
  .awready_axi_s_1      (awready_p1_axis_ib_switch0_axi_s_1),
  .wdata_axi_s_1        (wdata_p1_axis_ib_switch0_axi_s_1),
  .wstrb_axi_s_1        (wstrb_p1_axis_ib_switch0_axi_s_1),
  .wlast_axi_s_1        (wlast_p1_axis_ib_switch0_axi_s_1),
  .wvalid_axi_s_1       (wvalid_p1_axis_ib_switch0_axi_s_1),
  .wready_axi_s_1       (wready_p1_axis_ib_switch0_axi_s_1),
  .bid_axi_s_1          (bid_p1_axis_ib_switch0_axi_s_1),
  .bresp_axi_s_1        (bresp_p1_axis_ib_switch0_axi_s_1),
  .bvalid_axi_s_1       (bvalid_p1_axis_ib_switch0_axi_s_1),
  .bready_axi_s_1       (bready_p1_axis_ib_switch0_axi_s_1),
  .arid_axi_s_1         (arid_p1_axis_ib_switch0_axi_s_1),
  .araddr_axi_s_1       (araddr_p1_axis_ib_switch0_axi_s_1),
  .arlen_axi_s_1        (arlen_p1_axis_ib_switch0_axi_s_1),
  .arsize_axi_s_1       (arsize_p1_axis_ib_switch0_axi_s_1),
  .arburst_axi_s_1      (arburst_p1_axis_ib_switch0_axi_s_1),
  .arlock_axi_s_1       (arlock_p1_axis_ib_switch0_axi_s_1),
  .arcache_axi_s_1      (arcache_p1_axis_ib_switch0_axi_s_1),
  .arprot_axi_s_1       (arprot_p1_axis_ib_switch0_axi_s_1),
  .arvalid_axi_s_1      (arvalid_p1_axis_ib_switch0_axi_s_1),
  .arvalid_vect_axi_s_1 (arvalid_vect_p1_axis_ib_switch0_axi_s_1),
  .arready_axi_s_1      (arready_p1_axis_ib_switch0_axi_s_1),
  .rid_axi_s_1          (rid_p1_axis_ib_switch0_axi_s_1),
  .rdata_axi_s_1        (rdata_p1_axis_ib_switch0_axi_s_1),
  .rresp_axi_s_1        (rresp_p1_axis_ib_switch0_axi_s_1),
  .rlast_axi_s_1        (rlast_p1_axis_ib_switch0_axi_s_1),
  .rvalid_axi_s_1       (rvalid_p1_axis_ib_switch0_axi_s_1),
  .rready_axi_s_1       (rready_p1_axis_ib_switch0_axi_s_1),
  .awuser_axi_s_1       (awuser_p1_axis_ib_switch0_axi_s_1),
  .aruser_axi_s_1       (aruser_p1_axis_ib_switch0_axi_s_1),
  .aw_qv_axi_s_1        (awqv_p1_axis_ib_switch0_axi_s_1),
  .ar_qv_axi_s_1        (arqv_p1_axis_ib_switch0_axi_s_1),
  .awid_axi_s_2         (awid_p2_axis_switch0_axi_s_2),
  .awaddr_axi_s_2       (awaddr_p2_axis_switch0_axi_s_2),
  .awlen_axi_s_2        (awlen_p2_axis_switch0_axi_s_2),
  .awsize_axi_s_2       (awsize_p2_axis_switch0_axi_s_2),
  .awburst_axi_s_2      (awburst_p2_axis_switch0_axi_s_2),
  .awlock_axi_s_2       (awlock_p2_axis_switch0_axi_s_2),
  .awcache_axi_s_2      (awcache_p2_axis_switch0_axi_s_2),
  .awprot_axi_s_2       (awprot_p2_axis_switch0_axi_s_2),
  .awvalid_axi_s_2      (awvalid_p2_axis_switch0_axi_s_2),
  .awvalid_vect_axi_s_2 (awvalid_vect_p2_axis_switch0_axi_s_2),
  .awready_axi_s_2      (awready_p2_axis_switch0_axi_s_2),
  .wdata_axi_s_2        (wdata_p2_axis_switch0_axi_s_2),
  .wstrb_axi_s_2        (wstrb_p2_axis_switch0_axi_s_2),
  .wlast_axi_s_2        (wlast_p2_axis_switch0_axi_s_2),
  .wvalid_axi_s_2       (wvalid_p2_axis_switch0_axi_s_2),
  .wready_axi_s_2       (wready_p2_axis_switch0_axi_s_2),
  .bid_axi_s_2          (bid_p2_axis_switch0_axi_s_2),
  .bresp_axi_s_2        (bresp_p2_axis_switch0_axi_s_2),
  .bvalid_axi_s_2       (bvalid_p2_axis_switch0_axi_s_2),
  .bready_axi_s_2       (bready_p2_axis_switch0_axi_s_2),
  .arid_axi_s_2         (arid_p2_axis_switch0_axi_s_2),
  .araddr_axi_s_2       (araddr_p2_axis_switch0_axi_s_2),
  .arlen_axi_s_2        (arlen_p2_axis_switch0_axi_s_2),
  .arsize_axi_s_2       (arsize_p2_axis_switch0_axi_s_2),
  .arburst_axi_s_2      (arburst_p2_axis_switch0_axi_s_2),
  .arlock_axi_s_2       (arlock_p2_axis_switch0_axi_s_2),
  .arcache_axi_s_2      (arcache_p2_axis_switch0_axi_s_2),
  .arprot_axi_s_2       (arprot_p2_axis_switch0_axi_s_2),
  .arvalid_axi_s_2      (arvalid_p2_axis_switch0_axi_s_2),
  .arvalid_vect_axi_s_2 (arvalid_vect_p2_axis_switch0_axi_s_2),
  .arready_axi_s_2      (arready_p2_axis_switch0_axi_s_2),
  .rid_axi_s_2          (rid_p2_axis_switch0_axi_s_2),
  .rdata_axi_s_2        (rdata_p2_axis_switch0_axi_s_2),
  .rresp_axi_s_2        (rresp_p2_axis_switch0_axi_s_2),
  .rlast_axi_s_2        (rlast_p2_axis_switch0_axi_s_2),
  .rvalid_axi_s_2       (rvalid_p2_axis_switch0_axi_s_2),
  .rready_axi_s_2       (rready_p2_axis_switch0_axi_s_2),
  .awuser_axi_s_2       (awuser_p2_axis_switch0_axi_s_2),
  .aruser_axi_s_2       (aruser_p2_axis_switch0_axi_s_2),
  .aw_qv_axi_s_2        (awqv_p2_axis_switch0_axi_s_2),
  .ar_qv_axi_s_2        (arqv_p2_axis_switch0_axi_s_2),
  .aclk                 (mainclk),
  .aresetn              (mainresetn)
);


nic400_dmu_main_sse710_dbg3s1m     u_dmu_main_sse710_dbg3s1m (
  .cd_main_clk          (mainclk),
  .cd_main_resetn       (mainresetn),
  .cd_main_cactive      (cactive_cd_main),
  .cd_main_csysreq      (csysreq_cd_main),
  .cd_main_csysack      (csysack_cd_main),
  .p0_axis_cactive      (cactive_p0_axis_hcg),
  .p0_axis_port_enable  (port_enable_p0_axis_port_enable_hcg),
  .p0_axis_cactive_wakeup (cactive_p0_axis_wakeup_hcg),
  .p1_axis_cactive      (cactive_p1_axis_hcg),
  .p1_axis_port_enable  (port_enable_p1_axis_port_enable_hcg),
  .p1_axis_cactive_wakeup (cactive_p1_axis_wakeup_hcg),
  .p2_axis_cactive      (cactive_p2_axis_hcg),
  .p2_axis_port_enable  (port_enable_p2_axis_port_enable_hcg),
  .p2_axis_cactive_wakeup (cactive_p2_axis_wakeup_hcg)
);


nic400_ib_dbg_axim_ib_master_domain_sse710_dbg3s1m     u_ib_dbg_axim_ib_m (
  .awid_axi4_m          (awid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awaddr_axi4_m        (awaddr_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awlen_axi4_m         (awlen_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awsize_axi4_m        (awsize_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awburst_axi4_m       (awburst_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awlock_axi4_m        (awlock_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awcache_axi4_m       (awcache_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awprot_axi4_m        (awprot_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awvalid_axi4_m       (awvalid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awready_axi4_m       (awready_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .wdata_axi4_m         (wdata_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .wstrb_axi4_m         (wstrb_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .wlast_axi4_m         (wlast_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .wvalid_axi4_m        (wvalid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .wready_axi4_m        (wready_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .bid_axi4_m           (bid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .bresp_axi4_m         (bresp_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .bvalid_axi4_m        (bvalid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .bready_axi4_m        (bready_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arid_axi4_m          (arid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .araddr_axi4_m        (araddr_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arlen_axi4_m         (arlen_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arsize_axi4_m        (arsize_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arburst_axi4_m       (arburst_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arlock_axi4_m        (arlock_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arcache_axi4_m       (arcache_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arprot_axi4_m        (arprot_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arvalid_axi4_m       (arvalid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .arready_axi4_m       (arready_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .rid_axi4_m           (rid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .rdata_axi4_m         (rdata_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .rresp_axi4_m         (rresp_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .rlast_axi4_m         (rlast_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .rvalid_axi4_m        (rvalid_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .rready_axi4_m        (rready_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .awuser_axi4_m        (awuser_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .aruser_axi4_m        (aruser_dbg_axim_ib_dbg_axim_expmstr1_axim_s),
  .aclk                 (mainclk),
  .aresetn              (mainresetn),
  .aw_data              (aw_data_dbg_axim_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_dbg_axim_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_dbg_axim_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_dbg_axim_ib_int),
  .b_data               (b_data_dbg_axim_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_dbg_axim_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_dbg_axim_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_dbg_axim_ib_int),
  .ar_data              (ar_data_dbg_axim_ib_int),
  .ar_valid             (ar_valid_dbg_axim_ib_int),
  .ar_ready             (ar_ready_dbg_axim_ib_int),
  .r_data               (r_data_dbg_axim_ib_int),
  .r_valid              (r_valid_dbg_axim_ib_int),
  .r_ready              (r_ready_dbg_axim_ib_int),
  .w_data               (w_data_dbg_axim_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_dbg_axim_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_dbg_axim_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_dbg_axim_ib_int)
);


nic400_ib_dbg_axim_ib_slave_domain_sse710_dbg3s1m     u_ib_dbg_axim_ib_s (
  .awid_axi4_s          (awid_switch0_dbg_axim_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_switch0_dbg_axim_ib_axi4_s),
  .awlen_axi4_s         (awlen_switch0_dbg_axim_ib_axi4_s),
  .awsize_axi4_s        (awsize_switch0_dbg_axim_ib_axi4_s),
  .awburst_axi4_s       (awburst_switch0_dbg_axim_ib_axi4_s),
  .awlock_axi4_s        (awlock_switch0_dbg_axim_ib_axi4_s),
  .awcache_axi4_s       (awcache_switch0_dbg_axim_ib_axi4_s),
  .awprot_axi4_s        (awprot_switch0_dbg_axim_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_switch0_dbg_axim_ib_axi4_s),
  .awready_axi4_s       (awready_switch0_dbg_axim_ib_axi4_s),
  .wdata_axi4_s         (wdata_switch0_dbg_axim_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_switch0_dbg_axim_ib_axi4_s),
  .wlast_axi4_s         (wlast_switch0_dbg_axim_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_switch0_dbg_axim_ib_axi4_s),
  .wready_axi4_s        (wready_switch0_dbg_axim_ib_axi4_s),
  .bid_axi4_s           (bid_switch0_dbg_axim_ib_axi4_s),
  .bresp_axi4_s         (bresp_switch0_dbg_axim_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_switch0_dbg_axim_ib_axi4_s),
  .bready_axi4_s        (bready_switch0_dbg_axim_ib_axi4_s),
  .arid_axi4_s          (arid_switch0_dbg_axim_ib_axi4_s),
  .araddr_axi4_s        (araddr_switch0_dbg_axim_ib_axi4_s),
  .arlen_axi4_s         (arlen_switch0_dbg_axim_ib_axi4_s),
  .arsize_axi4_s        (arsize_switch0_dbg_axim_ib_axi4_s),
  .arburst_axi4_s       (arburst_switch0_dbg_axim_ib_axi4_s),
  .arlock_axi4_s        (arlock_switch0_dbg_axim_ib_axi4_s),
  .arcache_axi4_s       (arcache_switch0_dbg_axim_ib_axi4_s),
  .arprot_axi4_s        (arprot_switch0_dbg_axim_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_switch0_dbg_axim_ib_axi4_s),
  .arready_axi4_s       (arready_switch0_dbg_axim_ib_axi4_s),
  .rid_axi4_s           (rid_switch0_dbg_axim_ib_axi4_s),
  .rdata_axi4_s         (rdata_switch0_dbg_axim_ib_axi4_s),
  .rresp_axi4_s         (rresp_switch0_dbg_axim_ib_axi4_s),
  .rlast_axi4_s         (rlast_switch0_dbg_axim_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_switch0_dbg_axim_ib_axi4_s),
  .rready_axi4_s        (rready_switch0_dbg_axim_ib_axi4_s),
  .awuser_axi4_s        (awuser_switch0_dbg_axim_ib_axi4_s),
  .aruser_axi4_s        (aruser_switch0_dbg_axim_ib_axi4_s),
  .aclk                 (mainclk),
  .aresetn              (mainresetn),
  .aw_data              (aw_data_dbg_axim_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_dbg_axim_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_dbg_axim_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_dbg_axim_ib_int),
  .b_data               (b_data_dbg_axim_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_dbg_axim_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_dbg_axim_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_dbg_axim_ib_int),
  .ar_data              (ar_data_dbg_axim_ib_int),
  .ar_valid             (ar_valid_dbg_axim_ib_int),
  .ar_ready             (ar_ready_dbg_axim_ib_int),
  .r_data               (r_data_dbg_axim_ib_int),
  .r_valid              (r_valid_dbg_axim_ib_int),
  .r_ready              (r_ready_dbg_axim_ib_int),
  .w_data               (w_data_dbg_axim_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_dbg_axim_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_dbg_axim_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_dbg_axim_ib_int)
);


nic400_ib_p0_axis_ib_master_domain_sse710_dbg3s1m     u_ib_p0_axis_ib_m (
  .awid_axi4_m          (awid_p0_axis_ib_switch0_axi_s_0),
  .awaddr_axi4_m        (awaddr_p0_axis_ib_switch0_axi_s_0),
  .awlen_axi4_m         (awlen_p0_axis_ib_switch0_axi_s_0),
  .awsize_axi4_m        (awsize_p0_axis_ib_switch0_axi_s_0),
  .awburst_axi4_m       (awburst_p0_axis_ib_switch0_axi_s_0),
  .awlock_axi4_m        (awlock_p0_axis_ib_switch0_axi_s_0),
  .awcache_axi4_m       (awcache_p0_axis_ib_switch0_axi_s_0),
  .awprot_axi4_m        (awprot_p0_axis_ib_switch0_axi_s_0),
  .awvalid_axi4_m       (awvalid_p0_axis_ib_switch0_axi_s_0),
  .awvalid_vect_axi4_m  (awvalid_vect_p0_axis_ib_switch0_axi_s_0),
  .awready_axi4_m       (awready_p0_axis_ib_switch0_axi_s_0),
  .wdata_axi4_m         (wdata_p0_axis_ib_switch0_axi_s_0),
  .wstrb_axi4_m         (wstrb_p0_axis_ib_switch0_axi_s_0),
  .wlast_axi4_m         (wlast_p0_axis_ib_switch0_axi_s_0),
  .wvalid_axi4_m        (wvalid_p0_axis_ib_switch0_axi_s_0),
  .wready_axi4_m        (wready_p0_axis_ib_switch0_axi_s_0),
  .bid_axi4_m           (bid_p0_axis_ib_switch0_axi_s_0),
  .bresp_axi4_m         (bresp_p0_axis_ib_switch0_axi_s_0),
  .bvalid_axi4_m        (bvalid_p0_axis_ib_switch0_axi_s_0),
  .bready_axi4_m        (bready_p0_axis_ib_switch0_axi_s_0),
  .arid_axi4_m          (arid_p0_axis_ib_switch0_axi_s_0),
  .araddr_axi4_m        (araddr_p0_axis_ib_switch0_axi_s_0),
  .arlen_axi4_m         (arlen_p0_axis_ib_switch0_axi_s_0),
  .arsize_axi4_m        (arsize_p0_axis_ib_switch0_axi_s_0),
  .arburst_axi4_m       (arburst_p0_axis_ib_switch0_axi_s_0),
  .arlock_axi4_m        (arlock_p0_axis_ib_switch0_axi_s_0),
  .arcache_axi4_m       (arcache_p0_axis_ib_switch0_axi_s_0),
  .arprot_axi4_m        (arprot_p0_axis_ib_switch0_axi_s_0),
  .arvalid_axi4_m       (arvalid_p0_axis_ib_switch0_axi_s_0),
  .arvalid_vect_axi4_m  (arvalid_vect_p0_axis_ib_switch0_axi_s_0),
  .arready_axi4_m       (arready_p0_axis_ib_switch0_axi_s_0),
  .rid_axi4_m           (rid_p0_axis_ib_switch0_axi_s_0),
  .rdata_axi4_m         (rdata_p0_axis_ib_switch0_axi_s_0),
  .rresp_axi4_m         (rresp_p0_axis_ib_switch0_axi_s_0),
  .rlast_axi4_m         (rlast_p0_axis_ib_switch0_axi_s_0),
  .rvalid_axi4_m        (rvalid_p0_axis_ib_switch0_axi_s_0),
  .rready_axi4_m        (rready_p0_axis_ib_switch0_axi_s_0),
  .awuser_axi4_m        (awuser_p0_axis_ib_switch0_axi_s_0),
  .aruser_axi4_m        (aruser_p0_axis_ib_switch0_axi_s_0),
  .awqv_axi4_m          (awqv_p0_axis_ib_switch0_axi_s_0),
  .arqv_axi4_m          (arqv_p0_axis_ib_switch0_axi_s_0),
  .aclk                 (mainclk),
  .aresetn              (mainresetn),
  .aw_data              (aw_data_p0_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_p0_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_p0_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_p0_axis_ib_int),
  .b_data               (b_data_p0_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_p0_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_p0_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_p0_axis_ib_int),
  .ar_data              (ar_data_p0_axis_ib_int),
  .ar_valid             (ar_valid_p0_axis_ib_int),
  .ar_ready             (ar_ready_p0_axis_ib_int),
  .r_data               (r_data_p0_axis_ib_int),
  .r_valid              (r_valid_p0_axis_ib_int),
  .r_ready              (r_ready_p0_axis_ib_int),
  .w_data               (w_data_p0_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_p0_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_p0_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_p0_axis_ib_int)
);


nic400_ib_p0_axis_ib_slave_domain_sse710_dbg3s1m     u_ib_p0_axis_ib_s (
  .awid_axi4_s          (awid_p0_axis_p0_axis_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_p0_axis_p0_axis_ib_axi4_s),
  .awlen_axi4_s         (awlen_p0_axis_p0_axis_ib_axi4_s),
  .awsize_axi4_s        (awsize_p0_axis_p0_axis_ib_axi4_s),
  .awburst_axi4_s       (awburst_p0_axis_p0_axis_ib_axi4_s),
  .awlock_axi4_s        (awlock_p0_axis_p0_axis_ib_axi4_s),
  .awcache_axi4_s       (awcache_p0_axis_p0_axis_ib_axi4_s),
  .awprot_axi4_s        (awprot_p0_axis_p0_axis_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_p0_axis_p0_axis_ib_axi4_s),
  .awvalid_vect_axi4_s  (awvalid_vect_p0_axis_p0_axis_ib_axi4_s),
  .awready_axi4_s       (awready_p0_axis_p0_axis_ib_axi4_s),
  .wdata_axi4_s         (wdata_p0_axis_p0_axis_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_p0_axis_p0_axis_ib_axi4_s),
  .wlast_axi4_s         (wlast_p0_axis_p0_axis_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_p0_axis_p0_axis_ib_axi4_s),
  .wready_axi4_s        (wready_p0_axis_p0_axis_ib_axi4_s),
  .bid_axi4_s           (bid_p0_axis_p0_axis_ib_axi4_s),
  .bresp_axi4_s         (bresp_p0_axis_p0_axis_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_p0_axis_p0_axis_ib_axi4_s),
  .bready_axi4_s        (bready_p0_axis_p0_axis_ib_axi4_s),
  .arid_axi4_s          (arid_p0_axis_p0_axis_ib_axi4_s),
  .araddr_axi4_s        (araddr_p0_axis_p0_axis_ib_axi4_s),
  .arlen_axi4_s         (arlen_p0_axis_p0_axis_ib_axi4_s),
  .arsize_axi4_s        (arsize_p0_axis_p0_axis_ib_axi4_s),
  .arburst_axi4_s       (arburst_p0_axis_p0_axis_ib_axi4_s),
  .arlock_axi4_s        (arlock_p0_axis_p0_axis_ib_axi4_s),
  .arcache_axi4_s       (arcache_p0_axis_p0_axis_ib_axi4_s),
  .arprot_axi4_s        (arprot_p0_axis_p0_axis_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_p0_axis_p0_axis_ib_axi4_s),
  .arvalid_vect_axi4_s  (arvalid_vect_p0_axis_p0_axis_ib_axi4_s),
  .arready_axi4_s       (arready_p0_axis_p0_axis_ib_axi4_s),
  .rid_axi4_s           (rid_p0_axis_p0_axis_ib_axi4_s),
  .rdata_axi4_s         (rdata_p0_axis_p0_axis_ib_axi4_s),
  .rresp_axi4_s         (rresp_p0_axis_p0_axis_ib_axi4_s),
  .rlast_axi4_s         (rlast_p0_axis_p0_axis_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_p0_axis_p0_axis_ib_axi4_s),
  .rready_axi4_s        (rready_p0_axis_p0_axis_ib_axi4_s),
  .awuser_axi4_s        (awuser_p0_axis_p0_axis_ib_axi4_s),
  .aruser_axi4_s        (aruser_p0_axis_p0_axis_ib_axi4_s),
  .aclk                 (mainclk),
  .aresetn              (mainresetn),
  .aw_data              (aw_data_p0_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_p0_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_p0_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_p0_axis_ib_int),
  .b_data               (b_data_p0_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_p0_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_p0_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_p0_axis_ib_int),
  .ar_data              (ar_data_p0_axis_ib_int),
  .ar_valid             (ar_valid_p0_axis_ib_int),
  .ar_ready             (ar_ready_p0_axis_ib_int),
  .r_data               (r_data_p0_axis_ib_int),
  .r_valid              (r_valid_p0_axis_ib_int),
  .r_ready              (r_ready_p0_axis_ib_int),
  .w_data               (w_data_p0_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_p0_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_p0_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_p0_axis_ib_int)
);


nic400_ib_p1_axis_ib_master_domain_sse710_dbg3s1m     u_ib_p1_axis_ib_m (
  .awid_axi4_m          (awid_p1_axis_ib_switch0_axi_s_1),
  .awaddr_axi4_m        (awaddr_p1_axis_ib_switch0_axi_s_1),
  .awlen_axi4_m         (awlen_p1_axis_ib_switch0_axi_s_1),
  .awsize_axi4_m        (awsize_p1_axis_ib_switch0_axi_s_1),
  .awburst_axi4_m       (awburst_p1_axis_ib_switch0_axi_s_1),
  .awlock_axi4_m        (awlock_p1_axis_ib_switch0_axi_s_1),
  .awcache_axi4_m       (awcache_p1_axis_ib_switch0_axi_s_1),
  .awprot_axi4_m        (awprot_p1_axis_ib_switch0_axi_s_1),
  .awvalid_axi4_m       (awvalid_p1_axis_ib_switch0_axi_s_1),
  .awvalid_vect_axi4_m  (awvalid_vect_p1_axis_ib_switch0_axi_s_1),
  .awready_axi4_m       (awready_p1_axis_ib_switch0_axi_s_1),
  .wdata_axi4_m         (wdata_p1_axis_ib_switch0_axi_s_1),
  .wstrb_axi4_m         (wstrb_p1_axis_ib_switch0_axi_s_1),
  .wlast_axi4_m         (wlast_p1_axis_ib_switch0_axi_s_1),
  .wvalid_axi4_m        (wvalid_p1_axis_ib_switch0_axi_s_1),
  .wready_axi4_m        (wready_p1_axis_ib_switch0_axi_s_1),
  .bid_axi4_m           (bid_p1_axis_ib_switch0_axi_s_1),
  .bresp_axi4_m         (bresp_p1_axis_ib_switch0_axi_s_1),
  .bvalid_axi4_m        (bvalid_p1_axis_ib_switch0_axi_s_1),
  .bready_axi4_m        (bready_p1_axis_ib_switch0_axi_s_1),
  .arid_axi4_m          (arid_p1_axis_ib_switch0_axi_s_1),
  .araddr_axi4_m        (araddr_p1_axis_ib_switch0_axi_s_1),
  .arlen_axi4_m         (arlen_p1_axis_ib_switch0_axi_s_1),
  .arsize_axi4_m        (arsize_p1_axis_ib_switch0_axi_s_1),
  .arburst_axi4_m       (arburst_p1_axis_ib_switch0_axi_s_1),
  .arlock_axi4_m        (arlock_p1_axis_ib_switch0_axi_s_1),
  .arcache_axi4_m       (arcache_p1_axis_ib_switch0_axi_s_1),
  .arprot_axi4_m        (arprot_p1_axis_ib_switch0_axi_s_1),
  .arvalid_axi4_m       (arvalid_p1_axis_ib_switch0_axi_s_1),
  .arvalid_vect_axi4_m  (arvalid_vect_p1_axis_ib_switch0_axi_s_1),
  .arready_axi4_m       (arready_p1_axis_ib_switch0_axi_s_1),
  .rid_axi4_m           (rid_p1_axis_ib_switch0_axi_s_1),
  .rdata_axi4_m         (rdata_p1_axis_ib_switch0_axi_s_1),
  .rresp_axi4_m         (rresp_p1_axis_ib_switch0_axi_s_1),
  .rlast_axi4_m         (rlast_p1_axis_ib_switch0_axi_s_1),
  .rvalid_axi4_m        (rvalid_p1_axis_ib_switch0_axi_s_1),
  .rready_axi4_m        (rready_p1_axis_ib_switch0_axi_s_1),
  .awuser_axi4_m        (awuser_p1_axis_ib_switch0_axi_s_1),
  .aruser_axi4_m        (aruser_p1_axis_ib_switch0_axi_s_1),
  .awqv_axi4_m          (awqv_p1_axis_ib_switch0_axi_s_1),
  .arqv_axi4_m          (arqv_p1_axis_ib_switch0_axi_s_1),
  .aclk                 (mainclk),
  .aresetn              (mainresetn),
  .aw_data              (aw_data_p1_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_p1_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_p1_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_p1_axis_ib_int),
  .b_data               (b_data_p1_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_p1_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_p1_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_p1_axis_ib_int),
  .ar_data              (ar_data_p1_axis_ib_int),
  .ar_valid             (ar_valid_p1_axis_ib_int),
  .ar_ready             (ar_ready_p1_axis_ib_int),
  .r_data               (r_data_p1_axis_ib_int),
  .r_valid              (r_valid_p1_axis_ib_int),
  .r_ready              (r_ready_p1_axis_ib_int),
  .w_data               (w_data_p1_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_p1_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_p1_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_p1_axis_ib_int)
);


nic400_ib_p1_axis_ib_slave_domain_sse710_dbg3s1m     u_ib_p1_axis_ib_s (
  .awid_axi4_s          (awid_p1_axis_p1_axis_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_p1_axis_p1_axis_ib_axi4_s),
  .awlen_axi4_s         (awlen_p1_axis_p1_axis_ib_axi4_s),
  .awsize_axi4_s        (awsize_p1_axis_p1_axis_ib_axi4_s),
  .awburst_axi4_s       (awburst_p1_axis_p1_axis_ib_axi4_s),
  .awlock_axi4_s        (awlock_p1_axis_p1_axis_ib_axi4_s),
  .awcache_axi4_s       (awcache_p1_axis_p1_axis_ib_axi4_s),
  .awprot_axi4_s        (awprot_p1_axis_p1_axis_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_p1_axis_p1_axis_ib_axi4_s),
  .awvalid_vect_axi4_s  (awvalid_vect_p1_axis_p1_axis_ib_axi4_s),
  .awready_axi4_s       (awready_p1_axis_p1_axis_ib_axi4_s),
  .wdata_axi4_s         (wdata_p1_axis_p1_axis_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_p1_axis_p1_axis_ib_axi4_s),
  .wlast_axi4_s         (wlast_p1_axis_p1_axis_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_p1_axis_p1_axis_ib_axi4_s),
  .wready_axi4_s        (wready_p1_axis_p1_axis_ib_axi4_s),
  .bid_axi4_s           (bid_p1_axis_p1_axis_ib_axi4_s),
  .bresp_axi4_s         (bresp_p1_axis_p1_axis_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_p1_axis_p1_axis_ib_axi4_s),
  .bready_axi4_s        (bready_p1_axis_p1_axis_ib_axi4_s),
  .arid_axi4_s          (arid_p1_axis_p1_axis_ib_axi4_s),
  .araddr_axi4_s        (araddr_p1_axis_p1_axis_ib_axi4_s),
  .arlen_axi4_s         (arlen_p1_axis_p1_axis_ib_axi4_s),
  .arsize_axi4_s        (arsize_p1_axis_p1_axis_ib_axi4_s),
  .arburst_axi4_s       (arburst_p1_axis_p1_axis_ib_axi4_s),
  .arlock_axi4_s        (arlock_p1_axis_p1_axis_ib_axi4_s),
  .arcache_axi4_s       (arcache_p1_axis_p1_axis_ib_axi4_s),
  .arprot_axi4_s        (arprot_p1_axis_p1_axis_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_p1_axis_p1_axis_ib_axi4_s),
  .arvalid_vect_axi4_s  (arvalid_vect_p1_axis_p1_axis_ib_axi4_s),
  .arready_axi4_s       (arready_p1_axis_p1_axis_ib_axi4_s),
  .rid_axi4_s           (rid_p1_axis_p1_axis_ib_axi4_s),
  .rdata_axi4_s         (rdata_p1_axis_p1_axis_ib_axi4_s),
  .rresp_axi4_s         (rresp_p1_axis_p1_axis_ib_axi4_s),
  .rlast_axi4_s         (rlast_p1_axis_p1_axis_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_p1_axis_p1_axis_ib_axi4_s),
  .rready_axi4_s        (rready_p1_axis_p1_axis_ib_axi4_s),
  .awuser_axi4_s        (awuser_p1_axis_p1_axis_ib_axi4_s),
  .aruser_axi4_s        (aruser_p1_axis_p1_axis_ib_axi4_s),
  .aclk                 (mainclk),
  .aresetn              (mainresetn),
  .aw_data              (aw_data_p1_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_p1_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_p1_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_p1_axis_ib_int),
  .b_data               (b_data_p1_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_p1_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_p1_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_p1_axis_ib_int),
  .ar_data              (ar_data_p1_axis_ib_int),
  .ar_valid             (ar_valid_p1_axis_ib_int),
  .ar_ready             (ar_ready_p1_axis_ib_int),
  .r_data               (r_data_p1_axis_ib_int),
  .r_valid              (r_valid_p1_axis_ib_int),
  .r_ready              (r_ready_p1_axis_ib_int),
  .w_data               (w_data_p1_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_p1_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_p1_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_p1_axis_ib_int)
);



endmodule
