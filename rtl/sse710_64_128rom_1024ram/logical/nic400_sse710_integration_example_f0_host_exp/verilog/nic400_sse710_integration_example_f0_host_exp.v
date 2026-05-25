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




module nic400_sse710_integration_example_f0_host_exp (
  

  awid_extsys0_axi_m,
  awaddr_extsys0_axi_m,
  awlen_extsys0_axi_m,
  awsize_extsys0_axi_m,
  awburst_extsys0_axi_m,
  awlock_extsys0_axi_m,
  awcache_extsys0_axi_m,
  awprot_extsys0_axi_m,
  awvalid_extsys0_axi_m,
  awready_extsys0_axi_m,
  wdata_extsys0_axi_m,
  wstrb_extsys0_axi_m,
  wlast_extsys0_axi_m,
  wvalid_extsys0_axi_m,
  wready_extsys0_axi_m,
  bid_extsys0_axi_m,
  bresp_extsys0_axi_m,
  bvalid_extsys0_axi_m,
  bready_extsys0_axi_m,
  arid_extsys0_axi_m,
  araddr_extsys0_axi_m,
  arlen_extsys0_axi_m,
  arsize_extsys0_axi_m,
  arburst_extsys0_axi_m,
  arlock_extsys0_axi_m,
  arcache_extsys0_axi_m,
  arprot_extsys0_axi_m,
  arvalid_extsys0_axi_m,
  arready_extsys0_axi_m,
  rid_extsys0_axi_m,
  rdata_extsys0_axi_m,
  rresp_extsys0_axi_m,
  rlast_extsys0_axi_m,
  rvalid_extsys0_axi_m,
  rready_extsys0_axi_m,
  

  paddr_extsys0_ppu_abp_m,
  pselx_extsys0_ppu_abp_m,
  penable_extsys0_ppu_abp_m,
  pwrite_extsys0_ppu_abp_m,
  prdata_extsys0_ppu_abp_m,
  pwdata_extsys0_ppu_abp_m,
  pready_extsys0_ppu_abp_m,
  pslverr_extsys0_ppu_abp_m,
  

  awid_extsys1_axi_m,
  awaddr_extsys1_axi_m,
  awlen_extsys1_axi_m,
  awsize_extsys1_axi_m,
  awburst_extsys1_axi_m,
  awlock_extsys1_axi_m,
  awcache_extsys1_axi_m,
  awprot_extsys1_axi_m,
  awvalid_extsys1_axi_m,
  awready_extsys1_axi_m,
  wdata_extsys1_axi_m,
  wstrb_extsys1_axi_m,
  wlast_extsys1_axi_m,
  wvalid_extsys1_axi_m,
  wready_extsys1_axi_m,
  bid_extsys1_axi_m,
  bresp_extsys1_axi_m,
  bvalid_extsys1_axi_m,
  bready_extsys1_axi_m,
  arid_extsys1_axi_m,
  araddr_extsys1_axi_m,
  arlen_extsys1_axi_m,
  arsize_extsys1_axi_m,
  arburst_extsys1_axi_m,
  arlock_extsys1_axi_m,
  arcache_extsys1_axi_m,
  arprot_extsys1_axi_m,
  arvalid_extsys1_axi_m,
  arready_extsys1_axi_m,
  rid_extsys1_axi_m,
  rdata_extsys1_axi_m,
  rresp_extsys1_axi_m,
  rlast_extsys1_axi_m,
  rvalid_extsys1_axi_m,
  rready_extsys1_axi_m,
  

  paddr_extsys1_ppu_abp_m,
  pselx_extsys1_ppu_abp_m,
  penable_extsys1_ppu_abp_m,
  pwrite_extsys1_ppu_abp_m,
  prdata_extsys1_ppu_abp_m,
  pwdata_extsys1_ppu_abp_m,
  pready_extsys1_ppu_abp_m,
  pslverr_extsys1_ppu_abp_m,
  

  awid_hostexpmst_0_s,
  awaddr_hostexpmst_0_s,
  awlen_hostexpmst_0_s,
  awsize_hostexpmst_0_s,
  awburst_hostexpmst_0_s,
  awlock_hostexpmst_0_s,
  awcache_hostexpmst_0_s,
  awprot_hostexpmst_0_s,
  awvalid_hostexpmst_0_s,
  awready_hostexpmst_0_s,
  wdata_hostexpmst_0_s,
  wstrb_hostexpmst_0_s,
  wlast_hostexpmst_0_s,
  wvalid_hostexpmst_0_s,
  wready_hostexpmst_0_s,
  bid_hostexpmst_0_s,
  bresp_hostexpmst_0_s,
  bvalid_hostexpmst_0_s,
  bready_hostexpmst_0_s,
  arid_hostexpmst_0_s,
  araddr_hostexpmst_0_s,
  arlen_hostexpmst_0_s,
  arsize_hostexpmst_0_s,
  arburst_hostexpmst_0_s,
  arlock_hostexpmst_0_s,
  arcache_hostexpmst_0_s,
  arprot_hostexpmst_0_s,
  arvalid_hostexpmst_0_s,
  arready_hostexpmst_0_s,
  rid_hostexpmst_0_s,
  rdata_hostexpmst_0_s,
  rresp_hostexpmst_0_s,
  rlast_hostexpmst_0_s,
  rvalid_hostexpmst_0_s,
  rready_hostexpmst_0_s,
  

  awid_hostexpmst_1_s,
  awaddr_hostexpmst_1_s,
  awlen_hostexpmst_1_s,
  awsize_hostexpmst_1_s,
  awburst_hostexpmst_1_s,
  awlock_hostexpmst_1_s,
  awcache_hostexpmst_1_s,
  awprot_hostexpmst_1_s,
  awvalid_hostexpmst_1_s,
  awready_hostexpmst_1_s,
  wdata_hostexpmst_1_s,
  wstrb_hostexpmst_1_s,
  wlast_hostexpmst_1_s,
  wvalid_hostexpmst_1_s,
  wready_hostexpmst_1_s,
  bid_hostexpmst_1_s,
  bresp_hostexpmst_1_s,
  bvalid_hostexpmst_1_s,
  bready_hostexpmst_1_s,
  arid_hostexpmst_1_s,
  araddr_hostexpmst_1_s,
  arlen_hostexpmst_1_s,
  arsize_hostexpmst_1_s,
  arburst_hostexpmst_1_s,
  arlock_hostexpmst_1_s,
  arcache_hostexpmst_1_s,
  arprot_hostexpmst_1_s,
  arvalid_hostexpmst_1_s,
  arready_hostexpmst_1_s,
  rid_hostexpmst_1_s,
  rdata_hostexpmst_1_s,
  rresp_hostexpmst_1_s,
  rlast_hostexpmst_1_s,
  rvalid_hostexpmst_1_s,
  rready_hostexpmst_1_s,
  

  paddr_vultan_apb_m,
  pselx_vultan_apb_m,
  penable_vultan_apb_m,
  pwrite_vultan_apb_m,
  prdata_vultan_apb_m,
  pwdata_vultan_apb_m,
  pprot_vultan_apb_m,
  pstrb_vultan_apb_m,
  pready_vultan_apb_m,
  pslverr_vultan_apb_m,
  

  haddr_gpio_ahb_m,
  hburst_gpio_ahb_m,
  hprot_gpio_ahb_m,
  hsize_gpio_ahb_m,
  htrans_gpio_ahb_m,
  hwdata_gpio_ahb_m,
  hwrite_gpio_ahb_m,
  hrdata_gpio_ahb_m,
  hreadyout_gpio_ahb_m,
  hresp_gpio_ahb_m,
  hselx_gpio_ahb_m,
  hready_gpio_ahb_m,


  aclkoutclk,
  aclkoutclken,
  aclkoutresetn,
  refclk,
  refresetn

);






output [17:0] awid_extsys0_axi_m;
output [31:0] awaddr_extsys0_axi_m;
output [7:0]  awlen_extsys0_axi_m;
output [2:0]  awsize_extsys0_axi_m;
output [1:0]  awburst_extsys0_axi_m;
output        awlock_extsys0_axi_m;
output [3:0]  awcache_extsys0_axi_m;
output [2:0]  awprot_extsys0_axi_m;
output        awvalid_extsys0_axi_m;
input         awready_extsys0_axi_m;
output [31:0] wdata_extsys0_axi_m;
output [3:0]  wstrb_extsys0_axi_m;
output        wlast_extsys0_axi_m;
output        wvalid_extsys0_axi_m;
input         wready_extsys0_axi_m;
input  [17:0] bid_extsys0_axi_m;
input  [1:0]  bresp_extsys0_axi_m;
input         bvalid_extsys0_axi_m;
output        bready_extsys0_axi_m;
output [17:0] arid_extsys0_axi_m;
output [31:0] araddr_extsys0_axi_m;
output [7:0]  arlen_extsys0_axi_m;
output [2:0]  arsize_extsys0_axi_m;
output [1:0]  arburst_extsys0_axi_m;
output        arlock_extsys0_axi_m;
output [3:0]  arcache_extsys0_axi_m;
output [2:0]  arprot_extsys0_axi_m;
output        arvalid_extsys0_axi_m;
input         arready_extsys0_axi_m;
input  [17:0] rid_extsys0_axi_m;
input  [31:0] rdata_extsys0_axi_m;
input  [1:0]  rresp_extsys0_axi_m;
input         rlast_extsys0_axi_m;
input         rvalid_extsys0_axi_m;
output        rready_extsys0_axi_m;


output [31:0] paddr_extsys0_ppu_abp_m;
output        pselx_extsys0_ppu_abp_m;
output        penable_extsys0_ppu_abp_m;
output        pwrite_extsys0_ppu_abp_m;
input  [31:0] prdata_extsys0_ppu_abp_m;
output [31:0] pwdata_extsys0_ppu_abp_m;
input         pready_extsys0_ppu_abp_m;
input         pslverr_extsys0_ppu_abp_m;


output [17:0] awid_extsys1_axi_m;
output [31:0] awaddr_extsys1_axi_m;
output [7:0]  awlen_extsys1_axi_m;
output [2:0]  awsize_extsys1_axi_m;
output [1:0]  awburst_extsys1_axi_m;
output        awlock_extsys1_axi_m;
output [3:0]  awcache_extsys1_axi_m;
output [2:0]  awprot_extsys1_axi_m;
output        awvalid_extsys1_axi_m;
input         awready_extsys1_axi_m;
output [31:0] wdata_extsys1_axi_m;
output [3:0]  wstrb_extsys1_axi_m;
output        wlast_extsys1_axi_m;
output        wvalid_extsys1_axi_m;
input         wready_extsys1_axi_m;
input  [17:0] bid_extsys1_axi_m;
input  [1:0]  bresp_extsys1_axi_m;
input         bvalid_extsys1_axi_m;
output        bready_extsys1_axi_m;
output [17:0] arid_extsys1_axi_m;
output [31:0] araddr_extsys1_axi_m;
output [7:0]  arlen_extsys1_axi_m;
output [2:0]  arsize_extsys1_axi_m;
output [1:0]  arburst_extsys1_axi_m;
output        arlock_extsys1_axi_m;
output [3:0]  arcache_extsys1_axi_m;
output [2:0]  arprot_extsys1_axi_m;
output        arvalid_extsys1_axi_m;
input         arready_extsys1_axi_m;
input  [17:0] rid_extsys1_axi_m;
input  [31:0] rdata_extsys1_axi_m;
input  [1:0]  rresp_extsys1_axi_m;
input         rlast_extsys1_axi_m;
input         rvalid_extsys1_axi_m;
output        rready_extsys1_axi_m;


output [31:0] paddr_extsys1_ppu_abp_m;
output        pselx_extsys1_ppu_abp_m;
output        penable_extsys1_ppu_abp_m;
output        pwrite_extsys1_ppu_abp_m;
input  [31:0] prdata_extsys1_ppu_abp_m;
output [31:0] pwdata_extsys1_ppu_abp_m;
input         pready_extsys1_ppu_abp_m;
input         pslverr_extsys1_ppu_abp_m;


input  [15:0] awid_hostexpmst_0_s;
input  [31:0] awaddr_hostexpmst_0_s;
input  [7:0]  awlen_hostexpmst_0_s;
input  [2:0]  awsize_hostexpmst_0_s;
input  [1:0]  awburst_hostexpmst_0_s;
input         awlock_hostexpmst_0_s;
input  [3:0]  awcache_hostexpmst_0_s;
input  [2:0]  awprot_hostexpmst_0_s;
input         awvalid_hostexpmst_0_s;
output        awready_hostexpmst_0_s;
input  [63:0] wdata_hostexpmst_0_s;
input  [7:0]  wstrb_hostexpmst_0_s;
input         wlast_hostexpmst_0_s;
input         wvalid_hostexpmst_0_s;
output        wready_hostexpmst_0_s;
output [15:0] bid_hostexpmst_0_s;
output [1:0]  bresp_hostexpmst_0_s;
output        bvalid_hostexpmst_0_s;
input         bready_hostexpmst_0_s;
input  [15:0] arid_hostexpmst_0_s;
input  [31:0] araddr_hostexpmst_0_s;
input  [7:0]  arlen_hostexpmst_0_s;
input  [2:0]  arsize_hostexpmst_0_s;
input  [1:0]  arburst_hostexpmst_0_s;
input         arlock_hostexpmst_0_s;
input  [3:0]  arcache_hostexpmst_0_s;
input  [2:0]  arprot_hostexpmst_0_s;
input         arvalid_hostexpmst_0_s;
output        arready_hostexpmst_0_s;
output [15:0] rid_hostexpmst_0_s;
output [63:0] rdata_hostexpmst_0_s;
output [1:0]  rresp_hostexpmst_0_s;
output        rlast_hostexpmst_0_s;
output        rvalid_hostexpmst_0_s;
input         rready_hostexpmst_0_s;


input  [15:0] awid_hostexpmst_1_s;
input  [31:0] awaddr_hostexpmst_1_s;
input  [7:0]  awlen_hostexpmst_1_s;
input  [2:0]  awsize_hostexpmst_1_s;
input  [1:0]  awburst_hostexpmst_1_s;
input         awlock_hostexpmst_1_s;
input  [3:0]  awcache_hostexpmst_1_s;
input  [2:0]  awprot_hostexpmst_1_s;
input         awvalid_hostexpmst_1_s;
output        awready_hostexpmst_1_s;
input  [63:0] wdata_hostexpmst_1_s;
input  [7:0]  wstrb_hostexpmst_1_s;
input         wlast_hostexpmst_1_s;
input         wvalid_hostexpmst_1_s;
output        wready_hostexpmst_1_s;
output [15:0] bid_hostexpmst_1_s;
output [1:0]  bresp_hostexpmst_1_s;
output        bvalid_hostexpmst_1_s;
input         bready_hostexpmst_1_s;
input  [15:0] arid_hostexpmst_1_s;
input  [31:0] araddr_hostexpmst_1_s;
input  [7:0]  arlen_hostexpmst_1_s;
input  [2:0]  arsize_hostexpmst_1_s;
input  [1:0]  arburst_hostexpmst_1_s;
input         arlock_hostexpmst_1_s;
input  [3:0]  arcache_hostexpmst_1_s;
input  [2:0]  arprot_hostexpmst_1_s;
input         arvalid_hostexpmst_1_s;
output        arready_hostexpmst_1_s;
output [15:0] rid_hostexpmst_1_s;
output [63:0] rdata_hostexpmst_1_s;
output [1:0]  rresp_hostexpmst_1_s;
output        rlast_hostexpmst_1_s;
output        rvalid_hostexpmst_1_s;
input         rready_hostexpmst_1_s;


output [31:0] paddr_vultan_apb_m;
output        pselx_vultan_apb_m;
output        penable_vultan_apb_m;
output        pwrite_vultan_apb_m;
input  [31:0] prdata_vultan_apb_m;
output [31:0] pwdata_vultan_apb_m;
output [2:0]  pprot_vultan_apb_m;
output [3:0]  pstrb_vultan_apb_m;
input         pready_vultan_apb_m;
input         pslverr_vultan_apb_m;


output [31:0] haddr_gpio_ahb_m;
output [2:0]  hburst_gpio_ahb_m;
output [3:0]  hprot_gpio_ahb_m;
output [2:0]  hsize_gpio_ahb_m;
output [1:0]  htrans_gpio_ahb_m;
output [31:0] hwdata_gpio_ahb_m;
output        hwrite_gpio_ahb_m;
input  [31:0] hrdata_gpio_ahb_m;
input         hreadyout_gpio_ahb_m;
input         hresp_gpio_ahb_m;
output        hselx_gpio_ahb_m;
output        hready_gpio_ahb_m;


input         aclkoutclk;
input         aclkoutclken;
input         aclkoutresetn;
input         refclk;
input         refresetn;




wire   [31:0]  araddr_extsys0_axi_m;
wire   [31:0]  araddr_extsys1_axi_m;
wire   [1:0]   arburst_extsys0_axi_m;
wire   [1:0]   arburst_extsys1_axi_m;
wire   [3:0]   arcache_extsys0_axi_m;
wire   [3:0]   arcache_extsys1_axi_m;
wire   [17:0]  arid_extsys0_axi_m;
wire   [17:0]  arid_extsys1_axi_m;
wire   [7:0]   arlen_extsys0_axi_m;
wire   [7:0]   arlen_extsys1_axi_m;
wire           arlock_extsys0_axi_m;
wire           arlock_extsys1_axi_m;
wire   [2:0]   arprot_extsys0_axi_m;
wire   [2:0]   arprot_extsys1_axi_m;
wire           arready_hostexpmst_0_s;
wire           arready_hostexpmst_1_s;
wire   [2:0]   arsize_extsys0_axi_m;
wire   [2:0]   arsize_extsys1_axi_m;
wire           arvalid_extsys0_axi_m;
wire           arvalid_extsys1_axi_m;
wire   [31:0]  awaddr_extsys0_axi_m;
wire   [31:0]  awaddr_extsys1_axi_m;
wire   [1:0]   awburst_extsys0_axi_m;
wire   [1:0]   awburst_extsys1_axi_m;
wire   [3:0]   awcache_extsys0_axi_m;
wire   [3:0]   awcache_extsys1_axi_m;
wire   [17:0]  awid_extsys0_axi_m;
wire   [17:0]  awid_extsys1_axi_m;
wire   [7:0]   awlen_extsys0_axi_m;
wire   [7:0]   awlen_extsys1_axi_m;
wire           awlock_extsys0_axi_m;
wire           awlock_extsys1_axi_m;
wire   [2:0]   awprot_extsys0_axi_m;
wire   [2:0]   awprot_extsys1_axi_m;
wire           awready_hostexpmst_0_s;
wire           awready_hostexpmst_1_s;
wire   [2:0]   awsize_extsys0_axi_m;
wire   [2:0]   awsize_extsys1_axi_m;
wire           awvalid_extsys0_axi_m;
wire           awvalid_extsys1_axi_m;
wire   [15:0]  bid_hostexpmst_0_s;
wire   [15:0]  bid_hostexpmst_1_s;
wire           bready_extsys0_axi_m;
wire           bready_extsys1_axi_m;
wire   [1:0]   bresp_hostexpmst_0_s;
wire   [1:0]   bresp_hostexpmst_1_s;
wire           bvalid_hostexpmst_0_s;
wire           bvalid_hostexpmst_1_s;
wire   [31:0]  haddr_gpio_ahb_m;
wire   [2:0]   hburst_gpio_ahb_m;
wire   [3:0]   hprot_gpio_ahb_m;
wire           hready_gpio_ahb_m;
wire           hselx_gpio_ahb_m;
wire   [2:0]   hsize_gpio_ahb_m;
wire   [1:0]   htrans_gpio_ahb_m;
wire   [31:0]  hwdata_gpio_ahb_m;
wire           hwrite_gpio_ahb_m;
wire   [31:0]  paddr_extsys0_ppu_abp_m;
wire   [31:0]  paddr_extsys1_ppu_abp_m;
wire   [31:0]  paddr_vultan_apb_m;
wire           penable_extsys0_ppu_abp_m;
wire           penable_extsys1_ppu_abp_m;
wire           penable_vultan_apb_m;
wire   [2:0]   pprot_vultan_apb_m;
wire           pselx_extsys0_ppu_abp_m;
wire           pselx_extsys1_ppu_abp_m;
wire           pselx_vultan_apb_m;
wire   [3:0]   pstrb_vultan_apb_m;
wire   [31:0]  pwdata_extsys0_ppu_abp_m;
wire   [31:0]  pwdata_extsys1_ppu_abp_m;
wire   [31:0]  pwdata_vultan_apb_m;
wire           pwrite_extsys0_ppu_abp_m;
wire           pwrite_extsys1_ppu_abp_m;
wire           pwrite_vultan_apb_m;
wire   [63:0]  rdata_hostexpmst_0_s;
wire   [63:0]  rdata_hostexpmst_1_s;
wire   [15:0]  rid_hostexpmst_0_s;
wire   [15:0]  rid_hostexpmst_1_s;
wire           rlast_hostexpmst_0_s;
wire           rlast_hostexpmst_1_s;
wire           rready_extsys0_axi_m;
wire           rready_extsys1_axi_m;
wire   [1:0]   rresp_hostexpmst_0_s;
wire   [1:0]   rresp_hostexpmst_1_s;
wire           rvalid_hostexpmst_0_s;
wire           rvalid_hostexpmst_1_s;
wire   [31:0]  wdata_extsys0_axi_m;
wire   [31:0]  wdata_extsys1_axi_m;
wire           wlast_extsys0_axi_m;
wire           wlast_extsys1_axi_m;
wire           wready_hostexpmst_0_s;
wire           wready_hostexpmst_1_s;
wire   [3:0]   wstrb_extsys0_axi_m;
wire   [3:0]   wstrb_extsys1_axi_m;
wire           wvalid_extsys0_axi_m;
wire           wvalid_extsys1_axi_m;
wire   [88:0]  a_data_gpio_ahb_m_ib_int_async;    
wire   [3:0]   a_wpntr_gry_gpio_ahb_m_ib_int_async;    
wire   [2:0]   d_rpntr_bin_gpio_ahb_m_ib_int_async;    
wire   [3:0]   d_rpntr_gry_gpio_ahb_m_ib_int_async;    
wire   [72:0]  w_data_gpio_ahb_m_ib_int_async;    
wire   [3:0]   w_wpntr_gry_gpio_ahb_m_ib_int_async;    
wire   [2:0]   a_rpntr_bin_gpio_ahb_m_ib_int_async;    
wire   [3:0]   a_rpntr_gry_gpio_ahb_m_ib_int_async;    
wire   [87:0]  d_data_gpio_ahb_m_ib_int_async;    
wire   [3:0]   d_wpntr_gry_gpio_ahb_m_ib_int_async;    
wire   [2:0]   w_rpntr_bin_gpio_ahb_m_ib_int_async;    
wire   [3:0]   w_rpntr_gry_gpio_ahb_m_ib_int_async;    
wire           aclkoutclk;
wire           aclkoutclken;
wire           aclkoutresetn;
wire   [31:0]  araddr_hostexpmst_0_s;
wire   [31:0]  araddr_hostexpmst_1_s;
wire   [1:0]   arburst_hostexpmst_0_s;
wire   [1:0]   arburst_hostexpmst_1_s;
wire   [3:0]   arcache_hostexpmst_0_s;
wire   [3:0]   arcache_hostexpmst_1_s;
wire   [15:0]  arid_hostexpmst_0_s;
wire   [15:0]  arid_hostexpmst_1_s;
wire   [7:0]   arlen_hostexpmst_0_s;
wire   [7:0]   arlen_hostexpmst_1_s;
wire           arlock_hostexpmst_0_s;
wire           arlock_hostexpmst_1_s;
wire   [2:0]   arprot_hostexpmst_0_s;
wire   [2:0]   arprot_hostexpmst_1_s;
wire           arready_extsys0_axi_m;
wire           arready_extsys1_axi_m;
wire   [2:0]   arsize_hostexpmst_0_s;
wire   [2:0]   arsize_hostexpmst_1_s;
wire           arvalid_hostexpmst_0_s;
wire           arvalid_hostexpmst_1_s;
wire   [31:0]  awaddr_hostexpmst_0_s;
wire   [31:0]  awaddr_hostexpmst_1_s;
wire   [1:0]   awburst_hostexpmst_0_s;
wire   [1:0]   awburst_hostexpmst_1_s;
wire   [3:0]   awcache_hostexpmst_0_s;
wire   [3:0]   awcache_hostexpmst_1_s;
wire   [15:0]  awid_hostexpmst_0_s;
wire   [15:0]  awid_hostexpmst_1_s;
wire   [7:0]   awlen_hostexpmst_0_s;
wire   [7:0]   awlen_hostexpmst_1_s;
wire           awlock_hostexpmst_0_s;
wire           awlock_hostexpmst_1_s;
wire   [2:0]   awprot_hostexpmst_0_s;
wire   [2:0]   awprot_hostexpmst_1_s;
wire           awready_extsys0_axi_m;
wire           awready_extsys1_axi_m;
wire   [2:0]   awsize_hostexpmst_0_s;
wire   [2:0]   awsize_hostexpmst_1_s;
wire           awvalid_hostexpmst_0_s;
wire           awvalid_hostexpmst_1_s;
wire   [17:0]  bid_extsys0_axi_m;
wire   [17:0]  bid_extsys1_axi_m;
wire           bready_hostexpmst_0_s;
wire           bready_hostexpmst_1_s;
wire   [1:0]   bresp_extsys0_axi_m;
wire   [1:0]   bresp_extsys1_axi_m;
wire           bvalid_extsys0_axi_m;
wire           bvalid_extsys1_axi_m;
wire   [31:0]  hrdata_gpio_ahb_m;
wire           hreadyout_gpio_ahb_m;
wire           hresp_gpio_ahb_m;
wire   [31:0]  prdata_extsys0_ppu_abp_m;
wire   [31:0]  prdata_extsys1_ppu_abp_m;
wire   [31:0]  prdata_vultan_apb_m;
wire           pready_extsys0_ppu_abp_m;
wire           pready_extsys1_ppu_abp_m;
wire           pready_vultan_apb_m;
wire           pslverr_extsys0_ppu_abp_m;
wire           pslverr_extsys1_ppu_abp_m;
wire           pslverr_vultan_apb_m;
wire   [31:0]  rdata_extsys0_axi_m;
wire   [31:0]  rdata_extsys1_axi_m;
wire           refclk;
wire           refresetn;
wire   [17:0]  rid_extsys0_axi_m;
wire   [17:0]  rid_extsys1_axi_m;
wire           rlast_extsys0_axi_m;
wire           rlast_extsys1_axi_m;
wire           rready_hostexpmst_0_s;
wire           rready_hostexpmst_1_s;
wire   [1:0]   rresp_extsys0_axi_m;
wire   [1:0]   rresp_extsys1_axi_m;
wire           rvalid_extsys0_axi_m;
wire           rvalid_extsys1_axi_m;
wire   [63:0]  wdata_hostexpmst_0_s;
wire   [63:0]  wdata_hostexpmst_1_s;
wire           wlast_hostexpmst_0_s;
wire           wlast_hostexpmst_1_s;
wire           wready_extsys0_axi_m;
wire           wready_extsys1_axi_m;
wire   [7:0]   wstrb_hostexpmst_0_s;
wire   [7:0]   wstrb_hostexpmst_1_s;
wire           wvalid_hostexpmst_0_s;
wire           wvalid_hostexpmst_1_s;




nic400_cd_aclkout_sse710_integration_example_f0_host_exp     u_cd_aclkout (
  .awid_extsys0_axi_m   (awid_extsys0_axi_m),    
  .awaddr_extsys0_axi_m (awaddr_extsys0_axi_m),    
  .awlen_extsys0_axi_m  (awlen_extsys0_axi_m),    
  .awsize_extsys0_axi_m (awsize_extsys0_axi_m),    
  .awburst_extsys0_axi_m (awburst_extsys0_axi_m),    
  .awlock_extsys0_axi_m (awlock_extsys0_axi_m),    
  .awcache_extsys0_axi_m (awcache_extsys0_axi_m),    
  .awprot_extsys0_axi_m (awprot_extsys0_axi_m),    
  .awvalid_extsys0_axi_m (awvalid_extsys0_axi_m),    
  .awready_extsys0_axi_m (awready_extsys0_axi_m),    
  .wdata_extsys0_axi_m  (wdata_extsys0_axi_m),    
  .wstrb_extsys0_axi_m  (wstrb_extsys0_axi_m),    
  .wlast_extsys0_axi_m  (wlast_extsys0_axi_m),    
  .wvalid_extsys0_axi_m (wvalid_extsys0_axi_m),    
  .wready_extsys0_axi_m (wready_extsys0_axi_m),    
  .bid_extsys0_axi_m    (bid_extsys0_axi_m),    
  .bresp_extsys0_axi_m  (bresp_extsys0_axi_m),    
  .bvalid_extsys0_axi_m (bvalid_extsys0_axi_m),    
  .bready_extsys0_axi_m (bready_extsys0_axi_m),    
  .arid_extsys0_axi_m   (arid_extsys0_axi_m),    
  .araddr_extsys0_axi_m (araddr_extsys0_axi_m),    
  .arlen_extsys0_axi_m  (arlen_extsys0_axi_m),    
  .arsize_extsys0_axi_m (arsize_extsys0_axi_m),    
  .arburst_extsys0_axi_m (arburst_extsys0_axi_m),    
  .arlock_extsys0_axi_m (arlock_extsys0_axi_m),    
  .arcache_extsys0_axi_m (arcache_extsys0_axi_m),    
  .arprot_extsys0_axi_m (arprot_extsys0_axi_m),    
  .arvalid_extsys0_axi_m (arvalid_extsys0_axi_m),    
  .arready_extsys0_axi_m (arready_extsys0_axi_m),    
  .rid_extsys0_axi_m    (rid_extsys0_axi_m),    
  .rdata_extsys0_axi_m  (rdata_extsys0_axi_m),    
  .rresp_extsys0_axi_m  (rresp_extsys0_axi_m),    
  .rlast_extsys0_axi_m  (rlast_extsys0_axi_m),    
  .rvalid_extsys0_axi_m (rvalid_extsys0_axi_m),    
  .rready_extsys0_axi_m (rready_extsys0_axi_m),    
  .paddr_extsys0_ppu_abp_m (paddr_extsys0_ppu_abp_m),    
  .pselx_extsys0_ppu_abp_m (pselx_extsys0_ppu_abp_m),    
  .penable_extsys0_ppu_abp_m (penable_extsys0_ppu_abp_m),    
  .pwrite_extsys0_ppu_abp_m (pwrite_extsys0_ppu_abp_m),    
  .prdata_extsys0_ppu_abp_m (prdata_extsys0_ppu_abp_m),    
  .pwdata_extsys0_ppu_abp_m (pwdata_extsys0_ppu_abp_m),    
  .pready_extsys0_ppu_abp_m (pready_extsys0_ppu_abp_m),    
  .pslverr_extsys0_ppu_abp_m (pslverr_extsys0_ppu_abp_m),    
  .awid_extsys1_axi_m   (awid_extsys1_axi_m),    
  .awaddr_extsys1_axi_m (awaddr_extsys1_axi_m),    
  .awlen_extsys1_axi_m  (awlen_extsys1_axi_m),    
  .awsize_extsys1_axi_m (awsize_extsys1_axi_m),    
  .awburst_extsys1_axi_m (awburst_extsys1_axi_m),    
  .awlock_extsys1_axi_m (awlock_extsys1_axi_m),    
  .awcache_extsys1_axi_m (awcache_extsys1_axi_m),    
  .awprot_extsys1_axi_m (awprot_extsys1_axi_m),    
  .awvalid_extsys1_axi_m (awvalid_extsys1_axi_m),    
  .awready_extsys1_axi_m (awready_extsys1_axi_m),    
  .wdata_extsys1_axi_m  (wdata_extsys1_axi_m),    
  .wstrb_extsys1_axi_m  (wstrb_extsys1_axi_m),    
  .wlast_extsys1_axi_m  (wlast_extsys1_axi_m),    
  .wvalid_extsys1_axi_m (wvalid_extsys1_axi_m),    
  .wready_extsys1_axi_m (wready_extsys1_axi_m),    
  .bid_extsys1_axi_m    (bid_extsys1_axi_m),    
  .bresp_extsys1_axi_m  (bresp_extsys1_axi_m),    
  .bvalid_extsys1_axi_m (bvalid_extsys1_axi_m),    
  .bready_extsys1_axi_m (bready_extsys1_axi_m),    
  .arid_extsys1_axi_m   (arid_extsys1_axi_m),    
  .araddr_extsys1_axi_m (araddr_extsys1_axi_m),    
  .arlen_extsys1_axi_m  (arlen_extsys1_axi_m),    
  .arsize_extsys1_axi_m (arsize_extsys1_axi_m),    
  .arburst_extsys1_axi_m (arburst_extsys1_axi_m),    
  .arlock_extsys1_axi_m (arlock_extsys1_axi_m),    
  .arcache_extsys1_axi_m (arcache_extsys1_axi_m),    
  .arprot_extsys1_axi_m (arprot_extsys1_axi_m),    
  .arvalid_extsys1_axi_m (arvalid_extsys1_axi_m),    
  .arready_extsys1_axi_m (arready_extsys1_axi_m),    
  .rid_extsys1_axi_m    (rid_extsys1_axi_m),    
  .rdata_extsys1_axi_m  (rdata_extsys1_axi_m),    
  .rresp_extsys1_axi_m  (rresp_extsys1_axi_m),    
  .rlast_extsys1_axi_m  (rlast_extsys1_axi_m),    
  .rvalid_extsys1_axi_m (rvalid_extsys1_axi_m),    
  .rready_extsys1_axi_m (rready_extsys1_axi_m),    
  .paddr_extsys1_ppu_abp_m (paddr_extsys1_ppu_abp_m),    
  .pselx_extsys1_ppu_abp_m (pselx_extsys1_ppu_abp_m),    
  .penable_extsys1_ppu_abp_m (penable_extsys1_ppu_abp_m),    
  .pwrite_extsys1_ppu_abp_m (pwrite_extsys1_ppu_abp_m),    
  .prdata_extsys1_ppu_abp_m (prdata_extsys1_ppu_abp_m),    
  .pwdata_extsys1_ppu_abp_m (pwdata_extsys1_ppu_abp_m),    
  .pready_extsys1_ppu_abp_m (pready_extsys1_ppu_abp_m),    
  .pslverr_extsys1_ppu_abp_m (pslverr_extsys1_ppu_abp_m),    
  .a_data_gpio_ahb_m_ib_int_async (a_data_gpio_ahb_m_ib_int_async),    
  .a_wpntr_gry_gpio_ahb_m_ib_int_async (a_wpntr_gry_gpio_ahb_m_ib_int_async),    
  .a_rpntr_bin_gpio_ahb_m_ib_int_async (a_rpntr_bin_gpio_ahb_m_ib_int_async),    
  .a_rpntr_gry_gpio_ahb_m_ib_int_async (a_rpntr_gry_gpio_ahb_m_ib_int_async),    
  .w_data_gpio_ahb_m_ib_int_async (w_data_gpio_ahb_m_ib_int_async),    
  .w_wpntr_gry_gpio_ahb_m_ib_int_async (w_wpntr_gry_gpio_ahb_m_ib_int_async),    
  .w_rpntr_bin_gpio_ahb_m_ib_int_async (w_rpntr_bin_gpio_ahb_m_ib_int_async),    
  .w_rpntr_gry_gpio_ahb_m_ib_int_async (w_rpntr_gry_gpio_ahb_m_ib_int_async),    
  .d_data_gpio_ahb_m_ib_int_async (d_data_gpio_ahb_m_ib_int_async),    
  .d_wpntr_gry_gpio_ahb_m_ib_int_async (d_wpntr_gry_gpio_ahb_m_ib_int_async),    
  .d_rpntr_bin_gpio_ahb_m_ib_int_async (d_rpntr_bin_gpio_ahb_m_ib_int_async),    
  .d_rpntr_gry_gpio_ahb_m_ib_int_async (d_rpntr_gry_gpio_ahb_m_ib_int_async),    
  .awid_hostexpmst_0_s  (awid_hostexpmst_0_s),    
  .awaddr_hostexpmst_0_s (awaddr_hostexpmst_0_s),    
  .awlen_hostexpmst_0_s (awlen_hostexpmst_0_s),    
  .awsize_hostexpmst_0_s (awsize_hostexpmst_0_s),    
  .awburst_hostexpmst_0_s (awburst_hostexpmst_0_s),    
  .awlock_hostexpmst_0_s (awlock_hostexpmst_0_s),    
  .awcache_hostexpmst_0_s (awcache_hostexpmst_0_s),    
  .awprot_hostexpmst_0_s (awprot_hostexpmst_0_s),    
  .awvalid_hostexpmst_0_s (awvalid_hostexpmst_0_s),    
  .awready_hostexpmst_0_s (awready_hostexpmst_0_s),    
  .wdata_hostexpmst_0_s (wdata_hostexpmst_0_s),    
  .wstrb_hostexpmst_0_s (wstrb_hostexpmst_0_s),    
  .wlast_hostexpmst_0_s (wlast_hostexpmst_0_s),    
  .wvalid_hostexpmst_0_s (wvalid_hostexpmst_0_s),    
  .wready_hostexpmst_0_s (wready_hostexpmst_0_s),    
  .bid_hostexpmst_0_s   (bid_hostexpmst_0_s),    
  .bresp_hostexpmst_0_s (bresp_hostexpmst_0_s),    
  .bvalid_hostexpmst_0_s (bvalid_hostexpmst_0_s),    
  .bready_hostexpmst_0_s (bready_hostexpmst_0_s),    
  .arid_hostexpmst_0_s  (arid_hostexpmst_0_s),    
  .araddr_hostexpmst_0_s (araddr_hostexpmst_0_s),    
  .arlen_hostexpmst_0_s (arlen_hostexpmst_0_s),    
  .arsize_hostexpmst_0_s (arsize_hostexpmst_0_s),    
  .arburst_hostexpmst_0_s (arburst_hostexpmst_0_s),    
  .arlock_hostexpmst_0_s (arlock_hostexpmst_0_s),    
  .arcache_hostexpmst_0_s (arcache_hostexpmst_0_s),    
  .arprot_hostexpmst_0_s (arprot_hostexpmst_0_s),    
  .arvalid_hostexpmst_0_s (arvalid_hostexpmst_0_s),    
  .arready_hostexpmst_0_s (arready_hostexpmst_0_s),    
  .rid_hostexpmst_0_s   (rid_hostexpmst_0_s),    
  .rdata_hostexpmst_0_s (rdata_hostexpmst_0_s),    
  .rresp_hostexpmst_0_s (rresp_hostexpmst_0_s),    
  .rlast_hostexpmst_0_s (rlast_hostexpmst_0_s),    
  .rvalid_hostexpmst_0_s (rvalid_hostexpmst_0_s),    
  .rready_hostexpmst_0_s (rready_hostexpmst_0_s),    
  .awid_hostexpmst_1_s  (awid_hostexpmst_1_s),    
  .awaddr_hostexpmst_1_s (awaddr_hostexpmst_1_s),    
  .awlen_hostexpmst_1_s (awlen_hostexpmst_1_s),    
  .awsize_hostexpmst_1_s (awsize_hostexpmst_1_s),    
  .awburst_hostexpmst_1_s (awburst_hostexpmst_1_s),    
  .awlock_hostexpmst_1_s (awlock_hostexpmst_1_s),    
  .awcache_hostexpmst_1_s (awcache_hostexpmst_1_s),    
  .awprot_hostexpmst_1_s (awprot_hostexpmst_1_s),    
  .awvalid_hostexpmst_1_s (awvalid_hostexpmst_1_s),    
  .awready_hostexpmst_1_s (awready_hostexpmst_1_s),    
  .wdata_hostexpmst_1_s (wdata_hostexpmst_1_s),    
  .wstrb_hostexpmst_1_s (wstrb_hostexpmst_1_s),    
  .wlast_hostexpmst_1_s (wlast_hostexpmst_1_s),    
  .wvalid_hostexpmst_1_s (wvalid_hostexpmst_1_s),    
  .wready_hostexpmst_1_s (wready_hostexpmst_1_s),    
  .bid_hostexpmst_1_s   (bid_hostexpmst_1_s),    
  .bresp_hostexpmst_1_s (bresp_hostexpmst_1_s),    
  .bvalid_hostexpmst_1_s (bvalid_hostexpmst_1_s),    
  .bready_hostexpmst_1_s (bready_hostexpmst_1_s),    
  .arid_hostexpmst_1_s  (arid_hostexpmst_1_s),    
  .araddr_hostexpmst_1_s (araddr_hostexpmst_1_s),    
  .arlen_hostexpmst_1_s (arlen_hostexpmst_1_s),    
  .arsize_hostexpmst_1_s (arsize_hostexpmst_1_s),    
  .arburst_hostexpmst_1_s (arburst_hostexpmst_1_s),    
  .arlock_hostexpmst_1_s (arlock_hostexpmst_1_s),    
  .arcache_hostexpmst_1_s (arcache_hostexpmst_1_s),    
  .arprot_hostexpmst_1_s (arprot_hostexpmst_1_s),    
  .arvalid_hostexpmst_1_s (arvalid_hostexpmst_1_s),    
  .arready_hostexpmst_1_s (arready_hostexpmst_1_s),    
  .rid_hostexpmst_1_s   (rid_hostexpmst_1_s),    
  .rdata_hostexpmst_1_s (rdata_hostexpmst_1_s),    
  .rresp_hostexpmst_1_s (rresp_hostexpmst_1_s),    
  .rlast_hostexpmst_1_s (rlast_hostexpmst_1_s),    
  .rvalid_hostexpmst_1_s (rvalid_hostexpmst_1_s),    
  .rready_hostexpmst_1_s (rready_hostexpmst_1_s),    
  .aclkoutclk           (aclkoutclk),    
  .aclkoutresetn        (aclkoutresetn),    
  .paddr_vultan_apb_m   (paddr_vultan_apb_m),    
  .pselx_vultan_apb_m   (pselx_vultan_apb_m),    
  .penable_vultan_apb_m (penable_vultan_apb_m),    
  .pwrite_vultan_apb_m  (pwrite_vultan_apb_m),    
  .prdata_vultan_apb_m  (prdata_vultan_apb_m),    
  .pwdata_vultan_apb_m  (pwdata_vultan_apb_m),    
  .pprot_vultan_apb_m   (pprot_vultan_apb_m),    
  .pstrb_vultan_apb_m   (pstrb_vultan_apb_m),    
  .pready_vultan_apb_m  (pready_vultan_apb_m),    
  .pslverr_vultan_apb_m (pslverr_vultan_apb_m),    
  .aclkoutclken         (aclkoutclken)    
);


nic400_cd_ref_sse710_integration_example_f0_host_exp     u_cd_ref (
  .refclk               (refclk),    
  .refresetn            (refresetn),    
  .haddr_gpio_ahb_m     (haddr_gpio_ahb_m),    
  .hburst_gpio_ahb_m    (hburst_gpio_ahb_m),    
  .hprot_gpio_ahb_m     (hprot_gpio_ahb_m),    
  .hsize_gpio_ahb_m     (hsize_gpio_ahb_m),    
  .htrans_gpio_ahb_m    (htrans_gpio_ahb_m),    
  .hwdata_gpio_ahb_m    (hwdata_gpio_ahb_m),    
  .hwrite_gpio_ahb_m    (hwrite_gpio_ahb_m),    
  .hrdata_gpio_ahb_m    (hrdata_gpio_ahb_m),    
  .hreadyout_gpio_ahb_m (hreadyout_gpio_ahb_m),    
  .hresp_gpio_ahb_m     (hresp_gpio_ahb_m),    
  .hselx_gpio_ahb_m     (hselx_gpio_ahb_m),    
  .hready_gpio_ahb_m    (hready_gpio_ahb_m),    
  .a_data_gpio_ahb_m_ib_int_async (a_data_gpio_ahb_m_ib_int_async),    
  .a_wpntr_gry_gpio_ahb_m_ib_int_async (a_wpntr_gry_gpio_ahb_m_ib_int_async),    
  .a_rpntr_bin_gpio_ahb_m_ib_int_async (a_rpntr_bin_gpio_ahb_m_ib_int_async),    
  .a_rpntr_gry_gpio_ahb_m_ib_int_async (a_rpntr_gry_gpio_ahb_m_ib_int_async),    
  .w_data_gpio_ahb_m_ib_int_async (w_data_gpio_ahb_m_ib_int_async),    
  .w_wpntr_gry_gpio_ahb_m_ib_int_async (w_wpntr_gry_gpio_ahb_m_ib_int_async),    
  .w_rpntr_bin_gpio_ahb_m_ib_int_async (w_rpntr_bin_gpio_ahb_m_ib_int_async),    
  .w_rpntr_gry_gpio_ahb_m_ib_int_async (w_rpntr_gry_gpio_ahb_m_ib_int_async),    
  .d_data_gpio_ahb_m_ib_int_async (d_data_gpio_ahb_m_ib_int_async),    
  .d_wpntr_gry_gpio_ahb_m_ib_int_async (d_wpntr_gry_gpio_ahb_m_ib_int_async),    
  .d_rpntr_bin_gpio_ahb_m_ib_int_async (d_rpntr_bin_gpio_ahb_m_ib_int_async),    
  .d_rpntr_gry_gpio_ahb_m_ib_int_async (d_rpntr_gry_gpio_ahb_m_ib_int_async)    
);



endmodule
