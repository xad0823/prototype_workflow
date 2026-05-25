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
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Datapath wrapper module (containing data muxes)
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// This module instantiates the main datapath modules (ALU, MAC, store), and
// contains the muxes used to select data to and from those pipelines.

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_dp `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire                             clk,
  input  wire                             reset_n,
  input  wire                             DFTSE,
  input  wire                             aarch64_state_i,
  input  wire                             issue_to_iss_i,
  input  wire                             alu0_valid_de_i,
  input  wire                             alu1_valid_de_i,
  input  wire      [`CA53_IMM_DATA_W-1:0] imm_data_0_de_i,
  input  wire      [`CA53_IMM_DATA_W-1:0] imm_data_1_de_i,
  input  wire     [`CA53_IMM_SHIFT_W-1:0] imm_shift_0_de_i,
  input  wire     [`CA53_IMM_SHIFT_W-1:0] imm_shift_1_de_i,
  input  wire       [`CA53_IMM_SEL_W-1:0] imm_data_sel_0_de_i,
  input  wire       [`CA53_IMM_SEL_W-1:0] imm_data_sel_1_de_i,
  input  wire           [`CA53_FWD_W-1:0] r0_fwd_iss_i,
  input  wire           [`CA53_FWD_W-1:0] r1_fwd_iss_i,
  input  wire           [`CA53_FWD_W-1:0] r2_fwd_iss_i,
  input  wire           [`CA53_FWD_W-1:0] r3_fwd_iss_i,
  input  wire           [`CA53_FWD_W-1:0] r4_fwd_iss_i,
  input  wire           [`CA53_FWD_W-1:0] alu0_a_fwd_ex1_i,
  input  wire           [`CA53_FWD_W-1:0] alu0_b_fwd_ex1_i,
  input  wire           [`CA53_FWD_W-1:0] str0_a_fwd_ex1_i,
  input  wire           [`CA53_FWD_W-1:0] str0_b_fwd_ex1_i,
  input  wire           [`CA53_FWD_W-1:0] str1_a_fwd_ex1_i,
  input  wire           [`CA53_FWD_W-1:0] str1_b_fwd_ex1_i,
  input  wire           [`CA53_FWD_W-1:0] alu1_a_fwd_ex1_i,
  input  wire           [`CA53_FWD_W-1:0] alu1_b_fwd_ex1_i,
  input  wire           [`CA53_FWD_W-1:0] str0_a_fwd_ex2_i,
  input  wire           [`CA53_FWD_W-1:0] str0_b_fwd_ex2_i,
  input  wire           [`CA53_FWD_W-1:0] str1_a_fwd_ex2_i,
  input  wire           [`CA53_FWD_W-1:0] str1_b_fwd_ex2_i,
  input  wire                       [5:0] mac_fwd_ctl_ex1_i,
  input  wire                      [63:0] rf_rd_data_r0_iss_i,
  input  wire                      [63:0] rf_rd_data_r1_iss_i,
  input  wire                      [63:0] rf_rd_data_r2_iss_i,
  input  wire                      [63:0] rf_rd_data_r3_iss_i,
  input  wire                      [63:0] rf_rd_data_r4_iss_i,
  input  wire  [`CA53_RF_WR_SRC_W0_W-1:0] rf_wr_src_w0_wr_i,
  input  wire  [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_wr_i,
  input  wire  [`CA53_RF_WR_SRC_W2_W-1:0] rf_wr_src_w2_wr_i,
  input  wire                             rf_wr_64b_w0_wr_i,
  input  wire                             rf_wr_64b_w1_wr_i,
  input  wire                             rf_wr_64b_w2_wr_i,
  input  wire                      [63:0] pc_instr0_iss_i,
  input  wire                      [48:1] pc_instr1_iss_i,
  input  wire                             wd_align_pc_alu0_iss_i,
  input  wire                             wd_align_pc_alu1_iss_i,
  input  wire                             str0_valid_de_i,
  input  wire                             raw_str0_valid_iss_i,
  input  wire                             str0_a_valid_iss_i,
  input  wire                             str0_b_valid_iss_i,
  input  wire                             str1_valid_de_i,
  input  wire                             raw_str1_valid_iss_i,
  input  wire                             str1_a_valid_iss_i,
  input  wire                             str1_b_valid_iss_i,
  input  wire     [`CA53_SEL_STR_A_W-1:0] str0_data_a_sel_iss_i,
  input  wire     [`CA53_SEL_STR_B_W-1:0] str0_data_b_sel_iss_i,
  input  wire     [`CA53_SEL_STR_A_W-1:0] str1_data_a_sel_iss_i,
  input  wire     [`CA53_SEL_STR_B_W-1:0] str1_data_b_sel_iss_i,
  input  wire                      [63:0] mrc_data_wr_i,
  input  wire                      [63:0] ld_data0_wr_i,
  input  wire                      [63:0] ld_data1_wr_i,
  input  wire                             use_ex1_alu_0_iss_i,
  input  wire                             use_ex1_alu_1_iss_i,
  input  wire                             raw_alu0_valid_iss_i,
  input  wire                             raw_alu1_valid_iss_i,
  input  wire                             alu0_valid_iss_i,
  input  wire                             alu1_valid_iss_i,
  input  wire                             mac_valid_de_i,
  input  wire                             raw_mac_valid_iss_i,
  input  wire                             mac_valid_iss_i,
  input  wire                             div_valid_iss_i,
  input  wire                             div_valid_de_i,
  input  wire                             raw_div_valid_iss_i,
  input  wire                             save_base_ex2_i,
  input  wire                       [3:0] cond_code_instr0_ex2_i,
  input  wire                       [3:0] cond_code_instr1_ex2_i,
  input  wire                             div_flush_i,
  input  wire                             flush_wr_i,
  input  wire                             flush_ret_i,
  input  wire                             advance_pipeline_i,
  input  wire                             quash_iss_i,
  input  wire                             quash_ex1_i,
  input  wire                             stall_ex1_i,
  input  wire                             stall_ex2_i,
  input  wire                             stall_wr_i,
  input  wire                             pre_valid_instrs_wr_i,
  input  wire                      [31:0] cpsr_masked_ret_i,
  input  wire                      [31:0] cpsr_ret_i,
  input  wire                             sel_mac_nzflags_wr_i,
  input  wire                             srs_wr_i,
  input  wire                      [31:0] spsr_ret_i,
  input  wire                             ldc_stc_wr_i,
  input  wire                             slot1_mul_iss_i,
  input  wire                             slot1_ls_ex2_i,
  input  wire                             w0_slot1_wr_i,
  input  wire                             spec_endianness_ex2_i,
  input  wire                       [1:0] ls_elem_size_ex2_i,
  input  wire                       [1:0] ls_elem_size_wr_i,
  input  wire                             ls_valid_ex2_i,
  input  wire                             ls_store_ex2_i,
  input  wire                             ls_store_neon_ex2_i,
  input  wire                             instr_is_cp10_cp11_wr_i,
  input  wire  [`CA53_NEON_VLD_CTL_W-1:0] neon_vld_ctl_f2_i,
  input  wire  [`CA53_NEON_VLD_CTL_W-1:0] neon_vld_ctl_f3_i,
  input  wire                             first_x64_wr_i,
  input  wire                       [3:0] v_addr_ex2_i,
  input  wire                             cp_valid_ex2_i,
  input  wire                      [31:0] dbg_dtrrx_data_i,
  input  wire                             dcu_strex_okay_dc3_i,
  input  wire                             cpsr_flag_update_cp_dscr_wr_i,
  input  wire                       [3:0] cpsr_flag_update_nzcv_i,
  input  wire                       [1:0] instr_fmstat_ex2_i,
  input  wire                       [3:0] fp_fwd_cflags_ex2_i,
  input  wire                       [3:0] fp_cflags_add0_f2_i,
  input  wire                       [3:0] fp_cflags_add1_f2_i,
  input  wire                             ctl_64bit_op_alu0_iss_i,
  input  wire                             ctl_64bit_op_alu1_iss_i,
  input  wire                             ctl_64bit_op_mac_iss_i,
  input  wire                             ctl_64bit_op_str0_iss_i,
  input  wire                             ctl_64bit_op_str1_iss_i,
  input  wire   [`CA53_MAC_ISS_CTL_W-1:0] mac_iss_ctl_iss_i,
  input  wire                             alu0_msk_data_sel_iss_i,
  input  wire                             alu1_msk_data_sel_iss_i,
  input  wire     [`CA53_SEL_SHF_A_W-1:0] alu0_data_a_sel_iss_i,
  input  wire     [`CA53_SEL_SHF_B_W-1:0] alu0_data_b_sel_iss_i,
  input  wire     [`CA53_SEL_SHF_C_W-1:0] alu0_data_c_sel_iss_i,
  input  wire     [`CA53_SEL_SHF_A_W-1:0] alu1_data_a_sel_iss_i,
  input  wire     [`CA53_SEL_SHF_B_W-1:0] alu1_data_b_sel_iss_i,
  input  wire     [`CA53_SEL_SHF_C_W-1:0] alu1_data_c_sel_iss_i,
  input  wire   [`CA53_ALU_EX1_CTL_W-1:0] alu0_ex1_ctl_iss_i,
  input  wire   [`CA53_ALU_EX2_CTL_W-1:0] alu0_ex2_ctl_iss_i,
  input  wire                             alu0_wr_ctl_iss_i,
  input  wire   [`CA53_ALU_EX1_CTL_W-1:0] alu1_ex1_ctl_iss_i,
  input  wire   [`CA53_ALU_EX2_CTL_W-1:0] alu1_ex2_ctl_iss_i,
  input  wire                             alu1_wr_ctl_iss_i,
  input  wire     [`CA53_SEL_MAC_A_W-1:0] mac_data_a_sel_iss_i,
  input  wire     [`CA53_SEL_MAC_B_W-1:0] mac_data_b_sel_iss_i,
  input  wire     [`CA53_SEL_DIV_A_W-1:0] div_data_a_sel_iss_i,
  input  wire     [`CA53_SEL_DIV_B_W-1:0] div_data_b_sel_iss_i,
  input  wire                      [63:0] fp_str0_data_f1_i,
  input  wire                      [63:0] fp_str1_data_f1_i,
  input  wire                      [63:0] fp_str0_data_f2_i,
  input  wire                      [63:0] fp_str1_data_f2_i,
  input  wire                      [63:0] fp_alu0_f2i_res_f3_i,
  input  wire                      [63:0] fp_alu1_f2i_res_f3_i,
  input  wire                      [31:1] rtn_addr_iss_i,
  // Outputs
  output wire                      [20:0] raw_imm_data_0_iss_o,
  output wire                      [20:0] raw_imm_data_1_iss_o,
  output wire                       [1:0] adrp_valid_iss_o,
  output wire                             alu0_qbit_wr_o,
  output wire                             alu1_qbit_wr_o,
  output wire                             cc_pass_instr0_ex2_o,
  output wire                             cc_pass_instr0_cbz_ex2_o,
  output wire                             cc_pass_instr1_ex2_o,
  output wire                             cc_pass_instr1_cbz_ex2_o,
  output wire                             cc_pass_instr1_early_ex2_o,
  output wire                             fp0_ccmp_fail_ex2_o,
  output wire                             fp1_ccmp_fail_ex2_o,
  output wire                             alu0_csel_pass_ex2_o,
  output wire                             mac_stall_iss_o,
  output wire                             new_mac_qflag_wr_o,
  output wire                             div_busy_iss_o,
  output wire                             nxt_div_busy_wr_o,
  output wire                     [127:0] dpu_st_data_wr_o,
  output wire                      [63:0] st0_data_ex1_o,
  output wire                      [63:0] st0_data_wr_o,
  output wire                      [63:0] st1_data_ex1_o,
  output wire                      [63:0] st1_data_wr_o,
  output wire                      [63:0] rf_wr_data_w0_wr_o,
  output wire                      [63:0] rf_wr_data_w1_wr_o,
  output wire                      [63:0] rf_wr_data_w2_wr_o,
  output wire                       [3:0] ccflags_wr_o,
  output wire                       [3:0] geflags_wr_o,
  output wire                      [63:0] alu0_fwd_data_early_ex2_o,
  output wire                      [63:0] alu1_fwd_data_early_ex2_o,
  output wire                      [63:0] alu0_fwd_data_early_wr_o,
  output wire                      [63:0] alu1_fwd_data_early_wr_o
);

  `include "ca53dpu_functions.v"

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg      [`CA53_IMM_SHIFT_W-1:0] raw_imm_shift_0_iss;
  reg      [`CA53_IMM_SHIFT_W-1:0] raw_imm_shift_1_iss;
  reg       [`CA53_IMM_DATA_W-1:0] raw_imm_data_0_iss;
  reg       [`CA53_IMM_DATA_W-1:0] raw_imm_data_1_iss;
  reg        [`CA53_IMM_SEL_W-1:0] imm_data_sel_0_iss;
  reg        [`CA53_IMM_SEL_W-1:0] imm_data_sel_1_iss;
  reg                       [63:0] imm_data_0_iss;
  reg                       [63:0] imm_data_1_iss;
  reg                        [7:0] imm_shift_0_iss;
  reg                        [7:0] imm_shift_1_iss;
  reg                              imm_sel_c_0_iss;
  reg                              imm_sel_c_1_iss;
  reg                        [5:0] rf_wr_src_w0_wr_fw;
  reg                        [4:0] rf_wr_src_w1_wr_fw;
  reg                        [4:0] rf_wr_src_w2_wr_fw;
  reg                        [1:0] rf_wr_src_w0_wr_nofw;
  reg                              rf_wr_src_w1_wr_nofw;
  reg                       [63:0] fwd_data_r0_iss;
  reg                       [63:0] fwd_data_r1_iss;
  reg                       [63:0] fwd_data_r2_iss;
  reg                       [63:0] fwd_data_r3_iss;
  reg                       [63:0] fwd_data_r4_iss;
  reg                              use_localcc_wr;
  reg                              use_localge_wr;
  reg                        [3:0] geflags_wr;
  reg                        [3:0] ccflags_wr;
  reg                       [63:0] saved_base_value;
  reg                       [63:0] alu_pc_instr0_iss;
  reg                       [63:0] alu_pc_instr1_iss;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire   [63:0] masked_pc_instr0_iss;
  wire   [63:0] masked_pc_instr1_iss;
  wire   [31:0] imm_data_ror_0_iss;
  wire   [31:0] imm_data_ror_1_iss;
  wire   [63:0] imm_data_lsl_0_iss;
  wire   [63:0] imm_data_lsl_1_iss;
  wire          alu0_iss_en;
  wire          alu1_iss_en;
  wire    [1:0] alu0_ex2_flagid;
  wire    [1:0] alu1_ex2_flagid;
  wire          alu0_au_nout_ex2;
  wire          alu1_au_nout_ex2;
  wire          alu0_sel_c_flag_ex2;
  wire          alu0_sel_v_flag_ex2;
  wire          alu1_sel_c_flag_ex2;
  wire          alu1_sel_v_flag_ex2;
  wire    [3:0] alu0_csel_cond_ex2;
  wire    [3:0] alu1_csel_cond_ex2;
  wire          alu0_ex2_cbz_bypass_zflag;
  wire          alu0_ex2_cbz_pass;
  wire          alu1_ex2_cbz_bypass_zflag;
  wire          alu1_ex2_cbz_pass;
  wire          alu0_geflag_set_ex2;
  wire          alu1_geflag_set_ex2;
  wire          nxt_use_localcc_wr;
  wire          nxt_use_localge_wr;
  wire    [3:0] new_alu0_ccflags_nclear_ex2;
  wire    [3:0] new_alu0_ccflags_nset_ex2;
  wire    [3:0] new_alu1_ccflags_nclear_ex2;
  wire    [3:0] new_alu1_ccflags_nset_ex2;
  wire    [3:0] new_alu0_ccflags_ccmp_ex2;
  wire    [3:0] new_alu1_ccflags_ccmp_ex2;
  wire          alu0_sel_ccmp_flags_ex2;
  wire          alu1_sel_ccmp_flags_ex2;
  wire          alu0_valid_ex2;
  wire          alu1_valid_ex2;
  wire          cc_pass_instr0_ex2;
  wire          cc_pass_instr1_ex2;
  wire   [63:0] rf_wr_data_w0_wr;
  wire   [63:0] rf_wr_data_w1_wr;
  wire   [63:0] rf_wr_data_w2_wr;
  wire   [63:0] alu0_fwd_data_ex1;
  wire   [63:0] alu1_fwd_data_ex1;
  wire   [63:0] alu0_fwd_data_ex2;
  wire   [63:0] alu1_fwd_data_ex2;
  wire   [63:0] alu0_data_a_ex2;
  wire   [63:0] div_opa_iss;
  wire   [63:0] div_opb_iss;
  wire   [63:0] div_res_wr;
  wire   [63:0] mac_opa_iss;
  wire   [63:0] mac_opb_iss;
  wire   [31:0] mac_res_lo_wr;
  wire   [31:0] mac_res_hi_wr;
  wire          mac_q_wr;
  wire          mac_n_wr;
  wire          mac_z_wr;
  wire    [1:0] new_mac_nzflags_wr;
  wire   [63:0] alu0_data_wr;
  wire   [63:0] alu1_data_wr;
  wire   [63:0] st0_data_ex2;
  wire   [63:0] st0_data_wr;
  wire   [31:0] st0_data_a_iss;
  wire   [31:0] st0_data_b_iss;
  wire   [63:0] st1_data_ex2;
  wire   [63:0] st1_data_wr;
  wire   [31:0] st1_data_a_iss;
  wire   [31:0] st1_data_b_iss;
  wire   [63:0] log_imm_0;
  wire   [63:0] log_imm_1;
  wire   [63:0] alu0_data_a_iss;
  wire   [63:0] alu0_data_b_iss;
  wire    [7:0] alu0_data_c_iss;
  wire   [63:0] alu1_data_a_iss;
  wire   [63:0] alu1_data_b_iss;
  wire    [7:0] alu1_data_c_iss;
  wire    [5:0] alu0_mskgen_iss;
  wire    [5:0] alu1_mskgen_iss;
  wire  [127:0] store_data_wr;
  wire    [3:0] new_alu0_geflags_ex2;
  wire    [3:0] new_alu1_geflags_ex2;
  wire    [3:0] alu1_fwd_ccflags_nset_ex2;
  wire    [3:0] alu1_fwd_ccflags_nclear_ex2;
  wire    [3:0] ccflags_ex2;
  wire    [3:0] geflags_ex2;
  wire          alu0_ccflag_set_ex2;
  wire          alu1_ccflag_set_ex2;
  wire          fmstat_ccflag_set_ex2;
  wire    [3:0] new_alu0_ccflags_ex2;
  wire    [3:0] new_alu1_ccflags_ex2;
  wire    [3:0] new_alu0_ccflags_ccmp_nset_ex2;
  wire    [3:0] new_alu0_ccflags_ccmp_nclear_ex2;
  wire    [3:0] new_alu1_ccflags_ccmp_n0set_n1set_ex2;
  wire    [3:0] new_alu1_ccflags_ccmp_n0set_n1clear_ex2;
  wire    [3:0] new_alu1_ccflags_ccmp_n0clear_n1set_ex2;
  wire    [3:0] new_alu1_ccflags_ccmp_n0clear_n1clear_ex2;
  wire    [3:0] instr1_flags_nclear_ex2;
  wire    [3:0] instr1_flags_nset_ex2;
  wire          alu0_csel_pass_ex2;
  wire          alu1_csel_pass_early_ex2;
  wire          alu1_csel_pass_n0set_ex2;
  wire          alu1_csel_pass_n0clear_ex2;
  wire          alu1_csel_pass_ex2;
  wire          fp0_ccflag_set_ex2;
  wire          fp1_ccflag_set_ex2;
  wire    [3:0] new_fp0_ccflags_ex2;
  wire    [3:0] new_fp1_ccflags_ex2;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Issue stage forwarding muxes
  // ------------------------------------------------------

  // We have four read ports R0, R1, R2 and R3 and therefore four forwarding
  // arrays to match.  These arrays can forward data from write ports W0/W1/W2
  // or the ALU.

  always @*
    case (r0_fwd_iss_i)
      `CA53_FWD_W0       : fwd_data_r0_iss = rf_wr_data_w0_wr[63:0];
      `CA53_FWD_W1       : fwd_data_r0_iss = rf_wr_data_w1_wr[63:0];
      `CA53_FWD_W2       : fwd_data_r0_iss = rf_wr_data_w2_wr[63:0];
      `CA53_FWD_ALU0_EX2 : fwd_data_r0_iss = alu0_fwd_data_ex2[63:0];
      `CA53_FWD_ALU1_EX2 : fwd_data_r0_iss = alu1_fwd_data_ex2[63:0];
      `CA53_FWD_ALU0_EX1 : fwd_data_r0_iss = alu0_fwd_data_ex1[63:0];
      `CA53_FWD_ALU1_EX1 : fwd_data_r0_iss = alu1_fwd_data_ex1[63:0];
      `CA53_FWD_NULL     : fwd_data_r0_iss = rf_rd_data_r0_iss_i;
      // Illegal values see ovl_fwd_r0_ill in ca53dpu_ctl
      default            : fwd_data_r0_iss = 64'hxxxx_xxxx_xxxx_xxxx;
    endcase

  always @*
    case (r1_fwd_iss_i)
      `CA53_FWD_W0       : fwd_data_r1_iss = rf_wr_data_w0_wr[63:0];
      `CA53_FWD_W1       : fwd_data_r1_iss = rf_wr_data_w1_wr[63:0];
      `CA53_FWD_W2       : fwd_data_r1_iss = rf_wr_data_w2_wr[63:0];
      `CA53_FWD_ALU0_EX2 : fwd_data_r1_iss = alu0_fwd_data_ex2[63:0];
      `CA53_FWD_ALU1_EX2 : fwd_data_r1_iss = alu1_fwd_data_ex2[63:0];
      `CA53_FWD_ALU0_EX1 : fwd_data_r1_iss = alu0_fwd_data_ex1[63:0];
      `CA53_FWD_ALU1_EX1 : fwd_data_r1_iss = alu1_fwd_data_ex1[63:0];
      `CA53_FWD_NULL     : fwd_data_r1_iss = rf_rd_data_r1_iss_i;
      // Illegal values see ovl_fwd_r1_ill in ca53dpu_ctl
      default            : fwd_data_r1_iss = 64'hxxxx_xxxx_xxxx_xxxx;
    endcase

  always @*
    case (r2_fwd_iss_i)
      `CA53_FWD_W0       : fwd_data_r2_iss = rf_wr_data_w0_wr[63:0];
      `CA53_FWD_W1       : fwd_data_r2_iss = rf_wr_data_w1_wr[63:0];
      `CA53_FWD_W2       : fwd_data_r2_iss = rf_wr_data_w2_wr[63:0];
      `CA53_FWD_ALU0_EX2 : fwd_data_r2_iss = alu0_fwd_data_ex2[63:0];
      `CA53_FWD_ALU1_EX2 : fwd_data_r2_iss = alu1_fwd_data_ex2[63:0];
      `CA53_FWD_ALU0_EX1 : fwd_data_r2_iss = alu0_fwd_data_ex1[63:0];
      `CA53_FWD_ALU1_EX1 : fwd_data_r2_iss = alu1_fwd_data_ex1[63:0];
      `CA53_FWD_NULL     : fwd_data_r2_iss = rf_rd_data_r2_iss_i;
      // Illegal values see ovl_fwd_r2_ill in ca53dpu_ctl
      default            : fwd_data_r2_iss = 64'hxxxx_xxxx_xxxx_xxxx;
    endcase

  always @*
    case (r3_fwd_iss_i)
      `CA53_FWD_W0       : fwd_data_r3_iss = rf_wr_data_w0_wr[63:0];
      `CA53_FWD_W1       : fwd_data_r3_iss = rf_wr_data_w1_wr[63:0];
      `CA53_FWD_W2       : fwd_data_r3_iss = rf_wr_data_w2_wr[63:0];
      `CA53_FWD_ALU0_EX2 : fwd_data_r3_iss = alu0_fwd_data_ex2[63:0];
      `CA53_FWD_ALU1_EX2 : fwd_data_r3_iss = alu1_fwd_data_ex2[63:0];
      `CA53_FWD_ALU0_EX1 : fwd_data_r3_iss = alu0_fwd_data_ex1[63:0];
      `CA53_FWD_ALU1_EX1 : fwd_data_r3_iss = alu1_fwd_data_ex1[63:0];
      `CA53_FWD_NULL     : fwd_data_r3_iss = rf_rd_data_r3_iss_i;
      // Illegal values see ovl_fwd_r3_ill in ca53dpu_ctl
      default            : fwd_data_r3_iss = 64'hxxxx_xxxx_xxxx_xxxx;
    endcase

  always @*
    case (r4_fwd_iss_i)
      `CA53_FWD_W0       : fwd_data_r4_iss = rf_wr_data_w0_wr[63:0];
      `CA53_FWD_W1       : fwd_data_r4_iss = rf_wr_data_w1_wr[63:0];
      `CA53_FWD_W2       : fwd_data_r4_iss = rf_wr_data_w2_wr[63:0];
      `CA53_FWD_ALU0_EX2 : fwd_data_r4_iss = alu0_fwd_data_ex2[63:0];
      `CA53_FWD_ALU1_EX2 : fwd_data_r4_iss = alu1_fwd_data_ex2[63:0];
      `CA53_FWD_ALU0_EX1 : fwd_data_r4_iss = alu0_fwd_data_ex1[63:0];
      `CA53_FWD_ALU1_EX1 : fwd_data_r4_iss = alu1_fwd_data_ex1[63:0];
      `CA53_FWD_NULL     : fwd_data_r4_iss = rf_rd_data_r4_iss_i;
      // Illegal values see ovl_fwd_r4_ill in ca53dpu_ctl
      default            : fwd_data_r4_iss = 64'hxxxx_xxxx_xxxx_xxxx;
    endcase

  // ------------------------------------------------------
  // Logical Immediate generation
  // ------------------------------------------------------

  // Register encoded immediate data from De to Iss, which is then expanded in Iss
  assign alu0_iss_en = issue_to_iss_i & alu0_valid_de_i;
  assign alu1_iss_en = issue_to_iss_i & alu1_valid_de_i;

  always @(posedge clk)
    if (issue_to_iss_i) begin // Always enable as also used on FPU ops
      raw_imm_data_0_iss[12:0] <= imm_data_0_de_i[12:0];
      raw_imm_data_1_iss[12:0] <= imm_data_1_de_i[12:0];
    end

  assign raw_imm_data_0_iss_o = raw_imm_data_0_iss[20:0];
  assign raw_imm_data_1_iss_o = raw_imm_data_1_iss[20:0];

  always @(posedge clk)
    if (alu0_iss_en) begin
      raw_imm_data_0_iss[`CA53_IMM_DATA_W-1:13] <= imm_data_0_de_i[`CA53_IMM_DATA_W-1:13];
      raw_imm_shift_0_iss                       <= imm_shift_0_de_i;
      imm_data_sel_0_iss                        <= imm_data_sel_0_de_i;
    end

  always @(posedge clk)
    if (alu1_iss_en) begin
      raw_imm_data_1_iss[`CA53_IMM_DATA_W-1:13] <= imm_data_1_de_i[`CA53_IMM_DATA_W-1:13];
      raw_imm_shift_1_iss                       <= imm_shift_1_de_i;
      imm_data_sel_1_iss                        <= imm_data_sel_1_de_i;
    end

  // Generate A64 logical immediates
  ca53dpu_alu_mask_imm u_alu_mask_imm0 (
    // Inputs
    .n_i              (raw_imm_data_0_iss[6]),
    .imms_i           (raw_imm_data_0_iss[5:0]),
    .immr_i           (raw_imm_shift_0_iss[5:0]),
    // Outputs
    .log_imm_o        (log_imm_0[63:0])
  );

  ca53dpu_alu_mask_imm u_alu_mask_imm1 (
    // Inputs
    .n_i              (raw_imm_data_1_iss[6]),
    .imms_i           (raw_imm_data_1_iss[5:0]),
    .immr_i           (raw_imm_shift_1_iss[5:0]),
    // Outputs
    .log_imm_o        (log_imm_1[63:0])
  );

  // Generate A32/T32 rotated immediates
  function [31:0] imm_ror;
    // Create a 32-bit value by rotating right an 8-bit value by 0-31
    // - note that rotating around bit 0/1 by odd numbers is not possible, as only
    // thumb instructions can do odd rotates, and these can only shift and not
    // rotate.
    input [7:0] value;
    input [4:0] shift;

    case (shift)
      5'b00000: imm_ror = { {24{1'b0}}, value[7:0] };
      5'b00010: imm_ror = { value[1:0], {24{1'b0}}, value[7:2] };
      5'b00100: imm_ror = { value[3:0], {24{1'b0}}, value[7:4] };
      5'b00110: imm_ror = { value[5:0], {24{1'b0}}, value[7:6] };
      5'b01000: imm_ror = { value[7:0], {24{1'b0}} };
      5'b01001: imm_ror = {     1'b0  , value[7:0], {23{1'b0}} };
      5'b01010: imm_ror = { { 2{1'b0}}, value[7:0], {22{1'b0}} };
      5'b01011: imm_ror = { { 3{1'b0}}, value[7:0], {21{1'b0}} };
      5'b01100: imm_ror = { { 4{1'b0}}, value[7:0], {20{1'b0}} };
      5'b01101: imm_ror = { { 5{1'b0}}, value[7:0], {19{1'b0}} };
      5'b01110: imm_ror = { { 6{1'b0}}, value[7:0], {18{1'b0}} };
      5'b01111: imm_ror = { { 7{1'b0}}, value[7:0], {17{1'b0}} };
      5'b10000: imm_ror = { { 8{1'b0}}, value[7:0], {16{1'b0}} };
      5'b10001: imm_ror = { { 9{1'b0}}, value[7:0], {15{1'b0}} };
      5'b10010: imm_ror = { {10{1'b0}}, value[7:0], {14{1'b0}} };
      5'b10011: imm_ror = { {11{1'b0}}, value[7:0], {13{1'b0}} };
      5'b10100: imm_ror = { {12{1'b0}}, value[7:0], {12{1'b0}} };
      5'b10101: imm_ror = { {13{1'b0}}, value[7:0], {11{1'b0}} };
      5'b10110: imm_ror = { {14{1'b0}}, value[7:0], {10{1'b0}} };
      5'b10111: imm_ror = { {15{1'b0}}, value[7:0], { 9{1'b0}} };
      5'b11000: imm_ror = { {16{1'b0}}, value[7:0], { 8{1'b0}} };
      5'b11001: imm_ror = { {17{1'b0}}, value[7:0], { 7{1'b0}} };
      5'b11010: imm_ror = { {18{1'b0}}, value[7:0], { 6{1'b0}} };
      5'b11011: imm_ror = { {19{1'b0}}, value[7:0], { 5{1'b0}} };
      5'b11100: imm_ror = { {20{1'b0}}, value[7:0], { 4{1'b0}} };
      5'b11101: imm_ror = { {21{1'b0}}, value[7:0], { 3{1'b0}} };
      5'b11110: imm_ror = { {22{1'b0}}, value[7:0], { 2{1'b0}} };
      5'b11111: imm_ror = { {23{1'b0}}, value[7:0],     1'b0   };
      default : imm_ror = {32{1'bx}};
    endcase
  endfunction

  assign imm_data_ror_0_iss = imm_ror(raw_imm_data_0_iss[7:0], raw_imm_shift_0_iss[4:0]);
  assign imm_data_ror_1_iss = imm_ror(raw_imm_data_1_iss[7:0], raw_imm_shift_1_iss[4:0]);

  function [63:0] imm_lsl;
    // Create a 64-bit value by shifting left up to 21-bits of immediate
    input [20:0] value;
    input  [5:0] shift;

    case (shift)
      `CA53_IMM_LSL_0   : imm_lsl = { {43{1'b0}}, value[20:0] };
      `CA53_IMM_LSL_12,
      `CA53_IMM_LSL_ADRP: imm_lsl = { {31{value[20]}}, value[20:0], {12{1'b0}} };  // LSL by 12 with sign extension
      // Can only use 16-bit immediate with shift of 16/32/48
      `CA53_IMM_LSL_16  : imm_lsl = { {32{1'b0}}, value[15:0], {16{1'b0}} };
      `CA53_IMM_LSL_32  : imm_lsl = { {16{1'b0}}, value[15:0], {32{1'b0}} };
      `CA53_IMM_LSL_48  : imm_lsl = {             value[15:0], {48{1'b0}} };
      default           : imm_lsl = {64{1'bx}};
    endcase
  endfunction

  assign imm_data_lsl_0_iss = imm_lsl(raw_imm_data_0_iss[20:0], raw_imm_shift_0_iss[5:0]);
  assign imm_data_lsl_1_iss = imm_lsl(raw_imm_data_1_iss[20:0], raw_imm_shift_1_iss[5:0]);

  // Word align PC as required (applies to all instructions)
  assign masked_pc_instr0_iss  = { pc_instr0_iss_i[63:2], {2{~wd_align_pc_alu0_iss_i}} & pc_instr0_iss_i[1:0]};
  // - and sign extend for instr1
  assign masked_pc_instr1_iss  = { {15{pc_instr1_iss_i[48]}}, pc_instr1_iss_i[48:2], (~wd_align_pc_alu1_iss_i & pc_instr1_iss_i[1]), 1'b0};

  // Select/expand immediate
  // - Slot 0
  always @* begin
    imm_data_0_iss        = {64{1'b0}};
    imm_shift_0_iss       = raw_imm_shift_0_iss;
    imm_sel_c_0_iss       = 1'b0;
    alu_pc_instr0_iss     = masked_pc_instr0_iss;

    case (imm_data_sel_0_iss)
      `CA53_IMM_SEL_NULL : imm_data_0_iss[63:0] = {{(64-(`CA53_IMM_DATA_W-1)){raw_imm_data_0_iss[`CA53_IMM_DATA_W-1]}},
                                                   raw_imm_data_0_iss[`CA53_IMM_DATA_W-2:0]};
      `CA53_IMM_SEL_T32_1: imm_data_0_iss[31:0] = {2{ {8{1'b0}},raw_imm_data_0_iss[7:0] }};
      `CA53_IMM_SEL_T32_2: imm_data_0_iss[31:0] = {2{ raw_imm_data_0_iss[7:0],{8{1'b0}} }};
      `CA53_IMM_SEL_T32_3: imm_data_0_iss[31:0] = {raw_imm_data_0_iss[7:0],
                                                   raw_imm_data_0_iss[7:0],
                                                   raw_imm_data_0_iss[7:0],
                                                   raw_imm_data_0_iss[7:0]};
      // For a table branch instruction, the data from the rtn packet is provided as an immediate
      // - only possible for slot0, as table branch is not D1
      `CA53_IMM_SEL_TBB  : imm_data_0_iss[31:0]  = {rtn_addr_iss_i[31:1], 1'b0};
      `CA53_IMM_SEL_A64_LOG_IMM: begin
        imm_data_0_iss[63:0]  = log_imm_0;
      end
      `CA53_IMM_SEL_ROR: begin
        imm_data_0_iss[31:0]  = imm_data_ror_0_iss;
        imm_sel_c_0_iss       = (raw_imm_shift_0_iss[4:0] != 5'b00000);
      end
      `CA53_IMM_SEL_LSL: begin
        imm_data_0_iss[63:0]  = imm_data_lsl_0_iss;

        case (raw_imm_shift_0_iss[5:0])
          `CA53_IMM_LSL_0,
          `CA53_IMM_LSL_16,
          `CA53_IMM_LSL_32,
          `CA53_IMM_LSL_48,
          `CA53_IMM_LSL_12  : begin
            // Do nothing
          end
          `CA53_IMM_LSL_ADRP: alu_pc_instr0_iss[11:0] = {12{1'b0}}; // Additional masking on PC for ADRP
          default           : alu_pc_instr0_iss[11:0] = {12{1'bx}};
        endcase
      end
      default: begin
        imm_data_0_iss     = {64{1'bx}};
        imm_shift_0_iss    = { 8{1'bx}};
        imm_sel_c_0_iss    = 1'bx;
        alu_pc_instr0_iss  = {64{1'bx}};
      end
    endcase
  end

  // - Slot 1
  always @* begin
    imm_data_1_iss        = {64{1'b0}};
    imm_shift_1_iss       = raw_imm_shift_1_iss;
    imm_sel_c_1_iss       = 1'b0;
    alu_pc_instr1_iss     = masked_pc_instr1_iss;

    case (imm_data_sel_1_iss)
      `CA53_IMM_SEL_NULL : imm_data_1_iss[63:0] = {{(64-(`CA53_IMM_DATA_W-1)){raw_imm_data_1_iss[`CA53_IMM_DATA_W-1]}},
                                                   raw_imm_data_1_iss[`CA53_IMM_DATA_W-2:0]};
      `CA53_IMM_SEL_T32_1: imm_data_1_iss[31:0] = {2{ {8{1'b0}},raw_imm_data_1_iss[7:0] }};
      `CA53_IMM_SEL_T32_2: imm_data_1_iss[31:0] = {2{ raw_imm_data_1_iss[7:0],{8{1'b0}} }};
      `CA53_IMM_SEL_T32_3: imm_data_1_iss[31:0] = {raw_imm_data_1_iss[7:0],
                                                   raw_imm_data_1_iss[7:0],
                                                   raw_imm_data_1_iss[7:0],
                                                   raw_imm_data_1_iss[7:0]};
      `CA53_IMM_SEL_A64_LOG_IMM: begin
        imm_data_1_iss[63:0]  = log_imm_1;
      end
      `CA53_IMM_SEL_ROR: begin
        imm_data_1_iss[31:0]  = imm_data_ror_1_iss;
        imm_sel_c_1_iss       = (raw_imm_shift_1_iss[4:0] != 5'b00000);
      end
      `CA53_IMM_SEL_LSL: begin
        imm_data_1_iss[63:0]  = imm_data_lsl_1_iss;

        case (raw_imm_shift_1_iss[5:0])
          `CA53_IMM_LSL_0,
          `CA53_IMM_LSL_16,
          `CA53_IMM_LSL_32,
          `CA53_IMM_LSL_48,
          `CA53_IMM_LSL_12  : begin
            // Do nothing
          end
          `CA53_IMM_LSL_ADRP: alu_pc_instr1_iss[11:0] = {12{1'b0}}; // Additional masking on PC for ADRP
          default           : alu_pc_instr1_iss[11:0] = {12{1'bx}};
        endcase
      end
      default: begin
        imm_data_1_iss     = {64{1'bx}};
        imm_shift_1_iss    = { 8{1'bx}};
        imm_sel_c_1_iss    = 1'bx;
        alu_pc_instr1_iss  = {64{1'bx}};
      end
    endcase
  end

  // Identify if ADRP instructions are in Iss for ADRP forwarding
  assign adrp_valid_iss_o[0] = raw_alu0_valid_iss_i & (imm_data_sel_0_iss == `CA53_IMM_SEL_LSL) & (raw_imm_shift_0_iss[5:0] == `CA53_IMM_LSL_ADRP);
  assign adrp_valid_iss_o[1] = raw_alu1_valid_iss_i & (imm_data_sel_1_iss == `CA53_IMM_SEL_LSL) & (raw_imm_shift_1_iss[5:0] == `CA53_IMM_LSL_ADRP);

  // ------------------------------------------------------
  // Issue stage data selection muxes
  // ------------------------------------------------------

  // The data selection muxes can connect the correct read port forwarding muxes
  // to the correct pipe or select immediate/PC values appropriately.
  // - ALU normally takes R0-1 on to ports A and B respectively, but this
  // switches to R3-4 when remapping (dealt with in De).
  assign alu0_data_a_iss[63:0]  = ({64{alu0_data_a_sel_iss_i   == `CA53_SEL_SHF_A_R0}}         & fwd_data_r0_iss)       |
                                  ({64{alu0_data_a_sel_iss_i   == `CA53_SEL_SHF_A_R3}}         & fwd_data_r3_iss)       |
                                  ({64{alu0_data_a_sel_iss_i   == `CA53_SEL_SHF_A_PC}}         & alu_pc_instr0_iss);

  assign alu0_data_b_iss[63:0]  = ({64{alu0_data_b_sel_iss_i   == `CA53_SEL_SHF_B_R1}}         & fwd_data_r1_iss)       |
                                  ({64{alu0_data_b_sel_iss_i   == `CA53_SEL_SHF_B_R4}}         & fwd_data_r4_iss)       |
                                  ({64{alu0_data_b_sel_iss_i   == `CA53_SEL_SHF_B_PC}}         & alu_pc_instr0_iss)  |
                                  ({64{alu0_data_b_sel_iss_i   == `CA53_SEL_SHF_B_IMM_DATA}}   & imm_data_0_iss);

  assign alu0_data_c_iss[7:0]   = ({ 8{alu0_data_c_sel_iss_i   == `CA53_SEL_SHF_C_R2}}         & fwd_data_r2_iss[7:0])  |
                                  ({ 8{alu0_data_c_sel_iss_i   == `CA53_SEL_SHF_C_IMM_SHIFT}}  & imm_shift_0_iss[7:0]);

  assign alu0_mskgen_iss[5:0]   = ({ 6{alu0_msk_data_sel_iss_i == `CA53_SEL_MSK_B_IMM_DATA}}   & raw_imm_data_0_iss[5:0]);

  // ALU1 instructions R0-1 map to R3-4 on regbank and ports A-B on ALU1
  // respectively, unless remapping in which case regbank R0-1 are used.
  assign alu1_data_a_iss[63:0]  = ({64{alu1_data_a_sel_iss_i == `CA53_SEL_SHF_A_R0}}           & fwd_data_r3_iss)       | // Asks for R0             => Use R3
                                  ({64{alu1_data_a_sel_iss_i == `CA53_SEL_SHF_A_R3}}           & fwd_data_r0_iss)       | // Asks for R3 (remmaping) => Use R0
                                  ({64{alu1_data_a_sel_iss_i == `CA53_SEL_SHF_A_PC}}           & alu_pc_instr1_iss);

  assign alu1_data_b_iss[63:0]  = ({64{alu1_data_b_sel_iss_i == `CA53_SEL_SHF_B_R1}}           & fwd_data_r4_iss)       | // Asks for R1             => Use R4
                                  ({64{alu1_data_b_sel_iss_i == `CA53_SEL_SHF_B_R4}}           & fwd_data_r1_iss)       | // Asks for R4 (remmaping) => Use R1
                                  ({64{alu1_data_b_sel_iss_i == `CA53_SEL_SHF_B_PC}}           & alu_pc_instr1_iss)  |
                                  ({64{alu1_data_b_sel_iss_i == `CA53_SEL_SHF_B_IMM_DATA}}     & imm_data_1_iss);

  assign alu1_data_c_iss[7:0]   = ({ 8{alu1_data_c_sel_iss_i   == `CA53_SEL_SHF_C_R2}}         & fwd_data_r2_iss[7:0])  |
                                  ({ 8{alu1_data_c_sel_iss_i   == `CA53_SEL_SHF_C_IMM_SHIFT}}  & imm_shift_1_iss[7:0]);

  assign alu1_mskgen_iss[5:0]   = ({ 6{alu1_msk_data_sel_iss_i == `CA53_SEL_MSK_B_IMM_DATA}}   & raw_imm_data_1_iss[5:0]);


  assign mac_opa_iss            = ({64{mac_data_a_sel_iss_i  == `CA53_SEL_MAC_A_R0}}           & fwd_data_r0_iss)  |
                                  ({64{mac_data_a_sel_iss_i  == `CA53_SEL_MAC_A_R3}}           & fwd_data_r3_iss);

  assign mac_opb_iss            = ({64{mac_data_b_sel_iss_i  == `CA53_SEL_MAC_B_R1}}           & fwd_data_r1_iss)  |
                                  ({64{mac_data_b_sel_iss_i  == `CA53_SEL_MAC_B_R4}}           & fwd_data_r4_iss);

  assign div_opa_iss            = ({64{div_data_a_sel_iss_i  == `CA53_SEL_DIV_A_R0}}           & fwd_data_r0_iss) |
                                  ({64{div_data_a_sel_iss_i  == `CA53_SEL_DIV_A_R3}}           & fwd_data_r3_iss);  // Remapping (calculated in De)

  assign div_opb_iss            = ({64{div_data_b_sel_iss_i  == `CA53_SEL_DIV_B_R1}}           & fwd_data_r1_iss) |
                                  ({64{div_data_b_sel_iss_i  == `CA53_SEL_DIV_B_R4}}           & fwd_data_r4_iss);  // Remapping (calculated in De)

  // Slot0 instructions R2-3 map to R2-3 on regbank and ports A-B on STR0
  // respectively. (Note remapping dealt with in De).
  assign st0_data_a_iss[31:0]   = ({32{str0_data_a_sel_iss_i == `CA53_SEL_STR_A_R1}}           & fwd_data_r1_iss[31:0])       |
                                  ({32{str0_data_a_sel_iss_i == `CA53_SEL_STR_A_R2}}           & fwd_data_r2_iss[31:0])       |
                                  ({32{str0_data_a_sel_iss_i == `CA53_SEL_STR_A_R4}}           & fwd_data_r4_iss[31:0])       |
                                  ({32{str0_data_a_sel_iss_i == `CA53_SEL_STR_A_PC}}           & masked_pc_instr0_iss[31:0]);

  assign st0_data_b_iss[31:0]   = ({32{(str0_data_b_sel_iss_i == `CA53_SEL_STR_B_A_H) &
                                       (str0_data_a_sel_iss_i == `CA53_SEL_STR_A_R1)}}         & fwd_data_r1_iss[63:32])      |
                                  ({32{(str0_data_b_sel_iss_i == `CA53_SEL_STR_B_A_H) &
                                       (str0_data_a_sel_iss_i == `CA53_SEL_STR_A_R2)}}         & fwd_data_r2_iss[63:32])      |
                                  ({32{(str0_data_b_sel_iss_i == `CA53_SEL_STR_B_A_H) &
                                       (str0_data_a_sel_iss_i == `CA53_SEL_STR_A_R4)}}         & fwd_data_r4_iss[63:32])      |
                                  ({32{str0_data_b_sel_iss_i == `CA53_SEL_STR_B_R2}}           & fwd_data_r2_iss[31:0])       |
                                  ({32{str0_data_b_sel_iss_i == `CA53_SEL_STR_B_R3}}           & fwd_data_r3_iss[31:0])       |
                                  ({32{str0_data_b_sel_iss_i == `CA53_SEL_STR_B_PC}}           & masked_pc_instr0_iss[31:0]);

  // Slot1 instructions R2-3 map to R3-2 on regbank and ports A-B on STR1
  // respectively. (Note remapping dealt with in De).
  assign st1_data_a_iss[31:0]   = ({32{str1_data_a_sel_iss_i == `CA53_SEL_STR_A_R1}}           & fwd_data_r4_iss[31:0])       |
                                  ({32{str1_data_a_sel_iss_i == `CA53_SEL_STR_A_R2}}           & fwd_data_r2_iss[31:0])       |
                                  ({32{str1_data_a_sel_iss_i == `CA53_SEL_STR_A_R4}}           & fwd_data_r1_iss[31:0])       |
                                  ({32{str1_data_a_sel_iss_i == `CA53_SEL_STR_A_PC}}           & masked_pc_instr1_iss[31:0]);

  assign st1_data_b_iss[31:0]   = ({32{(str1_data_b_sel_iss_i == `CA53_SEL_STR_B_A_H) &
                                       (str1_data_a_sel_iss_i == `CA53_SEL_STR_A_R1)}}         & fwd_data_r4_iss[63:32])      |
                                  ({32{(str1_data_b_sel_iss_i == `CA53_SEL_STR_B_A_H) &
                                       (str1_data_a_sel_iss_i == `CA53_SEL_STR_A_R2)}}         & fwd_data_r2_iss[63:32])      |
                                  ({32{(str1_data_b_sel_iss_i == `CA53_SEL_STR_B_A_H) &
                                       (str1_data_a_sel_iss_i == `CA53_SEL_STR_A_R4)}}         & fwd_data_r1_iss[63:32])      |
                                  ({32{str1_data_b_sel_iss_i == `CA53_SEL_STR_B_R2}}           & fwd_data_r2_iss[31:0])       |
                                  ({32{str1_data_b_sel_iss_i == `CA53_SEL_STR_B_PC}}           & masked_pc_instr1_iss[31:0]);

  // ------------------------------------------------------
  // ALU0 pipeline
  // ------------------------------------------------------

  ca53dpu_alu #(.ALU_SLOT_1(0), .NEON_FP(NEON_FP)) u_alu0 (
    // Inputs
    .clk                           (clk),
    .reset_n                       (reset_n),
    .DFTSE                         (DFTSE),
    .aarch64_state_i               (aarch64_state_i),
    .alu_data_a_iss_i              (alu0_data_a_iss[63:0]),
    .alu_data_b_iss_i              (alu0_data_b_iss[63:0]),
    .alu_data_c_iss_i              (alu0_data_c_iss[7:0]),
    .alu_mskgen_iss_i              (alu0_mskgen_iss[5:0]),
    .alu_imm_shift_iss_i           (imm_shift_0_iss[4:0]),
    .alu_imm_sel_c_iss_i           (imm_sel_c_0_iss),
    .rf_wr_data_w0_wr_i            (rf_wr_data_w0_wr[63:0]),
    .rf_wr_data_w1_wr_i            (rf_wr_data_w1_wr[63:0]),
    .rf_wr_data_w2_wr_i            (rf_wr_data_w2_wr[63:0]),
    .alu_a_fwd_ex1_i               (alu0_a_fwd_ex1_i[`CA53_FWD_W-1:0]),
    .alu_b_fwd_ex1_i               (alu0_b_fwd_ex1_i[`CA53_FWD_W-1:0]),
    .ctl_64bit_op_iss_i            (ctl_64bit_op_alu0_iss_i),
    .flush_ret_i                   (flush_ret_i),
    .quash_iss_i                   (quash_iss_i),
    .quash_ex1_i                   (quash_ex1_i),
    .stall_ex1_i                   (stall_ex1_i),
    .stall_ex2_i                   (stall_ex2_i),
    .stall_wr_i                    (stall_wr_i),
    .use_ex1_alu_iss_i             (use_ex1_alu_0_iss_i),
    .raw_alu_valid_iss_i           (raw_alu0_valid_iss_i),
    .alu_valid_iss_i               (alu0_valid_iss_i),
    .alu_ex1_ctl_iss_i             (alu0_ex1_ctl_iss_i[(`CA53_ALU_EX1_CTL_W-1):0]),
    .alu_ex2_ctl_iss_i             (alu0_ex2_ctl_iss_i[(`CA53_ALU_EX2_CTL_W-1):0]),
    .alu_wr_ctl_iss_i              (alu0_wr_ctl_iss_i),
    .alu0_fwd_data_ex1_i           ({64{1'b0}}),  // ALU0 cannot forward to itself from Ex1
    .alu0_fwd_data_ex2_i           (alu0_fwd_data_ex2[63:0]),
    .alu1_fwd_data_ex2_i           (alu1_fwd_data_ex2[63:0]),
    .csel_cc_pass_ex2_i            (alu0_csel_pass_ex2),
    .csel_cc_pass_early_ex2_i      (alu0_csel_pass_ex2),  // Early is full version for ALU0
    .geflags_ex2_i                 (geflags_ex2[3:0]),
    .cflag_ex2_i                   (ccflags_ex2[1]),
    .vflag_wr_i                    (ccflags_wr[0]),
    // Outputs
    .alu_qbit_wr_o                 (alu0_qbit_wr_o),
    .alu_fwd_data_ex1_o            (alu0_fwd_data_ex1[63:0]),
    .alu_fwd_data_ex2_o            (alu0_fwd_data_ex2[63:0]),
    .alu_data_wr_o                 (alu0_data_wr[63:0]),
    .alu_data_a_ex2_o              (alu0_data_a_ex2[63:0]),
    .alu_fwd_data_early_ex2_o      (alu0_fwd_data_early_ex2_o[63:0]),
    .alu_fwd_data_early_wr_o       (alu0_fwd_data_early_wr_o[63:0]),
    .alu_valid_ex2_o               (alu0_valid_ex2),
    .alu_au_nout_ex2_o             (alu0_au_nout_ex2),
    .alu_sel_c_flag_ex2_o          (alu0_sel_c_flag_ex2),
    .alu_sel_v_flag_ex2_o          (alu0_sel_v_flag_ex2),
    .alu_csel_cond_ex2_o           (alu0_csel_cond_ex2[3:0]),
    .alu_ex2_cbz_bypass_zflag_o    (alu0_ex2_cbz_bypass_zflag),
    .alu_ex2_cbz_pass_o            (alu0_ex2_cbz_pass),
    .alu_ex2_flagid_o              (alu0_ex2_flagid[1:0]),
    .new_alu_ccflags_nclear_ex2_o  (new_alu0_ccflags_nclear_ex2[3:0]),
    .new_alu_ccflags_nset_ex2_o    (new_alu0_ccflags_nset_ex2[3:0]),
    .new_alu_ccflags_ccmp_ex2_o    (new_alu0_ccflags_ccmp_ex2[3:0]),
    .alu_sel_ccmp_flags_ex2_o      (alu0_sel_ccmp_flags_ex2),
    .new_alu_geflags_ex2_o         (new_alu0_geflags_ex2[3:0])
  );

  // ------------------------------------------------------
  // ALU1 pipeline
  // ------------------------------------------------------

  ca53dpu_alu #(.ALU_SLOT_1(1), .NEON_FP(0)) u_alu1 (
    // Inputs
    .clk                           (clk),
    .reset_n                       (reset_n),
    .DFTSE                         (DFTSE),
    .aarch64_state_i               (aarch64_state_i),
    .alu_data_a_iss_i              (alu1_data_a_iss[63:0]),
    .alu_data_b_iss_i              (alu1_data_b_iss[63:0]),
    .alu_data_c_iss_i              (alu1_data_c_iss[7:0]),
    .alu_mskgen_iss_i              (alu1_mskgen_iss),
    .alu_imm_shift_iss_i           (imm_shift_1_iss[4:0]),
    .alu_imm_sel_c_iss_i           (imm_sel_c_1_iss),
    .rf_wr_data_w0_wr_i            (rf_wr_data_w0_wr[63:0]),
    .rf_wr_data_w1_wr_i            (rf_wr_data_w1_wr[63:0]),
    .rf_wr_data_w2_wr_i            (rf_wr_data_w2_wr[63:0]),
    .alu_a_fwd_ex1_i               (alu1_a_fwd_ex1_i[`CA53_FWD_W-1:0]),
    .alu_b_fwd_ex1_i               (alu1_b_fwd_ex1_i[`CA53_FWD_W-1:0]),
    .ctl_64bit_op_iss_i            (ctl_64bit_op_alu1_iss_i),
    .flush_ret_i                   (flush_ret_i),
    .quash_iss_i                   (quash_iss_i),
    .quash_ex1_i                   (quash_ex1_i),
    .stall_ex1_i                   (stall_ex1_i),
    .stall_ex2_i                   (stall_ex2_i),
    .stall_wr_i                    (stall_wr_i),
    .use_ex1_alu_iss_i             (use_ex1_alu_1_iss_i),
    .raw_alu_valid_iss_i           (raw_alu1_valid_iss_i),
    .alu_valid_iss_i               (alu1_valid_iss_i),
    .alu_ex1_ctl_iss_i             (alu1_ex1_ctl_iss_i[(`CA53_ALU_EX1_CTL_W-1):0]),
    .alu_ex2_ctl_iss_i             (alu1_ex2_ctl_iss_i[(`CA53_ALU_EX2_CTL_W-1):0]),
    .alu_wr_ctl_iss_i              (alu1_wr_ctl_iss_i),
    .alu0_fwd_data_ex1_i           (alu0_fwd_data_ex1[63:0]),
    .alu0_fwd_data_ex2_i           (alu0_fwd_data_ex2[63:0]),
    .alu1_fwd_data_ex2_i           (alu1_fwd_data_ex2[63:0]),
    .csel_cc_pass_ex2_i            (alu1_csel_pass_ex2),
    .csel_cc_pass_early_ex2_i      (alu1_csel_pass_early_ex2),
    .geflags_ex2_i                 (geflags_ex2[3:0]),
    .cflag_ex2_i                   (ccflags_ex2[1]),
    .vflag_wr_i                    (ccflags_wr[0]),
    // Outputs
    .alu_qbit_wr_o                 (alu1_qbit_wr_o),
    .alu_fwd_data_ex1_o            (alu1_fwd_data_ex1[63:0]),
    .alu_fwd_data_ex2_o            (alu1_fwd_data_ex2[63:0]),
    .alu_data_wr_o                 (alu1_data_wr[63:0]),
    .alu_data_a_ex2_o              (),  // Only used by ALU0 for base restore
    .alu_fwd_data_early_ex2_o      (alu1_fwd_data_early_ex2_o[63:0]),
    .alu_fwd_data_early_wr_o       (alu1_fwd_data_early_wr_o[63:0]),
    .alu_valid_ex2_o               (alu1_valid_ex2),
    .alu_au_nout_ex2_o             (alu1_au_nout_ex2),
    .alu_sel_c_flag_ex2_o          (alu1_sel_c_flag_ex2),
    .alu_sel_v_flag_ex2_o          (alu1_sel_v_flag_ex2),
    .alu_csel_cond_ex2_o           (alu1_csel_cond_ex2[3:0]),
    .alu_ex2_cbz_bypass_zflag_o    (alu1_ex2_cbz_bypass_zflag),
    .alu_ex2_cbz_pass_o            (alu1_ex2_cbz_pass),
    .alu_ex2_flagid_o              (alu1_ex2_flagid[1:0]),
    .new_alu_ccflags_nclear_ex2_o  (new_alu1_ccflags_nclear_ex2[3:0]),
    .new_alu_ccflags_nset_ex2_o    (new_alu1_ccflags_nset_ex2[3:0]),
    .new_alu_ccflags_ccmp_ex2_o    (new_alu1_ccflags_ccmp_ex2[3:0]),
    .alu_sel_ccmp_flags_ex2_o      (alu1_sel_ccmp_flags_ex2),
    .new_alu_geflags_ex2_o         (new_alu1_geflags_ex2[3:0])
  );

  // ------------------------------------------------------
  // Select flags
  // ------------------------------------------------------

  // CC Flags
  // - The N flag output from the AU in the ALUs is very late, and so is
  // factored in as late as possible. Therefore, for the flags from the ALUs,
  // different versions of the flags are set up based on all possible values
  // of N, to allow N to be factored in as late as possible. This is complicated
  // for the CCMP instruction, as it writes a different value to the flags
  // depending on whether its condition passes or fails. A CCMP in ALU1 tests
  // its condition based on flags flat forwarded from ALU0, so the ALU1 flags
  // depend on the N output from both ALU1 and ALU0.

  // - ALU0 CCMP flags do not depend on N, so just factor CCMP flags into
  // both N set and N clear terms, then select between two using ALU0.N
  assign new_alu0_ccflags_ccmp_nset_ex2   = alu0_sel_ccmp_flags_ex2 ? (alu0_csel_pass_ex2 ? new_alu0_ccflags_nset_ex2   // CCMP Pass => use result of operation
                                                                                          : new_alu0_ccflags_ccmp_ex2)  // CCMP Fail => use specified flags
                                                                    : new_alu0_ccflags_nset_ex2;

  assign new_alu0_ccflags_ccmp_nclear_ex2 = alu0_sel_ccmp_flags_ex2 ? (alu0_csel_pass_ex2 ? new_alu0_ccflags_nclear_ex2
                                                                                          : new_alu0_ccflags_ccmp_ex2)
                                                                    : new_alu0_ccflags_nclear_ex2;

  assign new_alu0_ccflags_ex2 = alu0_au_nout_ex2 ? new_alu0_ccflags_ccmp_nset_ex2[3:0] : new_alu0_ccflags_ccmp_nclear_ex2[3:0];

  // - ALU1 CCMP flags can depend on forwarded value of N from ALU0, so
  // create four versions of the ALU1 flags, one for each of:
  // ALU0.N=0,1 x ALU1.N=0,1
  assign new_alu1_ccflags_ccmp_n0set_n1set_ex2      = alu1_sel_ccmp_flags_ex2 ? (alu1_csel_pass_n0set_ex2   ? new_alu1_ccflags_nset_ex2   // CCMP Pass => use result of operation
                                                                                                            : new_alu1_ccflags_ccmp_ex2)  // CCMP Fail => use specified flags
                                                                              : new_alu1_ccflags_nset_ex2;

  assign new_alu1_ccflags_ccmp_n0set_n1clear_ex2    = alu1_sel_ccmp_flags_ex2 ? (alu1_csel_pass_n0set_ex2   ? new_alu1_ccflags_nclear_ex2
                                                                                                            : new_alu1_ccflags_ccmp_ex2)
                                                                              : new_alu1_ccflags_nclear_ex2;

  assign new_alu1_ccflags_ccmp_n0clear_n1set_ex2    = alu1_sel_ccmp_flags_ex2 ? (alu1_csel_pass_n0clear_ex2 ? new_alu1_ccflags_nset_ex2
                                                                                                            : new_alu1_ccflags_ccmp_ex2)
                                                                              : new_alu1_ccflags_nset_ex2;

  assign new_alu1_ccflags_ccmp_n0clear_n1clear_ex2  = alu1_sel_ccmp_flags_ex2 ? (alu1_csel_pass_n0clear_ex2 ? new_alu1_ccflags_nclear_ex2
                                                                                                            : new_alu1_ccflags_ccmp_ex2)
                                                                              : new_alu1_ccflags_nclear_ex2;

  // - Factor in both ALU0.N and ALU1.N as late as possible
  assign new_alu1_ccflags_ex2 = alu1_au_nout_ex2 ? (alu0_au_nout_ex2 ? new_alu1_ccflags_ccmp_n0set_n1set_ex2
                                                                     : new_alu1_ccflags_ccmp_n0clear_n1set_ex2)
                                                 : (alu0_au_nout_ex2 ? new_alu1_ccflags_ccmp_n0set_n1clear_ex2
                                                                     : new_alu1_ccflags_ccmp_n0clear_n1clear_ex2);
                                
  // Choose between FP cflags and immediate for conditional compare
  assign new_fp0_ccflags_ex2 = alu0_sel_ccmp_flags_ex2 ? (alu0_csel_pass_ex2 ? fp_cflags_add0_f2_i         // CCMP Pass => use result of operation
                                                                             : new_alu0_ccflags_ccmp_ex2)  // CCMP Fail => use specified flags
                                                       : fp_cflags_add0_f2_i;

  assign new_fp1_ccflags_ex2 = alu1_sel_ccmp_flags_ex2 ? (alu1_csel_pass_ex2 ? fp_cflags_add1_f2_i         // CCMP Pass => use result of operation
                                                                             : new_alu1_ccflags_ccmp_ex2)  // CCMP Fail => use specified flags
                                                       : fp_cflags_add1_f2_i;

  assign fp0_ccmp_fail_ex2_o = fp0_ccflag_set_ex2 & alu0_sel_ccmp_flags_ex2 & ~alu0_csel_pass_ex2;
  assign fp1_ccmp_fail_ex2_o = fp1_ccflag_set_ex2 & alu1_sel_ccmp_flags_ex2 & ~alu1_csel_pass_ex2;

  // - Mux between various sources of flags for instruction in Ex2
  assign alu0_ccflag_set_ex2    =  (alu0_ex2_flagid == 2'b10) &                         alu0_valid_ex2 & cc_pass_instr0_ex2;
  assign alu1_ccflag_set_ex2    =  (alu1_ex2_flagid == 2'b10) &                         alu1_valid_ex2 & cc_pass_instr1_ex2;
  assign fmstat_ccflag_set_ex2  = ((alu0_ex2_flagid == 2'b10) & instr_fmstat_ex2_i[0] & alu0_valid_ex2 & cc_pass_instr0_ex2) |
                                  ((alu1_ex2_flagid == 2'b10) & instr_fmstat_ex2_i[1] & alu1_valid_ex2 & cc_pass_instr1_ex2);
  assign fp0_ccflag_set_ex2     =  (alu0_ex2_flagid == 2'b01) &                         alu0_valid_ex2; // No need for cc_pass, as always unconditional
  assign fp1_ccflag_set_ex2     =  (alu1_ex2_flagid == 2'b01) &                         alu1_valid_ex2; // No need for cc_pass, as always unconditional

  assign ccflags_ex2[3:2] = cpsr_flag_update_cp_dscr_wr_i               ? cpsr_flag_update_nzcv_i[3:2]  :
                            fp1_ccflag_set_ex2                          ? new_fp1_ccflags_ex2[3:2]      :
                            fp0_ccflag_set_ex2                          ? new_fp0_ccflags_ex2[3:2]      :
                            fmstat_ccflag_set_ex2                       ? fp_fwd_cflags_ex2_i[3:2]      :
                            alu1_ccflag_set_ex2                         ? new_alu1_ccflags_ex2[3:2]     :
                            alu0_ccflag_set_ex2                         ? new_alu0_ccflags_ex2[3:2]     :
                            sel_mac_nzflags_wr_i                        ? new_mac_nzflags_wr            :
                            // Preserve flags:
                            use_localcc_wr                              ? ccflags_wr[3:2]               : // Forward from Wr if flag setting instr there
                                                                          cpsr_ret_i[`CA53_PSR_ARCH_NZ_BITS];

  assign ccflags_ex2[1]   = cpsr_flag_update_cp_dscr_wr_i               ? cpsr_flag_update_nzcv_i[1]    :
                            fp1_ccflag_set_ex2                          ? new_fp1_ccflags_ex2[1]        :
                            fp0_ccflag_set_ex2                          ? new_fp0_ccflags_ex2[1]        :
                            fmstat_ccflag_set_ex2                       ? fp_fwd_cflags_ex2_i[1]        :
                            (alu1_ccflag_set_ex2 & alu1_sel_c_flag_ex2) ? new_alu1_ccflags_ex2[1]       :
                            (alu0_ccflag_set_ex2 & alu0_sel_c_flag_ex2) ? new_alu0_ccflags_ex2[1]       :
                            // Preserve flags:
                            use_localcc_wr                              ? ccflags_wr[1]                 :
                                                                          cpsr_ret_i[`CA53_PSR_ARCH_C_BITS];

  assign ccflags_ex2[0]   = cpsr_flag_update_cp_dscr_wr_i               ? cpsr_flag_update_nzcv_i[0]    :
                            fp1_ccflag_set_ex2                          ? new_fp1_ccflags_ex2[0]        :
                            fp0_ccflag_set_ex2                          ? new_fp0_ccflags_ex2[0]        :
                            fmstat_ccflag_set_ex2                       ? fp_fwd_cflags_ex2_i[0]        :
                            (alu1_ccflag_set_ex2 & alu1_sel_v_flag_ex2) ? new_alu1_ccflags_ex2[0]       :
                            (alu0_ccflag_set_ex2 & alu0_sel_v_flag_ex2) ? new_alu0_ccflags_ex2[0]       :
                            // Preserve flags:
                            use_localcc_wr                              ? ccflags_wr[0]                 :
                                                                          cpsr_ret_i[`CA53_PSR_ARCH_V_BITS];

  // Form flat fowarded flags to pass to ALU1 for CSEL/CCMP instructions,
  // including new flags being generated by an operation in ALU0 but
  // excluding other flag setting sources.
  // - Split into N set and clear versions, so N can be muxed in as late as
  // possible to improve timing
  // - Note that this CSEL/CCMP instructions are only available in AArch64,
  // which contains no conditionally executed data processing instructions,
  // so cc_pass_instr0 does not need factoring in when determining if the
  // ALU0 flags should be forwarded.
  assign alu1_fwd_ccflags_nset_ex2    = ((alu0_ex2_flagid == 2'b10) & alu0_valid_ex2) ? new_alu0_ccflags_ccmp_nset_ex2[3:0]   : ccflags_wr[3:0];
  assign alu1_fwd_ccflags_nclear_ex2  = ((alu0_ex2_flagid == 2'b10) & alu0_valid_ex2) ? new_alu0_ccflags_ccmp_nclear_ex2[3:0] : ccflags_wr[3:0];

  // GE Flags
  assign alu0_geflag_set_ex2  = (alu0_ex2_flagid == 2'b11) & alu0_valid_ex2 & cc_pass_instr0_ex2;
  assign alu1_geflag_set_ex2  = (alu1_ex2_flagid == 2'b11) & alu1_valid_ex2 & cc_pass_instr1_ex2;

  assign geflags_ex2 = alu1_geflag_set_ex2 ? new_alu1_geflags_ex2[3:0] :
                       alu0_geflag_set_ex2 ? new_alu0_geflags_ex2[3:0] :
                       // Preserve flags:
                       use_localge_wr      ? geflags_wr[3:0]           :
                                             cpsr_ret_i[`CA53_PSR_ARCH_GE_BITS];

  // Because the flags in the CPSR are written in Wr, if there is a flag
  // setting instruction in Wr the latest flags must be forwarded to Ex2
  // from Wr rather than taken from the CPSR registers in Ret.
  assign nxt_use_localcc_wr = (alu0_ccflag_set_ex2 | alu1_ccflag_set_ex2 | fp0_ccflag_set_ex2 | fp1_ccflag_set_ex2) & ~flush_wr_i;
  assign nxt_use_localge_wr = (alu0_geflag_set_ex2 | alu1_geflag_set_ex2)                                           & ~flush_wr_i;

  always @(posedge clk)
    if (advance_pipeline_i) begin
      ccflags_wr      <= ccflags_ex2;
      geflags_wr      <= geflags_ex2;
      use_localcc_wr  <= nxt_use_localcc_wr;
      use_localge_wr  <= nxt_use_localge_wr;
    end

  assign ccflags_wr_o = sel_mac_nzflags_wr_i ? {new_mac_nzflags_wr, ccflags_wr[1:0]} :
                                               ccflags_wr;
  assign geflags_wr_o = geflags_wr;

  // ------------------------------------------------------
  // Conditional execution logic
  // ------------------------------------------------------

  // Condition Code evaluation for Instr0
  assign cc_pass_instr0_ex2 = cc_eval(cond_code_instr0_ex2_i, ccflags_wr);

  // For a CB[N]Z instruction, the ccpass result is not evaluated on the condition
  // flags, but on the result of the current ALU operation.
  // For CBZ/CBNZ, the condition is always EQ or NE, which only relies on the
  // Z flag - can use one of the early ccflag signals
  assign cc_pass_instr0_cbz_ex2_o = alu0_ex2_cbz_bypass_zflag ? alu0_ex2_cbz_pass
                                                              : cc_pass_instr0_ex2;

  // Condition Code evaluation for Instr1 (doesn't include CBZ
  // evaluation as CBZ cannot be dual-issued)

  // - Early version not including flags from ALU0
  assign cc_pass_instr1_early_ex2_o = cc_eval(cond_code_instr1_ex2_i, ccflags_wr);

  // - Full version including flat forwarded flags
  assign instr1_flags_nclear_ex2 = alu0_ccflag_set_ex2 ? new_alu0_ccflags_ccmp_nclear_ex2 : ccflags_wr;
  assign instr1_flags_nset_ex2   = alu0_ccflag_set_ex2 ? new_alu0_ccflags_ccmp_nset_ex2   : ccflags_wr;

  assign cc_pass_instr1_ex2 = alu0_au_nout_ex2 ? cc_eval(cond_code_instr1_ex2_i, instr1_flags_nset_ex2)
                                               : cc_eval(cond_code_instr1_ex2_i, instr1_flags_nclear_ex2);

  assign cc_pass_instr1_cbz_ex2_o = alu1_ex2_cbz_bypass_zflag ? alu1_ex2_cbz_pass
                                                              : cc_pass_instr1_ex2;

  // Conditional code evaluation for CSEL/CCMP instructions
  // - Always executed unconditionally, but whether the condition passes or
  // fails determines what the result of the instruction is

  // - ALU0 always uses flags from Wr
  assign alu0_csel_pass_ex2       = cc_eval(alu0_csel_cond_ex2, ccflags_wr);

  // - ALU1 has uses flags forwarded out of ALU0, but also has an early
  // version just using the flags from Wr
  assign alu1_csel_pass_early_ex2 = cc_eval(alu1_csel_cond_ex2, ccflags_wr);

  // - Because N flag from ALU0 is very late, the ALU1 CSEL condition is
  // evaluated twice based on both possible values for N, with N muxed in at
  // the end
  assign alu1_csel_pass_n0set_ex2   = cc_eval(alu1_csel_cond_ex2, alu1_fwd_ccflags_nset_ex2);
  assign alu1_csel_pass_n0clear_ex2 = cc_eval(alu1_csel_cond_ex2, alu1_fwd_ccflags_nclear_ex2);

  assign alu1_csel_pass_ex2         = alu0_au_nout_ex2 ? alu1_csel_pass_n0set_ex2 : alu1_csel_pass_n0clear_ex2;

  // Output aliases
  assign cc_pass_instr0_ex2_o = cc_pass_instr0_ex2;
  assign cc_pass_instr1_ex2_o = cc_pass_instr1_ex2;
  assign alu0_csel_pass_ex2_o = alu0_csel_pass_ex2;

  // ------------------------------------------------------
  // MAC pipeline
  // ------------------------------------------------------

  ca53dpu_mac u_mac (
    // Inputs
    .clk                  (clk),
    .reset_n              (reset_n),
    .DFTSE                (DFTSE),
    .stall_wr_i           (stall_wr_i),
    .flush_wr_i           (flush_wr_i),
    .mac_valid_de_i       (mac_valid_de_i),
    .raw_mac_valid_iss_i  (raw_mac_valid_iss_i),
    .mac_valid_iss_i      (mac_valid_iss_i),
    .mac_cmd_iss_i        (mac_iss_ctl_iss_i[`CA53_MAC_ISS_CTL_W-1:0]),
    .slot1_mul_iss_i      (slot1_mul_iss_i),
    .mac_fwd_ctl_ex1_i    (mac_fwd_ctl_ex1_i[5:0]),
    .mac_opa_iss_i        (mac_opa_iss[63:0]),
    .mac_opb_iss_i        (mac_opb_iss[63:0]),
    .st0_data_ex2_i       (st0_data_ex2[63:0]),
    .st1_data_ex2_i       (st1_data_ex2[63:0]),
    // Outputs
    .mac_stall_iss_o      (mac_stall_iss_o),
    .mac_res_lo_wr_o      (mac_res_lo_wr[31:0]),
    .mac_res_hi_wr_o      (mac_res_hi_wr[31:0]),
    .mac_q_wr_o           (mac_q_wr),
    .mac_n_wr_o           (mac_n_wr),
    .mac_z_wr_o           (mac_z_wr)
  );

  assign new_mac_nzflags_wr[1:0]   = {mac_n_wr, mac_z_wr};
  assign new_mac_qflag_wr_o        = mac_q_wr;

  // ------------------------------------------------------
  // Divider
  // ------------------------------------------------------

  ca53dpu_div u_div (
    // Inputs
    .clk                     (clk),
    .reset_n                 (reset_n),
    .DFTSE                   (DFTSE),
    .div_flush_i             (div_flush_i),
    .div_valid_de_i          (div_valid_de_i),
    .raw_div_valid_iss_i     (raw_div_valid_iss_i),
    .div_valid_iss_i         (div_valid_iss_i),
    .div_signed_iss_i        (mac_iss_ctl_iss_i[8]),
    .ctl_64bit_op_iss_i      (ctl_64bit_op_mac_iss_i),
    .div_opa_iss_i           (div_opa_iss[63:0]),
    .div_opb_iss_i           (div_opb_iss[63:0]),
    // Outputs
    .div_res_wr_o            (div_res_wr[63:0]),
    .div_busy_iss_o          (div_busy_iss_o),
    .nxt_div_busy_wr_o       (nxt_div_busy_wr_o)
  );

  // ------------------------------------------------------
  // Store 0 pipeline
  // ------------------------------------------------------
  ca53dpu_store #(.NEON_FP(NEON_FP), .IS_PIPE0(1'b1)) u_store0 (
    // Inputs
    .clk                           (clk),
    .reset_n                       (reset_n),
    .DFTSE                         (DFTSE),
    .stall_wr_i                    (stall_wr_i),
    .ctl_64bit_op_store_iss_i      (ctl_64bit_op_str0_iss_i),
    .st_data_a_iss_i               (st0_data_a_iss[31:0]),
    .st_data_b_iss_i               (st0_data_b_iss[31:0]),
    .str_valid_de_i                (str0_valid_de_i),
    .raw_str_valid_iss_i           (raw_str0_valid_iss_i),
    .str_a_valid_iss_i             (str0_a_valid_iss_i),
    .str_b_valid_iss_i             (str0_b_valid_iss_i),
    .alu0_fwd_data_ex2_i           (alu0_fwd_data_ex2[63:0]),
    .rf_wr_data_w0_wr_i            (rf_wr_data_w0_wr[63:0]),
    .rf_wr_data_w1_wr_i            (rf_wr_data_w1_wr[63:0]),
    .rf_wr_data_w2_wr_i            (rf_wr_data_w2_wr[63:0]),
    .fp_str_data_f1_i              (fp_str0_data_f1_i[63:0]),
    .fp_str_data_f2_i              (fp_str0_data_f2_i[63:0]),
    .str_a_fwd_ex1_i               (str0_a_fwd_ex1_i[`CA53_FWD_W-1:0]),
    .str_b_fwd_ex1_i               (str0_b_fwd_ex1_i[`CA53_FWD_W-1:0]),
    .str_a_fwd_ex2_i               (str0_a_fwd_ex2_i[`CA53_FWD_W-1:0]),
    .str_b_fwd_ex2_i               (str0_b_fwd_ex2_i[`CA53_FWD_W-1:0]),
    // Outputs
    .st_data_ex1_o                 (st0_data_ex1_o[63:0]),
    .st_data_ex2_o                 (st0_data_ex2[63:0]),
    .st_data_wr_o                  (st0_data_wr[63:0])
  );

  // ------------------------------------------------------
  // Store 1 pipeline
  // ------------------------------------------------------
  ca53dpu_store #(.NEON_FP(NEON_FP), .IS_PIPE0(1'b0)) u_store1 (
    // Inputs
    .clk                           (clk),
    .reset_n                       (reset_n),
    .DFTSE                         (DFTSE),
    .stall_wr_i                    (stall_wr_i),
    .ctl_64bit_op_store_iss_i      (ctl_64bit_op_str1_iss_i),
    .st_data_a_iss_i               (st1_data_a_iss[31:0]),
    .st_data_b_iss_i               (st1_data_b_iss[31:0]),
    .str_valid_de_i                (str1_valid_de_i),
    .raw_str_valid_iss_i           (raw_str1_valid_iss_i),
    .str_a_valid_iss_i             (str1_a_valid_iss_i),
    .str_b_valid_iss_i             (str1_b_valid_iss_i),
    .alu0_fwd_data_ex2_i           (alu0_fwd_data_ex2[63:0]),
    .rf_wr_data_w0_wr_i            (rf_wr_data_w0_wr[63:0]),
    .rf_wr_data_w1_wr_i            (rf_wr_data_w1_wr[63:0]),
    .rf_wr_data_w2_wr_i            (rf_wr_data_w2_wr[63:0]),
    .fp_str_data_f1_i              (fp_str1_data_f1_i[63:0]),
    .fp_str_data_f2_i              (fp_str1_data_f2_i[63:0]),
    .str_a_fwd_ex1_i               (str1_a_fwd_ex1_i[`CA53_FWD_W-1:0]),
    .str_b_fwd_ex1_i               (str1_b_fwd_ex1_i[`CA53_FWD_W-1:0]),
    .str_a_fwd_ex2_i               (str1_a_fwd_ex2_i[`CA53_FWD_W-1:0]),
    .str_b_fwd_ex2_i               (str1_b_fwd_ex2_i[`CA53_FWD_W-1:0]),
    // Outputs
    .st_data_ex1_o                 (st1_data_ex1_o[63:0]),
    .st_data_ex2_o                 (st1_data_ex2[63:0]),
    .st_data_wr_o                  (st1_data_wr[63:0])
  );

  // ------------------------------------------------------
  // Save value for base register restore
  // ------------------------------------------------------

  always @(posedge clk)
    if (save_base_ex2_i)
      saved_base_value <= alu0_data_a_ex2;

  // ------------------------------------------------------
  // Write data muxes
  // ------------------------------------------------------

  // Convert the early control signals into a one-hot form
  always @* begin
    rf_wr_src_w0_wr_fw    = 6'b000000;
    rf_wr_src_w0_wr_nofw  = 2'b00;

    case (rf_wr_src_w0_wr_i)
      `CA53_RF_WR_SRC_W0_DCU_0    : rf_wr_src_w0_wr_fw = 6'b000010;
      `CA53_RF_WR_SRC_W0_CPSR     : rf_wr_src_w0_wr_fw = 6'b010000;
      `CA53_RF_WR_SRC_W0_SPSR     : rf_wr_src_w0_wr_fw = 6'b100000;
      `CA53_RF_WR_SRC_W0_MAC_HI   : rf_wr_src_w0_wr_fw = 6'b001000;
      `CA53_RF_WR_SRC_W0_STR      : rf_wr_src_w0_wr_fw = 6'b000001;
      `CA53_RF_WR_SRC_W0_STREX    : rf_wr_src_w0_wr_fw = 6'b000100;
      `CA53_RF_WR_SRC_W0_CP       : rf_wr_src_w0_wr_nofw = 2'b01;
      `CA53_RF_WR_SRC_W0_BASE     : rf_wr_src_w0_wr_nofw = 2'b10;
      default                   : begin
        rf_wr_src_w0_wr_fw    = 6'bxxxxxx;
        rf_wr_src_w0_wr_nofw  = 2'bxx;
      end
    endcase // case(rf_wr_src_w0_wr_i)
  end

  always @* begin
    rf_wr_src_w1_wr_fw    = 5'b00000;
    rf_wr_src_w1_wr_nofw  = 1'b0;

    case (rf_wr_src_w1_wr_i)
      `CA53_RF_WR_SRC_W1_ALU      : rf_wr_src_w1_wr_fw = 5'b00001;
      `CA53_RF_WR_SRC_W1_MAC_LO   : rf_wr_src_w1_wr_fw = 5'b00010;
      `CA53_RF_WR_SRC_W1_DIV      : rf_wr_src_w1_wr_fw = 5'b00100;
      `CA53_RF_WR_SRC_W1_FP_ALU   : rf_wr_src_w1_wr_fw = 5'b01000;
      `CA53_RF_WR_SRC_W1_STR      : rf_wr_src_w1_wr_fw = 5'b10000;
      `CA53_RF_WR_SRC_W1_CP       : rf_wr_src_w1_wr_nofw = 1'b1;
      default                   : begin
        rf_wr_src_w1_wr_fw    = 5'bxxxxx;
        rf_wr_src_w1_wr_nofw  = 1'bx;
      end
    endcase // case(rf_wr_src_w1_wr_i)
  end

  always @*
    case (rf_wr_src_w2_wr_i)
      `CA53_RF_WR_SRC_W2_DCU_1  : rf_wr_src_w2_wr_fw = 5'b00001;
      `CA53_RF_WR_SRC_W2_ALU    : rf_wr_src_w2_wr_fw = 5'b00010;
      `CA53_RF_WR_SRC_W2_MAC_LO : rf_wr_src_w2_wr_fw = 5'b00100;
      `CA53_RF_WR_SRC_W2_FP_ALU : rf_wr_src_w2_wr_fw = 5'b01000;
      `CA53_RF_WR_SRC_W2_STR    : rf_wr_src_w2_wr_fw = 5'b10000;
      default                   : rf_wr_src_w2_wr_fw = 5'bxxxxx;
    endcase // case(rf_wr_src_w2_wr_i)

  // Create register file write data buses
  assign rf_wr_data_w0_wr[31: 0] = ({32{rf_wr_src_w0_wr_fw[0]}} & (w0_slot1_wr_i ? st1_data_wr[63:32]
                                                                                 : st0_data_wr[63:32])) | // STR writes W0 with upper half (W1/2 always used for lower)
                                   ({32{rf_wr_src_w0_wr_fw[1]}} & ld_data0_wr_i[31:0])                  |
                                   ({32{rf_wr_src_w0_wr_fw[2]}} & { {31{1'b0}}, ~dcu_strex_okay_dc3_i}) |
                                   ({32{rf_wr_src_w0_wr_fw[3]}} & mac_res_hi_wr[31:0])                  |
                                   ({32{rf_wr_src_w0_wr_fw[4]}} & cpsr_masked_ret_i[31:0])              |
                                   ({32{rf_wr_src_w0_wr_fw[5]}} & spsr_ret_i[31:0]);

  assign rf_wr_data_w0_wr[63:32] = ({32{rf_wr_src_w0_wr_fw[1] & rf_wr_64b_w0_wr_i}} & ld_data0_wr_i[63:32]);

  assign rf_wr_data_w1_wr[31: 0] = ({32{rf_wr_src_w1_wr_fw[0]}} & alu0_data_wr[31:0])           |
                                   ({32{rf_wr_src_w1_wr_fw[1]}} & mac_res_lo_wr[31:0])          |
                                   ({32{rf_wr_src_w1_wr_fw[2]}} & div_res_wr[31:0])             |
                                   ({32{rf_wr_src_w1_wr_fw[3]}} & fp_alu0_f2i_res_f3_i[31:0])   |
                                   ({32{rf_wr_src_w1_wr_fw[4]}} & st0_data_wr[31:0]);

  assign rf_wr_data_w1_wr[63:32] = ({32{rf_wr_src_w1_wr_fw[0] & rf_wr_64b_w1_wr_i}} & alu0_data_wr[63:32])         |
                                   ({32{rf_wr_src_w1_wr_fw[1] & rf_wr_64b_w1_wr_i}} & mac_res_hi_wr[31:0])         |
                                   ({32{rf_wr_src_w1_wr_fw[2] & rf_wr_64b_w1_wr_i}} & div_res_wr[63:32])           |
                                   ({32{rf_wr_src_w1_wr_fw[3] & rf_wr_64b_w1_wr_i}} & fp_alu0_f2i_res_f3_i[63:32]) |
                                   ({32{rf_wr_src_w1_wr_fw[4] & rf_wr_64b_w1_wr_i}} & st0_data_wr[63:32]);  // Used for AA64 FMOV to X reg


  assign rf_wr_data_w2_wr[31: 0] = ({32{rf_wr_src_w2_wr_fw[0]}} & ld_data1_wr_i[31: 0])       |
                                   ({32{rf_wr_src_w2_wr_fw[1]}} & alu1_data_wr[31:0])         |
                                   ({32{rf_wr_src_w2_wr_fw[2]}} & mac_res_lo_wr[31:0])        |
                                   ({32{rf_wr_src_w2_wr_fw[3]}} & fp_alu1_f2i_res_f3_i[31:0]) |
                                   ({32{rf_wr_src_w2_wr_fw[4]}} & st1_data_wr[31:0]);

  assign rf_wr_data_w2_wr[63:32] = ({32{rf_wr_src_w2_wr_fw[0] & rf_wr_64b_w2_wr_i}} & ld_data1_wr_i[63:32])         |
                                   ({32{rf_wr_src_w2_wr_fw[1] & rf_wr_64b_w2_wr_i}} & alu1_data_wr[63:32])          |
                                   ({32{rf_wr_src_w2_wr_fw[2] & rf_wr_64b_w2_wr_i}} & mac_res_hi_wr[31:0])          |
                                   ({32{rf_wr_src_w2_wr_fw[3] & rf_wr_64b_w2_wr_i}} & fp_alu1_f2i_res_f3_i[63:32])  |
                                   ({32{rf_wr_src_w2_wr_fw[4] & rf_wr_64b_w2_wr_i}} & st1_data_wr[63:32]);

  // ------------------------------------------------------
  // Wr Stage store forwarding
  // ------------------------------------------------------

  // Swizzle the store data for the DCU
  assign store_data_wr = {st1_data_wr[63:0],                                              // 127:64
                          (srs_wr_i     ? spsr_ret_i[31:0]        : st0_data_wr[63:32]),  // 63:32
                          (ldc_stc_wr_i ? dbg_dtrrx_data_i[31:0]  : st0_data_wr[31:0])};  // 31:0

  ca53dpu_swizzle_store `CA53_DPU_PARAM_INST u_dpu_swizzle_store (
    .clk                      (clk),
    .reset_n                  (reset_n),
    .stall_wr_i               (stall_wr_i),
    .pre_valid_instrs_wr_i    (pre_valid_instrs_wr_i),
    .first_x64_wr_i           (first_x64_wr_i),
    .store_data_wr_i          (store_data_wr[127:0]),
    .slot1_ls_ex2_i           (slot1_ls_ex2_i),
    .v_addr_ex2_i             (v_addr_ex2_i[3:0]),
    .spec_endianness_ex2_i    (spec_endianness_ex2_i),
    .ls_elem_size_ex2_i       (ls_elem_size_ex2_i[1:0]),
    .ls_elem_size_wr_i        (ls_elem_size_wr_i[1:0]),
    .ls_valid_ex2_i           (ls_valid_ex2_i),
    .ls_store_ex2_i           (ls_store_ex2_i),
    .ls_store_neon_ex2_i      (ls_store_neon_ex2_i),
    .instr_is_cp10_cp11_wr_i  (instr_is_cp10_cp11_wr_i),
    .neon_vld_ctl_f2_i        (neon_vld_ctl_f2_i[`CA53_NEON_VLD_CTL_W-1:0]),
    .neon_vld_ctl_f3_i        (neon_vld_ctl_f3_i[`CA53_NEON_VLD_CTL_W-1:0]),
    .cp_valid_ex2_i           (cp_valid_ex2_i),
    .dpu_st_data_wr_o         (dpu_st_data_wr_o[127:0])
  );

  // Aliasing for register file write port outputs
  assign rf_wr_data_w0_wr_o = ({64{rf_wr_src_w0_wr_nofw[0]}} & { {32{1'b0}}, mrc_data_wr_i[63:32]}) |
                              ({64{rf_wr_src_w0_wr_nofw[1]}} & saved_base_value[63:0])              |
                              rf_wr_data_w0_wr;

  assign rf_wr_data_w1_wr_o = ({64{rf_wr_src_w1_wr_nofw}} & mrc_data_wr_i[63:0]) |
                              rf_wr_data_w1_wr;

  assign rf_wr_data_w2_wr_o = rf_wr_data_w2_wr;

  // Alias outputs for store pipeline
  assign st0_data_wr_o  = st0_data_wr[63:0];
  assign st1_data_wr_o  = st1_data_wr[63:0];

  // ------------------------------------------------------
  // OVL definitions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Check z flag prediction is correct (ALU0)
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"32bit z flag prediction incorrect (ALU0)")
    ovl_dpu_alu0_zpred_32 (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (~u_alu0.ctl_64bit_op_ex2 & alu0_valid_ex2 & ~flush_ret_i & alu0_ex2_flagid == 2'b10), // alu_valid_ex2 may be set on cycle after exception
      .consequent_expr (u_alu0.alu_ex2_valid_simd | (u_alu0.lu_ctl_ex2[3:0] == `CA53_LU_CTL_CSEL) | (new_alu0_ccflags_ex2[2] == (alu0_fwd_data_ex2[31:0] == 32'h0000_0000))));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"64bit z flag prediction incorrect (ALU0)")
    ovl_dpu_alu0_zpred_64 (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (u_alu0.ctl_64bit_op_ex2 & alu0_valid_ex2 & ~flush_ret_i & alu0_ex2_flagid == 2'b10),
      .consequent_expr (u_alu0.alu_ex2_valid_simd | (u_alu0.lu_ctl_ex2[3:0] == `CA53_LU_CTL_CSEL) | (new_alu0_ccflags_ex2[2] == (alu0_fwd_data_ex2[63:0] == 64'h0000_0000_0000_0000))));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Check z flag prediction is correct (ALU1)
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"32bit z flag prediction incorrect (alu1)")
    ovl_dpu_alu1_zpred_32 (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (~u_alu1.ctl_64bit_op_ex2 & alu1_valid_ex2 & ~flush_ret_i & alu1_ex2_flagid == 2'b10),
      .consequent_expr (u_alu1.alu_ex2_valid_simd | (u_alu1.lu_ctl_ex2[3:0] == `CA53_LU_CTL_CSEL) | (new_alu1_ccflags_ex2[2] == (alu1_fwd_data_ex2[31:0] == 32'h0000_0000))));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"64bit z flag prediction incorrect (alu1)")
    ovl_dpu_alu1_zpred_64 (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (u_alu1.ctl_64bit_op_ex2 & alu1_valid_ex2 & ~flush_ret_i & alu1_ex2_flagid == 2'b10),
      .consequent_expr (u_alu1.alu_ex2_valid_simd | (u_alu1.lu_ctl_ex2[3:0] == `CA53_LU_CTL_CSEL) | (new_alu1_ccflags_ex2[2] == (alu1_fwd_data_ex2[63:0] == 64'h0000_0000_0000_0000))));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Check imm_data_sel_x_iss never an unexpected value
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"imm_data_sel_0_iss unexpected value")
    ovl_imm_sel_0_unused  (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (alu0_valid_iss_i),
      .consequent_expr ((imm_data_sel_0_iss == `CA53_IMM_SEL_NULL)  |
                        (imm_data_sel_0_iss == `CA53_IMM_SEL_T32_1) |
                        (imm_data_sel_0_iss == `CA53_IMM_SEL_T32_2) |
                        (imm_data_sel_0_iss == `CA53_IMM_SEL_T32_3) |
                        (imm_data_sel_0_iss == `CA53_IMM_SEL_ROR)   |
                        (imm_data_sel_0_iss == `CA53_IMM_SEL_LSL)   |
                        (imm_data_sel_0_iss == `CA53_IMM_SEL_TBB)   |
                        (imm_data_sel_0_iss == `CA53_IMM_SEL_A64_LOG_IMM)));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"imm_data_sel_1_iss unexpected value")
    ovl_imm_sel_1_unused  (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (alu1_valid_iss_i),
      .consequent_expr ((imm_data_sel_1_iss == `CA53_IMM_SEL_NULL)  |
                        (imm_data_sel_1_iss == `CA53_IMM_SEL_T32_1) |
                        (imm_data_sel_1_iss == `CA53_IMM_SEL_T32_2) |
                        (imm_data_sel_1_iss == `CA53_IMM_SEL_T32_3) |
                        (imm_data_sel_1_iss == `CA53_IMM_SEL_ROR)   |
                        (imm_data_sel_1_iss == `CA53_IMM_SEL_LSL)   |
                        (imm_data_sel_1_iss == `CA53_IMM_SEL_A64_LOG_IMM)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Check imm_lsl shift never an unexpected value
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"imm_lsl 0 shift unexpected value")
    ovl_imm_lsl_0_unused  (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (alu0_valid_iss_i & (imm_data_sel_0_iss == `CA53_IMM_SEL_LSL)),
      .consequent_expr ((raw_imm_shift_0_iss[5:0] == `CA53_IMM_LSL_0)     |
                        (raw_imm_shift_0_iss[5:0] == `CA53_IMM_LSL_12)    |
                        (raw_imm_shift_0_iss[5:0] == `CA53_IMM_LSL_ADRP)  |
                        (raw_imm_shift_0_iss[5:0] == `CA53_IMM_LSL_16)    |
                        (raw_imm_shift_0_iss[5:0] == `CA53_IMM_LSL_32)    |
                        (raw_imm_shift_0_iss[5:0] == `CA53_IMM_LSL_48)));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"imm_lsl 1 shift unexpected value")
    ovl_imm_lsl_1_unused  (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (alu1_valid_iss_i & (imm_data_sel_1_iss == `CA53_IMM_SEL_LSL)),
      .consequent_expr ((raw_imm_shift_1_iss[5:0] == `CA53_IMM_LSL_0)     |
                        (raw_imm_shift_1_iss[5:0] == `CA53_IMM_LSL_12)    |
                        (raw_imm_shift_1_iss[5:0] == `CA53_IMM_LSL_ADRP)  |
                        (raw_imm_shift_1_iss[5:0] == `CA53_IMM_LSL_16)    |
                        (raw_imm_shift_1_iss[5:0] == `CA53_IMM_LSL_32)    |
                        (raw_imm_shift_1_iss[5:0] == `CA53_IMM_LSL_48)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Check imm_ror shift never an unexpected value
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"imm_ror 0 shift unexpected value")
    ovl_imm_ror_0_unused  (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (alu0_valid_iss_i & (imm_data_sel_0_iss == `CA53_IMM_SEL_ROR)),
      .consequent_expr ((raw_imm_shift_0_iss[4:0] == 5'b00000) |
                        (raw_imm_shift_0_iss[4:0] == 5'b00010) |
                        (raw_imm_shift_0_iss[4:0] == 5'b00100) |
                        (raw_imm_shift_0_iss[4:0] == 5'b00110) |
                        (raw_imm_shift_0_iss[4:0] == 5'b01000) |
                        (raw_imm_shift_0_iss[4:0] == 5'b01001) |
                        (raw_imm_shift_0_iss[4:0] == 5'b01010) |
                        (raw_imm_shift_0_iss[4:0] == 5'b01011) |
                        (raw_imm_shift_0_iss[4:0] == 5'b01100) |
                        (raw_imm_shift_0_iss[4:0] == 5'b01101) |
                        (raw_imm_shift_0_iss[4:0] == 5'b01110) |
                        (raw_imm_shift_0_iss[4:0] == 5'b01111) |
                        (raw_imm_shift_0_iss[4:0] == 5'b10000) |
                        (raw_imm_shift_0_iss[4:0] == 5'b10001) |
                        (raw_imm_shift_0_iss[4:0] == 5'b10010) |
                        (raw_imm_shift_0_iss[4:0] == 5'b10011) |
                        (raw_imm_shift_0_iss[4:0] == 5'b10100) |
                        (raw_imm_shift_0_iss[4:0] == 5'b10101) |
                        (raw_imm_shift_0_iss[4:0] == 5'b10110) |
                        (raw_imm_shift_0_iss[4:0] == 5'b10111) |
                        (raw_imm_shift_0_iss[4:0] == 5'b11000) |
                        (raw_imm_shift_0_iss[4:0] == 5'b11001) |
                        (raw_imm_shift_0_iss[4:0] == 5'b11010) |
                        (raw_imm_shift_0_iss[4:0] == 5'b11011) |
                        (raw_imm_shift_0_iss[4:0] == 5'b11100) |
                        (raw_imm_shift_0_iss[4:0] == 5'b11101) |
                        (raw_imm_shift_0_iss[4:0] == 5'b11110) |
                        (raw_imm_shift_0_iss[4:0] == 5'b11111)));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"imm_ror 1 shift unexpected value")
    ovl_imm_ror_1_unused  (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (alu1_valid_iss_i & (imm_data_sel_1_iss == `CA53_IMM_SEL_ROR)),
      .consequent_expr ((raw_imm_shift_1_iss[4:0] == 5'b00000) |
                        (raw_imm_shift_1_iss[4:0] == 5'b00010) |
                        (raw_imm_shift_1_iss[4:0] == 5'b00100) |
                        (raw_imm_shift_1_iss[4:0] == 5'b00110) |
                        (raw_imm_shift_1_iss[4:0] == 5'b01000) |
                        (raw_imm_shift_1_iss[4:0] == 5'b01001) |
                        (raw_imm_shift_1_iss[4:0] == 5'b01010) |
                        (raw_imm_shift_1_iss[4:0] == 5'b01011) |
                        (raw_imm_shift_1_iss[4:0] == 5'b01100) |
                        (raw_imm_shift_1_iss[4:0] == 5'b01101) |
                        (raw_imm_shift_1_iss[4:0] == 5'b01110) |
                        (raw_imm_shift_1_iss[4:0] == 5'b01111) |
                        (raw_imm_shift_1_iss[4:0] == 5'b10000) |
                        (raw_imm_shift_1_iss[4:0] == 5'b10001) |
                        (raw_imm_shift_1_iss[4:0] == 5'b10010) |
                        (raw_imm_shift_1_iss[4:0] == 5'b10011) |
                        (raw_imm_shift_1_iss[4:0] == 5'b10100) |
                        (raw_imm_shift_1_iss[4:0] == 5'b10101) |
                        (raw_imm_shift_1_iss[4:0] == 5'b10110) |
                        (raw_imm_shift_1_iss[4:0] == 5'b10111) |
                        (raw_imm_shift_1_iss[4:0] == 5'b11000) |
                        (raw_imm_shift_1_iss[4:0] == 5'b11001) |
                        (raw_imm_shift_1_iss[4:0] == 5'b11010) |
                        (raw_imm_shift_1_iss[4:0] == 5'b11011) |
                        (raw_imm_shift_1_iss[4:0] == 5'b11100) |
                        (raw_imm_shift_1_iss[4:0] == 5'b11101) |
                        (raw_imm_shift_1_iss[4:0] == 5'b11110) |
                        (raw_imm_shift_1_iss[4:0] == 5'b11111)));
  // OVL_ASSERT_END

  //ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: alu0_iss_en")
  u_ovl_x_alu0_iss_en (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (alu0_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: alu1_iss_en")
  u_ovl_x_alu1_iss_en (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (alu1_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_iss_i")
  u_ovl_x_issue_to_iss_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (issue_to_iss_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_pipeline_i")
  u_ovl_x_advance_pipeline_i (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (advance_pipeline_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: save_base_ex2_i")
  u_ovl_x_save_base_ex2_i (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (save_base_ex2_i));


`endif

endmodule // ca53dpu_dp

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
