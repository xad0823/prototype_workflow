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

// This is the specification for the interface between the Governor and IFU.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_gov_ifu_defs.v"
`include "cortexa53params.v"

module ca53_gov_ifu #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         ifu_wfx_ready_i,
  input         gov_mbist_req_i);


  wire         ifu_wfx_ready = ifu_wfx_ready_i;
  wire         gov_mbist_req = gov_mbist_req_i;


  reg         out_of_reset;

  reg         gov_mbist_req_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    gov_mbist_req_reg <= 1'b0;
  end
  else
  begin
    gov_mbist_req_reg <= gov_mbist_req;
  end



  // To gain wfx entry permission the DPU has to check that there are no 
  // line fill in progress in the IFU. This is because we need to make sure everything is quiescent
  // before we can remove the clock.
  //  input ifu_wfx_ready valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ifu_wfx_ready X or Z")
  u_ovl_intf_x_ifu_wfx_ready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_wfx_ready));


  // The global mbist request arrives from the governor
  //  output gov_mbist_req valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_mbist_req X or Z")
  u_ovl_intf_x_gov_mbist_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_mbist_req));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    out_of_reset <= 1'b0;
  else
    out_of_reset <= 1'b1;



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "out_of_reset  => gov_mbist_req == gov_mbist_req@1")
  u_ovl_intf_assert_2c6fd952e80b1696747dd52b0a40f7c9a82521fd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (out_of_reset ),
    .consequent_expr (gov_mbist_req == gov_mbist_req_reg));


endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_gov_ifu_defs.v"
`undef CA53_UNDEFINE

`endif

