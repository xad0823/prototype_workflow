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
//      Checked In          : $Date: 2014-10-06 14:47:15 +0100 (Mon, 06 Oct 2014) $
//
//      Revision            : $Revision: 291618 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : DPU control signal pipeline
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// This module pipelines all the control signals that are generic to the DPU
// pipeline, ie. not associated with a specific data path.
//
// It also includes the logic for the Issue stage, the Interlock logic and
// the Forwarding logic.

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_ctl `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire                                 clk,
  input  wire                                 reset_n,
  input  wire                                 DFTSE,
  input  wire                                 aarch64_state_i,
  input  wire                         [39:2]  rvbaraddr_i,
  input  wire                          [1:0]  dpu_exception_level_i,
  input  wire                                 gov_stall_neon_i,
  input  wire                                 etm_stall_cpu_i,
  input  wire                          [1:0]  head_instr_de_i,
  input  wire                                 end_instr_de_i,
  input  wire                                 first_cycle_ls_de_i,
  input  wire                          [1:0]  valid_instrs_de_i,
  input  wire                                 size_instr0_de_i,
  input  wire                                 size_instr1_de_i,
  input  wire                                 thumb_instr0_de_i,
  input  wire                                 thumb_instr1_de_i,
  input  wire                         [63:0]  pc_instr0_de_i,
  input  wire                                 mod_pc_top_bits_de_i,
  input  wire                                 no_insert_de_i,
  input  wire                                 dcu_not_ready_iss_i,
  input  wire                                 first_lsm_skidding_i,
  input  wire                                 inter_lsm_skidding_i,
  input  wire                                 lsm_skidding_i,
  input  wire                                 lsm_64b_be_i,
  input  wire                                 lsm_64b_be_skidding_i,
  input  wire                                 lsm_n64b_be_skidding_i,
  input  wire                                 last_lsm_skidding_i,
  input  wire                                 force_extra_lsm_cycle_i,
  input  wire                                 extra_lsm_cycle_i,
  input  wire                                 ls_128b_be_i,
  input  wire                                 ldr_no_early_fwd_iss_i,
  input  wire                                 enable_base_restore_iss_i,
  input  wire    [`CA53_LS_INSTR_TYPE_W-1:0]  ls_instr_type_wr_i,
  input  wire                                 ls_store_wr_i,
  input  wire                                 ls_isv_set_wr_i,
  input  wire                                 ls_synd_sf_wr_i,
  input  wire                          [4:0]  ls_synd_srt_wr_i,
  input  wire                                 ls_stall_wr_i,
  input  wire                                 ls_valid_wr_i,
  input  wire                                 first_x64_iss_i,
  input  wire                                 second_x64_iss_i,
  input  wire        [`CA53_SEL_DCU_A_W-1:0]  agu_data_a_sel_iss_i,
  input  wire        [`CA53_SEL_DCU_B_W-1:0]  agu_data_b_sel_iss_i,
  input  wire                                 usr_mode_regs_ldm_de_i,
  input  wire                          [5:0]  rf_r0_for_fwd_check_de_i,
  input  wire                          [5:0]  rf_r1_for_fwd_check_de_i,
  input  wire                                 no_interrupt_de_i,
  input  wire                          [4:0]  rf_wr_mode_de_i,
  input  wire                                 rf_wr_en_w0_de_i,
  input  wire                                 rf_wr_en_w1_de_i,
  input  wire                                 rf_wr_en_w2_de_i,
  input  wire                                 rf_wr_64b_w0_de_i,
  input  wire                                 rf_wr_64b_w1_de_i,
  input  wire                                 rf_wr_64b_w2_de_i,
  input  wire                          [4:0]  rf_wr_vaddr_w0_de_i,
  input  wire                          [4:0]  rf_wr_vaddr_w1_de_i,
  input  wire                          [4:0]  rf_wr_vaddr_w2_de_i,
  input  wire     [`CA53_RF_WR_SRC_W0_W-1:0]  rf_wr_src_w0_de_i,
  input  wire     [`CA53_RF_WR_SRC_W1_W-1:0]  rf_wr_src_w1_de_i,
  input  wire     [`CA53_RF_WR_SRC_W2_W-1:0]  rf_wr_src_w2_de_i,
  input  wire    [`CA53_FP_RF_RD_ADDR_W-1:0]  rf_rd_addr_fr0_de_i,
  input  wire    [`CA53_FP_RF_RD_ADDR_W-1:0]  rf_rd_addr_fr1_de_i,
  input  wire    [`CA53_FP_RF_RD_ADDR_W-1:0]  rf_rd_addr_fr2_de_i,
  input  wire    [`CA53_FP_RF_RD_ADDR_W-1:0]  rf_rd_addr_fr3_de_i,
  input  wire    [`CA53_FP_RF_RD_ADDR_W-1:0]  rf_rd_addr_fr4_de_i,
  input  wire    [`CA53_FP_RF_RD_ADDR_W-1:0]  rf_rd_addr_fr5_de_i,
  input  wire                          [1:0]  rf_rd_en_fr0_de_i,
  input  wire                          [1:0]  rf_rd_en_fr1_de_i,
  input  wire                          [1:0]  rf_rd_en_fr2_de_i,
  input  wire                          [1:0]  rf_rd_en_fr3_de_i,
  input  wire                          [1:0]  rf_rd_en_fr4_de_i,
  input  wire                          [1:0]  rf_rd_en_fr5_de_i,
  input  wire      [`CA53_RF_FRD_NEED_W-1:0]  rf_rd_need_fr0_de_i,
  input  wire      [`CA53_RF_FRD_NEED_W-1:0]  rf_rd_need_fr1_de_i,
  input  wire      [`CA53_RF_FRD_NEED_W-1:0]  rf_rd_need_fr2_de_i,
  input  wire      [`CA53_RF_FRD_NEED_W-1:0]  rf_rd_need_fr3_de_i,
  input  wire      [`CA53_RF_FRD_NEED_W-1:0]  rf_rd_need_fr4_de_i,
  input  wire      [`CA53_RF_FRD_NEED_W-1:0]  rf_rd_need_fr5_de_i,
  input  wire    [`CA53_FP_RF_WR_ADDR_W-1:0]  rf_wr_addr_fw0_de_i,
  input  wire    [`CA53_FP_RF_WR_ADDR_W-1:0]  rf_wr_addr_fw1_de_i,
  input  wire                          [3:0]  rf_wr_en_fw0_de_i,
  input  wire                          [3:0]  rf_wr_en_fw1_de_i,
  input  wire       [`CA53_RF_FWR_SRC_W-1:0]  rf_wr_src_fw0_de_i,
  input  wire       [`CA53_RF_FWR_SRC_W-1:0]  rf_wr_src_fw1_de_i,
  input  wire      [`CA53_RF_FWR_WHEN_W-1:0]  rf_wr_when_fw0_de_i,
  input  wire      [`CA53_RF_FWR_WHEN_W-1:0]  rf_wr_when_fw1_de_i,
  input  wire                          [1:0]  fmac_valid_sp_de_i,
  input  wire                          [1:0]  fdiv_valid_de_i,
  input  wire                          [1:0]  neon_can_fwd_acc_de_i,
  input  wire     [`CA53_NEON_VLD_CTL_W-1:0]  neon_vld_ctl_de_i,
  input  wire       [`CA53_FP_EX_PIPE_W-1:0]  fp_ex_pipe_de_i,
  input  wire                                 crypto_enable_de_i,
  input  wire                          [1:0]  instr_fmstat_de_i,
  input  wire       [`CA53_FP_PIPECTL_W-1:0]  fp0_pipectl_iss_i,
  input  wire       [`CA53_FP_PIPECTL_W-1:0]  fp1_pipectl_iss_i,
  input  wire        [`CA53_SEL_FAD_A_W-1:0]  sel_fad0_a_iss_i,
  input  wire        [`CA53_SEL_FAD_B_W-1:0]  sel_fad0_b_iss_i,
  input  wire        [`CA53_SEL_FAD_C_W-1:0]  sel_fad0_c_iss_i,
  input  wire        [`CA53_SEL_FAD_A_W-1:0]  sel_fad1_a_iss_i,
  input  wire        [`CA53_SEL_FAD_B_W-1:0]  sel_fad1_b_iss_i,
  input  wire        [`CA53_SEL_FAD_C_W-1:0]  sel_fad1_c_iss_i,
  input  wire                                 sel_fml0_a_iss_i,
  input  wire        [`CA53_SEL_FML_B_W-1:0]  sel_fml0_b_iss_i,
  input  wire                                 sel_fml0_c_iss_i,
  input  wire                                 sel_fml1_a_iss_i,
  input  wire        [`CA53_SEL_FML_B_W-1:0]  sel_fml1_b_iss_i,
  input  wire                                 sel_fml1_c_iss_i,
  input  wire                                 fp_serialize_iss_i,
  input  wire     [`CA53_FP_CFLAG_SRC_W-1:0]  fp0_cflag_src_iss_i,
  input  wire     [`CA53_FP_CFLAG_SRC_W-1:0]  fp1_cflag_src_iss_i,
  input  wire     [`CA53_FP_XFLAG_SRC_W-1:0]  fp0_xflag_src_iss_i,
  input  wire     [`CA53_FP_XFLAG_SRC_W-1:0]  fp1_xflag_src_iss_i,
  input  wire                          [1:0]  iq_instr_is_fn_i,
  input  wire                                 instr_is_cp10_cp11_de_i,
  input  wire                          [1:0]  fp_div_busy_nxt_cyc_i,
  input  wire                                 neon_de_active_i,
  input  wire                          [3:0]  cond_code_instr0_de_i,
  input  wire                          [3:0]  cond_code_instr1_de_i,
  input  wire      [`CA53_ALU_PIPECTL_W-1:0]  alu0_pipectl_de_i,
  input  wire      [`CA53_ALU_PIPECTL_W-1:0]  alu1_pipectl_de_i,
  input  wire      [`CA53_MAC_PIPECTL_W-1:0]  mac_pipectl_de_i,
  input  wire                                 alu0_msk_data_sel_de_i,
  input  wire                                 alu1_msk_data_sel_de_i,
  input  wire        [`CA53_SEL_SHF_A_W-1:0]  alu0_data_a_sel_de_i,
  input  wire        [`CA53_SEL_SHF_B_W-1:0]  alu0_data_b_sel_de_i,
  input  wire        [`CA53_SEL_SHF_C_W-1:0]  alu0_data_c_sel_de_i,
  input  wire        [`CA53_SEL_MAC_A_W-1:0]  mac_data_a_sel_de_i,
  input  wire        [`CA53_SEL_MAC_B_W-1:0]  mac_data_b_sel_de_i,
  input  wire        [`CA53_SEL_DIV_A_W-1:0]  div_data_a_sel_de_i,
  input  wire        [`CA53_SEL_DIV_B_W-1:0]  div_data_b_sel_de_i,
  input  wire        [`CA53_SEL_SHF_A_W-1:0]  alu1_data_a_sel_de_i,
  input  wire        [`CA53_SEL_SHF_B_W-1:0]  alu1_data_b_sel_de_i,
  input  wire        [`CA53_SEL_SHF_C_W-1:0]  alu1_data_c_sel_de_i,
  input  wire        [`CA53_SEL_STR_A_W-1:0]  str0_data_a_sel_de_i,
  input  wire        [`CA53_SEL_STR_B_W-1:0]  str0_data_b_sel_de_i,
  input  wire                                 str0_b_valid_de_i,
  input  wire                                 ctl_64bit_op_str0_de_i,
  input  wire        [`CA53_SEL_STR_A_W-1:0]  str1_data_a_sel_de_i,
  input  wire        [`CA53_SEL_STR_B_W-1:0]  str1_data_b_sel_de_i,
  input  wire                                 str1_b_valid_de_i,
  input  wire                                 ctl_64bit_op_str1_de_i,
  input  wire                                 use_ex1_alu_0_de_i,
  input  wire                                 use_ex1_alu_1_de_i,
  input  wire                                 alu0_valid_de_i,
  input  wire                                 alu1_valid_de_i,
  input  wire                                 str0_valid_de_i,
  input  wire                                 str1_valid_de_i,
  input  wire                                 mac_valid_de_i,
  input  wire                                 cp_de_i,
  input  wire                                 ls_valid_de_i,
  input  wire                                 div_valid_de_i,
  input  wire                                 div_busy_iss_i,
  input  wire                                 nxt_div_busy_wr_i,
  input  wire       [`CA53_INSTR_TYPE_W-1:0]  instr_type_de_i,
  input  wire  [`CA53_EXPT_INSTR_TYPE_W-1:0]  expt_instr_type_de_i,
  input  wire   [`CA53_EXPT_INSTR_BUS_W-1:0]  expt_instr_data_de_i,
  input  wire                                 early_expt_enable_de_i,
  input  wire                          [1:0]  expt_cpacr_el1_fpen_i,
  input  wire                                 expt_cpacr_asedis_i,
  input  wire                                 expt_cptr_el2_tfp_i,
  input  wire                                 expt_hcptr_tase_i,
  input  wire                                 expt_cptr_el2_tcpac_i,
  input  wire       [`CA53_RF_RD_NEED_W-1:0]  rf_rd_need_r0_de_i,
  input  wire       [`CA53_RF_RD_NEED_W-1:0]  rf_rd_need_r1_de_i,
  input  wire       [`CA53_RF_RD_NEED_W-1:0]  rf_rd_need_r2_de_i,
  input  wire       [`CA53_RF_RD_NEED_W-1:0]  rf_rd_need_r3_de_i,
  input  wire       [`CA53_RF_RD_NEED_W-1:0]  rf_rd_need_r4_de_i,
  input  wire       [`CA53_RF_WR_WHEN_W-1:0]  rf_wr_when_w0_de_i,
  input  wire       [`CA53_RF_WR_WHEN_W-1:0]  rf_wr_when_w1_de_i,
  input  wire       [`CA53_RF_WR_WHEN_W-1:0]  rf_wr_when_w2_de_i,
  input  wire                          [5:0]  rf_rd_addr_r0_de_i,
  input  wire                          [5:0]  rf_rd_addr_r1_de_i,
  input  wire                          [5:0]  rf_rd_addr_r2_de_i,
  input  wire                          [5:0]  rf_rd_addr_r3_de_i,
  input  wire                          [5:0]  rf_stm_rd_addr_r2_de_i,
  input  wire                          [5:0]  rf_stm_rd_addr_r3_de_i,
  input  wire                          [5:0]  rf_rd_addr_r4_de_i,
  input  wire                                 instr0_r2_enabled_de_i,
  input  wire                                 instr0_w0_enabled_de_i,
  input  wire                                 rf_rd_remap_de_i,
  input  wire [`CA53_SLOT1_INSTR_TYPE_W-1:0]  slot1_instr_type_de_i,
  input  wire                                 rf_rd_en_r0_de_i,
  input  wire                                 rf_rd_en_r1_de_i,
  input  wire                                 rf_rd_en_r2_de_i,
  input  wire                                 rf_rd_en_r3_de_i,
  input  wire                                 rf_rd_en_r4_de_i,
  input  wire                                 wd_align_pc_alu0_de_i,
  input  wire                                 wd_align_pc_alu1_de_i,
  input  wire                                 wd_align_pc_ls_de_i,
  input  wire                                 pg_align_pc_ls_de_i,
  input  wire                                 expt_rtn_ret_i,
  input  wire                                 cpsr_ssbit_ret_i,
  input  wire                                 cpsr_ilbit_ret_i,
  input  wire                                 cpsr_ibit_ret_i,
  input  wire                                 cpsr_fbit_ret_i,
  input  wire                                 cpsr_abit_ret_i,
  input  wire                          [4:0]  cpsr_mode_ret_i,
  input  wire                                 cc_pass_instr0_ex2_i,
  input  wire                                 cc_pass_instr0_cbz_ex2_i,
  input  wire                                 cc_pass_instr1_ex2_i,
  input  wire                                 cc_pass_instr1_early_ex2_i,
  input  wire                                 fp0_ccmp_fail_ex2_i,
  input  wire                                 fp1_ccmp_fail_ex2_i,
  input  wire                          [3:0]  fp_cflags_add0_f2_i,
  input  wire                          [3:0]  fp_cflags_add1_f2_i,
  input  wire                          [3:0]  cp_fpsr_cflags_i,
  input  wire                                 br_flush_wr_i,
  input  wire                                 slot0_br_flush_wr_i,
  input  wire                                 br_flush_ret_i,
  input  wire                                 dbg_hw_halt_req_i,
  input  wire                                 in_halt_i,
  input  wire                                 held_dbg_hw_halt_req_i,
  input  wire                                 held_dbg_osuc_halt_req_i,
  input  wire                                 held_dbg_ext_hw_halt_req_i,
  input  wire                                 dbg_soft_step_active_i,
  input  wire                                 dbg_halt_step_active_not_pend_i,
  input  wire                                 dbg_restart_qual_i,
  input  wire                                 dbg_cancel_biu_i,
  input  wire                                 ss_enter_halt_i,
  input  wire                                 sctlr_ns_hivecs_i,
  input  wire                                 sctlr_s_hivecs_i,
  input  wire                                 sctlr_ntwe_i,
  input  wire                                 sctlr_ntwi_i,
  input  wire                                 sctlr_cp15ben_i,
  input  wire                                 sctlr_sed_i,
  input  wire                                 sctlr_el1_uci_i,
  input  wire                                 sctlr_el1_uct_i,
  input  wire                                 sctlr_el1_uma_i,
  input  wire                                 sctlr_el1_dze_i,
  input  wire                          [3:1]  aarch64_at_el_i,
  input  wire                                 dbgdscr_halted_i,
  input  wire                          [1:0]  edscr_intdis_i,
  input  wire                                 dbgen_synced_i,
  input  wire                                 spiden_synced_i,
  input  wire                                 dbg_hlt_en_i,
  input  wire                                 dbg_bkpt_wpt_en_i,
  input  wire                                 gov_wfx_wake_i,
  input  wire                                 muls_in_de_i,
  input  wire                                 gic_fiq_i,
  input  wire                                 gic_irq_i,
  input  wire                                 gic_vfiq_i,
  input  wire                                 gic_virq_i,
  input  wire                                 gov_sei_level_req_i,
  input  wire                                 gov_vsei_level_req_i,
  input  wire                                 gov_rei_level_req_i,
  input  wire                                 gov_int_active_i,
  input  wire                                 dcu_valid_dc3_i,
  input  wire                                 dcu_p_abort_dc3_i,
  input  wire                          [3:0]  dcu_p_domain_dc3_i,
  input  wire                          [6:0]  dcu_p_fault_dc3_i,
  input  wire                          [1:0]  dcu_p_fault_stage_dc3_i,
  input  wire                                 dcu_p_direction_dc3_i,
  input  wire                                 dcu_ecc_err_dc3_i,
  input  wire                                 dcu_cm_operation_dc3_i,
  input  wire                         [39:12] dcu_pa_dc3_i,
  input  wire                         [63:0]  dcu_va_dc3_i,
  input  wire                                 dcu_v2p_lpae_dc3_i,
  input  wire                                 dcu_wpt_hit_dc3_i,
  input  wire                                 tlb_lpae_mode_i,
  input  wire                                 tlb_lpae_mode_s_i,
  input  wire                                 biu_w_imp_abort_i,
  input  wire                          [1:0]  biu_w_imp_fault_i,
  input  wire                                 dpu_fe_valid_wr_i,
  input  wire                                 dpu_fe_valid_ret_i,
  input  wire                                 incr_pc_halt_mode_ret_i,
  input  wire                                 paq_stall_iss_i,
  input  wire                                 br_x_bit_de_i,
  input  wire                                 ls_multiple_de_i,
  input  wire                                 ls_multiple_iss_i,
  input  wire                                 ls_store_iss_i,
  input  wire                                 ls_valid_iss_i,
  input  wire                                 ls_valid_ex1_i,
  input  wire                          [1:0]  ls_size_wr_i,
  input  wire                                 mac_stall_iss_i,
  input  wire                         [63:5]  cp_vbar_el3_i,
  input  wire                         [63:5]  cp_vbar_el1_i,
  input  wire                         [31:5]  cp_mvbar_i,
  input  wire                         [63:5]  cp_hvbar_i,
  input  wire                                 dbg_os_lock_synced_i,
  input  wire                                 dbg_double_lock_set_i,
  input  wire                          [3:0]  pmn_useren_i,
  input  wire                                 mdscr_el1_tdcc_i,
  input  wire                                 hdcr_tdra_i,
  input  wire                                 hdcr_tdosa_i,
  input  wire                                 hdcr_tda_i,
  input  wire                                 hdcr_tde_i,
  input  wire                                 hdcr_tpm_i,
  input  wire                                 hdcr_tpmcr_i,
  input  wire                                 mdcr_el3_tdosa_i,
  input  wire                                 mdcr_el3_tda_i,
  input  wire                                 mdcr_el3_tpm_i,
  input  wire                                 hcr_trvm_i,
  input  wire                                 hcr_tdz_i,
  input  wire                                 hcr_twi_i,
  input  wire                                 hcr_twe_i,
  input  wire                                 hcr_tvm_i,
  input  wire                                 hcr_tid0_i,
  input  wire                                 hcr_tid1_i,
  input  wire                                 hcr_tid2_i,
  input  wire                                 hcr_tid3_i,
  input  wire                                 hcr_tsc_i,
  input  wire                                 hcr_tidcp_i,
  input  wire                                 hcr_tacr_i,
  input  wire                                 hcr_tsw_i,
  input  wire                                 hcr_tpc_i,
  input  wire                                 hcr_tpu_i,
  input  wire                                 hcr_ttlb_i,
  input  wire                                 hcr_amo_i,
  input  wire                                 hcr_imo_i,
  input  wire                                 hcr_fmo_i,
  input  wire                                 hcr_tge_i,
  input  wire                                 hcr_va_i,
  input  wire                                 hcr_vi_i,
  input  wire                                 hcr_vf_i,
  input  wire                         [13:0]  hstr_trap_cp15_i,
  input  wire                                 cpuactlr_el3_i,
  input  wire                                 cpuectlr_el3_i,
  input  wire                                 l2ctlr_el3_i,
  input  wire                                 l2ectlr_el3_i,
  input  wire                                 l2actlr_el3_i,
  input  wire                                 cpuactlr_el2_i,
  input  wire                                 cpuectlr_el2_i,
  input  wire                                 l2ctlr_el2_i,
  input  wire                                 l2ectlr_el2_i,
  input  wire                                 l2actlr_el2_i,
  input  wire                                 cptr_el3_tcpac_i,
  input  wire                                 cptr_el3_tfp_i,
  input  wire                                 cp_fpexc_en_i,
  input  wire                                 scr_el3_twi_i,
  input  wire                                 scr_el3_twe_i,
  input  wire                                 scr_el3_st_i,
  input  wire                                 scr_el3_hce_i,
  input  wire                                 scr_el3_smd_i,
  input  wire                                 gov_cntkctl_el1_el0pcten_i,
  input  wire                                 gov_cntkctl_el1_el0vcten_i,
  input  wire                                 gov_cntkctl_el1_el0pten_i,
  input  wire                                 gov_cntkctl_el1_el0vten_i,
  input  wire                                 gov_cnthctl_el2_el1pcen_i,
  input  wire                                 gov_cnthctl_el2_el1pcten_i,
  input  wire                                 gic_icc_sre_el1_ns_sre_i,
  input  wire                                 gic_icc_sre_el1_s_sre_i,
  input  wire                                 gic_icc_sre_el2_enable_i,
  input  wire                                 gic_icc_sre_el2_sre_i,
  input  wire                                 gic_icc_sre_el3_enable_i,
  input  wire                                 gic_icc_sre_el3_sre_i,
  input  wire                                 gic_ich_hcr_el2_tall0_i,
  input  wire                                 gic_ich_hcr_el2_tall1_i,
  input  wire                                 gic_ich_hcr_el2_tc_i,
  input  wire                                 scr_ea_i,
  input  wire                                 scr_fiq_i,
  input  wire                                 scr_irq_i,
  input  wire                                 scr_aw_i,
  input  wire                                 scr_fw_i,
  input  wire                                 edscr_sdd_i,
  input  wire                                 edscr_tda_i,
  input  wire                                 nxt_ns_scr_i,
  input  wire                                 nxt_mon_el3_mode_ret_i,
  input  wire                          [6:0]  ifu_ifsr_i,
  input  wire                          [1:0]  ifu_ifsr_stage2_i,
  input  wire                                 ifu_ifsr_lpae_i,
  input  wire                         [31:1]  ifu_ifar_i,
  input  wire                         [27:0]  ifu_hpfar_i,
  input  wire                                 cp_icimvau_i,
  input  wire                                 gov_event_reg_i,
  input  wire                                 msr_mrs_reg_de_i,
  input  wire                                 msr_mrs_spsr_de_i,
  input  wire                          [5:0]  msr_mrs_data_de_i,
  input  wire    [`CA53_FLAGEN_INSTR1_W-1:0]  flag_en_instr1_de_i,
  input  wire                                 mrc_instr_ex1_i,
  input  wire                                 mrc_instr_ex2_i,
  input  wire                                 mrc_instr_wr_i,
  input  wire                                 dbg_halting_allowed_i,
  input  wire                                 cryptodisable_i,
  input  wire                         [12:0]  raw_imm_data_0_iss_i,
  input  wire                         [12:0]  raw_imm_data_1_iss_i,
  input  wire                                 nxt_pc_sample_perm_i,
  // Outputs
  output wire                                 interlock_iss_o,
  output wire                                 stall_ex1_o,
  output wire                                 stall_ex2_o,
  output wire                                 stall_wr_o,
  output wire                                 stall_iss_o,
  output wire                                 stall_slot0_iss_o,
  output wire                                 stall_br_iss_o,
  output wire                                 ilock_stall_iss_o,
  output wire                                 nxt_div_stall_wr_o,
  output wire                                 div_flush_o,
  output wire                                 advance_pipeline_o,
  output wire                                 flush_wr_o,
  output wire                                 flush_ls_wr_o,
  output wire                                 flush_ret_o,
  output wire                                 quash_iss_o,
  output wire                                 quash_ex1_o,
  output wire                                 quash_ex2_o,
  output wire                                 quash_wr_o,
  output wire                                 quash_slot0_wr_o,
  output wire                                 expt_quash_wr_o,
  output wire                                 dpu_flush_o,
  output wire                                 dpu_kill_wr_o,
  output wire                         [12:0]  fp0_imm_data_f1_o,
  output wire                         [12:0]  fp1_imm_data_f1_o,
  output wire                         [48:1]  pc_instr1_iss_o,
  output wire      [`CA53_MAC_ISS_CTL_W-1:0]  mac_iss_ctl_iss_o,
  output wire                                 ctl_64bit_op_mac_iss_o,
  output wire                                 ctl_64bit_op_alu1_iss_o,
  output wire                                 ctl_64bit_op_alu0_iss_o,
  output wire                                 alu0_msk_data_sel_iss_o,
  output wire                                 alu1_msk_data_sel_iss_o,
  output wire        [`CA53_SEL_SHF_A_W-1:0]  alu0_data_a_sel_iss_o,
  output wire        [`CA53_SEL_SHF_B_W-1:0]  alu0_data_b_sel_iss_o,
  output wire        [`CA53_SEL_SHF_C_W-1:0]  alu0_data_c_sel_iss_o,
  output wire        [`CA53_SEL_SHF_A_W-1:0]  alu1_data_a_sel_iss_o,
  output wire        [`CA53_SEL_SHF_B_W-1:0]  alu1_data_b_sel_iss_o,
  output wire        [`CA53_SEL_SHF_C_W-1:0]  alu1_data_c_sel_iss_o,
  output wire      [`CA53_ALU_EX1_CTL_W-1:0]  alu0_ex1_ctl_iss_o,
  output wire      [`CA53_ALU_EX2_CTL_W-1:0]  alu0_ex2_ctl_iss_o,
  output wire                                 alu0_wr_ctl_iss_o,
  output wire      [`CA53_ALU_EX1_CTL_W-1:0]  alu1_ex1_ctl_iss_o,
  output wire      [`CA53_ALU_EX2_CTL_W-1:0]  alu1_ex2_ctl_iss_o,
  output wire                                 alu1_wr_ctl_iss_o,
  output wire        [`CA53_SEL_MAC_A_W-1:0]  mac_data_a_sel_iss_o,
  output wire        [`CA53_SEL_MAC_B_W-1:0]  mac_data_b_sel_iss_o,
  output wire        [`CA53_SEL_DIV_A_W-1:0]  div_data_a_sel_iss_o,
  output wire        [`CA53_SEL_DIV_B_W-1:0]  div_data_b_sel_iss_o,
  output wire                          [3:0]  msr_mrs_data_wr_o,
  output wire        [`CA53_SEL_STR_A_W-1:0]  str0_data_a_sel_iss_o,
  output wire        [`CA53_SEL_STR_B_W-1:0]  str0_data_b_sel_iss_o,
  output wire        [`CA53_SEL_STR_A_W-1:0]  str1_data_a_sel_iss_o,
  output wire        [`CA53_SEL_STR_B_W-1:0]  str1_data_b_sel_iss_o,
  output wire                                 expt_mon_mode_clear_ns_o,
  output wire     [`CA53_FAULT_REG_EN_W-1:0]  expt_fault_reg_en_wr_o,
  output wire                                 expt_fault_reg_sel_wr_o,
  output wire                                 expt_aa32_uses_el1_esr_wr_o,
  output wire                         [12:0]  expt_ifsr_wr_o,
  output wire                         [12:0]  expt_dfsr_wr_o,
  output wire                          [3:0]  expt_status_moe_data_wr_o,
  output wire                                 expt_idle_o,
  output wire                          [1:0]  target_exception_level_o,
  output wire                         [63:0]  expt_far_data_wr_o,
  output wire                         [27:0]  expt_hpfar_data_wr_o,
  output wire                         [31:0]  expt_esr_data_wr_o,
  output wire                                 clear_virtual_ea_o,
  output wire                                 nxt_wfx_ifu_halt_o,
  output wire                                 wfx_ifu_halt_o,
  output wire                                 force_wfx_nop_o,
  output wire                                 issue_to_iss_o,
  output wire                                 issue_to_iss_fpu_o,
  output wire                                 issue_to_ex1_o,
  output wire                                 issue_to_ex2_o,
  output wire                                 issue_to_ex2_fpu_o,
  output wire                                 issue_to_wr_o,
  output wire                                 issue_to_f4_o,
  output wire                                 sel_mac_nzflags_wr_o,
  output wire                          [1:0]  isa_instr0_iss_o,
  output wire                                 instr0_de_pc_in_iss_o,
  output wire                                 prefetch_abort_iss_o,
  output wire                                 size_instr0_iss_o,
  output wire                                 size_instr1_iss_o,
  output wire                         [63:0]  pc_instr0_iss_o,
  output wire                                 thumb_instr0_iss_o,
  output wire                                 br_x_bit_iss_o,
  output wire                                 use_ex1_alu_0_iss_o,
  output wire                                 use_ex1_alu_1_iss_o,
  output wire                                 raw_alu0_valid_iss_o,
  output wire                                 raw_alu1_valid_iss_o,
  output wire                                 alu0_valid_iss_o,
  output wire                                 alu1_valid_iss_o,
  output wire                                 raw_str0_valid_iss_o,
  output wire                                 str0_a_valid_iss_o,
  output wire                                 str0_b_valid_iss_o,
  output wire                                 ctl_64bit_op_str0_iss_o,
  output wire                                 raw_str1_valid_iss_o,
  output wire                                 str1_a_valid_iss_o,
  output wire                                 str1_b_valid_iss_o,
  output wire                                 ctl_64bit_op_str1_iss_o,
  output wire                                 raw_mac_valid_iss_o,
  output wire                                 mac_valid_iss_o,
  output wire                                 div_valid_iss_o,
  output wire                                 raw_div_valid_iss_o,
  output wire     [`CA53_LONG_RF_ADDR_W-1:0]  long_rf_rd_addr_r2_iss_o,
  output wire     [`CA53_LONG_RF_ADDR_W-1:0]  long_rf_rd_addr_r3_iss_o,
  output wire     [`CA53_LONG_RF_ADDR_W-1:0]  long_rf_rd_addr_r4_iss_o,
  output wire                                 wd_align_pc_alu0_iss_o,
  output wire                                 wd_align_pc_alu1_iss_o,
  output wire                                 wd_align_pc_ls_iss_o,
  output wire                                 pg_align_pc_ls_iss_o,
  output wire                          [5:0]  rf_wr_addr_w0_wr_o,
  output wire                          [5:0]  rf_wr_addr_w1_wr_o,
  output wire                          [5:0]  rf_wr_addr_w2_wr_o,
  output wire                                 sel_rf_wr_w0_wr_o,
  output wire                                 sel_rf_wr_w1_wr_o,
  output wire                                 sel_rf_wr_w2_wr_o,
  output wire                                 rf_wr_en_hi_wr_o,
  output wire                                 rf_wr_en_lo_wr_o,
  output wire                                 rf_wr_en_w0_wr_o,
  output wire                                 rf_wr_en_w1_wr_o,
  output wire                                 rf_wr_en_w2_wr_o,
  output wire                                 aarch64_state_iss_o,
  output wire                                 rf_wr_64b_w0_wr_o,
  output wire                                 rf_wr_64b_w1_wr_o,
  output wire                                 rf_wr_64b_w2_wr_o,
  output wire     [`CA53_RF_WR_SRC_W0_W-1:0]  rf_wr_src_w0_wr_o,
  output wire     [`CA53_RF_WR_SRC_W1_W-1:0]  rf_wr_src_w1_wr_o,
  output wire     [`CA53_RF_WR_SRC_W2_W-1:0]  rf_wr_src_w2_wr_o,
  output wire                          [1:0]  rf_rd_en_fr0_iss_o,
  output wire                          [1:0]  rf_rd_en_fr1_iss_o,
  output wire                          [1:0]  rf_rd_en_fr2_iss_o,
  output wire                          [1:0]  rf_rd_en_fr3_iss_o,
  output wire                          [1:0]  rf_rd_en_fr4_iss_o,
  output wire                          [1:0]  rf_rd_en_fr5_iss_o,
  output wire                          [1:0]  rf_rd_en_fr0_ex1_o,
  output wire                          [1:0]  rf_rd_en_fr1_ex1_o,
  output wire                          [1:0]  rf_rd_en_fr2_ex1_o,
  output wire                          [1:0]  rf_rd_en_fr3_ex1_o,
  output wire                          [1:0]  rf_rd_en_fr4_ex1_o,
  output wire                          [1:0]  rf_rd_en_fr5_ex1_o,
  output wire                          [1:0]  rf_rd_en_fr0_ex2_o,
  output wire                          [1:0]  rf_rd_en_fr1_ex2_o,
  output wire                          [1:0]  rf_rd_en_fr2_ex2_o,
  output wire                          [1:0]  rf_rd_en_fr3_ex2_o,
  output wire                          [1:0]  rf_rd_en_fr4_ex2_o,
  output wire                          [1:0]  rf_rd_en_fr5_ex2_o,
  output wire    [`CA53_FP_RF_RD_ADDR_W-1:0]  rf_rd_addr_fr0_iss_o,
  output wire    [`CA53_FP_RF_RD_ADDR_W-1:0]  rf_rd_addr_fr1_iss_o,
  output wire    [`CA53_FP_RF_RD_ADDR_W-1:0]  rf_rd_addr_fr2_iss_o,
  output wire    [`CA53_FP_RF_RD_ADDR_W-1:0]  rf_rd_addr_fr3_iss_o,
  output wire    [`CA53_FP_RF_RD_ADDR_W-1:0]  rf_rd_addr_fr4_iss_o,
  output wire    [`CA53_FP_RF_RD_ADDR_W-1:0]  rf_rd_addr_fr5_iss_o,
  output wire                                 rf_wr_en_fw_f3_o,
  output wire                                 rf_wr_en_fw_f5_o,
  output wire                          [3:0]  rf_wr_en_fw0_f5_o,
  output wire                          [3:0]  rf_wr_en_fw1_f5_o,
  output wire    [`CA53_FP_RF_WR_ADDR_W-1:0]  rf_wr_addr_fw0_f5_o,
  output wire    [`CA53_FP_RF_WR_ADDR_W-1:0]  rf_wr_addr_fw1_f5_o,
  output wire       [`CA53_RF_FWR_SRC_W-1:0]  rf_wr_src_fw0_f3_o,
  output wire       [`CA53_RF_FWR_SRC_W-1:0]  rf_wr_src_fw0_f4_o,
  output wire       [`CA53_RF_FWR_SRC_W-1:0]  rf_wr_src_fw0_f5_o,
  output wire       [`CA53_RF_FWR_SRC_W-1:0]  rf_wr_src_fw1_f3_o,
  output wire       [`CA53_RF_FWR_SRC_W-1:0]  rf_wr_src_fw1_f4_o,
  output wire       [`CA53_RF_FWR_SRC_W-1:0]  rf_wr_src_fw1_f5_o,
  output wire      [`CA53_RF_FWR_WHEN_W-1:0]  rf_wr_when_fw0_f4_o,
  output wire      [`CA53_RF_FWR_WHEN_W-1:0]  rf_wr_when_fw1_f4_o,
  output wire     [`CA53_FP_CFLAG_SRC_W-1:0]  fp0_cflag_src_f5_o,
  output wire     [`CA53_FP_CFLAG_SRC_W-1:0]  fp1_cflag_src_f5_o,
  output wire     [`CA53_FP_XFLAG_SRC_W-1:0]  fp0_xflag_src_f5_o,
  output wire     [`CA53_FP_XFLAG_SRC_W-1:0]  fp1_xflag_src_f5_o,
  output wire                          [5:0]  fr0_fwd_ex1_o,
  output wire                          [5:0]  fr1_fwd_ex1_o,
  output wire                          [5:0]  fr2_fwd_ex1_o,
  output wire                          [5:0]  fr3_fwd_ex1_o,
  output wire                          [5:0]  fr4_fwd_ex1_o,
  output wire                          [5:0]  fr5_fwd_ex1_o,
  output wire                          [5:0]  fr0_fwd_ex2_o,
  output wire                          [5:0]  fr1_fwd_ex2_o,
  output wire                          [5:0]  fr2_fwd_ex2_o,
  output wire                          [5:0]  fr3_fwd_ex2_o,
  output wire                          [5:0]  fr4_fwd_ex2_o,
  output wire                          [5:0]  fr5_fwd_ex2_o,
  output wire                          [1:0]  fp_mul_fwd_ex2_o,
  output wire                          [1:0]  str0_sel_fp_f1_o,
  output wire                          [1:0]  str1_sel_fp_f1_o,
  output wire                          [1:0]  str0_sel_fp_f2_o,
  output wire                          [1:0]  str1_sel_fp_f2_o,
  output wire                                 ctl_fp_dp_en_o,
  output wire                                 dpu_neon_active_o,
  output wire       [`CA53_FP_EX_PIPE_W-1:0]  fp_ex_pipe_iss_o,
  output wire       [`CA53_FP_EX_PIPE_W-1:0]  fp_ex_pipe_f1_o,
  output wire                                 crypto_enable_iss_o,
  output wire                                 crypto_enable_f1_o,
  output wire       [`CA53_FP_PIPECTL_W-1:0]  fp0_pipectl_f1_o,
  output wire       [`CA53_FP_PIPECTL_W-1:0]  fp1_pipectl_f1_o,
  output wire                          [1:0]  fp_div_enb_ex1_o,
  output wire                          [1:0]  fp_div_active_o,
  output wire                          [1:0]  instr_fmstat_ex2_o,
  output wire                          [3:0]  fp_fwd_cflags_ex2_o,
  output wire                          [3:0]  fp_cflags_add0_f5_o,
  output wire                          [3:0]  fp_cflags_add1_f5_o,
  output wire                                 instr_is_cp10_cp11_wr_o,
  output wire     [`CA53_NEON_VLD_CTL_W-1:0]  neon_vld_ctl_f2_o,
  output wire     [`CA53_NEON_VLD_CTL_W-1:0]  neon_vld_ctl_f3_o,
  output wire        [`CA53_SEL_FAD_A_W-1:0]  sel_fad0_a_f1_o,
  output wire        [`CA53_SEL_FAD_B_W-1:0]  sel_fad0_b_f1_o,
  output wire        [`CA53_SEL_FAD_C_W-1:0]  sel_fad0_c_f1_o,
  output wire        [`CA53_SEL_FAD_A_W-1:0]  sel_fad1_a_f1_o,
  output wire        [`CA53_SEL_FAD_B_W-1:0]  sel_fad1_b_f1_o,
  output wire        [`CA53_SEL_FAD_C_W-1:0]  sel_fad1_c_f1_o,
  output wire                                 sel_fml0_a_f1_o,
  output wire        [`CA53_SEL_FML_B_W-1:0]  sel_fml0_b_f1_o,
  output wire                                 sel_fml0_c_f1_o,
  output wire                                 sel_fml1_a_f1_o,
  output wire        [`CA53_SEL_FML_B_W-1:0]  sel_fml1_b_f1_o,
  output wire                                 sel_fml1_c_f1_o,
  output wire                          [1:0]  valid_instrs_iss_o,
  output wire                                 head_instr_ls_iss_o,
  output wire                                 end_instr_iss_o,
  output wire                                 end_instr_wr_o,
  output wire                                 pre_end_instr_wr_o,
  output wire                                 end_instr_no_quash_wr_o,
  output wire                                 end_instr_dbg_wr_o,
  output wire                                 ls_conditional_iss_o,
  output wire                                 isb_wr_o,
  output wire                                 pre_valid_instrs_wr_o,
  output wire                          [1:0]  valid_instrs_wr_o,
  output reg                           [3:0]  dpu_dbg_vid_o,
  output reg                                  pc_sample_perm_o,
  output wire                         [63:0]  pc_instr0_ret_o,
  output wire                         [48:1]  pc_instr0_ex2_o,
  output wire                         [63:0]  pc_instr0_wr_o,
  output wire                                 save_base_ex2_o,
  output wire                          [3:0]  cond_code_instr0_ex2_o,
  output wire                          [3:0]  cond_code_instr1_ex2_o,
  output wire                                 cc_pass_instr0_wr_o,
  output wire                                 cc_pass_instr1_wr_o,
  output wire                                 size_instr0_wr_o,
  output wire                                 size_instr1_wr_o,
  output wire                                 size_instr0_ret_o,
  output wire                                 size_instr1_ret_o,
  output wire                                 expt_slot1_ret_o,
  output wire                          [1:0]  isa_instr0_wr_o,
  output wire        [`CA53_EXPT_TYPE_W-1:0]  expt_type_o,
  output wire                                 expt_type_l1_ecc_o,
  output wire              [`CA53_FWD_W-1:0]  r0_fwd_iss_o,
  output wire              [`CA53_FWD_W-1:0]  r1_fwd_iss_o,
  output wire              [`CA53_FWD_W-1:0]  r2_fwd_iss_o,
  output wire              [`CA53_FWD_W-1:0]  r3_fwd_iss_o,
  output wire              [`CA53_FWD_W-1:0]  r4_fwd_iss_o,
  output wire                                 slot1_ls_ex2_o,
  output wire                                 slot1_branch_iss_o,
  output wire                                 slot1_branch_ex2_o,
  output wire                                 slot1_branch_wr_o,
  output wire                                 slot1_blx_ex2_o,
  output wire                                 slot1_bx_wr_o,
  output wire                                 slot1_blx_wr_o,
  output wire                                 slot1_mul_iss_o,
  output wire                                 slot1_mul_wr_o,
  output wire                                 w0_slot1_wr_o,
  output wire              [`CA53_FWD_W-1:0]  alu0_a_fwd_ex1_o,
  output wire              [`CA53_FWD_W-1:0]  alu0_b_fwd_ex1_o,
  output wire              [`CA53_FWD_W-1:0]  str0_a_fwd_ex1_o,
  output wire              [`CA53_FWD_W-1:0]  str0_b_fwd_ex1_o,
  output wire              [`CA53_FWD_W-1:0]  str1_a_fwd_ex1_o,
  output wire              [`CA53_FWD_W-1:0]  str1_b_fwd_ex1_o,
  output wire              [`CA53_FWD_W-1:0]  alu1_a_fwd_ex1_o,
  output wire              [`CA53_FWD_W-1:0]  alu1_b_fwd_ex1_o,
  output wire              [`CA53_FWD_W-1:0]  str0_a_fwd_ex2_o,
  output wire              [`CA53_FWD_W-1:0]  str0_b_fwd_ex2_o,
  output wire              [`CA53_FWD_W-1:0]  str1_a_fwd_ex2_o,
  output wire              [`CA53_FWD_W-1:0]  str1_b_fwd_ex2_o,
  output wire                          [5:0]  mac_fwd_ctl_ex1_o,
  output reg       [`CA53_SEL_FWD_DCU_W-1:0]  sel_fwd_dcu_a_iss_o,
  output reg       [`CA53_SEL_FWD_DCU_W-1:0]  sel_fwd_dcu_b_iss_o,
  output wire                                 sel_fwd_addr_dcu_a_iss_o,
  output wire                          [2:0]  rf_rd_r0_agu_de_o,
  output wire                          [2:0]  rf_rd_r1_agu_de_o,
  output wire                                 en_rf_rd_r0_agu_de_o,
  output wire                                 en_rf_rd_r1_agu_de_o,
  output wire                                 insert_forceop_wr_o,
  output wire                         [63:0]  forceop_pc_ret_o,
  output wire      [`CA53_SEL_CPSR_EN_W-1:0]  expt_cpsr_wr_en_ret_o,
  output wire     [`CA53_SEL_CPSR_SRC_W-1:0]  expt_cpsr_wr_src_ret_o,
  output wire                          [4:0]  expt_cpsr_mode_ret_o,
  output wire                                 forceop_valid_de_o,
  output wire                                 forceop_valid_iss_o,
  output wire                                 forceop_valid_wr_o,
  output wire                                 dbg_halt_ecc_expt_iss_o,
  output wire     [`CA53_FORCEOP_TYPE_W-1:0]  forceop_type_o,
  output wire   [`CA53_FORCEOP_OFFSET_W-1:0]  forceop_offset_o,
  output wire                                 forceop_aa64_o,
  output wire                                 insert_forceop_ret_o,
  output wire                                 etm_trace_expt_o,
  output wire                                 etm_trace_dbgentry_o,
  output wire                                 expt_dbgexit_o,
  output wire                                 expt_slot1_wr_o,
  output wire                         [17:1]  forceop_pc_offset_ret_o,
  output wire                          [1:0]  isa_instr0_ret_o,
  output wire                                 thumb_instr0_ret_o,
  output wire                                 thumb_instr1_ret_o,
  output wire                          [1:0]  isa_instr0_ex2_o,
  output wire                                 size_instr0_ex2_o,
  output wire                                 size_instr1_ex2_o,
  output reg                                  dpu_halt_ifu_o,
  output wire                                 expt_in_halt_o,
  output wire                                 end_expt_in_halt_o,
  output wire                                 dbg_event_o,
  output wire                                 dbg_event_halt_wr_o,
  output wire                                 dbg_ss_vld_expt_type_ret_o,
  output wire                                 dbg_expt_o,
  output wire                                 evnt_expt_taken_o,
  output wire                                 evnt_call_expt_taken_o,
  output wire                          [1:0]  evnt_instr_exec_o,
  output wire                                 evnt_fpu_interlock_iss_o,
  output wire                                 evnt_agu_interlock_iss_o,
  output wire                                 evnt_ls_instr_wr_o,
  output wire                                 ns_state_o,
  output reg                                  dpu_sev_req_o,
  output reg                                  dpu_clr_event_register_o,
  output reg                                  dpu_wfi_req_o,
  output reg                                  dpu_wfe_req_o,
  output wire                                 expt_serr_pending_o,
  output wire                                 expt_irq_pending_o,
  output wire                                 expt_fiq_pending_o,
  output wire                                 evnt_fiq_taken_o,
  output wire                                 evnt_irq_taken_o,
  output wire                                 dpu_irq_pended_o,
  output wire                                 dpu_fiq_pended_o,
  output wire                                 dpu_sei_pended_o,
  output wire                                 dpu_irq_masked_o,
  output wire                                 dpu_fiq_masked_o,
  output wire                                 dpu_sei_masked_o,
  output wire                                 dpu_virq_pended_o,
  output wire                                 dpu_vfiq_pended_o,
  output wire                                 dpu_vsei_pended_o,
  output wire                                 dpu_virq_masked_o,
  output wire                                 dpu_vfiq_masked_o,
  output wire                                 dpu_vsei_masked_o,
  output wire                                 dpu_rei_level_ack_o,
  output wire                                 dpu_sei_level_ack_o,
  output wire                                 dpu_vsei_level_ack_o,
  output wire                                 dpu_imp_abort_pending_o,
  output wire                                 no_interrupt_wr_o,
  output wire    [`CA53_FLAGEN_INSTR1_W-1:0]  flag_en_instr1_wr_o,
  output wire                                 rf_wr_en_w0_iss_o,
  output wire                                 rf_wr_en_w1_iss_o,
  output wire                                 rf_wr_en_w2_iss_o,
  output wire                          [1:0]  rf_wr_when_w0_iss_o,
  output wire                          [1:0]  rf_wr_when_w1_iss_o,
  output wire                          [1:0]  rf_wr_when_w2_iss_o,
  output wire                          [4:0]  rf_wr_vaddr_w0_iss_o,
  output wire                          [4:0]  rf_wr_vaddr_w1_iss_o,
  output wire                          [4:0]  rf_wr_vaddr_w2_iss_o,
  output wire                                 rf_wr_en_w0_ex1_o,
  output wire                                 rf_wr_en_w1_ex1_o,
  output wire                                 rf_wr_en_w2_ex1_o,
  output wire                          [1:0]  rf_wr_when_w0_ex1_o,
  output wire                          [1:0]  rf_wr_when_w1_ex1_o,
  output wire                          [1:0]  rf_wr_when_w2_ex1_o,
  output wire                          [4:0]  rf_wr_vaddr_w0_ex1_o,
  output wire                          [4:0]  rf_wr_vaddr_w1_ex1_o,
  output wire                          [4:0]  rf_wr_vaddr_w2_ex1_o,
  output wire                          [3:0]  rf_wr_en_fw0_iss_o,
  output wire                          [3:0]  rf_wr_en_fw1_iss_o,
  output wire                          [3:0]  rf_wr_en_fw0_f1_o,
  output wire                          [3:0]  rf_wr_en_fw1_f1_o,
  output wire                          [3:0]  rf_wr_en_fw0_f2_o,
  output wire                          [3:0]  rf_wr_en_fw1_f2_o,
  output wire                          [1:0]  rf_wr_when_fw0_iss_o,
  output wire                          [1:0]  rf_wr_when_fw1_iss_o,
  output wire                          [1:0]  rf_wr_when_fw0_f1_o,
  output wire                          [1:0]  rf_wr_when_fw1_f1_o,
  output wire                          [1:0]  rf_wr_when_fw0_f2_o,
  output wire                          [1:0]  rf_wr_when_fw1_f2_o,
  output wire                          [5:0]  rf_wr_addr_fw0_iss_o,
  output wire                          [5:0]  rf_wr_addr_fw1_iss_o,
  output wire                          [5:0]  rf_wr_addr_fw0_f1_o,
  output wire                          [5:0]  rf_wr_addr_fw1_f1_o,
  output wire                          [5:0]  rf_wr_addr_fw0_f2_o,
  output wire                          [5:0]  rf_wr_addr_fw1_f2_o,
  output wire                                 exception_valid_iss_o,
  output wire                                 exception_valid_ex1_o
);

  // -----------------------------
  // Constant declarations
  // -----------------------------

  localparam WHR_ISS = 3;
  localparam WHR_EX1 = 2;
  localparam WHR_EX2 = 1;
  localparam WHR_WR  = 0;

  localparam WHN_NOT_EX1  = 0;
  localparam WHN_NOT_EX2  = 1;
  localparam WHN_NOT_E_WR = 2;

  // Bit positions for read and write ports in address comparison arrays
  // - different values are used for the read and write port indices to
  // prevent them accidentally being interchanged
  localparam R1 = 4;
  localparam R0 = 3;
  localparam W2 = 2;
  localparam W1 = 1;
  localparam W0 = 0;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                                       size_instr0_iss;
  reg                                       size_instr1_iss;
  reg                                       thumb_instr0_iss;
  reg                                       thumb_instr1_iss;
  reg                           [1:0]       valid_instrs_iss;
  reg                          [63:0]       pc_instr0_iss;
  reg                           [3:0]       dsize_msr_mrs_data;
  reg                                       msr_mrs_reg_iss;
  reg                                       msr_mrs_spsr_iss;
  reg                           [5:0]       msr_mrs_data_iss;
  reg                           [3:0]       msr_mrs_data_ex1;
  reg                           [3:0]       msr_mrs_data_ex2;
  reg                           [3:0]       msr_mrs_data_wr;
  reg                           [4:0]       rf_wr_vaddr_w0_iss;
  reg                           [4:0]       rf_wr_vaddr_w1_iss;
  reg                           [4:0]       rf_wr_vaddr_w2_iss;
  reg                           [4:0]       rf_wr_vaddr_w0_ex1;
  reg                           [4:0]       rf_wr_vaddr_w1_ex1;
  reg                           [4:0]       rf_wr_vaddr_w2_ex1;
  reg      [`CA53_RF_WR_SRC_W0_W-1:0]       rf_wr_src_w0_iss;
  reg      [`CA53_RF_WR_SRC_W1_W-1:0]       rf_wr_src_w1_iss;
  reg      [`CA53_RF_WR_SRC_W2_W-1:0]       rf_wr_src_w2_iss;
  reg                                       raw_rf_wr_en_w0_iss;
  reg                                       raw_rf_wr_en_w1_iss;
  reg                                       raw_rf_wr_en_w2_iss;
  reg                                       rf_wr_64b_w0_iss;
  reg                                       rf_wr_64b_w1_iss;
  reg                                       rf_wr_64b_w2_iss;
  reg                                       wd_align_pc_alu0_iss;
  reg                                       wd_align_pc_alu1_iss;
  reg                                       wd_align_pc_ls_iss;
  reg                                       pg_align_pc_ls_iss;
  reg                                       usr_mode_regs_ldm_iss;
  reg                          [W2:W0]      early_addr_cmp_iss_ex2     [R1:R0];
  reg                          [W2:W0]      early_addr_cmp_iss_wr      [R1:R0];
  reg                          [W2:W1]      early_addr_cmp_agu_iss_ex2 [R1:R0];
  reg                                       raw_sel_fwd_addr_dcu_a_iss;
  reg                           [3:0]       cond_code_instr0_iss;
  reg                           [3:0]       cond_code_instr1_iss;
  reg       [`CA53_ALU_PIPECTL_W-1:0]       alu0_pipectl_iss;
  reg       [`CA53_ALU_PIPECTL_W-1:0]       alu1_pipectl_iss;
  reg       [`CA53_MAC_PIPECTL_W-1:0]       mac_pipectl_iss;
  reg                                       alu0_msk_data_sel_iss;
  reg                                       alu1_msk_data_sel_iss;
  reg         [`CA53_SEL_SHF_A_W-1:0]       alu0_data_a_sel_iss;
  reg         [`CA53_SEL_SHF_B_W-1:0]       alu0_data_b_sel_iss;
  reg         [`CA53_SEL_SHF_C_W-1:0]       alu0_data_c_sel_iss;
  reg         [`CA53_SEL_SHF_A_W-1:0]       alu1_data_a_sel_iss;
  reg         [`CA53_SEL_SHF_B_W-1:0]       alu1_data_b_sel_iss;
  reg         [`CA53_SEL_SHF_C_W-1:0]       alu1_data_c_sel_iss;
  reg         [`CA53_SEL_MAC_A_W-1:0]       mac_data_a_sel_iss;
  reg         [`CA53_SEL_MAC_B_W-1:0]       mac_data_b_sel_iss;
  reg         [`CA53_SEL_DIV_A_W-1:0]       div_data_a_sel_iss;
  reg         [`CA53_SEL_DIV_B_W-1:0]       div_data_b_sel_iss;
  reg         [`CA53_SEL_STR_A_W-1:0]       raw_str0_data_a_sel_iss;
  reg         [`CA53_SEL_STR_B_W-1:0]       raw_str0_data_b_sel_iss;
  reg                                       raw_str0_b_valid_iss;
  reg                                       ctl_64bit_op_str0_iss;
  reg         [`CA53_SEL_STR_A_W-1:0]       str1_data_a_sel_iss;
  reg         [`CA53_SEL_STR_B_W-1:0]       str1_data_b_sel_iss;
  reg                                       raw_str1_b_valid_iss;
  reg                                       ctl_64bit_op_str1_iss;
  reg                                       use_ex1_alu_0_iss;
  reg                                       use_ex1_alu_1_iss;
  reg                                       aarch64_state_iss;
  reg                                       raw_alu0_valid_iss;
  reg                                       raw_alu1_valid_iss;
  reg                                       raw_str0_valid_iss;
  reg                                       raw_str1_valid_iss;
  reg                                       raw_mac_valid_iss;
  reg                                       raw_div_valid_iss;
  reg        [`CA53_INSTR_TYPE_W-1:0]       instr_type_iss;
  reg                           [5:0]       rf_rd_addr_r0_iss;
  reg                           [5:0]       rf_rd_addr_r1_iss;
  reg                           [5:0]       rf_rd_addr_r4_iss;
  reg                                       held_rf_rd_en_r3_iss;
  reg         [`CA53_SEL_STR_B_W-1:0]       held_str0_data_b_sel_iss;
  reg                                       held_str0_b_valid_iss;
  reg                           [5:0]       held_rf_wr_addr_w2_iss;
  reg                                       held_rf_wr_en_w2_iss;
  reg                                       held_rf_wr_64b_w2_iss;
  reg                                       raw_rf_rd_en_r0_iss;
  reg                                       raw_rf_rd_en_r1_iss;
  reg                                       raw_rf_rd_en_r2_iss;
  reg                                       raw_rf_rd_en_r3_iss;
  reg                                       raw_rf_rd_en_r4_iss;
  reg        [`CA53_RF_RD_NEED_W-1:0]       rf_rd_need_r0_iss;
  reg        [`CA53_RF_RD_NEED_W-1:0]       rf_rd_need_r1_iss;
  reg        [`CA53_RF_RD_NEED_W-1:0]       rf_rd_need_r2_iss;
  reg        [`CA53_RF_RD_NEED_W-1:0]       rf_rd_need_r3_iss;
  reg        [`CA53_RF_RD_NEED_W-1:0]       rf_rd_need_r4_iss;
  reg                                       rf_rd_remap_iss;
  reg                                       instr0_r2_enabled_iss;
  reg                                       instr0_w0_enabled_iss;
  reg        [`CA53_RF_WR_WHEN_W-1:0]       rf_wr_when_w0_iss;
  reg        [`CA53_RF_WR_WHEN_W-1:0]       rf_wr_when_w1_iss;
  reg        [`CA53_RF_WR_WHEN_W-1:0]       raw_rf_wr_when_w2_iss;
  reg                                       alu0_flagset_ex1;
  reg                                       alu0_flagset_ex2;
  reg                                       alu1_flagset_ex1;
  reg                                       alu1_flagset_ex2;
  reg                                       no_interrupt_iss;
  reg                                       enable_base_restore_ex1;
  reg                                       enable_base_restore_ex2;
  reg                                       enable_base_restore_wr;
  reg                                       en_restore;
  reg                           [1:0]       valid_instrs_ex1;
  reg                          [48:1]       pc_instr0_ex1;
  reg                                       no_interrupt_ex1;
  reg                           [5:0]       rf_wr_addr_w0_ex1;
  reg                           [5:0]       rf_wr_addr_w1_ex1;
  reg                           [5:0]       rf_wr_addr_w2_ex1;
  reg      [`CA53_RF_WR_SRC_W0_W-1:0]       rf_wr_src_w0_ex1;
  reg      [`CA53_RF_WR_SRC_W1_W-1:0]       rf_wr_src_w1_ex1;
  reg      [`CA53_RF_WR_SRC_W2_W-1:0]       rf_wr_src_w2_ex1;
  reg                                       raw_rf_wr_en_w0_ex1;
  reg                                       raw_rf_wr_en_w1_ex1;
  reg                                       raw_rf_wr_en_w2_ex1;
  reg                                       raw_rf_wr_en_w1_no_x64_ex1;
  reg                                       rf_wr_64b_w0_ex1;
  reg                                       rf_wr_64b_w1_ex1;
  reg                                       rf_wr_64b_w2_ex1;
  reg                           [5:0]       rf_rd_addr_r0_ex1;
  reg                           [5:0]       base_reg_number_ex2;
  reg                           [5:0]       base_reg_number_wr;
  reg                           [3:0]       cond_code_instr0_ex1;
  reg                           [3:0]       cond_code_instr1_ex1;
  reg                                       size_instr0_ex1;
  reg                                       size_instr1_ex1;
  reg                                       thumb_instr0_ex1;
  reg                                       thumb_instr1_ex1;
  reg                                       forceop_valid_iss;
  reg                                       dbg_halt_ecc_expt_iss;
  reg     [`CA53_FLAGEN_INSTR1_W-1:0]       flag_en_instr1_iss;
  reg     [`CA53_FLAGEN_INSTR1_W-1:0]       flag_en_instr1_ex1;
  reg     [`CA53_FLAGEN_INSTR1_W-1:0]       flag_en_instr1_ex2;
  reg     [`CA53_FLAGEN_INSTR1_W-1:0]       flag_en_instr1_wr;
  reg                           [1:0]       valid_instrs_ex2;
  reg                          [48:1]       pc_instr0_ex2;
  reg                                       no_interrupt_ex2;
  reg                           [5:0]       rf_wr_addr_w0_ex2;
  reg                           [5:0]       rf_wr_addr_w1_ex2;
  reg                           [5:0]       rf_wr_addr_w2_ex2;
  reg      [`CA53_RF_WR_SRC_W0_W-1:0]       rf_wr_src_w0_ex2;
  reg      [`CA53_RF_WR_SRC_W1_W-1:0]       rf_wr_src_w1_ex2;
  reg      [`CA53_RF_WR_SRC_W2_W-1:0]       rf_wr_src_w2_ex2;
  reg                                       raw_rf_wr_en_w0_ex2;
  reg                                       raw_rf_wr_en_w1_ex2;
  reg                                       raw_rf_wr_en_w2_ex2;
  reg                                       rf_wr_64b_w0_ex2;
  reg                                       rf_wr_64b_w1_ex2;
  reg                                       rf_wr_64b_w2_ex2;
  reg                           [3:0]       cond_code_instr0_ex2;
  reg                           [3:0]       cond_code_instr1_ex2;
  reg                                       size_instr0_ex2;
  reg                                       size_instr1_ex2;
  reg                                       thumb_instr0_ex2;
  reg                                       thumb_instr1_ex2;
  reg                           [1:0]       pre_valid_instrs_wr;
  reg                          [48:1]       raw_pc_instr0_wr;
  reg                                       no_interrupt_dp_wr;
  reg                                       no_interrupt_ls_wr;
  reg                           [5:0]       raw_rf_wr_addr_w0_wr;
  reg                           [5:0]       rf_wr_addr_w1_wr;
  reg                           [5:0]       rf_wr_addr_w2_wr;
  reg      [`CA53_RF_WR_SRC_W0_W-1:0]       raw_rf_wr_src_w0_wr;
  reg      [`CA53_RF_WR_SRC_W1_W-1:0]       rf_wr_src_w1_wr;
  reg      [`CA53_RF_WR_SRC_W2_W-1:0]       rf_wr_src_w2_wr;
  reg                                       raw_rf_wr_en_w0_wr;
  reg                                       raw_rf_wr_en_w0_nohz_wr;
  reg                                       raw_rf_wr_en_w1_wr;
  reg                                       raw_rf_wr_en_w1_nohz_wr;
  reg                                       raw_rf_wr_en_w2_wr;
  reg                                       raw_rf_wr_64b_w0_wr;
  reg                                       rf_wr_64b_w1_wr;
  reg                                       rf_wr_64b_w2_wr;
  reg                                       rf_wr_en_hi_wr;
  reg                                       rf_wr_en_lo_wr;
  reg                                       size_instr0_wr;
  reg                                       size_instr1_wr;
  reg                                       thumb_instr0_wr;
  reg                                       thumb_instr1_wr;
  reg                                       size_instr0_ret;
  reg                                       size_instr1_ret;
  reg                           [1:0]       isa_instr0_ret;
  reg                                       thumb_instr1_ret;
  reg                                       expt_slot1_ret;
  reg                                       instr0_de_pc_in_iss;
  reg                          [48:1]       raw_pc_instr0_ret;
  reg                                       mod_pc_top_bits_iss;
  reg                                       mod_pc_top_bits_ex1;
  reg                                       mod_pc_top_bits_ex2;
  reg                                       mod_pc_top_bits_wr;
  reg                                       full_pc_ex1;
  reg                                       full_pc_ex2;
  reg                                       full_pc_wr;
  reg                                       full_pc_ret;
  reg                                       muls_in_iss;
  reg                                       muls_in_ex1;
  reg                                       muls_in_ex2;
  reg                                       muls_in_wr;
  reg                                       cc_pass_instr0_wr;
  reg                                       cc_pass_instr1_wr;
  reg                                       can_fwd_from_agu_ex1;
  reg                           [1:0]       pre_head_instr_iss;
  reg                           [1:0]       head_instr_ex1;
  reg                           [1:0]       head_instr_ex2;
  reg                           [1:0]       pre_head_instr_wr;
  reg                                       end_instr_iss;
  reg                                       end_instr_ex1;
  reg                                       end_instr_ex2;
  reg                                       pre_end_instr_wr;
  reg                                       br_x_bit_iss;
  reg                                       exception_valid_ex1;
  reg                                       exception_valid_ex2;
  reg        [`CA53_INSTR_TYPE_W-1:0]       instr_type_ex1;
  reg        [`CA53_INSTR_TYPE_W-1:0]       instr_type_ex2;
  reg        [`CA53_INSTR_TYPE_W-1:0]       instr_type_wr;
  reg  [`CA53_SLOT1_INSTR_TYPE_W-1:0]       slot1_instr_type_iss;
  reg  [`CA53_SLOT1_INSTR_TYPE_W-1:0]       slot1_instr_type_ex1;
  reg  [`CA53_SLOT1_INSTR_TYPE_W-1:0]       slot1_instr_type_ex2;
  reg  [`CA53_SLOT1_INSTR_TYPE_W-1:0]       slot1_instr_type_wr;
  reg                      [WHR_WR:WHR_WR]  alu0_a_w0_where_ex1;
  reg                     [WHR_EX2:WHR_WR]  alu0_a_w1_where_ex1;
  reg                     [WHR_EX2:WHR_WR]  alu0_a_w2_where_ex1;
  reg                      [WHR_WR:WHR_WR]  alu0_b_w0_where_ex1;
  reg                     [WHR_EX2:WHR_WR]  alu0_b_w1_where_ex1;
  reg                     [WHR_EX2:WHR_WR]  alu0_b_w2_where_ex1;
  reg                      [WHR_WR:WHR_WR]  alu1_a_w0_where_ex1;
  reg                     [WHR_EX1:WHR_WR]  alu1_a_w1_where_ex1;
  reg                     [WHR_EX2:WHR_WR]  alu1_a_w2_where_ex1;
  reg                      [WHR_WR:WHR_WR]  alu1_b_w0_where_ex1;
  reg                     [WHR_EX1:WHR_WR]  alu1_b_w1_where_ex1;
  reg                     [WHR_EX2:WHR_WR]  alu1_b_w2_where_ex1;
  reg                     [WHR_EX2:WHR_WR]  str0_a_w0_where_ex1;
  reg                     [WHR_EX1:WHR_WR]  str0_a_w1_where_ex1;
  reg                     [WHR_EX2:WHR_WR]  str0_a_w2_where_ex1;
  reg                     [WHR_EX2:WHR_WR]  str0_b_w0_where_ex1;
  reg                     [WHR_EX2:WHR_WR]  str0_b_w1_where_ex1;
  reg                     [WHR_EX2:WHR_WR]  str0_b_w2_where_ex1;
  reg                     [WHR_EX2:WHR_WR]  str1_a_w0_where_ex1;
  reg                     [WHR_EX1:WHR_WR]  str1_a_w1_where_ex1;
  reg                     [WHR_EX2:WHR_WR]  str1_a_w2_where_ex1;
  reg                     [WHR_EX2:WHR_WR]  str1_b_w0_where_ex1;
  reg                     [WHR_EX1:WHR_WR]  str1_b_w1_where_ex1;
  reg                     [WHR_EX2:WHR_WR]  str1_b_w2_where_ex1;
  reg                      [WHR_WR:WHR_WR]  str0_a_w0_where_ex2;
  reg                     [WHR_EX2:WHR_WR]  str0_a_w1_where_ex2;
  reg                      [WHR_WR:WHR_WR]  str0_a_w2_where_ex2;
  reg                      [WHR_WR:WHR_WR]  str0_b_w0_where_ex2;
  reg                      [WHR_WR:WHR_WR]  str0_b_w1_where_ex2;
  reg                      [WHR_WR:WHR_WR]  str0_b_w2_where_ex2;
  reg                      [WHR_WR:WHR_WR]  str1_a_w0_where_ex2;
  reg                     [WHR_EX2:WHR_WR]  str1_a_w1_where_ex2;
  reg                      [WHR_WR:WHR_WR]  str1_a_w2_where_ex2;
  reg                      [WHR_WR:WHR_WR]  str1_b_w0_where_ex2;
  reg                     [WHR_EX2:WHR_WR]  str1_b_w1_where_ex2;
  reg                      [WHR_WR:WHR_WR]  str1_b_w2_where_ex2;
  reg        [`CA53_RF_WR_WHEN_W-1:0]       rf_wr_when_w0_ex1;
  reg        [`CA53_RF_WR_WHEN_W-1:0]       rf_wr_when_w1_ex1;
  reg        [`CA53_RF_WR_WHEN_W-1:0]       rf_wr_when_w2_ex1;
  reg        [`CA53_RF_WR_WHEN_W-1:0]       rf_wr_when_w0_ex2;
  reg        [`CA53_RF_WR_WHEN_W-1:0]       rf_wr_when_w1_ex2;
  reg        [`CA53_RF_WR_WHEN_W-1:0]       rf_wr_when_w2_ex2;
  reg                                       rf_wr_when_n_early_wr_w0_wr;
  reg                                       rf_wr_when_n_early_wr_w1_wr;
  reg                                       rf_wr_when_n_early_wr_w2_wr;
  reg                                       w0_slot1_ex1;
  reg                                       w0_slot1_ex2;
  reg                                       w0_slot1_wr;
  reg                           [4:0]       rf_wr_mode_iss;
  reg        [`CA53_FP_PIPECTL_W-1:0]       fp0_pipectl_f1;
  reg        [`CA53_FP_PIPECTL_W-1:0]       fp1_pipectl_f1;
  reg                           [1:0]       opposite_cc_ex1_w0_iss;
  reg                           [1:0]       opposite_cc_ex2_w0_iss;
  reg                           [1:0]       opposite_cc_ex1_w1_iss;
  reg                           [1:0]       opposite_cc_ex2_w1_iss;
  reg                           [1:0]       opposite_cc_ex1_w2_iss;
  reg                           [1:0]       opposite_cc_ex2_w2_iss;
  reg                                       raw_save_base_ex2;
  reg                                       wfx_stall_wr;
  reg                                       wfx_ifu_halt;
  reg                                       ext_event_reg;
  reg                                       local_event_reg;
  reg                                       div_stall_wr;
  reg                                       etm_stall_iss;
  reg                           [5:0]       rf_rd_addr_r2_iss;
  reg                           [5:0]       rf_rd_addr_r3_iss;
  reg                           [5:0]       rf_stm_rd_addr_r3_skid_iss;
  reg                                       soft_step_isv;
  reg                                       halt_step_isv;
  reg                                       step_ex;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                                      exception_valid_iss;
  wire                                      quash_de;
  wire                                      quash_iss;
  wire                                      quash_ex1;
  wire                                      quash_ex2;
  wire                                      quash_wr;
  wire                                      quash_slot0_wr;
  wire                                      quash_wr_special;
  wire                                      flush_ret;
  wire                                      flush_ls_ret;
  wire                                      flush_wr;
  wire                                      flush_ls_wr;
  wire                          [2:0]       cannot_fwd_from_ex2_to_ex1_w0_ex1;
  wire                          [2:0]       cannot_fwd_from_ex2_to_ex1_w1_ex1;
  wire                          [2:0]       cannot_fwd_from_ex2_to_ex1_w2_ex1;
  wire                          [2:0]       cannot_fwd_from_ex2_to_iss_w0_ex2;
  wire                          [2:0]       cannot_fwd_from_ex2_to_iss_w1_ex2;
  wire                          [2:0]       cannot_fwd_from_ex2_to_iss_w2_ex2;
  wire                          [2:0]       cannot_fwd_from_wr_to_early_iss_w0_wr;
  wire                          [2:0]       cannot_fwd_from_wr_to_early_iss_w1_wr;
  wire                          [2:0]       cannot_fwd_from_wr_to_early_iss_w2_wr;
  wire                          [5:0]       msr_mrs_data_spsr;
  wire        [`CA53_SEL_STR_A_W-1:0]       str0_data_a_sel_iss;
  wire        [`CA53_SEL_STR_B_W-1:0]       str0_data_b_sel_iss;
  wire                    [WHR_EX1:WHR_WR]  w0_ready_mask;
  wire                    [WHR_EX1:WHR_WR]  w1_ready_mask;
  wire                    [WHR_EX1:WHR_WR]  w2_ready_mask;
  wire                          [2:0]       fw0_lo_ready_mask_iss;
  wire                          [2:0]       fw0_hi_ready_mask_iss;
  wire                          [2:0]       fw1_lo_ready_mask_iss;
  wire                          [2:0]       fw1_hi_ready_mask_iss;
  wire                          [2:0]       fw0_lo_ready_mask_f2;
  wire                          [2:0]       fw0_hi_ready_mask_f2;
  wire                          [2:0]       fw1_lo_ready_mask_f2;
  wire                          [2:0]       fw1_hi_ready_mask_f2;
  wire                     [WHR_WR:WHR_WR]  r0_w0_available_iss;
  wire                    [WHR_EX1:WHR_WR]  r0_w1_available_iss;
  wire                    [WHR_EX1:WHR_WR]  r0_w2_available_iss;
  wire                     [WHR_WR:WHR_WR]  r1_w0_available_iss;
  wire                    [WHR_EX1:WHR_WR]  r1_w1_available_iss;
  wire                    [WHR_EX1:WHR_WR]  r1_w2_available_iss;
  wire                     [WHR_WR:WHR_WR]  r2_w0_available_iss;
  wire                    [WHR_EX1:WHR_WR]  r2_w1_available_iss;
  wire                    [WHR_EX1:WHR_WR]  r2_w2_available_iss;
  wire                     [WHR_WR:WHR_WR]  r3_w0_available_iss;
  wire                    [WHR_EX1:WHR_WR]  r3_w1_available_iss;
  wire                    [WHR_EX1:WHR_WR]  r3_w2_available_iss;
  wire                     [WHR_WR:WHR_WR]  r4_w0_available_iss;
  wire                    [WHR_EX1:WHR_WR]  r4_w1_available_iss;
  wire                    [WHR_EX1:WHR_WR]  r4_w2_available_iss;
  wire                     [WHR_WR:WHR_WR]  alu0_a_w0_available_ex1;
  wire                    [WHR_EX2:WHR_WR]  alu0_a_w1_available_ex1;
  wire                    [WHR_EX2:WHR_WR]  alu0_a_w2_available_ex1;
  wire                     [WHR_WR:WHR_WR]  alu0_b_w0_available_ex1;
  wire                    [WHR_EX2:WHR_WR]  alu0_b_w1_available_ex1;
  wire                    [WHR_EX2:WHR_WR]  alu0_b_w2_available_ex1;
  wire                     [WHR_WR:WHR_WR]  alu1_a_w0_available_ex1;
  wire                    [WHR_EX1:WHR_WR]  alu1_a_w1_available_ex1;
  wire                    [WHR_EX2:WHR_WR]  alu1_a_w2_available_ex1;
  wire                     [WHR_WR:WHR_WR]  alu1_b_w0_available_ex1;
  wire                    [WHR_EX1:WHR_WR]  alu1_b_w1_available_ex1;
  wire                    [WHR_EX2:WHR_WR]  alu1_b_w2_available_ex1;
  wire                     [WHR_WR:WHR_WR]  str0_a_w0_available_ex1;
  wire                     [WHR_WR:WHR_WR]  str0_a_w1_available_ex1;
  wire                     [WHR_WR:WHR_WR]  str0_a_w2_available_ex1;
  wire                     [WHR_WR:WHR_WR]  str0_b_w0_available_ex1;
  wire                     [WHR_WR:WHR_WR]  str0_b_w1_available_ex1;
  wire                     [WHR_WR:WHR_WR]  str0_b_w2_available_ex1;
  wire                     [WHR_WR:WHR_WR]  str1_a_w0_available_ex1;
  wire                     [WHR_WR:WHR_WR]  str1_a_w1_available_ex1;
  wire                     [WHR_WR:WHR_WR]  str1_a_w2_available_ex1;
  wire                     [WHR_WR:WHR_WR]  str1_b_w0_available_ex1;
  wire                     [WHR_WR:WHR_WR]  str1_b_w1_available_ex1;
  wire                     [WHR_WR:WHR_WR]  str1_b_w2_available_ex1;
  wire                     [WHR_WR:WHR_WR]  str0_a_w0_available_ex2;
  wire                    [WHR_EX2:WHR_WR]  str0_a_w1_available_ex2;
  wire                     [WHR_WR:WHR_WR]  str0_a_w2_available_ex2;
  wire                     [WHR_WR:WHR_WR]  str0_b_w0_available_ex2;
  wire                     [WHR_WR:WHR_WR]  str0_b_w1_available_ex2;
  wire                     [WHR_WR:WHR_WR]  str0_b_w2_available_ex2;
  wire                     [WHR_WR:WHR_WR]  str1_a_w0_available_ex2;
  wire                    [WHR_EX2:WHR_WR]  str1_a_w1_available_ex2;
  wire                     [WHR_WR:WHR_WR]  str1_a_w2_available_ex2;
  wire                     [WHR_WR:WHR_WR]  str1_b_w0_available_ex2;
  wire                    [WHR_EX2:WHR_WR]  str1_b_w1_available_ex2;
  wire                     [WHR_WR:WHR_WR]  str1_b_w2_available_ex2;
  wire                          [1:0]       cc_cancel_ex1_w0_iss;
  wire                          [1:0]       cc_cancel_ex2_w0_iss;
  wire                          [1:0]       cc_cancel_ex1_w1_iss;
  wire                          [1:0]       cc_cancel_ex2_w1_iss;
  wire                          [1:0]       cc_cancel_ex1_w2_iss;
  wire                          [1:0]       cc_cancel_ex2_w2_iss;
  wire                                      r01_slot0_iss;
  wire                                      r2_slot0_iss;
  wire                                      r34_slot0_iss;
  wire                                      w0_slot1_iss;
  wire                          [1:0]       special_insert_iss;
  wire                                      special_stall_iss;
  wire                     [WHR_WR:WHR_WR]  nxt_r0_w0_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_r1_w0_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_r2_w0_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_r3_w0_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_r4_w0_where_ex1;
  wire                    [WHR_EX1:WHR_WR]  nxt_r0_w1_where_ex1;
  wire                    [WHR_EX1:WHR_WR]  nxt_r1_w1_where_ex1;
  wire                    [WHR_EX1:WHR_WR]  nxt_r2_w1_where_ex1;
  wire                    [WHR_EX1:WHR_WR]  nxt_r3_w1_where_ex1;
  wire                    [WHR_EX1:WHR_WR]  nxt_r4_w1_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_r0_w2_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_r1_w2_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_r2_w2_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_r3_w2_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_r4_w2_where_ex1;
  wire                     [WHR_WR:WHR_WR]  nxt_alu0_a_w0_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_alu0_a_w1_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_alu0_a_w2_where_ex1;
  wire                     [WHR_WR:WHR_WR]  nxt_alu0_b_w0_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_alu0_b_w1_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_alu0_b_w2_where_ex1;
  wire                     [WHR_WR:WHR_WR]  nxt_alu1_a_w0_where_ex1;
  wire                    [WHR_EX1:WHR_WR]  nxt_alu1_a_w1_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_alu1_a_w2_where_ex1;
  wire                     [WHR_WR:WHR_WR]  nxt_alu1_b_w0_where_ex1;
  wire                    [WHR_EX1:WHR_WR]  nxt_alu1_b_w1_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_alu1_b_w2_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_str0_a_w0_where_ex1;
  wire                    [WHR_EX1:WHR_WR]  nxt_str0_a_w1_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_str0_a_w2_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_str0_b_w0_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_str0_b_w2_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_str0_b_w1_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_str1_a_w0_where_ex1;
  wire                    [WHR_EX1:WHR_WR]  nxt_str1_a_w1_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_str1_a_w2_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_str1_b_w0_where_ex1;
  wire                    [WHR_EX1:WHR_WR]  nxt_str1_b_w1_where_ex1;
  wire                    [WHR_EX2:WHR_WR]  nxt_str1_b_w2_where_ex1;
  wire       [`CA53_INSTR_TYPE_W-1:0]       nxt_instr_type_ex1;
  wire       [`CA53_INSTR_TYPE_W-1:0]       nxt_instr_type_ex2;
  wire                    [WHR_EX1:WHR_WR]  r0_w0_where_iss;
  wire                    [WHR_EX1:WHR_WR]  r1_w0_where_iss;
  wire                    [WHR_EX1:WHR_WR]  r2_w0_where_iss;
  wire                    [WHR_EX1:WHR_WR]  r3_w0_where_iss;
  wire                    [WHR_EX1:WHR_WR]  r4_w0_where_iss;
  wire                    [WHR_ISS:WHR_WR]  r0_w1_where_iss;
  wire                    [WHR_ISS:WHR_WR]  r1_w1_where_iss;
  wire                    [WHR_ISS:WHR_WR]  r2_w1_where_iss;
  wire                    [WHR_ISS:WHR_WR]  r3_w1_where_iss;
  wire                    [WHR_ISS:WHR_WR]  r4_w1_where_iss;
  wire                    [WHR_EX1:WHR_WR]  r0_w2_where_iss;
  wire                    [WHR_EX1:WHR_WR]  r1_w2_where_iss;
  wire                    [WHR_EX1:WHR_WR]  r2_w2_where_iss;
  wire                    [WHR_EX1:WHR_WR]  r3_w2_where_iss;
  wire                    [WHR_EX1:WHR_WR]  r4_w2_where_iss;
  wire                         [W2:W0]      addr_cmp_de_ex1                [R1:R0];
  wire                         [W2:W0]      addr_cmp_de_ex2                [R1:R0];
  wire                         [W2:W0]      addr_cmp_iss_ex1               [R1:R0];
  wire                         [W2:W0]      addr_cmp_iss_ex2               [R1:R0];
  wire                         [W2:W0]      addr_cmp_iss_wr                [R1:R0];
  wire                         [W2:W0]      addr_cmp_de_wr                 [R1:R0];
  wire                         [W2:W0]      nxt_early_addr_cmp_iss_ex2     [R1:R0];
  wire                         [W2:W0]      nxt_early_addr_cmp_iss_wr      [R1:R0]; 
  wire                         [W2:W1]      nxt_early_addr_cmp_agu_iss_ex2 [R1:R0];
  wire                          [1:0]       conditional_instr_ex1;
  wire                          [1:0]       conditional_instr_ex2;
  wire                                      expt_quash_no_data_wr;
  wire                                      quash_no_data_wr;
  wire                          [1:0]       nxt_head_instr_ex2;
  wire                          [1:0]       nxt_head_instr_wr;
  wire                                      nxt_end_instr_ex1;
  wire                                      nxt_end_instr_ex2;
  wire                                      nxt_end_instr_wr;
  wire                                      issue_to_iss;
  wire                                      issue_to_iss_fpu;
  wire                                      issue_to_ex1;
  wire                                      issue_to_ex1_fpu;
  wire                                      issue_to_ex2;
  wire                                      issue_to_ex2_fpu;
  wire                                      issue_to_wr;
  wire                                      issue_to_wr_fpu;
  wire                                      issue_to_f4;
  wire                                      issue_to_f5;
  wire                                      nxt_alu0_valid_iss;
  wire                                      nxt_alu1_valid_iss;
  wire                                      nxt_mac_valid_iss;
  wire                                      nxt_div_valid_iss;
  wire                                      nxt_str0_valid_iss;
  wire                                      nxt_str1_valid_iss;
  wire                                      end_instr_wr;
  wire                                      end_instr_no_quash_wr;
  wire                          [1:0]       head_instr_wr;
  wire                          [1:0]       head_instr_iss;
  wire                                      wfi_expt_exception_pending;
  wire                                      wfe_expt_exception_pending;
  wire                                      nxt_dbg_ifu_halt;
  wire                                      interlock_iss;
  wire                                      conditional_instr_iss;
  wire                          [1:0]       nxt_valid_instrs_iss;
  wire                          [1:0]       nxt_valid_instrs_ex1;
  wire                          [1:0]       nxt_valid_instrs_ex2;
  wire                          [1:0]       nxt_valid_instrs_wr;
  wire                                      nxt_en_restore;
  wire                                      expt_flush_ret;
  wire                                      expt_quash_wr;
  wire                                      forceop_valid_de;
  wire                                      forceop_valid_wr;
  wire                                      dbg_halt_ecc_expt_de;
  wire                                      insert_forceop_wr;
  wire                                      sel_fwd_addr_dcu_a_iss;
  wire                                      mac_no_ilock_r2_w0_iss;
  wire                                      mac_no_ilock_r2_w1_iss;
  wire                                      mac_no_ilock_r2_w2_iss;
  wire                                      mac_no_ilock_r3_w0_iss;
  wire                                      can_fwd_from_agu_iss;
  wire                          [1:0]       isa_instr0_iss;
  wire                          [1:0]       isa_instr0_ex2;
  wire                          [1:0]       isa_instr0_wr;
  wire                                      nxt_mod_pc_top_bits_wr;
  wire                                      en_btm_pc_iss;
  wire                                      en_top_pc_iss;
  wire                                      en_aa64_pc_iss;
  wire                                      en_btm_pc_ex1;
  wire                                      en_top_pc_ex1;
  wire                                      en_aa64_pc_ex1;
  wire                                      en_btm_pc_ex2;
  wire                                      en_top_pc_ex2;
  wire                                      en_aa64_pc_ex2;
  wire                                      en_top_pc_wr;
  wire                                      en_aa64_pc_wr;
  wire                                      en_btm_pc_ret;
  wire                                      en_top_pc_ret;
  wire                                      en_aa64_pc_ret;
  wire                         [63:0]       pc_instr0_wr;
  wire                         [63:0]       pc_instr0_ret;
  wire                                      nxt_full_pc_ex1;
  wire                          [3:0]       nxt_dpu_dbg_vid;
  wire                                      alu0_pipectl_en_iss;
  wire                                      alu1_pipectl_en_iss;
  wire                                      mac_pipectl_en_iss;
  wire      [`CA53_ALU_EX2_CTL_W-1:0]       alu0_ex2_ctl_iss;
  wire      [`CA53_ALU_EX2_CTL_W-1:0]       alu1_ex2_ctl_iss;
  wire                          [1:0]       valid_instrs_wr;
  wire                                      no_interrupt_en;
  wire                                      nxt_no_interrupt_iss;
  wire                                      nxt_no_interrupt_ex1;
  wire                                      nxt_no_interrupt_ex2;
  wire                                      nxt_no_interrupt_dp_wr;
  wire                                      nxt_no_interrupt_ls_wr;
  wire                                      no_interrupt_wr;
  wire                                      no_interrupt_ls_wr_en;
  wire       [`CA53_RF_WR_WHEN_W-1:0]       nxt_rf_wr_when_w0_ex1;
  wire       [`CA53_RF_WR_WHEN_W-1:0]       nxt_rf_wr_when_w1_iss;
  wire       [`CA53_RF_WR_WHEN_W-1:0]       nxt_rf_wr_when_w2_iss;
  wire                          [5:0]       nxt_rf_wr_addr_w0_ex1;
  wire                          [5:0]       nxt_rf_wr_addr_w2_ex1;
  wire                          [5:0]       rf_wr_addr_w0_wr;
  wire                                      nxt_rf_wr_64b_w0_ex1;
  wire                                      nxt_rf_wr_64b_w2_ex1;
  wire                                      rf_wr_64b_w0_wr;
  wire     [`CA53_RF_WR_SRC_W0_W-1:0]       nxt_rf_wr_src_w0_ex1;
  wire     [`CA53_RF_WR_SRC_W2_W-1:0]       nxt_rf_wr_src_w2_ex1;
  wire     [`CA53_RF_WR_SRC_W0_W-1:0]       rf_wr_src_w0_wr;
  wire                                      reenable_w0_wr;
  wire                                      reenable_w1_wr;
  wire                                      rf_wr_en_w0_wr;
  wire                                      rf_wr_en_w1_wr;
  wire                                      rf_wr_en_w2_wr;
  wire [`CA53_SLOT1_INSTR_TYPE_W-1:0]       nxt_slot1_instr_type_iss;
  wire                                      slot1_ls_iss;
  wire                                      slot1_ls_ex2;
  wire                                      slot1_ls_wr;
  wire                                      slot1_branch_iss;
  wire                                      slot1_branch_ex2;
  wire                                      slot1_branch_wr;
  wire                                      slot1_mul_iss;
  wire                                      slot1_mul_wr;
  wire                                      slot1_fp_iss;
  wire                                      slot1_fp_ex2;
  wire                                      slot1_fp_wr;
  wire                                      nxt_muls_in_ex1;
  wire                                      nxt_exception_valid_ex1;
  wire                                      unflushable_ex1;
  wire                                      unflushable_ex2;
  wire                                      unflushable_wr;
  wire                                      ilock_stall_iss;
  wire                                      ilock_stall_div_iss;
  wire                                      ilock_stall_mac_iss;
  wire                                      nxt_instr0_de_pc_in_iss;
  wire                                      stall_slot0_iss;
  wire                                      stall_iss;
  wire                                      stall_ex1_no_sfmac;
  wire                                      stall_ex2_no_sfmac;
  wire                                      stall_ex1_sfmac;
  wire                                      stall_ex2_sfmac;
  wire                                      stall_wr;
  wire                                      div_in_ex1;
  wire                                      div_in_ex2;
  wire                                      div_in_wr;
  wire                                      div_stall_iss;
  wire                                      nxt_div_stall_wr;
  wire                                      nxt_etm_stall_iss;
  wire                                      div_flush;
  wire                                      expt_quash_slot0_wr;
  wire                                      expt_slot1_wr;
  wire                                      early_expt_dcu_wr;
  wire                          [5:0]       rf_wr_addr_w0_iss;
  wire                          [5:0]       rf_wr_addr_w1_iss;
  wire                          [5:0]       rf_wr_addr_w2_iss;
  wire                                      rf_wr_en_w0_ex1;
  wire                                      rf_wr_en_w1_ex1;
  wire                                      rf_wr_en_w1_no_x64_ex1;
  wire                                      rf_wr_en_w2_ex1;
  wire                                      rf_wr_en_w0_ex2;
  wire                                      rf_wr_en_w1_ex2;
  wire                                      rf_wr_en_w2_ex2;
  wire                                      rf_wr_en_w0_iss;
  wire                                      rf_wr_en_w1_iss;
  wire                                      rf_wr_en_w1_no_x64_iss;
  wire                                      rf_wr_en_w2_iss;
  wire                                      nxt_rf_wr_en_w0_ex1;
  wire                                      nxt_rf_wr_en_w2_ex1;
  wire                                      nxt_rf_wr_en_w0_wr;
  wire                                      nxt_rf_wr_en_w1_wr;
  wire                                      nxt_rf_wr_en_w2_wr;
  wire                                      nxt_rf_wr_en_hi_wr;
  wire                                      nxt_rf_wr_en_lo_wr;
  wire                                      dual_iss_w0_hazard_ex2;
  wire                                      dual_iss_w1_hazard_ex2;
  wire                          [3:0]       special_cond_code_instr0_iss;
  wire                          [3:0]       special_cond_code_instr1_iss;
  wire                                      alu0_valid_iss;
  wire                                      alu1_valid_iss;
  wire                                      str0_valid_iss;
  wire                                      str0_a_valid_iss;
  wire                                      str0_b_valid_iss;
  wire                                      str1_valid_iss;
  wire                                      str1_a_valid_iss;
  wire                                      str1_b_valid_iss;
  wire                                      mac_valid_iss;
  wire                                      div_valid_iss;
  wire                                      rf_rd_en_r0_iss;
  wire                                      rf_rd_en_r1_iss;
  wire                                      rf_rd_en_r2_iss;
  wire                                      rf_rd_en_r3_iss;
  wire                                      rf_rd_en_r4_iss;
  wire                          [2:0]       r0_when_iss;
  wire                          [2:0]       r1_when_iss;
  wire                          [2:0]       r2_when_iss;
  wire                          [2:0]       r3_when_iss;
  wire                          [2:0]       r4_when_iss;
  wire                                      alu0_flagset_iss;
  wire                                      alu1_flagset_iss;
  wire                                      nxt_size_instr0_iss;
  wire                         [48:1]       raw_pc_instr1_iss;
  wire                         [48:1]       pc_instr1_iss;
  wire                                      fpu_interlock_iss;
  wire                          [1:0]       unflushable_sfmac_ex1;
  wire                          [1:0]       unflushable_sfmac_ex2;
  wire                          [1:0]       unflushable_sfmac_wr;
  wire                                      expt_ls_quash_wr;
  wire                                      raw_sel_fwd_addr_dcu_a_de;
  wire                                      r0_de_w1_iss_match;
  wire                                      r0_de_w2_iss_match;
  wire                                      ns_state;
  wire                                      wfi_expt_wr;
  wire                                      wfe_expt_wr;
  wire                                      en_lsm_skidding;
  wire                                      en_rd_addr_lsm_skidding;
  wire    [`CA53_FLAGEN_INSTR1_W-1:0]       nxt_flag_en_instr1_wr;
  wire       [`CA53_RF_WR_WHEN_W-1:0]       rf_wr_when_w2_iss;
  wire                          [1:0]       nxt_opposite_cc_ex1_w0_iss;
  wire                          [1:0]       nxt_opposite_cc_ex2_w0_iss;
  wire                          [1:0]       nxt_opposite_cc_ex1_w1_iss;
  wire                          [1:0]       nxt_opposite_cc_ex2_w1_iss;
  wire                          [1:0]       nxt_opposite_cc_ex1_w2_iss;
  wire                          [1:0]       nxt_opposite_cc_ex2_w2_iss;
  wire                          [1:0]       suppress_cc_cancel_ex1_iss;
  wire                          [1:0]       suppress_cc_cancel_ex2_iss;
  wire                                      opposite_cc_de_0_iss_0;
  wire                                      opposite_cc_de_0_ex1_0;
  wire                                      opposite_cc_iss_0_ex1_0;
  wire                                      opposite_cc_iss_0_ex2_0;
  wire                                      opposite_cc_de_0_iss_1;
  wire                                      opposite_cc_de_0_ex1_1;
  wire                                      opposite_cc_iss_0_ex1_1;
  wire                                      opposite_cc_iss_0_ex2_1;
  wire                                      opposite_cc_de_1_iss_0;
  wire                                      opposite_cc_de_1_ex1_0;
  wire                                      opposite_cc_iss_1_ex1_0;
  wire                                      opposite_cc_iss_1_ex2_0;
  wire                                      opposite_cc_de_1_iss_1;
  wire                                      opposite_cc_de_1_ex1_1;
  wire                                      opposite_cc_iss_1_ex1_1;
  wire                                      opposite_cc_iss_1_ex2_1;
  wire                                      mrc_interlock_iss;
  wire                                      agu_b_sxt_iss;
  wire              [`CA53_FWD_W-1:0]       str0_a_fwd_fp_ex2;
  wire              [`CA53_FWD_W-1:0]       str0_b_fwd_fp_ex2;
  wire              [`CA53_FWD_W-1:0]       str1_a_fwd_fp_ex2;
  wire              [`CA53_FWD_W-1:0]       str1_b_fwd_fp_ex2;
  wire                          [1:0]       str0_sel_fp_f1;
  wire                          [1:0]       str0_sel_fp_f2;
  wire                          [1:0]       str1_sel_fp_f1;
  wire                          [1:0]       str1_sel_fp_f2;
  wire                                      nxt_save_base_ex2;
  wire                                      save_base_ex2;
  wire                                      instr_sev_wr;
  wire                                      instr_sevl_wr;
  wire                                      instr_wfe_wr;
  wire                                      instr_wfi_wr;
  wire                                      valid_wfx_or_sev_in_wr;
  wire                                      raw_wfi_req;
  wire                                      raw_wfe_req;
  wire                                      nxt_sev_req;
  wire                                      nxt_clr_event_register;
  wire                                      nxt_wfi_req;
  wire                                      nxt_wfe_req;
  wire                                      nxt_wfx_stall_wr;
  wire                                      nxt_dpu_halt_ifu;
  wire                                      nxt_wfx_ifu_halt;
  wire                                      nxt_local_event_reg;
  wire                                      neon_ret_stall_iss;
  wire                          [5:0]       nxt_rf_rd_addr_r2_iss;
  wire                          [5:0]       nxt_rf_rd_addr_r3_iss;
  wire                                      rf_rd_addr_r0_iss_en;
  wire                                      rf_rd_addr_r1_iss_en;
  wire                                      rf_rd_addr_r2_iss_en;
  wire                                      rf_rd_addr_r3_iss_en;
  wire                                      rf_rd_addr_r4_iss_en;
  wire                                      rf_stm_rd_addr_r3_skid_iss_en;
  wire                                      nxt_soft_step_isv;
  wire                                      nxt_halt_step_isv;
  wire                                      nxt_step_ex;
  wire                                      advance_pipeline;
  wire                                      valid_iss_en;
  wire                                      no_interrupt_iss_en;
  wire                                      expt_full_pc_iss;
  wire               [`CA53_EXPT_BUS_W-1:0] exception_data_wr;
  

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Flush logic
  // ------------------------------------------------------
  //
  // There are several sources of flush:
  //  - direct branch
  //  - indirect branch
  //  - exception
  //
  // Different branch signals come from the various events in the various blocks.  They are
  // combined here to produce to overall flush signals:
  // - flush_ret (kills everything)
  // - flush_wr  (kills everything from De to Ex2)
  // In practice, if flush_ret is asserted, then flush_wr will certainly be asserted.
  //
  // The "ls" versions are used by the DCU and the load-store interface.  If an imprecise
  // exception such as FIQ/IRQ is signalled a flush occurs followed by another flush on the
  // following cycle caused by expt_flush_ret.
  assign flush_wr     = br_flush_ret_i | expt_flush_ret | br_flush_wr_i;
  assign flush_ls_wr  = br_flush_ret_i | expt_flush_ret | br_flush_wr_i       | expt_ls_quash_wr;
  assign flush_ret    = br_flush_ret_i | expt_flush_ret;
  assign flush_ls_ret = br_flush_ret_i | expt_flush_ret | slot0_br_flush_wr_i | expt_ls_quash_wr;

  // Create quash signals.  Forceops are not marked as no_interrupt (so
  // sMOVs can pre-empt them) so we must not quash them.  The exception
  // logic ensures no other exceptions happen as they travel down the pipe
  //
  // The special version of quash_wr is only for the special control logic.
  // It is generated without unflushable so that if there is an
  // unflushable in Wr and the multiply portion of an FMACD is commited but
  // the special not yet issued the FMACD can still be killed.
  assign quash_de         =  flush_wr & ~forceop_valid_de;
  assign quash_iss        =  flush_wr;
  assign quash_ex1        =  flush_wr & ~unflushable_ex1;
  assign quash_ex2        =  flush_wr & ~unflushable_ex2;
  assign quash_wr         = (flush_ret | expt_quash_wr)         & ~unflushable_wr;
  assign quash_no_data_wr = (flush_ret | expt_quash_no_data_wr) & ~unflushable_wr;
  assign quash_wr_special = (flush_ret | expt_quash_slot0_wr);
  assign quash_slot0_wr   = (flush_ret | expt_quash_slot0_wr)   & ~unflushable_wr;

  // Valid instruction pipeline
  //
  // In the Iss stage, if we are dual issuing a load/store that gets reissued
  // then suppress the other instruction's valid signal on the first of the two
  // cycles, so the other instruction only gets issued once.
  assign advance_pipeline        = ~stall_wr | flush_ret;
  assign nxt_valid_instrs_iss    =  valid_instrs_de_i & {2{~quash_de}};
  assign nxt_valid_instrs_ex1[1] =  valid_instrs_iss[1] &  ~quash_iss & ~(slot1_ls_iss ? ilock_stall_iss : stall_iss);
  assign nxt_valid_instrs_ex1[0] = (valid_instrs_iss[0] &  ~quash_iss & ~ilock_stall_iss) | (special_stall_iss & advance_pipeline);
  assign nxt_valid_instrs_ex2    =  valid_instrs_ex1 &  {2{~quash_ex1}} & {2{advance_pipeline}};
  assign nxt_valid_instrs_wr     =  valid_instrs_ex2 &  {2{~quash_ex2}} & {2{advance_pipeline}};

  // Stall signals for ex1/ex2
  //
  // Two versions of the stall signals are created.  The sFMAC version is required to make sure
  // any sFMAC specials (inserted for FMACS/FMACD) proceed down the pipeline as long as there isn't a
  // stall_wr.
  //
  // One thing to be aware of with sFMAC that they can be inserted at the same time as other
  // instructions to keep the throughput of FMACS at a maximum whereas all other specials
  // stall the pipeline when they insert.  Therefore, you can't use the valid_instr signal as
  // a pipeline qualification signal for the for the sFMAC and must use the unflushable_sfmac_*
  // signal for qualification instead.
  assign stall_ex1_no_sfmac = unflushable_ex1 ? (stall_wr & ~flush_ret) : (stall_wr & ~flush_wr);
  assign stall_ex2_no_sfmac = unflushable_ex2 ? (stall_wr & ~flush_ret) : (stall_wr & ~flush_wr);
  assign stall_ex1_sfmac    = stall_wr & ~flush_ret;
  assign stall_ex2_sfmac    = stall_wr & ~flush_ret;

  // Pipeline enable signals
  assign issue_to_iss = valid_instrs_de_i[0] & (~stall_iss | flush_wr) & ~quash_de;
  assign issue_to_ex1 = (valid_instrs_iss[0] | (|special_insert_iss)) & advance_pipeline;
  assign issue_to_ex2 = (valid_instrs_ex1[0] | (|unflushable_sfmac_ex1)) & advance_pipeline;
  assign issue_to_wr  = (valid_instrs_ex2[0] | (|unflushable_sfmac_ex2)) & advance_pipeline;
  assign issue_to_f4  = (valid_instrs_wr[0]  | (|unflushable_sfmac_wr))  & advance_pipeline;
  assign issue_to_f5  = advance_pipeline;

  // ------------------------------------------------------
  // No interrupt
  // ------------------------------------------------------

  // no_interrupt, when asserted in the wr-stage, prevents the exception
  // logic taking an interrupt (IRQ/FIQ/imprecise dabort).  After the PC is
  // forced (by a branch or an exception), the pipelined no_interrupt signals
  // are forced high, thus preventing any interrupts being taken before the
  // new PC value has flowed down the pipeline.
  // The iss-stage no_interrupt signal need not be forced high on a branch,
  // because the iss-stage PC is forced when the branch is taken.  However,
  // it does need to be forced when an exception is taken, because the
  // exception vector address travels with the ForceOp, which is in the
  // de-stage at the time of the flush.

  assign nxt_no_interrupt_iss = (no_interrupt_de_i & ~flush_wr) | expt_flush_ret;
  assign no_interrupt_iss_en = ~stall_iss | flush_wr;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      no_interrupt_iss <= 1'b1;
    else if (no_interrupt_iss_en)
      no_interrupt_iss <= nxt_no_interrupt_iss;

  assign nxt_no_interrupt_ex1   = no_interrupt_iss | flush_wr | incr_pc_halt_mode_ret_i;
  assign nxt_no_interrupt_ex2   = no_interrupt_ex1 | flush_wr | incr_pc_halt_mode_ret_i;
  assign nxt_no_interrupt_dp_wr = no_interrupt_ex2 | flush_wr | incr_pc_halt_mode_ret_i;

  assign no_interrupt_en = ~stall_wr | flush_wr | incr_pc_halt_mode_ret_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      no_interrupt_ex1   <= 1'b1;
      no_interrupt_ex2   <= 1'b1;
      no_interrupt_dp_wr <= 1'b1;
    end else if (no_interrupt_en) begin
      no_interrupt_ex1   <= nxt_no_interrupt_ex1;
      no_interrupt_ex2   <= nxt_no_interrupt_ex2;
      no_interrupt_dp_wr <= nxt_no_interrupt_dp_wr;
    end

  // If we are in the first cycle or subsequent cycle of a load-store instruction
  // and the transaction is not completed then we force no_interrupt (a requirement
  // as we are not implementing low interrupt latency mode).
  assign nxt_no_interrupt_ls_wr = (~pre_end_instr_wr | stall_wr) & ~flush_ret;

  assign no_interrupt_ls_wr_en = (ls_valid_wr_i & ~slot0_br_flush_wr_i) | pre_end_instr_wr | flush_ret;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      no_interrupt_ls_wr <= 1'b0;
    else if (no_interrupt_ls_wr_en)
      no_interrupt_ls_wr <= nxt_no_interrupt_ls_wr;

  assign no_interrupt_wr = no_interrupt_dp_wr | no_interrupt_ls_wr;

  // ------------------------------------------------------
  // Slot 1 instruction types
  // ------------------------------------------------------

  assign slot1_ls_iss     = (slot1_instr_type_iss == `CA53_SLOT1_INSTR_TYPE_LS) |
                            (slot1_instr_type_iss == `CA53_SLOT1_INSTR_TYPE_FP_LS);
  assign slot1_ls_ex2     = (slot1_instr_type_ex2 == `CA53_SLOT1_INSTR_TYPE_LS) |
                            (slot1_instr_type_ex2 == `CA53_SLOT1_INSTR_TYPE_FP_LS);
  assign slot1_ls_wr      = (slot1_instr_type_wr  == `CA53_SLOT1_INSTR_TYPE_LS) |
                            (slot1_instr_type_wr  == `CA53_SLOT1_INSTR_TYPE_FP_LS);

  assign slot1_branch_iss = (slot1_instr_type_iss == `CA53_SLOT1_INSTR_TYPE_BRANCH) |
                            (slot1_instr_type_iss == `CA53_SLOT1_INSTR_TYPE_BX)     |
                            (slot1_instr_type_iss == `CA53_SLOT1_INSTR_TYPE_BLX);
  assign slot1_branch_ex2 = (slot1_instr_type_ex2 == `CA53_SLOT1_INSTR_TYPE_BRANCH) |
                            (slot1_instr_type_ex2 == `CA53_SLOT1_INSTR_TYPE_BX)     |
                            (slot1_instr_type_ex2 == `CA53_SLOT1_INSTR_TYPE_BLX);
  assign slot1_branch_wr  = (slot1_instr_type_wr  == `CA53_SLOT1_INSTR_TYPE_BRANCH) |
                            (slot1_instr_type_wr  == `CA53_SLOT1_INSTR_TYPE_BX)     |
                            (slot1_instr_type_wr  == `CA53_SLOT1_INSTR_TYPE_BLX);

  assign slot1_mul_iss    = (slot1_instr_type_iss == `CA53_SLOT1_INSTR_TYPE_MUL);
  assign slot1_mul_wr     = (slot1_instr_type_wr  == `CA53_SLOT1_INSTR_TYPE_MUL);

  assign slot1_fp_iss     = (slot1_instr_type_iss == `CA53_SLOT1_INSTR_TYPE_FP) |
                            (slot1_instr_type_iss == `CA53_SLOT1_INSTR_TYPE_FP_LS);
  assign slot1_fp_ex2     = (slot1_instr_type_ex2 == `CA53_SLOT1_INSTR_TYPE_FP) |
                            (slot1_instr_type_ex2 == `CA53_SLOT1_INSTR_TYPE_FP_LS);
  assign slot1_fp_wr      = (slot1_instr_type_wr  == `CA53_SLOT1_INSTR_TYPE_FP) |
                            (slot1_instr_type_wr  == `CA53_SLOT1_INSTR_TYPE_FP_LS);

  // ------------------------------------------------------
  // Iss stage registers
  // ------------------------------------------------------

  assign head_instr_ls_iss_o = (slot1_ls_iss ? (pre_head_instr_iss[1] & valid_instrs_iss[1])
                                             : (pre_head_instr_iss[0] & valid_instrs_iss[0])) &
                               ~lsm_skidding_i &
                               ~second_x64_iss_i &
                               ~(interlock_iss | quash_iss);

  assign head_instr_iss[0]   = pre_head_instr_iss[0] &
                               valid_instrs_iss[0]   &
                               ~lsm_skidding_i       &
                               ~second_x64_iss_i     &
                               ~(interlock_iss | quash_iss);

  assign head_instr_iss[1]   = pre_head_instr_iss[1]             &
                               valid_instrs_iss[1]               &
                               ~lsm_skidding_i                   &
                               (slot1_ls_iss ? ~second_x64_iss_i
                                             : ~first_x64_iss_i) &
                               ~(interlock_iss | quash_iss);

  assign nxt_alu0_valid_iss  = alu0_valid_de_i & ~quash_de;
  assign nxt_alu1_valid_iss  = alu1_valid_de_i & ~quash_de;
  assign nxt_str0_valid_iss  = str0_valid_de_i & ~quash_de;
  assign nxt_str1_valid_iss  = str1_valid_de_i & ~quash_de;
  assign nxt_mac_valid_iss   = mac_valid_de_i  & ~quash_de;

  assign nxt_div_valid_iss   = stall_iss ? (raw_div_valid_iss & ilock_stall_div_iss)
                                         : (div_valid_de_i  & ~quash_de);

  assign valid_iss_en = ~stall_iss | quash_iss;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      valid_instrs_iss        <= 2'b00;
      pre_head_instr_iss      <= 2'b00;
      end_instr_iss           <= 1'b0;
      raw_rf_wr_en_w0_iss     <= 1'b0;
      raw_rf_wr_en_w1_iss     <= 1'b0;
      raw_rf_wr_en_w2_iss     <= 1'b0;
      thumb_instr1_iss        <= 1'b0;
      br_x_bit_iss            <= 1'b0;
      muls_in_iss             <= 1'b0;
      usr_mode_regs_ldm_iss   <= 1'b0;
      rf_wr_mode_iss          <= {5{1'b0}};
      raw_alu0_valid_iss      <= 1'b0;
      raw_alu1_valid_iss      <= 1'b0;
      raw_str0_valid_iss      <= 1'b0;
      raw_str1_valid_iss      <= 1'b0;
      raw_mac_valid_iss       <= 1'b0;
      flag_en_instr1_iss      <= {`CA53_FLAGEN_INSTR1_W{1'b0}};
      forceop_valid_iss       <= 1'b0;
      dbg_halt_ecc_expt_iss   <= 1'b0;
    end else if (valid_iss_en) begin
      valid_instrs_iss        <= nxt_valid_instrs_iss;
      pre_head_instr_iss      <= head_instr_de_i;
      end_instr_iss           <= end_instr_de_i;
      raw_rf_wr_en_w0_iss     <= rf_wr_en_w0_de_i;
      raw_rf_wr_en_w1_iss     <= rf_wr_en_w1_de_i;
      raw_rf_wr_en_w2_iss     <= rf_wr_en_w2_de_i;
      thumb_instr1_iss        <= thumb_instr1_de_i;
      br_x_bit_iss            <= br_x_bit_de_i;
      muls_in_iss             <= muls_in_de_i;
      usr_mode_regs_ldm_iss   <= usr_mode_regs_ldm_de_i;
      rf_wr_mode_iss          <= rf_wr_mode_de_i;
      raw_alu0_valid_iss      <= nxt_alu0_valid_iss;
      raw_alu1_valid_iss      <= nxt_alu1_valid_iss;
      raw_str0_valid_iss      <= nxt_str0_valid_iss;
      raw_str1_valid_iss      <= nxt_str1_valid_iss;
      raw_mac_valid_iss       <= nxt_mac_valid_iss;
      flag_en_instr1_iss      <= flag_en_instr1_de_i;
      forceop_valid_iss       <= forceop_valid_de;
      dbg_halt_ecc_expt_iss   <= dbg_halt_ecc_expt_de;
    end

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      size_instr0_iss         <= 1'b0;
      size_instr1_iss         <= 1'b0;
      wd_align_pc_alu0_iss    <= 1'b0;
      wd_align_pc_alu1_iss    <= 1'b0;
      wd_align_pc_ls_iss      <= 1'b0;
      pg_align_pc_ls_iss      <= 1'b0;
      alu0_msk_data_sel_iss   <= 1'b0;
      alu1_msk_data_sel_iss   <= 1'b0;
      alu0_data_a_sel_iss     <= {`CA53_SEL_SHF_A_W{1'b0}};
      alu0_data_b_sel_iss     <= {`CA53_SEL_SHF_B_W{1'b0}};
      alu0_data_c_sel_iss     <= {`CA53_SEL_SHF_C_W{1'b0}};
      mac_data_a_sel_iss      <= {`CA53_SEL_MAC_A_W{1'b0}};
      mac_data_b_sel_iss      <= {`CA53_SEL_MAC_B_W{1'b0}};
      div_data_a_sel_iss      <= {`CA53_SEL_DIV_A_W{1'b0}};
      div_data_b_sel_iss      <= {`CA53_SEL_DIV_B_W{1'b0}};
      alu1_data_a_sel_iss     <= {`CA53_SEL_SHF_A_W{1'b0}};
      alu1_data_b_sel_iss     <= {`CA53_SEL_SHF_B_W{1'b0}};
      alu1_data_c_sel_iss     <= {`CA53_SEL_SHF_C_W{1'b0}};
      raw_str0_data_a_sel_iss <= {`CA53_SEL_STR_A_W{1'b0}};
      raw_str0_data_b_sel_iss <= {`CA53_SEL_STR_B_W{1'b0}};
      raw_str0_b_valid_iss    <= 1'b0;
      ctl_64bit_op_str0_iss   <= 1'b0;
      str1_data_a_sel_iss     <= {`CA53_SEL_STR_A_W{1'b0}};
      str1_data_b_sel_iss     <= {`CA53_SEL_STR_B_W{1'b0}};
      raw_str1_b_valid_iss    <= 1'b0;
      ctl_64bit_op_str1_iss   <= 1'b0;
      raw_rf_rd_en_r0_iss     <= 1'b0;
      raw_rf_rd_en_r1_iss     <= 1'b0;
      raw_rf_rd_en_r2_iss     <= 1'b0;
      raw_rf_rd_en_r3_iss     <= 1'b0;
      raw_rf_rd_en_r4_iss     <= 1'b0;
    end else if (issue_to_iss) begin
      size_instr0_iss         <= nxt_size_instr0_iss;
      size_instr1_iss         <= size_instr1_de_i;
      wd_align_pc_alu0_iss    <= wd_align_pc_alu0_de_i;
      wd_align_pc_alu1_iss    <= wd_align_pc_alu1_de_i;
      wd_align_pc_ls_iss      <= wd_align_pc_ls_de_i;
      pg_align_pc_ls_iss      <= pg_align_pc_ls_de_i;
      alu0_msk_data_sel_iss   <= alu0_msk_data_sel_de_i;
      alu1_msk_data_sel_iss   <= alu1_msk_data_sel_de_i;
      alu0_data_a_sel_iss     <= alu0_data_a_sel_de_i;
      alu0_data_b_sel_iss     <= alu0_data_b_sel_de_i;
      alu0_data_c_sel_iss     <= alu0_data_c_sel_de_i;
      mac_data_a_sel_iss      <= mac_data_a_sel_de_i;
      mac_data_b_sel_iss      <= mac_data_b_sel_de_i;
      div_data_a_sel_iss      <= div_data_a_sel_de_i;
      div_data_b_sel_iss      <= div_data_b_sel_de_i;
      alu1_data_a_sel_iss     <= alu1_data_a_sel_de_i;
      alu1_data_b_sel_iss     <= alu1_data_b_sel_de_i;
      alu1_data_c_sel_iss     <= alu1_data_c_sel_de_i;
      raw_str0_data_a_sel_iss <= str0_data_a_sel_de_i;
      raw_str0_data_b_sel_iss <= str0_data_b_sel_de_i;
      raw_str0_b_valid_iss    <= str0_b_valid_de_i;
      ctl_64bit_op_str0_iss   <= ctl_64bit_op_str0_de_i;
      str1_data_a_sel_iss     <= str1_data_a_sel_de_i;
      str1_data_b_sel_iss     <= str1_data_b_sel_de_i;
      raw_str1_b_valid_iss    <= str1_b_valid_de_i;
      ctl_64bit_op_str1_iss   <= ctl_64bit_op_str1_de_i;
      raw_rf_rd_en_r0_iss     <= rf_rd_en_r0_de_i;
      raw_rf_rd_en_r1_iss     <= rf_rd_en_r1_de_i;
      raw_rf_rd_en_r2_iss     <= rf_rd_en_r2_de_i;
      raw_rf_rd_en_r3_iss     <= rf_rd_en_r3_de_i;
      raw_rf_rd_en_r4_iss     <= rf_rd_en_r4_de_i;
    end

  assign nxt_slot1_instr_type_iss = slot1_instr_type_de_i & {`CA53_SLOT1_INSTR_TYPE_W{valid_instrs_de_i[1]}};

  // ALU cannot forward out of Ex1 if the instruction is conditional (because do not know if
  // instruction will cc pass until Ex2), so force "when" to be Ex2 in that case
  assign nxt_rf_wr_when_w1_iss = {rf_wr_when_w1_de_i[WHN_NOT_E_WR],
                                  rf_wr_when_w1_de_i[WHN_NOT_EX2],
                                  rf_wr_when_w1_de_i[WHN_NOT_EX1] | (cond_code_instr0_de_i[3:1] != `CA53_CC_AL_or_NV)};

  assign nxt_rf_wr_when_w2_iss = {rf_wr_when_w2_de_i[WHN_NOT_E_WR],
                                  rf_wr_when_w2_de_i[WHN_NOT_EX2],
                                  rf_wr_when_w2_de_i[WHN_NOT_EX1] | (valid_instrs_de_i[1] & (cond_code_instr1_de_i[3:1] != `CA53_CC_AL_or_NV))};

  always @(posedge clk)
    if (issue_to_iss) begin
      cond_code_instr0_iss      <= cond_code_instr0_de_i;
      cond_code_instr1_iss      <= cond_code_instr1_de_i;
      msr_mrs_reg_iss           <= msr_mrs_reg_de_i;
      msr_mrs_spsr_iss          <= msr_mrs_spsr_de_i;
      msr_mrs_data_iss          <= msr_mrs_data_de_i;
      rf_rd_need_r0_iss         <= rf_rd_need_r0_de_i;
      rf_rd_need_r1_iss         <= rf_rd_need_r1_de_i;
      rf_rd_need_r2_iss         <= rf_rd_need_r2_de_i;
      rf_rd_need_r3_iss         <= rf_rd_need_r3_de_i;
      rf_rd_need_r4_iss         <= rf_rd_need_r4_de_i;
      instr_type_iss            <= instr_type_de_i;
      slot1_instr_type_iss      <= nxt_slot1_instr_type_iss;
      rf_rd_remap_iss           <= rf_rd_remap_de_i;
      instr0_r2_enabled_iss     <= instr0_r2_enabled_de_i;
      instr0_w0_enabled_iss     <= instr0_w0_enabled_de_i;
      rf_wr_64b_w0_iss          <= rf_wr_64b_w0_de_i;
      rf_wr_64b_w1_iss          <= rf_wr_64b_w1_de_i;
      rf_wr_64b_w2_iss          <= rf_wr_64b_w2_de_i;
      rf_wr_vaddr_w0_iss        <= rf_wr_vaddr_w0_de_i;
      rf_wr_vaddr_w1_iss        <= rf_wr_vaddr_w1_de_i;
      rf_wr_vaddr_w2_iss        <= rf_wr_vaddr_w2_de_i;
      rf_wr_src_w0_iss          <= rf_wr_src_w0_de_i;
      rf_wr_src_w1_iss          <= rf_wr_src_w1_de_i;
      rf_wr_src_w2_iss          <= rf_wr_src_w2_de_i;
      rf_wr_when_w0_iss         <= rf_wr_when_w0_de_i;
      rf_wr_when_w1_iss         <= nxt_rf_wr_when_w1_iss;
      raw_rf_wr_when_w2_iss     <= nxt_rf_wr_when_w2_iss;
      use_ex1_alu_0_iss         <= use_ex1_alu_0_de_i;
      use_ex1_alu_1_iss         <= use_ex1_alu_1_de_i;
      aarch64_state_iss         <= aarch64_state_i;
    end

  // Needs to be clocked on bubbles
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      thumb_instr0_iss <= 1'b0;
    else if (en_top_pc_iss)
      thumb_instr0_iss <= thumb_instr0_de_i;

  // Clock gate the datapath control signals if they are not required
  assign alu0_pipectl_en_iss = issue_to_iss & alu0_valid_de_i;
  assign alu1_pipectl_en_iss = issue_to_iss & alu1_valid_de_i;
  assign mac_pipectl_en_iss  = issue_to_iss & (mac_valid_de_i | div_valid_de_i);  // MAC control bus also used for divider

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      alu0_pipectl_iss <= {`CA53_ALU_PIPECTL_W{1'b0}};
    else if (alu0_pipectl_en_iss)
      alu0_pipectl_iss <= alu0_pipectl_de_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      alu1_pipectl_iss <= {`CA53_ALU_PIPECTL_W{1'b0}};
    else if (alu1_pipectl_en_iss)
      alu1_pipectl_iss <= alu1_pipectl_de_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      mac_pipectl_iss <= {`CA53_MAC_PIPECTL_W{1'b0}};
    else if (mac_pipectl_en_iss)
      mac_pipectl_iss <= mac_pipectl_de_i;

  // Clock gate register file signals that have been decoded in De
  assign rf_rd_addr_r0_iss_en = issue_to_iss & rf_rd_en_r0_de_i;
  assign rf_rd_addr_r1_iss_en = issue_to_iss & rf_rd_en_r1_de_i;

  always @(posedge clk)
    if (rf_rd_addr_r0_iss_en)
      rf_rd_addr_r0_iss <= rf_rd_addr_r0_de_i;

  always @(posedge clk)
    if (rf_rd_addr_r1_iss_en)
      rf_rd_addr_r1_iss <= rf_rd_addr_r1_de_i;

  // R2 & R3 are a special case because of skidding on STMs
  // - In general the effects of skidding are applied in Iss, but to improve timing
  // the RF addresses are muxed on the input to the Iss stage flops
  assign nxt_rf_rd_addr_r2_iss = (first_lsm_skidding_i | inter_lsm_skidding_i) ? rf_stm_rd_addr_r3_skid_iss : rf_rd_addr_r2_de_i;
  assign nxt_rf_rd_addr_r3_iss = (first_lsm_skidding_i | inter_lsm_skidding_i) ? rf_stm_rd_addr_r2_de_i     : rf_rd_addr_r3_de_i;

  // - To improve timing, the registers enables assume that the first beat of an STM (indicated by head_instr) will skid,
  // to avoid factoring in the critical first_lsm_skidding signal.
  assign en_rd_addr_lsm_skidding = ls_valid_iss_i & ls_multiple_iss_i & ls_store_iss_i & ~ilock_stall_iss & (pre_head_instr_iss[0] | lsm_skidding_i);
  assign rf_rd_addr_r2_iss_en = (issue_to_iss & rf_rd_en_r2_de_i) | en_rd_addr_lsm_skidding;
  assign rf_rd_addr_r3_iss_en = (issue_to_iss & rf_rd_en_r3_de_i) | en_rd_addr_lsm_skidding;

  always @(posedge clk)
    if (rf_rd_addr_r2_iss_en)
      rf_rd_addr_r2_iss <= nxt_rf_rd_addr_r2_iss;

  always @(posedge clk)
    if (rf_rd_addr_r3_iss_en)
      rf_rd_addr_r3_iss <= nxt_rf_rd_addr_r3_iss;

  // - The R3 address skid buffer needs to register the R3 address from De on a skidding STM. To improve timing, assume
  // the first and second beats (indicated by first_cycle_ls_de and head_instr_iss respectively) will skid, to avoid
  // factoring in the critical first_lsm_skidding signal.
  assign rf_stm_rd_addr_r3_skid_iss_en = issue_to_iss & rf_rd_en_r3_de_i & ls_multiple_de_i & (first_cycle_ls_de_i | pre_head_instr_iss[0] | lsm_skidding_i);

  always @(posedge clk)
    if (rf_stm_rd_addr_r3_skid_iss_en)
      rf_stm_rd_addr_r3_skid_iss <= rf_stm_rd_addr_r3_de_i;

  assign rf_rd_addr_r4_iss_en = issue_to_iss & rf_rd_en_r4_de_i;

  always @(posedge clk)
    if (rf_rd_addr_r4_iss_en)
      rf_rd_addr_r4_iss <= rf_rd_addr_r4_de_i;

  // Skidding register
  always @(posedge clk)
    if (en_lsm_skidding) begin
      held_rf_rd_en_r3_iss     <= raw_rf_rd_en_r3_iss;
      held_str0_data_b_sel_iss <= raw_str0_data_b_sel_iss;
      held_str0_b_valid_iss    <= raw_str0_b_valid_iss;
      held_rf_wr_addr_w2_iss   <= rf_wr_addr_w2_iss;
      held_rf_wr_en_w2_iss     <= rf_wr_en_w2_iss;
      held_rf_wr_64b_w2_iss    <= rf_wr_64b_w2_iss;
    end

  always @(posedge clk) begin
    raw_sel_fwd_addr_dcu_a_iss <= raw_sel_fwd_addr_dcu_a_de;
    early_addr_cmp_iss_ex2[R0] <= nxt_early_addr_cmp_iss_ex2[R0];
    early_addr_cmp_iss_ex2[R1] <= nxt_early_addr_cmp_iss_ex2[R1];
    early_addr_cmp_iss_wr[R0]  <= nxt_early_addr_cmp_iss_wr[R0];
    early_addr_cmp_iss_wr[R1]  <= nxt_early_addr_cmp_iss_wr[R1];
    raw_div_valid_iss          <= nxt_div_valid_iss;
  end

  // All specials should have always condition code
  assign special_cond_code_instr0_iss = special_stall_iss ? `CA53_CC_AL : cond_code_instr0_iss;
  assign special_cond_code_instr1_iss = special_stall_iss ? `CA53_CC_AL : cond_code_instr1_iss;

  // Integer RF read addresses expanded to one hot form
  ca53dpu_ctl_regexpand u_regexpand_ctl_r2 (
    .raw_rf_rd_addr_i (rf_rd_addr_r2_iss[ 5:0]),
    .exp_rf_rd_addr_o (long_rf_rd_addr_r2_iss_o[`CA53_LONG_RF_ADDR_W-1:0])
  );

  ca53dpu_ctl_regexpand u_regexpand_ctl_r3 (
    .raw_rf_rd_addr_i (rf_rd_addr_r3_iss[ 5:0]),
    .exp_rf_rd_addr_o (long_rf_rd_addr_r3_iss_o[`CA53_LONG_RF_ADDR_W-1:0])
  );

  ca53dpu_ctl_regexpand u_regexpand_ctl_r4 (
    .raw_rf_rd_addr_i (rf_rd_addr_r4_iss[ 5:0]),
    .exp_rf_rd_addr_o (long_rf_rd_addr_r4_iss_o[`CA53_LONG_RF_ADDR_W-1:0])
  );

  // Integer RF read enables including skidding
  assign rf_rd_en_r0_iss = valid_instrs_iss[0] & raw_rf_rd_en_r0_iss;
  assign rf_rd_en_r1_iss = valid_instrs_iss[0] & raw_rf_rd_en_r1_iss;
  assign rf_rd_en_r2_iss = valid_instrs_iss[0] & (lsm_skidding_i ? held_rf_rd_en_r3_iss : raw_rf_rd_en_r2_iss);
  assign rf_rd_en_r3_iss = valid_instrs_iss[0] & (lsm_skidding_i ?  raw_rf_rd_en_r2_iss : raw_rf_rd_en_r3_iss);
  assign rf_rd_en_r4_iss = valid_instrs_iss[0] & raw_rf_rd_en_r4_iss;

  // Store pipeline select signals including skidding
  assign str0_data_a_sel_iss = lsm_skidding_i ? held_str0_data_b_sel_iss[`CA53_SEL_STR_B_W-1:0] : raw_str0_data_a_sel_iss[`CA53_SEL_STR_A_W-1:0];
  assign str0_data_b_sel_iss = lsm_skidding_i ? raw_str0_data_a_sel_iss[`CA53_SEL_STR_A_W-1:0]  : raw_str0_data_b_sel_iss[`CA53_SEL_STR_B_W-1:0];

  // Store pipeline valid signals including skidding
  assign str0_a_valid_iss = str0_valid_iss & (~lsm_skidding_i | held_str0_b_valid_iss);
  assign str0_b_valid_iss = str0_valid_iss & ( lsm_skidding_i |  raw_str0_b_valid_iss);
  // - never skid slot 1 store
  assign str1_a_valid_iss = str1_valid_iss;
  assign str1_b_valid_iss = str1_valid_iss & raw_str1_b_valid_iss;

  // Integer RF write addresses including skidding
  assign nxt_rf_wr_addr_w0_ex1 = lsm_skidding_i ? held_rf_wr_addr_w2_iss : rf_wr_addr_w0_iss;
  assign nxt_rf_wr_addr_w2_ex1 = lsm_skidding_i ?      rf_wr_addr_w0_iss : rf_wr_addr_w2_iss;

  // Integer RF write widths including skidding
  assign nxt_rf_wr_64b_w0_ex1 = lsm_skidding_i ? held_rf_wr_64b_w2_iss : rf_wr_64b_w0_iss;
  assign nxt_rf_wr_64b_w2_ex1 = lsm_skidding_i ?      rf_wr_64b_w0_iss : rf_wr_64b_w2_iss;

  // Integer RF write enables including skidding
  assign nxt_rf_wr_en_w0_ex1 = lsm_skidding_i ? (held_rf_wr_en_w2_iss & ~ilock_stall_iss) :  rf_wr_en_w0_iss;
  assign nxt_rf_wr_en_w2_ex1 = lsm_skidding_i ? (~extra_lsm_cycle_i & rf_wr_en_w0_iss) : (~first_lsm_skidding_i & rf_wr_en_w2_iss);

  // Integer RF write source including skidding
  assign nxt_rf_wr_src_w0_ex1 = (lsm_skidding_i & ~ls_store_iss_i) ? `CA53_RF_WR_SRC_W0_DCU_0 : rf_wr_src_w0_iss;

  assign nxt_rf_wr_src_w2_ex1 = ((last_lsm_skidding_i | lsm_skidding_i) & ~ls_store_iss_i) ? `CA53_RF_WR_SRC_W2_DCU_1 : rf_wr_src_w2_iss;

  // Enable the registers that hold previous values when skidding
  assign en_lsm_skidding = ls_valid_iss_i & ls_multiple_iss_i & ~ilock_stall_iss & (first_lsm_skidding_i | lsm_skidding_i);

  // Pipeline valid signals
  // - Do not clock ALU control signals if instruction will stall because of
  // x64 load/store in other slot.
  // - Do not clock ALU control signals if instruction is skidding and has
  // already activated the ALU
  // - On a x64 store, do not clock the store pipe for the second half if the
  // PC is being read, as it will have been updated
  assign alu0_valid_iss     = raw_alu0_valid_iss & ~ilock_stall_iss     & ~flush_ret & ~(slot1_ls_iss & second_x64_iss_i);
  assign alu1_valid_iss     = raw_alu1_valid_iss & ~ilock_stall_iss     & ~flush_ret & ~first_x64_iss_i;
  assign str0_valid_iss     = raw_str0_valid_iss & ~ilock_stall_mac_iss & ~flush_ret & ~(second_x64_iss_i & str0_data_a_sel_iss == `CA53_SEL_STR_A_PC);
  assign str1_valid_iss     = raw_str1_valid_iss & ~ilock_stall_mac_iss & ~flush_ret & ~(second_x64_iss_i & str1_data_a_sel_iss == `CA53_SEL_STR_A_PC);
  assign div_valid_iss      = raw_div_valid_iss  & ~ilock_stall_div_iss & ~flush_wr  & valid_instrs_iss[0];
  assign mac_valid_iss      = raw_mac_valid_iss  & ~ilock_stall_mac_iss;

  // Translate virtual register addresses into physical ones
  ca53dpu_ctl_reg_trans u_reg_trans_w0 (
    .vaddr_i          (rf_wr_vaddr_w0_iss[4:0]),
    .force_usr_mode_i (usr_mode_regs_ldm_iss),
    .rf_wr_mode_iss_i (rf_wr_mode_iss[4:0]),
    .msr_mrs_data_i   (msr_mrs_data_iss[5:0]),
    .msr_mrs_reg_i    (msr_mrs_reg_iss),
    .addr_o           (rf_wr_addr_w0_iss[5:0])
  );

  ca53dpu_ctl_reg_trans u_reg_trans_w1 (
    .vaddr_i          (rf_wr_vaddr_w1_iss[4:0]),
    .force_usr_mode_i (1'b0),
    .rf_wr_mode_iss_i (rf_wr_mode_iss[4:0]),
    .msr_mrs_data_i   (msr_mrs_data_iss[5:0]),
    .msr_mrs_reg_i    (msr_mrs_reg_iss),
    .addr_o           (rf_wr_addr_w1_iss[5:0])
  );

  ca53dpu_ctl_reg_trans u_reg_trans_w2 (
    .vaddr_i          (rf_wr_vaddr_w2_iss[4:0]),
    .force_usr_mode_i (usr_mode_regs_ldm_iss),
    .rf_wr_mode_iss_i (rf_wr_mode_iss[4:0]),
    .msr_mrs_data_i   ({6{1'b0}}),
    .msr_mrs_reg_i    (1'b0),
    .addr_o           (rf_wr_addr_w2_iss[5:0])
  );

  // Reduce msr_mrs_data size as it will be used only for the SPSR encoding in different modes
  assign msr_mrs_data_spsr = {6{msr_mrs_spsr_iss}} & msr_mrs_data_iss;

  always @*
    case (msr_mrs_data_spsr[5:0]) // The new MSR/MRS encoding for SPSR
      6'b000000 : dsize_msr_mrs_data = {msr_mrs_spsr_iss, `CA53_SPSR_CRNT};
      6'b101110 : dsize_msr_mrs_data = {msr_mrs_spsr_iss, `CA53_SPSR_FIQ};
      6'b110000 : dsize_msr_mrs_data = {msr_mrs_spsr_iss, `CA53_SPSR_IRQ};
      6'b110010 : dsize_msr_mrs_data = {msr_mrs_spsr_iss, `CA53_SPSR_SVC};
      6'b110100 : dsize_msr_mrs_data = {msr_mrs_spsr_iss, `CA53_SPSR_ABT};
      6'b110110 : dsize_msr_mrs_data = {msr_mrs_spsr_iss, `CA53_SPSR_UND};
      6'b111100 : dsize_msr_mrs_data = {msr_mrs_spsr_iss, `CA53_SPSR_MON};
      6'b111110 : dsize_msr_mrs_data = {msr_mrs_spsr_iss, `CA53_SPSR_HYP};
      default   : dsize_msr_mrs_data = {4{1'bx}};
    endcase

  // ------------------------------------------------------
  // Ex1 stage registers
  // ------------------------------------------------------

  assign nxt_muls_in_ex1          = muls_in_iss         &                     ~ilock_stall_iss & valid_instrs_iss[0];
  assign nxt_instr_type_ex1       = instr_type_iss      & {`CA53_INSTR_TYPE_W{~ilock_stall_iss & valid_instrs_iss[0]}};
  assign nxt_exception_valid_ex1  = exception_valid_iss &                     ~ilock_stall_iss & valid_instrs_iss[0];

  assign nxt_end_instr_ex1  = end_instr_iss &
                              valid_instrs_iss[0] &
                              ~first_x64_iss_i &
                              ~first_lsm_skidding_i &
                              ~inter_lsm_skidding_i &
                              ~(interlock_iss | quash_iss | div_stall_iss);

  // If there is an unaligned LDR then force the upper bit of the "when" signal. If there is a
  // skidding LDM then force the lower bit to be set.
  assign nxt_rf_wr_when_w0_ex1 = {(rf_wr_when_w0_iss[WHN_NOT_E_WR] | ldr_no_early_fwd_iss_i),
                                  (rf_wr_when_w0_iss[WHN_NOT_EX2]  | (~ls_store_iss_i & lsm_skidding_i)),
                                   rf_wr_when_w0_iss[WHN_NOT_EX1]};

  // Flagset detection
  assign alu0_ex2_ctl_iss = alu0_pipectl_iss[`CA53_ALU_PIPECTL_ALU_EX2_CTL_BITS];
  assign alu0_flagset_iss = (alu0_ex2_ctl_iss[`CA53_ALU_EX2_CTL_FLAG_ID_BITS] == 2'b10) & raw_alu0_valid_iss;

  assign alu1_ex2_ctl_iss = alu1_pipectl_iss[`CA53_ALU_PIPECTL_ALU_EX2_CTL_BITS];
  assign alu1_flagset_iss = (alu1_ex2_ctl_iss[`CA53_ALU_EX2_CTL_FLAG_ID_BITS] == 2'b10) & raw_alu1_valid_iss;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      valid_instrs_ex1           <= 2'b00;
      head_instr_ex1             <= 2'b00;
      end_instr_ex1              <= 1'b0;
      raw_rf_wr_en_w0_ex1        <= 1'b0;
      raw_rf_wr_en_w1_ex1        <= 1'b0;
      raw_rf_wr_en_w2_ex1        <= 1'b0;
      raw_rf_wr_en_w1_no_x64_ex1 <= 1'b0;
      mod_pc_top_bits_ex1        <= 1'b0;
      thumb_instr0_ex1           <= 1'b0;
      thumb_instr1_ex1           <= 1'b0;
      muls_in_ex1                <= 1'b0;
      instr_type_ex1             <= {`CA53_INSTR_TYPE_W{1'b0}};
      exception_valid_ex1        <= 1'b0;
      flag_en_instr1_ex1         <= {`CA53_FLAGEN_INSTR1_W{1'b0}};
    end else if (en_btm_pc_ex1) begin
      valid_instrs_ex1           <= nxt_valid_instrs_ex1;
      head_instr_ex1             <= head_instr_iss;
      end_instr_ex1              <= nxt_end_instr_ex1;
      raw_rf_wr_en_w0_ex1        <= nxt_rf_wr_en_w0_ex1;
      raw_rf_wr_en_w1_ex1        <= rf_wr_en_w1_iss;
      raw_rf_wr_en_w2_ex1        <= nxt_rf_wr_en_w2_ex1;
      raw_rf_wr_en_w1_no_x64_ex1 <= rf_wr_en_w1_no_x64_iss;
      mod_pc_top_bits_ex1        <= mod_pc_top_bits_iss;
      thumb_instr0_ex1           <= thumb_instr0_iss;
      thumb_instr1_ex1           <= thumb_instr1_iss;
      muls_in_ex1                <= nxt_muls_in_ex1;
      instr_type_ex1             <= nxt_instr_type_ex1;
      exception_valid_ex1        <= nxt_exception_valid_ex1;
      flag_en_instr1_ex1         <= flag_en_instr1_iss;
    end

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      size_instr0_ex1         <= 1'b0;
      size_instr1_ex1         <= 1'b0;
      can_fwd_from_agu_ex1    <= 1'b0;
      alu0_a_w0_where_ex1     <= 1'b0;
      alu0_a_w1_where_ex1     <= 2'b00;
      alu0_a_w2_where_ex1     <= 2'b00;
      alu0_b_w0_where_ex1     <= 1'b0;
      alu0_b_w1_where_ex1     <= 2'b00;
      alu0_b_w2_where_ex1     <= 2'b00;
      alu1_a_w0_where_ex1     <= 1'b0;
      alu1_a_w1_where_ex1     <= 3'b000;
      alu1_a_w2_where_ex1     <= 2'b00;
      alu1_b_w0_where_ex1     <= 1'b0;
      alu1_b_w1_where_ex1     <= 3'b000;
      alu1_b_w2_where_ex1     <= 2'b00;
      str0_a_w0_where_ex1     <= 2'b00;
      str0_a_w1_where_ex1     <= 3'b000;
      str0_a_w2_where_ex1     <= 2'b00;
      str0_b_w0_where_ex1     <= 2'b00;
      str0_b_w2_where_ex1     <= 2'b00;
      str0_b_w1_where_ex1     <= 2'b00;
      str1_a_w0_where_ex1     <= 2'b00;
      str1_a_w1_where_ex1     <= 3'b000;
      str1_a_w2_where_ex1     <= 2'b00;
      str1_b_w0_where_ex1     <= 2'b00;
      str1_b_w1_where_ex1     <= 3'b000;
      str1_b_w2_where_ex1     <= 2'b00;
      enable_base_restore_ex1 <= 1'b0;
    end else if (issue_to_ex1) begin
      size_instr0_ex1         <= size_instr0_iss;
      size_instr1_ex1         <= size_instr1_iss;
      can_fwd_from_agu_ex1    <= can_fwd_from_agu_iss;
      alu0_a_w0_where_ex1     <= nxt_alu0_a_w0_where_ex1;
      alu0_a_w1_where_ex1     <= nxt_alu0_a_w1_where_ex1;
      alu0_a_w2_where_ex1     <= nxt_alu0_a_w2_where_ex1;
      alu0_b_w0_where_ex1     <= nxt_alu0_b_w0_where_ex1;
      alu0_b_w1_where_ex1     <= nxt_alu0_b_w1_where_ex1;
      alu0_b_w2_where_ex1     <= nxt_alu0_b_w2_where_ex1;
      alu1_a_w0_where_ex1     <= nxt_alu1_a_w0_where_ex1;
      alu1_a_w1_where_ex1     <= nxt_alu1_a_w1_where_ex1;
      alu1_a_w2_where_ex1     <= nxt_alu1_a_w2_where_ex1;
      alu1_b_w0_where_ex1     <= nxt_alu1_b_w0_where_ex1;
      alu1_b_w1_where_ex1     <= nxt_alu1_b_w1_where_ex1;
      alu1_b_w2_where_ex1     <= nxt_alu1_b_w2_where_ex1;
      str0_a_w0_where_ex1     <= nxt_str0_a_w0_where_ex1;
      str0_a_w1_where_ex1     <= nxt_str0_a_w1_where_ex1;
      str0_a_w2_where_ex1     <= nxt_str0_a_w2_where_ex1;
      str0_b_w0_where_ex1     <= nxt_str0_b_w0_where_ex1;
      str0_b_w2_where_ex1     <= nxt_str0_b_w2_where_ex1;
      str0_b_w1_where_ex1     <= nxt_str0_b_w1_where_ex1;
      str1_a_w0_where_ex1     <= nxt_str1_a_w0_where_ex1;
      str1_a_w1_where_ex1     <= nxt_str1_a_w1_where_ex1;
      str1_a_w2_where_ex1     <= nxt_str1_a_w2_where_ex1;
      str1_b_w0_where_ex1     <= nxt_str1_b_w0_where_ex1;
      str1_b_w1_where_ex1     <= nxt_str1_b_w1_where_ex1;
      str1_b_w2_where_ex1     <= nxt_str1_b_w2_where_ex1;
      enable_base_restore_ex1 <= enable_base_restore_iss_i;
    end

  // Most of the time the 'when' signal for W2 is set to late Wr,
  // with the only exception when instr1 is valid in which case it can be set to Ex2.
  // But if in instr0 we have a flag setting instruction and in instr1 we have
  // a conditinal code instruction we change the 'when' signal from Ex2 to early Wr.
  // This is because we don't want to use the correct cc_pass result (timing critical) until Wr
  // - Note that the only time slot 0 can contain a flag setting instruction
  //   when slot 1 is valid is when the slot 0 instruction is an ALU operation.
  assign rf_wr_when_w2_iss[WHN_NOT_E_WR] = raw_rf_wr_when_w2_iss[WHN_NOT_E_WR];
  assign rf_wr_when_w2_iss[WHN_NOT_EX2]  = raw_rf_wr_when_w2_iss[WHN_NOT_EX2] |
                                           (alu0_flagset_iss & valid_instrs_iss[1] & (cond_code_instr1_iss[3:1] != `CA53_CC_AL_or_NV));
  assign rf_wr_when_w2_iss[WHN_NOT_EX1]  = raw_rf_wr_when_w2_iss[WHN_NOT_EX1];

  always @(posedge clk)
    if (issue_to_ex1) begin
      msr_mrs_data_ex1      <= dsize_msr_mrs_data;
      rf_wr_addr_w0_ex1     <= nxt_rf_wr_addr_w0_ex1;
      rf_wr_addr_w1_ex1     <= rf_wr_addr_w1_iss;
      rf_wr_addr_w2_ex1     <= nxt_rf_wr_addr_w2_ex1;
      rf_wr_64b_w0_ex1      <= nxt_rf_wr_64b_w0_ex1;
      rf_wr_64b_w1_ex1      <= rf_wr_64b_w1_iss;
      rf_wr_64b_w2_ex1      <= nxt_rf_wr_64b_w2_ex1;
      rf_wr_src_w0_ex1      <= nxt_rf_wr_src_w0_ex1;
      rf_wr_src_w1_ex1      <= rf_wr_src_w1_iss;
      rf_wr_src_w2_ex1      <= nxt_rf_wr_src_w2_ex1;
      rf_rd_addr_r0_ex1     <= rf_rd_addr_r0_iss;
      rf_wr_when_w0_ex1     <= nxt_rf_wr_when_w0_ex1;
      rf_wr_when_w1_ex1     <= rf_wr_when_w1_iss;
      rf_wr_when_w2_ex1     <= rf_wr_when_w2_iss;
      w0_slot1_ex1          <= w0_slot1_iss;
      cond_code_instr0_ex1  <= special_cond_code_instr0_iss;
      cond_code_instr1_ex1  <= special_cond_code_instr1_iss;
      alu0_flagset_ex1      <= alu0_flagset_iss;
      alu1_flagset_ex1      <= alu1_flagset_iss;
      slot1_instr_type_ex1  <= slot1_instr_type_iss;
      rf_wr_vaddr_w0_ex1    <= rf_wr_vaddr_w0_iss;
      rf_wr_vaddr_w1_ex1    <= rf_wr_vaddr_w1_iss;
      rf_wr_vaddr_w2_ex1    <= rf_wr_vaddr_w2_iss;
    end

  // Integer write enables
  assign rf_wr_en_w0_iss = raw_rf_wr_en_w0_iss & valid_instrs_iss[0] & ~ilock_stall_iss & ((w0_slot1_iss | ~slot1_ls_iss) ? ~first_x64_iss_i
                                                                                                                          : ~second_x64_iss_i);
  assign rf_wr_en_w1_iss = raw_rf_wr_en_w1_iss & valid_instrs_iss[0] & ~stall_slot0_iss;
  assign rf_wr_en_w2_iss = raw_rf_wr_en_w2_iss & valid_instrs_iss[0] & ~ilock_stall_iss & ~first_x64_iss_i;

  // - Version of rf_wr_en_w1_iss without x64 factored in. Used to enable flat
  // fowarding on both halves of slot 0 ALU operations forwarding to a slot 1
  // cross 64 load/store with post-indexed addressing.
  assign rf_wr_en_w1_no_x64_iss = raw_rf_wr_en_w1_iss & valid_instrs_iss[0] & 
                                  ~(ilock_stall_iss | force_extra_lsm_cycle_i);  // Same as stall_slot0_iss, but with x64 term taken out

  assign rf_wr_en_w0_ex1        = raw_rf_wr_en_w0_ex1        & valid_instrs_ex1[0];
  assign rf_wr_en_w1_ex1        = raw_rf_wr_en_w1_ex1        & valid_instrs_ex1[0];
  assign rf_wr_en_w2_ex1        = raw_rf_wr_en_w2_ex1        & valid_instrs_ex1[0];
  assign rf_wr_en_w1_no_x64_ex1 = raw_rf_wr_en_w1_no_x64_ex1 & valid_instrs_ex1[0];

  // the w0 and w2 ex2 enables comes in three flavours:
  // 1) raw   : An instruction that uses the WP is seen.
  //            Used for clock gating and to calculate a possible interlock in Iss.
  // 2) early : Same as raw but anded with a speculative cc_pass when WP is used by slot1 (does not look at the instr0 results).
  //            We cannot use the raw because cc failing instruction should not set the mask.
  //            The speculative cc_pass is sufficient because the only time it could get it wrong is when the forward
  //            is delayed from Ex2 to Wr (instr0 flag setting, instr1 conditional).
  //            Used to calculate W2 ready mask.
  // 3) actual: (nxt_..._wr) Same as raw but using the final cc_pass even for instr1.
  //            Used into the forward logic both in Ex2 and in Wr
  assign rf_wr_en_w0_ex2 = raw_rf_wr_en_w0_ex2 & ((valid_instrs_ex2[1] & w0_slot1_ex2) ? cc_pass_instr1_early_ex2_i : (valid_instrs_ex2[0] & cc_pass_instr0_ex2_i));
  assign rf_wr_en_w1_ex2 = raw_rf_wr_en_w1_ex2 &                                                                       valid_instrs_ex2[0] & cc_pass_instr0_ex2_i;
  assign rf_wr_en_w2_ex2 = raw_rf_wr_en_w2_ex2 &  (valid_instrs_ex2[1]                 ? cc_pass_instr1_early_ex2_i : (valid_instrs_ex2[0] & cc_pass_instr0_ex2_i));

  // ------------------------------------------------------
  // Ex2 stage registers
  // ------------------------------------------------------

  assign nxt_head_instr_ex2 = head_instr_ex1[1:0]     & valid_instrs_ex1[1:0] & {2{~quash_ex1}};
  assign nxt_end_instr_ex2  = end_instr_ex1           & valid_instrs_ex1[0]   &    ~quash_ex1;

  assign nxt_save_base_ex2  = enable_base_restore_ex1 & head_instr_ex1[0] & issue_to_ex2;

  assign nxt_instr_type_ex2 = exception_valid_ex1 ? `CA53_INSTR_TYPE_SYNC_EXPT : instr_type_ex1;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      valid_instrs_ex2        <= 2'b00;
      head_instr_ex2          <= 2'b00;
      end_instr_ex2           <= 1'b0;
      raw_rf_wr_en_w0_ex2     <= 1'b0;
      raw_rf_wr_en_w1_ex2     <= 1'b0;
      raw_rf_wr_en_w2_ex2     <= 1'b0;
      mod_pc_top_bits_ex2     <= 1'b0;
      thumb_instr0_ex2        <= 1'b0;
      thumb_instr1_ex2        <= 1'b0;
      muls_in_ex2             <= 1'b0;
      flag_en_instr1_ex2      <= {`CA53_FLAGEN_INSTR1_W{1'b0}};
    end else if (en_btm_pc_ex2) begin
      valid_instrs_ex2        <= nxt_valid_instrs_ex2;
      head_instr_ex2          <= nxt_head_instr_ex2;
      end_instr_ex2           <= nxt_end_instr_ex2;
      raw_rf_wr_en_w0_ex2     <= rf_wr_en_w0_ex1;
      raw_rf_wr_en_w1_ex2     <= rf_wr_en_w1_ex1;
      raw_rf_wr_en_w2_ex2     <= rf_wr_en_w2_ex1;
      mod_pc_top_bits_ex2     <= mod_pc_top_bits_ex1;
      thumb_instr0_ex2        <= thumb_instr0_ex1;
      thumb_instr1_ex2        <= thumb_instr1_ex1;
      muls_in_ex2             <= muls_in_ex1;
      flag_en_instr1_ex2      <= flag_en_instr1_ex1;
    end

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      size_instr0_ex2         <= 1'b0;
      size_instr1_ex2         <= 1'b0;
      str0_a_w0_where_ex2     <= 1'b0;
      str0_a_w1_where_ex2     <= 2'b00;
      str0_a_w2_where_ex2     <= 1'b0;
      str0_b_w0_where_ex2     <= 1'b0;
      str0_b_w1_where_ex2     <= 1'b0;
      str0_b_w2_where_ex2     <= 1'b0;
      str1_a_w0_where_ex2     <= 1'b0;
      str1_a_w1_where_ex2     <= 2'b00;
      str1_a_w2_where_ex2     <= 1'b0;
      str1_b_w0_where_ex2     <= 1'b0;
      str1_b_w1_where_ex2     <= 2'b00;
      str1_b_w2_where_ex2     <= 1'b0;
      enable_base_restore_ex2 <= 1'b0;
      raw_save_base_ex2       <= 1'b0;
    end else if (issue_to_ex2) begin
      size_instr0_ex2         <= size_instr0_ex1;
      size_instr1_ex2         <= size_instr1_ex1;
      str0_a_w0_where_ex2     <= str0_a_w0_where_ex1[WHR_EX2];
      str0_a_w1_where_ex2     <= str0_a_w1_where_ex1[WHR_EX1:WHR_EX2];
      str0_a_w2_where_ex2     <= str0_a_w2_where_ex1[WHR_EX2];
      str0_b_w0_where_ex2     <= str0_b_w0_where_ex1[WHR_EX2];
      str0_b_w1_where_ex2     <= str0_b_w1_where_ex1[WHR_EX2];
      str0_b_w2_where_ex2     <= str0_b_w2_where_ex1[WHR_EX2];
      str1_a_w0_where_ex2     <= str1_a_w0_where_ex1[WHR_EX2];
      str1_a_w1_where_ex2     <= str1_a_w1_where_ex1[WHR_EX1:WHR_EX2];
      str1_a_w2_where_ex2     <= str1_a_w2_where_ex1[WHR_EX2];
      str1_b_w0_where_ex2     <= str1_b_w0_where_ex1[WHR_EX2];
      str1_b_w1_where_ex2     <= str1_b_w1_where_ex1[WHR_EX1:WHR_EX2];
      str1_b_w2_where_ex2     <= str1_b_w2_where_ex1[WHR_EX2];
      enable_base_restore_ex2 <= enable_base_restore_ex1;
      raw_save_base_ex2       <= nxt_save_base_ex2;
    end

  always @(posedge clk)
    if (issue_to_ex2) begin
      msr_mrs_data_ex2      <= msr_mrs_data_ex1;
      rf_wr_addr_w0_ex2     <= rf_wr_addr_w0_ex1;
      rf_wr_addr_w1_ex2     <= rf_wr_addr_w1_ex1;
      rf_wr_addr_w2_ex2     <= rf_wr_addr_w2_ex1;
      rf_wr_64b_w0_ex2      <= rf_wr_64b_w0_ex1;
      rf_wr_64b_w1_ex2      <= rf_wr_64b_w1_ex1;
      rf_wr_64b_w2_ex2      <= rf_wr_64b_w2_ex1;
      rf_wr_src_w0_ex2      <= rf_wr_src_w0_ex1;
      rf_wr_src_w1_ex2      <= rf_wr_src_w1_ex1;
      rf_wr_src_w2_ex2      <= rf_wr_src_w2_ex1;
      rf_wr_when_w0_ex2     <= rf_wr_when_w0_ex1;
      rf_wr_when_w1_ex2     <= rf_wr_when_w1_ex1;
      rf_wr_when_w2_ex2     <= rf_wr_when_w2_ex1;
      w0_slot1_ex2          <= w0_slot1_ex1;
      cond_code_instr0_ex2  <= cond_code_instr0_ex1;
      cond_code_instr1_ex2  <= cond_code_instr1_ex1;
      alu0_flagset_ex2      <= alu0_flagset_ex1;
      alu1_flagset_ex2      <= alu1_flagset_ex1;
      instr_type_ex2        <= nxt_instr_type_ex2;
      exception_valid_ex2   <= exception_valid_ex1;
      slot1_instr_type_ex2  <= slot1_instr_type_ex1;
    end

  always @(posedge clk)
    if (nxt_save_base_ex2)
      base_reg_number_ex2 <= rf_rd_addr_r0_ex1;

  assign save_base_ex2 = raw_save_base_ex2 & issue_to_wr & ~expt_quash_wr;

  // ------------------------------------------------------
  // Ex2 Hazard Resolution
  // ------------------------------------------------------

  // Integer pipeline hazard check
  // - The decoder checks that neither slot writes the same register on two
  // of its write ports, so if there is a match it must be because of a write
  // after write hazard on two dual issued instructions. In this case, the
  // write enable for the slot 0 instruction is suppressed (as slot 0 is the
  // older instruction).
  // - The following combinations are possible:
  //    W0 | W1 | W2
  //   ----|----|----
  //    S0 | S0 | S0
  //    S0 | S0 | S1  (Dec1 instruction in slot 1)
  //    S1 | S0 | S1  (LS instruction in slot 1)

  // - Suppress W0 if it matches W2, but not if it matches W1 (as W0 will be
  //   for slot 1 in that case)
  assign dual_iss_w0_hazard_ex2 = cc_pass_instr1_ex2_i &
                                   ({1'b1, rf_wr_addr_w0_ex2} == {raw_rf_wr_en_w2_ex2, rf_wr_addr_w2_ex2});

  // - Suppress W1 if it matches W0 or W2 (as it will only match when it is
  // for slot 0)
  assign dual_iss_w1_hazard_ex2 = cc_pass_instr1_ex2_i &
                                  (({1'b1, rf_wr_addr_w1_ex2} == {raw_rf_wr_en_w0_ex2, rf_wr_addr_w0_ex2}) |
                                   ({1'b1, rf_wr_addr_w1_ex2} == {raw_rf_wr_en_w2_ex2, rf_wr_addr_w2_ex2}));

  // - Never suppress W2, as it will only match when it's for slot 1

  // Suppress the write enables either on a hazard or a cc_failed instruction
  // This does not need to go to the forwarding logic since r14 from BL can not forward until Wr.
  assign nxt_rf_wr_en_w0_wr = raw_rf_wr_en_w0_ex2 & ~dual_iss_w0_hazard_ex2 & ((valid_instrs_ex2[1] & w0_slot1_ex2) ? cc_pass_instr1_ex2_i : (valid_instrs_ex2[0] & cc_pass_instr0_ex2_i));
  assign nxt_rf_wr_en_w1_wr =     rf_wr_en_w1_ex2 & ~dual_iss_w1_hazard_ex2;  // rf_wr_en_w1 takes cc_pass into account
  assign nxt_rf_wr_en_w2_wr = raw_rf_wr_en_w2_ex2 &                            (valid_instrs_ex2[1]                 ? cc_pass_instr1_ex2_i : (valid_instrs_ex2[0] & cc_pass_instr0_ex2_i));

  // ------------------------------------------------------
  // Wr stage registers
  // ------------------------------------------------------

  assign nxt_head_instr_wr = head_instr_ex2[1:0] & {2{~flush_wr}};
  assign nxt_end_instr_wr  = end_instr_ex2       &    ~flush_wr;

  // Create an enable signal to be used by the intermediate clock gate in the regbank
  // - Use raw version of W0/2 enable as can be used by instr1 and
  // cc_pass_instr1 is too late to factor in (W1 only ever used by instr0,
  // and cc_pass_instr0 is early to enough to be used).
  assign nxt_rf_wr_en_hi_wr = (raw_rf_wr_en_w0_ex2 | rf_wr_en_w1_ex2 | raw_rf_wr_en_w2_ex2 | nxt_en_restore) & aarch64_state_i;
  assign nxt_rf_wr_en_lo_wr =  raw_rf_wr_en_w0_ex2 | rf_wr_en_w1_ex2 | raw_rf_wr_en_w2_ex2 | nxt_en_restore;

  // Create an enable signal to select which flag will need to be updated
  assign nxt_flag_en_instr1_wr = flag_en_instr1_ex2[`CA53_FLAGEN_INSTR1_W-1:0] &
                                 {`CA53_FLAGEN_INSTR1_W{valid_instrs_ex2[1] & cc_pass_instr1_ex2_i & ~flush_wr}};

  assign nxt_mod_pc_top_bits_wr = mod_pc_top_bits_ex2 | (mod_pc_top_bits_wr & ~en_btm_pc_ret);

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      pre_valid_instrs_wr           <= 2'b00;
      pre_head_instr_wr             <= 2'b00;
      pre_end_instr_wr              <= 1'b0;
      raw_rf_wr_en_w0_wr            <= 1'b0;
      raw_rf_wr_en_w0_nohz_wr       <= 1'b0;
      raw_rf_wr_en_w1_wr            <= 1'b0;
      raw_rf_wr_en_w1_nohz_wr       <= 1'b0;
      raw_rf_wr_en_w2_wr            <= 1'b0;
      rf_wr_en_hi_wr                <= 1'b0;
      rf_wr_en_lo_wr                <= 1'b0;
      thumb_instr1_wr               <= 1'b0;
      muls_in_wr                    <= 1'b0;
      mod_pc_top_bits_wr            <= 1'b0;
      flag_en_instr1_wr             <= {`CA53_FLAGEN_INSTR1_W{1'b0}};
      enable_base_restore_wr        <= 1'b0;
    end else if (advance_pipeline) begin
      pre_valid_instrs_wr           <= nxt_valid_instrs_wr;
      pre_head_instr_wr             <= nxt_head_instr_wr;
      pre_end_instr_wr              <= nxt_end_instr_wr;
      raw_rf_wr_en_w0_wr            <= nxt_rf_wr_en_w0_wr;
      raw_rf_wr_en_w0_nohz_wr       <= rf_wr_en_w0_ex2;
      raw_rf_wr_en_w1_wr            <= nxt_rf_wr_en_w1_wr;
      raw_rf_wr_en_w1_nohz_wr       <= rf_wr_en_w1_ex2;
      raw_rf_wr_en_w2_wr            <= nxt_rf_wr_en_w2_wr;
      rf_wr_en_hi_wr                <= nxt_rf_wr_en_hi_wr;
      rf_wr_en_lo_wr                <= nxt_rf_wr_en_lo_wr;
      thumb_instr1_wr               <= thumb_instr1_ex2;
      muls_in_wr                    <= muls_in_ex2;
      mod_pc_top_bits_wr            <= nxt_mod_pc_top_bits_wr;
      flag_en_instr1_wr             <= nxt_flag_en_instr1_wr;
      enable_base_restore_wr        <= enable_base_restore_ex2;
    end

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      size_instr0_wr        <= 1'b0;
      size_instr1_wr        <= 1'b0;
      cc_pass_instr0_wr     <= 1'b1;
      cc_pass_instr1_wr     <= 1'b1;
    end else if (issue_to_wr) begin
      size_instr0_wr        <= size_instr0_ex2;
      size_instr1_wr        <= size_instr1_ex2;
      cc_pass_instr0_wr     <= cc_pass_instr0_cbz_ex2_i;
      cc_pass_instr1_wr     <= cc_pass_instr1_ex2_i;
    end

  always @(posedge clk)
    if (issue_to_wr) begin
      msr_mrs_data_wr             <= msr_mrs_data_ex2;
      raw_rf_wr_addr_w0_wr        <= rf_wr_addr_w0_ex2;
      rf_wr_addr_w1_wr            <= rf_wr_addr_w1_ex2;
      rf_wr_addr_w2_wr            <= rf_wr_addr_w2_ex2;
      raw_rf_wr_64b_w0_wr         <= rf_wr_64b_w0_ex2;
      rf_wr_64b_w1_wr             <= rf_wr_64b_w1_ex2;
      rf_wr_64b_w2_wr             <= rf_wr_64b_w2_ex2;
      raw_rf_wr_src_w0_wr         <= rf_wr_src_w0_ex2;
      rf_wr_src_w1_wr             <= rf_wr_src_w1_ex2;
      rf_wr_src_w2_wr             <= rf_wr_src_w2_ex2;
      rf_wr_when_n_early_wr_w0_wr <= rf_wr_when_w0_ex2[WHN_NOT_E_WR];
      rf_wr_when_n_early_wr_w1_wr <= rf_wr_when_w1_ex2[WHN_NOT_E_WR];
      rf_wr_when_n_early_wr_w2_wr <= rf_wr_when_w2_ex2[WHN_NOT_E_WR];
      w0_slot1_wr                 <= w0_slot1_ex2;
      instr_type_wr               <= instr_type_ex2;
      slot1_instr_type_wr         <= slot1_instr_type_ex2;
    end

  // Needs to be clocked on bubbles
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      thumb_instr0_wr <= 1'b0;
    else if (en_top_pc_wr)
      thumb_instr0_wr <= thumb_instr0_ex2;

  always @(posedge clk)
    if (save_base_ex2)
      base_reg_number_wr <= base_reg_number_ex2;

  // When there is an exception in slot 1 or the slot 0 instruction is a
  // mispredicted branch, the slot 0 write enables should
  // not be suppressed. There an only be an exception in slot 1 on
  // load/stores, and so only W1 can be being used by slot 0. In addition to
  // not suppressing the W1 write enable on a slot 1 exception, W1 must be
  // re-enabled if it is being suppressed because of a WAW hazard with slot
  // 1 (which no longer exists, because slot 1 will not do its write).
  assign reenable_w0_wr = raw_rf_wr_en_w0_nohz_wr & (early_expt_dcu_wr | slot0_br_flush_wr_i) & ~w0_slot1_wr;
  assign reenable_w1_wr = raw_rf_wr_en_w1_nohz_wr & (early_expt_dcu_wr | slot0_br_flush_wr_i);

  // W0 is either slot0 or slot1, so need to suppress if for slot 1
  assign rf_wr_en_w0_wr = ((raw_rf_wr_en_w0_wr | reenable_w0_wr) & ~(w0_slot1_wr ? quash_wr
                                                                                 : quash_slot0_wr) & ~slot0_br_flush_wr_i & pre_valid_instrs_wr[0] & ~stall_wr) |
                          en_restore;
  // W1 always belongs to slot 0, so never have to suppress on branch
  assign rf_wr_en_w1_wr =  (raw_rf_wr_en_w1_wr | reenable_w1_wr) &                ~quash_slot0_wr  &                        pre_valid_instrs_wr[0] & ~stall_wr;
  // W2 never used by branches so can always suppress
  assign rf_wr_en_w2_wr =   raw_rf_wr_en_w2_wr                   &                ~quash_wr        & ~slot0_br_flush_wr_i & pre_valid_instrs_wr[0] & ~stall_wr;

  // Generate the register file write mux select signals.  These
  // use early signals to alleviate timing problems.
  assign sel_rf_wr_w0_wr_o = (raw_rf_wr_en_w0_wr & ~(reenable_w1_wr & w0_slot1_wr))    | reenable_w0_wr  |  en_restore;
  assign sel_rf_wr_w1_wr_o = (raw_rf_wr_en_w1_wr                                       | reenable_w1_wr) & ~en_restore;
  assign sel_rf_wr_w2_wr_o = (raw_rf_wr_en_w2_wr & ~(reenable_w0_wr | reenable_w1_wr))                   & ~en_restore;

  assign rf_wr_addr_w0_wr = en_restore ? base_reg_number_wr      : raw_rf_wr_addr_w0_wr;
  assign rf_wr_src_w0_wr  = en_restore ? `CA53_RF_WR_SRC_W0_BASE : raw_rf_wr_src_w0_wr;
  assign rf_wr_64b_w0_wr  = en_restore ? aarch64_state_i         : raw_rf_wr_64b_w0_wr;

  // Register late exception signal for base reg restore (affects rf_wr_src)
  assign nxt_en_restore = expt_quash_wr & enable_base_restore_wr & no_interrupt_ls_wr;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      en_restore <= 1'b0;
    else
      en_restore <= nxt_en_restore;

  assign valid_instrs_wr       = pre_valid_instrs_wr & {2{~flush_ret | unflushable_wr}};
  assign head_instr_wr         = pre_head_instr_wr   & {2{~flush_ret}};

  assign end_instr_wr          = pre_end_instr_wr    & ~flush_ret & ~quash_no_data_wr;
  assign end_instr_no_quash_wr = pre_end_instr_wr    & ~flush_ret;

  // ------------------------------------------------------
  // Ret stage registers
  // ------------------------------------------------------

  // These signals are required by the debug block for the non-invasive debug control used
  // to enable the PC sampling register and performance monitors.

  // Register the syndrome fields for single-step exceptions
  assign nxt_soft_step_isv = ~insert_forceop_wr & (end_instr_wr ? (dbg_soft_step_active_i & cpsr_ssbit_ret_i) : soft_step_isv);
  assign nxt_halt_step_isv = ~insert_forceop_wr & (end_instr_wr ? dbg_halt_step_active_not_pend_i             : halt_step_isv);

  assign nxt_step_ex  = end_instr_wr ? (ls_valid_wr_i & ~ls_store_wr_i &
                                        ((ls_instr_type_wr_i == `CA53_LS_INSTR_EXCL_SGL) |
                                         (ls_instr_type_wr_i == `CA53_LS_INSTR_ORD_EXCL_SGL)))
                                     : step_ex;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      isa_instr0_ret    <= 2'b00;
      thumb_instr1_ret  <= 1'b0;
      soft_step_isv     <= 1'b0;
      halt_step_isv     <= 1'b0;
      pc_sample_perm_o  <= 1'b0;
    end else if (en_btm_pc_ret) begin
      isa_instr0_ret    <= isa_instr0_wr;
      thumb_instr1_ret  <= thumb_instr1_wr;
      soft_step_isv     <= nxt_soft_step_isv;
      halt_step_isv     <= nxt_halt_step_isv;
      pc_sample_perm_o  <= nxt_pc_sample_perm_i;
    end

  // Upper bits of the EDVIDSR register for the TLB
  assign nxt_dpu_dbg_vid = {ns_state, 
                            (dpu_exception_level_i == `CA53_EL2), 
                            (dpu_exception_level_i == `CA53_EL3) & aarch64_state_i, 
                            aarch64_state_i};

  // The PC calculation needs to know whether an exception in ret is being
  // caused by a slot 1 load/store and if so, what the size of the corresponding
  // slot 0 instruction is. This is needed to ensure that the forceop picks
  // up the correct PC value.
  always @(posedge clk)
    if (en_btm_pc_ret) begin
      size_instr0_ret  <= size_instr0_wr;
      size_instr1_ret  <= size_instr1_wr;
      expt_slot1_ret   <= expt_slot1_wr;
      step_ex          <= nxt_step_ex;
      dpu_dbg_vid_o    <= nxt_dpu_dbg_vid;
    end

  // ------------------------------------------------------
  // PC Pipeline
  // ------------------------------------------------------

  // Software can attempt to branch to an address outside the 49-bit range
  // supported by the v8 architecture, but this should always cause a prefetch
  // abort. As such, it is necessary to generate a full 64-bit PC in De, and
  // then register this into Iss, but the full value does not need to be
  // pipelined, as the IFU will stop sending instructions after the prefetch
  // abort.

  // When there is an x64 load/store in slot1, the PC pipeline is advanced with
  // the first half of the x64 (when the slot0 instruction advances). This is
  // required to allow the exception return address to be calculated if the
  // first part gets an abort from the DCU and the slot 0 instruction is a
  // branch (so the PC of the load/store is not pc_instr0 + size_instr0). By
  // ensuring that the PC of the next instruction is available in Ret when
  // the load/store is in Ret, the PC of the load/store can be calculated.
  // A side effect of this is that on the second half of the x64,
  // pc_instr0_iss will be for the slot0 instruction stalled in De. Therefore
  // need to track when this is the case so continue to calculate the correct
  // PC in De.

  assign nxt_instr0_de_pc_in_iss = stall_iss & (~stall_slot0_iss | instr0_de_pc_in_iss);

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      instr0_de_pc_in_iss <= 1'b0;
    else
      instr0_de_pc_in_iss <= nxt_instr0_de_pc_in_iss;

  assign instr0_de_pc_in_iss_o = instr0_de_pc_in_iss;

  // Bits [31:8] of the PC are only clocked when they are changing
  // Bits [63/48:32] of the PC are only clocked in AA64 state
  assign en_btm_pc_iss  = ~stall_slot0_iss | flush_wr;
  assign en_top_pc_iss  = en_btm_pc_iss & mod_pc_top_bits_de_i;
  assign en_aa64_pc_iss = en_top_pc_iss & (aarch64_state_i | isa_instr0_ret[1]);

  assign en_btm_pc_ex1  = ~stall_ex1_no_sfmac;
  assign en_top_pc_ex1  = en_btm_pc_ex1 & mod_pc_top_bits_iss;
  assign en_aa64_pc_ex1 = en_top_pc_ex1 & (aarch64_state_i | isa_instr0_ret[1]);

  assign en_btm_pc_ex2  = ~stall_ex2_no_sfmac;
  assign en_top_pc_ex2  = en_btm_pc_ex2 & mod_pc_top_bits_ex1;
  assign en_aa64_pc_ex2 = en_top_pc_ex2 & (aarch64_state_i | isa_instr0_ret[1]);

  assign en_top_pc_wr   = advance_pipeline & mod_pc_top_bits_ex2;
  assign en_aa64_pc_wr  = en_top_pc_wr & (aarch64_state_i | isa_instr0_ret[1]);
  
  assign en_btm_pc_ret  = insert_forceop_wr | ((valid_instrs_wr[0] & ~forceop_valid_wr & ~unflushable_wr) & advance_pipeline);
  assign en_top_pc_ret  = en_btm_pc_ret & mod_pc_top_bits_wr;
  assign en_aa64_pc_ret = en_top_pc_ret & (aarch64_state_i | isa_instr0_ret[1]);

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      mod_pc_top_bits_iss <= 1'b0;
    else if (en_btm_pc_iss)
      mod_pc_top_bits_iss <= mod_pc_top_bits_de_i;

  always @(posedge clk)
    if (en_btm_pc_iss)
      pc_instr0_iss[ 7: 0] <= pc_instr0_de_i[ 7: 0];

  always @(posedge clk)
    if (en_top_pc_iss)
      pc_instr0_iss[31: 8] <= pc_instr0_de_i[31: 8];

  always @(posedge clk)
    if (en_aa64_pc_iss)
      pc_instr0_iss[63:32] <= pc_instr0_de_i[63:32];


  always @(posedge clk)
    if (en_btm_pc_ex1)
      pc_instr0_ex1[ 7: 1] <= pc_instr0_iss[ 7: 1];

  always @(posedge clk)
    if (en_top_pc_ex1)
      pc_instr0_ex1[31: 8] <= pc_instr0_iss[31: 8];

  always @(posedge clk)
    if (en_aa64_pc_ex1)
      pc_instr0_ex1[48:32] <= pc_instr0_iss[48:32];


  always @(posedge clk)
    if (en_btm_pc_ex2)
      pc_instr0_ex2[ 7: 1] <= pc_instr0_ex1[ 7: 1];

  always @(posedge clk)
    if (en_top_pc_ex2)
      pc_instr0_ex2[31: 8] <= pc_instr0_ex1[31: 8];

  always @(posedge clk)
    if (en_aa64_pc_ex2)
      pc_instr0_ex2[48:32] <= pc_instr0_ex1[48:32];


  always @(posedge clk)
    if (advance_pipeline)
      raw_pc_instr0_wr[ 7: 1]  <= pc_instr0_ex2[ 7: 1];

  always @(posedge clk)
    if (en_top_pc_wr)
      raw_pc_instr0_wr[31: 8]  <= pc_instr0_ex2[31: 8];

  always @(posedge clk)
    if (en_aa64_pc_wr)
      raw_pc_instr0_wr[48:32]  <= pc_instr0_ex2[48:32];


  always @(posedge clk)
    if (en_btm_pc_ret)
      raw_pc_instr0_ret[ 7: 1] <= raw_pc_instr0_wr[ 7: 1];

   always @(posedge clk)
    if (en_top_pc_ret)
      raw_pc_instr0_ret[31: 8] <= raw_pc_instr0_wr[31: 8];

   always @(posedge clk)
    if (en_aa64_pc_ret)
      raw_pc_instr0_ret[48:32] <= raw_pc_instr0_wr[48:32];

  // In the case of a prefetch abort, the bits in [63:49] of the PC might not
  // be a simple sign extension of bit [48], and bit [0] might be non-zero
  // If there are no other instructions in the pipeline, take these bits from
  // the full-width iss-stage PC, which will not have changed since the abort
  // was in iss

  assign nxt_full_pc_ex1 = ~valid_instrs_iss[0] | expt_full_pc_iss | in_halt_i;

  always @(posedge clk)
    if (en_btm_pc_ex1)
      full_pc_ex1 <= nxt_full_pc_ex1;

  always @(posedge clk)
    if (en_btm_pc_ex2)
      full_pc_ex2 <= full_pc_ex1;

  always @(posedge clk)
    if (advance_pipeline)
      full_pc_wr <= full_pc_ex2;

  always @(posedge clk)
    if (en_btm_pc_ret)
      full_pc_ret <= full_pc_wr;

  assign pc_instr0_wr[63:49] = (full_pc_wr & full_pc_ex2 & full_pc_ex1) ? pc_instr0_iss[63:49] : {15{raw_pc_instr0_wr[48]}};
  assign pc_instr0_wr[48: 1] = raw_pc_instr0_wr[48: 1];
  assign pc_instr0_wr[ 0]    = (full_pc_wr & full_pc_ex2 & full_pc_ex1) ? pc_instr0_iss[0] : 1'b0;

  assign pc_instr0_ret[63:49] = (full_pc_ret & full_pc_wr & full_pc_ex2 & full_pc_ex1) ? pc_instr0_iss[63:49] : {15{raw_pc_instr0_ret[48]}};
  assign pc_instr0_ret[48: 1] = raw_pc_instr0_ret[48: 1];
  assign pc_instr0_ret[ 0]    = (full_pc_ret & full_pc_wr & full_pc_ex2 & full_pc_ex1) ? pc_instr0_iss[0] : 1'b0;

  // ------------------------------------------------------
  // Iss stage PC outputs
  // ------------------------------------------------------

  assign raw_pc_instr1_iss[48:1] = pc_instr0_iss[48:1] + (size_instr0_iss ? 2'b10 : 2'b01);

  // In AArch32 the above addition could wrap on a 32-bit boundary - mask out
  // the carry from bit [32] in this case
  assign pc_instr1_iss[48:1]     = raw_pc_instr1_iss[48:1] & { {16{1'b1}}, aarch64_state_i, {31{1'b1}} };

  assign pc_instr0_iss_o = pc_instr0_iss[63:0];
  assign pc_instr1_iss_o = pc_instr1_iss;

  // ------------------------------------------------------
  // ISA and Size
  // ------------------------------------------------------

  assign isa_instr0_iss = {aarch64_state_i, thumb_instr0_iss};
  assign isa_instr0_ex2 = {aarch64_state_i, thumb_instr0_ex2};
  assign isa_instr0_wr  = {aarch64_state_i, thumb_instr0_wr};

  // During force operation, speculative size setting is 32-bit
  assign nxt_size_instr0_iss = forceop_valid_de ? 1'b1 : size_instr0_de_i;

  // ------------------------------------------------------
  // Interlock logic and forward control generation
  // ------------------------------------------------------
  //
  // The following sections encompass the interlock and forwarding logic
  //
  // However, first, register comparisions based on the De address (if the pipeline is not
  // stalled) or based on the Iss address (if the pipeline is stalled) are completed and then
  // registered to improve interlock generation in the Iss pipeline stage.
  //
  // Make sure that the Ex2 check uses the condition code qualified register file write enable
  // so that a potential interlock can be disabled as early as possible.
  //
  // Because of timing effects created by skidding on read-ports 2 and 3 it is only possible
  // to optimize read-ports 0 and 1.

  // Compare De with:
  // - Ex1                       
  assign addr_cmp_de_ex1[R0][W0]  = (rf_rd_addr_r0_de_i == rf_wr_addr_w0_ex1) & rf_rd_en_r0_de_i & raw_rf_wr_en_w0_ex1;
  assign addr_cmp_de_ex1[R0][W1]  = (rf_rd_addr_r0_de_i == rf_wr_addr_w1_ex1) & rf_rd_en_r0_de_i & raw_rf_wr_en_w1_ex1;
  assign addr_cmp_de_ex1[R0][W2]  = (rf_rd_addr_r0_de_i == rf_wr_addr_w2_ex1) & rf_rd_en_r0_de_i & raw_rf_wr_en_w2_ex1;
                                 
  assign addr_cmp_de_ex1[R1][W0]  = (rf_rd_addr_r1_de_i == rf_wr_addr_w0_ex1) & rf_rd_en_r1_de_i & raw_rf_wr_en_w0_ex1;
  assign addr_cmp_de_ex1[R1][W1]  = (rf_rd_addr_r1_de_i == rf_wr_addr_w1_ex1) & rf_rd_en_r1_de_i & raw_rf_wr_en_w1_ex1;
  assign addr_cmp_de_ex1[R1][W2]  = (rf_rd_addr_r1_de_i == rf_wr_addr_w2_ex1) & rf_rd_en_r1_de_i & raw_rf_wr_en_w2_ex1;
                                 
  // - Ex2                       
  assign addr_cmp_de_ex2[R0][W0]  = (rf_rd_addr_r0_de_i == rf_wr_addr_w0_ex2) & rf_rd_en_r0_de_i & nxt_rf_wr_en_w0_wr;
  assign addr_cmp_de_ex2[R0][W1]  = (rf_rd_addr_r0_de_i == rf_wr_addr_w1_ex2) & rf_rd_en_r0_de_i & nxt_rf_wr_en_w1_wr;
  assign addr_cmp_de_ex2[R0][W2]  = (rf_rd_addr_r0_de_i == rf_wr_addr_w2_ex2) & rf_rd_en_r0_de_i & nxt_rf_wr_en_w2_wr;
                                 
  assign addr_cmp_de_ex2[R1][W0]  = (rf_rd_addr_r1_de_i == rf_wr_addr_w0_ex2) & rf_rd_en_r1_de_i & nxt_rf_wr_en_w0_wr;
  assign addr_cmp_de_ex2[R1][W1]  = (rf_rd_addr_r1_de_i == rf_wr_addr_w1_ex2) & rf_rd_en_r1_de_i & nxt_rf_wr_en_w1_wr;
  assign addr_cmp_de_ex2[R1][W2]  = (rf_rd_addr_r1_de_i == rf_wr_addr_w2_ex2) & rf_rd_en_r1_de_i & nxt_rf_wr_en_w2_wr;

  // Compare Iss with:
  // - Ex1
  assign addr_cmp_iss_ex1[R0][W0] = (rf_rd_addr_r0_iss == rf_wr_addr_w0_ex1) & rf_rd_en_r0_iss & raw_rf_wr_en_w0_ex1;
  assign addr_cmp_iss_ex1[R0][W1] = (rf_rd_addr_r0_iss == rf_wr_addr_w1_ex1) & rf_rd_en_r0_iss & raw_rf_wr_en_w1_ex1;
  assign addr_cmp_iss_ex1[R0][W2] = (rf_rd_addr_r0_iss == rf_wr_addr_w2_ex1) & rf_rd_en_r0_iss & raw_rf_wr_en_w2_ex1;
                                                                                                                  
  assign addr_cmp_iss_ex1[R1][W0] = (rf_rd_addr_r1_iss == rf_wr_addr_w0_ex1) & rf_rd_en_r1_iss & raw_rf_wr_en_w0_ex1;
  assign addr_cmp_iss_ex1[R1][W1] = (rf_rd_addr_r1_iss == rf_wr_addr_w1_ex1) & rf_rd_en_r1_iss & raw_rf_wr_en_w1_ex1;
  assign addr_cmp_iss_ex1[R1][W2] = (rf_rd_addr_r1_iss == rf_wr_addr_w2_ex1) & rf_rd_en_r1_iss & raw_rf_wr_en_w2_ex1;

  // - Ex2
  assign addr_cmp_iss_ex2[R0][W0] = (rf_rd_addr_r0_iss == rf_wr_addr_w0_ex2) & rf_rd_en_r0_iss & nxt_rf_wr_en_w0_wr;
  assign addr_cmp_iss_ex2[R0][W1] = (rf_rd_addr_r0_iss == rf_wr_addr_w1_ex2) & rf_rd_en_r0_iss & nxt_rf_wr_en_w1_wr;
  assign addr_cmp_iss_ex2[R0][W2] = (rf_rd_addr_r0_iss == rf_wr_addr_w2_ex2) & rf_rd_en_r0_iss & nxt_rf_wr_en_w2_wr;
                                                                                                              
  assign addr_cmp_iss_ex2[R1][W0] = (rf_rd_addr_r1_iss == rf_wr_addr_w0_ex2) & rf_rd_en_r1_iss & nxt_rf_wr_en_w0_wr;
  assign addr_cmp_iss_ex2[R1][W1] = (rf_rd_addr_r1_iss == rf_wr_addr_w1_ex2) & rf_rd_en_r1_iss & nxt_rf_wr_en_w1_wr;
  assign addr_cmp_iss_ex2[R1][W2] = (rf_rd_addr_r1_iss == rf_wr_addr_w2_ex2) & rf_rd_en_r1_iss & nxt_rf_wr_en_w2_wr;

  // - Wr
  assign addr_cmp_iss_wr[R0][W0]  = (rf_rd_addr_r0_iss == raw_rf_wr_addr_w0_wr) & rf_rd_en_r0_iss & raw_rf_wr_en_w0_wr;
  assign addr_cmp_iss_wr[R0][W1]  = (rf_rd_addr_r0_iss ==     rf_wr_addr_w1_wr) & rf_rd_en_r0_iss & raw_rf_wr_en_w1_wr;
  assign addr_cmp_iss_wr[R0][W2]  = (rf_rd_addr_r0_iss ==     rf_wr_addr_w2_wr) & rf_rd_en_r0_iss & raw_rf_wr_en_w2_wr;
                                 
  assign addr_cmp_iss_wr[R1][W0]  = (rf_rd_addr_r1_iss == raw_rf_wr_addr_w0_wr) & rf_rd_en_r1_iss & raw_rf_wr_en_w0_wr;
  assign addr_cmp_iss_wr[R1][W1]  = (rf_rd_addr_r1_iss ==     rf_wr_addr_w1_wr) & rf_rd_en_r1_iss & raw_rf_wr_en_w1_wr;
  assign addr_cmp_iss_wr[R1][W2]  = (rf_rd_addr_r1_iss ==     rf_wr_addr_w2_wr) & rf_rd_en_r1_iss & raw_rf_wr_en_w2_wr;

  // For Ex2, choose between the comparisons depending on the type of stall
  assign nxt_early_addr_cmp_iss_ex2[R0] = stall_wr  ? addr_cmp_iss_ex2[R0] :
                                          stall_iss ? addr_cmp_iss_ex1[R0] : 
                                                      addr_cmp_de_ex1[R0];
                                 
  assign nxt_early_addr_cmp_iss_ex2[R1] = stall_wr  ? addr_cmp_iss_ex2[R1] :
                                          stall_iss ? addr_cmp_iss_ex1[R1] : 
                                                      addr_cmp_de_ex1[R1];
                                 
  // For Wr, choose between the comparisons depending on the type of stall
  assign nxt_early_addr_cmp_iss_wr[R0]  = stall_wr  ? addr_cmp_iss_wr[R0]  :
                                          stall_iss ? addr_cmp_iss_ex2[R0] : 
                                                      addr_cmp_de_ex2[R0];
                                 
  assign nxt_early_addr_cmp_iss_wr[R1]  = stall_wr  ? addr_cmp_iss_wr[R1]  :
                                          stall_iss ? addr_cmp_iss_ex2[R1] : 
                                                      addr_cmp_de_ex2[R1];
                                 
  // ------------------------------------------------------
  // Iss 'where' signal for the integer forwarding logic
  // ------------------------------------------------------

  // The forwarding and interlock logic is built around the fact that there are five read ports
  // and three write ports.  Hazards are detected on this basis.  Forwarding muxes after issue
  // are not rigidly tied to read ports so it is necessary to map the read ports to forwarding
  // points in order to correctly control the muxes; the state to control that is kept here.
  //
  // There is a basic framework of forwarding and interlocking that is driven by data from the
  // decoders and then special case logic is wired over the top.
  //
  // The general principle is:
  //
  // The fowarding logic is arranged so that an operation always gets the most up to date value
  // available for the register it is waiting for even if it is still interlocked.  This ensures
  // that when an instruction is waiting on an instruction that subsequently cc-fails it still
  // has the correct value.
  //
  // The decoder tells us when an operation "need"s its data by, that is the last pipe stage
  // that forwarded data can be accepted, this is encoded as:
  //
  // Need early in iss : 111
  // Need late in iss  : 110
  // Need in ex1       : 100
  // Need in ex2       : 000
  //
  // and there is "need" information per read port.  The decoder also tells us "when" the results
  // of the operation will be ready, encoded as:
  //
  // ready late in ex1 : 000
  // ready late in ex2 : 001
  // ready early in wr : 011
  // ready late in wr  : 111
  //
  // In order to determine if there are any hazards and where to forward data from, all valid
  // source register numbers are compared with valid register writes in the pipeline to produce
  // the "where" arrays.  There is a "where" array for the cross product of all read and write
  // ports.  They are three bits long each and are interpreted as:
  //
  // r0_w0_where_iss = [ex1,ex2,wr] :
  //
  //    the register number being read on register port r0 will be written at write port w0 by
  //    the operation(s) in the pipe stage(s) that have a 1 in the array. An array of [1,0,1]
  //    shows us that there are operations in ex1 and wr that will write to w0 the register
  //    number being read on port r0.
  //
  // Each destination forwarding point is mapped onto the appropriate read port "where" signal,
  // which is then pipelined into ex1 so the forwarding muxes in ex1/ex2 do not have to do any
  // comparisons.
  //
  // The forwarding logic only forwards data once the producing operation has actually produced
  // the data (as indicated by "when").  Three ready masks (one per write port) are generated to
  // indicate where in the pipeline there is data ready to be forwarded if it is desired.  The
  // ready masks are then combined with the "where" arrays to produce the "available" arrays.
  // There is an "available" array for each of the cross product of the read and write ports in
  // iss, and for the cross product of the forwarding destinations and write ports in ex1/ex2.
  // The arrays indicate whereabouts in the pipeline there is data that is ready to be forwarded
  // that is being read in iss, ex1 and ex2.
  
  // The "available" masks are priority encoded to produce the controls for the forwarding muxes
  // in iss, ex1 and ex2.  The iss forwarding controls are then used by the forwarding muxes.
  // The ex1 controls are mapped onto the ALU0, ALU1, STR0 and STR1 forwarding controls and
  // exported.
  //
  // When prioritising between multiple forwarding sources, the "youngest" available value is
  // selected - so forwarding from an instruction in ex1 takes priority over an instruction in
  // ex2.  There can be two instructions in the same pipeline stage which write the same
  // register, so it is necessary to prioritise also between the different write ports within
  // each pipeline stage.  W1 is always used only by slot 1, so is considered the "oldest",
  // while W2 is only used by a slot 0 instruction if no slot 1 instruction is present and is
  // considered the "youngest".  W0 can be used by either instruction, and so is in the middle.
  //
  // When a value has been forwarded, the "where" signals in subsequent stages corresponding to
  // that forwarding source or any older data must be suppressed, to prevent re-forwarding the 
  // same data after the "need" stage of the destination, and to prevent forwarding older data
  // on top of newer data in a later stage.
  //
  // The interlock signal is then generated by looking at the "where" arrays and when each read
  // port "need"s its data.  If the read port has a "need" value that is earlier than the "when"
  // value of the most up to date value in flight an interlock is raised.

  // Read port 2 has an additional "where" bit for the Iss stage, as a slot 1 store can accept
  // forwarded data in Wr from the instruction in slot 0

  // Write port 0
  // Discover 'where' in the pipeline is going to write to the register number we want to read.
  // Pipeline the issue version into ex1 so we don't have to repeat the comparisons, and the same
  // for ex1 to ex2.
  //
  // Make sure that the Ex2 check uses the condition code qualified register file write enable
  // so that a potential interlock can be disabled as early as possible.

  assign r0_w0_where_iss = {((rf_rd_addr_r0_iss ==     rf_wr_addr_w0_ex1) & rf_rd_en_r0_iss & raw_rf_wr_en_w0_ex1),
                            early_addr_cmp_iss_ex2[R0][W0],
                            early_addr_cmp_iss_wr[ R0][W0]};

  assign r1_w0_where_iss = {((rf_rd_addr_r1_iss ==     rf_wr_addr_w0_ex1) & rf_rd_en_r1_iss & raw_rf_wr_en_w0_ex1),
                            early_addr_cmp_iss_ex2[R1][W0],
                            early_addr_cmp_iss_wr[ R1][W0]};

  assign r2_w0_where_iss = {((rf_rd_addr_r2_iss ==     rf_wr_addr_w0_ex1) & rf_rd_en_r2_iss & raw_rf_wr_en_w0_ex1),
                            ((rf_rd_addr_r2_iss ==     rf_wr_addr_w0_ex2) & rf_rd_en_r2_iss & raw_rf_wr_en_w0_ex2),
                            ((rf_rd_addr_r2_iss == raw_rf_wr_addr_w0_wr)  & rf_rd_en_r2_iss & raw_rf_wr_en_w0_wr)};

  assign r3_w0_where_iss = {((rf_rd_addr_r3_iss ==     rf_wr_addr_w0_ex1) & rf_rd_en_r3_iss & raw_rf_wr_en_w0_ex1),
                            ((rf_rd_addr_r3_iss ==     rf_wr_addr_w0_ex2) & rf_rd_en_r3_iss & raw_rf_wr_en_w0_ex2),
                            ((rf_rd_addr_r3_iss == raw_rf_wr_addr_w0_wr)  & rf_rd_en_r3_iss & raw_rf_wr_en_w0_wr)};

  assign r4_w0_where_iss = {((rf_rd_addr_r4_iss ==     rf_wr_addr_w0_ex1) & rf_rd_en_r4_iss & raw_rf_wr_en_w0_ex1),
                            ((rf_rd_addr_r4_iss ==     rf_wr_addr_w0_ex2) & rf_rd_en_r4_iss & raw_rf_wr_en_w0_ex2),
                            ((rf_rd_addr_r4_iss == raw_rf_wr_addr_w0_wr)  & rf_rd_en_r4_iss & raw_rf_wr_en_w0_wr)};

  // Write port 1
  // - When a slot 0 ALU operation needs to flat forward to a load/store in slot
  // 1 which is doing post-indexed writeback, and the load/store is x64, we
  // need to forward from ALU0 to ALU1 on the second half of the x64, as that is
  // when the writeback is done. Normally however, a slot 0 instruction proceeds
  // with the first half of a slot 1 x64 instruction. Therefore, to enable the
  // correct forwarding, the slot 0 instruction forwards out on both halves of
  // the x64, so the write enable used to calculate the forwarding does not have
  // x64 factored in (i.e. it is set on both halves).
  assign r0_w1_where_iss = {((rf_rd_addr_r0_iss == rf_wr_addr_w1_iss)     & rf_rd_en_r0_iss &     rf_wr_en_w1_no_x64_iss & ~r01_slot0_iss),
                            ((rf_rd_addr_r0_iss == rf_wr_addr_w1_ex1)     & rf_rd_en_r0_iss & raw_rf_wr_en_w1_ex1),
                            early_addr_cmp_iss_ex2[R0][W1],
                            early_addr_cmp_iss_wr[ R0][W1]};

  assign r1_w1_where_iss = {((rf_rd_addr_r1_iss == rf_wr_addr_w1_iss)     & rf_rd_en_r1_iss &     rf_wr_en_w1_no_x64_iss & ~r01_slot0_iss),
                            ((rf_rd_addr_r1_iss == rf_wr_addr_w1_ex1)     & rf_rd_en_r1_iss & raw_rf_wr_en_w1_ex1),
                            early_addr_cmp_iss_ex2[R1][W1],
                            early_addr_cmp_iss_wr[ R1][W1]};

  assign r2_w1_where_iss = {((rf_rd_addr_r2_iss == rf_wr_addr_w1_iss)     & rf_rd_en_r2_iss &     rf_wr_en_w1_no_x64_iss & ~r2_slot0_iss),
                            ((rf_rd_addr_r2_iss == rf_wr_addr_w1_ex1)     & rf_rd_en_r2_iss & raw_rf_wr_en_w1_ex1),
                            ((rf_rd_addr_r2_iss == rf_wr_addr_w1_ex2)     & rf_rd_en_r2_iss & raw_rf_wr_en_w1_ex2),
                            ((rf_rd_addr_r2_iss == rf_wr_addr_w1_wr)      & rf_rd_en_r2_iss & raw_rf_wr_en_w1_wr)};

  assign r3_w1_where_iss = {((rf_rd_addr_r3_iss == rf_wr_addr_w1_iss)     & rf_rd_en_r3_iss &     rf_wr_en_w1_no_x64_iss & ~r34_slot0_iss),
                            ((rf_rd_addr_r3_iss == rf_wr_addr_w1_ex1)     & rf_rd_en_r3_iss & raw_rf_wr_en_w1_ex1),
                            ((rf_rd_addr_r3_iss == rf_wr_addr_w1_ex2)     & rf_rd_en_r3_iss & raw_rf_wr_en_w1_ex2),
                            ((rf_rd_addr_r3_iss == rf_wr_addr_w1_wr)      & rf_rd_en_r3_iss & raw_rf_wr_en_w1_wr)};

  assign r4_w1_where_iss = {((rf_rd_addr_r4_iss == rf_wr_addr_w1_iss)     & rf_rd_en_r4_iss &     rf_wr_en_w1_no_x64_iss & ~r34_slot0_iss),
                            ((rf_rd_addr_r4_iss == rf_wr_addr_w1_ex1)     & rf_rd_en_r4_iss & raw_rf_wr_en_w1_ex1),
                            ((rf_rd_addr_r4_iss == rf_wr_addr_w1_ex2)     & rf_rd_en_r4_iss & raw_rf_wr_en_w1_ex2),
                            ((rf_rd_addr_r4_iss == rf_wr_addr_w1_wr)      & rf_rd_en_r4_iss & raw_rf_wr_en_w1_wr)};

  // Write port 2
  assign r0_w2_where_iss = {((rf_rd_addr_r0_iss == rf_wr_addr_w2_ex1)     & rf_rd_en_r0_iss & raw_rf_wr_en_w2_ex1),
                            early_addr_cmp_iss_ex2[R0][W2],
                            early_addr_cmp_iss_wr[ R0][W2]};

  assign r1_w2_where_iss = {((rf_rd_addr_r1_iss == rf_wr_addr_w2_ex1)     & rf_rd_en_r1_iss & raw_rf_wr_en_w2_ex1),
                            early_addr_cmp_iss_ex2[R1][W2],
                            early_addr_cmp_iss_wr[ R1][W2]};

  assign r2_w2_where_iss = {((rf_rd_addr_r2_iss == rf_wr_addr_w2_ex1)     & rf_rd_en_r2_iss & raw_rf_wr_en_w2_ex1),
                            ((rf_rd_addr_r2_iss == rf_wr_addr_w2_ex2)     & rf_rd_en_r2_iss & raw_rf_wr_en_w2_ex2),
                            ((rf_rd_addr_r2_iss == rf_wr_addr_w2_wr)      & rf_rd_en_r2_iss & raw_rf_wr_en_w2_wr)};

  assign r3_w2_where_iss = {((rf_rd_addr_r3_iss == rf_wr_addr_w2_ex1)     & rf_rd_en_r3_iss & raw_rf_wr_en_w2_ex1),
                            ((rf_rd_addr_r3_iss == rf_wr_addr_w2_ex2)     & rf_rd_en_r3_iss & raw_rf_wr_en_w2_ex2),
                            ((rf_rd_addr_r3_iss == rf_wr_addr_w2_wr)      & rf_rd_en_r3_iss & raw_rf_wr_en_w2_wr)};

  assign r4_w2_where_iss = {((rf_rd_addr_r4_iss == rf_wr_addr_w2_ex1)     & rf_rd_en_r4_iss & raw_rf_wr_en_w2_ex1),
                            ((rf_rd_addr_r4_iss == rf_wr_addr_w2_ex2)     & rf_rd_en_r4_iss & raw_rf_wr_en_w2_ex2),
                            ((rf_rd_addr_r4_iss == rf_wr_addr_w2_wr)      & rf_rd_en_r4_iss & raw_rf_wr_en_w2_wr)};

  // ------------------------------------------------------
  // Ex1 and Ex2 'where' signal generation
  // ------------------------------------------------------

  // If we have forwarded into Iss then suppress forwarding the same value into
  // Ex1 in the same cycle (as this may then be after the "need" for the
  // destination instruction).  It's also necessary to suppressing the "where"
  // signals corresponding to older instructions, to prevent overwriting the
  // forwarded data with data from an older instruction in a subsequent cycle

  // Pipeline the signals controlling the Wr->Wr forwarding path for stores
  assign nxt_r0_w1_where_ex1[WHR_EX1] = r0_w1_where_iss[WHR_ISS];
  assign nxt_r1_w1_where_ex1[WHR_EX1] = r1_w1_where_iss[WHR_ISS];
  assign nxt_r2_w1_where_ex1[WHR_EX1] = r2_w1_where_iss[WHR_ISS];
  assign nxt_r3_w1_where_ex1[WHR_EX1] = r3_w1_where_iss[WHR_ISS];
  assign nxt_r4_w1_where_ex1[WHR_EX1] = r4_w1_where_iss[WHR_ISS];

  assign nxt_r1_w0_where_ex1[WHR_EX2] = r1_w0_where_iss[WHR_EX1] & ~r1_w2_available_iss[WHR_EX1];
  assign nxt_r2_w0_where_ex1[WHR_EX2] = r2_w0_where_iss[WHR_EX1] & ~r2_w2_available_iss[WHR_EX1];
  assign nxt_r3_w0_where_ex1[WHR_EX2] = r3_w0_where_iss[WHR_EX1] & ~r3_w2_available_iss[WHR_EX1];
  assign nxt_r4_w0_where_ex1[WHR_EX2] = r4_w0_where_iss[WHR_EX1] & ~r4_w2_available_iss[WHR_EX1];

  assign nxt_r0_w1_where_ex1[WHR_EX2] = r0_w1_where_iss[WHR_EX1] & ~r0_w2_available_iss[WHR_EX1] & ~r0_w1_available_iss[WHR_EX1];
  assign nxt_r1_w1_where_ex1[WHR_EX2] = r1_w1_where_iss[WHR_EX1] & ~r1_w2_available_iss[WHR_EX1] & ~r1_w1_available_iss[WHR_EX1];
  assign nxt_r2_w1_where_ex1[WHR_EX2] = r2_w1_where_iss[WHR_EX1] & ~r2_w2_available_iss[WHR_EX1] & ~r2_w1_available_iss[WHR_EX1];
  assign nxt_r3_w1_where_ex1[WHR_EX2] = r3_w1_where_iss[WHR_EX1] & ~r3_w2_available_iss[WHR_EX1] & ~r3_w1_available_iss[WHR_EX1];
  assign nxt_r4_w1_where_ex1[WHR_EX2] = r4_w1_where_iss[WHR_EX1] & ~r4_w2_available_iss[WHR_EX1] & ~r4_w1_available_iss[WHR_EX1];

  assign nxt_r0_w2_where_ex1[WHR_EX2] = r0_w2_where_iss[WHR_EX1] & ~r0_w2_available_iss[WHR_EX1];
  assign nxt_r1_w2_where_ex1[WHR_EX2] = r1_w2_where_iss[WHR_EX1] & ~r1_w2_available_iss[WHR_EX1];
  assign nxt_r2_w2_where_ex1[WHR_EX2] = r2_w2_where_iss[WHR_EX1] & ~r2_w2_available_iss[WHR_EX1];
  assign nxt_r3_w2_where_ex1[WHR_EX2] = r3_w2_where_iss[WHR_EX1] & ~r3_w2_available_iss[WHR_EX1];
  assign nxt_r4_w2_where_ex1[WHR_EX2] = r4_w2_where_iss[WHR_EX1] & ~r4_w2_available_iss[WHR_EX1];

  assign nxt_r0_w0_where_ex1[WHR_WR] = r0_w0_where_iss[WHR_EX2] & ~(|r0_w2_available_iss[WHR_EX1:WHR_EX2]) &   ~r0_w1_available_iss[WHR_EX1];
  assign nxt_r1_w0_where_ex1[WHR_WR] = r1_w0_where_iss[WHR_EX2] & ~(|r1_w2_available_iss[WHR_EX1:WHR_EX2]) &   ~r1_w1_available_iss[WHR_EX1];
  assign nxt_r2_w0_where_ex1[WHR_WR] = r2_w0_where_iss[WHR_EX2] & ~(|r2_w2_available_iss[WHR_EX1:WHR_EX2]) &   ~r2_w1_available_iss[WHR_EX1];
  assign nxt_r3_w0_where_ex1[WHR_WR] = r3_w0_where_iss[WHR_EX2] & ~(|r3_w2_available_iss[WHR_EX1:WHR_EX2]) &   ~r3_w1_available_iss[WHR_EX1];
  assign nxt_r4_w0_where_ex1[WHR_WR] = r4_w0_where_iss[WHR_EX2] & ~(|r4_w2_available_iss[WHR_EX1:WHR_EX2]) &   ~r4_w1_available_iss[WHR_EX1];
                                                                                         
  assign nxt_r0_w1_where_ex1[WHR_WR] = r0_w1_where_iss[WHR_EX2] & ~(|r0_w2_available_iss[WHR_EX1:WHR_EX2]) & ~(|r0_w1_available_iss[WHR_EX1:WHR_EX2]);
  assign nxt_r1_w1_where_ex1[WHR_WR] = r1_w1_where_iss[WHR_EX2] & ~(|r1_w2_available_iss[WHR_EX1:WHR_EX2]) & ~(|r1_w1_available_iss[WHR_EX1:WHR_EX2]);
  assign nxt_r2_w1_where_ex1[WHR_WR] = r2_w1_where_iss[WHR_EX2] & ~(|r2_w2_available_iss[WHR_EX1:WHR_EX2]) & ~(|r2_w1_available_iss[WHR_EX1:WHR_EX2]);
  assign nxt_r3_w1_where_ex1[WHR_WR] = r3_w1_where_iss[WHR_EX2] & ~(|r3_w2_available_iss[WHR_EX1:WHR_EX2]) & ~(|r3_w1_available_iss[WHR_EX1:WHR_EX2]);
  assign nxt_r4_w1_where_ex1[WHR_WR] = r4_w1_where_iss[WHR_EX2] & ~(|r4_w2_available_iss[WHR_EX1:WHR_EX2]) & ~(|r4_w1_available_iss[WHR_EX1:WHR_EX2]);
                                                                                         
  assign nxt_r0_w2_where_ex1[WHR_WR] = r0_w2_where_iss[WHR_EX2] & ~(|r0_w2_available_iss[WHR_EX1:WHR_EX2]) &   ~r0_w1_available_iss[WHR_EX1];
  assign nxt_r1_w2_where_ex1[WHR_WR] = r1_w2_where_iss[WHR_EX2] & ~(|r1_w2_available_iss[WHR_EX1:WHR_EX2]) &   ~r1_w1_available_iss[WHR_EX1];
  assign nxt_r2_w2_where_ex1[WHR_WR] = r2_w2_where_iss[WHR_EX2] & ~(|r2_w2_available_iss[WHR_EX1:WHR_EX2]) &   ~r2_w1_available_iss[WHR_EX1];
  assign nxt_r3_w2_where_ex1[WHR_WR] = r3_w2_where_iss[WHR_EX2] & ~(|r3_w2_available_iss[WHR_EX1:WHR_EX2]) &   ~r3_w1_available_iss[WHR_EX1];
  assign nxt_r4_w2_where_ex1[WHR_WR] = r4_w2_where_iss[WHR_EX2] & ~(|r4_w2_available_iss[WHR_EX1:WHR_EX2]) &   ~r4_w1_available_iss[WHR_EX1];

  // Note: Ex2 'where' signals are taken straight from Ex1, as only stores can
  // be forwarded into in Ex2, and these will never be forwarded to from Ex2
  // to Ex1.
  
  // Map pipeline "where" signals onto the read port signals, based on which
  // ports are in use by the pipelines

  assign nxt_alu0_a_w0_where_ex1 = (alu0_data_a_sel_iss == `CA53_SEL_SHF_A_R0) ? nxt_r0_w0_where_ex1[WHR_WR:WHR_WR]  :
                                   (alu0_data_a_sel_iss == `CA53_SEL_SHF_A_R3) ? nxt_r3_w0_where_ex1[WHR_WR:WHR_WR]  :
                                                                                 1'b0;
  assign nxt_alu0_a_w1_where_ex1 = (alu0_data_a_sel_iss == `CA53_SEL_SHF_A_R0) ? nxt_r0_w1_where_ex1[WHR_EX2:WHR_WR] :
                                   (alu0_data_a_sel_iss == `CA53_SEL_SHF_A_R3) ? nxt_r3_w1_where_ex1[WHR_EX2:WHR_WR] :
                                                                                 2'b00;
  assign nxt_alu0_a_w2_where_ex1 = (alu0_data_a_sel_iss == `CA53_SEL_SHF_A_R0) ? nxt_r0_w2_where_ex1[WHR_EX2:WHR_WR] :
                                   (alu0_data_a_sel_iss == `CA53_SEL_SHF_A_R3) ? nxt_r3_w2_where_ex1[WHR_EX2:WHR_WR] :
                                                                                 2'b00;

  assign nxt_alu0_b_w0_where_ex1 = (alu0_data_b_sel_iss == `CA53_SEL_SHF_B_R1) ? nxt_r1_w0_where_ex1[WHR_WR:WHR_WR]  :
                                   (alu0_data_b_sel_iss == `CA53_SEL_SHF_B_R4) ? nxt_r4_w0_where_ex1[WHR_WR:WHR_WR]  :
                                                                                 1'b0;
  assign nxt_alu0_b_w1_where_ex1 = (alu0_data_b_sel_iss == `CA53_SEL_SHF_B_R1) ? nxt_r1_w1_where_ex1[WHR_EX2:WHR_WR] :
                                   (alu0_data_b_sel_iss == `CA53_SEL_SHF_B_R4) ? nxt_r4_w1_where_ex1[WHR_EX2:WHR_WR] :
                                                                                 2'b00;
  assign nxt_alu0_b_w2_where_ex1 = (alu0_data_b_sel_iss == `CA53_SEL_SHF_B_R1) ? nxt_r1_w2_where_ex1[WHR_EX2:WHR_WR] :
                                   (alu0_data_b_sel_iss == `CA53_SEL_SHF_B_R4) ? nxt_r4_w2_where_ex1[WHR_EX2:WHR_WR] :
                                                                                 2'b00;

  assign nxt_alu1_a_w0_where_ex1 = (alu1_data_a_sel_iss == `CA53_SEL_SHF_A_R3) ? nxt_r0_w0_where_ex1[WHR_WR:WHR_WR]  :
                                   (alu1_data_a_sel_iss == `CA53_SEL_SHF_A_R0) ? nxt_r3_w0_where_ex1[WHR_WR:WHR_WR]  :
                                                                                 1'b0;
  assign nxt_alu1_a_w1_where_ex1 = (alu1_data_a_sel_iss == `CA53_SEL_SHF_A_R3) ? nxt_r0_w1_where_ex1[WHR_EX1:WHR_WR] :
                                   (alu1_data_a_sel_iss == `CA53_SEL_SHF_A_R0) ? nxt_r3_w1_where_ex1[WHR_EX1:WHR_WR] :
                                                                                 3'b000;
  assign nxt_alu1_a_w2_where_ex1 = (alu1_data_a_sel_iss == `CA53_SEL_SHF_A_R3) ? nxt_r0_w2_where_ex1[WHR_EX2:WHR_WR] :
                                   (alu1_data_a_sel_iss == `CA53_SEL_SHF_A_R0) ? nxt_r3_w2_where_ex1[WHR_EX2:WHR_WR] :
                                                                                 2'b00;

  assign nxt_alu1_b_w0_where_ex1 = (alu1_data_b_sel_iss == `CA53_SEL_SHF_B_R4) ? nxt_r1_w0_where_ex1[WHR_WR:WHR_WR]  :
                                   (alu1_data_b_sel_iss == `CA53_SEL_SHF_B_R1) ? nxt_r4_w0_where_ex1[WHR_WR:WHR_WR]  :
                                                                                 1'b0;
  assign nxt_alu1_b_w1_where_ex1 = (alu1_data_b_sel_iss == `CA53_SEL_SHF_B_R4) ? nxt_r1_w1_where_ex1[WHR_EX1:WHR_WR] :
                                   (alu1_data_b_sel_iss == `CA53_SEL_SHF_B_R1) ? nxt_r4_w1_where_ex1[WHR_EX1:WHR_WR] :
                                                                                 3'b000;
  assign nxt_alu1_b_w2_where_ex1 = (alu1_data_b_sel_iss == `CA53_SEL_SHF_B_R4) ? nxt_r1_w2_where_ex1[WHR_EX2:WHR_WR] :
                                   (alu1_data_b_sel_iss == `CA53_SEL_SHF_B_R1) ? nxt_r4_w2_where_ex1[WHR_EX2:WHR_WR] :
                                                                                 2'b00;

  assign nxt_str0_a_w0_where_ex1 = (str0_data_a_sel_iss == `CA53_SEL_STR_A_R1) ? nxt_r1_w0_where_ex1[WHR_EX2:WHR_WR] :
                                   (str0_data_a_sel_iss == `CA53_SEL_STR_A_R2) ? nxt_r2_w0_where_ex1[WHR_EX2:WHR_WR] :
                                   (str0_data_a_sel_iss == `CA53_SEL_STR_A_R4) ? nxt_r4_w0_where_ex1[WHR_EX2:WHR_WR] :
                                                                                 2'b00;
  assign nxt_str0_a_w1_where_ex1 = (str0_data_a_sel_iss == `CA53_SEL_STR_A_R1) ? {1'b0, nxt_r1_w1_where_ex1[WHR_EX2:WHR_WR]} :
                                   (str0_data_a_sel_iss == `CA53_SEL_STR_A_R2) ? nxt_r2_w1_where_ex1[WHR_EX1:WHR_WR]         :
                                   (str0_data_a_sel_iss == `CA53_SEL_STR_A_R4) ? {1'b0, nxt_r4_w1_where_ex1[WHR_EX2:WHR_WR]} :
                                                                                 3'b000;
  assign nxt_str0_a_w2_where_ex1 = (str0_data_a_sel_iss == `CA53_SEL_STR_A_R1) ? nxt_r1_w2_where_ex1[WHR_EX2:WHR_WR] :
                                   (str0_data_a_sel_iss == `CA53_SEL_STR_A_R2) ? nxt_r2_w2_where_ex1[WHR_EX2:WHR_WR] :
                                   (str0_data_a_sel_iss == `CA53_SEL_STR_A_R4) ? nxt_r4_w2_where_ex1[WHR_EX2:WHR_WR] :
                                                                                 2'b00;


  // Assume that A_H means R2 in this case, as these signals will only be used
  // for multiplier forwarding
  assign nxt_str0_b_w0_where_ex1 = (str0_data_b_sel_iss == `CA53_SEL_STR_B_A_H) ? nxt_r2_w0_where_ex1[WHR_EX2:WHR_WR] :
                                   (str0_data_b_sel_iss == `CA53_SEL_STR_B_R2)  ? nxt_r2_w0_where_ex1[WHR_EX2:WHR_WR] :
                                   (str0_data_b_sel_iss == `CA53_SEL_STR_B_R3)  ? nxt_r3_w0_where_ex1[WHR_EX2:WHR_WR] :
                                                                                  2'b00;
  assign nxt_str0_b_w1_where_ex1 = (str0_data_b_sel_iss == `CA53_SEL_STR_B_A_H) ? nxt_r2_w1_where_ex1[WHR_EX2:WHR_WR] :
                                   (str0_data_b_sel_iss == `CA53_SEL_STR_B_R2)  ? nxt_r2_w1_where_ex1[WHR_EX2:WHR_WR] :
                                   (str0_data_b_sel_iss == `CA53_SEL_STR_B_R3)  ? nxt_r3_w1_where_ex1[WHR_EX2:WHR_WR] :
                                                                                  2'b00;
  assign nxt_str0_b_w2_where_ex1 = (str0_data_b_sel_iss == `CA53_SEL_STR_B_A_H) ? nxt_r2_w2_where_ex1[WHR_EX2:WHR_WR] :
                                   (str0_data_b_sel_iss == `CA53_SEL_STR_B_R2)  ? nxt_r2_w2_where_ex1[WHR_EX2:WHR_WR] :
                                   (str0_data_b_sel_iss == `CA53_SEL_STR_B_R3)  ? nxt_r3_w2_where_ex1[WHR_EX2:WHR_WR] :
                                                                                  2'b00;


  assign nxt_str1_a_w0_where_ex1 = (str1_data_a_sel_iss == `CA53_SEL_STR_A_R1) ? nxt_r4_w0_where_ex1[WHR_EX2:WHR_WR] :
                                   (str1_data_a_sel_iss == `CA53_SEL_STR_A_R2) ? nxt_r2_w0_where_ex1[WHR_EX2:WHR_WR] :
                                   (str1_data_a_sel_iss == `CA53_SEL_STR_A_R4) ? nxt_r1_w0_where_ex1[WHR_EX2:WHR_WR] :
                                                                                 2'b00;
  assign nxt_str1_a_w1_where_ex1 = (str1_data_a_sel_iss == `CA53_SEL_STR_A_R1) ? nxt_r4_w1_where_ex1[WHR_EX1:WHR_WR] :
                                   (str1_data_a_sel_iss == `CA53_SEL_STR_A_R2) ? nxt_r2_w1_where_ex1[WHR_EX1:WHR_WR] :
                                   (str1_data_a_sel_iss == `CA53_SEL_STR_A_R4) ? nxt_r1_w1_where_ex1[WHR_EX1:WHR_WR] :
                                                                                 3'b000;
  assign nxt_str1_a_w2_where_ex1 = (str1_data_a_sel_iss == `CA53_SEL_STR_A_R1) ? nxt_r4_w2_where_ex1[WHR_EX2:WHR_WR] :
                                   (str1_data_a_sel_iss == `CA53_SEL_STR_A_R2) ? nxt_r2_w2_where_ex1[WHR_EX2:WHR_WR] :
                                   (str1_data_a_sel_iss == `CA53_SEL_STR_A_R4) ? nxt_r1_w2_where_ex1[WHR_EX2:WHR_WR] :
                                                                                 2'b00;

  // Assume that A_H means R2 in this case, as these signals will only be used
  // for multiplier forwarding
  assign nxt_str1_b_w0_where_ex1 = (str1_data_b_sel_iss == `CA53_SEL_STR_B_A_H) ? nxt_r2_w0_where_ex1[WHR_EX2:WHR_WR] :
                                   (str1_data_b_sel_iss == `CA53_SEL_STR_B_R2)  ? nxt_r2_w0_where_ex1[WHR_EX2:WHR_WR] :
                                                                                  2'b00;
  assign nxt_str1_b_w1_where_ex1 = (str1_data_b_sel_iss == `CA53_SEL_STR_B_A_H) ? {1'b0, nxt_r2_w1_where_ex1[WHR_EX2:WHR_WR]} :
                                   (str1_data_b_sel_iss == `CA53_SEL_STR_B_R2)  ? nxt_r2_w1_where_ex1[WHR_EX1:WHR_WR] :
                                                                                  3'b000;
  assign nxt_str1_b_w2_where_ex1 = (str1_data_b_sel_iss == `CA53_SEL_STR_B_A_H) ? nxt_r2_w2_where_ex1[WHR_EX2:WHR_WR] :
                                   (str1_data_b_sel_iss == `CA53_SEL_STR_B_R2)  ? nxt_r2_w2_where_ex1[WHR_EX2:WHR_WR] :
                                                                                  2'b00;

  // ------------------------------------------------------
  // Available mask
  // ------------------------------------------------------
  //
  // Figure out which write data in the pipe that have the same register number as the one being
  // read are actually ready for forwarding.  We will be grabbing the most up to date from this set.
  //
  // The mask is a representation of the write pipe: [Ex2, Wr]
  //
  // Ex1 does not need to be considered for forwarding as there are no forwarding paths from Ex1
  // (it still needs to be considered for interlocking, though).

  // Main ready signal for use in Iss, Ex1, Ex2 available signals
  //                      available from ex1 now                                  , available from ex2 now                           , available from wr now
  assign w0_ready_mask = {~rf_wr_when_w0_ex1[WHN_NOT_EX1] & rf_wr_en_w0_ex1       , ~rf_wr_when_w0_ex2[WHN_NOT_EX2] & rf_wr_en_w0_ex2, raw_rf_wr_en_w0_wr & pre_valid_instrs_wr[0] & ~ls_stall_wr_i};
  assign w1_ready_mask = {~rf_wr_when_w1_ex1[WHN_NOT_EX1] & rf_wr_en_w1_no_x64_ex1, ~rf_wr_when_w1_ex2[WHN_NOT_EX2] & rf_wr_en_w1_ex2, raw_rf_wr_en_w1_wr & pre_valid_instrs_wr[0]};
  assign w2_ready_mask = {~rf_wr_when_w2_ex1[WHN_NOT_EX1] & rf_wr_en_w2_ex1       , ~rf_wr_when_w2_ex2[WHN_NOT_EX2] & rf_wr_en_w2_ex2, raw_rf_wr_en_w2_wr & pre_valid_instrs_wr[0]};

  // Main available signals for Iss, Ex1, Ex2 forwarding
  // (note that nothing which uses W0 can forward from Ex2)
  //                                available from ex1 now                               , available from ex2 now                               , available from wr now
  // - Iss
  assign r0_w0_available_iss     =                                                                                                                r0_w0_where_iss[WHR_WR];
  assign r0_w1_available_iss     = {r0_w1_where_iss[WHR_EX1] & w1_ready_mask[WHR_EX1]    , r0_w1_where_iss[WHR_EX2] & w1_ready_mask[WHR_EX2],     r0_w1_where_iss[WHR_WR]};
  assign r0_w2_available_iss     = {r0_w2_where_iss[WHR_EX1] & w2_ready_mask[WHR_EX1]    , r0_w2_where_iss[WHR_EX2] & w2_ready_mask[WHR_EX2],     r0_w2_where_iss[WHR_WR]};

  assign r1_w0_available_iss     =                                                                                                                r1_w0_where_iss[WHR_WR];
  assign r1_w1_available_iss     = {r1_w1_where_iss[WHR_EX1] & w1_ready_mask[WHR_EX1]    , r1_w1_where_iss[WHR_EX2] & w1_ready_mask[WHR_EX2],     r1_w1_where_iss[WHR_WR]};
  assign r1_w2_available_iss     = {r1_w2_where_iss[WHR_EX1] & w2_ready_mask[WHR_EX1]    , r1_w2_where_iss[WHR_EX2] & w2_ready_mask[WHR_EX2],     r1_w2_where_iss[WHR_WR]};

  assign r2_w0_available_iss     =                                                                                                                r2_w0_where_iss[WHR_WR];
  assign r2_w1_available_iss     = {r2_w1_where_iss[WHR_EX1] & w1_ready_mask[WHR_EX1]    , r2_w1_where_iss[WHR_EX2] & w1_ready_mask[WHR_EX2],     r2_w1_where_iss[WHR_WR]};
  assign r2_w2_available_iss     = {r2_w2_where_iss[WHR_EX1] & w2_ready_mask[WHR_EX1]    , r2_w2_where_iss[WHR_EX2] & w2_ready_mask[WHR_EX2],     r2_w2_where_iss[WHR_WR]};

  assign r3_w0_available_iss     =                                                                                                                r3_w0_where_iss[WHR_WR];
  assign r3_w1_available_iss     = {r3_w1_where_iss[WHR_EX1] & w1_ready_mask[WHR_EX1]    , r3_w1_where_iss[WHR_EX2] & w1_ready_mask[WHR_EX2],     r3_w1_where_iss[WHR_WR]};
  assign r3_w2_available_iss     = {r3_w2_where_iss[WHR_EX1] & w2_ready_mask[WHR_EX1]    , r3_w2_where_iss[WHR_EX2] & w2_ready_mask[WHR_EX2],     r3_w2_where_iss[WHR_WR]};

  assign r4_w0_available_iss     =                                                                                                                r4_w0_where_iss[WHR_WR];
  assign r4_w1_available_iss     = {r4_w1_where_iss[WHR_EX1] & w1_ready_mask[WHR_EX1]    , r4_w1_where_iss[WHR_EX2] & w1_ready_mask[WHR_EX2],     r4_w1_where_iss[WHR_WR]};
  assign r4_w2_available_iss     = {r4_w2_where_iss[WHR_EX1] & w2_ready_mask[WHR_EX1]    , r4_w2_where_iss[WHR_EX2] & w2_ready_mask[WHR_EX2],     r4_w2_where_iss[WHR_WR]};

  // - Ex1
  assign alu0_a_w0_available_ex1 =                                                                                                                alu0_a_w0_where_ex1[WHR_WR] & w0_ready_mask[WHR_WR];
  assign alu0_a_w1_available_ex1 =                                                        {alu0_a_w1_where_ex1[WHR_EX2] & w1_ready_mask[WHR_EX2], alu0_a_w1_where_ex1[WHR_WR] & w1_ready_mask[WHR_WR]};
  assign alu0_a_w2_available_ex1 =                                                        {alu0_a_w2_where_ex1[WHR_EX2] & w2_ready_mask[WHR_EX2], alu0_a_w2_where_ex1[WHR_WR] & w2_ready_mask[WHR_WR]};

  assign alu0_b_w0_available_ex1 =                                                                                                                alu0_b_w0_where_ex1[WHR_WR] & w0_ready_mask[WHR_WR];
  assign alu0_b_w1_available_ex1 =                                                        {alu0_b_w1_where_ex1[WHR_EX2] & w1_ready_mask[WHR_EX2], alu0_b_w1_where_ex1[WHR_WR] & w1_ready_mask[WHR_WR]};
  assign alu0_b_w2_available_ex1 =                                                        {alu0_b_w2_where_ex1[WHR_EX2] & w2_ready_mask[WHR_EX2], alu0_b_w2_where_ex1[WHR_WR] & w2_ready_mask[WHR_WR]};

  assign alu1_a_w0_available_ex1 =                                                                                                                alu1_a_w0_where_ex1[WHR_WR] & w0_ready_mask[WHR_WR];
  assign alu1_a_w1_available_ex1 = {alu1_a_w1_where_ex1[WHR_EX1] & w1_ready_mask[WHR_EX1], alu1_a_w1_where_ex1[WHR_EX2] & w1_ready_mask[WHR_EX2], alu1_a_w1_where_ex1[WHR_WR] & w1_ready_mask[WHR_WR]};
  assign alu1_a_w2_available_ex1 =                                                        {alu1_a_w2_where_ex1[WHR_EX2] & w2_ready_mask[WHR_EX2], alu1_a_w2_where_ex1[WHR_WR] & w2_ready_mask[WHR_WR]};

  assign alu1_b_w0_available_ex1 =                                                                                                                alu1_b_w0_where_ex1[WHR_WR] & w0_ready_mask[WHR_WR];
  assign alu1_b_w1_available_ex1 = {alu1_b_w1_where_ex1[WHR_EX1] & w1_ready_mask[WHR_EX1], alu1_b_w1_where_ex1[WHR_EX2] & w1_ready_mask[WHR_EX2], alu1_b_w1_where_ex1[WHR_WR] & w1_ready_mask[WHR_WR]};
  assign alu1_b_w2_available_ex1 =                                                        {alu1_b_w2_where_ex1[WHR_EX2] & w2_ready_mask[WHR_EX2], alu1_b_w2_where_ex1[WHR_WR] & w2_ready_mask[WHR_WR]};

  assign str0_a_w0_available_ex1 =                                                                                                                str0_a_w0_where_ex1[WHR_WR] & w0_ready_mask[WHR_WR];
  assign str0_a_w1_available_ex1 =                                                                                                                str0_a_w1_where_ex1[WHR_WR] & w1_ready_mask[WHR_WR];
  assign str0_a_w2_available_ex1 =                                                                                                                str0_a_w2_where_ex1[WHR_WR] & w2_ready_mask[WHR_WR];

  assign str0_b_w0_available_ex1 =                                                                                                                str0_b_w0_where_ex1[WHR_WR] & w0_ready_mask[WHR_WR];
  assign str0_b_w1_available_ex1 =                                                                                                                str0_b_w1_where_ex1[WHR_WR] & w1_ready_mask[WHR_WR];
  assign str0_b_w2_available_ex1 =                                                                                                                str0_b_w2_where_ex1[WHR_WR] & w2_ready_mask[WHR_WR];

  assign str1_a_w0_available_ex1 =                                                                                                                str1_a_w0_where_ex1[WHR_WR] & w0_ready_mask[WHR_WR];
  assign str1_a_w1_available_ex1 =                                                                                                                str1_a_w1_where_ex1[WHR_WR] & w1_ready_mask[WHR_WR];
  assign str1_a_w2_available_ex1 =                                                                                                                str1_a_w2_where_ex1[WHR_WR] & w2_ready_mask[WHR_WR];

  assign str1_b_w0_available_ex1 =                                                                                                                str1_b_w0_where_ex1[WHR_WR] & w0_ready_mask[WHR_WR];
  assign str1_b_w1_available_ex1 =                                                                                                                str1_b_w1_where_ex1[WHR_WR] & w1_ready_mask[WHR_WR];
  assign str1_b_w2_available_ex1 =                                                                                                                str1_b_w2_where_ex1[WHR_WR] & w2_ready_mask[WHR_WR];

  // - Ex2
  //   Only store pipe can have data forwarded into it in Ex2
  //   Store pipe 1 can accept data from w1 in Ex2, to allow a slot 0 ALU op to forward
  //   to a slot 1 store
  //                                available from ex2 now                               , available from wr now
  assign str0_a_w0_available_ex2 =                                                         str0_a_w0_where_ex2[WHR_WR] & w0_ready_mask[WHR_WR];
  assign str0_a_w1_available_ex2 = {str0_a_w1_where_ex2[WHR_EX2] & w1_ready_mask[WHR_EX2], str0_a_w1_where_ex2[WHR_WR] & w1_ready_mask[WHR_WR]};
  assign str0_a_w2_available_ex2 =                                                         str0_a_w2_where_ex2[WHR_WR] & w2_ready_mask[WHR_WR];

  assign str0_b_w0_available_ex2 =                                                         str0_b_w0_where_ex2[WHR_WR] & w0_ready_mask[WHR_WR];
  assign str0_b_w1_available_ex2 =                                                         str0_b_w1_where_ex2[WHR_WR] & w1_ready_mask[WHR_WR];
  assign str0_b_w2_available_ex2 =                                                         str0_b_w2_where_ex2[WHR_WR] & w2_ready_mask[WHR_WR];

  assign str1_a_w0_available_ex2 =                                                         str1_a_w0_where_ex2[WHR_WR] & w0_ready_mask[WHR_WR];
  assign str1_a_w1_available_ex2 = {str1_a_w1_where_ex2[WHR_EX2] & w1_ready_mask[WHR_EX2], str1_a_w1_where_ex2[WHR_WR] & w1_ready_mask[WHR_WR]};
  assign str1_a_w2_available_ex2 =                                                         str1_a_w2_where_ex2[WHR_WR] & w2_ready_mask[WHR_WR];

  assign str1_b_w0_available_ex2 =                                                         str1_b_w0_where_ex2[WHR_WR] & w0_ready_mask[WHR_WR];
  assign str1_b_w1_available_ex2 = {str1_b_w1_where_ex2[WHR_EX2] & w1_ready_mask[WHR_EX2], str1_b_w1_where_ex2[WHR_WR] & w1_ready_mask[WHR_WR]};
  assign str1_b_w2_available_ex2 =                                                         str1_b_w2_where_ex2[WHR_WR] & w2_ready_mask[WHR_WR];

  // ------------------------------------------------------
  // AGU De stage regbank read port (lower bits only)
  // ------------------------------------------------------

  // Additional address compares for use below (where possible reuse the signals created earlier)
  assign addr_cmp_de_wr[R0][W0]  = (rf_r0_for_fwd_check_de_i == raw_rf_wr_addr_w0_wr) & raw_rf_wr_en_w0_wr;
  assign addr_cmp_de_wr[R0][W1]  = (rf_r0_for_fwd_check_de_i ==     rf_wr_addr_w1_wr) & raw_rf_wr_en_w1_wr;
  assign addr_cmp_de_wr[R0][W2]  = (rf_r0_for_fwd_check_de_i ==     rf_wr_addr_w2_wr) & raw_rf_wr_en_w2_wr;
  assign addr_cmp_de_wr[R1][W0]  = (rf_r1_for_fwd_check_de_i == raw_rf_wr_addr_w0_wr) & raw_rf_wr_en_w0_wr;
  assign addr_cmp_de_wr[R1][W1]  = (rf_r1_for_fwd_check_de_i ==     rf_wr_addr_w1_wr) & raw_rf_wr_en_w1_wr;
  assign addr_cmp_de_wr[R1][W2]  = (rf_r1_for_fwd_check_de_i ==     rf_wr_addr_w2_wr) & raw_rf_wr_en_w2_wr;

  // Register file control for De stage AGU offset operand read port
  assign rf_rd_r0_agu_de_o[2:0] = stall_wr        ? 3'b000                      :
                                  ilock_stall_iss ? addr_cmp_iss_wr[R0][W2:W0]  :
                                                    addr_cmp_de_wr[R0][W2:W0];

  assign en_rf_rd_r0_agu_de_o = ilock_stall_iss & (|addr_cmp_iss_wr[R0][W2:W0]) & ls_valid_iss_i;

  // Register file control for De stage AGU offset operand read port
  assign rf_rd_r1_agu_de_o[2:0] = stall_wr        ? 3'b000                      :
                                  ilock_stall_iss ? addr_cmp_iss_wr[R1][W2:W0]  :
                                                    addr_cmp_de_wr[R1][W2:W0];

  assign en_rf_rd_r1_agu_de_o = ilock_stall_iss & (|addr_cmp_iss_wr[R1][W2:W0]) & ls_valid_iss_i;

  // ------------------------------------------------------
  // DCU forwarding controls
  // ------------------------------------------------------

  // Early forwarding suppressed on conditional instructions, as do not know
  // cc_pass result early enough to factor in in Ex2
  assign conditional_instr_ex1 = {valid_instrs_ex1[1] ? (cond_code_instr1_ex1[3:1] != `CA53_CC_AL_or_NV)
                                                      : (cond_code_instr0_ex1[3:1] != `CA53_CC_AL_or_NV),
                                  (cond_code_instr0_ex1[3:1] != `CA53_CC_AL_or_NV)};

  assign conditional_instr_ex2 = {valid_instrs_ex2[1] ? (cond_code_instr1_ex2[3:1] != `CA53_CC_AL_or_NV)
                                                      : (cond_code_instr0_ex2[3:1] != `CA53_CC_AL_or_NV),
                                  (cond_code_instr0_ex2[3:1] != `CA53_CC_AL_or_NV)};

  assign nxt_early_addr_cmp_agu_iss_ex2[R0][W2:W1] = stall_wr  ? (addr_cmp_iss_ex2[R0][W2:W1] & ~conditional_instr_ex2) :
                                                     stall_iss ? (addr_cmp_iss_ex1[R0][W2:W1] & ~conditional_instr_ex1) : 
                                                                 (addr_cmp_de_ex1[ R0][W2:W1] & ~conditional_instr_ex1);

  assign nxt_early_addr_cmp_agu_iss_ex2[R1][W2:W1] = stall_wr  ? (addr_cmp_iss_ex2[R1][W2:W1] & ~conditional_instr_ex2) :
                                                     stall_iss ? (addr_cmp_iss_ex1[R1][W2:W1] & ~conditional_instr_ex1) : 
                                                                 (addr_cmp_de_ex1[ R1][W2:W1] & ~conditional_instr_ex1);

  always @(posedge clk) begin
    early_addr_cmp_agu_iss_ex2[R0][W2:W1] <= nxt_early_addr_cmp_agu_iss_ex2[R0][W2:W1];
    early_addr_cmp_agu_iss_ex2[R1][W2:W1] <= nxt_early_addr_cmp_agu_iss_ex2[R1][W2:W1];
  end

  // AGU Base operand
  always @* begin
    sel_fwd_dcu_a_iss_o = {`CA53_SEL_FWD_DCU_W{1'b0}};

    case ({early_addr_cmp_agu_iss_ex2[R0][W2],
           early_addr_cmp_agu_iss_ex2[R0][W1],
           early_addr_cmp_iss_wr[R0][W2],
           early_addr_cmp_iss_wr[R0][W1],
           early_addr_cmp_iss_wr[R0][W0]})
      `ca53dpu_sel_1xxxx: sel_fwd_dcu_a_iss_o[`CA53_SEL_FWD_DCU_BIT_W2F_EX2]  = 1'b1;
      `ca53dpu_sel_01xxx: sel_fwd_dcu_a_iss_o[`CA53_SEL_FWD_DCU_BIT_W1F_EX2]  = 1'b1;  // Need priority between Ex2 comparators as WAW hazards not resolved until end of Ex2
        5'b00100        : sel_fwd_dcu_a_iss_o[`CA53_SEL_FWD_DCU_BIT_W2F_WR]   = 1'b1;  // Wr stage comparators mutually exclusive
        5'b00010        : sel_fwd_dcu_a_iss_o[`CA53_SEL_FWD_DCU_BIT_W1F_WR]   = 1'b1;
        5'b00001        : sel_fwd_dcu_a_iss_o[`CA53_SEL_FWD_DCU_BIT_W0F_WR]   = 1'b1;
        5'b00000        : sel_fwd_dcu_a_iss_o[`CA53_SEL_FWD_DCU_BIT_NOF]      = 1'b1;  // default nobody is forwarding use RF
      default           : sel_fwd_dcu_a_iss_o                                 = {`CA53_SEL_FWD_DCU_W{1'bx}};
    endcase
  end

  // AGU Offset operand
  always @* begin
    sel_fwd_dcu_b_iss_o = {`CA53_SEL_FWD_DCU_W{1'b0}};

    case ({early_addr_cmp_agu_iss_ex2[R1][W2],
           early_addr_cmp_agu_iss_ex2[R1][W1],
           early_addr_cmp_iss_wr[R1][W2],
           early_addr_cmp_iss_wr[R1][W1],
           early_addr_cmp_iss_wr[R1][W0]})
      `ca53dpu_sel_1xxxx: sel_fwd_dcu_b_iss_o[`CA53_SEL_FWD_DCU_BIT_W2F_EX2]  = 1'b1;
      `ca53dpu_sel_01xxx: sel_fwd_dcu_b_iss_o[`CA53_SEL_FWD_DCU_BIT_W1F_EX2]  = 1'b1;  // Need priority between Ex2 comparators as WAW hazards not resolved until end of Ex2
        5'b00100        : sel_fwd_dcu_b_iss_o[`CA53_SEL_FWD_DCU_BIT_W2F_WR]   = 1'b1;  // Wr stage comparators mutually exclusive
        5'b00010        : sel_fwd_dcu_b_iss_o[`CA53_SEL_FWD_DCU_BIT_W1F_WR]   = 1'b1;
        5'b00001        : sel_fwd_dcu_b_iss_o[`CA53_SEL_FWD_DCU_BIT_W0F_WR]   = 1'b1;
        5'b00000        : sel_fwd_dcu_b_iss_o[`CA53_SEL_FWD_DCU_BIT_NOF]      = 1'b1;  // default nobody is forwarding use RF
      default           : sel_fwd_dcu_b_iss_o                                 = {`CA53_SEL_FWD_DCU_W{1'bx}};
    endcase
  end

  // Addr forwarding path from one LDR operation to the next (forwards base register
  // value) must be selected separately.  Also used to disable interlocking with R0.
  // Assumptions:
  //
  // - R0 is the only read port than can supply the base register address
  // - W1 is always used to write-back the base register for slot
  //   0 load/store, W2 is always used for slot 1

  // Calculate if the instruction currently in iss can forward an address out of the AGU
  // in the next cycle
  assign can_fwd_from_agu_iss = (slot1_ls_iss ? ((cond_code_instr1_iss == `CA53_CC_AL)        &       // Unconditional load/store in slot 1
                                                 (alu1_data_a_sel_iss  == `CA53_SEL_SHF_A_R0) &       // Using ALU1
                                                  rf_wr_en_w2_iss                             &
                                                 (rf_wr_src_w2_iss     == `CA53_RF_WR_SRC_W2_ALU)) :  // ALU1 will write on W2, so doing write back
                                                ((cond_code_instr0_iss == `CA53_CC_AL)        &       // Unconditional load/store in slot 0
                                                 (alu0_data_a_sel_iss  == `CA53_SEL_SHF_A_R0) &       // Using ALU0
                                                  rf_wr_en_w1_iss                             &
                                                 (rf_wr_src_w1_iss     == `CA53_RF_WR_SRC_W1_ALU))) & // ALU0 will write on W1, so doing write back
                                (agu_data_a_sel_iss_i   == `CA53_SEL_DCU_A_R0) &
                                ((agu_data_b_sel_iss_i[`CA53_SEL_DCU_B_BIT_R1]     & (alu0_data_b_sel_iss == `CA53_SEL_SHF_B_R1)) |
                                 (agu_data_b_sel_iss_i[`CA53_SEL_DCU_B_BIT_IMM_LS] & (alu0_data_b_sel_iss == `CA53_SEL_SHF_B_IMM_DATA))) &
                                // Don't forward if slot 0 LS and slot 1 is overwriting base register
                                ~(~slot1_ls_iss & valid_instrs_iss[1] & 
                                  ((rf_wr_en_w2_iss &                (rf_wr_addr_w2_iss == rf_wr_addr_w1_iss)) |
                                   (rf_wr_en_w0_iss & w0_slot1_iss & (rf_wr_addr_w0_iss == rf_wr_addr_w1_iss))));

  // Pre-calculate the address and valid check
  // Note that we must qualify with the case where a dual-issued instruction in Iss writes
  // to the same register:
  // - if the load/store is the earlier instruction of the pair, then we
  //   cannot foward, as the later data processing instruction has the final
  //   value for the register and data processing instructions cannot use the
  //   fowarding path.
  // - if the load/store is the later instruction of the pair, then we can
  //   forward, as the earlier data processing instruction is overwritten by
  //   the load/store.
  assign r0_de_w1_iss_match = (rf_r0_for_fwd_check_de_i == rf_wr_addr_w1_iss) & rf_wr_en_w1_iss;  // Slot 0 uses W1
  assign r0_de_w2_iss_match = (rf_r0_for_fwd_check_de_i == rf_wr_addr_w2_iss) & rf_wr_en_w2_iss;  // Slot 1 uses W2

  // - Do not forward to a CP op, as this is not useful in normal code, and
  // means the address for address translation instructions (which may need the
  // upper bits of the VA forcing to zero) is easier to generate in the AGU.
  assign raw_sel_fwd_addr_dcu_a_de = stall_wr ? raw_sel_fwd_addr_dcu_a_iss
                                              : (rf_rd_en_r0_de_i & ls_valid_de_i & ~cp_de_i & ls_valid_iss_i &
                                                 (slot1_ls_iss ?  r0_de_w2_iss_match :                         // AGU addr on W2 in slot 1
                                                                 (r0_de_w1_iss_match & ~r0_de_w2_iss_match))); // AGU addr on W1, later DP on W2

  // Use the registered versions of the above signals to determine if a memory operation
  // in iss can forward the AGU address from the instruction now in ex1
  assign sel_fwd_addr_dcu_a_iss = raw_sel_fwd_addr_dcu_a_iss & can_fwd_from_agu_ex1;

  // ------------------------------------------------------
  // Integer forwarding controls for Iss forwarding
  // ------------------------------------------------------
  // W2 takes priority over W1 and W0. When both W2 and one other want to forward W2
  // should be selected because it is from instr1 hence newer than instr0.
  // ALU1 takes priority over ALU0. When both ALUs want to forward ALU1 should be
  // selected because it is from instr1 hence newer than instr0.
  assign r0_fwd_iss_o = r0_w2_available_iss[WHR_EX1] ? `CA53_FWD_ALU1_EX1 :
                        r0_w1_available_iss[WHR_EX1] ? `CA53_FWD_ALU0_EX1 :
                        r0_w2_available_iss[WHR_EX2] ? `CA53_FWD_ALU1_EX2 :
                        r0_w1_available_iss[WHR_EX2] ? `CA53_FWD_ALU0_EX2 :
                        r0_w2_available_iss[WHR_WR]  ? `CA53_FWD_W2       :
                        r0_w1_available_iss[WHR_WR]  ? `CA53_FWD_W1       :
                        r0_w0_available_iss[WHR_WR]  ? `CA53_FWD_W0       : 
                                                       `CA53_FWD_NULL;

  assign r1_fwd_iss_o = r1_w2_available_iss[WHR_EX1] ? `CA53_FWD_ALU1_EX1 :
                        r1_w1_available_iss[WHR_EX1] ? `CA53_FWD_ALU0_EX1 :
                        r1_w2_available_iss[WHR_EX2] ? `CA53_FWD_ALU1_EX2 :
                        r1_w1_available_iss[WHR_EX2] ? `CA53_FWD_ALU0_EX2 :
                        r1_w2_available_iss[WHR_WR]  ? `CA53_FWD_W2       :
                        r1_w1_available_iss[WHR_WR]  ? `CA53_FWD_W1       :
                        r1_w0_available_iss[WHR_WR]  ? `CA53_FWD_W0       : 
                                                       `CA53_FWD_NULL;

  assign r2_fwd_iss_o = r2_w2_available_iss[WHR_EX1] ? `CA53_FWD_ALU1_EX1 :
                        r2_w1_available_iss[WHR_EX1] ? `CA53_FWD_ALU0_EX1 :
                        r2_w2_available_iss[WHR_EX2] ? `CA53_FWD_ALU1_EX2 :
                        r2_w1_available_iss[WHR_EX2] ? `CA53_FWD_ALU0_EX2 :
                        r2_w2_available_iss[WHR_WR]  ? `CA53_FWD_W2       :
                        r2_w1_available_iss[WHR_WR]  ? `CA53_FWD_W1       :
                        r2_w0_available_iss[WHR_WR]  ? `CA53_FWD_W0       : 
                                                       `CA53_FWD_NULL;

  assign r3_fwd_iss_o = r3_w2_available_iss[WHR_EX1] ? `CA53_FWD_ALU1_EX1 :
                        r3_w1_available_iss[WHR_EX1] ? `CA53_FWD_ALU0_EX1 :
                        r3_w2_available_iss[WHR_EX2] ? `CA53_FWD_ALU1_EX2 :
                        r3_w1_available_iss[WHR_EX2] ? `CA53_FWD_ALU0_EX2 :
                        r3_w2_available_iss[WHR_WR]  ? `CA53_FWD_W2       :
                        r3_w1_available_iss[WHR_WR]  ? `CA53_FWD_W1       :
                        r3_w0_available_iss[WHR_WR]  ? `CA53_FWD_W0       : 
                                                       `CA53_FWD_NULL;

  assign r4_fwd_iss_o = r4_w2_available_iss[WHR_EX1] ? `CA53_FWD_ALU1_EX1 :
                        r4_w1_available_iss[WHR_EX1] ? `CA53_FWD_ALU0_EX1 :
                        r4_w2_available_iss[WHR_EX2] ? `CA53_FWD_ALU1_EX2 :
                        r4_w1_available_iss[WHR_EX2] ? `CA53_FWD_ALU0_EX2 :
                        r4_w2_available_iss[WHR_WR]  ? `CA53_FWD_W2       :
                        r4_w1_available_iss[WHR_WR]  ? `CA53_FWD_W1       :
                        r4_w0_available_iss[WHR_WR]  ? `CA53_FWD_W0       : 
                                                       `CA53_FWD_NULL;

  // ------------------------------------------------------
  // Integer forwarding controls for Ex1 forwarding
  // ------------------------------------------------------

  assign alu0_a_fwd_ex1_o  = alu0_a_w2_available_ex1[WHR_EX2] ? `CA53_FWD_ALU1_EX2 :
                             alu0_a_w1_available_ex1[WHR_EX2] ? `CA53_FWD_ALU0_EX2 :
                             alu0_a_w2_available_ex1[WHR_WR]  ? `CA53_FWD_W2       :
                             alu0_a_w1_available_ex1[WHR_WR]  ? `CA53_FWD_W1       :
                             alu0_a_w0_available_ex1[WHR_WR]  ? `CA53_FWD_W0       : 
                                                                `CA53_FWD_NULL;

  assign alu0_b_fwd_ex1_o  = alu0_b_w2_available_ex1[WHR_EX2] ? `CA53_FWD_ALU1_EX2 :
                             alu0_b_w1_available_ex1[WHR_EX2] ? `CA53_FWD_ALU0_EX2 :
                             alu0_b_w2_available_ex1[WHR_WR]  ? `CA53_FWD_W2       :
                             alu0_b_w1_available_ex1[WHR_WR]  ? `CA53_FWD_W1       :
                             alu0_b_w0_available_ex1[WHR_WR]  ? `CA53_FWD_W0       : 
                                                                `CA53_FWD_NULL;


  assign alu1_a_fwd_ex1_o  = alu1_a_w1_available_ex1[WHR_EX1] ? `CA53_FWD_ALU0_EX1 :
                             alu1_a_w2_available_ex1[WHR_EX2] ? `CA53_FWD_ALU1_EX2 :
                             alu1_a_w1_available_ex1[WHR_EX2] ? `CA53_FWD_ALU0_EX2 :
                             alu1_a_w2_available_ex1[WHR_WR]  ? `CA53_FWD_W2       :
                             alu1_a_w1_available_ex1[WHR_WR]  ? `CA53_FWD_W1       :
                             alu1_a_w0_available_ex1[WHR_WR]  ? `CA53_FWD_W0       : 
                                                                `CA53_FWD_NULL;

  assign alu1_b_fwd_ex1_o  = alu1_b_w1_available_ex1[WHR_EX1] ? `CA53_FWD_ALU0_EX1 :
                             alu1_b_w2_available_ex1[WHR_EX2] ? `CA53_FWD_ALU1_EX2 :
                             alu1_b_w1_available_ex1[WHR_EX2] ? `CA53_FWD_ALU0_EX2 :
                             alu1_b_w2_available_ex1[WHR_WR]  ? `CA53_FWD_W2       :
                             alu1_b_w1_available_ex1[WHR_WR]  ? `CA53_FWD_W1       :
                             alu1_b_w0_available_ex1[WHR_WR]  ? `CA53_FWD_W0       : 
                                                                `CA53_FWD_NULL;


  assign str0_a_fwd_ex1_o  = (|str0_sel_fp_f1)                ? `CA53_FWD_FP       :
                             str0_a_w2_available_ex1[WHR_WR]  ? `CA53_FWD_W2       :
                             str0_a_w1_available_ex1[WHR_WR]  ? `CA53_FWD_W1       :
                             str0_a_w0_available_ex1[WHR_WR]  ? `CA53_FWD_W0       : 
                                                                `CA53_FWD_NULL;

  assign str0_b_fwd_ex1_o  = (|str0_sel_fp_f1)                ? `CA53_FWD_FP       :
                             str0_b_w2_available_ex1[WHR_WR]  ? `CA53_FWD_W2       :
                             str0_b_w1_available_ex1[WHR_WR]  ? `CA53_FWD_W1       :
                             str0_b_w0_available_ex1[WHR_WR]  ? `CA53_FWD_W0       : 
                                                                `CA53_FWD_NULL;


  assign str1_a_fwd_ex1_o  = (|str1_sel_fp_f1)                ? `CA53_FWD_FP       :
                             str1_a_w2_available_ex1[WHR_WR]  ? `CA53_FWD_W2       :
                             str1_a_w1_available_ex1[WHR_WR]  ? `CA53_FWD_W1       :
                             str1_a_w0_available_ex1[WHR_WR]  ? `CA53_FWD_W0       : 
                                                                `CA53_FWD_NULL;

  assign str1_b_fwd_ex1_o  = (|str1_sel_fp_f1)                ? `CA53_FWD_FP       :
                             str1_b_w2_available_ex1[WHR_WR]  ? `CA53_FWD_W2       :
                             str1_b_w1_available_ex1[WHR_WR]  ? `CA53_FWD_W1       :
                             str1_b_w0_available_ex1[WHR_WR]  ? `CA53_FWD_W0       : 
                                                                `CA53_FWD_NULL;
  // ------------------------------------------------------
  // Integer forwarding controls for Ex2 forwarding
  // ------------------------------------------------------
  // Only store pipe can get data forwarded in in Ex2

  assign str0_a_fwd_ex2_o = (|str0_sel_fp_f2)                ? str0_a_fwd_fp_ex2  :
                            str0_a_w1_available_ex2[WHR_EX2] ? `CA53_FWD_ALU0_EX2 :
                            str0_a_w2_available_ex2[WHR_WR]  ? `CA53_FWD_W2       :
                            str0_a_w1_available_ex2[WHR_WR]  ? `CA53_FWD_W1       :
                            str0_a_w0_available_ex2[WHR_WR]  ? `CA53_FWD_W0       :
                                                               `CA53_FWD_NULL;

  assign str0_b_fwd_ex2_o = (|str0_sel_fp_f2)                ? str0_b_fwd_fp_ex2  :
                            str0_b_w2_available_ex2[WHR_WR]  ? `CA53_FWD_W2       :
                            str0_b_w1_available_ex2[WHR_WR]  ? `CA53_FWD_W1       :
                            str0_b_w0_available_ex2[WHR_WR]  ? `CA53_FWD_W0       :
                                                               `CA53_FWD_NULL;

  assign str1_a_fwd_ex2_o = (|str1_sel_fp_f2)                ? str1_a_fwd_fp_ex2  :
                            str1_a_w1_available_ex2[WHR_EX2] ? `CA53_FWD_ALU0_EX2 :
                            str1_a_w2_available_ex2[WHR_WR]  ? `CA53_FWD_W2       :
                            str1_a_w1_available_ex2[WHR_WR]  ? `CA53_FWD_W1       :
                            str1_a_w0_available_ex2[WHR_WR]  ? `CA53_FWD_W0       :
                                                               `CA53_FWD_NULL;

  assign str1_b_fwd_ex2_o = (|str1_sel_fp_f2)                ? str1_b_fwd_fp_ex2  :
                            str1_b_w1_available_ex2[WHR_EX2] ? `CA53_FWD_ALU0_EX2 :
                            str1_b_w2_available_ex2[WHR_WR]  ? `CA53_FWD_W2       :
                            str1_b_w1_available_ex2[WHR_WR]  ? `CA53_FWD_W1       :
                            str1_b_w0_available_ex2[WHR_WR]  ? `CA53_FWD_W0       :
                                                               `CA53_FWD_NULL;

  // ------------------------------------------------------
  // MAC forwarding
  // ------------------------------------------------------

  // Indicate to the MAC pipeline that the accumulator forwarding path
  // can be enabled next cycle
  assign mac_fwd_ctl_ex1_o[0] = (str0_a_w1_where_ex1[WHR_EX2] & nxt_rf_wr_en_w1_wr) |
                                (str0_a_w2_where_ex1[WHR_EX2] & nxt_rf_wr_en_w2_wr);

  assign mac_fwd_ctl_ex1_o[1] = (str1_a_w1_where_ex1[WHR_EX2] & nxt_rf_wr_en_w1_wr) |
                                (str1_a_w2_where_ex1[WHR_EX2] & nxt_rf_wr_en_w2_wr);

  assign mac_fwd_ctl_ex1_o[2] = (str0_b_w0_where_ex1[WHR_EX2] & nxt_rf_wr_en_w0_wr) |
                                (str0_b_w1_where_ex1[WHR_EX2] & nxt_rf_wr_en_w1_wr) |
                                (str0_b_w2_where_ex1[WHR_EX2] & nxt_rf_wr_en_w2_wr);

  assign mac_fwd_ctl_ex1_o[3] = (str1_b_w0_where_ex1[WHR_EX2] & nxt_rf_wr_en_w0_wr) |
                                (str1_b_w1_where_ex1[WHR_EX2] & nxt_rf_wr_en_w1_wr) |
                                (str1_b_w2_where_ex1[WHR_EX2] & nxt_rf_wr_en_w2_wr);

  // These signals are similar to bits [3:2], but are qualified in the case that
  // zeroes should be forwarded
  assign mac_fwd_ctl_ex1_o[4] = (str0_b_w0_where_ex1[WHR_EX2] & nxt_rf_wr_en_w0_wr)                    |
                                (str0_b_w1_where_ex1[WHR_EX2] & nxt_rf_wr_en_w1_wr & rf_wr_64b_w1_ex2) |
                                (str0_b_w2_where_ex1[WHR_EX2] & nxt_rf_wr_en_w2_wr & rf_wr_64b_w2_ex2);

  assign mac_fwd_ctl_ex1_o[5] = (str1_b_w0_where_ex1[WHR_EX2] & nxt_rf_wr_en_w0_wr)                    |
                                (str1_b_w1_where_ex1[WHR_EX2] & nxt_rf_wr_en_w1_wr & rf_wr_64b_w1_ex2) |
                                (str1_b_w2_where_ex1[WHR_EX2] & nxt_rf_wr_en_w2_wr & rf_wr_64b_w2_ex2);

  // Disable interlocks with MAC accumulator (if internal forwarding is possible).
  // Assumptions:
  //
  // - R2 is used by MAC operations to read the accumulator (32 bits per cycle),
  //   and W0 and W1/W2 are used to write-back the 32/64-bit result
  // - For forwarding purposes, W1/W2 always map on to R2 (the low bits of the
  //   result)
  // - W1 is used when executing from slot 0, W2 when executing from slot 1
  // - W2 can be used from either slot
  assign mac_no_ilock_r2_w0_iss = raw_mac_valid_iss                               &
                                  rf_rd_en_r2_iss                                 &
                                  mac_pipectl_iss[13]                             & // Accumulating high data
                                  (slot1_mul_iss
                                   ? (str1_data_b_sel_iss == `CA53_SEL_STR_B_R2)
                                   : (str0_data_b_sel_iss == `CA53_SEL_STR_B_R2)) &
                                  rf_wr_en_w0_ex1                                 &
                                  (rf_wr_src_w0_ex1 == `CA53_RF_WR_SRC_W0_MAC_HI) &
                                  (rf_rd_addr_r2_iss == rf_wr_addr_w0_ex1);

  assign mac_no_ilock_r2_w1_iss = raw_mac_valid_iss   &
                                  rf_rd_en_r2_iss     &
                                  mac_pipectl_iss[12] &
                                  rf_wr_en_w1_ex1     &
                                  (rf_wr_src_w1_ex1 == `CA53_RF_WR_SRC_W1_MAC_LO) &
                                  (rf_rd_addr_r2_iss == rf_wr_addr_w1_ex1);

  assign mac_no_ilock_r2_w2_iss = raw_mac_valid_iss   &
                                  rf_rd_en_r2_iss     &
                                  mac_pipectl_iss[12] &
                                  rf_wr_en_w2_ex1     &
                                  (rf_wr_src_w2_ex1 == `CA53_RF_WR_SRC_W2_MAC_LO) &
                                  (rf_rd_addr_r2_iss == rf_wr_addr_w2_ex1);

  assign mac_no_ilock_r3_w0_iss = raw_mac_valid_iss                               &
                                  rf_rd_en_r3_iss                                 &
                                  ~slot1_mul_iss                                  &
                                  mac_pipectl_iss[13]                             & // Accumulating high data
                                  (str0_data_b_sel_iss == `CA53_SEL_STR_B_R3)     &
                                  rf_wr_en_w0_ex1                                 &
                                  (rf_wr_src_w0_ex1 == `CA53_RF_WR_SRC_W0_MAC_HI) &
                                  (rf_rd_addr_r3_iss == rf_wr_addr_w0_ex1);

  // We need to interlock in Iss if any flag setting or conditional
  // instruction follows a multiply that updates the CC flags.
  assign conditional_instr_iss = (valid_instrs_iss[0] & (cond_code_instr0_iss[3:1] != `CA53_CC_AL_or_NV)) |
                                 (valid_instrs_iss[1] & (cond_code_instr1_iss[3:1] != `CA53_CC_AL_or_NV)) |
                                 (valid_instrs_iss[0] & raw_alu0_valid_iss & (alu0_ex2_ctl_iss[`CA53_ALU_EX2_CTL_LU_CTL_BITS] == `CA53_LU_CTL_CSEL));

  // Identify if a load/store instruction is conditional
  assign ls_conditional_iss_o = slot1_ls_iss ? (cond_code_instr1_iss[3:1] != `CA53_CC_AL_or_NV)
                                             : (cond_code_instr0_iss[3:1] != `CA53_CC_AL_or_NV);

  // Check for instructions with opposite condition codes
  //
  // For the pipeline stages Ex1 and Ex2, the condition codes of the instruction in each
  // stage is compared to that of the instruction in Iss.  If the condition codes are
  // opposite (and not "always" or "never"), there are no flag-setting instructions
  // between the two instructions being compared and the instruction in Ex1/Ex2 is not
  // flag-setting itself, then any interlocks between the two instructions can be cancelled.
  //
  // Condition code cancelling is not done between Wr and Iss since it complicates the DPU
  // to DCU interface - specifically around cross-64 instructions - for little performance
  // benefit.

  assign opposite_cc_de_0_iss_0   = (cond_code_instr0_de_i[3:1] == cond_code_instr0_iss[3:1]) &
                                    (cond_code_instr0_de_i[0]   != cond_code_instr0_iss[0])   &
                                    (cond_code_instr0_de_i[3:1] != `CA53_CC_AL_or_NV);

  assign opposite_cc_de_0_ex1_0   = (cond_code_instr0_de_i[3:1] == cond_code_instr0_ex1[3:1]) &
                                    (cond_code_instr0_de_i[0]   != cond_code_instr0_ex1[0])   &
                                    (cond_code_instr0_de_i[3:1] != `CA53_CC_AL_or_NV);

  assign opposite_cc_iss_0_ex1_0  = (cond_code_instr0_iss[3:1]  == cond_code_instr0_ex1[3:1]) &
                                    (cond_code_instr0_iss[0]    != cond_code_instr0_ex1[0])   &
                                    (cond_code_instr0_iss[3:1]  != `CA53_CC_AL_or_NV);

  assign opposite_cc_iss_0_ex2_0  = (cond_code_instr0_iss[3:1]  == cond_code_instr0_ex2[3:1]) &
                                    (cond_code_instr0_iss[0]    != cond_code_instr0_ex2[0])   &
                                    (cond_code_instr0_iss[3:1]  != `CA53_CC_AL_or_NV);

  assign opposite_cc_de_0_iss_1   = (cond_code_instr0_de_i[3:1] == cond_code_instr1_iss[3:1]) &
                                    (cond_code_instr0_de_i[0]   != cond_code_instr1_iss[0])   &
                                    (cond_code_instr0_de_i[3:1] != `CA53_CC_AL_or_NV);

  assign opposite_cc_de_0_ex1_1   = (cond_code_instr0_de_i[3:1] == cond_code_instr1_ex1[3:1]) &
                                    (cond_code_instr0_de_i[0]   != cond_code_instr1_ex1[0])   &
                                    (cond_code_instr0_de_i[3:1] != `CA53_CC_AL_or_NV);

  assign opposite_cc_iss_0_ex1_1  = (cond_code_instr0_iss[3:1]  == cond_code_instr1_ex1[3:1]) &
                                    (cond_code_instr0_iss[0]    != cond_code_instr1_ex1[0])   &
                                    (cond_code_instr0_iss[3:1]  != `CA53_CC_AL_or_NV);

  assign opposite_cc_iss_0_ex2_1  = (cond_code_instr0_iss[3:1]  == cond_code_instr1_ex2[3:1]) &
                                    (cond_code_instr0_iss[0]    != cond_code_instr1_ex2[0])   &
                                    (cond_code_instr0_iss[3:1]  != `CA53_CC_AL_or_NV);

  assign opposite_cc_de_1_iss_0   = (cond_code_instr1_de_i[3:1] == cond_code_instr0_iss[3:1]) &
                                    (cond_code_instr1_de_i[0]   != cond_code_instr0_iss[0])   &
                                    (cond_code_instr1_de_i[3:1] != `CA53_CC_AL_or_NV);

  assign opposite_cc_de_1_ex1_0   = (cond_code_instr1_de_i[3:1] == cond_code_instr0_ex1[3:1]) &
                                    (cond_code_instr1_de_i[0]   != cond_code_instr0_ex1[0])   &
                                    (cond_code_instr1_de_i[3:1] != `CA53_CC_AL_or_NV);

  assign opposite_cc_iss_1_ex1_0  = (cond_code_instr1_iss[3:1]  == cond_code_instr0_ex1[3:1]) &
                                    (cond_code_instr1_iss[0]    != cond_code_instr0_ex1[0])   &
                                    (cond_code_instr1_iss[3:1]  != `CA53_CC_AL_or_NV);

  assign opposite_cc_iss_1_ex2_0  = (cond_code_instr1_iss[3:1]  == cond_code_instr0_ex2[3:1]) &
                                    (cond_code_instr1_iss[0]    != cond_code_instr0_ex2[0])   &
                                    (cond_code_instr1_iss[3:1]  != `CA53_CC_AL_or_NV);

  assign opposite_cc_de_1_iss_1   = (cond_code_instr1_de_i[3:1] == cond_code_instr1_iss[3:1]) &
                                    (cond_code_instr1_de_i[0]   != cond_code_instr1_iss[0])   &
                                    (cond_code_instr1_de_i[3:1] != `CA53_CC_AL_or_NV);

  assign opposite_cc_de_1_ex1_1   = (cond_code_instr1_de_i[3:1] == cond_code_instr1_ex1[3:1]) &
                                    (cond_code_instr1_de_i[0]   != cond_code_instr1_ex1[0])   &
                                    (cond_code_instr1_de_i[3:1] != `CA53_CC_AL_or_NV);

  assign opposite_cc_iss_1_ex1_1  = (cond_code_instr1_iss[3:1]  == cond_code_instr1_ex1[3:1]) &
                                    (cond_code_instr1_iss[0]    != cond_code_instr1_ex1[0])   &
                                    (cond_code_instr1_iss[3:1]  != `CA53_CC_AL_or_NV);

  assign opposite_cc_iss_1_ex2_1  = (cond_code_instr1_iss[3:1]  == cond_code_instr1_ex2[3:1]) &
                                    (cond_code_instr1_iss[0]    != cond_code_instr1_ex2[0])   &
                                    (cond_code_instr1_iss[3:1]  != `CA53_CC_AL_or_NV);

  // W0 is always for slot 0, unless dual issued load in slot 1
  assign nxt_opposite_cc_ex1_w0_iss[0] = stall_wr   ? (w0_slot1_ex1 ? opposite_cc_iss_0_ex1_1 : opposite_cc_iss_0_ex1_0) :
                                         stall_iss  ? 1'b0                                                               :
                                                      (w0_slot1_iss ? opposite_cc_de_0_iss_1  : opposite_cc_de_0_iss_0);

  assign nxt_opposite_cc_ex2_w0_iss[0] = stall_wr   ? (w0_slot1_ex2 ? opposite_cc_iss_0_ex2_1 : opposite_cc_iss_0_ex2_0) :
                                         stall_iss  ? 1'b0                                                               :
                                                      (w0_slot1_ex1 ? opposite_cc_de_0_ex1_1  : opposite_cc_de_0_ex1_0);

  assign nxt_opposite_cc_ex1_w0_iss[1] = stall_wr   ? (w0_slot1_ex1 ? opposite_cc_iss_1_ex1_1 : opposite_cc_iss_1_ex1_0) :
                                         stall_iss  ? 1'b0                                                               :
                                                      (w0_slot1_iss ? opposite_cc_de_1_iss_1  : opposite_cc_de_1_iss_0);

  assign nxt_opposite_cc_ex2_w0_iss[1] = stall_wr   ? (w0_slot1_ex2 ? opposite_cc_iss_1_ex2_1 : opposite_cc_iss_1_ex2_0) :
                                         stall_iss  ? 1'b0                                                               :
                                                      (w0_slot1_ex1 ? opposite_cc_de_1_ex1_1  : opposite_cc_de_1_ex1_0);

  // W1 is always for slot 0
  assign nxt_opposite_cc_ex1_w1_iss[0] = stall_wr   ? opposite_cc_iss_0_ex1_0 :
                                         stall_iss  ? 1'b0                    :
                                                      opposite_cc_de_0_iss_0;

  assign nxt_opposite_cc_ex2_w1_iss[0] = stall_wr   ? opposite_cc_iss_0_ex2_0 :
                                         stall_iss  ? 1'b0                    :
                                                      opposite_cc_de_0_ex1_0;

  assign nxt_opposite_cc_ex1_w1_iss[1] = stall_wr   ? opposite_cc_iss_1_ex1_0 :
                                         stall_iss  ? 1'b0                    :
                                                      opposite_cc_de_1_iss_0;

  assign nxt_opposite_cc_ex2_w1_iss[1] = stall_wr   ? opposite_cc_iss_1_ex2_0 :
                                         stall_iss  ? 1'b0                    :
                                                      opposite_cc_de_1_ex1_0;

  // W2 is for slot 1 if valid, otherwise slot 0
  assign nxt_opposite_cc_ex1_w2_iss[0] = stall_wr   ? (valid_instrs_ex1[1] ? opposite_cc_iss_0_ex1_1 : opposite_cc_iss_0_ex1_0)  :
                                         stall_iss  ? 1'b0                                                                       :
                                                      (valid_instrs_iss[1] ? opposite_cc_de_0_iss_1  : opposite_cc_de_0_iss_0);

  assign nxt_opposite_cc_ex2_w2_iss[0] = stall_wr   ? (valid_instrs_ex2[1] ? opposite_cc_iss_0_ex2_1 : opposite_cc_iss_0_ex2_0)  :
                                         stall_iss  ? 1'b0                                                                       :
                                                      (valid_instrs_ex1[1] ? opposite_cc_de_0_ex1_1  : opposite_cc_de_0_ex1_0);

  assign nxt_opposite_cc_ex1_w2_iss[1] = stall_wr   ? (valid_instrs_ex1[1] ? opposite_cc_iss_1_ex1_1 : opposite_cc_iss_1_ex1_0)  :
                                         stall_iss  ? 1'b0                                                                       :
                                                      (valid_instrs_iss[1] ? opposite_cc_de_1_iss_1  : opposite_cc_de_1_iss_0);

  assign nxt_opposite_cc_ex2_w2_iss[1] = stall_wr   ? (valid_instrs_ex2[1] ? opposite_cc_iss_1_ex2_1 : opposite_cc_iss_1_ex2_0)  :
                                         stall_iss  ? 1'b0                                                                       :
                                                      (valid_instrs_ex1[1] ? opposite_cc_de_1_ex1_1  : opposite_cc_de_1_ex1_0);


  always @(posedge clk) begin
    opposite_cc_ex1_w0_iss <= nxt_opposite_cc_ex1_w0_iss[1:0];
    opposite_cc_ex2_w0_iss <= nxt_opposite_cc_ex2_w0_iss[1:0];
    opposite_cc_ex1_w1_iss <= nxt_opposite_cc_ex1_w1_iss[1:0];
    opposite_cc_ex2_w1_iss <= nxt_opposite_cc_ex2_w1_iss[1:0];
    opposite_cc_ex1_w2_iss <= nxt_opposite_cc_ex1_w2_iss[1:0];
    opposite_cc_ex2_w2_iss <= nxt_opposite_cc_ex2_w2_iss[1:0];
  end

  // Suppress CC cancelling if there is a flag setting operation between the two
  // opposite condition code instructions.
  // - Note for slot 1, there could be a flag setting instruction in slot 0 in
  // the same pipeline stage
  assign suppress_cc_cancel_ex1_iss[1] = alu0_flagset_iss |
                                         alu0_flagset_ex1 | alu1_flagset_ex1 | muls_in_ex1;

  assign suppress_cc_cancel_ex1_iss[0] = alu0_flagset_ex1 | alu1_flagset_ex1 | muls_in_ex1;

  assign suppress_cc_cancel_ex2_iss[1] = alu0_flagset_iss |
                                         alu0_flagset_ex1 | alu1_flagset_ex1 | muls_in_ex1 |
                                         alu0_flagset_ex2 | alu1_flagset_ex2 | muls_in_ex2;

  assign suppress_cc_cancel_ex2_iss[0] = alu0_flagset_ex1 | alu1_flagset_ex1 | muls_in_ex1 |
                                         alu0_flagset_ex2 | alu1_flagset_ex2 | muls_in_ex2;

  assign cc_cancel_ex1_w0_iss = opposite_cc_ex1_w0_iss[1:0] & ~suppress_cc_cancel_ex1_iss[1:0];
  assign cc_cancel_ex2_w0_iss = opposite_cc_ex2_w0_iss[1:0] & ~suppress_cc_cancel_ex2_iss[1:0];

  assign cc_cancel_ex1_w1_iss = opposite_cc_ex1_w1_iss[1:0] & ~suppress_cc_cancel_ex1_iss[1:0];
  assign cc_cancel_ex2_w1_iss = opposite_cc_ex2_w1_iss[1:0] & ~suppress_cc_cancel_ex2_iss[1:0];

  assign cc_cancel_ex1_w2_iss = opposite_cc_ex1_w2_iss[1:0] & ~suppress_cc_cancel_ex1_iss[1:0];
  assign cc_cancel_ex2_w2_iss = opposite_cc_ex2_w2_iss[1:0] & ~suppress_cc_cancel_ex2_iss[1:0];

  // Calculate which read/write ports belongs to which instruction slot in iss
  assign r01_slot0_iss  = ~rf_rd_remap_iss;
  assign r2_slot0_iss   = instr0_r2_enabled_iss;
  assign r34_slot0_iss  = rf_rd_remap_iss | ~valid_instrs_iss[1]; // R3 belongs to slot 0 when not dual issuing

  assign w0_slot1_iss   = ~instr0_w0_enabled_iss;

  // Calculate when an mrc instruction ahead must cause an interlock
  assign mrc_interlock_iss = (|(r0_w0_where_iss[WHR_EX1:WHR_WR] & {mrc_instr_ex1_i,mrc_instr_ex2_i,mrc_instr_wr_i})) |
                             (|(r0_w1_where_iss[WHR_EX1:WHR_WR] & {mrc_instr_ex1_i,mrc_instr_ex2_i,mrc_instr_wr_i})) |
                             (|(r1_w0_where_iss[WHR_EX1:WHR_WR] & {mrc_instr_ex1_i,mrc_instr_ex2_i,mrc_instr_wr_i})) |
                             (|(r1_w1_where_iss[WHR_EX1:WHR_WR] & {mrc_instr_ex1_i,mrc_instr_ex2_i,mrc_instr_wr_i})) |
                             (|(r2_w0_where_iss[WHR_EX1:WHR_WR] & {mrc_instr_ex1_i,mrc_instr_ex2_i,mrc_instr_wr_i})) |
                             (|(r2_w1_where_iss[WHR_EX1:WHR_WR] & {mrc_instr_ex1_i,mrc_instr_ex2_i,mrc_instr_wr_i})) |
                             (|(r3_w0_where_iss[WHR_EX1:WHR_WR] & {mrc_instr_ex1_i,mrc_instr_ex2_i,mrc_instr_wr_i})) |
                             (|(r3_w1_where_iss[WHR_EX1:WHR_WR] & {mrc_instr_ex1_i,mrc_instr_ex2_i,mrc_instr_wr_i})) |
                             (|(r4_w0_where_iss[WHR_EX1:WHR_WR] & {mrc_instr_ex1_i,mrc_instr_ex2_i,mrc_instr_wr_i})) |
                             (|(r4_w1_where_iss[WHR_EX1:WHR_WR] & {mrc_instr_ex1_i,mrc_instr_ex2_i,mrc_instr_wr_i}));

  // Calculate when the register feeding the B operand of the AGU is being
  // sign extended, as need to suppress early Iss forwarding in this case
  assign agu_b_sxt_iss = (agu_data_b_sel_iss_i[5:4] == 2'b10);

  // Calculate when the data each instruction wants to read is going to be available.
  //
  // rf_rd_need_rx_iss => 000 Ex2
  //                      100 Ex1
  //                      110 Late iss
  //                      111 Early iss (load/store only)
  //
  // rx_when_iss       => 000 Available now (early)
  //                      001 Available now (late)
  //                      011 Available when I'm in Ex1
  //                      111 Available when I'm in Ex2
  //
  // rf_wr_when_wx_xxx => 000  Ex1
  //                      001  Ex2
  //                      011  early wr
  //                      111  late wr
  //
  // rx_wy_where_iss   => 1xxx currently in iss (r2 only)
  //                      x1xx currently in ex1
  //                      xx1x currently in ex2
  //                      xxx1 currently in wr
  //
  // The rx_when_iss signals do not factor stall_wr into the W2 Wr where
  // terms, because only the W0 output of the load/store pipe can foward it's
  // data to early iss (a load hazarded on the W2 output needs to stall for
  // an extra cycle and read the value of the regbank).
  //
  // The W2 when signals are not suppressed by the cc cancel logic if when
  // there is an instruction in slot 1, as the cc cancel logic is not valid
  // in that case. Note also that there is no cc cancel logic between Wr and
  // iss, so the Wr terms can never be suppressed.

  // Wx not available to instr in iss in:         ex1                             late iss                        early iss
  assign cannot_fwd_from_ex2_to_ex1_w0_ex1     = {rf_wr_when_w0_ex1[WHN_NOT_EX2], rf_wr_when_w0_ex1[WHN_NOT_EX1], 1'b1};
  assign cannot_fwd_from_ex2_to_iss_w0_ex2     = {1'b0,                           rf_wr_when_w0_ex2[WHN_NOT_EX2], rf_wr_when_w0_ex2[WHN_NOT_EX1]};
  assign cannot_fwd_from_wr_to_early_iss_w0_wr = {1'b0,                           agu_b_sxt_iss | ls_stall_wr_i,  (rf_wr_when_n_early_wr_w0_wr | ls_stall_wr_i | div_stall_wr)};

  assign cannot_fwd_from_ex2_to_ex1_w1_ex1     = {rf_wr_when_w1_ex1[WHN_NOT_EX2], rf_wr_when_w1_ex1[WHN_NOT_EX1], 1'b1};
  assign cannot_fwd_from_ex2_to_iss_w1_ex2     = {1'b0,                           rf_wr_when_w1_ex2[WHN_NOT_EX2], rf_wr_when_w1_ex2[WHN_NOT_EX1]};
  assign cannot_fwd_from_wr_to_early_iss_w1_wr = {1'b0,                           1'b0,                           rf_wr_when_n_early_wr_w1_wr};

  assign cannot_fwd_from_ex2_to_ex1_w2_ex1     = {rf_wr_when_w2_ex1[WHN_NOT_EX2], rf_wr_when_w2_ex1[WHN_NOT_EX1], 1'b1};
  assign cannot_fwd_from_ex2_to_iss_w2_ex2     = {1'b0,                           rf_wr_when_w2_ex2[WHN_NOT_EX2], rf_wr_when_w2_ex2[WHN_NOT_EX1]};
  assign cannot_fwd_from_wr_to_early_iss_w2_wr = {1'b0,                           1'b0,                           rf_wr_when_n_early_wr_w2_wr};

  assign r0_when_iss = // ex1 instr wx writes r0
                       ({3{r0_w0_where_iss[WHR_EX1]}} & cannot_fwd_from_ex2_to_ex1_w0_ex1 & {3{~(r01_slot0_iss ? cc_cancel_ex1_w0_iss[0] : cc_cancel_ex1_w0_iss[1])}}) |
                       ({3{r0_w1_where_iss[WHR_EX1]}} & cannot_fwd_from_ex2_to_ex1_w1_ex1 & {3{~(r01_slot0_iss ? cc_cancel_ex1_w1_iss[0] : cc_cancel_ex1_w1_iss[1])}}) |
                       ({3{r0_w2_where_iss[WHR_EX1]}} & cannot_fwd_from_ex2_to_ex1_w2_ex1 & {3{~(r01_slot0_iss ? cc_cancel_ex1_w2_iss[0] : cc_cancel_ex1_w2_iss[1])}}) |

                       // ex2 instr wx writes r0
                       ({3{r0_w0_where_iss[WHR_EX2]}} & cannot_fwd_from_ex2_to_iss_w0_ex2 & {3{~(r01_slot0_iss ? cc_cancel_ex2_w0_iss[0] : cc_cancel_ex2_w0_iss[1])}}) |
                       ({3{r0_w1_where_iss[WHR_EX2]}} & cannot_fwd_from_ex2_to_iss_w1_ex2 & {3{~(r01_slot0_iss ? cc_cancel_ex2_w1_iss[0] : cc_cancel_ex2_w1_iss[1])}}) |
                       ({3{r0_w2_where_iss[WHR_EX2]}} & cannot_fwd_from_ex2_to_iss_w2_ex2 & {3{~(r01_slot0_iss ? cc_cancel_ex2_w2_iss[0] : cc_cancel_ex2_w2_iss[1])}}) |

                       // wr instr wx writes r0
                       ({3{r0_w0_where_iss[WHR_WR] }} & cannot_fwd_from_wr_to_early_iss_w0_wr) |
                       ({3{r0_w1_where_iss[WHR_WR] }} & cannot_fwd_from_wr_to_early_iss_w1_wr) |
                       ({3{r0_w2_where_iss[WHR_WR] }} & cannot_fwd_from_wr_to_early_iss_w2_wr);

  assign r1_when_iss = ({3{r1_w0_where_iss[WHR_EX1]}} & cannot_fwd_from_ex2_to_ex1_w0_ex1 & {3{~(r01_slot0_iss ? cc_cancel_ex1_w0_iss[0] : cc_cancel_ex1_w0_iss[1])}}) |
                       ({3{r1_w1_where_iss[WHR_EX1]}} & cannot_fwd_from_ex2_to_ex1_w1_ex1 & {3{~(r01_slot0_iss ? cc_cancel_ex1_w1_iss[0] : cc_cancel_ex1_w1_iss[1])}}) |
                       ({3{r1_w2_where_iss[WHR_EX1]}} & cannot_fwd_from_ex2_to_ex1_w2_ex1 & {3{~(r01_slot0_iss ? cc_cancel_ex1_w2_iss[0] : cc_cancel_ex1_w2_iss[1])}}) |

                       ({3{r1_w0_where_iss[WHR_EX2]}} & cannot_fwd_from_ex2_to_iss_w0_ex2 & {3{~(r01_slot0_iss ? cc_cancel_ex2_w0_iss[0] : cc_cancel_ex2_w0_iss[1])}}) |
                       ({3{r1_w1_where_iss[WHR_EX2]}} & cannot_fwd_from_ex2_to_iss_w1_ex2 & {3{~(r01_slot0_iss ? cc_cancel_ex2_w1_iss[0] : cc_cancel_ex2_w1_iss[1])}}) |
                       ({3{r1_w2_where_iss[WHR_EX2]}} & cannot_fwd_from_ex2_to_iss_w2_ex2 & {3{~(r01_slot0_iss ? cc_cancel_ex2_w2_iss[0] : cc_cancel_ex2_w2_iss[1])}}) |

                       ({3{r1_w0_where_iss[WHR_WR] }} & cannot_fwd_from_wr_to_early_iss_w0_wr) |
                       ({3{r1_w1_where_iss[WHR_WR] }} & cannot_fwd_from_wr_to_early_iss_w1_wr) |
                       ({3{r1_w2_where_iss[WHR_WR] }} & cannot_fwd_from_wr_to_early_iss_w2_wr);

  assign r2_when_iss = ({3{r2_w0_where_iss[WHR_EX1]}} & cannot_fwd_from_ex2_to_ex1_w0_ex1 & {3{~(r2_slot0_iss  ? cc_cancel_ex1_w0_iss[0] : cc_cancel_ex1_w0_iss[1])}} & {3{~mac_no_ilock_r2_w0_iss}}) |
                       ({3{r2_w1_where_iss[WHR_EX1]}} & cannot_fwd_from_ex2_to_ex1_w1_ex1 & {3{~(r2_slot0_iss  ? cc_cancel_ex1_w1_iss[0] : cc_cancel_ex1_w1_iss[1])}} & {3{~mac_no_ilock_r2_w1_iss}}) |
                       ({3{r2_w2_where_iss[WHR_EX1]}} & cannot_fwd_from_ex2_to_ex1_w2_ex1 & {3{~(r2_slot0_iss  ? cc_cancel_ex1_w2_iss[0] : cc_cancel_ex1_w2_iss[1])}} & {3{~mac_no_ilock_r2_w2_iss}}) |

                       ({3{r2_w0_where_iss[WHR_EX2]}} & cannot_fwd_from_ex2_to_iss_w0_ex2 & {3{~(r2_slot0_iss  ? cc_cancel_ex2_w0_iss[0] : cc_cancel_ex2_w0_iss[1])}}) |
                       ({3{r2_w1_where_iss[WHR_EX2]}} & cannot_fwd_from_ex2_to_iss_w1_ex2 & {3{~(r2_slot0_iss  ? cc_cancel_ex2_w1_iss[0] : cc_cancel_ex2_w1_iss[1])}}) |
                       ({3{r2_w2_where_iss[WHR_EX2]}} & cannot_fwd_from_ex2_to_iss_w2_ex2 & {3{~(r2_slot0_iss  ? cc_cancel_ex2_w2_iss[0] : cc_cancel_ex2_w2_iss[1])}}) |

                       ({3{r2_w0_where_iss[WHR_WR] }} & cannot_fwd_from_wr_to_early_iss_w0_wr) |
                       ({3{r2_w1_where_iss[WHR_WR] }} & cannot_fwd_from_wr_to_early_iss_w1_wr) |
                       ({3{r2_w2_where_iss[WHR_WR] }} & cannot_fwd_from_wr_to_early_iss_w2_wr);

  assign r3_when_iss = ({3{r3_w0_where_iss[WHR_EX1]}} & cannot_fwd_from_ex2_to_ex1_w0_ex1 & {3{~(r34_slot0_iss ? cc_cancel_ex1_w0_iss[0] : cc_cancel_ex1_w0_iss[1])}} & {3{~mac_no_ilock_r3_w0_iss}}) |
                       ({3{r3_w1_where_iss[WHR_EX1]}} & cannot_fwd_from_ex2_to_ex1_w1_ex1 & {3{~(r34_slot0_iss ? cc_cancel_ex1_w1_iss[0] : cc_cancel_ex1_w1_iss[1])}})                                |
                       ({3{r3_w2_where_iss[WHR_EX1]}} & cannot_fwd_from_ex2_to_ex1_w2_ex1 & {3{~(r34_slot0_iss ? cc_cancel_ex1_w2_iss[0] : cc_cancel_ex1_w2_iss[1])}})                                |

                       ({3{r3_w0_where_iss[WHR_EX2]}} & cannot_fwd_from_ex2_to_iss_w0_ex2 & {3{~(r34_slot0_iss ? cc_cancel_ex2_w0_iss[0] : cc_cancel_ex2_w0_iss[1])}}) |
                       ({3{r3_w1_where_iss[WHR_EX2]}} & cannot_fwd_from_ex2_to_iss_w1_ex2 & {3{~(r34_slot0_iss ? cc_cancel_ex2_w1_iss[0] : cc_cancel_ex2_w1_iss[1])}}) |
                       ({3{r3_w2_where_iss[WHR_EX2]}} & cannot_fwd_from_ex2_to_iss_w2_ex2 & {3{~(r34_slot0_iss ? cc_cancel_ex2_w2_iss[0] : cc_cancel_ex2_w2_iss[1])}}) |

                       ({3{r3_w0_where_iss[WHR_WR] }} & cannot_fwd_from_wr_to_early_iss_w0_wr) |
                       ({3{r3_w1_where_iss[WHR_WR] }} & cannot_fwd_from_wr_to_early_iss_w1_wr) |
                       ({3{r3_w2_where_iss[WHR_WR] }} & cannot_fwd_from_wr_to_early_iss_w2_wr);

  assign r4_when_iss = ({3{r4_w0_where_iss[WHR_EX1]}} & cannot_fwd_from_ex2_to_ex1_w0_ex1 & {3{~(r34_slot0_iss ? cc_cancel_ex1_w0_iss[0] : cc_cancel_ex1_w0_iss[1])}}) |
                       ({3{r4_w1_where_iss[WHR_EX1]}} & cannot_fwd_from_ex2_to_ex1_w1_ex1 & {3{~(r34_slot0_iss ? cc_cancel_ex1_w1_iss[0] : cc_cancel_ex1_w1_iss[1])}}) |
                       ({3{r4_w2_where_iss[WHR_EX1]}} & cannot_fwd_from_ex2_to_ex1_w2_ex1 & {3{~(r34_slot0_iss ? cc_cancel_ex1_w2_iss[0] : cc_cancel_ex1_w2_iss[1])}}) |

                       ({3{r4_w0_where_iss[WHR_EX2]}} & cannot_fwd_from_ex2_to_iss_w0_ex2 & {3{~(r34_slot0_iss ? cc_cancel_ex2_w0_iss[0] : cc_cancel_ex2_w0_iss[1])}}) |
                       ({3{r4_w1_where_iss[WHR_EX2]}} & cannot_fwd_from_ex2_to_iss_w1_ex2 & {3{~(r34_slot0_iss ? cc_cancel_ex2_w1_iss[0] : cc_cancel_ex2_w1_iss[1])}}) |
                       ({3{r4_w2_where_iss[WHR_EX2]}} & cannot_fwd_from_ex2_to_iss_w2_ex2 & {3{~(r34_slot0_iss ? cc_cancel_ex2_w2_iss[0] : cc_cancel_ex2_w2_iss[1])}}) |

                       ({3{r4_w0_where_iss[WHR_WR] }} & cannot_fwd_from_wr_to_early_iss_w0_wr) |
                       ({3{r4_w1_where_iss[WHR_WR] }} & cannot_fwd_from_wr_to_early_iss_w1_wr) |
                       ({3{r4_w2_where_iss[WHR_WR] }} & cannot_fwd_from_wr_to_early_iss_w2_wr);


  assign interlock_iss = // When forceop_valid_de is signalled there is not a real instruction in
                         // issue being pre-empted by the divide so we can clock the forceop into issue
                         // Prevent hazarding on slot 0 read ports when the second half of a slot 1 x64
                         // is executing, to avoid the slot 0 instruction interlocking on itself
                         ((special_stall_iss & ~forceop_valid_iss) |
                          (muls_in_ex1 & conditional_instr_iss) |
                          ((|(rf_rd_need_r0_iss & r0_when_iss)) & ~sel_fwd_addr_dcu_a_iss)                            |
                          ( |(rf_rd_need_r1_iss & r1_when_iss))                                                       |
                          ((|(rf_rd_need_r2_iss & r2_when_iss)) & ~(slot1_ls_iss & r2_slot0_iss  & second_x64_iss_i)) |
                          ((|(rf_rd_need_r3_iss & r3_when_iss)) & ~(slot1_ls_iss & r34_slot0_iss & second_x64_iss_i)) |
                          ((|(rf_rd_need_r4_iss & r4_when_iss)) & ~(slot1_ls_iss & r34_slot0_iss & second_x64_iss_i)) |
                          fpu_interlock_iss |
                          mrc_interlock_iss) &
                         valid_instrs_iss[0];

  // Divider stall control
  // A divide uop will issue down the pipeline, then stall in wr until the
  // divider is ready
  // A subsequent divide uop will stall in iss if the earlier one has not
  // yet completed
  assign div_in_ex1 =     rf_wr_en_w1_ex1 & (rf_wr_src_w1_ex1 == `CA53_RF_WR_SRC_W1_DIV);
  assign div_in_ex2 = raw_rf_wr_en_w1_ex2 & (rf_wr_src_w1_ex2 == `CA53_RF_WR_SRC_W1_DIV);
  assign div_in_wr  = raw_rf_wr_en_w1_wr  & (rf_wr_src_w1_wr  == `CA53_RF_WR_SRC_W1_DIV) & pre_valid_instrs_wr[0];

  assign div_stall_iss = raw_div_valid_iss & (div_busy_iss_i | div_in_ex1 | div_in_ex2 | div_stall_wr);

  assign nxt_div_stall_wr = ((div_in_ex2 & cc_pass_instr0_ex2_i & nxt_valid_instrs_wr[0]) |
                             (div_stall_wr & ~quash_slot0_wr)) & nxt_div_busy_wr_i;

  // If a divide is in wr, only flush the divider on flush_ret, otherwise
  // use flush_wr
  assign div_flush = div_in_wr ? flush_ret : (flush_wr | (div_in_ex2 & ~cc_pass_instr0_ex2_i));

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      div_stall_wr <= 1'b0;
    else
      div_stall_wr <= nxt_div_stall_wr;

  // ETM can request a pipeline stall - only takes effect if DBGEN set
  // Only stall the head of an instruction, to prevent inserting delays
  // mid-instruction
  assign nxt_etm_stall_iss = etm_stall_cpu_i & dbgen_synced_i & ~in_halt_i & (valid_iss_en ? head_instr_de_i[0] : pre_head_instr_iss[0]);
  
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      etm_stall_iss <= 1'b0;
    else
      etm_stall_iss <= nxt_etm_stall_iss;

  // Create different issue stall signals depending on what we are trying to stall
  assign ilock_stall_iss     = interlock_iss | stall_wr | etm_stall_iss | div_stall_iss | mac_stall_iss_i | paq_stall_iss_i | neon_ret_stall_iss | dcu_not_ready_iss_i;
  assign ilock_stall_div_iss = interlock_iss | stall_wr | etm_stall_iss | div_stall_iss | mac_stall_iss_i | paq_stall_iss_i | neon_ret_stall_iss;
  assign ilock_stall_mac_iss = interlock_iss | stall_wr | etm_stall_iss | div_stall_iss                   | paq_stall_iss_i | neon_ret_stall_iss | dcu_not_ready_iss_i;

  assign stall_iss           = ilock_stall_iss | first_x64_iss_i | force_extra_lsm_cycle_i;

  // On a cross-64 LS instruction, need to stall the pipeline. If the load
  // or store is in slot 1, then allow the slot 0 instruction to proceed in the
  // first cycle
  assign stall_slot0_iss     = ilock_stall_iss | (slot1_ls_iss ? second_x64_iss_i : first_x64_iss_i) | force_extra_lsm_cycle_i;

  // Stall the branch pipe in Iss based on whether the branch is in slot 0/1
  assign stall_br_iss_o      = slot1_branch_iss ? stall_iss : stall_slot0_iss;

  // The stall_wr that every stage except Wr needs to include ~flush so that
  // a flush is guarenteed to be clocked into the valid bits
  assign stall_wr = (ls_stall_wr_i & ~slot0_br_flush_wr_i) | wfx_stall_wr | div_stall_wr;

  // Export events including creating an event for pointer chasing interlocks
  assign evnt_fpu_interlock_iss_o = fpu_interlock_iss;
  assign evnt_agu_interlock_iss_o = ls_valid_iss_i & ((rf_rd_en_r0_iss & (|(rf_rd_need_r0_iss & r0_when_iss))) |
                                                      (rf_rd_en_r1_iss & (|(rf_rd_need_r1_iss & r1_when_iss))));

generate if (NEON_FP) begin : FPU1
  reg                         [1:0] unflushable_sfmac_ex1_reg;
  reg                         [1:0] unflushable_sfmac_ex2_reg;
  reg                         [1:0] unflushable_sfmac_wr_reg;
  reg                               unflushable_sfdiv_ex1;
  reg                               unflushable_ex2_reg;
  reg                               unflushable_wr_reg;
  reg                               instr_is_cp10_cp11_ex1;
  reg                               instr_is_cp10_cp11_ex2;
  reg                               instr_is_cp10_cp11_wr;
  reg                               instr_is_cp10_cp11_f4;
  reg                               instr_is_cp10_cp11_f5;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] raw_rf_rd_addr_fr0_iss;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] raw_rf_rd_addr_fr1_iss;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] raw_rf_rd_addr_fr2_iss;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] raw_rf_rd_addr_fr3_iss;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] raw_rf_rd_addr_fr4_iss;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] raw_rf_rd_addr_fr5_iss;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] held_rf_rd_addr_fr1_iss;
  reg                         [1:0] raw_rf_rd_en_fr0_iss;
  reg                         [1:0] raw_rf_rd_en_fr1_iss;
  reg                         [1:0] raw_rf_rd_en_fr2_iss;
  reg                         [1:0] raw_rf_rd_en_fr3_iss;
  reg                         [1:0] raw_rf_rd_en_fr4_iss;
  reg                         [1:0] raw_rf_rd_en_fr5_iss;
  reg                         [1:0] held_rf_rd_en_fr0_iss;
  reg                         [1:0] held_rf_rd_en_fr1_iss;
  reg     [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr0_iss;
  reg     [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr1_iss;
  reg     [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr2_iss;
  reg     [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr3_iss;
  reg     [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr4_iss;
  reg     [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr5_iss;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] raw_rf_wr_addr_fw0_iss;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] raw_rf_wr_addr_fw1_iss;
  reg                         [3:0] held_rf_wr_en_fw_iss;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] held_rf_wr_addr_fw_iss;
  reg                         [3:0] raw_rf_wr_en_fw0_iss;
  reg                         [3:0] raw_rf_wr_en_fw1_iss;
  reg      [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_iss;
  reg      [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw1_iss;
  reg     [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw0_iss;
  reg     [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw1_iss;
  reg                         [1:0] rf_rd_en_fr0_f1;
  reg                         [1:0] rf_rd_en_fr1_f1;
  reg                         [1:0] rf_rd_en_fr2_f1;
  reg                         [1:0] rf_rd_en_fr3_f1;
  reg                         [1:0] rf_rd_en_fr4_f1;
  reg                         [1:0] rf_rd_en_fr5_f1;
  reg                         [1:0] rf_rd_en_fr0_f2;
  reg                         [1:0] rf_rd_en_fr1_f2;
  reg                         [1:0] rf_rd_en_fr2_f2;
  reg                         [1:0] rf_rd_en_fr3_f2;
  reg                         [1:0] rf_rd_en_fr4_f2;
  reg                         [1:0] rf_rd_en_fr5_f2;
  reg                         [3:0] raw_rf_wr_en_fw0_f1;
  reg                         [3:0] raw_rf_wr_en_fw1_f1;
  reg                         [3:0] raw_rf_wr_en_fw0_f2;
  reg                         [3:0] raw_rf_wr_en_fw1_f2;
  reg                         [3:0] raw_rf_wr_en_fw0_f3;
  reg                         [3:0] raw_rf_wr_en_fw1_f3;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw0_f1;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw1_f1;
  reg      [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_f1;
  reg      [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw1_f1;
  reg     [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw0_f1;
  reg     [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw1_f1;
  reg                        [12:0] fp0_imm_data_f1;
  reg                        [12:0] fp1_imm_data_f1;
  reg       [`CA53_SEL_FAD_A_W-1:0] sel_fad0_a_f1;
  reg       [`CA53_SEL_FAD_B_W-1:0] sel_fad0_b_f1;
  reg       [`CA53_SEL_FAD_C_W-1:0] sel_fad0_c_f1;
  reg       [`CA53_SEL_FAD_A_W-1:0] sel_fad1_a_f1;
  reg       [`CA53_SEL_FAD_B_W-1:0] sel_fad1_b_f1;
  reg       [`CA53_SEL_FAD_C_W-1:0] sel_fad1_c_f1;
  reg                               sel_fml0_a_f1;
  reg       [`CA53_SEL_FML_B_W-1:0] sel_fml0_b_f1;
  reg                               sel_fml0_c_f1;
  reg                               sel_fml1_a_f1;
  reg       [`CA53_SEL_FML_B_W-1:0] sel_fml1_b_f1;
  reg                               sel_fml1_c_f1;
  reg                         [2:0] fr0_fw0_where_f1 [1:0];
  reg                         [2:0] fr0_fw1_where_f1 [1:0];
  reg                         [2:0] fr1_fw0_where_f1 [1:0];
  reg                         [2:0] fr1_fw1_where_f1 [1:0];
  reg                         [2:0] fr2_fw0_where_f1 [1:0];
  reg                         [2:0] fr2_fw1_where_f1 [1:0];
  reg                         [2:0] fr3_fw0_where_f1 [1:0];
  reg                         [2:0] fr3_fw1_where_f1 [1:0];
  reg                         [2:0] fr4_fw0_where_f1 [1:0];
  reg                         [2:0] fr4_fw1_where_f1 [1:0];
  reg                         [2:0] fr5_fw0_where_f1 [1:0];
  reg                         [2:0] fr5_fw1_where_f1 [1:0];
  reg                         [1:0] fr0_zero_available_f1;
  reg                         [1:0] fr1_zero_available_f1;
  reg                         [1:0] fr2_zero_available_f1;
  reg                         [1:0] fr3_zero_available_f1;
  reg                         [1:0] fr4_zero_available_f1;
  reg                         [1:0] fr5_zero_available_f1;
  reg                         [2:0] fr0_fw0_available_f1 [1:0];
  reg                         [2:0] fr0_fw1_available_f1 [1:0];
  reg                         [2:0] fr1_fw0_available_f1 [1:0];
  reg                         [2:0] fr1_fw1_available_f1 [1:0];
  reg                         [2:0] fr2_fw0_available_f1 [1:0];
  reg                         [2:0] fr2_fw1_available_f1 [1:0];
  reg                         [2:0] fr3_fw0_available_f1 [1:0];
  reg                         [2:0] fr3_fw1_available_f1 [1:0];
  reg                         [2:0] fr4_fw0_available_f1 [1:0];
  reg                         [2:0] fr4_fw1_available_f1 [1:0];
  reg                         [2:0] fr5_fw0_available_f1 [1:0];
  reg                         [2:0] fr5_fw1_available_f1 [1:0];
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw0_f2;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw1_f2;
  reg      [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_f2;
  reg      [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw1_f2;
  reg     [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw0_f2;
  reg     [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw1_f2;
  reg                         [2:0] fr0_fw0_where_f2 [1:0];
  reg                         [2:0] fr0_fw1_where_f2 [1:0];
  reg                         [2:0] fr1_fw0_where_f2 [1:0];
  reg                         [2:0] fr1_fw1_where_f2 [1:0];
  reg                         [2:0] fr2_fw0_where_f2 [1:0];
  reg                         [2:0] fr2_fw1_where_f2 [1:0];
  reg                         [2:0] fr3_fw0_where_f2 [1:0];
  reg                         [2:0] fr3_fw1_where_f2 [1:0];
  reg                         [2:0] fr4_fw0_where_f2 [1:0];
  reg                         [2:0] fr4_fw1_where_f2 [1:0];
  reg                         [2:0] fr5_fw0_where_f2 [1:0];
  reg                         [2:0] fr5_fw1_where_f2 [1:0];
  reg                         [1:0] fp_mul_fwd_ex1;
  reg                         [1:0] fp_mul_fwd_ex2;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw0_f3;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw1_f3;
  reg      [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_f3;
  reg      [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw1_f3;
  reg     [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw0_f3;
  reg     [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw1_f3;
  reg                         [1:0] fdivs_valid_f3;
  reg                         [3:0] raw_rf_wr_en_fw0_f4;
  reg                         [3:0] raw_rf_wr_en_fw1_f4;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw0_f4;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw1_f4;
  reg      [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_f4;
  reg      [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw1_f4;
  reg     [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw0_f4;
  reg     [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw1_f4;
  reg                               rf_wr_en_fw_f5;
  reg                         [3:0] rf_wr_en_fw0_f5;
  reg                         [3:0] rf_wr_en_fw1_f5;
  reg                         [1:0] rf_wr_valid_fw0_f5;
  reg                         [1:0] rf_wr_valid_fw1_f5;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw0_f5;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw1_f5;
  reg      [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_f5;
  reg      [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw1_f5;
  reg                               pre_instr_is_cp10_cp11_iss;
  reg      [`CA53_FP_EX_PIPE_W-1:0] raw_fp_ex_pipe_f1;
  reg                         [1:0] fdivs_pre_valid_f2;
  reg                         [1:0] fmac_valid_sp_iss;
  reg                         [1:0] raw_fdiv_valid_iss;
  reg                         [1:0] neon_can_fwd_acc_iss;
  reg    [`CA53_NEON_VLD_CTL_W-1:0] neon_vld_ctl_iss;
  reg      [`CA53_FP_EX_PIPE_W-1:0] raw_fp_ex_pipe_iss;
  reg                               no_insert_iss;
  reg    [`CA53_FP_CFLAG_SRC_W-1:0] fp0_cflag_src_f1;
  reg    [`CA53_FP_CFLAG_SRC_W-1:0] fp1_cflag_src_f1;
  reg    [`CA53_FP_XFLAG_SRC_W-1:0] fp0_xflag_src_f1;
  reg    [`CA53_FP_XFLAG_SRC_W-1:0] fp1_xflag_src_f1;
  reg    [`CA53_FP_CFLAG_SRC_W-1:0] fp0_cflag_src_f2;
  reg    [`CA53_FP_CFLAG_SRC_W-1:0] fp1_cflag_src_f2;
  reg    [`CA53_FP_XFLAG_SRC_W-1:0] fp0_xflag_src_f2;
  reg    [`CA53_FP_XFLAG_SRC_W-1:0] fp1_xflag_src_f2;
  reg    [`CA53_FP_CFLAG_SRC_W-1:0] raw_fp0_cflag_src_f3;
  reg    [`CA53_FP_CFLAG_SRC_W-1:0] raw_fp1_cflag_src_f3;
  reg    [`CA53_FP_XFLAG_SRC_W-1:0] raw_fp0_xflag_src_f3;
  reg    [`CA53_FP_XFLAG_SRC_W-1:0] raw_fp1_xflag_src_f3;
  reg    [`CA53_FP_CFLAG_SRC_W-1:0] raw_fp0_cflag_src_f4;
  reg    [`CA53_FP_CFLAG_SRC_W-1:0] raw_fp1_cflag_src_f4;
  reg    [`CA53_FP_XFLAG_SRC_W-1:0] raw_fp0_xflag_src_f4;
  reg    [`CA53_FP_XFLAG_SRC_W-1:0] raw_fp1_xflag_src_f4;
  reg    [`CA53_FP_CFLAG_SRC_W-1:0] fp0_cflag_src_f5;
  reg    [`CA53_FP_CFLAG_SRC_W-1:0] fp1_cflag_src_f5;
  reg    [`CA53_FP_XFLAG_SRC_W-1:0] fp0_xflag_src_f5;
  reg    [`CA53_FP_XFLAG_SRC_W-1:0] fp1_xflag_src_f5;
  reg                         [3:0] fp_cflags_add0_f3;
  reg                         [3:0] fp_cflags_add1_f3;
  reg                         [3:0] fp_cflags_add0_f4;
  reg                         [3:0] fp_cflags_add1_f4;
  reg                         [3:0] fp_cflags_add0_f5;
  reg                         [3:0] fp_cflags_add1_f5;
  reg                         [1:0] instr_fmstat_iss;
  reg                         [1:0] instr_fmstat_ex1;
  reg                         [1:0] instr_fmstat_ex2;
  reg                         [1:0] str0_sel_fp_f1_reg;
  reg                         [1:0] str0_sel_fp_f2_reg;
  reg                         [1:0] str1_sel_fp_f1_reg;
  reg                         [1:0] str1_sel_fp_f2_reg;
  reg             [`CA53_FWD_W-1:0] str0_a_fwd_fp_ex2_int;
  reg             [`CA53_FWD_W-1:0] str0_b_fwd_fp_ex2_int;
  reg             [`CA53_FWD_W-1:0] str1_a_fwd_fp_ex2_int;
  reg             [`CA53_FWD_W-1:0] str1_b_fwd_fp_ex2_int;
  reg                               stall_neon_rs;
  reg                               neon_in_retention;
  reg                               dpu_neon_active;
  reg    [`CA53_NEON_VLD_CTL_W-1:0] neon_vld_ctl_f1;
  reg    [`CA53_NEON_VLD_CTL_W-1:0] neon_vld_ctl_f2;
  reg    [`CA53_NEON_VLD_CTL_W-1:0] neon_vld_ctl_f3;
        
  wire   [`CA53_NEON_VLD_CTL_W-1:0] nxt_neon_vld_ctl_f1;
  wire                              neon_vld_ctl_f2_en;
  wire                              neon_vld_ctl_f3_en;
  wire     [`CA53_FP_EX_PIPE_W-1:0] fp_ex_pipe_iss;
  wire     [`CA53_FP_EX_PIPE_W-1:0] nxt_fp_ex_pipe_f1;
  wire      [`CA53_SEL_FAD_A_W-1:0] nxt_sel_fad0_a_f1;
  wire      [`CA53_SEL_FAD_B_W-1:0] nxt_sel_fad0_b_f1;
  wire      [`CA53_SEL_FAD_C_W-1:0] nxt_sel_fad0_c_f1;
  wire      [`CA53_SEL_FAD_A_W-1:0] nxt_sel_fad1_a_f1;
  wire      [`CA53_SEL_FAD_B_W-1:0] nxt_sel_fad1_b_f1;
  wire      [`CA53_SEL_FAD_C_W-1:0] nxt_sel_fad1_c_f1;
  wire  [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr0_iss;
  wire  [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr1_iss;
  wire  [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr2_iss;
  wire  [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr3_iss;
  wire  [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr4_iss;
  wire  [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr5_iss;
  wire  [`CA53_FP_RF_RD_ADDR_W-1:0] hold_rf_rd_addr_fr1_iss;
  wire                        [1:0] rf_rd_en_fr0_iss;
  wire                        [1:0] rf_rd_en_fr1_iss;
  wire                        [1:0] rf_rd_en_fr2_iss;
  wire                        [1:0] rf_rd_en_fr3_iss;
  wire                        [1:0] rf_rd_en_fr4_iss;
  wire                        [1:0] rf_rd_en_fr5_iss;
  wire                        [2:0] fr0_fw0_available_iss [1:0];
  wire                        [2:0] fr0_fw1_available_iss [1:0];
  wire                        [2:0] fr1_fw0_available_iss [1:0];
  wire                        [2:0] fr1_fw1_available_iss [1:0];
  wire                        [2:0] fr2_fw0_available_iss [1:0];
  wire                        [2:0] fr2_fw1_available_iss [1:0];
  wire                        [2:0] fr3_fw0_available_iss [1:0];
  wire                        [2:0] fr3_fw1_available_iss [1:0];
  wire                        [2:0] fr4_fw0_available_iss [1:0];
  wire                        [2:0] fr4_fw1_available_iss [1:0];
  wire                        [2:0] fr5_fw0_available_iss [1:0];
  wire                        [2:0] fr5_fw1_available_iss [1:0];
  wire                        [2:0] fr0_fw0_available_f2 [1:0];
  wire                        [2:0] fr0_fw1_available_f2 [1:0];
  wire                        [2:0] fr1_fw0_available_f2 [1:0];
  wire                        [2:0] fr1_fw1_available_f2 [1:0];
  wire                        [2:0] fr2_fw0_available_f2 [1:0];
  wire                        [2:0] fr2_fw1_available_f2 [1:0];
  wire                        [2:0] fr3_fw0_available_f2 [1:0];
  wire                        [2:0] fr3_fw1_available_f2 [1:0];
  wire                        [2:0] fr4_fw0_available_f2 [1:0];
  wire                        [2:0] fr4_fw1_available_f2 [1:0];
  wire                        [2:0] fr5_fw0_available_f2 [1:0];
  wire                        [2:0] fr5_fw1_available_f2 [1:0];
  wire                        [1:0] fr0_zero_available_iss;
  wire                        [1:0] fr1_zero_available_iss;
  wire                        [1:0] fr2_zero_available_iss;
  wire                        [1:0] fr3_zero_available_iss;
  wire                        [1:0] fr4_zero_available_iss;
  wire                        [1:0] fr5_zero_available_iss;
  wire                        [3:0] rf_wr_en_fw0_f4;
  wire                        [3:0] rf_wr_en_fw1_f4;
  wire                              rf_wr_en_fw_f4;
  wire                       [12:0] nxt_fp1_imm_data_f1;
  wire     [`CA53_FP_EX_PIPE_W-1:0] fp_ex_pipe_f1;
  wire     [`CA53_FP_PIPECTL_W-1:0] nxt_fp0_pipectl_f1;
  wire     [`CA53_FP_PIPECTL_W-1:0] nxt_fp1_pipectl_f1;
  wire                        [1:0] fdivs_valid_iss;
  wire                        [1:0] fdivs_valid_f1;
  wire                        [1:0] fdivs_valid_f2;
  wire     [`CA53_FP_MUL_CTL_W-1:0] fp_mul0_ctl_iss;
  wire     [`CA53_FP_MUL_CTL_W-1:0] fp_mul0_ctl_f1;
  wire     [`CA53_FP_MUL_CTL_W-1:0] fp_mul1_ctl_iss;
  wire     [`CA53_FP_MUL_CTL_W-1:0] fp_mul1_ctl_f1;
  wire                              instr_is_cp10_cp11_iss;
  wire                        [1:0] unflushable_sfmac_iss;
  wire                              unflushable_sfdiv_iss;
  wire                              nxt_unflushable_sfdiv_ex1;
  wire                              nxt_unflushable_ex2;
  wire                              fmac_valid_f3;
  wire  [`CA53_FP_RF_WR_ADDR_W-1:0] pre_rf_wr_addr_fw0_iss;
  wire  [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw0_iss;
  wire  [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw1_iss;
  wire                        [3:0] hold_rf_wr_en_fw_iss;
  wire  [`CA53_FP_RF_WR_ADDR_W-1:0] hold_rf_wr_addr_fw_iss;
  wire     [`CA53_RF_FWR_SRC_W-1:0] nxt_rf_wr_src_fw0_f1;
  wire     [`CA53_RF_FWR_SRC_W-1:0] nxt_rf_wr_src_fw1_f1;
  wire                        [3:0] rf_wr_en_fw0_iss;
  wire                        [3:0] rf_wr_en_fw1_iss;
  wire                              fpscr_interlock_iss;
  wire      [`CA53_SEL_FAD_A_W-1:0] special_sel_fad0_a_iss;
  wire      [`CA53_SEL_FAD_B_W-1:0] special_sel_fad0_b_iss;
  wire      [`CA53_SEL_FAD_A_W-1:0] special_sel_fad1_a_iss;
  wire      [`CA53_SEL_FAD_B_W-1:0] special_sel_fad1_b_iss;
  wire                        [1:0] special_rf_rd_en_fr2_iss;
  wire                        [1:0] special_rf_rd_en_fr5_iss;
  wire  [`CA53_FP_RF_RD_ADDR_W-1:0] special_rf_rd_addr_fr2_iss;
  wire  [`CA53_FP_RF_RD_ADDR_W-1:0] special_rf_rd_addr_fr5_iss;
  wire     [`CA53_RF_FWR_SRC_W-1:0] special_rf_wr_src_fw0_iss;
  wire     [`CA53_RF_FWR_SRC_W-1:0] special_rf_wr_src_fw1_iss;
  wire  [`CA53_FP_RF_WR_ADDR_W-1:0] special_rf_wr_addr_fw0_iss;
  wire  [`CA53_FP_RF_WR_ADDR_W-1:0] special_rf_wr_addr_fw1_iss;
  wire                        [3:0] special_rf_wr_en_fw0_iss;
  wire                        [3:0] special_rf_wr_en_fw1_iss;
  wire                              special_interlock_iss;
  wire     [`CA53_FP_ADD_CTL_W-1:0] special_fp_add0_ctl_iss;
  wire     [`CA53_FP_ADD_CTL_W-1:0] special_fp_add1_ctl_iss;
  wire                              fp_special_in_flight;
  wire                        [3:0] fr0_fw0_addr_match;
  wire                        [3:0] fr0_fw1_addr_match;
  wire                        [3:0] fr1_fw0_addr_match;
  wire                        [3:0] fr1_fw1_addr_match;
  wire                        [3:0] fr2_fw0_addr_match;
  wire                        [3:0] fr2_fw1_addr_match;
  wire                        [3:0] fr3_fw0_addr_match;
  wire                        [3:0] fr3_fw1_addr_match;
  wire                        [3:0] fr4_fw0_addr_match;
  wire                        [3:0] fr4_fw1_addr_match;
  wire                        [3:0] fr5_fw0_addr_match;
  wire                        [3:0] fr5_fw1_addr_match;
  wire                        [3:0] early_fr0_fw0_where_iss;
  wire                        [3:0] early_fr0_fw1_where_iss;
  wire                        [3:0] fr0_fw0_where_iss [1:0];
  wire                        [3:0] fr0_fw1_where_iss [1:0];
  wire                        [3:0] fr0_zero_where_iss;
  wire                        [3:0] early_fr1_fw0_where_iss;
  wire                        [3:0] early_fr1_fw1_where_iss;
  wire                        [3:0] fr1_fw0_where_iss [1:0];
  wire                        [3:0] fr1_fw1_where_iss [1:0];
  wire                        [3:0] fr1_zero_where_iss;
  wire                        [3:0] early_fr2_fw0_where_iss;
  wire                        [3:0] early_fr2_fw1_where_iss;
  wire                        [3:0] fr2_fw0_where_iss [1:0];
  wire                        [3:0] fr2_fw1_where_iss [1:0];
  wire                        [3:0] fr2_zero_where_iss;
  wire                        [3:0] early_fr3_fw0_where_iss;
  wire                        [3:0] early_fr3_fw1_where_iss;
  wire                        [3:0] fr3_fw0_where_iss [1:0];
  wire                        [3:0] fr3_fw1_where_iss [1:0];
  wire                        [3:0] fr3_zero_where_iss;
  wire                        [3:0] early_fr4_fw0_where_iss;
  wire                        [3:0] early_fr4_fw1_where_iss;
  wire                        [3:0] fr4_fw0_where_iss [1:0];
  wire                        [3:0] fr4_fw1_where_iss [1:0];
  wire                        [3:0] fr4_zero_where_iss;
  wire                        [3:0] early_fr5_fw0_where_iss;
  wire                        [3:0] early_fr5_fw1_where_iss;
  wire                        [3:0] fr5_fw0_where_iss [1:0];
  wire                        [3:0] fr5_fw1_where_iss [1:0];
  wire                        [3:0] fr5_zero_where_iss;
  wire                        [2:0] nxt_fr0_fw0_where_f2 [1:0];
  wire                        [2:0] nxt_fr0_fw1_where_f2 [1:0];
  wire                        [2:0] nxt_fr1_fw0_where_f2 [1:0];
  wire                        [2:0] nxt_fr1_fw1_where_f2 [1:0];
  wire                        [2:0] nxt_fr2_fw0_where_f2 [1:0];
  wire                        [2:0] nxt_fr2_fw1_where_f2 [1:0];
  wire                        [2:0] nxt_fr3_fw0_where_f2 [1:0];
  wire                        [2:0] nxt_fr3_fw1_where_f2 [1:0];
  wire                        [2:0] nxt_fr4_fw0_where_f2 [1:0];
  wire                        [2:0] nxt_fr4_fw1_where_f2 [1:0];
  wire                        [2:0] nxt_fr5_fw0_where_f2 [1:0];
  wire                        [2:0] nxt_fr5_fw1_where_f2 [1:0];
  wire                        [3:0] early_rf_wr_en_fw0_f1;
  wire                        [3:0] early_rf_wr_en_fw1_f1;
  wire                        [3:0] early_rf_wr_en_fw0_f2;
  wire                        [3:0] early_rf_wr_en_fw1_f2;
  wire                        [3:0] early_rf_wr_en_fw0_f3;
  wire                        [3:0] early_rf_wr_en_fw1_f3;
  wire                        [3:0] rf_wr_en_fw0_f2;
  wire                        [3:0] rf_wr_en_fw1_f2;
  wire                        [3:0] rf_wr_en_fw0_f3;
  wire                        [3:0] rf_wr_en_fw1_f3;
  wire                              rf_wr_en_fw_f3;
  wire    [`CA53_RF_FWR_WHEN_W-1:0] nxt_rf_wr_when_fw0_f1;
  wire    [`CA53_RF_FWR_WHEN_W-1:0] nxt_rf_wr_when_fw1_f1;
  wire                        [1:0] nxt_fdivs_valid_f3;
  wire                        [1:0] fr0_when_iss;
  wire                        [1:0] fr1_when_iss;
  wire                        [1:0] fr2_when_iss;
  wire                        [1:0] fr3_when_iss;
  wire                        [1:0] fr4_when_iss;
  wire                        [1:0] fr5_when_iss;
  wire                              wfx_serialize_iss;
  wire                        [1:0] neon_mul_can_fwd;
  wire   [`CA53_FP_CFLAG_SRC_W-1:0] nxt_fp0_cflag_src_f1;
  wire   [`CA53_FP_CFLAG_SRC_W-1:0] nxt_fp1_cflag_src_f1;
  wire   [`CA53_FP_XFLAG_SRC_W-1:0] nxt_fp0_xflag_src_f1;
  wire   [`CA53_FP_XFLAG_SRC_W-1:0] nxt_fp1_xflag_src_f1;
  wire   [`CA53_FP_XFLAG_SRC_W-1:0] nxt_fp0_xflag_src_f3;
  wire   [`CA53_FP_XFLAG_SRC_W-1:0] nxt_fp1_xflag_src_f3;
  wire   [`CA53_FP_CFLAG_SRC_W-1:0] fp0_cflag_src_f3;
  wire   [`CA53_FP_CFLAG_SRC_W-1:0] fp1_cflag_src_f3;
  wire   [`CA53_FP_XFLAG_SRC_W-1:0] fp0_xflag_src_f3;
  wire   [`CA53_FP_XFLAG_SRC_W-1:0] fp1_xflag_src_f3;
  wire   [`CA53_FP_CFLAG_SRC_W-1:0] fp0_cflag_src_f4;
  wire   [`CA53_FP_CFLAG_SRC_W-1:0] fp1_cflag_src_f4;
  wire   [`CA53_FP_XFLAG_SRC_W-1:0] fp0_xflag_src_f4;
  wire   [`CA53_FP_XFLAG_SRC_W-1:0] fp1_xflag_src_f4;
  wire                        [1:0] nxt_str0_sel_fp_f1;
  wire                        [1:0] nxt_str1_sel_fp_f1;
  wire                              no_insert_iss_en;
  wire                              en_f1;
  wire                              en_f2;
  wire                              en_rf_wr_en_f5;
  wire                              fp_rp_active;
  wire                              fp_imm_data_active;
  wire                              fp_ld_data_active;
  wire                              nxt_neon_in_retention;
  wire                              nxt_dpu_neon_active;
  wire                              clk_fp_ctl;
  wire                              fp_ctl_en;

  // ------------------------------------------------------
  // Regional clock gates
  // ------------------------------------------------------

  assign fp_ctl_en = dpu_neon_active | iq_instr_is_fn_i[0] | iq_instr_is_fn_i[1];

  ca53_cell_inter_clkgate u_inter_clkgate_fp_ctl (
    .clk_i         (clk),
    .clk_enable_i  (fp_ctl_en),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_fp_ctl));

  // ------------------------------------------------------
  // Control
  // ------------------------------------------------------

  assign no_insert_iss_en = ~stall_iss;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      no_insert_iss <= 1'b1;
    else if (no_insert_iss_en)
      no_insert_iss <= no_insert_de_i;

  // Create FPU specific pipeline enable signals
  // These only enable the pipeline if there is a cp10/cp11 instruction
  // in the pipeline or if there is a special in the pipeline.
  assign instr_is_cp10_cp11_iss = pre_instr_is_cp10_cp11_iss | (|special_insert_iss);

  assign issue_to_iss_fpu = issue_to_iss & instr_is_cp10_cp11_de_i;
  assign issue_to_ex1_fpu = ((valid_instrs_iss[0] & instr_is_cp10_cp11_iss) |
                             (|special_insert_iss)) & advance_pipeline;
  assign issue_to_ex2_fpu = ((valid_instrs_ex1[0] & instr_is_cp10_cp11_ex1) |
                             (|unflushable_sfmac_ex1)) & advance_pipeline;
  assign issue_to_wr_fpu  = ((valid_instrs_ex2[0] & instr_is_cp10_cp11_ex2) |
                             (|unflushable_sfmac_ex2)) & advance_pipeline;

  // ------------------------------------------------------
  // FPU issue stage pipeline registers
  // ------------------------------------------------------

  assign fp_ex_pipe_iss = (raw_fp_ex_pipe_iss & {`CA53_FP_EX_PIPE_W{~neon_in_retention}}) | {2'b00, unflushable_sfmac_iss};

  assign fp_mul0_ctl_iss = fp0_pipectl_iss_i[`CA53_FP_PIPECTL_MUL_CTL_BITS];
  assign fp_mul0_ctl_f1  = fp0_pipectl_f1   [`CA53_FP_PIPECTL_MUL_CTL_BITS];

  assign fp_mul1_ctl_iss = fp1_pipectl_iss_i[`CA53_FP_PIPECTL_MUL_CTL_BITS];
  assign fp_mul1_ctl_f1  = fp1_pipectl_f1   [`CA53_FP_PIPECTL_MUL_CTL_BITS];

  // The divide control signals should not be advanced to Ex1 when Iss is stalled.
  assign fdivs_valid_iss[0] = raw_fp_ex_pipe_iss[`CA53_FP_EX_PIPE_MUL0] & raw_fdiv_valid_iss[0]                     & valid_instrs_iss[0];
  assign fdivs_valid_f1[0]  =     fp_ex_pipe_f1 [`CA53_FP_EX_PIPE_MUL0] & fp_mul0_ctl_f1 [`CA53_FP_MUL_DIVIDE_BITS] & valid_instrs_ex1[0];
  assign fdivs_valid_f2[0]  = fdivs_pre_valid_f2[0]                                                                 & valid_instrs_ex2[0];

  assign fdivs_valid_iss[1] = raw_fp_ex_pipe_iss[`CA53_FP_EX_PIPE_MUL1] & raw_fdiv_valid_iss[1]                     & valid_instrs_iss[0];
  assign fdivs_valid_f1[1]  =     fp_ex_pipe_f1 [`CA53_FP_EX_PIPE_MUL1] & fp_mul1_ctl_f1 [`CA53_FP_MUL_DIVIDE_BITS] & valid_instrs_ex1[0];
  assign fdivs_valid_f2[1]  = fdivs_pre_valid_f2[1]                                                                 & valid_instrs_ex2[0];

  always @(posedge clk_fp_ctl or negedge reset_n)
    if (~reset_n) begin
      raw_rf_rd_addr_fr0_iss  <= {`CA53_FP_RF_RD_ADDR_W{1'b0}};
      raw_rf_rd_addr_fr1_iss  <= {`CA53_FP_RF_RD_ADDR_W{1'b0}};
      raw_rf_rd_addr_fr2_iss  <= {`CA53_FP_RF_RD_ADDR_W{1'b0}};
      raw_rf_rd_addr_fr3_iss  <= {`CA53_FP_RF_RD_ADDR_W{1'b0}};
      raw_rf_rd_addr_fr4_iss  <= {`CA53_FP_RF_RD_ADDR_W{1'b0}};
      raw_rf_rd_addr_fr5_iss  <= {`CA53_FP_RF_RD_ADDR_W{1'b0}};
      rf_rd_need_fr0_iss      <= {`CA53_RF_FRD_NEED_W{1'b0}};
      rf_rd_need_fr1_iss      <= {`CA53_RF_FRD_NEED_W{1'b0}};
      rf_rd_need_fr2_iss      <= {`CA53_RF_FRD_NEED_W{1'b0}};
      rf_rd_need_fr3_iss      <= {`CA53_RF_FRD_NEED_W{1'b0}};
      rf_rd_need_fr4_iss      <= {`CA53_RF_FRD_NEED_W{1'b0}};
      rf_rd_need_fr5_iss      <= {`CA53_RF_FRD_NEED_W{1'b0}};
      raw_rf_wr_addr_fw0_iss  <= {`CA53_FP_RF_WR_ADDR_W{1'b0}};
      raw_rf_wr_addr_fw1_iss  <= {`CA53_FP_RF_WR_ADDR_W{1'b0}};
      rf_wr_src_fw0_iss       <= `CA53_RF_FWR_SRC_FAD_Q;
      rf_wr_src_fw1_iss       <= `CA53_RF_FWR_SRC_FAD_Q;
      rf_wr_when_fw0_iss      <= {`CA53_RF_FWR_WHEN_W{1'b0}};
      rf_wr_when_fw1_iss      <= {`CA53_RF_FWR_WHEN_W{1'b0}};
    end else if (issue_to_iss_fpu) begin
      raw_rf_rd_addr_fr0_iss  <= rf_rd_addr_fr0_de_i[(`CA53_FP_RF_RD_ADDR_W-1):0];
      raw_rf_rd_addr_fr1_iss  <= rf_rd_addr_fr1_de_i[(`CA53_FP_RF_RD_ADDR_W-1):0];
      raw_rf_rd_addr_fr2_iss  <= rf_rd_addr_fr2_de_i[(`CA53_FP_RF_RD_ADDR_W-1):0];
      raw_rf_rd_addr_fr3_iss  <= rf_rd_addr_fr3_de_i[(`CA53_FP_RF_RD_ADDR_W-1):0];
      raw_rf_rd_addr_fr4_iss  <= rf_rd_addr_fr4_de_i[(`CA53_FP_RF_RD_ADDR_W-1):0];
      raw_rf_rd_addr_fr5_iss  <= rf_rd_addr_fr5_de_i[(`CA53_FP_RF_RD_ADDR_W-1):0];
      rf_rd_need_fr0_iss      <= rf_rd_need_fr0_de_i;
      rf_rd_need_fr1_iss      <= rf_rd_need_fr1_de_i;
      rf_rd_need_fr2_iss      <= rf_rd_need_fr2_de_i;
      rf_rd_need_fr3_iss      <= rf_rd_need_fr3_de_i;
      rf_rd_need_fr4_iss      <= rf_rd_need_fr4_de_i;
      rf_rd_need_fr5_iss      <= rf_rd_need_fr5_de_i;
      raw_rf_wr_addr_fw0_iss  <= rf_wr_addr_fw0_de_i[(`CA53_FP_RF_WR_ADDR_W-1):0];
      raw_rf_wr_addr_fw1_iss  <= rf_wr_addr_fw1_de_i[(`CA53_FP_RF_WR_ADDR_W-1):0];
      rf_wr_src_fw0_iss       <= rf_wr_src_fw0_de_i;
      rf_wr_src_fw1_iss       <= rf_wr_src_fw1_de_i;
      rf_wr_when_fw0_iss      <= rf_wr_when_fw0_de_i[`CA53_RF_FWR_WHEN_W-1:0];
      rf_wr_when_fw1_iss      <= rf_wr_when_fw1_de_i[`CA53_RF_FWR_WHEN_W-1:0];
    end

  // Use the conventional issue_to_iss enable for signals that must be clocked when
  // the integer pipeline moves.  This could be signals that control the integer
  // datapath or it could be control signals for forwarding (as otherwise a flush
  // can leave these signals set and forwarding data incorrectly).  This also requires
  // the use of the main clock rather than the regionally gated version.
  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      raw_rf_rd_en_fr0_iss       <= 2'b00;
      raw_rf_rd_en_fr1_iss       <= 2'b00;
      raw_rf_rd_en_fr2_iss       <= 2'b00;
      raw_rf_rd_en_fr3_iss       <= 2'b00;
      raw_rf_rd_en_fr4_iss       <= 2'b00;
      raw_rf_rd_en_fr5_iss       <= 2'b00;
      raw_rf_wr_en_fw0_iss       <= 4'b0000;
      raw_rf_wr_en_fw1_iss       <= 4'b0000;
      fmac_valid_sp_iss          <= 2'b00;
      raw_fdiv_valid_iss         <= 2'b00;
      neon_can_fwd_acc_iss       <= 2'b00;
      neon_vld_ctl_iss           <= {`CA53_NEON_VLD_CTL_W{1'b0}};
      raw_fp_ex_pipe_iss         <= {`CA53_FP_EX_PIPE_W{1'b0}};
      instr_fmstat_iss           <= 2'b00;
      pre_instr_is_cp10_cp11_iss <= 1'b0;
    end else if (issue_to_iss) begin
      raw_rf_rd_en_fr0_iss       <= rf_rd_en_fr0_de_i;
      raw_rf_rd_en_fr1_iss       <= rf_rd_en_fr1_de_i;
      raw_rf_rd_en_fr2_iss       <= rf_rd_en_fr2_de_i;
      raw_rf_rd_en_fr3_iss       <= rf_rd_en_fr3_de_i;
      raw_rf_rd_en_fr4_iss       <= rf_rd_en_fr4_de_i;
      raw_rf_rd_en_fr5_iss       <= rf_rd_en_fr5_de_i;
      raw_rf_wr_en_fw0_iss       <= rf_wr_en_fw0_de_i;
      raw_rf_wr_en_fw1_iss       <= rf_wr_en_fw1_de_i;
      fmac_valid_sp_iss          <= fmac_valid_sp_de_i;
      raw_fdiv_valid_iss         <= fdiv_valid_de_i;
      neon_can_fwd_acc_iss       <= neon_can_fwd_acc_de_i;
      neon_vld_ctl_iss           <= neon_vld_ctl_de_i;
      raw_fp_ex_pipe_iss         <= fp_ex_pipe_de_i;
      instr_fmstat_iss           <= instr_fmstat_de_i;
      pre_instr_is_cp10_cp11_iss <= instr_is_cp10_cp11_de_i;
    end

  // Skidding register
  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      held_rf_rd_addr_fr1_iss <= {`CA53_FP_RF_RD_ADDR_W{1'b0}};
      held_rf_rd_en_fr0_iss   <= {2{1'b0}};
      held_rf_rd_en_fr1_iss   <= {2{1'b0}};
      held_rf_wr_addr_fw_iss  <= {`CA53_FP_RF_WR_ADDR_W{1'b0}};
      held_rf_wr_en_fw_iss    <= {4{1'b0}};
    end else if (en_lsm_skidding) begin
      held_rf_rd_addr_fr1_iss <= hold_rf_rd_addr_fr1_iss;
      held_rf_rd_en_fr0_iss   <= raw_rf_rd_en_fr1_iss;
      held_rf_rd_en_fr1_iss   <= raw_rf_rd_en_fr0_iss;
      held_rf_wr_addr_fw_iss  <= hold_rf_wr_addr_fw_iss;
      held_rf_wr_en_fw_iss    <= hold_rf_wr_en_fw_iss;
    end

  // ------------------------------------------------------
  // Neon retention control logic
  // ------------------------------------------------------

  // Determine when the FP read ports will be used, to ensure that clk_fp
  // is enabled
  assign fp_rp_active = (instr_is_cp10_cp11_de_i    & valid_instrs_de_i[0] & ~nxt_neon_in_retention)  | // Neon instruction in De and not currently in retention
                        (pre_instr_is_cp10_cp11_iss & valid_instrs_iss[0]  & ~nxt_neon_in_retention &   // Stalled Neon instruction in Iss (including stalls due
                         stall_slot0_iss)                                                             | // to retention), and not in retention next cycle
                        (fmac_valid_f3 & valid_instrs_wr[0]);                                           // FMAC in pipeline which will insert a special next cycle

  // An FMOV (immediate) instruction requires the F1->F2 and F2->F3 stages to
  // be clocked to pass immediate data. Neon immediate shifts only require the
  // clock to be active for F1->F2
  assign fp_imm_data_active = pre_instr_is_cp10_cp11_iss & valid_instrs_iss[0] & ~nxt_neon_in_retention &
                              ((rf_wr_src_fw0_iss == `CA53_RF_FWR_SRC_FAD_Q)  |
                               (rf_wr_src_fw1_iss == `CA53_RF_FWR_SRC_FAD_Q)  |
                               (rf_wr_src_fw0_iss == `CA53_RF_FWR_SRC_FAD_NARROW));

  // An instruction using the FP load pipeline from F3 needs clk_fp to be active
  assign fp_ld_data_active = valid_instrs_ex2[0] & instr_is_cp10_cp11_ex2 &
                             ((rf_wr_src_fw0_f2 == `CA53_RF_FWR_SRC_DCU_PERM)   |
                              (rf_wr_src_fw0_f2 == `CA53_RF_FWR_SRC_DCU_SGL)    |
                              (rf_wr_src_fw0_f2 == `CA53_RF_FWR_SRC_DCU_SGL2)   |
                              (rf_wr_src_fw0_f2 == `CA53_RF_FWR_SRC_DCU_DUP)    |
                              (rf_wr_src_fw0_f2 == `CA53_RF_FWR_SRC_DCU_DUP2)   |
                              (rf_wr_src_fw0_f2 == `CA53_RF_FWR_SRC_STR)        |
                              (rf_wr_src_fw0_f2 == `CA53_RF_FWR_SRC_STR_SP)     |
                              (rf_wr_src_fw0_f2 == `CA53_RF_FWR_SRC_STR_2SP)    |
                              (rf_wr_src_fw0_f2 == `CA53_RF_FWR_SRC_DCU_DBL)    |
                              (rf_wr_src_fw0_f2 == `CA53_RF_FWR_SRC_CRYPTO_F3)  |
                              (rf_wr_src_fw1_f2 == `CA53_RF_FWR_SRC_DCU_PERM)   |
                              (rf_wr_src_fw1_f2 == `CA53_RF_FWR_SRC_DCU_SGL)    |
                              (rf_wr_src_fw1_f2 == `CA53_RF_FWR_SRC_DCU_SGL2)   |
                              (rf_wr_src_fw1_f2 == `CA53_RF_FWR_SRC_DCU_DUP)    |
                              (rf_wr_src_fw1_f2 == `CA53_RF_FWR_SRC_DCU_DUP2)   |
                              (rf_wr_src_fw1_f2 == `CA53_RF_FWR_SRC_STR)        |
                              (rf_wr_src_fw1_f2 == `CA53_RF_FWR_SRC_STR_SP)     |
                              (rf_wr_src_fw1_f2 == `CA53_RF_FWR_SRC_STR_2SP)    |
                              (rf_wr_src_fw1_f2 == `CA53_RF_FWR_SRC_DCU_DBL));

  assign nxt_dpu_neon_active = (neon_de_active_i              | // Decode stage active
                                instr_is_cp10_cp11_iss        | // Issue stage active
                                instr_is_cp10_cp11_ex1        | // F1 stage active
                                instr_is_cp10_cp11_ex2        | // F2 stage active
                                instr_is_cp10_cp11_wr         | // F3 stage active
                                instr_is_cp10_cp11_f4         | // F4 stage active
                                instr_is_cp10_cp11_f5         | // F5 stage active
                                fp_special_in_flight          | // Special in flight
                                (dpu_neon_active & flush_ret) | // Pipeline flush while active (ensures FP Ctl clock remains long enough to clear enables)
                                (dpu_neon_active & stall_wr));  // Pipeline stall while active (ensures active remains while a load is stalled)

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      stall_neon_rs     <= 1'b0;
      neon_in_retention <= 1'b0;
      dpu_neon_active   <= 1'b1;
    end else begin
      stall_neon_rs     <= gov_stall_neon_i;
      neon_in_retention <= nxt_neon_in_retention;
      dpu_neon_active   <= nxt_dpu_neon_active;
    end

  assign nxt_neon_in_retention = stall_neon_rs & (neon_in_retention | ~nxt_dpu_neon_active);

  // Stall if a Neon/FP instruction is present and the governor has handshaked
  // Neon retention entry
  assign neon_ret_stall_iss = neon_in_retention & pre_instr_is_cp10_cp11_iss & valid_instrs_iss[0];

  // ------------------------------------------------------
  // Skidding and special control logic
  // ------------------------------------------------------

  // Read and Write data skidding for FPU and Neon is more complicated than for integer code,
  // largely because of the requirement to be able to endian align 64-bit and 32-bit data
  // elements that are skidding.
  //
  // The following is an example decode read address and read enable table for a double precision
  // VSTM to D4-D6 where:
  // - The "Decoder" column indicates the registers that are spun out on the FR0 and FR1 ports
  // - The "LE"/"BE" columns are for Little-Endian/Big-Endian VSTMs
  // - The "Skid" columns are for when the address of the first access was 32-bit, not 64-bit aligned
  // - The "*" indicates the register that has been held from the previous cycle
  // - The "H"/"L" suffix on the register identifier indicates whether the register is read on the
  //   high or low portion of the 64-bit read port
  //
  //       |  Decoder   | LE No-Skid |   LE Skid  | BE No-Skid |   BE Skid  |
  // Cycle | FR1    FR0 | FR1    FR0 | FR1    FR0 | FR1    FR0 | FR1    FR0 |
  //   0   | D04H  D04L | D04H  D04L | ----  D04L | D04H  D04L | D04H  ---- |
  //   1   | D05H  D05L | D05H  D05L | D05L *D04H | D05H  D05L | D04L* D05H |
  //   2   | D06H  D06L | D06H  D06L | D06L *D05H | D06H  D06L | D05L* D06H |
  //   3   | ---    --- | ---    --- | ---  *D06H | ---    --- | D06L* ---- |

  // FPU/Neon RF read addresses including skidding
  assign rf_rd_addr_fr0_iss = (lsm_n64b_be_skidding_i ?    held_rf_rd_addr_fr1_iss : (raw_rf_rd_addr_fr0_iss ^ {5'b00000, ls_128b_be_i & ~slot1_ls_iss}));
  assign rf_rd_addr_fr1_iss = (lsm_n64b_be_skidding_i ?     raw_rf_rd_addr_fr0_iss :
                               lsm_64b_be_skidding_i  ?    held_rf_rd_addr_fr1_iss : (raw_rf_rd_addr_fr1_iss ^ {5'b00000, ls_128b_be_i & ~slot1_ls_iss}));
  assign rf_rd_addr_fr2_iss = special_insert_iss[0]   ? special_rf_rd_addr_fr2_iss :  raw_rf_rd_addr_fr2_iss;
  assign rf_rd_addr_fr3_iss =                                                        (raw_rf_rd_addr_fr3_iss ^ {5'b00000, ls_128b_be_i &  slot1_ls_iss});
  assign rf_rd_addr_fr4_iss =                                                        (raw_rf_rd_addr_fr4_iss ^ {5'b00000, ls_128b_be_i &  slot1_ls_iss});
  assign rf_rd_addr_fr5_iss = special_insert_iss[1]   ? special_rf_rd_addr_fr5_iss :  raw_rf_rd_addr_fr5_iss;

  assign hold_rf_rd_addr_fr1_iss = lsm_64b_be_i ? raw_rf_rd_addr_fr0_iss : raw_rf_rd_addr_fr1_iss;

  // FPU/Neon RF read enables including skidding
  assign rf_rd_en_fr0_iss = lsm_n64b_be_skidding_i  ? held_rf_rd_en_fr0_iss :
                            lsm_64b_be_skidding_i   ?  raw_rf_rd_en_fr1_iss :
                                                       raw_rf_rd_en_fr0_iss;

  assign rf_rd_en_fr1_iss = lsm_n64b_be_skidding_i  ?  raw_rf_rd_en_fr0_iss :
                            lsm_64b_be_skidding_i   ? held_rf_rd_en_fr1_iss :
                                                       raw_rf_rd_en_fr1_iss;

  assign rf_rd_en_fr2_iss = special_insert_iss[0]   ? special_rf_rd_en_fr2_iss :
                            fmac_valid_sp_iss[0]    ? 2'b00                    :
                                                      raw_rf_rd_en_fr2_iss;

  assign rf_rd_en_fr3_iss =                           raw_rf_rd_en_fr3_iss;
  assign rf_rd_en_fr4_iss =                           raw_rf_rd_en_fr4_iss;

  assign rf_rd_en_fr5_iss = special_insert_iss[1]   ? special_rf_rd_en_fr5_iss :
                            fmac_valid_sp_iss[1]    ? 2'b00                    :
                                                      raw_rf_rd_en_fr5_iss;

  // The following is an example decode write address and write enable table for a double precision
  // VLDM to D4-D6 (registers S8-S9, S10-S11 and S12-S13) where:
  // - The "Decoder" column indicates the registers that are spun out on the W0 and W1 ports
  // - The "LE"/"BE" columns are for Little-Endian/Big-Endian VLDMs
  // - The "Skid" columns are for when the address of the first access was 32-bit, not 64-bit aligned
  // - The "*" indicates the register that has been held from the previous cycle
  //
  //       |  Decoder   | LE No-Skid |  LE Skid   | BE No-Skid |  BE Skid   |
  // Cycle | FW1    FW0 | FW1    FW0 | FW1    FW0 | FW1    FW0 | FW1    FW0 |
  //   0   | S09    S08 | S09    S08 | ---    S08 | S09    S08 | S09    --- |
  //   1   | S11    S10 | S11    S10 | S10   *S09 | S11    S10 | S08*   S11 |
  //   2   | S13    S12 | S13    S12 | S12   *S11 | S13    S12 | S10*   S13 |
  //   3   | ---    --- | ---    --- | ---   *S13 | ---    --- | S12*   --- |

  // For big-endian 128-bit loads, must flip the bottom register address bit
  assign pre_rf_wr_addr_fw0_iss = raw_rf_wr_addr_fw0_iss ^ {5'b00000, (ls_128b_be_i & ~slot1_ls_iss)};

  // FPU/Neon RF write addresses including skidding
  assign rf_wr_addr_fw0_iss = special_insert_iss[0]           ? special_rf_wr_addr_fw0_iss     :
                              lsm_n64b_be_skidding_i          ?    held_rf_wr_addr_fw_iss      :
                              lsm_64b_be_skidding_i           ?     raw_rf_wr_addr_fw1_iss     :
                                                                    pre_rf_wr_addr_fw0_iss;

  assign rf_wr_addr_fw1_iss = special_insert_iss[1]           ? special_rf_wr_addr_fw1_iss :
                              lsm_n64b_be_skidding_i          ?     raw_rf_wr_addr_fw0_iss :
                              lsm_64b_be_skidding_i           ?    held_rf_wr_addr_fw_iss  :
                                                                    raw_rf_wr_addr_fw1_iss;

  assign hold_rf_wr_addr_fw_iss = lsm_64b_be_i ? raw_rf_wr_addr_fw0_iss : raw_rf_wr_addr_fw1_iss;

  // FPU/Neon RF write enables including skidding
  // Use (lsm_skidding_i & lsm_64b_be_i) instead of lsm_64b_be_skidding_i
  // to reduce loading and improve timing
  assign rf_wr_en_fw0_iss = special_insert_iss[0]                                 ? special_rf_wr_en_fw0_iss :
                            special_stall_iss                                     ? 4'b0000                  :
                            ilock_stall_iss                                       ? 4'b0000                  :
                            (lsm_skidding_i & ~lsm_64b_be_i)                      ? held_rf_wr_en_fw_iss     :
                            extra_lsm_cycle_i                                     ? 4'b0000                  :
                            (first_lsm_skidding_i &  lsm_64b_be_i)                ? 4'b0000                  :
                            (first_x64_iss_i  & ~slot1_ls_iss)                    ? 4'b0000                  :
                            (second_x64_iss_i &  slot1_ls_iss)                    ? 4'b0000                  :
                            (fdivs_valid_iss[0] | fmac_valid_sp_iss[0])           ? 4'b0000                  :
                            (lsm_skidding_i &  lsm_64b_be_i)                      ? raw_rf_wr_en_fw1_iss     :
                                                                                    raw_rf_wr_en_fw0_iss;

  assign rf_wr_en_fw1_iss = special_insert_iss[1]                                 ? special_rf_wr_en_fw1_iss :
                            special_stall_iss                                     ? 4'b0000                  :
                            ilock_stall_iss                                       ? 4'b0000                  :
                            (lsm_skidding_i &  lsm_64b_be_i)                      ? held_rf_wr_en_fw_iss     :
                            extra_lsm_cycle_i                                     ? 4'b0000                  :
                            (first_lsm_skidding_i & ~lsm_64b_be_i)                ? 4'b0000                  :
                            (first_x64_iss_i  & (~slot1_ls_iss |  slot1_fp_iss))  ? 4'b0000                  :
                            (second_x64_iss_i &   slot1_ls_iss & ~slot1_fp_iss )  ? 4'b0000                  :
                            (fdivs_valid_iss[1] | fmac_valid_sp_iss[1])           ? 4'b0000                  :
                            (lsm_skidding_i & ~lsm_64b_be_i)                      ? raw_rf_wr_en_fw0_iss     :
                                                                                    raw_rf_wr_en_fw1_iss;

  assign hold_rf_wr_en_fw_iss = lsm_64b_be_i ? raw_rf_wr_en_fw0_iss : raw_rf_wr_en_fw1_iss;

  // Integer RF write source including special control
  assign nxt_rf_wr_src_fw0_f1  = special_insert_iss[0] ? special_rf_wr_src_fw0_iss  : rf_wr_src_fw0_iss;
  assign nxt_rf_wr_when_fw0_f1 = special_insert_iss[0] ? `CA53_RF_FWR_WHEN_F5       : rf_wr_when_fw0_iss;

  assign nxt_rf_wr_src_fw1_f1  = special_insert_iss[1] ? special_rf_wr_src_fw1_iss  : rf_wr_src_fw1_iss;
  assign nxt_rf_wr_when_fw1_f1 = special_insert_iss[1] ? `CA53_RF_FWR_WHEN_F5       : rf_wr_when_fw1_iss;

  // Modify the fad select signals for FMACs
  // Note that we need the adder read port (rather than reusing a forwarding path) for the multiply output of
  // FMACs because we only have three read ports on the register file and need one of them for the accumulator
  // and two to issue another FMAC phantom to the multiply block underneath the FMAC special.
  assign nxt_sel_fad0_a_f1 = special_insert_iss[0] ? special_sel_fad0_a_iss : sel_fad0_a_iss_i;
  assign nxt_sel_fad0_b_f1 = special_insert_iss[0] ? special_sel_fad0_b_iss : sel_fad0_b_iss_i;
  assign nxt_sel_fad0_c_f1 = special_insert_iss[0] ? `CA53_SEL_FAD_C_ZERO   : sel_fad0_c_iss_i;

  assign nxt_sel_fad1_a_f1 = special_insert_iss[1] ? special_sel_fad1_a_iss : sel_fad1_a_iss_i;
  assign nxt_sel_fad1_b_f1 = special_insert_iss[1] ? special_sel_fad1_b_iss : sel_fad1_b_iss_i;
  assign nxt_sel_fad1_c_f1 = special_insert_iss[1] ? `CA53_SEL_FAD_C_ZERO   : sel_fad1_c_iss_i;

  assign nxt_neon_vld_ctl_f1                           = neon_vld_ctl_iss                             &   {`CA53_NEON_VLD_CTL_W{~special_stall_iss}};

  assign nxt_fp0_pipectl_f1[`CA53_FP_PIPECTL_TOP_BITS] = fp0_pipectl_iss_i[`CA53_FP_PIPECTL_TOP_BITS] & {`CA53_FP_PIPECTL_TOP_W{~special_stall_iss}};
  assign nxt_fp1_pipectl_f1[`CA53_FP_PIPECTL_TOP_BITS] = fp1_pipectl_iss_i[`CA53_FP_PIPECTL_TOP_BITS] & {`CA53_FP_PIPECTL_TOP_W{~special_stall_iss}};

  assign nxt_fp0_pipectl_f1[`CA53_FP_PIPECTL_ADD_CTL_BITS] = special_insert_iss[0] ? special_fp_add0_ctl_iss
                                                                                   : fp0_pipectl_iss_i[`CA53_FP_PIPECTL_ADD_CTL_BITS];
  assign nxt_fp1_pipectl_f1[`CA53_FP_PIPECTL_ADD_CTL_BITS] = special_insert_iss[1] ? special_fp_add1_ctl_iss
                                                                                   : fp1_pipectl_iss_i[`CA53_FP_PIPECTL_ADD_CTL_BITS];

  assign nxt_fp_ex_pipe_f1 = raw_fp_ex_pipe_iss & {`CA53_FP_EX_PIPE_W{valid_instrs_iss[0] & ~stall_slot0_iss & ~quash_iss}};

  assign nxt_fp0_cflag_src_f1 = fp0_cflag_src_iss_i & {`CA53_FP_CFLAG_SRC_W{valid_instrs_iss[0] & ~stall_slot0_iss & ~quash_iss}};
  assign nxt_fp1_cflag_src_f1 = fp1_cflag_src_iss_i & {`CA53_FP_CFLAG_SRC_W{valid_instrs_iss[0] & ~stall_slot0_iss & ~quash_iss}};
  assign nxt_fp0_xflag_src_f1 = fp0_xflag_src_iss_i & {`CA53_FP_XFLAG_SRC_W{valid_instrs_iss[0] & ~stall_slot0_iss & ~quash_iss}};
  assign nxt_fp1_xflag_src_f1 = fp1_xflag_src_iss_i & {`CA53_FP_XFLAG_SRC_W{valid_instrs_iss[0] & ~stall_slot0_iss & ~quash_iss}};

  assign nxt_str0_sel_fp_f1 = (str0_data_b_sel_iss == `CA53_SEL_STR_B_FR1) ? `CA53_STR0_FP_SEL_FR0_FR1 :
                              (str0_data_a_sel_iss == `CA53_SEL_STR_A_FR0) ? `CA53_STR0_FP_SEL_FR0     :
                              (str0_data_a_sel_iss == `CA53_SEL_STR_A_FR1) ? `CA53_STR0_FP_SEL_FR4     :
                                                                             `CA53_STR0_FP_SEL_NONE;
  assign nxt_str1_sel_fp_f1 = (str1_data_b_sel_iss == `CA53_SEL_STR_B_FR1) ? `CA53_STR1_FP_SEL_FR3_FR4 :
                              (str1_data_a_sel_iss == `CA53_SEL_STR_A_FR0) ? `CA53_STR1_FP_SEL_FR3     :
                              (str1_data_a_sel_iss == `CA53_SEL_STR_A_FR1) ? `CA53_STR1_FP_SEL_FR1     :
                                                                             `CA53_STR1_FP_SEL_NONE;

  // Prevent a WFE or WFI instruction in Iss moving forwards until all specials have been inserted to prevent
  // the WFX being bisected by a special
  assign wfx_serialize_iss = (instr_type_iss == `CA53_INSTR_TYPE_WFI) |
                             (instr_type_iss == `CA53_INSTR_TYPE_WFE);

  // Early FPU pipeline write enables that do not include valid terms for the interlock/forwarding logic.
  // Also, the F2 stage does not factor in the condition code pass calculation which means that an extra
  // interlock cycle could occur on a dependent FP/NEON instruction that is stalled in Iss.
  assign early_rf_wr_en_fw0_f1 = raw_rf_wr_en_fw0_f1 & {4{    valid_instrs_ex1[0] | unflushable_sfmac_ex1[0]}};
  assign early_rf_wr_en_fw1_f1 = raw_rf_wr_en_fw1_f1 & {4{    valid_instrs_ex1[0] | unflushable_sfmac_ex1[1]}};
  assign early_rf_wr_en_fw0_f2 = raw_rf_wr_en_fw0_f2 & {4{    valid_instrs_ex2[0] | unflushable_sfmac_ex2[0]}};
  assign early_rf_wr_en_fw1_f2 = raw_rf_wr_en_fw1_f2 & {4{    valid_instrs_ex2[0] | unflushable_sfmac_ex2[1]}};
  assign early_rf_wr_en_fw0_f3 = raw_rf_wr_en_fw0_f3 & {4{pre_valid_instrs_wr[0]  | unflushable_sfmac_wr[0]}};
  assign early_rf_wr_en_fw1_f3 = raw_rf_wr_en_fw1_f3 & {4{pre_valid_instrs_wr[0]  | unflushable_sfmac_wr[1]}};

  // ------------------------------------------------------
  // FPU F1 stage pipeline registers
  // ------------------------------------------------------

  assign unflushable_ex1            = unflushable_sfdiv_ex1;
  assign nxt_unflushable_sfdiv_ex1  = unflushable_sfdiv_iss  & advance_pipeline;

  assign fp_ex_pipe_f1 = {raw_fp_ex_pipe_f1 & {4{~flush_wr}}} | {2'b00, unflushable_sfmac_ex1};

  // FP pipe 1 can be used by either slot 0 or slot 1
  assign nxt_fp1_imm_data_f1 = slot1_fp_iss ? raw_imm_data_1_iss_i[12:0] : raw_imm_data_0_iss_i[12:0];

  always @(posedge clk_fp_ctl or negedge reset_n)
    if (~reset_n) begin
      raw_fp_ex_pipe_f1       <= {`CA53_FP_EX_PIPE_W{1'b0}};
      unflushable_sfdiv_ex1   <= 1'b0;
    end else if (en_btm_pc_ex1) begin
      raw_fp_ex_pipe_f1       <= nxt_fp_ex_pipe_f1;
      unflushable_sfdiv_ex1   <= nxt_unflushable_sfdiv_ex1;
    end

  always @(posedge clk_fp_ctl or negedge reset_n)
    if (~reset_n) begin
      rf_wr_addr_fw0_f1   <= {`CA53_FP_RF_WR_ADDR_W{1'b0}};
      rf_wr_addr_fw1_f1   <= {`CA53_FP_RF_WR_ADDR_W{1'b0}};
      rf_wr_src_fw0_f1    <= {`CA53_RF_FWR_SRC_W{1'b0}};
      rf_wr_src_fw1_f1    <= {`CA53_RF_FWR_SRC_W{1'b0}};
      rf_wr_when_fw0_f1   <= {`CA53_RF_FWR_WHEN_W{1'b0}};
      rf_wr_when_fw1_f1   <= {`CA53_RF_FWR_WHEN_W{1'b0}};
      fp0_imm_data_f1     <= {13{1'b0}};
      fp1_imm_data_f1     <= {13{1'b0}};
      fp0_pipectl_f1      <= {`CA53_FP_PIPECTL_W{1'b0}};
      fp1_pipectl_f1      <= {`CA53_FP_PIPECTL_W{1'b0}};
      neon_vld_ctl_f1     <= {`CA53_NEON_VLD_CTL_W{1'b0}};
      sel_fad0_a_f1       <= {`CA53_SEL_FAD_A_W{1'b0}};
      sel_fad0_b_f1       <= {`CA53_SEL_FAD_B_W{1'b0}};
      sel_fad0_c_f1       <= {`CA53_SEL_FAD_C_W{1'b0}};
      sel_fad1_a_f1       <= {`CA53_SEL_FAD_A_W{1'b0}};
      sel_fad1_b_f1       <= {`CA53_SEL_FAD_B_W{1'b0}};
      sel_fad1_c_f1       <= {`CA53_SEL_FAD_C_W{1'b0}};
      sel_fml0_a_f1       <= 1'b0;
      sel_fml0_b_f1       <= {`CA53_SEL_FML_B_W{1'b0}};
      sel_fml0_c_f1       <= 1'b0;
      sel_fml1_a_f1       <= 1'b0;
      sel_fml1_b_f1       <= {`CA53_SEL_FML_B_W{1'b0}};
      sel_fml1_c_f1       <= 1'b0;
    end else if (issue_to_ex1_fpu) begin
      rf_wr_addr_fw0_f1   <= rf_wr_addr_fw0_iss[(`CA53_FP_RF_WR_ADDR_W-1):0];
      rf_wr_addr_fw1_f1   <= rf_wr_addr_fw1_iss[(`CA53_FP_RF_WR_ADDR_W-1):0];
      rf_wr_src_fw0_f1    <= nxt_rf_wr_src_fw0_f1;
      rf_wr_src_fw1_f1    <= nxt_rf_wr_src_fw1_f1;
      rf_wr_when_fw0_f1   <= nxt_rf_wr_when_fw0_f1;
      rf_wr_when_fw1_f1   <= nxt_rf_wr_when_fw1_f1;
      fp0_imm_data_f1     <= raw_imm_data_0_iss_i[12:0];
      fp1_imm_data_f1     <= nxt_fp1_imm_data_f1[12:0];
      fp0_pipectl_f1      <= nxt_fp0_pipectl_f1;
      fp1_pipectl_f1      <= nxt_fp1_pipectl_f1;
      neon_vld_ctl_f1     <= nxt_neon_vld_ctl_f1;
      sel_fad0_a_f1       <= nxt_sel_fad0_a_f1;
      sel_fad0_b_f1       <= nxt_sel_fad0_b_f1;
      sel_fad0_c_f1       <= nxt_sel_fad0_c_f1;
      sel_fad1_a_f1       <= nxt_sel_fad1_a_f1;
      sel_fad1_b_f1       <= nxt_sel_fad1_b_f1;
      sel_fad1_c_f1       <= nxt_sel_fad1_c_f1;
      sel_fml0_a_f1       <= sel_fml0_a_iss_i;
      sel_fml0_b_f1       <= sel_fml0_b_iss_i;
      sel_fml0_c_f1       <= sel_fml0_c_iss_i;
      sel_fml1_a_f1       <= sel_fml1_a_iss_i;
      sel_fml1_b_f1       <= sel_fml1_b_iss_i;
      sel_fml1_c_f1       <= sel_fml1_c_iss_i;
    end

  // Use the conventional issue_to_ex1 enable for signals that must be clocked when
  // the integer pipeline moves.  This could be signals that control the integer
  // datapath or it could be control signals for forwarding (as otherwise a flush
  // can leave these signals set and forwarding data incorrectly).  This also requires
  // the use of the main clock rather than the regionally gated version.
  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      fr0_fw0_where_f1[0]     <= {3{1'b0}};
      fr0_fw1_where_f1[0]     <= {3{1'b0}};
      fr0_fw0_where_f1[1]     <= {3{1'b0}};
      fr0_fw1_where_f1[1]     <= {3{1'b0}};
      fr1_fw0_where_f1[0]     <= {3{1'b0}};
      fr1_fw1_where_f1[0]     <= {3{1'b0}};
      fr1_fw0_where_f1[1]     <= {3{1'b0}};
      fr1_fw1_where_f1[1]     <= {3{1'b0}};
      fr2_fw0_where_f1[0]     <= {3{1'b0}};
      fr2_fw1_where_f1[0]     <= {3{1'b0}};
      fr2_fw0_where_f1[1]     <= {3{1'b0}};
      fr2_fw1_where_f1[1]     <= {3{1'b0}};
      fr3_fw0_where_f1[0]     <= {3{1'b0}};
      fr3_fw1_where_f1[0]     <= {3{1'b0}};
      fr3_fw0_where_f1[1]     <= {3{1'b0}};
      fr3_fw1_where_f1[1]     <= {3{1'b0}};
      fr4_fw0_where_f1[0]     <= {3{1'b0}};
      fr4_fw1_where_f1[0]     <= {3{1'b0}};
      fr4_fw0_where_f1[1]     <= {3{1'b0}};
      fr4_fw1_where_f1[1]     <= {3{1'b0}};
      fr5_fw0_where_f1[0]     <= {3{1'b0}};
      fr5_fw1_where_f1[0]     <= {3{1'b0}};
      fr5_fw0_where_f1[1]     <= {3{1'b0}};
      fr5_fw1_where_f1[1]     <= {3{1'b0}};
      fr0_zero_available_f1   <= {2{1'b0}};
      fr1_zero_available_f1   <= {2{1'b0}};
      fr2_zero_available_f1   <= {2{1'b0}};
      fr3_zero_available_f1   <= {2{1'b0}};
      fr4_zero_available_f1   <= {2{1'b0}};
      fr5_zero_available_f1   <= {2{1'b0}};
      fr0_fw0_available_f1[0] <= {3{1'b0}};
      fr0_fw1_available_f1[0] <= {3{1'b0}};
      fr0_fw0_available_f1[1] <= {3{1'b0}};
      fr0_fw1_available_f1[1] <= {3{1'b0}};
      fr1_fw0_available_f1[0] <= {3{1'b0}};
      fr1_fw1_available_f1[0] <= {3{1'b0}};
      fr1_fw0_available_f1[1] <= {3{1'b0}};
      fr1_fw1_available_f1[1] <= {3{1'b0}};
      fr2_fw0_available_f1[0] <= {3{1'b0}};
      fr2_fw1_available_f1[0] <= {3{1'b0}};
      fr2_fw0_available_f1[1] <= {3{1'b0}};
      fr2_fw1_available_f1[1] <= {3{1'b0}};
      fr3_fw0_available_f1[0] <= {3{1'b0}};
      fr3_fw1_available_f1[0] <= {3{1'b0}};
      fr3_fw0_available_f1[1] <= {3{1'b0}};
      fr3_fw1_available_f1[1] <= {3{1'b0}};
      fr4_fw0_available_f1[0] <= {3{1'b0}};
      fr4_fw1_available_f1[0] <= {3{1'b0}};
      fr4_fw0_available_f1[1] <= {3{1'b0}};
      fr4_fw1_available_f1[1] <= {3{1'b0}};
      fr5_fw0_available_f1[0] <= {3{1'b0}};
      fr5_fw1_available_f1[0] <= {3{1'b0}};
      fr5_fw0_available_f1[1] <= {3{1'b0}};
      fr5_fw1_available_f1[1] <= {3{1'b0}};
      fp_mul_fwd_ex1          <= 2'b00;
      instr_fmstat_ex1        <= 2'b00;
      str0_sel_fp_f1_reg      <= 2'b00;
      str1_sel_fp_f1_reg      <= 2'b00;
    end else if (issue_to_ex1) begin
      fr0_fw0_where_f1[0]     <= fr0_fw0_where_iss[0][3:1];
      fr0_fw1_where_f1[0]     <= fr0_fw1_where_iss[0][3:1];
      fr0_fw0_where_f1[1]     <= fr0_fw0_where_iss[1][3:1];
      fr0_fw1_where_f1[1]     <= fr0_fw1_where_iss[1][3:1];
      fr1_fw0_where_f1[0]     <= fr1_fw0_where_iss[0][3:1];
      fr1_fw1_where_f1[0]     <= fr1_fw1_where_iss[0][3:1];
      fr1_fw0_where_f1[1]     <= fr1_fw0_where_iss[1][3:1];
      fr1_fw1_where_f1[1]     <= fr1_fw1_where_iss[1][3:1];
      fr2_fw0_where_f1[0]     <= fr2_fw0_where_iss[0][3:1];
      fr2_fw1_where_f1[0]     <= fr2_fw1_where_iss[0][3:1];
      fr2_fw0_where_f1[1]     <= fr2_fw0_where_iss[1][3:1];
      fr2_fw1_where_f1[1]     <= fr2_fw1_where_iss[1][3:1];
      fr3_fw0_where_f1[0]     <= fr3_fw0_where_iss[0][3:1];
      fr3_fw1_where_f1[0]     <= fr3_fw1_where_iss[0][3:1];
      fr3_fw0_where_f1[1]     <= fr3_fw0_where_iss[1][3:1];
      fr3_fw1_where_f1[1]     <= fr3_fw1_where_iss[1][3:1];
      fr4_fw0_where_f1[0]     <= fr4_fw0_where_iss[0][3:1];
      fr4_fw1_where_f1[0]     <= fr4_fw1_where_iss[0][3:1];
      fr4_fw0_where_f1[1]     <= fr4_fw0_where_iss[1][3:1];
      fr4_fw1_where_f1[1]     <= fr4_fw1_where_iss[1][3:1];
      fr5_fw0_where_f1[0]     <= fr5_fw0_where_iss[0][3:1];
      fr5_fw1_where_f1[0]     <= fr5_fw1_where_iss[0][3:1];
      fr5_fw0_where_f1[1]     <= fr5_fw0_where_iss[1][3:1];
      fr5_fw1_where_f1[1]     <= fr5_fw1_where_iss[1][3:1];
      fr0_zero_available_f1   <= fr0_zero_available_iss;
      fr1_zero_available_f1   <= fr1_zero_available_iss;
      fr2_zero_available_f1   <= fr2_zero_available_iss;
      fr3_zero_available_f1   <= fr3_zero_available_iss;
      fr4_zero_available_f1   <= fr4_zero_available_iss;
      fr5_zero_available_f1   <= fr5_zero_available_iss;
      fr0_fw0_available_f1[0] <= fr0_fw0_available_iss[0];
      fr0_fw1_available_f1[0] <= fr0_fw1_available_iss[0];
      fr0_fw0_available_f1[1] <= fr0_fw0_available_iss[1];
      fr0_fw1_available_f1[1] <= fr0_fw1_available_iss[1];
      fr1_fw0_available_f1[0] <= fr1_fw0_available_iss[0];
      fr1_fw1_available_f1[0] <= fr1_fw1_available_iss[0];
      fr1_fw0_available_f1[1] <= fr1_fw0_available_iss[1];
      fr1_fw1_available_f1[1] <= fr1_fw1_available_iss[1];
      fr2_fw0_available_f1[0] <= fr2_fw0_available_iss[0];
      fr2_fw1_available_f1[0] <= fr2_fw1_available_iss[0];
      fr2_fw0_available_f1[1] <= fr2_fw0_available_iss[1];
      fr2_fw1_available_f1[1] <= fr2_fw1_available_iss[1];
      fr3_fw0_available_f1[0] <= fr3_fw0_available_iss[0];
      fr3_fw1_available_f1[0] <= fr3_fw1_available_iss[0];
      fr3_fw0_available_f1[1] <= fr3_fw0_available_iss[1];
      fr3_fw1_available_f1[1] <= fr3_fw1_available_iss[1];
      fr4_fw0_available_f1[0] <= fr4_fw0_available_iss[0];
      fr4_fw1_available_f1[0] <= fr4_fw1_available_iss[0];
      fr4_fw0_available_f1[1] <= fr4_fw0_available_iss[1];
      fr4_fw1_available_f1[1] <= fr4_fw1_available_iss[1];
      fr5_fw0_available_f1[0] <= fr5_fw0_available_iss[0];
      fr5_fw1_available_f1[0] <= fr5_fw1_available_iss[0];
      fr5_fw0_available_f1[1] <= fr5_fw0_available_iss[1];
      fr5_fw1_available_f1[1] <= fr5_fw1_available_iss[1];
      fp_mul_fwd_ex1          <= neon_mul_can_fwd;
      instr_fmstat_ex1        <= instr_fmstat_iss;
      str0_sel_fp_f1_reg      <= nxt_str0_sel_fp_f1;
      str1_sel_fp_f1_reg      <= nxt_str1_sel_fp_f1;
    end

  // These registers are specifically for FPU FMAC and double
  // precision special instructions
  assign en_f1 = ~stall_ex1_sfmac;

  always @(posedge clk_fp_ctl or negedge reset_n)
    if (~reset_n) begin
      rf_rd_en_fr0_f1           <= 2'b00;
      rf_rd_en_fr1_f1           <= 2'b00;
      rf_rd_en_fr2_f1           <= 2'b00;
      rf_rd_en_fr3_f1           <= 2'b00;
      rf_rd_en_fr4_f1           <= 2'b00;
      rf_rd_en_fr5_f1           <= 2'b00;
      raw_rf_wr_en_fw0_f1       <= 4'b0000;
      raw_rf_wr_en_fw1_f1       <= 4'b0000;
      unflushable_sfmac_ex1_reg <= 2'b00;
      instr_is_cp10_cp11_ex1    <= 1'b0;
      fp0_cflag_src_f1          <= {`CA53_FP_CFLAG_SRC_W{1'b0}};
      fp1_cflag_src_f1          <= {`CA53_FP_CFLAG_SRC_W{1'b0}};
      fp0_xflag_src_f1          <= {`CA53_FP_XFLAG_SRC_W{1'b0}};
      fp1_xflag_src_f1          <= {`CA53_FP_XFLAG_SRC_W{1'b0}};
    end else if (en_f1) begin
      rf_rd_en_fr0_f1           <= rf_rd_en_fr0_iss;
      rf_rd_en_fr1_f1           <= rf_rd_en_fr1_iss;
      rf_rd_en_fr2_f1           <= rf_rd_en_fr2_iss;
      rf_rd_en_fr3_f1           <= rf_rd_en_fr3_iss;
      rf_rd_en_fr4_f1           <= rf_rd_en_fr4_iss;
      rf_rd_en_fr5_f1           <= rf_rd_en_fr5_iss;
      raw_rf_wr_en_fw0_f1       <= rf_wr_en_fw0_iss;
      raw_rf_wr_en_fw1_f1       <= rf_wr_en_fw1_iss;
      unflushable_sfmac_ex1_reg <= unflushable_sfmac_iss;
      instr_is_cp10_cp11_ex1    <= instr_is_cp10_cp11_iss;
      fp0_cflag_src_f1          <= nxt_fp0_cflag_src_f1;
      fp1_cflag_src_f1          <= nxt_fp1_cflag_src_f1;
      fp0_xflag_src_f1          <= nxt_fp0_xflag_src_f1;
      fp1_xflag_src_f1          <= nxt_fp1_xflag_src_f1;
    end

  assign unflushable_sfmac_ex1 = unflushable_sfmac_ex1_reg;
  assign str0_sel_fp_f1        = str0_sel_fp_f1_reg;
  assign str1_sel_fp_f1        = str1_sel_fp_f1_reg;

  // ------------------------------------------------------
  // FPU F2 stage pipeline registers
  // ------------------------------------------------------

  assign nxt_unflushable_ex2 = unflushable_ex1 & advance_pipeline;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      unflushable_ex2_reg <= 1'b0;
    else if (en_btm_pc_ex2)
      unflushable_ex2_reg <= nxt_unflushable_ex2;

  assign unflushable_ex2 = unflushable_ex2_reg;

  always @(posedge clk_fp_ctl or negedge reset_n)
    if (~reset_n) begin
      rf_wr_addr_fw0_f2 <= {`CA53_FP_RF_WR_ADDR_W{1'b0}};
      rf_wr_addr_fw1_f2 <= {`CA53_FP_RF_WR_ADDR_W{1'b0}};
      rf_wr_src_fw0_f2  <= {`CA53_RF_FWR_SRC_W{1'b0}};
      rf_wr_src_fw1_f2  <= {`CA53_RF_FWR_SRC_W{1'b0}};
      rf_wr_when_fw0_f2 <= {`CA53_RF_FWR_WHEN_W{1'b0}};
      rf_wr_when_fw1_f2 <= {`CA53_RF_FWR_WHEN_W{1'b0}};
    end else if (issue_to_ex2_fpu) begin
      rf_wr_addr_fw0_f2 <= rf_wr_addr_fw0_f1[(`CA53_FP_RF_WR_ADDR_W-1):0];
      rf_wr_addr_fw1_f2 <= rf_wr_addr_fw1_f1[(`CA53_FP_RF_WR_ADDR_W-1):0];
      rf_wr_src_fw0_f2  <= rf_wr_src_fw0_f1;
      rf_wr_src_fw1_f2  <= rf_wr_src_fw1_f1;
      rf_wr_when_fw0_f2 <= rf_wr_when_fw0_f1;
      rf_wr_when_fw1_f2 <= rf_wr_when_fw1_f1;
    end

  // Use the conventional issue_to_ex2 enable for signals that must be clocked when
  // the integer pipeline moves.  This could be signals that control the integer
  // datapath or it could be control signals for forwarding (as otherwise a flush
  // can leave these signals set and forwarding data incorrectly).  This also requires
  // the use of the main clock rather than the regionally gated version.
  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      fr0_fw0_where_f2[0] <= {3{1'b0}};
      fr0_fw1_where_f2[0] <= {3{1'b0}};
      fr0_fw0_where_f2[1] <= {3{1'b0}};
      fr0_fw1_where_f2[1] <= {3{1'b0}};
      fr1_fw0_where_f2[0] <= {3{1'b0}};
      fr1_fw1_where_f2[0] <= {3{1'b0}};
      fr1_fw0_where_f2[1] <= {3{1'b0}};
      fr1_fw1_where_f2[1] <= {3{1'b0}};
      fr2_fw0_where_f2[0] <= {3{1'b0}};
      fr2_fw1_where_f2[0] <= {3{1'b0}};
      fr2_fw0_where_f2[1] <= {3{1'b0}};
      fr2_fw1_where_f2[1] <= {3{1'b0}};
      fr3_fw0_where_f2[0] <= {3{1'b0}};
      fr3_fw1_where_f2[0] <= {3{1'b0}};
      fr3_fw0_where_f2[1] <= {3{1'b0}};
      fr3_fw1_where_f2[1] <= {3{1'b0}};
      fr4_fw0_where_f2[0] <= {3{1'b0}};
      fr4_fw1_where_f2[0] <= {3{1'b0}};
      fr4_fw0_where_f2[1] <= {3{1'b0}};
      fr4_fw1_where_f2[1] <= {3{1'b0}};
      fr5_fw0_where_f2[0] <= {3{1'b0}};
      fr5_fw1_where_f2[0] <= {3{1'b0}};
      fr5_fw0_where_f2[1] <= {3{1'b0}};
      fr5_fw1_where_f2[1] <= {3{1'b0}};
      fp_mul_fwd_ex2      <= {2{1'b0}};
      instr_fmstat_ex2    <= {2{1'b0}};
      str0_sel_fp_f2_reg  <= {2{1'b0}};
      str1_sel_fp_f2_reg  <= {2{1'b0}};
    end else if (issue_to_ex2) begin
      fr0_fw0_where_f2[0] <= nxt_fr0_fw0_where_f2[0];
      fr0_fw1_where_f2[0] <= nxt_fr0_fw1_where_f2[0];
      fr0_fw0_where_f2[1] <= nxt_fr0_fw0_where_f2[1];
      fr0_fw1_where_f2[1] <= nxt_fr0_fw1_where_f2[1];
      fr1_fw0_where_f2[0] <= nxt_fr1_fw0_where_f2[0];
      fr1_fw1_where_f2[0] <= nxt_fr1_fw1_where_f2[0];
      fr1_fw0_where_f2[1] <= nxt_fr1_fw0_where_f2[1];
      fr1_fw1_where_f2[1] <= nxt_fr1_fw1_where_f2[1];
      fr2_fw0_where_f2[0] <= nxt_fr2_fw0_where_f2[0];
      fr2_fw1_where_f2[0] <= nxt_fr2_fw1_where_f2[0];
      fr2_fw0_where_f2[1] <= nxt_fr2_fw0_where_f2[1];
      fr2_fw1_where_f2[1] <= nxt_fr2_fw1_where_f2[1];
      fr3_fw0_where_f2[0] <= nxt_fr3_fw0_where_f2[0];
      fr3_fw1_where_f2[0] <= nxt_fr3_fw1_where_f2[0];
      fr3_fw0_where_f2[1] <= nxt_fr3_fw0_where_f2[1];
      fr3_fw1_where_f2[1] <= nxt_fr3_fw1_where_f2[1];
      fr4_fw0_where_f2[0] <= nxt_fr4_fw0_where_f2[0];
      fr4_fw1_where_f2[0] <= nxt_fr4_fw1_where_f2[0];
      fr4_fw0_where_f2[1] <= nxt_fr4_fw0_where_f2[1];
      fr4_fw1_where_f2[1] <= nxt_fr4_fw1_where_f2[1];
      fr5_fw0_where_f2[0] <= nxt_fr5_fw0_where_f2[0];
      fr5_fw1_where_f2[0] <= nxt_fr5_fw1_where_f2[0];
      fr5_fw0_where_f2[1] <= nxt_fr5_fw0_where_f2[1];
      fr5_fw1_where_f2[1] <= nxt_fr5_fw1_where_f2[1];
      fp_mul_fwd_ex2      <= fp_mul_fwd_ex1;
      instr_fmstat_ex2    <= instr_fmstat_ex1;
      str0_sel_fp_f2_reg  <= str0_sel_fp_f1;
      str1_sel_fp_f2_reg  <= str1_sel_fp_f1;
    end

  assign en_f2 = ~stall_ex2_sfmac;

  always @(posedge clk_fp_ctl or negedge reset_n)
    if (~reset_n) begin
      rf_rd_en_fr0_f2           <= 2'b00;
      rf_rd_en_fr1_f2           <= 2'b00;
      rf_rd_en_fr2_f2           <= 2'b00;
      rf_rd_en_fr3_f2           <= 2'b00;
      rf_rd_en_fr4_f2           <= 2'b00;
      rf_rd_en_fr5_f2           <= 2'b00;
      raw_rf_wr_en_fw0_f2       <= 4'b0000;
      raw_rf_wr_en_fw1_f2       <= 4'b0000;
      unflushable_sfmac_ex2_reg <= 2'b00;
      fdivs_pre_valid_f2        <= 2'b00;
      instr_is_cp10_cp11_ex2    <= 1'b0;
      fp0_cflag_src_f2          <= {`CA53_FP_CFLAG_SRC_W{1'b0}};
      fp1_cflag_src_f2          <= {`CA53_FP_CFLAG_SRC_W{1'b0}};
      fp0_xflag_src_f2          <= {`CA53_FP_XFLAG_SRC_W{1'b0}};
      fp1_xflag_src_f2          <= {`CA53_FP_XFLAG_SRC_W{1'b0}};
    end else if (en_f2) begin
      rf_rd_en_fr0_f2           <= rf_rd_en_fr0_f1;
      rf_rd_en_fr1_f2           <= rf_rd_en_fr1_f1;
      rf_rd_en_fr2_f2           <= rf_rd_en_fr2_f1;
      rf_rd_en_fr3_f2           <= rf_rd_en_fr3_f1;
      rf_rd_en_fr4_f2           <= rf_rd_en_fr4_f1;
      rf_rd_en_fr5_f2           <= rf_rd_en_fr5_f1;
      raw_rf_wr_en_fw0_f2       <= raw_rf_wr_en_fw0_f1;
      raw_rf_wr_en_fw1_f2       <= raw_rf_wr_en_fw1_f1;
      unflushable_sfmac_ex2_reg <= unflushable_sfmac_ex1;
      fdivs_pre_valid_f2        <= fdivs_valid_f1;
      instr_is_cp10_cp11_ex2    <= instr_is_cp10_cp11_ex1;
      fp0_cflag_src_f2          <= fp0_cflag_src_f1;
      fp1_cflag_src_f2          <= fp1_cflag_src_f1;
      fp0_xflag_src_f2          <= fp0_xflag_src_f1;
      fp1_xflag_src_f2          <= fp1_xflag_src_f1;
    end

  // Qualify the FPU register file write enable
  // FW1 can be either slot 0 or slot 1
  assign rf_wr_en_fw0_f2 = raw_rf_wr_en_fw0_f2 & {4{(nxt_valid_instrs_wr[0] &                                        cc_pass_instr0_ex2_i) |
                                                    unflushable_sfmac_ex2[0]}};
  assign rf_wr_en_fw1_f2 = raw_rf_wr_en_fw1_f2 & {4{(nxt_valid_instrs_wr[0] & (slot1_fp_ex2 ? cc_pass_instr1_ex2_i : cc_pass_instr0_ex2_i)) |
                                                    unflushable_sfmac_ex2[1]}};

  assign unflushable_sfmac_ex2 = unflushable_sfmac_ex2_reg;
  assign str0_sel_fp_f2        = str0_sel_fp_f2_reg;
  assign str1_sel_fp_f2        = str1_sel_fp_f2_reg;

  // ------------------------------------------------------
  // FPU F3 stage pipeline registers
  // ------------------------------------------------------

  // Qualify the phantoms before they reach F3 (Wr)
  assign nxt_fdivs_valid_f3  = fdivs_valid_f2 & {2{cc_pass_instr0_ex2_i}};

  assign nxt_fp0_xflag_src_f3 = fp0_xflag_src_f2 & {`CA53_FP_XFLAG_SRC_W{~fp0_ccmp_fail_ex2_i}};
  assign nxt_fp1_xflag_src_f3 = fp1_xflag_src_f2 & {`CA53_FP_XFLAG_SRC_W{~fp1_ccmp_fail_ex2_i}};

  always @(posedge clk_fp_ctl or negedge reset_n)
    if (~reset_n)
      unflushable_wr_reg <= 1'b0;
    else if (en_btm_pc_ex2)
      unflushable_wr_reg <= unflushable_ex2;

  assign unflushable_wr = unflushable_wr_reg;

  always @(posedge clk_fp_ctl or negedge reset_n)
    if (~reset_n) begin
      rf_wr_addr_fw0_f3 <= {`CA53_FP_RF_WR_ADDR_W{1'b0}};
      rf_wr_addr_fw1_f3 <= {`CA53_FP_RF_WR_ADDR_W{1'b0}};
      rf_wr_src_fw0_f3  <= {`CA53_RF_FWR_SRC_W{1'b0}};
      rf_wr_src_fw1_f3  <= {`CA53_RF_FWR_SRC_W{1'b0}};
      rf_wr_when_fw0_f3 <= {`CA53_RF_FWR_WHEN_W{1'b0}};
      rf_wr_when_fw1_f3 <= {`CA53_RF_FWR_WHEN_W{1'b0}};
    end else if (issue_to_wr_fpu) begin
      rf_wr_addr_fw0_f3 <= rf_wr_addr_fw0_f2[(`CA53_FP_RF_WR_ADDR_W-1):0];
      rf_wr_addr_fw1_f3 <= rf_wr_addr_fw1_f2[(`CA53_FP_RF_WR_ADDR_W-1):0];
      rf_wr_src_fw0_f3  <= rf_wr_src_fw0_f2;
      rf_wr_src_fw1_f3  <= rf_wr_src_fw1_f2;
      rf_wr_when_fw0_f3 <= rf_wr_when_fw0_f2;
      rf_wr_when_fw1_f3 <= rf_wr_when_fw1_f2;
    end

  always @(posedge clk_fp_ctl or negedge reset_n)
    if (~reset_n) begin
      instr_is_cp10_cp11_wr    <= 1'b0;
      raw_rf_wr_en_fw0_f3      <= 4'b0000;
      raw_rf_wr_en_fw1_f3      <= 4'b0000;
      fdivs_valid_f3           <= 2'b00;
      unflushable_sfmac_wr_reg <= 2'b00;
      raw_fp0_cflag_src_f3     <= {`CA53_FP_CFLAG_SRC_W{1'b0}};
      raw_fp1_cflag_src_f3     <= {`CA53_FP_CFLAG_SRC_W{1'b0}};
      raw_fp0_xflag_src_f3     <= {`CA53_FP_XFLAG_SRC_W{1'b0}};
      raw_fp1_xflag_src_f3     <= {`CA53_FP_XFLAG_SRC_W{1'b0}};
    end else if (advance_pipeline) begin
      instr_is_cp10_cp11_wr    <= instr_is_cp10_cp11_ex2;
      raw_rf_wr_en_fw0_f3      <= rf_wr_en_fw0_f2;
      raw_rf_wr_en_fw1_f3      <= rf_wr_en_fw1_f2;
      fdivs_valid_f3           <= nxt_fdivs_valid_f3;
      unflushable_sfmac_wr_reg <= unflushable_sfmac_ex2;
      raw_fp0_cflag_src_f3     <= fp0_cflag_src_f2;
      raw_fp1_cflag_src_f3     <= fp1_cflag_src_f2;
      raw_fp0_xflag_src_f3     <= nxt_fp0_xflag_src_f3;
      raw_fp1_xflag_src_f3     <= nxt_fp1_xflag_src_f3;
    end

  always @(posedge clk_fp_ctl)
    if (advance_pipeline) begin
      fp_cflags_add0_f3 <= fp_cflags_add0_f2_i;
      fp_cflags_add1_f3 <= fp_cflags_add1_f2_i;
    end

  // Qualify the FPU register file write enable
  assign rf_wr_en_fw0_f3 = raw_rf_wr_en_fw0_f3 & {4{((pre_valid_instrs_wr[0] & ~quash_slot0_wr) | unflushable_sfmac_wr[0]) & advance_pipeline}};
  assign rf_wr_en_fw1_f3 = raw_rf_wr_en_fw1_f3 & {4{((pre_valid_instrs_wr[0] & ~(slot1_fp_wr ? quash_wr : quash_slot0_wr) &
                                                      ~slot0_br_flush_wr_i) | unflushable_sfmac_wr[1]) & advance_pipeline}};

  // Enable for Load-Store / Register Transfer Pipeline
  assign rf_wr_en_fw_f3 = (|raw_rf_wr_en_fw0_f3) | (|raw_rf_wr_en_fw1_f3);

  // Enable for FPSR condition/exception flags
  assign fp0_cflag_src_f3 =  raw_fp0_cflag_src_f3   & {`CA53_FP_CFLAG_SRC_W{pre_valid_instrs_wr[0] & cc_pass_instr0_wr & ~quash_slot0_wr                  & ~unflushable_wr}};
  assign fp1_cflag_src_f3 =  raw_fp1_cflag_src_f3   & {`CA53_FP_CFLAG_SRC_W{pre_valid_instrs_wr[1] & cc_pass_instr1_wr & ~quash_wr & ~slot0_br_flush_wr_i & ~unflushable_wr}};
  assign fp0_xflag_src_f3 = (raw_fp0_xflag_src_f3   & {`CA53_FP_XFLAG_SRC_W{pre_valid_instrs_wr[0] & cc_pass_instr0_wr & ~quash_slot0_wr                  & ~unflushable_wr}}) |
                            (`CA53_FP_XFLAG_SRC_ALU & {`CA53_FP_XFLAG_SRC_W{unflushable_sfmac_wr[0]}}) |
                            (`CA53_FP_XFLAG_SRC_MUL & {`CA53_FP_XFLAG_SRC_W{unflushable_wr}});
  assign fp1_xflag_src_f3 = (raw_fp1_xflag_src_f3   & {`CA53_FP_XFLAG_SRC_W{pre_valid_instrs_wr[0] & (slot1_fp_wr ? cc_pass_instr1_wr : cc_pass_instr0_wr) &
                                                                            ~quash_slot0_wr & ~slot0_br_flush_wr_i & ~unflushable_wr}}) |
                            (`CA53_FP_XFLAG_SRC_ALU & {`CA53_FP_XFLAG_SRC_W{unflushable_sfmac_wr[1]}}) |
                            (`CA53_FP_XFLAG_SRC_MUL & {`CA53_FP_XFLAG_SRC_W{unflushable_wr & (|raw_rf_wr_en_fw1_f3)}});

  assign unflushable_sfmac_wr = unflushable_sfmac_wr_reg;

  // ------------------------------------------------------
  // FPU F4 stage pipeline registers
  // ------------------------------------------------------

  always @(posedge clk_fp_ctl or negedge reset_n)
    if (~reset_n) begin
      rf_wr_addr_fw0_f4 <= {`CA53_FP_RF_WR_ADDR_W{1'b0}};
      rf_wr_addr_fw1_f4 <= {`CA53_FP_RF_WR_ADDR_W{1'b0}};
      rf_wr_src_fw0_f4  <= {`CA53_RF_FWR_SRC_W{1'b0}};
      rf_wr_src_fw1_f4  <= {`CA53_RF_FWR_SRC_W{1'b0}};
      rf_wr_when_fw0_f4 <= {`CA53_RF_FWR_WHEN_W{1'b0}};
      rf_wr_when_fw1_f4 <= {`CA53_RF_FWR_WHEN_W{1'b0}};
    end else if (issue_to_f4) begin
      rf_wr_addr_fw0_f4 <= rf_wr_addr_fw0_f3[(`CA53_FP_RF_WR_ADDR_W-1):0];
      rf_wr_addr_fw1_f4 <= rf_wr_addr_fw1_f3[(`CA53_FP_RF_WR_ADDR_W-1):0];
      rf_wr_src_fw0_f4  <= rf_wr_src_fw0_f3;
      rf_wr_src_fw1_f4  <= rf_wr_src_fw1_f3;
      rf_wr_when_fw0_f4 <= rf_wr_when_fw0_f3;
      rf_wr_when_fw1_f4 <= rf_wr_when_fw1_f3;
    end

  always @(posedge clk_fp_ctl or negedge reset_n)
    if (~reset_n) begin
      instr_is_cp10_cp11_f4 <= 1'b0;
      raw_rf_wr_en_fw0_f4   <= 4'b0000;
      raw_rf_wr_en_fw1_f4   <= 4'b0000;
      raw_fp0_cflag_src_f4  <= {`CA53_FP_CFLAG_SRC_W{1'b0}};
      raw_fp1_cflag_src_f4  <= {`CA53_FP_CFLAG_SRC_W{1'b0}};
      raw_fp0_xflag_src_f4  <= {`CA53_FP_XFLAG_SRC_W{1'b0}};
      raw_fp1_xflag_src_f4  <= {`CA53_FP_XFLAG_SRC_W{1'b0}};
    end else if (advance_pipeline) begin
      instr_is_cp10_cp11_f4 <= instr_is_cp10_cp11_wr;
      raw_rf_wr_en_fw0_f4   <= rf_wr_en_fw0_f3;
      raw_rf_wr_en_fw1_f4   <= rf_wr_en_fw1_f3;
      raw_fp0_cflag_src_f4  <= fp0_cflag_src_f3;
      raw_fp1_cflag_src_f4  <= fp1_cflag_src_f3;
      raw_fp0_xflag_src_f4  <= fp0_xflag_src_f3;
      raw_fp1_xflag_src_f4  <= fp1_xflag_src_f3;
    end

  always @(posedge clk_fp_ctl)
    if (advance_pipeline) begin
      fp_cflags_add0_f4 <= fp_cflags_add0_f3;
      fp_cflags_add1_f4 <= fp_cflags_add1_f3;
    end

  // Qualify the FPU register file write enable
  assign rf_wr_en_fw0_f4 = raw_rf_wr_en_fw0_f4 & {4{advance_pipeline}};
  assign rf_wr_en_fw1_f4 = raw_rf_wr_en_fw1_f4 & {4{advance_pipeline}};

  assign fp0_cflag_src_f4 = raw_fp0_cflag_src_f4 & {`CA53_FP_CFLAG_SRC_W{advance_pipeline}};
  assign fp1_cflag_src_f4 = raw_fp1_cflag_src_f4 & {`CA53_FP_CFLAG_SRC_W{advance_pipeline}};
  assign fp0_xflag_src_f4 = raw_fp0_xflag_src_f4 & {`CA53_FP_XFLAG_SRC_W{advance_pipeline}};
  assign fp1_xflag_src_f4 = raw_fp1_xflag_src_f4 & {`CA53_FP_XFLAG_SRC_W{advance_pipeline}};

  // ------------------------------------------------------
  // FPU F5 stage pipeline registers
  // ------------------------------------------------------

  always @(posedge clk_fp_ctl or negedge reset_n)
    if (~reset_n) begin
      rf_wr_addr_fw0_f5   <= {`CA53_FP_RF_WR_ADDR_W{1'b0}};
      rf_wr_addr_fw1_f5   <= {`CA53_FP_RF_WR_ADDR_W{1'b0}};
      rf_wr_src_fw0_f5    <= {`CA53_RF_FWR_SRC_W{1'b0}};
      rf_wr_src_fw1_f5    <= {`CA53_RF_FWR_SRC_W{1'b0}};
      rf_wr_valid_fw0_f5  <= 2'b00;
      rf_wr_valid_fw1_f5  <= 2'b00;
    end else if (issue_to_f5) begin
      rf_wr_addr_fw0_f5   <= rf_wr_addr_fw0_f4[(`CA53_FP_RF_WR_ADDR_W-1):0];
      rf_wr_addr_fw1_f5   <= rf_wr_addr_fw1_f4[(`CA53_FP_RF_WR_ADDR_W-1):0];
      rf_wr_src_fw0_f5    <= rf_wr_src_fw0_f4;
      rf_wr_src_fw1_f5    <= rf_wr_src_fw1_f4;
      rf_wr_valid_fw0_f5  <= rf_wr_en_fw0_f4[1:0];
      rf_wr_valid_fw1_f5  <= rf_wr_en_fw1_f4[1:0];
    end

  assign en_rf_wr_en_f5 = issue_to_f5 | rf_wr_en_fw_f5 | (|fp0_cflag_src_f5) | (|fp1_cflag_src_f5) | (|fp0_xflag_src_f5) | (|fp1_xflag_src_f5);

  // Create an intermediate clock gate enable for the register bank
  assign rf_wr_en_fw_f4 = (|rf_wr_en_fw0_f4) | (|rf_wr_en_fw1_f4);

  always @(posedge clk_fp_ctl or negedge reset_n)
    if (~reset_n) begin
      rf_wr_en_fw_f5        <= 1'b0;
      rf_wr_en_fw0_f5       <= 4'b0000;
      rf_wr_en_fw1_f5       <= 4'b0000;
      fp0_cflag_src_f5      <= {`CA53_FP_CFLAG_SRC_W{1'b0}};
      fp1_cflag_src_f5      <= {`CA53_FP_CFLAG_SRC_W{1'b0}};
      fp0_xflag_src_f5      <= {`CA53_FP_XFLAG_SRC_W{1'b0}};
      fp1_xflag_src_f5      <= {`CA53_FP_XFLAG_SRC_W{1'b0}};
    end else if (en_rf_wr_en_f5) begin
      rf_wr_en_fw_f5        <= rf_wr_en_fw_f4;
      rf_wr_en_fw0_f5       <= rf_wr_en_fw0_f4;
      rf_wr_en_fw1_f5       <= rf_wr_en_fw1_f4;
      fp0_cflag_src_f5      <= fp0_cflag_src_f4;
      fp1_cflag_src_f5      <= fp1_cflag_src_f4;
      fp0_xflag_src_f5      <= fp0_xflag_src_f4;
      fp1_xflag_src_f5      <= fp1_xflag_src_f4;
    end

  always @(posedge clk_fp_ctl or negedge reset_n)
    if (~reset_n)
      instr_is_cp10_cp11_f5 <= 1'b0;
    else if (advance_pipeline)
      instr_is_cp10_cp11_f5 <= instr_is_cp10_cp11_f4;

  always @(posedge clk_fp_ctl)
    if (advance_pipeline) begin
      fp_cflags_add0_f5 <= fp_cflags_add0_f4;
      fp_cflags_add1_f5 <= fp_cflags_add1_f4;
    end

  // ------------------------------------------------------
  // Crypto pipeline enable
  // ------------------------------------------------------

  if (CRYPTO) begin : g_crypto_enable
    reg  raw_crypto_enable_iss;
    reg  crypto_enable_f1;
    wire crypto_enable_iss;
    wire nxt_crypto_enable_f1;

    always @(posedge clk_fp_ctl or negedge reset_n)
      if (~reset_n)
        raw_crypto_enable_iss <= 1'b0;
      else if (issue_to_iss)
        raw_crypto_enable_iss <= crypto_enable_de_i;

    assign crypto_enable_iss = raw_crypto_enable_iss & ~neon_in_retention;

    assign nxt_crypto_enable_f1 = crypto_enable_iss & valid_instrs_iss[0] & ~stall_slot0_iss & ~quash_iss & ~flush_ret;

    always @(posedge clk_fp_ctl or negedge reset_n)
      if (~reset_n)
        crypto_enable_f1 <= 1'b0;
      else if (en_btm_pc_ex1)
        crypto_enable_f1 <= nxt_crypto_enable_f1;

    assign crypto_enable_iss_o = crypto_enable_iss;
    assign crypto_enable_f1_o  = crypto_enable_f1;
  end else begin : g_crypto_enable_stubs
    assign crypto_enable_iss_o = 1'b0;
    assign crypto_enable_f1_o  = 1'b0;
  end

  // ------------------------------------------------------
  // Special control logic
  // ------------------------------------------------------

  ca53dpu_special `CA53_DPU_PARAM_INST u_dpu_special (
    // Inputs
    .clk                            (clk),
    .clk_fp_ctl                     (clk_fp_ctl),
    .reset_n                        (reset_n),
    .issue_to_iss_i                 (issue_to_iss),
    .issue_to_iss_fpu_i             (issue_to_iss_fpu),
    .fp_div_busy_nxt_cyc_i          (fp_div_busy_nxt_cyc_i[1:0]),
    .valid_instrs_iss_i             (valid_instrs_iss[1:0]),
    .valid_instrs_ex1_i             (valid_instrs_ex1[1:0]),
    .valid_instrs_ex2_i             (valid_instrs_ex2[1:0]),
    .valid_instrs_wr_i              (valid_instrs_wr[1:0]),
    .pre_valid_instrs_wr_i          (pre_valid_instrs_wr[1:0]),
    .slot1_fp_ex2_i                 (slot1_fp_ex2),
    .cc_pass_instr0_ex2_i           (cc_pass_instr0_ex2_i),
    .cc_pass_instr1_ex2_i           (cc_pass_instr1_ex2_i),
    .no_insert_iss_i                (no_insert_iss),
    .flush_ret_i                    (flush_ret),
    .flush_wr_i                     (flush_wr),
    .quash_wr_special_i             (quash_wr_special),
    .slot0_br_flush_wr_i            (slot0_br_flush_wr_i),
    .stall_wr_i                     (stall_wr),
    .stall_slot0_iss_i              (stall_slot0_iss),
    .ilock_stall_div_iss_i          (ilock_stall_div_iss),
    .lsm_skidding_i                 (lsm_skidding_i),
    .fdivs_valid_iss_i              (fdivs_valid_iss[1:0]),
    .fdivs_valid_f1_i               (fdivs_valid_f1[1:0]),
    .fdivs_valid_f2_i               (fdivs_valid_f2[1:0]),
    .fdivs_valid_f3_i               (fdivs_valid_f3[1:0]),
    .rf_rd_addr_fr0_de_i            (rf_rd_addr_fr0_de_i[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_addr_fr1_de_i            (rf_rd_addr_fr1_de_i[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_addr_fr2_de_i            (rf_rd_addr_fr2_de_i[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_addr_fr3_de_i            (rf_rd_addr_fr3_de_i[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_addr_fr4_de_i            (rf_rd_addr_fr4_de_i[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_addr_fr5_de_i            (rf_rd_addr_fr5_de_i[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .rf_rd_en_fr0_de_i              (rf_rd_en_fr0_de_i[1:0]),
    .rf_rd_en_fr1_de_i              (rf_rd_en_fr1_de_i[1:0]),
    .rf_rd_en_fr2_de_i              (rf_rd_en_fr2_de_i[1:0]),
    .rf_rd_en_fr3_de_i              (rf_rd_en_fr3_de_i[1:0]),
    .rf_rd_en_fr4_de_i              (rf_rd_en_fr4_de_i[1:0]),
    .rf_rd_en_fr5_de_i              (rf_rd_en_fr5_de_i[1:0]),
    .pre_rf_wr_addr_fw0_iss_i       (pre_rf_wr_addr_fw0_iss[`CA53_FP_RF_WR_ADDR_W-1:0]),
    .raw_rf_wr_addr_fw1_iss_i       (raw_rf_wr_addr_fw1_iss[`CA53_FP_RF_WR_ADDR_W-1:0]),
    .raw_rf_wr_en_fw0_iss_i         (raw_rf_wr_en_fw0_iss),
    .raw_rf_wr_en_fw1_iss_i         (raw_rf_wr_en_fw1_iss),
    .fmac_valid_sp_iss_i            (fmac_valid_sp_iss[1:0]),
    .raw_fp_ex_pipe_iss_i           (raw_fp_ex_pipe_iss[`CA53_FP_EX_PIPE_W-1:0]),
    .fp0_pipectl_iss_i              (fp0_pipectl_iss_i[`CA53_FP_PIPECTL_W-1:0]),
    .fp1_pipectl_iss_i              (fp1_pipectl_iss_i[`CA53_FP_PIPECTL_W-1:0]),
    .fp_serialize_iss_i             (fp_serialize_iss_i),
    .wfx_serialize_iss_i            (wfx_serialize_iss),
    .sel_fad0_a_iss_i               (sel_fad0_a_iss_i[`CA53_SEL_FAD_A_W-1:0]),
    .sel_fad1_a_iss_i               (sel_fad1_a_iss_i[`CA53_SEL_FAD_A_W-1:0]),
    // Outputs
    .unflushable_sfmac_iss_o        (unflushable_sfmac_iss[1:0]),
    .unflushable_sfdiv_iss_o        (unflushable_sfdiv_iss),
    .special_stall_iss_o            (special_stall_iss),
    .special_insert_iss_o           (special_insert_iss[1:0]),
    .special_interlock_iss_o        (special_interlock_iss),
    .special_sel_fad0_a_iss_o       (special_sel_fad0_a_iss[`CA53_SEL_FAD_A_W-1:0]),
    .special_sel_fad0_b_iss_o       (special_sel_fad0_b_iss[`CA53_SEL_FAD_B_W-1:0]),
    .special_sel_fad1_a_iss_o       (special_sel_fad1_a_iss[`CA53_SEL_FAD_A_W-1:0]),
    .special_sel_fad1_b_iss_o       (special_sel_fad1_b_iss[`CA53_SEL_FAD_B_W-1:0]),
    .special_rf_rd_en_fr2_iss_o     (special_rf_rd_en_fr2_iss[1:0]),
    .special_rf_rd_en_fr5_iss_o     (special_rf_rd_en_fr5_iss[1:0]),
    .special_rf_rd_addr_fr2_iss_o   (special_rf_rd_addr_fr2_iss[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .special_rf_rd_addr_fr5_iss_o   (special_rf_rd_addr_fr5_iss[`CA53_FP_RF_RD_ADDR_W-1:0]),
    .special_rf_wr_en_fw0_iss_o     (special_rf_wr_en_fw0_iss),
    .special_rf_wr_en_fw1_iss_o     (special_rf_wr_en_fw1_iss),
    .special_rf_wr_addr_fw0_iss_o   (special_rf_wr_addr_fw0_iss[`CA53_FP_RF_WR_ADDR_W-1:0]),
    .special_rf_wr_addr_fw1_iss_o   (special_rf_wr_addr_fw1_iss[`CA53_FP_RF_WR_ADDR_W-1:0]),
    .special_rf_wr_src_fw0_iss_o    (special_rf_wr_src_fw0_iss[`CA53_RF_FWR_SRC_W-1:0]),
    .special_rf_wr_src_fw1_iss_o    (special_rf_wr_src_fw1_iss[`CA53_RF_FWR_SRC_W-1:0]),
    .special_fp_add0_ctl_iss_o      (special_fp_add0_ctl_iss[`CA53_FP_ADD_CTL_W-1:0]),
    .special_fp_add1_ctl_iss_o      (special_fp_add1_ctl_iss[`CA53_FP_ADD_CTL_W-1:0]),
    .fmac_valid_f3_o                (fmac_valid_f3),
    .fp_special_in_flight_o         (fp_special_in_flight),
    .fp_div_active_o                (fp_div_active_o[1:0])
  );

  // ------------------------------------------------------
  // Iss 'where' signals for the FPU forwarding logic
  // ------------------------------------------------------

  // Compare the read address which operates over and is aligned to double registers (e.g. D0, D1, etc)
  // to the write address which operates over and is aligned to single registers (e.g. S0, S1, etc).
  // Therefore we ignore the bottom bit of the write address when we compare with the complete read
  // address.  This gives us address matching on a per-read-port/per-double-register basis, but does
  // not tell us for sure if there is a hazard.
  assign fr0_fw0_addr_match[3:0] = {rf_rd_addr_fr0_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f1[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr0_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f2[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr0_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f3[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr0_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f4[`CA53_FP_RF_WR_ADDR_W-1:1]};

  assign fr0_fw1_addr_match[3:0] = {rf_rd_addr_fr0_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f1[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr0_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f2[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr0_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f3[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr0_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f4[`CA53_FP_RF_WR_ADDR_W-1:1]};

  assign fr1_fw0_addr_match[3:0] = {rf_rd_addr_fr1_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f1[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr1_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f2[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr1_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f3[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr1_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f4[`CA53_FP_RF_WR_ADDR_W-1:1]};

  assign fr1_fw1_addr_match[3:0] = {rf_rd_addr_fr1_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f1[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr1_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f2[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr1_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f3[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr1_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f4[`CA53_FP_RF_WR_ADDR_W-1:1]};

  assign fr2_fw0_addr_match[3:0] = {rf_rd_addr_fr2_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f1[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr2_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f2[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr2_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f3[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr2_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f4[`CA53_FP_RF_WR_ADDR_W-1:1]};

  assign fr2_fw1_addr_match[3:0] = {rf_rd_addr_fr2_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f1[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr2_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f2[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr2_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f3[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr2_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f4[`CA53_FP_RF_WR_ADDR_W-1:1]};

  assign fr3_fw0_addr_match[3:0] = {rf_rd_addr_fr3_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f1[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr3_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f2[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr3_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f3[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr3_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f4[`CA53_FP_RF_WR_ADDR_W-1:1]};

  assign fr3_fw1_addr_match[3:0] = {rf_rd_addr_fr3_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f1[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr3_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f2[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr3_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f3[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr3_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f4[`CA53_FP_RF_WR_ADDR_W-1:1]};

  assign fr4_fw0_addr_match[3:0] = {rf_rd_addr_fr4_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f1[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr4_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f2[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr4_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f3[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr4_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f4[`CA53_FP_RF_WR_ADDR_W-1:1]};

  assign fr4_fw1_addr_match[3:0] = {rf_rd_addr_fr4_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f1[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr4_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f2[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr4_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f3[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr4_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f4[`CA53_FP_RF_WR_ADDR_W-1:1]};

  assign fr5_fw0_addr_match[3:0] = {rf_rd_addr_fr5_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f1[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr5_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f2[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr5_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f3[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr5_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw0_f4[`CA53_FP_RF_WR_ADDR_W-1:1]};

  assign fr5_fw1_addr_match[3:0] = {rf_rd_addr_fr5_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f1[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr5_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f2[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr5_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f3[`CA53_FP_RF_WR_ADDR_W-1:1],
                                    rf_rd_addr_fr5_iss[`CA53_FP_RF_RD_ADDR_W-1:1] == rf_wr_addr_fw1_f4[`CA53_FP_RF_WR_ADDR_W-1:1]};

  // Interlocking only needs to know if a compare between either the high or low portion of the
  // read-port matches a write address.  This compare is also timing critical so has a slightly
  // different logic cone from forwarding which needs to know exactly which compare has matched.
  //
  // Note that the read address applies to a 128-bit wide port while the write
  // address applies to a 64-bit wide port.
  function automatic fr_fw_where_ilock;
    input       addr_match;
    input       rd_addr0;
    input [1:0] rd_en;
    input       wr_addr0;
    input [3:0] wr_en;

    fr_fw_where_ilock = addr_match & ((rd_addr0 == wr_addr0) | (|wr_en[3:2])) & (|(rd_en & (wr_en[1:0] | {2{|wr_en[3:2]}})));
  endfunction

  function automatic fw_fw_where0;
    input       addr_match;
    input       rd_addr0;
    input [1:0] rd_en;
    input       wr_addr0;
    input [3:0] wr_en;

    fw_fw_where0 = addr_match & ((rd_addr0 == wr_addr0) | wr_en[2]) & rd_en[0] & (wr_en[0] | wr_en[2]);
  endfunction

  function automatic fw_fw_where1;
    input       addr_match;
    input       rd_addr0;
    input [1:0] rd_en;
    input       wr_addr0;
    input [3:0] wr_en;

    fw_fw_where1 = addr_match & ((rd_addr0 == wr_addr0) | wr_en[2]) & rd_en[1] & (wr_en[1] | wr_en[2]);
  endfunction

  function [3:0] fr_zero_where;
    input [3:0] fr_fw0_addr_match_iss;
    input [3:0] fr_fw1_addr_match_iss;
    input       early_rf_wr_en_fw0_f1;
    input       early_rf_wr_en_fw1_f1;
    input       early_rf_wr_en_fw0_f2;
    input       early_rf_wr_en_fw1_f2;
    input       early_rf_wr_en_fw0_f3;
    input       early_rf_wr_en_fw1_f3;
    input             rf_wr_en_fw0_f4;
    input             rf_wr_en_fw1_f4;

    fr_zero_where[3:0] = {((fr_fw0_addr_match_iss[3] & early_rf_wr_en_fw0_f1) |
                           (fr_fw1_addr_match_iss[3] & early_rf_wr_en_fw1_f1)),
                          ((fr_fw0_addr_match_iss[2] & early_rf_wr_en_fw0_f2) |
                           (fr_fw1_addr_match_iss[2] & early_rf_wr_en_fw1_f2)),
                          ((fr_fw0_addr_match_iss[1] & early_rf_wr_en_fw0_f3) |
                           (fr_fw1_addr_match_iss[1] & early_rf_wr_en_fw1_f3)),
                          ((fr_fw0_addr_match_iss[0] &       rf_wr_en_fw0_f4) |
                           (fr_fw1_addr_match_iss[0] &       rf_wr_en_fw1_f4))};
  endfunction

  function automatic fr_zero_available;
    input [3:0] fr_zero_where_iss;
    input [3:0] fr_fw0_where_iss;
    input [3:0] fr_fw1_where_iss;
    input       rf_rd_addr0_fr_f1;

    fr_zero_available = (fr_zero_where_iss[3] &   ~fr_fw0_where_iss[3]    &   ~fr_fw1_where_iss[3]    & rf_rd_addr0_fr_f1) |
                        (fr_zero_where_iss[2] & ~(|fr_fw0_where_iss[3:2]) & ~(|fr_fw1_where_iss[3:2]) & rf_rd_addr0_fr_f1) |
                        (fr_zero_where_iss[1] & ~(|fr_fw0_where_iss[3:1]) & ~(|fr_fw1_where_iss[3:1]) & rf_rd_addr0_fr_f1) |
                        (fr_zero_where_iss[0] & ~(|fr_fw0_where_iss[3:0]) & ~(|fr_fw1_where_iss[3:0]) & rf_rd_addr0_fr_f1);
  endfunction

  // FR0-FW0 "where" calculation
  assign early_fr0_fw0_where_iss = {fr_fw_where_ilock(fr0_fw0_addr_match[3], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1[3:0]),
                                    fr_fw_where_ilock(fr0_fw0_addr_match[2], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2[3:0]),
                                    fr_fw_where_ilock(fr0_fw0_addr_match[1], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3[3:0]),
                                    fr_fw_where_ilock(fr0_fw0_addr_match[0], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4[3:0])};

  assign fr0_fw0_where_iss[0] = {fw_fw_where0(fr0_fw0_addr_match[3], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1),
                                 fw_fw_where0(fr0_fw0_addr_match[2], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2),
                                 fw_fw_where0(fr0_fw0_addr_match[1], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3),
                                 fw_fw_where0(fr0_fw0_addr_match[0], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4)};

  assign fr0_fw0_where_iss[1] = {fw_fw_where1(fr0_fw0_addr_match[3], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1),
                                 fw_fw_where1(fr0_fw0_addr_match[2], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2),
                                 fw_fw_where1(fr0_fw0_addr_match[1], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3),
                                 fw_fw_where1(fr0_fw0_addr_match[0], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4)};

  // FR0-FW1 "where" calculation
  assign early_fr0_fw1_where_iss = {fr_fw_where_ilock(fr0_fw1_addr_match[3], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1[3:0]),
                                    fr_fw_where_ilock(fr0_fw1_addr_match[2], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2[3:0]),
                                    fr_fw_where_ilock(fr0_fw1_addr_match[1], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3[3:0]),
                                    fr_fw_where_ilock(fr0_fw1_addr_match[0], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4[3:0])};

  assign fr0_fw1_where_iss[0] = {fw_fw_where0(fr0_fw1_addr_match[3], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1),
                                 fw_fw_where0(fr0_fw1_addr_match[2], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2),
                                 fw_fw_where0(fr0_fw1_addr_match[1], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3),
                                 fw_fw_where0(fr0_fw1_addr_match[0], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4)};

  assign fr0_fw1_where_iss[1] = {fw_fw_where1(fr0_fw1_addr_match[3], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1),
                                 fw_fw_where1(fr0_fw1_addr_match[2], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2),
                                 fw_fw_where1(fr0_fw1_addr_match[1], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3),
                                 fw_fw_where1(fr0_fw1_addr_match[0], rf_rd_addr_fr0_iss[0], rf_rd_en_fr0_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4)};

  // FR0 Zero calculation for forwarding zeroes from AArch64 writes
  assign fr0_zero_where_iss[3:0] = fr_zero_where(fr0_fw0_addr_match[3:0],  fr0_fw1_addr_match[3:0],
                                                 early_rf_wr_en_fw0_f1[3], early_rf_wr_en_fw1_f1[3],
                                                 early_rf_wr_en_fw0_f2[3], early_rf_wr_en_fw1_f2[3],
                                                 early_rf_wr_en_fw0_f3[3], early_rf_wr_en_fw1_f3[3],
                                                       rf_wr_en_fw0_f4[3],       rf_wr_en_fw1_f4[3]);

  assign fr0_zero_available_iss[0] = fr_zero_available(fr0_zero_where_iss[3:0], fr0_fw0_where_iss[0][3:0], fr0_fw1_where_iss[0][3:0], rf_rd_addr_fr0_iss[0]);
  assign fr0_zero_available_iss[1] = fr_zero_available(fr0_zero_where_iss[3:0], fr0_fw0_where_iss[1][3:0], fr0_fw1_where_iss[1][3:0], 1'b1);

  // FR1-FW0 "where" calculation
  assign early_fr1_fw0_where_iss = {fr_fw_where_ilock(fr1_fw0_addr_match[3], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1[3:0]),
                                    fr_fw_where_ilock(fr1_fw0_addr_match[2], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2[3:0]),
                                    fr_fw_where_ilock(fr1_fw0_addr_match[1], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3[3:0]),
                                    fr_fw_where_ilock(fr1_fw0_addr_match[0], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4[3:0])};

  assign fr1_fw0_where_iss[0] = {fw_fw_where0(fr1_fw0_addr_match[3], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1),
                                 fw_fw_where0(fr1_fw0_addr_match[2], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2),
                                 fw_fw_where0(fr1_fw0_addr_match[1], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3),
                                 fw_fw_where0(fr1_fw0_addr_match[0], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4)};

  assign fr1_fw0_where_iss[1] = {fw_fw_where1(fr1_fw0_addr_match[3], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1),
                                 fw_fw_where1(fr1_fw0_addr_match[2], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2),
                                 fw_fw_where1(fr1_fw0_addr_match[1], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3),
                                 fw_fw_where1(fr1_fw0_addr_match[0], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4)};

  // FR1-FW1 "where" calculation
  assign early_fr1_fw1_where_iss = {fr_fw_where_ilock(fr1_fw1_addr_match[3], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1[3:0]),
                                    fr_fw_where_ilock(fr1_fw1_addr_match[2], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2[3:0]),
                                    fr_fw_where_ilock(fr1_fw1_addr_match[1], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3[3:0]),
                                    fr_fw_where_ilock(fr1_fw1_addr_match[0], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4[3:0])};

  assign fr1_fw1_where_iss[0] = {fw_fw_where0(fr1_fw1_addr_match[3], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1),
                                 fw_fw_where0(fr1_fw1_addr_match[2], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2),
                                 fw_fw_where0(fr1_fw1_addr_match[1], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3),
                                 fw_fw_where0(fr1_fw1_addr_match[0], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4)};

  assign fr1_fw1_where_iss[1] = {fw_fw_where1(fr1_fw1_addr_match[3], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1),
                                 fw_fw_where1(fr1_fw1_addr_match[2], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2),
                                 fw_fw_where1(fr1_fw1_addr_match[1], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3),
                                 fw_fw_where1(fr1_fw1_addr_match[0], rf_rd_addr_fr1_iss[0], rf_rd_en_fr1_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4)};

  // FR1 Zero calculation for forwarding zeroes from AArch64 writes
  assign fr1_zero_where_iss[3:0] = fr_zero_where(fr1_fw0_addr_match[3:0],  fr1_fw1_addr_match[3:0],
                                                 early_rf_wr_en_fw0_f1[3], early_rf_wr_en_fw1_f1[3],
                                                 early_rf_wr_en_fw0_f2[3], early_rf_wr_en_fw1_f2[3],
                                                 early_rf_wr_en_fw0_f3[3], early_rf_wr_en_fw1_f3[3],
                                                       rf_wr_en_fw0_f4[3],       rf_wr_en_fw1_f4[3]);

  assign fr1_zero_available_iss[0] = fr_zero_available(fr1_zero_where_iss[3:0], fr1_fw0_where_iss[0][3:0], fr1_fw1_where_iss[0][3:0], rf_rd_addr_fr1_iss[0]);
  assign fr1_zero_available_iss[1] = fr_zero_available(fr1_zero_where_iss[3:0], fr1_fw0_where_iss[1][3:0], fr1_fw1_where_iss[1][3:0], 1'b1);

  // FR2-FW0 "where" calculation
  assign early_fr2_fw0_where_iss = {fr_fw_where_ilock(fr2_fw0_addr_match[3], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1[3:0]),
                                    fr_fw_where_ilock(fr2_fw0_addr_match[2], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2[3:0]),
                                    fr_fw_where_ilock(fr2_fw0_addr_match[1], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3[3:0]),
                                    fr_fw_where_ilock(fr2_fw0_addr_match[0], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4[3:0])};

  assign fr2_fw0_where_iss[0] = {fw_fw_where0(fr2_fw0_addr_match[3], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1),
                                 fw_fw_where0(fr2_fw0_addr_match[2], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2),
                                 fw_fw_where0(fr2_fw0_addr_match[1], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3),
                                 fw_fw_where0(fr2_fw0_addr_match[0], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4)};

  assign fr2_fw0_where_iss[1] = {fw_fw_where1(fr2_fw0_addr_match[3], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1),
                                 fw_fw_where1(fr2_fw0_addr_match[2], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2),
                                 fw_fw_where1(fr2_fw0_addr_match[1], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3),
                                 fw_fw_where1(fr2_fw0_addr_match[0], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4)};

  // FR2-FW1 "where" calculation
  assign early_fr2_fw1_where_iss = {fr_fw_where_ilock(fr2_fw1_addr_match[3], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1[3:0]),
                                    fr_fw_where_ilock(fr2_fw1_addr_match[2], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2[3:0]),
                                    fr_fw_where_ilock(fr2_fw1_addr_match[1], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3[3:0]),
                                    fr_fw_where_ilock(fr2_fw1_addr_match[0], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4[3:0])};

  assign fr2_fw1_where_iss[0] = {fw_fw_where0(fr2_fw1_addr_match[3], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1),
                                 fw_fw_where0(fr2_fw1_addr_match[2], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2),
                                 fw_fw_where0(fr2_fw1_addr_match[1], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3),
                                 fw_fw_where0(fr2_fw1_addr_match[0], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4)};

  assign fr2_fw1_where_iss[1] = {fw_fw_where1(fr2_fw1_addr_match[3], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1),
                                 fw_fw_where1(fr2_fw1_addr_match[2], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2),
                                 fw_fw_where1(fr2_fw1_addr_match[1], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3),
                                 fw_fw_where1(fr2_fw1_addr_match[0], rf_rd_addr_fr2_iss[0], rf_rd_en_fr2_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4)};

  // FR2 Zero calculation for forwarding zeroes from AArch64 writes
  assign fr2_zero_where_iss[3:0] = fr_zero_where(fr2_fw0_addr_match[3:0],  fr2_fw1_addr_match[3:0],
                                                 early_rf_wr_en_fw0_f1[3], early_rf_wr_en_fw1_f1[3],
                                                 early_rf_wr_en_fw0_f2[3], early_rf_wr_en_fw1_f2[3],
                                                 early_rf_wr_en_fw0_f3[3], early_rf_wr_en_fw1_f3[3],
                                                       rf_wr_en_fw0_f4[3],       rf_wr_en_fw1_f4[3]);

  assign fr2_zero_available_iss[0] = fr_zero_available(fr2_zero_where_iss[3:0], fr2_fw0_where_iss[0][3:0], fr2_fw1_where_iss[0][3:0], rf_rd_addr_fr2_iss[0]);
  assign fr2_zero_available_iss[1] = fr_zero_available(fr2_zero_where_iss[3:0], fr2_fw0_where_iss[1][3:0], fr2_fw1_where_iss[1][3:0], 1'b1);

  // FR3-FW0 "where" calculation
  assign early_fr3_fw0_where_iss = {fr_fw_where_ilock(fr3_fw0_addr_match[3], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1[3:0]),
                                    fr_fw_where_ilock(fr3_fw0_addr_match[2], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2[3:0]),
                                    fr_fw_where_ilock(fr3_fw0_addr_match[1], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3[3:0]),
                                    fr_fw_where_ilock(fr3_fw0_addr_match[0], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4[3:0])};

  assign fr3_fw0_where_iss[0] = {fw_fw_where0(fr3_fw0_addr_match[3], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1),
                                 fw_fw_where0(fr3_fw0_addr_match[2], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2),
                                 fw_fw_where0(fr3_fw0_addr_match[1], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3),
                                 fw_fw_where0(fr3_fw0_addr_match[0], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4)};

  assign fr3_fw0_where_iss[1] = {fw_fw_where1(fr3_fw0_addr_match[3], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1),
                                 fw_fw_where1(fr3_fw0_addr_match[2], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2),
                                 fw_fw_where1(fr3_fw0_addr_match[1], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3),
                                 fw_fw_where1(fr3_fw0_addr_match[0], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4)};

  // FR3-FW1 "where" calculation
  assign early_fr3_fw1_where_iss = {fr_fw_where_ilock(fr3_fw1_addr_match[3], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1[3:0]),
                                    fr_fw_where_ilock(fr3_fw1_addr_match[2], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2[3:0]),
                                    fr_fw_where_ilock(fr3_fw1_addr_match[1], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3[3:0]),
                                    fr_fw_where_ilock(fr3_fw1_addr_match[0], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4[3:0])};

  assign fr3_fw1_where_iss[0] = {fw_fw_where0(fr3_fw1_addr_match[3], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1),
                                 fw_fw_where0(fr3_fw1_addr_match[2], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2),
                                 fw_fw_where0(fr3_fw1_addr_match[1], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3),
                                 fw_fw_where0(fr3_fw1_addr_match[0], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4)};

  assign fr3_fw1_where_iss[1] = {fw_fw_where1(fr3_fw1_addr_match[3], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1),
                                 fw_fw_where1(fr3_fw1_addr_match[2], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2),
                                 fw_fw_where1(fr3_fw1_addr_match[1], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3),
                                 fw_fw_where1(fr3_fw1_addr_match[0], rf_rd_addr_fr3_iss[0], rf_rd_en_fr3_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4)};

  // FR3 Zero calculation for forwarding zeroes from AArch64 writes
  assign fr3_zero_where_iss[3:0] = fr_zero_where(fr3_fw0_addr_match[3:0],  fr3_fw1_addr_match[3:0],
                                                 early_rf_wr_en_fw0_f1[3], early_rf_wr_en_fw1_f1[3],
                                                 early_rf_wr_en_fw0_f2[3], early_rf_wr_en_fw1_f2[3],
                                                 early_rf_wr_en_fw0_f3[3], early_rf_wr_en_fw1_f3[3],
                                                       rf_wr_en_fw0_f4[3],       rf_wr_en_fw1_f4[3]);

  assign fr3_zero_available_iss[0] = fr_zero_available(fr3_zero_where_iss[3:0], fr3_fw0_where_iss[0][3:0], fr3_fw1_where_iss[0][3:0], rf_rd_addr_fr3_iss[0]);
  assign fr3_zero_available_iss[1] = fr_zero_available(fr3_zero_where_iss[3:0], fr3_fw0_where_iss[1][3:0], fr3_fw1_where_iss[1][3:0], 1'b1);

  // FR4-FW0 "where" calculation
  assign early_fr4_fw0_where_iss = {fr_fw_where_ilock(fr4_fw0_addr_match[3], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1[3:0]),
                                    fr_fw_where_ilock(fr4_fw0_addr_match[2], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2[3:0]),
                                    fr_fw_where_ilock(fr4_fw0_addr_match[1], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3[3:0]),
                                    fr_fw_where_ilock(fr4_fw0_addr_match[0], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4[3:0])};

  assign fr4_fw0_where_iss[0] = {fw_fw_where0(fr4_fw0_addr_match[3], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1),
                                 fw_fw_where0(fr4_fw0_addr_match[2], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2),
                                 fw_fw_where0(fr4_fw0_addr_match[1], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3),
                                 fw_fw_where0(fr4_fw0_addr_match[0], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4)};

  assign fr4_fw0_where_iss[1] = {fw_fw_where1(fr4_fw0_addr_match[3], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1),
                                 fw_fw_where1(fr4_fw0_addr_match[2], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2),
                                 fw_fw_where1(fr4_fw0_addr_match[1], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3),
                                 fw_fw_where1(fr4_fw0_addr_match[0], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4)};

  // FR4-FW1 "where" calculation
  assign early_fr4_fw1_where_iss = {fr_fw_where_ilock(fr4_fw1_addr_match[3], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1[3:0]),
                                    fr_fw_where_ilock(fr4_fw1_addr_match[2], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2[3:0]),
                                    fr_fw_where_ilock(fr4_fw1_addr_match[1], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3[3:0]),
                                    fr_fw_where_ilock(fr4_fw1_addr_match[0], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4[3:0])};

  assign fr4_fw1_where_iss[0] = {fw_fw_where0(fr4_fw1_addr_match[3], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1),
                                 fw_fw_where0(fr4_fw1_addr_match[2], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2),
                                 fw_fw_where0(fr4_fw1_addr_match[1], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3),
                                 fw_fw_where0(fr4_fw1_addr_match[0], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4)};

  assign fr4_fw1_where_iss[1] = {fw_fw_where1(fr4_fw1_addr_match[3], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1),
                                 fw_fw_where1(fr4_fw1_addr_match[2], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2),
                                 fw_fw_where1(fr4_fw1_addr_match[1], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3),
                                 fw_fw_where1(fr4_fw1_addr_match[0], rf_rd_addr_fr4_iss[0], rf_rd_en_fr4_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4)};

  // FR4 Zero calculation for forwarding zeroes from AArch64 writes
  assign fr4_zero_where_iss[3:0] = fr_zero_where(fr4_fw0_addr_match[3:0],  fr4_fw1_addr_match[3:0],
                                                 early_rf_wr_en_fw0_f1[3], early_rf_wr_en_fw1_f1[3],
                                                 early_rf_wr_en_fw0_f2[3], early_rf_wr_en_fw1_f2[3],
                                                 early_rf_wr_en_fw0_f3[3], early_rf_wr_en_fw1_f3[3],
                                                       rf_wr_en_fw0_f4[3],       rf_wr_en_fw1_f4[3]);

  assign fr4_zero_available_iss[0] = fr_zero_available(fr4_zero_where_iss[3:0], fr4_fw0_where_iss[0][3:0], fr4_fw1_where_iss[0][3:0], rf_rd_addr_fr4_iss[0]);
  assign fr4_zero_available_iss[1] = fr_zero_available(fr4_zero_where_iss[3:0], fr4_fw0_where_iss[1][3:0], fr4_fw1_where_iss[1][3:0], 1'b1);

  // FR5-FW0 "where" calculation
  assign early_fr5_fw0_where_iss = {fr_fw_where_ilock(fr5_fw0_addr_match[3], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1[3:0]),
                                    fr_fw_where_ilock(fr5_fw0_addr_match[2], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2[3:0]),
                                    fr_fw_where_ilock(fr5_fw0_addr_match[1], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3[3:0]),
                                    fr_fw_where_ilock(fr5_fw0_addr_match[0], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4[3:0])};

  assign fr5_fw0_where_iss[0] = {fw_fw_where0(fr5_fw0_addr_match[3], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1),
                                 fw_fw_where0(fr5_fw0_addr_match[2], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2),
                                 fw_fw_where0(fr5_fw0_addr_match[1], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3),
                                 fw_fw_where0(fr5_fw0_addr_match[0], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4)};

  assign fr5_fw0_where_iss[1] = {fw_fw_where1(fr5_fw0_addr_match[3], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw0_f1[0], early_rf_wr_en_fw0_f1),
                                 fw_fw_where1(fr5_fw0_addr_match[2], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw0_f2[0], early_rf_wr_en_fw0_f2),
                                 fw_fw_where1(fr5_fw0_addr_match[1], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw0_f3[0], early_rf_wr_en_fw0_f3),
                                 fw_fw_where1(fr5_fw0_addr_match[0], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw0_f4[0],       rf_wr_en_fw0_f4)};

  // FR5-FW1 "where" calculation
  assign early_fr5_fw1_where_iss = {fr_fw_where_ilock(fr5_fw1_addr_match[3], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1[3:0]),
                                    fr_fw_where_ilock(fr5_fw1_addr_match[2], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2[3:0]),
                                    fr_fw_where_ilock(fr5_fw1_addr_match[1], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3[3:0]),
                                    fr_fw_where_ilock(fr5_fw1_addr_match[0], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4[3:0])};

  assign fr5_fw1_where_iss[0] = {fw_fw_where0(fr5_fw1_addr_match[3], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1),
                                 fw_fw_where0(fr5_fw1_addr_match[2], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2),
                                 fw_fw_where0(fr5_fw1_addr_match[1], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3),
                                 fw_fw_where0(fr5_fw1_addr_match[0], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4)};

  assign fr5_fw1_where_iss[1] = {fw_fw_where1(fr5_fw1_addr_match[3], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw1_f1[0], early_rf_wr_en_fw1_f1),
                                 fw_fw_where1(fr5_fw1_addr_match[2], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw1_f2[0], early_rf_wr_en_fw1_f2),
                                 fw_fw_where1(fr5_fw1_addr_match[1], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw1_f3[0], early_rf_wr_en_fw1_f3),
                                 fw_fw_where1(fr5_fw1_addr_match[0], rf_rd_addr_fr5_iss[0], rf_rd_en_fr5_iss, rf_wr_addr_fw1_f4[0],       rf_wr_en_fw1_f4)};

  // FR5 Zero calculation for forwarding zeroes from AArch64 writes
  assign fr5_zero_where_iss[3:0] = fr_zero_where(fr5_fw0_addr_match[3:0],  fr5_fw1_addr_match[3:0],
                                                 early_rf_wr_en_fw0_f1[3], early_rf_wr_en_fw1_f1[3],
                                                 early_rf_wr_en_fw0_f2[3], early_rf_wr_en_fw1_f2[3],
                                                 early_rf_wr_en_fw0_f3[3], early_rf_wr_en_fw1_f3[3],
                                                       rf_wr_en_fw0_f4[3],       rf_wr_en_fw1_f4[3]);

  assign fr5_zero_available_iss[0] = fr_zero_available(fr5_zero_where_iss[3:0], fr5_fw0_where_iss[0][3:0], fr5_fw1_where_iss[0][3:0], rf_rd_addr_fr5_iss[0]);
  assign fr5_zero_available_iss[1] = fr_zero_available(fr5_zero_where_iss[3:0], fr5_fw0_where_iss[1][3:0], fr5_fw1_where_iss[1][3:0], 1'b1);

  function fwd_from_f3 (input [2:0] fwd_ctl);
    fwd_from_f3 = (fwd_ctl == `CA53_FWD_FW0_F3) |
                  (fwd_ctl == `CA53_FWD_FW1_F3) |
                  (fwd_ctl == `CA53_FWD_ZERO);
  endfunction

  function fwd_from_f3_f4 (input [2:0] fwd_ctl);
    fwd_from_f3_f4 = (fwd_ctl == `CA53_FWD_FW0_F3) |
                     (fwd_ctl == `CA53_FWD_FW1_F3) |
                     (fwd_ctl == `CA53_FWD_FW0_F4) |
                     (fwd_ctl == `CA53_FWD_FW1_F4) |
                     (fwd_ctl == `CA53_FWD_ZERO);
  endfunction


  // FPU 'where' signals for the F2 stage
  // If we have forwarded into F1 from F3/F4 then do not propagate the 'where' signal into F2 that
  // says we should forward into F2 from F4/F5.
  assign nxt_fr0_fw0_where_f2[0] = fr0_fw0_where_f1[0][2:0] & {1'b1, ~fwd_from_f3(fr0_fwd_ex1_o[ 2: 0]), ~fwd_from_f3_f4(fr0_fwd_ex1_o[ 2: 0]) };
  assign nxt_fr0_fw0_where_f2[1] = fr0_fw0_where_f1[1][2:0] & {1'b1, ~fwd_from_f3(fr0_fwd_ex1_o[ 5: 3]), ~fwd_from_f3_f4(fr0_fwd_ex1_o[ 5: 3]) };
  assign nxt_fr0_fw1_where_f2[0] = fr0_fw1_where_f1[0][2:0] & {1'b1, ~fwd_from_f3(fr0_fwd_ex1_o[ 2: 0]), ~fwd_from_f3_f4(fr0_fwd_ex1_o[ 2: 0]) };
  assign nxt_fr0_fw1_where_f2[1] = fr0_fw1_where_f1[1][2:0] & {1'b1, ~fwd_from_f3(fr0_fwd_ex1_o[ 5: 3]), ~fwd_from_f3_f4(fr0_fwd_ex1_o[ 5: 3]) };

  assign nxt_fr1_fw0_where_f2[0] = fr1_fw0_where_f1[0][2:0] & {1'b1, ~fwd_from_f3(fr1_fwd_ex1_o[ 2: 0]), ~fwd_from_f3_f4(fr1_fwd_ex1_o[ 2: 0]) };
  assign nxt_fr1_fw0_where_f2[1] = fr1_fw0_where_f1[1][2:0] & {1'b1, ~fwd_from_f3(fr1_fwd_ex1_o[ 5: 3]), ~fwd_from_f3_f4(fr1_fwd_ex1_o[ 5: 3]) };
  assign nxt_fr1_fw1_where_f2[0] = fr1_fw1_where_f1[0][2:0] & {1'b1, ~fwd_from_f3(fr1_fwd_ex1_o[ 2: 0]), ~fwd_from_f3_f4(fr1_fwd_ex1_o[ 2: 0]) };
  assign nxt_fr1_fw1_where_f2[1] = fr1_fw1_where_f1[1][2:0] & {1'b1, ~fwd_from_f3(fr1_fwd_ex1_o[ 5: 3]), ~fwd_from_f3_f4(fr1_fwd_ex1_o[ 5: 3]) };

  assign nxt_fr2_fw0_where_f2[0] = fr2_fw0_where_f1[0][2:0] & {1'b1, ~fwd_from_f3(fr2_fwd_ex1_o[ 2: 0]), ~fwd_from_f3_f4(fr2_fwd_ex1_o[ 2: 0]) };
  assign nxt_fr2_fw0_where_f2[1] = fr2_fw0_where_f1[1][2:0] & {1'b1, ~fwd_from_f3(fr2_fwd_ex1_o[ 5: 3]), ~fwd_from_f3_f4(fr2_fwd_ex1_o[ 5: 3]) };
  assign nxt_fr2_fw1_where_f2[0] = fr2_fw1_where_f1[0][2:0] & {1'b1, ~fwd_from_f3(fr2_fwd_ex1_o[ 2: 0]), ~fwd_from_f3_f4(fr2_fwd_ex1_o[ 2: 0]) };
  assign nxt_fr2_fw1_where_f2[1] = fr2_fw1_where_f1[1][2:0] & {1'b1, ~fwd_from_f3(fr2_fwd_ex1_o[ 5: 3]), ~fwd_from_f3_f4(fr2_fwd_ex1_o[ 5: 3]) };

  assign nxt_fr3_fw0_where_f2[0] = fr3_fw0_where_f1[0][2:0] & {1'b1, ~fwd_from_f3(fr3_fwd_ex1_o[ 2: 0]), ~fwd_from_f3_f4(fr3_fwd_ex1_o[ 2: 0]) };
  assign nxt_fr3_fw0_where_f2[1] = fr3_fw0_where_f1[1][2:0] & {1'b1, ~fwd_from_f3(fr3_fwd_ex1_o[ 5: 3]), ~fwd_from_f3_f4(fr3_fwd_ex1_o[ 5: 3]) };
  assign nxt_fr3_fw1_where_f2[0] = fr3_fw1_where_f1[0][2:0] & {1'b1, ~fwd_from_f3(fr3_fwd_ex1_o[ 2: 0]), ~fwd_from_f3_f4(fr3_fwd_ex1_o[ 2: 0]) };
  assign nxt_fr3_fw1_where_f2[1] = fr3_fw1_where_f1[1][2:0] & {1'b1, ~fwd_from_f3(fr3_fwd_ex1_o[ 5: 3]), ~fwd_from_f3_f4(fr3_fwd_ex1_o[ 5: 3]) };

  assign nxt_fr4_fw0_where_f2[0] = fr4_fw0_where_f1[0][2:0] & {1'b1, ~fwd_from_f3(fr4_fwd_ex1_o[ 2: 0]), ~fwd_from_f3_f4(fr4_fwd_ex1_o[ 2: 0]) };
  assign nxt_fr4_fw0_where_f2[1] = fr4_fw0_where_f1[1][2:0] & {1'b1, ~fwd_from_f3(fr4_fwd_ex1_o[ 5: 3]), ~fwd_from_f3_f4(fr4_fwd_ex1_o[ 5: 3]) };
  assign nxt_fr4_fw1_where_f2[0] = fr4_fw1_where_f1[0][2:0] & {1'b1, ~fwd_from_f3(fr4_fwd_ex1_o[ 2: 0]), ~fwd_from_f3_f4(fr4_fwd_ex1_o[ 2: 0]) };
  assign nxt_fr4_fw1_where_f2[1] = fr4_fw1_where_f1[1][2:0] & {1'b1, ~fwd_from_f3(fr4_fwd_ex1_o[ 5: 3]), ~fwd_from_f3_f4(fr4_fwd_ex1_o[ 5: 3]) };

  assign nxt_fr5_fw0_where_f2[0] = fr5_fw0_where_f1[0][2:0] & {1'b1, ~fwd_from_f3(fr5_fwd_ex1_o[ 2: 0]), ~fwd_from_f3_f4(fr5_fwd_ex1_o[ 2: 0]) };
  assign nxt_fr5_fw0_where_f2[1] = fr5_fw0_where_f1[1][2:0] & {1'b1, ~fwd_from_f3(fr5_fwd_ex1_o[ 5: 3]), ~fwd_from_f3_f4(fr5_fwd_ex1_o[ 5: 3]) };
  assign nxt_fr5_fw1_where_f2[0] = fr5_fw1_where_f1[0][2:0] & {1'b1, ~fwd_from_f3(fr5_fwd_ex1_o[ 2: 0]), ~fwd_from_f3_f4(fr5_fwd_ex1_o[ 2: 0]) };
  assign nxt_fr5_fw1_where_f2[1] = fr5_fw1_where_f1[1][2:0] & {1'b1, ~fwd_from_f3(fr5_fwd_ex1_o[ 5: 3]), ~fwd_from_f3_f4(fr5_fwd_ex1_o[ 5: 3]) };

  // Ready signals for FPU forwarding
  //
  // The ready signals for the FPU pipeline are encoded slightly
  // differently from the integer pipeline:
  //
  // ~rf_wr_when_fw0_f3[0] & rf_wr_en_fw0_wr = 1 => Forward from F3
  // ~rf_wr_when_fw0_f4[1] & rf_wr_en_fw0_f4 = 1 => Forward from F4
  //                         rf_wr_en_fw0_f5 = 1 => Forward from F5
  //
  // The rf_wr_valid_fw*_f5 signal is generated from the write enable in F4,
  // but is seperate because the write enable in F5 should be asserted for
  // a single cycle regardless of any stall signals.  However the data in F5
  // will be available for forwarding for longer if a stall has been asserted
  // so we can not use the rf_wr_en_fw*_f5 signal for signalling ready.
  assign fw0_lo_ready_mask_iss = {~rf_wr_when_fw0_f2[0] &     rf_wr_en_fw0_f2[0],
                                  ~rf_wr_when_fw0_f3[1] & raw_rf_wr_en_fw0_f3[0],
                                                          raw_rf_wr_en_fw0_f4[0]};

  assign fw0_hi_ready_mask_iss = {~rf_wr_when_fw0_f2[0] &     rf_wr_en_fw0_f2[1],
                                  ~rf_wr_when_fw0_f3[1] & raw_rf_wr_en_fw0_f3[1],
                                                          raw_rf_wr_en_fw0_f4[1]};

  assign fw1_lo_ready_mask_iss = {~rf_wr_when_fw1_f2[0] &     rf_wr_en_fw1_f2[0],
                                  ~rf_wr_when_fw1_f3[1] & raw_rf_wr_en_fw1_f3[0],
                                                          raw_rf_wr_en_fw1_f4[0]};

  assign fw1_hi_ready_mask_iss = {~rf_wr_when_fw1_f2[0] &     rf_wr_en_fw1_f2[1],
                                  ~rf_wr_when_fw1_f3[1] & raw_rf_wr_en_fw1_f3[1],
                                                          raw_rf_wr_en_fw1_f4[1]};

  assign fw0_lo_ready_mask_f2 = {~rf_wr_when_fw0_f3[0] & raw_rf_wr_en_fw0_f3[0],
                                 ~rf_wr_when_fw0_f4[1] & raw_rf_wr_en_fw0_f4[0],
                                                         rf_wr_valid_fw0_f5[0]};

  assign fw0_hi_ready_mask_f2 = {~rf_wr_when_fw0_f3[0] & raw_rf_wr_en_fw0_f3[1],
                                 ~rf_wr_when_fw0_f4[1] & raw_rf_wr_en_fw0_f4[1],
                                                         rf_wr_valid_fw0_f5[1]};

  assign fw1_lo_ready_mask_f2 = {~rf_wr_when_fw1_f3[0] & raw_rf_wr_en_fw1_f3[0],
                                 ~rf_wr_when_fw1_f4[1] & raw_rf_wr_en_fw1_f4[0],
                                                         rf_wr_valid_fw1_f5[0]};

  assign fw1_hi_ready_mask_f2 = {~rf_wr_when_fw1_f3[0] & raw_rf_wr_en_fw1_f3[1],
                                 ~rf_wr_when_fw1_f4[1] & raw_rf_wr_en_fw1_f4[1],
                                                         rf_wr_valid_fw1_f5[1]};

  // Available signals for FPU forwarding in F1 - Generated in Iss and pipelined
  assign fr0_fw0_available_iss[0] = fr0_fw0_where_iss[0][2:0] & fw0_lo_ready_mask_iss;
  assign fr0_fw1_available_iss[0] = fr0_fw1_where_iss[0][2:0] & fw1_lo_ready_mask_iss;
  assign fr0_fw0_available_iss[1] = fr0_fw0_where_iss[1][2:0] & fw0_hi_ready_mask_iss;
  assign fr0_fw1_available_iss[1] = fr0_fw1_where_iss[1][2:0] & fw1_hi_ready_mask_iss;
  assign fr1_fw0_available_iss[0] = fr1_fw0_where_iss[0][2:0] & fw0_lo_ready_mask_iss;
  assign fr1_fw1_available_iss[0] = fr1_fw1_where_iss[0][2:0] & fw1_lo_ready_mask_iss;
  assign fr1_fw0_available_iss[1] = fr1_fw0_where_iss[1][2:0] & fw0_hi_ready_mask_iss;
  assign fr1_fw1_available_iss[1] = fr1_fw1_where_iss[1][2:0] & fw1_hi_ready_mask_iss;
  assign fr2_fw0_available_iss[0] = fr2_fw0_where_iss[0][2:0] & fw0_lo_ready_mask_iss;
  assign fr2_fw1_available_iss[0] = fr2_fw1_where_iss[0][2:0] & fw1_lo_ready_mask_iss;
  assign fr2_fw0_available_iss[1] = fr2_fw0_where_iss[1][2:0] & fw0_hi_ready_mask_iss;
  assign fr2_fw1_available_iss[1] = fr2_fw1_where_iss[1][2:0] & fw1_hi_ready_mask_iss;
  assign fr3_fw0_available_iss[0] = fr3_fw0_where_iss[0][2:0] & fw0_lo_ready_mask_iss;
  assign fr3_fw1_available_iss[0] = fr3_fw1_where_iss[0][2:0] & fw1_lo_ready_mask_iss;
  assign fr3_fw0_available_iss[1] = fr3_fw0_where_iss[1][2:0] & fw0_hi_ready_mask_iss;
  assign fr3_fw1_available_iss[1] = fr3_fw1_where_iss[1][2:0] & fw1_hi_ready_mask_iss;
  assign fr4_fw0_available_iss[0] = fr4_fw0_where_iss[0][2:0] & fw0_lo_ready_mask_iss;
  assign fr4_fw1_available_iss[0] = fr4_fw1_where_iss[0][2:0] & fw1_lo_ready_mask_iss;
  assign fr4_fw0_available_iss[1] = fr4_fw0_where_iss[1][2:0] & fw0_hi_ready_mask_iss;
  assign fr4_fw1_available_iss[1] = fr4_fw1_where_iss[1][2:0] & fw1_hi_ready_mask_iss;
  assign fr5_fw0_available_iss[0] = fr5_fw0_where_iss[0][2:0] & fw0_lo_ready_mask_iss;
  assign fr5_fw1_available_iss[0] = fr5_fw1_where_iss[0][2:0] & fw1_lo_ready_mask_iss;
  assign fr5_fw0_available_iss[1] = fr5_fw0_where_iss[1][2:0] & fw0_hi_ready_mask_iss;
  assign fr5_fw1_available_iss[1] = fr5_fw1_where_iss[1][2:0] & fw1_hi_ready_mask_iss;

  // Available signals for FPU forwarding in F2
  assign fr0_fw0_available_f2[0] = fr0_fw0_where_f2[0][2:0] & fw0_lo_ready_mask_f2;
  assign fr0_fw1_available_f2[0] = fr0_fw1_where_f2[0][2:0] & fw1_lo_ready_mask_f2;
  assign fr0_fw0_available_f2[1] = fr0_fw0_where_f2[1][2:0] & fw0_hi_ready_mask_f2;
  assign fr0_fw1_available_f2[1] = fr0_fw1_where_f2[1][2:0] & fw1_hi_ready_mask_f2;

  assign fr1_fw0_available_f2[0] = fr1_fw0_where_f2[0][2:0] & fw0_lo_ready_mask_f2;
  assign fr1_fw1_available_f2[0] = fr1_fw1_where_f2[0][2:0] & fw1_lo_ready_mask_f2;
  assign fr1_fw0_available_f2[1] = fr1_fw0_where_f2[1][2:0] & fw0_hi_ready_mask_f2;
  assign fr1_fw1_available_f2[1] = fr1_fw1_where_f2[1][2:0] & fw1_hi_ready_mask_f2;

  assign fr2_fw0_available_f2[0] = fr2_fw0_where_f2[0][2:0] & fw0_lo_ready_mask_f2;
  assign fr2_fw1_available_f2[0] = fr2_fw1_where_f2[0][2:0] & fw1_lo_ready_mask_f2;
  assign fr2_fw0_available_f2[1] = fr2_fw0_where_f2[1][2:0] & fw0_hi_ready_mask_f2;
  assign fr2_fw1_available_f2[1] = fr2_fw1_where_f2[1][2:0] & fw1_hi_ready_mask_f2;

  assign fr3_fw0_available_f2[0] = fr3_fw0_where_f2[0][2:0] & fw0_lo_ready_mask_f2;
  assign fr3_fw1_available_f2[0] = fr3_fw1_where_f2[0][2:0] & fw1_lo_ready_mask_f2;
  assign fr3_fw0_available_f2[1] = fr3_fw0_where_f2[1][2:0] & fw0_hi_ready_mask_f2;
  assign fr3_fw1_available_f2[1] = fr3_fw1_where_f2[1][2:0] & fw1_hi_ready_mask_f2;

  assign fr4_fw0_available_f2[0] = fr4_fw0_where_f2[0][2:0] & fw0_lo_ready_mask_f2;
  assign fr4_fw1_available_f2[0] = fr4_fw1_where_f2[0][2:0] & fw1_lo_ready_mask_f2;
  assign fr4_fw0_available_f2[1] = fr4_fw0_where_f2[1][2:0] & fw0_hi_ready_mask_f2;
  assign fr4_fw1_available_f2[1] = fr4_fw1_where_f2[1][2:0] & fw1_hi_ready_mask_f2;

  assign fr5_fw0_available_f2[0] = fr5_fw0_where_f2[0][2:0] & fw0_lo_ready_mask_f2;
  assign fr5_fw1_available_f2[0] = fr5_fw1_where_f2[0][2:0] & fw1_lo_ready_mask_f2;
  assign fr5_fw0_available_f2[1] = fr5_fw0_where_f2[1][2:0] & fw0_hi_ready_mask_f2;
  assign fr5_fw1_available_f2[1] = fr5_fw1_where_f2[1][2:0] & fw1_hi_ready_mask_f2;

  // ------------------------------------------------------
  // FPU forwarding controls for F1 forwarding
  // ------------------------------------------------------

  // These signals control the mux for F5, F4 and F3 to F1 forwarding

  assign fr0_fwd_ex1_o[ 2: 0] = (fr0_zero_available_f1[0])   ? `CA53_FWD_ZERO   :
                                (fr0_fw0_available_f1[0][2]) ? `CA53_FWD_FW0_F3 :
                                (fr0_fw1_available_f1[0][2]) ? `CA53_FWD_FW1_F3 :
                                (fr0_fw0_available_f1[0][1]) ? `CA53_FWD_FW0_F4 :
                                (fr0_fw1_available_f1[0][1]) ? `CA53_FWD_FW1_F4 :
                                (fr0_fw0_available_f1[0][0]) ? `CA53_FWD_FW0_F5 :
                                (fr0_fw1_available_f1[0][0]) ? `CA53_FWD_FW1_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr0_fwd_ex1_o[ 5: 3] = (fr0_zero_available_f1[1])   ? `CA53_FWD_ZERO   :
                                (fr0_fw0_available_f1[1][2]) ? `CA53_FWD_FW0_F3 :
                                (fr0_fw1_available_f1[1][2]) ? `CA53_FWD_FW1_F3 :
                                (fr0_fw0_available_f1[1][1]) ? `CA53_FWD_FW0_F4 :
                                (fr0_fw1_available_f1[1][1]) ? `CA53_FWD_FW1_F4 :
                                (fr0_fw0_available_f1[1][0]) ? `CA53_FWD_FW0_F5 :
                                (fr0_fw1_available_f1[1][0]) ? `CA53_FWD_FW1_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr1_fwd_ex1_o[ 2: 0] = (fr1_zero_available_f1[0])   ? `CA53_FWD_ZERO   :
                                (fr1_fw0_available_f1[0][2]) ? `CA53_FWD_FW0_F3 :
                                (fr1_fw1_available_f1[0][2]) ? `CA53_FWD_FW1_F3 :
                                (fr1_fw0_available_f1[0][1]) ? `CA53_FWD_FW0_F4 :
                                (fr1_fw1_available_f1[0][1]) ? `CA53_FWD_FW1_F4 :
                                (fr1_fw0_available_f1[0][0]) ? `CA53_FWD_FW0_F5 :
                                (fr1_fw1_available_f1[0][0]) ? `CA53_FWD_FW1_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr1_fwd_ex1_o[ 5: 3] = (fr1_zero_available_f1[1])   ? `CA53_FWD_ZERO   :
                                (fr1_fw0_available_f1[1][2]) ? `CA53_FWD_FW0_F3 :
                                (fr1_fw1_available_f1[1][2]) ? `CA53_FWD_FW1_F3 :
                                (fr1_fw0_available_f1[1][1]) ? `CA53_FWD_FW0_F4 :
                                (fr1_fw1_available_f1[1][1]) ? `CA53_FWD_FW1_F4 :
                                (fr1_fw0_available_f1[1][0]) ? `CA53_FWD_FW0_F5 :
                                (fr1_fw1_available_f1[1][0]) ? `CA53_FWD_FW1_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr2_fwd_ex1_o[ 2: 0] = (fr2_zero_available_f1[0])   ? `CA53_FWD_ZERO   :
                                (fr2_fw0_available_f1[0][2]) ? `CA53_FWD_FW0_F3 :
                                (fr2_fw1_available_f1[0][2]) ? `CA53_FWD_FW1_F3 :
                                (fr2_fw0_available_f1[0][1]) ? `CA53_FWD_FW0_F4 :
                                (fr2_fw1_available_f1[0][1]) ? `CA53_FWD_FW1_F4 :
                                (fr2_fw0_available_f1[0][0]) ? `CA53_FWD_FW0_F5 :
                                (fr2_fw1_available_f1[0][0]) ? `CA53_FWD_FW1_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr2_fwd_ex1_o[ 5: 3] = (fr2_zero_available_f1[1])   ? `CA53_FWD_ZERO   :
                                (fr2_fw0_available_f1[1][2]) ? `CA53_FWD_FW0_F3 :
                                (fr2_fw1_available_f1[1][2]) ? `CA53_FWD_FW1_F3 :
                                (fr2_fw0_available_f1[1][1]) ? `CA53_FWD_FW0_F4 :
                                (fr2_fw1_available_f1[1][1]) ? `CA53_FWD_FW1_F4 :
                                (fr2_fw0_available_f1[1][0]) ? `CA53_FWD_FW0_F5 :
                                (fr2_fw1_available_f1[1][0]) ? `CA53_FWD_FW1_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr3_fwd_ex1_o[ 2: 0] = (fr3_zero_available_f1[0])   ? `CA53_FWD_ZERO   :
                                (fr3_fw0_available_f1[0][2]) ? `CA53_FWD_FW0_F3 :
                                (fr3_fw1_available_f1[0][2]) ? `CA53_FWD_FW1_F3 :
                                (fr3_fw0_available_f1[0][1]) ? `CA53_FWD_FW0_F4 :
                                (fr3_fw1_available_f1[0][1]) ? `CA53_FWD_FW1_F4 :
                                (fr3_fw0_available_f1[0][0]) ? `CA53_FWD_FW0_F5 :
                                (fr3_fw1_available_f1[0][0]) ? `CA53_FWD_FW1_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr3_fwd_ex1_o[ 5: 3] = (fr3_zero_available_f1[1])   ? `CA53_FWD_ZERO   :
                                (fr3_fw0_available_f1[1][2]) ? `CA53_FWD_FW0_F3 :
                                (fr3_fw1_available_f1[1][2]) ? `CA53_FWD_FW1_F3 :
                                (fr3_fw0_available_f1[1][1]) ? `CA53_FWD_FW0_F4 :
                                (fr3_fw1_available_f1[1][1]) ? `CA53_FWD_FW1_F4 :
                                (fr3_fw0_available_f1[1][0]) ? `CA53_FWD_FW0_F5 :
                                (fr3_fw1_available_f1[1][0]) ? `CA53_FWD_FW1_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr4_fwd_ex1_o[ 2: 0] = (fr4_zero_available_f1[0])   ? `CA53_FWD_ZERO   :
                                (fr4_fw0_available_f1[0][2]) ? `CA53_FWD_FW0_F3 :
                                (fr4_fw1_available_f1[0][2]) ? `CA53_FWD_FW1_F3 :
                                (fr4_fw0_available_f1[0][1]) ? `CA53_FWD_FW0_F4 :
                                (fr4_fw1_available_f1[0][1]) ? `CA53_FWD_FW1_F4 :
                                (fr4_fw0_available_f1[0][0]) ? `CA53_FWD_FW0_F5 :
                                (fr4_fw1_available_f1[0][0]) ? `CA53_FWD_FW1_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr4_fwd_ex1_o[ 5: 3] = (fr4_zero_available_f1[1])   ? `CA53_FWD_ZERO   :
                                (fr4_fw0_available_f1[1][2]) ? `CA53_FWD_FW0_F3 :
                                (fr4_fw1_available_f1[1][2]) ? `CA53_FWD_FW1_F3 :
                                (fr4_fw0_available_f1[1][1]) ? `CA53_FWD_FW0_F4 :
                                (fr4_fw1_available_f1[1][1]) ? `CA53_FWD_FW1_F4 :
                                (fr4_fw0_available_f1[1][0]) ? `CA53_FWD_FW0_F5 :
                                (fr4_fw1_available_f1[1][0]) ? `CA53_FWD_FW1_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr5_fwd_ex1_o[ 2: 0] = (fr5_zero_available_f1[0])   ? `CA53_FWD_ZERO   :
                                (fr5_fw0_available_f1[0][2]) ? `CA53_FWD_FW0_F3 :
                                (fr5_fw1_available_f1[0][2]) ? `CA53_FWD_FW1_F3 :
                                (fr5_fw0_available_f1[0][1]) ? `CA53_FWD_FW0_F4 :
                                (fr5_fw1_available_f1[0][1]) ? `CA53_FWD_FW1_F4 :
                                (fr5_fw0_available_f1[0][0]) ? `CA53_FWD_FW0_F5 :
                                (fr5_fw1_available_f1[0][0]) ? `CA53_FWD_FW1_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr5_fwd_ex1_o[ 5: 3] = (fr5_zero_available_f1[1])   ? `CA53_FWD_ZERO   :
                                (fr5_fw0_available_f1[1][2]) ? `CA53_FWD_FW0_F3 :
                                (fr5_fw1_available_f1[1][2]) ? `CA53_FWD_FW1_F3 :
                                (fr5_fw0_available_f1[1][1]) ? `CA53_FWD_FW0_F4 :
                                (fr5_fw1_available_f1[1][1]) ? `CA53_FWD_FW1_F4 :
                                (fr5_fw0_available_f1[1][0]) ? `CA53_FWD_FW0_F5 :
                                (fr5_fw1_available_f1[1][0]) ? `CA53_FWD_FW1_F5 :
                                                               `CA53_FWD_FNULL;

  // ------------------------------------------------------
  // FPU forwarding controls for F2 forwarding
  // ------------------------------------------------------

  // Forward to instructions in the F2 stage of the store pipeline
  always @*
    case (str0_sel_fp_f2)
      `CA53_STR0_FP_SEL_FR0,
      `CA53_STR0_FP_SEL_FR0_FR1:
        case ((rf_rd_en_fr0_f2[1:0] == 2'b10) ? {1'b0,
                                                 (|fr0_fw0_available_f2[1]) | (|fr0_fw1_available_f2[1])}
                                              : {(|fr0_fw0_available_f2[1]) | (|fr0_fw1_available_f2[1]),
                                                 (|fr0_fw0_available_f2[0]) | (|fr0_fw1_available_f2[0])})
          2'b00:   str0_a_fwd_fp_ex2_int = `CA53_FWD_NULL;
          2'b01:   str0_a_fwd_fp_ex2_int = `CA53_FWD_FP_LO;
          2'b10:   str0_a_fwd_fp_ex2_int = `CA53_FWD_FP_HI;
          2'b11:   str0_a_fwd_fp_ex2_int = `CA53_FWD_FP;
          default: str0_a_fwd_fp_ex2_int = {`CA53_FWD_W{1'bx}};
        endcase
      
      `CA53_STR0_FP_SEL_FR4:
        case ((rf_rd_en_fr4_f2[1:0] == 2'b10) ? {1'b0,
                                                 (|fr4_fw0_available_f2[1]) | (|fr4_fw1_available_f2[1])}
                                              : {(|fr4_fw0_available_f2[1]) | (|fr4_fw1_available_f2[1]),
                                                 (|fr4_fw0_available_f2[0]) | (|fr4_fw1_available_f2[0])})
          2'b00:   str0_a_fwd_fp_ex2_int = `CA53_FWD_NULL;
          2'b01:   str0_a_fwd_fp_ex2_int = `CA53_FWD_FP_LO;
          2'b10:   str0_a_fwd_fp_ex2_int = `CA53_FWD_FP_HI;
          2'b11:   str0_a_fwd_fp_ex2_int = `CA53_FWD_FP;
          default: str0_a_fwd_fp_ex2_int = {`CA53_FWD_W{1'bx}};
        endcase
      
      default: str0_a_fwd_fp_ex2_int = {`CA53_FWD_W{1'bx}};
    endcase

  always @*
    case ((rf_rd_en_fr1_f2[1:0] == 2'b10) ? (|fr1_fw0_available_f2[1]) | (|fr1_fw1_available_f2[1])
                                          : (|fr1_fw0_available_f2[0]) | (|fr1_fw1_available_f2[0]))
      1'b0:    str0_b_fwd_fp_ex2_int = `CA53_FWD_NULL;
      1'b1:    str0_b_fwd_fp_ex2_int = `CA53_FWD_FP;
      default: str0_b_fwd_fp_ex2_int = {`CA53_FWD_W{1'bx}};
    endcase

  always @*
    case (str1_sel_fp_f2)
      `CA53_STR1_FP_SEL_FR3,
      `CA53_STR1_FP_SEL_FR3_FR4:
        case ((rf_rd_en_fr3_f2[1:0] == 2'b10) ? {1'b0,
                                                 (|fr3_fw0_available_f2[1]) | (|fr3_fw1_available_f2[1])}
                                              : {(|fr3_fw0_available_f2[1]) | (|fr3_fw1_available_f2[1]),
                                                 (|fr3_fw0_available_f2[0]) | (|fr3_fw1_available_f2[0])})
          2'b00:   str1_a_fwd_fp_ex2_int = `CA53_FWD_NULL;
          2'b01:   str1_a_fwd_fp_ex2_int = `CA53_FWD_FP_LO;
          2'b10:   str1_a_fwd_fp_ex2_int = `CA53_FWD_FP_HI;
          2'b11:   str1_a_fwd_fp_ex2_int = `CA53_FWD_FP;
          default: str1_a_fwd_fp_ex2_int = {`CA53_FWD_W{1'bx}};
        endcase
      
      `CA53_STR1_FP_SEL_FR1:
        case ((rf_rd_en_fr1_f2[1:0] == 2'b10) ? {1'b0,
                                                 (|fr1_fw0_available_f2[1]) | (|fr1_fw1_available_f2[1])}
                                              : {(|fr1_fw0_available_f2[1]) | (|fr1_fw1_available_f2[1]),
                                                 (|fr1_fw0_available_f2[0]) | (|fr1_fw1_available_f2[0])})
          2'b00:   str1_a_fwd_fp_ex2_int = `CA53_FWD_NULL;
          2'b01:   str1_a_fwd_fp_ex2_int = `CA53_FWD_FP_LO;
          2'b10:   str1_a_fwd_fp_ex2_int = `CA53_FWD_FP_HI;
          2'b11:   str1_a_fwd_fp_ex2_int = `CA53_FWD_FP;
          default: str1_a_fwd_fp_ex2_int = {`CA53_FWD_W{1'bx}};
        endcase
      
      default: str1_a_fwd_fp_ex2_int = {`CA53_FWD_W{1'bx}};
    endcase

  always @*
    case ((rf_rd_en_fr4_f2[1:0] == 2'b10) ? (|fr4_fw0_available_f2[1]) | (|fr4_fw1_available_f2[1])
                                          : (|fr4_fw0_available_f2[0]) | (|fr4_fw1_available_f2[0]))
      1'b0:    str1_b_fwd_fp_ex2_int = `CA53_FWD_NULL;
      1'b1:    str1_b_fwd_fp_ex2_int = `CA53_FWD_FP;
      default: str1_b_fwd_fp_ex2_int = {`CA53_FWD_W{1'bx}};
    endcase


  assign str0_a_fwd_fp_ex2 = str0_a_fwd_fp_ex2_int;
  assign str0_b_fwd_fp_ex2 = str0_b_fwd_fp_ex2_int;
  assign str1_a_fwd_fp_ex2 = str1_a_fwd_fp_ex2_int;
  assign str1_b_fwd_fp_ex2 = str1_b_fwd_fp_ex2_int;

  assign fr0_fwd_ex2_o[ 2: 0] = (fr0_fw1_available_f2[0][2]) ? `CA53_FWD_FW1_F3 :
                                (fr0_fw0_available_f2[0][2]) ? `CA53_FWD_FW0_F3 :
                                (fr0_fw1_available_f2[0][1]) ? `CA53_FWD_FW1_F4 :
                                (fr0_fw0_available_f2[0][1]) ? `CA53_FWD_FW0_F4 :
                                (fr0_fw1_available_f2[0][0]) ? `CA53_FWD_FW1_F5 :
                                (fr0_fw0_available_f2[0][0]) ? `CA53_FWD_FW0_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr0_fwd_ex2_o[ 5: 3] = (fr0_fw1_available_f2[1][2]) ? `CA53_FWD_FW1_F3 :
                                (fr0_fw0_available_f2[1][2]) ? `CA53_FWD_FW0_F3 :
                                (fr0_fw1_available_f2[1][1]) ? `CA53_FWD_FW1_F4 :
                                (fr0_fw0_available_f2[1][1]) ? `CA53_FWD_FW0_F4 :
                                (fr0_fw1_available_f2[1][0]) ? `CA53_FWD_FW1_F5 :
                                (fr0_fw0_available_f2[1][0]) ? `CA53_FWD_FW0_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr1_fwd_ex2_o[ 2: 0] = (fr1_fw1_available_f2[0][2]) ? `CA53_FWD_FW1_F3 :
                                (fr1_fw0_available_f2[0][2]) ? `CA53_FWD_FW0_F3 :
                                (fr1_fw1_available_f2[0][1]) ? `CA53_FWD_FW1_F4 :
                                (fr1_fw0_available_f2[0][1]) ? `CA53_FWD_FW0_F4 :
                                (fr1_fw1_available_f2[0][0]) ? `CA53_FWD_FW1_F5 :
                                (fr1_fw0_available_f2[0][0]) ? `CA53_FWD_FW0_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr1_fwd_ex2_o[ 5: 3] = (fr1_fw1_available_f2[1][2]) ? `CA53_FWD_FW1_F3 :
                                (fr1_fw0_available_f2[1][2]) ? `CA53_FWD_FW0_F3 :
                                (fr1_fw1_available_f2[1][1]) ? `CA53_FWD_FW1_F4 :
                                (fr1_fw0_available_f2[1][1]) ? `CA53_FWD_FW0_F4 :
                                (fr1_fw1_available_f2[1][0]) ? `CA53_FWD_FW1_F5 :
                                (fr1_fw0_available_f2[1][0]) ? `CA53_FWD_FW0_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr2_fwd_ex2_o[ 2: 0] = (fr2_fw1_available_f2[0][2]) ? `CA53_FWD_FW1_F3 :
                                (fr2_fw0_available_f2[0][2]) ? `CA53_FWD_FW0_F3 :
                                (fr2_fw1_available_f2[0][1]) ? `CA53_FWD_FW1_F4 :
                                (fr2_fw0_available_f2[0][1]) ? `CA53_FWD_FW0_F4 :
                                (fr2_fw1_available_f2[0][0]) ? `CA53_FWD_FW1_F5 :
                                (fr2_fw0_available_f2[0][0]) ? `CA53_FWD_FW0_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr2_fwd_ex2_o[ 5: 3] = (fr2_fw1_available_f2[1][2]) ? `CA53_FWD_FW1_F3 :
                                (fr2_fw0_available_f2[1][2]) ? `CA53_FWD_FW0_F3 :
                                (fr2_fw1_available_f2[1][1]) ? `CA53_FWD_FW1_F4 :
                                (fr2_fw0_available_f2[1][1]) ? `CA53_FWD_FW0_F4 :
                                (fr2_fw1_available_f2[1][0]) ? `CA53_FWD_FW1_F5 :
                                (fr2_fw0_available_f2[1][0]) ? `CA53_FWD_FW0_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr3_fwd_ex2_o[ 2: 0] = (fr3_fw1_available_f2[0][2]) ? `CA53_FWD_FW1_F3 :
                                (fr3_fw0_available_f2[0][2]) ? `CA53_FWD_FW0_F3 :
                                (fr3_fw1_available_f2[0][1]) ? `CA53_FWD_FW1_F4 :
                                (fr3_fw0_available_f2[0][1]) ? `CA53_FWD_FW0_F4 :
                                (fr3_fw1_available_f2[0][0]) ? `CA53_FWD_FW1_F5 :
                                (fr3_fw0_available_f2[0][0]) ? `CA53_FWD_FW0_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr3_fwd_ex2_o[ 5: 3] = (fr3_fw1_available_f2[1][2]) ? `CA53_FWD_FW1_F3 :
                                (fr3_fw0_available_f2[1][2]) ? `CA53_FWD_FW0_F3 :
                                (fr3_fw1_available_f2[1][1]) ? `CA53_FWD_FW1_F4 :
                                (fr3_fw0_available_f2[1][1]) ? `CA53_FWD_FW0_F4 :
                                (fr3_fw1_available_f2[1][0]) ? `CA53_FWD_FW1_F5 :
                                (fr3_fw0_available_f2[1][0]) ? `CA53_FWD_FW0_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr4_fwd_ex2_o[ 2: 0] = (fr4_fw1_available_f2[0][2]) ? `CA53_FWD_FW1_F3 :
                                (fr4_fw0_available_f2[0][2]) ? `CA53_FWD_FW0_F3 :
                                (fr4_fw1_available_f2[0][1]) ? `CA53_FWD_FW1_F4 :
                                (fr4_fw0_available_f2[0][1]) ? `CA53_FWD_FW0_F4 :
                                (fr4_fw1_available_f2[0][0]) ? `CA53_FWD_FW1_F5 :
                                (fr4_fw0_available_f2[0][0]) ? `CA53_FWD_FW0_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr4_fwd_ex2_o[ 5: 3] = (fr4_fw1_available_f2[1][2]) ? `CA53_FWD_FW1_F3 :
                                (fr4_fw0_available_f2[1][2]) ? `CA53_FWD_FW0_F3 :
                                (fr4_fw1_available_f2[1][1]) ? `CA53_FWD_FW1_F4 :
                                (fr4_fw0_available_f2[1][1]) ? `CA53_FWD_FW0_F4 :
                                (fr4_fw1_available_f2[1][0]) ? `CA53_FWD_FW1_F5 :
                                (fr4_fw0_available_f2[1][0]) ? `CA53_FWD_FW0_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr5_fwd_ex2_o[ 2: 0] = (fr5_fw1_available_f2[0][2]) ? `CA53_FWD_FW1_F3 :
                                (fr5_fw0_available_f2[0][2]) ? `CA53_FWD_FW0_F3 :
                                (fr5_fw1_available_f2[0][1]) ? `CA53_FWD_FW1_F4 :
                                (fr5_fw0_available_f2[0][1]) ? `CA53_FWD_FW0_F4 :
                                (fr5_fw1_available_f2[0][0]) ? `CA53_FWD_FW1_F5 :
                                (fr5_fw0_available_f2[0][0]) ? `CA53_FWD_FW0_F5 :
                                                               `CA53_FWD_FNULL;

  assign fr5_fwd_ex2_o[ 5: 3] = (fr5_fw1_available_f2[1][2]) ? `CA53_FWD_FW1_F3 :
                                (fr5_fw0_available_f2[1][2]) ? `CA53_FWD_FW0_F3 :
                                (fr5_fw1_available_f2[1][1]) ? `CA53_FWD_FW1_F4 :
                                (fr5_fw0_available_f2[1][1]) ? `CA53_FWD_FW0_F4 :
                                (fr5_fw1_available_f2[1][0]) ? `CA53_FWD_FW1_F5 :
                                (fr5_fw0_available_f2[1][0]) ? `CA53_FWD_FW0_F5 :
                                                               `CA53_FWD_FNULL;

  assign fp_mul_fwd_ex2_o = fp_mul_fwd_ex2;

  assign neon_mul_can_fwd[0] = valid_instrs_iss[0] & neon_can_fwd_acc_iss[0]                   &
                               valid_instrs_ex1[0] & fp_ex_pipe_f1 [`CA53_FP_EX_PIPE_MUL0]     &
                               (cond_code_instr0_iss == cond_code_instr0_ex1)                  &
                               fp_mul0_ctl_f1[`CA53_FP_MUL_NEON_INT_OP_BITS]                   &
                               (fp_mul0_ctl_iss[`CA53_FP_MUL_NEON_OUT_FMT_BITS]
                                 == fp_mul0_ctl_f1[`CA53_FP_MUL_NEON_OUT_FMT_BITS])            &
                               ~fp_mul0_ctl_f1 [`CA53_FP_MUL_NEON_SAT_DBL_BITS]                &
                               fr2_fw0_addr_match[3]                                           &
                               (rf_rd_addr_fr2_iss[0] == rf_wr_addr_fw0_f1[0])                 &
                               rf_rd_en_fr2_iss[0]                                             &
                               early_rf_wr_en_fw0_f1[0];

  assign neon_mul_can_fwd[1] = valid_instrs_iss[0] & neon_can_fwd_acc_iss[1]                   &
                               valid_instrs_ex1[0] & fp_ex_pipe_f1 [`CA53_FP_EX_PIPE_MUL1]     &
                               (cond_code_instr0_iss == cond_code_instr0_ex1)                  &
                               fp_mul1_ctl_f1[`CA53_FP_MUL_NEON_INT_OP_BITS]                   &
                               (fp_mul1_ctl_iss[`CA53_FP_MUL_NEON_OUT_FMT_BITS]
                                 == fp_mul1_ctl_f1[`CA53_FP_MUL_NEON_OUT_FMT_BITS])            &
                               ~fp_mul1_ctl_f1 [`CA53_FP_MUL_NEON_SAT_DBL_BITS]                &
                               fr5_fw1_addr_match[3]                                           &
                               (rf_rd_addr_fr5_iss[0] == rf_wr_addr_fw1_f1[0])                 &
                               rf_rd_en_fr5_iss[0]                                             &
                               early_rf_wr_en_fw1_f1[0];

  // FPU 'when' signals                                      1: Can't forward into F2   2: Can't forward into F1
  assign fr0_when_iss = ({2{early_fr0_fw0_where_iss[3]}} & { rf_wr_when_fw0_f1[0],      1'b1})                 |
                        ({2{early_fr0_fw1_where_iss[3]}} & { rf_wr_when_fw1_f1[0],      1'b1})                 |
                        ({2{early_fr0_fw0_where_iss[2]}} & { rf_wr_when_fw0_f2[1],      rf_wr_when_fw0_f2[0]}) |
                        ({2{early_fr0_fw1_where_iss[2]}} & { rf_wr_when_fw1_f2[1],      rf_wr_when_fw1_f2[0]}) |
                        ({2{early_fr0_fw0_where_iss[1]}} & { rf_wr_when_fw0_f3[2],      rf_wr_when_fw0_f3[1]}) |
                        ({2{early_fr0_fw1_where_iss[1]}} & { rf_wr_when_fw1_f3[2],      rf_wr_when_fw1_f3[1]}) |
                        ({2{early_fr0_fw0_where_iss[0]}} & { rf_wr_when_fw0_f4[2],      rf_wr_when_fw0_f3[2]}) |
                        ({2{early_fr0_fw1_where_iss[0]}} & { rf_wr_when_fw1_f4[2],      rf_wr_when_fw1_f3[2]});

  assign fr1_when_iss = ({2{early_fr1_fw0_where_iss[3]}} & { rf_wr_when_fw0_f1[0],      1'b1})                 |
                        ({2{early_fr1_fw1_where_iss[3]}} & { rf_wr_when_fw1_f1[0],      1'b1})                 |
                        ({2{early_fr1_fw0_where_iss[2]}} & { rf_wr_when_fw0_f2[1],      rf_wr_when_fw0_f2[0]}) |
                        ({2{early_fr1_fw1_where_iss[2]}} & { rf_wr_when_fw1_f2[1],      rf_wr_when_fw1_f2[0]}) |
                        ({2{early_fr1_fw0_where_iss[1]}} & { rf_wr_when_fw0_f3[2],      rf_wr_when_fw0_f3[1]}) |
                        ({2{early_fr1_fw1_where_iss[1]}} & { rf_wr_when_fw1_f3[2],      rf_wr_when_fw1_f3[1]}) |
                        ({2{early_fr1_fw0_where_iss[0]}} & { rf_wr_when_fw0_f4[2],      rf_wr_when_fw0_f3[2]}) |
                        ({2{early_fr1_fw1_where_iss[0]}} & { rf_wr_when_fw1_f4[2],      rf_wr_when_fw1_f3[2]});

  assign fr2_when_iss = ({2{early_fr2_fw0_where_iss[3]}} & { rf_wr_when_fw0_f1[0],      1'b1})                 |
                        ({2{early_fr2_fw1_where_iss[3]}} & { rf_wr_when_fw1_f1[0],      1'b1})                 |
                        ({2{early_fr2_fw0_where_iss[2]}} & { rf_wr_when_fw0_f2[1],      rf_wr_when_fw0_f2[0]}) |
                        ({2{early_fr2_fw1_where_iss[2]}} & { rf_wr_when_fw1_f2[1],      rf_wr_when_fw1_f2[0]}) |
                        ({2{early_fr2_fw0_where_iss[1]}} & { rf_wr_when_fw0_f3[2],      rf_wr_when_fw0_f3[1]}) |
                        ({2{early_fr2_fw1_where_iss[1]}} & { rf_wr_when_fw1_f3[2],      rf_wr_when_fw1_f3[1]}) |
                        ({2{early_fr2_fw0_where_iss[0]}} & { rf_wr_when_fw0_f4[2],      rf_wr_when_fw0_f3[2]}) |
                        ({2{early_fr2_fw1_where_iss[0]}} & { rf_wr_when_fw1_f4[2],      rf_wr_when_fw1_f3[2]});

  assign fr3_when_iss = ({2{early_fr3_fw0_where_iss[3]}} & { rf_wr_when_fw0_f1[0],      1'b1})                 |
                        ({2{early_fr3_fw1_where_iss[3]}} & { rf_wr_when_fw1_f1[0],      1'b1})                 |
                        ({2{early_fr3_fw0_where_iss[2]}} & { rf_wr_when_fw0_f2[1],      rf_wr_when_fw0_f2[0]}) |
                        ({2{early_fr3_fw1_where_iss[2]}} & { rf_wr_when_fw1_f2[1],      rf_wr_when_fw1_f2[0]}) |
                        ({2{early_fr3_fw0_where_iss[1]}} & { rf_wr_when_fw0_f3[2],      rf_wr_when_fw0_f3[1]}) |
                        ({2{early_fr3_fw1_where_iss[1]}} & { rf_wr_when_fw1_f3[2],      rf_wr_when_fw1_f3[1]}) |
                        ({2{early_fr3_fw0_where_iss[0]}} & { rf_wr_when_fw0_f4[2],      rf_wr_when_fw0_f3[2]}) |
                        ({2{early_fr3_fw1_where_iss[0]}} & { rf_wr_when_fw1_f4[2],      rf_wr_when_fw1_f3[2]});

  assign fr4_when_iss = ({2{early_fr4_fw0_where_iss[3]}} & { rf_wr_when_fw0_f1[0],      1'b1})                 |
                        ({2{early_fr4_fw1_where_iss[3]}} & { rf_wr_when_fw1_f1[0],      1'b1})                 |
                        ({2{early_fr4_fw0_where_iss[2]}} & { rf_wr_when_fw0_f2[1],      rf_wr_when_fw0_f2[0]}) |
                        ({2{early_fr4_fw1_where_iss[2]}} & { rf_wr_when_fw1_f2[1],      rf_wr_when_fw1_f2[0]}) |
                        ({2{early_fr4_fw0_where_iss[1]}} & { rf_wr_when_fw0_f3[2],      rf_wr_when_fw0_f3[1]}) |
                        ({2{early_fr4_fw1_where_iss[1]}} & { rf_wr_when_fw1_f3[2],      rf_wr_when_fw1_f3[1]}) |
                        ({2{early_fr4_fw0_where_iss[0]}} & { rf_wr_when_fw0_f4[2],      rf_wr_when_fw0_f3[2]}) |
                        ({2{early_fr4_fw1_where_iss[0]}} & { rf_wr_when_fw1_f4[2],      rf_wr_when_fw1_f3[2]});

  assign fr5_when_iss = ({2{early_fr5_fw0_where_iss[3]}} & { rf_wr_when_fw0_f1[0],      1'b1})                 |
                        ({2{early_fr5_fw1_where_iss[3]}} & { rf_wr_when_fw1_f1[0],      1'b1})                 |
                        ({2{early_fr5_fw0_where_iss[2]}} & { rf_wr_when_fw0_f2[1],      rf_wr_when_fw0_f2[0]}) |
                        ({2{early_fr5_fw1_where_iss[2]}} & { rf_wr_when_fw1_f2[1],      rf_wr_when_fw1_f2[0]}) |
                        ({2{early_fr5_fw0_where_iss[1]}} & { rf_wr_when_fw0_f3[2],      rf_wr_when_fw0_f3[1]}) |
                        ({2{early_fr5_fw1_where_iss[1]}} & { rf_wr_when_fw1_f3[2],      rf_wr_when_fw1_f3[1]}) |
                        ({2{early_fr5_fw0_where_iss[0]}} & { rf_wr_when_fw0_f4[2],      rf_wr_when_fw0_f3[2]}) |
                        ({2{early_fr5_fw1_where_iss[0]}} & { rf_wr_when_fw1_f4[2],      rf_wr_when_fw1_f3[2]});

  // FPU interlocking
  assign fpscr_interlock_iss = fp_serialize_iss_i &
                               ((|fp0_cflag_src_f1)      | (|fp0_cflag_src_f2) |
                                (|fp1_cflag_src_f1)      | (|fp1_cflag_src_f2) |
                                (|fp0_xflag_src_f1)      | (|fp0_xflag_src_f2) |
                                (|fp1_xflag_src_f1)      | (|fp1_xflag_src_f2) |
                                unflushable_ex1          | unflushable_ex2     |
                                (|unflushable_sfmac_ex1) | (|unflushable_sfmac_ex2));

  assign fpu_interlock_iss = special_interlock_iss                           |
                             fpscr_interlock_iss                             |
                             (wfx_serialize_iss & (instr_is_cp10_cp11_ex1 |
                                                   instr_is_cp10_cp11_ex2))  |
                              (|({1'b1, rf_rd_need_fr0_iss} & fr0_when_iss)) |
                              (|({1'b1, rf_rd_need_fr1_iss} & fr1_when_iss)) |
                             ((|({1'b1, rf_rd_need_fr2_iss} & fr2_when_iss)) & ~neon_mul_can_fwd[0]) |
                              (|({1'b1, rf_rd_need_fr3_iss} & fr3_when_iss)) |
                              (|({1'b1, rf_rd_need_fr4_iss} & fr4_when_iss)) |
                             ((|({1'b1, rf_rd_need_fr5_iss} & fr5_when_iss)) & ~neon_mul_can_fwd[1]);

  // Forwarding of the FPSCR.NZCV flags
  assign fp_fwd_cflags_ex2_o = (fp0_cflag_src_f2 & cc_pass_instr0_ex2_i) ? fp_cflags_add0_f2_i :
                                fp1_cflag_src_f3                         ? fp_cflags_add1_f3   :
                                fp0_cflag_src_f3                         ? fp_cflags_add0_f3   :
                                raw_fp1_cflag_src_f4                     ? fp_cflags_add1_f4   :
                                raw_fp0_cflag_src_f4                     ? fp_cflags_add0_f4   :
                                fp1_cflag_src_f5                         ? fp_cflags_add1_f5   :
                                fp0_cflag_src_f5                         ? fp_cflags_add0_f5   :
                                                                           cp_fpsr_cflags_i;
  assign fp_cflags_add0_f5_o = fp_cflags_add0_f5;
  assign fp_cflags_add1_f5_o = fp_cflags_add1_f5;

  // vldn control logic
  assign neon_vld_ctl_f2_en = issue_to_ex2_fpu & ~stall_wr;
  always @(posedge clk)
    if (neon_vld_ctl_f2_en)
      neon_vld_ctl_f2 <= neon_vld_ctl_f1;

  assign neon_vld_ctl_f3_en = issue_to_wr_fpu & ~stall_wr;
  always @(posedge clk)
    if (neon_vld_ctl_f3_en)
      neon_vld_ctl_f3 <= neon_vld_ctl_f2;

  assign neon_vld_ctl_f2_o = neon_vld_ctl_f2;
  assign neon_vld_ctl_f3_o = neon_vld_ctl_f3;

  // FPU register file interface
  assign rf_rd_addr_fr0_iss_o       = rf_rd_addr_fr0_iss;
  assign rf_rd_addr_fr1_iss_o       = rf_rd_addr_fr1_iss;
  assign rf_rd_addr_fr2_iss_o       = rf_rd_addr_fr2_iss;
  assign rf_rd_addr_fr3_iss_o       = rf_rd_addr_fr3_iss;
  assign rf_rd_addr_fr4_iss_o       = rf_rd_addr_fr4_iss;
  assign rf_rd_addr_fr5_iss_o       = rf_rd_addr_fr5_iss;
  assign rf_rd_en_fr0_iss_o         = raw_rf_rd_en_fr0_iss;
  assign rf_rd_en_fr1_iss_o         = raw_rf_rd_en_fr1_iss;
  assign rf_rd_en_fr2_iss_o         = rf_rd_en_fr2_iss;
  assign rf_rd_en_fr3_iss_o         = raw_rf_rd_en_fr3_iss;
  assign rf_rd_en_fr4_iss_o         = raw_rf_rd_en_fr4_iss;
  assign rf_rd_en_fr5_iss_o         = rf_rd_en_fr5_iss;
  assign rf_rd_en_fr0_ex1_o         = rf_rd_en_fr0_f1;
  assign rf_rd_en_fr1_ex1_o         = rf_rd_en_fr1_f1;
  assign rf_rd_en_fr2_ex1_o         = rf_rd_en_fr2_f1;
  assign rf_rd_en_fr3_ex1_o         = rf_rd_en_fr3_f1;
  assign rf_rd_en_fr4_ex1_o         = rf_rd_en_fr4_f1;
  assign rf_rd_en_fr5_ex1_o         = rf_rd_en_fr5_f1;
  assign rf_rd_en_fr0_ex2_o         = rf_rd_en_fr0_f2;
  assign rf_rd_en_fr1_ex2_o         = rf_rd_en_fr1_f2;
  assign rf_rd_en_fr2_ex2_o         = rf_rd_en_fr2_f2;
  assign rf_rd_en_fr3_ex2_o         = rf_rd_en_fr3_f2;
  assign rf_rd_en_fr4_ex2_o         = rf_rd_en_fr4_f2;
  assign rf_rd_en_fr5_ex2_o         = rf_rd_en_fr5_f2;
  assign rf_wr_en_fw_f3_o           = rf_wr_en_fw_f3;
  assign rf_wr_en_fw_f5_o           = rf_wr_en_fw_f5;
  assign rf_wr_en_fw0_f5_o          = rf_wr_en_fw0_f5;
  assign rf_wr_en_fw1_f5_o          = rf_wr_en_fw1_f5;
  assign rf_wr_addr_fw0_f5_o        = rf_wr_addr_fw0_f5[(`CA53_FP_RF_WR_ADDR_W-1):0];
  assign rf_wr_addr_fw1_f5_o        = rf_wr_addr_fw1_f5[(`CA53_FP_RF_WR_ADDR_W-1):0];
  assign rf_wr_src_fw0_f3_o         = rf_wr_src_fw0_f3;
  assign rf_wr_src_fw0_f4_o         = rf_wr_src_fw0_f4;
  assign rf_wr_src_fw0_f5_o         = rf_wr_src_fw0_f5;
  assign rf_wr_src_fw1_f3_o         = rf_wr_src_fw1_f3;
  assign rf_wr_src_fw1_f4_o         = rf_wr_src_fw1_f4;
  assign rf_wr_src_fw1_f5_o         = rf_wr_src_fw1_f5;
  assign rf_wr_when_fw0_f4_o        = rf_wr_when_fw0_f4;
  assign rf_wr_when_fw1_f4_o        = rf_wr_when_fw1_f4;

  // FPSR update control
  assign fp0_cflag_src_f5_o         = fp0_cflag_src_f5;
  assign fp1_cflag_src_f5_o         = fp1_cflag_src_f5;
  assign fp0_xflag_src_f5_o         = fp0_xflag_src_f5;
  assign fp1_xflag_src_f5_o         = fp1_xflag_src_f5;

  // FPU immediate data
  assign fp0_imm_data_f1_o[12:0]    = fp0_imm_data_f1[12:0];
  assign fp1_imm_data_f1_o[12:0]    = fp1_imm_data_f1[12:0];

  // FPU datapath control
  // Ex1 stage command bus should only be asserted for one cycle
  assign ctl_fp_dp_en_o             = fp_rp_active | fp_imm_data_active | fp_ld_data_active;
  assign dpu_neon_active_o          = dpu_neon_active;
  assign fp_ex_pipe_iss_o           = fp_ex_pipe_iss;
  assign fp_ex_pipe_f1_o            = fp_ex_pipe_f1;
  assign fp0_pipectl_f1_o           = fp0_pipectl_f1;
  assign fp1_pipectl_f1_o           = fp1_pipectl_f1;
  assign fp_div_enb_ex1_o           = {2{unflushable_sfdiv_ex1}} & {raw_rf_wr_en_fw1_f1[0], 1'b1};
  assign instr_is_cp10_cp11_wr_o    = instr_is_cp10_cp11_wr;
  assign sel_fad0_a_f1_o            = sel_fad0_a_f1 & {`CA53_SEL_FAD_A_W{instr_is_cp10_cp11_ex1}};
  assign sel_fad0_b_f1_o            = sel_fad0_b_f1 & {`CA53_SEL_FAD_B_W{instr_is_cp10_cp11_ex1}};
  assign sel_fad0_c_f1_o            = sel_fad0_c_f1 & {`CA53_SEL_FAD_C_W{instr_is_cp10_cp11_ex1}};
  assign sel_fad1_a_f1_o            = sel_fad1_a_f1 & {`CA53_SEL_FAD_A_W{instr_is_cp10_cp11_ex1}};
  assign sel_fad1_b_f1_o            = sel_fad1_b_f1 & {`CA53_SEL_FAD_B_W{instr_is_cp10_cp11_ex1}};
  assign sel_fad1_c_f1_o            = sel_fad1_c_f1 & {`CA53_SEL_FAD_C_W{instr_is_cp10_cp11_ex1}};
  assign sel_fml0_a_f1_o            = sel_fml0_a_f1 &                    instr_is_cp10_cp11_ex1;
  assign sel_fml0_b_f1_o            = sel_fml0_b_f1 & {`CA53_SEL_FML_B_W{instr_is_cp10_cp11_ex1}};
  assign sel_fml0_c_f1_o            = sel_fml0_c_f1 &                    instr_is_cp10_cp11_ex1;
  assign sel_fml1_a_f1_o            = sel_fml1_a_f1 &                    instr_is_cp10_cp11_ex1;
  assign sel_fml1_b_f1_o            = sel_fml1_b_f1 & {`CA53_SEL_FML_B_W{instr_is_cp10_cp11_ex1}};
  assign sel_fml1_c_f1_o            = sel_fml1_c_f1 &                    instr_is_cp10_cp11_ex1;

  assign instr_fmstat_ex2_o         = instr_fmstat_ex2;

  // Information about instructions in flight for dual issue hazarding
  assign rf_wr_addr_fw0_iss_o       = raw_rf_wr_addr_fw0_iss;
  assign rf_wr_addr_fw1_iss_o       = raw_rf_wr_addr_fw1_iss;
  assign rf_wr_addr_fw0_f1_o        = rf_wr_addr_fw0_f1;
  assign rf_wr_addr_fw1_f1_o        = rf_wr_addr_fw1_f1;
  assign rf_wr_addr_fw0_f2_o        = rf_wr_addr_fw0_f2;
  assign rf_wr_addr_fw1_f2_o        = rf_wr_addr_fw1_f2;

  assign rf_wr_en_fw0_iss_o         = raw_rf_wr_en_fw0_iss;
  assign rf_wr_en_fw1_iss_o         = raw_rf_wr_en_fw1_iss;
  assign rf_wr_en_fw0_f1_o          = raw_rf_wr_en_fw0_f1;
  assign rf_wr_en_fw1_f1_o          = raw_rf_wr_en_fw1_f1;
  assign rf_wr_en_fw0_f2_o          = raw_rf_wr_en_fw0_f2;
  assign rf_wr_en_fw1_f2_o          = raw_rf_wr_en_fw1_f2;

  assign rf_wr_when_fw0_iss_o       = rf_wr_when_fw0_iss[1:0];  // Don't consider when of L_F5, so just need bottom two bits
  assign rf_wr_when_fw1_iss_o       = rf_wr_when_fw1_iss[1:0];
  assign rf_wr_when_fw0_f1_o        = rf_wr_when_fw0_f1[1:0];
  assign rf_wr_when_fw1_f1_o        = rf_wr_when_fw1_f1[1:0];
  assign rf_wr_when_fw0_f2_o        = rf_wr_when_fw0_f2[1:0];
  assign rf_wr_when_fw1_f2_o        = rf_wr_when_fw1_f2[1:0];

end else begin : FPU1_STUBS
  assign neon_ret_stall_iss         = 1'b0;
  assign ctl_fp_dp_en_o             = 1'b0;
  assign dpu_neon_active_o          = 1'b0;
  assign special_insert_iss         = 2'b00;
  assign special_stall_iss          = 1'b0;
  assign fpu_interlock_iss          = 1'b0;

  assign unflushable_ex1            = 1'b0;
  assign unflushable_ex2            = 1'b0;
  assign unflushable_wr             = 1'b0;
  assign unflushable_sfmac_ex1      = 2'b00;
  assign unflushable_sfmac_ex2      = 2'b00;
  assign unflushable_sfmac_wr       = 2'b00;

  assign issue_to_iss_fpu           = 1'b0;
  assign issue_to_ex1_fpu           = 1'b0;
  assign issue_to_ex2_fpu           = 1'b0;
  assign issue_to_wr_fpu            = 1'b0;

  assign fp_fwd_cflags_ex2_o        = 4'b0000;
  assign fp_cflags_add0_f5_o        = 4'b0000;
  assign fp_cflags_add1_f5_o        = 4'b0000;

  assign neon_vld_ctl_f2_o = {`CA53_NEON_VLD_CTL_W{1'b0}};
  assign neon_vld_ctl_f3_o = {`CA53_NEON_VLD_CTL_W{1'b0}};

  // FPU register file interface
  assign rf_rd_addr_fr0_iss_o       = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
  assign rf_rd_addr_fr1_iss_o       = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
  assign rf_rd_addr_fr2_iss_o       = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
  assign rf_rd_addr_fr3_iss_o       = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
  assign rf_rd_addr_fr4_iss_o       = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
  assign rf_rd_addr_fr5_iss_o       = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
  assign rf_rd_en_fr0_iss_o         = 2'b00;
  assign rf_rd_en_fr1_iss_o         = 2'b00;
  assign rf_rd_en_fr2_iss_o         = 2'b00;
  assign rf_rd_en_fr3_iss_o         = 2'b00;
  assign rf_rd_en_fr4_iss_o         = 2'b00;
  assign rf_rd_en_fr5_iss_o         = 2'b00;
  assign rf_rd_en_fr0_ex1_o         = 2'b00;
  assign rf_rd_en_fr1_ex1_o         = 2'b00;
  assign rf_rd_en_fr2_ex1_o         = 2'b00;
  assign rf_rd_en_fr3_ex1_o         = 2'b00;
  assign rf_rd_en_fr4_ex1_o         = 2'b00;
  assign rf_rd_en_fr5_ex1_o         = 2'b00;
  assign rf_rd_en_fr0_ex2_o         = 2'b00;
  assign rf_rd_en_fr1_ex2_o         = 2'b00;
  assign rf_rd_en_fr2_ex2_o         = 2'b00;
  assign rf_rd_en_fr3_ex2_o         = 2'b00;
  assign rf_rd_en_fr4_ex2_o         = 2'b00;
  assign rf_rd_en_fr5_ex2_o         = 2'b00;
  assign rf_wr_en_fw_f3_o           = 1'b0;
  assign rf_wr_en_fw_f5_o           = 1'b0;
  assign rf_wr_en_fw0_f5_o          = 4'b0000;
  assign rf_wr_en_fw1_f5_o          = 4'b0000;
  assign rf_wr_addr_fw0_f5_o        = {`CA53_FP_RF_WR_ADDR_W{1'b0}};
  assign rf_wr_addr_fw1_f5_o        = {`CA53_FP_RF_WR_ADDR_W{1'b0}};
  assign rf_wr_src_fw0_f3_o         = {`CA53_RF_FWR_SRC_W{1'b0}};
  assign rf_wr_src_fw0_f4_o         = {`CA53_RF_FWR_SRC_W{1'b0}};
  assign rf_wr_src_fw0_f5_o         = {`CA53_RF_FWR_SRC_W{1'b0}};
  assign rf_wr_src_fw1_f3_o         = {`CA53_RF_FWR_SRC_W{1'b0}};
  assign rf_wr_src_fw1_f4_o         = {`CA53_RF_FWR_SRC_W{1'b0}};
  assign rf_wr_src_fw1_f5_o         = {`CA53_RF_FWR_SRC_W{1'b0}};
  assign rf_wr_when_fw0_f4_o        = {`CA53_RF_FWR_WHEN_W{1'b0}};
  assign rf_wr_when_fw1_f4_o        = {`CA53_RF_FWR_WHEN_W{1'b0}};

  // FPSR update control
  assign fp0_cflag_src_f5_o         = {`CA53_FP_CFLAG_SRC_W{1'b0}};
  assign fp1_cflag_src_f5_o         = {`CA53_FP_CFLAG_SRC_W{1'b0}};
  assign fp0_xflag_src_f5_o         = {`CA53_FP_XFLAG_SRC_W{1'b0}};
  assign fp1_xflag_src_f5_o         = {`CA53_FP_XFLAG_SRC_W{1'b0}};

  // FPU immediate data
  assign fp0_imm_data_f1_o[12:0]    = {13{1'b0}};
  assign fp1_imm_data_f1_o[12:0]    = {13{1'b0}};

  // FPU datapath control
  // Ex1 stage command bus should only be asserted for one cycle
  assign fp_ex_pipe_iss_o           = {`CA53_FP_EX_PIPE_W{1'b0}};
  assign fp_ex_pipe_f1_o            = {`CA53_FP_EX_PIPE_W{1'b0}};
  assign crypto_enable_iss_o        = 1'b0;
  assign crypto_enable_f1_o         = 1'b0;
  assign fp0_pipectl_f1_o           = {`CA53_FP_PIPECTL_W{1'b0}};
  assign fp1_pipectl_f1_o           = {`CA53_FP_PIPECTL_W{1'b0}};
  assign fp_div_active_o            = 2'b00;
  assign fp_div_enb_ex1_o           = 2'b00;
  assign instr_is_cp10_cp11_wr_o    = 1'b0;
  assign sel_fad0_a_f1_o            = {`CA53_SEL_FAD_A_W{1'b0}};
  assign sel_fad0_b_f1_o            = {`CA53_SEL_FAD_B_W{1'b0}};
  assign sel_fad0_c_f1_o            = {`CA53_SEL_FAD_C_W{1'b0}};
  assign sel_fad1_a_f1_o            = {`CA53_SEL_FAD_A_W{1'b0}};
  assign sel_fad1_b_f1_o            = {`CA53_SEL_FAD_B_W{1'b0}};
  assign sel_fad1_c_f1_o            = {`CA53_SEL_FAD_C_W{1'b0}};
  assign sel_fml0_a_f1_o            = 1'b0;
  assign sel_fml0_b_f1_o            = {`CA53_SEL_FML_B_W{1'b0}};
  assign sel_fml0_c_f1_o            = 1'b0;
  assign sel_fml1_a_f1_o            = 1'b0;
  assign sel_fml1_b_f1_o            = {`CA53_SEL_FML_B_W{1'b0}};
  assign sel_fml1_c_f1_o            = 1'b0;

  assign fr0_fwd_ex1_o              = {2{`CA53_FWD_FNULL}};
  assign fr1_fwd_ex1_o              = {2{`CA53_FWD_FNULL}};
  assign fr2_fwd_ex1_o              = {2{`CA53_FWD_FNULL}};
  assign fr3_fwd_ex1_o              = {2{`CA53_FWD_FNULL}};
  assign fr4_fwd_ex1_o              = {2{`CA53_FWD_FNULL}};
  assign fr5_fwd_ex1_o              = {2{`CA53_FWD_FNULL}};

  assign fr0_fwd_ex2_o              = {2{`CA53_FWD_FNULL}};
  assign fr1_fwd_ex2_o              = {2{`CA53_FWD_FNULL}};
  assign fr2_fwd_ex2_o              = {2{`CA53_FWD_FNULL}};
  assign fr3_fwd_ex2_o              = {2{`CA53_FWD_FNULL}};
  assign fr4_fwd_ex2_o              = {2{`CA53_FWD_FNULL}};
  assign fr5_fwd_ex2_o              = {2{`CA53_FWD_FNULL}};
  assign fp_mul_fwd_ex2_o           = 2'b00;

  assign str0_a_fwd_fp_ex2          = {`CA53_FWD_W{1'b0}};
  assign str0_b_fwd_fp_ex2          = {`CA53_FWD_W{1'b0}};
  assign str1_a_fwd_fp_ex2          = {`CA53_FWD_W{1'b0}};
  assign str1_b_fwd_fp_ex2          = {`CA53_FWD_W{1'b0}};
  assign str0_sel_fp_f1             = 2'b00;
  assign str0_sel_fp_f2             = 2'b00;
  assign str1_sel_fp_f1             = 2'b00;
  assign str1_sel_fp_f2             = 2'b00;

  assign instr_fmstat_ex2_o         = 2'b00;

  assign rf_wr_addr_fw0_iss_o       = 6'b000000;
  assign rf_wr_addr_fw1_iss_o       = 6'b000000;
  assign rf_wr_addr_fw0_f1_o        = 6'b000000;
  assign rf_wr_addr_fw1_f1_o        = 6'b000000;
  assign rf_wr_addr_fw0_f2_o        = 6'b000000;
  assign rf_wr_addr_fw1_f2_o        = 6'b000000;
  assign rf_wr_en_fw0_iss_o         = 4'b0000;
  assign rf_wr_en_fw1_iss_o         = 4'b0000;
  assign rf_wr_en_fw0_f1_o          = 4'b0000;
  assign rf_wr_en_fw1_f1_o          = 4'b0000;
  assign rf_wr_en_fw0_f2_o          = 4'b0000;
  assign rf_wr_en_fw1_f2_o          = 4'b0000;
  assign rf_wr_when_fw0_iss_o       = 2'b00;
  assign rf_wr_when_fw1_iss_o       = 2'b00;
  assign rf_wr_when_fw0_f1_o        = 2'b00;
  assign rf_wr_when_fw1_f1_o        = 2'b00;
  assign rf_wr_when_fw0_f2_o        = 2'b00;
  assign rf_wr_when_fw1_f2_o        = 2'b00;

end endgenerate // FPU

  // ----------------------------------------------------
  // Exception logic
  // ----------------------------------------------------

  // Early exception detection and routing of trapping instructions in Iss
  ca53dpu_early_exception u_dpu_early_exception (
    // Inputs
    .clk                          (clk),
    .reset_n                      (reset_n),
    .DFTSE                        (DFTSE),
    .aarch64_state_i              (aarch64_state_i),
    .cpsr_mode_ret_i              (cpsr_mode_ret_i[4:0]),
    .ns_state_i                   (ns_state),
    .dpu_exception_level_i        (dpu_exception_level_i),
    .expt_instr_data_de_i         (expt_instr_data_de_i[`CA53_EXPT_INSTR_BUS_W-1:0]),
    .expt_instr_type_de_i         (expt_instr_type_de_i[(`CA53_EXPT_INSTR_TYPE_W-1):0]),
    .early_expt_enable_de_i       (early_expt_enable_de_i),
    .expt_cpacr_el1_fpen_i        (expt_cpacr_el1_fpen_i[1:0]),
    .expt_cpacr_asedis_i          (expt_cpacr_asedis_i),
    .expt_cptr_el2_tfp_i          (expt_cptr_el2_tfp_i),
    .expt_hcptr_tase_i            (expt_hcptr_tase_i),
    .expt_cptr_el2_tcpac_i        (expt_cptr_el2_tcpac_i),
    .flush_ret_i                  (flush_ret),
    .instr_size_ex1_i             (size_instr0_ex1),
    .cond_code_instr0_ex1_i       (cond_code_instr0_ex1[3:0]),
    .stall_iss_i                  (stall_iss),
    .ilock_stall_iss_i            (ilock_stall_iss),
    .stall_wr_i                   (stall_wr),
    .exception_valid_ex1_i        (exception_valid_ex1),
    .exception_valid_ex2_i        (exception_valid_ex2),
    .valid_instrs_de_i            (valid_instrs_de_i[0]),
    .valid_iss_en_i               (valid_iss_en),
    .quash_de_i                   (quash_de),
    .head_instr0_iss_i            (head_instr_iss[0]),
    .ifu_ifsr_i                   (ifu_ifsr_i[6:0]),
    .ifu_ifsr_stage2_i            (ifu_ifsr_stage2_i[1:0]),
    .aarch64_at_el_i              (aarch64_at_el_i),
    .cpsr_ilbit_ret_i             (cpsr_ilbit_ret_i),
    .in_halt_i                    (in_halt_i),
    .dbg_hlt_en_i                 (dbg_hlt_en_i),
    .dbg_bkpt_wpt_en_i            (dbg_bkpt_wpt_en_i),
    .dbg_halting_allowed_i        (dbg_halting_allowed_i),
    .dbg_os_lock_synced_i         (dbg_os_lock_synced_i),
    .dbg_double_lock_set_i        (dbg_double_lock_set_i),
    .pmn_useren_i                 (pmn_useren_i[3:0]),
    .mdscr_el1_tdcc_i             (mdscr_el1_tdcc_i),
    .hdcr_tdra_i                  (hdcr_tdra_i),
    .hdcr_tdosa_i                 (hdcr_tdosa_i),
    .hdcr_tda_i                   (hdcr_tda_i),
    .hdcr_tde_i                   (hdcr_tde_i),
    .hdcr_tpm_i                   (hdcr_tpm_i),
    .hdcr_tpmcr_i                 (hdcr_tpmcr_i),
    .mdcr_el3_tdosa_i             (mdcr_el3_tdosa_i),
    .mdcr_el3_tda_i               (mdcr_el3_tda_i),
    .mdcr_el3_tpm_i               (mdcr_el3_tpm_i),
    .hcr_trvm_i                   (hcr_trvm_i),
    .hcr_tdz_i                    (hcr_tdz_i),
    .hcr_tge_i                    (hcr_tge_i),
    .hcr_tvm_i                    (hcr_tvm_i),
    .hcr_ttlb_i                   (hcr_ttlb_i),
    .hcr_tpu_i                    (hcr_tpu_i),
    .hcr_tpc_i                    (hcr_tpc_i),
    .hcr_tsw_i                    (hcr_tsw_i),
    .hcr_tacr_i                   (hcr_tacr_i),
    .hcr_tidcp_i                  (hcr_tidcp_i),
    .hcr_tsc_i                    (hcr_tsc_i),
    .hcr_tid3_i                   (hcr_tid3_i),
    .hcr_tid2_i                   (hcr_tid2_i),
    .hcr_tid1_i                   (hcr_tid1_i),
    .hcr_tid0_i                   (hcr_tid0_i),
    .hcr_twe_i                    (hcr_twe_i),
    .hcr_twi_i                    (hcr_twi_i),
    .hcr_amo_i                    (hcr_amo_i),
    .hcr_imo_i                    (hcr_imo_i),
    .hcr_fmo_i                    (hcr_fmo_i),
    .hstr_trap_i                  (hstr_trap_cp15_i[13:0]),
    .cpuactlr_el3_i               (cpuactlr_el3_i),
    .cpuectlr_el3_i               (cpuectlr_el3_i),
    .l2ctlr_el3_i                 (l2ctlr_el3_i),
    .l2ectlr_el3_i                (l2ectlr_el3_i),
    .l2actlr_el3_i                (l2actlr_el3_i),
    .cpuactlr_el2_i               (cpuactlr_el2_i),
    .cpuectlr_el2_i               (cpuectlr_el2_i),
    .l2ctlr_el2_i                 (l2ctlr_el2_i),
    .l2ectlr_el2_i                (l2ectlr_el2_i),
    .l2actlr_el2_i                (l2actlr_el2_i),
    .cptr_el3_tcpac_i             (cptr_el3_tcpac_i),
    .cptr_el3_tfp_i               (cptr_el3_tfp_i),
    .cp_fpexc_en_i                (cp_fpexc_en_i),
    .sctlr_ntwe_i                 (sctlr_ntwe_i),
    .sctlr_ntwi_i                 (sctlr_ntwi_i),
    .sctlr_cp15ben_i              (sctlr_cp15ben_i),
    .sctlr_sed_i                  (sctlr_sed_i),
    .sctlr_el1_uci_i              (sctlr_el1_uci_i),
    .sctlr_el1_uct_i              (sctlr_el1_uct_i),
    .sctlr_el1_uma_i              (sctlr_el1_uma_i),
    .sctlr_el1_dze_i              (sctlr_el1_dze_i),
    .scr_el3_twi_i                (scr_el3_twi_i),
    .scr_el3_twe_i                (scr_el3_twe_i),
    .scr_el3_st_i                 (scr_el3_st_i),
    .scr_el3_hce_i                (scr_el3_hce_i),
    .scr_el3_smd_i                (scr_el3_smd_i),
    .scr_el3_ea_i                 (scr_ea_i),
    .scr_el3_irq_i                (scr_irq_i),
    .scr_el3_fiq_i                (scr_fiq_i),
    .edscr_sdd_i                  (edscr_sdd_i),
    .edscr_tda_i                  (edscr_tda_i),
    .gov_cntkctl_el1_el0pcten_i   (gov_cntkctl_el1_el0pcten_i),
    .gov_cntkctl_el1_el0vcten_i   (gov_cntkctl_el1_el0vcten_i),
    .gov_cntkctl_el1_el0pten_i    (gov_cntkctl_el1_el0pten_i),
    .gov_cntkctl_el1_el0vten_i    (gov_cntkctl_el1_el0vten_i),
    .gov_cnthctl_el2_el1pcen_i    (gov_cnthctl_el2_el1pcen_i),
    .gov_cnthctl_el2_el1pcten_i   (gov_cnthctl_el2_el1pcten_i),
    .gic_icc_sre_el1_ns_sre_i     (gic_icc_sre_el1_ns_sre_i),
    .gic_icc_sre_el1_s_sre_i      (gic_icc_sre_el1_s_sre_i),
    .gic_icc_sre_el2_enable_i     (gic_icc_sre_el2_enable_i),
    .gic_icc_sre_el2_sre_i        (gic_icc_sre_el2_sre_i),
    .gic_icc_sre_el3_enable_i     (gic_icc_sre_el3_enable_i),
    .gic_icc_sre_el3_sre_i        (gic_icc_sre_el3_sre_i),
    .gic_ich_hcr_el2_tall0_i      (gic_ich_hcr_el2_tall0_i),
    .gic_ich_hcr_el2_tall1_i      (gic_ich_hcr_el2_tall1_i),
    .gic_ich_hcr_el2_tc_i         (gic_ich_hcr_el2_tc_i),
    .cryptodisable_i              (cryptodisable_i),
    // Outputs
    .expt_full_pc_iss_o           (expt_full_pc_iss),
    .exception_valid_iss_o        (exception_valid_iss),
    .exception_data_wr_o          (exception_data_wr[`CA53_EXPT_BUS_W-1:0])
  );

  // Exception logic in Wr
  ca53dpu_exception u_dpu_exception (
    // Inputs
    .clk                          (clk),
    .reset_n                      (reset_n),
    .dpu_exception_level_i        (dpu_exception_level_i),
    .aarch64_state_i              (aarch64_state_i),
    .rvbaraddr_i                  (rvbaraddr_i[39:2]),
    .sctlr_ns_hivecs_i            (sctlr_ns_hivecs_i),
    .sctlr_s_hivecs_i             (sctlr_s_hivecs_i),
    .aarch64_at_el_i              (aarch64_at_el_i),
    .gic_fiq_i                    (gic_fiq_i),
    .gic_irq_i                    (gic_irq_i),
    .gic_vfiq_i                   (gic_vfiq_i),
    .gic_virq_i                   (gic_virq_i),
    .gov_sei_level_req_i          (gov_sei_level_req_i),
    .gov_vsei_level_req_i         (gov_vsei_level_req_i),
    .gov_rei_level_req_i          (gov_rei_level_req_i),
    .gov_int_active_i             (gov_int_active_i),
    .cc_pass_instr0_wr_i          (cc_pass_instr0_wr),
    .cc_pass_instr1_wr_i          (cc_pass_instr1_wr),
    .dcu_valid_dc3_i              (dcu_valid_dc3_i),
    .dcu_p_abort_dc3_i            (dcu_p_abort_dc3_i),
    .dcu_p_domain_dc3_i           (dcu_p_domain_dc3_i[3:0]),
    .dcu_p_fault_dc3_i            (dcu_p_fault_dc3_i[6:0]),
    .dcu_p_fault_stage_dc3_i      (dcu_p_fault_stage_dc3_i[1:0]),
    .dcu_p_direction_dc3_i        (dcu_p_direction_dc3_i),
    .dcu_ecc_err_dc3_i            (dcu_ecc_err_dc3_i),
    .dcu_cm_operation_dc3_i       (dcu_cm_operation_dc3_i),
    .dcu_va_dc3_i                 (dcu_va_dc3_i[63:0]),
    .dcu_pa_dc3_i                 (dcu_pa_dc3_i[39:12]),
    .dcu_v2p_lpae_dc3_i           (dcu_v2p_lpae_dc3_i),
    .dcu_wpt_hit_dc3_i            (dcu_wpt_hit_dc3_i),
    .tlb_lpae_mode_i              (tlb_lpae_mode_i),
    .tlb_lpae_mode_s_i            (tlb_lpae_mode_s_i),
    .biu_w_imp_abort_i            (biu_w_imp_abort_i),
    .biu_w_imp_fault_i            (biu_w_imp_fault_i[1:0]),
    .dpu_fe_valid_wr_i            (dpu_fe_valid_wr_i),
    .dpu_fe_valid_ret_i           (dpu_fe_valid_ret_i),
    .cpsr_ssbit_ret_i             (cpsr_ssbit_ret_i),
    .cpsr_ibit_ret_i              (cpsr_ibit_ret_i),
    .cpsr_fbit_ret_i              (cpsr_fbit_ret_i),
    .cpsr_abit_ret_i              (cpsr_abit_ret_i),
    .cpsr_mode_ret_i              (cpsr_mode_ret_i[4:0]),
    .stall_wr_i                   (stall_wr),
    .br_flush_ret_i               (br_flush_ret_i),
    .slot0_br_flush_wr_i          (slot0_br_flush_wr_i),
    .pre_valid_instrs_wr_i        (pre_valid_instrs_wr[1:0]),
    .pre_head_instr0_wr_i         (pre_head_instr_wr[0]),
    .unflushable_wr_i             (unflushable_wr),
    .no_interrupt_wr_i            (no_interrupt_wr),
    .ls_instr_type_wr_i           (ls_instr_type_wr_i[`CA53_LS_INSTR_TYPE_W-1:0]),
    .ls_isv_set_wr_i              (ls_isv_set_wr_i),
    .ls_synd_sf_wr_i              (ls_synd_sf_wr_i),
    .ls_valid_wr_i                (ls_valid_wr_i),
    .ls_size_wr_i                 (ls_size_wr_i[1:0]),
    .slot1_ls_wr_i                (slot1_ls_wr),
    .in_halt_i                    (in_halt_i),
    .edscr_intdis_i               (edscr_intdis_i[1:0]),
    .dbgen_synced_i               (dbgen_synced_i),
    .spiden_synced_i              (spiden_synced_i),
    .dbg_bkpt_wpt_en_i            (dbg_bkpt_wpt_en_i),
    .dbg_hw_halt_req_i            (dbg_hw_halt_req_i),
    .held_dbg_hw_halt_req_i       (held_dbg_hw_halt_req_i),
    .held_dbg_osuc_halt_req_i     (held_dbg_osuc_halt_req_i),
    .held_dbg_ext_hw_halt_req_i   (held_dbg_ext_hw_halt_req_i),
    .dbg_soft_step_active_i       (dbg_soft_step_active_i),
    .dbg_restart_qual_i           (dbg_restart_qual_i),
    .dbg_cancel_biu_i             (dbg_cancel_biu_i),
    .ss_enter_halt_i              (ss_enter_halt_i),
    .pc_instr0_wr_i               (pc_instr0_wr[63:0]),
    .pc_instr0_ret_i              (pc_instr0_ret[63:0]),
    .expt_slot1_ret_i             (expt_slot1_ret),
    .size_instr1_ret_i            (size_instr1_ret),
    .ifu_ifsr_i                   (ifu_ifsr_i[6:0]),
    .ifu_ifsr_stage2_i            (ifu_ifsr_stage2_i[1:0]),
    .ifu_ifsr_lpae_i              (ifu_ifsr_lpae_i),
    .ifu_ifar_i                   (ifu_ifar_i[31:1]),
    .ifu_hpfar_i                  (ifu_hpfar_i[27:0]),
    .cp_vbar_el3_i                (cp_vbar_el3_i[63:5]),
    .cp_vbar_el1_i                (cp_vbar_el1_i[63:5]),
    .cp_mvbar_i                   (cp_mvbar_i[31:5]),
    .cp_hvbar_i                   (cp_hvbar_i[63:5]),
    .hdcr_tde_i                   (hdcr_tde_i),
    .hcr_amo_i                    (hcr_amo_i),
    .hcr_imo_i                    (hcr_imo_i),
    .hcr_fmo_i                    (hcr_fmo_i),
    .scr_ea_i                     (scr_ea_i),
    .scr_fiq_i                    (scr_fiq_i),
    .scr_irq_i                    (scr_irq_i),
    .scr_aw_i                     (scr_aw_i),
    .scr_fw_i                     (scr_fw_i),
    .nxt_ns_scr_i                 (nxt_ns_scr_i),
    .hcr_tge_i                    (hcr_tge_i),
    .hcr_va_i                     (hcr_va_i),
    .hcr_vi_i                     (hcr_vi_i),
    .hcr_vf_i                     (hcr_vf_i),
    .cp_icimvau_i                 (cp_icimvau_i),
    .nxt_mon_el3_mode_ret_i       (nxt_mon_el3_mode_ret_i),
    .size_instr0_wr_i             (size_instr0_wr),
    .size_instr1_wr_i             (size_instr1_wr),
    .ls_synd_srt_wr_i             (ls_synd_srt_wr_i[4:0]),
    .raw_wfi_req_i                (raw_wfi_req),
    .raw_wfe_req_i                (raw_wfe_req),
    .nxt_wfx_ifu_halt_i           (nxt_wfx_ifu_halt),
    .wfx_stall_wr_i               (wfx_stall_wr),
    .thumb_instr0_wr_i            (thumb_instr0_wr),
    .thumb_instr1_wr_i            (thumb_instr1_wr),
    .isa_instr0_wr_i              (isa_instr0_wr[1:0]),
    .isa_instr0_ret_i             (isa_instr0_ret[1:0]),
    .exception_data_wr_i          (exception_data_wr[`CA53_EXPT_BUS_W-1:0]),
    .instr_type_wr_i              (instr_type_wr),
    .soft_step_isv_i              (soft_step_isv),
    .halt_step_isv_i              (halt_step_isv),
    .step_ex_i                    (step_ex),
    .fpu_interlock_iss_i          (fpu_interlock_iss),
    // Outputs
    .insert_forceop_ret_o         (insert_forceop_ret_o),
    .etm_trace_expt_o             (etm_trace_expt_o),
    .etm_trace_dbgentry_o         (etm_trace_dbgentry_o),
    .expt_dbgexit_o               (expt_dbgexit_o),
    .expt_flush_ret_o             (expt_flush_ret),
    .expt_quash_wr_o              (expt_quash_wr),
    .expt_ls_quash_wr_o           (expt_ls_quash_wr),
    .expt_slot1_wr_o              (expt_slot1_wr),
    .expt_quash_slot0_wr_o        (expt_quash_slot0_wr),
    .early_expt_dcu_wr_o          (early_expt_dcu_wr),
    .insert_forceop_wr_o          (insert_forceop_wr),
    .forceop_pc_ret_o             (forceop_pc_ret_o[63:0]),
    .expt_cpsr_wr_en_ret_o        (expt_cpsr_wr_en_ret_o),
    .expt_cpsr_wr_src_ret_o       (expt_cpsr_wr_src_ret_o),
    .expt_cpsr_mode_ret_o         (expt_cpsr_mode_ret_o),
    .forceop_valid_de_o           (forceop_valid_de),
    .forceop_valid_wr_o           (forceop_valid_wr),
    .dbg_halt_ecc_expt_de_o       (dbg_halt_ecc_expt_de),
    .forceop_pc_offset_ret_o      (forceop_pc_offset_ret_o[17:1]),
    .expt_in_halt_o               (expt_in_halt_o),
    .end_expt_in_halt_o           (end_expt_in_halt_o),
    .dbg_event_o                  (dbg_event_o),
    .dbg_event_halt_wr_o          (dbg_event_halt_wr_o),
    .dbg_ss_vld_expt_type_ret_o   (dbg_ss_vld_expt_type_ret_o),
    .dbg_expt_o                   (dbg_expt_o),
    .nxt_dbg_ifu_halt_o           (nxt_dbg_ifu_halt),
    .evnt_expt_taken_o            (evnt_expt_taken_o),
    .evnt_call_expt_taken_o       (evnt_call_expt_taken_o),
    .expt_quash_no_data_wr_o      (expt_quash_no_data_wr),
    .expt_status_moe_data_wr_o    (expt_status_moe_data_wr_o[3:0]),
    .expt_idle_o                  (expt_idle_o),
    .target_exception_level_o     (target_exception_level_o),
    .expt_fault_reg_en_wr_o       (expt_fault_reg_en_wr_o[`CA53_FAULT_REG_EN_W-1:0]),
    .expt_fault_reg_sel_wr_o      (expt_fault_reg_sel_wr_o),
    .expt_aa32_uses_el1_esr_wr_o  (expt_aa32_uses_el1_esr_wr_o),
    .expt_ifsr_wr_o               (expt_ifsr_wr_o[12:0]),
    .expt_dfsr_wr_o               (expt_dfsr_wr_o[12:0]),
    .expt_far_data_wr_o           (expt_far_data_wr_o[63:0]),
    .expt_hpfar_data_wr_o         (expt_hpfar_data_wr_o[27:0]),
    .expt_esr_data_wr_o           (expt_esr_data_wr_o),
    .clear_virtual_ea_o           (clear_virtual_ea_o),
    .wfi_expt_exception_pending_o (wfi_expt_exception_pending),
    .wfe_expt_exception_pending_o (wfe_expt_exception_pending),
    .expt_mon_mode_clear_ns_o     (expt_mon_mode_clear_ns_o),
    .expt_type_o                  (expt_type_o[`CA53_EXPT_TYPE_W-1:0]),
    .expt_type_l1_ecc_o           (expt_type_l1_ecc_o),
    .forceop_type_o               (forceop_type_o[`CA53_FORCEOP_TYPE_W-1:0]),
    .forceop_offset_o             (forceop_offset_o[`CA53_FORCEOP_OFFSET_W-1:0]),
    .forceop_aa64_o               (forceop_aa64_o),
    .ns_state_o                   (ns_state),
    .wfi_expt_wr_o                (wfi_expt_wr),
    .wfe_expt_wr_o                (wfe_expt_wr),
    .expt_serr_pending_o          (expt_serr_pending_o),
    .expt_irq_pending_o           (expt_irq_pending_o),
    .expt_fiq_pending_o           (expt_fiq_pending_o),
    .evnt_fiq_taken_o             (evnt_fiq_taken_o),
    .evnt_irq_taken_o             (evnt_irq_taken_o),
    .dpu_irq_pended_o             (dpu_irq_pended_o),
    .dpu_fiq_pended_o             (dpu_fiq_pended_o),
    .dpu_sei_pended_o             (dpu_sei_pended_o),
    .dpu_irq_masked_o             (dpu_irq_masked_o),
    .dpu_fiq_masked_o             (dpu_fiq_masked_o),
    .dpu_sei_masked_o             (dpu_sei_masked_o),
    .dpu_virq_pended_o            (dpu_virq_pended_o),
    .dpu_vfiq_pended_o            (dpu_vfiq_pended_o),
    .dpu_vsei_pended_o            (dpu_vsei_pended_o),
    .dpu_virq_masked_o            (dpu_virq_masked_o),
    .dpu_vfiq_masked_o            (dpu_vfiq_masked_o),
    .dpu_vsei_masked_o            (dpu_vsei_masked_o),
    .dpu_rei_level_ack_o          (dpu_rei_level_ack_o),
    .dpu_sei_level_ack_o          (dpu_sei_level_ack_o),
    .dpu_vsei_level_ack_o         (dpu_vsei_level_ack_o),
    .dpu_imp_abort_pending_o      (dpu_imp_abort_pending_o)
  );

  // ------------------------------------------------------
  // WFx Control
  // ------------------------------------------------------

  assign instr_sev_wr  = (instr_type_wr == `CA53_INSTR_TYPE_SEV)                         & valid_instrs_wr[0];
  assign instr_sevl_wr = (instr_type_wr == `CA53_INSTR_TYPE_SEVL)                        & valid_instrs_wr[0];
  assign instr_wfi_wr  = ((instr_type_wr == `CA53_INSTR_TYPE_WFI) |
                          ((instr_type_wr == `CA53_INSTR_TYPE_SYNC_EXPT) & wfi_expt_wr)) & valid_instrs_wr[0];
  assign instr_wfe_wr  = ((instr_type_wr == `CA53_INSTR_TYPE_WFE) |
                          ((instr_type_wr == `CA53_INSTR_TYPE_SYNC_EXPT) & wfe_expt_wr)) & valid_instrs_wr[0];

  // WFx and SEV qualification
  assign valid_wfx_or_sev_in_wr = cc_pass_instr0_wr & ~expt_quash_wr;

  // Calculate if a WFE or WFI instruction should try to enter standby
  assign raw_wfi_req = instr_wfi_wr & cc_pass_instr0_wr & ~dbgdscr_halted_i & ~wfi_expt_exception_pending;
  assign raw_wfe_req = instr_wfe_wr & cc_pass_instr0_wr & ~dbgdscr_halted_i & ~wfe_expt_exception_pending & ~expt_rtn_ret_i & ~ext_event_reg & ~local_event_reg;

  // Signal SEV, WFI, WFE or clear the event register
  assign nxt_sev_req            = instr_sev_wr & valid_wfx_or_sev_in_wr;
  assign nxt_wfi_req            = raw_wfi_req  & valid_wfx_or_sev_in_wr;
  assign nxt_wfe_req            = raw_wfe_req  & valid_wfx_or_sev_in_wr;
  assign nxt_clr_event_register = instr_wfe_wr & valid_wfx_or_sev_in_wr & ~raw_wfe_req;

  assign nxt_wfx_ifu_halt       = nxt_wfe_req | nxt_wfi_req;
  assign nxt_wfx_stall_wr       = nxt_wfx_ifu_halt | (wfx_stall_wr & ~gov_wfx_wake_i);

  // Keep a local copy of the event register which considers only synchronous set events
  assign nxt_local_event_reg   = ~nxt_clr_event_register &
                                 (local_event_reg                           |
                                  nxt_sev_req                               | // a SEV instruction
                                  (instr_sevl_wr & valid_wfx_or_sev_in_wr)  | // a SEVL instruction
                                  nxt_dbg_ifu_halt                          | // a debug event that causes entry into Debug state
                                  expt_rtn_ret_i);                            // an exception return

  // Force the WFx into a NOP.  This is done whenever a valid WFx instruction is in Wr,
  // and the FSM does not move into the DRAIN state in the next cycle.  In this case the
  // WFx becomes a NOP and the branch packet following behind the WFx needs to be nullified.
  assign force_wfx_nop_o = (instr_wfe_wr | instr_wfi_wr) & ~nxt_wfx_ifu_halt;

  assign nxt_dpu_halt_ifu = nxt_wfx_ifu_halt | nxt_dbg_ifu_halt;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dpu_sev_req_o            <= 1'b0;
      dpu_clr_event_register_o <= 1'b0;
      dpu_wfi_req_o            <= 1'b0;
      dpu_wfe_req_o            <= 1'b0;
      dpu_halt_ifu_o           <= 1'b0;
      wfx_ifu_halt             <= 1'b0;
      wfx_stall_wr             <= 1'b0;
      ext_event_reg            <= 1'b0;
      local_event_reg          <= 1'b0;
    end else begin
      dpu_sev_req_o            <= nxt_sev_req;
      dpu_clr_event_register_o <= nxt_clr_event_register;
      dpu_wfi_req_o            <= nxt_wfi_req;
      dpu_wfe_req_o            <= nxt_wfe_req;
      dpu_halt_ifu_o           <= nxt_dpu_halt_ifu;
      wfx_ifu_halt             <= nxt_wfx_ifu_halt;
      wfx_stall_wr             <= nxt_wfx_stall_wr;
      ext_event_reg            <= gov_event_reg_i;
      local_event_reg          <= nxt_local_event_reg;
    end

  // ------------------------------------------------------
  // Output assignments
  // ------------------------------------------------------

  // ETM interface
  assign pre_valid_instrs_wr_o      = pre_valid_instrs_wr[0];
  assign valid_instrs_wr_o[1:0]     = valid_instrs_wr;
  assign pc_instr0_wr_o             = pc_instr0_wr;
  assign cc_pass_instr0_wr_o        = cc_pass_instr0_wr;
  assign cc_pass_instr1_wr_o        = cc_pass_instr1_wr;
  assign size_instr0_wr_o           = size_instr0_wr;
  assign size_instr1_wr_o           = size_instr1_wr;

  // Branch pipeline interface
  assign pc_instr0_ex2_o[48:1]      = pc_instr0_ex2[48:1];
  assign isa_instr0_ex2_o[1:0]      = isa_instr0_ex2[1:0];
  assign isa_instr0_wr_o[1:0]       = isa_instr0_wr[1:0];
  assign size_instr0_ex2_o          = size_instr0_ex2;
  assign size_instr1_ex2_o          = size_instr1_ex2;
  assign nxt_wfx_ifu_halt_o         = nxt_wfx_ifu_halt;
  assign wfx_ifu_halt_o             = wfx_ifu_halt;

  // Register file interface
  assign rf_wr_addr_w0_wr_o[5:0]    = rf_wr_addr_w0_wr;
  assign rf_wr_addr_w1_wr_o[5:0]    = rf_wr_addr_w1_wr;
  assign rf_wr_addr_w2_wr_o[5:0]    = rf_wr_addr_w2_wr;
  assign rf_wr_64b_w0_wr_o          = rf_wr_64b_w0_wr;
  assign rf_wr_64b_w1_wr_o          = rf_wr_64b_w1_wr;
  assign rf_wr_64b_w2_wr_o          = rf_wr_64b_w2_wr;
  assign rf_wr_src_w0_wr_o          = rf_wr_src_w0_wr;
  assign rf_wr_src_w1_wr_o          = rf_wr_src_w1_wr;
  assign rf_wr_src_w2_wr_o          = rf_wr_src_w2_wr;
  assign rf_wr_en_hi_wr_o           = rf_wr_en_hi_wr;
  assign rf_wr_en_lo_wr_o           = rf_wr_en_lo_wr;
  assign rf_wr_en_w0_wr_o           = rf_wr_en_w0_wr;
  assign rf_wr_en_w1_wr_o           = rf_wr_en_w1_wr;
  assign rf_wr_en_w2_wr_o           = rf_wr_en_w2_wr;
  assign aarch64_state_iss_o        = aarch64_state_iss;

  // Datapath control interface
  assign use_ex1_alu_0_iss_o        = use_ex1_alu_0_iss;
  assign use_ex1_alu_1_iss_o        = use_ex1_alu_1_iss;
  assign alu0_msk_data_sel_iss_o    = alu0_msk_data_sel_iss;
  assign alu1_msk_data_sel_iss_o    = alu1_msk_data_sel_iss;
  assign alu0_data_a_sel_iss_o      = alu0_data_a_sel_iss;
  assign alu0_data_b_sel_iss_o      = alu0_data_b_sel_iss;
  assign alu0_data_c_sel_iss_o      = alu0_data_c_sel_iss;
  assign mac_data_a_sel_iss_o       = mac_data_a_sel_iss;
  assign mac_data_b_sel_iss_o       = mac_data_b_sel_iss;
  assign div_data_a_sel_iss_o       = div_data_a_sel_iss;
  assign div_data_b_sel_iss_o       = div_data_b_sel_iss;
  assign alu1_data_a_sel_iss_o      = alu1_data_a_sel_iss;
  assign alu1_data_b_sel_iss_o      = alu1_data_b_sel_iss;
  assign alu1_data_c_sel_iss_o      = alu1_data_c_sel_iss;
  assign mac_iss_ctl_iss_o          = mac_pipectl_iss[`CA53_MAC_PIPECTL_MAC_ISS_CTL_BITS];
  assign ctl_64bit_op_mac_iss_o     = mac_pipectl_iss[`CA53_MAC_PIPECTL_MAC_GEN_CTL_BITS];
  assign alu0_ex1_ctl_iss_o         = alu0_pipectl_iss[`CA53_ALU_PIPECTL_ALU_EX1_CTL_BITS];
  assign alu0_ex2_ctl_iss_o         = alu0_pipectl_iss[`CA53_ALU_PIPECTL_ALU_EX2_CTL_BITS];
  assign alu0_wr_ctl_iss_o          = alu0_pipectl_iss[`CA53_ALU_PIPECTL_ALU_WR_CTL_BITS];
  assign ctl_64bit_op_alu0_iss_o    = alu0_pipectl_iss[`CA53_ALU_PIPECTL_ALU_GEN_CTL_BITS];
  assign alu1_ex1_ctl_iss_o         = alu1_pipectl_iss[`CA53_ALU_PIPECTL_ALU_EX1_CTL_BITS];
  assign alu1_ex2_ctl_iss_o         = alu1_pipectl_iss[`CA53_ALU_PIPECTL_ALU_EX2_CTL_BITS];
  assign alu1_wr_ctl_iss_o          = alu1_pipectl_iss[`CA53_ALU_PIPECTL_ALU_WR_CTL_BITS];
  assign ctl_64bit_op_alu1_iss_o    = alu1_pipectl_iss[`CA53_ALU_PIPECTL_ALU_GEN_CTL_BITS];
  assign msr_mrs_data_wr_o          = msr_mrs_data_wr;

  // General control interface
  assign end_instr_iss_o            = end_instr_iss & ~special_stall_iss;
  assign interlock_iss_o            = interlock_iss;
  assign stall_iss_o                = stall_iss;
  assign stall_slot0_iss_o          = stall_slot0_iss;
  assign ilock_stall_iss_o          = ilock_stall_iss;
  assign stall_ex1_o                = stall_ex1_no_sfmac;
  assign stall_ex2_o                = stall_ex2_no_sfmac;
  assign stall_wr_o                 = stall_wr;
  assign nxt_div_stall_wr_o         = nxt_div_stall_wr;
  assign valid_instrs_iss_o         = valid_instrs_iss;
  assign isa_instr0_iss_o[1:0]      = isa_instr0_iss[1:0];
  assign size_instr0_iss_o          = size_instr0_iss;
  assign size_instr1_iss_o          = size_instr1_iss;
  assign size_instr0_ret_o          = size_instr0_ret;
  assign size_instr1_ret_o          = size_instr1_ret;
  assign expt_slot1_ret_o           = expt_slot1_ret;
  assign thumb_instr0_iss_o         = thumb_instr0_iss;
  assign br_x_bit_iss_o             = br_x_bit_iss;
  assign issue_to_iss_o             = issue_to_iss;
  assign issue_to_iss_fpu_o         = issue_to_iss_fpu;
  assign issue_to_ex1_o             = issue_to_ex1;
  assign issue_to_ex2_o             = issue_to_ex2;
  assign issue_to_ex2_fpu_o         = issue_to_ex2_fpu;
  assign issue_to_wr_o              = issue_to_wr;
  assign issue_to_f4_o              = issue_to_f4;
  assign raw_alu0_valid_iss_o       = raw_alu0_valid_iss;
  assign raw_alu1_valid_iss_o       = raw_alu1_valid_iss;
  assign alu0_valid_iss_o           = alu0_valid_iss;
  assign alu1_valid_iss_o           = alu1_valid_iss;
  assign raw_str0_valid_iss_o       = raw_str0_valid_iss;
  assign str0_a_valid_iss_o         = str0_a_valid_iss;
  assign str0_b_valid_iss_o         = str0_b_valid_iss;
  assign ctl_64bit_op_str0_iss_o    = ctl_64bit_op_str0_iss;
  assign raw_str1_valid_iss_o       = raw_str1_valid_iss;
  assign str1_a_valid_iss_o         = str1_a_valid_iss;
  assign str1_b_valid_iss_o         = str1_b_valid_iss;
  assign ctl_64bit_op_str1_iss_o    = ctl_64bit_op_str1_iss;
  assign raw_mac_valid_iss_o        = raw_mac_valid_iss;
  assign mac_valid_iss_o            = mac_valid_iss;
  assign div_valid_iss_o            = div_valid_iss;
  assign raw_div_valid_iss_o        = raw_div_valid_iss;
  assign wd_align_pc_alu0_iss_o     = wd_align_pc_alu0_iss;
  assign wd_align_pc_alu1_iss_o     = wd_align_pc_alu1_iss;
  assign wd_align_pc_ls_iss_o       = wd_align_pc_ls_iss;
  assign pg_align_pc_ls_iss_o       = pg_align_pc_ls_iss;
  assign str0_data_a_sel_iss_o      = str0_data_a_sel_iss;
  assign str0_data_b_sel_iss_o      = str0_data_b_sel_iss;
  assign str1_data_a_sel_iss_o      = str1_data_a_sel_iss;
  assign str1_data_b_sel_iss_o      = str1_data_b_sel_iss;
  assign prefetch_abort_iss_o       = expt_full_pc_iss;
  assign pc_instr0_ret_o[63:0]      = pc_instr0_ret[63:0];
  assign thumb_instr0_ret_o         = isa_instr0_ret[0];
  assign thumb_instr1_ret_o         = thumb_instr1_ret;
  assign end_instr_wr_o             = end_instr_wr;
  assign pre_end_instr_wr_o         = pre_end_instr_wr;
  assign end_instr_no_quash_wr_o    = end_instr_no_quash_wr;
  assign end_instr_dbg_wr_o         = end_instr_wr | expt_quash_wr;
  assign isb_wr_o                   = (instr_type_wr == `CA53_INSTR_TYPE_ISB);
  assign slot1_ls_ex2_o             = slot1_ls_ex2;
  assign slot1_branch_iss_o         = slot1_branch_iss;
  assign slot1_branch_ex2_o         = slot1_branch_ex2;
  assign slot1_branch_wr_o          = slot1_branch_wr;
  assign slot1_blx_ex2_o            = (slot1_instr_type_ex2 == `CA53_SLOT1_INSTR_TYPE_BLX);
  assign slot1_bx_wr_o              = (slot1_instr_type_wr  == `CA53_SLOT1_INSTR_TYPE_BX);
  assign slot1_blx_wr_o             = (slot1_instr_type_wr  == `CA53_SLOT1_INSTR_TYPE_BLX);
  assign slot1_mul_iss_o            = slot1_mul_iss;
  assign slot1_mul_wr_o             = slot1_mul_wr;
  assign w0_slot1_wr_o              = w0_slot1_wr;
  assign exception_valid_iss_o      = exception_valid_iss;
  assign exception_valid_ex1_o      = exception_valid_ex1;
  assign expt_slot1_wr_o            = expt_slot1_wr;
  assign advance_pipeline_o         = advance_pipeline;
  assign str0_sel_fp_f1_o           = str0_sel_fp_f1;
  assign str1_sel_fp_f1_o           = str1_sel_fp_f1;
  assign str0_sel_fp_f2_o           = str0_sel_fp_f2;
  assign str1_sel_fp_f2_o           = str1_sel_fp_f2;

  // Flag setting logic
  assign cond_code_instr0_ex2_o     = cond_code_instr0_ex2;
  assign cond_code_instr1_ex2_o     = cond_code_instr1_ex2;

  // Control to cc flag mux in ALU.
  // When valid muls in Wr, then mux in nz flags from MAC.
  assign sel_mac_nzflags_wr_o       = muls_in_wr & (slot1_mul_wr ? (valid_instrs_wr[1] & cc_pass_instr1_wr)
                                                                 : (valid_instrs_wr[0] & cc_pass_instr0_wr));

  // Exception interface
  assign insert_forceop_wr_o        = insert_forceop_wr;
  assign forceop_valid_de_o         = forceop_valid_de;
  assign forceop_valid_iss_o        = forceop_valid_iss;
  assign forceop_valid_wr_o         = forceop_valid_wr;
  assign dbg_halt_ecc_expt_iss_o    = dbg_halt_ecc_expt_iss;
  assign div_flush_o                = div_flush;
  assign flush_wr_o                 = flush_wr;
  assign flush_ls_wr_o              = flush_ls_wr;
  assign flush_ret_o                = flush_ret;
  assign expt_quash_wr_o            = expt_quash_wr;
  assign quash_slot0_wr_o           = quash_slot0_wr;
  assign quash_wr_o                 = quash_wr;
  assign quash_ex2_o                = quash_ex2;
  assign quash_ex1_o                = quash_ex1;
  assign quash_iss_o                = quash_iss;
  assign ns_state_o                 = ns_state;

  // Load-store interface
  assign dpu_flush_o                = flush_ls_wr;
  assign dpu_kill_wr_o              = flush_ls_ret;

  // To Debug logic
  assign isa_instr0_ret_o[1:0]      = isa_instr0_ret[1:0];
  assign no_interrupt_wr_o          = no_interrupt_wr;

  // To AGU forwarding mux
  assign sel_fwd_addr_dcu_a_iss_o   = sel_fwd_addr_dcu_a_iss;

  // Peformance monitor interface
  assign evnt_instr_exec_o          = head_instr_wr[1:0] & {2{~stall_wr}};
  assign evnt_ls_instr_wr_o         = slot1_ls_wr ? (pre_head_instr_wr[1] & cc_pass_instr1_wr & ~slot0_br_flush_wr_i)
                                                  : (pre_head_instr_wr[0] & cc_pass_instr0_wr);

  // instr1 general control
  assign flag_en_instr1_wr_o        = flag_en_instr1_wr[`CA53_FLAGEN_INSTR1_W-1:0];

  // iq hazard
  assign rf_wr_en_w0_iss_o          = raw_rf_wr_en_w0_iss;
  assign rf_wr_en_w1_iss_o          = raw_rf_wr_en_w1_iss;
  assign rf_wr_en_w2_iss_o          = raw_rf_wr_en_w2_iss;

  assign rf_wr_when_w0_iss_o        = rf_wr_when_w0_iss[WHN_NOT_EX2:WHN_NOT_EX1]; // Early Wr not used
  assign rf_wr_when_w1_iss_o        = rf_wr_when_w1_iss[WHN_NOT_EX2:WHN_NOT_EX1];
  assign rf_wr_when_w2_iss_o        = rf_wr_when_w2_iss[WHN_NOT_EX2:WHN_NOT_EX1];
                                 
  assign rf_wr_vaddr_w0_iss_o       = rf_wr_vaddr_w0_iss;
  assign rf_wr_vaddr_w1_iss_o       = rf_wr_vaddr_w1_iss;
  assign rf_wr_vaddr_w2_iss_o       = rf_wr_vaddr_w2_iss;
                                 
  assign rf_wr_en_w0_ex1_o          = raw_rf_wr_en_w0_ex1;
  assign rf_wr_en_w1_ex1_o          = raw_rf_wr_en_w1_ex1;
  assign rf_wr_en_w2_ex1_o          = raw_rf_wr_en_w2_ex1;
                                 
  assign rf_wr_when_w0_ex1_o        = rf_wr_when_w0_ex1[WHN_NOT_EX2:WHN_NOT_EX1]; // Early Wr not used
  assign rf_wr_when_w1_ex1_o        = rf_wr_when_w1_ex1[WHN_NOT_EX2:WHN_NOT_EX1];
  assign rf_wr_when_w2_ex1_o        = rf_wr_when_w2_ex1[WHN_NOT_EX2:WHN_NOT_EX1];

  assign rf_wr_vaddr_w0_ex1_o       = rf_wr_vaddr_w0_ex1;
  assign rf_wr_vaddr_w1_ex1_o       = rf_wr_vaddr_w1_ex1;
  assign rf_wr_vaddr_w2_ex1_o       = rf_wr_vaddr_w2_ex1;

  // Base register save control signal
  assign save_base_ex2_o            = save_base_ex2;

  //----------------------------------------------------------------------------
  //                     OVL definitions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  reg    ovl_r0_w0_ex2_cmp_iss, ovl_r0_w1_ex2_cmp_iss, ovl_r0_w2_ex2_cmp_iss;
  reg    ovl_r1_w0_ex2_cmp_iss, ovl_r1_w1_ex2_cmp_iss, ovl_r1_w2_ex2_cmp_iss;
  reg    ovl_r0_w0_wr_cmp_iss,  ovl_r0_w1_wr_cmp_iss,  ovl_r0_w2_wr_cmp_iss;
  reg    ovl_r1_w0_wr_cmp_iss,  ovl_r1_w1_wr_cmp_iss,  ovl_r1_w2_wr_cmp_iss;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ovl_r0_w0_ex2_cmp_iss <= 1'b0;
      ovl_r0_w1_ex2_cmp_iss <= 1'b0;
      ovl_r0_w2_ex2_cmp_iss <= 1'b0;
      ovl_r1_w0_ex2_cmp_iss <= 1'b0;
      ovl_r1_w1_ex2_cmp_iss <= 1'b0;
      ovl_r1_w2_ex2_cmp_iss <= 1'b0;
      ovl_r0_w0_wr_cmp_iss  <= 1'b0;
      ovl_r0_w1_wr_cmp_iss  <= 1'b0;
      ovl_r0_w2_wr_cmp_iss  <= 1'b0;
      ovl_r1_w0_wr_cmp_iss  <= 1'b0;
      ovl_r1_w1_wr_cmp_iss  <= 1'b0;
      ovl_r1_w2_wr_cmp_iss  <= 1'b0;
    end
    else begin
      ovl_r0_w0_ex2_cmp_iss <= nxt_early_addr_cmp_iss_ex2[R0][W0] & ~flush_wr;
      ovl_r0_w1_ex2_cmp_iss <= nxt_early_addr_cmp_iss_ex2[R0][W1] & ~flush_wr;
      ovl_r0_w2_ex2_cmp_iss <= nxt_early_addr_cmp_iss_ex2[R0][W2] & ~flush_wr;
      ovl_r1_w0_ex2_cmp_iss <= nxt_early_addr_cmp_iss_ex2[R1][W0] & ~flush_wr;
      ovl_r1_w1_ex2_cmp_iss <= nxt_early_addr_cmp_iss_ex2[R1][W1] & ~flush_wr;
      ovl_r1_w2_ex2_cmp_iss <= nxt_early_addr_cmp_iss_ex2[R1][W2] & ~flush_wr;
      ovl_r0_w0_wr_cmp_iss  <= nxt_early_addr_cmp_iss_wr[R0][W0]  & ~flush_wr;
      ovl_r0_w1_wr_cmp_iss  <= nxt_early_addr_cmp_iss_wr[R0][W1]  & ~flush_wr;
      ovl_r0_w2_wr_cmp_iss  <= nxt_early_addr_cmp_iss_wr[R0][W2]  & ~flush_wr;
      ovl_r1_w0_wr_cmp_iss  <= nxt_early_addr_cmp_iss_wr[R1][W0]  & ~flush_wr;
      ovl_r1_w1_wr_cmp_iss  <= nxt_early_addr_cmp_iss_wr[R1][W1]  & ~flush_wr;
      ovl_r1_w2_wr_cmp_iss  <= nxt_early_addr_cmp_iss_wr[R1][W2]  & ~flush_wr;
    end

  //----------------------------------------------------------------------------
  // Exceptions in debug state with EDSCR.SDD set never switch to secure state
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exceptions in debug state with EDSCR.SDD set never switch to secure state")
    ovl_expt_dbg_sdd_el3 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (in_halt_i & edscr_sdd_i),
                          .consequent_expr  (~(~u_dpu_exception.nxt_ns_state & ns_state)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Can never be in AArch64 state and Thumb state at the same time
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Instr 0 should not be Thumb while in AArch64")
    ovl_aa64_thumb0  (.clk              (clk),
                      .reset_n          (reset_n),
                      .antecedent_expr  (valid_instrs_de_i[0] & ~forceop_valid_de),
                      .consequent_expr  (~(aarch64_state_i & thumb_instr0_de_i)));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Instr 1 should not be Thumb while in AArch64")
    ovl_aa64_thumb1  (.clk              (clk),
                      .reset_n          (reset_n),
                      .antecedent_expr  (valid_instrs_de_i[1] & ~forceop_valid_de),
                      .consequent_expr  (~(aarch64_state_i & thumb_instr1_de_i)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Can never be in non-secure EL1 when HCR.TGE is set
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Should not be in nS EL1 when HCR.TGE set")
    ovl_tge_ns_el1   (.clk              (clk),
                      .reset_n          (reset_n),
                      .antecedent_expr  (hcr_tge_i),
                      .consequent_expr  (~(ns_state & (dpu_exception_level_i == `CA53_EL1))));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // PC must be in 32-bit range when in AArch32
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"PC must be in 32-bit range when in AArch32")
    ovl_32bit_pc_aa32  (.clk              (clk),
                        .reset_n          (reset_n),
                        .antecedent_expr  (valid_instrs_wr[0] & ~forceop_valid_wr & ~unflushable_wr & ~aarch64_state_i),
                        .consequent_expr  (pc_instr0_wr[63:32] == {32{1'b0}}));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Check for invalid encoding
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Bad valid_instrs_iss encoding")
    ovl_dpu_ctl_valid_instrs_iss (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .test_expr (valid_instrs_iss == 2'b10));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Check for invalid encoding
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Bad valid_instrs_ex1 encoding")
    ovl_dpu_ctl_valid_instrs_ex1 (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .test_expr (valid_instrs_ex1 == 2'b10));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Check for invalid encoding
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Bad valid_instrs_ex2 encoding")
    ovl_dpu_ctl_valid_instrs_ex2 (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .test_expr (valid_instrs_ex2 == 2'b10));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Check for invalid encoding
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Bad valid_instrs_wr encoding")
    ovl_dpu_ctl_valid_instrs_wr (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .test_expr (valid_instrs_wr == 2'b10));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Simultaneous write access to same port is forbidden
  //----------------------------------------------------------------------------

  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"The w0, w1 or w2 write ports refer to same register in same cycle")
    ovl_dpu_ctl_sim_wr (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr ((rf_wr_addr_w0_wr_o == rf_wr_addr_w1_wr_o & rf_wr_en_w0_wr_o & rf_wr_en_w1_wr_o) |
                                    (rf_wr_addr_w0_wr_o == rf_wr_addr_w2_wr_o & rf_wr_en_w0_wr_o & rf_wr_en_w2_wr_o) |
                                    (rf_wr_addr_w1_wr_o == rf_wr_addr_w2_wr_o & rf_wr_en_w1_wr_o & rf_wr_en_w2_wr_o)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Check that forward path selector to DCU_A is zero one-hot
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_zero_one_hot #(`OVL_FATAL,`CA53_SEL_FWD_DCU_W,`OVL_ASSERT,"sel_fwd_dcu_a_iss_o should be zero one-hot")
    ovl_dpu_ctl_sel_fwd_dcu_a_zoh (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .test_expr (sel_fwd_dcu_a_iss_o & {`CA53_SEL_FWD_DCU_W{rf_rd_en_r0_iss & ls_valid_iss_i & ~interlock_iss & ~flush_ret}}));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Check that forward path selector to DCU_B is zero one-hot
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_zero_one_hot #(`OVL_FATAL,`CA53_SEL_FWD_DCU_W,`OVL_ASSERT,"sel_fwd_dcu_b_iss_o should be zero one-hot")
    ovl_dpu_ctl_sel_fwd_dcu_b_zoh (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .test_expr (sel_fwd_dcu_b_iss_o & {`CA53_SEL_FWD_DCU_W{rf_rd_en_r1_iss & ls_valid_iss_i & ~interlock_iss & ~flush_ret}}));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Since Write-after-write hazards are resolved in Ex2, early_addr_cmp signals
  // must be one-hot in Wr
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_zero_one_hot #(`OVL_FATAL,3,`OVL_ASSERT,"early_addr_cmp_iss_wr[R0] not zero/one_hot")
    ovl_addr_cmp_iss_wr_r0_oneh   (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .test_expr ({3{rf_rd_en_r0_iss & ls_valid_iss_i & ~interlock_iss & ~flush_ret}} & early_addr_cmp_iss_wr[R0][W2:W0]));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_zero_one_hot #(`OVL_FATAL,3,`OVL_ASSERT,"early_addr_cmp_iss_wr[R1] not zero/one_hot")
    ovl_addr_cmp_iss_wr_r1_oneh   (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .test_expr ({3{rf_rd_en_r1_iss & ls_valid_iss_i & ~interlock_iss & ~flush_ret}} & early_addr_cmp_iss_wr[R1][W2:W0]));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Check that the new base from an LS instruction is forwarding back to
  // the next LS instruction
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  wire ovl_slot1_ls_ex1     = (slot1_instr_type_ex1 == `CA53_SLOT1_INSTR_TYPE_LS);
  reg ovl_cp_iss;
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_cp_iss <= 1'b0;
    else if (~stall_iss)
      ovl_cp_iss <= cp_de_i;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"IPC hit as the base from the previous LS is not forwarding back")
    ovl_agu_forward (.clk             (clk),
                     .reset_n         (reset_n),
                     .antecedent_expr (ls_valid_ex1_i & ls_valid_iss_i & ~ovl_cp_iss & can_fwd_from_agu_ex1 & ~second_x64_iss_i &
                                       ~last_lsm_skidding_i & rf_rd_en_r0_iss &
                                       (ovl_slot1_ls_ex1 ? (rf_rd_addr_r0_iss == rf_wr_addr_w2_ex1) // Slot 1 LS doing WB on W2
                                                         : (rf_rd_addr_r0_iss == rf_wr_addr_w1_ex1) & ~(rf_rd_addr_r0_iss == rf_wr_addr_w2_ex1 & rf_wr_en_w2_ex1))),// Slot 0 LS doing WB on W1 and no later DP writing same register on W2 in slot 1
                     .consequent_expr (sel_fwd_addr_dcu_a_iss));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // cc_pass_instr0 has taken an unknown (X) value
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT,"cc_pass_instr0 is X")
    ovl_cc_pass_0_undef (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (cc_pass_instr0_wr & valid_instrs_wr[0]));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // cc_pass_instr1 has taken an unknown (X) value
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT,"cc_pass_instr1 is X")
    ovl_cc_pass_1_undef (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (cc_pass_instr1_wr & valid_instrs_wr[1]));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Checks for illegal select signal combinations for r0 fowarding mux
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"r0 forwarding control illegal")
    ovl_fwd_r0_ill (.clk             (clk),
                    .reset_n         (reset_n),
                    .antecedent_expr (rf_rd_en_r0_iss),
                    .consequent_expr ((r0_fwd_iss_o == `CA53_FWD_W0)       |
                                      (r0_fwd_iss_o == `CA53_FWD_W1)       |
                                      (r0_fwd_iss_o == `CA53_FWD_W2)       |
                                      (r0_fwd_iss_o == `CA53_FWD_ALU0_EX2) |
                                      (r0_fwd_iss_o == `CA53_FWD_ALU1_EX2) |
                                      (r0_fwd_iss_o == `CA53_FWD_ALU0_EX1) |
                                      (r0_fwd_iss_o == `CA53_FWD_ALU1_EX1) |
                                      (r0_fwd_iss_o == `CA53_FWD_NULL)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Checks for illegal select signal combinations for r1 fowarding mux
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"r1 forwarding control illegal")
    ovl_fwd_r1_ill (.clk             (clk),
                    .reset_n         (reset_n),
                    .antecedent_expr (rf_rd_en_r1_iss),
                    .consequent_expr ((r1_fwd_iss_o == `CA53_FWD_W0)       |
                                      (r1_fwd_iss_o == `CA53_FWD_W1)       |
                                      (r1_fwd_iss_o == `CA53_FWD_W2)       |
                                      (r1_fwd_iss_o == `CA53_FWD_ALU0_EX2) |
                                      (r1_fwd_iss_o == `CA53_FWD_ALU1_EX2) |
                                      (r1_fwd_iss_o == `CA53_FWD_ALU0_EX1) |
                                      (r1_fwd_iss_o == `CA53_FWD_ALU1_EX1) |
                                      (r1_fwd_iss_o == `CA53_FWD_NULL)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Checks for illegal select signal combinations for r2 fowarding mux
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"r2 forwarding control illegal")
    ovl_fwd_r2_ill (.clk             (clk),
                    .reset_n         (reset_n),
                    .antecedent_expr (rf_rd_en_r2_iss),
                    .consequent_expr ((r2_fwd_iss_o == `CA53_FWD_W0)       |
                                      (r2_fwd_iss_o == `CA53_FWD_W1)       |
                                      (r2_fwd_iss_o == `CA53_FWD_W2)       |
                                      (r2_fwd_iss_o == `CA53_FWD_ALU0_EX2) |
                                      (r2_fwd_iss_o == `CA53_FWD_ALU1_EX2) |
                                      (r2_fwd_iss_o == `CA53_FWD_ALU0_EX1) |
                                      (r2_fwd_iss_o == `CA53_FWD_ALU1_EX1) |
                                      (r2_fwd_iss_o == `CA53_FWD_NULL)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Checks for illegal select signal combinations for r3 fowarding mux
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"r3 forwarding control illegal")
    ovl_fwd_r3_ill (.clk             (clk),
                    .reset_n         (reset_n),
                    .antecedent_expr (rf_rd_en_r3_iss),
                    .consequent_expr ((r3_fwd_iss_o == `CA53_FWD_W0)       |
                                      (r3_fwd_iss_o == `CA53_FWD_W1)       |
                                      (r3_fwd_iss_o == `CA53_FWD_W2)       |
                                      (r3_fwd_iss_o == `CA53_FWD_ALU0_EX2) |
                                      (r3_fwd_iss_o == `CA53_FWD_ALU1_EX2) |
                                      (r3_fwd_iss_o == `CA53_FWD_ALU0_EX1) |
                                      (r3_fwd_iss_o == `CA53_FWD_ALU1_EX1) |
                                      (r3_fwd_iss_o == `CA53_FWD_NULL)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Checks for illegal select signal combinations for r4 fowarding mux
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"r4 forwarding control illegal")
    ovl_fwd_r4_ill (.clk             (clk),
                    .reset_n         (reset_n),
                    .antecedent_expr (rf_rd_en_r4_iss),
                    .consequent_expr ((r4_fwd_iss_o == `CA53_FWD_W0)       |
                                      (r4_fwd_iss_o == `CA53_FWD_W1)       |
                                      (r4_fwd_iss_o == `CA53_FWD_W2)       |
                                      (r4_fwd_iss_o == `CA53_FWD_ALU0_EX2) |
                                      (r4_fwd_iss_o == `CA53_FWD_ALU1_EX2) |
                                      (r4_fwd_iss_o == `CA53_FWD_ALU0_EX1) |
                                      (r4_fwd_iss_o == `CA53_FWD_ALU1_EX1) |
                                      (r4_fwd_iss_o == `CA53_FWD_NULL)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Checks for illegal select signal combinations into the GPRF write port 0
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Illegal select for data into the integer register file W0")
  ovl_illegal_rf_wr_src_w0 (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_wr_en_w0_wr_o),
    .consequent_expr ((rf_wr_src_w0_wr_o == `CA53_RF_WR_SRC_W0_DCU_0)   ||
                      (rf_wr_src_w0_wr_o == `CA53_RF_WR_SRC_W0_CPSR)    ||
                      (rf_wr_src_w0_wr_o == `CA53_RF_WR_SRC_W0_MAC_HI)  ||
                      (rf_wr_src_w0_wr_o == `CA53_RF_WR_SRC_W0_STR)     ||
                      (rf_wr_src_w0_wr_o == `CA53_RF_WR_SRC_W0_CP)      ||
                      (rf_wr_src_w0_wr_o == `CA53_RF_WR_SRC_W0_STREX)   ||
                      (rf_wr_src_w0_wr_o == `CA53_RF_WR_SRC_W0_SPSR)    ||
                      (rf_wr_src_w0_wr_o == `CA53_RF_WR_SRC_W0_BASE))
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Checks for illegal select signal combinations into the GPRF write port 1
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Illegal select for data into the integer register file W1")
  ovl_illegal_rf_wr_src_w1 (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_wr_en_w1_wr_o),
    .consequent_expr ((rf_wr_src_w1_wr_o == `CA53_RF_WR_SRC_W1_ALU)     ||
                      (rf_wr_src_w1_wr_o == `CA53_RF_WR_SRC_W1_MAC_LO)  ||
                      (rf_wr_src_w1_wr_o == `CA53_RF_WR_SRC_W1_CP)      ||
                      (rf_wr_src_w1_wr_o == `CA53_RF_WR_SRC_W1_DIV)     ||
                      (rf_wr_src_w1_wr_o == `CA53_RF_WR_SRC_W1_STR)     ||
                      (rf_wr_src_w1_wr_o == `CA53_RF_WR_SRC_W1_FP_ALU))
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Checks for illegal select signal combinations into the GPRF write port 2
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Illegal select for data into the integer register file W2")
  ovl_illegal_rf_wr_src_w2 (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_wr_en_w2_wr_o),
    .consequent_expr ((rf_wr_src_w2_wr_o == `CA53_RF_WR_SRC_W2_ALU)    ||
                      (rf_wr_src_w2_wr_o == `CA53_RF_WR_SRC_W2_DCU_1)  ||
                      (rf_wr_src_w2_wr_o == `CA53_RF_WR_SRC_W2_MAC_LO) ||
                      (rf_wr_src_w2_wr_o == `CA53_RF_WR_SRC_W2_FP_ALU) ||
                      (rf_wr_src_w2_wr_o == `CA53_RF_WR_SRC_W2_STR))
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Checks for deadlock situation that occurs if the muls_in_ex1 signal is
  // asserted after the flag setting multiply has moved on and a flag testing
  // instruction is following (occurs if muls_in_ex1 is not in a free running reg)
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Flag setting multiply in Ex1 deadlock with flag testing instr in Iss")
    ovl_muls_deadlock (.clk       (clk),
                       .reset_n   (reset_n),
                       .test_expr (~valid_instrs_iss[0] & muls_in_ex1 & conditional_instr_iss));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // rf_wr_src_w0_ex2 should not be ILLEGAL when issue_to_wr
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"rf_wr_src_w0_ex2 has an illegal value when issue_to_wr")
  ovl_rf_wr_src_w0_ex2_illegal (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (issue_to_wr),
    .consequent_expr ((rf_wr_src_w0_ex2 == `CA53_RF_WR_SRC_W0_0)       ||
                      (rf_wr_src_w0_ex2 == `CA53_RF_WR_SRC_W0_DCU_0)   ||
                      (rf_wr_src_w0_ex2 == `CA53_RF_WR_SRC_W0_CPSR)    ||
                      (rf_wr_src_w0_ex2 == `CA53_RF_WR_SRC_W0_MAC_HI)  ||
                      (rf_wr_src_w0_ex2 == `CA53_RF_WR_SRC_W0_STR)     ||
                      (rf_wr_src_w0_ex2 == `CA53_RF_WR_SRC_W0_CP)      ||
                      (rf_wr_src_w0_ex2 == `CA53_RF_WR_SRC_W0_STREX)   ||
                      (rf_wr_src_w0_ex2 == `CA53_RF_WR_SRC_W0_SPSR))
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // rf_wr_src_w1_ex2 should not be ILLEGAL when issue_to_wr
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"rf_wr_src_w1_ex2 has an illegal value when issue_to_wr")
  ovl_rf_wr_src_w1_ex2_illegal (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (issue_to_wr),
    .consequent_expr ((rf_wr_src_w1_ex2 == `CA53_RF_WR_SRC_W1_0)       ||
                      (rf_wr_src_w1_ex2 == `CA53_RF_WR_SRC_W1_ALU)     ||
                      (rf_wr_src_w1_ex2 == `CA53_RF_WR_SRC_W1_MAC_LO)  ||
                      (rf_wr_src_w1_ex2 == `CA53_RF_WR_SRC_W1_DIV)     ||
                      (rf_wr_src_w1_ex2 == `CA53_RF_WR_SRC_W1_CP)      ||
                      (rf_wr_src_w1_ex2 == `CA53_RF_WR_SRC_W1_STR)     ||
                      (rf_wr_src_w1_ex2 == `CA53_RF_WR_SRC_W1_FP_ALU))
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // rf_wr_src_w2_ex2 should not be ILLEGAL when issue_to_wr
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"rf_wr_src_w2_ex2 has an illegal value when issue_to_wr")
  ovl_rf_wr_src_w2_ex2_illegal (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (issue_to_wr),
    .consequent_expr ((rf_wr_src_w2_ex2 == `CA53_RF_WR_SRC_W2_0)      ||
                      (rf_wr_src_w2_ex2 == `CA53_RF_WR_SRC_W2_ALU)    ||
                      (rf_wr_src_w2_ex2 == `CA53_RF_WR_SRC_W2_MAC_LO) ||
                      (rf_wr_src_w2_ex2 == `CA53_RF_WR_SRC_W2_STR)    ||
                      (rf_wr_src_w2_ex2 == `CA53_RF_WR_SRC_W2_FP_ALU) ||
                      (rf_wr_src_w2_ex2 == `CA53_RF_WR_SRC_W2_DCU_1))
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Optimized compares for Ex2 interlock check pessimistic
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Optimized r0 to w0_ex2 compare for interlock check pessimistic")
    ovl_r0_w0_ex2_cmp_pessimistic (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (ovl_r0_w0_ex2_cmp_iss & raw_rf_wr_en_w0_ex2 & ~exception_valid_iss),
                                   .consequent_expr ((rf_rd_addr_r0_iss == rf_wr_addr_w0_ex2) & rf_rd_en_r0_iss & raw_rf_wr_en_w0_ex2));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Optimized r0 to w1_ex2 compare for interlock check pessimistic")
    ovl_r0_w1_ex2_cmp_pessimistic (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (ovl_r0_w1_ex2_cmp_iss & raw_rf_wr_en_w1_ex2 & ~exception_valid_iss),
                                   .consequent_expr ((rf_rd_addr_r0_iss == rf_wr_addr_w1_ex2) & rf_rd_en_r0_iss & raw_rf_wr_en_w1_ex2));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Optimized r0 to w2_ex2 compare for interlock check pessimistic")
    ovl_r0_w2_ex2_cmp_pessimistic (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (ovl_r0_w2_ex2_cmp_iss & raw_rf_wr_en_w2_ex2 & ~exception_valid_iss),
                                   .consequent_expr ((rf_rd_addr_r0_iss == rf_wr_addr_w2_ex2) & rf_rd_en_r0_iss & raw_rf_wr_en_w2_ex2));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Optimized r1 to w0_ex2 compare for interlock check pessimistic")
    ovl_r1_w0_ex2_cmp_pessimistic (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (ovl_r1_w0_ex2_cmp_iss & raw_rf_wr_en_w0_ex2 & ~exception_valid_iss),
                                   .consequent_expr ((rf_rd_addr_r1_iss == rf_wr_addr_w0_ex2) & rf_rd_en_r1_iss & raw_rf_wr_en_w0_ex2));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Optimized r1 to w1_ex2 compare for interlock check pessimistic")
    ovl_r1_w1_ex2_cmp_pessimistic (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (ovl_r1_w1_ex2_cmp_iss & raw_rf_wr_en_w1_ex2 & ~exception_valid_iss),
                                   .consequent_expr ((rf_rd_addr_r1_iss == rf_wr_addr_w1_ex2) & rf_rd_en_r1_iss & raw_rf_wr_en_w1_ex2));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Optimized r1 to w2_ex2 compare for interlock check pessimistic")
    ovl_r1_w2_ex2_cmp_pessimistic (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (ovl_r1_w2_ex2_cmp_iss & raw_rf_wr_en_w2_ex2 & ~exception_valid_iss),
                                   .consequent_expr ((rf_rd_addr_r1_iss == rf_wr_addr_w2_ex2) & rf_rd_en_r1_iss & raw_rf_wr_en_w2_ex2));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Optimized compares for Wr interlock check pessimistic
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Optimized r0 to w0_wr compare for interlock check pessimistic")
    ovl_r0_w0_wr_cmp_pessimistic (.clk             (clk),
                                  .reset_n         (reset_n),
                                  .antecedent_expr (ovl_r0_w0_wr_cmp_iss & ~exception_valid_iss),
                                  .consequent_expr ((rf_rd_addr_r0_iss == raw_rf_wr_addr_w0_wr) & rf_rd_en_r0_iss & raw_rf_wr_en_w0_wr));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Optimized r0 to w1_wr compare for interlock check pessimistic")
    ovl_r0_w1_wr_cmp_pessimistic (.clk             (clk),
                                  .reset_n         (reset_n),
                                  .antecedent_expr (ovl_r0_w1_wr_cmp_iss & ~exception_valid_iss),
                                  .consequent_expr ((rf_rd_addr_r0_iss == rf_wr_addr_w1_wr) & rf_rd_en_r0_iss & raw_rf_wr_en_w1_wr));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Optimized r0 to w2_wr compare for interlock check pessimistic")
    ovl_r0_w2_wr_cmp_pessimistic (.clk             (clk),
                                  .reset_n         (reset_n),
                                  .antecedent_expr (ovl_r0_w2_wr_cmp_iss & ~exception_valid_iss),
                                  .consequent_expr ((rf_rd_addr_r0_iss == rf_wr_addr_w2_wr) & rf_rd_en_r0_iss & raw_rf_wr_en_w2_wr));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Optimized r1 to w0_wr compare for interlock check pessimistic")
    ovl_r1_w0_wr_cmp_pessimistic (.clk             (clk),
                                  .reset_n         (reset_n),
                                  .antecedent_expr (ovl_r1_w0_wr_cmp_iss & ~exception_valid_iss),
                                  .consequent_expr ((rf_rd_addr_r1_iss == raw_rf_wr_addr_w0_wr) & rf_rd_en_r1_iss & raw_rf_wr_en_w0_wr));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Optimized r1 to w1_wr compare for interlock check pessimistic")
    ovl_r1_w1_wr_cmp_pessimistic (.clk             (clk),
                                  .reset_n         (reset_n),
                                  .antecedent_expr (ovl_r1_w1_wr_cmp_iss & ~exception_valid_iss),
                                  .consequent_expr ((rf_rd_addr_r1_iss == rf_wr_addr_w1_wr) & rf_rd_en_r1_iss & raw_rf_wr_en_w1_wr));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Optimized r1 to w2_wr compare for interlock check pessimistic")
    ovl_r1_w2_wr_cmp_pessimistic (.clk             (clk),
                                  .reset_n         (reset_n),
                                  .antecedent_expr (ovl_r1_w2_wr_cmp_iss & ~exception_valid_iss),
                                  .consequent_expr ((rf_rd_addr_r1_iss == rf_wr_addr_w2_wr) & rf_rd_en_r1_iss & raw_rf_wr_en_w2_wr));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Check that W0 never indicates it can forward out of Ex2
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Instruction in Ex2 says it can forward to Iss on W0 (W0 should never forward out of Ex2)")
    ovl_ex2_iss_w0_fwd  (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (|valid_instrs_iss & |valid_instrs_ex2),
                         .consequent_expr (~(r0_w0_where_iss[WHR_EX2] & w0_ready_mask[WHR_EX2]) &
                                           ~(r1_w0_where_iss[WHR_EX2] & w0_ready_mask[WHR_EX2]) &
                                           ~(r2_w0_where_iss[WHR_EX2] & w0_ready_mask[WHR_EX2]) &
                                           ~(r3_w0_where_iss[WHR_EX2] & w0_ready_mask[WHR_EX2]) &
                                           ~(r4_w0_where_iss[WHR_EX2] & w0_ready_mask[WHR_EX2])));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Automatically generated x-check assertions on register enables
  //----------------------------------------------------------------------------
  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: valid_iss_en")
  u_ovl_x_valid_iss_en (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (valid_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_pipeline")
  u_ovl_x_advance_pipeline (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (advance_pipeline));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: alu0_pipectl_en_iss")
  u_ovl_x_alu0_pipectl_en_iss (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (alu0_pipectl_en_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: alu1_pipectl_en_iss")
  u_ovl_x_alu1_pipectl_en_iss (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (alu1_pipectl_en_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_aa64_pc_ex1")
  u_ovl_x_en_aa64_pc_ex1 (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (en_aa64_pc_ex1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_aa64_pc_ex2")
  u_ovl_x_en_aa64_pc_ex2 (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (en_aa64_pc_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_aa64_pc_iss")
  u_ovl_x_en_aa64_pc_iss (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (en_aa64_pc_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_aa64_pc_ret")
  u_ovl_x_en_aa64_pc_ret (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (en_aa64_pc_ret));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_aa64_pc_wr")
  u_ovl_x_en_aa64_pc_wr (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_aa64_pc_wr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_btm_pc_ex1")
  u_ovl_x_en_btm_pc_ex1 (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_btm_pc_ex1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_btm_pc_ex2")
  u_ovl_x_en_btm_pc_ex2 (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_btm_pc_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_btm_pc_iss")
  u_ovl_x_en_btm_pc_iss (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_btm_pc_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_btm_pc_ret")
  u_ovl_x_en_btm_pc_ret (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_btm_pc_ret));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_lsm_skidding")
  u_ovl_x_en_lsm_skidding (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (en_lsm_skidding));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_top_pc_ex1")
  u_ovl_x_en_top_pc_ex1 (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_top_pc_ex1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_top_pc_ex2")
  u_ovl_x_en_top_pc_ex2 (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_top_pc_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_top_pc_iss")
  u_ovl_x_en_top_pc_iss (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_top_pc_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_top_pc_ret")
  u_ovl_x_en_top_pc_ret (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_top_pc_ret));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_top_pc_wr")
  u_ovl_x_en_top_pc_wr (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (en_top_pc_wr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_ex1")
  u_ovl_x_issue_to_ex1 (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (issue_to_ex1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_ex1_fpu")
  u_ovl_x_issue_to_ex1_fpu (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (issue_to_ex1_fpu));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_ex2")
  u_ovl_x_issue_to_ex2 (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (issue_to_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_ex2_fpu")
  u_ovl_x_issue_to_ex2_fpu (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (issue_to_ex2_fpu));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_f4")
  u_ovl_x_issue_to_f4 (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (issue_to_f4));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_f5")
  u_ovl_x_issue_to_f5 (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (issue_to_f5));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_iss")
  u_ovl_x_issue_to_iss (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (issue_to_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_iss_fpu")
  u_ovl_x_issue_to_iss_fpu (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (issue_to_iss_fpu));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_wr")
  u_ovl_x_issue_to_wr (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (issue_to_wr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_wr_fpu")
  u_ovl_x_issue_to_wr_fpu (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (issue_to_wr_fpu));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: mac_pipectl_en_iss")
  u_ovl_x_mac_pipectl_en_iss (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (mac_pipectl_en_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: no_interrupt_en")
  u_ovl_x_no_interrupt_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (no_interrupt_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: no_interrupt_iss_en")
  u_ovl_x_no_interrupt_iss_en (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (no_interrupt_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: no_interrupt_ls_wr_en")
  u_ovl_x_no_interrupt_ls_wr_en (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (no_interrupt_ls_wr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: nxt_save_base_ex2")
  u_ovl_x_nxt_save_base_ex2 (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (nxt_save_base_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rf_rd_addr_r0_iss_en")
  u_ovl_x_rf_rd_addr_r0_iss_en (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (rf_rd_addr_r0_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rf_rd_addr_r1_iss_en")
  u_ovl_x_rf_rd_addr_r1_iss_en (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (rf_rd_addr_r1_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rf_rd_addr_r2_iss_en")
  u_ovl_x_rf_rd_addr_r2_iss_en (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (rf_rd_addr_r2_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rf_rd_addr_r3_iss_en")
  u_ovl_x_rf_rd_addr_r3_iss_en (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (rf_rd_addr_r3_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rf_rd_addr_r4_iss_en")
  u_ovl_x_rf_rd_addr_r4_iss_en (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (rf_rd_addr_r4_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rf_stm_rd_addr_r3_skid_iss_en")
  u_ovl_x_rf_stm_rd_addr_r3_skid_iss_en (.clk       (clk),
                                         .reset_n   (reset_n),
                                         .qualifier (1'b1),
                                         .test_expr (rf_stm_rd_addr_r3_skid_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: save_base_ex2")
  u_ovl_x_save_base_ex2 (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (save_base_ex2));

generate if (NEON_FP) begin : FPU3
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: no_insert_iss_en")
  u_ovl_x_no_insert_iss_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (FPU1.no_insert_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_rf_wr_en_f5")
  u_ovl_x_en_rf_wr_en_f5 (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (FPU1.en_rf_wr_en_f5));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_f1")
  u_ovl_x_en_f1 (.clk       (clk),
                 .reset_n   (reset_n),
                 .qualifier (1'b1),
                 .test_expr (FPU1.en_f1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_f2")
  u_ovl_x_en_f2 (.clk       (clk),
                 .reset_n   (reset_n),
                 .qualifier (1'b1),
                 .test_expr (FPU1.en_f2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: neon_vld_ctl_f2_en")
  u_ovl_x_en_neon_vld_ctl_f2_en (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (FPU1.neon_vld_ctl_f2_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: neon_vld_ctl_f3_en")
  u_ovl_x_en_neon_vld_ctl_f3_en (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (FPU1.neon_vld_ctl_f3_en));
end endgenerate

`endif

endmodule // ca53dpu_ctl

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
