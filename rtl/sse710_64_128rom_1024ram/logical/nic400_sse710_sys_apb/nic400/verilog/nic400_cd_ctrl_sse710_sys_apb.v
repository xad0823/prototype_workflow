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




module nic400_cd_ctrl_sse710_sys_apb (
  

  paddr_ppu_cpu_apb,
  pwdata_ppu_cpu_apb,
  pwrite_ppu_cpu_apb,
  pprot_ppu_cpu_apb,
  pstrb_ppu_cpu_apb,
  penable_ppu_cpu_apb,
  pselx_ppu_cpu_apb,
  prdata_ppu_cpu_apb,
  pslverr_ppu_cpu_apb,
  pready_ppu_cpu_apb,
  

  cactive_cd_ctrl,
  csysreq_cd_ctrl,
  csysack_cd_ctrl,
  

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


  ctrlclk,
  ctrlclken,
  ctrlresetn

);






output [31:0] paddr_ppu_cpu_apb;
output [31:0] pwdata_ppu_cpu_apb;
output        pwrite_ppu_cpu_apb;
output [2:0]  pprot_ppu_cpu_apb;
output [3:0]  pstrb_ppu_cpu_apb;
output        penable_ppu_cpu_apb;
output        pselx_ppu_cpu_apb;
input  [31:0] prdata_ppu_cpu_apb;
input         pslverr_ppu_cpu_apb;
input         pready_ppu_cpu_apb;


output        cactive_cd_ctrl;
input         csysreq_cd_ctrl;
output        csysack_cd_ctrl;


input  [69:0] a_data_slave_9_ib_int_async;
output [1:0]  a_rpntr_gry_slave_9_ib_int_async;
output        a_rpntr_bin_slave_9_ib_int_async;
input  [1:0]  a_wpntr_gry_slave_9_ib_int_async;
output [47:0] d_data_slave_9_ib_int_async;
input  [1:0]  d_rpntr_gry_slave_9_ib_int_async;
input         d_rpntr_bin_slave_9_ib_int_async;
output [1:0]  d_wpntr_gry_slave_9_ib_int_async;
input  [36:0] w_data_slave_9_ib_int_async;
output [1:0]  w_rpntr_gry_slave_9_ib_int_async;
output        w_rpntr_bin_slave_9_ib_int_async;
input  [1:0]  w_wpntr_gry_slave_9_ib_int_async;
input         empty_slave_9_ib_int_async;


input         ctrlclk;
input         ctrlclken;
input         ctrlresetn;




wire           a_rpntr_bin_slave_9_ib_int_async;
wire   [1:0]   a_rpntr_gry_slave_9_ib_int_async;
wire           cactive_cd_ctrl;
wire           csysack_cd_ctrl;
wire   [47:0]  d_data_slave_9_ib_int_async;
wire   [1:0]   d_wpntr_gry_slave_9_ib_int_async;
wire   [31:0]  paddr_ppu_cpu_apb;
wire           penable_ppu_cpu_apb;
wire   [2:0]   pprot_ppu_cpu_apb;
wire           pselx_ppu_cpu_apb;
wire   [3:0]   pstrb_ppu_cpu_apb;
wire   [31:0]  pwdata_ppu_cpu_apb;
wire           pwrite_ppu_cpu_apb;
wire           w_rpntr_bin_slave_9_ib_int_async;
wire   [1:0]   w_rpntr_gry_slave_9_ib_int_async;
wire           aready_slave_9_ib_slave_9_slave_9_s;
wire           dbnr_slave_9_ib_slave_9_slave_9_s;
wire   [31:0]  ddata_slave_9_ib_slave_9_slave_9_s;
wire   [11:0]  did_slave_9_ib_slave_9_slave_9_s;
wire           dlast_slave_9_ib_slave_9_slave_9_s;
wire   [1:0]   dresp_slave_9_ib_slave_9_slave_9_s;
wire           dvalid_slave_9_ib_slave_9_slave_9_s;
wire           wready_slave_9_ib_slave_9_slave_9_s;
wire           port_enable_slave_9_ib_port_enable_hcg;
wire   [31:0]  aaddr_slave_9_ib_slave_9_slave_9_s;
wire   [1:0]   aburst_slave_9_ib_slave_9_slave_9_s;
wire   [3:0]   acache_slave_9_ib_slave_9_slave_9_s;
wire   [11:0]  aid_slave_9_ib_slave_9_slave_9_s;
wire   [7:0]   alen_slave_9_ib_slave_9_slave_9_s;
wire           alock_slave_9_ib_slave_9_slave_9_s;
wire   [2:0]   aprot_slave_9_ib_slave_9_slave_9_s;
wire   [2:0]   asize_slave_9_ib_slave_9_slave_9_s;
wire           avalid_slave_9_ib_slave_9_slave_9_s;
wire           awrite_slave_9_ib_slave_9_slave_9_s;
wire           dready_slave_9_ib_slave_9_slave_9_s;
wire           cactive_slave_9_ib_hcg;
wire           cactive_slave_9_ib_wakeup_hcg;
wire   [31:0]  wdata_slave_9_ib_slave_9_slave_9_s;
wire           wlast_slave_9_ib_slave_9_slave_9_s;
wire   [3:0]   wstrb_slave_9_ib_slave_9_slave_9_s;
wire           wvalid_slave_9_ib_slave_9_slave_9_s;
wire   [69:0]  a_data_slave_9_ib_int_async;
wire   [1:0]   a_wpntr_gry_slave_9_ib_int_async;
wire           csysreq_cd_ctrl;
wire           ctrlclk;
wire           ctrlclken;
wire           ctrlresetn;
wire           d_rpntr_bin_slave_9_ib_int_async;
wire   [1:0]   d_rpntr_gry_slave_9_ib_int_async;
wire           empty_slave_9_ib_int_async;
wire   [31:0]  prdata_ppu_cpu_apb;
wire           pready_ppu_cpu_apb;
wire           pslverr_ppu_cpu_apb;
wire   [36:0]  w_data_slave_9_ib_int_async;
wire   [1:0]   w_wpntr_gry_slave_9_ib_int_async;




nic400_amib_slave_9_sse710_sys_apb     u_amib_slave_9 (
  .paddr_ppu_cpu_apb    (paddr_ppu_cpu_apb),
  .pwdata_ppu_cpu_apb   (pwdata_ppu_cpu_apb),
  .pwrite_ppu_cpu_apb   (pwrite_ppu_cpu_apb),
  .pprot_ppu_cpu_apb    (pprot_ppu_cpu_apb),
  .pstrb_ppu_cpu_apb    (pstrb_ppu_cpu_apb),
  .penable_ppu_cpu_apb  (penable_ppu_cpu_apb),
  .psel_ppu_cpu_apb     (pselx_ppu_cpu_apb),
  .prdata_ppu_cpu_apb   (prdata_ppu_cpu_apb),
  .pslverr_ppu_cpu_apb  (pslverr_ppu_cpu_apb),
  .pready_ppu_cpu_apb   (pready_ppu_cpu_apb),
  .apb_pclken           (ctrlclken),
  .aid_slave_9_s        (aid_slave_9_ib_slave_9_slave_9_s),
  .aaddr_slave_9_s      (aaddr_slave_9_ib_slave_9_slave_9_s),
  .alen_slave_9_s       (alen_slave_9_ib_slave_9_slave_9_s),
  .asize_slave_9_s      (asize_slave_9_ib_slave_9_slave_9_s),
  .aburst_slave_9_s     (aburst_slave_9_ib_slave_9_slave_9_s),
  .alock_slave_9_s      (alock_slave_9_ib_slave_9_slave_9_s),
  .acache_slave_9_s     (acache_slave_9_ib_slave_9_slave_9_s),
  .aprot_slave_9_s      (aprot_slave_9_ib_slave_9_slave_9_s),
  .awrite_slave_9_s     (awrite_slave_9_ib_slave_9_slave_9_s),
  .avalid_slave_9_s     (avalid_slave_9_ib_slave_9_slave_9_s),
  .aready_slave_9_s     (aready_slave_9_ib_slave_9_slave_9_s),
  .wdata_slave_9_s      (wdata_slave_9_ib_slave_9_slave_9_s),
  .wstrb_slave_9_s      (wstrb_slave_9_ib_slave_9_slave_9_s),
  .wlast_slave_9_s      (wlast_slave_9_ib_slave_9_slave_9_s),
  .wvalid_slave_9_s     (wvalid_slave_9_ib_slave_9_slave_9_s),
  .wready_slave_9_s     (wready_slave_9_ib_slave_9_slave_9_s),
  .did_slave_9_s        (did_slave_9_ib_slave_9_slave_9_s),
  .ddata_slave_9_s      (ddata_slave_9_ib_slave_9_slave_9_s),
  .dresp_slave_9_s      (dresp_slave_9_ib_slave_9_slave_9_s),
  .dlast_slave_9_s      (dlast_slave_9_ib_slave_9_slave_9_s),
  .dbnr_slave_9_s       (dbnr_slave_9_ib_slave_9_slave_9_s),
  .dvalid_slave_9_s     (dvalid_slave_9_ib_slave_9_slave_9_s),
  .dready_slave_9_s     (dready_slave_9_ib_slave_9_slave_9_s),
  .aclk                 (ctrlclk),
  .aresetn              (ctrlresetn)
);


nic400_dmu_ctrl_sse710_sys_apb     u_dmu_ctrl_sse710_sys_apb (
  .cd_ctrl_clk          (ctrlclk),
  .cd_ctrl_resetn       (ctrlresetn),
  .cd_ctrl_cactive      (cactive_cd_ctrl),
  .cd_ctrl_csysreq      (csysreq_cd_ctrl),
  .cd_ctrl_csysack      (csysack_cd_ctrl),
  .slave_9_ib_cactive   (cactive_slave_9_ib_hcg),
  .slave_9_ib_port_enable (port_enable_slave_9_ib_port_enable_hcg),
  .slave_9_ib_cactive_wakeup (cactive_slave_9_ib_wakeup_hcg)
);


nic400_ib_slave_9_ib_master_domain_sse710_sys_apb     u_ib_slave_9_ib_m (
  .aid_itb_m            (aid_slave_9_ib_slave_9_slave_9_s),
  .aaddr_itb_m          (aaddr_slave_9_ib_slave_9_slave_9_s),
  .alen_itb_m           (alen_slave_9_ib_slave_9_slave_9_s),
  .asize_itb_m          (asize_slave_9_ib_slave_9_slave_9_s),
  .aburst_itb_m         (aburst_slave_9_ib_slave_9_slave_9_s),
  .alock_itb_m          (alock_slave_9_ib_slave_9_slave_9_s),
  .acache_itb_m         (acache_slave_9_ib_slave_9_slave_9_s),
  .aprot_itb_m          (aprot_slave_9_ib_slave_9_slave_9_s),
  .awrite_itb_m         (awrite_slave_9_ib_slave_9_slave_9_s),
  .avalid_itb_m         (avalid_slave_9_ib_slave_9_slave_9_s),
  .aregion_itb_m        (),
  .aready_itb_m         (aready_slave_9_ib_slave_9_slave_9_s),
  .wdata_itb_m          (wdata_slave_9_ib_slave_9_slave_9_s),
  .wstrb_itb_m          (wstrb_slave_9_ib_slave_9_slave_9_s),
  .wlast_itb_m          (wlast_slave_9_ib_slave_9_slave_9_s),
  .wvalid_itb_m         (wvalid_slave_9_ib_slave_9_slave_9_s),
  .wready_itb_m         (wready_slave_9_ib_slave_9_slave_9_s),
  .did_itb_m            (did_slave_9_ib_slave_9_slave_9_s),
  .ddata_itb_m          (ddata_slave_9_ib_slave_9_slave_9_s),
  .dresp_itb_m          (dresp_slave_9_ib_slave_9_slave_9_s),
  .dlast_itb_m          (dlast_slave_9_ib_slave_9_slave_9_s),
  .dbnr_itb_m           (dbnr_slave_9_ib_slave_9_slave_9_s),
  .dvalid_itb_m         (dvalid_slave_9_ib_slave_9_slave_9_s),
  .dready_itb_m         (dready_slave_9_ib_slave_9_slave_9_s),
  .aclk_m               (ctrlclk),
  .aresetn_m            (ctrlresetn),
  .slave_9_ib_cactive   (cactive_slave_9_ib_hcg),
  .slave_9_ib_port_enable (port_enable_slave_9_ib_port_enable_hcg),
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
  .empty_async          (empty_slave_9_ib_int_async),
  .slave_9_ib_cactive_wakeup (cactive_slave_9_ib_wakeup_hcg)
);



endmodule
