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

// This is the specification for the interface between the DPU and GIC
// Inputs and outputs are from the point of view of the DPU.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_dpu_gic_defs.v"
`include "cortexa53params.v"

module ca53_dpu_gic #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         gic_fiq_i,
  input         gic_icc_sre_el1_ns_sre_i,
  input         gic_icc_sre_el1_s_sre_i,
  input         gic_icc_sre_el2_enable_i,
  input         gic_icc_sre_el2_sre_i,
  input         gic_icc_sre_el3_enable_i,
  input         gic_icc_sre_el3_sre_i,
  input         gic_ich_hcr_el2_tall0_i,
  input         gic_ich_hcr_el2_tall1_i,
  input         gic_ich_hcr_el2_tc_i,
  input         gic_irq_i,
  input         gic_vfiq_i,
  input         gic_virq_i,
  input         gov_giccdisable_i);


  wire         gic_fiq = gic_fiq_i;
  wire         gic_icc_sre_el1_ns_sre = gic_icc_sre_el1_ns_sre_i;
  wire         gic_icc_sre_el1_s_sre = gic_icc_sre_el1_s_sre_i;
  wire         gic_icc_sre_el2_enable = gic_icc_sre_el2_enable_i;
  wire         gic_icc_sre_el2_sre = gic_icc_sre_el2_sre_i;
  wire         gic_icc_sre_el3_enable = gic_icc_sre_el3_enable_i;
  wire         gic_icc_sre_el3_sre = gic_icc_sre_el3_sre_i;
  wire         gic_ich_hcr_el2_tall0 = gic_ich_hcr_el2_tall0_i;
  wire         gic_ich_hcr_el2_tall1 = gic_ich_hcr_el2_tall1_i;
  wire         gic_ich_hcr_el2_tc = gic_ich_hcr_el2_tc_i;
  wire         gic_irq = gic_irq_i;
  wire         gic_vfiq = gic_vfiq_i;
  wire         gic_virq = gic_virq_i;
  wire         gov_giccdisable = gov_giccdisable_i;






  // ------------------------------------------------------
  // Interface signals : DPU from GIC
  // ------------------------------------------------------

  // Fast interrupt request (active high)
  //  input gic_fiq valid always timing 25% wiring 55%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gic_fiq X or Z")
  u_ovl_intf_x_gic_fiq (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gic_fiq));


  // ICC_SRE_EL1.SRE non-secure (untreated)
  //  input gic_icc_sre_el1_ns_sre valid always timing 25% wiring 55%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gic_icc_sre_el1_ns_sre X or Z")
  u_ovl_intf_x_gic_icc_sre_el1_ns_sre (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gic_icc_sre_el1_ns_sre));


  // ICC_SRE_EL1.SRE secure (untreated)
  //  input gic_icc_sre_el1_s_sre valid always timing 25% wiring 55%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gic_icc_sre_el1_s_sre X or Z")
  u_ovl_intf_x_gic_icc_sre_el1_s_sre (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gic_icc_sre_el1_s_sre));


  // ICC_SRE_EL2.Enable (untreated)
  //  input gic_icc_sre_el2_enable valid always timing 25% wiring 55%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gic_icc_sre_el2_enable X or Z")
  u_ovl_intf_x_gic_icc_sre_el2_enable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gic_icc_sre_el2_enable));


  // ICC_SRE_EL2.SRE (untreated)
  //  input gic_icc_sre_el2_sre valid always timing 25% wiring 55%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gic_icc_sre_el2_sre X or Z")
  u_ovl_intf_x_gic_icc_sre_el2_sre (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gic_icc_sre_el2_sre));


  // ICC_SRE_EL3.Enable (untreated)
  //  input gic_icc_sre_el3_enable valid always timing 25% wiring 55%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gic_icc_sre_el3_enable X or Z")
  u_ovl_intf_x_gic_icc_sre_el3_enable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gic_icc_sre_el3_enable));


  // ICC_SRE_EL3.SRE
  //  input gic_icc_sre_el3_sre valid always timing 25% wiring 55%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gic_icc_sre_el3_sre X or Z")
  u_ovl_intf_x_gic_icc_sre_el3_sre (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gic_icc_sre_el3_sre));


  // ICH_HCR_EL2.TALL0
  //  input gic_ich_hcr_el2_tall0 valid always timing 25% wiring 55%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gic_ich_hcr_el2_tall0 X or Z")
  u_ovl_intf_x_gic_ich_hcr_el2_tall0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gic_ich_hcr_el2_tall0));


  // ICH_HCR_EL2.TALL1
  //  input gic_ich_hcr_el2_tall1 valid always timing 25% wiring 55%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gic_ich_hcr_el2_tall1 X or Z")
  u_ovl_intf_x_gic_ich_hcr_el2_tall1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gic_ich_hcr_el2_tall1));


  // ICH_HCR_EL2.TC
  //  input gic_ich_hcr_el2_tc valid always timing 25% wiring 55%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gic_ich_hcr_el2_tc X or Z")
  u_ovl_intf_x_gic_ich_hcr_el2_tc (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gic_ich_hcr_el2_tc));


  // IRQ (active high)
  //  input gic_irq valid always timing 25% wiring 55%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gic_irq X or Z")
  u_ovl_intf_x_gic_irq (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gic_irq));


  // Virtual FIQ (active high)
  //  input gic_vfiq valid always timing 25% wiring 55%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gic_vfiq X or Z")
  u_ovl_intf_x_gic_vfiq (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gic_vfiq));


  // Virtual IRQ (active high)
  //  input gic_virq valid always timing 25% wiring 55%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gic_virq X or Z")
  u_ovl_intf_x_gic_virq (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gic_virq));



  // ------------------------------------------------------
  // Interface OVLs
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Hardware Disable
  // ------------------------------------------------------

  // Hypervisor control register

  assert_implication #(`OVL_FATAL, INOPTIONS, "gov_giccdisable  => ~gic_ich_hcr_el2_tall0")
  u_ovl_intf_assume_873fc8bd659fdabbfa99c267648843719455e7fd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_giccdisable ),
    .consequent_expr (~gic_ich_hcr_el2_tall0));


  assert_implication #(`OVL_FATAL, INOPTIONS, "gov_giccdisable  => ~gic_ich_hcr_el2_tall1")
  u_ovl_intf_assume_16de2b772e694f33f7008e9e8a22373bdf2c0b0d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_giccdisable ),
    .consequent_expr (~gic_ich_hcr_el2_tall1));


  assert_implication #(`OVL_FATAL, INOPTIONS, "gov_giccdisable  => ~gic_ich_hcr_el2_tc")
  u_ovl_intf_assume_280a27ebdea72d0eced91e032a5eb466db1c6cde (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_giccdisable ),
    .consequent_expr (~gic_ich_hcr_el2_tc));


  // System register enables

  assert_implication #(`OVL_FATAL, INOPTIONS, "gov_giccdisable  => ~gic_icc_sre_el1_ns_sre")
  u_ovl_intf_assume_2979c72ab4092ff550e0cbbd24af74d39bc44ea6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_giccdisable ),
    .consequent_expr (~gic_icc_sre_el1_ns_sre));


  assert_implication #(`OVL_FATAL, INOPTIONS, "gov_giccdisable  => ~gic_icc_sre_el1_s_sre")
  u_ovl_intf_assume_3ad19033ceeb2f2286e0a1b09038b39c7b00e445 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_giccdisable ),
    .consequent_expr (~gic_icc_sre_el1_s_sre));


  assert_implication #(`OVL_FATAL, INOPTIONS, "gov_giccdisable  => ~gic_icc_sre_el2_enable")
  u_ovl_intf_assume_0b2c024bce6663f26d52b60360b3c2467a3ebc7e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_giccdisable ),
    .consequent_expr (~gic_icc_sre_el2_enable));


  assert_implication #(`OVL_FATAL, INOPTIONS, "gov_giccdisable  => ~gic_icc_sre_el2_sre")
  u_ovl_intf_assume_da7661aeae51ca721d79f8e39952715dff3b178a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_giccdisable ),
    .consequent_expr (~gic_icc_sre_el2_sre));


  assert_implication #(`OVL_FATAL, INOPTIONS, "gov_giccdisable  => ~gic_icc_sre_el3_enable")
  u_ovl_intf_assume_375abf24f6abf2faebcc3452a1798ac40f47db68 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_giccdisable ),
    .consequent_expr (~gic_icc_sre_el3_enable));


  assert_implication #(`OVL_FATAL, INOPTIONS, "gov_giccdisable  => ~gic_icc_sre_el3_sre")
  u_ovl_intf_assume_6269e3b66135f399b784043850683fd9641e0e71 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_giccdisable ),
    .consequent_expr (~gic_icc_sre_el3_sre));





endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_dpu_gic_defs.v"
`undef CA53_UNDEFINE

`endif

