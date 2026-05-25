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




module nic400_sse710_main (
  

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
  

  csysreq_cd_a,
  csysack_cd_a,
  cactive_cd_a,
  

  awid_cvm_axim,
  awaddr_cvm_axim,
  awlen_cvm_axim,
  awsize_cvm_axim,
  awburst_cvm_axim,
  awlock_cvm_axim,
  awcache_cvm_axim,
  awprot_cvm_axim,
  awqos_cvm_axim,
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
  arqos_cvm_axim,
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
  

  awid_expmstr0_axim,
  awaddr_expmstr0_axim,
  awlen_expmstr0_axim,
  awsize_expmstr0_axim,
  awburst_expmstr0_axim,
  awlock_expmstr0_axim,
  awcache_expmstr0_axim,
  awprot_expmstr0_axim,
  awqos_expmstr0_axim,
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
  arqos_expmstr0_axim,
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
  

  awid_expmstr1_axim,
  awaddr_expmstr1_axim,
  awlen_expmstr1_axim,
  awsize_expmstr1_axim,
  awburst_expmstr1_axim,
  awlock_expmstr1_axim,
  awcache_expmstr1_axim,
  awprot_expmstr1_axim,
  awqos_expmstr1_axim,
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
  arqos_expmstr1_axim,
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
  

  awid_expslv0_axis,
  awaddr_expslv0_axis,
  awlen_expslv0_axis,
  awsize_expslv0_axis,
  awburst_expslv0_axis,
  awlock_expslv0_axis,
  awcache_expslv0_axis,
  awprot_expslv0_axis,
  awqos_expslv0_axis,
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
  arqos_expslv0_axis,
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
  

  awid_expslv1_axis,
  awaddr_expslv1_axis,
  awlen_expslv1_axis,
  awsize_expslv1_axis,
  awburst_expslv1_axis,
  awlock_expslv1_axis,
  awcache_expslv1_axis,
  awprot_expslv1_axis,
  awqos_expslv1_axis,
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
  arqos_expslv1_axis,
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
  

  awid_ocvm_axim,
  awaddr_ocvm_axim,
  awlen_ocvm_axim,
  awsize_ocvm_axim,
  awburst_ocvm_axim,
  awlock_ocvm_axim,
  awcache_ocvm_axim,
  awprot_ocvm_axim,
  awqos_ocvm_axim,
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
  arqos_ocvm_axim,
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
  awqos_xnvm_axim,
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
  arqos_xnvm_axim,
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
  

  cactive_cd_main,
  

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


  aclk,
  aclk_r,
  aresetn,
  aresetn_r,
  mainclk,
  mainresetn

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


input         csysreq_cd_a;
output        csysack_cd_a;
output        cactive_cd_a;


output [11:0] awid_cvm_axim;
output [31:0] awaddr_cvm_axim;
output [7:0]  awlen_cvm_axim;
output [2:0]  awsize_cvm_axim;
output [1:0]  awburst_cvm_axim;
output        awlock_cvm_axim;
output [3:0]  awcache_cvm_axim;
output [2:0]  awprot_cvm_axim;
output [3:0]  awqos_cvm_axim;
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
output [3:0]  arqos_cvm_axim;
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


output [11:0] awid_expmstr0_axim;
output [31:0] awaddr_expmstr0_axim;
output [7:0]  awlen_expmstr0_axim;
output [2:0]  awsize_expmstr0_axim;
output [1:0]  awburst_expmstr0_axim;
output        awlock_expmstr0_axim;
output [3:0]  awcache_expmstr0_axim;
output [2:0]  awprot_expmstr0_axim;
output [3:0]  awqos_expmstr0_axim;
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
output [3:0]  arqos_expmstr0_axim;
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


output [11:0] awid_expmstr1_axim;
output [31:0] awaddr_expmstr1_axim;
output [7:0]  awlen_expmstr1_axim;
output [2:0]  awsize_expmstr1_axim;
output [1:0]  awburst_expmstr1_axim;
output        awlock_expmstr1_axim;
output [3:0]  awcache_expmstr1_axim;
output [2:0]  awprot_expmstr1_axim;
output [3:0]  awqos_expmstr1_axim;
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
output [3:0]  arqos_expmstr1_axim;
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


input  [7:0]  awid_expslv0_axis;
input  [31:0] awaddr_expslv0_axis;
input  [7:0]  awlen_expslv0_axis;
input  [2:0]  awsize_expslv0_axis;
input  [1:0]  awburst_expslv0_axis;
input         awlock_expslv0_axis;
input  [3:0]  awcache_expslv0_axis;
input  [2:0]  awprot_expslv0_axis;
input  [3:0]  awqos_expslv0_axis;
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
input  [3:0]  arqos_expslv0_axis;
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


input  [7:0]  awid_expslv1_axis;
input  [31:0] awaddr_expslv1_axis;
input  [7:0]  awlen_expslv1_axis;
input  [2:0]  awsize_expslv1_axis;
input  [1:0]  awburst_expslv1_axis;
input         awlock_expslv1_axis;
input  [3:0]  awcache_expslv1_axis;
input  [2:0]  awprot_expslv1_axis;
input  [3:0]  awqos_expslv1_axis;
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
input  [3:0]  arqos_expslv1_axis;
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


output [11:0] awid_ocvm_axim;
output [31:0] awaddr_ocvm_axim;
output [7:0]  awlen_ocvm_axim;
output [2:0]  awsize_ocvm_axim;
output [1:0]  awburst_ocvm_axim;
output        awlock_ocvm_axim;
output [3:0]  awcache_ocvm_axim;
output [2:0]  awprot_ocvm_axim;
output [3:0]  awqos_ocvm_axim;
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
output [3:0]  arqos_ocvm_axim;
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
output [3:0]  awqos_xnvm_axim;
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
output [3:0]  arqos_xnvm_axim;
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


output        cactive_cd_main;


input  [31:0] haddr_gpvmain_ahb;
input  [2:0]  hburst_gpvmain_ahb;
input  [3:0]  hprot_gpvmain_ahb;
input  [2:0]  hsize_gpvmain_ahb;
input  [1:0]  htrans_gpvmain_ahb;
input  [31:0] hwdata_gpvmain_ahb;
input         hwrite_gpvmain_ahb;
output [31:0] hrdata_gpvmain_ahb;
output        hreadyout_gpvmain_ahb;
output        hresp_gpvmain_ahb;
input         hselx_gpvmain_ahb;
input         hready_gpvmain_ahb;


input         aclk;
input         aclk_r;
input         aresetn;
input         aresetn_r;
input         mainclk;
input         mainresetn;




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
wire           cactive_cd_main;
wire           csysack_cd_a;
wire   [31:0]  hrdata_gpvmain_ahb;
wire           hreadyout_gpvmain_ahb;
wire           hresp_gpvmain_ahb;
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
wire   [73:0]  a_data_gpv_0_ib1_int;    
wire           a_ready_gpvmain_ahb_ib_int;    
wire           a_valid_gpv_0_ib1_int;    
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
wire   [36:0]  w_data_gpv_0_ib1_int;    
wire           w_ready_gpvmain_ahb_ib_int;    
wire           w_valid_gpv_0_ib1_int;    
wire   [51:0]  a_data_gpvmain_ahb_ib_int;    
wire           a_valid_gpvmain_ahb_ib_int;    
wire           d_ready_gpvmain_ahb_ib_int;    
wire           empty_gpvmain_ahb_ib_int;    
wire   [36:0]  w_data_gpvmain_ahb_ib_int;    
wire           w_valid_gpvmain_ahb_ib_int;    
wire           a_ready_gpv_0_ib1_int;    
wire   [47:0]  d_data_gpv_0_ib1_int;    
wire           d_valid_gpv_0_ib1_int;    
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
wire   [1:0]   rsb_bin_rptr_a_ml_s;    
wire   [1:0]   rsb_bin_rptr_a_sl_s;    
wire   [7:0]   rsb_data_a_ml_m;    
wire   [7:0]   rsb_data_a_sl_m;    
wire   [2:0]   rsb_rptr_a_ml_s;    
wire   [2:0]   rsb_rptr_a_sl_s;    
wire   [2:0]   rsb_wptr_a_ml_m;    
wire   [2:0]   rsb_wptr_a_sl_m;    
wire           w_ready_gpv_0_ib1_int;    
wire   [1:0]   rsb_bin_rptr_a_ml_m;    
wire   [1:0]   rsb_bin_rptr_a_sl_m;    
wire   [7:0]   rsb_data_a_ml_s;    
wire   [7:0]   rsb_data_a_sl_s;    
wire   [2:0]   rsb_rptr_a_ml_m;    
wire   [2:0]   rsb_rptr_a_sl_m;    
wire   [2:0]   rsb_wptr_a_ml_s;    
wire   [2:0]   rsb_wptr_a_sl_s;    
wire           aclk;
wire           aclk_r;
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
wire           aresetn_r;
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
wire   [31:0]  haddr_gpvmain_ahb;
wire   [2:0]   hburst_gpvmain_ahb;
wire   [3:0]   hprot_gpvmain_ahb;
wire           hready_gpvmain_ahb;
wire           hselx_gpvmain_ahb;
wire   [2:0]   hsize_gpvmain_ahb;
wire   [1:0]   htrans_gpvmain_ahb;
wire   [31:0]  hwdata_gpvmain_ahb;
wire           hwrite_gpvmain_ahb;
wire           mainclk;
wire           mainresetn;
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




nic400_cd_a_sse710_main     u_cd_a (
  .awid_bootreg_axim    (awid_bootreg_axim),    
  .awaddr_bootreg_axim  (awaddr_bootreg_axim),    
  .awlen_bootreg_axim   (awlen_bootreg_axim),    
  .awsize_bootreg_axim  (awsize_bootreg_axim),    
  .awburst_bootreg_axim (awburst_bootreg_axim),    
  .awlock_bootreg_axim  (awlock_bootreg_axim),    
  .awcache_bootreg_axim (awcache_bootreg_axim),    
  .awprot_bootreg_axim  (awprot_bootreg_axim),    
  .awvalid_bootreg_axim (awvalid_bootreg_axim),    
  .awready_bootreg_axim (awready_bootreg_axim),    
  .wdata_bootreg_axim   (wdata_bootreg_axim),    
  .wstrb_bootreg_axim   (wstrb_bootreg_axim),    
  .wlast_bootreg_axim   (wlast_bootreg_axim),    
  .wvalid_bootreg_axim  (wvalid_bootreg_axim),    
  .wready_bootreg_axim  (wready_bootreg_axim),    
  .bid_bootreg_axim     (bid_bootreg_axim),    
  .bresp_bootreg_axim   (bresp_bootreg_axim),    
  .bvalid_bootreg_axim  (bvalid_bootreg_axim),    
  .bready_bootreg_axim  (bready_bootreg_axim),    
  .arid_bootreg_axim    (arid_bootreg_axim),    
  .araddr_bootreg_axim  (araddr_bootreg_axim),    
  .arlen_bootreg_axim   (arlen_bootreg_axim),    
  .arsize_bootreg_axim  (arsize_bootreg_axim),    
  .arburst_bootreg_axim (arburst_bootreg_axim),    
  .arlock_bootreg_axim  (arlock_bootreg_axim),    
  .arcache_bootreg_axim (arcache_bootreg_axim),    
  .arprot_bootreg_axim  (arprot_bootreg_axim),    
  .arvalid_bootreg_axim (arvalid_bootreg_axim),    
  .arready_bootreg_axim (arready_bootreg_axim),    
  .rid_bootreg_axim     (rid_bootreg_axim),    
  .rdata_bootreg_axim   (rdata_bootreg_axim),    
  .rresp_bootreg_axim   (rresp_bootreg_axim),    
  .rlast_bootreg_axim   (rlast_bootreg_axim),    
  .rvalid_bootreg_axim  (rvalid_bootreg_axim),    
  .rready_bootreg_axim  (rready_bootreg_axim),    
  .awuser_bootreg_axim  (awuser_bootreg_axim),    
  .aruser_bootreg_axim  (aruser_bootreg_axim),    
  .csysreq_cd_a         (csysreq_cd_a),    
  .csysack_cd_a         (csysack_cd_a),    
  .cactive_cd_a         (cactive_cd_a),    
  .awid_cvm_axim        (awid_cvm_axim),    
  .awaddr_cvm_axim      (awaddr_cvm_axim),    
  .awlen_cvm_axim       (awlen_cvm_axim),    
  .awsize_cvm_axim      (awsize_cvm_axim),    
  .awburst_cvm_axim     (awburst_cvm_axim),    
  .awlock_cvm_axim      (awlock_cvm_axim),    
  .awcache_cvm_axim     (awcache_cvm_axim),    
  .awprot_cvm_axim      (awprot_cvm_axim),    
  .awqos_cvm_axim       (awqos_cvm_axim),    
  .awvalid_cvm_axim     (awvalid_cvm_axim),    
  .awready_cvm_axim     (awready_cvm_axim),    
  .wdata_cvm_axim       (wdata_cvm_axim),    
  .wstrb_cvm_axim       (wstrb_cvm_axim),    
  .wlast_cvm_axim       (wlast_cvm_axim),    
  .wvalid_cvm_axim      (wvalid_cvm_axim),    
  .wready_cvm_axim      (wready_cvm_axim),    
  .bid_cvm_axim         (bid_cvm_axim),    
  .bresp_cvm_axim       (bresp_cvm_axim),    
  .bvalid_cvm_axim      (bvalid_cvm_axim),    
  .bready_cvm_axim      (bready_cvm_axim),    
  .arid_cvm_axim        (arid_cvm_axim),    
  .araddr_cvm_axim      (araddr_cvm_axim),    
  .arlen_cvm_axim       (arlen_cvm_axim),    
  .arsize_cvm_axim      (arsize_cvm_axim),    
  .arburst_cvm_axim     (arburst_cvm_axim),    
  .arlock_cvm_axim      (arlock_cvm_axim),    
  .arcache_cvm_axim     (arcache_cvm_axim),    
  .arprot_cvm_axim      (arprot_cvm_axim),    
  .arqos_cvm_axim       (arqos_cvm_axim),    
  .arvalid_cvm_axim     (arvalid_cvm_axim),    
  .arready_cvm_axim     (arready_cvm_axim),    
  .rid_cvm_axim         (rid_cvm_axim),    
  .rdata_cvm_axim       (rdata_cvm_axim),    
  .rresp_cvm_axim       (rresp_cvm_axim),    
  .rlast_cvm_axim       (rlast_cvm_axim),    
  .rvalid_cvm_axim      (rvalid_cvm_axim),    
  .rready_cvm_axim      (rready_cvm_axim),    
  .awuser_cvm_axim      (awuser_cvm_axim),    
  .buser_cvm_axim       (buser_cvm_axim),    
  .aruser_cvm_axim      (aruser_cvm_axim),    
  .ruser_cvm_axim       (ruser_cvm_axim),    
  .awid_debug_axim      (awid_debug_axim),    
  .awaddr_debug_axim    (awaddr_debug_axim),    
  .awlen_debug_axim     (awlen_debug_axim),    
  .awsize_debug_axim    (awsize_debug_axim),    
  .awburst_debug_axim   (awburst_debug_axim),    
  .awlock_debug_axim    (awlock_debug_axim),    
  .awcache_debug_axim   (awcache_debug_axim),    
  .awprot_debug_axim    (awprot_debug_axim),    
  .awvalid_debug_axim   (awvalid_debug_axim),    
  .awready_debug_axim   (awready_debug_axim),    
  .wdata_debug_axim     (wdata_debug_axim),    
  .wstrb_debug_axim     (wstrb_debug_axim),    
  .wlast_debug_axim     (wlast_debug_axim),    
  .wvalid_debug_axim    (wvalid_debug_axim),    
  .wready_debug_axim    (wready_debug_axim),    
  .bid_debug_axim       (bid_debug_axim),    
  .bresp_debug_axim     (bresp_debug_axim),    
  .bvalid_debug_axim    (bvalid_debug_axim),    
  .bready_debug_axim    (bready_debug_axim),    
  .arid_debug_axim      (arid_debug_axim),    
  .araddr_debug_axim    (araddr_debug_axim),    
  .arlen_debug_axim     (arlen_debug_axim),    
  .arsize_debug_axim    (arsize_debug_axim),    
  .arburst_debug_axim   (arburst_debug_axim),    
  .arlock_debug_axim    (arlock_debug_axim),    
  .arcache_debug_axim   (arcache_debug_axim),    
  .arprot_debug_axim    (arprot_debug_axim),    
  .arvalid_debug_axim   (arvalid_debug_axim),    
  .arready_debug_axim   (arready_debug_axim),    
  .rid_debug_axim       (rid_debug_axim),    
  .rdata_debug_axim     (rdata_debug_axim),    
  .rresp_debug_axim     (rresp_debug_axim),    
  .rlast_debug_axim     (rlast_debug_axim),    
  .rvalid_debug_axim    (rvalid_debug_axim),    
  .rready_debug_axim    (rready_debug_axim),    
  .awuser_debug_axim    (awuser_debug_axim),    
  .buser_debug_axim     (buser_debug_axim),    
  .aruser_debug_axim    (aruser_debug_axim),    
  .ruser_debug_axim     (ruser_debug_axim),    
  .awid_debug_axis      (awid_debug_axis),    
  .awaddr_debug_axis    (awaddr_debug_axis),    
  .awlen_debug_axis     (awlen_debug_axis),    
  .awsize_debug_axis    (awsize_debug_axis),    
  .awburst_debug_axis   (awburst_debug_axis),    
  .awlock_debug_axis    (awlock_debug_axis),    
  .awcache_debug_axis   (awcache_debug_axis),    
  .awprot_debug_axis    (awprot_debug_axis),    
  .awvalid_debug_axis   (awvalid_debug_axis),    
  .awready_debug_axis   (awready_debug_axis),    
  .wdata_debug_axis     (wdata_debug_axis),    
  .wstrb_debug_axis     (wstrb_debug_axis),    
  .wlast_debug_axis     (wlast_debug_axis),    
  .wvalid_debug_axis    (wvalid_debug_axis),    
  .wready_debug_axis    (wready_debug_axis),    
  .bid_debug_axis       (bid_debug_axis),    
  .bresp_debug_axis     (bresp_debug_axis),    
  .bvalid_debug_axis    (bvalid_debug_axis),    
  .bready_debug_axis    (bready_debug_axis),    
  .arid_debug_axis      (arid_debug_axis),    
  .araddr_debug_axis    (araddr_debug_axis),    
  .arlen_debug_axis     (arlen_debug_axis),    
  .arsize_debug_axis    (arsize_debug_axis),    
  .arburst_debug_axis   (arburst_debug_axis),    
  .arlock_debug_axis    (arlock_debug_axis),    
  .arcache_debug_axis   (arcache_debug_axis),    
  .arprot_debug_axis    (arprot_debug_axis),    
  .arvalid_debug_axis   (arvalid_debug_axis),    
  .arready_debug_axis   (arready_debug_axis),    
  .rid_debug_axis       (rid_debug_axis),    
  .rdata_debug_axis     (rdata_debug_axis),    
  .rresp_debug_axis     (rresp_debug_axis),    
  .rlast_debug_axis     (rlast_debug_axis),    
  .rvalid_debug_axis    (rvalid_debug_axis),    
  .rready_debug_axis    (rready_debug_axis),    
  .awuser_debug_axis    (awuser_debug_axis),    
  .buser_debug_axis     (buser_debug_axis),    
  .aruser_debug_axis    (aruser_debug_axis),    
  .ruser_debug_axis     (ruser_debug_axis),    
  .paddr_debug_axis_ib_apb (paddr_debug_axis_ib_apb),    
  .pselx_debug_axis_ib_apb (pselx_debug_axis_ib_apb),    
  .penable_debug_axis_ib_apb (penable_debug_axis_ib_apb),    
  .pwrite_debug_axis_ib_apb (pwrite_debug_axis_ib_apb),    
  .prdata_debug_axis_ib_apb (prdata_debug_axis_ib_apb),    
  .pwdata_debug_axis_ib_apb (pwdata_debug_axis_ib_apb),    
  .pready_debug_axis_ib_apb (pready_debug_axis_ib_apb),    
  .pslverr_debug_axis_ib_apb (pslverr_debug_axis_ib_apb),    
  .awid_expmstr0_axim   (awid_expmstr0_axim),    
  .awaddr_expmstr0_axim (awaddr_expmstr0_axim),    
  .awlen_expmstr0_axim  (awlen_expmstr0_axim),    
  .awsize_expmstr0_axim (awsize_expmstr0_axim),    
  .awburst_expmstr0_axim (awburst_expmstr0_axim),    
  .awlock_expmstr0_axim (awlock_expmstr0_axim),    
  .awcache_expmstr0_axim (awcache_expmstr0_axim),    
  .awprot_expmstr0_axim (awprot_expmstr0_axim),    
  .awqos_expmstr0_axim  (awqos_expmstr0_axim),    
  .awvalid_expmstr0_axim (awvalid_expmstr0_axim),    
  .awready_expmstr0_axim (awready_expmstr0_axim),    
  .wdata_expmstr0_axim  (wdata_expmstr0_axim),    
  .wstrb_expmstr0_axim  (wstrb_expmstr0_axim),    
  .wlast_expmstr0_axim  (wlast_expmstr0_axim),    
  .wvalid_expmstr0_axim (wvalid_expmstr0_axim),    
  .wready_expmstr0_axim (wready_expmstr0_axim),    
  .bid_expmstr0_axim    (bid_expmstr0_axim),    
  .bresp_expmstr0_axim  (bresp_expmstr0_axim),    
  .bvalid_expmstr0_axim (bvalid_expmstr0_axim),    
  .bready_expmstr0_axim (bready_expmstr0_axim),    
  .arid_expmstr0_axim   (arid_expmstr0_axim),    
  .araddr_expmstr0_axim (araddr_expmstr0_axim),    
  .arlen_expmstr0_axim  (arlen_expmstr0_axim),    
  .arsize_expmstr0_axim (arsize_expmstr0_axim),    
  .arburst_expmstr0_axim (arburst_expmstr0_axim),    
  .arlock_expmstr0_axim (arlock_expmstr0_axim),    
  .arcache_expmstr0_axim (arcache_expmstr0_axim),    
  .arprot_expmstr0_axim (arprot_expmstr0_axim),    
  .arqos_expmstr0_axim  (arqos_expmstr0_axim),    
  .arvalid_expmstr0_axim (arvalid_expmstr0_axim),    
  .arready_expmstr0_axim (arready_expmstr0_axim),    
  .rid_expmstr0_axim    (rid_expmstr0_axim),    
  .rdata_expmstr0_axim  (rdata_expmstr0_axim),    
  .rresp_expmstr0_axim  (rresp_expmstr0_axim),    
  .rlast_expmstr0_axim  (rlast_expmstr0_axim),    
  .rvalid_expmstr0_axim (rvalid_expmstr0_axim),    
  .rready_expmstr0_axim (rready_expmstr0_axim),    
  .awuser_expmstr0_axim (awuser_expmstr0_axim),    
  .buser_expmstr0_axim  (buser_expmstr0_axim),    
  .aruser_expmstr0_axim (aruser_expmstr0_axim),    
  .ruser_expmstr0_axim  (ruser_expmstr0_axim),    
  .awid_expmstr1_axim   (awid_expmstr1_axim),    
  .awaddr_expmstr1_axim (awaddr_expmstr1_axim),    
  .awlen_expmstr1_axim  (awlen_expmstr1_axim),    
  .awsize_expmstr1_axim (awsize_expmstr1_axim),    
  .awburst_expmstr1_axim (awburst_expmstr1_axim),    
  .awlock_expmstr1_axim (awlock_expmstr1_axim),    
  .awcache_expmstr1_axim (awcache_expmstr1_axim),    
  .awprot_expmstr1_axim (awprot_expmstr1_axim),    
  .awqos_expmstr1_axim  (awqos_expmstr1_axim),    
  .awvalid_expmstr1_axim (awvalid_expmstr1_axim),    
  .awready_expmstr1_axim (awready_expmstr1_axim),    
  .wdata_expmstr1_axim  (wdata_expmstr1_axim),    
  .wstrb_expmstr1_axim  (wstrb_expmstr1_axim),    
  .wlast_expmstr1_axim  (wlast_expmstr1_axim),    
  .wvalid_expmstr1_axim (wvalid_expmstr1_axim),    
  .wready_expmstr1_axim (wready_expmstr1_axim),    
  .bid_expmstr1_axim    (bid_expmstr1_axim),    
  .bresp_expmstr1_axim  (bresp_expmstr1_axim),    
  .bvalid_expmstr1_axim (bvalid_expmstr1_axim),    
  .bready_expmstr1_axim (bready_expmstr1_axim),    
  .arid_expmstr1_axim   (arid_expmstr1_axim),    
  .araddr_expmstr1_axim (araddr_expmstr1_axim),    
  .arlen_expmstr1_axim  (arlen_expmstr1_axim),    
  .arsize_expmstr1_axim (arsize_expmstr1_axim),    
  .arburst_expmstr1_axim (arburst_expmstr1_axim),    
  .arlock_expmstr1_axim (arlock_expmstr1_axim),    
  .arcache_expmstr1_axim (arcache_expmstr1_axim),    
  .arprot_expmstr1_axim (arprot_expmstr1_axim),    
  .arqos_expmstr1_axim  (arqos_expmstr1_axim),    
  .arvalid_expmstr1_axim (arvalid_expmstr1_axim),    
  .arready_expmstr1_axim (arready_expmstr1_axim),    
  .rid_expmstr1_axim    (rid_expmstr1_axim),    
  .rdata_expmstr1_axim  (rdata_expmstr1_axim),    
  .rresp_expmstr1_axim  (rresp_expmstr1_axim),    
  .rlast_expmstr1_axim  (rlast_expmstr1_axim),    
  .rvalid_expmstr1_axim (rvalid_expmstr1_axim),    
  .rready_expmstr1_axim (rready_expmstr1_axim),    
  .awuser_expmstr1_axim (awuser_expmstr1_axim),    
  .buser_expmstr1_axim  (buser_expmstr1_axim),    
  .aruser_expmstr1_axim (aruser_expmstr1_axim),    
  .ruser_expmstr1_axim  (ruser_expmstr1_axim),    
  .awid_expslv0_axis    (awid_expslv0_axis),    
  .awaddr_expslv0_axis  (awaddr_expslv0_axis),    
  .awlen_expslv0_axis   (awlen_expslv0_axis),    
  .awsize_expslv0_axis  (awsize_expslv0_axis),    
  .awburst_expslv0_axis (awburst_expslv0_axis),    
  .awlock_expslv0_axis  (awlock_expslv0_axis),    
  .awcache_expslv0_axis (awcache_expslv0_axis),    
  .awprot_expslv0_axis  (awprot_expslv0_axis),    
  .awqos_expslv0_axis   (awqos_expslv0_axis),    
  .awvalid_expslv0_axis (awvalid_expslv0_axis),    
  .awready_expslv0_axis (awready_expslv0_axis),    
  .wdata_expslv0_axis   (wdata_expslv0_axis),    
  .wstrb_expslv0_axis   (wstrb_expslv0_axis),    
  .wlast_expslv0_axis   (wlast_expslv0_axis),    
  .wvalid_expslv0_axis  (wvalid_expslv0_axis),    
  .wready_expslv0_axis  (wready_expslv0_axis),    
  .bid_expslv0_axis     (bid_expslv0_axis),    
  .bresp_expslv0_axis   (bresp_expslv0_axis),    
  .bvalid_expslv0_axis  (bvalid_expslv0_axis),    
  .bready_expslv0_axis  (bready_expslv0_axis),    
  .arid_expslv0_axis    (arid_expslv0_axis),    
  .araddr_expslv0_axis  (araddr_expslv0_axis),    
  .arlen_expslv0_axis   (arlen_expslv0_axis),    
  .arsize_expslv0_axis  (arsize_expslv0_axis),    
  .arburst_expslv0_axis (arburst_expslv0_axis),    
  .arlock_expslv0_axis  (arlock_expslv0_axis),    
  .arcache_expslv0_axis (arcache_expslv0_axis),    
  .arprot_expslv0_axis  (arprot_expslv0_axis),    
  .arqos_expslv0_axis   (arqos_expslv0_axis),    
  .arvalid_expslv0_axis (arvalid_expslv0_axis),    
  .arready_expslv0_axis (arready_expslv0_axis),    
  .rid_expslv0_axis     (rid_expslv0_axis),    
  .rdata_expslv0_axis   (rdata_expslv0_axis),    
  .rresp_expslv0_axis   (rresp_expslv0_axis),    
  .rlast_expslv0_axis   (rlast_expslv0_axis),    
  .rvalid_expslv0_axis  (rvalid_expslv0_axis),    
  .rready_expslv0_axis  (rready_expslv0_axis),    
  .awuser_expslv0_axis  (awuser_expslv0_axis),    
  .buser_expslv0_axis   (buser_expslv0_axis),    
  .aruser_expslv0_axis  (aruser_expslv0_axis),    
  .ruser_expslv0_axis   (ruser_expslv0_axis),    
  .awid_expslv1_axis    (awid_expslv1_axis),    
  .awaddr_expslv1_axis  (awaddr_expslv1_axis),    
  .awlen_expslv1_axis   (awlen_expslv1_axis),    
  .awsize_expslv1_axis  (awsize_expslv1_axis),    
  .awburst_expslv1_axis (awburst_expslv1_axis),    
  .awlock_expslv1_axis  (awlock_expslv1_axis),    
  .awcache_expslv1_axis (awcache_expslv1_axis),    
  .awprot_expslv1_axis  (awprot_expslv1_axis),    
  .awqos_expslv1_axis   (awqos_expslv1_axis),    
  .awvalid_expslv1_axis (awvalid_expslv1_axis),    
  .awready_expslv1_axis (awready_expslv1_axis),    
  .wdata_expslv1_axis   (wdata_expslv1_axis),    
  .wstrb_expslv1_axis   (wstrb_expslv1_axis),    
  .wlast_expslv1_axis   (wlast_expslv1_axis),    
  .wvalid_expslv1_axis  (wvalid_expslv1_axis),    
  .wready_expslv1_axis  (wready_expslv1_axis),    
  .bid_expslv1_axis     (bid_expslv1_axis),    
  .bresp_expslv1_axis   (bresp_expslv1_axis),    
  .bvalid_expslv1_axis  (bvalid_expslv1_axis),    
  .bready_expslv1_axis  (bready_expslv1_axis),    
  .arid_expslv1_axis    (arid_expslv1_axis),    
  .araddr_expslv1_axis  (araddr_expslv1_axis),    
  .arlen_expslv1_axis   (arlen_expslv1_axis),    
  .arsize_expslv1_axis  (arsize_expslv1_axis),    
  .arburst_expslv1_axis (arburst_expslv1_axis),    
  .arlock_expslv1_axis  (arlock_expslv1_axis),    
  .arcache_expslv1_axis (arcache_expslv1_axis),    
  .arprot_expslv1_axis  (arprot_expslv1_axis),    
  .arqos_expslv1_axis   (arqos_expslv1_axis),    
  .arvalid_expslv1_axis (arvalid_expslv1_axis),    
  .arready_expslv1_axis (arready_expslv1_axis),    
  .rid_expslv1_axis     (rid_expslv1_axis),    
  .rdata_expslv1_axis   (rdata_expslv1_axis),    
  .rresp_expslv1_axis   (rresp_expslv1_axis),    
  .rlast_expslv1_axis   (rlast_expslv1_axis),    
  .rvalid_expslv1_axis  (rvalid_expslv1_axis),    
  .rready_expslv1_axis  (rready_expslv1_axis),    
  .awuser_expslv1_axis  (awuser_expslv1_axis),    
  .buser_expslv1_axis   (buser_expslv1_axis),    
  .aruser_expslv1_axis  (aruser_expslv1_axis),    
  .ruser_expslv1_axis   (ruser_expslv1_axis),    
  .awid_extsys0_axis    (awid_extsys0_axis),    
  .awaddr_extsys0_axis  (awaddr_extsys0_axis),    
  .awlen_extsys0_axis   (awlen_extsys0_axis),    
  .awsize_extsys0_axis  (awsize_extsys0_axis),    
  .awburst_extsys0_axis (awburst_extsys0_axis),    
  .awlock_extsys0_axis  (awlock_extsys0_axis),    
  .awcache_extsys0_axis (awcache_extsys0_axis),    
  .awprot_extsys0_axis  (awprot_extsys0_axis),    
  .awvalid_extsys0_axis (awvalid_extsys0_axis),    
  .awready_extsys0_axis (awready_extsys0_axis),    
  .wdata_extsys0_axis   (wdata_extsys0_axis),    
  .wstrb_extsys0_axis   (wstrb_extsys0_axis),    
  .wlast_extsys0_axis   (wlast_extsys0_axis),    
  .wvalid_extsys0_axis  (wvalid_extsys0_axis),    
  .wready_extsys0_axis  (wready_extsys0_axis),    
  .bid_extsys0_axis     (bid_extsys0_axis),    
  .bresp_extsys0_axis   (bresp_extsys0_axis),    
  .bvalid_extsys0_axis  (bvalid_extsys0_axis),    
  .bready_extsys0_axis  (bready_extsys0_axis),    
  .arid_extsys0_axis    (arid_extsys0_axis),    
  .araddr_extsys0_axis  (araddr_extsys0_axis),    
  .arlen_extsys0_axis   (arlen_extsys0_axis),    
  .arsize_extsys0_axis  (arsize_extsys0_axis),    
  .arburst_extsys0_axis (arburst_extsys0_axis),    
  .arlock_extsys0_axis  (arlock_extsys0_axis),    
  .arcache_extsys0_axis (arcache_extsys0_axis),    
  .arprot_extsys0_axis  (arprot_extsys0_axis),    
  .arvalid_extsys0_axis (arvalid_extsys0_axis),    
  .arready_extsys0_axis (arready_extsys0_axis),    
  .rid_extsys0_axis     (rid_extsys0_axis),    
  .rdata_extsys0_axis   (rdata_extsys0_axis),    
  .rresp_extsys0_axis   (rresp_extsys0_axis),    
  .rlast_extsys0_axis   (rlast_extsys0_axis),    
  .rvalid_extsys0_axis  (rvalid_extsys0_axis),    
  .rready_extsys0_axis  (rready_extsys0_axis),    
  .awuser_extsys0_axis  (awuser_extsys0_axis),    
  .buser_extsys0_axis   (buser_extsys0_axis),    
  .aruser_extsys0_axis  (aruser_extsys0_axis),    
  .ruser_extsys0_axis   (ruser_extsys0_axis),    
  .paddr_extsys0_axis_ib_apb (paddr_extsys0_axis_ib_apb),    
  .pselx_extsys0_axis_ib_apb (pselx_extsys0_axis_ib_apb),    
  .penable_extsys0_axis_ib_apb (penable_extsys0_axis_ib_apb),    
  .pwrite_extsys0_axis_ib_apb (pwrite_extsys0_axis_ib_apb),    
  .prdata_extsys0_axis_ib_apb (prdata_extsys0_axis_ib_apb),    
  .pwdata_extsys0_axis_ib_apb (pwdata_extsys0_axis_ib_apb),    
  .pready_extsys0_axis_ib_apb (pready_extsys0_axis_ib_apb),    
  .pslverr_extsys0_axis_ib_apb (pslverr_extsys0_axis_ib_apb),    
  .awid_extsys1_axis    (awid_extsys1_axis),    
  .awaddr_extsys1_axis  (awaddr_extsys1_axis),    
  .awlen_extsys1_axis   (awlen_extsys1_axis),    
  .awsize_extsys1_axis  (awsize_extsys1_axis),    
  .awburst_extsys1_axis (awburst_extsys1_axis),    
  .awlock_extsys1_axis  (awlock_extsys1_axis),    
  .awcache_extsys1_axis (awcache_extsys1_axis),    
  .awprot_extsys1_axis  (awprot_extsys1_axis),    
  .awvalid_extsys1_axis (awvalid_extsys1_axis),    
  .awready_extsys1_axis (awready_extsys1_axis),    
  .wdata_extsys1_axis   (wdata_extsys1_axis),    
  .wstrb_extsys1_axis   (wstrb_extsys1_axis),    
  .wlast_extsys1_axis   (wlast_extsys1_axis),    
  .wvalid_extsys1_axis  (wvalid_extsys1_axis),    
  .wready_extsys1_axis  (wready_extsys1_axis),    
  .bid_extsys1_axis     (bid_extsys1_axis),    
  .bresp_extsys1_axis   (bresp_extsys1_axis),    
  .bvalid_extsys1_axis  (bvalid_extsys1_axis),    
  .bready_extsys1_axis  (bready_extsys1_axis),    
  .arid_extsys1_axis    (arid_extsys1_axis),    
  .araddr_extsys1_axis  (araddr_extsys1_axis),    
  .arlen_extsys1_axis   (arlen_extsys1_axis),    
  .arsize_extsys1_axis  (arsize_extsys1_axis),    
  .arburst_extsys1_axis (arburst_extsys1_axis),    
  .arlock_extsys1_axis  (arlock_extsys1_axis),    
  .arcache_extsys1_axis (arcache_extsys1_axis),    
  .arprot_extsys1_axis  (arprot_extsys1_axis),    
  .arvalid_extsys1_axis (arvalid_extsys1_axis),    
  .arready_extsys1_axis (arready_extsys1_axis),    
  .rid_extsys1_axis     (rid_extsys1_axis),    
  .rdata_extsys1_axis   (rdata_extsys1_axis),    
  .rresp_extsys1_axis   (rresp_extsys1_axis),    
  .rlast_extsys1_axis   (rlast_extsys1_axis),    
  .rvalid_extsys1_axis  (rvalid_extsys1_axis),    
  .rready_extsys1_axis  (rready_extsys1_axis),    
  .awuser_extsys1_axis  (awuser_extsys1_axis),    
  .buser_extsys1_axis   (buser_extsys1_axis),    
  .aruser_extsys1_axis  (aruser_extsys1_axis),    
  .ruser_extsys1_axis   (ruser_extsys1_axis),    
  .paddr_extsys1_axis_ib_apb (paddr_extsys1_axis_ib_apb),    
  .pselx_extsys1_axis_ib_apb (pselx_extsys1_axis_ib_apb),    
  .penable_extsys1_axis_ib_apb (penable_extsys1_axis_ib_apb),    
  .pwrite_extsys1_axis_ib_apb (pwrite_extsys1_axis_ib_apb),    
  .prdata_extsys1_axis_ib_apb (prdata_extsys1_axis_ib_apb),    
  .pwdata_extsys1_axis_ib_apb (pwdata_extsys1_axis_ib_apb),    
  .pready_extsys1_axis_ib_apb (pready_extsys1_axis_ib_apb),    
  .pslverr_extsys1_axis_ib_apb (pslverr_extsys1_axis_ib_apb),    
  .awid_firewall_axim   (awid_firewall_axim),    
  .awaddr_firewall_axim (awaddr_firewall_axim),    
  .awlen_firewall_axim  (awlen_firewall_axim),    
  .awsize_firewall_axim (awsize_firewall_axim),    
  .awburst_firewall_axim (awburst_firewall_axim),    
  .awlock_firewall_axim (awlock_firewall_axim),    
  .awcache_firewall_axim (awcache_firewall_axim),    
  .awprot_firewall_axim (awprot_firewall_axim),    
  .awvalid_firewall_axim (awvalid_firewall_axim),    
  .awready_firewall_axim (awready_firewall_axim),    
  .wdata_firewall_axim  (wdata_firewall_axim),    
  .wstrb_firewall_axim  (wstrb_firewall_axim),    
  .wlast_firewall_axim  (wlast_firewall_axim),    
  .wvalid_firewall_axim (wvalid_firewall_axim),    
  .wready_firewall_axim (wready_firewall_axim),    
  .bid_firewall_axim    (bid_firewall_axim),    
  .bresp_firewall_axim  (bresp_firewall_axim),    
  .bvalid_firewall_axim (bvalid_firewall_axim),    
  .bready_firewall_axim (bready_firewall_axim),    
  .arid_firewall_axim   (arid_firewall_axim),    
  .araddr_firewall_axim (araddr_firewall_axim),    
  .arlen_firewall_axim  (arlen_firewall_axim),    
  .arsize_firewall_axim (arsize_firewall_axim),    
  .arburst_firewall_axim (arburst_firewall_axim),    
  .arlock_firewall_axim (arlock_firewall_axim),    
  .arcache_firewall_axim (arcache_firewall_axim),    
  .arprot_firewall_axim (arprot_firewall_axim),    
  .arvalid_firewall_axim (arvalid_firewall_axim),    
  .arready_firewall_axim (arready_firewall_axim),    
  .rid_firewall_axim    (rid_firewall_axim),    
  .rdata_firewall_axim  (rdata_firewall_axim),    
  .rresp_firewall_axim  (rresp_firewall_axim),    
  .rlast_firewall_axim  (rlast_firewall_axim),    
  .rvalid_firewall_axim (rvalid_firewall_axim),    
  .rready_firewall_axim (rready_firewall_axim),    
  .awuser_firewall_axim (awuser_firewall_axim),    
  .buser_firewall_axim  (buser_firewall_axim),    
  .aruser_firewall_axim (aruser_firewall_axim),    
  .ruser_firewall_axim  (ruser_firewall_axim),    
  .a_data_gpv_0_ib1_int (a_data_gpv_0_ib1_int),    
  .a_valid_gpv_0_ib1_int (a_valid_gpv_0_ib1_int),    
  .a_ready_gpv_0_ib1_int (a_ready_gpv_0_ib1_int),    
  .w_data_gpv_0_ib1_int (w_data_gpv_0_ib1_int),    
  .w_valid_gpv_0_ib1_int (w_valid_gpv_0_ib1_int),    
  .w_ready_gpv_0_ib1_int (w_ready_gpv_0_ib1_int),    
  .d_data_gpv_0_ib1_int (d_data_gpv_0_ib1_int),    
  .d_valid_gpv_0_ib1_int (d_valid_gpv_0_ib1_int),    
  .d_ready_gpv_0_ib1_int (d_ready_gpv_0_ib1_int),    
  .a_data_gpvmain_ahb_ib_int (a_data_gpvmain_ahb_ib_int),    
  .a_valid_gpvmain_ahb_ib_int (a_valid_gpvmain_ahb_ib_int),    
  .a_ready_gpvmain_ahb_ib_int (a_ready_gpvmain_ahb_ib_int),    
  .w_data_gpvmain_ahb_ib_int (w_data_gpvmain_ahb_ib_int),    
  .w_valid_gpvmain_ahb_ib_int (w_valid_gpvmain_ahb_ib_int),    
  .w_ready_gpvmain_ahb_ib_int (w_ready_gpvmain_ahb_ib_int),    
  .d_data_gpvmain_ahb_ib_int (d_data_gpvmain_ahb_ib_int),    
  .d_valid_gpvmain_ahb_ib_int (d_valid_gpvmain_ahb_ib_int),    
  .d_ready_gpvmain_ahb_ib_int (d_ready_gpvmain_ahb_ib_int),    
  .empty_gpvmain_ahb_ib_int (empty_gpvmain_ahb_ib_int),    
  .awid_hostcpu_axis    (awid_hostcpu_axis),    
  .awaddr_hostcpu_axis  (awaddr_hostcpu_axis),    
  .awlen_hostcpu_axis   (awlen_hostcpu_axis),    
  .awsize_hostcpu_axis  (awsize_hostcpu_axis),    
  .awburst_hostcpu_axis (awburst_hostcpu_axis),    
  .awlock_hostcpu_axis  (awlock_hostcpu_axis),    
  .awcache_hostcpu_axis (awcache_hostcpu_axis),    
  .awprot_hostcpu_axis  (awprot_hostcpu_axis),    
  .awvalid_hostcpu_axis (awvalid_hostcpu_axis),    
  .awready_hostcpu_axis (awready_hostcpu_axis),    
  .wdata_hostcpu_axis   (wdata_hostcpu_axis),    
  .wstrb_hostcpu_axis   (wstrb_hostcpu_axis),    
  .wlast_hostcpu_axis   (wlast_hostcpu_axis),    
  .wvalid_hostcpu_axis  (wvalid_hostcpu_axis),    
  .wready_hostcpu_axis  (wready_hostcpu_axis),    
  .bid_hostcpu_axis     (bid_hostcpu_axis),    
  .bresp_hostcpu_axis   (bresp_hostcpu_axis),    
  .bvalid_hostcpu_axis  (bvalid_hostcpu_axis),    
  .bready_hostcpu_axis  (bready_hostcpu_axis),    
  .arid_hostcpu_axis    (arid_hostcpu_axis),    
  .araddr_hostcpu_axis  (araddr_hostcpu_axis),    
  .arlen_hostcpu_axis   (arlen_hostcpu_axis),    
  .arsize_hostcpu_axis  (arsize_hostcpu_axis),    
  .arburst_hostcpu_axis (arburst_hostcpu_axis),    
  .arlock_hostcpu_axis  (arlock_hostcpu_axis),    
  .arcache_hostcpu_axis (arcache_hostcpu_axis),    
  .arprot_hostcpu_axis  (arprot_hostcpu_axis),    
  .arvalid_hostcpu_axis (arvalid_hostcpu_axis),    
  .arready_hostcpu_axis (arready_hostcpu_axis),    
  .rid_hostcpu_axis     (rid_hostcpu_axis),    
  .rdata_hostcpu_axis   (rdata_hostcpu_axis),    
  .rresp_hostcpu_axis   (rresp_hostcpu_axis),    
  .rlast_hostcpu_axis   (rlast_hostcpu_axis),    
  .rvalid_hostcpu_axis  (rvalid_hostcpu_axis),    
  .rready_hostcpu_axis  (rready_hostcpu_axis),    
  .awuser_hostcpu_axis  (awuser_hostcpu_axis),    
  .buser_hostcpu_axis   (buser_hostcpu_axis),    
  .aruser_hostcpu_axis  (aruser_hostcpu_axis),    
  .ruser_hostcpu_axis   (ruser_hostcpu_axis),    
  .paddr_hostcpu_axis_ib_apb (paddr_hostcpu_axis_ib_apb),    
  .pselx_hostcpu_axis_ib_apb (pselx_hostcpu_axis_ib_apb),    
  .penable_hostcpu_axis_ib_apb (penable_hostcpu_axis_ib_apb),    
  .pwrite_hostcpu_axis_ib_apb (pwrite_hostcpu_axis_ib_apb),    
  .prdata_hostcpu_axis_ib_apb (prdata_hostcpu_axis_ib_apb),    
  .pwdata_hostcpu_axis_ib_apb (pwdata_hostcpu_axis_ib_apb),    
  .pready_hostcpu_axis_ib_apb (pready_hostcpu_axis_ib_apb),    
  .pslverr_hostcpu_axis_ib_apb (pslverr_hostcpu_axis_ib_apb),    
  .awid_ocvm_axim       (awid_ocvm_axim),    
  .awaddr_ocvm_axim     (awaddr_ocvm_axim),    
  .awlen_ocvm_axim      (awlen_ocvm_axim),    
  .awsize_ocvm_axim     (awsize_ocvm_axim),    
  .awburst_ocvm_axim    (awburst_ocvm_axim),    
  .awlock_ocvm_axim     (awlock_ocvm_axim),    
  .awcache_ocvm_axim    (awcache_ocvm_axim),    
  .awprot_ocvm_axim     (awprot_ocvm_axim),    
  .awqos_ocvm_axim      (awqos_ocvm_axim),    
  .awvalid_ocvm_axim    (awvalid_ocvm_axim),    
  .awready_ocvm_axim    (awready_ocvm_axim),    
  .wdata_ocvm_axim      (wdata_ocvm_axim),    
  .wstrb_ocvm_axim      (wstrb_ocvm_axim),    
  .wlast_ocvm_axim      (wlast_ocvm_axim),    
  .wvalid_ocvm_axim     (wvalid_ocvm_axim),    
  .wready_ocvm_axim     (wready_ocvm_axim),    
  .bid_ocvm_axim        (bid_ocvm_axim),    
  .bresp_ocvm_axim      (bresp_ocvm_axim),    
  .bvalid_ocvm_axim     (bvalid_ocvm_axim),    
  .bready_ocvm_axim     (bready_ocvm_axim),    
  .arid_ocvm_axim       (arid_ocvm_axim),    
  .araddr_ocvm_axim     (araddr_ocvm_axim),    
  .arlen_ocvm_axim      (arlen_ocvm_axim),    
  .arsize_ocvm_axim     (arsize_ocvm_axim),    
  .arburst_ocvm_axim    (arburst_ocvm_axim),    
  .arlock_ocvm_axim     (arlock_ocvm_axim),    
  .arcache_ocvm_axim    (arcache_ocvm_axim),    
  .arprot_ocvm_axim     (arprot_ocvm_axim),    
  .arqos_ocvm_axim      (arqos_ocvm_axim),    
  .arvalid_ocvm_axim    (arvalid_ocvm_axim),    
  .arready_ocvm_axim    (arready_ocvm_axim),    
  .rid_ocvm_axim        (rid_ocvm_axim),    
  .rdata_ocvm_axim      (rdata_ocvm_axim),    
  .rresp_ocvm_axim      (rresp_ocvm_axim),    
  .rlast_ocvm_axim      (rlast_ocvm_axim),    
  .rvalid_ocvm_axim     (rvalid_ocvm_axim),    
  .rready_ocvm_axim     (rready_ocvm_axim),    
  .awuser_ocvm_axim     (awuser_ocvm_axim),    
  .buser_ocvm_axim      (buser_ocvm_axim),    
  .aruser_ocvm_axim     (aruser_ocvm_axim),    
  .ruser_ocvm_axim      (ruser_ocvm_axim),    
  .awid_secenc_axis     (awid_secenc_axis),    
  .awaddr_secenc_axis   (awaddr_secenc_axis),    
  .awlen_secenc_axis    (awlen_secenc_axis),    
  .awsize_secenc_axis   (awsize_secenc_axis),    
  .awburst_secenc_axis  (awburst_secenc_axis),    
  .awlock_secenc_axis   (awlock_secenc_axis),    
  .awcache_secenc_axis  (awcache_secenc_axis),    
  .awprot_secenc_axis   (awprot_secenc_axis),    
  .awvalid_secenc_axis  (awvalid_secenc_axis),    
  .awready_secenc_axis  (awready_secenc_axis),    
  .wdata_secenc_axis    (wdata_secenc_axis),    
  .wstrb_secenc_axis    (wstrb_secenc_axis),    
  .wlast_secenc_axis    (wlast_secenc_axis),    
  .wvalid_secenc_axis   (wvalid_secenc_axis),    
  .wready_secenc_axis   (wready_secenc_axis),    
  .bid_secenc_axis      (bid_secenc_axis),    
  .bresp_secenc_axis    (bresp_secenc_axis),    
  .bvalid_secenc_axis   (bvalid_secenc_axis),    
  .bready_secenc_axis   (bready_secenc_axis),    
  .arid_secenc_axis     (arid_secenc_axis),    
  .araddr_secenc_axis   (araddr_secenc_axis),    
  .arlen_secenc_axis    (arlen_secenc_axis),    
  .arsize_secenc_axis   (arsize_secenc_axis),    
  .arburst_secenc_axis  (arburst_secenc_axis),    
  .arlock_secenc_axis   (arlock_secenc_axis),    
  .arcache_secenc_axis  (arcache_secenc_axis),    
  .arprot_secenc_axis   (arprot_secenc_axis),    
  .arvalid_secenc_axis  (arvalid_secenc_axis),    
  .arready_secenc_axis  (arready_secenc_axis),    
  .rid_secenc_axis      (rid_secenc_axis),    
  .rdata_secenc_axis    (rdata_secenc_axis),    
  .rresp_secenc_axis    (rresp_secenc_axis),    
  .rlast_secenc_axis    (rlast_secenc_axis),    
  .rvalid_secenc_axis   (rvalid_secenc_axis),    
  .rready_secenc_axis   (rready_secenc_axis),    
  .awuser_secenc_axis   (awuser_secenc_axis),    
  .buser_secenc_axis    (buser_secenc_axis),    
  .aruser_secenc_axis   (aruser_secenc_axis),    
  .ruser_secenc_axis    (ruser_secenc_axis),    
  .paddr_secenc_axis_ib_apb (paddr_secenc_axis_ib_apb),    
  .pselx_secenc_axis_ib_apb (pselx_secenc_axis_ib_apb),    
  .penable_secenc_axis_ib_apb (penable_secenc_axis_ib_apb),    
  .pwrite_secenc_axis_ib_apb (pwrite_secenc_axis_ib_apb),    
  .prdata_secenc_axis_ib_apb (prdata_secenc_axis_ib_apb),    
  .pwdata_secenc_axis_ib_apb (pwdata_secenc_axis_ib_apb),    
  .pready_secenc_axis_ib_apb (pready_secenc_axis_ib_apb),    
  .pslverr_secenc_axis_ib_apb (pslverr_secenc_axis_ib_apb),    
  .awid_sysctrl_axim    (awid_sysctrl_axim),    
  .awaddr_sysctrl_axim  (awaddr_sysctrl_axim),    
  .awlen_sysctrl_axim   (awlen_sysctrl_axim),    
  .awsize_sysctrl_axim  (awsize_sysctrl_axim),    
  .awburst_sysctrl_axim (awburst_sysctrl_axim),    
  .awlock_sysctrl_axim  (awlock_sysctrl_axim),    
  .awcache_sysctrl_axim (awcache_sysctrl_axim),    
  .awprot_sysctrl_axim  (awprot_sysctrl_axim),    
  .awvalid_sysctrl_axim (awvalid_sysctrl_axim),    
  .awready_sysctrl_axim (awready_sysctrl_axim),    
  .wdata_sysctrl_axim   (wdata_sysctrl_axim),    
  .wstrb_sysctrl_axim   (wstrb_sysctrl_axim),    
  .wlast_sysctrl_axim   (wlast_sysctrl_axim),    
  .wvalid_sysctrl_axim  (wvalid_sysctrl_axim),    
  .wready_sysctrl_axim  (wready_sysctrl_axim),    
  .bid_sysctrl_axim     (bid_sysctrl_axim),    
  .bresp_sysctrl_axim   (bresp_sysctrl_axim),    
  .bvalid_sysctrl_axim  (bvalid_sysctrl_axim),    
  .bready_sysctrl_axim  (bready_sysctrl_axim),    
  .arid_sysctrl_axim    (arid_sysctrl_axim),    
  .araddr_sysctrl_axim  (araddr_sysctrl_axim),    
  .arlen_sysctrl_axim   (arlen_sysctrl_axim),    
  .arsize_sysctrl_axim  (arsize_sysctrl_axim),    
  .arburst_sysctrl_axim (arburst_sysctrl_axim),    
  .arlock_sysctrl_axim  (arlock_sysctrl_axim),    
  .arcache_sysctrl_axim (arcache_sysctrl_axim),    
  .arprot_sysctrl_axim  (arprot_sysctrl_axim),    
  .arvalid_sysctrl_axim (arvalid_sysctrl_axim),    
  .arready_sysctrl_axim (arready_sysctrl_axim),    
  .rid_sysctrl_axim     (rid_sysctrl_axim),    
  .rdata_sysctrl_axim   (rdata_sysctrl_axim),    
  .rresp_sysctrl_axim   (rresp_sysctrl_axim),    
  .rlast_sysctrl_axim   (rlast_sysctrl_axim),    
  .rvalid_sysctrl_axim  (rvalid_sysctrl_axim),    
  .rready_sysctrl_axim  (rready_sysctrl_axim),    
  .awuser_sysctrl_axim  (awuser_sysctrl_axim),    
  .buser_sysctrl_axim   (buser_sysctrl_axim),    
  .aruser_sysctrl_axim  (aruser_sysctrl_axim),    
  .ruser_sysctrl_axim   (ruser_sysctrl_axim),    
  .awid_sysperi_axim    (awid_sysperi_axim),    
  .awaddr_sysperi_axim  (awaddr_sysperi_axim),    
  .awlen_sysperi_axim   (awlen_sysperi_axim),    
  .awsize_sysperi_axim  (awsize_sysperi_axim),    
  .awburst_sysperi_axim (awburst_sysperi_axim),    
  .awlock_sysperi_axim  (awlock_sysperi_axim),    
  .awcache_sysperi_axim (awcache_sysperi_axim),    
  .awprot_sysperi_axim  (awprot_sysperi_axim),    
  .awvalid_sysperi_axim (awvalid_sysperi_axim),    
  .awready_sysperi_axim (awready_sysperi_axim),    
  .wdata_sysperi_axim   (wdata_sysperi_axim),    
  .wstrb_sysperi_axim   (wstrb_sysperi_axim),    
  .wlast_sysperi_axim   (wlast_sysperi_axim),    
  .wvalid_sysperi_axim  (wvalid_sysperi_axim),    
  .wready_sysperi_axim  (wready_sysperi_axim),    
  .bid_sysperi_axim     (bid_sysperi_axim),    
  .bresp_sysperi_axim   (bresp_sysperi_axim),    
  .bvalid_sysperi_axim  (bvalid_sysperi_axim),    
  .bready_sysperi_axim  (bready_sysperi_axim),    
  .arid_sysperi_axim    (arid_sysperi_axim),    
  .araddr_sysperi_axim  (araddr_sysperi_axim),    
  .arlen_sysperi_axim   (arlen_sysperi_axim),    
  .arsize_sysperi_axim  (arsize_sysperi_axim),    
  .arburst_sysperi_axim (arburst_sysperi_axim),    
  .arlock_sysperi_axim  (arlock_sysperi_axim),    
  .arcache_sysperi_axim (arcache_sysperi_axim),    
  .arprot_sysperi_axim  (arprot_sysperi_axim),    
  .arvalid_sysperi_axim (arvalid_sysperi_axim),    
  .arready_sysperi_axim (arready_sysperi_axim),    
  .rid_sysperi_axim     (rid_sysperi_axim),    
  .rdata_sysperi_axim   (rdata_sysperi_axim),    
  .rresp_sysperi_axim   (rresp_sysperi_axim),    
  .rlast_sysperi_axim   (rlast_sysperi_axim),    
  .rvalid_sysperi_axim  (rvalid_sysperi_axim),    
  .rready_sysperi_axim  (rready_sysperi_axim),    
  .awuser_sysperi_axim  (awuser_sysperi_axim),    
  .buser_sysperi_axim   (buser_sysperi_axim),    
  .aruser_sysperi_axim  (aruser_sysperi_axim),    
  .ruser_sysperi_axim   (ruser_sysperi_axim),    
  .aclk                 (aclk),    
  .aresetn              (aresetn),    
  .awid_xnvm_axim       (awid_xnvm_axim),    
  .awaddr_xnvm_axim     (awaddr_xnvm_axim),    
  .awlen_xnvm_axim      (awlen_xnvm_axim),    
  .awsize_xnvm_axim     (awsize_xnvm_axim),    
  .awburst_xnvm_axim    (awburst_xnvm_axim),    
  .awlock_xnvm_axim     (awlock_xnvm_axim),    
  .awcache_xnvm_axim    (awcache_xnvm_axim),    
  .awprot_xnvm_axim     (awprot_xnvm_axim),    
  .awqos_xnvm_axim      (awqos_xnvm_axim),    
  .awvalid_xnvm_axim    (awvalid_xnvm_axim),    
  .awready_xnvm_axim    (awready_xnvm_axim),    
  .wdata_xnvm_axim      (wdata_xnvm_axim),    
  .wstrb_xnvm_axim      (wstrb_xnvm_axim),    
  .wlast_xnvm_axim      (wlast_xnvm_axim),    
  .wvalid_xnvm_axim     (wvalid_xnvm_axim),    
  .wready_xnvm_axim     (wready_xnvm_axim),    
  .bid_xnvm_axim        (bid_xnvm_axim),    
  .bresp_xnvm_axim      (bresp_xnvm_axim),    
  .bvalid_xnvm_axim     (bvalid_xnvm_axim),    
  .bready_xnvm_axim     (bready_xnvm_axim),    
  .arid_xnvm_axim       (arid_xnvm_axim),    
  .araddr_xnvm_axim     (araddr_xnvm_axim),    
  .arlen_xnvm_axim      (arlen_xnvm_axim),    
  .arsize_xnvm_axim     (arsize_xnvm_axim),    
  .arburst_xnvm_axim    (arburst_xnvm_axim),    
  .arlock_xnvm_axim     (arlock_xnvm_axim),    
  .arcache_xnvm_axim    (arcache_xnvm_axim),    
  .arprot_xnvm_axim     (arprot_xnvm_axim),    
  .arqos_xnvm_axim      (arqos_xnvm_axim),    
  .arvalid_xnvm_axim    (arvalid_xnvm_axim),    
  .arready_xnvm_axim    (arready_xnvm_axim),    
  .rid_xnvm_axim        (rid_xnvm_axim),    
  .rdata_xnvm_axim      (rdata_xnvm_axim),    
  .rresp_xnvm_axim      (rresp_xnvm_axim),    
  .rlast_xnvm_axim      (rlast_xnvm_axim),    
  .rvalid_xnvm_axim     (rvalid_xnvm_axim),    
  .rready_xnvm_axim     (rready_xnvm_axim),    
  .awuser_xnvm_axim     (awuser_xnvm_axim),    
  .buser_xnvm_axim      (buser_xnvm_axim),    
  .aruser_xnvm_axim     (aruser_xnvm_axim),    
  .ruser_xnvm_axim      (ruser_xnvm_axim)    
);


nic400_cd_main_sse710_main     u_cd_main (
  .cactive_cd_main      (cactive_cd_main),    
  .mainclk              (mainclk),    
  .mainresetn           (mainresetn),    
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
  .a_data_gpvmain_ahb_ib_int (a_data_gpvmain_ahb_ib_int),    
  .a_valid_gpvmain_ahb_ib_int (a_valid_gpvmain_ahb_ib_int),    
  .a_ready_gpvmain_ahb_ib_int (a_ready_gpvmain_ahb_ib_int),    
  .w_data_gpvmain_ahb_ib_int (w_data_gpvmain_ahb_ib_int),    
  .w_valid_gpvmain_ahb_ib_int (w_valid_gpvmain_ahb_ib_int),    
  .w_ready_gpvmain_ahb_ib_int (w_ready_gpvmain_ahb_ib_int),    
  .d_data_gpvmain_ahb_ib_int (d_data_gpvmain_ahb_ib_int),    
  .d_valid_gpvmain_ahb_ib_int (d_valid_gpvmain_ahb_ib_int),    
  .d_ready_gpvmain_ahb_ib_int (d_ready_gpvmain_ahb_ib_int),    
  .empty_gpvmain_ahb_ib_int (empty_gpvmain_ahb_ib_int)    
);


nic400_cd_a_r_sse710_main     u_r_cd_a (
  .rsb_data_a_ml_m      (rsb_data_a_ml_m),    
  .rsb_wptr_a_ml_m      (rsb_wptr_a_ml_m),    
  .rsb_rptr_a_ml_m      (rsb_rptr_a_ml_m),    
  .rsb_bin_rptr_a_ml_m  (rsb_bin_rptr_a_ml_m),    
  .rsb_data_a_ml_s      (rsb_data_a_ml_s),    
  .rsb_wptr_a_ml_s      (rsb_wptr_a_ml_s),    
  .rsb_rptr_a_ml_s      (rsb_rptr_a_ml_s),    
  .rsb_bin_rptr_a_ml_s  (rsb_bin_rptr_a_ml_s),    
  .rsb_data_a_sl_m      (rsb_data_a_sl_m),    
  .rsb_wptr_a_sl_m      (rsb_wptr_a_sl_m),    
  .rsb_rptr_a_sl_m      (rsb_rptr_a_sl_m),    
  .rsb_bin_rptr_a_sl_m  (rsb_bin_rptr_a_sl_m),    
  .rsb_data_a_sl_s      (rsb_data_a_sl_s),    
  .rsb_wptr_a_sl_s      (rsb_wptr_a_sl_s),    
  .rsb_rptr_a_sl_s      (rsb_rptr_a_sl_s),    
  .rsb_bin_rptr_a_sl_s  (rsb_bin_rptr_a_sl_s),    
  .paddr_debug_axis_ib_apb (paddr_debug_axis_ib_apb),    
  .pselx_debug_axis_ib_apb (pselx_debug_axis_ib_apb),    
  .penable_debug_axis_ib_apb (penable_debug_axis_ib_apb),    
  .pwrite_debug_axis_ib_apb (pwrite_debug_axis_ib_apb),    
  .prdata_debug_axis_ib_apb (prdata_debug_axis_ib_apb),    
  .pwdata_debug_axis_ib_apb (pwdata_debug_axis_ib_apb),    
  .pready_debug_axis_ib_apb (pready_debug_axis_ib_apb),    
  .pslverr_debug_axis_ib_apb (pslverr_debug_axis_ib_apb),    
  .paddr_extsys0_axis_ib_apb (paddr_extsys0_axis_ib_apb),    
  .pselx_extsys0_axis_ib_apb (pselx_extsys0_axis_ib_apb),    
  .penable_extsys0_axis_ib_apb (penable_extsys0_axis_ib_apb),    
  .pwrite_extsys0_axis_ib_apb (pwrite_extsys0_axis_ib_apb),    
  .prdata_extsys0_axis_ib_apb (prdata_extsys0_axis_ib_apb),    
  .pwdata_extsys0_axis_ib_apb (pwdata_extsys0_axis_ib_apb),    
  .pready_extsys0_axis_ib_apb (pready_extsys0_axis_ib_apb),    
  .pslverr_extsys0_axis_ib_apb (pslverr_extsys0_axis_ib_apb),    
  .paddr_extsys1_axis_ib_apb (paddr_extsys1_axis_ib_apb),    
  .pselx_extsys1_axis_ib_apb (pselx_extsys1_axis_ib_apb),    
  .penable_extsys1_axis_ib_apb (penable_extsys1_axis_ib_apb),    
  .pwrite_extsys1_axis_ib_apb (pwrite_extsys1_axis_ib_apb),    
  .prdata_extsys1_axis_ib_apb (prdata_extsys1_axis_ib_apb),    
  .pwdata_extsys1_axis_ib_apb (pwdata_extsys1_axis_ib_apb),    
  .pready_extsys1_axis_ib_apb (pready_extsys1_axis_ib_apb),    
  .pslverr_extsys1_axis_ib_apb (pslverr_extsys1_axis_ib_apb),    
  .a_data_gpv_0_ib1_int (a_data_gpv_0_ib1_int),    
  .a_valid_gpv_0_ib1_int (a_valid_gpv_0_ib1_int),    
  .a_ready_gpv_0_ib1_int (a_ready_gpv_0_ib1_int),    
  .w_data_gpv_0_ib1_int (w_data_gpv_0_ib1_int),    
  .w_valid_gpv_0_ib1_int (w_valid_gpv_0_ib1_int),    
  .w_ready_gpv_0_ib1_int (w_ready_gpv_0_ib1_int),    
  .d_data_gpv_0_ib1_int (d_data_gpv_0_ib1_int),    
  .d_valid_gpv_0_ib1_int (d_valid_gpv_0_ib1_int),    
  .d_ready_gpv_0_ib1_int (d_ready_gpv_0_ib1_int),    
  .paddr_hostcpu_axis_ib_apb (paddr_hostcpu_axis_ib_apb),    
  .pselx_hostcpu_axis_ib_apb (pselx_hostcpu_axis_ib_apb),    
  .penable_hostcpu_axis_ib_apb (penable_hostcpu_axis_ib_apb),    
  .pwrite_hostcpu_axis_ib_apb (pwrite_hostcpu_axis_ib_apb),    
  .prdata_hostcpu_axis_ib_apb (prdata_hostcpu_axis_ib_apb),    
  .pwdata_hostcpu_axis_ib_apb (pwdata_hostcpu_axis_ib_apb),    
  .pready_hostcpu_axis_ib_apb (pready_hostcpu_axis_ib_apb),    
  .pslverr_hostcpu_axis_ib_apb (pslverr_hostcpu_axis_ib_apb),    
  .aclk_r               (aclk_r),    
  .aresetn_r            (aresetn_r),    
  .paddr_secenc_axis_ib_apb (paddr_secenc_axis_ib_apb),    
  .pselx_secenc_axis_ib_apb (pselx_secenc_axis_ib_apb),    
  .penable_secenc_axis_ib_apb (penable_secenc_axis_ib_apb),    
  .pwrite_secenc_axis_ib_apb (pwrite_secenc_axis_ib_apb),    
  .prdata_secenc_axis_ib_apb (prdata_secenc_axis_ib_apb),    
  .pwdata_secenc_axis_ib_apb (pwdata_secenc_axis_ib_apb),    
  .pready_secenc_axis_ib_apb (pready_secenc_axis_ib_apb),    
  .pslverr_secenc_axis_ib_apb (pslverr_secenc_axis_ib_apb)    
);


nic400_rsb_connections_sse710_main     u_rsb_conns (
  .rsb_data_a_master_m  (rsb_data_a_ml_s),    
  .rsb_wptr_a_master_m  (rsb_wptr_a_ml_s),    
  .rsb_rptr_a_master_m  (rsb_rptr_a_ml_s),    
  .rsb_b_rptr_a_master_m (rsb_bin_rptr_a_ml_s),    
  .rsb_data_a_master_s  (rsb_data_a_ml_m),    
  .rsb_wptr_a_master_s  (rsb_wptr_a_ml_m),    
  .rsb_rptr_a_master_s  (rsb_rptr_a_ml_m),    
  .rsb_b_rptr_a_master_s (rsb_bin_rptr_a_ml_m),    
  .rsb_data_a_slave_m   (rsb_data_a_sl_s),    
  .rsb_wptr_a_slave_m   (rsb_wptr_a_sl_s),    
  .rsb_rptr_a_slave_m   (rsb_rptr_a_sl_s),    
  .rsb_b_rptr_a_slave_m (rsb_bin_rptr_a_sl_s),    
  .rsb_data_a_slave_s   (rsb_data_a_sl_m),    
  .rsb_wptr_a_slave_s   (rsb_wptr_a_sl_m),    
  .rsb_rptr_a_slave_s   (rsb_rptr_a_sl_m),    
  .rsb_b_rptr_a_slave_s (rsb_bin_rptr_a_sl_m)    
);



endmodule
