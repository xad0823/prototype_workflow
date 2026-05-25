//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2015 ARM Limited.
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

// This is the specification for the interface between the GOV
// and the SCU.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_gov_scu_defs.v"
`include "cortexa53params.v"
`include "cortexa53params.v"

module ca53_gov_scu #(parameter NUM_CPUS             = 1, parameter CPU_CACHE_PROTECTION = 1'b0, parameter SCU_CACHE_PROTECTION = 1'b0, parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input [NUM_CPUS-1:0] scu_wfx_ready_i,
  input         scu_axierr_i,
  input         scu_eccerr_i,
  input         scu_l2ecc_valid_i,
  input         scu_l2ecc_fatal_i,
  input   [1:0] scu_l2ecc_ramid_i,
  input   [3:0] scu_l2ecc_cpuid_way_i,
  input  [14:0] scu_l2ecc_index_i,
  input         scu_l2_retention_ready_i,
  input         scu_cpu0_inv_all_ack_i,
  input         scu_cpu1_inv_all_ack_i,
  input         scu_cpu2_inv_all_ack_i,
  input         scu_cpu3_inv_all_ack_i,
  input         scu_mbistack0_i,
  input         scu_mbistack1_i,
  input [`CA53_MBIST0_DATA_W-1: 0] scu_mbistoutdata0_i,
  input [`CA53_MBIST1_DATA_W-1: 0] scu_mbistoutdata1_i,
  input         gov_cpu0_smp_en_i,
  input         gov_cpu1_smp_en_i,
  input         gov_cpu2_smp_en_i,
  input         gov_cpu3_smp_en_i,
  input [NUM_CPUS-1:0] gov_standbywfi_i,
  input         gov_enable_writeevict_i,
  input         gov_disable_evict_i,
  input         gov_l2deien_i,
  input         gov_l2teien_i,
  input   [1:0] gov_l2victim_ctl_i,
  input         gov_clear_axierr_i,
  input         gov_clear_eccerr_i,
  input         gov_l2_in_retention_i,
  input         gov_cpu0_inv_all_req_i,
  input         gov_cpu1_inv_all_req_i,
  input         gov_cpu2_inv_all_req_i,
  input         gov_cpu3_inv_all_req_i,
  input         gov_mbistreq_i,
  input [`CA53_MBIST0_RAMARRAY_W-1:0] gov_mbistarray0_i,
  input [`CA53_MBIST1_RAMARRAY_W-1:0] gov_mbistarray1_i,
  input         gov_mbistwriteen0_i,
  input         gov_mbistwriteen1_i,
  input         gov_mbistreaden0_i,
  input         gov_mbistreaden1_i,
  input [`CA53_MBIST0_ADDR_W-1: 0] gov_mbistaddr0_i,
  input [`CA53_MBIST1_ADDR_W-1: 0] gov_mbistaddr1_i,
  input [`CA53_MBIST0_BE_W-1:0] gov_mbistbe0_i,
  input [`CA53_MBIST1_BE_W-1:0] gov_mbistbe1_i,
  input         gov_mbistcfg0_i,
  input         gov_mbistcfg1_i,
  input [`CA53_MBIST0_DATA_W-1: 0] gov_mbistindata0_i,
  input [`CA53_MBIST1_DATA_W-1: 0] gov_mbistindata1_i);


  wire [NUM_CPUS-1:0] scu_wfx_ready = scu_wfx_ready_i;
  wire         scu_axierr = scu_axierr_i;
  wire         scu_eccerr = scu_eccerr_i;
  wire         scu_l2ecc_valid = scu_l2ecc_valid_i;
  wire         scu_l2ecc_fatal = scu_l2ecc_fatal_i;
  wire   [1:0] scu_l2ecc_ramid = scu_l2ecc_ramid_i;
  wire   [3:0] scu_l2ecc_cpuid_way = scu_l2ecc_cpuid_way_i;
  wire  [14:0] scu_l2ecc_index = scu_l2ecc_index_i;
  wire         scu_l2_retention_ready = scu_l2_retention_ready_i;
  wire         scu_cpu0_inv_all_ack = scu_cpu0_inv_all_ack_i;
  wire         scu_cpu1_inv_all_ack = scu_cpu1_inv_all_ack_i;
  wire         scu_cpu2_inv_all_ack = scu_cpu2_inv_all_ack_i;
  wire         scu_cpu3_inv_all_ack = scu_cpu3_inv_all_ack_i;
  wire         scu_mbistack0 = scu_mbistack0_i;
  wire         scu_mbistack1 = scu_mbistack1_i;
  wire [`CA53_MBIST0_DATA_W-1: 0] scu_mbistoutdata0 = scu_mbistoutdata0_i;
  wire [`CA53_MBIST1_DATA_W-1: 0] scu_mbistoutdata1 = scu_mbistoutdata1_i;
  wire         gov_cpu0_smp_en = gov_cpu0_smp_en_i;
  wire         gov_cpu1_smp_en = gov_cpu1_smp_en_i;
  wire         gov_cpu2_smp_en = gov_cpu2_smp_en_i;
  wire         gov_cpu3_smp_en = gov_cpu3_smp_en_i;
  wire [NUM_CPUS-1:0] gov_standbywfi = gov_standbywfi_i;
  wire         gov_enable_writeevict = gov_enable_writeevict_i;
  wire         gov_disable_evict = gov_disable_evict_i;
  wire         gov_l2deien = gov_l2deien_i;
  wire         gov_l2teien = gov_l2teien_i;
  wire   [1:0] gov_l2victim_ctl = gov_l2victim_ctl_i;
  wire         gov_clear_axierr = gov_clear_axierr_i;
  wire         gov_clear_eccerr = gov_clear_eccerr_i;
  wire         gov_l2_in_retention = gov_l2_in_retention_i;
  wire         gov_cpu0_inv_all_req = gov_cpu0_inv_all_req_i;
  wire         gov_cpu1_inv_all_req = gov_cpu1_inv_all_req_i;
  wire         gov_cpu2_inv_all_req = gov_cpu2_inv_all_req_i;
  wire         gov_cpu3_inv_all_req = gov_cpu3_inv_all_req_i;
  wire         gov_mbistreq = gov_mbistreq_i;
  wire [`CA53_MBIST0_RAMARRAY_W-1:0] gov_mbistarray0 = gov_mbistarray0_i;
  wire [`CA53_MBIST1_RAMARRAY_W-1:0] gov_mbistarray1 = gov_mbistarray1_i;
  wire         gov_mbistwriteen0 = gov_mbistwriteen0_i;
  wire         gov_mbistwriteen1 = gov_mbistwriteen1_i;
  wire         gov_mbistreaden0 = gov_mbistreaden0_i;
  wire         gov_mbistreaden1 = gov_mbistreaden1_i;
  wire [`CA53_MBIST0_ADDR_W-1: 0] gov_mbistaddr0 = gov_mbistaddr0_i;
  wire [`CA53_MBIST1_ADDR_W-1: 0] gov_mbistaddr1 = gov_mbistaddr1_i;
  wire [`CA53_MBIST0_BE_W-1:0] gov_mbistbe0 = gov_mbistbe0_i;
  wire [`CA53_MBIST1_BE_W-1:0] gov_mbistbe1 = gov_mbistbe1_i;
  wire         gov_mbistcfg0 = gov_mbistcfg0_i;
  wire         gov_mbistcfg1 = gov_mbistcfg1_i;
  wire [`CA53_MBIST0_DATA_W-1: 0] gov_mbistindata0 = gov_mbistindata0_i;
  wire [`CA53_MBIST1_DATA_W-1: 0] gov_mbistindata1 = gov_mbistindata1_i;


  reg         out_of_reset;

  reg         scu_l2_retention_ready_reg;
  reg         scu_l2_retention_ready_reg_reg;
  reg         scu_l2_retention_ready_reg_reg_reg;
  reg         scu_cpu0_inv_all_ack_reg;
  reg         gov_cpu2_inv_all_req_reg;
  reg         gov_l2_in_retention_reg;
  reg         gov_l2_in_retention_reg_reg;
  reg         gov_l2_in_retention_reg_reg_reg;
  reg         gov_l2_in_retention_reg_reg_reg_reg;
  reg         gov_l2_in_retention_reg_reg_reg_reg_reg;
  reg         gov_l2_in_retention_reg_reg_reg_reg_reg_reg;
  reg         gov_l2_in_retention_reg_reg_reg_reg_reg_reg_reg;
  reg         scu_cpu1_inv_all_ack_reg;
  reg         gov_cpu3_inv_all_req_reg;
  reg         scu_cpu3_inv_all_ack_reg;
  reg         scu_cpu2_inv_all_ack_reg;
  reg         gov_cpu0_inv_all_req_reg;
  reg         gov_cpu1_inv_all_req_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    scu_l2_retention_ready_reg <= 1'b0;
    scu_l2_retention_ready_reg_reg <= 1'b0;
    scu_l2_retention_ready_reg_reg_reg <= 1'b0;
    scu_cpu0_inv_all_ack_reg <= 1'b0;
    gov_cpu2_inv_all_req_reg <= 1'b0;
    gov_l2_in_retention_reg <= 1'b0;
    gov_l2_in_retention_reg_reg <= 1'b0;
    gov_l2_in_retention_reg_reg_reg <= 1'b0;
    gov_l2_in_retention_reg_reg_reg_reg <= 1'b0;
    gov_l2_in_retention_reg_reg_reg_reg_reg <= 1'b0;
    gov_l2_in_retention_reg_reg_reg_reg_reg_reg <= 1'b0;
    gov_l2_in_retention_reg_reg_reg_reg_reg_reg_reg <= 1'b0;
    scu_cpu1_inv_all_ack_reg <= 1'b0;
    gov_cpu3_inv_all_req_reg <= 1'b0;
    scu_cpu3_inv_all_ack_reg <= 1'b0;
    scu_cpu2_inv_all_ack_reg <= 1'b0;
    gov_cpu0_inv_all_req_reg <= 1'b0;
    gov_cpu1_inv_all_req_reg <= 1'b0;
  end
  else
  begin
    scu_l2_retention_ready_reg <= scu_l2_retention_ready;
    scu_l2_retention_ready_reg_reg <= scu_l2_retention_ready_reg;
    scu_l2_retention_ready_reg_reg_reg <= scu_l2_retention_ready_reg_reg;
    scu_cpu0_inv_all_ack_reg <= scu_cpu0_inv_all_ack;
    scu_cpu1_inv_all_ack_reg <= scu_cpu1_inv_all_ack;
    scu_cpu2_inv_all_ack_reg <= scu_cpu2_inv_all_ack;
    scu_cpu3_inv_all_ack_reg <= scu_cpu3_inv_all_ack;
    gov_l2_in_retention_reg <= gov_l2_in_retention;
    gov_l2_in_retention_reg_reg <= gov_l2_in_retention_reg;
    gov_l2_in_retention_reg_reg_reg <= gov_l2_in_retention_reg_reg;
    gov_l2_in_retention_reg_reg_reg_reg <= gov_l2_in_retention_reg_reg_reg;
    gov_l2_in_retention_reg_reg_reg_reg_reg <= gov_l2_in_retention_reg_reg_reg_reg;
    gov_l2_in_retention_reg_reg_reg_reg_reg_reg <= gov_l2_in_retention_reg_reg_reg_reg_reg;
    gov_l2_in_retention_reg_reg_reg_reg_reg_reg_reg <= gov_l2_in_retention_reg_reg_reg_reg_reg_reg;
    gov_cpu0_inv_all_req_reg <= gov_cpu0_inv_all_req;
    gov_cpu1_inv_all_req_reg <= gov_cpu1_inv_all_req;
    gov_cpu2_inv_all_req_reg <= gov_cpu2_inv_all_req;
    gov_cpu3_inv_all_req_reg <= gov_cpu3_inv_all_req;
  end



  // ------------------------------------------------------
  // Interface signals
  // ------------------------------------------------------

  // SMP enable
  //  output                             gov_cpu0_smp_en               valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_cpu0_smp_en X or Z")
  u_ovl_intf_x_gov_cpu0_smp_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_cpu0_smp_en));

  //  output                             gov_cpu1_smp_en               valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_cpu1_smp_en X or Z")
  u_ovl_intf_x_gov_cpu1_smp_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_cpu1_smp_en));

  //  output                             gov_cpu2_smp_en               valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_cpu2_smp_en X or Z")
  u_ovl_intf_x_gov_cpu2_smp_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_cpu2_smp_en));

  //  output                             gov_cpu3_smp_en               valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_cpu3_smp_en X or Z")
  u_ovl_intf_x_gov_cpu3_smp_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_cpu3_smp_en));


  // WFI
  //  output [NUM_CPUS-1:0]              gov_standbywfi                valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, ((NUM_CPUS-1) - (0) + 1), OUTOPTIONS, "gov_standbywfi X or Z")
  u_ovl_intf_x_gov_standbywfi (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_standbywfi));

  //  input  [NUM_CPUS-1:0]              scu_wfx_ready                 valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, ((NUM_CPUS-1) - (0) + 1), INOPTIONS, "scu_wfx_ready X or Z")
  u_ovl_intf_x_scu_wfx_ready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_wfx_ready));


  // L2ACTLR outputs
  //  output                             gov_enable_writeevict         valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_enable_writeevict X or Z")
  u_ovl_intf_x_gov_enable_writeevict (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_enable_writeevict));

  //  output                             gov_disable_evict             valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_disable_evict X or Z")
  u_ovl_intf_x_gov_disable_evict (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_disable_evict));


  //  output                             gov_l2deien                   valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_l2deien X or Z")
  u_ovl_intf_x_gov_l2deien (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_l2deien));

  //  output                             gov_l2teien                   valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_l2teien X or Z")
  u_ovl_intf_x_gov_l2teien (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_l2teien));


  //  output [1:0]                       gov_l2victim_ctl              valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "gov_l2victim_ctl X or Z")
  u_ovl_intf_x_gov_l2victim_ctl (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_l2victim_ctl));


  //  output                             gov_clear_axierr              valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_clear_axierr X or Z")
  u_ovl_intf_x_gov_clear_axierr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_clear_axierr));

  //  output                             gov_clear_eccerr              valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_clear_eccerr X or Z")
  u_ovl_intf_x_gov_clear_eccerr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_clear_eccerr));


  //  input                              scu_axierr                    valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_axierr X or Z")
  u_ovl_intf_x_scu_axierr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_axierr));

  //  input                              scu_eccerr                    valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_eccerr X or Z")
  u_ovl_intf_x_scu_eccerr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_eccerr));


  // ECC inputs
  //  input                              scu_l2ecc_valid               valid always          timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_l2ecc_valid X or Z")
  u_ovl_intf_x_scu_l2ecc_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_l2ecc_valid));

  //  input                              scu_l2ecc_fatal               valid scu_l2ecc_valid timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_l2ecc_fatal X or Z")
  u_ovl_intf_x_scu_l2ecc_fatal (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_l2ecc_valid),
    .test_expr (scu_l2ecc_fatal));

  //  input [1:0]                        scu_l2ecc_ramid               valid scu_l2ecc_valid timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "scu_l2ecc_ramid X or Z")
  u_ovl_intf_x_scu_l2ecc_ramid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_l2ecc_valid),
    .test_expr (scu_l2ecc_ramid));

  //  input [3:0]                        scu_l2ecc_cpuid_way           valid scu_l2ecc_valid timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 4, INOPTIONS, "scu_l2ecc_cpuid_way X or Z")
  u_ovl_intf_x_scu_l2ecc_cpuid_way (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_l2ecc_valid),
    .test_expr (scu_l2ecc_cpuid_way));

  //  input [14:0]                       scu_l2ecc_index               valid scu_l2ecc_valid timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 15, INOPTIONS, "scu_l2ecc_index X or Z")
  u_ovl_intf_x_scu_l2ecc_index (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_l2ecc_valid),
    .test_expr (scu_l2ecc_index));


  // Retention control
  //  input                              scu_l2_retention_ready        valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_l2_retention_ready X or Z")
  u_ovl_intf_x_scu_l2_retention_ready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_l2_retention_ready));

  //  output                             gov_l2_in_retention           valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_l2_in_retention X or Z")
  u_ovl_intf_x_gov_l2_in_retention (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_l2_in_retention));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    out_of_reset <= 1'b0;
  else
    out_of_reset <= 1'b1;


  // The governor must not put the RAMs into retention when the SCU is not ready.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~gov_l2_in_retention@1 & ~scu_l2_retention_ready@3 & out_of_reset  => ~gov_l2_in_retention")
  u_ovl_intf_assert_58aaeb905777147b567444aabe09a8ea6b8fcea2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~gov_l2_in_retention_reg & ~scu_l2_retention_ready_reg_reg_reg & out_of_reset ),
    .consequent_expr (~gov_l2_in_retention));


  // If the SCU requires the RAMs in the first five cycles that the governor
  // starts to enter retention, then the governor should abandon the retention
  // request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~gov_l2_in_retention@2 & gov_l2_in_retention@1 & ~scu_l2_retention_ready@3  => ~gov_l2_in_retention")
  u_ovl_intf_assert_4600dc5f251d67a7c66fdad687d48e7c16fdde28 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~gov_l2_in_retention_reg_reg & gov_l2_in_retention_reg & ~scu_l2_retention_ready_reg_reg_reg ),
    .consequent_expr (~gov_l2_in_retention));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~gov_l2_in_retention@3 & gov_l2_in_retention@2 & ~scu_l2_retention_ready@3  => ~gov_l2_in_retention")
  u_ovl_intf_assert_711501e9bb1f970ea4dd6bce4a58a625d2795f86 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~gov_l2_in_retention_reg_reg_reg & gov_l2_in_retention_reg_reg & ~scu_l2_retention_ready_reg_reg_reg ),
    .consequent_expr (~gov_l2_in_retention));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~gov_l2_in_retention@4 & gov_l2_in_retention@3 & ~scu_l2_retention_ready@3  => ~gov_l2_in_retention")
  u_ovl_intf_assert_184d1b5ebb23068875a29233ebae379b3982f0e0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~gov_l2_in_retention_reg_reg_reg_reg & gov_l2_in_retention_reg_reg_reg & ~scu_l2_retention_ready_reg_reg_reg ),
    .consequent_expr (~gov_l2_in_retention));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~gov_l2_in_retention@5 & gov_l2_in_retention@4 & ~scu_l2_retention_ready@3  => ~gov_l2_in_retention")
  u_ovl_intf_assert_865660acd798c467fe11b5998264413690f1f6c9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~gov_l2_in_retention_reg_reg_reg_reg_reg & gov_l2_in_retention_reg_reg_reg_reg & ~scu_l2_retention_ready_reg_reg_reg ),
    .consequent_expr (~gov_l2_in_retention));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~gov_l2_in_retention@6 & gov_l2_in_retention@5 & ~scu_l2_retention_ready@3  => ~gov_l2_in_retention")
  u_ovl_intf_assert_2b6a01b4092005ec2995aa7e9ea82b101cba6571 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~gov_l2_in_retention_reg_reg_reg_reg_reg_reg & gov_l2_in_retention_reg_reg_reg_reg_reg & ~scu_l2_retention_ready_reg_reg_reg ),
    .consequent_expr (~gov_l2_in_retention));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~gov_l2_in_retention@7 & gov_l2_in_retention@6 & ~scu_l2_retention_ready@3  => ~gov_l2_in_retention")
  u_ovl_intf_assert_77ed219a727e02d291bcebf9f95eb6a4acd9d362 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~gov_l2_in_retention_reg_reg_reg_reg_reg_reg_reg & gov_l2_in_retention_reg_reg_reg_reg_reg_reg & ~scu_l2_retention_ready_reg_reg_reg ),
    .consequent_expr (~gov_l2_in_retention));


  // The GOV indicates when it is about to perform an invalidate all on reset,
  // so the SCU can invalidate its duplicate tags.  The SCU responds once it
  // has started the invalidate process
  //  output                               gov_cpu0_inv_all_req         valid always       timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_cpu0_inv_all_req X or Z")
  u_ovl_intf_x_gov_cpu0_inv_all_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_cpu0_inv_all_req));

  //  output                               gov_cpu1_inv_all_req         valid always       timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_cpu1_inv_all_req X or Z")
  u_ovl_intf_x_gov_cpu1_inv_all_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_cpu1_inv_all_req));

  //  output                               gov_cpu2_inv_all_req         valid always       timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_cpu2_inv_all_req X or Z")
  u_ovl_intf_x_gov_cpu2_inv_all_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_cpu2_inv_all_req));

  //  output                               gov_cpu3_inv_all_req         valid always       timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_cpu3_inv_all_req X or Z")
  u_ovl_intf_x_gov_cpu3_inv_all_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_cpu3_inv_all_req));

  //  input                                scu_cpu0_inv_all_ack         valid always       timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_cpu0_inv_all_ack X or Z")
  u_ovl_intf_x_scu_cpu0_inv_all_ack (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_cpu0_inv_all_ack));

  //  input                                scu_cpu1_inv_all_ack         valid always       timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_cpu1_inv_all_ack X or Z")
  u_ovl_intf_x_scu_cpu1_inv_all_ack (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_cpu1_inv_all_ack));

  //  input                                scu_cpu2_inv_all_ack         valid always       timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_cpu2_inv_all_ack X or Z")
  u_ovl_intf_x_scu_cpu2_inv_all_ack (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_cpu2_inv_all_ack));

  //  input                                scu_cpu3_inv_all_ack         valid always       timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_cpu3_inv_all_ack X or Z")
  u_ovl_intf_x_scu_cpu3_inv_all_ack (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_cpu3_inv_all_ack));


  // Once the request is asserted, it must be held until acknowledged.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "gov_cpu0_inv_all_req@1 & ~scu_cpu0_inv_all_ack@1  => gov_cpu0_inv_all_req")
  u_ovl_intf_assert_802b73ef660d339f410f6f0d29d959fc77b69207 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_cpu0_inv_all_req_reg & ~scu_cpu0_inv_all_ack_reg ),
    .consequent_expr (gov_cpu0_inv_all_req));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "gov_cpu1_inv_all_req@1 & ~scu_cpu1_inv_all_ack@1  => gov_cpu1_inv_all_req")
  u_ovl_intf_assert_87bb1f125d78bf2abf4c98e7e4c3176f23134cd9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_cpu1_inv_all_req_reg & ~scu_cpu1_inv_all_ack_reg ),
    .consequent_expr (gov_cpu1_inv_all_req));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "gov_cpu2_inv_all_req@1 & ~scu_cpu2_inv_all_ack@1  => gov_cpu2_inv_all_req")
  u_ovl_intf_assert_6bcdb128f916c325e152827c1a6cf456b6c1f0ef (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_cpu2_inv_all_req_reg & ~scu_cpu2_inv_all_ack_reg ),
    .consequent_expr (gov_cpu2_inv_all_req));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "gov_cpu3_inv_all_req@1 & ~scu_cpu3_inv_all_ack@1  => gov_cpu3_inv_all_req")
  u_ovl_intf_assert_2141bd4fd37c082f60ca2529c531040fb70c3bfa (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_cpu3_inv_all_req_reg & ~scu_cpu3_inv_all_ack_reg ),
    .consequent_expr (gov_cpu3_inv_all_req));


  // The acknowledge must only be provided in response to a request.

  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_cpu0_inv_all_ack  => gov_cpu0_inv_all_req")
  u_ovl_intf_assume_7597d93c9289c10b09519a92c87259d87a78d5e4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_cpu0_inv_all_ack ),
    .consequent_expr (gov_cpu0_inv_all_req));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_cpu1_inv_all_ack  => gov_cpu1_inv_all_req")
  u_ovl_intf_assume_47b4fe178c511410ba4c476e0a39e6276a3867a2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_cpu1_inv_all_ack ),
    .consequent_expr (gov_cpu1_inv_all_req));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_cpu2_inv_all_ack  => gov_cpu2_inv_all_req")
  u_ovl_intf_assume_859c73fc5c417bdbde4407c74c0fb6ac4e59f096 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_cpu2_inv_all_ack ),
    .consequent_expr (gov_cpu2_inv_all_req));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_cpu3_inv_all_ack  => gov_cpu3_inv_all_req")
  u_ovl_intf_assume_f6e5f61a23fefc6d517e72d9515433472704dcab (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_cpu3_inv_all_ack ),
    .consequent_expr (gov_cpu3_inv_all_req));


  // MBIST interface. This is the standard external interface, after registering in the governor.
  //  output                               gov_mbistreq                 valid always       timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_mbistreq X or Z")
  u_ovl_intf_x_gov_mbistreq (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_mbistreq));

  //  input                                scu_mbistack0                valid always       timing 40% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_mbistack0 X or Z")
  u_ovl_intf_x_scu_mbistack0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_mbistack0));

  //  input                                scu_mbistack1                valid always       timing 40% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_mbistack1 X or Z")
  u_ovl_intf_x_scu_mbistack1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_mbistack1));

  //  output [`CA53_MBIST0_RAMARRAY_W-1:0] gov_mbistarray0              valid gov_mbistreq timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_MBIST0_RAMARRAY_W-1) - (0) + 1), OUTOPTIONS, "gov_mbistarray0 X or Z")
  u_ovl_intf_x_gov_mbistarray0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbistreq),
    .test_expr (gov_mbistarray0));

  //  output [`CA53_MBIST1_RAMARRAY_W-1:0] gov_mbistarray1              valid gov_mbistreq timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_MBIST1_RAMARRAY_W-1) - (0) + 1), OUTOPTIONS, "gov_mbistarray1 X or Z")
  u_ovl_intf_x_gov_mbistarray1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbistreq),
    .test_expr (gov_mbistarray1));

  //  output                               gov_mbistwriteen0            valid gov_mbistreq timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_mbistwriteen0 X or Z")
  u_ovl_intf_x_gov_mbistwriteen0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbistreq),
    .test_expr (gov_mbistwriteen0));

  //  output                               gov_mbistwriteen1            valid gov_mbistreq timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_mbistwriteen1 X or Z")
  u_ovl_intf_x_gov_mbistwriteen1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbistreq),
    .test_expr (gov_mbistwriteen1));

  //  output                               gov_mbistreaden0             valid gov_mbistreq timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_mbistreaden0 X or Z")
  u_ovl_intf_x_gov_mbistreaden0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbistreq),
    .test_expr (gov_mbistreaden0));

  //  output                               gov_mbistreaden1             valid gov_mbistreq timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_mbistreaden1 X or Z")
  u_ovl_intf_x_gov_mbistreaden1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbistreq),
    .test_expr (gov_mbistreaden1));

  //  output [`CA53_MBIST0_ADDR_W-1: 0]    gov_mbistaddr0               valid gov_mbistreq timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_MBIST0_ADDR_W-1) - ( 0) + 1), OUTOPTIONS, "gov_mbistaddr0 X or Z")
  u_ovl_intf_x_gov_mbistaddr0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbistreq),
    .test_expr (gov_mbistaddr0));

  //  output [`CA53_MBIST1_ADDR_W-1: 0]    gov_mbistaddr1               valid gov_mbistreq timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_MBIST1_ADDR_W-1) - ( 0) + 1), OUTOPTIONS, "gov_mbistaddr1 X or Z")
  u_ovl_intf_x_gov_mbistaddr1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbistreq),
    .test_expr (gov_mbistaddr1));

  //  output [`CA53_MBIST0_BE_W-1:0]       gov_mbistbe0                 valid gov_mbistreq timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_MBIST0_BE_W-1) - (0) + 1), OUTOPTIONS, "gov_mbistbe0 X or Z")
  u_ovl_intf_x_gov_mbistbe0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbistreq),
    .test_expr (gov_mbistbe0));

  //  output [`CA53_MBIST1_BE_W-1:0]       gov_mbistbe1                 valid gov_mbistreq timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_MBIST1_BE_W-1) - (0) + 1), OUTOPTIONS, "gov_mbistbe1 X or Z")
  u_ovl_intf_x_gov_mbistbe1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbistreq),
    .test_expr (gov_mbistbe1));

  //  output                               gov_mbistcfg0                valid gov_mbistreq timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_mbistcfg0 X or Z")
  u_ovl_intf_x_gov_mbistcfg0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbistreq),
    .test_expr (gov_mbistcfg0));

  //  output                               gov_mbistcfg1                valid gov_mbistreq timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_mbistcfg1 X or Z")
  u_ovl_intf_x_gov_mbistcfg1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbistreq),
    .test_expr (gov_mbistcfg1));

  //  output [`CA53_MBIST0_DATA_W-1: 0]    gov_mbistindata0             valid gov_mbistreq timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_MBIST0_DATA_W-1) - ( 0) + 1), OUTOPTIONS, "gov_mbistindata0 X or Z")
  u_ovl_intf_x_gov_mbistindata0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbistreq),
    .test_expr (gov_mbistindata0));

  //  output [`CA53_MBIST1_DATA_W-1: 0]    gov_mbistindata1             valid gov_mbistreq timing 20% wiring 40%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_MBIST1_DATA_W-1) - ( 0) + 1), OUTOPTIONS, "gov_mbistindata1 X or Z")
  u_ovl_intf_x_gov_mbistindata1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbistreq),
    .test_expr (gov_mbistindata1));

  //  input  [`CA53_MBIST0_DATA_W-1: 0]    scu_mbistoutdata0            valid gov_mbistreq timing 50% wiring 30%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_MBIST0_DATA_W-1) - ( 0) + 1), INOPTIONS, "scu_mbistoutdata0 X or Z")
  u_ovl_intf_x_scu_mbistoutdata0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbistreq),
    .test_expr (scu_mbistoutdata0));

  //  input  [`CA53_MBIST1_DATA_W-1: 0]    scu_mbistoutdata1            valid gov_mbistreq timing 50% wiring 30%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_MBIST1_DATA_W-1) - ( 0) + 1), INOPTIONS, "scu_mbistoutdata1 X or Z")
  u_ovl_intf_x_scu_mbistoutdata1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbistreq),
    .test_expr (scu_mbistoutdata1));



endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "cortexa53params.v"
`include "ca53_gov_scu_defs.v"
`undef CA53_UNDEFINE

`endif

