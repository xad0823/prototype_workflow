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
// Abstract : Load/store pipeline
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// This module pipelines the various control signals required for load/store
// transactions as they travel through the DCU pipeline.  These signals form
// a "phantom" of the DCU transaction, and enable the correct operation when
// the result is produced in the wr-stage.
//
// Most of the wr-stage DCU interface signals are handled in this pipeline.
//
//---------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_ldst `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire                               clk,
  input  wire                               reset_n,
  input  wire                               DFTSE,
  input  wire                               aarch64_state_i,
  input  wire                        [3:1]  aarch64_at_el_i,
  input  wire                               stall_iss_i,
  input  wire                               ilock_stall_iss_i,
  input  wire                               flush_ls_wr_i,
  input  wire                               flush_wr_i,
  input  wire                               flush_ret_i,
  input  wire                               advance_pipeline_i,
  input  wire                               slot0_br_flush_wr_i,
  input  wire                               interlock_iss_i,
  input  wire                               stall_wr_i,
  input  wire                               nxt_div_stall_wr_i,
  input  wire                               cc_pass_instr0_ex2_i,
  input  wire                               cc_pass_instr1_ex2_i,
  input  wire                               slot1_ls_ex2_i,
  input  wire                               evnt_ls_instr_wr_i,
  input  wire                        [1:0]  dpu_exception_level_i,
  input  wire                               head_instr_ls_iss_i,
  input  wire                               ls_conditional_iss_i,
  input  wire                               spec_endianness_iss_i,
  input  wire                               spec_endianness_ex2_i,
  input  wire                               enable_base_restore_de_i,
  input  wire                               skid_x64_multiple_de_i,
  input  wire                               ls_valid_de_i,
  input  wire                        [5:0]  ls_length_de_i,
  input  wire                               ls_store_de_i,
  input  wire                               ls_store_neon_de_i,
  input  wire                        [2:0]  ls_size_de_i,
  input  wire                        [2:0]  ls_elem_size_de_i,
  input  wire  [`CA53_LS_INSTR_TYPE_W-1:0]  ls_instr_type_de_i,
  input  wire                               ls_isv_set_de_i,
  input  wire                               ls_synd_sf_de_i,
  input  wire                        [4:0]  ls_synd_srt_de_i,
  input  wire                               ls_check_stack_de_i,
  input  wire                               cp_de_i,
  input  wire                        [8:0]  cp_op_de_i,
  input  wire                               cp_op_mva_de_i,
  input  wire                               force_usr_priv_mem_de_i,
  input  wire      [`CA53_SEL_DCU_A_W-1:0]  agu_data_a_sel_de_i,
  input  wire      [`CA53_SEL_DCU_B_W-1:0]  agu_data_b_sel_de_i,
  input  wire    [`CA53_SEL_FWD_DCU_W-1:0]  sel_fwd_dcu_b_iss_i,
  input  wire    [`CA53_SEL_FWD_DCU_W-1:0]  sel_fwd_dcu_a_iss_i,
  input  wire                               sel_fwd_addr_dcu_a_iss_i,
  input  wire                        [2:0]  agu_shf_value_de_i,
  input  wire                               agu_sub_b_de_i,
  input  wire                       [63:0]  rf_rd_data_r0_agu_iss_i,
  input  wire                       [63:0]  rf_rd_data_r1_agu_iss_i,
  input  wire                       [63:0]  alu0_fwd_data_early_ex2_i,
  input  wire                       [63:0]  alu1_fwd_data_early_ex2_i,
  input  wire                       [63:0]  alu0_fwd_data_early_wr_i,
  input  wire                       [63:0]  alu1_fwd_data_early_wr_i,
  input  wire                       [63:1]  pc_instr0_iss_i,
  input  wire                       [48:1]  pc_instr1_iss_i,
  input  wire                               wd_align_pc_ls_iss_i,
  input  wire                               pg_align_pc_ls_iss_i,
  input  wire                       [32:0]  imm_data_ls_de_i,
  input  wire                               slot1_ls_de_i,
  input  wire                       [63:0]  dcu_ld_data_dc3_i,
  input  wire                               dcu_ready_iss_i,
  input  wire                               dcu_ready_cp_iss_i,
  input  wire                               dcu_valid_dc3_i,
  input  wire                               req_strict_algn_de_i,
  input  wire                               check_x64_de_i,
  input  wire                        [2:0]  algn_size_de_i,
  input  wire                               sctlr_align_check_i,
  input  wire                               cp_op_ats1_de_i,
  input  wire                               cp_other_sec_de_i,
  input  wire                               tlb_d_utlb_enable_i,
  input  wire                               tlb_d_utlb_might_enable_i,
  input  wire                               tlb_d_utlb_valid_i,
  input  wire                               tlb_d_utlb_lpae_i,
  input  wire                       [95:0]  tlb_d_utlb_data_i,
  input  wire                               tlb_d_utlb_flush_i,
  input  wire                               tlb_lpae_mode_i,
  input  wire                               flush_d_utlb_i,
  input  wire                       [31:0]  dpu_dacr_i,
  input  wire                       [31:0]  dpu_dacr_ns_i,
  input  wire                               dpu_default_cacheable_i,
  input  wire                               dpu_dacr_mmu_on_i,
  input  wire                               dpu_mmu_on_el1_i,
  input  wire                               ns_state_i,
  input  wire                               raw_cp_valid_wr_i,
  input  wire                        [1:0]  neon_instr_iss_i,
  // Outputs
  output wire                       [48:6]  dpu_agu_a_operand_iss_o,
  output wire                       [48:6]  dpu_agu_b_operand_iss_o,
  output wire                               dpu_agu_carry_out_64b_iss_o,
  output wire                               dcu_not_ready_iss_o,
  output wire                               first_lsm_skidding_o,
  output wire                               inter_lsm_skidding_o,
  output wire                               lsm_skidding_o,
  output wire                               lsm_64b_be_o,
  output wire                               lsm_64b_be_skidding_o,
  output wire                               lsm_n64b_be_skidding_o,
  output wire                               last_lsm_skidding_o,
  output wire                               force_extra_lsm_cycle_o,
  output wire                               extra_lsm_cycle_o,
  output wire                               ls_128b_be_o,
  output wire                               ldr_no_early_fwd_iss_o,
  output wire                               ls_stall_wr_o,
  output wire                               first_x64_iss_o,
  output wire      [`CA53_SEL_DCU_A_W-1:0]  agu_data_a_sel_iss_o,
  output wire      [`CA53_SEL_DCU_B_W-1:0]  agu_data_b_sel_iss_o,
  output wire                        [3:0]  v_addr_ex2_o,
  output wire                        [1:0]  ls_size_wr_o,
  output wire                        [1:0]  ls_elem_size_ex2_o,
  output wire                        [1:0]  ls_elem_size_wr_o,
  output wire                               ls_store_ex2_o,
  output wire                               ls_store_wr_o,
  output wire                               ls_store_neon_ex2_o,
  output wire  [`CA53_LS_INSTR_TYPE_W-1:0]  ls_instr_type_wr_o,
  output wire                               ls_isv_set_wr_o,
  output wire                               ls_synd_sf_wr_o,
  output wire                        [4:0]  ls_synd_srt_wr_o,
  output wire                               ldc_ex2_o,
  output wire                               ldc_stc_wr_o,
  output wire                               srs_wr_o,
  output wire                               ls_valid_iss_o,
  output wire                               ls_valid_ex1_o,
  output wire                               ls_valid_ex2_o,
  output wire                               ls_valid_wr_o,
  output wire                               first_x64_wr_o,
  output wire                               ongoing_ldm_wr_o,
  output wire                               dpu_valid_iss_o,
  output wire                               dpu_valid_cp_iss_o,
  output wire                               dpu_store_iss_o,
  output wire                       [15:0]  dpu_strobe_iss_o,
  output wire                               dpu_excl_iss_o,
  output wire                               dpu_ldar_stlr_iss_o,
  output wire                               dpu_non_temporal_iss_o,
  output wire                               dpu_pld_iss_o,
  output wire                               dpu_pld_level_iss_o,
  output wire                               dpu_priv_iss_o,
  output wire                               dpu_first_iss_o,
  output wire                               dpu_force_first_iss_o,
  output wire                               dpu_neon_access_iss_o,
  output wire                               second_x64_iss_o,
  output wire                        [4:0]  dpu_length_iss_o,
  output wire                        [1:0]  dpu_size_iss_o,
  output wire                               dpu_req_align_iss_o,
  output wire                        [2:0]  dpu_align_size_iss_o,
  output wire                               ls_multiple_iss_o,
  output wire                               ls_store_iss_o,
  output wire                               dpu_cross_64_iss_o,
  output wire                               dpu_burst_iss_o,
  output wire                        [8:0]  dpu_cp_op_iss_o,
  output wire                       [63:0]  fwd_ld_data_int_wr_o,
  output wire                       [63:0]  ld_data0_wr_o,
  output wire                       [63:0]  ld_data1_wr_o,
  output wire                               dpu_cc_fail_wr_o,
  output wire                               dpu_ready_wr_o,
  output wire                               dpu_ready_cc_fail_wr_o,
  output wire                               dpu_ready_cc_pass_wr_o,
  output wire                               enable_base_restore_iss_o,
  output wire                               dpu_utlb_hit_dc1_o,
  output wire                        [3:0]  dpu_utlb_hit_entry_dc1_o,
  output wire                       [63:0]  dpu_va_dc1_o,
  output wire                       [39:12] dpu_pa_dc1_o,
  output wire                       [12:0]  dpu_attributes_dc1_o,
  output wire                        [8:0]  dpu_fault_dc1_o,
  output wire                               dpu_ns_dsc_dc1_o,
  output wire                        [3:0]  dpu_domain_dc1_o,
  output wire                               dpu_abort_dc1_o,
  output wire                               dpu_stack_align_expt_dc1_o,
  output wire                        [3:0]  dpu_level_dc1_o,
  output wire                               dpu_lpae_dc1_o,
  output wire                               evnt_data_rd_wr_o,
  output wire                               evnt_data_wr_wr_o,
  output wire                               evnt_unaligned_ls_o,
  output wire                               evnt_data_mem_access_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                               ls_real_valid_iss;
  reg                               ls_valid_iss;
  reg                               ls_valid_fwd_iss;
  reg                         [5:0] ls_length_iss;
  reg                               ls_store_iss;
  reg                               skid_x64_multiple_iss;
  reg                               ls_store_ex1;
  reg                               ls_store_ex2;
  reg                               ls_store_wr;
  reg                               ls_store_neon_iss;
  reg                               ls_store_neon_ex1;
  reg                               ls_store_neon_ex2;
  reg                         [2:0] ls_size_iss;
  reg                         [2:0] ls_elem_size_iss;
  reg                               cp_iss;
  reg                         [8:0] cp_op_iss;
  reg                               cp_op_mva_iss;
  reg                               force_usr_priv_mem_iss;
  reg                         [2:0] agu_shf_value_iss;
  reg       [`CA53_SEL_DCU_A_W-1:0] agu_data_a_sel_iss;
  reg       [`CA53_SEL_DCU_A_W-1:0] agu_data_a_hi_sel_iss;
  reg       [`CA53_SEL_DCU_B_W-1:0] agu_data_b_sel_iss;
  reg                               agu_sub_b_iss;
  reg                               force_first_iss;
  reg                               second_x64_iss;
  reg                               subseq_x64_iss;
  reg                         [3:0] v_addr_ex2;
  reg                               unaligned_wr;
  reg                               ls_valid_ex1;
  reg                               ls_valid_ex2;
  reg                               ls_valid_wr;
  reg                               first_x64_ex1;
  reg                               first_x64_ex2;
  reg                               first_x64_wr;
  reg                               use_x64_skid_buffer_ex1;
  reg                               use_x64_skid_buffer_ex2;
  reg                         [1:0] ls_size_ex1;
  reg                         [1:0] ls_elem_size_ex1;
  reg                         [1:0] ls_size_ex2;
  reg                         [1:0] ls_elem_size_ex2;
  reg                         [1:0] ls_size_wr;
  reg                         [1:0] ls_elem_size_wr;
  reg   [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_iss;
  reg   [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_ex1;
  reg   [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_ex2;
  reg   [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_wr;
  reg                               ls_isv_set_iss;
  reg                               ls_isv_set_ex1;
  reg                               ls_isv_set_ex2;
  reg                               ls_isv_set_wr;
  reg                               ls_synd_sf_iss;
  reg                               ls_synd_sf_ex1;
  reg                               ls_synd_sf_ex2;
  reg                               ls_synd_sf_wr;
  reg                         [4:0] ls_synd_srt_iss;
  reg                         [4:0] ls_synd_srt_ex1;
  reg                         [4:0] ls_synd_srt_ex2;
  reg                         [4:0] ls_synd_srt_wr;
  reg                               ls_check_stack_iss;
  reg                               enable_base_restore_iss;
  reg                               cp_op_ats1_iss;
  reg                               cp_other_sec_iss;
  reg                               req_strict_algn_iss;
  reg                               check_x64_iss;
  reg                         [2:0] algn_size_iss;
  reg                        [63:0] v_addr_ex1;
  reg                        [63:0] va_dc1;
  reg                               trans_iss_last_cycle;
  reg                               extra_lsm_cycle;
  reg                               lsm_skidding;
  reg                               inter_lsm_skidding;
  reg                               cc_fail_wr;
  reg                               dpu_ready_wr;
  reg                               dpu_ready_cc_fail_wr;
  reg                               dpu_ready_cc_pass_wr;
  reg                         [7:1] nxt_skid_strobe_wr;
  reg                         [7:1] skid_strobe_wr;
  reg                        [63:8] skid_data_wr;
  reg                               align_64_dc1;
  reg                               align_128_dc1;
  reg                        [32:0] imm_data_ls_iss;
  reg                               slot1_ls_iss;
  reg                               align_512_ex1;
  reg                               aarch64_state_iss;
  reg                               agu_aa64_addr_iss;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                              unaligned_ex2;
  wire                              dpu_valid_iss;
  wire                              dpu_valid_cp_iss;
  wire                       [63:0] va_iss;
  wire                              dcu_not_ready_iss;
  wire                              first_x64_iss;
  wire                       [63:0] fwd_addr;
  wire                       [63:0] fwd_ld_data_agu_wr;
  wire                              nxt_ls_valid_iss;
  wire                              ls_valid_iss_en;
  wire                              advance_wr;
  wire                              ls_valid_wr_en;
  wire                              nxt_ls_valid_ex1;
  wire                              nxt_ls_valid_ex2;
  wire                              nxt_ls_valid_wr;
  wire                              nxt_first_x64_ex1;
  wire                              nxt_first_x64_ex2;
  wire                              nxt_first_x64_wr;
  wire                              nxt_use_x64_skid_buffer_ex1;
  wire                              nxt_use_x64_skid_buffer_ex2;
  wire                              nxt_cc_fail_wr;
  wire                              ls_stalled_in_wr;
  wire                              nxt_dpu_ready_wr;
  wire                              nxt_dpu_ready_cc_fail_wr;
  wire                              nxt_dpu_ready_cc_pass_wr;
  wire                              en_addr_ex1;
  wire                              en_ls_wr;
  wire                              en_ls_isv_wr;
  wire                              en_ls_iss;
  wire                              en_ls_isv_iss;
  wire                              en_ls_ex1;
  wire                              en_ls_isv_ex1;
  wire                              en_ls_ex2;
  wire                              en_ls_isv_ex2;
  wire                              ls_stall_wr;
  wire                              ls_sign_ext_wr;
  wire                              ls_multiple_iss;
  wire                        [4:0] dpu_length_iss;
  wire                              on_64b_boundary_iss;
  wire                              ls_real_first_iss;
  wire                              clean_dcu_ready_iss;
  wire                              clean_dcu_ready_cp_iss;
  wire      [`CA53_SEL_DCU_A_W-1:0] nxt_agu_data_a_sel_iss;
  wire      [`CA53_SEL_DCU_A_W-1:0] nxt_agu_data_a_hi_sel_iss;
  wire      [`CA53_SEL_DCU_B_W-1:0] nxt_agu_data_b_sel_iss;
  wire                        [2:0] nxt_agu_shf_value_iss;
  wire                              nxt_agu_sub_b_iss;
  wire                              nxt_force_first_iss;
  wire                              en_ri_ctl_iss;
  wire                              en_ls_length;
  wire                              nxt_second_x64_iss;
  wire                              nxt_ls_real_valid_iss;
  wire                              en_ls_real_valid_iss;
  wire                              dpu_utlb_hit_dc1;
  wire                              excl_iss;
  wire                              ldar_stlr_iss;
  wire                              non_temporal_iss;
  wire                              pld_iss;
  wire                              pld_wr;
  wire                              pld_level_iss;
  wire                              dczva_iss;
  wire                              align_512_iss;
  wire                              evnt_not_a_load_or_store;
  wire                              evnt_ls_instr_valid;
  wire                              reissue_mux_ctl;
  wire                              agu_aa64_addr_de;
  wire                              lsm_unaligned64_iss;
  wire                              nxt_trans_iss_last_cycle;
  wire                              force_extra_lsm_cycle;
  wire                              nxt_extra_lsm_cycle;
  wire                              first_lsm_skidding;
  wire                              last_lsm_skidding;
  wire                              nxt_lsm_skidding;
  wire                              nxt_lsm_64b_be_skidding;
  wire                              nxt_lsm_n64b_be_skidding;
  wire                              nxt_inter_lsm_skidding;
  wire                              lsm_64b_be;
  wire                              en_skidding_iss;
  wire                        [5:0] nxt_ls_length_iss;
  wire                        [1:0] nxt_ls_elem_size_ex1;
  wire                              va_dc1_en;
  wire                        [7:1] skid_en_wr;
  wire                       [63:0] skid_data_mask_wr;
  wire                       [63:0] skidded_data_wr;
  wire                              last_x64_iss;
  wire                              align_64_iss;
  wire                              align_128_iss;
  wire                              nxt_subseq_x64_iss;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // AGU
  // ------------------------------------------------------

  ca53dpu_agu u_agu (
    // Inputs
    .clk                         (clk),
    .reset_n                     (reset_n),
    .DFTSE                       (DFTSE),
    .aarch64_state_iss_i         (aarch64_state_iss),
    .agu_aa64_addr_iss_i         (agu_aa64_addr_iss),
    .agu_data_a_sel_iss_i        (agu_data_a_sel_iss[`CA53_SEL_DCU_A_W-1:0]),
    .agu_data_a_hi_sel_iss_i     (agu_data_a_hi_sel_iss[`CA53_SEL_DCU_A_W-1:0]),
    .sel_fwd_dcu_a_iss_i         (sel_fwd_dcu_a_iss_i[`CA53_SEL_FWD_DCU_W-1:0]),
    .sel_fwd_addr_dcu_a_iss_i    (sel_fwd_addr_dcu_a_iss_i),
    .rf_rd_data_r0_agu_iss_i     (rf_rd_data_r0_agu_iss_i[63:0]),
    .rf_rd_data_r1_agu_iss_i     (rf_rd_data_r1_agu_iss_i[63:0]),
    .pc_instr0_iss_i             (pc_instr0_iss_i[63:1]),
    .pc_instr1_iss_i             (pc_instr1_iss_i[48:1]),
    .wd_align_pc_ls_iss_i        (wd_align_pc_ls_iss_i),
    .pg_align_pc_ls_iss_i        (pg_align_pc_ls_iss_i),
    .agu_data_b_sel_iss_i        (agu_data_b_sel_iss[`CA53_SEL_DCU_B_W-1:0]),
    .sel_fwd_dcu_b_iss_i         (sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_W-1:0]),
    .imm_data_ls_iss_i           (imm_data_ls_iss[32:0]),
    .slot1_ls_iss_i              (slot1_ls_iss),
    .fwd_ld_data_agu_wr_i        (fwd_ld_data_agu_wr[63:0]),
    .alu0_fwd_data_early_ex2_i   (alu0_fwd_data_early_ex2_i[63:0]),
    .alu1_fwd_data_early_ex2_i   (alu1_fwd_data_early_ex2_i[63:0]),
    .alu0_fwd_data_early_wr_i    (alu0_fwd_data_early_wr_i[63:0]),
    .alu1_fwd_data_early_wr_i    (alu1_fwd_data_early_wr_i[63:0]),
    .agu_shf_value_iss_i         (agu_shf_value_iss[2:0]),
    .agu_sub_b_iss_i             (agu_sub_b_iss),
    .ls_valid_iss_i              (ls_valid_iss),
    .ls_valid_fwd_iss_i          (ls_valid_fwd_iss),
    .ls_store_iss_i              (ls_store_iss),
    .ls_size_iss_i               (ls_size_iss[2:0]),
    .ls_elem_size_iss_i          (ls_elem_size_iss[2:0]),
    .check_x64_iss_i             (check_x64_iss),
    .fwd_addr_i                  (fwd_addr[63:0]),
    .ls_multiple_iss_i           (ls_multiple_iss),
    .ls_length_iss_i             (ls_length_iss[5:0]),
    .lsm_skidding_i              (lsm_skidding),
    .dczva_iss_i                 (dczva_iss),
    .dpu_valid_iss_i             (dpu_valid_iss),
    .flush_ls_wr_i               (flush_ls_wr_i),
    .dcu_ready_iss_i             (dcu_ready_iss_i),
    .clean_dcu_ready_iss_i       (clean_dcu_ready_iss),
    .subseq_x64_iss_i            (subseq_x64_iss),
    .last_x64_iss_i              (last_x64_iss),
    .ls_check_stack_iss_i        (ls_check_stack_iss),
    .head_instr_ls_iss_i         (head_instr_ls_iss_i),
    .cp_op_ats1_iss_i            (cp_op_ats1_iss),
    .ldar_stlr_iss_i             (ldar_stlr_iss),
    .cp_iss_i                    (cp_iss),
    .cp_other_sec_iss_i          (cp_other_sec_iss),
    .tlb_d_utlb_enable_i         (tlb_d_utlb_enable_i),
    .tlb_d_utlb_might_enable_i   (tlb_d_utlb_might_enable_i),
    .tlb_d_utlb_valid_i          (tlb_d_utlb_valid_i),
    .tlb_d_utlb_lpae_i           (tlb_d_utlb_lpae_i),
    .tlb_d_utlb_data_i           (tlb_d_utlb_data_i[95:0]),
    .tlb_d_utlb_flush_i          (tlb_d_utlb_flush_i),
    .tlb_lpae_mode_i             (tlb_lpae_mode_i),
    .dpu_dacr_i                  (dpu_dacr_i),
    .dpu_dacr_ns_i               (dpu_dacr_ns_i),
    .dpu_default_cacheable_i     (dpu_default_cacheable_i),
    .dpu_dacr_mmu_on_i           (dpu_dacr_mmu_on_i),
    .dpu_mmu_on_el1_i            (dpu_mmu_on_el1_i),
    .flush_d_utlb_i              (flush_d_utlb_i),
    .ns_state_i                  (ns_state_i),
    .dpu_exception_level_i       (dpu_exception_level_i),
    // Outputs                 
    .dpu_agu_a_operand_iss_o     (dpu_agu_a_operand_iss_o),
    .dpu_agu_b_operand_iss_o     (dpu_agu_b_operand_iss_o),
    .dpu_agu_carry_out_64b_iss_o (dpu_agu_carry_out_64b_iss_o),
    .va_iss_o                    (va_iss[63:0]),
    .align_64_iss_o              (align_64_iss),
    .align_128_iss_o             (align_128_iss),
    .first_x64_iss_o             (first_x64_iss),
    .lsm_unaligned64_iss_o       (lsm_unaligned64_iss),
    .ldr_no_early_fwd_iss_o      (ldr_no_early_fwd_iss_o),
    .on_64b_boundary_iss_o       (on_64b_boundary_iss),
    .dpu_strobe_iss_o            (dpu_strobe_iss_o[15:0]),
    .dpu_utlb_hit_dc1_o          (dpu_utlb_hit_dc1),
    .dpu_utlb_hit_entry_dc1_o    (dpu_utlb_hit_entry_dc1_o),
    .dpu_pa_dc1_o                (dpu_pa_dc1_o[39:12]),
    .dpu_attributes_dc1_o        (dpu_attributes_dc1_o[12:0]),
    .dpu_fault_dc1_o             (dpu_fault_dc1_o[8:0]),
    .dpu_ns_dsc_dc1_o            (dpu_ns_dsc_dc1_o),
    .dpu_domain_dc1_o            (dpu_domain_dc1_o),
    .dpu_abort_dc1_o             (dpu_abort_dc1_o),
    .dpu_level_dc1_o             (dpu_level_dc1_o),
    .dpu_lpae_dc1_o              (dpu_lpae_dc1_o),
    .dpu_stack_align_expt_dc1_o  (dpu_stack_align_expt_dc1_o)
  );

  // ------------------------------------------------------
  // LSM Skidding
  // ------------------------------------------------------

  // Mis-aligned Integer LSMs
  //
  // The integer skidding decode table is useful for some of the logic below:
  //
  // ls_length_iss | lsm_skidding | last_lsm_skidding | Condition if skidding
  //               |              |                   |
  // 6'b000_000    | -            | -                 | Not Possible
  // 6'b000_001    | CLEAR        | SET               | Final LSM cycle
  // 6'b000_010    | SET          | CLEAR             | Penultimate - need extra LSM cycle
  // 6'b000_011    | SET          | CLEAR             | Penultimate - no extra LSM cycle needed
  // 6'b000_100 =< | SET          | CLEAR             | -

  // We skid a multiple if we are transfering more than one register and we are not 64-bit aligned.
  // This signal is valid in the first issue cycle of an LSM.
  assign first_lsm_skidding = ls_valid_iss & (ls_length_iss[5:0] != 6'b000001) & lsm_unaligned64_iss;

  // Create a skidding signal that is set on all cycles except the first cycle which can be registered
  // and used elsewhere with minimal timing impact
  assign nxt_lsm_skidding = (first_lsm_skidding | lsm_skidding) & ~last_lsm_skidding & ~flush_wr_i;

  // Augment the skidding signal with an indicator for FPU or Neon instructions that have a 64-bit
  // element size and big-endian mode since register skidding must be controlled differently
  assign lsm_64b_be               = spec_endianness_iss_i & (ls_elem_size_iss == `CA53_LS_ELEM_SIZE_64BIT);
  assign nxt_lsm_64b_be_skidding  = nxt_lsm_skidding &  lsm_64b_be;
  assign nxt_lsm_n64b_be_skidding = nxt_lsm_skidding & ~lsm_64b_be;

  // Create a skidding signal that is set on all cycles except the first cycle and the last cycle which
  // can be registered and used elsewhere with minimal timing impact
  assign nxt_inter_lsm_skidding = (first_lsm_skidding | lsm_skidding) & (ls_length_iss[5:2] != 4'b0000) & ~flush_wr_i;

  // It is the last cycle of a skidding LSM providing the bits above the first are not set.
  // The signal will not be asserted if it only skids for one cycle (i.e. unaligned LSM of two registers)
  assign last_lsm_skidding = lsm_skidding & (ls_length_iss[5:1] == 5'b00000);

  // If we are skidding and the length value produced by the decoder indicates that there are two
  // registers remaining, then really three registers are left to be transferred and an extra
  // cycle will be required.  To enable this the pipeline must be stalled.
  assign force_extra_lsm_cycle = ls_valid_iss & (ls_length_iss[5:0] == 6'b000010) & (lsm_unaligned64_iss | lsm_skidding);
  assign nxt_extra_lsm_cycle   = force_extra_lsm_cycle & ~flush_wr_i;

  // Indicate when a big-endian 128b element is being accessed, to allow control logic
  // to swizzle the register accesses
  assign ls_128b_be_o = ls_valid_iss & spec_endianness_iss_i & ls_elem_size_iss[2];

  // ------------------------------------------------------
  // Re-issue logic
  // ------------------------------------------------------

  // The AGU needs to reissue skidding LSMs and cross-64
  assign reissue_mux_ctl = first_lsm_skidding | inter_lsm_skidding | first_x64_iss;

  // Force AGU A operand to be 32-bit when in AA32 state or in AA64 state but
  // doing an AT instruction for an exception level using AA32.
  assign agu_aa64_addr_de = aarch64_state_i & 
                            ~(cp_de_i & ((((cp_op_de_i == `CA53_CPOP_ATS1E01) | 
                                           (cp_op_de_i == `CA53_CPOP_ATS12E01)) & ~aarch64_at_el_i[1]) |
                                         ( (cp_op_de_i == `CA53_CPOP_ATS1E2)    & ~aarch64_at_el_i[2])));

  // Mux between the original control signals and the new, re-issue control
  // signals. If we are in the first skidding cycle then we must add 4 using the
  // same path as cross-64, if we are in subsequent skidding cycles we must add
  // 8.
  assign nxt_agu_shf_value_iss     = {3{~reissue_mux_ctl}}  & agu_shf_value_de_i;
  assign nxt_agu_sub_b_iss         =    ~reissue_mux_ctl    & agu_sub_b_de_i;
  assign nxt_agu_data_a_sel_iss    =     reissue_mux_ctl    ? `CA53_SEL_DCU_A_MUL  : 
                                                              agu_data_a_sel_de_i;
  assign nxt_agu_data_a_hi_sel_iss =     reissue_mux_ctl    ? `CA53_SEL_DCU_A_MUL  : 
                                        ~agu_aa64_addr_de   ? `CA53_SEL_DCU_A_ZERO : 
                                                              agu_data_a_sel_de_i;
  assign nxt_agu_data_b_sel_iss    = (                first_lsm_skidding) ? `CA53_SEL_DCU_B_4 :
                                     (first_x64_iss | inter_lsm_skidding) ? `CA53_SEL_DCU_B_8 : 
                                                                            agu_data_b_sel_de_i;
  assign nxt_ls_length_iss         = force_extra_lsm_cycle ? 6'b000_000 : ls_length_de_i;

  // If the first beat of a load instruction has issued to the DCU while stalled,
  // and the load was conditional (and used the opposite condition code cancelling
  // logic), the the address previously issued could be incorrect, so force "first"
  // on the next DCU transaction, as the cache-line crossing logic will not pick up
  // on this case.
  
  assign nxt_force_first_iss = ls_valid_iss & ~ls_real_valid_iss & ls_conditional_iss_i & ~ls_store_iss;

  // ------------------------------------------------------
  // Iss stage control logic
  // ------------------------------------------------------

  // "Real" first is the first transaction of an instruction.
  // - Should be suppressed on the second cycle of a cross-64
  // - Should be suppressed on subsequent beats of LSM or LDP/STP
  assign ls_real_first_iss = head_instr_ls_iss_i | (~skid_x64_multiple_iss & ~ls_multiple_iss & ~dczva_iss & ~second_x64_iss);

  // The DCU will continue to indicate dcu_ready_iss in the cycle that a micro-TLB miss occurs.
  // Therefore the DPU must suppress the dcu_ready_iss signal in this cycle to prevent a
  // trailing load-store transaction being issued to the DCU by mistake.
  //
  // Note that the logic creates a performance degradation on a cc failed LSM that has missed the
  // uTLB as every request in the LSM will miss the uTLB which will result in a bubble cycle being
  // inserted.  Non-multiple load-store instructions will not be affected as it is not known in
  // advance if they have cc failed (the condition code cancelling logic only covers Ex1/2).
  assign clean_dcu_ready_iss    = dpu_utlb_hit_dc1 ? dcu_ready_iss_i    : (dcu_ready_iss_i    & ~trans_iss_last_cycle);
  assign clean_dcu_ready_cp_iss = dpu_utlb_hit_dc1 ? dcu_ready_cp_iss_i : (dcu_ready_cp_iss_i & ~trans_iss_last_cycle);

  // Stall de-iss advance if the DCU can not accept a new transaction or if there was a micro-TLB
  // miss and there is another transaction wanting to be issued.
  assign dcu_not_ready_iss = ((ls_real_valid_iss & trans_iss_last_cycle       & ~dpu_utlb_hit_dc1) |
                              (ls_real_valid_iss & (~cp_iss |  cp_op_mva_iss) & ~dcu_ready_iss_i)  |
                              (ls_real_valid_iss & ( cp_iss & ~cp_op_mva_iss) & ~dcu_ready_cp_iss_i));

  // Expand control signals out from ls_instr_type_iss
  assign ls_multiple_iss     = (ls_instr_type_iss == `CA53_LS_INSTR_MULTIPLE);
  assign excl_iss            = (ls_instr_type_iss == `CA53_LS_INSTR_EXCL_SGL) |
                               (ls_instr_type_iss == `CA53_LS_INSTR_ORD_EXCL_SGL);
  assign ldar_stlr_iss       = (ls_instr_type_iss == `CA53_LS_INSTR_ORDERED) |
                               (ls_instr_type_iss == `CA53_LS_INSTR_ORD_EXCL_SGL);
  assign non_temporal_iss    = (ls_instr_type_iss == `CA53_LS_INSTR_NON_TEMPORAL) |
                               (ls_instr_type_iss == `CA53_LS_INSTR_PLD_L1STRM) |
                               (ls_instr_type_iss == `CA53_LS_INSTR_PLD_L2STRM);
  assign pld_iss             = (ls_instr_type_iss == `CA53_LS_INSTR_PLD_L1KEEP) |
                               (ls_instr_type_iss == `CA53_LS_INSTR_PLD_L1STRM) |
                               (ls_instr_type_iss == `CA53_LS_INSTR_PLD_L2KEEP) |
                               (ls_instr_type_iss == `CA53_LS_INSTR_PLD_L2STRM);
  assign pld_level_iss       = (ls_instr_type_iss == `CA53_LS_INSTR_PLD_L2KEEP) |
                               (ls_instr_type_iss == `CA53_LS_INSTR_PLD_L2STRM);
  assign dczva_iss           = (ls_instr_type_iss == `CA53_LS_INSTR_DCZVA);

  // When an extra Load-Store multiple cycle has been added because of skidding length will have been
  // set to zero.  In all other skidding cycles the decoder is one ahead so we don't need to subtract 1
  assign dpu_length_iss = lsm_skidding ? ls_length_iss[4:0] : ls_length_iss[4:0] - 5'b00001;

  assign dpu_cross_64_iss_o = first_x64_iss | second_x64_iss;

  assign dpu_burst_iss_o = cp_iss ? ldar_stlr_iss // Only CP op burst is barrier part of STLR
                                  : (first_x64_iss | (subseq_x64_iss & ~last_x64_iss) |
                                     first_lsm_skidding |
                                     (((ls_instr_type_iss == `CA53_LS_INSTR_MULTIPLE) | ~ls_store_iss) ? // Loads/STMs do up to 64-bits/cycle
                                                                                                       ((dpu_length_iss[4:1] != 4'b0000) | (dpu_length_iss[0] & lsm_skidding))
                                                                                                     : // Stores do up to 128-bits/cycle
                                                                                                       (dpu_length_iss[4:2] != 3'b000)));

  assign dpu_req_align_iss_o = (ls_multiple_iss | req_strict_algn_iss | sctlr_align_check_i) &
                               ~pld_iss & ~(cp_iss & ~cp_op_mva_iss) & ~dczva_iss;

  assign dpu_first_iss_o = ls_real_first_iss | on_64b_boundary_iss;

  assign dpu_force_first_iss_o = force_first_iss;
  
  assign dpu_neon_access_iss_o = slot1_ls_iss ? neon_instr_iss_i[1] : neon_instr_iss_i[0];

  // ------------------------------------------------------
  // Base restore
  // ------------------------------------------------------
  //
  // The base register of a load needs to be restored if we take an exception part way
  // through the instruction.  This is only of concern for LDM as all other loads have
  // single cycle register file update
  assign enable_base_restore_iss_o = ls_valid_iss &
                                     enable_base_restore_iss &
                                     ~(dcu_not_ready_iss & head_instr_ls_iss_i);

  // ------------------------------------------------------
  // Pipeline
  // ------------------------------------------------------

  // Valid external signal propagation
  assign dpu_valid_iss    = ls_real_valid_iss & ~interlock_iss_i & (~cp_iss | cp_op_mva_iss);
  assign dpu_valid_cp_iss = ~interlock_iss_i & cp_iss & ls_real_valid_iss;

  // This more complex signal is required to create an indication for the case
  // where we issue into the DCU while the DPU is stalled
  assign nxt_ls_real_valid_iss = ilock_stall_iss_i ?
                                 ((ls_real_valid_iss & ~flush_wr_i & (interlock_iss_i | ~clean_dcu_ready_iss)    & (~cp_iss |  cp_op_mva_iss)) |
                                  (ls_real_valid_iss & ~flush_wr_i & (interlock_iss_i | ~clean_dcu_ready_cp_iss) & ( cp_iss & ~cp_op_mva_iss)))
                               : ((ls_valid_de_i | first_x64_iss | force_extra_lsm_cycle) & ~flush_wr_i);

  assign en_ls_real_valid_iss = ~ilock_stall_iss_i | flush_wr_i | clean_dcu_ready_iss | (clean_dcu_ready_cp_iss & cp_iss & ~cp_op_mva_iss);

  // Enable the skidding registers
  assign en_skidding_iss = ((first_lsm_skidding | lsm_skidding) & ~ilock_stall_iss_i) | flush_wr_i;

  // Enable the reissue registers
  assign en_ri_ctl_iss = (ls_valid_de_i | reissue_mux_ctl) & ~ilock_stall_iss_i;

  // Enable the length registers
  assign en_ls_length = (ls_valid_de_i & ~stall_iss_i) | (force_extra_lsm_cycle & ~ilock_stall_iss_i);

  // Valid internal signal propagation
  assign nxt_ls_valid_iss = ls_valid_de_i & ~flush_wr_i;
  assign nxt_ls_valid_ex1 = ls_valid_iss  & ~flush_wr_i & ~ilock_stall_iss_i;
  assign nxt_ls_valid_ex2 = ls_valid_ex1  & ~flush_wr_i;
  assign nxt_ls_valid_wr  = ls_valid_ex2  & ~flush_wr_i;

  // First/subseq part of x64 operation pipelining
  assign nxt_first_x64_ex1  = first_x64_iss & ~flush_wr_i & ~ilock_stall_iss_i;
  assign nxt_first_x64_ex2  = first_x64_ex1 & ~flush_wr_i;
  assign nxt_first_x64_wr   = first_x64_ex2 & ~flush_wr_i;

  assign nxt_use_x64_skid_buffer_ex1 = skid_x64_multiple_iss & (first_x64_iss | subseq_x64_iss) & ~flush_wr_i & ~ilock_stall_iss_i;
  assign nxt_use_x64_skid_buffer_ex2 = use_x64_skid_buffer_ex1 & ~flush_wr_i;

  // DPU-DCU valid and CC-Pass signals
  assign nxt_cc_fail_wr = ~(slot1_ls_ex2_i ? cc_pass_instr1_ex2_i : cc_pass_instr0_ex2_i);

  assign ls_stalled_in_wr = stall_wr_i & ~flush_ret_i & ~slot0_br_flush_wr_i;

  assign nxt_dpu_ready_wr         = ls_stalled_in_wr ? (    ls_valid_wr & ~nxt_div_stall_wr_i)
                                                     : (nxt_ls_valid_wr & ~nxt_div_stall_wr_i);
  assign nxt_dpu_ready_cc_fail_wr = ls_stalled_in_wr ? (    ls_valid_wr & ~nxt_div_stall_wr_i &      cc_fail_wr)
                                                     : (nxt_ls_valid_wr & ~nxt_div_stall_wr_i &  nxt_cc_fail_wr);
  assign nxt_dpu_ready_cc_pass_wr = ls_stalled_in_wr ? (    ls_valid_wr & ~nxt_div_stall_wr_i &     ~cc_fail_wr)
                                                     : (nxt_ls_valid_wr & ~nxt_div_stall_wr_i & ~nxt_cc_fail_wr);

  // ------------------------------------------------------
  // Pipeline registers De -> Iss
  // ------------------------------------------------------

  assign ls_valid_iss_en = ~stall_iss_i | flush_wr_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ls_valid_iss            <= 1'b0;
      ls_valid_fwd_iss        <= 1'b1;
      enable_base_restore_iss <= 1'b0;
    end else if (ls_valid_iss_en) begin
      ls_valid_iss            <= nxt_ls_valid_iss;
      ls_valid_fwd_iss        <= nxt_ls_valid_iss;
      enable_base_restore_iss <= enable_base_restore_de_i;
    end

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      lsm_skidding         <= 1'b0;
      inter_lsm_skidding   <= 1'b0;
      extra_lsm_cycle      <= 1'b0;
    end else if (en_skidding_iss) begin
      lsm_skidding         <= nxt_lsm_skidding;
      inter_lsm_skidding   <= nxt_inter_lsm_skidding;
      extra_lsm_cycle      <= nxt_extra_lsm_cycle;
    end

  // The following skidding registers are specific to FPU/NEON configurations
generate if (NEON_FP) begin : FPU1
  reg lsm_64b_be_skidding;
  reg lsm_n64b_be_skidding;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      lsm_64b_be_skidding  <= 1'b0;
      lsm_n64b_be_skidding <= 1'b0;
    end else if (en_skidding_iss) begin
      lsm_64b_be_skidding  <= nxt_lsm_64b_be_skidding;
      lsm_n64b_be_skidding <= nxt_lsm_n64b_be_skidding;
    end

  assign lsm_64b_be_skidding_o  = lsm_64b_be_skidding;
  assign lsm_n64b_be_skidding_o = lsm_n64b_be_skidding;
end else begin : FPU1_STUBS
  assign lsm_64b_be_skidding_o  = 1'b0;
  assign lsm_n64b_be_skidding_o = 1'b0;
end endgenerate

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ls_real_valid_iss <= 1'b0;
    else if (en_ls_real_valid_iss)
      ls_real_valid_iss <= nxt_ls_real_valid_iss;

  assign nxt_trans_iss_last_cycle = clean_dcu_ready_iss & dpu_valid_iss & ~flush_wr_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      trans_iss_last_cycle <= 1'b0;
    else
      trans_iss_last_cycle <= nxt_trans_iss_last_cycle;

  // The following registers are for signals that change over a re-issue and
  // therefore must be re-registered
  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      agu_shf_value_iss     <= 3'b000;
      agu_data_a_sel_iss    <= {`CA53_SEL_DCU_A_W{1'b0}};
      agu_data_a_hi_sel_iss <= {`CA53_SEL_DCU_A_W{1'b0}};
      agu_data_b_sel_iss    <= {`CA53_SEL_DCU_B_W{1'b0}};
      agu_sub_b_iss         <= 1'b0;
      force_first_iss       <= 1'b0;
    end
    else if (en_ri_ctl_iss) begin
      agu_shf_value_iss     <= nxt_agu_shf_value_iss;
      agu_data_a_sel_iss    <= nxt_agu_data_a_sel_iss;
      agu_data_a_hi_sel_iss <= nxt_agu_data_a_hi_sel_iss;
      agu_data_b_sel_iss    <= nxt_agu_data_b_sel_iss;
      agu_sub_b_iss         <= nxt_agu_sub_b_iss;
      force_first_iss       <= nxt_force_first_iss;
    end

  // The length register is updated from De or an extra LSM cycle
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ls_length_iss <= 6'b000_001;
    else if (en_ls_length)
      ls_length_iss <= nxt_ls_length_iss;

  // The following registers are for signals that do not change over a re-issue,
  // and can therefore simply be held
  assign en_ls_iss = ls_valid_de_i & ~stall_iss_i;

  always @(posedge clk)
    if (en_ls_iss) begin
      ls_store_iss           <= ls_store_de_i;
      ls_store_neon_iss      <= ls_store_neon_de_i;
      ls_size_iss            <= ls_size_de_i;
      ls_elem_size_iss       <= ls_elem_size_de_i;
      ls_instr_type_iss      <= ls_instr_type_de_i;
      ls_isv_set_iss         <= ls_isv_set_de_i;
      ls_check_stack_iss     <= ls_check_stack_de_i;
      cp_iss                 <= cp_de_i;
      cp_op_iss              <= cp_op_de_i;
      cp_op_mva_iss          <= cp_op_mva_de_i;
      cp_op_ats1_iss         <= cp_op_ats1_de_i;
      cp_other_sec_iss       <= cp_other_sec_de_i;
      force_usr_priv_mem_iss <= force_usr_priv_mem_de_i;
      req_strict_algn_iss    <= req_strict_algn_de_i;
      check_x64_iss          <= check_x64_de_i;
      algn_size_iss          <= algn_size_de_i;
      skid_x64_multiple_iss  <= skid_x64_multiple_de_i;
      agu_aa64_addr_iss      <= agu_aa64_addr_de;
    end

  always @(posedge clk)
    if (en_ls_iss) begin
      imm_data_ls_iss   <= imm_data_ls_de_i;
      slot1_ls_iss      <= slot1_ls_de_i;
      aarch64_state_iss <= aarch64_state_i;
    end

  // Signals for fault information on load/stores which set ISV bit in ESR
  // (only enable if instruction will set ISV bit)
  assign en_ls_isv_iss = en_ls_iss & ls_isv_set_de_i;

  always @(posedge clk)
    if (en_ls_isv_iss) begin
      ls_synd_sf_iss  <= ls_synd_sf_de_i;
      ls_synd_srt_iss <= ls_synd_srt_de_i;
    end

  // ------------------------------------------------------
  // Cross-64 register (detect subsequent transations)
  // ------------------------------------------------------

  assign nxt_second_x64_iss = ilock_stall_iss_i ? (second_x64_iss & ~flush_ret_i)
                                                : (first_x64_iss  & ~flush_ret_i);

  assign nxt_subseq_x64_iss = ilock_stall_iss_i ? (subseq_x64_iss                                     & ~flush_wr_i)
                                                : ((first_x64_iss | (subseq_x64_iss & ~last_x64_iss)) & ~flush_wr_i);

  assign advance_wr = ~stall_wr_i | flush_wr_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      second_x64_iss <= 1'b0;
      subseq_x64_iss <= 1'b0;
    end else if (advance_wr) begin
      second_x64_iss <= nxt_second_x64_iss;
      subseq_x64_iss <= nxt_subseq_x64_iss;
    end

  // Detect last beat of x64/128 burst. This will typically be the
  // second beat, but can be later when skidding a multiple (e.g.
  // on LDP/STP). Note AA32 LSMs never go x64, so they can be
  // ignored in this case
  assign last_x64_iss = subseq_x64_iss & (ls_size_iss[2] ? (ls_length_iss <= 6'd4) : (ls_length_iss <= 6'd2));

  // ------------------------------------------------------
  // Pipeline registers Iss -> Ex1
  // ------------------------------------------------------

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ls_valid_ex1            <= 1'b0;
      first_x64_ex1           <= 1'b0;
      use_x64_skid_buffer_ex1 <= 1'b0;
    end else if (advance_wr) begin
      ls_valid_ex1            <= nxt_ls_valid_ex1;
      first_x64_ex1           <= nxt_first_x64_ex1;
      use_x64_skid_buffer_ex1 <= nxt_use_x64_skid_buffer_ex1;
    end

  // Virtual address for every calculation in the AGU that is sent to the DCU.
  assign va_dc1_en = dpu_valid_iss & ~flush_ls_wr_i & clean_dcu_ready_iss;

  always @(posedge clk)
    if (va_dc1_en) begin
      align_64_dc1  <= align_64_iss;
      align_128_dc1 <= align_128_iss;
      va_dc1[63:0]  <= va_iss[63:0];
    end

  // Virtual address from the first calculation in the AGU.  If the calculation is x64
  // this register retains the original result for forwarding and for the swizzle logic.
  assign en_addr_ex1 = ls_valid_iss & ~ilock_stall_iss_i & (~second_x64_iss | skid_x64_multiple_iss);

  assign align_512_iss = dczva_iss & head_instr_ls_iss_i;

  always @(posedge clk)
    if (en_addr_ex1) begin
      v_addr_ex1[63:0] <= va_iss[63:0];
      align_512_ex1    <= align_512_iss;
    end

  // Internal address update forwarding path
  // - align on DCZVA first so get correct address on subsequent beats
  assign fwd_addr   = {v_addr_ex1[63:6], v_addr_ex1[5:0] & {6{~align_512_ex1}}};  // DCZVA not D1 dual issueable

  // Compress the element size, as 128-bit is handled in issue
  assign nxt_ls_elem_size_ex1 = {2{ls_elem_size_iss == `CA53_LS_ELEM_SIZE_128BIT}} | ls_elem_size_iss[1:0];

  assign en_ls_ex1 = ls_valid_iss & ~stall_wr_i;

  always @(posedge clk)
    if (en_ls_ex1) begin
      ls_size_ex1        <= ls_size_iss[1:0];
      ls_elem_size_ex1   <= nxt_ls_elem_size_ex1;
      ls_store_ex1       <= ls_store_iss;
      ls_store_neon_ex1  <= ls_store_neon_iss;
      ls_instr_type_ex1  <= ls_instr_type_iss;
      ls_isv_set_ex1     <= ls_isv_set_iss;
    end

  // Signals for fault information on load/stores which set ISV bit in ESR
  // (only enable if instruction will set ISV bit)
  assign en_ls_isv_ex1 = en_ls_ex1 & ls_isv_set_iss;

  always @(posedge clk)
    if (en_ls_isv_ex1) begin
      ls_synd_sf_ex1  <= ls_synd_sf_iss;
      ls_synd_srt_ex1 <= ls_synd_srt_iss;
    end

  // ------------------------------------------------------
  // Pipeline registers Ex1 -> Ex2
  // ------------------------------------------------------

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ls_valid_ex2            <= 1'b0;
      first_x64_ex2           <= 1'b0;
      use_x64_skid_buffer_ex2 <= 1'b0;
    end else if (advance_wr) begin
      ls_valid_ex2            <= nxt_ls_valid_ex2;
      first_x64_ex2           <= nxt_first_x64_ex2;
      use_x64_skid_buffer_ex2 <= nxt_use_x64_skid_buffer_ex2;
    end

  assign en_ls_ex2 = ls_valid_ex1 & ~stall_wr_i;

  always @(posedge clk)
    if (en_ls_ex2)
      v_addr_ex2[3:0] <= v_addr_ex1[3:0];

  always @(posedge clk)
    if (en_ls_ex2) begin
      ls_size_ex2        <= ls_size_ex1;
      ls_elem_size_ex2   <= ls_elem_size_ex1;
      ls_store_ex2       <= ls_store_ex1;
      ls_store_neon_ex2  <= ls_store_neon_ex1;
      ls_instr_type_ex2  <= ls_instr_type_ex1;
      ls_isv_set_ex2     <= ls_isv_set_ex1;
    end

  // Signals for fault information on load/stores which set ISV bit in ESR
  // (only enable if instruction will set ISV bit)
  assign en_ls_isv_ex2 = en_ls_ex2 & ls_isv_set_ex1;

  always @(posedge clk)
    if (en_ls_isv_ex2) begin
      ls_synd_sf_ex2  <= ls_synd_sf_ex1;
      ls_synd_srt_ex2 <= ls_synd_srt_ex1;
    end

  // ------------------------------------------------------
  // Pipeline registers Ex2 -> Wr
  // ------------------------------------------------------

  assign ls_valid_wr_en = advance_pipeline_i | slot0_br_flush_wr_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ls_valid_wr             <= 1'b0;
      cc_fail_wr              <= 1'b0;
      first_x64_wr            <= 1'b0;
      skid_strobe_wr          <= {7{1'b0}};
    end else if (ls_valid_wr_en) begin
      ls_valid_wr             <= nxt_ls_valid_wr;
      cc_fail_wr              <= nxt_cc_fail_wr;
      first_x64_wr            <= nxt_first_x64_wr;
      skid_strobe_wr          <= nxt_skid_strobe_wr;
    end

  assign en_ls_wr = ls_valid_ex2 & ~stall_wr_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ls_size_wr        <= 2'b00;
      ls_elem_size_wr   <= 2'b00;
      ls_store_wr       <= 1'b0;
      ls_instr_type_wr  <= {`CA53_LS_INSTR_TYPE_W{1'b0}};
      ls_isv_set_wr     <= 1'b0;
    end else if (en_ls_wr) begin
      ls_size_wr        <= ls_size_ex2;
      ls_elem_size_wr   <= ls_elem_size_ex2;
      ls_store_wr       <= ls_store_ex2;
      ls_instr_type_wr  <= ls_instr_type_ex2;
      ls_isv_set_wr     <= ls_isv_set_ex2;
    end

  assign en_ls_isv_wr = en_ls_wr & ls_isv_set_ex2;

  always @(posedge clk)
    if (en_ls_isv_wr) begin
      ls_synd_sf_wr   <= ls_synd_sf_ex2;
      ls_synd_srt_wr  <= ls_synd_srt_ex2;
    end

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dpu_ready_wr         <= 1'b0;
      dpu_ready_cc_fail_wr <= 1'b0;
      dpu_ready_cc_pass_wr <= 1'b0;
    end else begin
      dpu_ready_wr         <= nxt_dpu_ready_wr;
      dpu_ready_cc_fail_wr <= nxt_dpu_ready_cc_fail_wr;
      dpu_ready_cc_pass_wr <= nxt_dpu_ready_cc_pass_wr;
    end

  // ------------------------------------------------------
  // Wr stage control logic
  // ------------------------------------------------------

  // The Wr stage will be gated if the load/store is ready, but the DCU is not
  assign ls_stall_wr = dpu_ready_cc_pass_wr & ~dcu_valid_dc3_i;

  assign ls_sign_ext_wr = ls_instr_type_wr == `CA53_LS_INSTR_SIGN_EXT;

  // ------------------------------------------------------
  // Skid buffer
  // ------------------------------------------------------
  always @*
    case (v_addr_ex2[2:0] & {3{use_x64_skid_buffer_ex2}})
      3'b000 : nxt_skid_strobe_wr = 7'b0000000;
      3'b001 : nxt_skid_strobe_wr = 7'b1111111;
      3'b010 : nxt_skid_strobe_wr = 7'b1111110;
      3'b011 : nxt_skid_strobe_wr = 7'b1111100;
      3'b100 : nxt_skid_strobe_wr = 7'b1111000;
      3'b101 : nxt_skid_strobe_wr = 7'b1110000;
      3'b110 : nxt_skid_strobe_wr = 7'b1100000;
      3'b111 : nxt_skid_strobe_wr = 7'b1000000;
      default: nxt_skid_strobe_wr = 7'bxxxxxxx;
    endcase

  assign skid_en_wr = {7{dpu_ready_wr & dcu_valid_dc3_i & ~ls_store_wr}} & skid_strobe_wr;

  always @(posedge clk)
    if (skid_en_wr[7])
      skid_data_wr[63:56] <= dcu_ld_data_dc3_i[63:56];

  always @(posedge clk)
    if (skid_en_wr[6])
      skid_data_wr[55:48] <= dcu_ld_data_dc3_i[55:48];

  always @(posedge clk)
    if (skid_en_wr[5])
      skid_data_wr[47:40] <= dcu_ld_data_dc3_i[47:40];

  always @(posedge clk)
    if (skid_en_wr[4])
      skid_data_wr[39:32] <= dcu_ld_data_dc3_i[39:32];

  always @(posedge clk)
    if (skid_en_wr[3])
      skid_data_wr[31:24] <= dcu_ld_data_dc3_i[31:24];

  always @(posedge clk)
    if (skid_en_wr[2])
      skid_data_wr[23:16] <= dcu_ld_data_dc3_i[23:16];

  always @(posedge clk)
    if (skid_en_wr[1])
      skid_data_wr[15: 8] <= dcu_ld_data_dc3_i[15: 8];

  assign skid_data_mask_wr = {{8{skid_strobe_wr[7]}},
                              {8{skid_strobe_wr[6]}},
                              {8{skid_strobe_wr[5]}},
                              {8{skid_strobe_wr[4]}},
                              {8{skid_strobe_wr[3]}},
                              {8{skid_strobe_wr[2]}},
                              {8{skid_strobe_wr[1]}},
                              {8{1'b0}}};

  assign skidded_data_wr = ( skid_data_mask_wr & {skid_data_wr[63:8], 8'h00}) |
                           (~skid_data_mask_wr & dcu_ld_data_dc3_i);

  // ------------------------------------------------------
  // Swizzle logic
  // ------------------------------------------------------
  //
  // Data is returned from the DCU on dcu_ld_data_dc3 in the same format as
  // it was found in memory, and this bus represents an aligned doubleword in
  // memory.  Before it is written to the register file, unaligned data must
  // be rotated into the correct position, and when in BE-8 state (E-bit set)
  // the byte lanes must also be swapped round appropriately.  The following
  // module instantiates the muxes required for this operation; the controls
  // for the swizzler were computed in the ex2-stage.
  ca53dpu_swizzle_load `CA53_DPU_PARAM_INST u_swizzle_load (
    // Inputs
    .clk                    (clk),
    .reset_n                (reset_n),
    .aarch64_state_i        (aarch64_state_i),
    .ls_elem_size_ex2_i     (ls_elem_size_ex2[1:0]),
    .ls_elem_size_wr_i      (ls_elem_size_wr[1:0]),
    .dcu_ld_data_dc3_i      (skidded_data_wr[63:0]),
    .en_ls_wr_i             (en_ls_wr),
    .v_addr_ex2_i           (v_addr_ex2[2:0]),
    .spec_endianness_ex2_i  (spec_endianness_ex2_i),
    .ls_sign_ext_wr_i       (ls_sign_ext_wr),
    // Outputs
    .fwd_ld_data_agu_wr_o   (fwd_ld_data_agu_wr[63:0]),
    .fwd_ld_data_int_wr_o   (fwd_ld_data_int_wr_o[63:0]),
    .ld_data0_wr_o          (ld_data0_wr_o[63:0]),
    .ld_data1_wr_o          (ld_data1_wr_o[63:0])
  );

  // ------------------------------------------------------
  // Event signals
  // ------------------------------------------------------

  // Do not count CP ops 
  assign evnt_not_a_load_or_store = raw_cp_valid_wr_i | (ls_instr_type_wr == `CA53_LS_INSTR_DCZVA);

  // Qualification signal that checks for valid load-store instructions
  assign evnt_ls_instr_valid = ls_valid_wr & ~ls_stall_wr & ~evnt_not_a_load_or_store &
                               evnt_ls_instr_wr_i;

  // Event signals
  assign unaligned_ex2 = ((ls_size_ex2 == `CA53_LDST_SIZE_DWORD) & (|v_addr_ex2[2:0])) |
                         ((ls_size_ex2 == `CA53_LDST_SIZE_WORD)  & (|v_addr_ex2[1:0])) |
                         ((ls_size_ex2 == `CA53_LDST_SIZE_HWORD) & ( v_addr_ex2[0]));

  always @(posedge clk)
    if (en_ls_wr)
      unaligned_wr <= unaligned_ex2;

  // PLD counts as a load (even if it is a PLDW)
  assign pld_wr = (ls_instr_type_wr == `CA53_LS_INSTR_PLD_L1KEEP) |
                  (ls_instr_type_wr == `CA53_LS_INSTR_PLD_L1STRM) |
                  (ls_instr_type_wr == `CA53_LS_INSTR_PLD_L2KEEP) |
                  (ls_instr_type_wr == `CA53_LS_INSTR_PLD_L2STRM);

  assign evnt_data_rd_wr_o      = evnt_ls_instr_valid & ~(ls_store_wr & ~pld_wr);
  assign evnt_data_wr_wr_o      = evnt_ls_instr_valid &  (ls_store_wr & ~pld_wr);
  assign evnt_data_mem_access_o = ls_valid_wr         & ~ls_stall_wr & ~evnt_not_a_load_or_store;
  assign evnt_unaligned_ls_o    = evnt_ls_instr_valid & unaligned_wr;

  // ------------------------------------------------------
  // Aliasing for the output ports
  // ------------------------------------------------------

  assign dcu_not_ready_iss_o        = dcu_not_ready_iss;
  assign agu_data_a_sel_iss_o       = agu_data_a_sel_iss;
  assign agu_data_b_sel_iss_o       = agu_data_b_sel_iss;
  assign first_lsm_skidding_o       = first_lsm_skidding;
  assign lsm_skidding_o             = lsm_skidding;
  assign lsm_64b_be_o               = lsm_64b_be;
  assign inter_lsm_skidding_o       = inter_lsm_skidding;
  assign last_lsm_skidding_o        = last_lsm_skidding;
  assign force_extra_lsm_cycle_o    = force_extra_lsm_cycle;
  assign extra_lsm_cycle_o          = extra_lsm_cycle;
  assign dpu_priv_iss_o             = (dpu_exception_level_i > `CA53_EL0) &
                                      // V2P and LDRT/STRT instructions can force unprivileged:
                                      ~(force_usr_priv_mem_iss & 
                                        // - Forcing always applies on V2P ops
                                        (cp_iss | 
                                        // - and on load/stores in EL1 or AA32 EL3
                                         ( (dpu_exception_level_i == `CA53_EL1) |
                                          ((dpu_exception_level_i == `CA53_EL3) & ~aarch64_at_el_i[3]))));
  assign ls_stall_wr_o              = ls_stall_wr;
  assign v_addr_ex2_o               = v_addr_ex2[3:0];
  assign ls_size_wr_o               = ls_size_wr;
  assign ls_elem_size_ex2_o         = ls_elem_size_ex2;
  assign ls_elem_size_wr_o          = ls_elem_size_wr;
  assign ls_store_ex2_o             = ls_store_ex2;
  assign ls_store_wr_o              = ls_store_wr;
  assign ls_store_neon_ex2_o        = ls_store_neon_ex2;
  assign ls_instr_type_wr_o         = ls_instr_type_wr;
  assign ldc_ex2_o                  = (ls_instr_type_ex2 == `CA53_LS_INSTR_LDC_STC) & ls_valid_ex2 & ~ls_store_ex2;
  assign ldc_stc_wr_o               = (ls_instr_type_wr == `CA53_LS_INSTR_LDC_STC) & ls_valid_wr;
  assign srs_wr_o                   = (ls_instr_type_wr == `CA53_LS_INSTR_SRS) & ls_valid_wr & ls_store_wr;
  assign ls_isv_set_wr_o            = ls_isv_set_wr;
  assign ls_synd_sf_wr_o            = ls_synd_sf_wr;
  assign ls_synd_srt_wr_o           = ls_synd_srt_wr;
  assign ls_valid_iss_o             = ls_valid_iss;
  assign ls_valid_ex1_o             = ls_valid_ex1;
  assign ls_valid_ex2_o             = ls_valid_ex2;
  assign ls_valid_wr_o              = ls_valid_wr;
  assign first_x64_wr_o             = first_x64_wr;
  assign ongoing_ldm_wr_o           = (ls_instr_type_wr == `CA53_LS_INSTR_MULTIPLE) & ~ls_store_wr;
  assign first_x64_iss_o            = first_x64_iss;
  assign second_x64_iss_o           = second_x64_iss;
  assign dpu_va_dc1_o[63:0]         = {va_dc1[63:4], va_dc1[3] & ~align_128_dc1, va_dc1[2:0] & {3{~align_64_dc1}}};
  assign dpu_align_size_iss_o       = algn_size_iss;
  assign ls_multiple_iss_o          = ls_multiple_iss;
  assign ls_store_iss_o             = ls_store_iss;
  assign dpu_excl_iss_o             = excl_iss;
  assign dpu_ldar_stlr_iss_o        = ldar_stlr_iss;
  assign dpu_non_temporal_iss_o     = non_temporal_iss;
  assign dpu_pld_iss_o              = pld_iss;
  assign dpu_pld_level_iss_o        = pld_level_iss;
  assign dpu_store_iss_o            = ls_store_iss & ls_valid_iss;
  assign dpu_valid_iss_o            = dpu_valid_iss;
  assign dpu_valid_cp_iss_o         = dpu_valid_cp_iss;
  assign dpu_size_iss_o             = ls_size_iss[1:0];
  assign dpu_cp_op_iss_o            = cp_op_iss;
  assign dpu_utlb_hit_dc1_o         = dpu_utlb_hit_dc1;
  assign dpu_length_iss_o           = dpu_length_iss;
  assign dpu_cc_fail_wr_o           = cc_fail_wr;
  assign dpu_ready_wr_o             = dpu_ready_wr;
  assign dpu_ready_cc_fail_wr_o     = dpu_ready_cc_fail_wr;
  assign dpu_ready_cc_pass_wr_o     = dpu_ready_cc_pass_wr;

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_wr")
  u_ovl_x_advance_wr (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (advance_wr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: clean_dcu_ready_iss")
  u_ovl_x_clean_dcu_ready_iss (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (clean_dcu_ready_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_addr_ex1")
  u_ovl_x_en_addr_ex1 (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (en_addr_ex1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_ls_ex1")
  u_ovl_x_en_ls_ex1 (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (en_ls_ex1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_ls_ex2")
  u_ovl_x_en_ls_ex2 (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (en_ls_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_ls_iss")
  u_ovl_x_en_ls_iss (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (en_ls_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_ls_isv_ex1")
  u_ovl_x_en_ls_isv_ex1 (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_ls_isv_ex1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_ls_isv_ex2")
  u_ovl_x_en_ls_isv_ex2 (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_ls_isv_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_ls_isv_iss")
  u_ovl_x_en_ls_isv_iss (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_ls_isv_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_ls_isv_wr")
  u_ovl_x_en_ls_isv_wr (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (en_ls_isv_wr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_ls_length")
  u_ovl_x_en_ls_length (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (en_ls_length));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_ls_real_valid_iss")
  u_ovl_x_en_ls_real_valid_iss (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (en_ls_real_valid_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_ls_wr")
  u_ovl_x_en_ls_wr (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (en_ls_wr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_ri_ctl_iss")
  u_ovl_x_en_ri_ctl_iss (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_ri_ctl_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_skidding_iss")
  u_ovl_x_en_skidding_iss (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (en_skidding_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ls_valid_iss_en")
  u_ovl_x_ls_valid_iss_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (ls_valid_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ls_valid_wr_en")
  u_ovl_x_ls_valid_wr_en (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (ls_valid_wr_en));

  assert_never_unknown #(`OVL_FATAL, 7, `OVL_ASSERT, "Register enable x-check: skid_en_wr")
  u_ovl_x_skid_en_wr (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (skid_en_wr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: va_dc1_en")
  u_ovl_x_va_dc1_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (va_dc1_en));

  //----------------------------------------------------------------------------
  // OVL_ASSERT: The ls_length[5:0] input can never be greater than 16 for
  // integer LSMs (5'b10000), this is required so that we can encode it onto
  // dpu_length[3:0] by simply subtracting one.
  //----------------------------------------------------------------------------

  generate if (!NEON_FP) begin : FPU2
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"ls_length may not be >16")
    ovl_ls_length_gt16 (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (ls_valid_de_i & (ls_length_de_i > 6'b010000)));
  end else begin : FPU2
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"ls_length may not be >32")
    ovl_ls_length_gt31 (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (ls_valid_de_i & (ls_length_de_i > 6'b100_000)));
  end endgenerate

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_length_too_long
  // Check that ls_length_iss is never >16 for integer LSMs, since we subtract
  // one to generate dpu_length_iss
  //----------------------------------------------------------------------------

  generate if (!NEON_FP) begin : FPU3
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"ls_length_iss is >16")
    ovl_length_too_long (.clk       (clk),
                         .reset_n   (reset_n),
                         .test_expr (dpu_valid_iss & ~flush_wr_i & ~ls_stall_wr & (ls_length_iss > 6'b010_000)));
  end else begin : FPU3
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"ls_length_iss is >32")
    ovl_length_too_long (.clk       (clk),
                         .reset_n   (reset_n),
                         .test_expr (dpu_valid_iss & ~flush_wr_i & ~ls_stall_wr & (ls_length_iss > 6'b100_000)));
  end endgenerate

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_length_too_short
  // Check that ls_length_iss is never 0, since we subtract one to generate
  // dpu_length_iss
  //----------------------------------------------------------------------------

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"ls_length_iss is =0")
    ovl_length_too_short (.clk       (clk),
                          .reset_n   (reset_n),
                          .test_expr (dpu_valid_iss &
                                      ~flush_wr_i &
                                      ~lsm_skidding &
                                      ~ls_stall_wr &
                                      (ls_length_iss == 6'b000000)));

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Check that a micro-TLB update can only occur after a miss
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL

  reg  ovl_utlb_miss_reg;
  wire ovl_utlb_miss_reg_set;

  assign ovl_utlb_miss_reg_set = dpu_valid_iss & ~flush_wr_i & clean_dcu_ready_iss & ~(|u_agu.entry_hit_iss);

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_utlb_miss_reg <= 1'b0;
    else if (clean_dcu_ready_iss)
      ovl_utlb_miss_reg <= ovl_utlb_miss_reg_set;
    else if (tlb_d_utlb_enable_i)
      ovl_utlb_miss_reg <= 1'b0;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Illegal micro-TLB update has occured")
    ovl_utlb_update (.clk             (clk),
                     .reset_n         (reset_n),
                     .antecedent_expr (tlb_d_utlb_enable_i),
                     .consequent_expr (ovl_utlb_miss_reg));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Check that a transaction can not be issued in the same cycle
  // as a micro-TLB update as the same entry that hit could change causing
  // an incorrect physical address to be sent out.
  //---------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Issue occuring in same cycle as uTLB update")
    ovl_issue_while_update (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr (tlb_d_utlb_enable_i & dpu_valid_iss & ~flush_wr_i & clean_dcu_ready_iss));
  // OVL_ASSERT_END

  //---------------------------------------------------------------------------
  // OVL_ASSERT: Check that the lsm_unaligned signal can only be set on an LDR
  //---------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"The ldr_no_early_fwd_iss signal is modifying fwd'ing, but should not be set")
    ovl_bad_ldr_unalgn (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (ldr_no_early_fwd_iss_o & (~ls_valid_iss | ls_store_iss)));
  // OVL_ASSERT_END

  //---------------------------------------------------------------------------
  // OVL_ASSERT: We should only force an extra lsm-cycle on a valid instruction
  //---------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"force_extra_lsm_cycle should not be asserted")
    ovl_force_extra_lsm (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (force_extra_lsm_cycle),
                         .consequent_expr (ls_valid_iss & ls_multiple_iss));
  // OVL_ASSERT_END

  //---------------------------------------------------------------------------
  // OVL_ASSERT: Should never have aligned address when using Wr skid buffer
  //---------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg [2:0] ovl_v_addr_wr;
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_v_addr_wr <= 3'b000;
    else if (en_ls_wr)
      ovl_v_addr_wr <= v_addr_ex2[2:0];

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Using Wr skid buffer but do not have unaligned address")
    ovl_wr_skid_strobe  (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (dpu_ready_wr & dcu_valid_dc3_i & |skid_strobe_wr),
                         .consequent_expr (ovl_v_addr_wr[2:0] != 3'b000));
  // OVL_ASSERT_END

`endif

endmodule // ca53dpu_ldst

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
