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

// This is the specification for the interface between the DPU and rams

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_dpu_rams_defs.v"
`include "cortexa53params.v"

module ca53_dpu_rams #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input   [2:0] dc_size_i,
  input   [2:0] ic_size_i);


  wire   [2:0] dc_size = dc_size_i;
  wire   [2:0] ic_size = ic_size_i;


  reg         out_of_reset;

  reg   [2:0] dc_size_reg;
  reg   [2:0] ic_size_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    dc_size_reg <= 3'b000;
    ic_size_reg <= 3'b000;
  end
  else
  begin
    dc_size_reg <= dc_size;
    ic_size_reg <= ic_size;
  end



  // ------------------------------------------------------
  // Interface signals
  // ------------------------------------------------------

  //  input [2:0]    dc_size           valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 3, INOPTIONS, "dc_size X or Z")
  u_ovl_intf_x_dc_size (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_size));

  //  input [2:0]    ic_size           valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 3, INOPTIONS, "ic_size X or Z")
  u_ovl_intf_x_ic_size (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ic_size));


  // ------------------------------------------------------
  // Interface OVLs
  // ------------------------------------------------------



  assert_always #(`OVL_FATAL, INOPTIONS, "dc_size in [`CA53_SIZE_8K, `CA53_SIZE_16K, `CA53_SIZE_32K, `CA53_SIZE_64K]")
  u_ovl_intf_assume_f9bb5566fbc3a2a5e5f37b06b3a8c8995c5498a4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (((dc_size == `CA53_SIZE_8K) | (dc_size ==  `CA53_SIZE_16K) | (dc_size ==  `CA53_SIZE_32K) | (dc_size ==  `CA53_SIZE_64K))));



  assert_always #(`OVL_FATAL, INOPTIONS, "ic_size in [`CA53_SIZE_8K, `CA53_SIZE_16K, `CA53_SIZE_32K, `CA53_SIZE_64K]")
  u_ovl_intf_assume_a3f1030bd99638eb2be24b699441686ab4d56b61 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (((ic_size == `CA53_SIZE_8K) | (ic_size ==  `CA53_SIZE_16K) | (ic_size ==  `CA53_SIZE_32K) | (ic_size ==  `CA53_SIZE_64K))));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    out_of_reset <= 1'b0;
  else
    out_of_reset <= 1'b1;


  // The RAM size cannot change outside of reset.

  assert_implication #(`OVL_FATAL, INOPTIONS, "out_of_reset  => dc_size == dc_size@1")
  u_ovl_intf_assume_ba11dcffa9a7b279d8422ce8185e8fc294a63179 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (out_of_reset ),
    .consequent_expr (dc_size == dc_size_reg));


  assert_implication #(`OVL_FATAL, INOPTIONS, "out_of_reset  => ic_size == ic_size@1")
  u_ovl_intf_assume_22c296dc97ac8e262e308b2c4c4500f51dc57a6d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (out_of_reset ),
    .consequent_expr (ic_size == ic_size_reg));



endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_dpu_rams_defs.v"
`undef CA53_UNDEFINE

`endif

