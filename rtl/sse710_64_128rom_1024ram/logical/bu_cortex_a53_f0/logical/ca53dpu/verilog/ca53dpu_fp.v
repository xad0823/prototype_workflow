//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2014 ARM Limited.
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
// Abstract : Floating point unit
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// This module instantiates the FPU modules

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_fp `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire                             clk_fp,
  input  wire                             clk_fp_alu0,
  input  wire                             clk_fp_alu1,
  input  wire                             clk_fp_mul0,
  input  wire                             clk_fp_mul1,
  input  wire                             clk_crypto,
  input  wire                             clk_fp_nrf,
  input  wire                             reset_n,
  input  wire                             flush_ret_i,
  input  wire                             stall_wr_i,
  input  wire                             advance_pipeline_i,
  input  wire                             cp_fpcr_ahp_i,
  input  wire                             cp_fpcr_dn_i,
  input  wire                             cp_fpcr_fz_i,
  input  wire                       [1:0] cp_fpcr_rmode_i,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr0_iss_i,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr1_iss_i,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr2_iss_i,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr3_iss_i,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr4_iss_i,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr5_iss_i,
  input  wire                             issue_to_ex1_i,
  input  wire                       [1:0] rf_rd_en_fr0_iss_i,
  input  wire                       [1:0] rf_rd_en_fr1_iss_i,
  input  wire                       [1:0] rf_rd_en_fr2_iss_i,
  input  wire                       [1:0] rf_rd_en_fr3_iss_i,
  input  wire                       [1:0] rf_rd_en_fr4_iss_i,
  input  wire                       [1:0] rf_rd_en_fr5_iss_i,
  input  wire                       [1:0] rf_rd_en_fr0_f1_i,
  input  wire                       [1:0] rf_rd_en_fr1_f1_i,
  input  wire                       [1:0] rf_rd_en_fr2_f1_i,
  input  wire                       [1:0] rf_rd_en_fr3_f1_i,
  input  wire                       [1:0] rf_rd_en_fr4_f1_i,
  input  wire                       [1:0] rf_rd_en_fr5_f1_i,
  input  wire                       [1:0] rf_rd_en_fr0_f2_i,
  input  wire                       [1:0] rf_rd_en_fr1_f2_i,
  input  wire                       [1:0] rf_rd_en_fr2_f2_i,
  input  wire                       [1:0] rf_rd_en_fr3_f2_i,
  input  wire                       [1:0] rf_rd_en_fr4_f2_i,
  input  wire                       [1:0] rf_rd_en_fr5_f2_i,
  input  wire                       [5:0] fr0_fwd_f1_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr1_fwd_f1_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr2_fwd_f1_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr3_fwd_f1_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr4_fwd_f1_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr5_fwd_f1_i,             // FPU forwarding mux select
  input  wire     [`CA53_SEL_FAD_A_W-1:0] sel_fad0_a_f1_i,          // Mux select signal(s) for FAD_A
  input  wire     [`CA53_SEL_FAD_B_W-1:0] sel_fad0_b_f1_i,          // Mux select signal(s) for FAD_B
  input  wire     [`CA53_SEL_FAD_C_W-1:0] sel_fad0_c_f1_i,          // Mux select signal(s) for FAD_C
  input  wire     [`CA53_SEL_FAD_A_W-1:0] sel_fad1_a_f1_i,          // Mux select signal(s) for FAD_A
  input  wire     [`CA53_SEL_FAD_B_W-1:0] sel_fad1_b_f1_i,          // Mux select signal(s) for FAD_B
  input  wire     [`CA53_SEL_FAD_C_W-1:0] sel_fad1_c_f1_i,          // Mux select signal(s) for FAD_C
  input  wire                             sel_fml0_a_f1_i,          // Mux select signal(s) for FML_A
  input  wire     [`CA53_SEL_FML_B_W-1:0] sel_fml0_b_f1_i,          // Mux select signal(s) for FML_B
  input  wire                             sel_fml0_c_f1_i,          // Mux select signal(s) for FML_C
  input  wire                             sel_fml1_a_f1_i,          // Mux select signal(s) for FML_A
  input  wire     [`CA53_SEL_FML_B_W-1:0] sel_fml1_b_f1_i,          // Mux select signal(s) for FML_B
  input  wire                             sel_fml1_c_f1_i,          // Mux select signal(s) for FML_C
  input  wire                       [5:0] fr0_fwd_f2_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr1_fwd_f2_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr2_fwd_f2_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr3_fwd_f2_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr4_fwd_f2_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr5_fwd_f2_i,             // FPU forwarding mux select
  input  wire                       [1:0] fp_mul_fwd_f2_i,
  input  wire                       [1:0] str0_sel_fp_f1_i,
  input  wire                       [1:0] str1_sel_fp_f1_i,
  input  wire                       [1:0] str0_sel_fp_f2_i,
  input  wire                       [1:0] str1_sel_fp_f2_i,
  input  wire    [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_f3_i,       // Mux select signal(s) for RF write port 0
  input  wire    [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_f4_i,       // Mux select signal(s) for RF write port 0
  input  wire    [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_f5_i,       // Mux select signal(s) for RF write port 0
  input  wire    [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw1_f3_i,       // Mux select signal(s) for RF write port 0
  input  wire    [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw1_f4_i,       // Mux select signal(s) for RF write port 0
  input  wire    [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw1_f5_i,       // Mux select signal(s) for RF write port 0
  input  wire   [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw0_f4_i,
  input  wire   [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw1_f4_i,
  input  wire                             rf_wr_en_fw_f3_i,
  input  wire                       [3:0] rf_wr_en_fw0_f5_i,
  input  wire                       [3:0] rf_wr_en_fw1_f5_i,
  input  wire [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw0_f5_i,
  input  wire [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw1_f5_i,
  input  wire                      [12:0] fp0_imm_data_f1_i,        // FPU immediate data
  input  wire                      [12:0] fp1_imm_data_f1_i,        // FPU immediate data
  input  wire    [`CA53_FP_EX_PIPE_W-1:0] fp_ex_pipe_f1_i,
  input  wire                             crypto_enable_f1_i,
  input  wire    [`CA53_FP_PIPECTL_W-1:0] fp0_pipectl_f1_i,
  input  wire    [`CA53_FP_PIPECTL_W-1:0] fp1_pipectl_f1_i,
  input  wire                       [1:0] fp_div_enb_f1_i,
  input  wire                             alu0_csel_pass_ex2_i,
  input  wire                             instr_is_cp10_cp11_wr_i,
  input  wire  [`CA53_NEON_VLD_CTL_W-1:0] neon_vld_ctl_f3_i,
  input  wire                             valid_instrs_wr_i,
  input  wire                             issue_to_ex2_fpu_i,
  input  wire                             issue_to_f4_i,
  input  wire                             first_x64_wr_i,
  input  wire                      [63:0] fwd_ld_data_int_wr_i,     // Load data from DCU (not sign extended)
  input  wire                      [63:0] st0_data_ex1_i,           // Data from store pipe
  input  wire                      [63:0] st0_data_wr_i,            // Data from store pipe
  input  wire                      [63:0] st1_data_ex1_i,           // Data from store pipe
  input  wire                      [63:0] st1_data_wr_i,            // Data from store pipe
  input  wire                       [1:0] ls_elem_size_wr_i,        // Size of element data
  // Outputs
  output wire                       [1:0] fp_alu_en_o,
  output wire                       [1:0] fp_mul_en_o,
  output wire                       [1:0] fp_div_busy_nxt_cyc_o,
  output wire                      [63:0] fp_str0_data_f1_o,
  output wire                      [63:0] fp_str1_data_f1_o,
  output wire                      [63:0] fp_str0_data_f2_o,
  output wire                      [63:0] fp_str1_data_f2_o,
  output wire                      [63:0] fp_alu0_f2i_res_f3_o,     // Result of A64 float->int conversion
  output wire                      [63:0] fp_alu1_f2i_res_f3_o,     // Result of A64 float->int conversion
  output wire                       [3:0] fp_cflags_add0_f2_o,
  output wire                       [3:0] fp_cflags_add1_f2_o,
  output wire        [`CA53_XFLAGS_W-1:0] fp_xflags_mul0_f5_o,
  output wire        [`CA53_XFLAGS_W-1:0] fp_xflags_mul1_f5_o,
  output wire        [`CA53_XFLAGS_W-1:0] fp_xflags_add0_f5_o,
  output wire        [`CA53_XFLAGS_W-1:0] fp_xflags_add1_f5_o,
  output wire                             fp_dp_en_active_o,
  output wire                             crypto_active_o
);

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [63:0] rf_rd_data_fr0_f1;
  wire [63:0] rf_rd_data_fr1_f1;
  wire [63:0] rf_rd_data_fr2_f1;
  wire [63:0] rf_rd_data_fr3_f1;
  wire [63:0] rf_rd_data_fr4_f1;
  wire [63:0] rf_rd_data_fr5_f1;
  wire [63:0] rf_wr_data_fw0_f5;
  wire [63:0] rf_wr_data_fw1_f5;

  // ------------------------------------------------------
  // Floating-point datapath
  // ------------------------------------------------------

  ca53dpu_fp_dp `CA53_DPU_PARAM_INST u_dpu_fp_dp (
    // Inputs
    .clk_fp                   (clk_fp),
    .clk_fp_alu0              (clk_fp_alu0),
    .clk_fp_alu1              (clk_fp_alu1),
    .clk_fp_mul0              (clk_fp_mul0),
    .clk_fp_mul1              (clk_fp_mul1),
    .clk_crypto               (clk_crypto),
    .reset_n                  (reset_n),
    .flush_ret_i              (flush_ret_i),
    .stall_wr_i               (stall_wr_i),
    .advance_pipeline_i       (advance_pipeline_i),
    .rf_rd_en_fr0_f1_i        (rf_rd_en_fr0_f1_i),
    .rf_rd_en_fr1_f1_i        (rf_rd_en_fr1_f1_i),
    .rf_rd_en_fr2_f1_i        (rf_rd_en_fr2_f1_i),
    .rf_rd_en_fr3_f1_i        (rf_rd_en_fr3_f1_i),
    .rf_rd_en_fr4_f1_i        (rf_rd_en_fr4_f1_i),
    .rf_rd_en_fr5_f1_i        (rf_rd_en_fr5_f1_i),
    .rf_rd_en_fr0_f2_i        (rf_rd_en_fr0_f2_i),
    .rf_rd_en_fr1_f2_i        (rf_rd_en_fr1_f2_i),
    .rf_rd_en_fr2_f2_i        (rf_rd_en_fr2_f2_i),
    .rf_rd_en_fr3_f2_i        (rf_rd_en_fr3_f2_i),
    .rf_rd_en_fr4_f2_i        (rf_rd_en_fr4_f2_i),
    .rf_rd_en_fr5_f2_i        (rf_rd_en_fr5_f2_i),
    .rf_rd_data_fr0_f1_i      (rf_rd_data_fr0_f1[63:0]),
    .rf_rd_data_fr1_f1_i      (rf_rd_data_fr1_f1[63:0]),
    .rf_rd_data_fr2_f1_i      (rf_rd_data_fr2_f1[63:0]),
    .rf_rd_data_fr3_f1_i      (rf_rd_data_fr3_f1[63:0]),
    .rf_rd_data_fr4_f1_i      (rf_rd_data_fr4_f1[63:0]),
    .rf_rd_data_fr5_f1_i      (rf_rd_data_fr5_f1[63:0]),
    .fr0_fwd_f1_i             (fr0_fwd_f1_i[5:0]),
    .fr1_fwd_f1_i             (fr1_fwd_f1_i[5:0]),
    .fr2_fwd_f1_i             (fr2_fwd_f1_i[5:0]),
    .fr3_fwd_f1_i             (fr3_fwd_f1_i[5:0]),
    .fr4_fwd_f1_i             (fr4_fwd_f1_i[5:0]),
    .fr5_fwd_f1_i             (fr5_fwd_f1_i[5:0]),
    .sel_fad0_a_f1_i          (sel_fad0_a_f1_i[`CA53_SEL_FAD_A_W-1:0]),
    .sel_fad0_b_f1_i          (sel_fad0_b_f1_i[`CA53_SEL_FAD_B_W-1:0]),
    .sel_fad0_c_f1_i          (sel_fad0_c_f1_i[`CA53_SEL_FAD_C_W-1:0]),
    .sel_fad1_a_f1_i          (sel_fad1_a_f1_i[`CA53_SEL_FAD_A_W-1:0]),
    .sel_fad1_b_f1_i          (sel_fad1_b_f1_i[`CA53_SEL_FAD_B_W-1:0]),
    .sel_fad1_c_f1_i          (sel_fad1_c_f1_i[`CA53_SEL_FAD_C_W-1:0]),
    .sel_fml0_a_f1_i          (sel_fml0_a_f1_i),
    .sel_fml0_b_f1_i          (sel_fml0_b_f1_i[`CA53_SEL_FML_B_W-1:0]),
    .sel_fml0_c_f1_i          (sel_fml0_c_f1_i),
    .sel_fml1_a_f1_i          (sel_fml1_a_f1_i),
    .sel_fml1_b_f1_i          (sel_fml1_b_f1_i[`CA53_SEL_FML_B_W-1:0]),
    .sel_fml1_c_f1_i          (sel_fml1_c_f1_i),
    .fr0_fwd_f2_i             (fr0_fwd_f2_i[5:0]),
    .fr1_fwd_f2_i             (fr1_fwd_f2_i[5:0]),
    .fr2_fwd_f2_i             (fr2_fwd_f2_i[5:0]),
    .fr3_fwd_f2_i             (fr3_fwd_f2_i[5:0]),
    .fr4_fwd_f2_i             (fr4_fwd_f2_i[5:0]),
    .fr5_fwd_f2_i             (fr5_fwd_f2_i[5:0]),
    .fp_mul_fwd_f2_i          (fp_mul_fwd_f2_i),
    .str0_sel_fp_f1_i         (str0_sel_fp_f1_i[1:0]),
    .str1_sel_fp_f1_i         (str1_sel_fp_f1_i[1:0]),
    .str0_sel_fp_f2_i         (str0_sel_fp_f2_i[1:0]),
    .str1_sel_fp_f2_i         (str1_sel_fp_f2_i[1:0]),
    .rf_wr_en_fw_f3_i         (rf_wr_en_fw_f3_i),
    .rf_wr_src_fw0_f3_i       (rf_wr_src_fw0_f3_i[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_src_fw0_f4_i       (rf_wr_src_fw0_f4_i[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_src_fw0_f5_i       (rf_wr_src_fw0_f5_i[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_src_fw1_f3_i       (rf_wr_src_fw1_f3_i[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_src_fw1_f4_i       (rf_wr_src_fw1_f4_i[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_src_fw1_f5_i       (rf_wr_src_fw1_f5_i[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_when_fw0_f4_i      (rf_wr_when_fw0_f4_i[`CA53_RF_FWR_WHEN_W-1:0]),
    .rf_wr_when_fw1_f4_i      (rf_wr_when_fw1_f4_i[`CA53_RF_FWR_WHEN_W-1:0]),
    .fp0_imm_data_f1_i        (fp0_imm_data_f1_i[12:0]),
    .fp1_imm_data_f1_i        (fp1_imm_data_f1_i[12:0]),
    .fp_ex_pipe_f1_i          (fp_ex_pipe_f1_i[`CA53_FP_EX_PIPE_W-1:0]),
    .crypto_enable_f1_i       (crypto_enable_f1_i),
    .fp0_pipectl_f1_i         (fp0_pipectl_f1_i[`CA53_FP_PIPECTL_W-1:0]),
    .fp1_pipectl_f1_i         (fp1_pipectl_f1_i[`CA53_FP_PIPECTL_W-1:0]),
    .fp_div_enb_f1_i          (fp_div_enb_f1_i[1:0]),
    .alu0_csel_pass_ex2_i     (alu0_csel_pass_ex2_i),
    .instr_is_cp10_cp11_wr_i  (instr_is_cp10_cp11_wr_i),
    .neon_vld_ctl_f3_i        (neon_vld_ctl_f3_i[`CA53_NEON_VLD_CTL_W-1:0]),
    .cp_fpcr_ahp_i            (cp_fpcr_ahp_i),
    .cp_fpcr_dn_i             (cp_fpcr_dn_i),
    .cp_fpcr_fz_i             (cp_fpcr_fz_i),
    .cp_fpcr_rmode_i          (cp_fpcr_rmode_i),
    .valid_instrs_wr_i        (valid_instrs_wr_i),
    .issue_to_ex2_fpu_i       (issue_to_ex2_fpu_i),
    .issue_to_f4_i            (issue_to_f4_i),
    .first_x64_wr_i           (first_x64_wr_i),
    .fwd_ld_data_int_wr_i     (fwd_ld_data_int_wr_i[63:0]),
    .st0_data_ex1_i           (st0_data_ex1_i[63:0]),
    .st0_data_wr_i            (st0_data_wr_i[63:0]),
    .st1_data_ex1_i           (st1_data_ex1_i[63:0]),
    .st1_data_wr_i            (st1_data_wr_i[63:0]),
    .ls_elem_size_wr_i        (ls_elem_size_wr_i[1:0]),
    // Outputs
    .fp_alu_en_o              (fp_alu_en_o),
    .fp_mul_en_o              (fp_mul_en_o),
    .fp_div_busy_nxt_cyc_o    (fp_div_busy_nxt_cyc_o),
    .rf_wr_data_fw0_f5_o      (rf_wr_data_fw0_f5[63:0]),
    .rf_wr_data_fw1_f5_o      (rf_wr_data_fw1_f5[63:0]),
    .fp_str0_data_f1_o        (fp_str0_data_f1_o[63:0]),
    .fp_str1_data_f1_o        (fp_str1_data_f1_o[63:0]),
    .fp_str0_data_f2_o        (fp_str0_data_f2_o[63:0]),
    .fp_str1_data_f2_o        (fp_str1_data_f2_o[63:0]),
    .fp_alu0_f2i_res_f3_o     (fp_alu0_f2i_res_f3_o[63:0]),
    .fp_alu1_f2i_res_f3_o     (fp_alu1_f2i_res_f3_o[63:0]),
    .fp_cflags_add0_f2_o      (fp_cflags_add0_f2_o[3:0]),
    .fp_cflags_add1_f2_o      (fp_cflags_add1_f2_o[3:0]),
    .fp_xflags_mul0_f5_o      (fp_xflags_mul0_f5_o[`CA53_XFLAGS_W-1:0]),
    .fp_xflags_mul1_f5_o      (fp_xflags_mul1_f5_o[`CA53_XFLAGS_W-1:0]),
    .fp_xflags_add0_f5_o      (fp_xflags_add0_f5_o[`CA53_XFLAGS_W-1:0]),
    .fp_xflags_add1_f5_o      (fp_xflags_add1_f5_o[`CA53_XFLAGS_W-1:0]),
    .fp_dp_en_active_o        (fp_dp_en_active_o),
    .crypto_active_o          (crypto_active_o)
  );

  // ------------------------------------------------------
  // FPU Register File
  // ------------------------------------------------------

  ca53dpu_fp_regbank u_dpu_fp_regbank (
    // Inputs
    .clk_fp               (clk_fp),
    .clk_fp_nrf           (clk_fp_nrf),
    .reset_n              (reset_n),
    .rf_rd_addr_fr0_iss_i (rf_rd_addr_fr0_iss_i[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_addr_fr1_iss_i (rf_rd_addr_fr1_iss_i[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_addr_fr2_iss_i (rf_rd_addr_fr2_iss_i[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_addr_fr3_iss_i (rf_rd_addr_fr3_iss_i[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_addr_fr4_iss_i (rf_rd_addr_fr4_iss_i[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_addr_fr5_iss_i (rf_rd_addr_fr5_iss_i[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .issue_to_ex1_i       (issue_to_ex1_i),
    .rf_rd_en_fr0_iss_i   (rf_rd_en_fr0_iss_i),
    .rf_rd_en_fr1_iss_i   (rf_rd_en_fr1_iss_i),
    .rf_rd_en_fr2_iss_i   (rf_rd_en_fr2_iss_i),
    .rf_rd_en_fr3_iss_i   (rf_rd_en_fr3_iss_i),
    .rf_rd_en_fr4_iss_i   (rf_rd_en_fr4_iss_i),
    .rf_rd_en_fr5_iss_i   (rf_rd_en_fr5_iss_i),
    .rf_wr_en_fw0_f5_i    (rf_wr_en_fw0_f5_i),
    .rf_wr_en_fw1_f5_i    (rf_wr_en_fw1_f5_i),
    .rf_wr_addr_fw0_f5_i  (rf_wr_addr_fw0_f5_i[`CA53_FP_RF_WR_ADDR_W-1:0]),
    .rf_wr_addr_fw1_f5_i  (rf_wr_addr_fw1_f5_i[`CA53_FP_RF_WR_ADDR_W-1:0]),
    .rf_wr_data_fw0_f5_i  (rf_wr_data_fw0_f5[63:0]),
    .rf_wr_data_fw1_f5_i  (rf_wr_data_fw1_f5[63:0]),
    // Outputs
    .rf_rd_data_fr0_ex1_o (rf_rd_data_fr0_f1[63:0]),
    .rf_rd_data_fr1_ex1_o (rf_rd_data_fr1_f1[63:0]),
    .rf_rd_data_fr2_ex1_o (rf_rd_data_fr2_f1[63:0]),
    .rf_rd_data_fr3_ex1_o (rf_rd_data_fr3_f1[63:0]),
    .rf_rd_data_fr4_ex1_o (rf_rd_data_fr4_f1[63:0]),
    .rf_rd_data_fr5_ex1_o (rf_rd_data_fr5_f1[63:0])
  );

endmodule // ca53dpu_fp

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
