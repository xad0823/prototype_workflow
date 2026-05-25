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




module nic400_sse710_dbgaxi2apb (
  

  paddr_extdbg_apb,
  pwdata_extdbg_apb,
  pwrite_extdbg_apb,
  pprot_extdbg_apb,
  pstrb_extdbg_apb,
  penable_extdbg_apb,
  pselx_extdbg_apb,
  prdata_extdbg_apb,
  pslverr_extdbg_apb,
  pready_extdbg_apb,
  

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
  

  cactive_cd_a,
  csysreq_cd_a,
  csysack_cd_a,


  aclk,
  aclken,
  aresetn

);






output [31:0] paddr_extdbg_apb;
output [31:0] pwdata_extdbg_apb;
output        pwrite_extdbg_apb;
output [2:0]  pprot_extdbg_apb;
output [3:0]  pstrb_extdbg_apb;
output        penable_extdbg_apb;
output        pselx_extdbg_apb;
input  [31:0] prdata_extdbg_apb;
input         pslverr_extdbg_apb;
input         pready_extdbg_apb;


input  [8:0]  awid_debug_axis;
input  [31:0] awaddr_debug_axis;
input  [7:0]  awlen_debug_axis;
input  [2:0]  awsize_debug_axis;
input  [1:0]  awburst_debug_axis;
input         awlock_debug_axis;
input  [3:0]  awcache_debug_axis;
input  [2:0]  awprot_debug_axis;
input         awvalid_debug_axis;
output        awready_debug_axis;
input  [31:0] wdata_debug_axis;
input  [3:0]  wstrb_debug_axis;
input         wlast_debug_axis;
input         wvalid_debug_axis;
output        wready_debug_axis;
output [8:0]  bid_debug_axis;
output [1:0]  bresp_debug_axis;
output        bvalid_debug_axis;
input         bready_debug_axis;
input  [8:0]  arid_debug_axis;
input  [31:0] araddr_debug_axis;
input  [7:0]  arlen_debug_axis;
input  [2:0]  arsize_debug_axis;
input  [1:0]  arburst_debug_axis;
input         arlock_debug_axis;
input  [3:0]  arcache_debug_axis;
input  [2:0]  arprot_debug_axis;
input         arvalid_debug_axis;
output        arready_debug_axis;
output [8:0]  rid_debug_axis;
output [31:0] rdata_debug_axis;
output [1:0]  rresp_debug_axis;
output        rlast_debug_axis;
output        rvalid_debug_axis;
input         rready_debug_axis;


output        cactive_cd_a;
input         csysreq_cd_a;
output        csysack_cd_a;


input         aclk;
input         aclken;
input         aresetn;




wire           arready_debug_axis;
wire           awready_debug_axis;
wire   [8:0]   bid_debug_axis;
wire   [1:0]   bresp_debug_axis;
wire           bvalid_debug_axis;
wire           cactive_cd_a;
wire           csysack_cd_a;
wire   [31:0]  paddr_extdbg_apb;
wire           penable_extdbg_apb;
wire   [2:0]   pprot_extdbg_apb;
wire           pselx_extdbg_apb;
wire   [3:0]   pstrb_extdbg_apb;
wire   [31:0]  pwdata_extdbg_apb;
wire           pwrite_extdbg_apb;
wire   [31:0]  rdata_debug_axis;
wire   [8:0]   rid_debug_axis;
wire           rlast_debug_axis;
wire   [1:0]   rresp_debug_axis;
wire           rvalid_debug_axis;
wire           wready_debug_axis;
wire           arready_switch1_slave_2_slave_2_s;
wire           awready_switch1_slave_2_slave_2_s;
wire   [8:0]   bid_switch1_slave_2_slave_2_s;
wire   [1:0]   bresp_switch1_slave_2_slave_2_s;
wire           bvalid_switch1_slave_2_slave_2_s;
wire   [31:0]  rdata_switch1_slave_2_slave_2_s;
wire   [8:0]   rid_switch1_slave_2_slave_2_s;
wire           rlast_switch1_slave_2_slave_2_s;
wire   [1:0]   rresp_switch1_slave_2_slave_2_s;
wire           rvalid_switch1_slave_2_slave_2_s;
wire           wready_switch1_slave_2_slave_2_s;
wire   [31:0]  araddr_debug_axis_debug_axis_ib_axi4_s;
wire   [1:0]   arburst_debug_axis_debug_axis_ib_axi4_s;
wire   [3:0]   arcache_debug_axis_debug_axis_ib_axi4_s;
wire   [8:0]   arid_debug_axis_debug_axis_ib_axi4_s;
wire   [7:0]   arlen_debug_axis_debug_axis_ib_axi4_s;
wire           arlock_debug_axis_debug_axis_ib_axi4_s;
wire   [2:0]   arprot_debug_axis_debug_axis_ib_axi4_s;
wire   [2:0]   arsize_debug_axis_debug_axis_ib_axi4_s;
wire           arvalid_debug_axis_debug_axis_ib_axi4_s;
wire   [1:0]   arvalid_vect_debug_axis_debug_axis_ib_axi4_s;
wire   [31:0]  awaddr_debug_axis_debug_axis_ib_axi4_s;
wire   [1:0]   awburst_debug_axis_debug_axis_ib_axi4_s;
wire   [3:0]   awcache_debug_axis_debug_axis_ib_axi4_s;
wire   [8:0]   awid_debug_axis_debug_axis_ib_axi4_s;
wire   [7:0]   awlen_debug_axis_debug_axis_ib_axi4_s;
wire           awlock_debug_axis_debug_axis_ib_axi4_s;
wire   [2:0]   awprot_debug_axis_debug_axis_ib_axi4_s;
wire   [2:0]   awsize_debug_axis_debug_axis_ib_axi4_s;
wire           awvalid_debug_axis_debug_axis_ib_axi4_s;
wire   [1:0]   awvalid_vect_debug_axis_debug_axis_ib_axi4_s;
wire           bready_debug_axis_debug_axis_ib_axi4_s;
wire           cactive_debug_axis_hcg;
wire           cactive_debug_axis_wakeup_hcg;
wire           rready_debug_axis_debug_axis_ib_axi4_s;
wire   [31:0]  wdata_debug_axis_debug_axis_ib_axi4_s;
wire           wlast_debug_axis_debug_axis_ib_axi4_s;
wire   [3:0]   wstrb_debug_axis_debug_axis_ib_axi4_s;
wire           wvalid_debug_axis_debug_axis_ib_axi4_s;
wire   [31:0]  araddr_switch1_slave_2_slave_2_s;
wire   [1:0]   arburst_switch1_slave_2_slave_2_s;
wire   [3:0]   arcache_switch1_slave_2_slave_2_s;
wire   [8:0]   arid_switch1_slave_2_slave_2_s;
wire   [8:0]   arid_switch1_ds_1_axi_s_0;
wire   [7:0]   arlen_switch1_slave_2_slave_2_s;
wire   [7:0]   arlen_switch1_ds_1_axi_s_0;
wire           arlock_switch1_slave_2_slave_2_s;
wire   [2:0]   arprot_switch1_slave_2_slave_2_s;
wire           arready_debug_axis_ib_switch1_axi_s_0;
wire   [2:0]   arsize_switch1_slave_2_slave_2_s;
wire           arvalid_switch1_slave_2_slave_2_s;
wire           arvalid_switch1_ds_1_axi_s_0;
wire   [31:0]  awaddr_switch1_slave_2_slave_2_s;
wire   [1:0]   awburst_switch1_slave_2_slave_2_s;
wire   [3:0]   awcache_switch1_slave_2_slave_2_s;
wire   [8:0]   awid_switch1_slave_2_slave_2_s;
wire   [8:0]   awid_switch1_ds_1_axi_s_0;
wire   [7:0]   awlen_switch1_slave_2_slave_2_s;
wire           awlock_switch1_slave_2_slave_2_s;
wire   [2:0]   awprot_switch1_slave_2_slave_2_s;
wire           awready_debug_axis_ib_switch1_axi_s_0;
wire   [2:0]   awsize_switch1_slave_2_slave_2_s;
wire           awvalid_switch1_slave_2_slave_2_s;
wire           awvalid_switch1_ds_1_axi_s_0;
wire   [8:0]   bid_debug_axis_ib_switch1_axi_s_0;
wire           bready_switch1_slave_2_slave_2_s;
wire           bready_switch1_ds_1_axi_s_0;
wire   [1:0]   bresp_debug_axis_ib_switch1_axi_s_0;
wire           bvalid_debug_axis_ib_switch1_axi_s_0;
wire   [31:0]  rdata_debug_axis_ib_switch1_axi_s_0;
wire   [8:0]   rid_debug_axis_ib_switch1_axi_s_0;
wire           rlast_debug_axis_ib_switch1_axi_s_0;
wire           rready_switch1_slave_2_slave_2_s;
wire           rready_switch1_ds_1_axi_s_0;
wire   [1:0]   rresp_debug_axis_ib_switch1_axi_s_0;
wire           rvalid_debug_axis_ib_switch1_axi_s_0;
wire   [31:0]  wdata_switch1_slave_2_slave_2_s;
wire           wlast_switch1_slave_2_slave_2_s;
wire           wlast_switch1_ds_1_axi_s_0;
wire           wready_debug_axis_ib_switch1_axi_s_0;
wire   [3:0]   wstrb_switch1_slave_2_slave_2_s;
wire           wvalid_switch1_slave_2_slave_2_s;
wire           wvalid_switch1_ds_1_axi_s_0;
wire           arready_switch1_ds_1_axi_s_0;
wire           awready_switch1_ds_1_axi_s_0;
wire   [8:0]   bid_switch1_ds_1_axi_s_0;
wire   [1:0]   bresp_switch1_ds_1_axi_s_0;
wire           bvalid_switch1_ds_1_axi_s_0;
wire   [8:0]   rid_switch1_ds_1_axi_s_0;
wire           rlast_switch1_ds_1_axi_s_0;
wire   [1:0]   rresp_switch1_ds_1_axi_s_0;
wire           rvalid_switch1_ds_1_axi_s_0;
wire           wready_switch1_ds_1_axi_s_0;
wire           port_enable_debug_axis_port_enable_hcg;
wire   [1:0]   ar_rpntr_bin_debug_axis_ib_int;
wire   [2:0]   ar_rpntr_gry_debug_axis_ib_int;
wire   [31:0]  araddr_debug_axis_ib_switch1_axi_s_0;
wire   [1:0]   arburst_debug_axis_ib_switch1_axi_s_0;
wire   [3:0]   arcache_debug_axis_ib_switch1_axi_s_0;
wire   [8:0]   arid_debug_axis_ib_switch1_axi_s_0;
wire   [7:0]   arlen_debug_axis_ib_switch1_axi_s_0;
wire           arlock_debug_axis_ib_switch1_axi_s_0;
wire   [2:0]   arprot_debug_axis_ib_switch1_axi_s_0;
wire   [3:0]   arqv_debug_axis_ib_switch1_axi_s_0;
wire   [2:0]   arsize_debug_axis_ib_switch1_axi_s_0;
wire           arvalid_debug_axis_ib_switch1_axi_s_0;
wire   [1:0]   arvalid_vect_debug_axis_ib_switch1_axi_s_0;
wire   [2:0]   aw_rpntr_bin_debug_axis_ib_int;
wire   [3:0]   aw_rpntr_gry_debug_axis_ib_int;
wire   [31:0]  awaddr_debug_axis_ib_switch1_axi_s_0;
wire   [1:0]   awburst_debug_axis_ib_switch1_axi_s_0;
wire   [3:0]   awcache_debug_axis_ib_switch1_axi_s_0;
wire   [8:0]   awid_debug_axis_ib_switch1_axi_s_0;
wire   [7:0]   awlen_debug_axis_ib_switch1_axi_s_0;
wire           awlock_debug_axis_ib_switch1_axi_s_0;
wire   [2:0]   awprot_debug_axis_ib_switch1_axi_s_0;
wire   [3:0]   awqv_debug_axis_ib_switch1_axi_s_0;
wire   [2:0]   awsize_debug_axis_ib_switch1_axi_s_0;
wire           awvalid_debug_axis_ib_switch1_axi_s_0;
wire   [1:0]   awvalid_vect_debug_axis_ib_switch1_axi_s_0;
wire   [10:0]  b_data_debug_axis_ib_int;
wire   [3:0]   b_wpntr_gry_debug_axis_ib_int;
wire           bready_debug_axis_ib_switch1_axi_s_0;
wire   [43:0]  r_data_debug_axis_ib_int;
wire   [2:0]   r_wpntr_gry_debug_axis_ib_int;
wire           rready_debug_axis_ib_switch1_axi_s_0;
wire   [2:0]   w_rpntr_bin_debug_axis_ib_int;
wire   [3:0]   w_rpntr_gry_debug_axis_ib_int;
wire   [31:0]  wdata_debug_axis_ib_switch1_axi_s_0;
wire           wlast_debug_axis_ib_switch1_axi_s_0;
wire   [3:0]   wstrb_debug_axis_ib_switch1_axi_s_0;
wire           wvalid_debug_axis_ib_switch1_axi_s_0;
wire   [63:0]  ar_data_debug_axis_ib_int;
wire   [2:0]   ar_wpntr_gry_debug_axis_ib_int;
wire           arready_debug_axis_debug_axis_ib_axi4_s;
wire   [63:0]  aw_data_debug_axis_ib_int;
wire   [3:0]   aw_wpntr_gry_debug_axis_ib_int;
wire           awready_debug_axis_debug_axis_ib_axi4_s;
wire   [2:0]   b_rpntr_bin_debug_axis_ib_int;
wire   [3:0]   b_rpntr_gry_debug_axis_ib_int;
wire   [8:0]   bid_debug_axis_debug_axis_ib_axi4_s;
wire   [1:0]   bresp_debug_axis_debug_axis_ib_axi4_s;
wire           bvalid_debug_axis_debug_axis_ib_axi4_s;
wire   [1:0]   r_rpntr_bin_debug_axis_ib_int;
wire   [2:0]   r_rpntr_gry_debug_axis_ib_int;
wire   [31:0]  rdata_debug_axis_debug_axis_ib_axi4_s;
wire   [8:0]   rid_debug_axis_debug_axis_ib_axi4_s;
wire           rlast_debug_axis_debug_axis_ib_axi4_s;
wire   [1:0]   rresp_debug_axis_debug_axis_ib_axi4_s;
wire           rvalid_debug_axis_debug_axis_ib_axi4_s;
wire   [36:0]  w_data_debug_axis_ib_int;
wire   [3:0]   w_wpntr_gry_debug_axis_ib_int;
wire           wready_debug_axis_debug_axis_ib_axi4_s;
wire           aclk;
wire           aclken;
wire   [31:0]  araddr_debug_axis;
wire   [1:0]   arburst_debug_axis;
wire   [3:0]   arcache_debug_axis;
wire           aresetn;
wire   [8:0]   arid_debug_axis;
wire   [7:0]   arlen_debug_axis;
wire           arlock_debug_axis;
wire   [2:0]   arprot_debug_axis;
wire   [2:0]   arsize_debug_axis;
wire           arvalid_debug_axis;
wire   [31:0]  awaddr_debug_axis;
wire   [1:0]   awburst_debug_axis;
wire   [3:0]   awcache_debug_axis;
wire   [8:0]   awid_debug_axis;
wire   [7:0]   awlen_debug_axis;
wire           awlock_debug_axis;
wire   [2:0]   awprot_debug_axis;
wire   [2:0]   awsize_debug_axis;
wire           awvalid_debug_axis;
wire           bready_debug_axis;
wire           csysreq_cd_a;
wire   [31:0]  prdata_extdbg_apb;
wire           pready_extdbg_apb;
wire           pslverr_extdbg_apb;
wire           rready_debug_axis;
wire   [31:0]  wdata_debug_axis;
wire           wlast_debug_axis;
wire   [3:0]   wstrb_debug_axis;
wire           wvalid_debug_axis;




nic400_amib_slave_2_sse710_dbgaxi2apb     u_amib_slave_2 (
  .paddr_extdbg_apb     (paddr_extdbg_apb),
  .pwdata_extdbg_apb    (pwdata_extdbg_apb),
  .pwrite_extdbg_apb    (pwrite_extdbg_apb),
  .pprot_extdbg_apb     (pprot_extdbg_apb),
  .pstrb_extdbg_apb     (pstrb_extdbg_apb),
  .penable_extdbg_apb   (penable_extdbg_apb),
  .psel_extdbg_apb      (pselx_extdbg_apb),
  .prdata_extdbg_apb    (prdata_extdbg_apb),
  .pslverr_extdbg_apb   (pslverr_extdbg_apb),
  .pready_extdbg_apb    (pready_extdbg_apb),
  .awid_slave_2_s       (awid_switch1_slave_2_slave_2_s),
  .awaddr_slave_2_s     (awaddr_switch1_slave_2_slave_2_s),
  .awlen_slave_2_s      (awlen_switch1_slave_2_slave_2_s),
  .awsize_slave_2_s     (awsize_switch1_slave_2_slave_2_s),
  .awburst_slave_2_s    (awburst_switch1_slave_2_slave_2_s),
  .awlock_slave_2_s     (awlock_switch1_slave_2_slave_2_s),
  .awcache_slave_2_s    (awcache_switch1_slave_2_slave_2_s),
  .awprot_slave_2_s     (awprot_switch1_slave_2_slave_2_s),
  .awvalid_slave_2_s    (awvalid_switch1_slave_2_slave_2_s),
  .awready_slave_2_s    (awready_switch1_slave_2_slave_2_s),
  .wdata_slave_2_s      (wdata_switch1_slave_2_slave_2_s),
  .wstrb_slave_2_s      (wstrb_switch1_slave_2_slave_2_s),
  .wlast_slave_2_s      (wlast_switch1_slave_2_slave_2_s),
  .wvalid_slave_2_s     (wvalid_switch1_slave_2_slave_2_s),
  .wready_slave_2_s     (wready_switch1_slave_2_slave_2_s),
  .bid_slave_2_s        (bid_switch1_slave_2_slave_2_s),
  .bresp_slave_2_s      (bresp_switch1_slave_2_slave_2_s),
  .bvalid_slave_2_s     (bvalid_switch1_slave_2_slave_2_s),
  .bready_slave_2_s     (bready_switch1_slave_2_slave_2_s),
  .arid_slave_2_s       (arid_switch1_slave_2_slave_2_s),
  .araddr_slave_2_s     (araddr_switch1_slave_2_slave_2_s),
  .arlen_slave_2_s      (arlen_switch1_slave_2_slave_2_s),
  .arsize_slave_2_s     (arsize_switch1_slave_2_slave_2_s),
  .arburst_slave_2_s    (arburst_switch1_slave_2_slave_2_s),
  .arlock_slave_2_s     (arlock_switch1_slave_2_slave_2_s),
  .arcache_slave_2_s    (arcache_switch1_slave_2_slave_2_s),
  .arprot_slave_2_s     (arprot_switch1_slave_2_slave_2_s),
  .arvalid_slave_2_s    (arvalid_switch1_slave_2_slave_2_s),
  .arready_slave_2_s    (arready_switch1_slave_2_slave_2_s),
  .rid_slave_2_s        (rid_switch1_slave_2_slave_2_s),
  .rdata_slave_2_s      (rdata_switch1_slave_2_slave_2_s),
  .rresp_slave_2_s      (rresp_switch1_slave_2_slave_2_s),
  .rlast_slave_2_s      (rlast_switch1_slave_2_slave_2_s),
  .rvalid_slave_2_s     (rvalid_switch1_slave_2_slave_2_s),
  .rready_slave_2_s     (rready_switch1_slave_2_slave_2_s),
  .aclk                 (aclk),
  .apb_pclken           (aclken),
  .aresetn              (aresetn)
);


nic400_asib_debug_axis_sse710_dbgaxi2apb     u_asib_debug_axis (
  .debug_axis_cactive   (cactive_debug_axis_hcg),
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
  .debug_axis_cactive_wakeup (cactive_debug_axis_wakeup_hcg),
  .awid_secenc_axis_m   (awid_debug_axis_debug_axis_ib_axi4_s),
  .awaddr_secenc_axis_m (awaddr_debug_axis_debug_axis_ib_axi4_s),
  .awlen_secenc_axis_m  (awlen_debug_axis_debug_axis_ib_axi4_s),
  .awsize_secenc_axis_m (awsize_debug_axis_debug_axis_ib_axi4_s),
  .awburst_secenc_axis_m (awburst_debug_axis_debug_axis_ib_axi4_s),
  .awlock_secenc_axis_m (awlock_debug_axis_debug_axis_ib_axi4_s),
  .awcache_secenc_axis_m (awcache_debug_axis_debug_axis_ib_axi4_s),
  .awprot_secenc_axis_m (awprot_debug_axis_debug_axis_ib_axi4_s),
  .awvalid_secenc_axis_m (awvalid_debug_axis_debug_axis_ib_axi4_s),
  .awvalid_vect_secenc_axis_m (awvalid_vect_debug_axis_debug_axis_ib_axi4_s),
  .awready_secenc_axis_m (awready_debug_axis_debug_axis_ib_axi4_s),
  .wdata_secenc_axis_m  (wdata_debug_axis_debug_axis_ib_axi4_s),
  .wstrb_secenc_axis_m  (wstrb_debug_axis_debug_axis_ib_axi4_s),
  .wlast_secenc_axis_m  (wlast_debug_axis_debug_axis_ib_axi4_s),
  .wvalid_secenc_axis_m (wvalid_debug_axis_debug_axis_ib_axi4_s),
  .wready_secenc_axis_m (wready_debug_axis_debug_axis_ib_axi4_s),
  .bid_secenc_axis_m    (bid_debug_axis_debug_axis_ib_axi4_s),
  .bresp_secenc_axis_m  (bresp_debug_axis_debug_axis_ib_axi4_s),
  .bvalid_secenc_axis_m (bvalid_debug_axis_debug_axis_ib_axi4_s),
  .bready_secenc_axis_m (bready_debug_axis_debug_axis_ib_axi4_s),
  .arid_secenc_axis_m   (arid_debug_axis_debug_axis_ib_axi4_s),
  .araddr_secenc_axis_m (araddr_debug_axis_debug_axis_ib_axi4_s),
  .arlen_secenc_axis_m  (arlen_debug_axis_debug_axis_ib_axi4_s),
  .arsize_secenc_axis_m (arsize_debug_axis_debug_axis_ib_axi4_s),
  .arburst_secenc_axis_m (arburst_debug_axis_debug_axis_ib_axi4_s),
  .arlock_secenc_axis_m (arlock_debug_axis_debug_axis_ib_axi4_s),
  .arcache_secenc_axis_m (arcache_debug_axis_debug_axis_ib_axi4_s),
  .arprot_secenc_axis_m (arprot_debug_axis_debug_axis_ib_axi4_s),
  .arvalid_secenc_axis_m (arvalid_debug_axis_debug_axis_ib_axi4_s),
  .arvalid_vect_secenc_axis_m (arvalid_vect_debug_axis_debug_axis_ib_axi4_s),
  .arready_secenc_axis_m (arready_debug_axis_debug_axis_ib_axi4_s),
  .rid_secenc_axis_m    (rid_debug_axis_debug_axis_ib_axi4_s),
  .rdata_secenc_axis_m  (rdata_debug_axis_debug_axis_ib_axi4_s),
  .rresp_secenc_axis_m  (rresp_debug_axis_debug_axis_ib_axi4_s),
  .rlast_secenc_axis_m  (rlast_debug_axis_debug_axis_ib_axi4_s),
  .rvalid_secenc_axis_m (rvalid_debug_axis_debug_axis_ib_axi4_s),
  .rready_secenc_axis_m (rready_debug_axis_debug_axis_ib_axi4_s),
  .aclk                 (aclk),
  .aresetn              (aresetn)
);


nic400_switch1_sse710_dbgaxi2apb     u_busmatrix_switch1 (
  .awid_axi_m_0         (awid_switch1_slave_2_slave_2_s),
  .awaddr_axi_m_0       (awaddr_switch1_slave_2_slave_2_s),
  .awlen_axi_m_0        (awlen_switch1_slave_2_slave_2_s),
  .awsize_axi_m_0       (awsize_switch1_slave_2_slave_2_s),
  .awburst_axi_m_0      (awburst_switch1_slave_2_slave_2_s),
  .awlock_axi_m_0       (awlock_switch1_slave_2_slave_2_s),
  .awcache_axi_m_0      (awcache_switch1_slave_2_slave_2_s),
  .awprot_axi_m_0       (awprot_switch1_slave_2_slave_2_s),
  .awvalid_axi_m_0      (awvalid_switch1_slave_2_slave_2_s),
  .awvalid_vect_axi_m_0 (),
  .awready_axi_m_0      (awready_switch1_slave_2_slave_2_s),
  .wdata_axi_m_0        (wdata_switch1_slave_2_slave_2_s),
  .wstrb_axi_m_0        (wstrb_switch1_slave_2_slave_2_s),
  .wlast_axi_m_0        (wlast_switch1_slave_2_slave_2_s),
  .wvalid_axi_m_0       (wvalid_switch1_slave_2_slave_2_s),
  .wready_axi_m_0       (wready_switch1_slave_2_slave_2_s),
  .bid_axi_m_0          (bid_switch1_slave_2_slave_2_s),
  .bresp_axi_m_0        (bresp_switch1_slave_2_slave_2_s),
  .bvalid_axi_m_0       (bvalid_switch1_slave_2_slave_2_s),
  .bready_axi_m_0       (bready_switch1_slave_2_slave_2_s),
  .arid_axi_m_0         (arid_switch1_slave_2_slave_2_s),
  .araddr_axi_m_0       (araddr_switch1_slave_2_slave_2_s),
  .arlen_axi_m_0        (arlen_switch1_slave_2_slave_2_s),
  .arsize_axi_m_0       (arsize_switch1_slave_2_slave_2_s),
  .arburst_axi_m_0      (arburst_switch1_slave_2_slave_2_s),
  .arlock_axi_m_0       (arlock_switch1_slave_2_slave_2_s),
  .arcache_axi_m_0      (arcache_switch1_slave_2_slave_2_s),
  .arprot_axi_m_0       (arprot_switch1_slave_2_slave_2_s),
  .arvalid_axi_m_0      (arvalid_switch1_slave_2_slave_2_s),
  .arvalid_vect_axi_m_0 (),
  .arready_axi_m_0      (arready_switch1_slave_2_slave_2_s),
  .rid_axi_m_0          (rid_switch1_slave_2_slave_2_s),
  .rdata_axi_m_0        (rdata_switch1_slave_2_slave_2_s),
  .rresp_axi_m_0        (rresp_switch1_slave_2_slave_2_s),
  .rlast_axi_m_0        (rlast_switch1_slave_2_slave_2_s),
  .rvalid_axi_m_0       (rvalid_switch1_slave_2_slave_2_s),
  .rready_axi_m_0       (rready_switch1_slave_2_slave_2_s),
  .aw_qv_axi_m_0        (),
  .ar_qv_axi_m_0        (),
  .awid_axi_m_1         (awid_switch1_ds_1_axi_s_0),
  .awaddr_axi_m_1       (),
  .awlen_axi_m_1        (),
  .awsize_axi_m_1       (),
  .awburst_axi_m_1      (),
  .awlock_axi_m_1       (),
  .awcache_axi_m_1      (),
  .awprot_axi_m_1       (),
  .awvalid_axi_m_1      (awvalid_switch1_ds_1_axi_s_0),
  .awvalid_vect_axi_m_1 (),
  .awready_axi_m_1      (awready_switch1_ds_1_axi_s_0),
  .wdata_axi_m_1        (),
  .wstrb_axi_m_1        (),
  .wlast_axi_m_1        (wlast_switch1_ds_1_axi_s_0),
  .wvalid_axi_m_1       (wvalid_switch1_ds_1_axi_s_0),
  .wready_axi_m_1       (wready_switch1_ds_1_axi_s_0),
  .bid_axi_m_1          (bid_switch1_ds_1_axi_s_0),
  .bresp_axi_m_1        (bresp_switch1_ds_1_axi_s_0),
  .bvalid_axi_m_1       (bvalid_switch1_ds_1_axi_s_0),
  .bready_axi_m_1       (bready_switch1_ds_1_axi_s_0),
  .arid_axi_m_1         (arid_switch1_ds_1_axi_s_0),
  .araddr_axi_m_1       (),
  .arlen_axi_m_1        (arlen_switch1_ds_1_axi_s_0),
  .arsize_axi_m_1       (),
  .arburst_axi_m_1      (),
  .arlock_axi_m_1       (),
  .arcache_axi_m_1      (),
  .arprot_axi_m_1       (),
  .arvalid_axi_m_1      (arvalid_switch1_ds_1_axi_s_0),
  .arvalid_vect_axi_m_1 (),
  .arready_axi_m_1      (arready_switch1_ds_1_axi_s_0),
  .rid_axi_m_1          (rid_switch1_ds_1_axi_s_0),
  .rdata_axi_m_1        (32'b0),
  .rresp_axi_m_1        (rresp_switch1_ds_1_axi_s_0),
  .rlast_axi_m_1        (rlast_switch1_ds_1_axi_s_0),
  .rvalid_axi_m_1       (rvalid_switch1_ds_1_axi_s_0),
  .rready_axi_m_1       (rready_switch1_ds_1_axi_s_0),
  .aw_qv_axi_m_1        (),
  .ar_qv_axi_m_1        (),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .awid_axi_s_0         (awid_debug_axis_ib_switch1_axi_s_0),
  .awaddr_axi_s_0       (awaddr_debug_axis_ib_switch1_axi_s_0),
  .awlen_axi_s_0        (awlen_debug_axis_ib_switch1_axi_s_0),
  .awsize_axi_s_0       (awsize_debug_axis_ib_switch1_axi_s_0),
  .awburst_axi_s_0      (awburst_debug_axis_ib_switch1_axi_s_0),
  .awlock_axi_s_0       (awlock_debug_axis_ib_switch1_axi_s_0),
  .awcache_axi_s_0      (awcache_debug_axis_ib_switch1_axi_s_0),
  .awprot_axi_s_0       (awprot_debug_axis_ib_switch1_axi_s_0),
  .awvalid_axi_s_0      (awvalid_debug_axis_ib_switch1_axi_s_0),
  .awvalid_vect_axi_s_0 (awvalid_vect_debug_axis_ib_switch1_axi_s_0),
  .awready_axi_s_0      (awready_debug_axis_ib_switch1_axi_s_0),
  .wdata_axi_s_0        (wdata_debug_axis_ib_switch1_axi_s_0),
  .wstrb_axi_s_0        (wstrb_debug_axis_ib_switch1_axi_s_0),
  .wlast_axi_s_0        (wlast_debug_axis_ib_switch1_axi_s_0),
  .wvalid_axi_s_0       (wvalid_debug_axis_ib_switch1_axi_s_0),
  .wready_axi_s_0       (wready_debug_axis_ib_switch1_axi_s_0),
  .bid_axi_s_0          (bid_debug_axis_ib_switch1_axi_s_0),
  .bresp_axi_s_0        (bresp_debug_axis_ib_switch1_axi_s_0),
  .bvalid_axi_s_0       (bvalid_debug_axis_ib_switch1_axi_s_0),
  .bready_axi_s_0       (bready_debug_axis_ib_switch1_axi_s_0),
  .arid_axi_s_0         (arid_debug_axis_ib_switch1_axi_s_0),
  .araddr_axi_s_0       (araddr_debug_axis_ib_switch1_axi_s_0),
  .arlen_axi_s_0        (arlen_debug_axis_ib_switch1_axi_s_0),
  .arsize_axi_s_0       (arsize_debug_axis_ib_switch1_axi_s_0),
  .arburst_axi_s_0      (arburst_debug_axis_ib_switch1_axi_s_0),
  .arlock_axi_s_0       (arlock_debug_axis_ib_switch1_axi_s_0),
  .arcache_axi_s_0      (arcache_debug_axis_ib_switch1_axi_s_0),
  .arprot_axi_s_0       (arprot_debug_axis_ib_switch1_axi_s_0),
  .arvalid_axi_s_0      (arvalid_debug_axis_ib_switch1_axi_s_0),
  .arvalid_vect_axi_s_0 (arvalid_vect_debug_axis_ib_switch1_axi_s_0),
  .arready_axi_s_0      (arready_debug_axis_ib_switch1_axi_s_0),
  .rid_axi_s_0          (rid_debug_axis_ib_switch1_axi_s_0),
  .rdata_axi_s_0        (rdata_debug_axis_ib_switch1_axi_s_0),
  .rresp_axi_s_0        (rresp_debug_axis_ib_switch1_axi_s_0),
  .rlast_axi_s_0        (rlast_debug_axis_ib_switch1_axi_s_0),
  .rvalid_axi_s_0       (rvalid_debug_axis_ib_switch1_axi_s_0),
  .rready_axi_s_0       (rready_debug_axis_ib_switch1_axi_s_0),
  .aw_qv_axi_s_0        (awqv_debug_axis_ib_switch1_axi_s_0),
  .ar_qv_axi_s_0        (arqv_debug_axis_ib_switch1_axi_s_0)
);


nic400_default_slave_ds_1_sse710_dbgaxi2apb     u_default_slave_ds_1 (
  .awid                 (awid_switch1_ds_1_axi_s_0),
  .awvalid              (awvalid_switch1_ds_1_axi_s_0),
  .awready              (awready_switch1_ds_1_axi_s_0),
  .wlast                (wlast_switch1_ds_1_axi_s_0),
  .wvalid               (wvalid_switch1_ds_1_axi_s_0),
  .wready               (wready_switch1_ds_1_axi_s_0),
  .bid                  (bid_switch1_ds_1_axi_s_0),
  .bresp                (bresp_switch1_ds_1_axi_s_0),
  .bvalid               (bvalid_switch1_ds_1_axi_s_0),
  .bready               (bready_switch1_ds_1_axi_s_0),
  .arid                 (arid_switch1_ds_1_axi_s_0),
  .arlen                (arlen_switch1_ds_1_axi_s_0),
  .arvalid              (arvalid_switch1_ds_1_axi_s_0),
  .arready              (arready_switch1_ds_1_axi_s_0),
  .rid                  (rid_switch1_ds_1_axi_s_0),
  .rresp                (rresp_switch1_ds_1_axi_s_0),
  .rlast                (rlast_switch1_ds_1_axi_s_0),
  .rvalid               (rvalid_switch1_ds_1_axi_s_0),
  .rready               (rready_switch1_ds_1_axi_s_0),
  .aclk                 (aclk),
  .aresetn              (aresetn)
);


nic400_dmu_a_sse710_dbgaxi2apb     u_dmu_a_sse710_dbgaxi2apb (
  .cd_a_clk             (aclk),
  .cd_a_resetn          (aresetn),
  .cd_a_cactive         (cactive_cd_a),
  .cd_a_csysreq         (csysreq_cd_a),
  .cd_a_csysack         (csysack_cd_a),
  .debug_axis_cactive   (cactive_debug_axis_hcg),
  .debug_axis_port_enable (port_enable_debug_axis_port_enable_hcg),
  .debug_axis_cactive_wakeup (cactive_debug_axis_wakeup_hcg)
);


nic400_ib_debug_axis_ib_master_domain_sse710_dbgaxi2apb     u_ib_debug_axis_ib_m (
  .awid_axi4_m          (awid_debug_axis_ib_switch1_axi_s_0),
  .awaddr_axi4_m        (awaddr_debug_axis_ib_switch1_axi_s_0),
  .awlen_axi4_m         (awlen_debug_axis_ib_switch1_axi_s_0),
  .awsize_axi4_m        (awsize_debug_axis_ib_switch1_axi_s_0),
  .awburst_axi4_m       (awburst_debug_axis_ib_switch1_axi_s_0),
  .awlock_axi4_m        (awlock_debug_axis_ib_switch1_axi_s_0),
  .awcache_axi4_m       (awcache_debug_axis_ib_switch1_axi_s_0),
  .awprot_axi4_m        (awprot_debug_axis_ib_switch1_axi_s_0),
  .awvalid_axi4_m       (awvalid_debug_axis_ib_switch1_axi_s_0),
  .awvalid_vect_axi4_m  (awvalid_vect_debug_axis_ib_switch1_axi_s_0),
  .awready_axi4_m       (awready_debug_axis_ib_switch1_axi_s_0),
  .wdata_axi4_m         (wdata_debug_axis_ib_switch1_axi_s_0),
  .wstrb_axi4_m         (wstrb_debug_axis_ib_switch1_axi_s_0),
  .wlast_axi4_m         (wlast_debug_axis_ib_switch1_axi_s_0),
  .wvalid_axi4_m        (wvalid_debug_axis_ib_switch1_axi_s_0),
  .wready_axi4_m        (wready_debug_axis_ib_switch1_axi_s_0),
  .bid_axi4_m           (bid_debug_axis_ib_switch1_axi_s_0),
  .bresp_axi4_m         (bresp_debug_axis_ib_switch1_axi_s_0),
  .bvalid_axi4_m        (bvalid_debug_axis_ib_switch1_axi_s_0),
  .bready_axi4_m        (bready_debug_axis_ib_switch1_axi_s_0),
  .arid_axi4_m          (arid_debug_axis_ib_switch1_axi_s_0),
  .araddr_axi4_m        (araddr_debug_axis_ib_switch1_axi_s_0),
  .arlen_axi4_m         (arlen_debug_axis_ib_switch1_axi_s_0),
  .arsize_axi4_m        (arsize_debug_axis_ib_switch1_axi_s_0),
  .arburst_axi4_m       (arburst_debug_axis_ib_switch1_axi_s_0),
  .arlock_axi4_m        (arlock_debug_axis_ib_switch1_axi_s_0),
  .arcache_axi4_m       (arcache_debug_axis_ib_switch1_axi_s_0),
  .arprot_axi4_m        (arprot_debug_axis_ib_switch1_axi_s_0),
  .arvalid_axi4_m       (arvalid_debug_axis_ib_switch1_axi_s_0),
  .arvalid_vect_axi4_m  (arvalid_vect_debug_axis_ib_switch1_axi_s_0),
  .arready_axi4_m       (arready_debug_axis_ib_switch1_axi_s_0),
  .rid_axi4_m           (rid_debug_axis_ib_switch1_axi_s_0),
  .rdata_axi4_m         (rdata_debug_axis_ib_switch1_axi_s_0),
  .rresp_axi4_m         (rresp_debug_axis_ib_switch1_axi_s_0),
  .rlast_axi4_m         (rlast_debug_axis_ib_switch1_axi_s_0),
  .rvalid_axi4_m        (rvalid_debug_axis_ib_switch1_axi_s_0),
  .rready_axi4_m        (rready_debug_axis_ib_switch1_axi_s_0),
  .awqv_axi4_m          (awqv_debug_axis_ib_switch1_axi_s_0),
  .arqv_axi4_m          (arqv_debug_axis_ib_switch1_axi_s_0),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_debug_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_debug_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_debug_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_debug_axis_ib_int),
  .b_data               (b_data_debug_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_debug_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_debug_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_debug_axis_ib_int),
  .ar_data              (ar_data_debug_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_debug_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_debug_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_debug_axis_ib_int),
  .r_data               (r_data_debug_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_debug_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_debug_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_debug_axis_ib_int),
  .w_data               (w_data_debug_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_debug_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_debug_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_debug_axis_ib_int)
);


nic400_ib_debug_axis_ib_slave_domain_sse710_dbgaxi2apb     u_ib_debug_axis_ib_s (
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
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_debug_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_debug_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_debug_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_debug_axis_ib_int),
  .b_data               (b_data_debug_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_debug_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_debug_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_debug_axis_ib_int),
  .ar_data              (ar_data_debug_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_debug_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_debug_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_debug_axis_ib_int),
  .r_data               (r_data_debug_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_debug_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_debug_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_debug_axis_ib_int),
  .w_data               (w_data_debug_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_debug_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_debug_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_debug_axis_ib_int)
);



endmodule
