//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2014 ARM Limited.
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
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Denormalisation shift module for FP ALU pipeline
//-----------------------------------------------------------------------------
//
// Overview
// --------
//

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_fp_alu_denorm (
  input  wire [106:1] fp_a_frac_f2_i,
  input  wire [107:1] fp_b_frac_f2_i,
  input  wire   [1:0] fp_a_zero_f2_i,
  input  wire   [1:0] fp_b_zero_f2_i,
  input  wire   [1:0] raw_gtexp_f2_i,
  input  wire  [10:0] fp_a_exp_0_f2_i,
  input  wire  [10:0] fp_a_exp_1_f2_i,
  input  wire  [11:0] fp_b_exp_0_f2_i,
  input  wire  [11:0] fp_b_exp_1_f2_i,
  input  wire         dual_op_i,
  output wire [106:0] result_o
);

  // -------------------------------
  // Reg declarations
  // -------------------------------

  reg   [106:1] stage1_a;
  reg   [106:1] stage1_b;
  reg   [106:1] stage2;
  reg   [106:1] stage3;
  reg   [106:1] stage4;

  // -------------------------------
  // Wire declarations
  // -------------------------------

  wire    [6:0] exp_diff_0_ab;
  wire    [6:0] exp_diff_0_ba;
  wire    [6:0] exp_diff_1_ab;
  wire    [6:0] exp_diff_1_ba;
  wire    [6:0] shift_hi;
  wire    [6:0] shift_lo;
  wire    [5:0] opa_ctz_hi;
  wire    [6:0] opa_ctz_lo;
  wire    [5:0] opb_ctz_hi;
  wire    [6:0] opb_ctz_lo;
  wire  [105:0] rev_opa_f2;
  wire  [105:0] rev_opb_f2;
  wire          sticky_lo;
  wire          sticky_hi;
  wire          sticky_wide;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  function [6:0] exp_sub;
    // Performs the (expa - expb) -(expb == 0) or
    // (expb - expa) - (expa == 0 and expb != 0)
    // If the difference is greater than 127, saturates to
    // a number in the range 112-127 (partial saturation is
    // sufficient for correct results and improves timing)
    input [11:0] opa;
    input [11:0] opb;

    reg  [11:8]  carry_high;
    reg   [7:0]  sub_res_low;
    reg  [11:7]  sub_res_high;
    reg          zero_res;

    begin
      sub_res_low   = {1'b0, opa[6:0]} + {1'b0, ~opb[6:0]} + 1'b1;
      sub_res_high  = opa[11:7] ^ (~opb[11:7]);
      carry_high    = opa[10:7] | (~opb[10:7]);
      zero_res      = sub_res_high == {carry_high, sub_res_low[7]};
      exp_sub       = sub_res_low[6:0] | { {3{~zero_res}}, {4{1'b0}} };
    end
  endfunction

  // Compute the shift amount for the alignment of the operands
  assign exp_diff_0_ab = exp_sub ({1'b0, fp_a_exp_0_f2_i}, fp_b_exp_0_f2_i);
  assign exp_diff_0_ba = exp_sub (fp_b_exp_0_f2_i, {1'b0, fp_a_exp_0_f2_i});

  assign exp_diff_1_ab = exp_sub ({1'b0, fp_a_exp_1_f2_i}, fp_b_exp_1_f2_i);
  assign exp_diff_1_ba = exp_sub (fp_b_exp_1_f2_i, {1'b0, fp_a_exp_1_f2_i});

  assign shift_hi  = raw_gtexp_f2_i[0] ? exp_diff_0_ab : exp_diff_0_ba;
  assign shift_lo  = raw_gtexp_f2_i[1] ? exp_diff_1_ab : exp_diff_1_ba;

  // -------------------------------
  // Perform split shift
  // -------------------------------

  // First stage - split between operands A and B to improve timing
  always @*
    case (exp_diff_0_ab[1:0])
      2'b00:   stage1_b[106:54] =              fp_b_frac_f2_i[106:54];
      2'b01:   stage1_b[106:54] = { {1{1'b0}}, fp_b_frac_f2_i[106:55]};
      2'b10:   stage1_b[106:54] = { {2{1'b0}}, fp_b_frac_f2_i[106:56]};
      2'b11:   stage1_b[106:54] = { {3{1'b0}}, fp_b_frac_f2_i[106:57]};
      default: stage1_b[106:54] = {53{1'bx}};
    endcase

  always @*
    case (exp_diff_0_ba[1:0])
      2'b00:   stage1_a[106:54] =              fp_a_frac_f2_i[106:54];
      2'b01:   stage1_a[106:54] = { {1{1'b0}}, fp_a_frac_f2_i[106:55]};
      2'b10:   stage1_a[106:54] = { {2{1'b0}}, fp_a_frac_f2_i[106:56]};
      2'b11:   stage1_a[106:54] = { {3{1'b0}}, fp_a_frac_f2_i[106:57]};
      default: stage1_a[106:54] = {53{1'bx}};
    endcase

  always @*
    case (exp_diff_1_ab[1:0])
      2'b00:   stage1_b[ 53: 1] =                                              fp_b_frac_f2_i[ 53: 1];
      2'b01:   stage1_b[ 53: 1] = { {1{~dual_op_i}} & fp_b_frac_f2_i[     54], fp_b_frac_f2_i[ 53: 2]};
      2'b10:   stage1_b[ 53: 1] = { {2{~dual_op_i}} & fp_b_frac_f2_i[ 55: 54], fp_b_frac_f2_i[ 53: 3]};
      2'b11:   stage1_b[ 53: 1] = { {3{~dual_op_i}} & fp_b_frac_f2_i[ 56: 54], fp_b_frac_f2_i[ 53: 4]};
      default: stage1_b[ 53: 1] = {53{1'bx}};
    endcase

  always @*
    case (exp_diff_1_ba[1:0])
      2'b00:   stage1_a[ 53: 1] =                                              fp_a_frac_f2_i[ 53: 1];
      2'b01:   stage1_a[ 53: 1] = { {1{~dual_op_i}} & fp_a_frac_f2_i[     54], fp_a_frac_f2_i[ 53: 2]};
      2'b10:   stage1_a[ 53: 1] = { {2{~dual_op_i}} & fp_a_frac_f2_i[ 55: 54], fp_a_frac_f2_i[ 53: 3]};
      2'b11:   stage1_a[ 53: 1] = { {3{~dual_op_i}} & fp_a_frac_f2_i[ 56: 54], fp_a_frac_f2_i[ 53: 4]};
      default: stage1_a[ 53: 1] = {53{1'bx}};
    endcase

  // Second stage - paths merge
  always @*
    case ({raw_gtexp_f2_i[0], shift_hi[2]})
      2'b00:   stage2[106:54] =              stage1_a[106:54];
      2'b01:   stage2[106:54] = { {4{1'b0}}, stage1_a[106:58]};
      2'b10:   stage2[106:54] =              stage1_b[106:54];
      2'b11:   stage2[106:54] = { {4{1'b0}}, stage1_b[106:58]};
      default: stage2[106:54] = {53{1'bx}};
    endcase

  always @*
    case ({raw_gtexp_f2_i[1], shift_lo[2]})
      2'b00:   stage2[ 53: 1] =                                         stage1_a[ 53: 1];
      2'b01:   stage2[ 53: 1] = { { 4{~dual_op_i}} & stage1_a[ 57: 54], stage1_a[ 53: 5]};
      2'b10:   stage2[ 53: 1] =                                         stage1_b[ 53: 1];
      2'b11:   stage2[ 53: 1] = { { 4{~dual_op_i}} & stage1_b[ 57: 54], stage1_b[ 53: 5]};
      default: stage2[ 53: 1] = {53{1'bx}};
    endcase

  // Third stage
  always @*
    case (shift_hi[4:3])
      2'b00:   stage3[106:54] =               stage2[106:54];
      2'b01:   stage3[106:54] = { { 8{1'b0}}, stage2[106:62]};
      2'b10:   stage3[106:54] = { {16{1'b0}}, stage2[106:70]};
      2'b11:   stage3[106:54] = { {24{1'b0}}, stage2[106:78]};
      default: stage3[106:54] = {53{1'bx}};
    endcase

  always @*
    case (shift_lo[4:3])
      2'b00:   stage3[ 53: 1] =                                       stage2[ 53: 1];
      2'b01:   stage3[ 53: 1] = { { 8{~dual_op_i}} & stage2[ 61: 54], stage2[ 53: 9]};
      2'b10:   stage3[ 53: 1] = { {16{~dual_op_i}} & stage2[ 69: 54], stage2[ 53:17]};
      2'b11:   stage3[ 53: 1] = { {24{~dual_op_i}} & stage2[ 77: 54], stage2[ 53:25]};
      default: stage3[ 53: 1] = {53{1'bx}};
    endcase

  // Fourth stage
  always @*
    case (shift_hi[6:5])
      2'b00:   stage4[106:54] =               stage3[106: 54];
      2'b01:   stage4[106:54] = { {32{1'b0}}, stage3[106: 86]};
      2'b10:   stage4[106:54] = {53{1'b0}};
      2'b11:   stage4[106:54] = {53{1'b0}};
      default: stage4[106:54] = {53{1'bx}};
    endcase

  always @*
    case (shift_lo[6:5])
      2'b00:   stage4[ 53: 1] =                                                    stage3[ 53:  1];
      2'b01:   stage4[ 53: 1] = {             { 32{~dual_op_i}} & stage3[ 85: 54], stage3[ 53: 33]};
      2'b10:   stage4[ 53: 1] = { {11{1'b0}}, { 42{~dual_op_i}} & stage3[106: 65]                 };
      2'b11:   stage4[ 53: 1] = { {43{1'b0}}, { 10{~dual_op_i}} & stage3[106: 97]                 };
      default: stage4[ 53: 1] = {53{1'bx}};
    endcase
  
  // -------------------------------
  // Calculate sticky bits
  // -------------------------------

  genvar i;
  generate for (i = 0; i < 106; i = i + 1) begin : g_rev_opa
    assign rev_opa_f2[i] = fp_a_frac_f2_i[106-i];
  end endgenerate

  generate for (i = 0; i < 106; i = i + 1) begin : g_rev_opb
    assign rev_opb_f2[i] = fp_b_frac_f2_i[106-i];
  end endgenerate

  ca53dpu_fp_clz106 u_opa_ctz_lo (
    .opa (rev_opa_f2),
    .res (opa_ctz_lo)
  );

  ca53dpu_fp_clz106 u_opb_ctz_lo (
    .opa (rev_opb_f2),
    .res (opb_ctz_lo)
  );

  ca53dpu_fp_clz54 u_opa_ctz_hi (
    .opa ({rev_opa_f2[52:0], 1'b0}),
    .res (opa_ctz_hi)
  );

  ca53dpu_fp_clz54 u_opb_ctz_hi (
    .opa ({rev_opb_f2[52:0], 1'b0}),
    .res (opb_ctz_hi)
  );

  assign sticky_lo   = raw_gtexp_f2_i[1] ? ((       opb_ctz_lo  < shift_lo) & ~fp_b_zero_f2_i[1])
                                         : ((       opa_ctz_lo  < shift_lo) & ~fp_a_zero_f2_i[1]);

  assign sticky_hi   = raw_gtexp_f2_i[0] ? (({1'b0, opb_ctz_hi} < shift_hi) & ~fp_b_zero_f2_i[0])
                                         : (({1'b0, opa_ctz_hi} < shift_hi) & ~fp_a_zero_f2_i[0]);

  assign sticky_wide = raw_gtexp_f2_i[0] ? ((       opb_ctz_lo  < shift_hi) & ~fp_b_zero_f2_i[0])
                                         : ((       opa_ctz_lo  < shift_hi) & ~fp_a_zero_f2_i[0]);

  assign result_o = {stage4[106:55], stage4[54] | (dual_op_i & sticky_hi), stage4[53:1], (dual_op_i ? sticky_lo : sticky_wide)};

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/

