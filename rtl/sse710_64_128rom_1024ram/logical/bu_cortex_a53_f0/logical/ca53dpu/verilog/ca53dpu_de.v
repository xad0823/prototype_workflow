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
//      Checked In          : $Date: 2015-02-14 09:39:17 +0000 (Sat, 14 Feb 2015) $
//
//      Revision            : $Revision: 301905 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : DPU de-stage.  Includes IQ, Main Decoders, PC/mode/IT logic.
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Top-level for the Decode (De) Stage.
//
// This block instantiates the following blocks.
//
// ca53dpu_de_rp_dec.v      - Register read port decoder
// ca53dpu_dec0_dp.v        - Slot-0 data-processing decoder
// ca53dpu_dec0_ls.v        - Slot-0 load-store decoder
// ca53dpu_dec0_br.v        - Slot-0 branch decoder
// ca53dpu_dec0_other.v     - Slot-0 other decoder
// ca53dpu_dec0_neon.v      - Slot-0 NEON decoder
// ca53dpu_dec_late_neon.v  - Slot-0 NEON decoder (Iss stage)
// ca53dpu_dec1.v           - Slot-1 main decoder
// ca53dpu_dec1_ls.v        - Slot-1 load-store decoder
// ca53dpu_dec1_br.v        - Slot-1 branch decoder
// ca53dpu_dec1_neon.v      - Slot-1 NEON decoder
// ca53dpu_dec1_late_neon.v - Slot-1 NEON decoder (Iss stage)
// ca53dpu_dec_forceop.v    - Exception force operation decoder
// ca53dpu_de_pc.v          - Logic which generates the PC for the instruction.
//                            If only one instruction is being issued, then the PC
//                            (R15) value is for that instruction. If dual
//                            issue, then the PC is that for the first
//                            instruction, with the PC for the second instruction
//                            being interpolated.
// ca53dpu_de_regexpand.v   - Expand register file read ports in to one-hot form
// ca53dpu_iq.v             - top level of the Instruction Queue logic.
//
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_de `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire                                 clk,
  input  wire                                 reset_n,
  input  wire                                 DFTSE,
  input  wire                          [47:0] ifu_instr0_if3_i,
  input  wire                          [47:0] ifu_instr1_if3_i,
  input  wire                           [1:0] ifu_instr_valid_if3_i,
  input  wire                                 ifu_early_two_valid_if3_i,
  input  wire                                 paq_full_i,
  input  wire                           [4:0] spec_cpsr_mode_iss_i,
  input  wire                                 spec_cpsr_mode_usr_iss_i,
  input  wire                                 spec_cpsr_mode_sys_iss_i,
  input  wire                                 spec_cpsr_mode_mon_iss_i,
  input  wire                                 spec_cpsr_mode_hyp_iss_i,
  input  wire                                 ns_state_de_i,
  input  wire                                 gov_cp15sdisable_i,
  input  wire                                 giccdisable_i,
  input  wire                                 ns_scr_i,
  input  wire                                 stall_de_i,
  input  wire                                 aarch64_state_i,
  input  wire                                 aarch64_at_el3_i,
  input  wire                           [3:0] sctlr_sa_at_el_i,
  input  wire                           [1:0] dpu_exception_level_i,
  input  wire                           [1:0] isa_instr0_iss_i,
  input  wire                                 instr0_de_pc_in_iss_i,
  input  wire                                 prefetch_abort_iss_i,
  input  wire                                 slot1_branch_iss_i,
  input  wire                                 size_instr0_iss_i,
  input  wire                                 size_instr1_iss_i,
  input  wire                                 size_instr1_ret_i,
  input  wire                           [1:0] valid_instrs_iss_i,
  input  wire                                 end_instr_iss_i,
  input  wire                                 flush_wr_i,
  input  wire                                 expt_slot1_ret_i,
  input  wire                                 insert_forceop_ret_i,
  input  wire                                 forceop_valid_de_i,
  input  wire                                 forceop_valid_iss_i,
  input  wire      [`CA53_FORCEOP_TYPE_W-1:0] forceop_type_i,
  input  wire    [`CA53_FORCEOP_OFFSET_W-1:0] forceop_offset_i,
  input  wire                                 forceop_aa64_i,
  input  wire                          [63:0] pc_instr0_iss_i,
  input  wire                          [48:1] pc_instr0_wr_i,
  input  wire                          [63:0] pc_instr0_ret_i,
  input  wire                                 thumb_instr0_iss_i,
  input  wire                                 thumb_instr0_ret_i,
  input  wire                                 thumb_instr1_ret_i,
  input  wire                           [1:0] tlb_d_tcr_el1_tbi_i,
  input  wire                                 tlb_d_tcr_el2_tbi0_i,
  input  wire                                 tlb_d_tcr_el3_tbi0_i,
  input  wire                          [48:1] rtn_addr_iss_i,
  input  wire                          [27:1] br_offset_iss_i,
  input  wire                                 btac_rtn_instr_iss_i,
  input  wire                                 tbit_btac_rtn_instr_iss_i,
  input  wire                                 taken_br_instr_iss_i,
  input  wire                                 br_x_bit_iss_i,
  input  wire                                 in_halt_i,
  input  wire                                 dpu_fe_valid_wr_i,
  input  wire                          [48:1] dpu_fe_addr_opa_wr_i,
  input  wire                          [27:1] dpu_fe_addr_opb_wr_i,
  input  wire                                 dpu_fe_valid_ret_i,
  input  wire                          [63:0] dpu_fe_addr_opa_ret_i,
  input  wire                          [17:1] dpu_fe_addr_opb_ret_i,
  input  wire                                 disable_dual_issue_i,
  input  wire                                 disable_fp_dual_issue_i,
  input  wire                                 force_clean_to_invalidate_i,
  input  wire                                 cp_trap_fp_i,
  input  wire                                 cp_trap_neon_i,
  input  wire                                 edecr_ss_reg_i,
  input  wire                                 dbg_soft_step_active_i,
  input  wire                                 cpsr_tbit_wr_i,
  input  wire                                 cpsr_tbit_ret_i,
  input  wire                                 incr_pc_halt_mode_ret_i,
  input  wire                                 dbg_halt_ecc_expt_iss_i,
  input  wire                                 dpu_halt_ifu_i,
  input  wire                                 issue_to_iss_i,
  input  wire                                 issue_to_iss_fpu_i,
  input  wire                                 exception_valid_iss_i,
  input  wire                                 hcr_fb_i,
  input  wire                           [1:0] hcr_bsu_i,
  input  wire                                 hcr_imo_i,
  input  wire                                 hcr_fmo_i,
  input  wire                                 rf_wr_en_w0_iss_i,
  input  wire                                 rf_wr_en_w1_iss_i,
  input  wire                                 rf_wr_en_w2_iss_i,
  input  wire                           [1:0] rf_wr_when_w0_iss_i,
  input  wire                           [1:0] rf_wr_when_w1_iss_i,
  input  wire                           [1:0] rf_wr_when_w2_iss_i,
  input  wire                           [4:0] rf_wr_vaddr_w0_iss_i,
  input  wire                           [4:0] rf_wr_vaddr_w1_iss_i,
  input  wire                           [4:0] rf_wr_vaddr_w2_iss_i,
  input  wire                                 rf_wr_en_w0_ex1_i,
  input  wire                                 rf_wr_en_w1_ex1_i,
  input  wire                                 rf_wr_en_w2_ex1_i,
  input  wire                           [1:0] rf_wr_when_w0_ex1_i,
  input  wire                           [1:0] rf_wr_when_w1_ex1_i,
  input  wire                           [1:0] rf_wr_when_w2_ex1_i,
  input  wire                           [4:0] rf_wr_vaddr_w0_ex1_i,
  input  wire                           [4:0] rf_wr_vaddr_w1_ex1_i,
  input  wire                           [4:0] rf_wr_vaddr_w2_ex1_i,
  input  wire                           [3:0] rf_wr_en_fw0_iss_i,
  input  wire                           [3:0] rf_wr_en_fw1_iss_i,
  input  wire                           [3:0] rf_wr_en_fw0_f1_i,
  input  wire                           [3:0] rf_wr_en_fw1_f1_i,
  input  wire                           [3:0] rf_wr_en_fw0_f2_i,
  input  wire                           [3:0] rf_wr_en_fw1_f2_i,
  input  wire                           [1:0] rf_wr_when_fw0_iss_i,
  input  wire                           [1:0] rf_wr_when_fw1_iss_i,
  input  wire                           [1:0] rf_wr_when_fw0_f1_i,
  input  wire                           [1:0] rf_wr_when_fw1_f1_i,
  input  wire                           [1:0] rf_wr_when_fw0_f2_i,
  input  wire                           [1:0] rf_wr_when_fw1_f2_i,
  input  wire                           [5:0] rf_wr_addr_fw0_iss_i,
  input  wire                           [5:0] rf_wr_addr_fw1_iss_i,
  input  wire                           [5:0] rf_wr_addr_fw0_f1_i,
  input  wire                           [5:0] rf_wr_addr_fw1_f1_i,
  input  wire                           [5:0] rf_wr_addr_fw0_f2_i,
  input  wire                           [5:0] rf_wr_addr_fw1_f2_i,
  input  wire                          [20:0] raw_imm_data_0_iss_i,
  input  wire                          [20:0] raw_imm_data_1_iss_i,
  input  wire                           [1:0] adrp_valid_iss_i,
  input  wire                                 second_x64_iss_i,
  // Outputs
  output wire   [`CA53_EXPT_INSTR_TYPE_W-1:0] expt_instr_type_de_o,
  output reg     [`CA53_EXPT_INSTR_BUS_W-1:0] expt_instr_data_de_o,
  output reg                                  early_expt_enable_de_o,
  output wire                                 dpu_iq_full_o,
  output wire                                 dpu_iq_part_full_o,
  output wire                                 aarch64_state_ext_o,
  output reg                                  psr_wr_operation_de_o,
  output reg                            [5:0] psr_wr_en_de_o,
  output reg                            [3:0] psr_wr_src_de_o,
  output reg                            [1:0] head_instr_de_o,
  output reg                                  end_instr_de_o,
  output wire                                 first_cycle_ls_de_o,
  output wire                                 use_ex1_alu_0_de_o,
  output wire                                 use_ex1_alu_1_de_o,
  output wire                                 alu0_valid_de_o,
  output wire                                 alu1_valid_de_o,
  output reg        [`CA53_ALU_PIPECTL_W-1:0] alu0_pipectl_de_o,
  output reg        [`CA53_ALU_PIPECTL_W-1:0] alu1_pipectl_de_o,
  output reg        [`CA53_MAC_PIPECTL_W-1:0] mac_pipectl_de_o,
  output reg                                  alu0_msk_data_sel_de_o,
  output reg                                  alu1_msk_data_sel_de_o,
  output reg          [`CA53_SEL_SHF_A_W-1:0] alu0_data_a_sel_de_o,
  output reg          [`CA53_SEL_SHF_B_W-1:0] alu0_data_b_sel_de_o,
  output reg          [`CA53_SEL_SHF_C_W-1:0] alu0_data_c_sel_de_o,
  output reg          [`CA53_SEL_MAC_A_W-1:0] mac_data_a_sel_de_o,
  output reg          [`CA53_SEL_MAC_B_W-1:0] mac_data_b_sel_de_o,
  output reg          [`CA53_SEL_DIV_A_W-1:0] div_data_a_sel_de_o,
  output reg          [`CA53_SEL_DIV_B_W-1:0] div_data_b_sel_de_o,
  output reg          [`CA53_SEL_SHF_A_W-1:0] alu1_data_a_sel_de_o,
  output reg          [`CA53_SEL_SHF_B_W-1:0] alu1_data_b_sel_de_o,
  output reg          [`CA53_SEL_SHF_C_W-1:0] alu1_data_c_sel_de_o,
  output wire                                 mac_valid_de_o,
  output reg                                  mul_cpsr_nz_v_de_o,
  output wire                                 div_valid_de_o,
  output wire                                 ls_valid_de_o,
  output reg                            [5:0] ls_length_de_o,
  output reg                                  ls_store_de_o,
  output reg                                  ls_store_neon_de_o,
  output reg                            [2:0] ls_size_de_o,
  output reg                            [2:0] ls_elem_size_de_o,
  output wire     [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_de_o,
  output wire                                 ls_multiple_de_o,
  output reg                                  ls_isv_set_de_o,
  output reg                                  ls_synd_sf_de_o,
  output wire                                 ls_check_stack_de_o,
  output reg                                  cp_de_o,
  output reg                            [8:0] cp_op_de_o,
  output reg                                  cp_op_mva_de_o,
  output reg                                  cp_valid_de_o,
  output reg                            [8:0] cp_decode_de_o,
  output reg                                  cp_op_ats1_de_o,
  output reg                                  cp_other_sec_de_o,
  output reg                                  fp_serialise_de_o,
  output reg                                  msr_mrs_reg_wr_de_o,
  output reg                                  msr_mrs_spsr_de_o,
  output reg                            [5:0] msr_mrs_data_de_o,
  output reg                                  force_usr_priv_mem_de_o,
  output reg          [`CA53_SEL_STR_A_W-1:0] str0_data_a_sel_de_o,
  output reg          [`CA53_SEL_STR_B_W-1:0] str0_data_b_sel_de_o,
  output reg                                  str0_b_valid_de_o,
  output reg                                  ctl_64bit_op_str0_de_o,
  output reg          [`CA53_SEL_STR_A_W-1:0] str1_data_a_sel_de_o,
  output reg          [`CA53_SEL_STR_B_W-1:0] str1_data_b_sel_de_o,
  output reg                                  str1_b_valid_de_o,
  output reg                                  ctl_64bit_op_str1_de_o,
  output reg                            [2:0] agu_shf_value_de_o,
  output reg          [`CA53_SEL_DCU_A_W-1:0] agu_data_a_sel_de_o,
  output reg          [`CA53_SEL_DCU_B_W-1:0] agu_data_b_sel_de_o,
  output reg                                  agu_sub_b_de_o,
  output wire                           [1:0] valid_instrs_de_o,
  output wire                                 size_instr0_de_o,
  output wire                                 size_instr1_de_o,
  output wire                                 thumb_instr0_de_o,
  output wire                                 thumb_instr1_de_o,
  output reg                            [3:0] cond_code_instr0_de_o,
  output wire                           [3:0] cond_code_instr1_de_o,
  output wire                          [63:0] pc_instr0_de_o,
  output wire                                 mod_pc_top_bits_de_o,
  output reg                                  no_interrupt_de_o,
  output reg                                  no_insert_de_o,
  output reg                                  enable_base_restore_de_o,
  output reg                                  usr_mode_regs_ldm_de_o,
  output wire                           [4:0] rf_wr_mode_de_o,
  output wire                           [5:0] rf_rd_addr_r0_de_o,
  output wire                           [5:0] rf_rd_addr_r1_de_o,
  output wire                           [5:0] rf_rd_addr_r2_de_o,
  output reg                            [5:0] rf_rd_addr_r3_de_o,
  output wire                           [5:0] rf_stm_rd_addr_r2_de_o,
  output wire                           [5:0] rf_stm_rd_addr_r3_de_o,
  output wire                           [5:0] rf_rd_addr_r4_de_o,
  output wire                                 instr0_r2_enabled_de_o,
  output wire                                 instr0_w0_enabled_de_o,
  output wire      [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r0_de_o,
  output wire      [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r1_de_o,
  output wire      [`CA53_LONG_RF_ADDR_W-1:0] rf_rd_addr_r0_agu_de_o,
  output wire      [`CA53_LONG_RF_ADDR_W-1:0] rf_rd_addr_r1_agu_de_o,
  output wire                           [5:0] rf_r0_for_fwd_check_de_o,
  output wire                           [5:0] rf_r1_for_fwd_check_de_o,
  output wire                                 rf_rd_en_r0_de_o,
  output wire                                 rf_rd_en_r1_de_o,
  output wire                                 rf_rd_en_r2_de_o,
  output reg                                  rf_rd_en_r3_de_o,
  output wire                                 rf_rd_en_r4_de_o,
  output wire        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_de_o,
  output wire        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_de_o,
  output wire        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r2_de_o,
  output wire        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r3_de_o,
  output wire        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r4_de_o,
  output reg                                  wd_align_pc_alu0_de_o,
  output reg                                  wd_align_pc_alu1_de_o,
  output reg                                  wd_align_pc_ls_de_o,
  output reg                                  pg_align_pc_ls_de_o,
  output wire                           [4:0] rf_wr_vaddr_w0_de_o,
  output wire                           [4:0] rf_wr_vaddr_w1_de_o,
  output wire                           [4:0] rf_wr_vaddr_w2_de_o,
  output wire      [`CA53_RF_WR_SRC_W0_W-1:0] rf_wr_src_w0_de_o,
  output wire      [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_de_o,
  output wire      [`CA53_RF_WR_SRC_W2_W-1:0] rf_wr_src_w2_de_o,
  output wire                                 rf_wr_en_w0_de_o,
  output wire                                 rf_wr_en_w1_de_o,
  output wire                                 rf_wr_en_w2_de_o,
  output wire                                 rf_wr_64b_w0_de_o,
  output wire                                 rf_wr_64b_w1_de_o,
  output wire                                 rf_wr_64b_w2_de_o,
  output wire        [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w0_de_o,
  output wire        [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_de_o,
  output wire        [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w2_de_o,
  output reg      [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr0_de_o,
  output reg      [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr1_de_o,
  output reg      [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr2_de_o,
  output reg      [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr3_de_o,
  output reg      [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr4_de_o,
  output reg      [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr5_de_o,
  output reg                            [1:0] rf_rd_en_fr0_de_o,
  output reg                            [1:0] rf_rd_en_fr1_de_o,
  output reg                            [1:0] rf_rd_en_fr2_de_o,
  output reg                            [1:0] rf_rd_en_fr3_de_o,
  output reg                            [1:0] rf_rd_en_fr4_de_o,
  output reg                            [1:0] rf_rd_en_fr5_de_o,
  output reg        [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr0_de_o,
  output reg        [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr1_de_o,
  output reg        [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr2_de_o,
  output reg        [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr3_de_o,
  output reg        [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr4_de_o,
  output reg        [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr5_de_o,
  output reg      [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw0_de_o,
  output reg      [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw1_de_o,
  output reg                            [3:0] rf_wr_en_fw0_de_o,
  output reg                            [3:0] rf_wr_en_fw1_de_o,
  output reg         [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_de_o,
  output reg         [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw1_de_o,
  output reg        [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw0_de_o,
  output reg        [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw1_de_o,
  output reg         [`CA53_FP_EX_PIPE_W-1:0] fp_ex_pipe_de_o,
  output reg                                  crypto_enable_de_o,
  output wire                                 br_valid_de_o,
  output reg                                  dpu_pred_br_de_o,
  output reg                                  dpu_br_return_de_o,
  output reg                                  dpu_br_call_de_o,
  output reg                                  br_btac_de_o,
  output reg         [`CA53_BR_PIPECTL_W-1:0] br_pipectl_de_o,
  output reg                                  br_pred_takenness_de_o,
  output reg                           [27:1] br_offset_de_o,
  output reg                                  br_x_bit_de_o,
  output reg                                  rtn_addr_valid_de_o,
  output reg                            [7:0] t16o_it_cpsr_mask_de_o,
  output reg                                  t16o_it_cpsr_valid_de_o,
  output reg                                  cpsr_ebit_value_de_o,
  output reg                            [5:0] cpsr_aifbits_val_o,
  output reg         [`CA53_INSTR_TYPE_W-1:0] instr_type_de_o,
  output reg   [`CA53_SLOT1_INSTR_TYPE_W-1:0] slot1_instr_type_de_o,
  output wire                                 str0_valid_de_o,
  output wire                                 str1_valid_de_o,
  output reg           [`CA53_IMM_DATA_W-1:0] imm_data_0_de_o,
  output reg           [`CA53_IMM_DATA_W-1:0] imm_data_1_de_o,
  output wire                          [32:0] imm_data_ls_de_o,
  output reg          [`CA53_IMM_SHIFT_W-1:0] imm_shift_0_de_o,
  output reg          [`CA53_IMM_SHIFT_W-1:0] imm_shift_1_de_o,
  output reg            [`CA53_IMM_SEL_W-1:0] imm_data_sel_0_de_o,
  output reg            [`CA53_IMM_SEL_W-1:0] imm_data_sel_1_de_o,
  output reg                                  req_strict_algn_de_o,
  output reg                                  check_x64_de_o,
  output reg                            [2:0] algn_size_de_o,
  output wire                           [1:0] iq_instr_is_fn_o,
  output wire                                 instr_is_cp10_cp11_de_o,
  output reg                            [1:0] instr_fmstat_de_o,
  output reg         [`CA53_FP_PIPECTL_W-1:0] fp0_pipectl_iss_o,
  output reg         [`CA53_FP_PIPECTL_W-1:0] fp1_pipectl_iss_o,
  output reg          [`CA53_SEL_FAD_A_W-1:0] sel_fad0_a_iss_o,
  output reg          [`CA53_SEL_FAD_B_W-1:0] sel_fad0_b_iss_o,
  output reg          [`CA53_SEL_FAD_C_W-1:0] sel_fad0_c_iss_o,
  output reg          [`CA53_SEL_FAD_A_W-1:0] sel_fad1_a_iss_o,
  output reg          [`CA53_SEL_FAD_B_W-1:0] sel_fad1_b_iss_o,
  output reg          [`CA53_SEL_FAD_C_W-1:0] sel_fad1_c_iss_o,
  output reg                                  sel_fml0_a_iss_o,
  output reg          [`CA53_SEL_FML_B_W-1:0] sel_fml0_b_iss_o,
  output reg                                  sel_fml0_c_iss_o,
  output reg                                  sel_fml1_a_iss_o,
  output reg          [`CA53_SEL_FML_B_W-1:0] sel_fml1_b_iss_o,
  output reg                                  sel_fml1_c_iss_o,
  output reg                            [1:0] fmac_valid_sp_de_o,
  output reg                            [1:0] fdiv_valid_de_o,
  output reg                            [1:0] neon_can_fwd_acc_de_o,
  output reg       [`CA53_NEON_VLD_CTL_W-1:0] neon_vld_ctl_de_o,
  output reg       [`CA53_FP_CFLAG_SRC_W-1:0] fp0_cflag_src_iss_o,
  output reg       [`CA53_FP_CFLAG_SRC_W-1:0] fp1_cflag_src_iss_o,
  output reg       [`CA53_FP_XFLAG_SRC_W-1:0] fp0_xflag_src_iss_o,
  output reg       [`CA53_FP_XFLAG_SRC_W-1:0] fp1_xflag_src_iss_o,
  output reg      [`CA53_FLAGEN_INSTR1_W-1:0] flag_en_instr1_de_o,
  output wire                                 rf_rd_remap_de_o,
  output wire                                 slot1_ls_de_o,
  output reg                            [4:0] ls_synd_srt_de_o,
  output reg                                  skid_x64_multiple_de_o,
  output wire                                 neon_de_active_o,
  output wire                                 evnt_iq_empty_o,
  output wire                           [1:0] neon_instr_iss_o
);

  // -----------------------------
  // Constant declarations
  // -----------------------------

  localparam DP = 0;
  localparam LS = 1;
  localparam OT = 2;
  localparam FO = 3;
  localparam UN = 4;
  localparam NE = 5;
  localparam BR = 6;

  localparam DEC1    = 0;
  localparam DEC1_LS = 1;
  localparam DEC1_NE = 2;
  localparam DEC1_BR = 3;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                                 en_decoder_lsm_de;
  reg                          [13:0] lsm_state;
  reg                                 decoder_fsm_dp;
  reg                           [4:0] decoder_fsm_ls;
  reg                           [3:0] decoder_fsm_other;
  reg                           [7:0] nxt_rf_rd_sel_0_r0_subseq;
  reg                           [5:0] nxt_rf_rd_sel_0_r1_subseq;
  reg                           [8:0] nxt_rf_rd_sel_0_r2_subseq;
  reg                           [4:0] nxt_rf_rd_sel_0_r3_subseq;
  reg                          [13:0] nxt_lsm_state_de;
  reg     [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_de;
  reg                                 srs_mode_ctl_de;
  reg           [`CA53_EX_PIPE_W-1:0] ex_pipe_0_de;
  reg           [`CA53_EX_PIPE_W-1:0] raw_ex_pipe_1_de;
  reg                                 slot0_str1_sel_de;
  reg                                 slot1_str0_sel_de;
  reg                          [11:0] exp_cpsr_mode_de;
  reg                           [4:0] postfix_srs_mode_de;
  reg        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_0_de;
  reg        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_0_de;
  reg        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r2_0_de;
  reg        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r3_0_de;
  reg                                 rf_rd_en_r0_0_de;
  reg                                 rf_rd_en_r1_0_de;
  reg                                 rf_rd_en_r2_0_de;
  reg                                 rf_rd_en_r3_0_de;
  reg        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_1_de;
  reg        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_1_de;
  reg        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r2_1_de;
  reg                                 rf_rd_en_r0_1_de;
  reg                                 rf_rd_en_r1_1_de;
  reg                                 rf_rd_en_r2_1_de;
  reg                           [4:0] rf_wr_vaddr_w0_0_de;
  reg                           [4:0] rf_wr_vaddr_w1_0_de;
  reg                           [4:0] rf_wr_vaddr_w2_0_de;
  reg      [`CA53_RF_WR_SRC_W0_W-1:0] rf_wr_src_w0_0_de;
  reg      [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_0_de;
  reg      [`CA53_RF_WR_SRC_W2_W-1:0] rf_wr_src_w2_0_de;
  reg                                 rf_wr_en_w0_0_de;
  reg                                 rf_wr_en_w1_0_de;
  reg                                 rf_wr_en_w2_0_de;
  reg                                 rf_wr_64b_w0_0_de;
  reg                                 rf_wr_64b_w1_0_de;
  reg                                 rf_wr_64b_w2_0_de;
  reg        [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w0_0_de;
  reg        [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_0_de;
  reg        [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w2_0_de;
  reg                           [4:0] rf_wr_vaddr_w0_1_de;
  reg                           [4:0] rf_wr_vaddr_w1_1_de;
  reg      [`CA53_RF_WR_SRC_W0_W-1:0] rf_wr_src_w0_1_de;
  reg      [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_1_de;
  reg                                 rf_wr_en_w0_1_de;
  reg                                 rf_wr_en_w1_1_de;
  reg                                 rf_wr_64b_w0_1_de;
  reg                                 rf_wr_64b_w1_1_de;
  reg        [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w0_1_de;
  reg        [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_1_de;
  reg                                 finish_instr_de;
  reg                           [5:0] nxt_decoder_fsm_de;
  reg   [`CA53_EXPT_INSTR_TYPE_W-1:0] expt_instr_type_de;
  reg        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r3_preskew_de;
  reg                                 use_ex1_alu_0_static_de;
  reg                                 use_ex1_alu_1_static_de;
  reg                           [2:0] adrp_fwd_src;
  reg          [`CA53_IMM_DATA_W-1:0] raw_imm_data_ls_de;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire          [`CA53_EX_PIPE_W-1:0] ex_pipe_1_de;
  wire                                mcr_mrc_valid_de;
  wire                          [7:0] nxt_rf_rd_sel_r0_subseq_dp;
  wire                          [5:0] nxt_rf_rd_sel_r1_subseq_dp;
  wire                          [8:0] nxt_rf_rd_sel_r2_subseq_dp;
  wire                          [4:0] nxt_rf_rd_sel_r3_subseq_dp;
  wire                          [7:0] nxt_rf_rd_sel_r0_subseq_ls;
  wire                          [5:0] nxt_rf_rd_sel_r1_subseq_ls;
  wire                          [8:0] nxt_rf_rd_sel_r2_subseq_ls;
  wire                          [4:0] nxt_rf_rd_sel_r3_subseq_ls;
  wire                          [5:0] rf_rd_addr_r0_de;
  wire                          [5:0] rf_rd_addr_r1_de;
  wire                          [5:0] iq_instr0_sideband;
  wire                         [32:0] iq_instr0_common;
  wire                                iq_instr0_common_aarch64;
  wire                         [32:0] iq_instr0_dp;
  wire                          [1:0] iq_instr0_dp_pdtype;
  wire                         [32:0] iq_instr0_ls;
  wire                          [1:0] iq_instr0_ls_pdtype;
  wire                                iq_instr0_ls_br_taken;
  wire                         [32:0] iq_instr0_other;
  wire                          [1:0] iq_instr0_other_pdtype;
  wire                                iq_instr0_other_br_taken;
  wire                                iq_instr0_common_br_taken;
  wire                         [32:0] iq_instr0_fn;
  wire                          [1:0] iq_instr0_fn_pdtype;
  wire                                iq_instr0_dp_aarch64;
  wire                                iq_instr0_ls_aarch64;
  wire                                iq_instr0_other_aarch64;
  wire                                iq_instr0_fn_aarch64;
  wire                                iq_instr0_en_other;
  wire                                iq_instr0_is_dp;
  wire                                iq_instr0_is_ls;
  wire                                iq_instr0_is_other;
  wire                                iq_instr0_is_fn;
  wire                                iq_instr0_val;
  wire                          [1:0] iq_instr0_pdtype;
  wire                          [5:0] iq_instr1_sideband;
  wire                         [32:0] iq_instr1_main;
  wire                         [32:0] iq_instr1_ls;
  wire                         [32:0] iq_instr1_fn;
  wire                         [32:0] iq_instr1_common;
  wire                                iq_instr1_common_aarch64;
  wire                          [1:0] iq_instr1_pdtype;
  wire                                iq_instr1_br_taken;
  wire                                iq_instr1_main_aarch64;
  wire                                iq_instr1_ls_aarch64;
  wire                                iq_instr1_fn_aarch64;
  wire                                iq_instr1_val;
  wire                                iq_instr1_is_dp;
  wire                                iq_instr1_is_ls;
  wire                                iq_instr1_is_other;
  wire                                iq_instr1_is_fn;
  wire                                iq_instr1_dih;
  wire                                iq_instr0_d0;
  wire                                iq_instr1_d1;
  wire                                iq_instr1_is_aesimc_aesmc;
  wire                                iq_skew_instr0_de;
  wire                                iq_skew_instr0_r0_de;
  wire                                iq_skew_instr0_r1_de;
  wire                                iq_skew_instr1_de;
  wire                                iq_skew_instr1_r0_de;
  wire                                iq_skew_instr1_r1_de;
  wire                                skew_instr0_de;
  wire                                skew_instr0_r0_de;
  wire                                skew_instr0_r1_de;
  wire                                skew_instr1_de;
  wire                                skew_instr1_r0_de;
  wire                                skew_instr1_r1_de;
  wire                                iq_instr0_r2_enabled;
  wire                                iq_instr0_w0_enabled;
  wire                                iq_instr1_br_valid;
  wire                                iq_instr1_datapath_resource_hazard;
  wire                                iq_instr1_fn_dcu_valid;
  wire                                iq_instr0_sets_ccflags;
  wire                                iq_instr0_d0_uses_dcu;
  wire                                iq_instr0_adrp_fwd;
  wire                          [2:1] iq_instr0_adrp_fwd_src;
  wire                                iq_instr1_adrp_fwd;
  wire                          [2:0] iq_instr1_adrp_fwd_src;
  wire                         [32:0] iq_instr0_fn_iss;
  wire                                iq_instr0_fn_pdtype_iss;
  wire                                iq_instr0_fn_aarch64_iss;
  wire                         [32:0] iq_instr1_fn_iss;
  wire                                iq_instr1_fn_pdtype_iss;
  wire                                iq_instr1_fn_aarch64_iss;
  wire                                disable_dual_issue;
  wire                          [1:0] valid_instrs_de;
  wire                                valid_instr1_early_de;
  wire                                ls_cp14_ldc_literal;
  wire    [`CA53_FLAGEN_INSTR1_W-1:0] flag_en_dec1;
  wire                          [7:0] t16_it_cpsr_mask_dec1;
  wire                                t16_it_cpsr_valid_dec1;
  wire                          [4:0] mode_for_srs_de;
  wire                          [5:0] nxt_flush_decoder_fsm_de;
  wire                                en_decoder_lsm;
  wire                                en_decoder_lsm_neon;
  wire                                en_decoder_fsm;
  wire                                en_decoder_fsm_dp;
  wire                                en_decoder_fsm_ls;
  wire                                en_decoder_fsm_other;
  wire                                en_decoder_fsm_fn;
  wire                          [5:0] decoder_fsm_fn;
  wire                          [5:0] decoder_fsm_fn_iss;
  wire                                rf_rd_en_r0_dp;
  wire                                rf_rd_en_r1_dp;
  wire                                rf_rd_en_r2_dp;
  wire                                rf_rd_en_r3_dp;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_dp;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_dp;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r2_dp;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r3_dp;
  wire                          [4:0] rf_wr_vaddr_w0_dp;
  wire                          [4:0] rf_wr_vaddr_w1_dp;
  wire                                rf_wr_en_w0_dp;
  wire                                rf_wr_en_w1_dp;
  wire                                rf_wr_64b_w0_dp;
  wire                                rf_wr_64b_w1_dp;
  wire     [`CA53_RF_WR_SRC_W0_W-1:0] rf_wr_src_w0_dp;
  wire     [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_dp;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w0_dp;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_dp_preskew;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_dp;
  wire                                alu_msk_data_sel_dp;
  wire        [`CA53_SEL_SHF_A_W-1:0] alu_data_a_sel_dp;
  wire        [`CA53_SEL_SHF_B_W-1:0] alu_data_b_sel_dp;
  wire        [`CA53_SEL_SHF_C_W-1:0] alu_data_c_sel_dp;
  wire        [`CA53_SEL_MAC_A_W-1:0] mac_data_a_sel_dp;
  wire        [`CA53_SEL_MAC_B_W-1:0] mac_data_b_sel_dp;
  wire        [`CA53_SEL_DIV_A_W-1:0] div_data_a_sel_dp;
  wire        [`CA53_SEL_DIV_B_W-1:0] div_data_b_sel_dp;
  wire        [`CA53_SEL_STR_A_W-1:0] str_data_a_sel_dp;
  wire          [`CA53_EX_PIPE_W-1:0] ex_pipe_dp;
  wire        [`CA53_SEL_STR_B_W-1:0] str_data_b_sel_dp;
  wire                                str_b_valid_dp;
  wire                                ctl_64bit_op_str_dp;
  wire         [`CA53_IMM_DATA_W-1:0] imm_data_dp;
  wire        [`CA53_IMM_SHIFT_W-1:0] imm_shift_dp;
  wire          [`CA53_IMM_SEL_W-1:0] imm_data_sel_dp;
  wire       [`CA53_BR_PIPECTL_W-1:0] br_pipectl_dp;
  wire      [`CA53_ALU_PIPECTL_W-1:0] alu_pipectl_dp;
  wire                                use_ex1_alu_static_dp;
  wire      [`CA53_MAC_PIPECTL_W-1:0] mac_pipectl_dp;
  wire                                word_align_pc_dp;
  wire                                mul_cpsr_nz_v_dp;
  wire                                psr_wr_operation_dp;
  wire                          [5:0] psr_wr_en_dp;
  wire                          [3:0] psr_wr_src_dp;
  wire                                head_instr_dp;
  wire                                end_instr_dp;
  wire                          [1:0] nxt_decoder_fsm_dp;
  wire                          [5:0] rf_stm_rd_addr_r2_ls;
  wire                          [5:0] rf_stm_rd_addr_r3_ls;
  wire                                rf_rd_en_r0_ls;
  wire                                rf_rd_en_r1_ls;
  wire                                rf_rd_en_r2_ls;
  wire                                rf_rd_en_r3_ls;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_ls;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_ls;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r2_ls;
  wire                          [4:0] rf_wr_vaddr_w0_ls;
  wire                          [4:0] rf_wr_vaddr_w1_ls;
  wire                          [4:0] rf_wr_vaddr_w2_ls;
  wire                                rf_wr_en_w0_ls;
  wire                                rf_wr_en_w1_ls;
  wire                                rf_wr_en_w2_ls;
  wire                                rf_wr_64b_w0_ls;
  wire                                rf_wr_64b_w1_ls;
  wire                                rf_wr_64b_w2_ls;
  wire     [`CA53_RF_WR_SRC_W0_W-1:0] rf_wr_src_w0_ls;
  wire     [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_ls;
  wire     [`CA53_RF_WR_SRC_W2_W-1:0] rf_wr_src_w2_ls;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w0_ls;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_ls;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_ls_preskew;
  wire        [`CA53_SEL_SHF_A_W-1:0] alu_data_a_sel_ls;
  wire        [`CA53_SEL_SHF_B_W-1:0] alu_data_b_sel_ls;
  wire        [`CA53_SEL_SHF_C_W-1:0] alu_data_c_sel_ls;
  wire        [`CA53_SEL_DCU_A_W-1:0] agu_data_a_sel_ls;
  wire        [`CA53_SEL_DCU_B_W-1:0] agu_data_b_sel_ls;
  wire        [`CA53_SEL_STR_A_W-1:0] str_data_a_sel_ls;
  wire        [`CA53_SEL_STR_B_W-1:0] str_data_b_sel_ls;
  wire                                str_b_valid_ls;
  wire                                ctl_64bit_op_str_ls;
  wire        [`CA53_SEL_STR_A_W-1:0] str1_data_a_sel_ls;
  wire        [`CA53_SEL_STR_B_W-1:0] str1_data_b_sel_ls;
  wire                                str1_sel_ls;
  wire          [`CA53_EX_PIPE_W-1:0] ex_pipe_ls;
  wire         [`CA53_IMM_DATA_W-1:0] imm_data_ls;
  wire        [`CA53_IMM_SHIFT_W-1:0] imm_shift_ls;
  wire       [`CA53_BR_PIPECTL_W-1:0] br_pipectl_ls;
  wire      [`CA53_ALU_PIPECTL_W-1:0] alu_pipectl_ls;
  wire                                req_strict_algn_ls;
  wire                                check_x64_ls;
  wire                          [2:0] algn_size_ls;
  wire                                word_align_pc_ls;
  wire                                ls_store_ls;
  wire                          [2:0] ls_size_ls;
  wire    [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_ls;
  wire                                ls_isv_set_ls;
  wire                                ls_synd_sf_ls;
  wire                          [1:0] ls_elem_size_ls;
  wire                                cp_ls;
  wire                          [8:0] cp_op_ls;
  wire                                cp_op_mva_ls;
  wire                                force_usr_priv_mem_ls;
  wire                                usr_mode_regs_ldm_ls;
  wire                          [1:0] agu_shf_value_ls;
  wire                                agu_sub_b_ls;
  wire                                br_return_ls;
  wire                                br_btac_ls;
  wire                                pred_br_ls;
  wire                                br_pred_takenness_ls;
  wire                                rtn_addr_valid_ls;
  wire                                enable_base_restore_ls;
  wire                                srs_mode_ctl_ls;
  wire                                psr_wr_operation_ls;
  wire                          [5:0] psr_wr_en_ls;
  wire                          [3:0] psr_wr_src_ls;
  wire       [`CA53_INSTR_TYPE_W-1:0] instr_type_ls;
  wire                                early_expt_enable_ls;
  wire  [`CA53_EXPT_INSTR_TYPE_W-1:0] expt_instr_type_ls;
  wire                                skid_x64_multiple_ls;
  wire                                skid_x64_multiple_neon;
  wire                                head_instr_ls;
  wire                                end_instr_ls;
  wire                                last_cycle_ls;
  wire                          [4:0] nxt_decoder_fsm_ls;
  wire                         [13:0] nxt_lsm_state_ls;
  wire                          [4:0] ls_synd_srt_ls;
  wire                          [4:0] postfix_srs_mode_ls;
  wire                          [7:0] exp_srs_mode_ls;
  wire                                rf_rd_en_r0_other;
  wire                                rf_rd_en_r1_other;
  wire                                rf_rd_en_r2_other;
  wire                                rf_rd_en_r3_other;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_other;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_other;
  wire                          [4:0] rf_wr_vaddr_w0_other;
  wire                          [4:0] rf_wr_vaddr_w1_other;
  wire                                rf_wr_en_w0_other;
  wire                                rf_wr_en_w1_other;
  wire                                rf_wr_64b_w0_other;
  wire                                rf_wr_64b_w1_other;
  wire     [`CA53_RF_WR_SRC_W0_W-1:0] rf_wr_src_w0_other;
  wire     [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_other;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w0_other;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_other;
  wire        [`CA53_SEL_DCU_A_W-1:0] agu_data_a_sel_other;
  wire        [`CA53_SEL_DCU_B_W-1:0] agu_data_b_sel_other;
  wire        [`CA53_SEL_SHF_A_W-1:0] alu_data_a_sel_other;
  wire        [`CA53_SEL_SHF_B_W-1:0] alu_data_b_sel_other;
  wire        [`CA53_SEL_SHF_C_W-1:0] alu_data_c_sel_other;
  wire        [`CA53_SEL_STR_A_W-1:0] str_data_a_sel_other;
  wire        [`CA53_SEL_STR_B_W-1:0] str_data_b_sel_other;
  wire                                str_b_valid_other;
  wire                                ctl_64bit_op_str_other;
  wire                                str1_sel_other;
  wire          [`CA53_EX_PIPE_W-1:0] ex_pipe_other;
  wire         [`CA53_IMM_DATA_W-1:0] imm_data_other;
  wire        [`CA53_IMM_SHIFT_W-1:0] imm_shift_other;
  wire          [`CA53_IMM_SEL_W-1:0] imm_data_sel_ls;
  wire       [`CA53_BR_PIPECTL_W-1:0] br_pipectl_other;
  wire      [`CA53_ALU_PIPECTL_W-1:0] alu_pipectl_other;
  wire                          [2:0] algn_size_other;
  wire                                ls_store_other;
  wire                          [2:0] ls_size_other;
  wire                          [4:0] ls_length_other;
  wire    [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_other;
  wire                                cp_other;
  wire                          [8:0] cp_op_other;
  wire                                cp_op_mva_other;
  wire                                cp_op_ats1_other;
  wire                                cp_other_sec_other;
  wire                                cp_valid_other;
  wire                          [8:0] cp_decode_other;
  wire                                fp_serialise_other;
  wire                                force_usr_priv_mem_other;
  wire                                br_pred_takenness_other;
  wire                                t16_it_cpsr_valid_other;
  wire                          [7:0] t16_it_cpsr_mask_other;
  wire                          [5:0] cpsr_aifbits_value_other;
  wire                                cpsr_ebit_value_other;
  wire                                psr_wr_operation_other;
  wire                          [5:0] psr_wr_en_other;
  wire                          [3:0] psr_wr_src_other;
  wire                                early_expt_enable_dp;
  wire  [`CA53_EXPT_INSTR_TYPE_W-1:0] expt_instr_type_dp;
  wire       [`CA53_INSTR_TYPE_W-1:0] instr_type_other;
  wire                                early_expt_enable_other;
  wire  [`CA53_EXPT_INSTR_TYPE_W-1:0] expt_instr_type_other;
  wire                          [3:0] cond_code_other;
  wire                                head_instr_other;
  wire                                end_instr_other;
  wire                          [3:0] nxt_decoder_fsm_other;
  wire                          [4:0] rf_wr_vaddr_w1_force;
  wire                                rf_wr_en_w1_force;
  wire                                rf_wr_64b_w1_force;
  wire     [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_force;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_force;
  wire        [`CA53_SEL_SHF_A_W-1:0] alu_data_a_sel_force;
  wire        [`CA53_SEL_SHF_B_W-1:0] alu_data_b_sel_force;
  wire          [`CA53_EX_PIPE_W-1:0] ex_pipe_force;
  wire      [`CA53_ALU_PIPECTL_W-1:0] alu_pipectl_force;
  wire         [`CA53_IMM_DATA_W-1:0] imm_data_force;
  wire                                msr_mrs_reg_wr_force;
  wire                          [5:0] msr_mrs_data_force;
  wire                                msr_mrs_reg_wr_other;
  wire                                msr_mrs_reg_rd_other;
  wire                                msr_mrs_spsr_other;
  wire                          [5:0] msr_mrs_data_other;
  wire                          [6:0] decoder_select0;
  wire                          [3:0] decoder_select1;
  wire                          [3:0] decoder_select1_early;
  wire                                iq_instr1_is_dec1;
  wire                                decoder_select0_ne_iss;
  wire                                decoder_select1_ne_iss;
  wire                                dec0_neon_uses_pipe1_de;
  wire                                dec0_neon_uses_pipe1_iss;
  wire                          [4:0] ls_length_ls;
  wire                                rf_rd_en_r0_neon;
  wire                                rf_rd_en_r1_neon;
  wire                                rf_rd_en_r2_neon;
  wire                                rf_rd_en_r3_neon;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_neon;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_neon;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r2_neon;
  wire                          [4:0] rf_wr_vaddr_w0_neon;
  wire                                rf_wr_en_w0_neon;
  wire                                rf_wr_64b_w0_neon;
  wire                          [4:0] rf_wr_vaddr_w1_neon;
  wire                                rf_wr_en_w1_neon;
  wire                                rf_wr_64b_w1_neon;
  wire     [`CA53_RF_WR_SRC_W0_W-1:0] rf_wr_src_w0_neon;
  wire     [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_neon;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w0_neon;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_neon;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_neon_preskew;
  wire    [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr0_neon;
  wire    [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr1_neon;
  wire    [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr2_neon;
  wire    [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr3_neon;
  wire    [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr4_neon;
  wire    [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr5_neon;
  wire                          [1:0] rf_rd_en_fr0_neon;
  wire                          [1:0] rf_rd_en_fr1_neon;
  wire                          [1:0] rf_rd_en_fr2_neon;
  wire                          [1:0] rf_rd_en_fr3_neon;
  wire                          [1:0] rf_rd_en_fr4_neon;
  wire                          [1:0] rf_rd_en_fr5_neon;
  wire      [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr0_neon;
  wire      [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr1_neon;
  wire      [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr2_neon;
  wire      [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr3_neon;
  wire      [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr4_neon;
  wire      [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr5_neon;
  wire    [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw0_neon;
  wire    [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw1_neon;
  wire                          [3:0] rf_wr_en_fw0_neon;
  wire                          [3:0] rf_wr_en_fw1_neon;
  wire       [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_neon;
  wire      [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw0_neon;
  wire        [`CA53_SEL_DCU_A_W-1:0] agu_data_a_sel_neon;
  wire        [`CA53_SEL_DCU_B_W-1:0] agu_data_b_sel_neon;
  wire        [`CA53_SEL_STR_A_W-1:0] str_data_a_sel_neon;
  wire        [`CA53_SEL_STR_B_W-1:0] str_data_b_sel_neon;
  wire                                str_b_valid_neon;
  wire                                ctl_64bit_op_str_neon;
  wire        [`CA53_SEL_STR_A_W-1:0] str1_data_a_sel_neon;
  wire        [`CA53_SEL_STR_B_W-1:0] str1_data_b_sel_neon;
  wire                                str1_sel_neon;
  wire          [`CA53_EX_PIPE_W-1:0] ex_pipe_neon;
  wire         [`CA53_IMM_DATA_W-1:0] imm_data_neon;
  wire        [`CA53_IMM_SHIFT_W-1:0] imm_shift_neon;
  wire      [`CA53_ALU_PIPECTL_W-1:0] alu_pipectl_neon;
  wire                                req_strict_algn_neon;
  wire                                check_x64_neon;
  wire                                enable_base_restore_neon;
  wire                          [2:0] algn_size_neon;
  wire                                wd_align_pc_neon;
  wire                                ls_store_neon;
  wire                          [2:0] ls_size_neon;
  wire                          [2:0] ls_elem_size_neon;
  wire    [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_neon;
  wire                          [5:0] ls_length_neon;
  wire                          [2:0] agu_shf_value_neon;
  wire                                agu_sub_b_neon;
  wire                          [9:0] nxt_lsm_state_neon;
  wire     [`CA53_FP_CFLAG_SRC_W-1:0] fp_cflag_src_neon;
  wire     [`CA53_FP_XFLAG_SRC_W-1:0] fp_xflag_src_neon;
  wire       [`CA53_FP_EX_PIPE_W-1:0] fp_ex_pipe_neon;
  wire                                crypto_enable_neon;
  wire       [`CA53_FP_PIPECTL_W-1:0] fp_pipectl_neon;
  wire                                instr_fmstat_neon;
  wire                                sel_fml_a_neon;
  wire        [`CA53_SEL_FML_B_W-1:0] sel_fml_b_neon;
  wire                                sel_fml_c_neon;
  wire        [`CA53_SEL_FAD_A_W-1:0] sel_fad_a_neon;
  wire        [`CA53_SEL_FAD_B_W-1:0] sel_fad_b_neon;
  wire        [`CA53_SEL_FAD_C_W-1:0] sel_fad_c_neon;
  wire                                cp_valid_neon;
  wire                          [8:0] cp_decode_neon;
  wire                                fp_serialise_neon;
  wire                                psr_wr_operation_neon;
  wire                          [5:0] psr_wr_en_neon;
  wire                          [3:0] psr_wr_src_neon;
  wire                                no_interrupt_neon;
  wire                                no_insert_neon;
  wire                                early_expt_enable_neon;
  wire  [`CA53_EXPT_INSTR_TYPE_W-1:0] expt_instr_type_neon;
  wire                                head_instr_neon;
  wire                                end_instr_neon;
  wire                          [5:0] nxt_decoder_fsm_neon;
  wire                                alu_msk_data_sel_neon;
  wire        [`CA53_SEL_SHF_A_W-1:0] alu_data_a_sel_neon;
  wire        [`CA53_SEL_SHF_B_W-1:0] alu_data_b_sel_neon;
  wire        [`CA53_SEL_SHF_C_W-1:0] alu_data_c_sel_neon;
  wire                                predec_undefined;
  wire                                fmac_valid_sp_neon;
  wire                                fmac_valid_sp_dec1_ne;
  wire                                fdiv_valid_neon;
  wire     [`CA53_NEON_VLD_CTL_W-1:0] neon_vld_ctl_neon;
  wire                                neon_can_fwd_acc_neon;
  wire                                neon_can_fwd_acc_dec1_ne;
  wire                                el0_or_sys_de;
  wire                                el0_or_hyp_or_sys_de;
  wire                                elxt_de;
  wire                          [4:0] rf_wr_mode_de;
  wire                                hyp_or_mon_de;
  wire                                word_align_pc_dec1;
  wire      [`CA53_ALU_PIPECTL_W-1:0] alu_pipectl_dec1;
  wire                                use_ex1_alu_static_dec1;
  wire      [`CA53_MAC_PIPECTL_W-1:0] mac_pipectl_dec1;
  wire        [`CA53_SEL_SHF_A_W-1:0] alu_data_a_sel_dec1;
  wire        [`CA53_SEL_SHF_B_W-1:0] alu_data_b_sel_dec1;
  wire        [`CA53_SEL_SHF_C_W-1:0] alu_data_c_sel_dec1;
  wire                                msk_data_sel_dec1;
  wire        [`CA53_SEL_MAC_A_W-1:0] mac_data_a_sel_dec1;
  wire        [`CA53_SEL_MAC_B_W-1:0] mac_data_b_sel_dec1;
  wire        [`CA53_SEL_STR_A_W-1:0] str_data_a_sel_dec1;
  wire        [`CA53_SEL_STR_B_W-1:0] str_data_b_sel_dec1;
  wire                                str_b_valid_dec1;
  wire                                ctl_64bit_op_str_dec1;
  wire          [`CA53_EX_PIPE_W-1:0] ex_pipe_dec1;
  wire     [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w0_dec1;
  wire     [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_dec1;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_dec1_preskew;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w0_dec1;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_dec1;
  wire [`CA53_SLOT1_INSTR_TYPE_W-1:0] slot1_instr_type_dec1;
  wire [`CA53_SLOT1_INSTR_TYPE_W-1:0] slot1_instr_type_dec1_br;
  wire                                rf_wr_en_w0_dec1;
  wire                                rf_wr_en_w1_dec1;
  wire                                rf_wr_64b_w0_dec1;
  wire                                rf_wr_64b_w1_dec1;
  wire                          [4:0] rf_wr_vaddr_w0_dec1;
  wire                          [4:0] rf_wr_vaddr_w1_dec1;
  wire                                mul_cpsr_nz_v_dec1;
  wire         [`CA53_IMM_DATA_W-1:0] imm_data_dec1;
  wire        [`CA53_IMM_SHIFT_W-1:0] imm_shift_dec1;
  wire          [`CA53_IMM_SEL_W-1:0] imm_data_sel_dec1;
  wire                          [5:0] rf_rd_addr_r0_0_de;
  wire                          [5:0] rf_rd_addr_r1_0_de;
  wire                          [5:0] rf_rd_addr_r2_0_de;
  wire                          [5:0] rf_rd_addr_r3_0_de;
  wire                          [5:0] rf_rd_addr_r0_1_de;
  wire                          [5:0] rf_rd_addr_r1_1_de;
  wire                          [5:0] rf_rd_addr_r2_1_de;
  wire                                rf_rd_r0_is_r31_0_de;
  wire                                rf_rd_r0_is_r31_1_de;
  wire                                rf_rd_en_r0_dec1;
  wire                                rf_rd_en_r1_dec1;
  wire                                rf_rd_en_r2_dec1;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_dec1;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_dec1;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r2_dec1;
  wire                                force_cond_always_dec1;
  wire                                rf_rd_remap_de;
  wire                                rf_rd_en_r0_de;
  wire                                instr0_r2_enabled;
  wire                                instr0_r3_enabled;
  wire                                instr0_w0_enabled;
  wire                                instr0_w2_enabled;
  wire                                iq_neon_present;
  wire                                aes_op_merged_iss;
  wire                                rf_rd_en_r0_dec1_ls;
  wire                                rf_rd_en_r1_dec1_ls;
  wire                                rf_rd_en_r2_dec1_ls;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_dec1_ls;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_dec1_ls;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r2_dec1_ls;
  wire                          [4:0] rf_wr_vaddr_w0_dec1_ls;
  wire                          [4:0] rf_wr_vaddr_w1_dec1_ls;
  wire                                rf_wr_en_w0_dec1_ls;
  wire                                rf_wr_en_w1_dec1_ls;
  wire                                rf_wr_64b_w0_dec1_ls;
  wire                                rf_wr_64b_w1_dec1_ls;
  wire     [`CA53_RF_WR_SRC_W0_W-1:0] rf_wr_src_w0_dec1_ls;
  wire     [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_dec1_ls;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w0_dec1_ls;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_dec1_ls;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_dec1_ls_preskew;
  wire        [`CA53_SEL_SHF_A_W-1:0] alu_data_a_sel_dec1_ls;
  wire        [`CA53_SEL_SHF_B_W-1:0] alu_data_b_sel_dec1_ls;
  wire        [`CA53_SEL_SHF_C_W-1:0] alu_data_c_sel_dec1_ls;
  wire        [`CA53_SEL_STR_A_W-1:0] str_data_a_sel_dec1_ls;
  wire        [`CA53_SEL_STR_B_W-1:0] str_data_b_sel_dec1_ls;
  wire                                str_b_valid_dec1_ls;
  wire                                ctl_64bit_op_str_dec1_ls;
  wire        [`CA53_SEL_STR_A_W-1:0] str1_data_a_sel_dec1_ls;
  wire        [`CA53_SEL_STR_B_W-1:0] str1_data_b_sel_dec1_ls;
  wire                                str1_sel_dec1_ls;
  wire        [`CA53_SEL_DCU_A_W-1:0] agu_data_a_sel_dec1_ls;
  wire        [`CA53_SEL_DCU_B_W-1:0] agu_data_b_sel_dec1_ls;
  wire                                req_strict_algn_dec1_ls;
  wire                                check_x64_dec1_ls;
  wire                          [2:0] algn_size_dec1_ls;
  wire                                ls_store_dec1_ls;
  wire                          [1:0] ls_elem_size_dec1_ls;
  wire                          [2:0] ls_size_dec1_ls;
  wire                          [4:0] ls_length_dec1_ls;
  wire                                force_usr_priv_mem_dec1_ls;
  wire                          [1:0] agu_shf_value_dec1_ls;
  wire                                agu_sub_b_dec1_ls;
  wire    [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_dec1_ls;
  wire                          [4:0] ls_synd_srt_dec1_ls;
  wire                                ls_isv_set_dec1_ls;
  wire                                ls_synd_sf_dec1_ls;
  wire          [`CA53_EX_PIPE_W-1:0] ex_pipe_dec1_ls;
  wire         [`CA53_IMM_DATA_W-1:0] imm_data_dec1_ls;
  wire        [`CA53_IMM_SHIFT_W-1:0] imm_shift_dec1_ls;
  wire      [`CA53_ALU_PIPECTL_W-1:0] alu_pipectl_dec1_ls;
  wire                                word_align_pc_dec1_ls;
  wire                                head_instr_dec1_ls;
  wire                                rf_rd_en_r0_dec1_ne;
  wire                                rf_rd_en_r1_dec1_ne;
  wire                                rf_rd_en_r2_dec1_ne;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_dec1_ne;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_dec1_ne;
  wire                          [4:0] rf_wr_vaddr_w0_dec1_ne;
  wire                                rf_wr_en_w0_dec1_ne;
  wire                          [4:0] rf_wr_vaddr_w1_dec1_ne;
  wire                                rf_wr_en_w1_dec1_ne;
  wire                                rf_wr_64b_w1_dec1_ne;
  wire     [`CA53_RF_WR_SRC_W0_W-1:0] rf_wr_src_w0_dec1_ne;
  wire     [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_dec1_ne;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w0_dec1_ne;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_dec1_ne;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_dec1_ne_preskew;
  wire    [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr0_dec1_ne;
  wire    [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr1_dec1_ne;
  wire    [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr2_dec1_ne;
  wire                          [1:0] rf_rd_en_fr0_dec1_ne;
  wire                          [1:0] rf_rd_en_fr1_dec1_ne;
  wire                          [1:0] rf_rd_en_fr2_dec1_ne;
  wire      [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr0_dec1_ne;
  wire      [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr1_dec1_ne;
  wire      [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr2_dec1_ne;
  wire    [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw0_dec1_ne;
  wire                          [3:0] rf_wr_en_fw0_dec1_ne;
  wire       [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_dec1_ne;
  wire      [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw0_dec1_ne;
  wire        [`CA53_SEL_DCU_A_W-1:0] agu_data_a_sel_dec1_ne;
  wire        [`CA53_SEL_DCU_B_W-1:0] agu_data_b_sel_dec1_ne;
  wire        [`CA53_SEL_STR_A_W-1:0] str_data_a_sel_dec1_ne;
  wire        [`CA53_SEL_STR_B_W-1:0] str_data_b_sel_dec1_ne;
  wire                                str_b_valid_dec1_ne;
  wire                                ctl_64bit_op_str_dec1_ne;
  wire        [`CA53_SEL_STR_A_W-1:0] str1_data_a_sel_dec1_ne;
  wire        [`CA53_SEL_STR_B_W-1:0] str1_data_b_sel_dec1_ne;
  wire                                str1_sel_dec1_ne;
  wire          [`CA53_EX_PIPE_W-1:0] ex_pipe_dec1_ne;
  wire         [`CA53_IMM_DATA_W-1:0] imm_data_dec1_ne;
  wire        [`CA53_IMM_SHIFT_W-1:0] imm_shift_dec1_ne;
  wire      [`CA53_ALU_PIPECTL_W-1:0] alu_pipectl_dec1_ne;
  wire                                req_strict_algn_dec1_ne;
  wire                                check_x64_dec1_ne;
  wire                          [2:0] algn_size_dec1_ne;
  wire                                wd_align_pc_dec1_ne;
  wire                                ls_store_dec1_ne;
  wire                          [2:0] ls_size_dec1_ne;
  wire                          [2:0] ls_elem_size_dec1_ne;
  wire    [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_dec1_ne;
  wire                          [5:0] ls_length_dec1_ne;
  wire                          [2:0] agu_shf_value_dec1_ne;
  wire                                agu_sub_b_dec1_ne;
  wire     [`CA53_FP_CFLAG_SRC_W-1:0] fp_cflag_src_dec1_ne;
  wire     [`CA53_FP_XFLAG_SRC_W-1:0] fp_xflag_src_dec1_ne;
  wire       [`CA53_FP_EX_PIPE_W-1:0] fp_ex_pipe_dec1_ne;
  wire    [`CA53_FLAGEN_INSTR1_W-1:0] flag_en_dec1_ne;
  wire       [`CA53_FP_PIPECTL_W-1:0] fp_pipectl_dec1_ne;
  wire                                instr_fmstat_dec1_ne;
  wire                                sel_fml_a_dec1_ne;
  wire        [`CA53_SEL_FML_B_W-1:0] sel_fml_b_dec1_ne;
  wire                                sel_fml_c_dec1_ne;
  wire        [`CA53_SEL_FAD_A_W-1:0] sel_fad_a_dec1_ne;
  wire        [`CA53_SEL_FAD_B_W-1:0] sel_fad_b_dec1_ne;
  wire        [`CA53_SEL_FAD_C_W-1:0] sel_fad_c_dec1_ne;
  wire        [`CA53_SEL_SHF_A_W-1:0] alu_data_a_sel_dec1_ne;
  wire        [`CA53_SEL_SHF_B_W-1:0] alu_data_b_sel_dec1_ne;
  wire        [`CA53_SEL_SHF_C_W-1:0] alu_data_c_sel_dec1_ne;
  wire [`CA53_SLOT1_INSTR_TYPE_W-1:0] slot1_instr_type_dec1_ne;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_preskew_de;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_preskew_de;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r4_preskew_de;
  wire                                skew_r0_de;
  wire                                skew_r1_de;
  wire                                skew_r3_de;
  wire                                skew_r4_de;
  wire                          [1:0] iss_pc_in_same_page;
  wire                                use_dec0_br;
  wire                                use_dec1_br;
  wire                                rf_rd_en_r0_dec1_br;
  wire                                rf_rd_en_r1_dec1_br;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_dec1_br;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_dec1_br;
  wire                          [4:0] rf_wr_vaddr_w1_dec1_br;
  wire                                rf_wr_en_w1_dec1_br;
  wire                                rf_wr_64b_w1_dec1_br;
  wire     [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_dec1_br;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_dec1_br;
  wire        [`CA53_SEL_SHF_A_W-1:0] alu_data_a_sel_dec1_br;
  wire        [`CA53_SEL_SHF_B_W-1:0] alu_data_b_sel_dec1_br;
  wire        [`CA53_SEL_SHF_C_W-1:0] alu_data_c_sel_dec1_br;
  wire        [`CA53_SEL_STR_A_W-1:0] str_data_a_sel_dec1_br;
  wire        [`CA53_SEL_STR_B_W-1:0] str_data_b_sel_dec1_br;
  wire                                str_b_valid_dec1_br;
  wire                                ctl_64bit_op_str_dec1_br;
  wire          [`CA53_EX_PIPE_W-1:0] ex_pipe_dec1_br;
  wire         [`CA53_IMM_DATA_W-1:0] imm_data_dec1_br;
  wire        [`CA53_IMM_SHIFT_W-1:0] imm_shift_dec1_br;
  wire       [`CA53_BR_PIPECTL_W-1:0] br_pipectl_dec1_br;
  wire      [`CA53_ALU_PIPECTL_W-1:0] alu_pipectl_dec1_br;
  wire                                br_btac_dec1_br;
  wire                                br_return_dec1_br;
  wire                                rtn_addr_valid_dec1_br;
  wire                                pred_br_dec1_br;
  wire                         [27:1] br_offset_dec1_br;
  wire                                br_pred_takenness_dec1_br;
  wire                                br_call_dec1_br;
  wire                                br_x_bit_dec1_br;
  wire                                a64_cond_br_dec1_br;
  wire                                rf_rd_en_r0_dec0_br;
  wire                                rf_rd_en_r1_dec0_br;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_dec0_br;
  wire       [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_dec0_br;
  wire                          [4:0] rf_wr_vaddr_w1_dec0_br;
  wire                                rf_wr_en_w1_dec0_br;
  wire                                rf_wr_64b_w1_dec0_br;
  wire     [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_dec0_br;
  wire       [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_dec0_br;
  wire        [`CA53_SEL_SHF_A_W-1:0] alu_data_a_sel_dec0_br;
  wire        [`CA53_SEL_SHF_B_W-1:0] alu_data_b_sel_dec0_br;
  wire        [`CA53_SEL_SHF_C_W-1:0] alu_data_c_sel_dec0_br;
  wire        [`CA53_SEL_STR_A_W-1:0] str_data_a_sel_dec0_br;
  wire        [`CA53_SEL_STR_B_W-1:0] str_data_b_sel_dec0_br;
  wire                                str_b_valid_dec0_br;
  wire                                ctl_64bit_op_str_dec0_br;
  wire          [`CA53_EX_PIPE_W-1:0] ex_pipe_dec0_br;
  wire         [`CA53_IMM_DATA_W-1:0] imm_data_dec0_br;
  wire        [`CA53_IMM_SHIFT_W-1:0] imm_shift_dec0_br;
  wire       [`CA53_BR_PIPECTL_W-1:0] br_pipectl_dec0_br;
  wire      [`CA53_ALU_PIPECTL_W-1:0] alu_pipectl_dec0_br;
  wire                                br_btac_dec0_br;
  wire                                br_return_dec0_br;
  wire                                rtn_addr_valid_dec0_br;
  wire                                pred_br_dec0_br;
  wire                         [27:1] br_offset_dec0_br;
  wire                                br_pred_takenness_dec0_br;
  wire                                br_call_dec0_br;
  wire                                br_x_bit_dec0_br;
  wire                                psr_wr_operation_dec0_br;
  wire                          [5:0] psr_wr_en_dec0_br;
  wire                          [3:0] psr_wr_src_dec0_br;
  wire                          [3:0] cond_code_dec0_br;


  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Register list registers
  // ------------------------------------------------------

  // The following registers store the register list or register number for
  // integer and floating point LSM instructions
  assign en_decoder_lsm = ~stall_de_i & valid_instrs_de[0] & ((ls_instr_type_de == `CA53_LS_INSTR_MULTIPLE) |
                                                              en_decoder_lsm_de);

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      lsm_state <= {14{1'b0}};
    else if (en_decoder_lsm)
      lsm_state <= nxt_lsm_state_de;

  // ------------------------------------------------------
  // State machine for multicycle instructions
  // ------------------------------------------------------

  // The decoder_fsm counters are split into four versions to ensure that
  // logic does not toggle in the decoders that are not being used.
  assign en_decoder_fsm           = (~stall_de_i | flush_wr_i) & valid_instrs_de[0];
  assign en_decoder_fsm_dp        = en_decoder_fsm & iq_instr0_is_dp;
  assign en_decoder_fsm_ls        = en_decoder_fsm & iq_instr0_is_ls;
  assign en_decoder_fsm_other     = en_decoder_fsm & iq_instr0_is_other;
  assign en_decoder_fsm_fn        = en_decoder_fsm & iq_instr0_is_fn;
  assign nxt_flush_decoder_fsm_de = {nxt_decoder_fsm_de[5:1] & {5{~flush_wr_i}},
                                     nxt_decoder_fsm_de[0] | flush_wr_i};

  // DP FSM decoder registers
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      decoder_fsm_dp <= 1'b1;
    else if (en_decoder_fsm_dp)
      decoder_fsm_dp <= nxt_flush_decoder_fsm_de[0];

  // LS FSM decoder registers
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      decoder_fsm_ls <= 5'b00001;
    else if (en_decoder_fsm_ls)
      decoder_fsm_ls <= nxt_flush_decoder_fsm_de[4:0];

  // Other FSM decoder registers
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      decoder_fsm_other <= 4'b0001;
    else if (en_decoder_fsm_other)
      decoder_fsm_other <= nxt_flush_decoder_fsm_de[3:0];

generate if (NEON_FP) begin : FPU1
  reg [5:0] decoder_fsm_fn_reg;

  // FPU/Neon FSM decoder registers
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      decoder_fsm_fn_reg <= 6'b000_001;
    else if (en_decoder_fsm_fn)
      decoder_fsm_fn_reg <= nxt_flush_decoder_fsm_de[5:0];

  assign decoder_fsm_fn = decoder_fsm_fn_reg;
end else begin : FPU1_STUBS
  assign decoder_fsm_fn = {6{1'b0}};
end endgenerate

  // Indicate first cycle of LS instruction to ctl block - used for timing optimised
  // STM register address calculation
  assign first_cycle_ls_de_o = decoder_fsm_ls[0];

  // ------------------------------------------------------
  // Read port address decode
  // ------------------------------------------------------

  ca53dpu_de_rp_dec u_rp_dec (
    // Inputs
    .clk                          (clk),
    .reset_n                      (reset_n),
    .en_decoder_fsm_i             (en_decoder_fsm),
    .nxt_first_cycle_i            (nxt_flush_decoder_fsm_de[0]),
    .aarch64_state_i              (aarch64_state_i),
    .iq_instr0_cond_code_i        (iq_instr0_common[32:29]),
    .iq_instr0_is_dp_i            (iq_instr0_is_dp),
    .iq_instr0_is_other_i         (iq_instr0_is_other),
    .iq_instr0_is_ls_i            (iq_instr0_is_ls),
    .iq_instr0_sideband_i         (iq_instr0_sideband[5:0]),
    .iq_instr0_common_i           (iq_instr0_common[28:0]),
    .iq_instr1_is_dp_i            (iq_instr1_is_dp),
    .iq_instr1_common_i           (iq_instr1_common[28:0]),
    .iq_instr1_cond_code_i        (iq_instr1_common[32:29]),
    .iq_instr1_sideband_i         (iq_instr1_sideband[5:0]),
    .spec_cpsr_mode_iss_i         (spec_cpsr_mode_iss_i[4:0]),
    .exp_cpsr_mode_de_i           (exp_cpsr_mode_de[11:0]),
    .exp_srs_mode_ls_i            (exp_srs_mode_ls[7:0]),
    .srs_mode_ctl_ls_i            (srs_mode_ctl_ls),
    .nxt_rf_rd_sel_0_r0_subseq_i  (nxt_rf_rd_sel_0_r0_subseq[7:0]),
    .nxt_rf_rd_sel_0_r1_subseq_i  (nxt_rf_rd_sel_0_r1_subseq[5:0]),
    .nxt_rf_rd_sel_0_r2_subseq_i  (nxt_rf_rd_sel_0_r2_subseq[8:0]),
    .nxt_rf_rd_sel_0_r3_subseq_i  (nxt_rf_rd_sel_0_r3_subseq[4:0]),
    .rf_stm_rd_addr_r2_ls_i       (rf_stm_rd_addr_r2_ls[5:0]),
    .rf_stm_rd_addr_r3_ls_i       (rf_stm_rd_addr_r3_ls[5:0]),
    .msr_mrs_reg_rd_other_i       (msr_mrs_reg_rd_other),
    .msr_mrs_data_other_i         (msr_mrs_data_other[5:0]),
    .rf_rd_remap_de_i             (rf_rd_remap_de),
    // Outputs
    .rf_rd_addr_r0_0_de_o         (rf_rd_addr_r0_0_de[5:0]),
    .rf_rd_addr_r1_0_de_o         (rf_rd_addr_r1_0_de[5:0]),
    .rf_rd_addr_r2_0_de_o         (rf_rd_addr_r2_0_de[5:0]),
    .rf_rd_addr_r3_0_de_o         (rf_rd_addr_r3_0_de[5:0]),
    .rf_rd_addr_r0_1_de_o         (rf_rd_addr_r0_1_de[5:0]),
    .rf_rd_addr_r1_1_de_o         (rf_rd_addr_r1_1_de[5:0]),
    .rf_rd_addr_r2_1_de_o         (rf_rd_addr_r2_1_de[5:0]),
    .rf_rd_r0_is_r31_0_de_o       (rf_rd_r0_is_r31_0_de),
    .rf_rd_r0_is_r31_1_de_o       (rf_rd_r0_is_r31_1_de),
    .rf_rd_addr_r0_agu_de_o       (rf_rd_addr_r0_agu_de_o[`CA53_LONG_RF_ADDR_W-1:0]),
    .rf_rd_addr_r1_agu_de_o       (rf_rd_addr_r1_agu_de_o[`CA53_LONG_RF_ADDR_W-1:0]),
    .rf_r0_for_fwd_check_de_o     (rf_r0_for_fwd_check_de_o[5:0]),
    .rf_r1_for_fwd_check_de_o     (rf_r1_for_fwd_check_de_o[5:0])
  );

  // ------------------------------------------------------
  // Disable dual issue when Single Step enabled
  // ------------------------------------------------------

  assign disable_dual_issue = disable_dual_issue_i | edecr_ss_reg_i | dbg_soft_step_active_i;

  // ------------------------------------------------------
  // Valid instruction generation
  // ------------------------------------------------------
  //
  // Valid instruction encoding:
  //
  // 00 => No valid instructions
  // 01 => One valid instruction or force op
  // 10 => Not possible (checked with OVL)
  // 11 => Dual issue
  assign valid_instrs_de[1:0] = {(~forceop_valid_de_i &
                                  ~disable_dual_issue &
                                  ~(disable_fp_dual_issue_i & iq_instr1_is_fn) &
                                  // Wait for last cycle of multi-cycle
                                  // Slot 0 instruction
                                  ~(iq_instr0_is_dp & ~nxt_decoder_fsm_dp[0]) &
                                  ~(iq_instr0_is_ls & ~last_cycle_ls) &
                                  ~(iq_instr0_is_fn & ~nxt_decoder_fsm_neon[0]) &
                                  iq_instr1_val & iq_instr1_d1 & iq_instr0_d0 & ~iq_instr1_dih),
                                 (forceop_valid_de_i | iq_instr0_val)};

  // - early version of valid_instrs_de[1] without dual issue hazarding factored
  // in to use in decoder muxing
  // - need to factor in datapath resource hazarding because if slot 0 and slot
  // 1 want same resource, slot 0 has priority
  assign valid_instr1_early_de = iq_instr1_val & iq_instr1_d1 & iq_instr0_d0 & ~iq_instr1_datapath_resource_hazard;

  // ------------------------------------------------------
  // Processor modes and HYP mode traps
  // ------------------------------------------------------

  assign el0_or_sys_de         = spec_cpsr_mode_usr_iss_i | spec_cpsr_mode_sys_iss_i;
  assign el0_or_hyp_or_sys_de  = spec_cpsr_mode_usr_iss_i | spec_cpsr_mode_hyp_iss_i | spec_cpsr_mode_sys_iss_i;
  assign elxt_de               = exp_cpsr_mode_de[`CA53_ONEHOT_MODE_ELXT_BIT];
  assign hyp_or_mon_de         = spec_cpsr_mode_hyp_iss_i | spec_cpsr_mode_mon_iss_i;

  // ------------------------------------------------------
  // Slot-0 data processing decoder
  // ------------------------------------------------------

  ca53dpu_dec0_dp u_dec0_dp (
    // Inputs
    .iq_instr_dp_i                (iq_instr0_dp[32:0]),
    .iq_instr_sideband_0_i        (iq_instr0_sideband[0]),
    .decoder_fsm_i                (decoder_fsm_dp),
    .aarch64_state_i              (iq_instr0_dp_aarch64),
    .pdtype_i                     (iq_instr0_dp_pdtype),
    .el0_or_hyp_or_sys_de_i       (el0_or_hyp_or_sys_de),
    // Outputs
    .rf_rd_en_r0_dp_o             (rf_rd_en_r0_dp),
    .rf_rd_en_r1_dp_o             (rf_rd_en_r1_dp),
    .rf_rd_en_r2_dp_o             (rf_rd_en_r2_dp),
    .rf_rd_en_r3_dp_o             (rf_rd_en_r3_dp),
    .rf_rd_need_r0_dp_o           (rf_rd_need_r0_dp[`CA53_RF_RD_NEED_W-1:0]),
    .rf_rd_need_r1_dp_o           (rf_rd_need_r1_dp[`CA53_RF_RD_NEED_W-1:0]),
    .rf_rd_need_r2_dp_o           (rf_rd_need_r2_dp[`CA53_RF_RD_NEED_W-1:0]),
    .rf_rd_need_r3_dp_o           (rf_rd_need_r3_dp[`CA53_RF_RD_NEED_W-1:0]),
    .rf_wr_vaddr_w0_dp_o          (rf_wr_vaddr_w0_dp[4:0]),
    .rf_wr_vaddr_w1_dp_o          (rf_wr_vaddr_w1_dp[4:0]),
    .rf_wr_en_w0_dp_o             (rf_wr_en_w0_dp),
    .rf_wr_en_w1_dp_o             (rf_wr_en_w1_dp),
    .rf_wr_64b_w0_dp_o            (rf_wr_64b_w0_dp),
    .rf_wr_64b_w1_dp_o            (rf_wr_64b_w1_dp),
    .rf_wr_src_w0_dp_o            (rf_wr_src_w0_dp[`CA53_RF_WR_SRC_W0_W-1:0]),
    .rf_wr_src_w1_dp_o            (rf_wr_src_w1_dp[`CA53_RF_WR_SRC_W1_W-1:0]),
    .rf_wr_when_w0_dp_o           (rf_wr_when_w0_dp[`CA53_RF_WR_WHEN_W-1:0]),
    .rf_wr_when_w1_dp_o           (rf_wr_when_w1_dp_preskew[`CA53_RF_WR_WHEN_W-1:0]),
    .ex_pipe_dp_o                 (ex_pipe_dp[`CA53_EX_PIPE_W-1:0]),
    .imm_data_dp_o                (imm_data_dp[`CA53_IMM_DATA_W-1:0]),
    .imm_shift_dp_o               (imm_shift_dp[`CA53_IMM_SHIFT_W-1:0]),
    .imm_data_sel_dp_o            (imm_data_sel_dp[`CA53_IMM_SEL_W-1:0]),
    .use_ex1_alu_static_dp_o      (use_ex1_alu_static_dp),
    .br_pipectl_dp_o              (br_pipectl_dp[`CA53_BR_PIPECTL_W-1:0]),
    .alu_pipectl_dp_o             (alu_pipectl_dp[`CA53_ALU_PIPECTL_W-1:0]),
    .mac_pipectl_dp_o             (mac_pipectl_dp[`CA53_MAC_PIPECTL_W-1:0]),
    .msk_data_sel_dp_o            (alu_msk_data_sel_dp),
    .dp_data_c_sel_dp_o           (alu_data_c_sel_dp[`CA53_SEL_SHF_C_W-1:0]),
    .dp_data_b_sel_dp_o           (alu_data_b_sel_dp[`CA53_SEL_SHF_B_W-1:0]),
    .dp_data_a_sel_dp_o           (alu_data_a_sel_dp[`CA53_SEL_SHF_A_W-1:0]),
    .mac_data_a_sel_dp_o          (mac_data_a_sel_dp[`CA53_SEL_MAC_A_W-1:0]),
    .mac_data_b_sel_dp_o          (mac_data_b_sel_dp[`CA53_SEL_MAC_B_W-1:0]),
    .div_data_a_sel_dp_o          (div_data_a_sel_dp[`CA53_SEL_DIV_A_W-1:0]),
    .div_data_b_sel_dp_o          (div_data_b_sel_dp[`CA53_SEL_DIV_B_W-1:0]),
    .str_data_a_sel_dp_o          (str_data_a_sel_dp[`CA53_SEL_STR_A_W-1:0]),
    .str_data_b_sel_dp_o          (str_data_b_sel_dp[`CA53_SEL_STR_B_W-1:0]),
    .str_b_valid_dp_o             (str_b_valid_dp),
    .ctl_64bit_op_str_dp_o        (ctl_64bit_op_str_dp),
    .word_align_pc_dp_o           (word_align_pc_dp),
    .mul_cpsr_nz_v_dp_o           (mul_cpsr_nz_v_dp),
    .psr_wr_operation_dp_o        (psr_wr_operation_dp),
    .psr_wr_en_dp_o               (psr_wr_en_dp),
    .psr_wr_src_dp_o              (psr_wr_src_dp),
    .early_expt_enable_dp_o       (early_expt_enable_dp),
    .expt_instr_type_dp_o         (expt_instr_type_dp[`CA53_EXPT_INSTR_TYPE_W-1:0]),
    .head_instr_dp_o              (head_instr_dp),
    .end_instr_dp_o               (end_instr_dp),
    .nxt_decoder_fsm_dp_o         (nxt_decoder_fsm_dp[1:0]),
    .nxt_rf_rd_sel_r0_subseq_dp_o (nxt_rf_rd_sel_r0_subseq_dp),
    .nxt_rf_rd_sel_r1_subseq_dp_o (nxt_rf_rd_sel_r1_subseq_dp),
    .nxt_rf_rd_sel_r2_subseq_dp_o (nxt_rf_rd_sel_r2_subseq_dp),
    .nxt_rf_rd_sel_r3_subseq_dp_o (nxt_rf_rd_sel_r3_subseq_dp)
  );

  // ------------------------------------------------------
  // Slot-0 load-store decoder
  // ------------------------------------------------------

  ca53dpu_dec0_ls u_dec0_ls (
    // Inputs
    .iq_instr_ls_i                (iq_instr0_ls[32:0]),
    .iq_instr_sideband_i          (iq_instr0_sideband[5:0]),
    .aarch64_state_i              (iq_instr0_ls_aarch64),
    .br_taken_ls_i                (iq_instr0_ls_br_taken),
    .decoder_fsm_i                (decoder_fsm_ls[4:0]),
    .ns_state_de_i                (ns_state_de_i),
    .el0_or_sys_de_i              (el0_or_sys_de),
    .pdtype_i                     (iq_instr0_ls_pdtype),
    .lsm_state_i                  (lsm_state[13:0]),
    .hyp_mode_de_i                (spec_cpsr_mode_hyp_iss_i),
    .spec_cpsr_mode_usr_iss_i     (spec_cpsr_mode_usr_iss_i),
    .spec_cpsr_mode_iss_i         (spec_cpsr_mode_iss_i[4:0]),
    .exp_cpsr_mode_de_i           (exp_cpsr_mode_de[11:0]),
    // Outputs
    .nxt_rf_rd_sel_r0_subseq_ls_o (nxt_rf_rd_sel_r0_subseq_ls),
    .nxt_rf_rd_sel_r1_subseq_ls_o (nxt_rf_rd_sel_r1_subseq_ls),
    .nxt_rf_rd_sel_r2_subseq_ls_o (nxt_rf_rd_sel_r2_subseq_ls),
    .nxt_rf_rd_sel_r3_subseq_ls_o (nxt_rf_rd_sel_r3_subseq_ls),
    .rf_stm_rd_addr_r2_ls_o       (rf_stm_rd_addr_r2_ls[5:0]),
    .rf_stm_rd_addr_r3_ls_o       (rf_stm_rd_addr_r3_ls[5:0]),
    .rf_rd_en_r0_ls_o             (rf_rd_en_r0_ls),
    .rf_rd_en_r1_ls_o             (rf_rd_en_r1_ls),
    .rf_rd_en_r2_ls_o             (rf_rd_en_r2_ls),
    .rf_rd_en_r3_ls_o             (rf_rd_en_r3_ls),
    .rf_rd_need_r0_ls_o           (rf_rd_need_r0_ls[`CA53_RF_RD_NEED_W-1:0]),
    .rf_rd_need_r1_ls_o           (rf_rd_need_r1_ls[`CA53_RF_RD_NEED_W-1:0]),
    .rf_rd_need_r2_ls_o           (rf_rd_need_r2_ls[`CA53_RF_RD_NEED_W-1:0]),
    .rf_wr_vaddr_w0_ls_o          (rf_wr_vaddr_w0_ls[4:0]),
    .rf_wr_vaddr_w1_ls_o          (rf_wr_vaddr_w1_ls[4:0]),
    .rf_wr_vaddr_w2_ls_o          (rf_wr_vaddr_w2_ls[4:0]),
    .rf_wr_en_w0_ls_o             (rf_wr_en_w0_ls),
    .rf_wr_en_w1_ls_o             (rf_wr_en_w1_ls),
    .rf_wr_en_w2_ls_o             (rf_wr_en_w2_ls),
    .rf_wr_64b_w0_ls_o            (rf_wr_64b_w0_ls),
    .rf_wr_64b_w1_ls_o            (rf_wr_64b_w1_ls),
    .rf_wr_64b_w2_ls_o            (rf_wr_64b_w2_ls),
    .rf_wr_src_w0_ls_o            (rf_wr_src_w0_ls[`CA53_RF_WR_SRC_W0_W-1:0]),
    .rf_wr_src_w1_ls_o            (rf_wr_src_w1_ls[`CA53_RF_WR_SRC_W1_W-1:0]),
    .rf_wr_src_w2_ls_o            (rf_wr_src_w2_ls[`CA53_RF_WR_SRC_W2_W-1:0]),
    .rf_wr_when_w0_ls_o           (rf_wr_when_w0_ls[`CA53_RF_WR_WHEN_W-1:0]),
    .rf_wr_when_w1_ls_o           (rf_wr_when_w1_ls_preskew[`CA53_RF_WR_WHEN_W-1:0]),
    .ls_cp14_ldc_literal_o        (ls_cp14_ldc_literal),
    .agu_data_a_sel_ls_o          (agu_data_a_sel_ls[`CA53_SEL_DCU_A_W-1:0]),
    .agu_data_b_sel_ls_o          (agu_data_b_sel_ls[`CA53_SEL_DCU_B_W-1:0]),
    .str_data_a_sel_ls_o          (str_data_a_sel_ls[`CA53_SEL_STR_A_W-1:0]),
    .str_data_b_sel_ls_o          (str_data_b_sel_ls[`CA53_SEL_STR_B_W-1:0]),
    .str_b_valid_ls_o             (str_b_valid_ls),
    .ctl_64bit_op_str_ls_o        (ctl_64bit_op_str_ls),
    .str1_data_a_sel_ls_o         (str1_data_a_sel_ls[`CA53_SEL_STR_A_W-1:0]),
    .str1_data_b_sel_ls_o         (str1_data_b_sel_ls[`CA53_SEL_STR_B_W-1:0]),
    .str1_sel_ls_o                (str1_sel_ls),
    .ex_pipe_ls_o                 (ex_pipe_ls[`CA53_EX_PIPE_W-1:0]),
    .imm_data_ls_o                (imm_data_ls[`CA53_IMM_DATA_W-1:0]),
    .imm_shift_ls_o               (imm_shift_ls[`CA53_IMM_SHIFT_W-1:0]),
    .imm_data_sel_ls_o            (imm_data_sel_ls[`CA53_IMM_SEL_W-1:0]),
    .br_pipectl_ls_o              (br_pipectl_ls[`CA53_BR_PIPECTL_W-1:0]),
    .alu_pipectl_ls_o             (alu_pipectl_ls[`CA53_ALU_PIPECTL_W-1:0]),
    .dp_data_c_sel_ls_o           (alu_data_c_sel_ls[`CA53_SEL_SHF_C_W-1:0]),
    .dp_data_b_sel_ls_o           (alu_data_b_sel_ls[`CA53_SEL_SHF_B_W-1:0]),
    .dp_data_a_sel_ls_o           (alu_data_a_sel_ls[`CA53_SEL_SHF_A_W-1:0]),
    .req_strict_algn_ls_o         (req_strict_algn_ls),
    .check_x64_ls_o               (check_x64_ls),
    .algn_size_ls_o               (algn_size_ls[2:0]),
    .word_align_pc_ls_o           (word_align_pc_ls),
    .ls_store_ls_o                (ls_store_ls),
    .ls_instr_type_ls_o           (ls_instr_type_ls[`CA53_LS_INSTR_TYPE_W-1:0]),
    .ls_isv_set_ls_o              (ls_isv_set_ls),
    .ls_synd_sf_ls_o              (ls_synd_sf_ls),
    .ls_elem_size_ls_o            (ls_elem_size_ls[1:0]),
    .ls_size_ls_o                 (ls_size_ls[2:0]),
    .ls_length_ls_o               (ls_length_ls[4:0]),
    .cp_ls_o                      (cp_ls),
    .cp_op_ls_o                   (cp_op_ls[8:0]),
    .cp_op_mva_ls_o               (cp_op_mva_ls),
    .force_usr_priv_mem_ls_o      (force_usr_priv_mem_ls),
    .usr_mode_regs_ldm_ls_o       (usr_mode_regs_ldm_ls),
    .agu_shf_value_ls_o           (agu_shf_value_ls[1:0]),
    .agu_sub_b_ls_o               (agu_sub_b_ls),
    .br_return_ls_o               (br_return_ls),
    .br_btac_ls_o                 (br_btac_ls),
    .pred_br_ls_o                 (pred_br_ls),
    .br_pred_takenness_ls_o       (br_pred_takenness_ls),
    .rtn_addr_valid_ls_o          (rtn_addr_valid_ls),
    .enable_base_restore_ls_o     (enable_base_restore_ls),
    .srs_mode_ctl_ls_o            (srs_mode_ctl_ls),
    .psr_wr_operation_ls_o        (psr_wr_operation_ls),
    .psr_wr_en_ls_o               (psr_wr_en_ls),
    .psr_wr_src_ls_o              (psr_wr_src_ls),
    .instr_type_ls_o              (instr_type_ls[`CA53_INSTR_TYPE_W-1:0]),
    .early_expt_enable_ls_o       (early_expt_enable_ls),
    .expt_instr_type_ls_o         (expt_instr_type_ls[`CA53_EXPT_INSTR_TYPE_W-1:0]),
    .skid_x64_multiple_ls_o       (skid_x64_multiple_ls),
    .head_instr_ls_o              (head_instr_ls),
    .end_instr_ls_o               (end_instr_ls),
    .last_cycle_ls_o              (last_cycle_ls),
    .nxt_decoder_fsm_ls_o         (nxt_decoder_fsm_ls[4:0]),
    .nxt_lsm_state_ls_o           (nxt_lsm_state_ls),
    .ls_synd_srt_ls_o             (ls_synd_srt_ls),
    .postfix_srs_mode_ls_o        (postfix_srs_mode_ls),
    .exp_srs_mode_ls_o            (exp_srs_mode_ls)
  );

  // ------------------------------------------------------
  // Slot-0 branch decoder
  // ------------------------------------------------------
  ca53dpu_dec0_br u_dec0_br (
    // Inputs
    .iq_instr_dec0_br_i            (iq_instr0_common[32:0]),
    .aarch64_state_i               (iq_instr0_common_aarch64),
    .pdtype_i                      (iq_instr0_pdtype[1:0]),
    .br_taken_i                    (iq_instr0_common_br_taken),
    // Outputs
    .rf_rd_en_r0_dec0_br_o         (rf_rd_en_r0_dec0_br),
    .rf_rd_en_r1_dec0_br_o         (rf_rd_en_r1_dec0_br),
    .rf_rd_need_r0_dec0_br_o       (rf_rd_need_r0_dec0_br[`CA53_RF_RD_NEED_W-1:0]),
    .rf_rd_need_r1_dec0_br_o       (rf_rd_need_r1_dec0_br[`CA53_RF_RD_NEED_W-1:0]),
    .rf_wr_vaddr_w1_dec0_br_o      (rf_wr_vaddr_w1_dec0_br[4:0]),
    .rf_wr_en_w1_dec0_br_o         (rf_wr_en_w1_dec0_br),
    .rf_wr_64b_w1_dec0_br_o        (rf_wr_64b_w1_dec0_br),
    .rf_wr_src_w1_dec0_br_o        (rf_wr_src_w1_dec0_br[`CA53_RF_WR_SRC_W1_W-1:0]),
    .rf_wr_when_w1_dec0_br_o       (rf_wr_when_w1_dec0_br[`CA53_RF_WR_WHEN_W-1:0]),
    .dp_data_a_sel_dec0_br_o       (alu_data_a_sel_dec0_br[`CA53_SEL_SHF_A_W-1:0]),
    .dp_data_b_sel_dec0_br_o       (alu_data_b_sel_dec0_br[`CA53_SEL_SHF_B_W-1:0]),
    .dp_data_c_sel_dec0_br_o       (alu_data_c_sel_dec0_br[`CA53_SEL_SHF_C_W-1:0]),
    .str_data_a_sel_dec0_br_o      (str_data_a_sel_dec0_br[`CA53_SEL_STR_A_W-1:0]),
    .str_data_b_sel_dec0_br_o      (str_data_b_sel_dec0_br[`CA53_SEL_STR_B_W-1:0]),
    .str_b_valid_dec0_br_o         (str_b_valid_dec0_br),
    .ctl_64bit_op_str_dec0_br_o    (ctl_64bit_op_str_dec0_br),
    .ex_pipe_dec0_br_o             (ex_pipe_dec0_br[`CA53_EX_PIPE_W-1:0]),
    .imm_data_dec0_br_o            (imm_data_dec0_br[`CA53_IMM_DATA_W-1:0]),
    .imm_shift_dec0_br_o           (imm_shift_dec0_br[`CA53_IMM_SHIFT_W-1:0]),
    .br_pipectl_dec0_br_o          (br_pipectl_dec0_br[`CA53_BR_PIPECTL_W-1:0]),
    .alu_pipectl_dec0_br_o         (alu_pipectl_dec0_br[`CA53_ALU_PIPECTL_W-1:0]),
    .br_btac_dec0_br_o             (br_btac_dec0_br),
    .br_return_dec0_br_o           (br_return_dec0_br),
    .rtn_addr_valid_dec0_br_o      (rtn_addr_valid_dec0_br),
    .pred_br_dec0_br_o             (pred_br_dec0_br),
    .br_offset_dec0_br_o           (br_offset_dec0_br[27:1]),
    .br_pred_takenness_dec0_br_o   (br_pred_takenness_dec0_br),
    .br_call_dec0_br_o             (br_call_dec0_br),
    .br_x_bit_dec0_br_o            (br_x_bit_dec0_br),
    .psr_wr_operation_dec0_br_o    (psr_wr_operation_dec0_br),
    .psr_wr_en_dec0_br_o           (psr_wr_en_dec0_br),
    .psr_wr_src_dec0_br_o          (psr_wr_src_dec0_br),
    .cond_code_dec0_br_o           (cond_code_dec0_br[3:0])
  );

  // ------------------------------------------------------
  // Slot-0 other decoder
  // ------------------------------------------------------
  ca53dpu_dec0_other `CA53_DPU_PARAM_INST u_dec0_other (
    // Inputs
    .clk                          (clk),
    .reset_n                      (reset_n),
    .iq_instr_en_other_i          (iq_instr0_en_other),
    .iq_instr_other_i             (iq_instr0_other[32:0]),
    .br_taken_i                   (iq_instr0_other_br_taken),
    .decoder_fsm_i                (decoder_fsm_other[3:0]),
    .aarch64_state_i              (iq_instr0_other_aarch64),
    .aarch64_at_el3_i             (aarch64_at_el3_i),
    .dpu_exception_level_i        (dpu_exception_level_i),
    .in_halt_i                    (in_halt_i),
    .ns_scr_i                     (ns_scr_i),
    .ns_state_i                   (ns_state_de_i),
    .usr_de_i                     (spec_cpsr_mode_usr_iss_i),
    .monitor_mode_de_i            (spec_cpsr_mode_mon_iss_i),
    .hyp_mode_de_i                (spec_cpsr_mode_hyp_iss_i),
    .hcr_force_broadcast_i        (hcr_fb_i),
    .hcr_barrier_shareability_i   (hcr_bsu_i[1:0]),
    .hcr_imo_i                    (hcr_imo_i),
    .hcr_fmo_i                    (hcr_fmo_i),
    .hyp_or_mon_de_i              (hyp_or_mon_de),
    .el0_or_sys_de_i              (el0_or_sys_de),
    .elxt_de_i                    (elxt_de),
    .gov_cp15sdisable_i           (gov_cp15sdisable_i),
    .giccdisable_i                (giccdisable_i),
    .force_clean_to_invalidate_i  (force_clean_to_invalidate_i),
    .pdtype_i                     (iq_instr0_other_pdtype),
    // Outputs
    .mcr_mrc_valid_o              (mcr_mrc_valid_de),
    .rf_rd_en_r0_other_o          (rf_rd_en_r0_other),
    .rf_rd_en_r1_other_o          (rf_rd_en_r1_other),
    .rf_rd_en_r2_other_o          (rf_rd_en_r2_other),
    .rf_rd_en_r3_other_o          (rf_rd_en_r3_other),
    .rf_rd_need_r0_other_o        (rf_rd_need_r0_other[`CA53_RF_RD_NEED_W-1:0]),
    .rf_rd_need_r1_other_o        (rf_rd_need_r1_other[`CA53_RF_RD_NEED_W-1:0]),
    .rf_wr_vaddr_w0_other_o       (rf_wr_vaddr_w0_other[4:0]),
    .rf_wr_vaddr_w1_other_o       (rf_wr_vaddr_w1_other[4:0]),
    .rf_wr_en_w0_other_o          (rf_wr_en_w0_other),
    .rf_wr_en_w1_other_o          (rf_wr_en_w1_other),
    .rf_wr_64b_w0_other_o         (rf_wr_64b_w0_other),
    .rf_wr_64b_w1_other_o         (rf_wr_64b_w1_other),
    .rf_wr_src_w0_other_o         (rf_wr_src_w0_other[`CA53_RF_WR_SRC_W0_W-1:0]),
    .rf_wr_src_w1_other_o         (rf_wr_src_w1_other[`CA53_RF_WR_SRC_W1_W-1:0]),
    .rf_wr_when_w0_other_o        (rf_wr_when_w0_other[`CA53_RF_WR_WHEN_W-1:0]),
    .rf_wr_when_w1_other_o        (rf_wr_when_w1_other[`CA53_RF_WR_WHEN_W-1:0]),
    .agu_data_a_sel_other_o       (agu_data_a_sel_other[`CA53_SEL_DCU_A_W-1:0]),
    .agu_data_b_sel_other_o       (agu_data_b_sel_other[`CA53_SEL_DCU_B_W-1:0]),
    .str_data_a_sel_other_o       (str_data_a_sel_other[`CA53_SEL_STR_A_W-1:0]),
    .str_data_b_sel_other_o       (str_data_b_sel_other[`CA53_SEL_STR_B_W-1:0]),
    .str_b_valid_other_o          (str_b_valid_other),
    .ctl_64bit_op_str_other_o     (ctl_64bit_op_str_other),
    .str1_sel_other_o             (str1_sel_other),
    .ex_pipe_other_o              (ex_pipe_other[`CA53_EX_PIPE_W-1:0]),
    .imm_data_other_o             (imm_data_other[`CA53_IMM_DATA_W-1:0]),
    .imm_shift_other_o            (imm_shift_other[`CA53_IMM_SHIFT_W-1:0]),
    .br_pipectl_other_o           (br_pipectl_other[`CA53_BR_PIPECTL_W-1:0]),
    .alu_pipectl_other_o          (alu_pipectl_other[`CA53_ALU_PIPECTL_W-1:0]),
    .dp_data_c_sel_other_o        (alu_data_c_sel_other[`CA53_SEL_SHF_C_W-1:0]),
    .dp_data_b_sel_other_o        (alu_data_b_sel_other[`CA53_SEL_SHF_B_W-1:0]),
    .dp_data_a_sel_other_o        (alu_data_a_sel_other[`CA53_SEL_SHF_A_W-1:0]),
    .algn_size_other_o            (algn_size_other[2:0]),
    .ls_store_other_o             (ls_store_other),
    .ls_size_other_o              (ls_size_other[2:0]),
    .ls_length_other_o            (ls_length_other[4:0]),
    .ls_instr_type_other_o        (ls_instr_type_other[`CA53_LS_INSTR_TYPE_W-1:0]),
    .cp_other_o                   (cp_other),
    .cp_op_other_o                (cp_op_other[8:0]),
    .cp_op_mva_other_o            (cp_op_mva_other),
    .cp_op_ats1_other_o           (cp_op_ats1_other),
    .cp_other_sec_other_o         (cp_other_sec_other),
    .cp_valid_other_o             (cp_valid_other),
    .cp_decode_other_o            (cp_decode_other[8:0]),
    .fp_serialise_other_o         (fp_serialise_other),
    .msr_mrs_reg_wr_other_o       (msr_mrs_reg_wr_other),
    .msr_mrs_reg_rd_other_o       (msr_mrs_reg_rd_other),
    .msr_mrs_spsr_other_o         (msr_mrs_spsr_other),
    .msr_mrs_data_other_o         (msr_mrs_data_other[5:0]),
    .force_usr_priv_mem_other_o   (force_usr_priv_mem_other),
    .br_pred_takenness_other_o    (br_pred_takenness_other),
    .t16_it_cpsr_valid_other_o    (t16_it_cpsr_valid_other),
    .t16_it_cpsr_mask_other_o     (t16_it_cpsr_mask_other[7:0]),
    .cpsr_aifbits_value_other_o   (cpsr_aifbits_value_other[5:0]),
    .cpsr_ebit_value_other_o      (cpsr_ebit_value_other),
    .psr_wr_operation_other_o     (psr_wr_operation_other),
    .psr_wr_en_other_o            (psr_wr_en_other),
    .psr_wr_src_other_o           (psr_wr_src_other),
    .instr_type_other_o           (instr_type_other[`CA53_INSTR_TYPE_W-1:0]),
    .early_expt_enable_other_o    (early_expt_enable_other),
    .expt_instr_type_other_o      (expt_instr_type_other[`CA53_EXPT_INSTR_TYPE_W-1:0]),
    .cond_code_other_o            (cond_code_other[3:0]),
    .head_instr_other_o           (head_instr_other),
    .end_instr_other_o            (end_instr_other),
    .nxt_decoder_fsm_other_o      (nxt_decoder_fsm_other[3:0])
  );

  // ------------------------------------------------------
  // Slot-0 force operation decoder
  // ------------------------------------------------------

  ca53dpu_dec_forceop `CA53_DPU_PARAM_INST u_dec0_forceop (
    // Inputs
    .forceop_type_i             (forceop_type_i[`CA53_FORCEOP_TYPE_W-1:0]),
    .forceop_offset_i           (forceop_offset_i[`CA53_FORCEOP_OFFSET_W-1:0]),
    .forceop_aa64_i             (forceop_aa64_i),
    .aarch64_state_i            (aarch64_state_i),
    .dpu_exception_level_i      (dpu_exception_level_i[1:0]),
    // Outputs
    .rf_wr_vaddr_w1_force_o     (rf_wr_vaddr_w1_force[4:0]),
    .rf_wr_en_w1_force_o        (rf_wr_en_w1_force),
    .rf_wr_64b_w1_force_o       (rf_wr_64b_w1_force),
    .rf_wr_src_w1_force_o       (rf_wr_src_w1_force[`CA53_RF_WR_SRC_W1_W-1:0]),
    .rf_wr_when_w1_force_o      (rf_wr_when_w1_force[`CA53_RF_WR_WHEN_W-1:0]),
    .dp_data_a_sel_force_o      (alu_data_a_sel_force[`CA53_SEL_SHF_A_W-1:0]),
    .dp_data_b_sel_force_o      (alu_data_b_sel_force[`CA53_SEL_SHF_B_W-1:0]),
    .ex_pipe_force_o            (ex_pipe_force[`CA53_EX_PIPE_W-1:0]),
    .imm_data_force_o           (imm_data_force[`CA53_IMM_DATA_W-1:0]),
    .alu_pipectl_force_o        (alu_pipectl_force[`CA53_ALU_PIPECTL_W-1:0]),
    .msr_mrs_reg_wr_force_o     (msr_mrs_reg_wr_force),
    .msr_mrs_data_force_o       (msr_mrs_data_force[5:0])
  );

  // ------------------------------------------------------
  // Slot-0 Neon decoder
  // ------------------------------------------------------

generate if (NEON_FP) begin : NEON1
  reg                       [1:0] iq_instr0_fn_iss_reg_hi;
  reg                      [28:0] iq_instr0_fn_iss_reg_lo;
  reg                             iq_instr0_fn_pdtype_iss_reg;
  reg                             iq_instr0_fn_aarch64_iss_reg;
  reg                       [2:0] decoder_fsm_fn_iss_reg;
  reg                             decoder_select0_ne_iss_reg;
  reg                             dec0_neon_uses_pipe1_iss_reg;
  reg                       [2:0] mul_neon_out_fmt_iss;
  wire                      [2:0] mul_neon_out_fmt_neon;

  ca53dpu_dec0_neon `CA53_DPU_PARAM_INST u_dec0_neon (
    // Inputs
    .iq_instr_fn_i              (iq_instr0_fn[32:0]),
    .decoder_fsm_i              (decoder_fsm_fn[5:0]),
    .lsm_state_i                (lsm_state[9:0]),
    .aarch64_state_i            (iq_instr0_fn_aarch64),
    .pdtype_i                   (iq_instr0_fn_pdtype),
    // Outputs
    .rf_rd_en_r0_neon_o         (rf_rd_en_r0_neon),
    .rf_rd_en_r1_neon_o         (rf_rd_en_r1_neon),
    .rf_rd_en_r2_neon_o         (rf_rd_en_r2_neon),
    .rf_rd_en_r3_neon_o         (rf_rd_en_r3_neon),
    .rf_rd_need_r0_neon_o       (rf_rd_need_r0_neon[`CA53_RF_RD_NEED_W-1:0]),
    .rf_rd_need_r1_neon_o       (rf_rd_need_r1_neon[`CA53_RF_RD_NEED_W-1:0]),
    .rf_rd_need_r2_neon_o       (rf_rd_need_r2_neon[`CA53_RF_RD_NEED_W-1:0]),
    .rf_wr_vaddr_w0_neon_o      (rf_wr_vaddr_w0_neon[4:0]),
    .rf_wr_en_w0_neon_o         (rf_wr_en_w0_neon),
    .rf_wr_64b_w0_neon_o        (rf_wr_64b_w0_neon),
    .rf_wr_vaddr_w1_neon_o      (rf_wr_vaddr_w1_neon[4:0]),
    .rf_wr_en_w1_neon_o         (rf_wr_en_w1_neon),
    .rf_wr_64b_w1_neon_o        (rf_wr_64b_w1_neon),
    .rf_wr_src_w0_neon_o        (rf_wr_src_w0_neon[`CA53_RF_WR_SRC_W0_W-1:0]),
    .rf_wr_src_w1_neon_o        (rf_wr_src_w1_neon[`CA53_RF_WR_SRC_W1_W-1:0]),
    .rf_wr_when_w0_neon_o       (rf_wr_when_w0_neon[`CA53_RF_WR_WHEN_W-1:0]),
    .rf_wr_when_w1_neon_o       (rf_wr_when_w1_neon_preskew[`CA53_RF_WR_WHEN_W-1:0]),
    .rf_rd_addr_fr0_neon_o      (rf_rd_addr_fr0_neon[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_addr_fr1_neon_o      (rf_rd_addr_fr1_neon[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_addr_fr2_neon_o      (rf_rd_addr_fr2_neon[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_addr_fr3_neon_o      (rf_rd_addr_fr3_neon[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_addr_fr4_neon_o      (rf_rd_addr_fr4_neon[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_addr_fr5_neon_o      (rf_rd_addr_fr5_neon[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_en_fr0_neon_o        (rf_rd_en_fr0_neon[1:0]),
    .rf_rd_en_fr1_neon_o        (rf_rd_en_fr1_neon[1:0]),
    .rf_rd_en_fr2_neon_o        (rf_rd_en_fr2_neon[1:0]),
    .rf_rd_en_fr3_neon_o        (rf_rd_en_fr3_neon[1:0]),
    .rf_rd_en_fr4_neon_o        (rf_rd_en_fr4_neon[1:0]),
    .rf_rd_en_fr5_neon_o        (rf_rd_en_fr5_neon[1:0]),
    .rf_rd_need_fr0_neon_o      (rf_rd_need_fr0_neon[`CA53_RF_FRD_NEED_W-1:0]),
    .rf_rd_need_fr1_neon_o      (rf_rd_need_fr1_neon[`CA53_RF_FRD_NEED_W-1:0]),
    .rf_rd_need_fr2_neon_o      (rf_rd_need_fr2_neon[`CA53_RF_FRD_NEED_W-1:0]),
    .rf_rd_need_fr3_neon_o      (rf_rd_need_fr3_neon[`CA53_RF_FRD_NEED_W-1:0]),
    .rf_rd_need_fr4_neon_o      (rf_rd_need_fr4_neon[`CA53_RF_FRD_NEED_W-1:0]),
    .rf_rd_need_fr5_neon_o      (rf_rd_need_fr5_neon[`CA53_RF_FRD_NEED_W-1:0]),
    .rf_wr_addr_fw0_neon_o      (rf_wr_addr_fw0_neon[`CA53_FP_RF_WR_ADDR_W-1:0]),
    .rf_wr_addr_fw1_neon_o      (rf_wr_addr_fw1_neon[`CA53_FP_RF_WR_ADDR_W-1:0]),
    .rf_wr_en_fw0_neon_o        (rf_wr_en_fw0_neon[3:0]),
    .rf_wr_en_fw1_neon_o        (rf_wr_en_fw1_neon[3:0]),
    .rf_wr_src_fw0_neon_o       (rf_wr_src_fw0_neon[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_when_fw0_neon_o      (rf_wr_when_fw0_neon[`CA53_RF_FWR_WHEN_W-1:0]),
    .agu_data_a_sel_neon_o      (agu_data_a_sel_neon[`CA53_SEL_DCU_A_W-1:0]),
    .agu_data_b_sel_neon_o      (agu_data_b_sel_neon[`CA53_SEL_DCU_B_W-1:0]),
    .str_data_a_sel_neon_o      (str_data_a_sel_neon[`CA53_SEL_STR_A_W-1:0]),
    .str_data_b_sel_neon_o      (str_data_b_sel_neon[`CA53_SEL_STR_B_W-1:0]),
    .str1_data_a_sel_neon_o     (str1_data_a_sel_neon[`CA53_SEL_STR_A_W-1:0]),
    .str1_data_b_sel_neon_o     (str1_data_b_sel_neon[`CA53_SEL_STR_B_W-1:0]),
    .str1_sel_neon_o            (str1_sel_neon),
    .str_b_valid_neon_o         (str_b_valid_neon),
    .ctl_64bit_op_str_neon_o    (ctl_64bit_op_str_neon),
    .ex_pipe_neon_o             (ex_pipe_neon[`CA53_EX_PIPE_W-1:0]),
    .imm_data_neon_o            (imm_data_neon[`CA53_IMM_DATA_W-1:0]),
    .imm_shift_neon_o           (imm_shift_neon[`CA53_IMM_SHIFT_W-1:0]),
    .alu_pipectl_neon_o         (alu_pipectl_neon[`CA53_ALU_PIPECTL_W-1:0]),
    .req_strict_algn_neon_o     (req_strict_algn_neon),
    .check_x64_neon_o           (check_x64_neon),
    .enable_base_restore_neon_o (enable_base_restore_neon),
    .algn_size_neon_o           (algn_size_neon[2:0]),
    .wd_align_pc_neon_o         (wd_align_pc_neon),
    .ls_store_neon_o            (ls_store_neon),
    .ls_size_neon_o             (ls_size_neon[2:0]),
    .ls_instr_type_neon_o       (ls_instr_type_neon[`CA53_LS_INSTR_TYPE_W-1:0]),
    .ls_elem_size_neon_o        (ls_elem_size_neon[2:0]),
    .ls_length_neon_o           (ls_length_neon[5:0]),
    .agu_shf_value_neon_o       (agu_shf_value_neon[2:0]),
    .agu_sub_b_neon_o           (agu_sub_b_neon),
    .fmac_valid_sp_neon_o       (fmac_valid_sp_neon),
    .fdiv_valid_neon_o          (fdiv_valid_neon),
    .neon_can_fwd_acc_neon_o    (neon_can_fwd_acc_neon),
    .mul_neon_out_fmt_neon_o    (mul_neon_out_fmt_neon[2:0]),
    .no_interrupt_neon_o        (no_interrupt_neon),
    .en_decoder_lsm_neon_o      (en_decoder_lsm_neon),
    .nxt_lsm_state_neon_o       (nxt_lsm_state_neon[9:0]),
    .fp_ex_pipe_neon_o          (fp_ex_pipe_neon),
    .crypto_enable_neon_o       (crypto_enable_neon),
    .cp_valid_neon_o            (cp_valid_neon),
    .cp_decode_neon_o           (cp_decode_neon[8:0]),
    .fp_serialise_neon_o        (fp_serialise_neon),
    .psr_wr_operation_neon_o    (psr_wr_operation_neon),
    .psr_wr_en_neon_o           (psr_wr_en_neon),
    .psr_wr_src_neon_o          (psr_wr_src_neon),
    .no_insert_neon_o           (no_insert_neon),
    .early_expt_enable_neon_o   (early_expt_enable_neon),
    .expt_instr_type_neon_o     (expt_instr_type_neon[`CA53_EXPT_INSTR_TYPE_W-1:0]),
    .skid_x64_multiple_neon_o   (skid_x64_multiple_neon),
    .head_instr_neon_o          (head_instr_neon),
    .end_instr_neon_o           (end_instr_neon),
    .msk_data_sel_neon_o        (alu_msk_data_sel_neon),
    .dp_data_a_sel_neon_o       (alu_data_a_sel_neon[`CA53_SEL_SHF_A_W-1:0]),
    .dp_data_b_sel_neon_o       (alu_data_b_sel_neon[`CA53_SEL_SHF_B_W-1:0]),
    .dp_data_c_sel_neon_o       (alu_data_c_sel_neon[`CA53_SEL_SHF_C_W-1:0]),
    .nxt_decoder_fsm_neon_o     (nxt_decoder_fsm_neon[5:0]),
    .neon_vld_ctl_neon_o        (neon_vld_ctl_neon[`CA53_NEON_VLD_CTL_W-1:0]),
    .instr_fmstat_neon_o        (instr_fmstat_neon)
  );

  // The Iss-stage Neon decoder does not read all bits of iq_instr0_fn or
  // decoder_fsm. Only register used bits.
  always @(posedge clk)
    if (issue_to_iss_fpu_i) begin
      iq_instr0_fn_iss_reg_hi      <= iq_instr0_fn[32:31];
      iq_instr0_fn_iss_reg_lo      <= iq_instr0_fn[28:0];
      iq_instr0_fn_pdtype_iss_reg  <= iq_instr0_fn_pdtype[0];
      iq_instr0_fn_aarch64_iss_reg <= iq_instr0_fn_aarch64;
      decoder_fsm_fn_iss_reg       <= decoder_fsm_fn[2:0];
      mul_neon_out_fmt_iss         <= mul_neon_out_fmt_neon;
    end

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      decoder_select0_ne_iss_reg   <= 1'b0;
      dec0_neon_uses_pipe1_iss_reg <= 1'b0;
    end else if (issue_to_iss_i) begin
      decoder_select0_ne_iss_reg   <= decoder_select0[NE];
      dec0_neon_uses_pipe1_iss_reg <= dec0_neon_uses_pipe1_de;
    end

  assign iq_instr0_fn_iss         = {iq_instr0_fn_iss_reg_hi[1:0],   // [32:31]
                                     {2{1'b0}},                      // [30:29]
                                     iq_instr0_fn_iss_reg_lo[28:0]}; // [28:0]
  assign iq_instr0_fn_pdtype_iss  = iq_instr0_fn_pdtype_iss_reg;
  assign iq_instr0_fn_aarch64_iss = iq_instr0_fn_aarch64_iss_reg;
  assign decoder_fsm_fn_iss       = { {3{1'b0}}, decoder_fsm_fn_iss_reg[2:0]};

  assign decoder_select0_ne_iss   = decoder_select0_ne_iss_reg;
  assign dec0_neon_uses_pipe1_iss = dec0_neon_uses_pipe1_iss_reg;

  if (CRYPTO) begin : g_crypto
    reg        aes_op_merged_iss_reg;
    wire       nxt_aes_op_merged_iss;

    // Register whether an AESIMC/AESMC instruction has dual-issued
    assign nxt_aes_op_merged_iss = iq_instr1_is_aesimc_aesmc & valid_instrs_de[1];

    always @(posedge clk)
      if (issue_to_iss_fpu_i)
        aes_op_merged_iss_reg <= nxt_aes_op_merged_iss;

    assign aes_op_merged_iss = aes_op_merged_iss_reg;

  end else begin : g_crypto_stubs
    assign aes_op_merged_iss = 1'b0;
  end

  ca53dpu_dec_late_neon `CA53_DPU_PARAM_INST u_dec_late_neon (
    // Inputs
    .iq_instr_fn_i              (iq_instr0_fn_iss[32:0]),
    .iq_instr0_fn_pdtype_iss_i  (iq_instr0_fn_pdtype_iss),
    .aarch64_state_i            (iq_instr0_fn_aarch64_iss),
    .aes_op_merged_iss_i        (aes_op_merged_iss),
    .decoder_fsm_i              (decoder_fsm_fn_iss[2:0]),
    .exception_valid_iss_i      (exception_valid_iss_i),
    .mul_neon_out_fmt_iss_i     (mul_neon_out_fmt_iss[2:0]),
    // Outputs
    .fp_cflag_src_neon_o        (fp_cflag_src_neon[`CA53_FP_CFLAG_SRC_W-1:0]),
    .fp_xflag_src_neon_o        (fp_xflag_src_neon[`CA53_FP_XFLAG_SRC_W-1:0]),
    .fp_pipectl_neon_o          (fp_pipectl_neon),
    .sel_fml_a_neon_o           (sel_fml_a_neon),
    .sel_fml_b_neon_o           (sel_fml_b_neon[`CA53_SEL_FML_B_W-1:0]),
    .sel_fml_c_neon_o           (sel_fml_c_neon),
    .sel_fad_a_neon_o           (sel_fad_a_neon[`CA53_SEL_FAD_A_W-1:0]),
    .sel_fad_b_neon_o           (sel_fad_b_neon[`CA53_SEL_FAD_B_W-1:0]),
    .sel_fad_c_neon_o           (sel_fad_c_neon[`CA53_SEL_FAD_C_W-1:0])
  );

end else begin : NEON1_STUBS
  // Assign all Neon signals to 1'b0 if the Neon unit is not used.
  assign rf_rd_en_r0_neon         = 1'b0;
  assign rf_rd_en_r1_neon         = 1'b0;
  assign rf_rd_en_r2_neon         = 1'b0;
  assign rf_rd_en_r3_neon         = 1'b0;
  assign rf_rd_need_r0_neon       = {3{1'b0}};
  assign rf_rd_need_r1_neon       = {3{1'b0}};
  assign rf_rd_need_r2_neon       = {3{1'b0}};
  assign rf_wr_vaddr_w0_neon      = {5{1'b0}};
  assign rf_wr_en_w0_neon         = 1'b0;
  assign rf_wr_64b_w0_neon        = 1'b0;
  assign rf_wr_vaddr_w1_neon      = {5{1'b0}};
  assign rf_wr_en_w1_neon         = 1'b0;
  assign rf_wr_64b_w1_neon        = 1'b0;
  assign rf_wr_src_w0_neon        = {`CA53_RF_WR_SRC_W0_W{1'b0}};
  assign rf_wr_src_w1_neon        = {`CA53_RF_WR_SRC_W1_W{1'b0}};
  assign rf_wr_when_w0_neon       = {`CA53_RF_WR_WHEN_W{1'b0}};
  assign rf_wr_when_w1_neon_preskew = {`CA53_RF_WR_WHEN_W{1'b0}};
  assign rf_rd_addr_fr0_neon      = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
  assign rf_rd_addr_fr1_neon      = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
  assign rf_rd_addr_fr2_neon      = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
  assign rf_rd_addr_fr3_neon      = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
  assign rf_rd_addr_fr4_neon      = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
  assign rf_rd_addr_fr5_neon      = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
  assign rf_rd_en_fr0_neon        = {2{1'b0}};
  assign rf_rd_en_fr1_neon        = {2{1'b0}};
  assign rf_rd_en_fr2_neon        = {2{1'b0}};
  assign rf_rd_en_fr3_neon        = {2{1'b0}};
  assign rf_rd_en_fr4_neon        = {2{1'b0}};
  assign rf_rd_en_fr5_neon        = {2{1'b0}};
  assign rf_rd_need_fr0_neon      = {`CA53_RF_FRD_NEED_W{1'b0}};
  assign rf_rd_need_fr1_neon      = {`CA53_RF_FRD_NEED_W{1'b0}};
  assign rf_rd_need_fr2_neon      = {`CA53_RF_FRD_NEED_W{1'b0}};
  assign rf_rd_need_fr3_neon      = {`CA53_RF_FRD_NEED_W{1'b0}};
  assign rf_rd_need_fr4_neon      = {`CA53_RF_FRD_NEED_W{1'b0}};
  assign rf_rd_need_fr5_neon      = {`CA53_RF_FRD_NEED_W{1'b0}};
  assign rf_wr_addr_fw0_neon      = {`CA53_FP_RF_WR_ADDR_W{1'b0}};
  assign rf_wr_addr_fw1_neon      = {`CA53_FP_RF_WR_ADDR_W{1'b0}};
  assign rf_wr_en_fw0_neon        = {4{1'b0}};
  assign rf_wr_en_fw1_neon        = {4{1'b0}};
  assign rf_wr_src_fw0_neon       = {`CA53_RF_FWR_SRC_W{1'b0}};
  assign rf_wr_when_fw0_neon      = {`CA53_RF_FWR_WHEN_W{1'b0}};
  assign alu_msk_data_sel_neon    = 1'b0;
  assign alu_data_a_sel_neon      = {`CA53_SEL_SHF_A_W{1'b0}};
  assign alu_data_b_sel_neon      = {`CA53_SEL_SHF_B_W{1'b0}};
  assign alu_data_c_sel_neon      = {`CA53_SEL_SHF_C_W{1'b0}};
  assign agu_data_a_sel_neon      = {`CA53_SEL_DCU_A_W{1'b0}};
  assign agu_data_b_sel_neon      = {`CA53_SEL_DCU_B_W{1'b0}};
  assign str_data_a_sel_neon      = {`CA53_SEL_STR_A_W{1'b0}};
  assign str_data_b_sel_neon      = {`CA53_SEL_STR_B_W{1'b0}};
  assign str1_data_a_sel_neon     = {`CA53_SEL_STR_A_W{1'b0}};
  assign str1_data_b_sel_neon     = {`CA53_SEL_STR_B_W{1'b0}};
  assign str1_sel_neon            = 1'b0;
  assign str_b_valid_neon         = 1'b0;
  assign ctl_64bit_op_str_neon    = 1'b0;
  assign ex_pipe_neon             = {`CA53_EX_PIPE_W{1'b0}};
  assign imm_data_neon            = {`CA53_IMM_DATA_W{1'b0}};
  assign imm_shift_neon           = {`CA53_IMM_SHIFT_W{1'b0}};
  assign alu_pipectl_neon         = {`CA53_ALU_PIPECTL_W{1'b0}};
  assign req_strict_algn_neon     = 1'b0;
  assign check_x64_neon           = 1'b0;
  assign algn_size_neon           = 3'b000;
  assign wd_align_pc_neon         = 1'b0;
  assign ls_store_neon            = 1'b0;
  assign ls_size_neon             = {3{1'b0}};
  assign ls_instr_type_neon       = {`CA53_LS_INSTR_TYPE_W{1'b0}};
  assign ls_elem_size_neon        = {3{1'b0}};
  assign ls_length_neon           = {6{1'b0}};
  assign agu_sub_b_neon           = 1'b0;
  assign fmac_valid_sp_neon       = 1'b0;
  assign fdiv_valid_neon          = 1'b0;
  assign neon_can_fwd_acc_neon    = 1'b0;
  assign neon_vld_ctl_neon        = {`CA53_NEON_VLD_CTL_W{1'b0}};
  assign no_interrupt_neon        = 1'b0;
  assign en_decoder_lsm_neon      = 1'b0;
  assign nxt_lsm_state_neon       = {10{1'b0}};
  assign fp_cflag_src_neon        = {`CA53_FP_CFLAG_SRC_W{1'b0}};
  assign fp_xflag_src_neon        = {`CA53_FP_XFLAG_SRC_W{1'b0}};
  assign fp_ex_pipe_neon          = {`CA53_FP_EX_PIPE_W{1'b0}};
  assign crypto_enable_neon       = 1'b0;
  assign fp_pipectl_neon          = {`CA53_FP_PIPECTL_W{1'b0}};
  assign sel_fml_a_neon           = 1'b0;
  assign sel_fml_b_neon           = {`CA53_SEL_FML_B_W{1'b0}};
  assign sel_fml_c_neon           = 1'b0;
  assign sel_fad_a_neon           = {`CA53_SEL_FAD_A_W{1'b0}};
  assign sel_fad_b_neon           = {`CA53_SEL_FAD_B_W{1'b0}};
  assign sel_fad_c_neon           = {`CA53_SEL_FAD_C_W{1'b0}};
  assign no_insert_neon           = 1'b0;
  assign early_expt_enable_neon   = 1'b1;
  assign expt_instr_type_neon     = `CA53_EXPT_INSTR_TYPE_UNDEF;
  assign skid_x64_multiple_neon   = 1'b0;
  assign cp_valid_neon            = 1'b0;
  assign cp_decode_neon           = {9{1'b0}};
  assign fp_serialise_neon        = 1'b0;
  assign psr_wr_operation_neon    = 1'b0;
  assign psr_wr_en_neon           = {6{1'b0}};
  assign psr_wr_src_neon          = {4{1'b0}};
  assign head_instr_neon          = 1'b1;
  assign end_instr_neon           = 1'b1;
  assign nxt_decoder_fsm_neon     = 6'b000001;
  assign instr_fmstat_neon        = 1'b0;
  assign agu_shf_value_neon       = 3'b000;
  assign enable_base_restore_neon = 1'b0;
  assign iq_instr0_fn_iss         = {33{1'b0}};
  assign iq_instr0_fn_pdtype_iss  = 1'b0;
  assign iq_instr0_fn_aarch64_iss = 1'b0;
  assign decoder_fsm_fn_iss       = {6{1'b0}};
  assign decoder_select0_ne_iss   = 1'b0;
  assign dec0_neon_uses_pipe1_iss = 1'b0;
end endgenerate

  // ------------------------------------------------------
  // Slot-1 main decoder
  // ------------------------------------------------------
  // The slot 1 main decoder decodes slot 1 DP instructions, plus NOP and IT.
  // The slot 1 main decoder instructions address R0-2 and W1 (or a subset of
  // those ports), though these are mapped on to different physical regbank
  // ports.
  ca53dpu_dec1 u_dec1 (
    // Inputs
    .iq_instr_dec1_i            (iq_instr1_main[32:0]),
    .iq_instr_dec1_sideband_0_i (iq_instr1_sideband[0]),
    .aarch64_state_i            (iq_instr1_main_aarch64),
    .pdtype_i                   (iq_instr1_pdtype[1:0]),
    .instr_is_dp_i              (iq_instr1_is_dp),
    .instr_is_ot_i              (iq_instr1_is_other),
    .instr0_sets_ccflags_i      (iq_instr0_sets_ccflags),
    // Outputs
    .rf_rd_en_r0_dec1_o         (rf_rd_en_r0_dec1),
    .rf_rd_en_r1_dec1_o         (rf_rd_en_r1_dec1),
    .rf_rd_en_r2_dec1_o         (rf_rd_en_r2_dec1),
    .rf_rd_need_r0_dec1_o       (rf_rd_need_r0_dec1[`CA53_RF_RD_NEED_W-1:0]),
    .rf_rd_need_r1_dec1_o       (rf_rd_need_r1_dec1[`CA53_RF_RD_NEED_W-1:0]),
    .rf_rd_need_r2_dec1_o       (rf_rd_need_r2_dec1[`CA53_RF_RD_NEED_W-1:0]),
    .rf_wr_vaddr_w0_dec1_o      (rf_wr_vaddr_w0_dec1[4:0]),
    .rf_wr_vaddr_w1_dec1_o      (rf_wr_vaddr_w1_dec1[4:0]),
    .rf_wr_en_w0_dec1_o         (rf_wr_en_w0_dec1),
    .rf_wr_en_w1_dec1_o         (rf_wr_en_w1_dec1),
    .rf_wr_64b_w0_dec1_o        (rf_wr_64b_w0_dec1),
    .rf_wr_64b_w1_dec1_o        (rf_wr_64b_w1_dec1),
    .rf_wr_src_w0_dec1_o        (rf_wr_src_w0_dec1[`CA53_RF_WR_SRC_W0_W-1:0]),
    .rf_wr_src_w1_dec1_o        (rf_wr_src_w1_dec1[`CA53_RF_WR_SRC_W1_W-1:0]),
    .rf_wr_when_w0_dec1_o       (rf_wr_when_w0_dec1[`CA53_RF_WR_WHEN_W-1:0]),
    .rf_wr_when_w1_dec1_o       (rf_wr_when_w1_dec1_preskew[`CA53_RF_WR_WHEN_W-1:0]),
    .slot1_instr_type_dec1_o    (slot1_instr_type_dec1[`CA53_SLOT1_INSTR_TYPE_W-1:0]),
    .dp_data_a_sel_dec1_o       (alu_data_a_sel_dec1[`CA53_SEL_SHF_A_W-1:0]),
    .dp_data_b_sel_dec1_o       (alu_data_b_sel_dec1[`CA53_SEL_SHF_B_W-1:0]),
    .dp_data_c_sel_dec1_o       (alu_data_c_sel_dec1[`CA53_SEL_SHF_C_W-1:0]),
    .msk_data_sel_dec1_o        (msk_data_sel_dec1),
    .mac_data_a_sel_dec1_o      (mac_data_a_sel_dec1[`CA53_SEL_MAC_A_W-1:0]),
    .mac_data_b_sel_dec1_o      (mac_data_b_sel_dec1[`CA53_SEL_MAC_B_W-1:0]),
    .str_data_a_sel_dec1_o      (str_data_a_sel_dec1[`CA53_SEL_STR_A_W-1:0]),
    .str_data_b_sel_dec1_o      (str_data_b_sel_dec1[`CA53_SEL_STR_B_W-1:0]),
    .str_b_valid_dec1_o         (str_b_valid_dec1),
    .ctl_64bit_op_str_dec1_o    (ctl_64bit_op_str_dec1),
    .ex_pipe_dec1_o             (ex_pipe_dec1[`CA53_EX_PIPE_W-1:0]),
    .imm_data_dec1_o            (imm_data_dec1[`CA53_IMM_DATA_W-1:0]),
    .imm_shift_dec1_o           (imm_shift_dec1[`CA53_IMM_SHIFT_W-1:0]),
    .imm_data_sel_dec1_o        (imm_data_sel_dec1[`CA53_IMM_SEL_W-1:0]),
    .use_ex1_alu_static_dec1_o  (use_ex1_alu_static_dec1),
    .alu_pipectl_dec1_o         (alu_pipectl_dec1[`CA53_ALU_PIPECTL_W-1:0]),
    .mac_pipectl_dec1_o         (mac_pipectl_dec1[`CA53_MAC_PIPECTL_W-1:0]),
    .word_align_pc_dec1_o       (word_align_pc_dec1),
    .force_cond_always_dec1_o   (force_cond_always_dec1),
    .mul_cpsr_nz_v_dec1_o       (mul_cpsr_nz_v_dec1),
    .flag_en_dec1_o             (flag_en_dec1[`CA53_FLAGEN_INSTR1_W-1:0]),
    .t16_it_cpsr_mask_dec1_o    (t16_it_cpsr_mask_dec1[7:0]),
    .t16_it_cpsr_valid_dec1_o   (t16_it_cpsr_valid_dec1)
  );

  // ------------------------------------------------------
  // Slot-1 branch decoder
  // ------------------------------------------------------
  ca53dpu_dec1_br u_dec1_br (
    // Inputs
    .iq_instr_dec1_br_i            (iq_instr1_common[32:0]),
    .aarch64_state_i               (iq_instr1_common_aarch64),
    .pdtype_i                      (iq_instr1_pdtype[1:0]),
    .br_taken_i                    (iq_instr1_br_taken),
    // Outputs
    .rf_rd_en_r0_dec1_br_o         (rf_rd_en_r0_dec1_br),
    .rf_rd_en_r1_dec1_br_o         (rf_rd_en_r1_dec1_br),
    .rf_rd_need_r0_dec1_br_o       (rf_rd_need_r0_dec1_br[`CA53_RF_RD_NEED_W-1:0]),
    .rf_rd_need_r1_dec1_br_o       (rf_rd_need_r1_dec1_br[`CA53_RF_RD_NEED_W-1:0]),
    .rf_wr_vaddr_w1_dec1_br_o      (rf_wr_vaddr_w1_dec1_br[4:0]),
    .rf_wr_en_w1_dec1_br_o         (rf_wr_en_w1_dec1_br),
    .rf_wr_64b_w1_dec1_br_o        (rf_wr_64b_w1_dec1_br),
    .rf_wr_src_w1_dec1_br_o        (rf_wr_src_w1_dec1_br[`CA53_RF_WR_SRC_W1_W-1:0]),
    .rf_wr_when_w1_dec1_br_o       (rf_wr_when_w1_dec1_br[`CA53_RF_WR_WHEN_W-1:0]),
    .dp_data_a_sel_dec1_br_o       (alu_data_a_sel_dec1_br[`CA53_SEL_SHF_A_W-1:0]),
    .dp_data_b_sel_dec1_br_o       (alu_data_b_sel_dec1_br[`CA53_SEL_SHF_B_W-1:0]),
    .dp_data_c_sel_dec1_br_o       (alu_data_c_sel_dec1_br[`CA53_SEL_SHF_C_W-1:0]),
    .str_data_a_sel_dec1_br_o      (str_data_a_sel_dec1_br[`CA53_SEL_STR_A_W-1:0]),
    .str_data_b_sel_dec1_br_o      (str_data_b_sel_dec1_br[`CA53_SEL_STR_B_W-1:0]),
    .str_b_valid_dec1_br_o         (str_b_valid_dec1_br),
    .ctl_64bit_op_str_dec1_br_o    (ctl_64bit_op_str_dec1_br),
    .ex_pipe_dec1_br_o             (ex_pipe_dec1_br[`CA53_EX_PIPE_W-1:0]),
    .imm_data_dec1_br_o            (imm_data_dec1_br[`CA53_IMM_DATA_W-1:0]),
    .imm_shift_dec1_br_o           (imm_shift_dec1_br[`CA53_IMM_SHIFT_W-1:0]),
    .br_pipectl_dec1_br_o          (br_pipectl_dec1_br[`CA53_BR_PIPECTL_W-1:0]),
    .alu_pipectl_dec1_br_o         (alu_pipectl_dec1_br[`CA53_ALU_PIPECTL_W-1:0]),
    .br_btac_dec1_br_o             (br_btac_dec1_br),
    .br_return_dec1_br_o           (br_return_dec1_br),
    .rtn_addr_valid_dec1_br_o      (rtn_addr_valid_dec1_br),
    .pred_br_dec1_br_o             (pred_br_dec1_br),
    .br_offset_dec1_br_o           (br_offset_dec1_br[27:1]),
    .br_pred_takenness_dec1_br_o   (br_pred_takenness_dec1_br),
    .br_call_dec1_br_o             (br_call_dec1_br),
    .br_x_bit_dec1_br_o            (br_x_bit_dec1_br),
    .slot1_instr_type_dec1_br_o    (slot1_instr_type_dec1_br[`CA53_SLOT1_INSTR_TYPE_W-1:0]),
    .a64_cond_br_dec1_br_o         (a64_cond_br_dec1_br)
  );

  // ------------------------------------------------------
  // Slot-1 load-store decoder
  // ------------------------------------------------------

  ca53dpu_dec1_ls u_dec1_ls (
    // Inputs
    .iq_instr_dec1_ls_i            (iq_instr1_ls[32:0]),
    .iq_instr_sideband_i           (iq_instr1_sideband[5:0]),
    .aarch64_state_i               (iq_instr1_ls_aarch64),
    .pdtype_i                      (iq_instr1_pdtype),
    // Outputs
    .rf_rd_en_r0_dec1_ls_o         (rf_rd_en_r0_dec1_ls),
    .rf_rd_en_r1_dec1_ls_o         (rf_rd_en_r1_dec1_ls),
    .rf_rd_en_r2_dec1_ls_o         (rf_rd_en_r2_dec1_ls),
    .rf_rd_need_r0_dec1_ls_o       (rf_rd_need_r0_dec1_ls[`CA53_RF_RD_NEED_W-1:0]),
    .rf_rd_need_r1_dec1_ls_o       (rf_rd_need_r1_dec1_ls[`CA53_RF_RD_NEED_W-1:0]),
    .rf_rd_need_r2_dec1_ls_o       (rf_rd_need_r2_dec1_ls[`CA53_RF_RD_NEED_W-1:0]),
    .rf_wr_vaddr_w0_dec1_ls_o      (rf_wr_vaddr_w0_dec1_ls[4:0]),
    .rf_wr_vaddr_w1_dec1_ls_o      (rf_wr_vaddr_w1_dec1_ls[4:0]),
    .rf_wr_en_w0_dec1_ls_o         (rf_wr_en_w0_dec1_ls),
    .rf_wr_en_w1_dec1_ls_o         (rf_wr_en_w1_dec1_ls),
    .rf_wr_64b_w0_dec1_ls_o        (rf_wr_64b_w0_dec1_ls),
    .rf_wr_64b_w1_dec1_ls_o        (rf_wr_64b_w1_dec1_ls),
    .rf_wr_src_w0_dec1_ls_o        (rf_wr_src_w0_dec1_ls[`CA53_RF_WR_SRC_W0_W-1:0]),
    .rf_wr_src_w1_dec1_ls_o        (rf_wr_src_w1_dec1_ls[`CA53_RF_WR_SRC_W1_W-1:0]),
    .rf_wr_when_w0_dec1_ls_o       (rf_wr_when_w0_dec1_ls[`CA53_RF_WR_WHEN_W-1:0]),
    .rf_wr_when_w1_dec1_ls_o       (rf_wr_when_w1_dec1_ls_preskew[`CA53_RF_WR_WHEN_W-1:0]),
    .dp_data_a_sel_dec1_ls_o       (alu_data_a_sel_dec1_ls[`CA53_SEL_SHF_A_W-1:0]),
    .dp_data_b_sel_dec1_ls_o       (alu_data_b_sel_dec1_ls[`CA53_SEL_SHF_B_W-1:0]),
    .dp_data_c_sel_dec1_ls_o       (alu_data_c_sel_dec1_ls[`CA53_SEL_SHF_C_W-1:0]),
    .str_data_a_sel_dec1_ls_o      (str_data_a_sel_dec1_ls[`CA53_SEL_STR_A_W-1:0]),
    .str_data_b_sel_dec1_ls_o      (str_data_b_sel_dec1_ls[`CA53_SEL_STR_B_W-1:0]),
    .str_b_valid_dec1_ls_o         (str_b_valid_dec1_ls),
    .ctl_64bit_op_str_dec1_ls_o    (ctl_64bit_op_str_dec1_ls),
    .str1_data_a_sel_dec1_ls_o     (str1_data_a_sel_dec1_ls[`CA53_SEL_STR_A_W-1:0]),
    .str1_data_b_sel_dec1_ls_o     (str1_data_b_sel_dec1_ls[`CA53_SEL_STR_B_W-1:0]),
    .str1_sel_dec1_ls_o            (str1_sel_dec1_ls),
    .agu_data_a_sel_dec1_ls_o      (agu_data_a_sel_dec1_ls[`CA53_SEL_DCU_A_W-1:0]),
    .agu_data_b_sel_dec1_ls_o      (agu_data_b_sel_dec1_ls[`CA53_SEL_DCU_B_W-1:0]),
    .req_strict_algn_dec1_ls_o     (req_strict_algn_dec1_ls),
    .check_x64_dec1_ls_o           (check_x64_dec1_ls),
    .algn_size_dec1_ls_o           (algn_size_dec1_ls[2:0]),
    .ls_store_dec1_ls_o            (ls_store_dec1_ls),
    .ls_elem_size_dec1_ls_o        (ls_elem_size_dec1_ls[1:0]),
    .ls_size_dec1_ls_o             (ls_size_dec1_ls[2:0]),
    .ls_length_dec1_ls_o           (ls_length_dec1_ls[4:0]),
    .force_usr_priv_mem_dec1_ls_o  (force_usr_priv_mem_dec1_ls),
    .agu_shf_value_dec1_ls_o       (agu_shf_value_dec1_ls[1:0]),
    .agu_sub_b_dec1_ls_o           (agu_sub_b_dec1_ls),
    .ls_instr_type_dec1_ls_o       (ls_instr_type_dec1_ls[`CA53_LS_INSTR_TYPE_W-1:0]),
    .ls_synd_srt_dec1_ls_o         (ls_synd_srt_dec1_ls[4:0]),
    .ls_isv_set_dec1_ls_o          (ls_isv_set_dec1_ls),
    .ls_synd_sf_dec1_ls_o          (ls_synd_sf_dec1_ls),
    .ex_pipe_dec1_ls_o             (ex_pipe_dec1_ls[`CA53_EX_PIPE_W-1:0]),
    .imm_data_dec1_ls_o            (imm_data_dec1_ls[`CA53_IMM_DATA_W-1:0]),
    .imm_shift_dec1_ls_o           (imm_shift_dec1_ls[`CA53_IMM_SHIFT_W-1:0]),
    .alu_pipectl_dec1_ls_o         (alu_pipectl_dec1_ls[`CA53_ALU_PIPECTL_W-1:0]),
    .word_align_pc_dec1_ls_o       (word_align_pc_dec1_ls),
    .head_instr_dec1_ls_o          (head_instr_dec1_ls)
  );

  // ------------------------------------------------------
  // Slot-1 Neon decoder
  // ------------------------------------------------------

generate if (NEON_FP) begin : NEON2
  reg                     [32:31] iq_instr1_fn_iss_reg_hi;
  reg                     [28:16] iq_instr1_fn_iss_reg_mid;
  reg                      [11:4] iq_instr1_fn_iss_reg_lo;
  reg                             iq_instr1_fn_pdtype_iss_reg;
  reg                             iq_instr1_fn_aarch64_iss_reg;
  reg                             decoder_select1_ne_iss_reg;
  reg                       [2:0] mul_neon_out_fmt_dec1_iss;
  wire                      [2:0] mul_neon_out_fmt_dec1_ne;

  ca53dpu_dec1_neon u_dec1_neon (
    // Inputs
    .iq_instr_dec1_ne_i            (iq_instr1_fn[32:0]),
    .aarch64_state_i               (iq_instr1_fn_aarch64),
    .pdtype_i                      (iq_instr1_pdtype),
    // Outputs
    .rf_rd_en_r0_dec1_ne_o         (rf_rd_en_r0_dec1_ne),
    .rf_rd_en_r1_dec1_ne_o         (rf_rd_en_r1_dec1_ne),
    .rf_rd_en_r2_dec1_ne_o         (rf_rd_en_r2_dec1_ne),
    .rf_rd_need_r0_dec1_ne_o       (rf_rd_need_r0_dec1_ne[`CA53_RF_RD_NEED_W-1:0]),
    .rf_rd_need_r1_dec1_ne_o       (rf_rd_need_r1_dec1_ne[`CA53_RF_RD_NEED_W-1:0]),
    .rf_wr_vaddr_w0_dec1_ne_o      (rf_wr_vaddr_w0_dec1_ne[4:0]),
    .rf_wr_en_w0_dec1_ne_o         (rf_wr_en_w0_dec1_ne),
    .rf_wr_vaddr_w1_dec1_ne_o      (rf_wr_vaddr_w1_dec1_ne[4:0]),
    .rf_wr_en_w1_dec1_ne_o         (rf_wr_en_w1_dec1_ne),
    .rf_wr_64b_w1_dec1_ne_o        (rf_wr_64b_w1_dec1_ne),
    .rf_wr_src_w0_dec1_ne_o        (rf_wr_src_w0_dec1_ne[`CA53_RF_WR_SRC_W0_W-1:0]),
    .rf_wr_src_w1_dec1_ne_o        (rf_wr_src_w1_dec1_ne[`CA53_RF_WR_SRC_W1_W-1:0]),
    .rf_wr_when_w0_dec1_ne_o       (rf_wr_when_w0_dec1_ne[`CA53_RF_WR_WHEN_W-1:0]),
    .rf_wr_when_w1_dec1_ne_o       (rf_wr_when_w1_dec1_ne_preskew[`CA53_RF_WR_WHEN_W-1:0]),
    .rf_rd_addr_fr0_dec1_ne_o      (rf_rd_addr_fr0_dec1_ne[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_addr_fr1_dec1_ne_o      (rf_rd_addr_fr1_dec1_ne[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_addr_fr2_dec1_ne_o      (rf_rd_addr_fr2_dec1_ne[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_en_fr0_dec1_ne_o        (rf_rd_en_fr0_dec1_ne[1:0]),
    .rf_rd_en_fr1_dec1_ne_o        (rf_rd_en_fr1_dec1_ne[1:0]),
    .rf_rd_en_fr2_dec1_ne_o        (rf_rd_en_fr2_dec1_ne[1:0]),
    .rf_rd_need_fr0_dec1_ne_o      (rf_rd_need_fr0_dec1_ne[`CA53_RF_FRD_NEED_W-1:0]),
    .rf_rd_need_fr1_dec1_ne_o      (rf_rd_need_fr1_dec1_ne[`CA53_RF_FRD_NEED_W-1:0]),
    .rf_rd_need_fr2_dec1_ne_o      (rf_rd_need_fr2_dec1_ne[`CA53_RF_FRD_NEED_W-1:0]),
    .rf_wr_addr_fw0_dec1_ne_o      (rf_wr_addr_fw0_dec1_ne[`CA53_FP_RF_WR_ADDR_W-1:0]),
    .rf_wr_en_fw0_dec1_ne_o        (rf_wr_en_fw0_dec1_ne[3:0]),
    .rf_wr_src_fw0_dec1_ne_o       (rf_wr_src_fw0_dec1_ne[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_when_fw0_dec1_ne_o      (rf_wr_when_fw0_dec1_ne[`CA53_RF_FWR_WHEN_W-1:0]),
    .agu_data_a_sel_dec1_ne_o      (agu_data_a_sel_dec1_ne),
    .agu_data_b_sel_dec1_ne_o      (agu_data_b_sel_dec1_ne),
    .str_data_a_sel_dec1_ne_o      (str_data_a_sel_dec1_ne),
    .str_data_b_sel_dec1_ne_o      (str_data_b_sel_dec1_ne),
    .str1_data_a_sel_dec1_ne_o     (str1_data_a_sel_dec1_ne[`CA53_SEL_STR_A_W-1:0]),
    .str1_data_b_sel_dec1_ne_o     (str1_data_b_sel_dec1_ne[`CA53_SEL_STR_B_W-1:0]),
    .str1_sel_dec1_ne_o            (str1_sel_dec1_ne),
    .str_b_valid_dec1_ne_o         (str_b_valid_dec1_ne),
    .ctl_64bit_op_str_dec1_ne_o    (ctl_64bit_op_str_dec1_ne),
    .ex_pipe_dec1_ne_o             (ex_pipe_dec1_ne[`CA53_EX_PIPE_W-1:0]),
    .imm_data_dec1_ne_o            (imm_data_dec1_ne[`CA53_IMM_DATA_W-1:0]),
    .imm_shift_dec1_ne_o           (imm_shift_dec1_ne[`CA53_IMM_SHIFT_W-1:0]),
    .alu_pipectl_dec1_ne_o         (alu_pipectl_dec1_ne[`CA53_ALU_PIPECTL_W-1:0]),
    .req_strict_algn_dec1_ne_o     (req_strict_algn_dec1_ne),
    .check_x64_dec1_ne_o           (check_x64_dec1_ne),
    .algn_size_dec1_ne_o           (algn_size_dec1_ne),
    .wd_align_pc_dec1_ne_o         (wd_align_pc_dec1_ne),
    .ls_store_dec1_ne_o            (ls_store_dec1_ne),
    .ls_size_dec1_ne_o             (ls_size_dec1_ne),
    .ls_instr_type_dec1_ne_o       (ls_instr_type_dec1_ne),
    .ls_elem_size_dec1_ne_o        (ls_elem_size_dec1_ne),
    .ls_length_dec1_ne_o           (ls_length_dec1_ne),
    .agu_shf_value_dec1_ne_o       (agu_shf_value_dec1_ne),
    .agu_sub_b_dec1_ne_o           (agu_sub_b_dec1_ne),
    .fmac_valid_sp_dec1_ne_o       (fmac_valid_sp_dec1_ne),
    .neon_can_fwd_acc_dec1_ne_o    (neon_can_fwd_acc_dec1_ne),
    .mul_neon_out_fmt_dec1_ne_o    (mul_neon_out_fmt_dec1_ne),
    .fp_ex_pipe_dec1_ne_o          (fp_ex_pipe_dec1_ne),
    .flag_en_dec1_ne_o             (flag_en_dec1_ne[`CA53_FLAGEN_INSTR1_W-1:0]),
    .dp_data_a_sel_dec1_ne_o       (alu_data_a_sel_dec1_ne[`CA53_SEL_SHF_A_W-1:0]),
    .dp_data_b_sel_dec1_ne_o       (alu_data_b_sel_dec1_ne[`CA53_SEL_SHF_B_W-1:0]),
    .dp_data_c_sel_dec1_ne_o       (alu_data_c_sel_dec1_ne[`CA53_SEL_SHF_C_W-1:0]),
    .instr_fmstat_dec1_ne_o        (instr_fmstat_dec1_ne),
    .slot1_instr_type_dec1_ne_o    (slot1_instr_type_dec1_ne[`CA53_SLOT1_INSTR_TYPE_W-1:0])
  );

  // The Iss-stage Neon decoder does not read all bits of iq_instr0_fn or
  // decoder_fsm. Only register used bits.
  always @(posedge clk)
    if (issue_to_iss_fpu_i) begin
      iq_instr1_fn_iss_reg_hi      <= iq_instr1_fn[32:31];
      iq_instr1_fn_iss_reg_mid     <= iq_instr1_fn[28:16];
      iq_instr1_fn_iss_reg_lo      <= iq_instr1_fn[11:4];
      iq_instr1_fn_pdtype_iss_reg  <= iq_instr1_pdtype[0];
      iq_instr1_fn_aarch64_iss_reg <= iq_instr1_fn_aarch64;
      mul_neon_out_fmt_dec1_iss    <= mul_neon_out_fmt_dec1_ne;
    end

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      decoder_select1_ne_iss_reg <= 1'b0;
    else if (issue_to_iss_i)
      decoder_select1_ne_iss_reg <= decoder_select1[DEC1_NE];

  assign iq_instr1_fn_iss         = {iq_instr1_fn_iss_reg_hi[32:31],  // [32:31]
                                     {2{1'b0}},                       // [30:29] (unused)
                                     iq_instr1_fn_iss_reg_mid[28:16], // [28:16]
                                     {4{1'b0}},                       // [15:12] (unused)
                                     iq_instr1_fn_iss_reg_lo[11:4],   // [11:4]
                                     {4{1'b0}}};                      // [3:0]   (unused)
  assign iq_instr1_fn_pdtype_iss  = iq_instr1_fn_pdtype_iss_reg;
  assign iq_instr1_fn_aarch64_iss = iq_instr1_fn_aarch64_iss_reg;

  assign decoder_select1_ne_iss   = decoder_select1_ne_iss_reg;

  ca53dpu_dec1_late_neon `CA53_DPU_PARAM_INST u_dec1_late_neon (
    // Inputs
    .iq_instr_fn_i              (iq_instr1_fn_iss[32:0]),
    .iq_instr1_fn_pdtype_iss_i  (iq_instr1_fn_pdtype_iss),
    .aarch64_state_i            (iq_instr1_fn_aarch64_iss),
    .mul_neon_out_fmt_iss_i     (mul_neon_out_fmt_dec1_iss),
    // Outputs
    .fp_cflag_src_neon_o        (fp_cflag_src_dec1_ne[`CA53_FP_CFLAG_SRC_W-1:0]),
    .fp_xflag_src_neon_o        (fp_xflag_src_dec1_ne[`CA53_FP_XFLAG_SRC_W-1:0]),
    .fp_pipectl_neon_o          (fp_pipectl_dec1_ne),
    .sel_fml_a_neon_o           (sel_fml_a_dec1_ne),
    .sel_fml_b_neon_o           (sel_fml_b_dec1_ne[`CA53_SEL_FML_B_W-1:0]),
    .sel_fml_c_neon_o           (sel_fml_c_dec1_ne),
    .sel_fad_a_neon_o           (sel_fad_a_dec1_ne[`CA53_SEL_FAD_A_W-1:0]),
    .sel_fad_b_neon_o           (sel_fad_b_dec1_ne[`CA53_SEL_FAD_B_W-1:0]),
    .sel_fad_c_neon_o           (sel_fad_c_dec1_ne[`CA53_SEL_FAD_C_W-1:0])
  );

end else begin : NEON2_STUBS
  assign rf_rd_en_r0_dec1_ne      = 1'b0;
  assign rf_rd_en_r1_dec1_ne      = 1'b0;
  assign rf_rd_en_r2_dec1_ne      = 1'b0;
  assign rf_rd_need_r0_dec1_ne    = {3{1'b0}};
  assign rf_rd_need_r1_dec1_ne    = {3{1'b0}};
  assign rf_wr_vaddr_w0_dec1_ne   = {5{1'b0}};
  assign rf_wr_en_w0_dec1_ne      = 1'b0;
  assign rf_wr_vaddr_w1_dec1_ne   = {5{1'b0}};
  assign rf_wr_en_w1_dec1_ne      = 1'b0;
  assign rf_wr_64b_w1_dec1_ne     = 1'b0;
  assign rf_wr_src_w0_dec1_ne     = {`CA53_RF_WR_SRC_W0_W{1'b0}};
  assign rf_wr_src_w1_dec1_ne     = {`CA53_RF_WR_SRC_W1_W{1'b0}};
  assign rf_wr_when_w0_dec1_ne    = {`CA53_RF_WR_WHEN_W{1'b0}};
  assign rf_wr_when_w1_dec1_ne_preskew    = {`CA53_RF_WR_WHEN_W{1'b0}};
  assign rf_rd_addr_fr0_dec1_ne   = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
  assign rf_rd_addr_fr1_dec1_ne   = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
  assign rf_rd_addr_fr2_dec1_ne   = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
  assign rf_rd_en_fr0_dec1_ne     = {2{1'b0}};
  assign rf_rd_en_fr1_dec1_ne     = {2{1'b0}};
  assign rf_rd_en_fr2_dec1_ne     = {2{1'b0}};
  assign rf_rd_need_fr0_dec1_ne   = {`CA53_RF_FRD_NEED_W{1'b0}};
  assign rf_rd_need_fr1_dec1_ne   = {`CA53_RF_FRD_NEED_W{1'b0}};
  assign rf_rd_need_fr2_dec1_ne   = {`CA53_RF_FRD_NEED_W{1'b0}};
  assign rf_wr_addr_fw0_dec1_ne   = {`CA53_FP_RF_WR_ADDR_W{1'b0}};
  assign rf_wr_en_fw0_dec1_ne     = {4{1'b0}};
  assign rf_wr_src_fw0_dec1_ne    = {`CA53_RF_FWR_SRC_W{1'b0}};
  assign rf_wr_when_fw0_dec1_ne   = {`CA53_RF_FWR_WHEN_W{1'b0}};
  assign alu_data_a_sel_dec1_ne   = {`CA53_SEL_SHF_A_W{1'b0}};
  assign alu_data_b_sel_dec1_ne   = {`CA53_SEL_SHF_B_W{1'b0}};
  assign alu_data_c_sel_dec1_ne   = {`CA53_SEL_SHF_C_W{1'b0}};
  assign agu_data_a_sel_dec1_ne   = {`CA53_SEL_DCU_A_W{1'b0}};
  assign agu_data_b_sel_dec1_ne   = {`CA53_SEL_DCU_B_W{1'b0}};
  assign str_data_a_sel_dec1_ne   = {`CA53_SEL_STR_A_W{1'b0}};
  assign str_data_b_sel_dec1_ne   = {`CA53_SEL_STR_B_W{1'b0}};
  assign str_b_valid_dec1_ne      = 1'b0;
  assign ctl_64bit_op_str_dec1_ne = 1'b0;
  assign str1_data_a_sel_dec1_ne  = {`CA53_SEL_STR_A_W{1'b0}};
  assign str1_data_b_sel_dec1_ne  = {`CA53_SEL_STR_B_W{1'b0}};
  assign str1_sel_dec1_ne         = 1'b0;
  assign ex_pipe_dec1_ne          = {`CA53_EX_PIPE_W{1'b0}};
  assign imm_data_dec1_ne         = {`CA53_IMM_DATA_W{1'b0}};
  assign imm_shift_dec1_ne        = {`CA53_IMM_SHIFT_W{1'b0}};
  assign alu_pipectl_dec1_ne      = {`CA53_ALU_PIPECTL_W{1'b0}};
  assign req_strict_algn_dec1_ne  = 1'b0;
  assign check_x64_dec1_ne        = 1'b0;
  assign algn_size_dec1_ne        = 3'b000;
  assign wd_align_pc_dec1_ne      = 1'b0;
  assign ls_store_dec1_ne         = 1'b0;
  assign ls_size_dec1_ne          = {3{1'b0}};
  assign ls_instr_type_dec1_ne    = {`CA53_LS_INSTR_TYPE_W{1'b0}};
  assign ls_elem_size_dec1_ne     = {3{1'b0}};
  assign ls_length_dec1_ne        = {6{1'b0}};
  assign agu_sub_b_dec1_ne        = 1'b0;
  assign agu_shf_value_dec1_ne    = 3'b000;
  assign slot1_instr_type_dec1_ne = {`CA53_SLOT1_INSTR_TYPE_W{1'b0}};
  assign neon_can_fwd_acc_dec1_ne = 1'b0;
  assign fmac_valid_sp_dec1_ne    = 1'b0;
  assign fp_cflag_src_dec1_ne     = {`CA53_FP_CFLAG_SRC_W{1'b0}};
  assign fp_xflag_src_dec1_ne     = {`CA53_FP_XFLAG_SRC_W{1'b0}};
  assign fp_ex_pipe_dec1_ne       = {`CA53_FP_EX_PIPE_W{1'b0}};
  assign flag_en_dec1_ne          = {`CA53_FLAGEN_INSTR1_W{1'b0}};
  assign fp_pipectl_dec1_ne       = {`CA53_FP_PIPECTL_W{1'b0}};
  assign instr_fmstat_dec1_ne     = 1'b0;
  assign sel_fml_a_dec1_ne        = 1'b0;
  assign sel_fml_b_dec1_ne        = {`CA53_SEL_FML_B_W{1'b0}};
  assign sel_fml_c_dec1_ne        = 1'b0;
  assign sel_fad_a_dec1_ne        = {`CA53_SEL_FAD_A_W{1'b0}};
  assign sel_fad_b_dec1_ne        = {`CA53_SEL_FAD_B_W{1'b0}};
  assign sel_fad_c_dec1_ne        = {`CA53_SEL_FAD_C_W{1'b0}};
  assign iq_instr1_fn_iss         = {33{1'b0}};
  assign iq_instr1_fn_pdtype_iss  = 1'b0;
  assign iq_instr1_fn_aarch64_iss = 1'b0;
  assign decoder_select1_ne_iss   = 1'b0;
end endgenerate

  // ------------------------------------------------------
  // Select between decoders
  // ------------------------------------------------------

  // Identify undefined instructions indicated by pre-decoder
  assign predec_undefined = iq_instr0_is_other & ~iq_instr0_sideband[5] & // Undef/abort/BKPT if marked as Other and top bit of sideband clear
                            ~iq_instr0_other_br_taken;                    // Taken bit reused to indicate Abort/BKPT

                      
  // Use the branch decoders when the class does not indicate any type of
  // instruction (this is how the IFU indicates instructions for the branch
  // decoder).
  assign use_dec0_br = ~(iq_instr0_is_fn | iq_instr0_is_ls | iq_instr0_is_dp | iq_instr0_is_other);
  assign use_dec1_br = ~(iq_instr1_is_fn | iq_instr1_is_ls | iq_instr1_is_dec1);

  // Slot 0 decoder select control signal
  assign decoder_select0       = {// Branch decoder
                                  (~forceop_valid_de_i & iq_instr0_val & use_dec0_br),
                                  // Neon decoder
                                  (~forceop_valid_de_i & iq_instr0_val & iq_instr0_is_fn),
                                  // Undefined integer instruction
                                  (~forceop_valid_de_i & iq_instr0_val & predec_undefined),
                                  // Force-operation
                                  forceop_valid_de_i,
                                  // Other decoder
                                  (~forceop_valid_de_i & iq_instr0_val & iq_instr0_is_other & ~predec_undefined),
                                  // Load-store decoder
                                  (~forceop_valid_de_i & iq_instr0_val & iq_instr0_is_ls),
                                  // Data-processing decoder
                                  (~forceop_valid_de_i & iq_instr0_val & iq_instr0_is_dp)};

  // Slot 1 decoder select control logic
  assign decoder_select1       = {// Branch decoder
                                  valid_instrs_de[1] & use_dec1_br,
                                  // Neon decoder
                                  valid_instrs_de[1] & iq_instr1_is_fn & ~iq_instr1_is_aesimc_aesmc,
                                  // Load-store decoder
                                  valid_instrs_de[1] & iq_instr1_is_ls,
                                  // Slot 1 decoder
                                  valid_instrs_de[1] & iq_instr1_is_dec1};

  // - early version used for muxing most signals where signal ignored when
  // instr1 not actually dual issuing
  assign decoder_select1_early = {// Branch decoder
                                  valid_instr1_early_de & use_dec1_br,
                                  // Neon decoder
                                  valid_instr1_early_de & iq_instr1_is_fn & ~iq_instr1_is_aesimc_aesmc,
                                  // Load-store decoder
                                  valid_instr1_early_de & iq_instr1_is_ls,
                                  // Slot 1 decoder
                                  valid_instr1_early_de & iq_instr1_is_dec1};


  // General control
  always @* begin
    cond_code_instr0_de_o        = aarch64_state_i ? `CA53_CC_AL : iq_instr0_common[32:29];
    en_decoder_lsm_de            = 1'b0;
    end_instr_de_o               = 1'b0;
    ex_pipe_0_de                 = {`CA53_EX_PIPE_W{1'b0}};
    slot0_str1_sel_de            = 1'b0;
    early_expt_enable_de_o       = 1'b0;
    expt_instr_type_de           = `CA53_EXPT_INSTR_TYPE_NULL;
    finish_instr_de              = 1'b1;
    head_instr_de_o[0]           = 1'b0;
    instr_type_de_o              = `CA53_INSTR_TYPE_NULL;
    msr_mrs_data_de_o            = {6{1'b0}};
    msr_mrs_reg_wr_de_o          = 1'b0;
    msr_mrs_spsr_de_o            = 1'b0;
    no_insert_de_o               = 1'b0;
    no_interrupt_de_o            = 1'b0;
    nxt_decoder_fsm_de           = {{5{1'b0}}, 1'b1};
    nxt_lsm_state_de             = {14{1'b0}};

    case ({decoder_select0[BR],
           decoder_select0[NE],
           decoder_select0[UN],
           decoder_select0[FO],
           decoder_select0[OT],
           decoder_select0[LS],
           decoder_select0[DP]})
      7'b000_0000 : begin // Use defaults
      end
      7'b000_0001 : begin // Data-processing decoder
        end_instr_de_o           = end_instr_dp;
        ex_pipe_0_de             = ex_pipe_dp;
        early_expt_enable_de_o   = early_expt_enable_dp;
        expt_instr_type_de       = expt_instr_type_dp[`CA53_EXPT_INSTR_TYPE_W-1:0];
        finish_instr_de          = nxt_decoder_fsm_dp[0];
        head_instr_de_o[0]       = head_instr_dp;
        nxt_decoder_fsm_de       = {4'b0000, nxt_decoder_fsm_dp[1:0]};
      end
      7'b000_0010 : begin // Load-store decoder
        end_instr_de_o           = end_instr_ls;
        ex_pipe_0_de             = ex_pipe_ls;
        slot0_str1_sel_de        = str1_sel_ls;
        early_expt_enable_de_o   = early_expt_enable_ls;
        expt_instr_type_de       = expt_instr_type_ls[`CA53_EXPT_INSTR_TYPE_W-1:0];
        finish_instr_de          = end_instr_ls;
        head_instr_de_o[0]       = head_instr_ls;
        instr_type_de_o          = instr_type_ls[`CA53_INSTR_TYPE_W-1:0];
        nxt_decoder_fsm_de       = {1'b0, nxt_decoder_fsm_ls[4:0]};
        nxt_lsm_state_de         = nxt_lsm_state_ls;
      end
      7'b000_0100 : begin // Other decoder
        cond_code_instr0_de_o    = cond_code_other[3:0];
        end_instr_de_o           = end_instr_other;
        ex_pipe_0_de             = ex_pipe_other;
        slot0_str1_sel_de        = str1_sel_other;
        early_expt_enable_de_o   = early_expt_enable_other;
        expt_instr_type_de       = expt_instr_type_other[`CA53_EXPT_INSTR_TYPE_W-1:0];
        finish_instr_de          = nxt_decoder_fsm_other[0];
        head_instr_de_o[0]       = head_instr_other;
        instr_type_de_o          = instr_type_other[`CA53_INSTR_TYPE_W-1:0];
        msr_mrs_data_de_o        = msr_mrs_data_other[5:0];
        msr_mrs_reg_wr_de_o      = msr_mrs_reg_wr_other;
        msr_mrs_spsr_de_o        = msr_mrs_spsr_other;
        nxt_decoder_fsm_de       = {2'b00, nxt_decoder_fsm_other[3:0]};
      end
      7'b000_1000 : begin // Forceop decoder
        cond_code_instr0_de_o    = `CA53_CC_AL;
        ex_pipe_0_de             = ex_pipe_force;
        finish_instr_de          = 1'b1;
        msr_mrs_data_de_o        = msr_mrs_data_force[5:0];
        msr_mrs_reg_wr_de_o      = msr_mrs_reg_wr_force;
        no_interrupt_de_o        = 1'b1;
      end
      7'b001_0000 : begin // Undefined instruction identified by pre-decoder
        end_instr_de_o           = 1'b1;
        early_expt_enable_de_o   = 1'b1;
        expt_instr_type_de       = `CA53_EXPT_INSTR_TYPE_PD_UNDEF;
        finish_instr_de          = 1'b1;
        head_instr_de_o[0]       = 1'b1;
      end
      7'b010_0000 : begin // Neon decoder
        en_decoder_lsm_de        = en_decoder_lsm_neon;
        end_instr_de_o           = end_instr_neon;
        ex_pipe_0_de             = ex_pipe_neon;
        slot0_str1_sel_de        = str1_sel_neon;
        early_expt_enable_de_o   = early_expt_enable_neon;
        expt_instr_type_de       = expt_instr_type_neon[`CA53_EXPT_INSTR_TYPE_W-1:0];
        finish_instr_de          = nxt_decoder_fsm_neon[0];
        head_instr_de_o[0]       = head_instr_neon;
        no_insert_de_o           = no_insert_neon;
        no_interrupt_de_o        = no_interrupt_neon;
        nxt_decoder_fsm_de       = nxt_decoder_fsm_neon[5:0];
        nxt_lsm_state_de         = { {4{1'b0}}, nxt_lsm_state_neon[9:0]};
      end
      7'b100_0000 : begin // Branch decoder
        cond_code_instr0_de_o    = cond_code_dec0_br[3:0];
        ex_pipe_0_de             = ex_pipe_dec0_br;
        head_instr_de_o[0]       = 1'b1;
        end_instr_de_o           = 1'b1;
      end
      default : begin
        cond_code_instr0_de_o    = {4{1'bx}};
        en_decoder_lsm_de        = 1'bx;
        end_instr_de_o           = 1'bx;
        ex_pipe_0_de             = {`CA53_EX_PIPE_W{1'bx}};
        slot0_str1_sel_de        = 1'bx;
        early_expt_enable_de_o   = 1'bx;
        expt_instr_type_de       = {`CA53_EXPT_INSTR_TYPE_W{1'bx}};
        finish_instr_de          = 1'bx;
        head_instr_de_o[0]       = 1'bx;
        instr_type_de_o          = {`CA53_INSTR_TYPE_W{1'bx}};
        msr_mrs_data_de_o        = {6{1'bx}};
        msr_mrs_reg_wr_de_o      = 1'bx;
        msr_mrs_spsr_de_o        = 1'bx;
        no_insert_de_o           = 1'bx;
        no_interrupt_de_o        = 1'bx;
        nxt_decoder_fsm_de       = {6{1'bx}};
        nxt_lsm_state_de         = {14{1'bx}};
      end
    endcase
  end

  always @*
    case ({decoder_select1_early[DEC1_BR],
           decoder_select1_early[DEC1_NE],
           decoder_select1_early[DEC1_LS],
           decoder_select1_early[DEC1]})
      4'b0000 : begin
        // Nothing dual issuing from slot 1
        raw_ex_pipe_1_de      = {`CA53_EX_PIPE_W{1'b0}};
        head_instr_de_o[1]    = 1'b0;
        slot1_instr_type_de_o = `CA53_SLOT1_INSTR_TYPE_NULL;
        slot1_str0_sel_de     = 1'b0;
      end
      4'b0001 : begin
        // Dec1 instruction dual-issuing from slot 1
        raw_ex_pipe_1_de      = ex_pipe_dec1;
        head_instr_de_o[1]    = 1'b1;
        slot1_instr_type_de_o = slot1_instr_type_dec1[`CA53_SLOT1_INSTR_TYPE_W-1:0];
        slot1_str0_sel_de     = 1'b0;
      end
      4'b0010 : begin
        // Load-store dual issuing from slot 1
        raw_ex_pipe_1_de      = ex_pipe_dec1_ls;
        head_instr_de_o[1]    = head_instr_dec1_ls;
        slot1_instr_type_de_o = `CA53_SLOT1_INSTR_TYPE_LS;
        slot1_str0_sel_de     = str1_sel_dec1_ls;
      end
      4'b0100 : begin
        // Neon dual issuing from slot 1
        raw_ex_pipe_1_de      = ex_pipe_dec1_ne;
        head_instr_de_o[1]    = 1'b1;
        slot1_instr_type_de_o = slot1_instr_type_dec1_ne;
        slot1_str0_sel_de     = str1_sel_dec1_ne;
      end
      4'b1000 : begin
        // Branch dual issuing from slot 1
        raw_ex_pipe_1_de      = ex_pipe_dec1_br;
        head_instr_de_o[1]    = 1'b1;
        slot1_instr_type_de_o = slot1_instr_type_dec1_br;
        slot1_str0_sel_de     = 1'b0;
      end
      default : begin
        raw_ex_pipe_1_de      = {`CA53_EX_PIPE_W{1'bx}};
        head_instr_de_o[1]    = 1'bx;
        slot1_instr_type_de_o = {`CA53_SLOT1_INSTR_TYPE_W{1'bx}};
        slot1_str0_sel_de     = 1'bx;
      end
    endcase

  assign ex_pipe_1_de = raw_ex_pipe_1_de & {`CA53_EX_PIPE_W{valid_instrs_de[1]}};

  // - To improve timing, create instr1 condition code using early signals
  assign cond_code_instr1_de_o = (use_dec1_br & a64_cond_br_dec1_br)                              ? iq_instr1_common[15:12] :
                                 ((iq_instr1_is_dec1 & force_cond_always_dec1) | aarch64_state_i) ? `CA53_CC_AL             :
                                                                                                    iq_instr1_common[32:29];

  // ALU0
  always @* begin
    use_ex1_alu_0_static_de      = 1'b0;
    alu0_pipectl_de_o            = {`CA53_ALU_PIPECTL_W{1'b0}};
    alu0_msk_data_sel_de_o       = 1'b0;
    alu0_data_a_sel_de_o         = {`CA53_SEL_SHF_A_W{1'b0}};
    alu0_data_b_sel_de_o         = {`CA53_SEL_SHF_B_W{1'b0}};
    alu0_data_c_sel_de_o         = {`CA53_SEL_SHF_C_W{1'b0}};
    wd_align_pc_alu0_de_o        = 1'b0;
    imm_data_0_de_o              = {`CA53_IMM_DATA_W{1'b0}};
    imm_shift_0_de_o             = {`CA53_IMM_SHIFT_W{1'b0}};
    imm_data_sel_0_de_o          = `CA53_IMM_SEL_NULL;

    case ({decoder_select0[BR],
           decoder_select0[NE],
           decoder_select0[UN],
           decoder_select0[FO],
           decoder_select0[OT],
           decoder_select0[LS],
           decoder_select0[DP]})
      7'b000_0000 : begin // No decoder
        // Use defaults
      end
      7'b000_0001 : begin // Data-processing decoder
        alu0_pipectl_de_o        = alu_pipectl_dp;
        alu0_msk_data_sel_de_o   = alu_msk_data_sel_dp;
        alu0_data_a_sel_de_o     = ((alu_data_a_sel_dp == `CA53_SEL_SHF_A_R0) & rf_rd_remap_de) ? `CA53_SEL_SHF_A_R3 : alu_data_a_sel_dp[`CA53_SEL_SHF_A_W-1:0];
        alu0_data_b_sel_de_o     = ((alu_data_b_sel_dp == `CA53_SEL_SHF_B_R1) & rf_rd_remap_de) ? `CA53_SEL_SHF_B_R4 : alu_data_b_sel_dp[`CA53_SEL_SHF_B_W-1:0];
        alu0_data_c_sel_de_o     = alu_data_c_sel_dp[`CA53_SEL_SHF_C_W-1:0];
        wd_align_pc_alu0_de_o    = word_align_pc_dp;
        imm_data_0_de_o          = imm_data_dp[`CA53_IMM_DATA_W-1:0];
        imm_shift_0_de_o         = imm_shift_dp[`CA53_IMM_SHIFT_W-1:0];
        imm_data_sel_0_de_o      = imm_data_sel_dp[`CA53_IMM_SEL_W-1:0];
        use_ex1_alu_0_static_de  = use_ex1_alu_static_dp;
      end
      7'b000_0010 : begin // Load-store decoder
        alu0_pipectl_de_o        = alu_pipectl_ls;
        alu0_data_a_sel_de_o     = ((alu_data_a_sel_ls == `CA53_SEL_SHF_A_R0) & rf_rd_remap_de) ? `CA53_SEL_SHF_A_R3 : alu_data_a_sel_ls[`CA53_SEL_SHF_A_W-1:0];
        alu0_data_b_sel_de_o     = ((alu_data_b_sel_ls == `CA53_SEL_SHF_B_R1) & rf_rd_remap_de) ? `CA53_SEL_SHF_B_R4 : alu_data_b_sel_ls[`CA53_SEL_SHF_B_W-1:0];
        alu0_data_c_sel_de_o     = alu_data_c_sel_ls[`CA53_SEL_SHF_C_W-1:0];
        imm_data_0_de_o          = imm_data_ls[`CA53_IMM_DATA_W-1:0];
        imm_shift_0_de_o         = imm_shift_ls[`CA53_IMM_SHIFT_W-1:0];
        imm_data_sel_0_de_o      = imm_data_sel_ls[`CA53_IMM_SEL_W-1:0];
      end
      7'b000_0100 : begin // Other decoder
        alu0_pipectl_de_o        = alu_pipectl_other;
        alu0_data_a_sel_de_o     = ((alu_data_a_sel_other == `CA53_SEL_SHF_A_R0) & rf_rd_remap_de) ? `CA53_SEL_SHF_A_R3 : alu_data_a_sel_other[`CA53_SEL_SHF_A_W-1:0];
        alu0_data_b_sel_de_o     = ((alu_data_b_sel_other == `CA53_SEL_SHF_B_R1) & rf_rd_remap_de) ? `CA53_SEL_SHF_B_R4 : alu_data_b_sel_other[`CA53_SEL_SHF_B_W-1:0];
        alu0_data_c_sel_de_o     = alu_data_c_sel_other[`CA53_SEL_SHF_C_W-1:0];
        imm_data_0_de_o          = imm_data_other[`CA53_IMM_DATA_W-1:0];
        imm_shift_0_de_o         = imm_shift_other[`CA53_IMM_SHIFT_W-1:0];
      end
      7'b000_1000 : begin // Forceop decoder
        alu0_pipectl_de_o        = alu_pipectl_force;
        alu0_data_a_sel_de_o     = alu_data_a_sel_force[`CA53_SEL_SHF_A_W-1:0]; // Forceop can't remap
        alu0_data_b_sel_de_o     = alu_data_b_sel_force[`CA53_SEL_SHF_B_W-1:0];
        imm_data_0_de_o          = imm_data_force[`CA53_IMM_DATA_W-1:0];
      end
      7'b001_0000 : begin // Undefined instruction identified by pre-decoder
        // Use defaults
      end
      7'b010_0000 : begin // Neon decoder
        alu0_pipectl_de_o        = alu_pipectl_neon[`CA53_ALU_PIPECTL_W-1:0];
        alu0_msk_data_sel_de_o   = alu_msk_data_sel_neon;
        alu0_data_a_sel_de_o     = ((alu_data_a_sel_neon == `CA53_SEL_SHF_A_R0) & rf_rd_remap_de) ? `CA53_SEL_SHF_A_R3 : alu_data_a_sel_neon[`CA53_SEL_SHF_A_W-1:0];
        alu0_data_b_sel_de_o     = ((alu_data_b_sel_neon == `CA53_SEL_SHF_B_R1) & rf_rd_remap_de) ? `CA53_SEL_SHF_B_R4 : alu_data_b_sel_neon[`CA53_SEL_SHF_B_W-1:0];
        alu0_data_c_sel_de_o     = alu_data_c_sel_neon[`CA53_SEL_SHF_C_W-1:0];
        imm_data_0_de_o          = imm_data_neon[`CA53_IMM_DATA_W-1:0];
        imm_shift_0_de_o         = imm_shift_neon[`CA53_IMM_SHIFT_W-1:0];
      end
      7'b100_0000 : begin // Branch decoder
        alu0_pipectl_de_o        = alu_pipectl_dec0_br[`CA53_ALU_PIPECTL_W-1:0];
        alu0_data_a_sel_de_o     = ((alu_data_a_sel_dec0_br == `CA53_SEL_SHF_A_R0) & rf_rd_remap_de) ? `CA53_SEL_SHF_A_R3 : alu_data_a_sel_dec0_br[`CA53_SEL_SHF_A_W-1:0];
        alu0_data_b_sel_de_o     = ((alu_data_b_sel_dec0_br == `CA53_SEL_SHF_B_R1) & rf_rd_remap_de) ? `CA53_SEL_SHF_B_R4 : alu_data_b_sel_dec0_br[`CA53_SEL_SHF_B_W-1:0];
        alu0_data_c_sel_de_o     = alu_data_c_sel_dec0_br[`CA53_SEL_SHF_C_W-1:0];
        imm_data_0_de_o          = imm_data_dec0_br[`CA53_IMM_DATA_W-1:0];
        imm_shift_0_de_o         = imm_shift_dec0_br[`CA53_IMM_SHIFT_W-1:0];
      end
      default : begin
        alu0_pipectl_de_o        = {`CA53_ALU_PIPECTL_W{1'bx}};
        alu0_msk_data_sel_de_o   = 1'bx;
        alu0_data_a_sel_de_o     = {`CA53_SEL_SHF_A_W{1'bx}};
        alu0_data_b_sel_de_o     = {`CA53_SEL_SHF_B_W{1'bx}};
        alu0_data_c_sel_de_o     = {`CA53_SEL_SHF_C_W{1'bx}};
        wd_align_pc_alu0_de_o    = 1'bx;
        imm_data_0_de_o          = {`CA53_IMM_DATA_W{1'bx}};
        imm_shift_0_de_o         = {`CA53_IMM_SHIFT_W{1'bx}};
        imm_data_sel_0_de_o      = {`CA53_IMM_SEL_W{1'bx}};
        use_ex1_alu_0_static_de  = 1'bx;
      end
    endcase
  end

  // ALU1
  always @* begin
    alu1_pipectl_de_o            = {`CA53_ALU_PIPECTL_W{1'b0}};
    alu1_msk_data_sel_de_o       = 1'b0;
    alu1_data_a_sel_de_o         = {`CA53_SEL_SHF_A_W{1'b0}};
    alu1_data_b_sel_de_o         = {`CA53_SEL_SHF_B_W{1'b0}};
    alu1_data_c_sel_de_o         = {`CA53_SEL_SHF_C_W{1'b0}};
    wd_align_pc_alu1_de_o        = 1'b0;
    imm_data_1_de_o              = {`CA53_IMM_DATA_W{1'b0}};
    imm_shift_1_de_o             = {`CA53_IMM_SHIFT_W{1'b0}};
    imm_data_sel_1_de_o          = `CA53_IMM_SEL_NULL;
    use_ex1_alu_1_static_de      = 1'b0;

    case ({decoder_select1_early[DEC1_BR],
           decoder_select1_early[DEC1_NE],
           decoder_select1_early[DEC1_LS],
           decoder_select1_early[DEC1]})
      4'b0000 : begin
        // Nothing dual issuing from slot 1
        // - Use defaults
      end
      4'b0001 : begin
        // Dec1 instruction dual-issuing from slot 1
        alu1_pipectl_de_o        = alu_pipectl_dec1;
        alu1_data_a_sel_de_o     = ((alu_data_a_sel_dec1 == `CA53_SEL_SHF_A_R0) & rf_rd_remap_de) ? `CA53_SEL_SHF_A_R3 : alu_data_a_sel_dec1[`CA53_SEL_SHF_A_W-1:0];
        alu1_data_b_sel_de_o     = ((alu_data_b_sel_dec1 == `CA53_SEL_SHF_B_R1) & rf_rd_remap_de) ? `CA53_SEL_SHF_B_R4 : alu_data_b_sel_dec1[`CA53_SEL_SHF_B_W-1:0];
        alu1_data_c_sel_de_o     = alu_data_c_sel_dec1[`CA53_SEL_SHF_C_W-1:0];
        wd_align_pc_alu1_de_o    = word_align_pc_dec1;
        alu1_msk_data_sel_de_o   = msk_data_sel_dec1;
        imm_data_1_de_o          = imm_data_dec1;
        imm_shift_1_de_o         = imm_shift_dec1;
        imm_data_sel_1_de_o      = imm_data_sel_dec1;
        use_ex1_alu_1_static_de  = use_ex1_alu_static_dec1;
      end
      4'b0010 : begin
        // Load-store dual issuing from slot 1
        alu1_pipectl_de_o        = alu_pipectl_dec1_ls;
        alu1_data_a_sel_de_o     = ((alu_data_a_sel_dec1_ls == `CA53_SEL_SHF_A_R0) & rf_rd_remap_de) ? `CA53_SEL_SHF_A_R3 : alu_data_a_sel_dec1_ls[`CA53_SEL_SHF_A_W-1:0];
        alu1_data_b_sel_de_o     = ((alu_data_b_sel_dec1_ls == `CA53_SEL_SHF_B_R1) & rf_rd_remap_de) ? `CA53_SEL_SHF_B_R4 : alu_data_b_sel_dec1_ls[`CA53_SEL_SHF_B_W-1:0];
        alu1_data_c_sel_de_o     = alu_data_c_sel_dec1_ls[`CA53_SEL_SHF_C_W-1:0];
        imm_data_1_de_o          = imm_data_dec1_ls[`CA53_IMM_DATA_W-1:0];
        imm_shift_1_de_o         = imm_shift_dec1_ls[`CA53_IMM_SHIFT_W-1:0];
      end
      4'b0100 : begin
        // Neon dual issuing from slot 1
        alu1_pipectl_de_o        = alu_pipectl_dec1_ne;
        alu1_data_a_sel_de_o     = ((alu_data_a_sel_dec1_ne == `CA53_SEL_SHF_A_R0) & rf_rd_remap_de) ? `CA53_SEL_SHF_A_R3 : alu_data_a_sel_dec1_ne[`CA53_SEL_SHF_A_W-1:0];
        alu1_data_b_sel_de_o     = ((alu_data_b_sel_dec1_ne == `CA53_SEL_SHF_B_R1) & rf_rd_remap_de) ? `CA53_SEL_SHF_B_R4 : alu_data_b_sel_dec1_ne[`CA53_SEL_SHF_B_W-1:0];
        alu1_data_c_sel_de_o     = alu_data_c_sel_dec1_ne[`CA53_SEL_SHF_C_W-1:0];
        imm_data_1_de_o          = imm_data_dec1_ne[`CA53_IMM_DATA_W-1:0];
        imm_shift_1_de_o         = imm_shift_dec1_ne[`CA53_IMM_SHIFT_W-1:0];
      end
      4'b1000 : begin
        // Branch instruction dual-issuing from slot 1
        alu1_pipectl_de_o        = alu_pipectl_dec1_br;
        alu1_data_a_sel_de_o     = ((alu_data_a_sel_dec1_br == `CA53_SEL_SHF_A_R0) & rf_rd_remap_de) ? `CA53_SEL_SHF_A_R3 : alu_data_a_sel_dec1_br[`CA53_SEL_SHF_A_W-1:0];
        alu1_data_b_sel_de_o     = ((alu_data_b_sel_dec1_br == `CA53_SEL_SHF_B_R1) & rf_rd_remap_de) ? `CA53_SEL_SHF_B_R4 : alu_data_b_sel_dec1_br[`CA53_SEL_SHF_B_W-1:0];
        alu1_data_c_sel_de_o     = alu_data_c_sel_dec1_br[`CA53_SEL_SHF_C_W-1:0];
        imm_data_1_de_o          = imm_data_dec1_br;
        imm_shift_1_de_o         = imm_shift_dec1_br;
      end
      default : begin
        alu1_pipectl_de_o        = {`CA53_ALU_PIPECTL_W{1'bx}};
        alu1_data_a_sel_de_o     = {`CA53_SEL_SHF_A_W{1'bx}};
        alu1_data_b_sel_de_o     = {`CA53_SEL_SHF_B_W{1'bx}};
        alu1_data_c_sel_de_o     = {`CA53_SEL_SHF_C_W{1'bx}};
        wd_align_pc_alu1_de_o    = 1'bx;
        alu1_msk_data_sel_de_o   = 1'bx;
        imm_data_1_de_o          = {`CA53_IMM_DATA_W{1'bx}};
        imm_shift_1_de_o         = {`CA53_IMM_SHIFT_W{1'bx}};
        imm_data_sel_1_de_o      = {`CA53_IMM_SEL_W{1'bx}};
        use_ex1_alu_1_static_de  = 1'bx;
      end
    endcase
  end

  // MAC/Div
  always @*
    case ({decoder_select1_early[DEC1],
           decoder_select0[DP] & (ex_pipe_0_de[`CA53_EX_PIPE_MAC_BIT] | ex_pipe_0_de[`CA53_EX_PIPE_DIV_BIT])})
      2'b00: begin // Not dual-issuing from dec1 and no multiply/divide in slot 0
        mac_pipectl_de_o         = {`CA53_MAC_PIPECTL_W{1'b0}};
        mac_data_a_sel_de_o      = {`CA53_SEL_MAC_A_W{1'b0}};
        mac_data_b_sel_de_o      = {`CA53_SEL_MAC_B_W{1'b0}};
        div_data_a_sel_de_o      = {`CA53_SEL_DIV_A_W{1'b0}};
        div_data_b_sel_de_o      = {`CA53_SEL_DIV_B_W{1'b0}};
      end      
      2'b01, 2'b11: begin // Multiply/divide in slot 0
        mac_pipectl_de_o         = mac_pipectl_dp;
        mac_data_a_sel_de_o      = ((mac_data_a_sel_dp == `CA53_SEL_MAC_A_R0) & rf_rd_remap_de) ? `CA53_SEL_MAC_A_R3 : mac_data_a_sel_dp[`CA53_SEL_MAC_A_W-1:0];
        mac_data_b_sel_de_o      = ((mac_data_b_sel_dp == `CA53_SEL_MAC_B_R1) & rf_rd_remap_de) ? `CA53_SEL_MAC_B_R4 : mac_data_b_sel_dp[`CA53_SEL_MAC_B_W-1:0];
        div_data_a_sel_de_o      = ((div_data_a_sel_dp == `CA53_SEL_DIV_A_R0) & rf_rd_remap_de) ? `CA53_SEL_DIV_A_R3 : div_data_a_sel_dp[`CA53_SEL_DIV_A_W-1:0];
        div_data_b_sel_de_o      = ((div_data_b_sel_dp == `CA53_SEL_DIV_B_R1) & rf_rd_remap_de) ? `CA53_SEL_DIV_B_R4 : div_data_b_sel_dp[`CA53_SEL_DIV_B_W-1:0];
      end     
      2'b10: begin // Dual-issuing from dec1 and no multiply/divide in slot 0
        mac_pipectl_de_o         = mac_pipectl_dec1;
        mac_data_a_sel_de_o      = (mac_data_a_sel_dec1 == `CA53_SEL_MAC_A_R0) ? `CA53_SEL_MAC_A_R3 : mac_data_a_sel_dec1[`CA53_SEL_MAC_A_W-1:0];
        mac_data_b_sel_de_o      = (mac_data_b_sel_dec1 == `CA53_SEL_MAC_B_R1) ? `CA53_SEL_MAC_B_R4 : mac_data_b_sel_dec1[`CA53_SEL_MAC_B_W-1:0];
        div_data_a_sel_de_o      = {`CA53_SEL_DIV_A_W{1'b0}};
        div_data_b_sel_de_o      = {`CA53_SEL_DIV_B_W{1'b0}};
      end      
      default: begin
        mac_pipectl_de_o         = {`CA53_MAC_PIPECTL_W{1'bx}};
        mac_data_a_sel_de_o      = {`CA53_SEL_MAC_A_W{1'bx}};
        mac_data_b_sel_de_o      = {`CA53_SEL_MAC_B_W{1'bx}};
        div_data_a_sel_de_o      = {`CA53_SEL_DIV_A_W{1'bx}};
        div_data_b_sel_de_o      = {`CA53_SEL_DIV_B_W{1'bx}};
      end
    endcase

  // LS
  always @* begin
    ls_length_de_o               = 6'b000001; // Default is single access, length=1
    ls_store_de_o                = 1'b0;
    ls_store_neon_de_o           = 1'b0;
    ls_size_de_o                 = {3{1'b0}};
    ls_elem_size_de_o            = {3{1'b0}};
    ls_instr_type_de             = {`CA53_LS_INSTR_TYPE_W{1'b0}};
    ls_isv_set_de_o              = 1'b0;
    ls_synd_sf_de_o              = 1'b0;
    ls_synd_srt_de_o             = {5{1'b0}};
    agu_data_a_sel_de_o          = {`CA53_SEL_DCU_A_W{1'b0}};
    agu_data_b_sel_de_o          = {`CA53_SEL_DCU_B_W{1'b0}};
    agu_sub_b_de_o               = 1'b0;
    agu_shf_value_de_o           = {3{1'b0}};
    check_x64_de_o               = 1'b0;
    algn_size_de_o               = {3{1'b0}};
    req_strict_algn_de_o         = 1'b0;
    force_usr_priv_mem_de_o      = 1'b0;
    enable_base_restore_de_o     = 1'b0;
    wd_align_pc_ls_de_o          = 1'b0;
    pg_align_pc_ls_de_o          = 1'b0;
    skid_x64_multiple_de_o       = 1'b0;
    adrp_fwd_src                 = 3'b000;
    raw_imm_data_ls_de           = {`CA53_IMM_DATA_W{1'b0}};

    case ({decoder_select0[BR],
           decoder_select0[NE],
           decoder_select0[OT],
           decoder_select0[LS],
           decoder_select0[DP]})
      5'b00000 : begin // Use defaults
      end
      5'b00001 : begin // Data-processing decoder
        case ({decoder_select1_early[DEC1_NE],
               decoder_select1_early[DEC1_LS],
               decoder_select1_early[DEC1]})
          3'b000 : begin
            // Nothing dual issuing from slot 1
          end
          3'b001 : begin
            // Dec1 instruction dual-issuing from slot 1
          end
          3'b010 : begin
            // Load-store dual issuing from slot 1
            ls_store_de_o            = ls_store_dec1_ls;
            ls_size_de_o             = ls_size_dec1_ls[2:0];
            ls_length_de_o           = {1'b0, ls_length_dec1_ls[4:0]};
            ls_elem_size_de_o        = {1'b0, ls_elem_size_dec1_ls[1:0]};
            ls_instr_type_de         = ls_instr_type_dec1_ls[`CA53_LS_INSTR_TYPE_W-1:0];
            ls_isv_set_de_o          = ls_isv_set_dec1_ls;
            ls_synd_sf_de_o          = ls_synd_sf_dec1_ls;
            ls_synd_srt_de_o         = ls_synd_srt_dec1_ls;
            agu_data_a_sel_de_o      = iq_instr1_adrp_fwd ? `CA53_SEL_DCU_A_PC : agu_data_a_sel_dec1_ls[`CA53_SEL_DCU_A_W-1:0];
            agu_data_b_sel_de_o      = agu_data_b_sel_dec1_ls[`CA53_SEL_DCU_B_W-1:0];
            agu_sub_b_de_o           = agu_sub_b_dec1_ls;
            agu_shf_value_de_o       = {1'b0, agu_shf_value_dec1_ls[1:0]};
            check_x64_de_o           = check_x64_dec1_ls;
            algn_size_de_o           = algn_size_dec1_ls[2:0];
            req_strict_algn_de_o     = req_strict_algn_dec1_ls;
            force_usr_priv_mem_de_o  = force_usr_priv_mem_dec1_ls;
            wd_align_pc_ls_de_o      = word_align_pc_dec1_ls | iq_instr1_adrp_fwd;
            pg_align_pc_ls_de_o      = iq_instr1_adrp_fwd;
            adrp_fwd_src             = iq_instr1_adrp_fwd_src[2:0];
            raw_imm_data_ls_de       = imm_data_dec1_ls[`CA53_IMM_DATA_W-1:0];
          end
          3'b100 : begin
            // Neon dual issuing from slot 1
            ls_store_de_o            = ls_store_dec1_ne;
            ls_size_de_o             = ls_size_dec1_ne[2:0];
            ls_length_de_o           = ls_length_dec1_ne[5:0];
            ls_elem_size_de_o        = ls_elem_size_dec1_ne[2:0];
            ls_instr_type_de         = ls_instr_type_dec1_ne[`CA53_LS_INSTR_TYPE_W-1:0];
            agu_data_a_sel_de_o      = iq_instr1_adrp_fwd ? `CA53_SEL_DCU_A_PC : agu_data_a_sel_dec1_ne[`CA53_SEL_DCU_A_W-1:0];
            agu_data_b_sel_de_o      = agu_data_b_sel_dec1_ne[`CA53_SEL_DCU_B_W-1:0];
            agu_sub_b_de_o           = agu_sub_b_dec1_ne;
            agu_shf_value_de_o       = agu_shf_value_dec1_ne[2:0];
            check_x64_de_o           = check_x64_dec1_ne;
            algn_size_de_o           = algn_size_dec1_ne[2:0];
            req_strict_algn_de_o     = req_strict_algn_dec1_ne;
            wd_align_pc_ls_de_o      = wd_align_pc_dec1_ne | iq_instr1_adrp_fwd;
            pg_align_pc_ls_de_o      = iq_instr1_adrp_fwd;
            adrp_fwd_src             = iq_instr1_adrp_fwd_src[2:0];
            raw_imm_data_ls_de       = imm_data_dec1_ne[`CA53_IMM_DATA_W-1:0];
          end
          default : begin
            ls_store_de_o            = 1'bx;
            ls_size_de_o             = {3{1'bx}};
            ls_elem_size_de_o        = {3{1'bx}};
            ls_instr_type_de         = {`CA53_LS_INSTR_TYPE_W{1'bx}};
            ls_isv_set_de_o          = 1'bx;
            ls_synd_sf_de_o          = 1'bx;
            ls_synd_srt_de_o         = {5{1'bx}};
            agu_data_a_sel_de_o      = {`CA53_SEL_DCU_A_W{1'bx}};
            agu_data_b_sel_de_o      = {`CA53_SEL_DCU_B_W{1'bx}};
            agu_sub_b_de_o           = 1'bx;
            agu_shf_value_de_o       = {3{1'bx}};
            check_x64_de_o           = 1'bx;
            algn_size_de_o           = {3{1'bx}};
            req_strict_algn_de_o     = 1'bx;
            force_usr_priv_mem_de_o  = 1'bx;
            wd_align_pc_ls_de_o      = 1'bx;
            pg_align_pc_ls_de_o      = 1'bx;
            adrp_fwd_src             = {3{1'bx}};
            raw_imm_data_ls_de       = {`CA53_IMM_DATA_W{1'bx}};
          end
        endcase
      end
      5'b00010 : begin // Load-store decoder
        ls_length_de_o           = {1'b0, ls_length_ls[4:0]};
        ls_store_de_o            = ls_store_ls;
        ls_size_de_o             = ls_size_ls[2:0];
        ls_elem_size_de_o        = {1'b0, ls_elem_size_ls[1:0]};
        ls_instr_type_de         = ls_instr_type_ls[`CA53_LS_INSTR_TYPE_W-1:0];
        ls_isv_set_de_o          = ls_isv_set_ls;
        ls_synd_sf_de_o          = ls_synd_sf_ls;
        ls_synd_srt_de_o         = ls_synd_srt_ls;
        agu_data_a_sel_de_o      = iq_instr0_adrp_fwd ? `CA53_SEL_DCU_A_PC : agu_data_a_sel_ls[`CA53_SEL_DCU_A_W-1:0];
        agu_data_b_sel_de_o      = agu_data_b_sel_ls[`CA53_SEL_DCU_B_W-1:0];
        agu_sub_b_de_o           = agu_sub_b_ls;
        agu_shf_value_de_o       = {1'b0, agu_shf_value_ls[1:0]};
        check_x64_de_o           = check_x64_ls;
        algn_size_de_o           = algn_size_ls[2:0];
        req_strict_algn_de_o     = req_strict_algn_ls;
        force_usr_priv_mem_de_o  = force_usr_priv_mem_ls;
        enable_base_restore_de_o = enable_base_restore_ls;
        wd_align_pc_ls_de_o      = word_align_pc_ls | iq_instr0_adrp_fwd;
        pg_align_pc_ls_de_o      = iq_instr0_adrp_fwd;
        adrp_fwd_src             = {iq_instr0_adrp_fwd_src[2:1], 1'b0};
        skid_x64_multiple_de_o   = skid_x64_multiple_ls;
        raw_imm_data_ls_de       = imm_data_ls[`CA53_IMM_DATA_W-1:0];
      end
      5'b00100 : begin // Other decoder
        case ({decoder_select1_early[DEC1_NE],
               decoder_select1_early[DEC1_LS],
               decoder_select1_early[DEC1]})
          3'b000 : begin
            // Nothing dual issuing from slot 1
            // - LS pipe driven by Ot
            ls_length_de_o           = {1'b0, ls_length_other[4:0]};
            ls_store_de_o            = ls_store_other;
            ls_size_de_o             = ls_size_other[2:0];
            ls_elem_size_de_o        = {1'b0, ls_size_other[1:0]};
            ls_instr_type_de         = ls_instr_type_other[`CA53_LS_INSTR_TYPE_W-1:0];
            agu_data_a_sel_de_o      = agu_data_a_sel_other[`CA53_SEL_DCU_A_W-1:0];
            agu_data_b_sel_de_o      = agu_data_b_sel_other[`CA53_SEL_DCU_B_W-1:0];
            algn_size_de_o           = algn_size_other[2:0];
            force_usr_priv_mem_de_o  = force_usr_priv_mem_other;
          end
          3'b001 : begin
            // Dec1 instruction dual-issuing from slot 1
            // - LS pipe driven by Ot
            ls_length_de_o           = {1'b0, ls_length_other[4:0]};
            ls_store_de_o            = ls_store_other;
            ls_size_de_o             = ls_size_other[2:0];
            ls_elem_size_de_o        = {1'b0, ls_size_other[1:0]};
            ls_instr_type_de         = ls_instr_type_other[`CA53_LS_INSTR_TYPE_W-1:0];
            agu_data_a_sel_de_o      = agu_data_a_sel_other[`CA53_SEL_DCU_A_W-1:0];
            agu_data_b_sel_de_o      = agu_data_b_sel_other[`CA53_SEL_DCU_B_W-1:0];
            algn_size_de_o           = algn_size_other[2:0];
            force_usr_priv_mem_de_o  = force_usr_priv_mem_other;
          end
          3'b010 : begin
            // Load-store dual issuing from slot 1
            // - LS pipe driven by LS
            ls_store_de_o            = ls_store_dec1_ls;
            ls_size_de_o             = ls_size_dec1_ls[2:0];
            ls_length_de_o           = {1'b0, ls_length_dec1_ls[4:0]};
            ls_elem_size_de_o        = {1'b0, ls_elem_size_dec1_ls[1:0]};
            ls_instr_type_de         = ls_instr_type_dec1_ls[`CA53_LS_INSTR_TYPE_W-1:0];
            ls_isv_set_de_o          = ls_isv_set_dec1_ls;
            ls_synd_sf_de_o          = ls_synd_sf_dec1_ls;
            ls_synd_srt_de_o         = ls_synd_srt_dec1_ls;
            agu_data_a_sel_de_o      = iq_instr1_adrp_fwd ? `CA53_SEL_DCU_A_PC : agu_data_a_sel_dec1_ls[`CA53_SEL_DCU_A_W-1:0];
            agu_data_b_sel_de_o      = agu_data_b_sel_dec1_ls[`CA53_SEL_DCU_B_W-1:0];
            agu_sub_b_de_o           = agu_sub_b_dec1_ls;
            agu_shf_value_de_o       = {1'b0, agu_shf_value_dec1_ls[1:0]};
            check_x64_de_o           = check_x64_dec1_ls;
            algn_size_de_o           = algn_size_dec1_ls[2:0];
            req_strict_algn_de_o     = req_strict_algn_dec1_ls;
            force_usr_priv_mem_de_o  = force_usr_priv_mem_dec1_ls;
            wd_align_pc_ls_de_o      = word_align_pc_dec1_ls | iq_instr1_adrp_fwd;
            pg_align_pc_ls_de_o      = iq_instr1_adrp_fwd;
            adrp_fwd_src             = iq_instr1_adrp_fwd_src[2:0];
            raw_imm_data_ls_de       = imm_data_dec1_ls[`CA53_IMM_DATA_W-1:0];
          end
          3'b100 : begin
            // Neon dual issuing from slot 1
            ls_store_de_o            = ls_store_dec1_ne;
            ls_size_de_o             = ls_size_dec1_ne[2:0];
            ls_length_de_o           = ls_length_dec1_ne[5:0];
            ls_elem_size_de_o        = ls_elem_size_dec1_ne[2:0];
            ls_instr_type_de         = ls_instr_type_dec1_ne[`CA53_LS_INSTR_TYPE_W-1:0];
            agu_data_a_sel_de_o      = iq_instr1_adrp_fwd ? `CA53_SEL_DCU_A_PC : agu_data_a_sel_dec1_ne[`CA53_SEL_DCU_A_W-1:0];
            agu_data_b_sel_de_o      = agu_data_b_sel_dec1_ne[`CA53_SEL_DCU_B_W-1:0];
            agu_sub_b_de_o           = agu_sub_b_dec1_ne;
            agu_shf_value_de_o       = agu_shf_value_dec1_ne[2:0];
            check_x64_de_o           = check_x64_dec1_ne;
            algn_size_de_o           = algn_size_dec1_ne[2:0];
            req_strict_algn_de_o     = req_strict_algn_dec1_ne;
            wd_align_pc_ls_de_o      = wd_align_pc_dec1_ne | iq_instr1_adrp_fwd;
            pg_align_pc_ls_de_o      = iq_instr1_adrp_fwd;
            adrp_fwd_src             = iq_instr1_adrp_fwd_src[2:0];
            raw_imm_data_ls_de       = imm_data_dec1_ne[`CA53_IMM_DATA_W-1:0];
          end
          default : begin
            ls_length_de_o           = {6{1'bx}};
            ls_store_de_o            = 1'bx;
            ls_size_de_o             = {3{1'bx}};
            ls_elem_size_de_o        = {3{1'bx}};
            ls_instr_type_de         = {`CA53_LS_INSTR_TYPE_W{1'bx}};
            ls_isv_set_de_o          = 1'bx;
            ls_synd_sf_de_o          = 1'bx;
            ls_synd_srt_de_o         = {5{1'bx}};
            agu_data_a_sel_de_o      = {`CA53_SEL_DCU_A_W{1'bx}};
            agu_data_b_sel_de_o      = {`CA53_SEL_DCU_B_W{1'bx}};
            agu_sub_b_de_o           = 1'bx;
            agu_shf_value_de_o       = {3{1'bx}};
            check_x64_de_o           = 1'bx;
            algn_size_de_o           = {3{1'bx}};
            req_strict_algn_de_o     = 1'bx;
            force_usr_priv_mem_de_o  = 1'bx;
            wd_align_pc_ls_de_o      = 1'bx;
            pg_align_pc_ls_de_o      = 1'bx;
            adrp_fwd_src             = {3{1'bx}};
            raw_imm_data_ls_de       = {`CA53_IMM_DATA_W{1'bx}};
          end
        endcase
      end
      5'b01000 : begin // Neon decoder
        case ({decoder_select1_early[DEC1_NE] & iq_instr1_fn_dcu_valid,
               decoder_select1_early[DEC1_LS],
               decoder_select1_early[DEC1]})
          3'b000 : begin
            // Nothing dual issuing from slot 1 (or another Neon not using LS pipe)
            // - LS pipe driven by NEON
            ls_length_de_o           = ls_length_neon[5:0];
            ls_store_de_o            = ls_store_neon;
            ls_store_neon_de_o       = ls_store_neon;
            ls_size_de_o             = ls_size_neon[2:0];
            ls_elem_size_de_o        = ls_elem_size_neon[2:0];
            ls_instr_type_de         = ls_instr_type_neon[`CA53_LS_INSTR_TYPE_W-1:0];
            agu_data_a_sel_de_o      = iq_instr0_adrp_fwd ? `CA53_SEL_DCU_A_PC : agu_data_a_sel_neon[`CA53_SEL_DCU_A_W-1:0];
            agu_data_b_sel_de_o      = agu_data_b_sel_neon[`CA53_SEL_DCU_B_W-1:0];
            agu_sub_b_de_o           = agu_sub_b_neon;
            agu_shf_value_de_o       = agu_shf_value_neon[2:0];
            check_x64_de_o           = check_x64_neon;
            algn_size_de_o           = algn_size_neon[2:0];
            req_strict_algn_de_o     = req_strict_algn_neon;
            enable_base_restore_de_o = enable_base_restore_neon;
            wd_align_pc_ls_de_o      = wd_align_pc_neon | iq_instr0_adrp_fwd;
            pg_align_pc_ls_de_o      = iq_instr0_adrp_fwd;
            adrp_fwd_src             = {iq_instr0_adrp_fwd_src[2:1], 1'b0};
            skid_x64_multiple_de_o   = skid_x64_multiple_neon;
            raw_imm_data_ls_de       = imm_data_neon[`CA53_IMM_DATA_W-1:0];
          end
          3'b001 : begin
            // Dec1 instruction dual-issuing from slot 1
            // - LS pipe driven by NEON
            ls_length_de_o           = ls_length_neon[5:0];
            ls_store_de_o            = ls_store_neon;
            ls_store_neon_de_o       = ls_store_neon;
            ls_size_de_o             = ls_size_neon[2:0];
            ls_elem_size_de_o        = ls_elem_size_neon[2:0];
            ls_instr_type_de         = ls_instr_type_neon[`CA53_LS_INSTR_TYPE_W-1:0];
            agu_data_a_sel_de_o      = iq_instr0_adrp_fwd ? `CA53_SEL_DCU_A_PC : agu_data_a_sel_neon[`CA53_SEL_DCU_A_W-1:0];
            agu_data_b_sel_de_o      = agu_data_b_sel_neon[`CA53_SEL_DCU_B_W-1:0];
            agu_sub_b_de_o           = agu_sub_b_neon;
            agu_shf_value_de_o       = agu_shf_value_neon[2:0];
            check_x64_de_o           = check_x64_neon;
            algn_size_de_o           = algn_size_neon[2:0];
            req_strict_algn_de_o     = req_strict_algn_neon;
            enable_base_restore_de_o = enable_base_restore_neon;
            wd_align_pc_ls_de_o      = wd_align_pc_neon | iq_instr0_adrp_fwd;
            pg_align_pc_ls_de_o      = iq_instr0_adrp_fwd;
            adrp_fwd_src             = {iq_instr0_adrp_fwd_src[2:1], 1'b0};
            skid_x64_multiple_de_o   = skid_x64_multiple_neon;
            raw_imm_data_ls_de       = imm_data_neon[`CA53_IMM_DATA_W-1:0];
          end
          3'b010 : begin
            // Load-store dual issuing from slot 1
            // - LS pipe driven by LS
            ls_store_de_o            = ls_store_dec1_ls;
            ls_size_de_o             = ls_size_dec1_ls[2:0];
            ls_length_de_o           = {1'b0, ls_length_dec1_ls[4:0]};
            ls_elem_size_de_o        = {1'b0, ls_elem_size_dec1_ls[1:0]};
            ls_instr_type_de         = ls_instr_type_dec1_ls[`CA53_LS_INSTR_TYPE_W-1:0];
            ls_isv_set_de_o          = ls_isv_set_dec1_ls;
            ls_synd_sf_de_o          = ls_synd_sf_dec1_ls;
            ls_synd_srt_de_o         = ls_synd_srt_dec1_ls;
            agu_data_a_sel_de_o      = iq_instr1_adrp_fwd ? `CA53_SEL_DCU_A_PC : agu_data_a_sel_dec1_ls[`CA53_SEL_DCU_A_W-1:0];
            agu_data_b_sel_de_o      = agu_data_b_sel_dec1_ls[`CA53_SEL_DCU_B_W-1:0];
            agu_sub_b_de_o           = agu_sub_b_dec1_ls;
            agu_shf_value_de_o       = {1'b0, agu_shf_value_dec1_ls[1:0]};
            check_x64_de_o           = check_x64_dec1_ls;
            algn_size_de_o           = algn_size_dec1_ls[2:0];
            req_strict_algn_de_o     = req_strict_algn_dec1_ls;
            force_usr_priv_mem_de_o  = force_usr_priv_mem_dec1_ls;
            wd_align_pc_ls_de_o      = word_align_pc_dec1_ls | iq_instr1_adrp_fwd;
            pg_align_pc_ls_de_o      = iq_instr1_adrp_fwd;
            adrp_fwd_src             = iq_instr1_adrp_fwd_src[2:0];
            raw_imm_data_ls_de       = imm_data_dec1_ls[`CA53_IMM_DATA_W-1:0];
          end
          3'b100 : begin
            // Neon dual issuing from slot 1
            ls_store_de_o            = ls_store_dec1_ne;
            ls_size_de_o             = ls_size_dec1_ne[2:0];
            ls_length_de_o           = ls_length_dec1_ne[5:0];
            ls_elem_size_de_o        = ls_elem_size_dec1_ne[2:0];
            ls_instr_type_de         = ls_instr_type_dec1_ne[`CA53_LS_INSTR_TYPE_W-1:0];
            agu_data_a_sel_de_o      = iq_instr1_adrp_fwd ? `CA53_SEL_DCU_A_PC : agu_data_a_sel_dec1_ne[`CA53_SEL_DCU_A_W-1:0];
            agu_data_b_sel_de_o      = agu_data_b_sel_dec1_ne[`CA53_SEL_DCU_B_W-1:0];
            agu_sub_b_de_o           = agu_sub_b_dec1_ne;
            agu_shf_value_de_o       = agu_shf_value_dec1_ne[2:0];
            check_x64_de_o           = check_x64_dec1_ne;
            algn_size_de_o           = algn_size_dec1_ne[2:0];
            req_strict_algn_de_o     = req_strict_algn_dec1_ne;
            wd_align_pc_ls_de_o      = wd_align_pc_dec1_ne | iq_instr1_adrp_fwd;
            pg_align_pc_ls_de_o      = iq_instr1_adrp_fwd;
            adrp_fwd_src             = iq_instr1_adrp_fwd_src[2:0];
            raw_imm_data_ls_de       = imm_data_dec1_ne[`CA53_IMM_DATA_W-1:0];
          end
          default : begin
            ls_length_de_o           = {6{1'bx}};
            ls_store_de_o            = 1'bx;
            ls_store_neon_de_o       = 1'bx;
            ls_size_de_o             = {3{1'bx}};
            ls_elem_size_de_o        = {3{1'bx}};
            ls_instr_type_de         = {`CA53_LS_INSTR_TYPE_W{1'bx}};
            ls_isv_set_de_o          = 1'bx;
            ls_synd_sf_de_o          = 1'bx;
            ls_synd_srt_de_o         = {5{1'bx}};
            agu_data_a_sel_de_o      = {`CA53_SEL_DCU_A_W{1'bx}};
            agu_data_b_sel_de_o      = {`CA53_SEL_DCU_B_W{1'bx}};
            agu_sub_b_de_o           = 1'bx;
            agu_shf_value_de_o       = {3{1'bx}};
            check_x64_de_o           = 1'bx;
            algn_size_de_o           = {3{1'bx}};
            req_strict_algn_de_o     = 1'bx;
            force_usr_priv_mem_de_o  = 1'bx;
            wd_align_pc_ls_de_o      = 1'bx;
            pg_align_pc_ls_de_o      = 1'bx;
            adrp_fwd_src             = {3{1'bx}};
            skid_x64_multiple_de_o   = 1'bx;
            raw_imm_data_ls_de       = {`CA53_IMM_DATA_W{1'bx}};
          end
        endcase
      end
      5'b10000 : begin // Branch decoder
        case ({decoder_select1_early[DEC1_NE],
               decoder_select1_early[DEC1_LS],
               decoder_select1_early[DEC1]})
          3'b000, 3'b001 : begin
            // Nothing/DP dual issuing from slot 1
            // - Branch decoder never uses DCU so use defaults
          end
          3'b010 : begin
            // Load-store dual issuing from slot 1
            // - LS pipe driven by LS
            ls_store_de_o            = ls_store_dec1_ls;
            ls_size_de_o             = ls_size_dec1_ls[2:0];
            ls_length_de_o           = {1'b0, ls_length_dec1_ls[4:0]};
            ls_elem_size_de_o        = {1'b0, ls_elem_size_dec1_ls[1:0]};
            ls_instr_type_de         = ls_instr_type_dec1_ls[`CA53_LS_INSTR_TYPE_W-1:0];
            ls_isv_set_de_o          = ls_isv_set_dec1_ls;
            ls_synd_sf_de_o          = ls_synd_sf_dec1_ls;
            ls_synd_srt_de_o         = ls_synd_srt_dec1_ls;
            agu_data_a_sel_de_o      = iq_instr1_adrp_fwd ? `CA53_SEL_DCU_A_PC : agu_data_a_sel_dec1_ls[`CA53_SEL_DCU_A_W-1:0];
            agu_data_b_sel_de_o      = agu_data_b_sel_dec1_ls[`CA53_SEL_DCU_B_W-1:0];
            agu_sub_b_de_o           = agu_sub_b_dec1_ls;
            agu_shf_value_de_o       = {1'b0, agu_shf_value_dec1_ls[1:0]};
            check_x64_de_o           = check_x64_dec1_ls;
            algn_size_de_o           = algn_size_dec1_ls[2:0];
            req_strict_algn_de_o     = req_strict_algn_dec1_ls;
            force_usr_priv_mem_de_o  = force_usr_priv_mem_dec1_ls;
            wd_align_pc_ls_de_o      = word_align_pc_dec1_ls | iq_instr1_adrp_fwd;
            pg_align_pc_ls_de_o      = iq_instr1_adrp_fwd;
            adrp_fwd_src             = iq_instr1_adrp_fwd_src[2:0];
            raw_imm_data_ls_de       = imm_data_dec1_ls[`CA53_IMM_DATA_W-1:0];
          end
          3'b100 : begin
            // Neon dual issuing from slot 1
            ls_store_de_o            = ls_store_dec1_ne;
            ls_size_de_o             = ls_size_dec1_ne[2:0];
            ls_length_de_o           = ls_length_dec1_ne[5:0];
            ls_elem_size_de_o        = ls_elem_size_dec1_ne[2:0];
            ls_instr_type_de         = ls_instr_type_dec1_ne[`CA53_LS_INSTR_TYPE_W-1:0];
            agu_data_a_sel_de_o      = iq_instr1_adrp_fwd ? `CA53_SEL_DCU_A_PC : agu_data_a_sel_dec1_ne[`CA53_SEL_DCU_A_W-1:0];
            agu_data_b_sel_de_o      = agu_data_b_sel_dec1_ne[`CA53_SEL_DCU_B_W-1:0];
            agu_sub_b_de_o           = agu_sub_b_dec1_ne;
            agu_shf_value_de_o       = agu_shf_value_dec1_ne[2:0];
            check_x64_de_o           = check_x64_dec1_ne;
            algn_size_de_o           = algn_size_dec1_ne[2:0];
            req_strict_algn_de_o     = req_strict_algn_dec1_ne;
            wd_align_pc_ls_de_o      = wd_align_pc_dec1_ne | iq_instr1_adrp_fwd;
            pg_align_pc_ls_de_o      = iq_instr1_adrp_fwd;
            adrp_fwd_src             = iq_instr1_adrp_fwd_src[2:0];
            raw_imm_data_ls_de       = imm_data_dec1_ne[`CA53_IMM_DATA_W-1:0];
          end
          default : begin
            ls_length_de_o           = {6{1'bx}};
            ls_store_de_o            = 1'bx;
            ls_size_de_o             = {3{1'bx}};
            ls_elem_size_de_o        = {3{1'bx}};
            ls_instr_type_de         = {`CA53_LS_INSTR_TYPE_W{1'bx}};
            ls_isv_set_de_o          = 1'bx;
            ls_synd_sf_de_o          = 1'bx;
            ls_synd_srt_de_o         = {5{1'bx}};
            agu_data_a_sel_de_o      = {`CA53_SEL_DCU_A_W{1'bx}};
            agu_data_b_sel_de_o      = {`CA53_SEL_DCU_B_W{1'bx}};
            agu_sub_b_de_o           = 1'bx;
            agu_shf_value_de_o       = {3{1'bx}};
            check_x64_de_o           = 1'bx;
            algn_size_de_o           = {3{1'bx}};
            req_strict_algn_de_o     = 1'bx;
            force_usr_priv_mem_de_o  = 1'bx;
            wd_align_pc_ls_de_o      = 1'bx;
            pg_align_pc_ls_de_o      = 1'bx;
            adrp_fwd_src             = {3{1'bx}};
            raw_imm_data_ls_de       = {`CA53_IMM_DATA_W{1'bx}};
          end
        endcase
      end
      default : begin
        ls_length_de_o           = {6{1'bx}};
        ls_store_de_o            = 1'bx;
        ls_store_neon_de_o       = 1'bx;
        ls_size_de_o             = {3{1'bx}};
        ls_elem_size_de_o        = {3{1'bx}};
        ls_instr_type_de         = {`CA53_LS_INSTR_TYPE_W{1'bx}};
        ls_isv_set_de_o          = 1'bx;
        ls_synd_sf_de_o          = 1'bx;
        ls_synd_srt_de_o         = {5{1'bx}};
        agu_data_a_sel_de_o      = {`CA53_SEL_DCU_A_W{1'bx}};
        agu_data_b_sel_de_o      = {`CA53_SEL_DCU_B_W{1'bx}};
        agu_sub_b_de_o           = 1'bx;
        agu_shf_value_de_o       = {3{1'bx}};
        check_x64_de_o           = 1'bx;
        algn_size_de_o           = {3{1'bx}};
        req_strict_algn_de_o     = 1'bx;
        force_usr_priv_mem_de_o  = 1'bx;
        enable_base_restore_de_o = 1'bx;
        wd_align_pc_ls_de_o      = 1'bx;
        pg_align_pc_ls_de_o      = 1'bx;
        adrp_fwd_src             = {3{1'bx}};
        skid_x64_multiple_de_o   = 1'bx;
        raw_imm_data_ls_de       = {`CA53_IMM_DATA_W{1'bx}};
      end
    endcase
  end

  // Handle rewriting the LS immediate if forwarding an ADRP
  assign imm_data_ls_de_o = adrp_fwd_src[0] ? {imm_data_dp[20:0],          raw_imm_data_ls_de[11:0]} :
                            adrp_fwd_src[1] ? {raw_imm_data_1_iss_i[20:0], raw_imm_data_ls_de[11:0]} :
                            adrp_fwd_src[2] ? {raw_imm_data_0_iss_i[20:0], raw_imm_data_ls_de[11:0]} :
                                              { {33-`CA53_IMM_DATA_W{raw_imm_data_ls_de[`CA53_IMM_DATA_W-1]}}, raw_imm_data_ls_de};

  // Store0
  always @* begin
    str0_data_a_sel_de_o          = {`CA53_SEL_STR_A_W{1'b0}};
    str0_data_b_sel_de_o          = {`CA53_SEL_STR_B_W{1'b0}};
    str0_b_valid_de_o             = 1'b0;
    ctl_64bit_op_str0_de_o        = 1'b0;

    // If slot 1 store indicates it wants to use both store pipes then take control signals from slot 1
    case ({decoder_select1_early[DEC1_NE] & str1_sel_dec1_ne,
           decoder_select1_early[DEC1_LS] & str1_sel_dec1_ls})
      2'b00: begin
        case ({decoder_select0[BR],
               decoder_select0[NE],
               decoder_select0[OT],
               decoder_select0[LS],
               decoder_select0[DP]})
          5'b00000 : begin // Use defaults
          end
          5'b00001 : begin // Data-processing decoder
            str0_data_a_sel_de_o      = str_data_a_sel_dp[`CA53_SEL_STR_A_W-1:0];
            str0_data_b_sel_de_o      = str_data_b_sel_dp[`CA53_SEL_STR_B_W-1:0];
            str0_b_valid_de_o         = str_b_valid_dp;
            ctl_64bit_op_str0_de_o    = ctl_64bit_op_str_dp;
          end
          5'b00010 : begin // Load-store decoder
            str0_data_a_sel_de_o      = str_data_a_sel_ls[`CA53_SEL_STR_A_W-1:0];
            str0_data_b_sel_de_o      = str_data_b_sel_ls[`CA53_SEL_STR_B_W-1:0];
            str0_b_valid_de_o         = str_b_valid_ls;
            ctl_64bit_op_str0_de_o    = ctl_64bit_op_str_ls;
          end
          5'b00100 : begin // Other decoder
            str0_data_a_sel_de_o      = ((str_data_a_sel_other == `CA53_SEL_STR_A_R1) & rf_rd_remap_de) ? `CA53_SEL_STR_A_R4 : str_data_a_sel_other[`CA53_SEL_STR_A_W-1:0];
            str0_data_b_sel_de_o      = str_data_b_sel_other[`CA53_SEL_STR_B_W-1:0];
            str0_b_valid_de_o         = str_b_valid_other;
            ctl_64bit_op_str0_de_o    = ctl_64bit_op_str_other;
          end
          5'b01000 : begin // Neon decoder
            str0_data_a_sel_de_o      = ((str_data_a_sel_neon  == `CA53_SEL_STR_A_R1) & rf_rd_remap_de) ? `CA53_SEL_STR_A_R4 : str_data_a_sel_neon[`CA53_SEL_STR_A_W-1:0];
            str0_data_b_sel_de_o      = str_data_b_sel_neon[`CA53_SEL_STR_B_W-1:0];
            str0_b_valid_de_o         = str_b_valid_neon;
            ctl_64bit_op_str0_de_o    = ctl_64bit_op_str_neon;
          end
          5'b10000 : begin // Branch decoder
            str0_data_a_sel_de_o      = ((str_data_a_sel_dec0_br  == `CA53_SEL_STR_A_R1) & rf_rd_remap_de) ? `CA53_SEL_STR_A_R4 : str_data_a_sel_dec0_br[`CA53_SEL_STR_A_W-1:0];
            str0_data_b_sel_de_o      = str_data_b_sel_dec0_br[`CA53_SEL_STR_B_W-1:0];
            str0_b_valid_de_o         = str_b_valid_dec0_br;
            ctl_64bit_op_str0_de_o    = ctl_64bit_op_str_dec0_br;
          end
          default : begin
            str0_data_a_sel_de_o      = {`CA53_SEL_STR_A_W{1'bx}};
            str0_data_b_sel_de_o      = {`CA53_SEL_STR_B_W{1'bx}};
            str0_b_valid_de_o         = 1'bx;
            ctl_64bit_op_str0_de_o    = 1'bx;
          end
        endcase
      end
      2'b01: begin
        str0_data_a_sel_de_o      = str1_data_a_sel_dec1_ls[`CA53_SEL_STR_A_W-1:0];
        str0_data_b_sel_de_o      = str1_data_b_sel_dec1_ls[`CA53_SEL_STR_B_W-1:0];
        str0_b_valid_de_o         = 1'b1; // Always 64-bit
        ctl_64bit_op_str0_de_o    = 1'b1;
      end
      2'b10: begin
        str0_data_a_sel_de_o      = str1_data_a_sel_dec1_ne[`CA53_SEL_STR_A_W-1:0];
        str0_data_b_sel_de_o      = str1_data_b_sel_dec1_ne[`CA53_SEL_STR_B_W-1:0];
        str0_b_valid_de_o         = 1'b1; // Always 64-bit
        ctl_64bit_op_str0_de_o    = 1'b1;
      end
      default: begin
        str0_data_a_sel_de_o      = {`CA53_SEL_STR_A_W{1'bx}};
        str0_data_b_sel_de_o      = {`CA53_SEL_STR_B_W{1'bx}};
        str0_b_valid_de_o         = 1'bx;
        ctl_64bit_op_str0_de_o    = 1'bx;
      end
    endcase
  end

  // Store1
  always @*
    // If slot 0 store indicates it wants to use both store pipes then take control signals from slot 0
    case ({decoder_select0[NE] & str1_sel_neon,
           decoder_select0[OT] & str1_sel_other,
           decoder_select0[LS] & str1_sel_ls})
      3'b000 : begin
        // Slot 0 not using second store pipe
        case ({decoder_select1_early[DEC1_BR],
               decoder_select1_early[DEC1_NE],
               decoder_select1_early[DEC1_LS],
               decoder_select1_early[DEC1]})
          4'b0000 : begin // Nothing dual issuing
            str1_data_a_sel_de_o      = {`CA53_SEL_STR_A_W{1'b0}};
            str1_data_b_sel_de_o      = {`CA53_SEL_STR_B_W{1'b0}};
            str1_b_valid_de_o         = 1'b0;
            ctl_64bit_op_str1_de_o    = 1'b0;
          end
          4'b0001 : begin
            // Dec1 instruction dual-issuing from slot 1
            str1_data_a_sel_de_o      = str_data_a_sel_dec1[`CA53_SEL_STR_A_W-1:0];
            str1_data_b_sel_de_o      = str_data_b_sel_dec1[`CA53_SEL_STR_B_W-1:0];
            str1_b_valid_de_o         = str_b_valid_dec1;
            ctl_64bit_op_str1_de_o    = ctl_64bit_op_str_dec1;
          end
          4'b0010 : begin
            // Load-store dual issuing from slot 1
            str1_data_a_sel_de_o      = ((str_data_a_sel_dec1_ls == `CA53_SEL_STR_A_R1) & rf_rd_remap_de) ? `CA53_SEL_STR_A_R4 : str_data_a_sel_dec1_ls[`CA53_SEL_STR_A_W-1:0];
            str1_data_b_sel_de_o      = str_data_b_sel_dec1_ls[`CA53_SEL_STR_B_W-1:0];
            str1_b_valid_de_o         = str_b_valid_dec1_ls;
            ctl_64bit_op_str1_de_o    = ctl_64bit_op_str_dec1_ls;
          end
          4'b0100 : begin
            // Neon dual issuing from slot 1
            str1_data_a_sel_de_o      = ((str_data_a_sel_dec1_ne == `CA53_SEL_STR_A_R1) & rf_rd_remap_de) ? `CA53_SEL_STR_A_R4 : str_data_a_sel_dec1_ne[`CA53_SEL_STR_A_W-1:0];
            str1_data_b_sel_de_o      = str_data_b_sel_dec1_ne[`CA53_SEL_STR_B_W-1:0];
            str1_b_valid_de_o         = str_b_valid_dec1_ne;
            ctl_64bit_op_str1_de_o    = ctl_64bit_op_str_dec1_ne;
          end
          4'b1000 : begin
            // Branch instruction dual-issuing from slot 1
            str1_data_a_sel_de_o      = str_data_a_sel_dec1_br[`CA53_SEL_STR_A_W-1:0];
            str1_data_b_sel_de_o      = str_data_b_sel_dec1_br[`CA53_SEL_STR_B_W-1:0];
            str1_b_valid_de_o         = str_b_valid_dec1_br;
            ctl_64bit_op_str1_de_o    = ctl_64bit_op_str_dec1_br;
          end
          default : begin
            str1_data_a_sel_de_o      = {`CA53_SEL_STR_A_W{1'bx}};
            str1_data_b_sel_de_o      = {`CA53_SEL_STR_B_W{1'bx}};
            str1_b_valid_de_o         = 1'bx;
            ctl_64bit_op_str1_de_o    = 1'bx;
          end
        endcase
      end
      3'b001 : begin
        // Slot 0 indicates it wants second store pipe by setting str0_data_b_sel
        str1_data_a_sel_de_o      = str1_data_a_sel_ls;
        str1_data_b_sel_de_o      = str1_data_b_sel_ls;
        str1_b_valid_de_o         = 1'b1; // Always 64-bit
        ctl_64bit_op_str1_de_o    = 1'b1;
      end
      3'b010 : begin
        // Slot 0 indicates it wants second store pipe by setting str0_data_b_sel
        str1_data_a_sel_de_o      = `CA53_SEL_STR_A_ZERO;
        str1_data_b_sel_de_o      = `CA53_SEL_STR_B_ZERO;
        str1_b_valid_de_o         = 1'b1; // Always 64-bit
        ctl_64bit_op_str1_de_o    = 1'b1;
      end
      3'b100 : begin
        // Slot 0 indicates it wants second store pipe by setting str0_data_b_sel
        str1_data_a_sel_de_o      = str1_data_a_sel_neon;
        str1_data_b_sel_de_o      = str1_data_b_sel_neon;
        str1_b_valid_de_o         = 1'b1; // Always 64-bit
        ctl_64bit_op_str1_de_o    = 1'b1;
      end
      default : begin
        str1_data_a_sel_de_o      = {`CA53_SEL_STR_A_W{1'bx}};
        str1_data_b_sel_de_o      = {`CA53_SEL_STR_B_W{1'bx}};
        str1_b_valid_de_o         = 1'bx;
        ctl_64bit_op_str1_de_o    = 1'bx;
      end
    endcase

  // Branch
  always @* begin
    br_pipectl_de_o              = {`CA53_BR_PIPECTL_W{1'b0}};
    br_btac_de_o                 = 1'b0;
    br_offset_de_o               = {27{1'b0}};
    br_pred_takenness_de_o       = 1'b0;
    br_x_bit_de_o                = 1'b0;
    dpu_pred_br_de_o             = 1'b0;
    dpu_br_call_de_o             = 1'b0;
    dpu_br_return_de_o           = 1'b0;
    rtn_addr_valid_de_o          = 1'b0;

    case ({decoder_select0[BR],
           decoder_select0[NE],
           decoder_select0[OT],
           decoder_select0[LS],
           decoder_select0[DP]})
      5'b00000 : begin // Use defaults
      end
      5'b00001 : begin // Data-processing decoder
        case ({decoder_select1_early[DEC1_LS],
               decoder_select1_early[DEC1_BR]})
          2'b00 : begin
            // Nothing dual issuing from slot 1
            // - Branch pipe driven by DP
            br_pipectl_de_o          = br_pipectl_dp[`CA53_BR_PIPECTL_W-1:0];
          end
          2'b01 : begin
            // Branch instruction dual-issuing from slot 1
            br_pipectl_de_o          = br_pipectl_dec1_br[`CA53_BR_PIPECTL_W-1:0];
            br_btac_de_o             = br_btac_dec1_br;
            br_offset_de_o           = br_offset_dec1_br[27:1];
            br_pred_takenness_de_o   = br_pred_takenness_dec1_br;
            br_x_bit_de_o            = br_x_bit_dec1_br;
            dpu_pred_br_de_o         = pred_br_dec1_br;
            dpu_br_call_de_o         = br_call_dec1_br;
            dpu_br_return_de_o       = br_return_dec1_br;
            rtn_addr_valid_de_o      = rtn_addr_valid_dec1_br;
          end
          2'b10 : begin
            // Load-store dual issuing from slot 1
            // - Use defaults
          end
          default : begin
            br_pipectl_de_o          = {`CA53_BR_PIPECTL_W{1'bx}};
            br_btac_de_o             = 1'bx;
            br_offset_de_o           = {27{1'bx}};
            br_pred_takenness_de_o   = 1'bx;
            br_x_bit_de_o            = 1'bx;
            dpu_pred_br_de_o         = 1'bx;
            dpu_br_call_de_o         = 1'bx;
            dpu_br_return_de_o       = 1'bx;
            rtn_addr_valid_de_o      = 1'bx;
          end
        endcase
      end
      5'b00010 : begin // Load-store decoder
        case ({decoder_select1_early[DEC1_LS],
               decoder_select1_early[DEC1_BR]})
          2'b00 : begin
            // Nothing dual issuing from slot 1
            // - Branch pipe driven by LS
            br_pipectl_de_o          = br_pipectl_ls[`CA53_BR_PIPECTL_W-1:0];
            br_btac_de_o             = br_btac_ls;
            br_pred_takenness_de_o   = br_pred_takenness_ls;
            dpu_pred_br_de_o         = pred_br_ls;
            dpu_br_return_de_o       = br_return_ls;
            rtn_addr_valid_de_o      = rtn_addr_valid_ls;
          end
          2'b01 : begin
            // Branch instruction dual-issuing from slot 1
            br_pipectl_de_o          = br_pipectl_dec1_br[`CA53_BR_PIPECTL_W-1:0];
            br_btac_de_o             = br_btac_dec1_br;
            br_offset_de_o           = br_offset_dec1_br[27:1];
            br_pred_takenness_de_o   = br_pred_takenness_dec1_br;
            br_x_bit_de_o            = br_x_bit_dec1_br;
            dpu_pred_br_de_o         = pred_br_dec1_br;
            dpu_br_call_de_o         = br_call_dec1_br;
            dpu_br_return_de_o       = br_return_dec1_br;
            rtn_addr_valid_de_o      = rtn_addr_valid_dec1_br;
          end
          default : begin
            br_pipectl_de_o          = {`CA53_BR_PIPECTL_W{1'bx}};
            br_btac_de_o             = 1'bx;
            br_offset_de_o           = {27{1'bx}};
            br_pred_takenness_de_o   = 1'bx;
            br_x_bit_de_o            = 1'bx;
            dpu_pred_br_de_o         = 1'bx;
            dpu_br_call_de_o         = 1'bx;
            dpu_br_return_de_o       = 1'bx;
            rtn_addr_valid_de_o      = 1'bx;
          end
        endcase
      end
      5'b00100 : begin // Other decoder
        case ({decoder_select1_early[DEC1_LS] & iq_instr1_br_valid,
               decoder_select1_early[DEC1_BR]})
          2'b00 : begin
            // Nothing dual issuing from slot 1
            // - Branch pipe driven by Ot
            br_pipectl_de_o          = br_pipectl_other[`CA53_BR_PIPECTL_W-1:0];
            br_pred_takenness_de_o   = br_pred_takenness_other;
          end
          2'b01 : begin
            // Branch dual-issuing from slot 1
            br_pipectl_de_o          = br_pipectl_dec1_br[`CA53_BR_PIPECTL_W-1:0];
            br_btac_de_o             = br_btac_dec1_br;
            br_offset_de_o           = br_offset_dec1_br[27:1];
            br_pred_takenness_de_o   = br_pred_takenness_dec1_br;
            br_x_bit_de_o            = br_x_bit_dec1_br;
            dpu_pred_br_de_o         = pred_br_dec1_br;
            dpu_br_call_de_o         = br_call_dec1_br;
            dpu_br_return_de_o       = br_return_dec1_br;
            rtn_addr_valid_de_o      = rtn_addr_valid_dec1_br;
          end
          default : begin
            br_pipectl_de_o          = {`CA53_BR_PIPECTL_W{1'bx}};
            br_btac_de_o             = 1'bx;
            br_offset_de_o           = {27{1'bx}};
            br_pred_takenness_de_o   = 1'bx;
            br_x_bit_de_o            = 1'bx;
            dpu_pred_br_de_o         = 1'bx;
            dpu_br_call_de_o         = 1'bx;
            dpu_br_return_de_o       = 1'bx;
            rtn_addr_valid_de_o      = 1'bx;
          end
        endcase
      end
      5'b01000 : begin // Neon decoder
        case ({decoder_select1_early[DEC1_LS],
               decoder_select1_early[DEC1_BR]})
          2'b00 : begin
            // Nothing dual issuing from slot 1
            // - Use defaults
          end
          2'b01 : begin
            // Branch dual-issuing from slot 1
            br_pipectl_de_o          = br_pipectl_dec1_br[`CA53_BR_PIPECTL_W-1:0];
            br_btac_de_o             = br_btac_dec1_br;
            br_offset_de_o           = br_offset_dec1_br[27:1];
            br_pred_takenness_de_o   = br_pred_takenness_dec1_br;
            br_x_bit_de_o            = br_x_bit_dec1_br;
            dpu_pred_br_de_o         = pred_br_dec1_br;
            dpu_br_call_de_o         = br_call_dec1_br;
            dpu_br_return_de_o       = br_return_dec1_br;
            rtn_addr_valid_de_o      = rtn_addr_valid_dec1_br;
          end
          2'b10 : begin
            // Load-store dual issuing from slot 1
            // - Use defaults
          end
          default : begin
            br_pipectl_de_o          = {`CA53_BR_PIPECTL_W{1'bx}};
            br_btac_de_o             = 1'bx;
            br_offset_de_o           = {27{1'bx}};
            br_pred_takenness_de_o   = 1'bx;
            br_x_bit_de_o            = 1'bx;
            dpu_pred_br_de_o         = 1'bx;
            dpu_br_call_de_o         = 1'bx;
            dpu_br_return_de_o       = 1'bx;
            rtn_addr_valid_de_o      = 1'bx;
          end
        endcase
      end
      5'b10000 : begin // Branch decoder
        br_pipectl_de_o          = br_pipectl_dec0_br[`CA53_BR_PIPECTL_W-1:0];
        br_btac_de_o             = br_btac_dec0_br;
        br_offset_de_o           = br_offset_dec0_br[27:1];
        br_pred_takenness_de_o   = br_pred_takenness_dec0_br;
        br_x_bit_de_o            = br_x_bit_dec0_br;
        dpu_pred_br_de_o         = pred_br_dec0_br;
        dpu_br_call_de_o         = br_call_dec0_br;
        dpu_br_return_de_o       = br_return_dec0_br;
        rtn_addr_valid_de_o      = rtn_addr_valid_dec0_br;
      end
      default : begin
        br_pipectl_de_o          = {`CA53_BR_PIPECTL_W{1'bx}};
        br_btac_de_o             = 1'bx;
        br_offset_de_o           = {27{1'bx}};
        br_pred_takenness_de_o   = 1'bx;
        br_x_bit_de_o            = 1'bx;
        dpu_pred_br_de_o         = 1'bx;
        dpu_br_call_de_o         = 1'bx;
        dpu_br_return_de_o       = 1'bx;
        rtn_addr_valid_de_o      = 1'bx;
      end
    endcase
  end

  // CP
  always @* begin
    cp_valid_de_o                = 1'b0;
    cp_decode_de_o               = {9{1'b0}};
    cp_de_o                      = 1'b0;
    cp_op_de_o                   = {9{1'b0}};
    cp_op_mva_de_o               = 1'b0;
    cp_op_ats1_de_o              = 1'b0;
    cp_other_sec_de_o            = 1'b0;
    fp_serialise_de_o            = 1'b0;

    case ({decoder_select0[NE],
           decoder_select0[OT],
           decoder_select0[LS],
           decoder_select0[DP]})
      4'b0000 : begin // Use defaults
      end
      4'b0001 : begin // Data-processing decoder
        // - Use defaults
      end
      4'b0010 : begin // Load-store decoder
        cp_de_o                  = cp_ls;
        cp_op_de_o               = cp_op_ls[8:0];
        cp_op_mva_de_o           = cp_op_mva_ls;
      end
      4'b0100 : begin // Other decoder
        cp_de_o                  = cp_other;
        cp_op_de_o               = cp_op_other[8:0];
        cp_op_mva_de_o           = cp_op_mva_other;
        cp_op_ats1_de_o          = cp_op_ats1_other;
        cp_other_sec_de_o        = cp_other_sec_other;
        cp_valid_de_o            = cp_valid_other;
        cp_decode_de_o           = cp_decode_other[8:0];
        fp_serialise_de_o        = fp_serialise_other;
      end
      4'b1000 : begin // Neon decoder
        cp_valid_de_o            = cp_valid_neon;
        cp_decode_de_o           = cp_decode_neon[8:0];
        fp_serialise_de_o        = fp_serialise_neon;
      end
      default : begin
        cp_de_o                  = 1'bx;
        cp_op_de_o               = {9{1'bx}};
        cp_op_mva_de_o           = 1'bx;
        cp_op_ats1_de_o          = 1'bx;
        cp_other_sec_de_o        = 1'bx;
        cp_valid_de_o            = 1'bx;
        cp_decode_de_o           = {9{1'bx}};
        fp_serialise_de_o        = 1'bx;
      end
    endcase
  end

  // CPSR
  always @* begin
    cpsr_ebit_value_de_o         = 1'b0;
    cpsr_aifbits_val_o           = {6{1'b0}};
    t16o_it_cpsr_valid_de_o      = 1'b0;
    t16o_it_cpsr_mask_de_o       = {8{1'b0}};
    psr_wr_operation_de_o        = 1'b0;
    psr_wr_en_de_o               = {`CA53_SEL_CPSR_EN_W{1'b0}};
    psr_wr_src_de_o              = {`CA53_SEL_CPSR_SRC_W{1'b0}};
    flag_en_instr1_de_o          = {`CA53_FLAGEN_INSTR1_W{1'b0}};
    mul_cpsr_nz_v_de_o           = 1'b0;

    case ({decoder_select0[BR],
           decoder_select0[NE],
           decoder_select0[OT],
           decoder_select0[LS],
           decoder_select0[DP]})
      5'b00000 : begin // Use defaults
      end
      5'b00001 : begin // Data-processing decoder
        psr_wr_operation_de_o    = psr_wr_operation_dp;
        psr_wr_en_de_o           = psr_wr_en_dp;
        psr_wr_src_de_o          = psr_wr_src_dp;
        mul_cpsr_nz_v_de_o       = mul_cpsr_nz_v_dp;

        case ({decoder_select1[DEC1_NE],
               decoder_select1[DEC1_LS],
               decoder_select1[DEC1]})
          3'b000 : begin
            // Nothing dual issuing from slot 1
            // - Use defaults
          end
          3'b001 : begin
            // Dec1 instruction dual-issuing from slot 1
            // - CPSR pipe driven by Dec1
            t16o_it_cpsr_valid_de_o  = t16_it_cpsr_valid_dec1;
            t16o_it_cpsr_mask_de_o   = t16_it_cpsr_mask_dec1[7:0];
            flag_en_instr1_de_o      = flag_en_dec1[`CA53_FLAGEN_INSTR1_W-1:0];
            mul_cpsr_nz_v_de_o       = mul_cpsr_nz_v_dec1;
          end
          3'b010 : begin
            // Load-store dual issuing from slot 1
            // - Use defaults
          end
          3'b100 : begin
            // Neon instruction dual-issuing from slot 1
            // - CPSR pipe driven by Dec1
            flag_en_instr1_de_o      = flag_en_dec1_ne[`CA53_FLAGEN_INSTR1_W-1:0];
          end
          default : begin
            t16o_it_cpsr_valid_de_o  = 1'bx;
            t16o_it_cpsr_mask_de_o   = {8{1'bx}};
            flag_en_instr1_de_o      = {`CA53_FLAGEN_INSTR1_W{1'bx}};
          end
        endcase
      end
      5'b00010 : begin // Load-store decoder
        psr_wr_operation_de_o    = psr_wr_operation_ls;
        psr_wr_en_de_o           = psr_wr_en_ls;
        psr_wr_src_de_o          = psr_wr_src_ls;

        case ({decoder_select1[DEC1_NE],
               decoder_select1[DEC1_LS],
               decoder_select1[DEC1]})
          3'b000 : begin
            // Nothing dual issuing from slot 1
            // - Use defaults
          end
          3'b001 : begin
            // Dec1 instruction dual-issuing from slot 1
            // - CPSR pipe driven by Dec1
            t16o_it_cpsr_valid_de_o  = t16_it_cpsr_valid_dec1;
            t16o_it_cpsr_mask_de_o   = t16_it_cpsr_mask_dec1[7:0];
            flag_en_instr1_de_o      = flag_en_dec1[`CA53_FLAGEN_INSTR1_W-1:0];
            mul_cpsr_nz_v_de_o       = mul_cpsr_nz_v_dec1;
          end
          3'b100 : begin
            // Neon instruction dual-issuing from slot 1
            // - CPSR pipe driven by Dec1
            flag_en_instr1_de_o      = flag_en_dec1_ne[`CA53_FLAGEN_INSTR1_W-1:0];
          end
          default : begin
            t16o_it_cpsr_valid_de_o  = 1'bx;
            t16o_it_cpsr_mask_de_o   = {8{1'bx}};
            flag_en_instr1_de_o      = {`CA53_FLAGEN_INSTR1_W{1'bx}};
          end
        endcase
      end
      5'b00100 : begin // Other decoder
        cpsr_aifbits_val_o       = cpsr_aifbits_value_other[5:0];
        cpsr_ebit_value_de_o     = cpsr_ebit_value_other;
        psr_wr_operation_de_o    = psr_wr_operation_other;
        psr_wr_en_de_o           = psr_wr_en_other;
        psr_wr_src_de_o          = psr_wr_src_other;

        case ({decoder_select1[DEC1_NE],
               decoder_select1[DEC1_LS],
               decoder_select1[DEC1]})
          3'b000 : begin
            // Nothing dual issuing from slot 1
            t16o_it_cpsr_valid_de_o  = t16_it_cpsr_valid_other;
            t16o_it_cpsr_mask_de_o   = t16_it_cpsr_mask_other[7:0];
          end
          3'b001 : begin
            // Dec1 instruction dual-issuing from slot 1
            // - Instr1 part of CPSR pipe driven by Dec1
            t16o_it_cpsr_valid_de_o  = t16_it_cpsr_valid_other | t16_it_cpsr_valid_dec1;
            t16o_it_cpsr_mask_de_o   = t16_it_cpsr_valid_dec1 ? t16_it_cpsr_mask_dec1[7:0]
                                                              : t16_it_cpsr_mask_other[7:0];
            flag_en_instr1_de_o      = flag_en_dec1[`CA53_FLAGEN_INSTR1_W-1:0];
            mul_cpsr_nz_v_de_o       = mul_cpsr_nz_v_dec1;
          end
          3'b010 : begin
            // Load-store dual issuing from slot 1
            t16o_it_cpsr_valid_de_o  = t16_it_cpsr_valid_other;
            t16o_it_cpsr_mask_de_o   = t16_it_cpsr_mask_other[7:0];
          end
          3'b100 : begin
            // Neon instruction dual-issuing from slot 1
            // - Instr1 part of CPSR pipe driven by Neon Dec1
            t16o_it_cpsr_valid_de_o  = t16_it_cpsr_valid_other;
            t16o_it_cpsr_mask_de_o   = t16_it_cpsr_mask_other[7:0];
            flag_en_instr1_de_o      = flag_en_dec1_ne[`CA53_FLAGEN_INSTR1_W-1:0];
          end
          default : begin
            flag_en_instr1_de_o      = {`CA53_FLAGEN_INSTR1_W{1'bx}};
          end
        endcase
      end
      5'b01000 : begin // Neon decoder
        // Common outputs not dependent on dual issuing:
        psr_wr_operation_de_o    = psr_wr_operation_neon;
        psr_wr_en_de_o           = psr_wr_en_neon;
        psr_wr_src_de_o          = psr_wr_src_neon[3:0];

        // Outputs which depend on what Slot 0 Neon being dual
        // issued with:
        case ({decoder_select1[DEC1_NE],
               decoder_select1[DEC1_LS],
               decoder_select1[DEC1]})
          3'b000 : begin
            // Nothing dual issuing from slot 1
            // - Use defaults
          end
          3'b001 : begin
            // Dec1 instruction dual-issuing from slot
            // - CPSR pipe driven by Dec1
            t16o_it_cpsr_valid_de_o  = t16_it_cpsr_valid_dec1;
            t16o_it_cpsr_mask_de_o   = t16_it_cpsr_mask_dec1[7:0];
            flag_en_instr1_de_o      = flag_en_dec1[`CA53_FLAGEN_INSTR1_W-1:0];
            mul_cpsr_nz_v_de_o       = mul_cpsr_nz_v_dec1;
          end
          3'b010 : begin
            // Load-store dual issuing from slot 1
            // - Use defaults
          end
          3'b100 : begin
            // Neon instruction dual-issuing from slot 1
            // - CPSR pipe driven by Dec1
            flag_en_instr1_de_o      = flag_en_dec1_ne[`CA53_FLAGEN_INSTR1_W-1:0];
          end
          default : begin
            t16o_it_cpsr_valid_de_o  = 1'bx;
            t16o_it_cpsr_mask_de_o   = {8{1'bx}};
            flag_en_instr1_de_o      = {`CA53_FLAGEN_INSTR1_W{1'bx}};
            mul_cpsr_nz_v_de_o       = 1'bx;
          end
        endcase
      end
      5'b10000 : begin // Branch decoder
        psr_wr_operation_de_o    = psr_wr_operation_dec0_br;
        psr_wr_en_de_o           = psr_wr_en_dec0_br;
        psr_wr_src_de_o          = psr_wr_src_dec0_br;

        case ({decoder_select1[DEC1_NE],
               decoder_select1[DEC1_LS],
               decoder_select1[DEC1]})
          3'b000 : begin
            // Nothing dual issuing from slot 1
          end
          3'b001 : begin
            // Dec1 instruction dual-issuing from slot 1
            // - Instr1 part of CPSR pipe driven by Dec1
            t16o_it_cpsr_valid_de_o  = t16_it_cpsr_valid_dec1;
            t16o_it_cpsr_mask_de_o   = t16_it_cpsr_mask_dec1[7:0];
            flag_en_instr1_de_o      = flag_en_dec1[`CA53_FLAGEN_INSTR1_W-1:0];
            mul_cpsr_nz_v_de_o       = mul_cpsr_nz_v_dec1;
          end
          3'b010 : begin
            // Load-store dual issuing from slot 1
          end
          3'b100 : begin
            // Neon instruction dual-issuing from slot 1
            // - Instr1 part of CPSR pipe driven by Neon Dec1
            flag_en_instr1_de_o      = flag_en_dec1_ne[`CA53_FLAGEN_INSTR1_W-1:0];
          end
          default : begin
            flag_en_instr1_de_o      = {`CA53_FLAGEN_INSTR1_W{1'bx}};
            t16o_it_cpsr_valid_de_o  = 1'bx;
            t16o_it_cpsr_mask_de_o   = {8{1'bx}};
            mul_cpsr_nz_v_de_o       = 1'bx;
          end
        endcase
      end
      default : begin
        cpsr_ebit_value_de_o     = 1'bx;
        cpsr_aifbits_val_o       = {6{1'bx}};
        t16o_it_cpsr_valid_de_o  = 1'bx;
        t16o_it_cpsr_mask_de_o   = {8{1'bx}};
        psr_wr_operation_de_o    = 1'bx;
        psr_wr_en_de_o           = {`CA53_SEL_CPSR_EN_W{1'bx}};
        psr_wr_src_de_o          = {`CA53_SEL_CPSR_SRC_W{1'bx}};
        flag_en_instr1_de_o      = {`CA53_FLAGEN_INSTR1_W{1'bx}};
        mul_cpsr_nz_v_de_o       = 1'bx;
      end
    endcase
  end

  // FPU Pipe 0
  always @* begin
    case (decoder_select0[NE])
      1'b0 : begin  // Not Neon decoder
        fp_ex_pipe_de_o[`CA53_FP_EX_PIPE_ADD0]  = 1'b0;
        fp_ex_pipe_de_o[`CA53_FP_EX_PIPE_MUL0]  = 1'b0;
        neon_vld_ctl_de_o                       = {`CA53_NEON_VLD_CTL_W{1'b0}};
        neon_can_fwd_acc_de_o[0]                = 1'b0;
        fmac_valid_sp_de_o[0]                   = 1'b0;
        fdiv_valid_de_o[0]                      = 1'b0;
        instr_fmstat_de_o[0]                    = 1'b0;
        crypto_enable_de_o                      = 1'b0;
        rf_rd_addr_fr0_de_o                     = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
        rf_rd_addr_fr1_de_o                     = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
        rf_rd_addr_fr2_de_o                     = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
        rf_rd_en_fr0_de_o                       = {2{1'b0}};
        rf_rd_en_fr1_de_o                       = {2{1'b0}};
        rf_rd_en_fr2_de_o                       = {2{1'b0}};
        rf_rd_need_fr0_de_o                     = {`CA53_RF_FRD_NEED_W{1'b0}};
        rf_rd_need_fr1_de_o                     = {`CA53_RF_FRD_NEED_W{1'b0}};
        rf_rd_need_fr2_de_o                     = {`CA53_RF_FRD_NEED_W{1'b0}};
        rf_wr_addr_fw0_de_o                     = {`CA53_FP_RF_WR_ADDR_W{1'b0}};
        rf_wr_en_fw0_de_o                       = {4{1'b0}};
        rf_wr_src_fw0_de_o                      = {`CA53_RF_FWR_SRC_W{1'b0}};
        rf_wr_when_fw0_de_o                     = {`CA53_RF_FWR_WHEN_W{1'b0}};
      end
      1'b1 : begin // Neon decoder
        // Common outputs not dependent on dual issuing:
        fp_ex_pipe_de_o[`CA53_FP_EX_PIPE_ADD0]  = fp_ex_pipe_neon[`CA53_FP_EX_PIPE_ADD0];
        fp_ex_pipe_de_o[`CA53_FP_EX_PIPE_MUL0]  = fp_ex_pipe_neon[`CA53_FP_EX_PIPE_MUL0];
        neon_vld_ctl_de_o                       = neon_vld_ctl_neon[`CA53_NEON_VLD_CTL_W-1:0];
        neon_can_fwd_acc_de_o[0]                = neon_can_fwd_acc_neon;
        fmac_valid_sp_de_o[0]                   = fmac_valid_sp_neon;
        fdiv_valid_de_o[0]                      = fdiv_valid_neon;
        instr_fmstat_de_o[0]                    = instr_fmstat_neon;
        crypto_enable_de_o                      = crypto_enable_neon;
        rf_rd_addr_fr0_de_o                     = rf_rd_addr_fr0_neon[`CA53_FP_RF_RD_ADDR_W-1:0];
        rf_rd_addr_fr1_de_o                     = rf_rd_addr_fr1_neon[`CA53_FP_RF_RD_ADDR_W-1:0];
        rf_rd_addr_fr2_de_o                     = rf_rd_addr_fr2_neon[`CA53_FP_RF_RD_ADDR_W-1:0];
        rf_rd_en_fr0_de_o                       = rf_rd_en_fr0_neon[1:0];
        rf_rd_en_fr1_de_o                       = rf_rd_en_fr1_neon[1:0];
        rf_rd_en_fr2_de_o                       = rf_rd_en_fr2_neon[1:0];
        rf_rd_need_fr0_de_o                     = rf_rd_need_fr0_neon[`CA53_RF_FRD_NEED_W-1:0];
        rf_rd_need_fr1_de_o                     = rf_rd_need_fr1_neon[`CA53_RF_FRD_NEED_W-1:0];
        rf_rd_need_fr2_de_o                     = rf_rd_need_fr2_neon[`CA53_RF_FRD_NEED_W-1:0];
        rf_wr_addr_fw0_de_o                     = rf_wr_addr_fw0_neon[`CA53_FP_RF_WR_ADDR_W-1:0];
        rf_wr_en_fw0_de_o                       = rf_wr_en_fw0_neon;
        rf_wr_src_fw0_de_o                      = rf_wr_src_fw0_neon[(`CA53_RF_FWR_SRC_W-1):0];
        rf_wr_when_fw0_de_o                     = rf_wr_when_fw0_neon[`CA53_RF_FWR_WHEN_W-1:0];
      end
      default : begin
        fp_ex_pipe_de_o[`CA53_FP_EX_PIPE_ADD0]  = 1'bx;
        fp_ex_pipe_de_o[`CA53_FP_EX_PIPE_MUL0]  = 1'bx;
        neon_vld_ctl_de_o                       = {`CA53_NEON_VLD_CTL_W{1'bx}};
        neon_can_fwd_acc_de_o[0]                = 1'bx;
        fmac_valid_sp_de_o[0]                   = 1'bx;
        fdiv_valid_de_o[0]                      = 1'bx;
        instr_fmstat_de_o[0]                    = 1'bx;
        crypto_enable_de_o                      = 1'bx;
        rf_rd_addr_fr0_de_o                     = {`CA53_FP_RF_RD_ADDR_W{1'bx}};
        rf_rd_addr_fr1_de_o                     = {`CA53_FP_RF_RD_ADDR_W{1'bx}};
        rf_rd_addr_fr2_de_o                     = {`CA53_FP_RF_RD_ADDR_W{1'bx}};
        rf_rd_en_fr0_de_o                       = {2{1'bx}};
        rf_rd_en_fr1_de_o                       = {2{1'bx}};
        rf_rd_en_fr2_de_o                       = {2{1'bx}};
        rf_rd_need_fr0_de_o                     = {`CA53_RF_FRD_NEED_W{1'bx}};
        rf_rd_need_fr1_de_o                     = {`CA53_RF_FRD_NEED_W{1'bx}};
        rf_rd_need_fr2_de_o                     = {`CA53_RF_FRD_NEED_W{1'bx}};
        rf_wr_addr_fw0_de_o                     = {`CA53_FP_RF_WR_ADDR_W{1'bx}};
        rf_wr_en_fw0_de_o                       = {4{1'bx}};
        rf_wr_src_fw0_de_o                      = {`CA53_RF_FWR_SRC_W{1'bx}};
        rf_wr_when_fw0_de_o                     = {`CA53_RF_FWR_WHEN_W{1'bx}};
      end
    endcase
  end

  // FPU Pipe 1
  assign dec0_neon_uses_pipe1_de = decoder_select0[NE] &
                                   (fp_ex_pipe_neon[`CA53_FP_EX_PIPE_ADD1] |
                                    fp_ex_pipe_neon[`CA53_FP_EX_PIPE_MUL1] |
                                    crypto_enable_neon                     |
                                    (ls_instr_type_neon == `CA53_LS_INSTR_MULTIPLE) |
                                    (|rf_wr_en_fw1_neon));

  always @* begin
    case ({decoder_select1[DEC1_NE],
           dec0_neon_uses_pipe1_de})
      2'b00 : begin  // Not Neon decoder
        fp_ex_pipe_de_o[`CA53_FP_EX_PIPE_ADD1]  = 1'b0;
        fp_ex_pipe_de_o[`CA53_FP_EX_PIPE_MUL1]  = 1'b0;
        fmac_valid_sp_de_o[1]                   = 1'b0;
        fdiv_valid_de_o[1]                      = 1'b0;
        instr_fmstat_de_o[1]                    = 1'b0;
        rf_rd_en_fr3_de_o                       = {2{1'b0}};
        rf_rd_en_fr4_de_o                       = {2{1'b0}};
        rf_rd_en_fr5_de_o                       = {2{1'b0}};
        rf_wr_en_fw1_de_o                       = {4{1'b0}};
      end
      2'b01, 2'b11 : begin // Slot 0 Neon decoder
        fp_ex_pipe_de_o[`CA53_FP_EX_PIPE_ADD1]  = fp_ex_pipe_neon[`CA53_FP_EX_PIPE_ADD1];
        fp_ex_pipe_de_o[`CA53_FP_EX_PIPE_MUL1]  = fp_ex_pipe_neon[`CA53_FP_EX_PIPE_MUL1];
        fmac_valid_sp_de_o[1]                   = fmac_valid_sp_neon;
        fdiv_valid_de_o[1]                      = fdiv_valid_neon;
        instr_fmstat_de_o[1]                    = 1'b0;
        rf_rd_en_fr3_de_o                       = rf_rd_en_fr3_neon[1:0];
        rf_rd_en_fr4_de_o                       = rf_rd_en_fr4_neon[1:0];
        rf_rd_en_fr5_de_o                       = rf_rd_en_fr5_neon[1:0];
        rf_wr_en_fw1_de_o                       = rf_wr_en_fw1_neon;
      end
      2'b10 : begin // Slot 1 Neon decoder
        fp_ex_pipe_de_o[`CA53_FP_EX_PIPE_ADD1]  = fp_ex_pipe_dec1_ne[`CA53_FP_EX_PIPE_ADD0];
        fp_ex_pipe_de_o[`CA53_FP_EX_PIPE_MUL1]  = fp_ex_pipe_dec1_ne[`CA53_FP_EX_PIPE_MUL0];
        fmac_valid_sp_de_o[1]                   = fmac_valid_sp_dec1_ne;
        fdiv_valid_de_o[1]                      = 1'b0; // Can't D1 FDIV
        instr_fmstat_de_o[1]                    = instr_fmstat_dec1_ne;
        rf_rd_en_fr3_de_o                       = rf_rd_en_fr0_dec1_ne[1:0];
        rf_rd_en_fr4_de_o                       = rf_rd_en_fr1_dec1_ne[1:0];
        rf_rd_en_fr5_de_o                       = rf_rd_en_fr2_dec1_ne[1:0];
        rf_wr_en_fw1_de_o                       = rf_wr_en_fw0_dec1_ne;
      end
      default : begin
        fp_ex_pipe_de_o[`CA53_FP_EX_PIPE_ADD1]  = 1'bx;
        fp_ex_pipe_de_o[`CA53_FP_EX_PIPE_MUL1]  = 1'bx;
        fmac_valid_sp_de_o[1]                   = 1'bx;
        fdiv_valid_de_o[1]                      = 1'bx;
        instr_fmstat_de_o[1]                    = 1'bx;
        rf_rd_en_fr3_de_o                       = {2{1'bx}};
        rf_rd_en_fr4_de_o                       = {2{1'bx}};
        rf_rd_en_fr5_de_o                       = {2{1'bx}};
        rf_wr_en_fw1_de_o                       = {4{1'bx}};
      end
    endcase
  end

  always @* begin
    case ({decoder_select1_early[DEC1_NE],
           dec0_neon_uses_pipe1_de})
      2'b00 : begin  // Not Neon decoder
        neon_can_fwd_acc_de_o[1]                = 1'b0;
        rf_rd_addr_fr3_de_o                     = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
        rf_rd_addr_fr4_de_o                     = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
        rf_rd_addr_fr5_de_o                     = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
        rf_rd_need_fr3_de_o                     = {`CA53_RF_FRD_NEED_W{1'b0}};
        rf_rd_need_fr4_de_o                     = {`CA53_RF_FRD_NEED_W{1'b0}};
        rf_rd_need_fr5_de_o                     = {`CA53_RF_FRD_NEED_W{1'b0}};
        rf_wr_addr_fw1_de_o                     = {`CA53_FP_RF_WR_ADDR_W{1'b0}};
        rf_wr_src_fw1_de_o                      = {`CA53_RF_FWR_SRC_W{1'b0}};
        rf_wr_when_fw1_de_o                     = {`CA53_RF_FWR_WHEN_W{1'b0}};
      end
      2'b01, 2'b11 : begin // Slot 0 Neon decoder
        neon_can_fwd_acc_de_o[1]                = neon_can_fwd_acc_neon;
        rf_rd_addr_fr3_de_o                     = rf_rd_addr_fr3_neon[`CA53_FP_RF_RD_ADDR_W-1:0];
        rf_rd_addr_fr4_de_o                     = rf_rd_addr_fr4_neon[`CA53_FP_RF_RD_ADDR_W-1:0];
        rf_rd_addr_fr5_de_o                     = rf_rd_addr_fr5_neon[`CA53_FP_RF_RD_ADDR_W-1:0];
        rf_rd_need_fr3_de_o                     = rf_rd_need_fr3_neon[`CA53_RF_FRD_NEED_W-1:0];
        rf_rd_need_fr4_de_o                     = rf_rd_need_fr4_neon[`CA53_RF_FRD_NEED_W-1:0];
        rf_rd_need_fr5_de_o                     = rf_rd_need_fr5_neon[`CA53_RF_FRD_NEED_W-1:0];
        rf_wr_addr_fw1_de_o                     = rf_wr_addr_fw1_neon[`CA53_FP_RF_WR_ADDR_W-1:0];
        rf_wr_src_fw1_de_o                      = rf_wr_src_fw0_neon[`CA53_RF_FWR_SRC_W-1:0];
        rf_wr_when_fw1_de_o                     = rf_wr_when_fw0_neon[`CA53_RF_FWR_WHEN_W-1:0];
      end
      2'b10 : begin // Slot 1 Neon decoder
        neon_can_fwd_acc_de_o[1]                = neon_can_fwd_acc_dec1_ne;
        rf_rd_addr_fr3_de_o                     = rf_rd_addr_fr0_dec1_ne[`CA53_FP_RF_RD_ADDR_W-1:0];
        rf_rd_addr_fr4_de_o                     = rf_rd_addr_fr1_dec1_ne[`CA53_FP_RF_RD_ADDR_W-1:0];
        rf_rd_addr_fr5_de_o                     = rf_rd_addr_fr2_dec1_ne[`CA53_FP_RF_RD_ADDR_W-1:0];
        rf_rd_need_fr3_de_o                     = rf_rd_need_fr0_dec1_ne[`CA53_RF_FRD_NEED_W-1:0];
        rf_rd_need_fr4_de_o                     = rf_rd_need_fr1_dec1_ne[`CA53_RF_FRD_NEED_W-1:0];
        rf_rd_need_fr5_de_o                     = rf_rd_need_fr2_dec1_ne[`CA53_RF_FRD_NEED_W-1:0];
        rf_wr_addr_fw1_de_o                     = rf_wr_addr_fw0_dec1_ne[`CA53_FP_RF_WR_ADDR_W-1:0];
        rf_wr_src_fw1_de_o                      = rf_wr_src_fw0_dec1_ne[`CA53_RF_FWR_SRC_W-1:0];
        rf_wr_when_fw1_de_o                     = rf_wr_when_fw0_dec1_ne[`CA53_RF_FWR_WHEN_W-1:0];
      end
      default : begin
        neon_can_fwd_acc_de_o[1]                = 1'bx;
        rf_rd_addr_fr3_de_o                     = {`CA53_FP_RF_RD_ADDR_W{1'bx}};
        rf_rd_addr_fr4_de_o                     = {`CA53_FP_RF_RD_ADDR_W{1'bx}};
        rf_rd_addr_fr5_de_o                     = {`CA53_FP_RF_RD_ADDR_W{1'bx}};
        rf_rd_need_fr3_de_o                     = {`CA53_RF_FRD_NEED_W{1'bx}};
        rf_rd_need_fr4_de_o                     = {`CA53_RF_FRD_NEED_W{1'bx}};
        rf_rd_need_fr5_de_o                     = {`CA53_RF_FRD_NEED_W{1'bx}};
        rf_wr_addr_fw1_de_o                     = {`CA53_FP_RF_WR_ADDR_W{1'bx}};
        rf_wr_src_fw1_de_o                      = {`CA53_RF_FWR_SRC_W{1'bx}};
        rf_wr_when_fw1_de_o                     = {`CA53_RF_FWR_WHEN_W{1'bx}};
      end
    endcase
  end

  // Integer regbank
  always @* begin
    // RF Rd
    rf_rd_en_r0_0_de             = 1'b0;
    rf_rd_en_r1_0_de             = 1'b0;
    rf_rd_en_r2_0_de             = 1'b0;
    rf_rd_en_r3_0_de             = 1'b0;
    rf_rd_need_r0_0_de           = {`CA53_RF_RD_NEED_W{1'b0}};
    rf_rd_need_r1_0_de           = {`CA53_RF_RD_NEED_W{1'b0}};
    rf_rd_need_r2_0_de           = {`CA53_RF_RD_NEED_W{1'b0}};
    rf_rd_need_r3_0_de           = {`CA53_RF_RD_NEED_W{1'b0}};
    nxt_rf_rd_sel_0_r0_subseq    = {8{1'b0}};
    nxt_rf_rd_sel_0_r1_subseq    = {6{1'b0}};
    nxt_rf_rd_sel_0_r2_subseq    = {9{1'b0}};
    nxt_rf_rd_sel_0_r3_subseq    = {5{1'b0}};

    // RF Wr
    rf_wr_en_w0_0_de             = 1'b0;
    rf_wr_en_w1_0_de             = 1'b0;
    rf_wr_en_w2_0_de             = 1'b0;
    rf_wr_when_w0_0_de           = {`CA53_RF_WR_WHEN_W{1'b0}};
    rf_wr_when_w1_0_de           = {`CA53_RF_WR_WHEN_W{1'b0}};
    rf_wr_when_w2_0_de           = {`CA53_RF_WR_WHEN_W{1'b0}};
    rf_wr_vaddr_w0_0_de          = {5{1'b0}};
    rf_wr_vaddr_w1_0_de          = {5{1'b0}};
    rf_wr_vaddr_w2_0_de          = {5{1'b0}};
    rf_wr_64b_w0_0_de            = 1'b0;
    rf_wr_64b_w1_0_de            = 1'b0;
    rf_wr_64b_w2_0_de            = 1'b0;
    rf_wr_src_w0_0_de            = {`CA53_RF_WR_SRC_W0_W{1'b0}};
    rf_wr_src_w1_0_de            = {`CA53_RF_WR_SRC_W1_W{1'b0}};
    rf_wr_src_w2_0_de            = {`CA53_RF_WR_SRC_W2_W{1'b0}};

    usr_mode_regs_ldm_de_o       = 1'b0;      // Used for Write port vaddr->paddr
    postfix_srs_mode_de          = {5{1'b0}}; // Used for Write port vaddr->paddr
    srs_mode_ctl_de              = 1'b0;      // Used for Read+Write port vaddr->paddr

    case ({decoder_select0[BR],
           decoder_select0[NE],
           decoder_select0[UN],
           decoder_select0[FO],
           decoder_select0[OT],
           decoder_select0[LS],
           decoder_select0[DP]})
      7'b000_0000 : begin // Use defaults
      end
      7'b000_0001 : begin // Data-processing decoder
        rf_rd_en_r0_0_de         = rf_rd_en_r0_dp;
        rf_rd_en_r1_0_de         = rf_rd_en_r1_dp;
        rf_rd_en_r2_0_de         = rf_rd_en_r2_dp;
        rf_rd_en_r3_0_de         = rf_rd_en_r3_dp;
        rf_rd_need_r0_0_de       = rf_rd_need_r0_dp[`CA53_RF_RD_NEED_W-1:0];
        rf_rd_need_r1_0_de       = rf_rd_need_r1_dp[`CA53_RF_RD_NEED_W-1:0];
        rf_rd_need_r2_0_de       = rf_rd_need_r2_dp[`CA53_RF_RD_NEED_W-1:0];
        rf_rd_need_r3_0_de       = rf_rd_need_r3_dp[`CA53_RF_RD_NEED_W-1:0];
        rf_wr_vaddr_w0_0_de      = rf_wr_vaddr_w0_dp[4:0];
        rf_wr_vaddr_w1_0_de      = rf_wr_vaddr_w1_dp[4:0];
        rf_wr_en_w0_0_de         = rf_wr_en_w0_dp;
        rf_wr_en_w1_0_de         = rf_wr_en_w1_dp;
        rf_wr_64b_w0_0_de        = rf_wr_64b_w0_dp;
        rf_wr_64b_w1_0_de        = rf_wr_64b_w1_dp;
        rf_wr_src_w0_0_de        = rf_wr_src_w0_dp[`CA53_RF_WR_SRC_W0_W-1:0];
        rf_wr_src_w1_0_de        = rf_wr_src_w1_dp[`CA53_RF_WR_SRC_W1_W-1:0];
        rf_wr_when_w0_0_de       = rf_wr_when_w0_dp[`CA53_RF_WR_WHEN_W-1:0];
        rf_wr_when_w1_0_de       = rf_wr_when_w1_dp[`CA53_RF_WR_WHEN_W-1:0];
        // - Subseq read port enables only used on multi-cycle
        // instructions, which do not dual issue
        nxt_rf_rd_sel_0_r0_subseq  = nxt_rf_rd_sel_r0_subseq_dp[7:0];
        nxt_rf_rd_sel_0_r1_subseq  = nxt_rf_rd_sel_r1_subseq_dp[5:0];
        nxt_rf_rd_sel_0_r2_subseq  = nxt_rf_rd_sel_r2_subseq_dp[8:0];
        nxt_rf_rd_sel_0_r3_subseq  = nxt_rf_rd_sel_r3_subseq_dp[4:0];
      end
      7'b000_0010 : begin // Load-store decoder
        rf_rd_en_r0_0_de         = rf_rd_en_r0_ls & ~iq_instr0_adrp_fwd;
        rf_rd_en_r1_0_de         = rf_rd_en_r1_ls;
        rf_rd_en_r2_0_de         = rf_rd_en_r2_ls;
        rf_rd_en_r3_0_de         = rf_rd_en_r3_ls;
        rf_rd_need_r0_0_de       = rf_rd_need_r0_ls[`CA53_RF_RD_NEED_W-1:0];
        rf_rd_need_r1_0_de       = rf_rd_need_r1_ls[`CA53_RF_RD_NEED_W-1:0];
        rf_rd_need_r2_0_de       = rf_rd_need_r2_ls[`CA53_RF_RD_NEED_W-1:0];
        rf_rd_need_r3_0_de       = `CA53_RF_RD_NEED_EX2;
        rf_wr_vaddr_w0_0_de      = rf_wr_vaddr_w0_ls[4:0];
        rf_wr_vaddr_w1_0_de      = rf_wr_vaddr_w1_ls[4:0];
        rf_wr_vaddr_w2_0_de      = rf_wr_vaddr_w2_ls[4:0];
        rf_wr_en_w0_0_de         = rf_wr_en_w0_ls;
        rf_wr_en_w1_0_de         = rf_wr_en_w1_ls;
        rf_wr_en_w2_0_de         = rf_wr_en_w2_ls;
        rf_wr_64b_w0_0_de        = rf_wr_64b_w0_ls;
        rf_wr_64b_w1_0_de        = rf_wr_64b_w1_ls;
        rf_wr_64b_w2_0_de        = rf_wr_64b_w2_ls;
        rf_wr_src_w0_0_de        = rf_wr_src_w0_ls[`CA53_RF_WR_SRC_W0_W-1:0];
        rf_wr_src_w1_0_de        = rf_wr_src_w1_ls[`CA53_RF_WR_SRC_W1_W-1:0];
        rf_wr_src_w2_0_de        = rf_wr_src_w2_ls[`CA53_RF_WR_SRC_W2_W-1:0];
        rf_wr_when_w0_0_de       = rf_wr_when_w0_ls[`CA53_RF_WR_WHEN_W-1:0];
        rf_wr_when_w1_0_de       = rf_wr_when_w1_ls[`CA53_RF_WR_WHEN_W-1:0];
        rf_wr_when_w2_0_de       = `CA53_RF_WR_WHEN_LATE_WR;
        usr_mode_regs_ldm_de_o   = usr_mode_regs_ldm_ls;
        postfix_srs_mode_de      = postfix_srs_mode_ls[4:0];
        srs_mode_ctl_de          = srs_mode_ctl_ls;
        // - Subseq read port enables only used on multi-cycle
        // instructions, which do not dual issue
        nxt_rf_rd_sel_0_r0_subseq  = nxt_rf_rd_sel_r0_subseq_ls[7:0];
        nxt_rf_rd_sel_0_r1_subseq  = nxt_rf_rd_sel_r1_subseq_ls[5:0];
        nxt_rf_rd_sel_0_r2_subseq  = nxt_rf_rd_sel_r2_subseq_ls[8:0];
        nxt_rf_rd_sel_0_r3_subseq  = nxt_rf_rd_sel_r3_subseq_ls[4:0];
      end
      7'b000_0100 : begin // Other decoder
        rf_rd_en_r0_0_de         = rf_rd_en_r0_other;
        rf_rd_en_r1_0_de         = rf_rd_en_r1_other;
        rf_rd_en_r2_0_de         = rf_rd_en_r2_other;
        rf_rd_en_r3_0_de         = rf_rd_en_r3_other;
        rf_rd_need_r0_0_de       = rf_rd_need_r0_other[`CA53_RF_RD_NEED_W-1:0];
        rf_rd_need_r1_0_de       = rf_rd_need_r1_other[`CA53_RF_RD_NEED_W-1:0];
        rf_wr_vaddr_w0_0_de      = rf_wr_vaddr_w0_other[4:0];
        rf_wr_vaddr_w1_0_de      = rf_wr_vaddr_w1_other[4:0];
        rf_wr_en_w0_0_de         = rf_wr_en_w0_other;
        rf_wr_en_w1_0_de         = rf_wr_en_w1_other;
        rf_wr_64b_w0_0_de        = rf_wr_64b_w0_other;
        rf_wr_64b_w1_0_de        = rf_wr_64b_w1_other;
        rf_wr_src_w0_0_de        = rf_wr_src_w0_other[`CA53_RF_WR_SRC_W0_W-1:0];
        rf_wr_src_w1_0_de        = rf_wr_src_w1_other[`CA53_RF_WR_SRC_W1_W-1:0];
        rf_wr_when_w0_0_de       = rf_wr_when_w0_other[`CA53_RF_WR_WHEN_W-1:0];
        rf_wr_when_w1_0_de       = rf_wr_when_w1_other[`CA53_RF_WR_WHEN_W-1:0];
      end
      7'b000_1000 : begin // Forceop decoder
        rf_wr_src_w1_0_de        = rf_wr_src_w1_force[`CA53_RF_WR_SRC_W1_W-1:0];
        rf_wr_vaddr_w1_0_de      = rf_wr_vaddr_w1_force[4:0];
        rf_wr_en_w1_0_de         = rf_wr_en_w1_force;
        rf_wr_64b_w1_0_de        = rf_wr_64b_w1_force;
        rf_wr_when_w1_0_de       = rf_wr_when_w1_force[`CA53_RF_WR_WHEN_W-1:0];
      end
      7'b001_0000 : begin // Undefined instruction identified by pre-decoder
      end
      7'b010_0000 : begin // Neon decoder
        rf_rd_en_r0_0_de         = rf_rd_en_r0_neon & ~iq_instr0_adrp_fwd;
        rf_rd_en_r1_0_de         = rf_rd_en_r1_neon;
        rf_rd_en_r2_0_de         = rf_rd_en_r2_neon;
        rf_rd_en_r3_0_de         = rf_rd_en_r3_neon;
        rf_rd_need_r0_0_de       = rf_rd_need_r0_neon[`CA53_RF_RD_NEED_W-1:0];
        rf_rd_need_r1_0_de       = rf_rd_need_r1_neon[`CA53_RF_RD_NEED_W-1:0];
        rf_rd_need_r2_0_de       = rf_rd_need_r2_neon[`CA53_RF_RD_NEED_W-1:0];
        rf_wr_vaddr_w0_0_de      = rf_wr_vaddr_w0_neon[4:0];
        rf_wr_vaddr_w1_0_de      = rf_wr_vaddr_w1_neon[4:0];
        rf_wr_en_w0_0_de         = rf_wr_en_w0_neon;
        rf_wr_en_w1_0_de         = rf_wr_en_w1_neon;
        rf_wr_64b_w0_0_de        = rf_wr_64b_w0_neon;
        rf_wr_64b_w1_0_de        = rf_wr_64b_w1_neon;
        rf_wr_src_w0_0_de        = rf_wr_src_w0_neon[`CA53_RF_WR_SRC_W0_W-1:0];
        rf_wr_src_w1_0_de        = rf_wr_src_w1_neon[`CA53_RF_WR_SRC_W1_W-1:0];
        rf_wr_when_w0_0_de       = rf_wr_when_w0_neon[`CA53_RF_WR_WHEN_W-1:0];
        rf_wr_when_w1_0_de       = rf_wr_when_w1_neon[`CA53_RF_WR_WHEN_W-1:0];
        // - Mult-cycle FN instructions only ever access one integer
        // register address on susbequent cycles, so set statically
        nxt_rf_rd_sel_0_r0_subseq[`CA53_RP_RD_19_16] = 1'b1;
        nxt_rf_rd_sel_0_r1_subseq[`CA53_RP_RD_3_0]   = 1'b1;
      end
      7'b100_0000 : begin // Branch decoder
        rf_rd_en_r0_0_de         = rf_rd_en_r0_dec0_br;
        rf_rd_en_r1_0_de         = rf_rd_en_r1_dec0_br;
        rf_rd_need_r0_0_de       = rf_rd_need_r0_dec0_br[`CA53_RF_RD_NEED_W-1:0];
        rf_rd_need_r1_0_de       = rf_rd_need_r1_dec0_br[`CA53_RF_RD_NEED_W-1:0];
        rf_wr_vaddr_w1_0_de      = rf_wr_vaddr_w1_dec0_br[4:0];
        rf_wr_en_w1_0_de         = rf_wr_en_w1_dec0_br;
        rf_wr_64b_w1_0_de        = rf_wr_64b_w1_dec0_br;
        rf_wr_src_w1_0_de        = rf_wr_src_w1_dec0_br[`CA53_RF_WR_SRC_W1_W-1:0];
        rf_wr_when_w1_0_de       = rf_wr_when_w1_dec0_br[`CA53_RF_WR_WHEN_W-1:0];
      end
      default : begin
        rf_rd_en_r0_0_de          = 1'bx;
        rf_rd_en_r1_0_de          = 1'bx;
        rf_rd_en_r2_0_de          = 1'bx;
        rf_rd_en_r3_0_de          = 1'bx;
        rf_rd_need_r0_0_de        = {3{1'bx}};
        rf_rd_need_r1_0_de        = {3{1'bx}};
        rf_rd_need_r2_0_de        = {3{1'bx}};
        rf_rd_need_r3_0_de        = {3{1'bx}};
        rf_wr_vaddr_w0_0_de       = {5{1'bx}};
        rf_wr_vaddr_w1_0_de       = {5{1'bx}};
        rf_wr_vaddr_w2_0_de       = {5{1'bx}};
        rf_wr_en_w0_0_de          = 1'bx;
        rf_wr_en_w1_0_de          = 1'bx;
        rf_wr_en_w2_0_de          = 1'bx;
        rf_wr_64b_w0_0_de         = 1'bx;
        rf_wr_64b_w1_0_de         = 1'bx;
        rf_wr_64b_w2_0_de         = 1'bx;
        rf_wr_src_w0_0_de         = {`CA53_RF_WR_SRC_W0_W{1'bx}};
        rf_wr_src_w1_0_de         = {`CA53_RF_WR_SRC_W1_W{1'bx}};
        rf_wr_src_w2_0_de         = {`CA53_RF_WR_SRC_W2_W{1'bx}};
        rf_wr_when_w0_0_de        = {`CA53_RF_WR_WHEN_W{1'bx}};
        rf_wr_when_w1_0_de        = {`CA53_RF_WR_WHEN_W{1'bx}};
        rf_wr_when_w2_0_de        = {`CA53_RF_WR_WHEN_W{1'bx}};
        nxt_rf_rd_sel_0_r0_subseq = {8{1'bx}};
        nxt_rf_rd_sel_0_r1_subseq = {6{1'bx}};
        nxt_rf_rd_sel_0_r2_subseq = {9{1'bx}};
        nxt_rf_rd_sel_0_r3_subseq = {5{1'bx}};
        usr_mode_regs_ldm_de_o    = 1'bx;
        postfix_srs_mode_de       = {5{1'bx}};
        srs_mode_ctl_de           = 1'bx;
      end
    endcase
  end

  always @* begin
    rf_rd_en_r0_1_de         = 1'b0;
    rf_rd_en_r1_1_de         = 1'b0;
    rf_rd_en_r2_1_de         = 1'b0;
    rf_wr_en_w0_1_de         = 1'b0;
    rf_wr_en_w1_1_de         = 1'b0;
    case ({decoder_select1[DEC1_BR],
           decoder_select1[DEC1_NE],
           decoder_select1[DEC1_LS],
           decoder_select1[DEC1]})
      4'b0000: begin // Nothing dual issuing from slot 1
      end
      4'b0001: begin // Dec1 instruction dual-issuing from slot 1
        rf_rd_en_r0_1_de         = rf_rd_en_r0_dec1;
        rf_rd_en_r1_1_de         = rf_rd_en_r1_dec1;
        rf_rd_en_r2_1_de         = rf_rd_en_r2_dec1;
        rf_wr_en_w0_1_de         = rf_wr_en_w0_dec1;
        rf_wr_en_w1_1_de         = rf_wr_en_w1_dec1;
      end
      4'b0010: begin // Load-store dual issuing from slot 1
        rf_rd_en_r0_1_de         = rf_rd_en_r0_dec1_ls & ~iq_instr1_adrp_fwd;
        rf_rd_en_r1_1_de         = rf_rd_en_r1_dec1_ls;
        rf_rd_en_r2_1_de         = rf_rd_en_r2_dec1_ls;
        rf_wr_en_w0_1_de         = rf_wr_en_w0_dec1_ls;
        rf_wr_en_w1_1_de         = rf_wr_en_w1_dec1_ls;
      end
      4'b0100: begin // Neon dual issuing from slot 1
        rf_rd_en_r0_1_de         = rf_rd_en_r0_dec1_ne & ~iq_instr1_adrp_fwd;
        rf_rd_en_r1_1_de         = rf_rd_en_r1_dec1_ne;
        rf_rd_en_r2_1_de         = rf_rd_en_r2_dec1_ne;
        rf_wr_en_w0_1_de         = rf_wr_en_w0_dec1_ne;
        rf_wr_en_w1_1_de         = rf_wr_en_w1_dec1_ne;
      end
      4'b1000: begin // Branch dual issuing from slot 1
        rf_rd_en_r0_1_de         = rf_rd_en_r0_dec1_br;
        rf_rd_en_r1_1_de         = rf_rd_en_r1_dec1_br;
        rf_wr_en_w1_1_de         = rf_wr_en_w1_dec1_br;
      end
      default: begin
        rf_rd_en_r0_1_de         = 1'bx;
        rf_rd_en_r1_1_de         = 1'bx;
        rf_rd_en_r2_1_de         = 1'bx;
        rf_wr_en_w0_1_de         = 1'bx;
        rf_wr_en_w1_1_de         = 1'bx;
      end
    endcase
  end

  always @* begin
    rf_rd_need_r0_1_de       = {`CA53_RF_RD_NEED_W{1'b0}};
    rf_rd_need_r1_1_de       = {`CA53_RF_RD_NEED_W{1'b0}};
    rf_rd_need_r2_1_de       = {`CA53_RF_RD_NEED_W{1'b0}};
    rf_wr_vaddr_w0_1_de      = {5{1'b0}};
    rf_wr_64b_w0_1_de        = 1'b0;
    rf_wr_src_w0_1_de        = {`CA53_RF_WR_SRC_W0_W{1'b0}};
    rf_wr_when_w0_1_de       = {`CA53_RF_WR_WHEN_W{1'b0}};
    rf_wr_vaddr_w1_1_de      = {5{1'b0}};
    rf_wr_64b_w1_1_de        = 1'b0;
    rf_wr_src_w1_1_de        = {`CA53_RF_WR_SRC_W1_W{1'b0}};
    rf_wr_when_w1_1_de       = {`CA53_RF_WR_WHEN_W{1'b0}};
    case ({decoder_select1_early[DEC1_BR],
           decoder_select1_early[DEC1_NE],
           decoder_select1_early[DEC1_LS],
           decoder_select1_early[DEC1]})
      4'b0000: begin // Nothing dual issuing from slot 1
      end
      4'b0001: begin // Dec1 instruction dual-issuing from slot 1
        rf_rd_need_r0_1_de       = rf_rd_need_r0_dec1;
        rf_rd_need_r1_1_de       = rf_rd_need_r1_dec1;
        rf_rd_need_r2_1_de       = rf_rd_need_r2_dec1;
        rf_wr_vaddr_w0_1_de      = rf_wr_vaddr_w0_dec1[4:0];
        rf_wr_64b_w0_1_de        = rf_wr_64b_w0_dec1;
        rf_wr_src_w0_1_de        = rf_wr_src_w0_dec1[`CA53_RF_WR_SRC_W0_W-1:0];
        rf_wr_when_w0_1_de       = rf_wr_when_w0_dec1[`CA53_RF_WR_WHEN_W-1:0];
        rf_wr_vaddr_w1_1_de      = rf_wr_vaddr_w1_dec1[4:0];
        rf_wr_64b_w1_1_de        = rf_wr_64b_w1_dec1;
        rf_wr_src_w1_1_de        = rf_wr_src_w1_dec1;
        rf_wr_when_w1_1_de       = rf_wr_when_w1_dec1[`CA53_RF_WR_WHEN_W-1:0];
      end
      4'b0010: begin // Load-store dual issuing from slot 1
        rf_rd_need_r0_1_de       = rf_rd_need_r0_dec1_ls;
        rf_rd_need_r1_1_de       = rf_rd_need_r1_dec1_ls;
        rf_rd_need_r2_1_de       = rf_rd_need_r2_dec1_ls;
        rf_wr_vaddr_w0_1_de      = rf_wr_vaddr_w0_dec1_ls[4:0];
        rf_wr_64b_w0_1_de        = rf_wr_64b_w0_dec1_ls;
        rf_wr_src_w0_1_de        = rf_wr_src_w0_dec1_ls[`CA53_RF_WR_SRC_W0_W-1:0];
        rf_wr_when_w0_1_de       = rf_wr_when_w0_dec1_ls[`CA53_RF_WR_WHEN_W-1:0];
        rf_wr_vaddr_w1_1_de      = rf_wr_vaddr_w1_dec1_ls[4:0];
        rf_wr_64b_w1_1_de        = rf_wr_64b_w1_dec1_ls;
        rf_wr_src_w1_1_de        = rf_wr_src_w1_dec1_ls;
        rf_wr_when_w1_1_de       = rf_wr_when_w1_dec1_ls;
      end
      4'b0100: begin // Neon dual issuing from slot 1
        rf_rd_need_r0_1_de       = rf_rd_need_r0_dec1_ne;
        rf_rd_need_r1_1_de       = rf_rd_need_r1_dec1_ne;
        rf_wr_vaddr_w0_1_de      = rf_wr_vaddr_w0_dec1_ne[4:0];
        rf_wr_src_w0_1_de        = rf_wr_src_w0_dec1_ne[`CA53_RF_WR_SRC_W0_W-1:0];
        rf_wr_when_w0_1_de       = rf_wr_when_w0_dec1_ne[`CA53_RF_WR_WHEN_W-1:0];
        rf_wr_vaddr_w1_1_de      = rf_wr_vaddr_w1_dec1_ne[4:0];
        rf_wr_64b_w1_1_de        = rf_wr_64b_w1_dec1_ne;
        rf_wr_src_w1_1_de        = rf_wr_src_w1_dec1_ne;
        rf_wr_when_w1_1_de       = rf_wr_when_w1_dec1_ne;
      end
      4'b1000: begin // Branch instruction dual-issuing from slot 1
        rf_rd_need_r0_1_de       = rf_rd_need_r0_dec1_br;
        rf_rd_need_r1_1_de       = rf_rd_need_r1_dec1_br;
        rf_wr_vaddr_w1_1_de      = rf_wr_vaddr_w1_dec1_br[4:0];
        rf_wr_64b_w1_1_de        = rf_wr_64b_w1_dec1_br;
        rf_wr_src_w1_1_de        = rf_wr_src_w1_dec1_br;
        rf_wr_when_w1_1_de       = rf_wr_when_w1_dec1_br[`CA53_RF_WR_WHEN_W-1:0];
      end
      default: begin
        rf_rd_need_r0_1_de       = {`CA53_RF_RD_NEED_W{1'bx}};
        rf_rd_need_r1_1_de       = {`CA53_RF_RD_NEED_W{1'bx}};
        rf_rd_need_r2_1_de       = {`CA53_RF_RD_NEED_W{1'bx}};
        rf_wr_vaddr_w0_1_de      = {5{1'bx}};
        rf_wr_64b_w0_1_de        = 1'bx;
        rf_wr_src_w0_1_de        = {`CA53_RF_WR_SRC_W0_W{1'bx}};
        rf_wr_when_w0_1_de       = {`CA53_RF_WR_WHEN_W{1'bx}};
        rf_wr_vaddr_w1_1_de      = {5{1'bx}};
        rf_wr_64b_w1_1_de        = 1'bx;
        rf_wr_src_w1_1_de        = {`CA53_RF_WR_SRC_W1_W{1'bx}};
        rf_wr_when_w1_1_de       = {`CA53_RF_WR_WHEN_W{1'bx}};
      end
    endcase
  end

  // Mux read ports using early signals
  assign rf_rd_remap_de = iq_instr1_val & (iq_instr1_is_ls |
                                           iq_instr1_fn_dcu_valid) &  // Slot 1 load/store
                          iq_instr0_d0 & ~iq_instr0_d0_uses_dcu;      // Slot 0 can dual issue and is not using AGU

  assign rf_rd_remap_de_o = rf_rd_remap_de;

  // Detect when slot 0 is using R2/R3, so can share between slot 0 and slot 1
  assign instr0_r2_enabled = ~valid_instrs_de[1] | iq_instr0_r2_enabled;  // IQ output only valid for D0 dual issueable instructions (last cycle)
  assign instr0_r3_enabled = iq_instr0_val & ~iq_instr0_d0;

  // R0-1 will always be for slot 0, unless remapping
  assign rf_rd_en_r0_de           = rf_rd_remap_de   ? rf_rd_en_r0_1_de    : rf_rd_en_r0_0_de;
  assign rf_rd_en_r0_de_o         = rf_rd_en_r0_de;
  assign rf_rd_en_r1_de_o         = rf_rd_remap_de   ? rf_rd_en_r1_1_de    : rf_rd_en_r1_0_de;

  assign rf_rd_need_r0_preskew_de = rf_rd_remap_de   ? rf_rd_need_r0_1_de  : rf_rd_need_r0_0_de;
  assign rf_rd_need_r1_preskew_de = rf_rd_remap_de   ? rf_rd_need_r1_1_de  : rf_rd_need_r1_0_de;

  assign rf_rd_addr_r0_de         = rf_rd_remap_de   ? rf_rd_addr_r0_1_de  : rf_rd_addr_r0_0_de;
  assign rf_rd_addr_r1_de         = rf_rd_remap_de   ? rf_rd_addr_r1_1_de  : rf_rd_addr_r1_0_de;

  // R2 is for slot 0 if it wants it, otherwise slot 1
  assign rf_rd_en_r2_de_o    = instr0_r2_enabled ? rf_rd_en_r2_0_de    : rf_rd_en_r2_1_de;
  assign rf_rd_need_r2_de_o  = instr0_r2_enabled ? rf_rd_need_r2_0_de  : rf_rd_need_r2_1_de;
  assign rf_rd_addr_r2_de_o  = instr0_r2_enabled ? rf_rd_addr_r2_0_de  : rf_rd_addr_r2_1_de;

  // R3 can come from 3 places:
  always @*
    case ({instr0_r3_enabled, rf_rd_remap_de})
      2'b00: begin
        rf_rd_en_r3_de_o          = rf_rd_en_r0_1_de;
        rf_rd_need_r3_preskew_de  = rf_rd_need_r0_1_de;
        rf_rd_addr_r3_de_o        = rf_rd_addr_r0_1_de;
      end
      2'b01: begin
        rf_rd_en_r3_de_o          = rf_rd_en_r0_0_de;
        rf_rd_need_r3_preskew_de  = rf_rd_need_r0_0_de;
        rf_rd_addr_r3_de_o        = rf_rd_addr_r0_0_de;
      end
      `ca53dpu_sel_1x: begin
        rf_rd_en_r3_de_o          = rf_rd_en_r3_0_de;
        rf_rd_need_r3_preskew_de  = rf_rd_need_r3_0_de;
        rf_rd_addr_r3_de_o        = rf_rd_addr_r3_0_de;
      end
      default: begin
        rf_rd_en_r3_de_o          = 1'bx;
        rf_rd_need_r3_preskew_de  = {`CA53_RF_RD_NEED_W{1'bx}};
        rf_rd_addr_r3_de_o        = {6{1'bx}};
      end
    endcase

  // R4 usually comes from Slot 1 R1, unless remapping in which case it is
  // Slot 0 R1
  // Note can never be using R4 when there is an exception, so do not need to qualify with valid_instrs_de
  assign rf_rd_en_r4_de_o         = rf_rd_remap_de  ? rf_rd_en_r1_0_de    : rf_rd_en_r1_1_de;
  assign rf_rd_need_r4_preskew_de = rf_rd_remap_de  ? rf_rd_need_r1_0_de  : rf_rd_need_r1_1_de;
  assign rf_rd_addr_r4_de_o       = rf_rd_remap_de  ? rf_rd_addr_r1_0_de  : rf_rd_addr_r1_1_de;

  // Mux write ports
  assign instr0_w0_enabled = ~iq_instr0_d0 | iq_instr0_w0_enabled;  // IQ output only valid for D0 dual issueable instructions
  assign instr0_w2_enabled = ~iq_instr0_d0;

  assign rf_wr_en_w0_de_o    = instr0_w0_enabled ? rf_wr_en_w0_0_de    : rf_wr_en_w0_1_de;
  assign rf_wr_64b_w0_de_o   = instr0_w0_enabled ? rf_wr_64b_w0_0_de   : rf_wr_64b_w0_1_de;
  assign rf_wr_src_w0_de_o   = instr0_w0_enabled ? rf_wr_src_w0_0_de   : rf_wr_src_w0_1_de;
  assign rf_wr_when_w0_de_o  = instr0_w0_enabled ? rf_wr_when_w0_0_de  : rf_wr_when_w0_1_de;
  assign rf_wr_vaddr_w0_de_o = instr0_w0_enabled ? rf_wr_vaddr_w0_0_de : rf_wr_vaddr_w0_1_de;

  assign rf_wr_en_w1_de_o    = rf_wr_en_w1_0_de;
  assign rf_wr_64b_w1_de_o   = rf_wr_64b_w1_0_de;
  assign rf_wr_src_w1_de_o   = rf_wr_src_w1_0_de;
  assign rf_wr_when_w1_de_o  = rf_wr_when_w1_0_de;
  assign rf_wr_vaddr_w1_de_o = rf_wr_vaddr_w1_0_de;

  assign rf_wr_en_w2_de_o    = instr0_w2_enabled ? rf_wr_en_w2_0_de    : rf_wr_en_w1_1_de;
  assign rf_wr_64b_w2_de_o   = instr0_w2_enabled ? rf_wr_64b_w2_0_de   : rf_wr_64b_w1_1_de;
  assign rf_wr_src_w2_de_o   = instr0_w2_enabled ? rf_wr_src_w2_0_de   : rf_wr_src_w1_1_de;
  assign rf_wr_when_w2_de_o  = instr0_w2_enabled ? rf_wr_when_w2_0_de  : rf_wr_when_w1_1_de;
  assign rf_wr_vaddr_w2_de_o = instr0_w2_enabled ? rf_wr_vaddr_w2_0_de : rf_wr_vaddr_w1_1_de;

  // Apply skewing of instructions to read need and write when signals
  // - Can only happen on DP instructions which have need of Ex1 and when of Ex2

  // Read ports
  // - Can only skew R0-1 and R3-4
  // - Which slot uses which ports depends on whether remapping
  assign skew_r0_de = rf_rd_remap_de ? (skew_instr1_r0_de & valid_instrs_de[1]) :  skew_instr0_r0_de;
  assign skew_r1_de = rf_rd_remap_de ? (skew_instr1_r1_de & valid_instrs_de[1]) :  skew_instr0_r1_de;
  assign skew_r3_de = rf_rd_remap_de ?  skew_instr0_r0_de                       : (skew_instr1_r0_de & valid_instrs_de[1]);
  assign skew_r4_de = rf_rd_remap_de ?  skew_instr0_r1_de                       : (skew_instr1_r1_de & valid_instrs_de[1]);

  assign rf_rd_need_r0_de_o = rf_rd_need_r0_preskew_de | {1'b0, skew_r0_de, 1'b0};  // Set [1] to indicate need in Iss
  assign rf_rd_need_r1_de_o = rf_rd_need_r1_preskew_de | {1'b0, skew_r1_de, 1'b0};  // (whenever skewing will have need of Ex1)
  assign rf_rd_need_r3_de_o = rf_rd_need_r3_preskew_de | {1'b0, skew_r3_de, 1'b0};
  assign rf_rd_need_r4_de_o = rf_rd_need_r4_preskew_de | {1'b0, skew_r4_de, 1'b0};

  // Write ports
  assign rf_wr_when_w1_dp       = rf_wr_when_w1_dp_preskew      & {2'b11, ~skew_instr0_de};  // Clear [0] to indicate when of Ex1
  assign rf_wr_when_w1_ls       = rf_wr_when_w1_ls_preskew      & {2'b11, ~skew_instr0_de};  // (whenever skewing will have when of Ex2)
  assign rf_wr_when_w1_neon     = rf_wr_when_w1_neon_preskew    & {2'b11, ~skew_instr0_de};
  assign rf_wr_when_w1_dec1     = rf_wr_when_w1_dec1_preskew    & {2'b11, ~skew_instr1_de};
  assign rf_wr_when_w1_dec1_ls  = rf_wr_when_w1_dec1_ls_preskew & {2'b11, ~skew_instr1_de};
  assign rf_wr_when_w1_dec1_ne  = rf_wr_when_w1_dec1_ne_preskew & {2'b11, ~skew_instr1_de};

  // Version of R2 and R3 for STM instructions to improve timing in LSM skidding logic in ctl block
  assign rf_stm_rd_addr_r2_de_o = rf_stm_rd_addr_r2_ls;
  assign rf_stm_rd_addr_r3_de_o = rf_stm_rd_addr_r3_ls;

  // Indicate to ctl block when R2 and W0 are for slot 0
  assign instr0_r2_enabled_de_o = instr0_r2_enabled;
  assign instr0_w0_enabled_de_o = instr0_w0_enabled;

  // ------------------------------------------------------
  // Execution pipeline valid signals
  // ------------------------------------------------------

  assign alu0_valid_de_o    = ex_pipe_0_de[`CA53_EX_PIPE_ALU_BIT];
  assign str0_valid_de_o    = ex_pipe_0_de[`CA53_EX_PIPE_STR_BIT] | (ex_pipe_1_de[`CA53_EX_PIPE_STR_BIT] & slot1_str0_sel_de);
  assign str1_valid_de_o    = ex_pipe_1_de[`CA53_EX_PIPE_STR_BIT] | (ex_pipe_0_de[`CA53_EX_PIPE_STR_BIT] & slot0_str1_sel_de);
  assign mac_valid_de_o     = ex_pipe_0_de[`CA53_EX_PIPE_MAC_BIT] |  ex_pipe_1_de[`CA53_EX_PIPE_MAC_BIT];
  assign ls_valid_de_o      = ex_pipe_0_de[`CA53_EX_PIPE_DCU_BIT] |  ex_pipe_1_de[`CA53_EX_PIPE_DCU_BIT];
  assign div_valid_de_o     = ex_pipe_0_de[`CA53_EX_PIPE_DIV_BIT];
  assign alu1_valid_de_o    =                                        ex_pipe_1_de[`CA53_EX_PIPE_ALU_BIT];
  assign br_valid_de_o      = ex_pipe_0_de[`CA53_EX_PIPE_BR_BIT]  |  ex_pipe_1_de[`CA53_EX_PIPE_BR_BIT];

  // ------------------------------------------------------
  // Stack pointer alignment check decode
  // ------------------------------------------------------
  // When a load/store enables RP0 and the RP0 address is R31, the instruction is
  // using the Stack Pointer as the base register. Note that is is possible to
  // use the Zero register as the base address, in which case R0 will not be enabled.
  assign ls_check_stack_de_o = rf_rd_en_r0_de & (rf_rd_remap_de ? rf_rd_r0_is_r31_1_de : rf_rd_r0_is_r31_0_de) &
                               // Stack pointer alignment checking is not done on preload instructions:
                               ~((ls_instr_type_de == `CA53_LS_INSTR_PLD_L1KEEP) |
                                 (ls_instr_type_de == `CA53_LS_INSTR_PLD_L1STRM) |
                                 (ls_instr_type_de == `CA53_LS_INSTR_PLD_L2KEEP) |
                                 (ls_instr_type_de == `CA53_LS_INSTR_PLD_L2STRM)) &
                               // Factor SCTLR enables here to improve timing in Iss:
                               (((dpu_exception_level_i == `CA53_EL0) & sctlr_sa_at_el_i[0]) |
                                ((dpu_exception_level_i == `CA53_EL1) & sctlr_sa_at_el_i[1]) |
                                ((dpu_exception_level_i == `CA53_EL2) & sctlr_sa_at_el_i[2]) |
                                ((dpu_exception_level_i == `CA53_EL3) & sctlr_sa_at_el_i[3]));

  // ------------------------------------------------------
  // Mode adjustment
  // ------------------------------------------------------

  // Expand mode for the non-SRS case
  always @* begin
    exp_cpsr_mode_de[`CA53_ONEHOT_MODE_USR_SYS_BIT] = (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_USR) | spec_cpsr_mode_sys_iss_i;
    exp_cpsr_mode_de[`CA53_ONEHOT_MODE_FIQ_BIT]     = (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_FIQ);
    exp_cpsr_mode_de[`CA53_ONEHOT_MODE_IRQ_BIT]     = (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_IRQ);
    exp_cpsr_mode_de[`CA53_ONEHOT_MODE_SVC_BIT]     = (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_SVC);
    exp_cpsr_mode_de[`CA53_ONEHOT_MODE_ABT_BIT]     = (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_ABT);
    exp_cpsr_mode_de[`CA53_ONEHOT_MODE_UND_BIT]     = (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_UND);
    exp_cpsr_mode_de[`CA53_ONEHOT_MODE_MON_BIT]     = spec_cpsr_mode_mon_iss_i;
    exp_cpsr_mode_de[`CA53_ONEHOT_MODE_HYP_BIT]     = spec_cpsr_mode_hyp_iss_i;
    exp_cpsr_mode_de[`CA53_ONEHOT_MODE_ELXT_BIT]    = (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_EL0T) |
                                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_EL1T) |
                                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_EL2T) |
                                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_EL3T);
    exp_cpsr_mode_de[`CA53_ONEHOT_MODE_EL1H_BIT]    = (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_EL1H);
    exp_cpsr_mode_de[`CA53_ONEHOT_MODE_EL2H_BIT]    = (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_EL2H);
    exp_cpsr_mode_de[`CA53_ONEHOT_MODE_EL3H_BIT]    = (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_EL3H);
  end

  // SRS should not load banked regs in User Mode
  assign mode_for_srs_de = srs_mode_ctl_de ? postfix_srs_mode_de : spec_cpsr_mode_iss_i;

  // A force operation should use the mode set by the forceop decoder
  assign rf_wr_mode_de = mode_for_srs_de;

  // ------------------------------------------------------
  // Register expansion
  // ------------------------------------------------------

  // Convert timing critical register file read port addresses into one-hot form
  ca53dpu_de_regexpand u_regexpand_r0 (
    .rf_rd_addr_de_i      (rf_rd_addr_r0_de[5:0]),
    .long_rf_rd_addr_de_o (long_rf_rd_addr_r0_de_o[`CA53_LONG_RF_ADDR_W-1:0])
  );

  ca53dpu_de_regexpand u_regexpand_r1 (
    .rf_rd_addr_de_i      (rf_rd_addr_r1_de[5:0]),
    .long_rf_rd_addr_de_o (long_rf_rd_addr_r1_de_o[`CA53_LONG_RF_ADDR_W-1:0])
  );

  assign rf_rd_addr_r0_de_o = rf_rd_addr_r0_de;
  assign rf_rd_addr_r1_de_o = rf_rd_addr_r1_de;

  // ------------------------------------------------------
  // PC Logic
  // ------------------------------------------------------

  ca53dpu_de_pc `CA53_DPU_PARAM_INST u_dpu_de_pc (
    // Inputs
    .clk                        (clk),
    .reset_n                    (reset_n),
    .valid_instrs_iss_i         (valid_instrs_iss_i[1:0]),
    .end_instr_iss_i            (end_instr_iss_i),
    .size_instr0_iss_i          (size_instr0_iss_i),
    .size_instr1_iss_i          (size_instr1_iss_i),
    .size_instr1_ret_i          (size_instr1_ret_i),
    .aarch64_state_i            (aarch64_state_i),
    .dpu_exception_level_i      (dpu_exception_level_i[1:0]),
    .isa_instr0_iss_i           (isa_instr0_iss_i[1:0]),
    .instr0_de_pc_in_iss_i      (instr0_de_pc_in_iss_i),
    .prefetch_abort_iss_i       (prefetch_abort_iss_i),
    .slot1_branch_iss_i         (slot1_branch_iss_i),
    .rtn_addr_iss_i             (rtn_addr_iss_i[48:1]),
    .br_offset_iss_i            (br_offset_iss_i[27:1]),
    .taken_br_instr_iss_i       (taken_br_instr_iss_i),
    .br_x_bit_iss_i             (br_x_bit_iss_i),
    .btac_rtn_instr_iss_i       (btac_rtn_instr_iss_i),
    .tbit_btac_rtn_instr_iss_i  (tbit_btac_rtn_instr_iss_i),
    .in_halt_i                  (in_halt_i),
    .pc_instr0_iss_i            (pc_instr0_iss_i[63:0]),
    .pc_instr0_wr_i             (pc_instr0_wr_i[48:1]),
    .pc_instr0_ret_i            (pc_instr0_ret_i[63:0]),
    .thumb_instr0_iss_i         (thumb_instr0_iss_i),
    .thumb_instr0_ret_i         (thumb_instr0_ret_i),
    .thumb_instr1_ret_i         (thumb_instr1_ret_i),
    .tlb_d_tcr_el1_tbi_i        (tlb_d_tcr_el1_tbi_i[1:0]),
    .tlb_d_tcr_el2_tbi0_i       (tlb_d_tcr_el2_tbi0_i),
    .tlb_d_tcr_el3_tbi0_i       (tlb_d_tcr_el3_tbi0_i),
    .dpu_fe_addr_opa_wr_i       (dpu_fe_addr_opa_wr_i[48:1]),
    .dpu_fe_addr_opb_wr_i       (dpu_fe_addr_opb_wr_i[27:1]),
    .dpu_fe_valid_wr_i          (dpu_fe_valid_wr_i),
    .cpsr_tbit_wr_i             (cpsr_tbit_wr_i),
    .dpu_fe_addr_opa_ret_i      (dpu_fe_addr_opa_ret_i[63:0]),
    .dpu_fe_addr_opb_ret_i      (dpu_fe_addr_opb_ret_i[17:1]),
    .dpu_fe_valid_ret_i         (dpu_fe_valid_ret_i),
    .cpsr_tbit_ret_i            (cpsr_tbit_ret_i),
    .expt_slot1_ret_i           (expt_slot1_ret_i),
    .insert_forceop_ret_i       (insert_forceop_ret_i),
    .forceop_valid_de_i         (forceop_valid_de_i),
    .forceop_valid_iss_i        (forceop_valid_iss_i),
    .incr_pc_halt_mode_ret_i    (incr_pc_halt_mode_ret_i),
    .dbg_halt_ecc_expt_iss_i    (dbg_halt_ecc_expt_iss_i),
    .dpu_halt_ifu_i             (dpu_halt_ifu_i),
    // Outputs
    .pc_instr0_de_o             (pc_instr0_de_o[63:0]),
    .mod_pc_top_bits_de_o       (mod_pc_top_bits_de_o),
    .thumb_instr0_de_o          (thumb_instr0_de_o)
  );

  // ------------------------------------------------------
  // Instruction Queue
  // ------------------------------------------------------

  // Determine if the PC for the instructions in iss is in the same page
  // as the decode-stage instructions
  assign iss_pc_in_same_page = ~({2{(pc_instr0_iss_i[11:3] == {9{1'b1}}) | second_x64_iss_i}} & {~pc_instr0_iss_i[2], 1'b1});

  ca53dpu_iq `CA53_DPU_PARAM_INST u_iq (
    // Inputs
    .clk                                  (clk),
    .reset_n                              (reset_n),
    .DFTSE                                (DFTSE),
    .ifu_instr0_if3_i                     (ifu_instr0_if3_i[47:0]),
    .ifu_instr1_if3_i                     (ifu_instr1_if3_i[47:0]),
    .ifu_instr_valid_if3_i                (ifu_instr_valid_if3_i[1:0]),
    .ifu_early_two_valid_if3_i            (ifu_early_two_valid_if3_i),
    .paq_full_i                           (paq_full_i),
    .aarch64_state_i                      (aarch64_state_i),
    .stall_de_i                           (stall_de_i),
    .flush_wr_i                           (flush_wr_i),
    .finish_instr_de_i                    (finish_instr_de),
    .disable_dual_issue_i                 (disable_dual_issue),
    .disable_fp_dual_issue_i              (disable_fp_dual_issue_i),
    .cp_trap_fp_i                         (cp_trap_fp_i),
    .cp_trap_neon_i                       (cp_trap_neon_i),
    .rf_wr_en_w0_iss_i                    (rf_wr_en_w0_iss_i),
    .rf_wr_en_w1_iss_i                    (rf_wr_en_w1_iss_i),
    .rf_wr_en_w2_iss_i                    (rf_wr_en_w2_iss_i),
    .rf_wr_when_w0_iss_i                  (rf_wr_when_w0_iss_i),
    .rf_wr_when_w1_iss_i                  (rf_wr_when_w1_iss_i),
    .rf_wr_when_w2_iss_i                  (rf_wr_when_w2_iss_i),
    .rf_wr_vaddr_w0_iss_i                 (rf_wr_vaddr_w0_iss_i[4:0]),
    .rf_wr_vaddr_w1_iss_i                 (rf_wr_vaddr_w1_iss_i[4:0]),
    .rf_wr_vaddr_w2_iss_i                 (rf_wr_vaddr_w2_iss_i[4:0]),
    .rf_wr_en_w0_ex1_i                    (rf_wr_en_w0_ex1_i),
    .rf_wr_en_w1_ex1_i                    (rf_wr_en_w1_ex1_i),
    .rf_wr_en_w2_ex1_i                    (rf_wr_en_w2_ex1_i),
    .rf_wr_when_w0_ex1_i                  (rf_wr_when_w0_ex1_i),
    .rf_wr_when_w1_ex1_i                  (rf_wr_when_w1_ex1_i),
    .rf_wr_when_w2_ex1_i                  (rf_wr_when_w2_ex1_i),
    .rf_wr_vaddr_w0_ex1_i                 (rf_wr_vaddr_w0_ex1_i[4:0]),
    .rf_wr_vaddr_w1_ex1_i                 (rf_wr_vaddr_w1_ex1_i[4:0]),
    .rf_wr_vaddr_w2_ex1_i                 (rf_wr_vaddr_w2_ex1_i[4:0]),
    .rf_wr_en_fw0_iss_i                   (rf_wr_en_fw0_iss_i),
    .rf_wr_en_fw1_iss_i                   (rf_wr_en_fw1_iss_i),
    .rf_wr_en_fw0_f1_i                    (rf_wr_en_fw0_f1_i),
    .rf_wr_en_fw1_f1_i                    (rf_wr_en_fw1_f1_i),
    .rf_wr_en_fw0_f2_i                    (rf_wr_en_fw0_f2_i),
    .rf_wr_en_fw1_f2_i                    (rf_wr_en_fw1_f2_i),
    .rf_wr_when_fw0_iss_i                 (rf_wr_when_fw0_iss_i),
    .rf_wr_when_fw1_iss_i                 (rf_wr_when_fw1_iss_i),
    .rf_wr_when_fw0_f1_i                  (rf_wr_when_fw0_f1_i),
    .rf_wr_when_fw1_f1_i                  (rf_wr_when_fw1_f1_i),
    .rf_wr_when_fw0_f2_i                  (rf_wr_when_fw0_f2_i),
    .rf_wr_when_fw1_f2_i                  (rf_wr_when_fw1_f2_i),
    .rf_wr_addr_fw0_iss_i                 (rf_wr_addr_fw0_iss_i),
    .rf_wr_addr_fw1_iss_i                 (rf_wr_addr_fw1_iss_i),
    .rf_wr_addr_fw0_f1_i                  (rf_wr_addr_fw0_f1_i),
    .rf_wr_addr_fw1_f1_i                  (rf_wr_addr_fw1_f1_i),
    .rf_wr_addr_fw0_f2_i                  (rf_wr_addr_fw0_f2_i),
    .rf_wr_addr_fw1_f2_i                  (rf_wr_addr_fw1_f2_i),
    .adrp_valid_iss_i                     (adrp_valid_iss_i[1:0]),
    .taken_br_instr_iss_i                 (taken_br_instr_iss_i),
    .iss_pc_in_same_page_i                (iss_pc_in_same_page[1:0]),
    // Outputs                           
    .dpu_iq_full_o                        (dpu_iq_full_o),
    .dpu_iq_part_full_o                   (dpu_iq_part_full_o),
    .aarch64_state_ext_o                  (aarch64_state_ext_o),
    .iq_instr0_sideband_o                 (iq_instr0_sideband),
    .iq_instr0_common_o                   (iq_instr0_common[32:0]),
    .iq_instr0_common_aarch64_o           (iq_instr0_common_aarch64),
    .iq_instr0_dp_o                       (iq_instr0_dp[32:0]),
    .iq_instr0_dp_pdtype_o                (iq_instr0_dp_pdtype[1:0]),
    .iq_instr0_ls_o                       (iq_instr0_ls[32:0]),
    .iq_instr0_ls_br_taken_o              (iq_instr0_ls_br_taken),
    .iq_instr0_ls_pdtype_o                (iq_instr0_ls_pdtype),
    .iq_instr0_other_o                    (iq_instr0_other[32:0]),
    .iq_instr0_other_pdtype_o             (iq_instr0_other_pdtype[1:0]),
    .iq_instr0_other_br_taken_o           (iq_instr0_other_br_taken),
    .iq_instr0_common_br_taken_o          (iq_instr0_common_br_taken),
    .iq_instr0_fn_o                       (iq_instr0_fn[32:0]),
    .iq_instr0_fn_pdtype_o                (iq_instr0_fn_pdtype[1:0]),
    .iq_instr0_dp_aarch64_o               (iq_instr0_dp_aarch64),
    .iq_instr0_ls_aarch64_o               (iq_instr0_ls_aarch64),
    .iq_instr0_other_aarch64_o            (iq_instr0_other_aarch64),
    .iq_instr0_fn_aarch64_o               (iq_instr0_fn_aarch64),
    .iq_instr0_en_other_o                 (iq_instr0_en_other),
    .iq_instr0_is_dp_o                    (iq_instr0_is_dp),
    .iq_instr0_is_ls_o                    (iq_instr0_is_ls),
    .iq_instr0_is_other_o                 (iq_instr0_is_other),
    .iq_instr0_is_fn_o                    (iq_instr0_is_fn),
    .iq_instr0_val_o                      (iq_instr0_val),
    .iq_instr0_pdtype_o                   (iq_instr0_pdtype[1:0]),
    .iq_instr1_sideband_o                 (iq_instr1_sideband[5:0]),
    .iq_instr1_common_o                   (iq_instr1_common[32:0]),
    .iq_instr1_common_aarch64_o           (iq_instr1_common_aarch64),
    .iq_instr1_main_o                     (iq_instr1_main[32:0]),
    .iq_instr1_br_taken_o                 (iq_instr1_br_taken),
    .iq_instr1_main_aarch64_o             (iq_instr1_main_aarch64),
    .iq_instr1_ls_o                       (iq_instr1_ls[32:0]),
    .iq_instr1_ls_aarch64_o               (iq_instr1_ls_aarch64),
    .iq_instr1_fn_o                       (iq_instr1_fn[32:0]),
    .iq_instr1_fn_aarch64_o               (iq_instr1_fn_aarch64),
    .iq_instr1_pdtype_o                   (iq_instr1_pdtype[1:0]),
    .iq_instr1_is_dp_o                    (iq_instr1_is_dp),
    .iq_instr1_is_ls_o                    (iq_instr1_is_ls),
    .iq_instr1_is_other_o                 (iq_instr1_is_other),
    .iq_instr1_is_fn_o                    (iq_instr1_is_fn),
    .iq_instr1_is_dec1_o                  (iq_instr1_is_dec1),
    .iq_instr1_val_o                      (iq_instr1_val),
    .iq_instr1_dih_o                      (iq_instr1_dih),
    .iq_instr1_d1_o                       (iq_instr1_d1),
    .iq_instr0_d0_o                       (iq_instr0_d0),
    .iq_instr1_is_aesimc_aesmc_o          (iq_instr1_is_aesimc_aesmc),
    .iq_skew_instr0_o                     (iq_skew_instr0_de),
    .iq_skew_instr0_r0_o                  (iq_skew_instr0_r0_de),
    .iq_skew_instr0_r1_o                  (iq_skew_instr0_r1_de),
    .iq_skew_instr1_o                     (iq_skew_instr1_de),
    .iq_skew_instr1_r0_o                  (iq_skew_instr1_r0_de),
    .iq_skew_instr1_r1_o                  (iq_skew_instr1_r1_de),
    .iq_instr0_d0_uses_dcu_o              (iq_instr0_d0_uses_dcu),
    .iq_instr0_r2_enabled_o               (iq_instr0_r2_enabled),
    .iq_instr0_w0_enabled_o               (iq_instr0_w0_enabled),
    .iq_instr1_br_valid_o                 (iq_instr1_br_valid),
    .iq_instr1_datapath_resource_hazard_o (iq_instr1_datapath_resource_hazard),
    .iq_instr1_fn_dcu_valid_o             (iq_instr1_fn_dcu_valid),
    .iq_instr0_sets_ccflags_o             (iq_instr0_sets_ccflags),
    .iq_instr0_adrp_fwd_o                 (iq_instr0_adrp_fwd),
    .iq_instr0_adrp_fwd_src_o             (iq_instr0_adrp_fwd_src[2:1]),
    .iq_instr1_adrp_fwd_o                 (iq_instr1_adrp_fwd),
    .iq_instr1_adrp_fwd_src_o             (iq_instr1_adrp_fwd_src[2:0]),
    .iq_neon_present_o                    (iq_neon_present),
    .evnt_iq_empty_o                      (evnt_iq_empty_o)
  );

  // Skew signals from IQ are only valid when instruction is dual-issuable
  assign skew_instr0_de     = iq_skew_instr0_de    & iq_instr0_d0;
  assign skew_instr0_r0_de  = iq_skew_instr0_r0_de & iq_instr0_d0;
  assign skew_instr0_r1_de  = iq_skew_instr0_r1_de & iq_instr0_d0;

  assign skew_instr1_de     = iq_skew_instr1_de    & iq_instr1_d1;
  assign skew_instr1_r0_de  = iq_skew_instr1_r0_de & iq_instr1_d1;
  assign skew_instr1_r1_de  = iq_skew_instr1_r1_de & iq_instr1_d1;

  // ------------------------------------------------------
  // Exception decoder opcode selection
  // ------------------------------------------------------

  // Select and pack information for Iss stage exception decoder
  always @* begin
    expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_MISC_BIT]     = 1'b0; // Misc info about instruction - flop shared between LS and
                                                                    // Other instructions but has different meanining on each
    expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_IS_OTHER_BIT] = 1'b0;
    expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_IS_LS_BIT]    = 1'b0;
    expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_INSTR_D_BIT]  = 1'b0;
    expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_INSTR_BITS]   = {28{1'b0}};

    case (decoder_select0)
      7'b0000000: begin
        // Use default
      end
      7'b0000001: begin  // DP
        // Use default
      end
      7'b0000010: begin  // LS
        expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_MISC_BIT]     = ls_cp14_ldc_literal;
        expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_IS_LS_BIT]    = 1'b1;
        expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_INSTR_D_BIT]  = iq_instr0_ls[29];
        expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_INSTR_BITS]   = iq_instr0_ls[27:0];
      end
      7'b0000100: begin  // OT
        expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_MISC_BIT]     = mcr_mrc_valid_de;
        expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_IS_OTHER_BIT] = 1'b1;
        expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_INSTR_D_BIT]  = iq_instr0_other[29];
        expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_INSTR_BITS]   = iq_instr0_other[27:0];
      end
      7'b0001000: begin  // Force
        // Use default
      end
      7'b0010000: begin  // Undef
        // Use default
      end
      7'b0100000: begin  // Neon
        expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_INSTR_D_BIT]  = iq_instr0_fn[29];
        expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_INSTR_BITS]   = iq_instr0_fn[27:0];
      end
      7'b1000000: begin // Branch
        // Use default
      end
      default: begin
        expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_MISC_BIT]     = 1'bx;
        expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_IS_OTHER_BIT] = 1'bx;
        expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_IS_LS_BIT]    = 1'bx;
        expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_INSTR_D_BIT]  = 1'bx;
        expt_instr_data_de_o[`CA53_EXPT_INSTR_BUS_INSTR_BITS]   = {28{1'bx}};
      end
    endcase
  end

  // ------------------------------------------------------
  // Issue-stage decoding of Neon control signals
  // ------------------------------------------------------

  // FP pipe 0
  always @* begin
    fp0_pipectl_iss_o            = {`CA53_FP_PIPECTL_W{1'b0}};
    sel_fml0_a_iss_o             = {`CA53_SEL_FML_A_W{1'b0}};
    sel_fml0_b_iss_o             = {`CA53_SEL_FML_B_W{1'b0}};
    sel_fml0_c_iss_o             = {`CA53_SEL_FML_C_W{1'b0}};
    sel_fad0_a_iss_o             = {`CA53_SEL_FAD_A_W{1'b0}};
    sel_fad0_b_iss_o             = {`CA53_SEL_FAD_B_W{1'b0}};
    sel_fad0_c_iss_o             = {`CA53_SEL_FAD_C_W{1'b0}};
    fp0_cflag_src_iss_o          = {`CA53_FP_CFLAG_SRC_W{1'b0}};
    fp0_xflag_src_iss_o          = {`CA53_FP_XFLAG_SRC_W{1'b0}};

    case (decoder_select0_ne_iss)
      1'b0 : begin // Use defaults
      end
      1'b1 : begin // Neon decoder
        fp0_pipectl_iss_o        = fp_pipectl_neon[(`CA53_FP_PIPECTL_W-1):0];
        sel_fml0_a_iss_o         = sel_fml_a_neon;
        sel_fml0_b_iss_o         = sel_fml_b_neon[(`CA53_SEL_FML_B_W-1):0];
        sel_fml0_c_iss_o         = sel_fml_c_neon;
        sel_fad0_a_iss_o         = sel_fad_a_neon[(`CA53_SEL_FAD_A_W-1):0];
        sel_fad0_b_iss_o         = sel_fad_b_neon[(`CA53_SEL_FAD_B_W-1):0];
        sel_fad0_c_iss_o         = sel_fad_c_neon[(`CA53_SEL_FAD_C_W-1):0];
        fp0_cflag_src_iss_o      = fp_cflag_src_neon[(`CA53_FP_CFLAG_SRC_W-1):0];
        fp0_xflag_src_iss_o      = fp_xflag_src_neon[(`CA53_FP_XFLAG_SRC_W-1):0];
      end
      default : begin
        fp0_pipectl_iss_o        = {`CA53_FP_PIPECTL_W{1'bx}};
        sel_fml0_a_iss_o         = {`CA53_SEL_FML_A_W{1'bx}};
        sel_fml0_b_iss_o         = {`CA53_SEL_FML_B_W{1'bx}};
        sel_fml0_c_iss_o         = {`CA53_SEL_FML_C_W{1'bx}};
        sel_fad0_a_iss_o         = {`CA53_SEL_FAD_A_W{1'bx}};
        sel_fad0_b_iss_o         = {`CA53_SEL_FAD_B_W{1'bx}};
        sel_fad0_c_iss_o         = {`CA53_SEL_FAD_C_W{1'bx}};
        fp0_cflag_src_iss_o      = {`CA53_FP_CFLAG_SRC_W{1'bx}};
        fp0_xflag_src_iss_o      = {`CA53_FP_XFLAG_SRC_W{1'bx}};
      end
    endcase
  end

  // FP pipe 1
  always @* begin
    fp1_pipectl_iss_o            = {`CA53_FP_PIPECTL_W{1'b0}};
    sel_fml1_a_iss_o             = {`CA53_SEL_FML_A_W{1'b0}};
    sel_fml1_b_iss_o             = {`CA53_SEL_FML_B_W{1'b0}};
    sel_fml1_c_iss_o             = {`CA53_SEL_FML_C_W{1'b0}};
    sel_fad1_a_iss_o             = {`CA53_SEL_FAD_A_W{1'b0}};
    sel_fad1_b_iss_o             = {`CA53_SEL_FAD_B_W{1'b0}};
    sel_fad1_c_iss_o             = {`CA53_SEL_FAD_C_W{1'b0}};
    fp1_cflag_src_iss_o          = {`CA53_FP_CFLAG_SRC_W{1'b0}};
    fp1_xflag_src_iss_o          = {`CA53_FP_XFLAG_SRC_W{1'b0}};

    case ({decoder_select1_ne_iss,
           dec0_neon_uses_pipe1_iss})
      2'b00 : begin // Use defaults
      end
      2'b01, 2'b11 : begin // Slot 0 Neon decoder
        fp1_pipectl_iss_o        = fp_pipectl_neon[`CA53_FP_PIPECTL_W-1:0];
        sel_fml1_a_iss_o         = sel_fml_a_neon;
        sel_fml1_b_iss_o         = sel_fml_b_neon[`CA53_SEL_FML_B_W-1:0];
        sel_fml1_c_iss_o         = sel_fml_c_neon;
        sel_fad1_a_iss_o         = sel_fad_a_neon[`CA53_SEL_FAD_A_W-1:0];
        sel_fad1_b_iss_o         = sel_fad_b_neon[`CA53_SEL_FAD_B_W-1:0];
        sel_fad1_c_iss_o         = sel_fad_c_neon[`CA53_SEL_FAD_C_W-1:0];
        fp1_xflag_src_iss_o      = fp_xflag_src_neon[`CA53_FP_XFLAG_SRC_W-1:0];
      end
      2'b10 : begin // Slot 1 Neon decoder
        fp1_pipectl_iss_o        = fp_pipectl_dec1_ne[`CA53_FP_PIPECTL_W-1:0];
        sel_fml1_a_iss_o         = sel_fml_a_dec1_ne;
        sel_fml1_b_iss_o         = sel_fml_b_dec1_ne[`CA53_SEL_FML_B_W-1:0];
        sel_fml1_c_iss_o         = sel_fml_c_dec1_ne;
        sel_fad1_a_iss_o         = sel_fad_a_dec1_ne[`CA53_SEL_FAD_A_W-1:0];
        sel_fad1_b_iss_o         = sel_fad_b_dec1_ne[`CA53_SEL_FAD_B_W-1:0];
        sel_fad1_c_iss_o         = sel_fad_c_dec1_ne[`CA53_SEL_FAD_C_W-1:0];
        fp1_cflag_src_iss_o      = fp_cflag_src_dec1_ne[`CA53_FP_CFLAG_SRC_W-1:0];
        fp1_xflag_src_iss_o      = fp_xflag_src_dec1_ne[`CA53_FP_XFLAG_SRC_W-1:0];
      end
      default : begin
        fp1_pipectl_iss_o        = {`CA53_FP_PIPECTL_W{1'bx}};
        sel_fml1_a_iss_o         = {`CA53_SEL_FML_A_W{1'bx}};
        sel_fml1_b_iss_o         = {`CA53_SEL_FML_B_W{1'bx}};
        sel_fml1_c_iss_o         = {`CA53_SEL_FML_C_W{1'bx}};
        sel_fad1_a_iss_o         = {`CA53_SEL_FAD_A_W{1'bx}};
        sel_fad1_b_iss_o         = {`CA53_SEL_FAD_B_W{1'bx}};
        sel_fad1_c_iss_o         = {`CA53_SEL_FAD_C_W{1'bx}};
        fp1_cflag_src_iss_o      = {`CA53_FP_CFLAG_SRC_W{1'bx}};
        fp1_xflag_src_iss_o      = {`CA53_FP_XFLAG_SRC_W{1'bx}};
      end
    endcase
  end

  // ------------------------------------------------------
  // Generate neon_de_active
  // ------------------------------------------------------

  assign neon_de_active_o = decoder_select0[NE] | decoder_select1[DEC1_NE] | iq_neon_present;

  // ------------------------------------------------------
  // Output aliases
  // ------------------------------------------------------

  assign rf_wr_mode_de_o          = rf_wr_mode_de;
  assign valid_instrs_de_o        = valid_instrs_de;
  assign size_instr0_de_o         = (iq_instr0_pdtype != 2'b11);
  assign size_instr1_de_o         = (iq_instr1_pdtype[1:0] != 2'b11) & iq_instr1_val;
  assign thumb_instr1_de_o        = iq_instr1_pdtype[1];
  assign ls_instr_type_de_o       = ls_instr_type_de;
  assign ls_multiple_de_o         = (ls_instr_type_de == `CA53_LS_INSTR_MULTIPLE);
  assign expt_instr_type_de_o     = expt_instr_type_de[`CA53_EXPT_INSTR_TYPE_W-1:0];
  assign instr_is_cp10_cp11_de_o  = decoder_select0[NE] | decoder_select1[DEC1_NE];
  assign slot1_ls_de_o            = valid_instrs_de[1] & (iq_instr1_is_ls | iq_instr1_fn_dcu_valid);
  assign use_ex1_alu_0_de_o       = skew_instr0_de | use_ex1_alu_0_static_de;
  assign use_ex1_alu_1_de_o       = skew_instr1_de | use_ex1_alu_1_static_de;
  assign iq_instr_is_fn_o         = {(iq_instr1_val & iq_instr1_is_fn), iq_instr0_is_fn};
  assign neon_instr_iss_o         = {decoder_select1_ne_iss, decoder_select0_ne_iss};

  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

  `ifdef ARM_ASSERT_ON

  wire r0_0_is_zr;
  wire r1_0_is_zr;
  wire r2_0_is_zr;
  wire r3_0_is_zr;
  wire r0_1_is_zr;
  wire r1_1_is_zr;
  wire r2_1_is_zr;
  wire r0_is_zr;
  wire r1_is_zr;
  wire r2_is_zr;
  wire r3_is_zr;
  wire r4_is_zr;
  wire w0_is_zr;
  wire w1_is_zr;
  wire w2_is_zr;

  wire r2_belongs_to_ls1  = decoder_select1[DEC1_LS] & ~instr0_r2_enabled;
  wire r2_belongs_to_dec1 = decoder_select1[DEC1]    & ~instr0_r2_enabled;

generate if (NEON_FP) begin : NEON3
  assign r0_0_is_zr = decoder_select0[DP] ? u_dec0_dp.rf_rd_ctl_r0_dp[`CA53_RD_CTL_ZR]              :
                      decoder_select0[LS] ? u_dec0_ls.rf_rd_ctl_r0_ls[`CA53_RD_CTL_ZR]              :
                      decoder_select0[OT] ? u_dec0_other.rf_rd_ctl_r0_other[`CA53_RD_CTL_ZR]        :
                      decoder_select0[BR] ? u_dec0_br.rf_rd_ctl_r0_dec0_br[`CA53_RD_CTL_ZR]         :
                      decoder_select0[NE] ? NEON1.u_dec0_neon.rf_rd_ctl_r0_neon[`CA53_RD_CTL_ZR]    :
                                            1'b0;

  assign r1_0_is_zr = decoder_select0[DP] ? u_dec0_dp.rf_rd_ctl_r1_dp[`CA53_RD_CTL_ZR]              :
                      decoder_select0[LS] ? u_dec0_ls.rf_rd_ctl_r1_ls[`CA53_RD_CTL_ZR]              :
                      decoder_select0[OT] ? u_dec0_other.rf_rd_ctl_r1_other[`CA53_RD_CTL_ZR]        :
                      decoder_select0[BR] ? u_dec0_br.rf_rd_ctl_r1_dec0_br[`CA53_RD_CTL_ZR]         :
                      decoder_select0[NE] ? NEON1.u_dec0_neon.rf_rd_ctl_r1_neon[`CA53_RD_CTL_ZR]    :
                                            1'b0;

  assign r2_0_is_zr = decoder_select0[DP] ? u_dec0_dp.rf_rd_ctl_r2_dp[`CA53_RD_CTL_ZR]            :
                      decoder_select0[LS] ? u_dec0_ls.rf_rd_ctl_r2_ls[`CA53_RD_CTL_ZR]            :
                      decoder_select0[OT] ? u_dec0_other.rf_rd_ctl_r2_other[`CA53_RD_CTL_ZR]      :
                      decoder_select0[NE] ? NEON1.u_dec0_neon.rf_rd_ctl_r2_neon[`CA53_RD_CTL_ZR]  :
                                            1'b0;

  assign r3_0_is_zr = decoder_select0[DP] ? u_dec0_dp.rf_rd_ctl_r3_dp[`CA53_RD_CTL_ZR]            :
                      decoder_select0[LS] ? u_dec0_ls.rf_rd_ctl_r3_ls[`CA53_RD_CTL_ZR]            :
                      decoder_select0[OT] ? u_dec0_other.rf_rd_ctl_r3_other[`CA53_RD_CTL_ZR]      :
                      decoder_select0[NE] ? NEON1.u_dec0_neon.rf_rd_ctl_r3_neon[`CA53_RD_CTL_ZR]  :
                                            1'b0;


  assign r0_1_is_zr = decoder_select1[DEC1_NE] ? NEON2.u_dec1_neon.rf_rd_ctl_r0_dec1_ne[`CA53_RD_CTL_ZR]  :
                      decoder_select1[DEC1_LS] ? u_dec1_ls.rf_rd_ctl_r0_dec1_ls[`CA53_RD_CTL_ZR]          :
                      decoder_select1[DEC1_BR] ? u_dec1_br.rf_rd_ctl_r0_dec1_br[`CA53_RD_CTL_ZR]          :
                      decoder_select1[DEC1]    ? u_dec1.rf_rd_ctl_r0_dec1[`CA53_RD_CTL_ZR]                :
                                                 1'b0;

  assign r1_1_is_zr = decoder_select1[DEC1_NE] ? NEON2.u_dec1_neon.rf_rd_ctl_r1_dec1_ne[`CA53_RD_CTL_ZR]  :
                      decoder_select1[DEC1_LS] ? u_dec1_ls.rf_rd_ctl_r1_dec1_ls[`CA53_RD_CTL_ZR]          :
                      decoder_select1[DEC1_BR] ? u_dec1_br.rf_rd_ctl_r1_dec1_br[`CA53_RD_CTL_ZR]          :
                      decoder_select1[DEC1]    ? u_dec1.rf_rd_ctl_r1_dec1[`CA53_RD_CTL_ZR]                :
                                                 1'b0;

  assign r2_1_is_zr = decoder_select1[DEC1_NE] ? NEON2.u_dec1_neon.rf_rd_ctl_r2_dec1_ne[`CA53_RD_CTL_ZR]  :
                      decoder_select1[DEC1_LS] ? u_dec1_ls.rf_rd_ctl_r2_dec1_ls[`CA53_RD_CTL_ZR]          :
                      decoder_select1[DEC1]    ? u_dec1.rf_rd_ctl_r2_dec1[`CA53_RD_CTL_ZR]                :
                                                 1'b0;

  assign r0_is_zr = rf_rd_remap_de ? r0_1_is_zr : r0_0_is_zr;
  assign r1_is_zr = rf_rd_remap_de ? r1_1_is_zr : r1_0_is_zr;
  assign r2_is_zr = instr0_r2_enabled ? r2_0_is_zr : r2_1_is_zr;
  assign r3_is_zr = instr0_r3_enabled ? r3_0_is_zr :
                    rf_rd_remap_de    ? r0_0_is_zr :
                                        r0_1_is_zr;
  assign r4_is_zr = rf_rd_remap_de ? r1_0_is_zr : r1_1_is_zr;


  assign w0_is_zr = decoder_select1[DEC1_LS] ? u_dec1_ls.rf_wr_ctl_w0_dec1_ls[`CA53_WR_CTL_ZR]      :
                    decoder_select0[DP]      ? u_dec0_dp.rf_wr_ctl_w0_dp[`CA53_WR_CTL_ZR]           :
                    decoder_select0[LS]      ? u_dec0_ls.rf_wr_ctl_w0_ls[`CA53_WR_CTL_ZR]           :
                    decoder_select0[OT]      ? u_dec0_other.rf_wr_ctl_w0_other[`CA53_WR_CTL_ZR]     :
                    decoder_select0[NE]      ? NEON1.u_dec0_neon.rf_wr_ctl_w0_neon[`CA53_WR_CTL_ZR] :
                                               1'b0;

  assign w1_is_zr = decoder_select0[DP] ? u_dec0_dp.rf_wr_ctl_w1_dp[`CA53_WR_CTL_ZR]           :
                    decoder_select0[LS] ? u_dec0_ls.rf_wr_ctl_w1_ls[`CA53_WR_CTL_ZR]           :
                    decoder_select0[OT] ? u_dec0_other.rf_wr_ctl_w1_other[`CA53_WR_CTL_ZR]     :
                    decoder_select0[BR] ? u_dec0_br.rf_wr_ctl_w1_dec0_br[`CA53_WR_CTL_ZR]     :
                    decoder_select0[NE] ? NEON1.u_dec0_neon.rf_wr_ctl_w1_neon[`CA53_WR_CTL_ZR] :
                                          1'b0;

  assign w2_is_zr = decoder_select1[DEC1]    ? u_dec1.rf_wr_ctl_w1_dec1[`CA53_WR_CTL_ZR]               :
                    decoder_select1[DEC1_LS] ? u_dec1_ls.rf_wr_ctl_w1_dec1_ls[`CA53_WR_CTL_ZR]         :
                    decoder_select1[DEC1_NE] ? NEON2.u_dec1_neon.rf_wr_ctl_w1_dec1_ne[`CA53_WR_CTL_ZR] :
                    decoder_select0[LS]      ? u_dec0_ls.rf_wr_ctl_w2_ls[`CA53_WR_CTL_ZR]              :
                                               1'b0;
end else begin : NEON3_STUBS
  assign r0_is_zr = decoder_select1[DEC1_LS] ? u_dec1_ls.rf_rd_ctl_r0_dec1_ls[`CA53_RD_CTL_ZR]         :
                    decoder_select0[DP]      ? u_dec0_dp.rf_rd_ctl_r0_dp[`CA53_RD_CTL_ZR]              :
                    decoder_select0[LS]      ? u_dec0_ls.rf_rd_ctl_r0_ls[`CA53_RD_CTL_ZR]              :
                    decoder_select0[BR]      ? u_dec0_br.rf_rd_ctl_r0_dec0_br[`CA53_RD_CTL_ZR]         :
                    decoder_select0[OT]      ? u_dec0_other.rf_rd_ctl_r0_other[`CA53_RD_CTL_ZR]        :
                                               1'b0;

  assign r1_is_zr = decoder_select1[DEC1_LS] ? u_dec1_ls.rf_rd_ctl_r1_dec1_ls[`CA53_RD_CTL_ZR]         :
                    decoder_select0[DP]      ? u_dec0_dp.rf_rd_ctl_r1_dp[`CA53_RD_CTL_ZR]              :
                    decoder_select0[LS]      ? u_dec0_ls.rf_rd_ctl_r1_ls[`CA53_RD_CTL_ZR]              :
                    decoder_select0[OT]      ? u_dec0_other.rf_rd_ctl_r1_other[`CA53_RD_CTL_ZR]        :
                    decoder_select0[BR]      ? u_dec0_br.rf_rd_ctl_r1_dec0_br[`CA53_RD_CTL_ZR]         :
                                               1'b0;

  assign r2_is_zr = r2_belongs_to_ls1     ? u_dec1_ls.rf_rd_ctl_r2_dec1_ls[`CA53_RD_CTL_ZR]       :
                    r2_belongs_to_dec1    ? u_dec1.rf_rd_ctl_r2_dec1[`CA53_RD_CTL_ZR]             :
                    decoder_select0[DP]   ? u_dec0_dp.rf_rd_ctl_r2_dp[`CA53_RD_CTL_ZR]            :
                    decoder_select0[LS]   ? u_dec0_ls.rf_rd_ctl_r2_ls[`CA53_RD_CTL_ZR]            :
                    decoder_select0[OT]   ? u_dec0_other.rf_rd_ctl_r2_other[`CA53_RD_CTL_ZR]      :
                                            1'b0;

  assign r3_is_zr =  decoder_select1[DEC1]                  ? u_dec1.rf_rd_ctl_r0_dec1[`CA53_RD_CTL_ZR]             :
                     decoder_select1[DEC1_BR]               ? u_dec1_br.rf_rd_ctl_r0_dec1_br[`CA53_RD_CTL_ZR]       :
                    (decoder_select0[DP] & ~rf_rd_remap_de) ? u_dec0_dp.rf_rd_ctl_r3_dp[`CA53_RD_CTL_ZR]            :
                    (decoder_select0[DP] &  rf_rd_remap_de) ? u_dec0_dp.rf_rd_ctl_r0_dp[`CA53_RD_CTL_ZR]            :
                    (decoder_select0[BR] &  rf_rd_remap_de) ? u_dec0_br.rf_rd_ctl_r0_dec0_br[`CA53_RD_CTL_ZR]       :
                     decoder_select0[LS]                    ? u_dec0_ls.rf_rd_ctl_r3_ls[`CA53_RD_CTL_ZR]            :
                     decoder_select0[OT]                    ? u_dec0_other.rf_rd_ctl_r3_other[`CA53_RD_CTL_ZR]      :
                                                              1'b0;

  assign r4_is_zr =  decoder_select1[DEC1]                  ? u_dec1.rf_rd_ctl_r1_dec1[`CA53_RD_CTL_ZR]             :
                     decoder_select1[DEC1_BR]               ? u_dec1_br.rf_rd_ctl_r1_dec1_br[`CA53_RD_CTL_ZR]       :
                    (decoder_select0[DP] &  rf_rd_remap_de) ? u_dec0_dp.rf_rd_ctl_r1_dp[`CA53_RD_CTL_ZR]            :
                    (decoder_select0[BR] &  rf_rd_remap_de) ? u_dec0_br.rf_rd_ctl_r1_dec0_br[`CA53_RD_CTL_ZR]       :
                                                              1'b0;


  assign w0_is_zr = decoder_select1[DEC1_LS] ? u_dec1_ls.rf_wr_ctl_w0_dec1_ls[`CA53_WR_CTL_ZR]   :
                    decoder_select0[DP]      ? u_dec0_dp.rf_wr_ctl_w0_dp[`CA53_WR_CTL_ZR]        :
                    decoder_select0[LS]      ? u_dec0_ls.rf_wr_ctl_w0_ls[`CA53_WR_CTL_ZR]        :
                    decoder_select0[OT]      ? u_dec0_other.rf_wr_ctl_w0_other[`CA53_WR_CTL_ZR]  :
                                               1'b0;

  assign w1_is_zr = decoder_select0[DP] ? u_dec0_dp.rf_wr_ctl_w1_dp[`CA53_WR_CTL_ZR]        :
                    decoder_select0[LS] ? u_dec0_ls.rf_wr_ctl_w1_ls[`CA53_WR_CTL_ZR]        :
                    decoder_select0[OT] ? u_dec0_other.rf_wr_ctl_w1_other[`CA53_WR_CTL_ZR]  :
                    decoder_select0[OT] ? u_dec0_br.rf_wr_ctl_w1_dec0_br[`CA53_WR_CTL_ZR]   :
                                          1'b0;

  assign w2_is_zr = decoder_select1[DEC1]    ? u_dec1.rf_wr_ctl_w1_dec1[`CA53_WR_CTL_ZR]   :
                    decoder_select1[DEC1_LS] ? u_dec1_ls.rf_wr_ctl_w1_dec1_ls[`CA53_WR_CTL_ZR]  :
                    decoder_select0[LS]      ? u_dec0_ls.rf_wr_ctl_w2_ls[`CA53_WR_CTL_ZR]  :
                                               1'b0;
end endgenerate

  wire [1:0] ovl_valid_instrs_de = valid_instrs_de & {2{~flush_wr_i}};

  //ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_decoder_fsm_dp")
  u_ovl_x_en_decoder_fsm_dp (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (en_decoder_fsm_dp));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_decoder_fsm_fn")
  u_ovl_x_en_decoder_fsm_fn (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (en_decoder_fsm_fn));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_decoder_fsm_ls")
  u_ovl_x_en_decoder_fsm_ls (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (en_decoder_fsm_ls));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_decoder_fsm_other")
  u_ovl_x_en_decoder_fsm_other (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (en_decoder_fsm_other));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_decoder_lsm")
  u_ovl_x_en_decoder_lsm (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (en_decoder_lsm));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_iss_fpu_i")
  u_ovl_x_issue_to_iss_fpu_i (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (issue_to_iss_fpu_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_iss_i")
  u_ovl_x_issue_to_iss_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (issue_to_iss_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ~stall_de_i | flush_wr_i")
  u_ovl_x_de_comb_en1 (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (~stall_de_i | flush_wr_i));

  // aarch64_state_i is used in an if statement in dec_forceop.v, but that
  // module does not have a clk input
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: aarch64_state_i")
  u_ovl_x_aarch64_state_i (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (aarch64_state_i));

  //----------------------------------------------------------------------------
  // Early version of instr1_reads_pc in DIH block must be accurate
  //----------------------------------------------------------------------------
  wire ovl_dec1_ls_reads_pc = (alu_data_a_sel_dec1_ls  == `CA53_SEL_SHF_A_PC) |
                              (alu_data_b_sel_dec1_ls  == `CA53_SEL_SHF_B_PC) |
                              (agu_data_a_sel_dec1_ls == `CA53_SEL_DCU_A_PC) |
                              (str_data_a_sel_dec1_ls == `CA53_SEL_STR_A_PC);

  wire ovl_dec1_ne_reads_pc = (alu_data_a_sel_dec1_ne  == `CA53_SEL_SHF_A_PC) |
                              (alu_data_b_sel_dec1_ne  == `CA53_SEL_SHF_B_PC) |
                              (agu_data_a_sel_dec1_ne == `CA53_SEL_DCU_A_PC);

  wire ovl_dec1_br_reads_pc = (alu_data_a_sel_dec1_br == `CA53_SEL_SHF_A_PC) |
                              (alu_data_b_sel_dec1_br == `CA53_SEL_SHF_B_PC);

  wire ovl_dec1_reads_pc    = (alu_data_a_sel_dec1    == `CA53_SEL_SHF_A_PC) |
                              (alu_data_b_sel_dec1    == `CA53_SEL_SHF_B_PC);

  wire ovl_instr1_reads_pc  = iq_instr1_is_fn ? ovl_dec1_ne_reads_pc :
                              iq_instr1_is_ls ? ovl_dec1_ls_reads_pc :
                              use_dec1_br     ? ovl_dec1_br_reads_pc :
                                                ovl_dec1_reads_pc;

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"DIH version of instr1_reads_pc must be accurate")
    ovl_i1_reads_pc     (.clk              (clk),
                         .reset_n          (reset_n),
                         .antecedent_expr  (ovl_valid_instrs_de[1]),
                         .consequent_expr  (ovl_instr1_reads_pc == u_iq.u_iq_dih.instr1_reads_pc));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // When skewing must have need of Ex1
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"When skewing should have need of Ex1 - R0")
    ovl_skew_need_ex1_r0(.clk              (clk),
                         .reset_n          (reset_n),
                         .antecedent_expr  (ovl_valid_instrs_de[0] & skew_r0_de & (expt_instr_type_de_o != `CA53_EXPT_INSTR_TYPE_UNDEF)),
                         .consequent_expr  (rf_rd_need_r0_preskew_de == `CA53_RF_RD_NEED_EX1));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"When skewing should have need of Ex1 - R1")
    ovl_skew_need_ex1_r1(.clk              (clk),
                         .reset_n          (reset_n),
                         .antecedent_expr  (ovl_valid_instrs_de[0] & skew_r1_de & (expt_instr_type_de_o != `CA53_EXPT_INSTR_TYPE_UNDEF)),
                         .consequent_expr  (rf_rd_need_r1_preskew_de == `CA53_RF_RD_NEED_EX1));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"When skewing should have need of Ex1 - R3")
    ovl_skew_need_ex1_r3(.clk              (clk),
                         .reset_n          (reset_n),
                         .antecedent_expr  (ovl_valid_instrs_de[0] & skew_r3_de & (expt_instr_type_de_o != `CA53_EXPT_INSTR_TYPE_UNDEF)),
                         .consequent_expr  (rf_rd_need_r3_preskew_de == `CA53_RF_RD_NEED_EX1));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"When skewing should have need of Ex1 - R4")
    ovl_skew_need_ex1_r4(.clk              (clk),
                         .reset_n          (reset_n),
                         .antecedent_expr  (ovl_valid_instrs_de[0] & skew_r4_de & (expt_instr_type_de_o != `CA53_EXPT_INSTR_TYPE_UNDEF)),
                         .consequent_expr  (rf_rd_need_r4_preskew_de == `CA53_RF_RD_NEED_EX1));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // When skewing must have when of Ex2
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"When skewing should have when of Ex2 - Instr0")
    ovl_skew_when_ex2_i0(.clk              (clk),
                         .reset_n          (reset_n),
                         .antecedent_expr  (ovl_valid_instrs_de[0] & skew_instr0_de & (expt_instr_type_de_o != `CA53_EXPT_INSTR_TYPE_UNDEF)),
                         .consequent_expr  ((decoder_select0[DP] & rf_wr_when_w1_dp_preskew   == `CA53_RF_WR_WHEN_EX2) |
                                            (decoder_select0[LS] & rf_wr_when_w1_ls_preskew   == `CA53_RF_WR_WHEN_EX2) |
                                            (decoder_select0[NE] & rf_wr_when_w1_neon_preskew == `CA53_RF_WR_WHEN_EX2)));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"When skewing should have when of Ex2 - Instr1")
    ovl_skew_when_ex2_i1(.clk              (clk),
                         .reset_n          (reset_n),
                         .antecedent_expr  (ovl_valid_instrs_de[1] & skew_instr1_de & (expt_instr_type_de_o != `CA53_EXPT_INSTR_TYPE_UNDEF)),
                         .consequent_expr  ((decoder_select1[DEC1]    & rf_wr_when_w1_dec1_preskew    == `CA53_RF_WR_WHEN_EX2) |
                                            (decoder_select1[DEC1_LS] & rf_wr_when_w1_dec1_ls_preskew == `CA53_RF_WR_WHEN_EX2) |
                                            (decoder_select1[DEC1_NE] & rf_wr_when_w1_dec1_ne_preskew == `CA53_RF_WR_WHEN_EX2)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // decoder_select0 must be one-hot
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Signal decoder_select0 must be one-hot")
    ovl_dec_sel_one_hot (.clk              (clk),
                         .reset_n          (reset_n),
                         .antecedent_expr  (ovl_valid_instrs_de[0]),
                         .consequent_expr  ((decoder_select0[6] +
                                             decoder_select0[5] +
                                             decoder_select0[4] +
                                             decoder_select0[3] +
                                             decoder_select0[2] +
                                             decoder_select0[1] +
                                             decoder_select0[0]) == 1));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // decoder_select1 must be zero/one-hot
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_zero_one_hot #(`OVL_FATAL,4,`OVL_ASSERT,"decoder_select1 must be zero one hot")
    ovl_dec1_sel_one_hot (.clk       (clk),
                          .reset_n   (reset_n),
                          .test_expr ({4{|ovl_valid_instrs_de}} & decoder_select1));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // If the instruction is undef then head must be set
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"head_instr_de should be set on undef")
    ovl_head_instr_de_ill (.clk              (clk),
                           .reset_n          (reset_n),
                           .antecedent_expr  (ovl_valid_instrs_de[0] & (expt_instr_type_de_o == `CA53_EXPT_INSTR_TYPE_UNDEF)),
                           .consequent_expr  (head_instr_de_o[0] == 1'b1));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // If the instruction is undef then end must be set
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"end_instr_de should be set on undef")
    ovl_end_instr_de_ill (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (ovl_valid_instrs_de[0] & (expt_instr_type_de_o == `CA53_EXPT_INSTR_TYPE_UNDEF)),
                          .consequent_expr  (end_instr_de_o));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // If the instruction is in the spreadsheet then the nxt_decoder_fsm
  // signals should be set
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Decoder FSM is zero: Indicates instr encoding not in spreadsheet")
    ovl_decoder_broken (.clk              (clk),
                        .reset_n          (reset_n),
                        .antecedent_expr  (ovl_valid_instrs_de[0]),
                        .consequent_expr  (nxt_flush_decoder_fsm_de[5:0] != 6'b000_000));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // At the end of an instruction, nxt_decoder_fsm should be 1
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"nxt_decoder_fsm is not 1 on final instruction cycle")
    ovl_decoder_fsm_not_1 (.clk              (clk),
                           .reset_n          (reset_n),
                           .antecedent_expr  (finish_instr_de),
                           .consequent_expr  (nxt_flush_decoder_fsm_de[5:0] == 6'b000_001));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // If an instruction is multicycle then CPSR mode and ns state must not change
  // (unless instruction causes a flush)
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg       delayed_ns_state_de_i;
  reg [4:0] delayed_spec_cpsr_mode_iss_i;
  reg [5:0] flush_decoder_fsm_de;
  reg       multicycle_instr;

  always @(posedge clk or negedge reset_n) begin
    if (~reset_n) begin
      delayed_ns_state_de_i        <= 1'b0;
      delayed_spec_cpsr_mode_iss_i <= `CA53_FULL_MODE_SVC;
    end else begin
      delayed_ns_state_de_i        <= ns_state_de_i;
      delayed_spec_cpsr_mode_iss_i <= spec_cpsr_mode_iss_i;
    end
  end

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      flush_decoder_fsm_de <= 6'b00_0001;
      multicycle_instr     <= 1'b0;
    end else if (~stall_de_i | flush_wr_i) begin
      flush_decoder_fsm_de <= nxt_flush_decoder_fsm_de;
      multicycle_instr     <= ~end_instr_de_o & ~flush_wr_i & (multicycle_instr | (flush_decoder_fsm_de == 6'b00_0001 & nxt_flush_decoder_fsm_de != 6'b00_0001));
    end

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"ns_state_de_i should not change during execution of multicycle instruction")
    ovl_ns_state_stable_for_multicycle (.clk             (clk),
                                        .reset_n         (reset_n),
                                        .antecedent_expr (multicycle_instr & ~flush_wr_i),
                                        .consequent_expr (ns_state_de_i == delayed_ns_state_de_i));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"spec_cpsr_mode_iss_i should not change during execution of multicycle instruction")
    ovl_cpsr_mode_stable_for_multicycle (.clk             (clk),
                                         .reset_n         (reset_n),
                                         .antecedent_expr (multicycle_instr & ~flush_wr_i),
                                         .consequent_expr (spec_cpsr_mode_iss_i == delayed_spec_cpsr_mode_iss_i));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Check that the mode encoding, which is an input to reg_trans doesn't
  // take an illegal value (it should have already been translated into some
  // value value before reaching this point)
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Illegal mode encoding for register translation: mode_for_srs_de")
    ovl_ill_mode1 (.clk              (clk),
                   .reset_n          (reset_n),
                   .antecedent_expr  (ovl_valid_instrs_de[0]),
                   .consequent_expr  ((mode_for_srs_de == `CA53_FULL_MODE_USR)  |
                                      (mode_for_srs_de == `CA53_FULL_MODE_FIQ)  |
                                      (mode_for_srs_de == `CA53_FULL_MODE_IRQ)  |
                                      (mode_for_srs_de == `CA53_FULL_MODE_SVC)  |
                                      (mode_for_srs_de == `CA53_FULL_MODE_ABT)  |
                                      (mode_for_srs_de == `CA53_FULL_MODE_UND)  |
                                      (mode_for_srs_de == `CA53_FULL_MODE_SYS)  |
                                      (mode_for_srs_de == `CA53_FULL_MODE_MON)  |
                                      (mode_for_srs_de == `CA53_FULL_MODE_HYP)  |
                                      (mode_for_srs_de == `CA53_FULL_MODE_EL0T) |
                                      (mode_for_srs_de == `CA53_FULL_MODE_EL1T) |
                                      (mode_for_srs_de == `CA53_FULL_MODE_EL1H) |
                                      (mode_for_srs_de == `CA53_FULL_MODE_EL2T) |
                                      (mode_for_srs_de == `CA53_FULL_MODE_EL2H) |
                                      (mode_for_srs_de == `CA53_FULL_MODE_EL3T) |
                                      (mode_for_srs_de == `CA53_FULL_MODE_EL3H)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Check that the mode encoding, which is an input to reg_trans doesn't
  // take an illegal value (it should have already been translated into some
  // value value before reaching this point)
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Illegal mode encoding for register translation: spec_cpsr_mode_iss_i")
    ovl_ill_mode2 (.clk              (clk),
                   .reset_n          (reset_n),
                   .antecedent_expr  (ovl_valid_instrs_de[0]),
                   .consequent_expr  ((spec_cpsr_mode_iss_i == `CA53_FULL_MODE_USR)  |
                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_FIQ)  |
                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_IRQ)  |
                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_SVC)  |
                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_ABT)  |
                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_UND)  |
                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_SYS)  |
                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_MON)  |
                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_HYP)  |
                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_EL0T) |
                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_EL1T) |
                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_EL1H) |
                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_EL2T) |
                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_EL2H) |
                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_EL3T) |
                                      (spec_cpsr_mode_iss_i == `CA53_FULL_MODE_EL3H)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Instructions which might generate exceptions must be single issue (except 
  // FP/NEON)
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Instruction which might cause exception not single issue")
    ovl_expt_single_issue  (.clk              (clk),
                            .reset_n          (reset_n),
                            .antecedent_expr  (ovl_valid_instrs_de[1]),
                            .consequent_expr  ((expt_instr_type_de_o == `CA53_EXPT_INSTR_TYPE_NULL) | iq_instr0_is_fn));
  // OVL_ASSERT_END

  // ------------------------------------------------------
  // One hot read register long address
  // ------------------------------------------------------

  // Out Of reset the signals are X but they will not cause any issue, extend reset
  // period up to first valid instruction
  reg ovl_regexpand_hold_reset_n;
  wire ovl_regexpand_valid_reset_n;
  // extend reset to first valid
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_regexpand_hold_reset_n <= 1'b0;
    else if (iq_instr0_val)
      ovl_regexpand_hold_reset_n <= 1'b1;

  // ensure first valid cycle is captured as well
  assign ovl_regexpand_valid_reset_n = ovl_regexpand_hold_reset_n | iq_instr0_val;

  // OVL_ASSERT_RTL
  assert_one_hot #(`OVL_FATAL, `CA53_LONG_RF_ADDR_W, `OVL_ASSERT, "Long register file read address R0 not one-hot.")
  ovl_de_regexpand_onehot0 (
    .clk       (clk),
    .reset_n   (ovl_regexpand_valid_reset_n),
`ifdef OVL_SVA
    .test_expr (ovl_regexpand_valid_reset_n ? long_rf_rd_addr_r0_de_o : {{`CA53_LONG_RF_ADDR_W-1{1'b0}},1'b1})
`else
    .test_expr (long_rf_rd_addr_r0_de_o)
`endif
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_one_hot #(`OVL_FATAL, `CA53_LONG_RF_ADDR_W, `OVL_ASSERT, "Long register file read address R1 not one-hot.")
  ovl_de_regexpand_onehot1 (
    .clk       (clk),
    .reset_n   (ovl_regexpand_valid_reset_n),
`ifdef OVL_SVA
    .test_expr (ovl_regexpand_valid_reset_n ? long_rf_rd_addr_r1_de_o : {{`CA53_LONG_RF_ADDR_W-1{1'b0}},1'b1})
`else
    .test_expr (long_rf_rd_addr_r1_de_o)
`endif
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Spreadsheet Error: R0/1/2/3/4 read enable set, but not consumed by datapaths
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"R0 read port enabled, but read is not consumed anywhere")
  ovl_dec_err_r0_read (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (ovl_valid_instrs_de[0] & rf_rd_en_r0_de_o & (expt_instr_type_de_o == `CA53_EXPT_INSTR_TYPE_NULL)),
    .consequent_expr ((ex_pipe_1_de[`CA53_EX_PIPE_DCU_BIT] & (agu_data_a_sel_de_o  == `CA53_SEL_DCU_A_R0))  |   // Slot 1 LS
                      (ex_pipe_0_de[`CA53_EX_PIPE_DCU_BIT] & (agu_data_a_sel_de_o  == `CA53_SEL_DCU_A_R0))  |   // Slot 0 LS
                      (ex_pipe_0_de[`CA53_EX_PIPE_ALU_BIT] & (alu0_data_a_sel_de_o == `CA53_SEL_SHF_A_R0))  |   // Slot 0 ALU
                      (ex_pipe_0_de[`CA53_EX_PIPE_MAC_BIT] & (mac_data_a_sel_de_o  == `CA53_SEL_MAC_A_R0))  |   // Slot 0 MAC
                      (ex_pipe_0_de[`CA53_EX_PIPE_DIV_BIT] & (div_data_a_sel_de_o  == `CA53_SEL_DIV_A_R0))));   // Slot 0 Div
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"R1 read port enabled, but read is not consumed anywhere")
  ovl_dec_err_r1_read (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (ovl_valid_instrs_de[0] & rf_rd_en_r1_de_o & (expt_instr_type_de_o == `CA53_EXPT_INSTR_TYPE_NULL)),
    .consequent_expr ((ex_pipe_1_de[`CA53_EX_PIPE_DCU_BIT] &  agu_data_b_sel_de_o[`CA53_SEL_DCU_B_BIT_R1])  |   // Slot 1 LS - reg + reg
                      (ex_pipe_1_de[`CA53_EX_PIPE_ALU_BIT] & (alu1_data_b_sel_de_o == `CA53_SEL_SHF_B_R4))  |   // Slot 1 LS - agu can't shift (remapping)
                      (ex_pipe_1_de[`CA53_EX_PIPE_STR_BIT] & (str1_data_a_sel_de_o == `CA53_SEL_STR_A_R4))  |   // Slot 1 Store - reg + imm addr (remapping)
                      (ex_pipe_0_de[`CA53_EX_PIPE_DCU_BIT] &  agu_data_b_sel_de_o[`CA53_SEL_DCU_B_BIT_R1])  |   // Slot 0 LS
                      (ex_pipe_0_de[`CA53_EX_PIPE_STR_BIT] & (str0_data_a_sel_de_o == `CA53_SEL_STR_A_R1))  |   // Slot 0 Store - reg + imm addr
                      (ex_pipe_0_de[`CA53_EX_PIPE_ALU_BIT] & (alu0_data_b_sel_de_o == `CA53_SEL_SHF_B_R1))  |   // Slot 0 ALU/LS agu can't shift
                      (ex_pipe_0_de[`CA53_EX_PIPE_MAC_BIT] & (mac_data_b_sel_de_o  == `CA53_SEL_MAC_B_R1))  |   // Slot 0 MAC
                      (ex_pipe_0_de[`CA53_EX_PIPE_DIV_BIT] & (div_data_b_sel_de_o  == `CA53_SEL_DIV_B_R1))));   // Slot 0 Div
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"R2 read port enabled, but read is not consumed anywhere")
  ovl_dec_err_r2_read (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (ovl_valid_instrs_de[0] & rf_rd_en_r2_de_o & (expt_instr_type_de_o == `CA53_EXPT_INSTR_TYPE_NULL)),
    .consequent_expr ((ex_pipe_1_de[`CA53_EX_PIPE_ALU_BIT] & (alu1_data_c_sel_de_o == `CA53_SEL_SHF_C_R2)) |    // Slot 1 ALU reg-shift-reg
                      (ex_pipe_1_de[`CA53_EX_PIPE_STR_BIT] & (str1_data_a_sel_de_o == `CA53_SEL_STR_A_R2)) |    // Slot 1 store
                      (ex_pipe_1_de[`CA53_EX_PIPE_STR_BIT] & (str1_data_b_sel_de_o == `CA53_SEL_STR_B_R2)) |    // Slot 1 store
                      (ex_pipe_1_de[`CA53_EX_PIPE_STR_BIT] & (str0_data_a_sel_de_o == `CA53_SEL_STR_A_R2)) |    // Slot 1 store 2 64-bit registers
                      (ex_pipe_0_de[`CA53_EX_PIPE_ALU_BIT] & (alu0_data_c_sel_de_o == `CA53_SEL_SHF_C_R2)) |    // Slot 0 ALU reg-shift-reg
                      (ex_pipe_0_de[`CA53_EX_PIPE_STR_BIT] & (str0_data_a_sel_de_o == `CA53_SEL_STR_A_R2)) |    // Slot 0 store
                      (ex_pipe_0_de[`CA53_EX_PIPE_STR_BIT] & (str0_data_b_sel_de_o == `CA53_SEL_STR_B_R2)) |    // Slot 0 store
                      (ex_pipe_0_de[`CA53_EX_PIPE_STR_BIT] & (str1_data_a_sel_de_o == `CA53_SEL_STR_A_R2))));   // Slot 0 store 2 64-bit registers
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"R3 read port enabled, but read is not consumed anywhere")
  ovl_dec_err_r3_read (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (ovl_valid_instrs_de[0] & rf_rd_en_r3_de_o & (expt_instr_type_de_o == `CA53_EXPT_INSTR_TYPE_NULL)),
    .consequent_expr ((ex_pipe_1_de[`CA53_EX_PIPE_ALU_BIT] & (alu1_data_a_sel_de_o == `CA53_SEL_SHF_A_R0)) |    // Slot 1 ALU
                      (ex_pipe_0_de[`CA53_EX_PIPE_MAC_BIT] & (mac_data_a_sel_de_o  == `CA53_SEL_MAC_A_R3)) |    // Slot 0 MAC (remapping)
                      (ex_pipe_1_de[`CA53_EX_PIPE_MAC_BIT] & (mac_data_a_sel_de_o  == `CA53_SEL_MAC_A_R3)) |    // Slot 1 MAC
                      (ex_pipe_0_de[`CA53_EX_PIPE_DIV_BIT] & (div_data_a_sel_de_o  == `CA53_SEL_DIV_A_R3)) |    // Slot 0 Div (remapping)
                      (ex_pipe_1_de[`CA53_EX_PIPE_DIV_BIT] & (div_data_a_sel_de_o  == `CA53_SEL_DIV_A_R3)) |    // Slot 1 Div
                      (ex_pipe_0_de[`CA53_EX_PIPE_ALU_BIT] & (alu0_data_a_sel_de_o == `CA53_SEL_SHF_A_R3)) |    // Slot 0 ALU (remapping)
                      (ex_pipe_0_de[`CA53_EX_PIPE_STR_BIT] & (str0_data_b_sel_de_o == `CA53_SEL_STR_B_R3))));   // Slot 0 Store 2 registers
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"R4 read port enabled, but read is not consumed anywhere")
  ovl_dec_err_r4_read (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (ovl_valid_instrs_de[0] & rf_rd_en_r4_de_o & (expt_instr_type_de_o == `CA53_EXPT_INSTR_TYPE_NULL)),
    .consequent_expr ((ex_pipe_1_de[`CA53_EX_PIPE_ALU_BIT] & (alu1_data_b_sel_de_o == `CA53_SEL_SHF_B_R1)) |    // Slot 1 ALU
                      (ex_pipe_0_de[`CA53_EX_PIPE_MAC_BIT] & (mac_data_b_sel_de_o  == `CA53_SEL_MAC_B_R4)) |    // Slot 0 MAC (remapping)
                      (ex_pipe_1_de[`CA53_EX_PIPE_MAC_BIT] & (mac_data_b_sel_de_o  == `CA53_SEL_MAC_B_R4)) |    // Slot 1 MAC
                      (ex_pipe_0_de[`CA53_EX_PIPE_DIV_BIT] & (div_data_b_sel_de_o  == `CA53_SEL_DIV_B_R4)) |    // Slot 0 Div (remapping)
                      (ex_pipe_1_de[`CA53_EX_PIPE_DIV_BIT] & (div_data_b_sel_de_o  == `CA53_SEL_DIV_B_R4)) |    // Slot 1 Div
                      (ex_pipe_0_de[`CA53_EX_PIPE_ALU_BIT] & (alu0_data_b_sel_de_o == `CA53_SEL_SHF_B_R4)) |    // Slot 0 ALU (remapping)
                      (ex_pipe_0_de[`CA53_EX_PIPE_STR_BIT] & (str0_data_a_sel_de_o == `CA53_SEL_STR_A_R4)) |    // Slot 0 Store
                      (ex_pipe_1_de[`CA53_EX_PIPE_STR_BIT] & (str1_data_a_sel_de_o == `CA53_SEL_STR_A_R1))));   // Slot 0 Store
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Spreadsheet Error: R0-4, FR0-5 'need' signal should not be set if not reading,
  // although the PC may be selected and it is not worth suppressing 'need'
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"R0 read port not used (nor is PC), but 'need' is non-zero")
    ovl_dec_err_r0_need_nz (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr (ovl_valid_instrs_de[0]                               &
                                        (~iq_instr1_val | ovl_valid_instrs_de[1])            &
                                        ~rf_rd_en_r0_de_o                                    &
                                        (expt_instr_type_de_o == `CA53_EXPT_INSTR_TYPE_NULL) &
                                        (rf_rd_need_r0_de_o  != 3'b000)                      &
                                        ~r0_is_zr                                            &
                                        (alu0_data_a_sel_de_o  != `CA53_SEL_SHF_A_PC)        &
                                        (agu_data_a_sel_de_o != `CA53_SEL_DCU_A_PC)));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"R1 read port not used (nor is PC), but 'need' is non-zero")
    ovl_dec_err_r1_need_nz (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr (ovl_valid_instrs_de[0]                               &
                                        (~iq_instr1_val | ovl_valid_instrs_de[1])            &
                                        ~rf_rd_en_r1_de_o                                    &
                                        (expt_instr_type_de_o == `CA53_EXPT_INSTR_TYPE_NULL) &
                                        (rf_rd_need_r1_de_o != 3'b000)                       &
                                        ~r1_is_zr                                            &
                                        (alu0_data_b_sel_de_o != `CA53_SEL_SHF_B_PC)));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"R2 read port not used, but 'need' is non-zero")
    ovl_dec_err_r2_need_nz (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr (ovl_valid_instrs_de[0]                               &
                                        (~iq_instr1_val | ovl_valid_instrs_de[1])            &
                                        ~rf_rd_en_r2_de_o                                    &
                                        (expt_instr_type_de_o == `CA53_EXPT_INSTR_TYPE_NULL) &
                                        ~r2_is_zr                                            &
                                        (rf_rd_need_r2_de_o != 3'b000)));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"R3 read port not used, but 'need' is non-zero")
    ovl_dec_err_r3_need_nz (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr (ovl_valid_instrs_de[0]                               &
                                        (~iq_instr1_val | ovl_valid_instrs_de[1])            &
                                        ~rf_rd_en_r3_de_o                                    &
                                        (expt_instr_type_de_o == `CA53_EXPT_INSTR_TYPE_NULL) &
                                        (rf_rd_need_r3_de_o != 3'b000)                       &
                                        ((rf_rd_remap_de ? alu0_data_a_sel_de_o : alu1_data_a_sel_de_o) != `CA53_SEL_SHF_A_PC) &
                                        ~r3_is_zr));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"R4 read port not used, but 'need' is non-zero")
    ovl_dec_err_r4_need_nz (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr (ovl_valid_instrs_de[0]                               &
                                        (~iq_instr1_val | ovl_valid_instrs_de[1])            &
                                        ~rf_rd_en_r4_de_o                                    &
                                        (expt_instr_type_de_o == `CA53_EXPT_INSTR_TYPE_NULL) &
                                        (rf_rd_need_r4_de_o != 3'b000)                       &
                                        ((rf_rd_remap_de ? alu0_data_b_sel_de_o : alu1_data_b_sel_de_o) != `CA53_SEL_SHF_B_PC) &
                                        ~r4_is_zr));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"FR0 read port not used, but 'need' is non-zero")
    ovl_dec_err_fr0_need_nz (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr (ovl_valid_instrs_de[0]                   &
                                        (~iq_instr1_val | ovl_valid_instrs_de[1]) &
                                         ~(|rf_rd_en_fr0_de_o)                    &
                                         (|rf_rd_need_fr0_de_o)));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"FR1 read port not used, but 'need' is non-zero")
    ovl_dec_err_fr1_need_nz (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr (ovl_valid_instrs_de[0]                   &
                                        (~iq_instr1_val | ovl_valid_instrs_de[1]) &
                                         ~(|rf_rd_en_fr1_de_o)                    &
                                         (|rf_rd_need_fr1_de_o)));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"FR2 read port not used, but 'need' is non-zero")
    ovl_dec_err_fr2_need_nz (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr (ovl_valid_instrs_de[0]                   &
                                        (~iq_instr1_val | ovl_valid_instrs_de[1]) &
                                         ~(|rf_rd_en_fr2_de_o)                    &
                                         (|rf_rd_need_fr2_de_o)));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"FR3 read port not used, but 'need' is non-zero")
    ovl_dec_err_fr3_need_nz (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr (ovl_valid_instrs_de[0]                   &
                                        (~iq_instr1_val | ovl_valid_instrs_de[1]) &
                                         ~(|rf_rd_en_fr3_de_o)                    &
                                         (|rf_rd_need_fr3_de_o)));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"FR4 read port not used, but 'need' is non-zero")
    ovl_dec_err_fr4_need_nz (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr (ovl_valid_instrs_de[0]                   &
                                        (~iq_instr1_val | ovl_valid_instrs_de[1]) &
                                         ~(|rf_rd_en_fr4_de_o)                    &
                                         (|rf_rd_need_fr4_de_o)));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"FR5 read port not used, but 'need' is non-zero")
    ovl_dec_err_fr5_need_nz (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr (ovl_valid_instrs_de[0]                   &
                                        (~iq_instr1_val | ovl_valid_instrs_de[1]) &
                                         ~(|rf_rd_en_fr5_de_o)                    &
                                         (|rf_rd_need_fr5_de_o)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Spreadsheet Error: 'need' signal is earlier than needed
  //----------------------------------------------------------------------------

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"R0 'need' is earlier than required")
  ovl_dec_err_r0_need_early (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_rd_en_r0_de_o & (rf_rd_need_r0_de_o == `CA53_RF_RD_NEED_EARLY_ISS) & (expt_instr_type_de_o != `CA53_EXPT_INSTR_TYPE_UNDEF)),
    .consequent_expr (ex_pipe_0_de[`CA53_EX_PIPE_DCU_BIT] | ex_pipe_1_de[`CA53_EX_PIPE_DCU_BIT])
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"R1 'need' is earlier than required")
  ovl_dec_err_r1_need_early (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_rd_en_r1_de_o & (rf_rd_need_r1_de_o == `CA53_RF_RD_NEED_EARLY_ISS) & (expt_instr_type_de_o != `CA53_EXPT_INSTR_TYPE_UNDEF)),
    .consequent_expr (ex_pipe_0_de[`CA53_EX_PIPE_DCU_BIT] | ex_pipe_1_de[`CA53_EX_PIPE_DCU_BIT] |
                      // MSR uses ALU and has need of Early Iss
                      decoder_select0[OT])
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"R2 'need' is earlier than required")
  ovl_dec_err_r2_need_early (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_rd_en_r2_de_o & (expt_instr_type_de_o != `CA53_EXPT_INSTR_TYPE_UNDEF)),
                      // R2 never has need of Early Iss (but can be late iss for shifter)
    .consequent_expr ((rf_rd_need_r2_de_o != `CA53_RF_RD_NEED_EARLY_ISS))
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"R3 'need' is earlier than required")
  ovl_dec_err_r3_need_early (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_rd_en_r3_de_o & (expt_instr_type_de_o != `CA53_EXPT_INSTR_TYPE_UNDEF)),
                      // R3 never has need of Early Iss (slot 1 LS will use R0-1)
    .consequent_expr ((rf_rd_need_r2_de_o != `CA53_RF_RD_NEED_EARLY_ISS))
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"R4 'need' is earlier than required")
  ovl_dec_err_r4_need_early (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_rd_en_r2_de_o & (expt_instr_type_de_o != `CA53_EXPT_INSTR_TYPE_UNDEF)),
                      // R4 never has need of Early Iss (slot 1 LS will use R0-1)
    .consequent_expr ((rf_rd_need_r2_de_o != `CA53_RF_RD_NEED_EARLY_ISS))
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Spreadsheet Error: Datapath selecting read port, but no enable
  //----------------------------------------------------------------------------

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Datapath selects read port R0, but no read port R0 enable")
  ovl_dec_err_r0_sel (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (ovl_valid_instrs_de[0] & (expt_instr_type_de_o != `CA53_EXPT_INSTR_TYPE_UNDEF) &
                      ((alu0_valid_de_o & (alu0_data_a_sel_de_o == `CA53_SEL_SHF_A_R0)) |
                       (alu1_valid_de_o & (alu1_data_a_sel_de_o == `CA53_SEL_SHF_A_R3)) |
                       (mac_valid_de_o  & (mac_data_a_sel_de_o  == `CA53_SEL_MAC_A_R0)) |
                       (div_valid_de_o  & (div_data_a_sel_de_o  == `CA53_SEL_DIV_A_R0)) |
                       (ls_valid_de_o   & (agu_data_a_sel_de_o  == `CA53_SEL_DCU_A_R0)))),
    .consequent_expr (rf_rd_en_r0_de_o)
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Datapath selects read port R1, but no read port R1 enable")
  ovl_dec_err_r1_sel (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (ovl_valid_instrs_de[0] & (expt_instr_type_de_o != `CA53_EXPT_INSTR_TYPE_UNDEF) &
                      ((alu0_valid_de_o & (alu0_data_b_sel_de_o == `CA53_SEL_SHF_B_R1)) |
                       (alu1_valid_de_o & (alu1_data_b_sel_de_o == `CA53_SEL_SHF_B_R4)) |
                       (mac_valid_de_o  & (mac_data_b_sel_de_o  == `CA53_SEL_MAC_B_R1)) |
                       (div_valid_de_o  & (div_data_b_sel_de_o  == `CA53_SEL_DIV_B_R1)) |
                       (str0_valid_de_o & (str0_data_a_sel_de_o == `CA53_SEL_STR_A_R1)) |
                       (str1_valid_de_o & (str1_data_a_sel_de_o == `CA53_SEL_STR_A_R4)) |
                       (ls_valid_de_o   & agu_data_b_sel_de_o[`CA53_SEL_DCU_B_BIT_R1]))),
    .consequent_expr (rf_rd_en_r1_de_o)
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Datapath selects read port R2, but no read port R2 enable")
  ovl_dec_err_r2_sel (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (ovl_valid_instrs_de[0] & (expt_instr_type_de_o != `CA53_EXPT_INSTR_TYPE_UNDEF) &
                      ((alu0_valid_de_o & (alu0_data_c_sel_de_o == `CA53_SEL_SHF_C_R2)) |
                       (alu1_valid_de_o & (alu1_data_c_sel_de_o == `CA53_SEL_SHF_C_R2)) |
                       (str0_valid_de_o & (str0_data_a_sel_de_o == `CA53_SEL_STR_A_R2)) |
                       (str0_valid_de_o & (str0_data_b_sel_de_o == `CA53_SEL_STR_B_R2)) |
                       (str1_valid_de_o & (str1_data_a_sel_de_o == `CA53_SEL_STR_A_R2)) |
                       (str1_valid_de_o & (str1_data_b_sel_de_o == `CA53_SEL_STR_B_R2)))),
    .consequent_expr (rf_rd_en_r2_de_o)
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Datapath selects read port R3, but no read port R3 enable")
  ovl_dec_err_r3_sel (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (ovl_valid_instrs_de[0] & (expt_instr_type_de_o != `CA53_EXPT_INSTR_TYPE_UNDEF) &
                      ((alu0_valid_de_o & (alu0_data_a_sel_de_o == `CA53_SEL_SHF_A_R3)) |
                       (alu1_valid_de_o & (alu1_data_a_sel_de_o == `CA53_SEL_SHF_A_R0)) |
                       (mac_valid_de_o  & (mac_data_a_sel_de_o  == `CA53_SEL_MAC_A_R3)) |
                       (div_valid_de_o  & (div_data_a_sel_de_o  == `CA53_SEL_DIV_A_R3)) |
                       (str0_valid_de_o & (str0_data_b_sel_de_o == `CA53_SEL_STR_B_R3)))),
    .consequent_expr (rf_rd_en_r3_de_o)
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Datapath selects read port R4, but no read port R4 enable")
  ovl_dec_err_r4_sel (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (ovl_valid_instrs_de[0] & (expt_instr_type_de_o != `CA53_EXPT_INSTR_TYPE_UNDEF) &
                      ((alu0_valid_de_o & (alu0_data_b_sel_de_o == `CA53_SEL_SHF_B_R4)) |
                       (alu1_valid_de_o & (alu1_data_b_sel_de_o == `CA53_SEL_SHF_B_R1)) |
                       (mac_valid_de_o  & (mac_data_b_sel_de_o  == `CA53_SEL_MAC_B_R4)) |
                       (div_valid_de_o  & (div_data_b_sel_de_o  == `CA53_SEL_DIV_B_R4)) |
                       (str0_valid_de_o & (str0_data_a_sel_de_o == `CA53_SEL_STR_A_R4)) |
                       (str1_valid_de_o & (str1_data_a_sel_de_o == `CA53_SEL_STR_A_R1)))),
    .consequent_expr (rf_rd_en_r4_de_o)
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Spreadsheet Error: Write source mux selecting datapath but no write enable
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Write source mux selects datapath, but no write occurs")
    ovl_dec_err_wr_src_sel_err (.clk       (clk),
                                .reset_n   (reset_n),
                                .test_expr (ovl_valid_instrs_de[0]                    &
                                            (~iq_instr1_val | ovl_valid_instrs_de[1]) &
                                            ~decoder_select0[FO]                      &
                                            ~rf_wr_en_w1_de_o                         &
                                            ~w1_is_zr                                 &
                                            ~(decoder_select0[LS] & u_dec0_ls.suppress_writeback)  &
                                            (rf_wr_src_w1_de_o == `CA53_RF_WR_SRC_W1_ALU)));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"FPU write source mux selects datapath, but no write occurs")
    ovl_dec_err_fp_wr_src_sel_err (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .test_expr (ovl_valid_instrs_de[0]              &
                                               (~iq_instr1_val | ovl_valid_instrs_de[1])  &
                                               ~((|rf_wr_en_fw0_de_o) | (|rf_wr_en_fw1_de_o)) &
                                               (rf_wr_src_fw0_de_o != `CA53_RF_FWR_SRC_NONE)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Spreadsheet Error: Datapath control pipeline should not be set if no ALU/Mac
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Datapath pipeline control set, but ALU/MAC pipeline not enabled")
    ovl_dec_err_alu0_pipectl (.clk       (clk),
                              .reset_n   (reset_n),
                              .test_expr (ovl_valid_instrs_de[0] &
                                          (~iq_instr1_val | ovl_valid_instrs_de[1])  &
                                          ~(expt_instr_type_de_o == `CA53_EXPT_INSTR_TYPE_UNDEF) &
                                          ~(alu0_valid_de_o | mac_valid_de_o | div_valid_de_o) &
                                          (|alu0_pipectl_de_o[`CA53_ALU_PIPECTL_W-1:0])));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Spreadsheet Error: Branch control pipeline should not be set if no branch
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Branch pipeline control set, but branch pipeline not enabled")
    ovl_dec_err_br_pipectl (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr (ovl_valid_instrs_de[0] &
                                        (~iq_instr1_val | ovl_valid_instrs_de[1])  &
                                        ~br_valid_de_o &
                                        (|br_pipectl_de_o[`CA53_BR_PIPECTL_W-1:0])));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Spreadsheet Error: W0 Write 'when' set, but no register file enable
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"W0 Write 'when' set, but no register file W0 write enable")
    ovl_dec_err_w0_when (.clk       (clk),
                         .reset_n   (reset_n),
                         .test_expr (ovl_valid_instrs_de[0]                        &
                                     (~iq_instr1_val | ovl_valid_instrs_de[1])     &
                                     ~rf_wr_en_w0_de_o                             &
                                     ~w0_is_zr                                     &
                                     ~(br_pipectl_de_o[2:0] == `CA53_BR_INDIRECT_LD) &
                                     (|rf_wr_when_w0_de_o[`CA53_RF_WR_WHEN_W-1:0])));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Spreadsheet Error: W1 Write 'when' set, but no register file enable
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"W1 Write 'when' set, but no register file W1 write enable")
    ovl_dec_err_w1_when (.clk       (clk),
                         .reset_n   (reset_n),
                         .test_expr (ovl_valid_instrs_de[0]                                 &
                                     (~iq_instr1_val | ovl_valid_instrs_de[1])              &
                                     ~decoder_select0[FO]                                   &
                                     ~rf_wr_en_w1_de_o                                      &
                                     ~w1_is_zr                                              &
                                     ~(decoder_select0[LS] & u_dec0_ls.suppress_writeback)  &
                                     (|rf_wr_when_w1_de_o[`CA53_RF_WR_WHEN_W-1:0])));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Spreadsheet Error: Write port src invalid
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"rf_wr_src_w0_de has an illegal value in the decode stage when it is valid")
  ovl_rf_wr_src_w0_de_illegal (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_wr_en_w0_de_o),
    .consequent_expr ((rf_wr_src_w0_de_o == `CA53_RF_WR_SRC_W0_DCU_0)   ||
                      (rf_wr_src_w0_de_o == `CA53_RF_WR_SRC_W0_CPSR)    ||
                      (rf_wr_src_w0_de_o == `CA53_RF_WR_SRC_W0_MAC_HI)  ||
                      (rf_wr_src_w0_de_o == `CA53_RF_WR_SRC_W0_STR)     ||
                      (rf_wr_src_w0_de_o == `CA53_RF_WR_SRC_W0_CP)      ||
                      (rf_wr_src_w0_de_o == `CA53_RF_WR_SRC_W0_STREX)   ||
                      (rf_wr_src_w0_de_o == `CA53_RF_WR_SRC_W0_SPSR))
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"rf_wr_src_w1_de has an illegal value in the decode stage when it is valid")
  ovl_rf_wr_src_w1_de_illegal (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_wr_en_w1_de_o),
    .consequent_expr ((rf_wr_src_w1_de_o == `CA53_RF_WR_SRC_W1_ALU)     ||
                      (rf_wr_src_w1_de_o == `CA53_RF_WR_SRC_W1_MAC_LO)  ||
                      (rf_wr_src_w1_de_o == `CA53_RF_WR_SRC_W1_CP)      ||
                      (rf_wr_src_w1_de_o == `CA53_RF_WR_SRC_W1_DIV)     ||
                      (rf_wr_src_w1_de_o == `CA53_RF_WR_SRC_W1_STR)     ||
                      (rf_wr_src_w1_de_o == `CA53_RF_WR_SRC_W1_FP_ALU))
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"rf_wr_src_w2_de has an illegal value in the decode stage when it is valid")
  ovl_rf_wr_src_w2_de_illegal (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_wr_en_w2_de_o),
    .consequent_expr ((rf_wr_src_w2_de_o == `CA53_RF_WR_SRC_W2_DCU_1)   ||
                      (rf_wr_src_w2_de_o == `CA53_RF_WR_SRC_W2_ALU)     ||
                      (rf_wr_src_w2_de_o == `CA53_RF_WR_SRC_W2_MAC_LO)  ||
                      (rf_wr_src_w2_de_o == `CA53_RF_WR_SRC_W2_FP_ALU)  ||
                      (rf_wr_src_w2_de_o == `CA53_RF_WR_SRC_W2_STR))
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Spreadsheet Error: Slot 0 or 1 should never write same register on
  // different write ports (but could write same register between slot 0 and
  // slot 1 - this is picked up later in the pipeline).
  //----------------------------------------------------------------------------

  // - Slot 0 controls all write ports: check all ports against each other
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"The slot 0 w0, w1 or w2 write ports refer to same register in same cycle")
    ovl_dec_err_sim_s0_s0_s0 (.clk              (clk),
                              .reset_n          (reset_n),
                              .antecedent_expr  (ovl_valid_instrs_de[0] & (decoder_select1 == 3'b000)),
                              .consequent_expr  (~((rf_wr_vaddr_w0_de_o[4:0] == rf_wr_vaddr_w1_de_o[4:0] & rf_wr_en_w0_de_o & rf_wr_en_w1_de_o) |
                                                   (rf_wr_vaddr_w0_de_o[4:0] == rf_wr_vaddr_w2_de_o[4:0] & rf_wr_en_w0_de_o & rf_wr_en_w2_de_o) |
                                                   (rf_wr_vaddr_w1_de_o[4:0] == rf_wr_vaddr_w2_de_o[4:0] & rf_wr_en_w1_de_o & rf_wr_en_w2_de_o))));
  // OVL_ASSERT_END

  // - Slot 0 controls W0-1, Slot 1 controls W2: check W0 and W1 against each other
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"The slot 0 w0 and w1 write ports refer to same register in same cycle")
    ovl_dec_err_sim_s0_s0_xx (.clk              (clk),
                              .reset_n          (reset_n),
                              .antecedent_expr  (ovl_valid_instrs_de[0] & instr0_w0_enabled),
                              .consequent_expr  (~(rf_wr_vaddr_w0_de_o[4:0] == rf_wr_vaddr_w1_de_o[4:0] & rf_wr_en_w0_de_o & rf_wr_en_w1_de_o)));
  // OVL_ASSERT_END

  // - Slot 0 controls W1, Slot 1 controls W0 and W2: check W0 and W2 against each other
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"The slot 1 w0 and w2 write ports refer to same register in same cycle")
    ovl_dec_err_sim_s1_xx_s1 (.clk              (clk),
                              .reset_n          (reset_n),
                              .antecedent_expr  (ovl_valid_instrs_de[0] & ~instr0_w0_enabled),
                              .consequent_expr  (~(rf_wr_vaddr_w0_de_o[4:0] == rf_wr_vaddr_w2_de_o[4:0] & rf_wr_en_w0_de_o & rf_wr_en_w2_de_o)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Spreadsheet Error: If enable_base_restore is set on the head of an
  //                    instruction, ALU0 should be enabled and should select
  //                    the base register
  //----------------------------------------------------------------------------

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Base restore enabled, but ALU0 not enabled")
    ovl_dec_err_base_restore_alu0 (
      .clk              (clk),
      .reset_n          (reset_n),
      .antecedent_expr  (enable_base_restore_de_o & head_instr_de_o[0]),
      .consequent_expr  (alu0_valid_de_o &
                         (alu0_data_a_sel_de_o == `CA53_SEL_SHF_A_R0))
    );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // When rewriting the immediate for a load/store for ADRP forwarding, should
  // not lose any immediate bits
  //----------------------------------------------------------------------------

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"LS immediate merged with ADRP immediate incorrectly")
    ovl_dec_err_adrp_fwd_imm (
      .clk              (clk),
      .reset_n          (reset_n),
      .antecedent_expr  (ls_valid_de_o & (adrp_fwd_src != 3'b000)),
      .consequent_expr  (raw_imm_data_ls_de[`CA53_IMM_DATA_W-1:12] == {`CA53_IMM_DATA_W-12{1'b0}})
    );
  // OVL_ASSERT_END

  `endif

endmodule // ca53dpu_de

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
