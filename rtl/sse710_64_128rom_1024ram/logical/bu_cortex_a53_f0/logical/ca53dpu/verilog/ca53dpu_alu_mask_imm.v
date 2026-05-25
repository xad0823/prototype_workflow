//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2012-04-24 13:34:35 +0100 (Tue, 24 Apr 2012) $
//
//      Revision            : $Revision: 207743 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract: AA64 logical immediate generator
// ----------------------------------------------------------------------------
//
// Overview
// ========
// This block generates the immediate for AArch64 Logical instructions (see the
// ARM ARM psuedocode for details on the algorithm)
//
//----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_alu_mask_imm (
  // Inputs
  input  wire         n_i,
  input  wire   [5:0] imms_i,
  input  wire   [5:0] immr_i,
  // Outputs
  output wire  [63:0] log_imm_o
);

  reg  [ 5:0] levels;
  wire [ 5:0] s;
  wire [ 5:0] r;
  wire [ 6:0] s_r_diff;
  wire [ 5:0] tmask_and;
  wire [ 5:0] tmask_or;
  wire [63:0] t_and0;
  wire [63:0] t_and1;
  wire [63:0] t_and2;
  wire [63:0] t_and3;
  wire [63:0] t_and4;
  wire [63:0] t_and5;
  wire [63:0] t_or1;
  wire [63:0] t_or2;
  wire [63:0] t_or3;
  wire [63:0] t_or4;
  wire [63:0] t_or5;
  wire [63:0] tmask0;
  wire [63:0] tmask1;
  wire [63:0] tmask2;
  wire [63:0] tmask3;
  wire [63:0] tmask4;
  wire [63:0] tmask5;
  wire [ 5:0] wmask_and;
  wire [ 5:0] wmask_or;
  wire [63:0] w_and1;
  wire [63:0] w_and2;
  wire [63:0] w_and3;
  wire [63:0] w_and4;
  wire [63:0] w_and5;
  wire [63:0] w_or0;
  wire [63:0] w_or1;
  wire [63:0] w_or2;
  wire [63:0] w_or3;
  wire [63:0] w_or4;
  wire [63:0] w_or5;
  wire [63:0] wmask0;
  wire [63:0] wmask1;
  wire [63:0] wmask2;
  wire [63:0] wmask3;
  wire [63:0] wmask4;
  wire [63:0] wmask5;

  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  always @*
    case ({n_i, ~imms_i})
      `ca53dpu_sel_1xx_xxxx: levels = 6'b111111;
      `ca53dpu_sel_01x_xxxx: levels = 6'b011111;
      `ca53dpu_sel_001_xxxx: levels = 6'b001111;
      `ca53dpu_sel_000_1xxx: levels = 6'b000111;
      `ca53dpu_sel_000_01xx: levels = 6'b000011;
      `ca53dpu_sel_000_001x: levels = 6'b000001;
                7'b000_0001: levels = 6'b000000;
                7'b000_0000: levels = 6'b000000;
      default              : levels = 6'bxxxxxx;
    endcase

  assign s        = imms_i & levels;
  assign r        = immr_i & levels;
  assign s_r_diff = s - r;

  // Compute "top mask"
  assign tmask_and = s_r_diff[5:0] | ~levels[5:0];
  assign tmask_or  = s_r_diff[5:0] &  levels[5:0];

  assign t_and0 = {32{ {     tmask_and[0]  ,            1'b1   } }};
  assign t_and1 = {16{ { { 2{tmask_and[1]}}, { 2{       1'b1}} } }};
  assign t_and2 = { 8{ { { 4{tmask_and[2]}}, { 4{       1'b1}} } }};
  assign t_and3 = { 4{ { { 8{tmask_and[3]}}, { 8{       1'b1}} } }};
  assign t_and4 = { 2{ { {16{tmask_and[4]}}, {16{       1'b1}} } }};
  assign t_and5 =      { {32{tmask_and[5]}}, {32{       1'b1}} };

  assign t_or1  = {16{ { { 2{        1'b0}}, { 2{tmask_or[1]}} } }};
  assign t_or2  = { 8{ { { 4{        1'b0}}, { 4{tmask_or[2]}} } }};
  assign t_or3  = { 4{ { { 8{        1'b0}}, { 8{tmask_or[3]}} } }};
  assign t_or4  = { 2{ { {16{        1'b0}}, {16{tmask_or[4]}} } }};
  assign t_or5  =      { {32{        1'b0}}, {32{tmask_or[5]}} };

  assign tmask0 = (          t_and0          );
  assign tmask1 = ((tmask0 & t_and1) |  t_or1);
  assign tmask2 = ((tmask1 & t_and2) |  t_or2);
  assign tmask3 = ((tmask2 & t_and3) |  t_or3);
  assign tmask4 = ((tmask3 & t_and4) |  t_or4);
  assign tmask5 = ((tmask4 & t_and5) |  t_or5);

  // Compute "wraparound mask"
  assign wmask_and = immr_i[5:0] | ~levels[5:0];
  assign wmask_or  = immr_i[5:0] &  levels[5:0];

  assign w_and1 = {16{ { { 2{       1'b1}}, { 2{wmask_and[1]}} } }};
  assign w_and2 = { 8{ { { 4{       1'b1}}, { 4{wmask_and[2]}} } }};
  assign w_and3 = { 4{ { { 8{       1'b1}}, { 8{wmask_and[3]}} } }};
  assign w_and4 = { 2{ { {16{       1'b1}}, {16{wmask_and[4]}} } }};
  assign w_and5 =      { {32{       1'b1}}, {32{wmask_and[5]}} };

  assign w_or0  = {32{ {     wmask_or[0]  ,             1'b0   } }};
  assign w_or1  = {16{ { { 2{wmask_or[1]}}, { 2{        1'b0}} } }};
  assign w_or2  = { 8{ { { 4{wmask_or[2]}}, { 4{        1'b0}} } }};
  assign w_or3  = { 4{ { { 8{wmask_or[3]}}, { 8{        1'b0}} } }};
  assign w_or4  = { 2{ { {16{wmask_or[4]}}, {16{        1'b0}} } }};
  assign w_or5  =      { {32{wmask_or[5]}}, {32{        1'b0}} };

  assign wmask0 = (                    w_or0);
  assign wmask1 = ((wmask0 & w_and1) | w_or1);
  assign wmask2 = ((wmask1 & w_and2) | w_or2);
  assign wmask3 = ((wmask2 & w_and3) | w_or3);
  assign wmask4 = ((wmask3 & w_and4) | w_or4);
  assign wmask5 = ((wmask4 & w_and5) | w_or5);

  // Final immediate
  assign log_imm_o = (s_r_diff[6] ? (wmask5 & tmask5)
                                  : (wmask5 | tmask5));

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
