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




module nic400_sse710_sctrl_apb (
  

  paddr_uart_apb,
  pwdata_uart_apb,
  pwrite_uart_apb,
  pprot_uart_apb,
  pstrb_uart_apb,
  penable_uart_apb,
  pselx_uart_apb,
  prdata_uart_apb,
  pslverr_uart_apb,
  pready_uart_apb,
  

  paddr_sysctrl_apb,
  pwdata_sysctrl_apb,
  pwrite_sysctrl_apb,
  pprot_sysctrl_apb,
  pstrb_sysctrl_apb,
  penable_sysctrl_apb,
  pselx_sysctrl_apb,
  prdata_sysctrl_apb,
  pslverr_sysctrl_apb,
  pready_sysctrl_apb,
  

  awid_sysctrl_axis,
  awaddr_sysctrl_axis,
  awlen_sysctrl_axis,
  awsize_sysctrl_axis,
  awburst_sysctrl_axis,
  awlock_sysctrl_axis,
  awcache_sysctrl_axis,
  awprot_sysctrl_axis,
  awvalid_sysctrl_axis,
  awready_sysctrl_axis,
  wdata_sysctrl_axis,
  wstrb_sysctrl_axis,
  wlast_sysctrl_axis,
  wvalid_sysctrl_axis,
  wready_sysctrl_axis,
  bid_sysctrl_axis,
  bresp_sysctrl_axis,
  bvalid_sysctrl_axis,
  bready_sysctrl_axis,
  arid_sysctrl_axis,
  araddr_sysctrl_axis,
  arlen_sysctrl_axis,
  arsize_sysctrl_axis,
  arburst_sysctrl_axis,
  arlock_sysctrl_axis,
  arcache_sysctrl_axis,
  arprot_sysctrl_axis,
  arvalid_sysctrl_axis,
  arready_sysctrl_axis,
  rid_sysctrl_axis,
  rdata_sysctrl_axis,
  rresp_sysctrl_axis,
  rlast_sysctrl_axis,
  rvalid_sysctrl_axis,
  rready_sysctrl_axis,
  awqos_sysctrl_axis,
  arqos_sysctrl_axis,
  

  cactive_cd_a,
  csysreq_cd_a,
  csysack_cd_a,


  aclk,
  aclken,
  aresetn

);






output [31:0] paddr_uart_apb;
output [31:0] pwdata_uart_apb;
output        pwrite_uart_apb;
output [2:0]  pprot_uart_apb;
output [3:0]  pstrb_uart_apb;
output        penable_uart_apb;
output        pselx_uart_apb;
input  [31:0] prdata_uart_apb;
input         pslverr_uart_apb;
input         pready_uart_apb;


output [31:0] paddr_sysctrl_apb;
output [31:0] pwdata_sysctrl_apb;
output        pwrite_sysctrl_apb;
output [2:0]  pprot_sysctrl_apb;
output [3:0]  pstrb_sysctrl_apb;
output        penable_sysctrl_apb;
output        pselx_sysctrl_apb;
input  [31:0] prdata_sysctrl_apb;
input         pslverr_sysctrl_apb;
input         pready_sysctrl_apb;


input  [11:0] awid_sysctrl_axis;
input  [31:0] awaddr_sysctrl_axis;
input  [7:0]  awlen_sysctrl_axis;
input  [2:0]  awsize_sysctrl_axis;
input  [1:0]  awburst_sysctrl_axis;
input         awlock_sysctrl_axis;
input  [3:0]  awcache_sysctrl_axis;
input  [2:0]  awprot_sysctrl_axis;
input         awvalid_sysctrl_axis;
output        awready_sysctrl_axis;
input  [31:0] wdata_sysctrl_axis;
input  [3:0]  wstrb_sysctrl_axis;
input         wlast_sysctrl_axis;
input         wvalid_sysctrl_axis;
output        wready_sysctrl_axis;
output [11:0] bid_sysctrl_axis;
output [1:0]  bresp_sysctrl_axis;
output        bvalid_sysctrl_axis;
input         bready_sysctrl_axis;
input  [11:0] arid_sysctrl_axis;
input  [31:0] araddr_sysctrl_axis;
input  [7:0]  arlen_sysctrl_axis;
input  [2:0]  arsize_sysctrl_axis;
input  [1:0]  arburst_sysctrl_axis;
input         arlock_sysctrl_axis;
input  [3:0]  arcache_sysctrl_axis;
input  [2:0]  arprot_sysctrl_axis;
input         arvalid_sysctrl_axis;
output        arready_sysctrl_axis;
output [11:0] rid_sysctrl_axis;
output [31:0] rdata_sysctrl_axis;
output [1:0]  rresp_sysctrl_axis;
output        rlast_sysctrl_axis;
output        rvalid_sysctrl_axis;
input         rready_sysctrl_axis;
input  [3:0]  awqos_sysctrl_axis;
input  [3:0]  arqos_sysctrl_axis;


output        cactive_cd_a;
input         csysreq_cd_a;
output        csysack_cd_a;


input         aclk;
input         aclken;
input         aresetn;




wire           arready_sysctrl_axis;
wire           awready_sysctrl_axis;
wire   [11:0]  bid_sysctrl_axis;
wire   [1:0]   bresp_sysctrl_axis;
wire           bvalid_sysctrl_axis;
wire           cactive_cd_a;
wire           csysack_cd_a;
wire   [31:0]  paddr_sysctrl_apb;
wire   [31:0]  paddr_uart_apb;
wire           penable_sysctrl_apb;
wire           penable_uart_apb;
wire   [2:0]   pprot_sysctrl_apb;
wire   [2:0]   pprot_uart_apb;
wire           pselx_sysctrl_apb;
wire           pselx_uart_apb;
wire   [3:0]   pstrb_sysctrl_apb;
wire   [3:0]   pstrb_uart_apb;
wire   [31:0]  pwdata_sysctrl_apb;
wire   [31:0]  pwdata_uart_apb;
wire           pwrite_sysctrl_apb;
wire           pwrite_uart_apb;
wire   [31:0]  rdata_sysctrl_axis;
wire   [11:0]  rid_sysctrl_axis;
wire           rlast_sysctrl_axis;
wire   [1:0]   rresp_sysctrl_axis;
wire           rvalid_sysctrl_axis;
wire           wready_sysctrl_axis;
wire           arready_switch1_slave_2_slave_2_s;
wire           awready_switch1_slave_2_slave_2_s;
wire   [11:0]  bid_switch1_slave_2_slave_2_s;
wire   [1:0]   bresp_switch1_slave_2_slave_2_s;
wire           bvalid_switch1_slave_2_slave_2_s;
wire   [31:0]  rdata_switch1_slave_2_slave_2_s;
wire   [11:0]  rid_switch1_slave_2_slave_2_s;
wire           rlast_switch1_slave_2_slave_2_s;
wire   [1:0]   rresp_switch1_slave_2_slave_2_s;
wire           rvalid_switch1_slave_2_slave_2_s;
wire           wready_switch1_slave_2_slave_2_s;
wire           arready_switch1_slave_5_slave_5_s;
wire           awready_switch1_slave_5_slave_5_s;
wire   [11:0]  bid_switch1_slave_5_slave_5_s;
wire   [1:0]   bresp_switch1_slave_5_slave_5_s;
wire           bvalid_switch1_slave_5_slave_5_s;
wire   [31:0]  rdata_switch1_slave_5_slave_5_s;
wire   [11:0]  rid_switch1_slave_5_slave_5_s;
wire           rlast_switch1_slave_5_slave_5_s;
wire   [1:0]   rresp_switch1_slave_5_slave_5_s;
wire           rvalid_switch1_slave_5_slave_5_s;
wire           wready_switch1_slave_5_slave_5_s;
wire   [31:0]  araddr_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [1:0]   arburst_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [3:0]   arcache_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [11:0]  arid_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [7:0]   arlen_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire           arlock_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [2:0]   arprot_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [3:0]   arqv_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [2:0]   arsize_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire           arvalid_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [2:0]   arvalid_vect_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [31:0]  awaddr_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [1:0]   awburst_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [3:0]   awcache_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [11:0]  awid_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [7:0]   awlen_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire           awlock_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [2:0]   awprot_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [3:0]   awqv_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [2:0]   awsize_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire           awvalid_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [2:0]   awvalid_vect_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire           bready_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire           rready_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire           cactive_sysctrl_axis_hcg;
wire           cactive_sysctrl_axis_wakeup_hcg;
wire   [31:0]  wdata_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire           wlast_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [3:0]   wstrb_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire           wvalid_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [31:0]  araddr_switch1_slave_5_slave_5_s;
wire   [31:0]  araddr_switch1_slave_2_slave_2_s;
wire   [1:0]   arburst_switch1_slave_5_slave_5_s;
wire   [1:0]   arburst_switch1_slave_2_slave_2_s;
wire   [3:0]   arcache_switch1_slave_5_slave_5_s;
wire   [3:0]   arcache_switch1_slave_2_slave_2_s;
wire   [11:0]  arid_switch1_slave_5_slave_5_s;
wire   [11:0]  arid_switch1_ds_0_axi_s_0;
wire   [11:0]  arid_switch1_slave_2_slave_2_s;
wire   [7:0]   arlen_switch1_slave_5_slave_5_s;
wire   [7:0]   arlen_switch1_ds_0_axi_s_0;
wire   [7:0]   arlen_switch1_slave_2_slave_2_s;
wire           arlock_switch1_slave_5_slave_5_s;
wire           arlock_switch1_slave_2_slave_2_s;
wire   [2:0]   arprot_switch1_slave_5_slave_5_s;
wire   [2:0]   arprot_switch1_slave_2_slave_2_s;
wire           arready_sysctrl_axis_ib_switch1_axi_s_0;
wire   [2:0]   arsize_switch1_slave_5_slave_5_s;
wire   [2:0]   arsize_switch1_slave_2_slave_2_s;
wire           arvalid_switch1_slave_5_slave_5_s;
wire           arvalid_switch1_ds_0_axi_s_0;
wire           arvalid_switch1_slave_2_slave_2_s;
wire   [31:0]  awaddr_switch1_slave_5_slave_5_s;
wire   [31:0]  awaddr_switch1_slave_2_slave_2_s;
wire   [1:0]   awburst_switch1_slave_5_slave_5_s;
wire   [1:0]   awburst_switch1_slave_2_slave_2_s;
wire   [3:0]   awcache_switch1_slave_5_slave_5_s;
wire   [3:0]   awcache_switch1_slave_2_slave_2_s;
wire   [11:0]  awid_switch1_slave_5_slave_5_s;
wire   [11:0]  awid_switch1_ds_0_axi_s_0;
wire   [11:0]  awid_switch1_slave_2_slave_2_s;
wire   [7:0]   awlen_switch1_slave_5_slave_5_s;
wire   [7:0]   awlen_switch1_slave_2_slave_2_s;
wire           awlock_switch1_slave_5_slave_5_s;
wire           awlock_switch1_slave_2_slave_2_s;
wire   [2:0]   awprot_switch1_slave_5_slave_5_s;
wire   [2:0]   awprot_switch1_slave_2_slave_2_s;
wire           awready_sysctrl_axis_ib_switch1_axi_s_0;
wire   [2:0]   awsize_switch1_slave_5_slave_5_s;
wire   [2:0]   awsize_switch1_slave_2_slave_2_s;
wire           awvalid_switch1_slave_5_slave_5_s;
wire           awvalid_switch1_ds_0_axi_s_0;
wire           awvalid_switch1_slave_2_slave_2_s;
wire   [11:0]  bid_sysctrl_axis_ib_switch1_axi_s_0;
wire           bready_switch1_slave_5_slave_5_s;
wire           bready_switch1_ds_0_axi_s_0;
wire           bready_switch1_slave_2_slave_2_s;
wire   [1:0]   bresp_sysctrl_axis_ib_switch1_axi_s_0;
wire           bvalid_sysctrl_axis_ib_switch1_axi_s_0;
wire   [31:0]  rdata_sysctrl_axis_ib_switch1_axi_s_0;
wire   [11:0]  rid_sysctrl_axis_ib_switch1_axi_s_0;
wire           rlast_sysctrl_axis_ib_switch1_axi_s_0;
wire           rready_switch1_slave_5_slave_5_s;
wire           rready_switch1_ds_0_axi_s_0;
wire           rready_switch1_slave_2_slave_2_s;
wire   [1:0]   rresp_sysctrl_axis_ib_switch1_axi_s_0;
wire           rvalid_sysctrl_axis_ib_switch1_axi_s_0;
wire   [31:0]  wdata_switch1_slave_5_slave_5_s;
wire   [31:0]  wdata_switch1_slave_2_slave_2_s;
wire           wlast_switch1_slave_5_slave_5_s;
wire           wlast_switch1_ds_0_axi_s_0;
wire           wlast_switch1_slave_2_slave_2_s;
wire           wready_sysctrl_axis_ib_switch1_axi_s_0;
wire   [3:0]   wstrb_switch1_slave_5_slave_5_s;
wire   [3:0]   wstrb_switch1_slave_2_slave_2_s;
wire           wvalid_switch1_slave_5_slave_5_s;
wire           wvalid_switch1_ds_0_axi_s_0;
wire           wvalid_switch1_slave_2_slave_2_s;
wire           arready_switch1_ds_0_axi_s_0;
wire           awready_switch1_ds_0_axi_s_0;
wire   [11:0]  bid_switch1_ds_0_axi_s_0;
wire   [1:0]   bresp_switch1_ds_0_axi_s_0;
wire           bvalid_switch1_ds_0_axi_s_0;
wire   [11:0]  rid_switch1_ds_0_axi_s_0;
wire           rlast_switch1_ds_0_axi_s_0;
wire   [1:0]   rresp_switch1_ds_0_axi_s_0;
wire           rvalid_switch1_ds_0_axi_s_0;
wire           wready_switch1_ds_0_axi_s_0;
wire           port_enable_sysctrl_axis_port_enable_hcg;
wire   [1:0]   ar_rpntr_bin_sysctrl_axis_ib_int;
wire   [2:0]   ar_rpntr_gry_sysctrl_axis_ib_int;
wire   [31:0]  araddr_sysctrl_axis_ib_switch1_axi_s_0;
wire   [1:0]   arburst_sysctrl_axis_ib_switch1_axi_s_0;
wire   [3:0]   arcache_sysctrl_axis_ib_switch1_axi_s_0;
wire   [11:0]  arid_sysctrl_axis_ib_switch1_axi_s_0;
wire   [7:0]   arlen_sysctrl_axis_ib_switch1_axi_s_0;
wire           arlock_sysctrl_axis_ib_switch1_axi_s_0;
wire   [2:0]   arprot_sysctrl_axis_ib_switch1_axi_s_0;
wire   [3:0]   arqv_sysctrl_axis_ib_switch1_axi_s_0;
wire   [2:0]   arsize_sysctrl_axis_ib_switch1_axi_s_0;
wire           arvalid_sysctrl_axis_ib_switch1_axi_s_0;
wire   [2:0]   arvalid_vect_sysctrl_axis_ib_switch1_axi_s_0;
wire   [2:0]   aw_rpntr_bin_sysctrl_axis_ib_int;
wire   [3:0]   aw_rpntr_gry_sysctrl_axis_ib_int;
wire   [31:0]  awaddr_sysctrl_axis_ib_switch1_axi_s_0;
wire   [1:0]   awburst_sysctrl_axis_ib_switch1_axi_s_0;
wire   [3:0]   awcache_sysctrl_axis_ib_switch1_axi_s_0;
wire   [11:0]  awid_sysctrl_axis_ib_switch1_axi_s_0;
wire   [7:0]   awlen_sysctrl_axis_ib_switch1_axi_s_0;
wire           awlock_sysctrl_axis_ib_switch1_axi_s_0;
wire   [2:0]   awprot_sysctrl_axis_ib_switch1_axi_s_0;
wire   [3:0]   awqv_sysctrl_axis_ib_switch1_axi_s_0;
wire   [2:0]   awsize_sysctrl_axis_ib_switch1_axi_s_0;
wire           awvalid_sysctrl_axis_ib_switch1_axi_s_0;
wire   [2:0]   awvalid_vect_sysctrl_axis_ib_switch1_axi_s_0;
wire   [13:0]  b_data_sysctrl_axis_ib_int;
wire   [3:0]   b_wpntr_gry_sysctrl_axis_ib_int;
wire           bready_sysctrl_axis_ib_switch1_axi_s_0;
wire   [46:0]  r_data_sysctrl_axis_ib_int;
wire   [2:0]   r_wpntr_gry_sysctrl_axis_ib_int;
wire           rready_sysctrl_axis_ib_switch1_axi_s_0;
wire   [2:0]   w_rpntr_bin_sysctrl_axis_ib_int;
wire   [3:0]   w_rpntr_gry_sysctrl_axis_ib_int;
wire   [31:0]  wdata_sysctrl_axis_ib_switch1_axi_s_0;
wire           wlast_sysctrl_axis_ib_switch1_axi_s_0;
wire   [3:0]   wstrb_sysctrl_axis_ib_switch1_axi_s_0;
wire           wvalid_sysctrl_axis_ib_switch1_axi_s_0;
wire   [71:0]  ar_data_sysctrl_axis_ib_int;
wire   [2:0]   ar_wpntr_gry_sysctrl_axis_ib_int;
wire           arready_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [71:0]  aw_data_sysctrl_axis_ib_int;
wire   [3:0]   aw_wpntr_gry_sysctrl_axis_ib_int;
wire           awready_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [2:0]   b_rpntr_bin_sysctrl_axis_ib_int;
wire   [3:0]   b_rpntr_gry_sysctrl_axis_ib_int;
wire   [11:0]  bid_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [1:0]   bresp_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire           bvalid_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [1:0]   r_rpntr_bin_sysctrl_axis_ib_int;
wire   [2:0]   r_rpntr_gry_sysctrl_axis_ib_int;
wire   [31:0]  rdata_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [11:0]  rid_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire           rlast_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [1:0]   rresp_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire           rvalid_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire   [36:0]  w_data_sysctrl_axis_ib_int;
wire   [3:0]   w_wpntr_gry_sysctrl_axis_ib_int;
wire           wready_sysctrl_axis_sysctrl_axis_ib_axi4_s;
wire           aclk;
wire           aclken;
wire   [31:0]  araddr_sysctrl_axis;
wire   [1:0]   arburst_sysctrl_axis;
wire   [3:0]   arcache_sysctrl_axis;
wire           aresetn;
wire   [11:0]  arid_sysctrl_axis;
wire   [7:0]   arlen_sysctrl_axis;
wire           arlock_sysctrl_axis;
wire   [2:0]   arprot_sysctrl_axis;
wire   [3:0]   arqos_sysctrl_axis;
wire   [2:0]   arsize_sysctrl_axis;
wire           arvalid_sysctrl_axis;
wire   [31:0]  awaddr_sysctrl_axis;
wire   [1:0]   awburst_sysctrl_axis;
wire   [3:0]   awcache_sysctrl_axis;
wire   [11:0]  awid_sysctrl_axis;
wire   [7:0]   awlen_sysctrl_axis;
wire           awlock_sysctrl_axis;
wire   [2:0]   awprot_sysctrl_axis;
wire   [3:0]   awqos_sysctrl_axis;
wire   [2:0]   awsize_sysctrl_axis;
wire           awvalid_sysctrl_axis;
wire           bready_sysctrl_axis;
wire           csysreq_cd_a;
wire   [31:0]  prdata_sysctrl_apb;
wire   [31:0]  prdata_uart_apb;
wire           pready_sysctrl_apb;
wire           pready_uart_apb;
wire           pslverr_sysctrl_apb;
wire           pslverr_uart_apb;
wire           rready_sysctrl_axis;
wire   [31:0]  wdata_sysctrl_axis;
wire           wlast_sysctrl_axis;
wire   [3:0]   wstrb_sysctrl_axis;
wire           wvalid_sysctrl_axis;




nic400_amib_slave_2_sse710_sctrl_apb     u_amib_slave_2 (
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
  .paddr_uart_apb       (paddr_uart_apb),
  .pwdata_uart_apb      (pwdata_uart_apb),
  .pwrite_uart_apb      (pwrite_uart_apb),
  .pprot_uart_apb       (pprot_uart_apb),
  .pstrb_uart_apb       (pstrb_uart_apb),
  .penable_uart_apb     (penable_uart_apb),
  .psel_uart_apb        (pselx_uart_apb),
  .prdata_uart_apb      (prdata_uart_apb),
  .pslverr_uart_apb     (pslverr_uart_apb),
  .pready_uart_apb      (pready_uart_apb),
  .aclk                 (aclk),
  .apb_pclken           (aclken),
  .aresetn              (aresetn)
);


nic400_amib_slave_5_sse710_sctrl_apb     u_amib_slave_5 (
  .awid_slave_5_s       (awid_switch1_slave_5_slave_5_s),
  .awaddr_slave_5_s     (awaddr_switch1_slave_5_slave_5_s),
  .awlen_slave_5_s      (awlen_switch1_slave_5_slave_5_s),
  .awsize_slave_5_s     (awsize_switch1_slave_5_slave_5_s),
  .awburst_slave_5_s    (awburst_switch1_slave_5_slave_5_s),
  .awlock_slave_5_s     (awlock_switch1_slave_5_slave_5_s),
  .awcache_slave_5_s    (awcache_switch1_slave_5_slave_5_s),
  .awprot_slave_5_s     (awprot_switch1_slave_5_slave_5_s),
  .awvalid_slave_5_s    (awvalid_switch1_slave_5_slave_5_s),
  .awready_slave_5_s    (awready_switch1_slave_5_slave_5_s),
  .wdata_slave_5_s      (wdata_switch1_slave_5_slave_5_s),
  .wstrb_slave_5_s      (wstrb_switch1_slave_5_slave_5_s),
  .wlast_slave_5_s      (wlast_switch1_slave_5_slave_5_s),
  .wvalid_slave_5_s     (wvalid_switch1_slave_5_slave_5_s),
  .wready_slave_5_s     (wready_switch1_slave_5_slave_5_s),
  .bid_slave_5_s        (bid_switch1_slave_5_slave_5_s),
  .bresp_slave_5_s      (bresp_switch1_slave_5_slave_5_s),
  .bvalid_slave_5_s     (bvalid_switch1_slave_5_slave_5_s),
  .bready_slave_5_s     (bready_switch1_slave_5_slave_5_s),
  .arid_slave_5_s       (arid_switch1_slave_5_slave_5_s),
  .araddr_slave_5_s     (araddr_switch1_slave_5_slave_5_s),
  .arlen_slave_5_s      (arlen_switch1_slave_5_slave_5_s),
  .arsize_slave_5_s     (arsize_switch1_slave_5_slave_5_s),
  .arburst_slave_5_s    (arburst_switch1_slave_5_slave_5_s),
  .arlock_slave_5_s     (arlock_switch1_slave_5_slave_5_s),
  .arcache_slave_5_s    (arcache_switch1_slave_5_slave_5_s),
  .arprot_slave_5_s     (arprot_switch1_slave_5_slave_5_s),
  .arvalid_slave_5_s    (arvalid_switch1_slave_5_slave_5_s),
  .arready_slave_5_s    (arready_switch1_slave_5_slave_5_s),
  .rid_slave_5_s        (rid_switch1_slave_5_slave_5_s),
  .rdata_slave_5_s      (rdata_switch1_slave_5_slave_5_s),
  .rresp_slave_5_s      (rresp_switch1_slave_5_slave_5_s),
  .rlast_slave_5_s      (rlast_switch1_slave_5_slave_5_s),
  .rvalid_slave_5_s     (rvalid_switch1_slave_5_slave_5_s),
  .rready_slave_5_s     (rready_switch1_slave_5_slave_5_s),
  .paddr_sysctrl_apb    (paddr_sysctrl_apb),
  .pwdata_sysctrl_apb   (pwdata_sysctrl_apb),
  .pwrite_sysctrl_apb   (pwrite_sysctrl_apb),
  .pprot_sysctrl_apb    (pprot_sysctrl_apb),
  .pstrb_sysctrl_apb    (pstrb_sysctrl_apb),
  .penable_sysctrl_apb  (penable_sysctrl_apb),
  .psel_sysctrl_apb     (pselx_sysctrl_apb),
  .prdata_sysctrl_apb   (prdata_sysctrl_apb),
  .pslverr_sysctrl_apb  (pslverr_sysctrl_apb),
  .pready_sysctrl_apb   (pready_sysctrl_apb),
  .aclk                 (aclk),
  .apb_pclken           (aclken),
  .aresetn              (aresetn)
);


nic400_asib_sysctrl_axis_sse710_sctrl_apb     u_asib_sysctrl_axis (
  .sysctrl_axis_cactive (cactive_sysctrl_axis_hcg),
  .awid_sysctrl_axis_m  (awid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awaddr_sysctrl_axis_m (awaddr_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awlen_sysctrl_axis_m (awlen_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awsize_sysctrl_axis_m (awsize_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awburst_sysctrl_axis_m (awburst_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awlock_sysctrl_axis_m (awlock_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awcache_sysctrl_axis_m (awcache_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awprot_sysctrl_axis_m (awprot_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awvalid_sysctrl_axis_m (awvalid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awvalid_vect_sysctrl_axis_m (awvalid_vect_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awready_sysctrl_axis_m (awready_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .wdata_sysctrl_axis_m (wdata_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .wstrb_sysctrl_axis_m (wstrb_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .wlast_sysctrl_axis_m (wlast_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .wvalid_sysctrl_axis_m (wvalid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .wready_sysctrl_axis_m (wready_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .bid_sysctrl_axis_m   (bid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .bresp_sysctrl_axis_m (bresp_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .bvalid_sysctrl_axis_m (bvalid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .bready_sysctrl_axis_m (bready_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arid_sysctrl_axis_m  (arid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .araddr_sysctrl_axis_m (araddr_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arlen_sysctrl_axis_m (arlen_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arsize_sysctrl_axis_m (arsize_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arburst_sysctrl_axis_m (arburst_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arlock_sysctrl_axis_m (arlock_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arcache_sysctrl_axis_m (arcache_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arprot_sysctrl_axis_m (arprot_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arvalid_sysctrl_axis_m (arvalid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arvalid_vect_sysctrl_axis_m (arvalid_vect_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arready_sysctrl_axis_m (arready_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .rid_sysctrl_axis_m   (rid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .rdata_sysctrl_axis_m (rdata_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .rresp_sysctrl_axis_m (rresp_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .rlast_sysctrl_axis_m (rlast_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .rvalid_sysctrl_axis_m (rvalid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .rready_sysctrl_axis_m (rready_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awqv_sysctrl_axis_m  (awqv_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arqv_sysctrl_axis_m  (arqv_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .sysctrl_axis_port_enable (port_enable_sysctrl_axis_port_enable_hcg),
  .awid_sysctrl_axis_s  (awid_sysctrl_axis),
  .awaddr_sysctrl_axis_s (awaddr_sysctrl_axis),
  .awlen_sysctrl_axis_s (awlen_sysctrl_axis),
  .awsize_sysctrl_axis_s (awsize_sysctrl_axis),
  .awburst_sysctrl_axis_s (awburst_sysctrl_axis),
  .awlock_sysctrl_axis_s (awlock_sysctrl_axis),
  .awcache_sysctrl_axis_s (awcache_sysctrl_axis),
  .awprot_sysctrl_axis_s (awprot_sysctrl_axis),
  .awvalid_sysctrl_axis_s (awvalid_sysctrl_axis),
  .awready_sysctrl_axis_s (awready_sysctrl_axis),
  .wdata_sysctrl_axis_s (wdata_sysctrl_axis),
  .wstrb_sysctrl_axis_s (wstrb_sysctrl_axis),
  .wlast_sysctrl_axis_s (wlast_sysctrl_axis),
  .wvalid_sysctrl_axis_s (wvalid_sysctrl_axis),
  .wready_sysctrl_axis_s (wready_sysctrl_axis),
  .bid_sysctrl_axis_s   (bid_sysctrl_axis),
  .bresp_sysctrl_axis_s (bresp_sysctrl_axis),
  .bvalid_sysctrl_axis_s (bvalid_sysctrl_axis),
  .bready_sysctrl_axis_s (bready_sysctrl_axis),
  .arid_sysctrl_axis_s  (arid_sysctrl_axis),
  .araddr_sysctrl_axis_s (araddr_sysctrl_axis),
  .arlen_sysctrl_axis_s (arlen_sysctrl_axis),
  .arsize_sysctrl_axis_s (arsize_sysctrl_axis),
  .arburst_sysctrl_axis_s (arburst_sysctrl_axis),
  .arlock_sysctrl_axis_s (arlock_sysctrl_axis),
  .arcache_sysctrl_axis_s (arcache_sysctrl_axis),
  .arprot_sysctrl_axis_s (arprot_sysctrl_axis),
  .arvalid_sysctrl_axis_s (arvalid_sysctrl_axis),
  .arready_sysctrl_axis_s (arready_sysctrl_axis),
  .rid_sysctrl_axis_s   (rid_sysctrl_axis),
  .rdata_sysctrl_axis_s (rdata_sysctrl_axis),
  .rresp_sysctrl_axis_s (rresp_sysctrl_axis),
  .rlast_sysctrl_axis_s (rlast_sysctrl_axis),
  .rvalid_sysctrl_axis_s (rvalid_sysctrl_axis),
  .rready_sysctrl_axis_s (rready_sysctrl_axis),
  .awqv_sysctrl_axis_s  (awqos_sysctrl_axis),
  .arqv_sysctrl_axis_s  (arqos_sysctrl_axis),
  .sysctrl_axis_cactive_wakeup (cactive_sysctrl_axis_wakeup_hcg)
);


nic400_switch1_sse710_sctrl_apb     u_busmatrix_switch1 (
  .awid_axi_m_0         (awid_switch1_slave_5_slave_5_s),
  .awaddr_axi_m_0       (awaddr_switch1_slave_5_slave_5_s),
  .awlen_axi_m_0        (awlen_switch1_slave_5_slave_5_s),
  .awsize_axi_m_0       (awsize_switch1_slave_5_slave_5_s),
  .awburst_axi_m_0      (awburst_switch1_slave_5_slave_5_s),
  .awlock_axi_m_0       (awlock_switch1_slave_5_slave_5_s),
  .awcache_axi_m_0      (awcache_switch1_slave_5_slave_5_s),
  .awprot_axi_m_0       (awprot_switch1_slave_5_slave_5_s),
  .awvalid_axi_m_0      (awvalid_switch1_slave_5_slave_5_s),
  .awvalid_vect_axi_m_0 (),
  .awready_axi_m_0      (awready_switch1_slave_5_slave_5_s),
  .wdata_axi_m_0        (wdata_switch1_slave_5_slave_5_s),
  .wstrb_axi_m_0        (wstrb_switch1_slave_5_slave_5_s),
  .wlast_axi_m_0        (wlast_switch1_slave_5_slave_5_s),
  .wvalid_axi_m_0       (wvalid_switch1_slave_5_slave_5_s),
  .wready_axi_m_0       (wready_switch1_slave_5_slave_5_s),
  .bid_axi_m_0          (bid_switch1_slave_5_slave_5_s),
  .bresp_axi_m_0        (bresp_switch1_slave_5_slave_5_s),
  .bvalid_axi_m_0       (bvalid_switch1_slave_5_slave_5_s),
  .bready_axi_m_0       (bready_switch1_slave_5_slave_5_s),
  .arid_axi_m_0         (arid_switch1_slave_5_slave_5_s),
  .araddr_axi_m_0       (araddr_switch1_slave_5_slave_5_s),
  .arlen_axi_m_0        (arlen_switch1_slave_5_slave_5_s),
  .arsize_axi_m_0       (arsize_switch1_slave_5_slave_5_s),
  .arburst_axi_m_0      (arburst_switch1_slave_5_slave_5_s),
  .arlock_axi_m_0       (arlock_switch1_slave_5_slave_5_s),
  .arcache_axi_m_0      (arcache_switch1_slave_5_slave_5_s),
  .arprot_axi_m_0       (arprot_switch1_slave_5_slave_5_s),
  .arvalid_axi_m_0      (arvalid_switch1_slave_5_slave_5_s),
  .arvalid_vect_axi_m_0 (),
  .arready_axi_m_0      (arready_switch1_slave_5_slave_5_s),
  .rid_axi_m_0          (rid_switch1_slave_5_slave_5_s),
  .rdata_axi_m_0        (rdata_switch1_slave_5_slave_5_s),
  .rresp_axi_m_0        (rresp_switch1_slave_5_slave_5_s),
  .rlast_axi_m_0        (rlast_switch1_slave_5_slave_5_s),
  .rvalid_axi_m_0       (rvalid_switch1_slave_5_slave_5_s),
  .rready_axi_m_0       (rready_switch1_slave_5_slave_5_s),
  .aw_qv_axi_m_0        (),
  .ar_qv_axi_m_0        (),
  .awid_axi_m_1         (awid_switch1_ds_0_axi_s_0),
  .awaddr_axi_m_1       (),
  .awlen_axi_m_1        (),
  .awsize_axi_m_1       (),
  .awburst_axi_m_1      (),
  .awlock_axi_m_1       (),
  .awcache_axi_m_1      (),
  .awprot_axi_m_1       (),
  .awvalid_axi_m_1      (awvalid_switch1_ds_0_axi_s_0),
  .awvalid_vect_axi_m_1 (),
  .awready_axi_m_1      (awready_switch1_ds_0_axi_s_0),
  .wdata_axi_m_1        (),
  .wstrb_axi_m_1        (),
  .wlast_axi_m_1        (wlast_switch1_ds_0_axi_s_0),
  .wvalid_axi_m_1       (wvalid_switch1_ds_0_axi_s_0),
  .wready_axi_m_1       (wready_switch1_ds_0_axi_s_0),
  .bid_axi_m_1          (bid_switch1_ds_0_axi_s_0),
  .bresp_axi_m_1        (bresp_switch1_ds_0_axi_s_0),
  .bvalid_axi_m_1       (bvalid_switch1_ds_0_axi_s_0),
  .bready_axi_m_1       (bready_switch1_ds_0_axi_s_0),
  .arid_axi_m_1         (arid_switch1_ds_0_axi_s_0),
  .araddr_axi_m_1       (),
  .arlen_axi_m_1        (arlen_switch1_ds_0_axi_s_0),
  .arsize_axi_m_1       (),
  .arburst_axi_m_1      (),
  .arlock_axi_m_1       (),
  .arcache_axi_m_1      (),
  .arprot_axi_m_1       (),
  .arvalid_axi_m_1      (arvalid_switch1_ds_0_axi_s_0),
  .arvalid_vect_axi_m_1 (),
  .arready_axi_m_1      (arready_switch1_ds_0_axi_s_0),
  .rid_axi_m_1          (rid_switch1_ds_0_axi_s_0),
  .rdata_axi_m_1        (32'b0),
  .rresp_axi_m_1        (rresp_switch1_ds_0_axi_s_0),
  .rlast_axi_m_1        (rlast_switch1_ds_0_axi_s_0),
  .rvalid_axi_m_1       (rvalid_switch1_ds_0_axi_s_0),
  .rready_axi_m_1       (rready_switch1_ds_0_axi_s_0),
  .aw_qv_axi_m_1        (),
  .ar_qv_axi_m_1        (),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .awid_axi_m_2         (awid_switch1_slave_2_slave_2_s),
  .awaddr_axi_m_2       (awaddr_switch1_slave_2_slave_2_s),
  .awlen_axi_m_2        (awlen_switch1_slave_2_slave_2_s),
  .awsize_axi_m_2       (awsize_switch1_slave_2_slave_2_s),
  .awburst_axi_m_2      (awburst_switch1_slave_2_slave_2_s),
  .awlock_axi_m_2       (awlock_switch1_slave_2_slave_2_s),
  .awcache_axi_m_2      (awcache_switch1_slave_2_slave_2_s),
  .awprot_axi_m_2       (awprot_switch1_slave_2_slave_2_s),
  .awvalid_axi_m_2      (awvalid_switch1_slave_2_slave_2_s),
  .awvalid_vect_axi_m_2 (),
  .awready_axi_m_2      (awready_switch1_slave_2_slave_2_s),
  .wdata_axi_m_2        (wdata_switch1_slave_2_slave_2_s),
  .wstrb_axi_m_2        (wstrb_switch1_slave_2_slave_2_s),
  .wlast_axi_m_2        (wlast_switch1_slave_2_slave_2_s),
  .wvalid_axi_m_2       (wvalid_switch1_slave_2_slave_2_s),
  .wready_axi_m_2       (wready_switch1_slave_2_slave_2_s),
  .bid_axi_m_2          (bid_switch1_slave_2_slave_2_s),
  .bresp_axi_m_2        (bresp_switch1_slave_2_slave_2_s),
  .bvalid_axi_m_2       (bvalid_switch1_slave_2_slave_2_s),
  .bready_axi_m_2       (bready_switch1_slave_2_slave_2_s),
  .arid_axi_m_2         (arid_switch1_slave_2_slave_2_s),
  .araddr_axi_m_2       (araddr_switch1_slave_2_slave_2_s),
  .arlen_axi_m_2        (arlen_switch1_slave_2_slave_2_s),
  .arsize_axi_m_2       (arsize_switch1_slave_2_slave_2_s),
  .arburst_axi_m_2      (arburst_switch1_slave_2_slave_2_s),
  .arlock_axi_m_2       (arlock_switch1_slave_2_slave_2_s),
  .arcache_axi_m_2      (arcache_switch1_slave_2_slave_2_s),
  .arprot_axi_m_2       (arprot_switch1_slave_2_slave_2_s),
  .arvalid_axi_m_2      (arvalid_switch1_slave_2_slave_2_s),
  .arvalid_vect_axi_m_2 (),
  .arready_axi_m_2      (arready_switch1_slave_2_slave_2_s),
  .rid_axi_m_2          (rid_switch1_slave_2_slave_2_s),
  .rdata_axi_m_2        (rdata_switch1_slave_2_slave_2_s),
  .rresp_axi_m_2        (rresp_switch1_slave_2_slave_2_s),
  .rlast_axi_m_2        (rlast_switch1_slave_2_slave_2_s),
  .rvalid_axi_m_2       (rvalid_switch1_slave_2_slave_2_s),
  .rready_axi_m_2       (rready_switch1_slave_2_slave_2_s),
  .aw_qv_axi_m_2        (),
  .ar_qv_axi_m_2        (),
  .awid_axi_s_0         (awid_sysctrl_axis_ib_switch1_axi_s_0),
  .awaddr_axi_s_0       (awaddr_sysctrl_axis_ib_switch1_axi_s_0),
  .awlen_axi_s_0        (awlen_sysctrl_axis_ib_switch1_axi_s_0),
  .awsize_axi_s_0       (awsize_sysctrl_axis_ib_switch1_axi_s_0),
  .awburst_axi_s_0      (awburst_sysctrl_axis_ib_switch1_axi_s_0),
  .awlock_axi_s_0       (awlock_sysctrl_axis_ib_switch1_axi_s_0),
  .awcache_axi_s_0      (awcache_sysctrl_axis_ib_switch1_axi_s_0),
  .awprot_axi_s_0       (awprot_sysctrl_axis_ib_switch1_axi_s_0),
  .awvalid_axi_s_0      (awvalid_sysctrl_axis_ib_switch1_axi_s_0),
  .awvalid_vect_axi_s_0 (awvalid_vect_sysctrl_axis_ib_switch1_axi_s_0),
  .awready_axi_s_0      (awready_sysctrl_axis_ib_switch1_axi_s_0),
  .wdata_axi_s_0        (wdata_sysctrl_axis_ib_switch1_axi_s_0),
  .wstrb_axi_s_0        (wstrb_sysctrl_axis_ib_switch1_axi_s_0),
  .wlast_axi_s_0        (wlast_sysctrl_axis_ib_switch1_axi_s_0),
  .wvalid_axi_s_0       (wvalid_sysctrl_axis_ib_switch1_axi_s_0),
  .wready_axi_s_0       (wready_sysctrl_axis_ib_switch1_axi_s_0),
  .bid_axi_s_0          (bid_sysctrl_axis_ib_switch1_axi_s_0),
  .bresp_axi_s_0        (bresp_sysctrl_axis_ib_switch1_axi_s_0),
  .bvalid_axi_s_0       (bvalid_sysctrl_axis_ib_switch1_axi_s_0),
  .bready_axi_s_0       (bready_sysctrl_axis_ib_switch1_axi_s_0),
  .arid_axi_s_0         (arid_sysctrl_axis_ib_switch1_axi_s_0),
  .araddr_axi_s_0       (araddr_sysctrl_axis_ib_switch1_axi_s_0),
  .arlen_axi_s_0        (arlen_sysctrl_axis_ib_switch1_axi_s_0),
  .arsize_axi_s_0       (arsize_sysctrl_axis_ib_switch1_axi_s_0),
  .arburst_axi_s_0      (arburst_sysctrl_axis_ib_switch1_axi_s_0),
  .arlock_axi_s_0       (arlock_sysctrl_axis_ib_switch1_axi_s_0),
  .arcache_axi_s_0      (arcache_sysctrl_axis_ib_switch1_axi_s_0),
  .arprot_axi_s_0       (arprot_sysctrl_axis_ib_switch1_axi_s_0),
  .arvalid_axi_s_0      (arvalid_sysctrl_axis_ib_switch1_axi_s_0),
  .arvalid_vect_axi_s_0 (arvalid_vect_sysctrl_axis_ib_switch1_axi_s_0),
  .arready_axi_s_0      (arready_sysctrl_axis_ib_switch1_axi_s_0),
  .rid_axi_s_0          (rid_sysctrl_axis_ib_switch1_axi_s_0),
  .rdata_axi_s_0        (rdata_sysctrl_axis_ib_switch1_axi_s_0),
  .rresp_axi_s_0        (rresp_sysctrl_axis_ib_switch1_axi_s_0),
  .rlast_axi_s_0        (rlast_sysctrl_axis_ib_switch1_axi_s_0),
  .rvalid_axi_s_0       (rvalid_sysctrl_axis_ib_switch1_axi_s_0),
  .rready_axi_s_0       (rready_sysctrl_axis_ib_switch1_axi_s_0),
  .aw_qv_axi_s_0        (awqv_sysctrl_axis_ib_switch1_axi_s_0),
  .ar_qv_axi_s_0        (arqv_sysctrl_axis_ib_switch1_axi_s_0)
);


nic400_default_slave_ds_0_sse710_sctrl_apb     u_default_slave_ds_0 (
  .awid                 (awid_switch1_ds_0_axi_s_0),
  .awvalid              (awvalid_switch1_ds_0_axi_s_0),
  .awready              (awready_switch1_ds_0_axi_s_0),
  .wlast                (wlast_switch1_ds_0_axi_s_0),
  .wvalid               (wvalid_switch1_ds_0_axi_s_0),
  .wready               (wready_switch1_ds_0_axi_s_0),
  .bid                  (bid_switch1_ds_0_axi_s_0),
  .bresp                (bresp_switch1_ds_0_axi_s_0),
  .bvalid               (bvalid_switch1_ds_0_axi_s_0),
  .bready               (bready_switch1_ds_0_axi_s_0),
  .arid                 (arid_switch1_ds_0_axi_s_0),
  .arlen                (arlen_switch1_ds_0_axi_s_0),
  .arvalid              (arvalid_switch1_ds_0_axi_s_0),
  .arready              (arready_switch1_ds_0_axi_s_0),
  .rid                  (rid_switch1_ds_0_axi_s_0),
  .rresp                (rresp_switch1_ds_0_axi_s_0),
  .rlast                (rlast_switch1_ds_0_axi_s_0),
  .rvalid               (rvalid_switch1_ds_0_axi_s_0),
  .rready               (rready_switch1_ds_0_axi_s_0),
  .aclk                 (aclk),
  .aresetn              (aresetn)
);


nic400_dmu_a_sse710_sctrl_apb     u_dmu_a_sse710_sctrl_apb (
  .cd_a_clk             (aclk),
  .cd_a_resetn          (aresetn),
  .cd_a_cactive         (cactive_cd_a),
  .cd_a_csysreq         (csysreq_cd_a),
  .cd_a_csysack         (csysack_cd_a),
  .sysctrl_axis_cactive (cactive_sysctrl_axis_hcg),
  .sysctrl_axis_port_enable (port_enable_sysctrl_axis_port_enable_hcg),
  .sysctrl_axis_cactive_wakeup (cactive_sysctrl_axis_wakeup_hcg)
);


nic400_ib_sysctrl_axis_ib_master_domain_sse710_sctrl_apb     u_ib_sysctrl_axis_ib_m (
  .awid_axi4_m          (awid_sysctrl_axis_ib_switch1_axi_s_0),
  .awaddr_axi4_m        (awaddr_sysctrl_axis_ib_switch1_axi_s_0),
  .awlen_axi4_m         (awlen_sysctrl_axis_ib_switch1_axi_s_0),
  .awsize_axi4_m        (awsize_sysctrl_axis_ib_switch1_axi_s_0),
  .awburst_axi4_m       (awburst_sysctrl_axis_ib_switch1_axi_s_0),
  .awlock_axi4_m        (awlock_sysctrl_axis_ib_switch1_axi_s_0),
  .awcache_axi4_m       (awcache_sysctrl_axis_ib_switch1_axi_s_0),
  .awprot_axi4_m        (awprot_sysctrl_axis_ib_switch1_axi_s_0),
  .awvalid_axi4_m       (awvalid_sysctrl_axis_ib_switch1_axi_s_0),
  .awvalid_vect_axi4_m  (awvalid_vect_sysctrl_axis_ib_switch1_axi_s_0),
  .awready_axi4_m       (awready_sysctrl_axis_ib_switch1_axi_s_0),
  .wdata_axi4_m         (wdata_sysctrl_axis_ib_switch1_axi_s_0),
  .wstrb_axi4_m         (wstrb_sysctrl_axis_ib_switch1_axi_s_0),
  .wlast_axi4_m         (wlast_sysctrl_axis_ib_switch1_axi_s_0),
  .wvalid_axi4_m        (wvalid_sysctrl_axis_ib_switch1_axi_s_0),
  .wready_axi4_m        (wready_sysctrl_axis_ib_switch1_axi_s_0),
  .bid_axi4_m           (bid_sysctrl_axis_ib_switch1_axi_s_0),
  .bresp_axi4_m         (bresp_sysctrl_axis_ib_switch1_axi_s_0),
  .bvalid_axi4_m        (bvalid_sysctrl_axis_ib_switch1_axi_s_0),
  .bready_axi4_m        (bready_sysctrl_axis_ib_switch1_axi_s_0),
  .arid_axi4_m          (arid_sysctrl_axis_ib_switch1_axi_s_0),
  .araddr_axi4_m        (araddr_sysctrl_axis_ib_switch1_axi_s_0),
  .arlen_axi4_m         (arlen_sysctrl_axis_ib_switch1_axi_s_0),
  .arsize_axi4_m        (arsize_sysctrl_axis_ib_switch1_axi_s_0),
  .arburst_axi4_m       (arburst_sysctrl_axis_ib_switch1_axi_s_0),
  .arlock_axi4_m        (arlock_sysctrl_axis_ib_switch1_axi_s_0),
  .arcache_axi4_m       (arcache_sysctrl_axis_ib_switch1_axi_s_0),
  .arprot_axi4_m        (arprot_sysctrl_axis_ib_switch1_axi_s_0),
  .arvalid_axi4_m       (arvalid_sysctrl_axis_ib_switch1_axi_s_0),
  .arvalid_vect_axi4_m  (arvalid_vect_sysctrl_axis_ib_switch1_axi_s_0),
  .arready_axi4_m       (arready_sysctrl_axis_ib_switch1_axi_s_0),
  .rid_axi4_m           (rid_sysctrl_axis_ib_switch1_axi_s_0),
  .rdata_axi4_m         (rdata_sysctrl_axis_ib_switch1_axi_s_0),
  .rresp_axi4_m         (rresp_sysctrl_axis_ib_switch1_axi_s_0),
  .rlast_axi4_m         (rlast_sysctrl_axis_ib_switch1_axi_s_0),
  .rvalid_axi4_m        (rvalid_sysctrl_axis_ib_switch1_axi_s_0),
  .rready_axi4_m        (rready_sysctrl_axis_ib_switch1_axi_s_0),
  .awqv_axi4_m          (awqv_sysctrl_axis_ib_switch1_axi_s_0),
  .arqv_axi4_m          (arqv_sysctrl_axis_ib_switch1_axi_s_0),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_sysctrl_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_sysctrl_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_sysctrl_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_sysctrl_axis_ib_int),
  .b_data               (b_data_sysctrl_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_sysctrl_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_sysctrl_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_sysctrl_axis_ib_int),
  .ar_data              (ar_data_sysctrl_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_sysctrl_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_sysctrl_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_sysctrl_axis_ib_int),
  .r_data               (r_data_sysctrl_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_sysctrl_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_sysctrl_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_sysctrl_axis_ib_int),
  .w_data               (w_data_sysctrl_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_sysctrl_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_sysctrl_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_sysctrl_axis_ib_int)
);


nic400_ib_sysctrl_axis_ib_slave_domain_sse710_sctrl_apb     u_ib_sysctrl_axis_ib_s (
  .awid_axi4_s          (awid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awaddr_axi4_s        (awaddr_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awlen_axi4_s         (awlen_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awsize_axi4_s        (awsize_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awburst_axi4_s       (awburst_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awlock_axi4_s        (awlock_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awcache_axi4_s       (awcache_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awprot_axi4_s        (awprot_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awvalid_axi4_s       (awvalid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awvalid_vect_axi4_s  (awvalid_vect_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awready_axi4_s       (awready_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .wdata_axi4_s         (wdata_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .wstrb_axi4_s         (wstrb_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .wlast_axi4_s         (wlast_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .wvalid_axi4_s        (wvalid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .wready_axi4_s        (wready_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .bid_axi4_s           (bid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .bresp_axi4_s         (bresp_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .bvalid_axi4_s        (bvalid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .bready_axi4_s        (bready_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arid_axi4_s          (arid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .araddr_axi4_s        (araddr_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arlen_axi4_s         (arlen_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arsize_axi4_s        (arsize_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arburst_axi4_s       (arburst_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arlock_axi4_s        (arlock_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arcache_axi4_s       (arcache_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arprot_axi4_s        (arprot_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arvalid_axi4_s       (arvalid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arvalid_vect_axi4_s  (arvalid_vect_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arready_axi4_s       (arready_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .rid_axi4_s           (rid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .rdata_axi4_s         (rdata_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .rresp_axi4_s         (rresp_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .rlast_axi4_s         (rlast_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .rvalid_axi4_s        (rvalid_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .rready_axi4_s        (rready_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .awqv_axi4_s          (awqv_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .arqv_axi4_s          (arqv_sysctrl_axis_sysctrl_axis_ib_axi4_s),
  .aclk                 (aclk),
  .aresetn              (aresetn),
  .aw_data              (aw_data_sysctrl_axis_ib_int),
  .aw_rpntr_gry         (aw_rpntr_gry_sysctrl_axis_ib_int),
  .aw_rpntr_bin         (aw_rpntr_bin_sysctrl_axis_ib_int),
  .aw_wpntr_gry         (aw_wpntr_gry_sysctrl_axis_ib_int),
  .b_data               (b_data_sysctrl_axis_ib_int),
  .b_rpntr_gry          (b_rpntr_gry_sysctrl_axis_ib_int),
  .b_rpntr_bin          (b_rpntr_bin_sysctrl_axis_ib_int),
  .b_wpntr_gry          (b_wpntr_gry_sysctrl_axis_ib_int),
  .ar_data              (ar_data_sysctrl_axis_ib_int),
  .ar_rpntr_gry         (ar_rpntr_gry_sysctrl_axis_ib_int),
  .ar_rpntr_bin         (ar_rpntr_bin_sysctrl_axis_ib_int),
  .ar_wpntr_gry         (ar_wpntr_gry_sysctrl_axis_ib_int),
  .r_data               (r_data_sysctrl_axis_ib_int),
  .r_rpntr_gry          (r_rpntr_gry_sysctrl_axis_ib_int),
  .r_rpntr_bin          (r_rpntr_bin_sysctrl_axis_ib_int),
  .r_wpntr_gry          (r_wpntr_gry_sysctrl_axis_ib_int),
  .w_data               (w_data_sysctrl_axis_ib_int),
  .w_rpntr_gry          (w_rpntr_gry_sysctrl_axis_ib_int),
  .w_rpntr_bin          (w_rpntr_bin_sysctrl_axis_ib_int),
  .w_wpntr_gry          (w_wpntr_gry_sysctrl_axis_ib_int)
);



endmodule
