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
// Abstract : Floating point div/sqrt
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Performs IEEE divide and sqrt with all rounding modes.
// Supports AdvSIMD divide/sqrt performing 2 single precision ops in parallel.
// Three bits of the result fraction generated per cycle.
//

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_fp_div (
  input  wire         clk_fp_mul,
  input  wire         reset_n,
  input  wire         stall_wr_i,
  input  wire         advance_pipeline_i,
  input  wire         start_div_f2_i,
  input  wire         sqrt_f2_i,
  input  wire         double_prec_f2_i,
  input  wire   [1:0] round_mode_f2_i,
  input  wire         res0_zero_f2_i,
  input  wire         res0_infinite_f2_i,
  input  wire         res0_nan_f2_i,
  input  wire         invalid0_f2_i,
  input  wire         divbyzero_op0_f2_i,
  input  wire         in_flushzero_f2_i,
  input  wire         out0_sign_f2_i,
  input  wire  [10:0] a0_exp_f2_i,
  input  wire  [10:0] b0_exp_f2_i,
  input  wire  [52:0] a_mant_f2_i,
  input  wire  [52:0] b_mant_f2_i,
  input  wire   [5:0] a0_mant_lz_f2_i,
  input  wire   [5:0] b0_mant_lz_f2_i,
  input  wire         nan_sel_a0_f2_i,
  input  wire         nan_sel_b0_f2_i,
  input  wire         res1_zero_f2_i,
  input  wire         res1_infinite_f2_i,
  input  wire         res1_nan_f2_i,
  input  wire         invalid1_f2_i,
  input  wire         divbyzero_op1_f2_i,
  input  wire         out1_sign_f2_i,
  input  wire   [7:0] a1_exp_f2_i,
  input  wire   [7:0] b1_exp_f2_i,
  input  wire   [4:0] a1_mant_lz_f2_i,
  input  wire   [4:0] b1_mant_lz_f2_i,
  input  wire         nan_sel_a1_f2_i,
  input  wire         nan_sel_b1_f2_i,
  input  wire         ctl_dual_fp_f2_i,

  output wire         out0_sign_f3_o,
  output wire  [12:0] out0_exp_f3_o,
  output wire  [54:0] out0_frac_f3_o,
  output wire         stickybit0_f3_o,
  output wire   [6:0] shift0_f3_o,
  output wire         double_prec_f3_o,
  output wire   [1:0] round_mode_f3_o,
  output wire         res0_infinite_f3_o,
  output wire         res0_zero_f3_o,
  output wire         res0_nan_f3_o,
  output wire         invalid0_f3_o,
  output wire         divbyzero0_f3_o,
  output wire         in_flushzero_f3_o,
  output wire         div_fp_busy_nxt_cyc_o,
  output wire         stickybit1_f3_o,
  output wire   [5:0] shift1_f3_o,
  output wire   [9:0] out1_exp_f3_o,
  output wire  [26:0] out1_frac_f3_o,
  output wire         out1_sign_f3_o,
  output wire         res1_infinite_f3_o,
  output wire         res1_zero_f3_o,
  output wire         res1_nan_f3_o,
  output wire         invalid1_f3_o,
  output wire         divbyzero1_f3_o,
  output wire         ctl_dual_fp_f3_o
);
  // -------------------------------
  // Genvar declaration
  // -------------------------------

  genvar i;

  // -------------------------------
  // Reg declarations
  // -------------------------------

  reg         divbyzero_op0_f3;
  reg         double_prec_f3;
  reg         in_flushzero_f3;
  reg         invalid0_f3;
  reg         out0_sign_f3;
  reg         res0_infinite_f3;
  reg         res0_nan_f3;
  reg         res0_zero_f3;
  reg         sqrt_f3;
  reg         start_div_f3;
  reg   [1:0] round_mode_f3;
  reg   [5:0] div_fsm_f3;
  reg   [5:0] a0_mant_lz_f3;
  reg   [5:0] b0_mant_lz_f3;
  reg  [12:0] quot0_exp_f3;
  reg   [9:0] quot1_exp_f3;
  reg         ctl_dual_fp_f3;
  reg         res1_zero_f3;
  reg         res1_infinite_f3;
  reg         res1_nan_f3;
  reg         invalid1_f3;
  reg         divbyzero_op1_f3;
  reg         out1_sign_f3;
  reg   [4:0] a1_mant_lz_f3;
  reg   [4:0] b1_mant_lz_f3;
  reg  [17:0] nxt_raw_mask_f3;
  reg  [17:0] raw_mask_f3;
  reg  [52:0] divisor_f3;
  reg  [56:0] nxt_rem_carry_f3;
  reg  [56:0] rem_carry_f3;
  reg  [54:0] nxt_quot_f3;
  reg  [54:0] nxt_quot_m1_f3;
  reg  [54:0] quot_f3;
  reg  [54:0] quot_m1_f3;
  reg  [56:0] nxt_rem_sum_f3;
  reg  [56:0] rem_sum_f3;
  reg         renorm_a0;
  reg         renorm_b0_reg;
  reg         renorm_a1;
  reg         renorm_b1_reg;
  reg   [5:0] ctz_counter0;
  reg   [5:0] ctz_m1_counter0;
  reg   [4:0] ctz_counter1;
  reg   [4:0] ctz_m1_counter1;

  // -------------------------------
  // Wire declarations
  // -------------------------------

  wire [12:0] a0_exp_adj_f3;
  wire [11:0] a0_exp_unbiased_f2;
  wire [12:0] a0_exp_unbiased_f2_se;
  wire  [9:0] a1_exp_adj_f3;
  wire  [8:0] a1_exp_unbiased_f2;
  wire  [9:0] a1_exp_unbiased_f2_se;
  wire [52:0] a_mant_in;
  wire [52:0] b_mant_in;
  wire [52:0] a0_mant_aligned;
  wire [52:0] b0_mant_aligned;
  wire [23:0] a1_mant_aligned;
  wire [23:0] b1_mant_aligned;
  wire [52:0] a0_mant_norm;
  wire [52:0] b0_mant_norm;
  wire [23:0] a1_mant_norm;
  wire [23:0] b1_mant_norm;
  wire [10:0] bias;
  wire        div_reg_wr_en;
  wire        enable_f3;
  wire  [5:0] fsm_start_val;
  wire [54:0] msk_dig_3          [2:0];
  wire [55:0] msk_dig            [2:0];
  wire [55:0] mask_f3            [2:0];
  wire [54:0] nan_frac;
  wire        div_fp_busy_nxt_cyc;
  wire  [5:0] nxt_div_fsm_f3;
  wire [52:0] nxt_divisor_f3;
  wire        quot_exp_en;
  wire [12:0] nxt_quot0_exp_f3;
  wire  [9:0] nxt_quot1_exp_f3;
  wire [54:0] new_quot0_f3       [2:0];
  wire [54:0] new_quot0_m1_f3    [2:0];
  wire [26:0] new_quot1_f3       [2:0];
  wire [26:0] new_quot1_m1_f3    [2:0];
  wire        new_quot_m1_sel0   [2:0];
  wire        new_quot_sel0      [2:0];
  wire        new_quot_dig0      [2:0];
  wire        new_quot_m1_dig0   [2:0];
  wire        new_quot_m1_sel1   [2:0];
  wire        new_quot_sel1      [2:0];
  wire        new_quot_dig1      [2:0];
  wire        new_quot_m1_dig1   [2:0];
  wire [56:0] new_rem_carry_f3   [2:0];
  wire [56:0] new_rem_sum_f3     [2:0];
  wire [50:0] rem_sum_xor        [2:0];
  wire [51:0] rem_carry_andor    [2:0];
  wire        nxt_sqrt_f3;
  wire        nxt_ctl_dual_fp_f3;
  wire        nxt_double_prec_f3;
  wire        nxt_start_div_f3;
  wire  [1:0] quot_dig0          [2:0];
  wire  [1:0] quot_dig1          [2:0];
  wire  [1:0] quot_dig0_zero     [1:0];
  wire  [1:0] quot_dig0_plus     [1:0];
  wire  [1:0] quot_dig0_minus    [1:0];
  wire  [1:0] quot_dig1_zero     [1:0];
  wire  [1:0] quot_dig1_plus     [1:0];
  wire  [1:0] quot_dig1_minus    [1:0];
  wire [54:0] quot_out0;
  wire [26:0] quot_out1;
  wire        rem0_neg;
  wire        rem0_nonzero;
  wire        rem1_neg;
  wire        rem1_nonzero;
  wire        remhi_nonzero;
  wire        rem0_eq_div;
  wire        rem1_eq_div;
  wire        remhi_eq_div;
  wire        remmi_eq_div;
  wire        renorm_b0;
  wire        renorm_b1;
  wire  [5:0] renorm_shift0_amount;
  wire [52:0] renorm_shift0_in;
  wire [52:0] renorm_shift0_out;
  wire  [4:0] renorm_shift1_amount;
  wire [23:0] renorm_shift1_in;
  wire [23:0] renorm_shift1_out;
  wire        nxt_renorm_a0;
  wire        nxt_renorm_b0;
  wire        nxt_renorm_a1;
  wire        nxt_renorm_b1;
  wire  [6:0] shift0_f3;
  wire  [5:0] shift1_f3;
  wire [54:0] csa_plus_val_sqrt0  [2:0];
  wire [24:0] csa_plus_val_sqrt1  [2:0];
  wire [54:0] csa_val_div;
  wire [54:0] csa_minus_val_sqrt0 [2:0];
  wire [24:0] csa_minus_val_sqrt1 [2:0];
  wire [54:0] csa_plus_val0       [2:0];
  wire [54:0] csa_minus_val0      [2:0];
  wire [28:0] csa_plus_val1       [2:0];
  wire [28:0] csa_minus_val1      [2:0];
  wire [50:0] csa_val0            [2:0];
  wire [28:0] csa_val1            [2:0];
  wire [50:0] csa_mux             [2:0];
  wire [56:0] new_rem_sum0        [2:0];
  wire [26:0] new_rem_sum1        [2:0];
  wire [56:0] new_rem_carry0      [2:0];
  wire [26:0] new_rem_carry1      [2:0];
  wire  [5:0] rem_sum_msb0        [2:0];
  wire  [5:0] rem_sum_msb1        [2:0];
  wire  [5:0] rem_carry_msb0      [2:0];
  wire  [5:0] rem_carry_msb1      [2:0];
  wire  [5:0] rem0_sum_zero       [2:0];
  wire  [5:0] rem0_carry_zero     [2:0];
  wire  [5:0] rem0_sum_minus      [2:0];
  wire  [5:0] rem0_carry_minus    [2:0];
  wire  [5:0] rem0_sum_plus       [2:0];
  wire  [5:0] rem0_carry_plus     [2:0];
  wire  [5:0] rem1_sum_zero       [2:0];
  wire  [5:0] rem1_carry_zero     [2:0];
  wire  [5:0] rem1_sum_minus      [2:0];
  wire  [5:0] rem1_carry_minus    [2:0];
  wire  [5:0] rem1_sum_plus       [2:0];
  wire  [5:0] rem1_carry_plus     [2:0];
  wire [56:0] div_sh;
  wire [56:0] rem_sum_plus_d_no_sh;
  wire [56:0] rem_carry_plus_d_no_sh;
  wire [56:0] rem_plus_d_no_sh_xor;
  wire [56:1] rem_plus_d_no_sh_or;
  wire [56:0] init_rem_sum_sqrt;
  wire [56:0] init_rem_sum_sqrt_simd;
  wire [56:0] init_rem_sum_div;
  wire [56:0] init_rem_sum_div_simd;
  wire [56:0] init_rem_carry_div;
  wire [56:0] init_rem_carry_div_simd;
  wire  [5:0] nxt_ctz_counter0;
  wire  [5:0] nxt_ctz_m1_counter0;
  wire  [5:0] ctz_counter0_p1    [2:0];
  wire  [5:0] ctz_m1_counter0_p1 [2:0];
  wire  [5:0] quot0_out_ctz;
  wire  [4:0] nxt_ctz_counter1;
  wire  [4:0] nxt_ctz_m1_counter1;
  wire  [4:0] ctz_counter1_p1    [2:0];
  wire  [4:0] ctz_m1_counter1_p1 [2:0];
  wire  [5:0] nxt_ctz_count0     [2:0];
  wire  [5:0] nxt_ctz_m1_count0  [2:0];
  wire  [4:0] nxt_ctz_count1     [2:0];
  wire  [4:0] nxt_ctz_m1_count1  [2:0];
  wire  [4:0] quot1_out_ctz;
  wire        sticky0_shift_gt_tz;
  wire        sticky1_shift_gt_tz;
  wire [54:0] prev_quot          [2:0];
  wire [54:0] prev_quot_m1       [2:0];
  wire [55:0] rem_sum_in         [2:0];
  wire [55:0] rem_carry_in       [2:0];
  wire [57:0] cpa_res;
  wire        start_div_f3_en;
  wire        advance_f2_f3;
  wire        advance_f2_f3_dual;
  wire        quot_exp_en_dual;
  wire        divisor_f3_en;
  wire        iteration_upper_en;
  wire        iteration_lower_en;
  wire        raw_mask_f3_en;
  wire        ctz_en;
  wire        ctz_en_dual;

  // --- F2 stage ---
  // -----------------------------------------------------------------------
  // Calculate exponent result
  // -----------------------------------------------------------------------
  assign bias = double_prec_f2_i ? 11'h3ff
                                 : 11'h07f;

  // Calculate the exponent without leading zeros (LZ) value in F2 - and
  // introduce LZ values in F3. This Breaks long timing path through
  // count leading zeros (CLZ) and calculation in F2.
  assign a0_exp_unbiased_f2 = {1'b0, a0_exp_f2_i} + bias;

  assign a0_exp_unbiased_f2_se = {1'b0,a0_exp_unbiased_f2};

  assign a0_exp_adj_f3      = quot0_exp_f3 - a0_mant_lz_f3;

  assign nxt_quot0_exp_f3 = start_div_f2_i ? (sqrt_f2_i ? a0_exp_unbiased_f2_se
                                              : (a0_exp_unbiased_f2_se - b0_exp_f2_i))
                             : (sqrt_f3 ? ({1'b0, a0_exp_adj_f3[12:1]} - 1'b1)
                                 : (a0_exp_adj_f3 + b0_mant_lz_f3 - 1'b1));

  // Also calculate exponent for second SIMD op
  // Note: Only needs to be Single Precision. Therefore narrower.
  assign a1_exp_unbiased_f2 = {1'b0, a1_exp_f2_i} + 9'h07f;

  assign a1_exp_unbiased_f2_se = {1'b0,a1_exp_unbiased_f2};

  assign a1_exp_adj_f3      = quot1_exp_f3 - a1_mant_lz_f3;

  assign nxt_quot1_exp_f3 = start_div_f2_i ? (sqrt_f2_i ? a1_exp_unbiased_f2_se
                                              : (a1_exp_unbiased_f2_se - b1_exp_f2_i))
                             : (sqrt_f3 ? ({1'b0, a1_exp_adj_f3[9:1]} - 1'b1)
                                 : (a1_exp_adj_f3 + b1_mant_lz_f3 - 1'b1));

  // SRT iterations begin on last cycle start_div_f3 is asserted
  // - check for stall/flush and renorm of mantissae
  // stall/flush inhibits calculation.
  // renorm will delay start of calculation.
  assign nxt_start_div_f3 = (start_div_f2_i & advance_pipeline_i) | renorm_b0_reg | renorm_a0 | renorm_b1_reg | renorm_a1;

  assign start_div_f3_en = start_div_f2_i | start_div_f3;
  always @(posedge clk_fp_mul or negedge reset_n)
    if (~reset_n) begin
      start_div_f3  <= 1'b0;
      renorm_a0     <= 1'b0;
      renorm_b0_reg <= 1'b0;
      renorm_a1     <= 1'b0;
      renorm_b1_reg <= 1'b0;
    end else if (start_div_f3_en) begin
      start_div_f3 <= nxt_start_div_f3;
      renorm_a0 <= nxt_renorm_a0;
      renorm_b0_reg <= nxt_renorm_b0;
      renorm_a1 <= nxt_renorm_a1;
      renorm_b1_reg <= nxt_renorm_b1;
    end

  // Load static register values
  assign advance_f2_f3 = start_div_f2_i & advance_pipeline_i;
  always @(posedge clk_fp_mul)
    if (advance_f2_f3) begin
      sqrt_f3            <= sqrt_f2_i;
      double_prec_f3     <= nxt_double_prec_f3;
      round_mode_f3      <= round_mode_f2_i;
      res0_zero_f3       <= res0_zero_f2_i;
      res0_infinite_f3   <= res0_infinite_f2_i;
      res0_nan_f3        <= res0_nan_f2_i;
      invalid0_f3        <= invalid0_f2_i;
      divbyzero_op0_f3   <= divbyzero_op0_f2_i;
      in_flushzero_f3    <= in_flushzero_f2_i;
      out0_sign_f3       <= out0_sign_f2_i;
      a0_mant_lz_f3      <= a0_mant_lz_f2_i;
      b0_mant_lz_f3      <= b0_mant_lz_f2_i;
      ctl_dual_fp_f3     <= nxt_ctl_dual_fp_f3;
    end

  assign advance_f2_f3_dual = start_div_f2_i & advance_pipeline_i & nxt_ctl_dual_fp_f3;
  always @(posedge clk_fp_mul)
    if (advance_f2_f3_dual) begin
      res1_zero_f3       <= res1_zero_f2_i;
      res1_infinite_f3   <= res1_infinite_f2_i;
      res1_nan_f3        <= res1_nan_f2_i;
      invalid1_f3        <= invalid1_f2_i;
      divbyzero_op1_f3   <= divbyzero_op1_f2_i;
      out1_sign_f3       <= out1_sign_f2_i;
      a1_mant_lz_f3      <= a1_mant_lz_f2_i;
      b1_mant_lz_f3      <= b1_mant_lz_f2_i;
    end

  assign quot_exp_en = start_div_f2_i | (start_div_f3 & ~renorm_a0 & ~renorm_b0_reg & ~renorm_a1 & ~renorm_b1_reg);

  always @(posedge clk_fp_mul)
    if (quot_exp_en)
      quot0_exp_f3 <= nxt_quot0_exp_f3;

  assign quot_exp_en_dual = quot_exp_en & nxt_ctl_dual_fp_f3;
  always @(posedge clk_fp_mul)
    if (quot_exp_en_dual)
      quot1_exp_f3 <= nxt_quot1_exp_f3;

  assign nxt_sqrt_f3 = start_div_f2_i ? sqrt_f2_i : sqrt_f3;
  assign nxt_ctl_dual_fp_f3 = start_div_f2_i ? ctl_dual_fp_f2_i : ctl_dual_fp_f3;
  assign nxt_double_prec_f3 = start_div_f2_i ? double_prec_f2_i : double_prec_f3;

  // -----------------------------------------------------------------------
  // Calculate whether the operands need to be normalized using extra cycles
  // -----------------------------------------------------------------------

  // Renorm will only occur when input mantissae are denormalised (ie. MSB
  // of mant_in is not 1)

  // Because of the rarity of use and large size of shifters, the dividend and
  // divisor share a shifter.
  // Therefore, a_mant must be stored whilst b_mant is renormalised and vice versa
  // and the shift takes a whole cycle, delaying the start of the calculation.

  // If renorm take input mantissa from the register.
  assign a_mant_in = (renorm_a0 | renorm_a1) ? rem_sum_f3[52:0] : a_mant_f2_i;
  assign b_mant_in = (renorm_b0 | renorm_b1) ? divisor_f3 : b_mant_f2_i;

  // align the mantissa dependent on single/double precision.
  assign a0_mant_aligned = nxt_double_prec_f3 ? a_mant_in
                            : {a_mant_in[23:0], {29{1'b0}} };
  assign b0_mant_aligned = nxt_double_prec_f3 ? b_mant_in
                            : {b_mant_in[23:0], {29{1'b0}} };

  // SIMD op always single precision
  assign a1_mant_aligned = a_mant_in[52:29];
  assign b1_mant_aligned = b_mant_in[52:29];

  // renorm_a at start of calculation if MSB of mantissa isn't 1.
  // inhibit renorm when calculation isn't going to be performed (ie. result
  // is zero, NaN or infinite).
  // inhibit when renorm_b is high because renorm_a should have already happened
  // (this is in case a_mant_in is changed for a fp_mul calculation).
  assign nxt_renorm_a0 = start_div_f2_i & advance_pipeline_i & ~res0_zero_f2_i &
     ~res0_infinite_f2_i & ~res0_nan_f2_i & ~a0_mant_norm[52] & ~renorm_b0_reg & ~renorm_b1_reg;

  // Similarly renorm_b when MSB isn't 1 and calculation is to be performed.
  // As renorm_b is inhibited by renorm_a. keep it high when both renorm_a and
  // renorm_b are due to occur.
  assign nxt_renorm_b0 = (start_div_f2_i & ~stall_wr_i & ~sqrt_f2_i & ~res0_zero_f2_i &
    ~res0_infinite_f2_i & ~res0_nan_f2_i & ~b0_mant_norm[52]) | (renorm_b0_reg & (renorm_a0 | renorm_a1));
  // Inhibit renorm_b when renorm_a on either SIMD calculation.
  // This simplifies the register load logic for very small performance hit.
  assign renorm_b0 = renorm_b0_reg & ~renorm_a0 & ~renorm_a1;

  // Shift respective mantissa left by leading zeros value.
  assign renorm_shift0_in = {53{renorm_b0}}  & b0_mant_aligned |
                            {53{renorm_a0}}  & a0_mant_aligned;
  assign renorm_shift0_amount = {6{renorm_b0}} & b0_mant_lz_f3 |
                                {6{renorm_a0}} & a0_mant_lz_f3;

  assign renorm_shift0_out = renorm_shift0_in << renorm_shift0_amount;

  // Repeat renorm logic for SIMD calculation.
  // (Inhibit renorm_a1/b1 when not SIMD operation)
  assign nxt_renorm_a1 = start_div_f2_i & advance_pipeline_i & ~res1_zero_f2_i & ~res1_infinite_f2_i
    & ~res1_nan_f2_i & nxt_ctl_dual_fp_f3 & ~a1_mant_norm[23] & ~renorm_b1_reg & ~renorm_b0_reg;

  assign nxt_renorm_b1 = (start_div_f2_i & ~stall_wr_i & ~sqrt_f2_i & ~res1_zero_f2_i &
    ~res1_infinite_f2_i & ~res1_nan_f2_i & ctl_dual_fp_f2_i & ~b1_mant_norm[23]) | (renorm_b1_reg & (renorm_a0 | renorm_a1));

  assign renorm_b1 = renorm_b1_reg & ~renorm_a1 & ~renorm_a0;

  assign renorm_shift1_in = {24{renorm_b1}}  & b1_mant_aligned |
                            {24{renorm_a1}}  & a1_mant_aligned;
  assign renorm_shift1_amount = {5{renorm_b1}}  & b1_mant_lz_f3 |
                                {5{renorm_a1}}  & a1_mant_lz_f3;

  assign renorm_shift1_out = renorm_shift1_in << renorm_shift1_amount;

  // normalised mantissa output
  assign a0_mant_norm = renorm_a0 ? renorm_shift0_out[52:0] : a0_mant_aligned;
  assign b0_mant_norm = renorm_b0 ? renorm_shift0_out[52:0] : b0_mant_aligned;

  assign a1_mant_norm = renorm_a1 ? renorm_shift1_out[23:0] : a1_mant_aligned;
  assign b1_mant_norm = renorm_b1 ? renorm_shift1_out[23:0] : b1_mant_aligned;

  // -----------------------------------------------------------------------
  // Load initial values in to iteration registers
  // -----------------------------------------------------------------------
  // Assemble NaN (Not a Number) fraction for when result is determined to be NaN.
  assign nan_frac[54:27] = ({28{nan_sel_a0_f2_i}} & {1'b0, a0_mant_aligned[52:26]}) |
                           ({28{nan_sel_b0_f2_i}} & {1'b0, b0_mant_aligned[52:26]}) |
                           ({~res0_nan_f2_i, {2{res0_nan_f2_i}}, {25{1'b0}} });
  assign nan_frac[26:0] =
    ({27{nan_sel_a0_f2_i & ~ctl_dual_fp_f2_i}} & {a0_mant_aligned[25:0],1'b0}) |
    ({27{nan_sel_b0_f2_i & ~ctl_dual_fp_f2_i}} & {b0_mant_aligned[25:0],1'b0}) |
    ({27{nan_sel_a1_f2_i &  ctl_dual_fp_f2_i}} & {1'b0,a1_mant_aligned, 2'b00})  |
    ({27{nan_sel_b1_f2_i &  ctl_dual_fp_f2_i}} & {1'b0,b1_mant_aligned, 2'b00})  |
    {(ctl_dual_fp_f2_i & ~res1_nan_f2_i), {2{(ctl_dual_fp_f2_i & res1_nan_f2_i)}}, {24{1'b0}} };

  // When exp_in is odd and op is SQRT - we shift initial mantissa left one bit.
  //   Because sqrt_exp_result = exp_in/2, we must force exp_in to be even.
  //
  // This is combined with subtraction of initial update_value for first iteration.
  //   init_update_value = 2^-(i+1) = 57'h20_0000_0000_0000
  // Initial carry is zero and divisor is unused for sqrt operations.
  assign init_rem_sum_sqrt =
    ((a0_exp_unbiased_f2[0] & start_div_f2_i) | (a0_exp_adj_f3[0] & (renorm_a0|renorm_a1))) ?
        {1'b0,a0_mant_norm[51],~a0_mant_norm[51], a0_mant_norm[50:0], 3'b000}
      : {                3'b000                 , a0_mant_norm[51:0],  2'b00};

  assign init_rem_sum_sqrt_simd = {init_rem_sum_sqrt[56:30],{3{1'b0}},
    ((a1_exp_unbiased_f2[0] & start_div_f2_i) | (a1_exp_adj_f3[0] & (renorm_a0|renorm_a1))) ?
         {a1_mant_norm[22],~a1_mant_norm[22], a1_mant_norm[21:0],3'b000}
        :{                2'b00             , a1_mant_norm[22:0], 2'b00}};

  // Divide op also includes first iteration at initial remainder load.
  // This is achieved by placing ~divisor in to rem_carry (and adding 1 @ LSB)
  // and placing left shifted dividend in rem_sum.
  //   This is possible because q0 = +1, therefore rem1 = 2*rem0 - divisor.

  assign init_rem_sum_div  =
    (renorm_b0_reg & ~renorm_a0) ? rem_sum_f3
           : {1'b0, a0_mant_norm[52:0],3'b100};

  assign init_rem_sum_div_simd =
     (renorm_b0 | renorm_b1) ? rem_sum_f3
           : {1'b0, a0_mant_norm[52:29],1'b1, 4'h0, a1_mant_norm[23:0], 3'b100};

  assign init_rem_carry_div = (renorm_a0 | renorm_a1) ? {1'b1, ~divisor_f3,   3'b100}
                                                      : {1'b1, ~b0_mant_norm, 3'b100};

  assign init_rem_carry_div_simd = (renorm_a0 | renorm_a1) ?
        {1'b1, ~divisor_f3[52:29]  ,5'b10001,~divisor_f3[23:0], 3'b100}
      : {1'b1, ~b0_mant_norm[52:29],5'b10001,~b1_mant_norm    , 3'b100};

  // If renorm_b will be set - load denorm value in to divisor so that it can be
  // used as input to shifter in next cycle.
  // If renorm_a maintain the divisor value.
  assign nxt_divisor_f3 =
    ((nxt_renorm_b0 | nxt_renorm_b1) & start_div_f2_i) ? b_mant_in
        : (renorm_a0 | renorm_a1) ? divisor_f3
          : nxt_ctl_dual_fp_f3 ? {b0_mant_norm[52:29],{5{1'b0}},b1_mant_norm}
                                : b0_mant_norm;

  always @*
    case (nxt_start_div_f3)
      1'b0: begin
        nxt_rem_sum_f3    = new_rem_sum_f3[2][56:0];
        nxt_rem_carry_f3  = new_rem_carry_f3[2][56:0];
        nxt_raw_mask_f3   = {1'b1, raw_mask_f3[17:1]};
        nxt_quot_f3       = ctl_dual_fp_f3 ?
                             {new_quot0_f3[2][54:28], 1'b0, new_quot1_f3[2][26:0]}
                            : new_quot0_f3[2];
        nxt_quot_m1_f3    = ctl_dual_fp_f3 ?
                             {new_quot0_m1_f3[2][54:28], 1'b0, new_quot1_m1_f3[2][26:0]}
                            : new_quot0_m1_f3[2];
      end

      1'b1: begin
        nxt_rem_sum_f3    = (nxt_renorm_a0 | nxt_renorm_a1) ? {4'b0000,a_mant_f2_i}
          : nxt_ctl_dual_fp_f3 ?
             (nxt_sqrt_f3 ? init_rem_sum_sqrt_simd : init_rem_sum_div_simd)
            :(nxt_sqrt_f3 ? init_rem_sum_sqrt : init_rem_sum_div);
        nxt_rem_carry_f3  = nxt_sqrt_f3        ? 57'h000_0000_0000_0000 :
                            nxt_ctl_dual_fp_f3 ? init_rem_carry_div_simd :
                                                 init_rem_carry_div;
        nxt_raw_mask_f3   = {18{1'b0}};
        // If result isn't NaN - initialise quotient (result) with 1 @ MSB
        // This is because first iteration assumed result_bit of 1 with reg load.
        nxt_quot_f3       = (start_div_f2_i & (res0_nan_f2_i | res1_nan_f2_i)) ? nan_frac
                             : nxt_ctl_dual_fp_f3 ? 55'h40_0000_0400_0000
                                                  : 55'h40_0000_0000_0000;
        nxt_quot_m1_f3    = 55'h00_0000_0000_0000;
      end

      default: begin
        nxt_rem_sum_f3    = {57{1'bx}};
        nxt_rem_carry_f3  = {57{1'bx}};
        nxt_raw_mask_f3   = {18{1'bx}};
        nxt_quot_f3       = {55{1'bx}};
        nxt_quot_m1_f3    = {55{1'bx}};
      end
    endcase

  // -----------------------------------------------------------------------
  // Clocking blocks for iteration registers
  // -----------------------------------------------------------------------

  assign div_reg_wr_en = start_div_f2_i & advance_pipeline_i;

  // Only load divisor at beginning of calculation or due to renorm
  assign divisor_f3_en = (div_reg_wr_en & ~sqrt_f2_i) | renorm_b0 | renorm_b1;
  always @(posedge clk_fp_mul)
    if (divisor_f3_en)
      divisor_f3        <= nxt_divisor_f3;

  // Unless res0 is NaN clock top half of registers during calculation
  assign iteration_upper_en = div_reg_wr_en | (enable_f3 & ~res0_nan_f3);
  always @(posedge clk_fp_mul)
    if (iteration_upper_en)
    begin
      rem_sum_f3[56:28]   <= nxt_rem_sum_f3[56:28];
      rem_carry_f3[56:28] <= nxt_rem_carry_f3[56:28];
      quot_f3[54:27]      <= nxt_quot_f3[54:27];
      quot_m1_f3[54:27]   <= nxt_quot_m1_f3[54:27];
    end

  // Unless res0 is NaN and not dual, or res1 is NaN and dual, clock bottom half during calculation
  assign iteration_lower_en = div_reg_wr_en | (enable_f3 & ((~res0_nan_f3 & ~ctl_dual_fp_f3) | (~res1_nan_f3 & ctl_dual_fp_f3)));
  always @(posedge clk_fp_mul)
    if (iteration_lower_en)
    begin
      rem_sum_f3[27:0]    <= nxt_rem_sum_f3[27:0];
      rem_carry_f3[27:0]  <= nxt_rem_carry_f3[27:0];
      quot_f3[26:0]       <= nxt_quot_f3[26:0];
      quot_m1_f3[26:0]    <= nxt_quot_m1_f3[26:0];
    end

  assign raw_mask_f3_en = div_reg_wr_en | (enable_f3 & (~res0_nan_f3 | (~res1_nan_f3 & ctl_dual_fp_f3)));
  always @(posedge clk_fp_mul)
    if (raw_mask_f3_en)
      raw_mask_f3       <= nxt_raw_mask_f3;

  // --- F3 stage ---
  // -----------------------------------------------------------------------
  // Iteration Counter/FSM
  // -----------------------------------------------------------------------

  // Generate control signals and drive FSM to control iteration
  assign div_fp_busy_nxt_cyc = start_div_f2_i | start_div_f3 | (div_fsm_f3 > 6'h04);

  assign enable_f3 = start_div_f3 | (div_fsm_f3 != 6'h00);

  assign fsm_start_val = double_prec_f3 ? 6'd17 : sqrt_f3 ? 6'd7 : 6'd8;

  assign nxt_div_fsm_f3 = start_div_f3 ? fsm_start_val[5:0]
                                       : div_fsm_f3 - 1'b1;

  always @(posedge clk_fp_mul or negedge reset_n)
    if (~reset_n)
      div_fsm_f3 <= 6'h00;
    else if (enable_f3)
      div_fsm_f3 <= nxt_div_fsm_f3;

  // -----------------------------------------------------------------------
  // Calculate result digit for current iteration
  // -----------------------------------------------------------------------

  ca53dpu_div_quot u_quot_00(
    .rem_sum_msb_i   (rem_sum_f3[56:54]),
    .rem_carry_msb_i (rem_carry_f3[56:54]),
    .quot_dig_o      (quot_dig0[0][1:0])
  );

  ca53dpu_div_quot u_quot_10(
    .rem_sum_msb_i   (rem_sum_f3[27:25]),
    .rem_carry_msb_i (rem_carry_f3[27:25]),
    .quot_dig_o      (quot_dig1[0][1:0])
  );

  generate for (i = 1; i < 3; i = i+1) begin : g_speculative_quot_sel
    ca53dpu_div_quot u_quot0_zero (
      .rem_sum_msb_i   (rem0_sum_zero[i-1][5:3]),
      .rem_carry_msb_i (rem0_carry_zero[i-1][5:3]),
      .quot_dig_o      (quot_dig0_zero[i-1][1:0])
    );

    ca53dpu_div_quot u_quot0_plus (
      .rem_sum_msb_i   (rem0_sum_plus[i-1][5:3]),
      .rem_carry_msb_i (rem0_carry_plus[i-1][5:3]),
      .quot_dig_o      (quot_dig0_plus[i-1][1:0])
    );

    ca53dpu_div_quot u_quot0_minus(
      .rem_sum_msb_i   (rem0_sum_minus[i-1][5:3]),
      .rem_carry_msb_i (rem0_carry_minus[i-1][5:3]),
      .quot_dig_o      (quot_dig0_minus[i-1][1:0])
    );

    assign quot_dig0[i] = quot_dig0[i-1][0] ? quot_dig0_minus[i-1] :
                          quot_dig0[i-1][1] ? quot_dig0_plus[i-1]  :
                                              quot_dig0_zero[i-1];

    ca53dpu_div_quot u_quot1_zero (
      .rem_sum_msb_i   (rem1_sum_zero[i-1][5:3]),
      .rem_carry_msb_i (rem1_carry_zero[i-1][5:3]),
      .quot_dig_o    (quot_dig1_zero[i-1][1:0])
    );

    ca53dpu_div_quot u_quot1_plus (
      .rem_sum_msb_i   (rem1_sum_plus[i-1][5:3]),
      .rem_carry_msb_i (rem1_carry_plus[i-1][5:3]),
      .quot_dig_o      (quot_dig1_plus[i-1][1:0])
    );

    ca53dpu_div_quot u_quot1_minus(
      .rem_sum_msb_i   (rem1_sum_minus[i-1][5:3]),
      .rem_carry_msb_i (rem1_carry_minus[i-1][5:3]),
      .quot_dig_o      (quot_dig1_minus[i-1][1:0])
    );

    assign quot_dig1[i] = quot_dig1[i-1][0] ? quot_dig1_minus[i-1] :
                          quot_dig1[i-1][1] ? quot_dig1_plus[i-1]  :
                                              quot_dig1_zero[i-1];
  end endgenerate

  // Generate masks for update value and result indexing
  assign msk_dig[0]   = mask_f3[0][55:0] ^ {1'b1, mask_f3[0][55:1]};
  assign msk_dig_3[0] = msk_dig[0][55:1] | msk_dig[0][54:0];
  assign mask_f3[0]   = {1'b1,{3{raw_mask_f3[17]}},
                              {3{raw_mask_f3[16]}},
                              {3{raw_mask_f3[15]}},
                              {3{raw_mask_f3[14]}},
                              {3{raw_mask_f3[13]}},
                              {3{raw_mask_f3[12]}},
                              {3{raw_mask_f3[11]}},
                              {3{raw_mask_f3[10]}},
                              {3{raw_mask_f3[ 9]}},
                              {3{raw_mask_f3[ 8]}},
                              {3{raw_mask_f3[ 7]}},
                              {3{raw_mask_f3[ 6]}},
                              {3{raw_mask_f3[ 5]}},
                              {3{raw_mask_f3[ 4]}},
                              {3{raw_mask_f3[ 3]}},
                              {3{raw_mask_f3[ 2]}},
                              {3{raw_mask_f3[ 1]}},
                              {3{raw_mask_f3[ 0]}}, 1'b0};
  // Shift masks right 1 bit for 2nd iteration within cycle.
  // LSB is unused - but required for correct indexing in generate blocks.
  assign mask_f3[1]   = {1'b1,  mask_f3[0][55:1]};
  assign msk_dig[1]   = {1'b0,  msk_dig[0][55:1]};
  assign msk_dig_3[1] = {1'b0,  msk_dig_3[0][54:1]};

  assign mask_f3[2]   = {2'b11, mask_f3[0][55:2]};
  assign msk_dig[2]   = {2'b00, msk_dig[0][55:2]};
  assign msk_dig_3[2] = {2'b00, msk_dig_3[0][54:2]};

  // -----------------------------------------------------------------------
  // Generate update value to be add/subtracted from current remainder.
  // -----------------------------------------------------------------------

  // Assemble possible update values
  assign csa_plus_val_sqrt0[0]  = {quot_m1_f3[53:1], 2'b00} | msk_dig_3[0][54: 0];
  assign csa_plus_val_sqrt1[0]  = {quot_m1_f3[25:2], 1'b0}  | msk_dig_3[0][54:30];
  assign csa_minus_val_sqrt0[0] = {quot_f3[53:1], 2'b00}    | msk_dig[0][55: 1];
  assign csa_minus_val_sqrt1[0] = {quot_f3[25:2], 1'b0}     | msk_dig[0][55:31];
  assign csa_val_div = {divisor_f3[51:0], 3'b000};

  generate for (i = 1; i < 3; i = i+1) begin : g_csa_sqrt_val

    assign csa_plus_val_sqrt0[i]  = {new_quot0_m1_f3[i-1][53:1], 2'b00} | msk_dig_3[i][54: 0];
    assign csa_plus_val_sqrt1[i]  = {new_quot1_m1_f3[i-1][25:2], 1'b0}  | msk_dig_3[i][54:30];
    assign csa_minus_val_sqrt0[i] = {new_quot0_f3[i-1][53:1], 2'b00}    | msk_dig[i][55: 1];
    assign csa_minus_val_sqrt1[i] = {new_quot1_f3[i-1][25:2], 1'b0}     | msk_dig[i][55:31];
  end endgenerate

  generate for (i = 0; i < 3; i = i+1) begin : g_csa_mux_val
    // Mux between SQRT or DIVIDE operation
    assign csa_plus_val0[i] = sqrt_f3 ? csa_plus_val_sqrt0[i] : csa_val_div;
    assign csa_plus_val1[i] = sqrt_f3 ? {4'h0, csa_plus_val_sqrt1[i]} : {4'h0, csa_val_div[25:1]};

    assign csa_minus_val0[i] = sqrt_f3 ? csa_minus_val_sqrt0[i] : csa_val_div;
    assign csa_minus_val1[i] = sqrt_f3 ? {4'h0, csa_minus_val_sqrt1[i]} : {4'h0, csa_val_div[25:1]};

    // Mux between PLUS/MINUS/NO-OP (based on quot_sel results)
    assign csa_val0[i] = ({51{quot_dig0[i][0]}} & ~csa_minus_val0[i][50:0]) |
                         ({51{quot_dig0[i][1]}} &  csa_plus_val0[i][50:0]);
    assign csa_val1[i] = ({29{quot_dig1[i][0]}} & ~csa_minus_val1[i][28:0]) |
                         ({29{quot_dig1[i][1]}} &  csa_plus_val1[i][28:0]);

    // Mux between dual sp or single sp/dp calculation.
    assign csa_mux[i][50:30] = csa_val0[i][50:30];
    assign csa_mux[i][29: 0] = ctl_dual_fp_f3 ? {csa_val1[i][28:0], 1'b0}
                                              : csa_val0[i][29:0];
  end endgenerate

  // -----------------------------------------------------------------------
  // 54b Carry Save Adder with MSB compression
  // -----------------------------------------------------------------------

  assign rem_sum_in[0]   = rem_sum_f3[55:0];
  assign rem_carry_in[0] = rem_carry_f3[55:0];
  assign rem_sum_in[1]   = new_rem_sum_f3[0][55:0];
  assign rem_carry_in[1] = new_rem_carry_f3[0][55:0];
  assign rem_sum_in[2]   = new_rem_sum_f3[1][55:0];
  assign rem_carry_in[2] = new_rem_carry_f3[1][55:0];

  generate for (i = 0; i < 3; i = i+1) begin : g_csa_msbcompress

    assign rem_sum_xor[i][50:0] = {rem_sum_in[i][49:0], 1'b0}   ^
                                  {rem_carry_in[i][49:0], 1'b0} ^
                                  csa_mux[i][50:0];

    // Note: LSB of carry is 1 when subtracting csa_val.
    assign rem_carry_andor[i][51:0] =
        {(rem_sum_in  [i][49:0] & rem_carry_in[i][49:0]) |
         (rem_sum_in  [i][49:0] & csa_mux     [i][50:1]) |
         (rem_carry_in[i][49:0] & csa_mux     [i][50:1]),
         1'b0,
         quot_dig0[i][0]};

    // Calculate top bits of remainder seperately. This ensures that no information
    // is lost when shifting the remainder left.
    ca53dpu_div_csa #(.CSA_WIDTH(7)) u_micro_csa_0(
      .csa_plus_i           (csa_plus_val0   [i][54:51]),
      .csa_minus_i          (csa_minus_val0  [i][54:51]),
      .rem_sum_i            (rem_sum_in      [i][55:50]),
      .rem_carry_i          (rem_carry_in    [i][55:50]),

      .rem_sum_zero_o       (rem0_sum_zero   [i][5:0]),
      .rem_carry_zero_o     (rem0_carry_zero [i][5:0]),
      .rem_sum_minus_d_o    (rem0_sum_minus  [i][5:0]),
      .rem_carry_minus_d_o  (rem0_carry_minus[i][5:0]),
      .rem_sum_plus_d_o     (rem0_sum_plus   [i][5:0]),
      .rem_carry_plus_d_o   (rem0_carry_plus [i][5:0])
    );

    ca53dpu_div_csa #(.CSA_WIDTH(7)) u_micro_csa_1(
      .csa_plus_i           (csa_plus_val1   [i][24:21]),
      .csa_minus_i          (csa_minus_val1  [i][24:21]),
      .rem_sum_i            (rem_sum_in      [i][26:21]),
      .rem_carry_i          (rem_carry_in    [i][26:21]),

      .rem_sum_zero_o       (rem1_sum_zero   [i][5:0]),
      .rem_carry_zero_o     (rem1_carry_zero [i][5:0]),
      .rem_sum_minus_d_o    (rem1_sum_minus  [i][5:0]),
      .rem_carry_minus_d_o  (rem1_carry_minus[i][5:0]),
      .rem_sum_plus_d_o     (rem1_sum_plus   [i][5:0]),
      .rem_carry_plus_d_o   (rem1_carry_plus [i][5:0])
    );

    assign rem_sum_msb0[i][5:0]   = quot_dig0[i][0] ? rem0_sum_minus[i] :
                                    quot_dig0[i][1] ? rem0_sum_plus[i]  :
                                                      rem0_sum_zero[i];
    assign rem_carry_msb0[i][5:0] = quot_dig0[i][0] ? rem0_carry_minus[i] :
                                    quot_dig0[i][1] ? rem0_carry_plus[i]  :
                                                      rem0_carry_zero[i];
    assign rem_sum_msb1[i][5:0]   = quot_dig1[i][0] ? rem1_sum_minus[i] :
                                    quot_dig1[i][1] ? rem1_sum_plus[i]  :
                                                      rem1_sum_zero[i];
    assign rem_carry_msb1[i][5:0] = quot_dig1[i][0] ? rem1_carry_minus[i] :
                                    quot_dig1[i][1] ? rem1_carry_plus[i]  :
                                                      rem1_carry_zero[i];

    assign new_rem_sum0[i][56:0] = {rem_sum_msb0[i][5:0], rem_sum_xor[i][50:0]};
    assign new_rem_sum1[i][26:0] = {rem_sum_msb1[i][5:0], rem_sum_xor[i][21:1]};
    assign new_rem_sum_f3[i] = {new_rem_sum0[i][56:30],
                                (ctl_dual_fp_f3 ? {2'b00, new_rem_sum1[i][26:0], 1'b0}
                                                : new_rem_sum0[i][29:0])};

    assign new_rem_carry0[i][56:0] = {rem_carry_msb0[i][5:1], rem_carry_andor[i][51:0]};
    assign new_rem_carry1[i][26:0] = {rem_carry_msb1[i][5:1], rem_carry_andor[i][22:2], quot_dig1[i][0]};

    // Must insert 1 at bottom of rem_carry0 when subtracting
    // (ie. quot_dig0[0] is 01)
    // and performing SIMD SP operation.
    assign new_rem_carry_f3[i] = {new_rem_carry0[i][56:31],
                                  (ctl_dual_fp_f3 ? {quot_dig0[i][0], 2'b00, new_rem_carry1[i][26:0], 1'b0}
                                                  : new_rem_carry0[i][30:0])};

  end endgenerate

  // -----------------------------------------------------------------------
  // Update result with new digit
  // -----------------------------------------------------------------------
  assign prev_quot[0]    = quot_f3;
  assign prev_quot_m1[0] = quot_m1_f3;
  generate for (i = 1; i < 3; i = i+1) begin : g_prev_quot
    assign prev_quot[i]    = ctl_dual_fp_f3 ?
                               {new_quot0_f3[i-1][54:28], 1'b0, new_quot1_f3[i-1][26:0]}
                              : new_quot0_f3[i-1];
    assign prev_quot_m1[i] = ctl_dual_fp_f3 ?
                               {new_quot0_m1_f3[i-1][54:28], 1'b0, new_quot1_m1_f3[i-1][26:0]}
                              : new_quot0_m1_f3[i-1];
  end endgenerate

  // It is necessary to store quotient and quotient-1 so that SRT algorithm
  // can correct for previous iterations.
  //
  // quot_dig = +1 -> quotient <= {quotient[$:i], 1'b1, 00...}    (add 1)
  // quot_dig =  0 -> quotient <= {quotient[$:i], 1'b0, 00...}    (NOP)
  // quot_dig = -1 -> quotient <= {quotient_m1[$:i], 1'b1, 00...} (sub 1)
  //
  // Placed in generate so 2nd SRT iteration in cycle adds further bit.
  generate for (i = 0; i < 3; i = i+1) begin : g_quotient_result_decode

    // new_quot_dig inserts a 1 in indexed result bit when high.
    assign new_quot_dig0[i]    =  |(quot_dig0[i]);
    assign new_quot_m1_dig0[i] = ~|(quot_dig0[i]);
    // new_quot_sel selects between quotient and quotient minus 1 value.
    assign new_quot_sel0[i]    =  quot_dig0[i][1];
    assign new_quot_m1_sel0[i] = ~quot_dig0[i][0];

    assign new_quot0_f3[i]    = ((new_quot_sel0[i] ? prev_quot_m1[i] : prev_quot[i]) & mask_f3[i][55:1])
                                 | ({55{new_quot_dig0[i]}}    & msk_dig[i][55:1]);
    assign new_quot0_m1_f3[i] = ((new_quot_m1_sel0[i] ? prev_quot_m1[i] : prev_quot[i]) & mask_f3[i][55:1])
                                 | ({55{new_quot_m1_dig0[i]}} & msk_dig[i][55:1]);

    // SIMD operation result calculation
    assign new_quot_dig1[i]    =  |(quot_dig1[i]);
    assign new_quot_m1_dig1[i] = ~|(quot_dig1[i]);
    assign new_quot_sel1[i]    =  quot_dig1[i][1];
    assign new_quot_m1_sel1[i] = ~quot_dig1[i][0];

    assign new_quot1_f3[i]    = ((new_quot_sel1[i] ? prev_quot_m1[i][26:0] : prev_quot[i][26:0])
        & mask_f3[i][55:29]) | ({27{new_quot_dig1[i]}}    & msk_dig[i][55:29]);
    assign new_quot1_m1_f3[i] = ((new_quot_m1_sel1[i] ? prev_quot_m1[i][26:0] : prev_quot[i][26:0])
        & mask_f3[i][55:29]) | ({27{new_quot_m1_dig1[i]}} & msk_dig[i][55:29]);

  end endgenerate

  // CPA of remainder to test if final remainder is negative
  // if negative, use quot_m1 as final quotient result.
  assign cpa_res = {rem_sum_f3[56:28],   ~ctl_dual_fp_f3, rem_sum_f3[27:0]} +
                   {rem_carry_f3[56:28], 1'b0,            rem_carry_f3[27:0]};

  assign rem0_neg      = cpa_res[57];
  assign rem1_neg      = cpa_res[27];
  assign remhi_nonzero = cpa_res[57:29] != {29{1'b0}};
  assign rem1_nonzero  = cpa_res[27: 0] != {28{1'b0}};
  assign rem0_nonzero  = double_prec_f3 ? (remhi_nonzero | rem1_nonzero) : remhi_nonzero;

  assign quot_out0 = (rem0_neg & ~res0_nan_f3) ? quot_m1_f3       : quot_f3;
  assign quot_out1 = (rem1_neg & ~res1_nan_f3) ? quot_m1_f3[26:0] : quot_f3[26:0];

  // -----------------------------------------------------------------------
  // Determine inexact result
  // -----------------------------------------------------------------------

  // If number of trailing zeros less than sub-norm result shift then
  // result is inexact.

  // Count-trailing zeros of result by checking bits appended to result.
  assign ctz_en = div_reg_wr_en | enable_f3;
  always @(posedge clk_fp_mul)
    if (ctz_en) begin
      ctz_counter0    <= nxt_ctz_counter0;
      ctz_m1_counter0 <= nxt_ctz_m1_counter0;
    end

  assign nxt_ctz_counter0 = nxt_start_div_f3 ? 6'h00
                            : nxt_ctz_count0[2];
  assign nxt_ctz_m1_counter0 = nxt_start_div_f3 ? 6'h01
                               : nxt_ctz_m1_count0[2];

  assign ctz_counter0_p1[0]   = ctz_counter0 + 6'h01;
  assign ctz_m1_counter0_p1[0]= ctz_m1_counter0 + 6'h01;
  assign ctz_counter1_p1[0]   = ctz_counter1 + 5'h01;
  assign ctz_m1_counter1_p1[0]= ctz_m1_counter1 + 5'h01;

  assign nxt_ctz_count0[0]    = new_quot_dig0[0] ? 6'h00 : ctz_counter0_p1[0];
  assign nxt_ctz_m1_count0[0] = quot_dig0[0][0] ? ctz_counter0_p1[0] :
                                quot_dig0[0][1] ? ctz_m1_counter0_p1[0] : 6'h00;
  assign nxt_ctz_count1[0]    = new_quot_dig1[0] ? 5'h00 : ctz_counter1_p1[0];
  assign nxt_ctz_m1_count1[0] = quot_dig1[0][0] ? ctz_counter1_p1[0] :
                                quot_dig1[0][1] ? ctz_m1_counter1_p1[0] :
                                                  5'h00;

  generate for (i = 1; i < 3; i = i+1) begin : g_nxt_ctz_count
    assign ctz_counter0_p1[i]   = nxt_ctz_count0[i-1] + 6'h01;
    assign ctz_m1_counter0_p1[i]= nxt_ctz_m1_count0[i-1] + 6'h01;

    assign nxt_ctz_count0[i]    = new_quot_dig0[i] ? 6'h00 : ctz_counter0_p1[i];
    assign nxt_ctz_m1_count0[i] = quot_dig0[i][0] ? ctz_counter0_p1[i]    :
                                  quot_dig0[i][1] ? ctz_m1_counter0_p1[i] :
                                                  6'h00;

    assign ctz_counter1_p1[i]   = nxt_ctz_count1[i-1] + 5'h01;
    assign ctz_m1_counter1_p1[i]= nxt_ctz_m1_count1[i-1] + 5'h01;

    assign nxt_ctz_count1[i]    = new_quot_dig1[i] ? 5'h00 : ctz_counter1_p1[i];
    assign nxt_ctz_m1_count1[i] = quot_dig1[i][0] ? ctz_counter1_p1[i]    :
                                  quot_dig1[i][1] ? ctz_m1_counter1_p1[i] :
                                                  5'h00;
  end endgenerate

  // Must have a seperate counter for SIMD operation.
  assign ctz_en_dual = (div_reg_wr_en | enable_f3) & nxt_ctl_dual_fp_f3;
  always @(posedge clk_fp_mul)
    if (ctz_en_dual) begin
      ctz_counter1    <= nxt_ctz_counter1;
      ctz_m1_counter1 <= nxt_ctz_m1_counter1;
    end

  assign nxt_ctz_counter1 = nxt_start_div_f3 ? 5'h00
                           : nxt_ctz_count1[2];
  assign nxt_ctz_m1_counter1 = nxt_start_div_f3 ? 5'h01
                               : nxt_ctz_m1_count1[2];

  // If exponent is negative, and therefore result is denormalised, must calculate shift required for mantissa.
  assign shift0_f3 = (~res0_nan_f3 &  quot0_exp_f3[12] & ((~&quot0_exp_f3[11:6]) | (~|quot0_exp_f3[5:0]))) ? 7'h40                            :
                     (~res0_nan_f3 & (quot0_exp_f3[12] | (quot0_exp_f3[11:0] == 12'h000)))                 ? {1'b1, quot0_exp_f3[5:0] - 1'b1} :
                                                                                                             7'h00;

  assign shift1_f3 = (~res1_nan_f3 &  quot1_exp_f3[9] & ((~&quot1_exp_f3[8:5]) | (~|quot1_exp_f3[4:0]))) ? 6'h20                            :
                     (~res1_nan_f3 & (quot1_exp_f3[9] | (quot1_exp_f3[8:0] == 9'h000)))                  ? {1'b1, quot1_exp_f3[4:0] - 1'b1} :
                                                                                                           6'h00;
  // Test final remainder equal to -divisor (division) or -result (sqrt)
  // to give exact answer.
  // Achieved by Carry-save adding divisor/result to remainder and testing
  // if equal to minus 1 by "carry-save adding" with all 1s.
  assign div_sh =
    ctl_dual_fp_f3 ?
          sqrt_f3 ? {1'b0, quot_m1_f3[54:30], 4'b1110, quot_m1_f3[26:2],2'b10 }
                  : {1'b0,divisor_f3[52:29],5'h00,divisor_f3[23:0],3'b000}
        : sqrt_f3 ? {1'b0, ({quot_m1_f3,1'b0} | msk_dig[0])}
                  : {1'b0,divisor_f3[52:0],3'b000};

  assign rem_sum_plus_d_no_sh = rem_sum_f3 ^ rem_carry_f3 ^ div_sh;

  assign rem_carry_plus_d_no_sh =
      {(rem_sum_f3  [55:0] & rem_carry_f3    [55:0]) |
       (rem_sum_f3  [55:0] & div_sh    [55:0]) |
       (rem_carry_f3[55:0] & div_sh    [55:0]),
       1'b0};

  assign rem_plus_d_no_sh_xor = rem_sum_plus_d_no_sh[56:0] ^ rem_carry_plus_d_no_sh[56:0];
  assign rem_plus_d_no_sh_or  = rem_sum_plus_d_no_sh[55:0] | rem_carry_plus_d_no_sh[55:0];

  assign remhi_eq_div = (rem_plus_d_no_sh_xor[56:33] ==  rem_plus_d_no_sh_or[56:33]);
  assign remmi_eq_div = (rem_plus_d_no_sh_xor[32:28] ==  rem_plus_d_no_sh_or[32:28]);
  assign rem1_eq_div  = (rem_plus_d_no_sh_xor[27: 0] == {rem_plus_d_no_sh_or[27: 1], 1'b0});
  assign rem0_eq_div  = double_prec_f3 ? remhi_eq_div & remmi_eq_div & rem1_eq_div : remhi_eq_div;
  // Determine inexact
  assign quot0_out_ctz = rem0_neg ? ctz_m1_counter0 : ctz_counter0;
  assign quot1_out_ctz = rem1_neg ? ctz_m1_counter1 : ctz_counter1;
  // sticky bit hi when right shift is greater than number of trailing zeros on quot_mantissa

  assign sticky0_shift_gt_tz = (shift0_f3[6] & (~shift0_f3[5:0] >= quot0_out_ctz));
  assign sticky1_shift_gt_tz = (shift1_f3[5] & (~shift1_f3[4:0] >= quot1_out_ctz));

  // -----------------------------------------------------------------------
  // Output aliasing
  // -----------------------------------------------------------------------

  assign div_fp_busy_nxt_cyc_o = div_fp_busy_nxt_cyc;
  assign double_prec_f3_o      = double_prec_f3;
  assign round_mode_f3_o       = round_mode_f3;
  assign res0_zero_f3_o        = res0_zero_f3;
  assign res0_infinite_f3_o    = res0_infinite_f3;
  assign res0_nan_f3_o         = res0_nan_f3;
  assign invalid0_f3_o         = invalid0_f3;
  assign divbyzero0_f3_o       = divbyzero_op0_f3;
  assign in_flushzero_f3_o     = in_flushzero_f3;
  assign shift0_f3_o           = shift0_f3;
  assign out0_sign_f3_o        = out0_sign_f3;
  assign out0_exp_f3_o         = quot0_exp_f3;
  assign out0_frac_f3_o        = quot_out0[54:0];
  assign stickybit0_f3_o       = (rem0_nonzero & ~rem0_eq_div) | sticky0_shift_gt_tz;
  assign stickybit1_f3_o       = (rem1_nonzero & ~rem1_eq_div) | sticky1_shift_gt_tz;
  assign shift1_f3_o           = shift1_f3;
  assign out1_exp_f3_o         = quot1_exp_f3[9:0];
  assign out1_sign_f3_o        = out1_sign_f3;
  assign out1_frac_f3_o        = quot_out1;
  assign res1_infinite_f3_o    = res1_infinite_f3;
  assign res1_zero_f3_o        = res1_zero_f3;
  assign res1_nan_f3_o         = res1_nan_f3;
  assign invalid1_f3_o         = invalid1_f3;
  assign divbyzero1_f3_o       = divbyzero_op1_f3;
  assign ctl_dual_fp_f3_o      = ctl_dual_fp_f3;

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_f2_f3")
  u_ovl_x_advance_f2_f3 (.clk       (clk_fp_mul),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (advance_f2_f3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_f2_f3_dual")
  u_ovl_x_advance_f2_f3_dual (.clk       (clk_fp_mul),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (advance_f2_f3_dual));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ctz_en")
  u_ovl_x_ctz_en (.clk       (clk_fp_mul),
                  .reset_n   (reset_n),
                  .qualifier (1'b1),
                  .test_expr (ctz_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ctz_en_dual")
  u_ovl_x_ctz_en_dual (.clk       (clk_fp_mul),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (ctz_en_dual));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: divisor_f3_en")
  u_ovl_x_divisor_f3_en (.clk       (clk_fp_mul),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (divisor_f3_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: iteration_lower_en")
  u_ovl_x_iteration_lower_en (.clk       (clk_fp_mul),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (iteration_lower_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: iteration_upper_en")
  u_ovl_x_iteration_upper_en (.clk       (clk_fp_mul),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (iteration_upper_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: quot_exp_en_dual")
  u_ovl_x_quot_exp_en_dual (.clk       (clk_fp_mul),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (quot_exp_en_dual));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: raw_mask_f3_en")
  u_ovl_x_raw_mask_f3_en (.clk       (clk_fp_mul),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (raw_mask_f3_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: start_div_f3_en")
  u_ovl_x_start_div_f3_en (.clk       (clk_fp_mul),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (start_div_f3_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: quot_exp_en")
  u_ovl_x_quot_exp_en (.clk       (clk_fp_mul),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (quot_exp_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: enable_f3")
  u_ovl_x_enable_f3 (.clk       (clk_fp_mul),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (enable_f3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: div_reg_wr_en")
  u_ovl_x_div_reg_wr_en (.clk       (clk_fp_mul),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (div_reg_wr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: start_div_f2_i | start_div_f3")
  u_ovl_x_fp_div_comb_en1 (.clk       (clk_fp_mul),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (start_div_f2_i | start_div_f3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: div_reg_wr_en & ~sqrt_f2_i")
  u_ovl_x_fp_div_comb_en2 (.clk       (clk_fp_mul),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (div_reg_wr_en & ~sqrt_f2_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: enable_f3 & sqrt_f3 & ~res0_nan_f3")
  u_ovl_x_fp_div_comb_en3 (.clk       (clk_fp_mul),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (enable_f3 & sqrt_f3 & ~res0_nan_f3));

  // Each renorm signal should only be high for one cycle
  reg renorm_b1_prev;
  reg renorm_b0_prev;

  always @(posedge clk_fp_mul)
  begin
    renorm_b1_prev <= renorm_b1;
    renorm_b0_prev <= renorm_b0;
  end

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "renorm_b0 high for 2 consecutive cycles")
  u_ovl_renorm_b0    (.clk(clk_fp_mul),
                      .reset_n(reset_n),
                      .test_expr(renorm_b0_prev & renorm_b0));
  assert_never #(`OVL_FATAL, `OVL_ASSERT, "renorm_b1 high for 2 consecutive cycles")
  u_ovl_renorm_b1    (.clk(clk_fp_mul),
                      .reset_n(reset_n),
                      .test_expr(renorm_b1_prev & renorm_b1));

  // OVL_ASSERT_END

`endif

endmodule // ca53dpu_fp_div

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
