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

// This is the specification for the interface between the STB and DPU.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_stb_dpu_defs.v"
`include "cortexa53params.v"

module ca53_stb_dpu #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         dpu_store_iss_i,
  input         dpu_kill_wr_i,
  input [127:0] dpu_st_data_wr_i,
  input         dpu_disable_dmb_i,
  input         stb_evnt_stb_stall_i);


  wire         dpu_store_iss = dpu_store_iss_i;
  wire         dpu_kill_wr = dpu_kill_wr_i;
  wire [127:0] dpu_st_data_wr = dpu_st_data_wr_i;
  wire         dpu_disable_dmb = dpu_disable_dmb_i;
  wire         stb_evnt_stb_stall = stb_evnt_stb_stall_i;


  reg         initialization_done;

  reg         initialization_done_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    initialization_done_reg <= 1'b0;
  end
  else
  begin
    initialization_done_reg <= initialization_done;
  end



  // Event signal for a merge in the store buffer.
  //  output stb_evnt_stb_stall valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "stb_evnt_stb_stall X or Z")
  u_ovl_intf_x_stb_evnt_stb_stall (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_evnt_stb_stall));


  // A hint to the STB that there is a store in issue, to help decide when to
  // drain STB slots. Does not have to be 100% accurate.
  //  input dpu_store_iss valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dpu_store_iss X or Z")
  u_ovl_intf_x_dpu_store_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_store_iss));


  // The DPU is killing the instruction in wr. If this is asserted then the STB
  // must ignore any dcu_stb_req_dc3.
  //  input dpu_kill_wr valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dpu_kill_wr X or Z")
  u_ovl_intf_x_dpu_kill_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_kill_wr));


  // The DPU provides store data directly to the STB, rather than via the DCU, to help timing.

  // Any DPU outputs initialized by the reset FSM rather than by reset itself
  // will not be valid for the 1st two cycles after reset has been deasserted

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    initialization_done <= 1'b0;
  else
    initialization_done <= 1'b1;


  // When asserted, the DCU transforms DMBs into DSBs. The STB disables optimised
  // barrier behaviour so that every DSB propagates to the BIU.
  //  input dpu_disable_dmb valid initialization_done@1 timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dpu_disable_dmb X or Z")
  u_ovl_intf_x_dpu_disable_dmb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (initialization_done_reg),
    .test_expr (dpu_disable_dmb));



endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_stb_dpu_defs.v"
`undef CA53_UNDEFINE

`endif

