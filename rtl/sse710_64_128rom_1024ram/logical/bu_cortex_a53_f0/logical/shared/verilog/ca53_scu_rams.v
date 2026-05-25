//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------


// This is the specification for the interface between the SCU and the RAMs.
// This includes L2 tags, L2 data, and L1 duplicate tags.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_scu_rams_defs.v"
`include "cortexa53params.v"
`include "ca53scu_defs.v"
`include "cortexa53params.v"

module ca53_scu_rams #(parameter L2_CACHE             = 0, parameter CPU_CACHE_PROTECTION = 1'b0, parameter SCU_CACHE_PROTECTION = 1'b0, parameter L2_INPUT_LATENCY     = 1'b0, parameter L2_OUTPUT_LATENCY    = 1'b0, parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input [`CA53_L1DC_SIZE_W-1:0] l1_dc_size_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu0_way0_rdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu0_way1_rdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu0_way2_rdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu0_way3_rdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu1_way0_rdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu1_way1_rdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu1_way2_rdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu1_way3_rdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu2_way0_rdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu2_way1_rdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu2_way2_rdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu2_way3_rdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu3_way0_rdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu3_way1_rdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu3_way2_rdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu3_way3_rdata_i,
  input [`CA53_L2_SIZE_W-1:0] l2_size_i,
  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way0_rdata_i,
  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way1_rdata_i,
  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way2_rdata_i,
  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way3_rdata_i,
  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way4_rdata_i,
  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way5_rdata_i,
  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way6_rdata_i,
  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way7_rdata_i,
  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way8_rdata_i,
  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way9_rdata_i,
  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way10_rdata_i,
  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way11_rdata_i,
  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way12_rdata_i,
  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way13_rdata_i,
  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way14_rdata_i,
  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way15_rdata_i,
  input [`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0] l2_victimram_rdata_i,
  input [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata0_i,
  input [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata1_i,
  input [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata2_i,
  input [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata3_i,
  input [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata4_i,
  input [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata5_i,
  input [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata6_i,
  input [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata7_i,
  input         gov_l2_in_retention_i,
  input         l1d_tagram_clken_i,
  input   [3:0] l1d_tagram_cpu0_en_i,
  input   [3:0] l1d_tagram_cpu1_en_i,
  input   [3:0] l1d_tagram_cpu2_en_i,
  input   [3:0] l1d_tagram_cpu3_en_i,
  input         l1d_tagram_cpu0_wr_i,
  input         l1d_tagram_cpu1_wr_i,
  input         l1d_tagram_cpu2_wr_i,
  input         l1d_tagram_cpu3_wr_i,
  input [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0] l1d_tagram_cpu0_addr_i,
  input [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0] l1d_tagram_cpu1_addr_i,
  input [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0] l1d_tagram_cpu2_addr_i,
  input [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0] l1d_tagram_cpu3_addr_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu0_wdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu1_wdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu2_wdata_i,
  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu3_wdata_i,
  input         l2_tagram_clken_i,
  input  [15:0] l2_tagram_en_i,
  input         l2_tagram_wr_i,
  input [`CA53_SCU_L2_TAGRAM_ADDR_W-1:0] l2_tagram_addr_i,
  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_wdata_i,
  input         l2_victimram_clken_i,
  input         l2_victimram_en_i,
  input         l2_victimram_no_acc_next_cycle_i,
  input         l2_victimram_wr_i,
  input [`CA53_SCU_L2_VICTIMRAM_STRB_W-1:0] l2_victimram_strb_i,
  input [`CA53_SCU_L2_VICTIMRAM_ADDR_W-1:0] l2_victimram_addr_i,
  input [`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0] l2_victimram_wdata_i,
  input [`CA53_SCU_L2_DATARAM_EN_W-1:0] l2_dataram_clken_i,
  input         l2_dataram_no_acc_next_cycle_i,
  input [`CA53_SCU_L2_DATARAM_EN_W-1:0] l2_dataram_en_i,
  input         l2_dataram_wr_i,
  input [`CA53_SCU_L2_DATARAM_ADDR_W-1:0] l2_dataram_addr_i,
  input [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata0_i,
  input [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata1_i,
  input [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata2_i,
  input [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata3_i,
  input [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata4_i,
  input [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata5_i,
  input [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata6_i,
  input [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata7_i);


  wire [`CA53_L1DC_SIZE_W-1:0] l1_dc_size = l1_dc_size_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu0_way0_rdata = l1d_tagram_cpu0_way0_rdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu0_way1_rdata = l1d_tagram_cpu0_way1_rdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu0_way2_rdata = l1d_tagram_cpu0_way2_rdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu0_way3_rdata = l1d_tagram_cpu0_way3_rdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu1_way0_rdata = l1d_tagram_cpu1_way0_rdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu1_way1_rdata = l1d_tagram_cpu1_way1_rdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu1_way2_rdata = l1d_tagram_cpu1_way2_rdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu1_way3_rdata = l1d_tagram_cpu1_way3_rdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu2_way0_rdata = l1d_tagram_cpu2_way0_rdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu2_way1_rdata = l1d_tagram_cpu2_way1_rdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu2_way2_rdata = l1d_tagram_cpu2_way2_rdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu2_way3_rdata = l1d_tagram_cpu2_way3_rdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu3_way0_rdata = l1d_tagram_cpu3_way0_rdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu3_way1_rdata = l1d_tagram_cpu3_way1_rdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu3_way2_rdata = l1d_tagram_cpu3_way2_rdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu3_way3_rdata = l1d_tagram_cpu3_way3_rdata_i;
  wire [`CA53_L2_SIZE_W-1:0] l2_size = l2_size_i;
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way0_rdata = l2_tagram_way0_rdata_i;
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way1_rdata = l2_tagram_way1_rdata_i;
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way2_rdata = l2_tagram_way2_rdata_i;
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way3_rdata = l2_tagram_way3_rdata_i;
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way4_rdata = l2_tagram_way4_rdata_i;
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way5_rdata = l2_tagram_way5_rdata_i;
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way6_rdata = l2_tagram_way6_rdata_i;
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way7_rdata = l2_tagram_way7_rdata_i;
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way8_rdata = l2_tagram_way8_rdata_i;
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way9_rdata = l2_tagram_way9_rdata_i;
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way10_rdata = l2_tagram_way10_rdata_i;
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way11_rdata = l2_tagram_way11_rdata_i;
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way12_rdata = l2_tagram_way12_rdata_i;
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way13_rdata = l2_tagram_way13_rdata_i;
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way14_rdata = l2_tagram_way14_rdata_i;
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way15_rdata = l2_tagram_way15_rdata_i;
  wire [`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0] l2_victimram_rdata = l2_victimram_rdata_i;
  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata0 = l2_dataram_rdata0_i;
  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata1 = l2_dataram_rdata1_i;
  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata2 = l2_dataram_rdata2_i;
  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata3 = l2_dataram_rdata3_i;
  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata4 = l2_dataram_rdata4_i;
  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata5 = l2_dataram_rdata5_i;
  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata6 = l2_dataram_rdata6_i;
  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata7 = l2_dataram_rdata7_i;
  wire         gov_l2_in_retention = gov_l2_in_retention_i;
  wire         l1d_tagram_clken = l1d_tagram_clken_i;
  wire   [3:0] l1d_tagram_cpu0_en = l1d_tagram_cpu0_en_i;
  wire   [3:0] l1d_tagram_cpu1_en = l1d_tagram_cpu1_en_i;
  wire   [3:0] l1d_tagram_cpu2_en = l1d_tagram_cpu2_en_i;
  wire   [3:0] l1d_tagram_cpu3_en = l1d_tagram_cpu3_en_i;
  wire         l1d_tagram_cpu0_wr = l1d_tagram_cpu0_wr_i;
  wire         l1d_tagram_cpu1_wr = l1d_tagram_cpu1_wr_i;
  wire         l1d_tagram_cpu2_wr = l1d_tagram_cpu2_wr_i;
  wire         l1d_tagram_cpu3_wr = l1d_tagram_cpu3_wr_i;
  wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0] l1d_tagram_cpu0_addr = l1d_tagram_cpu0_addr_i;
  wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0] l1d_tagram_cpu1_addr = l1d_tagram_cpu1_addr_i;
  wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0] l1d_tagram_cpu2_addr = l1d_tagram_cpu2_addr_i;
  wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0] l1d_tagram_cpu3_addr = l1d_tagram_cpu3_addr_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu0_wdata = l1d_tagram_cpu0_wdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu1_wdata = l1d_tagram_cpu1_wdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu2_wdata = l1d_tagram_cpu2_wdata_i;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu3_wdata = l1d_tagram_cpu3_wdata_i;
  wire         l2_tagram_clken = l2_tagram_clken_i;
  wire  [15:0] l2_tagram_en = l2_tagram_en_i;
  wire         l2_tagram_wr = l2_tagram_wr_i;
  wire [`CA53_SCU_L2_TAGRAM_ADDR_W-1:0] l2_tagram_addr = l2_tagram_addr_i;
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_wdata = l2_tagram_wdata_i;
  wire         l2_victimram_clken = l2_victimram_clken_i;
  wire         l2_victimram_en = l2_victimram_en_i;
  wire         l2_victimram_no_acc_next_cycle = l2_victimram_no_acc_next_cycle_i;
  wire         l2_victimram_wr = l2_victimram_wr_i;
  wire [`CA53_SCU_L2_VICTIMRAM_STRB_W-1:0] l2_victimram_strb = l2_victimram_strb_i;
  wire [`CA53_SCU_L2_VICTIMRAM_ADDR_W-1:0] l2_victimram_addr = l2_victimram_addr_i;
  wire [`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0] l2_victimram_wdata = l2_victimram_wdata_i;
  wire [`CA53_SCU_L2_DATARAM_EN_W-1:0] l2_dataram_clken = l2_dataram_clken_i;
  wire         l2_dataram_no_acc_next_cycle = l2_dataram_no_acc_next_cycle_i;
  wire [`CA53_SCU_L2_DATARAM_EN_W-1:0] l2_dataram_en = l2_dataram_en_i;
  wire         l2_dataram_wr = l2_dataram_wr_i;
  wire [`CA53_SCU_L2_DATARAM_ADDR_W-1:0] l2_dataram_addr = l2_dataram_addr_i;
  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata0 = l2_dataram_wdata0_i;
  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata1 = l2_dataram_wdata1_i;
  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata2 = l2_dataram_wdata2_i;
  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata3 = l2_dataram_wdata3_i;
  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata4 = l2_dataram_wdata4_i;
  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata5 = l2_dataram_wdata5_i;
  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata6 = l2_dataram_wdata6_i;
  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata7 = l2_dataram_wdata7_i;

  wire         in_retention;

  reg   [4:0] data_ram_count_32;
  reg   [4:0] victim_ram_count_32;
  reg         reset_done;

  reg [`CA53_L2_SIZE_W-1:0] l2_size_reg;
  reg   [3:0] l1d_tagram_cpu0_en_reg;
  reg [`CA53_SCU_L2_DATARAM_EN_W-1:0] l2_dataram_en_reg;
  reg [`CA53_SCU_L2_DATARAM_EN_W-1:0] l2_dataram_en_reg_reg;
  reg         gov_l2_in_retention_reg;
  reg         gov_l2_in_retention_reg_reg;
  reg         gov_l2_in_retention_reg_reg_reg;
  reg         gov_l2_in_retention_reg_reg_reg_reg;
  reg         gov_l2_in_retention_reg_reg_reg_reg_reg;
  reg [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata1_reg;
  reg         l2_dataram_no_acc_next_cycle_reg;
  reg         l1d_tagram_cpu3_wr_reg;
  reg [`CA53_SCU_L2_DATARAM_ADDR_W-1:0] l2_dataram_addr_reg;
  reg [`CA53_L1DC_SIZE_W-1:0] l1_dc_size_reg;
  reg         l2_dataram_wr_reg;
  reg         l2_dataram_wr_reg_reg;
  reg         l2_tagram_wr_reg;
  reg [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata6_reg;
  reg [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata4_reg;
  reg [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata5_reg;
  reg         l1d_tagram_cpu1_wr_reg;
  reg         l1d_tagram_cpu2_wr_reg;
  reg [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata7_reg;
  reg         l2_victimram_en_reg;
  reg         l2_victimram_wr_reg;
  reg [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata0_reg;
  reg   [3:0] l1d_tagram_cpu3_en_reg;
  reg [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata2_reg;
  reg         l2_victimram_no_acc_next_cycle_reg;
  reg  [15:0] l2_tagram_en_reg;
  reg   [3:0] l1d_tagram_cpu2_en_reg;
  reg         l1d_tagram_cpu0_wr_reg;
  reg   [3:0] l1d_tagram_cpu1_en_reg;
  reg [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata3_reg;
  reg [`CA53_SCU_L2_DATARAM_EN_W-1:0] l2_dataram_clken_reg;
  reg [`CA53_SCU_L2_DATARAM_EN_W-1:0] l2_dataram_clken_reg_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    l2_size_reg <= {((`CA53_L2_SIZE_W-1) - (0) + 1){1'b0}};
    l1d_tagram_cpu0_en_reg <= 4'b0000;
    l2_dataram_en_reg <= {((`CA53_SCU_L2_DATARAM_EN_W-1) - (0) + 1){1'b0}};
    l2_dataram_en_reg_reg <= {((`CA53_SCU_L2_DATARAM_EN_W-1) - (0) + 1){1'b0}};
    gov_l2_in_retention_reg <= 1'b0;
    gov_l2_in_retention_reg_reg <= 1'b0;
    gov_l2_in_retention_reg_reg_reg <= 1'b0;
    gov_l2_in_retention_reg_reg_reg_reg <= 1'b0;
    gov_l2_in_retention_reg_reg_reg_reg_reg <= 1'b0;
    l2_dataram_wdata1_reg <= {((`CA53_SCU_L2_DATARAM_DATA_W-1) - (0) + 1){1'b0}};
    l2_dataram_no_acc_next_cycle_reg <= 1'b0;
    l1d_tagram_cpu3_wr_reg <= 1'b0;
    l2_dataram_addr_reg <= {((`CA53_SCU_L2_DATARAM_ADDR_W-1) - (0) + 1){1'b0}};
    l1_dc_size_reg <= {((`CA53_L1DC_SIZE_W-1) - (0) + 1){1'b0}};
    l2_dataram_wr_reg <= 1'b0;
    l2_dataram_wr_reg_reg <= 1'b0;
    l2_tagram_wr_reg <= 1'b0;
    l2_dataram_wdata6_reg <= {((`CA53_SCU_L2_DATARAM_DATA_W-1) - (0) + 1){1'b0}};
    l2_dataram_wdata4_reg <= {((`CA53_SCU_L2_DATARAM_DATA_W-1) - (0) + 1){1'b0}};
    l2_dataram_wdata5_reg <= {((`CA53_SCU_L2_DATARAM_DATA_W-1) - (0) + 1){1'b0}};
    l1d_tagram_cpu1_wr_reg <= 1'b0;
    l1d_tagram_cpu2_wr_reg <= 1'b0;
    l2_dataram_wdata7_reg <= {((`CA53_SCU_L2_DATARAM_DATA_W-1) - (0) + 1){1'b0}};
    l2_victimram_en_reg <= 1'b0;
    l2_victimram_wr_reg <= 1'b0;
    l2_dataram_wdata0_reg <= {((`CA53_SCU_L2_DATARAM_DATA_W-1) - (0) + 1){1'b0}};
    l1d_tagram_cpu3_en_reg <= 4'b0000;
    l2_dataram_wdata2_reg <= {((`CA53_SCU_L2_DATARAM_DATA_W-1) - (0) + 1){1'b0}};
    l2_victimram_no_acc_next_cycle_reg <= 1'b0;
    l2_tagram_en_reg <= {16{1'b0}};
    l1d_tagram_cpu2_en_reg <= 4'b0000;
    l1d_tagram_cpu0_wr_reg <= 1'b0;
    l1d_tagram_cpu1_en_reg <= 4'b0000;
    l2_dataram_wdata3_reg <= {((`CA53_SCU_L2_DATARAM_DATA_W-1) - (0) + 1){1'b0}};
    l2_dataram_clken_reg <= {((`CA53_SCU_L2_DATARAM_EN_W-1) - (0) + 1){1'b0}};
    l2_dataram_clken_reg_reg <= {((`CA53_SCU_L2_DATARAM_EN_W-1) - (0) + 1){1'b0}};
  end
  else
  begin
    l1_dc_size_reg <= l1_dc_size;
    l2_size_reg <= l2_size;
    gov_l2_in_retention_reg <= gov_l2_in_retention;
    gov_l2_in_retention_reg_reg <= gov_l2_in_retention_reg;
    gov_l2_in_retention_reg_reg_reg <= gov_l2_in_retention_reg_reg;
    gov_l2_in_retention_reg_reg_reg_reg <= gov_l2_in_retention_reg_reg_reg;
    gov_l2_in_retention_reg_reg_reg_reg_reg <= gov_l2_in_retention_reg_reg_reg_reg;
    l1d_tagram_cpu0_en_reg <= l1d_tagram_cpu0_en;
    l1d_tagram_cpu1_en_reg <= l1d_tagram_cpu1_en;
    l1d_tagram_cpu2_en_reg <= l1d_tagram_cpu2_en;
    l1d_tagram_cpu3_en_reg <= l1d_tagram_cpu3_en;
    l1d_tagram_cpu0_wr_reg <= l1d_tagram_cpu0_wr;
    l1d_tagram_cpu1_wr_reg <= l1d_tagram_cpu1_wr;
    l1d_tagram_cpu2_wr_reg <= l1d_tagram_cpu2_wr;
    l1d_tagram_cpu3_wr_reg <= l1d_tagram_cpu3_wr;
    l2_tagram_en_reg <= l2_tagram_en;
    l2_tagram_wr_reg <= l2_tagram_wr;
    l2_victimram_en_reg <= l2_victimram_en;
    l2_victimram_no_acc_next_cycle_reg <= l2_victimram_no_acc_next_cycle;
    l2_victimram_wr_reg <= l2_victimram_wr;
    l2_dataram_clken_reg <= l2_dataram_clken;
    l2_dataram_clken_reg_reg <= l2_dataram_clken_reg;
    l2_dataram_no_acc_next_cycle_reg <= l2_dataram_no_acc_next_cycle;
    l2_dataram_en_reg <= l2_dataram_en;
    l2_dataram_en_reg_reg <= l2_dataram_en_reg;
    l2_dataram_wr_reg <= l2_dataram_wr;
    l2_dataram_wr_reg_reg <= l2_dataram_wr_reg;
    l2_dataram_addr_reg <= l2_dataram_addr;
    l2_dataram_wdata0_reg <= l2_dataram_wdata0;
    l2_dataram_wdata1_reg <= l2_dataram_wdata1;
    l2_dataram_wdata2_reg <= l2_dataram_wdata2;
    l2_dataram_wdata3_reg <= l2_dataram_wdata3;
    l2_dataram_wdata4_reg <= l2_dataram_wdata4;
    l2_dataram_wdata5_reg <= l2_dataram_wdata5;
    l2_dataram_wdata6_reg <= l2_dataram_wdata6;
    l2_dataram_wdata7_reg <= l2_dataram_wdata7;
  end




  //---------------------------------------------------------------------------
  // L1 duplicate tags
  //---------------------------------------------------------------------------

  // L1 data cache size
  // 000 8k
  // 001 16k
  // 011 32k
  // 111 64k
  //  input [`CA53_L1DC_SIZE_W-1:0] l1_dc_size valid always timing 10%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_L1DC_SIZE_W-1) - (0) + 1), INOPTIONS, "l1_dc_size X or Z")
  u_ovl_intf_x_l1_dc_size (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l1_dc_size));


  // Clock gate enable
  //  output       l1d_tagram_clken   valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "l1d_tagram_clken X or Z")
  u_ovl_intf_x_l1d_tagram_clken (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l1d_tagram_clken));


  // Bank enables
  //  output [3:0] l1d_tagram_cpu0_en valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "l1d_tagram_cpu0_en X or Z")
  u_ovl_intf_x_l1d_tagram_cpu0_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l1d_tagram_cpu0_en));

  //  output [3:0] l1d_tagram_cpu1_en valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "l1d_tagram_cpu1_en X or Z")
  u_ovl_intf_x_l1d_tagram_cpu1_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l1d_tagram_cpu1_en));

  //  output [3:0] l1d_tagram_cpu2_en valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "l1d_tagram_cpu2_en X or Z")
  u_ovl_intf_x_l1d_tagram_cpu2_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l1d_tagram_cpu2_en));

  //  output [3:0] l1d_tagram_cpu3_en valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "l1d_tagram_cpu3_en X or Z")
  u_ovl_intf_x_l1d_tagram_cpu3_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l1d_tagram_cpu3_en));


  // Global write enable
  //  output l1d_tagram_cpu0_wr valid |l1d_tagram_cpu0_en timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "l1d_tagram_cpu0_wr X or Z")
  u_ovl_intf_x_l1d_tagram_cpu0_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|l1d_tagram_cpu0_en),
    .test_expr (l1d_tagram_cpu0_wr));

  //  output l1d_tagram_cpu1_wr valid |l1d_tagram_cpu1_en timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "l1d_tagram_cpu1_wr X or Z")
  u_ovl_intf_x_l1d_tagram_cpu1_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|l1d_tagram_cpu1_en),
    .test_expr (l1d_tagram_cpu1_wr));

  //  output l1d_tagram_cpu2_wr valid |l1d_tagram_cpu2_en timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "l1d_tagram_cpu2_wr X or Z")
  u_ovl_intf_x_l1d_tagram_cpu2_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|l1d_tagram_cpu2_en),
    .test_expr (l1d_tagram_cpu2_wr));

  //  output l1d_tagram_cpu3_wr valid |l1d_tagram_cpu3_en timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "l1d_tagram_cpu3_wr X or Z")
  u_ovl_intf_x_l1d_tagram_cpu3_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|l1d_tagram_cpu3_en),
    .test_expr (l1d_tagram_cpu3_wr));


  // Tag RAM address
  //  output [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0] l1d_tagram_cpu0_addr valid |l1d_tagram_cpu0_en timing 30%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_ADDR_W-1) - (0) + 1), OUTOPTIONS, "l1d_tagram_cpu0_addr X or Z")
  u_ovl_intf_x_l1d_tagram_cpu0_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|l1d_tagram_cpu0_en),
    .test_expr (l1d_tagram_cpu0_addr));

  //  output [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0] l1d_tagram_cpu1_addr valid |l1d_tagram_cpu1_en timing 30%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_ADDR_W-1) - (0) + 1), OUTOPTIONS, "l1d_tagram_cpu1_addr X or Z")
  u_ovl_intf_x_l1d_tagram_cpu1_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|l1d_tagram_cpu1_en),
    .test_expr (l1d_tagram_cpu1_addr));

  //  output [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0] l1d_tagram_cpu2_addr valid |l1d_tagram_cpu2_en timing 30%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_ADDR_W-1) - (0) + 1), OUTOPTIONS, "l1d_tagram_cpu2_addr X or Z")
  u_ovl_intf_x_l1d_tagram_cpu2_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|l1d_tagram_cpu2_en),
    .test_expr (l1d_tagram_cpu2_addr));

  //  output [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0] l1d_tagram_cpu3_addr valid |l1d_tagram_cpu3_en timing 30%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_ADDR_W-1) - (0) + 1), OUTOPTIONS, "l1d_tagram_cpu3_addr X or Z")
  u_ovl_intf_x_l1d_tagram_cpu3_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|l1d_tagram_cpu3_en),
    .test_expr (l1d_tagram_cpu3_addr));


  // Tag write data
  //  output [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu0_wdata valid |l1d_tagram_cpu0_en & l1d_tagram_cpu0_wr timing 30%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), OUTOPTIONS, "l1d_tagram_cpu0_wdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu0_wdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|l1d_tagram_cpu0_en & l1d_tagram_cpu0_wr),
    .test_expr (l1d_tagram_cpu0_wdata));

  //  output [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu1_wdata valid |l1d_tagram_cpu1_en & l1d_tagram_cpu1_wr timing 30%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), OUTOPTIONS, "l1d_tagram_cpu1_wdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu1_wdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|l1d_tagram_cpu1_en & l1d_tagram_cpu1_wr),
    .test_expr (l1d_tagram_cpu1_wdata));

  //  output [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu2_wdata valid |l1d_tagram_cpu2_en & l1d_tagram_cpu2_wr timing 30%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), OUTOPTIONS, "l1d_tagram_cpu2_wdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu2_wdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|l1d_tagram_cpu2_en & l1d_tagram_cpu2_wr),
    .test_expr (l1d_tagram_cpu2_wdata));

  //  output [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu3_wdata valid |l1d_tagram_cpu3_en & l1d_tagram_cpu3_wr timing 30%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), OUTOPTIONS, "l1d_tagram_cpu3_wdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu3_wdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|l1d_tagram_cpu3_en & l1d_tagram_cpu3_wr),
    .test_expr (l1d_tagram_cpu3_wdata));


  // Tag read data
  //  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu0_way0_rdata valid l1d_tagram_cpu0_en@1[0] & ~l1d_tagram_cpu0_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l1d_tagram_cpu0_way0_rdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu0_way0_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l1d_tagram_cpu0_en_reg[0] & ~l1d_tagram_cpu0_wr_reg),
    .test_expr (l1d_tagram_cpu0_way0_rdata));

  //  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu0_way1_rdata valid l1d_tagram_cpu0_en@1[1] & ~l1d_tagram_cpu0_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l1d_tagram_cpu0_way1_rdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu0_way1_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l1d_tagram_cpu0_en_reg[1] & ~l1d_tagram_cpu0_wr_reg),
    .test_expr (l1d_tagram_cpu0_way1_rdata));

  //  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu0_way2_rdata valid l1d_tagram_cpu0_en@1[2] & ~l1d_tagram_cpu0_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l1d_tagram_cpu0_way2_rdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu0_way2_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l1d_tagram_cpu0_en_reg[2] & ~l1d_tagram_cpu0_wr_reg),
    .test_expr (l1d_tagram_cpu0_way2_rdata));

  //  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu0_way3_rdata valid l1d_tagram_cpu0_en@1[3] & ~l1d_tagram_cpu0_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l1d_tagram_cpu0_way3_rdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu0_way3_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l1d_tagram_cpu0_en_reg[3] & ~l1d_tagram_cpu0_wr_reg),
    .test_expr (l1d_tagram_cpu0_way3_rdata));


  //  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu1_way0_rdata valid l1d_tagram_cpu1_en@1[0] & ~l1d_tagram_cpu1_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l1d_tagram_cpu1_way0_rdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu1_way0_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l1d_tagram_cpu1_en_reg[0] & ~l1d_tagram_cpu1_wr_reg),
    .test_expr (l1d_tagram_cpu1_way0_rdata));

  //  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu1_way1_rdata valid l1d_tagram_cpu1_en@1[1] & ~l1d_tagram_cpu1_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l1d_tagram_cpu1_way1_rdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu1_way1_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l1d_tagram_cpu1_en_reg[1] & ~l1d_tagram_cpu1_wr_reg),
    .test_expr (l1d_tagram_cpu1_way1_rdata));

  //  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu1_way2_rdata valid l1d_tagram_cpu1_en@1[2] & ~l1d_tagram_cpu1_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l1d_tagram_cpu1_way2_rdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu1_way2_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l1d_tagram_cpu1_en_reg[2] & ~l1d_tagram_cpu1_wr_reg),
    .test_expr (l1d_tagram_cpu1_way2_rdata));

  //  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu1_way3_rdata valid l1d_tagram_cpu1_en@1[3] & ~l1d_tagram_cpu1_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l1d_tagram_cpu1_way3_rdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu1_way3_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l1d_tagram_cpu1_en_reg[3] & ~l1d_tagram_cpu1_wr_reg),
    .test_expr (l1d_tagram_cpu1_way3_rdata));


  //  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu2_way0_rdata valid l1d_tagram_cpu2_en@1[0] & ~l1d_tagram_cpu2_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l1d_tagram_cpu2_way0_rdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu2_way0_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l1d_tagram_cpu2_en_reg[0] & ~l1d_tagram_cpu2_wr_reg),
    .test_expr (l1d_tagram_cpu2_way0_rdata));

  //  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu2_way1_rdata valid l1d_tagram_cpu2_en@1[1] & ~l1d_tagram_cpu2_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l1d_tagram_cpu2_way1_rdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu2_way1_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l1d_tagram_cpu2_en_reg[1] & ~l1d_tagram_cpu2_wr_reg),
    .test_expr (l1d_tagram_cpu2_way1_rdata));

  //  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu2_way2_rdata valid l1d_tagram_cpu2_en@1[2] & ~l1d_tagram_cpu2_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l1d_tagram_cpu2_way2_rdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu2_way2_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l1d_tagram_cpu2_en_reg[2] & ~l1d_tagram_cpu2_wr_reg),
    .test_expr (l1d_tagram_cpu2_way2_rdata));

  //  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu2_way3_rdata valid l1d_tagram_cpu2_en@1[3] & ~l1d_tagram_cpu2_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l1d_tagram_cpu2_way3_rdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu2_way3_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l1d_tagram_cpu2_en_reg[3] & ~l1d_tagram_cpu2_wr_reg),
    .test_expr (l1d_tagram_cpu2_way3_rdata));


  //  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu3_way0_rdata valid l1d_tagram_cpu3_en@1[0] & ~l1d_tagram_cpu3_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l1d_tagram_cpu3_way0_rdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu3_way0_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l1d_tagram_cpu3_en_reg[0] & ~l1d_tagram_cpu3_wr_reg),
    .test_expr (l1d_tagram_cpu3_way0_rdata));

  //  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu3_way1_rdata valid l1d_tagram_cpu3_en@1[1] & ~l1d_tagram_cpu3_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l1d_tagram_cpu3_way1_rdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu3_way1_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l1d_tagram_cpu3_en_reg[1] & ~l1d_tagram_cpu3_wr_reg),
    .test_expr (l1d_tagram_cpu3_way1_rdata));

  //  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu3_way2_rdata valid l1d_tagram_cpu3_en@1[2] & ~l1d_tagram_cpu3_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l1d_tagram_cpu3_way2_rdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu3_way2_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l1d_tagram_cpu3_en_reg[2] & ~l1d_tagram_cpu3_wr_reg),
    .test_expr (l1d_tagram_cpu3_way2_rdata));

  //  input [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] l1d_tagram_cpu3_way3_rdata valid l1d_tagram_cpu3_en@1[3] & ~l1d_tagram_cpu3_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L1D_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l1d_tagram_cpu3_way3_rdata X or Z")
  u_ovl_intf_x_l1d_tagram_cpu3_way3_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l1d_tagram_cpu3_en_reg[3] & ~l1d_tagram_cpu3_wr_reg),
    .test_expr (l1d_tagram_cpu3_way3_rdata));


  // The SCU is allowed to access the RAMs in the first five cycles after going
  // into retention, as the governor waits before actually putting the RAMs
  // into retention.
  assign in_retention  = gov_l2_in_retention & gov_l2_in_retention_reg & gov_l2_in_retention_reg_reg & gov_l2_in_retention_reg_reg_reg & gov_l2_in_retention_reg_reg_reg_reg & gov_l2_in_retention_reg_reg_reg_reg_reg;

  // RAMs must not be accessed when in retention

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "in_retention  => ~|l1d_tagram_cpu0_en")
  u_ovl_intf_assert_05d680b36cb9829bfcc1689ac4edb6d98973b92a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (in_retention ),
    .consequent_expr (~|l1d_tagram_cpu0_en));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "in_retention  => ~|l1d_tagram_cpu1_en")
  u_ovl_intf_assert_5d61db83025d25527b5377fc068fdfed1c3f0242 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (in_retention ),
    .consequent_expr (~|l1d_tagram_cpu1_en));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "in_retention  => ~|l1d_tagram_cpu2_en")
  u_ovl_intf_assert_e82d12a4ef353c3d91b8d7c906ece593e6af4541 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (in_retention ),
    .consequent_expr (~|l1d_tagram_cpu2_en));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "in_retention  => ~|l1d_tagram_cpu3_en")
  u_ovl_intf_assert_84580b3452c7f9bd0c60349eba5cd4d9303b483b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (in_retention ),
    .consequent_expr (~|l1d_tagram_cpu3_en));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "in_retention  => ~l1d_tagram_clken")
  u_ovl_intf_assert_5068d1d1db40e1c42f293080d0b0cd23f47a0339 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (in_retention ),
    .consequent_expr (~l1d_tagram_clken));


  // The clock enable must always be asserted when a request is made

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|l1d_tagram_cpu0_en  => l1d_tagram_clken")
  u_ovl_intf_assert_f3b80d2bade1c849ba97da707196b313e17f7b27 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|l1d_tagram_cpu0_en ),
    .consequent_expr (l1d_tagram_clken));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|l1d_tagram_cpu1_en  => l1d_tagram_clken")
  u_ovl_intf_assert_0b0cc74945dc2a0c29471f3bea035dbfe3aac7f8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|l1d_tagram_cpu1_en ),
    .consequent_expr (l1d_tagram_clken));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|l1d_tagram_cpu2_en  => l1d_tagram_clken")
  u_ovl_intf_assert_356806e7d596f54f962bd6e520e15be6db501d63 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|l1d_tagram_cpu2_en ),
    .consequent_expr (l1d_tagram_clken));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|l1d_tagram_cpu3_en  => l1d_tagram_clken")
  u_ovl_intf_assert_d2b520349526256017176ba8cd60aa56d19f156f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|l1d_tagram_cpu3_en ),
    .consequent_expr (l1d_tagram_clken));


  // Only some encodings of the size are valid

  assert_always #(`OVL_FATAL, INOPTIONS, "l1_dc_size in [3'b000, 3'b001, 3'b011, 3'b111]")
  u_ovl_intf_assume_c622fbd2a734741574cd3e4aa89f0df5aa6ab451 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (((l1_dc_size == 3'b000) | (l1_dc_size ==  3'b001) | (l1_dc_size ==  3'b011) | (l1_dc_size ==  3'b111))));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    reset_done <= 1'b0;
  else
    reset_done <= 1'b1;


  // L1 size should be stable

  assert_implication #(`OVL_FATAL, INOPTIONS, "reset_done & ~in_retention  => l1_dc_size == l1_dc_size@1")
  u_ovl_intf_assume_772a3469dc68e35e65a2b10df22a8ad1cf7c1248 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (reset_done & ~in_retention ),
    .consequent_expr (l1_dc_size == l1_dc_size_reg));


  // Based on the size, the lower bits of the tag must be masked out

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "l1d_tagram_cpu0_wr  => ~|(l1d_tagram_cpu0_wdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assert_31f4d463c960a925e4c8d143aedda92b68dae105 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu0_wr ),
    .consequent_expr (~|(l1d_tagram_cpu0_wdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "l1d_tagram_cpu1_wr  => ~|(l1d_tagram_cpu1_wdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assert_d7e1e7394fc33fd1d0a60b2210949d88099a4b9a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu1_wr ),
    .consequent_expr (~|(l1d_tagram_cpu1_wdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "l1d_tagram_cpu2_wr  => ~|(l1d_tagram_cpu2_wdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assert_8298b43db72ff4e46596f62636d688ff59b40717 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu2_wr ),
    .consequent_expr (~|(l1d_tagram_cpu2_wdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "l1d_tagram_cpu3_wr  => ~|(l1d_tagram_cpu3_wdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assert_87b7dfd0faaee98d54dc363ab0e7b04076e0d798 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu3_wr ),
    .consequent_expr (~|(l1d_tagram_cpu3_wdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  generate if (!CPU_CACHE_PROTECTION) begin : g_ovl_l1_addr_size
    // These assertions may not be true if there is an ECC error in the lower bits.

  assert_implication #(`OVL_FATAL, INOPTIONS, "l1d_tagram_cpu0_en@1[0] & ~l1d_tagram_cpu0_wr@1  => ~|(l1d_tagram_cpu0_way0_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assume_32d39b938dc41cd178956cacd2d9de195177b789 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu0_en_reg[0] & ~l1d_tagram_cpu0_wr_reg ),
    .consequent_expr (~|(l1d_tagram_cpu0_way0_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l1d_tagram_cpu0_en@1[1] & ~l1d_tagram_cpu0_wr@1  => ~|(l1d_tagram_cpu0_way1_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assume_16a815e737302310184f57564ae230ff42a33eb3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu0_en_reg[1] & ~l1d_tagram_cpu0_wr_reg ),
    .consequent_expr (~|(l1d_tagram_cpu0_way1_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l1d_tagram_cpu0_en@1[2] & ~l1d_tagram_cpu0_wr@1  => ~|(l1d_tagram_cpu0_way2_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assume_154954b1f1ad646339061e740e4e40f08a048c2e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu0_en_reg[2] & ~l1d_tagram_cpu0_wr_reg ),
    .consequent_expr (~|(l1d_tagram_cpu0_way2_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l1d_tagram_cpu0_en@1[3] & ~l1d_tagram_cpu0_wr@1  => ~|(l1d_tagram_cpu0_way3_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assume_395bbb24cd59f49fd9a0a49cc5b47499fd8896af (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu0_en_reg[3] & ~l1d_tagram_cpu0_wr_reg ),
    .consequent_expr (~|(l1d_tagram_cpu0_way3_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l1d_tagram_cpu1_en@1[0] & ~l1d_tagram_cpu1_wr@1  => ~|(l1d_tagram_cpu1_way0_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assume_43321ba1716267febd6a5271b1756e6e443fc5ef (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu1_en_reg[0] & ~l1d_tagram_cpu1_wr_reg ),
    .consequent_expr (~|(l1d_tagram_cpu1_way0_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l1d_tagram_cpu1_en@1[1] & ~l1d_tagram_cpu1_wr@1  => ~|(l1d_tagram_cpu1_way1_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assume_dd6bfe5309cab591c105c66bca844f105b582844 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu1_en_reg[1] & ~l1d_tagram_cpu1_wr_reg ),
    .consequent_expr (~|(l1d_tagram_cpu1_way1_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l1d_tagram_cpu1_en@1[2] & ~l1d_tagram_cpu1_wr@1  => ~|(l1d_tagram_cpu1_way2_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assume_b457701d6d852725c7aed07cd9ddd10792f60541 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu1_en_reg[2] & ~l1d_tagram_cpu1_wr_reg ),
    .consequent_expr (~|(l1d_tagram_cpu1_way2_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l1d_tagram_cpu1_en@1[3] & ~l1d_tagram_cpu1_wr@1  => ~|(l1d_tagram_cpu1_way3_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assume_0727a046560d522474f4ca1a417179be19bf88c0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu1_en_reg[3] & ~l1d_tagram_cpu1_wr_reg ),
    .consequent_expr (~|(l1d_tagram_cpu1_way3_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l1d_tagram_cpu2_en@1[0] & ~l1d_tagram_cpu2_wr@1  => ~|(l1d_tagram_cpu2_way0_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assume_3216b5d8a64a71e06a4519b7984573538aa1ce80 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu2_en_reg[0] & ~l1d_tagram_cpu2_wr_reg ),
    .consequent_expr (~|(l1d_tagram_cpu2_way0_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l1d_tagram_cpu2_en@1[1] & ~l1d_tagram_cpu2_wr@1  => ~|(l1d_tagram_cpu2_way1_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assume_8c99d7acd71f529dd9f4155235d9d368a763e7ed (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu2_en_reg[1] & ~l1d_tagram_cpu2_wr_reg ),
    .consequent_expr (~|(l1d_tagram_cpu2_way1_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l1d_tagram_cpu2_en@1[2] & ~l1d_tagram_cpu2_wr@1  => ~|(l1d_tagram_cpu2_way2_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assume_6e204adba0a6b31ab7ce4f99629384a54b192e27 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu2_en_reg[2] & ~l1d_tagram_cpu2_wr_reg ),
    .consequent_expr (~|(l1d_tagram_cpu2_way2_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l1d_tagram_cpu2_en@1[3] & ~l1d_tagram_cpu2_wr@1  => ~|(l1d_tagram_cpu2_way3_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assume_8605d130d58b93040193d8d010e0c30189cdc4a4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu2_en_reg[3] & ~l1d_tagram_cpu2_wr_reg ),
    .consequent_expr (~|(l1d_tagram_cpu2_way3_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l1d_tagram_cpu3_en@1[0] & ~l1d_tagram_cpu3_wr@1  => ~|(l1d_tagram_cpu3_way0_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assume_1167a04afe386c06ed5e033fe489428465488fd0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu3_en_reg[0] & ~l1d_tagram_cpu3_wr_reg ),
    .consequent_expr (~|(l1d_tagram_cpu3_way0_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l1d_tagram_cpu3_en@1[1] & ~l1d_tagram_cpu3_wr@1  => ~|(l1d_tagram_cpu3_way1_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assume_a1666aaf43333f675fb0be2884ef8f1adb3d3093 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu3_en_reg[1] & ~l1d_tagram_cpu3_wr_reg ),
    .consequent_expr (~|(l1d_tagram_cpu3_way1_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l1d_tagram_cpu3_en@1[2] & ~l1d_tagram_cpu3_wr@1  => ~|(l1d_tagram_cpu3_way2_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assume_848feebad923bb727eb3633ae8a8f4c792c93ef3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu3_en_reg[2] & ~l1d_tagram_cpu3_wr_reg ),
    .consequent_expr (~|(l1d_tagram_cpu3_way2_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l1d_tagram_cpu3_en@1[3] & ~l1d_tagram_cpu3_wr@1  => ~|(l1d_tagram_cpu3_way3_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)")
  u_ovl_intf_assume_0dbed8ab3b06f72ebaef0f9001f0705a1c94d639 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l1d_tagram_cpu3_en_reg[3] & ~l1d_tagram_cpu3_wr_reg ),
    .consequent_expr (~|(l1d_tagram_cpu3_way3_rdata[`CA53_L1DC_SIZE_W-1:0] & l1_dc_size)));

  end endgenerate

  // Interface assumes 4-way L1 associativity

  assert_always #(`OVL_FATAL, OUTOPTIONS, "`CA53_SCU_L1D_ASSOC == 4")
  u_ovl_intf_assert_e26c2d5ae3abde620f51aad68ebbd51adb5f080e (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (`CA53_SCU_L1D_ASSOC == 4));


  //---------------------------------------------------------------------------
  // L2 tags
  //---------------------------------------------------------------------------

  // L2 cache size
  // 0000 128k
  // 0001 256k
  // 0011 512k
  // 0111 1024k
  // 1111 2048k
  //  input [`CA53_L2_SIZE_W-1:0] l2_size valid always timing 10%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_L2_SIZE_W-1) - (0) + 1), INOPTIONS, "l2_size X or Z")
  u_ovl_intf_x_l2_size (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l2_size));


  // Clock gate enable
  //  output l2_tagram_clken valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "l2_tagram_clken X or Z")
  u_ovl_intf_x_l2_tagram_clken (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l2_tagram_clken));


  // Bank enables
  //  output [15:0] l2_tagram_en valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 16, OUTOPTIONS, "l2_tagram_en X or Z")
  u_ovl_intf_x_l2_tagram_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l2_tagram_en));


  // Global write enable
  //  output l2_tagram_wr valid |l2_tagram_en timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "l2_tagram_wr X or Z")
  u_ovl_intf_x_l2_tagram_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|l2_tagram_en),
    .test_expr (l2_tagram_wr));


  // Tag RAM address
  //  output [`CA53_SCU_L2_TAGRAM_ADDR_W-1:0] l2_tagram_addr valid |l2_tagram_en timing 30%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_ADDR_W-1) - (0) + 1), OUTOPTIONS, "l2_tagram_addr X or Z")
  u_ovl_intf_x_l2_tagram_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|l2_tagram_en),
    .test_expr (l2_tagram_addr));


  // Tag write data
  //  output [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_wdata valid |l2_tagram_en & l2_tagram_wr timing 30%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_DATA_W-1) - (0) + 1), OUTOPTIONS, "l2_tagram_wdata X or Z")
  u_ovl_intf_x_l2_tagram_wdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|l2_tagram_en & l2_tagram_wr),
    .test_expr (l2_tagram_wdata));


  // Tag read data
  //  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way0_rdata  valid l2_tagram_en@1[0]  & ~l2_tagram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l2_tagram_way0_rdata X or Z")
  u_ovl_intf_x_l2_tagram_way0_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_tagram_en_reg[0]  & ~l2_tagram_wr_reg),
    .test_expr (l2_tagram_way0_rdata));

  //  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way1_rdata  valid l2_tagram_en@1[1]  & ~l2_tagram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l2_tagram_way1_rdata X or Z")
  u_ovl_intf_x_l2_tagram_way1_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_tagram_en_reg[1]  & ~l2_tagram_wr_reg),
    .test_expr (l2_tagram_way1_rdata));

  //  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way2_rdata  valid l2_tagram_en@1[2]  & ~l2_tagram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l2_tagram_way2_rdata X or Z")
  u_ovl_intf_x_l2_tagram_way2_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_tagram_en_reg[2]  & ~l2_tagram_wr_reg),
    .test_expr (l2_tagram_way2_rdata));

  //  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way3_rdata  valid l2_tagram_en@1[3]  & ~l2_tagram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l2_tagram_way3_rdata X or Z")
  u_ovl_intf_x_l2_tagram_way3_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_tagram_en_reg[3]  & ~l2_tagram_wr_reg),
    .test_expr (l2_tagram_way3_rdata));

  //  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way4_rdata  valid l2_tagram_en@1[4]  & ~l2_tagram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l2_tagram_way4_rdata X or Z")
  u_ovl_intf_x_l2_tagram_way4_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_tagram_en_reg[4]  & ~l2_tagram_wr_reg),
    .test_expr (l2_tagram_way4_rdata));

  //  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way5_rdata  valid l2_tagram_en@1[5]  & ~l2_tagram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l2_tagram_way5_rdata X or Z")
  u_ovl_intf_x_l2_tagram_way5_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_tagram_en_reg[5]  & ~l2_tagram_wr_reg),
    .test_expr (l2_tagram_way5_rdata));

  //  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way6_rdata  valid l2_tagram_en@1[6]  & ~l2_tagram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l2_tagram_way6_rdata X or Z")
  u_ovl_intf_x_l2_tagram_way6_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_tagram_en_reg[6]  & ~l2_tagram_wr_reg),
    .test_expr (l2_tagram_way6_rdata));

  //  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way7_rdata  valid l2_tagram_en@1[7]  & ~l2_tagram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l2_tagram_way7_rdata X or Z")
  u_ovl_intf_x_l2_tagram_way7_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_tagram_en_reg[7]  & ~l2_tagram_wr_reg),
    .test_expr (l2_tagram_way7_rdata));

  //  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way8_rdata  valid l2_tagram_en@1[8]  & ~l2_tagram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l2_tagram_way8_rdata X or Z")
  u_ovl_intf_x_l2_tagram_way8_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_tagram_en_reg[8]  & ~l2_tagram_wr_reg),
    .test_expr (l2_tagram_way8_rdata));

  //  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way9_rdata  valid l2_tagram_en@1[9]  & ~l2_tagram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l2_tagram_way9_rdata X or Z")
  u_ovl_intf_x_l2_tagram_way9_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_tagram_en_reg[9]  & ~l2_tagram_wr_reg),
    .test_expr (l2_tagram_way9_rdata));

  //  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way10_rdata valid l2_tagram_en@1[10] & ~l2_tagram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l2_tagram_way10_rdata X or Z")
  u_ovl_intf_x_l2_tagram_way10_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_tagram_en_reg[10] & ~l2_tagram_wr_reg),
    .test_expr (l2_tagram_way10_rdata));

  //  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way11_rdata valid l2_tagram_en@1[11] & ~l2_tagram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l2_tagram_way11_rdata X or Z")
  u_ovl_intf_x_l2_tagram_way11_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_tagram_en_reg[11] & ~l2_tagram_wr_reg),
    .test_expr (l2_tagram_way11_rdata));

  //  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way12_rdata valid l2_tagram_en@1[12] & ~l2_tagram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l2_tagram_way12_rdata X or Z")
  u_ovl_intf_x_l2_tagram_way12_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_tagram_en_reg[12] & ~l2_tagram_wr_reg),
    .test_expr (l2_tagram_way12_rdata));

  //  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way13_rdata valid l2_tagram_en@1[13] & ~l2_tagram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l2_tagram_way13_rdata X or Z")
  u_ovl_intf_x_l2_tagram_way13_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_tagram_en_reg[13] & ~l2_tagram_wr_reg),
    .test_expr (l2_tagram_way13_rdata));

  //  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way14_rdata valid l2_tagram_en@1[14] & ~l2_tagram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l2_tagram_way14_rdata X or Z")
  u_ovl_intf_x_l2_tagram_way14_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_tagram_en_reg[14] & ~l2_tagram_wr_reg),
    .test_expr (l2_tagram_way14_rdata));

  //  input [`CA53_SCU_L2_TAGRAM_DATA_W-1:0] l2_tagram_way15_rdata valid l2_tagram_en@1[15] & ~l2_tagram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_TAGRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l2_tagram_way15_rdata X or Z")
  u_ovl_intf_x_l2_tagram_way15_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_tagram_en_reg[15] & ~l2_tagram_wr_reg),
    .test_expr (l2_tagram_way15_rdata));


  // RAMs must not be accessed when in retention

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "in_retention  => ~|l2_tagram_en")
  u_ovl_intf_assert_cbb51eb4c3bec4e3bfe33be633a87c80f242d6f7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (in_retention ),
    .consequent_expr (~|l2_tagram_en));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "in_retention  => ~l2_tagram_clken")
  u_ovl_intf_assert_3e33be3ff72330af10a519ac0135f2f541e1549c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (in_retention ),
    .consequent_expr (~l2_tagram_clken));


  // Interface assumes 16-way L2 associativity

  assert_always #(`OVL_FATAL, OUTOPTIONS, "`CA53_SCU_L2_ASSOC == 16")
  u_ovl_intf_assert_8cda823780723c812d529fdf84cd4c83e491df8d (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (`CA53_SCU_L2_ASSOC == 16));


  // If there is no L2 cache, this interface must not be enabled

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "L2_CACHE == 0  => ~|l2_tagram_en")
  u_ovl_intf_assert_fb9e44cacb8f3adf1ae361c7021d1970f79dc85f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (L2_CACHE == 0 ),
    .consequent_expr (~|l2_tagram_en));


  // The clock enable must always be asserted when a request is made

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|l2_tagram_en  => l2_tagram_clken")
  u_ovl_intf_assert_be3e3964995d866e64141d5fbd1ecae94104d401 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|l2_tagram_en ),
    .consequent_expr (l2_tagram_clken));


  // Only some encodings of the size are valid

  assert_always #(`OVL_FATAL, INOPTIONS, "l2_size in [4'b0000, 4'b0001, 4'b0011, 4'b0111, 4'b1111]")
  u_ovl_intf_assume_a9eb48f77ef022dbbceacc0ec1384401d4170d77 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (((l2_size == 4'b0000) | (l2_size ==  4'b0001) | (l2_size ==  4'b0011) | (l2_size ==  4'b0111) | (l2_size ==  4'b1111))));


  // L2 size should be stable

  assert_implication #(`OVL_FATAL, INOPTIONS, "reset_done & ~in_retention  => l2_size == l2_size@1")
  u_ovl_intf_assume_9dcc06ef1d29ecef4689be3eba54daddb30e74ec (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (reset_done & ~in_retention ),
    .consequent_expr (l2_size == l2_size_reg));


  // Based on the size, the lower bits of the tag must be masked out

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|l2_tagram_en & l2_tagram_wr  => ~|(l2_tagram_wdata[`CA53_L2_SIZE_W-1:0] & l2_size)")
  u_ovl_intf_assert_60475fa087a5f5e18f071409f3a9b09098b5937b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|l2_tagram_en & l2_tagram_wr ),
    .consequent_expr (~|(l2_tagram_wdata[`CA53_L2_SIZE_W-1:0] & l2_size)));


  generate if (!SCU_CACHE_PROTECTION) begin : g_ovl_l2_addr_size
    // These assertions may not be true if there is an ECC error in the lower bits.

  assert_implication #(`OVL_FATAL, INOPTIONS, "l2_tagram_en@1[0]  & ~l2_tagram_wr@1  => ~|(l2_tagram_way0_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)")
  u_ovl_intf_assume_8fad53f9e7cef98cced39b35cfdd72a455633386 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_tagram_en_reg[0]  & ~l2_tagram_wr_reg ),
    .consequent_expr (~|(l2_tagram_way0_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l2_tagram_en@1[1]  & ~l2_tagram_wr@1  => ~|(l2_tagram_way1_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)")
  u_ovl_intf_assume_e7009ef185d57dca94a3627dd6b2005d170941ee (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_tagram_en_reg[1]  & ~l2_tagram_wr_reg ),
    .consequent_expr (~|(l2_tagram_way1_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l2_tagram_en@1[2]  & ~l2_tagram_wr@1  => ~|(l2_tagram_way2_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)")
  u_ovl_intf_assume_254a742db993cbc8c6459ff2b37aa174f69c93ed (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_tagram_en_reg[2]  & ~l2_tagram_wr_reg ),
    .consequent_expr (~|(l2_tagram_way2_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l2_tagram_en@1[3]  & ~l2_tagram_wr@1  => ~|(l2_tagram_way3_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)")
  u_ovl_intf_assume_d808b76c1e1e5a853dc48692366e7405d96a7a15 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_tagram_en_reg[3]  & ~l2_tagram_wr_reg ),
    .consequent_expr (~|(l2_tagram_way3_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l2_tagram_en@1[4]  & ~l2_tagram_wr@1  => ~|(l2_tagram_way4_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)")
  u_ovl_intf_assume_19d94f88dcce53ecf67d48caed29e918828b8118 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_tagram_en_reg[4]  & ~l2_tagram_wr_reg ),
    .consequent_expr (~|(l2_tagram_way4_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l2_tagram_en@1[5]  & ~l2_tagram_wr@1  => ~|(l2_tagram_way5_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)")
  u_ovl_intf_assume_a8f7936149e82be21b483852c01eee05c1accad8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_tagram_en_reg[5]  & ~l2_tagram_wr_reg ),
    .consequent_expr (~|(l2_tagram_way5_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l2_tagram_en@1[6]  & ~l2_tagram_wr@1  => ~|(l2_tagram_way6_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)")
  u_ovl_intf_assume_05d934dc72a13343584f20e5cb24e1a81b2dde54 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_tagram_en_reg[6]  & ~l2_tagram_wr_reg ),
    .consequent_expr (~|(l2_tagram_way6_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l2_tagram_en@1[7]  & ~l2_tagram_wr@1  => ~|(l2_tagram_way7_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)")
  u_ovl_intf_assume_21cc47a66070ead4b0b29d2ed2f33775eebd0408 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_tagram_en_reg[7]  & ~l2_tagram_wr_reg ),
    .consequent_expr (~|(l2_tagram_way7_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l2_tagram_en@1[8]  & ~l2_tagram_wr@1  => ~|(l2_tagram_way8_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)")
  u_ovl_intf_assume_c901c31d67339bd1ecb454987c928cf4f71ddf68 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_tagram_en_reg[8]  & ~l2_tagram_wr_reg ),
    .consequent_expr (~|(l2_tagram_way8_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l2_tagram_en@1[9]  & ~l2_tagram_wr@1  => ~|(l2_tagram_way9_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)")
  u_ovl_intf_assume_13d00ac3f57a87dc441f4986eb366e352f28cf58 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_tagram_en_reg[9]  & ~l2_tagram_wr_reg ),
    .consequent_expr (~|(l2_tagram_way9_rdata[`CA53_L2_SIZE_W-1:0]  & l2_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l2_tagram_en@1[10] & ~l2_tagram_wr@1  => ~|(l2_tagram_way10_rdata[`CA53_L2_SIZE_W-1:0] & l2_size)")
  u_ovl_intf_assume_56f3cd4bd933f9af6c4a6771b3db06b0fd0736d5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_tagram_en_reg[10] & ~l2_tagram_wr_reg ),
    .consequent_expr (~|(l2_tagram_way10_rdata[`CA53_L2_SIZE_W-1:0] & l2_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l2_tagram_en@1[11] & ~l2_tagram_wr@1  => ~|(l2_tagram_way11_rdata[`CA53_L2_SIZE_W-1:0] & l2_size)")
  u_ovl_intf_assume_308b785edb90297ec8503ae51290983257c335c6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_tagram_en_reg[11] & ~l2_tagram_wr_reg ),
    .consequent_expr (~|(l2_tagram_way11_rdata[`CA53_L2_SIZE_W-1:0] & l2_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l2_tagram_en@1[12] & ~l2_tagram_wr@1  => ~|(l2_tagram_way12_rdata[`CA53_L2_SIZE_W-1:0] & l2_size)")
  u_ovl_intf_assume_da5e510769f448d0174db8a3b926bb2eb13e902f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_tagram_en_reg[12] & ~l2_tagram_wr_reg ),
    .consequent_expr (~|(l2_tagram_way12_rdata[`CA53_L2_SIZE_W-1:0] & l2_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l2_tagram_en@1[13] & ~l2_tagram_wr@1  => ~|(l2_tagram_way13_rdata[`CA53_L2_SIZE_W-1:0] & l2_size)")
  u_ovl_intf_assume_2410ca7aa1709a3b03ff72150114effaf8d0b722 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_tagram_en_reg[13] & ~l2_tagram_wr_reg ),
    .consequent_expr (~|(l2_tagram_way13_rdata[`CA53_L2_SIZE_W-1:0] & l2_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l2_tagram_en@1[14] & ~l2_tagram_wr@1  => ~|(l2_tagram_way14_rdata[`CA53_L2_SIZE_W-1:0] & l2_size)")
  u_ovl_intf_assume_01815a31def423c28ccbb4050ab29414b0bd1640 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_tagram_en_reg[14] & ~l2_tagram_wr_reg ),
    .consequent_expr (~|(l2_tagram_way14_rdata[`CA53_L2_SIZE_W-1:0] & l2_size)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "l2_tagram_en@1[15] & ~l2_tagram_wr@1  => ~|(l2_tagram_way15_rdata[`CA53_L2_SIZE_W-1:0] & l2_size)")
  u_ovl_intf_assume_179f87ab8daadda31bb434de3cd9ed90b3cefc07 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_tagram_en_reg[15] & ~l2_tagram_wr_reg ),
    .consequent_expr (~|(l2_tagram_way15_rdata[`CA53_L2_SIZE_W-1:0] & l2_size)));

  end endgenerate

  //---------------------------------------------------------------------------
  // L2 victim RAM
  //---------------------------------------------------------------------------

  // Clock gate enable
  //  output l2_victimram_clken valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "l2_victimram_clken X or Z")
  u_ovl_intf_x_l2_victimram_clken (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l2_victimram_clken));


  // Bank enable
  //  output l2_victimram_en valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "l2_victimram_en X or Z")
  u_ovl_intf_x_l2_victimram_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l2_victimram_en));


  // Inidcates that the L2 victimrams may not be accessed in the next cycle and
  // can be put in to a light sleep mode.
  //  output l2_victimram_no_acc_next_cycle valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "l2_victimram_no_acc_next_cycle X or Z")
  u_ovl_intf_x_l2_victimram_no_acc_next_cycle (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l2_victimram_no_acc_next_cycle));


  // Global write enable
  //  output l2_victimram_wr valid l2_victimram_en timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "l2_victimram_wr X or Z")
  u_ovl_intf_x_l2_victimram_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_victimram_en),
    .test_expr (l2_victimram_wr));


  // Bit strobes
  //  output [`CA53_SCU_L2_VICTIMRAM_STRB_W-1:0] l2_victimram_strb valid l2_victimram_en timing 30%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_VICTIMRAM_STRB_W-1) - (0) + 1), OUTOPTIONS, "l2_victimram_strb X or Z")
  u_ovl_intf_x_l2_victimram_strb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_victimram_en),
    .test_expr (l2_victimram_strb));


  // Victim RAM address
  //  output [`CA53_SCU_L2_VICTIMRAM_ADDR_W-1:0] l2_victimram_addr valid l2_victimram_en timing 30%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_VICTIMRAM_ADDR_W-1) - (0) + 1), OUTOPTIONS, "l2_victimram_addr X or Z")
  u_ovl_intf_x_l2_victimram_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_victimram_en),
    .test_expr (l2_victimram_addr));


  // Victim write data
  //  output [`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0] l2_victimram_wdata valid l2_victimram_en timing 30%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_VICTIMRAM_DATA_W-1) - (0) + 1), OUTOPTIONS, "l2_victimram_wdata X or Z")
  u_ovl_intf_x_l2_victimram_wdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_victimram_en),
    .test_expr (l2_victimram_wdata));


  // Victim read data
  //  input [`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0] l2_victimram_rdata valid l2_victimram_en@1 & ~l2_victimram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_VICTIMRAM_DATA_W-1) - (0) + 1), INOPTIONS, "l2_victimram_rdata X or Z")
  u_ovl_intf_x_l2_victimram_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_victimram_en_reg & ~l2_victimram_wr_reg),
    .test_expr (l2_victimram_rdata));


  // RAMs must not be accessed when in retention

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "in_retention  => ~|l2_victimram_en")
  u_ovl_intf_assert_24dc1abbd89c88a1a1372658ec3708a78c12e0eb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (in_retention ),
    .consequent_expr (~|l2_victimram_en));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "in_retention  => ~l2_victimram_clken")
  u_ovl_intf_assert_5f03caa3b84f84dcb2943376edc0136492f29330 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (in_retention ),
    .consequent_expr (~l2_victimram_clken));


  // If no-access was indicated in the last cycle allowing light-sleep we must never see an enable in this cycle

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "l2_victimram_no_acc_next_cycle@1  => ~|l2_victimram_en")
  u_ovl_intf_assert_54ea2230f68e4ae63f1b00a9fd8730f8ebb28973 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_victimram_no_acc_next_cycle_reg ),
    .consequent_expr (~|l2_victimram_en));


  // If no-access has changed so that it is now asserted it must have been deasserted for at least the previous 32-cycles
  //
  // The counter register below is enabled whenever the L2 Victim RAM No Access signal is asserted, but forced to 0.  Once the
  // L2 Victim RAM No Access signal is deasserted the counter register remains enabled until it reaches 32 at which point the
  // counter saturates and is disabled until L2 Victim RAM No Access is enabled again.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    victim_ram_count_32 <= {5{1'b0}};
  else if (l2_victimram_no_acc_next_cycle | ~(&victim_ram_count_32))
    victim_ram_count_32 <= l2_victimram_no_acc_next_cycle ? 5'b00000 : (victim_ram_count_32 + 5'b00001);



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(L2_CACHE != 0) & l2_victimram_no_acc_next_cycle & ~l2_victimram_no_acc_next_cycle@1  => (&victim_ram_count_32)")
  u_ovl_intf_assert_9c48121b80433bb76986ffad00810d4b294a1130 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((L2_CACHE != 0) & l2_victimram_no_acc_next_cycle & ~l2_victimram_no_acc_next_cycle_reg ),
    .consequent_expr ((&victim_ram_count_32)));


  // If there is no L2 cache, this interface must not be enabled

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "L2_CACHE == 0  => ~l2_victimram_en")
  u_ovl_intf_assert_e1fbd9c92a7c799f01c72bec33694b80bce83c8f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (L2_CACHE == 0 ),
    .consequent_expr (~l2_victimram_en));


  // The clock enable must always be asserted when a request is made

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|l2_victimram_en  => l2_victimram_clken")
  u_ovl_intf_assert_fae8be43f79041f1a9ec02aa9bdf577b3f3dac3f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|l2_victimram_en ),
    .consequent_expr (l2_victimram_clken));


  // The strobes should be consistant with the write enable.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "l2_victimram_en & ~l2_victimram_wr  => ~|l2_victimram_strb")
  u_ovl_intf_assert_0b7178336b6ead8b96b9669438367bc74604c45b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_victimram_en & ~l2_victimram_wr ),
    .consequent_expr (~|l2_victimram_strb));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "l2_victimram_en & l2_victimram_wr  => |l2_victimram_strb")
  u_ovl_intf_assert_6b81cd1eecca79b9bdf409eb692424ec6f075a97 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_victimram_en & l2_victimram_wr ),
    .consequent_expr (|l2_victimram_strb));


  //---------------------------------------------------------------------------
  // L2 data RAMs
  //---------------------------------------------------------------------------

  // Clock enables for L2 datarams. Must be high when the RAMs are enabled, but
  // may also be speculatively high at other times. When input latency is
  // enabled, it will only be high for the second of the two cycles.
  //  output [`CA53_SCU_L2_DATARAM_EN_W-1:0] l2_dataram_clken valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_DATARAM_EN_W-1) - (0) + 1), OUTOPTIONS, "l2_dataram_clken X or Z")
  u_ovl_intf_x_l2_dataram_clken (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l2_dataram_clken));


  // Inidcates that the L2 datarams may not be accessed in the next cycle and
  // can be put in to a light sleep mode.
  //  output l2_dataram_no_acc_next_cycle valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "l2_dataram_no_acc_next_cycle X or Z")
  u_ovl_intf_x_l2_dataram_no_acc_next_cycle (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l2_dataram_no_acc_next_cycle));


  // Enables for each bank of 64/72 bits
  //  output [`CA53_SCU_L2_DATARAM_EN_W-1:0] l2_dataram_en valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_DATARAM_EN_W-1) - (0) + 1), OUTOPTIONS, "l2_dataram_en X or Z")
  u_ovl_intf_x_l2_dataram_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l2_dataram_en));


  // Global write enable
  //  output l2_dataram_wr valid |l2_dataram_en timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "l2_dataram_wr X or Z")
  u_ovl_intf_x_l2_dataram_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|l2_dataram_en),
    .test_expr (l2_dataram_wr));


  // Data RAM address, shared for all banks
  //  output [`CA53_SCU_L2_DATARAM_ADDR_W-1:0] l2_dataram_addr valid |l2_dataram_en timing 30%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_DATARAM_ADDR_W-1) - (0) + 1), OUTOPTIONS, "l2_dataram_addr X or Z")
  u_ovl_intf_x_l2_dataram_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|l2_dataram_en),
    .test_expr (l2_dataram_addr));


  // Write data
  //  output [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata0 valid l2_dataram_en[0] & l2_dataram_wr timing 20%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_DATARAM_DATA_W-1) - (0) + 1), OUTOPTIONS, "l2_dataram_wdata0 X or Z")
  u_ovl_intf_x_l2_dataram_wdata0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_dataram_en[0] & l2_dataram_wr),
    .test_expr (l2_dataram_wdata0));

  //  output [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata1 valid l2_dataram_en[1] & l2_dataram_wr timing 20%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_DATARAM_DATA_W-1) - (0) + 1), OUTOPTIONS, "l2_dataram_wdata1 X or Z")
  u_ovl_intf_x_l2_dataram_wdata1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_dataram_en[1] & l2_dataram_wr),
    .test_expr (l2_dataram_wdata1));

  //  output [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata2 valid l2_dataram_en[2] & l2_dataram_wr timing 20%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_DATARAM_DATA_W-1) - (0) + 1), OUTOPTIONS, "l2_dataram_wdata2 X or Z")
  u_ovl_intf_x_l2_dataram_wdata2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_dataram_en[2] & l2_dataram_wr),
    .test_expr (l2_dataram_wdata2));

  //  output [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata3 valid l2_dataram_en[3] & l2_dataram_wr timing 20%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_DATARAM_DATA_W-1) - (0) + 1), OUTOPTIONS, "l2_dataram_wdata3 X or Z")
  u_ovl_intf_x_l2_dataram_wdata3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_dataram_en[3] & l2_dataram_wr),
    .test_expr (l2_dataram_wdata3));

  //  output [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata4 valid l2_dataram_en[4] & l2_dataram_wr timing 20%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_DATARAM_DATA_W-1) - (0) + 1), OUTOPTIONS, "l2_dataram_wdata4 X or Z")
  u_ovl_intf_x_l2_dataram_wdata4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_dataram_en[4] & l2_dataram_wr),
    .test_expr (l2_dataram_wdata4));

  //  output [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata5 valid l2_dataram_en[5] & l2_dataram_wr timing 20%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_DATARAM_DATA_W-1) - (0) + 1), OUTOPTIONS, "l2_dataram_wdata5 X or Z")
  u_ovl_intf_x_l2_dataram_wdata5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_dataram_en[5] & l2_dataram_wr),
    .test_expr (l2_dataram_wdata5));

  //  output [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata6 valid l2_dataram_en[6] & l2_dataram_wr timing 20%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_DATARAM_DATA_W-1) - (0) + 1), OUTOPTIONS, "l2_dataram_wdata6 X or Z")
  u_ovl_intf_x_l2_dataram_wdata6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_dataram_en[6] & l2_dataram_wr),
    .test_expr (l2_dataram_wdata6));

  //  output [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata7 valid l2_dataram_en[7] & l2_dataram_wr timing 20%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_SCU_L2_DATARAM_DATA_W-1) - (0) + 1), OUTOPTIONS, "l2_dataram_wdata7 X or Z")
  u_ovl_intf_x_l2_dataram_wdata7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (l2_dataram_en[7] & l2_dataram_wr),
    .test_expr (l2_dataram_wdata7));


  // Read data

  // The read data is valid either 2 or 3 cycles after the clock enable,
  // however we cannot do x checking because there may be speculative reads
  // which are later abandoned, and these could be to uninitialised locations.


  // RAMs must not be accessed when in retention

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "in_retention  => ~|l2_dataram_en")
  u_ovl_intf_assert_8e3a8c475ca93e16ecb2d648ddbe5bcc3ee2daca (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (in_retention ),
    .consequent_expr (~|l2_dataram_en));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "in_retention  => ~|l2_dataram_clken")
  u_ovl_intf_assert_ea291bde61fa17b54cca72ba58ee69f66399f200 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (in_retention ),
    .consequent_expr (~|l2_dataram_clken));


  // If there is no L2 cache, this interface must not be enabled

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "L2_CACHE == 0  => ~|l2_dataram_en")
  u_ovl_intf_assert_3eb8858429e77ef9939483be456594f517f98d04 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (L2_CACHE == 0 ),
    .consequent_expr (~|l2_dataram_en));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "L2_CACHE == 0  => ~|l2_dataram_clken")
  u_ovl_intf_assert_889ac0d31d4c799450a9b807b2dd154b8d786ab3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (L2_CACHE == 0 ),
    .consequent_expr (~|l2_dataram_clken));


  // The RAMs can only be accessed at most every other cycle

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|l2_dataram_clken@1  => ~|l2_dataram_clken")
  u_ovl_intf_assert_22641f191e53d5ff0074cf29ac53defa05e2b1aa (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|l2_dataram_clken_reg ),
    .consequent_expr (~|l2_dataram_clken));


  // If no-access was indicated in the last cycle allowing light-sleep we must never see an enable in this cycle

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "l2_dataram_no_acc_next_cycle@1  => ~|l2_dataram_clken")
  u_ovl_intf_assert_adb3cb4b95287ecf645a43ba98413512b23e60e0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_dataram_no_acc_next_cycle_reg ),
    .consequent_expr (~|l2_dataram_clken));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "l2_dataram_no_acc_next_cycle@1  => ~|l2_dataram_en")
  u_ovl_intf_assert_3ad2f5265c253c055d5cb2d4d78a682ae2e44da9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2_dataram_no_acc_next_cycle_reg ),
    .consequent_expr (~|l2_dataram_en));


  // If no-access has changed so that it is now asserted it must have been deasserted for at least the previous 32-cycles
  //
  // The counter register below is enabled whenever the L2 Data RAM No Access signal is asserted, but forced to 0.  Once the
  // L2 Data RAM No Access signal is deasserted the counter register remains enabled until it reaches 32 at which point the
  // counter saturates and is disabled until L2 Data RAM No Access is enabled again.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    data_ram_count_32 <= {5{1'b0}};
  else if (l2_dataram_no_acc_next_cycle | ~(&data_ram_count_32))
    data_ram_count_32 <= l2_dataram_no_acc_next_cycle ? 5'b00000 : (data_ram_count_32 + 5'b00001);



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(L2_CACHE != 0) & l2_dataram_no_acc_next_cycle & ~l2_dataram_no_acc_next_cycle@1  => (&data_ram_count_32)")
  u_ovl_intf_assert_e626615374aab30ec671621dd0cb18f2b064c4dc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((L2_CACHE != 0) & l2_dataram_no_acc_next_cycle & ~l2_dataram_no_acc_next_cycle_reg ),
    .consequent_expr ((&data_ram_count_32)));


  // When output latency is enabled, the RAM must not be enabled until 3 cycles after a read

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(L2_OUTPUT_LATENCY != 0) & |l2_dataram_clken@2 & |l2_dataram_en@2 & ~l2_dataram_wr@2  => ~|l2_dataram_clken")
  u_ovl_intf_assert_2c7bc8c42b58435705e9694210ac1427894a1348 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((L2_OUTPUT_LATENCY != 0) & |l2_dataram_clken_reg_reg & |l2_dataram_en_reg_reg & ~l2_dataram_wr_reg_reg ),
    .consequent_expr (~|l2_dataram_clken));


  // The clock enable must always be asserted when the bank enables are

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(L2_INPUT_LATENCY == 0)  => ~|(l2_dataram_en & ~l2_dataram_clken)")
  u_ovl_intf_assert_2166bb10b9703a7f9fdeebd91c431e931ec6d6d7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((L2_INPUT_LATENCY == 0) ),
    .consequent_expr (~|(l2_dataram_en & ~l2_dataram_clken)));


  // The clock enable must always be asserted when the bank enables are

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(L2_INPUT_LATENCY != 0)  => ~|(l2_dataram_en@1 & ~(l2_dataram_clken@1 | l2_dataram_clken))")
  u_ovl_intf_assert_c8650e91b51635964ad4df29bd00351c0f16dd5d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((L2_INPUT_LATENCY != 0) ),
    .consequent_expr (~|(l2_dataram_en_reg & ~(l2_dataram_clken_reg | l2_dataram_clken))));


  // When input latency is enabled, all inputs must be held constant for two cycles.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(L2_INPUT_LATENCY != 0) & |l2_dataram_clken  => l2_dataram_en == l2_dataram_en@1")
  u_ovl_intf_assert_080e90a84118b6802a49afd6e619342dcd8a6c5f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((L2_INPUT_LATENCY != 0) & |l2_dataram_clken ),
    .consequent_expr (l2_dataram_en == l2_dataram_en_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(L2_INPUT_LATENCY != 0) & |l2_dataram_clken  => l2_dataram_wr == l2_dataram_wr@1")
  u_ovl_intf_assert_6ccbc4569e03d787c640937db1e89c5b430aa9e0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((L2_INPUT_LATENCY != 0) & |l2_dataram_clken ),
    .consequent_expr (l2_dataram_wr == l2_dataram_wr_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(L2_INPUT_LATENCY != 0) & |l2_dataram_clken  => l2_dataram_addr == l2_dataram_addr@1")
  u_ovl_intf_assert_064eab86184f6d6259bfb81cd235e04616df9c26 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((L2_INPUT_LATENCY != 0) & |l2_dataram_clken ),
    .consequent_expr (l2_dataram_addr == l2_dataram_addr_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(L2_INPUT_LATENCY != 0) & |l2_dataram_clken  => l2_dataram_wdata0 === l2_dataram_wdata0@1")
  u_ovl_intf_assert_70179b0ddb50aa6696659ff54bbed19285504cf7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((L2_INPUT_LATENCY != 0) & |l2_dataram_clken ),
    .consequent_expr (l2_dataram_wdata0 === l2_dataram_wdata0_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(L2_INPUT_LATENCY != 0) & |l2_dataram_clken  => l2_dataram_wdata1 === l2_dataram_wdata1@1")
  u_ovl_intf_assert_297a5701a8014ab275992f7fa6875cbb36606cff (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((L2_INPUT_LATENCY != 0) & |l2_dataram_clken ),
    .consequent_expr (l2_dataram_wdata1 === l2_dataram_wdata1_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(L2_INPUT_LATENCY != 0) & |l2_dataram_clken  => l2_dataram_wdata2 === l2_dataram_wdata2@1")
  u_ovl_intf_assert_f546a3a83d1bd2146c191ae758a1e4eb621bd439 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((L2_INPUT_LATENCY != 0) & |l2_dataram_clken ),
    .consequent_expr (l2_dataram_wdata2 === l2_dataram_wdata2_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(L2_INPUT_LATENCY != 0) & |l2_dataram_clken  => l2_dataram_wdata3 === l2_dataram_wdata3@1")
  u_ovl_intf_assert_9cc4a26eee8e27bab91add3d5c3c702ccc2bc54d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((L2_INPUT_LATENCY != 0) & |l2_dataram_clken ),
    .consequent_expr (l2_dataram_wdata3 === l2_dataram_wdata3_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(L2_INPUT_LATENCY != 0) & |l2_dataram_clken  => l2_dataram_wdata4 === l2_dataram_wdata4@1")
  u_ovl_intf_assert_1f533ed2c6b350ce5fbcc21db949e493071bd0cb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((L2_INPUT_LATENCY != 0) & |l2_dataram_clken ),
    .consequent_expr (l2_dataram_wdata4 === l2_dataram_wdata4_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(L2_INPUT_LATENCY != 0) & |l2_dataram_clken  => l2_dataram_wdata5 === l2_dataram_wdata5@1")
  u_ovl_intf_assert_2b63332c1bdfc8df69b05ac5216f1e47f2665345 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((L2_INPUT_LATENCY != 0) & |l2_dataram_clken ),
    .consequent_expr (l2_dataram_wdata5 === l2_dataram_wdata5_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(L2_INPUT_LATENCY != 0) & |l2_dataram_clken  => l2_dataram_wdata6 === l2_dataram_wdata6@1")
  u_ovl_intf_assert_a0b3d86e7e5e63237141d40ee29a937d2b03d4c4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((L2_INPUT_LATENCY != 0) & |l2_dataram_clken ),
    .consequent_expr (l2_dataram_wdata6 === l2_dataram_wdata6_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(L2_INPUT_LATENCY != 0) & |l2_dataram_clken  => l2_dataram_wdata7 === l2_dataram_wdata7@1")
  u_ovl_intf_assert_e93360fb2bfb706282f04dc10d28fc9222d689af (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((L2_INPUT_LATENCY != 0) & |l2_dataram_clken ),
    .consequent_expr (l2_dataram_wdata7 === l2_dataram_wdata7_reg));



endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53scu_defs.v"
`include "cortexa53params.v"
`include "ca53_scu_rams_defs.v"
`undef CA53_UNDEFINE

`endif

