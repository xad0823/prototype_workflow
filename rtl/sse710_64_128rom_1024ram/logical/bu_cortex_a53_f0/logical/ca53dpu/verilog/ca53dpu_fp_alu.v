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
// Abstract : Floating point single/double precision add datapath
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Performs SP and DP addition
//

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_fp_alu #(parameter CRYPTO = 1'b0, IS_PIPE0 = 1'b1) (
  // Inputs
  input  wire                           clk_fp_alu,
  input  wire                           reset_n,
  input  wire                           advance_pipeline_i,
  input  wire    [`CA53_FP_RMODE_W-1:0] rm_f1_i,              // Round mode
  input  wire                           force_dn_fz_f1_i,     // Force DN and FZ modes
  input  wire                           fpscr_fz_i,           // Flush-to-zero mode
  input  wire                           fpscr_dn_i,           // Default NaN mode
  input  wire                           fpscr_ahp_i,          // Alternative half-precision mode
  input  wire                           enable_f1_i,          // Enable signal
  input  wire  [`CA53_FP_ADD_CTL_W-1:0] add_ctl_f1_i,
  input  wire                           fused_mac_f1_i,       // The addition is part of a Fused MAC
  input  wire                     [6:0] imm_data_f1_i,
  input  wire                     [7:0] imm_data_f2_i,
  input  wire                    [63:0] fad_a_data_f1_i,      // First operand
  input  wire                    [63:0] fad_b_data_f1_i,      // Second operand
  input  wire                    [63:0] fad_c_data_f1_i,      // Third operand
  input  wire                           alu0_csel_pass_ex2_i,
  input  wire                     [1:0] fad_a_fwd_f2_i,
  input  wire                     [1:0] fad_b_fwd_f2_i,
  input  wire                    [63:0] fwd_data_fr1_f2_i,
  input  wire                    [63:0] fwd_data_fr2_f2_i,
  // Outputs
  output wire                           add_enable_f2_o,      // FP ALU enable in F2
  output wire                           add_enable_f3_o,      // FP ALU enable in F3
  output wire                    [63:0] fp_alu_f2i_res_f3_o,  // Result of A64 float->int conversion
  output wire                    [63:0] fad_early_data_f3_o,  // Result for forwardin from F3
  output wire                    [63:0] fad_early_data_f4_o,  // Result for forwardin from F4
  output wire                    [63:0] fad_data_f5_o,        // Addition result
  output wire      [`CA53_XFLAGS_W-1:0] add_xflags_f5_o,      // Exception flags
  output wire                     [3:0] fp_cmpflags_f2_o      // Comparison NZCV flags
);

  // -------------------------------
  // Reg declarations
  // -------------------------------

  reg                           can_flush_opb_f2;
  reg                  [107:0]  alu_res_f4;
  reg                           enable_f2;
  reg                           enable_f3;
  reg                           enable_f4;
  reg                   [10:0]  fp_a_exp_f2 [1:0];
  reg                   [11:0]  fp_b_exp_f2 [1:0];
  reg      [`CA53_FP_OP_W-1:0]  fp_op_f2;
  reg      [`CA53_FP_OP_W-1:0]  fp_op_f3;
  reg      [`CA53_FP_OP_W-1:0]  fp_op_f4;
  reg      [`CA53_FP_OP_W-1:0]  fp_op_f5;
  reg                   [11:0]  exp_nres_f5 [1:0];
  reg                   [11:0]  exp_opd_f2  [1:0];
  reg                   [11:0]  exp_opd_f3  [1:0];
  reg                   [11:0]  exp_opd_f4  [1:0];
  reg                   [11:0]  f2i_a_exp_threshold_f2;
  reg                    [1:0]  f2i_carry_f5;
  reg                    [1:0]  f2i_inexact_f3;
  reg                    [1:0]  f2i_inexact_f4;
  reg                    [1:0]  f2i_neg_sat_f5;
  reg                    [1:0]  f2i_overflow_f3;
  reg                    [1:0]  f2i_overflow_f4;
  reg                    [1:0]  f2i_pos_sat_f5;
  reg                   [63:0]  fad_a_data_f2;
  reg                  [106:0]  add_op_a_f3;
  reg                   [63:0]  fad_b_data_f2;
  reg                  [107:0]  add_op_b_f3;
  reg                   [63:0]  frc_sres_f5;
  reg                           ifz_f3;
  reg                           ifz_f4;
  reg                           ifz_f5;
  reg                    [1:0]  inc_exp_res_f5;
  reg                    [1:0]  inc_frc_f5;
  reg                    [1:0]  infinity_op_f3;
  reg                    [1:0]  infinity_op_f4;
  reg                    [1:0]  infinity_op_f5;
  reg                    [1:0]  invalid_op_f3;
  reg                    [1:0]  invalid_op_f4;
  reg                    [1:0]  fp_a_exp_max_f2;
  reg                    [1:0]  fp_b_exp_max_f2;
  reg                    [1:0]  nan_inv_op_f3;
  reg                    [1:0]  nan_inv_op_f4;
  reg                    [1:0]  nan_inv_op_f5;
  reg                    [7:0]  neon_carry_f2;
  reg                    [7:0]  neon_extend_a_f2;
  reg                    [7:0]  neon_extend_b_f2;
  reg                   [63:0]  neon_cls_res_f2;
  reg  [`CA53_NEON_FCTN_W-1:0]  neon_fctn_sel_f2;
  reg                           force_dn_fz_f2;
  reg                           force_dn_fz_f3;
  reg                           force_dn_fz_f4;
  reg                   [63:0]  fad_c_data_f2;
  reg                   [63:0]  neon_element_res_f3;
  reg                   [63:0]  neon_frc_opc_f3;
  reg                   [63:0]  neon_halved_res_f3;
  reg                           neon_int_sel_f2;
  reg                           neon_int_sel_f3;
  reg                           neon_int_sel_f4;
  reg                           neon_int_sel_f5;
  reg                    [3:0]  neon_lu_ctl_f2;
  reg                    [7:0]  neon_lu_ctl_f3;
  reg                           neon_mask_sel_f2;
  reg                    [2:0]  neon_mux_sel_f2;
  reg                    [2:0]  neon_mux_sel_f3;
  reg                   [31:0]  neon_narrow_res_f4;
  reg                   [63:0]  neon_opa_f2;
  reg                   [63:0]  neon_opb_f2;
  reg                   [63:0]  neon_rnd_opb_f2;
  reg                   [63:0]  neon_scalar_mask_f3;
  reg                   [15:0]  neon_sat_detect_f3;
  reg                   [15:0]  neon_sat_dtect_ctl_f3;
  reg                           neon_sat_flag_f4;
  reg                           neon_sat_flag_f5;
  reg                    [2:0]  neon_sat_op_sel_f2;
  reg                    [2:0]  neon_sat_op_sel_f3;
  reg                    [2:0]  neon_sat_op_sel_f4;
  reg                   [63:0]  neon_sat_res_f4;
  reg                           neon_shift_reg_f2;
  reg                    [1:0]  neon_size_sel_f2;
  reg                    [1:0]  neon_size_sel_f3;
  reg                    [1:0]  neon_size_sel_f4;
  reg                    [1:0]  neon_size_sel_f5;
  reg                           neon_unsigned_op_f2;
  reg                           neon_unsigned_op_f3;
  reg                           neon_unsigned_op_f4;
  reg                           neon_unsigned_op_f5;
  reg                           neon_vtb_cycle_f2;
  reg                           neon_vtst_op_sel_f2;
  reg                           neon_vtst_op_sel_f3;
  reg                           neon_vtst_op_sel_f4;
  reg                   [15:0]  neon_vtst_res_f4;
  reg                    [2:0]  neon_width_op_sel_f2;
  reg                    [2:0]  neon_width_op_sel_f3;
  reg                    [2:0]  neon_width_op_sel_f4;
  reg                    [1:0]  nzero_grt_bits_f5;
  reg                    [7:0]  nxt_neon_lu_ctl_f3;
  reg                    [1:0]  overflow_f5;
  reg                    [1:0]  ovf_to_inf_f5;
  reg                    [1:0]  raw_invalid_op_f5;
  reg                    [1:0]  raw_fp_b_exp_zero_f2;
  reg                    [6:0]  renorm_shift_f4 [1:0];
  reg                   [63:0]  res_f5;
  reg   [`CA53_FP_RMODE_W-1:0]  rnd_mode_f2;
  reg   [`CA53_FP_RMODE_W-1:0]  rnd_mode_f3;
  reg   [`CA53_FP_RMODE_W-1:0]  rnd_mode_f4;
  reg                    [1:0]  fp_a_sign_f2;
  reg                    [1:0]  sign_f3;
  reg                    [1:0]  sign_f4;
  reg                    [1:0]  raw_fp_b_sign_f2;
  reg                    [1:0]  sign_res_f5;
  reg                    [1:0]  sub_f2;
  reg                           sub_f3;
  reg                    [1:0]  undf_res_f5;
  reg                    [1:0]  fp_a_exp_zero_f2;
  reg                    [1:0]  zero_op_f3;
  reg                    [1:0]  zero_op_f4;
  reg                    [1:0]  zero_out_f5;
  reg                    [1:0]  zres_f3;
  reg                    [1:0]  zres_f4;
  reg                           fpscr_ahp_f2;
  reg                           fpscr_ahp_f4;
  reg                           fpscr_ahp_f5;
  reg                           fpscr_dn_f2;
  reg                           fpscr_dn_f4;
  reg                           fpscr_fz_f2;
  reg                           fpscr_fz_f4;
  reg                   [63:0]  frc_sres_f4;
  reg                    [1:0]  round_bit_f4;
  reg                    [1:0]  sticky_bit_f4;
  reg                           ctl_dual_fp_f2;
  reg                           ctl_dual_fp_f3;
  reg                           ctl_dual_fp_f4;
  reg                           ctl_dual_fp_f5;
  reg                           ctl_no_dual_fp_f2;
  reg                           ctl_no_dual_fp_f3;
  reg                           dual_s2h_f5;
  reg                    [1:0]  f2i_roundval_f2 [1:0];
  reg                           vector_op_f2;
  reg                           vector_op_f3;
  reg                    [1:0]  exp_is_max_m1;
  reg                    [1:0]  exp_is_max;
  reg                    [1:0]  exp_is_max_p1;
  reg                    [1:0]  exp_gt_max_p1;
  reg                           neon_narrowing_op_f2;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                          abs_cmd_f1;
  wire                          abs_neg_f2;
  wire                          abs_neg_f4;
  wire                   [1:0]  abs_sign_a_f2;
  wire                   [1:0]  abs_sign_b_f2;
  wire                          can_flush_opb_f1;
  wire                   [1:0]  cmp_aeqb_f2;
  wire                   [1:0]  cmp_agtb_f2;
  wire                          cmp_cmd_f3;
  wire                          cmp_cmd_f4;
  wire                          cmp_cmd_f5;
  wire                          cmpe_cmd_f2;
  wire                   [3:0]  cmpflags_f2;
  wire                          d2fix_f5;
  wire                          d2s_f2;
  wire                          dec_exp_res_f2;
  wire                   [1:0]  denorm_fz_f4;
  wire                          dp_op_sel_f4;
  wire                   [1:0]  eqexp_f2;
  wire                   [1:0]  equal_opnd_f2;
  wire                   [1:0]  exc_res;
  wire                  [10:0]  fp_a_exp_f1 [1:0];
  wire                  [11:0]  exp_add_f2 [1:0];
  wire                  [11:0]  fp_b_exp_f1 [1:0];
  wire                  [11:0]  exp_nres_f4 [1:0];
  wire                  [10:0]  exp_res [1:0];
  wire                  [11:0]  recpx_exp_f3;
  wire                   [1:0]  nxt_sign_f4;
  wire                  [11:0]  nxt_exp_opd_f4 [1:0];
  wire                   [1:0]  nxt_nan_inv_op_f4;
  wire                   [1:0]  nxt_infinity_op_f4;
  wire                   [1:0]  nxt_zero_op_f4;
  wire                   [1:0]  f2i_carry_f4;
  wire                          f2i_cmd_f1;
  wire                   [1:0]  f2i_inexact_f2;
  wire                          f2i_f2;
  wire                          f2i_f3;
  wire                          f2i_f4;
  wire                          f2i_f5;
  wire                   [1:0]  f2i_msb_f4;
  wire                   [1:0]  f2i_neg_sat_f4;
  wire                   [1:0]  f2i_overflow_f2;
  wire                   [1:0]  f2i_pos_sat_f4;
  wire                   [1:0]  f2i_sign;
  wire                          f2i_signed_f4;
  wire                 [105:0]  fp_clz_opd_f3;
  wire     [`CA53_FP_OP_W-1:0]  fp_op_f1;
  wire                   [1:0]  fp_out_size_f1;
  wire                  [63:0]  frc_inc_res;
  wire                  [63:0]  rounded_frac_f5;
  wire                   [1:0]  frac_carry_f5;
  wire                  [63:0]  nxt_fad_a_data_f2;
  wire                 [106:1]  fp_a_frac_f2;
  wire                  [63:0]  nxt_fad_b_data_f2;
  wire                 [107:1]  fp_b_frac_f2;
  wire                  [63:0]  frc_res;
  wire                 [107:0]  add_res_f3;
  wire                  [66:0]  early_f2i_res_f3;
  wire                  [63:0]  early_f2i_sat_res_f3;
  wire                          early_f2i_pos_sat_f3;
  wire                          early_f2i_neg_sat_f3;
  wire                          early_f2i_msb_f3;
  wire                          early_f2i_carry_f3;
  wire                          early_f2i_sign_f3;
  wire                  [63:0]  fp_alu_f2i_res_f3;
  wire                   [1:0]  gtexp_f2;
  wire                   [1:0]  gtopnd_f2;
  wire                          h2s_f1;
  wire                          i2f_cmd_f1;
  wire                          i2f_f2;
  wire                          ifz_f2;
  wire                   [1:0]  fp_a_flush_f2;
  wire                   [1:0]  fp_b_flush_f2;
  wire                   [1:0]  inc_exp_res_f4;
  wire                   [1:0]  inc_frc_f4;
  wire                          inc_frc_hi_f5;
  wire                          inexact_excpt;
  wire                          underflow_excpt;
  wire                   [1:0]  fp_a_infinite_f2;
  wire                   [1:0]  fp_b_infinite_f2;
  wire                   [1:0]  infinity_op_f2;
  wire                   [1:0]  invalid_op_f2;
  wire                   [1:0]  sub_infinities_f2;
  wire                   [1:0]  invalid_op_f5;
  wire                   [1:0]  fp_a_exp_max_f1;
  wire                   [1:0]  fp_b_exp_max_f1;
  wire                   [1:0]  fp_a_frac_msb_f2;
  wire                   [1:0]  fp_b_frac_msb_f2;
  wire                 [107:0]  nxt_alu_res_f4;
  wire                          maximum_f2;
  wire                          minimum_f2;
  wire                 [106:0]  muxfrc_opa_f2;
  wire                 [107:0]  muxfrc_opb_f2;
  wire                   [1:0]  nan_inv_inf_op;
  wire                   [1:0]  nan_inv_op_f2;
  wire                   [1:0]  nan_op_f2;
  wire                   [1:0]  fp_a_nan_f2;
  wire                   [1:0]  fp_b_nan_f2;
  wire                          negate_b_f1;
  wire                          neon_b_unsigned_f2;
  wire                  [63:0]  fwd_neon_opa_f2;
  wire                  [63:0]  fwd_neon_opb_f2;
  wire                  [79:0]  neon_add_opa_f2;
  wire                  [79:0]  neon_add_opb_f2;
  wire                 [107:0]  neon_add_res_f3;
  wire                  [63:0]  neon_clz_res_f3;
  wire                  [63:0]  neon_cmp_eq_f2;
  wire                  [63:0]  neon_cmp_gt_f2;
  wire                  [63:0]  neon_cnt_res_f2;
  wire                  [63:0]  neon_rbit_res_f2;
  wire                   [1:0]  neon_dcr_size_sel_f4;
  wire                  [63:0]  neon_ext_opa_f1;
  wire                  [63:0]  neon_ext_opb_f1;
  wire [`CA53_NEON_FCTN_W-1:0]  neon_fctn_sel_f1;
  wire                   [1:0]  neon_inc_size_sel_f1;
  wire                   [1:0]  nxt_neon_size_sel_f2;
  wire                          neon_int_op_f2;
  wire                          neon_int_sel_f1;
  wire                   [3:0]  neon_lu_ctl_f1;
  wire                  [63:0]  raw_neon_lu_res_f3;
  wire                  [63:0]  neon_lu_res_f3;
  wire                          neon_mask_sel_f1;
  wire                   [2:0]  neon_mux_sel_f1;
  wire                  [63:0]  nxt_fad_c_data_f2;
  wire                  [63:0]  neon_nxt_frc_opc_f3;
  wire                  [63:0]  neon_opa_f3;
  wire                  [63:0]  neon_opb_f3;
  wire                  [63:0]  neon_perm_ctl_f1;
  wire                  [63:0]  neon_perm_opa_f2;
  wire                  [63:0]  neon_perm_opb_f2;
  wire                   [3:0]  neon_perm_sel_f1;
  wire                  [95:0]  neon_polymul_res_f3;
  wire                  [63:0]  neon_res_f3;
  wire                  [63:0]  neon_masked_res_f3;
  wire                          neon_suqadd_f3;
  wire                          neon_usqadd_f3;
  wire                  [63:0]  neon_sat_dtect_f2;
  wire                  [15:0]  neon_sat_dtect_f3;
  wire                  [15:0]  raw_neon_sat_dtect_res_f4;
  wire                  [15:0]  neon_sat_dtect_res_f4;
  wire                  [63:0]  neon_sat_in_res_f4;
  wire                  [31:0]  neon_vector_maxmin_f4;
  wire                   [2:0]  neon_sat_op_sel_f1;
  wire                          neon_sat_unsigned_f4;
  wire                  [63:0]  neon_shift_mask_f2;
  wire                          neon_shift_reg_f1;
  wire                  [63:0]  neon_shift_res_f2;
  wire                  [63:0]  neon_shift_round_f2;
  wire                  [15:0]  neon_shift_sat_f3;
  wire                   [1:0]  neon_size_sel_f1;
  wire                  [63:0]  neon_swap_max_f2;
  wire                  [63:0]  neon_swap_min_f2;
  wire                          neon_unsigned_op_f1;
  wire                  [63:0]  neon_valid_bytes_vector_cycle_f2;
  wire                  [63:0]  neon_valid_bytes_vector_final_f2;
  wire                          neon_vrhadd_f2;
  wire                          neon_vtb_cycle_f1;
  wire                          neon_vtst_byte0_f4;
  wire                          neon_vtst_byte1_f4;
  wire                          neon_vtst_byte2_f4;
  wire                          neon_vtst_byte3_f4;
  wire                          neon_vtst_byte4_f4;
  wire                          neon_vtst_byte5_f4;
  wire                          neon_vtst_byte6_f4;
  wire                          neon_vtst_byte7_f4;
  wire                          neon_vtst_op_sel_f1;
  wire                   [2:0]  neon_width_op_sel_f1;
  wire                  [63:0]  nfrc_sres_f4;
  wire                   [1:0]  nsnan_opb_f2;
  wire                   [1:0]  swap_opnd_f2;
  wire                 [106:0]  nxt_add_op_a_f3;
  wire                 [107:0]  nxt_add_op_b_f3;
  wire                   [1:0]  nxt_fp_a_sign_f2;
  wire                   [1:0]  nxt_fp_b_sign_f2;
  wire                   [1:0]  nzero_grt_bits_f4;
  wire                   [1:0]  ovf_res;
  wire                   [1:0]  ovf_if_carry_f4;
  wire                   [1:0]  ovf_always_f4;
  wire                   [1:0]  overflow_f4;
  wire                   [1:0]  ovf_to_inf_f4;
  wire                   [1:0]  raw_gtexp_f2;
  wire                          recpx_f2;
  wire                          recpx_f3;
  wire                          recpx_f4;
  wire                          rnd_integral_f2;
  wire                          rnd_integral_f3;
  wire                          rnd_integral_f4;
  wire                          rnd_integral_f5;
  wire                   [1:0]  round_infinity_f4;
  wire                          s2d_f2;
  wire                          s2h_f1;
  wire                          s2h_f2;
  wire                          s2h_f4;
  wire                          s2h_f5;
  wire                          s2h_scalar_f2;
  wire                   [1:0]  sel_a_exp_f2;
  wire                 [106:0]  shfrc_opb_f2;
  wire                   [6:0]  lza_res_f3 [1:0];
  wire                   [6:0]  renorm_shift_f3 [1:0];
  wire                   [1:0]  no_extra_shift_f4;
  wire                 [107:0]  pre_shifted_frc_f4;
  wire                 [107:0]  shifted_frc_f4;
  wire                   [1:0]  raw_fp_a_sign_f1;
  wire                   [1:0]  fp_a_sign_f1;
  wire                   [1:0]  raw_fp_b_sign_f1;
  wire                   [1:0]  fp_b_sign_f1;
  wire                   [1:0]  fp_b_sign_f2;
  wire                   [1:0]  sign_f2;
  wire                   [1:0]  sign_res_f4;
  wire                   [1:0]  fp_a_snan_f2;
  wire                   [1:0]  fp_b_snan_f2;
  wire                   [1:0]  sub_f1;
  wire                   [1:0]  sub_mux_f2;
  wire                 [106:0]  swap_frc_opa_f2;
  wire                 [107:0]  swap_frc_opb_f2;
  wire                   [1:0]  undf_res_f4;
  wire                 [106:22] fp_a_frac_f1;
  wire                 [107:1]  fp_b_frac_f1;
  wire                   [1:0]  fp_a_exp_zero_f1;
  wire                   [1:0]  fp_b_exp_zero_f1;
  wire                   [1:0]  fp_b_exp_zero_f2;
  wire                   [1:0]  fp_a_frac_zero_f2;
  wire                   [1:0]  fp_b_frac_zero_f2;
  wire                          fp_a_frac_zero_hi_f2;
  wire                          fp_a_frac_zero_mid_f2;
  wire                          fp_a_frac_zero_lo_f2;
  wire                          fp_b_frac_zero_hi_f2;
  wire                          fp_b_frac_zero_mid_f2;
  wire                          fp_b_frac_zero_lo_f2;
  wire                          fp_frac_hi_equal_f2;
  wire                          fp_frac_lo_equal_f2;
  wire                          fp_frac_hi_gt_f2;
  wire                          fp_frac_lo_gt_f2;
  wire                   [1:0]  zero_op_f2;
  wire                   [1:0]  fp_a_zero_f2;
  wire                   [1:0]  fp_b_zero_f2;
  wire                   [1:0]  zero_out_f4;
  wire                   [1:0]  zero_res_f2;
  wire                   [1:0]  zres_f2;
  wire                   [1:0]  shift_opnd_f2;
  wire                          raw_ctl_dual_fp_f1;
  wire                          ctl_dual_fp_f1;
  wire                          ctl_no_dual_fp_f1;
  wire                          nxt_ctl_dual_fp_f4;
  wire                          sel_a_hi_from_a;
  wire                          sel_a_hi_from_b;
  wire                          sel_a_lo_from_a;
  wire                          sel_a_lo_from_b;
  wire                          sel_b_hi_from_sh;
  wire                          sel_b_hi_from_a;
  wire                          sel_b_hi_from_b;
  wire                          sel_b_lo_from_sh;
  wire                          sel_b_lo_from_a;
  wire                          sel_b_lo_from_b;
  wire                          nxt_sub_f3;
  wire                          dual_s2h_f4;
  wire                          f2i_low_sign_f2;
  wire                          minmaxnm_f2;
  wire                          vector_op_f1;
  wire                  [63:0]  sha1h_res_f2;
  wire                  [63:0]  sha1su0_opa_f2;
  wire                  [63:0]  sha1su0_opb_f2;
  wire                  [63:0]  sha256su0_opa_f2;
  wire                  [63:0]  sha256su0_opb_f2;
  wire                  [63:0]  neon_reduce_opa_f2;
  wire                  [63:0]  neon_reduce_opb_f2;
  wire                          fp_maxmin_sign_f3;
  wire                   [7:0]  fp_maxmin_exp_f3;
  wire                  [23:0]  fp_maxmin_frac_f3;
  wire                          fp_maxmin_nan_f3;
  wire                          fp_maxmin_inf_f3;
  wire                          fp_maxmin_zero_f3;
  wire                  [11:0]  exp_inc_res [1:0];
  wire                          neon_narrowing_op_f1;
  wire                          advance_f1;
  wire                          advance_f2;
  wire                          advance_f3;
  wire                          advance_f4;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  //----------------------------------------------------------
  // First execution stage f1
  //----------------------------------------------------------

  // Unpack the floating point operands
  ca53dpu_fp_unpack_opa u_fp_unpack_opa (
    .fad_a_data_f1_i    (fad_a_data_f1_i),
    .fp_op_f1_i         (fp_op_f1),
    .neon_size_sel_f1_i (neon_size_sel_f1),
    .dual_fp_f1_i       (raw_ctl_dual_fp_f1),
    .imm_data_f1_i      (imm_data_f1_i[6:0]),
    .fp_a_sign_f1_o     (raw_fp_a_sign_f1),
    .fp_a_exp0_f1_o     (fp_a_exp_f1[0]),
    .fp_a_exp1_f1_o     (fp_a_exp_f1[1]),
    .fp_a_frac_f1_o     (fp_a_frac_f1),
    .fp_a_exp_max_f1_o  (fp_a_exp_max_f1),
    .fp_a_exp_zero_f1_o (fp_a_exp_zero_f1)
  );

  ca53dpu_fp_unpack_opb u_fp_unpack_opb (
    .fad_b_data_f1_i        (fad_b_data_f1_i),
    .fad_c_data_f1_i        (fad_c_data_f1_i),
    .fp_op_f1_i             (fp_op_f1),
    .neon_size_sel_f1_i     (neon_size_sel_f1),
    .neon_unsigned_op_f1_i  (neon_unsigned_op_f1),
    .fused_mac_f1_i         (fused_mac_f1_i),
    .fpscr_ahp_i            (fpscr_ahp_i),
    .dual_fp_f1_i           (raw_ctl_dual_fp_f1),
    .imm_data_f1_i          (imm_data_f1_i[6:0]),
    .fp_b_sign_f1_o         (raw_fp_b_sign_f1),
    .fp_b_exp0_f1_o         (fp_b_exp_f1[0]),
    .fp_b_exp1_f1_o         (fp_b_exp_f1[1]),
    .fp_b_frac_f1_o         (fp_b_frac_f1),
    .fp_b_exp_max_f1_o      (fp_b_exp_max_f1),
    .fp_b_exp_zero_f1_o     (fp_b_exp_zero_f1),
    .can_flush_opb_f1_o     (can_flush_opb_f1)
  );

  // Extract control signals
  assign fp_op_f1               = add_ctl_f1_i[`CA53_FP_ADD_FP_OP_BITS];
  assign raw_ctl_dual_fp_f1     = add_ctl_f1_i[`CA53_FP_ADD_VECTOR_FP_OP_BITS] & (neon_size_sel_f1 != 2'b11) & (fp_op_f1 != `CA53_FP_OP_S2D);
  assign ctl_dual_fp_f1         = raw_ctl_dual_fp_f1 | s2h_f1;
  assign ctl_no_dual_fp_f1      = ~ctl_dual_fp_f1;
  assign neon_int_sel_f1        = add_ctl_f1_i[`CA53_FP_NEON_ADD_NEON_INT_SEL_BITS]; // Select neon integer operation's result
  assign neon_mux_sel_f1        = add_ctl_f1_i[`CA53_FP_NEON_ADD_NEON_MUX_SEL_BITS]; // Select adder, polymult or logical result
  assign neon_lu_ctl_f1         = add_ctl_f1_i[`CA53_FP_NEON_ADD_LU_CTL_BITS];       // Logical unit operation
  assign neon_size_sel_f1       = add_ctl_f1_i[`CA53_FP_NEON_ADD_SIZE_SEL_BITS];     // Size of SIMD operations
  assign neon_perm_sel_f1       = add_ctl_f1_i[`CA53_FP_NEON_ADD_PERM_SEL_BITS];     // Selects permutation operation
  assign neon_vtb_cycle_f1      = add_ctl_f1_i[`CA53_FP_NEON_ADD_VTB_CYCLE_BITS];    // Indicates the number of the current cycle for VTBL/VTBX instructions
  assign neon_unsigned_op_f1    = add_ctl_f1_i[`CA53_FP_NEON_ADD_UNSIGNED_OP_BITS];  // Selects signed or unsigned comparison
  assign neon_fctn_sel_f1       = add_ctl_f1_i[`CA53_FP_NEON_ADD_FCTN_SEL_BITS];     // Selects neon operation in the second stage
  assign neon_width_op_sel_f1   = add_ctl_f1_i[`CA53_FP_NEON_ADD_WIDTH_OP_SEL_BITS]; // Width operation (widening or narrow) of source and destination operands respectively
  assign neon_sat_op_sel_f1     = add_ctl_f1_i[`CA53_FP_NEON_ADD_SAT_OP_SEL_BITS];   // Selects the saturation detect bits according to the operation
  assign neon_vtst_op_sel_f1    = add_ctl_f1_i[`CA53_FP_NEON_ADD_VTST_OP_SEL_BITS];  // Selects the VTST operation
  assign neon_mask_sel_f1       = add_ctl_f1_i[`CA53_FP_NEON_ADD_MASK_SEL_BITS];     // Selects the mask produced from the shift block as the 2nd operand
  assign vector_op_f1           = add_ctl_f1_i[`CA53_FP_ADD_VECTOR_FP_OP_BITS];

  // Floating to integer and integer to floating input formats
  assign f2i_cmd_f1 = (fp_op_f1 == `CA53_FP_OP_S2I) | (fp_op_f1 == `CA53_FP_OP_D2I) | (fp_op_f1 == `CA53_FP_OP_D2FP);
  assign i2f_cmd_f1 = (fp_op_f1 == `CA53_FP_OP_I2S) | (fp_op_f1 == `CA53_FP_OP_I2D);

  assign s2h_f1 = (fp_op_f1 == `CA53_FP_OP_F2H_B) | (fp_op_f1 == `CA53_FP_OP_F2H_T);
  assign h2s_f1 = (fp_op_f1 == `CA53_FP_OP_H2F_B) | (fp_op_f1 == `CA53_FP_OP_H2F_T);

  assign abs_cmd_f1 = (fp_op_f1 == `CA53_FP_OP_ABS);

  // Negate operand's sign if required
  // For convert operations, make the a sign equal to the b sign
  // Negate the sign for the operand b for VNEG and subtraction
  assign negate_b_f1 = abs_cmd_f1 | (fp_op_f1 == `CA53_FP_OP_SUB) | (fp_op_f1 == `CA53_FP_OP_NEG) | (fp_op_f1 == `CA53_FP_OP_ABD);

  assign fp_a_sign_f1 = {2{fp_op_f1 == `CA53_FP_OP_RSB}} ^ (raw_fp_a_sign_f1 & {2{~neon_int_sel_f1}});
  assign fp_b_sign_f1 = {2{negate_b_f1}}               ^ (raw_fp_b_sign_f1 & {2{~neon_int_sel_f1}});

  // Select addition or subtraction operation
  assign sub_f1 = {2{i2f_cmd_f1 | f2i_cmd_f1 |
                     (fp_op_f1 == `CA53_FP_OP_ADD)  |
                     (fp_op_f1 == `CA53_FP_OP_SUB)  |
                     (fp_op_f1 == `CA53_FP_OP_RSB)  |
                     (fp_op_f1 == `CA53_FP_OP_HADD) |
                     (fp_op_f1 == `CA53_FP_OP_ABD)}} & (fp_a_sign_f1 ^ fp_b_sign_f1);

  // Compute sign for the first operand
  assign nxt_fp_a_sign_f2 = {2{~abs_cmd_f1}} & (fp_a_sign_f1 | (fp_b_sign_f1 & {2{i2f_cmd_f1 | f2i_cmd_f1 | s2h_f1 | h2s_f1}}));

  // Compute the sign of the second operand for the VABS operation
  assign nxt_fp_b_sign_f2 = {2{~abs_cmd_f1}} & fp_b_sign_f1;

  // Set the size signal to represent the output element size after this stage
  assign fp_out_size_f1 = (fp_op_f1 == `CA53_FP_OP_I2S) ? 2'b10 :
                          (fp_op_f1 == `CA53_FP_OP_I2D) ? 2'b11 :
                          (fp_op_f1 == `CA53_FP_OP_S2D) ? 2'b11 :
                          (fp_op_f1 == `CA53_FP_OP_D2S) ? 2'b10 :
                          s2h_f1                      ? 2'b01 :
                                                        neon_size_sel_f1;

  // Select inputs for neon or normal fpu operation


  // When the input operands are extended increase the size element by one
  // Also increase for narrowing operations, as the instruction encodes the
  // result element size, not the source element size
  assign neon_inc_size_sel_f1 = ((neon_width_op_sel_f1[2:1] == 2'b01) |
                                 (neon_width_op_sel_f1[2:1] == 2'b10))  ? (neon_size_sel_f1 + 1'b1) : neon_size_sel_f1;

  assign nxt_neon_size_sel_f2 = neon_int_sel_f1 ? neon_inc_size_sel_f1
                                                : fp_out_size_f1;

  // Zero or sign extends input operands
  function [63:0] extend_opnd;
    input         sign_ext;
    input [1:0]   size;
    input [63:0]  opa;

    case (size)
      2'b00: begin // 8-bits
        extend_opnd = { { 8{sign_ext & opa[31]}}, opa[31:24],
                        { 8{sign_ext & opa[23]}}, opa[23:16],
                        { 8{sign_ext & opa[15]}}, opa[15: 8],
                        { 8{sign_ext & opa[ 7]}}, opa[ 7: 0]};
      end
      2'b01: begin // 16-bits
        extend_opnd = { {16{sign_ext & opa[31]}}, opa[31:16],
                        {16{sign_ext & opa[15]}}, opa[15: 0]};
      end
      2'b10: begin // 32-bits
        extend_opnd = { {32{sign_ext & opa[31]}}, opa[31: 0]};
      end
      default: extend_opnd = {64{1'bx}};
    endcase
  endfunction

  assign neon_ext_opa_f1 = extend_opnd(~neon_unsigned_op_f1, neon_size_sel_f1, fad_a_data_f1_i);
  assign neon_ext_opb_f1 = extend_opnd(~neon_unsigned_op_f1, neon_size_sel_f1, fad_b_data_f1_i);

  ca53dpu_neon_perm_ctl u_perm_ctl (
    .neon_inc_size_sel_f1_i (neon_inc_size_sel_f1),
    .neon_perm_sel_f1_i     (neon_perm_sel_f1),
    .imm_data_f1_i          (imm_data_f1_i[6:0]),
    .fad_c_data_f1_i        (fad_c_data_f1_i),
    .neon_perm_ctl_f1_o     (neon_perm_ctl_f1)
  );

  assign neon_shift_reg_f1 = ((neon_fctn_sel_f1 == `CA53_NEON_FCTN_SHIFT) | (neon_fctn_sel_f1 == `CA53_NEON_FCTN_RND_SHIFT))
                             & (neon_width_op_sel_f1 != 3'b001);

  assign nxt_fad_a_data_f2 = (~neon_int_sel_f1 & ctl_no_dual_fp_f1)     ?   fp_a_frac_f1[106:43]                       :
                             (~neon_int_sel_f1 & ctl_dual_fp_f1)        ? { fp_a_frac_f1[106:75], fp_a_frac_f1[53:22]} :
                             ((neon_width_op_sel_f1[2:0] == 3'b011) &
                              (neon_fctn_sel_f1 != `CA53_NEON_FCTN_ADDV)) ? neon_ext_opa_f1                              :
                                                                          fad_a_data_f1_i;

  assign nxt_fad_b_data_f2 = ~neon_int_sel_f1                           ? { {10{1'b0}}, fp_b_frac_f1[107:54]} :
                             neon_shift_reg_f1                          ? fad_c_data_f1_i                     :
                             ((neon_width_op_sel_f1[2:1] == 2'b01) &
                              (neon_fctn_sel_f1 != `CA53_NEON_FCTN_ADDV)) ? neon_ext_opb_f1                     :
                                                                          fad_b_data_f1_i;
  assign nxt_fad_c_data_f2 = neon_int_sel_f1 ? neon_perm_ctl_f1
                                             : { {11{1'b0}}, fp_b_frac_f1[53:1]};

  
  assign neon_narrowing_op_f1 = neon_width_op_sel_f1 == 3'b001;

  always @(posedge clk_fp_alu)
    if (advance_pipeline_i)
      enable_f2 <= enable_f1_i;

  assign advance_f1 = advance_pipeline_i & enable_f1_i;

  always @(posedge clk_fp_alu)
    if (advance_f1) begin
      rnd_mode_f2             <= rm_f1_i;
      fp_op_f2                <= fp_op_f1;
      sub_f2                  <= sub_f1;
      fp_a_sign_f2            <= nxt_fp_a_sign_f2;
      raw_fp_b_sign_f2        <= nxt_fp_b_sign_f2;
      fad_a_data_f2           <= nxt_fad_a_data_f2;
      fad_b_data_f2           <= nxt_fad_b_data_f2;
      fad_c_data_f2           <= nxt_fad_c_data_f2;
      can_flush_opb_f2        <= can_flush_opb_f1;
      fp_a_exp_max_f2         <= fp_a_exp_max_f1;
      fp_b_exp_max_f2         <= fp_b_exp_max_f1;
      fp_a_exp_f2[0]          <= fp_a_exp_f1[0];
      fp_a_exp_f2[1]          <= fp_a_exp_f1[1];
      fp_b_exp_f2[0]          <= fp_b_exp_f1[0];
      fp_b_exp_f2[1]          <= fp_b_exp_f1[1];
      fp_a_exp_zero_f2        <= fp_a_exp_zero_f1;
      raw_fp_b_exp_zero_f2    <= fp_b_exp_zero_f1;
      fpscr_ahp_f2            <= fpscr_ahp_i;
      fpscr_dn_f2             <= fpscr_dn_i;
      fpscr_fz_f2             <= fpscr_fz_i;
      neon_int_sel_f2         <= neon_int_sel_f1;
      neon_fctn_sel_f2        <= neon_fctn_sel_f1;
      neon_mux_sel_f2         <= neon_mux_sel_f1;
      neon_lu_ctl_f2          <= neon_lu_ctl_f1;
      neon_size_sel_f2        <= nxt_neon_size_sel_f2;
      neon_vtb_cycle_f2       <= neon_vtb_cycle_f1;
      neon_unsigned_op_f2     <= neon_unsigned_op_f1;
      neon_width_op_sel_f2    <= neon_width_op_sel_f1;
      neon_narrowing_op_f2    <= neon_narrowing_op_f1;
      neon_sat_op_sel_f2      <= neon_sat_op_sel_f1;
      neon_mask_sel_f2        <= neon_mask_sel_f1;
      neon_vtst_op_sel_f2     <= neon_vtst_op_sel_f1;
      force_dn_fz_f2          <= force_dn_fz_f1_i;
      neon_shift_reg_f2       <= neon_shift_reg_f1;
      ctl_dual_fp_f2          <= ctl_dual_fp_f1;
      ctl_no_dual_fp_f2       <= ctl_no_dual_fp_f1;
      vector_op_f2            <= vector_op_f1;
    end

  //----------------------------------------------------------
  // Second execution stage f2
  //----------------------------------------------------------

  assign neon_int_op_f2 = neon_int_sel_f2;

  // Floating to integer and integer to floating input formats
  assign f2i_f2 = (fp_op_f2 == `CA53_FP_OP_S2I) | (fp_op_f2 == `CA53_FP_OP_D2I) | (fp_op_f2 == `CA53_FP_OP_D2FP);
  assign i2f_f2 = (fp_op_f2 == `CA53_FP_OP_I2S) | (fp_op_f2 == `CA53_FP_OP_I2D);

  // Single to double and double to single input formats
  assign s2d_f2 = (fp_op_f2 == `CA53_FP_OP_S2D);
  assign d2s_f2 = (fp_op_f2 == `CA53_FP_OP_D2S);

  assign s2h_f2 = (fp_op_f2 == `CA53_FP_OP_F2H_B) | (fp_op_f2 == `CA53_FP_OP_F2H_T);

  assign s2h_scalar_f2 = s2h_f2 & (neon_width_op_sel_f2 != 3'b001);

  assign rnd_integral_f2 = (fp_op_f2 == `CA53_FP_OP_RINT) | (fp_op_f2 == `CA53_FP_OP_RINTX);

  assign cmpe_cmd_f2 = (fp_op_f2 == `CA53_FP_OP_CMPE) | (fp_op_f2 == `CA53_FP_OP_ACMPE);

  assign abs_neg_f2 = (fp_op_f2 == `CA53_FP_OP_ABS) | (fp_op_f2 == `CA53_FP_OP_NEG) |
                      (fp_op_f2 == `CA53_FP_OP_MOV) | (fp_op_f2 == `CA53_FP_OP_ACMPE);
  assign recpx_f2 = (fp_op_f2 == `CA53_FP_OP_RECPX);

  // Maximum or minimum functions
  assign maximum_f2  = (fp_op_f2 == `CA53_FP_OP_MAX)   | (fp_op_f2 == `CA53_FP_OP_MAXNM);
  assign minimum_f2  = (fp_op_f2 == `CA53_FP_OP_MIN)   | (fp_op_f2 == `CA53_FP_OP_MINNM);
  assign minmaxnm_f2 = (fp_op_f2 == `CA53_FP_OP_MAXNM) | (fp_op_f2 == `CA53_FP_OP_MINNM);

  assign fp_a_frac_f2 = ctl_dual_fp_f2 ? {fad_a_data_f2[63:32], {21{1'b0}}, fad_a_data_f2[31: 0], {21{1'b0}} }
                                       : {fad_a_data_f2[63: 0], {42{1'b0}} };
  assign fp_b_frac_f2 = {fad_b_data_f2[53:0], fad_c_data_f2[52:0]};

  // Check exponents and fractions if non-zero, zero or all ones
  assign fp_a_frac_zero_hi_f2  = fad_a_data_f2[62:32] == {31{1'b0}};
  assign fp_a_frac_zero_mid_f2 = fad_a_data_f2[31:29] == { 3{1'b0}};
  assign fp_a_frac_zero_lo_f2  = fad_a_data_f2[28: 0] == {29{1'b0}};
  assign fp_b_frac_zero_hi_f2  = fp_b_frac_f2[105:54] == {52{1'b0}};
  assign fp_b_frac_zero_mid_f2 = fp_b_frac_f2[ 53:51] == { 3{1'b0}};
  assign fp_b_frac_zero_lo_f2  = fp_b_frac_f2[ 50: 1] == {50{1'b0}};

  assign fp_a_frac_zero_f2[0] = fp_a_frac_zero_hi_f2 & (ctl_dual_fp_f2 | (fp_a_frac_zero_lo_f2 & fp_a_frac_zero_mid_f2));
  assign fp_a_frac_zero_f2[1] = fp_a_frac_zero_lo_f2 & (ctl_dual_fp_f2 | (fp_a_frac_zero_hi_f2 & fp_a_frac_zero_mid_f2));
  assign fp_b_frac_zero_f2[0] = fp_b_frac_zero_hi_f2 & (ctl_dual_fp_f2 | (fp_b_frac_zero_lo_f2 & fp_b_frac_zero_mid_f2));
  assign fp_b_frac_zero_f2[1] = fp_b_frac_zero_lo_f2 & (ctl_dual_fp_f2 | (fp_b_frac_zero_hi_f2 & fp_b_frac_zero_mid_f2));

  // If the B operand was an integer, set zero_exp to zero_frc
  assign fp_b_exp_zero_f2 = i2f_f2 ? fp_b_frac_zero_f2 : raw_fp_b_exp_zero_f2;

  assign fp_a_frac_msb_f2[0] = fp_a_frac_f2[105];
  assign fp_a_frac_msb_f2[1] = fp_a_frac_f2[50];
  assign fp_b_frac_msb_f2[0] = fp_b_frac_f2[105];
  assign fp_b_frac_msb_f2[1] = fp_b_frac_f2[50];

  assign fp_a_nan_f2  = {2{~neon_int_op_f2}} & fp_a_exp_max_f2 & ~fp_a_frac_zero_f2;
  assign fp_b_nan_f2  = {2{~neon_int_op_f2}} & fp_b_exp_max_f2 & ~fp_b_frac_zero_f2;
  assign fp_a_snan_f2 = fp_a_nan_f2 & ~fp_a_frac_msb_f2;
  assign fp_b_snan_f2 = fp_b_nan_f2 & ~fp_b_frac_msb_f2;

  // Flush to zero mode signal
  assign fp_a_flush_f2 =                     {2{force_dn_fz_f2 | fpscr_fz_f2}}  & fp_a_exp_zero_f2 & ~fp_a_frac_zero_f2;
  assign fp_b_flush_f2 = {2{can_flush_opb_f2 & (force_dn_fz_f2 | fpscr_fz_f2)}} & fp_b_exp_zero_f2 & ~fp_b_frac_zero_f2;
  assign fp_a_zero_f2  = (fp_a_exp_zero_f2 & fp_a_frac_zero_f2) | fp_a_flush_f2;
  assign fp_b_zero_f2  = (fp_b_exp_zero_f2 & fp_b_frac_zero_f2) | fp_b_flush_f2;

    // Negate the sign if it is nan
  assign fp_b_sign_f2 = (fp_b_nan_f2 & {2{fp_op_f2 == `CA53_FP_OP_SUB}}) ^ raw_fp_b_sign_f2;

  // Select the sign of the 1st NaN operand when ~(~fp_a_snan_f1 & fp_b_snan_f1)
  assign nsnan_opb_f2 = fp_a_nan_f2 & (fp_a_snan_f2 | ~fp_b_snan_f2);

  // Check if one (or both) of the operands is NaN or signalling NaN
  assign nan_op_f2 = minmaxnm_f2 ? (fp_a_snan_f2 | fp_b_snan_f2 | (fp_a_nan_f2 & fp_b_nan_f2))
                                 : (fp_a_nan_f2  | fp_b_nan_f2);

  // Check if zero operation
  assign zero_op_f2[0] = (maximum_f2 | minimum_f2) ? (swap_opnd_f2[0] ? fp_b_zero_f2[0] : fp_a_zero_f2[0]) :
                         recpx_f2                  ? 1'b0                                                  :
                                                     (fp_a_zero_f2[0] & fp_b_zero_f2[0]);
  assign zero_op_f2[1] = ctl_no_dual_fp_f2         ? zero_op_f2[0]                                         :
                         (maximum_f2 | minimum_f2) ? (swap_opnd_f2[1] ? fp_b_zero_f2[1] : fp_a_zero_f2[1]) :
                                                     (fp_a_zero_f2[1] & fp_b_zero_f2[1]);

  // Check if operands are infinite
  assign fp_a_infinite_f2 = {2{~neon_int_op_f2}} & fp_a_exp_max_f2 & fp_a_frac_zero_f2;
  assign fp_b_infinite_f2 = {2{~neon_int_op_f2}} & fp_b_exp_max_f2 & fp_b_frac_zero_f2;

  // Check if invalid operation due to subtracting infinity from itself
  assign sub_infinities_f2 = fp_a_infinite_f2 & fp_b_infinite_f2 & sub_f2;

  // Compare the two exponents of the input operands
  assign raw_gtexp_f2[0] = {1'b0, fp_a_exp_f2[0]} > fp_b_exp_f2[0];
  assign raw_gtexp_f2[1] = {1'b0, fp_a_exp_f2[1]} > fp_b_exp_f2[1];

  assign gtexp_f2        = raw_gtexp_f2 | fp_a_infinite_f2;
  assign eqexp_f2[0]     = ({1'b0, fp_a_exp_f2[0]} == fp_b_exp_f2[0]) & ~fp_a_infinite_f2[0];
  assign eqexp_f2[1]     = ({1'b0, fp_a_exp_f2[1]} == fp_b_exp_f2[1]) & ~fp_a_infinite_f2[1];

   // Choose the maximum of the two input exponents
  assign sel_a_exp_f2[0] = maximum_f2 ? (  fp_b_nan_f2[0]                                                       |
                                         (~fp_a_nan_f2[0] & ~fp_a_sign_f2[0] &  fp_b_sign_f2[0])                |
                                         (~fp_a_nan_f2[0] & ~fp_a_sign_f2[0] & ~fp_b_sign_f2[0] &  gtexp_f2[0]) |
                                         (~fp_a_nan_f2[0] &  fp_a_sign_f2[0] &  fp_b_sign_f2[0] & ~gtexp_f2[0]))  :
                           minimum_f2 ? (  fp_b_nan_f2[0]                                                       |
                                         (~fp_a_nan_f2[0] &  fp_a_sign_f2[0] & ~fp_b_sign_f2[0])                |
                                         (~fp_a_nan_f2[0] & ~fp_a_sign_f2[0] & ~fp_b_sign_f2[0] & ~gtexp_f2[0]) |
                                         (~fp_a_nan_f2[0] &  fp_a_sign_f2[0] &  fp_b_sign_f2[0] &  gtexp_f2[0]))  :
                                        gtexp_f2[0];

  assign sel_a_exp_f2[1] = maximum_f2 ? (  fp_b_nan_f2[1]                                                       |
                                         (~fp_a_nan_f2[1] & ~fp_a_sign_f2[1] &  fp_b_sign_f2[1])                |
                                         (~fp_a_nan_f2[1] & ~fp_a_sign_f2[1] & ~fp_b_sign_f2[1] &  gtexp_f2[1]) |
                                         (~fp_a_nan_f2[1] &  fp_a_sign_f2[1] &  fp_b_sign_f2[1] & ~gtexp_f2[1]))  :
                           minimum_f2 ? (  fp_b_nan_f2[1]                                                       |
                                         (~fp_a_nan_f2[1] &  fp_a_sign_f2[1] & ~fp_b_sign_f2[1])                |
                                         (~fp_a_nan_f2[1] & ~fp_a_sign_f2[1] & ~fp_b_sign_f2[1] & ~gtexp_f2[1]) |
                                         (~fp_a_nan_f2[1] &  fp_a_sign_f2[1] &  fp_b_sign_f2[1] &  gtexp_f2[1]))  :
                                        gtexp_f2[1];

  assign exp_add_f2[0] = sel_a_exp_f2[0] ? {1'b0, fp_a_exp_f2[0]} : fp_b_exp_f2[0];
  assign exp_add_f2[1] = sel_a_exp_f2[1] ? {1'b0, fp_a_exp_f2[1]} : fp_b_exp_f2[1];

  // Calculate if the magnitude of a float is too large to fit into an int/fixed-point
  always @*
    case (neon_size_sel_f2)
      2'b01:    f2i_a_exp_threshold_f2 = 12'd89;
      2'b10:    f2i_a_exp_threshold_f2 = 12'd73;
      2'b11:    f2i_a_exp_threshold_f2 = 12'd41;
      default:  f2i_a_exp_threshold_f2 = {12{1'bx}};
    endcase

  assign f2i_overflow_f2[0] = ctl_dual_fp_f2 ? (fp_b_exp_f2[0] > (fp_a_exp_f2[0] - 12'd19))
                                             : (fp_b_exp_f2[0] > (fp_a_exp_f2[0] - f2i_a_exp_threshold_f2));
  assign f2i_overflow_f2[1] = ctl_dual_fp_f2 ? (fp_b_exp_f2[1] > (fp_a_exp_f2[1] - 12'd18))
                                             : f2i_overflow_f2[0];

  // VRSQRTS/FRQSRTS halves the result
  assign dec_exp_res_f2 = (fp_op_f2 == `CA53_FP_OP_HADD);

  // The exponents after unpacking are always biased as if the numbers
  // were double-precision - rebias here to the output format
  always @*
    case ({f2i_f2, neon_size_sel_f2})
      3'b0_11: begin  // Double precision
        exp_opd_f2[0] = exp_add_f2[0]           - dec_exp_res_f2;
        exp_opd_f2[1] = exp_add_f2[1]           - dec_exp_res_f2;
      end

      3'b0_10: begin  // Single precision
        exp_opd_f2[0] = exp_add_f2[0] - 12'h380 - dec_exp_res_f2;
        exp_opd_f2[1] = exp_add_f2[1] - 12'h380 - dec_exp_res_f2;
      end

      3'b0_01: begin  // Half precision
        exp_opd_f2[0] = exp_add_f2[0] - 12'h3F0 - dec_exp_res_f2;
        exp_opd_f2[1] = exp_add_f2[1] - 12'h3F0 - dec_exp_res_f2;
      end

      3'b1_01,
      3'b1_10,
      3'b1_11: begin  // Integer/fixed-point
        exp_opd_f2[0] = 12'h000;
        exp_opd_f2[1] = 12'h000;
      end

      default: begin
        exp_opd_f2[0] = {12{1'bx}};
        exp_opd_f2[1] = {12{1'bx}};
      end
    endcase

  // Compute the flush to zero output
  assign ifz_f2 = |((fp_a_flush_f2 | fp_b_flush_f2) & {ctl_dual_fp_f2, 1'b1});

  // Check if invalid exception for addition/subtraction or comparison
  assign invalid_op_f2[1:0] = (fp_a_snan_f2[1:0] | fp_b_snan_f2[1:0] | sub_infinities_f2[1:0] |
                              (nan_op_f2[1:0] & {2{cmpe_cmd_f2 | f2i_f2 | (s2h_f2 & fpscr_ahp_f2)}}) |
                              (fp_b_infinite_f2[1:0] & {2{s2h_f2 & fpscr_ahp_f2}}))
                              & {ctl_dual_fp_f2, 1'b1};

  // Check if invalid or NaN operation
  assign nan_inv_op_f2 = ctl_dual_fp_f2 ? (nan_op_f2 | sub_infinities_f2)
                                        : {2{nan_op_f2[0] | sub_infinities_f2[0]}};

  // Check if one (or both) of the operands is infinity
  assign infinity_op_f2[0] =                   (sel_a_exp_f2[0] ? fp_a_infinite_f2[0] : fp_b_infinite_f2[0]) & ~f2i_f2 & ~(s2h_f2 & fpscr_ahp_f2) & ~recpx_f2;
  assign infinity_op_f2[1] = ctl_dual_fp_f2 ? ((sel_a_exp_f2[1] ? fp_a_infinite_f2[1] : fp_b_infinite_f2[1]) & ~f2i_f2 & ~(s2h_f2 & fpscr_ahp_f2))
                                            : infinity_op_f2[0];

  // Check if possible zero result
  assign fp_frac_lo_equal_f2 = fp_a_frac_f2[ 53: 1] == fp_b_frac_f2[ 53: 1];
  assign fp_frac_hi_equal_f2 = fp_a_frac_f2[106:54] == fp_b_frac_f2[106:54];

  assign equal_opnd_f2[0] = eqexp_f2[0] & fp_frac_hi_equal_f2 & (ctl_dual_fp_f2 | fp_frac_lo_equal_f2);
  assign equal_opnd_f2[1] = eqexp_f2[1] & fp_frac_lo_equal_f2;

  assign zres_f2[0] =                   sub_f2[0] & equal_opnd_f2[0] & ~f2i_f2 & ~(fp_a_zero_f2[0] & ~fp_b_zero_f2[0]);
  assign zres_f2[1] = ctl_dual_fp_f2 ? (sub_f2[1] & equal_opnd_f2[1] & ~f2i_f2 & ~(fp_a_zero_f2[1] & ~fp_b_zero_f2[1]))
                                     : zres_f2[0];

  assign zero_res_f2[1:0] = ~nan_op_f2[1:0] & (zres_f2[1:0] | zero_op_f2[1:0]) & {2{~maximum_f2 & ~minimum_f2}};

  // Swap operands if required
  assign fp_frac_lo_gt_f2 = fp_a_frac_f2[ 53: 1] > fp_b_frac_f2[ 53: 1];
  assign fp_frac_hi_gt_f2 = fp_a_frac_f2[106:54] > fp_b_frac_f2[106:54];

  assign gtopnd_f2[0] =  gtexp_f2[0] | (eqexp_f2[0] & ~fp_a_flush_f2[0] &
                                        (fp_frac_hi_gt_f2 | (ctl_dual_fp_f2 & fp_frac_hi_equal_f2 & fp_frac_lo_gt_f2)));
  assign gtopnd_f2[1] =  gtexp_f2[1] | (eqexp_f2[1] & ~fp_a_flush_f2[1] & fp_frac_lo_gt_f2);

  // Generate a constant which, when added to the shifted fraction,
  // correctly rounds a float-to-int conversion
  assign f2i_low_sign_f2 = ctl_dual_fp_f2 ? fp_b_sign_f2[1] : fp_b_sign_f2[0];

  always @*
    case (rnd_mode_f2)
      `CA53_FP_RMODE_RN:  f2i_roundval_f2[0][1:0] = (shfrc_opb_f2[ 2] ^ sub_mux_f2[1])   ? 2'b10 : 2'b01; // Round to nearest (ties to even)
      `CA53_FP_RMODE_RP:  f2i_roundval_f2[0][1:0] = ( rnd_integral_f2 & f2i_low_sign_f2) ? 2'b00 : 2'b11; // Round to positive infinity
      `CA53_FP_RMODE_RM:  f2i_roundval_f2[0][1:0] = ( rnd_integral_f2 & f2i_low_sign_f2) ? 2'b11 : 2'b00; // Round to negative infinity
      `CA53_FP_RMODE_RZ:  f2i_roundval_f2[0][1:0] = (~rnd_integral_f2 & f2i_low_sign_f2) ? 2'b11 : 2'b00; // Round to zero
      `CA53_FP_RMODE_RA:  f2i_roundval_f2[0][1:0] = (~rnd_integral_f2 & f2i_low_sign_f2) ? 2'b01 : 2'b10; // Round to nearest (ties away from zero)
      default:            f2i_roundval_f2[0][1:0] = 2'bxx;
    endcase

  always @*
    case (rnd_mode_f2)
      `CA53_FP_RMODE_RN:  f2i_roundval_f2[1][1:0] = (shfrc_opb_f2[56] ^ sub_mux_f2[0])   ? 2'b10 : 2'b01; // Round to nearest (ties to even)
      `CA53_FP_RMODE_RP:  f2i_roundval_f2[1][1:0] = ( rnd_integral_f2 & fp_b_sign_f2[0]) ? 2'b00 : 2'b11; // Round to positive infinity
      `CA53_FP_RMODE_RM:  f2i_roundval_f2[1][1:0] = ( rnd_integral_f2 & fp_b_sign_f2[0]) ? 2'b11 : 2'b00; // Round to negative infinity
      `CA53_FP_RMODE_RZ:  f2i_roundval_f2[1][1:0] = (~rnd_integral_f2 & fp_b_sign_f2[0]) ? 2'b11 : 2'b00; // Round to zero
      `CA53_FP_RMODE_RA:  f2i_roundval_f2[1][1:0] = (~rnd_integral_f2 & fp_b_sign_f2[0]) ? 2'b01 : 2'b10; // Round to nearest (ties away from zero)
      default:            f2i_roundval_f2[1][1:0] = 2'bxx;
    endcase

  assign swap_opnd_f2[0] = (nan_op_f2[0] & ~s2h_f2)       ? ~nsnan_opb_f2[0]                                                           :
                           maximum_f2                     ? (  fp_a_nan_f2[0]                                                        |
                                                             (~fp_b_nan_f2[0] &  fp_a_sign_f2[0] & ~fp_b_sign_f2[0])                 |
                                                             (~fp_b_nan_f2[0] & ~fp_a_sign_f2[0] & ~fp_b_sign_f2[0] & ~gtopnd_f2[0]) |
                                                             (~fp_b_nan_f2[0] &  fp_a_sign_f2[0] &  fp_b_sign_f2[0] &  gtopnd_f2[0]))  :
                           minimum_f2                     ? (  fp_a_nan_f2[0]                                                        |
                                                             (~fp_b_nan_f2[0] & ~fp_a_sign_f2[0] &  fp_b_sign_f2[0])                 |
                                                             (~fp_b_nan_f2[0] & ~fp_a_sign_f2[0] & ~fp_b_sign_f2[0] &  gtopnd_f2[0]) |
                                                             (~fp_b_nan_f2[0] &  fp_a_sign_f2[0] &  fp_b_sign_f2[0] & ~gtopnd_f2[0]))  :
                           (i2f_f2 | f2i_f2 | abs_neg_f2) ? 1'b0                                                                       :
                                                            ~gtopnd_f2[0];

  assign swap_opnd_f2[1] = (nan_op_f2[1] & ~s2h_f2)       ? ~nsnan_opb_f2[1]                                                           :
                           maximum_f2                     ? (  fp_a_nan_f2[1]                                                        |
                                                             (~fp_b_nan_f2[1] &  fp_a_sign_f2[1] & ~fp_b_sign_f2[1])                 |
                                                             (~fp_b_nan_f2[1] & ~fp_a_sign_f2[1] & ~fp_b_sign_f2[1] & ~gtopnd_f2[1]) |
                                                             (~fp_b_nan_f2[1] &  fp_a_sign_f2[1] &  fp_b_sign_f2[1] &  gtopnd_f2[1]))  :
                           minimum_f2                     ? (  fp_a_nan_f2[1]                                                        |
                                                             (~fp_b_nan_f2[1] & ~fp_a_sign_f2[1] &  fp_b_sign_f2[1])                 |
                                                             (~fp_b_nan_f2[1] & ~fp_a_sign_f2[1] & ~fp_b_sign_f2[1] &  gtopnd_f2[1]) |
                                                             (~fp_b_nan_f2[1] &  fp_a_sign_f2[1] &  fp_b_sign_f2[1] & ~gtopnd_f2[1]))  :
                           (i2f_f2 | f2i_f2 | abs_neg_f2) ? 1'b0                                                                       :
                                                            ~gtopnd_f2[1];

  assign shift_opnd_f2[0] = ~eqexp_f2[0] & ~i2f_f2 & ~abs_neg_f2;
  assign shift_opnd_f2[1] = ~eqexp_f2[1] & ~i2f_f2 & ~abs_neg_f2 & ~s2h_scalar_f2;

  assign sel_a_hi_from_a  = ~swap_opnd_f2[0] & ~fp_a_flush_f2[0];
  assign sel_a_hi_from_b  =  swap_opnd_f2[0] & ~fp_b_flush_f2[0] & ~(recpx_f2 & ~nan_op_f2[0]);

  assign sel_a_lo_from_a  = ctl_no_dual_fp_f2 ? sel_a_hi_from_a  : (~swap_opnd_f2[1] & ~fp_a_flush_f2[1]);
  assign sel_a_lo_from_b  = ctl_no_dual_fp_f2 ? sel_a_hi_from_b  : ( swap_opnd_f2[1] & ~fp_b_flush_f2[1]);

  assign sel_b_hi_from_sh = (shift_opnd_f2[0] &  swap_opnd_f2[0] & ~fp_a_flush_f2[0] & ~maximum_f2 & ~minimum_f2) |
                            (shift_opnd_f2[0] & ~swap_opnd_f2[0] & ~fp_b_flush_f2[0] & ~maximum_f2 & ~minimum_f2);
  assign sel_b_hi_from_a  = ~shift_opnd_f2[0] &  swap_opnd_f2[0] & ~fp_a_flush_f2[0] & ~maximum_f2 & ~minimum_f2;
  assign sel_b_hi_from_b  = ~shift_opnd_f2[0] & ~swap_opnd_f2[0] & (~fp_b_flush_f2[0] | abs_neg_f2) & ~maximum_f2 & ~minimum_f2;

  assign sel_b_lo_from_sh = ctl_no_dual_fp_f2 ? sel_b_hi_from_sh
                                              : ((shift_opnd_f2[1] &  swap_opnd_f2[1] & ~fp_a_flush_f2[1] & ~maximum_f2 & ~minimum_f2) |
                                                 (shift_opnd_f2[1] & ~swap_opnd_f2[1] & ~fp_b_flush_f2[1] & ~maximum_f2 & ~minimum_f2));
  assign sel_b_lo_from_a  = ctl_no_dual_fp_f2 ? sel_b_hi_from_a
                                              : (~shift_opnd_f2[1] &  swap_opnd_f2[1] & ~fp_a_flush_f2[1] & ~maximum_f2 & ~minimum_f2);
  assign sel_b_lo_from_b  = ctl_no_dual_fp_f2 ? sel_b_hi_from_b
                                              : (~shift_opnd_f2[1] & ~swap_opnd_f2[1] & (~fp_b_flush_f2[1] | abs_neg_f2) & ~maximum_f2 & ~minimum_f2);


  assign swap_frc_opa_f2[106:54] = ({53{sel_a_hi_from_a}}             & fp_a_frac_f2[106:54]) |
                                   ({53{sel_a_hi_from_b}}             & fp_b_frac_f2[106:54]) |
                                   ({53{(f2i_f2 | rnd_integral_f2) &
                                        ctl_dual_fp_f2}}              & { {51{1'b0}}, f2i_roundval_f2[1]});

  assign swap_frc_opa_f2[ 53: 0] = ({54{sel_a_lo_from_a}}             & {fp_a_frac_f2[ 53: 1], 1'b0}) |
                                   ({54{sel_a_lo_from_b}}             & {fp_b_frac_f2[ 53: 1], 1'b0}) |
                                   ({54{(f2i_f2 | rnd_integral_f2)}}  & { {52{1'b0}}, f2i_roundval_f2[0]});

  assign swap_frc_opb_f2[107:54] = ({54{sel_b_hi_from_sh}}            & {1'b0, shfrc_opb_f2[106:54]}) |
                                   ({54{sel_b_hi_from_a}}             & {1'b0, fp_a_frac_f2[106:54]}) |
                                   ({54{sel_b_hi_from_b}}             & fp_b_frac_f2[107:54])        ;

  assign swap_frc_opb_f2[ 53: 0] = ({54{sel_b_lo_from_sh}}            & shfrc_opb_f2[53:0])         |
                                   ({54{sel_b_lo_from_a}}             & {fp_a_frac_f2[53:1], 1'b0}) |
                                   ({54{sel_b_lo_from_b}}             & {fp_b_frac_f2[53:1], 1'b0});

  // Shift second operand

  ca53dpu_fp_alu_denorm u_denorm (
    .fp_a_frac_f2_i   (fp_a_frac_f2),
    .fp_b_frac_f2_i   (fp_b_frac_f2),
    .fp_a_zero_f2_i   (fp_a_zero_f2),
    .fp_b_zero_f2_i   (fp_b_zero_f2),
    .raw_gtexp_f2_i   (raw_gtexp_f2),
    .fp_a_exp_0_f2_i  (fp_a_exp_f2[0]),
    .fp_a_exp_1_f2_i  (fp_a_exp_f2[1]),
    .fp_b_exp_0_f2_i  (fp_b_exp_f2[0]),
    .fp_b_exp_1_f2_i  (fp_b_exp_f2[1]),
    .dual_op_i        (ctl_dual_fp_f2),
    .result_o         (shfrc_opb_f2)
  );

  // Calculate if a float->int conversion is inexact
  assign f2i_inexact_f2[0] = (f2i_f2 | (fp_op_f2 == `CA53_FP_OP_RINTX)) & (ctl_dual_fp_f2 ? (|shfrc_opb_f2[55:54]) : (|shfrc_opb_f2[1:0]));
  assign f2i_inexact_f2[1] = (f2i_f2 | (fp_op_f2 == `CA53_FP_OP_RINTX)) &  ctl_dual_fp_f2 & (|shfrc_opb_f2[1:0]);

  // Select second operand to be zero if NaN operation
  assign sub_mux_f2[0] =                   sub_f2[0] & ~nan_inv_op_f2[0];
  assign sub_mux_f2[1] = ctl_dual_fp_f2 ? (sub_f2[1] & ~nan_inv_op_f2[1]) : sub_mux_f2[0];

  assign muxfrc_opa_f2[106:54] = ({53{~nan_op_f2[0] | (~force_dn_fz_f2 & ~fpscr_dn_f2 & ~(s2h_f2 & fpscr_ahp_f2)) | abs_neg_f2}} & swap_frc_opa_f2[106:54]) |
                                 {{2{nan_inv_op_f2[0] & ~(s2h_f2 & fpscr_ahp_f2) & ~abs_neg_f2}}, {51{1'b0}} }                                              |
                                 {recpx_f2, {52{1'b0}} };
  assign muxfrc_opa_f2[ 53: 0] = ({54{~nan_op_f2[1] | (~force_dn_fz_f2 & ~fpscr_dn_f2 & ~(s2h_f2 & fpscr_ahp_f2)) | abs_neg_f2}} & swap_frc_opa_f2[ 53: 0]) |
                                 {2'b00, {2{ctl_dual_fp_f2 & nan_inv_op_f2[1] & ~(s2h_f2 & fpscr_ahp_f2) & ~abs_neg_f2}}, {50{1'b0}} } |
                                 {(ctl_dual_fp_f2 & sub_mux_f2[0]), {53{1'b0}} };

  assign muxfrc_opb_f2[107:54] =  {54{~nan_inv_op_f2[0]}} & swap_frc_opb_f2[107:54];
  assign muxfrc_opb_f2[ 53: 0] = ({54{~nan_inv_op_f2[1]}} & swap_frc_opb_f2[ 53: 0]) |
                                 {(ctl_dual_fp_f2 & (sub_mux_f2[1] ^ sub_mux_f2[0])), {53{1'b0}} };

  // Compute the sign
  assign sign_f2[0] = ~sub_infinities_f2[0] & (zero_res_f2[0] ? ((((rnd_mode_f2 == `CA53_FP_RMODE_RM) |
                                                                   s2d_f2 | d2s_f2 | s2h_f2 | abs_neg_f2 | rnd_integral_f2) &
                                                                  (fp_a_sign_f2[0] | fp_b_sign_f2[0])) | (fp_a_sign_f2[0] & fp_b_sign_f2[0]))
                                                              : ((~swap_opnd_f2[0] & ~s2d_f2 & ~d2s_f2 & ~abs_neg_f2 & ~rnd_integral_f2)
                                                                 ? fp_a_sign_f2[0] : fp_b_sign_f2[0]));
  assign sign_f2[1] = ctl_no_dual_fp_f2 ? sign_f2[0] :
                      (~sub_infinities_f2[1] & (zero_res_f2[1] ? ((((rnd_mode_f2 == `CA53_FP_RMODE_RM) |
                                                                    s2d_f2 | d2s_f2 | s2h_f2 | abs_neg_f2 | rnd_integral_f2) &
                                                                   (fp_a_sign_f2[1] | fp_b_sign_f2[1])) | (fp_a_sign_f2[1] & fp_b_sign_f2[1]))
                                                               : ((~swap_opnd_f2[1] & ~s2d_f2 & ~d2s_f2 & ~abs_neg_f2 & ~rnd_integral_f2)
                                                                  ? fp_a_sign_f2[1] : fp_b_sign_f2[1])));

  // Absolute floating point comparison
  assign abs_sign_a_f2 = {2{~abs_neg_f2}} & fp_a_sign_f2[1:0];
  assign abs_sign_b_f2 = {2{~abs_neg_f2}} & fp_b_sign_f2[1:0];

  // Performs comparison
  function [1:0] fp_cmp (
    input nan_op,
    input zero_op,
    input a_inf,
    input b_inf,
    input a_sign,
    input b_sign,
    input gt,
    input eq
  );
    fp_cmp = nan_op              ? 2'b00                                    : // Incomparable if either is NaN
             (a_inf & b_inf)     ? {(~a_sign & b_sign), (a_sign == b_sign)} : // Both infinite, compare signs
             a_inf               ? {~a_sign, 1'b0}                          : // Only A infinite, A larger if positive
             b_inf               ? { b_sign, 1'b0}                          : // Only B infinite, A larger if B negative
             zero_op             ? 2'b01                                    : // Both zero, equal regardless of signs
             (~a_sign & ~b_sign) ? {~eq &  gt, eq}                          : // Both positive, A larger if magnitude greater
             ( a_sign &  b_sign) ? {~eq & ~gt, eq}                          : // Both negative, A larger if magnitude lesser
                                   {~a_sign, 1'b0};                           // Signs differ, A larger if positive
  endfunction

  assign {cmp_agtb_f2[0], cmp_aeqb_f2[0]} = fp_cmp(nan_op_f2[0], zero_op_f2[0], fp_a_infinite_f2[0], fp_b_infinite_f2[0],
                                                   abs_sign_a_f2[0], abs_sign_b_f2[0], gtopnd_f2[0], equal_opnd_f2[0]);
  assign {cmp_agtb_f2[1], cmp_aeqb_f2[1]} = fp_cmp(nan_op_f2[1], zero_op_f2[1], fp_a_infinite_f2[1], fp_b_infinite_f2[1],
                                                   abs_sign_a_f2[1], abs_sign_b_f2[1], gtopnd_f2[1], equal_opnd_f2[1]);

  //  RESULT   | N Z C V
  // -------------------
  //   A = B   | 0 1 1 0
  //   A < B   | 1 0 0 0
  //   A > B   | 0 0 1 0
  // Unordered | 0 0 1 1

  assign cmpflags_f2 = {cmp_agtb_f2[0], cmp_aeqb_f2[0], ~cmp_agtb_f2[0], nan_op_f2[0]};

  //----------------------------------
  // Neon Permutation Block
  //----------------------------------

  ca53dpu_neon_permutation u_permutation (
    // Inputs
    .frc_opa_f2_i          (fad_a_data_f2),
    .frc_opb_f2_i          (fad_b_data_f2),
    .neon_frc_opc_f2_i     (fad_c_data_f2),
    // Outputs
    .neon_perm_opa_f2_o    (neon_perm_opa_f2),
    .neon_perm_opb_f2_o    (neon_perm_opb_f2)
  );

  //----------------------------------
  // Neon Comparison Block
  //----------------------------------

  ca53dpu_neon_swap_max u_neon_swap_max (
    // Inputs
    .neon_size_sel_f2_i     (neon_size_sel_f2),
    .neon_unsigned_op_f2_i  (neon_unsigned_op_f2),
    .neon_perm_opa_f2_i     (neon_perm_opa_f2),
    .neon_perm_opb_f2_i     (neon_perm_opb_f2),
    // Outputs
    .neon_swap_max_f2_o     (neon_swap_max_f2),
    .neon_swap_min_f2_o     (neon_swap_min_f2),
    .neon_cmp_gt_f2_o       (neon_cmp_gt_f2),
    .neon_cmp_eq_f2_o       (neon_cmp_eq_f2)
  );

  //----------------------------------
  // Neon Shift Block
  //----------------------------------

  ca53dpu_neon_shift u_neon_shift (
    // Inputs
    .neon_size_f2_i         (neon_size_sel_f2),
    .neon_unsigned_f2_i     (neon_unsigned_op_f2),
    .neon_narrowing_op_f2_i (neon_narrowing_op_f2),
    .neon_mask_sel_f2_i     (neon_mask_sel_f2),
    .neon_shift_reg_f2_i    (neon_shift_reg_f2),
    .imm_data_f2_i          (imm_data_f2_i),
    .frc_opa_f2_i           (fad_a_data_f2),
    .frc_opb_f2_i           (fad_b_data_f2),
    .neon_perm_opa_f2_i     (neon_perm_opa_f2),
    .neon_perm_opb_f2_i     (neon_perm_opb_f2),
    // Outputs
    .neon_shift_res_f2_o    (neon_shift_res_f2),
    .neon_shift_round_f2_o  (neon_shift_round_f2),
    .neon_shift_mask_f2_o   (neon_shift_mask_f2),
    .neon_sat_res_f2_o      (neon_sat_dtect_f2)
  );

  //----------------------------------
  // Neon reduction add block
  //----------------------------------

  generate if (IS_PIPE0) begin : g_reduce
    wire  neon_reduce_f1;
    wire  neon_reduce_size_sel_f1;
    reg   neon_reduce_f2;
    reg   neon_reduce_size_sel_f2;

    assign neon_reduce_size_sel_f1 = neon_width_op_sel_f1 == 3'b011;
    assign neon_reduce_f1          = neon_fctn_sel_f1 == `CA53_NEON_FCTN_ADDV;

    always @(posedge clk_fp_alu)
      if (advance_f1) begin
        neon_reduce_size_sel_f2 <= neon_reduce_size_sel_f1;
        neon_reduce_f2          <= neon_reduce_f1;
      end

    ca53dpu_neon_reduce u_neon_reduce (
      // Inputs
      .neon_reduce_f2_i          (neon_reduce_f2),
      .neon_reduce_size_sel_f2_i (neon_reduce_size_sel_f2),
      .neon_size_sel_f2_i        (neon_size_sel_f2),
      .neon_unsigned_op_f2_i     (neon_unsigned_op_f2),
      .fad_a_data_f2_i           (fad_a_data_f2),
      .fad_b_data_f2_i           (fad_b_data_f2),
      // Outputs
      .neon_reduce_opa_f2_o      (neon_reduce_opa_f2),
      .neon_reduce_opb_f2_o      (neon_reduce_opb_f2)
    );
  end else begin : g_reduce_stubs
    assign neon_reduce_opa_f2 = {64{1'b0}};
    assign neon_reduce_opb_f2 = {64{1'b0}};
  end endgenerate

  //----------------------------------
  // Neon CLS block
  //----------------------------------

  // Check the sign of the operand and if
  // negative invert it in order to use the
  // count leading zeros block in the next stage
  always @*
    case (neon_size_sel_f2)
      2'b00: begin // 8-bits
        neon_cls_res_f2[63:56] = {{7{fad_a_data_f2[63]}} ^ fad_a_data_f2[62:56], 1'b1};
        neon_cls_res_f2[55:48] = {{7{fad_a_data_f2[55]}} ^ fad_a_data_f2[54:48], 1'b1};
        neon_cls_res_f2[47:40] = {{7{fad_a_data_f2[47]}} ^ fad_a_data_f2[46:40], 1'b1};
        neon_cls_res_f2[39:32] = {{7{fad_a_data_f2[39]}} ^ fad_a_data_f2[38:32], 1'b1};
        neon_cls_res_f2[31:24] = {{7{fad_a_data_f2[31]}} ^ fad_a_data_f2[30:24], 1'b1};
        neon_cls_res_f2[23:16] = {{7{fad_a_data_f2[23]}} ^ fad_a_data_f2[22:16], 1'b1};
        neon_cls_res_f2[15:8]  = {{7{fad_a_data_f2[15]}} ^ fad_a_data_f2[14: 8], 1'b1};
        neon_cls_res_f2[7:0]   = {{7{fad_a_data_f2[7]}}  ^ fad_a_data_f2[ 6: 0], 1'b1};
      end
      2'b01: begin // 16-bits
        neon_cls_res_f2[63:48] = {{15{fad_a_data_f2[63]}} ^ fad_a_data_f2[62:48], 1'b1};
        neon_cls_res_f2[47:32] = {{15{fad_a_data_f2[47]}} ^ fad_a_data_f2[46:32], 1'b1};
        neon_cls_res_f2[31:16] = {{15{fad_a_data_f2[31]}} ^ fad_a_data_f2[30:16], 1'b1};
        neon_cls_res_f2[15:0]  = {{15{fad_a_data_f2[15]}} ^ fad_a_data_f2[14: 0], 1'b1};
      end
      2'b10: begin // 32-bits
        neon_cls_res_f2[63:32] = {{31{fad_a_data_f2[63]}} ^ fad_a_data_f2[62:32], 1'b1};
        neon_cls_res_f2[31:0]  = {{31{fad_a_data_f2[31]}} ^ fad_a_data_f2[30: 0], 1'b1};
      end
      default:
        neon_cls_res_f2[63:0] = {64{1'bx}};
    endcase

  //----------------------------------
  // Neon CNT block
  //----------------------------------
  function [3:0] count_ones;
  // Counts ones of an input operand
    input [7:0]   opa;
    begin
      count_ones = (opa[7]  +
                    opa[6]  +
                    opa[5]  +
                    opa[4]  +
                    opa[3]  +
                    opa[2]  +
                    opa[1]  +
                    opa[0]);
    end
  endfunction

  // Counts ones for every 8-bit element of an input operand
  // and produces a vector result
  assign neon_cnt_res_f2[63:56] = {4'b0000, count_ones(fad_a_data_f2[63:56])};
  assign neon_cnt_res_f2[55:48] = {4'b0000, count_ones(fad_a_data_f2[55:48])};
  assign neon_cnt_res_f2[47:40] = {4'b0000, count_ones(fad_a_data_f2[47:40])};
  assign neon_cnt_res_f2[39:32] = {4'b0000, count_ones(fad_a_data_f2[39:32])};
  assign neon_cnt_res_f2[31:24] = {4'b0000, count_ones(fad_a_data_f2[31:24])};
  assign neon_cnt_res_f2[23:16] = {4'b0000, count_ones(fad_a_data_f2[23:16])};
  assign neon_cnt_res_f2[15:8]  = {4'b0000, count_ones(fad_a_data_f2[15: 8])};
  assign neon_cnt_res_f2[7:0]   = {4'b0000, count_ones(fad_a_data_f2[ 7: 0])};

  //----------------------------------
  // Neon RBIT instruction
  //----------------------------------
  function [7:0] rbit;
    input [7:0]   opb;
    begin
      rbit = {opb[0], opb[1], opb[2], opb[3], opb[4], opb[5], opb[6], opb[7]};
    end
  endfunction

  assign neon_rbit_res_f2[63:56] = rbit(fad_b_data_f2[63:56]);
  assign neon_rbit_res_f2[55:48] = rbit(fad_b_data_f2[55:48]);
  assign neon_rbit_res_f2[47:40] = rbit(fad_b_data_f2[47:40]);
  assign neon_rbit_res_f2[39:32] = rbit(fad_b_data_f2[39:32]);
  assign neon_rbit_res_f2[31:24] = rbit(fad_b_data_f2[31:24]);
  assign neon_rbit_res_f2[23:16] = rbit(fad_b_data_f2[23:16]);
  assign neon_rbit_res_f2[15: 8] = rbit(fad_b_data_f2[15: 8]);
  assign neon_rbit_res_f2[ 7: 0] = rbit(fad_b_data_f2[ 7: 0]);

  //----------------------------------
  // Neon valid vector for VTBL/VTBX
  //----------------------------------

  function [7:0] valid_bytes_vector_cycle;
    // Checks if the byte indexes from the control vector
    // are within a valid range and produces a valid vector
    input [7:0] vector_ctl;
    input       unsigned_op;
    input [1:0] size;
    reg   [2:0] vec_len;
    reg         valid_byte;
    begin
      vec_len = {unsigned_op, size};
      valid_byte = ~(|vector_ctl[7:6]) & (vector_ctl[5:4] == vec_len[2:1]) & ~(vector_ctl[3] & ~vec_len[0]);
      valid_bytes_vector_cycle = {8{valid_byte}};
    end
  endfunction

  function [7:0] valid_bytes_vector_final;
    // Checks if the byte indexes from the control vector
    // are within a valid range and produces a valid vector
    input [7:0] vector_ctl;
    input       unsigned_op;
    input [1:0] size;
    reg   [2:0] vec_len;
    reg         valid_byte;
    begin
      vec_len = {unsigned_op, size};
      valid_byte = ~(|vector_ctl[7:6]) & (vector_ctl[5:3] <= vec_len);
      valid_bytes_vector_final = {8{valid_byte}};
    end
  endfunction

  // Produces the valid vector for VTBL/VTBX
  assign neon_valid_bytes_vector_cycle_f2[63:56] = valid_bytes_vector_cycle(fad_c_data_f2[63:56], neon_unsigned_op_f2, neon_size_sel_f2);
  assign neon_valid_bytes_vector_cycle_f2[55:48] = valid_bytes_vector_cycle(fad_c_data_f2[55:48], neon_unsigned_op_f2, neon_size_sel_f2);
  assign neon_valid_bytes_vector_cycle_f2[47:40] = valid_bytes_vector_cycle(fad_c_data_f2[47:40], neon_unsigned_op_f2, neon_size_sel_f2);
  assign neon_valid_bytes_vector_cycle_f2[39:32] = valid_bytes_vector_cycle(fad_c_data_f2[39:32], neon_unsigned_op_f2, neon_size_sel_f2);
  assign neon_valid_bytes_vector_cycle_f2[31:24] = valid_bytes_vector_cycle(fad_c_data_f2[31:24], neon_unsigned_op_f2, neon_size_sel_f2);
  assign neon_valid_bytes_vector_cycle_f2[23:16] = valid_bytes_vector_cycle(fad_c_data_f2[23:16], neon_unsigned_op_f2, neon_size_sel_f2);
  assign neon_valid_bytes_vector_cycle_f2[15: 8] = valid_bytes_vector_cycle(fad_c_data_f2[15: 8], neon_unsigned_op_f2, neon_size_sel_f2);
  assign neon_valid_bytes_vector_cycle_f2[ 7: 0] = valid_bytes_vector_cycle(fad_c_data_f2[ 7: 0], neon_unsigned_op_f2, neon_size_sel_f2);

  assign neon_valid_bytes_vector_final_f2[63:56] = valid_bytes_vector_final(fad_c_data_f2[63:56], neon_unsigned_op_f2, neon_size_sel_f2);
  assign neon_valid_bytes_vector_final_f2[55:48] = valid_bytes_vector_final(fad_c_data_f2[55:48], neon_unsigned_op_f2, neon_size_sel_f2);
  assign neon_valid_bytes_vector_final_f2[47:40] = valid_bytes_vector_final(fad_c_data_f2[47:40], neon_unsigned_op_f2, neon_size_sel_f2);
  assign neon_valid_bytes_vector_final_f2[39:32] = valid_bytes_vector_final(fad_c_data_f2[39:32], neon_unsigned_op_f2, neon_size_sel_f2);
  assign neon_valid_bytes_vector_final_f2[31:24] = valid_bytes_vector_final(fad_c_data_f2[31:24], neon_unsigned_op_f2, neon_size_sel_f2);
  assign neon_valid_bytes_vector_final_f2[23:16] = valid_bytes_vector_final(fad_c_data_f2[23:16], neon_unsigned_op_f2, neon_size_sel_f2);
  assign neon_valid_bytes_vector_final_f2[15: 8] = valid_bytes_vector_final(fad_c_data_f2[15: 8], neon_unsigned_op_f2, neon_size_sel_f2);
  assign neon_valid_bytes_vector_final_f2[ 7: 0] = valid_bytes_vector_final(fad_c_data_f2[ 7: 0], neon_unsigned_op_f2, neon_size_sel_f2);

  //----------------------------------
  // Cryptography block for SHA instructions
  // Only present if crypto configured
  //----------------------------------

  generate if (CRYPTO) begin : g_sha
    ca53dpu_crypto_alu_sha #(.IS_PIPE0(IS_PIPE0)) u_crypto_sha256su0 (
      // Inputs
      .fad_a_data_f2_i    (fad_a_data_f2[63:0]),
      .fad_b_data_f2_i    (fad_b_data_f2[63:0]),
      .fad_c_data_f2_i    (fad_c_data_f2[63:0]),
      // Outputs
      .sha1h_res_f2_o     (sha1h_res_f2[63:0]),
      .sha1su0_opa_f2_o   (sha1su0_opa_f2[63:0]),
      .sha1su0_opb_f2_o   (sha1su0_opb_f2[63:0]),
      .sha256su0_opa_f2_o (sha256su0_opa_f2[63:0]),
      .sha256su0_opb_f2_o (sha256su0_opb_f2[63:0])
    );
  end else begin : g_sha_stubs
    assign sha1h_res_f2     = {64{1'b0}};
    assign sha1su0_opa_f2   = {64{1'b0}};
    assign sha1su0_opb_f2   = {64{1'b0}};
    assign sha256su0_opa_f2 = {64{1'b0}};
    assign sha256su0_opb_f2 = {64{1'b0}};
  end endgenerate

  // MUX to select between the 3d input operand and the feedback mask result
  // of the F3 stage for the VTBL/VTBX instructions or the saturation detect
  // result
  // Also factor in the mux select control from the conditional select logic
  // in the integer ALU
  assign neon_nxt_frc_opc_f3 = (neon_fctn_sel_f2 == `CA53_NEON_FCTN_PERM)             ? {64{alu0_csel_pass_ex2_i}} :
                               neon_vtb_cycle_f2                                    ? raw_neon_lu_res_f3         :
                               ((neon_sat_op_sel_f2 == `CA53_NEON_SAT_SHF_SIGNED) |
                                (neon_sat_op_sel_f2 == `CA53_NEON_SAT_SHF_UNSIGNED))  ? neon_sat_dtect_f2          :
                                neon_mask_sel_f2                                    ? neon_shift_mask_f2         :
                                                                                      fad_c_data_f2;

  // Rounding logic for VRADDHN/VRSUBHN instructions
  always @*
    case (neon_size_sel_f2)
      2'b01: // 16-bits
        neon_rnd_opb_f2 = {16'h0080, 16'h0080, 16'h0080, 16'h0080};
      2'b10: // 32-bits
        neon_rnd_opb_f2 = {32'h00008000, 32'h00008000};
      2'b11: // 64-bits
        neon_rnd_opb_f2 = {{32{1'b0}}, 32'h80000000};
      default:
        neon_rnd_opb_f2 = {64{1'bx}};
    endcase

  // Neon MUX that selects the output operands from Neon blocks

  always @*
    case (neon_fctn_sel_f2)
      `CA53_NEON_FCTN_PERM: begin // permutation operation only
        neon_opa_f2 = neon_perm_opa_f2;
        neon_opb_f2 = neon_perm_opb_f2;
      end
      `CA53_NEON_FCTN_ADDSUBHN: begin // VRADDHN/VRSUBHN  operation
        neon_opa_f2 = neon_res_f3;
        neon_opb_f2 = neon_rnd_opb_f2;
      end
      `CA53_NEON_FCTN_TBL_TBX: begin // VTBL/VTBX operation
        neon_opa_f2 = neon_perm_opa_f2;
        neon_opb_f2 = neon_valid_bytes_vector_cycle_f2;
      end
      `CA53_NEON_FCTN_TBX_FINAL: begin // VTBX operation in the 3d cycle
        neon_opa_f2 = fad_a_data_f2;
        neon_opb_f2 = neon_valid_bytes_vector_final_f2;
      end
      `CA53_NEON_FCTN_SWAP_MAX: begin // swap_max operation
        neon_opa_f2 = neon_swap_max_f2;
        neon_opb_f2 = neon_swap_min_f2;
      end
      `CA53_NEON_FCTN_CMP: begin // comparison operation
        neon_opa_f2 = neon_int_sel_f2 ? neon_cmp_gt_f2 : { {32{ctl_dual_fp_f2 ? cmp_agtb_f2[1] : ((neon_size_sel_f2 == 2'b11) & cmp_agtb_f2[0])}},
                                                           {32{cmp_agtb_f2[0]}} };
        neon_opb_f2 = neon_int_sel_f2 ? neon_cmp_eq_f2 : { {32{ctl_dual_fp_f2 ? cmp_aeqb_f2[1] : ((neon_size_sel_f2 == 2'b11) & cmp_aeqb_f2[0])}},
                                                           {32{cmp_aeqb_f2[0]}} };
      end
      `CA53_NEON_FCTN_SHIFT: begin // shift operation
        neon_opa_f2 = neon_shift_res_f2;
        neon_opb_f2 = 64'h0000000000000000;
      end
      `CA53_NEON_FCTN_NONE: begin // no change in the input operands
        neon_opa_f2 = fad_a_data_f2;
        neon_opb_f2 = fad_b_data_f2;
      end
      `CA53_NEON_FCTN_CLS: begin // count leading sign bits operation
        neon_opa_f2 = 64'h0000000000000000;
        neon_opb_f2 = neon_cls_res_f2;
      end
      `CA53_NEON_FCTN_CNT: begin // count ones operation
        neon_opa_f2 = neon_cnt_res_f2;
        neon_opb_f2 = 64'h0000000000000000;
      end
      `CA53_NEON_FCTN_ACCUM: begin // addition feedback result for accumulation
        neon_opa_f2 = fad_a_data_f2;
        neon_opb_f2 = neon_res_f3;
      end
      `CA53_NEON_FCTN_PERM_FB: begin // feedback path for VSWP/VTRN/VZIP/VUZP
        neon_opa_f2 = neon_opb_f3;
        neon_opb_f2 = 64'h0000000000000000;
      end
      `CA53_NEON_FCTN_RND_SHIFT: begin // rounding shift operation
        neon_opa_f2 = neon_shift_res_f2;
        neon_opb_f2 = neon_shift_round_f2;
      end
      `CA53_NEON_FCTN_INS_SHIFT: begin // shift and accumulate/insert
        neon_opa_f2 = neon_shift_res_f2;
        neon_opb_f2 = fad_b_data_f2;
      end
      `CA53_NEON_FCTN_RBIT: begin // RBIT
        neon_opa_f2 = neon_rbit_res_f2;
        neon_opb_f2 = 64'h0000000000000000;
      end
      `CA53_NEON_FCTN_SHA1H: begin // SHA1H
        neon_opa_f2 = sha1h_res_f2;
        neon_opb_f2 = 64'h0000000000000000;
      end
      `CA53_NEON_FCTN_SHA1SU0: begin // SHA1SU0
        neon_opa_f2 = sha1su0_opa_f2;
        neon_opb_f2 = sha1su0_opb_f2;
      end
      `CA53_NEON_FCTN_SHA256SU0: begin // SHA256SU0
        neon_opa_f2 = sha256su0_opa_f2;
        neon_opb_f2 = sha256su0_opb_f2;
      end
      `CA53_NEON_FCTN_ADDV: begin // ADDV/SADDLV/UADDLV
        neon_opa_f2 = neon_reduce_opa_f2;
        neon_opb_f2 = neon_reduce_opb_f2;
      end
      `CA53_NEON_FCTN_MAXV: begin
        neon_opa_f2 = neon_swap_max_f2;
        neon_opb_f2 = { {32{1'b0}}, neon_swap_max_f2[63:32]};
      end
      `CA53_NEON_FCTN_MINV: begin
        neon_opa_f2 = neon_swap_min_f2;
        neon_opb_f2 = { {32{1'b0}}, neon_swap_min_f2[63:32]};
      end
      default: begin
        neon_opa_f2 = {64{1'bx}};
        neon_opb_f2 = {64{1'bx}};
      end
    endcase

  // F2 operand forwarding
  assign fwd_neon_opa_f2[31: 0] = fad_a_fwd_f2_i[0] ? fwd_data_fr2_f2_i[31: 0] : neon_opa_f2[31: 0];
  assign fwd_neon_opa_f2[63:32] = fad_a_fwd_f2_i[1] ? fwd_data_fr2_f2_i[63:32] : neon_opa_f2[63:32];

  assign fwd_neon_opb_f2[31: 0] = fad_b_fwd_f2_i[0] ? fwd_data_fr1_f2_i[31: 0] : neon_opb_f2[31: 0];
  assign fwd_neon_opb_f2[63:32] = fad_b_fwd_f2_i[1] ? fwd_data_fr1_f2_i[63:32] : neon_opb_f2[63:32];

  assign neon_vrhadd_f2 = neon_width_op_sel_f2 == 3'b111;

  // ------------------------------------------------------
  // SIMD carry control bit generation
  // ------------------------------------------------------
  //
  // Depending on the type of operation being performed we need to interleave
  // SIMD control bits between the operands.  These control bits either
  // kill a carry (a=0, b=0), propagate a carry (a=1, b=0) or create a carry
  // (a=1, b=1).
  //
  //                 A6 A5 A4 A3 A2 A1 A0  B6 B5 B4 B3 B2 B1 B0
  // 64-bit Add       1  1  1  1  1  1  1   0  0  0  0  0  0  0
  // 32-bit Add       1  1  1  0  1  1  1   0  0  0  0  0  0  0
  // 16-bit Add       1  0  1  0  1  0  1   0  0  0  0  0  0  0
  // 8-bit Add        0  0  0  0  0  0  0   0  0  0  0  0  0  0
  //
  // 64-bit Sub       1  1  1  1  1  1  1   0  0  0  0  0  0  0
  // 32-bit Sub       1  1  1  1  1  1  1   0  0  0  1  0  0  0
  // 16-bit Sub       1  1  1  1  1  1  1   0  1  0  1  0  1  0
  // 8-bit Sub        1  1  1  1  1  1  1   1  1  1  1  1  1  1

  // Create SIMD bits
  always @*
    case (neon_size_sel_f2)
      2'b11 : // 64-bits
        neon_carry_f2 = {8{sub_f2[0] | neon_vrhadd_f2}} ^ 8'b11111110;
      2'b10 : // 32-bits
        neon_carry_f2 = {8{sub_f2[0] | neon_vrhadd_f2}} ^ 8'b11101110;
      2'b01 : // 16-bits
        neon_carry_f2 = {8{sub_f2[0] | neon_vrhadd_f2}} ^ 8'b10101010;
      2'b00 : // 8-bits
        neon_carry_f2 = {8{sub_f2[0] | neon_vrhadd_f2}};
      default :
        neon_carry_f2 = {8{1'bx}};
    endcase

  assign neon_b_unsigned_f2 = (neon_sat_op_sel_f2 == `CA53_NEON_SAT_SUQADD) ? 1'b1 :
                              (neon_sat_op_sel_f2 == `CA53_NEON_SAT_USQADD) ? 1'b0 :
                                                                            neon_unsigned_op_f2;

  always @*
    case (neon_size_sel_f2)
      2'b11 : begin // 64-bits
        neon_extend_a_f2[7]   = fwd_neon_opa_f2[63] & ~neon_unsigned_op_f2;
        neon_extend_b_f2[7]   = fwd_neon_opb_f2[63] & ~neon_b_unsigned_f2;
        neon_extend_a_f2[6:0] = {7{1'b0}};
        neon_extend_b_f2[6:0] = {7{~sub_f2[0]}};
      end
      2'b10 : begin // 32-bits
        neon_extend_a_f2[7]   = fwd_neon_opa_f2[63] & ~neon_unsigned_op_f2;
        neon_extend_b_f2[7]   = fwd_neon_opb_f2[63] & ~neon_b_unsigned_f2;
        neon_extend_a_f2[6:4] = {3{1'b0}};
        neon_extend_b_f2[6:4] = {3{~sub_f2[0]}};
        neon_extend_a_f2[3]   = fwd_neon_opa_f2[31] & ~neon_unsigned_op_f2;
        neon_extend_b_f2[3]   = fwd_neon_opb_f2[31] & ~neon_b_unsigned_f2;
        neon_extend_a_f2[2:0] = {3{1'b0}};
        neon_extend_b_f2[2:0] = {3{~sub_f2[0]}};
      end
      2'b01 : begin // 16-bits
        neon_extend_a_f2[7]   = fwd_neon_opa_f2[63] & ~neon_unsigned_op_f2;
        neon_extend_b_f2[7]   = fwd_neon_opb_f2[63] & ~neon_b_unsigned_f2;
        neon_extend_a_f2[6]   = 1'b0;
        neon_extend_b_f2[6]   = ~sub_f2[0];
        neon_extend_a_f2[5]   = fwd_neon_opa_f2[47] & ~neon_unsigned_op_f2;
        neon_extend_b_f2[5]   = fwd_neon_opb_f2[47] & ~neon_b_unsigned_f2;
        neon_extend_a_f2[4]   = 1'b0;
        neon_extend_b_f2[4]   = ~sub_f2[0];
        neon_extend_a_f2[3]   = fwd_neon_opa_f2[31] & ~neon_unsigned_op_f2;
        neon_extend_b_f2[3]   = fwd_neon_opb_f2[31] & ~neon_b_unsigned_f2;
        neon_extend_a_f2[2]   = 1'b0;
        neon_extend_b_f2[2]   = ~sub_f2[0];
        neon_extend_a_f2[1]   = fwd_neon_opa_f2[15] & ~neon_unsigned_op_f2;
        neon_extend_b_f2[1]   = fwd_neon_opb_f2[15] & ~neon_b_unsigned_f2;
        neon_extend_a_f2[0]   = 1'b0;
        neon_extend_b_f2[0]   = ~sub_f2[0];
      end
      2'b00 : begin // 8-bits
        neon_extend_a_f2[7]   = fwd_neon_opa_f2[63] & ~neon_unsigned_op_f2;
        neon_extend_b_f2[7]   = fwd_neon_opb_f2[63] & ~neon_b_unsigned_f2;
        neon_extend_a_f2[6]   = fwd_neon_opa_f2[55] & ~neon_unsigned_op_f2;
        neon_extend_b_f2[6]   = fwd_neon_opb_f2[55] & ~neon_b_unsigned_f2;
        neon_extend_a_f2[5]   = fwd_neon_opa_f2[47] & ~neon_unsigned_op_f2;
        neon_extend_b_f2[5]   = fwd_neon_opb_f2[47] & ~neon_b_unsigned_f2;
        neon_extend_a_f2[4]   = fwd_neon_opa_f2[39] & ~neon_unsigned_op_f2;
        neon_extend_b_f2[4]   = fwd_neon_opb_f2[39] & ~neon_b_unsigned_f2;
        neon_extend_a_f2[3]   = fwd_neon_opa_f2[31] & ~neon_unsigned_op_f2;
        neon_extend_b_f2[3]   = fwd_neon_opb_f2[31] & ~neon_b_unsigned_f2;
        neon_extend_a_f2[2]   = fwd_neon_opa_f2[23] & ~neon_unsigned_op_f2;
        neon_extend_b_f2[2]   = fwd_neon_opb_f2[23] & ~neon_b_unsigned_f2;
        neon_extend_a_f2[1]   = fwd_neon_opa_f2[15] & ~neon_unsigned_op_f2;
        neon_extend_b_f2[1]   = fwd_neon_opb_f2[15] & ~neon_b_unsigned_f2;
        neon_extend_a_f2[0]   = fwd_neon_opa_f2[ 7] & ~neon_unsigned_op_f2;
        neon_extend_b_f2[0]   = fwd_neon_opb_f2[ 7] & ~neon_b_unsigned_f2;
      end
      default : begin
        neon_extend_a_f2[7:0] = {8{1'bx}};
        neon_extend_b_f2[7:0] = {8{1'bx}};
      end
    endcase

  // ------------------------------------------------------
  // SIMD Operand generation
  // ------------------------------------------------------
  //
  // Interleave the control bits to create the operands we
  // will pass into the 71-bit adder.

  assign neon_add_opa_f2 = {neon_extend_a_f2[7], fwd_neon_opa_f2[63:56], neon_carry_f2[7],
                            neon_extend_a_f2[6], fwd_neon_opa_f2[55:48], neon_carry_f2[6],
                            neon_extend_a_f2[5], fwd_neon_opa_f2[47:40], neon_carry_f2[5],
                            neon_extend_a_f2[4], fwd_neon_opa_f2[39:32], neon_carry_f2[4],
                            neon_extend_a_f2[3], fwd_neon_opa_f2[31:24], neon_carry_f2[3],
                            neon_extend_a_f2[2], fwd_neon_opa_f2[23:16], neon_carry_f2[2],
                            neon_extend_a_f2[1], fwd_neon_opa_f2[15: 8], neon_carry_f2[1],
                            neon_extend_a_f2[0], fwd_neon_opa_f2[ 7: 0], neon_carry_f2[0]};

  assign neon_add_opb_f2 = {neon_extend_b_f2[7], fwd_neon_opb_f2[63:56], neon_vrhadd_f2,
                            neon_extend_b_f2[6], fwd_neon_opb_f2[55:48], neon_vrhadd_f2,
                            neon_extend_b_f2[5], fwd_neon_opb_f2[47:40], neon_vrhadd_f2,
                            neon_extend_b_f2[4], fwd_neon_opb_f2[39:32], neon_vrhadd_f2,
                            neon_extend_b_f2[3], fwd_neon_opb_f2[31:24], neon_vrhadd_f2,
                            neon_extend_b_f2[2], fwd_neon_opb_f2[23:16], neon_vrhadd_f2,
                            neon_extend_b_f2[1], fwd_neon_opb_f2[15: 8], neon_vrhadd_f2,
                            neon_extend_b_f2[0], fwd_neon_opb_f2[ 7 :0], neon_vrhadd_f2};

  // Expand LU control prior to the LU pipeline stage
  always @*
    case (neon_lu_ctl_f2)
      `CA53_NEON_LU_AND  : nxt_neon_lu_ctl_f3 = 8'b1100_0000;
      `CA53_NEON_LU_BIC  : nxt_neon_lu_ctl_f3 = 8'b0011_0000;
      `CA53_NEON_LU_BIF  : nxt_neon_lu_ctl_f3 = 8'b1011_1000;
      `CA53_NEON_LU_BIT  : nxt_neon_lu_ctl_f3 = 8'b1110_0010;
      `CA53_NEON_LU_BSL  : nxt_neon_lu_ctl_f3 = 8'b1110_0100;
      `CA53_NEON_LU_EOR  : nxt_neon_lu_ctl_f3 = 8'b0011_1100;
      `CA53_NEON_LU_MOV  : nxt_neon_lu_ctl_f3 = 8'b1100_1100;
      `CA53_NEON_LU_MVN  : nxt_neon_lu_ctl_f3 = 8'b0011_0011;
      `CA53_NEON_LU_ORN  : nxt_neon_lu_ctl_f3 = 8'b1111_0011;
      `CA53_NEON_LU_ORR  : nxt_neon_lu_ctl_f3 = 8'b1111_1100;
      `CA53_NEON_LU_VCGT : nxt_neon_lu_ctl_f3 = 8'b1111_0000;
      `CA53_NEON_LU_VCEQ : nxt_neon_lu_ctl_f3 = 8'b1100_1100;
      default            : nxt_neon_lu_ctl_f3 = {8{1'bx}};
    endcase


  // MUX that selects Neon integer or floating-point output operands
  assign nxt_add_op_a_f3 =  (neon_fctn_sel_f2 == `CA53_NEON_FCTN_FP) ? muxfrc_opa_f2 : {      neon_add_opa_f2, {27{1'b0}} };
  assign nxt_add_op_b_f3 = ((neon_fctn_sel_f2 == `CA53_NEON_FCTN_FP) ? muxfrc_opb_f2 : {1'b0, neon_add_opb_f2, {27{1'b0}} })
                            ^ { {54{sub_mux_f2[0]}}, {54{sub_mux_f2[1]}} };

  assign nxt_sub_f3 = sub_mux_f2[1];

  always @(posedge clk_fp_alu)
    if (advance_pipeline_i)
      enable_f3 <= enable_f2;

  assign advance_f2 = advance_pipeline_i & enable_f2;

  always @(posedge clk_fp_alu)
    if (advance_f2) begin
      rnd_mode_f3           <= rnd_mode_f2;
      fp_op_f3              <= fp_op_f2;
      zero_op_f3            <= zero_op_f2;
      zres_f3               <= zres_f2;
      sign_f3               <= sign_f2;
      exp_opd_f3[0]         <= exp_opd_f2[0];
      exp_opd_f3[1]         <= exp_opd_f2[1];
      add_op_a_f3           <= nxt_add_op_a_f3;
      add_op_b_f3           <= nxt_add_op_b_f3;
      sub_f3                <= nxt_sub_f3;
      invalid_op_f3         <= invalid_op_f2;
      infinity_op_f3        <= infinity_op_f2;
      nan_inv_op_f3         <= nan_inv_op_f2;
      f2i_inexact_f3        <= f2i_inexact_f2;
      f2i_overflow_f3       <= f2i_overflow_f2;
      ifz_f3                <= ifz_f2;
      neon_int_sel_f3       <= neon_int_sel_f2;
      neon_mux_sel_f3       <= neon_mux_sel_f2;
      neon_lu_ctl_f3        <= nxt_neon_lu_ctl_f3;
      neon_frc_opc_f3       <= neon_nxt_frc_opc_f3;
      neon_size_sel_f3      <= neon_size_sel_f2;
      neon_unsigned_op_f3   <= neon_unsigned_op_f2;
      neon_width_op_sel_f3  <= neon_width_op_sel_f2;
      neon_sat_op_sel_f3    <= neon_sat_op_sel_f2;
      neon_vtst_op_sel_f3   <= neon_vtst_op_sel_f2;
      force_dn_fz_f3        <= force_dn_fz_f2;
      ctl_dual_fp_f3        <= ctl_dual_fp_f2;
      ctl_no_dual_fp_f3     <= ctl_no_dual_fp_f2;
      vector_op_f3          <= vector_op_f2;
    end

  //----------------------------------------------------------
  // Third execution stage f3
  //----------------------------------------------------------

  assign f2i_f3 = (fp_op_f3 == `CA53_FP_OP_S2I) | (fp_op_f3 == `CA53_FP_OP_D2I) | (fp_op_f3 == `CA53_FP_OP_D2FP);

  assign rnd_integral_f3 = (fp_op_f3 == `CA53_FP_OP_RINT) | (fp_op_f3 == `CA53_FP_OP_RINTX);

  assign cmp_cmd_f3 = (fp_op_f3 == `CA53_FP_OP_CMP) | (fp_op_f3 == `CA53_FP_OP_CMPE) | (fp_op_f3 == `CA53_FP_OP_ACMPE);

  assign recpx_f3 = (fp_op_f3 == `CA53_FP_OP_RECPX);

  //----------------------------------
  // Adder
  //----------------------------------

  // Perform addition/subtraction

  // Create result bus
  assign add_res_f3 = add_op_a_f3 + add_op_b_f3 + sub_f3;

  // Perform leading zero prediction on the add operands
  assign fp_clz_opd_f3 = ~({1'b0, add_op_a_f3[106:2]} ^ add_op_b_f3[107:2]) &
                         (add_op_a_f3[106:1] | add_op_b_f3[106:1]);

  ca53dpu_fp_clz106 u_clz106 (
    .opa (fp_clz_opd_f3),
    .res (lza_res_f3[0])
  );

  ca53dpu_fp_clz54 u_clz54 (
    .opa ({fp_clz_opd_f3[50:0], 3'b000}),
    .res (lza_res_f3[1][5:0])
  );

  assign lza_res_f3[1][6] = 1'b0;

  assign renorm_shift_f3[0] = (f2i_f3 | recpx_f3)                         ? {7{1'b0}}          :
                              ({5'b00000, lza_res_f3[0]} > exp_opd_f3[0]) ? exp_opd_f3[0][6:0] :
                                                                            lza_res_f3[0];

  assign renorm_shift_f3[1] = ctl_no_dual_fp_f3                           ? renorm_shift_f3[0] :
                              f2i_f3                                      ? {7{1'b0}}          :
                              ({5'b00000, lza_res_f3[1]} > exp_opd_f3[1]) ? exp_opd_f3[1][6:0] :
                                                                            lza_res_f3[1];

  // Generate an earlier result for float->int conversions, for A64 instructions
  // which write the integer register file in Wr
  assign early_f2i_res_f3 = add_op_b_f3[66:0] + add_op_a_f3[1:0] + sub_f3;

  assign early_f2i_msb_f3   = (neon_size_sel_f3 == 2'b10) ? early_f2i_res_f3[33] : early_f2i_res_f3[65];
  assign early_f2i_carry_f3 = (neon_size_sel_f3 == 2'b10) ? early_f2i_res_f3[34] : early_f2i_res_f3[66];

  assign early_f2i_pos_sat_f3 = f2i_overflow_f3[0]  ? ~(sign_f3[0] | nan_inv_op_f3[0])                        :
                                neon_unsigned_op_f3 ?                     (early_f2i_carry_f3  & ~sign_f3[0]) :
                                                      ((early_f2i_msb_f3 | early_f2i_carry_f3) & ~sign_f3[0]);
  assign early_f2i_neg_sat_f3 = f2i_overflow_f3[0]  ?  (sign_f3[0] | nan_inv_op_f3[0])                        :
                                neon_unsigned_op_f3 ?                     (early_f2i_carry_f3  &  sign_f3[0]) :
                                                      (~early_f2i_msb_f3 & early_f2i_carry_f3  &  sign_f3[0]);

  // Floating to integer conversion signals
  assign early_f2i_sign_f3 = (early_f2i_neg_sat_f3 & ~nan_inv_op_f3[0]) |
                             (early_f2i_carry_f3 & ~early_f2i_pos_sat_f3 & ~nan_inv_op_f3[0]);

  assign early_f2i_sat_res_f3 = {64{early_f2i_pos_sat_f3}} | ({64{~early_f2i_neg_sat_f3}} & early_f2i_res_f3[65:2]);

  assign fp_alu_f2i_res_f3[63]    = neon_unsigned_op_f3 ? early_f2i_sat_res_f3[63] : early_f2i_sign_f3;
  assign fp_alu_f2i_res_f3[62:32] = early_f2i_sat_res_f3[62:32];
  assign fp_alu_f2i_res_f3[31]    = (neon_unsigned_op_f3 |
                                     (neon_size_sel_f3 == 2'b11)) ? early_f2i_sat_res_f3[31] : early_f2i_sign_f3;
  assign fp_alu_f2i_res_f3[30: 0] = early_f2i_sat_res_f3[30: 0];

  // Element extract for Neon->core moves
  always @*
    case (neon_size_sel_f3)
      2'b00:   neon_element_res_f3 = { {56{~neon_unsigned_op_f3 & neon_opa_f3[ 7]}}, neon_opa_f3[ 7:0]}; //  8-bit
      2'b01:   neon_element_res_f3 = { {48{~neon_unsigned_op_f3 & neon_opa_f3[15]}}, neon_opa_f3[15:0]}; // 16-bit
      2'b10:   neon_element_res_f3 = { {32{~neon_unsigned_op_f3 & neon_opa_f3[31]}}, neon_opa_f3[31:0]}; // 32-bit
      2'b11:   neon_element_res_f3 =                                                 neon_opa_f3[63:0];  // 64-bit
      default: neon_element_res_f3 = {64{1'bx}};
    endcase

  assign fp_alu_f2i_res_f3_o = neon_int_sel_f3 ? neon_element_res_f3
                                               : fp_alu_f2i_res_f3;

  // FP across-vector max/min
  generate if (IS_PIPE0) begin : g_fp_maxmin
    wire minimum_f3;
    wire minmaxnm_f3;
    wire fp_value_cmp_f3;
    wire fp_maxmin_sel_b_f3;

    assign minimum_f3  = (fp_op_f3 == `CA53_FP_OP_MIN)   | (fp_op_f3 == `CA53_FP_OP_MINNM);
    assign minmaxnm_f3 = (fp_op_f3 == `CA53_FP_OP_MAXNM) | (fp_op_f3 == `CA53_FP_OP_MINNM);

    // Only need to perform single-precision comparison
    assign fp_value_cmp_f3 = {exp_opd_f3[1][7:0], add_op_a_f3[51:28]} > {exp_opd_f3[0][7:0], add_op_a_f3[106:83]};

    assign fp_maxmin_sel_b_f3 = nan_inv_op_f3[0]           ? (~nan_inv_op_f3[1] &  minmaxnm_f3) :
                                nan_inv_op_f3[1]           ?                      ~minmaxnm_f3  :
                                (sign_f3[1] != sign_f3[0]) ? (sign_f3[0] ^ minimum_f3)          :
                                                             (sign_f3[0] ^ minimum_f3 ^ fp_value_cmp_f3);

    assign fp_maxmin_sign_f3 = fp_maxmin_sel_b_f3 ? sign_f3[1]         : sign_f3[0];
    assign fp_maxmin_exp_f3  = fp_maxmin_sel_b_f3 ? exp_opd_f3[1][7:0] : exp_opd_f3[0][7:0];
    assign fp_maxmin_frac_f3 = fp_maxmin_sel_b_f3 ? add_op_a_f3[51:28] : add_op_a_f3[106:83];
    assign fp_maxmin_nan_f3  = fp_maxmin_sel_b_f3 ? nan_inv_op_f3[1]   : nan_inv_op_f3[0];
    assign fp_maxmin_inf_f3  = fp_maxmin_sel_b_f3 ? infinity_op_f3[1]  : infinity_op_f3[0];
    assign fp_maxmin_zero_f3 = fp_maxmin_sel_b_f3 ? zero_op_f3[1]      : zero_op_f3[0];

  end else begin : g_fp_maxmin_stubs
    assign fp_maxmin_sign_f3 = 1'b0;
    assign fp_maxmin_exp_f3  = {8{1'b0}};
    assign fp_maxmin_frac_f3 = {24{1'b0}};
    assign fp_maxmin_nan_f3  = 1'b0;
    assign fp_maxmin_inf_f3  = 1'b0;
    assign fp_maxmin_zero_f3 = 1'b0;
  end endgenerate

  assign neon_res_f3 = {add_res_f3[105:98],
                        add_res_f3[ 95:88],
                        add_res_f3[ 85:78],
                        add_res_f3[ 75:68],
                        add_res_f3[ 65:58],
                        add_res_f3[ 55:48],
                        add_res_f3[ 45:38],
                        add_res_f3[ 35:28]};

  // Halving result logic for VHADD, VHSUB, VRHADD
  always @*
    case (neon_size_sel_f3)
      2'b00:  // Signed 8-bit
        neon_halved_res_f3 = {add_res_f3[106:99],
                              add_res_f3[ 96:89],
                              add_res_f3[ 86:79],
                              add_res_f3[ 76:69],
                              add_res_f3[ 66:59],
                              add_res_f3[ 56:49],
                              add_res_f3[ 46:39],
                              add_res_f3[ 36:29]};

      2'b01:  // Signed 16-bit
        neon_halved_res_f3 = {add_res_f3[106:98],
                              add_res_f3[ 95:89],
                              add_res_f3[ 86:78],
                              add_res_f3[ 75:69],
                              add_res_f3[ 66:58],
                              add_res_f3[ 55:49],
                              add_res_f3[ 46:38],
                              add_res_f3[ 35:29]};

      2'b10:  // Signed 32-bit
        neon_halved_res_f3 = {add_res_f3[106:98],
                              add_res_f3[ 95:88],
                              add_res_f3[ 85:78],
                              add_res_f3[ 75:69],
                              add_res_f3[ 66:58],
                              add_res_f3[ 55:48],
                              add_res_f3[ 45:38],
                              add_res_f3[ 35:29]};

      default:
        neon_halved_res_f3 = {64{1'bx}};
    endcase

  always @*
    case ({vector_op_f3, neon_size_sel_f3})
      3'b0_00: neon_scalar_mask_f3 = 64'h00000000000000FF;
      3'b0_01: neon_scalar_mask_f3 = 64'h000000000000FFFF;
      3'b0_10: neon_scalar_mask_f3 = 64'h00000000FFFFFFFF;
      3'b0_11,
      3'b1_00,
      3'b1_01,
      3'b1_10,
      3'b1_11: neon_scalar_mask_f3 = 64'hFFFFFFFFFFFFFFFF;
      default: neon_scalar_mask_f3 = {64{1'bx}};
    endcase

  assign neon_masked_res_f3 = neon_res_f3 & neon_scalar_mask_f3;

  assign neon_add_res_f3 = (neon_width_op_sel_f3[2:1] == 2'b11) ? { {44{1'b0}}, neon_halved_res_f3}           :
                           (cmp_cmd_f3 | neon_int_sel_f3)       ? { {44{1'b0}}, neon_masked_res_f3}           :
                           rnd_integral_f3                      ? {add_res_f3[107:56],
                                                                   (add_res_f3[55:54] & {2{ctl_no_dual_fp_f3}}),
                                                                   add_res_f3[53:2], 2'b00}                   : // Mask off rounding bits
                                                                   add_res_f3;

  assign neon_opa_f3 = {add_op_a_f3[105:98],
                        add_op_a_f3[ 95:88],
                        add_op_a_f3[ 85:78],
                        add_op_a_f3[ 75:68],
                        add_op_a_f3[ 65:58],
                        add_op_a_f3[ 55:48],
                        add_op_a_f3[ 45:38],
                        add_op_a_f3[ 35:28]};

  assign neon_opb_f3 = {add_op_b_f3[105:98],
                        add_op_b_f3[ 95:88],
                        add_op_b_f3[ 85:78],
                        add_op_b_f3[ 75:68],
                        add_op_b_f3[ 65:58],
                        add_op_b_f3[ 55:48],
                        add_op_b_f3[ 45:38],
                        add_op_b_f3[ 35:28]};

  //----------------------------------
  // Polynomial mult unit
  //----------------------------------

  ca53dpu_neon_polymul u_polymul (
    // Inputs
    .neon_opa_f3_i          (neon_opa_f3[63:0]),
    .neon_opb_f3_i          (neon_opb_f3[63:0]),
    // Outputs
    .neon_polymul_res_f3_o  (neon_polymul_res_f3)
  );

  //----------------------------------
  // Logical unit
  //----------------------------------
  ca53dpu_neon_lu u_lu (
    // Inputs
    .neon_lu_ctl_f3_i   (neon_lu_ctl_f3[7:0]),
    .frc_opa_f3_i       (neon_opa_f3[63:0]),
    .frc_opb_f3_i       (neon_opb_f3[63:0]),
    .neon_frc_opc_f3_i  (neon_frc_opc_f3),
    // Outputs
    .neon_lu_res_f3_o   (raw_neon_lu_res_f3)
  );

  assign neon_lu_res_f3 = raw_neon_lu_res_f3 & neon_scalar_mask_f3;

  //----------------------------------
  // CLZ/CLS
  //----------------------------------

  ca53dpu_fp_clz64 u_neon_clz64 (
    .clz_input_f3_i     (neon_opb_f3[63:0]),
    .neon_size_sel_f3_i (neon_size_sel_f3[1:0]),
    .neon_clz_res_f3_o  (neon_clz_res_f3)
  );

  //----------------------------------
  // Saturation detect
  //----------------------------------

  assign neon_suqadd_f3 = (neon_sat_op_sel_f3 == `CA53_NEON_SAT_SUQADD);
  assign neon_usqadd_f3 = (neon_sat_op_sel_f3 == `CA53_NEON_SAT_USQADD);

  always @*
    case (neon_unsigned_op_f3)
      1'b1: begin // unsigned
        neon_sat_detect_f3[ 1: 0] = {sub_f3 | (neon_usqadd_f3 & add_res_f3[ 35]), add_res_f3[ 36]};
        neon_sat_detect_f3[ 3: 2] = {sub_f3 | (neon_usqadd_f3 & add_res_f3[ 45]), add_res_f3[ 46]};
        neon_sat_detect_f3[ 5: 4] = {sub_f3 | (neon_usqadd_f3 & add_res_f3[ 55]), add_res_f3[ 56]};
        neon_sat_detect_f3[ 7: 6] = {sub_f3 | (neon_usqadd_f3 & add_res_f3[ 65]), add_res_f3[ 66]};
        neon_sat_detect_f3[ 9: 8] = {sub_f3 | (neon_usqadd_f3 & add_res_f3[ 75]), add_res_f3[ 76]};
        neon_sat_detect_f3[11:10] = {sub_f3 | (neon_usqadd_f3 & add_res_f3[ 85]), add_res_f3[ 86]};
        neon_sat_detect_f3[13:12] = {sub_f3 | (neon_usqadd_f3 & add_res_f3[ 95]), add_res_f3[ 96]};
        neon_sat_detect_f3[15:14] = {sub_f3 | (neon_usqadd_f3 & add_res_f3[105]), add_res_f3[106]};
      end
      1'b0: begin // signed
        neon_sat_detect_f3[ 1: 0] = {add_res_f3[ 36] & ~neon_suqadd_f3, add_res_f3[ 36] ^ add_res_f3[ 35]};
        neon_sat_detect_f3[ 3: 2] = {add_res_f3[ 46] & ~neon_suqadd_f3, add_res_f3[ 46] ^ add_res_f3[ 45]};
        neon_sat_detect_f3[ 5: 4] = {add_res_f3[ 56] & ~neon_suqadd_f3, add_res_f3[ 56] ^ add_res_f3[ 55]};
        neon_sat_detect_f3[ 7: 6] = {add_res_f3[ 66] & ~neon_suqadd_f3, add_res_f3[ 66] ^ add_res_f3[ 65]};
        neon_sat_detect_f3[ 9: 8] = {add_res_f3[ 76] & ~neon_suqadd_f3, add_res_f3[ 76] ^ add_res_f3[ 75]};
        neon_sat_detect_f3[11:10] = {add_res_f3[ 86] & ~neon_suqadd_f3, add_res_f3[ 86] ^ add_res_f3[ 85]};
        neon_sat_detect_f3[13:12] = {add_res_f3[ 96] & ~neon_suqadd_f3, add_res_f3[ 96] ^ add_res_f3[ 95]};
        neon_sat_detect_f3[15:14] = {add_res_f3[106] & ~neon_suqadd_f3, add_res_f3[106] ^ add_res_f3[105]};
      end
      default:
        neon_sat_detect_f3 = {16{1'bx}};
    endcase

  always @*
    case (neon_size_sel_f3)
      2'b00: // 8-bit elements
        neon_sat_dtect_ctl_f3 = neon_sat_detect_f3;
      2'b01: // 16-bit elements
        neon_sat_dtect_ctl_f3 = {{8{1'b0}}, neon_sat_detect_f3[15:14], neon_sat_detect_f3[11:10], neon_sat_detect_f3[7:6], neon_sat_detect_f3[3:2]};
      2'b10: // 32-bit elements
        neon_sat_dtect_ctl_f3 = {{12{1'b0}}, neon_sat_detect_f3[15:14], neon_sat_detect_f3[7:6]};
      2'b11: // 64-bit elements
        neon_sat_dtect_ctl_f3 = {{14{1'b0}}, neon_sat_detect_f3[15:14]};
      default:
        neon_sat_dtect_ctl_f3 = {16{1'bx}};
    endcase

  // Process the saturation control from the shift module
  ca53dpu_neon_shift_sat u_neon_shift_sat (
    // Inputs
    .neon_size_sel_f3_i     (neon_size_sel_f3),
    .neon_width_op_sel_f3_i (neon_width_op_sel_f3),
    .neon_sat_op_sel_f3_i   (neon_sat_op_sel_f3),
    .frc_opa_f3_i           (neon_opa_f3[63:0]),
    .neon_frc_opc_f3_i      (neon_frc_opc_f3),
    .frc_res_f3_i           (neon_res_f3[63:0]),
    // Outputs
    .neon_shift_sat_f3_o    (neon_shift_sat_f3)
  );

  // Choose the saturation control signals from shift and add/sub operations
  // and pipe the final saturation detect signal to the next stage
  assign neon_sat_dtect_f3 = (((neon_sat_op_sel_f3 == `CA53_NEON_SAT_SHF_SIGNED) |
                               (neon_sat_op_sel_f3 == `CA53_NEON_SAT_SHF_UNSIGNED)) ? neon_shift_sat_f3
                                                                                  : neon_sat_dtect_ctl_f3)    & { {14{vector_op_f3}}, 2'b11};

  assign nxt_ctl_dual_fp_f4 = ctl_dual_fp_f3 & ~(neon_mux_sel_f3 == `CA53_NEON_MUX_SEL_FMAXMIN);

  // Mux in result from FMAXV-type instructions
  assign nxt_sign_f4[0]        = (neon_mux_sel_f3 == `CA53_NEON_MUX_SEL_FMAXMIN) ? fp_maxmin_sign_f3 : sign_f3[0];
  assign nxt_sign_f4[1]        = (neon_mux_sel_f3 == `CA53_NEON_MUX_SEL_FMAXMIN) ? fp_maxmin_sign_f3 : sign_f3[1];

  assign nxt_nan_inv_op_f4[0]  = (neon_mux_sel_f3 == `CA53_NEON_MUX_SEL_FMAXMIN) ? fp_maxmin_nan_f3  : nan_inv_op_f3[0];
  assign nxt_nan_inv_op_f4[1]  = (neon_mux_sel_f3 == `CA53_NEON_MUX_SEL_FMAXMIN) ? fp_maxmin_nan_f3  : nan_inv_op_f3[1];

  assign nxt_infinity_op_f4[0] = (neon_mux_sel_f3 == `CA53_NEON_MUX_SEL_FMAXMIN) ? fp_maxmin_inf_f3  : infinity_op_f3[0];
  assign nxt_infinity_op_f4[1] = (neon_mux_sel_f3 == `CA53_NEON_MUX_SEL_FMAXMIN) ? fp_maxmin_inf_f3  : infinity_op_f3[1];

  assign nxt_zero_op_f4[0]     = (neon_mux_sel_f3 == `CA53_NEON_MUX_SEL_FMAXMIN) ? fp_maxmin_zero_f3 : zero_op_f3[0];
  assign nxt_zero_op_f4[1]     = (neon_mux_sel_f3 == `CA53_NEON_MUX_SEL_FMAXMIN) ? fp_maxmin_zero_f3 : zero_op_f3[1];

  // Calculate exponent for FRECPX instruction
  assign recpx_exp_f3 = { 1'b0, {3{neon_size_sel_f3[0]}}, 8'hFF} ^ exp_opd_f3[0];

  assign nxt_exp_opd_f4[0] = (neon_mux_sel_f3 == `CA53_NEON_MUX_SEL_FMAXMIN) ? { {4{1'b0}}, fp_maxmin_exp_f3[ 7:0]}  :
                             (neon_sat_op_sel_f3 != `CA53_NEON_SAT_NONE)     ? { {4{1'b0}}, neon_sat_dtect_f3[ 7:0]} :
                             recpx_f3                                      ? recpx_exp_f3                          :
                                                                             exp_opd_f3[0];

  assign nxt_exp_opd_f4[1] = (neon_mux_sel_f3 == `CA53_NEON_MUX_SEL_FMAXMIN) ? { {4{1'b0}}, fp_maxmin_exp_f3[ 7:0]}  :
                             (neon_sat_op_sel_f3 != `CA53_NEON_SAT_NONE)     ? { {4{1'b0}}, neon_sat_dtect_f3[15:8]} :
                                                                             exp_opd_f3[1];

  // MUX to select the result from adder, polymult or logical unit
  assign nxt_alu_res_f4 = ({108{(neon_mux_sel_f3 == `CA53_NEON_MUX_SEL_AU)}}      & neon_add_res_f3)                    |
                          ({108{(neon_mux_sel_f3 == `CA53_NEON_MUX_SEL_CLZ)}}     & { {44{1'b0}}, neon_clz_res_f3})     |
                          ({108{(neon_mux_sel_f3 == `CA53_NEON_MUX_SEL_PMUL)}}    & { {12{1'b0}}, neon_polymul_res_f3}) |
                          ({108{(neon_mux_sel_f3 == `CA53_NEON_MUX_SEL_LU)}}      & { {44{1'b0}}, neon_lu_res_f3})      |
                          ({108{(neon_mux_sel_f3 == `CA53_NEON_MUX_SEL_MAXMIN)}}  & { {44{1'b0}}, neon_opa_f3})         |
                          ({108{(neon_mux_sel_f3 == `CA53_NEON_MUX_SEL_FMAXMIN)}} & {1'b0, fp_maxmin_frac_f3, {83{1'b0}} });

  always @(posedge clk_fp_alu)
    if (advance_pipeline_i)
      enable_f4 <= enable_f3;

  assign advance_f3 = advance_pipeline_i & enable_f3;

  always @(posedge clk_fp_alu)
    if (advance_f3) begin
      rnd_mode_f4           <= rnd_mode_f3;
      fp_op_f4              <= fp_op_f3;
      zero_op_f4            <= nxt_zero_op_f4;
      zres_f4               <= zres_f3;
      sign_f4               <= nxt_sign_f4;
      exp_opd_f4[0]         <= nxt_exp_opd_f4[0];
      exp_opd_f4[1]         <= nxt_exp_opd_f4[1];
      alu_res_f4            <= nxt_alu_res_f4;
      renorm_shift_f4[0]    <= renorm_shift_f3[0];
      renorm_shift_f4[1]    <= renorm_shift_f3[1];
      invalid_op_f4         <= invalid_op_f3;
      infinity_op_f4        <= nxt_infinity_op_f4;
      nan_inv_op_f4         <= nxt_nan_inv_op_f4;
      f2i_inexact_f4        <= f2i_inexact_f3;
      f2i_overflow_f4       <= f2i_overflow_f3;
      ifz_f4                <= ifz_f3;
      fpscr_ahp_f4          <= fpscr_ahp_i;
      fpscr_dn_f4           <= fpscr_dn_i;
      fpscr_fz_f4           <= fpscr_fz_i;
      neon_int_sel_f4       <= neon_int_sel_f3;
      neon_size_sel_f4      <= neon_size_sel_f3;
      neon_unsigned_op_f4   <= neon_unsigned_op_f3;
      neon_width_op_sel_f4  <= neon_width_op_sel_f3;
      neon_sat_op_sel_f4    <= neon_sat_op_sel_f3;
      neon_vtst_op_sel_f4   <= neon_vtst_op_sel_f3;
      force_dn_fz_f4        <= force_dn_fz_f3;
      ctl_dual_fp_f4        <= nxt_ctl_dual_fp_f4;
    end

  //----------------------------------------------------------
  // Fourth execution stage f4
  //----------------------------------------------------------

  assign cmp_cmd_f4 = (fp_op_f4 == `CA53_FP_OP_CMP) | (fp_op_f4 == `CA53_FP_OP_CMPE) | (fp_op_f4 == `CA53_FP_OP_ACMPE);

  assign f2i_f4      = (fp_op_f4 == `CA53_FP_OP_S2I)   | (fp_op_f4 == `CA53_FP_OP_D2I) | (fp_op_f4 == `CA53_FP_OP_D2FP);
  assign s2h_f4      = (fp_op_f4 == `CA53_FP_OP_F2H_B) | (fp_op_f4 == `CA53_FP_OP_F2H_T);
  assign dual_s2h_f4 = (fp_op_f4 == `CA53_FP_OP_F2H_B) & (neon_width_op_sel_f4 == 3'b001);

  assign abs_neg_f4 = (fp_op_f4 == `CA53_FP_OP_ABS) | (fp_op_f4 == `CA53_FP_OP_NEG) | (fp_op_f4 == `CA53_FP_OP_MOV);

  assign rnd_integral_f4 = (fp_op_f4 == `CA53_FP_OP_RINT) | (fp_op_f4 == `CA53_FP_OP_RINTX);

  assign recpx_f4 = (fp_op_f4 == `CA53_FP_OP_RECPX);

  assign dp_op_sel_f4 = ~f2i_f4 & (neon_size_sel_f4 == 2'b11);

  //----------------------------------
  // Narrow result logic
  //----------------------------------

  // Copy the high-half or the low-half of the element
  always @*
    case (neon_size_sel_f4)
      2'b01: begin //  16-bit elements
        neon_narrow_res_f4 = neon_width_op_sel_f4[0] ? {alu_res_f4[63:56], alu_res_f4[47:40], alu_res_f4[31:24], alu_res_f4[15:8]}
                                                     : {alu_res_f4[55:48], alu_res_f4[39:32], alu_res_f4[23:16], alu_res_f4[7:0]};
      end
      2'b10: begin // 32-bit elements
        neon_narrow_res_f4 = neon_width_op_sel_f4[0] ? {alu_res_f4[63:48], alu_res_f4[31:16]}
                                                     : {alu_res_f4[47:32], alu_res_f4[15:0]};
      end
      2'b11: begin // 64-bit elements
        neon_narrow_res_f4 = neon_width_op_sel_f4[0] ? alu_res_f4[63:32] : alu_res_f4[31:0];
      end
      default:
        neon_narrow_res_f4 = {32{1'bx}};
    endcase

  // Select the narrow result or the original from the previous stage
  // as an input to the saturation block
  // For VMUL.P8, the instruction is executed as a widening operation followed
  // by a narrowing operation, so fill in the upper data
  assign neon_sat_in_res_f4 = (neon_width_op_sel_f4[2:1]==2'b10) ? {alu_res_f4[95:64], neon_narrow_res_f4[31:0]} : alu_res_f4[63:0];

  //-------------------------------------
  // Logic for the VTST instruction
  //-------------------------------------

  //Compare each byte with zero
  assign neon_vtst_byte0_f4 = alu_res_f4[ 7: 0] == 8'h00;
  assign neon_vtst_byte1_f4 = alu_res_f4[15: 8] == 8'h00;
  assign neon_vtst_byte2_f4 = alu_res_f4[23:16] == 8'h00;
  assign neon_vtst_byte3_f4 = alu_res_f4[31:24] == 8'h00;
  assign neon_vtst_byte4_f4 = alu_res_f4[39:32] == 8'h00;
  assign neon_vtst_byte5_f4 = alu_res_f4[47:40] == 8'h00;
  assign neon_vtst_byte6_f4 = alu_res_f4[55:48] == 8'h00;
  assign neon_vtst_byte7_f4 = alu_res_f4[63:56] == 8'h00;

  always @*
    case (neon_size_sel_f4)
      2'b00: begin // 8-bit elements
        neon_vtst_res_f4 = {neon_vtst_byte7_f4, 1'b1, neon_vtst_byte6_f4, 1'b1, neon_vtst_byte5_f4, 1'b1, neon_vtst_byte4_f4, 1'b1,
                            neon_vtst_byte3_f4, 1'b1, neon_vtst_byte2_f4, 1'b1, neon_vtst_byte1_f4, 1'b1, neon_vtst_byte0_f4, 1'b1};
      end
      2'b01: begin // 16-bit elements
        neon_vtst_res_f4 = {{8{1'b0}},
                            neon_vtst_byte7_f4 & neon_vtst_byte6_f4, 1'b1, neon_vtst_byte5_f4 & neon_vtst_byte4_f4, 1'b1,
                            neon_vtst_byte3_f4 & neon_vtst_byte2_f4, 1'b1, neon_vtst_byte1_f4 & neon_vtst_byte0_f4, 1'b1};
      end
      2'b10: begin // 32-bit elements
        neon_vtst_res_f4 = {{12{1'b0}},
                            neon_vtst_byte7_f4 & neon_vtst_byte6_f4 & neon_vtst_byte5_f4 & neon_vtst_byte4_f4, 1'b1,
                            neon_vtst_byte3_f4 & neon_vtst_byte2_f4 & neon_vtst_byte1_f4 & neon_vtst_byte0_f4, 1'b1};
      end
      2'b11: begin // 64-bit elements
        neon_vtst_res_f4 = {{14{1'b0}},
                            neon_vtst_byte7_f4 & neon_vtst_byte6_f4 & neon_vtst_byte5_f4 & neon_vtst_byte4_f4 &
                            neon_vtst_byte3_f4 & neon_vtst_byte2_f4 & neon_vtst_byte1_f4 & neon_vtst_byte0_f4, 1'b1};
      end
      default:
        neon_vtst_res_f4 = {16{1'bx}};
    endcase

  //-------------------------------------
  // Saturation result
  //-------------------------------------

  assign raw_neon_sat_dtect_res_f4 = {exp_opd_f4[1][7:0], exp_opd_f4[0][7:0]};
  assign neon_sat_dtect_res_f4     = neon_vtst_op_sel_f4 ? neon_vtst_res_f4 : raw_neon_sat_dtect_res_f4;

  // In case of narrow result the size element is decreased by one
  assign neon_dcr_size_sel_f4 = (neon_width_op_sel_f4[2:1] == 2'b10) ? neon_size_sel_f4 - 1'b1 : neon_size_sel_f4;

  assign neon_sat_unsigned_f4 = (neon_sat_op_sel_f4 == `CA53_NEON_SAT_SHF_UNSIGNED) ? 1'b1               :
                                (neon_sat_op_sel_f4 == `CA53_NEON_SAT_SHF_SIGNED)   ? 1'b0               :
                                                                                    neon_unsigned_op_f4;

  // Perform saturation
  // If saturation, it will saturate to the negative value or positive value else it
  // will remain unchanged. The result MSB for the unsigned case is the same with the
  // other bits while for the signed is the inverted value of the other bits.
  always @*
    case (neon_dcr_size_sel_f4)
      2'b00: begin // 8-bit elements
        neon_sat_flag_f4       = neon_sat_dtect_res_f4[14] | neon_sat_dtect_res_f4[12] | neon_sat_dtect_res_f4[10] | neon_sat_dtect_res_f4[ 8] |
                                 neon_sat_dtect_res_f4[ 6] | neon_sat_dtect_res_f4[ 4] | neon_sat_dtect_res_f4[ 2] | neon_sat_dtect_res_f4[ 0];
        neon_sat_res_f4[63:56] = neon_sat_dtect_res_f4[14] ? (neon_sat_dtect_res_f4[15] ? {~neon_sat_unsigned_f4, {7{1'b0}}} : {neon_sat_unsigned_f4, {7{1'b1}}})
                                                           : neon_sat_in_res_f4[63:56];
        neon_sat_res_f4[55:48] = neon_sat_dtect_res_f4[12] ? (neon_sat_dtect_res_f4[13] ? {~neon_sat_unsigned_f4, {7{1'b0}}} : {neon_sat_unsigned_f4, {7{1'b1}}})
                                                           : neon_sat_in_res_f4[55:48];
        neon_sat_res_f4[47:40] = neon_sat_dtect_res_f4[10] ? (neon_sat_dtect_res_f4[11] ? {~neon_sat_unsigned_f4, {7{1'b0}}} : {neon_sat_unsigned_f4, {7{1'b1}}})
                                                           : neon_sat_in_res_f4[47:40];
        neon_sat_res_f4[39:32] = neon_sat_dtect_res_f4[8]  ? (neon_sat_dtect_res_f4[9]  ? {~neon_sat_unsigned_f4, {7{1'b0}}} : {neon_sat_unsigned_f4, {7{1'b1}}})
                                                           : neon_sat_in_res_f4[39:32];
        neon_sat_res_f4[31:24] = neon_sat_dtect_res_f4[6]  ? (neon_sat_dtect_res_f4[7]  ? {~neon_sat_unsigned_f4, {7{1'b0}}} : {neon_sat_unsigned_f4, {7{1'b1}}})
                                                           : neon_sat_in_res_f4[31:24];
        neon_sat_res_f4[23:16] = neon_sat_dtect_res_f4[4]  ? (neon_sat_dtect_res_f4[5]  ? {~neon_sat_unsigned_f4, {7{1'b0}}} : {neon_sat_unsigned_f4, {7{1'b1}}})
                                                           : neon_sat_in_res_f4[23:16];
        neon_sat_res_f4[15:8]  = neon_sat_dtect_res_f4[2]  ? (neon_sat_dtect_res_f4[3]  ? {~neon_sat_unsigned_f4, {7{1'b0}}} : {neon_sat_unsigned_f4, {7{1'b1}}})
                                                           : neon_sat_in_res_f4[15:8];
        neon_sat_res_f4[7:0]   = neon_sat_dtect_res_f4[0]  ? (neon_sat_dtect_res_f4[1]  ? {~neon_sat_unsigned_f4, {7{1'b0}}} : {neon_sat_unsigned_f4, {7{1'b1}}})
                                                           : neon_sat_in_res_f4[7:0];
      end
      2'b01: begin // 16-bit elements
        neon_sat_flag_f4       = neon_sat_dtect_res_f4[6] | neon_sat_dtect_res_f4[4] | neon_sat_dtect_res_f4[2] | neon_sat_dtect_res_f4[0];
        neon_sat_res_f4[63:48] = neon_sat_dtect_res_f4[6] ? (neon_sat_dtect_res_f4[7] ? {~neon_sat_unsigned_f4, {15{1'b0}}} : {neon_sat_unsigned_f4, {15{1'b1}}})
                                                          : neon_sat_in_res_f4[63:48];
        neon_sat_res_f4[47:32] = neon_sat_dtect_res_f4[4] ? (neon_sat_dtect_res_f4[5] ? {~neon_sat_unsigned_f4, {15{1'b0}}} : {neon_sat_unsigned_f4, {15{1'b1}}})
                                                          : neon_sat_in_res_f4[47:32];
        neon_sat_res_f4[31:16] = neon_sat_dtect_res_f4[2] ? (neon_sat_dtect_res_f4[3] ? {~neon_sat_unsigned_f4, {15{1'b0}}} : {neon_sat_unsigned_f4, {15{1'b1}}})
                                                          : neon_sat_in_res_f4[31:16];
        neon_sat_res_f4[15:0]  = neon_sat_dtect_res_f4[0] ? (neon_sat_dtect_res_f4[1] ? {~neon_sat_unsigned_f4, {15{1'b0}}} : {neon_sat_unsigned_f4, {15{1'b1}}})
                                                          : neon_sat_in_res_f4[15:0];
      end
      2'b10: begin // 32-bit elements
        neon_sat_flag_f4       = neon_sat_dtect_res_f4[2] | neon_sat_dtect_res_f4[0];
        neon_sat_res_f4[63:32] = neon_sat_dtect_res_f4[2] ? (neon_sat_dtect_res_f4[3] ? {~neon_sat_unsigned_f4, {31{1'b0}}} : {neon_sat_unsigned_f4, {31{1'b1}}})
                                                          : neon_sat_in_res_f4[63:32];
        neon_sat_res_f4[31:0]  = neon_sat_dtect_res_f4[0] ? (neon_sat_dtect_res_f4[1] ? {~neon_sat_unsigned_f4, {31{1'b0}}} : {neon_sat_unsigned_f4, {31{1'b1}}})
                                                          : neon_sat_in_res_f4[31:0];
      end
      2'b11: begin // 64-bit elements
        neon_sat_flag_f4       = neon_sat_dtect_res_f4[0];
        neon_sat_res_f4[63:0]  = neon_sat_dtect_res_f4[0] ? (neon_sat_dtect_res_f4[1] ? {~neon_sat_unsigned_f4, {63{1'b0}}} : {neon_sat_unsigned_f4, {63{1'b1}}})
                                                          : neon_sat_in_res_f4[63:0];
      end
      default: begin
        neon_sat_flag_f4       = 1'bx;
        neon_sat_res_f4[63:0]  = {64{1'bx}};
      end
    endcase

  // Calculate result for MAXV/MINV operations
  generate if (IS_PIPE0) begin : g_vector_maxmin
    ca53dpu_neon_vector_maxmin u_vector_maxmin (
      .neon_size_sel_f4_i       (neon_size_sel_f4),
      .neon_unsigned_op_f4_i    (neon_unsigned_op_f4),
      .neon_sat_op_sel_f4_i     (neon_sat_op_sel_f4),
      .neon_sat_dtect_res_f4_i  (raw_neon_sat_dtect_res_f4[7:0]),
      .alu_res_f4_i             (alu_res_f4[63:0]),
      .neon_vector_maxmin_f4_o  (neon_vector_maxmin_f4)
    );
  end else begin : g_vector_maxmin_stubs
    assign neon_vector_maxmin_f4 = {32{1'b0}};
  end endgenerate

  // Perform normalization shift

  ca53dpu_fp_alu_renorm u_renorm (
    .alu_res_f4_i (alu_res_f4),
    .shift_lo_i   (renorm_shift_f4[1]),
    .shift_hi_i   (renorm_shift_f4[0]),
    .dual_op_i    (ctl_dual_fp_f4),
    .result_o     (pre_shifted_frc_f4)
  );

  assign no_extra_shift_f4[0] =                   pre_shifted_frc_f4[107] | f2i_f4 | (({ {5{1'b0}}, renorm_shift_f4[0]} == exp_opd_f4[0]) & (|exp_opd_f4[0]));
  assign no_extra_shift_f4[1] = ctl_dual_fp_f4 ? (pre_shifted_frc_f4[ 52] | f2i_f4 | (({ {5{1'b0}}, renorm_shift_f4[1]} == exp_opd_f4[1]) & (|exp_opd_f4[1])))
                                               : no_extra_shift_f4[0];

  assign shifted_frc_f4[107:54] = no_extra_shift_f4[0] ? pre_shifted_frc_f4[107:54] : {pre_shifted_frc_f4[106:54], pre_shifted_frc_f4[53] & ~ctl_dual_fp_f4};
  assign shifted_frc_f4[ 53: 0] = no_extra_shift_f4[1] ? pre_shifted_frc_f4[ 53: 0] : {pre_shifted_frc_f4[ 52: 0], 1'b0};

  always @*
    case ({(s2h_f4 ? dual_s2h_f4 : ctl_dual_fp_f4), f2i_f4, neon_size_sel_f4})
      4'b0_0_01: begin  // Half precision (scalar operation)
        frc_sres_f4[31: 0]  = { {22{1'b0}}, shifted_frc_f4[106:97]};
        round_bit_f4[0]     = shifted_frc_f4[96];
        sticky_bit_f4[0]    = |shifted_frc_f4[95:54];
        frc_sres_f4[63:32]  = { {16{1'b0}}, shifted_frc_f4[51:36]};
        round_bit_f4[1]     = 1'b0;
        sticky_bit_f4[1]    = 1'b0;
      end

      4'b1_0_01: begin  // Half precision (vector operation)
        frc_sres_f4[31: 0]  = { {22{1'b0}}, shifted_frc_f4[106:97]};
        round_bit_f4[0]     = shifted_frc_f4[96];
        sticky_bit_f4[0]    = |shifted_frc_f4[95:54];
        frc_sres_f4[63:32]  = { {22{1'b0}}, shifted_frc_f4[ 51:42]};
        round_bit_f4[1]     = shifted_frc_f4[41];
        sticky_bit_f4[1]    = |shifted_frc_f4[40: 0];
      end

      4'b0_0_10: begin  // Single precision (scalar operation)
        frc_sres_f4[31: 0]  = { {9{1'b0}}, shifted_frc_f4[106:84]};
        round_bit_f4[0]     = shifted_frc_f4[83];
        sticky_bit_f4[0]    = |shifted_frc_f4[82:0];
        frc_sres_f4[63:32]  = { {9{1'b0}}, shifted_frc_f4[106:84]};
        round_bit_f4[1]     = shifted_frc_f4[83];
        sticky_bit_f4[1]    = |shifted_frc_f4[82:0];
      end

      4'b1_0_10: begin  // Single precision (vector operation)
        frc_sres_f4[31: 0]  = { {9{1'b0}}, shifted_frc_f4[106:84]};
        round_bit_f4[0]     = shifted_frc_f4[83];
        sticky_bit_f4[0]    = |shifted_frc_f4[82:54];
        frc_sres_f4[63:32]  = { {9{1'b0}}, shifted_frc_f4[51:29]};
        round_bit_f4[1]     = shifted_frc_f4[28];
        sticky_bit_f4[1]    = |shifted_frc_f4[27: 0];
      end

      4'b0_0_11: begin  // Double precision
        frc_sres_f4      = { {12{1'b0}}, shifted_frc_f4[106:55]};
        round_bit_f4[0]  = shifted_frc_f4[54];
        sticky_bit_f4[0] = |shifted_frc_f4[53:0];
        round_bit_f4[1]  = 1'b0;
        sticky_bit_f4[1] = 1'b0;
      end

      4'b0_1_01,        // 16-bit integer/fixed-point (scalar operation)
      4'b0_1_10: begin  // 32-bit integer/fixed-point (scalar operation)
        frc_sres_f4[31: 0]  = alu_res_f4[33:2];
        round_bit_f4[0]     = 1'b0;
        sticky_bit_f4[0]    = 1'b0;
        frc_sres_f4[63:32]  = alu_res_f4[33:2];
        round_bit_f4[1]     = 1'b0;
        sticky_bit_f4[1]    = 1'b0;
      end

      4'b1_1_10: begin  // 32-bit integer/fixed-point (vector operation)
        frc_sres_f4[31: 0]  = alu_res_f4[87:56];
        round_bit_f4[0]     = 1'b0;
        sticky_bit_f4[0]    = 1'b0;
        frc_sres_f4[63:32]  = alu_res_f4[33:2];
        round_bit_f4[1]     = 1'b0;
        sticky_bit_f4[1]    = 1'b0;
      end

      4'b0_1_11: begin  // 64-bit integer/fixed-point
        frc_sres_f4[63: 0]  = alu_res_f4[65:2];
        round_bit_f4[0]     = 1'b0;
        sticky_bit_f4[0]    = 1'b0;
        round_bit_f4[1]     = 1'b0;
        sticky_bit_f4[1]    = 1'b0;
      end

      default: begin
        frc_sres_f4   = {64{1'bx}};
        round_bit_f4  = 2'bxx;
        sticky_bit_f4 = 2'bxx;
      end
    endcase

  // Set increment exponent signal
  assign inc_exp_res_f4[0] = inc_frc_f4[0] & (s2h_f4 ? (&frc_sres_f4[ 9:0])
                                                     : (&frc_sres_f4[22:0])
                                                        & (~dp_op_sel_f4 | (&frc_sres_f4[51:23])));

  assign inc_exp_res_f4[1] = inc_frc_f4[1] & (s2h_f4 ? (&frc_sres_f4[41:32])
                                                     : (&frc_sres_f4[54:32]));

  // Set the rounding control signals
  assign round_infinity_f4 = ({2{rnd_mode_f4 == `CA53_FP_RMODE_RP}} & ~sign_f4[1:0]) |
                             ({2{rnd_mode_f4 == `CA53_FP_RMODE_RM}} &  sign_f4[1:0]);
  assign ovf_to_inf_f4     = ({2{rnd_mode_f4 == `CA53_FP_RMODE_RN}} | round_infinity_f4) & ~{2{s2h_f4 & fpscr_ahp_f4}};

  // Adjust exponent result
  assign exp_nres_f4[0] = (exp_opd_f4[0][11:0] == {12{1'b0}}) ? { {11{1'b0}}, shifted_frc_f4[107] & ~recpx_f4}                    :
                          shifted_frc_f4[107]                 ? (exp_opd_f4[0][11:0] + no_extra_shift_f4[0] - renorm_shift_f4[0]) :
                                                                {12{1'b0}};

  assign exp_nres_f4[1] = ~ctl_dual_fp_f4                     ? exp_nres_f4[0]                                                    :
                          (exp_opd_f4[1][11:0] == {12{1'b0}}) ? { {11{1'b0}}, shifted_frc_f4[52]}                                 :
                          shifted_frc_f4[52]                  ? (exp_opd_f4[1][11:0] + no_extra_shift_f4[1] - renorm_shift_f4[1]) :
                                                                {12{1'b0}};

  // Check the guard, round and sticky bits for round to
  // infinity and round to nearest cases
  assign nzero_grt_bits_f4 = round_bit_f4[1:0] | sticky_bit_f4[1:0] | f2i_inexact_f4[1:0];

  // Check if the result is denormalised
  assign denorm_fz_f4[0] = (force_dn_fz_f4 | fpscr_fz_f4) & (~|exp_nres_f4[0]) & (~(zres_f4[0] | zero_op_f4[0])) & ~f2i_f4 & ~s2h_f4 & ~rnd_integral_f4 & ~recpx_f4;
  assign denorm_fz_f4[1] = (force_dn_fz_f4 | fpscr_fz_f4) & (~|exp_nres_f4[1]) & (~(zres_f4[1] | zero_op_f4[1])) & ~f2i_f4 & ~s2h_f4 & ~rnd_integral_f4 & ~recpx_f4;

  // Increment significand signal
  assign inc_frc_f4[0] = ~denorm_fz_f4[0] & ~nan_inv_op_f4[0] &
                         ((rnd_mode_f4 == `CA53_FP_RMODE_RN) &  round_bit_f4[0] & (sticky_bit_f4[0] | frc_sres_f4[0])   |
                          (rnd_mode_f4 == `CA53_FP_RMODE_RX) & ~frc_sres_f4[0]  & (round_bit_f4[0]  | sticky_bit_f4[0]) |
                          (round_infinity_f4[0]            & (round_bit_f4[0] |  sticky_bit_f4[0])));

  assign inc_frc_f4[1] = ~denorm_fz_f4[1] & ~nan_inv_op_f4[1] &
                         ((rnd_mode_f4 == `CA53_FP_RMODE_RN) &  round_bit_f4[1] & (sticky_bit_f4[1] | frc_sres_f4[32])  |
                          (rnd_mode_f4 == `CA53_FP_RMODE_RX) & ~frc_sres_f4[32] & (round_bit_f4[1]  | sticky_bit_f4[1]) |
                          (round_infinity_f4[1]            & (round_bit_f4[1] |  sticky_bit_f4[1])));

  // Compute result sign
  assign sign_res_f4[0] = (~((force_dn_fz_f4 | fpscr_dn_f4) & ~(s2h_f4 & fpscr_ahp_f4) & nan_inv_op_f4[0]) | abs_neg_f4)
                          & (fp_op_f4 != `CA53_FP_OP_ABD)
                          & ((~nan_inv_op_f4[0] & zres_f4[0]) ? (rnd_mode_f4 == `CA53_FP_RMODE_RM) : sign_f4[0]);

  assign sign_res_f4[1] = (~((force_dn_fz_f4 | fpscr_dn_f4) & ~(s2h_f4 & fpscr_ahp_f4) & nan_inv_op_f4[1]) | abs_neg_f4)
                          & (fp_op_f4 != `CA53_FP_OP_ABD)
                          & ((~nan_inv_op_f4[1] & zres_f4[1]) ? (rnd_mode_f4 == `CA53_FP_RMODE_RM) : sign_f4[1]);

  // Compute zero result signal
  assign zero_out_f4 = zres_f4 | zero_op_f4 | (nan_inv_op_f4 & {2{s2h_f4 & fpscr_ahp_f4}});

  // Calculate if the result has overflowed. There are two basic cases here
  // - if the result before rounding has an exponent greater than the maximum
  // - if the result before rounding has the maximum exponent, and then rounding
  //   causes the exponent to be incremented
  //
  // To improve timing, the exponent before renormalisation is used, so there are
  // additional cases to consider:
  // - The ALU operation could have overflowed, meaning the exponent should be
  //   incremented, possibly cause an in-range exponent to overflow
  // - The ALU operation could have caused underflow, requiring the exponent
  //   to be reduced, possibly causing an out-of-range exponent (from a fused MAC)
  //   to become in-range. While cancellation could cause the exponent to be
  //   decremented by several places, it is only necessary to consider one bit
  //   for the purposes of detecting overflow

  always @*
    case (neon_size_sel_f4)
      2'b11: begin // Double precision
        exp_is_max_m1[0] = (exp_opd_f4[0] == 12'h7FD);
        exp_is_max[0]    = (exp_opd_f4[0] == 12'h7FE);
        exp_is_max_p1[0] = (exp_opd_f4[0] == 12'h7FF);
        exp_gt_max_p1[0] = (exp_opd_f4[0] >  12'h7FF);

        exp_is_max_m1[1] = 1'b0;
        exp_is_max[1]    = 1'b0;
        exp_is_max_p1[1] = 1'b0;
        exp_gt_max_p1[1] = 1'b0;
      end
      2'b10: begin // Single precision
        exp_is_max_m1[0] = (exp_opd_f4[0] == 12'h0FD);
        exp_is_max[0]    = (exp_opd_f4[0] == 12'h0FE);
        exp_is_max_p1[0] = (exp_opd_f4[0] == 12'h0FF);
        exp_gt_max_p1[0] = (exp_opd_f4[0] >  12'h0FF);

        exp_is_max_m1[1] = (exp_opd_f4[1] == 12'h0FD);
        exp_is_max[1]    = (exp_opd_f4[1] == 12'h0FE);
        exp_is_max_p1[1] = (exp_opd_f4[1] == 12'h0FF);
        exp_gt_max_p1[1] = (exp_opd_f4[1] >  12'h0FF);
      end
      2'b01: begin // Half precision
        exp_is_max_m1[0] = fpscr_ahp_f4 ? (exp_opd_f4[0] == 12'h01E) : (exp_opd_f4[0] == 12'h01D);
        exp_is_max[0]    = fpscr_ahp_f4 ? (exp_opd_f4[0] == 12'h01F) : (exp_opd_f4[0] == 12'h01E);
        exp_is_max_p1[0] = fpscr_ahp_f4 ? (exp_opd_f4[0] == 12'h020) : (exp_opd_f4[0] == 12'h01F);
        exp_gt_max_p1[0] = fpscr_ahp_f4 ? (exp_opd_f4[0] >  12'h020) : (exp_opd_f4[0] >  12'h01F);

        exp_is_max_m1[1] = fpscr_ahp_f4 ? (exp_opd_f4[1] == 12'h01E) : (exp_opd_f4[1] == 12'h01D);
        exp_is_max[1]    = fpscr_ahp_f4 ? (exp_opd_f4[1] == 12'h01F) : (exp_opd_f4[1] == 12'h01E);
        exp_is_max_p1[1] = fpscr_ahp_f4 ? (exp_opd_f4[1] == 12'h020) : (exp_opd_f4[1] == 12'h01F);
        exp_gt_max_p1[1] = fpscr_ahp_f4 ? (exp_opd_f4[1] >  12'h020) : (exp_opd_f4[1] >  12'h01F);
      end
      default: begin
        exp_is_max_m1 = 2'bxx;
        exp_is_max    = 2'bxx;
        exp_is_max_p1 = 2'bxx;
        exp_gt_max_p1 = 2'bxx;
      end
    endcase


  assign ovf_if_carry_f4[0] = ((exp_is_max_m1[0] &  alu_res_f4[107])               |
                               (exp_is_max[0]    & (alu_res_f4[107:106] == 2'b01)) |
                               (exp_is_max_p1[0] & (alu_res_f4[107:105] == 3'b001)))
                              & ~nan_inv_op_f4[0];

  assign ovf_always_f4[0]   = ((exp_is_max[0]    &  alu_res_f4[107])               |
                               (exp_is_max_p1[0] & (alu_res_f4[107:106] != 2'b00)) |
                                exp_gt_max_p1[0])
                              & ~nan_inv_op_f4[0];

  assign overflow_f4[0] = ovf_always_f4[0] | (ovf_if_carry_f4[0] & inc_exp_res_f4[0]);

  assign ovf_if_carry_f4[1] = ((exp_is_max_m1[1] &  alu_res_f4[ 52])               |
                               (exp_is_max[1]    & (alu_res_f4[ 52: 51] == 2'b01)) |
                               (exp_is_max_p1[1] & (alu_res_f4[ 52: 50] == 3'b001)))
                              & ~nan_inv_op_f4[1];

  assign ovf_always_f4[1]   = ((exp_is_max[1]    &  alu_res_f4[ 52])               |
                               (exp_is_max_p1[1] & (alu_res_f4[ 52: 51] != 2'b00)) |
                                exp_gt_max_p1[1])
                              & ~nan_inv_op_f4[1];

  assign overflow_f4[1] = ~ctl_dual_fp_f4 ? overflow_f4[0] : (ovf_always_f4[1] | (ovf_if_carry_f4[1] & inc_exp_res_f4[1]));

  // Check if underflow flag is set
  assign undf_res_f4 = denorm_fz_f4 & ~nan_inv_op_f4 & ~infinity_op_f4;


  assign f2i_signed_f4 = ~neon_unsigned_op_f4;

  assign f2i_msb_f4[0] = ctl_dual_fp_f4 ? ((neon_size_sel_f4 == 2'b10) ? alu_res_f4[87] :
                                                                         alu_res_f4[71])
                                        : ((neon_size_sel_f4 == 2'b11) ? alu_res_f4[65] :
                                           (neon_size_sel_f4 == 2'b10) ? alu_res_f4[33] :
                                                                         alu_res_f4[17]);
  assign f2i_msb_f4[1] =                   (neon_size_sel_f4 == 2'b11) ? alu_res_f4[65] :
                                           (neon_size_sel_f4 == 2'b10) ? alu_res_f4[33] :
                                                                         alu_res_f4[17];

  assign f2i_carry_f4[0] = ctl_dual_fp_f4 ? ((neon_size_sel_f4 == 2'b10) ? alu_res_f4[88] :
                                                                           alu_res_f4[72])
                                          : ((neon_size_sel_f4 == 2'b11) ? alu_res_f4[66] :
                                             (neon_size_sel_f4 == 2'b10) ? alu_res_f4[34] :
                                                                           alu_res_f4[18]);
  assign f2i_carry_f4[1] =                   (neon_size_sel_f4 == 2'b11) ? alu_res_f4[66] :
                                             (neon_size_sel_f4 == 2'b10) ? alu_res_f4[34] :
                                                                           alu_res_f4[18];

  assign f2i_pos_sat_f4[0] = f2i_f4 & (f2i_overflow_f4[0] ? ~(sign_res_f4[0] | nan_inv_op_f4[0])    :
                                       f2i_signed_f4      ? (f2i_msb_f4[0] | f2i_carry_f4[0]) & ~sign_f4[0] :
                                                                             f2i_carry_f4[0]  & ~sign_f4[0]);
  assign f2i_neg_sat_f4[0] = f2i_f4 & (f2i_overflow_f4[0] ?  (sign_res_f4[0] | nan_inv_op_f4[0]) :
                                       f2i_signed_f4      ? ~f2i_msb_f4[0] & f2i_carry_f4[0]  &  sign_f4[0] :
                                                                             f2i_carry_f4[0]  &  sign_f4[0]);

  assign f2i_pos_sat_f4[1] = f2i_f4 & (f2i_overflow_f4[1] ? ~(sign_res_f4[1] | nan_inv_op_f4[1])    :
                                       f2i_signed_f4      ? (f2i_msb_f4[1] | f2i_carry_f4[1]) & ~sign_f4[1] :
                                                                             f2i_carry_f4[1]  & ~sign_f4[1]);
  assign f2i_neg_sat_f4[1] = f2i_f4 & (f2i_overflow_f4[1] ?  (sign_res_f4[1] | nan_inv_op_f4[1]) :
                                       f2i_signed_f4      ? ~f2i_msb_f4[1] & f2i_carry_f4[1]  &  sign_f4[1] :
                                                                             f2i_carry_f4[1]  &  sign_f4[1]);

  // MUX to select result output
  assign nfrc_sres_f4 = (~neon_int_sel_f4 & ~cmp_cmd_f4)              ? frc_sres_f4                          :
                        ((neon_sat_op_sel_f4 == `CA53_NEON_SAT_MAXV) |
                         (neon_sat_op_sel_f4 == `CA53_NEON_SAT_MINV)) ? { {32{1'b0}}, neon_vector_maxmin_f4} :
                        (neon_sat_op_sel_f4 != `CA53_NEON_SAT_NONE)   ? neon_sat_res_f4                      :
                                                                      neon_sat_in_res_f4;

  assign advance_f4 = advance_pipeline_i & enable_f4;

  always @(posedge clk_fp_alu)
    if (advance_f4) begin
      fp_op_f5            <= fp_op_f4;
      zero_out_f5         <= zero_out_f4;
      sign_res_f5         <= sign_res_f4;
      exp_nres_f5[0]      <= exp_nres_f4[0];
      exp_nres_f5[1]      <= exp_nres_f4[1];
      frc_sres_f5         <= nfrc_sres_f4;
      inc_exp_res_f5      <= inc_exp_res_f4;
      inc_frc_f5          <= inc_frc_f4;
      raw_invalid_op_f5   <= invalid_op_f4;
      infinity_op_f5      <= infinity_op_f4;
      nan_inv_op_f5       <= nan_inv_op_f4;
      ovf_to_inf_f5       <= ovf_to_inf_f4;
      nzero_grt_bits_f5   <= nzero_grt_bits_f4;
      undf_res_f5         <= undf_res_f4;
      f2i_carry_f5        <= f2i_carry_f4;
      overflow_f5         <= overflow_f4;
      f2i_pos_sat_f5      <= f2i_pos_sat_f4;
      f2i_neg_sat_f5      <= f2i_neg_sat_f4;
      ifz_f5              <= ifz_f4;
      fpscr_ahp_f5        <= fpscr_ahp_i;
      neon_int_sel_f5     <= neon_int_sel_f4;
      neon_sat_flag_f5    <= neon_sat_flag_f4;
      neon_size_sel_f5    <= neon_size_sel_f4;
      neon_unsigned_op_f5 <= neon_unsigned_op_f4;
      ctl_dual_fp_f5      <= ctl_dual_fp_f4;
      dual_s2h_f5         <= dual_s2h_f4;
    end

  //----------------------------------------------------------
  // F5 stage
  //----------------------------------------------------------

  // Floating to integer conversion signal
  assign f2i_f5 = (fp_op_f5 == `CA53_FP_OP_S2I)   | (fp_op_f5 == `CA53_FP_OP_D2I) | (fp_op_f5 == `CA53_FP_OP_D2FP);
  assign s2h_f5 = (fp_op_f5 == `CA53_FP_OP_F2H_B) | (fp_op_f5 == `CA53_FP_OP_F2H_T);

  assign d2fix_f5 = (fp_op_f5 == `CA53_FP_OP_D2FP);

  assign rnd_integral_f5 = (fp_op_f5 == `CA53_FP_OP_RINT) | (fp_op_f5 == `CA53_FP_OP_RINTX);

  assign cmp_cmd_f5 = (fp_op_f5 == `CA53_FP_OP_CMP) | (fp_op_f5 == `CA53_FP_OP_CMPE) | (fp_op_f5 == `CA53_FP_OP_ACMPE);

  // Not invalid, Nan or infinity operation
  assign nan_inv_inf_op = (nan_inv_op_f5 & ~{2{s2h_f5 & fpscr_ahp_f5}}) | infinity_op_f5;

  // Increment exponent result if required
  assign exp_inc_res[0] = inc_exp_res_f5[0] ? exp_nres_f5[0] + 1'b1 : exp_nres_f5[0];
  assign exp_inc_res[1] = inc_exp_res_f5[1] ? exp_nres_f5[1] + 1'b1 : exp_nres_f5[1];

  // Increment fraction result if required

  assign {frac_carry_f5[0], frc_inc_res[31: 0]} = frc_sres_f5[31: 0] + 1'b1;
  assign {frac_carry_f5[1], frc_inc_res[63:32]} = frc_sres_f5[63:32] + 1'b1;

  assign inc_frc_hi_f5 = (neon_size_sel_f5 == 2'b11) ? (inc_frc_f5[0] & frac_carry_f5[0])
                                                     :  inc_frc_f5[1];

  assign rounded_frac_f5[31: 0] = inc_frc_f5[0] ? frc_inc_res[31: 0] : frc_sres_f5[31: 0];
  assign rounded_frac_f5[63:32] = inc_frc_hi_f5 ? frc_inc_res[63:32] : frc_sres_f5[63:32];

  // Compute the inexact flag
  assign inexact_excpt = |((overflow_f5 | nzero_grt_bits_f5) & ~nan_inv_inf_op & ~undf_res_f5 & ~invalid_op_f5 & {ctl_dual_fp_f5, 1'b1});

  // Check if overflow flag is set
  assign ovf_res[1:0] = overflow_f5[1:0] & ~nan_inv_inf_op[1:0];

  assign underflow_excpt = (|undf_res_f5) |
                           ((exp_nres_f5[0] == {12{1'b0}}) & nzero_grt_bits_f5[0] & ~f2i_f5 & ~rnd_integral_f5) |
                           ((exp_nres_f5[1] == {12{1'b0}}) & nzero_grt_bits_f5[1] & ~f2i_f5 & ~rnd_integral_f5);

  // AHP single-to-half operations return invalid operation rather than overflow exception
  assign invalid_op_f5[1:0] = raw_invalid_op_f5[1:0] |
                              ({2{s2h_f5 & fpscr_ahp_f5}} & ovf_res[1:0]) |
                              f2i_pos_sat_f5[1:0] | f2i_neg_sat_f5[1:0];

  // Check if there is an exception
  assign exc_res = (overflow_f5 & ovf_to_inf_f5) | (infinity_op_f5 & ~nan_inv_op_f5);

  // Compute final exponent result
  assign exp_res[0] = {{10{nan_inv_inf_op[0] | exc_res[0] | overflow_f5[0]}}, nan_inv_inf_op[0] | exc_res[0] | (overflow_f5[0] & s2h_f5 & fpscr_ahp_f5)} |
                      ({{10{~zero_out_f5[0]}}, ~(zero_out_f5[0] | (overflow_f5[0] & ~ovf_to_inf_f5[0]))} & exp_inc_res[0][10:0]);

  assign exp_res[1] = {{10{nan_inv_inf_op[1] | exc_res[1] | overflow_f5[1]}}, nan_inv_inf_op[1] | exc_res[1] | (overflow_f5[1] & s2h_f5 & fpscr_ahp_f5)} |
                      ({{10{~zero_out_f5[1]}}, ~(zero_out_f5[1] | (overflow_f5[1] & ~ovf_to_inf_f5[1]))} & exp_inc_res[1][10:0]);

  // Floating to integer conversion signals
  assign f2i_sign[0] = (f2i_neg_sat_f5[0] & ~nan_inv_op_f5[0]) | (f2i_carry_f5[0] & ~f2i_pos_sat_f5[0] & ~nan_inv_op_f5[0]);
  assign f2i_sign[1] = (f2i_neg_sat_f5[1] & ~nan_inv_op_f5[1]) | (f2i_carry_f5[1] & ~f2i_pos_sat_f5[1] & ~nan_inv_op_f5[1]);

  // Compute final fraction result
  assign frc_res[31: 0] = {32{~(exc_res[0] | undf_res_f5[0] | f2i_neg_sat_f5[0])}} & ({32{overflow_f5[0] | f2i_pos_sat_f5[0]}} | rounded_frac_f5[31: 0]);
  assign frc_res[63:32] = {32{~(exc_res[1] | undf_res_f5[1] | f2i_neg_sat_f5[1])}} & ({32{overflow_f5[1] | f2i_pos_sat_f5[1]}} | rounded_frac_f5[63:32]);

  always @*
    case ({f2i_f5, neon_size_sel_f5})
      3'b0_10: begin  // Single precision
        res_f5 = {sign_res_f5[1], exp_res[1][7:0], frc_res[54:32],
                  sign_res_f5[0], exp_res[0][7:0], frc_res[22: 0]};
      end

      3'b0_11: begin  // Double precision
        res_f5 = {sign_res_f5[0], exp_res[0][10:0], frc_res[51:0]};
      end

      3'b0_01: begin  // Half precision
        case ({dual_s2h_f5, fp_op_f5})
          {1'b1, `CA53_FP_OP_F2H_B}:
            res_f5 = {sign_res_f5[1], exp_res[1][4:0], frc_res[41:32],
                      sign_res_f5[0], exp_res[0][4:0], frc_res[ 9: 0],
                      sign_res_f5[1], exp_res[1][4:0], frc_res[41:32],
                      sign_res_f5[0], exp_res[0][4:0], frc_res[ 9: 0]};

          {1'b0, `CA53_FP_OP_F2H_B}:
            res_f5 = {frc_sres_f5[47:32],
                      sign_res_f5[0], exp_res[0][4:0], frc_res[ 9: 0],
                      frc_sres_f5[47:32],
                      sign_res_f5[0], exp_res[0][4:0], frc_res[ 9: 0]};

          {1'b0, `CA53_FP_OP_F2H_T}:
            res_f5 = {sign_res_f5[0], exp_res[0][4:0], frc_res[9:0],
                      frc_sres_f5[47:32],
                      sign_res_f5[0], exp_res[0][4:0], frc_res[9:0],
                      frc_sres_f5[47:32]};

          default: res_f5 = {64{1'bx}};
        endcase
      end

      3'b1_11: begin
        res_f5 = neon_unsigned_op_f5 ?                frc_res[63:0]
                                     : { f2i_sign[0], frc_res[62:0] };
      end

      3'b1_10: begin
        res_f5 = neon_unsigned_op_f5 ? { ({32{~d2fix_f5}} & frc_res[63:32]),
                                         frc_res[31:0] }
                                     : { f2i_sign[1], (d2fix_f5 ? {31{f2i_sign[1]}} : frc_res[62:32]),
                                         f2i_sign[0], frc_res[30:0] };
      end

      3'b1_01: begin
        res_f5 = neon_unsigned_op_f5 ? { 16'h0000, ({16{~d2fix_f5}} & frc_res[47:32]),
                                         16'h0000, frc_res[15:0] }
                                     : { {17{f2i_sign[1]}}, (d2fix_f5 ? {15{f2i_sign[1]}} : frc_res[46:32]),
                                         {17{f2i_sign[0]}}, frc_res[14:0] };
      end

      default:
        res_f5 = {64{1'bx}};
    endcase

  assign fad_data_f5_o                          = (neon_int_sel_f5 | cmp_cmd_f5) ? frc_sres_f5 : res_f5;
  assign add_xflags_f5_o[`CA53_XFLAGS_QC_BITS]  =  neon_int_sel_f5 & neon_sat_flag_f5;
  assign add_xflags_f5_o[`CA53_XFLAGS_IDC_BITS] = ~neon_int_sel_f5 & ifz_f5;
  assign add_xflags_f5_o[`CA53_XFLAGS_IXC_BITS] = ~neon_int_sel_f5 & ~cmp_cmd_f5 & inexact_excpt;
  assign add_xflags_f5_o[`CA53_XFLAGS_IOC_BITS] = ~neon_int_sel_f5 & (|invalid_op_f5);
  assign add_xflags_f5_o[`CA53_XFLAGS_OFC_BITS] = ~neon_int_sel_f5 & ~cmp_cmd_f5 & (|(ovf_res[1:0] & ~invalid_op_f5[1:0]));
  assign add_xflags_f5_o[`CA53_XFLAGS_UFC_BITS] = ~neon_int_sel_f5 & ~cmp_cmd_f5 & underflow_excpt;
  assign add_xflags_f5_o[`CA53_XFLAGS_DZC_BITS] = 1'b0;

  // Forwarding outputs
  assign fad_early_data_f3_o = neon_lu_res_f3;
  assign fad_early_data_f4_o = alu_res_f4[63:0];

  // Comparison result flags
  assign fp_cmpflags_f2_o = cmpflags_f2;

  assign add_enable_f2_o = enable_f2;
  assign add_enable_f3_o = enable_f3;

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_f1")
  u_ovl_x_advance_f1 (.clk       (clk_fp_alu),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (advance_f1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_f2")
  u_ovl_x_advance_f2 (.clk       (clk_fp_alu),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (advance_f2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_f3")
  u_ovl_x_advance_f3 (.clk       (clk_fp_alu),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (advance_f3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_f4")
  u_ovl_x_advance_f4 (.clk       (clk_fp_alu),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (advance_f4));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_pipeline_i")
  u_ovl_x_advance_pipeline_i (.clk       (clk_fp_alu),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (advance_pipeline_i));


`endif

endmodule // ca53dpu_fp_alu

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
