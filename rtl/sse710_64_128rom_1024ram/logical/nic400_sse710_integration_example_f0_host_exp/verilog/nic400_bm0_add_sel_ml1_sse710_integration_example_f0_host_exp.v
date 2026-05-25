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


module nic400_bm0_add_sel_ml1_sse710_integration_example_f0_host_exp
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





  output [3:0]      awuser_m;
  output [17:0]      awid_m;
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
   
  output [3:0]      aruser_m;
  output [17:0]      arid_m;
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
  input  [3:0]      awuser_s0;
  input  [17:0]      awid_s0;
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
   
  input  [3:0]      aruser_s0;
  input  [17:0]      arid_s0;
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

  
  
  wire              aw_valid_vector;
  wire              ar_valid_vector;
  wire              aw_sel_i;
  wire              ar_sel_i;
  wire              last_rd;
  wire              last_slot;     

  wire              wr_override;   
  wire              rd_override;   
  wire              rd_wr_awvalid;
  wire              rd_wr_arvalid;

  wire              mask_w;
  wire              mask_r;

  wire   [3:0]      awuser_m_i;
  wire   [17:0]      awid_m_i;
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
   
  wire   [3:0]      aruser_m_i;
  wire   [17:0]      arid_m_i;
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


  wire              valid_cnt_wr;
  wire              valid_cnt_rd;

  wire   [3:0]      awuser_s0_i;
  wire   [17:0]      awid_s0_i;
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
  
  wire   [3:0]      aruser_s0_i;
  wire   [17:0]      arid_s0_i;
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



nic400_bm0_maskcntl_ml1_sse710_integration_example_f0_host_exp u_nic400_bm0_maskcntl_ml1_sse710_integration_example_f0_host_exp (
        .last_slot    (last_slot),
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
   assign aw_valid_vector = awvalid_s0_i;
   assign ar_valid_vector = arvalid_s0_i;
   assign rd_wr_awvalid = aw_valid_vector & ~mask_w;
   assign rd_wr_arvalid = ar_valid_vector & ~mask_r;

nic400_bm0_rd_wr_arb_1_sse710_integration_example_f0_host_exp u_nic400_bm0_rd_wr_arb_1_sse710_integration_example_f0_host_exp (
        .wr_override    (wr_override),
        .rd_override    (rd_override),
        .last_slot      (last_slot),
        .wr_reqd_qv     (aw_qv_s0_i),
        .rd_reqd_qv     (ar_qv_s0_i),
        .awvalid        (rd_wr_awvalid),
        .awvalid_m      (valid_cnt_wr),
        .awready_m      (awready_m_i),
        .arvalid        (rd_wr_arvalid),
        .arvalid_m      (valid_cnt_rd),
        .arready_m      (arready_m_i),
        .aclk           (aclk),
        .aresetn        (aresetn)
);


    assign valid_cnt_wr     = (awvalid_m_i);
    assign valid_cnt_rd     = (arvalid_m_i);

    assign aw_sel_i         = ~(mask_w | wr_override);
    assign ar_sel_i         = ~(mask_r | rd_override);

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

    assign awuser_m       = awuser_m_i;
    assign awid_m         = awid_m_i;
    assign awaddr_m       = awaddr_m_i;
    assign awlen_m        = awlen_m_i;
    assign awsize_m       = awsize_m_i;
    assign awburst_m      = awburst_m_i;
    assign awlock_m       = awlock_m_i;
    assign awcache_m      = awcache_m_i;
    assign awprot_m       = awprot_m_i;
    assign aw_qv_m        = aw_qv_m_i;
    assign awvalid_m      = awvalid_m_i;
    assign awvalid_vect_m = awvalid_vect_m_i;
   
    assign aruser_m       = aruser_m_i;
    assign arid_m         = arid_m_i;
    assign araddr_m       = araddr_m_i;
    assign arlen_m        = arlen_m_i;
    assign arsize_m       = arsize_m_i;
    assign arburst_m      = arburst_m_i;
    assign arlock_m       = arlock_m_i;
    assign arcache_m      = arcache_m_i;
    assign arprot_m       = arprot_m_i;
    assign ar_qv_m        = ar_qv_m_i;
    assign arvalid_m      = arvalid_m_i;
    assign arvalid_vect_m = arvalid_vect_m_i;

    assign awready_m_i    = awready_m;
    assign arready_m_i    = arready_m;




endmodule




