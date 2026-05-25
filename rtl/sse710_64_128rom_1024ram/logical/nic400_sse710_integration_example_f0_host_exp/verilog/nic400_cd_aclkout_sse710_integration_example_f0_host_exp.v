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




module nic400_cd_aclkout_sse710_integration_example_f0_host_exp (
  

  paddr_extsys0_ppu_abp_m,
  pwdata_extsys0_ppu_abp_m,
  pwrite_extsys0_ppu_abp_m,
  penable_extsys0_ppu_abp_m,
  pselx_extsys0_ppu_abp_m,
  prdata_extsys0_ppu_abp_m,
  pslverr_extsys0_ppu_abp_m,
  pready_extsys0_ppu_abp_m,
  

  paddr_extsys1_ppu_abp_m,
  pwdata_extsys1_ppu_abp_m,
  pwrite_extsys1_ppu_abp_m,
  penable_extsys1_ppu_abp_m,
  pselx_extsys1_ppu_abp_m,
  prdata_extsys1_ppu_abp_m,
  pslverr_extsys1_ppu_abp_m,
  pready_extsys1_ppu_abp_m,
  

  paddr_vultan_apb_m,
  pwdata_vultan_apb_m,
  pwrite_vultan_apb_m,
  pprot_vultan_apb_m,
  pstrb_vultan_apb_m,
  penable_vultan_apb_m,
  pselx_vultan_apb_m,
  prdata_vultan_apb_m,
  pslverr_vultan_apb_m,
  pready_vultan_apb_m,
  

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
  

  a_data_gpio_ahb_m_ib_int_async,
  a_rpntr_gry_gpio_ahb_m_ib_int_async,
  a_rpntr_bin_gpio_ahb_m_ib_int_async,
  a_wpntr_gry_gpio_ahb_m_ib_int_async,
  d_data_gpio_ahb_m_ib_int_async,
  d_rpntr_gry_gpio_ahb_m_ib_int_async,
  d_rpntr_bin_gpio_ahb_m_ib_int_async,
  d_wpntr_gry_gpio_ahb_m_ib_int_async,
  w_data_gpio_ahb_m_ib_int_async,
  w_rpntr_gry_gpio_ahb_m_ib_int_async,
  w_rpntr_bin_gpio_ahb_m_ib_int_async,
  w_wpntr_gry_gpio_ahb_m_ib_int_async,


  aclkoutclk,
  aclkoutclken,
  aclkoutresetn

);






output [31:0] paddr_extsys0_ppu_abp_m;
output [31:0] pwdata_extsys0_ppu_abp_m;
output        pwrite_extsys0_ppu_abp_m;
output        penable_extsys0_ppu_abp_m;
output        pselx_extsys0_ppu_abp_m;
input  [31:0] prdata_extsys0_ppu_abp_m;
input         pslverr_extsys0_ppu_abp_m;
input         pready_extsys0_ppu_abp_m;


output [31:0] paddr_extsys1_ppu_abp_m;
output [31:0] pwdata_extsys1_ppu_abp_m;
output        pwrite_extsys1_ppu_abp_m;
output        penable_extsys1_ppu_abp_m;
output        pselx_extsys1_ppu_abp_m;
input  [31:0] prdata_extsys1_ppu_abp_m;
input         pslverr_extsys1_ppu_abp_m;
input         pready_extsys1_ppu_abp_m;


output [31:0] paddr_vultan_apb_m;
output [31:0] pwdata_vultan_apb_m;
output        pwrite_vultan_apb_m;
output [2:0]  pprot_vultan_apb_m;
output [3:0]  pstrb_vultan_apb_m;
output        penable_vultan_apb_m;
output        pselx_vultan_apb_m;
input  [31:0] prdata_vultan_apb_m;
input         pslverr_vultan_apb_m;
input         pready_vultan_apb_m;


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


output [88:0] a_data_gpio_ahb_m_ib_int_async;
input  [3:0]  a_rpntr_gry_gpio_ahb_m_ib_int_async;
input  [2:0]  a_rpntr_bin_gpio_ahb_m_ib_int_async;
output [3:0]  a_wpntr_gry_gpio_ahb_m_ib_int_async;
input  [87:0] d_data_gpio_ahb_m_ib_int_async;
output [3:0]  d_rpntr_gry_gpio_ahb_m_ib_int_async;
output [2:0]  d_rpntr_bin_gpio_ahb_m_ib_int_async;
input  [3:0]  d_wpntr_gry_gpio_ahb_m_ib_int_async;
output [72:0] w_data_gpio_ahb_m_ib_int_async;
input  [3:0]  w_rpntr_gry_gpio_ahb_m_ib_int_async;
input  [2:0]  w_rpntr_bin_gpio_ahb_m_ib_int_async;
output [3:0]  w_wpntr_gry_gpio_ahb_m_ib_int_async;


input         aclkoutclk;
input         aclkoutclken;
input         aclkoutresetn;




wire   [88:0]  a_data_gpio_ahb_m_ib_int_async;
wire   [3:0]   a_wpntr_gry_gpio_ahb_m_ib_int_async;
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
wire   [2:0]   d_rpntr_bin_gpio_ahb_m_ib_int_async;
wire   [3:0]   d_rpntr_gry_gpio_ahb_m_ib_int_async;
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
wire   [72:0]  w_data_gpio_ahb_m_ib_int_async;
wire   [3:0]   w_wpntr_gry_gpio_ahb_m_ib_int_async;
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
wire           aready_apb_group0_ib_apb_group0_apb_group0_s;
wire           dbnr_apb_group0_ib_apb_group0_apb_group0_s;
wire   [31:0]  ddata_apb_group0_ib_apb_group0_apb_group0_s;
wire   [17:0]  did_apb_group0_ib_apb_group0_apb_group0_s;
wire           dlast_apb_group0_ib_apb_group0_apb_group0_s;
wire   [1:0]   dresp_apb_group0_ib_apb_group0_apb_group0_s;
wire           dvalid_apb_group0_ib_apb_group0_apb_group0_s;
wire           wready_apb_group0_ib_apb_group0_apb_group0_s;
wire           arready_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire           awready_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [17:0]  bid_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [1:0]   bresp_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire           bvalid_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [31:0]  rdata_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [17:0]  rid_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire           rlast_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [1:0]   rresp_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire           rvalid_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire           wready_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire           arready_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire           awready_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [17:0]  bid_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [1:0]   bresp_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire           bvalid_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [31:0]  rdata_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [17:0]  rid_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire           rlast_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [1:0]   rresp_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire           rvalid_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire           wready_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [31:0]  araddr_hostexpmst_0_s_bm1_axi_s_0;
wire   [1:0]   arburst_hostexpmst_0_s_bm1_axi_s_0;
wire   [3:0]   arcache_hostexpmst_0_s_bm1_axi_s_0;
wire   [17:0]  arid_hostexpmst_0_s_bm1_axi_s_0;
wire   [7:0]   arlen_hostexpmst_0_s_bm1_axi_s_0;
wire           arlock_hostexpmst_0_s_bm1_axi_s_0;
wire   [2:0]   arprot_hostexpmst_0_s_bm1_axi_s_0;
wire   [3:0]   arqv_hostexpmst_0_s_bm1_axi_s_0;
wire   [3:0]   arregion_hostexpmst_0_s_bm1_axi_s_0;
wire   [2:0]   arsize_hostexpmst_0_s_bm1_axi_s_0;
wire           arvalid_hostexpmst_0_s_bm1_axi_s_0;
wire   [4:0]   arvalid_vect_hostexpmst_0_s_bm1_axi_s_0;
wire   [31:0]  awaddr_hostexpmst_0_s_bm1_axi_s_0;
wire   [1:0]   awburst_hostexpmst_0_s_bm1_axi_s_0;
wire   [3:0]   awcache_hostexpmst_0_s_bm1_axi_s_0;
wire   [17:0]  awid_hostexpmst_0_s_bm1_axi_s_0;
wire   [7:0]   awlen_hostexpmst_0_s_bm1_axi_s_0;
wire           awlock_hostexpmst_0_s_bm1_axi_s_0;
wire   [2:0]   awprot_hostexpmst_0_s_bm1_axi_s_0;
wire   [3:0]   awqv_hostexpmst_0_s_bm1_axi_s_0;
wire   [3:0]   awregion_hostexpmst_0_s_bm1_axi_s_0;
wire   [2:0]   awsize_hostexpmst_0_s_bm1_axi_s_0;
wire           awvalid_hostexpmst_0_s_bm1_axi_s_0;
wire   [4:0]   awvalid_vect_hostexpmst_0_s_bm1_axi_s_0;
wire           bready_hostexpmst_0_s_bm1_axi_s_0;
wire           rready_hostexpmst_0_s_bm1_axi_s_0;
wire   [63:0]  wdata_hostexpmst_0_s_bm1_axi_s_0;
wire           wlast_hostexpmst_0_s_bm1_axi_s_0;
wire   [7:0]   wstrb_hostexpmst_0_s_bm1_axi_s_0;
wire           wvalid_hostexpmst_0_s_bm1_axi_s_0;
wire   [31:0]  araddr_hostexpmst_1_s_bm1_axi_s_1;
wire   [1:0]   arburst_hostexpmst_1_s_bm1_axi_s_1;
wire   [3:0]   arcache_hostexpmst_1_s_bm1_axi_s_1;
wire   [17:0]  arid_hostexpmst_1_s_bm1_axi_s_1;
wire   [7:0]   arlen_hostexpmst_1_s_bm1_axi_s_1;
wire           arlock_hostexpmst_1_s_bm1_axi_s_1;
wire   [2:0]   arprot_hostexpmst_1_s_bm1_axi_s_1;
wire   [3:0]   arqv_hostexpmst_1_s_bm1_axi_s_1;
wire   [3:0]   arregion_hostexpmst_1_s_bm1_axi_s_1;
wire   [2:0]   arsize_hostexpmst_1_s_bm1_axi_s_1;
wire           arvalid_hostexpmst_1_s_bm1_axi_s_1;
wire   [3:0]   arvalid_vect_hostexpmst_1_s_bm1_axi_s_1;
wire   [31:0]  awaddr_hostexpmst_1_s_bm1_axi_s_1;
wire   [1:0]   awburst_hostexpmst_1_s_bm1_axi_s_1;
wire   [3:0]   awcache_hostexpmst_1_s_bm1_axi_s_1;
wire   [17:0]  awid_hostexpmst_1_s_bm1_axi_s_1;
wire   [7:0]   awlen_hostexpmst_1_s_bm1_axi_s_1;
wire           awlock_hostexpmst_1_s_bm1_axi_s_1;
wire   [2:0]   awprot_hostexpmst_1_s_bm1_axi_s_1;
wire   [3:0]   awqv_hostexpmst_1_s_bm1_axi_s_1;
wire   [3:0]   awregion_hostexpmst_1_s_bm1_axi_s_1;
wire   [2:0]   awsize_hostexpmst_1_s_bm1_axi_s_1;
wire           awvalid_hostexpmst_1_s_bm1_axi_s_1;
wire   [3:0]   awvalid_vect_hostexpmst_1_s_bm1_axi_s_1;
wire           bready_hostexpmst_1_s_bm1_axi_s_1;
wire           rready_hostexpmst_1_s_bm1_axi_s_1;
wire   [63:0]  wdata_hostexpmst_1_s_bm1_axi_s_1;
wire           wlast_hostexpmst_1_s_bm1_axi_s_1;
wire   [7:0]   wstrb_hostexpmst_1_s_bm1_axi_s_1;
wire           wvalid_hostexpmst_1_s_bm1_axi_s_1;
wire   [31:0]  araddr_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [31:0]  araddr_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [1:0]   arburst_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [1:0]   arburst_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [3:0]   arcache_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [3:0]   arcache_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [17:0]  arid_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [17:0]  arid_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [7:0]   arlen_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [7:0]   arlen_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire           arlock_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire           arlock_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [2:0]   arprot_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [2:0]   arprot_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire           arready_ib2_bm0_axi_s_0;
wire   [2:0]   arsize_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [2:0]   arsize_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire           arvalid_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire           arvalid_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [31:0]  awaddr_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [31:0]  awaddr_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [1:0]   awburst_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [1:0]   awburst_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [3:0]   awcache_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [3:0]   awcache_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [17:0]  awid_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [17:0]  awid_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [7:0]   awlen_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [7:0]   awlen_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire           awlock_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire           awlock_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [2:0]   awprot_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [2:0]   awprot_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire           awready_ib2_bm0_axi_s_0;
wire   [2:0]   awsize_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [2:0]   awsize_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire           awvalid_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire           awvalid_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [17:0]  bid_ib2_bm0_axi_s_0;
wire           bready_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire           bready_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [1:0]   bresp_ib2_bm0_axi_s_0;
wire           bvalid_ib2_bm0_axi_s_0;
wire   [31:0]  rdata_ib2_bm0_axi_s_0;
wire   [17:0]  rid_ib2_bm0_axi_s_0;
wire           rlast_ib2_bm0_axi_s_0;
wire           rready_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire           rready_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [1:0]   rresp_ib2_bm0_axi_s_0;
wire           rvalid_ib2_bm0_axi_s_0;
wire   [31:0]  wdata_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [31:0]  wdata_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire           wlast_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire           wlast_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire           wready_ib2_bm0_axi_s_0;
wire   [3:0]   wstrb_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire   [3:0]   wstrb_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire           wvalid_bm0_extsys0_axi_m_extsys0_axi_m_s;
wire           wvalid_bm0_extsys1_axi_m_extsys1_axi_m_s;
wire   [3:0]   arqv_bm1_ib2_ib2_s;
wire   [31:0]  araddr_bm1_ib2_ib2_s;
wire   [31:0]  araddr_bm1_gpio_ahb_m_ib_axi4_s;
wire   [31:0]  araddr_bm1_apb_group0_ib_axi4_s;
wire   [1:0]   arburst_bm1_ib2_ib2_s;
wire   [1:0]   arburst_bm1_gpio_ahb_m_ib_axi4_s;
wire   [1:0]   arburst_bm1_apb_group0_ib_axi4_s;
wire   [3:0]   arcache_bm1_ib2_ib2_s;
wire   [3:0]   arcache_bm1_gpio_ahb_m_ib_axi4_s;
wire   [3:0]   arcache_bm1_apb_group0_ib_axi4_s;
wire   [17:0]  arid_bm1_ib2_ib2_s;
wire   [17:0]  arid_bm1_gpio_ahb_m_ib_axi4_s;
wire   [17:0]  arid_bm1_apb_group0_ib_axi4_s;
wire   [17:0]  arid_bm1_ds_3_axi_s_0;
wire   [7:0]   arlen_bm1_ib2_ib2_s;
wire   [7:0]   arlen_bm1_gpio_ahb_m_ib_axi4_s;
wire   [7:0]   arlen_bm1_apb_group0_ib_axi4_s;
wire   [7:0]   arlen_bm1_ds_3_axi_s_0;
wire           arlock_bm1_ib2_ib2_s;
wire           arlock_bm1_gpio_ahb_m_ib_axi4_s;
wire           arlock_bm1_apb_group0_ib_axi4_s;
wire   [2:0]   arprot_bm1_ib2_ib2_s;
wire   [2:0]   arprot_bm1_gpio_ahb_m_ib_axi4_s;
wire   [2:0]   arprot_bm1_apb_group0_ib_axi4_s;
wire           arready_hostexpmst_0_s_bm1_axi_s_0;
wire           arready_hostexpmst_1_s_bm1_axi_s_1;
wire   [3:0]   arregion_bm1_ib2_ib2_s;
wire   [3:0]   arregion_bm1_gpio_ahb_m_ib_axi4_s;
wire   [3:0]   arregion_bm1_apb_group0_ib_axi4_s;
wire   [2:0]   arsize_bm1_ib2_ib2_s;
wire   [2:0]   arsize_bm1_gpio_ahb_m_ib_axi4_s;
wire   [2:0]   arsize_bm1_apb_group0_ib_axi4_s;
wire           arvalid_bm1_ib2_ib2_s;
wire           arvalid_bm1_gpio_ahb_m_ib_axi4_s;
wire           arvalid_bm1_apb_group0_ib_axi4_s;
wire           arvalid_bm1_ds_3_axi_s_0;
wire   [1:0]   arvalid_vect_bm1_ib2_ib2_s;
wire   [3:0]   awqv_bm1_ib2_ib2_s;
wire   [31:0]  awaddr_bm1_ib2_ib2_s;
wire   [31:0]  awaddr_bm1_gpio_ahb_m_ib_axi4_s;
wire   [31:0]  awaddr_bm1_apb_group0_ib_axi4_s;
wire   [1:0]   awburst_bm1_ib2_ib2_s;
wire   [1:0]   awburst_bm1_gpio_ahb_m_ib_axi4_s;
wire   [1:0]   awburst_bm1_apb_group0_ib_axi4_s;
wire   [3:0]   awcache_bm1_ib2_ib2_s;
wire   [3:0]   awcache_bm1_gpio_ahb_m_ib_axi4_s;
wire   [3:0]   awcache_bm1_apb_group0_ib_axi4_s;
wire   [17:0]  awid_bm1_ib2_ib2_s;
wire   [17:0]  awid_bm1_gpio_ahb_m_ib_axi4_s;
wire   [17:0]  awid_bm1_apb_group0_ib_axi4_s;
wire   [17:0]  awid_bm1_ds_3_axi_s_0;
wire   [7:0]   awlen_bm1_ib2_ib2_s;
wire   [7:0]   awlen_bm1_gpio_ahb_m_ib_axi4_s;
wire   [7:0]   awlen_bm1_apb_group0_ib_axi4_s;
wire           awlock_bm1_ib2_ib2_s;
wire           awlock_bm1_gpio_ahb_m_ib_axi4_s;
wire           awlock_bm1_apb_group0_ib_axi4_s;
wire   [2:0]   awprot_bm1_ib2_ib2_s;
wire   [2:0]   awprot_bm1_gpio_ahb_m_ib_axi4_s;
wire   [2:0]   awprot_bm1_apb_group0_ib_axi4_s;
wire           awready_hostexpmst_0_s_bm1_axi_s_0;
wire           awready_hostexpmst_1_s_bm1_axi_s_1;
wire   [3:0]   awregion_bm1_ib2_ib2_s;
wire   [3:0]   awregion_bm1_gpio_ahb_m_ib_axi4_s;
wire   [3:0]   awregion_bm1_apb_group0_ib_axi4_s;
wire   [2:0]   awsize_bm1_ib2_ib2_s;
wire   [2:0]   awsize_bm1_gpio_ahb_m_ib_axi4_s;
wire   [2:0]   awsize_bm1_apb_group0_ib_axi4_s;
wire           awvalid_bm1_ib2_ib2_s;
wire           awvalid_bm1_gpio_ahb_m_ib_axi4_s;
wire           awvalid_bm1_apb_group0_ib_axi4_s;
wire           awvalid_bm1_ds_3_axi_s_0;
wire   [1:0]   awvalid_vect_bm1_ib2_ib2_s;
wire   [17:0]  bid_hostexpmst_0_s_bm1_axi_s_0;
wire   [17:0]  bid_hostexpmst_1_s_bm1_axi_s_1;
wire           bready_bm1_ib2_ib2_s;
wire           bready_bm1_gpio_ahb_m_ib_axi4_s;
wire           bready_bm1_apb_group0_ib_axi4_s;
wire           bready_bm1_ds_3_axi_s_0;
wire   [1:0]   bresp_hostexpmst_0_s_bm1_axi_s_0;
wire   [1:0]   bresp_hostexpmst_1_s_bm1_axi_s_1;
wire           bvalid_hostexpmst_0_s_bm1_axi_s_0;
wire           bvalid_hostexpmst_1_s_bm1_axi_s_1;
wire   [63:0]  rdata_hostexpmst_0_s_bm1_axi_s_0;
wire   [63:0]  rdata_hostexpmst_1_s_bm1_axi_s_1;
wire   [17:0]  rid_hostexpmst_0_s_bm1_axi_s_0;
wire   [17:0]  rid_hostexpmst_1_s_bm1_axi_s_1;
wire           rlast_hostexpmst_0_s_bm1_axi_s_0;
wire           rlast_hostexpmst_1_s_bm1_axi_s_1;
wire           rready_bm1_ib2_ib2_s;
wire           rready_bm1_gpio_ahb_m_ib_axi4_s;
wire           rready_bm1_apb_group0_ib_axi4_s;
wire           rready_bm1_ds_3_axi_s_0;
wire   [1:0]   rresp_hostexpmst_0_s_bm1_axi_s_0;
wire   [1:0]   rresp_hostexpmst_1_s_bm1_axi_s_1;
wire           rvalid_hostexpmst_0_s_bm1_axi_s_0;
wire           rvalid_hostexpmst_1_s_bm1_axi_s_1;
wire   [63:0]  wdata_bm1_ib2_ib2_s;
wire   [63:0]  wdata_bm1_gpio_ahb_m_ib_axi4_s;
wire   [63:0]  wdata_bm1_apb_group0_ib_axi4_s;
wire           wlast_bm1_ib2_ib2_s;
wire           wlast_bm1_gpio_ahb_m_ib_axi4_s;
wire           wlast_bm1_apb_group0_ib_axi4_s;
wire           wlast_bm1_ds_3_axi_s_0;
wire           wready_hostexpmst_0_s_bm1_axi_s_0;
wire           wready_hostexpmst_1_s_bm1_axi_s_1;
wire   [7:0]   wstrb_bm1_ib2_ib2_s;
wire   [7:0]   wstrb_bm1_gpio_ahb_m_ib_axi4_s;
wire   [7:0]   wstrb_bm1_apb_group0_ib_axi4_s;
wire           wvalid_bm1_ib2_ib2_s;
wire           wvalid_bm1_gpio_ahb_m_ib_axi4_s;
wire           wvalid_bm1_apb_group0_ib_axi4_s;
wire           wvalid_bm1_ds_3_axi_s_0;
wire           arready_bm1_ds_3_axi_s_0;
wire           awready_bm1_ds_3_axi_s_0;
wire   [17:0]  bid_bm1_ds_3_axi_s_0;
wire   [1:0]   bresp_bm1_ds_3_axi_s_0;
wire           bvalid_bm1_ds_3_axi_s_0;
wire   [17:0]  rid_bm1_ds_3_axi_s_0;
wire           rlast_bm1_ds_3_axi_s_0;
wire   [1:0]   rresp_bm1_ds_3_axi_s_0;
wire           rvalid_bm1_ds_3_axi_s_0;
wire           wready_bm1_ds_3_axi_s_0;
wire           a_ready_apb_group0_ib_int;
wire   [31:0]  aaddr_apb_group0_ib_apb_group0_apb_group0_s;
wire   [1:0]   aburst_apb_group0_ib_apb_group0_apb_group0_s;
wire   [3:0]   acache_apb_group0_ib_apb_group0_apb_group0_s;
wire   [17:0]  aid_apb_group0_ib_apb_group0_apb_group0_s;
wire   [7:0]   alen_apb_group0_ib_apb_group0_apb_group0_s;
wire           alock_apb_group0_ib_apb_group0_apb_group0_s;
wire   [2:0]   aprot_apb_group0_ib_apb_group0_apb_group0_s;
wire   [3:0]   aregion_apb_group0_ib_apb_group0_apb_group0_s;
wire   [2:0]   asize_apb_group0_ib_apb_group0_apb_group0_s;
wire           avalid_apb_group0_ib_apb_group0_apb_group0_s;
wire           awrite_apb_group0_ib_apb_group0_apb_group0_s;
wire   [87:0]  d_data_apb_group0_ib_int;
wire           d_valid_apb_group0_ib_int;
wire           dready_apb_group0_ib_apb_group0_apb_group0_s;
wire           w_ready_apb_group0_ib_int;
wire   [31:0]  wdata_apb_group0_ib_apb_group0_apb_group0_s;
wire           wlast_apb_group0_ib_apb_group0_apb_group0_s;
wire   [3:0]   wstrb_apb_group0_ib_apb_group0_apb_group0_s;
wire           wvalid_apb_group0_ib_apb_group0_apb_group0_s;
wire   [88:0]  a_data_apb_group0_ib_int;
wire           a_valid_apb_group0_ib_int;
wire           arready_bm1_apb_group0_ib_axi4_s;
wire           awready_bm1_apb_group0_ib_axi4_s;
wire   [17:0]  bid_bm1_apb_group0_ib_axi4_s;
wire   [1:0]   bresp_bm1_apb_group0_ib_axi4_s;
wire           bvalid_bm1_apb_group0_ib_axi4_s;
wire           d_ready_apb_group0_ib_int;
wire   [63:0]  rdata_bm1_apb_group0_ib_axi4_s;
wire   [17:0]  rid_bm1_apb_group0_ib_axi4_s;
wire           rlast_bm1_apb_group0_ib_axi4_s;
wire   [1:0]   rresp_bm1_apb_group0_ib_axi4_s;
wire           rvalid_bm1_apb_group0_ib_axi4_s;
wire   [72:0]  w_data_apb_group0_ib_int;
wire           w_valid_apb_group0_ib_int;
wire           wready_bm1_apb_group0_ib_axi4_s;
wire           arready_bm1_gpio_ahb_m_ib_axi4_s;
wire           awready_bm1_gpio_ahb_m_ib_axi4_s;
wire   [17:0]  bid_bm1_gpio_ahb_m_ib_axi4_s;
wire   [1:0]   bresp_bm1_gpio_ahb_m_ib_axi4_s;
wire           bvalid_bm1_gpio_ahb_m_ib_axi4_s;
wire   [63:0]  rdata_bm1_gpio_ahb_m_ib_axi4_s;
wire   [17:0]  rid_bm1_gpio_ahb_m_ib_axi4_s;
wire           rlast_bm1_gpio_ahb_m_ib_axi4_s;
wire   [1:0]   rresp_bm1_gpio_ahb_m_ib_axi4_s;
wire           rvalid_bm1_gpio_ahb_m_ib_axi4_s;
wire           wready_bm1_gpio_ahb_m_ib_axi4_s;
wire           ar_ready_ib2_int;
wire   [31:0]  araddr_ib2_bm0_axi_s_0;
wire   [1:0]   arburst_ib2_bm0_axi_s_0;
wire   [3:0]   arcache_ib2_bm0_axi_s_0;
wire   [17:0]  arid_ib2_bm0_axi_s_0;
wire   [7:0]   arlen_ib2_bm0_axi_s_0;
wire           arlock_ib2_bm0_axi_s_0;
wire   [2:0]   arprot_ib2_bm0_axi_s_0;
wire   [3:0]   arqv_ib2_bm0_axi_s_0;
wire   [3:0]   arregion_ib2_bm0_axi_s_0;
wire   [2:0]   arsize_ib2_bm0_axi_s_0;
wire           arvalid_ib2_bm0_axi_s_0;
wire   [1:0]   arvalid_vect_ib2_bm0_axi_s_0;
wire           aw_ready_ib2_int;
wire   [31:0]  awaddr_ib2_bm0_axi_s_0;
wire   [1:0]   awburst_ib2_bm0_axi_s_0;
wire   [3:0]   awcache_ib2_bm0_axi_s_0;
wire   [17:0]  awid_ib2_bm0_axi_s_0;
wire   [7:0]   awlen_ib2_bm0_axi_s_0;
wire           awlock_ib2_bm0_axi_s_0;
wire   [2:0]   awprot_ib2_bm0_axi_s_0;
wire   [3:0]   awqv_ib2_bm0_axi_s_0;
wire   [3:0]   awregion_ib2_bm0_axi_s_0;
wire   [2:0]   awsize_ib2_bm0_axi_s_0;
wire           awvalid_ib2_bm0_axi_s_0;
wire   [1:0]   awvalid_vect_ib2_bm0_axi_s_0;
wire   [19:0]  b_data_ib2_int;
wire           b_valid_ib2_int;
wire           bready_ib2_bm0_axi_s_0;
wire   [86:0]  r_data_ib2_int;
wire           r_valid_ib2_int;
wire           rready_ib2_bm0_axi_s_0;
wire           w_ready_ib2_int;
wire   [31:0]  wdata_ib2_bm0_axi_s_0;
wire           wlast_ib2_bm0_axi_s_0;
wire   [3:0]   wstrb_ib2_bm0_axi_s_0;
wire           wvalid_ib2_bm0_axi_s_0;
wire   [92:0]  ar_data_ib2_int;
wire           ar_valid_ib2_int;
wire           arready_bm1_ib2_ib2_s;
wire   [81:0]  aw_data_ib2_int;
wire           aw_valid_ib2_int;
wire           awready_bm1_ib2_ib2_s;
wire           b_ready_ib2_int;
wire   [17:0]  bid_bm1_ib2_ib2_s;
wire   [1:0]   bresp_bm1_ib2_ib2_s;
wire           bvalid_bm1_ib2_ib2_s;
wire           r_ready_ib2_int;
wire   [63:0]  rdata_bm1_ib2_ib2_s;
wire   [17:0]  rid_bm1_ib2_ib2_s;
wire           rlast_bm1_ib2_ib2_s;
wire   [1:0]   rresp_bm1_ib2_ib2_s;
wire           rvalid_bm1_ib2_ib2_s;
wire   [72:0]  w_data_ib2_int;
wire           w_valid_ib2_int;
wire           wready_bm1_ib2_ib2_s;
wire   [2:0]   a_rpntr_bin_gpio_ahb_m_ib_int_async;
wire   [3:0]   a_rpntr_gry_gpio_ahb_m_ib_int_async;
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
wire   [87:0]  d_data_gpio_ahb_m_ib_int_async;
wire   [3:0]   d_wpntr_gry_gpio_ahb_m_ib_int_async;
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
wire   [2:0]   w_rpntr_bin_gpio_ahb_m_ib_int_async;
wire   [3:0]   w_rpntr_gry_gpio_ahb_m_ib_int_async;
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




nic400_amib_apb_group0_sse710_integration_example_f0_host_exp     u_amib_apb_group0 (
  .aid_apb_group0_s     (aid_apb_group0_ib_apb_group0_apb_group0_s),
  .aaddr_apb_group0_s   (aaddr_apb_group0_ib_apb_group0_apb_group0_s),
  .alen_apb_group0_s    (alen_apb_group0_ib_apb_group0_apb_group0_s),
  .asize_apb_group0_s   (asize_apb_group0_ib_apb_group0_apb_group0_s),
  .aburst_apb_group0_s  (aburst_apb_group0_ib_apb_group0_apb_group0_s),
  .alock_apb_group0_s   (alock_apb_group0_ib_apb_group0_apb_group0_s),
  .acache_apb_group0_s  (acache_apb_group0_ib_apb_group0_apb_group0_s),
  .aprot_apb_group0_s   (aprot_apb_group0_ib_apb_group0_apb_group0_s),
  .awrite_apb_group0_s  (awrite_apb_group0_ib_apb_group0_apb_group0_s),
  .avalid_apb_group0_s  (avalid_apb_group0_ib_apb_group0_apb_group0_s),
  .aregion_apb_group0_s (aregion_apb_group0_ib_apb_group0_apb_group0_s),
  .aready_apb_group0_s  (aready_apb_group0_ib_apb_group0_apb_group0_s),
  .wdata_apb_group0_s   (wdata_apb_group0_ib_apb_group0_apb_group0_s),
  .wstrb_apb_group0_s   (wstrb_apb_group0_ib_apb_group0_apb_group0_s),
  .wlast_apb_group0_s   (wlast_apb_group0_ib_apb_group0_apb_group0_s),
  .wvalid_apb_group0_s  (wvalid_apb_group0_ib_apb_group0_apb_group0_s),
  .wready_apb_group0_s  (wready_apb_group0_ib_apb_group0_apb_group0_s),
  .did_apb_group0_s     (did_apb_group0_ib_apb_group0_apb_group0_s),
  .ddata_apb_group0_s   (ddata_apb_group0_ib_apb_group0_apb_group0_s),
  .dresp_apb_group0_s   (dresp_apb_group0_ib_apb_group0_apb_group0_s),
  .dlast_apb_group0_s   (dlast_apb_group0_ib_apb_group0_apb_group0_s),
  .dbnr_apb_group0_s    (dbnr_apb_group0_ib_apb_group0_apb_group0_s),
  .dvalid_apb_group0_s  (dvalid_apb_group0_ib_apb_group0_apb_group0_s),
  .dready_apb_group0_s  (dready_apb_group0_ib_apb_group0_apb_group0_s),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn),
  .paddr_extsys0_ppu_abp_m (paddr_extsys0_ppu_abp_m),
  .pwdata_extsys0_ppu_abp_m (pwdata_extsys0_ppu_abp_m),
  .pwrite_extsys0_ppu_abp_m (pwrite_extsys0_ppu_abp_m),
  .penable_extsys0_ppu_abp_m (penable_extsys0_ppu_abp_m),
  .psel_extsys0_ppu_abp_m (pselx_extsys0_ppu_abp_m),
  .prdata_extsys0_ppu_abp_m (prdata_extsys0_ppu_abp_m),
  .pslverr_extsys0_ppu_abp_m (pslverr_extsys0_ppu_abp_m),
  .pready_extsys0_ppu_abp_m (pready_extsys0_ppu_abp_m),
  .paddr_extsys1_ppu_abp_m (paddr_extsys1_ppu_abp_m),
  .pwdata_extsys1_ppu_abp_m (pwdata_extsys1_ppu_abp_m),
  .pwrite_extsys1_ppu_abp_m (pwrite_extsys1_ppu_abp_m),
  .penable_extsys1_ppu_abp_m (penable_extsys1_ppu_abp_m),
  .psel_extsys1_ppu_abp_m (pselx_extsys1_ppu_abp_m),
  .prdata_extsys1_ppu_abp_m (prdata_extsys1_ppu_abp_m),
  .pslverr_extsys1_ppu_abp_m (pslverr_extsys1_ppu_abp_m),
  .pready_extsys1_ppu_abp_m (pready_extsys1_ppu_abp_m),
  .apb_pclken           (aclkoutclken),
  .paddr_vultan_apb_m   (paddr_vultan_apb_m),
  .pwdata_vultan_apb_m  (pwdata_vultan_apb_m),
  .pwrite_vultan_apb_m  (pwrite_vultan_apb_m),
  .pprot_vultan_apb_m   (pprot_vultan_apb_m),
  .pstrb_vultan_apb_m   (pstrb_vultan_apb_m),
  .penable_vultan_apb_m (penable_vultan_apb_m),
  .psel_vultan_apb_m    (pselx_vultan_apb_m),
  .prdata_vultan_apb_m  (prdata_vultan_apb_m),
  .pslverr_vultan_apb_m (pslverr_vultan_apb_m),
  .pready_vultan_apb_m  (pready_vultan_apb_m)
);


nic400_amib_extsys0_axi_m_sse710_integration_example_f0_host_exp     u_amib_extsys0_axi_m (
  .awid_extsys0_axi_m_m (awid_extsys0_axi_m),
  .awaddr_extsys0_axi_m_m (awaddr_extsys0_axi_m),
  .awlen_extsys0_axi_m_m (awlen_extsys0_axi_m),
  .awsize_extsys0_axi_m_m (awsize_extsys0_axi_m),
  .awburst_extsys0_axi_m_m (awburst_extsys0_axi_m),
  .awlock_extsys0_axi_m_m (awlock_extsys0_axi_m),
  .awcache_extsys0_axi_m_m (awcache_extsys0_axi_m),
  .awprot_extsys0_axi_m_m (awprot_extsys0_axi_m),
  .awvalid_extsys0_axi_m_m (awvalid_extsys0_axi_m),
  .awready_extsys0_axi_m_m (awready_extsys0_axi_m),
  .wdata_extsys0_axi_m_m (wdata_extsys0_axi_m),
  .wstrb_extsys0_axi_m_m (wstrb_extsys0_axi_m),
  .wlast_extsys0_axi_m_m (wlast_extsys0_axi_m),
  .wvalid_extsys0_axi_m_m (wvalid_extsys0_axi_m),
  .wready_extsys0_axi_m_m (wready_extsys0_axi_m),
  .bid_extsys0_axi_m_m  (bid_extsys0_axi_m),
  .bresp_extsys0_axi_m_m (bresp_extsys0_axi_m),
  .bvalid_extsys0_axi_m_m (bvalid_extsys0_axi_m),
  .bready_extsys0_axi_m_m (bready_extsys0_axi_m),
  .arid_extsys0_axi_m_m (arid_extsys0_axi_m),
  .araddr_extsys0_axi_m_m (araddr_extsys0_axi_m),
  .arlen_extsys0_axi_m_m (arlen_extsys0_axi_m),
  .arsize_extsys0_axi_m_m (arsize_extsys0_axi_m),
  .arburst_extsys0_axi_m_m (arburst_extsys0_axi_m),
  .arlock_extsys0_axi_m_m (arlock_extsys0_axi_m),
  .arcache_extsys0_axi_m_m (arcache_extsys0_axi_m),
  .arprot_extsys0_axi_m_m (arprot_extsys0_axi_m),
  .arvalid_extsys0_axi_m_m (arvalid_extsys0_axi_m),
  .arready_extsys0_axi_m_m (arready_extsys0_axi_m),
  .rid_extsys0_axi_m_m  (rid_extsys0_axi_m),
  .rdata_extsys0_axi_m_m (rdata_extsys0_axi_m),
  .rresp_extsys0_axi_m_m (rresp_extsys0_axi_m),
  .rlast_extsys0_axi_m_m (rlast_extsys0_axi_m),
  .rvalid_extsys0_axi_m_m (rvalid_extsys0_axi_m),
  .rready_extsys0_axi_m_m (rready_extsys0_axi_m),
  .awid_extsys0_axi_m_s (awid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awaddr_extsys0_axi_m_s (awaddr_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awlen_extsys0_axi_m_s (awlen_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awsize_extsys0_axi_m_s (awsize_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awburst_extsys0_axi_m_s (awburst_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awlock_extsys0_axi_m_s (awlock_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awcache_extsys0_axi_m_s (awcache_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awprot_extsys0_axi_m_s (awprot_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awvalid_extsys0_axi_m_s (awvalid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awready_extsys0_axi_m_s (awready_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .wdata_extsys0_axi_m_s (wdata_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .wstrb_extsys0_axi_m_s (wstrb_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .wlast_extsys0_axi_m_s (wlast_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .wvalid_extsys0_axi_m_s (wvalid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .wready_extsys0_axi_m_s (wready_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .bid_extsys0_axi_m_s  (bid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .bresp_extsys0_axi_m_s (bresp_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .bvalid_extsys0_axi_m_s (bvalid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .bready_extsys0_axi_m_s (bready_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arid_extsys0_axi_m_s (arid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .araddr_extsys0_axi_m_s (araddr_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arlen_extsys0_axi_m_s (arlen_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arsize_extsys0_axi_m_s (arsize_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arburst_extsys0_axi_m_s (arburst_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arlock_extsys0_axi_m_s (arlock_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arcache_extsys0_axi_m_s (arcache_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arprot_extsys0_axi_m_s (arprot_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arvalid_extsys0_axi_m_s (arvalid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arready_extsys0_axi_m_s (arready_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .rid_extsys0_axi_m_s  (rid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .rdata_extsys0_axi_m_s (rdata_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .rresp_extsys0_axi_m_s (rresp_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .rlast_extsys0_axi_m_s (rlast_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .rvalid_extsys0_axi_m_s (rvalid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .rready_extsys0_axi_m_s (rready_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn)
);


nic400_amib_extsys1_axi_m_sse710_integration_example_f0_host_exp     u_amib_extsys1_axi_m (
  .awid_extsys1_axi_m_m (awid_extsys1_axi_m),
  .awaddr_extsys1_axi_m_m (awaddr_extsys1_axi_m),
  .awlen_extsys1_axi_m_m (awlen_extsys1_axi_m),
  .awsize_extsys1_axi_m_m (awsize_extsys1_axi_m),
  .awburst_extsys1_axi_m_m (awburst_extsys1_axi_m),
  .awlock_extsys1_axi_m_m (awlock_extsys1_axi_m),
  .awcache_extsys1_axi_m_m (awcache_extsys1_axi_m),
  .awprot_extsys1_axi_m_m (awprot_extsys1_axi_m),
  .awvalid_extsys1_axi_m_m (awvalid_extsys1_axi_m),
  .awready_extsys1_axi_m_m (awready_extsys1_axi_m),
  .wdata_extsys1_axi_m_m (wdata_extsys1_axi_m),
  .wstrb_extsys1_axi_m_m (wstrb_extsys1_axi_m),
  .wlast_extsys1_axi_m_m (wlast_extsys1_axi_m),
  .wvalid_extsys1_axi_m_m (wvalid_extsys1_axi_m),
  .wready_extsys1_axi_m_m (wready_extsys1_axi_m),
  .bid_extsys1_axi_m_m  (bid_extsys1_axi_m),
  .bresp_extsys1_axi_m_m (bresp_extsys1_axi_m),
  .bvalid_extsys1_axi_m_m (bvalid_extsys1_axi_m),
  .bready_extsys1_axi_m_m (bready_extsys1_axi_m),
  .arid_extsys1_axi_m_m (arid_extsys1_axi_m),
  .araddr_extsys1_axi_m_m (araddr_extsys1_axi_m),
  .arlen_extsys1_axi_m_m (arlen_extsys1_axi_m),
  .arsize_extsys1_axi_m_m (arsize_extsys1_axi_m),
  .arburst_extsys1_axi_m_m (arburst_extsys1_axi_m),
  .arlock_extsys1_axi_m_m (arlock_extsys1_axi_m),
  .arcache_extsys1_axi_m_m (arcache_extsys1_axi_m),
  .arprot_extsys1_axi_m_m (arprot_extsys1_axi_m),
  .arvalid_extsys1_axi_m_m (arvalid_extsys1_axi_m),
  .arready_extsys1_axi_m_m (arready_extsys1_axi_m),
  .rid_extsys1_axi_m_m  (rid_extsys1_axi_m),
  .rdata_extsys1_axi_m_m (rdata_extsys1_axi_m),
  .rresp_extsys1_axi_m_m (rresp_extsys1_axi_m),
  .rlast_extsys1_axi_m_m (rlast_extsys1_axi_m),
  .rvalid_extsys1_axi_m_m (rvalid_extsys1_axi_m),
  .rready_extsys1_axi_m_m (rready_extsys1_axi_m),
  .awid_extsys1_axi_m_s (awid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awaddr_extsys1_axi_m_s (awaddr_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awlen_extsys1_axi_m_s (awlen_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awsize_extsys1_axi_m_s (awsize_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awburst_extsys1_axi_m_s (awburst_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awlock_extsys1_axi_m_s (awlock_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awcache_extsys1_axi_m_s (awcache_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awprot_extsys1_axi_m_s (awprot_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awvalid_extsys1_axi_m_s (awvalid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awready_extsys1_axi_m_s (awready_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .wdata_extsys1_axi_m_s (wdata_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .wstrb_extsys1_axi_m_s (wstrb_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .wlast_extsys1_axi_m_s (wlast_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .wvalid_extsys1_axi_m_s (wvalid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .wready_extsys1_axi_m_s (wready_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .bid_extsys1_axi_m_s  (bid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .bresp_extsys1_axi_m_s (bresp_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .bvalid_extsys1_axi_m_s (bvalid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .bready_extsys1_axi_m_s (bready_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arid_extsys1_axi_m_s (arid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .araddr_extsys1_axi_m_s (araddr_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arlen_extsys1_axi_m_s (arlen_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arsize_extsys1_axi_m_s (arsize_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arburst_extsys1_axi_m_s (arburst_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arlock_extsys1_axi_m_s (arlock_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arcache_extsys1_axi_m_s (arcache_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arprot_extsys1_axi_m_s (arprot_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arvalid_extsys1_axi_m_s (arvalid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arready_extsys1_axi_m_s (arready_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .rid_extsys1_axi_m_s  (rid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .rdata_extsys1_axi_m_s (rdata_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .rresp_extsys1_axi_m_s (rresp_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .rlast_extsys1_axi_m_s (rlast_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .rvalid_extsys1_axi_m_s (rvalid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .rready_extsys1_axi_m_s (rready_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn)
);


nic400_asib_hostexpmst_0_s_sse710_integration_example_f0_host_exp     u_asib_hostexpmst_0_s (
  .awid_hostexpmst_0_s_m (awid_hostexpmst_0_s_bm1_axi_s_0),
  .awaddr_hostexpmst_0_s_m (awaddr_hostexpmst_0_s_bm1_axi_s_0),
  .awlen_hostexpmst_0_s_m (awlen_hostexpmst_0_s_bm1_axi_s_0),
  .awsize_hostexpmst_0_s_m (awsize_hostexpmst_0_s_bm1_axi_s_0),
  .awburst_hostexpmst_0_s_m (awburst_hostexpmst_0_s_bm1_axi_s_0),
  .awlock_hostexpmst_0_s_m (awlock_hostexpmst_0_s_bm1_axi_s_0),
  .awcache_hostexpmst_0_s_m (awcache_hostexpmst_0_s_bm1_axi_s_0),
  .awprot_hostexpmst_0_s_m (awprot_hostexpmst_0_s_bm1_axi_s_0),
  .awvalid_hostexpmst_0_s_m (awvalid_hostexpmst_0_s_bm1_axi_s_0),
  .awvalid_vect_hostexpmst_0_s_m (awvalid_vect_hostexpmst_0_s_bm1_axi_s_0),
  .awregion_hostexpmst_0_s_m (awregion_hostexpmst_0_s_bm1_axi_s_0),
  .awready_hostexpmst_0_s_m (awready_hostexpmst_0_s_bm1_axi_s_0),
  .wdata_hostexpmst_0_s_m (wdata_hostexpmst_0_s_bm1_axi_s_0),
  .wstrb_hostexpmst_0_s_m (wstrb_hostexpmst_0_s_bm1_axi_s_0),
  .wlast_hostexpmst_0_s_m (wlast_hostexpmst_0_s_bm1_axi_s_0),
  .wvalid_hostexpmst_0_s_m (wvalid_hostexpmst_0_s_bm1_axi_s_0),
  .wready_hostexpmst_0_s_m (wready_hostexpmst_0_s_bm1_axi_s_0),
  .bid_hostexpmst_0_s_m (bid_hostexpmst_0_s_bm1_axi_s_0),
  .bresp_hostexpmst_0_s_m (bresp_hostexpmst_0_s_bm1_axi_s_0),
  .bvalid_hostexpmst_0_s_m (bvalid_hostexpmst_0_s_bm1_axi_s_0),
  .bready_hostexpmst_0_s_m (bready_hostexpmst_0_s_bm1_axi_s_0),
  .arid_hostexpmst_0_s_m (arid_hostexpmst_0_s_bm1_axi_s_0),
  .araddr_hostexpmst_0_s_m (araddr_hostexpmst_0_s_bm1_axi_s_0),
  .arlen_hostexpmst_0_s_m (arlen_hostexpmst_0_s_bm1_axi_s_0),
  .arsize_hostexpmst_0_s_m (arsize_hostexpmst_0_s_bm1_axi_s_0),
  .arburst_hostexpmst_0_s_m (arburst_hostexpmst_0_s_bm1_axi_s_0),
  .arlock_hostexpmst_0_s_m (arlock_hostexpmst_0_s_bm1_axi_s_0),
  .arcache_hostexpmst_0_s_m (arcache_hostexpmst_0_s_bm1_axi_s_0),
  .arprot_hostexpmst_0_s_m (arprot_hostexpmst_0_s_bm1_axi_s_0),
  .arvalid_hostexpmst_0_s_m (arvalid_hostexpmst_0_s_bm1_axi_s_0),
  .arvalid_vect_hostexpmst_0_s_m (arvalid_vect_hostexpmst_0_s_bm1_axi_s_0),
  .arregion_hostexpmst_0_s_m (arregion_hostexpmst_0_s_bm1_axi_s_0),
  .arready_hostexpmst_0_s_m (arready_hostexpmst_0_s_bm1_axi_s_0),
  .rid_hostexpmst_0_s_m (rid_hostexpmst_0_s_bm1_axi_s_0),
  .rdata_hostexpmst_0_s_m (rdata_hostexpmst_0_s_bm1_axi_s_0),
  .rresp_hostexpmst_0_s_m (rresp_hostexpmst_0_s_bm1_axi_s_0),
  .rlast_hostexpmst_0_s_m (rlast_hostexpmst_0_s_bm1_axi_s_0),
  .rvalid_hostexpmst_0_s_m (rvalid_hostexpmst_0_s_bm1_axi_s_0),
  .rready_hostexpmst_0_s_m (rready_hostexpmst_0_s_bm1_axi_s_0),
  .awqv_hostexpmst_0_s_m (awqv_hostexpmst_0_s_bm1_axi_s_0),
  .arqv_hostexpmst_0_s_m (arqv_hostexpmst_0_s_bm1_axi_s_0),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn),
  .awid_hostexpmst_0_s_s (awid_hostexpmst_0_s),
  .awaddr_hostexpmst_0_s_s (awaddr_hostexpmst_0_s),
  .awlen_hostexpmst_0_s_s (awlen_hostexpmst_0_s),
  .awsize_hostexpmst_0_s_s (awsize_hostexpmst_0_s),
  .awburst_hostexpmst_0_s_s (awburst_hostexpmst_0_s),
  .awlock_hostexpmst_0_s_s (awlock_hostexpmst_0_s),
  .awcache_hostexpmst_0_s_s (awcache_hostexpmst_0_s),
  .awprot_hostexpmst_0_s_s (awprot_hostexpmst_0_s),
  .awvalid_hostexpmst_0_s_s (awvalid_hostexpmst_0_s),
  .awready_hostexpmst_0_s_s (awready_hostexpmst_0_s),
  .wdata_hostexpmst_0_s_s (wdata_hostexpmst_0_s),
  .wstrb_hostexpmst_0_s_s (wstrb_hostexpmst_0_s),
  .wlast_hostexpmst_0_s_s (wlast_hostexpmst_0_s),
  .wvalid_hostexpmst_0_s_s (wvalid_hostexpmst_0_s),
  .wready_hostexpmst_0_s_s (wready_hostexpmst_0_s),
  .bid_hostexpmst_0_s_s (bid_hostexpmst_0_s),
  .bresp_hostexpmst_0_s_s (bresp_hostexpmst_0_s),
  .bvalid_hostexpmst_0_s_s (bvalid_hostexpmst_0_s),
  .bready_hostexpmst_0_s_s (bready_hostexpmst_0_s),
  .arid_hostexpmst_0_s_s (arid_hostexpmst_0_s),
  .araddr_hostexpmst_0_s_s (araddr_hostexpmst_0_s),
  .arlen_hostexpmst_0_s_s (arlen_hostexpmst_0_s),
  .arsize_hostexpmst_0_s_s (arsize_hostexpmst_0_s),
  .arburst_hostexpmst_0_s_s (arburst_hostexpmst_0_s),
  .arlock_hostexpmst_0_s_s (arlock_hostexpmst_0_s),
  .arcache_hostexpmst_0_s_s (arcache_hostexpmst_0_s),
  .arprot_hostexpmst_0_s_s (arprot_hostexpmst_0_s),
  .arvalid_hostexpmst_0_s_s (arvalid_hostexpmst_0_s),
  .arready_hostexpmst_0_s_s (arready_hostexpmst_0_s),
  .rid_hostexpmst_0_s_s (rid_hostexpmst_0_s),
  .rdata_hostexpmst_0_s_s (rdata_hostexpmst_0_s),
  .rresp_hostexpmst_0_s_s (rresp_hostexpmst_0_s),
  .rlast_hostexpmst_0_s_s (rlast_hostexpmst_0_s),
  .rvalid_hostexpmst_0_s_s (rvalid_hostexpmst_0_s),
  .rready_hostexpmst_0_s_s (rready_hostexpmst_0_s)
);


nic400_asib_hostexpmst_1_s_sse710_integration_example_f0_host_exp     u_asib_hostexpmst_1_s (
  .awid_hostexpmst_1_s_m (awid_hostexpmst_1_s_bm1_axi_s_1),
  .awaddr_hostexpmst_1_s_m (awaddr_hostexpmst_1_s_bm1_axi_s_1),
  .awlen_hostexpmst_1_s_m (awlen_hostexpmst_1_s_bm1_axi_s_1),
  .awsize_hostexpmst_1_s_m (awsize_hostexpmst_1_s_bm1_axi_s_1),
  .awburst_hostexpmst_1_s_m (awburst_hostexpmst_1_s_bm1_axi_s_1),
  .awlock_hostexpmst_1_s_m (awlock_hostexpmst_1_s_bm1_axi_s_1),
  .awcache_hostexpmst_1_s_m (awcache_hostexpmst_1_s_bm1_axi_s_1),
  .awprot_hostexpmst_1_s_m (awprot_hostexpmst_1_s_bm1_axi_s_1),
  .awvalid_hostexpmst_1_s_m (awvalid_hostexpmst_1_s_bm1_axi_s_1),
  .awvalid_vect_hostexpmst_1_s_m (awvalid_vect_hostexpmst_1_s_bm1_axi_s_1),
  .awregion_hostexpmst_1_s_m (awregion_hostexpmst_1_s_bm1_axi_s_1),
  .awready_hostexpmst_1_s_m (awready_hostexpmst_1_s_bm1_axi_s_1),
  .wdata_hostexpmst_1_s_m (wdata_hostexpmst_1_s_bm1_axi_s_1),
  .wstrb_hostexpmst_1_s_m (wstrb_hostexpmst_1_s_bm1_axi_s_1),
  .wlast_hostexpmst_1_s_m (wlast_hostexpmst_1_s_bm1_axi_s_1),
  .wvalid_hostexpmst_1_s_m (wvalid_hostexpmst_1_s_bm1_axi_s_1),
  .wready_hostexpmst_1_s_m (wready_hostexpmst_1_s_bm1_axi_s_1),
  .bid_hostexpmst_1_s_m (bid_hostexpmst_1_s_bm1_axi_s_1),
  .bresp_hostexpmst_1_s_m (bresp_hostexpmst_1_s_bm1_axi_s_1),
  .bvalid_hostexpmst_1_s_m (bvalid_hostexpmst_1_s_bm1_axi_s_1),
  .bready_hostexpmst_1_s_m (bready_hostexpmst_1_s_bm1_axi_s_1),
  .arid_hostexpmst_1_s_m (arid_hostexpmst_1_s_bm1_axi_s_1),
  .araddr_hostexpmst_1_s_m (araddr_hostexpmst_1_s_bm1_axi_s_1),
  .arlen_hostexpmst_1_s_m (arlen_hostexpmst_1_s_bm1_axi_s_1),
  .arsize_hostexpmst_1_s_m (arsize_hostexpmst_1_s_bm1_axi_s_1),
  .arburst_hostexpmst_1_s_m (arburst_hostexpmst_1_s_bm1_axi_s_1),
  .arlock_hostexpmst_1_s_m (arlock_hostexpmst_1_s_bm1_axi_s_1),
  .arcache_hostexpmst_1_s_m (arcache_hostexpmst_1_s_bm1_axi_s_1),
  .arprot_hostexpmst_1_s_m (arprot_hostexpmst_1_s_bm1_axi_s_1),
  .arvalid_hostexpmst_1_s_m (arvalid_hostexpmst_1_s_bm1_axi_s_1),
  .arvalid_vect_hostexpmst_1_s_m (arvalid_vect_hostexpmst_1_s_bm1_axi_s_1),
  .arregion_hostexpmst_1_s_m (arregion_hostexpmst_1_s_bm1_axi_s_1),
  .arready_hostexpmst_1_s_m (arready_hostexpmst_1_s_bm1_axi_s_1),
  .rid_hostexpmst_1_s_m (rid_hostexpmst_1_s_bm1_axi_s_1),
  .rdata_hostexpmst_1_s_m (rdata_hostexpmst_1_s_bm1_axi_s_1),
  .rresp_hostexpmst_1_s_m (rresp_hostexpmst_1_s_bm1_axi_s_1),
  .rlast_hostexpmst_1_s_m (rlast_hostexpmst_1_s_bm1_axi_s_1),
  .rvalid_hostexpmst_1_s_m (rvalid_hostexpmst_1_s_bm1_axi_s_1),
  .rready_hostexpmst_1_s_m (rready_hostexpmst_1_s_bm1_axi_s_1),
  .awqv_hostexpmst_1_s_m (awqv_hostexpmst_1_s_bm1_axi_s_1),
  .arqv_hostexpmst_1_s_m (arqv_hostexpmst_1_s_bm1_axi_s_1),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn),
  .awid_hostexpmst_1_s_s (awid_hostexpmst_1_s),
  .awaddr_hostexpmst_1_s_s (awaddr_hostexpmst_1_s),
  .awlen_hostexpmst_1_s_s (awlen_hostexpmst_1_s),
  .awsize_hostexpmst_1_s_s (awsize_hostexpmst_1_s),
  .awburst_hostexpmst_1_s_s (awburst_hostexpmst_1_s),
  .awlock_hostexpmst_1_s_s (awlock_hostexpmst_1_s),
  .awcache_hostexpmst_1_s_s (awcache_hostexpmst_1_s),
  .awprot_hostexpmst_1_s_s (awprot_hostexpmst_1_s),
  .awvalid_hostexpmst_1_s_s (awvalid_hostexpmst_1_s),
  .awready_hostexpmst_1_s_s (awready_hostexpmst_1_s),
  .wdata_hostexpmst_1_s_s (wdata_hostexpmst_1_s),
  .wstrb_hostexpmst_1_s_s (wstrb_hostexpmst_1_s),
  .wlast_hostexpmst_1_s_s (wlast_hostexpmst_1_s),
  .wvalid_hostexpmst_1_s_s (wvalid_hostexpmst_1_s),
  .wready_hostexpmst_1_s_s (wready_hostexpmst_1_s),
  .bid_hostexpmst_1_s_s (bid_hostexpmst_1_s),
  .bresp_hostexpmst_1_s_s (bresp_hostexpmst_1_s),
  .bvalid_hostexpmst_1_s_s (bvalid_hostexpmst_1_s),
  .bready_hostexpmst_1_s_s (bready_hostexpmst_1_s),
  .arid_hostexpmst_1_s_s (arid_hostexpmst_1_s),
  .araddr_hostexpmst_1_s_s (araddr_hostexpmst_1_s),
  .arlen_hostexpmst_1_s_s (arlen_hostexpmst_1_s),
  .arsize_hostexpmst_1_s_s (arsize_hostexpmst_1_s),
  .arburst_hostexpmst_1_s_s (arburst_hostexpmst_1_s),
  .arlock_hostexpmst_1_s_s (arlock_hostexpmst_1_s),
  .arcache_hostexpmst_1_s_s (arcache_hostexpmst_1_s),
  .arprot_hostexpmst_1_s_s (arprot_hostexpmst_1_s),
  .arvalid_hostexpmst_1_s_s (arvalid_hostexpmst_1_s),
  .arready_hostexpmst_1_s_s (arready_hostexpmst_1_s),
  .rid_hostexpmst_1_s_s (rid_hostexpmst_1_s),
  .rdata_hostexpmst_1_s_s (rdata_hostexpmst_1_s),
  .rresp_hostexpmst_1_s_s (rresp_hostexpmst_1_s),
  .rlast_hostexpmst_1_s_s (rlast_hostexpmst_1_s),
  .rvalid_hostexpmst_1_s_s (rvalid_hostexpmst_1_s),
  .rready_hostexpmst_1_s_s (rready_hostexpmst_1_s)
);


nic400_bm0_sse710_integration_example_f0_host_exp     u_busmatrix_bm0 (
  .awid_axi_m_0         (awid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awaddr_axi_m_0       (awaddr_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awlen_axi_m_0        (awlen_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awsize_axi_m_0       (awsize_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awburst_axi_m_0      (awburst_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awlock_axi_m_0       (awlock_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awcache_axi_m_0      (awcache_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awprot_axi_m_0       (awprot_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awregion_axi_m_0     (),
  .awvalid_axi_m_0      (awvalid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .awvalid_vect_axi_m_0 (),
  .awready_axi_m_0      (awready_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .wdata_axi_m_0        (wdata_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .wstrb_axi_m_0        (wstrb_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .wlast_axi_m_0        (wlast_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .wvalid_axi_m_0       (wvalid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .wready_axi_m_0       (wready_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .bid_axi_m_0          (bid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .bresp_axi_m_0        (bresp_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .bvalid_axi_m_0       (bvalid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .bready_axi_m_0       (bready_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arid_axi_m_0         (arid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .araddr_axi_m_0       (araddr_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arlen_axi_m_0        (arlen_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arsize_axi_m_0       (arsize_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arburst_axi_m_0      (arburst_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arlock_axi_m_0       (arlock_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arcache_axi_m_0      (arcache_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arprot_axi_m_0       (arprot_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arregion_axi_m_0     (),
  .arvalid_axi_m_0      (arvalid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .arvalid_vect_axi_m_0 (),
  .arready_axi_m_0      (arready_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .rid_axi_m_0          (rid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .rdata_axi_m_0        (rdata_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .rresp_axi_m_0        (rresp_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .rlast_axi_m_0        (rlast_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .rvalid_axi_m_0       (rvalid_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .rready_axi_m_0       (rready_bm0_extsys0_axi_m_extsys0_axi_m_s),
  .aw_qv_axi_m_0        (),
  .ar_qv_axi_m_0        (),
  .awid_axi_m_1         (awid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awaddr_axi_m_1       (awaddr_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awlen_axi_m_1        (awlen_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awsize_axi_m_1       (awsize_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awburst_axi_m_1      (awburst_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awlock_axi_m_1       (awlock_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awcache_axi_m_1      (awcache_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awprot_axi_m_1       (awprot_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awregion_axi_m_1     (),
  .awvalid_axi_m_1      (awvalid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .awvalid_vect_axi_m_1 (),
  .awready_axi_m_1      (awready_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .wdata_axi_m_1        (wdata_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .wstrb_axi_m_1        (wstrb_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .wlast_axi_m_1        (wlast_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .wvalid_axi_m_1       (wvalid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .wready_axi_m_1       (wready_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .bid_axi_m_1          (bid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .bresp_axi_m_1        (bresp_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .bvalid_axi_m_1       (bvalid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .bready_axi_m_1       (bready_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arid_axi_m_1         (arid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .araddr_axi_m_1       (araddr_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arlen_axi_m_1        (arlen_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arsize_axi_m_1       (arsize_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arburst_axi_m_1      (arburst_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arlock_axi_m_1       (arlock_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arcache_axi_m_1      (arcache_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arprot_axi_m_1       (arprot_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arregion_axi_m_1     (),
  .arvalid_axi_m_1      (arvalid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .arvalid_vect_axi_m_1 (),
  .arready_axi_m_1      (arready_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .rid_axi_m_1          (rid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .rdata_axi_m_1        (rdata_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .rresp_axi_m_1        (rresp_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .rlast_axi_m_1        (rlast_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .rvalid_axi_m_1       (rvalid_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .rready_axi_m_1       (rready_bm0_extsys1_axi_m_extsys1_axi_m_s),
  .aw_qv_axi_m_1        (),
  .ar_qv_axi_m_1        (),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn),
  .awid_axi_s_0         (awid_ib2_bm0_axi_s_0),
  .awaddr_axi_s_0       (awaddr_ib2_bm0_axi_s_0),
  .awlen_axi_s_0        (awlen_ib2_bm0_axi_s_0),
  .awsize_axi_s_0       (awsize_ib2_bm0_axi_s_0),
  .awburst_axi_s_0      (awburst_ib2_bm0_axi_s_0),
  .awlock_axi_s_0       (awlock_ib2_bm0_axi_s_0),
  .awcache_axi_s_0      (awcache_ib2_bm0_axi_s_0),
  .awprot_axi_s_0       (awprot_ib2_bm0_axi_s_0),
  .awregion_axi_s_0     (awregion_ib2_bm0_axi_s_0),
  .awvalid_axi_s_0      (awvalid_ib2_bm0_axi_s_0),
  .awvalid_vect_axi_s_0 (awvalid_vect_ib2_bm0_axi_s_0),
  .awready_axi_s_0      (awready_ib2_bm0_axi_s_0),
  .wdata_axi_s_0        (wdata_ib2_bm0_axi_s_0),
  .wstrb_axi_s_0        (wstrb_ib2_bm0_axi_s_0),
  .wlast_axi_s_0        (wlast_ib2_bm0_axi_s_0),
  .wvalid_axi_s_0       (wvalid_ib2_bm0_axi_s_0),
  .wready_axi_s_0       (wready_ib2_bm0_axi_s_0),
  .bid_axi_s_0          (bid_ib2_bm0_axi_s_0),
  .bresp_axi_s_0        (bresp_ib2_bm0_axi_s_0),
  .bvalid_axi_s_0       (bvalid_ib2_bm0_axi_s_0),
  .bready_axi_s_0       (bready_ib2_bm0_axi_s_0),
  .arid_axi_s_0         (arid_ib2_bm0_axi_s_0),
  .araddr_axi_s_0       (araddr_ib2_bm0_axi_s_0),
  .arlen_axi_s_0        (arlen_ib2_bm0_axi_s_0),
  .arsize_axi_s_0       (arsize_ib2_bm0_axi_s_0),
  .arburst_axi_s_0      (arburst_ib2_bm0_axi_s_0),
  .arlock_axi_s_0       (arlock_ib2_bm0_axi_s_0),
  .arcache_axi_s_0      (arcache_ib2_bm0_axi_s_0),
  .arprot_axi_s_0       (arprot_ib2_bm0_axi_s_0),
  .arregion_axi_s_0     (arregion_ib2_bm0_axi_s_0),
  .arvalid_axi_s_0      (arvalid_ib2_bm0_axi_s_0),
  .arvalid_vect_axi_s_0 (arvalid_vect_ib2_bm0_axi_s_0),
  .arready_axi_s_0      (arready_ib2_bm0_axi_s_0),
  .rid_axi_s_0          (rid_ib2_bm0_axi_s_0),
  .rdata_axi_s_0        (rdata_ib2_bm0_axi_s_0),
  .rresp_axi_s_0        (rresp_ib2_bm0_axi_s_0),
  .rlast_axi_s_0        (rlast_ib2_bm0_axi_s_0),
  .rvalid_axi_s_0       (rvalid_ib2_bm0_axi_s_0),
  .rready_axi_s_0       (rready_ib2_bm0_axi_s_0),
  .aw_qv_axi_s_0        (awqv_ib2_bm0_axi_s_0),
  .ar_qv_axi_s_0        (arqv_ib2_bm0_axi_s_0)
);


nic400_bm1_sse710_integration_example_f0_host_exp     u_busmatrix_bm1 (
  .awid_axi_m_0         (awid_bm1_ib2_ib2_s),
  .awaddr_axi_m_0       (awaddr_bm1_ib2_ib2_s),
  .awlen_axi_m_0        (awlen_bm1_ib2_ib2_s),
  .awsize_axi_m_0       (awsize_bm1_ib2_ib2_s),
  .awburst_axi_m_0      (awburst_bm1_ib2_ib2_s),
  .awlock_axi_m_0       (awlock_bm1_ib2_ib2_s),
  .awcache_axi_m_0      (awcache_bm1_ib2_ib2_s),
  .awprot_axi_m_0       (awprot_bm1_ib2_ib2_s),
  .awregion_axi_m_0     (awregion_bm1_ib2_ib2_s),
  .awvalid_axi_m_0      (awvalid_bm1_ib2_ib2_s),
  .awvalid_vect_axi_m_0 (awvalid_vect_bm1_ib2_ib2_s),
  .awready_axi_m_0      (awready_bm1_ib2_ib2_s),
  .wdata_axi_m_0        (wdata_bm1_ib2_ib2_s),
  .wstrb_axi_m_0        (wstrb_bm1_ib2_ib2_s),
  .wlast_axi_m_0        (wlast_bm1_ib2_ib2_s),
  .wvalid_axi_m_0       (wvalid_bm1_ib2_ib2_s),
  .wready_axi_m_0       (wready_bm1_ib2_ib2_s),
  .bid_axi_m_0          (bid_bm1_ib2_ib2_s),
  .bresp_axi_m_0        (bresp_bm1_ib2_ib2_s),
  .bvalid_axi_m_0       (bvalid_bm1_ib2_ib2_s),
  .bready_axi_m_0       (bready_bm1_ib2_ib2_s),
  .arid_axi_m_0         (arid_bm1_ib2_ib2_s),
  .araddr_axi_m_0       (araddr_bm1_ib2_ib2_s),
  .arlen_axi_m_0        (arlen_bm1_ib2_ib2_s),
  .arsize_axi_m_0       (arsize_bm1_ib2_ib2_s),
  .arburst_axi_m_0      (arburst_bm1_ib2_ib2_s),
  .arlock_axi_m_0       (arlock_bm1_ib2_ib2_s),
  .arcache_axi_m_0      (arcache_bm1_ib2_ib2_s),
  .arprot_axi_m_0       (arprot_bm1_ib2_ib2_s),
  .arregion_axi_m_0     (arregion_bm1_ib2_ib2_s),
  .arvalid_axi_m_0      (arvalid_bm1_ib2_ib2_s),
  .arvalid_vect_axi_m_0 (arvalid_vect_bm1_ib2_ib2_s),
  .arready_axi_m_0      (arready_bm1_ib2_ib2_s),
  .rid_axi_m_0          (rid_bm1_ib2_ib2_s),
  .rdata_axi_m_0        (rdata_bm1_ib2_ib2_s),
  .rresp_axi_m_0        (rresp_bm1_ib2_ib2_s),
  .rlast_axi_m_0        (rlast_bm1_ib2_ib2_s),
  .rvalid_axi_m_0       (rvalid_bm1_ib2_ib2_s),
  .rready_axi_m_0       (rready_bm1_ib2_ib2_s),
  .aw_qv_axi_m_0        (awqv_bm1_ib2_ib2_s),
  .ar_qv_axi_m_0        (arqv_bm1_ib2_ib2_s),
  .awid_axi_m_1         (awid_bm1_gpio_ahb_m_ib_axi4_s),
  .awaddr_axi_m_1       (awaddr_bm1_gpio_ahb_m_ib_axi4_s),
  .awlen_axi_m_1        (awlen_bm1_gpio_ahb_m_ib_axi4_s),
  .awsize_axi_m_1       (awsize_bm1_gpio_ahb_m_ib_axi4_s),
  .awburst_axi_m_1      (awburst_bm1_gpio_ahb_m_ib_axi4_s),
  .awlock_axi_m_1       (awlock_bm1_gpio_ahb_m_ib_axi4_s),
  .awcache_axi_m_1      (awcache_bm1_gpio_ahb_m_ib_axi4_s),
  .awprot_axi_m_1       (awprot_bm1_gpio_ahb_m_ib_axi4_s),
  .awregion_axi_m_1     (awregion_bm1_gpio_ahb_m_ib_axi4_s),
  .awvalid_axi_m_1      (awvalid_bm1_gpio_ahb_m_ib_axi4_s),
  .awvalid_vect_axi_m_1 (),
  .awready_axi_m_1      (awready_bm1_gpio_ahb_m_ib_axi4_s),
  .wdata_axi_m_1        (wdata_bm1_gpio_ahb_m_ib_axi4_s),
  .wstrb_axi_m_1        (wstrb_bm1_gpio_ahb_m_ib_axi4_s),
  .wlast_axi_m_1        (wlast_bm1_gpio_ahb_m_ib_axi4_s),
  .wvalid_axi_m_1       (wvalid_bm1_gpio_ahb_m_ib_axi4_s),
  .wready_axi_m_1       (wready_bm1_gpio_ahb_m_ib_axi4_s),
  .bid_axi_m_1          (bid_bm1_gpio_ahb_m_ib_axi4_s),
  .bresp_axi_m_1        (bresp_bm1_gpio_ahb_m_ib_axi4_s),
  .bvalid_axi_m_1       (bvalid_bm1_gpio_ahb_m_ib_axi4_s),
  .bready_axi_m_1       (bready_bm1_gpio_ahb_m_ib_axi4_s),
  .arid_axi_m_1         (arid_bm1_gpio_ahb_m_ib_axi4_s),
  .araddr_axi_m_1       (araddr_bm1_gpio_ahb_m_ib_axi4_s),
  .arlen_axi_m_1        (arlen_bm1_gpio_ahb_m_ib_axi4_s),
  .arsize_axi_m_1       (arsize_bm1_gpio_ahb_m_ib_axi4_s),
  .arburst_axi_m_1      (arburst_bm1_gpio_ahb_m_ib_axi4_s),
  .arlock_axi_m_1       (arlock_bm1_gpio_ahb_m_ib_axi4_s),
  .arcache_axi_m_1      (arcache_bm1_gpio_ahb_m_ib_axi4_s),
  .arprot_axi_m_1       (arprot_bm1_gpio_ahb_m_ib_axi4_s),
  .arregion_axi_m_1     (arregion_bm1_gpio_ahb_m_ib_axi4_s),
  .arvalid_axi_m_1      (arvalid_bm1_gpio_ahb_m_ib_axi4_s),
  .arvalid_vect_axi_m_1 (),
  .arready_axi_m_1      (arready_bm1_gpio_ahb_m_ib_axi4_s),
  .rid_axi_m_1          (rid_bm1_gpio_ahb_m_ib_axi4_s),
  .rdata_axi_m_1        (rdata_bm1_gpio_ahb_m_ib_axi4_s),
  .rresp_axi_m_1        (rresp_bm1_gpio_ahb_m_ib_axi4_s),
  .rlast_axi_m_1        (rlast_bm1_gpio_ahb_m_ib_axi4_s),
  .rvalid_axi_m_1       (rvalid_bm1_gpio_ahb_m_ib_axi4_s),
  .rready_axi_m_1       (rready_bm1_gpio_ahb_m_ib_axi4_s),
  .aw_qv_axi_m_1        (),
  .ar_qv_axi_m_1        (),
  .awid_axi_m_2         (awid_bm1_apb_group0_ib_axi4_s),
  .awaddr_axi_m_2       (awaddr_bm1_apb_group0_ib_axi4_s),
  .awlen_axi_m_2        (awlen_bm1_apb_group0_ib_axi4_s),
  .awsize_axi_m_2       (awsize_bm1_apb_group0_ib_axi4_s),
  .awburst_axi_m_2      (awburst_bm1_apb_group0_ib_axi4_s),
  .awlock_axi_m_2       (awlock_bm1_apb_group0_ib_axi4_s),
  .awcache_axi_m_2      (awcache_bm1_apb_group0_ib_axi4_s),
  .awprot_axi_m_2       (awprot_bm1_apb_group0_ib_axi4_s),
  .awregion_axi_m_2     (awregion_bm1_apb_group0_ib_axi4_s),
  .awvalid_axi_m_2      (awvalid_bm1_apb_group0_ib_axi4_s),
  .awvalid_vect_axi_m_2 (),
  .awready_axi_m_2      (awready_bm1_apb_group0_ib_axi4_s),
  .wdata_axi_m_2        (wdata_bm1_apb_group0_ib_axi4_s),
  .wstrb_axi_m_2        (wstrb_bm1_apb_group0_ib_axi4_s),
  .wlast_axi_m_2        (wlast_bm1_apb_group0_ib_axi4_s),
  .wvalid_axi_m_2       (wvalid_bm1_apb_group0_ib_axi4_s),
  .wready_axi_m_2       (wready_bm1_apb_group0_ib_axi4_s),
  .bid_axi_m_2          (bid_bm1_apb_group0_ib_axi4_s),
  .bresp_axi_m_2        (bresp_bm1_apb_group0_ib_axi4_s),
  .bvalid_axi_m_2       (bvalid_bm1_apb_group0_ib_axi4_s),
  .bready_axi_m_2       (bready_bm1_apb_group0_ib_axi4_s),
  .arid_axi_m_2         (arid_bm1_apb_group0_ib_axi4_s),
  .araddr_axi_m_2       (araddr_bm1_apb_group0_ib_axi4_s),
  .arlen_axi_m_2        (arlen_bm1_apb_group0_ib_axi4_s),
  .arsize_axi_m_2       (arsize_bm1_apb_group0_ib_axi4_s),
  .arburst_axi_m_2      (arburst_bm1_apb_group0_ib_axi4_s),
  .arlock_axi_m_2       (arlock_bm1_apb_group0_ib_axi4_s),
  .arcache_axi_m_2      (arcache_bm1_apb_group0_ib_axi4_s),
  .arprot_axi_m_2       (arprot_bm1_apb_group0_ib_axi4_s),
  .arregion_axi_m_2     (arregion_bm1_apb_group0_ib_axi4_s),
  .arvalid_axi_m_2      (arvalid_bm1_apb_group0_ib_axi4_s),
  .arvalid_vect_axi_m_2 (),
  .arready_axi_m_2      (arready_bm1_apb_group0_ib_axi4_s),
  .rid_axi_m_2          (rid_bm1_apb_group0_ib_axi4_s),
  .rdata_axi_m_2        (rdata_bm1_apb_group0_ib_axi4_s),
  .rresp_axi_m_2        (rresp_bm1_apb_group0_ib_axi4_s),
  .rlast_axi_m_2        (rlast_bm1_apb_group0_ib_axi4_s),
  .rvalid_axi_m_2       (rvalid_bm1_apb_group0_ib_axi4_s),
  .rready_axi_m_2       (rready_bm1_apb_group0_ib_axi4_s),
  .aw_qv_axi_m_2        (),
  .ar_qv_axi_m_2        (),
  .awid_axi_m_3         (awid_bm1_ds_3_axi_s_0),
  .awaddr_axi_m_3       (),
  .awlen_axi_m_3        (),
  .awsize_axi_m_3       (),
  .awburst_axi_m_3      (),
  .awlock_axi_m_3       (),
  .awcache_axi_m_3      (),
  .awprot_axi_m_3       (),
  .awregion_axi_m_3     (),
  .awvalid_axi_m_3      (awvalid_bm1_ds_3_axi_s_0),
  .awvalid_vect_axi_m_3 (),
  .awready_axi_m_3      (awready_bm1_ds_3_axi_s_0),
  .wdata_axi_m_3        (),
  .wstrb_axi_m_3        (),
  .wlast_axi_m_3        (wlast_bm1_ds_3_axi_s_0),
  .wvalid_axi_m_3       (wvalid_bm1_ds_3_axi_s_0),
  .wready_axi_m_3       (wready_bm1_ds_3_axi_s_0),
  .bid_axi_m_3          (bid_bm1_ds_3_axi_s_0),
  .bresp_axi_m_3        (bresp_bm1_ds_3_axi_s_0),
  .bvalid_axi_m_3       (bvalid_bm1_ds_3_axi_s_0),
  .bready_axi_m_3       (bready_bm1_ds_3_axi_s_0),
  .arid_axi_m_3         (arid_bm1_ds_3_axi_s_0),
  .araddr_axi_m_3       (),
  .arlen_axi_m_3        (arlen_bm1_ds_3_axi_s_0),
  .arsize_axi_m_3       (),
  .arburst_axi_m_3      (),
  .arlock_axi_m_3       (),
  .arcache_axi_m_3      (),
  .arprot_axi_m_3       (),
  .arregion_axi_m_3     (),
  .arvalid_axi_m_3      (arvalid_bm1_ds_3_axi_s_0),
  .arvalid_vect_axi_m_3 (),
  .arready_axi_m_3      (arready_bm1_ds_3_axi_s_0),
  .rid_axi_m_3          (rid_bm1_ds_3_axi_s_0),
  .rdata_axi_m_3        (64'b0),
  .rresp_axi_m_3        (rresp_bm1_ds_3_axi_s_0),
  .rlast_axi_m_3        (rlast_bm1_ds_3_axi_s_0),
  .rvalid_axi_m_3       (rvalid_bm1_ds_3_axi_s_0),
  .rready_axi_m_3       (rready_bm1_ds_3_axi_s_0),
  .aw_qv_axi_m_3        (),
  .ar_qv_axi_m_3        (),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn),
  .awid_axi_s_0         (awid_hostexpmst_0_s_bm1_axi_s_0),
  .awaddr_axi_s_0       (awaddr_hostexpmst_0_s_bm1_axi_s_0),
  .awlen_axi_s_0        (awlen_hostexpmst_0_s_bm1_axi_s_0),
  .awsize_axi_s_0       (awsize_hostexpmst_0_s_bm1_axi_s_0),
  .awburst_axi_s_0      (awburst_hostexpmst_0_s_bm1_axi_s_0),
  .awlock_axi_s_0       (awlock_hostexpmst_0_s_bm1_axi_s_0),
  .awcache_axi_s_0      (awcache_hostexpmst_0_s_bm1_axi_s_0),
  .awprot_axi_s_0       (awprot_hostexpmst_0_s_bm1_axi_s_0),
  .awregion_axi_s_0     (awregion_hostexpmst_0_s_bm1_axi_s_0),
  .awvalid_axi_s_0      (awvalid_hostexpmst_0_s_bm1_axi_s_0),
  .awvalid_vect_axi_s_0 (awvalid_vect_hostexpmst_0_s_bm1_axi_s_0),
  .awready_axi_s_0      (awready_hostexpmst_0_s_bm1_axi_s_0),
  .wdata_axi_s_0        (wdata_hostexpmst_0_s_bm1_axi_s_0),
  .wstrb_axi_s_0        (wstrb_hostexpmst_0_s_bm1_axi_s_0),
  .wlast_axi_s_0        (wlast_hostexpmst_0_s_bm1_axi_s_0),
  .wvalid_axi_s_0       (wvalid_hostexpmst_0_s_bm1_axi_s_0),
  .wready_axi_s_0       (wready_hostexpmst_0_s_bm1_axi_s_0),
  .bid_axi_s_0          (bid_hostexpmst_0_s_bm1_axi_s_0),
  .bresp_axi_s_0        (bresp_hostexpmst_0_s_bm1_axi_s_0),
  .bvalid_axi_s_0       (bvalid_hostexpmst_0_s_bm1_axi_s_0),
  .bready_axi_s_0       (bready_hostexpmst_0_s_bm1_axi_s_0),
  .arid_axi_s_0         (arid_hostexpmst_0_s_bm1_axi_s_0),
  .araddr_axi_s_0       (araddr_hostexpmst_0_s_bm1_axi_s_0),
  .arlen_axi_s_0        (arlen_hostexpmst_0_s_bm1_axi_s_0),
  .arsize_axi_s_0       (arsize_hostexpmst_0_s_bm1_axi_s_0),
  .arburst_axi_s_0      (arburst_hostexpmst_0_s_bm1_axi_s_0),
  .arlock_axi_s_0       (arlock_hostexpmst_0_s_bm1_axi_s_0),
  .arcache_axi_s_0      (arcache_hostexpmst_0_s_bm1_axi_s_0),
  .arprot_axi_s_0       (arprot_hostexpmst_0_s_bm1_axi_s_0),
  .arregion_axi_s_0     (arregion_hostexpmst_0_s_bm1_axi_s_0),
  .arvalid_axi_s_0      (arvalid_hostexpmst_0_s_bm1_axi_s_0),
  .arvalid_vect_axi_s_0 (arvalid_vect_hostexpmst_0_s_bm1_axi_s_0),
  .arready_axi_s_0      (arready_hostexpmst_0_s_bm1_axi_s_0),
  .rid_axi_s_0          (rid_hostexpmst_0_s_bm1_axi_s_0),
  .rdata_axi_s_0        (rdata_hostexpmst_0_s_bm1_axi_s_0),
  .rresp_axi_s_0        (rresp_hostexpmst_0_s_bm1_axi_s_0),
  .rlast_axi_s_0        (rlast_hostexpmst_0_s_bm1_axi_s_0),
  .rvalid_axi_s_0       (rvalid_hostexpmst_0_s_bm1_axi_s_0),
  .rready_axi_s_0       (rready_hostexpmst_0_s_bm1_axi_s_0),
  .aw_qv_axi_s_0        (awqv_hostexpmst_0_s_bm1_axi_s_0),
  .ar_qv_axi_s_0        (arqv_hostexpmst_0_s_bm1_axi_s_0),
  .awid_axi_s_1         (awid_hostexpmst_1_s_bm1_axi_s_1),
  .awaddr_axi_s_1       (awaddr_hostexpmst_1_s_bm1_axi_s_1),
  .awlen_axi_s_1        (awlen_hostexpmst_1_s_bm1_axi_s_1),
  .awsize_axi_s_1       (awsize_hostexpmst_1_s_bm1_axi_s_1),
  .awburst_axi_s_1      (awburst_hostexpmst_1_s_bm1_axi_s_1),
  .awlock_axi_s_1       (awlock_hostexpmst_1_s_bm1_axi_s_1),
  .awcache_axi_s_1      (awcache_hostexpmst_1_s_bm1_axi_s_1),
  .awprot_axi_s_1       (awprot_hostexpmst_1_s_bm1_axi_s_1),
  .awregion_axi_s_1     (awregion_hostexpmst_1_s_bm1_axi_s_1),
  .awvalid_axi_s_1      (awvalid_hostexpmst_1_s_bm1_axi_s_1),
  .awvalid_vect_axi_s_1 (awvalid_vect_hostexpmst_1_s_bm1_axi_s_1),
  .awready_axi_s_1      (awready_hostexpmst_1_s_bm1_axi_s_1),
  .wdata_axi_s_1        (wdata_hostexpmst_1_s_bm1_axi_s_1),
  .wstrb_axi_s_1        (wstrb_hostexpmst_1_s_bm1_axi_s_1),
  .wlast_axi_s_1        (wlast_hostexpmst_1_s_bm1_axi_s_1),
  .wvalid_axi_s_1       (wvalid_hostexpmst_1_s_bm1_axi_s_1),
  .wready_axi_s_1       (wready_hostexpmst_1_s_bm1_axi_s_1),
  .bid_axi_s_1          (bid_hostexpmst_1_s_bm1_axi_s_1),
  .bresp_axi_s_1        (bresp_hostexpmst_1_s_bm1_axi_s_1),
  .bvalid_axi_s_1       (bvalid_hostexpmst_1_s_bm1_axi_s_1),
  .bready_axi_s_1       (bready_hostexpmst_1_s_bm1_axi_s_1),
  .arid_axi_s_1         (arid_hostexpmst_1_s_bm1_axi_s_1),
  .araddr_axi_s_1       (araddr_hostexpmst_1_s_bm1_axi_s_1),
  .arlen_axi_s_1        (arlen_hostexpmst_1_s_bm1_axi_s_1),
  .arsize_axi_s_1       (arsize_hostexpmst_1_s_bm1_axi_s_1),
  .arburst_axi_s_1      (arburst_hostexpmst_1_s_bm1_axi_s_1),
  .arlock_axi_s_1       (arlock_hostexpmst_1_s_bm1_axi_s_1),
  .arcache_axi_s_1      (arcache_hostexpmst_1_s_bm1_axi_s_1),
  .arprot_axi_s_1       (arprot_hostexpmst_1_s_bm1_axi_s_1),
  .arregion_axi_s_1     (arregion_hostexpmst_1_s_bm1_axi_s_1),
  .arvalid_axi_s_1      (arvalid_hostexpmst_1_s_bm1_axi_s_1),
  .arvalid_vect_axi_s_1 (arvalid_vect_hostexpmst_1_s_bm1_axi_s_1),
  .arready_axi_s_1      (arready_hostexpmst_1_s_bm1_axi_s_1),
  .rid_axi_s_1          (rid_hostexpmst_1_s_bm1_axi_s_1),
  .rdata_axi_s_1        (rdata_hostexpmst_1_s_bm1_axi_s_1),
  .rresp_axi_s_1        (rresp_hostexpmst_1_s_bm1_axi_s_1),
  .rlast_axi_s_1        (rlast_hostexpmst_1_s_bm1_axi_s_1),
  .rvalid_axi_s_1       (rvalid_hostexpmst_1_s_bm1_axi_s_1),
  .rready_axi_s_1       (rready_hostexpmst_1_s_bm1_axi_s_1),
  .aw_qv_axi_s_1        (awqv_hostexpmst_1_s_bm1_axi_s_1),
  .ar_qv_axi_s_1        (arqv_hostexpmst_1_s_bm1_axi_s_1)
);


nic400_default_slave_ds_3_sse710_integration_example_f0_host_exp     u_default_slave_ds_3 (
  .awid                 (awid_bm1_ds_3_axi_s_0),
  .awvalid              (awvalid_bm1_ds_3_axi_s_0),
  .awready              (awready_bm1_ds_3_axi_s_0),
  .wlast                (wlast_bm1_ds_3_axi_s_0),
  .wvalid               (wvalid_bm1_ds_3_axi_s_0),
  .wready               (wready_bm1_ds_3_axi_s_0),
  .bid                  (bid_bm1_ds_3_axi_s_0),
  .bresp                (bresp_bm1_ds_3_axi_s_0),
  .bvalid               (bvalid_bm1_ds_3_axi_s_0),
  .bready               (bready_bm1_ds_3_axi_s_0),
  .arid                 (arid_bm1_ds_3_axi_s_0),
  .arlen                (arlen_bm1_ds_3_axi_s_0),
  .arvalid              (arvalid_bm1_ds_3_axi_s_0),
  .arready              (arready_bm1_ds_3_axi_s_0),
  .rid                  (rid_bm1_ds_3_axi_s_0),
  .rresp                (rresp_bm1_ds_3_axi_s_0),
  .rlast                (rlast_bm1_ds_3_axi_s_0),
  .rvalid               (rvalid_bm1_ds_3_axi_s_0),
  .rready               (rready_bm1_ds_3_axi_s_0),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn)
);


nic400_ib_apb_group0_ib_master_domain_sse710_integration_example_f0_host_exp     u_ib_apb_group0_ib_m (
  .a_data               (a_data_apb_group0_ib_int),
  .a_valid              (a_valid_apb_group0_ib_int),
  .a_ready              (a_ready_apb_group0_ib_int),
  .d_data               (d_data_apb_group0_ib_int),
  .d_valid              (d_valid_apb_group0_ib_int),
  .d_ready              (d_ready_apb_group0_ib_int),
  .w_data               (w_data_apb_group0_ib_int),
  .w_valid              (w_valid_apb_group0_ib_int),
  .w_ready              (w_ready_apb_group0_ib_int),
  .aid_itb_m            (aid_apb_group0_ib_apb_group0_apb_group0_s),
  .aaddr_itb_m          (aaddr_apb_group0_ib_apb_group0_apb_group0_s),
  .alen_itb_m           (alen_apb_group0_ib_apb_group0_apb_group0_s),
  .asize_itb_m          (asize_apb_group0_ib_apb_group0_apb_group0_s),
  .aburst_itb_m         (aburst_apb_group0_ib_apb_group0_apb_group0_s),
  .alock_itb_m          (alock_apb_group0_ib_apb_group0_apb_group0_s),
  .acache_itb_m         (acache_apb_group0_ib_apb_group0_apb_group0_s),
  .aprot_itb_m          (aprot_apb_group0_ib_apb_group0_apb_group0_s),
  .awrite_itb_m         (awrite_apb_group0_ib_apb_group0_apb_group0_s),
  .avalid_itb_m         (avalid_apb_group0_ib_apb_group0_apb_group0_s),
  .aregion_itb_m        (aregion_apb_group0_ib_apb_group0_apb_group0_s),
  .aready_itb_m         (aready_apb_group0_ib_apb_group0_apb_group0_s),
  .wdata_itb_m          (wdata_apb_group0_ib_apb_group0_apb_group0_s),
  .wstrb_itb_m          (wstrb_apb_group0_ib_apb_group0_apb_group0_s),
  .wlast_itb_m          (wlast_apb_group0_ib_apb_group0_apb_group0_s),
  .wvalid_itb_m         (wvalid_apb_group0_ib_apb_group0_apb_group0_s),
  .wready_itb_m         (wready_apb_group0_ib_apb_group0_apb_group0_s),
  .did_itb_m            (did_apb_group0_ib_apb_group0_apb_group0_s),
  .ddata_itb_m          (ddata_apb_group0_ib_apb_group0_apb_group0_s),
  .dresp_itb_m          (dresp_apb_group0_ib_apb_group0_apb_group0_s),
  .dlast_itb_m          (dlast_apb_group0_ib_apb_group0_apb_group0_s),
  .dbnr_itb_m           (dbnr_apb_group0_ib_apb_group0_apb_group0_s),
  .dvalid_itb_m         (dvalid_apb_group0_ib_apb_group0_apb_group0_s),
  .dready_itb_m         (dready_apb_group0_ib_apb_group0_apb_group0_s),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn)
);


nic400_ib_apb_group0_ib_slave_domain_sse710_integration_example_f0_host_exp     u_ib_apb_group0_ib_s (
  .a_data               (a_data_apb_group0_ib_int),
  .a_valid              (a_valid_apb_group0_ib_int),
  .a_ready              (a_ready_apb_group0_ib_int),
  .d_data               (d_data_apb_group0_ib_int),
  .d_valid              (d_valid_apb_group0_ib_int),
  .d_ready              (d_ready_apb_group0_ib_int),
  .w_data               (w_data_apb_group0_ib_int),
  .w_valid              (w_valid_apb_group0_ib_int),
  .w_ready              (w_ready_apb_group0_ib_int),
  .awid_axi4_s          (awid_bm1_apb_group0_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_bm1_apb_group0_ib_axi4_s),
  .awlen_axi4_s         (awlen_bm1_apb_group0_ib_axi4_s),
  .awsize_axi4_s        (awsize_bm1_apb_group0_ib_axi4_s),
  .awburst_axi4_s       (awburst_bm1_apb_group0_ib_axi4_s),
  .awlock_axi4_s        (awlock_bm1_apb_group0_ib_axi4_s),
  .awcache_axi4_s       (awcache_bm1_apb_group0_ib_axi4_s),
  .awprot_axi4_s        (awprot_bm1_apb_group0_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_bm1_apb_group0_ib_axi4_s),
  .awregion_axi4_s      (awregion_bm1_apb_group0_ib_axi4_s),
  .awready_axi4_s       (awready_bm1_apb_group0_ib_axi4_s),
  .wdata_axi4_s         (wdata_bm1_apb_group0_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_bm1_apb_group0_ib_axi4_s),
  .wlast_axi4_s         (wlast_bm1_apb_group0_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_bm1_apb_group0_ib_axi4_s),
  .wready_axi4_s        (wready_bm1_apb_group0_ib_axi4_s),
  .bid_axi4_s           (bid_bm1_apb_group0_ib_axi4_s),
  .bresp_axi4_s         (bresp_bm1_apb_group0_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_bm1_apb_group0_ib_axi4_s),
  .bready_axi4_s        (bready_bm1_apb_group0_ib_axi4_s),
  .arid_axi4_s          (arid_bm1_apb_group0_ib_axi4_s),
  .araddr_axi4_s        (araddr_bm1_apb_group0_ib_axi4_s),
  .arlen_axi4_s         (arlen_bm1_apb_group0_ib_axi4_s),
  .arsize_axi4_s        (arsize_bm1_apb_group0_ib_axi4_s),
  .arburst_axi4_s       (arburst_bm1_apb_group0_ib_axi4_s),
  .arlock_axi4_s        (arlock_bm1_apb_group0_ib_axi4_s),
  .arcache_axi4_s       (arcache_bm1_apb_group0_ib_axi4_s),
  .arprot_axi4_s        (arprot_bm1_apb_group0_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_bm1_apb_group0_ib_axi4_s),
  .arregion_axi4_s      (arregion_bm1_apb_group0_ib_axi4_s),
  .arready_axi4_s       (arready_bm1_apb_group0_ib_axi4_s),
  .rid_axi4_s           (rid_bm1_apb_group0_ib_axi4_s),
  .rdata_axi4_s         (rdata_bm1_apb_group0_ib_axi4_s),
  .rresp_axi4_s         (rresp_bm1_apb_group0_ib_axi4_s),
  .rlast_axi4_s         (rlast_bm1_apb_group0_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_bm1_apb_group0_ib_axi4_s),
  .rready_axi4_s        (rready_bm1_apb_group0_ib_axi4_s),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn)
);


nic400_ib_gpio_ahb_m_ib_slave_domain_sse710_integration_example_f0_host_exp     u_ib_gpio_ahb_m_ib_s (
  .awid_axi4_s          (awid_bm1_gpio_ahb_m_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_bm1_gpio_ahb_m_ib_axi4_s),
  .awlen_axi4_s         (awlen_bm1_gpio_ahb_m_ib_axi4_s),
  .awsize_axi4_s        (awsize_bm1_gpio_ahb_m_ib_axi4_s),
  .awburst_axi4_s       (awburst_bm1_gpio_ahb_m_ib_axi4_s),
  .awlock_axi4_s        (awlock_bm1_gpio_ahb_m_ib_axi4_s),
  .awcache_axi4_s       (awcache_bm1_gpio_ahb_m_ib_axi4_s),
  .awprot_axi4_s        (awprot_bm1_gpio_ahb_m_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_bm1_gpio_ahb_m_ib_axi4_s),
  .awregion_axi4_s      (awregion_bm1_gpio_ahb_m_ib_axi4_s),
  .awready_axi4_s       (awready_bm1_gpio_ahb_m_ib_axi4_s),
  .wdata_axi4_s         (wdata_bm1_gpio_ahb_m_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_bm1_gpio_ahb_m_ib_axi4_s),
  .wlast_axi4_s         (wlast_bm1_gpio_ahb_m_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_bm1_gpio_ahb_m_ib_axi4_s),
  .wready_axi4_s        (wready_bm1_gpio_ahb_m_ib_axi4_s),
  .bid_axi4_s           (bid_bm1_gpio_ahb_m_ib_axi4_s),
  .bresp_axi4_s         (bresp_bm1_gpio_ahb_m_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_bm1_gpio_ahb_m_ib_axi4_s),
  .bready_axi4_s        (bready_bm1_gpio_ahb_m_ib_axi4_s),
  .arid_axi4_s          (arid_bm1_gpio_ahb_m_ib_axi4_s),
  .araddr_axi4_s        (araddr_bm1_gpio_ahb_m_ib_axi4_s),
  .arlen_axi4_s         (arlen_bm1_gpio_ahb_m_ib_axi4_s),
  .arsize_axi4_s        (arsize_bm1_gpio_ahb_m_ib_axi4_s),
  .arburst_axi4_s       (arburst_bm1_gpio_ahb_m_ib_axi4_s),
  .arlock_axi4_s        (arlock_bm1_gpio_ahb_m_ib_axi4_s),
  .arcache_axi4_s       (arcache_bm1_gpio_ahb_m_ib_axi4_s),
  .arprot_axi4_s        (arprot_bm1_gpio_ahb_m_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_bm1_gpio_ahb_m_ib_axi4_s),
  .arregion_axi4_s      (arregion_bm1_gpio_ahb_m_ib_axi4_s),
  .arready_axi4_s       (arready_bm1_gpio_ahb_m_ib_axi4_s),
  .rid_axi4_s           (rid_bm1_gpio_ahb_m_ib_axi4_s),
  .rdata_axi4_s         (rdata_bm1_gpio_ahb_m_ib_axi4_s),
  .rresp_axi4_s         (rresp_bm1_gpio_ahb_m_ib_axi4_s),
  .rlast_axi4_s         (rlast_bm1_gpio_ahb_m_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_bm1_gpio_ahb_m_ib_axi4_s),
  .rready_axi4_s        (rready_bm1_gpio_ahb_m_ib_axi4_s),
  .aclk_s               (aclkoutclk),
  .aresetn_s            (aclkoutresetn),
  .a_data_async         (a_data_gpio_ahb_m_ib_int_async),
  .a_rpntr_gry_async    (a_rpntr_gry_gpio_ahb_m_ib_int_async),
  .a_rpntr_bin          (a_rpntr_bin_gpio_ahb_m_ib_int_async),
  .a_wpntr_gry_async    (a_wpntr_gry_gpio_ahb_m_ib_int_async),
  .d_data_async         (d_data_gpio_ahb_m_ib_int_async),
  .d_rpntr_gry_async    (d_rpntr_gry_gpio_ahb_m_ib_int_async),
  .d_rpntr_bin          (d_rpntr_bin_gpio_ahb_m_ib_int_async),
  .d_wpntr_gry_async    (d_wpntr_gry_gpio_ahb_m_ib_int_async),
  .w_data_async         (w_data_gpio_ahb_m_ib_int_async),
  .w_rpntr_gry_async    (w_rpntr_gry_gpio_ahb_m_ib_int_async),
  .w_rpntr_bin          (w_rpntr_bin_gpio_ahb_m_ib_int_async),
  .w_wpntr_gry_async    (w_wpntr_gry_gpio_ahb_m_ib_int_async)
);


nic400_ib_ib2_master_domain_sse710_integration_example_f0_host_exp     u_ib_ib2_m (
  .awid_ib2_m           (awid_ib2_bm0_axi_s_0),
  .awaddr_ib2_m         (awaddr_ib2_bm0_axi_s_0),
  .awlen_ib2_m          (awlen_ib2_bm0_axi_s_0),
  .awsize_ib2_m         (awsize_ib2_bm0_axi_s_0),
  .awburst_ib2_m        (awburst_ib2_bm0_axi_s_0),
  .awlock_ib2_m         (awlock_ib2_bm0_axi_s_0),
  .awcache_ib2_m        (awcache_ib2_bm0_axi_s_0),
  .awprot_ib2_m         (awprot_ib2_bm0_axi_s_0),
  .awvalid_ib2_m        (awvalid_ib2_bm0_axi_s_0),
  .awvalid_vect_ib2_m   (awvalid_vect_ib2_bm0_axi_s_0),
  .awregion_ib2_m       (awregion_ib2_bm0_axi_s_0),
  .awready_ib2_m        (awready_ib2_bm0_axi_s_0),
  .wdata_ib2_m          (wdata_ib2_bm0_axi_s_0),
  .wstrb_ib2_m          (wstrb_ib2_bm0_axi_s_0),
  .wlast_ib2_m          (wlast_ib2_bm0_axi_s_0),
  .wvalid_ib2_m         (wvalid_ib2_bm0_axi_s_0),
  .wready_ib2_m         (wready_ib2_bm0_axi_s_0),
  .bid_ib2_m            (bid_ib2_bm0_axi_s_0),
  .bresp_ib2_m          (bresp_ib2_bm0_axi_s_0),
  .bvalid_ib2_m         (bvalid_ib2_bm0_axi_s_0),
  .bready_ib2_m         (bready_ib2_bm0_axi_s_0),
  .arid_ib2_m           (arid_ib2_bm0_axi_s_0),
  .araddr_ib2_m         (araddr_ib2_bm0_axi_s_0),
  .arlen_ib2_m          (arlen_ib2_bm0_axi_s_0),
  .arsize_ib2_m         (arsize_ib2_bm0_axi_s_0),
  .arburst_ib2_m        (arburst_ib2_bm0_axi_s_0),
  .arlock_ib2_m         (arlock_ib2_bm0_axi_s_0),
  .arcache_ib2_m        (arcache_ib2_bm0_axi_s_0),
  .arprot_ib2_m         (arprot_ib2_bm0_axi_s_0),
  .arvalid_ib2_m        (arvalid_ib2_bm0_axi_s_0),
  .arvalid_vect_ib2_m   (arvalid_vect_ib2_bm0_axi_s_0),
  .arregion_ib2_m       (arregion_ib2_bm0_axi_s_0),
  .arready_ib2_m        (arready_ib2_bm0_axi_s_0),
  .rid_ib2_m            (rid_ib2_bm0_axi_s_0),
  .rdata_ib2_m          (rdata_ib2_bm0_axi_s_0),
  .rresp_ib2_m          (rresp_ib2_bm0_axi_s_0),
  .rlast_ib2_m          (rlast_ib2_bm0_axi_s_0),
  .rvalid_ib2_m         (rvalid_ib2_bm0_axi_s_0),
  .rready_ib2_m         (rready_ib2_bm0_axi_s_0),
  .awqv_ib2_m           (awqv_ib2_bm0_axi_s_0),
  .arqv_ib2_m           (arqv_ib2_bm0_axi_s_0),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn),
  .aw_data              (aw_data_ib2_int),
  .aw_valid             (aw_valid_ib2_int),
  .aw_ready             (aw_ready_ib2_int),
  .b_data               (b_data_ib2_int),
  .b_valid              (b_valid_ib2_int),
  .b_ready              (b_ready_ib2_int),
  .ar_data              (ar_data_ib2_int),
  .ar_valid             (ar_valid_ib2_int),
  .ar_ready             (ar_ready_ib2_int),
  .r_data               (r_data_ib2_int),
  .r_valid              (r_valid_ib2_int),
  .r_ready              (r_ready_ib2_int),
  .w_data               (w_data_ib2_int),
  .w_valid              (w_valid_ib2_int),
  .w_ready              (w_ready_ib2_int)
);


nic400_ib_ib2_slave_domain_sse710_integration_example_f0_host_exp     u_ib_ib2_s (
  .aw_data              (aw_data_ib2_int),
  .aw_valid             (aw_valid_ib2_int),
  .aw_ready             (aw_ready_ib2_int),
  .b_data               (b_data_ib2_int),
  .b_valid              (b_valid_ib2_int),
  .b_ready              (b_ready_ib2_int),
  .ar_data              (ar_data_ib2_int),
  .ar_valid             (ar_valid_ib2_int),
  .ar_ready             (ar_ready_ib2_int),
  .r_data               (r_data_ib2_int),
  .r_valid              (r_valid_ib2_int),
  .r_ready              (r_ready_ib2_int),
  .w_data               (w_data_ib2_int),
  .w_valid              (w_valid_ib2_int),
  .w_ready              (w_ready_ib2_int),
  .awid_ib2_s           (awid_bm1_ib2_ib2_s),
  .awaddr_ib2_s         (awaddr_bm1_ib2_ib2_s),
  .awlen_ib2_s          (awlen_bm1_ib2_ib2_s),
  .awsize_ib2_s         (awsize_bm1_ib2_ib2_s),
  .awburst_ib2_s        (awburst_bm1_ib2_ib2_s),
  .awlock_ib2_s         (awlock_bm1_ib2_ib2_s),
  .awcache_ib2_s        (awcache_bm1_ib2_ib2_s),
  .awprot_ib2_s         (awprot_bm1_ib2_ib2_s),
  .awvalid_ib2_s        (awvalid_bm1_ib2_ib2_s),
  .awvalid_vect_ib2_s   (awvalid_vect_bm1_ib2_ib2_s),
  .awregion_ib2_s       (awregion_bm1_ib2_ib2_s),
  .awready_ib2_s        (awready_bm1_ib2_ib2_s),
  .wdata_ib2_s          (wdata_bm1_ib2_ib2_s),
  .wstrb_ib2_s          (wstrb_bm1_ib2_ib2_s),
  .wlast_ib2_s          (wlast_bm1_ib2_ib2_s),
  .wvalid_ib2_s         (wvalid_bm1_ib2_ib2_s),
  .wready_ib2_s         (wready_bm1_ib2_ib2_s),
  .bid_ib2_s            (bid_bm1_ib2_ib2_s),
  .bresp_ib2_s          (bresp_bm1_ib2_ib2_s),
  .bvalid_ib2_s         (bvalid_bm1_ib2_ib2_s),
  .bready_ib2_s         (bready_bm1_ib2_ib2_s),
  .arid_ib2_s           (arid_bm1_ib2_ib2_s),
  .araddr_ib2_s         (araddr_bm1_ib2_ib2_s),
  .arlen_ib2_s          (arlen_bm1_ib2_ib2_s),
  .arsize_ib2_s         (arsize_bm1_ib2_ib2_s),
  .arburst_ib2_s        (arburst_bm1_ib2_ib2_s),
  .arlock_ib2_s         (arlock_bm1_ib2_ib2_s),
  .arcache_ib2_s        (arcache_bm1_ib2_ib2_s),
  .arprot_ib2_s         (arprot_bm1_ib2_ib2_s),
  .arvalid_ib2_s        (arvalid_bm1_ib2_ib2_s),
  .arvalid_vect_ib2_s   (arvalid_vect_bm1_ib2_ib2_s),
  .arregion_ib2_s       (arregion_bm1_ib2_ib2_s),
  .arready_ib2_s        (arready_bm1_ib2_ib2_s),
  .rid_ib2_s            (rid_bm1_ib2_ib2_s),
  .rdata_ib2_s          (rdata_bm1_ib2_ib2_s),
  .rresp_ib2_s          (rresp_bm1_ib2_ib2_s),
  .rlast_ib2_s          (rlast_bm1_ib2_ib2_s),
  .rvalid_ib2_s         (rvalid_bm1_ib2_ib2_s),
  .rready_ib2_s         (rready_bm1_ib2_ib2_s),
  .awqv_ib2_s           (awqv_bm1_ib2_ib2_s),
  .arqv_ib2_s           (arqv_bm1_ib2_ib2_s),
  .aclk                 (aclkoutclk),
  .aresetn              (aclkoutresetn)
);



endmodule
