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





module nic400_cd_a_r_sse710_main (
  

  a_data_gpv_0_ib1_int,
  a_valid_gpv_0_ib1_int,
  a_ready_gpv_0_ib1_int,
  d_data_gpv_0_ib1_int,
  d_valid_gpv_0_ib1_int,
  d_ready_gpv_0_ib1_int,
  w_data_gpv_0_ib1_int,
  w_valid_gpv_0_ib1_int,
  w_ready_gpv_0_ib1_int,
  

  rsb_data_a_ml_m,
  rsb_wptr_a_ml_m,
  rsb_rptr_a_ml_m,
  rsb_bin_rptr_a_ml_m,
  

  rsb_data_a_ml_s,
  rsb_wptr_a_ml_s,
  rsb_rptr_a_ml_s,
  rsb_bin_rptr_a_ml_s,
  

  rsb_data_a_sl_m,
  rsb_wptr_a_sl_m,
  rsb_rptr_a_sl_m,
  rsb_bin_rptr_a_sl_m,
  

  rsb_data_a_sl_s,
  rsb_wptr_a_sl_s,
  rsb_rptr_a_sl_s,
  rsb_bin_rptr_a_sl_s,
  

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


  aclk_r,
  aresetn_r

);






input  [73:0] a_data_gpv_0_ib1_int;
input         a_valid_gpv_0_ib1_int;
output        a_ready_gpv_0_ib1_int;
output [47:0] d_data_gpv_0_ib1_int;
output        d_valid_gpv_0_ib1_int;
input         d_ready_gpv_0_ib1_int;
input  [36:0] w_data_gpv_0_ib1_int;
input         w_valid_gpv_0_ib1_int;
output        w_ready_gpv_0_ib1_int;


output [7:0]  rsb_data_a_ml_m;
output [2:0]  rsb_wptr_a_ml_m;
input  [2:0]  rsb_rptr_a_ml_m;
input  [1:0]  rsb_bin_rptr_a_ml_m;


input  [7:0]  rsb_data_a_ml_s;
input  [2:0]  rsb_wptr_a_ml_s;
output [2:0]  rsb_rptr_a_ml_s;
output [1:0]  rsb_bin_rptr_a_ml_s;


output [7:0]  rsb_data_a_sl_m;
output [2:0]  rsb_wptr_a_sl_m;
input  [2:0]  rsb_rptr_a_sl_m;
input  [1:0]  rsb_bin_rptr_a_sl_m;


input  [7:0]  rsb_data_a_sl_s;
input  [2:0]  rsb_wptr_a_sl_s;
output [2:0]  rsb_rptr_a_sl_s;
output [1:0]  rsb_bin_rptr_a_sl_s;


output [31:0] paddr_debug_axis_ib_apb;
output [31:0] pwdata_debug_axis_ib_apb;
output        pwrite_debug_axis_ib_apb;
output        penable_debug_axis_ib_apb;
output        pselx_debug_axis_ib_apb;
input  [31:0] prdata_debug_axis_ib_apb;
input         pslverr_debug_axis_ib_apb;
input         pready_debug_axis_ib_apb;


output [31:0] paddr_extsys0_axis_ib_apb;
output [31:0] pwdata_extsys0_axis_ib_apb;
output        pwrite_extsys0_axis_ib_apb;
output        penable_extsys0_axis_ib_apb;
output        pselx_extsys0_axis_ib_apb;
input  [31:0] prdata_extsys0_axis_ib_apb;
input         pslverr_extsys0_axis_ib_apb;
input         pready_extsys0_axis_ib_apb;


output [31:0] paddr_extsys1_axis_ib_apb;
output [31:0] pwdata_extsys1_axis_ib_apb;
output        pwrite_extsys1_axis_ib_apb;
output        penable_extsys1_axis_ib_apb;
output        pselx_extsys1_axis_ib_apb;
input  [31:0] prdata_extsys1_axis_ib_apb;
input         pslverr_extsys1_axis_ib_apb;
input         pready_extsys1_axis_ib_apb;


output [31:0] paddr_hostcpu_axis_ib_apb;
output [31:0] pwdata_hostcpu_axis_ib_apb;
output        pwrite_hostcpu_axis_ib_apb;
output        penable_hostcpu_axis_ib_apb;
output        pselx_hostcpu_axis_ib_apb;
input  [31:0] prdata_hostcpu_axis_ib_apb;
input         pslverr_hostcpu_axis_ib_apb;
input         pready_hostcpu_axis_ib_apb;


output [31:0] paddr_secenc_axis_ib_apb;
output [31:0] pwdata_secenc_axis_ib_apb;
output        pwrite_secenc_axis_ib_apb;
output        penable_secenc_axis_ib_apb;
output        pselx_secenc_axis_ib_apb;
input  [31:0] prdata_secenc_axis_ib_apb;
input         pslverr_secenc_axis_ib_apb;
input         pready_secenc_axis_ib_apb;


input         aclk_r;
input         aresetn_r;




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
wire   [39:0]  aaddr_ib_gpv_0_ib1;
wire   [1:0]   aburst_ib_gpv_0_ib1;
wire   [3:0]   acache_ib_gpv_0_ib1;
wire   [11:0]  aid_ib_gpv_0_ib1;
wire   [7:0]   alen_ib_gpv_0_ib1;
wire           alock_ib_gpv_0_ib1;
wire   [2:0]   aprot_ib_gpv_0_ib1;
wire   [2:0]   asize_ib_gpv_0_ib1;
wire           avalid_ib_gpv_0_ib1;
wire           awrite_ib_gpv_0_ib1;
wire           dready_ib_gpv_0_ib1;
wire   [31:0]  wdata_ib_gpv_0_ib1;
wire           wlast_ib_gpv_0_ib1;
wire   [3:0]   wstrb_ib_gpv_0_ib1;
wire           wvalid_ib_gpv_0_ib1;
wire   [31:0]  prdata_ib_regs;
wire           pready_ib_regs;
wire           pslverr_ib_regs;
wire           aready_ib_gpv_0_ib1;
wire           dbnr_ib_gpv_0_ib1;
wire   [31:0]  ddata_ib_gpv_0_ib1;
wire   [11:0]  did_ib_gpv_0_ib1;
wire           dlast_ib_gpv_0_ib1;
wire   [1:0]   dresp_ib_gpv_0_ib1;
wire           dvalid_ib_gpv_0_ib1;
wire           wready_ib_gpv_0_ib1;
wire   [31:0]  paddr_ib_regs;
wire           penable_ib_regs;
wire           pselx_ib_regs;
wire   [31:0]  pwdata_ib_regs;
wire           pwrite_ib_regs;
wire   [73:0]  a_data_gpv_0_ib1_int;
wire           a_valid_gpv_0_ib1_int;
wire           aclk_r;
wire           aresetn_r;
wire           d_ready_gpv_0_ib1_int;
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
wire   [1:0]   rsb_bin_rptr_a_ml_m;
wire   [1:0]   rsb_bin_rptr_a_sl_m;
wire   [7:0]   rsb_data_a_ml_s;
wire   [7:0]   rsb_data_a_sl_s;
wire   [2:0]   rsb_rptr_a_ml_m;
wire   [2:0]   rsb_rptr_a_sl_m;
wire   [2:0]   rsb_wptr_a_ml_s;
wire   [2:0]   rsb_wptr_a_sl_s;
wire   [36:0]  w_data_gpv_0_ib1_int;
wire           w_valid_gpv_0_ib1_int;




nic400_ib_gpv_0_ib1_master_domain_sse710_main     u_ib_gpv_0_ib1_m (
  .a_data               (a_data_gpv_0_ib1_int),
  .a_valid              (a_valid_gpv_0_ib1_int),
  .a_ready              (a_ready_gpv_0_ib1_int),
  .d_data               (d_data_gpv_0_ib1_int),
  .d_valid              (d_valid_gpv_0_ib1_int),
  .d_ready              (d_ready_gpv_0_ib1_int),
  .w_data               (w_data_gpv_0_ib1_int),
  .w_valid              (w_valid_gpv_0_ib1_int),
  .w_ready              (w_ready_gpv_0_ib1_int),
  .aid_itb_m            (aid_ib_gpv_0_ib1),
  .aaddr_itb_m          (aaddr_ib_gpv_0_ib1),
  .alen_itb_m           (alen_ib_gpv_0_ib1),
  .asize_itb_m          (asize_ib_gpv_0_ib1),
  .aburst_itb_m         (aburst_ib_gpv_0_ib1),
  .alock_itb_m          (alock_ib_gpv_0_ib1),
  .acache_itb_m         (acache_ib_gpv_0_ib1),
  .aprot_itb_m          (aprot_ib_gpv_0_ib1),
  .awrite_itb_m         (awrite_ib_gpv_0_ib1),
  .avalid_itb_m         (avalid_ib_gpv_0_ib1),
  .aready_itb_m         (aready_ib_gpv_0_ib1),
  .wdata_itb_m          (wdata_ib_gpv_0_ib1),
  .wstrb_itb_m          (wstrb_ib_gpv_0_ib1),
  .wlast_itb_m          (wlast_ib_gpv_0_ib1),
  .wvalid_itb_m         (wvalid_ib_gpv_0_ib1),
  .wready_itb_m         (wready_ib_gpv_0_ib1),
  .did_itb_m            (did_ib_gpv_0_ib1),
  .ddata_itb_m          (ddata_ib_gpv_0_ib1),
  .dresp_itb_m          (dresp_ib_gpv_0_ib1),
  .dlast_itb_m          (dlast_ib_gpv_0_ib1),
  .dbnr_itb_m           (dbnr_ib_gpv_0_ib1),
  .dvalid_itb_m         (dvalid_ib_gpv_0_ib1),
  .dready_itb_m         (dready_ib_gpv_0_ib1),
  .aclk                 (aclk_r),
  .aresetn              (aresetn_r)
);


nic400_id_regs_sse710_main     u_id_regs (
  .paddr                (paddr_ib_regs),
  .pwdata               (pwdata_ib_regs),
  .pwrite               (pwrite_ib_regs),
  .penable              (penable_ib_regs),
  .psel                 (pselx_ib_regs),
  .prdata               (prdata_ib_regs),
  .pslverr              (pslverr_ib_regs),
  .pready               (pready_ib_regs),
  .pclk                 (aclk_r),
  .presetn              (aresetn_r)
);


nic400_a_master_reg_nodes_sse710_main     u_mnodes_a (
  .rsb_data_m_async     (rsb_data_a_ml_m),
  .rsb_wptr_b_async     (rsb_wptr_a_ml_m),
  .rsb_rptr_b_async     (rsb_rptr_a_ml_m),
  .rsb_rptr_b_bin       (rsb_bin_rptr_a_ml_m),
  .rsb_data_s_async     (rsb_data_a_ml_s),
  .rsb_wptr_s_async     (rsb_wptr_a_ml_s),
  .rsb_rptr_s_async     (rsb_rptr_a_ml_s),
  .rsb_rptr_s_bin       (rsb_bin_rptr_a_ml_s),
  .aid_gpv_0            (aid_ib_gpv_0_ib1),
  .aaddr_gpv_0          (aaddr_ib_gpv_0_ib1),
  .alen_gpv_0           (alen_ib_gpv_0_ib1),
  .asize_gpv_0          (asize_ib_gpv_0_ib1),
  .aburst_gpv_0         (aburst_ib_gpv_0_ib1),
  .alock_gpv_0          (alock_ib_gpv_0_ib1),
  .acache_gpv_0         (acache_ib_gpv_0_ib1),
  .aprot_gpv_0          (aprot_ib_gpv_0_ib1),
  .avalid_gpv_0         (avalid_ib_gpv_0_ib1),
  .aready_gpv_0         (aready_ib_gpv_0_ib1),
  .awrite_gpv_0         (awrite_ib_gpv_0_ib1),
  .wdata_gpv_0          (wdata_ib_gpv_0_ib1),
  .wstrb_gpv_0          (wstrb_ib_gpv_0_ib1),
  .wlast_gpv_0          (wlast_ib_gpv_0_ib1),
  .wvalid_gpv_0         (wvalid_ib_gpv_0_ib1),
  .wready_gpv_0         (wready_ib_gpv_0_ib1),
  .did_gpv_0            (did_ib_gpv_0_ib1),
  .ddata_gpv_0          (ddata_ib_gpv_0_ib1),
  .dresp_gpv_0          (dresp_ib_gpv_0_ib1),
  .dlast_gpv_0          (dlast_ib_gpv_0_ib1),
  .dbnr_gpv_0           (dbnr_ib_gpv_0_ib1),
  .dvalid_gpv_0         (dvalid_ib_gpv_0_ib1),
  .dready_gpv_0         (dready_ib_gpv_0_ib1),
  .rclk                 (aclk_r),
  .rresetn              (aresetn_r)
);


nic400_a_slave_reg_nodes_sse710_main     u_snodes_a (
  .rsb_data_m_async     (rsb_data_a_sl_m),
  .rsb_wptr_b_async     (rsb_wptr_a_sl_m),
  .rsb_rptr_b_async     (rsb_rptr_a_sl_m),
  .rsb_rptr_b_bin       (rsb_bin_rptr_a_sl_m),
  .rsb_data_s_async     (rsb_data_a_sl_s),
  .rsb_wptr_s_async     (rsb_wptr_a_sl_s),
  .rsb_rptr_s_async     (rsb_rptr_a_sl_s),
  .rsb_rptr_s_bin       (rsb_bin_rptr_a_sl_s),
  .paddr_debug_axis_ib  (paddr_debug_axis_ib_apb),
  .pwdata_debug_axis_ib (pwdata_debug_axis_ib_apb),
  .pwrite_debug_axis_ib (pwrite_debug_axis_ib_apb),
  .penable_debug_axis_ib (penable_debug_axis_ib_apb),
  .psel_debug_axis_ib   (pselx_debug_axis_ib_apb),
  .prdata_debug_axis_ib (prdata_debug_axis_ib_apb),
  .pslverr_debug_axis_ib (pslverr_debug_axis_ib_apb),
  .pready_debug_axis_ib (pready_debug_axis_ib_apb),
  .paddr_extsys0_axis_ib (paddr_extsys0_axis_ib_apb),
  .pwdata_extsys0_axis_ib (pwdata_extsys0_axis_ib_apb),
  .pwrite_extsys0_axis_ib (pwrite_extsys0_axis_ib_apb),
  .penable_extsys0_axis_ib (penable_extsys0_axis_ib_apb),
  .psel_extsys0_axis_ib (pselx_extsys0_axis_ib_apb),
  .prdata_extsys0_axis_ib (prdata_extsys0_axis_ib_apb),
  .pslverr_extsys0_axis_ib (pslverr_extsys0_axis_ib_apb),
  .pready_extsys0_axis_ib (pready_extsys0_axis_ib_apb),
  .paddr_extsys1_axis_ib (paddr_extsys1_axis_ib_apb),
  .pwdata_extsys1_axis_ib (pwdata_extsys1_axis_ib_apb),
  .pwrite_extsys1_axis_ib (pwrite_extsys1_axis_ib_apb),
  .penable_extsys1_axis_ib (penable_extsys1_axis_ib_apb),
  .psel_extsys1_axis_ib (pselx_extsys1_axis_ib_apb),
  .prdata_extsys1_axis_ib (prdata_extsys1_axis_ib_apb),
  .pslverr_extsys1_axis_ib (pslverr_extsys1_axis_ib_apb),
  .pready_extsys1_axis_ib (pready_extsys1_axis_ib_apb),
  .paddr_hostcpu_axis_ib (paddr_hostcpu_axis_ib_apb),
  .pwdata_hostcpu_axis_ib (pwdata_hostcpu_axis_ib_apb),
  .pwrite_hostcpu_axis_ib (pwrite_hostcpu_axis_ib_apb),
  .penable_hostcpu_axis_ib (penable_hostcpu_axis_ib_apb),
  .psel_hostcpu_axis_ib (pselx_hostcpu_axis_ib_apb),
  .prdata_hostcpu_axis_ib (prdata_hostcpu_axis_ib_apb),
  .pslverr_hostcpu_axis_ib (pslverr_hostcpu_axis_ib_apb),
  .pready_hostcpu_axis_ib (pready_hostcpu_axis_ib_apb),
  .paddr_regs           (paddr_ib_regs),
  .pwdata_regs          (pwdata_ib_regs),
  .pwrite_regs          (pwrite_ib_regs),
  .penable_regs         (penable_ib_regs),
  .psel_regs            (pselx_ib_regs),
  .prdata_regs          (prdata_ib_regs),
  .pslverr_regs         (pslverr_ib_regs),
  .pready_regs          (pready_ib_regs),
  .rclk                 (aclk_r),
  .rresetn              (aresetn_r),
  .paddr_secenc_axis_ib (paddr_secenc_axis_ib_apb),
  .pwdata_secenc_axis_ib (pwdata_secenc_axis_ib_apb),
  .pwrite_secenc_axis_ib (pwrite_secenc_axis_ib_apb),
  .penable_secenc_axis_ib (penable_secenc_axis_ib_apb),
  .psel_secenc_axis_ib  (pselx_secenc_axis_ib_apb),
  .prdata_secenc_axis_ib (prdata_secenc_axis_ib_apb),
  .pslverr_secenc_axis_ib (pslverr_secenc_axis_ib_apb),
  .pready_secenc_axis_ib (pready_secenc_axis_ib_apb)
);



endmodule
