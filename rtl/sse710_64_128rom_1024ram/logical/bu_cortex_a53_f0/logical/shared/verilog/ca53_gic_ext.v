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

// This is the specification for the interface between the GIC and the top
// level.  This encapsulate the GIC Arbiter and all GIC CPU Interfaces.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_gic_ext_defs.v"
`include "cortexa53params.v"

module ca53_gic_ext #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         gov_giccdisable_i,
  input         nvcpumntirq_i);


  wire         gov_giccdisable = gov_giccdisable_i;
  wire         nvcpumntirq = nvcpumntirq_i;






  // ------------------------------------------------------
  // Interface signals : Interrupts
  // ------------------------------------------------------

  // Active low Virutal CPU maintenance interrupt request.  Corresponds to
  // PPI ID25.  This signal is provided for the case where PPIs are handled
  // externally to the CPU interface.
  //  output nvcpumntirq valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "nvcpumntirq X or Z")
  u_ovl_intf_x_nvcpumntirq (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (nvcpumntirq));



  // ------------------------------------------------------
  // Interface OVLs
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Hardware Disable
  // ------------------------------------------------------


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "gov_giccdisable  => nvcpumntirq")
  u_ovl_intf_assert_85a9a1e6409b460e408381212e5e08c9b9f7d7e5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_giccdisable ),
    .consequent_expr (nvcpumntirq));





endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_gic_ext_defs.v"
`undef CA53_UNDEFINE

`endif

