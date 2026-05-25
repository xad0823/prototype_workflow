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




module nic400_cd_clk1_sse710_boot_reg (
  

  paddr_master_if0,
  pwdata_master_if0,
  pwrite_master_if0,
  pprot_master_if0,
  pstrb_master_if0,
  penable_master_if0,
  pselx_master_if0,
  prdata_master_if0,
  pslverr_master_if0,
  pready_master_if0,
  

  cactive_cd_clk1,
  csysreq_cd_clk1,
  csysack_cd_clk1,
  

  a_data_slave_if0_0_m_ib_int_async,
  a_rpntr_gry_slave_if0_0_m_ib_int_async,
  a_rpntr_bin_slave_if0_0_m_ib_int_async,
  a_wpntr_gry_slave_if0_0_m_ib_int_async,
  d_data_slave_if0_0_m_ib_int_async,
  d_rpntr_gry_slave_if0_0_m_ib_int_async,
  d_rpntr_bin_slave_if0_0_m_ib_int_async,
  d_wpntr_gry_slave_if0_0_m_ib_int_async,
  w_data_slave_if0_0_m_ib_int_async,
  w_rpntr_gry_slave_if0_0_m_ib_int_async,
  w_rpntr_bin_slave_if0_0_m_ib_int_async,
  w_wpntr_gry_slave_if0_0_m_ib_int_async,
  empty_slave_if0_0_m_ib_int_async,


  clk1clk,
  clk1clken,
  clk1resetn

);






output [31:0] paddr_master_if0;
output [31:0] pwdata_master_if0;
output        pwrite_master_if0;
output [2:0]  pprot_master_if0;
output [3:0]  pstrb_master_if0;
output        penable_master_if0;
output        pselx_master_if0;
input  [31:0] prdata_master_if0;
input         pslverr_master_if0;
input         pready_master_if0;


output        cactive_cd_clk1;
input         csysreq_cd_clk1;
output        csysack_cd_clk1;


input  [63:0] a_data_slave_if0_0_m_ib_int_async;
output [1:0]  a_rpntr_gry_slave_if0_0_m_ib_int_async;
output        a_rpntr_bin_slave_if0_0_m_ib_int_async;
input  [1:0]  a_wpntr_gry_slave_if0_0_m_ib_int_async;
output [45:0] d_data_slave_if0_0_m_ib_int_async;
input  [1:0]  d_rpntr_gry_slave_if0_0_m_ib_int_async;
input         d_rpntr_bin_slave_if0_0_m_ib_int_async;
output [1:0]  d_wpntr_gry_slave_if0_0_m_ib_int_async;
input  [36:0] w_data_slave_if0_0_m_ib_int_async;
output [1:0]  w_rpntr_gry_slave_if0_0_m_ib_int_async;
output        w_rpntr_bin_slave_if0_0_m_ib_int_async;
input  [1:0]  w_wpntr_gry_slave_if0_0_m_ib_int_async;
input         empty_slave_if0_0_m_ib_int_async;


input         clk1clk;
input         clk1clken;
input         clk1resetn;




wire           a_rpntr_bin_slave_if0_0_m_ib_int_async;
wire   [1:0]   a_rpntr_gry_slave_if0_0_m_ib_int_async;
wire           cactive_cd_clk1;
wire           csysack_cd_clk1;
wire   [45:0]  d_data_slave_if0_0_m_ib_int_async;
wire   [1:0]   d_wpntr_gry_slave_if0_0_m_ib_int_async;
wire   [31:0]  paddr_master_if0;
wire           penable_master_if0;
wire   [2:0]   pprot_master_if0;
wire           pselx_master_if0;
wire   [3:0]   pstrb_master_if0;
wire   [31:0]  pwdata_master_if0;
wire           pwrite_master_if0;
wire           w_rpntr_bin_slave_if0_0_m_ib_int_async;
wire   [1:0]   w_rpntr_gry_slave_if0_0_m_ib_int_async;
wire           aready_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire           dbnr_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire   [31:0]  ddata_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire   [9:0]   did_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire           dlast_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire   [1:0]   dresp_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire           dvalid_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire           wready_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire           port_enable_slave_if0_0_m_ib_port_enable_hcg;
wire   [31:0]  aaddr_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire   [1:0]   aburst_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire   [3:0]   acache_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire   [9:0]   aid_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire   [7:0]   alen_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire           alock_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire   [2:0]   aprot_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire   [2:0]   asize_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire           avalid_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire           awrite_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire           dready_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire           cactive_slave_if0_0_m_ib_hcg;
wire           cactive_slave_if0_0_m_ib_wakeup_hcg;
wire   [31:0]  wdata_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire           wlast_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire   [3:0]   wstrb_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire           wvalid_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s;
wire   [63:0]  a_data_slave_if0_0_m_ib_int_async;
wire   [1:0]   a_wpntr_gry_slave_if0_0_m_ib_int_async;
wire           clk1clk;
wire           clk1clken;
wire           clk1resetn;
wire           csysreq_cd_clk1;
wire           d_rpntr_bin_slave_if0_0_m_ib_int_async;
wire   [1:0]   d_rpntr_gry_slave_if0_0_m_ib_int_async;
wire           empty_slave_if0_0_m_ib_int_async;
wire   [31:0]  prdata_master_if0;
wire           pready_master_if0;
wire           pslverr_master_if0;
wire   [36:0]  w_data_slave_if0_0_m_ib_int_async;
wire   [1:0]   w_wpntr_gry_slave_if0_0_m_ib_int_async;




nic400_amib_slave_if0_0_m_sse710_boot_reg     u_amib_slave_if0_0_m (
  .paddr_master_if0     (paddr_master_if0),
  .pwdata_master_if0    (pwdata_master_if0),
  .pwrite_master_if0    (pwrite_master_if0),
  .pprot_master_if0     (pprot_master_if0),
  .pstrb_master_if0     (pstrb_master_if0),
  .penable_master_if0   (penable_master_if0),
  .psel_master_if0      (pselx_master_if0),
  .prdata_master_if0    (prdata_master_if0),
  .pslverr_master_if0   (pslverr_master_if0),
  .pready_master_if0    (pready_master_if0),
  .apb_pclken           (clk1clken),
  .aid_slave_if0_0_m_s  (aid_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .aaddr_slave_if0_0_m_s (aaddr_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .alen_slave_if0_0_m_s (alen_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .asize_slave_if0_0_m_s (asize_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .aburst_slave_if0_0_m_s (aburst_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .alock_slave_if0_0_m_s (alock_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .acache_slave_if0_0_m_s (acache_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .aprot_slave_if0_0_m_s (aprot_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .awrite_slave_if0_0_m_s (awrite_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .avalid_slave_if0_0_m_s (avalid_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .aready_slave_if0_0_m_s (aready_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .wdata_slave_if0_0_m_s (wdata_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .wstrb_slave_if0_0_m_s (wstrb_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .wlast_slave_if0_0_m_s (wlast_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .wvalid_slave_if0_0_m_s (wvalid_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .wready_slave_if0_0_m_s (wready_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .did_slave_if0_0_m_s  (did_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .ddata_slave_if0_0_m_s (ddata_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .dresp_slave_if0_0_m_s (dresp_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .dlast_slave_if0_0_m_s (dlast_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .dbnr_slave_if0_0_m_s (dbnr_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .dvalid_slave_if0_0_m_s (dvalid_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .dready_slave_if0_0_m_s (dready_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .aclk                 (clk1clk),
  .aresetn              (clk1resetn)
);


nic400_dmu_clk1_sse710_boot_reg     u_dmu_clk1_sse710_boot_reg (
  .cd_clk1_clk          (clk1clk),
  .cd_clk1_resetn       (clk1resetn),
  .cd_clk1_cactive      (cactive_cd_clk1),
  .cd_clk1_csysreq      (csysreq_cd_clk1),
  .cd_clk1_csysack      (csysack_cd_clk1),
  .slave_if0_0_m_ib_cactive (cactive_slave_if0_0_m_ib_hcg),
  .slave_if0_0_m_ib_port_enable (port_enable_slave_if0_0_m_ib_port_enable_hcg),
  .slave_if0_0_m_ib_cactive_wakeup (cactive_slave_if0_0_m_ib_wakeup_hcg)
);


nic400_ib_slave_if0_0_m_ib_master_domain_sse710_boot_reg     u_ib_slave_if0_0_m_ib_m (
  .aid_itb_m            (aid_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .aaddr_itb_m          (aaddr_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .alen_itb_m           (alen_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .asize_itb_m          (asize_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .aburst_itb_m         (aburst_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .alock_itb_m          (alock_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .acache_itb_m         (acache_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .aprot_itb_m          (aprot_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .awrite_itb_m         (awrite_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .avalid_itb_m         (avalid_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .aready_itb_m         (aready_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .wdata_itb_m          (wdata_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .wstrb_itb_m          (wstrb_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .wlast_itb_m          (wlast_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .wvalid_itb_m         (wvalid_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .wready_itb_m         (wready_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .did_itb_m            (did_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .ddata_itb_m          (ddata_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .dresp_itb_m          (dresp_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .dlast_itb_m          (dlast_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .dbnr_itb_m           (dbnr_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .dvalid_itb_m         (dvalid_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .dready_itb_m         (dready_slave_if0_0_m_ib_slave_if0_0_m_slave_if0_0_m_s),
  .aclk_m               (clk1clk),
  .aresetn_m            (clk1resetn),
  .slave_if0_0_m_ib_cactive (cactive_slave_if0_0_m_ib_hcg),
  .slave_if0_0_m_ib_port_enable (port_enable_slave_if0_0_m_ib_port_enable_hcg),
  .a_data_async         (a_data_slave_if0_0_m_ib_int_async),
  .a_rpntr_gry_async    (a_rpntr_gry_slave_if0_0_m_ib_int_async),
  .a_rpntr_bin          (a_rpntr_bin_slave_if0_0_m_ib_int_async),
  .a_wpntr_gry_async    (a_wpntr_gry_slave_if0_0_m_ib_int_async),
  .d_data_async         (d_data_slave_if0_0_m_ib_int_async),
  .d_rpntr_gry_async    (d_rpntr_gry_slave_if0_0_m_ib_int_async),
  .d_rpntr_bin          (d_rpntr_bin_slave_if0_0_m_ib_int_async),
  .d_wpntr_gry_async    (d_wpntr_gry_slave_if0_0_m_ib_int_async),
  .w_data_async         (w_data_slave_if0_0_m_ib_int_async),
  .w_rpntr_gry_async    (w_rpntr_gry_slave_if0_0_m_ib_int_async),
  .w_rpntr_bin          (w_rpntr_bin_slave_if0_0_m_ib_int_async),
  .w_wpntr_gry_async    (w_wpntr_gry_slave_if0_0_m_ib_int_async),
  .empty_async          (empty_slave_if0_0_m_ib_int_async),
  .slave_if0_0_m_ib_cactive_wakeup (cactive_slave_if0_0_m_ib_wakeup_hcg)
);



endmodule
