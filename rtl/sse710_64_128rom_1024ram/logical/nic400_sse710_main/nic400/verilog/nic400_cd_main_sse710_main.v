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




module nic400_cd_main_sse710_main (
  

  haddr_gpvmain_ahb,
  htrans_gpvmain_ahb,
  hwrite_gpvmain_ahb,
  hsize_gpvmain_ahb,
  hburst_gpvmain_ahb,
  hprot_gpvmain_ahb,
  hwdata_gpvmain_ahb,
  hselx_gpvmain_ahb,
  hrdata_gpvmain_ahb,
  hready_gpvmain_ahb,
  hreadyout_gpvmain_ahb,
  hresp_gpvmain_ahb,
  

  cactive_cd_main,
  

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


  mainclk,
  mainresetn

);






input  [31:0] haddr_gpvmain_ahb;
input  [1:0]  htrans_gpvmain_ahb;
input         hwrite_gpvmain_ahb;
input  [2:0]  hsize_gpvmain_ahb;
input  [2:0]  hburst_gpvmain_ahb;
input  [3:0]  hprot_gpvmain_ahb;
input  [31:0] hwdata_gpvmain_ahb;
input         hselx_gpvmain_ahb;
output [31:0] hrdata_gpvmain_ahb;
input         hready_gpvmain_ahb;
output        hreadyout_gpvmain_ahb;
output        hresp_gpvmain_ahb;


output        cactive_cd_main;


output [51:0] a_data_gpvmain_ahb_ib_int;
output        a_valid_gpvmain_ahb_ib_int;
input         a_ready_gpvmain_ahb_ib_int;
input  [35:0] d_data_gpvmain_ahb_ib_int;
input         d_valid_gpvmain_ahb_ib_int;
output        d_ready_gpvmain_ahb_ib_int;
output [36:0] w_data_gpvmain_ahb_ib_int;
output        w_valid_gpvmain_ahb_ib_int;
input         w_ready_gpvmain_ahb_ib_int;
output        empty_gpvmain_ahb_ib_int;


input         mainclk;
input         mainresetn;




wire   [51:0]  a_data_gpvmain_ahb_ib_int;
wire           a_valid_gpvmain_ahb_ib_int;
wire           cactive_cd_main;
wire           d_ready_gpvmain_ahb_ib_int;
wire           empty_gpvmain_ahb_ib_int;
wire   [31:0]  hrdata_gpvmain_ahb;
wire           hreadyout_gpvmain_ahb;
wire           hresp_gpvmain_ahb;
wire   [36:0]  w_data_gpvmain_ahb_ib_int;
wire           w_valid_gpvmain_ahb_ib_int;
wire   [31:0]  aaddr_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire   [1:0]   aburst_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire   [3:0]   acache_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire   [3:0]   alen_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire   [1:0]   alock_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire   [2:0]   aprot_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire   [2:0]   asize_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire           avalid_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire   [1:0]   avalid_vect_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire           awrite_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire           dready_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire           cactive_gpvmain_ahb_hcg;
wire           cactive_gpvmain_ahb_wakeup_hcg;
wire   [31:0]  wdata_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire           wlast_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire   [3:0]   wstrb_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire           wvalid_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire           port_enable_gpvmain_ahb_port_enable_hcg;
wire           aready_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire           dbnr_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire   [31:0]  ddata_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire           dlast_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire   [1:0]   dresp_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire           dvalid_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire           wready_gpvmain_ahb_gpvmain_ahb_ib_itb_s;
wire           a_ready_gpvmain_ahb_ib_int;
wire   [35:0]  d_data_gpvmain_ahb_ib_int;
wire           d_valid_gpvmain_ahb_ib_int;
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
wire           w_ready_gpvmain_ahb_ib_int;




nic400_asib_gpvmain_ahb_sse710_main     u_asib_gpvmain_ahb (
  .gpvmain_ahb_cactive  (cactive_gpvmain_ahb_hcg),
  .aaddr_gpvmain_ahb_m  (aaddr_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .alen_gpvmain_ahb_m   (alen_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .asize_gpvmain_ahb_m  (asize_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .aburst_gpvmain_ahb_m (aburst_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .alock_gpvmain_ahb_m  (alock_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .acache_gpvmain_ahb_m (acache_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .aprot_gpvmain_ahb_m  (aprot_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .awrite_gpvmain_ahb_m (awrite_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .avalid_gpvmain_ahb_m (avalid_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .avalid_vect_gpvmain_ahb_m (avalid_vect_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .aready_gpvmain_ahb_m (aready_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .wdata_gpvmain_ahb_m  (wdata_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .wstrb_gpvmain_ahb_m  (wstrb_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .wlast_gpvmain_ahb_m  (wlast_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .wvalid_gpvmain_ahb_m (wvalid_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .wready_gpvmain_ahb_m (wready_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .ddata_gpvmain_ahb_m  (ddata_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .dresp_gpvmain_ahb_m  (dresp_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .dlast_gpvmain_ahb_m  (dlast_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .dbnr_gpvmain_ahb_m   (dbnr_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .dvalid_gpvmain_ahb_m (dvalid_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .dready_gpvmain_ahb_m (dready_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .aclk                 (mainclk),
  .aresetn              (mainresetn),
  .gpvmain_ahb_port_enable (port_enable_gpvmain_ahb_port_enable_hcg),
  .haddr_gpvmain_ahb_s  (haddr_gpvmain_ahb),
  .htrans_gpvmain_ahb_s (htrans_gpvmain_ahb),
  .hwrite_gpvmain_ahb_s (hwrite_gpvmain_ahb),
  .hsize_gpvmain_ahb_s  (hsize_gpvmain_ahb),
  .hburst_gpvmain_ahb_s (hburst_gpvmain_ahb),
  .hprot_gpvmain_ahb_s  (hprot_gpvmain_ahb),
  .hwdata_gpvmain_ahb_s (hwdata_gpvmain_ahb),
  .hselx_gpvmain_ahb_s  (hselx_gpvmain_ahb),
  .hrdata_gpvmain_ahb_s (hrdata_gpvmain_ahb),
  .hready_gpvmain_ahb_s (hready_gpvmain_ahb),
  .hreadyout_gpvmain_ahb_s (hreadyout_gpvmain_ahb),
  .hresp_gpvmain_ahb_s  (hresp_gpvmain_ahb),
  .gpvmain_ahb_cactive_wakeup (cactive_gpvmain_ahb_wakeup_hcg)
);


nic400_dmu_main_sse710_main     u_dmu_main_sse710_main (
  .cd_main_clk          (mainclk),
  .cd_main_resetn       (mainresetn),
  .cd_main_cactive      (cactive_cd_main),
  .gpvmain_ahb_cactive  (cactive_gpvmain_ahb_hcg),
  .gpvmain_ahb_port_enable (port_enable_gpvmain_ahb_port_enable_hcg),
  .gpvmain_ahb_cactive_wakeup (cactive_gpvmain_ahb_wakeup_hcg)
);


nic400_ib_gpvmain_ahb_ib_slave_domain_sse710_main     u_ib_gpvmain_ahb_ib_s (
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
  .aaddr_itb_s          (aaddr_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .alen_itb_s           (alen_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .asize_itb_s          (asize_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .aburst_itb_s         (aburst_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .alock_itb_s          (alock_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .acache_itb_s         (acache_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .aprot_itb_s          (aprot_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .awrite_itb_s         (awrite_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .avalid_itb_s         (avalid_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .avalid_vect_itb_s    (avalid_vect_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .aready_itb_s         (aready_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .wdata_itb_s          (wdata_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .wstrb_itb_s          (wstrb_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .wlast_itb_s          (wlast_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .wvalid_itb_s         (wvalid_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .wready_itb_s         (wready_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .ddata_itb_s          (ddata_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .dresp_itb_s          (dresp_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .dlast_itb_s          (dlast_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .dbnr_itb_s           (dbnr_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .dvalid_itb_s         (dvalid_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .dready_itb_s         (dready_gpvmain_ahb_gpvmain_ahb_ib_itb_s),
  .aclk_s               (mainclk),
  .aresetn_s            (mainresetn)
);



endmodule
