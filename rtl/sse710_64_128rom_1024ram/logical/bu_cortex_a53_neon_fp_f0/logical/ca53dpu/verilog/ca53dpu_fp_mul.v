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
// Abstract : Floating point multiplier
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Performs IEEE multiplication with all rounding modes
//

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_fp_mul (
  // Inputs
  input  wire                           clk_fp_mul,
  input  wire                           reset_n,
  input  wire                           stall_wr_i,
  input  wire                           flush_ret_i,
  input  wire                           advance_pipeline_i,
  input  wire                           mul_enable_f1_i,
  input  wire  [`CA53_FP_MUL_CTL_W-1:0] mul_ctl_f1_i,
  input  wire                           collect_div_f1_i,
  input  wire                     [1:0] round_mode_f1_i,
  input  wire                           force_dn_fz_f1_i,
  input  wire                           fpscr_dn_i,        // default NaN mode
  input  wire                           fpscr_fz_i,        // flush to zero mode
  input  wire                    [63:0] fml_a_data_f1_i,
  input  wire                    [63:0] fml_b_data_f1_i,
  input  wire                    [63:0] fml_c_data_f1_i,
  input  wire                           fp_mul_fwd_f2_i,
  // Outputs
  output wire                    [63:0] fml_data_f5_o,
  output wire                    [63:0] fml_extra_data_f5_o,
  output wire                           mul_enable_f2_o,
  output wire                           mul_enable_f3_o,
  output wire      [`CA53_XFLAGS_W-1:0] mul_xflags_o,
  output wire                     [1:0] mac_round_mode_f5_o,
  output wire                           mac_force_dn_fz_f5_o,
  output wire                           div_fp_busy_nxt_cyc_o,
  output wire                           fused_mac_f5_o,
  output wire                           mul_dual_fp_f5_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg    [10:0] a0_exp_f2;
  reg           a0_exp_max_f2;
  reg           a0_sign_f2;
  reg     [7:0] a1_exp_f2;
  reg           a1_exp_max_f2;
  reg           a1_sign_f2;
  reg    [52:0] a_mant_f2;
  reg    [12:0] acc0_exp_f3;
  reg    [12:0] acc0_exp_f4;
  reg     [9:0] acc1_exp_f3;
  reg     [9:0] acc1_exp_f4;
  reg   [119:0] pre_acc_val_f3;
  reg     [1:0] acc_halfprec_bits_f3;
  reg    [10:0] b0_exp_f2;
  reg           b0_exp_max_f2;
  reg           b0_sign_f2;
  reg     [7:0] b1_exp_f2;
  reg           b1_exp_max_f2;
  reg           b1_sign_f2;
  reg    [52:0] b_mant_f2;
  reg           collect_div_f2;
  reg           collect_div_f3;
  reg           collect_div_f4;
  reg           sum0_stickybit_f4;
  reg           sum1_stickybit_f4;
  reg           divbyzero_op0_f4;
  reg           divbyzero_op0_f5;
  reg           divbyzero_op1_f4;
  reg           divbyzero_op1_f5;
  reg           double_prec_f2;
  reg           double_prec_f3;
  reg           double_prec_f4;
  reg           double_prec_f5;
  reg           enable_f2;
  reg           enable_f3;
  reg           enable_f4;
  reg           fused_mac_f2;
  reg           fused_mac_f3;
  reg           fused_mac_f4;
  reg           fused_mac_f5;
  reg           in_flushzero_f3;
  reg           in_flushzero_f4;
  reg           in_flushzero_f5;
  reg           invalid0_f3;
  reg           invalid0_f4;
  reg           invalid0_f5;
  reg           invalid1_f3;
  reg           invalid1_f4;
  reg           invalid1_f5;
  reg     [5:0] mant0_lz_f3;
  reg     [6:0] mant0_tz_f3;
  reg     [4:0] mant1_lz_f3;
  reg     [5:0] mant1_tz_f3;
  reg    [63:0] mul_op_a_f2;
  reg    [63:0] mul_op_b_f2;
  reg     [1:0] mul_size_f2;
  reg     [1:0] mul_size_f3;
  reg   [105:0] mul_sum_f4;
  reg           negate_f2;
  reg     [1:0] neon_acc_sat_f4;
  reg           neon_mul_qc_f3;
  reg     [3:0] neon_mul_sat_f3;
  reg     [2:0] neon_out_fmt_f2;
  reg     [2:0] neon_out_fmt_f3;
  reg           neon_qc_bit_f4;
  reg           neon_qc_bit_f5;
  reg           neon_round_f2;
  reg           neon_sat_dbl_f2;
  reg           neon_sat_dbl_f3;
  reg     [1:0] neon_sat_width_f4;
  reg     [1:0] neon_underflow_f4;
  reg           neon_vrsqrte_f3;
  reg    [11:0] norm0_exp_f5;
  reg     [8:0] norm1_exp_f5;
  reg    [52:0] norm_frac_f4;
  reg    [52:0] norm_frac_f5;
  reg    [52:0] norm_frac_subprec_f4;
  reg    [52:0] norm_frac_subprec_f5;
  reg    [12:0] nxt_acc0_exp_f4;
  reg     [9:0] nxt_acc1_exp_f4;
  reg           nxt_sum0_stickybit_f4;
  reg           nxt_sum1_stickybit_f4;
  reg           nxt_divbyzero_op0_f4;
  reg           nxt_divbyzero_op1_f4;
  reg           nxt_double_prec_f4;
  reg           nxt_fused_mac_f4;
  reg           nxt_in_flushzero_f4;
  reg           nxt_invalid0_f4;
  reg           nxt_invalid1_f4;
  reg   [105:0] nxt_mul_sum_f4;
  reg           nxt_out0_sign_f4;
  reg           nxt_out1_sign_f4;
  reg           nxt_res0_infinite_f4;
  reg           nxt_res0_nan_f4;
  reg           nxt_res0_sign_f4;
  reg           nxt_res0_zero_f4;
  reg           nxt_res1_infinite_f4;
  reg           nxt_res1_nan_f4;
  reg           nxt_res1_sign_f4;
  reg           nxt_res1_zero_f4;
  reg     [1:0] nxt_round_mode_f4;
  reg     [6:0] nxt_shift_lo_f4;
  reg     [6:0] nxt_shift_hi_f4;
  reg           nxt_ctl_dual_fp_f4;
  reg    [63:0] op_c_f2;
  reg           out0_overflow_no_carry_f5;
  reg           out1_overflow_no_carry_f5;
  reg           out0_overflow_if_carry_f5;
  reg           out1_overflow_if_carry_f5;
  reg           out0_sign_f3;
  reg           out0_sign_f4;
  reg           out0_sign_f5;
  reg           out1_sign_f3;
  reg           out1_sign_f4;
  reg           out1_sign_f5;
  reg           neon_divbyzero_op0_f3;
  reg           neon_divbyzero_op1_f3;
  reg           force_dn_fz_f2;
  reg           raw_force_dn_fz_f3;
  reg           force_dn_fz_f4;
  reg           force_dn_fz_f5;
  reg           neon_int_op_f2;
  reg           neon_int_op_f3;
  reg           raw_neon_int_op_f4;
  reg           neon_int_op_f5;
  reg           neon_inv_zero_f2;
  reg     [1:0] neon_udf_f5;
  reg           raw_res0_zero_f4;
  reg           raw_res1_zero_f4;
  reg           res0_infinite_f3;
  reg           res0_infinite_f4;
  reg           res0_infinite_f5;
  reg           res0_nan_f3;
  reg           res0_nan_f4;
  reg           res0_nan_f5;
  reg           res0_sign_f3;
  reg           res0_sign_f4;
  reg           res0_two_f3;
  reg           res0_zero_f3;
  reg           res0_zero_f5;
  reg           res1_infinite_f3;
  reg           res1_infinite_f4;
  reg           res1_infinite_f5;
  reg           res1_nan_f3;
  reg           res1_nan_f4;
  reg           res1_nan_f5;
  reg           res1_sign_f3;
  reg           res1_sign_f4;
  reg           res1_two_f3;
  reg           res1_zero_f3;
  reg           res1_zero_f5;
  reg     [1:0] round_mode_f2;
  reg     [1:0] round_mode_f3;
  reg     [1:0] round_mode_f4;
  reg     [1:0] round_mode_f5;
  reg           round_updown0_f5;
  reg           round_updown1_f5;
  reg     [1:0] round_val_f5;
  reg           roundbit0_f4;
  reg           roundbit1_f4;
  reg     [6:0] shift_lo_f4;
  reg     [6:0] shift_hi_f4;
  reg           signed_f2;
  reg           sqrt_f2;
  reg           start_div_f2;
  reg           stickybit0_f4;
  reg           stickybit1_f4;
  reg           fpscr_dn_f2;
  reg           fpscr_fz_f2;
  reg           fpscr_fz_f3;
  reg           fpscr_fz_f5;
  reg    [63:0] neon_mul_sum_f3;
  reg    [63:0] sat_neon_sum_f4;
  reg           inexact0_f5;
  reg           inexact1_f5;
  reg           ctl_dual_fp_f2;
  reg           ctl_dual_fp_f3;
  reg           ctl_dual_fp_f4;
  reg           ctl_dual_fp_f5;
  reg   [119:0] neon_acc_val_f2;
  reg   [119:0] fwd_mask;
  reg           round_mode_rn_f5;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire   [10:0] a0_exp_f1;
  wire          a0_exp_max_f1;
  wire   [10:0] a0_exp_raw;
  wire          a0_exp_zero_f1;
  wire          a0_exp_zero_f2;
  wire          a0_flushzero;
  wire          a0_frac_zero_f2;
  wire          a0_infinite_f2;
  wire    [5:0] a0_mant_lz_f2;
  wire    [5:0] a0_mant_tz_f2;
  wire          a0_nan_f2;
  wire          a0_sign_f1;
  wire          a0_snan_f2;
  wire          a0_zero_f2;
  wire    [7:0] a1_exp_f1;
  wire          a1_exp_max_f1;
  wire    [7:0] a1_exp_raw;
  wire          a1_exp_zero_f1;
  wire          a1_exp_zero_f2;
  wire          a1_flushzero;
  wire          a1_frac_zero_f2;
  wire          a1_infinite_f2;
  wire    [4:0] a1_mant_lz_f2;
  wire    [4:0] a1_mant_tz_f2;
  wire          a1_nan_f2;
  wire          a1_sign_f1;
  wire          a1_snan_f2;
  wire          a1_zero_f2;
  wire   [52:0] a_mant_f1;
  wire    [5:0] a_mant_lz_dp_f2;
  wire    [4:0] a_mant_lz_sp_f2;
  wire   [52:0] a_mant_rev_f2;
  wire   [12:0] acc0_exp_f2;
  wire   [12:0] mul_acc0_exp_f3;
  wire   [12:0] acc0_renorm_exp_f3;
  wire    [9:0] acc1_exp_f2;
  wire    [9:0] mul_acc1_exp_f3;
  wire    [9:0] acc1_renorm_exp_f3;
  wire  [119:0] pre_acc_val_f2;
  wire    [1:0] acc_halfprec_bits_f2;
  wire          array_en_f1;
  wire          array_en_f2;
  wire   [10:0] b0_exp_f1;
  wire          b0_exp_max_f1;
  wire   [10:0] b0_exp_raw;
  wire          b0_exp_zero_f1;
  wire          b0_exp_zero_f2;
  wire          b0_flushzero;
  wire          b0_frac_zero_f2;
  wire          b0_infinite_f2;
  wire    [5:0] b0_mant_lz_f2;
  wire    [5:0] b0_mant_tz_f2;
  wire          b0_nan_f2;
  wire          b0_sign_f1;
  wire          b0_snan_f2;
  wire          b0_zero_f2;
  wire    [7:0] b1_exp_f1;
  wire          b1_exp_max_f1;
  wire    [7:0] b1_exp_raw;
  wire          b1_exp_zero_f1;
  wire          b1_exp_zero_f2;
  wire          b1_flushzero;
  wire          b1_frac_zero_f2;
  wire          b1_infinite_f2;
  wire    [4:0] b1_mant_lz_f2;
  wire    [4:0] b1_mant_tz_f2;
  wire          b1_nan_f2;
  wire          b1_sign_f1;
  wire          b1_snan_f2;
  wire          b1_zero_f2;
  wire   [52:0] b_mant_f1;
  wire   [52:0] b_mant_rev_f2;
  wire    [5:0] b_mant_lz_dp_f2;
  wire    [4:0] b_mant_lz_sp_f2;
  wire   [10:0] bias;
  wire          carry_low;
  wire          carry_high;
  wire          div_divbyzero0_f3;
  wire          div_double_prec_f3;
  wire          div_in_flushzero_f3;
  wire          div_invalid0_f3;
  wire   [12:0] div_out0_exp_f3;
  wire   [54:0] div_out0_frac_f3;
  wire          div_out0_sign_f3;
  wire          div_res0_infinite_f3;
  wire          div_res0_nan_f3;
  wire          div_res0_zero_f3;
  wire    [1:0] div_round_mode_f3;
  wire    [6:0] div_shift0_f3;
  wire    [5:0] div_shift1_f3;
  wire          div_stickybit0_f3;
  wire          div_divbyzero1_f3;
  wire          div_invalid1_f3;
  wire    [9:0] div_out1_exp_f3;
  wire   [26:0] div_out1_frac_f3;
  wire          div_out1_sign_f3;
  wire          div_res1_infinite_f3;
  wire          div_res1_nan_f3;
  wire          div_res1_zero_f3;
  wire          div_stickybit1_f3;
  wire          div_ctl_dual_fp_f3;
  wire          divbyzero_op0_f2;
  wire          divbyzero_op1_f2;
  wire          double_prec_f1;
  wire          enable_f1;
  wire          flush_res0_zero_f5;
  wire          flush_res1_zero_f5;
  wire          fz_f3;
  wire          force_dn_fz_f3;
  wire          fused_mac_f1;
  wire          in_flushzero_f2;
  wire          inexact0_f4;
  wire          inexact1_f4;
  wire          invalid0_f2;
  wire          invalid1_f2;
  wire          invalid_op0;
  wire          invalid_op1;
  wire    [5:0] mant0_lz_f2;
  wire    [6:0] mant0_tz_f2;
  wire    [4:0] mant1_lz_f2;
  wire    [5:0] mant1_tz_f2;
  wire    [1:0] mul_dbz;
  wire    [1:0] mul_inv;
  wire    [1:0] mul_inx;
  wire   [63:0] mul_op_a_f1;
  wire   [63:0] mul_op_b_f1;
  wire    [1:0] mul_ovf;
  wire          mul_sel_dp;
  wire          mul_sel_sp_lo;
  wire          mul_sel_sp_hi;
  wire          mul_sel_b_norm;
  wire          mul_sel_b_16_lo;
  wire          mul_sel_b_16_hi;
  wire          mul_sel_b_32_lo;
  wire   [63:0] mul_vector_mask;
  wire    [6:0] mul0_shift;
  wire    [5:0] mul1_shift;
  wire    [1:0] mul_size_f1;
  wire  [105:0] mul_sum_f3;
  wire  [126:0] mul_sum_raw_f3;
  wire    [1:0] mul_halfprec_sum_f3;
  wire    [1:0] mul_udf;
  wire          nan_sel_a0_f2;
  wire          nan_sel_a1_f2;
  wire          nan_sel_b0_f2;
  wire          nan_sel_b1_f2;
  wire          nan0_sign_f2;
  wire          nan1_sign_f2;
  wire  [119:0] nan_val_f2;
  wire          negate_f1;
  wire    [1:0] neon_acc_sat_f3;
  wire          neon_int_op_f1;
  wire          neon_int_op_f4;
  wire          neon_inv_zero_f1;
  wire          neon_mul_qc_f2;
  wire    [3:0] neon_mul_sat_f2;
  wire    [2:0] neon_out_fmt_f1;
  wire          neon_qc_bit_f3;
  wire          neon_round_f1;
  wire          neon_sat_dbl_f1;
  wire    [1:0] neon_sat_width_f3;
  wire    [1:0] neon_underflow_f3;
  wire          neon_vector_op_f1;
  wire   [12:0] neon_vrec_est_exp0_f3;
  wire   [10:0] neon_vrec_est_frc0_f3;
  wire    [9:0] neon_vrec_est_exp1_f3;
  wire   [10:0] neon_vrec_est_frc1_f3;
  wire   [63:0] neon_vrec_est_int_res_f3;
  wire    [1:0] neon_vrec_udf_f3;
  wire   [11:0] norm0_exp_f4;
  wire    [8:0] norm1_exp_f4;
  wire    [8:0] num_bits_discarded0;
  wire    [7:0] num_bits_discarded1;
  wire   [11:0] nxt_norm0_exp_f5;
  wire   [52:0] nxt_norm_frac_f5;
  wire          nxt_out0_sign_f5;
  wire   [11:0] out0_exp;
  wire    [8:0] out1_exp;
  wire          out0_flushzero_f5;
  wire          out1_flushzero_f5;
  wire   [51:0] dp_frac;
  wire   [22:0] sp_frac0;
  wire   [22:0] sp_frac1;
  wire          norm0_exp_zero_f5;
  wire          norm1_exp_zero_f5;
  wire          out0_frac_max;
  wire          out0_frac_zero;
  wire          out0_overflow_f5;
  wire          out0_overflow_no_carry_f4;
  wire          out0_overflow_if_carry_f4;
  wire          out0_sign_f2;
  wire          out1_frac_max;
  wire          out1_frac_zero;
  wire          out1_overflow_f5;
  wire          out1_overflow_no_carry_f4;
  wire          out1_overflow_if_carry_f4;
  wire          out1_sign_f2;
  wire          overflow_to_inf0;
  wire          overflow_to_inf1;
  wire   [12:0] prod0_exp_f2;
  wire    [9:0] prod1_exp_f2;
  wire          res0_denormal;
  wire   [11:0] res0_exp_f4;
  wire   [11:0] res0_exp_p1;
  wire          res0_infinite_f2;
  wire          res0_nan_f2;
  wire          res0_sign_f2;
  wire          res0_two_f2;
  wire          res0_zero_f2;
  wire          res0_zero_f4;
  wire          res1_denormal;
  wire    [8:0] res1_exp_f4;
  wire    [8:0] res1_exp_p1;
  wire          res1_infinite_f2;
  wire          res1_nan_f2;
  wire          res1_sign_f2;
  wire          res1_two_f2;
  wire          res1_zero_f2;
  wire          res1_zero_f4;
  wire          rmode_nearest_f4;
  wire          rmode_posinf_f4;
  wire          rmode_neginf_f4;
  wire   [11:0] round_exp0;
  wire    [8:0] round_exp1;
  wire          round_nearest0_f4;
  wire          round_updown0_f4;
  wire          round_nearest1_f4;
  wire          round_updown1_f4;
  wire    [1:0] round_val_f4;
  wire   [52:0] rounded_frac;
  wire    [6:0] shift_lo_f3;
  wire    [6:0] shift_hi_f3;
  wire  [105:0] shifted_frac;
  wire          shifted_msb0;
  wire          shifted_msb1;
  wire          signed_f1;
  wire          sqrt_f1;
  wire          start_div_f1;
  wire          vrec_est_f2;
  wire          vrec_est_f3;
  wire   [83:0] vrec_est_op_f2;
  wire          vrsqrte_f2;
  wire          saturate_shift0;
  wire          saturate_shift1;
  wire          mul0_stickybit_f3;
  wire          mul1_stickybit_f3;
  wire          def_qnan0_f2;
  wire          def_qnan1_f2;
  wire          fmac_snan0_f2;
  wire          fmac_snan1_f2;
  wire          round_high;
  wire          frac_carry_f5;
  wire   [63:0] neg_neon_sum_f4;
  wire          ctl_dual_fp_f1;
  wire    [1:0] expt_mask;
  wire          advance_pipeline_f1;
  wire          advance_pipeline_f2;
  wire          advance_pipeline_f3;
  wire          advance_pipeline_f4;
  wire    [3:0] zeroes;
  wire  [119:0] neon_acc_val_fwd_f2;
  wire          nxt_round_mode_rn_f5;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // Instantiate the divider module
  // This takes its input data in F2, and returns a result (many cycles later)
  // in F4

  ca53dpu_fp_div u_fp_div (
    .clk_fp_mul           (clk_fp_mul),
    .reset_n              (reset_n),
    .stall_wr_i           (stall_wr_i),
    .advance_pipeline_i   (advance_pipeline_i),
    .start_div_f2_i       (start_div_f2),
    .sqrt_f2_i            (sqrt_f2),
    .double_prec_f2_i     (double_prec_f2),
    .round_mode_f2_i      (round_mode_f2),
    .res0_zero_f2_i       (res0_zero_f2),
    .res0_infinite_f2_i   (res0_infinite_f2),
    .res0_nan_f2_i        (res0_nan_f2),
    .invalid0_f2_i        (invalid0_f2),
    .divbyzero_op0_f2_i   (divbyzero_op0_f2),
    .in_flushzero_f2_i    (in_flushzero_f2),
    .out0_sign_f2_i       (out0_sign_f2),
    .a0_exp_f2_i          (a0_exp_f2),
    .b0_exp_f2_i          (b0_exp_f2),
    .a_mant_f2_i          (a_mant_f2),
    .b_mant_f2_i          (b_mant_f2),
    .a0_mant_lz_f2_i      (a0_mant_lz_f2),
    .b0_mant_lz_f2_i      (b0_mant_lz_f2),
    .nan_sel_a0_f2_i      (nan_sel_a0_f2),
    .nan_sel_b0_f2_i      (nan_sel_b0_f2),
    .res1_zero_f2_i       (res1_zero_f2),
    .res1_infinite_f2_i   (res1_infinite_f2),
    .res1_nan_f2_i        (res1_nan_f2),
    .invalid1_f2_i        (invalid1_f2),
    .divbyzero_op1_f2_i   (divbyzero_op1_f2),
    .out1_sign_f2_i       (out1_sign_f2),
    .a1_exp_f2_i          (a1_exp_f2),
    .b1_exp_f2_i          (b1_exp_f2),
    .a1_mant_lz_f2_i      (a1_mant_lz_f2),
    .b1_mant_lz_f2_i      (b1_mant_lz_f2),
    .nan_sel_a1_f2_i      (nan_sel_a1_f2),
    .nan_sel_b1_f2_i      (nan_sel_b1_f2),
    .ctl_dual_fp_f2_i     (ctl_dual_fp_f2),

    .out0_sign_f3_o        (div_out0_sign_f3),
    .out0_exp_f3_o         (div_out0_exp_f3),
    .out0_frac_f3_o        (div_out0_frac_f3),
    .stickybit0_f3_o       (div_stickybit0_f3),
    .shift0_f3_o           (div_shift0_f3),
    .double_prec_f3_o      (div_double_prec_f3),
    .round_mode_f3_o       (div_round_mode_f3),
    .res0_infinite_f3_o    (div_res0_infinite_f3),
    .res0_zero_f3_o        (div_res0_zero_f3),
    .res0_nan_f3_o         (div_res0_nan_f3),
    .invalid0_f3_o         (div_invalid0_f3),
    .divbyzero0_f3_o       (div_divbyzero0_f3),
    .in_flushzero_f3_o     (div_in_flushzero_f3),
    .div_fp_busy_nxt_cyc_o (div_fp_busy_nxt_cyc_o),
    .stickybit1_f3_o       (div_stickybit1_f3),
    .shift1_f3_o           (div_shift1_f3),
    .out1_exp_f3_o         (div_out1_exp_f3),
    .out1_frac_f3_o        (div_out1_frac_f3),
    .out1_sign_f3_o        (div_out1_sign_f3),
    .res1_infinite_f3_o    (div_res1_infinite_f3),
    .res1_zero_f3_o        (div_res1_zero_f3),
    .res1_nan_f3_o         (div_res1_nan_f3),
    .invalid1_f3_o         (div_invalid1_f3),
    .divbyzero1_f3_o       (div_divbyzero1_f3),
    .ctl_dual_fp_f3_o      (div_ctl_dual_fp_f3)
  );


  // --- F1 stage ---

  // Extract control signals from cmd input
  assign enable_f1         = mul_enable_f1_i & ~flush_ret_i;
  assign double_prec_f1    = mul_ctl_f1_i[`CA53_FP_MUL_PRECISION_BITS];
  assign negate_f1         = mul_ctl_f1_i[`CA53_FP_MUL_NEG_SQRT_BITS] & ~start_div_f1;
  assign fused_mac_f1      = mul_ctl_f1_i[`CA53_FP_MUL_FUSED_MAC_BITS];

  // Extract divider control signals
  assign start_div_f1      = mul_ctl_f1_i[`CA53_FP_MUL_DIVIDE_BITS] & mul_enable_f1_i & ~flush_ret_i;
  assign sqrt_f1           = mul_ctl_f1_i[`CA53_FP_MUL_NEG_SQRT_BITS];

  assign neon_int_op_f1    = mul_ctl_f1_i[`CA53_FP_MUL_NEON_INT_OP_BITS] & mul_enable_f1_i;
  assign signed_f1         = mul_ctl_f1_i[`CA53_FP_MUL_NEON_FIXUP_BITS];
  assign neon_inv_zero_f1  = mul_ctl_f1_i[`CA53_FP_MUL_NEON_INV_IS_ZERO_BITS];
  assign neon_sat_dbl_f1   = mul_ctl_f1_i[`CA53_FP_MUL_NEON_SAT_DBL_BITS];
  assign neon_round_f1     = mul_ctl_f1_i[`CA53_FP_MUL_NEON_ROUND_BITS];    // Also indicates VRSQRTE instead of VRECPE
  assign neon_out_fmt_f1   = mul_ctl_f1_i[`CA53_FP_MUL_NEON_OUT_FMT_BITS];
  assign neon_vector_op_f1 = mul_ctl_f1_i[`CA53_FP_MUL_NEON_VECTOR_OP_BITS];

  assign ctl_dual_fp_f1    = neon_vector_op_f1 & ~double_prec_f1;

  assign a_mant_f1 = (double_prec_f1 | neon_int_op_f1) ? {             ~a0_exp_zero_f1, fml_a_data_f1_i[51: 0]} :
                     ctl_dual_fp_f1                    ? {             ~a1_exp_zero_f1, fml_a_data_f1_i[54:32],
                                                           { 5{1'b0}}, ~a0_exp_zero_f1, fml_a_data_f1_i[22: 0]} :
                                                         { {29{1'b0}}, ~a0_exp_zero_f1, fml_a_data_f1_i[22: 0]};

  assign b_mant_f1 = (double_prec_f1 | neon_int_op_f1) ? {             ~b0_exp_zero_f1, fml_b_data_f1_i[51: 0]} :
                     ctl_dual_fp_f1                    ? {             ~b1_exp_zero_f1, fml_b_data_f1_i[54:32],
                                                           { 5{1'b0}}, ~b0_exp_zero_f1, fml_b_data_f1_i[22: 0]} :
                                                         { {29{1'b0}}, ~b0_exp_zero_f1, fml_b_data_f1_i[22: 0]};


  assign a0_sign_f1 = ((double_prec_f1 | neon_int_op_f1) ? fml_a_data_f1_i[63]
                                                         : fml_a_data_f1_i[31]) ^ (negate_f1 & fused_mac_f1);
  assign b0_sign_f1 =  (double_prec_f1 | neon_int_op_f1) ? fml_b_data_f1_i[63]
                                                         : fml_b_data_f1_i[31];

  assign a1_sign_f1 = fml_a_data_f1_i[63] ^ (negate_f1 & fused_mac_f1);
  assign b1_sign_f1 = fml_b_data_f1_i[63];

  // Extract exponents from input operands
  assign a0_exp_raw = (double_prec_f1 | neon_int_op_f1) ? fml_a_data_f1_i[62:52]
                                                        : {3'b000, fml_a_data_f1_i[30:23]};
  assign b0_exp_raw = (double_prec_f1 | neon_int_op_f1) ? fml_b_data_f1_i[62:52]
                                                        : {3'b000, fml_b_data_f1_i[30:23]};

  assign a1_exp_raw = fml_a_data_f1_i[62:55];
  assign b1_exp_raw = fml_b_data_f1_i[62:55];

  assign a0_exp_zero_f1 = (a0_exp_raw == {11{1'b0}}) & ~neon_int_op_f1;
  assign b0_exp_zero_f1 = (b0_exp_raw == {11{1'b0}}) & ~neon_int_op_f1;

  assign a1_exp_zero_f1 = (a1_exp_raw == {8{1'b0}}) & ~neon_int_op_f1;
  assign b1_exp_zero_f1 = (b1_exp_raw == {8{1'b0}}) & ~neon_int_op_f1;

  assign a0_exp_max_f1 = double_prec_f1 ? &fml_a_data_f1_i[62:52]
                                        : &fml_a_data_f1_i[30:23];
  assign b0_exp_max_f1 = double_prec_f1 ? &fml_b_data_f1_i[62:52]
                                        : &fml_b_data_f1_i[30:23];

  assign a1_exp_max_f1 = &fml_a_data_f1_i[62:55];
  assign b1_exp_max_f1 = &fml_b_data_f1_i[62:55];

  assign a0_exp_f1 = a0_exp_raw | { {10{1'b0}}, a0_exp_zero_f1};
  assign b0_exp_f1 = b0_exp_raw | { {10{1'b0}}, b0_exp_zero_f1};

  assign a1_exp_f1 = a1_exp_raw | { { 7{1'b0}}, a1_exp_zero_f1};
  assign b1_exp_f1 = b1_exp_raw | { { 7{1'b0}}, b1_exp_zero_f1};

  // Select the appropriate bits of the operands for the multipliers

  assign mul_size_f1 = (~neon_int_op_f1 & double_prec_f1)                                        ? 2'b11 :
                       ~neon_int_op_f1                                                           ? 2'b10 :
                       (mul_ctl_f1_i[`CA53_FP_MUL_NEON_TYPE_BITS] == `CA53_NEON_MUL_TYPE_I8)     ? 2'b00 :
                       (mul_ctl_f1_i[`CA53_FP_MUL_NEON_TYPE_BITS] == `CA53_NEON_MUL_TYPE_I16)    ? 2'b01 :
                       (mul_ctl_f1_i[`CA53_FP_MUL_NEON_TYPE_BITS] == `CA53_NEON_MUL_TYPE_I16_LO) ? 2'b01 :
                       (mul_ctl_f1_i[`CA53_FP_MUL_NEON_TYPE_BITS] == `CA53_NEON_MUL_TYPE_I16_HI) ? 2'b01 :
                                                                                                   2'b10;

  assign mul_sel_sp_lo    = ~neon_int_op_f1 & ~double_prec_f1;
  assign mul_sel_sp_hi    = mul_sel_sp_lo & ctl_dual_fp_f1;
  assign mul_sel_dp       = ~neon_int_op_f1 &  double_prec_f1;

  assign mul_sel_b_norm   = neon_int_op_f1 & ((mul_ctl_f1_i[`CA53_FP_MUL_NEON_TYPE_BITS] == `CA53_NEON_MUL_TYPE_I8)  |
                                              (mul_ctl_f1_i[`CA53_FP_MUL_NEON_TYPE_BITS] == `CA53_NEON_MUL_TYPE_I16) |
                                              (mul_ctl_f1_i[`CA53_FP_MUL_NEON_TYPE_BITS] == `CA53_NEON_MUL_TYPE_I32));

  assign mul_sel_b_16_lo  = neon_int_op_f1 & (mul_ctl_f1_i[`CA53_FP_MUL_NEON_TYPE_BITS] == `CA53_NEON_MUL_TYPE_I16_LO);
  assign mul_sel_b_16_hi  = neon_int_op_f1 & (mul_ctl_f1_i[`CA53_FP_MUL_NEON_TYPE_BITS] == `CA53_NEON_MUL_TYPE_I16_HI);

  assign mul_sel_b_32_lo  = neon_int_op_f1 & (mul_ctl_f1_i[`CA53_FP_MUL_NEON_TYPE_BITS] == `CA53_NEON_MUL_TYPE_I32_LO);

  assign mul_vector_mask  = { {32{neon_vector_op_f1}},
                              {16{neon_vector_op_f1 |
                                  (mul_ctl_f1_i[`CA53_FP_MUL_NEON_TYPE_BITS] == `CA53_NEON_MUL_TYPE_I32) |
                                  (mul_ctl_f1_i[`CA53_FP_MUL_NEON_TYPE_BITS] == `CA53_NEON_MUL_TYPE_I32_LO)}},
                              {16{1'b1}} };


  assign mul_op_a_f1 = ({64{mul_sel_sp_lo}}   & { {40{1'b0}}, ~a0_exp_zero_f1, fml_a_data_f1_i[22: 0]})              |
                       ({64{mul_sel_sp_hi}}   & { { 8{1'b0}}, ~a1_exp_zero_f1, fml_a_data_f1_i[54:32], {32{1'b0}} }) |
                       ({64{mul_sel_dp}}      & { {11{1'b0}}, ~a0_exp_zero_f1, fml_a_data_f1_i[51: 0]})              |
                       ({64{neon_int_op_f1}}  & fml_a_data_f1_i & mul_vector_mask);

  assign mul_op_b_f1 = ({64{mul_sel_sp_lo}}   & { {40{1'b0}}, ~b0_exp_zero_f1, fml_b_data_f1_i[22: 0]})              |
                       ({64{mul_sel_sp_hi}}   & { { 8{1'b0}}, ~b1_exp_zero_f1, fml_b_data_f1_i[54:32], {32{1'b0}} }) |
                       ({64{mul_sel_dp}}      & { {11{1'b0}}, ~b0_exp_zero_f1, fml_b_data_f1_i[51: 0]})              |
                       ({64{mul_sel_b_norm}}  & fml_b_data_f1_i)                                                     |
                       ({64{mul_sel_b_16_lo}} & {4{fml_b_data_f1_i[15: 0]}})                                         |
                       ({64{mul_sel_b_16_hi}} & {4{fml_b_data_f1_i[31:16]}})                                         |
                       ({64{mul_sel_b_32_lo}} & {2{fml_b_data_f1_i[31: 0]}});

  always @(posedge clk_fp_mul)
    if (advance_pipeline_i) begin
      enable_f2      <= enable_f1;
      start_div_f2   <= start_div_f1;
      collect_div_f2 <= collect_div_f1_i;
    end

  assign advance_pipeline_f1 = advance_pipeline_i & enable_f1;

  always @(posedge clk_fp_mul)
    if (advance_pipeline_f1) begin
      ctl_dual_fp_f2    <= ctl_dual_fp_f1;
      double_prec_f2    <= double_prec_f1;
      negate_f2         <= negate_f1;
      fused_mac_f2      <= fused_mac_f1;
      mul_size_f2       <= mul_size_f1;
      signed_f2         <= signed_f1;
      a_mant_f2         <= a_mant_f1;
      a0_exp_f2         <= a0_exp_f1;
      a0_exp_max_f2     <= a0_exp_max_f1;
      a1_exp_f2         <= a1_exp_f1;
      a1_exp_max_f2     <= a1_exp_max_f1;
      round_mode_f2     <= round_mode_f1_i;
      fpscr_dn_f2       <= fpscr_dn_i;
      fpscr_fz_f2       <= fpscr_fz_i;
      a0_sign_f2        <= a0_sign_f1;
      a1_sign_f2        <= a1_sign_f1;
      sqrt_f2           <= sqrt_f1;
      op_c_f2           <= fml_c_data_f1_i;
      neon_int_op_f2    <= neon_int_op_f1;
      neon_inv_zero_f2  <= neon_inv_zero_f1;
      neon_sat_dbl_f2   <= neon_sat_dbl_f1;
      neon_round_f2     <= neon_round_f1;
      neon_out_fmt_f2   <= neon_out_fmt_f1;
      force_dn_fz_f2    <= force_dn_fz_f1_i;
      mul_op_a_f2       <= mul_op_a_f1;
      b_mant_f2         <= b_mant_f1;
      b0_exp_f2         <= b0_exp_f1;
      b0_exp_max_f2     <= b0_exp_max_f1;
      b0_sign_f2        <= b0_sign_f1;
      b1_exp_f2         <= b1_exp_f1;
      b1_exp_max_f2     <= b1_exp_max_f1;
      b1_sign_f2        <= b1_sign_f1;
      mul_op_b_f2       <= mul_op_b_f1;
    end

  // --- F2 stage ---

  assign vrec_est_f2      = (neon_out_fmt_f2 == `CA53_NEON_MUL_OUT_FMT_VREC);
  assign vrsqrte_f2       = neon_round_f2;

  assign a0_frac_zero_f2 = double_prec_f2 ? (a_mant_f2[51:0] == {52{1'b0}}) : (a_mant_f2[22: 0] == {23{1'b0}});
  assign b0_frac_zero_f2 = double_prec_f2 ? (b_mant_f2[51:0] == {52{1'b0}}) : (b_mant_f2[22: 0] == {23{1'b0}});

  assign a1_frac_zero_f2 = (a_mant_f2[51:29] == {23{1'b0}});
  assign b1_frac_zero_f2 = (b_mant_f2[51:29] == {23{1'b0}});

  assign a0_exp_zero_f2 = double_prec_f2 ? ~a_mant_f2[52] : ~a_mant_f2[23];
  assign b0_exp_zero_f2 = double_prec_f2 ? ~b_mant_f2[52] : ~b_mant_f2[23];

  assign a1_exp_zero_f2 = ~a_mant_f2[52];
  assign b1_exp_zero_f2 = ~b_mant_f2[52];

  assign a0_zero_f2 = (a0_frac_zero_f2 & a0_exp_zero_f2) | a0_flushzero;
  assign b0_zero_f2 = (b0_frac_zero_f2 & b0_exp_zero_f2) | b0_flushzero;

  assign a1_zero_f2 = (a1_frac_zero_f2 & a1_exp_zero_f2) | a1_flushzero;
  assign b1_zero_f2 = (b1_frac_zero_f2 & b1_exp_zero_f2) | b1_flushzero;

  assign a0_infinite_f2 = a0_exp_max_f2 & a0_frac_zero_f2;
  assign b0_infinite_f2 = b0_exp_max_f2 & b0_frac_zero_f2;

  assign a1_infinite_f2 = a1_exp_max_f2 & a1_frac_zero_f2;
  assign b1_infinite_f2 = b1_exp_max_f2 & b1_frac_zero_f2;

  assign a0_nan_f2 = a0_exp_max_f2 & ~a0_frac_zero_f2 & ~neon_int_op_f2;
  assign b0_nan_f2 = b0_exp_max_f2 & ~b0_frac_zero_f2 & ~neon_int_op_f2;

  assign a1_nan_f2 = a1_exp_max_f2 & ~a1_frac_zero_f2 & ~neon_int_op_f2;
  assign b1_nan_f2 = b1_exp_max_f2 & ~b1_frac_zero_f2 & ~neon_int_op_f2;

  assign a0_snan_f2 = a0_nan_f2 & (double_prec_f2 ? ~a_mant_f2[51] : ~a_mant_f2[22]);
  assign b0_snan_f2 = b0_nan_f2 & (double_prec_f2 ? ~b_mant_f2[51] : ~b_mant_f2[22]);

  assign a1_snan_f2 = a1_nan_f2 & ~a_mant_f2[51];
  assign b1_snan_f2 = b1_nan_f2 & ~b_mant_f2[51];

  // Calculate if any of the inputs are denormal and will be flushed to zero
  assign a0_flushzero     = ~a0_frac_zero_f2 & a0_exp_zero_f2 & (force_dn_fz_f2 | fpscr_fz_f2);
  assign b0_flushzero     = ~b0_frac_zero_f2 & b0_exp_zero_f2 & (force_dn_fz_f2 | fpscr_fz_f2);
  assign a1_flushzero     = ~a1_frac_zero_f2 & a1_exp_zero_f2 & (force_dn_fz_f2 | fpscr_fz_f2);
  assign b1_flushzero     = ~b1_frac_zero_f2 & b1_exp_zero_f2 & (force_dn_fz_f2 | fpscr_fz_f2);
  assign in_flushzero_f2  = a0_flushzero | b0_flushzero |
                            (ctl_dual_fp_f2 & (a1_flushzero | b1_flushzero));

  // Calculate if product will be trivially zero or infinity.
  assign res0_zero_f2 = (start_div_f2 & sqrt_f2) ? a0_zero_f2                    :
                         start_div_f2            ? (a0_zero_f2 | b0_infinite_f2) :
                         vrec_est_f2             ? a0_infinite_f2                :
                                                   ((a0_zero_f2 | b0_zero_f2)
                                                    & ~(neon_inv_zero_f2 & neon_round_f2 & (a0_infinite_f2 | b0_infinite_f2)));

  assign res1_zero_f2 = (start_div_f2 & sqrt_f2) ? a1_zero_f2                    :
                         start_div_f2            ? (a1_zero_f2 | b1_infinite_f2) :
                         vrec_est_f2             ? a1_infinite_f2                :
                                                   ((a1_zero_f2 | b1_zero_f2)
                                                    & ~(neon_inv_zero_f2 & neon_round_f2 & (a1_infinite_f2 | b1_infinite_f2)));

  assign res0_infinite_f2 = (start_div_f2 & sqrt_f2) ? a0_infinite_f2                :
                             start_div_f2            ? (a0_infinite_f2 | b0_zero_f2) :
                             vrec_est_f2             ? a0_zero_f2                    :
                                                       ((a0_infinite_f2 | b0_infinite_f2)
                                                        & ~(neon_inv_zero_f2 & (a0_zero_f2 | b0_zero_f2)));

  assign res1_infinite_f2 = (start_div_f2 & sqrt_f2) ? a1_infinite_f2                :
                             start_div_f2            ? (a1_infinite_f2 | b1_zero_f2) :
                             vrec_est_f2             ? a1_zero_f2                    :
                                                       ((a1_infinite_f2 | b1_infinite_f2)
                                                        & ~(neon_inv_zero_f2 & (a1_zero_f2 | b1_zero_f2)));

  // Generate two on inf*zero for FMULX
  assign res0_two_f2 = neon_inv_zero_f2 & neon_round_f2 & (a0_infinite_f2 | b0_infinite_f2) & (a0_zero_f2 | b0_zero_f2);
  assign res1_two_f2 = neon_inv_zero_f2 & neon_round_f2 & (a1_infinite_f2 | b1_infinite_f2) & (a1_zero_f2 | b1_zero_f2);

  assign invalid_op0 = (start_div_f2 & sqrt_f2) |
                        (vrec_est_f2 & vrsqrte_f2)     ? (a0_sign_f2 & ~a0_zero_f2 & ~a0_nan_f2)                     :
                        start_div_f2                   ? (a0_infinite_f2 & b0_infinite_f2 | a0_zero_f2 & b0_zero_f2) :
                                                         (res0_zero_f2 & res0_infinite_f2);

  assign invalid_op1 = (start_div_f2 & sqrt_f2) |
                        (vrec_est_f2 & vrsqrte_f2)     ? (a1_sign_f2 & ~a1_zero_f2 & ~a1_nan_f2)                     :
                        start_div_f2                   ? (a1_infinite_f2 & b1_infinite_f2 | a1_zero_f2 & b1_zero_f2) :
                                                         (res1_zero_f2 & res1_infinite_f2);

  assign divbyzero_op0_f2 = (start_div_f2 & ~sqrt_f2 & ~res0_nan_f2 & ~a0_infinite_f2 & b0_zero_f2)
                            | (vrec_est_f2 & a0_zero_f2);

  assign divbyzero_op1_f2 = (start_div_f2 & ~sqrt_f2 & ~res1_nan_f2 & ~a1_infinite_f2 & b1_zero_f2)
                            | (vrec_est_f2 & a1_zero_f2);

  // Output is NaN if either operand is NaN or if zero is multiplied by infinity
  assign res0_nan_f2 = ~neon_int_op_f2 & (a0_nan_f2 | b0_nan_f2 | invalid_op0);
  assign res1_nan_f2 = ~neon_int_op_f2 & (a1_nan_f2 | b1_nan_f2 | invalid_op1);

  assign invalid0_f2 = a0_snan_f2 | b0_snan_f2 | invalid_op0;
  assign invalid1_f2 = a1_snan_f2 | b1_snan_f2 | invalid_op1;

  assign nan_sel_a0_f2 = (( a0_snan_f2)              | ( a0_nan_f2  & ~b0_snan_f2)) & ~(force_dn_fz_f2 | fpscr_dn_f2);
  assign nan_sel_b0_f2 = ((~a0_snan_f2 & b0_snan_f2) | (~a0_nan_f2  &  b0_nan_f2))  & ~(force_dn_fz_f2 | fpscr_dn_f2);

  assign nan_sel_a1_f2 = (( a1_snan_f2)              | ( a1_nan_f2  & ~b1_snan_f2)) & ~(force_dn_fz_f2 | fpscr_dn_f2);
  assign nan_sel_b1_f2 = ((~a1_snan_f2 & b1_snan_f2) | (~a1_nan_f2  &  b1_nan_f2))  & ~(force_dn_fz_f2 | fpscr_dn_f2);


  assign nan0_sign_f2 = (nan_sel_a0_f2 & a0_sign_f2) |
                        (nan_sel_b0_f2 & b0_sign_f2);

  assign nan1_sign_f2 = (nan_sel_a1_f2 & a1_sign_f2) |
                        (nan_sel_b1_f2 & b1_sign_f2);

  assign res0_sign_f2 = res0_nan_f2 ? nan0_sign_f2 : (a0_sign_f2 ^ b0_sign_f2);
  assign out0_sign_f2 = res0_sign_f2 ^ (negate_f2 & ~fused_mac_f2);

  assign res1_sign_f2 = res1_nan_f2 ? nan1_sign_f2 : (a1_sign_f2 ^ b1_sign_f2);
  assign out1_sign_f2 = res1_sign_f2 ^ (negate_f2 & ~fused_mac_f2);

  ca53dpu_fp_clz54 u_a_mant_clz_dp(.opa({a_mant_f2, 1'b0}), .res(a_mant_lz_dp_f2));
  ca53dpu_fp_clz54 u_b_mant_clz_dp(.opa({b_mant_f2, 1'b0}), .res(b_mant_lz_dp_f2));

  ca53dpu_fp_clz24 u_a_mant_clz_sp(.opa(a_mant_f2[23:0]), .res(a_mant_lz_sp_f2));
  ca53dpu_fp_clz24 u_b_mant_clz_sp(.opa(b_mant_f2[23:0]), .res(b_mant_lz_sp_f2));

  assign a0_mant_lz_f2 = double_prec_f2 ? a_mant_lz_dp_f2 : {1'b0, a_mant_lz_sp_f2};
  assign b0_mant_lz_f2 = double_prec_f2 ? b_mant_lz_dp_f2 : {1'b0, b_mant_lz_sp_f2};

  assign a1_mant_lz_f2 = a_mant_lz_dp_f2[4:0];
  assign b1_mant_lz_f2 = b_mant_lz_dp_f2[4:0];

  genvar i;
  generate for (i = 0; i < 53; i = i + 1) begin : g_rev_mant
    assign a_mant_rev_f2[i] = a_mant_f2[52 - i];
    assign b_mant_rev_f2[i] = b_mant_f2[52 - i];
  end endgenerate

  // Add one extra zero to these calculations to account for the rounding bit later
  ca53dpu_fp_clz54 u_a0_mant_ctz(.opa({1'b0, a_mant_rev_f2}), .res(a0_mant_tz_f2));
  ca53dpu_fp_clz54 u_b0_mant_ctz(.opa({b_mant_rev_f2, 1'b0}), .res(b0_mant_tz_f2));

  ca53dpu_fp_clz24 u_a1_mant_ctz(.opa({1'b0, a_mant_rev_f2[23:1]}), .res(a1_mant_tz_f2));
  ca53dpu_fp_clz24 u_b1_mant_ctz(.opa(b_mant_rev_f2[23:0]),         .res(b1_mant_tz_f2));

  // If both LZ values are nonzero, then the output result will be so tiny that
  // the actual values don't matter, so or them together instead of adding them.
  assign mant0_lz_f2 = a0_mant_lz_f2 | ({6{~vrec_est_f2}} & b0_mant_lz_f2);
  assign mant0_tz_f2 = a0_mant_tz_f2 + b0_mant_tz_f2;

  assign mant1_lz_f2 = a1_mant_lz_f2 | ({5{~vrec_est_f2}} & b1_mant_lz_f2);
  assign mant1_tz_f2 = a1_mant_tz_f2 + b1_mant_tz_f2;

  assign vrec_est_op_f2[83:52] = {32{~neon_int_op_f2}} & {a_mant_f2[51:29], {9{1'b0}} };
  assign vrec_est_op_f2[51: 0] = {52{~neon_int_op_f2}} & (double_prec_f2 ? a_mant_f2[51: 0]
                                                                         : {a_mant_f2[22: 0], {29{1'b0}} });

  assign def_qnan0_f2 = res0_nan_f2 & ~nan_sel_a0_f2 & ~nan_sel_b0_f2 & ~(fused_mac_f2 & invalid0_f2);
  assign def_qnan1_f2 = res1_nan_f2 & ~nan_sel_a1_f2 & ~nan_sel_b1_f2 & ~(fused_mac_f2 & invalid1_f2);

  // If this operation is a Fused MAC with input operands of infinity and zero,
  // pass a signalling NaN to the ALU pipe so that QNaN+0*Inf returns the default NaN
  // Do this by setting a bit below the lowest precision bit
  assign fmac_snan0_f2 = fused_mac_f2 & invalid0_f2;
  assign fmac_snan1_f2 = fused_mac_f2 & invalid1_f2;

  assign nan_val_f2 = ({120{nan_sel_a0_f2 &  double_prec_f2}} & { {15{1'b0}}, 1'b1, ~fused_mac_f2 | a_mant_f2[51], a_mant_f2[50: 0], 1'b0, {51{1'b0}} }) |
                      ({120{nan_sel_b0_f2 &  double_prec_f2}} & { {15{1'b0}}, 1'b1, ~fused_mac_f2 | b_mant_f2[51], b_mant_f2[50: 0], 1'b0, {51{1'b0}} }) |
                      ({120{def_qnan0_f2  &  double_prec_f2}} & { {15{1'b0}}, 1'b1, 1'b1,                          {51{1'b0}},       1'b0, {51{1'b0}} }) |
                      ({120{fmac_snan0_f2 &  double_prec_f2}} & { {15{1'b0}}, 1'b1, 1'b0,                          {51{1'b0}},       1'b1, {51{1'b0}} }) |
                      ({120{nan_sel_a0_f2 & ~double_prec_f2}} & { {73{1'b0}}, 1'b1, ~fused_mac_f2 | a_mant_f2[22], a_mant_f2[21: 0], 1'b0, {22{1'b0}} }) |
                      ({120{nan_sel_b0_f2 & ~double_prec_f2}} & { {73{1'b0}}, 1'b1, ~fused_mac_f2 | b_mant_f2[22], b_mant_f2[21: 0], 1'b0, {22{1'b0}} }) |
                      ({120{def_qnan0_f2  & ~double_prec_f2}} & { {73{1'b0}}, 1'b1, 1'b1,                          {22{1'b0}},       1'b0, {22{1'b0}} }) |
                      ({120{fmac_snan0_f2 & ~double_prec_f2}} & { {73{1'b0}}, 1'b1, 1'b0,                          {22{1'b0}},       1'b1, {22{1'b0}} }) |
                      ({120{nan_sel_a1_f2 &  ctl_dual_fp_f2}} & { {25{1'b0}}, 1'b1, ~fused_mac_f2 | a_mant_f2[51], a_mant_f2[50:29], 1'b0, {70{1'b0}} }) |
                      ({120{nan_sel_b1_f2 &  ctl_dual_fp_f2}} & { {25{1'b0}}, 1'b1, ~fused_mac_f2 | b_mant_f2[51], b_mant_f2[50:29], 1'b0, {70{1'b0}} }) |
                      ({120{def_qnan1_f2  &  ctl_dual_fp_f2}} & { {25{1'b0}}, 1'b1, 1'b1,                          {22{1'b0}},       1'b0, {70{1'b0}} }) |
                      ({120{fmac_snan1_f2 &  ctl_dual_fp_f2}} & { {25{1'b0}}, 1'b1, 1'b0,                          {22{1'b0}},       1'b1, {70{1'b0}} }) |
                      ({120{vrec_est_f2   & ~res0_nan_f2}}    & { {68{1'b0}}, vrec_est_op_f2[51: 0]                                                   }) |
                      ({120{vrec_est_f2   & ~res1_nan_f2}}    & { {16{1'b0}}, vrec_est_op_f2[83:52], {72{1'b0}}                                       });

  // Calculate the exponent of the result before normalization
  assign bias = double_prec_f2  ? 11'h3FF :
                                  11'h07F;

  assign prod0_exp_f2 = {2'b00, a0_exp_f2} + b0_exp_f2 - bias;
  assign prod1_exp_f2 = {2'b00, a1_exp_f2} + b1_exp_f2 - 7'h7F;

  assign acc0_exp_f2 = vrec_est_f2 ? {2'b00, a0_exp_f2} :
                                     prod0_exp_f2;
  assign acc1_exp_f2 = vrec_est_f2 ? {2'b00, a1_exp_f2} :
                                     prod1_exp_f2;

  always @*
    case (neon_out_fmt_f2)
      `CA53_NEON_MUL_OUT_FMT_4_8:
        neon_acc_val_f2 = {       op_c_f2[63:56], 8'h00, op_c_f2[55:48],
                           8'h00, op_c_f2[47:40], 8'h00, op_c_f2[39:32],
                           8'h00, op_c_f2[31:24], 8'h00, op_c_f2[23:16],
                           8'h00, op_c_f2[15: 8], 8'h00, op_c_f2[ 7: 0]};
      `CA53_NEON_MUL_OUT_FMT_4_16:
        neon_acc_val_f2 = {   8'h00, op_c_f2[63:48],
                           16'h0000, op_c_f2[47:32],
                           16'h0000, op_c_f2[31:16],
                           16'h0000, op_c_f2[15: 0]};
      `CA53_NEON_MUL_OUT_FMT_2_32:
        neon_acc_val_f2 = neon_sat_dbl_f2 ? { {56{1'b0}}, op_c_f2[63], op_c_f2[63:33], op_c_f2[31], op_c_f2[31: 1]}
                                          : { {56{1'b0}}, op_c_f2[63:32], op_c_f2[31: 0]};
      `CA53_NEON_MUL_OUT_FMT_2_16_H:
        neon_acc_val_f2 = { { 9{1'b0}}, neon_round_f2 & ~neon_mul_sat_f2[3], {14{1'b0}},
                            {17{1'b0}}, neon_round_f2 & ~neon_mul_sat_f2[2], {14{1'b0}},
                            {17{1'b0}}, neon_round_f2 & ~neon_mul_sat_f2[1], {14{1'b0}},
                            {17{1'b0}}, neon_round_f2 & ~neon_mul_sat_f2[0], {14{1'b0}} };
      `CA53_NEON_MUL_OUT_FMT_32_L:
        neon_acc_val_f2 = {  24'h000000, op_c_f2[63:32],
                           32'h00000000, op_c_f2[31: 0]};
      `CA53_NEON_MUL_OUT_FMT_32_H:
        neon_acc_val_f2 = { {25{1'b0}}, neon_round_f2 & ~neon_mul_sat_f2[2], {30{1'b0}},
                            {33{1'b0}}, neon_round_f2 & ~neon_mul_sat_f2[0], {30{1'b0}} };
      `CA53_NEON_MUL_OUT_FMT_64:
        neon_acc_val_f2 = neon_sat_dbl_f2 ? { {56{1'b0}}, op_c_f2[63], op_c_f2[63: 1]} : { {56{1'b0}}, op_c_f2};
      `CA53_NEON_MUL_OUT_FMT_VREC:
        neon_acc_val_f2 = { {16{1'b0}}, op_c_f2[63:32], {20{1'b0}}, op_c_f2[31:0], {20{1'b0}} };
      default:
        neon_acc_val_f2 = {120{1'bx}};
    endcase

  always @*
    case (neon_out_fmt_f2)
      `CA53_NEON_MUL_OUT_FMT_4_8:  fwd_mask = 120'hFF00FF00FF00FF00FF00FF00FF00FF;
      `CA53_NEON_MUL_OUT_FMT_4_16: fwd_mask = 120'h00FFFF0000FFFF0000FFFF0000FFFF;
      `CA53_NEON_MUL_OUT_FMT_2_32: fwd_mask = 120'h00000000000000FFFFFFFFFFFFFFFF;
      `CA53_NEON_MUL_OUT_FMT_32_L: fwd_mask = 120'h000000FFFFFFFF00000000FFFFFFFF;
      `CA53_NEON_MUL_OUT_FMT_64:   fwd_mask = 120'h00000000000000FFFFFFFFFFFFFFFF;
      default: fwd_mask = {120{1'bx}};
    endcase

  assign neon_acc_val_fwd_f2 = fp_mul_fwd_f2_i ? (mul_sum_raw_f3[119:0] & fwd_mask)
                                               : neon_acc_val_f2;

  // If not performing saturating doubling multiply, set the half-precision bit
  // to 1 to force carries to be propagated
  assign acc_halfprec_bits_f2[1] = ((neon_out_fmt_f2 == `CA53_NEON_MUL_OUT_FMT_2_32) & neon_sat_dbl_f2)
                                   ? ((fp_mul_fwd_f2_i ? mul_halfprec_sum_f3[1] : op_c_f2[32]) ^ negate_f2)
                                   : 1'b0;

  assign acc_halfprec_bits_f2[0] = neon_sat_dbl_f2
                                   ? ((fp_mul_fwd_f2_i ? mul_halfprec_sum_f3[0] : op_c_f2[0]) ^ negate_f2)
                                   : 1'b0;

  // Detect saturation on the doubling multiply - only occurs if both
  // multiplication operands are max negative (ie. 0x80...0)

  assign zeroes[0]  = (mul_op_a_f2[14: 0] == {15{1'b0}}) & (mul_op_b_f2[14: 0] == {15{1'b0}});
  assign zeroes[1]  = (mul_op_a_f2[30:16] == {15{1'b0}}) & (mul_op_b_f2[30:16] == {15{1'b0}});
  assign zeroes[2]  = (mul_op_a_f2[46:32] == {15{1'b0}}) & (mul_op_b_f2[46:32] == {15{1'b0}});
  assign zeroes[3]  = (mul_op_a_f2[62:48] == {15{1'b0}}) & (mul_op_b_f2[62:48] == {15{1'b0}});

  assign neon_mul_sat_f2[3] = neon_sat_dbl_f2 & ~mul_size_f2[1] &  mul_op_a_f2[63] &  mul_op_b_f2[63] & zeroes[3];

  assign neon_mul_sat_f2[2] = mul_size_f2[1] ? (neon_sat_dbl_f2 &  mul_op_a_f2[63] &  mul_op_b_f2[63] & zeroes[3] &
                                                                  ~mul_op_a_f2[47] & ~mul_op_b_f2[47] & zeroes[2])
                                             : (neon_sat_dbl_f2 &  mul_op_a_f2[47] &  mul_op_b_f2[47] & zeroes[2]);

  assign neon_mul_sat_f2[1] = neon_sat_dbl_f2 & ~mul_size_f2[1] &  mul_op_a_f2[31] &  mul_op_b_f2[31] & zeroes[1];

  assign neon_mul_sat_f2[0] = mul_size_f2[1] ? (neon_sat_dbl_f2 &  mul_op_a_f2[31] &  mul_op_b_f2[31] & zeroes[1] &
                                                                  ~mul_op_a_f2[15] & ~mul_op_b_f2[15] & zeroes[0])
                                             : (neon_sat_dbl_f2 &  mul_op_a_f2[15] &  mul_op_b_f2[15] & zeroes[0]);

  assign neon_mul_qc_f2 = ((neon_out_fmt_f2 == `CA53_NEON_MUL_OUT_FMT_64) |
                           (neon_out_fmt_f2 == `CA53_NEON_MUL_OUT_FMT_2_32)) ? |neon_mul_sat_f2[1:0] : |neon_mul_sat_f2[3:0];

  assign pre_acc_val_f2 = nan_val_f2 | ({120{neon_int_op_f2}} & ({120{negate_f2 ^ (fp_mul_fwd_f2_i & (out0_sign_f3 ^ res0_sign_f3))}} ^ neon_acc_val_fwd_f2));

  always @(posedge clk_fp_mul)
    if (advance_pipeline_i) begin
      enable_f3       <= enable_f2;
      collect_div_f3  <= collect_div_f2;
    end

  assign advance_pipeline_f2 = advance_pipeline_i & enable_f2;

  always @(posedge clk_fp_mul)
    if (advance_pipeline_f2) begin
      ctl_dual_fp_f3          <= ctl_dual_fp_f2;
      double_prec_f3          <= double_prec_f2;
      fused_mac_f3            <= fused_mac_f2;
      mul_size_f3             <= mul_size_f2;
      round_mode_f3           <= round_mode_f2;
      fpscr_fz_f3             <= fpscr_fz_f2;
      res0_infinite_f3        <= res0_infinite_f2;
      res0_two_f3             <= res0_two_f2;
      res0_zero_f3            <= res0_zero_f2;
      res0_nan_f3             <= res0_nan_f2;
      invalid0_f3             <= invalid0_f2;
      out0_sign_f3            <= out0_sign_f2;
      res0_sign_f3            <= res0_sign_f2;
      mant0_lz_f3             <= mant0_lz_f2;
      mant0_tz_f3             <= mant0_tz_f2;
      res1_infinite_f3        <= res1_infinite_f2;
      res1_two_f3             <= res1_two_f2;
      res1_zero_f3            <= res1_zero_f2;
      res1_nan_f3             <= res1_nan_f2;
      invalid1_f3             <= invalid1_f2;
      out1_sign_f3            <= out1_sign_f2;
      res1_sign_f3            <= res1_sign_f2;
      mant1_lz_f3             <= mant1_lz_f2;
      mant1_tz_f3             <= mant1_tz_f2;
      in_flushzero_f3         <= in_flushzero_f2;
      pre_acc_val_f3          <= pre_acc_val_f2;
      acc_halfprec_bits_f3    <= acc_halfprec_bits_f2;
      acc0_exp_f3             <= acc0_exp_f2;
      acc1_exp_f3             <= acc1_exp_f2;
      neon_int_op_f3          <= neon_int_op_f2;
      neon_out_fmt_f3         <= neon_out_fmt_f2;
      neon_mul_qc_f3          <= neon_mul_qc_f2;
      neon_vrsqrte_f3         <= vrsqrte_f2;
      neon_divbyzero_op0_f3   <= divbyzero_op0_f2;
      neon_divbyzero_op1_f3   <= divbyzero_op1_f2;
      raw_force_dn_fz_f3      <= force_dn_fz_f2;
      neon_mul_sat_f3         <= neon_mul_sat_f2;
      neon_sat_dbl_f3         <= neon_sat_dbl_f2;
    end

  // --- F3 stage ---

  assign vrec_est_f3 = (neon_out_fmt_f3 == `CA53_NEON_MUL_OUT_FMT_VREC);

  assign force_dn_fz_f3 = raw_force_dn_fz_f3 & ~collect_div_f3;
  assign fz_f3 = force_dn_fz_f3 | fpscr_fz_f3;

  assign array_en_f1 = enable_f1 & advance_pipeline_i;
  assign array_en_f2 = enable_f2 & advance_pipeline_i;

  ca53dpu_fp_mul_array u_mul_array (
    .clk_fp_mul             (clk_fp_mul),
    .reset_n                (reset_n),
    .array_en_f1_i          (array_en_f1),
    .array_en_f2_i          (array_en_f2),
    .mul_size_f1_i          (mul_size_f1),
    .mul_size_f2_i          (mul_size_f2),
    .signed_f2_i            (signed_f2),
    .mul_size_f3_i          (mul_size_f3),
    .mul_op_a_f1_i          (mul_op_a_f1),
    .mul_op_a_f2_i          (mul_op_a_f2),
    .mul_op_b_f2_i          (mul_op_b_f2),
    .neon_mul_sat_f3_i      (neon_mul_sat_f3),
    .acc_val_f3_i           (pre_acc_val_f3),
    .acc_halfprec_bits_f3_i (acc_halfprec_bits_f3),
    .mul_sum_raw_f3_o       (mul_sum_raw_f3),
    .mul_halfprec_sum_f3_o  (mul_halfprec_sum_f3)
  );


  ca53dpu_neon_vrec_est #(.EXP_SIZE(11)) u_vrec_est0 (
    .int_op_f3_i            (neon_int_op_f3),
    .neon_rsqrte_f3_i       (neon_vrsqrte_f3),
    .double_prec_f3_i       (double_prec_f3),
    .fz_f3_i                (fz_f3),
    .a_exp_f3_i             (acc0_exp_f3[10:0]),
    .a_frac_f3_i            (pre_acc_val_f3[51: 0]),
    .mant_lz_f3_i           (mant0_lz_f3[5:0]),

    .vrec_est_int_res_f3_o  (neon_vrec_est_int_res_f3[31:0]),
    .vrec_est_frc_f3_o      (neon_vrec_est_frc0_f3),
    .vrec_est_exp_f3_o      (neon_vrec_est_exp0_f3),
    .vrec_udf_f3_o          (neon_vrec_udf_f3[0])
  );

  ca53dpu_neon_vrec_est #(.EXP_SIZE(8)) u_vrec_est1 (
    .int_op_f3_i            (neon_int_op_f3),
    .neon_rsqrte_f3_i       (neon_vrsqrte_f3),
    .double_prec_f3_i       (1'b0),
    .fz_f3_i                (fz_f3),
    .a_exp_f3_i             (acc1_exp_f3[7:0]),
    .a_frac_f3_i            ({pre_acc_val_f3[103:72], {20{1'b0}} }),
    .mant_lz_f3_i           ({1'b0, mant1_lz_f3[4:0]}),

    .vrec_est_int_res_f3_o  (neon_vrec_est_int_res_f3[63:32]),
    .vrec_est_frc_f3_o      (neon_vrec_est_frc1_f3),
    .vrec_est_exp_f3_o      (neon_vrec_est_exp1_f3),
    .vrec_udf_f3_o          (neon_vrec_udf_f3[1])
  );

  assign neon_underflow_f3 = {2{vrec_est_f3 & ~collect_div_f3}} & neon_vrec_udf_f3[1:0];

  // Extract the appropriate bits from the adder output to generate the result

  always @*
    case (neon_out_fmt_f3)
      `CA53_NEON_MUL_OUT_FMT_4_8:
          neon_mul_sum_f3 = {mul_sum_raw_f3[119:112], mul_sum_raw_f3[103:96], mul_sum_raw_f3[87:80], mul_sum_raw_f3[71:64],
                             mul_sum_raw_f3[ 55: 48], mul_sum_raw_f3[ 39:32], mul_sum_raw_f3[23:16], mul_sum_raw_f3[7:0]};
      `CA53_NEON_MUL_OUT_FMT_4_16:
          neon_mul_sum_f3 = {mul_sum_raw_f3[111:96], mul_sum_raw_f3[79:64], mul_sum_raw_f3[47:32], mul_sum_raw_f3[15:0]};
      `CA53_NEON_MUL_OUT_FMT_2_32:
          neon_mul_sum_f3 = neon_sat_dbl_f3 ? {mul_sum_raw_f3[62:32], mul_halfprec_sum_f3[1],
                                               mul_sum_raw_f3[30: 0], mul_halfprec_sum_f3[0]}
                                            : mul_sum_raw_f3[63:0];
      `CA53_NEON_MUL_OUT_FMT_2_16_H:
          neon_mul_sum_f3 = {mul_sum_raw_f3[126:111], mul_sum_raw_f3[94:79], mul_sum_raw_f3[62:47], mul_sum_raw_f3[30:15]};
      `CA53_NEON_MUL_OUT_FMT_32_L:
          neon_mul_sum_f3 = {mul_sum_raw_f3[95:64], mul_sum_raw_f3[31:0]};
      `CA53_NEON_MUL_OUT_FMT_32_H:
          neon_mul_sum_f3 = {mul_sum_raw_f3[126:95], mul_sum_raw_f3[62:31]};
      `CA53_NEON_MUL_OUT_FMT_64:
          neon_mul_sum_f3 = neon_sat_dbl_f3 ? {mul_sum_raw_f3[62:0], mul_halfprec_sum_f3[0]}
                                            : mul_sum_raw_f3[63:0];
      `CA53_NEON_MUL_OUT_FMT_VREC:
          neon_mul_sum_f3 = neon_vrec_est_int_res_f3;
      default:
          neon_mul_sum_f3 = {64{1'bx}};
    endcase

  assign mul_sum_f3[ 47: 0] = res0_nan_f3                     ? pre_acc_val_f3[ 47: 0]                     :
                              res0_two_f3                     ? {1'b0, ~double_prec_f3, {46{1'b0}} }       :
                              (vrec_est_f3 & ~double_prec_f3) ? {1'b0, neon_vrec_est_frc0_f3, {36{1'b0}} } :
                              vrec_est_f3                     ? {48{1'b0}}                                 :
                                                                mul_sum_raw_f3[ 47: 0];

  assign mul_sum_f3[105:48] = (ctl_dual_fp_f3 ? res1_nan_f3 : res0_nan_f3)  ? pre_acc_val_f3[105:48]                        :
                              (ctl_dual_fp_f3 & res1_two_f3)                ? {12'h001, {46{1'b0}} }                        :
                              (double_prec_f3 & res0_two_f3)                ? {2'b01, {56{1'b0}} }                          :
                              (vrec_est_f3 & ctl_dual_fp_f3)                ? {11'h000, neon_vrec_est_frc1_f3, {36{1'b0}} } :
                              (vrec_est_f3 & double_prec_f3)                ? {1'b0,    neon_vrec_est_frc0_f3, {46{1'b0}} } :
                              ctl_dual_fp_f3                                ? mul_sum_raw_f3[121:64]                        :
                                                                              mul_sum_raw_f3[105:48];

  // Detect whether the accumulate overflowed and must be saturated
  // Only signed multiplies can saturate, so signed overflow only is detected

  assign neon_acc_sat_f3[0] = ((neon_out_fmt_f3 == `CA53_NEON_MUL_OUT_FMT_32_L) | (neon_out_fmt_f3 == `CA53_NEON_MUL_OUT_FMT_32_H))
                                ? neon_acc_sat_f3[1]
                                : (neon_sat_dbl_f3 & (mul_sum_raw_f3[31] != mul_sum_raw_f3[30]));
  assign neon_acc_sat_f3[1] = (neon_sat_dbl_f3 & (mul_sum_raw_f3[63] != mul_sum_raw_f3[62]));

  assign neon_sat_width_f3[1] = (neon_out_fmt_f3 == `CA53_NEON_MUL_OUT_FMT_2_32) |
                                (neon_out_fmt_f3 == `CA53_NEON_MUL_OUT_FMT_32_L) |
                                (neon_out_fmt_f3 == `CA53_NEON_MUL_OUT_FMT_32_H) |
                                (neon_out_fmt_f3 == `CA53_NEON_MUL_OUT_FMT_64);

  assign neon_sat_width_f3[0] = (neon_out_fmt_f3 == `CA53_NEON_MUL_OUT_FMT_2_16_H) |
                                (neon_out_fmt_f3 == `CA53_NEON_MUL_OUT_FMT_64);

  assign neon_qc_bit_f3 = neon_int_op_f3 & ~collect_div_f3 &
                          (neon_mul_qc_f3 | neon_acc_sat_f3[1] | ((neon_sat_width_f3 != 2'b11) & neon_acc_sat_f3[0]));

  assign acc0_renorm_exp_f3 = acc0_exp_f3 - mant0_lz_f3;
  assign acc1_renorm_exp_f3 = acc1_exp_f3 - mant1_lz_f3;

  assign mul_acc0_exp_f3 = vrec_est_f3 ? neon_vrec_est_exp0_f3                                        :
                           res0_two_f3 ? { 2'b00, double_prec_f3, 2'b00, ~double_prec_f3, {7{1'b0}} } :
                                         acc0_renorm_exp_f3;
  assign mul_acc1_exp_f3 = vrec_est_f3 ? neon_vrec_est_exp1_f3 :
                           res1_two_f3 ? 10'h080               :
                                          acc1_renorm_exp_f3;

  // If biased exponent of product (before normalization)
  // is very negative (<= -64 for dp, <= -32 for sp), saturate ultimate shift value
  assign saturate_shift0 = acc0_exp_f3[12] & ((~&acc0_exp_f3[11:6]) |
                                              (~double_prec_f3 & ~acc0_exp_f3[5]) |
                                              (~|acc0_exp_f3[5:0]));

  assign saturate_shift1 = acc1_exp_f3[ 9] & ((~&acc1_exp_f3[8:5]) | (~|acc1_exp_f3[4:0]));

  assign mul0_shift = (res0_nan_f3 | res0_two_f3)             ? 7'd0                      :
                      saturate_shift0                         ? 7'd64                     : // -64
                      (acc0_renorm_exp_f3[12] |
                       (acc0_renorm_exp_f3[11:0] == 12'h000)) ? (acc0_exp_f3[6:0] - 1'b1) :
                                                                {1'b0, mant0_lz_f3};

  assign mul1_shift = (res1_nan_f3 | res1_two_f3)             ? 6'd0                      :
                      saturate_shift1                         ? 6'd32                     : // -32
                      (acc1_renorm_exp_f3[9] |
                       (acc1_renorm_exp_f3[8:0] == 9'h000))   ? (acc1_exp_f3[5:0] - 1'b1) :
                                                                {1'b0, mant1_lz_f3};

  assign num_bits_discarded0 = (fused_mac_f3 ? (double_prec_f3 ? 9'd1  : 9'd1)
                                             : (double_prec_f3 ? 9'd52 : 9'd23))
                                - {{2{mul0_shift[6]}}, mul0_shift};

  assign num_bits_discarded1 = (fused_mac_f3 ? 8'd1 : 8'd23)
                                - {{2{mul1_shift[5]}}, mul1_shift};

  assign mul0_stickybit_f3 = ~num_bits_discarded0[8] & ({1'b0, mant0_tz_f3} < num_bits_discarded0[7:0]);
  assign mul1_stickybit_f3 = ~num_bits_discarded1[7] & ({1'b0, mant1_tz_f3} < num_bits_discarded1[6:0]);

  assign shift_lo_f3 = mul0_shift;
  assign shift_hi_f3 = ctl_dual_fp_f3 ? {mul1_shift[5], mul1_shift} : mul0_shift;

  // If this is a special to collect the result of a divide, mux in the output of the divider
  always @*
    case ({neon_int_op_f3, collect_div_f3})
      2'b10: begin
        nxt_mul_sum_f4        = { {42{1'b0}}, neon_mul_sum_f3};
        nxt_sum0_stickybit_f4 = 1'b0;
        nxt_shift_lo_f4       = 7'd26;
        nxt_acc0_exp_f4       = 13'h0000;
        nxt_sum1_stickybit_f4 = 1'b0;
        nxt_shift_hi_f4       = 7'd26;
        nxt_acc1_exp_f4       = 10'h000;
        nxt_double_prec_f4    = 1'b1;
        nxt_out0_sign_f4      = 1'b0;
        nxt_out1_sign_f4      = 1'b0;
        nxt_round_mode_f4     = 2'b00;
        nxt_res0_infinite_f4  = 1'b0;
        nxt_res0_zero_f4      = 1'b0;
        nxt_res0_nan_f4       = 1'b0;
        nxt_invalid0_f4       = 1'b0;
        nxt_divbyzero_op0_f4  = 1'b0;
        nxt_res1_infinite_f4  = 1'b0;
        nxt_res1_zero_f4      = 1'b0;
        nxt_res1_nan_f4       = 1'b0;
        nxt_invalid1_f4       = 1'b0;
        nxt_divbyzero_op1_f4  = 1'b0;
        nxt_in_flushzero_f4   = 1'b0;

        // Store the value of the negate control signal in res_sign_f4
        nxt_res0_sign_f4      = (out0_sign_f3 ^ res0_sign_f3);
        nxt_res1_sign_f4      = 1'b0;
        nxt_fused_mac_f4      = 1'b0;
        nxt_ctl_dual_fp_f4    = 1'b0;
      end

      2'b00: begin
        nxt_mul_sum_f4        = mul_sum_f3;
        nxt_sum0_stickybit_f4 = mul0_stickybit_f3;
        nxt_shift_lo_f4       = shift_lo_f3;
        nxt_acc0_exp_f4       = mul_acc0_exp_f3;
        nxt_sum1_stickybit_f4 = mul1_stickybit_f3;
        nxt_shift_hi_f4       = shift_hi_f3;
        nxt_acc1_exp_f4       = mul_acc1_exp_f3;
        nxt_double_prec_f4    = double_prec_f3;
        nxt_out0_sign_f4      = out0_sign_f3;
        nxt_res0_sign_f4      = res0_sign_f3;
        nxt_out1_sign_f4      = out1_sign_f3;
        nxt_res1_sign_f4      = res1_sign_f3;
        nxt_round_mode_f4     = round_mode_f3;
        nxt_res0_infinite_f4  = res0_infinite_f3;
        nxt_res0_zero_f4      = res0_zero_f3;
        nxt_res0_nan_f4       = res0_nan_f3;
        nxt_invalid0_f4       = invalid0_f3;
        nxt_divbyzero_op0_f4  = neon_divbyzero_op0_f3;
        nxt_res1_infinite_f4  = res1_infinite_f3;
        nxt_res1_zero_f4      = res1_zero_f3;
        nxt_res1_nan_f4       = res1_nan_f3;
        nxt_invalid1_f4       = invalid1_f3;
        nxt_divbyzero_op1_f4  = neon_divbyzero_op1_f3;
        nxt_in_flushzero_f4   = in_flushzero_f3;
        nxt_fused_mac_f4      = fused_mac_f3;
        nxt_ctl_dual_fp_f4    = ctl_dual_fp_f3;
      end

      2'b01, 2'b11: begin
        nxt_mul_sum_f4        = div_double_prec_f3 ? {div_out0_frac_f3, {51{1'b0}} }
                                                   : { {10{1'b0}}, div_out1_frac_f3, {21{1'b0}}, div_out0_frac_f3[54:27], {20{1'b0}} };
        nxt_sum0_stickybit_f4 = div_stickybit0_f3;
        nxt_shift_lo_f4       = div_shift0_f3;
        nxt_shift_hi_f4       = div_ctl_dual_fp_f3 ? {div_shift1_f3[5],div_shift1_f3}
                                                   : div_shift0_f3;
        nxt_acc0_exp_f4       = div_out0_exp_f3;
        nxt_out0_sign_f4      = div_out0_sign_f3;
        nxt_res0_sign_f4      = div_out0_sign_f3; // div/sqrt can't be inverted, so same as out_sign
        nxt_res1_sign_f4      = div_out1_sign_f3;
        nxt_double_prec_f4    = div_double_prec_f3;
        nxt_round_mode_f4     = div_round_mode_f3;
        nxt_res0_infinite_f4  = div_res0_infinite_f3;
        nxt_res0_zero_f4      = div_res0_zero_f3;
        nxt_res0_nan_f4       = div_res0_nan_f3;
        nxt_invalid0_f4       = div_invalid0_f3;
        nxt_divbyzero_op0_f4  = div_divbyzero0_f3;
        nxt_in_flushzero_f4   = div_in_flushzero_f3;
        nxt_fused_mac_f4      = 1'b0;
        nxt_sum1_stickybit_f4 = div_stickybit1_f3;
        nxt_acc1_exp_f4       = div_out1_exp_f3;
        nxt_out1_sign_f4      = div_out1_sign_f3;
        nxt_res1_infinite_f4  = div_res1_infinite_f3;
        nxt_res1_zero_f4      = div_res1_zero_f3;
        nxt_res1_nan_f4       = div_res1_nan_f3;
        nxt_invalid1_f4       = div_invalid1_f3;
        nxt_divbyzero_op1_f4  = div_divbyzero1_f3;
        nxt_ctl_dual_fp_f4    = div_ctl_dual_fp_f3;
      end

      default:
      begin
        nxt_mul_sum_f4        = {106{1'bx}};
        nxt_sum0_stickybit_f4 = 1'bx;
        nxt_shift_lo_f4       = {7{1'bx}};
        nxt_acc0_exp_f4       = {13{1'bx}};
        nxt_sum1_stickybit_f4 = 1'bx;
        nxt_shift_hi_f4       = {7{1'bx}};
        nxt_acc1_exp_f4       = {10{1'bx}};
        nxt_double_prec_f4    = 1'bx;
        nxt_out0_sign_f4      = 1'bx;
        nxt_res0_sign_f4      = 1'bx;
        nxt_out1_sign_f4      = 1'bx;
        nxt_res1_sign_f4      = 1'bx;
        nxt_round_mode_f4     = {2{1'bx}};
        nxt_res0_infinite_f4  = 1'bx;
        nxt_res0_zero_f4      = 1'bx;
        nxt_res0_nan_f4       = 1'bx;
        nxt_invalid0_f4       = 1'bx;
        nxt_divbyzero_op0_f4  = 1'bx;
        nxt_res1_infinite_f4  = 1'bx;
        nxt_res1_zero_f4      = 1'bx;
        nxt_res1_nan_f4       = 1'bx;
        nxt_invalid1_f4       = 1'bx;
        nxt_divbyzero_op1_f4  = 1'bx;
        nxt_in_flushzero_f4   = 1'bx;
        nxt_fused_mac_f4      = 1'bx;
        nxt_ctl_dual_fp_f4    = 1'bx;
      end
    endcase

  always @(posedge clk_fp_mul)
    if (advance_pipeline_i) begin
      enable_f4       <= enable_f3;
      collect_div_f4  <= collect_div_f3;
    end

  assign advance_pipeline_f3 = advance_pipeline_i & (enable_f3 | collect_div_f3);

  always @(posedge clk_fp_mul)
    if (advance_pipeline_f3) begin
      ctl_dual_fp_f4      <= nxt_ctl_dual_fp_f4;
      sum0_stickybit_f4   <= nxt_sum0_stickybit_f4;
      sum1_stickybit_f4   <= nxt_sum1_stickybit_f4;
      double_prec_f4      <= nxt_double_prec_f4;
      fused_mac_f4        <= nxt_fused_mac_f4;
      round_mode_f4       <= nxt_round_mode_f4;
      res0_infinite_f4    <= nxt_res0_infinite_f4;
      res0_nan_f4         <= nxt_res0_nan_f4;
      invalid0_f4         <= nxt_invalid0_f4;
      divbyzero_op0_f4    <= nxt_divbyzero_op0_f4;
      res1_infinite_f4    <= nxt_res1_infinite_f4;
      res1_nan_f4         <= nxt_res1_nan_f4;
      invalid1_f4         <= nxt_invalid1_f4;
      divbyzero_op1_f4    <= nxt_divbyzero_op1_f4;
      in_flushzero_f4     <= nxt_in_flushzero_f4;
      shift_lo_f4         <= nxt_shift_lo_f4;
      shift_hi_f4         <= nxt_shift_hi_f4;
      mul_sum_f4          <= nxt_mul_sum_f4;
      acc0_exp_f4         <= nxt_acc0_exp_f4;
      out0_sign_f4        <= nxt_out0_sign_f4;
      res0_sign_f4        <= nxt_res0_sign_f4;
      raw_res0_zero_f4    <= nxt_res0_zero_f4;
      acc1_exp_f4         <= nxt_acc1_exp_f4;
      out1_sign_f4        <= nxt_out1_sign_f4;
      res1_sign_f4        <= nxt_res1_sign_f4;
      raw_res1_zero_f4    <= nxt_res1_zero_f4;
      raw_neon_int_op_f4  <= neon_int_op_f3;
      neon_acc_sat_f4     <= neon_acc_sat_f3;
      neon_sat_width_f4   <= neon_sat_width_f3;
      neon_qc_bit_f4      <= neon_qc_bit_f3;
      neon_underflow_f4   <= neon_underflow_f3;
      force_dn_fz_f4      <= force_dn_fz_f3;
    end

  // --- F4 stage ---

  assign neon_int_op_f4 = raw_neon_int_op_f4 & ~collect_div_f4;

  // Do a shift to get the appropriate bits
  // This gives a value in the range [1,4)
  ca53dpu_fp_shift7 u_mul_shift1 (
    .data_i         (mul_sum_f4[105:0]),
    .shift_lo_i     (shift_lo_f4),
    .shift_hi_i     (shift_hi_f4),
    .ctl_dual_fp_i  (ctl_dual_fp_f4),
    .result_o       (shifted_frac)
  );

  // If the multiply result was >= 2, shift to get it in the range [1,2)
  assign shifted_msb0 = double_prec_f4 ? shifted_frac[105] : shifted_frac[47];
  assign shifted_msb1 = shifted_frac[95];

  always @*
    case ({double_prec_f4, ctl_dual_fp_f4})
      2'b10: begin
        norm_frac_f4[52:0]          = shifted_msb0 ? shifted_frac[105:53] : shifted_frac[104:52];
        norm_frac_subprec_f4[52:1]  = shifted_msb0 ? shifted_frac[ 52: 1] : shifted_frac[ 51: 0];
        norm_frac_subprec_f4[0]     = (shifted_msb0 & shifted_frac[0]) | sum0_stickybit_f4;
        roundbit0_f4                = shifted_msb0 ? shifted_frac[52]     : shifted_frac[51];
        stickybit0_f4               = sum0_stickybit_f4 | (shifted_msb0 & ~fused_mac_f4 & shifted_frac[51]);
        roundbit1_f4                = 1'b0;
        stickybit1_f4               = 1'b0;
      end
      2'b00: begin
        norm_frac_f4[23:0]          = shifted_msb0 ? shifted_frac[47:24] : shifted_frac[46:23];
        norm_frac_subprec_f4[23:1]  = shifted_msb0 ? shifted_frac[23: 1] : shifted_frac[22: 0];
        norm_frac_subprec_f4[0]     = (shifted_msb0 & shifted_frac[0]) | sum0_stickybit_f4;
        roundbit0_f4                = shifted_msb0 ? shifted_frac[23]    : shifted_frac[22];
        stickybit0_f4               = sum0_stickybit_f4 | (shifted_msb0 & ~fused_mac_f4 & shifted_frac[22]) | shifted_frac[21] | shifted_frac[20];

        norm_frac_f4[52:24]         = {29{1'b0}};
        norm_frac_subprec_f4[52:24] = {29{1'b0}};
        roundbit1_f4                = 1'b0;
        stickybit1_f4               = 1'b0;
      end
      2'b01: begin
        norm_frac_f4[23:0]          = shifted_msb0 ? shifted_frac[47:24] : shifted_frac[46:23];
        norm_frac_subprec_f4[23:1]  = shifted_msb0 ? shifted_frac[23: 1] : shifted_frac[22: 0];
        norm_frac_subprec_f4[0]     = (shifted_msb0 & shifted_frac[0]) | sum0_stickybit_f4;
        roundbit0_f4                = shifted_msb0 ? shifted_frac[23]    : shifted_frac[22];
        stickybit0_f4               = sum0_stickybit_f4 | (shifted_msb0 & ~fused_mac_f4 & shifted_frac[22]) | shifted_frac[21] | shifted_frac[20];

        norm_frac_f4[47:24]          = shifted_msb1 ? shifted_frac[95:72] : shifted_frac[94:71];
        norm_frac_subprec_f4[47:25]  = shifted_msb1 ? shifted_frac[71:49] : shifted_frac[70:48];
        norm_frac_subprec_f4[24]     = (shifted_msb1 & shifted_frac[48]) | sum1_stickybit_f4;
        roundbit1_f4                = shifted_msb1 ? shifted_frac[71]    : shifted_frac[70];
        stickybit1_f4               = sum1_stickybit_f4 | (shifted_msb1 & ~fused_mac_f4 & shifted_frac[70]) | shifted_frac[69] | shifted_frac[68];

        norm_frac_f4[52:48]         = {5{1'b0}};
        norm_frac_subprec_f4[52:48] = {5{1'b0}};
      end
      default: begin
        norm_frac_f4[52:0]          = {53{1'bx}};
        norm_frac_subprec_f4[52:0]  = {53{1'bx}};
        roundbit0_f4                = 1'bx;
        stickybit0_f4               = 1'bx;
        roundbit1_f4                = 1'bx;
        stickybit1_f4               = 1'bx;
      end
    endcase

  assign res0_exp_f4 = (acc0_exp_f4[12] | (acc0_exp_f4[11:0] == 12'h000)) ? 12'h001 :
                       (acc0_exp_f4[11] & ~fused_mac_f4)                  ? 12'h7FF :
                                                                            acc0_exp_f4[11:0];

  assign res1_exp_f4 = (acc1_exp_f4[ 9] | (acc1_exp_f4[8:0] == 9'h000)) ? 9'h001 :
                       (acc1_exp_f4[ 8] & ~fused_mac_f4)                ? 9'h1FF :
                                                                          acc1_exp_f4[8:0];

  assign res0_exp_p1 = ((&res0_exp_f4[10:0]) & ~fused_mac_f4) ? 12'h7FF : res0_exp_f4 + 1'b1;
  assign res1_exp_p1 = ((&res1_exp_f4[ 7:0]) & ~fused_mac_f4) ?  9'h1FF : res1_exp_f4 + 1'b1;

  assign norm0_exp_f4 = shifted_msb0 ? res0_exp_p1 : res0_exp_f4;
  assign norm1_exp_f4 = shifted_msb1 ? res1_exp_p1 : res1_exp_f4;

  assign res0_zero_f4 = raw_res0_zero_f4;
  assign res1_zero_f4 = raw_res1_zero_f4;

  assign rmode_nearest_f4 = ({1'b0, round_mode_f4} == `CA53_FP_RMODE_RN);
  assign rmode_posinf_f4  = ({1'b0, round_mode_f4} == `CA53_FP_RMODE_RP);
  assign rmode_neginf_f4  = ({1'b0, round_mode_f4} == `CA53_FP_RMODE_RM);

  assign round_updown0_f4  = ~res0_nan_f4 & ~fused_mac_f4 & ~neon_int_op_f4 & (res0_sign_f4 ? rmode_neginf_f4 : rmode_posinf_f4);
  assign round_nearest0_f4 = ~res0_nan_f4 & ~fused_mac_f4 & ~neon_int_op_f4 & rmode_nearest_f4;

  assign round_updown1_f4  = ~res1_nan_f4 & ~fused_mac_f4 & ~neon_int_op_f4 & (res1_sign_f4 ? rmode_neginf_f4 : rmode_posinf_f4);
  assign round_nearest1_f4 = ~res1_nan_f4 & ~fused_mac_f4 & ~neon_int_op_f4 & rmode_nearest_f4;

  assign round_val_f4[0] = (round_nearest0_f4 & (roundbit0_f4 & (stickybit0_f4 | norm_frac_f4[0]))) |
                           (round_updown0_f4  & (roundbit0_f4 | stickybit0_f4));

  assign round_val_f4[1] = (round_nearest1_f4 & (roundbit1_f4 & (stickybit1_f4 | norm_frac_f4[24]))) |
                           (round_updown1_f4  & (roundbit1_f4 | stickybit1_f4));

  assign inexact0_f4 = (roundbit0_f4 | stickybit0_f4) & ~neon_int_op_f4 & ~fused_mac_f4;
  assign inexact1_f4 = (roundbit1_f4 | stickybit1_f4) & ~neon_int_op_f4 & ~fused_mac_f4;

  // Result definitely overflows
  assign out0_overflow_no_carry_f4 = (double_prec_f4 ?  (&norm0_exp_f4[10:0])
                                                     : ((&norm0_exp_f4[ 7:0]) | (|norm0_exp_f4[10:8])))
                                     & ~neon_int_op_f4 & ~fused_mac_f4;

  assign out1_overflow_no_carry_f4 = (&norm1_exp_f4[ 7:0]) & ~neon_int_op_f4 & ~fused_mac_f4;


  // Result overflows if rounding generates a carry
  assign out0_overflow_if_carry_f4 = (double_prec_f4 ? (&norm0_exp_f4[10:1])
                                                     : (&norm0_exp_f4[ 7:1]))
                                     & ~neon_int_op_f4 & ~fused_mac_f4;

  assign out1_overflow_if_carry_f4 = (&norm1_exp_f4[ 7:1]) & ~neon_int_op_f4 & ~fused_mac_f4;

  // Saturate the Neon integer result if necessary
  // Saturation is peformed before the negation for a VMLS

  always @*
    case (neon_sat_width_f4[0])
      1'b0: begin  // 32-bit saturation
        sat_neon_sum_f4[31: 0] = neon_acc_sat_f4[0] ? {~mul_sum_f4[31], {31{mul_sum_f4[31]}} }
                                                    : mul_sum_f4[31: 0];
        sat_neon_sum_f4[63:32] = neon_acc_sat_f4[1] ? {~mul_sum_f4[63], {31{mul_sum_f4[63]}} }
                                                    : mul_sum_f4[63:32];
      end

      1'b1: begin  // 64-bit saturation
        sat_neon_sum_f4[63: 0] = neon_acc_sat_f4[1] ? {~mul_sum_f4[63], {63{mul_sum_f4[63]}} }
                                                    : mul_sum_f4[63: 0];
      end
    endcase


  assign neg_neon_sum_f4 = sat_neon_sum_f4 ^ {64{res0_sign_f4}};

  assign nxt_norm_frac_f5 = neon_int_op_f4 ? {1'b0, neg_neon_sum_f4[51:0]}
                                           : norm_frac_f4[52:0];
  assign nxt_norm0_exp_f5 = neon_int_op_f4 ? {1'b0, neg_neon_sum_f4[62:52]}
                                           : norm0_exp_f4;
  assign nxt_out0_sign_f5 = neon_int_op_f4 ? neg_neon_sum_f4[63]
                                           : out0_sign_f4;

  assign nxt_round_mode_rn_f5 = {1'b0, round_mode_f4} == `CA53_FP_RMODE_RN;

  assign advance_pipeline_f4 = advance_pipeline_i & (enable_f4 | collect_div_f4);

  always @(posedge clk_fp_mul)
    if (advance_pipeline_f4) begin
      ctl_dual_fp_f5            <= ctl_dual_fp_f4;
      double_prec_f5            <= double_prec_f4;
      norm0_exp_f5              <= nxt_norm0_exp_f5;
      norm1_exp_f5              <= norm1_exp_f4;
      out0_sign_f5              <= nxt_out0_sign_f5;
      out1_sign_f5              <= out1_sign_f4;
      round_mode_f5             <= round_mode_f4;
      round_mode_rn_f5          <= nxt_round_mode_rn_f5;
      round_updown0_f5          <= round_updown0_f4;
      round_updown1_f5          <= round_updown1_f4;
      fpscr_fz_f5               <= fpscr_fz_i;
      res0_infinite_f5          <= res0_infinite_f4;
      res0_zero_f5              <= res0_zero_f4;
      res0_nan_f5               <= res0_nan_f4;
      res1_infinite_f5          <= res1_infinite_f4;
      res1_zero_f5              <= res1_zero_f4;
      res1_nan_f5               <= res1_nan_f4;
      invalid0_f5               <= invalid0_f4;
      invalid1_f5               <= invalid1_f4;
      divbyzero_op0_f5          <= divbyzero_op0_f4;
      divbyzero_op1_f5          <= divbyzero_op1_f4;
      in_flushzero_f5           <= in_flushzero_f4;
      out0_overflow_no_carry_f5 <= out0_overflow_no_carry_f4;
      out0_overflow_if_carry_f5 <= out0_overflow_if_carry_f4;
      out1_overflow_no_carry_f5 <= out1_overflow_no_carry_f4;
      out1_overflow_if_carry_f5 <= out1_overflow_if_carry_f4;
      round_val_f5              <= round_val_f4;
      fused_mac_f5              <= fused_mac_f4;
      norm_frac_f5              <= nxt_norm_frac_f5;
      norm_frac_subprec_f5      <= norm_frac_subprec_f4;
      inexact0_f5               <= inexact0_f4;
      inexact1_f5               <= inexact1_f4;
      neon_int_op_f5            <= neon_int_op_f4;
      neon_qc_bit_f5            <= neon_qc_bit_f4;
      force_dn_fz_f5            <= force_dn_fz_f4;
      neon_udf_f5               <= neon_underflow_f4;
    end


  // --- F5 stage ---

  // Perform rounding on the result

  assign round_high = ctl_dual_fp_f5 ? round_val_f5[1] : carry_low;

  assign {carry_high, rounded_frac[52:24]} = round_high ? (norm_frac_f5[52:24] + 1'b1) : {1'b0, norm_frac_f5[52:24]};
  assign {carry_low,  rounded_frac[23: 0]} = norm_frac_f5[23:0] + round_val_f5[0];

  assign frac_carry_f5 = double_prec_f5 ? carry_high : carry_low;

  assign round_exp0 = frac_carry_f5    ? (norm0_exp_f5 + 1'b1) : norm0_exp_f5;
  assign round_exp1 = rounded_frac[48] ? (norm1_exp_f5 + 1'b1) : norm1_exp_f5;

  assign out0_overflow_f5 = out0_overflow_no_carry_f5 | (out0_overflow_if_carry_f5 & frac_carry_f5);
  assign out1_overflow_f5 = out1_overflow_no_carry_f5 | (out1_overflow_if_carry_f5 & rounded_frac[48]);

  assign res0_denormal = ~neon_int_op_f5 & ~res0_zero_f5 & (double_prec_f5 ? ~rounded_frac[52] : ~rounded_frac[23]) & ~frac_carry_f5;
  assign res1_denormal = ~neon_int_op_f5 & ~res1_zero_f5 & (~|rounded_frac[48:47]);

  assign norm0_exp_zero_f5 = ~neon_int_op_f5 & ~res0_zero_f5 & ~res0_infinite_f5 & ~res0_nan_f5 & (double_prec_f5 ? ~norm_frac_f5[52] : ~norm_frac_f5[23]);
  assign norm1_exp_zero_f5 = ~neon_int_op_f5 & ~res1_zero_f5 & ~res1_infinite_f5 & ~res1_nan_f5 & ~norm_frac_f5[47];

  assign flush_res0_zero_f5 = norm0_exp_zero_f5 & (force_dn_fz_f5 | fpscr_fz_f5) & ~fused_mac_f5;
  assign flush_res1_zero_f5 = norm1_exp_zero_f5 & (force_dn_fz_f5 | fpscr_fz_f5) & ~fused_mac_f5;

  assign out0_flushzero_f5 = flush_res0_zero_f5 | neon_udf_f5[0];
  assign out1_flushzero_f5 = flush_res1_zero_f5 | neon_udf_f5[1];

  assign overflow_to_inf0 = round_mode_rn_f5 | round_updown0_f5;
  assign overflow_to_inf1 = round_mode_rn_f5 | round_updown1_f5;

  assign out0_exp = (res0_nan_f5 | res0_infinite_f5
                     | (out0_overflow_f5 & ~res0_zero_f5 & overflow_to_inf0)) ? 12'hFFF :     // Infinite or NaN
                    (out0_overflow_f5 & ~res0_zero_f5 & ~overflow_to_inf0)    ? 12'hFFE :     // Largest non-infinite
                    (res0_zero_f5 | res0_denormal | out0_flushzero_f5)        ? 12'h000 :     // Denormal or zero
                                                                                round_exp0;
  assign out1_exp = (res1_nan_f5 | res1_infinite_f5
                     | (out1_overflow_f5 & ~res1_zero_f5 & overflow_to_inf1)) ? 9'h1FF :     // Infinite or NaN
                    (out1_overflow_f5 & ~res1_zero_f5 & ~overflow_to_inf1)    ? 9'h1FE :     // Largest non-infinite
                    (res1_zero_f5 | res1_denormal | out1_flushzero_f5)        ? 9'h000 :     // Denormal or zero
                                                                                round_exp1;


  assign out0_frac_zero = (res0_zero_f5 | res0_infinite_f5 | (out0_overflow_f5 & overflow_to_inf0) | out0_flushzero_f5) & ~res0_nan_f5;
  assign out0_frac_max = out0_overflow_f5 & ~res0_zero_f5 & ~overflow_to_inf0 & ~res0_nan_f5;

  assign out1_frac_zero = (res1_zero_f5 | res1_infinite_f5 | (out1_overflow_f5 & overflow_to_inf1) | out1_flushzero_f5) & ~res1_nan_f5;
  assign out1_frac_max = out1_overflow_f5 & ~res1_zero_f5 & ~overflow_to_inf1 & ~res1_nan_f5;

  assign dp_frac  = {52{~out0_frac_zero}} & ({52{out0_frac_max}} | rounded_frac[51: 0]);

  assign sp_frac0 = {23{~out0_frac_zero}} & ({23{out0_frac_max}} | rounded_frac[22: 0]);
  assign sp_frac1 = {23{~out1_frac_zero}} & ({23{out1_frac_max}} | rounded_frac[46:24]);

  assign mul_inx[0] = (out0_overflow_f5 | inexact0_f5) & ~res0_nan_f5 & ~res0_infinite_f5 & ~res0_zero_f5 & ~out0_flushzero_f5;
  assign mul_udf[0] = (norm0_exp_zero_f5 & inexact0_f5 & ~fused_mac_f5) | out0_flushzero_f5;
  assign mul_ovf[0] = out0_overflow_f5 & ~res0_zero_f5 & ~res0_nan_f5 & ~res0_infinite_f5;
  assign mul_inv[0] = invalid0_f5;
  assign mul_dbz[0] = divbyzero_op0_f5;

  assign mul_inx[1] = (out1_overflow_f5 | inexact1_f5) & ~res1_nan_f5 & ~res1_infinite_f5 & ~res1_zero_f5 & ~out1_flushzero_f5;
  assign mul_udf[1] = (norm1_exp_zero_f5 & inexact1_f5 & ~fused_mac_f5) | out1_flushzero_f5;
  assign mul_ovf[1] = out1_overflow_f5 & ~res1_zero_f5 & ~res1_nan_f5 & ~res1_infinite_f5;
  assign mul_inv[1] = invalid1_f5;
  assign mul_dbz[1] = divbyzero_op1_f5;

  assign fml_data_f5_o = double_prec_f5 ? {out0_sign_f5, out0_exp[10:0], dp_frac[51:0]}  :
                         ctl_dual_fp_f5 ? {out1_sign_f5, out1_exp[ 7:0], sp_frac1[22:0],
                                           out0_sign_f5, out0_exp[ 7:0], sp_frac0[22:0]} :
                                          {out0_sign_f5, out0_exp[ 7:0], sp_frac0[22:0],
                                           out0_sign_f5, out0_exp[ 7:0], sp_frac0[22:0]};

  assign fml_extra_data_f5_o[53:0] = double_prec_f5 ? {out0_exp[11], {53{~out0_frac_zero}} & {norm_frac_subprec_f5[52:0]} }
                                                    : { {4{1'b0}},
                                                       out1_exp[8], {24{~out1_frac_zero}} & norm_frac_subprec_f5[47:24],
                                                       out0_exp[8], {24{~out0_frac_zero}} & norm_frac_subprec_f5[23:0]};
  assign fml_extra_data_f5_o[63:54] = {10{1'b0}};

  assign mac_round_mode_f5_o  = round_mode_f5;
  assign mac_force_dn_fz_f5_o = force_dn_fz_f5;

  assign fused_mac_f5_o       = fused_mac_f5;
  assign mul_dual_fp_f5_o     = ctl_dual_fp_f5;

  assign expt_mask = {ctl_dual_fp_f5, 1'b1};

  assign mul_xflags_o[`CA53_XFLAGS_IDC_BITS] = in_flushzero_f5;
  assign mul_xflags_o[`CA53_XFLAGS_IXC_BITS] = (|(mul_inx & expt_mask));
  assign mul_xflags_o[`CA53_XFLAGS_UFC_BITS] = (|(mul_udf & expt_mask));
  assign mul_xflags_o[`CA53_XFLAGS_OFC_BITS] = (|(mul_ovf & expt_mask));
  assign mul_xflags_o[`CA53_XFLAGS_DZC_BITS] = (|(mul_dbz & expt_mask));
  assign mul_xflags_o[`CA53_XFLAGS_IOC_BITS] = (|(mul_inv & expt_mask));
  assign mul_xflags_o[`CA53_XFLAGS_QC_BITS]  = neon_qc_bit_f5;

  assign mul_enable_f2_o = enable_f2 | collect_div_f2;
  assign mul_enable_f3_o = enable_f3 | collect_div_f3;

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_pipeline_f1")
  u_ovl_x_advance_pipeline_f1 (.clk       (clk_fp_mul),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (advance_pipeline_f1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_pipeline_f2")
  u_ovl_x_advance_pipeline_f2 (.clk       (clk_fp_mul),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (advance_pipeline_f2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_pipeline_f3")
  u_ovl_x_advance_pipeline_f3 (.clk       (clk_fp_mul),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (advance_pipeline_f3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_pipeline_f4")
  u_ovl_x_advance_pipeline_f4 (.clk       (clk_fp_mul),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (advance_pipeline_f4));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_pipeline_i")
  u_ovl_x_advance_pipeline_i (.clk       (clk_fp_mul),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (advance_pipeline_i));



`endif

endmodule // ca53dpu_fp_mul

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
