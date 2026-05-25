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




module nic400_cd_a_sse710_sys_apb (
  

  awid_gic_axim,
  awaddr_gic_axim,
  awlen_gic_axim,
  awsize_gic_axim,
  awburst_gic_axim,
  awlock_gic_axim,
  awcache_gic_axim,
  awprot_gic_axim,
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
  awqos_gic_axim,
  arqos_gic_axim,
  

  hselx_gpvmain_ahb,
  haddr_gpvmain_ahb,
  htrans_gpvmain_ahb,
  hwrite_gpvmain_ahb,
  hsize_gpvmain_ahb,
  hburst_gpvmain_ahb,
  hprot_gpvmain_ahb,
  hwdata_gpvmain_ahb,
  hrdata_gpvmain_ahb,
  hreadyout_gpvmain_ahb,
  hready_gpvmain_ahb,
  hresp_gpvmain_ahb,
  

  paddr_hostsysdbg_apb,
  pwdata_hostsysdbg_apb,
  pwrite_hostsysdbg_apb,
  pprot_hostsysdbg_apb,
  pstrb_hostsysdbg_apb,
  penable_hostsysdbg_apb,
  pselx_hostsysdbg_apb,
  prdata_hostsysdbg_apb,
  pslverr_hostsysdbg_apb,
  pready_hostsysdbg_apb,
  

  paddr_sdc600_apb,
  pwdata_sdc600_apb,
  pwrite_sdc600_apb,
  pprot_sdc600_apb,
  pstrb_sdc600_apb,
  penable_sdc600_apb,
  pselx_sdc600_apb,
  prdata_sdc600_apb,
  pslverr_sdc600_apb,
  pready_sdc600_apb,
  

  paddr_es0h_mhu0,
  pwdata_es0h_mhu0,
  pwrite_es0h_mhu0,
  pprot_es0h_mhu0,
  pstrb_es0h_mhu0,
  penable_es0h_mhu0,
  pselx_es0h_mhu0,
  prdata_es0h_mhu0,
  pslverr_es0h_mhu0,
  pready_es0h_mhu0,
  

  paddr_es0h_mhu1,
  pwdata_es0h_mhu1,
  pwrite_es0h_mhu1,
  pprot_es0h_mhu1,
  pstrb_es0h_mhu1,
  penable_es0h_mhu1,
  pselx_es0h_mhu1,
  prdata_es0h_mhu1,
  pslverr_es0h_mhu1,
  pready_es0h_mhu1,
  

  paddr_es1h_mhu0,
  pwdata_es1h_mhu0,
  pwrite_es1h_mhu0,
  pprot_es1h_mhu0,
  pstrb_es1h_mhu0,
  penable_es1h_mhu0,
  pselx_es1h_mhu0,
  prdata_es1h_mhu0,
  pslverr_es1h_mhu0,
  pready_es1h_mhu0,
  

  paddr_es1h_mhu1,
  pwdata_es1h_mhu1,
  pwrite_es1h_mhu1,
  pprot_es1h_mhu1,
  pstrb_es1h_mhu1,
  penable_es1h_mhu1,
  pselx_es1h_mhu1,
  prdata_es1h_mhu1,
  pslverr_es1h_mhu1,
  pready_es1h_mhu1,
  

  paddr_hes0_mhu0,
  pwdata_hes0_mhu0,
  pwrite_hes0_mhu0,
  pprot_hes0_mhu0,
  pstrb_hes0_mhu0,
  penable_hes0_mhu0,
  pselx_hes0_mhu0,
  prdata_hes0_mhu0,
  pslverr_hes0_mhu0,
  pready_hes0_mhu0,
  

  paddr_hes0_mhu1,
  pwdata_hes0_mhu1,
  pwrite_hes0_mhu1,
  pprot_hes0_mhu1,
  pstrb_hes0_mhu1,
  penable_hes0_mhu1,
  pselx_hes0_mhu1,
  prdata_hes0_mhu1,
  pslverr_hes0_mhu1,
  pready_hes0_mhu1,
  

  paddr_hes1_mhu0,
  pwdata_hes1_mhu0,
  pwrite_hes1_mhu0,
  pprot_hes1_mhu0,
  pstrb_hes1_mhu0,
  penable_hes1_mhu0,
  pselx_hes1_mhu0,
  prdata_hes1_mhu0,
  pslverr_hes1_mhu0,
  pready_hes1_mhu0,
  

  paddr_hes1_mhu1,
  pwdata_hes1_mhu1,
  pwrite_hes1_mhu1,
  pprot_hes1_mhu1,
  pstrb_hes1_mhu1,
  penable_hes1_mhu1,
  pselx_hes1_mhu1,
  prdata_hes1_mhu1,
  pslverr_hes1_mhu1,
  pready_hes1_mhu1,
  

  paddr_hse_mhu0,
  pwdata_hse_mhu0,
  pwrite_hse_mhu0,
  pprot_hse_mhu0,
  pstrb_hse_mhu0,
  penable_hse_mhu0,
  pselx_hse_mhu0,
  prdata_hse_mhu0,
  pslverr_hse_mhu0,
  pready_hse_mhu0,
  

  paddr_hse_mhu1,
  pwdata_hse_mhu1,
  pwrite_hse_mhu1,
  pprot_hse_mhu1,
  pstrb_hse_mhu1,
  penable_hse_mhu1,
  pselx_hse_mhu1,
  prdata_hse_mhu1,
  pslverr_hse_mhu1,
  pready_hse_mhu1,
  

  paddr_seh_mhu0,
  pwdata_seh_mhu0,
  pwrite_seh_mhu0,
  pprot_seh_mhu0,
  pstrb_seh_mhu0,
  penable_seh_mhu0,
  pselx_seh_mhu0,
  prdata_seh_mhu0,
  pslverr_seh_mhu0,
  pready_seh_mhu0,
  

  paddr_seh_mhu1,
  pwdata_seh_mhu1,
  pwrite_seh_mhu1,
  pprot_seh_mhu1,
  pstrb_seh_mhu1,
  penable_seh_mhu1,
  pselx_seh_mhu1,
  prdata_seh_mhu1,
  pslverr_seh_mhu1,
  pready_seh_mhu1,
  

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
  awqos_sysperi_axis,
  arqos_sysperi_axis,
  

  cactive_cd_a,
  csysreq_cd_a,
  csysack_cd_a,
  

  a_data_slave_9_ib_int_async,
  a_rpntr_gry_slave_9_ib_int_async,
  a_rpntr_bin_slave_9_ib_int_async,
  a_wpntr_gry_slave_9_ib_int_async,
  d_data_slave_9_ib_int_async,
  d_rpntr_gry_slave_9_ib_int_async,
  d_rpntr_bin_slave_9_ib_int_async,
  d_wpntr_gry_slave_9_ib_int_async,
  w_data_slave_9_ib_int_async,
  w_rpntr_gry_slave_9_ib_int_async,
  w_rpntr_bin_slave_9_ib_int_async,
  w_wpntr_gry_slave_9_ib_int_async,
  empty_slave_9_ib_int_async,


  aclk,
  aclken,
  aresetn

);






output [11:0] awid_gic_axim;
output [31:0] awaddr_gic_axim;
output [7:0]  awlen_gic_axim;
output [2:0]  awsize_gic_axim;
output [1:0]  awburst_gic_axim;
output        awlock_gic_axim;
output [3:0]  awcache_gic_axim;
output [2:0]  awprot_gic_axim;
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
output [3:0]  awqos_gic_axim;
output [3:0]  arqos_gic_axim;


output        hselx_gpvmain_ahb;
output [31:0] haddr_gpvmain_ahb;
output [1:0]  htrans_gpvmain_ahb;
output        hwrite_gpvmain_ahb;
output [2:0]  hsize_gpvmain_ahb;
output [2:0]  hburst_gpvmain_ahb;
output [3:0]  hprot_gpvmain_ahb;
output [31:0] hwdata_gpvmain_ahb;
input  [31:0] hrdata_gpvmain_ahb;
input         hreadyout_gpvmain_ahb;
output        hready_gpvmain_ahb;
input         hresp_gpvmain_ahb;


output [31:0] paddr_hostsysdbg_apb;
output [31:0] pwdata_hostsysdbg_apb;
output        pwrite_hostsysdbg_apb;
output [2:0]  pprot_hostsysdbg_apb;
output [3:0]  pstrb_hostsysdbg_apb;
output        penable_hostsysdbg_apb;
output        pselx_hostsysdbg_apb;
input  [31:0] prdata_hostsysdbg_apb;
input         pslverr_hostsysdbg_apb;
input         pready_hostsysdbg_apb;


output [31:0] paddr_sdc600_apb;
output [31:0] pwdata_sdc600_apb;
output        pwrite_sdc600_apb;
output [2:0]  pprot_sdc600_apb;
output [3:0]  pstrb_sdc600_apb;
output        penable_sdc600_apb;
output        pselx_sdc600_apb;
input  [31:0] prdata_sdc600_apb;
input         pslverr_sdc600_apb;
input         pready_sdc600_apb;


output [31:0] paddr_es0h_mhu0;
output [31:0] pwdata_es0h_mhu0;
output        pwrite_es0h_mhu0;
output [2:0]  pprot_es0h_mhu0;
output [3:0]  pstrb_es0h_mhu0;
output        penable_es0h_mhu0;
output        pselx_es0h_mhu0;
input  [31:0] prdata_es0h_mhu0;
input         pslverr_es0h_mhu0;
input         pready_es0h_mhu0;


output [31:0] paddr_es0h_mhu1;
output [31:0] pwdata_es0h_mhu1;
output        pwrite_es0h_mhu1;
output [2:0]  pprot_es0h_mhu1;
output [3:0]  pstrb_es0h_mhu1;
output        penable_es0h_mhu1;
output        pselx_es0h_mhu1;
input  [31:0] prdata_es0h_mhu1;
input         pslverr_es0h_mhu1;
input         pready_es0h_mhu1;


output [31:0] paddr_es1h_mhu0;
output [31:0] pwdata_es1h_mhu0;
output        pwrite_es1h_mhu0;
output [2:0]  pprot_es1h_mhu0;
output [3:0]  pstrb_es1h_mhu0;
output        penable_es1h_mhu0;
output        pselx_es1h_mhu0;
input  [31:0] prdata_es1h_mhu0;
input         pslverr_es1h_mhu0;
input         pready_es1h_mhu0;


output [31:0] paddr_es1h_mhu1;
output [31:0] pwdata_es1h_mhu1;
output        pwrite_es1h_mhu1;
output [2:0]  pprot_es1h_mhu1;
output [3:0]  pstrb_es1h_mhu1;
output        penable_es1h_mhu1;
output        pselx_es1h_mhu1;
input  [31:0] prdata_es1h_mhu1;
input         pslverr_es1h_mhu1;
input         pready_es1h_mhu1;


output [31:0] paddr_hes0_mhu0;
output [31:0] pwdata_hes0_mhu0;
output        pwrite_hes0_mhu0;
output [2:0]  pprot_hes0_mhu0;
output [3:0]  pstrb_hes0_mhu0;
output        penable_hes0_mhu0;
output        pselx_hes0_mhu0;
input  [31:0] prdata_hes0_mhu0;
input         pslverr_hes0_mhu0;
input         pready_hes0_mhu0;


output [31:0] paddr_hes0_mhu1;
output [31:0] pwdata_hes0_mhu1;
output        pwrite_hes0_mhu1;
output [2:0]  pprot_hes0_mhu1;
output [3:0]  pstrb_hes0_mhu1;
output        penable_hes0_mhu1;
output        pselx_hes0_mhu1;
input  [31:0] prdata_hes0_mhu1;
input         pslverr_hes0_mhu1;
input         pready_hes0_mhu1;


output [31:0] paddr_hes1_mhu0;
output [31:0] pwdata_hes1_mhu0;
output        pwrite_hes1_mhu0;
output [2:0]  pprot_hes1_mhu0;
output [3:0]  pstrb_hes1_mhu0;
output        penable_hes1_mhu0;
output        pselx_hes1_mhu0;
input  [31:0] prdata_hes1_mhu0;
input         pslverr_hes1_mhu0;
input         pready_hes1_mhu0;


output [31:0] paddr_hes1_mhu1;
output [31:0] pwdata_hes1_mhu1;
output        pwrite_hes1_mhu1;
output [2:0]  pprot_hes1_mhu1;
output [3:0]  pstrb_hes1_mhu1;
output        penable_hes1_mhu1;
output        pselx_hes1_mhu1;
input  [31:0] prdata_hes1_mhu1;
input         pslverr_hes1_mhu1;
input         pready_hes1_mhu1;


output [31:0] paddr_hse_mhu0;
output [31:0] pwdata_hse_mhu0;
output        pwrite_hse_mhu0;
output [2:0]  pprot_hse_mhu0;
output [3:0]  pstrb_hse_mhu0;
output        penable_hse_mhu0;
output        pselx_hse_mhu0;
input  [31:0] prdata_hse_mhu0;
input         pslverr_hse_mhu0;
input         pready_hse_mhu0;


output [31:0] paddr_hse_mhu1;
output [31:0] pwdata_hse_mhu1;
output        pwrite_hse_mhu1;
output [2:0]  pprot_hse_mhu1;
output [3:0]  pstrb_hse_mhu1;
output        penable_hse_mhu1;
output        pselx_hse_mhu1;
input  [31:0] prdata_hse_mhu1;
input         pslverr_hse_mhu1;
input         pready_hse_mhu1;


output [31:0] paddr_seh_mhu0;
output [31:0] pwdata_seh_mhu0;
output        pwrite_seh_mhu0;
output [2:0]  pprot_seh_mhu0;
output [3:0]  pstrb_seh_mhu0;
output        penable_seh_mhu0;
output        pselx_seh_mhu0;
input  [31:0] prdata_seh_mhu0;
input         pslverr_seh_mhu0;
input         pready_seh_mhu0;


output [31:0] paddr_seh_mhu1;
output [31:0] pwdata_seh_mhu1;
output        pwrite_seh_mhu1;
output [2:0]  pprot_seh_mhu1;
output [3:0]  pstrb_seh_mhu1;
output        penable_seh_mhu1;
output        pselx_seh_mhu1;
input  [31:0] prdata_seh_mhu1;
input         pslverr_seh_mhu1;
input         pready_seh_mhu1;


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
input  [3:0]  awqos_sysperi_axis;
input  [3:0]  arqos_sysperi_axis;


output        cactive_cd_a;
input         csysreq_cd_a;
output        csysack_cd_a;


output [69:0] a_data_slave_9_ib_int_async;
input  [1:0]  a_rpntr_gry_slave_9_ib_int_async;
input         a_rpntr_bin_slave_9_ib_int_async;
output [1:0]  a_wpntr_gry_slave_9_ib_int_async;
input  [47:0] d_data_slave_9_ib_int_async;
output [1:0]  d_rpntr_gry_slave_9_ib_int_async;
output        d_rpntr_bin_slave_9_ib_int_async;
input  [1:0]  d_wpntr_gry_slave_9_ib_int_async;
output [36:0] w_data_slave_9_ib_int_async;
input  [1:0]  w_rpntr_gry_slave_9_ib_int_async;
input         w_rpntr_bin_slave_9_ib_int_async;
output [1:0]  w_wpntr_gry_slave_9_ib_int_async;
output        empty_slave_9_ib_int_async;


input         aclk;
input         aclken;
input         aresetn;




wire   [69:0]  a_data_slave_9_ib_int_async;
wire   [1:0]   a_wpntr_gry_slave_9_ib_int_async;
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
wire           csysack_cd_a;
wire           d_rpntr_bin_slave_9_ib_int_async;
wire   [1:0]   d_rpntr_gry_slave_9_ib_int_async;
wire           empty_slave_9_ib_int_async;
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
wire   [36:0]  w_data_slave_9_ib_int_async;
wire   [1:0]   w_wpntr_gry_slave_9_ib_int_async;
wire   [31:0]  wdata_gic_axim;
wire   [63:0]  wdata_stm_axim;
wire           wlast_gic_axim;
wire           wlast_stm_axim;
wire           wready_sysperi_axis;
wire   [3:0]   wstrb_gic_axim;
wire   [7:0]   wstrb_stm_axim;
wire           wvalid_gic_axim;
wire           wvalid_stm_axim;
wire           arready_switch0_gic_axim_gic_axim_s;
wire           awready_switch0_gic_axim_gic_axim_s;
wire   [11:0]  bid_switch0_gic_axim_gic_axim_s;
wire   [1:0]   bresp_switch0_gic_axim_gic_axim_s;
wire           bvalid_switch0_gic_axim_gic_axim_s;
wire   [31:0]  rdata_switch0_gic_axim_gic_axim_s;
wire   [11:0]  rid_switch0_gic_axim_gic_axim_s;
wire           rlast_switch0_gic_axim_gic_axim_s;
wire   [1:0]   rresp_switch0_gic_axim_gic_axim_s;
wire           rvalid_switch0_gic_axim_gic_axim_s;
wire           wready_switch0_gic_axim_gic_axim_s;
wire           arready_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire           awready_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [11:0]  bid_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [1:0]   bresp_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire           bvalid_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [31:0]  rdata_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [11:0]  rid_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire           rlast_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [1:0]   rresp_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire           rvalid_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire           wready_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire           arready_switch0_slave_6_slave_6_s;
wire           awready_switch0_slave_6_slave_6_s;
wire   [11:0]  bid_switch0_slave_6_slave_6_s;
wire   [1:0]   bresp_switch0_slave_6_slave_6_s;
wire           bvalid_switch0_slave_6_slave_6_s;
wire   [31:0]  rdata_switch0_slave_6_slave_6_s;
wire   [11:0]  rid_switch0_slave_6_slave_6_s;
wire           rlast_switch0_slave_6_slave_6_s;
wire   [1:0]   rresp_switch0_slave_6_slave_6_s;
wire           rvalid_switch0_slave_6_slave_6_s;
wire           wready_switch0_slave_6_slave_6_s;
wire           arready_switch0_slave_8_slave_8_s;
wire           awready_switch0_slave_8_slave_8_s;
wire   [11:0]  bid_switch0_slave_8_slave_8_s;
wire   [1:0]   bresp_switch0_slave_8_slave_8_s;
wire           bvalid_switch0_slave_8_slave_8_s;
wire   [31:0]  rdata_switch0_slave_8_slave_8_s;
wire   [11:0]  rid_switch0_slave_8_slave_8_s;
wire           rlast_switch0_slave_8_slave_8_s;
wire   [1:0]   rresp_switch0_slave_8_slave_8_s;
wire           rvalid_switch0_slave_8_slave_8_s;
wire           wready_switch0_slave_8_slave_8_s;
wire           arready_stm_axim_ib_stm_axim_stm_axim_s;
wire           awready_stm_axim_ib_stm_axim_stm_axim_s;
wire   [11:0]  bid_stm_axim_ib_stm_axim_stm_axim_s;
wire   [1:0]   bresp_stm_axim_ib_stm_axim_stm_axim_s;
wire           bvalid_stm_axim_ib_stm_axim_stm_axim_s;
wire   [63:0]  rdata_stm_axim_ib_stm_axim_stm_axim_s;
wire   [11:0]  rid_stm_axim_ib_stm_axim_stm_axim_s;
wire           rlast_stm_axim_ib_stm_axim_stm_axim_s;
wire   [1:0]   rresp_stm_axim_ib_stm_axim_stm_axim_s;
wire           rvalid_stm_axim_ib_stm_axim_stm_axim_s;
wire           wready_stm_axim_ib_stm_axim_stm_axim_s;
wire   [31:0]  araddr_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [1:0]   arburst_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [3:0]   arcache_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [11:0]  arid_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [7:0]   arlen_sysperi_axis_sysperi_axis_ib_axi4_s;
wire           arlock_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [2:0]   arprot_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [3:0]   arqv_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [3:0]   arregion_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [2:0]   arsize_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [9:0]   aruser_sysperi_axis_sysperi_axis_ib_axi4_s;
wire           arvalid_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [6:0]   arvalid_vect_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [31:0]  awaddr_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [1:0]   awburst_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [3:0]   awcache_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [11:0]  awid_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [7:0]   awlen_sysperi_axis_sysperi_axis_ib_axi4_s;
wire           awlock_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [2:0]   awprot_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [3:0]   awqv_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [3:0]   awregion_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [2:0]   awsize_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [9:0]   awuser_sysperi_axis_sysperi_axis_ib_axi4_s;
wire           awvalid_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [6:0]   awvalid_vect_sysperi_axis_sysperi_axis_ib_axi4_s;
wire           bready_sysperi_axis_sysperi_axis_ib_axi4_s;
wire           rready_sysperi_axis_sysperi_axis_ib_axi4_s;
wire           cactive_sysperi_axis_hcg;
wire           cactive_sysperi_axis_wakeup_hcg;
wire   [31:0]  wdata_sysperi_axis_sysperi_axis_ib_axi4_s;
wire           wlast_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [3:0]   wstrb_sysperi_axis_sysperi_axis_ib_axi4_s;
wire           wvalid_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [3:0]   arqv_switch0_gic_axim_gic_axim_s;
wire   [31:0]  araddr_switch0_gic_axim_gic_axim_s;
wire   [31:0]  araddr_switch0_stm_axim_ib_axi4_s;
wire   [31:0]  araddr_switch0_slave_8_slave_8_s;
wire   [31:0]  araddr_switch0_slave_9_ib_axi4_s;
wire   [31:0]  araddr_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [31:0]  araddr_switch0_slave_6_slave_6_s;
wire   [1:0]   arburst_switch0_gic_axim_gic_axim_s;
wire   [1:0]   arburst_switch0_stm_axim_ib_axi4_s;
wire   [1:0]   arburst_switch0_slave_8_slave_8_s;
wire   [1:0]   arburst_switch0_slave_9_ib_axi4_s;
wire   [1:0]   arburst_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [1:0]   arburst_switch0_slave_6_slave_6_s;
wire   [3:0]   arcache_switch0_gic_axim_gic_axim_s;
wire   [3:0]   arcache_switch0_stm_axim_ib_axi4_s;
wire   [3:0]   arcache_switch0_slave_8_slave_8_s;
wire   [3:0]   arcache_switch0_slave_9_ib_axi4_s;
wire   [3:0]   arcache_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [3:0]   arcache_switch0_slave_6_slave_6_s;
wire   [11:0]  arid_switch0_gic_axim_gic_axim_s;
wire   [11:0]  arid_switch0_stm_axim_ib_axi4_s;
wire   [11:0]  arid_switch0_slave_8_slave_8_s;
wire   [11:0]  arid_switch0_slave_9_ib_axi4_s;
wire   [11:0]  arid_switch0_ds_0_axi_s_0;
wire   [11:0]  arid_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [11:0]  arid_switch0_slave_6_slave_6_s;
wire   [7:0]   arlen_switch0_gic_axim_gic_axim_s;
wire   [7:0]   arlen_switch0_stm_axim_ib_axi4_s;
wire   [7:0]   arlen_switch0_slave_8_slave_8_s;
wire   [7:0]   arlen_switch0_slave_9_ib_axi4_s;
wire   [7:0]   arlen_switch0_ds_0_axi_s_0;
wire   [7:0]   arlen_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [7:0]   arlen_switch0_slave_6_slave_6_s;
wire           arlock_switch0_gic_axim_gic_axim_s;
wire           arlock_switch0_stm_axim_ib_axi4_s;
wire           arlock_switch0_slave_8_slave_8_s;
wire           arlock_switch0_slave_9_ib_axi4_s;
wire           arlock_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire           arlock_switch0_slave_6_slave_6_s;
wire   [2:0]   arprot_switch0_gic_axim_gic_axim_s;
wire   [2:0]   arprot_switch0_stm_axim_ib_axi4_s;
wire   [2:0]   arprot_switch0_slave_8_slave_8_s;
wire   [2:0]   arprot_switch0_slave_9_ib_axi4_s;
wire   [2:0]   arprot_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [2:0]   arprot_switch0_slave_6_slave_6_s;
wire           arready_sysperi_axis_ib_switch0_axi_s_0;
wire   [3:0]   arregion_switch0_stm_axim_ib_axi4_s;
wire   [3:0]   arregion_switch0_slave_8_slave_8_s;
wire   [3:0]   arregion_switch0_slave_9_ib_axi4_s;
wire   [3:0]   arregion_switch0_slave_6_slave_6_s;
wire   [2:0]   arsize_switch0_gic_axim_gic_axim_s;
wire   [2:0]   arsize_switch0_stm_axim_ib_axi4_s;
wire   [2:0]   arsize_switch0_slave_8_slave_8_s;
wire   [2:0]   arsize_switch0_slave_9_ib_axi4_s;
wire   [2:0]   arsize_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [2:0]   arsize_switch0_slave_6_slave_6_s;
wire   [9:0]   aruser_switch0_gic_axim_gic_axim_s;
wire   [9:0]   aruser_switch0_stm_axim_ib_axi4_s;
wire           arvalid_switch0_gic_axim_gic_axim_s;
wire           arvalid_switch0_stm_axim_ib_axi4_s;
wire           arvalid_switch0_slave_8_slave_8_s;
wire           arvalid_switch0_slave_9_ib_axi4_s;
wire           arvalid_switch0_ds_0_axi_s_0;
wire           arvalid_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire           arvalid_switch0_slave_6_slave_6_s;
wire   [3:0]   awqv_switch0_gic_axim_gic_axim_s;
wire   [31:0]  awaddr_switch0_gic_axim_gic_axim_s;
wire   [31:0]  awaddr_switch0_stm_axim_ib_axi4_s;
wire   [31:0]  awaddr_switch0_slave_8_slave_8_s;
wire   [31:0]  awaddr_switch0_slave_9_ib_axi4_s;
wire   [31:0]  awaddr_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [31:0]  awaddr_switch0_slave_6_slave_6_s;
wire   [1:0]   awburst_switch0_gic_axim_gic_axim_s;
wire   [1:0]   awburst_switch0_stm_axim_ib_axi4_s;
wire   [1:0]   awburst_switch0_slave_8_slave_8_s;
wire   [1:0]   awburst_switch0_slave_9_ib_axi4_s;
wire   [1:0]   awburst_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [1:0]   awburst_switch0_slave_6_slave_6_s;
wire   [3:0]   awcache_switch0_gic_axim_gic_axim_s;
wire   [3:0]   awcache_switch0_stm_axim_ib_axi4_s;
wire   [3:0]   awcache_switch0_slave_8_slave_8_s;
wire   [3:0]   awcache_switch0_slave_9_ib_axi4_s;
wire   [3:0]   awcache_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [3:0]   awcache_switch0_slave_6_slave_6_s;
wire   [11:0]  awid_switch0_gic_axim_gic_axim_s;
wire   [11:0]  awid_switch0_stm_axim_ib_axi4_s;
wire   [11:0]  awid_switch0_slave_8_slave_8_s;
wire   [11:0]  awid_switch0_slave_9_ib_axi4_s;
wire   [11:0]  awid_switch0_ds_0_axi_s_0;
wire   [11:0]  awid_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [11:0]  awid_switch0_slave_6_slave_6_s;
wire   [7:0]   awlen_switch0_gic_axim_gic_axim_s;
wire   [7:0]   awlen_switch0_stm_axim_ib_axi4_s;
wire   [7:0]   awlen_switch0_slave_8_slave_8_s;
wire   [7:0]   awlen_switch0_slave_9_ib_axi4_s;
wire   [7:0]   awlen_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [7:0]   awlen_switch0_slave_6_slave_6_s;
wire           awlock_switch0_gic_axim_gic_axim_s;
wire           awlock_switch0_stm_axim_ib_axi4_s;
wire           awlock_switch0_slave_8_slave_8_s;
wire           awlock_switch0_slave_9_ib_axi4_s;
wire           awlock_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire           awlock_switch0_slave_6_slave_6_s;
wire   [2:0]   awprot_switch0_gic_axim_gic_axim_s;
wire   [2:0]   awprot_switch0_stm_axim_ib_axi4_s;
wire   [2:0]   awprot_switch0_slave_8_slave_8_s;
wire   [2:0]   awprot_switch0_slave_9_ib_axi4_s;
wire   [2:0]   awprot_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [2:0]   awprot_switch0_slave_6_slave_6_s;
wire           awready_sysperi_axis_ib_switch0_axi_s_0;
wire   [3:0]   awregion_switch0_stm_axim_ib_axi4_s;
wire   [3:0]   awregion_switch0_slave_8_slave_8_s;
wire   [3:0]   awregion_switch0_slave_9_ib_axi4_s;
wire   [3:0]   awregion_switch0_slave_6_slave_6_s;
wire   [2:0]   awsize_switch0_gic_axim_gic_axim_s;
wire   [2:0]   awsize_switch0_stm_axim_ib_axi4_s;
wire   [2:0]   awsize_switch0_slave_8_slave_8_s;
wire   [2:0]   awsize_switch0_slave_9_ib_axi4_s;
wire   [2:0]   awsize_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [2:0]   awsize_switch0_slave_6_slave_6_s;
wire   [9:0]   awuser_switch0_gic_axim_gic_axim_s;
wire   [9:0]   awuser_switch0_stm_axim_ib_axi4_s;
wire           awvalid_switch0_gic_axim_gic_axim_s;
wire           awvalid_switch0_stm_axim_ib_axi4_s;
wire           awvalid_switch0_slave_8_slave_8_s;
wire           awvalid_switch0_slave_9_ib_axi4_s;
wire           awvalid_switch0_ds_0_axi_s_0;
wire           awvalid_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire           awvalid_switch0_slave_6_slave_6_s;
wire   [11:0]  bid_sysperi_axis_ib_switch0_axi_s_0;
wire           bready_switch0_gic_axim_gic_axim_s;
wire           bready_switch0_stm_axim_ib_axi4_s;
wire           bready_switch0_slave_8_slave_8_s;
wire           bready_switch0_slave_9_ib_axi4_s;
wire           bready_switch0_ds_0_axi_s_0;
wire           bready_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire           bready_switch0_slave_6_slave_6_s;
wire   [1:0]   bresp_sysperi_axis_ib_switch0_axi_s_0;
wire           bvalid_sysperi_axis_ib_switch0_axi_s_0;
wire   [31:0]  rdata_sysperi_axis_ib_switch0_axi_s_0;
wire   [11:0]  rid_sysperi_axis_ib_switch0_axi_s_0;
wire           rlast_sysperi_axis_ib_switch0_axi_s_0;
wire           rready_switch0_gic_axim_gic_axim_s;
wire           rready_switch0_stm_axim_ib_axi4_s;
wire           rready_switch0_slave_8_slave_8_s;
wire           rready_switch0_slave_9_ib_axi4_s;
wire           rready_switch0_ds_0_axi_s_0;
wire           rready_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire           rready_switch0_slave_6_slave_6_s;
wire   [1:0]   rresp_sysperi_axis_ib_switch0_axi_s_0;
wire           rvalid_sysperi_axis_ib_switch0_axi_s_0;
wire   [31:0]  wdata_switch0_gic_axim_gic_axim_s;
wire   [31:0]  wdata_switch0_stm_axim_ib_axi4_s;
wire   [31:0]  wdata_switch0_slave_8_slave_8_s;
wire   [31:0]  wdata_switch0_slave_9_ib_axi4_s;
wire   [31:0]  wdata_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [31:0]  wdata_switch0_slave_6_slave_6_s;
wire           wlast_switch0_gic_axim_gic_axim_s;
wire           wlast_switch0_stm_axim_ib_axi4_s;
wire           wlast_switch0_slave_8_slave_8_s;
wire           wlast_switch0_slave_9_ib_axi4_s;
wire           wlast_switch0_ds_0_axi_s_0;
wire           wlast_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire           wlast_switch0_slave_6_slave_6_s;
wire           wready_sysperi_axis_ib_switch0_axi_s_0;
wire   [3:0]   wstrb_switch0_gic_axim_gic_axim_s;
wire   [3:0]   wstrb_switch0_stm_axim_ib_axi4_s;
wire   [3:0]   wstrb_switch0_slave_8_slave_8_s;
wire   [3:0]   wstrb_switch0_slave_9_ib_axi4_s;
wire   [3:0]   wstrb_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire   [3:0]   wstrb_switch0_slave_6_slave_6_s;
wire           wvalid_switch0_gic_axim_gic_axim_s;
wire           wvalid_switch0_stm_axim_ib_axi4_s;
wire           wvalid_switch0_slave_8_slave_8_s;
wire           wvalid_switch0_slave_9_ib_axi4_s;
wire           wvalid_switch0_ds_0_axi_s_0;
wire           wvalid_switch0_gpvmain_ahb_gpvmain_ahb_s;
wire           wvalid_switch0_slave_6_slave_6_s;
wire           arready_switch0_ds_0_axi_s_0;
wire           awready_switch0_ds_0_axi_s_0;
wire   [11:0]  bid_switch0_ds_0_axi_s_0;
wire   [1:0]   bresp_switch0_ds_0_axi_s_0;
wire           bvalid_switch0_ds_0_axi_s_0;
wire   [11:0]  rid_switch0_ds_0_axi_s_0;
wire           rlast_switch0_ds_0_axi_s_0;
wire   [1:0]   rresp_switch0_ds_0_axi_s_0;
wire           rvalid_switch0_ds_0_axi_s_0;
wire           wready_switch0_ds_0_axi_s_0;
wire           port_enable_sysperi_axis_port_enable_hcg;
wire           arready_switch0_slave_9_ib_axi4_s;
wire           awready_switch0_slave_9_ib_axi4_s;
wire   [11:0]  bid_switch0_slave_9_ib_axi4_s;
wire   [1:0]   bresp_switch0_slave_9_ib_axi4_s;
wire           bvalid_switch0_slave_9_ib_axi4_s;
wire   [31:0]  rdata_switch0_slave_9_ib_axi4_s;
wire   [11:0]  rid_switch0_slave_9_ib_axi4_s;
wire           rlast_switch0_slave_9_ib_axi4_s;
wire   [1:0]   rresp_switch0_slave_9_ib_axi4_s;
wire           rvalid_switch0_slave_9_ib_axi4_s;
wire           wready_switch0_slave_9_ib_axi4_s;
wire           ar_ready_stm_axim_ib_int;
wire   [31:0]  araddr_stm_axim_ib_stm_axim_stm_axim_s;
wire   [1:0]   arburst_stm_axim_ib_stm_axim_stm_axim_s;
wire   [3:0]   arcache_stm_axim_ib_stm_axim_stm_axim_s;
wire   [11:0]  arid_stm_axim_ib_stm_axim_stm_axim_s;
wire   [7:0]   arlen_stm_axim_ib_stm_axim_stm_axim_s;
wire           arlock_stm_axim_ib_stm_axim_stm_axim_s;
wire   [2:0]   arprot_stm_axim_ib_stm_axim_stm_axim_s;
wire   [2:0]   arsize_stm_axim_ib_stm_axim_stm_axim_s;
wire   [9:0]   aruser_stm_axim_ib_stm_axim_stm_axim_s;
wire           arvalid_stm_axim_ib_stm_axim_stm_axim_s;
wire           aw_ready_stm_axim_ib_int;
wire   [31:0]  awaddr_stm_axim_ib_stm_axim_stm_axim_s;
wire   [1:0]   awburst_stm_axim_ib_stm_axim_stm_axim_s;
wire   [3:0]   awcache_stm_axim_ib_stm_axim_stm_axim_s;
wire   [11:0]  awid_stm_axim_ib_stm_axim_stm_axim_s;
wire   [7:0]   awlen_stm_axim_ib_stm_axim_stm_axim_s;
wire           awlock_stm_axim_ib_stm_axim_stm_axim_s;
wire   [2:0]   awprot_stm_axim_ib_stm_axim_stm_axim_s;
wire   [2:0]   awsize_stm_axim_ib_stm_axim_stm_axim_s;
wire   [9:0]   awuser_stm_axim_ib_stm_axim_stm_axim_s;
wire           awvalid_stm_axim_ib_stm_axim_stm_axim_s;
wire   [13:0]  b_data_stm_axim_ib_int;
wire           b_valid_stm_axim_ib_int;
wire           bready_stm_axim_ib_stm_axim_stm_axim_s;
wire   [78:0]  r_data_stm_axim_ib_int;
wire           r_valid_stm_axim_ib_int;
wire           rready_stm_axim_ib_stm_axim_stm_axim_s;
wire           w_ready_stm_axim_ib_int;
wire   [63:0]  wdata_stm_axim_ib_stm_axim_stm_axim_s;
wire           wlast_stm_axim_ib_stm_axim_stm_axim_s;
wire   [7:0]   wstrb_stm_axim_ib_stm_axim_stm_axim_s;
wire           wvalid_stm_axim_ib_stm_axim_stm_axim_s;
wire   [78:0]  ar_data_stm_axim_ib_int;
wire           ar_valid_stm_axim_ib_int;
wire           arready_switch0_stm_axim_ib_axi4_s;
wire   [78:0]  aw_data_stm_axim_ib_int;
wire           aw_valid_stm_axim_ib_int;
wire           awready_switch0_stm_axim_ib_axi4_s;
wire           b_ready_stm_axim_ib_int;
wire   [11:0]  bid_switch0_stm_axim_ib_axi4_s;
wire   [1:0]   bresp_switch0_stm_axim_ib_axi4_s;
wire           bvalid_switch0_stm_axim_ib_axi4_s;
wire           r_ready_stm_axim_ib_int;
wire   [31:0]  rdata_switch0_stm_axim_ib_axi4_s;
wire   [11:0]  rid_switch0_stm_axim_ib_axi4_s;
wire           rlast_switch0_stm_axim_ib_axi4_s;
wire   [1:0]   rresp_switch0_stm_axim_ib_axi4_s;
wire           rvalid_switch0_stm_axim_ib_axi4_s;
wire   [72:0]  w_data_stm_axim_ib_int;
wire           w_valid_stm_axim_ib_int;
wire           wready_switch0_stm_axim_ib_axi4_s;
wire   [1:0]   ar_rpntr_bin_sysperi_axis_ib_int;
wire   [2:0]   ar_rpntr_gry_sysperi_axis_ib_int;
wire   [31:0]  araddr_sysperi_axis_ib_switch0_axi_s_0;
wire   [1:0]   arburst_sysperi_axis_ib_switch0_axi_s_0;
wire   [3:0]   arcache_sysperi_axis_ib_switch0_axi_s_0;
wire   [11:0]  arid_sysperi_axis_ib_switch0_axi_s_0;
wire   [7:0]   arlen_sysperi_axis_ib_switch0_axi_s_0;
wire           arlock_sysperi_axis_ib_switch0_axi_s_0;
wire   [2:0]   arprot_sysperi_axis_ib_switch0_axi_s_0;
wire   [3:0]   arqv_sysperi_axis_ib_switch0_axi_s_0;
wire   [3:0]   arregion_sysperi_axis_ib_switch0_axi_s_0;
wire   [2:0]   arsize_sysperi_axis_ib_switch0_axi_s_0;
wire   [9:0]   aruser_sysperi_axis_ib_switch0_axi_s_0;
wire           arvalid_sysperi_axis_ib_switch0_axi_s_0;
wire   [6:0]   arvalid_vect_sysperi_axis_ib_switch0_axi_s_0;
wire   [2:0]   aw_rpntr_bin_sysperi_axis_ib_int;
wire   [3:0]   aw_rpntr_gry_sysperi_axis_ib_int;
wire   [31:0]  awaddr_sysperi_axis_ib_switch0_axi_s_0;
wire   [1:0]   awburst_sysperi_axis_ib_switch0_axi_s_0;
wire   [3:0]   awcache_sysperi_axis_ib_switch0_axi_s_0;
wire   [11:0]  awid_sysperi_axis_ib_switch0_axi_s_0;
wire   [7:0]   awlen_sysperi_axis_ib_switch0_axi_s_0;
wire           awlock_sysperi_axis_ib_switch0_axi_s_0;
wire   [2:0]   awprot_sysperi_axis_ib_switch0_axi_s_0;
wire   [3:0]   awqv_sysperi_axis_ib_switch0_axi_s_0;
wire   [3:0]   awregion_sysperi_axis_ib_switch0_axi_s_0;
wire   [2:0]   awsize_sysperi_axis_ib_switch0_axi_s_0;
wire   [9:0]   awuser_sysperi_axis_ib_switch0_axi_s_0;
wire           awvalid_sysperi_axis_ib_switch0_axi_s_0;
wire   [6:0]   awvalid_vect_sysperi_axis_ib_switch0_axi_s_0;
wire   [13:0]  b_data_sysperi_axis_ib_int;
wire   [3:0]   b_wpntr_gry_sysperi_axis_ib_int;
wire           bready_sysperi_axis_ib_switch0_axi_s_0;
wire   [46:0]  r_data_sysperi_axis_ib_int;
wire   [2:0]   r_wpntr_gry_sysperi_axis_ib_int;
wire           rready_sysperi_axis_ib_switch0_axi_s_0;
wire   [2:0]   w_rpntr_bin_sysperi_axis_ib_int;
wire   [3:0]   w_rpntr_gry_sysperi_axis_ib_int;
wire   [31:0]  wdata_sysperi_axis_ib_switch0_axi_s_0;
wire           wlast_sysperi_axis_ib_switch0_axi_s_0;
wire   [3:0]   wstrb_sysperi_axis_ib_switch0_axi_s_0;
wire           wvalid_sysperi_axis_ib_switch0_axi_s_0;
wire   [89:0]  ar_data_sysperi_axis_ib_int;
wire   [2:0]   ar_wpntr_gry_sysperi_axis_ib_int;
wire           arready_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [89:0]  aw_data_sysperi_axis_ib_int;
wire   [3:0]   aw_wpntr_gry_sysperi_axis_ib_int;
wire           awready_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [2:0]   b_rpntr_bin_sysperi_axis_ib_int;
wire   [3:0]   b_rpntr_gry_sysperi_axis_ib_int;
wire   [11:0]  bid_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [1:0]   bresp_sysperi_axis_sysperi_axis_ib_axi4_s;
wire           bvalid_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [1:0]   r_rpntr_bin_sysperi_axis_ib_int;
wire   [2:0]   r_rpntr_gry_sysperi_axis_ib_int;
wire   [31:0]  rdata_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [11:0]  rid_sysperi_axis_sysperi_axis_ib_axi4_s;
wire           rlast_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [1:0]   rresp_sysperi_axis_sysperi_axis_ib_axi4_s;
wire           rvalid_sysperi_axis_sysperi_axis_ib_axi4_s;
wire   [36:0]  w_data_sysperi_axis_ib_int;
wire   [3:0]   w_wpntr_gry_sysperi_axis_ib_int;
wire           wready_sysperi_axis_sysperi_axis_ib_axi4_s;
wire           a_rpntr_bin_slave_9_ib_int_async;
wire   [1:0]   a_rpntr_gry_slave_9_ib_int_async;
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
wire   [47:0]  d_data_slave_9_ib_int_async;
wire   [1:0]   d_wpntr_gry_slave_9_ib_int_async;
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
wire           w_rpntr_bin_slave_9_ib_int_async;
wire   [1:0]   w_rpntr_gry_slave_9_ib_int_async;
wire   [31:0]  wdata_sysperi_axis;
wire           wlast_sysperi_axis;
wire           wready_gic_axim;
wire           wready_stm_axim;
wire   [3:0]   wstrb_sysperi_axis;
wire           wvalid_sysperi_axis;




nic400_amib_gic_axim_sse710_sys_apb     u_amib_gic_axim (
  .awid_gic_axim_m      (awid_gic_axim),
  .awaddr_gic_axim_m    (awaddr_gic_axim),
  .awlen_gic_axim_m     (awlen_gic_axim),
  .awsize_gic_axim_m    (awsize_gic_axim),
  .awburst_gic_axim_m   (awburst_gic_axim),
  .awlock_gic_axim_m    (awlock_gic_axim),
  .awcache_gic_axim_m   (awcache_gic_axim),
  .awprot_gic_axim_m    (awprot_gic_axim),
  .awvalid_gic_axim_m   (awvalid_gic_axim),
  .awready_gic_axim_m   (awready_gic_axim),
  .wdata_gic_axim_m     (wdata_gic_axim),
  .wstrb_gic_axim_m     (wstrb_gic_axim),
  .wlast_gic_axim_m     (wlast_gic_axim),
  .wvalid_gic_axim_m    (wvalid_gic_axim),
  .wready_gic_axim_m    (wready_gic_axim),
  .bid_gic_axim_m       (bid_gic_axim),
  .bresp_gic_axim_m     (bresp_gic_axim),
  .bvalid_gic_axim_m    (bvalid_gic_axim),
  .bready_gic_axim_m    (bready_gic_axim),
  .arid_gic_axim_m      (arid_gic_axim),
  .araddr_gic_axim_m    (araddr_gic_axim),
  .arlen_gic_axim_m     (arlen_gic_axim),
  .arsize_gic_axim_m    (arsize_gic_axim),
  .arburst_gic_axim_m   (arburst_gic_axim),
  .arlock_gic_axim_m    (arlock_gic_axim),
  .arcache_gic_axim_m   (arcache_gic_axim),
  .arprot_gic_axim_m    (arprot_gic_axim),
  .arvalid_gic_axim_m   (arvalid_gic_axim),
  .arready_gic_axim_m   (arready_gic_axim),
  .rid_gic_axim_m       (rid_gic_axim),
  .rdata_gic_axim_m     (rdata_gic_axim),
  .rresp_gic_axim_m     (rresp_gic_axim),
  .rlast_gic_axim_m     (rlast_gic_axim),
  .rvalid_gic_axim_m    (rvalid_gic_axim),
  .rready_gic_axim_m    (rready_gic_axim),
  .awuser_gic_axim_m    (awuser_gic_axim),
  .aruser_gic_axim_m    (aruser_gic_axim),
  .awqv_gic_axim_m      (awqos_gic_axim),
  .arqv_gic_axim_m      (arqos_gic_axim),
  .awid_gic_axim_s      (awid_switch0_gic_axim_gic_axim_s),
  .awaddr_gic_axim_s    (awaddr_switch0_gic_axim_gic_axim_s),
  .awlen_gic_axim_s     (awlen_switch0_gic_axim_gic_axim_s),
  .awsize_gic_axim_s    (awsize_switch0_gic_axim_gic_axim_s),
  .awburst_gic_axim_s   (awburst_switch0_gic_axim_gic_axim_s),
  .awlock_gic_axim_s    (awlock_switch0_gic_axim_gic_axim_s),
  .awcache_gic_axim_s   (awcache_switch0_gic_axim_gic_axim_s),
  .awprot_gic_axim_s    (awprot_switch0_gic_axim_gic_axim_s),
  .awvalid_gic_axim_s   (awvalid_switch0_gic_axim_gic_axim_s),
  .awready_gic_axim_s   (awready_switch0_gic_axim_gic_axim_s),
  .wdata_gic_axim_s     (wdata_switch0_gic_axim_gic_axim_s),
  .wstrb_gic_axim_s     (wstrb_switch0_gic_axim_gic_axim_s),
  .wlast_gic_axim_s     (wlast_switch0_gic_axim_gic_axim_s),
  .wvalid_gic_axim_s    (wvalid_switch0_gic_axim_gic_axim_s),
  .wready_gic_axim_s    (wready_switch0_gic_axim_gic_axim_s),
  .bid_gic_axim_s       (bid_switch0_gic_axim_gic_axim_s),
  .bresp_gic_axim_s     (bresp_switch0_gic_axim_gic_axim_s),
  .bvalid_gic_axim_s    (bvalid_switch0_gic_axim_gic_axim_s),
  .bready_gic_axim_s    (bready_switch0_gic_axim_gic_axim_s),
  .arid_gic_axim_s      (arid_switch0_gic_axim_gic_axim_s),
  .araddr_gic_axim_s    (araddr_switch0_gic_axim_gic_axim_s),
  .arlen_gic_axim_s     (arlen_switch0_gic_axim_gic_axim_s),
  .arsize_gic_axim_s    (arsize_switch0_gic_axim_gic_axim_s),
  .arburst_gic_axim_s   (arburst_switch0_gic_axim_gic_axim_s),
  .arlock_gic_axim_s    (arlock_switch0_gic_axim_gic_axim_s),
  .arcache_gic_axim_s   (arcache_switch0_gic_axim_gic_axim_s),
  .arprot_gic_axim_s    (arprot_switch0_gic_axim_gic_axim_s),
  .arvalid_gic_axim_s   (arvalid_switch0_gic_axim_gic_axim_s),
  .arready_gic_axim_s   (arready_switch0_gic_axim_gic_axim_s),
  .rid_gic_axim_s       (rid_switch0_gic_axim_gic_axim_s),
  .rdata_gic_axim_s     (rdata_switch0_gic_axim_gic_axim_s),
  .rresp_gic_axim_s     (rresp_switch0_gic_axim_gic_axim_s),
  .rlast_gic_axim_s     (rlast_switch0_gic_axim_gic_axim_s),
  .rvalid_gic_axim_s    (rvalid_switch0_gic_axim_gic_axim_s),
  .rready_gic_axim_s    (rready_switch0_gic_axim_gic_axim_s),
  .awuser_gic_axim_s    (awuser_switch0_gic_axim_gic_axim_s),
  .aruser_gic_axim_s    (aruser_switch0_gic_axim_gic_axim_s),
  .awqv_gic_axim_s      (awqv_switch0_gic_axim_gic_axim_s),
  .arqv_gic_axim_s      (arqv_switch0_gic_axim_gic_axim_s),
  .aclk                 (aclk),
  .aresetn              (aresetn)
);


nic400_amib_gpvmain_ahb_sse710_sys_apb     u_amib_gpvmain_ahb (
  .hsel_gpvmain_ahb_m   (hselx_gpvmain_ahb),
  .haddr_gpvmain_ahb_m  (haddr_gpvmain_ahb),
  .htrans_gpvmain_ahb_m (htrans_gpvmain_ahb),
  .hwrite_gpvmain_ahb_m (hwrite_gpvmain_ahb),
  .hsize_gpvmain_ahb_m  (hsize_gpvmain_ahb),
  .hburst_gpvmain_ahb_m (hburst_gpvmain_ahb),
  .hprot_gpvmain_ahb_m  (hprot_gpvmain_ahb),
  .hwdata_gpvmain_ahb_m (hwdata_gpvmain_ahb),
  .hrdata_gpvmain_ahb_m (hrdata_gpvmain_ahb),
  .hready_gpvmain_ahb_m (hreadyout_gpvmain_ahb),
  .hreadymux_gpvmain_ahb_m (hready_gpvmain_ahb),
  .hresp_gpvmain_ahb_m  (hresp_gpvmain_ahb),
  .awid_gpvmain_ahb_s   (awid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awaddr_gpvmain_ahb_s (awaddr_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awlen_gpvmain_ahb_s  (awlen_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awsize_gpvmain_ahb_s (awsize_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awburst_gpvmain_ahb_s (awburst_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awlock_gpvmain_ahb_s (awlock_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awcache_gpvmain_ahb_s (awcache_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awprot_gpvmain_ahb_s (awprot_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awvalid_gpvmain_ahb_s (awvalid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awready_gpvmain_ahb_s (awready_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .wdata_gpvmain_ahb_s  (wdata_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .wstrb_gpvmain_ahb_s  (wstrb_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .wlast_gpvmain_ahb_s  (wlast_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .wvalid_gpvmain_ahb_s (wvalid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .wready_gpvmain_ahb_s (wready_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .bid_gpvmain_ahb_s    (bid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .bresp_gpvmain_ahb_s  (bresp_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .bvalid_gpvmain_ahb_s (bvalid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .bready_gpvmain_ahb_s (bready_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arid_gpvmain_ahb_s   (arid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .araddr_gpvmain_ahb_s (araddr_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arlen_gpvmain_ahb_s  (arlen_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arsize_gpvmain_ahb_s (arsize_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arburst_gpvmain_ahb_s (arburst_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arlock_gpvmain_ahb_s (arlock_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arcache_gpvmain_ahb_s (arcache_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arprot_gpvmain_ahb_s (arprot_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arvalid_gpvmain_ahb_s (arvalid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arready_gpvmain_ahb_s (arready_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .rid_gpvmain_ahb_s    (rid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .rdata_gpvmain_ahb_s  (rdata_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .rresp_gpvmain_ahb_s  (rresp_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .rlast_gpvmain_ahb_s  (rlast_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .rvalid_gpvmain_ahb_s (rvalid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .rready_gpvmain_ahb_s (rready_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .aclk                 (aclk),
  .aresetn              (aresetn)
);


nic400_amib_slave_6_sse710_sys_apb     u_amib_slave_6 (
  .paddr_hostsysdbg_apb (paddr_hostsysdbg_apb),
  .pwdata_hostsysdbg_apb (pwdata_hostsysdbg_apb),
  .pwrite_hostsysdbg_apb (pwrite_hostsysdbg_apb),
  .pprot_hostsysdbg_apb (pprot_hostsysdbg_apb),
  .pstrb_hostsysdbg_apb (pstrb_hostsysdbg_apb),
  .penable_hostsysdbg_apb (penable_hostsysdbg_apb),
  .psel_hostsysdbg_apb  (pselx_hostsysdbg_apb),
  .prdata_hostsysdbg_apb (prdata_hostsysdbg_apb),
  .pslverr_hostsysdbg_apb (pslverr_hostsysdbg_apb),
  .pready_hostsysdbg_apb (pready_hostsysdbg_apb),
  .paddr_sdc600_apb     (paddr_sdc600_apb),
  .pwdata_sdc600_apb    (pwdata_sdc600_apb),
  .pwrite_sdc600_apb    (pwrite_sdc600_apb),
  .pprot_sdc600_apb     (pprot_sdc600_apb),
  .pstrb_sdc600_apb     (pstrb_sdc600_apb),
  .penable_sdc600_apb   (penable_sdc600_apb),
  .psel_sdc600_apb      (pselx_sdc600_apb),
  .prdata_sdc600_apb    (prdata_sdc600_apb),
  .pslverr_sdc600_apb   (pslverr_sdc600_apb),
  .pready_sdc600_apb    (pready_sdc600_apb),
  .aclk                 (aclk),
  .apb_pclken           (aclken),
  .aresetn              (aresetn),
  .awid_slave_6_s       (awid_switch0_slave_6_slave_6_s),
  .awaddr_slave_6_s     (awaddr_switch0_slave_6_slave_6_s),
  .awlen_slave_6_s      (awlen_switch0_slave_6_slave_6_s),
  .awsize_slave_6_s     (awsize_switch0_slave_6_slave_6_s),
  .awburst_slave_6_s    (awburst_switch0_slave_6_slave_6_s),
  .awlock_slave_6_s     (awlock_switch0_slave_6_slave_6_s),
  .awcache_slave_6_s    (awcache_switch0_slave_6_slave_6_s),
  .awprot_slave_6_s     (awprot_switch0_slave_6_slave_6_s),
  .awvalid_slave_6_s    (awvalid_switch0_slave_6_slave_6_s),
  .awregion_slave_6_s   (awregion_switch0_slave_6_slave_6_s),
  .awready_slave_6_s    (awready_switch0_slave_6_slave_6_s),
  .wdata_slave_6_s      (wdata_switch0_slave_6_slave_6_s),
  .wstrb_slave_6_s      (wstrb_switch0_slave_6_slave_6_s),
  .wlast_slave_6_s      (wlast_switch0_slave_6_slave_6_s),
  .wvalid_slave_6_s     (wvalid_switch0_slave_6_slave_6_s),
  .wready_slave_6_s     (wready_switch0_slave_6_slave_6_s),
  .bid_slave_6_s        (bid_switch0_slave_6_slave_6_s),
  .bresp_slave_6_s      (bresp_switch0_slave_6_slave_6_s),
  .bvalid_slave_6_s     (bvalid_switch0_slave_6_slave_6_s),
  .bready_slave_6_s     (bready_switch0_slave_6_slave_6_s),
  .arid_slave_6_s       (arid_switch0_slave_6_slave_6_s),
  .araddr_slave_6_s     (araddr_switch0_slave_6_slave_6_s),
  .arlen_slave_6_s      (arlen_switch0_slave_6_slave_6_s),
  .arsize_slave_6_s     (arsize_switch0_slave_6_slave_6_s),
  .arburst_slave_6_s    (arburst_switch0_slave_6_slave_6_s),
  .arlock_slave_6_s     (arlock_switch0_slave_6_slave_6_s),
  .arcache_slave_6_s    (arcache_switch0_slave_6_slave_6_s),
  .arprot_slave_6_s     (arprot_switch0_slave_6_slave_6_s),
  .arvalid_slave_6_s    (arvalid_switch0_slave_6_slave_6_s),
  .arregion_slave_6_s   (arregion_switch0_slave_6_slave_6_s),
  .arready_slave_6_s    (arready_switch0_slave_6_slave_6_s),
  .rid_slave_6_s        (rid_switch0_slave_6_slave_6_s),
  .rdata_slave_6_s      (rdata_switch0_slave_6_slave_6_s),
  .rresp_slave_6_s      (rresp_switch0_slave_6_slave_6_s),
  .rlast_slave_6_s      (rlast_switch0_slave_6_slave_6_s),
  .rvalid_slave_6_s     (rvalid_switch0_slave_6_slave_6_s),
  .rready_slave_6_s     (rready_switch0_slave_6_slave_6_s)
);


nic400_amib_slave_8_sse710_sys_apb     u_amib_slave_8 (
  .paddr_es0h_mhu0      (paddr_es0h_mhu0),
  .pwdata_es0h_mhu0     (pwdata_es0h_mhu0),
  .pwrite_es0h_mhu0     (pwrite_es0h_mhu0),
  .pprot_es0h_mhu0      (pprot_es0h_mhu0),
  .pstrb_es0h_mhu0      (pstrb_es0h_mhu0),
  .penable_es0h_mhu0    (penable_es0h_mhu0),
  .psel_es0h_mhu0       (pselx_es0h_mhu0),
  .prdata_es0h_mhu0     (prdata_es0h_mhu0),
  .pslverr_es0h_mhu0    (pslverr_es0h_mhu0),
  .pready_es0h_mhu0     (pready_es0h_mhu0),
  .paddr_es0h_mhu1      (paddr_es0h_mhu1),
  .pwdata_es0h_mhu1     (pwdata_es0h_mhu1),
  .pwrite_es0h_mhu1     (pwrite_es0h_mhu1),
  .pprot_es0h_mhu1      (pprot_es0h_mhu1),
  .pstrb_es0h_mhu1      (pstrb_es0h_mhu1),
  .penable_es0h_mhu1    (penable_es0h_mhu1),
  .psel_es0h_mhu1       (pselx_es0h_mhu1),
  .prdata_es0h_mhu1     (prdata_es0h_mhu1),
  .pslverr_es0h_mhu1    (pslverr_es0h_mhu1),
  .pready_es0h_mhu1     (pready_es0h_mhu1),
  .paddr_es1h_mhu0      (paddr_es1h_mhu0),
  .pwdata_es1h_mhu0     (pwdata_es1h_mhu0),
  .pwrite_es1h_mhu0     (pwrite_es1h_mhu0),
  .pprot_es1h_mhu0      (pprot_es1h_mhu0),
  .pstrb_es1h_mhu0      (pstrb_es1h_mhu0),
  .penable_es1h_mhu0    (penable_es1h_mhu0),
  .psel_es1h_mhu0       (pselx_es1h_mhu0),
  .prdata_es1h_mhu0     (prdata_es1h_mhu0),
  .pslverr_es1h_mhu0    (pslverr_es1h_mhu0),
  .pready_es1h_mhu0     (pready_es1h_mhu0),
  .paddr_es1h_mhu1      (paddr_es1h_mhu1),
  .pwdata_es1h_mhu1     (pwdata_es1h_mhu1),
  .pwrite_es1h_mhu1     (pwrite_es1h_mhu1),
  .pprot_es1h_mhu1      (pprot_es1h_mhu1),
  .pstrb_es1h_mhu1      (pstrb_es1h_mhu1),
  .penable_es1h_mhu1    (penable_es1h_mhu1),
  .psel_es1h_mhu1       (pselx_es1h_mhu1),
  .prdata_es1h_mhu1     (prdata_es1h_mhu1),
  .pslverr_es1h_mhu1    (pslverr_es1h_mhu1),
  .pready_es1h_mhu1     (pready_es1h_mhu1),
  .aclk                 (aclk),
  .apb_pclken           (aclken),
  .aresetn              (aresetn),
  .paddr_hes0_mhu0      (paddr_hes0_mhu0),
  .pwdata_hes0_mhu0     (pwdata_hes0_mhu0),
  .pwrite_hes0_mhu0     (pwrite_hes0_mhu0),
  .pprot_hes0_mhu0      (pprot_hes0_mhu0),
  .pstrb_hes0_mhu0      (pstrb_hes0_mhu0),
  .penable_hes0_mhu0    (penable_hes0_mhu0),
  .psel_hes0_mhu0       (pselx_hes0_mhu0),
  .prdata_hes0_mhu0     (prdata_hes0_mhu0),
  .pslverr_hes0_mhu0    (pslverr_hes0_mhu0),
  .pready_hes0_mhu0     (pready_hes0_mhu0),
  .paddr_hes0_mhu1      (paddr_hes0_mhu1),
  .pwdata_hes0_mhu1     (pwdata_hes0_mhu1),
  .pwrite_hes0_mhu1     (pwrite_hes0_mhu1),
  .pprot_hes0_mhu1      (pprot_hes0_mhu1),
  .pstrb_hes0_mhu1      (pstrb_hes0_mhu1),
  .penable_hes0_mhu1    (penable_hes0_mhu1),
  .psel_hes0_mhu1       (pselx_hes0_mhu1),
  .prdata_hes0_mhu1     (prdata_hes0_mhu1),
  .pslverr_hes0_mhu1    (pslverr_hes0_mhu1),
  .pready_hes0_mhu1     (pready_hes0_mhu1),
  .paddr_hes1_mhu0      (paddr_hes1_mhu0),
  .pwdata_hes1_mhu0     (pwdata_hes1_mhu0),
  .pwrite_hes1_mhu0     (pwrite_hes1_mhu0),
  .pprot_hes1_mhu0      (pprot_hes1_mhu0),
  .pstrb_hes1_mhu0      (pstrb_hes1_mhu0),
  .penable_hes1_mhu0    (penable_hes1_mhu0),
  .psel_hes1_mhu0       (pselx_hes1_mhu0),
  .prdata_hes1_mhu0     (prdata_hes1_mhu0),
  .pslverr_hes1_mhu0    (pslverr_hes1_mhu0),
  .pready_hes1_mhu0     (pready_hes1_mhu0),
  .paddr_hes1_mhu1      (paddr_hes1_mhu1),
  .pwdata_hes1_mhu1     (pwdata_hes1_mhu1),
  .pwrite_hes1_mhu1     (pwrite_hes1_mhu1),
  .pprot_hes1_mhu1      (pprot_hes1_mhu1),
  .pstrb_hes1_mhu1      (pstrb_hes1_mhu1),
  .penable_hes1_mhu1    (penable_hes1_mhu1),
  .psel_hes1_mhu1       (pselx_hes1_mhu1),
  .prdata_hes1_mhu1     (prdata_hes1_mhu1),
  .pslverr_hes1_mhu1    (pslverr_hes1_mhu1),
  .pready_hes1_mhu1     (pready_hes1_mhu1),
  .paddr_hse_mhu0       (paddr_hse_mhu0),
  .pwdata_hse_mhu0      (pwdata_hse_mhu0),
  .pwrite_hse_mhu0      (pwrite_hse_mhu0),
  .pprot_hse_mhu0       (pprot_hse_mhu0),
  .pstrb_hse_mhu0       (pstrb_hse_mhu0),
  .penable_hse_mhu0     (penable_hse_mhu0),
  .psel_hse_mhu0        (pselx_hse_mhu0),
  .prdata_hse_mhu0      (prdata_hse_mhu0),
  .pslverr_hse_mhu0     (pslverr_hse_mhu0),
  .pready_hse_mhu0      (pready_hse_mhu0),
  .paddr_hse_mhu1       (paddr_hse_mhu1),
  .pwdata_hse_mhu1      (pwdata_hse_mhu1),
  .pwrite_hse_mhu1      (pwrite_hse_mhu1),
  .pprot_hse_mhu1       (pprot_hse_mhu1),
  .pstrb_hse_mhu1       (pstrb_hse_mhu1),
  .penable_hse_mhu1     (penable_hse_mhu1),
  .psel_hse_mhu1        (pselx_hse_mhu1),
  .prdata_hse_mhu1      (prdata_hse_mhu1),
  .pslverr_hse_mhu1     (pslverr_hse_mhu1),
  .pready_hse_mhu1      (pready_hse_mhu1),
  .paddr_seh_mhu0       (paddr_seh_mhu0),
  .pwdata_seh_mhu0      (pwdata_seh_mhu0),
  .pwrite_seh_mhu0      (pwrite_seh_mhu0),
  .pprot_seh_mhu0       (pprot_seh_mhu0),
  .pstrb_seh_mhu0       (pstrb_seh_mhu0),
  .penable_seh_mhu0     (penable_seh_mhu0),
  .psel_seh_mhu0        (pselx_seh_mhu0),
  .prdata_seh_mhu0      (prdata_seh_mhu0),
  .pslverr_seh_mhu0     (pslverr_seh_mhu0),
  .pready_seh_mhu0      (pready_seh_mhu0),
  .paddr_seh_mhu1       (paddr_seh_mhu1),
  .pwdata_seh_mhu1      (pwdata_seh_mhu1),
  .pwrite_seh_mhu1      (pwrite_seh_mhu1),
  .pprot_seh_mhu1       (pprot_seh_mhu1),
  .pstrb_seh_mhu1       (pstrb_seh_mhu1),
  .penable_seh_mhu1     (penable_seh_mhu1),
  .psel_seh_mhu1        (pselx_seh_mhu1),
  .prdata_seh_mhu1      (prdata_seh_mhu1),
  .pslverr_seh_mhu1     (pslverr_seh_mhu1),
  .pready_seh_mhu1      (pready_seh_mhu1),
  .awid_slave_8_s       (awid_switch0_slave_8_slave_8_s),
  .awaddr_slave_8_s     (awaddr_switch0_slave_8_slave_8_s),
  .awlen_slave_8_s      (awlen_switch0_slave_8_slave_8_s),
  .awsize_slave_8_s     (awsize_switch0_slave_8_slave_8_s),
  .awburst_slave_8_s    (awburst_switch0_slave_8_slave_8_s),
  .awlock_slave_8_s     (awlock_switch0_slave_8_slave_8_s),
  .awcache_slave_8_s    (awcache_switch0_slave_8_slave_8_s),
  .awprot_slave_8_s     (awprot_switch0_slave_8_slave_8_s),
  .awvalid_slave_8_s    (awvalid_switch0_slave_8_slave_8_s),
  .awregion_slave_8_s   (awregion_switch0_slave_8_slave_8_s),
  .awready_slave_8_s    (awready_switch0_slave_8_slave_8_s),
  .wdata_slave_8_s      (wdata_switch0_slave_8_slave_8_s),
  .wstrb_slave_8_s      (wstrb_switch0_slave_8_slave_8_s),
  .wlast_slave_8_s      (wlast_switch0_slave_8_slave_8_s),
  .wvalid_slave_8_s     (wvalid_switch0_slave_8_slave_8_s),
  .wready_slave_8_s     (wready_switch0_slave_8_slave_8_s),
  .bid_slave_8_s        (bid_switch0_slave_8_slave_8_s),
  .bresp_slave_8_s      (bresp_switch0_slave_8_slave_8_s),
  .bvalid_slave_8_s     (bvalid_switch0_slave_8_slave_8_s),
  .bready_slave_8_s     (bready_switch0_slave_8_slave_8_s),
  .arid_slave_8_s       (arid_switch0_slave_8_slave_8_s),
  .araddr_slave_8_s     (araddr_switch0_slave_8_slave_8_s),
  .arlen_slave_8_s      (arlen_switch0_slave_8_slave_8_s),
  .arsize_slave_8_s     (arsize_switch0_slave_8_slave_8_s),
  .arburst_slave_8_s    (arburst_switch0_slave_8_slave_8_s),
  .arlock_slave_8_s     (arlock_switch0_slave_8_slave_8_s),
  .arcache_slave_8_s    (arcache_switch0_slave_8_slave_8_s),
  .arprot_slave_8_s     (arprot_switch0_slave_8_slave_8_s),
  .arvalid_slave_8_s    (arvalid_switch0_slave_8_slave_8_s),
  .arregion_slave_8_s   (arregion_switch0_slave_8_slave_8_s),
  .arready_slave_8_s    (arready_switch0_slave_8_slave_8_s),
  .rid_slave_8_s        (rid_switch0_slave_8_slave_8_s),
  .rdata_slave_8_s      (rdata_switch0_slave_8_slave_8_s),
  .rresp_slave_8_s      (rresp_switch0_slave_8_slave_8_s),
  .rlast_slave_8_s      (rlast_switch0_slave_8_slave_8_s),
  .rvalid_slave_8_s     (rvalid_switch0_slave_8_slave_8_s),
  .rready_slave_8_s     (rready_switch0_slave_8_slave_8_s)
);


nic400_amib_stm_axim_sse710_sys_apb     u_amib_stm_axim (
  .awid_stm_axim_m      (awid_stm_axim),
  .awaddr_stm_axim_m    (awaddr_stm_axim),
  .awlen_stm_axim_m     (awlen_stm_axim),
  .awsize_stm_axim_m    (awsize_stm_axim),
  .awburst_stm_axim_m   (awburst_stm_axim),
  .awlock_stm_axim_m    (awlock_stm_axim),
  .awcache_stm_axim_m   (awcache_stm_axim),
  .awprot_stm_axim_m    (awprot_stm_axim),
  .awvalid_stm_axim_m   (awvalid_stm_axim),
  .awready_stm_axim_m   (awready_stm_axim),
  .wdata_stm_axim_m     (wdata_stm_axim),
  .wstrb_stm_axim_m     (wstrb_stm_axim),
  .wlast_stm_axim_m     (wlast_stm_axim),
  .wvalid_stm_axim_m    (wvalid_stm_axim),
  .wready_stm_axim_m    (wready_stm_axim),
  .bid_stm_axim_m       (bid_stm_axim),
  .bresp_stm_axim_m     (bresp_stm_axim),
  .bvalid_stm_axim_m    (bvalid_stm_axim),
  .bready_stm_axim_m    (bready_stm_axim),
  .arid_stm_axim_m      (arid_stm_axim),
  .araddr_stm_axim_m    (araddr_stm_axim),
  .arlen_stm_axim_m     (arlen_stm_axim),
  .arsize_stm_axim_m    (arsize_stm_axim),
  .arburst_stm_axim_m   (arburst_stm_axim),
  .arlock_stm_axim_m    (arlock_stm_axim),
  .arcache_stm_axim_m   (arcache_stm_axim),
  .arprot_stm_axim_m    (arprot_stm_axim),
  .arvalid_stm_axim_m   (arvalid_stm_axim),
  .arready_stm_axim_m   (arready_stm_axim),
  .rid_stm_axim_m       (rid_stm_axim),
  .rdata_stm_axim_m     (rdata_stm_axim),
  .rresp_stm_axim_m     (rresp_stm_axim),
  .rlast_stm_axim_m     (rlast_stm_axim),
  .rvalid_stm_axim_m    (rvalid_stm_axim),
  .rready_stm_axim_m    (rready_stm_axim),
  .awuser_stm_axim_m    (awuser_stm_axim),
  .aruser_stm_axim_m    (aruser_stm_axim),
  .awid_stm_axim_s      (awid_stm_axim_ib_stm_axim_stm_axim_s),
  .awaddr_stm_axim_s    (awaddr_stm_axim_ib_stm_axim_stm_axim_s),
  .awlen_stm_axim_s     (awlen_stm_axim_ib_stm_axim_stm_axim_s),
  .awsize_stm_axim_s    (awsize_stm_axim_ib_stm_axim_stm_axim_s),
  .awburst_stm_axim_s   (awburst_stm_axim_ib_stm_axim_stm_axim_s),
  .awlock_stm_axim_s    (awlock_stm_axim_ib_stm_axim_stm_axim_s),
  .awcache_stm_axim_s   (awcache_stm_axim_ib_stm_axim_stm_axim_s),
  .awprot_stm_axim_s    (awprot_stm_axim_ib_stm_axim_stm_axim_s),
  .awvalid_stm_axim_s   (awvalid_stm_axim_ib_stm_axim_stm_axim_s),
  .awready_stm_axim_s   (awready_stm_axim_ib_stm_axim_stm_axim_s),
  .wdata_stm_axim_s     (wdata_stm_axim_ib_stm_axim_stm_axim_s),
  .wstrb_stm_axim_s     (wstrb_stm_axim_ib_stm_axim_stm_axim_s),
  .wlast_stm_axim_s     (wlast_stm_axim_ib_stm_axim_stm_axim_s),
  .wvalid_stm_axim_s    (wvalid_stm_axim_ib_stm_axim_stm_axim_s),
  .wready_stm_axim_s    (wready_stm_axim_ib_stm_axim_stm_axim_s),
  .bid_stm_axim_s       (bid_stm_axim_ib_stm_axim_stm_axim_s),
  .bresp_stm_axim_s     (bresp_stm_axim_ib_stm_axim_stm_axim_s),
  .bvalid_stm_axim_s    (bvalid_stm_axim_ib_stm_axim_stm_axim_s),
  .bready_stm_axim_s    (bready_stm_axim_ib_stm_axim_stm_axim_s),
  .arid_stm_axim_s      (arid_stm_axim_ib_stm_axim_stm_axim_s),
  .araddr_stm_axim_s    (araddr_stm_axim_ib_stm_axim_stm_axim_s),
  .arlen_stm_axim_s     (arlen_stm_axim_ib_stm_axim_stm_axim_s),
  .arsize_stm_axim_s    (arsize_stm_axim_ib_stm_axim_stm_axim_s),
  .arburst_stm_axim_s   (arburst_stm_axim_ib_stm_axim_stm_axim_s),
  .arlock_stm_axim_s    (arlock_stm_axim_ib_stm_axim_stm_axim_s),
  .arcache_stm_axim_s   (arcache_stm_axim_ib_stm_axim_stm_axim_s),
  .arprot_stm_axim_s    (arprot_stm_axim_ib_stm_axim_stm_axim_s),
  .arvalid_stm_axim_s   (arvalid_stm_axim_ib_stm_axim_stm_axim_s),
  .arready_stm_axim_s   (arready_stm_axim_ib_stm_axim_stm_axim_s),
  .rid_stm_axim_s       (rid_stm_axim_ib_stm_axim_stm_axim_s),
  .rdata_stm_axim_s     (rdata_stm_axim_ib_stm_axim_stm_axim_s),
  .rresp_stm_axim_s     (rresp_stm_axim_ib_stm_axim_stm_axim_s),
  .rlast_stm_axim_s     (rlast_stm_axim_ib_stm_axim_stm_axim_s),
  .rvalid_stm_axim_s    (rvalid_stm_axim_ib_stm_axim_stm_axim_s),
  .rready_stm_axim_s    (rready_stm_axim_ib_stm_axim_stm_axim_s),
  .awuser_stm_axim_s    (awuser_stm_axim_ib_stm_axim_stm_axim_s),
  .aruser_stm_axim_s    (aruser_stm_axim_ib_stm_axim_stm_axim_s),
  .aclk                 (aclk),
  .aresetn              (aresetn)
);


nic400_asib_sysperi_axis_sse710_sys_apb     u_asib_sysperi_axis (
  .sysperi_axis_cactive (cactive_sysperi_axis_hcg),
  .awid_sysperi_axis_m  (awid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awaddr_sysperi_axis_m (awaddr_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awlen_sysperi_axis_m (awlen_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awsize_sysperi_axis_m (awsize_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awburst_sysperi_axis_m (awburst_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awlock_sysperi_axis_m (awlock_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awcache_sysperi_axis_m (awcache_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awprot_sysperi_axis_m (awprot_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awvalid_sysperi_axis_m (awvalid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awvalid_vect_sysperi_axis_m (awvalid_vect_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awregion_sysperi_axis_m (awregion_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awready_sysperi_axis_m (awready_sysperi_axis_sysperi_axis_ib_axi4_s),
  .wdata_sysperi_axis_m (wdata_sysperi_axis_sysperi_axis_ib_axi4_s),
  .wstrb_sysperi_axis_m (wstrb_sysperi_axis_sysperi_axis_ib_axi4_s),
  .wlast_sysperi_axis_m (wlast_sysperi_axis_sysperi_axis_ib_axi4_s),
  .wvalid_sysperi_axis_m (wvalid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .wready_sysperi_axis_m (wready_sysperi_axis_sysperi_axis_ib_axi4_s),
  .bid_sysperi_axis_m   (bid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .bresp_sysperi_axis_m (bresp_sysperi_axis_sysperi_axis_ib_axi4_s),
  .bvalid_sysperi_axis_m (bvalid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .bready_sysperi_axis_m (bready_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arid_sysperi_axis_m  (arid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .araddr_sysperi_axis_m (araddr_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arlen_sysperi_axis_m (arlen_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arsize_sysperi_axis_m (arsize_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arburst_sysperi_axis_m (arburst_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arlock_sysperi_axis_m (arlock_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arcache_sysperi_axis_m (arcache_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arprot_sysperi_axis_m (arprot_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arvalid_sysperi_axis_m (arvalid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arvalid_vect_sysperi_axis_m (arvalid_vect_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arregion_sysperi_axis_m (arregion_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arready_sysperi_axis_m (arready_sysperi_axis_sysperi_axis_ib_axi4_s),
  .rid_sysperi_axis_m   (rid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .rdata_sysperi_axis_m (rdata_sysperi_axis_sysperi_axis_ib_axi4_s),
  .rresp_sysperi_axis_m (rresp_sysperi_axis_sysperi_axis_ib_axi4_s),
  .rlast_sysperi_axis_m (rlast_sysperi_axis_sysperi_axis_ib_axi4_s),
  .rvalid_sysperi_axis_m (rvalid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .rready_sysperi_axis_m (rready_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awuser_sysperi_axis_m (awuser_sysperi_axis_sysperi_axis_ib_axi4_s),
  .aruser_sysperi_axis_m (aruser_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awqv_sysperi_axis_m  (awqv_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arqv_sysperi_axis_m  (arqv_sysperi_axis_sysperi_axis_ib_axi4_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .sysperi_axis_port_enable (port_enable_sysperi_axis_port_enable_hcg),
  .awid_sysperi_axis_s  (awid_sysperi_axis),
  .awaddr_sysperi_axis_s (awaddr_sysperi_axis),
  .awlen_sysperi_axis_s (awlen_sysperi_axis),
  .awsize_sysperi_axis_s (awsize_sysperi_axis),
  .awburst_sysperi_axis_s (awburst_sysperi_axis),
  .awlock_sysperi_axis_s (awlock_sysperi_axis),
  .awcache_sysperi_axis_s (awcache_sysperi_axis),
  .awprot_sysperi_axis_s (awprot_sysperi_axis),
  .awvalid_sysperi_axis_s (awvalid_sysperi_axis),
  .awready_sysperi_axis_s (awready_sysperi_axis),
  .wdata_sysperi_axis_s (wdata_sysperi_axis),
  .wstrb_sysperi_axis_s (wstrb_sysperi_axis),
  .wlast_sysperi_axis_s (wlast_sysperi_axis),
  .wvalid_sysperi_axis_s (wvalid_sysperi_axis),
  .wready_sysperi_axis_s (wready_sysperi_axis),
  .bid_sysperi_axis_s   (bid_sysperi_axis),
  .bresp_sysperi_axis_s (bresp_sysperi_axis),
  .bvalid_sysperi_axis_s (bvalid_sysperi_axis),
  .bready_sysperi_axis_s (bready_sysperi_axis),
  .arid_sysperi_axis_s  (arid_sysperi_axis),
  .araddr_sysperi_axis_s (araddr_sysperi_axis),
  .arlen_sysperi_axis_s (arlen_sysperi_axis),
  .arsize_sysperi_axis_s (arsize_sysperi_axis),
  .arburst_sysperi_axis_s (arburst_sysperi_axis),
  .arlock_sysperi_axis_s (arlock_sysperi_axis),
  .arcache_sysperi_axis_s (arcache_sysperi_axis),
  .arprot_sysperi_axis_s (arprot_sysperi_axis),
  .arvalid_sysperi_axis_s (arvalid_sysperi_axis),
  .arready_sysperi_axis_s (arready_sysperi_axis),
  .rid_sysperi_axis_s   (rid_sysperi_axis),
  .rdata_sysperi_axis_s (rdata_sysperi_axis),
  .rresp_sysperi_axis_s (rresp_sysperi_axis),
  .rlast_sysperi_axis_s (rlast_sysperi_axis),
  .rvalid_sysperi_axis_s (rvalid_sysperi_axis),
  .rready_sysperi_axis_s (rready_sysperi_axis),
  .awuser_sysperi_axis_s (awuser_sysperi_axis),
  .aruser_sysperi_axis_s (aruser_sysperi_axis),
  .awqv_sysperi_axis_s  (awqos_sysperi_axis),
  .arqv_sysperi_axis_s  (arqos_sysperi_axis),
  .sysperi_axis_cactive_wakeup (cactive_sysperi_axis_wakeup_hcg)
);


nic400_switch0_sse710_sys_apb     u_busmatrix_switch0 (
  .awid_axi_m_0         (awid_switch0_gic_axim_gic_axim_s),
  .awaddr_axi_m_0       (awaddr_switch0_gic_axim_gic_axim_s),
  .awlen_axi_m_0        (awlen_switch0_gic_axim_gic_axim_s),
  .awsize_axi_m_0       (awsize_switch0_gic_axim_gic_axim_s),
  .awburst_axi_m_0      (awburst_switch0_gic_axim_gic_axim_s),
  .awlock_axi_m_0       (awlock_switch0_gic_axim_gic_axim_s),
  .awcache_axi_m_0      (awcache_switch0_gic_axim_gic_axim_s),
  .awprot_axi_m_0       (awprot_switch0_gic_axim_gic_axim_s),
  .awregion_axi_m_0     (),
  .awvalid_axi_m_0      (awvalid_switch0_gic_axim_gic_axim_s),
  .awvalid_vect_axi_m_0 (),
  .awready_axi_m_0      (awready_switch0_gic_axim_gic_axim_s),
  .wdata_axi_m_0        (wdata_switch0_gic_axim_gic_axim_s),
  .wstrb_axi_m_0        (wstrb_switch0_gic_axim_gic_axim_s),
  .wlast_axi_m_0        (wlast_switch0_gic_axim_gic_axim_s),
  .wvalid_axi_m_0       (wvalid_switch0_gic_axim_gic_axim_s),
  .wready_axi_m_0       (wready_switch0_gic_axim_gic_axim_s),
  .bid_axi_m_0          (bid_switch0_gic_axim_gic_axim_s),
  .bresp_axi_m_0        (bresp_switch0_gic_axim_gic_axim_s),
  .bvalid_axi_m_0       (bvalid_switch0_gic_axim_gic_axim_s),
  .bready_axi_m_0       (bready_switch0_gic_axim_gic_axim_s),
  .arid_axi_m_0         (arid_switch0_gic_axim_gic_axim_s),
  .araddr_axi_m_0       (araddr_switch0_gic_axim_gic_axim_s),
  .arlen_axi_m_0        (arlen_switch0_gic_axim_gic_axim_s),
  .arsize_axi_m_0       (arsize_switch0_gic_axim_gic_axim_s),
  .arburst_axi_m_0      (arburst_switch0_gic_axim_gic_axim_s),
  .arlock_axi_m_0       (arlock_switch0_gic_axim_gic_axim_s),
  .arcache_axi_m_0      (arcache_switch0_gic_axim_gic_axim_s),
  .arprot_axi_m_0       (arprot_switch0_gic_axim_gic_axim_s),
  .arregion_axi_m_0     (),
  .arvalid_axi_m_0      (arvalid_switch0_gic_axim_gic_axim_s),
  .arvalid_vect_axi_m_0 (),
  .arready_axi_m_0      (arready_switch0_gic_axim_gic_axim_s),
  .rid_axi_m_0          (rid_switch0_gic_axim_gic_axim_s),
  .rdata_axi_m_0        (rdata_switch0_gic_axim_gic_axim_s),
  .rresp_axi_m_0        (rresp_switch0_gic_axim_gic_axim_s),
  .rlast_axi_m_0        (rlast_switch0_gic_axim_gic_axim_s),
  .rvalid_axi_m_0       (rvalid_switch0_gic_axim_gic_axim_s),
  .rready_axi_m_0       (rready_switch0_gic_axim_gic_axim_s),
  .awuser_axi_m_0       (awuser_switch0_gic_axim_gic_axim_s),
  .aruser_axi_m_0       (aruser_switch0_gic_axim_gic_axim_s),
  .aw_qv_axi_m_0        (awqv_switch0_gic_axim_gic_axim_s),
  .ar_qv_axi_m_0        (arqv_switch0_gic_axim_gic_axim_s),
  .awid_axi_m_1         (awid_switch0_stm_axim_ib_axi4_s),
  .awaddr_axi_m_1       (awaddr_switch0_stm_axim_ib_axi4_s),
  .awlen_axi_m_1        (awlen_switch0_stm_axim_ib_axi4_s),
  .awsize_axi_m_1       (awsize_switch0_stm_axim_ib_axi4_s),
  .awburst_axi_m_1      (awburst_switch0_stm_axim_ib_axi4_s),
  .awlock_axi_m_1       (awlock_switch0_stm_axim_ib_axi4_s),
  .awcache_axi_m_1      (awcache_switch0_stm_axim_ib_axi4_s),
  .awprot_axi_m_1       (awprot_switch0_stm_axim_ib_axi4_s),
  .awregion_axi_m_1     (awregion_switch0_stm_axim_ib_axi4_s),
  .awvalid_axi_m_1      (awvalid_switch0_stm_axim_ib_axi4_s),
  .awvalid_vect_axi_m_1 (),
  .awready_axi_m_1      (awready_switch0_stm_axim_ib_axi4_s),
  .wdata_axi_m_1        (wdata_switch0_stm_axim_ib_axi4_s),
  .wstrb_axi_m_1        (wstrb_switch0_stm_axim_ib_axi4_s),
  .wlast_axi_m_1        (wlast_switch0_stm_axim_ib_axi4_s),
  .wvalid_axi_m_1       (wvalid_switch0_stm_axim_ib_axi4_s),
  .wready_axi_m_1       (wready_switch0_stm_axim_ib_axi4_s),
  .bid_axi_m_1          (bid_switch0_stm_axim_ib_axi4_s),
  .bresp_axi_m_1        (bresp_switch0_stm_axim_ib_axi4_s),
  .bvalid_axi_m_1       (bvalid_switch0_stm_axim_ib_axi4_s),
  .bready_axi_m_1       (bready_switch0_stm_axim_ib_axi4_s),
  .arid_axi_m_1         (arid_switch0_stm_axim_ib_axi4_s),
  .araddr_axi_m_1       (araddr_switch0_stm_axim_ib_axi4_s),
  .arlen_axi_m_1        (arlen_switch0_stm_axim_ib_axi4_s),
  .arsize_axi_m_1       (arsize_switch0_stm_axim_ib_axi4_s),
  .arburst_axi_m_1      (arburst_switch0_stm_axim_ib_axi4_s),
  .arlock_axi_m_1       (arlock_switch0_stm_axim_ib_axi4_s),
  .arcache_axi_m_1      (arcache_switch0_stm_axim_ib_axi4_s),
  .arprot_axi_m_1       (arprot_switch0_stm_axim_ib_axi4_s),
  .arregion_axi_m_1     (arregion_switch0_stm_axim_ib_axi4_s),
  .arvalid_axi_m_1      (arvalid_switch0_stm_axim_ib_axi4_s),
  .arvalid_vect_axi_m_1 (),
  .arready_axi_m_1      (arready_switch0_stm_axim_ib_axi4_s),
  .rid_axi_m_1          (rid_switch0_stm_axim_ib_axi4_s),
  .rdata_axi_m_1        (rdata_switch0_stm_axim_ib_axi4_s),
  .rresp_axi_m_1        (rresp_switch0_stm_axim_ib_axi4_s),
  .rlast_axi_m_1        (rlast_switch0_stm_axim_ib_axi4_s),
  .rvalid_axi_m_1       (rvalid_switch0_stm_axim_ib_axi4_s),
  .rready_axi_m_1       (rready_switch0_stm_axim_ib_axi4_s),
  .awuser_axi_m_1       (awuser_switch0_stm_axim_ib_axi4_s),
  .aruser_axi_m_1       (aruser_switch0_stm_axim_ib_axi4_s),
  .aw_qv_axi_m_1        (),
  .ar_qv_axi_m_1        (),
  .awid_axi_m_2         (awid_switch0_slave_8_slave_8_s),
  .awaddr_axi_m_2       (awaddr_switch0_slave_8_slave_8_s),
  .awlen_axi_m_2        (awlen_switch0_slave_8_slave_8_s),
  .awsize_axi_m_2       (awsize_switch0_slave_8_slave_8_s),
  .awburst_axi_m_2      (awburst_switch0_slave_8_slave_8_s),
  .awlock_axi_m_2       (awlock_switch0_slave_8_slave_8_s),
  .awcache_axi_m_2      (awcache_switch0_slave_8_slave_8_s),
  .awprot_axi_m_2       (awprot_switch0_slave_8_slave_8_s),
  .awregion_axi_m_2     (awregion_switch0_slave_8_slave_8_s),
  .awvalid_axi_m_2      (awvalid_switch0_slave_8_slave_8_s),
  .awvalid_vect_axi_m_2 (),
  .awready_axi_m_2      (awready_switch0_slave_8_slave_8_s),
  .wdata_axi_m_2        (wdata_switch0_slave_8_slave_8_s),
  .wstrb_axi_m_2        (wstrb_switch0_slave_8_slave_8_s),
  .wlast_axi_m_2        (wlast_switch0_slave_8_slave_8_s),
  .wvalid_axi_m_2       (wvalid_switch0_slave_8_slave_8_s),
  .wready_axi_m_2       (wready_switch0_slave_8_slave_8_s),
  .bid_axi_m_2          (bid_switch0_slave_8_slave_8_s),
  .bresp_axi_m_2        (bresp_switch0_slave_8_slave_8_s),
  .bvalid_axi_m_2       (bvalid_switch0_slave_8_slave_8_s),
  .bready_axi_m_2       (bready_switch0_slave_8_slave_8_s),
  .arid_axi_m_2         (arid_switch0_slave_8_slave_8_s),
  .araddr_axi_m_2       (araddr_switch0_slave_8_slave_8_s),
  .arlen_axi_m_2        (arlen_switch0_slave_8_slave_8_s),
  .arsize_axi_m_2       (arsize_switch0_slave_8_slave_8_s),
  .arburst_axi_m_2      (arburst_switch0_slave_8_slave_8_s),
  .arlock_axi_m_2       (arlock_switch0_slave_8_slave_8_s),
  .arcache_axi_m_2      (arcache_switch0_slave_8_slave_8_s),
  .arprot_axi_m_2       (arprot_switch0_slave_8_slave_8_s),
  .arregion_axi_m_2     (arregion_switch0_slave_8_slave_8_s),
  .arvalid_axi_m_2      (arvalid_switch0_slave_8_slave_8_s),
  .arvalid_vect_axi_m_2 (),
  .arready_axi_m_2      (arready_switch0_slave_8_slave_8_s),
  .rid_axi_m_2          (rid_switch0_slave_8_slave_8_s),
  .rdata_axi_m_2        (rdata_switch0_slave_8_slave_8_s),
  .rresp_axi_m_2        (rresp_switch0_slave_8_slave_8_s),
  .rlast_axi_m_2        (rlast_switch0_slave_8_slave_8_s),
  .rvalid_axi_m_2       (rvalid_switch0_slave_8_slave_8_s),
  .rready_axi_m_2       (rready_switch0_slave_8_slave_8_s),
  .awuser_axi_m_2       (),
  .aruser_axi_m_2       (),
  .aw_qv_axi_m_2        (),
  .ar_qv_axi_m_2        (),
  .awid_axi_m_3         (awid_switch0_slave_9_ib_axi4_s),
  .awaddr_axi_m_3       (awaddr_switch0_slave_9_ib_axi4_s),
  .awlen_axi_m_3        (awlen_switch0_slave_9_ib_axi4_s),
  .awsize_axi_m_3       (awsize_switch0_slave_9_ib_axi4_s),
  .awburst_axi_m_3      (awburst_switch0_slave_9_ib_axi4_s),
  .awlock_axi_m_3       (awlock_switch0_slave_9_ib_axi4_s),
  .awcache_axi_m_3      (awcache_switch0_slave_9_ib_axi4_s),
  .awprot_axi_m_3       (awprot_switch0_slave_9_ib_axi4_s),
  .awregion_axi_m_3     (awregion_switch0_slave_9_ib_axi4_s),
  .awvalid_axi_m_3      (awvalid_switch0_slave_9_ib_axi4_s),
  .awvalid_vect_axi_m_3 (),
  .awready_axi_m_3      (awready_switch0_slave_9_ib_axi4_s),
  .wdata_axi_m_3        (wdata_switch0_slave_9_ib_axi4_s),
  .wstrb_axi_m_3        (wstrb_switch0_slave_9_ib_axi4_s),
  .wlast_axi_m_3        (wlast_switch0_slave_9_ib_axi4_s),
  .wvalid_axi_m_3       (wvalid_switch0_slave_9_ib_axi4_s),
  .wready_axi_m_3       (wready_switch0_slave_9_ib_axi4_s),
  .bid_axi_m_3          (bid_switch0_slave_9_ib_axi4_s),
  .bresp_axi_m_3        (bresp_switch0_slave_9_ib_axi4_s),
  .bvalid_axi_m_3       (bvalid_switch0_slave_9_ib_axi4_s),
  .bready_axi_m_3       (bready_switch0_slave_9_ib_axi4_s),
  .arid_axi_m_3         (arid_switch0_slave_9_ib_axi4_s),
  .araddr_axi_m_3       (araddr_switch0_slave_9_ib_axi4_s),
  .arlen_axi_m_3        (arlen_switch0_slave_9_ib_axi4_s),
  .arsize_axi_m_3       (arsize_switch0_slave_9_ib_axi4_s),
  .arburst_axi_m_3      (arburst_switch0_slave_9_ib_axi4_s),
  .arlock_axi_m_3       (arlock_switch0_slave_9_ib_axi4_s),
  .arcache_axi_m_3      (arcache_switch0_slave_9_ib_axi4_s),
  .arprot_axi_m_3       (arprot_switch0_slave_9_ib_axi4_s),
  .arregion_axi_m_3     (arregion_switch0_slave_9_ib_axi4_s),
  .arvalid_axi_m_3      (arvalid_switch0_slave_9_ib_axi4_s),
  .arvalid_vect_axi_m_3 (),
  .arready_axi_m_3      (arready_switch0_slave_9_ib_axi4_s),
  .rid_axi_m_3          (rid_switch0_slave_9_ib_axi4_s),
  .rdata_axi_m_3        (rdata_switch0_slave_9_ib_axi4_s),
  .rresp_axi_m_3        (rresp_switch0_slave_9_ib_axi4_s),
  .rlast_axi_m_3        (rlast_switch0_slave_9_ib_axi4_s),
  .rvalid_axi_m_3       (rvalid_switch0_slave_9_ib_axi4_s),
  .rready_axi_m_3       (rready_switch0_slave_9_ib_axi4_s),
  .awuser_axi_m_3       (),
  .aruser_axi_m_3       (),
  .aw_qv_axi_m_3        (),
  .ar_qv_axi_m_3        (),
  .awid_axi_m_4         (awid_switch0_ds_0_axi_s_0),
  .awaddr_axi_m_4       (),
  .awlen_axi_m_4        (),
  .awsize_axi_m_4       (),
  .awburst_axi_m_4      (),
  .awlock_axi_m_4       (),
  .awcache_axi_m_4      (),
  .awprot_axi_m_4       (),
  .awregion_axi_m_4     (),
  .awvalid_axi_m_4      (awvalid_switch0_ds_0_axi_s_0),
  .awvalid_vect_axi_m_4 (),
  .awready_axi_m_4      (awready_switch0_ds_0_axi_s_0),
  .wdata_axi_m_4        (),
  .wstrb_axi_m_4        (),
  .wlast_axi_m_4        (wlast_switch0_ds_0_axi_s_0),
  .wvalid_axi_m_4       (wvalid_switch0_ds_0_axi_s_0),
  .wready_axi_m_4       (wready_switch0_ds_0_axi_s_0),
  .bid_axi_m_4          (bid_switch0_ds_0_axi_s_0),
  .bresp_axi_m_4        (bresp_switch0_ds_0_axi_s_0),
  .bvalid_axi_m_4       (bvalid_switch0_ds_0_axi_s_0),
  .bready_axi_m_4       (bready_switch0_ds_0_axi_s_0),
  .arid_axi_m_4         (arid_switch0_ds_0_axi_s_0),
  .araddr_axi_m_4       (),
  .arlen_axi_m_4        (arlen_switch0_ds_0_axi_s_0),
  .arsize_axi_m_4       (),
  .arburst_axi_m_4      (),
  .arlock_axi_m_4       (),
  .arcache_axi_m_4      (),
  .arprot_axi_m_4       (),
  .arregion_axi_m_4     (),
  .arvalid_axi_m_4      (arvalid_switch0_ds_0_axi_s_0),
  .arvalid_vect_axi_m_4 (),
  .arready_axi_m_4      (arready_switch0_ds_0_axi_s_0),
  .rid_axi_m_4          (rid_switch0_ds_0_axi_s_0),
  .rdata_axi_m_4        (32'b0),
  .rresp_axi_m_4        (rresp_switch0_ds_0_axi_s_0),
  .rlast_axi_m_4        (rlast_switch0_ds_0_axi_s_0),
  .rvalid_axi_m_4       (rvalid_switch0_ds_0_axi_s_0),
  .rready_axi_m_4       (rready_switch0_ds_0_axi_s_0),
  .awuser_axi_m_4       (),
  .aruser_axi_m_4       (),
  .aw_qv_axi_m_4        (),
  .ar_qv_axi_m_4        (),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .awid_axi_m_5         (awid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awaddr_axi_m_5       (awaddr_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awlen_axi_m_5        (awlen_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awsize_axi_m_5       (awsize_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awburst_axi_m_5      (awburst_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awlock_axi_m_5       (awlock_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awcache_axi_m_5      (awcache_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awprot_axi_m_5       (awprot_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awregion_axi_m_5     (),
  .awvalid_axi_m_5      (awvalid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awvalid_vect_axi_m_5 (),
  .awready_axi_m_5      (awready_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .wdata_axi_m_5        (wdata_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .wstrb_axi_m_5        (wstrb_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .wlast_axi_m_5        (wlast_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .wvalid_axi_m_5       (wvalid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .wready_axi_m_5       (wready_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .bid_axi_m_5          (bid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .bresp_axi_m_5        (bresp_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .bvalid_axi_m_5       (bvalid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .bready_axi_m_5       (bready_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arid_axi_m_5         (arid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .araddr_axi_m_5       (araddr_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arlen_axi_m_5        (arlen_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arsize_axi_m_5       (arsize_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arburst_axi_m_5      (arburst_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arlock_axi_m_5       (arlock_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arcache_axi_m_5      (arcache_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arprot_axi_m_5       (arprot_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arregion_axi_m_5     (),
  .arvalid_axi_m_5      (arvalid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .arvalid_vect_axi_m_5 (),
  .arready_axi_m_5      (arready_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .rid_axi_m_5          (rid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .rdata_axi_m_5        (rdata_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .rresp_axi_m_5        (rresp_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .rlast_axi_m_5        (rlast_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .rvalid_axi_m_5       (rvalid_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .rready_axi_m_5       (rready_switch0_gpvmain_ahb_gpvmain_ahb_s),
  .awuser_axi_m_5       (),
  .aruser_axi_m_5       (),
  .aw_qv_axi_m_5        (),
  .ar_qv_axi_m_5        (),
  .awid_axi_m_6         (awid_switch0_slave_6_slave_6_s),
  .awaddr_axi_m_6       (awaddr_switch0_slave_6_slave_6_s),
  .awlen_axi_m_6        (awlen_switch0_slave_6_slave_6_s),
  .awsize_axi_m_6       (awsize_switch0_slave_6_slave_6_s),
  .awburst_axi_m_6      (awburst_switch0_slave_6_slave_6_s),
  .awlock_axi_m_6       (awlock_switch0_slave_6_slave_6_s),
  .awcache_axi_m_6      (awcache_switch0_slave_6_slave_6_s),
  .awprot_axi_m_6       (awprot_switch0_slave_6_slave_6_s),
  .awregion_axi_m_6     (awregion_switch0_slave_6_slave_6_s),
  .awvalid_axi_m_6      (awvalid_switch0_slave_6_slave_6_s),
  .awvalid_vect_axi_m_6 (),
  .awready_axi_m_6      (awready_switch0_slave_6_slave_6_s),
  .wdata_axi_m_6        (wdata_switch0_slave_6_slave_6_s),
  .wstrb_axi_m_6        (wstrb_switch0_slave_6_slave_6_s),
  .wlast_axi_m_6        (wlast_switch0_slave_6_slave_6_s),
  .wvalid_axi_m_6       (wvalid_switch0_slave_6_slave_6_s),
  .wready_axi_m_6       (wready_switch0_slave_6_slave_6_s),
  .bid_axi_m_6          (bid_switch0_slave_6_slave_6_s),
  .bresp_axi_m_6        (bresp_switch0_slave_6_slave_6_s),
  .bvalid_axi_m_6       (bvalid_switch0_slave_6_slave_6_s),
  .bready_axi_m_6       (bready_switch0_slave_6_slave_6_s),
  .arid_axi_m_6         (arid_switch0_slave_6_slave_6_s),
  .araddr_axi_m_6       (araddr_switch0_slave_6_slave_6_s),
  .arlen_axi_m_6        (arlen_switch0_slave_6_slave_6_s),
  .arsize_axi_m_6       (arsize_switch0_slave_6_slave_6_s),
  .arburst_axi_m_6      (arburst_switch0_slave_6_slave_6_s),
  .arlock_axi_m_6       (arlock_switch0_slave_6_slave_6_s),
  .arcache_axi_m_6      (arcache_switch0_slave_6_slave_6_s),
  .arprot_axi_m_6       (arprot_switch0_slave_6_slave_6_s),
  .arregion_axi_m_6     (arregion_switch0_slave_6_slave_6_s),
  .arvalid_axi_m_6      (arvalid_switch0_slave_6_slave_6_s),
  .arvalid_vect_axi_m_6 (),
  .arready_axi_m_6      (arready_switch0_slave_6_slave_6_s),
  .rid_axi_m_6          (rid_switch0_slave_6_slave_6_s),
  .rdata_axi_m_6        (rdata_switch0_slave_6_slave_6_s),
  .rresp_axi_m_6        (rresp_switch0_slave_6_slave_6_s),
  .rlast_axi_m_6        (rlast_switch0_slave_6_slave_6_s),
  .rvalid_axi_m_6       (rvalid_switch0_slave_6_slave_6_s),
  .rready_axi_m_6       (rready_switch0_slave_6_slave_6_s),
  .awuser_axi_m_6       (),
  .aruser_axi_m_6       (),
  .aw_qv_axi_m_6        (),
  .ar_qv_axi_m_6        (),
  .awid_axi_s_0         (awid_sysperi_axis_ib_switch0_axi_s_0),
  .awaddr_axi_s_0       (awaddr_sysperi_axis_ib_switch0_axi_s_0),
  .awlen_axi_s_0        (awlen_sysperi_axis_ib_switch0_axi_s_0),
  .awsize_axi_s_0       (awsize_sysperi_axis_ib_switch0_axi_s_0),
  .awburst_axi_s_0      (awburst_sysperi_axis_ib_switch0_axi_s_0),
  .awlock_axi_s_0       (awlock_sysperi_axis_ib_switch0_axi_s_0),
  .awcache_axi_s_0      (awcache_sysperi_axis_ib_switch0_axi_s_0),
  .awprot_axi_s_0       (awprot_sysperi_axis_ib_switch0_axi_s_0),
  .awregion_axi_s_0     (awregion_sysperi_axis_ib_switch0_axi_s_0),
  .awvalid_axi_s_0      (awvalid_sysperi_axis_ib_switch0_axi_s_0),
  .awvalid_vect_axi_s_0 (awvalid_vect_sysperi_axis_ib_switch0_axi_s_0),
  .awready_axi_s_0      (awready_sysperi_axis_ib_switch0_axi_s_0),
  .wdata_axi_s_0        (wdata_sysperi_axis_ib_switch0_axi_s_0),
  .wstrb_axi_s_0        (wstrb_sysperi_axis_ib_switch0_axi_s_0),
  .wlast_axi_s_0        (wlast_sysperi_axis_ib_switch0_axi_s_0),
  .wvalid_axi_s_0       (wvalid_sysperi_axis_ib_switch0_axi_s_0),
  .wready_axi_s_0       (wready_sysperi_axis_ib_switch0_axi_s_0),
  .bid_axi_s_0          (bid_sysperi_axis_ib_switch0_axi_s_0),
  .bresp_axi_s_0        (bresp_sysperi_axis_ib_switch0_axi_s_0),
  .bvalid_axi_s_0       (bvalid_sysperi_axis_ib_switch0_axi_s_0),
  .bready_axi_s_0       (bready_sysperi_axis_ib_switch0_axi_s_0),
  .arid_axi_s_0         (arid_sysperi_axis_ib_switch0_axi_s_0),
  .araddr_axi_s_0       (araddr_sysperi_axis_ib_switch0_axi_s_0),
  .arlen_axi_s_0        (arlen_sysperi_axis_ib_switch0_axi_s_0),
  .arsize_axi_s_0       (arsize_sysperi_axis_ib_switch0_axi_s_0),
  .arburst_axi_s_0      (arburst_sysperi_axis_ib_switch0_axi_s_0),
  .arlock_axi_s_0       (arlock_sysperi_axis_ib_switch0_axi_s_0),
  .arcache_axi_s_0      (arcache_sysperi_axis_ib_switch0_axi_s_0),
  .arprot_axi_s_0       (arprot_sysperi_axis_ib_switch0_axi_s_0),
  .arregion_axi_s_0     (arregion_sysperi_axis_ib_switch0_axi_s_0),
  .arvalid_axi_s_0      (arvalid_sysperi_axis_ib_switch0_axi_s_0),
  .arvalid_vect_axi_s_0 (arvalid_vect_sysperi_axis_ib_switch0_axi_s_0),
  .arready_axi_s_0      (arready_sysperi_axis_ib_switch0_axi_s_0),
  .rid_axi_s_0          (rid_sysperi_axis_ib_switch0_axi_s_0),
  .rdata_axi_s_0        (rdata_sysperi_axis_ib_switch0_axi_s_0),
  .rresp_axi_s_0        (rresp_sysperi_axis_ib_switch0_axi_s_0),
  .rlast_axi_s_0        (rlast_sysperi_axis_ib_switch0_axi_s_0),
  .rvalid_axi_s_0       (rvalid_sysperi_axis_ib_switch0_axi_s_0),
  .rready_axi_s_0       (rready_sysperi_axis_ib_switch0_axi_s_0),
  .awuser_axi_s_0       (awuser_sysperi_axis_ib_switch0_axi_s_0),
  .aruser_axi_s_0       (aruser_sysperi_axis_ib_switch0_axi_s_0),
  .aw_qv_axi_s_0        (awqv_sysperi_axis_ib_switch0_axi_s_0),
  .ar_qv_axi_s_0        (arqv_sysperi_axis_ib_switch0_axi_s_0)
);


nic400_default_slave_ds_0_sse710_sys_apb     u_default_slave_ds_0 (
  .awid                 (awid_switch0_ds_0_axi_s_0),
  .awvalid              (awvalid_switch0_ds_0_axi_s_0),
  .awready              (awready_switch0_ds_0_axi_s_0),
  .wlast                (wlast_switch0_ds_0_axi_s_0),
  .wvalid               (wvalid_switch0_ds_0_axi_s_0),
  .wready               (wready_switch0_ds_0_axi_s_0),
  .bid                  (bid_switch0_ds_0_axi_s_0),
  .bresp                (bresp_switch0_ds_0_axi_s_0),
  .bvalid               (bvalid_switch0_ds_0_axi_s_0),
  .bready               (bready_switch0_ds_0_axi_s_0),
  .arid                 (arid_switch0_ds_0_axi_s_0),
  .arlen                (arlen_switch0_ds_0_axi_s_0),
  .arvalid              (arvalid_switch0_ds_0_axi_s_0),
  .arready              (arready_switch0_ds_0_axi_s_0),
  .rid                  (rid_switch0_ds_0_axi_s_0),
  .rresp                (rresp_switch0_ds_0_axi_s_0),
  .rlast                (rlast_switch0_ds_0_axi_s_0),
  .rvalid               (rvalid_switch0_ds_0_axi_s_0),
  .rready               (rready_switch0_ds_0_axi_s_0),
  .aclk                 (aclk),
  .aresetn              (aresetn)
);


nic400_dmu_a_sse710_sys_apb     u_dmu_a_sse710_sys_apb (
  .cd_a_clk             (aclk),
  .cd_a_resetn          (aresetn),
  .cd_a_cactive         (cactive_cd_a),
  .cd_a_csysreq         (csysreq_cd_a),
  .cd_a_csysack         (csysack_cd_a),
  .sysperi_axis_cactive (cactive_sysperi_axis_hcg),
  .sysperi_axis_port_enable (port_enable_sysperi_axis_port_enable_hcg),
  .sysperi_axis_cactive_wakeup (cactive_sysperi_axis_wakeup_hcg)
);


nic400_ib_slave_9_ib_slave_domain_sse710_sys_apb     u_ib_slave_9_ib_s (
  .awid_axi4_s          (awid_switch0_slave_9_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_switch0_slave_9_ib_axi4_s),
  .awlen_axi4_s         (awlen_switch0_slave_9_ib_axi4_s),
  .awsize_axi4_s        (awsize_switch0_slave_9_ib_axi4_s),
  .awburst_axi4_s       (awburst_switch0_slave_9_ib_axi4_s),
  .awlock_axi4_s        (awlock_switch0_slave_9_ib_axi4_s),
  .awcache_axi4_s       (awcache_switch0_slave_9_ib_axi4_s),
  .awprot_axi4_s        (awprot_switch0_slave_9_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_switch0_slave_9_ib_axi4_s),
  .awregion_axi4_s      (awregion_switch0_slave_9_ib_axi4_s),
  .awready_axi4_s       (awready_switch0_slave_9_ib_axi4_s),
  .wdata_axi4_s         (wdata_switch0_slave_9_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_switch0_slave_9_ib_axi4_s),
  .wlast_axi4_s         (wlast_switch0_slave_9_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_switch0_slave_9_ib_axi4_s),
  .wready_axi4_s        (wready_switch0_slave_9_ib_axi4_s),
  .bid_axi4_s           (bid_switch0_slave_9_ib_axi4_s),
  .bresp_axi4_s         (bresp_switch0_slave_9_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_switch0_slave_9_ib_axi4_s),
  .bready_axi4_s        (bready_switch0_slave_9_ib_axi4_s),
  .arid_axi4_s          (arid_switch0_slave_9_ib_axi4_s),
  .araddr_axi4_s        (araddr_switch0_slave_9_ib_axi4_s),
  .arlen_axi4_s         (arlen_switch0_slave_9_ib_axi4_s),
  .arsize_axi4_s        (arsize_switch0_slave_9_ib_axi4_s),
  .arburst_axi4_s       (arburst_switch0_slave_9_ib_axi4_s),
  .arlock_axi4_s        (arlock_switch0_slave_9_ib_axi4_s),
  .arcache_axi4_s       (arcache_switch0_slave_9_ib_axi4_s),
  .arprot_axi4_s        (arprot_switch0_slave_9_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_switch0_slave_9_ib_axi4_s),
  .arregion_axi4_s      (arregion_switch0_slave_9_ib_axi4_s),
  .arready_axi4_s       (arready_switch0_slave_9_ib_axi4_s),
  .rid_axi4_s           (rid_switch0_slave_9_ib_axi4_s),
  .rdata_axi4_s         (rdata_switch0_slave_9_ib_axi4_s),
  .rresp_axi4_s         (rresp_switch0_slave_9_ib_axi4_s),
  .rlast_axi4_s         (rlast_switch0_slave_9_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_switch0_slave_9_ib_axi4_s),
  .rready_axi4_s        (rready_switch0_slave_9_ib_axi4_s),
  .aclk_s               (aclk),
  .aresetn_s            (aresetn),
  .a_data_async         (a_data_slave_9_ib_int_async),
  .a_rpntr_gry_async    (a_rpntr_gry_slave_9_ib_int_async),
  .a_rpntr_bin          (a_rpntr_bin_slave_9_ib_int_async),
  .a_wpntr_gry_async    (a_wpntr_gry_slave_9_ib_int_async),
  .d_data_async         (d_data_slave_9_ib_int_async),
  .d_rpntr_gry_async    (d_rpntr_gry_slave_9_ib_int_async),
  .d_rpntr_bin          (d_rpntr_bin_slave_9_ib_int_async),
  .d_wpntr_gry_async    (d_wpntr_gry_slave_9_ib_int_async),
  .w_data_async         (w_data_slave_9_ib_int_async),
  .w_rpntr_gry_async    (w_rpntr_gry_slave_9_ib_int_async),
  .w_rpntr_bin          (w_rpntr_bin_slave_9_ib_int_async),
  .w_wpntr_gry_async    (w_wpntr_gry_slave_9_ib_int_async),
  .empty_async          (empty_slave_9_ib_int_async)
);


nic400_ib_stm_axim_ib_master_domain_sse710_sys_apb     u_ib_stm_axim_ib_m (
  .awid_axi4_m          (awid_stm_axim_ib_stm_axim_stm_axim_s),
  .awaddr_axi4_m        (awaddr_stm_axim_ib_stm_axim_stm_axim_s),
  .awlen_axi4_m         (awlen_stm_axim_ib_stm_axim_stm_axim_s),
  .awsize_axi4_m        (awsize_stm_axim_ib_stm_axim_stm_axim_s),
  .awburst_axi4_m       (awburst_stm_axim_ib_stm_axim_stm_axim_s),
  .awlock_axi4_m        (awlock_stm_axim_ib_stm_axim_stm_axim_s),
  .awcache_axi4_m       (awcache_stm_axim_ib_stm_axim_stm_axim_s),
  .awprot_axi4_m        (awprot_stm_axim_ib_stm_axim_stm_axim_s),
  .awvalid_axi4_m       (awvalid_stm_axim_ib_stm_axim_stm_axim_s),
  .awregion_axi4_m      (),
  .awready_axi4_m       (awready_stm_axim_ib_stm_axim_stm_axim_s),
  .wdata_axi4_m         (wdata_stm_axim_ib_stm_axim_stm_axim_s),
  .wstrb_axi4_m         (wstrb_stm_axim_ib_stm_axim_stm_axim_s),
  .wlast_axi4_m         (wlast_stm_axim_ib_stm_axim_stm_axim_s),
  .wvalid_axi4_m        (wvalid_stm_axim_ib_stm_axim_stm_axim_s),
  .wready_axi4_m        (wready_stm_axim_ib_stm_axim_stm_axim_s),
  .bid_axi4_m           (bid_stm_axim_ib_stm_axim_stm_axim_s),
  .bresp_axi4_m         (bresp_stm_axim_ib_stm_axim_stm_axim_s),
  .bvalid_axi4_m        (bvalid_stm_axim_ib_stm_axim_stm_axim_s),
  .bready_axi4_m        (bready_stm_axim_ib_stm_axim_stm_axim_s),
  .arid_axi4_m          (arid_stm_axim_ib_stm_axim_stm_axim_s),
  .araddr_axi4_m        (araddr_stm_axim_ib_stm_axim_stm_axim_s),
  .arlen_axi4_m         (arlen_stm_axim_ib_stm_axim_stm_axim_s),
  .arsize_axi4_m        (arsize_stm_axim_ib_stm_axim_stm_axim_s),
  .arburst_axi4_m       (arburst_stm_axim_ib_stm_axim_stm_axim_s),
  .arlock_axi4_m        (arlock_stm_axim_ib_stm_axim_stm_axim_s),
  .arcache_axi4_m       (arcache_stm_axim_ib_stm_axim_stm_axim_s),
  .arprot_axi4_m        (arprot_stm_axim_ib_stm_axim_stm_axim_s),
  .arvalid_axi4_m       (arvalid_stm_axim_ib_stm_axim_stm_axim_s),
  .arregion_axi4_m      (),
  .arready_axi4_m       (arready_stm_axim_ib_stm_axim_stm_axim_s),
  .rid_axi4_m           (rid_stm_axim_ib_stm_axim_stm_axim_s),
  .rdata_axi4_m         (rdata_stm_axim_ib_stm_axim_stm_axim_s),
  .rresp_axi4_m         (rresp_stm_axim_ib_stm_axim_stm_axim_s),
  .rlast_axi4_m         (rlast_stm_axim_ib_stm_axim_stm_axim_s),
  .rvalid_axi4_m        (rvalid_stm_axim_ib_stm_axim_stm_axim_s),
  .rready_axi4_m        (rready_stm_axim_ib_stm_axim_stm_axim_s),
  .awuser_axi4_m        (awuser_stm_axim_ib_stm_axim_stm_axim_s),
  .aruser_axi4_m        (aruser_stm_axim_ib_stm_axim_stm_axim_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_stm_axim_ib_int),
  .aw_valid             (aw_valid_stm_axim_ib_int),
  .aw_ready             (aw_ready_stm_axim_ib_int),
  .b_data               (b_data_stm_axim_ib_int),
  .b_valid              (b_valid_stm_axim_ib_int),
  .b_ready              (b_ready_stm_axim_ib_int),
  .ar_data              (ar_data_stm_axim_ib_int),
  .ar_valid             (ar_valid_stm_axim_ib_int),
  .ar_ready             (ar_ready_stm_axim_ib_int),
  .r_data               (r_data_stm_axim_ib_int),
  .r_valid              (r_valid_stm_axim_ib_int),
  .r_ready              (r_ready_stm_axim_ib_int),
  .w_data               (w_data_stm_axim_ib_int),
  .w_valid              (w_valid_stm_axim_ib_int),
  .w_ready              (w_ready_stm_axim_ib_int)
);


nic400_ib_stm_axim_ib_slave_domain_sse710_sys_apb     u_ib_stm_axim_ib_s (
  .awid_axi4_s          (awid_switch0_stm_axim_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_switch0_stm_axim_ib_axi4_s),
  .awlen_axi4_s         (awlen_switch0_stm_axim_ib_axi4_s),
  .awsize_axi4_s        (awsize_switch0_stm_axim_ib_axi4_s),
  .awburst_axi4_s       (awburst_switch0_stm_axim_ib_axi4_s),
  .awlock_axi4_s        (awlock_switch0_stm_axim_ib_axi4_s),
  .awcache_axi4_s       (awcache_switch0_stm_axim_ib_axi4_s),
  .awprot_axi4_s        (awprot_switch0_stm_axim_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_switch0_stm_axim_ib_axi4_s),
  .awregion_axi4_s      (awregion_switch0_stm_axim_ib_axi4_s),
  .awready_axi4_s       (awready_switch0_stm_axim_ib_axi4_s),
  .wdata_axi4_s         (wdata_switch0_stm_axim_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_switch0_stm_axim_ib_axi4_s),
  .wlast_axi4_s         (wlast_switch0_stm_axim_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_switch0_stm_axim_ib_axi4_s),
  .wready_axi4_s        (wready_switch0_stm_axim_ib_axi4_s),
  .bid_axi4_s           (bid_switch0_stm_axim_ib_axi4_s),
  .bresp_axi4_s         (bresp_switch0_stm_axim_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_switch0_stm_axim_ib_axi4_s),
  .bready_axi4_s        (bready_switch0_stm_axim_ib_axi4_s),
  .arid_axi4_s          (arid_switch0_stm_axim_ib_axi4_s),
  .araddr_axi4_s        (araddr_switch0_stm_axim_ib_axi4_s),
  .arlen_axi4_s         (arlen_switch0_stm_axim_ib_axi4_s),
  .arsize_axi4_s        (arsize_switch0_stm_axim_ib_axi4_s),
  .arburst_axi4_s       (arburst_switch0_stm_axim_ib_axi4_s),
  .arlock_axi4_s        (arlock_switch0_stm_axim_ib_axi4_s),
  .arcache_axi4_s       (arcache_switch0_stm_axim_ib_axi4_s),
  .arprot_axi4_s        (arprot_switch0_stm_axim_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_switch0_stm_axim_ib_axi4_s),
  .arregion_axi4_s      (arregion_switch0_stm_axim_ib_axi4_s),
  .arready_axi4_s       (arready_switch0_stm_axim_ib_axi4_s),
  .rid_axi4_s           (rid_switch0_stm_axim_ib_axi4_s),
  .rdata_axi4_s         (rdata_switch0_stm_axim_ib_axi4_s),
  .rresp_axi4_s         (rresp_switch0_stm_axim_ib_axi4_s),
  .rlast_axi4_s         (rlast_switch0_stm_axim_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_switch0_stm_axim_ib_axi4_s),
  .rready_axi4_s        (rready_switch0_stm_axim_ib_axi4_s),
  .awuser_axi4_s        (awuser_switch0_stm_axim_ib_axi4_s),
  .aruser_axi4_s        (aruser_switch0_stm_axim_ib_axi4_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_stm_axim_ib_int),
  .aw_valid             (aw_valid_stm_axim_ib_int),
  .aw_ready             (aw_ready_stm_axim_ib_int),
  .b_data               (b_data_stm_axim_ib_int),
  .b_valid              (b_valid_stm_axim_ib_int),
  .b_ready              (b_ready_stm_axim_ib_int),
  .ar_data              (ar_data_stm_axim_ib_int),
  .ar_valid             (ar_valid_stm_axim_ib_int),
  .ar_ready             (ar_ready_stm_axim_ib_int),
  .r_data               (r_data_stm_axim_ib_int),
  .r_valid              (r_valid_stm_axim_ib_int),
  .r_ready              (r_ready_stm_axim_ib_int),
  .w_data               (w_data_stm_axim_ib_int),
  .w_valid              (w_valid_stm_axim_ib_int),
  .w_ready              (w_ready_stm_axim_ib_int)
);


nic400_ib_sysperi_axis_ib_master_domain_sse710_sys_apb     u_ib_sysperi_axis_ib_m (
  .awid_axi4_m          (awid_sysperi_axis_ib_switch0_axi_s_0),
  .awaddr_axi4_m        (awaddr_sysperi_axis_ib_switch0_axi_s_0),
  .awlen_axi4_m         (awlen_sysperi_axis_ib_switch0_axi_s_0),
  .awsize_axi4_m        (awsize_sysperi_axis_ib_switch0_axi_s_0),
  .awburst_axi4_m       (awburst_sysperi_axis_ib_switch0_axi_s_0),
  .awlock_axi4_m        (awlock_sysperi_axis_ib_switch0_axi_s_0),
  .awcache_axi4_m       (awcache_sysperi_axis_ib_switch0_axi_s_0),
  .awprot_axi4_m        (awprot_sysperi_axis_ib_switch0_axi_s_0),
  .awvalid_axi4_m       (awvalid_sysperi_axis_ib_switch0_axi_s_0),
  .awvalid_vect_axi4_m  (awvalid_vect_sysperi_axis_ib_switch0_axi_s_0),
  .awregion_axi4_m      (awregion_sysperi_axis_ib_switch0_axi_s_0),
  .awready_axi4_m       (awready_sysperi_axis_ib_switch0_axi_s_0),
  .wdata_axi4_m         (wdata_sysperi_axis_ib_switch0_axi_s_0),
  .wstrb_axi4_m         (wstrb_sysperi_axis_ib_switch0_axi_s_0),
  .wlast_axi4_m         (wlast_sysperi_axis_ib_switch0_axi_s_0),
  .wvalid_axi4_m        (wvalid_sysperi_axis_ib_switch0_axi_s_0),
  .wready_axi4_m        (wready_sysperi_axis_ib_switch0_axi_s_0),
  .bid_axi4_m           (bid_sysperi_axis_ib_switch0_axi_s_0),
  .bresp_axi4_m         (bresp_sysperi_axis_ib_switch0_axi_s_0),
  .bvalid_axi4_m        (bvalid_sysperi_axis_ib_switch0_axi_s_0),
  .bready_axi4_m        (bready_sysperi_axis_ib_switch0_axi_s_0),
  .arid_axi4_m          (arid_sysperi_axis_ib_switch0_axi_s_0),
  .araddr_axi4_m        (araddr_sysperi_axis_ib_switch0_axi_s_0),
  .arlen_axi4_m         (arlen_sysperi_axis_ib_switch0_axi_s_0),
  .arsize_axi4_m        (arsize_sysperi_axis_ib_switch0_axi_s_0),
  .arburst_axi4_m       (arburst_sysperi_axis_ib_switch0_axi_s_0),
  .arlock_axi4_m        (arlock_sysperi_axis_ib_switch0_axi_s_0),
  .arcache_axi4_m       (arcache_sysperi_axis_ib_switch0_axi_s_0),
  .arprot_axi4_m        (arprot_sysperi_axis_ib_switch0_axi_s_0),
  .arvalid_axi4_m       (arvalid_sysperi_axis_ib_switch0_axi_s_0),
  .arvalid_vect_axi4_m  (arvalid_vect_sysperi_axis_ib_switch0_axi_s_0),
  .arregion_axi4_m      (arregion_sysperi_axis_ib_switch0_axi_s_0),
  .arready_axi4_m       (arready_sysperi_axis_ib_switch0_axi_s_0),
  .rid_axi4_m           (rid_sysperi_axis_ib_switch0_axi_s_0),
  .rdata_axi4_m         (rdata_sysperi_axis_ib_switch0_axi_s_0),
  .rresp_axi4_m         (rresp_sysperi_axis_ib_switch0_axi_s_0),
  .rlast_axi4_m         (rlast_sysperi_axis_ib_switch0_axi_s_0),
  .rvalid_axi4_m        (rvalid_sysperi_axis_ib_switch0_axi_s_0),
  .rready_axi4_m        (rready_sysperi_axis_ib_switch0_axi_s_0),
  .awuser_axi4_m        (awuser_sysperi_axis_ib_switch0_axi_s_0),
  .aruser_axi4_m        (aruser_sysperi_axis_ib_switch0_axi_s_0),
  .awqv_axi4_m          (awqv_sysperi_axis_ib_switch0_axi_s_0),
  .arqv_axi4_m          (arqv_sysperi_axis_ib_switch0_axi_s_0),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_sysperi_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_sysperi_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_sysperi_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_sysperi_axis_ib_int),
  .b_data               (b_data_sysperi_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_sysperi_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_sysperi_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_sysperi_axis_ib_int),
  .ar_data              (ar_data_sysperi_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_sysperi_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_sysperi_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_sysperi_axis_ib_int),
  .r_data               (r_data_sysperi_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_sysperi_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_sysperi_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_sysperi_axis_ib_int),
  .w_data               (w_data_sysperi_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_sysperi_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_sysperi_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_sysperi_axis_ib_int)
);


nic400_ib_sysperi_axis_ib_slave_domain_sse710_sys_apb     u_ib_sysperi_axis_ib_s (
  .awid_axi4_s          (awid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awlen_axi4_s         (awlen_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awsize_axi4_s        (awsize_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awburst_axi4_s       (awburst_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awlock_axi4_s        (awlock_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awcache_axi4_s       (awcache_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awprot_axi4_s        (awprot_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awvalid_vect_axi4_s  (awvalid_vect_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awregion_axi4_s      (awregion_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awready_axi4_s       (awready_sysperi_axis_sysperi_axis_ib_axi4_s),
  .wdata_axi4_s         (wdata_sysperi_axis_sysperi_axis_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_sysperi_axis_sysperi_axis_ib_axi4_s),
  .wlast_axi4_s         (wlast_sysperi_axis_sysperi_axis_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .wready_axi4_s        (wready_sysperi_axis_sysperi_axis_ib_axi4_s),
  .bid_axi4_s           (bid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .bresp_axi4_s         (bresp_sysperi_axis_sysperi_axis_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .bready_axi4_s        (bready_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arid_axi4_s          (arid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .araddr_axi4_s        (araddr_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arlen_axi4_s         (arlen_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arsize_axi4_s        (arsize_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arburst_axi4_s       (arburst_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arlock_axi4_s        (arlock_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arcache_axi4_s       (arcache_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arprot_axi4_s        (arprot_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arvalid_vect_axi4_s  (arvalid_vect_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arregion_axi4_s      (arregion_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arready_axi4_s       (arready_sysperi_axis_sysperi_axis_ib_axi4_s),
  .rid_axi4_s           (rid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .rdata_axi4_s         (rdata_sysperi_axis_sysperi_axis_ib_axi4_s),
  .rresp_axi4_s         (rresp_sysperi_axis_sysperi_axis_ib_axi4_s),
  .rlast_axi4_s         (rlast_sysperi_axis_sysperi_axis_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_sysperi_axis_sysperi_axis_ib_axi4_s),
  .rready_axi4_s        (rready_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awuser_axi4_s        (awuser_sysperi_axis_sysperi_axis_ib_axi4_s),
  .aruser_axi4_s        (aruser_sysperi_axis_sysperi_axis_ib_axi4_s),
  .awqv_axi4_s          (awqv_sysperi_axis_sysperi_axis_ib_axi4_s),
  .arqv_axi4_s          (arqv_sysperi_axis_sysperi_axis_ib_axi4_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_sysperi_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_sysperi_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_sysperi_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_sysperi_axis_ib_int),
  .b_data               (b_data_sysperi_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_sysperi_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_sysperi_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_sysperi_axis_ib_int),
  .ar_data              (ar_data_sysperi_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_sysperi_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_sysperi_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_sysperi_axis_ib_int),
  .r_data               (r_data_sysperi_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_sysperi_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_sysperi_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_sysperi_axis_ib_int),
  .w_data               (w_data_sysperi_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_sysperi_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_sysperi_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_sysperi_axis_ib_int)
);



endmodule
