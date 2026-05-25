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




module nic400_cd_ref_sse710_integration_example_f0_host_exp (
  

  hselx_gpio_ahb_m,
  haddr_gpio_ahb_m,
  htrans_gpio_ahb_m,
  hwrite_gpio_ahb_m,
  hsize_gpio_ahb_m,
  hburst_gpio_ahb_m,
  hprot_gpio_ahb_m,
  hwdata_gpio_ahb_m,
  hrdata_gpio_ahb_m,
  hreadyout_gpio_ahb_m,
  hready_gpio_ahb_m,
  hresp_gpio_ahb_m,
  

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


  refclk,
  refresetn

);






output        hselx_gpio_ahb_m;
output [31:0] haddr_gpio_ahb_m;
output [1:0]  htrans_gpio_ahb_m;
output        hwrite_gpio_ahb_m;
output [2:0]  hsize_gpio_ahb_m;
output [2:0]  hburst_gpio_ahb_m;
output [3:0]  hprot_gpio_ahb_m;
output [31:0] hwdata_gpio_ahb_m;
input  [31:0] hrdata_gpio_ahb_m;
input         hreadyout_gpio_ahb_m;
output        hready_gpio_ahb_m;
input         hresp_gpio_ahb_m;


input  [88:0] a_data_gpio_ahb_m_ib_int_async;
output [3:0]  a_rpntr_gry_gpio_ahb_m_ib_int_async;
output [2:0]  a_rpntr_bin_gpio_ahb_m_ib_int_async;
input  [3:0]  a_wpntr_gry_gpio_ahb_m_ib_int_async;
output [87:0] d_data_gpio_ahb_m_ib_int_async;
input  [3:0]  d_rpntr_gry_gpio_ahb_m_ib_int_async;
input  [2:0]  d_rpntr_bin_gpio_ahb_m_ib_int_async;
output [3:0]  d_wpntr_gry_gpio_ahb_m_ib_int_async;
input  [72:0] w_data_gpio_ahb_m_ib_int_async;
output [3:0]  w_rpntr_gry_gpio_ahb_m_ib_int_async;
output [2:0]  w_rpntr_bin_gpio_ahb_m_ib_int_async;
input  [3:0]  w_wpntr_gry_gpio_ahb_m_ib_int_async;


input         refclk;
input         refresetn;




wire   [2:0]   a_rpntr_bin_gpio_ahb_m_ib_int_async;
wire   [3:0]   a_rpntr_gry_gpio_ahb_m_ib_int_async;
wire   [87:0]  d_data_gpio_ahb_m_ib_int_async;
wire   [3:0]   d_wpntr_gry_gpio_ahb_m_ib_int_async;
wire   [31:0]  haddr_gpio_ahb_m;
wire   [2:0]   hburst_gpio_ahb_m;
wire   [3:0]   hprot_gpio_ahb_m;
wire           hready_gpio_ahb_m;
wire           hselx_gpio_ahb_m;
wire   [2:0]   hsize_gpio_ahb_m;
wire   [1:0]   htrans_gpio_ahb_m;
wire   [31:0]  hwdata_gpio_ahb_m;
wire           hwrite_gpio_ahb_m;
wire   [2:0]   w_rpntr_bin_gpio_ahb_m_ib_int_async;
wire   [3:0]   w_rpntr_gry_gpio_ahb_m_ib_int_async;
wire           aready_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire           dbnr_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire   [31:0]  ddata_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire   [17:0]  did_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire           dlast_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire   [1:0]   dresp_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire           dvalid_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire           wready_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire   [31:0]  aaddr_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire   [1:0]   aburst_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire   [3:0]   acache_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire   [17:0]  aid_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire   [7:0]   alen_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire           alock_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire   [2:0]   aprot_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire   [2:0]   asize_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire           avalid_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire           awrite_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire           dready_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire   [31:0]  wdata_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire           wlast_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire   [3:0]   wstrb_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire           wvalid_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s;
wire   [88:0]  a_data_gpio_ahb_m_ib_int_async;
wire   [3:0]   a_wpntr_gry_gpio_ahb_m_ib_int_async;
wire   [2:0]   d_rpntr_bin_gpio_ahb_m_ib_int_async;
wire   [3:0]   d_rpntr_gry_gpio_ahb_m_ib_int_async;
wire   [31:0]  hrdata_gpio_ahb_m;
wire           hreadyout_gpio_ahb_m;
wire           hresp_gpio_ahb_m;
wire           refclk;
wire           refresetn;
wire   [72:0]  w_data_gpio_ahb_m_ib_int_async;
wire   [3:0]   w_wpntr_gry_gpio_ahb_m_ib_int_async;




nic400_amib_gpio_ahb_m_sse710_integration_example_f0_host_exp     u_amib_gpio_ahb_m (
  .hsel_gpio_ahb_m_m    (hselx_gpio_ahb_m),
  .haddr_gpio_ahb_m_m   (haddr_gpio_ahb_m),
  .htrans_gpio_ahb_m_m  (htrans_gpio_ahb_m),
  .hwrite_gpio_ahb_m_m  (hwrite_gpio_ahb_m),
  .hsize_gpio_ahb_m_m   (hsize_gpio_ahb_m),
  .hburst_gpio_ahb_m_m  (hburst_gpio_ahb_m),
  .hprot_gpio_ahb_m_m   (hprot_gpio_ahb_m),
  .hwdata_gpio_ahb_m_m  (hwdata_gpio_ahb_m),
  .hrdata_gpio_ahb_m_m  (hrdata_gpio_ahb_m),
  .hready_gpio_ahb_m_m  (hreadyout_gpio_ahb_m),
  .hreadymux_gpio_ahb_m_m (hready_gpio_ahb_m),
  .hresp_gpio_ahb_m_m   (hresp_gpio_ahb_m),
  .aid_gpio_ahb_m_s     (aid_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .aaddr_gpio_ahb_m_s   (aaddr_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .alen_gpio_ahb_m_s    (alen_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .asize_gpio_ahb_m_s   (asize_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .aburst_gpio_ahb_m_s  (aburst_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .alock_gpio_ahb_m_s   (alock_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .acache_gpio_ahb_m_s  (acache_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .aprot_gpio_ahb_m_s   (aprot_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .awrite_gpio_ahb_m_s  (awrite_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .avalid_gpio_ahb_m_s  (avalid_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .aready_gpio_ahb_m_s  (aready_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .wdata_gpio_ahb_m_s   (wdata_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .wstrb_gpio_ahb_m_s   (wstrb_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .wlast_gpio_ahb_m_s   (wlast_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .wvalid_gpio_ahb_m_s  (wvalid_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .wready_gpio_ahb_m_s  (wready_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .did_gpio_ahb_m_s     (did_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .ddata_gpio_ahb_m_s   (ddata_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .dresp_gpio_ahb_m_s   (dresp_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .dlast_gpio_ahb_m_s   (dlast_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .dbnr_gpio_ahb_m_s    (dbnr_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .dvalid_gpio_ahb_m_s  (dvalid_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .dready_gpio_ahb_m_s  (dready_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .aclk                 (refclk),
  .aresetn              (refresetn)
);


nic400_ib_gpio_ahb_m_ib_master_domain_sse710_integration_example_f0_host_exp     u_ib_gpio_ahb_m_ib_m (
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
  .w_wpntr_gry_async    (w_wpntr_gry_gpio_ahb_m_ib_int_async),
  .aid_itb_m            (aid_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .aaddr_itb_m          (aaddr_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .alen_itb_m           (alen_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .asize_itb_m          (asize_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .aburst_itb_m         (aburst_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .alock_itb_m          (alock_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .acache_itb_m         (acache_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .aprot_itb_m          (aprot_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .awrite_itb_m         (awrite_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .avalid_itb_m         (avalid_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .aregion_itb_m        (),
  .aready_itb_m         (aready_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .wdata_itb_m          (wdata_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .wstrb_itb_m          (wstrb_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .wlast_itb_m          (wlast_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .wvalid_itb_m         (wvalid_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .wready_itb_m         (wready_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .did_itb_m            (did_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .ddata_itb_m          (ddata_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .dresp_itb_m          (dresp_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .dlast_itb_m          (dlast_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .dbnr_itb_m           (dbnr_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .dvalid_itb_m         (dvalid_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .dready_itb_m         (dready_gpio_ahb_m_ib_gpio_ahb_m_gpio_ahb_m_s),
  .aclk_m               (refclk),
  .aresetn_m            (refresetn)
);



endmodule
