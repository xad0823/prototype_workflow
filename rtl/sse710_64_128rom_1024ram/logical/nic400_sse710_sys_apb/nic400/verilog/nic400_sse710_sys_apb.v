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




module nic400_sse710_sys_apb (
  

  csysreq_cd_a,
  csysack_cd_a,
  cactive_cd_a,
  

  paddr_es0h_mhu0,
  pselx_es0h_mhu0,
  penable_es0h_mhu0,
  pwrite_es0h_mhu0,
  prdata_es0h_mhu0,
  pwdata_es0h_mhu0,
  pprot_es0h_mhu0,
  pstrb_es0h_mhu0,
  pready_es0h_mhu0,
  pslverr_es0h_mhu0,
  

  paddr_es0h_mhu1,
  pselx_es0h_mhu1,
  penable_es0h_mhu1,
  pwrite_es0h_mhu1,
  prdata_es0h_mhu1,
  pwdata_es0h_mhu1,
  pprot_es0h_mhu1,
  pstrb_es0h_mhu1,
  pready_es0h_mhu1,
  pslverr_es0h_mhu1,
  

  paddr_es1h_mhu0,
  pselx_es1h_mhu0,
  penable_es1h_mhu0,
  pwrite_es1h_mhu0,
  prdata_es1h_mhu0,
  pwdata_es1h_mhu0,
  pprot_es1h_mhu0,
  pstrb_es1h_mhu0,
  pready_es1h_mhu0,
  pslverr_es1h_mhu0,
  

  paddr_es1h_mhu1,
  pselx_es1h_mhu1,
  penable_es1h_mhu1,
  pwrite_es1h_mhu1,
  prdata_es1h_mhu1,
  pwdata_es1h_mhu1,
  pprot_es1h_mhu1,
  pstrb_es1h_mhu1,
  pready_es1h_mhu1,
  pslverr_es1h_mhu1,
  

  awid_gic_axim,
  awaddr_gic_axim,
  awlen_gic_axim,
  awsize_gic_axim,
  awburst_gic_axim,
  awlock_gic_axim,
  awcache_gic_axim,
  awprot_gic_axim,
  awqos_gic_axim,
  awvalid_gic_axim,
  awready_gic_axim,
  wdata_gic_axim,
  wstrb_gic_axim,
  wlast_gic_axim,
  wvalid_gic_axim,
  wready_gic_axim,
  bid_gic_axim,
  bresp_gic_axim,
  bvalid_gic_axim,
  bready_gic_axim,
  arid_gic_axim,
  araddr_gic_axim,
  arlen_gic_axim,
  arsize_gic_axim,
  arburst_gic_axim,
  arlock_gic_axim,
  arcache_gic_axim,
  arprot_gic_axim,
  arqos_gic_axim,
  arvalid_gic_axim,
  arready_gic_axim,
  rid_gic_axim,
  rdata_gic_axim,
  rresp_gic_axim,
  rlast_gic_axim,
  rvalid_gic_axim,
  rready_gic_axim,
  awuser_gic_axim,
  aruser_gic_axim,
  

  haddr_gpvmain_ahb,
  hburst_gpvmain_ahb,
  hprot_gpvmain_ahb,
  hsize_gpvmain_ahb,
  htrans_gpvmain_ahb,
  hwdata_gpvmain_ahb,
  hwrite_gpvmain_ahb,
  hrdata_gpvmain_ahb,
  hreadyout_gpvmain_ahb,
  hresp_gpvmain_ahb,
  hselx_gpvmain_ahb,
  hready_gpvmain_ahb,
  

  paddr_hes0_mhu0,
  pselx_hes0_mhu0,
  penable_hes0_mhu0,
  pwrite_hes0_mhu0,
  prdata_hes0_mhu0,
  pwdata_hes0_mhu0,
  pprot_hes0_mhu0,
  pstrb_hes0_mhu0,
  pready_hes0_mhu0,
  pslverr_hes0_mhu0,
  

  paddr_hes0_mhu1,
  pselx_hes0_mhu1,
  penable_hes0_mhu1,
  pwrite_hes0_mhu1,
  prdata_hes0_mhu1,
  pwdata_hes0_mhu1,
  pprot_hes0_mhu1,
  pstrb_hes0_mhu1,
  pready_hes0_mhu1,
  pslverr_hes0_mhu1,
  

  paddr_hes1_mhu0,
  pselx_hes1_mhu0,
  penable_hes1_mhu0,
  pwrite_hes1_mhu0,
  prdata_hes1_mhu0,
  pwdata_hes1_mhu0,
  pprot_hes1_mhu0,
  pstrb_hes1_mhu0,
  pready_hes1_mhu0,
  pslverr_hes1_mhu0,
  

  paddr_hes1_mhu1,
  pselx_hes1_mhu1,
  penable_hes1_mhu1,
  pwrite_hes1_mhu1,
  prdata_hes1_mhu1,
  pwdata_hes1_mhu1,
  pprot_hes1_mhu1,
  pstrb_hes1_mhu1,
  pready_hes1_mhu1,
  pslverr_hes1_mhu1,
  

  paddr_hostsysdbg_apb,
  pselx_hostsysdbg_apb,
  penable_hostsysdbg_apb,
  pwrite_hostsysdbg_apb,
  prdata_hostsysdbg_apb,
  pwdata_hostsysdbg_apb,
  pprot_hostsysdbg_apb,
  pstrb_hostsysdbg_apb,
  pready_hostsysdbg_apb,
  pslverr_hostsysdbg_apb,
  

  paddr_hse_mhu0,
  pselx_hse_mhu0,
  penable_hse_mhu0,
  pwrite_hse_mhu0,
  prdata_hse_mhu0,
  pwdata_hse_mhu0,
  pprot_hse_mhu0,
  pstrb_hse_mhu0,
  pready_hse_mhu0,
  pslverr_hse_mhu0,
  

  paddr_hse_mhu1,
  pselx_hse_mhu1,
  penable_hse_mhu1,
  pwrite_hse_mhu1,
  prdata_hse_mhu1,
  pwdata_hse_mhu1,
  pprot_hse_mhu1,
  pstrb_hse_mhu1,
  pready_hse_mhu1,
  pslverr_hse_mhu1,
  

  paddr_sdc600_apb,
  pselx_sdc600_apb,
  penable_sdc600_apb,
  pwrite_sdc600_apb,
  prdata_sdc600_apb,
  pwdata_sdc600_apb,
  pprot_sdc600_apb,
  pstrb_sdc600_apb,
  pready_sdc600_apb,
  pslverr_sdc600_apb,
  

  paddr_seh_mhu0,
  pselx_seh_mhu0,
  penable_seh_mhu0,
  pwrite_seh_mhu0,
  prdata_seh_mhu0,
  pwdata_seh_mhu0,
  pprot_seh_mhu0,
  pstrb_seh_mhu0,
  pready_seh_mhu0,
  pslverr_seh_mhu0,
  

  paddr_seh_mhu1,
  pselx_seh_mhu1,
  penable_seh_mhu1,
  pwrite_seh_mhu1,
  prdata_seh_mhu1,
  pwdata_seh_mhu1,
  pprot_seh_mhu1,
  pstrb_seh_mhu1,
  pready_seh_mhu1,
  pslverr_seh_mhu1,
  

  awid_stm_axim,
  awaddr_stm_axim,
  awlen_stm_axim,
  awsize_stm_axim,
  awburst_stm_axim,
  awlock_stm_axim,
  awcache_stm_axim,
  awprot_stm_axim,
  awvalid_stm_axim,
  awready_stm_axim,
  wdata_stm_axim,
  wstrb_stm_axim,
  wlast_stm_axim,
  wvalid_stm_axim,
  wready_stm_axim,
  bid_stm_axim,
  bresp_stm_axim,
  bvalid_stm_axim,
  bready_stm_axim,
  arid_stm_axim,
  araddr_stm_axim,
  arlen_stm_axim,
  arsize_stm_axim,
  arburst_stm_axim,
  arlock_stm_axim,
  arcache_stm_axim,
  arprot_stm_axim,
  arvalid_stm_axim,
  arready_stm_axim,
  rid_stm_axim,
  rdata_stm_axim,
  rresp_stm_axim,
  rlast_stm_axim,
  rvalid_stm_axim,
  rready_stm_axim,
  awuser_stm_axim,
  aruser_stm_axim,
  

  awid_sysperi_axis,
  awaddr_sysperi_axis,
  awlen_sysperi_axis,
  awsize_sysperi_axis,
  awburst_sysperi_axis,
  awlock_sysperi_axis,
  awcache_sysperi_axis,
  awprot_sysperi_axis,
  awqos_sysperi_axis,
  awvalid_sysperi_axis,
  awready_sysperi_axis,
  wdata_sysperi_axis,
  wstrb_sysperi_axis,
  wlast_sysperi_axis,
  wvalid_sysperi_axis,
  wready_sysperi_axis,
  bid_sysperi_axis,
  bresp_sysperi_axis,
  bvalid_sysperi_axis,
  bready_sysperi_axis,
  arid_sysperi_axis,
  araddr_sysperi_axis,
  arlen_sysperi_axis,
  arsize_sysperi_axis,
  arburst_sysperi_axis,
  arlock_sysperi_axis,
  arcache_sysperi_axis,
  arprot_sysperi_axis,
  arqos_sysperi_axis,
  arvalid_sysperi_axis,
  arready_sysperi_axis,
  rid_sysperi_axis,
  rdata_sysperi_axis,
  rresp_sysperi_axis,
  rlast_sysperi_axis,
  rvalid_sysperi_axis,
  rready_sysperi_axis,
  awuser_sysperi_axis,
  aruser_sysperi_axis,
  

  csysreq_cd_ctrl,
  csysack_cd_ctrl,
  cactive_cd_ctrl,
  

  paddr_ppu_cpu_apb,
  pselx_ppu_cpu_apb,
  penable_ppu_cpu_apb,
  pwrite_ppu_cpu_apb,
  prdata_ppu_cpu_apb,
  pwdata_ppu_cpu_apb,
  pprot_ppu_cpu_apb,
  pstrb_ppu_cpu_apb,
  pready_ppu_cpu_apb,
  pslverr_ppu_cpu_apb,


  aclk,
  aclken,
  aresetn,
  ctrlclk,
  ctrlclken,
  ctrlresetn

);






input         csysreq_cd_a;
output        csysack_cd_a;
output        cactive_cd_a;


output [31:0] paddr_es0h_mhu0;
output        pselx_es0h_mhu0;
output        penable_es0h_mhu0;
output        pwrite_es0h_mhu0;
input  [31:0] prdata_es0h_mhu0;
output [31:0] pwdata_es0h_mhu0;
output [2:0]  pprot_es0h_mhu0;
output [3:0]  pstrb_es0h_mhu0;
input         pready_es0h_mhu0;
input         pslverr_es0h_mhu0;


output [31:0] paddr_es0h_mhu1;
output        pselx_es0h_mhu1;
output        penable_es0h_mhu1;
output        pwrite_es0h_mhu1;
input  [31:0] prdata_es0h_mhu1;
output [31:0] pwdata_es0h_mhu1;
output [2:0]  pprot_es0h_mhu1;
output [3:0]  pstrb_es0h_mhu1;
input         pready_es0h_mhu1;
input         pslverr_es0h_mhu1;


output [31:0] paddr_es1h_mhu0;
output        pselx_es1h_mhu0;
output        penable_es1h_mhu0;
output        pwrite_es1h_mhu0;
input  [31:0] prdata_es1h_mhu0;
output [31:0] pwdata_es1h_mhu0;
output [2:0]  pprot_es1h_mhu0;
output [3:0]  pstrb_es1h_mhu0;
input         pready_es1h_mhu0;
input         pslverr_es1h_mhu0;


output [31:0] paddr_es1h_mhu1;
output        pselx_es1h_mhu1;
output        penable_es1h_mhu1;
output        pwrite_es1h_mhu1;
input  [31:0] prdata_es1h_mhu1;
output [31:0] pwdata_es1h_mhu1;
output [2:0]  pprot_es1h_mhu1;
output [3:0]  pstrb_es1h_mhu1;
input         pready_es1h_mhu1;
input         pslverr_es1h_mhu1;


output [11:0] awid_gic_axim;
output [31:0] awaddr_gic_axim;
output [7:0]  awlen_gic_axim;
output [2:0]  awsize_gic_axim;
output [1:0]  awburst_gic_axim;
output        awlock_gic_axim;
output [3:0]  awcache_gic_axim;
output [2:0]  awprot_gic_axim;
output [3:0]  awqos_gic_axim;
output        awvalid_gic_axim;
input         awready_gic_axim;
output [31:0] wdata_gic_axim;
output [3:0]  wstrb_gic_axim;
output        wlast_gic_axim;
output        wvalid_gic_axim;
input         wready_gic_axim;
input  [11:0] bid_gic_axim;
input  [1:0]  bresp_gic_axim;
input         bvalid_gic_axim;
output        bready_gic_axim;
output [11:0] arid_gic_axim;
output [31:0] araddr_gic_axim;
output [7:0]  arlen_gic_axim;
output [2:0]  arsize_gic_axim;
output [1:0]  arburst_gic_axim;
output        arlock_gic_axim;
output [3:0]  arcache_gic_axim;
output [2:0]  arprot_gic_axim;
output [3:0]  arqos_gic_axim;
output        arvalid_gic_axim;
input         arready_gic_axim;
input  [11:0] rid_gic_axim;
input  [31:0] rdata_gic_axim;
input  [1:0]  rresp_gic_axim;
input         rlast_gic_axim;
input         rvalid_gic_axim;
output        rready_gic_axim;
output [9:0]  awuser_gic_axim;
output [9:0]  aruser_gic_axim;


output [31:0] haddr_gpvmain_ahb;
output [2:0]  hburst_gpvmain_ahb;
output [3:0]  hprot_gpvmain_ahb;
output [2:0]  hsize_gpvmain_ahb;
output [1:0]  htrans_gpvmain_ahb;
output [31:0] hwdata_gpvmain_ahb;
output        hwrite_gpvmain_ahb;
input  [31:0] hrdata_gpvmain_ahb;
input         hreadyout_gpvmain_ahb;
input         hresp_gpvmain_ahb;
output        hselx_gpvmain_ahb;
output        hready_gpvmain_ahb;


output [31:0] paddr_hes0_mhu0;
output        pselx_hes0_mhu0;
output        penable_hes0_mhu0;
output        pwrite_hes0_mhu0;
input  [31:0] prdata_hes0_mhu0;
output [31:0] pwdata_hes0_mhu0;
output [2:0]  pprot_hes0_mhu0;
output [3:0]  pstrb_hes0_mhu0;
input         pready_hes0_mhu0;
input         pslverr_hes0_mhu0;


output [31:0] paddr_hes0_mhu1;
output        pselx_hes0_mhu1;
output        penable_hes0_mhu1;
output        pwrite_hes0_mhu1;
input  [31:0] prdata_hes0_mhu1;
output [31:0] pwdata_hes0_mhu1;
output [2:0]  pprot_hes0_mhu1;
output [3:0]  pstrb_hes0_mhu1;
input         pready_hes0_mhu1;
input         pslverr_hes0_mhu1;


output [31:0] paddr_hes1_mhu0;
output        pselx_hes1_mhu0;
output        penable_hes1_mhu0;
output        pwrite_hes1_mhu0;
input  [31:0] prdata_hes1_mhu0;
output [31:0] pwdata_hes1_mhu0;
output [2:0]  pprot_hes1_mhu0;
output [3:0]  pstrb_hes1_mhu0;
input         pready_hes1_mhu0;
input         pslverr_hes1_mhu0;


output [31:0] paddr_hes1_mhu1;
output        pselx_hes1_mhu1;
output        penable_hes1_mhu1;
output        pwrite_hes1_mhu1;
input  [31:0] prdata_hes1_mhu1;
output [31:0] pwdata_hes1_mhu1;
output [2:0]  pprot_hes1_mhu1;
output [3:0]  pstrb_hes1_mhu1;
input         pready_hes1_mhu1;
input         pslverr_hes1_mhu1;


output [31:0] paddr_hostsysdbg_apb;
output        pselx_hostsysdbg_apb;
output        penable_hostsysdbg_apb;
output        pwrite_hostsysdbg_apb;
input  [31:0] prdata_hostsysdbg_apb;
output [31:0] pwdata_hostsysdbg_apb;
output [2:0]  pprot_hostsysdbg_apb;
output [3:0]  pstrb_hostsysdbg_apb;
input         pready_hostsysdbg_apb;
input         pslverr_hostsysdbg_apb;


output [31:0] paddr_hse_mhu0;
output        pselx_hse_mhu0;
output        penable_hse_mhu0;
output        pwrite_hse_mhu0;
input  [31:0] prdata_hse_mhu0;
output [31:0] pwdata_hse_mhu0;
output [2:0]  pprot_hse_mhu0;
output [3:0]  pstrb_hse_mhu0;
input         pready_hse_mhu0;
input         pslverr_hse_mhu0;


output [31:0] paddr_hse_mhu1;
output        pselx_hse_mhu1;
output        penable_hse_mhu1;
output        pwrite_hse_mhu1;
input  [31:0] prdata_hse_mhu1;
output [31:0] pwdata_hse_mhu1;
output [2:0]  pprot_hse_mhu1;
output [3:0]  pstrb_hse_mhu1;
input         pready_hse_mhu1;
input         pslverr_hse_mhu1;


output [31:0] paddr_sdc600_apb;
output        pselx_sdc600_apb;
output        penable_sdc600_apb;
output        pwrite_sdc600_apb;
input  [31:0] prdata_sdc600_apb;
output [31:0] pwdata_sdc600_apb;
output [2:0]  pprot_sdc600_apb;
output [3:0]  pstrb_sdc600_apb;
input         pready_sdc600_apb;
input         pslverr_sdc600_apb;


output [31:0] paddr_seh_mhu0;
output        pselx_seh_mhu0;
output        penable_seh_mhu0;
output        pwrite_seh_mhu0;
input  [31:0] prdata_seh_mhu0;
output [31:0] pwdata_seh_mhu0;
output [2:0]  pprot_seh_mhu0;
output [3:0]  pstrb_seh_mhu0;
input         pready_seh_mhu0;
input         pslverr_seh_mhu0;


output [31:0] paddr_seh_mhu1;
output        pselx_seh_mhu1;
output        penable_seh_mhu1;
output        pwrite_seh_mhu1;
input  [31:0] prdata_seh_mhu1;
output [31:0] pwdata_seh_mhu1;
output [2:0]  pprot_seh_mhu1;
output [3:0]  pstrb_seh_mhu1;
input         pready_seh_mhu1;
input         pslverr_seh_mhu1;


output [11:0] awid_stm_axim;
output [31:0] awaddr_stm_axim;
output [7:0]  awlen_stm_axim;
output [2:0]  awsize_stm_axim;
output [1:0]  awburst_stm_axim;
output        awlock_stm_axim;
output [3:0]  awcache_stm_axim;
output [2:0]  awprot_stm_axim;
output        awvalid_stm_axim;
input         awready_stm_axim;
output [63:0] wdata_stm_axim;
output [7:0]  wstrb_stm_axim;
output        wlast_stm_axim;
output        wvalid_stm_axim;
input         wready_stm_axim;
input  [11:0] bid_stm_axim;
input  [1:0]  bresp_stm_axim;
input         bvalid_stm_axim;
output        bready_stm_axim;
output [11:0] arid_stm_axim;
output [31:0] araddr_stm_axim;
output [7:0]  arlen_stm_axim;
output [2:0]  arsize_stm_axim;
output [1:0]  arburst_stm_axim;
output        arlock_stm_axim;
output [3:0]  arcache_stm_axim;
output [2:0]  arprot_stm_axim;
output        arvalid_stm_axim;
input         arready_stm_axim;
input  [11:0] rid_stm_axim;
input  [63:0] rdata_stm_axim;
input  [1:0]  rresp_stm_axim;
input         rlast_stm_axim;
input         rvalid_stm_axim;
output        rready_stm_axim;
output [9:0]  awuser_stm_axim;
output [9:0]  aruser_stm_axim;


input  [11:0] awid_sysperi_axis;
input  [31:0] awaddr_sysperi_axis;
input  [7:0]  awlen_sysperi_axis;
input  [2:0]  awsize_sysperi_axis;
input  [1:0]  awburst_sysperi_axis;
input         awlock_sysperi_axis;
input  [3:0]  awcache_sysperi_axis;
input  [2:0]  awprot_sysperi_axis;
input  [3:0]  awqos_sysperi_axis;
input         awvalid_sysperi_axis;
output        awready_sysperi_axis;
input  [31:0] wdata_sysperi_axis;
input  [3:0]  wstrb_sysperi_axis;
input         wlast_sysperi_axis;
input         wvalid_sysperi_axis;
output        wready_sysperi_axis;
output [11:0] bid_sysperi_axis;
output [1:0]  bresp_sysperi_axis;
output        bvalid_sysperi_axis;
input         bready_sysperi_axis;
input  [11:0] arid_sysperi_axis;
input  [31:0] araddr_sysperi_axis;
input  [7:0]  arlen_sysperi_axis;
input  [2:0]  arsize_sysperi_axis;
input  [1:0]  arburst_sysperi_axis;
input         arlock_sysperi_axis;
input  [3:0]  arcache_sysperi_axis;
input  [2:0]  arprot_sysperi_axis;
input  [3:0]  arqos_sysperi_axis;
input         arvalid_sysperi_axis;
output        arready_sysperi_axis;
output [11:0] rid_sysperi_axis;
output [31:0] rdata_sysperi_axis;
output [1:0]  rresp_sysperi_axis;
output        rlast_sysperi_axis;
output        rvalid_sysperi_axis;
input         rready_sysperi_axis;
input  [9:0]  awuser_sysperi_axis;
input  [9:0]  aruser_sysperi_axis;


input         csysreq_cd_ctrl;
output        csysack_cd_ctrl;
output        cactive_cd_ctrl;


output [31:0] paddr_ppu_cpu_apb;
output        pselx_ppu_cpu_apb;
output        penable_ppu_cpu_apb;
output        pwrite_ppu_cpu_apb;
input  [31:0] prdata_ppu_cpu_apb;
output [31:0] pwdata_ppu_cpu_apb;
output [2:0]  pprot_ppu_cpu_apb;
output [3:0]  pstrb_ppu_cpu_apb;
input         pready_ppu_cpu_apb;
input         pslverr_ppu_cpu_apb;


input         aclk;
input         aclken;
input         aresetn;
input         ctrlclk;
input         ctrlclken;
input         ctrlresetn;




wire   [31:0]  araddr_gic_axim;
wire   [31:0]  araddr_stm_axim;
wire   [1:0]   arburst_gic_axim;
wire   [1:0]   arburst_stm_axim;
wire   [3:0]   arcache_gic_axim;
wire   [3:0]   arcache_stm_axim;
wire   [11:0]  arid_gic_axim;
wire   [11:0]  arid_stm_axim;
wire   [7:0]   arlen_gic_axim;
wire   [7:0]   arlen_stm_axim;
wire           arlock_gic_axim;
wire           arlock_stm_axim;
wire   [2:0]   arprot_gic_axim;
wire   [2:0]   arprot_stm_axim;
wire   [3:0]   arqos_gic_axim;
wire           arready_sysperi_axis;
wire   [2:0]   arsize_gic_axim;
wire   [2:0]   arsize_stm_axim;
wire   [9:0]   aruser_gic_axim;
wire   [9:0]   aruser_stm_axim;
wire           arvalid_gic_axim;
wire           arvalid_stm_axim;
wire   [31:0]  awaddr_gic_axim;
wire   [31:0]  awaddr_stm_axim;
wire   [1:0]   awburst_gic_axim;
wire   [1:0]   awburst_stm_axim;
wire   [3:0]   awcache_gic_axim;
wire   [3:0]   awcache_stm_axim;
wire   [11:0]  awid_gic_axim;
wire   [11:0]  awid_stm_axim;
wire   [7:0]   awlen_gic_axim;
wire   [7:0]   awlen_stm_axim;
wire           awlock_gic_axim;
wire           awlock_stm_axim;
wire   [2:0]   awprot_gic_axim;
wire   [2:0]   awprot_stm_axim;
wire   [3:0]   awqos_gic_axim;
wire           awready_sysperi_axis;
wire   [2:0]   awsize_gic_axim;
wire   [2:0]   awsize_stm_axim;
wire   [9:0]   awuser_gic_axim;
wire   [9:0]   awuser_stm_axim;
wire           awvalid_gic_axim;
wire           awvalid_stm_axim;
wire   [11:0]  bid_sysperi_axis;
wire           bready_gic_axim;
wire           bready_stm_axim;
wire   [1:0]   bresp_sysperi_axis;
wire           bvalid_sysperi_axis;
wire           cactive_cd_a;
wire           cactive_cd_ctrl;
wire           csysack_cd_a;
wire           csysack_cd_ctrl;
wire   [31:0]  haddr_gpvmain_ahb;
wire   [2:0]   hburst_gpvmain_ahb;
wire   [3:0]   hprot_gpvmain_ahb;
wire           hready_gpvmain_ahb;
wire           hselx_gpvmain_ahb;
wire   [2:0]   hsize_gpvmain_ahb;
wire   [1:0]   htrans_gpvmain_ahb;
wire   [31:0]  hwdata_gpvmain_ahb;
wire           hwrite_gpvmain_ahb;
wire   [31:0]  paddr_es0h_mhu0;
wire   [31:0]  paddr_es0h_mhu1;
wire   [31:0]  paddr_es1h_mhu0;
wire   [31:0]  paddr_es1h_mhu1;
wire   [31:0]  paddr_hes0_mhu0;
wire   [31:0]  paddr_hes0_mhu1;
wire   [31:0]  paddr_hes1_mhu0;
wire   [31:0]  paddr_hes1_mhu1;
wire   [31:0]  paddr_hostsysdbg_apb;
wire   [31:0]  paddr_hse_mhu0;
wire   [31:0]  paddr_hse_mhu1;
wire   [31:0]  paddr_ppu_cpu_apb;
wire   [31:0]  paddr_sdc600_apb;
wire   [31:0]  paddr_seh_mhu0;
wire   [31:0]  paddr_seh_mhu1;
wire           penable_es0h_mhu0;
wire           penable_es0h_mhu1;
wire           penable_es1h_mhu0;
wire           penable_es1h_mhu1;
wire           penable_hes0_mhu0;
wire           penable_hes0_mhu1;
wire           penable_hes1_mhu0;
wire           penable_hes1_mhu1;
wire           penable_hostsysdbg_apb;
wire           penable_hse_mhu0;
wire           penable_hse_mhu1;
wire           penable_ppu_cpu_apb;
wire           penable_sdc600_apb;
wire           penable_seh_mhu0;
wire           penable_seh_mhu1;
wire   [2:0]   pprot_es0h_mhu0;
wire   [2:0]   pprot_es0h_mhu1;
wire   [2:0]   pprot_es1h_mhu0;
wire   [2:0]   pprot_es1h_mhu1;
wire   [2:0]   pprot_hes0_mhu0;
wire   [2:0]   pprot_hes0_mhu1;
wire   [2:0]   pprot_hes1_mhu0;
wire   [2:0]   pprot_hes1_mhu1;
wire   [2:0]   pprot_hostsysdbg_apb;
wire   [2:0]   pprot_hse_mhu0;
wire   [2:0]   pprot_hse_mhu1;
wire   [2:0]   pprot_ppu_cpu_apb;
wire   [2:0]   pprot_sdc600_apb;
wire   [2:0]   pprot_seh_mhu0;
wire   [2:0]   pprot_seh_mhu1;
wire           pselx_es0h_mhu0;
wire           pselx_es0h_mhu1;
wire           pselx_es1h_mhu0;
wire           pselx_es1h_mhu1;
wire           pselx_hes0_mhu0;
wire           pselx_hes0_mhu1;
wire           pselx_hes1_mhu0;
wire           pselx_hes1_mhu1;
wire           pselx_hostsysdbg_apb;
wire           pselx_hse_mhu0;
wire           pselx_hse_mhu1;
wire           pselx_ppu_cpu_apb;
wire           pselx_sdc600_apb;
wire           pselx_seh_mhu0;
wire           pselx_seh_mhu1;
wire   [3:0]   pstrb_es0h_mhu0;
wire   [3:0]   pstrb_es0h_mhu1;
wire   [3:0]   pstrb_es1h_mhu0;
wire   [3:0]   pstrb_es1h_mhu1;
wire   [3:0]   pstrb_hes0_mhu0;
wire   [3:0]   pstrb_hes0_mhu1;
wire   [3:0]   pstrb_hes1_mhu0;
wire   [3:0]   pstrb_hes1_mhu1;
wire   [3:0]   pstrb_hostsysdbg_apb;
wire   [3:0]   pstrb_hse_mhu0;
wire   [3:0]   pstrb_hse_mhu1;
wire   [3:0]   pstrb_ppu_cpu_apb;
wire   [3:0]   pstrb_sdc600_apb;
wire   [3:0]   pstrb_seh_mhu0;
wire   [3:0]   pstrb_seh_mhu1;
wire   [31:0]  pwdata_es0h_mhu0;
wire   [31:0]  pwdata_es0h_mhu1;
wire   [31:0]  pwdata_es1h_mhu0;
wire   [31:0]  pwdata_es1h_mhu1;
wire   [31:0]  pwdata_hes0_mhu0;
wire   [31:0]  pwdata_hes0_mhu1;
wire   [31:0]  pwdata_hes1_mhu0;
wire   [31:0]  pwdata_hes1_mhu1;
wire   [31:0]  pwdata_hostsysdbg_apb;
wire   [31:0]  pwdata_hse_mhu0;
wire   [31:0]  pwdata_hse_mhu1;
wire   [31:0]  pwdata_ppu_cpu_apb;
wire   [31:0]  pwdata_sdc600_apb;
wire   [31:0]  pwdata_seh_mhu0;
wire   [31:0]  pwdata_seh_mhu1;
wire           pwrite_es0h_mhu0;
wire           pwrite_es0h_mhu1;
wire           pwrite_es1h_mhu0;
wire           pwrite_es1h_mhu1;
wire           pwrite_hes0_mhu0;
wire           pwrite_hes0_mhu1;
wire           pwrite_hes1_mhu0;
wire           pwrite_hes1_mhu1;
wire           pwrite_hostsysdbg_apb;
wire           pwrite_hse_mhu0;
wire           pwrite_hse_mhu1;
wire           pwrite_ppu_cpu_apb;
wire           pwrite_sdc600_apb;
wire           pwrite_seh_mhu0;
wire           pwrite_seh_mhu1;
wire   [31:0]  rdata_sysperi_axis;
wire   [11:0]  rid_sysperi_axis;
wire           rlast_sysperi_axis;
wire           rready_gic_axim;
wire           rready_stm_axim;
wire   [1:0]   rresp_sysperi_axis;
wire           rvalid_sysperi_axis;
wire   [31:0]  wdata_gic_axim;
wire   [63:0]  wdata_stm_axim;
wire           wlast_gic_axim;
wire           wlast_stm_axim;
wire           wready_sysperi_axis;
wire   [3:0]   wstrb_gic_axim;
wire   [7:0]   wstrb_stm_axim;
wire           wvalid_gic_axim;
wire           wvalid_stm_axim;
wire   [69:0]  a_data_slave_9_ib_int_async;    
wire   [1:0]   a_wpntr_gry_slave_9_ib_int_async;    
wire           d_rpntr_bin_slave_9_ib_int_async;    
wire   [1:0]   d_rpntr_gry_slave_9_ib_int_async;    
wire           empty_slave_9_ib_int_async;    
wire   [36:0]  w_data_slave_9_ib_int_async;    
wire   [1:0]   w_wpntr_gry_slave_9_ib_int_async;    
wire           a_rpntr_bin_slave_9_ib_int_async;    
wire   [1:0]   a_rpntr_gry_slave_9_ib_int_async;    
wire   [47:0]  d_data_slave_9_ib_int_async;    
wire   [1:0]   d_wpntr_gry_slave_9_ib_int_async;    
wire           w_rpntr_bin_slave_9_ib_int_async;    
wire   [1:0]   w_rpntr_gry_slave_9_ib_int_async;    
wire           aclk;
wire           aclken;
wire   [31:0]  araddr_sysperi_axis;
wire   [1:0]   arburst_sysperi_axis;
wire   [3:0]   arcache_sysperi_axis;
wire           aresetn;
wire   [11:0]  arid_sysperi_axis;
wire   [7:0]   arlen_sysperi_axis;
wire           arlock_sysperi_axis;
wire   [2:0]   arprot_sysperi_axis;
wire   [3:0]   arqos_sysperi_axis;
wire           arready_gic_axim;
wire           arready_stm_axim;
wire   [2:0]   arsize_sysperi_axis;
wire   [9:0]   aruser_sysperi_axis;
wire           arvalid_sysperi_axis;
wire   [31:0]  awaddr_sysperi_axis;
wire   [1:0]   awburst_sysperi_axis;
wire   [3:0]   awcache_sysperi_axis;
wire   [11:0]  awid_sysperi_axis;
wire   [7:0]   awlen_sysperi_axis;
wire           awlock_sysperi_axis;
wire   [2:0]   awprot_sysperi_axis;
wire   [3:0]   awqos_sysperi_axis;
wire           awready_gic_axim;
wire           awready_stm_axim;
wire   [2:0]   awsize_sysperi_axis;
wire   [9:0]   awuser_sysperi_axis;
wire           awvalid_sysperi_axis;
wire   [11:0]  bid_gic_axim;
wire   [11:0]  bid_stm_axim;
wire           bready_sysperi_axis;
wire   [1:0]   bresp_gic_axim;
wire   [1:0]   bresp_stm_axim;
wire           bvalid_gic_axim;
wire           bvalid_stm_axim;
wire           csysreq_cd_a;
wire           csysreq_cd_ctrl;
wire           ctrlclk;
wire           ctrlclken;
wire           ctrlresetn;
wire   [31:0]  hrdata_gpvmain_ahb;
wire           hreadyout_gpvmain_ahb;
wire           hresp_gpvmain_ahb;
wire   [31:0]  prdata_es0h_mhu0;
wire   [31:0]  prdata_es0h_mhu1;
wire   [31:0]  prdata_es1h_mhu0;
wire   [31:0]  prdata_es1h_mhu1;
wire   [31:0]  prdata_hes0_mhu0;
wire   [31:0]  prdata_hes0_mhu1;
wire   [31:0]  prdata_hes1_mhu0;
wire   [31:0]  prdata_hes1_mhu1;
wire   [31:0]  prdata_hostsysdbg_apb;
wire   [31:0]  prdata_hse_mhu0;
wire   [31:0]  prdata_hse_mhu1;
wire   [31:0]  prdata_ppu_cpu_apb;
wire   [31:0]  prdata_sdc600_apb;
wire   [31:0]  prdata_seh_mhu0;
wire   [31:0]  prdata_seh_mhu1;
wire           pready_es0h_mhu0;
wire           pready_es0h_mhu1;
wire           pready_es1h_mhu0;
wire           pready_es1h_mhu1;
wire           pready_hes0_mhu0;
wire           pready_hes0_mhu1;
wire           pready_hes1_mhu0;
wire           pready_hes1_mhu1;
wire           pready_hostsysdbg_apb;
wire           pready_hse_mhu0;
wire           pready_hse_mhu1;
wire           pready_ppu_cpu_apb;
wire           pready_sdc600_apb;
wire           pready_seh_mhu0;
wire           pready_seh_mhu1;
wire           pslverr_es0h_mhu0;
wire           pslverr_es0h_mhu1;
wire           pslverr_es1h_mhu0;
wire           pslverr_es1h_mhu1;
wire           pslverr_hes0_mhu0;
wire           pslverr_hes0_mhu1;
wire           pslverr_hes1_mhu0;
wire           pslverr_hes1_mhu1;
wire           pslverr_hostsysdbg_apb;
wire           pslverr_hse_mhu0;
wire           pslverr_hse_mhu1;
wire           pslverr_ppu_cpu_apb;
wire           pslverr_sdc600_apb;
wire           pslverr_seh_mhu0;
wire           pslverr_seh_mhu1;
wire   [31:0]  rdata_gic_axim;
wire   [63:0]  rdata_stm_axim;
wire   [11:0]  rid_gic_axim;
wire   [11:0]  rid_stm_axim;
wire           rlast_gic_axim;
wire           rlast_stm_axim;
wire           rready_sysperi_axis;
wire   [1:0]   rresp_gic_axim;
wire   [1:0]   rresp_stm_axim;
wire           rvalid_gic_axim;
wire           rvalid_stm_axim;
wire   [31:0]  wdata_sysperi_axis;
wire           wlast_sysperi_axis;
wire           wready_gic_axim;
wire           wready_stm_axim;
wire   [3:0]   wstrb_sysperi_axis;
wire           wvalid_sysperi_axis;




nic400_cd_a_sse710_sys_apb     u_cd_a (
  .csysreq_cd_a         (csysreq_cd_a),    
  .csysack_cd_a         (csysack_cd_a),    
  .cactive_cd_a         (cactive_cd_a),    
  .paddr_es0h_mhu0      (paddr_es0h_mhu0),    
  .pselx_es0h_mhu0      (pselx_es0h_mhu0),    
  .penable_es0h_mhu0    (penable_es0h_mhu0),    
  .pwrite_es0h_mhu0     (pwrite_es0h_mhu0),    
  .prdata_es0h_mhu0     (prdata_es0h_mhu0),    
  .pwdata_es0h_mhu0     (pwdata_es0h_mhu0),    
  .pprot_es0h_mhu0      (pprot_es0h_mhu0),    
  .pstrb_es0h_mhu0      (pstrb_es0h_mhu0),    
  .pready_es0h_mhu0     (pready_es0h_mhu0),    
  .pslverr_es0h_mhu0    (pslverr_es0h_mhu0),    
  .paddr_es0h_mhu1      (paddr_es0h_mhu1),    
  .pselx_es0h_mhu1      (pselx_es0h_mhu1),    
  .penable_es0h_mhu1    (penable_es0h_mhu1),    
  .pwrite_es0h_mhu1     (pwrite_es0h_mhu1),    
  .prdata_es0h_mhu1     (prdata_es0h_mhu1),    
  .pwdata_es0h_mhu1     (pwdata_es0h_mhu1),    
  .pprot_es0h_mhu1      (pprot_es0h_mhu1),    
  .pstrb_es0h_mhu1      (pstrb_es0h_mhu1),    
  .pready_es0h_mhu1     (pready_es0h_mhu1),    
  .pslverr_es0h_mhu1    (pslverr_es0h_mhu1),    
  .paddr_es1h_mhu0      (paddr_es1h_mhu0),    
  .pselx_es1h_mhu0      (pselx_es1h_mhu0),    
  .penable_es1h_mhu0    (penable_es1h_mhu0),    
  .pwrite_es1h_mhu0     (pwrite_es1h_mhu0),    
  .prdata_es1h_mhu0     (prdata_es1h_mhu0),    
  .pwdata_es1h_mhu0     (pwdata_es1h_mhu0),    
  .pprot_es1h_mhu0      (pprot_es1h_mhu0),    
  .pstrb_es1h_mhu0      (pstrb_es1h_mhu0),    
  .pready_es1h_mhu0     (pready_es1h_mhu0),    
  .pslverr_es1h_mhu0    (pslverr_es1h_mhu0),    
  .paddr_es1h_mhu1      (paddr_es1h_mhu1),    
  .pselx_es1h_mhu1      (pselx_es1h_mhu1),    
  .penable_es1h_mhu1    (penable_es1h_mhu1),    
  .pwrite_es1h_mhu1     (pwrite_es1h_mhu1),    
  .prdata_es1h_mhu1     (prdata_es1h_mhu1),    
  .pwdata_es1h_mhu1     (pwdata_es1h_mhu1),    
  .pprot_es1h_mhu1      (pprot_es1h_mhu1),    
  .pstrb_es1h_mhu1      (pstrb_es1h_mhu1),    
  .pready_es1h_mhu1     (pready_es1h_mhu1),    
  .pslverr_es1h_mhu1    (pslverr_es1h_mhu1),    
  .awid_gic_axim        (awid_gic_axim),    
  .awaddr_gic_axim      (awaddr_gic_axim),    
  .awlen_gic_axim       (awlen_gic_axim),    
  .awsize_gic_axim      (awsize_gic_axim),    
  .awburst_gic_axim     (awburst_gic_axim),    
  .awlock_gic_axim      (awlock_gic_axim),    
  .awcache_gic_axim     (awcache_gic_axim),    
  .awprot_gic_axim      (awprot_gic_axim),    
  .awqos_gic_axim       (awqos_gic_axim),    
  .awvalid_gic_axim     (awvalid_gic_axim),    
  .awready_gic_axim     (awready_gic_axim),    
  .wdata_gic_axim       (wdata_gic_axim),    
  .wstrb_gic_axim       (wstrb_gic_axim),    
  .wlast_gic_axim       (wlast_gic_axim),    
  .wvalid_gic_axim      (wvalid_gic_axim),    
  .wready_gic_axim      (wready_gic_axim),    
  .bid_gic_axim         (bid_gic_axim),    
  .bresp_gic_axim       (bresp_gic_axim),    
  .bvalid_gic_axim      (bvalid_gic_axim),    
  .bready_gic_axim      (bready_gic_axim),    
  .arid_gic_axim        (arid_gic_axim),    
  .araddr_gic_axim      (araddr_gic_axim),    
  .arlen_gic_axim       (arlen_gic_axim),    
  .arsize_gic_axim      (arsize_gic_axim),    
  .arburst_gic_axim     (arburst_gic_axim),    
  .arlock_gic_axim      (arlock_gic_axim),    
  .arcache_gic_axim     (arcache_gic_axim),    
  .arprot_gic_axim      (arprot_gic_axim),    
  .arqos_gic_axim       (arqos_gic_axim),    
  .arvalid_gic_axim     (arvalid_gic_axim),    
  .arready_gic_axim     (arready_gic_axim),    
  .rid_gic_axim         (rid_gic_axim),    
  .rdata_gic_axim       (rdata_gic_axim),    
  .rresp_gic_axim       (rresp_gic_axim),    
  .rlast_gic_axim       (rlast_gic_axim),    
  .rvalid_gic_axim      (rvalid_gic_axim),    
  .rready_gic_axim      (rready_gic_axim),    
  .awuser_gic_axim      (awuser_gic_axim),    
  .aruser_gic_axim      (aruser_gic_axim),    
  .haddr_gpvmain_ahb    (haddr_gpvmain_ahb),    
  .hburst_gpvmain_ahb   (hburst_gpvmain_ahb),    
  .hprot_gpvmain_ahb    (hprot_gpvmain_ahb),    
  .hsize_gpvmain_ahb    (hsize_gpvmain_ahb),    
  .htrans_gpvmain_ahb   (htrans_gpvmain_ahb),    
  .hwdata_gpvmain_ahb   (hwdata_gpvmain_ahb),    
  .hwrite_gpvmain_ahb   (hwrite_gpvmain_ahb),    
  .hrdata_gpvmain_ahb   (hrdata_gpvmain_ahb),    
  .hreadyout_gpvmain_ahb (hreadyout_gpvmain_ahb),    
  .hresp_gpvmain_ahb    (hresp_gpvmain_ahb),    
  .hselx_gpvmain_ahb    (hselx_gpvmain_ahb),    
  .hready_gpvmain_ahb   (hready_gpvmain_ahb),    
  .paddr_hes0_mhu0      (paddr_hes0_mhu0),    
  .pselx_hes0_mhu0      (pselx_hes0_mhu0),    
  .penable_hes0_mhu0    (penable_hes0_mhu0),    
  .pwrite_hes0_mhu0     (pwrite_hes0_mhu0),    
  .prdata_hes0_mhu0     (prdata_hes0_mhu0),    
  .pwdata_hes0_mhu0     (pwdata_hes0_mhu0),    
  .pprot_hes0_mhu0      (pprot_hes0_mhu0),    
  .pstrb_hes0_mhu0      (pstrb_hes0_mhu0),    
  .pready_hes0_mhu0     (pready_hes0_mhu0),    
  .pslverr_hes0_mhu0    (pslverr_hes0_mhu0),    
  .paddr_hes0_mhu1      (paddr_hes0_mhu1),    
  .pselx_hes0_mhu1      (pselx_hes0_mhu1),    
  .penable_hes0_mhu1    (penable_hes0_mhu1),    
  .pwrite_hes0_mhu1     (pwrite_hes0_mhu1),    
  .prdata_hes0_mhu1     (prdata_hes0_mhu1),    
  .pwdata_hes0_mhu1     (pwdata_hes0_mhu1),    
  .pprot_hes0_mhu1      (pprot_hes0_mhu1),    
  .pstrb_hes0_mhu1      (pstrb_hes0_mhu1),    
  .pready_hes0_mhu1     (pready_hes0_mhu1),    
  .pslverr_hes0_mhu1    (pslverr_hes0_mhu1),    
  .paddr_hes1_mhu0      (paddr_hes1_mhu0),    
  .pselx_hes1_mhu0      (pselx_hes1_mhu0),    
  .penable_hes1_mhu0    (penable_hes1_mhu0),    
  .pwrite_hes1_mhu0     (pwrite_hes1_mhu0),    
  .prdata_hes1_mhu0     (prdata_hes1_mhu0),    
  .pwdata_hes1_mhu0     (pwdata_hes1_mhu0),    
  .pprot_hes1_mhu0      (pprot_hes1_mhu0),    
  .pstrb_hes1_mhu0      (pstrb_hes1_mhu0),    
  .pready_hes1_mhu0     (pready_hes1_mhu0),    
  .pslverr_hes1_mhu0    (pslverr_hes1_mhu0),    
  .paddr_hes1_mhu1      (paddr_hes1_mhu1),    
  .pselx_hes1_mhu1      (pselx_hes1_mhu1),    
  .penable_hes1_mhu1    (penable_hes1_mhu1),    
  .pwrite_hes1_mhu1     (pwrite_hes1_mhu1),    
  .prdata_hes1_mhu1     (prdata_hes1_mhu1),    
  .pwdata_hes1_mhu1     (pwdata_hes1_mhu1),    
  .pprot_hes1_mhu1      (pprot_hes1_mhu1),    
  .pstrb_hes1_mhu1      (pstrb_hes1_mhu1),    
  .pready_hes1_mhu1     (pready_hes1_mhu1),    
  .pslverr_hes1_mhu1    (pslverr_hes1_mhu1),    
  .paddr_hostsysdbg_apb (paddr_hostsysdbg_apb),    
  .pselx_hostsysdbg_apb (pselx_hostsysdbg_apb),    
  .penable_hostsysdbg_apb (penable_hostsysdbg_apb),    
  .pwrite_hostsysdbg_apb (pwrite_hostsysdbg_apb),    
  .prdata_hostsysdbg_apb (prdata_hostsysdbg_apb),    
  .pwdata_hostsysdbg_apb (pwdata_hostsysdbg_apb),    
  .pprot_hostsysdbg_apb (pprot_hostsysdbg_apb),    
  .pstrb_hostsysdbg_apb (pstrb_hostsysdbg_apb),    
  .pready_hostsysdbg_apb (pready_hostsysdbg_apb),    
  .pslverr_hostsysdbg_apb (pslverr_hostsysdbg_apb),    
  .paddr_hse_mhu0       (paddr_hse_mhu0),    
  .pselx_hse_mhu0       (pselx_hse_mhu0),    
  .penable_hse_mhu0     (penable_hse_mhu0),    
  .pwrite_hse_mhu0      (pwrite_hse_mhu0),    
  .prdata_hse_mhu0      (prdata_hse_mhu0),    
  .pwdata_hse_mhu0      (pwdata_hse_mhu0),    
  .pprot_hse_mhu0       (pprot_hse_mhu0),    
  .pstrb_hse_mhu0       (pstrb_hse_mhu0),    
  .pready_hse_mhu0      (pready_hse_mhu0),    
  .pslverr_hse_mhu0     (pslverr_hse_mhu0),    
  .paddr_hse_mhu1       (paddr_hse_mhu1),    
  .pselx_hse_mhu1       (pselx_hse_mhu1),    
  .penable_hse_mhu1     (penable_hse_mhu1),    
  .pwrite_hse_mhu1      (pwrite_hse_mhu1),    
  .prdata_hse_mhu1      (prdata_hse_mhu1),    
  .pwdata_hse_mhu1      (pwdata_hse_mhu1),    
  .pprot_hse_mhu1       (pprot_hse_mhu1),    
  .pstrb_hse_mhu1       (pstrb_hse_mhu1),    
  .pready_hse_mhu1      (pready_hse_mhu1),    
  .pslverr_hse_mhu1     (pslverr_hse_mhu1),    
  .paddr_sdc600_apb     (paddr_sdc600_apb),    
  .pselx_sdc600_apb     (pselx_sdc600_apb),    
  .penable_sdc600_apb   (penable_sdc600_apb),    
  .pwrite_sdc600_apb    (pwrite_sdc600_apb),    
  .prdata_sdc600_apb    (prdata_sdc600_apb),    
  .pwdata_sdc600_apb    (pwdata_sdc600_apb),    
  .pprot_sdc600_apb     (pprot_sdc600_apb),    
  .pstrb_sdc600_apb     (pstrb_sdc600_apb),    
  .pready_sdc600_apb    (pready_sdc600_apb),    
  .pslverr_sdc600_apb   (pslverr_sdc600_apb),    
  .paddr_seh_mhu0       (paddr_seh_mhu0),    
  .pselx_seh_mhu0       (pselx_seh_mhu0),    
  .penable_seh_mhu0     (penable_seh_mhu0),    
  .pwrite_seh_mhu0      (pwrite_seh_mhu0),    
  .prdata_seh_mhu0      (prdata_seh_mhu0),    
  .pwdata_seh_mhu0      (pwdata_seh_mhu0),    
  .pprot_seh_mhu0       (pprot_seh_mhu0),    
  .pstrb_seh_mhu0       (pstrb_seh_mhu0),    
  .pready_seh_mhu0      (pready_seh_mhu0),    
  .pslverr_seh_mhu0     (pslverr_seh_mhu0),    
  .paddr_seh_mhu1       (paddr_seh_mhu1),    
  .pselx_seh_mhu1       (pselx_seh_mhu1),    
  .penable_seh_mhu1     (penable_seh_mhu1),    
  .pwrite_seh_mhu1      (pwrite_seh_mhu1),    
  .prdata_seh_mhu1      (prdata_seh_mhu1),    
  .pwdata_seh_mhu1      (pwdata_seh_mhu1),    
  .pprot_seh_mhu1       (pprot_seh_mhu1),    
  .pstrb_seh_mhu1       (pstrb_seh_mhu1),    
  .pready_seh_mhu1      (pready_seh_mhu1),    
  .pslverr_seh_mhu1     (pslverr_seh_mhu1),    
  .aclken               (aclken),    
  .a_data_slave_9_ib_int_async (a_data_slave_9_ib_int_async),    
  .a_wpntr_gry_slave_9_ib_int_async (a_wpntr_gry_slave_9_ib_int_async),    
  .a_rpntr_bin_slave_9_ib_int_async (a_rpntr_bin_slave_9_ib_int_async),    
  .a_rpntr_gry_slave_9_ib_int_async (a_rpntr_gry_slave_9_ib_int_async),    
  .w_data_slave_9_ib_int_async (w_data_slave_9_ib_int_async),    
  .w_wpntr_gry_slave_9_ib_int_async (w_wpntr_gry_slave_9_ib_int_async),    
  .w_rpntr_bin_slave_9_ib_int_async (w_rpntr_bin_slave_9_ib_int_async),    
  .w_rpntr_gry_slave_9_ib_int_async (w_rpntr_gry_slave_9_ib_int_async),    
  .d_data_slave_9_ib_int_async (d_data_slave_9_ib_int_async),    
  .d_wpntr_gry_slave_9_ib_int_async (d_wpntr_gry_slave_9_ib_int_async),    
  .d_rpntr_bin_slave_9_ib_int_async (d_rpntr_bin_slave_9_ib_int_async),    
  .d_rpntr_gry_slave_9_ib_int_async (d_rpntr_gry_slave_9_ib_int_async),    
  .empty_slave_9_ib_int_async (empty_slave_9_ib_int_async),    
  .awid_stm_axim        (awid_stm_axim),    
  .awaddr_stm_axim      (awaddr_stm_axim),    
  .awlen_stm_axim       (awlen_stm_axim),    
  .awsize_stm_axim      (awsize_stm_axim),    
  .awburst_stm_axim     (awburst_stm_axim),    
  .awlock_stm_axim      (awlock_stm_axim),    
  .awcache_stm_axim     (awcache_stm_axim),    
  .awprot_stm_axim      (awprot_stm_axim),    
  .awvalid_stm_axim     (awvalid_stm_axim),    
  .awready_stm_axim     (awready_stm_axim),    
  .wdata_stm_axim       (wdata_stm_axim),    
  .wstrb_stm_axim       (wstrb_stm_axim),    
  .wlast_stm_axim       (wlast_stm_axim),    
  .wvalid_stm_axim      (wvalid_stm_axim),    
  .wready_stm_axim      (wready_stm_axim),    
  .bid_stm_axim         (bid_stm_axim),    
  .bresp_stm_axim       (bresp_stm_axim),    
  .bvalid_stm_axim      (bvalid_stm_axim),    
  .bready_stm_axim      (bready_stm_axim),    
  .arid_stm_axim        (arid_stm_axim),    
  .araddr_stm_axim      (araddr_stm_axim),    
  .arlen_stm_axim       (arlen_stm_axim),    
  .arsize_stm_axim      (arsize_stm_axim),    
  .arburst_stm_axim     (arburst_stm_axim),    
  .arlock_stm_axim      (arlock_stm_axim),    
  .arcache_stm_axim     (arcache_stm_axim),    
  .arprot_stm_axim      (arprot_stm_axim),    
  .arvalid_stm_axim     (arvalid_stm_axim),    
  .arready_stm_axim     (arready_stm_axim),    
  .rid_stm_axim         (rid_stm_axim),    
  .rdata_stm_axim       (rdata_stm_axim),    
  .rresp_stm_axim       (rresp_stm_axim),    
  .rlast_stm_axim       (rlast_stm_axim),    
  .rvalid_stm_axim      (rvalid_stm_axim),    
  .rready_stm_axim      (rready_stm_axim),    
  .awuser_stm_axim      (awuser_stm_axim),    
  .aruser_stm_axim      (aruser_stm_axim),    
  .aclk                 (aclk),    
  .aresetn              (aresetn),    
  .awid_sysperi_axis    (awid_sysperi_axis),    
  .awaddr_sysperi_axis  (awaddr_sysperi_axis),    
  .awlen_sysperi_axis   (awlen_sysperi_axis),    
  .awsize_sysperi_axis  (awsize_sysperi_axis),    
  .awburst_sysperi_axis (awburst_sysperi_axis),    
  .awlock_sysperi_axis  (awlock_sysperi_axis),    
  .awcache_sysperi_axis (awcache_sysperi_axis),    
  .awprot_sysperi_axis  (awprot_sysperi_axis),    
  .awqos_sysperi_axis   (awqos_sysperi_axis),    
  .awvalid_sysperi_axis (awvalid_sysperi_axis),    
  .awready_sysperi_axis (awready_sysperi_axis),    
  .wdata_sysperi_axis   (wdata_sysperi_axis),    
  .wstrb_sysperi_axis   (wstrb_sysperi_axis),    
  .wlast_sysperi_axis   (wlast_sysperi_axis),    
  .wvalid_sysperi_axis  (wvalid_sysperi_axis),    
  .wready_sysperi_axis  (wready_sysperi_axis),    
  .bid_sysperi_axis     (bid_sysperi_axis),    
  .bresp_sysperi_axis   (bresp_sysperi_axis),    
  .bvalid_sysperi_axis  (bvalid_sysperi_axis),    
  .bready_sysperi_axis  (bready_sysperi_axis),    
  .arid_sysperi_axis    (arid_sysperi_axis),    
  .araddr_sysperi_axis  (araddr_sysperi_axis),    
  .arlen_sysperi_axis   (arlen_sysperi_axis),    
  .arsize_sysperi_axis  (arsize_sysperi_axis),    
  .arburst_sysperi_axis (arburst_sysperi_axis),    
  .arlock_sysperi_axis  (arlock_sysperi_axis),    
  .arcache_sysperi_axis (arcache_sysperi_axis),    
  .arprot_sysperi_axis  (arprot_sysperi_axis),    
  .arqos_sysperi_axis   (arqos_sysperi_axis),    
  .arvalid_sysperi_axis (arvalid_sysperi_axis),    
  .arready_sysperi_axis (arready_sysperi_axis),    
  .rid_sysperi_axis     (rid_sysperi_axis),    
  .rdata_sysperi_axis   (rdata_sysperi_axis),    
  .rresp_sysperi_axis   (rresp_sysperi_axis),    
  .rlast_sysperi_axis   (rlast_sysperi_axis),    
  .rvalid_sysperi_axis  (rvalid_sysperi_axis),    
  .rready_sysperi_axis  (rready_sysperi_axis),    
  .awuser_sysperi_axis  (awuser_sysperi_axis),    
  .aruser_sysperi_axis  (aruser_sysperi_axis)    
);


nic400_cd_ctrl_sse710_sys_apb     u_cd_ctrl (
  .csysreq_cd_ctrl      (csysreq_cd_ctrl),    
  .csysack_cd_ctrl      (csysack_cd_ctrl),    
  .cactive_cd_ctrl      (cactive_cd_ctrl),    
  .ctrlclk              (ctrlclk),    
  .ctrlresetn           (ctrlresetn),    
  .paddr_ppu_cpu_apb    (paddr_ppu_cpu_apb),    
  .pselx_ppu_cpu_apb    (pselx_ppu_cpu_apb),    
  .penable_ppu_cpu_apb  (penable_ppu_cpu_apb),    
  .pwrite_ppu_cpu_apb   (pwrite_ppu_cpu_apb),    
  .prdata_ppu_cpu_apb   (prdata_ppu_cpu_apb),    
  .pwdata_ppu_cpu_apb   (pwdata_ppu_cpu_apb),    
  .pprot_ppu_cpu_apb    (pprot_ppu_cpu_apb),    
  .pstrb_ppu_cpu_apb    (pstrb_ppu_cpu_apb),    
  .pready_ppu_cpu_apb   (pready_ppu_cpu_apb),    
  .pslverr_ppu_cpu_apb  (pslverr_ppu_cpu_apb),    
  .ctrlclken            (ctrlclken),    
  .a_data_slave_9_ib_int_async (a_data_slave_9_ib_int_async),    
  .a_wpntr_gry_slave_9_ib_int_async (a_wpntr_gry_slave_9_ib_int_async),    
  .a_rpntr_bin_slave_9_ib_int_async (a_rpntr_bin_slave_9_ib_int_async),    
  .a_rpntr_gry_slave_9_ib_int_async (a_rpntr_gry_slave_9_ib_int_async),    
  .w_data_slave_9_ib_int_async (w_data_slave_9_ib_int_async),    
  .w_wpntr_gry_slave_9_ib_int_async (w_wpntr_gry_slave_9_ib_int_async),    
  .w_rpntr_bin_slave_9_ib_int_async (w_rpntr_bin_slave_9_ib_int_async),    
  .w_rpntr_gry_slave_9_ib_int_async (w_rpntr_gry_slave_9_ib_int_async),    
  .d_data_slave_9_ib_int_async (d_data_slave_9_ib_int_async),    
  .d_wpntr_gry_slave_9_ib_int_async (d_wpntr_gry_slave_9_ib_int_async),    
  .d_rpntr_bin_slave_9_ib_int_async (d_rpntr_bin_slave_9_ib_int_async),    
  .d_rpntr_gry_slave_9_ib_int_async (d_rpntr_gry_slave_9_ib_int_async),    
  .empty_slave_9_ib_int_async (empty_slave_9_ib_int_async)    
);



endmodule
