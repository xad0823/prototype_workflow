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

// This is the specification for the interface between the Governor and BIU.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_gov_biu_defs.v"
`include "cortexa53params.v"

module ca53_gov_biu #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         biu_wfx_ready_i,
  input         gov_wfx_drain_req_i,
  input         gov_mbist_req_i);


  wire         biu_wfx_ready = biu_wfx_ready_i;
  wire         gov_wfx_drain_req = gov_wfx_drain_req_i;
  wire         gov_mbist_req = gov_mbist_req_i;





  // Governor requests a WFx so the BIU should be drained
  //  output gov_wfx_drain_req valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_wfx_drain_req X or Z")
  u_ovl_intf_x_gov_wfx_drain_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_wfx_drain_req));


  // Indicates that the BIU has no outstanding write requests, linefills,
  // or evictions in progress and thus is ready to enter WFx state.
  // This may be asserted at any time, even if the governor has not
  // requested a WFx.
  //  input biu_wfx_ready valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_wfx_ready X or Z")
  u_ovl_intf_x_biu_wfx_ready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_wfx_ready));


  // The global mbist request arrives from the governor
  //  output gov_mbist_req valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_mbist_req X or Z")
  u_ovl_intf_x_gov_mbist_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_mbist_req));



endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_gov_biu_defs.v"
`undef CA53_UNDEFINE

`endif

