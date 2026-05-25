//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2010-2015 ARM Limited.
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

// This is the specification for the interface between the STB and the SCU for
// DVM complete messages.
// Inputs and outputs are from the point of view of the STB.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_stb_scu_defs.v"
`include "cortexa53params.v"

module ca53_stb_scu #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         scu_dvm_complete_i,
  input         scu_drain_stb_i);


  wire         scu_dvm_complete = scu_dvm_complete_i;
  wire         scu_drain_stb = scu_drain_stb_i;



  reg         scu_dvm_complete_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    scu_dvm_complete_reg <= 1'b0;
  end
  else
  begin
    scu_dvm_complete_reg <= scu_dvm_complete;
  end



  // DVM complete messages are returned directly to the STB rather than via the
  // snoop channel. This is a one shot signal that indicates a complete has
  // been received.
  //  input scu_dvm_complete valid always timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_dvm_complete X or Z")
  u_ovl_intf_x_scu_dvm_complete (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_dvm_complete));


  // A transaction is hazarding on a write for which the SCU does not have
  // the last beat of data. The STB should drain slots that are speculatively
  // waiting for more data to add to a burst.
  //  input scu_drain_stb valid always timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_drain_stb X or Z")
  u_ovl_intf_x_scu_drain_stb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_drain_stb));


  // Only one DVM sync can be in progress, therefore back to back completes
  // are not possible.

  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dvm_complete@1  => ~scu_dvm_complete")
  u_ovl_intf_assume_8c44729aa1395b2a54dd6305e6c8a40d1380bf59 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dvm_complete_reg ),
    .consequent_expr (~scu_dvm_complete));



endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_stb_scu_defs.v"
`undef CA53_UNDEFINE

`endif

