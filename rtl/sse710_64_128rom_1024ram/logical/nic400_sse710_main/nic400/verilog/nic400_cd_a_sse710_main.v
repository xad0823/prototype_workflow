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




module nic400_cd_a_sse710_main (
  

  awid_bootreg_axim,
  awaddr_bootreg_axim,
  awlen_bootreg_axim,
  awsize_bootreg_axim,
  awburst_bootreg_axim,
  awlock_bootreg_axim,
  awcache_bootreg_axim,
  awprot_bootreg_axim,
  awvalid_bootreg_axim,
  awready_bootreg_axim,
  wdata_bootreg_axim,
  wstrb_bootreg_axim,
  wlast_bootreg_axim,
  wvalid_bootreg_axim,
  wready_bootreg_axim,
  bid_bootreg_axim,
  bresp_bootreg_axim,
  bvalid_bootreg_axim,
  bready_bootreg_axim,
  arid_bootreg_axim,
  araddr_bootreg_axim,
  arlen_bootreg_axim,
  arsize_bootreg_axim,
  arburst_bootreg_axim,
  arlock_bootreg_axim,
  arcache_bootreg_axim,
  arprot_bootreg_axim,
  arvalid_bootreg_axim,
  arready_bootreg_axim,
  rid_bootreg_axim,
  rdata_bootreg_axim,
  rresp_bootreg_axim,
  rlast_bootreg_axim,
  rvalid_bootreg_axim,
  rready_bootreg_axim,
  awuser_bootreg_axim,
  aruser_bootreg_axim,
  

  awid_cvm_axim,
  awaddr_cvm_axim,
  awlen_cvm_axim,
  awsize_cvm_axim,
  awburst_cvm_axim,
  awlock_cvm_axim,
  awcache_cvm_axim,
  awprot_cvm_axim,
  awvalid_cvm_axim,
  awready_cvm_axim,
  wdata_cvm_axim,
  wstrb_cvm_axim,
  wlast_cvm_axim,
  wvalid_cvm_axim,
  wready_cvm_axim,
  bid_cvm_axim,
  bresp_cvm_axim,
  bvalid_cvm_axim,
  bready_cvm_axim,
  arid_cvm_axim,
  araddr_cvm_axim,
  arlen_cvm_axim,
  arsize_cvm_axim,
  arburst_cvm_axim,
  arlock_cvm_axim,
  arcache_cvm_axim,
  arprot_cvm_axim,
  arvalid_cvm_axim,
  arready_cvm_axim,
  rid_cvm_axim,
  rdata_cvm_axim,
  rresp_cvm_axim,
  rlast_cvm_axim,
  rvalid_cvm_axim,
  rready_cvm_axim,
  awuser_cvm_axim,
  buser_cvm_axim,
  aruser_cvm_axim,
  ruser_cvm_axim,
  awqos_cvm_axim,
  arqos_cvm_axim,
  

  awid_debug_axim,
  awaddr_debug_axim,
  awlen_debug_axim,
  awsize_debug_axim,
  awburst_debug_axim,
  awlock_debug_axim,
  awcache_debug_axim,
  awprot_debug_axim,
  awvalid_debug_axim,
  awready_debug_axim,
  wdata_debug_axim,
  wstrb_debug_axim,
  wlast_debug_axim,
  wvalid_debug_axim,
  wready_debug_axim,
  bid_debug_axim,
  bresp_debug_axim,
  bvalid_debug_axim,
  bready_debug_axim,
  arid_debug_axim,
  araddr_debug_axim,
  arlen_debug_axim,
  arsize_debug_axim,
  arburst_debug_axim,
  arlock_debug_axim,
  arcache_debug_axim,
  arprot_debug_axim,
  arvalid_debug_axim,
  arready_debug_axim,
  rid_debug_axim,
  rdata_debug_axim,
  rresp_debug_axim,
  rlast_debug_axim,
  rvalid_debug_axim,
  rready_debug_axim,
  awuser_debug_axim,
  buser_debug_axim,
  aruser_debug_axim,
  ruser_debug_axim,
  

  awid_expmstr0_axim,
  awaddr_expmstr0_axim,
  awlen_expmstr0_axim,
  awsize_expmstr0_axim,
  awburst_expmstr0_axim,
  awlock_expmstr0_axim,
  awcache_expmstr0_axim,
  awprot_expmstr0_axim,
  awvalid_expmstr0_axim,
  awready_expmstr0_axim,
  wdata_expmstr0_axim,
  wstrb_expmstr0_axim,
  wlast_expmstr0_axim,
  wvalid_expmstr0_axim,
  wready_expmstr0_axim,
  bid_expmstr0_axim,
  bresp_expmstr0_axim,
  bvalid_expmstr0_axim,
  bready_expmstr0_axim,
  arid_expmstr0_axim,
  araddr_expmstr0_axim,
  arlen_expmstr0_axim,
  arsize_expmstr0_axim,
  arburst_expmstr0_axim,
  arlock_expmstr0_axim,
  arcache_expmstr0_axim,
  arprot_expmstr0_axim,
  arvalid_expmstr0_axim,
  arready_expmstr0_axim,
  rid_expmstr0_axim,
  rdata_expmstr0_axim,
  rresp_expmstr0_axim,
  rlast_expmstr0_axim,
  rvalid_expmstr0_axim,
  rready_expmstr0_axim,
  awuser_expmstr0_axim,
  buser_expmstr0_axim,
  aruser_expmstr0_axim,
  ruser_expmstr0_axim,
  awqos_expmstr0_axim,
  arqos_expmstr0_axim,
  

  awid_expmstr1_axim,
  awaddr_expmstr1_axim,
  awlen_expmstr1_axim,
  awsize_expmstr1_axim,
  awburst_expmstr1_axim,
  awlock_expmstr1_axim,
  awcache_expmstr1_axim,
  awprot_expmstr1_axim,
  awvalid_expmstr1_axim,
  awready_expmstr1_axim,
  wdata_expmstr1_axim,
  wstrb_expmstr1_axim,
  wlast_expmstr1_axim,
  wvalid_expmstr1_axim,
  wready_expmstr1_axim,
  bid_expmstr1_axim,
  bresp_expmstr1_axim,
  bvalid_expmstr1_axim,
  bready_expmstr1_axim,
  arid_expmstr1_axim,
  araddr_expmstr1_axim,
  arlen_expmstr1_axim,
  arsize_expmstr1_axim,
  arburst_expmstr1_axim,
  arlock_expmstr1_axim,
  arcache_expmstr1_axim,
  arprot_expmstr1_axim,
  arvalid_expmstr1_axim,
  arready_expmstr1_axim,
  rid_expmstr1_axim,
  rdata_expmstr1_axim,
  rresp_expmstr1_axim,
  rlast_expmstr1_axim,
  rvalid_expmstr1_axim,
  rready_expmstr1_axim,
  awuser_expmstr1_axim,
  buser_expmstr1_axim,
  aruser_expmstr1_axim,
  ruser_expmstr1_axim,
  awqos_expmstr1_axim,
  arqos_expmstr1_axim,
  

  awid_firewall_axim,
  awaddr_firewall_axim,
  awlen_firewall_axim,
  awsize_firewall_axim,
  awburst_firewall_axim,
  awlock_firewall_axim,
  awcache_firewall_axim,
  awprot_firewall_axim,
  awvalid_firewall_axim,
  awready_firewall_axim,
  wdata_firewall_axim,
  wstrb_firewall_axim,
  wlast_firewall_axim,
  wvalid_firewall_axim,
  wready_firewall_axim,
  bid_firewall_axim,
  bresp_firewall_axim,
  bvalid_firewall_axim,
  bready_firewall_axim,
  arid_firewall_axim,
  araddr_firewall_axim,
  arlen_firewall_axim,
  arsize_firewall_axim,
  arburst_firewall_axim,
  arlock_firewall_axim,
  arcache_firewall_axim,
  arprot_firewall_axim,
  arvalid_firewall_axim,
  arready_firewall_axim,
  rid_firewall_axim,
  rdata_firewall_axim,
  rresp_firewall_axim,
  rlast_firewall_axim,
  rvalid_firewall_axim,
  rready_firewall_axim,
  awuser_firewall_axim,
  buser_firewall_axim,
  aruser_firewall_axim,
  ruser_firewall_axim,
  

  awid_ocvm_axim,
  awaddr_ocvm_axim,
  awlen_ocvm_axim,
  awsize_ocvm_axim,
  awburst_ocvm_axim,
  awlock_ocvm_axim,
  awcache_ocvm_axim,
  awprot_ocvm_axim,
  awvalid_ocvm_axim,
  awready_ocvm_axim,
  wdata_ocvm_axim,
  wstrb_ocvm_axim,
  wlast_ocvm_axim,
  wvalid_ocvm_axim,
  wready_ocvm_axim,
  bid_ocvm_axim,
  bresp_ocvm_axim,
  bvalid_ocvm_axim,
  bready_ocvm_axim,
  arid_ocvm_axim,
  araddr_ocvm_axim,
  arlen_ocvm_axim,
  arsize_ocvm_axim,
  arburst_ocvm_axim,
  arlock_ocvm_axim,
  arcache_ocvm_axim,
  arprot_ocvm_axim,
  arvalid_ocvm_axim,
  arready_ocvm_axim,
  rid_ocvm_axim,
  rdata_ocvm_axim,
  rresp_ocvm_axim,
  rlast_ocvm_axim,
  rvalid_ocvm_axim,
  rready_ocvm_axim,
  awuser_ocvm_axim,
  buser_ocvm_axim,
  aruser_ocvm_axim,
  ruser_ocvm_axim,
  awqos_ocvm_axim,
  arqos_ocvm_axim,
  

  awid_sysctrl_axim,
  awaddr_sysctrl_axim,
  awlen_sysctrl_axim,
  awsize_sysctrl_axim,
  awburst_sysctrl_axim,
  awlock_sysctrl_axim,
  awcache_sysctrl_axim,
  awprot_sysctrl_axim,
  awvalid_sysctrl_axim,
  awready_sysctrl_axim,
  wdata_sysctrl_axim,
  wstrb_sysctrl_axim,
  wlast_sysctrl_axim,
  wvalid_sysctrl_axim,
  wready_sysctrl_axim,
  bid_sysctrl_axim,
  bresp_sysctrl_axim,
  bvalid_sysctrl_axim,
  bready_sysctrl_axim,
  arid_sysctrl_axim,
  araddr_sysctrl_axim,
  arlen_sysctrl_axim,
  arsize_sysctrl_axim,
  arburst_sysctrl_axim,
  arlock_sysctrl_axim,
  arcache_sysctrl_axim,
  arprot_sysctrl_axim,
  arvalid_sysctrl_axim,
  arready_sysctrl_axim,
  rid_sysctrl_axim,
  rdata_sysctrl_axim,
  rresp_sysctrl_axim,
  rlast_sysctrl_axim,
  rvalid_sysctrl_axim,
  rready_sysctrl_axim,
  awuser_sysctrl_axim,
  buser_sysctrl_axim,
  aruser_sysctrl_axim,
  ruser_sysctrl_axim,
  

  awid_sysperi_axim,
  awaddr_sysperi_axim,
  awlen_sysperi_axim,
  awsize_sysperi_axim,
  awburst_sysperi_axim,
  awlock_sysperi_axim,
  awcache_sysperi_axim,
  awprot_sysperi_axim,
  awvalid_sysperi_axim,
  awready_sysperi_axim,
  wdata_sysperi_axim,
  wstrb_sysperi_axim,
  wlast_sysperi_axim,
  wvalid_sysperi_axim,
  wready_sysperi_axim,
  bid_sysperi_axim,
  bresp_sysperi_axim,
  bvalid_sysperi_axim,
  bready_sysperi_axim,
  arid_sysperi_axim,
  araddr_sysperi_axim,
  arlen_sysperi_axim,
  arsize_sysperi_axim,
  arburst_sysperi_axim,
  arlock_sysperi_axim,
  arcache_sysperi_axim,
  arprot_sysperi_axim,
  arvalid_sysperi_axim,
  arready_sysperi_axim,
  rid_sysperi_axim,
  rdata_sysperi_axim,
  rresp_sysperi_axim,
  rlast_sysperi_axim,
  rvalid_sysperi_axim,
  rready_sysperi_axim,
  awuser_sysperi_axim,
  buser_sysperi_axim,
  aruser_sysperi_axim,
  ruser_sysperi_axim,
  

  awid_xnvm_axim,
  awaddr_xnvm_axim,
  awlen_xnvm_axim,
  awsize_xnvm_axim,
  awburst_xnvm_axim,
  awlock_xnvm_axim,
  awcache_xnvm_axim,
  awprot_xnvm_axim,
  awvalid_xnvm_axim,
  awready_xnvm_axim,
  wdata_xnvm_axim,
  wstrb_xnvm_axim,
  wlast_xnvm_axim,
  wvalid_xnvm_axim,
  wready_xnvm_axim,
  bid_xnvm_axim,
  bresp_xnvm_axim,
  bvalid_xnvm_axim,
  bready_xnvm_axim,
  arid_xnvm_axim,
  araddr_xnvm_axim,
  arlen_xnvm_axim,
  arsize_xnvm_axim,
  arburst_xnvm_axim,
  arlock_xnvm_axim,
  arcache_xnvm_axim,
  arprot_xnvm_axim,
  arvalid_xnvm_axim,
  arready_xnvm_axim,
  rid_xnvm_axim,
  rdata_xnvm_axim,
  rresp_xnvm_axim,
  rlast_xnvm_axim,
  rvalid_xnvm_axim,
  rready_xnvm_axim,
  awuser_xnvm_axim,
  buser_xnvm_axim,
  aruser_xnvm_axim,
  ruser_xnvm_axim,
  awqos_xnvm_axim,
  arqos_xnvm_axim,
  

  awid_debug_axis,
  awaddr_debug_axis,
  awlen_debug_axis,
  awsize_debug_axis,
  awburst_debug_axis,
  awlock_debug_axis,
  awcache_debug_axis,
  awprot_debug_axis,
  awvalid_debug_axis,
  awready_debug_axis,
  wdata_debug_axis,
  wstrb_debug_axis,
  wlast_debug_axis,
  wvalid_debug_axis,
  wready_debug_axis,
  bid_debug_axis,
  bresp_debug_axis,
  bvalid_debug_axis,
  bready_debug_axis,
  arid_debug_axis,
  araddr_debug_axis,
  arlen_debug_axis,
  arsize_debug_axis,
  arburst_debug_axis,
  arlock_debug_axis,
  arcache_debug_axis,
  arprot_debug_axis,
  arvalid_debug_axis,
  arready_debug_axis,
  rid_debug_axis,
  rdata_debug_axis,
  rresp_debug_axis,
  rlast_debug_axis,
  rvalid_debug_axis,
  rready_debug_axis,
  awuser_debug_axis,
  buser_debug_axis,
  aruser_debug_axis,
  ruser_debug_axis,
  

  awid_expslv0_axis,
  awaddr_expslv0_axis,
  awlen_expslv0_axis,
  awsize_expslv0_axis,
  awburst_expslv0_axis,
  awlock_expslv0_axis,
  awcache_expslv0_axis,
  awprot_expslv0_axis,
  awvalid_expslv0_axis,
  awready_expslv0_axis,
  wdata_expslv0_axis,
  wstrb_expslv0_axis,
  wlast_expslv0_axis,
  wvalid_expslv0_axis,
  wready_expslv0_axis,
  bid_expslv0_axis,
  bresp_expslv0_axis,
  bvalid_expslv0_axis,
  bready_expslv0_axis,
  arid_expslv0_axis,
  araddr_expslv0_axis,
  arlen_expslv0_axis,
  arsize_expslv0_axis,
  arburst_expslv0_axis,
  arlock_expslv0_axis,
  arcache_expslv0_axis,
  arprot_expslv0_axis,
  arvalid_expslv0_axis,
  arready_expslv0_axis,
  rid_expslv0_axis,
  rdata_expslv0_axis,
  rresp_expslv0_axis,
  rlast_expslv0_axis,
  rvalid_expslv0_axis,
  rready_expslv0_axis,
  awuser_expslv0_axis,
  buser_expslv0_axis,
  aruser_expslv0_axis,
  ruser_expslv0_axis,
  awqos_expslv0_axis,
  arqos_expslv0_axis,
  

  awid_expslv1_axis,
  awaddr_expslv1_axis,
  awlen_expslv1_axis,
  awsize_expslv1_axis,
  awburst_expslv1_axis,
  awlock_expslv1_axis,
  awcache_expslv1_axis,
  awprot_expslv1_axis,
  awvalid_expslv1_axis,
  awready_expslv1_axis,
  wdata_expslv1_axis,
  wstrb_expslv1_axis,
  wlast_expslv1_axis,
  wvalid_expslv1_axis,
  wready_expslv1_axis,
  bid_expslv1_axis,
  bresp_expslv1_axis,
  bvalid_expslv1_axis,
  bready_expslv1_axis,
  arid_expslv1_axis,
  araddr_expslv1_axis,
  arlen_expslv1_axis,
  arsize_expslv1_axis,
  arburst_expslv1_axis,
  arlock_expslv1_axis,
  arcache_expslv1_axis,
  arprot_expslv1_axis,
  arvalid_expslv1_axis,
  arready_expslv1_axis,
  rid_expslv1_axis,
  rdata_expslv1_axis,
  rresp_expslv1_axis,
  rlast_expslv1_axis,
  rvalid_expslv1_axis,
  rready_expslv1_axis,
  awuser_expslv1_axis,
  buser_expslv1_axis,
  aruser_expslv1_axis,
  ruser_expslv1_axis,
  awqos_expslv1_axis,
  arqos_expslv1_axis,
  

  awid_extsys0_axis,
  awaddr_extsys0_axis,
  awlen_extsys0_axis,
  awsize_extsys0_axis,
  awburst_extsys0_axis,
  awlock_extsys0_axis,
  awcache_extsys0_axis,
  awprot_extsys0_axis,
  awvalid_extsys0_axis,
  awready_extsys0_axis,
  wdata_extsys0_axis,
  wstrb_extsys0_axis,
  wlast_extsys0_axis,
  wvalid_extsys0_axis,
  wready_extsys0_axis,
  bid_extsys0_axis,
  bresp_extsys0_axis,
  bvalid_extsys0_axis,
  bready_extsys0_axis,
  arid_extsys0_axis,
  araddr_extsys0_axis,
  arlen_extsys0_axis,
  arsize_extsys0_axis,
  arburst_extsys0_axis,
  arlock_extsys0_axis,
  arcache_extsys0_axis,
  arprot_extsys0_axis,
  arvalid_extsys0_axis,
  arready_extsys0_axis,
  rid_extsys0_axis,
  rdata_extsys0_axis,
  rresp_extsys0_axis,
  rlast_extsys0_axis,
  rvalid_extsys0_axis,
  rready_extsys0_axis,
  awuser_extsys0_axis,
  buser_extsys0_axis,
  aruser_extsys0_axis,
  ruser_extsys0_axis,
  

  awid_extsys1_axis,
  awaddr_extsys1_axis,
  awlen_extsys1_axis,
  awsize_extsys1_axis,
  awburst_extsys1_axis,
  awlock_extsys1_axis,
  awcache_extsys1_axis,
  awprot_extsys1_axis,
  awvalid_extsys1_axis,
  awready_extsys1_axis,
  wdata_extsys1_axis,
  wstrb_extsys1_axis,
  wlast_extsys1_axis,
  wvalid_extsys1_axis,
  wready_extsys1_axis,
  bid_extsys1_axis,
  bresp_extsys1_axis,
  bvalid_extsys1_axis,
  bready_extsys1_axis,
  arid_extsys1_axis,
  araddr_extsys1_axis,
  arlen_extsys1_axis,
  arsize_extsys1_axis,
  arburst_extsys1_axis,
  arlock_extsys1_axis,
  arcache_extsys1_axis,
  arprot_extsys1_axis,
  arvalid_extsys1_axis,
  arready_extsys1_axis,
  rid_extsys1_axis,
  rdata_extsys1_axis,
  rresp_extsys1_axis,
  rlast_extsys1_axis,
  rvalid_extsys1_axis,
  rready_extsys1_axis,
  awuser_extsys1_axis,
  buser_extsys1_axis,
  aruser_extsys1_axis,
  ruser_extsys1_axis,
  

  awid_hostcpu_axis,
  awaddr_hostcpu_axis,
  awlen_hostcpu_axis,
  awsize_hostcpu_axis,
  awburst_hostcpu_axis,
  awlock_hostcpu_axis,
  awcache_hostcpu_axis,
  awprot_hostcpu_axis,
  awvalid_hostcpu_axis,
  awready_hostcpu_axis,
  wdata_hostcpu_axis,
  wstrb_hostcpu_axis,
  wlast_hostcpu_axis,
  wvalid_hostcpu_axis,
  wready_hostcpu_axis,
  bid_hostcpu_axis,
  bresp_hostcpu_axis,
  bvalid_hostcpu_axis,
  bready_hostcpu_axis,
  arid_hostcpu_axis,
  araddr_hostcpu_axis,
  arlen_hostcpu_axis,
  arsize_hostcpu_axis,
  arburst_hostcpu_axis,
  arlock_hostcpu_axis,
  arcache_hostcpu_axis,
  arprot_hostcpu_axis,
  arvalid_hostcpu_axis,
  arready_hostcpu_axis,
  rid_hostcpu_axis,
  rdata_hostcpu_axis,
  rresp_hostcpu_axis,
  rlast_hostcpu_axis,
  rvalid_hostcpu_axis,
  rready_hostcpu_axis,
  awuser_hostcpu_axis,
  buser_hostcpu_axis,
  aruser_hostcpu_axis,
  ruser_hostcpu_axis,
  

  awid_secenc_axis,
  awaddr_secenc_axis,
  awlen_secenc_axis,
  awsize_secenc_axis,
  awburst_secenc_axis,
  awlock_secenc_axis,
  awcache_secenc_axis,
  awprot_secenc_axis,
  awvalid_secenc_axis,
  awready_secenc_axis,
  wdata_secenc_axis,
  wstrb_secenc_axis,
  wlast_secenc_axis,
  wvalid_secenc_axis,
  wready_secenc_axis,
  bid_secenc_axis,
  bresp_secenc_axis,
  bvalid_secenc_axis,
  bready_secenc_axis,
  arid_secenc_axis,
  araddr_secenc_axis,
  arlen_secenc_axis,
  arsize_secenc_axis,
  arburst_secenc_axis,
  arlock_secenc_axis,
  arcache_secenc_axis,
  arprot_secenc_axis,
  arvalid_secenc_axis,
  arready_secenc_axis,
  rid_secenc_axis,
  rdata_secenc_axis,
  rresp_secenc_axis,
  rlast_secenc_axis,
  rvalid_secenc_axis,
  rready_secenc_axis,
  awuser_secenc_axis,
  buser_secenc_axis,
  aruser_secenc_axis,
  ruser_secenc_axis,
  

  cactive_cd_a,
  csysreq_cd_a,
  csysack_cd_a,
  

  paddr_debug_axis_ib_apb,
  pwdata_debug_axis_ib_apb,
  pwrite_debug_axis_ib_apb,
  penable_debug_axis_ib_apb,
  pselx_debug_axis_ib_apb,
  prdata_debug_axis_ib_apb,
  pslverr_debug_axis_ib_apb,
  pready_debug_axis_ib_apb,
  

  paddr_extsys0_axis_ib_apb,
  pwdata_extsys0_axis_ib_apb,
  pwrite_extsys0_axis_ib_apb,
  penable_extsys0_axis_ib_apb,
  pselx_extsys0_axis_ib_apb,
  prdata_extsys0_axis_ib_apb,
  pslverr_extsys0_axis_ib_apb,
  pready_extsys0_axis_ib_apb,
  

  paddr_extsys1_axis_ib_apb,
  pwdata_extsys1_axis_ib_apb,
  pwrite_extsys1_axis_ib_apb,
  penable_extsys1_axis_ib_apb,
  pselx_extsys1_axis_ib_apb,
  prdata_extsys1_axis_ib_apb,
  pslverr_extsys1_axis_ib_apb,
  pready_extsys1_axis_ib_apb,
  

  a_data_gpv_0_ib1_int,
  a_valid_gpv_0_ib1_int,
  a_ready_gpv_0_ib1_int,
  d_data_gpv_0_ib1_int,
  d_valid_gpv_0_ib1_int,
  d_ready_gpv_0_ib1_int,
  w_data_gpv_0_ib1_int,
  w_valid_gpv_0_ib1_int,
  w_ready_gpv_0_ib1_int,
  

  a_data_gpvmain_ahb_ib_int,
  a_valid_gpvmain_ahb_ib_int,
  a_ready_gpvmain_ahb_ib_int,
  d_data_gpvmain_ahb_ib_int,
  d_valid_gpvmain_ahb_ib_int,
  d_ready_gpvmain_ahb_ib_int,
  w_data_gpvmain_ahb_ib_int,
  w_valid_gpvmain_ahb_ib_int,
  w_ready_gpvmain_ahb_ib_int,
  empty_gpvmain_ahb_ib_int,
  

  paddr_hostcpu_axis_ib_apb,
  pwdata_hostcpu_axis_ib_apb,
  pwrite_hostcpu_axis_ib_apb,
  penable_hostcpu_axis_ib_apb,
  pselx_hostcpu_axis_ib_apb,
  prdata_hostcpu_axis_ib_apb,
  pslverr_hostcpu_axis_ib_apb,
  pready_hostcpu_axis_ib_apb,
  

  paddr_secenc_axis_ib_apb,
  pwdata_secenc_axis_ib_apb,
  pwrite_secenc_axis_ib_apb,
  penable_secenc_axis_ib_apb,
  pselx_secenc_axis_ib_apb,
  prdata_secenc_axis_ib_apb,
  pslverr_secenc_axis_ib_apb,
  pready_secenc_axis_ib_apb,


  aclk,
  aresetn

);






output [9:0]  awid_bootreg_axim;
output [39:0] awaddr_bootreg_axim;
output [7:0]  awlen_bootreg_axim;
output [2:0]  awsize_bootreg_axim;
output [1:0]  awburst_bootreg_axim;
output        awlock_bootreg_axim;
output [3:0]  awcache_bootreg_axim;
output [2:0]  awprot_bootreg_axim;
output        awvalid_bootreg_axim;
input         awready_bootreg_axim;
output [31:0] wdata_bootreg_axim;
output [3:0]  wstrb_bootreg_axim;
output        wlast_bootreg_axim;
output        wvalid_bootreg_axim;
input         wready_bootreg_axim;
input  [9:0]  bid_bootreg_axim;
input  [1:0]  bresp_bootreg_axim;
input         bvalid_bootreg_axim;
output        bready_bootreg_axim;
output [9:0]  arid_bootreg_axim;
output [39:0] araddr_bootreg_axim;
output [7:0]  arlen_bootreg_axim;
output [2:0]  arsize_bootreg_axim;
output [1:0]  arburst_bootreg_axim;
output        arlock_bootreg_axim;
output [3:0]  arcache_bootreg_axim;
output [2:0]  arprot_bootreg_axim;
output        arvalid_bootreg_axim;
input         arready_bootreg_axim;
input  [9:0]  rid_bootreg_axim;
input  [31:0] rdata_bootreg_axim;
input  [1:0]  rresp_bootreg_axim;
input         rlast_bootreg_axim;
input         rvalid_bootreg_axim;
output        rready_bootreg_axim;
output [9:0]  awuser_bootreg_axim;
output [9:0]  aruser_bootreg_axim;


output [11:0] awid_cvm_axim;
output [31:0] awaddr_cvm_axim;
output [7:0]  awlen_cvm_axim;
output [2:0]  awsize_cvm_axim;
output [1:0]  awburst_cvm_axim;
output        awlock_cvm_axim;
output [3:0]  awcache_cvm_axim;
output [2:0]  awprot_cvm_axim;
output        awvalid_cvm_axim;
input         awready_cvm_axim;
output [63:0] wdata_cvm_axim;
output [7:0]  wstrb_cvm_axim;
output        wlast_cvm_axim;
output        wvalid_cvm_axim;
input         wready_cvm_axim;
input  [11:0] bid_cvm_axim;
input  [1:0]  bresp_cvm_axim;
input         bvalid_cvm_axim;
output        bready_cvm_axim;
output [11:0] arid_cvm_axim;
output [31:0] araddr_cvm_axim;
output [7:0]  arlen_cvm_axim;
output [2:0]  arsize_cvm_axim;
output [1:0]  arburst_cvm_axim;
output        arlock_cvm_axim;
output [3:0]  arcache_cvm_axim;
output [2:0]  arprot_cvm_axim;
output        arvalid_cvm_axim;
input         arready_cvm_axim;
input  [11:0] rid_cvm_axim;
input  [63:0] rdata_cvm_axim;
input  [1:0]  rresp_cvm_axim;
input         rlast_cvm_axim;
input         rvalid_cvm_axim;
output        rready_cvm_axim;
output [9:0]  awuser_cvm_axim;
input         buser_cvm_axim;
output [9:0]  aruser_cvm_axim;
input         ruser_cvm_axim;
output [3:0]  awqos_cvm_axim;
output [3:0]  arqos_cvm_axim;


output [8:0]  awid_debug_axim;
output [31:0] awaddr_debug_axim;
output [7:0]  awlen_debug_axim;
output [2:0]  awsize_debug_axim;
output [1:0]  awburst_debug_axim;
output        awlock_debug_axim;
output [3:0]  awcache_debug_axim;
output [2:0]  awprot_debug_axim;
output        awvalid_debug_axim;
input         awready_debug_axim;
output [31:0] wdata_debug_axim;
output [3:0]  wstrb_debug_axim;
output        wlast_debug_axim;
output        wvalid_debug_axim;
input         wready_debug_axim;
input  [8:0]  bid_debug_axim;
input  [1:0]  bresp_debug_axim;
input         bvalid_debug_axim;
output        bready_debug_axim;
output [8:0]  arid_debug_axim;
output [31:0] araddr_debug_axim;
output [7:0]  arlen_debug_axim;
output [2:0]  arsize_debug_axim;
output [1:0]  arburst_debug_axim;
output        arlock_debug_axim;
output [3:0]  arcache_debug_axim;
output [2:0]  arprot_debug_axim;
output        arvalid_debug_axim;
input         arready_debug_axim;
input  [8:0]  rid_debug_axim;
input  [31:0] rdata_debug_axim;
input  [1:0]  rresp_debug_axim;
input         rlast_debug_axim;
input         rvalid_debug_axim;
output        rready_debug_axim;
output [9:0]  awuser_debug_axim;
input         buser_debug_axim;
output [9:0]  aruser_debug_axim;
input         ruser_debug_axim;


output [11:0] awid_expmstr0_axim;
output [31:0] awaddr_expmstr0_axim;
output [7:0]  awlen_expmstr0_axim;
output [2:0]  awsize_expmstr0_axim;
output [1:0]  awburst_expmstr0_axim;
output        awlock_expmstr0_axim;
output [3:0]  awcache_expmstr0_axim;
output [2:0]  awprot_expmstr0_axim;
output        awvalid_expmstr0_axim;
input         awready_expmstr0_axim;
output [63:0] wdata_expmstr0_axim;
output [7:0]  wstrb_expmstr0_axim;
output        wlast_expmstr0_axim;
output        wvalid_expmstr0_axim;
input         wready_expmstr0_axim;
input  [11:0] bid_expmstr0_axim;
input  [1:0]  bresp_expmstr0_axim;
input         bvalid_expmstr0_axim;
output        bready_expmstr0_axim;
output [11:0] arid_expmstr0_axim;
output [31:0] araddr_expmstr0_axim;
output [7:0]  arlen_expmstr0_axim;
output [2:0]  arsize_expmstr0_axim;
output [1:0]  arburst_expmstr0_axim;
output        arlock_expmstr0_axim;
output [3:0]  arcache_expmstr0_axim;
output [2:0]  arprot_expmstr0_axim;
output        arvalid_expmstr0_axim;
input         arready_expmstr0_axim;
input  [11:0] rid_expmstr0_axim;
input  [63:0] rdata_expmstr0_axim;
input  [1:0]  rresp_expmstr0_axim;
input         rlast_expmstr0_axim;
input         rvalid_expmstr0_axim;
output        rready_expmstr0_axim;
output [9:0]  awuser_expmstr0_axim;
input         buser_expmstr0_axim;
output [9:0]  aruser_expmstr0_axim;
input         ruser_expmstr0_axim;
output [3:0]  awqos_expmstr0_axim;
output [3:0]  arqos_expmstr0_axim;


output [11:0] awid_expmstr1_axim;
output [31:0] awaddr_expmstr1_axim;
output [7:0]  awlen_expmstr1_axim;
output [2:0]  awsize_expmstr1_axim;
output [1:0]  awburst_expmstr1_axim;
output        awlock_expmstr1_axim;
output [3:0]  awcache_expmstr1_axim;
output [2:0]  awprot_expmstr1_axim;
output        awvalid_expmstr1_axim;
input         awready_expmstr1_axim;
output [63:0] wdata_expmstr1_axim;
output [7:0]  wstrb_expmstr1_axim;
output        wlast_expmstr1_axim;
output        wvalid_expmstr1_axim;
input         wready_expmstr1_axim;
input  [11:0] bid_expmstr1_axim;
input  [1:0]  bresp_expmstr1_axim;
input         bvalid_expmstr1_axim;
output        bready_expmstr1_axim;
output [11:0] arid_expmstr1_axim;
output [31:0] araddr_expmstr1_axim;
output [7:0]  arlen_expmstr1_axim;
output [2:0]  arsize_expmstr1_axim;
output [1:0]  arburst_expmstr1_axim;
output        arlock_expmstr1_axim;
output [3:0]  arcache_expmstr1_axim;
output [2:0]  arprot_expmstr1_axim;
output        arvalid_expmstr1_axim;
input         arready_expmstr1_axim;
input  [11:0] rid_expmstr1_axim;
input  [63:0] rdata_expmstr1_axim;
input  [1:0]  rresp_expmstr1_axim;
input         rlast_expmstr1_axim;
input         rvalid_expmstr1_axim;
output        rready_expmstr1_axim;
output [9:0]  awuser_expmstr1_axim;
input         buser_expmstr1_axim;
output [9:0]  aruser_expmstr1_axim;
input         ruser_expmstr1_axim;
output [3:0]  awqos_expmstr1_axim;
output [3:0]  arqos_expmstr1_axim;


output [9:0]  awid_firewall_axim;
output [31:0] awaddr_firewall_axim;
output [7:0]  awlen_firewall_axim;
output [2:0]  awsize_firewall_axim;
output [1:0]  awburst_firewall_axim;
output        awlock_firewall_axim;
output [3:0]  awcache_firewall_axim;
output [2:0]  awprot_firewall_axim;
output        awvalid_firewall_axim;
input         awready_firewall_axim;
output [31:0] wdata_firewall_axim;
output [3:0]  wstrb_firewall_axim;
output        wlast_firewall_axim;
output        wvalid_firewall_axim;
input         wready_firewall_axim;
input  [9:0]  bid_firewall_axim;
input  [1:0]  bresp_firewall_axim;
input         bvalid_firewall_axim;
output        bready_firewall_axim;
output [9:0]  arid_firewall_axim;
output [31:0] araddr_firewall_axim;
output [7:0]  arlen_firewall_axim;
output [2:0]  arsize_firewall_axim;
output [1:0]  arburst_firewall_axim;
output        arlock_firewall_axim;
output [3:0]  arcache_firewall_axim;
output [2:0]  arprot_firewall_axim;
output        arvalid_firewall_axim;
input         arready_firewall_axim;
input  [9:0]  rid_firewall_axim;
input  [31:0] rdata_firewall_axim;
input  [1:0]  rresp_firewall_axim;
input         rlast_firewall_axim;
input         rvalid_firewall_axim;
output        rready_firewall_axim;
output [9:0]  awuser_firewall_axim;
input         buser_firewall_axim;
output [9:0]  aruser_firewall_axim;
input         ruser_firewall_axim;


output [11:0] awid_ocvm_axim;
output [31:0] awaddr_ocvm_axim;
output [7:0]  awlen_ocvm_axim;
output [2:0]  awsize_ocvm_axim;
output [1:0]  awburst_ocvm_axim;
output        awlock_ocvm_axim;
output [3:0]  awcache_ocvm_axim;
output [2:0]  awprot_ocvm_axim;
output        awvalid_ocvm_axim;
input         awready_ocvm_axim;
output [63:0] wdata_ocvm_axim;
output [7:0]  wstrb_ocvm_axim;
output        wlast_ocvm_axim;
output        wvalid_ocvm_axim;
input         wready_ocvm_axim;
input  [11:0] bid_ocvm_axim;
input  [1:0]  bresp_ocvm_axim;
input         bvalid_ocvm_axim;
output        bready_ocvm_axim;
output [11:0] arid_ocvm_axim;
output [31:0] araddr_ocvm_axim;
output [7:0]  arlen_ocvm_axim;
output [2:0]  arsize_ocvm_axim;
output [1:0]  arburst_ocvm_axim;
output        arlock_ocvm_axim;
output [3:0]  arcache_ocvm_axim;
output [2:0]  arprot_ocvm_axim;
output        arvalid_ocvm_axim;
input         arready_ocvm_axim;
input  [11:0] rid_ocvm_axim;
input  [63:0] rdata_ocvm_axim;
input  [1:0]  rresp_ocvm_axim;
input         rlast_ocvm_axim;
input         rvalid_ocvm_axim;
output        rready_ocvm_axim;
output [9:0]  awuser_ocvm_axim;
input         buser_ocvm_axim;
output [9:0]  aruser_ocvm_axim;
input         ruser_ocvm_axim;
output [3:0]  awqos_ocvm_axim;
output [3:0]  arqos_ocvm_axim;


output [11:0] awid_sysctrl_axim;
output [31:0] awaddr_sysctrl_axim;
output [7:0]  awlen_sysctrl_axim;
output [2:0]  awsize_sysctrl_axim;
output [1:0]  awburst_sysctrl_axim;
output        awlock_sysctrl_axim;
output [3:0]  awcache_sysctrl_axim;
output [2:0]  awprot_sysctrl_axim;
output        awvalid_sysctrl_axim;
input         awready_sysctrl_axim;
output [31:0] wdata_sysctrl_axim;
output [3:0]  wstrb_sysctrl_axim;
output        wlast_sysctrl_axim;
output        wvalid_sysctrl_axim;
input         wready_sysctrl_axim;
input  [11:0] bid_sysctrl_axim;
input  [1:0]  bresp_sysctrl_axim;
input         bvalid_sysctrl_axim;
output        bready_sysctrl_axim;
output [11:0] arid_sysctrl_axim;
output [31:0] araddr_sysctrl_axim;
output [7:0]  arlen_sysctrl_axim;
output [2:0]  arsize_sysctrl_axim;
output [1:0]  arburst_sysctrl_axim;
output        arlock_sysctrl_axim;
output [3:0]  arcache_sysctrl_axim;
output [2:0]  arprot_sysctrl_axim;
output        arvalid_sysctrl_axim;
input         arready_sysctrl_axim;
input  [11:0] rid_sysctrl_axim;
input  [31:0] rdata_sysctrl_axim;
input  [1:0]  rresp_sysctrl_axim;
input         rlast_sysctrl_axim;
input         rvalid_sysctrl_axim;
output        rready_sysctrl_axim;
output [9:0]  awuser_sysctrl_axim;
input         buser_sysctrl_axim;
output [9:0]  aruser_sysctrl_axim;
input         ruser_sysctrl_axim;


output [11:0] awid_sysperi_axim;
output [31:0] awaddr_sysperi_axim;
output [7:0]  awlen_sysperi_axim;
output [2:0]  awsize_sysperi_axim;
output [1:0]  awburst_sysperi_axim;
output        awlock_sysperi_axim;
output [3:0]  awcache_sysperi_axim;
output [2:0]  awprot_sysperi_axim;
output        awvalid_sysperi_axim;
input         awready_sysperi_axim;
output [31:0] wdata_sysperi_axim;
output [3:0]  wstrb_sysperi_axim;
output        wlast_sysperi_axim;
output        wvalid_sysperi_axim;
input         wready_sysperi_axim;
input  [11:0] bid_sysperi_axim;
input  [1:0]  bresp_sysperi_axim;
input         bvalid_sysperi_axim;
output        bready_sysperi_axim;
output [11:0] arid_sysperi_axim;
output [31:0] araddr_sysperi_axim;
output [7:0]  arlen_sysperi_axim;
output [2:0]  arsize_sysperi_axim;
output [1:0]  arburst_sysperi_axim;
output        arlock_sysperi_axim;
output [3:0]  arcache_sysperi_axim;
output [2:0]  arprot_sysperi_axim;
output        arvalid_sysperi_axim;
input         arready_sysperi_axim;
input  [11:0] rid_sysperi_axim;
input  [31:0] rdata_sysperi_axim;
input  [1:0]  rresp_sysperi_axim;
input         rlast_sysperi_axim;
input         rvalid_sysperi_axim;
output        rready_sysperi_axim;
output [9:0]  awuser_sysperi_axim;
input         buser_sysperi_axim;
output [9:0]  aruser_sysperi_axim;
input         ruser_sysperi_axim;


output [11:0] awid_xnvm_axim;
output [31:0] awaddr_xnvm_axim;
output [7:0]  awlen_xnvm_axim;
output [2:0]  awsize_xnvm_axim;
output [1:0]  awburst_xnvm_axim;
output        awlock_xnvm_axim;
output [3:0]  awcache_xnvm_axim;
output [2:0]  awprot_xnvm_axim;
output        awvalid_xnvm_axim;
input         awready_xnvm_axim;
output [63:0] wdata_xnvm_axim;
output [7:0]  wstrb_xnvm_axim;
output        wlast_xnvm_axim;
output        wvalid_xnvm_axim;
input         wready_xnvm_axim;
input  [11:0] bid_xnvm_axim;
input  [1:0]  bresp_xnvm_axim;
input         bvalid_xnvm_axim;
output        bready_xnvm_axim;
output [11:0] arid_xnvm_axim;
output [31:0] araddr_xnvm_axim;
output [7:0]  arlen_xnvm_axim;
output [2:0]  arsize_xnvm_axim;
output [1:0]  arburst_xnvm_axim;
output        arlock_xnvm_axim;
output [3:0]  arcache_xnvm_axim;
output [2:0]  arprot_xnvm_axim;
output        arvalid_xnvm_axim;
input         arready_xnvm_axim;
input  [11:0] rid_xnvm_axim;
input  [63:0] rdata_xnvm_axim;
input  [1:0]  rresp_xnvm_axim;
input         rlast_xnvm_axim;
input         rvalid_xnvm_axim;
output        rready_xnvm_axim;
output [9:0]  awuser_xnvm_axim;
input         buser_xnvm_axim;
output [9:0]  aruser_xnvm_axim;
input         ruser_xnvm_axim;
output [3:0]  awqos_xnvm_axim;
output [3:0]  arqos_xnvm_axim;


input  [3:0]  awid_debug_axis;
input  [31:0] awaddr_debug_axis;
input  [7:0]  awlen_debug_axis;
input  [2:0]  awsize_debug_axis;
input  [1:0]  awburst_debug_axis;
input         awlock_debug_axis;
input  [3:0]  awcache_debug_axis;
input  [2:0]  awprot_debug_axis;
input         awvalid_debug_axis;
output        awready_debug_axis;
input  [63:0] wdata_debug_axis;
input  [7:0]  wstrb_debug_axis;
input         wlast_debug_axis;
input         wvalid_debug_axis;
output        wready_debug_axis;
output [3:0]  bid_debug_axis;
output [1:0]  bresp_debug_axis;
output        bvalid_debug_axis;
input         bready_debug_axis;
input  [3:0]  arid_debug_axis;
input  [31:0] araddr_debug_axis;
input  [7:0]  arlen_debug_axis;
input  [2:0]  arsize_debug_axis;
input  [1:0]  arburst_debug_axis;
input         arlock_debug_axis;
input  [3:0]  arcache_debug_axis;
input  [2:0]  arprot_debug_axis;
input         arvalid_debug_axis;
output        arready_debug_axis;
output [3:0]  rid_debug_axis;
output [63:0] rdata_debug_axis;
output [1:0]  rresp_debug_axis;
output        rlast_debug_axis;
output        rvalid_debug_axis;
input         rready_debug_axis;
input  [9:0]  awuser_debug_axis;
output        buser_debug_axis;
input  [9:0]  aruser_debug_axis;
output        ruser_debug_axis;


input  [7:0]  awid_expslv0_axis;
input  [31:0] awaddr_expslv0_axis;
input  [7:0]  awlen_expslv0_axis;
input  [2:0]  awsize_expslv0_axis;
input  [1:0]  awburst_expslv0_axis;
input         awlock_expslv0_axis;
input  [3:0]  awcache_expslv0_axis;
input  [2:0]  awprot_expslv0_axis;
input         awvalid_expslv0_axis;
output        awready_expslv0_axis;
input  [63:0] wdata_expslv0_axis;
input  [7:0]  wstrb_expslv0_axis;
input         wlast_expslv0_axis;
input         wvalid_expslv0_axis;
output        wready_expslv0_axis;
output [7:0]  bid_expslv0_axis;
output [1:0]  bresp_expslv0_axis;
output        bvalid_expslv0_axis;
input         bready_expslv0_axis;
input  [7:0]  arid_expslv0_axis;
input  [31:0] araddr_expslv0_axis;
input  [7:0]  arlen_expslv0_axis;
input  [2:0]  arsize_expslv0_axis;
input  [1:0]  arburst_expslv0_axis;
input         arlock_expslv0_axis;
input  [3:0]  arcache_expslv0_axis;
input  [2:0]  arprot_expslv0_axis;
input         arvalid_expslv0_axis;
output        arready_expslv0_axis;
output [7:0]  rid_expslv0_axis;
output [63:0] rdata_expslv0_axis;
output [1:0]  rresp_expslv0_axis;
output        rlast_expslv0_axis;
output        rvalid_expslv0_axis;
input         rready_expslv0_axis;
input  [9:0]  awuser_expslv0_axis;
output        buser_expslv0_axis;
input  [9:0]  aruser_expslv0_axis;
output        ruser_expslv0_axis;
input  [3:0]  awqos_expslv0_axis;
input  [3:0]  arqos_expslv0_axis;


input  [7:0]  awid_expslv1_axis;
input  [31:0] awaddr_expslv1_axis;
input  [7:0]  awlen_expslv1_axis;
input  [2:0]  awsize_expslv1_axis;
input  [1:0]  awburst_expslv1_axis;
input         awlock_expslv1_axis;
input  [3:0]  awcache_expslv1_axis;
input  [2:0]  awprot_expslv1_axis;
input         awvalid_expslv1_axis;
output        awready_expslv1_axis;
input  [63:0] wdata_expslv1_axis;
input  [7:0]  wstrb_expslv1_axis;
input         wlast_expslv1_axis;
input         wvalid_expslv1_axis;
output        wready_expslv1_axis;
output [7:0]  bid_expslv1_axis;
output [1:0]  bresp_expslv1_axis;
output        bvalid_expslv1_axis;
input         bready_expslv1_axis;
input  [7:0]  arid_expslv1_axis;
input  [31:0] araddr_expslv1_axis;
input  [7:0]  arlen_expslv1_axis;
input  [2:0]  arsize_expslv1_axis;
input  [1:0]  arburst_expslv1_axis;
input         arlock_expslv1_axis;
input  [3:0]  arcache_expslv1_axis;
input  [2:0]  arprot_expslv1_axis;
input         arvalid_expslv1_axis;
output        arready_expslv1_axis;
output [7:0]  rid_expslv1_axis;
output [63:0] rdata_expslv1_axis;
output [1:0]  rresp_expslv1_axis;
output        rlast_expslv1_axis;
output        rvalid_expslv1_axis;
input         rready_expslv1_axis;
input  [9:0]  awuser_expslv1_axis;
output        buser_expslv1_axis;
input  [9:0]  aruser_expslv1_axis;
output        ruser_expslv1_axis;
input  [3:0]  awqos_expslv1_axis;
input  [3:0]  arqos_expslv1_axis;


input  [7:0]  awid_extsys0_axis;
input  [31:0] awaddr_extsys0_axis;
input  [7:0]  awlen_extsys0_axis;
input  [2:0]  awsize_extsys0_axis;
input  [1:0]  awburst_extsys0_axis;
input         awlock_extsys0_axis;
input  [3:0]  awcache_extsys0_axis;
input  [2:0]  awprot_extsys0_axis;
input         awvalid_extsys0_axis;
output        awready_extsys0_axis;
input  [63:0] wdata_extsys0_axis;
input  [7:0]  wstrb_extsys0_axis;
input         wlast_extsys0_axis;
input         wvalid_extsys0_axis;
output        wready_extsys0_axis;
output [7:0]  bid_extsys0_axis;
output [1:0]  bresp_extsys0_axis;
output        bvalid_extsys0_axis;
input         bready_extsys0_axis;
input  [7:0]  arid_extsys0_axis;
input  [31:0] araddr_extsys0_axis;
input  [7:0]  arlen_extsys0_axis;
input  [2:0]  arsize_extsys0_axis;
input  [1:0]  arburst_extsys0_axis;
input         arlock_extsys0_axis;
input  [3:0]  arcache_extsys0_axis;
input  [2:0]  arprot_extsys0_axis;
input         arvalid_extsys0_axis;
output        arready_extsys0_axis;
output [7:0]  rid_extsys0_axis;
output [63:0] rdata_extsys0_axis;
output [1:0]  rresp_extsys0_axis;
output        rlast_extsys0_axis;
output        rvalid_extsys0_axis;
input         rready_extsys0_axis;
input  [9:0]  awuser_extsys0_axis;
output        buser_extsys0_axis;
input  [9:0]  aruser_extsys0_axis;
output        ruser_extsys0_axis;


input  [7:0]  awid_extsys1_axis;
input  [31:0] awaddr_extsys1_axis;
input  [7:0]  awlen_extsys1_axis;
input  [2:0]  awsize_extsys1_axis;
input  [1:0]  awburst_extsys1_axis;
input         awlock_extsys1_axis;
input  [3:0]  awcache_extsys1_axis;
input  [2:0]  awprot_extsys1_axis;
input         awvalid_extsys1_axis;
output        awready_extsys1_axis;
input  [63:0] wdata_extsys1_axis;
input  [7:0]  wstrb_extsys1_axis;
input         wlast_extsys1_axis;
input         wvalid_extsys1_axis;
output        wready_extsys1_axis;
output [7:0]  bid_extsys1_axis;
output [1:0]  bresp_extsys1_axis;
output        bvalid_extsys1_axis;
input         bready_extsys1_axis;
input  [7:0]  arid_extsys1_axis;
input  [31:0] araddr_extsys1_axis;
input  [7:0]  arlen_extsys1_axis;
input  [2:0]  arsize_extsys1_axis;
input  [1:0]  arburst_extsys1_axis;
input         arlock_extsys1_axis;
input  [3:0]  arcache_extsys1_axis;
input  [2:0]  arprot_extsys1_axis;
input         arvalid_extsys1_axis;
output        arready_extsys1_axis;
output [7:0]  rid_extsys1_axis;
output [63:0] rdata_extsys1_axis;
output [1:0]  rresp_extsys1_axis;
output        rlast_extsys1_axis;
output        rvalid_extsys1_axis;
input         rready_extsys1_axis;
input  [9:0]  awuser_extsys1_axis;
output        buser_extsys1_axis;
input  [9:0]  aruser_extsys1_axis;
output        ruser_extsys1_axis;


input  [7:0]  awid_hostcpu_axis;
input  [39:0] awaddr_hostcpu_axis;
input  [7:0]  awlen_hostcpu_axis;
input  [2:0]  awsize_hostcpu_axis;
input  [1:0]  awburst_hostcpu_axis;
input         awlock_hostcpu_axis;
input  [3:0]  awcache_hostcpu_axis;
input  [2:0]  awprot_hostcpu_axis;
input         awvalid_hostcpu_axis;
output        awready_hostcpu_axis;
input  [127:0] wdata_hostcpu_axis;
input  [15:0] wstrb_hostcpu_axis;
input         wlast_hostcpu_axis;
input         wvalid_hostcpu_axis;
output        wready_hostcpu_axis;
output [7:0]  bid_hostcpu_axis;
output [1:0]  bresp_hostcpu_axis;
output        bvalid_hostcpu_axis;
input         bready_hostcpu_axis;
input  [7:0]  arid_hostcpu_axis;
input  [39:0] araddr_hostcpu_axis;
input  [7:0]  arlen_hostcpu_axis;
input  [2:0]  arsize_hostcpu_axis;
input  [1:0]  arburst_hostcpu_axis;
input         arlock_hostcpu_axis;
input  [3:0]  arcache_hostcpu_axis;
input  [2:0]  arprot_hostcpu_axis;
input         arvalid_hostcpu_axis;
output        arready_hostcpu_axis;
output [7:0]  rid_hostcpu_axis;
output [127:0] rdata_hostcpu_axis;
output [1:0]  rresp_hostcpu_axis;
output        rlast_hostcpu_axis;
output        rvalid_hostcpu_axis;
input         rready_hostcpu_axis;
input  [9:0]  awuser_hostcpu_axis;
output        buser_hostcpu_axis;
input  [9:0]  aruser_hostcpu_axis;
output        ruser_hostcpu_axis;


input  [7:0]  awid_secenc_axis;
input  [39:0] awaddr_secenc_axis;
input  [7:0]  awlen_secenc_axis;
input  [2:0]  awsize_secenc_axis;
input  [1:0]  awburst_secenc_axis;
input         awlock_secenc_axis;
input  [3:0]  awcache_secenc_axis;
input  [2:0]  awprot_secenc_axis;
input         awvalid_secenc_axis;
output        awready_secenc_axis;
input  [31:0] wdata_secenc_axis;
input  [3:0]  wstrb_secenc_axis;
input         wlast_secenc_axis;
input         wvalid_secenc_axis;
output        wready_secenc_axis;
output [7:0]  bid_secenc_axis;
output [1:0]  bresp_secenc_axis;
output        bvalid_secenc_axis;
input         bready_secenc_axis;
input  [7:0]  arid_secenc_axis;
input  [39:0] araddr_secenc_axis;
input  [7:0]  arlen_secenc_axis;
input  [2:0]  arsize_secenc_axis;
input  [1:0]  arburst_secenc_axis;
input         arlock_secenc_axis;
input  [3:0]  arcache_secenc_axis;
input  [2:0]  arprot_secenc_axis;
input         arvalid_secenc_axis;
output        arready_secenc_axis;
output [7:0]  rid_secenc_axis;
output [31:0] rdata_secenc_axis;
output [1:0]  rresp_secenc_axis;
output        rlast_secenc_axis;
output        rvalid_secenc_axis;
input         rready_secenc_axis;
input  [9:0]  awuser_secenc_axis;
output        buser_secenc_axis;
input  [9:0]  aruser_secenc_axis;
output        ruser_secenc_axis;


output        cactive_cd_a;
input         csysreq_cd_a;
output        csysack_cd_a;


input  [31:0] paddr_debug_axis_ib_apb;
input  [31:0] pwdata_debug_axis_ib_apb;
input         pwrite_debug_axis_ib_apb;
input         penable_debug_axis_ib_apb;
input         pselx_debug_axis_ib_apb;
output [31:0] prdata_debug_axis_ib_apb;
output        pslverr_debug_axis_ib_apb;
output        pready_debug_axis_ib_apb;


input  [31:0] paddr_extsys0_axis_ib_apb;
input  [31:0] pwdata_extsys0_axis_ib_apb;
input         pwrite_extsys0_axis_ib_apb;
input         penable_extsys0_axis_ib_apb;
input         pselx_extsys0_axis_ib_apb;
output [31:0] prdata_extsys0_axis_ib_apb;
output        pslverr_extsys0_axis_ib_apb;
output        pready_extsys0_axis_ib_apb;


input  [31:0] paddr_extsys1_axis_ib_apb;
input  [31:0] pwdata_extsys1_axis_ib_apb;
input         pwrite_extsys1_axis_ib_apb;
input         penable_extsys1_axis_ib_apb;
input         pselx_extsys1_axis_ib_apb;
output [31:0] prdata_extsys1_axis_ib_apb;
output        pslverr_extsys1_axis_ib_apb;
output        pready_extsys1_axis_ib_apb;


output [73:0] a_data_gpv_0_ib1_int;
output        a_valid_gpv_0_ib1_int;
input         a_ready_gpv_0_ib1_int;
input  [47:0] d_data_gpv_0_ib1_int;
input         d_valid_gpv_0_ib1_int;
output        d_ready_gpv_0_ib1_int;
output [36:0] w_data_gpv_0_ib1_int;
output        w_valid_gpv_0_ib1_int;
input         w_ready_gpv_0_ib1_int;


input  [51:0] a_data_gpvmain_ahb_ib_int;
input         a_valid_gpvmain_ahb_ib_int;
output        a_ready_gpvmain_ahb_ib_int;
output [35:0] d_data_gpvmain_ahb_ib_int;
output        d_valid_gpvmain_ahb_ib_int;
input         d_ready_gpvmain_ahb_ib_int;
input  [36:0] w_data_gpvmain_ahb_ib_int;
input         w_valid_gpvmain_ahb_ib_int;
output        w_ready_gpvmain_ahb_ib_int;
input         empty_gpvmain_ahb_ib_int;


input  [31:0] paddr_hostcpu_axis_ib_apb;
input  [31:0] pwdata_hostcpu_axis_ib_apb;
input         pwrite_hostcpu_axis_ib_apb;
input         penable_hostcpu_axis_ib_apb;
input         pselx_hostcpu_axis_ib_apb;
output [31:0] prdata_hostcpu_axis_ib_apb;
output        pslverr_hostcpu_axis_ib_apb;
output        pready_hostcpu_axis_ib_apb;


input  [31:0] paddr_secenc_axis_ib_apb;
input  [31:0] pwdata_secenc_axis_ib_apb;
input         pwrite_secenc_axis_ib_apb;
input         penable_secenc_axis_ib_apb;
input         pselx_secenc_axis_ib_apb;
output [31:0] prdata_secenc_axis_ib_apb;
output        pslverr_secenc_axis_ib_apb;
output        pready_secenc_axis_ib_apb;


input         aclk;
input         aresetn;




wire   [73:0]  a_data_gpv_0_ib1_int;
wire           a_ready_gpvmain_ahb_ib_int;
wire           a_valid_gpv_0_ib1_int;
wire   [39:0]  araddr_bootreg_axim;
wire   [31:0]  araddr_cvm_axim;
wire   [31:0]  araddr_debug_axim;
wire   [31:0]  araddr_expmstr0_axim;
wire   [31:0]  araddr_expmstr1_axim;
wire   [31:0]  araddr_firewall_axim;
wire   [31:0]  araddr_ocvm_axim;
wire   [31:0]  araddr_sysctrl_axim;
wire   [31:0]  araddr_sysperi_axim;
wire   [31:0]  araddr_xnvm_axim;
wire   [1:0]   arburst_bootreg_axim;
wire   [1:0]   arburst_cvm_axim;
wire   [1:0]   arburst_debug_axim;
wire   [1:0]   arburst_expmstr0_axim;
wire   [1:0]   arburst_expmstr1_axim;
wire   [1:0]   arburst_firewall_axim;
wire   [1:0]   arburst_ocvm_axim;
wire   [1:0]   arburst_sysctrl_axim;
wire   [1:0]   arburst_sysperi_axim;
wire   [1:0]   arburst_xnvm_axim;
wire   [3:0]   arcache_bootreg_axim;
wire   [3:0]   arcache_cvm_axim;
wire   [3:0]   arcache_debug_axim;
wire   [3:0]   arcache_expmstr0_axim;
wire   [3:0]   arcache_expmstr1_axim;
wire   [3:0]   arcache_firewall_axim;
wire   [3:0]   arcache_ocvm_axim;
wire   [3:0]   arcache_sysctrl_axim;
wire   [3:0]   arcache_sysperi_axim;
wire   [3:0]   arcache_xnvm_axim;
wire   [9:0]   arid_bootreg_axim;
wire   [11:0]  arid_cvm_axim;
wire   [8:0]   arid_debug_axim;
wire   [11:0]  arid_expmstr0_axim;
wire   [11:0]  arid_expmstr1_axim;
wire   [9:0]   arid_firewall_axim;
wire   [11:0]  arid_ocvm_axim;
wire   [11:0]  arid_sysctrl_axim;
wire   [11:0]  arid_sysperi_axim;
wire   [11:0]  arid_xnvm_axim;
wire   [7:0]   arlen_bootreg_axim;
wire   [7:0]   arlen_cvm_axim;
wire   [7:0]   arlen_debug_axim;
wire   [7:0]   arlen_expmstr0_axim;
wire   [7:0]   arlen_expmstr1_axim;
wire   [7:0]   arlen_firewall_axim;
wire   [7:0]   arlen_ocvm_axim;
wire   [7:0]   arlen_sysctrl_axim;
wire   [7:0]   arlen_sysperi_axim;
wire   [7:0]   arlen_xnvm_axim;
wire           arlock_bootreg_axim;
wire           arlock_cvm_axim;
wire           arlock_debug_axim;
wire           arlock_expmstr0_axim;
wire           arlock_expmstr1_axim;
wire           arlock_firewall_axim;
wire           arlock_ocvm_axim;
wire           arlock_sysctrl_axim;
wire           arlock_sysperi_axim;
wire           arlock_xnvm_axim;
wire   [2:0]   arprot_bootreg_axim;
wire   [2:0]   arprot_cvm_axim;
wire   [2:0]   arprot_debug_axim;
wire   [2:0]   arprot_expmstr0_axim;
wire   [2:0]   arprot_expmstr1_axim;
wire   [2:0]   arprot_firewall_axim;
wire   [2:0]   arprot_ocvm_axim;
wire   [2:0]   arprot_sysctrl_axim;
wire   [2:0]   arprot_sysperi_axim;
wire   [2:0]   arprot_xnvm_axim;
wire   [3:0]   arqos_cvm_axim;
wire   [3:0]   arqos_expmstr0_axim;
wire   [3:0]   arqos_expmstr1_axim;
wire   [3:0]   arqos_ocvm_axim;
wire   [3:0]   arqos_xnvm_axim;
wire           arready_debug_axis;
wire           arready_expslv0_axis;
wire           arready_expslv1_axis;
wire           arready_extsys0_axis;
wire           arready_extsys1_axis;
wire           arready_hostcpu_axis;
wire           arready_secenc_axis;
wire   [2:0]   arsize_bootreg_axim;
wire   [2:0]   arsize_cvm_axim;
wire   [2:0]   arsize_debug_axim;
wire   [2:0]   arsize_expmstr0_axim;
wire   [2:0]   arsize_expmstr1_axim;
wire   [2:0]   arsize_firewall_axim;
wire   [2:0]   arsize_ocvm_axim;
wire   [2:0]   arsize_sysctrl_axim;
wire   [2:0]   arsize_sysperi_axim;
wire   [2:0]   arsize_xnvm_axim;
wire   [9:0]   aruser_bootreg_axim;
wire   [9:0]   aruser_cvm_axim;
wire   [9:0]   aruser_debug_axim;
wire   [9:0]   aruser_expmstr0_axim;
wire   [9:0]   aruser_expmstr1_axim;
wire   [9:0]   aruser_firewall_axim;
wire   [9:0]   aruser_ocvm_axim;
wire   [9:0]   aruser_sysctrl_axim;
wire   [9:0]   aruser_sysperi_axim;
wire   [9:0]   aruser_xnvm_axim;
wire           arvalid_bootreg_axim;
wire           arvalid_cvm_axim;
wire           arvalid_debug_axim;
wire           arvalid_expmstr0_axim;
wire           arvalid_expmstr1_axim;
wire           arvalid_firewall_axim;
wire           arvalid_ocvm_axim;
wire           arvalid_sysctrl_axim;
wire           arvalid_sysperi_axim;
wire           arvalid_xnvm_axim;
wire   [39:0]  awaddr_bootreg_axim;
wire   [31:0]  awaddr_cvm_axim;
wire   [31:0]  awaddr_debug_axim;
wire   [31:0]  awaddr_expmstr0_axim;
wire   [31:0]  awaddr_expmstr1_axim;
wire   [31:0]  awaddr_firewall_axim;
wire   [31:0]  awaddr_ocvm_axim;
wire   [31:0]  awaddr_sysctrl_axim;
wire   [31:0]  awaddr_sysperi_axim;
wire   [31:0]  awaddr_xnvm_axim;
wire   [1:0]   awburst_bootreg_axim;
wire   [1:0]   awburst_cvm_axim;
wire   [1:0]   awburst_debug_axim;
wire   [1:0]   awburst_expmstr0_axim;
wire   [1:0]   awburst_expmstr1_axim;
wire   [1:0]   awburst_firewall_axim;
wire   [1:0]   awburst_ocvm_axim;
wire   [1:0]   awburst_sysctrl_axim;
wire   [1:0]   awburst_sysperi_axim;
wire   [1:0]   awburst_xnvm_axim;
wire   [3:0]   awcache_bootreg_axim;
wire   [3:0]   awcache_cvm_axim;
wire   [3:0]   awcache_debug_axim;
wire   [3:0]   awcache_expmstr0_axim;
wire   [3:0]   awcache_expmstr1_axim;
wire   [3:0]   awcache_firewall_axim;
wire   [3:0]   awcache_ocvm_axim;
wire   [3:0]   awcache_sysctrl_axim;
wire   [3:0]   awcache_sysperi_axim;
wire   [3:0]   awcache_xnvm_axim;
wire   [9:0]   awid_bootreg_axim;
wire   [11:0]  awid_cvm_axim;
wire   [8:0]   awid_debug_axim;
wire   [11:0]  awid_expmstr0_axim;
wire   [11:0]  awid_expmstr1_axim;
wire   [9:0]   awid_firewall_axim;
wire   [11:0]  awid_ocvm_axim;
wire   [11:0]  awid_sysctrl_axim;
wire   [11:0]  awid_sysperi_axim;
wire   [11:0]  awid_xnvm_axim;
wire   [7:0]   awlen_bootreg_axim;
wire   [7:0]   awlen_cvm_axim;
wire   [7:0]   awlen_debug_axim;
wire   [7:0]   awlen_expmstr0_axim;
wire   [7:0]   awlen_expmstr1_axim;
wire   [7:0]   awlen_firewall_axim;
wire   [7:0]   awlen_ocvm_axim;
wire   [7:0]   awlen_sysctrl_axim;
wire   [7:0]   awlen_sysperi_axim;
wire   [7:0]   awlen_xnvm_axim;
wire           awlock_bootreg_axim;
wire           awlock_cvm_axim;
wire           awlock_debug_axim;
wire           awlock_expmstr0_axim;
wire           awlock_expmstr1_axim;
wire           awlock_firewall_axim;
wire           awlock_ocvm_axim;
wire           awlock_sysctrl_axim;
wire           awlock_sysperi_axim;
wire           awlock_xnvm_axim;
wire   [2:0]   awprot_bootreg_axim;
wire   [2:0]   awprot_cvm_axim;
wire   [2:0]   awprot_debug_axim;
wire   [2:0]   awprot_expmstr0_axim;
wire   [2:0]   awprot_expmstr1_axim;
wire   [2:0]   awprot_firewall_axim;
wire   [2:0]   awprot_ocvm_axim;
wire   [2:0]   awprot_sysctrl_axim;
wire   [2:0]   awprot_sysperi_axim;
wire   [2:0]   awprot_xnvm_axim;
wire   [3:0]   awqos_cvm_axim;
wire   [3:0]   awqos_expmstr0_axim;
wire   [3:0]   awqos_expmstr1_axim;
wire   [3:0]   awqos_ocvm_axim;
wire   [3:0]   awqos_xnvm_axim;
wire           awready_debug_axis;
wire           awready_expslv0_axis;
wire           awready_expslv1_axis;
wire           awready_extsys0_axis;
wire           awready_extsys1_axis;
wire           awready_hostcpu_axis;
wire           awready_secenc_axis;
wire   [2:0]   awsize_bootreg_axim;
wire   [2:0]   awsize_cvm_axim;
wire   [2:0]   awsize_debug_axim;
wire   [2:0]   awsize_expmstr0_axim;
wire   [2:0]   awsize_expmstr1_axim;
wire   [2:0]   awsize_firewall_axim;
wire   [2:0]   awsize_ocvm_axim;
wire   [2:0]   awsize_sysctrl_axim;
wire   [2:0]   awsize_sysperi_axim;
wire   [2:0]   awsize_xnvm_axim;
wire   [9:0]   awuser_bootreg_axim;
wire   [9:0]   awuser_cvm_axim;
wire   [9:0]   awuser_debug_axim;
wire   [9:0]   awuser_expmstr0_axim;
wire   [9:0]   awuser_expmstr1_axim;
wire   [9:0]   awuser_firewall_axim;
wire   [9:0]   awuser_ocvm_axim;
wire   [9:0]   awuser_sysctrl_axim;
wire   [9:0]   awuser_sysperi_axim;
wire   [9:0]   awuser_xnvm_axim;
wire           awvalid_bootreg_axim;
wire           awvalid_cvm_axim;
wire           awvalid_debug_axim;
wire           awvalid_expmstr0_axim;
wire           awvalid_expmstr1_axim;
wire           awvalid_firewall_axim;
wire           awvalid_ocvm_axim;
wire           awvalid_sysctrl_axim;
wire           awvalid_sysperi_axim;
wire           awvalid_xnvm_axim;
wire   [3:0]   bid_debug_axis;
wire   [7:0]   bid_expslv0_axis;
wire   [7:0]   bid_expslv1_axis;
wire   [7:0]   bid_extsys0_axis;
wire   [7:0]   bid_extsys1_axis;
wire   [7:0]   bid_hostcpu_axis;
wire   [7:0]   bid_secenc_axis;
wire           bready_bootreg_axim;
wire           bready_cvm_axim;
wire           bready_debug_axim;
wire           bready_expmstr0_axim;
wire           bready_expmstr1_axim;
wire           bready_firewall_axim;
wire           bready_ocvm_axim;
wire           bready_sysctrl_axim;
wire           bready_sysperi_axim;
wire           bready_xnvm_axim;
wire   [1:0]   bresp_debug_axis;
wire   [1:0]   bresp_expslv0_axis;
wire   [1:0]   bresp_expslv1_axis;
wire   [1:0]   bresp_extsys0_axis;
wire   [1:0]   bresp_extsys1_axis;
wire   [1:0]   bresp_hostcpu_axis;
wire   [1:0]   bresp_secenc_axis;
wire           buser_debug_axis;
wire           buser_expslv0_axis;
wire           buser_expslv1_axis;
wire           buser_extsys0_axis;
wire           buser_extsys1_axis;
wire           buser_hostcpu_axis;
wire           buser_secenc_axis;
wire           bvalid_debug_axis;
wire           bvalid_expslv0_axis;
wire           bvalid_expslv1_axis;
wire           bvalid_extsys0_axis;
wire           bvalid_extsys1_axis;
wire           bvalid_hostcpu_axis;
wire           bvalid_secenc_axis;
wire           cactive_cd_a;
wire           csysack_cd_a;
wire   [35:0]  d_data_gpvmain_ahb_ib_int;
wire           d_ready_gpv_0_ib1_int;
wire           d_valid_gpvmain_ahb_ib_int;
wire   [31:0]  prdata_debug_axis_ib_apb;
wire   [31:0]  prdata_extsys0_axis_ib_apb;
wire   [31:0]  prdata_extsys1_axis_ib_apb;
wire   [31:0]  prdata_hostcpu_axis_ib_apb;
wire   [31:0]  prdata_secenc_axis_ib_apb;
wire           pready_debug_axis_ib_apb;
wire           pready_extsys0_axis_ib_apb;
wire           pready_extsys1_axis_ib_apb;
wire           pready_hostcpu_axis_ib_apb;
wire           pready_secenc_axis_ib_apb;
wire           pslverr_debug_axis_ib_apb;
wire           pslverr_extsys0_axis_ib_apb;
wire           pslverr_extsys1_axis_ib_apb;
wire           pslverr_hostcpu_axis_ib_apb;
wire           pslverr_secenc_axis_ib_apb;
wire   [63:0]  rdata_debug_axis;
wire   [63:0]  rdata_expslv0_axis;
wire   [63:0]  rdata_expslv1_axis;
wire   [63:0]  rdata_extsys0_axis;
wire   [63:0]  rdata_extsys1_axis;
wire   [127:0] rdata_hostcpu_axis;
wire   [31:0]  rdata_secenc_axis;
wire   [3:0]   rid_debug_axis;
wire   [7:0]   rid_expslv0_axis;
wire   [7:0]   rid_expslv1_axis;
wire   [7:0]   rid_extsys0_axis;
wire   [7:0]   rid_extsys1_axis;
wire   [7:0]   rid_hostcpu_axis;
wire   [7:0]   rid_secenc_axis;
wire           rlast_debug_axis;
wire           rlast_expslv0_axis;
wire           rlast_expslv1_axis;
wire           rlast_extsys0_axis;
wire           rlast_extsys1_axis;
wire           rlast_hostcpu_axis;
wire           rlast_secenc_axis;
wire           rready_bootreg_axim;
wire           rready_cvm_axim;
wire           rready_debug_axim;
wire           rready_expmstr0_axim;
wire           rready_expmstr1_axim;
wire           rready_firewall_axim;
wire           rready_ocvm_axim;
wire           rready_sysctrl_axim;
wire           rready_sysperi_axim;
wire           rready_xnvm_axim;
wire   [1:0]   rresp_debug_axis;
wire   [1:0]   rresp_expslv0_axis;
wire   [1:0]   rresp_expslv1_axis;
wire   [1:0]   rresp_extsys0_axis;
wire   [1:0]   rresp_extsys1_axis;
wire   [1:0]   rresp_hostcpu_axis;
wire   [1:0]   rresp_secenc_axis;
wire           ruser_debug_axis;
wire           ruser_expslv0_axis;
wire           ruser_expslv1_axis;
wire           ruser_extsys0_axis;
wire           ruser_extsys1_axis;
wire           ruser_hostcpu_axis;
wire           ruser_secenc_axis;
wire           rvalid_debug_axis;
wire           rvalid_expslv0_axis;
wire           rvalid_expslv1_axis;
wire           rvalid_extsys0_axis;
wire           rvalid_extsys1_axis;
wire           rvalid_hostcpu_axis;
wire           rvalid_secenc_axis;
wire   [36:0]  w_data_gpv_0_ib1_int;
wire           w_ready_gpvmain_ahb_ib_int;
wire           w_valid_gpv_0_ib1_int;
wire   [31:0]  wdata_bootreg_axim;
wire   [63:0]  wdata_cvm_axim;
wire   [31:0]  wdata_debug_axim;
wire   [63:0]  wdata_expmstr0_axim;
wire   [63:0]  wdata_expmstr1_axim;
wire   [31:0]  wdata_firewall_axim;
wire   [63:0]  wdata_ocvm_axim;
wire   [31:0]  wdata_sysctrl_axim;
wire   [31:0]  wdata_sysperi_axim;
wire   [63:0]  wdata_xnvm_axim;
wire           wlast_bootreg_axim;
wire           wlast_cvm_axim;
wire           wlast_debug_axim;
wire           wlast_expmstr0_axim;
wire           wlast_expmstr1_axim;
wire           wlast_firewall_axim;
wire           wlast_ocvm_axim;
wire           wlast_sysctrl_axim;
wire           wlast_sysperi_axim;
wire           wlast_xnvm_axim;
wire           wready_debug_axis;
wire           wready_expslv0_axis;
wire           wready_expslv1_axis;
wire           wready_extsys0_axis;
wire           wready_extsys1_axis;
wire           wready_hostcpu_axis;
wire           wready_secenc_axis;
wire   [3:0]   wstrb_bootreg_axim;
wire   [7:0]   wstrb_cvm_axim;
wire   [3:0]   wstrb_debug_axim;
wire   [7:0]   wstrb_expmstr0_axim;
wire   [7:0]   wstrb_expmstr1_axim;
wire   [3:0]   wstrb_firewall_axim;
wire   [7:0]   wstrb_ocvm_axim;
wire   [3:0]   wstrb_sysctrl_axim;
wire   [3:0]   wstrb_sysperi_axim;
wire   [7:0]   wstrb_xnvm_axim;
wire           wvalid_bootreg_axim;
wire           wvalid_cvm_axim;
wire           wvalid_debug_axim;
wire           wvalid_expmstr0_axim;
wire           wvalid_expmstr1_axim;
wire           wvalid_firewall_axim;
wire           wvalid_ocvm_axim;
wire           wvalid_sysctrl_axim;
wire           wvalid_sysperi_axim;
wire           wvalid_xnvm_axim;
wire           arready_switch3_bootreg_axim_bootreg_axim_s;
wire           awready_switch3_bootreg_axim_bootreg_axim_s;
wire   [11:0]  bid_switch3_bootreg_axim_bootreg_axim_s;
wire   [1:0]   bresp_switch3_bootreg_axim_bootreg_axim_s;
wire           bvalid_switch3_bootreg_axim_bootreg_axim_s;
wire   [31:0]  rdata_switch3_bootreg_axim_bootreg_axim_s;
wire   [11:0]  rid_switch3_bootreg_axim_bootreg_axim_s;
wire           rlast_switch3_bootreg_axim_bootreg_axim_s;
wire   [1:0]   rresp_switch3_bootreg_axim_bootreg_axim_s;
wire           rvalid_switch3_bootreg_axim_bootreg_axim_s;
wire           wready_switch3_bootreg_axim_bootreg_axim_s;
wire           arready_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire           awready_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [11:0]  bid_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [1:0]   bresp_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire           buser_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire           bvalid_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [63:0]  rdata_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [11:0]  rid_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire           rlast_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [1:0]   rresp_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire           ruser_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire           rvalid_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire           wready_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire           arready_debug_axim_ib_debug_axim_debug_axim_s;
wire           awready_debug_axim_ib_debug_axim_debug_axim_s;
wire   [11:0]  bid_debug_axim_ib_debug_axim_debug_axim_s;
wire   [1:0]   bresp_debug_axim_ib_debug_axim_debug_axim_s;
wire           buser_debug_axim_ib_debug_axim_debug_axim_s;
wire           bvalid_debug_axim_ib_debug_axim_debug_axim_s;
wire   [31:0]  rdata_debug_axim_ib_debug_axim_debug_axim_s;
wire   [11:0]  rid_debug_axim_ib_debug_axim_debug_axim_s;
wire           rlast_debug_axim_ib_debug_axim_debug_axim_s;
wire   [1:0]   rresp_debug_axim_ib_debug_axim_debug_axim_s;
wire           ruser_debug_axim_ib_debug_axim_debug_axim_s;
wire           rvalid_debug_axim_ib_debug_axim_debug_axim_s;
wire           wready_debug_axim_ib_debug_axim_debug_axim_s;
wire           arready_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire           awready_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [11:0]  bid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [1:0]   bresp_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire           buser_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire           bvalid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [63:0]  rdata_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [11:0]  rid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire           rlast_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [1:0]   rresp_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire           ruser_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire           rvalid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire           wready_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire           arready_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire           awready_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [11:0]  bid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [1:0]   bresp_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire           buser_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire           bvalid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [63:0]  rdata_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [11:0]  rid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire           rlast_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [1:0]   rresp_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire           ruser_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire           rvalid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire           wready_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire           arready_switch3_firewall_axim_firewall_axim_s;
wire           awready_switch3_firewall_axim_firewall_axim_s;
wire   [11:0]  bid_switch3_firewall_axim_firewall_axim_s;
wire   [1:0]   bresp_switch3_firewall_axim_firewall_axim_s;
wire           buser_switch3_firewall_axim_firewall_axim_s;
wire           bvalid_switch3_firewall_axim_firewall_axim_s;
wire   [31:0]  rdata_switch3_firewall_axim_firewall_axim_s;
wire   [11:0]  rid_switch3_firewall_axim_firewall_axim_s;
wire           rlast_switch3_firewall_axim_firewall_axim_s;
wire   [1:0]   rresp_switch3_firewall_axim_firewall_axim_s;
wire           ruser_switch3_firewall_axim_firewall_axim_s;
wire           rvalid_switch3_firewall_axim_firewall_axim_s;
wire           wready_switch3_firewall_axim_firewall_axim_s;
wire           arready_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire           awready_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [11:0]  bid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [1:0]   bresp_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire           buser_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire           bvalid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [63:0]  rdata_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [11:0]  rid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire           rlast_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [1:0]   rresp_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire           ruser_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire           rvalid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire           wready_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire           arready_switch3_sysctrl_axim_sysctrl_axim_s;
wire           awready_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [11:0]  bid_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [1:0]   bresp_switch3_sysctrl_axim_sysctrl_axim_s;
wire           buser_switch3_sysctrl_axim_sysctrl_axim_s;
wire           bvalid_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [31:0]  rdata_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [11:0]  rid_switch3_sysctrl_axim_sysctrl_axim_s;
wire           rlast_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [1:0]   rresp_switch3_sysctrl_axim_sysctrl_axim_s;
wire           ruser_switch3_sysctrl_axim_sysctrl_axim_s;
wire           rvalid_switch3_sysctrl_axim_sysctrl_axim_s;
wire           wready_switch3_sysctrl_axim_sysctrl_axim_s;
wire           arready_switch3_sysperi_axim_sysperi_axim_s;
wire           awready_switch3_sysperi_axim_sysperi_axim_s;
wire   [11:0]  bid_switch3_sysperi_axim_sysperi_axim_s;
wire   [1:0]   bresp_switch3_sysperi_axim_sysperi_axim_s;
wire           buser_switch3_sysperi_axim_sysperi_axim_s;
wire           bvalid_switch3_sysperi_axim_sysperi_axim_s;
wire   [31:0]  rdata_switch3_sysperi_axim_sysperi_axim_s;
wire   [11:0]  rid_switch3_sysperi_axim_sysperi_axim_s;
wire           rlast_switch3_sysperi_axim_sysperi_axim_s;
wire   [1:0]   rresp_switch3_sysperi_axim_sysperi_axim_s;
wire           ruser_switch3_sysperi_axim_sysperi_axim_s;
wire           rvalid_switch3_sysperi_axim_sysperi_axim_s;
wire           wready_switch3_sysperi_axim_sysperi_axim_s;
wire           arready_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire           awready_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [11:0]  bid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [1:0]   bresp_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire           buser_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire           bvalid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [63:0]  rdata_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [11:0]  rid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire           rlast_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [1:0]   rresp_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire           ruser_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire           rvalid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire           wready_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [31:0]  araddr_debug_axis_debug_axis_ib_axi4_s;
wire   [1:0]   arburst_debug_axis_debug_axis_ib_axi4_s;
wire   [3:0]   arcache_debug_axis_debug_axis_ib_axi4_s;
wire   [3:0]   arid_debug_axis_debug_axis_ib_axi4_s;
wire   [7:0]   arlen_debug_axis_debug_axis_ib_axi4_s;
wire           arlock_debug_axis_debug_axis_ib_axi4_s;
wire   [2:0]   arprot_debug_axis_debug_axis_ib_axi4_s;
wire   [2:0]   arsize_debug_axis_debug_axis_ib_axi4_s;
wire   [9:0]   aruser_debug_axis_debug_axis_ib_axi4_s;
wire           arvalid_debug_axis_debug_axis_ib_axi4_s;
wire   [9:0]   arvalid_vect_debug_axis_debug_axis_ib_axi4_s;
wire   [31:0]  awaddr_debug_axis_debug_axis_ib_axi4_s;
wire   [1:0]   awburst_debug_axis_debug_axis_ib_axi4_s;
wire   [3:0]   awcache_debug_axis_debug_axis_ib_axi4_s;
wire   [3:0]   awid_debug_axis_debug_axis_ib_axi4_s;
wire   [7:0]   awlen_debug_axis_debug_axis_ib_axi4_s;
wire           awlock_debug_axis_debug_axis_ib_axi4_s;
wire   [2:0]   awprot_debug_axis_debug_axis_ib_axi4_s;
wire   [2:0]   awsize_debug_axis_debug_axis_ib_axi4_s;
wire   [9:0]   awuser_debug_axis_debug_axis_ib_axi4_s;
wire           awvalid_debug_axis_debug_axis_ib_axi4_s;
wire   [9:0]   awvalid_vect_debug_axis_debug_axis_ib_axi4_s;
wire           bready_debug_axis_debug_axis_ib_axi4_s;
wire           cactive_debug_axis_hcg;
wire           cactive_debug_axis_wakeup_hcg;
wire   [31:0]  prdata_debug_axis_apb;
wire           pready_debug_axis_apb;
wire           pslverr_debug_axis_apb;
wire           rready_debug_axis_debug_axis_ib_axi4_s;
wire   [63:0]  wdata_debug_axis_debug_axis_ib_axi4_s;
wire           wlast_debug_axis_debug_axis_ib_axi4_s;
wire   [7:0]   wstrb_debug_axis_debug_axis_ib_axi4_s;
wire           wvalid_debug_axis_debug_axis_ib_axi4_s;
wire   [31:0]  araddr_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [1:0]   arburst_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [3:0]   arcache_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [7:0]   arid_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [7:0]   arlen_expslv0_axis_expslv0_axis_ib_axi4_s;
wire           arlock_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [2:0]   arprot_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [3:0]   arqv_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [2:0]   arsize_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [9:0]   aruser_expslv0_axis_expslv0_axis_ib_axi4_s;
wire           arvalid_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [9:0]   arvalid_vect_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [31:0]  awaddr_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [1:0]   awburst_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [3:0]   awcache_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [7:0]   awid_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [7:0]   awlen_expslv0_axis_expslv0_axis_ib_axi4_s;
wire           awlock_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [2:0]   awprot_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [3:0]   awqv_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [2:0]   awsize_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [9:0]   awuser_expslv0_axis_expslv0_axis_ib_axi4_s;
wire           awvalid_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [9:0]   awvalid_vect_expslv0_axis_expslv0_axis_ib_axi4_s;
wire           bready_expslv0_axis_expslv0_axis_ib_axi4_s;
wire           cactive_expslv0_axis_hcg;
wire           cactive_expslv0_axis_wakeup_hcg;
wire           rready_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [63:0]  wdata_expslv0_axis_expslv0_axis_ib_axi4_s;
wire           wlast_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [7:0]   wstrb_expslv0_axis_expslv0_axis_ib_axi4_s;
wire           wvalid_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [31:0]  araddr_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [1:0]   arburst_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [3:0]   arcache_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [7:0]   arid_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [7:0]   arlen_expslv1_axis_expslv1_axis_ib_axi4_s;
wire           arlock_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [2:0]   arprot_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [3:0]   arqv_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [2:0]   arsize_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [9:0]   aruser_expslv1_axis_expslv1_axis_ib_axi4_s;
wire           arvalid_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [9:0]   arvalid_vect_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [31:0]  awaddr_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [1:0]   awburst_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [3:0]   awcache_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [7:0]   awid_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [7:0]   awlen_expslv1_axis_expslv1_axis_ib_axi4_s;
wire           awlock_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [2:0]   awprot_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [3:0]   awqv_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [2:0]   awsize_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [9:0]   awuser_expslv1_axis_expslv1_axis_ib_axi4_s;
wire           awvalid_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [9:0]   awvalid_vect_expslv1_axis_expslv1_axis_ib_axi4_s;
wire           bready_expslv1_axis_expslv1_axis_ib_axi4_s;
wire           cactive_expslv1_axis_hcg;
wire           cactive_expslv1_axis_wakeup_hcg;
wire           rready_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [63:0]  wdata_expslv1_axis_expslv1_axis_ib_axi4_s;
wire           wlast_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [7:0]   wstrb_expslv1_axis_expslv1_axis_ib_axi4_s;
wire           wvalid_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [31:0]  araddr_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [1:0]   arburst_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [3:0]   arcache_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [7:0]   arid_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [7:0]   arlen_extsys0_axis_extsys0_axis_ib_axi4_s;
wire           arlock_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [2:0]   arprot_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [2:0]   arsize_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [9:0]   aruser_extsys0_axis_extsys0_axis_ib_axi4_s;
wire           arvalid_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [9:0]   arvalid_vect_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [31:0]  awaddr_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [1:0]   awburst_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [3:0]   awcache_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [7:0]   awid_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [7:0]   awlen_extsys0_axis_extsys0_axis_ib_axi4_s;
wire           awlock_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [2:0]   awprot_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [2:0]   awsize_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [9:0]   awuser_extsys0_axis_extsys0_axis_ib_axi4_s;
wire           awvalid_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [9:0]   awvalid_vect_extsys0_axis_extsys0_axis_ib_axi4_s;
wire           bready_extsys0_axis_extsys0_axis_ib_axi4_s;
wire           cactive_extsys0_axis_hcg;
wire           cactive_extsys0_axis_wakeup_hcg;
wire   [31:0]  prdata_extsys0_axis_apb;
wire           pready_extsys0_axis_apb;
wire           pslverr_extsys0_axis_apb;
wire           rready_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [63:0]  wdata_extsys0_axis_extsys0_axis_ib_axi4_s;
wire           wlast_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [7:0]   wstrb_extsys0_axis_extsys0_axis_ib_axi4_s;
wire           wvalid_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [31:0]  araddr_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [1:0]   arburst_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [3:0]   arcache_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [7:0]   arid_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [7:0]   arlen_extsys1_axis_extsys1_axis_ib_axi4_s;
wire           arlock_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [2:0]   arprot_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [2:0]   arsize_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [9:0]   aruser_extsys1_axis_extsys1_axis_ib_axi4_s;
wire           arvalid_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [9:0]   arvalid_vect_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [31:0]  awaddr_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [1:0]   awburst_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [3:0]   awcache_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [7:0]   awid_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [7:0]   awlen_extsys1_axis_extsys1_axis_ib_axi4_s;
wire           awlock_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [2:0]   awprot_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [2:0]   awsize_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [9:0]   awuser_extsys1_axis_extsys1_axis_ib_axi4_s;
wire           awvalid_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [9:0]   awvalid_vect_extsys1_axis_extsys1_axis_ib_axi4_s;
wire           bready_extsys1_axis_extsys1_axis_ib_axi4_s;
wire           cactive_extsys1_axis_hcg;
wire           cactive_extsys1_axis_wakeup_hcg;
wire   [31:0]  prdata_extsys1_axis_apb;
wire           pready_extsys1_axis_apb;
wire           pslverr_extsys1_axis_apb;
wire           rready_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [63:0]  wdata_extsys1_axis_extsys1_axis_ib_axi4_s;
wire           wlast_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [7:0]   wstrb_extsys1_axis_extsys1_axis_ib_axi4_s;
wire           wvalid_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [39:0]  araddr_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [1:0]   arburst_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [3:0]   arcache_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [7:0]   arid_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [7:0]   arlen_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire           arlock_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [2:0]   arprot_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [2:0]   arsize_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [9:0]   aruser_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire           arvalid_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [10:0]  arvalid_vect_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [39:0]  awaddr_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [1:0]   awburst_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [3:0]   awcache_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [7:0]   awid_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [7:0]   awlen_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire           awlock_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [2:0]   awprot_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [2:0]   awsize_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [9:0]   awuser_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire           awvalid_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [10:0]  awvalid_vect_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire           bready_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire           cactive_hostcpu_axis_hcg;
wire           cactive_hostcpu_axis_wakeup_hcg;
wire   [31:0]  prdata_hostcpu_axis_apb;
wire           pready_hostcpu_axis_apb;
wire           pslverr_hostcpu_axis_apb;
wire           rready_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [127:0] wdata_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire           wlast_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [15:0]  wstrb_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire           wvalid_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [39:0]  araddr_secenc_axis_secenc_axis_ib_axi4_s;
wire   [1:0]   arburst_secenc_axis_secenc_axis_ib_axi4_s;
wire   [3:0]   arcache_secenc_axis_secenc_axis_ib_axi4_s;
wire   [7:0]   arid_secenc_axis_secenc_axis_ib_axi4_s;
wire   [7:0]   arlen_secenc_axis_secenc_axis_ib_axi4_s;
wire           arlock_secenc_axis_secenc_axis_ib_axi4_s;
wire   [2:0]   arprot_secenc_axis_secenc_axis_ib_axi4_s;
wire   [2:0]   arsize_secenc_axis_secenc_axis_ib_axi4_s;
wire   [9:0]   aruser_secenc_axis_secenc_axis_ib_axi4_s;
wire           arvalid_secenc_axis_secenc_axis_ib_axi4_s;
wire   [10:0]  arvalid_vect_secenc_axis_secenc_axis_ib_axi4_s;
wire   [39:0]  awaddr_secenc_axis_secenc_axis_ib_axi4_s;
wire   [1:0]   awburst_secenc_axis_secenc_axis_ib_axi4_s;
wire   [3:0]   awcache_secenc_axis_secenc_axis_ib_axi4_s;
wire   [7:0]   awid_secenc_axis_secenc_axis_ib_axi4_s;
wire   [7:0]   awlen_secenc_axis_secenc_axis_ib_axi4_s;
wire           awlock_secenc_axis_secenc_axis_ib_axi4_s;
wire   [2:0]   awprot_secenc_axis_secenc_axis_ib_axi4_s;
wire   [2:0]   awsize_secenc_axis_secenc_axis_ib_axi4_s;
wire   [9:0]   awuser_secenc_axis_secenc_axis_ib_axi4_s;
wire           awvalid_secenc_axis_secenc_axis_ib_axi4_s;
wire   [10:0]  awvalid_vect_secenc_axis_secenc_axis_ib_axi4_s;
wire           bready_secenc_axis_secenc_axis_ib_axi4_s;
wire   [31:0]  prdata_secenc_axis_apb;
wire           pready_secenc_axis_apb;
wire           pslverr_secenc_axis_apb;
wire           rready_secenc_axis_secenc_axis_ib_axi4_s;
wire           cactive_secenc_axis_hcg;
wire           cactive_secenc_axis_wakeup_hcg;
wire   [31:0]  wdata_secenc_axis_secenc_axis_ib_axi4_s;
wire           wlast_secenc_axis_secenc_axis_ib_axi4_s;
wire   [3:0]   wstrb_secenc_axis_secenc_axis_ib_axi4_s;
wire           wvalid_secenc_axis_secenc_axis_ib_axi4_s;
wire   [3:0]   arqv_switch1_ib1_axi_s_0;
wire   [39:0]  araddr_switch1_gpv_0_ib1_axi4_s;
wire   [39:0]  araddr_switch1_ib1_axi_s_0;
wire   [1:0]   arburst_switch1_gpv_0_ib1_axi4_s;
wire   [1:0]   arburst_switch1_ib1_axi_s_0;
wire   [3:0]   arcache_switch1_gpv_0_ib1_axi4_s;
wire   [3:0]   arcache_switch1_ib1_axi_s_0;
wire   [11:0]  arid_switch1_gpv_0_ib1_axi4_s;
wire   [11:0]  arid_switch1_ds_2_axi_s_0;
wire   [11:0]  arid_switch1_ib1_axi_s_0;
wire   [7:0]   arlen_switch1_gpv_0_ib1_axi4_s;
wire   [7:0]   arlen_switch1_ds_2_axi_s_0;
wire   [7:0]   arlen_switch1_ib1_axi_s_0;
wire           arlock_switch1_gpv_0_ib1_axi4_s;
wire           arlock_switch1_ib1_axi_s_0;
wire   [2:0]   arprot_switch1_gpv_0_ib1_axi4_s;
wire   [2:0]   arprot_switch1_ib1_axi_s_0;
wire           arready_secenc_axis_ib_switch1_axi_s_0;
wire           arready_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [2:0]   arsize_switch1_gpv_0_ib1_axi4_s;
wire   [2:0]   arsize_switch1_ib1_axi_s_0;
wire   [9:0]   aruser_switch1_ib1_axi_s_0;
wire           arvalid_switch1_gpv_0_ib1_axi4_s;
wire           arvalid_switch1_ds_2_axi_s_0;
wire           arvalid_switch1_ib1_axi_s_0;
wire   [9:0]   arvalid_vect_switch1_ib1_axi_s_0;
wire   [3:0]   awqv_switch1_ib1_axi_s_0;
wire   [39:0]  awaddr_switch1_gpv_0_ib1_axi4_s;
wire   [39:0]  awaddr_switch1_ib1_axi_s_0;
wire   [1:0]   awburst_switch1_gpv_0_ib1_axi4_s;
wire   [1:0]   awburst_switch1_ib1_axi_s_0;
wire   [3:0]   awcache_switch1_gpv_0_ib1_axi4_s;
wire   [3:0]   awcache_switch1_ib1_axi_s_0;
wire   [11:0]  awid_switch1_gpv_0_ib1_axi4_s;
wire   [11:0]  awid_switch1_ds_2_axi_s_0;
wire   [11:0]  awid_switch1_ib1_axi_s_0;
wire   [7:0]   awlen_switch1_gpv_0_ib1_axi4_s;
wire   [7:0]   awlen_switch1_ib1_axi_s_0;
wire           awlock_switch1_gpv_0_ib1_axi4_s;
wire           awlock_switch1_ib1_axi_s_0;
wire   [2:0]   awprot_switch1_gpv_0_ib1_axi4_s;
wire   [2:0]   awprot_switch1_ib1_axi_s_0;
wire           awready_secenc_axis_ib_switch1_axi_s_0;
wire           awready_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [2:0]   awsize_switch1_gpv_0_ib1_axi4_s;
wire   [2:0]   awsize_switch1_ib1_axi_s_0;
wire   [9:0]   awuser_switch1_ib1_axi_s_0;
wire           awvalid_switch1_gpv_0_ib1_axi4_s;
wire           awvalid_switch1_ds_2_axi_s_0;
wire           awvalid_switch1_ib1_axi_s_0;
wire   [9:0]   awvalid_vect_switch1_ib1_axi_s_0;
wire   [11:0]  bid_secenc_axis_ib_switch1_axi_s_0;
wire   [11:0]  bid_gpvmain_ahb_ib_switch1_axi_s_5;
wire           bready_switch1_gpv_0_ib1_axi4_s;
wire           bready_switch1_ds_2_axi_s_0;
wire           bready_switch1_ib1_axi_s_0;
wire   [1:0]   bresp_secenc_axis_ib_switch1_axi_s_0;
wire   [1:0]   bresp_gpvmain_ahb_ib_switch1_axi_s_5;
wire           buser_secenc_axis_ib_switch1_axi_s_0;
wire           bvalid_secenc_axis_ib_switch1_axi_s_0;
wire           bvalid_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [31:0]  rdata_secenc_axis_ib_switch1_axi_s_0;
wire   [31:0]  rdata_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [11:0]  rid_secenc_axis_ib_switch1_axi_s_0;
wire   [11:0]  rid_gpvmain_ahb_ib_switch1_axi_s_5;
wire           rlast_secenc_axis_ib_switch1_axi_s_0;
wire           rlast_gpvmain_ahb_ib_switch1_axi_s_5;
wire           rready_switch1_gpv_0_ib1_axi4_s;
wire           rready_switch1_ds_2_axi_s_0;
wire           rready_switch1_ib1_axi_s_0;
wire   [1:0]   rresp_secenc_axis_ib_switch1_axi_s_0;
wire   [1:0]   rresp_gpvmain_ahb_ib_switch1_axi_s_5;
wire           ruser_secenc_axis_ib_switch1_axi_s_0;
wire           rvalid_secenc_axis_ib_switch1_axi_s_0;
wire           rvalid_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [31:0]  wdata_switch1_gpv_0_ib1_axi4_s;
wire   [31:0]  wdata_switch1_ib1_axi_s_0;
wire           wlast_switch1_gpv_0_ib1_axi4_s;
wire           wlast_switch1_ds_2_axi_s_0;
wire           wlast_switch1_ib1_axi_s_0;
wire           wready_secenc_axis_ib_switch1_axi_s_0;
wire           wready_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [3:0]   wstrb_switch1_gpv_0_ib1_axi4_s;
wire   [3:0]   wstrb_switch1_ib1_axi_s_0;
wire           wvalid_switch1_gpv_0_ib1_axi4_s;
wire           wvalid_switch1_ds_2_axi_s_0;
wire           wvalid_switch1_ib1_axi_s_0;
wire   [3:0]   arqv_switch2_cvm_axim_ib_axi4_s;
wire   [3:0]   arqv_switch2_xnvm_axim_ib_axi4_s;
wire   [3:0]   arqv_switch2_expmstr0_axim_ib_axi4_s;
wire   [3:0]   arqv_switch2_expmstr1_axim_ib_axi4_s;
wire   [3:0]   arqv_switch2_ocvm_axim_ib_axi4_s;
wire   [3:0]   arqv_switch2_ib4_axi_s_0;
wire   [39:0]  araddr_switch2_debug_axim_ib_axi4_s;
wire   [39:0]  araddr_switch2_cvm_axim_ib_axi4_s;
wire   [39:0]  araddr_switch2_xnvm_axim_ib_axi4_s;
wire   [39:0]  araddr_switch2_expmstr0_axim_ib_axi4_s;
wire   [39:0]  araddr_switch2_expmstr1_axim_ib_axi4_s;
wire   [39:0]  araddr_switch2_ocvm_axim_ib_axi4_s;
wire   [39:0]  araddr_switch2_ib4_axi_s_0;
wire   [1:0]   arburst_switch2_debug_axim_ib_axi4_s;
wire   [1:0]   arburst_switch2_cvm_axim_ib_axi4_s;
wire   [1:0]   arburst_switch2_xnvm_axim_ib_axi4_s;
wire   [1:0]   arburst_switch2_expmstr0_axim_ib_axi4_s;
wire   [1:0]   arburst_switch2_expmstr1_axim_ib_axi4_s;
wire   [1:0]   arburst_switch2_ocvm_axim_ib_axi4_s;
wire   [1:0]   arburst_switch2_ib4_axi_s_0;
wire   [3:0]   arcache_switch2_debug_axim_ib_axi4_s;
wire   [3:0]   arcache_switch2_cvm_axim_ib_axi4_s;
wire   [3:0]   arcache_switch2_xnvm_axim_ib_axi4_s;
wire   [3:0]   arcache_switch2_expmstr0_axim_ib_axi4_s;
wire   [3:0]   arcache_switch2_expmstr1_axim_ib_axi4_s;
wire   [3:0]   arcache_switch2_ocvm_axim_ib_axi4_s;
wire   [3:0]   arcache_switch2_ib4_axi_s_0;
wire   [11:0]  arid_switch2_debug_axim_ib_axi4_s;
wire   [11:0]  arid_switch2_cvm_axim_ib_axi4_s;
wire   [11:0]  arid_switch2_xnvm_axim_ib_axi4_s;
wire   [11:0]  arid_switch2_expmstr0_axim_ib_axi4_s;
wire   [11:0]  arid_switch2_expmstr1_axim_ib_axi4_s;
wire   [11:0]  arid_switch2_ocvm_axim_ib_axi4_s;
wire   [11:0]  arid_switch2_ib4_axi_s_0;
wire   [11:0]  arid_switch2_ds_1_axi_s_0;
wire   [7:0]   arlen_switch2_debug_axim_ib_axi4_s;
wire   [7:0]   arlen_switch2_cvm_axim_ib_axi4_s;
wire   [7:0]   arlen_switch2_xnvm_axim_ib_axi4_s;
wire   [7:0]   arlen_switch2_expmstr0_axim_ib_axi4_s;
wire   [7:0]   arlen_switch2_expmstr1_axim_ib_axi4_s;
wire   [7:0]   arlen_switch2_ocvm_axim_ib_axi4_s;
wire   [7:0]   arlen_switch2_ib4_axi_s_0;
wire   [7:0]   arlen_switch2_ds_1_axi_s_0;
wire           arlock_switch2_debug_axim_ib_axi4_s;
wire           arlock_switch2_cvm_axim_ib_axi4_s;
wire           arlock_switch2_xnvm_axim_ib_axi4_s;
wire           arlock_switch2_expmstr0_axim_ib_axi4_s;
wire           arlock_switch2_expmstr1_axim_ib_axi4_s;
wire           arlock_switch2_ocvm_axim_ib_axi4_s;
wire           arlock_switch2_ib4_axi_s_0;
wire   [2:0]   arprot_switch2_debug_axim_ib_axi4_s;
wire   [2:0]   arprot_switch2_cvm_axim_ib_axi4_s;
wire   [2:0]   arprot_switch2_xnvm_axim_ib_axi4_s;
wire   [2:0]   arprot_switch2_expmstr0_axim_ib_axi4_s;
wire   [2:0]   arprot_switch2_expmstr1_axim_ib_axi4_s;
wire   [2:0]   arprot_switch2_ocvm_axim_ib_axi4_s;
wire   [2:0]   arprot_switch2_ib4_axi_s_0;
wire           arready_extsys0_axis_ib_switch2_axi_s_0;
wire           arready_hostcpu_axis_ib_switch2_axi_s_1;
wire           arready_extsys1_axis_ib_switch2_axi_s_2;
wire           arready_ib1_switch2_axi_s_3;
wire           arready_expslv0_axis_ib_switch2_axi_s_4;
wire           arready_expslv1_axis_ib_switch2_axi_s_5;
wire           arready_debug_axis_ib_switch2_axi_s_6;
wire   [2:0]   arsize_switch2_debug_axim_ib_axi4_s;
wire   [2:0]   arsize_switch2_cvm_axim_ib_axi4_s;
wire   [2:0]   arsize_switch2_xnvm_axim_ib_axi4_s;
wire   [2:0]   arsize_switch2_expmstr0_axim_ib_axi4_s;
wire   [2:0]   arsize_switch2_expmstr1_axim_ib_axi4_s;
wire   [2:0]   arsize_switch2_ocvm_axim_ib_axi4_s;
wire   [2:0]   arsize_switch2_ib4_axi_s_0;
wire   [9:0]   aruser_switch2_debug_axim_ib_axi4_s;
wire   [9:0]   aruser_switch2_cvm_axim_ib_axi4_s;
wire   [9:0]   aruser_switch2_xnvm_axim_ib_axi4_s;
wire   [9:0]   aruser_switch2_expmstr0_axim_ib_axi4_s;
wire   [9:0]   aruser_switch2_expmstr1_axim_ib_axi4_s;
wire   [9:0]   aruser_switch2_ocvm_axim_ib_axi4_s;
wire   [9:0]   aruser_switch2_ib4_axi_s_0;
wire           arvalid_switch2_debug_axim_ib_axi4_s;
wire           arvalid_switch2_cvm_axim_ib_axi4_s;
wire           arvalid_switch2_xnvm_axim_ib_axi4_s;
wire           arvalid_switch2_expmstr0_axim_ib_axi4_s;
wire           arvalid_switch2_expmstr1_axim_ib_axi4_s;
wire           arvalid_switch2_ocvm_axim_ib_axi4_s;
wire           arvalid_switch2_ib4_axi_s_0;
wire           arvalid_switch2_ds_1_axi_s_0;
wire   [3:0]   arvalid_vect_switch2_ib4_axi_s_0;
wire   [3:0]   awqv_switch2_cvm_axim_ib_axi4_s;
wire   [3:0]   awqv_switch2_xnvm_axim_ib_axi4_s;
wire   [3:0]   awqv_switch2_expmstr0_axim_ib_axi4_s;
wire   [3:0]   awqv_switch2_expmstr1_axim_ib_axi4_s;
wire   [3:0]   awqv_switch2_ocvm_axim_ib_axi4_s;
wire   [3:0]   awqv_switch2_ib4_axi_s_0;
wire   [39:0]  awaddr_switch2_debug_axim_ib_axi4_s;
wire   [39:0]  awaddr_switch2_cvm_axim_ib_axi4_s;
wire   [39:0]  awaddr_switch2_xnvm_axim_ib_axi4_s;
wire   [39:0]  awaddr_switch2_expmstr0_axim_ib_axi4_s;
wire   [39:0]  awaddr_switch2_expmstr1_axim_ib_axi4_s;
wire   [39:0]  awaddr_switch2_ocvm_axim_ib_axi4_s;
wire   [39:0]  awaddr_switch2_ib4_axi_s_0;
wire   [1:0]   awburst_switch2_debug_axim_ib_axi4_s;
wire   [1:0]   awburst_switch2_cvm_axim_ib_axi4_s;
wire   [1:0]   awburst_switch2_xnvm_axim_ib_axi4_s;
wire   [1:0]   awburst_switch2_expmstr0_axim_ib_axi4_s;
wire   [1:0]   awburst_switch2_expmstr1_axim_ib_axi4_s;
wire   [1:0]   awburst_switch2_ocvm_axim_ib_axi4_s;
wire   [1:0]   awburst_switch2_ib4_axi_s_0;
wire   [3:0]   awcache_switch2_debug_axim_ib_axi4_s;
wire   [3:0]   awcache_switch2_cvm_axim_ib_axi4_s;
wire   [3:0]   awcache_switch2_xnvm_axim_ib_axi4_s;
wire   [3:0]   awcache_switch2_expmstr0_axim_ib_axi4_s;
wire   [3:0]   awcache_switch2_expmstr1_axim_ib_axi4_s;
wire   [3:0]   awcache_switch2_ocvm_axim_ib_axi4_s;
wire   [3:0]   awcache_switch2_ib4_axi_s_0;
wire   [11:0]  awid_switch2_debug_axim_ib_axi4_s;
wire   [11:0]  awid_switch2_cvm_axim_ib_axi4_s;
wire   [11:0]  awid_switch2_xnvm_axim_ib_axi4_s;
wire   [11:0]  awid_switch2_expmstr0_axim_ib_axi4_s;
wire   [11:0]  awid_switch2_expmstr1_axim_ib_axi4_s;
wire   [11:0]  awid_switch2_ocvm_axim_ib_axi4_s;
wire   [11:0]  awid_switch2_ib4_axi_s_0;
wire   [11:0]  awid_switch2_ds_1_axi_s_0;
wire   [7:0]   awlen_switch2_debug_axim_ib_axi4_s;
wire   [7:0]   awlen_switch2_cvm_axim_ib_axi4_s;
wire   [7:0]   awlen_switch2_xnvm_axim_ib_axi4_s;
wire   [7:0]   awlen_switch2_expmstr0_axim_ib_axi4_s;
wire   [7:0]   awlen_switch2_expmstr1_axim_ib_axi4_s;
wire   [7:0]   awlen_switch2_ocvm_axim_ib_axi4_s;
wire   [7:0]   awlen_switch2_ib4_axi_s_0;
wire           awlock_switch2_debug_axim_ib_axi4_s;
wire           awlock_switch2_cvm_axim_ib_axi4_s;
wire           awlock_switch2_xnvm_axim_ib_axi4_s;
wire           awlock_switch2_expmstr0_axim_ib_axi4_s;
wire           awlock_switch2_expmstr1_axim_ib_axi4_s;
wire           awlock_switch2_ocvm_axim_ib_axi4_s;
wire           awlock_switch2_ib4_axi_s_0;
wire   [2:0]   awprot_switch2_debug_axim_ib_axi4_s;
wire   [2:0]   awprot_switch2_cvm_axim_ib_axi4_s;
wire   [2:0]   awprot_switch2_xnvm_axim_ib_axi4_s;
wire   [2:0]   awprot_switch2_expmstr0_axim_ib_axi4_s;
wire   [2:0]   awprot_switch2_expmstr1_axim_ib_axi4_s;
wire   [2:0]   awprot_switch2_ocvm_axim_ib_axi4_s;
wire   [2:0]   awprot_switch2_ib4_axi_s_0;
wire           awready_extsys0_axis_ib_switch2_axi_s_0;
wire           awready_hostcpu_axis_ib_switch2_axi_s_1;
wire           awready_extsys1_axis_ib_switch2_axi_s_2;
wire           awready_ib1_switch2_axi_s_3;
wire           awready_expslv0_axis_ib_switch2_axi_s_4;
wire           awready_expslv1_axis_ib_switch2_axi_s_5;
wire           awready_debug_axis_ib_switch2_axi_s_6;
wire   [2:0]   awsize_switch2_debug_axim_ib_axi4_s;
wire   [2:0]   awsize_switch2_cvm_axim_ib_axi4_s;
wire   [2:0]   awsize_switch2_xnvm_axim_ib_axi4_s;
wire   [2:0]   awsize_switch2_expmstr0_axim_ib_axi4_s;
wire   [2:0]   awsize_switch2_expmstr1_axim_ib_axi4_s;
wire   [2:0]   awsize_switch2_ocvm_axim_ib_axi4_s;
wire   [2:0]   awsize_switch2_ib4_axi_s_0;
wire   [9:0]   awuser_switch2_debug_axim_ib_axi4_s;
wire   [9:0]   awuser_switch2_cvm_axim_ib_axi4_s;
wire   [9:0]   awuser_switch2_xnvm_axim_ib_axi4_s;
wire   [9:0]   awuser_switch2_expmstr0_axim_ib_axi4_s;
wire   [9:0]   awuser_switch2_expmstr1_axim_ib_axi4_s;
wire   [9:0]   awuser_switch2_ocvm_axim_ib_axi4_s;
wire   [9:0]   awuser_switch2_ib4_axi_s_0;
wire           awvalid_switch2_debug_axim_ib_axi4_s;
wire           awvalid_switch2_cvm_axim_ib_axi4_s;
wire           awvalid_switch2_xnvm_axim_ib_axi4_s;
wire           awvalid_switch2_expmstr0_axim_ib_axi4_s;
wire           awvalid_switch2_expmstr1_axim_ib_axi4_s;
wire           awvalid_switch2_ocvm_axim_ib_axi4_s;
wire           awvalid_switch2_ib4_axi_s_0;
wire           awvalid_switch2_ds_1_axi_s_0;
wire   [3:0]   awvalid_vect_switch2_ib4_axi_s_0;
wire   [11:0]  bid_extsys0_axis_ib_switch2_axi_s_0;
wire   [11:0]  bid_hostcpu_axis_ib_switch2_axi_s_1;
wire   [11:0]  bid_extsys1_axis_ib_switch2_axi_s_2;
wire   [11:0]  bid_ib1_switch2_axi_s_3;
wire   [11:0]  bid_expslv0_axis_ib_switch2_axi_s_4;
wire   [11:0]  bid_expslv1_axis_ib_switch2_axi_s_5;
wire   [11:0]  bid_debug_axis_ib_switch2_axi_s_6;
wire           bready_switch2_debug_axim_ib_axi4_s;
wire           bready_switch2_cvm_axim_ib_axi4_s;
wire           bready_switch2_xnvm_axim_ib_axi4_s;
wire           bready_switch2_expmstr0_axim_ib_axi4_s;
wire           bready_switch2_expmstr1_axim_ib_axi4_s;
wire           bready_switch2_ocvm_axim_ib_axi4_s;
wire           bready_switch2_ib4_axi_s_0;
wire           bready_switch2_ds_1_axi_s_0;
wire   [1:0]   bresp_extsys0_axis_ib_switch2_axi_s_0;
wire   [1:0]   bresp_hostcpu_axis_ib_switch2_axi_s_1;
wire   [1:0]   bresp_extsys1_axis_ib_switch2_axi_s_2;
wire   [1:0]   bresp_ib1_switch2_axi_s_3;
wire   [1:0]   bresp_expslv0_axis_ib_switch2_axi_s_4;
wire   [1:0]   bresp_expslv1_axis_ib_switch2_axi_s_5;
wire   [1:0]   bresp_debug_axis_ib_switch2_axi_s_6;
wire           buser_extsys0_axis_ib_switch2_axi_s_0;
wire           buser_hostcpu_axis_ib_switch2_axi_s_1;
wire           buser_extsys1_axis_ib_switch2_axi_s_2;
wire           buser_ib1_switch2_axi_s_3;
wire           buser_expslv0_axis_ib_switch2_axi_s_4;
wire           buser_expslv1_axis_ib_switch2_axi_s_5;
wire           buser_debug_axis_ib_switch2_axi_s_6;
wire           bvalid_extsys0_axis_ib_switch2_axi_s_0;
wire           bvalid_hostcpu_axis_ib_switch2_axi_s_1;
wire           bvalid_extsys1_axis_ib_switch2_axi_s_2;
wire           bvalid_ib1_switch2_axi_s_3;
wire           bvalid_expslv0_axis_ib_switch2_axi_s_4;
wire           bvalid_expslv1_axis_ib_switch2_axi_s_5;
wire           bvalid_debug_axis_ib_switch2_axi_s_6;
wire   [63:0]  rdata_extsys0_axis_ib_switch2_axi_s_0;
wire   [63:0]  rdata_hostcpu_axis_ib_switch2_axi_s_1;
wire   [63:0]  rdata_extsys1_axis_ib_switch2_axi_s_2;
wire   [63:0]  rdata_ib1_switch2_axi_s_3;
wire   [63:0]  rdata_expslv0_axis_ib_switch2_axi_s_4;
wire   [63:0]  rdata_expslv1_axis_ib_switch2_axi_s_5;
wire   [63:0]  rdata_debug_axis_ib_switch2_axi_s_6;
wire   [11:0]  rid_extsys0_axis_ib_switch2_axi_s_0;
wire   [11:0]  rid_hostcpu_axis_ib_switch2_axi_s_1;
wire   [11:0]  rid_extsys1_axis_ib_switch2_axi_s_2;
wire   [11:0]  rid_ib1_switch2_axi_s_3;
wire   [11:0]  rid_expslv0_axis_ib_switch2_axi_s_4;
wire   [11:0]  rid_expslv1_axis_ib_switch2_axi_s_5;
wire   [11:0]  rid_debug_axis_ib_switch2_axi_s_6;
wire           rlast_extsys0_axis_ib_switch2_axi_s_0;
wire           rlast_hostcpu_axis_ib_switch2_axi_s_1;
wire           rlast_extsys1_axis_ib_switch2_axi_s_2;
wire           rlast_ib1_switch2_axi_s_3;
wire           rlast_expslv0_axis_ib_switch2_axi_s_4;
wire           rlast_expslv1_axis_ib_switch2_axi_s_5;
wire           rlast_debug_axis_ib_switch2_axi_s_6;
wire           rready_switch2_debug_axim_ib_axi4_s;
wire           rready_switch2_cvm_axim_ib_axi4_s;
wire           rready_switch2_xnvm_axim_ib_axi4_s;
wire           rready_switch2_expmstr0_axim_ib_axi4_s;
wire           rready_switch2_expmstr1_axim_ib_axi4_s;
wire           rready_switch2_ocvm_axim_ib_axi4_s;
wire           rready_switch2_ib4_axi_s_0;
wire           rready_switch2_ds_1_axi_s_0;
wire   [1:0]   rresp_extsys0_axis_ib_switch2_axi_s_0;
wire   [1:0]   rresp_hostcpu_axis_ib_switch2_axi_s_1;
wire   [1:0]   rresp_extsys1_axis_ib_switch2_axi_s_2;
wire   [1:0]   rresp_ib1_switch2_axi_s_3;
wire   [1:0]   rresp_expslv0_axis_ib_switch2_axi_s_4;
wire   [1:0]   rresp_expslv1_axis_ib_switch2_axi_s_5;
wire   [1:0]   rresp_debug_axis_ib_switch2_axi_s_6;
wire           ruser_extsys0_axis_ib_switch2_axi_s_0;
wire           ruser_hostcpu_axis_ib_switch2_axi_s_1;
wire           ruser_extsys1_axis_ib_switch2_axi_s_2;
wire           ruser_ib1_switch2_axi_s_3;
wire           ruser_expslv0_axis_ib_switch2_axi_s_4;
wire           ruser_expslv1_axis_ib_switch2_axi_s_5;
wire           ruser_debug_axis_ib_switch2_axi_s_6;
wire           rvalid_extsys0_axis_ib_switch2_axi_s_0;
wire           rvalid_hostcpu_axis_ib_switch2_axi_s_1;
wire           rvalid_extsys1_axis_ib_switch2_axi_s_2;
wire           rvalid_ib1_switch2_axi_s_3;
wire           rvalid_expslv0_axis_ib_switch2_axi_s_4;
wire           rvalid_expslv1_axis_ib_switch2_axi_s_5;
wire           rvalid_debug_axis_ib_switch2_axi_s_6;
wire   [63:0]  wdata_switch2_debug_axim_ib_axi4_s;
wire   [63:0]  wdata_switch2_cvm_axim_ib_axi4_s;
wire   [63:0]  wdata_switch2_xnvm_axim_ib_axi4_s;
wire   [63:0]  wdata_switch2_expmstr0_axim_ib_axi4_s;
wire   [63:0]  wdata_switch2_expmstr1_axim_ib_axi4_s;
wire   [63:0]  wdata_switch2_ocvm_axim_ib_axi4_s;
wire   [63:0]  wdata_switch2_ib4_axi_s_0;
wire           wlast_switch2_debug_axim_ib_axi4_s;
wire           wlast_switch2_cvm_axim_ib_axi4_s;
wire           wlast_switch2_xnvm_axim_ib_axi4_s;
wire           wlast_switch2_expmstr0_axim_ib_axi4_s;
wire           wlast_switch2_expmstr1_axim_ib_axi4_s;
wire           wlast_switch2_ocvm_axim_ib_axi4_s;
wire           wlast_switch2_ib4_axi_s_0;
wire           wlast_switch2_ds_1_axi_s_0;
wire           wready_extsys0_axis_ib_switch2_axi_s_0;
wire           wready_hostcpu_axis_ib_switch2_axi_s_1;
wire           wready_extsys1_axis_ib_switch2_axi_s_2;
wire           wready_ib1_switch2_axi_s_3;
wire           wready_expslv0_axis_ib_switch2_axi_s_4;
wire           wready_expslv1_axis_ib_switch2_axi_s_5;
wire           wready_debug_axis_ib_switch2_axi_s_6;
wire   [7:0]   wstrb_switch2_debug_axim_ib_axi4_s;
wire   [7:0]   wstrb_switch2_cvm_axim_ib_axi4_s;
wire   [7:0]   wstrb_switch2_xnvm_axim_ib_axi4_s;
wire   [7:0]   wstrb_switch2_expmstr0_axim_ib_axi4_s;
wire   [7:0]   wstrb_switch2_expmstr1_axim_ib_axi4_s;
wire   [7:0]   wstrb_switch2_ocvm_axim_ib_axi4_s;
wire   [7:0]   wstrb_switch2_ib4_axi_s_0;
wire           wvalid_switch2_debug_axim_ib_axi4_s;
wire           wvalid_switch2_cvm_axim_ib_axi4_s;
wire           wvalid_switch2_xnvm_axim_ib_axi4_s;
wire           wvalid_switch2_expmstr0_axim_ib_axi4_s;
wire           wvalid_switch2_expmstr1_axim_ib_axi4_s;
wire           wvalid_switch2_ocvm_axim_ib_axi4_s;
wire           wvalid_switch2_ib4_axi_s_0;
wire           wvalid_switch2_ds_1_axi_s_0;
wire   [39:0]  araddr_switch3_sysperi_axim_sysperi_axim_s;
wire   [39:0]  araddr_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [39:0]  araddr_switch3_bootreg_axim_bootreg_axim_s;
wire   [39:0]  araddr_switch3_firewall_axim_firewall_axim_s;
wire   [1:0]   arburst_switch3_sysperi_axim_sysperi_axim_s;
wire   [1:0]   arburst_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [1:0]   arburst_switch3_bootreg_axim_bootreg_axim_s;
wire   [1:0]   arburst_switch3_firewall_axim_firewall_axim_s;
wire   [3:0]   arcache_switch3_sysperi_axim_sysperi_axim_s;
wire   [3:0]   arcache_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [3:0]   arcache_switch3_bootreg_axim_bootreg_axim_s;
wire   [3:0]   arcache_switch3_firewall_axim_firewall_axim_s;
wire   [11:0]  arid_switch3_sysperi_axim_sysperi_axim_s;
wire   [11:0]  arid_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [11:0]  arid_switch3_bootreg_axim_bootreg_axim_s;
wire   [11:0]  arid_switch3_firewall_axim_firewall_axim_s;
wire   [7:0]   arlen_switch3_sysperi_axim_sysperi_axim_s;
wire   [7:0]   arlen_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [7:0]   arlen_switch3_bootreg_axim_bootreg_axim_s;
wire   [7:0]   arlen_switch3_firewall_axim_firewall_axim_s;
wire           arlock_switch3_sysperi_axim_sysperi_axim_s;
wire           arlock_switch3_sysctrl_axim_sysctrl_axim_s;
wire           arlock_switch3_bootreg_axim_bootreg_axim_s;
wire           arlock_switch3_firewall_axim_firewall_axim_s;
wire   [2:0]   arprot_switch3_sysperi_axim_sysperi_axim_s;
wire   [2:0]   arprot_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [2:0]   arprot_switch3_bootreg_axim_bootreg_axim_s;
wire   [2:0]   arprot_switch3_firewall_axim_firewall_axim_s;
wire           arready_ib4_switch3_axi_s_0;
wire   [2:0]   arsize_switch3_sysperi_axim_sysperi_axim_s;
wire   [2:0]   arsize_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [2:0]   arsize_switch3_bootreg_axim_bootreg_axim_s;
wire   [2:0]   arsize_switch3_firewall_axim_firewall_axim_s;
wire   [9:0]   aruser_switch3_sysperi_axim_sysperi_axim_s;
wire   [9:0]   aruser_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [9:0]   aruser_switch3_bootreg_axim_bootreg_axim_s;
wire   [9:0]   aruser_switch3_firewall_axim_firewall_axim_s;
wire           arvalid_switch3_sysperi_axim_sysperi_axim_s;
wire           arvalid_switch3_sysctrl_axim_sysctrl_axim_s;
wire           arvalid_switch3_bootreg_axim_bootreg_axim_s;
wire           arvalid_switch3_firewall_axim_firewall_axim_s;
wire   [39:0]  awaddr_switch3_sysperi_axim_sysperi_axim_s;
wire   [39:0]  awaddr_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [39:0]  awaddr_switch3_bootreg_axim_bootreg_axim_s;
wire   [39:0]  awaddr_switch3_firewall_axim_firewall_axim_s;
wire   [1:0]   awburst_switch3_sysperi_axim_sysperi_axim_s;
wire   [1:0]   awburst_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [1:0]   awburst_switch3_bootreg_axim_bootreg_axim_s;
wire   [1:0]   awburst_switch3_firewall_axim_firewall_axim_s;
wire   [3:0]   awcache_switch3_sysperi_axim_sysperi_axim_s;
wire   [3:0]   awcache_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [3:0]   awcache_switch3_bootreg_axim_bootreg_axim_s;
wire   [3:0]   awcache_switch3_firewall_axim_firewall_axim_s;
wire   [11:0]  awid_switch3_sysperi_axim_sysperi_axim_s;
wire   [11:0]  awid_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [11:0]  awid_switch3_bootreg_axim_bootreg_axim_s;
wire   [11:0]  awid_switch3_firewall_axim_firewall_axim_s;
wire   [7:0]   awlen_switch3_sysperi_axim_sysperi_axim_s;
wire   [7:0]   awlen_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [7:0]   awlen_switch3_bootreg_axim_bootreg_axim_s;
wire   [7:0]   awlen_switch3_firewall_axim_firewall_axim_s;
wire           awlock_switch3_sysperi_axim_sysperi_axim_s;
wire           awlock_switch3_sysctrl_axim_sysctrl_axim_s;
wire           awlock_switch3_bootreg_axim_bootreg_axim_s;
wire           awlock_switch3_firewall_axim_firewall_axim_s;
wire   [2:0]   awprot_switch3_sysperi_axim_sysperi_axim_s;
wire   [2:0]   awprot_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [2:0]   awprot_switch3_bootreg_axim_bootreg_axim_s;
wire   [2:0]   awprot_switch3_firewall_axim_firewall_axim_s;
wire           awready_ib4_switch3_axi_s_0;
wire   [2:0]   awsize_switch3_sysperi_axim_sysperi_axim_s;
wire   [2:0]   awsize_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [2:0]   awsize_switch3_bootreg_axim_bootreg_axim_s;
wire   [2:0]   awsize_switch3_firewall_axim_firewall_axim_s;
wire   [9:0]   awuser_switch3_sysperi_axim_sysperi_axim_s;
wire   [9:0]   awuser_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [9:0]   awuser_switch3_bootreg_axim_bootreg_axim_s;
wire   [9:0]   awuser_switch3_firewall_axim_firewall_axim_s;
wire           awvalid_switch3_sysperi_axim_sysperi_axim_s;
wire           awvalid_switch3_sysctrl_axim_sysctrl_axim_s;
wire           awvalid_switch3_bootreg_axim_bootreg_axim_s;
wire           awvalid_switch3_firewall_axim_firewall_axim_s;
wire   [11:0]  bid_ib4_switch3_axi_s_0;
wire           bready_switch3_sysperi_axim_sysperi_axim_s;
wire           bready_switch3_sysctrl_axim_sysctrl_axim_s;
wire           bready_switch3_bootreg_axim_bootreg_axim_s;
wire           bready_switch3_firewall_axim_firewall_axim_s;
wire   [1:0]   bresp_ib4_switch3_axi_s_0;
wire           buser_ib4_switch3_axi_s_0;
wire           bvalid_ib4_switch3_axi_s_0;
wire   [31:0]  rdata_ib4_switch3_axi_s_0;
wire   [11:0]  rid_ib4_switch3_axi_s_0;
wire           rlast_ib4_switch3_axi_s_0;
wire           rready_switch3_sysperi_axim_sysperi_axim_s;
wire           rready_switch3_sysctrl_axim_sysctrl_axim_s;
wire           rready_switch3_bootreg_axim_bootreg_axim_s;
wire           rready_switch3_firewall_axim_firewall_axim_s;
wire   [1:0]   rresp_ib4_switch3_axi_s_0;
wire           ruser_ib4_switch3_axi_s_0;
wire           rvalid_ib4_switch3_axi_s_0;
wire   [31:0]  wdata_switch3_sysperi_axim_sysperi_axim_s;
wire   [31:0]  wdata_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [31:0]  wdata_switch3_bootreg_axim_bootreg_axim_s;
wire   [31:0]  wdata_switch3_firewall_axim_firewall_axim_s;
wire           wlast_switch3_sysperi_axim_sysperi_axim_s;
wire           wlast_switch3_sysctrl_axim_sysctrl_axim_s;
wire           wlast_switch3_bootreg_axim_bootreg_axim_s;
wire           wlast_switch3_firewall_axim_firewall_axim_s;
wire           wready_ib4_switch3_axi_s_0;
wire   [3:0]   wstrb_switch3_sysperi_axim_sysperi_axim_s;
wire   [3:0]   wstrb_switch3_sysctrl_axim_sysctrl_axim_s;
wire   [3:0]   wstrb_switch3_bootreg_axim_bootreg_axim_s;
wire   [3:0]   wstrb_switch3_firewall_axim_firewall_axim_s;
wire           wvalid_switch3_sysperi_axim_sysperi_axim_s;
wire           wvalid_switch3_sysctrl_axim_sysctrl_axim_s;
wire           wvalid_switch3_bootreg_axim_bootreg_axim_s;
wire           wvalid_switch3_firewall_axim_firewall_axim_s;
wire           arready_switch2_ds_1_axi_s_0;
wire           awready_switch2_ds_1_axi_s_0;
wire   [11:0]  bid_switch2_ds_1_axi_s_0;
wire   [1:0]   bresp_switch2_ds_1_axi_s_0;
wire           bvalid_switch2_ds_1_axi_s_0;
wire   [11:0]  rid_switch2_ds_1_axi_s_0;
wire           rlast_switch2_ds_1_axi_s_0;
wire   [1:0]   rresp_switch2_ds_1_axi_s_0;
wire           rvalid_switch2_ds_1_axi_s_0;
wire           wready_switch2_ds_1_axi_s_0;
wire           arready_switch1_ds_2_axi_s_0;
wire           awready_switch1_ds_2_axi_s_0;
wire   [11:0]  bid_switch1_ds_2_axi_s_0;
wire   [1:0]   bresp_switch1_ds_2_axi_s_0;
wire           bvalid_switch1_ds_2_axi_s_0;
wire   [11:0]  rid_switch1_ds_2_axi_s_0;
wire           rlast_switch1_ds_2_axi_s_0;
wire   [1:0]   rresp_switch1_ds_2_axi_s_0;
wire           rvalid_switch1_ds_2_axi_s_0;
wire           wready_switch1_ds_2_axi_s_0;
wire           port_enable_debug_axis_port_enable_hcg;
wire           port_enable_expslv0_axis_port_enable_hcg;
wire           port_enable_expslv1_axis_port_enable_hcg;
wire           port_enable_extsys0_axis_port_enable_hcg;
wire           port_enable_extsys1_axis_port_enable_hcg;
wire           port_enable_gpvmain_ahb_ib_port_enable_hcg;
wire           port_enable_hostcpu_axis_port_enable_hcg;
wire           port_enable_secenc_axis_port_enable_hcg;
wire           ar_ready_cvm_axim_ib_int;
wire   [31:0]  araddr_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [1:0]   arburst_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [3:0]   arcache_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [11:0]  arid_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [7:0]   arlen_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire           arlock_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [2:0]   arprot_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [3:0]   arqv_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [2:0]   arsize_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [9:0]   aruser_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire           arvalid_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire           aw_ready_cvm_axim_ib_int;
wire   [31:0]  awaddr_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [1:0]   awburst_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [3:0]   awcache_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [11:0]  awid_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [7:0]   awlen_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire           awlock_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [2:0]   awprot_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [3:0]   awqv_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [2:0]   awsize_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [9:0]   awuser_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire           awvalid_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [14:0]  b_data_cvm_axim_ib_int;
wire           b_valid_cvm_axim_ib_int;
wire           bready_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [79:0]  r_data_cvm_axim_ib_int;
wire           r_valid_cvm_axim_ib_int;
wire           rready_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire           w_ready_cvm_axim_ib_int;
wire   [63:0]  wdata_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire           wlast_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [7:0]   wstrb_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire           wvalid_cvm_axim_ib_cvm_axim_cvm_axim_s;
wire   [78:0]  ar_data_cvm_axim_ib_int;
wire           ar_valid_cvm_axim_ib_int;
wire           arready_switch2_cvm_axim_ib_axi4_s;
wire   [78:0]  aw_data_cvm_axim_ib_int;
wire           aw_valid_cvm_axim_ib_int;
wire           awready_switch2_cvm_axim_ib_axi4_s;
wire           b_ready_cvm_axim_ib_int;
wire   [11:0]  bid_switch2_cvm_axim_ib_axi4_s;
wire   [1:0]   bresp_switch2_cvm_axim_ib_axi4_s;
wire           buser_switch2_cvm_axim_ib_axi4_s;
wire           bvalid_switch2_cvm_axim_ib_axi4_s;
wire           r_ready_cvm_axim_ib_int;
wire   [63:0]  rdata_switch2_cvm_axim_ib_axi4_s;
wire   [11:0]  rid_switch2_cvm_axim_ib_axi4_s;
wire           rlast_switch2_cvm_axim_ib_axi4_s;
wire   [1:0]   rresp_switch2_cvm_axim_ib_axi4_s;
wire           ruser_switch2_cvm_axim_ib_axi4_s;
wire           rvalid_switch2_cvm_axim_ib_axi4_s;
wire   [72:0]  w_data_cvm_axim_ib_int;
wire           w_valid_cvm_axim_ib_int;
wire           wready_switch2_cvm_axim_ib_axi4_s;
wire           ar_ready_debug_axim_ib_int;
wire   [31:0]  araddr_debug_axim_ib_debug_axim_debug_axim_s;
wire   [1:0]   arburst_debug_axim_ib_debug_axim_debug_axim_s;
wire   [3:0]   arcache_debug_axim_ib_debug_axim_debug_axim_s;
wire   [11:0]  arid_debug_axim_ib_debug_axim_debug_axim_s;
wire   [7:0]   arlen_debug_axim_ib_debug_axim_debug_axim_s;
wire           arlock_debug_axim_ib_debug_axim_debug_axim_s;
wire   [2:0]   arprot_debug_axim_ib_debug_axim_debug_axim_s;
wire   [2:0]   arsize_debug_axim_ib_debug_axim_debug_axim_s;
wire   [9:0]   aruser_debug_axim_ib_debug_axim_debug_axim_s;
wire           arvalid_debug_axim_ib_debug_axim_debug_axim_s;
wire           aw_ready_debug_axim_ib_int;
wire   [31:0]  awaddr_debug_axim_ib_debug_axim_debug_axim_s;
wire   [1:0]   awburst_debug_axim_ib_debug_axim_debug_axim_s;
wire   [3:0]   awcache_debug_axim_ib_debug_axim_debug_axim_s;
wire   [11:0]  awid_debug_axim_ib_debug_axim_debug_axim_s;
wire   [7:0]   awlen_debug_axim_ib_debug_axim_debug_axim_s;
wire           awlock_debug_axim_ib_debug_axim_debug_axim_s;
wire   [2:0]   awprot_debug_axim_ib_debug_axim_debug_axim_s;
wire   [2:0]   awsize_debug_axim_ib_debug_axim_debug_axim_s;
wire   [9:0]   awuser_debug_axim_ib_debug_axim_debug_axim_s;
wire           awvalid_debug_axim_ib_debug_axim_debug_axim_s;
wire   [14:0]  b_data_debug_axim_ib_int;
wire           b_valid_debug_axim_ib_int;
wire           bready_debug_axim_ib_debug_axim_debug_axim_s;
wire   [81:0]  r_data_debug_axim_ib_int;
wire           r_valid_debug_axim_ib_int;
wire           rready_debug_axim_ib_debug_axim_debug_axim_s;
wire           w_ready_debug_axim_ib_int;
wire   [31:0]  wdata_debug_axim_ib_debug_axim_debug_axim_s;
wire           wlast_debug_axim_ib_debug_axim_debug_axim_s;
wire   [3:0]   wstrb_debug_axim_ib_debug_axim_debug_axim_s;
wire           wvalid_debug_axim_ib_debug_axim_debug_axim_s;
wire   [86:0]  ar_data_debug_axim_ib_int;
wire           ar_valid_debug_axim_ib_int;
wire           arready_switch2_debug_axim_ib_axi4_s;
wire   [75:0]  aw_data_debug_axim_ib_int;
wire           aw_valid_debug_axim_ib_int;
wire           awready_switch2_debug_axim_ib_axi4_s;
wire           b_ready_debug_axim_ib_int;
wire   [11:0]  bid_switch2_debug_axim_ib_axi4_s;
wire   [1:0]   bresp_switch2_debug_axim_ib_axi4_s;
wire           buser_switch2_debug_axim_ib_axi4_s;
wire           bvalid_switch2_debug_axim_ib_axi4_s;
wire           r_ready_debug_axim_ib_int;
wire   [63:0]  rdata_switch2_debug_axim_ib_axi4_s;
wire   [11:0]  rid_switch2_debug_axim_ib_axi4_s;
wire           rlast_switch2_debug_axim_ib_axi4_s;
wire   [1:0]   rresp_switch2_debug_axim_ib_axi4_s;
wire           ruser_switch2_debug_axim_ib_axi4_s;
wire           rvalid_switch2_debug_axim_ib_axi4_s;
wire   [72:0]  w_data_debug_axim_ib_int;
wire           w_valid_debug_axim_ib_int;
wire           wready_switch2_debug_axim_ib_axi4_s;
wire   [71:0]  pfwdpayld_debug_axis_ib_apb_int;
wire           preq_debug_axis_ib_apb_int;
wire           ar_ready_debug_axis_ib_int;
wire   [39:0]  araddr_debug_axis_ib_switch2_axi_s_6;
wire   [1:0]   arburst_debug_axis_ib_switch2_axi_s_6;
wire   [3:0]   arcache_debug_axis_ib_switch2_axi_s_6;
wire   [11:0]  arid_debug_axis_ib_switch2_axi_s_6;
wire   [7:0]   arlen_debug_axis_ib_switch2_axi_s_6;
wire           arlock_debug_axis_ib_switch2_axi_s_6;
wire   [2:0]   arprot_debug_axis_ib_switch2_axi_s_6;
wire   [3:0]   arqv_debug_axis_ib_switch2_axi_s_6;
wire   [2:0]   arsize_debug_axis_ib_switch2_axi_s_6;
wire   [9:0]   aruser_debug_axis_ib_switch2_axi_s_6;
wire           arvalid_debug_axis_ib_switch2_axi_s_6;
wire   [9:0]   arvalid_vect_debug_axis_ib_switch2_axi_s_6;
wire   [2:0]   aw_rpntr_bin_debug_axis_ib_int;
wire   [3:0]   aw_rpntr_gry_debug_axis_ib_int;
wire   [39:0]  awaddr_debug_axis_ib_switch2_axi_s_6;
wire   [1:0]   awburst_debug_axis_ib_switch2_axi_s_6;
wire   [3:0]   awcache_debug_axis_ib_switch2_axi_s_6;
wire   [11:0]  awid_debug_axis_ib_switch2_axi_s_6;
wire   [7:0]   awlen_debug_axis_ib_switch2_axi_s_6;
wire           awlock_debug_axis_ib_switch2_axi_s_6;
wire   [2:0]   awprot_debug_axis_ib_switch2_axi_s_6;
wire   [3:0]   awqv_debug_axis_ib_switch2_axi_s_6;
wire   [2:0]   awsize_debug_axis_ib_switch2_axi_s_6;
wire   [9:0]   awuser_debug_axis_ib_switch2_axi_s_6;
wire           awvalid_debug_axis_ib_switch2_axi_s_6;
wire   [9:0]   awvalid_vect_debug_axis_ib_switch2_axi_s_6;
wire   [6:0]   b_data_debug_axis_ib_int;
wire   [2:0]   b_wpntr_gry_debug_axis_ib_int;
wire           bready_debug_axis_ib_switch2_axi_s_6;
wire   [71:0]  r_data_debug_axis_ib_int;
wire           r_valid_debug_axis_ib_int;
wire           rready_debug_axis_ib_switch2_axi_s_6;
wire   [2:0]   w_rpntr_bin_debug_axis_ib_int;
wire   [3:0]   w_rpntr_gry_debug_axis_ib_int;
wire   [63:0]  wdata_debug_axis_ib_switch2_axi_s_6;
wire           wlast_debug_axis_ib_switch2_axi_s_6;
wire   [7:0]   wstrb_debug_axis_ib_switch2_axi_s_6;
wire           wvalid_debug_axis_ib_switch2_axi_s_6;
wire           pack_debug_axis_ib_apb_int;
wire   [32:0]  prevpayld_debug_axis_ib_apb_int;
wire   [76:0]  ar_data_debug_axis_ib_int;
wire           ar_valid_debug_axis_ib_int;
wire           arready_debug_axis_debug_axis_ib_axi4_s;
wire   [76:0]  aw_data_debug_axis_ib_int;
wire   [3:0]   aw_wpntr_gry_debug_axis_ib_int;
wire           awready_debug_axis_debug_axis_ib_axi4_s;
wire   [1:0]   b_rpntr_bin_debug_axis_ib_int;
wire   [2:0]   b_rpntr_gry_debug_axis_ib_int;
wire   [3:0]   bid_debug_axis_debug_axis_ib_axi4_s;
wire   [1:0]   bresp_debug_axis_debug_axis_ib_axi4_s;
wire           buser_debug_axis_debug_axis_ib_axi4_s;
wire           bvalid_debug_axis_debug_axis_ib_axi4_s;
wire   [31:0]  paddr_debug_axis_apb;
wire           penable_debug_axis_apb;
wire           pselx_debug_axis_apb;
wire   [31:0]  pwdata_debug_axis_apb;
wire           pwrite_debug_axis_apb;
wire           r_ready_debug_axis_ib_int;
wire   [63:0]  rdata_debug_axis_debug_axis_ib_axi4_s;
wire   [3:0]   rid_debug_axis_debug_axis_ib_axi4_s;
wire           rlast_debug_axis_debug_axis_ib_axi4_s;
wire   [1:0]   rresp_debug_axis_debug_axis_ib_axi4_s;
wire           ruser_debug_axis_debug_axis_ib_axi4_s;
wire           rvalid_debug_axis_debug_axis_ib_axi4_s;
wire   [72:0]  w_data_debug_axis_ib_int;
wire   [3:0]   w_wpntr_gry_debug_axis_ib_int;
wire           wready_debug_axis_debug_axis_ib_axi4_s;
wire           ar_ready_expmstr0_axim_ib_int;
wire   [31:0]  araddr_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [1:0]   arburst_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [3:0]   arcache_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [11:0]  arid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [7:0]   arlen_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire           arlock_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [2:0]   arprot_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [3:0]   arqv_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [2:0]   arsize_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [9:0]   aruser_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire           arvalid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire           aw_ready_expmstr0_axim_ib_int;
wire   [31:0]  awaddr_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [1:0]   awburst_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [3:0]   awcache_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [11:0]  awid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [7:0]   awlen_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire           awlock_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [2:0]   awprot_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [3:0]   awqv_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [2:0]   awsize_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [9:0]   awuser_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire           awvalid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [14:0]  b_data_expmstr0_axim_ib_int;
wire           b_valid_expmstr0_axim_ib_int;
wire           bready_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [79:0]  r_data_expmstr0_axim_ib_int;
wire           r_valid_expmstr0_axim_ib_int;
wire           rready_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire           w_ready_expmstr0_axim_ib_int;
wire   [63:0]  wdata_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire           wlast_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [7:0]   wstrb_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire           wvalid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s;
wire   [78:0]  ar_data_expmstr0_axim_ib_int;
wire           ar_valid_expmstr0_axim_ib_int;
wire           arready_switch2_expmstr0_axim_ib_axi4_s;
wire   [78:0]  aw_data_expmstr0_axim_ib_int;
wire           aw_valid_expmstr0_axim_ib_int;
wire           awready_switch2_expmstr0_axim_ib_axi4_s;
wire           b_ready_expmstr0_axim_ib_int;
wire   [11:0]  bid_switch2_expmstr0_axim_ib_axi4_s;
wire   [1:0]   bresp_switch2_expmstr0_axim_ib_axi4_s;
wire           buser_switch2_expmstr0_axim_ib_axi4_s;
wire           bvalid_switch2_expmstr0_axim_ib_axi4_s;
wire           r_ready_expmstr0_axim_ib_int;
wire   [63:0]  rdata_switch2_expmstr0_axim_ib_axi4_s;
wire   [11:0]  rid_switch2_expmstr0_axim_ib_axi4_s;
wire           rlast_switch2_expmstr0_axim_ib_axi4_s;
wire   [1:0]   rresp_switch2_expmstr0_axim_ib_axi4_s;
wire           ruser_switch2_expmstr0_axim_ib_axi4_s;
wire           rvalid_switch2_expmstr0_axim_ib_axi4_s;
wire   [72:0]  w_data_expmstr0_axim_ib_int;
wire           w_valid_expmstr0_axim_ib_int;
wire           wready_switch2_expmstr0_axim_ib_axi4_s;
wire           ar_ready_expmstr1_axim_ib_int;
wire   [31:0]  araddr_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [1:0]   arburst_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [3:0]   arcache_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [11:0]  arid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [7:0]   arlen_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire           arlock_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [2:0]   arprot_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [3:0]   arqv_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [2:0]   arsize_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [9:0]   aruser_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire           arvalid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire           aw_ready_expmstr1_axim_ib_int;
wire   [31:0]  awaddr_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [1:0]   awburst_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [3:0]   awcache_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [11:0]  awid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [7:0]   awlen_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire           awlock_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [2:0]   awprot_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [3:0]   awqv_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [2:0]   awsize_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [9:0]   awuser_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire           awvalid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [14:0]  b_data_expmstr1_axim_ib_int;
wire           b_valid_expmstr1_axim_ib_int;
wire           bready_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [79:0]  r_data_expmstr1_axim_ib_int;
wire           r_valid_expmstr1_axim_ib_int;
wire           rready_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire           w_ready_expmstr1_axim_ib_int;
wire   [63:0]  wdata_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire           wlast_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [7:0]   wstrb_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire           wvalid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s;
wire   [78:0]  ar_data_expmstr1_axim_ib_int;
wire           ar_valid_expmstr1_axim_ib_int;
wire           arready_switch2_expmstr1_axim_ib_axi4_s;
wire   [78:0]  aw_data_expmstr1_axim_ib_int;
wire           aw_valid_expmstr1_axim_ib_int;
wire           awready_switch2_expmstr1_axim_ib_axi4_s;
wire           b_ready_expmstr1_axim_ib_int;
wire   [11:0]  bid_switch2_expmstr1_axim_ib_axi4_s;
wire   [1:0]   bresp_switch2_expmstr1_axim_ib_axi4_s;
wire           buser_switch2_expmstr1_axim_ib_axi4_s;
wire           bvalid_switch2_expmstr1_axim_ib_axi4_s;
wire           r_ready_expmstr1_axim_ib_int;
wire   [63:0]  rdata_switch2_expmstr1_axim_ib_axi4_s;
wire   [11:0]  rid_switch2_expmstr1_axim_ib_axi4_s;
wire           rlast_switch2_expmstr1_axim_ib_axi4_s;
wire   [1:0]   rresp_switch2_expmstr1_axim_ib_axi4_s;
wire           ruser_switch2_expmstr1_axim_ib_axi4_s;
wire           rvalid_switch2_expmstr1_axim_ib_axi4_s;
wire   [72:0]  w_data_expmstr1_axim_ib_int;
wire           w_valid_expmstr1_axim_ib_int;
wire           wready_switch2_expmstr1_axim_ib_axi4_s;
wire   [3:0]   ar_rpntr_bin_expslv0_axis_ib_int;
wire   [4:0]   ar_rpntr_gry_expslv0_axis_ib_int;
wire   [39:0]  araddr_expslv0_axis_ib_switch2_axi_s_4;
wire   [1:0]   arburst_expslv0_axis_ib_switch2_axi_s_4;
wire   [3:0]   arcache_expslv0_axis_ib_switch2_axi_s_4;
wire   [11:0]  arid_expslv0_axis_ib_switch2_axi_s_4;
wire   [7:0]   arlen_expslv0_axis_ib_switch2_axi_s_4;
wire           arlock_expslv0_axis_ib_switch2_axi_s_4;
wire   [2:0]   arprot_expslv0_axis_ib_switch2_axi_s_4;
wire   [3:0]   arqv_expslv0_axis_ib_switch2_axi_s_4;
wire   [2:0]   arsize_expslv0_axis_ib_switch2_axi_s_4;
wire   [9:0]   aruser_expslv0_axis_ib_switch2_axi_s_4;
wire           arvalid_expslv0_axis_ib_switch2_axi_s_4;
wire   [9:0]   arvalid_vect_expslv0_axis_ib_switch2_axi_s_4;
wire   [2:0]   aw_rpntr_bin_expslv0_axis_ib_int;
wire   [3:0]   aw_rpntr_gry_expslv0_axis_ib_int;
wire   [39:0]  awaddr_expslv0_axis_ib_switch2_axi_s_4;
wire   [1:0]   awburst_expslv0_axis_ib_switch2_axi_s_4;
wire   [3:0]   awcache_expslv0_axis_ib_switch2_axi_s_4;
wire   [11:0]  awid_expslv0_axis_ib_switch2_axi_s_4;
wire   [7:0]   awlen_expslv0_axis_ib_switch2_axi_s_4;
wire           awlock_expslv0_axis_ib_switch2_axi_s_4;
wire   [2:0]   awprot_expslv0_axis_ib_switch2_axi_s_4;
wire   [3:0]   awqv_expslv0_axis_ib_switch2_axi_s_4;
wire   [2:0]   awsize_expslv0_axis_ib_switch2_axi_s_4;
wire   [9:0]   awuser_expslv0_axis_ib_switch2_axi_s_4;
wire           awvalid_expslv0_axis_ib_switch2_axi_s_4;
wire   [9:0]   awvalid_vect_expslv0_axis_ib_switch2_axi_s_4;
wire   [10:0]  b_data_expslv0_axis_ib_int;
wire   [2:0]   b_wpntr_gry_expslv0_axis_ib_int;
wire           bready_expslv0_axis_ib_switch2_axi_s_4;
wire   [75:0]  r_data_expslv0_axis_ib_int;
wire   [2:0]   r_wpntr_gry_expslv0_axis_ib_int;
wire           rready_expslv0_axis_ib_switch2_axi_s_4;
wire   [2:0]   w_rpntr_bin_expslv0_axis_ib_int;
wire   [3:0]   w_rpntr_gry_expslv0_axis_ib_int;
wire   [63:0]  wdata_expslv0_axis_ib_switch2_axi_s_4;
wire           wlast_expslv0_axis_ib_switch2_axi_s_4;
wire   [7:0]   wstrb_expslv0_axis_ib_switch2_axi_s_4;
wire           wvalid_expslv0_axis_ib_switch2_axi_s_4;
wire   [84:0]  ar_data_expslv0_axis_ib_int;
wire   [4:0]   ar_wpntr_gry_expslv0_axis_ib_int;
wire           arready_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [84:0]  aw_data_expslv0_axis_ib_int;
wire   [3:0]   aw_wpntr_gry_expslv0_axis_ib_int;
wire           awready_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [1:0]   b_rpntr_bin_expslv0_axis_ib_int;
wire   [2:0]   b_rpntr_gry_expslv0_axis_ib_int;
wire   [7:0]   bid_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [1:0]   bresp_expslv0_axis_expslv0_axis_ib_axi4_s;
wire           buser_expslv0_axis_expslv0_axis_ib_axi4_s;
wire           bvalid_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [1:0]   r_rpntr_bin_expslv0_axis_ib_int;
wire   [2:0]   r_rpntr_gry_expslv0_axis_ib_int;
wire   [63:0]  rdata_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [7:0]   rid_expslv0_axis_expslv0_axis_ib_axi4_s;
wire           rlast_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [1:0]   rresp_expslv0_axis_expslv0_axis_ib_axi4_s;
wire           ruser_expslv0_axis_expslv0_axis_ib_axi4_s;
wire           rvalid_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [72:0]  w_data_expslv0_axis_ib_int;
wire   [3:0]   w_wpntr_gry_expslv0_axis_ib_int;
wire           wready_expslv0_axis_expslv0_axis_ib_axi4_s;
wire   [3:0]   ar_rpntr_bin_expslv1_axis_ib_int;
wire   [4:0]   ar_rpntr_gry_expslv1_axis_ib_int;
wire   [39:0]  araddr_expslv1_axis_ib_switch2_axi_s_5;
wire   [1:0]   arburst_expslv1_axis_ib_switch2_axi_s_5;
wire   [3:0]   arcache_expslv1_axis_ib_switch2_axi_s_5;
wire   [11:0]  arid_expslv1_axis_ib_switch2_axi_s_5;
wire   [7:0]   arlen_expslv1_axis_ib_switch2_axi_s_5;
wire           arlock_expslv1_axis_ib_switch2_axi_s_5;
wire   [2:0]   arprot_expslv1_axis_ib_switch2_axi_s_5;
wire   [3:0]   arqv_expslv1_axis_ib_switch2_axi_s_5;
wire   [2:0]   arsize_expslv1_axis_ib_switch2_axi_s_5;
wire   [9:0]   aruser_expslv1_axis_ib_switch2_axi_s_5;
wire           arvalid_expslv1_axis_ib_switch2_axi_s_5;
wire   [9:0]   arvalid_vect_expslv1_axis_ib_switch2_axi_s_5;
wire   [2:0]   aw_rpntr_bin_expslv1_axis_ib_int;
wire   [3:0]   aw_rpntr_gry_expslv1_axis_ib_int;
wire   [39:0]  awaddr_expslv1_axis_ib_switch2_axi_s_5;
wire   [1:0]   awburst_expslv1_axis_ib_switch2_axi_s_5;
wire   [3:0]   awcache_expslv1_axis_ib_switch2_axi_s_5;
wire   [11:0]  awid_expslv1_axis_ib_switch2_axi_s_5;
wire   [7:0]   awlen_expslv1_axis_ib_switch2_axi_s_5;
wire           awlock_expslv1_axis_ib_switch2_axi_s_5;
wire   [2:0]   awprot_expslv1_axis_ib_switch2_axi_s_5;
wire   [3:0]   awqv_expslv1_axis_ib_switch2_axi_s_5;
wire   [2:0]   awsize_expslv1_axis_ib_switch2_axi_s_5;
wire   [9:0]   awuser_expslv1_axis_ib_switch2_axi_s_5;
wire           awvalid_expslv1_axis_ib_switch2_axi_s_5;
wire   [9:0]   awvalid_vect_expslv1_axis_ib_switch2_axi_s_5;
wire   [10:0]  b_data_expslv1_axis_ib_int;
wire   [2:0]   b_wpntr_gry_expslv1_axis_ib_int;
wire           bready_expslv1_axis_ib_switch2_axi_s_5;
wire   [75:0]  r_data_expslv1_axis_ib_int;
wire   [2:0]   r_wpntr_gry_expslv1_axis_ib_int;
wire           rready_expslv1_axis_ib_switch2_axi_s_5;
wire   [2:0]   w_rpntr_bin_expslv1_axis_ib_int;
wire   [3:0]   w_rpntr_gry_expslv1_axis_ib_int;
wire   [63:0]  wdata_expslv1_axis_ib_switch2_axi_s_5;
wire           wlast_expslv1_axis_ib_switch2_axi_s_5;
wire   [7:0]   wstrb_expslv1_axis_ib_switch2_axi_s_5;
wire           wvalid_expslv1_axis_ib_switch2_axi_s_5;
wire   [84:0]  ar_data_expslv1_axis_ib_int;
wire   [4:0]   ar_wpntr_gry_expslv1_axis_ib_int;
wire           arready_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [84:0]  aw_data_expslv1_axis_ib_int;
wire   [3:0]   aw_wpntr_gry_expslv1_axis_ib_int;
wire           awready_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [1:0]   b_rpntr_bin_expslv1_axis_ib_int;
wire   [2:0]   b_rpntr_gry_expslv1_axis_ib_int;
wire   [7:0]   bid_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [1:0]   bresp_expslv1_axis_expslv1_axis_ib_axi4_s;
wire           buser_expslv1_axis_expslv1_axis_ib_axi4_s;
wire           bvalid_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [1:0]   r_rpntr_bin_expslv1_axis_ib_int;
wire   [2:0]   r_rpntr_gry_expslv1_axis_ib_int;
wire   [63:0]  rdata_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [7:0]   rid_expslv1_axis_expslv1_axis_ib_axi4_s;
wire           rlast_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [1:0]   rresp_expslv1_axis_expslv1_axis_ib_axi4_s;
wire           ruser_expslv1_axis_expslv1_axis_ib_axi4_s;
wire           rvalid_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [72:0]  w_data_expslv1_axis_ib_int;
wire   [3:0]   w_wpntr_gry_expslv1_axis_ib_int;
wire           wready_expslv1_axis_expslv1_axis_ib_axi4_s;
wire   [71:0]  pfwdpayld_extsys0_axis_ib_apb_int;
wire           preq_extsys0_axis_ib_apb_int;
wire   [2:0]   ar_rpntr_bin_extsys0_axis_ib_int;
wire   [3:0]   ar_rpntr_gry_extsys0_axis_ib_int;
wire   [39:0]  araddr_extsys0_axis_ib_switch2_axi_s_0;
wire   [1:0]   arburst_extsys0_axis_ib_switch2_axi_s_0;
wire   [3:0]   arcache_extsys0_axis_ib_switch2_axi_s_0;
wire   [11:0]  arid_extsys0_axis_ib_switch2_axi_s_0;
wire   [7:0]   arlen_extsys0_axis_ib_switch2_axi_s_0;
wire           arlock_extsys0_axis_ib_switch2_axi_s_0;
wire   [2:0]   arprot_extsys0_axis_ib_switch2_axi_s_0;
wire   [3:0]   arqv_extsys0_axis_ib_switch2_axi_s_0;
wire   [2:0]   arsize_extsys0_axis_ib_switch2_axi_s_0;
wire   [9:0]   aruser_extsys0_axis_ib_switch2_axi_s_0;
wire           arvalid_extsys0_axis_ib_switch2_axi_s_0;
wire   [9:0]   arvalid_vect_extsys0_axis_ib_switch2_axi_s_0;
wire   [2:0]   aw_rpntr_bin_extsys0_axis_ib_int;
wire   [3:0]   aw_rpntr_gry_extsys0_axis_ib_int;
wire   [39:0]  awaddr_extsys0_axis_ib_switch2_axi_s_0;
wire   [1:0]   awburst_extsys0_axis_ib_switch2_axi_s_0;
wire   [3:0]   awcache_extsys0_axis_ib_switch2_axi_s_0;
wire   [11:0]  awid_extsys0_axis_ib_switch2_axi_s_0;
wire   [7:0]   awlen_extsys0_axis_ib_switch2_axi_s_0;
wire           awlock_extsys0_axis_ib_switch2_axi_s_0;
wire   [2:0]   awprot_extsys0_axis_ib_switch2_axi_s_0;
wire   [3:0]   awqv_extsys0_axis_ib_switch2_axi_s_0;
wire   [2:0]   awsize_extsys0_axis_ib_switch2_axi_s_0;
wire   [9:0]   awuser_extsys0_axis_ib_switch2_axi_s_0;
wire           awvalid_extsys0_axis_ib_switch2_axi_s_0;
wire   [9:0]   awvalid_vect_extsys0_axis_ib_switch2_axi_s_0;
wire   [10:0]  b_data_extsys0_axis_ib_int;
wire   [2:0]   b_wpntr_gry_extsys0_axis_ib_int;
wire           bready_extsys0_axis_ib_switch2_axi_s_0;
wire   [75:0]  r_data_extsys0_axis_ib_int;
wire   [2:0]   r_wpntr_gry_extsys0_axis_ib_int;
wire           rready_extsys0_axis_ib_switch2_axi_s_0;
wire   [1:0]   w_rpntr_bin_extsys0_axis_ib_int;
wire   [2:0]   w_rpntr_gry_extsys0_axis_ib_int;
wire   [63:0]  wdata_extsys0_axis_ib_switch2_axi_s_0;
wire           wlast_extsys0_axis_ib_switch2_axi_s_0;
wire   [7:0]   wstrb_extsys0_axis_ib_switch2_axi_s_0;
wire           wvalid_extsys0_axis_ib_switch2_axi_s_0;
wire           pack_extsys0_axis_ib_apb_int;
wire   [32:0]  prevpayld_extsys0_axis_ib_apb_int;
wire   [80:0]  ar_data_extsys0_axis_ib_int;
wire   [3:0]   ar_wpntr_gry_extsys0_axis_ib_int;
wire           arready_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [80:0]  aw_data_extsys0_axis_ib_int;
wire   [3:0]   aw_wpntr_gry_extsys0_axis_ib_int;
wire           awready_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [1:0]   b_rpntr_bin_extsys0_axis_ib_int;
wire   [2:0]   b_rpntr_gry_extsys0_axis_ib_int;
wire   [7:0]   bid_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [1:0]   bresp_extsys0_axis_extsys0_axis_ib_axi4_s;
wire           buser_extsys0_axis_extsys0_axis_ib_axi4_s;
wire           bvalid_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [31:0]  paddr_extsys0_axis_apb;
wire           penable_extsys0_axis_apb;
wire           pselx_extsys0_axis_apb;
wire   [31:0]  pwdata_extsys0_axis_apb;
wire           pwrite_extsys0_axis_apb;
wire   [1:0]   r_rpntr_bin_extsys0_axis_ib_int;
wire   [2:0]   r_rpntr_gry_extsys0_axis_ib_int;
wire   [63:0]  rdata_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [7:0]   rid_extsys0_axis_extsys0_axis_ib_axi4_s;
wire           rlast_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [1:0]   rresp_extsys0_axis_extsys0_axis_ib_axi4_s;
wire           ruser_extsys0_axis_extsys0_axis_ib_axi4_s;
wire           rvalid_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [72:0]  w_data_extsys0_axis_ib_int;
wire   [2:0]   w_wpntr_gry_extsys0_axis_ib_int;
wire           wready_extsys0_axis_extsys0_axis_ib_axi4_s;
wire   [71:0]  pfwdpayld_extsys1_axis_ib_apb_int;
wire           preq_extsys1_axis_ib_apb_int;
wire   [2:0]   ar_rpntr_bin_extsys1_axis_ib_int;
wire   [3:0]   ar_rpntr_gry_extsys1_axis_ib_int;
wire   [39:0]  araddr_extsys1_axis_ib_switch2_axi_s_2;
wire   [1:0]   arburst_extsys1_axis_ib_switch2_axi_s_2;
wire   [3:0]   arcache_extsys1_axis_ib_switch2_axi_s_2;
wire   [11:0]  arid_extsys1_axis_ib_switch2_axi_s_2;
wire   [7:0]   arlen_extsys1_axis_ib_switch2_axi_s_2;
wire           arlock_extsys1_axis_ib_switch2_axi_s_2;
wire   [2:0]   arprot_extsys1_axis_ib_switch2_axi_s_2;
wire   [3:0]   arqv_extsys1_axis_ib_switch2_axi_s_2;
wire   [2:0]   arsize_extsys1_axis_ib_switch2_axi_s_2;
wire   [9:0]   aruser_extsys1_axis_ib_switch2_axi_s_2;
wire           arvalid_extsys1_axis_ib_switch2_axi_s_2;
wire   [9:0]   arvalid_vect_extsys1_axis_ib_switch2_axi_s_2;
wire   [2:0]   aw_rpntr_bin_extsys1_axis_ib_int;
wire   [3:0]   aw_rpntr_gry_extsys1_axis_ib_int;
wire   [39:0]  awaddr_extsys1_axis_ib_switch2_axi_s_2;
wire   [1:0]   awburst_extsys1_axis_ib_switch2_axi_s_2;
wire   [3:0]   awcache_extsys1_axis_ib_switch2_axi_s_2;
wire   [11:0]  awid_extsys1_axis_ib_switch2_axi_s_2;
wire   [7:0]   awlen_extsys1_axis_ib_switch2_axi_s_2;
wire           awlock_extsys1_axis_ib_switch2_axi_s_2;
wire   [2:0]   awprot_extsys1_axis_ib_switch2_axi_s_2;
wire   [3:0]   awqv_extsys1_axis_ib_switch2_axi_s_2;
wire   [2:0]   awsize_extsys1_axis_ib_switch2_axi_s_2;
wire   [9:0]   awuser_extsys1_axis_ib_switch2_axi_s_2;
wire           awvalid_extsys1_axis_ib_switch2_axi_s_2;
wire   [9:0]   awvalid_vect_extsys1_axis_ib_switch2_axi_s_2;
wire   [10:0]  b_data_extsys1_axis_ib_int;
wire   [2:0]   b_wpntr_gry_extsys1_axis_ib_int;
wire           bready_extsys1_axis_ib_switch2_axi_s_2;
wire   [75:0]  r_data_extsys1_axis_ib_int;
wire   [2:0]   r_wpntr_gry_extsys1_axis_ib_int;
wire           rready_extsys1_axis_ib_switch2_axi_s_2;
wire   [1:0]   w_rpntr_bin_extsys1_axis_ib_int;
wire   [2:0]   w_rpntr_gry_extsys1_axis_ib_int;
wire   [63:0]  wdata_extsys1_axis_ib_switch2_axi_s_2;
wire           wlast_extsys1_axis_ib_switch2_axi_s_2;
wire   [7:0]   wstrb_extsys1_axis_ib_switch2_axi_s_2;
wire           wvalid_extsys1_axis_ib_switch2_axi_s_2;
wire           pack_extsys1_axis_ib_apb_int;
wire   [32:0]  prevpayld_extsys1_axis_ib_apb_int;
wire   [80:0]  ar_data_extsys1_axis_ib_int;
wire   [3:0]   ar_wpntr_gry_extsys1_axis_ib_int;
wire           arready_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [80:0]  aw_data_extsys1_axis_ib_int;
wire   [3:0]   aw_wpntr_gry_extsys1_axis_ib_int;
wire           awready_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [1:0]   b_rpntr_bin_extsys1_axis_ib_int;
wire   [2:0]   b_rpntr_gry_extsys1_axis_ib_int;
wire   [7:0]   bid_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [1:0]   bresp_extsys1_axis_extsys1_axis_ib_axi4_s;
wire           buser_extsys1_axis_extsys1_axis_ib_axi4_s;
wire           bvalid_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [31:0]  paddr_extsys1_axis_apb;
wire           penable_extsys1_axis_apb;
wire           pselx_extsys1_axis_apb;
wire   [31:0]  pwdata_extsys1_axis_apb;
wire           pwrite_extsys1_axis_apb;
wire   [1:0]   r_rpntr_bin_extsys1_axis_ib_int;
wire   [2:0]   r_rpntr_gry_extsys1_axis_ib_int;
wire   [63:0]  rdata_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [7:0]   rid_extsys1_axis_extsys1_axis_ib_axi4_s;
wire           rlast_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [1:0]   rresp_extsys1_axis_extsys1_axis_ib_axi4_s;
wire           ruser_extsys1_axis_extsys1_axis_ib_axi4_s;
wire           rvalid_extsys1_axis_extsys1_axis_ib_axi4_s;
wire   [72:0]  w_data_extsys1_axis_ib_int;
wire   [2:0]   w_wpntr_gry_extsys1_axis_ib_int;
wire           wready_extsys1_axis_extsys1_axis_ib_axi4_s;
wire           arready_switch1_gpv_0_ib1_axi4_s;
wire           awready_switch1_gpv_0_ib1_axi4_s;
wire   [11:0]  bid_switch1_gpv_0_ib1_axi4_s;
wire   [1:0]   bresp_switch1_gpv_0_ib1_axi4_s;
wire           bvalid_switch1_gpv_0_ib1_axi4_s;
wire   [31:0]  rdata_switch1_gpv_0_ib1_axi4_s;
wire   [11:0]  rid_switch1_gpv_0_ib1_axi4_s;
wire           rlast_switch1_gpv_0_ib1_axi4_s;
wire   [1:0]   rresp_switch1_gpv_0_ib1_axi4_s;
wire           rvalid_switch1_gpv_0_ib1_axi4_s;
wire           wready_switch1_gpv_0_ib1_axi4_s;
wire   [39:0]  araddr_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [1:0]   arburst_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [3:0]   arcache_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [11:0]  arid_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [7:0]   arlen_gpvmain_ahb_ib_switch1_axi_s_5;
wire           arlock_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [2:0]   arprot_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [3:0]   arqv_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [2:0]   arsize_gpvmain_ahb_ib_switch1_axi_s_5;
wire           arvalid_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [1:0]   arvalid_vect_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [39:0]  awaddr_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [1:0]   awburst_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [3:0]   awcache_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [11:0]  awid_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [7:0]   awlen_gpvmain_ahb_ib_switch1_axi_s_5;
wire           awlock_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [2:0]   awprot_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [3:0]   awqv_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [2:0]   awsize_gpvmain_ahb_ib_switch1_axi_s_5;
wire           awvalid_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [1:0]   awvalid_vect_gpvmain_ahb_ib_switch1_axi_s_5;
wire           bready_gpvmain_ahb_ib_switch1_axi_s_5;
wire           cactive_gpvmain_ahb_ib_hcg;
wire           cactive_gpvmain_ahb_ib_wakeup_hcg;
wire           rready_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [31:0]  wdata_gpvmain_ahb_ib_switch1_axi_s_5;
wire           wlast_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [3:0]   wstrb_gpvmain_ahb_ib_switch1_axi_s_5;
wire           wvalid_gpvmain_ahb_ib_switch1_axi_s_5;
wire   [71:0]  pfwdpayld_hostcpu_axis_ib_apb_int;
wire           preq_hostcpu_axis_ib_apb_int;
wire   [3:0]   ar_rpntr_bin_hostcpu_axis_ib_int;
wire   [4:0]   ar_rpntr_gry_hostcpu_axis_ib_int;
wire   [39:0]  araddr_hostcpu_axis_ib_switch2_axi_s_1;
wire   [1:0]   arburst_hostcpu_axis_ib_switch2_axi_s_1;
wire   [3:0]   arcache_hostcpu_axis_ib_switch2_axi_s_1;
wire   [11:0]  arid_hostcpu_axis_ib_switch2_axi_s_1;
wire   [7:0]   arlen_hostcpu_axis_ib_switch2_axi_s_1;
wire           arlock_hostcpu_axis_ib_switch2_axi_s_1;
wire   [2:0]   arprot_hostcpu_axis_ib_switch2_axi_s_1;
wire   [3:0]   arqv_hostcpu_axis_ib_switch2_axi_s_1;
wire   [2:0]   arsize_hostcpu_axis_ib_switch2_axi_s_1;
wire   [9:0]   aruser_hostcpu_axis_ib_switch2_axi_s_1;
wire           arvalid_hostcpu_axis_ib_switch2_axi_s_1;
wire   [10:0]  arvalid_vect_hostcpu_axis_ib_switch2_axi_s_1;
wire   [3:0]   aw_rpntr_bin_hostcpu_axis_ib_int;
wire   [4:0]   aw_rpntr_gry_hostcpu_axis_ib_int;
wire   [39:0]  awaddr_hostcpu_axis_ib_switch2_axi_s_1;
wire   [1:0]   awburst_hostcpu_axis_ib_switch2_axi_s_1;
wire   [3:0]   awcache_hostcpu_axis_ib_switch2_axi_s_1;
wire   [11:0]  awid_hostcpu_axis_ib_switch2_axi_s_1;
wire   [7:0]   awlen_hostcpu_axis_ib_switch2_axi_s_1;
wire           awlock_hostcpu_axis_ib_switch2_axi_s_1;
wire   [2:0]   awprot_hostcpu_axis_ib_switch2_axi_s_1;
wire   [3:0]   awqv_hostcpu_axis_ib_switch2_axi_s_1;
wire   [2:0]   awsize_hostcpu_axis_ib_switch2_axi_s_1;
wire   [9:0]   awuser_hostcpu_axis_ib_switch2_axi_s_1;
wire           awvalid_hostcpu_axis_ib_switch2_axi_s_1;
wire   [10:0]  awvalid_vect_hostcpu_axis_ib_switch2_axi_s_1;
wire   [10:0]  b_data_hostcpu_axis_ib_int;
wire   [2:0]   b_wpntr_gry_hostcpu_axis_ib_int;
wire           bready_hostcpu_axis_ib_switch2_axi_s_1;
wire   [142:0] r_data_hostcpu_axis_ib_int;
wire   [2:0]   r_wpntr_gry_hostcpu_axis_ib_int;
wire           rready_hostcpu_axis_ib_switch2_axi_s_1;
wire   [3:0]   w_rpntr_bin_hostcpu_axis_ib_int;
wire   [4:0]   w_rpntr_gry_hostcpu_axis_ib_int;
wire   [63:0]  wdata_hostcpu_axis_ib_switch2_axi_s_1;
wire           wlast_hostcpu_axis_ib_switch2_axi_s_1;
wire   [7:0]   wstrb_hostcpu_axis_ib_switch2_axi_s_1;
wire           wvalid_hostcpu_axis_ib_switch2_axi_s_1;
wire           pack_hostcpu_axis_ib_apb_int;
wire   [32:0]  prevpayld_hostcpu_axis_ib_apb_int;
wire   [103:0] ar_data_hostcpu_axis_ib_int;
wire   [4:0]   ar_wpntr_gry_hostcpu_axis_ib_int;
wire           arready_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [90:0]  aw_data_hostcpu_axis_ib_int;
wire   [4:0]   aw_wpntr_gry_hostcpu_axis_ib_int;
wire           awready_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [1:0]   b_rpntr_bin_hostcpu_axis_ib_int;
wire   [2:0]   b_rpntr_gry_hostcpu_axis_ib_int;
wire   [7:0]   bid_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [1:0]   bresp_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire           buser_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire           bvalid_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [31:0]  paddr_hostcpu_axis_apb;
wire           penable_hostcpu_axis_apb;
wire           pselx_hostcpu_axis_apb;
wire   [31:0]  pwdata_hostcpu_axis_apb;
wire           pwrite_hostcpu_axis_apb;
wire   [1:0]   r_rpntr_bin_hostcpu_axis_ib_int;
wire   [2:0]   r_rpntr_gry_hostcpu_axis_ib_int;
wire   [127:0] rdata_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [7:0]   rid_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire           rlast_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [1:0]   rresp_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire           ruser_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire           rvalid_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire   [144:0] w_data_hostcpu_axis_ib_int;
wire   [4:0]   w_wpntr_gry_hostcpu_axis_ib_int;
wire           wready_hostcpu_axis_hostcpu_axis_ib_axi4_s;
wire           ar_ready_ib1_int;
wire   [39:0]  araddr_ib1_switch2_axi_s_3;
wire   [1:0]   arburst_ib1_switch2_axi_s_3;
wire   [3:0]   arcache_ib1_switch2_axi_s_3;
wire   [11:0]  arid_ib1_switch2_axi_s_3;
wire   [7:0]   arlen_ib1_switch2_axi_s_3;
wire           arlock_ib1_switch2_axi_s_3;
wire   [2:0]   arprot_ib1_switch2_axi_s_3;
wire   [3:0]   arqv_ib1_switch2_axi_s_3;
wire   [2:0]   arsize_ib1_switch2_axi_s_3;
wire   [9:0]   aruser_ib1_switch2_axi_s_3;
wire           arvalid_ib1_switch2_axi_s_3;
wire   [9:0]   arvalid_vect_ib1_switch2_axi_s_3;
wire           aw_ready_ib1_int;
wire   [39:0]  awaddr_ib1_switch2_axi_s_3;
wire   [1:0]   awburst_ib1_switch2_axi_s_3;
wire   [3:0]   awcache_ib1_switch2_axi_s_3;
wire   [11:0]  awid_ib1_switch2_axi_s_3;
wire   [7:0]   awlen_ib1_switch2_axi_s_3;
wire           awlock_ib1_switch2_axi_s_3;
wire   [2:0]   awprot_ib1_switch2_axi_s_3;
wire   [3:0]   awqv_ib1_switch2_axi_s_3;
wire   [2:0]   awsize_ib1_switch2_axi_s_3;
wire   [9:0]   awuser_ib1_switch2_axi_s_3;
wire           awvalid_ib1_switch2_axi_s_3;
wire   [9:0]   awvalid_vect_ib1_switch2_axi_s_3;
wire   [14:0]  b_data_ib1_int;
wire           b_valid_ib1_int;
wire           bready_ib1_switch2_axi_s_3;
wire   [79:0]  r_data_ib1_int;
wire           r_valid_ib1_int;
wire           rready_ib1_switch2_axi_s_3;
wire           w_ready_ib1_int;
wire   [63:0]  wdata_ib1_switch2_axi_s_3;
wire           wlast_ib1_switch2_axi_s_3;
wire   [7:0]   wstrb_ib1_switch2_axi_s_3;
wire           wvalid_ib1_switch2_axi_s_3;
wire   [96:0]  ar_data_ib1_int;
wire           ar_valid_ib1_int;
wire           arready_switch1_ib1_axi_s_0;
wire   [96:0]  aw_data_ib1_int;
wire           aw_valid_ib1_int;
wire           awready_switch1_ib1_axi_s_0;
wire           b_ready_ib1_int;
wire   [11:0]  bid_switch1_ib1_axi_s_0;
wire   [1:0]   bresp_switch1_ib1_axi_s_0;
wire           buser_switch1_ib1_axi_s_0;
wire           bvalid_switch1_ib1_axi_s_0;
wire           r_ready_ib1_int;
wire   [31:0]  rdata_switch1_ib1_axi_s_0;
wire   [11:0]  rid_switch1_ib1_axi_s_0;
wire           rlast_switch1_ib1_axi_s_0;
wire   [1:0]   rresp_switch1_ib1_axi_s_0;
wire           ruser_switch1_ib1_axi_s_0;
wire           rvalid_switch1_ib1_axi_s_0;
wire   [72:0]  w_data_ib1_int;
wire           w_valid_ib1_int;
wire           wready_switch1_ib1_axi_s_0;
wire           ar_ready_ib4_int;
wire   [39:0]  araddr_ib4_switch3_axi_s_0;
wire   [1:0]   arburst_ib4_switch3_axi_s_0;
wire   [3:0]   arcache_ib4_switch3_axi_s_0;
wire   [11:0]  arid_ib4_switch3_axi_s_0;
wire   [7:0]   arlen_ib4_switch3_axi_s_0;
wire           arlock_ib4_switch3_axi_s_0;
wire   [2:0]   arprot_ib4_switch3_axi_s_0;
wire   [3:0]   arqv_ib4_switch3_axi_s_0;
wire   [2:0]   arsize_ib4_switch3_axi_s_0;
wire   [9:0]   aruser_ib4_switch3_axi_s_0;
wire           arvalid_ib4_switch3_axi_s_0;
wire   [3:0]   arvalid_vect_ib4_switch3_axi_s_0;
wire           aw_ready_ib4_int;
wire   [39:0]  awaddr_ib4_switch3_axi_s_0;
wire   [1:0]   awburst_ib4_switch3_axi_s_0;
wire   [3:0]   awcache_ib4_switch3_axi_s_0;
wire   [11:0]  awid_ib4_switch3_axi_s_0;
wire   [7:0]   awlen_ib4_switch3_axi_s_0;
wire           awlock_ib4_switch3_axi_s_0;
wire   [2:0]   awprot_ib4_switch3_axi_s_0;
wire   [3:0]   awqv_ib4_switch3_axi_s_0;
wire   [2:0]   awsize_ib4_switch3_axi_s_0;
wire   [9:0]   awuser_ib4_switch3_axi_s_0;
wire           awvalid_ib4_switch3_axi_s_0;
wire   [3:0]   awvalid_vect_ib4_switch3_axi_s_0;
wire   [14:0]  b_data_ib4_int;
wire           b_valid_ib4_int;
wire           bready_ib4_switch3_axi_s_0;
wire   [81:0]  r_data_ib4_int;
wire           r_valid_ib4_int;
wire           rready_ib4_switch3_axi_s_0;
wire           w_ready_ib4_int;
wire   [31:0]  wdata_ib4_switch3_axi_s_0;
wire           wlast_ib4_switch3_axi_s_0;
wire   [3:0]   wstrb_ib4_switch3_axi_s_0;
wire           wvalid_ib4_switch3_axi_s_0;
wire   [102:0] ar_data_ib4_int;
wire           ar_valid_ib4_int;
wire           arready_switch2_ib4_axi_s_0;
wire   [91:0]  aw_data_ib4_int;
wire           aw_valid_ib4_int;
wire           awready_switch2_ib4_axi_s_0;
wire           b_ready_ib4_int;
wire   [11:0]  bid_switch2_ib4_axi_s_0;
wire   [1:0]   bresp_switch2_ib4_axi_s_0;
wire           buser_switch2_ib4_axi_s_0;
wire           bvalid_switch2_ib4_axi_s_0;
wire           r_ready_ib4_int;
wire   [63:0]  rdata_switch2_ib4_axi_s_0;
wire   [11:0]  rid_switch2_ib4_axi_s_0;
wire           rlast_switch2_ib4_axi_s_0;
wire   [1:0]   rresp_switch2_ib4_axi_s_0;
wire           ruser_switch2_ib4_axi_s_0;
wire           rvalid_switch2_ib4_axi_s_0;
wire   [72:0]  w_data_ib4_int;
wire           w_valid_ib4_int;
wire           wready_switch2_ib4_axi_s_0;
wire           ar_ready_ocvm_axim_ib_int;
wire   [31:0]  araddr_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [1:0]   arburst_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [3:0]   arcache_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [11:0]  arid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [7:0]   arlen_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire           arlock_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [2:0]   arprot_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [3:0]   arqv_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [2:0]   arsize_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [9:0]   aruser_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire           arvalid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire           aw_ready_ocvm_axim_ib_int;
wire   [31:0]  awaddr_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [1:0]   awburst_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [3:0]   awcache_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [11:0]  awid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [7:0]   awlen_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire           awlock_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [2:0]   awprot_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [3:0]   awqv_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [2:0]   awsize_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [9:0]   awuser_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire           awvalid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [14:0]  b_data_ocvm_axim_ib_int;
wire           b_valid_ocvm_axim_ib_int;
wire           bready_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [79:0]  r_data_ocvm_axim_ib_int;
wire           r_valid_ocvm_axim_ib_int;
wire           rready_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire           w_ready_ocvm_axim_ib_int;
wire   [63:0]  wdata_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire           wlast_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [7:0]   wstrb_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire           wvalid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s;
wire   [78:0]  ar_data_ocvm_axim_ib_int;
wire           ar_valid_ocvm_axim_ib_int;
wire           arready_switch2_ocvm_axim_ib_axi4_s;
wire   [78:0]  aw_data_ocvm_axim_ib_int;
wire           aw_valid_ocvm_axim_ib_int;
wire           awready_switch2_ocvm_axim_ib_axi4_s;
wire           b_ready_ocvm_axim_ib_int;
wire   [11:0]  bid_switch2_ocvm_axim_ib_axi4_s;
wire   [1:0]   bresp_switch2_ocvm_axim_ib_axi4_s;
wire           buser_switch2_ocvm_axim_ib_axi4_s;
wire           bvalid_switch2_ocvm_axim_ib_axi4_s;
wire           r_ready_ocvm_axim_ib_int;
wire   [63:0]  rdata_switch2_ocvm_axim_ib_axi4_s;
wire   [11:0]  rid_switch2_ocvm_axim_ib_axi4_s;
wire           rlast_switch2_ocvm_axim_ib_axi4_s;
wire   [1:0]   rresp_switch2_ocvm_axim_ib_axi4_s;
wire           ruser_switch2_ocvm_axim_ib_axi4_s;
wire           rvalid_switch2_ocvm_axim_ib_axi4_s;
wire   [72:0]  w_data_ocvm_axim_ib_int;
wire           w_valid_ocvm_axim_ib_int;
wire           wready_switch2_ocvm_axim_ib_axi4_s;
wire   [71:0]  pfwdpayld_secenc_axis_ib_apb_int;
wire           preq_secenc_axis_ib_apb_int;
wire   [1:0]   ar_rpntr_bin_secenc_axis_ib_int;
wire   [2:0]   ar_rpntr_gry_secenc_axis_ib_int;
wire   [39:0]  araddr_secenc_axis_ib_switch1_axi_s_0;
wire   [1:0]   arburst_secenc_axis_ib_switch1_axi_s_0;
wire   [3:0]   arcache_secenc_axis_ib_switch1_axi_s_0;
wire   [11:0]  arid_secenc_axis_ib_switch1_axi_s_0;
wire   [7:0]   arlen_secenc_axis_ib_switch1_axi_s_0;
wire           arlock_secenc_axis_ib_switch1_axi_s_0;
wire   [2:0]   arprot_secenc_axis_ib_switch1_axi_s_0;
wire   [3:0]   arqv_secenc_axis_ib_switch1_axi_s_0;
wire   [2:0]   arsize_secenc_axis_ib_switch1_axi_s_0;
wire   [9:0]   aruser_secenc_axis_ib_switch1_axi_s_0;
wire           arvalid_secenc_axis_ib_switch1_axi_s_0;
wire   [10:0]  arvalid_vect_secenc_axis_ib_switch1_axi_s_0;
wire   [1:0]   aw_rpntr_bin_secenc_axis_ib_int;
wire   [2:0]   aw_rpntr_gry_secenc_axis_ib_int;
wire   [39:0]  awaddr_secenc_axis_ib_switch1_axi_s_0;
wire   [1:0]   awburst_secenc_axis_ib_switch1_axi_s_0;
wire   [3:0]   awcache_secenc_axis_ib_switch1_axi_s_0;
wire   [11:0]  awid_secenc_axis_ib_switch1_axi_s_0;
wire   [7:0]   awlen_secenc_axis_ib_switch1_axi_s_0;
wire           awlock_secenc_axis_ib_switch1_axi_s_0;
wire   [2:0]   awprot_secenc_axis_ib_switch1_axi_s_0;
wire   [3:0]   awqv_secenc_axis_ib_switch1_axi_s_0;
wire   [2:0]   awsize_secenc_axis_ib_switch1_axi_s_0;
wire   [9:0]   awuser_secenc_axis_ib_switch1_axi_s_0;
wire           awvalid_secenc_axis_ib_switch1_axi_s_0;
wire   [10:0]  awvalid_vect_secenc_axis_ib_switch1_axi_s_0;
wire   [10:0]  b_data_secenc_axis_ib_int;
wire   [2:0]   b_wpntr_gry_secenc_axis_ib_int;
wire           bready_secenc_axis_ib_switch1_axi_s_0;
wire   [43:0]  r_data_secenc_axis_ib_int;
wire   [2:0]   r_wpntr_gry_secenc_axis_ib_int;
wire           rready_secenc_axis_ib_switch1_axi_s_0;
wire   [1:0]   w_rpntr_bin_secenc_axis_ib_int;
wire   [2:0]   w_rpntr_gry_secenc_axis_ib_int;
wire   [31:0]  wdata_secenc_axis_ib_switch1_axi_s_0;
wire           wlast_secenc_axis_ib_switch1_axi_s_0;
wire   [3:0]   wstrb_secenc_axis_ib_switch1_axi_s_0;
wire           wvalid_secenc_axis_ib_switch1_axi_s_0;
wire           pack_secenc_axis_ib_apb_int;
wire   [32:0]  prevpayld_secenc_axis_ib_apb_int;
wire   [89:0]  ar_data_secenc_axis_ib_int;
wire   [2:0]   ar_wpntr_gry_secenc_axis_ib_int;
wire           arready_secenc_axis_secenc_axis_ib_axi4_s;
wire   [89:0]  aw_data_secenc_axis_ib_int;
wire   [2:0]   aw_wpntr_gry_secenc_axis_ib_int;
wire           awready_secenc_axis_secenc_axis_ib_axi4_s;
wire   [1:0]   b_rpntr_bin_secenc_axis_ib_int;
wire   [2:0]   b_rpntr_gry_secenc_axis_ib_int;
wire   [7:0]   bid_secenc_axis_secenc_axis_ib_axi4_s;
wire   [1:0]   bresp_secenc_axis_secenc_axis_ib_axi4_s;
wire           buser_secenc_axis_secenc_axis_ib_axi4_s;
wire           bvalid_secenc_axis_secenc_axis_ib_axi4_s;
wire   [31:0]  paddr_secenc_axis_apb;
wire           penable_secenc_axis_apb;
wire           pselx_secenc_axis_apb;
wire   [31:0]  pwdata_secenc_axis_apb;
wire           pwrite_secenc_axis_apb;
wire   [1:0]   r_rpntr_bin_secenc_axis_ib_int;
wire   [2:0]   r_rpntr_gry_secenc_axis_ib_int;
wire   [31:0]  rdata_secenc_axis_secenc_axis_ib_axi4_s;
wire   [7:0]   rid_secenc_axis_secenc_axis_ib_axi4_s;
wire           rlast_secenc_axis_secenc_axis_ib_axi4_s;
wire   [1:0]   rresp_secenc_axis_secenc_axis_ib_axi4_s;
wire           ruser_secenc_axis_secenc_axis_ib_axi4_s;
wire           rvalid_secenc_axis_secenc_axis_ib_axi4_s;
wire   [36:0]  w_data_secenc_axis_ib_int;
wire   [2:0]   w_wpntr_gry_secenc_axis_ib_int;
wire           wready_secenc_axis_secenc_axis_ib_axi4_s;
wire           ar_ready_xnvm_axim_ib_int;
wire   [31:0]  araddr_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [1:0]   arburst_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [3:0]   arcache_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [11:0]  arid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [7:0]   arlen_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire           arlock_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [2:0]   arprot_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [3:0]   arqv_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [2:0]   arsize_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [9:0]   aruser_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire           arvalid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire           aw_ready_xnvm_axim_ib_int;
wire   [31:0]  awaddr_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [1:0]   awburst_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [3:0]   awcache_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [11:0]  awid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [7:0]   awlen_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire           awlock_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [2:0]   awprot_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [3:0]   awqv_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [2:0]   awsize_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [9:0]   awuser_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire           awvalid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [14:0]  b_data_xnvm_axim_ib_int;
wire           b_valid_xnvm_axim_ib_int;
wire           bready_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [79:0]  r_data_xnvm_axim_ib_int;
wire           r_valid_xnvm_axim_ib_int;
wire           rready_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire           w_ready_xnvm_axim_ib_int;
wire   [63:0]  wdata_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire           wlast_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [7:0]   wstrb_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire           wvalid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s;
wire   [78:0]  ar_data_xnvm_axim_ib_int;
wire           ar_valid_xnvm_axim_ib_int;
wire           arready_switch2_xnvm_axim_ib_axi4_s;
wire   [78:0]  aw_data_xnvm_axim_ib_int;
wire           aw_valid_xnvm_axim_ib_int;
wire           awready_switch2_xnvm_axim_ib_axi4_s;
wire           b_ready_xnvm_axim_ib_int;
wire   [11:0]  bid_switch2_xnvm_axim_ib_axi4_s;
wire   [1:0]   bresp_switch2_xnvm_axim_ib_axi4_s;
wire           buser_switch2_xnvm_axim_ib_axi4_s;
wire           bvalid_switch2_xnvm_axim_ib_axi4_s;
wire           r_ready_xnvm_axim_ib_int;
wire   [63:0]  rdata_switch2_xnvm_axim_ib_axi4_s;
wire   [11:0]  rid_switch2_xnvm_axim_ib_axi4_s;
wire           rlast_switch2_xnvm_axim_ib_axi4_s;
wire   [1:0]   rresp_switch2_xnvm_axim_ib_axi4_s;
wire           ruser_switch2_xnvm_axim_ib_axi4_s;
wire           rvalid_switch2_xnvm_axim_ib_axi4_s;
wire   [72:0]  w_data_xnvm_axim_ib_int;
wire           w_valid_xnvm_axim_ib_int;
wire           wready_switch2_xnvm_axim_ib_axi4_s;
wire   [51:0]  a_data_gpvmain_ahb_ib_int;
wire           a_ready_gpv_0_ib1_int;
wire           a_valid_gpvmain_ahb_ib_int;
wire           aclk;
wire   [31:0]  araddr_debug_axis;
wire   [31:0]  araddr_expslv0_axis;
wire   [31:0]  araddr_expslv1_axis;
wire   [31:0]  araddr_extsys0_axis;
wire   [31:0]  araddr_extsys1_axis;
wire   [39:0]  araddr_hostcpu_axis;
wire   [39:0]  araddr_secenc_axis;
wire   [1:0]   arburst_debug_axis;
wire   [1:0]   arburst_expslv0_axis;
wire   [1:0]   arburst_expslv1_axis;
wire   [1:0]   arburst_extsys0_axis;
wire   [1:0]   arburst_extsys1_axis;
wire   [1:0]   arburst_hostcpu_axis;
wire   [1:0]   arburst_secenc_axis;
wire   [3:0]   arcache_debug_axis;
wire   [3:0]   arcache_expslv0_axis;
wire   [3:0]   arcache_expslv1_axis;
wire   [3:0]   arcache_extsys0_axis;
wire   [3:0]   arcache_extsys1_axis;
wire   [3:0]   arcache_hostcpu_axis;
wire   [3:0]   arcache_secenc_axis;
wire           aresetn;
wire   [3:0]   arid_debug_axis;
wire   [7:0]   arid_expslv0_axis;
wire   [7:0]   arid_expslv1_axis;
wire   [7:0]   arid_extsys0_axis;
wire   [7:0]   arid_extsys1_axis;
wire   [7:0]   arid_hostcpu_axis;
wire   [7:0]   arid_secenc_axis;
wire   [7:0]   arlen_debug_axis;
wire   [7:0]   arlen_expslv0_axis;
wire   [7:0]   arlen_expslv1_axis;
wire   [7:0]   arlen_extsys0_axis;
wire   [7:0]   arlen_extsys1_axis;
wire   [7:0]   arlen_hostcpu_axis;
wire   [7:0]   arlen_secenc_axis;
wire           arlock_debug_axis;
wire           arlock_expslv0_axis;
wire           arlock_expslv1_axis;
wire           arlock_extsys0_axis;
wire           arlock_extsys1_axis;
wire           arlock_hostcpu_axis;
wire           arlock_secenc_axis;
wire   [2:0]   arprot_debug_axis;
wire   [2:0]   arprot_expslv0_axis;
wire   [2:0]   arprot_expslv1_axis;
wire   [2:0]   arprot_extsys0_axis;
wire   [2:0]   arprot_extsys1_axis;
wire   [2:0]   arprot_hostcpu_axis;
wire   [2:0]   arprot_secenc_axis;
wire   [3:0]   arqos_expslv0_axis;
wire   [3:0]   arqos_expslv1_axis;
wire           arready_bootreg_axim;
wire           arready_cvm_axim;
wire           arready_debug_axim;
wire           arready_expmstr0_axim;
wire           arready_expmstr1_axim;
wire           arready_firewall_axim;
wire           arready_ocvm_axim;
wire           arready_sysctrl_axim;
wire           arready_sysperi_axim;
wire           arready_xnvm_axim;
wire   [2:0]   arsize_debug_axis;
wire   [2:0]   arsize_expslv0_axis;
wire   [2:0]   arsize_expslv1_axis;
wire   [2:0]   arsize_extsys0_axis;
wire   [2:0]   arsize_extsys1_axis;
wire   [2:0]   arsize_hostcpu_axis;
wire   [2:0]   arsize_secenc_axis;
wire   [9:0]   aruser_debug_axis;
wire   [9:0]   aruser_expslv0_axis;
wire   [9:0]   aruser_expslv1_axis;
wire   [9:0]   aruser_extsys0_axis;
wire   [9:0]   aruser_extsys1_axis;
wire   [9:0]   aruser_hostcpu_axis;
wire   [9:0]   aruser_secenc_axis;
wire           arvalid_debug_axis;
wire           arvalid_expslv0_axis;
wire           arvalid_expslv1_axis;
wire           arvalid_extsys0_axis;
wire           arvalid_extsys1_axis;
wire           arvalid_hostcpu_axis;
wire           arvalid_secenc_axis;
wire   [31:0]  awaddr_debug_axis;
wire   [31:0]  awaddr_expslv0_axis;
wire   [31:0]  awaddr_expslv1_axis;
wire   [31:0]  awaddr_extsys0_axis;
wire   [31:0]  awaddr_extsys1_axis;
wire   [39:0]  awaddr_hostcpu_axis;
wire   [39:0]  awaddr_secenc_axis;
wire   [1:0]   awburst_debug_axis;
wire   [1:0]   awburst_expslv0_axis;
wire   [1:0]   awburst_expslv1_axis;
wire   [1:0]   awburst_extsys0_axis;
wire   [1:0]   awburst_extsys1_axis;
wire   [1:0]   awburst_hostcpu_axis;
wire   [1:0]   awburst_secenc_axis;
wire   [3:0]   awcache_debug_axis;
wire   [3:0]   awcache_expslv0_axis;
wire   [3:0]   awcache_expslv1_axis;
wire   [3:0]   awcache_extsys0_axis;
wire   [3:0]   awcache_extsys1_axis;
wire   [3:0]   awcache_hostcpu_axis;
wire   [3:0]   awcache_secenc_axis;
wire   [3:0]   awid_debug_axis;
wire   [7:0]   awid_expslv0_axis;
wire   [7:0]   awid_expslv1_axis;
wire   [7:0]   awid_extsys0_axis;
wire   [7:0]   awid_extsys1_axis;
wire   [7:0]   awid_hostcpu_axis;
wire   [7:0]   awid_secenc_axis;
wire   [7:0]   awlen_debug_axis;
wire   [7:0]   awlen_expslv0_axis;
wire   [7:0]   awlen_expslv1_axis;
wire   [7:0]   awlen_extsys0_axis;
wire   [7:0]   awlen_extsys1_axis;
wire   [7:0]   awlen_hostcpu_axis;
wire   [7:0]   awlen_secenc_axis;
wire           awlock_debug_axis;
wire           awlock_expslv0_axis;
wire           awlock_expslv1_axis;
wire           awlock_extsys0_axis;
wire           awlock_extsys1_axis;
wire           awlock_hostcpu_axis;
wire           awlock_secenc_axis;
wire   [2:0]   awprot_debug_axis;
wire   [2:0]   awprot_expslv0_axis;
wire   [2:0]   awprot_expslv1_axis;
wire   [2:0]   awprot_extsys0_axis;
wire   [2:0]   awprot_extsys1_axis;
wire   [2:0]   awprot_hostcpu_axis;
wire   [2:0]   awprot_secenc_axis;
wire   [3:0]   awqos_expslv0_axis;
wire   [3:0]   awqos_expslv1_axis;
wire           awready_bootreg_axim;
wire           awready_cvm_axim;
wire           awready_debug_axim;
wire           awready_expmstr0_axim;
wire           awready_expmstr1_axim;
wire           awready_firewall_axim;
wire           awready_ocvm_axim;
wire           awready_sysctrl_axim;
wire           awready_sysperi_axim;
wire           awready_xnvm_axim;
wire   [2:0]   awsize_debug_axis;
wire   [2:0]   awsize_expslv0_axis;
wire   [2:0]   awsize_expslv1_axis;
wire   [2:0]   awsize_extsys0_axis;
wire   [2:0]   awsize_extsys1_axis;
wire   [2:0]   awsize_hostcpu_axis;
wire   [2:0]   awsize_secenc_axis;
wire   [9:0]   awuser_debug_axis;
wire   [9:0]   awuser_expslv0_axis;
wire   [9:0]   awuser_expslv1_axis;
wire   [9:0]   awuser_extsys0_axis;
wire   [9:0]   awuser_extsys1_axis;
wire   [9:0]   awuser_hostcpu_axis;
wire   [9:0]   awuser_secenc_axis;
wire           awvalid_debug_axis;
wire           awvalid_expslv0_axis;
wire           awvalid_expslv1_axis;
wire           awvalid_extsys0_axis;
wire           awvalid_extsys1_axis;
wire           awvalid_hostcpu_axis;
wire           awvalid_secenc_axis;
wire   [9:0]   bid_bootreg_axim;
wire   [11:0]  bid_cvm_axim;
wire   [8:0]   bid_debug_axim;
wire   [11:0]  bid_expmstr0_axim;
wire   [11:0]  bid_expmstr1_axim;
wire   [9:0]   bid_firewall_axim;
wire   [11:0]  bid_ocvm_axim;
wire   [11:0]  bid_sysctrl_axim;
wire   [11:0]  bid_sysperi_axim;
wire   [11:0]  bid_xnvm_axim;
wire           bready_debug_axis;
wire           bready_expslv0_axis;
wire           bready_expslv1_axis;
wire           bready_extsys0_axis;
wire           bready_extsys1_axis;
wire           bready_hostcpu_axis;
wire           bready_secenc_axis;
wire   [1:0]   bresp_bootreg_axim;
wire   [1:0]   bresp_cvm_axim;
wire   [1:0]   bresp_debug_axim;
wire   [1:0]   bresp_expmstr0_axim;
wire   [1:0]   bresp_expmstr1_axim;
wire   [1:0]   bresp_firewall_axim;
wire   [1:0]   bresp_ocvm_axim;
wire   [1:0]   bresp_sysctrl_axim;
wire   [1:0]   bresp_sysperi_axim;
wire   [1:0]   bresp_xnvm_axim;
wire           buser_cvm_axim;
wire           buser_debug_axim;
wire           buser_expmstr0_axim;
wire           buser_expmstr1_axim;
wire           buser_firewall_axim;
wire           buser_ocvm_axim;
wire           buser_sysctrl_axim;
wire           buser_sysperi_axim;
wire           buser_xnvm_axim;
wire           bvalid_bootreg_axim;
wire           bvalid_cvm_axim;
wire           bvalid_debug_axim;
wire           bvalid_expmstr0_axim;
wire           bvalid_expmstr1_axim;
wire           bvalid_firewall_axim;
wire           bvalid_ocvm_axim;
wire           bvalid_sysctrl_axim;
wire           bvalid_sysperi_axim;
wire           bvalid_xnvm_axim;
wire           csysreq_cd_a;
wire   [47:0]  d_data_gpv_0_ib1_int;
wire           d_ready_gpvmain_ahb_ib_int;
wire           d_valid_gpv_0_ib1_int;
wire           empty_gpvmain_ahb_ib_int;
wire   [31:0]  paddr_debug_axis_ib_apb;
wire   [31:0]  paddr_extsys0_axis_ib_apb;
wire   [31:0]  paddr_extsys1_axis_ib_apb;
wire   [31:0]  paddr_hostcpu_axis_ib_apb;
wire   [31:0]  paddr_secenc_axis_ib_apb;
wire           penable_debug_axis_ib_apb;
wire           penable_extsys0_axis_ib_apb;
wire           penable_extsys1_axis_ib_apb;
wire           penable_hostcpu_axis_ib_apb;
wire           penable_secenc_axis_ib_apb;
wire           pselx_debug_axis_ib_apb;
wire           pselx_extsys0_axis_ib_apb;
wire           pselx_extsys1_axis_ib_apb;
wire           pselx_hostcpu_axis_ib_apb;
wire           pselx_secenc_axis_ib_apb;
wire   [31:0]  pwdata_debug_axis_ib_apb;
wire   [31:0]  pwdata_extsys0_axis_ib_apb;
wire   [31:0]  pwdata_extsys1_axis_ib_apb;
wire   [31:0]  pwdata_hostcpu_axis_ib_apb;
wire   [31:0]  pwdata_secenc_axis_ib_apb;
wire           pwrite_debug_axis_ib_apb;
wire           pwrite_extsys0_axis_ib_apb;
wire           pwrite_extsys1_axis_ib_apb;
wire           pwrite_hostcpu_axis_ib_apb;
wire           pwrite_secenc_axis_ib_apb;
wire   [31:0]  rdata_bootreg_axim;
wire   [63:0]  rdata_cvm_axim;
wire   [31:0]  rdata_debug_axim;
wire   [63:0]  rdata_expmstr0_axim;
wire   [63:0]  rdata_expmstr1_axim;
wire   [31:0]  rdata_firewall_axim;
wire   [63:0]  rdata_ocvm_axim;
wire   [31:0]  rdata_sysctrl_axim;
wire   [31:0]  rdata_sysperi_axim;
wire   [63:0]  rdata_xnvm_axim;
wire   [9:0]   rid_bootreg_axim;
wire   [11:0]  rid_cvm_axim;
wire   [8:0]   rid_debug_axim;
wire   [11:0]  rid_expmstr0_axim;
wire   [11:0]  rid_expmstr1_axim;
wire   [9:0]   rid_firewall_axim;
wire   [11:0]  rid_ocvm_axim;
wire   [11:0]  rid_sysctrl_axim;
wire   [11:0]  rid_sysperi_axim;
wire   [11:0]  rid_xnvm_axim;
wire           rlast_bootreg_axim;
wire           rlast_cvm_axim;
wire           rlast_debug_axim;
wire           rlast_expmstr0_axim;
wire           rlast_expmstr1_axim;
wire           rlast_firewall_axim;
wire           rlast_ocvm_axim;
wire           rlast_sysctrl_axim;
wire           rlast_sysperi_axim;
wire           rlast_xnvm_axim;
wire           rready_debug_axis;
wire           rready_expslv0_axis;
wire           rready_expslv1_axis;
wire           rready_extsys0_axis;
wire           rready_extsys1_axis;
wire           rready_hostcpu_axis;
wire           rready_secenc_axis;
wire   [1:0]   rresp_bootreg_axim;
wire   [1:0]   rresp_cvm_axim;
wire   [1:0]   rresp_debug_axim;
wire   [1:0]   rresp_expmstr0_axim;
wire   [1:0]   rresp_expmstr1_axim;
wire   [1:0]   rresp_firewall_axim;
wire   [1:0]   rresp_ocvm_axim;
wire   [1:0]   rresp_sysctrl_axim;
wire   [1:0]   rresp_sysperi_axim;
wire   [1:0]   rresp_xnvm_axim;
wire           ruser_cvm_axim;
wire           ruser_debug_axim;
wire           ruser_expmstr0_axim;
wire           ruser_expmstr1_axim;
wire           ruser_firewall_axim;
wire           ruser_ocvm_axim;
wire           ruser_sysctrl_axim;
wire           ruser_sysperi_axim;
wire           ruser_xnvm_axim;
wire           rvalid_bootreg_axim;
wire           rvalid_cvm_axim;
wire           rvalid_debug_axim;
wire           rvalid_expmstr0_axim;
wire           rvalid_expmstr1_axim;
wire           rvalid_firewall_axim;
wire           rvalid_ocvm_axim;
wire           rvalid_sysctrl_axim;
wire           rvalid_sysperi_axim;
wire           rvalid_xnvm_axim;
wire   [36:0]  w_data_gpvmain_ahb_ib_int;
wire           w_ready_gpv_0_ib1_int;
wire           w_valid_gpvmain_ahb_ib_int;
wire   [63:0]  wdata_debug_axis;
wire   [63:0]  wdata_expslv0_axis;
wire   [63:0]  wdata_expslv1_axis;
wire   [63:0]  wdata_extsys0_axis;
wire   [63:0]  wdata_extsys1_axis;
wire   [127:0] wdata_hostcpu_axis;
wire   [31:0]  wdata_secenc_axis;
wire           wlast_debug_axis;
wire           wlast_expslv0_axis;
wire           wlast_expslv1_axis;
wire           wlast_extsys0_axis;
wire           wlast_extsys1_axis;
wire           wlast_hostcpu_axis;
wire           wlast_secenc_axis;
wire           wready_bootreg_axim;
wire           wready_cvm_axim;
wire           wready_debug_axim;
wire           wready_expmstr0_axim;
wire           wready_expmstr1_axim;
wire           wready_firewall_axim;
wire           wready_ocvm_axim;
wire           wready_sysctrl_axim;
wire           wready_sysperi_axim;
wire           wready_xnvm_axim;
wire   [7:0]   wstrb_debug_axis;
wire   [7:0]   wstrb_expslv0_axis;
wire   [7:0]   wstrb_expslv1_axis;
wire   [7:0]   wstrb_extsys0_axis;
wire   [7:0]   wstrb_extsys1_axis;
wire   [15:0]  wstrb_hostcpu_axis;
wire   [3:0]   wstrb_secenc_axis;
wire           wvalid_debug_axis;
wire           wvalid_expslv0_axis;
wire           wvalid_expslv1_axis;
wire           wvalid_extsys0_axis;
wire           wvalid_extsys1_axis;
wire           wvalid_hostcpu_axis;
wire           wvalid_secenc_axis;




nic400_amib_bootreg_axim_sse710_main     u_amib_bootreg_axim (
  .awid_bootreg_axim_m  (awid_bootreg_axim),
  .awaddr_bootreg_axim_m (awaddr_bootreg_axim),
  .awlen_bootreg_axim_m (awlen_bootreg_axim),
  .awsize_bootreg_axim_m (awsize_bootreg_axim),
  .awburst_bootreg_axim_m (awburst_bootreg_axim),
  .awlock_bootreg_axim_m (awlock_bootreg_axim),
  .awcache_bootreg_axim_m (awcache_bootreg_axim),
  .awprot_bootreg_axim_m (awprot_bootreg_axim),
  .awvalid_bootreg_axim_m (awvalid_bootreg_axim),
  .awready_bootreg_axim_m (awready_bootreg_axim),
  .wdata_bootreg_axim_m (wdata_bootreg_axim),
  .wstrb_bootreg_axim_m (wstrb_bootreg_axim),
  .wlast_bootreg_axim_m (wlast_bootreg_axim),
  .wvalid_bootreg_axim_m (wvalid_bootreg_axim),
  .wready_bootreg_axim_m (wready_bootreg_axim),
  .bid_bootreg_axim_m   (bid_bootreg_axim),
  .bresp_bootreg_axim_m (bresp_bootreg_axim),
  .bvalid_bootreg_axim_m (bvalid_bootreg_axim),
  .bready_bootreg_axim_m (bready_bootreg_axim),
  .arid_bootreg_axim_m  (arid_bootreg_axim),
  .araddr_bootreg_axim_m (araddr_bootreg_axim),
  .arlen_bootreg_axim_m (arlen_bootreg_axim),
  .arsize_bootreg_axim_m (arsize_bootreg_axim),
  .arburst_bootreg_axim_m (arburst_bootreg_axim),
  .arlock_bootreg_axim_m (arlock_bootreg_axim),
  .arcache_bootreg_axim_m (arcache_bootreg_axim),
  .arprot_bootreg_axim_m (arprot_bootreg_axim),
  .arvalid_bootreg_axim_m (arvalid_bootreg_axim),
  .arready_bootreg_axim_m (arready_bootreg_axim),
  .rid_bootreg_axim_m   (rid_bootreg_axim),
  .rdata_bootreg_axim_m (rdata_bootreg_axim),
  .rresp_bootreg_axim_m (rresp_bootreg_axim),
  .rlast_bootreg_axim_m (rlast_bootreg_axim),
  .rvalid_bootreg_axim_m (rvalid_bootreg_axim),
  .rready_bootreg_axim_m (rready_bootreg_axim),
  .awuser_bootreg_axim_m (awuser_bootreg_axim),
  .aruser_bootreg_axim_m (aruser_bootreg_axim),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .awid_bootreg_axim_s  (awid_switch3_bootreg_axim_bootreg_axim_s),
  .awaddr_bootreg_axim_s (awaddr_switch3_bootreg_axim_bootreg_axim_s),
  .awlen_bootreg_axim_s (awlen_switch3_bootreg_axim_bootreg_axim_s),
  .awsize_bootreg_axim_s (awsize_switch3_bootreg_axim_bootreg_axim_s),
  .awburst_bootreg_axim_s (awburst_switch3_bootreg_axim_bootreg_axim_s),
  .awlock_bootreg_axim_s (awlock_switch3_bootreg_axim_bootreg_axim_s),
  .awcache_bootreg_axim_s (awcache_switch3_bootreg_axim_bootreg_axim_s),
  .awprot_bootreg_axim_s (awprot_switch3_bootreg_axim_bootreg_axim_s),
  .awvalid_bootreg_axim_s (awvalid_switch3_bootreg_axim_bootreg_axim_s),
  .awready_bootreg_axim_s (awready_switch3_bootreg_axim_bootreg_axim_s),
  .wdata_bootreg_axim_s (wdata_switch3_bootreg_axim_bootreg_axim_s),
  .wstrb_bootreg_axim_s (wstrb_switch3_bootreg_axim_bootreg_axim_s),
  .wlast_bootreg_axim_s (wlast_switch3_bootreg_axim_bootreg_axim_s),
  .wvalid_bootreg_axim_s (wvalid_switch3_bootreg_axim_bootreg_axim_s),
  .wready_bootreg_axim_s (wready_switch3_bootreg_axim_bootreg_axim_s),
  .bid_bootreg_axim_s   (bid_switch3_bootreg_axim_bootreg_axim_s),
  .bresp_bootreg_axim_s (bresp_switch3_bootreg_axim_bootreg_axim_s),
  .bvalid_bootreg_axim_s (bvalid_switch3_bootreg_axim_bootreg_axim_s),
  .bready_bootreg_axim_s (bready_switch3_bootreg_axim_bootreg_axim_s),
  .arid_bootreg_axim_s  (arid_switch3_bootreg_axim_bootreg_axim_s),
  .araddr_bootreg_axim_s (araddr_switch3_bootreg_axim_bootreg_axim_s),
  .arlen_bootreg_axim_s (arlen_switch3_bootreg_axim_bootreg_axim_s),
  .arsize_bootreg_axim_s (arsize_switch3_bootreg_axim_bootreg_axim_s),
  .arburst_bootreg_axim_s (arburst_switch3_bootreg_axim_bootreg_axim_s),
  .arlock_bootreg_axim_s (arlock_switch3_bootreg_axim_bootreg_axim_s),
  .arcache_bootreg_axim_s (arcache_switch3_bootreg_axim_bootreg_axim_s),
  .arprot_bootreg_axim_s (arprot_switch3_bootreg_axim_bootreg_axim_s),
  .arvalid_bootreg_axim_s (arvalid_switch3_bootreg_axim_bootreg_axim_s),
  .arready_bootreg_axim_s (arready_switch3_bootreg_axim_bootreg_axim_s),
  .rid_bootreg_axim_s   (rid_switch3_bootreg_axim_bootreg_axim_s),
  .rdata_bootreg_axim_s (rdata_switch3_bootreg_axim_bootreg_axim_s),
  .rresp_bootreg_axim_s (rresp_switch3_bootreg_axim_bootreg_axim_s),
  .rlast_bootreg_axim_s (rlast_switch3_bootreg_axim_bootreg_axim_s),
  .rvalid_bootreg_axim_s (rvalid_switch3_bootreg_axim_bootreg_axim_s),
  .rready_bootreg_axim_s (rready_switch3_bootreg_axim_bootreg_axim_s),
  .awuser_bootreg_axim_s (awuser_switch3_bootreg_axim_bootreg_axim_s),
  .aruser_bootreg_axim_s (aruser_switch3_bootreg_axim_bootreg_axim_s)
);


nic400_amib_cvm_axim_sse710_main     u_amib_cvm_axim (
  .awid_cvm_axim_m      (awid_cvm_axim),
  .awaddr_cvm_axim_m    (awaddr_cvm_axim),
  .awlen_cvm_axim_m     (awlen_cvm_axim),
  .awsize_cvm_axim_m    (awsize_cvm_axim),
  .awburst_cvm_axim_m   (awburst_cvm_axim),
  .awlock_cvm_axim_m    (awlock_cvm_axim),
  .awcache_cvm_axim_m   (awcache_cvm_axim),
  .awprot_cvm_axim_m    (awprot_cvm_axim),
  .awvalid_cvm_axim_m   (awvalid_cvm_axim),
  .awready_cvm_axim_m   (awready_cvm_axim),
  .wdata_cvm_axim_m     (wdata_cvm_axim),
  .wstrb_cvm_axim_m     (wstrb_cvm_axim),
  .wlast_cvm_axim_m     (wlast_cvm_axim),
  .wvalid_cvm_axim_m    (wvalid_cvm_axim),
  .wready_cvm_axim_m    (wready_cvm_axim),
  .bid_cvm_axim_m       (bid_cvm_axim),
  .bresp_cvm_axim_m     (bresp_cvm_axim),
  .bvalid_cvm_axim_m    (bvalid_cvm_axim),
  .bready_cvm_axim_m    (bready_cvm_axim),
  .arid_cvm_axim_m      (arid_cvm_axim),
  .araddr_cvm_axim_m    (araddr_cvm_axim),
  .arlen_cvm_axim_m     (arlen_cvm_axim),
  .arsize_cvm_axim_m    (arsize_cvm_axim),
  .arburst_cvm_axim_m   (arburst_cvm_axim),
  .arlock_cvm_axim_m    (arlock_cvm_axim),
  .arcache_cvm_axim_m   (arcache_cvm_axim),
  .arprot_cvm_axim_m    (arprot_cvm_axim),
  .arvalid_cvm_axim_m   (arvalid_cvm_axim),
  .arready_cvm_axim_m   (arready_cvm_axim),
  .rid_cvm_axim_m       (rid_cvm_axim),
  .rdata_cvm_axim_m     (rdata_cvm_axim),
  .rresp_cvm_axim_m     (rresp_cvm_axim),
  .rlast_cvm_axim_m     (rlast_cvm_axim),
  .rvalid_cvm_axim_m    (rvalid_cvm_axim),
  .rready_cvm_axim_m    (rready_cvm_axim),
  .awuser_cvm_axim_m    (awuser_cvm_axim),
  .buser_cvm_axim_m     (buser_cvm_axim),
  .aruser_cvm_axim_m    (aruser_cvm_axim),
  .ruser_cvm_axim_m     (ruser_cvm_axim),
  .awqv_cvm_axim_m      (awqos_cvm_axim),
  .arqv_cvm_axim_m      (arqos_cvm_axim),
  .awid_cvm_axim_s      (awid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awaddr_cvm_axim_s    (awaddr_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awlen_cvm_axim_s     (awlen_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awsize_cvm_axim_s    (awsize_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awburst_cvm_axim_s   (awburst_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awlock_cvm_axim_s    (awlock_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awcache_cvm_axim_s   (awcache_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awprot_cvm_axim_s    (awprot_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awvalid_cvm_axim_s   (awvalid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awready_cvm_axim_s   (awready_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .wdata_cvm_axim_s     (wdata_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .wstrb_cvm_axim_s     (wstrb_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .wlast_cvm_axim_s     (wlast_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .wvalid_cvm_axim_s    (wvalid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .wready_cvm_axim_s    (wready_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .bid_cvm_axim_s       (bid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .bresp_cvm_axim_s     (bresp_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .bvalid_cvm_axim_s    (bvalid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .bready_cvm_axim_s    (bready_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arid_cvm_axim_s      (arid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .araddr_cvm_axim_s    (araddr_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arlen_cvm_axim_s     (arlen_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arsize_cvm_axim_s    (arsize_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arburst_cvm_axim_s   (arburst_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arlock_cvm_axim_s    (arlock_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arcache_cvm_axim_s   (arcache_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arprot_cvm_axim_s    (arprot_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arvalid_cvm_axim_s   (arvalid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arready_cvm_axim_s   (arready_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .rid_cvm_axim_s       (rid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .rdata_cvm_axim_s     (rdata_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .rresp_cvm_axim_s     (rresp_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .rlast_cvm_axim_s     (rlast_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .rvalid_cvm_axim_s    (rvalid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .rready_cvm_axim_s    (rready_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awuser_cvm_axim_s    (awuser_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .buser_cvm_axim_s     (buser_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .aruser_cvm_axim_s    (aruser_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .ruser_cvm_axim_s     (ruser_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awqv_cvm_axim_s      (awqv_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arqv_cvm_axim_s      (arqv_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .aclk                 (aclk),
  .aresetn              (aresetn)
);


nic400_amib_debug_axim_sse710_main     u_amib_debug_axim (
  .awid_debug_axim_m    (awid_debug_axim),
  .awaddr_debug_axim_m  (awaddr_debug_axim),
  .awlen_debug_axim_m   (awlen_debug_axim),
  .awsize_debug_axim_m  (awsize_debug_axim),
  .awburst_debug_axim_m (awburst_debug_axim),
  .awlock_debug_axim_m  (awlock_debug_axim),
  .awcache_debug_axim_m (awcache_debug_axim),
  .awprot_debug_axim_m  (awprot_debug_axim),
  .awvalid_debug_axim_m (awvalid_debug_axim),
  .awready_debug_axim_m (awready_debug_axim),
  .wdata_debug_axim_m   (wdata_debug_axim),
  .wstrb_debug_axim_m   (wstrb_debug_axim),
  .wlast_debug_axim_m   (wlast_debug_axim),
  .wvalid_debug_axim_m  (wvalid_debug_axim),
  .wready_debug_axim_m  (wready_debug_axim),
  .bid_debug_axim_m     (bid_debug_axim),
  .bresp_debug_axim_m   (bresp_debug_axim),
  .bvalid_debug_axim_m  (bvalid_debug_axim),
  .bready_debug_axim_m  (bready_debug_axim),
  .arid_debug_axim_m    (arid_debug_axim),
  .araddr_debug_axim_m  (araddr_debug_axim),
  .arlen_debug_axim_m   (arlen_debug_axim),
  .arsize_debug_axim_m  (arsize_debug_axim),
  .arburst_debug_axim_m (arburst_debug_axim),
  .arlock_debug_axim_m  (arlock_debug_axim),
  .arcache_debug_axim_m (arcache_debug_axim),
  .arprot_debug_axim_m  (arprot_debug_axim),
  .arvalid_debug_axim_m (arvalid_debug_axim),
  .arready_debug_axim_m (arready_debug_axim),
  .rid_debug_axim_m     (rid_debug_axim),
  .rdata_debug_axim_m   (rdata_debug_axim),
  .rresp_debug_axim_m   (rresp_debug_axim),
  .rlast_debug_axim_m   (rlast_debug_axim),
  .rvalid_debug_axim_m  (rvalid_debug_axim),
  .rready_debug_axim_m  (rready_debug_axim),
  .awuser_debug_axim_m  (awuser_debug_axim),
  .buser_debug_axim_m   (buser_debug_axim),
  .aruser_debug_axim_m  (aruser_debug_axim),
  .ruser_debug_axim_m   (ruser_debug_axim),
  .awid_debug_axim_s    (awid_debug_axim_ib_debug_axim_debug_axim_s),
  .awaddr_debug_axim_s  (awaddr_debug_axim_ib_debug_axim_debug_axim_s),
  .awlen_debug_axim_s   (awlen_debug_axim_ib_debug_axim_debug_axim_s),
  .awsize_debug_axim_s  (awsize_debug_axim_ib_debug_axim_debug_axim_s),
  .awburst_debug_axim_s (awburst_debug_axim_ib_debug_axim_debug_axim_s),
  .awlock_debug_axim_s  (awlock_debug_axim_ib_debug_axim_debug_axim_s),
  .awcache_debug_axim_s (awcache_debug_axim_ib_debug_axim_debug_axim_s),
  .awprot_debug_axim_s  (awprot_debug_axim_ib_debug_axim_debug_axim_s),
  .awvalid_debug_axim_s (awvalid_debug_axim_ib_debug_axim_debug_axim_s),
  .awready_debug_axim_s (awready_debug_axim_ib_debug_axim_debug_axim_s),
  .wdata_debug_axim_s   (wdata_debug_axim_ib_debug_axim_debug_axim_s),
  .wstrb_debug_axim_s   (wstrb_debug_axim_ib_debug_axim_debug_axim_s),
  .wlast_debug_axim_s   (wlast_debug_axim_ib_debug_axim_debug_axim_s),
  .wvalid_debug_axim_s  (wvalid_debug_axim_ib_debug_axim_debug_axim_s),
  .wready_debug_axim_s  (wready_debug_axim_ib_debug_axim_debug_axim_s),
  .bid_debug_axim_s     (bid_debug_axim_ib_debug_axim_debug_axim_s),
  .bresp_debug_axim_s   (bresp_debug_axim_ib_debug_axim_debug_axim_s),
  .bvalid_debug_axim_s  (bvalid_debug_axim_ib_debug_axim_debug_axim_s),
  .bready_debug_axim_s  (bready_debug_axim_ib_debug_axim_debug_axim_s),
  .arid_debug_axim_s    (arid_debug_axim_ib_debug_axim_debug_axim_s),
  .araddr_debug_axim_s  (araddr_debug_axim_ib_debug_axim_debug_axim_s),
  .arlen_debug_axim_s   (arlen_debug_axim_ib_debug_axim_debug_axim_s),
  .arsize_debug_axim_s  (arsize_debug_axim_ib_debug_axim_debug_axim_s),
  .arburst_debug_axim_s (arburst_debug_axim_ib_debug_axim_debug_axim_s),
  .arlock_debug_axim_s  (arlock_debug_axim_ib_debug_axim_debug_axim_s),
  .arcache_debug_axim_s (arcache_debug_axim_ib_debug_axim_debug_axim_s),
  .arprot_debug_axim_s  (arprot_debug_axim_ib_debug_axim_debug_axim_s),
  .arvalid_debug_axim_s (arvalid_debug_axim_ib_debug_axim_debug_axim_s),
  .arready_debug_axim_s (arready_debug_axim_ib_debug_axim_debug_axim_s),
  .rid_debug_axim_s     (rid_debug_axim_ib_debug_axim_debug_axim_s),
  .rdata_debug_axim_s   (rdata_debug_axim_ib_debug_axim_debug_axim_s),
  .rresp_debug_axim_s   (rresp_debug_axim_ib_debug_axim_debug_axim_s),
  .rlast_debug_axim_s   (rlast_debug_axim_ib_debug_axim_debug_axim_s),
  .rvalid_debug_axim_s  (rvalid_debug_axim_ib_debug_axim_debug_axim_s),
  .rready_debug_axim_s  (rready_debug_axim_ib_debug_axim_debug_axim_s),
  .awuser_debug_axim_s  (awuser_debug_axim_ib_debug_axim_debug_axim_s),
  .buser_debug_axim_s   (buser_debug_axim_ib_debug_axim_debug_axim_s),
  .aruser_debug_axim_s  (aruser_debug_axim_ib_debug_axim_debug_axim_s),
  .ruser_debug_axim_s   (ruser_debug_axim_ib_debug_axim_debug_axim_s),
  .aclk                 (aclk),
  .aresetn              (aresetn)
);


nic400_amib_expmstr0_axim_sse710_main     u_amib_expmstr0_axim (
  .awid_expmstr0_axim_m (awid_expmstr0_axim),
  .awaddr_expmstr0_axim_m (awaddr_expmstr0_axim),
  .awlen_expmstr0_axim_m (awlen_expmstr0_axim),
  .awsize_expmstr0_axim_m (awsize_expmstr0_axim),
  .awburst_expmstr0_axim_m (awburst_expmstr0_axim),
  .awlock_expmstr0_axim_m (awlock_expmstr0_axim),
  .awcache_expmstr0_axim_m (awcache_expmstr0_axim),
  .awprot_expmstr0_axim_m (awprot_expmstr0_axim),
  .awvalid_expmstr0_axim_m (awvalid_expmstr0_axim),
  .awready_expmstr0_axim_m (awready_expmstr0_axim),
  .wdata_expmstr0_axim_m (wdata_expmstr0_axim),
  .wstrb_expmstr0_axim_m (wstrb_expmstr0_axim),
  .wlast_expmstr0_axim_m (wlast_expmstr0_axim),
  .wvalid_expmstr0_axim_m (wvalid_expmstr0_axim),
  .wready_expmstr0_axim_m (wready_expmstr0_axim),
  .bid_expmstr0_axim_m  (bid_expmstr0_axim),
  .bresp_expmstr0_axim_m (bresp_expmstr0_axim),
  .bvalid_expmstr0_axim_m (bvalid_expmstr0_axim),
  .bready_expmstr0_axim_m (bready_expmstr0_axim),
  .arid_expmstr0_axim_m (arid_expmstr0_axim),
  .araddr_expmstr0_axim_m (araddr_expmstr0_axim),
  .arlen_expmstr0_axim_m (arlen_expmstr0_axim),
  .arsize_expmstr0_axim_m (arsize_expmstr0_axim),
  .arburst_expmstr0_axim_m (arburst_expmstr0_axim),
  .arlock_expmstr0_axim_m (arlock_expmstr0_axim),
  .arcache_expmstr0_axim_m (arcache_expmstr0_axim),
  .arprot_expmstr0_axim_m (arprot_expmstr0_axim),
  .arvalid_expmstr0_axim_m (arvalid_expmstr0_axim),
  .arready_expmstr0_axim_m (arready_expmstr0_axim),
  .rid_expmstr0_axim_m  (rid_expmstr0_axim),
  .rdata_expmstr0_axim_m (rdata_expmstr0_axim),
  .rresp_expmstr0_axim_m (rresp_expmstr0_axim),
  .rlast_expmstr0_axim_m (rlast_expmstr0_axim),
  .rvalid_expmstr0_axim_m (rvalid_expmstr0_axim),
  .rready_expmstr0_axim_m (rready_expmstr0_axim),
  .awuser_expmstr0_axim_m (awuser_expmstr0_axim),
  .buser_expmstr0_axim_m (buser_expmstr0_axim),
  .aruser_expmstr0_axim_m (aruser_expmstr0_axim),
  .ruser_expmstr0_axim_m (ruser_expmstr0_axim),
  .awqv_expmstr0_axim_m (awqos_expmstr0_axim),
  .arqv_expmstr0_axim_m (arqos_expmstr0_axim),
  .awid_expmstr0_axim_s (awid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awaddr_expmstr0_axim_s (awaddr_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awlen_expmstr0_axim_s (awlen_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awsize_expmstr0_axim_s (awsize_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awburst_expmstr0_axim_s (awburst_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awlock_expmstr0_axim_s (awlock_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awcache_expmstr0_axim_s (awcache_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awprot_expmstr0_axim_s (awprot_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awvalid_expmstr0_axim_s (awvalid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awready_expmstr0_axim_s (awready_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .wdata_expmstr0_axim_s (wdata_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .wstrb_expmstr0_axim_s (wstrb_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .wlast_expmstr0_axim_s (wlast_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .wvalid_expmstr0_axim_s (wvalid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .wready_expmstr0_axim_s (wready_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .bid_expmstr0_axim_s  (bid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .bresp_expmstr0_axim_s (bresp_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .bvalid_expmstr0_axim_s (bvalid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .bready_expmstr0_axim_s (bready_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arid_expmstr0_axim_s (arid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .araddr_expmstr0_axim_s (araddr_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arlen_expmstr0_axim_s (arlen_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arsize_expmstr0_axim_s (arsize_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arburst_expmstr0_axim_s (arburst_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arlock_expmstr0_axim_s (arlock_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arcache_expmstr0_axim_s (arcache_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arprot_expmstr0_axim_s (arprot_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arvalid_expmstr0_axim_s (arvalid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arready_expmstr0_axim_s (arready_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .rid_expmstr0_axim_s  (rid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .rdata_expmstr0_axim_s (rdata_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .rresp_expmstr0_axim_s (rresp_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .rlast_expmstr0_axim_s (rlast_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .rvalid_expmstr0_axim_s (rvalid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .rready_expmstr0_axim_s (rready_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awuser_expmstr0_axim_s (awuser_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .buser_expmstr0_axim_s (buser_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .aruser_expmstr0_axim_s (aruser_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .ruser_expmstr0_axim_s (ruser_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awqv_expmstr0_axim_s (awqv_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arqv_expmstr0_axim_s (arqv_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .aclk                 (aclk),
  .aresetn              (aresetn)
);


nic400_amib_expmstr1_axim_sse710_main     u_amib_expmstr1_axim (
  .awid_expmstr1_axim_m (awid_expmstr1_axim),
  .awaddr_expmstr1_axim_m (awaddr_expmstr1_axim),
  .awlen_expmstr1_axim_m (awlen_expmstr1_axim),
  .awsize_expmstr1_axim_m (awsize_expmstr1_axim),
  .awburst_expmstr1_axim_m (awburst_expmstr1_axim),
  .awlock_expmstr1_axim_m (awlock_expmstr1_axim),
  .awcache_expmstr1_axim_m (awcache_expmstr1_axim),
  .awprot_expmstr1_axim_m (awprot_expmstr1_axim),
  .awvalid_expmstr1_axim_m (awvalid_expmstr1_axim),
  .awready_expmstr1_axim_m (awready_expmstr1_axim),
  .wdata_expmstr1_axim_m (wdata_expmstr1_axim),
  .wstrb_expmstr1_axim_m (wstrb_expmstr1_axim),
  .wlast_expmstr1_axim_m (wlast_expmstr1_axim),
  .wvalid_expmstr1_axim_m (wvalid_expmstr1_axim),
  .wready_expmstr1_axim_m (wready_expmstr1_axim),
  .bid_expmstr1_axim_m  (bid_expmstr1_axim),
  .bresp_expmstr1_axim_m (bresp_expmstr1_axim),
  .bvalid_expmstr1_axim_m (bvalid_expmstr1_axim),
  .bready_expmstr1_axim_m (bready_expmstr1_axim),
  .arid_expmstr1_axim_m (arid_expmstr1_axim),
  .araddr_expmstr1_axim_m (araddr_expmstr1_axim),
  .arlen_expmstr1_axim_m (arlen_expmstr1_axim),
  .arsize_expmstr1_axim_m (arsize_expmstr1_axim),
  .arburst_expmstr1_axim_m (arburst_expmstr1_axim),
  .arlock_expmstr1_axim_m (arlock_expmstr1_axim),
  .arcache_expmstr1_axim_m (arcache_expmstr1_axim),
  .arprot_expmstr1_axim_m (arprot_expmstr1_axim),
  .arvalid_expmstr1_axim_m (arvalid_expmstr1_axim),
  .arready_expmstr1_axim_m (arready_expmstr1_axim),
  .rid_expmstr1_axim_m  (rid_expmstr1_axim),
  .rdata_expmstr1_axim_m (rdata_expmstr1_axim),
  .rresp_expmstr1_axim_m (rresp_expmstr1_axim),
  .rlast_expmstr1_axim_m (rlast_expmstr1_axim),
  .rvalid_expmstr1_axim_m (rvalid_expmstr1_axim),
  .rready_expmstr1_axim_m (rready_expmstr1_axim),
  .awuser_expmstr1_axim_m (awuser_expmstr1_axim),
  .buser_expmstr1_axim_m (buser_expmstr1_axim),
  .aruser_expmstr1_axim_m (aruser_expmstr1_axim),
  .ruser_expmstr1_axim_m (ruser_expmstr1_axim),
  .awqv_expmstr1_axim_m (awqos_expmstr1_axim),
  .arqv_expmstr1_axim_m (arqos_expmstr1_axim),
  .awid_expmstr1_axim_s (awid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awaddr_expmstr1_axim_s (awaddr_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awlen_expmstr1_axim_s (awlen_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awsize_expmstr1_axim_s (awsize_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awburst_expmstr1_axim_s (awburst_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awlock_expmstr1_axim_s (awlock_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awcache_expmstr1_axim_s (awcache_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awprot_expmstr1_axim_s (awprot_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awvalid_expmstr1_axim_s (awvalid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awready_expmstr1_axim_s (awready_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .wdata_expmstr1_axim_s (wdata_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .wstrb_expmstr1_axim_s (wstrb_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .wlast_expmstr1_axim_s (wlast_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .wvalid_expmstr1_axim_s (wvalid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .wready_expmstr1_axim_s (wready_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .bid_expmstr1_axim_s  (bid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .bresp_expmstr1_axim_s (bresp_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .bvalid_expmstr1_axim_s (bvalid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .bready_expmstr1_axim_s (bready_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arid_expmstr1_axim_s (arid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .araddr_expmstr1_axim_s (araddr_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arlen_expmstr1_axim_s (arlen_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arsize_expmstr1_axim_s (arsize_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arburst_expmstr1_axim_s (arburst_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arlock_expmstr1_axim_s (arlock_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arcache_expmstr1_axim_s (arcache_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arprot_expmstr1_axim_s (arprot_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arvalid_expmstr1_axim_s (arvalid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arready_expmstr1_axim_s (arready_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .rid_expmstr1_axim_s  (rid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .rdata_expmstr1_axim_s (rdata_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .rresp_expmstr1_axim_s (rresp_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .rlast_expmstr1_axim_s (rlast_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .rvalid_expmstr1_axim_s (rvalid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .rready_expmstr1_axim_s (rready_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awuser_expmstr1_axim_s (awuser_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .buser_expmstr1_axim_s (buser_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .aruser_expmstr1_axim_s (aruser_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .ruser_expmstr1_axim_s (ruser_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awqv_expmstr1_axim_s (awqv_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arqv_expmstr1_axim_s (arqv_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .aclk                 (aclk),
  .aresetn              (aresetn)
);


nic400_amib_firewall_axim_sse710_main     u_amib_firewall_axim (
  .awid_firewall_axim_m (awid_firewall_axim),
  .awaddr_firewall_axim_m (awaddr_firewall_axim),
  .awlen_firewall_axim_m (awlen_firewall_axim),
  .awsize_firewall_axim_m (awsize_firewall_axim),
  .awburst_firewall_axim_m (awburst_firewall_axim),
  .awlock_firewall_axim_m (awlock_firewall_axim),
  .awcache_firewall_axim_m (awcache_firewall_axim),
  .awprot_firewall_axim_m (awprot_firewall_axim),
  .awvalid_firewall_axim_m (awvalid_firewall_axim),
  .awready_firewall_axim_m (awready_firewall_axim),
  .wdata_firewall_axim_m (wdata_firewall_axim),
  .wstrb_firewall_axim_m (wstrb_firewall_axim),
  .wlast_firewall_axim_m (wlast_firewall_axim),
  .wvalid_firewall_axim_m (wvalid_firewall_axim),
  .wready_firewall_axim_m (wready_firewall_axim),
  .bid_firewall_axim_m  (bid_firewall_axim),
  .bresp_firewall_axim_m (bresp_firewall_axim),
  .bvalid_firewall_axim_m (bvalid_firewall_axim),
  .bready_firewall_axim_m (bready_firewall_axim),
  .arid_firewall_axim_m (arid_firewall_axim),
  .araddr_firewall_axim_m (araddr_firewall_axim),
  .arlen_firewall_axim_m (arlen_firewall_axim),
  .arsize_firewall_axim_m (arsize_firewall_axim),
  .arburst_firewall_axim_m (arburst_firewall_axim),
  .arlock_firewall_axim_m (arlock_firewall_axim),
  .arcache_firewall_axim_m (arcache_firewall_axim),
  .arprot_firewall_axim_m (arprot_firewall_axim),
  .arvalid_firewall_axim_m (arvalid_firewall_axim),
  .arready_firewall_axim_m (arready_firewall_axim),
  .rid_firewall_axim_m  (rid_firewall_axim),
  .rdata_firewall_axim_m (rdata_firewall_axim),
  .rresp_firewall_axim_m (rresp_firewall_axim),
  .rlast_firewall_axim_m (rlast_firewall_axim),
  .rvalid_firewall_axim_m (rvalid_firewall_axim),
  .rready_firewall_axim_m (rready_firewall_axim),
  .awuser_firewall_axim_m (awuser_firewall_axim),
  .buser_firewall_axim_m (buser_firewall_axim),
  .aruser_firewall_axim_m (aruser_firewall_axim),
  .ruser_firewall_axim_m (ruser_firewall_axim),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .awid_firewall_axim_s (awid_switch3_firewall_axim_firewall_axim_s),
  .awaddr_firewall_axim_s (awaddr_switch3_firewall_axim_firewall_axim_s),
  .awlen_firewall_axim_s (awlen_switch3_firewall_axim_firewall_axim_s),
  .awsize_firewall_axim_s (awsize_switch3_firewall_axim_firewall_axim_s),
  .awburst_firewall_axim_s (awburst_switch3_firewall_axim_firewall_axim_s),
  .awlock_firewall_axim_s (awlock_switch3_firewall_axim_firewall_axim_s),
  .awcache_firewall_axim_s (awcache_switch3_firewall_axim_firewall_axim_s),
  .awprot_firewall_axim_s (awprot_switch3_firewall_axim_firewall_axim_s),
  .awvalid_firewall_axim_s (awvalid_switch3_firewall_axim_firewall_axim_s),
  .awready_firewall_axim_s (awready_switch3_firewall_axim_firewall_axim_s),
  .wdata_firewall_axim_s (wdata_switch3_firewall_axim_firewall_axim_s),
  .wstrb_firewall_axim_s (wstrb_switch3_firewall_axim_firewall_axim_s),
  .wlast_firewall_axim_s (wlast_switch3_firewall_axim_firewall_axim_s),
  .wvalid_firewall_axim_s (wvalid_switch3_firewall_axim_firewall_axim_s),
  .wready_firewall_axim_s (wready_switch3_firewall_axim_firewall_axim_s),
  .bid_firewall_axim_s  (bid_switch3_firewall_axim_firewall_axim_s),
  .bresp_firewall_axim_s (bresp_switch3_firewall_axim_firewall_axim_s),
  .bvalid_firewall_axim_s (bvalid_switch3_firewall_axim_firewall_axim_s),
  .bready_firewall_axim_s (bready_switch3_firewall_axim_firewall_axim_s),
  .arid_firewall_axim_s (arid_switch3_firewall_axim_firewall_axim_s),
  .araddr_firewall_axim_s (araddr_switch3_firewall_axim_firewall_axim_s),
  .arlen_firewall_axim_s (arlen_switch3_firewall_axim_firewall_axim_s),
  .arsize_firewall_axim_s (arsize_switch3_firewall_axim_firewall_axim_s),
  .arburst_firewall_axim_s (arburst_switch3_firewall_axim_firewall_axim_s),
  .arlock_firewall_axim_s (arlock_switch3_firewall_axim_firewall_axim_s),
  .arcache_firewall_axim_s (arcache_switch3_firewall_axim_firewall_axim_s),
  .arprot_firewall_axim_s (arprot_switch3_firewall_axim_firewall_axim_s),
  .arvalid_firewall_axim_s (arvalid_switch3_firewall_axim_firewall_axim_s),
  .arready_firewall_axim_s (arready_switch3_firewall_axim_firewall_axim_s),
  .rid_firewall_axim_s  (rid_switch3_firewall_axim_firewall_axim_s),
  .rdata_firewall_axim_s (rdata_switch3_firewall_axim_firewall_axim_s),
  .rresp_firewall_axim_s (rresp_switch3_firewall_axim_firewall_axim_s),
  .rlast_firewall_axim_s (rlast_switch3_firewall_axim_firewall_axim_s),
  .rvalid_firewall_axim_s (rvalid_switch3_firewall_axim_firewall_axim_s),
  .rready_firewall_axim_s (rready_switch3_firewall_axim_firewall_axim_s),
  .awuser_firewall_axim_s (awuser_switch3_firewall_axim_firewall_axim_s),
  .buser_firewall_axim_s (buser_switch3_firewall_axim_firewall_axim_s),
  .aruser_firewall_axim_s (aruser_switch3_firewall_axim_firewall_axim_s),
  .ruser_firewall_axim_s (ruser_switch3_firewall_axim_firewall_axim_s)
);


nic400_amib_ocvm_axim_sse710_main     u_amib_ocvm_axim (
  .awid_ocvm_axim_m     (awid_ocvm_axim),
  .awaddr_ocvm_axim_m   (awaddr_ocvm_axim),
  .awlen_ocvm_axim_m    (awlen_ocvm_axim),
  .awsize_ocvm_axim_m   (awsize_ocvm_axim),
  .awburst_ocvm_axim_m  (awburst_ocvm_axim),
  .awlock_ocvm_axim_m   (awlock_ocvm_axim),
  .awcache_ocvm_axim_m  (awcache_ocvm_axim),
  .awprot_ocvm_axim_m   (awprot_ocvm_axim),
  .awvalid_ocvm_axim_m  (awvalid_ocvm_axim),
  .awready_ocvm_axim_m  (awready_ocvm_axim),
  .wdata_ocvm_axim_m    (wdata_ocvm_axim),
  .wstrb_ocvm_axim_m    (wstrb_ocvm_axim),
  .wlast_ocvm_axim_m    (wlast_ocvm_axim),
  .wvalid_ocvm_axim_m   (wvalid_ocvm_axim),
  .wready_ocvm_axim_m   (wready_ocvm_axim),
  .bid_ocvm_axim_m      (bid_ocvm_axim),
  .bresp_ocvm_axim_m    (bresp_ocvm_axim),
  .bvalid_ocvm_axim_m   (bvalid_ocvm_axim),
  .bready_ocvm_axim_m   (bready_ocvm_axim),
  .arid_ocvm_axim_m     (arid_ocvm_axim),
  .araddr_ocvm_axim_m   (araddr_ocvm_axim),
  .arlen_ocvm_axim_m    (arlen_ocvm_axim),
  .arsize_ocvm_axim_m   (arsize_ocvm_axim),
  .arburst_ocvm_axim_m  (arburst_ocvm_axim),
  .arlock_ocvm_axim_m   (arlock_ocvm_axim),
  .arcache_ocvm_axim_m  (arcache_ocvm_axim),
  .arprot_ocvm_axim_m   (arprot_ocvm_axim),
  .arvalid_ocvm_axim_m  (arvalid_ocvm_axim),
  .arready_ocvm_axim_m  (arready_ocvm_axim),
  .rid_ocvm_axim_m      (rid_ocvm_axim),
  .rdata_ocvm_axim_m    (rdata_ocvm_axim),
  .rresp_ocvm_axim_m    (rresp_ocvm_axim),
  .rlast_ocvm_axim_m    (rlast_ocvm_axim),
  .rvalid_ocvm_axim_m   (rvalid_ocvm_axim),
  .rready_ocvm_axim_m   (rready_ocvm_axim),
  .awuser_ocvm_axim_m   (awuser_ocvm_axim),
  .buser_ocvm_axim_m    (buser_ocvm_axim),
  .aruser_ocvm_axim_m   (aruser_ocvm_axim),
  .ruser_ocvm_axim_m    (ruser_ocvm_axim),
  .awqv_ocvm_axim_m     (awqos_ocvm_axim),
  .arqv_ocvm_axim_m     (arqos_ocvm_axim),
  .awid_ocvm_axim_s     (awid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awaddr_ocvm_axim_s   (awaddr_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awlen_ocvm_axim_s    (awlen_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awsize_ocvm_axim_s   (awsize_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awburst_ocvm_axim_s  (awburst_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awlock_ocvm_axim_s   (awlock_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awcache_ocvm_axim_s  (awcache_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awprot_ocvm_axim_s   (awprot_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awvalid_ocvm_axim_s  (awvalid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awready_ocvm_axim_s  (awready_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .wdata_ocvm_axim_s    (wdata_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .wstrb_ocvm_axim_s    (wstrb_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .wlast_ocvm_axim_s    (wlast_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .wvalid_ocvm_axim_s   (wvalid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .wready_ocvm_axim_s   (wready_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .bid_ocvm_axim_s      (bid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .bresp_ocvm_axim_s    (bresp_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .bvalid_ocvm_axim_s   (bvalid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .bready_ocvm_axim_s   (bready_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arid_ocvm_axim_s     (arid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .araddr_ocvm_axim_s   (araddr_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arlen_ocvm_axim_s    (arlen_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arsize_ocvm_axim_s   (arsize_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arburst_ocvm_axim_s  (arburst_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arlock_ocvm_axim_s   (arlock_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arcache_ocvm_axim_s  (arcache_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arprot_ocvm_axim_s   (arprot_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arvalid_ocvm_axim_s  (arvalid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arready_ocvm_axim_s  (arready_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .rid_ocvm_axim_s      (rid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .rdata_ocvm_axim_s    (rdata_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .rresp_ocvm_axim_s    (rresp_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .rlast_ocvm_axim_s    (rlast_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .rvalid_ocvm_axim_s   (rvalid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .rready_ocvm_axim_s   (rready_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awuser_ocvm_axim_s   (awuser_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .buser_ocvm_axim_s    (buser_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .aruser_ocvm_axim_s   (aruser_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .ruser_ocvm_axim_s    (ruser_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awqv_ocvm_axim_s     (awqv_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arqv_ocvm_axim_s     (arqv_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .aclk                 (aclk),
  .aresetn              (aresetn)
);


nic400_amib_sysctrl_axim_sse710_main     u_amib_sysctrl_axim (
  .awid_sysctrl_axim_m  (awid_sysctrl_axim),
  .awaddr_sysctrl_axim_m (awaddr_sysctrl_axim),
  .awlen_sysctrl_axim_m (awlen_sysctrl_axim),
  .awsize_sysctrl_axim_m (awsize_sysctrl_axim),
  .awburst_sysctrl_axim_m (awburst_sysctrl_axim),
  .awlock_sysctrl_axim_m (awlock_sysctrl_axim),
  .awcache_sysctrl_axim_m (awcache_sysctrl_axim),
  .awprot_sysctrl_axim_m (awprot_sysctrl_axim),
  .awvalid_sysctrl_axim_m (awvalid_sysctrl_axim),
  .awready_sysctrl_axim_m (awready_sysctrl_axim),
  .wdata_sysctrl_axim_m (wdata_sysctrl_axim),
  .wstrb_sysctrl_axim_m (wstrb_sysctrl_axim),
  .wlast_sysctrl_axim_m (wlast_sysctrl_axim),
  .wvalid_sysctrl_axim_m (wvalid_sysctrl_axim),
  .wready_sysctrl_axim_m (wready_sysctrl_axim),
  .bid_sysctrl_axim_m   (bid_sysctrl_axim),
  .bresp_sysctrl_axim_m (bresp_sysctrl_axim),
  .bvalid_sysctrl_axim_m (bvalid_sysctrl_axim),
  .bready_sysctrl_axim_m (bready_sysctrl_axim),
  .arid_sysctrl_axim_m  (arid_sysctrl_axim),
  .araddr_sysctrl_axim_m (araddr_sysctrl_axim),
  .arlen_sysctrl_axim_m (arlen_sysctrl_axim),
  .arsize_sysctrl_axim_m (arsize_sysctrl_axim),
  .arburst_sysctrl_axim_m (arburst_sysctrl_axim),
  .arlock_sysctrl_axim_m (arlock_sysctrl_axim),
  .arcache_sysctrl_axim_m (arcache_sysctrl_axim),
  .arprot_sysctrl_axim_m (arprot_sysctrl_axim),
  .arvalid_sysctrl_axim_m (arvalid_sysctrl_axim),
  .arready_sysctrl_axim_m (arready_sysctrl_axim),
  .rid_sysctrl_axim_m   (rid_sysctrl_axim),
  .rdata_sysctrl_axim_m (rdata_sysctrl_axim),
  .rresp_sysctrl_axim_m (rresp_sysctrl_axim),
  .rlast_sysctrl_axim_m (rlast_sysctrl_axim),
  .rvalid_sysctrl_axim_m (rvalid_sysctrl_axim),
  .rready_sysctrl_axim_m (rready_sysctrl_axim),
  .awuser_sysctrl_axim_m (awuser_sysctrl_axim),
  .buser_sysctrl_axim_m (buser_sysctrl_axim),
  .aruser_sysctrl_axim_m (aruser_sysctrl_axim),
  .ruser_sysctrl_axim_m (ruser_sysctrl_axim),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .awid_sysctrl_axim_s  (awid_switch3_sysctrl_axim_sysctrl_axim_s),
  .awaddr_sysctrl_axim_s (awaddr_switch3_sysctrl_axim_sysctrl_axim_s),
  .awlen_sysctrl_axim_s (awlen_switch3_sysctrl_axim_sysctrl_axim_s),
  .awsize_sysctrl_axim_s (awsize_switch3_sysctrl_axim_sysctrl_axim_s),
  .awburst_sysctrl_axim_s (awburst_switch3_sysctrl_axim_sysctrl_axim_s),
  .awlock_sysctrl_axim_s (awlock_switch3_sysctrl_axim_sysctrl_axim_s),
  .awcache_sysctrl_axim_s (awcache_switch3_sysctrl_axim_sysctrl_axim_s),
  .awprot_sysctrl_axim_s (awprot_switch3_sysctrl_axim_sysctrl_axim_s),
  .awvalid_sysctrl_axim_s (awvalid_switch3_sysctrl_axim_sysctrl_axim_s),
  .awready_sysctrl_axim_s (awready_switch3_sysctrl_axim_sysctrl_axim_s),
  .wdata_sysctrl_axim_s (wdata_switch3_sysctrl_axim_sysctrl_axim_s),
  .wstrb_sysctrl_axim_s (wstrb_switch3_sysctrl_axim_sysctrl_axim_s),
  .wlast_sysctrl_axim_s (wlast_switch3_sysctrl_axim_sysctrl_axim_s),
  .wvalid_sysctrl_axim_s (wvalid_switch3_sysctrl_axim_sysctrl_axim_s),
  .wready_sysctrl_axim_s (wready_switch3_sysctrl_axim_sysctrl_axim_s),
  .bid_sysctrl_axim_s   (bid_switch3_sysctrl_axim_sysctrl_axim_s),
  .bresp_sysctrl_axim_s (bresp_switch3_sysctrl_axim_sysctrl_axim_s),
  .bvalid_sysctrl_axim_s (bvalid_switch3_sysctrl_axim_sysctrl_axim_s),
  .bready_sysctrl_axim_s (bready_switch3_sysctrl_axim_sysctrl_axim_s),
  .arid_sysctrl_axim_s  (arid_switch3_sysctrl_axim_sysctrl_axim_s),
  .araddr_sysctrl_axim_s (araddr_switch3_sysctrl_axim_sysctrl_axim_s),
  .arlen_sysctrl_axim_s (arlen_switch3_sysctrl_axim_sysctrl_axim_s),
  .arsize_sysctrl_axim_s (arsize_switch3_sysctrl_axim_sysctrl_axim_s),
  .arburst_sysctrl_axim_s (arburst_switch3_sysctrl_axim_sysctrl_axim_s),
  .arlock_sysctrl_axim_s (arlock_switch3_sysctrl_axim_sysctrl_axim_s),
  .arcache_sysctrl_axim_s (arcache_switch3_sysctrl_axim_sysctrl_axim_s),
  .arprot_sysctrl_axim_s (arprot_switch3_sysctrl_axim_sysctrl_axim_s),
  .arvalid_sysctrl_axim_s (arvalid_switch3_sysctrl_axim_sysctrl_axim_s),
  .arready_sysctrl_axim_s (arready_switch3_sysctrl_axim_sysctrl_axim_s),
  .rid_sysctrl_axim_s   (rid_switch3_sysctrl_axim_sysctrl_axim_s),
  .rdata_sysctrl_axim_s (rdata_switch3_sysctrl_axim_sysctrl_axim_s),
  .rresp_sysctrl_axim_s (rresp_switch3_sysctrl_axim_sysctrl_axim_s),
  .rlast_sysctrl_axim_s (rlast_switch3_sysctrl_axim_sysctrl_axim_s),
  .rvalid_sysctrl_axim_s (rvalid_switch3_sysctrl_axim_sysctrl_axim_s),
  .rready_sysctrl_axim_s (rready_switch3_sysctrl_axim_sysctrl_axim_s),
  .awuser_sysctrl_axim_s (awuser_switch3_sysctrl_axim_sysctrl_axim_s),
  .buser_sysctrl_axim_s (buser_switch3_sysctrl_axim_sysctrl_axim_s),
  .aruser_sysctrl_axim_s (aruser_switch3_sysctrl_axim_sysctrl_axim_s),
  .ruser_sysctrl_axim_s (ruser_switch3_sysctrl_axim_sysctrl_axim_s)
);


nic400_amib_sysperi_axim_sse710_main     u_amib_sysperi_axim (
  .awid_sysperi_axim_m  (awid_sysperi_axim),
  .awaddr_sysperi_axim_m (awaddr_sysperi_axim),
  .awlen_sysperi_axim_m (awlen_sysperi_axim),
  .awsize_sysperi_axim_m (awsize_sysperi_axim),
  .awburst_sysperi_axim_m (awburst_sysperi_axim),
  .awlock_sysperi_axim_m (awlock_sysperi_axim),
  .awcache_sysperi_axim_m (awcache_sysperi_axim),
  .awprot_sysperi_axim_m (awprot_sysperi_axim),
  .awvalid_sysperi_axim_m (awvalid_sysperi_axim),
  .awready_sysperi_axim_m (awready_sysperi_axim),
  .wdata_sysperi_axim_m (wdata_sysperi_axim),
  .wstrb_sysperi_axim_m (wstrb_sysperi_axim),
  .wlast_sysperi_axim_m (wlast_sysperi_axim),
  .wvalid_sysperi_axim_m (wvalid_sysperi_axim),
  .wready_sysperi_axim_m (wready_sysperi_axim),
  .bid_sysperi_axim_m   (bid_sysperi_axim),
  .bresp_sysperi_axim_m (bresp_sysperi_axim),
  .bvalid_sysperi_axim_m (bvalid_sysperi_axim),
  .bready_sysperi_axim_m (bready_sysperi_axim),
  .arid_sysperi_axim_m  (arid_sysperi_axim),
  .araddr_sysperi_axim_m (araddr_sysperi_axim),
  .arlen_sysperi_axim_m (arlen_sysperi_axim),
  .arsize_sysperi_axim_m (arsize_sysperi_axim),
  .arburst_sysperi_axim_m (arburst_sysperi_axim),
  .arlock_sysperi_axim_m (arlock_sysperi_axim),
  .arcache_sysperi_axim_m (arcache_sysperi_axim),
  .arprot_sysperi_axim_m (arprot_sysperi_axim),
  .arvalid_sysperi_axim_m (arvalid_sysperi_axim),
  .arready_sysperi_axim_m (arready_sysperi_axim),
  .rid_sysperi_axim_m   (rid_sysperi_axim),
  .rdata_sysperi_axim_m (rdata_sysperi_axim),
  .rresp_sysperi_axim_m (rresp_sysperi_axim),
  .rlast_sysperi_axim_m (rlast_sysperi_axim),
  .rvalid_sysperi_axim_m (rvalid_sysperi_axim),
  .rready_sysperi_axim_m (rready_sysperi_axim),
  .awuser_sysperi_axim_m (awuser_sysperi_axim),
  .buser_sysperi_axim_m (buser_sysperi_axim),
  .aruser_sysperi_axim_m (aruser_sysperi_axim),
  .ruser_sysperi_axim_m (ruser_sysperi_axim),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .awid_sysperi_axim_s  (awid_switch3_sysperi_axim_sysperi_axim_s),
  .awaddr_sysperi_axim_s (awaddr_switch3_sysperi_axim_sysperi_axim_s),
  .awlen_sysperi_axim_s (awlen_switch3_sysperi_axim_sysperi_axim_s),
  .awsize_sysperi_axim_s (awsize_switch3_sysperi_axim_sysperi_axim_s),
  .awburst_sysperi_axim_s (awburst_switch3_sysperi_axim_sysperi_axim_s),
  .awlock_sysperi_axim_s (awlock_switch3_sysperi_axim_sysperi_axim_s),
  .awcache_sysperi_axim_s (awcache_switch3_sysperi_axim_sysperi_axim_s),
  .awprot_sysperi_axim_s (awprot_switch3_sysperi_axim_sysperi_axim_s),
  .awvalid_sysperi_axim_s (awvalid_switch3_sysperi_axim_sysperi_axim_s),
  .awready_sysperi_axim_s (awready_switch3_sysperi_axim_sysperi_axim_s),
  .wdata_sysperi_axim_s (wdata_switch3_sysperi_axim_sysperi_axim_s),
  .wstrb_sysperi_axim_s (wstrb_switch3_sysperi_axim_sysperi_axim_s),
  .wlast_sysperi_axim_s (wlast_switch3_sysperi_axim_sysperi_axim_s),
  .wvalid_sysperi_axim_s (wvalid_switch3_sysperi_axim_sysperi_axim_s),
  .wready_sysperi_axim_s (wready_switch3_sysperi_axim_sysperi_axim_s),
  .bid_sysperi_axim_s   (bid_switch3_sysperi_axim_sysperi_axim_s),
  .bresp_sysperi_axim_s (bresp_switch3_sysperi_axim_sysperi_axim_s),
  .bvalid_sysperi_axim_s (bvalid_switch3_sysperi_axim_sysperi_axim_s),
  .bready_sysperi_axim_s (bready_switch3_sysperi_axim_sysperi_axim_s),
  .arid_sysperi_axim_s  (arid_switch3_sysperi_axim_sysperi_axim_s),
  .araddr_sysperi_axim_s (araddr_switch3_sysperi_axim_sysperi_axim_s),
  .arlen_sysperi_axim_s (arlen_switch3_sysperi_axim_sysperi_axim_s),
  .arsize_sysperi_axim_s (arsize_switch3_sysperi_axim_sysperi_axim_s),
  .arburst_sysperi_axim_s (arburst_switch3_sysperi_axim_sysperi_axim_s),
  .arlock_sysperi_axim_s (arlock_switch3_sysperi_axim_sysperi_axim_s),
  .arcache_sysperi_axim_s (arcache_switch3_sysperi_axim_sysperi_axim_s),
  .arprot_sysperi_axim_s (arprot_switch3_sysperi_axim_sysperi_axim_s),
  .arvalid_sysperi_axim_s (arvalid_switch3_sysperi_axim_sysperi_axim_s),
  .arready_sysperi_axim_s (arready_switch3_sysperi_axim_sysperi_axim_s),
  .rid_sysperi_axim_s   (rid_switch3_sysperi_axim_sysperi_axim_s),
  .rdata_sysperi_axim_s (rdata_switch3_sysperi_axim_sysperi_axim_s),
  .rresp_sysperi_axim_s (rresp_switch3_sysperi_axim_sysperi_axim_s),
  .rlast_sysperi_axim_s (rlast_switch3_sysperi_axim_sysperi_axim_s),
  .rvalid_sysperi_axim_s (rvalid_switch3_sysperi_axim_sysperi_axim_s),
  .rready_sysperi_axim_s (rready_switch3_sysperi_axim_sysperi_axim_s),
  .awuser_sysperi_axim_s (awuser_switch3_sysperi_axim_sysperi_axim_s),
  .buser_sysperi_axim_s (buser_switch3_sysperi_axim_sysperi_axim_s),
  .aruser_sysperi_axim_s (aruser_switch3_sysperi_axim_sysperi_axim_s),
  .ruser_sysperi_axim_s (ruser_switch3_sysperi_axim_sysperi_axim_s)
);


nic400_amib_xnvm_axim_sse710_main     u_amib_xnvm_axim (
  .awid_xnvm_axim_m     (awid_xnvm_axim),
  .awaddr_xnvm_axim_m   (awaddr_xnvm_axim),
  .awlen_xnvm_axim_m    (awlen_xnvm_axim),
  .awsize_xnvm_axim_m   (awsize_xnvm_axim),
  .awburst_xnvm_axim_m  (awburst_xnvm_axim),
  .awlock_xnvm_axim_m   (awlock_xnvm_axim),
  .awcache_xnvm_axim_m  (awcache_xnvm_axim),
  .awprot_xnvm_axim_m   (awprot_xnvm_axim),
  .awvalid_xnvm_axim_m  (awvalid_xnvm_axim),
  .awready_xnvm_axim_m  (awready_xnvm_axim),
  .wdata_xnvm_axim_m    (wdata_xnvm_axim),
  .wstrb_xnvm_axim_m    (wstrb_xnvm_axim),
  .wlast_xnvm_axim_m    (wlast_xnvm_axim),
  .wvalid_xnvm_axim_m   (wvalid_xnvm_axim),
  .wready_xnvm_axim_m   (wready_xnvm_axim),
  .bid_xnvm_axim_m      (bid_xnvm_axim),
  .bresp_xnvm_axim_m    (bresp_xnvm_axim),
  .bvalid_xnvm_axim_m   (bvalid_xnvm_axim),
  .bready_xnvm_axim_m   (bready_xnvm_axim),
  .arid_xnvm_axim_m     (arid_xnvm_axim),
  .araddr_xnvm_axim_m   (araddr_xnvm_axim),
  .arlen_xnvm_axim_m    (arlen_xnvm_axim),
  .arsize_xnvm_axim_m   (arsize_xnvm_axim),
  .arburst_xnvm_axim_m  (arburst_xnvm_axim),
  .arlock_xnvm_axim_m   (arlock_xnvm_axim),
  .arcache_xnvm_axim_m  (arcache_xnvm_axim),
  .arprot_xnvm_axim_m   (arprot_xnvm_axim),
  .arvalid_xnvm_axim_m  (arvalid_xnvm_axim),
  .arready_xnvm_axim_m  (arready_xnvm_axim),
  .rid_xnvm_axim_m      (rid_xnvm_axim),
  .rdata_xnvm_axim_m    (rdata_xnvm_axim),
  .rresp_xnvm_axim_m    (rresp_xnvm_axim),
  .rlast_xnvm_axim_m    (rlast_xnvm_axim),
  .rvalid_xnvm_axim_m   (rvalid_xnvm_axim),
  .rready_xnvm_axim_m   (rready_xnvm_axim),
  .awuser_xnvm_axim_m   (awuser_xnvm_axim),
  .buser_xnvm_axim_m    (buser_xnvm_axim),
  .aruser_xnvm_axim_m   (aruser_xnvm_axim),
  .ruser_xnvm_axim_m    (ruser_xnvm_axim),
  .awqv_xnvm_axim_m     (awqos_xnvm_axim),
  .arqv_xnvm_axim_m     (arqos_xnvm_axim),
  .awid_xnvm_axim_s     (awid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awaddr_xnvm_axim_s   (awaddr_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awlen_xnvm_axim_s    (awlen_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awsize_xnvm_axim_s   (awsize_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awburst_xnvm_axim_s  (awburst_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awlock_xnvm_axim_s   (awlock_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awcache_xnvm_axim_s  (awcache_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awprot_xnvm_axim_s   (awprot_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awvalid_xnvm_axim_s  (awvalid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awready_xnvm_axim_s  (awready_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .wdata_xnvm_axim_s    (wdata_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .wstrb_xnvm_axim_s    (wstrb_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .wlast_xnvm_axim_s    (wlast_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .wvalid_xnvm_axim_s   (wvalid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .wready_xnvm_axim_s   (wready_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .bid_xnvm_axim_s      (bid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .bresp_xnvm_axim_s    (bresp_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .bvalid_xnvm_axim_s   (bvalid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .bready_xnvm_axim_s   (bready_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arid_xnvm_axim_s     (arid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .araddr_xnvm_axim_s   (araddr_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arlen_xnvm_axim_s    (arlen_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arsize_xnvm_axim_s   (arsize_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arburst_xnvm_axim_s  (arburst_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arlock_xnvm_axim_s   (arlock_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arcache_xnvm_axim_s  (arcache_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arprot_xnvm_axim_s   (arprot_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arvalid_xnvm_axim_s  (arvalid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arready_xnvm_axim_s  (arready_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .rid_xnvm_axim_s      (rid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .rdata_xnvm_axim_s    (rdata_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .rresp_xnvm_axim_s    (rresp_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .rlast_xnvm_axim_s    (rlast_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .rvalid_xnvm_axim_s   (rvalid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .rready_xnvm_axim_s   (rready_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awuser_xnvm_axim_s   (awuser_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .buser_xnvm_axim_s    (buser_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .aruser_xnvm_axim_s   (aruser_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .ruser_xnvm_axim_s    (ruser_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awqv_xnvm_axim_s     (awqv_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arqv_xnvm_axim_s     (arqv_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .aclk                 (aclk),
  .aresetn              (aresetn)
);


nic400_asib_debug_axis_sse710_main     u_asib_debug_axis (
  .paddr                (paddr_debug_axis_apb),
  .pwdata               (pwdata_debug_axis_apb),
  .pwrite               (pwrite_debug_axis_apb),
  .penable              (penable_debug_axis_apb),
  .psel                 (pselx_debug_axis_apb),
  .prdata               (prdata_debug_axis_apb),
  .pslverr              (pslverr_debug_axis_apb),
  .pready               (pready_debug_axis_apb),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .debug_axis_cactive   (cactive_debug_axis_hcg),
  .awid_debug_axis_m    (awid_debug_axis_debug_axis_ib_axi4_s),
  .awaddr_debug_axis_m  (awaddr_debug_axis_debug_axis_ib_axi4_s),
  .awlen_debug_axis_m   (awlen_debug_axis_debug_axis_ib_axi4_s),
  .awsize_debug_axis_m  (awsize_debug_axis_debug_axis_ib_axi4_s),
  .awburst_debug_axis_m (awburst_debug_axis_debug_axis_ib_axi4_s),
  .awlock_debug_axis_m  (awlock_debug_axis_debug_axis_ib_axi4_s),
  .awcache_debug_axis_m (awcache_debug_axis_debug_axis_ib_axi4_s),
  .awprot_debug_axis_m  (awprot_debug_axis_debug_axis_ib_axi4_s),
  .awvalid_debug_axis_m (awvalid_debug_axis_debug_axis_ib_axi4_s),
  .awvalid_vect_debug_axis_m (awvalid_vect_debug_axis_debug_axis_ib_axi4_s),
  .awready_debug_axis_m (awready_debug_axis_debug_axis_ib_axi4_s),
  .wdata_debug_axis_m   (wdata_debug_axis_debug_axis_ib_axi4_s),
  .wstrb_debug_axis_m   (wstrb_debug_axis_debug_axis_ib_axi4_s),
  .wlast_debug_axis_m   (wlast_debug_axis_debug_axis_ib_axi4_s),
  .wvalid_debug_axis_m  (wvalid_debug_axis_debug_axis_ib_axi4_s),
  .wready_debug_axis_m  (wready_debug_axis_debug_axis_ib_axi4_s),
  .bid_debug_axis_m     (bid_debug_axis_debug_axis_ib_axi4_s),
  .bresp_debug_axis_m   (bresp_debug_axis_debug_axis_ib_axi4_s),
  .bvalid_debug_axis_m  (bvalid_debug_axis_debug_axis_ib_axi4_s),
  .bready_debug_axis_m  (bready_debug_axis_debug_axis_ib_axi4_s),
  .arid_debug_axis_m    (arid_debug_axis_debug_axis_ib_axi4_s),
  .araddr_debug_axis_m  (araddr_debug_axis_debug_axis_ib_axi4_s),
  .arlen_debug_axis_m   (arlen_debug_axis_debug_axis_ib_axi4_s),
  .arsize_debug_axis_m  (arsize_debug_axis_debug_axis_ib_axi4_s),
  .arburst_debug_axis_m (arburst_debug_axis_debug_axis_ib_axi4_s),
  .arlock_debug_axis_m  (arlock_debug_axis_debug_axis_ib_axi4_s),
  .arcache_debug_axis_m (arcache_debug_axis_debug_axis_ib_axi4_s),
  .arprot_debug_axis_m  (arprot_debug_axis_debug_axis_ib_axi4_s),
  .arvalid_debug_axis_m (arvalid_debug_axis_debug_axis_ib_axi4_s),
  .arvalid_vect_debug_axis_m (arvalid_vect_debug_axis_debug_axis_ib_axi4_s),
  .arready_debug_axis_m (arready_debug_axis_debug_axis_ib_axi4_s),
  .rid_debug_axis_m     (rid_debug_axis_debug_axis_ib_axi4_s),
  .rdata_debug_axis_m   (rdata_debug_axis_debug_axis_ib_axi4_s),
  .rresp_debug_axis_m   (rresp_debug_axis_debug_axis_ib_axi4_s),
  .rlast_debug_axis_m   (rlast_debug_axis_debug_axis_ib_axi4_s),
  .rvalid_debug_axis_m  (rvalid_debug_axis_debug_axis_ib_axi4_s),
  .rready_debug_axis_m  (rready_debug_axis_debug_axis_ib_axi4_s),
  .awuser_debug_axis_m  (awuser_debug_axis_debug_axis_ib_axi4_s),
  .buser_debug_axis_m   (buser_debug_axis_debug_axis_ib_axi4_s),
  .aruser_debug_axis_m  (aruser_debug_axis_debug_axis_ib_axi4_s),
  .ruser_debug_axis_m   (ruser_debug_axis_debug_axis_ib_axi4_s),
  .debug_axis_port_enable (port_enable_debug_axis_port_enable_hcg),
  .awid_debug_axis_s    (awid_debug_axis),
  .awaddr_debug_axis_s  (awaddr_debug_axis),
  .awlen_debug_axis_s   (awlen_debug_axis),
  .awsize_debug_axis_s  (awsize_debug_axis),
  .awburst_debug_axis_s (awburst_debug_axis),
  .awlock_debug_axis_s  (awlock_debug_axis),
  .awcache_debug_axis_s (awcache_debug_axis),
  .awprot_debug_axis_s  (awprot_debug_axis),
  .awvalid_debug_axis_s (awvalid_debug_axis),
  .awready_debug_axis_s (awready_debug_axis),
  .wdata_debug_axis_s   (wdata_debug_axis),
  .wstrb_debug_axis_s   (wstrb_debug_axis),
  .wlast_debug_axis_s   (wlast_debug_axis),
  .wvalid_debug_axis_s  (wvalid_debug_axis),
  .wready_debug_axis_s  (wready_debug_axis),
  .bid_debug_axis_s     (bid_debug_axis),
  .bresp_debug_axis_s   (bresp_debug_axis),
  .bvalid_debug_axis_s  (bvalid_debug_axis),
  .bready_debug_axis_s  (bready_debug_axis),
  .arid_debug_axis_s    (arid_debug_axis),
  .araddr_debug_axis_s  (araddr_debug_axis),
  .arlen_debug_axis_s   (arlen_debug_axis),
  .arsize_debug_axis_s  (arsize_debug_axis),
  .arburst_debug_axis_s (arburst_debug_axis),
  .arlock_debug_axis_s  (arlock_debug_axis),
  .arcache_debug_axis_s (arcache_debug_axis),
  .arprot_debug_axis_s  (arprot_debug_axis),
  .arvalid_debug_axis_s (arvalid_debug_axis),
  .arready_debug_axis_s (arready_debug_axis),
  .rid_debug_axis_s     (rid_debug_axis),
  .rdata_debug_axis_s   (rdata_debug_axis),
  .rresp_debug_axis_s   (rresp_debug_axis),
  .rlast_debug_axis_s   (rlast_debug_axis),
  .rvalid_debug_axis_s  (rvalid_debug_axis),
  .rready_debug_axis_s  (rready_debug_axis),
  .awuser_debug_axis_s  (awuser_debug_axis),
  .buser_debug_axis_s   (buser_debug_axis),
  .aruser_debug_axis_s  (aruser_debug_axis),
  .ruser_debug_axis_s   (ruser_debug_axis),
  .debug_axis_cactive_wakeup (cactive_debug_axis_wakeup_hcg)
);


nic400_asib_expslv0_axis_sse710_main     u_asib_expslv0_axis (
  .expslv0_axis_cactive (cactive_expslv0_axis_hcg),
  .awid_expslv0_axis_m  (awid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awaddr_expslv0_axis_m (awaddr_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awlen_expslv0_axis_m (awlen_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awsize_expslv0_axis_m (awsize_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awburst_expslv0_axis_m (awburst_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awlock_expslv0_axis_m (awlock_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awcache_expslv0_axis_m (awcache_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awprot_expslv0_axis_m (awprot_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awvalid_expslv0_axis_m (awvalid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awvalid_vect_expslv0_axis_m (awvalid_vect_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awready_expslv0_axis_m (awready_expslv0_axis_expslv0_axis_ib_axi4_s),
  .wdata_expslv0_axis_m (wdata_expslv0_axis_expslv0_axis_ib_axi4_s),
  .wstrb_expslv0_axis_m (wstrb_expslv0_axis_expslv0_axis_ib_axi4_s),
  .wlast_expslv0_axis_m (wlast_expslv0_axis_expslv0_axis_ib_axi4_s),
  .wvalid_expslv0_axis_m (wvalid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .wready_expslv0_axis_m (wready_expslv0_axis_expslv0_axis_ib_axi4_s),
  .bid_expslv0_axis_m   (bid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .bresp_expslv0_axis_m (bresp_expslv0_axis_expslv0_axis_ib_axi4_s),
  .bvalid_expslv0_axis_m (bvalid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .bready_expslv0_axis_m (bready_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arid_expslv0_axis_m  (arid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .araddr_expslv0_axis_m (araddr_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arlen_expslv0_axis_m (arlen_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arsize_expslv0_axis_m (arsize_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arburst_expslv0_axis_m (arburst_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arlock_expslv0_axis_m (arlock_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arcache_expslv0_axis_m (arcache_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arprot_expslv0_axis_m (arprot_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arvalid_expslv0_axis_m (arvalid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arvalid_vect_expslv0_axis_m (arvalid_vect_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arready_expslv0_axis_m (arready_expslv0_axis_expslv0_axis_ib_axi4_s),
  .rid_expslv0_axis_m   (rid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .rdata_expslv0_axis_m (rdata_expslv0_axis_expslv0_axis_ib_axi4_s),
  .rresp_expslv0_axis_m (rresp_expslv0_axis_expslv0_axis_ib_axi4_s),
  .rlast_expslv0_axis_m (rlast_expslv0_axis_expslv0_axis_ib_axi4_s),
  .rvalid_expslv0_axis_m (rvalid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .rready_expslv0_axis_m (rready_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awuser_expslv0_axis_m (awuser_expslv0_axis_expslv0_axis_ib_axi4_s),
  .buser_expslv0_axis_m (buser_expslv0_axis_expslv0_axis_ib_axi4_s),
  .aruser_expslv0_axis_m (aruser_expslv0_axis_expslv0_axis_ib_axi4_s),
  .ruser_expslv0_axis_m (ruser_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awqv_expslv0_axis_m  (awqv_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arqv_expslv0_axis_m  (arqv_expslv0_axis_expslv0_axis_ib_axi4_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .expslv0_axis_port_enable (port_enable_expslv0_axis_port_enable_hcg),
  .awid_expslv0_axis_s  (awid_expslv0_axis),
  .awaddr_expslv0_axis_s (awaddr_expslv0_axis),
  .awlen_expslv0_axis_s (awlen_expslv0_axis),
  .awsize_expslv0_axis_s (awsize_expslv0_axis),
  .awburst_expslv0_axis_s (awburst_expslv0_axis),
  .awlock_expslv0_axis_s (awlock_expslv0_axis),
  .awcache_expslv0_axis_s (awcache_expslv0_axis),
  .awprot_expslv0_axis_s (awprot_expslv0_axis),
  .awvalid_expslv0_axis_s (awvalid_expslv0_axis),
  .awready_expslv0_axis_s (awready_expslv0_axis),
  .wdata_expslv0_axis_s (wdata_expslv0_axis),
  .wstrb_expslv0_axis_s (wstrb_expslv0_axis),
  .wlast_expslv0_axis_s (wlast_expslv0_axis),
  .wvalid_expslv0_axis_s (wvalid_expslv0_axis),
  .wready_expslv0_axis_s (wready_expslv0_axis),
  .bid_expslv0_axis_s   (bid_expslv0_axis),
  .bresp_expslv0_axis_s (bresp_expslv0_axis),
  .bvalid_expslv0_axis_s (bvalid_expslv0_axis),
  .bready_expslv0_axis_s (bready_expslv0_axis),
  .arid_expslv0_axis_s  (arid_expslv0_axis),
  .araddr_expslv0_axis_s (araddr_expslv0_axis),
  .arlen_expslv0_axis_s (arlen_expslv0_axis),
  .arsize_expslv0_axis_s (arsize_expslv0_axis),
  .arburst_expslv0_axis_s (arburst_expslv0_axis),
  .arlock_expslv0_axis_s (arlock_expslv0_axis),
  .arcache_expslv0_axis_s (arcache_expslv0_axis),
  .arprot_expslv0_axis_s (arprot_expslv0_axis),
  .arvalid_expslv0_axis_s (arvalid_expslv0_axis),
  .arready_expslv0_axis_s (arready_expslv0_axis),
  .rid_expslv0_axis_s   (rid_expslv0_axis),
  .rdata_expslv0_axis_s (rdata_expslv0_axis),
  .rresp_expslv0_axis_s (rresp_expslv0_axis),
  .rlast_expslv0_axis_s (rlast_expslv0_axis),
  .rvalid_expslv0_axis_s (rvalid_expslv0_axis),
  .rready_expslv0_axis_s (rready_expslv0_axis),
  .awuser_expslv0_axis_s (awuser_expslv0_axis),
  .buser_expslv0_axis_s (buser_expslv0_axis),
  .aruser_expslv0_axis_s (aruser_expslv0_axis),
  .ruser_expslv0_axis_s (ruser_expslv0_axis),
  .awqv_expslv0_axis_s  (awqos_expslv0_axis),
  .arqv_expslv0_axis_s  (arqos_expslv0_axis),
  .expslv0_axis_cactive_wakeup (cactive_expslv0_axis_wakeup_hcg)
);


nic400_asib_expslv1_axis_sse710_main     u_asib_expslv1_axis (
  .expslv1_axis_cactive (cactive_expslv1_axis_hcg),
  .awid_expslv1_axis_m  (awid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awaddr_expslv1_axis_m (awaddr_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awlen_expslv1_axis_m (awlen_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awsize_expslv1_axis_m (awsize_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awburst_expslv1_axis_m (awburst_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awlock_expslv1_axis_m (awlock_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awcache_expslv1_axis_m (awcache_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awprot_expslv1_axis_m (awprot_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awvalid_expslv1_axis_m (awvalid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awvalid_vect_expslv1_axis_m (awvalid_vect_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awready_expslv1_axis_m (awready_expslv1_axis_expslv1_axis_ib_axi4_s),
  .wdata_expslv1_axis_m (wdata_expslv1_axis_expslv1_axis_ib_axi4_s),
  .wstrb_expslv1_axis_m (wstrb_expslv1_axis_expslv1_axis_ib_axi4_s),
  .wlast_expslv1_axis_m (wlast_expslv1_axis_expslv1_axis_ib_axi4_s),
  .wvalid_expslv1_axis_m (wvalid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .wready_expslv1_axis_m (wready_expslv1_axis_expslv1_axis_ib_axi4_s),
  .bid_expslv1_axis_m   (bid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .bresp_expslv1_axis_m (bresp_expslv1_axis_expslv1_axis_ib_axi4_s),
  .bvalid_expslv1_axis_m (bvalid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .bready_expslv1_axis_m (bready_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arid_expslv1_axis_m  (arid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .araddr_expslv1_axis_m (araddr_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arlen_expslv1_axis_m (arlen_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arsize_expslv1_axis_m (arsize_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arburst_expslv1_axis_m (arburst_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arlock_expslv1_axis_m (arlock_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arcache_expslv1_axis_m (arcache_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arprot_expslv1_axis_m (arprot_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arvalid_expslv1_axis_m (arvalid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arvalid_vect_expslv1_axis_m (arvalid_vect_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arready_expslv1_axis_m (arready_expslv1_axis_expslv1_axis_ib_axi4_s),
  .rid_expslv1_axis_m   (rid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .rdata_expslv1_axis_m (rdata_expslv1_axis_expslv1_axis_ib_axi4_s),
  .rresp_expslv1_axis_m (rresp_expslv1_axis_expslv1_axis_ib_axi4_s),
  .rlast_expslv1_axis_m (rlast_expslv1_axis_expslv1_axis_ib_axi4_s),
  .rvalid_expslv1_axis_m (rvalid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .rready_expslv1_axis_m (rready_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awuser_expslv1_axis_m (awuser_expslv1_axis_expslv1_axis_ib_axi4_s),
  .buser_expslv1_axis_m (buser_expslv1_axis_expslv1_axis_ib_axi4_s),
  .aruser_expslv1_axis_m (aruser_expslv1_axis_expslv1_axis_ib_axi4_s),
  .ruser_expslv1_axis_m (ruser_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awqv_expslv1_axis_m  (awqv_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arqv_expslv1_axis_m  (arqv_expslv1_axis_expslv1_axis_ib_axi4_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .expslv1_axis_port_enable (port_enable_expslv1_axis_port_enable_hcg),
  .awid_expslv1_axis_s  (awid_expslv1_axis),
  .awaddr_expslv1_axis_s (awaddr_expslv1_axis),
  .awlen_expslv1_axis_s (awlen_expslv1_axis),
  .awsize_expslv1_axis_s (awsize_expslv1_axis),
  .awburst_expslv1_axis_s (awburst_expslv1_axis),
  .awlock_expslv1_axis_s (awlock_expslv1_axis),
  .awcache_expslv1_axis_s (awcache_expslv1_axis),
  .awprot_expslv1_axis_s (awprot_expslv1_axis),
  .awvalid_expslv1_axis_s (awvalid_expslv1_axis),
  .awready_expslv1_axis_s (awready_expslv1_axis),
  .wdata_expslv1_axis_s (wdata_expslv1_axis),
  .wstrb_expslv1_axis_s (wstrb_expslv1_axis),
  .wlast_expslv1_axis_s (wlast_expslv1_axis),
  .wvalid_expslv1_axis_s (wvalid_expslv1_axis),
  .wready_expslv1_axis_s (wready_expslv1_axis),
  .bid_expslv1_axis_s   (bid_expslv1_axis),
  .bresp_expslv1_axis_s (bresp_expslv1_axis),
  .bvalid_expslv1_axis_s (bvalid_expslv1_axis),
  .bready_expslv1_axis_s (bready_expslv1_axis),
  .arid_expslv1_axis_s  (arid_expslv1_axis),
  .araddr_expslv1_axis_s (araddr_expslv1_axis),
  .arlen_expslv1_axis_s (arlen_expslv1_axis),
  .arsize_expslv1_axis_s (arsize_expslv1_axis),
  .arburst_expslv1_axis_s (arburst_expslv1_axis),
  .arlock_expslv1_axis_s (arlock_expslv1_axis),
  .arcache_expslv1_axis_s (arcache_expslv1_axis),
  .arprot_expslv1_axis_s (arprot_expslv1_axis),
  .arvalid_expslv1_axis_s (arvalid_expslv1_axis),
  .arready_expslv1_axis_s (arready_expslv1_axis),
  .rid_expslv1_axis_s   (rid_expslv1_axis),
  .rdata_expslv1_axis_s (rdata_expslv1_axis),
  .rresp_expslv1_axis_s (rresp_expslv1_axis),
  .rlast_expslv1_axis_s (rlast_expslv1_axis),
  .rvalid_expslv1_axis_s (rvalid_expslv1_axis),
  .rready_expslv1_axis_s (rready_expslv1_axis),
  .awuser_expslv1_axis_s (awuser_expslv1_axis),
  .buser_expslv1_axis_s (buser_expslv1_axis),
  .aruser_expslv1_axis_s (aruser_expslv1_axis),
  .ruser_expslv1_axis_s (ruser_expslv1_axis),
  .awqv_expslv1_axis_s  (awqos_expslv1_axis),
  .arqv_expslv1_axis_s  (arqos_expslv1_axis),
  .expslv1_axis_cactive_wakeup (cactive_expslv1_axis_wakeup_hcg)
);


nic400_asib_extsys0_axis_sse710_main     u_asib_extsys0_axis (
  .paddr                (paddr_extsys0_axis_apb),
  .pwdata               (pwdata_extsys0_axis_apb),
  .pwrite               (pwrite_extsys0_axis_apb),
  .penable              (penable_extsys0_axis_apb),
  .psel                 (pselx_extsys0_axis_apb),
  .prdata               (prdata_extsys0_axis_apb),
  .pslverr              (pslverr_extsys0_axis_apb),
  .pready               (pready_extsys0_axis_apb),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .extsys0_axis_cactive (cactive_extsys0_axis_hcg),
  .awid_extsys0_axis_m  (awid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awaddr_extsys0_axis_m (awaddr_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awlen_extsys0_axis_m (awlen_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awsize_extsys0_axis_m (awsize_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awburst_extsys0_axis_m (awburst_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awlock_extsys0_axis_m (awlock_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awcache_extsys0_axis_m (awcache_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awprot_extsys0_axis_m (awprot_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awvalid_extsys0_axis_m (awvalid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awvalid_vect_extsys0_axis_m (awvalid_vect_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awready_extsys0_axis_m (awready_extsys0_axis_extsys0_axis_ib_axi4_s),
  .wdata_extsys0_axis_m (wdata_extsys0_axis_extsys0_axis_ib_axi4_s),
  .wstrb_extsys0_axis_m (wstrb_extsys0_axis_extsys0_axis_ib_axi4_s),
  .wlast_extsys0_axis_m (wlast_extsys0_axis_extsys0_axis_ib_axi4_s),
  .wvalid_extsys0_axis_m (wvalid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .wready_extsys0_axis_m (wready_extsys0_axis_extsys0_axis_ib_axi4_s),
  .bid_extsys0_axis_m   (bid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .bresp_extsys0_axis_m (bresp_extsys0_axis_extsys0_axis_ib_axi4_s),
  .bvalid_extsys0_axis_m (bvalid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .bready_extsys0_axis_m (bready_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arid_extsys0_axis_m  (arid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .araddr_extsys0_axis_m (araddr_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arlen_extsys0_axis_m (arlen_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arsize_extsys0_axis_m (arsize_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arburst_extsys0_axis_m (arburst_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arlock_extsys0_axis_m (arlock_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arcache_extsys0_axis_m (arcache_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arprot_extsys0_axis_m (arprot_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arvalid_extsys0_axis_m (arvalid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arvalid_vect_extsys0_axis_m (arvalid_vect_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arready_extsys0_axis_m (arready_extsys0_axis_extsys0_axis_ib_axi4_s),
  .rid_extsys0_axis_m   (rid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .rdata_extsys0_axis_m (rdata_extsys0_axis_extsys0_axis_ib_axi4_s),
  .rresp_extsys0_axis_m (rresp_extsys0_axis_extsys0_axis_ib_axi4_s),
  .rlast_extsys0_axis_m (rlast_extsys0_axis_extsys0_axis_ib_axi4_s),
  .rvalid_extsys0_axis_m (rvalid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .rready_extsys0_axis_m (rready_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awuser_extsys0_axis_m (awuser_extsys0_axis_extsys0_axis_ib_axi4_s),
  .buser_extsys0_axis_m (buser_extsys0_axis_extsys0_axis_ib_axi4_s),
  .aruser_extsys0_axis_m (aruser_extsys0_axis_extsys0_axis_ib_axi4_s),
  .ruser_extsys0_axis_m (ruser_extsys0_axis_extsys0_axis_ib_axi4_s),
  .extsys0_axis_port_enable (port_enable_extsys0_axis_port_enable_hcg),
  .awid_extsys0_axis_s  (awid_extsys0_axis),
  .awaddr_extsys0_axis_s (awaddr_extsys0_axis),
  .awlen_extsys0_axis_s (awlen_extsys0_axis),
  .awsize_extsys0_axis_s (awsize_extsys0_axis),
  .awburst_extsys0_axis_s (awburst_extsys0_axis),
  .awlock_extsys0_axis_s (awlock_extsys0_axis),
  .awcache_extsys0_axis_s (awcache_extsys0_axis),
  .awprot_extsys0_axis_s (awprot_extsys0_axis),
  .awvalid_extsys0_axis_s (awvalid_extsys0_axis),
  .awready_extsys0_axis_s (awready_extsys0_axis),
  .wdata_extsys0_axis_s (wdata_extsys0_axis),
  .wstrb_extsys0_axis_s (wstrb_extsys0_axis),
  .wlast_extsys0_axis_s (wlast_extsys0_axis),
  .wvalid_extsys0_axis_s (wvalid_extsys0_axis),
  .wready_extsys0_axis_s (wready_extsys0_axis),
  .bid_extsys0_axis_s   (bid_extsys0_axis),
  .bresp_extsys0_axis_s (bresp_extsys0_axis),
  .bvalid_extsys0_axis_s (bvalid_extsys0_axis),
  .bready_extsys0_axis_s (bready_extsys0_axis),
  .arid_extsys0_axis_s  (arid_extsys0_axis),
  .araddr_extsys0_axis_s (araddr_extsys0_axis),
  .arlen_extsys0_axis_s (arlen_extsys0_axis),
  .arsize_extsys0_axis_s (arsize_extsys0_axis),
  .arburst_extsys0_axis_s (arburst_extsys0_axis),
  .arlock_extsys0_axis_s (arlock_extsys0_axis),
  .arcache_extsys0_axis_s (arcache_extsys0_axis),
  .arprot_extsys0_axis_s (arprot_extsys0_axis),
  .arvalid_extsys0_axis_s (arvalid_extsys0_axis),
  .arready_extsys0_axis_s (arready_extsys0_axis),
  .rid_extsys0_axis_s   (rid_extsys0_axis),
  .rdata_extsys0_axis_s (rdata_extsys0_axis),
  .rresp_extsys0_axis_s (rresp_extsys0_axis),
  .rlast_extsys0_axis_s (rlast_extsys0_axis),
  .rvalid_extsys0_axis_s (rvalid_extsys0_axis),
  .rready_extsys0_axis_s (rready_extsys0_axis),
  .awuser_extsys0_axis_s (awuser_extsys0_axis),
  .buser_extsys0_axis_s (buser_extsys0_axis),
  .aruser_extsys0_axis_s (aruser_extsys0_axis),
  .ruser_extsys0_axis_s (ruser_extsys0_axis),
  .extsys0_axis_cactive_wakeup (cactive_extsys0_axis_wakeup_hcg)
);


nic400_asib_extsys1_axis_sse710_main     u_asib_extsys1_axis (
  .paddr                (paddr_extsys1_axis_apb),
  .pwdata               (pwdata_extsys1_axis_apb),
  .pwrite               (pwrite_extsys1_axis_apb),
  .penable              (penable_extsys1_axis_apb),
  .psel                 (pselx_extsys1_axis_apb),
  .prdata               (prdata_extsys1_axis_apb),
  .pslverr              (pslverr_extsys1_axis_apb),
  .pready               (pready_extsys1_axis_apb),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .extsys1_axis_cactive (cactive_extsys1_axis_hcg),
  .awid_extsys1_axis_m  (awid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awaddr_extsys1_axis_m (awaddr_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awlen_extsys1_axis_m (awlen_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awsize_extsys1_axis_m (awsize_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awburst_extsys1_axis_m (awburst_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awlock_extsys1_axis_m (awlock_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awcache_extsys1_axis_m (awcache_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awprot_extsys1_axis_m (awprot_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awvalid_extsys1_axis_m (awvalid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awvalid_vect_extsys1_axis_m (awvalid_vect_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awready_extsys1_axis_m (awready_extsys1_axis_extsys1_axis_ib_axi4_s),
  .wdata_extsys1_axis_m (wdata_extsys1_axis_extsys1_axis_ib_axi4_s),
  .wstrb_extsys1_axis_m (wstrb_extsys1_axis_extsys1_axis_ib_axi4_s),
  .wlast_extsys1_axis_m (wlast_extsys1_axis_extsys1_axis_ib_axi4_s),
  .wvalid_extsys1_axis_m (wvalid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .wready_extsys1_axis_m (wready_extsys1_axis_extsys1_axis_ib_axi4_s),
  .bid_extsys1_axis_m   (bid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .bresp_extsys1_axis_m (bresp_extsys1_axis_extsys1_axis_ib_axi4_s),
  .bvalid_extsys1_axis_m (bvalid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .bready_extsys1_axis_m (bready_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arid_extsys1_axis_m  (arid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .araddr_extsys1_axis_m (araddr_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arlen_extsys1_axis_m (arlen_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arsize_extsys1_axis_m (arsize_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arburst_extsys1_axis_m (arburst_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arlock_extsys1_axis_m (arlock_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arcache_extsys1_axis_m (arcache_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arprot_extsys1_axis_m (arprot_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arvalid_extsys1_axis_m (arvalid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arvalid_vect_extsys1_axis_m (arvalid_vect_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arready_extsys1_axis_m (arready_extsys1_axis_extsys1_axis_ib_axi4_s),
  .rid_extsys1_axis_m   (rid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .rdata_extsys1_axis_m (rdata_extsys1_axis_extsys1_axis_ib_axi4_s),
  .rresp_extsys1_axis_m (rresp_extsys1_axis_extsys1_axis_ib_axi4_s),
  .rlast_extsys1_axis_m (rlast_extsys1_axis_extsys1_axis_ib_axi4_s),
  .rvalid_extsys1_axis_m (rvalid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .rready_extsys1_axis_m (rready_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awuser_extsys1_axis_m (awuser_extsys1_axis_extsys1_axis_ib_axi4_s),
  .buser_extsys1_axis_m (buser_extsys1_axis_extsys1_axis_ib_axi4_s),
  .aruser_extsys1_axis_m (aruser_extsys1_axis_extsys1_axis_ib_axi4_s),
  .ruser_extsys1_axis_m (ruser_extsys1_axis_extsys1_axis_ib_axi4_s),
  .extsys1_axis_port_enable (port_enable_extsys1_axis_port_enable_hcg),
  .awid_extsys1_axis_s  (awid_extsys1_axis),
  .awaddr_extsys1_axis_s (awaddr_extsys1_axis),
  .awlen_extsys1_axis_s (awlen_extsys1_axis),
  .awsize_extsys1_axis_s (awsize_extsys1_axis),
  .awburst_extsys1_axis_s (awburst_extsys1_axis),
  .awlock_extsys1_axis_s (awlock_extsys1_axis),
  .awcache_extsys1_axis_s (awcache_extsys1_axis),
  .awprot_extsys1_axis_s (awprot_extsys1_axis),
  .awvalid_extsys1_axis_s (awvalid_extsys1_axis),
  .awready_extsys1_axis_s (awready_extsys1_axis),
  .wdata_extsys1_axis_s (wdata_extsys1_axis),
  .wstrb_extsys1_axis_s (wstrb_extsys1_axis),
  .wlast_extsys1_axis_s (wlast_extsys1_axis),
  .wvalid_extsys1_axis_s (wvalid_extsys1_axis),
  .wready_extsys1_axis_s (wready_extsys1_axis),
  .bid_extsys1_axis_s   (bid_extsys1_axis),
  .bresp_extsys1_axis_s (bresp_extsys1_axis),
  .bvalid_extsys1_axis_s (bvalid_extsys1_axis),
  .bready_extsys1_axis_s (bready_extsys1_axis),
  .arid_extsys1_axis_s  (arid_extsys1_axis),
  .araddr_extsys1_axis_s (araddr_extsys1_axis),
  .arlen_extsys1_axis_s (arlen_extsys1_axis),
  .arsize_extsys1_axis_s (arsize_extsys1_axis),
  .arburst_extsys1_axis_s (arburst_extsys1_axis),
  .arlock_extsys1_axis_s (arlock_extsys1_axis),
  .arcache_extsys1_axis_s (arcache_extsys1_axis),
  .arprot_extsys1_axis_s (arprot_extsys1_axis),
  .arvalid_extsys1_axis_s (arvalid_extsys1_axis),
  .arready_extsys1_axis_s (arready_extsys1_axis),
  .rid_extsys1_axis_s   (rid_extsys1_axis),
  .rdata_extsys1_axis_s (rdata_extsys1_axis),
  .rresp_extsys1_axis_s (rresp_extsys1_axis),
  .rlast_extsys1_axis_s (rlast_extsys1_axis),
  .rvalid_extsys1_axis_s (rvalid_extsys1_axis),
  .rready_extsys1_axis_s (rready_extsys1_axis),
  .awuser_extsys1_axis_s (awuser_extsys1_axis),
  .buser_extsys1_axis_s (buser_extsys1_axis),
  .aruser_extsys1_axis_s (aruser_extsys1_axis),
  .ruser_extsys1_axis_s (ruser_extsys1_axis),
  .extsys1_axis_cactive_wakeup (cactive_extsys1_axis_wakeup_hcg)
);


nic400_asib_hostcpu_axis_sse710_main     u_asib_hostcpu_axis (
  .paddr                (paddr_hostcpu_axis_apb),
  .pwdata               (pwdata_hostcpu_axis_apb),
  .pwrite               (pwrite_hostcpu_axis_apb),
  .penable              (penable_hostcpu_axis_apb),
  .psel                 (pselx_hostcpu_axis_apb),
  .prdata               (prdata_hostcpu_axis_apb),
  .pslverr              (pslverr_hostcpu_axis_apb),
  .pready               (pready_hostcpu_axis_apb),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .hostcpu_axis_cactive (cactive_hostcpu_axis_hcg),
  .awid_hostcpu_axis_m  (awid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awaddr_hostcpu_axis_m (awaddr_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awlen_hostcpu_axis_m (awlen_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awsize_hostcpu_axis_m (awsize_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awburst_hostcpu_axis_m (awburst_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awlock_hostcpu_axis_m (awlock_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awcache_hostcpu_axis_m (awcache_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awprot_hostcpu_axis_m (awprot_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awvalid_hostcpu_axis_m (awvalid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awvalid_vect_hostcpu_axis_m (awvalid_vect_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awready_hostcpu_axis_m (awready_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .wdata_hostcpu_axis_m (wdata_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .wstrb_hostcpu_axis_m (wstrb_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .wlast_hostcpu_axis_m (wlast_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .wvalid_hostcpu_axis_m (wvalid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .wready_hostcpu_axis_m (wready_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .bid_hostcpu_axis_m   (bid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .bresp_hostcpu_axis_m (bresp_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .bvalid_hostcpu_axis_m (bvalid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .bready_hostcpu_axis_m (bready_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arid_hostcpu_axis_m  (arid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .araddr_hostcpu_axis_m (araddr_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arlen_hostcpu_axis_m (arlen_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arsize_hostcpu_axis_m (arsize_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arburst_hostcpu_axis_m (arburst_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arlock_hostcpu_axis_m (arlock_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arcache_hostcpu_axis_m (arcache_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arprot_hostcpu_axis_m (arprot_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arvalid_hostcpu_axis_m (arvalid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arvalid_vect_hostcpu_axis_m (arvalid_vect_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arready_hostcpu_axis_m (arready_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .rid_hostcpu_axis_m   (rid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .rdata_hostcpu_axis_m (rdata_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .rresp_hostcpu_axis_m (rresp_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .rlast_hostcpu_axis_m (rlast_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .rvalid_hostcpu_axis_m (rvalid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .rready_hostcpu_axis_m (rready_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awuser_hostcpu_axis_m (awuser_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .buser_hostcpu_axis_m (buser_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .aruser_hostcpu_axis_m (aruser_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .ruser_hostcpu_axis_m (ruser_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .hostcpu_axis_port_enable (port_enable_hostcpu_axis_port_enable_hcg),
  .awid_hostcpu_axis_s  (awid_hostcpu_axis),
  .awaddr_hostcpu_axis_s (awaddr_hostcpu_axis),
  .awlen_hostcpu_axis_s (awlen_hostcpu_axis),
  .awsize_hostcpu_axis_s (awsize_hostcpu_axis),
  .awburst_hostcpu_axis_s (awburst_hostcpu_axis),
  .awlock_hostcpu_axis_s (awlock_hostcpu_axis),
  .awcache_hostcpu_axis_s (awcache_hostcpu_axis),
  .awprot_hostcpu_axis_s (awprot_hostcpu_axis),
  .awvalid_hostcpu_axis_s (awvalid_hostcpu_axis),
  .awready_hostcpu_axis_s (awready_hostcpu_axis),
  .wdata_hostcpu_axis_s (wdata_hostcpu_axis),
  .wstrb_hostcpu_axis_s (wstrb_hostcpu_axis),
  .wlast_hostcpu_axis_s (wlast_hostcpu_axis),
  .wvalid_hostcpu_axis_s (wvalid_hostcpu_axis),
  .wready_hostcpu_axis_s (wready_hostcpu_axis),
  .bid_hostcpu_axis_s   (bid_hostcpu_axis),
  .bresp_hostcpu_axis_s (bresp_hostcpu_axis),
  .bvalid_hostcpu_axis_s (bvalid_hostcpu_axis),
  .bready_hostcpu_axis_s (bready_hostcpu_axis),
  .arid_hostcpu_axis_s  (arid_hostcpu_axis),
  .araddr_hostcpu_axis_s (araddr_hostcpu_axis),
  .arlen_hostcpu_axis_s (arlen_hostcpu_axis),
  .arsize_hostcpu_axis_s (arsize_hostcpu_axis),
  .arburst_hostcpu_axis_s (arburst_hostcpu_axis),
  .arlock_hostcpu_axis_s (arlock_hostcpu_axis),
  .arcache_hostcpu_axis_s (arcache_hostcpu_axis),
  .arprot_hostcpu_axis_s (arprot_hostcpu_axis),
  .arvalid_hostcpu_axis_s (arvalid_hostcpu_axis),
  .arready_hostcpu_axis_s (arready_hostcpu_axis),
  .rid_hostcpu_axis_s   (rid_hostcpu_axis),
  .rdata_hostcpu_axis_s (rdata_hostcpu_axis),
  .rresp_hostcpu_axis_s (rresp_hostcpu_axis),
  .rlast_hostcpu_axis_s (rlast_hostcpu_axis),
  .rvalid_hostcpu_axis_s (rvalid_hostcpu_axis),
  .rready_hostcpu_axis_s (rready_hostcpu_axis),
  .awuser_hostcpu_axis_s (awuser_hostcpu_axis),
  .buser_hostcpu_axis_s (buser_hostcpu_axis),
  .aruser_hostcpu_axis_s (aruser_hostcpu_axis),
  .ruser_hostcpu_axis_s (ruser_hostcpu_axis),
  .hostcpu_axis_cactive_wakeup (cactive_hostcpu_axis_wakeup_hcg)
);


nic400_asib_secenc_axis_sse710_main     u_asib_secenc_axis (
  .paddr                (paddr_secenc_axis_apb),
  .pwdata               (pwdata_secenc_axis_apb),
  .pwrite               (pwrite_secenc_axis_apb),
  .penable              (penable_secenc_axis_apb),
  .psel                 (pselx_secenc_axis_apb),
  .prdata               (prdata_secenc_axis_apb),
  .pslverr              (pslverr_secenc_axis_apb),
  .pready               (pready_secenc_axis_apb),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .secenc_axis_cactive  (cactive_secenc_axis_hcg),
  .awid_secenc_axis_m   (awid_secenc_axis_secenc_axis_ib_axi4_s),
  .awaddr_secenc_axis_m (awaddr_secenc_axis_secenc_axis_ib_axi4_s),
  .awlen_secenc_axis_m  (awlen_secenc_axis_secenc_axis_ib_axi4_s),
  .awsize_secenc_axis_m (awsize_secenc_axis_secenc_axis_ib_axi4_s),
  .awburst_secenc_axis_m (awburst_secenc_axis_secenc_axis_ib_axi4_s),
  .awlock_secenc_axis_m (awlock_secenc_axis_secenc_axis_ib_axi4_s),
  .awcache_secenc_axis_m (awcache_secenc_axis_secenc_axis_ib_axi4_s),
  .awprot_secenc_axis_m (awprot_secenc_axis_secenc_axis_ib_axi4_s),
  .awvalid_secenc_axis_m (awvalid_secenc_axis_secenc_axis_ib_axi4_s),
  .awvalid_vect_secenc_axis_m (awvalid_vect_secenc_axis_secenc_axis_ib_axi4_s),
  .awready_secenc_axis_m (awready_secenc_axis_secenc_axis_ib_axi4_s),
  .wdata_secenc_axis_m  (wdata_secenc_axis_secenc_axis_ib_axi4_s),
  .wstrb_secenc_axis_m  (wstrb_secenc_axis_secenc_axis_ib_axi4_s),
  .wlast_secenc_axis_m  (wlast_secenc_axis_secenc_axis_ib_axi4_s),
  .wvalid_secenc_axis_m (wvalid_secenc_axis_secenc_axis_ib_axi4_s),
  .wready_secenc_axis_m (wready_secenc_axis_secenc_axis_ib_axi4_s),
  .bid_secenc_axis_m    (bid_secenc_axis_secenc_axis_ib_axi4_s),
  .bresp_secenc_axis_m  (bresp_secenc_axis_secenc_axis_ib_axi4_s),
  .bvalid_secenc_axis_m (bvalid_secenc_axis_secenc_axis_ib_axi4_s),
  .bready_secenc_axis_m (bready_secenc_axis_secenc_axis_ib_axi4_s),
  .arid_secenc_axis_m   (arid_secenc_axis_secenc_axis_ib_axi4_s),
  .araddr_secenc_axis_m (araddr_secenc_axis_secenc_axis_ib_axi4_s),
  .arlen_secenc_axis_m  (arlen_secenc_axis_secenc_axis_ib_axi4_s),
  .arsize_secenc_axis_m (arsize_secenc_axis_secenc_axis_ib_axi4_s),
  .arburst_secenc_axis_m (arburst_secenc_axis_secenc_axis_ib_axi4_s),
  .arlock_secenc_axis_m (arlock_secenc_axis_secenc_axis_ib_axi4_s),
  .arcache_secenc_axis_m (arcache_secenc_axis_secenc_axis_ib_axi4_s),
  .arprot_secenc_axis_m (arprot_secenc_axis_secenc_axis_ib_axi4_s),
  .arvalid_secenc_axis_m (arvalid_secenc_axis_secenc_axis_ib_axi4_s),
  .arvalid_vect_secenc_axis_m (arvalid_vect_secenc_axis_secenc_axis_ib_axi4_s),
  .arready_secenc_axis_m (arready_secenc_axis_secenc_axis_ib_axi4_s),
  .rid_secenc_axis_m    (rid_secenc_axis_secenc_axis_ib_axi4_s),
  .rdata_secenc_axis_m  (rdata_secenc_axis_secenc_axis_ib_axi4_s),
  .rresp_secenc_axis_m  (rresp_secenc_axis_secenc_axis_ib_axi4_s),
  .rlast_secenc_axis_m  (rlast_secenc_axis_secenc_axis_ib_axi4_s),
  .rvalid_secenc_axis_m (rvalid_secenc_axis_secenc_axis_ib_axi4_s),
  .rready_secenc_axis_m (rready_secenc_axis_secenc_axis_ib_axi4_s),
  .awuser_secenc_axis_m (awuser_secenc_axis_secenc_axis_ib_axi4_s),
  .buser_secenc_axis_m  (buser_secenc_axis_secenc_axis_ib_axi4_s),
  .aruser_secenc_axis_m (aruser_secenc_axis_secenc_axis_ib_axi4_s),
  .ruser_secenc_axis_m  (ruser_secenc_axis_secenc_axis_ib_axi4_s),
  .secenc_axis_port_enable (port_enable_secenc_axis_port_enable_hcg),
  .awid_secenc_axis_s   (awid_secenc_axis),
  .awaddr_secenc_axis_s (awaddr_secenc_axis),
  .awlen_secenc_axis_s  (awlen_secenc_axis),
  .awsize_secenc_axis_s (awsize_secenc_axis),
  .awburst_secenc_axis_s (awburst_secenc_axis),
  .awlock_secenc_axis_s (awlock_secenc_axis),
  .awcache_secenc_axis_s (awcache_secenc_axis),
  .awprot_secenc_axis_s (awprot_secenc_axis),
  .awvalid_secenc_axis_s (awvalid_secenc_axis),
  .awready_secenc_axis_s (awready_secenc_axis),
  .wdata_secenc_axis_s  (wdata_secenc_axis),
  .wstrb_secenc_axis_s  (wstrb_secenc_axis),
  .wlast_secenc_axis_s  (wlast_secenc_axis),
  .wvalid_secenc_axis_s (wvalid_secenc_axis),
  .wready_secenc_axis_s (wready_secenc_axis),
  .bid_secenc_axis_s    (bid_secenc_axis),
  .bresp_secenc_axis_s  (bresp_secenc_axis),
  .bvalid_secenc_axis_s (bvalid_secenc_axis),
  .bready_secenc_axis_s (bready_secenc_axis),
  .arid_secenc_axis_s   (arid_secenc_axis),
  .araddr_secenc_axis_s (araddr_secenc_axis),
  .arlen_secenc_axis_s  (arlen_secenc_axis),
  .arsize_secenc_axis_s (arsize_secenc_axis),
  .arburst_secenc_axis_s (arburst_secenc_axis),
  .arlock_secenc_axis_s (arlock_secenc_axis),
  .arcache_secenc_axis_s (arcache_secenc_axis),
  .arprot_secenc_axis_s (arprot_secenc_axis),
  .arvalid_secenc_axis_s (arvalid_secenc_axis),
  .arready_secenc_axis_s (arready_secenc_axis),
  .rid_secenc_axis_s    (rid_secenc_axis),
  .rdata_secenc_axis_s  (rdata_secenc_axis),
  .rresp_secenc_axis_s  (rresp_secenc_axis),
  .rlast_secenc_axis_s  (rlast_secenc_axis),
  .rvalid_secenc_axis_s (rvalid_secenc_axis),
  .rready_secenc_axis_s (rready_secenc_axis),
  .awuser_secenc_axis_s (awuser_secenc_axis),
  .buser_secenc_axis_s  (buser_secenc_axis),
  .aruser_secenc_axis_s (aruser_secenc_axis),
  .ruser_secenc_axis_s  (ruser_secenc_axis),
  .secenc_axis_cactive_wakeup (cactive_secenc_axis_wakeup_hcg)
);


nic400_switch1_sse710_main     u_busmatrix_switch1 (
  .awid_axi_m_0         (awid_switch1_gpv_0_ib1_axi4_s),
  .awaddr_axi_m_0       (awaddr_switch1_gpv_0_ib1_axi4_s),
  .awlen_axi_m_0        (awlen_switch1_gpv_0_ib1_axi4_s),
  .awsize_axi_m_0       (awsize_switch1_gpv_0_ib1_axi4_s),
  .awburst_axi_m_0      (awburst_switch1_gpv_0_ib1_axi4_s),
  .awlock_axi_m_0       (awlock_switch1_gpv_0_ib1_axi4_s),
  .awcache_axi_m_0      (awcache_switch1_gpv_0_ib1_axi4_s),
  .awprot_axi_m_0       (awprot_switch1_gpv_0_ib1_axi4_s),
  .awvalid_axi_m_0      (awvalid_switch1_gpv_0_ib1_axi4_s),
  .awvalid_vect_axi_m_0 (),
  .awready_axi_m_0      (awready_switch1_gpv_0_ib1_axi4_s),
  .wdata_axi_m_0        (wdata_switch1_gpv_0_ib1_axi4_s),
  .wstrb_axi_m_0        (wstrb_switch1_gpv_0_ib1_axi4_s),
  .wlast_axi_m_0        (wlast_switch1_gpv_0_ib1_axi4_s),
  .wvalid_axi_m_0       (wvalid_switch1_gpv_0_ib1_axi4_s),
  .wready_axi_m_0       (wready_switch1_gpv_0_ib1_axi4_s),
  .bid_axi_m_0          (bid_switch1_gpv_0_ib1_axi4_s),
  .bresp_axi_m_0        (bresp_switch1_gpv_0_ib1_axi4_s),
  .bvalid_axi_m_0       (bvalid_switch1_gpv_0_ib1_axi4_s),
  .bready_axi_m_0       (bready_switch1_gpv_0_ib1_axi4_s),
  .arid_axi_m_0         (arid_switch1_gpv_0_ib1_axi4_s),
  .araddr_axi_m_0       (araddr_switch1_gpv_0_ib1_axi4_s),
  .arlen_axi_m_0        (arlen_switch1_gpv_0_ib1_axi4_s),
  .arsize_axi_m_0       (arsize_switch1_gpv_0_ib1_axi4_s),
  .arburst_axi_m_0      (arburst_switch1_gpv_0_ib1_axi4_s),
  .arlock_axi_m_0       (arlock_switch1_gpv_0_ib1_axi4_s),
  .arcache_axi_m_0      (arcache_switch1_gpv_0_ib1_axi4_s),
  .arprot_axi_m_0       (arprot_switch1_gpv_0_ib1_axi4_s),
  .arvalid_axi_m_0      (arvalid_switch1_gpv_0_ib1_axi4_s),
  .arvalid_vect_axi_m_0 (),
  .arready_axi_m_0      (arready_switch1_gpv_0_ib1_axi4_s),
  .rid_axi_m_0          (rid_switch1_gpv_0_ib1_axi4_s),
  .rdata_axi_m_0        (rdata_switch1_gpv_0_ib1_axi4_s),
  .rresp_axi_m_0        (rresp_switch1_gpv_0_ib1_axi4_s),
  .rlast_axi_m_0        (rlast_switch1_gpv_0_ib1_axi4_s),
  .rvalid_axi_m_0       (rvalid_switch1_gpv_0_ib1_axi4_s),
  .rready_axi_m_0       (rready_switch1_gpv_0_ib1_axi4_s),
  .awuser_axi_m_0       (),
  .buser_axi_m_0        (1'b0),
  .aruser_axi_m_0       (),
  .ruser_axi_m_0        (1'b0),
  .aw_qv_axi_m_0        (),
  .ar_qv_axi_m_0        (),
  .awid_axi_m_1         (awid_switch1_ds_2_axi_s_0),
  .awaddr_axi_m_1       (),
  .awlen_axi_m_1        (),
  .awsize_axi_m_1       (),
  .awburst_axi_m_1      (),
  .awlock_axi_m_1       (),
  .awcache_axi_m_1      (),
  .awprot_axi_m_1       (),
  .awvalid_axi_m_1      (awvalid_switch1_ds_2_axi_s_0),
  .awvalid_vect_axi_m_1 (),
  .awready_axi_m_1      (awready_switch1_ds_2_axi_s_0),
  .wdata_axi_m_1        (),
  .wstrb_axi_m_1        (),
  .wlast_axi_m_1        (wlast_switch1_ds_2_axi_s_0),
  .wvalid_axi_m_1       (wvalid_switch1_ds_2_axi_s_0),
  .wready_axi_m_1       (wready_switch1_ds_2_axi_s_0),
  .bid_axi_m_1          (bid_switch1_ds_2_axi_s_0),
  .bresp_axi_m_1        (bresp_switch1_ds_2_axi_s_0),
  .bvalid_axi_m_1       (bvalid_switch1_ds_2_axi_s_0),
  .bready_axi_m_1       (bready_switch1_ds_2_axi_s_0),
  .arid_axi_m_1         (arid_switch1_ds_2_axi_s_0),
  .araddr_axi_m_1       (),
  .arlen_axi_m_1        (arlen_switch1_ds_2_axi_s_0),
  .arsize_axi_m_1       (),
  .arburst_axi_m_1      (),
  .arlock_axi_m_1       (),
  .arcache_axi_m_1      (),
  .arprot_axi_m_1       (),
  .arvalid_axi_m_1      (arvalid_switch1_ds_2_axi_s_0),
  .arvalid_vect_axi_m_1 (),
  .arready_axi_m_1      (arready_switch1_ds_2_axi_s_0),
  .rid_axi_m_1          (rid_switch1_ds_2_axi_s_0),
  .rdata_axi_m_1        (32'b0),
  .rresp_axi_m_1        (rresp_switch1_ds_2_axi_s_0),
  .rlast_axi_m_1        (rlast_switch1_ds_2_axi_s_0),
  .rvalid_axi_m_1       (rvalid_switch1_ds_2_axi_s_0),
  .rready_axi_m_1       (rready_switch1_ds_2_axi_s_0),
  .awuser_axi_m_1       (),
  .buser_axi_m_1        (1'b0),
  .aruser_axi_m_1       (),
  .ruser_axi_m_1        (1'b0),
  .aw_qv_axi_m_1        (),
  .ar_qv_axi_m_1        (),
  .awid_axi_m_2         (awid_switch1_ib1_axi_s_0),
  .awaddr_axi_m_2       (awaddr_switch1_ib1_axi_s_0),
  .awlen_axi_m_2        (awlen_switch1_ib1_axi_s_0),
  .awsize_axi_m_2       (awsize_switch1_ib1_axi_s_0),
  .awburst_axi_m_2      (awburst_switch1_ib1_axi_s_0),
  .awlock_axi_m_2       (awlock_switch1_ib1_axi_s_0),
  .awcache_axi_m_2      (awcache_switch1_ib1_axi_s_0),
  .awprot_axi_m_2       (awprot_switch1_ib1_axi_s_0),
  .awvalid_axi_m_2      (awvalid_switch1_ib1_axi_s_0),
  .awvalid_vect_axi_m_2 (awvalid_vect_switch1_ib1_axi_s_0),
  .awready_axi_m_2      (awready_switch1_ib1_axi_s_0),
  .wdata_axi_m_2        (wdata_switch1_ib1_axi_s_0),
  .wstrb_axi_m_2        (wstrb_switch1_ib1_axi_s_0),
  .wlast_axi_m_2        (wlast_switch1_ib1_axi_s_0),
  .wvalid_axi_m_2       (wvalid_switch1_ib1_axi_s_0),
  .wready_axi_m_2       (wready_switch1_ib1_axi_s_0),
  .bid_axi_m_2          (bid_switch1_ib1_axi_s_0),
  .bresp_axi_m_2        (bresp_switch1_ib1_axi_s_0),
  .bvalid_axi_m_2       (bvalid_switch1_ib1_axi_s_0),
  .bready_axi_m_2       (bready_switch1_ib1_axi_s_0),
  .arid_axi_m_2         (arid_switch1_ib1_axi_s_0),
  .araddr_axi_m_2       (araddr_switch1_ib1_axi_s_0),
  .arlen_axi_m_2        (arlen_switch1_ib1_axi_s_0),
  .arsize_axi_m_2       (arsize_switch1_ib1_axi_s_0),
  .arburst_axi_m_2      (arburst_switch1_ib1_axi_s_0),
  .arlock_axi_m_2       (arlock_switch1_ib1_axi_s_0),
  .arcache_axi_m_2      (arcache_switch1_ib1_axi_s_0),
  .arprot_axi_m_2       (arprot_switch1_ib1_axi_s_0),
  .arvalid_axi_m_2      (arvalid_switch1_ib1_axi_s_0),
  .arvalid_vect_axi_m_2 (arvalid_vect_switch1_ib1_axi_s_0),
  .arready_axi_m_2      (arready_switch1_ib1_axi_s_0),
  .rid_axi_m_2          (rid_switch1_ib1_axi_s_0),
  .rdata_axi_m_2        (rdata_switch1_ib1_axi_s_0),
  .rresp_axi_m_2        (rresp_switch1_ib1_axi_s_0),
  .rlast_axi_m_2        (rlast_switch1_ib1_axi_s_0),
  .rvalid_axi_m_2       (rvalid_switch1_ib1_axi_s_0),
  .rready_axi_m_2       (rready_switch1_ib1_axi_s_0),
  .awuser_axi_m_2       (awuser_switch1_ib1_axi_s_0),
  .buser_axi_m_2        (buser_switch1_ib1_axi_s_0),
  .aruser_axi_m_2       (aruser_switch1_ib1_axi_s_0),
  .ruser_axi_m_2        (ruser_switch1_ib1_axi_s_0),
  .aw_qv_axi_m_2        (awqv_switch1_ib1_axi_s_0),
  .ar_qv_axi_m_2        (arqv_switch1_ib1_axi_s_0),
  .awid_axi_s_0         (awid_secenc_axis_ib_switch1_axi_s_0),
  .awaddr_axi_s_0       (awaddr_secenc_axis_ib_switch1_axi_s_0),
  .awlen_axi_s_0        (awlen_secenc_axis_ib_switch1_axi_s_0),
  .awsize_axi_s_0       (awsize_secenc_axis_ib_switch1_axi_s_0),
  .awburst_axi_s_0      (awburst_secenc_axis_ib_switch1_axi_s_0),
  .awlock_axi_s_0       (awlock_secenc_axis_ib_switch1_axi_s_0),
  .awcache_axi_s_0      (awcache_secenc_axis_ib_switch1_axi_s_0),
  .awprot_axi_s_0       (awprot_secenc_axis_ib_switch1_axi_s_0),
  .awvalid_axi_s_0      (awvalid_secenc_axis_ib_switch1_axi_s_0),
  .awvalid_vect_axi_s_0 (awvalid_vect_secenc_axis_ib_switch1_axi_s_0),
  .awready_axi_s_0      (awready_secenc_axis_ib_switch1_axi_s_0),
  .wdata_axi_s_0        (wdata_secenc_axis_ib_switch1_axi_s_0),
  .wstrb_axi_s_0        (wstrb_secenc_axis_ib_switch1_axi_s_0),
  .wlast_axi_s_0        (wlast_secenc_axis_ib_switch1_axi_s_0),
  .wvalid_axi_s_0       (wvalid_secenc_axis_ib_switch1_axi_s_0),
  .wready_axi_s_0       (wready_secenc_axis_ib_switch1_axi_s_0),
  .bid_axi_s_0          (bid_secenc_axis_ib_switch1_axi_s_0),
  .bresp_axi_s_0        (bresp_secenc_axis_ib_switch1_axi_s_0),
  .bvalid_axi_s_0       (bvalid_secenc_axis_ib_switch1_axi_s_0),
  .bready_axi_s_0       (bready_secenc_axis_ib_switch1_axi_s_0),
  .arid_axi_s_0         (arid_secenc_axis_ib_switch1_axi_s_0),
  .araddr_axi_s_0       (araddr_secenc_axis_ib_switch1_axi_s_0),
  .arlen_axi_s_0        (arlen_secenc_axis_ib_switch1_axi_s_0),
  .arsize_axi_s_0       (arsize_secenc_axis_ib_switch1_axi_s_0),
  .arburst_axi_s_0      (arburst_secenc_axis_ib_switch1_axi_s_0),
  .arlock_axi_s_0       (arlock_secenc_axis_ib_switch1_axi_s_0),
  .arcache_axi_s_0      (arcache_secenc_axis_ib_switch1_axi_s_0),
  .arprot_axi_s_0       (arprot_secenc_axis_ib_switch1_axi_s_0),
  .arvalid_axi_s_0      (arvalid_secenc_axis_ib_switch1_axi_s_0),
  .arvalid_vect_axi_s_0 (arvalid_vect_secenc_axis_ib_switch1_axi_s_0),
  .arready_axi_s_0      (arready_secenc_axis_ib_switch1_axi_s_0),
  .rid_axi_s_0          (rid_secenc_axis_ib_switch1_axi_s_0),
  .rdata_axi_s_0        (rdata_secenc_axis_ib_switch1_axi_s_0),
  .rresp_axi_s_0        (rresp_secenc_axis_ib_switch1_axi_s_0),
  .rlast_axi_s_0        (rlast_secenc_axis_ib_switch1_axi_s_0),
  .rvalid_axi_s_0       (rvalid_secenc_axis_ib_switch1_axi_s_0),
  .rready_axi_s_0       (rready_secenc_axis_ib_switch1_axi_s_0),
  .awuser_axi_s_0       (awuser_secenc_axis_ib_switch1_axi_s_0),
  .buser_axi_s_0        (buser_secenc_axis_ib_switch1_axi_s_0),
  .aruser_axi_s_0       (aruser_secenc_axis_ib_switch1_axi_s_0),
  .ruser_axi_s_0        (ruser_secenc_axis_ib_switch1_axi_s_0),
  .aw_qv_axi_s_0        (awqv_secenc_axis_ib_switch1_axi_s_0),
  .ar_qv_axi_s_0        (arqv_secenc_axis_ib_switch1_axi_s_0),
  .awid_axi_s_5         (awid_gpvmain_ahb_ib_switch1_axi_s_5),
  .awaddr_axi_s_5       (awaddr_gpvmain_ahb_ib_switch1_axi_s_5),
  .awlen_axi_s_5        (awlen_gpvmain_ahb_ib_switch1_axi_s_5),
  .awsize_axi_s_5       (awsize_gpvmain_ahb_ib_switch1_axi_s_5),
  .awburst_axi_s_5      (awburst_gpvmain_ahb_ib_switch1_axi_s_5),
  .awlock_axi_s_5       (awlock_gpvmain_ahb_ib_switch1_axi_s_5),
  .awcache_axi_s_5      (awcache_gpvmain_ahb_ib_switch1_axi_s_5),
  .awprot_axi_s_5       (awprot_gpvmain_ahb_ib_switch1_axi_s_5),
  .awvalid_axi_s_5      (awvalid_gpvmain_ahb_ib_switch1_axi_s_5),
  .awvalid_vect_axi_s_5 (awvalid_vect_gpvmain_ahb_ib_switch1_axi_s_5),
  .awready_axi_s_5      (awready_gpvmain_ahb_ib_switch1_axi_s_5),
  .wdata_axi_s_5        (wdata_gpvmain_ahb_ib_switch1_axi_s_5),
  .wstrb_axi_s_5        (wstrb_gpvmain_ahb_ib_switch1_axi_s_5),
  .wlast_axi_s_5        (wlast_gpvmain_ahb_ib_switch1_axi_s_5),
  .wvalid_axi_s_5       (wvalid_gpvmain_ahb_ib_switch1_axi_s_5),
  .wready_axi_s_5       (wready_gpvmain_ahb_ib_switch1_axi_s_5),
  .bid_axi_s_5          (bid_gpvmain_ahb_ib_switch1_axi_s_5),
  .bresp_axi_s_5        (bresp_gpvmain_ahb_ib_switch1_axi_s_5),
  .bvalid_axi_s_5       (bvalid_gpvmain_ahb_ib_switch1_axi_s_5),
  .bready_axi_s_5       (bready_gpvmain_ahb_ib_switch1_axi_s_5),
  .arid_axi_s_5         (arid_gpvmain_ahb_ib_switch1_axi_s_5),
  .araddr_axi_s_5       (araddr_gpvmain_ahb_ib_switch1_axi_s_5),
  .arlen_axi_s_5        (arlen_gpvmain_ahb_ib_switch1_axi_s_5),
  .arsize_axi_s_5       (arsize_gpvmain_ahb_ib_switch1_axi_s_5),
  .arburst_axi_s_5      (arburst_gpvmain_ahb_ib_switch1_axi_s_5),
  .arlock_axi_s_5       (arlock_gpvmain_ahb_ib_switch1_axi_s_5),
  .arcache_axi_s_5      (arcache_gpvmain_ahb_ib_switch1_axi_s_5),
  .arprot_axi_s_5       (arprot_gpvmain_ahb_ib_switch1_axi_s_5),
  .arvalid_axi_s_5      (arvalid_gpvmain_ahb_ib_switch1_axi_s_5),
  .arvalid_vect_axi_s_5 (arvalid_vect_gpvmain_ahb_ib_switch1_axi_s_5),
  .arready_axi_s_5      (arready_gpvmain_ahb_ib_switch1_axi_s_5),
  .rid_axi_s_5          (rid_gpvmain_ahb_ib_switch1_axi_s_5),
  .rdata_axi_s_5        (rdata_gpvmain_ahb_ib_switch1_axi_s_5),
  .rresp_axi_s_5        (rresp_gpvmain_ahb_ib_switch1_axi_s_5),
  .rlast_axi_s_5        (rlast_gpvmain_ahb_ib_switch1_axi_s_5),
  .rvalid_axi_s_5       (rvalid_gpvmain_ahb_ib_switch1_axi_s_5),
  .rready_axi_s_5       (rready_gpvmain_ahb_ib_switch1_axi_s_5),
  .awuser_axi_s_5       (10'b0),
  .buser_axi_s_5        (),
  .aruser_axi_s_5       (10'b0),
  .ruser_axi_s_5        (),
  .aw_qv_axi_s_5        (awqv_gpvmain_ahb_ib_switch1_axi_s_5),
  .ar_qv_axi_s_5        (arqv_gpvmain_ahb_ib_switch1_axi_s_5),
  .aclk                 (aclk),
  .aresetn              (aresetn)
);


nic400_switch2_sse710_main     u_busmatrix_switch2 (
  .awid_axi_m_0         (awid_switch2_debug_axim_ib_axi4_s),
  .awaddr_axi_m_0       (awaddr_switch2_debug_axim_ib_axi4_s),
  .awlen_axi_m_0        (awlen_switch2_debug_axim_ib_axi4_s),
  .awsize_axi_m_0       (awsize_switch2_debug_axim_ib_axi4_s),
  .awburst_axi_m_0      (awburst_switch2_debug_axim_ib_axi4_s),
  .awlock_axi_m_0       (awlock_switch2_debug_axim_ib_axi4_s),
  .awcache_axi_m_0      (awcache_switch2_debug_axim_ib_axi4_s),
  .awprot_axi_m_0       (awprot_switch2_debug_axim_ib_axi4_s),
  .awvalid_axi_m_0      (awvalid_switch2_debug_axim_ib_axi4_s),
  .awvalid_vect_axi_m_0 (),
  .awready_axi_m_0      (awready_switch2_debug_axim_ib_axi4_s),
  .wdata_axi_m_0        (wdata_switch2_debug_axim_ib_axi4_s),
  .wstrb_axi_m_0        (wstrb_switch2_debug_axim_ib_axi4_s),
  .wlast_axi_m_0        (wlast_switch2_debug_axim_ib_axi4_s),
  .wvalid_axi_m_0       (wvalid_switch2_debug_axim_ib_axi4_s),
  .wready_axi_m_0       (wready_switch2_debug_axim_ib_axi4_s),
  .bid_axi_m_0          (bid_switch2_debug_axim_ib_axi4_s),
  .bresp_axi_m_0        (bresp_switch2_debug_axim_ib_axi4_s),
  .bvalid_axi_m_0       (bvalid_switch2_debug_axim_ib_axi4_s),
  .bready_axi_m_0       (bready_switch2_debug_axim_ib_axi4_s),
  .arid_axi_m_0         (arid_switch2_debug_axim_ib_axi4_s),
  .araddr_axi_m_0       (araddr_switch2_debug_axim_ib_axi4_s),
  .arlen_axi_m_0        (arlen_switch2_debug_axim_ib_axi4_s),
  .arsize_axi_m_0       (arsize_switch2_debug_axim_ib_axi4_s),
  .arburst_axi_m_0      (arburst_switch2_debug_axim_ib_axi4_s),
  .arlock_axi_m_0       (arlock_switch2_debug_axim_ib_axi4_s),
  .arcache_axi_m_0      (arcache_switch2_debug_axim_ib_axi4_s),
  .arprot_axi_m_0       (arprot_switch2_debug_axim_ib_axi4_s),
  .arvalid_axi_m_0      (arvalid_switch2_debug_axim_ib_axi4_s),
  .arvalid_vect_axi_m_0 (),
  .arready_axi_m_0      (arready_switch2_debug_axim_ib_axi4_s),
  .rid_axi_m_0          (rid_switch2_debug_axim_ib_axi4_s),
  .rdata_axi_m_0        (rdata_switch2_debug_axim_ib_axi4_s),
  .rresp_axi_m_0        (rresp_switch2_debug_axim_ib_axi4_s),
  .rlast_axi_m_0        (rlast_switch2_debug_axim_ib_axi4_s),
  .rvalid_axi_m_0       (rvalid_switch2_debug_axim_ib_axi4_s),
  .rready_axi_m_0       (rready_switch2_debug_axim_ib_axi4_s),
  .awuser_axi_m_0       (awuser_switch2_debug_axim_ib_axi4_s),
  .buser_axi_m_0        (buser_switch2_debug_axim_ib_axi4_s),
  .aruser_axi_m_0       (aruser_switch2_debug_axim_ib_axi4_s),
  .ruser_axi_m_0        (ruser_switch2_debug_axim_ib_axi4_s),
  .aw_qv_axi_m_0        (),
  .ar_qv_axi_m_0        (),
  .awid_axi_m_1         (awid_switch2_cvm_axim_ib_axi4_s),
  .awaddr_axi_m_1       (awaddr_switch2_cvm_axim_ib_axi4_s),
  .awlen_axi_m_1        (awlen_switch2_cvm_axim_ib_axi4_s),
  .awsize_axi_m_1       (awsize_switch2_cvm_axim_ib_axi4_s),
  .awburst_axi_m_1      (awburst_switch2_cvm_axim_ib_axi4_s),
  .awlock_axi_m_1       (awlock_switch2_cvm_axim_ib_axi4_s),
  .awcache_axi_m_1      (awcache_switch2_cvm_axim_ib_axi4_s),
  .awprot_axi_m_1       (awprot_switch2_cvm_axim_ib_axi4_s),
  .awvalid_axi_m_1      (awvalid_switch2_cvm_axim_ib_axi4_s),
  .awvalid_vect_axi_m_1 (),
  .awready_axi_m_1      (awready_switch2_cvm_axim_ib_axi4_s),
  .wdata_axi_m_1        (wdata_switch2_cvm_axim_ib_axi4_s),
  .wstrb_axi_m_1        (wstrb_switch2_cvm_axim_ib_axi4_s),
  .wlast_axi_m_1        (wlast_switch2_cvm_axim_ib_axi4_s),
  .wvalid_axi_m_1       (wvalid_switch2_cvm_axim_ib_axi4_s),
  .wready_axi_m_1       (wready_switch2_cvm_axim_ib_axi4_s),
  .bid_axi_m_1          (bid_switch2_cvm_axim_ib_axi4_s),
  .bresp_axi_m_1        (bresp_switch2_cvm_axim_ib_axi4_s),
  .bvalid_axi_m_1       (bvalid_switch2_cvm_axim_ib_axi4_s),
  .bready_axi_m_1       (bready_switch2_cvm_axim_ib_axi4_s),
  .arid_axi_m_1         (arid_switch2_cvm_axim_ib_axi4_s),
  .araddr_axi_m_1       (araddr_switch2_cvm_axim_ib_axi4_s),
  .arlen_axi_m_1        (arlen_switch2_cvm_axim_ib_axi4_s),
  .arsize_axi_m_1       (arsize_switch2_cvm_axim_ib_axi4_s),
  .arburst_axi_m_1      (arburst_switch2_cvm_axim_ib_axi4_s),
  .arlock_axi_m_1       (arlock_switch2_cvm_axim_ib_axi4_s),
  .arcache_axi_m_1      (arcache_switch2_cvm_axim_ib_axi4_s),
  .arprot_axi_m_1       (arprot_switch2_cvm_axim_ib_axi4_s),
  .arvalid_axi_m_1      (arvalid_switch2_cvm_axim_ib_axi4_s),
  .arvalid_vect_axi_m_1 (),
  .arready_axi_m_1      (arready_switch2_cvm_axim_ib_axi4_s),
  .rid_axi_m_1          (rid_switch2_cvm_axim_ib_axi4_s),
  .rdata_axi_m_1        (rdata_switch2_cvm_axim_ib_axi4_s),
  .rresp_axi_m_1        (rresp_switch2_cvm_axim_ib_axi4_s),
  .rlast_axi_m_1        (rlast_switch2_cvm_axim_ib_axi4_s),
  .rvalid_axi_m_1       (rvalid_switch2_cvm_axim_ib_axi4_s),
  .rready_axi_m_1       (rready_switch2_cvm_axim_ib_axi4_s),
  .awuser_axi_m_1       (awuser_switch2_cvm_axim_ib_axi4_s),
  .buser_axi_m_1        (buser_switch2_cvm_axim_ib_axi4_s),
  .aruser_axi_m_1       (aruser_switch2_cvm_axim_ib_axi4_s),
  .ruser_axi_m_1        (ruser_switch2_cvm_axim_ib_axi4_s),
  .aw_qv_axi_m_1        (awqv_switch2_cvm_axim_ib_axi4_s),
  .ar_qv_axi_m_1        (arqv_switch2_cvm_axim_ib_axi4_s),
  .awid_axi_m_2         (awid_switch2_xnvm_axim_ib_axi4_s),
  .awaddr_axi_m_2       (awaddr_switch2_xnvm_axim_ib_axi4_s),
  .awlen_axi_m_2        (awlen_switch2_xnvm_axim_ib_axi4_s),
  .awsize_axi_m_2       (awsize_switch2_xnvm_axim_ib_axi4_s),
  .awburst_axi_m_2      (awburst_switch2_xnvm_axim_ib_axi4_s),
  .awlock_axi_m_2       (awlock_switch2_xnvm_axim_ib_axi4_s),
  .awcache_axi_m_2      (awcache_switch2_xnvm_axim_ib_axi4_s),
  .awprot_axi_m_2       (awprot_switch2_xnvm_axim_ib_axi4_s),
  .awvalid_axi_m_2      (awvalid_switch2_xnvm_axim_ib_axi4_s),
  .awvalid_vect_axi_m_2 (),
  .awready_axi_m_2      (awready_switch2_xnvm_axim_ib_axi4_s),
  .wdata_axi_m_2        (wdata_switch2_xnvm_axim_ib_axi4_s),
  .wstrb_axi_m_2        (wstrb_switch2_xnvm_axim_ib_axi4_s),
  .wlast_axi_m_2        (wlast_switch2_xnvm_axim_ib_axi4_s),
  .wvalid_axi_m_2       (wvalid_switch2_xnvm_axim_ib_axi4_s),
  .wready_axi_m_2       (wready_switch2_xnvm_axim_ib_axi4_s),
  .bid_axi_m_2          (bid_switch2_xnvm_axim_ib_axi4_s),
  .bresp_axi_m_2        (bresp_switch2_xnvm_axim_ib_axi4_s),
  .bvalid_axi_m_2       (bvalid_switch2_xnvm_axim_ib_axi4_s),
  .bready_axi_m_2       (bready_switch2_xnvm_axim_ib_axi4_s),
  .arid_axi_m_2         (arid_switch2_xnvm_axim_ib_axi4_s),
  .araddr_axi_m_2       (araddr_switch2_xnvm_axim_ib_axi4_s),
  .arlen_axi_m_2        (arlen_switch2_xnvm_axim_ib_axi4_s),
  .arsize_axi_m_2       (arsize_switch2_xnvm_axim_ib_axi4_s),
  .arburst_axi_m_2      (arburst_switch2_xnvm_axim_ib_axi4_s),
  .arlock_axi_m_2       (arlock_switch2_xnvm_axim_ib_axi4_s),
  .arcache_axi_m_2      (arcache_switch2_xnvm_axim_ib_axi4_s),
  .arprot_axi_m_2       (arprot_switch2_xnvm_axim_ib_axi4_s),
  .arvalid_axi_m_2      (arvalid_switch2_xnvm_axim_ib_axi4_s),
  .arvalid_vect_axi_m_2 (),
  .arready_axi_m_2      (arready_switch2_xnvm_axim_ib_axi4_s),
  .rid_axi_m_2          (rid_switch2_xnvm_axim_ib_axi4_s),
  .rdata_axi_m_2        (rdata_switch2_xnvm_axim_ib_axi4_s),
  .rresp_axi_m_2        (rresp_switch2_xnvm_axim_ib_axi4_s),
  .rlast_axi_m_2        (rlast_switch2_xnvm_axim_ib_axi4_s),
  .rvalid_axi_m_2       (rvalid_switch2_xnvm_axim_ib_axi4_s),
  .rready_axi_m_2       (rready_switch2_xnvm_axim_ib_axi4_s),
  .awuser_axi_m_2       (awuser_switch2_xnvm_axim_ib_axi4_s),
  .buser_axi_m_2        (buser_switch2_xnvm_axim_ib_axi4_s),
  .aruser_axi_m_2       (aruser_switch2_xnvm_axim_ib_axi4_s),
  .ruser_axi_m_2        (ruser_switch2_xnvm_axim_ib_axi4_s),
  .aw_qv_axi_m_2        (awqv_switch2_xnvm_axim_ib_axi4_s),
  .ar_qv_axi_m_2        (arqv_switch2_xnvm_axim_ib_axi4_s),
  .awid_axi_m_3         (awid_switch2_expmstr0_axim_ib_axi4_s),
  .awaddr_axi_m_3       (awaddr_switch2_expmstr0_axim_ib_axi4_s),
  .awlen_axi_m_3        (awlen_switch2_expmstr0_axim_ib_axi4_s),
  .awsize_axi_m_3       (awsize_switch2_expmstr0_axim_ib_axi4_s),
  .awburst_axi_m_3      (awburst_switch2_expmstr0_axim_ib_axi4_s),
  .awlock_axi_m_3       (awlock_switch2_expmstr0_axim_ib_axi4_s),
  .awcache_axi_m_3      (awcache_switch2_expmstr0_axim_ib_axi4_s),
  .awprot_axi_m_3       (awprot_switch2_expmstr0_axim_ib_axi4_s),
  .awvalid_axi_m_3      (awvalid_switch2_expmstr0_axim_ib_axi4_s),
  .awvalid_vect_axi_m_3 (),
  .awready_axi_m_3      (awready_switch2_expmstr0_axim_ib_axi4_s),
  .wdata_axi_m_3        (wdata_switch2_expmstr0_axim_ib_axi4_s),
  .wstrb_axi_m_3        (wstrb_switch2_expmstr0_axim_ib_axi4_s),
  .wlast_axi_m_3        (wlast_switch2_expmstr0_axim_ib_axi4_s),
  .wvalid_axi_m_3       (wvalid_switch2_expmstr0_axim_ib_axi4_s),
  .wready_axi_m_3       (wready_switch2_expmstr0_axim_ib_axi4_s),
  .bid_axi_m_3          (bid_switch2_expmstr0_axim_ib_axi4_s),
  .bresp_axi_m_3        (bresp_switch2_expmstr0_axim_ib_axi4_s),
  .bvalid_axi_m_3       (bvalid_switch2_expmstr0_axim_ib_axi4_s),
  .bready_axi_m_3       (bready_switch2_expmstr0_axim_ib_axi4_s),
  .arid_axi_m_3         (arid_switch2_expmstr0_axim_ib_axi4_s),
  .araddr_axi_m_3       (araddr_switch2_expmstr0_axim_ib_axi4_s),
  .arlen_axi_m_3        (arlen_switch2_expmstr0_axim_ib_axi4_s),
  .arsize_axi_m_3       (arsize_switch2_expmstr0_axim_ib_axi4_s),
  .arburst_axi_m_3      (arburst_switch2_expmstr0_axim_ib_axi4_s),
  .arlock_axi_m_3       (arlock_switch2_expmstr0_axim_ib_axi4_s),
  .arcache_axi_m_3      (arcache_switch2_expmstr0_axim_ib_axi4_s),
  .arprot_axi_m_3       (arprot_switch2_expmstr0_axim_ib_axi4_s),
  .arvalid_axi_m_3      (arvalid_switch2_expmstr0_axim_ib_axi4_s),
  .arvalid_vect_axi_m_3 (),
  .arready_axi_m_3      (arready_switch2_expmstr0_axim_ib_axi4_s),
  .rid_axi_m_3          (rid_switch2_expmstr0_axim_ib_axi4_s),
  .rdata_axi_m_3        (rdata_switch2_expmstr0_axim_ib_axi4_s),
  .rresp_axi_m_3        (rresp_switch2_expmstr0_axim_ib_axi4_s),
  .rlast_axi_m_3        (rlast_switch2_expmstr0_axim_ib_axi4_s),
  .rvalid_axi_m_3       (rvalid_switch2_expmstr0_axim_ib_axi4_s),
  .rready_axi_m_3       (rready_switch2_expmstr0_axim_ib_axi4_s),
  .awuser_axi_m_3       (awuser_switch2_expmstr0_axim_ib_axi4_s),
  .buser_axi_m_3        (buser_switch2_expmstr0_axim_ib_axi4_s),
  .aruser_axi_m_3       (aruser_switch2_expmstr0_axim_ib_axi4_s),
  .ruser_axi_m_3        (ruser_switch2_expmstr0_axim_ib_axi4_s),
  .aw_qv_axi_m_3        (awqv_switch2_expmstr0_axim_ib_axi4_s),
  .ar_qv_axi_m_3        (arqv_switch2_expmstr0_axim_ib_axi4_s),
  .awid_axi_m_4         (awid_switch2_expmstr1_axim_ib_axi4_s),
  .awaddr_axi_m_4       (awaddr_switch2_expmstr1_axim_ib_axi4_s),
  .awlen_axi_m_4        (awlen_switch2_expmstr1_axim_ib_axi4_s),
  .awsize_axi_m_4       (awsize_switch2_expmstr1_axim_ib_axi4_s),
  .awburst_axi_m_4      (awburst_switch2_expmstr1_axim_ib_axi4_s),
  .awlock_axi_m_4       (awlock_switch2_expmstr1_axim_ib_axi4_s),
  .awcache_axi_m_4      (awcache_switch2_expmstr1_axim_ib_axi4_s),
  .awprot_axi_m_4       (awprot_switch2_expmstr1_axim_ib_axi4_s),
  .awvalid_axi_m_4      (awvalid_switch2_expmstr1_axim_ib_axi4_s),
  .awvalid_vect_axi_m_4 (),
  .awready_axi_m_4      (awready_switch2_expmstr1_axim_ib_axi4_s),
  .wdata_axi_m_4        (wdata_switch2_expmstr1_axim_ib_axi4_s),
  .wstrb_axi_m_4        (wstrb_switch2_expmstr1_axim_ib_axi4_s),
  .wlast_axi_m_4        (wlast_switch2_expmstr1_axim_ib_axi4_s),
  .wvalid_axi_m_4       (wvalid_switch2_expmstr1_axim_ib_axi4_s),
  .wready_axi_m_4       (wready_switch2_expmstr1_axim_ib_axi4_s),
  .bid_axi_m_4          (bid_switch2_expmstr1_axim_ib_axi4_s),
  .bresp_axi_m_4        (bresp_switch2_expmstr1_axim_ib_axi4_s),
  .bvalid_axi_m_4       (bvalid_switch2_expmstr1_axim_ib_axi4_s),
  .bready_axi_m_4       (bready_switch2_expmstr1_axim_ib_axi4_s),
  .arid_axi_m_4         (arid_switch2_expmstr1_axim_ib_axi4_s),
  .araddr_axi_m_4       (araddr_switch2_expmstr1_axim_ib_axi4_s),
  .arlen_axi_m_4        (arlen_switch2_expmstr1_axim_ib_axi4_s),
  .arsize_axi_m_4       (arsize_switch2_expmstr1_axim_ib_axi4_s),
  .arburst_axi_m_4      (arburst_switch2_expmstr1_axim_ib_axi4_s),
  .arlock_axi_m_4       (arlock_switch2_expmstr1_axim_ib_axi4_s),
  .arcache_axi_m_4      (arcache_switch2_expmstr1_axim_ib_axi4_s),
  .arprot_axi_m_4       (arprot_switch2_expmstr1_axim_ib_axi4_s),
  .arvalid_axi_m_4      (arvalid_switch2_expmstr1_axim_ib_axi4_s),
  .arvalid_vect_axi_m_4 (),
  .arready_axi_m_4      (arready_switch2_expmstr1_axim_ib_axi4_s),
  .rid_axi_m_4          (rid_switch2_expmstr1_axim_ib_axi4_s),
  .rdata_axi_m_4        (rdata_switch2_expmstr1_axim_ib_axi4_s),
  .rresp_axi_m_4        (rresp_switch2_expmstr1_axim_ib_axi4_s),
  .rlast_axi_m_4        (rlast_switch2_expmstr1_axim_ib_axi4_s),
  .rvalid_axi_m_4       (rvalid_switch2_expmstr1_axim_ib_axi4_s),
  .rready_axi_m_4       (rready_switch2_expmstr1_axim_ib_axi4_s),
  .awuser_axi_m_4       (awuser_switch2_expmstr1_axim_ib_axi4_s),
  .buser_axi_m_4        (buser_switch2_expmstr1_axim_ib_axi4_s),
  .aruser_axi_m_4       (aruser_switch2_expmstr1_axim_ib_axi4_s),
  .ruser_axi_m_4        (ruser_switch2_expmstr1_axim_ib_axi4_s),
  .aw_qv_axi_m_4        (awqv_switch2_expmstr1_axim_ib_axi4_s),
  .ar_qv_axi_m_4        (arqv_switch2_expmstr1_axim_ib_axi4_s),
  .awid_axi_m_5         (awid_switch2_ocvm_axim_ib_axi4_s),
  .awaddr_axi_m_5       (awaddr_switch2_ocvm_axim_ib_axi4_s),
  .awlen_axi_m_5        (awlen_switch2_ocvm_axim_ib_axi4_s),
  .awsize_axi_m_5       (awsize_switch2_ocvm_axim_ib_axi4_s),
  .awburst_axi_m_5      (awburst_switch2_ocvm_axim_ib_axi4_s),
  .awlock_axi_m_5       (awlock_switch2_ocvm_axim_ib_axi4_s),
  .awcache_axi_m_5      (awcache_switch2_ocvm_axim_ib_axi4_s),
  .awprot_axi_m_5       (awprot_switch2_ocvm_axim_ib_axi4_s),
  .awvalid_axi_m_5      (awvalid_switch2_ocvm_axim_ib_axi4_s),
  .awvalid_vect_axi_m_5 (),
  .awready_axi_m_5      (awready_switch2_ocvm_axim_ib_axi4_s),
  .wdata_axi_m_5        (wdata_switch2_ocvm_axim_ib_axi4_s),
  .wstrb_axi_m_5        (wstrb_switch2_ocvm_axim_ib_axi4_s),
  .wlast_axi_m_5        (wlast_switch2_ocvm_axim_ib_axi4_s),
  .wvalid_axi_m_5       (wvalid_switch2_ocvm_axim_ib_axi4_s),
  .wready_axi_m_5       (wready_switch2_ocvm_axim_ib_axi4_s),
  .bid_axi_m_5          (bid_switch2_ocvm_axim_ib_axi4_s),
  .bresp_axi_m_5        (bresp_switch2_ocvm_axim_ib_axi4_s),
  .bvalid_axi_m_5       (bvalid_switch2_ocvm_axim_ib_axi4_s),
  .bready_axi_m_5       (bready_switch2_ocvm_axim_ib_axi4_s),
  .arid_axi_m_5         (arid_switch2_ocvm_axim_ib_axi4_s),
  .araddr_axi_m_5       (araddr_switch2_ocvm_axim_ib_axi4_s),
  .arlen_axi_m_5        (arlen_switch2_ocvm_axim_ib_axi4_s),
  .arsize_axi_m_5       (arsize_switch2_ocvm_axim_ib_axi4_s),
  .arburst_axi_m_5      (arburst_switch2_ocvm_axim_ib_axi4_s),
  .arlock_axi_m_5       (arlock_switch2_ocvm_axim_ib_axi4_s),
  .arcache_axi_m_5      (arcache_switch2_ocvm_axim_ib_axi4_s),
  .arprot_axi_m_5       (arprot_switch2_ocvm_axim_ib_axi4_s),
  .arvalid_axi_m_5      (arvalid_switch2_ocvm_axim_ib_axi4_s),
  .arvalid_vect_axi_m_5 (),
  .arready_axi_m_5      (arready_switch2_ocvm_axim_ib_axi4_s),
  .rid_axi_m_5          (rid_switch2_ocvm_axim_ib_axi4_s),
  .rdata_axi_m_5        (rdata_switch2_ocvm_axim_ib_axi4_s),
  .rresp_axi_m_5        (rresp_switch2_ocvm_axim_ib_axi4_s),
  .rlast_axi_m_5        (rlast_switch2_ocvm_axim_ib_axi4_s),
  .rvalid_axi_m_5       (rvalid_switch2_ocvm_axim_ib_axi4_s),
  .rready_axi_m_5       (rready_switch2_ocvm_axim_ib_axi4_s),
  .awuser_axi_m_5       (awuser_switch2_ocvm_axim_ib_axi4_s),
  .buser_axi_m_5        (buser_switch2_ocvm_axim_ib_axi4_s),
  .aruser_axi_m_5       (aruser_switch2_ocvm_axim_ib_axi4_s),
  .ruser_axi_m_5        (ruser_switch2_ocvm_axim_ib_axi4_s),
  .aw_qv_axi_m_5        (awqv_switch2_ocvm_axim_ib_axi4_s),
  .ar_qv_axi_m_5        (arqv_switch2_ocvm_axim_ib_axi4_s),
  .awid_axi_m_6         (awid_switch2_ib4_axi_s_0),
  .awaddr_axi_m_6       (awaddr_switch2_ib4_axi_s_0),
  .awlen_axi_m_6        (awlen_switch2_ib4_axi_s_0),
  .awsize_axi_m_6       (awsize_switch2_ib4_axi_s_0),
  .awburst_axi_m_6      (awburst_switch2_ib4_axi_s_0),
  .awlock_axi_m_6       (awlock_switch2_ib4_axi_s_0),
  .awcache_axi_m_6      (awcache_switch2_ib4_axi_s_0),
  .awprot_axi_m_6       (awprot_switch2_ib4_axi_s_0),
  .awvalid_axi_m_6      (awvalid_switch2_ib4_axi_s_0),
  .awvalid_vect_axi_m_6 (awvalid_vect_switch2_ib4_axi_s_0),
  .awready_axi_m_6      (awready_switch2_ib4_axi_s_0),
  .wdata_axi_m_6        (wdata_switch2_ib4_axi_s_0),
  .wstrb_axi_m_6        (wstrb_switch2_ib4_axi_s_0),
  .wlast_axi_m_6        (wlast_switch2_ib4_axi_s_0),
  .wvalid_axi_m_6       (wvalid_switch2_ib4_axi_s_0),
  .wready_axi_m_6       (wready_switch2_ib4_axi_s_0),
  .bid_axi_m_6          (bid_switch2_ib4_axi_s_0),
  .bresp_axi_m_6        (bresp_switch2_ib4_axi_s_0),
  .bvalid_axi_m_6       (bvalid_switch2_ib4_axi_s_0),
  .bready_axi_m_6       (bready_switch2_ib4_axi_s_0),
  .arid_axi_m_6         (arid_switch2_ib4_axi_s_0),
  .araddr_axi_m_6       (araddr_switch2_ib4_axi_s_0),
  .arlen_axi_m_6        (arlen_switch2_ib4_axi_s_0),
  .arsize_axi_m_6       (arsize_switch2_ib4_axi_s_0),
  .arburst_axi_m_6      (arburst_switch2_ib4_axi_s_0),
  .arlock_axi_m_6       (arlock_switch2_ib4_axi_s_0),
  .arcache_axi_m_6      (arcache_switch2_ib4_axi_s_0),
  .arprot_axi_m_6       (arprot_switch2_ib4_axi_s_0),
  .arvalid_axi_m_6      (arvalid_switch2_ib4_axi_s_0),
  .arvalid_vect_axi_m_6 (arvalid_vect_switch2_ib4_axi_s_0),
  .arready_axi_m_6      (arready_switch2_ib4_axi_s_0),
  .rid_axi_m_6          (rid_switch2_ib4_axi_s_0),
  .rdata_axi_m_6        (rdata_switch2_ib4_axi_s_0),
  .rresp_axi_m_6        (rresp_switch2_ib4_axi_s_0),
  .rlast_axi_m_6        (rlast_switch2_ib4_axi_s_0),
  .rvalid_axi_m_6       (rvalid_switch2_ib4_axi_s_0),
  .rready_axi_m_6       (rready_switch2_ib4_axi_s_0),
  .awuser_axi_m_6       (awuser_switch2_ib4_axi_s_0),
  .buser_axi_m_6        (buser_switch2_ib4_axi_s_0),
  .aruser_axi_m_6       (aruser_switch2_ib4_axi_s_0),
  .ruser_axi_m_6        (ruser_switch2_ib4_axi_s_0),
  .aw_qv_axi_m_6        (awqv_switch2_ib4_axi_s_0),
  .ar_qv_axi_m_6        (arqv_switch2_ib4_axi_s_0),
  .awid_axi_m_8         (awid_switch2_ds_1_axi_s_0),
  .awaddr_axi_m_8       (),
  .awlen_axi_m_8        (),
  .awsize_axi_m_8       (),
  .awburst_axi_m_8      (),
  .awlock_axi_m_8       (),
  .awcache_axi_m_8      (),
  .awprot_axi_m_8       (),
  .awvalid_axi_m_8      (awvalid_switch2_ds_1_axi_s_0),
  .awvalid_vect_axi_m_8 (),
  .awready_axi_m_8      (awready_switch2_ds_1_axi_s_0),
  .wdata_axi_m_8        (),
  .wstrb_axi_m_8        (),
  .wlast_axi_m_8        (wlast_switch2_ds_1_axi_s_0),
  .wvalid_axi_m_8       (wvalid_switch2_ds_1_axi_s_0),
  .wready_axi_m_8       (wready_switch2_ds_1_axi_s_0),
  .bid_axi_m_8          (bid_switch2_ds_1_axi_s_0),
  .bresp_axi_m_8        (bresp_switch2_ds_1_axi_s_0),
  .bvalid_axi_m_8       (bvalid_switch2_ds_1_axi_s_0),
  .bready_axi_m_8       (bready_switch2_ds_1_axi_s_0),
  .arid_axi_m_8         (arid_switch2_ds_1_axi_s_0),
  .araddr_axi_m_8       (),
  .arlen_axi_m_8        (arlen_switch2_ds_1_axi_s_0),
  .arsize_axi_m_8       (),
  .arburst_axi_m_8      (),
  .arlock_axi_m_8       (),
  .arcache_axi_m_8      (),
  .arprot_axi_m_8       (),
  .arvalid_axi_m_8      (arvalid_switch2_ds_1_axi_s_0),
  .arvalid_vect_axi_m_8 (),
  .arready_axi_m_8      (arready_switch2_ds_1_axi_s_0),
  .rid_axi_m_8          (rid_switch2_ds_1_axi_s_0),
  .rdata_axi_m_8        (64'b0),
  .rresp_axi_m_8        (rresp_switch2_ds_1_axi_s_0),
  .rlast_axi_m_8        (rlast_switch2_ds_1_axi_s_0),
  .rvalid_axi_m_8       (rvalid_switch2_ds_1_axi_s_0),
  .rready_axi_m_8       (rready_switch2_ds_1_axi_s_0),
  .awuser_axi_m_8       (),
  .buser_axi_m_8        (1'b0),
  .aruser_axi_m_8       (),
  .ruser_axi_m_8        (1'b0),
  .aw_qv_axi_m_8        (),
  .ar_qv_axi_m_8        (),
  .awid_axi_s_0         (awid_extsys0_axis_ib_switch2_axi_s_0),
  .awaddr_axi_s_0       (awaddr_extsys0_axis_ib_switch2_axi_s_0),
  .awlen_axi_s_0        (awlen_extsys0_axis_ib_switch2_axi_s_0),
  .awsize_axi_s_0       (awsize_extsys0_axis_ib_switch2_axi_s_0),
  .awburst_axi_s_0      (awburst_extsys0_axis_ib_switch2_axi_s_0),
  .awlock_axi_s_0       (awlock_extsys0_axis_ib_switch2_axi_s_0),
  .awcache_axi_s_0      (awcache_extsys0_axis_ib_switch2_axi_s_0),
  .awprot_axi_s_0       (awprot_extsys0_axis_ib_switch2_axi_s_0),
  .awvalid_axi_s_0      (awvalid_extsys0_axis_ib_switch2_axi_s_0),
  .awvalid_vect_axi_s_0 (awvalid_vect_extsys0_axis_ib_switch2_axi_s_0),
  .awready_axi_s_0      (awready_extsys0_axis_ib_switch2_axi_s_0),
  .wdata_axi_s_0        (wdata_extsys0_axis_ib_switch2_axi_s_0),
  .wstrb_axi_s_0        (wstrb_extsys0_axis_ib_switch2_axi_s_0),
  .wlast_axi_s_0        (wlast_extsys0_axis_ib_switch2_axi_s_0),
  .wvalid_axi_s_0       (wvalid_extsys0_axis_ib_switch2_axi_s_0),
  .wready_axi_s_0       (wready_extsys0_axis_ib_switch2_axi_s_0),
  .bid_axi_s_0          (bid_extsys0_axis_ib_switch2_axi_s_0),
  .bresp_axi_s_0        (bresp_extsys0_axis_ib_switch2_axi_s_0),
  .bvalid_axi_s_0       (bvalid_extsys0_axis_ib_switch2_axi_s_0),
  .bready_axi_s_0       (bready_extsys0_axis_ib_switch2_axi_s_0),
  .arid_axi_s_0         (arid_extsys0_axis_ib_switch2_axi_s_0),
  .araddr_axi_s_0       (araddr_extsys0_axis_ib_switch2_axi_s_0),
  .arlen_axi_s_0        (arlen_extsys0_axis_ib_switch2_axi_s_0),
  .arsize_axi_s_0       (arsize_extsys0_axis_ib_switch2_axi_s_0),
  .arburst_axi_s_0      (arburst_extsys0_axis_ib_switch2_axi_s_0),
  .arlock_axi_s_0       (arlock_extsys0_axis_ib_switch2_axi_s_0),
  .arcache_axi_s_0      (arcache_extsys0_axis_ib_switch2_axi_s_0),
  .arprot_axi_s_0       (arprot_extsys0_axis_ib_switch2_axi_s_0),
  .arvalid_axi_s_0      (arvalid_extsys0_axis_ib_switch2_axi_s_0),
  .arvalid_vect_axi_s_0 (arvalid_vect_extsys0_axis_ib_switch2_axi_s_0),
  .arready_axi_s_0      (arready_extsys0_axis_ib_switch2_axi_s_0),
  .rid_axi_s_0          (rid_extsys0_axis_ib_switch2_axi_s_0),
  .rdata_axi_s_0        (rdata_extsys0_axis_ib_switch2_axi_s_0),
  .rresp_axi_s_0        (rresp_extsys0_axis_ib_switch2_axi_s_0),
  .rlast_axi_s_0        (rlast_extsys0_axis_ib_switch2_axi_s_0),
  .rvalid_axi_s_0       (rvalid_extsys0_axis_ib_switch2_axi_s_0),
  .rready_axi_s_0       (rready_extsys0_axis_ib_switch2_axi_s_0),
  .awuser_axi_s_0       (awuser_extsys0_axis_ib_switch2_axi_s_0),
  .buser_axi_s_0        (buser_extsys0_axis_ib_switch2_axi_s_0),
  .aruser_axi_s_0       (aruser_extsys0_axis_ib_switch2_axi_s_0),
  .ruser_axi_s_0        (ruser_extsys0_axis_ib_switch2_axi_s_0),
  .aw_qv_axi_s_0        (awqv_extsys0_axis_ib_switch2_axi_s_0),
  .ar_qv_axi_s_0        (arqv_extsys0_axis_ib_switch2_axi_s_0),
  .awid_axi_s_1         (awid_hostcpu_axis_ib_switch2_axi_s_1),
  .awaddr_axi_s_1       (awaddr_hostcpu_axis_ib_switch2_axi_s_1),
  .awlen_axi_s_1        (awlen_hostcpu_axis_ib_switch2_axi_s_1),
  .awsize_axi_s_1       (awsize_hostcpu_axis_ib_switch2_axi_s_1),
  .awburst_axi_s_1      (awburst_hostcpu_axis_ib_switch2_axi_s_1),
  .awlock_axi_s_1       (awlock_hostcpu_axis_ib_switch2_axi_s_1),
  .awcache_axi_s_1      (awcache_hostcpu_axis_ib_switch2_axi_s_1),
  .awprot_axi_s_1       (awprot_hostcpu_axis_ib_switch2_axi_s_1),
  .awvalid_axi_s_1      (awvalid_hostcpu_axis_ib_switch2_axi_s_1),
  .awvalid_vect_axi_s_1 (awvalid_vect_hostcpu_axis_ib_switch2_axi_s_1),
  .awready_axi_s_1      (awready_hostcpu_axis_ib_switch2_axi_s_1),
  .wdata_axi_s_1        (wdata_hostcpu_axis_ib_switch2_axi_s_1),
  .wstrb_axi_s_1        (wstrb_hostcpu_axis_ib_switch2_axi_s_1),
  .wlast_axi_s_1        (wlast_hostcpu_axis_ib_switch2_axi_s_1),
  .wvalid_axi_s_1       (wvalid_hostcpu_axis_ib_switch2_axi_s_1),
  .wready_axi_s_1       (wready_hostcpu_axis_ib_switch2_axi_s_1),
  .bid_axi_s_1          (bid_hostcpu_axis_ib_switch2_axi_s_1),
  .bresp_axi_s_1        (bresp_hostcpu_axis_ib_switch2_axi_s_1),
  .bvalid_axi_s_1       (bvalid_hostcpu_axis_ib_switch2_axi_s_1),
  .bready_axi_s_1       (bready_hostcpu_axis_ib_switch2_axi_s_1),
  .arid_axi_s_1         (arid_hostcpu_axis_ib_switch2_axi_s_1),
  .araddr_axi_s_1       (araddr_hostcpu_axis_ib_switch2_axi_s_1),
  .arlen_axi_s_1        (arlen_hostcpu_axis_ib_switch2_axi_s_1),
  .arsize_axi_s_1       (arsize_hostcpu_axis_ib_switch2_axi_s_1),
  .arburst_axi_s_1      (arburst_hostcpu_axis_ib_switch2_axi_s_1),
  .arlock_axi_s_1       (arlock_hostcpu_axis_ib_switch2_axi_s_1),
  .arcache_axi_s_1      (arcache_hostcpu_axis_ib_switch2_axi_s_1),
  .arprot_axi_s_1       (arprot_hostcpu_axis_ib_switch2_axi_s_1),
  .arvalid_axi_s_1      (arvalid_hostcpu_axis_ib_switch2_axi_s_1),
  .arvalid_vect_axi_s_1 (arvalid_vect_hostcpu_axis_ib_switch2_axi_s_1),
  .arready_axi_s_1      (arready_hostcpu_axis_ib_switch2_axi_s_1),
  .rid_axi_s_1          (rid_hostcpu_axis_ib_switch2_axi_s_1),
  .rdata_axi_s_1        (rdata_hostcpu_axis_ib_switch2_axi_s_1),
  .rresp_axi_s_1        (rresp_hostcpu_axis_ib_switch2_axi_s_1),
  .rlast_axi_s_1        (rlast_hostcpu_axis_ib_switch2_axi_s_1),
  .rvalid_axi_s_1       (rvalid_hostcpu_axis_ib_switch2_axi_s_1),
  .rready_axi_s_1       (rready_hostcpu_axis_ib_switch2_axi_s_1),
  .awuser_axi_s_1       (awuser_hostcpu_axis_ib_switch2_axi_s_1),
  .buser_axi_s_1        (buser_hostcpu_axis_ib_switch2_axi_s_1),
  .aruser_axi_s_1       (aruser_hostcpu_axis_ib_switch2_axi_s_1),
  .ruser_axi_s_1        (ruser_hostcpu_axis_ib_switch2_axi_s_1),
  .aw_qv_axi_s_1        (awqv_hostcpu_axis_ib_switch2_axi_s_1),
  .ar_qv_axi_s_1        (arqv_hostcpu_axis_ib_switch2_axi_s_1),
  .awid_axi_s_2         (awid_extsys1_axis_ib_switch2_axi_s_2),
  .awaddr_axi_s_2       (awaddr_extsys1_axis_ib_switch2_axi_s_2),
  .awlen_axi_s_2        (awlen_extsys1_axis_ib_switch2_axi_s_2),
  .awsize_axi_s_2       (awsize_extsys1_axis_ib_switch2_axi_s_2),
  .awburst_axi_s_2      (awburst_extsys1_axis_ib_switch2_axi_s_2),
  .awlock_axi_s_2       (awlock_extsys1_axis_ib_switch2_axi_s_2),
  .awcache_axi_s_2      (awcache_extsys1_axis_ib_switch2_axi_s_2),
  .awprot_axi_s_2       (awprot_extsys1_axis_ib_switch2_axi_s_2),
  .awvalid_axi_s_2      (awvalid_extsys1_axis_ib_switch2_axi_s_2),
  .awvalid_vect_axi_s_2 (awvalid_vect_extsys1_axis_ib_switch2_axi_s_2),
  .awready_axi_s_2      (awready_extsys1_axis_ib_switch2_axi_s_2),
  .wdata_axi_s_2        (wdata_extsys1_axis_ib_switch2_axi_s_2),
  .wstrb_axi_s_2        (wstrb_extsys1_axis_ib_switch2_axi_s_2),
  .wlast_axi_s_2        (wlast_extsys1_axis_ib_switch2_axi_s_2),
  .wvalid_axi_s_2       (wvalid_extsys1_axis_ib_switch2_axi_s_2),
  .wready_axi_s_2       (wready_extsys1_axis_ib_switch2_axi_s_2),
  .bid_axi_s_2          (bid_extsys1_axis_ib_switch2_axi_s_2),
  .bresp_axi_s_2        (bresp_extsys1_axis_ib_switch2_axi_s_2),
  .bvalid_axi_s_2       (bvalid_extsys1_axis_ib_switch2_axi_s_2),
  .bready_axi_s_2       (bready_extsys1_axis_ib_switch2_axi_s_2),
  .arid_axi_s_2         (arid_extsys1_axis_ib_switch2_axi_s_2),
  .araddr_axi_s_2       (araddr_extsys1_axis_ib_switch2_axi_s_2),
  .arlen_axi_s_2        (arlen_extsys1_axis_ib_switch2_axi_s_2),
  .arsize_axi_s_2       (arsize_extsys1_axis_ib_switch2_axi_s_2),
  .arburst_axi_s_2      (arburst_extsys1_axis_ib_switch2_axi_s_2),
  .arlock_axi_s_2       (arlock_extsys1_axis_ib_switch2_axi_s_2),
  .arcache_axi_s_2      (arcache_extsys1_axis_ib_switch2_axi_s_2),
  .arprot_axi_s_2       (arprot_extsys1_axis_ib_switch2_axi_s_2),
  .arvalid_axi_s_2      (arvalid_extsys1_axis_ib_switch2_axi_s_2),
  .arvalid_vect_axi_s_2 (arvalid_vect_extsys1_axis_ib_switch2_axi_s_2),
  .arready_axi_s_2      (arready_extsys1_axis_ib_switch2_axi_s_2),
  .rid_axi_s_2          (rid_extsys1_axis_ib_switch2_axi_s_2),
  .rdata_axi_s_2        (rdata_extsys1_axis_ib_switch2_axi_s_2),
  .rresp_axi_s_2        (rresp_extsys1_axis_ib_switch2_axi_s_2),
  .rlast_axi_s_2        (rlast_extsys1_axis_ib_switch2_axi_s_2),
  .rvalid_axi_s_2       (rvalid_extsys1_axis_ib_switch2_axi_s_2),
  .rready_axi_s_2       (rready_extsys1_axis_ib_switch2_axi_s_2),
  .awuser_axi_s_2       (awuser_extsys1_axis_ib_switch2_axi_s_2),
  .buser_axi_s_2        (buser_extsys1_axis_ib_switch2_axi_s_2),
  .aruser_axi_s_2       (aruser_extsys1_axis_ib_switch2_axi_s_2),
  .ruser_axi_s_2        (ruser_extsys1_axis_ib_switch2_axi_s_2),
  .aw_qv_axi_s_2        (awqv_extsys1_axis_ib_switch2_axi_s_2),
  .ar_qv_axi_s_2        (arqv_extsys1_axis_ib_switch2_axi_s_2),
  .awid_axi_s_3         (awid_ib1_switch2_axi_s_3),
  .awaddr_axi_s_3       (awaddr_ib1_switch2_axi_s_3),
  .awlen_axi_s_3        (awlen_ib1_switch2_axi_s_3),
  .awsize_axi_s_3       (awsize_ib1_switch2_axi_s_3),
  .awburst_axi_s_3      (awburst_ib1_switch2_axi_s_3),
  .awlock_axi_s_3       (awlock_ib1_switch2_axi_s_3),
  .awcache_axi_s_3      (awcache_ib1_switch2_axi_s_3),
  .awprot_axi_s_3       (awprot_ib1_switch2_axi_s_3),
  .awvalid_axi_s_3      (awvalid_ib1_switch2_axi_s_3),
  .awvalid_vect_axi_s_3 (awvalid_vect_ib1_switch2_axi_s_3),
  .awready_axi_s_3      (awready_ib1_switch2_axi_s_3),
  .wdata_axi_s_3        (wdata_ib1_switch2_axi_s_3),
  .wstrb_axi_s_3        (wstrb_ib1_switch2_axi_s_3),
  .wlast_axi_s_3        (wlast_ib1_switch2_axi_s_3),
  .wvalid_axi_s_3       (wvalid_ib1_switch2_axi_s_3),
  .wready_axi_s_3       (wready_ib1_switch2_axi_s_3),
  .bid_axi_s_3          (bid_ib1_switch2_axi_s_3),
  .bresp_axi_s_3        (bresp_ib1_switch2_axi_s_3),
  .bvalid_axi_s_3       (bvalid_ib1_switch2_axi_s_3),
  .bready_axi_s_3       (bready_ib1_switch2_axi_s_3),
  .arid_axi_s_3         (arid_ib1_switch2_axi_s_3),
  .araddr_axi_s_3       (araddr_ib1_switch2_axi_s_3),
  .arlen_axi_s_3        (arlen_ib1_switch2_axi_s_3),
  .arsize_axi_s_3       (arsize_ib1_switch2_axi_s_3),
  .arburst_axi_s_3      (arburst_ib1_switch2_axi_s_3),
  .arlock_axi_s_3       (arlock_ib1_switch2_axi_s_3),
  .arcache_axi_s_3      (arcache_ib1_switch2_axi_s_3),
  .arprot_axi_s_3       (arprot_ib1_switch2_axi_s_3),
  .arvalid_axi_s_3      (arvalid_ib1_switch2_axi_s_3),
  .arvalid_vect_axi_s_3 (arvalid_vect_ib1_switch2_axi_s_3),
  .arready_axi_s_3      (arready_ib1_switch2_axi_s_3),
  .rid_axi_s_3          (rid_ib1_switch2_axi_s_3),
  .rdata_axi_s_3        (rdata_ib1_switch2_axi_s_3),
  .rresp_axi_s_3        (rresp_ib1_switch2_axi_s_3),
  .rlast_axi_s_3        (rlast_ib1_switch2_axi_s_3),
  .rvalid_axi_s_3       (rvalid_ib1_switch2_axi_s_3),
  .rready_axi_s_3       (rready_ib1_switch2_axi_s_3),
  .awuser_axi_s_3       (awuser_ib1_switch2_axi_s_3),
  .buser_axi_s_3        (buser_ib1_switch2_axi_s_3),
  .aruser_axi_s_3       (aruser_ib1_switch2_axi_s_3),
  .ruser_axi_s_3        (ruser_ib1_switch2_axi_s_3),
  .aw_qv_axi_s_3        (awqv_ib1_switch2_axi_s_3),
  .ar_qv_axi_s_3        (arqv_ib1_switch2_axi_s_3),
  .awid_axi_s_4         (awid_expslv0_axis_ib_switch2_axi_s_4),
  .awaddr_axi_s_4       (awaddr_expslv0_axis_ib_switch2_axi_s_4),
  .awlen_axi_s_4        (awlen_expslv0_axis_ib_switch2_axi_s_4),
  .awsize_axi_s_4       (awsize_expslv0_axis_ib_switch2_axi_s_4),
  .awburst_axi_s_4      (awburst_expslv0_axis_ib_switch2_axi_s_4),
  .awlock_axi_s_4       (awlock_expslv0_axis_ib_switch2_axi_s_4),
  .awcache_axi_s_4      (awcache_expslv0_axis_ib_switch2_axi_s_4),
  .awprot_axi_s_4       (awprot_expslv0_axis_ib_switch2_axi_s_4),
  .awvalid_axi_s_4      (awvalid_expslv0_axis_ib_switch2_axi_s_4),
  .awvalid_vect_axi_s_4 (awvalid_vect_expslv0_axis_ib_switch2_axi_s_4),
  .awready_axi_s_4      (awready_expslv0_axis_ib_switch2_axi_s_4),
  .wdata_axi_s_4        (wdata_expslv0_axis_ib_switch2_axi_s_4),
  .wstrb_axi_s_4        (wstrb_expslv0_axis_ib_switch2_axi_s_4),
  .wlast_axi_s_4        (wlast_expslv0_axis_ib_switch2_axi_s_4),
  .wvalid_axi_s_4       (wvalid_expslv0_axis_ib_switch2_axi_s_4),
  .wready_axi_s_4       (wready_expslv0_axis_ib_switch2_axi_s_4),
  .bid_axi_s_4          (bid_expslv0_axis_ib_switch2_axi_s_4),
  .bresp_axi_s_4        (bresp_expslv0_axis_ib_switch2_axi_s_4),
  .bvalid_axi_s_4       (bvalid_expslv0_axis_ib_switch2_axi_s_4),
  .bready_axi_s_4       (bready_expslv0_axis_ib_switch2_axi_s_4),
  .arid_axi_s_4         (arid_expslv0_axis_ib_switch2_axi_s_4),
  .araddr_axi_s_4       (araddr_expslv0_axis_ib_switch2_axi_s_4),
  .arlen_axi_s_4        (arlen_expslv0_axis_ib_switch2_axi_s_4),
  .arsize_axi_s_4       (arsize_expslv0_axis_ib_switch2_axi_s_4),
  .arburst_axi_s_4      (arburst_expslv0_axis_ib_switch2_axi_s_4),
  .arlock_axi_s_4       (arlock_expslv0_axis_ib_switch2_axi_s_4),
  .arcache_axi_s_4      (arcache_expslv0_axis_ib_switch2_axi_s_4),
  .arprot_axi_s_4       (arprot_expslv0_axis_ib_switch2_axi_s_4),
  .arvalid_axi_s_4      (arvalid_expslv0_axis_ib_switch2_axi_s_4),
  .arvalid_vect_axi_s_4 (arvalid_vect_expslv0_axis_ib_switch2_axi_s_4),
  .arready_axi_s_4      (arready_expslv0_axis_ib_switch2_axi_s_4),
  .rid_axi_s_4          (rid_expslv0_axis_ib_switch2_axi_s_4),
  .rdata_axi_s_4        (rdata_expslv0_axis_ib_switch2_axi_s_4),
  .rresp_axi_s_4        (rresp_expslv0_axis_ib_switch2_axi_s_4),
  .rlast_axi_s_4        (rlast_expslv0_axis_ib_switch2_axi_s_4),
  .rvalid_axi_s_4       (rvalid_expslv0_axis_ib_switch2_axi_s_4),
  .rready_axi_s_4       (rready_expslv0_axis_ib_switch2_axi_s_4),
  .awuser_axi_s_4       (awuser_expslv0_axis_ib_switch2_axi_s_4),
  .buser_axi_s_4        (buser_expslv0_axis_ib_switch2_axi_s_4),
  .aruser_axi_s_4       (aruser_expslv0_axis_ib_switch2_axi_s_4),
  .ruser_axi_s_4        (ruser_expslv0_axis_ib_switch2_axi_s_4),
  .aw_qv_axi_s_4        (awqv_expslv0_axis_ib_switch2_axi_s_4),
  .ar_qv_axi_s_4        (arqv_expslv0_axis_ib_switch2_axi_s_4),
  .awid_axi_s_5         (awid_expslv1_axis_ib_switch2_axi_s_5),
  .awaddr_axi_s_5       (awaddr_expslv1_axis_ib_switch2_axi_s_5),
  .awlen_axi_s_5        (awlen_expslv1_axis_ib_switch2_axi_s_5),
  .awsize_axi_s_5       (awsize_expslv1_axis_ib_switch2_axi_s_5),
  .awburst_axi_s_5      (awburst_expslv1_axis_ib_switch2_axi_s_5),
  .awlock_axi_s_5       (awlock_expslv1_axis_ib_switch2_axi_s_5),
  .awcache_axi_s_5      (awcache_expslv1_axis_ib_switch2_axi_s_5),
  .awprot_axi_s_5       (awprot_expslv1_axis_ib_switch2_axi_s_5),
  .awvalid_axi_s_5      (awvalid_expslv1_axis_ib_switch2_axi_s_5),
  .awvalid_vect_axi_s_5 (awvalid_vect_expslv1_axis_ib_switch2_axi_s_5),
  .awready_axi_s_5      (awready_expslv1_axis_ib_switch2_axi_s_5),
  .wdata_axi_s_5        (wdata_expslv1_axis_ib_switch2_axi_s_5),
  .wstrb_axi_s_5        (wstrb_expslv1_axis_ib_switch2_axi_s_5),
  .wlast_axi_s_5        (wlast_expslv1_axis_ib_switch2_axi_s_5),
  .wvalid_axi_s_5       (wvalid_expslv1_axis_ib_switch2_axi_s_5),
  .wready_axi_s_5       (wready_expslv1_axis_ib_switch2_axi_s_5),
  .bid_axi_s_5          (bid_expslv1_axis_ib_switch2_axi_s_5),
  .bresp_axi_s_5        (bresp_expslv1_axis_ib_switch2_axi_s_5),
  .bvalid_axi_s_5       (bvalid_expslv1_axis_ib_switch2_axi_s_5),
  .bready_axi_s_5       (bready_expslv1_axis_ib_switch2_axi_s_5),
  .arid_axi_s_5         (arid_expslv1_axis_ib_switch2_axi_s_5),
  .araddr_axi_s_5       (araddr_expslv1_axis_ib_switch2_axi_s_5),
  .arlen_axi_s_5        (arlen_expslv1_axis_ib_switch2_axi_s_5),
  .arsize_axi_s_5       (arsize_expslv1_axis_ib_switch2_axi_s_5),
  .arburst_axi_s_5      (arburst_expslv1_axis_ib_switch2_axi_s_5),
  .arlock_axi_s_5       (arlock_expslv1_axis_ib_switch2_axi_s_5),
  .arcache_axi_s_5      (arcache_expslv1_axis_ib_switch2_axi_s_5),
  .arprot_axi_s_5       (arprot_expslv1_axis_ib_switch2_axi_s_5),
  .arvalid_axi_s_5      (arvalid_expslv1_axis_ib_switch2_axi_s_5),
  .arvalid_vect_axi_s_5 (arvalid_vect_expslv1_axis_ib_switch2_axi_s_5),
  .arready_axi_s_5      (arready_expslv1_axis_ib_switch2_axi_s_5),
  .rid_axi_s_5          (rid_expslv1_axis_ib_switch2_axi_s_5),
  .rdata_axi_s_5        (rdata_expslv1_axis_ib_switch2_axi_s_5),
  .rresp_axi_s_5        (rresp_expslv1_axis_ib_switch2_axi_s_5),
  .rlast_axi_s_5        (rlast_expslv1_axis_ib_switch2_axi_s_5),
  .rvalid_axi_s_5       (rvalid_expslv1_axis_ib_switch2_axi_s_5),
  .rready_axi_s_5       (rready_expslv1_axis_ib_switch2_axi_s_5),
  .awuser_axi_s_5       (awuser_expslv1_axis_ib_switch2_axi_s_5),
  .buser_axi_s_5        (buser_expslv1_axis_ib_switch2_axi_s_5),
  .aruser_axi_s_5       (aruser_expslv1_axis_ib_switch2_axi_s_5),
  .ruser_axi_s_5        (ruser_expslv1_axis_ib_switch2_axi_s_5),
  .aw_qv_axi_s_5        (awqv_expslv1_axis_ib_switch2_axi_s_5),
  .ar_qv_axi_s_5        (arqv_expslv1_axis_ib_switch2_axi_s_5),
  .awid_axi_s_6         (awid_debug_axis_ib_switch2_axi_s_6),
  .awaddr_axi_s_6       (awaddr_debug_axis_ib_switch2_axi_s_6),
  .awlen_axi_s_6        (awlen_debug_axis_ib_switch2_axi_s_6),
  .awsize_axi_s_6       (awsize_debug_axis_ib_switch2_axi_s_6),
  .awburst_axi_s_6      (awburst_debug_axis_ib_switch2_axi_s_6),
  .awlock_axi_s_6       (awlock_debug_axis_ib_switch2_axi_s_6),
  .awcache_axi_s_6      (awcache_debug_axis_ib_switch2_axi_s_6),
  .awprot_axi_s_6       (awprot_debug_axis_ib_switch2_axi_s_6),
  .awvalid_axi_s_6      (awvalid_debug_axis_ib_switch2_axi_s_6),
  .awvalid_vect_axi_s_6 (awvalid_vect_debug_axis_ib_switch2_axi_s_6),
  .awready_axi_s_6      (awready_debug_axis_ib_switch2_axi_s_6),
  .wdata_axi_s_6        (wdata_debug_axis_ib_switch2_axi_s_6),
  .wstrb_axi_s_6        (wstrb_debug_axis_ib_switch2_axi_s_6),
  .wlast_axi_s_6        (wlast_debug_axis_ib_switch2_axi_s_6),
  .wvalid_axi_s_6       (wvalid_debug_axis_ib_switch2_axi_s_6),
  .wready_axi_s_6       (wready_debug_axis_ib_switch2_axi_s_6),
  .bid_axi_s_6          (bid_debug_axis_ib_switch2_axi_s_6),
  .bresp_axi_s_6        (bresp_debug_axis_ib_switch2_axi_s_6),
  .bvalid_axi_s_6       (bvalid_debug_axis_ib_switch2_axi_s_6),
  .bready_axi_s_6       (bready_debug_axis_ib_switch2_axi_s_6),
  .arid_axi_s_6         (arid_debug_axis_ib_switch2_axi_s_6),
  .araddr_axi_s_6       (araddr_debug_axis_ib_switch2_axi_s_6),
  .arlen_axi_s_6        (arlen_debug_axis_ib_switch2_axi_s_6),
  .arsize_axi_s_6       (arsize_debug_axis_ib_switch2_axi_s_6),
  .arburst_axi_s_6      (arburst_debug_axis_ib_switch2_axi_s_6),
  .arlock_axi_s_6       (arlock_debug_axis_ib_switch2_axi_s_6),
  .arcache_axi_s_6      (arcache_debug_axis_ib_switch2_axi_s_6),
  .arprot_axi_s_6       (arprot_debug_axis_ib_switch2_axi_s_6),
  .arvalid_axi_s_6      (arvalid_debug_axis_ib_switch2_axi_s_6),
  .arvalid_vect_axi_s_6 (arvalid_vect_debug_axis_ib_switch2_axi_s_6),
  .arready_axi_s_6      (arready_debug_axis_ib_switch2_axi_s_6),
  .rid_axi_s_6          (rid_debug_axis_ib_switch2_axi_s_6),
  .rdata_axi_s_6        (rdata_debug_axis_ib_switch2_axi_s_6),
  .rresp_axi_s_6        (rresp_debug_axis_ib_switch2_axi_s_6),
  .rlast_axi_s_6        (rlast_debug_axis_ib_switch2_axi_s_6),
  .rvalid_axi_s_6       (rvalid_debug_axis_ib_switch2_axi_s_6),
  .rready_axi_s_6       (rready_debug_axis_ib_switch2_axi_s_6),
  .awuser_axi_s_6       (awuser_debug_axis_ib_switch2_axi_s_6),
  .buser_axi_s_6        (buser_debug_axis_ib_switch2_axi_s_6),
  .aruser_axi_s_6       (aruser_debug_axis_ib_switch2_axi_s_6),
  .ruser_axi_s_6        (ruser_debug_axis_ib_switch2_axi_s_6),
  .aw_qv_axi_s_6        (awqv_debug_axis_ib_switch2_axi_s_6),
  .ar_qv_axi_s_6        (arqv_debug_axis_ib_switch2_axi_s_6),
  .aclk                 (aclk),
  .aresetn              (aresetn)
);


nic400_switch3_sse710_main     u_busmatrix_switch3 (
  .awid_axi_m_0         (awid_switch3_sysperi_axim_sysperi_axim_s),
  .awaddr_axi_m_0       (awaddr_switch3_sysperi_axim_sysperi_axim_s),
  .awlen_axi_m_0        (awlen_switch3_sysperi_axim_sysperi_axim_s),
  .awsize_axi_m_0       (awsize_switch3_sysperi_axim_sysperi_axim_s),
  .awburst_axi_m_0      (awburst_switch3_sysperi_axim_sysperi_axim_s),
  .awlock_axi_m_0       (awlock_switch3_sysperi_axim_sysperi_axim_s),
  .awcache_axi_m_0      (awcache_switch3_sysperi_axim_sysperi_axim_s),
  .awprot_axi_m_0       (awprot_switch3_sysperi_axim_sysperi_axim_s),
  .awvalid_axi_m_0      (awvalid_switch3_sysperi_axim_sysperi_axim_s),
  .awvalid_vect_axi_m_0 (),
  .awready_axi_m_0      (awready_switch3_sysperi_axim_sysperi_axim_s),
  .wdata_axi_m_0        (wdata_switch3_sysperi_axim_sysperi_axim_s),
  .wstrb_axi_m_0        (wstrb_switch3_sysperi_axim_sysperi_axim_s),
  .wlast_axi_m_0        (wlast_switch3_sysperi_axim_sysperi_axim_s),
  .wvalid_axi_m_0       (wvalid_switch3_sysperi_axim_sysperi_axim_s),
  .wready_axi_m_0       (wready_switch3_sysperi_axim_sysperi_axim_s),
  .bid_axi_m_0          (bid_switch3_sysperi_axim_sysperi_axim_s),
  .bresp_axi_m_0        (bresp_switch3_sysperi_axim_sysperi_axim_s),
  .bvalid_axi_m_0       (bvalid_switch3_sysperi_axim_sysperi_axim_s),
  .bready_axi_m_0       (bready_switch3_sysperi_axim_sysperi_axim_s),
  .arid_axi_m_0         (arid_switch3_sysperi_axim_sysperi_axim_s),
  .araddr_axi_m_0       (araddr_switch3_sysperi_axim_sysperi_axim_s),
  .arlen_axi_m_0        (arlen_switch3_sysperi_axim_sysperi_axim_s),
  .arsize_axi_m_0       (arsize_switch3_sysperi_axim_sysperi_axim_s),
  .arburst_axi_m_0      (arburst_switch3_sysperi_axim_sysperi_axim_s),
  .arlock_axi_m_0       (arlock_switch3_sysperi_axim_sysperi_axim_s),
  .arcache_axi_m_0      (arcache_switch3_sysperi_axim_sysperi_axim_s),
  .arprot_axi_m_0       (arprot_switch3_sysperi_axim_sysperi_axim_s),
  .arvalid_axi_m_0      (arvalid_switch3_sysperi_axim_sysperi_axim_s),
  .arvalid_vect_axi_m_0 (),
  .arready_axi_m_0      (arready_switch3_sysperi_axim_sysperi_axim_s),
  .rid_axi_m_0          (rid_switch3_sysperi_axim_sysperi_axim_s),
  .rdata_axi_m_0        (rdata_switch3_sysperi_axim_sysperi_axim_s),
  .rresp_axi_m_0        (rresp_switch3_sysperi_axim_sysperi_axim_s),
  .rlast_axi_m_0        (rlast_switch3_sysperi_axim_sysperi_axim_s),
  .rvalid_axi_m_0       (rvalid_switch3_sysperi_axim_sysperi_axim_s),
  .rready_axi_m_0       (rready_switch3_sysperi_axim_sysperi_axim_s),
  .awuser_axi_m_0       (awuser_switch3_sysperi_axim_sysperi_axim_s),
  .buser_axi_m_0        (buser_switch3_sysperi_axim_sysperi_axim_s),
  .aruser_axi_m_0       (aruser_switch3_sysperi_axim_sysperi_axim_s),
  .ruser_axi_m_0        (ruser_switch3_sysperi_axim_sysperi_axim_s),
  .aw_qv_axi_m_0        (),
  .ar_qv_axi_m_0        (),
  .awid_axi_m_1         (awid_switch3_sysctrl_axim_sysctrl_axim_s),
  .awaddr_axi_m_1       (awaddr_switch3_sysctrl_axim_sysctrl_axim_s),
  .awlen_axi_m_1        (awlen_switch3_sysctrl_axim_sysctrl_axim_s),
  .awsize_axi_m_1       (awsize_switch3_sysctrl_axim_sysctrl_axim_s),
  .awburst_axi_m_1      (awburst_switch3_sysctrl_axim_sysctrl_axim_s),
  .awlock_axi_m_1       (awlock_switch3_sysctrl_axim_sysctrl_axim_s),
  .awcache_axi_m_1      (awcache_switch3_sysctrl_axim_sysctrl_axim_s),
  .awprot_axi_m_1       (awprot_switch3_sysctrl_axim_sysctrl_axim_s),
  .awvalid_axi_m_1      (awvalid_switch3_sysctrl_axim_sysctrl_axim_s),
  .awvalid_vect_axi_m_1 (),
  .awready_axi_m_1      (awready_switch3_sysctrl_axim_sysctrl_axim_s),
  .wdata_axi_m_1        (wdata_switch3_sysctrl_axim_sysctrl_axim_s),
  .wstrb_axi_m_1        (wstrb_switch3_sysctrl_axim_sysctrl_axim_s),
  .wlast_axi_m_1        (wlast_switch3_sysctrl_axim_sysctrl_axim_s),
  .wvalid_axi_m_1       (wvalid_switch3_sysctrl_axim_sysctrl_axim_s),
  .wready_axi_m_1       (wready_switch3_sysctrl_axim_sysctrl_axim_s),
  .bid_axi_m_1          (bid_switch3_sysctrl_axim_sysctrl_axim_s),
  .bresp_axi_m_1        (bresp_switch3_sysctrl_axim_sysctrl_axim_s),
  .bvalid_axi_m_1       (bvalid_switch3_sysctrl_axim_sysctrl_axim_s),
  .bready_axi_m_1       (bready_switch3_sysctrl_axim_sysctrl_axim_s),
  .arid_axi_m_1         (arid_switch3_sysctrl_axim_sysctrl_axim_s),
  .araddr_axi_m_1       (araddr_switch3_sysctrl_axim_sysctrl_axim_s),
  .arlen_axi_m_1        (arlen_switch3_sysctrl_axim_sysctrl_axim_s),
  .arsize_axi_m_1       (arsize_switch3_sysctrl_axim_sysctrl_axim_s),
  .arburst_axi_m_1      (arburst_switch3_sysctrl_axim_sysctrl_axim_s),
  .arlock_axi_m_1       (arlock_switch3_sysctrl_axim_sysctrl_axim_s),
  .arcache_axi_m_1      (arcache_switch3_sysctrl_axim_sysctrl_axim_s),
  .arprot_axi_m_1       (arprot_switch3_sysctrl_axim_sysctrl_axim_s),
  .arvalid_axi_m_1      (arvalid_switch3_sysctrl_axim_sysctrl_axim_s),
  .arvalid_vect_axi_m_1 (),
  .arready_axi_m_1      (arready_switch3_sysctrl_axim_sysctrl_axim_s),
  .rid_axi_m_1          (rid_switch3_sysctrl_axim_sysctrl_axim_s),
  .rdata_axi_m_1        (rdata_switch3_sysctrl_axim_sysctrl_axim_s),
  .rresp_axi_m_1        (rresp_switch3_sysctrl_axim_sysctrl_axim_s),
  .rlast_axi_m_1        (rlast_switch3_sysctrl_axim_sysctrl_axim_s),
  .rvalid_axi_m_1       (rvalid_switch3_sysctrl_axim_sysctrl_axim_s),
  .rready_axi_m_1       (rready_switch3_sysctrl_axim_sysctrl_axim_s),
  .awuser_axi_m_1       (awuser_switch3_sysctrl_axim_sysctrl_axim_s),
  .buser_axi_m_1        (buser_switch3_sysctrl_axim_sysctrl_axim_s),
  .aruser_axi_m_1       (aruser_switch3_sysctrl_axim_sysctrl_axim_s),
  .ruser_axi_m_1        (ruser_switch3_sysctrl_axim_sysctrl_axim_s),
  .aw_qv_axi_m_1        (),
  .ar_qv_axi_m_1        (),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .awid_axi_m_2         (awid_switch3_bootreg_axim_bootreg_axim_s),
  .awaddr_axi_m_2       (awaddr_switch3_bootreg_axim_bootreg_axim_s),
  .awlen_axi_m_2        (awlen_switch3_bootreg_axim_bootreg_axim_s),
  .awsize_axi_m_2       (awsize_switch3_bootreg_axim_bootreg_axim_s),
  .awburst_axi_m_2      (awburst_switch3_bootreg_axim_bootreg_axim_s),
  .awlock_axi_m_2       (awlock_switch3_bootreg_axim_bootreg_axim_s),
  .awcache_axi_m_2      (awcache_switch3_bootreg_axim_bootreg_axim_s),
  .awprot_axi_m_2       (awprot_switch3_bootreg_axim_bootreg_axim_s),
  .awvalid_axi_m_2      (awvalid_switch3_bootreg_axim_bootreg_axim_s),
  .awvalid_vect_axi_m_2 (),
  .awready_axi_m_2      (awready_switch3_bootreg_axim_bootreg_axim_s),
  .wdata_axi_m_2        (wdata_switch3_bootreg_axim_bootreg_axim_s),
  .wstrb_axi_m_2        (wstrb_switch3_bootreg_axim_bootreg_axim_s),
  .wlast_axi_m_2        (wlast_switch3_bootreg_axim_bootreg_axim_s),
  .wvalid_axi_m_2       (wvalid_switch3_bootreg_axim_bootreg_axim_s),
  .wready_axi_m_2       (wready_switch3_bootreg_axim_bootreg_axim_s),
  .bid_axi_m_2          (bid_switch3_bootreg_axim_bootreg_axim_s),
  .bresp_axi_m_2        (bresp_switch3_bootreg_axim_bootreg_axim_s),
  .bvalid_axi_m_2       (bvalid_switch3_bootreg_axim_bootreg_axim_s),
  .bready_axi_m_2       (bready_switch3_bootreg_axim_bootreg_axim_s),
  .arid_axi_m_2         (arid_switch3_bootreg_axim_bootreg_axim_s),
  .araddr_axi_m_2       (araddr_switch3_bootreg_axim_bootreg_axim_s),
  .arlen_axi_m_2        (arlen_switch3_bootreg_axim_bootreg_axim_s),
  .arsize_axi_m_2       (arsize_switch3_bootreg_axim_bootreg_axim_s),
  .arburst_axi_m_2      (arburst_switch3_bootreg_axim_bootreg_axim_s),
  .arlock_axi_m_2       (arlock_switch3_bootreg_axim_bootreg_axim_s),
  .arcache_axi_m_2      (arcache_switch3_bootreg_axim_bootreg_axim_s),
  .arprot_axi_m_2       (arprot_switch3_bootreg_axim_bootreg_axim_s),
  .arvalid_axi_m_2      (arvalid_switch3_bootreg_axim_bootreg_axim_s),
  .arvalid_vect_axi_m_2 (),
  .arready_axi_m_2      (arready_switch3_bootreg_axim_bootreg_axim_s),
  .rid_axi_m_2          (rid_switch3_bootreg_axim_bootreg_axim_s),
  .rdata_axi_m_2        (rdata_switch3_bootreg_axim_bootreg_axim_s),
  .rresp_axi_m_2        (rresp_switch3_bootreg_axim_bootreg_axim_s),
  .rlast_axi_m_2        (rlast_switch3_bootreg_axim_bootreg_axim_s),
  .rvalid_axi_m_2       (rvalid_switch3_bootreg_axim_bootreg_axim_s),
  .rready_axi_m_2       (rready_switch3_bootreg_axim_bootreg_axim_s),
  .awuser_axi_m_2       (awuser_switch3_bootreg_axim_bootreg_axim_s),
  .buser_axi_m_2        (1'b0),
  .aruser_axi_m_2       (aruser_switch3_bootreg_axim_bootreg_axim_s),
  .ruser_axi_m_2        (1'b0),
  .aw_qv_axi_m_2        (),
  .ar_qv_axi_m_2        (),
  .awid_axi_m_3         (awid_switch3_firewall_axim_firewall_axim_s),
  .awaddr_axi_m_3       (awaddr_switch3_firewall_axim_firewall_axim_s),
  .awlen_axi_m_3        (awlen_switch3_firewall_axim_firewall_axim_s),
  .awsize_axi_m_3       (awsize_switch3_firewall_axim_firewall_axim_s),
  .awburst_axi_m_3      (awburst_switch3_firewall_axim_firewall_axim_s),
  .awlock_axi_m_3       (awlock_switch3_firewall_axim_firewall_axim_s),
  .awcache_axi_m_3      (awcache_switch3_firewall_axim_firewall_axim_s),
  .awprot_axi_m_3       (awprot_switch3_firewall_axim_firewall_axim_s),
  .awvalid_axi_m_3      (awvalid_switch3_firewall_axim_firewall_axim_s),
  .awvalid_vect_axi_m_3 (),
  .awready_axi_m_3      (awready_switch3_firewall_axim_firewall_axim_s),
  .wdata_axi_m_3        (wdata_switch3_firewall_axim_firewall_axim_s),
  .wstrb_axi_m_3        (wstrb_switch3_firewall_axim_firewall_axim_s),
  .wlast_axi_m_3        (wlast_switch3_firewall_axim_firewall_axim_s),
  .wvalid_axi_m_3       (wvalid_switch3_firewall_axim_firewall_axim_s),
  .wready_axi_m_3       (wready_switch3_firewall_axim_firewall_axim_s),
  .bid_axi_m_3          (bid_switch3_firewall_axim_firewall_axim_s),
  .bresp_axi_m_3        (bresp_switch3_firewall_axim_firewall_axim_s),
  .bvalid_axi_m_3       (bvalid_switch3_firewall_axim_firewall_axim_s),
  .bready_axi_m_3       (bready_switch3_firewall_axim_firewall_axim_s),
  .arid_axi_m_3         (arid_switch3_firewall_axim_firewall_axim_s),
  .araddr_axi_m_3       (araddr_switch3_firewall_axim_firewall_axim_s),
  .arlen_axi_m_3        (arlen_switch3_firewall_axim_firewall_axim_s),
  .arsize_axi_m_3       (arsize_switch3_firewall_axim_firewall_axim_s),
  .arburst_axi_m_3      (arburst_switch3_firewall_axim_firewall_axim_s),
  .arlock_axi_m_3       (arlock_switch3_firewall_axim_firewall_axim_s),
  .arcache_axi_m_3      (arcache_switch3_firewall_axim_firewall_axim_s),
  .arprot_axi_m_3       (arprot_switch3_firewall_axim_firewall_axim_s),
  .arvalid_axi_m_3      (arvalid_switch3_firewall_axim_firewall_axim_s),
  .arvalid_vect_axi_m_3 (),
  .arready_axi_m_3      (arready_switch3_firewall_axim_firewall_axim_s),
  .rid_axi_m_3          (rid_switch3_firewall_axim_firewall_axim_s),
  .rdata_axi_m_3        (rdata_switch3_firewall_axim_firewall_axim_s),
  .rresp_axi_m_3        (rresp_switch3_firewall_axim_firewall_axim_s),
  .rlast_axi_m_3        (rlast_switch3_firewall_axim_firewall_axim_s),
  .rvalid_axi_m_3       (rvalid_switch3_firewall_axim_firewall_axim_s),
  .rready_axi_m_3       (rready_switch3_firewall_axim_firewall_axim_s),
  .awuser_axi_m_3       (awuser_switch3_firewall_axim_firewall_axim_s),
  .buser_axi_m_3        (buser_switch3_firewall_axim_firewall_axim_s),
  .aruser_axi_m_3       (aruser_switch3_firewall_axim_firewall_axim_s),
  .ruser_axi_m_3        (ruser_switch3_firewall_axim_firewall_axim_s),
  .aw_qv_axi_m_3        (),
  .ar_qv_axi_m_3        (),
  .awid_axi_s_0         (awid_ib4_switch3_axi_s_0),
  .awaddr_axi_s_0       (awaddr_ib4_switch3_axi_s_0),
  .awlen_axi_s_0        (awlen_ib4_switch3_axi_s_0),
  .awsize_axi_s_0       (awsize_ib4_switch3_axi_s_0),
  .awburst_axi_s_0      (awburst_ib4_switch3_axi_s_0),
  .awlock_axi_s_0       (awlock_ib4_switch3_axi_s_0),
  .awcache_axi_s_0      (awcache_ib4_switch3_axi_s_0),
  .awprot_axi_s_0       (awprot_ib4_switch3_axi_s_0),
  .awvalid_axi_s_0      (awvalid_ib4_switch3_axi_s_0),
  .awvalid_vect_axi_s_0 (awvalid_vect_ib4_switch3_axi_s_0),
  .awready_axi_s_0      (awready_ib4_switch3_axi_s_0),
  .wdata_axi_s_0        (wdata_ib4_switch3_axi_s_0),
  .wstrb_axi_s_0        (wstrb_ib4_switch3_axi_s_0),
  .wlast_axi_s_0        (wlast_ib4_switch3_axi_s_0),
  .wvalid_axi_s_0       (wvalid_ib4_switch3_axi_s_0),
  .wready_axi_s_0       (wready_ib4_switch3_axi_s_0),
  .bid_axi_s_0          (bid_ib4_switch3_axi_s_0),
  .bresp_axi_s_0        (bresp_ib4_switch3_axi_s_0),
  .bvalid_axi_s_0       (bvalid_ib4_switch3_axi_s_0),
  .bready_axi_s_0       (bready_ib4_switch3_axi_s_0),
  .arid_axi_s_0         (arid_ib4_switch3_axi_s_0),
  .araddr_axi_s_0       (araddr_ib4_switch3_axi_s_0),
  .arlen_axi_s_0        (arlen_ib4_switch3_axi_s_0),
  .arsize_axi_s_0       (arsize_ib4_switch3_axi_s_0),
  .arburst_axi_s_0      (arburst_ib4_switch3_axi_s_0),
  .arlock_axi_s_0       (arlock_ib4_switch3_axi_s_0),
  .arcache_axi_s_0      (arcache_ib4_switch3_axi_s_0),
  .arprot_axi_s_0       (arprot_ib4_switch3_axi_s_0),
  .arvalid_axi_s_0      (arvalid_ib4_switch3_axi_s_0),
  .arvalid_vect_axi_s_0 (arvalid_vect_ib4_switch3_axi_s_0),
  .arready_axi_s_0      (arready_ib4_switch3_axi_s_0),
  .rid_axi_s_0          (rid_ib4_switch3_axi_s_0),
  .rdata_axi_s_0        (rdata_ib4_switch3_axi_s_0),
  .rresp_axi_s_0        (rresp_ib4_switch3_axi_s_0),
  .rlast_axi_s_0        (rlast_ib4_switch3_axi_s_0),
  .rvalid_axi_s_0       (rvalid_ib4_switch3_axi_s_0),
  .rready_axi_s_0       (rready_ib4_switch3_axi_s_0),
  .awuser_axi_s_0       (awuser_ib4_switch3_axi_s_0),
  .buser_axi_s_0        (buser_ib4_switch3_axi_s_0),
  .aruser_axi_s_0       (aruser_ib4_switch3_axi_s_0),
  .ruser_axi_s_0        (ruser_ib4_switch3_axi_s_0),
  .aw_qv_axi_s_0        (awqv_ib4_switch3_axi_s_0),
  .ar_qv_axi_s_0        (arqv_ib4_switch3_axi_s_0)
);


nic400_default_slave_ds_1_sse710_main     u_default_slave_ds_1 (
  .awid                 (awid_switch2_ds_1_axi_s_0),
  .awvalid              (awvalid_switch2_ds_1_axi_s_0),
  .awready              (awready_switch2_ds_1_axi_s_0),
  .wlast                (wlast_switch2_ds_1_axi_s_0),
  .wvalid               (wvalid_switch2_ds_1_axi_s_0),
  .wready               (wready_switch2_ds_1_axi_s_0),
  .bid                  (bid_switch2_ds_1_axi_s_0),
  .bresp                (bresp_switch2_ds_1_axi_s_0),
  .bvalid               (bvalid_switch2_ds_1_axi_s_0),
  .bready               (bready_switch2_ds_1_axi_s_0),
  .arid                 (arid_switch2_ds_1_axi_s_0),
  .arlen                (arlen_switch2_ds_1_axi_s_0),
  .arvalid              (arvalid_switch2_ds_1_axi_s_0),
  .arready              (arready_switch2_ds_1_axi_s_0),
  .rid                  (rid_switch2_ds_1_axi_s_0),
  .rresp                (rresp_switch2_ds_1_axi_s_0),
  .rlast                (rlast_switch2_ds_1_axi_s_0),
  .rvalid               (rvalid_switch2_ds_1_axi_s_0),
  .rready               (rready_switch2_ds_1_axi_s_0),
  .aclk                 (aclk),
  .aresetn              (aresetn)
);


nic400_default_slave_ds_2_sse710_main     u_default_slave_ds_2 (
  .awid                 (awid_switch1_ds_2_axi_s_0),
  .awvalid              (awvalid_switch1_ds_2_axi_s_0),
  .awready              (awready_switch1_ds_2_axi_s_0),
  .wlast                (wlast_switch1_ds_2_axi_s_0),
  .wvalid               (wvalid_switch1_ds_2_axi_s_0),
  .wready               (wready_switch1_ds_2_axi_s_0),
  .bid                  (bid_switch1_ds_2_axi_s_0),
  .bresp                (bresp_switch1_ds_2_axi_s_0),
  .bvalid               (bvalid_switch1_ds_2_axi_s_0),
  .bready               (bready_switch1_ds_2_axi_s_0),
  .arid                 (arid_switch1_ds_2_axi_s_0),
  .arlen                (arlen_switch1_ds_2_axi_s_0),
  .arvalid              (arvalid_switch1_ds_2_axi_s_0),
  .arready              (arready_switch1_ds_2_axi_s_0),
  .rid                  (rid_switch1_ds_2_axi_s_0),
  .rresp                (rresp_switch1_ds_2_axi_s_0),
  .rlast                (rlast_switch1_ds_2_axi_s_0),
  .rvalid               (rvalid_switch1_ds_2_axi_s_0),
  .rready               (rready_switch1_ds_2_axi_s_0),
  .aclk                 (aclk),
  .aresetn              (aresetn)
);


nic400_dmu_a_sse710_main     u_dmu_a_sse710_main (
  .cd_a_clk             (aclk),
  .cd_a_resetn          (aresetn),
  .cd_a_cactive         (cactive_cd_a),
  .cd_a_csysreq         (csysreq_cd_a),
  .cd_a_csysack         (csysack_cd_a),
  .debug_axis_cactive   (cactive_debug_axis_hcg),
  .debug_axis_port_enable (port_enable_debug_axis_port_enable_hcg),
  .debug_axis_cactive_wakeup (cactive_debug_axis_wakeup_hcg),
  .expslv0_axis_cactive (cactive_expslv0_axis_hcg),
  .expslv0_axis_port_enable (port_enable_expslv0_axis_port_enable_hcg),
  .expslv0_axis_cactive_wakeup (cactive_expslv0_axis_wakeup_hcg),
  .expslv1_axis_cactive (cactive_expslv1_axis_hcg),
  .expslv1_axis_port_enable (port_enable_expslv1_axis_port_enable_hcg),
  .expslv1_axis_cactive_wakeup (cactive_expslv1_axis_wakeup_hcg),
  .extsys0_axis_cactive (cactive_extsys0_axis_hcg),
  .extsys0_axis_port_enable (port_enable_extsys0_axis_port_enable_hcg),
  .extsys0_axis_cactive_wakeup (cactive_extsys0_axis_wakeup_hcg),
  .extsys1_axis_cactive (cactive_extsys1_axis_hcg),
  .extsys1_axis_port_enable (port_enable_extsys1_axis_port_enable_hcg),
  .extsys1_axis_cactive_wakeup (cactive_extsys1_axis_wakeup_hcg),
  .gpvmain_ahb_ib_cactive (cactive_gpvmain_ahb_ib_hcg),
  .gpvmain_ahb_ib_port_enable (port_enable_gpvmain_ahb_ib_port_enable_hcg),
  .gpvmain_ahb_ib_cactive_wakeup (cactive_gpvmain_ahb_ib_wakeup_hcg),
  .hostcpu_axis_cactive (cactive_hostcpu_axis_hcg),
  .hostcpu_axis_port_enable (port_enable_hostcpu_axis_port_enable_hcg),
  .hostcpu_axis_cactive_wakeup (cactive_hostcpu_axis_wakeup_hcg),
  .secenc_axis_cactive  (cactive_secenc_axis_hcg),
  .secenc_axis_port_enable (port_enable_secenc_axis_port_enable_hcg),
  .secenc_axis_cactive_wakeup (cactive_secenc_axis_wakeup_hcg)
);


nic400_ib_cvm_axim_ib_master_domain_sse710_main     u_ib_cvm_axim_ib_m (
  .awid_axi4_m          (awid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awaddr_axi4_m        (awaddr_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awlen_axi4_m         (awlen_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awsize_axi4_m        (awsize_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awburst_axi4_m       (awburst_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awlock_axi4_m        (awlock_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awcache_axi4_m       (awcache_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awprot_axi4_m        (awprot_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awvalid_axi4_m       (awvalid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awready_axi4_m       (awready_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .wdata_axi4_m         (wdata_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .wstrb_axi4_m         (wstrb_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .wlast_axi4_m         (wlast_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .wvalid_axi4_m        (wvalid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .wready_axi4_m        (wready_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .bid_axi4_m           (bid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .bresp_axi4_m         (bresp_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .bvalid_axi4_m        (bvalid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .bready_axi4_m        (bready_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arid_axi4_m          (arid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .araddr_axi4_m        (araddr_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arlen_axi4_m         (arlen_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arsize_axi4_m        (arsize_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arburst_axi4_m       (arburst_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arlock_axi4_m        (arlock_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arcache_axi4_m       (arcache_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arprot_axi4_m        (arprot_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arvalid_axi4_m       (arvalid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arready_axi4_m       (arready_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .rid_axi4_m           (rid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .rdata_axi4_m         (rdata_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .rresp_axi4_m         (rresp_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .rlast_axi4_m         (rlast_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .rvalid_axi4_m        (rvalid_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .rready_axi4_m        (rready_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awuser_axi4_m        (awuser_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .buser_axi4_m         (buser_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .aruser_axi4_m        (aruser_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .ruser_axi4_m         (ruser_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .awqv_axi4_m          (awqv_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .arqv_axi4_m          (arqv_cvm_axim_ib_cvm_axim_cvm_axim_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_cvm_axim_ib_int),
  .aw_valid             (aw_valid_cvm_axim_ib_int),
  .aw_ready             (aw_ready_cvm_axim_ib_int),
  .b_data               (b_data_cvm_axim_ib_int),
  .b_valid              (b_valid_cvm_axim_ib_int),
  .b_ready              (b_ready_cvm_axim_ib_int),
  .ar_data              (ar_data_cvm_axim_ib_int),
  .ar_valid             (ar_valid_cvm_axim_ib_int),
  .ar_ready             (ar_ready_cvm_axim_ib_int),
  .r_data               (r_data_cvm_axim_ib_int),
  .r_valid              (r_valid_cvm_axim_ib_int),
  .r_ready              (r_ready_cvm_axim_ib_int),
  .w_data               (w_data_cvm_axim_ib_int),
  .w_valid              (w_valid_cvm_axim_ib_int),
  .w_ready              (w_ready_cvm_axim_ib_int)
);


nic400_ib_cvm_axim_ib_slave_domain_sse710_main     u_ib_cvm_axim_ib_s (
  .awid_axi4_s          (awid_switch2_cvm_axim_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_switch2_cvm_axim_ib_axi4_s),
  .awlen_axi4_s         (awlen_switch2_cvm_axim_ib_axi4_s),
  .awsize_axi4_s        (awsize_switch2_cvm_axim_ib_axi4_s),
  .awburst_axi4_s       (awburst_switch2_cvm_axim_ib_axi4_s),
  .awlock_axi4_s        (awlock_switch2_cvm_axim_ib_axi4_s),
  .awcache_axi4_s       (awcache_switch2_cvm_axim_ib_axi4_s),
  .awprot_axi4_s        (awprot_switch2_cvm_axim_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_switch2_cvm_axim_ib_axi4_s),
  .awready_axi4_s       (awready_switch2_cvm_axim_ib_axi4_s),
  .wdata_axi4_s         (wdata_switch2_cvm_axim_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_switch2_cvm_axim_ib_axi4_s),
  .wlast_axi4_s         (wlast_switch2_cvm_axim_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_switch2_cvm_axim_ib_axi4_s),
  .wready_axi4_s        (wready_switch2_cvm_axim_ib_axi4_s),
  .bid_axi4_s           (bid_switch2_cvm_axim_ib_axi4_s),
  .bresp_axi4_s         (bresp_switch2_cvm_axim_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_switch2_cvm_axim_ib_axi4_s),
  .bready_axi4_s        (bready_switch2_cvm_axim_ib_axi4_s),
  .arid_axi4_s          (arid_switch2_cvm_axim_ib_axi4_s),
  .araddr_axi4_s        (araddr_switch2_cvm_axim_ib_axi4_s),
  .arlen_axi4_s         (arlen_switch2_cvm_axim_ib_axi4_s),
  .arsize_axi4_s        (arsize_switch2_cvm_axim_ib_axi4_s),
  .arburst_axi4_s       (arburst_switch2_cvm_axim_ib_axi4_s),
  .arlock_axi4_s        (arlock_switch2_cvm_axim_ib_axi4_s),
  .arcache_axi4_s       (arcache_switch2_cvm_axim_ib_axi4_s),
  .arprot_axi4_s        (arprot_switch2_cvm_axim_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_switch2_cvm_axim_ib_axi4_s),
  .arready_axi4_s       (arready_switch2_cvm_axim_ib_axi4_s),
  .rid_axi4_s           (rid_switch2_cvm_axim_ib_axi4_s),
  .rdata_axi4_s         (rdata_switch2_cvm_axim_ib_axi4_s),
  .rresp_axi4_s         (rresp_switch2_cvm_axim_ib_axi4_s),
  .rlast_axi4_s         (rlast_switch2_cvm_axim_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_switch2_cvm_axim_ib_axi4_s),
  .rready_axi4_s        (rready_switch2_cvm_axim_ib_axi4_s),
  .awuser_axi4_s        (awuser_switch2_cvm_axim_ib_axi4_s),
  .buser_axi4_s         (buser_switch2_cvm_axim_ib_axi4_s),
  .aruser_axi4_s        (aruser_switch2_cvm_axim_ib_axi4_s),
  .ruser_axi4_s         (ruser_switch2_cvm_axim_ib_axi4_s),
  .awqv_axi4_s          (awqv_switch2_cvm_axim_ib_axi4_s),
  .arqv_axi4_s          (arqv_switch2_cvm_axim_ib_axi4_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_cvm_axim_ib_int),
  .aw_valid             (aw_valid_cvm_axim_ib_int),
  .aw_ready             (aw_ready_cvm_axim_ib_int),
  .b_data               (b_data_cvm_axim_ib_int),
  .b_valid              (b_valid_cvm_axim_ib_int),
  .b_ready              (b_ready_cvm_axim_ib_int),
  .ar_data              (ar_data_cvm_axim_ib_int),
  .ar_valid             (ar_valid_cvm_axim_ib_int),
  .ar_ready             (ar_ready_cvm_axim_ib_int),
  .r_data               (r_data_cvm_axim_ib_int),
  .r_valid              (r_valid_cvm_axim_ib_int),
  .r_ready              (r_ready_cvm_axim_ib_int),
  .w_data               (w_data_cvm_axim_ib_int),
  .w_valid              (w_valid_cvm_axim_ib_int),
  .w_ready              (w_ready_cvm_axim_ib_int)
);


nic400_ib_debug_axim_ib_master_domain_sse710_main     u_ib_debug_axim_ib_m (
  .awid_axi4_m          (awid_debug_axim_ib_debug_axim_debug_axim_s),
  .awaddr_axi4_m        (awaddr_debug_axim_ib_debug_axim_debug_axim_s),
  .awlen_axi4_m         (awlen_debug_axim_ib_debug_axim_debug_axim_s),
  .awsize_axi4_m        (awsize_debug_axim_ib_debug_axim_debug_axim_s),
  .awburst_axi4_m       (awburst_debug_axim_ib_debug_axim_debug_axim_s),
  .awlock_axi4_m        (awlock_debug_axim_ib_debug_axim_debug_axim_s),
  .awcache_axi4_m       (awcache_debug_axim_ib_debug_axim_debug_axim_s),
  .awprot_axi4_m        (awprot_debug_axim_ib_debug_axim_debug_axim_s),
  .awvalid_axi4_m       (awvalid_debug_axim_ib_debug_axim_debug_axim_s),
  .awready_axi4_m       (awready_debug_axim_ib_debug_axim_debug_axim_s),
  .wdata_axi4_m         (wdata_debug_axim_ib_debug_axim_debug_axim_s),
  .wstrb_axi4_m         (wstrb_debug_axim_ib_debug_axim_debug_axim_s),
  .wlast_axi4_m         (wlast_debug_axim_ib_debug_axim_debug_axim_s),
  .wvalid_axi4_m        (wvalid_debug_axim_ib_debug_axim_debug_axim_s),
  .wready_axi4_m        (wready_debug_axim_ib_debug_axim_debug_axim_s),
  .bid_axi4_m           (bid_debug_axim_ib_debug_axim_debug_axim_s),
  .bresp_axi4_m         (bresp_debug_axim_ib_debug_axim_debug_axim_s),
  .bvalid_axi4_m        (bvalid_debug_axim_ib_debug_axim_debug_axim_s),
  .bready_axi4_m        (bready_debug_axim_ib_debug_axim_debug_axim_s),
  .arid_axi4_m          (arid_debug_axim_ib_debug_axim_debug_axim_s),
  .araddr_axi4_m        (araddr_debug_axim_ib_debug_axim_debug_axim_s),
  .arlen_axi4_m         (arlen_debug_axim_ib_debug_axim_debug_axim_s),
  .arsize_axi4_m        (arsize_debug_axim_ib_debug_axim_debug_axim_s),
  .arburst_axi4_m       (arburst_debug_axim_ib_debug_axim_debug_axim_s),
  .arlock_axi4_m        (arlock_debug_axim_ib_debug_axim_debug_axim_s),
  .arcache_axi4_m       (arcache_debug_axim_ib_debug_axim_debug_axim_s),
  .arprot_axi4_m        (arprot_debug_axim_ib_debug_axim_debug_axim_s),
  .arvalid_axi4_m       (arvalid_debug_axim_ib_debug_axim_debug_axim_s),
  .arready_axi4_m       (arready_debug_axim_ib_debug_axim_debug_axim_s),
  .rid_axi4_m           (rid_debug_axim_ib_debug_axim_debug_axim_s),
  .rdata_axi4_m         (rdata_debug_axim_ib_debug_axim_debug_axim_s),
  .rresp_axi4_m         (rresp_debug_axim_ib_debug_axim_debug_axim_s),
  .rlast_axi4_m         (rlast_debug_axim_ib_debug_axim_debug_axim_s),
  .rvalid_axi4_m        (rvalid_debug_axim_ib_debug_axim_debug_axim_s),
  .rready_axi4_m        (rready_debug_axim_ib_debug_axim_debug_axim_s),
  .awuser_axi4_m        (awuser_debug_axim_ib_debug_axim_debug_axim_s),
  .buser_axi4_m         (buser_debug_axim_ib_debug_axim_debug_axim_s),
  .aruser_axi4_m        (aruser_debug_axim_ib_debug_axim_debug_axim_s),
  .ruser_axi4_m         (ruser_debug_axim_ib_debug_axim_debug_axim_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_debug_axim_ib_int),
  .aw_valid             (aw_valid_debug_axim_ib_int),
  .aw_ready             (aw_ready_debug_axim_ib_int),
  .b_data               (b_data_debug_axim_ib_int),
  .b_valid              (b_valid_debug_axim_ib_int),
  .b_ready              (b_ready_debug_axim_ib_int),
  .ar_data              (ar_data_debug_axim_ib_int),
  .ar_valid             (ar_valid_debug_axim_ib_int),
  .ar_ready             (ar_ready_debug_axim_ib_int),
  .r_data               (r_data_debug_axim_ib_int),
  .r_valid              (r_valid_debug_axim_ib_int),
  .r_ready              (r_ready_debug_axim_ib_int),
  .w_data               (w_data_debug_axim_ib_int),
  .w_valid              (w_valid_debug_axim_ib_int),
  .w_ready              (w_ready_debug_axim_ib_int)
);


nic400_ib_debug_axim_ib_slave_domain_sse710_main     u_ib_debug_axim_ib_s (
  .awid_axi4_s          (awid_switch2_debug_axim_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_switch2_debug_axim_ib_axi4_s),
  .awlen_axi4_s         (awlen_switch2_debug_axim_ib_axi4_s),
  .awsize_axi4_s        (awsize_switch2_debug_axim_ib_axi4_s),
  .awburst_axi4_s       (awburst_switch2_debug_axim_ib_axi4_s),
  .awlock_axi4_s        (awlock_switch2_debug_axim_ib_axi4_s),
  .awcache_axi4_s       (awcache_switch2_debug_axim_ib_axi4_s),
  .awprot_axi4_s        (awprot_switch2_debug_axim_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_switch2_debug_axim_ib_axi4_s),
  .awready_axi4_s       (awready_switch2_debug_axim_ib_axi4_s),
  .wdata_axi4_s         (wdata_switch2_debug_axim_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_switch2_debug_axim_ib_axi4_s),
  .wlast_axi4_s         (wlast_switch2_debug_axim_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_switch2_debug_axim_ib_axi4_s),
  .wready_axi4_s        (wready_switch2_debug_axim_ib_axi4_s),
  .bid_axi4_s           (bid_switch2_debug_axim_ib_axi4_s),
  .bresp_axi4_s         (bresp_switch2_debug_axim_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_switch2_debug_axim_ib_axi4_s),
  .bready_axi4_s        (bready_switch2_debug_axim_ib_axi4_s),
  .arid_axi4_s          (arid_switch2_debug_axim_ib_axi4_s),
  .araddr_axi4_s        (araddr_switch2_debug_axim_ib_axi4_s),
  .arlen_axi4_s         (arlen_switch2_debug_axim_ib_axi4_s),
  .arsize_axi4_s        (arsize_switch2_debug_axim_ib_axi4_s),
  .arburst_axi4_s       (arburst_switch2_debug_axim_ib_axi4_s),
  .arlock_axi4_s        (arlock_switch2_debug_axim_ib_axi4_s),
  .arcache_axi4_s       (arcache_switch2_debug_axim_ib_axi4_s),
  .arprot_axi4_s        (arprot_switch2_debug_axim_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_switch2_debug_axim_ib_axi4_s),
  .arready_axi4_s       (arready_switch2_debug_axim_ib_axi4_s),
  .rid_axi4_s           (rid_switch2_debug_axim_ib_axi4_s),
  .rdata_axi4_s         (rdata_switch2_debug_axim_ib_axi4_s),
  .rresp_axi4_s         (rresp_switch2_debug_axim_ib_axi4_s),
  .rlast_axi4_s         (rlast_switch2_debug_axim_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_switch2_debug_axim_ib_axi4_s),
  .rready_axi4_s        (rready_switch2_debug_axim_ib_axi4_s),
  .awuser_axi4_s        (awuser_switch2_debug_axim_ib_axi4_s),
  .buser_axi4_s         (buser_switch2_debug_axim_ib_axi4_s),
  .aruser_axi4_s        (aruser_switch2_debug_axim_ib_axi4_s),
  .ruser_axi4_s         (ruser_switch2_debug_axim_ib_axi4_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_debug_axim_ib_int),
  .aw_valid             (aw_valid_debug_axim_ib_int),
  .aw_ready             (aw_ready_debug_axim_ib_int),
  .b_data               (b_data_debug_axim_ib_int),
  .b_valid              (b_valid_debug_axim_ib_int),
  .b_ready              (b_ready_debug_axim_ib_int),
  .ar_data              (ar_data_debug_axim_ib_int),
  .ar_valid             (ar_valid_debug_axim_ib_int),
  .ar_ready             (ar_ready_debug_axim_ib_int),
  .r_data               (r_data_debug_axim_ib_int),
  .r_valid              (r_valid_debug_axim_ib_int),
  .r_ready              (r_ready_debug_axim_ib_int),
  .w_data               (w_data_debug_axim_ib_int),
  .w_valid              (w_valid_debug_axim_ib_int),
  .w_ready              (w_ready_debug_axim_ib_int)
);


nic400_ib_debug_axis_ib_master_domain_sse710_main     u_ib_debug_axis_ib_m (
  .paddr                (paddr_debug_axis_ib_apb),
  .pwdata               (pwdata_debug_axis_ib_apb),
  .pwrite               (pwrite_debug_axis_ib_apb),
  .penable              (penable_debug_axis_ib_apb),
  .psel                 (pselx_debug_axis_ib_apb),
  .prdata               (prdata_debug_axis_ib_apb),
  .pslverr              (pslverr_debug_axis_ib_apb),
  .pready               (pready_debug_axis_ib_apb),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .apbm_req             (preq_debug_axis_ib_apb_int),
  .apbm_ack             (pack_debug_axis_ib_apb_int),
  .apbm_fwd_data        (pfwdpayld_debug_axis_ib_apb_int),
  .apbm_rev_data        (prevpayld_debug_axis_ib_apb_int),
  .awid_axi4_m          (awid_debug_axis_ib_switch2_axi_s_6),
  .awaddr_axi4_m        (awaddr_debug_axis_ib_switch2_axi_s_6),
  .awlen_axi4_m         (awlen_debug_axis_ib_switch2_axi_s_6),
  .awsize_axi4_m        (awsize_debug_axis_ib_switch2_axi_s_6),
  .awburst_axi4_m       (awburst_debug_axis_ib_switch2_axi_s_6),
  .awlock_axi4_m        (awlock_debug_axis_ib_switch2_axi_s_6),
  .awcache_axi4_m       (awcache_debug_axis_ib_switch2_axi_s_6),
  .awprot_axi4_m        (awprot_debug_axis_ib_switch2_axi_s_6),
  .awvalid_axi4_m       (awvalid_debug_axis_ib_switch2_axi_s_6),
  .awvalid_vect_axi4_m  (awvalid_vect_debug_axis_ib_switch2_axi_s_6),
  .awready_axi4_m       (awready_debug_axis_ib_switch2_axi_s_6),
  .wdata_axi4_m         (wdata_debug_axis_ib_switch2_axi_s_6),
  .wstrb_axi4_m         (wstrb_debug_axis_ib_switch2_axi_s_6),
  .wlast_axi4_m         (wlast_debug_axis_ib_switch2_axi_s_6),
  .wvalid_axi4_m        (wvalid_debug_axis_ib_switch2_axi_s_6),
  .wready_axi4_m        (wready_debug_axis_ib_switch2_axi_s_6),
  .bid_axi4_m           (bid_debug_axis_ib_switch2_axi_s_6),
  .bresp_axi4_m         (bresp_debug_axis_ib_switch2_axi_s_6),
  .bvalid_axi4_m        (bvalid_debug_axis_ib_switch2_axi_s_6),
  .bready_axi4_m        (bready_debug_axis_ib_switch2_axi_s_6),
  .arid_axi4_m          (arid_debug_axis_ib_switch2_axi_s_6),
  .araddr_axi4_m        (araddr_debug_axis_ib_switch2_axi_s_6),
  .arlen_axi4_m         (arlen_debug_axis_ib_switch2_axi_s_6),
  .arsize_axi4_m        (arsize_debug_axis_ib_switch2_axi_s_6),
  .arburst_axi4_m       (arburst_debug_axis_ib_switch2_axi_s_6),
  .arlock_axi4_m        (arlock_debug_axis_ib_switch2_axi_s_6),
  .arcache_axi4_m       (arcache_debug_axis_ib_switch2_axi_s_6),
  .arprot_axi4_m        (arprot_debug_axis_ib_switch2_axi_s_6),
  .arvalid_axi4_m       (arvalid_debug_axis_ib_switch2_axi_s_6),
  .arvalid_vect_axi4_m  (arvalid_vect_debug_axis_ib_switch2_axi_s_6),
  .arready_axi4_m       (arready_debug_axis_ib_switch2_axi_s_6),
  .rid_axi4_m           (rid_debug_axis_ib_switch2_axi_s_6),
  .rdata_axi4_m         (rdata_debug_axis_ib_switch2_axi_s_6),
  .rresp_axi4_m         (rresp_debug_axis_ib_switch2_axi_s_6),
  .rlast_axi4_m         (rlast_debug_axis_ib_switch2_axi_s_6),
  .rvalid_axi4_m        (rvalid_debug_axis_ib_switch2_axi_s_6),
  .rready_axi4_m        (rready_debug_axis_ib_switch2_axi_s_6),
  .awuser_axi4_m        (awuser_debug_axis_ib_switch2_axi_s_6),
  .buser_axi4_m         (buser_debug_axis_ib_switch2_axi_s_6),
  .aruser_axi4_m        (aruser_debug_axis_ib_switch2_axi_s_6),
  .ruser_axi4_m         (ruser_debug_axis_ib_switch2_axi_s_6),
  .awqv_axi4_m          (awqv_debug_axis_ib_switch2_axi_s_6),
  .arqv_axi4_m          (arqv_debug_axis_ib_switch2_axi_s_6),
  .aw_data              (aw_data_debug_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_debug_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_debug_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_debug_axis_ib_int),
  .b_data               (b_data_debug_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_debug_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_debug_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_debug_axis_ib_int),
  .ar_data              (ar_data_debug_axis_ib_int),
  .ar_valid             (ar_valid_debug_axis_ib_int),
  .ar_ready             (ar_ready_debug_axis_ib_int),
  .r_data               (r_data_debug_axis_ib_int),
  .r_valid              (r_valid_debug_axis_ib_int),
  .r_ready              (r_ready_debug_axis_ib_int),
  .w_data               (w_data_debug_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_debug_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_debug_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_debug_axis_ib_int)
);


nic400_ib_debug_axis_ib_slave_domain_sse710_main     u_ib_debug_axis_ib_s (
  .apbs_req             (preq_debug_axis_ib_apb_int),
  .apbs_ack             (pack_debug_axis_ib_apb_int),
  .apbs_fwd_data        (pfwdpayld_debug_axis_ib_apb_int),
  .apbs_rev_data        (prevpayld_debug_axis_ib_apb_int),
  .paddrm               (paddr_debug_axis_apb),
  .pwdatam              (pwdata_debug_axis_apb),
  .pwritem              (pwrite_debug_axis_apb),
  .penablem             (penable_debug_axis_apb),
  .pselm                (pselx_debug_axis_apb),
  .prdatam              (prdata_debug_axis_apb),
  .pslverrm             (pslverr_debug_axis_apb),
  .preadym              (pready_debug_axis_apb),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .awid_axi4_s          (awid_debug_axis_debug_axis_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_debug_axis_debug_axis_ib_axi4_s),
  .awlen_axi4_s         (awlen_debug_axis_debug_axis_ib_axi4_s),
  .awsize_axi4_s        (awsize_debug_axis_debug_axis_ib_axi4_s),
  .awburst_axi4_s       (awburst_debug_axis_debug_axis_ib_axi4_s),
  .awlock_axi4_s        (awlock_debug_axis_debug_axis_ib_axi4_s),
  .awcache_axi4_s       (awcache_debug_axis_debug_axis_ib_axi4_s),
  .awprot_axi4_s        (awprot_debug_axis_debug_axis_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_debug_axis_debug_axis_ib_axi4_s),
  .awvalid_vect_axi4_s  (awvalid_vect_debug_axis_debug_axis_ib_axi4_s),
  .awready_axi4_s       (awready_debug_axis_debug_axis_ib_axi4_s),
  .wdata_axi4_s         (wdata_debug_axis_debug_axis_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_debug_axis_debug_axis_ib_axi4_s),
  .wlast_axi4_s         (wlast_debug_axis_debug_axis_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_debug_axis_debug_axis_ib_axi4_s),
  .wready_axi4_s        (wready_debug_axis_debug_axis_ib_axi4_s),
  .bid_axi4_s           (bid_debug_axis_debug_axis_ib_axi4_s),
  .bresp_axi4_s         (bresp_debug_axis_debug_axis_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_debug_axis_debug_axis_ib_axi4_s),
  .bready_axi4_s        (bready_debug_axis_debug_axis_ib_axi4_s),
  .arid_axi4_s          (arid_debug_axis_debug_axis_ib_axi4_s),
  .araddr_axi4_s        (araddr_debug_axis_debug_axis_ib_axi4_s),
  .arlen_axi4_s         (arlen_debug_axis_debug_axis_ib_axi4_s),
  .arsize_axi4_s        (arsize_debug_axis_debug_axis_ib_axi4_s),
  .arburst_axi4_s       (arburst_debug_axis_debug_axis_ib_axi4_s),
  .arlock_axi4_s        (arlock_debug_axis_debug_axis_ib_axi4_s),
  .arcache_axi4_s       (arcache_debug_axis_debug_axis_ib_axi4_s),
  .arprot_axi4_s        (arprot_debug_axis_debug_axis_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_debug_axis_debug_axis_ib_axi4_s),
  .arvalid_vect_axi4_s  (arvalid_vect_debug_axis_debug_axis_ib_axi4_s),
  .arready_axi4_s       (arready_debug_axis_debug_axis_ib_axi4_s),
  .rid_axi4_s           (rid_debug_axis_debug_axis_ib_axi4_s),
  .rdata_axi4_s         (rdata_debug_axis_debug_axis_ib_axi4_s),
  .rresp_axi4_s         (rresp_debug_axis_debug_axis_ib_axi4_s),
  .rlast_axi4_s         (rlast_debug_axis_debug_axis_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_debug_axis_debug_axis_ib_axi4_s),
  .rready_axi4_s        (rready_debug_axis_debug_axis_ib_axi4_s),
  .awuser_axi4_s        (awuser_debug_axis_debug_axis_ib_axi4_s),
  .buser_axi4_s         (buser_debug_axis_debug_axis_ib_axi4_s),
  .aruser_axi4_s        (aruser_debug_axis_debug_axis_ib_axi4_s),
  .ruser_axi4_s         (ruser_debug_axis_debug_axis_ib_axi4_s),
  .aw_data              (aw_data_debug_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_debug_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_debug_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_debug_axis_ib_int),
  .b_data               (b_data_debug_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_debug_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_debug_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_debug_axis_ib_int),
  .ar_data              (ar_data_debug_axis_ib_int),
  .ar_valid             (ar_valid_debug_axis_ib_int),
  .ar_ready             (ar_ready_debug_axis_ib_int),
  .r_data               (r_data_debug_axis_ib_int),
  .r_valid              (r_valid_debug_axis_ib_int),
  .r_ready              (r_ready_debug_axis_ib_int),
  .w_data               (w_data_debug_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_debug_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_debug_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_debug_axis_ib_int)
);


nic400_ib_expmstr0_axim_ib_master_domain_sse710_main     u_ib_expmstr0_axim_ib_m (
  .awid_axi4_m          (awid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awaddr_axi4_m        (awaddr_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awlen_axi4_m         (awlen_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awsize_axi4_m        (awsize_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awburst_axi4_m       (awburst_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awlock_axi4_m        (awlock_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awcache_axi4_m       (awcache_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awprot_axi4_m        (awprot_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awvalid_axi4_m       (awvalid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awready_axi4_m       (awready_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .wdata_axi4_m         (wdata_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .wstrb_axi4_m         (wstrb_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .wlast_axi4_m         (wlast_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .wvalid_axi4_m        (wvalid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .wready_axi4_m        (wready_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .bid_axi4_m           (bid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .bresp_axi4_m         (bresp_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .bvalid_axi4_m        (bvalid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .bready_axi4_m        (bready_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arid_axi4_m          (arid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .araddr_axi4_m        (araddr_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arlen_axi4_m         (arlen_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arsize_axi4_m        (arsize_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arburst_axi4_m       (arburst_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arlock_axi4_m        (arlock_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arcache_axi4_m       (arcache_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arprot_axi4_m        (arprot_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arvalid_axi4_m       (arvalid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arready_axi4_m       (arready_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .rid_axi4_m           (rid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .rdata_axi4_m         (rdata_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .rresp_axi4_m         (rresp_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .rlast_axi4_m         (rlast_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .rvalid_axi4_m        (rvalid_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .rready_axi4_m        (rready_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awuser_axi4_m        (awuser_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .buser_axi4_m         (buser_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .aruser_axi4_m        (aruser_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .ruser_axi4_m         (ruser_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .awqv_axi4_m          (awqv_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .arqv_axi4_m          (arqv_expmstr0_axim_ib_expmstr0_axim_expmstr0_axim_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_expmstr0_axim_ib_int),
  .aw_valid             (aw_valid_expmstr0_axim_ib_int),
  .aw_ready             (aw_ready_expmstr0_axim_ib_int),
  .b_data               (b_data_expmstr0_axim_ib_int),
  .b_valid              (b_valid_expmstr0_axim_ib_int),
  .b_ready              (b_ready_expmstr0_axim_ib_int),
  .ar_data              (ar_data_expmstr0_axim_ib_int),
  .ar_valid             (ar_valid_expmstr0_axim_ib_int),
  .ar_ready             (ar_ready_expmstr0_axim_ib_int),
  .r_data               (r_data_expmstr0_axim_ib_int),
  .r_valid              (r_valid_expmstr0_axim_ib_int),
  .r_ready              (r_ready_expmstr0_axim_ib_int),
  .w_data               (w_data_expmstr0_axim_ib_int),
  .w_valid              (w_valid_expmstr0_axim_ib_int),
  .w_ready              (w_ready_expmstr0_axim_ib_int)
);


nic400_ib_expmstr0_axim_ib_slave_domain_sse710_main     u_ib_expmstr0_axim_ib_s (
  .awid_axi4_s          (awid_switch2_expmstr0_axim_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_switch2_expmstr0_axim_ib_axi4_s),
  .awlen_axi4_s         (awlen_switch2_expmstr0_axim_ib_axi4_s),
  .awsize_axi4_s        (awsize_switch2_expmstr0_axim_ib_axi4_s),
  .awburst_axi4_s       (awburst_switch2_expmstr0_axim_ib_axi4_s),
  .awlock_axi4_s        (awlock_switch2_expmstr0_axim_ib_axi4_s),
  .awcache_axi4_s       (awcache_switch2_expmstr0_axim_ib_axi4_s),
  .awprot_axi4_s        (awprot_switch2_expmstr0_axim_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_switch2_expmstr0_axim_ib_axi4_s),
  .awready_axi4_s       (awready_switch2_expmstr0_axim_ib_axi4_s),
  .wdata_axi4_s         (wdata_switch2_expmstr0_axim_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_switch2_expmstr0_axim_ib_axi4_s),
  .wlast_axi4_s         (wlast_switch2_expmstr0_axim_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_switch2_expmstr0_axim_ib_axi4_s),
  .wready_axi4_s        (wready_switch2_expmstr0_axim_ib_axi4_s),
  .bid_axi4_s           (bid_switch2_expmstr0_axim_ib_axi4_s),
  .bresp_axi4_s         (bresp_switch2_expmstr0_axim_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_switch2_expmstr0_axim_ib_axi4_s),
  .bready_axi4_s        (bready_switch2_expmstr0_axim_ib_axi4_s),
  .arid_axi4_s          (arid_switch2_expmstr0_axim_ib_axi4_s),
  .araddr_axi4_s        (araddr_switch2_expmstr0_axim_ib_axi4_s),
  .arlen_axi4_s         (arlen_switch2_expmstr0_axim_ib_axi4_s),
  .arsize_axi4_s        (arsize_switch2_expmstr0_axim_ib_axi4_s),
  .arburst_axi4_s       (arburst_switch2_expmstr0_axim_ib_axi4_s),
  .arlock_axi4_s        (arlock_switch2_expmstr0_axim_ib_axi4_s),
  .arcache_axi4_s       (arcache_switch2_expmstr0_axim_ib_axi4_s),
  .arprot_axi4_s        (arprot_switch2_expmstr0_axim_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_switch2_expmstr0_axim_ib_axi4_s),
  .arready_axi4_s       (arready_switch2_expmstr0_axim_ib_axi4_s),
  .rid_axi4_s           (rid_switch2_expmstr0_axim_ib_axi4_s),
  .rdata_axi4_s         (rdata_switch2_expmstr0_axim_ib_axi4_s),
  .rresp_axi4_s         (rresp_switch2_expmstr0_axim_ib_axi4_s),
  .rlast_axi4_s         (rlast_switch2_expmstr0_axim_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_switch2_expmstr0_axim_ib_axi4_s),
  .rready_axi4_s        (rready_switch2_expmstr0_axim_ib_axi4_s),
  .awuser_axi4_s        (awuser_switch2_expmstr0_axim_ib_axi4_s),
  .buser_axi4_s         (buser_switch2_expmstr0_axim_ib_axi4_s),
  .aruser_axi4_s        (aruser_switch2_expmstr0_axim_ib_axi4_s),
  .ruser_axi4_s         (ruser_switch2_expmstr0_axim_ib_axi4_s),
  .awqv_axi4_s          (awqv_switch2_expmstr0_axim_ib_axi4_s),
  .arqv_axi4_s          (arqv_switch2_expmstr0_axim_ib_axi4_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_expmstr0_axim_ib_int),
  .aw_valid             (aw_valid_expmstr0_axim_ib_int),
  .aw_ready             (aw_ready_expmstr0_axim_ib_int),
  .b_data               (b_data_expmstr0_axim_ib_int),
  .b_valid              (b_valid_expmstr0_axim_ib_int),
  .b_ready              (b_ready_expmstr0_axim_ib_int),
  .ar_data              (ar_data_expmstr0_axim_ib_int),
  .ar_valid             (ar_valid_expmstr0_axim_ib_int),
  .ar_ready             (ar_ready_expmstr0_axim_ib_int),
  .r_data               (r_data_expmstr0_axim_ib_int),
  .r_valid              (r_valid_expmstr0_axim_ib_int),
  .r_ready              (r_ready_expmstr0_axim_ib_int),
  .w_data               (w_data_expmstr0_axim_ib_int),
  .w_valid              (w_valid_expmstr0_axim_ib_int),
  .w_ready              (w_ready_expmstr0_axim_ib_int)
);


nic400_ib_expmstr1_axim_ib_master_domain_sse710_main     u_ib_expmstr1_axim_ib_m (
  .awid_axi4_m          (awid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awaddr_axi4_m        (awaddr_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awlen_axi4_m         (awlen_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awsize_axi4_m        (awsize_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awburst_axi4_m       (awburst_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awlock_axi4_m        (awlock_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awcache_axi4_m       (awcache_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awprot_axi4_m        (awprot_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awvalid_axi4_m       (awvalid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awready_axi4_m       (awready_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .wdata_axi4_m         (wdata_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .wstrb_axi4_m         (wstrb_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .wlast_axi4_m         (wlast_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .wvalid_axi4_m        (wvalid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .wready_axi4_m        (wready_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .bid_axi4_m           (bid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .bresp_axi4_m         (bresp_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .bvalid_axi4_m        (bvalid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .bready_axi4_m        (bready_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arid_axi4_m          (arid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .araddr_axi4_m        (araddr_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arlen_axi4_m         (arlen_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arsize_axi4_m        (arsize_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arburst_axi4_m       (arburst_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arlock_axi4_m        (arlock_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arcache_axi4_m       (arcache_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arprot_axi4_m        (arprot_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arvalid_axi4_m       (arvalid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arready_axi4_m       (arready_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .rid_axi4_m           (rid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .rdata_axi4_m         (rdata_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .rresp_axi4_m         (rresp_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .rlast_axi4_m         (rlast_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .rvalid_axi4_m        (rvalid_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .rready_axi4_m        (rready_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awuser_axi4_m        (awuser_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .buser_axi4_m         (buser_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .aruser_axi4_m        (aruser_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .ruser_axi4_m         (ruser_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .awqv_axi4_m          (awqv_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .arqv_axi4_m          (arqv_expmstr1_axim_ib_expmstr1_axim_expmstr1_axim_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_expmstr1_axim_ib_int),
  .aw_valid             (aw_valid_expmstr1_axim_ib_int),
  .aw_ready             (aw_ready_expmstr1_axim_ib_int),
  .b_data               (b_data_expmstr1_axim_ib_int),
  .b_valid              (b_valid_expmstr1_axim_ib_int),
  .b_ready              (b_ready_expmstr1_axim_ib_int),
  .ar_data              (ar_data_expmstr1_axim_ib_int),
  .ar_valid             (ar_valid_expmstr1_axim_ib_int),
  .ar_ready             (ar_ready_expmstr1_axim_ib_int),
  .r_data               (r_data_expmstr1_axim_ib_int),
  .r_valid              (r_valid_expmstr1_axim_ib_int),
  .r_ready              (r_ready_expmstr1_axim_ib_int),
  .w_data               (w_data_expmstr1_axim_ib_int),
  .w_valid              (w_valid_expmstr1_axim_ib_int),
  .w_ready              (w_ready_expmstr1_axim_ib_int)
);


nic400_ib_expmstr1_axim_ib_slave_domain_sse710_main     u_ib_expmstr1_axim_ib_s (
  .awid_axi4_s          (awid_switch2_expmstr1_axim_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_switch2_expmstr1_axim_ib_axi4_s),
  .awlen_axi4_s         (awlen_switch2_expmstr1_axim_ib_axi4_s),
  .awsize_axi4_s        (awsize_switch2_expmstr1_axim_ib_axi4_s),
  .awburst_axi4_s       (awburst_switch2_expmstr1_axim_ib_axi4_s),
  .awlock_axi4_s        (awlock_switch2_expmstr1_axim_ib_axi4_s),
  .awcache_axi4_s       (awcache_switch2_expmstr1_axim_ib_axi4_s),
  .awprot_axi4_s        (awprot_switch2_expmstr1_axim_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_switch2_expmstr1_axim_ib_axi4_s),
  .awready_axi4_s       (awready_switch2_expmstr1_axim_ib_axi4_s),
  .wdata_axi4_s         (wdata_switch2_expmstr1_axim_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_switch2_expmstr1_axim_ib_axi4_s),
  .wlast_axi4_s         (wlast_switch2_expmstr1_axim_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_switch2_expmstr1_axim_ib_axi4_s),
  .wready_axi4_s        (wready_switch2_expmstr1_axim_ib_axi4_s),
  .bid_axi4_s           (bid_switch2_expmstr1_axim_ib_axi4_s),
  .bresp_axi4_s         (bresp_switch2_expmstr1_axim_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_switch2_expmstr1_axim_ib_axi4_s),
  .bready_axi4_s        (bready_switch2_expmstr1_axim_ib_axi4_s),
  .arid_axi4_s          (arid_switch2_expmstr1_axim_ib_axi4_s),
  .araddr_axi4_s        (araddr_switch2_expmstr1_axim_ib_axi4_s),
  .arlen_axi4_s         (arlen_switch2_expmstr1_axim_ib_axi4_s),
  .arsize_axi4_s        (arsize_switch2_expmstr1_axim_ib_axi4_s),
  .arburst_axi4_s       (arburst_switch2_expmstr1_axim_ib_axi4_s),
  .arlock_axi4_s        (arlock_switch2_expmstr1_axim_ib_axi4_s),
  .arcache_axi4_s       (arcache_switch2_expmstr1_axim_ib_axi4_s),
  .arprot_axi4_s        (arprot_switch2_expmstr1_axim_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_switch2_expmstr1_axim_ib_axi4_s),
  .arready_axi4_s       (arready_switch2_expmstr1_axim_ib_axi4_s),
  .rid_axi4_s           (rid_switch2_expmstr1_axim_ib_axi4_s),
  .rdata_axi4_s         (rdata_switch2_expmstr1_axim_ib_axi4_s),
  .rresp_axi4_s         (rresp_switch2_expmstr1_axim_ib_axi4_s),
  .rlast_axi4_s         (rlast_switch2_expmstr1_axim_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_switch2_expmstr1_axim_ib_axi4_s),
  .rready_axi4_s        (rready_switch2_expmstr1_axim_ib_axi4_s),
  .awuser_axi4_s        (awuser_switch2_expmstr1_axim_ib_axi4_s),
  .buser_axi4_s         (buser_switch2_expmstr1_axim_ib_axi4_s),
  .aruser_axi4_s        (aruser_switch2_expmstr1_axim_ib_axi4_s),
  .ruser_axi4_s         (ruser_switch2_expmstr1_axim_ib_axi4_s),
  .awqv_axi4_s          (awqv_switch2_expmstr1_axim_ib_axi4_s),
  .arqv_axi4_s          (arqv_switch2_expmstr1_axim_ib_axi4_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_expmstr1_axim_ib_int),
  .aw_valid             (aw_valid_expmstr1_axim_ib_int),
  .aw_ready             (aw_ready_expmstr1_axim_ib_int),
  .b_data               (b_data_expmstr1_axim_ib_int),
  .b_valid              (b_valid_expmstr1_axim_ib_int),
  .b_ready              (b_ready_expmstr1_axim_ib_int),
  .ar_data              (ar_data_expmstr1_axim_ib_int),
  .ar_valid             (ar_valid_expmstr1_axim_ib_int),
  .ar_ready             (ar_ready_expmstr1_axim_ib_int),
  .r_data               (r_data_expmstr1_axim_ib_int),
  .r_valid              (r_valid_expmstr1_axim_ib_int),
  .r_ready              (r_ready_expmstr1_axim_ib_int),
  .w_data               (w_data_expmstr1_axim_ib_int),
  .w_valid              (w_valid_expmstr1_axim_ib_int),
  .w_ready              (w_ready_expmstr1_axim_ib_int)
);


nic400_ib_expslv0_axis_ib_master_domain_sse710_main     u_ib_expslv0_axis_ib_m (
  .awid_axi4_m          (awid_expslv0_axis_ib_switch2_axi_s_4),
  .awaddr_axi4_m        (awaddr_expslv0_axis_ib_switch2_axi_s_4),
  .awlen_axi4_m         (awlen_expslv0_axis_ib_switch2_axi_s_4),
  .awsize_axi4_m        (awsize_expslv0_axis_ib_switch2_axi_s_4),
  .awburst_axi4_m       (awburst_expslv0_axis_ib_switch2_axi_s_4),
  .awlock_axi4_m        (awlock_expslv0_axis_ib_switch2_axi_s_4),
  .awcache_axi4_m       (awcache_expslv0_axis_ib_switch2_axi_s_4),
  .awprot_axi4_m        (awprot_expslv0_axis_ib_switch2_axi_s_4),
  .awvalid_axi4_m       (awvalid_expslv0_axis_ib_switch2_axi_s_4),
  .awvalid_vect_axi4_m  (awvalid_vect_expslv0_axis_ib_switch2_axi_s_4),
  .awready_axi4_m       (awready_expslv0_axis_ib_switch2_axi_s_4),
  .wdata_axi4_m         (wdata_expslv0_axis_ib_switch2_axi_s_4),
  .wstrb_axi4_m         (wstrb_expslv0_axis_ib_switch2_axi_s_4),
  .wlast_axi4_m         (wlast_expslv0_axis_ib_switch2_axi_s_4),
  .wvalid_axi4_m        (wvalid_expslv0_axis_ib_switch2_axi_s_4),
  .wready_axi4_m        (wready_expslv0_axis_ib_switch2_axi_s_4),
  .bid_axi4_m           (bid_expslv0_axis_ib_switch2_axi_s_4),
  .bresp_axi4_m         (bresp_expslv0_axis_ib_switch2_axi_s_4),
  .bvalid_axi4_m        (bvalid_expslv0_axis_ib_switch2_axi_s_4),
  .bready_axi4_m        (bready_expslv0_axis_ib_switch2_axi_s_4),
  .arid_axi4_m          (arid_expslv0_axis_ib_switch2_axi_s_4),
  .araddr_axi4_m        (araddr_expslv0_axis_ib_switch2_axi_s_4),
  .arlen_axi4_m         (arlen_expslv0_axis_ib_switch2_axi_s_4),
  .arsize_axi4_m        (arsize_expslv0_axis_ib_switch2_axi_s_4),
  .arburst_axi4_m       (arburst_expslv0_axis_ib_switch2_axi_s_4),
  .arlock_axi4_m        (arlock_expslv0_axis_ib_switch2_axi_s_4),
  .arcache_axi4_m       (arcache_expslv0_axis_ib_switch2_axi_s_4),
  .arprot_axi4_m        (arprot_expslv0_axis_ib_switch2_axi_s_4),
  .arvalid_axi4_m       (arvalid_expslv0_axis_ib_switch2_axi_s_4),
  .arvalid_vect_axi4_m  (arvalid_vect_expslv0_axis_ib_switch2_axi_s_4),
  .arready_axi4_m       (arready_expslv0_axis_ib_switch2_axi_s_4),
  .rid_axi4_m           (rid_expslv0_axis_ib_switch2_axi_s_4),
  .rdata_axi4_m         (rdata_expslv0_axis_ib_switch2_axi_s_4),
  .rresp_axi4_m         (rresp_expslv0_axis_ib_switch2_axi_s_4),
  .rlast_axi4_m         (rlast_expslv0_axis_ib_switch2_axi_s_4),
  .rvalid_axi4_m        (rvalid_expslv0_axis_ib_switch2_axi_s_4),
  .rready_axi4_m        (rready_expslv0_axis_ib_switch2_axi_s_4),
  .awuser_axi4_m        (awuser_expslv0_axis_ib_switch2_axi_s_4),
  .buser_axi4_m         (buser_expslv0_axis_ib_switch2_axi_s_4),
  .aruser_axi4_m        (aruser_expslv0_axis_ib_switch2_axi_s_4),
  .ruser_axi4_m         (ruser_expslv0_axis_ib_switch2_axi_s_4),
  .awqv_axi4_m          (awqv_expslv0_axis_ib_switch2_axi_s_4),
  .arqv_axi4_m          (arqv_expslv0_axis_ib_switch2_axi_s_4),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_expslv0_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_expslv0_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_expslv0_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_expslv0_axis_ib_int),
  .b_data               (b_data_expslv0_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_expslv0_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_expslv0_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_expslv0_axis_ib_int),
  .ar_data              (ar_data_expslv0_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_expslv0_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_expslv0_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_expslv0_axis_ib_int),
  .r_data               (r_data_expslv0_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_expslv0_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_expslv0_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_expslv0_axis_ib_int),
  .w_data               (w_data_expslv0_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_expslv0_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_expslv0_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_expslv0_axis_ib_int)
);


nic400_ib_expslv0_axis_ib_slave_domain_sse710_main     u_ib_expslv0_axis_ib_s (
  .awid_axi4_s          (awid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awlen_axi4_s         (awlen_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awsize_axi4_s        (awsize_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awburst_axi4_s       (awburst_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awlock_axi4_s        (awlock_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awcache_axi4_s       (awcache_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awprot_axi4_s        (awprot_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awvalid_vect_axi4_s  (awvalid_vect_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awready_axi4_s       (awready_expslv0_axis_expslv0_axis_ib_axi4_s),
  .wdata_axi4_s         (wdata_expslv0_axis_expslv0_axis_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_expslv0_axis_expslv0_axis_ib_axi4_s),
  .wlast_axi4_s         (wlast_expslv0_axis_expslv0_axis_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .wready_axi4_s        (wready_expslv0_axis_expslv0_axis_ib_axi4_s),
  .bid_axi4_s           (bid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .bresp_axi4_s         (bresp_expslv0_axis_expslv0_axis_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .bready_axi4_s        (bready_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arid_axi4_s          (arid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .araddr_axi4_s        (araddr_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arlen_axi4_s         (arlen_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arsize_axi4_s        (arsize_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arburst_axi4_s       (arburst_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arlock_axi4_s        (arlock_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arcache_axi4_s       (arcache_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arprot_axi4_s        (arprot_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arvalid_vect_axi4_s  (arvalid_vect_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arready_axi4_s       (arready_expslv0_axis_expslv0_axis_ib_axi4_s),
  .rid_axi4_s           (rid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .rdata_axi4_s         (rdata_expslv0_axis_expslv0_axis_ib_axi4_s),
  .rresp_axi4_s         (rresp_expslv0_axis_expslv0_axis_ib_axi4_s),
  .rlast_axi4_s         (rlast_expslv0_axis_expslv0_axis_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_expslv0_axis_expslv0_axis_ib_axi4_s),
  .rready_axi4_s        (rready_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awuser_axi4_s        (awuser_expslv0_axis_expslv0_axis_ib_axi4_s),
  .buser_axi4_s         (buser_expslv0_axis_expslv0_axis_ib_axi4_s),
  .aruser_axi4_s        (aruser_expslv0_axis_expslv0_axis_ib_axi4_s),
  .ruser_axi4_s         (ruser_expslv0_axis_expslv0_axis_ib_axi4_s),
  .awqv_axi4_s          (awqv_expslv0_axis_expslv0_axis_ib_axi4_s),
  .arqv_axi4_s          (arqv_expslv0_axis_expslv0_axis_ib_axi4_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_expslv0_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_expslv0_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_expslv0_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_expslv0_axis_ib_int),
  .b_data               (b_data_expslv0_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_expslv0_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_expslv0_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_expslv0_axis_ib_int),
  .ar_data              (ar_data_expslv0_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_expslv0_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_expslv0_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_expslv0_axis_ib_int),
  .r_data               (r_data_expslv0_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_expslv0_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_expslv0_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_expslv0_axis_ib_int),
  .w_data               (w_data_expslv0_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_expslv0_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_expslv0_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_expslv0_axis_ib_int)
);


nic400_ib_expslv1_axis_ib_master_domain_sse710_main     u_ib_expslv1_axis_ib_m (
  .awid_axi4_m          (awid_expslv1_axis_ib_switch2_axi_s_5),
  .awaddr_axi4_m        (awaddr_expslv1_axis_ib_switch2_axi_s_5),
  .awlen_axi4_m         (awlen_expslv1_axis_ib_switch2_axi_s_5),
  .awsize_axi4_m        (awsize_expslv1_axis_ib_switch2_axi_s_5),
  .awburst_axi4_m       (awburst_expslv1_axis_ib_switch2_axi_s_5),
  .awlock_axi4_m        (awlock_expslv1_axis_ib_switch2_axi_s_5),
  .awcache_axi4_m       (awcache_expslv1_axis_ib_switch2_axi_s_5),
  .awprot_axi4_m        (awprot_expslv1_axis_ib_switch2_axi_s_5),
  .awvalid_axi4_m       (awvalid_expslv1_axis_ib_switch2_axi_s_5),
  .awvalid_vect_axi4_m  (awvalid_vect_expslv1_axis_ib_switch2_axi_s_5),
  .awready_axi4_m       (awready_expslv1_axis_ib_switch2_axi_s_5),
  .wdata_axi4_m         (wdata_expslv1_axis_ib_switch2_axi_s_5),
  .wstrb_axi4_m         (wstrb_expslv1_axis_ib_switch2_axi_s_5),
  .wlast_axi4_m         (wlast_expslv1_axis_ib_switch2_axi_s_5),
  .wvalid_axi4_m        (wvalid_expslv1_axis_ib_switch2_axi_s_5),
  .wready_axi4_m        (wready_expslv1_axis_ib_switch2_axi_s_5),
  .bid_axi4_m           (bid_expslv1_axis_ib_switch2_axi_s_5),
  .bresp_axi4_m         (bresp_expslv1_axis_ib_switch2_axi_s_5),
  .bvalid_axi4_m        (bvalid_expslv1_axis_ib_switch2_axi_s_5),
  .bready_axi4_m        (bready_expslv1_axis_ib_switch2_axi_s_5),
  .arid_axi4_m          (arid_expslv1_axis_ib_switch2_axi_s_5),
  .araddr_axi4_m        (araddr_expslv1_axis_ib_switch2_axi_s_5),
  .arlen_axi4_m         (arlen_expslv1_axis_ib_switch2_axi_s_5),
  .arsize_axi4_m        (arsize_expslv1_axis_ib_switch2_axi_s_5),
  .arburst_axi4_m       (arburst_expslv1_axis_ib_switch2_axi_s_5),
  .arlock_axi4_m        (arlock_expslv1_axis_ib_switch2_axi_s_5),
  .arcache_axi4_m       (arcache_expslv1_axis_ib_switch2_axi_s_5),
  .arprot_axi4_m        (arprot_expslv1_axis_ib_switch2_axi_s_5),
  .arvalid_axi4_m       (arvalid_expslv1_axis_ib_switch2_axi_s_5),
  .arvalid_vect_axi4_m  (arvalid_vect_expslv1_axis_ib_switch2_axi_s_5),
  .arready_axi4_m       (arready_expslv1_axis_ib_switch2_axi_s_5),
  .rid_axi4_m           (rid_expslv1_axis_ib_switch2_axi_s_5),
  .rdata_axi4_m         (rdata_expslv1_axis_ib_switch2_axi_s_5),
  .rresp_axi4_m         (rresp_expslv1_axis_ib_switch2_axi_s_5),
  .rlast_axi4_m         (rlast_expslv1_axis_ib_switch2_axi_s_5),
  .rvalid_axi4_m        (rvalid_expslv1_axis_ib_switch2_axi_s_5),
  .rready_axi4_m        (rready_expslv1_axis_ib_switch2_axi_s_5),
  .awuser_axi4_m        (awuser_expslv1_axis_ib_switch2_axi_s_5),
  .buser_axi4_m         (buser_expslv1_axis_ib_switch2_axi_s_5),
  .aruser_axi4_m        (aruser_expslv1_axis_ib_switch2_axi_s_5),
  .ruser_axi4_m         (ruser_expslv1_axis_ib_switch2_axi_s_5),
  .awqv_axi4_m          (awqv_expslv1_axis_ib_switch2_axi_s_5),
  .arqv_axi4_m          (arqv_expslv1_axis_ib_switch2_axi_s_5),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_expslv1_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_expslv1_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_expslv1_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_expslv1_axis_ib_int),
  .b_data               (b_data_expslv1_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_expslv1_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_expslv1_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_expslv1_axis_ib_int),
  .ar_data              (ar_data_expslv1_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_expslv1_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_expslv1_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_expslv1_axis_ib_int),
  .r_data               (r_data_expslv1_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_expslv1_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_expslv1_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_expslv1_axis_ib_int),
  .w_data               (w_data_expslv1_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_expslv1_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_expslv1_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_expslv1_axis_ib_int)
);


nic400_ib_expslv1_axis_ib_slave_domain_sse710_main     u_ib_expslv1_axis_ib_s (
  .awid_axi4_s          (awid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awlen_axi4_s         (awlen_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awsize_axi4_s        (awsize_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awburst_axi4_s       (awburst_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awlock_axi4_s        (awlock_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awcache_axi4_s       (awcache_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awprot_axi4_s        (awprot_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awvalid_vect_axi4_s  (awvalid_vect_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awready_axi4_s       (awready_expslv1_axis_expslv1_axis_ib_axi4_s),
  .wdata_axi4_s         (wdata_expslv1_axis_expslv1_axis_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_expslv1_axis_expslv1_axis_ib_axi4_s),
  .wlast_axi4_s         (wlast_expslv1_axis_expslv1_axis_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .wready_axi4_s        (wready_expslv1_axis_expslv1_axis_ib_axi4_s),
  .bid_axi4_s           (bid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .bresp_axi4_s         (bresp_expslv1_axis_expslv1_axis_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .bready_axi4_s        (bready_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arid_axi4_s          (arid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .araddr_axi4_s        (araddr_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arlen_axi4_s         (arlen_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arsize_axi4_s        (arsize_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arburst_axi4_s       (arburst_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arlock_axi4_s        (arlock_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arcache_axi4_s       (arcache_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arprot_axi4_s        (arprot_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arvalid_vect_axi4_s  (arvalid_vect_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arready_axi4_s       (arready_expslv1_axis_expslv1_axis_ib_axi4_s),
  .rid_axi4_s           (rid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .rdata_axi4_s         (rdata_expslv1_axis_expslv1_axis_ib_axi4_s),
  .rresp_axi4_s         (rresp_expslv1_axis_expslv1_axis_ib_axi4_s),
  .rlast_axi4_s         (rlast_expslv1_axis_expslv1_axis_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_expslv1_axis_expslv1_axis_ib_axi4_s),
  .rready_axi4_s        (rready_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awuser_axi4_s        (awuser_expslv1_axis_expslv1_axis_ib_axi4_s),
  .buser_axi4_s         (buser_expslv1_axis_expslv1_axis_ib_axi4_s),
  .aruser_axi4_s        (aruser_expslv1_axis_expslv1_axis_ib_axi4_s),
  .ruser_axi4_s         (ruser_expslv1_axis_expslv1_axis_ib_axi4_s),
  .awqv_axi4_s          (awqv_expslv1_axis_expslv1_axis_ib_axi4_s),
  .arqv_axi4_s          (arqv_expslv1_axis_expslv1_axis_ib_axi4_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_expslv1_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_expslv1_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_expslv1_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_expslv1_axis_ib_int),
  .b_data               (b_data_expslv1_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_expslv1_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_expslv1_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_expslv1_axis_ib_int),
  .ar_data              (ar_data_expslv1_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_expslv1_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_expslv1_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_expslv1_axis_ib_int),
  .r_data               (r_data_expslv1_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_expslv1_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_expslv1_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_expslv1_axis_ib_int),
  .w_data               (w_data_expslv1_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_expslv1_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_expslv1_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_expslv1_axis_ib_int)
);


nic400_ib_extsys0_axis_ib_master_domain_sse710_main     u_ib_extsys0_axis_ib_m (
  .paddr                (paddr_extsys0_axis_ib_apb),
  .pwdata               (pwdata_extsys0_axis_ib_apb),
  .pwrite               (pwrite_extsys0_axis_ib_apb),
  .penable              (penable_extsys0_axis_ib_apb),
  .psel                 (pselx_extsys0_axis_ib_apb),
  .prdata               (prdata_extsys0_axis_ib_apb),
  .pslverr              (pslverr_extsys0_axis_ib_apb),
  .pready               (pready_extsys0_axis_ib_apb),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .apbm_req             (preq_extsys0_axis_ib_apb_int),
  .apbm_ack             (pack_extsys0_axis_ib_apb_int),
  .apbm_fwd_data        (pfwdpayld_extsys0_axis_ib_apb_int),
  .apbm_rev_data        (prevpayld_extsys0_axis_ib_apb_int),
  .awid_axi4_m          (awid_extsys0_axis_ib_switch2_axi_s_0),
  .awaddr_axi4_m        (awaddr_extsys0_axis_ib_switch2_axi_s_0),
  .awlen_axi4_m         (awlen_extsys0_axis_ib_switch2_axi_s_0),
  .awsize_axi4_m        (awsize_extsys0_axis_ib_switch2_axi_s_0),
  .awburst_axi4_m       (awburst_extsys0_axis_ib_switch2_axi_s_0),
  .awlock_axi4_m        (awlock_extsys0_axis_ib_switch2_axi_s_0),
  .awcache_axi4_m       (awcache_extsys0_axis_ib_switch2_axi_s_0),
  .awprot_axi4_m        (awprot_extsys0_axis_ib_switch2_axi_s_0),
  .awvalid_axi4_m       (awvalid_extsys0_axis_ib_switch2_axi_s_0),
  .awvalid_vect_axi4_m  (awvalid_vect_extsys0_axis_ib_switch2_axi_s_0),
  .awready_axi4_m       (awready_extsys0_axis_ib_switch2_axi_s_0),
  .wdata_axi4_m         (wdata_extsys0_axis_ib_switch2_axi_s_0),
  .wstrb_axi4_m         (wstrb_extsys0_axis_ib_switch2_axi_s_0),
  .wlast_axi4_m         (wlast_extsys0_axis_ib_switch2_axi_s_0),
  .wvalid_axi4_m        (wvalid_extsys0_axis_ib_switch2_axi_s_0),
  .wready_axi4_m        (wready_extsys0_axis_ib_switch2_axi_s_0),
  .bid_axi4_m           (bid_extsys0_axis_ib_switch2_axi_s_0),
  .bresp_axi4_m         (bresp_extsys0_axis_ib_switch2_axi_s_0),
  .bvalid_axi4_m        (bvalid_extsys0_axis_ib_switch2_axi_s_0),
  .bready_axi4_m        (bready_extsys0_axis_ib_switch2_axi_s_0),
  .arid_axi4_m          (arid_extsys0_axis_ib_switch2_axi_s_0),
  .araddr_axi4_m        (araddr_extsys0_axis_ib_switch2_axi_s_0),
  .arlen_axi4_m         (arlen_extsys0_axis_ib_switch2_axi_s_0),
  .arsize_axi4_m        (arsize_extsys0_axis_ib_switch2_axi_s_0),
  .arburst_axi4_m       (arburst_extsys0_axis_ib_switch2_axi_s_0),
  .arlock_axi4_m        (arlock_extsys0_axis_ib_switch2_axi_s_0),
  .arcache_axi4_m       (arcache_extsys0_axis_ib_switch2_axi_s_0),
  .arprot_axi4_m        (arprot_extsys0_axis_ib_switch2_axi_s_0),
  .arvalid_axi4_m       (arvalid_extsys0_axis_ib_switch2_axi_s_0),
  .arvalid_vect_axi4_m  (arvalid_vect_extsys0_axis_ib_switch2_axi_s_0),
  .arready_axi4_m       (arready_extsys0_axis_ib_switch2_axi_s_0),
  .rid_axi4_m           (rid_extsys0_axis_ib_switch2_axi_s_0),
  .rdata_axi4_m         (rdata_extsys0_axis_ib_switch2_axi_s_0),
  .rresp_axi4_m         (rresp_extsys0_axis_ib_switch2_axi_s_0),
  .rlast_axi4_m         (rlast_extsys0_axis_ib_switch2_axi_s_0),
  .rvalid_axi4_m        (rvalid_extsys0_axis_ib_switch2_axi_s_0),
  .rready_axi4_m        (rready_extsys0_axis_ib_switch2_axi_s_0),
  .awuser_axi4_m        (awuser_extsys0_axis_ib_switch2_axi_s_0),
  .buser_axi4_m         (buser_extsys0_axis_ib_switch2_axi_s_0),
  .aruser_axi4_m        (aruser_extsys0_axis_ib_switch2_axi_s_0),
  .ruser_axi4_m         (ruser_extsys0_axis_ib_switch2_axi_s_0),
  .awqv_axi4_m          (awqv_extsys0_axis_ib_switch2_axi_s_0),
  .arqv_axi4_m          (arqv_extsys0_axis_ib_switch2_axi_s_0),
  .aw_data              (aw_data_extsys0_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_extsys0_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_extsys0_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_extsys0_axis_ib_int),
  .b_data               (b_data_extsys0_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_extsys0_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_extsys0_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_extsys0_axis_ib_int),
  .ar_data              (ar_data_extsys0_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_extsys0_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_extsys0_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_extsys0_axis_ib_int),
  .r_data               (r_data_extsys0_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_extsys0_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_extsys0_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_extsys0_axis_ib_int),
  .w_data               (w_data_extsys0_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_extsys0_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_extsys0_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_extsys0_axis_ib_int)
);


nic400_ib_extsys0_axis_ib_slave_domain_sse710_main     u_ib_extsys0_axis_ib_s (
  .apbs_req             (preq_extsys0_axis_ib_apb_int),
  .apbs_ack             (pack_extsys0_axis_ib_apb_int),
  .apbs_fwd_data        (pfwdpayld_extsys0_axis_ib_apb_int),
  .apbs_rev_data        (prevpayld_extsys0_axis_ib_apb_int),
  .paddrm               (paddr_extsys0_axis_apb),
  .pwdatam              (pwdata_extsys0_axis_apb),
  .pwritem              (pwrite_extsys0_axis_apb),
  .penablem             (penable_extsys0_axis_apb),
  .pselm                (pselx_extsys0_axis_apb),
  .prdatam              (prdata_extsys0_axis_apb),
  .pslverrm             (pslverr_extsys0_axis_apb),
  .preadym              (pready_extsys0_axis_apb),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .awid_axi4_s          (awid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awlen_axi4_s         (awlen_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awsize_axi4_s        (awsize_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awburst_axi4_s       (awburst_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awlock_axi4_s        (awlock_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awcache_axi4_s       (awcache_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awprot_axi4_s        (awprot_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awvalid_vect_axi4_s  (awvalid_vect_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awready_axi4_s       (awready_extsys0_axis_extsys0_axis_ib_axi4_s),
  .wdata_axi4_s         (wdata_extsys0_axis_extsys0_axis_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_extsys0_axis_extsys0_axis_ib_axi4_s),
  .wlast_axi4_s         (wlast_extsys0_axis_extsys0_axis_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .wready_axi4_s        (wready_extsys0_axis_extsys0_axis_ib_axi4_s),
  .bid_axi4_s           (bid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .bresp_axi4_s         (bresp_extsys0_axis_extsys0_axis_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .bready_axi4_s        (bready_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arid_axi4_s          (arid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .araddr_axi4_s        (araddr_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arlen_axi4_s         (arlen_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arsize_axi4_s        (arsize_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arburst_axi4_s       (arburst_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arlock_axi4_s        (arlock_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arcache_axi4_s       (arcache_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arprot_axi4_s        (arprot_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arvalid_vect_axi4_s  (arvalid_vect_extsys0_axis_extsys0_axis_ib_axi4_s),
  .arready_axi4_s       (arready_extsys0_axis_extsys0_axis_ib_axi4_s),
  .rid_axi4_s           (rid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .rdata_axi4_s         (rdata_extsys0_axis_extsys0_axis_ib_axi4_s),
  .rresp_axi4_s         (rresp_extsys0_axis_extsys0_axis_ib_axi4_s),
  .rlast_axi4_s         (rlast_extsys0_axis_extsys0_axis_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_extsys0_axis_extsys0_axis_ib_axi4_s),
  .rready_axi4_s        (rready_extsys0_axis_extsys0_axis_ib_axi4_s),
  .awuser_axi4_s        (awuser_extsys0_axis_extsys0_axis_ib_axi4_s),
  .buser_axi4_s         (buser_extsys0_axis_extsys0_axis_ib_axi4_s),
  .aruser_axi4_s        (aruser_extsys0_axis_extsys0_axis_ib_axi4_s),
  .ruser_axi4_s         (ruser_extsys0_axis_extsys0_axis_ib_axi4_s),
  .aw_data              (aw_data_extsys0_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_extsys0_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_extsys0_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_extsys0_axis_ib_int),
  .b_data               (b_data_extsys0_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_extsys0_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_extsys0_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_extsys0_axis_ib_int),
  .ar_data              (ar_data_extsys0_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_extsys0_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_extsys0_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_extsys0_axis_ib_int),
  .r_data               (r_data_extsys0_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_extsys0_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_extsys0_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_extsys0_axis_ib_int),
  .w_data               (w_data_extsys0_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_extsys0_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_extsys0_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_extsys0_axis_ib_int)
);


nic400_ib_extsys1_axis_ib_master_domain_sse710_main     u_ib_extsys1_axis_ib_m (
  .paddr                (paddr_extsys1_axis_ib_apb),
  .pwdata               (pwdata_extsys1_axis_ib_apb),
  .pwrite               (pwrite_extsys1_axis_ib_apb),
  .penable              (penable_extsys1_axis_ib_apb),
  .psel                 (pselx_extsys1_axis_ib_apb),
  .prdata               (prdata_extsys1_axis_ib_apb),
  .pslverr              (pslverr_extsys1_axis_ib_apb),
  .pready               (pready_extsys1_axis_ib_apb),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .apbm_req             (preq_extsys1_axis_ib_apb_int),
  .apbm_ack             (pack_extsys1_axis_ib_apb_int),
  .apbm_fwd_data        (pfwdpayld_extsys1_axis_ib_apb_int),
  .apbm_rev_data        (prevpayld_extsys1_axis_ib_apb_int),
  .awid_axi4_m          (awid_extsys1_axis_ib_switch2_axi_s_2),
  .awaddr_axi4_m        (awaddr_extsys1_axis_ib_switch2_axi_s_2),
  .awlen_axi4_m         (awlen_extsys1_axis_ib_switch2_axi_s_2),
  .awsize_axi4_m        (awsize_extsys1_axis_ib_switch2_axi_s_2),
  .awburst_axi4_m       (awburst_extsys1_axis_ib_switch2_axi_s_2),
  .awlock_axi4_m        (awlock_extsys1_axis_ib_switch2_axi_s_2),
  .awcache_axi4_m       (awcache_extsys1_axis_ib_switch2_axi_s_2),
  .awprot_axi4_m        (awprot_extsys1_axis_ib_switch2_axi_s_2),
  .awvalid_axi4_m       (awvalid_extsys1_axis_ib_switch2_axi_s_2),
  .awvalid_vect_axi4_m  (awvalid_vect_extsys1_axis_ib_switch2_axi_s_2),
  .awready_axi4_m       (awready_extsys1_axis_ib_switch2_axi_s_2),
  .wdata_axi4_m         (wdata_extsys1_axis_ib_switch2_axi_s_2),
  .wstrb_axi4_m         (wstrb_extsys1_axis_ib_switch2_axi_s_2),
  .wlast_axi4_m         (wlast_extsys1_axis_ib_switch2_axi_s_2),
  .wvalid_axi4_m        (wvalid_extsys1_axis_ib_switch2_axi_s_2),
  .wready_axi4_m        (wready_extsys1_axis_ib_switch2_axi_s_2),
  .bid_axi4_m           (bid_extsys1_axis_ib_switch2_axi_s_2),
  .bresp_axi4_m         (bresp_extsys1_axis_ib_switch2_axi_s_2),
  .bvalid_axi4_m        (bvalid_extsys1_axis_ib_switch2_axi_s_2),
  .bready_axi4_m        (bready_extsys1_axis_ib_switch2_axi_s_2),
  .arid_axi4_m          (arid_extsys1_axis_ib_switch2_axi_s_2),
  .araddr_axi4_m        (araddr_extsys1_axis_ib_switch2_axi_s_2),
  .arlen_axi4_m         (arlen_extsys1_axis_ib_switch2_axi_s_2),
  .arsize_axi4_m        (arsize_extsys1_axis_ib_switch2_axi_s_2),
  .arburst_axi4_m       (arburst_extsys1_axis_ib_switch2_axi_s_2),
  .arlock_axi4_m        (arlock_extsys1_axis_ib_switch2_axi_s_2),
  .arcache_axi4_m       (arcache_extsys1_axis_ib_switch2_axi_s_2),
  .arprot_axi4_m        (arprot_extsys1_axis_ib_switch2_axi_s_2),
  .arvalid_axi4_m       (arvalid_extsys1_axis_ib_switch2_axi_s_2),
  .arvalid_vect_axi4_m  (arvalid_vect_extsys1_axis_ib_switch2_axi_s_2),
  .arready_axi4_m       (arready_extsys1_axis_ib_switch2_axi_s_2),
  .rid_axi4_m           (rid_extsys1_axis_ib_switch2_axi_s_2),
  .rdata_axi4_m         (rdata_extsys1_axis_ib_switch2_axi_s_2),
  .rresp_axi4_m         (rresp_extsys1_axis_ib_switch2_axi_s_2),
  .rlast_axi4_m         (rlast_extsys1_axis_ib_switch2_axi_s_2),
  .rvalid_axi4_m        (rvalid_extsys1_axis_ib_switch2_axi_s_2),
  .rready_axi4_m        (rready_extsys1_axis_ib_switch2_axi_s_2),
  .awuser_axi4_m        (awuser_extsys1_axis_ib_switch2_axi_s_2),
  .buser_axi4_m         (buser_extsys1_axis_ib_switch2_axi_s_2),
  .aruser_axi4_m        (aruser_extsys1_axis_ib_switch2_axi_s_2),
  .ruser_axi4_m         (ruser_extsys1_axis_ib_switch2_axi_s_2),
  .awqv_axi4_m          (awqv_extsys1_axis_ib_switch2_axi_s_2),
  .arqv_axi4_m          (arqv_extsys1_axis_ib_switch2_axi_s_2),
  .aw_data              (aw_data_extsys1_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_extsys1_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_extsys1_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_extsys1_axis_ib_int),
  .b_data               (b_data_extsys1_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_extsys1_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_extsys1_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_extsys1_axis_ib_int),
  .ar_data              (ar_data_extsys1_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_extsys1_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_extsys1_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_extsys1_axis_ib_int),
  .r_data               (r_data_extsys1_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_extsys1_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_extsys1_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_extsys1_axis_ib_int),
  .w_data               (w_data_extsys1_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_extsys1_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_extsys1_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_extsys1_axis_ib_int)
);


nic400_ib_extsys1_axis_ib_slave_domain_sse710_main     u_ib_extsys1_axis_ib_s (
  .apbs_req             (preq_extsys1_axis_ib_apb_int),
  .apbs_ack             (pack_extsys1_axis_ib_apb_int),
  .apbs_fwd_data        (pfwdpayld_extsys1_axis_ib_apb_int),
  .apbs_rev_data        (prevpayld_extsys1_axis_ib_apb_int),
  .paddrm               (paddr_extsys1_axis_apb),
  .pwdatam              (pwdata_extsys1_axis_apb),
  .pwritem              (pwrite_extsys1_axis_apb),
  .penablem             (penable_extsys1_axis_apb),
  .pselm                (pselx_extsys1_axis_apb),
  .prdatam              (prdata_extsys1_axis_apb),
  .pslverrm             (pslverr_extsys1_axis_apb),
  .preadym              (pready_extsys1_axis_apb),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .awid_axi4_s          (awid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awlen_axi4_s         (awlen_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awsize_axi4_s        (awsize_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awburst_axi4_s       (awburst_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awlock_axi4_s        (awlock_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awcache_axi4_s       (awcache_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awprot_axi4_s        (awprot_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awvalid_vect_axi4_s  (awvalid_vect_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awready_axi4_s       (awready_extsys1_axis_extsys1_axis_ib_axi4_s),
  .wdata_axi4_s         (wdata_extsys1_axis_extsys1_axis_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_extsys1_axis_extsys1_axis_ib_axi4_s),
  .wlast_axi4_s         (wlast_extsys1_axis_extsys1_axis_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .wready_axi4_s        (wready_extsys1_axis_extsys1_axis_ib_axi4_s),
  .bid_axi4_s           (bid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .bresp_axi4_s         (bresp_extsys1_axis_extsys1_axis_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .bready_axi4_s        (bready_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arid_axi4_s          (arid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .araddr_axi4_s        (araddr_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arlen_axi4_s         (arlen_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arsize_axi4_s        (arsize_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arburst_axi4_s       (arburst_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arlock_axi4_s        (arlock_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arcache_axi4_s       (arcache_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arprot_axi4_s        (arprot_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arvalid_vect_axi4_s  (arvalid_vect_extsys1_axis_extsys1_axis_ib_axi4_s),
  .arready_axi4_s       (arready_extsys1_axis_extsys1_axis_ib_axi4_s),
  .rid_axi4_s           (rid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .rdata_axi4_s         (rdata_extsys1_axis_extsys1_axis_ib_axi4_s),
  .rresp_axi4_s         (rresp_extsys1_axis_extsys1_axis_ib_axi4_s),
  .rlast_axi4_s         (rlast_extsys1_axis_extsys1_axis_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_extsys1_axis_extsys1_axis_ib_axi4_s),
  .rready_axi4_s        (rready_extsys1_axis_extsys1_axis_ib_axi4_s),
  .awuser_axi4_s        (awuser_extsys1_axis_extsys1_axis_ib_axi4_s),
  .buser_axi4_s         (buser_extsys1_axis_extsys1_axis_ib_axi4_s),
  .aruser_axi4_s        (aruser_extsys1_axis_extsys1_axis_ib_axi4_s),
  .ruser_axi4_s         (ruser_extsys1_axis_extsys1_axis_ib_axi4_s),
  .aw_data              (aw_data_extsys1_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_extsys1_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_extsys1_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_extsys1_axis_ib_int),
  .b_data               (b_data_extsys1_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_extsys1_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_extsys1_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_extsys1_axis_ib_int),
  .ar_data              (ar_data_extsys1_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_extsys1_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_extsys1_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_extsys1_axis_ib_int),
  .r_data               (r_data_extsys1_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_extsys1_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_extsys1_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_extsys1_axis_ib_int),
  .w_data               (w_data_extsys1_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_extsys1_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_extsys1_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_extsys1_axis_ib_int)
);


nic400_ib_gpv_0_ib1_slave_domain_sse710_main     u_ib_gpv_0_ib1_s (
  .awid_axi4_s          (awid_switch1_gpv_0_ib1_axi4_s),
  .awaddr_axi4_s        (awaddr_switch1_gpv_0_ib1_axi4_s),
  .awlen_axi4_s         (awlen_switch1_gpv_0_ib1_axi4_s),
  .awsize_axi4_s        (awsize_switch1_gpv_0_ib1_axi4_s),
  .awburst_axi4_s       (awburst_switch1_gpv_0_ib1_axi4_s),
  .awlock_axi4_s        (awlock_switch1_gpv_0_ib1_axi4_s),
  .awcache_axi4_s       (awcache_switch1_gpv_0_ib1_axi4_s),
  .awprot_axi4_s        (awprot_switch1_gpv_0_ib1_axi4_s),
  .awvalid_axi4_s       (awvalid_switch1_gpv_0_ib1_axi4_s),
  .awready_axi4_s       (awready_switch1_gpv_0_ib1_axi4_s),
  .wdata_axi4_s         (wdata_switch1_gpv_0_ib1_axi4_s),
  .wstrb_axi4_s         (wstrb_switch1_gpv_0_ib1_axi4_s),
  .wlast_axi4_s         (wlast_switch1_gpv_0_ib1_axi4_s),
  .wvalid_axi4_s        (wvalid_switch1_gpv_0_ib1_axi4_s),
  .wready_axi4_s        (wready_switch1_gpv_0_ib1_axi4_s),
  .bid_axi4_s           (bid_switch1_gpv_0_ib1_axi4_s),
  .bresp_axi4_s         (bresp_switch1_gpv_0_ib1_axi4_s),
  .bvalid_axi4_s        (bvalid_switch1_gpv_0_ib1_axi4_s),
  .bready_axi4_s        (bready_switch1_gpv_0_ib1_axi4_s),
  .arid_axi4_s          (arid_switch1_gpv_0_ib1_axi4_s),
  .araddr_axi4_s        (araddr_switch1_gpv_0_ib1_axi4_s),
  .arlen_axi4_s         (arlen_switch1_gpv_0_ib1_axi4_s),
  .arsize_axi4_s        (arsize_switch1_gpv_0_ib1_axi4_s),
  .arburst_axi4_s       (arburst_switch1_gpv_0_ib1_axi4_s),
  .arlock_axi4_s        (arlock_switch1_gpv_0_ib1_axi4_s),
  .arcache_axi4_s       (arcache_switch1_gpv_0_ib1_axi4_s),
  .arprot_axi4_s        (arprot_switch1_gpv_0_ib1_axi4_s),
  .arvalid_axi4_s       (arvalid_switch1_gpv_0_ib1_axi4_s),
  .arready_axi4_s       (arready_switch1_gpv_0_ib1_axi4_s),
  .rid_axi4_s           (rid_switch1_gpv_0_ib1_axi4_s),
  .rdata_axi4_s         (rdata_switch1_gpv_0_ib1_axi4_s),
  .rresp_axi4_s         (rresp_switch1_gpv_0_ib1_axi4_s),
  .rlast_axi4_s         (rlast_switch1_gpv_0_ib1_axi4_s),
  .rvalid_axi4_s        (rvalid_switch1_gpv_0_ib1_axi4_s),
  .rready_axi4_s        (rready_switch1_gpv_0_ib1_axi4_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .a_data               (a_data_gpv_0_ib1_int),
  .a_valid              (a_valid_gpv_0_ib1_int),
  .a_ready              (a_ready_gpv_0_ib1_int),
  .d_data               (d_data_gpv_0_ib1_int),
  .d_valid              (d_valid_gpv_0_ib1_int),
  .d_ready              (d_ready_gpv_0_ib1_int),
  .w_data               (w_data_gpv_0_ib1_int),
  .w_valid              (w_valid_gpv_0_ib1_int),
  .w_ready              (w_ready_gpv_0_ib1_int)
);


nic400_ib_gpvmain_ahb_ib_master_domain_sse710_main     u_ib_gpvmain_ahb_ib_m (
  .awid_axi4_m          (awid_gpvmain_ahb_ib_switch1_axi_s_5),
  .awaddr_axi4_m        (awaddr_gpvmain_ahb_ib_switch1_axi_s_5),
  .awlen_axi4_m         (awlen_gpvmain_ahb_ib_switch1_axi_s_5),
  .awsize_axi4_m        (awsize_gpvmain_ahb_ib_switch1_axi_s_5),
  .awburst_axi4_m       (awburst_gpvmain_ahb_ib_switch1_axi_s_5),
  .awlock_axi4_m        (awlock_gpvmain_ahb_ib_switch1_axi_s_5),
  .awcache_axi4_m       (awcache_gpvmain_ahb_ib_switch1_axi_s_5),
  .awprot_axi4_m        (awprot_gpvmain_ahb_ib_switch1_axi_s_5),
  .awvalid_axi4_m       (awvalid_gpvmain_ahb_ib_switch1_axi_s_5),
  .awvalid_vect_axi4_m  (awvalid_vect_gpvmain_ahb_ib_switch1_axi_s_5),
  .awready_axi4_m       (awready_gpvmain_ahb_ib_switch1_axi_s_5),
  .wdata_axi4_m         (wdata_gpvmain_ahb_ib_switch1_axi_s_5),
  .wstrb_axi4_m         (wstrb_gpvmain_ahb_ib_switch1_axi_s_5),
  .wlast_axi4_m         (wlast_gpvmain_ahb_ib_switch1_axi_s_5),
  .wvalid_axi4_m        (wvalid_gpvmain_ahb_ib_switch1_axi_s_5),
  .wready_axi4_m        (wready_gpvmain_ahb_ib_switch1_axi_s_5),
  .bid_axi4_m           (bid_gpvmain_ahb_ib_switch1_axi_s_5),
  .bresp_axi4_m         (bresp_gpvmain_ahb_ib_switch1_axi_s_5),
  .bvalid_axi4_m        (bvalid_gpvmain_ahb_ib_switch1_axi_s_5),
  .bready_axi4_m        (bready_gpvmain_ahb_ib_switch1_axi_s_5),
  .arid_axi4_m          (arid_gpvmain_ahb_ib_switch1_axi_s_5),
  .araddr_axi4_m        (araddr_gpvmain_ahb_ib_switch1_axi_s_5),
  .arlen_axi4_m         (arlen_gpvmain_ahb_ib_switch1_axi_s_5),
  .arsize_axi4_m        (arsize_gpvmain_ahb_ib_switch1_axi_s_5),
  .arburst_axi4_m       (arburst_gpvmain_ahb_ib_switch1_axi_s_5),
  .arlock_axi4_m        (arlock_gpvmain_ahb_ib_switch1_axi_s_5),
  .arcache_axi4_m       (arcache_gpvmain_ahb_ib_switch1_axi_s_5),
  .arprot_axi4_m        (arprot_gpvmain_ahb_ib_switch1_axi_s_5),
  .arvalid_axi4_m       (arvalid_gpvmain_ahb_ib_switch1_axi_s_5),
  .arvalid_vect_axi4_m  (arvalid_vect_gpvmain_ahb_ib_switch1_axi_s_5),
  .arready_axi4_m       (arready_gpvmain_ahb_ib_switch1_axi_s_5),
  .rid_axi4_m           (rid_gpvmain_ahb_ib_switch1_axi_s_5),
  .rdata_axi4_m         (rdata_gpvmain_ahb_ib_switch1_axi_s_5),
  .rresp_axi4_m         (rresp_gpvmain_ahb_ib_switch1_axi_s_5),
  .rlast_axi4_m         (rlast_gpvmain_ahb_ib_switch1_axi_s_5),
  .rvalid_axi4_m        (rvalid_gpvmain_ahb_ib_switch1_axi_s_5),
  .rready_axi4_m        (rready_gpvmain_ahb_ib_switch1_axi_s_5),
  .awqv_axi4_m          (awqv_gpvmain_ahb_ib_switch1_axi_s_5),
  .arqv_axi4_m          (arqv_gpvmain_ahb_ib_switch1_axi_s_5),
  .aclk_m               (aclk),
  .aresetn_m            (aresetn),
  .gpvmain_ahb_ib_cactive (cactive_gpvmain_ahb_ib_hcg),
  .gpvmain_ahb_ib_port_enable (port_enable_gpvmain_ahb_ib_port_enable_hcg),
  .a_data               (a_data_gpvmain_ahb_ib_int),
  .a_valid              (a_valid_gpvmain_ahb_ib_int),
  .a_ready              (a_ready_gpvmain_ahb_ib_int),
  .d_data               (d_data_gpvmain_ahb_ib_int),
  .d_valid              (d_valid_gpvmain_ahb_ib_int),
  .d_ready              (d_ready_gpvmain_ahb_ib_int),
  .w_data               (w_data_gpvmain_ahb_ib_int),
  .w_valid              (w_valid_gpvmain_ahb_ib_int),
  .w_ready              (w_ready_gpvmain_ahb_ib_int),
  .empty                (empty_gpvmain_ahb_ib_int),
  .gpvmain_ahb_ib_cactive_wakeup (cactive_gpvmain_ahb_ib_wakeup_hcg)
);


nic400_ib_hostcpu_axis_ib_master_domain_sse710_main     u_ib_hostcpu_axis_ib_m (
  .paddr                (paddr_hostcpu_axis_ib_apb),
  .pwdata               (pwdata_hostcpu_axis_ib_apb),
  .pwrite               (pwrite_hostcpu_axis_ib_apb),
  .penable              (penable_hostcpu_axis_ib_apb),
  .psel                 (pselx_hostcpu_axis_ib_apb),
  .prdata               (prdata_hostcpu_axis_ib_apb),
  .pslverr              (pslverr_hostcpu_axis_ib_apb),
  .pready               (pready_hostcpu_axis_ib_apb),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .apbm_req             (preq_hostcpu_axis_ib_apb_int),
  .apbm_ack             (pack_hostcpu_axis_ib_apb_int),
  .apbm_fwd_data        (pfwdpayld_hostcpu_axis_ib_apb_int),
  .apbm_rev_data        (prevpayld_hostcpu_axis_ib_apb_int),
  .awid_axi4_m          (awid_hostcpu_axis_ib_switch2_axi_s_1),
  .awaddr_axi4_m        (awaddr_hostcpu_axis_ib_switch2_axi_s_1),
  .awlen_axi4_m         (awlen_hostcpu_axis_ib_switch2_axi_s_1),
  .awsize_axi4_m        (awsize_hostcpu_axis_ib_switch2_axi_s_1),
  .awburst_axi4_m       (awburst_hostcpu_axis_ib_switch2_axi_s_1),
  .awlock_axi4_m        (awlock_hostcpu_axis_ib_switch2_axi_s_1),
  .awcache_axi4_m       (awcache_hostcpu_axis_ib_switch2_axi_s_1),
  .awprot_axi4_m        (awprot_hostcpu_axis_ib_switch2_axi_s_1),
  .awvalid_axi4_m       (awvalid_hostcpu_axis_ib_switch2_axi_s_1),
  .awvalid_vect_axi4_m  (awvalid_vect_hostcpu_axis_ib_switch2_axi_s_1),
  .awready_axi4_m       (awready_hostcpu_axis_ib_switch2_axi_s_1),
  .wdata_axi4_m         (wdata_hostcpu_axis_ib_switch2_axi_s_1),
  .wstrb_axi4_m         (wstrb_hostcpu_axis_ib_switch2_axi_s_1),
  .wlast_axi4_m         (wlast_hostcpu_axis_ib_switch2_axi_s_1),
  .wvalid_axi4_m        (wvalid_hostcpu_axis_ib_switch2_axi_s_1),
  .wready_axi4_m        (wready_hostcpu_axis_ib_switch2_axi_s_1),
  .bid_axi4_m           (bid_hostcpu_axis_ib_switch2_axi_s_1),
  .bresp_axi4_m         (bresp_hostcpu_axis_ib_switch2_axi_s_1),
  .bvalid_axi4_m        (bvalid_hostcpu_axis_ib_switch2_axi_s_1),
  .bready_axi4_m        (bready_hostcpu_axis_ib_switch2_axi_s_1),
  .arid_axi4_m          (arid_hostcpu_axis_ib_switch2_axi_s_1),
  .araddr_axi4_m        (araddr_hostcpu_axis_ib_switch2_axi_s_1),
  .arlen_axi4_m         (arlen_hostcpu_axis_ib_switch2_axi_s_1),
  .arsize_axi4_m        (arsize_hostcpu_axis_ib_switch2_axi_s_1),
  .arburst_axi4_m       (arburst_hostcpu_axis_ib_switch2_axi_s_1),
  .arlock_axi4_m        (arlock_hostcpu_axis_ib_switch2_axi_s_1),
  .arcache_axi4_m       (arcache_hostcpu_axis_ib_switch2_axi_s_1),
  .arprot_axi4_m        (arprot_hostcpu_axis_ib_switch2_axi_s_1),
  .arvalid_axi4_m       (arvalid_hostcpu_axis_ib_switch2_axi_s_1),
  .arvalid_vect_axi4_m  (arvalid_vect_hostcpu_axis_ib_switch2_axi_s_1),
  .arready_axi4_m       (arready_hostcpu_axis_ib_switch2_axi_s_1),
  .rid_axi4_m           (rid_hostcpu_axis_ib_switch2_axi_s_1),
  .rdata_axi4_m         (rdata_hostcpu_axis_ib_switch2_axi_s_1),
  .rresp_axi4_m         (rresp_hostcpu_axis_ib_switch2_axi_s_1),
  .rlast_axi4_m         (rlast_hostcpu_axis_ib_switch2_axi_s_1),
  .rvalid_axi4_m        (rvalid_hostcpu_axis_ib_switch2_axi_s_1),
  .rready_axi4_m        (rready_hostcpu_axis_ib_switch2_axi_s_1),
  .awuser_axi4_m        (awuser_hostcpu_axis_ib_switch2_axi_s_1),
  .buser_axi4_m         (buser_hostcpu_axis_ib_switch2_axi_s_1),
  .aruser_axi4_m        (aruser_hostcpu_axis_ib_switch2_axi_s_1),
  .ruser_axi4_m         (ruser_hostcpu_axis_ib_switch2_axi_s_1),
  .awqv_axi4_m          (awqv_hostcpu_axis_ib_switch2_axi_s_1),
  .arqv_axi4_m          (arqv_hostcpu_axis_ib_switch2_axi_s_1),
  .aw_data              (aw_data_hostcpu_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_hostcpu_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_hostcpu_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_hostcpu_axis_ib_int),
  .b_data               (b_data_hostcpu_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_hostcpu_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_hostcpu_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_hostcpu_axis_ib_int),
  .ar_data              (ar_data_hostcpu_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_hostcpu_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_hostcpu_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_hostcpu_axis_ib_int),
  .r_data               (r_data_hostcpu_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_hostcpu_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_hostcpu_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_hostcpu_axis_ib_int),
  .w_data               (w_data_hostcpu_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_hostcpu_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_hostcpu_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_hostcpu_axis_ib_int)
);


nic400_ib_hostcpu_axis_ib_slave_domain_sse710_main     u_ib_hostcpu_axis_ib_s (
  .apbs_req             (preq_hostcpu_axis_ib_apb_int),
  .apbs_ack             (pack_hostcpu_axis_ib_apb_int),
  .apbs_fwd_data        (pfwdpayld_hostcpu_axis_ib_apb_int),
  .apbs_rev_data        (prevpayld_hostcpu_axis_ib_apb_int),
  .paddrm               (paddr_hostcpu_axis_apb),
  .pwdatam              (pwdata_hostcpu_axis_apb),
  .pwritem              (pwrite_hostcpu_axis_apb),
  .penablem             (penable_hostcpu_axis_apb),
  .pselm                (pselx_hostcpu_axis_apb),
  .prdatam              (prdata_hostcpu_axis_apb),
  .pslverrm             (pslverr_hostcpu_axis_apb),
  .preadym              (pready_hostcpu_axis_apb),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .awid_axi4_s          (awid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awlen_axi4_s         (awlen_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awsize_axi4_s        (awsize_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awburst_axi4_s       (awburst_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awlock_axi4_s        (awlock_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awcache_axi4_s       (awcache_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awprot_axi4_s        (awprot_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awvalid_vect_axi4_s  (awvalid_vect_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awready_axi4_s       (awready_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .wdata_axi4_s         (wdata_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .wlast_axi4_s         (wlast_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .wready_axi4_s        (wready_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .bid_axi4_s           (bid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .bresp_axi4_s         (bresp_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .bready_axi4_s        (bready_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arid_axi4_s          (arid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .araddr_axi4_s        (araddr_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arlen_axi4_s         (arlen_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arsize_axi4_s        (arsize_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arburst_axi4_s       (arburst_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arlock_axi4_s        (arlock_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arcache_axi4_s       (arcache_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arprot_axi4_s        (arprot_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arvalid_vect_axi4_s  (arvalid_vect_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .arready_axi4_s       (arready_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .rid_axi4_s           (rid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .rdata_axi4_s         (rdata_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .rresp_axi4_s         (rresp_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .rlast_axi4_s         (rlast_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .rready_axi4_s        (rready_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .awuser_axi4_s        (awuser_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .buser_axi4_s         (buser_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .aruser_axi4_s        (aruser_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .ruser_axi4_s         (ruser_hostcpu_axis_hostcpu_axis_ib_axi4_s),
  .aw_data              (aw_data_hostcpu_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_hostcpu_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_hostcpu_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_hostcpu_axis_ib_int),
  .b_data               (b_data_hostcpu_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_hostcpu_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_hostcpu_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_hostcpu_axis_ib_int),
  .ar_data              (ar_data_hostcpu_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_hostcpu_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_hostcpu_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_hostcpu_axis_ib_int),
  .r_data               (r_data_hostcpu_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_hostcpu_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_hostcpu_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_hostcpu_axis_ib_int),
  .w_data               (w_data_hostcpu_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_hostcpu_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_hostcpu_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_hostcpu_axis_ib_int)
);


nic400_ib_ib1_master_domain_sse710_main     u_ib_ib1_m (
  .awid_axi_m_0         (awid_ib1_switch2_axi_s_3),
  .awaddr_axi_m_0       (awaddr_ib1_switch2_axi_s_3),
  .awlen_axi_m_0        (awlen_ib1_switch2_axi_s_3),
  .awsize_axi_m_0       (awsize_ib1_switch2_axi_s_3),
  .awburst_axi_m_0      (awburst_ib1_switch2_axi_s_3),
  .awlock_axi_m_0       (awlock_ib1_switch2_axi_s_3),
  .awcache_axi_m_0      (awcache_ib1_switch2_axi_s_3),
  .awprot_axi_m_0       (awprot_ib1_switch2_axi_s_3),
  .awvalid_axi_m_0      (awvalid_ib1_switch2_axi_s_3),
  .awvalid_vect_axi_m_0 (awvalid_vect_ib1_switch2_axi_s_3),
  .awready_axi_m_0      (awready_ib1_switch2_axi_s_3),
  .wdata_axi_m_0        (wdata_ib1_switch2_axi_s_3),
  .wstrb_axi_m_0        (wstrb_ib1_switch2_axi_s_3),
  .wlast_axi_m_0        (wlast_ib1_switch2_axi_s_3),
  .wvalid_axi_m_0       (wvalid_ib1_switch2_axi_s_3),
  .wready_axi_m_0       (wready_ib1_switch2_axi_s_3),
  .bid_axi_m_0          (bid_ib1_switch2_axi_s_3),
  .bresp_axi_m_0        (bresp_ib1_switch2_axi_s_3),
  .bvalid_axi_m_0       (bvalid_ib1_switch2_axi_s_3),
  .bready_axi_m_0       (bready_ib1_switch2_axi_s_3),
  .arid_axi_m_0         (arid_ib1_switch2_axi_s_3),
  .araddr_axi_m_0       (araddr_ib1_switch2_axi_s_3),
  .arlen_axi_m_0        (arlen_ib1_switch2_axi_s_3),
  .arsize_axi_m_0       (arsize_ib1_switch2_axi_s_3),
  .arburst_axi_m_0      (arburst_ib1_switch2_axi_s_3),
  .arlock_axi_m_0       (arlock_ib1_switch2_axi_s_3),
  .arcache_axi_m_0      (arcache_ib1_switch2_axi_s_3),
  .arprot_axi_m_0       (arprot_ib1_switch2_axi_s_3),
  .arvalid_axi_m_0      (arvalid_ib1_switch2_axi_s_3),
  .arvalid_vect_axi_m_0 (arvalid_vect_ib1_switch2_axi_s_3),
  .arready_axi_m_0      (arready_ib1_switch2_axi_s_3),
  .rid_axi_m_0          (rid_ib1_switch2_axi_s_3),
  .rdata_axi_m_0        (rdata_ib1_switch2_axi_s_3),
  .rresp_axi_m_0        (rresp_ib1_switch2_axi_s_3),
  .rlast_axi_m_0        (rlast_ib1_switch2_axi_s_3),
  .rvalid_axi_m_0       (rvalid_ib1_switch2_axi_s_3),
  .rready_axi_m_0       (rready_ib1_switch2_axi_s_3),
  .awuser_axi_m_0       (awuser_ib1_switch2_axi_s_3),
  .buser_axi_m_0        (buser_ib1_switch2_axi_s_3),
  .aruser_axi_m_0       (aruser_ib1_switch2_axi_s_3),
  .ruser_axi_m_0        (ruser_ib1_switch2_axi_s_3),
  .awqv_axi_m_0         (awqv_ib1_switch2_axi_s_3),
  .arqv_axi_m_0         (arqv_ib1_switch2_axi_s_3),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_ib1_int),
  .aw_valid             (aw_valid_ib1_int),
  .aw_ready             (aw_ready_ib1_int),
  .b_data               (b_data_ib1_int),
  .b_valid              (b_valid_ib1_int),
  .b_ready              (b_ready_ib1_int),
  .ar_data              (ar_data_ib1_int),
  .ar_valid             (ar_valid_ib1_int),
  .ar_ready             (ar_ready_ib1_int),
  .r_data               (r_data_ib1_int),
  .r_valid              (r_valid_ib1_int),
  .r_ready              (r_ready_ib1_int),
  .w_data               (w_data_ib1_int),
  .w_valid              (w_valid_ib1_int),
  .w_ready              (w_ready_ib1_int)
);


nic400_ib_ib1_slave_domain_sse710_main     u_ib_ib1_s (
  .awid_axi_s_0         (awid_switch1_ib1_axi_s_0),
  .awaddr_axi_s_0       (awaddr_switch1_ib1_axi_s_0),
  .awlen_axi_s_0        (awlen_switch1_ib1_axi_s_0),
  .awsize_axi_s_0       (awsize_switch1_ib1_axi_s_0),
  .awburst_axi_s_0      (awburst_switch1_ib1_axi_s_0),
  .awlock_axi_s_0       (awlock_switch1_ib1_axi_s_0),
  .awcache_axi_s_0      (awcache_switch1_ib1_axi_s_0),
  .awprot_axi_s_0       (awprot_switch1_ib1_axi_s_0),
  .awvalid_axi_s_0      (awvalid_switch1_ib1_axi_s_0),
  .awvalid_vect_axi_s_0 (awvalid_vect_switch1_ib1_axi_s_0),
  .awready_axi_s_0      (awready_switch1_ib1_axi_s_0),
  .wdata_axi_s_0        (wdata_switch1_ib1_axi_s_0),
  .wstrb_axi_s_0        (wstrb_switch1_ib1_axi_s_0),
  .wlast_axi_s_0        (wlast_switch1_ib1_axi_s_0),
  .wvalid_axi_s_0       (wvalid_switch1_ib1_axi_s_0),
  .wready_axi_s_0       (wready_switch1_ib1_axi_s_0),
  .bid_axi_s_0          (bid_switch1_ib1_axi_s_0),
  .bresp_axi_s_0        (bresp_switch1_ib1_axi_s_0),
  .bvalid_axi_s_0       (bvalid_switch1_ib1_axi_s_0),
  .bready_axi_s_0       (bready_switch1_ib1_axi_s_0),
  .arid_axi_s_0         (arid_switch1_ib1_axi_s_0),
  .araddr_axi_s_0       (araddr_switch1_ib1_axi_s_0),
  .arlen_axi_s_0        (arlen_switch1_ib1_axi_s_0),
  .arsize_axi_s_0       (arsize_switch1_ib1_axi_s_0),
  .arburst_axi_s_0      (arburst_switch1_ib1_axi_s_0),
  .arlock_axi_s_0       (arlock_switch1_ib1_axi_s_0),
  .arcache_axi_s_0      (arcache_switch1_ib1_axi_s_0),
  .arprot_axi_s_0       (arprot_switch1_ib1_axi_s_0),
  .arvalid_axi_s_0      (arvalid_switch1_ib1_axi_s_0),
  .arvalid_vect_axi_s_0 (arvalid_vect_switch1_ib1_axi_s_0),
  .arready_axi_s_0      (arready_switch1_ib1_axi_s_0),
  .rid_axi_s_0          (rid_switch1_ib1_axi_s_0),
  .rdata_axi_s_0        (rdata_switch1_ib1_axi_s_0),
  .rresp_axi_s_0        (rresp_switch1_ib1_axi_s_0),
  .rlast_axi_s_0        (rlast_switch1_ib1_axi_s_0),
  .rvalid_axi_s_0       (rvalid_switch1_ib1_axi_s_0),
  .rready_axi_s_0       (rready_switch1_ib1_axi_s_0),
  .awuser_axi_s_0       (awuser_switch1_ib1_axi_s_0),
  .buser_axi_s_0        (buser_switch1_ib1_axi_s_0),
  .aruser_axi_s_0       (aruser_switch1_ib1_axi_s_0),
  .ruser_axi_s_0        (ruser_switch1_ib1_axi_s_0),
  .awqv_axi_s_0         (awqv_switch1_ib1_axi_s_0),
  .arqv_axi_s_0         (arqv_switch1_ib1_axi_s_0),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_ib1_int),
  .aw_valid             (aw_valid_ib1_int),
  .aw_ready             (aw_ready_ib1_int),
  .b_data               (b_data_ib1_int),
  .b_valid              (b_valid_ib1_int),
  .b_ready              (b_ready_ib1_int),
  .ar_data              (ar_data_ib1_int),
  .ar_valid             (ar_valid_ib1_int),
  .ar_ready             (ar_ready_ib1_int),
  .r_data               (r_data_ib1_int),
  .r_valid              (r_valid_ib1_int),
  .r_ready              (r_ready_ib1_int),
  .w_data               (w_data_ib1_int),
  .w_valid              (w_valid_ib1_int),
  .w_ready              (w_ready_ib1_int)
);


nic400_ib_ib4_master_domain_sse710_main     u_ib_ib4_m (
  .awid_axi_m_0         (awid_ib4_switch3_axi_s_0),
  .awaddr_axi_m_0       (awaddr_ib4_switch3_axi_s_0),
  .awlen_axi_m_0        (awlen_ib4_switch3_axi_s_0),
  .awsize_axi_m_0       (awsize_ib4_switch3_axi_s_0),
  .awburst_axi_m_0      (awburst_ib4_switch3_axi_s_0),
  .awlock_axi_m_0       (awlock_ib4_switch3_axi_s_0),
  .awcache_axi_m_0      (awcache_ib4_switch3_axi_s_0),
  .awprot_axi_m_0       (awprot_ib4_switch3_axi_s_0),
  .awvalid_axi_m_0      (awvalid_ib4_switch3_axi_s_0),
  .awvalid_vect_axi_m_0 (awvalid_vect_ib4_switch3_axi_s_0),
  .awready_axi_m_0      (awready_ib4_switch3_axi_s_0),
  .wdata_axi_m_0        (wdata_ib4_switch3_axi_s_0),
  .wstrb_axi_m_0        (wstrb_ib4_switch3_axi_s_0),
  .wlast_axi_m_0        (wlast_ib4_switch3_axi_s_0),
  .wvalid_axi_m_0       (wvalid_ib4_switch3_axi_s_0),
  .wready_axi_m_0       (wready_ib4_switch3_axi_s_0),
  .bid_axi_m_0          (bid_ib4_switch3_axi_s_0),
  .bresp_axi_m_0        (bresp_ib4_switch3_axi_s_0),
  .bvalid_axi_m_0       (bvalid_ib4_switch3_axi_s_0),
  .bready_axi_m_0       (bready_ib4_switch3_axi_s_0),
  .arid_axi_m_0         (arid_ib4_switch3_axi_s_0),
  .araddr_axi_m_0       (araddr_ib4_switch3_axi_s_0),
  .arlen_axi_m_0        (arlen_ib4_switch3_axi_s_0),
  .arsize_axi_m_0       (arsize_ib4_switch3_axi_s_0),
  .arburst_axi_m_0      (arburst_ib4_switch3_axi_s_0),
  .arlock_axi_m_0       (arlock_ib4_switch3_axi_s_0),
  .arcache_axi_m_0      (arcache_ib4_switch3_axi_s_0),
  .arprot_axi_m_0       (arprot_ib4_switch3_axi_s_0),
  .arvalid_axi_m_0      (arvalid_ib4_switch3_axi_s_0),
  .arvalid_vect_axi_m_0 (arvalid_vect_ib4_switch3_axi_s_0),
  .arready_axi_m_0      (arready_ib4_switch3_axi_s_0),
  .rid_axi_m_0          (rid_ib4_switch3_axi_s_0),
  .rdata_axi_m_0        (rdata_ib4_switch3_axi_s_0),
  .rresp_axi_m_0        (rresp_ib4_switch3_axi_s_0),
  .rlast_axi_m_0        (rlast_ib4_switch3_axi_s_0),
  .rvalid_axi_m_0       (rvalid_ib4_switch3_axi_s_0),
  .rready_axi_m_0       (rready_ib4_switch3_axi_s_0),
  .awuser_axi_m_0       (awuser_ib4_switch3_axi_s_0),
  .buser_axi_m_0        (buser_ib4_switch3_axi_s_0),
  .aruser_axi_m_0       (aruser_ib4_switch3_axi_s_0),
  .ruser_axi_m_0        (ruser_ib4_switch3_axi_s_0),
  .awqv_axi_m_0         (awqv_ib4_switch3_axi_s_0),
  .arqv_axi_m_0         (arqv_ib4_switch3_axi_s_0),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_ib4_int),
  .aw_valid             (aw_valid_ib4_int),
  .aw_ready             (aw_ready_ib4_int),
  .b_data               (b_data_ib4_int),
  .b_valid              (b_valid_ib4_int),
  .b_ready              (b_ready_ib4_int),
  .ar_data              (ar_data_ib4_int),
  .ar_valid             (ar_valid_ib4_int),
  .ar_ready             (ar_ready_ib4_int),
  .r_data               (r_data_ib4_int),
  .r_valid              (r_valid_ib4_int),
  .r_ready              (r_ready_ib4_int),
  .w_data               (w_data_ib4_int),
  .w_valid              (w_valid_ib4_int),
  .w_ready              (w_ready_ib4_int)
);


nic400_ib_ib4_slave_domain_sse710_main     u_ib_ib4_s (
  .awid_axi_s_0         (awid_switch2_ib4_axi_s_0),
  .awaddr_axi_s_0       (awaddr_switch2_ib4_axi_s_0),
  .awlen_axi_s_0        (awlen_switch2_ib4_axi_s_0),
  .awsize_axi_s_0       (awsize_switch2_ib4_axi_s_0),
  .awburst_axi_s_0      (awburst_switch2_ib4_axi_s_0),
  .awlock_axi_s_0       (awlock_switch2_ib4_axi_s_0),
  .awcache_axi_s_0      (awcache_switch2_ib4_axi_s_0),
  .awprot_axi_s_0       (awprot_switch2_ib4_axi_s_0),
  .awvalid_axi_s_0      (awvalid_switch2_ib4_axi_s_0),
  .awvalid_vect_axi_s_0 (awvalid_vect_switch2_ib4_axi_s_0),
  .awready_axi_s_0      (awready_switch2_ib4_axi_s_0),
  .wdata_axi_s_0        (wdata_switch2_ib4_axi_s_0),
  .wstrb_axi_s_0        (wstrb_switch2_ib4_axi_s_0),
  .wlast_axi_s_0        (wlast_switch2_ib4_axi_s_0),
  .wvalid_axi_s_0       (wvalid_switch2_ib4_axi_s_0),
  .wready_axi_s_0       (wready_switch2_ib4_axi_s_0),
  .bid_axi_s_0          (bid_switch2_ib4_axi_s_0),
  .bresp_axi_s_0        (bresp_switch2_ib4_axi_s_0),
  .bvalid_axi_s_0       (bvalid_switch2_ib4_axi_s_0),
  .bready_axi_s_0       (bready_switch2_ib4_axi_s_0),
  .arid_axi_s_0         (arid_switch2_ib4_axi_s_0),
  .araddr_axi_s_0       (araddr_switch2_ib4_axi_s_0),
  .arlen_axi_s_0        (arlen_switch2_ib4_axi_s_0),
  .arsize_axi_s_0       (arsize_switch2_ib4_axi_s_0),
  .arburst_axi_s_0      (arburst_switch2_ib4_axi_s_0),
  .arlock_axi_s_0       (arlock_switch2_ib4_axi_s_0),
  .arcache_axi_s_0      (arcache_switch2_ib4_axi_s_0),
  .arprot_axi_s_0       (arprot_switch2_ib4_axi_s_0),
  .arvalid_axi_s_0      (arvalid_switch2_ib4_axi_s_0),
  .arvalid_vect_axi_s_0 (arvalid_vect_switch2_ib4_axi_s_0),
  .arready_axi_s_0      (arready_switch2_ib4_axi_s_0),
  .rid_axi_s_0          (rid_switch2_ib4_axi_s_0),
  .rdata_axi_s_0        (rdata_switch2_ib4_axi_s_0),
  .rresp_axi_s_0        (rresp_switch2_ib4_axi_s_0),
  .rlast_axi_s_0        (rlast_switch2_ib4_axi_s_0),
  .rvalid_axi_s_0       (rvalid_switch2_ib4_axi_s_0),
  .rready_axi_s_0       (rready_switch2_ib4_axi_s_0),
  .awuser_axi_s_0       (awuser_switch2_ib4_axi_s_0),
  .buser_axi_s_0        (buser_switch2_ib4_axi_s_0),
  .aruser_axi_s_0       (aruser_switch2_ib4_axi_s_0),
  .ruser_axi_s_0        (ruser_switch2_ib4_axi_s_0),
  .awqv_axi_s_0         (awqv_switch2_ib4_axi_s_0),
  .arqv_axi_s_0         (arqv_switch2_ib4_axi_s_0),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_ib4_int),
  .aw_valid             (aw_valid_ib4_int),
  .aw_ready             (aw_ready_ib4_int),
  .b_data               (b_data_ib4_int),
  .b_valid              (b_valid_ib4_int),
  .b_ready              (b_ready_ib4_int),
  .ar_data              (ar_data_ib4_int),
  .ar_valid             (ar_valid_ib4_int),
  .ar_ready             (ar_ready_ib4_int),
  .r_data               (r_data_ib4_int),
  .r_valid              (r_valid_ib4_int),
  .r_ready              (r_ready_ib4_int),
  .w_data               (w_data_ib4_int),
  .w_valid              (w_valid_ib4_int),
  .w_ready              (w_ready_ib4_int)
);


nic400_ib_ocvm_axim_ib_master_domain_sse710_main     u_ib_ocvm_axim_ib_m (
  .awid_axi4_m          (awid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awaddr_axi4_m        (awaddr_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awlen_axi4_m         (awlen_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awsize_axi4_m        (awsize_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awburst_axi4_m       (awburst_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awlock_axi4_m        (awlock_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awcache_axi4_m       (awcache_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awprot_axi4_m        (awprot_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awvalid_axi4_m       (awvalid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awready_axi4_m       (awready_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .wdata_axi4_m         (wdata_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .wstrb_axi4_m         (wstrb_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .wlast_axi4_m         (wlast_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .wvalid_axi4_m        (wvalid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .wready_axi4_m        (wready_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .bid_axi4_m           (bid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .bresp_axi4_m         (bresp_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .bvalid_axi4_m        (bvalid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .bready_axi4_m        (bready_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arid_axi4_m          (arid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .araddr_axi4_m        (araddr_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arlen_axi4_m         (arlen_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arsize_axi4_m        (arsize_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arburst_axi4_m       (arburst_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arlock_axi4_m        (arlock_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arcache_axi4_m       (arcache_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arprot_axi4_m        (arprot_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arvalid_axi4_m       (arvalid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arready_axi4_m       (arready_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .rid_axi4_m           (rid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .rdata_axi4_m         (rdata_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .rresp_axi4_m         (rresp_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .rlast_axi4_m         (rlast_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .rvalid_axi4_m        (rvalid_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .rready_axi4_m        (rready_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awuser_axi4_m        (awuser_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .buser_axi4_m         (buser_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .aruser_axi4_m        (aruser_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .ruser_axi4_m         (ruser_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .awqv_axi4_m          (awqv_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .arqv_axi4_m          (arqv_ocvm_axim_ib_ocvm_axim_ocvm_axim_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_ocvm_axim_ib_int),
  .aw_valid             (aw_valid_ocvm_axim_ib_int),
  .aw_ready             (aw_ready_ocvm_axim_ib_int),
  .b_data               (b_data_ocvm_axim_ib_int),
  .b_valid              (b_valid_ocvm_axim_ib_int),
  .b_ready              (b_ready_ocvm_axim_ib_int),
  .ar_data              (ar_data_ocvm_axim_ib_int),
  .ar_valid             (ar_valid_ocvm_axim_ib_int),
  .ar_ready             (ar_ready_ocvm_axim_ib_int),
  .r_data               (r_data_ocvm_axim_ib_int),
  .r_valid              (r_valid_ocvm_axim_ib_int),
  .r_ready              (r_ready_ocvm_axim_ib_int),
  .w_data               (w_data_ocvm_axim_ib_int),
  .w_valid              (w_valid_ocvm_axim_ib_int),
  .w_ready              (w_ready_ocvm_axim_ib_int)
);


nic400_ib_ocvm_axim_ib_slave_domain_sse710_main     u_ib_ocvm_axim_ib_s (
  .awid_axi4_s          (awid_switch2_ocvm_axim_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_switch2_ocvm_axim_ib_axi4_s),
  .awlen_axi4_s         (awlen_switch2_ocvm_axim_ib_axi4_s),
  .awsize_axi4_s        (awsize_switch2_ocvm_axim_ib_axi4_s),
  .awburst_axi4_s       (awburst_switch2_ocvm_axim_ib_axi4_s),
  .awlock_axi4_s        (awlock_switch2_ocvm_axim_ib_axi4_s),
  .awcache_axi4_s       (awcache_switch2_ocvm_axim_ib_axi4_s),
  .awprot_axi4_s        (awprot_switch2_ocvm_axim_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_switch2_ocvm_axim_ib_axi4_s),
  .awready_axi4_s       (awready_switch2_ocvm_axim_ib_axi4_s),
  .wdata_axi4_s         (wdata_switch2_ocvm_axim_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_switch2_ocvm_axim_ib_axi4_s),
  .wlast_axi4_s         (wlast_switch2_ocvm_axim_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_switch2_ocvm_axim_ib_axi4_s),
  .wready_axi4_s        (wready_switch2_ocvm_axim_ib_axi4_s),
  .bid_axi4_s           (bid_switch2_ocvm_axim_ib_axi4_s),
  .bresp_axi4_s         (bresp_switch2_ocvm_axim_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_switch2_ocvm_axim_ib_axi4_s),
  .bready_axi4_s        (bready_switch2_ocvm_axim_ib_axi4_s),
  .arid_axi4_s          (arid_switch2_ocvm_axim_ib_axi4_s),
  .araddr_axi4_s        (araddr_switch2_ocvm_axim_ib_axi4_s),
  .arlen_axi4_s         (arlen_switch2_ocvm_axim_ib_axi4_s),
  .arsize_axi4_s        (arsize_switch2_ocvm_axim_ib_axi4_s),
  .arburst_axi4_s       (arburst_switch2_ocvm_axim_ib_axi4_s),
  .arlock_axi4_s        (arlock_switch2_ocvm_axim_ib_axi4_s),
  .arcache_axi4_s       (arcache_switch2_ocvm_axim_ib_axi4_s),
  .arprot_axi4_s        (arprot_switch2_ocvm_axim_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_switch2_ocvm_axim_ib_axi4_s),
  .arready_axi4_s       (arready_switch2_ocvm_axim_ib_axi4_s),
  .rid_axi4_s           (rid_switch2_ocvm_axim_ib_axi4_s),
  .rdata_axi4_s         (rdata_switch2_ocvm_axim_ib_axi4_s),
  .rresp_axi4_s         (rresp_switch2_ocvm_axim_ib_axi4_s),
  .rlast_axi4_s         (rlast_switch2_ocvm_axim_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_switch2_ocvm_axim_ib_axi4_s),
  .rready_axi4_s        (rready_switch2_ocvm_axim_ib_axi4_s),
  .awuser_axi4_s        (awuser_switch2_ocvm_axim_ib_axi4_s),
  .buser_axi4_s         (buser_switch2_ocvm_axim_ib_axi4_s),
  .aruser_axi4_s        (aruser_switch2_ocvm_axim_ib_axi4_s),
  .ruser_axi4_s         (ruser_switch2_ocvm_axim_ib_axi4_s),
  .awqv_axi4_s          (awqv_switch2_ocvm_axim_ib_axi4_s),
  .arqv_axi4_s          (arqv_switch2_ocvm_axim_ib_axi4_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_ocvm_axim_ib_int),
  .aw_valid             (aw_valid_ocvm_axim_ib_int),
  .aw_ready             (aw_ready_ocvm_axim_ib_int),
  .b_data               (b_data_ocvm_axim_ib_int),
  .b_valid              (b_valid_ocvm_axim_ib_int),
  .b_ready              (b_ready_ocvm_axim_ib_int),
  .ar_data              (ar_data_ocvm_axim_ib_int),
  .ar_valid             (ar_valid_ocvm_axim_ib_int),
  .ar_ready             (ar_ready_ocvm_axim_ib_int),
  .r_data               (r_data_ocvm_axim_ib_int),
  .r_valid              (r_valid_ocvm_axim_ib_int),
  .r_ready              (r_ready_ocvm_axim_ib_int),
  .w_data               (w_data_ocvm_axim_ib_int),
  .w_valid              (w_valid_ocvm_axim_ib_int),
  .w_ready              (w_ready_ocvm_axim_ib_int)
);


nic400_ib_secenc_axis_ib_master_domain_sse710_main     u_ib_secenc_axis_ib_m (
  .paddr                (paddr_secenc_axis_ib_apb),
  .pwdata               (pwdata_secenc_axis_ib_apb),
  .pwrite               (pwrite_secenc_axis_ib_apb),
  .penable              (penable_secenc_axis_ib_apb),
  .psel                 (pselx_secenc_axis_ib_apb),
  .prdata               (prdata_secenc_axis_ib_apb),
  .pslverr              (pslverr_secenc_axis_ib_apb),
  .pready               (pready_secenc_axis_ib_apb),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .apbm_req             (preq_secenc_axis_ib_apb_int),
  .apbm_ack             (pack_secenc_axis_ib_apb_int),
  .apbm_fwd_data        (pfwdpayld_secenc_axis_ib_apb_int),
  .apbm_rev_data        (prevpayld_secenc_axis_ib_apb_int),
  .awid_axi4_m          (awid_secenc_axis_ib_switch1_axi_s_0),
  .awaddr_axi4_m        (awaddr_secenc_axis_ib_switch1_axi_s_0),
  .awlen_axi4_m         (awlen_secenc_axis_ib_switch1_axi_s_0),
  .awsize_axi4_m        (awsize_secenc_axis_ib_switch1_axi_s_0),
  .awburst_axi4_m       (awburst_secenc_axis_ib_switch1_axi_s_0),
  .awlock_axi4_m        (awlock_secenc_axis_ib_switch1_axi_s_0),
  .awcache_axi4_m       (awcache_secenc_axis_ib_switch1_axi_s_0),
  .awprot_axi4_m        (awprot_secenc_axis_ib_switch1_axi_s_0),
  .awvalid_axi4_m       (awvalid_secenc_axis_ib_switch1_axi_s_0),
  .awvalid_vect_axi4_m  (awvalid_vect_secenc_axis_ib_switch1_axi_s_0),
  .awready_axi4_m       (awready_secenc_axis_ib_switch1_axi_s_0),
  .wdata_axi4_m         (wdata_secenc_axis_ib_switch1_axi_s_0),
  .wstrb_axi4_m         (wstrb_secenc_axis_ib_switch1_axi_s_0),
  .wlast_axi4_m         (wlast_secenc_axis_ib_switch1_axi_s_0),
  .wvalid_axi4_m        (wvalid_secenc_axis_ib_switch1_axi_s_0),
  .wready_axi4_m        (wready_secenc_axis_ib_switch1_axi_s_0),
  .bid_axi4_m           (bid_secenc_axis_ib_switch1_axi_s_0),
  .bresp_axi4_m         (bresp_secenc_axis_ib_switch1_axi_s_0),
  .bvalid_axi4_m        (bvalid_secenc_axis_ib_switch1_axi_s_0),
  .bready_axi4_m        (bready_secenc_axis_ib_switch1_axi_s_0),
  .arid_axi4_m          (arid_secenc_axis_ib_switch1_axi_s_0),
  .araddr_axi4_m        (araddr_secenc_axis_ib_switch1_axi_s_0),
  .arlen_axi4_m         (arlen_secenc_axis_ib_switch1_axi_s_0),
  .arsize_axi4_m        (arsize_secenc_axis_ib_switch1_axi_s_0),
  .arburst_axi4_m       (arburst_secenc_axis_ib_switch1_axi_s_0),
  .arlock_axi4_m        (arlock_secenc_axis_ib_switch1_axi_s_0),
  .arcache_axi4_m       (arcache_secenc_axis_ib_switch1_axi_s_0),
  .arprot_axi4_m        (arprot_secenc_axis_ib_switch1_axi_s_0),
  .arvalid_axi4_m       (arvalid_secenc_axis_ib_switch1_axi_s_0),
  .arvalid_vect_axi4_m  (arvalid_vect_secenc_axis_ib_switch1_axi_s_0),
  .arready_axi4_m       (arready_secenc_axis_ib_switch1_axi_s_0),
  .rid_axi4_m           (rid_secenc_axis_ib_switch1_axi_s_0),
  .rdata_axi4_m         (rdata_secenc_axis_ib_switch1_axi_s_0),
  .rresp_axi4_m         (rresp_secenc_axis_ib_switch1_axi_s_0),
  .rlast_axi4_m         (rlast_secenc_axis_ib_switch1_axi_s_0),
  .rvalid_axi4_m        (rvalid_secenc_axis_ib_switch1_axi_s_0),
  .rready_axi4_m        (rready_secenc_axis_ib_switch1_axi_s_0),
  .awuser_axi4_m        (awuser_secenc_axis_ib_switch1_axi_s_0),
  .buser_axi4_m         (buser_secenc_axis_ib_switch1_axi_s_0),
  .aruser_axi4_m        (aruser_secenc_axis_ib_switch1_axi_s_0),
  .ruser_axi4_m         (ruser_secenc_axis_ib_switch1_axi_s_0),
  .awqv_axi4_m          (awqv_secenc_axis_ib_switch1_axi_s_0),
  .arqv_axi4_m          (arqv_secenc_axis_ib_switch1_axi_s_0),
  .aw_data              (aw_data_secenc_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_secenc_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_secenc_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_secenc_axis_ib_int),
  .b_data               (b_data_secenc_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_secenc_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_secenc_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_secenc_axis_ib_int),
  .ar_data              (ar_data_secenc_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_secenc_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_secenc_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_secenc_axis_ib_int),
  .r_data               (r_data_secenc_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_secenc_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_secenc_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_secenc_axis_ib_int),
  .w_data               (w_data_secenc_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_secenc_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_secenc_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_secenc_axis_ib_int)
);


nic400_ib_secenc_axis_ib_slave_domain_sse710_main     u_ib_secenc_axis_ib_s (
  .apbs_req             (preq_secenc_axis_ib_apb_int),
  .apbs_ack             (pack_secenc_axis_ib_apb_int),
  .apbs_fwd_data        (pfwdpayld_secenc_axis_ib_apb_int),
  .apbs_rev_data        (prevpayld_secenc_axis_ib_apb_int),
  .paddrm               (paddr_secenc_axis_apb),
  .pwdatam              (pwdata_secenc_axis_apb),
  .pwritem              (pwrite_secenc_axis_apb),
  .penablem             (penable_secenc_axis_apb),
  .pselm                (pselx_secenc_axis_apb),
  .prdatam              (prdata_secenc_axis_apb),
  .pslverrm             (pslverr_secenc_axis_apb),
  .preadym              (pready_secenc_axis_apb),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .awid_axi4_s          (awid_secenc_axis_secenc_axis_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_secenc_axis_secenc_axis_ib_axi4_s),
  .awlen_axi4_s         (awlen_secenc_axis_secenc_axis_ib_axi4_s),
  .awsize_axi4_s        (awsize_secenc_axis_secenc_axis_ib_axi4_s),
  .awburst_axi4_s       (awburst_secenc_axis_secenc_axis_ib_axi4_s),
  .awlock_axi4_s        (awlock_secenc_axis_secenc_axis_ib_axi4_s),
  .awcache_axi4_s       (awcache_secenc_axis_secenc_axis_ib_axi4_s),
  .awprot_axi4_s        (awprot_secenc_axis_secenc_axis_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_secenc_axis_secenc_axis_ib_axi4_s),
  .awvalid_vect_axi4_s  (awvalid_vect_secenc_axis_secenc_axis_ib_axi4_s),
  .awready_axi4_s       (awready_secenc_axis_secenc_axis_ib_axi4_s),
  .wdata_axi4_s         (wdata_secenc_axis_secenc_axis_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_secenc_axis_secenc_axis_ib_axi4_s),
  .wlast_axi4_s         (wlast_secenc_axis_secenc_axis_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_secenc_axis_secenc_axis_ib_axi4_s),
  .wready_axi4_s        (wready_secenc_axis_secenc_axis_ib_axi4_s),
  .bid_axi4_s           (bid_secenc_axis_secenc_axis_ib_axi4_s),
  .bresp_axi4_s         (bresp_secenc_axis_secenc_axis_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_secenc_axis_secenc_axis_ib_axi4_s),
  .bready_axi4_s        (bready_secenc_axis_secenc_axis_ib_axi4_s),
  .arid_axi4_s          (arid_secenc_axis_secenc_axis_ib_axi4_s),
  .araddr_axi4_s        (araddr_secenc_axis_secenc_axis_ib_axi4_s),
  .arlen_axi4_s         (arlen_secenc_axis_secenc_axis_ib_axi4_s),
  .arsize_axi4_s        (arsize_secenc_axis_secenc_axis_ib_axi4_s),
  .arburst_axi4_s       (arburst_secenc_axis_secenc_axis_ib_axi4_s),
  .arlock_axi4_s        (arlock_secenc_axis_secenc_axis_ib_axi4_s),
  .arcache_axi4_s       (arcache_secenc_axis_secenc_axis_ib_axi4_s),
  .arprot_axi4_s        (arprot_secenc_axis_secenc_axis_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_secenc_axis_secenc_axis_ib_axi4_s),
  .arvalid_vect_axi4_s  (arvalid_vect_secenc_axis_secenc_axis_ib_axi4_s),
  .arready_axi4_s       (arready_secenc_axis_secenc_axis_ib_axi4_s),
  .rid_axi4_s           (rid_secenc_axis_secenc_axis_ib_axi4_s),
  .rdata_axi4_s         (rdata_secenc_axis_secenc_axis_ib_axi4_s),
  .rresp_axi4_s         (rresp_secenc_axis_secenc_axis_ib_axi4_s),
  .rlast_axi4_s         (rlast_secenc_axis_secenc_axis_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_secenc_axis_secenc_axis_ib_axi4_s),
  .rready_axi4_s        (rready_secenc_axis_secenc_axis_ib_axi4_s),
  .awuser_axi4_s        (awuser_secenc_axis_secenc_axis_ib_axi4_s),
  .buser_axi4_s         (buser_secenc_axis_secenc_axis_ib_axi4_s),
  .aruser_axi4_s        (aruser_secenc_axis_secenc_axis_ib_axi4_s),
  .ruser_axi4_s         (ruser_secenc_axis_secenc_axis_ib_axi4_s),
  .aw_data              (aw_data_secenc_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_secenc_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_secenc_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_secenc_axis_ib_int),
  .b_data               (b_data_secenc_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_secenc_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_secenc_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_secenc_axis_ib_int),
  .ar_data              (ar_data_secenc_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_secenc_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_secenc_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_secenc_axis_ib_int),
  .r_data               (r_data_secenc_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_secenc_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_secenc_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_secenc_axis_ib_int),
  .w_data               (w_data_secenc_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_secenc_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_secenc_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_secenc_axis_ib_int)
);


nic400_ib_xnvm_axim_ib_master_domain_sse710_main     u_ib_xnvm_axim_ib_m (
  .awid_axi4_m          (awid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awaddr_axi4_m        (awaddr_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awlen_axi4_m         (awlen_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awsize_axi4_m        (awsize_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awburst_axi4_m       (awburst_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awlock_axi4_m        (awlock_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awcache_axi4_m       (awcache_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awprot_axi4_m        (awprot_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awvalid_axi4_m       (awvalid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awready_axi4_m       (awready_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .wdata_axi4_m         (wdata_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .wstrb_axi4_m         (wstrb_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .wlast_axi4_m         (wlast_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .wvalid_axi4_m        (wvalid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .wready_axi4_m        (wready_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .bid_axi4_m           (bid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .bresp_axi4_m         (bresp_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .bvalid_axi4_m        (bvalid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .bready_axi4_m        (bready_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arid_axi4_m          (arid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .araddr_axi4_m        (araddr_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arlen_axi4_m         (arlen_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arsize_axi4_m        (arsize_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arburst_axi4_m       (arburst_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arlock_axi4_m        (arlock_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arcache_axi4_m       (arcache_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arprot_axi4_m        (arprot_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arvalid_axi4_m       (arvalid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arready_axi4_m       (arready_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .rid_axi4_m           (rid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .rdata_axi4_m         (rdata_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .rresp_axi4_m         (rresp_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .rlast_axi4_m         (rlast_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .rvalid_axi4_m        (rvalid_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .rready_axi4_m        (rready_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awuser_axi4_m        (awuser_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .buser_axi4_m         (buser_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .aruser_axi4_m        (aruser_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .ruser_axi4_m         (ruser_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .awqv_axi4_m          (awqv_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .arqv_axi4_m          (arqv_xnvm_axim_ib_xnvm_axim_xnvm_axim_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_xnvm_axim_ib_int),
  .aw_valid             (aw_valid_xnvm_axim_ib_int),
  .aw_ready             (aw_ready_xnvm_axim_ib_int),
  .b_data               (b_data_xnvm_axim_ib_int),
  .b_valid              (b_valid_xnvm_axim_ib_int),
  .b_ready              (b_ready_xnvm_axim_ib_int),
  .ar_data              (ar_data_xnvm_axim_ib_int),
  .ar_valid             (ar_valid_xnvm_axim_ib_int),
  .ar_ready             (ar_ready_xnvm_axim_ib_int),
  .r_data               (r_data_xnvm_axim_ib_int),
  .r_valid              (r_valid_xnvm_axim_ib_int),
  .r_ready              (r_ready_xnvm_axim_ib_int),
  .w_data               (w_data_xnvm_axim_ib_int),
  .w_valid              (w_valid_xnvm_axim_ib_int),
  .w_ready              (w_ready_xnvm_axim_ib_int)
);


nic400_ib_xnvm_axim_ib_slave_domain_sse710_main     u_ib_xnvm_axim_ib_s (
  .awid_axi4_s          (awid_switch2_xnvm_axim_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_switch2_xnvm_axim_ib_axi4_s),
  .awlen_axi4_s         (awlen_switch2_xnvm_axim_ib_axi4_s),
  .awsize_axi4_s        (awsize_switch2_xnvm_axim_ib_axi4_s),
  .awburst_axi4_s       (awburst_switch2_xnvm_axim_ib_axi4_s),
  .awlock_axi4_s        (awlock_switch2_xnvm_axim_ib_axi4_s),
  .awcache_axi4_s       (awcache_switch2_xnvm_axim_ib_axi4_s),
  .awprot_axi4_s        (awprot_switch2_xnvm_axim_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_switch2_xnvm_axim_ib_axi4_s),
  .awready_axi4_s       (awready_switch2_xnvm_axim_ib_axi4_s),
  .wdata_axi4_s         (wdata_switch2_xnvm_axim_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_switch2_xnvm_axim_ib_axi4_s),
  .wlast_axi4_s         (wlast_switch2_xnvm_axim_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_switch2_xnvm_axim_ib_axi4_s),
  .wready_axi4_s        (wready_switch2_xnvm_axim_ib_axi4_s),
  .bid_axi4_s           (bid_switch2_xnvm_axim_ib_axi4_s),
  .bresp_axi4_s         (bresp_switch2_xnvm_axim_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_switch2_xnvm_axim_ib_axi4_s),
  .bready_axi4_s        (bready_switch2_xnvm_axim_ib_axi4_s),
  .arid_axi4_s          (arid_switch2_xnvm_axim_ib_axi4_s),
  .araddr_axi4_s        (araddr_switch2_xnvm_axim_ib_axi4_s),
  .arlen_axi4_s         (arlen_switch2_xnvm_axim_ib_axi4_s),
  .arsize_axi4_s        (arsize_switch2_xnvm_axim_ib_axi4_s),
  .arburst_axi4_s       (arburst_switch2_xnvm_axim_ib_axi4_s),
  .arlock_axi4_s        (arlock_switch2_xnvm_axim_ib_axi4_s),
  .arcache_axi4_s       (arcache_switch2_xnvm_axim_ib_axi4_s),
  .arprot_axi4_s        (arprot_switch2_xnvm_axim_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_switch2_xnvm_axim_ib_axi4_s),
  .arready_axi4_s       (arready_switch2_xnvm_axim_ib_axi4_s),
  .rid_axi4_s           (rid_switch2_xnvm_axim_ib_axi4_s),
  .rdata_axi4_s         (rdata_switch2_xnvm_axim_ib_axi4_s),
  .rresp_axi4_s         (rresp_switch2_xnvm_axim_ib_axi4_s),
  .rlast_axi4_s         (rlast_switch2_xnvm_axim_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_switch2_xnvm_axim_ib_axi4_s),
  .rready_axi4_s        (rready_switch2_xnvm_axim_ib_axi4_s),
  .awuser_axi4_s        (awuser_switch2_xnvm_axim_ib_axi4_s),
  .buser_axi4_s         (buser_switch2_xnvm_axim_ib_axi4_s),
  .aruser_axi4_s        (aruser_switch2_xnvm_axim_ib_axi4_s),
  .ruser_axi4_s         (ruser_switch2_xnvm_axim_ib_axi4_s),
  .awqv_axi4_s          (awqv_switch2_xnvm_axim_ib_axi4_s),
  .arqv_axi4_s          (arqv_switch2_xnvm_axim_ib_axi4_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_xnvm_axim_ib_int),
  .aw_valid             (aw_valid_xnvm_axim_ib_int),
  .aw_ready             (aw_ready_xnvm_axim_ib_int),
  .b_data               (b_data_xnvm_axim_ib_int),
  .b_valid              (b_valid_xnvm_axim_ib_int),
  .b_ready              (b_ready_xnvm_axim_ib_int),
  .ar_data              (ar_data_xnvm_axim_ib_int),
  .ar_valid             (ar_valid_xnvm_axim_ib_int),
  .ar_ready             (ar_ready_xnvm_axim_ib_int),
  .r_data               (r_data_xnvm_axim_ib_int),
  .r_valid              (r_valid_xnvm_axim_ib_int),
  .r_ready              (r_ready_xnvm_axim_ib_int),
  .w_data               (w_data_xnvm_axim_ib_int),
  .w_valid              (w_valid_xnvm_axim_ib_int),
  .w_ready              (w_ready_xnvm_axim_ib_int)
);



endmodule
