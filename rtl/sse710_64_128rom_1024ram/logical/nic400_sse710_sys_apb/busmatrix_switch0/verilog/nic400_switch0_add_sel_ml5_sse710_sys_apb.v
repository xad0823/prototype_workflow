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

`include "reg_slice_axi_defs.v"

module nic400_switch0_add_sel_ml5_sse710_sys_apb
  (
    awuser_m,
    awid_m,
    awaddr_m,
    awlen_m,
    awsize_m,
    awburst_m,
    awlock_m,
    awcache_m,
    awprot_m,
    awvalid_m,
    awvalid_vect_m,
    awready_m,
    aw_qv_m,
    aruser_m,
    arid_m,
    araddr_m,
    arlen_m,
    arsize_m,
    arburst_m,
    arlock_m,
    arcache_m,
    arprot_m,
    arvalid_m,
    arvalid_vect_m,
    arready_m,
    ar_qv_m,
    bvalid_m,
    bready_m,
    rvalid_m,
    rready_m,
    rlast_m,
    awuser_s0,
    awid_s0,
    awaddr_s0,
    awlen_s0,
    awsize_s0,
    awburst_s0,
    awlock_s0,
    awcache_s0,
    awprot_s0,
    awvalid_s0,
    awvalid_vect_s0,
    awready_s0,
    aw_qv_s0,
    aruser_s0,
    arid_s0,
    araddr_s0,
    arlen_s0,
    arsize_s0,
    arburst_s0,
    arlock_s0,
    arcache_s0,
    arprot_s0,
    arvalid_s0,
    arvalid_vect_s0,
    arready_s0,
    ar_qv_s0,

    wr_cnt_empty,
    aclk,
    aresetn
  );





  output [13:0]      awuser_m;
  output [11:0]      awid_m;
  output [31:0]     awaddr_m;
  output [7:0]      awlen_m;
  output [2:0]      awsize_m;
  output [1:0]      awburst_m;
  output            awlock_m;
  output [3:0]      awcache_m;
  output [2:0]      awprot_m;
  output            awvalid_m;
  output            awvalid_vect_m;
  input             awready_m;
  output [3:0]      aw_qv_m;
   
  output [13:0]      aruser_m;
  output [11:0]      arid_m;
  output [31:0]     araddr_m;
  output [7:0]      arlen_m;
  output [2:0]      arsize_m;
  output [1:0]      arburst_m;
  output            arlock_m;
  output [3:0]      arcache_m;
  output [2:0]      arprot_m;
  output            arvalid_m;
  output            arvalid_vect_m;
  input             arready_m;
  output [3:0]      ar_qv_m;
   
  input             bvalid_m;
  input             bready_m;
  input             rvalid_m;
  input             rready_m;
  input             rlast_m;
  input  [13:0]      awuser_s0;
  input  [11:0]      awid_s0;
  input  [31:0]     awaddr_s0;
  input  [7:0]      awlen_s0;
  input  [2:0]      awsize_s0;
  input  [1:0]      awburst_s0;
  input             awlock_s0;
  input  [3:0]      awcache_s0;
  input  [2:0]      awprot_s0;
  input             awvalid_s0;
  input             awvalid_vect_s0;
  output            awready_s0;
  input  [3:0]      aw_qv_s0;
   
  input  [13:0]      aruser_s0;
  input  [11:0]      arid_s0;
  input  [31:0]     araddr_s0;
  input  [7:0]      arlen_s0;
  input  [2:0]      arsize_s0;
  input  [1:0]      arburst_s0;
  input             arlock_s0;
  input  [3:0]      arcache_s0;
  input  [2:0]      arprot_s0;
  input             arvalid_s0;
  input             arvalid_vect_s0;
  output            arready_s0;
  input  [3:0]      ar_qv_s0;


  output            wr_cnt_empty;
  input             aclk;
  input             aresetn;

  
  
  wire              aw_sel_i;
  wire              ar_sel_i;
  wire              last_rd;
  wire              mask_w;
  wire              mask_r;

  wire   [13:0]      awuser_m_i;
  wire   [11:0]      awid_m_i;
  wire   [31:0]     awaddr_m_i;
  wire   [7:0]      awlen_m_i;
  wire   [2:0]      awsize_m_i;
  wire   [1:0]      awburst_m_i;
  wire              awlock_m_i;
  wire   [3:0]      awcache_m_i;
  wire   [2:0]      awprot_m_i;
  wire              awvalid_m_i;
  wire              awvalid_vect_m_i;
  wire              awready_m_i;
  wire   [3:0]      aw_qv_m_i;
   
  wire   [13:0]      aruser_m_i;
  wire   [11:0]      arid_m_i;
  wire   [31:0]     araddr_m_i;
  wire   [7:0]      arlen_m_i;
  wire   [2:0]      arsize_m_i;
  wire   [1:0]      arburst_m_i;
  wire              arlock_m_i;
  wire   [3:0]      arcache_m_i;
  wire   [2:0]      arprot_m_i;
  wire              arvalid_m_i;
  wire              arvalid_vect_m_i;
  wire              arready_m_i;
  wire   [3:0]      ar_qv_m_i;

  wire   [19:0]      awuser_in;
  wire   [19:0]      awuser_out;
  wire   [18:0]      aruser_in;
  wire   [18:0]      aruser_out;


  wire   [13:0]      awuser_s0_i;
  wire   [11:0]      awid_s0_i;
  wire   [31:0]     awaddr_s0_i;
  wire   [7:0]      awlen_s0_i;
  wire   [2:0]      awsize_s0_i;
  wire   [1:0]      awburst_s0_i;
  wire              awlock_s0_i;
  wire   [3:0]      awcache_s0_i;
  wire   [2:0]      awprot_s0_i;
  wire              awvalid_s0_i;
  wire              awvalid_vect_s0_i;
  wire              awready_s0_i;
  wire   [3:0]      aw_qv_s0_i;
  
  wire   [13:0]      aruser_s0_i;
  wire   [11:0]      arid_s0_i;
  wire   [31:0]     araddr_s0_i;
  wire   [7:0]      arlen_s0_i;
  wire   [2:0]      arsize_s0_i;
  wire   [1:0]      arburst_s0_i;
  wire              arlock_s0_i;
  wire   [3:0]      arcache_s0_i;
  wire   [2:0]      arprot_s0_i;
  wire              arvalid_s0_i;
  wire              arvalid_vect_s0_i;
  wire              arready_s0_i;
  wire   [3:0]      ar_qv_s0_i;
  




  assign awuser_s0_i = awuser_s0;
  assign awid_s0_i = awid_s0;
  assign awaddr_s0_i = awaddr_s0;
  assign awlen_s0_i = awlen_s0;
  assign awsize_s0_i = awsize_s0;
  assign awburst_s0_i = awburst_s0;
  assign awlock_s0_i = awlock_s0;
  assign awcache_s0_i = awcache_s0;
  assign awprot_s0_i = awprot_s0;
  assign awvalid_s0_i = awvalid_s0;
  assign awvalid_vect_s0_i = awvalid_vect_s0;
  assign aw_qv_s0_i = aw_qv_s0;
  assign awready_s0 = awready_s0_i;
   
  assign aruser_s0_i = aruser_s0;
  assign arid_s0_i = arid_s0;
  assign araddr_s0_i = araddr_s0;
  assign arlen_s0_i = arlen_s0;
  assign arsize_s0_i = arsize_s0;
  assign arburst_s0_i = arburst_s0;
  assign arlock_s0_i = arlock_s0;
  assign arcache_s0_i = arcache_s0;
  assign arprot_s0_i = arprot_s0;
  assign arvalid_s0_i = arvalid_s0;
  assign arvalid_vect_s0_i = arvalid_vect_s0;
  assign ar_qv_s0_i = ar_qv_s0;
  assign arready_s0 = arready_s0_i;



nic400_switch0_maskcntl_ml5_sse710_sys_apb u_nic400_switch0_maskcntl_ml5_sse710_sys_apb (
        .awvalid_m    (awvalid_m_i),
        .awready_m    (awready_m_i),
        .arvalid_m    (arvalid_m_i),
        .arready_m    (arready_m_i),
        .bvalid_m     (bvalid_m),
        .bready_m     (bready_m),
        .rvalid_m     (last_rd),
        .rready_m     (rready_m),
        .wr_cnt_empty (wr_cnt_empty),
        .mask_w       (mask_w),
        .mask_r       (mask_r),
        .aclk         (aclk),
        .aresetn      (aresetn)
);


   assign last_rd = (rvalid_m & rlast_m);



    assign aw_sel_i         = ~(mask_w);
    assign ar_sel_i         = ~(mask_r);

    assign awuser_m_i       = awuser_s0_i;
    assign awid_m_i         = awid_s0_i;
    assign awaddr_m_i       = awaddr_s0_i;
    assign awlen_m_i        = awlen_s0_i;
    assign awsize_m_i       = awsize_s0_i;
    assign awburst_m_i      = awburst_s0_i;
    assign awlock_m_i       = awlock_s0_i;
    assign awcache_m_i      = awcache_s0_i;
    assign awprot_m_i       = awprot_s0_i;
    assign aw_qv_m_i        = aw_qv_s0_i;
    assign awvalid_m_i      = awvalid_s0_i & aw_sel_i;
    assign awvalid_vect_m_i = awvalid_vect_s0_i & aw_sel_i;
   
    assign aruser_m_i       = aruser_s0_i;
    assign arid_m_i         = arid_s0_i;
    assign araddr_m_i       = araddr_s0_i;
    assign arlen_m_i        = arlen_s0_i;
    assign arsize_m_i       = arsize_s0_i;
    assign arburst_m_i      = arburst_s0_i;
    assign arlock_m_i       = arlock_s0_i;
    assign arcache_m_i      = arcache_s0_i;
    assign arprot_m_i       = arprot_s0_i;
    assign ar_qv_m_i        = ar_qv_s0_i;
    assign arvalid_m_i      = arvalid_s0_i & ar_sel_i;
    assign arvalid_vect_m_i = arvalid_vect_s0_i & ar_sel_i;

    assign awready_s0_i     = awready_m_i & aw_sel_i;
    assign arready_s0_i     = arready_m_i & ar_sel_i;

   assign awuser_in         = {awuser_m_i, aw_qv_m_i, (aw_sel_i), awvalid_vect_m_i};
   assign awvalid_vect_m    = awuser_out[0:0] & {1{awvalid_m}};
   assign aw_qv_m           = awuser_out[5:2];

   assign awuser_m          = awuser_out[19:6];

nic400_ax4_reg_slice_sse710_sys_apb
  #(12, 20, `RS_FWD_REG, 32)
  u_aw_reg_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .axids          (awid_m_i),
     .axaddrs        (awaddr_m_i),
     .axlens         (awlen_m_i),
     .axsizes        (awsize_m_i),
     .axbursts       (awburst_m_i),
     .axlocks        (awlock_m_i),
     .axcaches       (awcache_m_i),
     .axprots        (awprot_m_i),
     .axusers        (awuser_in),
     .axvalids       (awvalid_m_i),
     .axreadys       (awready_m_i),

     .axidm          (awid_m),
     .axaddrm        (awaddr_m),
     .axlenm         (awlen_m),
     .axsizem        (awsize_m),
     .axburstm       (awburst_m),
     .axlockm        (awlock_m),
     .axcachem       (awcache_m),
     .axprotm        (awprot_m),
     .axuserm        (awuser_out),
     .axvalidm       (awvalid_m),
     .axreadym       (awready_m)
     );


   assign aruser_in      = {aruser_m_i, ar_qv_m_i, arvalid_vect_m_i};
   assign ar_qv_m        = aruser_out[4:1];
   assign aruser_m       = aruser_out[18:5];
   assign arvalid_vect_m = aruser_out[0:0] & {1{arvalid_m}};


  nic400_ax4_reg_slice_sse710_sys_apb
  #(12, 19, `RS_FWD_REG, 32)
  u_ar_reg_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .axids          (arid_m_i),
     .axaddrs        (araddr_m_i),
     .axlens         (arlen_m_i),
     .axsizes        (arsize_m_i),
     .axbursts       (arburst_m_i),
     .axlocks        (arlock_m_i),
     .axcaches       (arcache_m_i),
     .axprots        (arprot_m_i),
     .axusers        (aruser_in),
     .axvalids       (arvalid_m_i),
     .axreadys       (arready_m_i),

     .axidm          (arid_m),
     .axaddrm        (araddr_m),
     .axlenm         (arlen_m),
     .axsizem        (arsize_m),
     .axburstm       (arburst_m),
     .axlockm        (arlock_m),
     .axcachem       (arcache_m),
     .axprotm        (arprot_m),
     .axuserm        (aruser_out),
     .axvalidm       (arvalid_m),
     .axreadym       (arready_m)
     );




endmodule


`include "reg_slice_axi_undefs.v"


