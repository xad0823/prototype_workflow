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

module nic400_switch2_add_sel_ml7_sse710_main
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
    aw_sel,
    wvalid_m,
    wready_m,
    wlast_m,
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

    awuser_s1,
    awid_s1,
    awaddr_s1,
    awlen_s1,
    awsize_s1,
    awburst_s1,
    awlock_s1,
    awcache_s1,
    awprot_s1,
    awvalid_s1,
    awvalid_vect_s1,
    awready_s1,
    aw_qv_s1,
    aruser_s1,
    arid_s1,
    araddr_s1,
    arlen_s1,
    arsize_s1,
    arburst_s1,
    arlock_s1,
    arcache_s1,
    arprot_s1,
    arvalid_s1,
    arvalid_vect_s1,
    arready_s1,
    ar_qv_s1,

    awuser_s2,
    awid_s2,
    awaddr_s2,
    awlen_s2,
    awsize_s2,
    awburst_s2,
    awlock_s2,
    awcache_s2,
    awprot_s2,
    awvalid_s2,
    awvalid_vect_s2,
    awready_s2,
    aw_qv_s2,
    aruser_s2,
    arid_s2,
    araddr_s2,
    arlen_s2,
    arsize_s2,
    arburst_s2,
    arlock_s2,
    arcache_s2,
    arprot_s2,
    arvalid_s2,
    arvalid_vect_s2,
    arready_s2,
    ar_qv_s2,

    awuser_s3,
    awid_s3,
    awaddr_s3,
    awlen_s3,
    awsize_s3,
    awburst_s3,
    awlock_s3,
    awcache_s3,
    awprot_s3,
    awvalid_s3,
    awvalid_vect_s3,
    awready_s3,
    aw_qv_s3,
    aruser_s3,
    arid_s3,
    araddr_s3,
    arlen_s3,
    arsize_s3,
    arburst_s3,
    arlock_s3,
    arcache_s3,
    arprot_s3,
    arvalid_s3,
    arvalid_vect_s3,
    arready_s3,
    ar_qv_s3,

    awuser_s4,
    awid_s4,
    awaddr_s4,
    awlen_s4,
    awsize_s4,
    awburst_s4,
    awlock_s4,
    awcache_s4,
    awprot_s4,
    awvalid_s4,
    awvalid_vect_s4,
    awready_s4,
    aw_qv_s4,
    aruser_s4,
    arid_s4,
    araddr_s4,
    arlen_s4,
    arsize_s4,
    arburst_s4,
    arlock_s4,
    arcache_s4,
    arprot_s4,
    arvalid_s4,
    arvalid_vect_s4,
    arready_s4,
    ar_qv_s4,

    awuser_s5,
    awid_s5,
    awaddr_s5,
    awlen_s5,
    awsize_s5,
    awburst_s5,
    awlock_s5,
    awcache_s5,
    awprot_s5,
    awvalid_s5,
    awvalid_vect_s5,
    awready_s5,
    aw_qv_s5,
    aruser_s5,
    arid_s5,
    araddr_s5,
    arlen_s5,
    arsize_s5,
    arburst_s5,
    arlock_s5,
    arcache_s5,
    arprot_s5,
    arvalid_s5,
    arvalid_vect_s5,
    arready_s5,
    ar_qv_s5,

    wr_cnt_empty,
    aclk,
    aresetn
  );





  output [9:0]      awuser_m;
  output [11:0]      awid_m;
  output [39:0]     awaddr_m;
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
   
  output [9:0]      aruser_m;
  output [11:0]      arid_m;
  output [39:0]     araddr_m;
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
   
  output [5:0]      aw_sel;
  input             wvalid_m;
  input             wready_m;
  input             wlast_m;
  input             bvalid_m;
  input             bready_m;
  input             rvalid_m;
  input             rready_m;
  input             rlast_m;
  input  [9:0]      awuser_s0;
  input  [11:0]      awid_s0;
  input  [39:0]     awaddr_s0;
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
   
  input  [9:0]      aruser_s0;
  input  [11:0]      arid_s0;
  input  [39:0]     araddr_s0;
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


  input  [9:0]      awuser_s1;
  input  [11:0]      awid_s1;
  input  [39:0]     awaddr_s1;
  input  [7:0]      awlen_s1;
  input  [2:0]      awsize_s1;
  input  [1:0]      awburst_s1;
  input             awlock_s1;
  input  [3:0]      awcache_s1;
  input  [2:0]      awprot_s1;
  input             awvalid_s1;
  input             awvalid_vect_s1;
  output            awready_s1;
  input  [3:0]      aw_qv_s1;
   
  input  [9:0]      aruser_s1;
  input  [11:0]      arid_s1;
  input  [39:0]     araddr_s1;
  input  [7:0]      arlen_s1;
  input  [2:0]      arsize_s1;
  input  [1:0]      arburst_s1;
  input             arlock_s1;
  input  [3:0]      arcache_s1;
  input  [2:0]      arprot_s1;
  input             arvalid_s1;
  input             arvalid_vect_s1;
  output            arready_s1;
  input  [3:0]      ar_qv_s1;


  input  [9:0]      awuser_s2;
  input  [11:0]      awid_s2;
  input  [39:0]     awaddr_s2;
  input  [7:0]      awlen_s2;
  input  [2:0]      awsize_s2;
  input  [1:0]      awburst_s2;
  input             awlock_s2;
  input  [3:0]      awcache_s2;
  input  [2:0]      awprot_s2;
  input             awvalid_s2;
  input             awvalid_vect_s2;
  output            awready_s2;
  input  [3:0]      aw_qv_s2;
   
  input  [9:0]      aruser_s2;
  input  [11:0]      arid_s2;
  input  [39:0]     araddr_s2;
  input  [7:0]      arlen_s2;
  input  [2:0]      arsize_s2;
  input  [1:0]      arburst_s2;
  input             arlock_s2;
  input  [3:0]      arcache_s2;
  input  [2:0]      arprot_s2;
  input             arvalid_s2;
  input             arvalid_vect_s2;
  output            arready_s2;
  input  [3:0]      ar_qv_s2;


  input  [9:0]      awuser_s3;
  input  [11:0]      awid_s3;
  input  [39:0]     awaddr_s3;
  input  [7:0]      awlen_s3;
  input  [2:0]      awsize_s3;
  input  [1:0]      awburst_s3;
  input             awlock_s3;
  input  [3:0]      awcache_s3;
  input  [2:0]      awprot_s3;
  input             awvalid_s3;
  input             awvalid_vect_s3;
  output            awready_s3;
  input  [3:0]      aw_qv_s3;
   
  input  [9:0]      aruser_s3;
  input  [11:0]      arid_s3;
  input  [39:0]     araddr_s3;
  input  [7:0]      arlen_s3;
  input  [2:0]      arsize_s3;
  input  [1:0]      arburst_s3;
  input             arlock_s3;
  input  [3:0]      arcache_s3;
  input  [2:0]      arprot_s3;
  input             arvalid_s3;
  input             arvalid_vect_s3;
  output            arready_s3;
  input  [3:0]      ar_qv_s3;


  input  [9:0]      awuser_s4;
  input  [11:0]      awid_s4;
  input  [39:0]     awaddr_s4;
  input  [7:0]      awlen_s4;
  input  [2:0]      awsize_s4;
  input  [1:0]      awburst_s4;
  input             awlock_s4;
  input  [3:0]      awcache_s4;
  input  [2:0]      awprot_s4;
  input             awvalid_s4;
  input             awvalid_vect_s4;
  output            awready_s4;
  input  [3:0]      aw_qv_s4;
   
  input  [9:0]      aruser_s4;
  input  [11:0]      arid_s4;
  input  [39:0]     araddr_s4;
  input  [7:0]      arlen_s4;
  input  [2:0]      arsize_s4;
  input  [1:0]      arburst_s4;
  input             arlock_s4;
  input  [3:0]      arcache_s4;
  input  [2:0]      arprot_s4;
  input             arvalid_s4;
  input             arvalid_vect_s4;
  output            arready_s4;
  input  [3:0]      ar_qv_s4;


  input  [9:0]      awuser_s5;
  input  [11:0]      awid_s5;
  input  [39:0]     awaddr_s5;
  input  [7:0]      awlen_s5;
  input  [2:0]      awsize_s5;
  input  [1:0]      awburst_s5;
  input             awlock_s5;
  input  [3:0]      awcache_s5;
  input  [2:0]      awprot_s5;
  input             awvalid_s5;
  input             awvalid_vect_s5;
  output            awready_s5;
  input  [3:0]      aw_qv_s5;
   
  input  [9:0]      aruser_s5;
  input  [11:0]      arid_s5;
  input  [39:0]     araddr_s5;
  input  [7:0]      arlen_s5;
  input  [2:0]      arsize_s5;
  input  [1:0]      arburst_s5;
  input             arlock_s5;
  input  [3:0]      arcache_s5;
  input  [2:0]      arprot_s5;
  input             arvalid_s5;
  input             arvalid_vect_s5;
  output            arready_s5;
  input  [3:0]      ar_qv_s5;


  output            wr_cnt_empty;
  input             aclk;
  input             aresetn;

  
  
  wire   [5:0]      aw_valid_vector;
  wire   [5:0]      ar_valid_vector;
  wire   [5:0]      aw_sel_i;
  wire   [5:0]      ar_sel_i;
  wire              last_rd;
  wire   [9:0]      awuser_masked0;
  wire   [11:0]      awid_masked0;
  wire   [39:0]     awaddr_masked0;
  wire   [7:0]      awlen_masked0;
  wire   [2:0]      awsize_masked0;
  wire   [1:0]      awburst_masked0;
  wire              awlock_masked0;
  wire   [3:0]      awcache_masked0;
  wire   [2:0]      awprot_masked0;
  wire   [3:0]      aw_qv_masked0;
  wire              awvalid_masked0;
  wire              awvalid_vect_masked0;
  wire   [9:0]      aruser_masked0;
  wire   [11:0]      arid_masked0;
  wire   [39:0]     araddr_masked0;
  wire   [7:0]      arlen_masked0;
  wire   [2:0]      arsize_masked0;
  wire   [1:0]      arburst_masked0;
  wire              arlock_masked0;
  wire   [3:0]      arcache_masked0;
  wire   [2:0]      arprot_masked0;
  wire   [3:0]      ar_qv_masked0;
  wire              arvalid_masked0;
  wire              arvalid_vect_masked0;

  wire   [9:0]      awuser_masked1;
  wire   [11:0]      awid_masked1;
  wire   [39:0]     awaddr_masked1;
  wire   [7:0]      awlen_masked1;
  wire   [2:0]      awsize_masked1;
  wire   [1:0]      awburst_masked1;
  wire              awlock_masked1;
  wire   [3:0]      awcache_masked1;
  wire   [2:0]      awprot_masked1;
  wire   [3:0]      aw_qv_masked1;
  wire              awvalid_masked1;
  wire              awvalid_vect_masked1;
  wire   [9:0]      aruser_masked1;
  wire   [11:0]      arid_masked1;
  wire   [39:0]     araddr_masked1;
  wire   [7:0]      arlen_masked1;
  wire   [2:0]      arsize_masked1;
  wire   [1:0]      arburst_masked1;
  wire              arlock_masked1;
  wire   [3:0]      arcache_masked1;
  wire   [2:0]      arprot_masked1;
  wire   [3:0]      ar_qv_masked1;
  wire              arvalid_masked1;
  wire              arvalid_vect_masked1;

  wire   [9:0]      awuser_masked2;
  wire   [11:0]      awid_masked2;
  wire   [39:0]     awaddr_masked2;
  wire   [7:0]      awlen_masked2;
  wire   [2:0]      awsize_masked2;
  wire   [1:0]      awburst_masked2;
  wire              awlock_masked2;
  wire   [3:0]      awcache_masked2;
  wire   [2:0]      awprot_masked2;
  wire   [3:0]      aw_qv_masked2;
  wire              awvalid_masked2;
  wire              awvalid_vect_masked2;
  wire   [9:0]      aruser_masked2;
  wire   [11:0]      arid_masked2;
  wire   [39:0]     araddr_masked2;
  wire   [7:0]      arlen_masked2;
  wire   [2:0]      arsize_masked2;
  wire   [1:0]      arburst_masked2;
  wire              arlock_masked2;
  wire   [3:0]      arcache_masked2;
  wire   [2:0]      arprot_masked2;
  wire   [3:0]      ar_qv_masked2;
  wire              arvalid_masked2;
  wire              arvalid_vect_masked2;

  wire   [9:0]      awuser_masked3;
  wire   [11:0]      awid_masked3;
  wire   [39:0]     awaddr_masked3;
  wire   [7:0]      awlen_masked3;
  wire   [2:0]      awsize_masked3;
  wire   [1:0]      awburst_masked3;
  wire              awlock_masked3;
  wire   [3:0]      awcache_masked3;
  wire   [2:0]      awprot_masked3;
  wire   [3:0]      aw_qv_masked3;
  wire              awvalid_masked3;
  wire              awvalid_vect_masked3;
  wire   [9:0]      aruser_masked3;
  wire   [11:0]      arid_masked3;
  wire   [39:0]     araddr_masked3;
  wire   [7:0]      arlen_masked3;
  wire   [2:0]      arsize_masked3;
  wire   [1:0]      arburst_masked3;
  wire              arlock_masked3;
  wire   [3:0]      arcache_masked3;
  wire   [2:0]      arprot_masked3;
  wire   [3:0]      ar_qv_masked3;
  wire              arvalid_masked3;
  wire              arvalid_vect_masked3;

  wire   [9:0]      awuser_masked4;
  wire   [11:0]      awid_masked4;
  wire   [39:0]     awaddr_masked4;
  wire   [7:0]      awlen_masked4;
  wire   [2:0]      awsize_masked4;
  wire   [1:0]      awburst_masked4;
  wire              awlock_masked4;
  wire   [3:0]      awcache_masked4;
  wire   [2:0]      awprot_masked4;
  wire   [3:0]      aw_qv_masked4;
  wire              awvalid_masked4;
  wire              awvalid_vect_masked4;
  wire   [9:0]      aruser_masked4;
  wire   [11:0]      arid_masked4;
  wire   [39:0]     araddr_masked4;
  wire   [7:0]      arlen_masked4;
  wire   [2:0]      arsize_masked4;
  wire   [1:0]      arburst_masked4;
  wire              arlock_masked4;
  wire   [3:0]      arcache_masked4;
  wire   [2:0]      arprot_masked4;
  wire   [3:0]      ar_qv_masked4;
  wire              arvalid_masked4;
  wire              arvalid_vect_masked4;

  wire   [9:0]      awuser_masked5;
  wire   [11:0]      awid_masked5;
  wire   [39:0]     awaddr_masked5;
  wire   [7:0]      awlen_masked5;
  wire   [2:0]      awsize_masked5;
  wire   [1:0]      awburst_masked5;
  wire              awlock_masked5;
  wire   [3:0]      awcache_masked5;
  wire   [2:0]      awprot_masked5;
  wire   [3:0]      aw_qv_masked5;
  wire              awvalid_masked5;
  wire              awvalid_vect_masked5;
  wire   [9:0]      aruser_masked5;
  wire   [11:0]      arid_masked5;
  wire   [39:0]     araddr_masked5;
  wire   [7:0]      arlen_masked5;
  wire   [2:0]      arsize_masked5;
  wire   [1:0]      arburst_masked5;
  wire              arlock_masked5;
  wire   [3:0]      arcache_masked5;
  wire   [2:0]      arprot_masked5;
  wire   [3:0]      ar_qv_masked5;
  wire              arvalid_masked5;
  wire              arvalid_vect_masked5;

  wire   [5:0]      mask_w;
  wire   [5:0]      mask_r;

  wire   [9:0]      awuser_m_i;
  wire   [11:0]      awid_m_i;
  wire   [39:0]     awaddr_m_i;
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
   
  wire   [9:0]      aruser_m_i;
  wire   [11:0]      arid_m_i;
  wire   [39:0]     araddr_m_i;
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

  wire   [20:0]      awuser_in;
  wire   [20:0]      awuser_out;
  wire   [14:0]      aruser_in;
  wire   [14:0]      aruser_out;


  wire   [9:0]      awuser_s0_i;
  wire   [11:0]      awid_s0_i;
  wire   [39:0]     awaddr_s0_i;
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
  
  wire   [9:0]      aruser_s0_i;
  wire   [11:0]      arid_s0_i;
  wire   [39:0]     araddr_s0_i;
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
  

  wire   [9:0]      awuser_s1_i;
  wire   [11:0]      awid_s1_i;
  wire   [39:0]     awaddr_s1_i;
  wire   [7:0]      awlen_s1_i;
  wire   [2:0]      awsize_s1_i;
  wire   [1:0]      awburst_s1_i;
  wire              awlock_s1_i;
  wire   [3:0]      awcache_s1_i;
  wire   [2:0]      awprot_s1_i;
  wire              awvalid_s1_i;
  wire              awvalid_vect_s1_i;
  wire              awready_s1_i;
  wire   [3:0]      aw_qv_s1_i;
  
  wire   [9:0]      aruser_s1_i;
  wire   [11:0]      arid_s1_i;
  wire   [39:0]     araddr_s1_i;
  wire   [7:0]      arlen_s1_i;
  wire   [2:0]      arsize_s1_i;
  wire   [1:0]      arburst_s1_i;
  wire              arlock_s1_i;
  wire   [3:0]      arcache_s1_i;
  wire   [2:0]      arprot_s1_i;
  wire              arvalid_s1_i;
  wire              arvalid_vect_s1_i;
  wire              arready_s1_i;
  wire   [3:0]      ar_qv_s1_i;
  

  wire   [9:0]      awuser_s2_i;
  wire   [11:0]      awid_s2_i;
  wire   [39:0]     awaddr_s2_i;
  wire   [7:0]      awlen_s2_i;
  wire   [2:0]      awsize_s2_i;
  wire   [1:0]      awburst_s2_i;
  wire              awlock_s2_i;
  wire   [3:0]      awcache_s2_i;
  wire   [2:0]      awprot_s2_i;
  wire              awvalid_s2_i;
  wire              awvalid_vect_s2_i;
  wire              awready_s2_i;
  wire   [3:0]      aw_qv_s2_i;
  
  wire   [9:0]      aruser_s2_i;
  wire   [11:0]      arid_s2_i;
  wire   [39:0]     araddr_s2_i;
  wire   [7:0]      arlen_s2_i;
  wire   [2:0]      arsize_s2_i;
  wire   [1:0]      arburst_s2_i;
  wire              arlock_s2_i;
  wire   [3:0]      arcache_s2_i;
  wire   [2:0]      arprot_s2_i;
  wire              arvalid_s2_i;
  wire              arvalid_vect_s2_i;
  wire              arready_s2_i;
  wire   [3:0]      ar_qv_s2_i;
  

  wire   [9:0]      awuser_s3_i;
  wire   [11:0]      awid_s3_i;
  wire   [39:0]     awaddr_s3_i;
  wire   [7:0]      awlen_s3_i;
  wire   [2:0]      awsize_s3_i;
  wire   [1:0]      awburst_s3_i;
  wire              awlock_s3_i;
  wire   [3:0]      awcache_s3_i;
  wire   [2:0]      awprot_s3_i;
  wire              awvalid_s3_i;
  wire              awvalid_vect_s3_i;
  wire              awready_s3_i;
  wire   [3:0]      aw_qv_s3_i;
  
  wire   [9:0]      aruser_s3_i;
  wire   [11:0]      arid_s3_i;
  wire   [39:0]     araddr_s3_i;
  wire   [7:0]      arlen_s3_i;
  wire   [2:0]      arsize_s3_i;
  wire   [1:0]      arburst_s3_i;
  wire              arlock_s3_i;
  wire   [3:0]      arcache_s3_i;
  wire   [2:0]      arprot_s3_i;
  wire              arvalid_s3_i;
  wire              arvalid_vect_s3_i;
  wire              arready_s3_i;
  wire   [3:0]      ar_qv_s3_i;
  

  wire   [9:0]      awuser_s4_i;
  wire   [11:0]      awid_s4_i;
  wire   [39:0]     awaddr_s4_i;
  wire   [7:0]      awlen_s4_i;
  wire   [2:0]      awsize_s4_i;
  wire   [1:0]      awburst_s4_i;
  wire              awlock_s4_i;
  wire   [3:0]      awcache_s4_i;
  wire   [2:0]      awprot_s4_i;
  wire              awvalid_s4_i;
  wire              awvalid_vect_s4_i;
  wire              awready_s4_i;
  wire   [3:0]      aw_qv_s4_i;
  
  wire   [9:0]      aruser_s4_i;
  wire   [11:0]      arid_s4_i;
  wire   [39:0]     araddr_s4_i;
  wire   [7:0]      arlen_s4_i;
  wire   [2:0]      arsize_s4_i;
  wire   [1:0]      arburst_s4_i;
  wire              arlock_s4_i;
  wire   [3:0]      arcache_s4_i;
  wire   [2:0]      arprot_s4_i;
  wire              arvalid_s4_i;
  wire              arvalid_vect_s4_i;
  wire              arready_s4_i;
  wire   [3:0]      ar_qv_s4_i;
  

  wire   [9:0]      awuser_s5_i;
  wire   [11:0]      awid_s5_i;
  wire   [39:0]     awaddr_s5_i;
  wire   [7:0]      awlen_s5_i;
  wire   [2:0]      awsize_s5_i;
  wire   [1:0]      awburst_s5_i;
  wire              awlock_s5_i;
  wire   [3:0]      awcache_s5_i;
  wire   [2:0]      awprot_s5_i;
  wire              awvalid_s5_i;
  wire              awvalid_vect_s5_i;
  wire              awready_s5_i;
  wire   [3:0]      aw_qv_s5_i;
  
  wire   [9:0]      aruser_s5_i;
  wire   [11:0]      arid_s5_i;
  wire   [39:0]     araddr_s5_i;
  wire   [7:0]      arlen_s5_i;
  wire   [2:0]      arsize_s5_i;
  wire   [1:0]      arburst_s5_i;
  wire              arlock_s5_i;
  wire   [3:0]      arcache_s5_i;
  wire   [2:0]      arprot_s5_i;
  wire              arvalid_s5_i;
  wire              arvalid_vect_s5_i;
  wire              arready_s5_i;
  wire   [3:0]      ar_qv_s5_i;
  




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

  assign awuser_s1_i = awuser_s1;
  assign awid_s1_i = awid_s1;
  assign awaddr_s1_i = awaddr_s1;
  assign awlen_s1_i = awlen_s1;
  assign awsize_s1_i = awsize_s1;
  assign awburst_s1_i = awburst_s1;
  assign awlock_s1_i = awlock_s1;
  assign awcache_s1_i = awcache_s1;
  assign awprot_s1_i = awprot_s1;
  assign awvalid_s1_i = awvalid_s1;
  assign awvalid_vect_s1_i = awvalid_vect_s1;
  assign aw_qv_s1_i = aw_qv_s1;
  assign awready_s1 = awready_s1_i;
   
  assign aruser_s1_i = aruser_s1;
  assign arid_s1_i = arid_s1;
  assign araddr_s1_i = araddr_s1;
  assign arlen_s1_i = arlen_s1;
  assign arsize_s1_i = arsize_s1;
  assign arburst_s1_i = arburst_s1;
  assign arlock_s1_i = arlock_s1;
  assign arcache_s1_i = arcache_s1;
  assign arprot_s1_i = arprot_s1;
  assign arvalid_s1_i = arvalid_s1;
  assign arvalid_vect_s1_i = arvalid_vect_s1;
  assign ar_qv_s1_i = ar_qv_s1;
  assign arready_s1 = arready_s1_i;

  assign awuser_s2_i = awuser_s2;
  assign awid_s2_i = awid_s2;
  assign awaddr_s2_i = awaddr_s2;
  assign awlen_s2_i = awlen_s2;
  assign awsize_s2_i = awsize_s2;
  assign awburst_s2_i = awburst_s2;
  assign awlock_s2_i = awlock_s2;
  assign awcache_s2_i = awcache_s2;
  assign awprot_s2_i = awprot_s2;
  assign awvalid_s2_i = awvalid_s2;
  assign awvalid_vect_s2_i = awvalid_vect_s2;
  assign aw_qv_s2_i = aw_qv_s2;
  assign awready_s2 = awready_s2_i;
   
  assign aruser_s2_i = aruser_s2;
  assign arid_s2_i = arid_s2;
  assign araddr_s2_i = araddr_s2;
  assign arlen_s2_i = arlen_s2;
  assign arsize_s2_i = arsize_s2;
  assign arburst_s2_i = arburst_s2;
  assign arlock_s2_i = arlock_s2;
  assign arcache_s2_i = arcache_s2;
  assign arprot_s2_i = arprot_s2;
  assign arvalid_s2_i = arvalid_s2;
  assign arvalid_vect_s2_i = arvalid_vect_s2;
  assign ar_qv_s2_i = ar_qv_s2;
  assign arready_s2 = arready_s2_i;

  assign awuser_s3_i = awuser_s3;
  assign awid_s3_i = awid_s3;
  assign awaddr_s3_i = awaddr_s3;
  assign awlen_s3_i = awlen_s3;
  assign awsize_s3_i = awsize_s3;
  assign awburst_s3_i = awburst_s3;
  assign awlock_s3_i = awlock_s3;
  assign awcache_s3_i = awcache_s3;
  assign awprot_s3_i = awprot_s3;
  assign awvalid_s3_i = awvalid_s3;
  assign awvalid_vect_s3_i = awvalid_vect_s3;
  assign aw_qv_s3_i = aw_qv_s3;
  assign awready_s3 = awready_s3_i;
   
  assign aruser_s3_i = aruser_s3;
  assign arid_s3_i = arid_s3;
  assign araddr_s3_i = araddr_s3;
  assign arlen_s3_i = arlen_s3;
  assign arsize_s3_i = arsize_s3;
  assign arburst_s3_i = arburst_s3;
  assign arlock_s3_i = arlock_s3;
  assign arcache_s3_i = arcache_s3;
  assign arprot_s3_i = arprot_s3;
  assign arvalid_s3_i = arvalid_s3;
  assign arvalid_vect_s3_i = arvalid_vect_s3;
  assign ar_qv_s3_i = ar_qv_s3;
  assign arready_s3 = arready_s3_i;

  assign awuser_s4_i = awuser_s4;
  assign awid_s4_i = awid_s4;
  assign awaddr_s4_i = awaddr_s4;
  assign awlen_s4_i = awlen_s4;
  assign awsize_s4_i = awsize_s4;
  assign awburst_s4_i = awburst_s4;
  assign awlock_s4_i = awlock_s4;
  assign awcache_s4_i = awcache_s4;
  assign awprot_s4_i = awprot_s4;
  assign awvalid_s4_i = awvalid_s4;
  assign awvalid_vect_s4_i = awvalid_vect_s4;
  assign aw_qv_s4_i = aw_qv_s4;
  assign awready_s4 = awready_s4_i;
   
  assign aruser_s4_i = aruser_s4;
  assign arid_s4_i = arid_s4;
  assign araddr_s4_i = araddr_s4;
  assign arlen_s4_i = arlen_s4;
  assign arsize_s4_i = arsize_s4;
  assign arburst_s4_i = arburst_s4;
  assign arlock_s4_i = arlock_s4;
  assign arcache_s4_i = arcache_s4;
  assign arprot_s4_i = arprot_s4;
  assign arvalid_s4_i = arvalid_s4;
  assign arvalid_vect_s4_i = arvalid_vect_s4;
  assign ar_qv_s4_i = ar_qv_s4;
  assign arready_s4 = arready_s4_i;

  assign awuser_s5_i = awuser_s5;
  assign awid_s5_i = awid_s5;
  assign awaddr_s5_i = awaddr_s5;
  assign awlen_s5_i = awlen_s5;
  assign awsize_s5_i = awsize_s5;
  assign awburst_s5_i = awburst_s5;
  assign awlock_s5_i = awlock_s5;
  assign awcache_s5_i = awcache_s5;
  assign awprot_s5_i = awprot_s5;
  assign awvalid_s5_i = awvalid_s5;
  assign awvalid_vect_s5_i = awvalid_vect_s5;
  assign aw_qv_s5_i = aw_qv_s5;
  assign awready_s5 = awready_s5_i;
   
  assign aruser_s5_i = aruser_s5;
  assign arid_s5_i = arid_s5;
  assign araddr_s5_i = araddr_s5;
  assign arlen_s5_i = arlen_s5;
  assign arsize_s5_i = arsize_s5;
  assign arburst_s5_i = arburst_s5;
  assign arlock_s5_i = arlock_s5;
  assign arcache_s5_i = arcache_s5;
  assign arprot_s5_i = arprot_s5;
  assign arvalid_s5_i = arvalid_s5;
  assign arvalid_vect_s5_i = arvalid_vect_s5;
  assign ar_qv_s5_i = ar_qv_s5;
  assign arready_s5 = arready_s5_i;



nic400_switch2_maskcntl_ml7_sse710_main u_nic400_switch2_maskcntl_ml7_sse710_main (
        .awvalid_m    (awvalid_m_i),
        .awready_m    (awready_m_i),
        .arvalid_m    (arvalid_m_i),
        .arready_m    (arready_m_i),
        .wvalid_m     (wvalid_m),
        .wready_m     (wready_m),
        .wlast_m      (wlast_m),

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
   assign aw_valid_vector[0] = awvalid_s0_i;
   assign aw_valid_vector[1] = awvalid_s1_i;
   assign aw_valid_vector[2] = awvalid_s2_i;
   assign aw_valid_vector[3] = awvalid_s3_i;
   assign aw_valid_vector[4] = awvalid_s4_i;
   assign aw_valid_vector[5] = awvalid_s5_i;
   assign ar_valid_vector[0] = arvalid_s0_i;
   assign ar_valid_vector[1] = arvalid_s1_i;
   assign ar_valid_vector[2] = arvalid_s2_i;
   assign ar_valid_vector[3] = arvalid_s3_i;
   assign ar_valid_vector[4] = arvalid_s4_i;
   assign ar_valid_vector[5] = arvalid_s5_i;

nic400_switch2_add_arb_ml7_sse710_main u_nic400_switch2_aw_arb_ml7_sse710_main (
        .a_sel          (aw_sel_i),
        .a_valid_vector (aw_valid_vector),
        .aready         (awready_m_i),
        .mask           (mask_w),
        .qv0            (aw_qv_s0_i),
        .qv1            (aw_qv_s1_i),
        .qv2            (aw_qv_s2_i),
        .qv3            (aw_qv_s3_i),
        .qv4            (aw_qv_s4_i),
        .qv5            (aw_qv_s5_i),
        .aclk           (aclk),
        .aresetn        (aresetn)
);

nic400_switch2_add_arb_ml7_sse710_main u_nic400_switch2_ar_arb_ml7_sse710_main (
        .a_sel          (ar_sel_i),
        .a_valid_vector (ar_valid_vector),
        .aready         (arready_m_i),
        .mask           (mask_r),
        .qv0            (ar_qv_s0_i),
        .qv1            (ar_qv_s1_i),
        .qv2            (ar_qv_s2_i),
        .qv3            (ar_qv_s3_i),
        .qv4            (ar_qv_s4_i),
        .qv5            (ar_qv_s5_i),
        .aclk          (aclk),
        .aresetn       (aresetn)
);


    assign awuser_masked0  = awuser_s0_i & {10{aw_sel_i[0]}}; 
    assign awid_masked0    = awid_s0_i & {12{aw_sel_i[0]}};
    assign awaddr_masked0  = awaddr_s0_i & {40{aw_sel_i[0]}};
    assign awlen_masked0   = awlen_s0_i & {8{aw_sel_i[0]}};
    assign awsize_masked0  = awsize_s0_i & {3{aw_sel_i[0]}};
    assign awburst_masked0 = awburst_s0_i & {2{aw_sel_i[0]}};
    assign awlock_masked0  = awlock_s0_i & {1{aw_sel_i[0]}};
    assign awcache_masked0 = awcache_s0_i & {4{aw_sel_i[0]}};
    assign awprot_masked0  = awprot_s0_i & {3{aw_sel_i[0]}};
    assign aw_qv_masked0   = aw_qv_s0_i & {4{aw_sel_i[0]}};
    assign awvalid_masked0 = awvalid_s0_i & aw_sel_i[0];
    assign awvalid_vect_masked0 = awvalid_vect_s0_i & aw_sel_i[0];
  
    assign aruser_masked0  = aruser_s0_i & {10{ar_sel_i[0]}};
    assign arid_masked0   = arid_s0_i & {12{ar_sel_i[0]}};
    assign araddr_masked0  = araddr_s0_i & {40{ar_sel_i[0]}};
    assign arlen_masked0   = arlen_s0_i & {8{ar_sel_i[0]}};
    assign arsize_masked0  = arsize_s0_i & {3{ar_sel_i[0]}};
    assign arburst_masked0 = arburst_s0_i & {2{ar_sel_i[0]}};
    assign arlock_masked0  = arlock_s0_i & {1{ar_sel_i[0]}};
    assign arcache_masked0 = arcache_s0_i & {4{ar_sel_i[0]}};
    assign arprot_masked0  = arprot_s0_i & {3{ar_sel_i[0]}};
    assign ar_qv_masked0   = ar_qv_s0_i & {4{ar_sel_i[0]}};
    assign arvalid_masked0 = arvalid_s0_i & ar_sel_i[0];
    assign arvalid_vect_masked0 = arvalid_vect_s0_i & ar_sel_i[0];

    assign awuser_masked1  = awuser_s1_i & {10{aw_sel_i[1]}}; 
    assign awid_masked1    = awid_s1_i & {12{aw_sel_i[1]}};
    assign awaddr_masked1  = awaddr_s1_i & {40{aw_sel_i[1]}};
    assign awlen_masked1   = awlen_s1_i & {8{aw_sel_i[1]}};
    assign awsize_masked1  = awsize_s1_i & {3{aw_sel_i[1]}};
    assign awburst_masked1 = awburst_s1_i & {2{aw_sel_i[1]}};
    assign awlock_masked1  = awlock_s1_i & {1{aw_sel_i[1]}};
    assign awcache_masked1 = awcache_s1_i & {4{aw_sel_i[1]}};
    assign awprot_masked1  = awprot_s1_i & {3{aw_sel_i[1]}};
    assign aw_qv_masked1   = aw_qv_s1_i & {4{aw_sel_i[1]}};
    assign awvalid_masked1 = awvalid_s1_i & aw_sel_i[1];
    assign awvalid_vect_masked1 = awvalid_vect_s1_i & aw_sel_i[1];
  
    assign aruser_masked1  = aruser_s1_i & {10{ar_sel_i[1]}};
    assign arid_masked1   = arid_s1_i & {12{ar_sel_i[1]}};
    assign araddr_masked1  = araddr_s1_i & {40{ar_sel_i[1]}};
    assign arlen_masked1   = arlen_s1_i & {8{ar_sel_i[1]}};
    assign arsize_masked1  = arsize_s1_i & {3{ar_sel_i[1]}};
    assign arburst_masked1 = arburst_s1_i & {2{ar_sel_i[1]}};
    assign arlock_masked1  = arlock_s1_i & {1{ar_sel_i[1]}};
    assign arcache_masked1 = arcache_s1_i & {4{ar_sel_i[1]}};
    assign arprot_masked1  = arprot_s1_i & {3{ar_sel_i[1]}};
    assign ar_qv_masked1   = ar_qv_s1_i & {4{ar_sel_i[1]}};
    assign arvalid_masked1 = arvalid_s1_i & ar_sel_i[1];
    assign arvalid_vect_masked1 = arvalid_vect_s1_i & ar_sel_i[1];

    assign awuser_masked2  = awuser_s2_i & {10{aw_sel_i[2]}}; 
    assign awid_masked2    = awid_s2_i & {12{aw_sel_i[2]}};
    assign awaddr_masked2  = awaddr_s2_i & {40{aw_sel_i[2]}};
    assign awlen_masked2   = awlen_s2_i & {8{aw_sel_i[2]}};
    assign awsize_masked2  = awsize_s2_i & {3{aw_sel_i[2]}};
    assign awburst_masked2 = awburst_s2_i & {2{aw_sel_i[2]}};
    assign awlock_masked2  = awlock_s2_i & {1{aw_sel_i[2]}};
    assign awcache_masked2 = awcache_s2_i & {4{aw_sel_i[2]}};
    assign awprot_masked2  = awprot_s2_i & {3{aw_sel_i[2]}};
    assign aw_qv_masked2   = aw_qv_s2_i & {4{aw_sel_i[2]}};
    assign awvalid_masked2 = awvalid_s2_i & aw_sel_i[2];
    assign awvalid_vect_masked2 = awvalid_vect_s2_i & aw_sel_i[2];
  
    assign aruser_masked2  = aruser_s2_i & {10{ar_sel_i[2]}};
    assign arid_masked2   = arid_s2_i & {12{ar_sel_i[2]}};
    assign araddr_masked2  = araddr_s2_i & {40{ar_sel_i[2]}};
    assign arlen_masked2   = arlen_s2_i & {8{ar_sel_i[2]}};
    assign arsize_masked2  = arsize_s2_i & {3{ar_sel_i[2]}};
    assign arburst_masked2 = arburst_s2_i & {2{ar_sel_i[2]}};
    assign arlock_masked2  = arlock_s2_i & {1{ar_sel_i[2]}};
    assign arcache_masked2 = arcache_s2_i & {4{ar_sel_i[2]}};
    assign arprot_masked2  = arprot_s2_i & {3{ar_sel_i[2]}};
    assign ar_qv_masked2   = ar_qv_s2_i & {4{ar_sel_i[2]}};
    assign arvalid_masked2 = arvalid_s2_i & ar_sel_i[2];
    assign arvalid_vect_masked2 = arvalid_vect_s2_i & ar_sel_i[2];

    assign awuser_masked3  = awuser_s3_i & {10{aw_sel_i[3]}}; 
    assign awid_masked3    = awid_s3_i & {12{aw_sel_i[3]}};
    assign awaddr_masked3  = awaddr_s3_i & {40{aw_sel_i[3]}};
    assign awlen_masked3   = awlen_s3_i & {8{aw_sel_i[3]}};
    assign awsize_masked3  = awsize_s3_i & {3{aw_sel_i[3]}};
    assign awburst_masked3 = awburst_s3_i & {2{aw_sel_i[3]}};
    assign awlock_masked3  = awlock_s3_i & {1{aw_sel_i[3]}};
    assign awcache_masked3 = awcache_s3_i & {4{aw_sel_i[3]}};
    assign awprot_masked3  = awprot_s3_i & {3{aw_sel_i[3]}};
    assign aw_qv_masked3   = aw_qv_s3_i & {4{aw_sel_i[3]}};
    assign awvalid_masked3 = awvalid_s3_i & aw_sel_i[3];
    assign awvalid_vect_masked3 = awvalid_vect_s3_i & aw_sel_i[3];
  
    assign aruser_masked3  = aruser_s3_i & {10{ar_sel_i[3]}};
    assign arid_masked3   = arid_s3_i & {12{ar_sel_i[3]}};
    assign araddr_masked3  = araddr_s3_i & {40{ar_sel_i[3]}};
    assign arlen_masked3   = arlen_s3_i & {8{ar_sel_i[3]}};
    assign arsize_masked3  = arsize_s3_i & {3{ar_sel_i[3]}};
    assign arburst_masked3 = arburst_s3_i & {2{ar_sel_i[3]}};
    assign arlock_masked3  = arlock_s3_i & {1{ar_sel_i[3]}};
    assign arcache_masked3 = arcache_s3_i & {4{ar_sel_i[3]}};
    assign arprot_masked3  = arprot_s3_i & {3{ar_sel_i[3]}};
    assign ar_qv_masked3   = ar_qv_s3_i & {4{ar_sel_i[3]}};
    assign arvalid_masked3 = arvalid_s3_i & ar_sel_i[3];
    assign arvalid_vect_masked3 = arvalid_vect_s3_i & ar_sel_i[3];

    assign awuser_masked4  = awuser_s4_i & {10{aw_sel_i[4]}}; 
    assign awid_masked4    = awid_s4_i & {12{aw_sel_i[4]}};
    assign awaddr_masked4  = awaddr_s4_i & {40{aw_sel_i[4]}};
    assign awlen_masked4   = awlen_s4_i & {8{aw_sel_i[4]}};
    assign awsize_masked4  = awsize_s4_i & {3{aw_sel_i[4]}};
    assign awburst_masked4 = awburst_s4_i & {2{aw_sel_i[4]}};
    assign awlock_masked4  = awlock_s4_i & {1{aw_sel_i[4]}};
    assign awcache_masked4 = awcache_s4_i & {4{aw_sel_i[4]}};
    assign awprot_masked4  = awprot_s4_i & {3{aw_sel_i[4]}};
    assign aw_qv_masked4   = aw_qv_s4_i & {4{aw_sel_i[4]}};
    assign awvalid_masked4 = awvalid_s4_i & aw_sel_i[4];
    assign awvalid_vect_masked4 = awvalid_vect_s4_i & aw_sel_i[4];
  
    assign aruser_masked4  = aruser_s4_i & {10{ar_sel_i[4]}};
    assign arid_masked4   = arid_s4_i & {12{ar_sel_i[4]}};
    assign araddr_masked4  = araddr_s4_i & {40{ar_sel_i[4]}};
    assign arlen_masked4   = arlen_s4_i & {8{ar_sel_i[4]}};
    assign arsize_masked4  = arsize_s4_i & {3{ar_sel_i[4]}};
    assign arburst_masked4 = arburst_s4_i & {2{ar_sel_i[4]}};
    assign arlock_masked4  = arlock_s4_i & {1{ar_sel_i[4]}};
    assign arcache_masked4 = arcache_s4_i & {4{ar_sel_i[4]}};
    assign arprot_masked4  = arprot_s4_i & {3{ar_sel_i[4]}};
    assign ar_qv_masked4   = ar_qv_s4_i & {4{ar_sel_i[4]}};
    assign arvalid_masked4 = arvalid_s4_i & ar_sel_i[4];
    assign arvalid_vect_masked4 = arvalid_vect_s4_i & ar_sel_i[4];

    assign awuser_masked5  = awuser_s5_i & {10{aw_sel_i[5]}}; 
    assign awid_masked5    = awid_s5_i & {12{aw_sel_i[5]}};
    assign awaddr_masked5  = awaddr_s5_i & {40{aw_sel_i[5]}};
    assign awlen_masked5   = awlen_s5_i & {8{aw_sel_i[5]}};
    assign awsize_masked5  = awsize_s5_i & {3{aw_sel_i[5]}};
    assign awburst_masked5 = awburst_s5_i & {2{aw_sel_i[5]}};
    assign awlock_masked5  = awlock_s5_i & {1{aw_sel_i[5]}};
    assign awcache_masked5 = awcache_s5_i & {4{aw_sel_i[5]}};
    assign awprot_masked5  = awprot_s5_i & {3{aw_sel_i[5]}};
    assign aw_qv_masked5   = aw_qv_s5_i & {4{aw_sel_i[5]}};
    assign awvalid_masked5 = awvalid_s5_i & aw_sel_i[5];
    assign awvalid_vect_masked5 = awvalid_vect_s5_i & aw_sel_i[5];
  
    assign aruser_masked5  = aruser_s5_i & {10{ar_sel_i[5]}};
    assign arid_masked5   = arid_s5_i & {12{ar_sel_i[5]}};
    assign araddr_masked5  = araddr_s5_i & {40{ar_sel_i[5]}};
    assign arlen_masked5   = arlen_s5_i & {8{ar_sel_i[5]}};
    assign arsize_masked5  = arsize_s5_i & {3{ar_sel_i[5]}};
    assign arburst_masked5 = arburst_s5_i & {2{ar_sel_i[5]}};
    assign arlock_masked5  = arlock_s5_i & {1{ar_sel_i[5]}};
    assign arcache_masked5 = arcache_s5_i & {4{ar_sel_i[5]}};
    assign arprot_masked5  = arprot_s5_i & {3{ar_sel_i[5]}};
    assign ar_qv_masked5   = ar_qv_s5_i & {4{ar_sel_i[5]}};
    assign arvalid_masked5 = arvalid_s5_i & ar_sel_i[5];
    assign arvalid_vect_masked5 = arvalid_vect_s5_i & ar_sel_i[5];



    assign awuser_m_i  = awuser_masked0
                       | awuser_masked1
                       | awuser_masked2
                       | awuser_masked3
                       | awuser_masked4
                       | awuser_masked5;
    assign awid_m_i    = awid_masked0
                       | awid_masked1
                       | awid_masked2
                       | awid_masked3
                       | awid_masked4
                       | awid_masked5;
    assign awaddr_m_i  = awaddr_masked0
                       | awaddr_masked1
                       | awaddr_masked2
                       | awaddr_masked3
                       | awaddr_masked4
                       | awaddr_masked5;
    assign awlen_m_i   = awlen_masked0
                       | awlen_masked1
                       | awlen_masked2
                       | awlen_masked3
                       | awlen_masked4
                       | awlen_masked5;
    assign awsize_m_i  = awsize_masked0
                       | awsize_masked1
                       | awsize_masked2
                       | awsize_masked3
                       | awsize_masked4
                       | awsize_masked5;
    assign awburst_m_i = awburst_masked0
                       | awburst_masked1
                       | awburst_masked2
                       | awburst_masked3
                       | awburst_masked4
                       | awburst_masked5;
    assign awlock_m_i  = awlock_masked0
                       | awlock_masked1
                       | awlock_masked2
                       | awlock_masked3
                       | awlock_masked4
                       | awlock_masked5;
    assign awcache_m_i = awcache_masked0
                       | awcache_masked1
                       | awcache_masked2
                       | awcache_masked3
                       | awcache_masked4
                       | awcache_masked5;
    assign awprot_m_i  = awprot_masked0
                       | awprot_masked1
                       | awprot_masked2
                       | awprot_masked3
                       | awprot_masked4
                       | awprot_masked5;
    assign aw_qv_m_i   = aw_qv_masked0
                       | aw_qv_masked1
                       | aw_qv_masked2
                       | aw_qv_masked3
                       | aw_qv_masked4
                       | aw_qv_masked5;
    assign awvalid_m_i = (awvalid_masked0
                      | awvalid_masked1
                      | awvalid_masked2
                      | awvalid_masked3
                      | awvalid_masked4
                      | awvalid_masked5);
     assign awvalid_vect_m_i = (awvalid_vect_masked0
                      | awvalid_vect_masked1
                      | awvalid_vect_masked2
                      | awvalid_vect_masked3
                      | awvalid_vect_masked4
                      | awvalid_vect_masked5);
  
    assign aruser_m_i  = aruser_masked0
                       | aruser_masked1
                       | aruser_masked2
                       | aruser_masked3
                       | aruser_masked4
                       | aruser_masked5;
    assign arid_m_i    = arid_masked0
                       | arid_masked1
                       | arid_masked2
                       | arid_masked3
                       | arid_masked4
                       | arid_masked5;
    assign araddr_m_i  = araddr_masked0
                       | araddr_masked1
                       | araddr_masked2
                       | araddr_masked3
                       | araddr_masked4
                       | araddr_masked5;
    assign arlen_m_i   = arlen_masked0
                       | arlen_masked1
                       | arlen_masked2
                       | arlen_masked3
                       | arlen_masked4
                       | arlen_masked5;
    assign arsize_m_i  = arsize_masked0
                       | arsize_masked1
                       | arsize_masked2
                       | arsize_masked3
                       | arsize_masked4
                       | arsize_masked5;
    assign arburst_m_i = arburst_masked0
                       | arburst_masked1
                       | arburst_masked2
                       | arburst_masked3
                       | arburst_masked4
                       | arburst_masked5;
    assign arlock_m_i  = arlock_masked0
                       | arlock_masked1
                       | arlock_masked2
                       | arlock_masked3
                       | arlock_masked4
                       | arlock_masked5;
    assign arcache_m_i = arcache_masked0
                       | arcache_masked1
                       | arcache_masked2
                       | arcache_masked3
                       | arcache_masked4
                       | arcache_masked5;
    assign arprot_m_i  = arprot_masked0
                       | arprot_masked1
                       | arprot_masked2
                       | arprot_masked3
                       | arprot_masked4
                       | arprot_masked5;
    assign ar_qv_m_i   = ar_qv_masked0
                       | ar_qv_masked1
                       | ar_qv_masked2
                       | ar_qv_masked3
                       | ar_qv_masked4
                       | ar_qv_masked5;
    assign arvalid_m_i = (arvalid_masked0
                       | arvalid_masked1
                       | arvalid_masked2
                       | arvalid_masked3
                       | arvalid_masked4
                       | arvalid_masked5);
    assign arvalid_vect_m_i = (arvalid_vect_masked0
                       | arvalid_vect_masked1
                       | arvalid_vect_masked2
                       | arvalid_vect_masked3
                       | arvalid_vect_masked4
                       | arvalid_vect_masked5);


    assign awready_s0_i     = awready_m_i & aw_sel_i[0];
    assign arready_s0_i     = arready_m_i & ar_sel_i[0];

    assign awready_s1_i     = awready_m_i & aw_sel_i[1];
    assign arready_s1_i     = arready_m_i & ar_sel_i[1];

    assign awready_s2_i     = awready_m_i & aw_sel_i[2];
    assign arready_s2_i     = arready_m_i & ar_sel_i[2];

    assign awready_s3_i     = awready_m_i & aw_sel_i[3];
    assign arready_s3_i     = arready_m_i & ar_sel_i[3];

    assign awready_s4_i     = awready_m_i & aw_sel_i[4];
    assign arready_s4_i     = arready_m_i & ar_sel_i[4];

    assign awready_s5_i     = awready_m_i & aw_sel_i[5];
    assign arready_s5_i     = arready_m_i & ar_sel_i[5];

   assign awuser_in         = {awuser_m_i, aw_qv_m_i, (aw_sel_i), awvalid_vect_m_i};
   assign awvalid_vect_m    = awuser_out[0:0] & {1{awvalid_m}};
   assign aw_sel            = awuser_out[6:1] & {6{awvalid_m}};
   assign aw_qv_m           = awuser_out[10:7];

   assign awuser_m          = awuser_out[20:11];

nic400_ax4_reg_slice_sse710_main
  #(12, 21, `RS_FWD_REG, 40)
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
   assign aruser_m       = aruser_out[14:5];
   assign arvalid_vect_m = aruser_out[0:0] & {1{arvalid_m}};


  nic400_ax4_reg_slice_sse710_main
  #(12, 15, `RS_FWD_REG, 40)
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


