//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2007-2015 ARM Limited.
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
// Abstract : Top level of the IFetch Unit Prefetch Block
//-----------------------------------------------------------------------------

`include "ca53ifu_defs.v"
`include "cortexa53params.v"

module ca53ifu_pf `CA53_IFU_PARAM_DECL (
               //Inputs
               input wire         clk,
               input wire         reset_n,
               input wire         DFTSE,
               input wire         DFTRAMHOLD,
               input wire         dpu_iq_full_i,
               input wire         dpu_iq_part_full_i,
               input wire         dpu_fe_valid_wr_i,
               input wire         dpu_fe_context_sync_ret_i,
               input wire [48:1]  dpu_fe_addr_opa_wr_i,
               input wire [27:1]  dpu_fe_addr_opb_wr_i,
               input wire [1:0]   dpu_fe_isa_wr_i,
               input wire [12:3]  dpu_br_addr_ex2_i,
               input wire         dpu_pred_br_ex2_i,
               input wire [1:0]   dpu_exception_level_i,
               input wire         dpu_aarch64_at_el3_i,
               input wire [31:0]  dpu_dacr_i,
               input wire         dpu_pred_br_wr_i,
               input wire         dpu_mispred_wr_i,
               input wire         dpu_br_taken_wr_i,
               input wire         dpu_br_return_wr_i,
               input wire         dpu_br_call_wr_i,
               input wire         dpu_fe_valid_ret_i,
               input wire [63:0]  dpu_fe_addr_opa_ret_i,
               input wire [17:1]  dpu_fe_addr_opb_ret_i,
               input wire [1:0]   dpu_fe_isa_ret_i,
               input wire [7:0]   dpu_fe_itstate_ret_i,
               input wire         dpu_btac_ret_i,
               input wire         dpu_halt_ifu_i,
               input wire         dpu_mmu_on_i,
               input wire         dpu_ipa_to_pa_en_i,
               input wire         dpu_flush_i_utlb_i,
               input wire         dpu_sif_only_i,
               input wire         dpu_ns_state_i,
               input wire         dpu_default_cacheable_i,
               input wire         dpu_sctlr_itd_i,
               input wire         dpu_throttle_enable_i,
               input wire         dpu_reset_catch_pending_i,
               input wire         dpu_expt_catch_pending_i,
               input wire         tlb_i_utlb_enable_i,
               input wire         tlb_i_utlb_might_enable_i,
               input wire         tlb_i_utlb_valid_i,
               input wire         tlb_i_utlb_lpae_i,
               input wire [96:0]  tlb_i_utlb_data_i,
               input wire         tlb_i_utlb_flush_i,
               input wire         tlb_lpae_mode_i,
               input wire [1:0]   tlb_tcr_el1_tbi_i,
               input wire         tlb_tcr_el2_tbi0_i,
               input wire         tlb_tcr_el3_tbi0_i,
               input wire [3:0]   tlb_bkpt_hit_if2_i,
               input wire [1:0]   tlb_vcr_hit_if2_i,
               input wire         icb_busy_if1_i,
               input wire [79:0]  icb_data_if2_i,
               input wire [79:0]  icb_lfb_data_if2_i,
               input wire         icb_hit_if2_i,
               input wire         icb_lfb_hit_if2_i,
               input wire         icb_dbg_hit_if2_i,
               input wire [1:0]   icb_way_if2_i,
               input wire         icb_pdc_hazard_if2_i,
               input wire         icb_ext_abort_if2_i,
               input wire [1:0]   icb_ext_abort_type_if2_i,
               input wire [3:0]   icb_parity_err_if2_i,
               input wire [39:0]  icb_pdc_data_if2_i,
               input wire         icb_flush_btic_i,
               input wire         icb_cacheable_if2_i,
               input wire [2:0]   icb_mbist_en_i,
               input wire         icb_pdc_valid_if2_i,
               input wire [49:0]  btac_stg0_ram_rdata_i,
               input wire [58:0]  btac_stg1_ram_rdata_i,
               input wire         ctl_mbist_req_i,
               input wire [ 1:0]  ctl_mbist_btac_en_mb4_i,
               input wire [ 6:0]  ctl_mbist_btac_addr_mb4_i,
               input wire         ctl_mbist_btac_wr_mb4_i,
               input wire [58:0]  ctl_mbist_btac_wdata_mb4_i,
               input wire         lfb_in_progress_i,
               // Outputs
               output wire [47:0] ifu_instr0_if3_o,
               output wire [47:0] ifu_instr1_if3_o,
               output wire [1:0]  ifu_instr_valid_if3_o,
               output wire        ifu_early_two_valid_if3_o,
               output wire [48:0] ifu_pred_addr_if4_o,
               output wire        ifu_pred_addr_valid_if4_o,
               output wire [31:1] ifu_ifar_o,
               output wire [27:0] ifu_hpfar_o,
               output wire [6:0]  ifu_ifsr_o,
               output wire [1:0]  ifu_ifsr_stage2_o,
               output wire        ifu_ifsr_lpae_o,
               output wire        ifu_evnt_ic_miss_wait_o,
               output wire        ifu_evnt_iutlb_miss_wait_o,
               output wire        ifu_evnt_throttle_o,
               output wire        ifu_utlb_miss_req_o,
               output wire        ifu_valid_if2_o,
               output wire        pfb_first_if1_o,
               output wire        pfb_valid_if1_o,
               output wire [14:2] pfb_va_if1_o,
               output wire        pfb_force_if1_o,
               output wire        pfb_utlb_hit_if2_o,
               output wire [1:0]  pfb_state_if2_o,
               output wire        pfb_kill_if2_o,
               output wire [7:0]  pfb_attributes_if2_o,
               output wire        pfb_priv_if2_o,
               output wire [63:0] pfb_va_if2_o,
               output wire [39:4] pfb_pa_if2_o,
               output wire        pfb_ns_dsc_if2_o,
               output wire [28:0] pfb_pdc_data_if3_o,
               output wire [18:0] pfb_pdc_ctl_if3_o,
               output wire [1:0]  pfb_valid_buffers_o,
               output wire [79:0] pfb_mbist_data_o,
               output wire        pfb_dbg_a64_state_o,
               output wire        pfb_in_debug_or_wfx_o,
               output wire        pfb_context_sync_o,
               output wire        btac_stg0_ram_en_o,
               output wire        btac_stg0_ram_wr_o,
               output wire [49:0] btac_stg0_ram_wdata_o,
               output wire [6:0]  btac_stg0_ram_addr_o,
               output wire        btac_stg1_ram_en_o,
               output wire        btac_stg1_ram_wr_o,
               output wire [58:0] btac_stg1_ram_wdata_o,
               output wire [6:0]  btac_stg1_ram_addr_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg            abuf_abt_if2;
  reg            abuf_abt_if3;
  reg [1:0]      abuf_state_if3;
  reg            avalid_if3;
  reg            bbuf_abt_if2;
  reg            bbuf_abt_if3;
  reg            bbuf_cwf_hit_if2;
  reg            bbuf_cwf_hit_if3;
  reg            bbuf_utlb_flushed_if2;
  reg            bbuf_utlb_flushed_if3;
  reg            bbuf_btic_if2;
  reg            bbuf_btic_if3;
  reg            bvalid_if3;
  reg            cbuf_abt_if3;
  reg            cbuf_cwf_hit_if3;
  reg            cbuf_utlb_flushed_if3;
  reg            cvalid_if3;
  reg            dbg_valid_if3;
  reg            early_kill_if2;
  reg            first_if1;
  reg            force_if1;
  reg            force_if1_pf;
  reg            hyp_mode_if2;
  reg            icu_busy_held;
  reg            ifsr_lpae;
  reg            in_debug_or_wfx;
  reg            instr_been_corrected;
  reg            instr_is_a32_if3;
  reg            instr_is_a64_if3;
  reg            instr_is_thumb_if3;
  reg            instr_is_thumb_bpd_if3;
  reg            dbg_a64_state;
  reg            cpsr_itd;
  reg            ip_top_buf_if3;
  reg            iutlb_miss_req;
  reg            lpae_abort_if2;
  reg            lpae_abort_if3;
  reg [27:0]     abort_ipa_if3;
  reg            main_tlb_abort_if2;
  reg            micro_tlb_abort_if2;
  reg            ns_dsc_if2;
  reg            nxt_avalid_if3;
  reg            nxt_bvalid_if3;
  reg            nxt_cvalid_if3;
  reg            nxt_shift_n32_if3;
  reg            nxt_shift_32_if3;
  reg            nxt_shift_n16_if3;
  reg            nxt_shift_16_if3;
  reg            out_of_range_abort_mmu_on_if2;
  reg            out_of_range_abort_mmu_off_if2;
  reg            pc_unalign_abort_if2;
  reg            priv_mode_if2;
  reg [1:0]      stage2_abort_if2;
  reg [1:0]      stage2_abort_if3;
  reg            stop_pfb;
  reg            tlb_abort_if2;
  reg            tlb_hit_if2;
  reg            utlb_flushed_if1;
  reg            utlb_flushed_if2;
  reg            valid_if1;
  reg            valid_if2;
  reg [1:0]      abuf_vcr_if2;
  reg [1:0]      abuf_vcr_if3;
  reg [1:0]      abuf_way_if2;
  reg [1:0]      abuf_way_if3;
  reg            abuf_btic_if2;
  reg            abuf_btic_if3;
  reg            abuf_cwf_hit_if2;
  reg            abuf_cwf_hit_if3;
  reg            abuf_pdc_hazard_if2;
  reg            abuf_pdc_hazard_if3;
  reg [1:0]      bbuf_vcr_if2;
  reg [1:0]      bbuf_vcr_if3;
  reg [1:0]      bbuf_way_if2;
  reg [1:0]      bbuf_way_if3;
  reg            bbuf_pdc_hazard_if2;
  reg            bbuf_pdc_hazard_if3;
  reg [1:0]      cbuf_vcr_if3;
  reg [1:0]      cbuf_way_if3;
  reg            cbuf_pdc_hazard_if3;
  reg [1:0]      clean_state_if2;
  reg [1:0]      cpsr_state;
  reg [2:1]      ip_if3;
  reg [2:1]      nxt_ip_if3;
  reg [27:0]     abort_ipa_if2;
  reg [63:0]     agu_a_operand_if0;
  reg [63:0]     agu_a_operand_if1;
  reg [63:0]     agu_b_operand_if0;
  reg [63:0]     agu_b_operand_if1;
  reg [63:0]     va_if2;
  reg [39:12]    pa_if2;
  reg [48:3]     abuf_va_if2;
  reg [12:3]     abuf_va_plus1_if2;
  reg [12:3]     abuf_va_plus2_if2;
  reg [48:3]     bbuf_va_if2;
  reg [48:3]     abuf_va_if3;
  reg [12:3]     abuf_va_plus1_if3;
  reg [12:3]     abuf_va_plus2_if3;
  reg [48:3]     bbuf_va_if3;
  reg [48:3]     cbuf_va_if3;
  reg [7:0]      attributes_if2;
  reg [3:0]      abuf_bkpt_if3;
  reg [3:0]      bbuf_bkpt_if3;
  reg [3:0]      cbuf_bkpt_if3;
  reg [3:0]      cpsr_it_cond;
  reg [3:0]      cpsr_it_mask;
  reg [3:0]      nxt_cpsr_it_cond;
  reg [3:0]      nxt_cpsr_it_mask;
  reg [6:0]      abort_type_if3;
  reg [6:0]      tlb_abort_type_if2;
  reg [10:0]     shift_n32_if3;
  reg [10:0]     shift_32_if3;
  reg [8:0]      shift_n16_if3;
  reg [8:0]      shift_16_if3;
  reg [79:0]     abuf_if3;
  reg [79:0]     abuf_idata_if2;
  reg [79:0]     bbuf_if3;
  reg [79:0]     bbuf_idata_if2;
  reg [79:0]     cbuf_if3;
  reg [79:0]     cbuf_idata_if2;
  reg [3:0]      abuf_bkpt_if2;
  reg [3:0]      bbuf_bkpt_if2;
  reg            return_hit_if4;
  reg            evnt_stall_if2;
  reg            abuf_expt_catch_if2;
  reg            abuf_expt_catch_if3;
  reg            abuf_rst_catch_if2;
  reg            abuf_rst_catch_if3;
  reg            context_sync_lfb_drain;
  reg            dpu_expt_catch_if2;
  reg            dpu_rst_catch_if2;
  reg            debug_catch_if2;
  reg            out_of_range_abort;
  reg            disable_predictors;
  reg            exception_level_0;
  reg            exception_level_1;
  reg            exception_level_2;
  reg            exception_level_3;
  reg            ns_state;
  reg            aarch64_at_el3;
  reg            sif_only;
  reg            default_cacheable;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire           abort_if2;
  wire           abort_inbound;
  wire           abt_cross_fetch_boundary;
  wire           branch_never_taken;
  wire [1:0]     brn_btac_if3;
  wire [1:0]     brn_return_if3;
  wire           btac_disable;
  wire           btac_hit_if4;
  wire           btic_disable;
  wire           carry_out_1m;
  wire           carry_out_4k;
  wire           aarch64_state;
  wire           cm_branch;
  wire           cm_flush_no_br;
  wire           cm_mispredicted;
  wire           cm_taken;
  wire           crs_commited_pop;
  wire           crs_commited_push;
  wire           crs_disable;
  wire           crs_spec_push;
  wire           crs_spec_pop;
  wire           dbg_valid_if2;
  wire           dpu_pfu_force;
  wire           en_abuf_idata;
  wire           en_bbuf_idata;
  wire           en_cbuf_idata;
  wire           en_abort_ctl_if2;
  wire           en_abort_data_if2;
  wire           nxt_tlb_abort_if2;
  wire           en_addr_if1;
  wire           en_addr_hi_if2;
  wire           en_addr_lo_if2;
  wire           en_line_if2;
  wire           en_valid_if1;
  wire           en_valid_if2;
  wire           enter_debug_or_wfx;
  wire           fetch_stall_if1;
  wire           first_if0;
  wire           force_if0;
  wire           force_if3;
  wire           hyp_mode_if1;
  wire           instr0_brn;
  wire           instr0_brn_imm_if3;
  wire           instr0_cwf_hazard;
  wire           instr0_way_hazard;
  wire           instr0_incomplete;
  wire           instr0_btic_hazard;
  wire           instr0_not_t16;
  wire           instr0_opcode_err;
  wire           instr0_pdec_err;
  wire           instr0_two_t32a;
  wire           instr0_utlb_flush;
  wire           instr1_brn_imm_if3;
  wire           instr1_cwf_hazard;
  wire           instr1_way_hazard;
  wire           instr1_incomplete;
  wire           instr1_btic_hazard;
  wire           instr1_not_t16;
  wire           instr1_opcode_err;
  wire           instr1_pdec_err;
  wire           instr1_possible;
  wire           instr1_select;
  wire           instr1_two_t32a;
  wire           instr1_utlb_flush;
  wire           instr_pdc_pass;
  wire           instr_sw_bkpt_if3;
  wire           early_instr1_possible;
  wire           kill_if1;
  wire           kill_if2;
  wire           lpae_abort_if1;
  wire           main_tlb_abort_if1;
  wire           micro_tlb_abort_if1;
  wire           out_of_range_abort_mmu_on_if1;
  wire           out_of_range_abort_mmu_off_if1;
  wire           pc_unalign_abort;
  wire           pc_unalign_abort_if1;
  wire           fetch_q_stable_if3;
  wire           ncarry_out_1m;
  wire           ncarry_out_4k;
  wire           ncarry_out_64;
  wire           next64_if3;
  wire           ns_dsc_if1;
  wire           nxt_ifsr_lpae;
  wire           nxt_in_debug_or_wfx;
  wire           nxt_instr_been_corrected;
  wire           nxt_instr_is_a32_if3;
  wire           nxt_instr_is_a64_if3;
  wire           nxt_iutlb_miss_req;
  wire           nxt_lpae_abort_if3;
  wire           nxt_stop_pfb;
  wire           nxt_stop_pfb_if3;
  wire           nxt_valid_if1;
  wire           nxt_valid_if2;
  wire           pdc_crosses_buffers;
  wire           pdc_req_if3;
  wire           pfb_early_two_valid;
  wire           pfb_valid_if1;
  wire           priv_mode_if1;
  wire           sel_push_one;
  wire           sel_push_two;
  wire [1:0]     spec_crs_btac_valid;
  wire           stall_if1;
  wire           stall_if2;
  wire           taken_i0_if3;
  wire           taken_i1_if3;
  wire           tlb_hit_if1;
  wire           utlb_flushed_if0;
  wire [6:0]     tlb_abort_type_if1;
  wire           va_if3_en;
  wire [10:0]    nxt_shift_n32_exp_if3;
  wire [10:0]    nxt_shift_32_exp_if3;
  wire [8:0]     nxt_shift_n16_exp_if3;
  wire [8:0]     nxt_shift_16_exp_if3;
  wire           nxt_ip_top_buf_if3;
  wire [1:0]     brn_predicted_if3;
  wire           btic_hit_if3;
  wire           btic_bbuf_valid_if3;
  wire [1:0]     early_instr_taken;
  wire [1:0]     in_it_block;
  wire [1:0]     instr_abt_if3;
  wire [1:0]     instr_pty_if3;
  wire [1:0]     instr_brn_btic;
  wire [1:0]     instr_brn_link_if3;
  wire [1:0]     instr_brn_exchange_a_if3;
  wire [1:0]     instr_brn_exchange_t_if3;
  wire [1:0]     instr_brn_t3_if3;
  wire [1:0]     instr_brn_t_cond_if3;
  wire [1:0]     instr_brn_taken_if3;
  wire [1:0]     instr_dual_slot0;
  wire [1:0]     instr_dual_slot1;
  wire [1:0]     instr_hw_bkpt_if3;
  wire [1:0]     instr_is_dp;
  wire [1:0]     instr_is_fn;
  wire [1:0]     instr_is_ls;
  wire [1:0]     instr_is_t16_if3;
  wire [1:0]     instr_is_t32_if3;
  wire [1:0]     instr_it_if3;
  wire [1:0]     instr_valid_if3;
  wire [1:0]     instr_vcr_if3;
  wire [1:0]     nxt_cpsr_state;
  wire [1:0]     nxt_stage2_abort_if3;
  wire [27:0]    nxt_abort_ipa_if3;
  wire [1:0]     pdc_way_0_if3;
  wire [1:0]     pdc_way_1_if3;
  wire [1:0]     pfb_push;
  wire [1:0]     stage2_abort_if1;
  wire [27:0]    abort_ipa_if1;
  wire [27:1]    instr0_brn_offset_if3;
  wire [27:1]    instr1_brn_offset_if3;
  wire [28:0]    pdc_data_if3;
  wire [4:0]     agu_b_operand_sel;
  wire [1:0]     instr0_size;
  wire [1:0]     instr1_size;
  wire [63:0]    agu_a_operand_frc;
  wire [63:0]    agu_a_operand_imm0;
  wire [63:0]    agu_a_operand_imm1;
  wire [63:0]    agu_a_operand_seq;
  wire [63:0]    agu_b_operand_frc;
  wire [63:0]    agu_b_operand_imm0;
  wire [63:0]    agu_b_operand_imm1;
  wire [63:0]    agu_b_operand_seq;
  wire [63:0]    agu_result_adder;
  wire [48:0]    btac_hit_addr_if4;
  wire [48:1]    btic_abuf_va_if3;
  wire [48:3]    btic_bbuf_va_if3;
  wire [12:3]    btic_cbuf_va_if3;
  wire [48:3]    btic_target_va_if2;
  wire [48:0]    crs_hit_addr_if3;
  wire [48:0]    crs_spec_addr;
  wire [12:3]    va_if0;
  wire [63:0]    va_if1;
  wire [48:1]    va_push_one_if3;
  wire [48:1]    va_push_two_if3;
  wire [63:0]    nxt_va_if2;
  wire [66:0]    agu_a_operand_adder;
  wire [66:0]    agu_b_operand_adder;
  wire [39:12]   pa_if1;
  wire [39:0]    instr0_32_if3;
  wire [39:0]    instr1_32_if3;
  wire [39:0]    instr0_if3;
  wire [39:0]    instr1_if3;
  wire [7:0]     attributes_if1;
  wire [3:0]     instr1_it_cond;
  wire [2:0]     it_undef;
  wire [2:0]     instr1_it_undef;
  wire [1:0]     last_in_it;
  wire [2:0]     ip_push_one;
  wire [2:0]     ip_push_two;
  wire [4:0]     abuf_idata_sel_00;
  wire [39:0]    instr0_t16t32;
  wire [39:0]    instr1_t16t32;
  wire [47:0]    iq_instr0_if3;
  wire [47:0]    iq_instr1_if3;
  wire [48:0]    iq_pred_addr_if4;
  wire [5:0]     agu_a_operand_sel;
  wire [5:0]     abuf_idata_sel_20;
  wire [5:0]     abuf_idata_sel_40;
  wire [5:0]     abuf_idata_sel_60;
  wire [6:0]     nxt_abort_type_if3;
  wire [79:0]    btic_abuf_if3;
  wire [79:0]    btic_bbuf_if3;
  wire [99:0]    imux_32_if3;
  wire [79:0]    imux_if3;
  wire [7:0]     cpsr_it_cm;
  wire [7:0]     it_cond_mask;
  wire [9:0]     dpu_pfu_cpsr;
  wire           instr_en;
  wire           en_dbg_a64_state;
  wire           instr_been_corrected_en;
  wire           iutlb_miss_req_en;
  wire [1:0]     s32_btac_if3;
  wire [1:0]     s32_return_if3;
  wire [1:0]     t16_btac_if3;
  wire [1:0]     t16_return_if3;
  wire [1:0]     spec_btac_if3;
  wire           instr0_topcl;
  wire           instr1_topcl;
  wire           brn_btac_pushed_if3;
  wire           nxt_return_hit_if4;
  wire           btac_invalidate;
  wire           btac_lookup_stall_if4;
  wire           btac_skew_loopkup_if4;
  wire           throttle_if1;
  wire           nxt_context_sync_lfb_drain;
  wire           nxt_dpu_expt_catch_if2;
  wire           nxt_dpu_rst_catch_if2;
  wire           nxt_debug_catch_if2;
  wire           nxt_disable_predictors;
  wire           nxt_exception_level_0;
  wire           nxt_exception_level_1;
  wire           nxt_exception_level_2;
  wire           nxt_exception_level_3;
  wire           throttle_enable_nxt_cyc;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // DPU signal qualification & capture
  // ------------------------------------------------------

  // Invalidate the Wr-stage signals if a force from the Ret-stage occurs
  assign cm_branch         = ~dpu_fe_valid_ret_i & dpu_pred_br_wr_i;
  assign cm_mispredicted   = ~dpu_fe_valid_ret_i & dpu_mispred_wr_i;
  assign cm_taken          = ~dpu_fe_valid_ret_i & dpu_br_taken_wr_i;
  assign crs_commited_push = ~dpu_fe_valid_ret_i & dpu_br_taken_wr_i & dpu_br_call_wr_i;
  assign crs_commited_pop  = ~dpu_fe_valid_ret_i & dpu_br_taken_wr_i & dpu_br_return_wr_i;
  assign dpu_pfu_force     =  dpu_fe_valid_ret_i | dpu_fe_valid_wr_i;

  // CPSR mux from the DPU (the Ret-stage has priority)
  assign dpu_pfu_cpsr[9:0] = dpu_fe_valid_ret_i ? {dpu_fe_isa_ret_i, dpu_fe_itstate_ret_i} : {dpu_fe_isa_wr_i, {8{1'b0}} };

  // Capture the DPU exception level which will only change on a flush from the Ret stage
  // Convert to one-hot rather than leave in encoded form to allow the register to be consistently
  // clock gated and reduce the amount of comparison logic elsewhere.
  assign nxt_exception_level_0 = dpu_exception_level_i[1:0] == `CA53_EL0;
  assign nxt_exception_level_1 = dpu_exception_level_i[1:0] == `CA53_EL1;
  assign nxt_exception_level_2 = dpu_exception_level_i[1:0] == `CA53_EL2;
  assign nxt_exception_level_3 = dpu_exception_level_i[1:0] == `CA53_EL3;

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      exception_level_0 <= 1'b0;
      exception_level_1 <= 1'b0;
      exception_level_2 <= 1'b0;
      exception_level_3 <= 1'b1;
      ns_state          <= 1'b0;
      aarch64_at_el3    <= 1'b0;
    end
    else if (dpu_fe_valid_ret_i) begin
      exception_level_0 <= nxt_exception_level_0;
      exception_level_1 <= nxt_exception_level_1;
      exception_level_2 <= nxt_exception_level_2;
      exception_level_3 <= nxt_exception_level_3;
      ns_state          <= dpu_ns_state_i;
      aarch64_at_el3    <= dpu_aarch64_at_el3_i;
    end

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      sif_only          <= 1'b0;
      default_cacheable <= 1'b0;
    end
    else begin
      sif_only          <= dpu_sif_only_i;
      default_cacheable <= dpu_default_cacheable_i;
    end

  // ------------------------------------------------------
  // Disable branch prediction
  // ------------------------------------------------------

  // The PF must be able to disable prediction when the MMU is off
  // we also disable branches for the first 128 cycles while the BTAC is initializing
  assign nxt_disable_predictors = ~dpu_mmu_on_i & ~dpu_ipa_to_pa_en_i;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      disable_predictors <= 1'b1;
    else
      disable_predictors <= nxt_disable_predictors;

  assign branch_never_taken = disable_predictors | btac_invalidate;
  assign crs_disable        = disable_predictors;
  assign btac_disable       = disable_predictors;
  assign btic_disable       = disable_predictors;

  // Indicate that the throttle predictor will be enabled in the next cycle providing
  // the DPU CPUACTLR bit is set, the MMU is on and we're not in debug
  assign throttle_enable_nxt_cyc = dpu_throttle_enable_i & dpu_mmu_on_i & ~in_debug_or_wfx;

  // ------------------------------------------------------
  // Pipeline force and valid signals
  // ------------------------------------------------------

  // The DPU signals entry to debug halt state by asserting dpu_fe_valid_ret_i and dpu_halt_ifu_i in
  // the same cycle.  The DPU signals entry to WFX by asserting dpu_fe_valid_wr_i and dpu_halt_ifu_i
  // in the same cycle.  Both of these condition are stored in the stop_pfb register.  The exit
  // condition is a dpu_pfu_force where dpu_halt_ifu_i is not asserted.
  assign enter_debug_or_wfx = dpu_pfu_force & dpu_halt_ifu_i;
  assign dbg_valid_if2      = stop_pfb & icb_dbg_hit_if2_i;

  // Force for immediate branch, return or BTAC hit
  assign force_if3 = (btac_hit_if4 |
                      (instr0_brn_imm_if3 & ~dpu_iq_full_i & ~instr0_opcode_err & ~instr_abt_if3[0])                    |
                      (instr1_brn_imm_if3 & ~dpu_iq_full_i & ~instr0_opcode_err & ~instr1_opcode_err & instr1_possible) |
                      (brn_return_if3[0]  & ~dpu_iq_full_i & ~instr0_opcode_err)                                        |
                      (brn_return_if3[1]  & ~dpu_iq_full_i & ~instr0_opcode_err & ~instr1_opcode_err & instr1_possible));

  // If a force has occured then a new fetch is always started regardless of the state of the pipeline.
  assign force_if0 = dpu_pfu_force | force_if3;

  // Valid signals
  assign nxt_valid_if1 = (dpu_pfu_force & ~dpu_halt_ifu_i) | ~stop_pfb | force_if3;
  assign nxt_valid_if2 = pfb_valid_if1 & tlb_hit_if1 & ~force_if0 & ~abort_if2 & ~nxt_stop_pfb_if3 & ~brn_btac_pushed_if3;

  // PFB valid signal indicates that the request to the ICB is valid.  If there is an icache
  // miss in if2 then the signal stays valid, but the request is stalled.
  assign pfb_valid_if1 = ~fetch_stall_if1;

  // ------------------------------------------------------
  // Context syncronization
  // ------------------------------------------------------

  // The DPU force signal is a pulse, so when there is a force with context sync
  // and outstanding linefills we register the force until the LFBs have
  // drained.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      context_sync_lfb_drain <= 1'b0;
    else
      context_sync_lfb_drain <= nxt_context_sync_lfb_drain;

  assign nxt_context_sync_lfb_drain = (dpu_fe_valid_ret_i & dpu_fe_context_sync_ret_i & ~dpu_halt_ifu_i & lfb_in_progress_i) | // Set
                                      (context_sync_lfb_drain & lfb_in_progress_i & ~dpu_pfu_force); // Hold

  // ------------------------------------------------------
  // Pipeline stall signals
  // ------------------------------------------------------

  // Early fetch stall signal without timing critical micro-TLB miss signal.  Stalls occur when:
  // - There are three fetches in flight or in the fetch buffers
  // - The 'C' fetch buffer is occupied
  // - A registered copy of the micro-TLB miss signal is set (power saving measure while waiting
  //   for the main TLB to process the miss request).
  // - The processor has stopped due to being in debug state, WFI/WFE or breakpoint,
  //   vector-catch or abort
  // - A TLB abort occured in the last cycle
  // - The ICU is holding the PFU while completing a CP15 operation
  // - A BTAC lookup is in progress
  // - Fetch is being throttled
  // - Context synchronisation stall
  assign fetch_stall_if1 = ((bvalid_if3 & valid_if2) |
                            cvalid_if3               |
                            iutlb_miss_req           |
                            stop_pfb                 |
                            tlb_abort_if2            |
                            debug_catch_if2          |
                            icu_busy_held            |
                            btac_lookup_stall_if4    |
                            throttle_if1             |
                            context_sync_lfb_drain);

  // Create if1 pipeline stall signal including the timing critical micro-TLB miss signal
  assign stall_if1 = valid_if1 & (fetch_stall_if1 | ~tlb_hit_if1);

  // Create if2 pipeline stall signal
  assign stall_if2 = valid_if2 & ~kill_if2 & ~(icb_hit_if2_i | icb_lfb_hit_if2_i);

  // ------------------------------------------------------
  // Generic control signals
  // ------------------------------------------------------

  // Determine if the next request should be marked 'first'.  Typically this indicates either a
  // non-sequential access or a sequential that crosses a cache line boundary.  However if the
  // micro-TLB is flushed while in the middle of sequentially fetching, the pfu_first_if1 signal
  // must be asserted on the first request that misses the micro-TLB - although first won't get
  // asserted on the micro-TLB miss cycle, but on the hit cycle.  Also, the recirculating mux is
  // built in to the logic, because a shareable gating term can not be constructed for the register
  assign first_if0 = (force_if0 |
                      tlb_i_utlb_might_enable_i |
                      ((stall_if1 | stall_if2 | stop_pfb) ? first_if1 : (va_if1[5:3] == 3'b111)));

  // Kill the request generated in the if1 cycle if there is a force, an abort (only the main TLB
  // abort is considered here) or if the PFU is going to be stopped in the next cycle.  For timing
  // reasons the request is sent out in if2 and is augmented with the TLB abort checks.
  assign kill_if1 = pfb_valid_if1 & (force_if0 | brn_btac_pushed_if3 | abort_if2 | nxt_stop_pfb_if3);

  // Augment the registered kill signal in if2 with a micro-TLB abort or
  // unaligned PC abort. Debug catch signals must prevent an external request
  // from going ahead
  assign kill_if2 = early_kill_if2 | tlb_abort_if2 | debug_catch_if2;

  // Mode in which fetch was made
  assign priv_mode_if1 = ~exception_level_0;
  assign hyp_mode_if1  =  exception_level_2;

  // Indicate how many instructions to push to the DPU IQ
  assign pfb_push[0] = ~dpu_iq_full_i & instr_valid_if3[0] & (~instr0_pdec_err | instr_pty_if3[0]);
  assign pfb_push[1] = ~dpu_iq_full_i & instr_valid_if3[1] & ~instr0_pdec_err & ~instr1_pdec_err & instr1_possible;

  // Early indication that two instructions may be pushed to the DPU to aid IQ entry clock gating
  assign pfb_early_two_valid = ~dpu_iq_full_i & ~instr0_pdec_err & instr_valid_if3[1];

  // ----------------------------------------------------------------------
  // Breakpoint / Vector Catch / Reset and Exception Catch / Abort handling
  // ----------------------------------------------------------------------

  // Capture exception/reset catch into if2
  // Capture itd behaviour
  always @ (posedge clk or negedge reset_n)
    if (!reset_n) begin
      dpu_expt_catch_if2 <= 1'b0;
      dpu_rst_catch_if2  <= 1'b0;
      debug_catch_if2    <= 1'b0;
      cpsr_itd           <= 1'b0;
    end else begin
      dpu_expt_catch_if2 <= nxt_dpu_expt_catch_if2;
      dpu_rst_catch_if2  <= nxt_dpu_rst_catch_if2;
      debug_catch_if2    <= nxt_debug_catch_if2;
      cpsr_itd           <= dpu_sctlr_itd_i;
    end

  assign nxt_dpu_expt_catch_if2 = dpu_expt_catch_pending_i & ~stop_pfb;
  assign nxt_dpu_rst_catch_if2  = dpu_reset_catch_pending_i & ~stop_pfb;
  assign nxt_debug_catch_if2    = (dpu_expt_catch_pending_i | dpu_reset_catch_pending_i) & pfb_valid_if1 & ~dpu_pfu_force & ~debug_catch_if2;


  // TLB aborts are signalled in if1 and pipelined to if2 while external aborts and parity errors
  // are signalled in if2.
  // debug_catch_if2 is a pulse so it does not need any extra qualification. Also we need to be able to push debug_catch
  // even on a uTLB miss (valid_if2 = 1'b0) therefore do not use valid_if2 as a qualify term.
  assign abort_if2 = (tlb_abort_if2 & ~stop_pfb & ~btac_skew_loopkup_if4) | (valid_if2 & icb_ext_abort_if2_i) | debug_catch_if2;

  // If there is an incoming abort then prevent any further accesses to the main TLB
  assign abort_inbound = (abort_if2 |
                          (avalid_if3 & abuf_abt_if3) |
                          (bvalid_if3 & bbuf_abt_if3) |
                          (cvalid_if3 & cbuf_abt_if3));

  // Identify Thumb-32 instructions that only abort on later portions so that the IFAR can be adjusted
  assign abt_cross_fetch_boundary = instr_valid_if3[0] & instr_abt_if3[0] & ~abuf_abt_if3 & ~dpu_iq_full_i;

  // If there is an abort in if2 or we enter debug the fetch part of the PFB should be stopped, but
  // the if3 end of the pipeline should proceed.  If there is an abort/breakpoint/VCR in the if3 stage
  // instruction-0 all stages of the PFU should be stopped.
  assign nxt_stop_pfb_if3 = (instr_valid_if3[0] & ~dpu_iq_full_i & (instr_abt_if3[0]  |
                                                                    instr_pty_if3[0]  |
                                                                    instr_vcr_if3[0]  |
                                                                    instr_sw_bkpt_if3 |
                                                                    instr_hw_bkpt_if3[0]));

  assign nxt_stop_pfb = ((((stop_pfb | abort_if2) & ~force_if3) | nxt_stop_pfb_if3 | in_debug_or_wfx) & ~dpu_pfu_force) | enter_debug_or_wfx;

  // Generate the IFSR value, stage2 abort indicator and LPAE abort indicator based on the abort type.
  // If there is not a main or micro TLB abort then default to the external abort type indicators.
  assign nxt_abort_type_if3[6:0] = (pc_unalign_abort_if2                       ? `CA53_FAULT_LPAE_ALIGNMENT      :
                                    out_of_range_abort_mmu_on_if2              ? `CA53_FAULT_LPAE_TRANSLATION_L0 :
                                    out_of_range_abort_mmu_off_if2             ? `CA53_FAULT_LPAE_ADDR_SIZE_L0   :
                                    (main_tlb_abort_if2 | micro_tlb_abort_if2) ? tlb_abort_type_if2[6:0]         :
                                    icb_ext_abort_type_if2_i[1]                ? 7'b0011000                      : {~icb_ext_abort_type_if2_i[0], 6'b010000});

  assign nxt_stage2_abort_if3[1:0] = ~pc_unalign_abort_if2 &
                                     ~out_of_range_abort_mmu_on_if2 &
                                     ~out_of_range_abort_mmu_off_if2 &
                                     (main_tlb_abort_if2 | micro_tlb_abort_if2) ? stage2_abort_if2 : 2'b00;

  assign nxt_lpae_abort_if3        = ~pc_unalign_abort_if2 &
                                     ~out_of_range_abort_mmu_on_if2 &
                                     ~out_of_range_abort_mmu_off_if2 &
                                     (main_tlb_abort_if2 | micro_tlb_abort_if2) ? lpae_abort_if2 : tlb_lpae_mode_i;

  assign nxt_abort_ipa_if3[27:0]   = {28{stage2_abort_if2[1]}} & abort_ipa_if2;

  // ------------------------------------------------------
  // Main if1 stage registers
  // ------------------------------------------------------

  // Free running registers
  // The early_kill_if2, force_if1, force_if1_pf registers must always be one-shot
  // The utlb_flushed_if1 register must always be able to capture
  // There are not enough similar registers to make an enable viable for first_if1
  // The evnt_stall_if2 is used by the performance counters
  always @(posedge clk) begin
    early_kill_if2   <= kill_if1;
    force_if1        <= force_if0;
    force_if1_pf     <= force_if3;
    utlb_flushed_if1 <= utlb_flushed_if0;
    first_if1        <= first_if0;
    evnt_stall_if2   <= stall_if2;
  end

  // Valid register
  assign en_valid_if1 = (~stall_if1 & ~stall_if2) | force_if0 | stop_pfb;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      valid_if1 <= 1'b0;
    else if (en_valid_if1)
      valid_if1 <= nxt_valid_if1;

  // Address registers
  assign en_addr_if1 = (~stall_if1 & ~stall_if2) | force_if0;

  always @(posedge clk)
    if (en_addr_if1) begin
      agu_a_operand_if1[63:0] <= agu_a_operand_if0[63:0];
      agu_b_operand_if1[63:0] <= agu_b_operand_if0[63:0];
    end

  // ------------------------------------------------------
  // Main if2 stage registers
  // ------------------------------------------------------

  // Valid register
  assign en_valid_if2 = ~stall_if2 | force_if0 | abort_if2 | nxt_stop_pfb_if3 | brn_btac_pushed_if3;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      valid_if2 <= 1'b0;
    else if (en_valid_if2)
      valid_if2 <= nxt_valid_if2;

  // Abort registers (the data version must only capture fields when the abort is signalled in if1)
  assign en_abort_ctl_if2  = (first_if1 | (priv_mode_if1 ^ priv_mode_if2) | tlb_abort_if2) & ~stall_if2;
  assign en_abort_data_if2 = (first_if1 | (priv_mode_if1 ^ priv_mode_if2)                ) & ~stall_if2;

  assign nxt_tlb_abort_if2 = main_tlb_abort_if1 | micro_tlb_abort_if1 | pc_unalign_abort_if1 | out_of_range_abort_mmu_on_if1 | out_of_range_abort_mmu_off_if1;

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      tlb_abort_if2                  <= 1'b0;
      main_tlb_abort_if2             <= 1'b0;
      micro_tlb_abort_if2            <= 1'b0;
      pc_unalign_abort_if2           <= 1'b0;
      out_of_range_abort_mmu_on_if2  <= 1'b0;
      out_of_range_abort_mmu_off_if2 <= 1'b0;
    end else if (en_abort_ctl_if2) begin
      tlb_abort_if2                  <= nxt_tlb_abort_if2;
      main_tlb_abort_if2             <= main_tlb_abort_if1;
      micro_tlb_abort_if2            <= micro_tlb_abort_if1;
      pc_unalign_abort_if2           <= pc_unalign_abort_if1;
      out_of_range_abort_mmu_on_if2  <= out_of_range_abort_mmu_on_if1;
      out_of_range_abort_mmu_off_if2 <= out_of_range_abort_mmu_off_if1;
    end

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      stage2_abort_if2[1:0] <= 2'b00;
      lpae_abort_if2        <= 1'b0;
      abort_ipa_if2         <= {28{1'b0}};
    end else if (en_abort_data_if2) begin
      stage2_abort_if2[1:0] <= stage2_abort_if1[1:0];
      lpae_abort_if2        <= lpae_abort_if1;
      abort_ipa_if2         <= abort_ipa_if1[27:0];
    end

  always @(posedge clk)
    if (en_abort_data_if2)
      tlb_abort_type_if2 <= tlb_abort_type_if1[6:0];

  // Cache line specific registers
  assign en_line_if2 = pfb_valid_if1 & first_if1 & ~stall_if2;

  always @(posedge clk)
    if (en_line_if2) begin
      priv_mode_if2        <= priv_mode_if1;
      pa_if2[39:12]        <= pa_if1[39:12];
      attributes_if2[7:0]  <= attributes_if1[7:0];
      ns_dsc_if2           <= ns_dsc_if1;
      clean_state_if2[1:0] <= cpsr_state[1:0];
      utlb_flushed_if2     <= utlb_flushed_if1;
    end

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      hyp_mode_if2 <= 1'b0;
    else if (en_line_if2)
      hyp_mode_if2 <= hyp_mode_if1;

  // Address registers (and the TLB hit register too)
  assign en_addr_hi_if2 = pfb_valid_if1 & ~stall_if2 & (va_if1[48:10] != va_if2[48:10]);
  assign en_addr_lo_if2 = pfb_valid_if1 & ~stall_if2;
  assign nxt_va_if2     = va_if1[63:0];

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      va_if2[63:10] <= {54{1'b0}};
    else if (en_addr_hi_if2)
      va_if2[63:10] <= nxt_va_if2[63:10];

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      tlb_hit_if2 <=     1'b0;
      va_if2[9:0] <= {10{1'b0}};
    end else if (en_addr_lo_if2) begin
      tlb_hit_if2 <= tlb_hit_if1;
      va_if2[9:0] <= nxt_va_if2[9:0];
    end

  // ------------------------------------------------------
  // if3 stage A-Buffer
  // ------------------------------------------------------

  // For the 'A' fetch buffer we must choose between:
  //
  // Corrected predecode data
  // 'B' fetch buffer
  // Line Fill Buffer data (debug data if in debug state)
  // Instruction cache data (default)
  always @*
    case ({btic_hit_if3, icb_pdc_valid_if2_i, bvalid_if3})
      `ca53ifu_sel_1xx : begin
        abuf_way_if2        = {2{1'b0}};
        abuf_abt_if2        =    1'b0;
        abuf_bkpt_if2       = {4{1'b0}};
        abuf_vcr_if2        = {2{1'b0}};
        abuf_expt_catch_if2 =    1'b0;
        abuf_rst_catch_if2  =    1'b0;
        abuf_btic_if2       =    1'b1;
        abuf_cwf_hit_if2    =    1'b0;
        abuf_va_if2         = btic_abuf_va_if3[48:3];
        abuf_va_plus1_if2   = btic_bbuf_va_if3[12:3];
        abuf_va_plus2_if2   = btic_cbuf_va_if3[12:3];
        abuf_pdc_hazard_if2 =    1'b0;
      end
      `ca53ifu_sel_01x : begin
        abuf_way_if2        = abuf_way_if3;
        abuf_abt_if2        = abuf_abt_if3;
        abuf_bkpt_if2       = abuf_bkpt_if3;
        abuf_vcr_if2        = abuf_vcr_if3;
        abuf_expt_catch_if2 = abuf_expt_catch_if3;
        abuf_rst_catch_if2  = abuf_rst_catch_if3;
        abuf_btic_if2       = abuf_btic_if3;
        abuf_cwf_hit_if2    = abuf_cwf_hit_if3;
        abuf_va_if2         = abuf_va_if3;
        abuf_va_plus1_if2   = abuf_va_plus1_if3;
        abuf_va_plus2_if2   = abuf_va_plus2_if3;
        abuf_pdc_hazard_if2 = abuf_pdc_hazard_if3;
      end
      `ca53ifu_sel_001 : begin
        abuf_way_if2        = bbuf_way_if3;
        abuf_abt_if2        = bbuf_abt_if3;
        abuf_bkpt_if2       = bbuf_bkpt_if3;
        abuf_vcr_if2        = bbuf_vcr_if3;
        abuf_expt_catch_if2 = 1'b0; // it can only be set from a buf
        abuf_rst_catch_if2  = 1'b0; // it can only be set from a buf
        abuf_btic_if2       = bbuf_btic_if3;
        abuf_cwf_hit_if2    = bbuf_cwf_hit_if3;
        abuf_va_if2         = bbuf_va_if3;
        abuf_va_plus1_if2   = (cvalid_if3 ? cbuf_va_if3[12:3] : (valid_if2 ? va_if2[12:3] : va_if1[12:3]));
        abuf_va_plus2_if2   = (cvalid_if3 | valid_if2) ? va_if1[12:3] : va_if0[12:3];
        abuf_pdc_hazard_if2 = bbuf_pdc_hazard_if3;
      end
      `ca53ifu_sel_000 : begin
        abuf_way_if2        = icb_way_if2_i;
        abuf_abt_if2        = abort_if2;
        abuf_bkpt_if2       = tlb_bkpt_hit_if2_i[3:0];
        abuf_vcr_if2        = tlb_vcr_hit_if2_i;
        abuf_expt_catch_if2 = dpu_expt_catch_if2;
        abuf_rst_catch_if2  = dpu_rst_catch_if2;
        abuf_btic_if2       = 1'b0;
        abuf_cwf_hit_if2    = icb_lfb_hit_if2_i;
        abuf_va_if2         = va_if2[48:3];
        abuf_va_plus1_if2   = va_if1[12:3];
        abuf_va_plus2_if2   = va_if0[12:3];
        abuf_pdc_hazard_if2 = icb_pdc_hazard_if2_i;
      end
      default : begin
        abuf_way_if2        =  {2{1'bx}};
        abuf_abt_if2        =     1'bx;
        abuf_bkpt_if2       =  {4{1'bx}};
        abuf_vcr_if2        =  {2{1'bx}};
        abuf_expt_catch_if2 =     1'bx;
        abuf_rst_catch_if2  =     1'bx;
        abuf_btic_if2       =     1'bx;
        abuf_cwf_hit_if2    =     1'bx;
        abuf_va_if2         = {46{1'bx}};
        abuf_va_plus1_if2   = {10{1'bx}};
        abuf_va_plus2_if2   = {10{1'bx}};
        abuf_pdc_hazard_if2 =     1'bx;
      end
    endcase

  // By making the data mux select slightly more complicated and recirculating the data that is in the
  // buffer if a pre-decode error is being processed, but not in the selected section, the more timing
  // critical fetch buffer enable can be simplifed.
  assign abuf_idata_sel_00[4:0] = {btic_hit_if3,
                                   (icb_pdc_valid_if2_i & ip_if3[2:1] == 2'b00),
                                   icb_pdc_valid_if2_i, bvalid_if3, (icb_lfb_hit_if2_i | icb_dbg_hit_if2_i)};
  assign abuf_idata_sel_20[5:0] = {btic_hit_if3,
                                   (icb_pdc_valid_if2_i & ip_if3[2:1] == 2'b00),
                                   (icb_pdc_valid_if2_i & ip_if3[2:1] == 2'b01),
                                   icb_pdc_valid_if2_i, bvalid_if3, (icb_lfb_hit_if2_i | icb_dbg_hit_if2_i)};
  assign abuf_idata_sel_40[5:0] = {btic_hit_if3,
                                   (icb_pdc_valid_if2_i & ip_if3[2:1] == 2'b01),
                                   (icb_pdc_valid_if2_i & ip_if3[2:1] == 2'b10),
                                   icb_pdc_valid_if2_i, bvalid_if3, icb_lfb_hit_if2_i};
  assign abuf_idata_sel_60[5:0] = {btic_hit_if3,
                                   (icb_pdc_valid_if2_i & ip_if3[2:1] == 2'b10),
                                   pdc_crosses_buffers,
                                   icb_pdc_valid_if2_i, bvalid_if3, icb_lfb_hit_if2_i};

  always @*
    begin
      case (abuf_idata_sel_00[4:0])
        `ca53ifu_sel_1xxxx : abuf_idata_if2[19:0] = btic_abuf_if3[19:0];
        `ca53ifu_sel_01xxx : abuf_idata_if2[19:0] = icb_pdc_data_if2_i[19:0];
        `ca53ifu_sel_001xx : abuf_idata_if2[19:0] = abuf_if3[19:0];
        `ca53ifu_sel_0001x : abuf_idata_if2[19:0] = bbuf_if3[19:0];
        `ca53ifu_sel_00001 : abuf_idata_if2[19:0] = icb_lfb_data_if2_i[19:0];
        `ca53ifu_sel_00000 : abuf_idata_if2[19:0] = icb_data_if2_i[19:0];
        default            : abuf_idata_if2[19:0] = {20{1'bx}};
      endcase

      case (abuf_idata_sel_20[5:0])
        `ca53ifu_sel_1xxxxx : abuf_idata_if2[39:20] = btic_abuf_if3[39:20];
        `ca53ifu_sel_01xxxx : abuf_idata_if2[39:20] = icb_pdc_data_if2_i[39:20];
        `ca53ifu_sel_001xxx : abuf_idata_if2[39:20] = icb_pdc_data_if2_i[19:0];
        `ca53ifu_sel_0001xx : abuf_idata_if2[39:20] = abuf_if3[39:20];
        `ca53ifu_sel_00001x : abuf_idata_if2[39:20] = bbuf_if3[39:20];
        `ca53ifu_sel_000001 : abuf_idata_if2[39:20] = icb_lfb_data_if2_i[39:20];
        `ca53ifu_sel_000000 : abuf_idata_if2[39:20] = icb_data_if2_i[39:20];
        default             : abuf_idata_if2[39:20] = {20{1'bx}};
      endcase

      case (abuf_idata_sel_40[5:0])
        `ca53ifu_sel_1xxxxx : abuf_idata_if2[59:40] = btic_abuf_if3[59:40];
        `ca53ifu_sel_01xxxx : abuf_idata_if2[59:40] = icb_pdc_data_if2_i[39:20];
        `ca53ifu_sel_001xxx : abuf_idata_if2[59:40] = icb_pdc_data_if2_i[19:0];
        `ca53ifu_sel_0001xx : abuf_idata_if2[59:40] = abuf_if3[59:40];
        `ca53ifu_sel_00001x : abuf_idata_if2[59:40] = bbuf_if3[59:40];
        `ca53ifu_sel_000001 : abuf_idata_if2[59:40] = icb_lfb_data_if2_i[59:40];
        `ca53ifu_sel_000000 : abuf_idata_if2[59:40] = icb_data_if2_i[59:40];
        default             : abuf_idata_if2[59:40] = {20{1'bx}};
      endcase

      case (abuf_idata_sel_60[5:0])
        `ca53ifu_sel_1xxxxx : abuf_idata_if2[79:60] = btic_abuf_if3[79:60];
        `ca53ifu_sel_01xxxx : abuf_idata_if2[79:60] = icb_pdc_data_if2_i[39:20];
        `ca53ifu_sel_001xxx : abuf_idata_if2[79:60] = icb_pdc_data_if2_i[19:0];
        `ca53ifu_sel_0001xx : abuf_idata_if2[79:60] = abuf_if3[79:60];
        `ca53ifu_sel_00001x : abuf_idata_if2[79:60] = bbuf_if3[79:60];
        `ca53ifu_sel_000001 : abuf_idata_if2[79:60] = icb_lfb_data_if2_i[79:60];
        `ca53ifu_sel_000000 : abuf_idata_if2[79:60] = icb_data_if2_i[79:60];
        default             : abuf_idata_if2[79:60] = {20{1'bx}};
      endcase
    end

  assign en_abuf_idata = (dbg_valid_if2 |
                          icb_pdc_valid_if2_i |
                          btic_hit_if3 |
                          ((valid_if2 | abort_if2) & ~avalid_if3) |
                          ((valid_if2 | abort_if2) & ~bvalid_if3 & next64_if3) |
                          (                           bvalid_if3 & next64_if3)) & (~nxt_stop_pfb_if3 | abt_cross_fetch_boundary);

  always @(posedge clk)
    if (en_abuf_idata) begin
      abuf_if3[79:0]          <= abuf_idata_if2[79:0];
      abuf_bkpt_if3[3:0]      <= abuf_bkpt_if2[3:0];
      abuf_vcr_if3[1:0]       <= abuf_vcr_if2[1:0];
      abuf_state_if3[1:0]     <= clean_state_if2[1:0];
      abuf_btic_if3           <= abuf_btic_if2;
      abuf_cwf_hit_if3        <= abuf_cwf_hit_if2;
      abuf_va_if3[48:3]       <= abuf_va_if2[48:3];
      abuf_va_plus1_if3[12:3] <= abuf_va_plus1_if2[12:3];
      abuf_va_plus2_if3[12:3] <= abuf_va_plus2_if2[12:3];
      abuf_pdc_hazard_if3     <= abuf_pdc_hazard_if2;
    end

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      abuf_abt_if3        <= 1'b0;
      abuf_expt_catch_if3 <= 1'b0;
      abuf_rst_catch_if3  <= 1'b0;
      abuf_way_if3        <= 2'b00;
    end
    else if (en_abuf_idata) begin
      abuf_abt_if3        <= abuf_abt_if2;
      abuf_expt_catch_if3 <= abuf_expt_catch_if2;
      abuf_rst_catch_if3  <= abuf_rst_catch_if2;
      abuf_way_if3        <= abuf_way_if2[1:0];
    end

  // ------------------------------------------------------
  // if3 stage B-Buffer
  // ------------------------------------------------------

  // For the 'B' fetch buffer we must choose between:
  //
  // Corrected predecode data
  // 'C' fetch buffer
  // Line Fill Buffer data
  // Instruction cache data (default)
  assign pdc_crosses_buffers = icb_pdc_valid_if2_i & ip_top_buf_if3;

  always @*
    case ({btic_hit_if3, pdc_crosses_buffers, cvalid_if3})
      `ca53ifu_sel_1xx : begin
        bbuf_way_if2          = {2{1'b0}};
        bbuf_abt_if2          =    1'b0;
        bbuf_bkpt_if2         = {4{1'b0}};
        bbuf_vcr_if2          = {2{1'b0}};
        bbuf_cwf_hit_if2      =    1'b0;
        bbuf_utlb_flushed_if2 =    1'b0;
        bbuf_btic_if2         =    1'b1;
        bbuf_va_if2           = btic_bbuf_va_if3;
        bbuf_pdc_hazard_if2   =    1'b0;
      end
      `ca53ifu_sel_01x : begin
        bbuf_way_if2          = bbuf_way_if3;
        bbuf_abt_if2          = bbuf_abt_if3;
        bbuf_bkpt_if2         = bbuf_bkpt_if3;
        bbuf_vcr_if2          = bbuf_vcr_if3;
        bbuf_cwf_hit_if2      = bbuf_cwf_hit_if3;
        bbuf_utlb_flushed_if2 = bbuf_utlb_flushed_if3;
        bbuf_btic_if2         = bbuf_btic_if3;
        bbuf_va_if2           = bbuf_va_if3;
        bbuf_pdc_hazard_if2   = bbuf_pdc_hazard_if3;
      end
      `ca53ifu_sel_001 : begin
        bbuf_way_if2          = cbuf_way_if3;
        bbuf_abt_if2          = cbuf_abt_if3;
        bbuf_bkpt_if2         = cbuf_bkpt_if3;
        bbuf_vcr_if2          = cbuf_vcr_if3;
        bbuf_cwf_hit_if2      = cbuf_cwf_hit_if3;
        bbuf_utlb_flushed_if2 = cbuf_utlb_flushed_if3;
        bbuf_btic_if2         = 1'b0;
        bbuf_va_if2           = cbuf_va_if3;
        bbuf_pdc_hazard_if2   = cbuf_pdc_hazard_if3;
      end
      `ca53ifu_sel_000 : begin
        bbuf_way_if2          = icb_way_if2_i;
        bbuf_abt_if2          = abort_if2;
        bbuf_bkpt_if2         = tlb_bkpt_hit_if2_i[3:0];
        bbuf_vcr_if2          = tlb_vcr_hit_if2_i;
        bbuf_cwf_hit_if2      = icb_lfb_hit_if2_i;
        bbuf_utlb_flushed_if2 = utlb_flushed_if2;
        bbuf_btic_if2         = 1'b0;
        bbuf_va_if2           = va_if2[48:3];
        bbuf_pdc_hazard_if2   = icb_pdc_hazard_if2_i;
      end
      default : begin
        bbuf_way_if2          =  {2{1'bx}};
        bbuf_abt_if2          =     1'bx;
        bbuf_bkpt_if2         =  {4{1'bx}};
        bbuf_vcr_if2          =  {2{1'bx}};
        bbuf_cwf_hit_if2      =     1'bx;
        bbuf_utlb_flushed_if2 =     1'bx;
        bbuf_btic_if2         =     1'bx;
        bbuf_va_if2           = {46{1'bx}};
        bbuf_pdc_hazard_if2   =     1'bx;
      end
    endcase

  always @*
    begin
      case ({btic_hit_if3, pdc_crosses_buffers, cvalid_if3, icb_lfb_hit_if2_i})
        `ca53ifu_sel_1xxx : bbuf_idata_if2[19:0] = btic_bbuf_if3[19:0];
        `ca53ifu_sel_01xx : bbuf_idata_if2[19:0] = icb_pdc_data_if2_i[39:20];
        `ca53ifu_sel_001x : bbuf_idata_if2[19:0] = cbuf_if3[19:0];
        `ca53ifu_sel_0001 : bbuf_idata_if2[19:0] = icb_lfb_data_if2_i[19:0];
        `ca53ifu_sel_0000 : bbuf_idata_if2[19:0] = icb_data_if2_i[19:0];
        default           : bbuf_idata_if2[19:0] = {20{1'bx}};
      endcase

      case ({btic_hit_if3, pdc_crosses_buffers, cvalid_if3, icb_lfb_hit_if2_i})
        `ca53ifu_sel_1xxx : bbuf_idata_if2[79:20] = btic_bbuf_if3[79:20];
        `ca53ifu_sel_01xx : bbuf_idata_if2[79:20] = bbuf_if3[79:20];
        `ca53ifu_sel_001x : bbuf_idata_if2[79:20] = cbuf_if3[79:20];
        `ca53ifu_sel_0001 : bbuf_idata_if2[79:20] = icb_lfb_data_if2_i[79:20];
        `ca53ifu_sel_0000 : bbuf_idata_if2[79:20] = icb_data_if2_i[79:20];
        default           : bbuf_idata_if2[79:20] = {60{1'bx}};
      endcase
    end

  assign en_bbuf_idata = (pdc_crosses_buffers |
                          btic_bbuf_valid_if3 |
                          ((valid_if2 | abort_if2) & avalid_if3 & ~bvalid_if3 & ~next64_if3) |
                          ((valid_if2 | abort_if2) & bvalid_if3 & ~cvalid_if3 &  next64_if3) |
                          (                                        cvalid_if3 &  next64_if3));

  always @(posedge clk)
    if (en_bbuf_idata) begin
      bbuf_if3[79:0]        <= bbuf_idata_if2[79:0];
      bbuf_bkpt_if3[3:0]    <= bbuf_bkpt_if2[3:0];
      bbuf_vcr_if3[1:0]     <= bbuf_vcr_if2[1:0];
      bbuf_cwf_hit_if3      <= bbuf_cwf_hit_if2;
      bbuf_utlb_flushed_if3 <= bbuf_utlb_flushed_if2;
      bbuf_btic_if3         <= bbuf_btic_if2;
      bbuf_va_if3[48:3]     <= bbuf_va_if2[48:3];
      bbuf_pdc_hazard_if3   <= bbuf_pdc_hazard_if2;
    end

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      bbuf_abt_if3 <= 1'b0;
      bbuf_way_if3 <= 2'b00;
    end else if (en_bbuf_idata) begin
      bbuf_abt_if3 <= bbuf_abt_if2;
      bbuf_way_if3 <= bbuf_way_if2[1:0];
    end
  // ------------------------------------------------------
  // if3 stage C-Buffer
  // ------------------------------------------------------

  // For the 'C' fetch buffer we must choose between:
  //
  // Line Fill Buffer data
  // Instruction cache data (default)
  assign en_cbuf_idata = icb_mbist_en_i[0] | ((valid_if2 | abort_if2) & bvalid_if3 & ~next64_if3 & ~btic_hit_if3);

  always @ (*)
    case ({icb_mbist_en_i[2:1], icb_lfb_hit_if2_i})
      `ca53ifu_sel_1xx : cbuf_idata_if2 = {{21{1'b0}}, btac_stg1_ram_rdata_i[58:0]}; // MBIST read BTAC stage 1
      `ca53ifu_sel_01x : cbuf_idata_if2 = {{30{1'b0}}, btac_stg0_ram_rdata_i[49:0]}; // MBIST read BTAC stage 0
      `ca53ifu_sel_001 : cbuf_idata_if2 = icb_lfb_data_if2_i[79:0];                  // LFB hit
      `ca53ifu_sel_000 : cbuf_idata_if2 = icb_data_if2_i[79:0];                      // Cache hit / MBIST dataram read
      default          : cbuf_idata_if2 = {80{1'bX}};
    endcase

  always @(posedge clk)
    if (en_cbuf_idata) begin
      cbuf_if3[79:0]        <= cbuf_idata_if2[79:0];
      cbuf_bkpt_if3[3:0]    <= tlb_bkpt_hit_if2_i[3:0];
      cbuf_vcr_if3[1:0]     <= tlb_vcr_hit_if2_i[1:0];
      cbuf_cwf_hit_if3      <= icb_lfb_hit_if2_i;
      cbuf_utlb_flushed_if3 <= utlb_flushed_if2;
      cbuf_va_if3[48:3]     <= va_if2[48:3];
      cbuf_pdc_hazard_if3   <= icb_pdc_hazard_if2_i;
    end

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      cbuf_abt_if3 <= 1'b0;
      cbuf_way_if3 <= 2'b00;
    end else if (en_cbuf_idata) begin
      cbuf_abt_if3 <= abort_if2;
      cbuf_way_if3 <= icb_way_if2_i[1:0];
    end

  // ------------------------------------------------------
  // if3 stage abort, debug and non-specific registers
  // ------------------------------------------------------

  // Abort registers
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      abort_type_if3[6:0]   <= `CA53_FAULT_VMSA_PERMISSION_PAGE; // A default value that won't trigger any OVLs
      stage2_abort_if3[1:0] <= 2'b00;
      lpae_abort_if3        <= 1'b0;
    end else if (abort_if2 | force_if0) begin
      abort_type_if3[6:0]   <= nxt_abort_type_if3;
      stage2_abort_if3[1:0] <= nxt_stage2_abort_if3;
      lpae_abort_if3        <= nxt_lpae_abort_if3;
    end

  always @(posedge clk)
    if (abort_if2 | force_if0)
      abort_ipa_if3[27:0]   <= nxt_abort_ipa_if3;

  // Debug registers
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      dbg_valid_if3 <= 1'b0;
      stop_pfb      <= 1'b1; // PFU should be stopped out of reset
    end else begin
      dbg_valid_if3 <= dbg_valid_if2;
      stop_pfb      <= nxt_stop_pfb;
    end

  // Indicate the LPAE value for the current instruction
  // Accurate for TLB aborts and external aborts, approximate for breakpoints and vector catch
  assign nxt_ifsr_lpae = instr_abt_if3[0] ? lpae_abort_if3 : tlb_lpae_mode_i;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ifsr_lpae <= 1'b0;
    else if (pfb_push[0])
      ifsr_lpae <= nxt_ifsr_lpae;

  // Indicate that the design is about to enter debug or WFX
  assign nxt_in_debug_or_wfx = (~dpu_pfu_force & in_debug_or_wfx) | enter_debug_or_wfx;

  always @(posedge clk)
    in_debug_or_wfx <= nxt_in_debug_or_wfx;

  // Hold the ICU busy signal to prevent a request being issued to the ICU when it is not ready
  // to receive it yet (a CP15 transaction in ICU while a micro-TLB miss is being processed
  // would break if it did not complete before the page was returned and the pfb_valid_if1 signal
  // reasserted again).
  always @(posedge clk)
    icu_busy_held <= icb_busy_if1_i;

  // ------------------------------------------------------
  // Instruction pointer generation
  // ------------------------------------------------------

  // Speculatively calculate new instruction pointer values depending on whether
  // one or two instructions are sent to the DPU and the size of those instructions.
  assign ip_push_one[2:0] = ip_if3[2:1] + instr0_size[1:0];
  assign ip_push_two[2:0] = ip_if3[2:1] + instr0_size[1:0] + instr1_size[1:0];

  // Generate control signals to select the speculative instruction pointer based on the
  // instructions that can be sent to the DPU.  For example, certain branch instructions in
  // decoder 1 can not be decoded so we can only increment the instruction pointer by one
  // instruction.  Suppress both selects if the error buffer is valid or about to be valid.
  assign sel_push_one = pfb_push[0];
  assign sel_push_two = pfb_push[1];

  // Indicate that we have crossed a 64-bit boundary
  assign next64_if3 = (sel_push_two & ip_push_two[2]) | (sel_push_one & ip_push_one[2]);

  // Generate the next instruction pointer and replicated (for timing) fetch buffer
  // mux control signals:
  // - If in debug state, point at the bottom 32-bits
  // - If the if3 fetch buffers are empty (typically, but not always, due to a force),
  //   use the address in if2 as the new instruction pointer.
  // - Otherwise use the sequential instruction pointer depending on how many instructions
  //   were pushed on the previous cycle.
  always @*
    case ({btic_hit_if3, (dbg_valid_if2 | abt_cross_fetch_boundary), ~avalid_if3, sel_push_two, sel_push_one})
      `ca53ifu_sel_1xxxx : begin
        nxt_ip_if3        =  btic_abuf_va_if3[2:1];
        nxt_shift_n32_if3 = ~btic_abuf_va_if3[2];
        nxt_shift_32_if3  =  btic_abuf_va_if3[2];
        nxt_shift_n16_if3 = ~btic_abuf_va_if3[1];
        nxt_shift_16_if3  =  btic_abuf_va_if3[1];
      end
      `ca53ifu_sel_01xxx : begin
        nxt_ip_if3        = 2'b00;
        nxt_shift_n32_if3 = 1'b1;
        nxt_shift_32_if3  = 1'b0;
        nxt_shift_n16_if3 = 1'b1;
        nxt_shift_16_if3  = 1'b0;
      end
      `ca53ifu_sel_001xx : begin
        nxt_ip_if3        =  va_if2[2:1];
        nxt_shift_n32_if3 = ~va_if2[2];
        nxt_shift_32_if3  =  va_if2[2];
        nxt_shift_n16_if3 = ~va_if2[1];
        nxt_shift_16_if3  =  va_if2[1];
      end
      `ca53ifu_sel_0001x : begin
        nxt_ip_if3        =  ip_push_two[1:0];
        nxt_shift_n32_if3 = ~ip_push_two[1];
        nxt_shift_32_if3  =  ip_push_two[1];
        nxt_shift_n16_if3 = ~ip_push_two[0];
        nxt_shift_16_if3  =  ip_push_two[0];
      end
      `ca53ifu_sel_00001 : begin
        nxt_ip_if3        =  ip_push_one[1:0];
        nxt_shift_n32_if3 = ~ip_push_one[1];
        nxt_shift_32_if3  =  ip_push_one[1];
        nxt_shift_n16_if3 = ~ip_push_one[0];
        nxt_shift_16_if3  =  ip_push_one[0];
      end
      `ca53ifu_sel_00000 : begin
        nxt_ip_if3        = ip_if3[2:1];
        nxt_shift_n32_if3 = shift_n32_if3[0];
        nxt_shift_32_if3  = shift_32_if3[0];
        nxt_shift_n16_if3 = shift_n16_if3[0];
        nxt_shift_16_if3  = shift_16_if3[0];
      end
      default : begin
        nxt_ip_if3        = 2'bxx;
        nxt_shift_n32_if3 = 1'bx;
        nxt_shift_32_if3  = 1'bx;
        nxt_shift_n16_if3 = 1'bx;
        nxt_shift_16_if3  = 1'bx;
      end
    endcase

  assign va_if3_en = (btic_hit_if3 | dbg_valid_if2 | valid_if2 | tlb_abort_if2 | (avalid_if3 & ~dpu_iq_full_i)) &
                     (~nxt_stop_pfb_if3 | abt_cross_fetch_boundary);

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ip_if3[2:1]         <= {2{1'b0}};
      shift_n32_if3[10:0] <= {11{1'b0}};
      shift_32_if3[10:0]  <= {11{1'b0}};
      shift_n16_if3[8:0]  <= {9{1'b0}};
      shift_16_if3[8:0]   <= {9{1'b0}};
      ip_top_buf_if3      <=    1'b0;
    end else if (va_if3_en) begin
      ip_if3[2:1]         <= nxt_ip_if3[2:1];
      shift_n32_if3[10:0] <= nxt_shift_n32_exp_if3;
      shift_32_if3[10:0]  <= nxt_shift_32_exp_if3;
      shift_n16_if3[8:0]  <= nxt_shift_n16_exp_if3;
      shift_16_if3[8:0]   <= nxt_shift_16_exp_if3;
      ip_top_buf_if3      <= nxt_ip_top_buf_if3;
    end

  assign nxt_shift_n32_exp_if3 = {11{nxt_shift_n32_if3}};
  assign nxt_shift_32_exp_if3  = {11{nxt_shift_32_if3}};
  assign nxt_shift_n16_exp_if3 =  {9{nxt_shift_n16_if3}};
  assign nxt_shift_16_exp_if3  =  {9{nxt_shift_16_if3}};
  assign nxt_ip_top_buf_if3    = nxt_shift_32_if3 & nxt_shift_16_if3;

  // ------------------------------------------------------
  // Fetch buffer control
  // ------------------------------------------------------

  // The following conditions (in order of priority) define whether
  // the 'A', 'B' and 'C' fetch buffers are either valid or empty
  always @*
    begin
      if (dpu_pfu_force | (force_if3 & ~btic_hit_if3) | nxt_stop_pfb_if3 | dbg_valid_if3 | brn_btac_pushed_if3)
        nxt_avalid_if3 = 1'b0;
      else if (btic_hit_if3 | abort_if2 | dbg_valid_if2)
        nxt_avalid_if3 = 1'b1;
      else
        nxt_avalid_if3 = (// Buffer currently valid and not exhasted
                          (avalid_if3 & ~next64_if3) |
                          // Buffer will accept from newer 'B' buffer
                          bvalid_if3 |
                          // Buffer will accept from cache hit
                          (valid_if2 & icb_hit_if2_i) |
                          // Buffer will accept from LFB hit
                          (valid_if2 & icb_lfb_hit_if2_i));
    end

  always @*
    begin
      if (dpu_pfu_force | (force_if3 & ~btic_bbuf_valid_if3) | nxt_stop_pfb_if3 | brn_btac_pushed_if3)
        nxt_bvalid_if3 = 1'b0;
      else if (btic_bbuf_valid_if3 | abort_if2)
        nxt_bvalid_if3 = 1'b1;
      else
        nxt_bvalid_if3 = (// Buffer currently valid and 'A' buffer not exhasted
                          (bvalid_if3 & ~next64_if3) |
                          // Buffer will accept from newer 'C' buffer
                          cvalid_if3 |
                          // Buffer will accept from cache hit as 'A' buffer is not exhasted or is exhasted,
                          // but the 'B' buffer contents will move to the 'A' buffer
                          ((~next64_if3 | (next64_if3 & bvalid_if3)) & avalid_if3 & valid_if2 & icb_hit_if2_i) |
                          // Buffer will accept from LFB hit as 'A' buffer is not exhasted or is exhasted,
                          // but the 'B' buffer contents will move to the 'A' buffer
                          ((~next64_if3 | (next64_if3 & bvalid_if3)) & avalid_if3 & valid_if2 & icb_lfb_hit_if2_i));
    end

  always @*
    begin
      if (force_if0 | nxt_stop_pfb_if3 | brn_btac_pushed_if3)
        nxt_cvalid_if3 = 1'b0;
      else if (abort_if2)
        nxt_cvalid_if3 = 1'b1;
      else
        nxt_cvalid_if3 = (// Buffer currently valid and 'A' buffer not exhasted
                          (cvalid_if3 & ~next64_if3) |
                          // Buffer will accept from cache hit as 'B' buffer is not exhasted
                          (bvalid_if3 & ~next64_if3 & valid_if2 & icb_hit_if2_i) |
                          // Buffer will accept from LFB hit as 'B' buffer is not exhasted
                          (bvalid_if3 & ~next64_if3 & valid_if2 & icb_lfb_hit_if2_i));
    end

  // Fetch buffer control registers
  always@(posedge clk or negedge reset_n)
    if (!reset_n) begin
      avalid_if3 <= 1'b0;
      bvalid_if3 <= 1'b0;
      cvalid_if3 <= 1'b0;
    end else begin
      avalid_if3 <= nxt_avalid_if3;
      bvalid_if3 <= nxt_bvalid_if3;
      cvalid_if3 <= nxt_cvalid_if3;
    end

  // ------------------------------------------------------
  // Valid instruction check
  // ------------------------------------------------------

  assign instr_valid_if3[0] = (bvalid_if3 |
                               (avalid_if3 & ~ip_if3[2]) |
                               (avalid_if3 &  ip_if3[2] & ~ip_if3[1]) |
                               (avalid_if3 &  ip_if3[2] &  ip_if3[1] & ~abuf_if3[79]));

  assign instr_valid_if3[1] = (~dbg_valid_if3 &
                               (bvalid_if3 |
                                (avalid_if3 & ~ip_if3[2] & ~ip_if3[1]) |
                                (avalid_if3 & ~ip_if3[2] & ~abuf_if3[39]) |
                                (avalid_if3 & ~ip_if3[2] &  abuf_if3[39] & ~abuf_if3[79]) |
                                (avalid_if3 &  ip_if3[2] & ~ip_if3[1] & ~abuf_if3[59] & ~abuf_if3[79] & instr_is_thumb_if3)));

  // ------------------------------------------------------
  // Virtual address generation
  // ------------------------------------------------------

  // Addition used only by the branch prediction logic in the next cycle
  assign va_if0 = (avalid_if3 ? abuf_va_if3[12:3] : va_if2[12:3]) + {1'b1, avalid_if3};

  // Additions that get used in multiple places so it is easier to generate once then reuse
  assign va_push_one_if3[48:1] = {{abuf_va_if3[48:3], ip_if3[2:1]} + ({(instr_is_t32_if3[0] | instr_is_a32_if3 | instr_is_a64_if3), instr_is_t16_if3[0]})};
  assign va_push_two_if3[48:1] = {{abuf_va_if3[48:3], ip_if3[2:1]} + ({(instr_is_t32_if3[0] | instr_is_a32_if3 | instr_is_a64_if3), instr_is_t16_if3[0]})} + instr1_size[1:0];

  // ------------------------------------------------------
  // if3 Instruction muxes
  // ------------------------------------------------------

  // Extract instructions on a 32-bit basis.  This mux can be used for all A32/A64 instructions.
  assign imux_32_if3[ 9: 0] = (({10{shift_n32_if3[0]}} & abuf_if3[ 9: 0]) |
                               ({10{shift_32_if3[0] }} & abuf_if3[49:40]));

  assign imux_32_if3[19:10] = (({10{shift_n32_if3[1]}} & abuf_if3[19:10]) |
                               ({10{shift_32_if3[1] }} & abuf_if3[59:50]));

  assign imux_32_if3[29:20] = (({10{shift_n32_if3[2]}} & abuf_if3[29:20]) |
                               ({10{shift_32_if3[2] }} & abuf_if3[69:60]));

  assign imux_32_if3[39:30] = (({10{shift_n32_if3[3]}} & abuf_if3[39:30]) |
                               ({10{shift_32_if3[3] }} & abuf_if3[79:70]));

  assign imux_32_if3[49:40] = (({10{shift_n32_if3[4]}} & abuf_if3[49:40]) |
                               ({10{shift_32_if3[4] }} & bbuf_if3[ 9: 0]));

  assign imux_32_if3[59:50] = (({10{shift_n32_if3[5]}} & abuf_if3[59:50]) |
                               ({10{shift_32_if3[5] }} & bbuf_if3[19:10]));

  assign imux_32_if3[69:60] = (({10{shift_n32_if3[6]}} & abuf_if3[69:60]) |
                               ({10{shift_32_if3[6] }} & bbuf_if3[29:20]));

  assign imux_32_if3[79:70] = (({10{shift_n32_if3[7]}} & abuf_if3[79:70]) |
                               ({10{shift_32_if3[7] }} & bbuf_if3[39:30]));

  assign imux_32_if3[89:80] = (({10{shift_n32_if3[8]}} & bbuf_if3[ 9: 0]) |
                               ({10{shift_32_if3[9] }} & bbuf_if3[49:40]));

  assign imux_32_if3[99:90] = (({10{shift_n32_if3[9]}} & bbuf_if3[19:10]) |
                               ({10{shift_32_if3[9] }} & bbuf_if3[59:50]));

  assign instr0_32_if3[39:0] = imux_32_if3[39: 0];
  assign instr1_32_if3[39:0] = imux_32_if3[79:40];

  // Extract instructions on a 16-bit basis.  This mux can be used for all T32/T16 instructions.
  assign imux_if3[ 9: 0] = (({10{shift_n16_if3[0]}} & imux_32_if3[ 9: 0]) |
                            ({10{shift_16_if3[0] }} & imux_32_if3[29:20]));

  assign imux_if3[19:10] = (({10{shift_n16_if3[1]}} & imux_32_if3[19:10]) |
                            ({10{shift_16_if3[1] }} & imux_32_if3[39:30]));

  assign imux_if3[29:20] = (({10{shift_n16_if3[2]}} & imux_32_if3[29:20]) |
                            ({10{shift_16_if3[2] }} & imux_32_if3[49:40]));

  assign imux_if3[39:30] = (({10{shift_n16_if3[3]}} & imux_32_if3[39:30]) |
                            ({10{shift_16_if3[3] }} & imux_32_if3[59:50]));

  assign imux_if3[49:40] = (({10{shift_n16_if3[4]}} & imux_32_if3[49:40]) |
                            ({10{shift_16_if3[4] }} & imux_32_if3[69:60]));

  assign imux_if3[59:50] = (({10{shift_n16_if3[5]}} & imux_32_if3[59:50]) |
                            ({10{shift_16_if3[5] }} & imux_32_if3[79:70]));

  assign imux_if3[69:60] = (({10{shift_n16_if3[6]}} & imux_32_if3[69:60]) |
                            ({10{shift_16_if3[6] }} & imux_32_if3[89:80]));

  assign imux_if3[79:70] = (({10{shift_n16_if3[7]}} & imux_32_if3[79:70]) |
                            ({10{shift_16_if3[7] }} & imux_32_if3[99:90]));

  // Dedicated, high speed select signal only used for extracting instr1 quickly
  assign instr1_select = instr_is_thumb_if3 & ~((shift_n32_if3[10] & shift_n16_if3[8] & abuf_if3[19]) |
                                                (shift_n32_if3[10] & shift_16_if3[8]  & abuf_if3[39]) |
                                                (shift_32_if3[10]  & shift_n16_if3[8] & abuf_if3[59]) |
                                                (shift_32_if3[10]  & shift_16_if3[8]  & abuf_if3[79]));

  assign instr0_if3[39:0] = imux_if3[39:0];
  assign instr1_if3[39:0] = instr1_select ? imux_if3[59:20] : imux_if3[79:40];

  // Construct aborts (Aborts have double-word granularity)
  // Instructions that span a double-word boundary can abort if any units hit an abort
  // To simplify timing, the instruction-1 check is coarse as aborts can not be
  // transferred from this position.
  assign instr_abt_if3[0] = (abuf_abt_if3 |
                             (bvalid_if3 & bbuf_abt_if3 & ip_top_buf_if3 & instr_is_thumb_if3 &
                              (abuf_if3[79] | (abuf_if3[75:73] == 3'b111 & abuf_if3[72:71] != 2'b00))));

  assign instr_abt_if3[1] = bvalid_if3 & bbuf_abt_if3;

  // Construct breakpoints (Breakpoints have half-word granularity)
  // Instructions can only trigger a breakpoint if the first unit hits a breakpoint
  // To simplify timing, the instruction-1 check is coarse as breakponts can not be
  // transferred from this position.
  assign instr_hw_bkpt_if3[0] = ((~ip_if3[2] & ~ip_if3[1] & avalid_if3 & abuf_bkpt_if3[0]) |
                                 (~ip_if3[2] &  ip_if3[1] & avalid_if3 & abuf_bkpt_if3[1]) |
                                 ( ip_if3[2] & ~ip_if3[1] & avalid_if3 & abuf_bkpt_if3[2]) |
                                 ( ip_if3[2] &  ip_if3[1] & avalid_if3 & abuf_bkpt_if3[3]));

  assign instr_hw_bkpt_if3[1] = ((~ip_if3[2] & avalid_if3 & (abuf_bkpt_if3[1] | abuf_bkpt_if3[2] | abuf_bkpt_if3[3])) |
                                 ( ip_if3[2] & avalid_if3 &                                        abuf_bkpt_if3[3])  |
                                 ( ip_if3[2] & bvalid_if3 & (bbuf_bkpt_if3[0] | bbuf_bkpt_if3[1])));

  // Construct vector catch (VCRs have word granularity)
  // Instructions can only trigger a VCR if the first unit hits a VCR
  // To simplify timing, the instruction-1 check is coarse as vector catch can not be
  // transferred from this position.
  assign instr_vcr_if3[0] = ip_if3[2] ? (abuf_vcr_if3[1] & avalid_if3) : (abuf_vcr_if3[0] & avalid_if3);
  assign instr_vcr_if3[1] = ip_if3[2] ? (bbuf_vcr_if3[0] & bvalid_if3) : (abuf_vcr_if3[1] & avalid_if3);

  // Parity error indication is only required when the CPU_CACHE_PROTECTION
  // configuration is present
  generate if (CPU_CACHE_PROTECTION) begin : genif_cache_protection
    reg [3:0] abuf_pty_if2;
    reg [3:0] abuf_pty_if3;
    reg [3:0] bbuf_pty_if2;
    reg [3:0] bbuf_pty_if3;
    reg [3:0] cbuf_pty_if3;

    // A buffer parity error indication
    always @*
      case ({btic_hit_if3, icb_pdc_valid_if2_i, bvalid_if3})
        `ca53ifu_sel_1xx : abuf_pty_if2 = 4'b0000;
        `ca53ifu_sel_01x : abuf_pty_if2 = abuf_pty_if3;
        `ca53ifu_sel_001 : abuf_pty_if2 = bbuf_pty_if3;
        `ca53ifu_sel_000 : abuf_pty_if2 = icb_parity_err_if2_i;
        default          : abuf_pty_if2 = 4'bxxxx;
      endcase

    always @ (posedge clk or negedge reset_n)
      if (!reset_n)
        abuf_pty_if3 <= 4'b0000;
      else if (en_abuf_idata)
        abuf_pty_if3 <= abuf_pty_if2;

    // B buffer parity error indication
    always @*
      case ({btic_hit_if3, pdc_crosses_buffers, cvalid_if3})
        `ca53ifu_sel_1xx : bbuf_pty_if2 = 4'b0000;
        `ca53ifu_sel_01x : bbuf_pty_if2 = bbuf_pty_if3;
        `ca53ifu_sel_001 : bbuf_pty_if2 = cbuf_pty_if3;
        `ca53ifu_sel_000 : bbuf_pty_if2 = icb_parity_err_if2_i;
        default          : bbuf_pty_if2 = 4'bxxxx;
      endcase

    always @ (posedge clk or negedge reset_n)
      if (!reset_n)
        bbuf_pty_if3 <= 4'b0000;
      else if (en_bbuf_idata)
        bbuf_pty_if3 <= bbuf_pty_if2;

    // C buffer parity error indication
    always @ (posedge clk or negedge reset_n)
      if (!reset_n)
        cbuf_pty_if3 <= 4'b0000;
      else if (en_cbuf_idata)
        cbuf_pty_if3 <= icb_parity_err_if2_i;

    // Parity error indication is a subset of the abort cases.  In the case of
    // a parity error coming from the bbuf, the error is only notified when the
    // bbuf is valid due to real data, not when it was set due to a previous
    // abort.
    assign instr_pty_if3[0] = ((avalid_if3 & (|abuf_pty_if3) & ~abuf_abt_if3) |
                               (bvalid_if3 & (|bbuf_pty_if3) & ~bbuf_abt_if3 & ip_top_buf_if3 & instr_is_thumb_if3 &
                                (abuf_if3[79] | (abuf_if3[75:73] == 3'b111 & abuf_if3[72:71] != 2'b00))));

    assign instr_pty_if3[1] = bvalid_if3 & (|bbuf_pty_if3) & ~bbuf_abt_if3;

  end else begin : genif_cache_protection_stubs
    assign instr_pty_if3 = 2'b00;
  end endgenerate

  // ------------------------------------------------------
  // Architectural state
  // ------------------------------------------------------
  assign nxt_cpsr_state[1:0] = (dpu_pfu_force                                                     ? dpu_pfu_cpsr[9:8] :
                                instr_brn_exchange_a_if3[0]                                       ? 2'b01 :
                               (instr_brn_exchange_a_if3[1] & instr1_possible)                    ? 2'b01 :
                                instr_brn_exchange_t_if3[0]                                       ? 2'b00 :
                               (instr_brn_exchange_t_if3[1] & ~instr1_pdec_err & instr1_possible) ? 2'b00 :
                                brn_return_if3[0]                                                 ? {cpsr_state[1],  crs_hit_addr_if3[0] & ~cpsr_state[1]} :
                               (brn_return_if3[1] & ~instr1_pdec_err & instr1_possible)           ? {cpsr_state[1],  crs_hit_addr_if3[0] & ~cpsr_state[1]} :
                                btac_hit_if4                                                      ? {cpsr_state[1], btac_hit_addr_if4[0] & ~cpsr_state[1]} :
                                                                                                    cpsr_state[1:0]);

  always @*
    case ({dpu_pfu_force, (dbg_valid_if2 | force_if3)})
      2'b11, 2'b10 : begin
        nxt_cpsr_it_cond = dpu_pfu_cpsr[7:4];
        nxt_cpsr_it_mask = dpu_pfu_cpsr[3:0];
      end
      2'b01 : begin
        nxt_cpsr_it_cond = {4{1'b0}};
        nxt_cpsr_it_mask = {4{1'b0}};
      end
      2'b00 : begin
        nxt_cpsr_it_cond = it_cond_mask[7:4];
        nxt_cpsr_it_mask = it_cond_mask[3:0];
      end
      default : begin
        nxt_cpsr_it_cond = {4{1'bx}};
        nxt_cpsr_it_mask = {4{1'bx}};
      end
    endcase

  // Create timing optimized instruction state signals
  assign nxt_instr_is_a32_if3 = nxt_cpsr_state[1:0] == 2'b00;
  assign nxt_instr_is_a64_if3 = nxt_cpsr_state[1:0] == 2'b10;

  assign instr_en = dpu_pfu_force | dbg_valid_if2 | pfb_push[0] | btac_hit_if4;

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      cpsr_state             <= {2{1'b0}};
      cpsr_it_cond           <= {4{1'b0}};
      cpsr_it_mask           <= {4{1'b0}};
      instr_is_a32_if3       <= 1'b0;
      instr_is_a64_if3       <= 1'b0;
      instr_is_thumb_if3     <= 1'b0;
      instr_is_thumb_bpd_if3 <= 1'b1;
    end else if (instr_en) begin
      cpsr_state             <= nxt_cpsr_state[1:0];
      cpsr_it_cond           <= nxt_cpsr_it_cond;
      cpsr_it_mask           <= nxt_cpsr_it_mask;
      instr_is_a32_if3       <= nxt_instr_is_a32_if3;
      instr_is_a64_if3       <= nxt_instr_is_a64_if3;
      instr_is_thumb_if3     <= nxt_cpsr_state[0];
      instr_is_thumb_bpd_if3 <= nxt_cpsr_state[0];
    end

  // A64 state for debug decoder.  We do not use the CPSR state register for
  // this since it is used even after the force from Ret has arrived.
  always @(posedge clk)
    if (en_dbg_a64_state)
      dbg_a64_state <= dpu_fe_isa_ret_i[1];

  assign en_dbg_a64_state = dpu_fe_valid_ret_i & dpu_halt_ifu_i;

  // ------------------------------------------------------
  // State & size identification
  // ------------------------------------------------------

  // Instruction set identification signals
  assign instr_is_t16_if3[0] = instr_is_thumb_if3 &  ~instr0_if3[19];
  assign instr_is_t16_if3[1] = instr_is_thumb_if3 & (~instr0_if3[19] ? ~imux_if3[39] : ~imux_if3[59]);
  assign instr_is_t32_if3[0] = instr_is_thumb_if3 &   instr0_if3[19];
  assign instr_is_t32_if3[1] = instr_is_thumb_if3 & ( instr0_if3[19] ?  imux_if3[59] :  imux_if3[39]);

  // Instruction size
  assign instr0_size = {(instr_is_t32_if3[0] | instr_is_a32_if3 | instr_is_a64_if3), instr_is_t16_if3[0]};
  assign instr1_size = {(instr_is_t32_if3[1] | instr_is_a32_if3 | instr_is_a64_if3), instr_is_t16_if3[1]};

  // ------------------------------------------------------
  // IT instruction decoder
  // ------------------------------------------------------

  assign cpsr_it_cm[7:0] = pfb_push[1] ? {cpsr_it_cond[3:1], cpsr_it_mask[2:0], 2'b00} : // annotated two
                                         {cpsr_it_cond[3:1], cpsr_it_mask[3:0], 1'b0};   // annotated one

  assign it_cond_mask[7:0] = ((pfb_push[1] & instr_it_if3[1] & (~cpsr_itd | (instr1_if3[3:0] == 4'b1000))) ? instr1_if3[7:0] :
                              (pfb_push[0] & instr_it_if3[0] & (~cpsr_itd | (instr0_if3[3:0] == 4'b1000))) ? instr0_if3[7:0] : cpsr_it_cm);

  assign in_it_block[0] = (|cpsr_it_mask[3:0]);
  assign in_it_block[1] = (|cpsr_it_mask[2:0]);

  assign instr1_it_cond[3:0] = {cpsr_it_cond[3:1], cpsr_it_mask[3]};

  assign last_in_it[0] = cpsr_it_mask[3:0] == 4'b1000;
  assign last_in_it[1] = cpsr_it_mask[2:0] == 3'b100;

  // Decode architecturally unpredictable IT cases where instructions
  // either not permitted in an IT block or not permitted except when
  // last in an IT block.  These are treated as undefined.
  // For timing reason we do the calculation as early as possible
  ca53ifu_pf_it_undef
    u_ca53ifu_pf_it_undef_0
      (.pfb_instr_i    ({imux_if3[19:0], imux_if3[39:20]}),
       .in_it_i        (in_it_block[0]),
       .last_in_it_i   (last_in_it[0]),
       .undef_in_it_o  (it_undef[0])
       );

  ca53ifu_pf_it_undef
    u_ca53ifu_pf_it_undef_1
      (.pfb_instr_i    ({imux_if3[39:20], imux_if3[59:40]}),
       .in_it_i        (in_it_block[1]),
       .last_in_it_i   (last_in_it[1]),
       .undef_in_it_o  (it_undef[1])
       );

  ca53ifu_pf_it_undef
    u_ca53ifu_pf_it_undef_2
      (.pfb_instr_i    ({imux_if3[59:40], imux_if3[79:60]}),
       .in_it_i        (in_it_block[1]),
       .last_in_it_i   (last_in_it[1]),
       .undef_in_it_o  (it_undef[2])
       );

  assign instr1_it_undef = {it_undef[2],it_undef[1],instr1_select};

  // ------------------------------------------------------
  // Class decoders
  // ------------------------------------------------------

  ca53ifu_pf_dec_class
    u_ca53ifu_pf_dec0_class
      (// Inputs
       .instr_if3_i            (instr0_if3[39:0]),
       .instr_is_t16_if3_i     (instr_is_t16_if3[0]),
       // Outputs
       .instr_is_dp_o          (instr_is_dp[0]),
       .instr_is_ls_o          (instr_is_ls[0]),
       .instr_is_fn_o          (instr_is_fn[0])
      );

  ca53ifu_pf_dec_class
    u_ca53ifu_pf_dec1_class
      (// Inputs
       .instr_if3_i            (instr1_if3[39:0]),
       .instr_is_t16_if3_i     (instr_is_t16_if3[1]),
       // Outputs
       .instr_is_dp_o          (instr_is_dp[1]),
       .instr_is_ls_o          (instr_is_ls[1]),
       .instr_is_fn_o          (instr_is_fn[1])
      );


  // ------------------------------------------------------
  // Thumb-16 to Thumb-32 decoders
  // ------------------------------------------------------

  ca53ifu_pf_dec_t16t32
    u_ca53ifu_pf_dec0_t16t32
      (.instr_i            (instr0_if3[18:0]),
       .in_it_block_i      (in_it_block[0]),
       .instr_t16t32_o     (instr0_t16t32[39:0])
      );

  ca53ifu_pf_dec_t16t32
    u_ca53ifu_pf_dec1_t16t32
      (.instr_i            (instr1_if3[18:0]),
       .in_it_block_i      (in_it_block[1]),
       .instr_t16t32_o     (instr1_t16t32[39:0])
      );


  // ------------------------------------------------------
  // Branch decoders
  // ------------------------------------------------------

  ca53ifu_pf_dec_branch
    u_ca53ifu_pf_dec_branch
      (// Inputs
       .instr0_if3_i               (instr0_if3[39:0]),
       .instr1_if3_i               (instr1_if3[39:0]),
       .instr0_32_if3_i            (instr0_32_if3[39:0]),
       .instr1_32_if3_i            (instr1_32_if3[39:0]),
       .instr_valid_if3_i          (instr_valid_if3[1:0]),
       .cpsr_state_i               (cpsr_state[1:0]),
       .instr_is_a32_if3_i         (instr_is_a32_if3),
       .instr_is_a64_if3_i         (instr_is_a64_if3),
       .instr_is_thumb_if3_i       (instr_is_thumb_if3),
       .taken_i0_if3_i             (taken_i0_if3),
       .taken_i1_if3_i             (taken_i1_if3),
       .it_cc_0_i                  (cpsr_it_cond[3:1]),
       .it_cc_1_i                  (instr1_it_cond[3:1]),
       .it_block_i                 (in_it_block[1:0]),
       .instr_abt_if3_i            (instr_abt_if3[1:0]),
       .instr_pty_if3_i            (instr_pty_if3[1:0]),
       .instr_vcr_if3_i            (instr_vcr_if3[1:0]),
       .instr_hw_bkpt_if3_i        (instr_hw_bkpt_if3[1:0]),
       .instr_expt_catch_if3_i     (abuf_expt_catch_if3),
       .instr_rst_catch_if3_i      (abuf_rst_catch_if3),
       .branch_never_taken_i       (branch_never_taken),
       // Outputs
       .instr0_brn_offset_if3_o    (instr0_brn_offset_if3[27:1]),
       .instr0_brn_imm_if3_o       (instr0_brn_imm_if3),
       .instr0_brn_o               (instr0_brn),
       .instr1_brn_offset_if3_o    (instr1_brn_offset_if3[27:1]),
       .instr1_brn_imm_if3_o       (instr1_brn_imm_if3),
       .instr1_possible_o          (instr1_possible),
       .early_instr1_possible_o    (early_instr1_possible),
       .early_instr_taken_o        (early_instr_taken[1:0]),
       .brn_predicted_if3_o        (brn_predicted_if3[1:0]),
       .instr_dual_slot0_o         (instr_dual_slot0[1:0]),
       .instr_dual_slot1_o         (instr_dual_slot1[1:0]),
       .instr_brn_taken_if3_o      (instr_brn_taken_if3[1:0]),
       .instr_brn_btic_o           (instr_brn_btic[1:0]),
       .instr_brn_t_cond_if3_o     (instr_brn_t_cond_if3[1:0]),
       .instr_brn_t3_if3_o         (instr_brn_t3_if3[1:0]),
       .instr_brn_link_if3_o       (instr_brn_link_if3[1:0]),
       .instr_brn_exchange_a_if3_o (instr_brn_exchange_a_if3),
       .instr_brn_exchange_t_if3_o (instr_brn_exchange_t_if3[1:0]),
       .instr_it_if3_o             (instr_it_if3[1:0]),
       .instr_sw_bkpt_if3_o        (instr_sw_bkpt_if3),
       .s32_btac_if3_o             (s32_btac_if3[1:0]),
       .s32_return_if3_o           (s32_return_if3[1:0]),
       .t16_btac_if3_o             (t16_btac_if3[1:0]),
       .t16_return_if3_o           (t16_return_if3[1:0]),
       .spec_btac_if3_o            (spec_btac_if3[1:0])
      );


  // ------------------------------------------------------
  // Format instructions for DPU IQ
  // ------------------------------------------------------

  ca53ifu_pf_iq_format_i0
    u_ca53ifu_pf_instr0
      (// Inputs
       .instr_i               (instr0_if3[39:0]),
       .instr_valid_if3_i     (instr_valid_if3[0]),
       .instr_is_a32_i        (instr_is_a32_if3),
       .instr_is_a64_i        (instr_is_a64_if3),
       .instr_is_t16_i        (instr_is_t16_if3[0]),
       .instr_is_thumb_i      (instr_is_thumb_if3),
       .instr_is_dp_i         (instr_is_dp[0]),
       .instr_is_ls_i         (instr_is_ls[0]),
       .instr_is_fn_i         (instr_is_fn[0]),
       .instr_t16t32_i        (instr0_t16t32[39:0]),
       .instr_dual_slot0_i    (instr_dual_slot0[0]),
       .instr_dual_slot1_i    (instr_dual_slot1[0]),
       .taken_i               (instr_brn_taken_if3[0]),
       .instr_brn_t_cond_i    (instr_brn_t_cond_if3[0]),
       .instr_brn_t3_i        (instr_brn_t3_if3[0]),
       .cpsr_itd_i            (cpsr_itd),
       .it_undef_i            (it_undef[0]),
       .it_cc_i               (cpsr_it_cond),
       .it_block_i            (in_it_block[0]),
       .instr_abt_i           (instr_abt_if3[0]),
       .instr_pty_i           (instr_pty_if3[0]),
       .instr_hw_bkpt_i       (instr_hw_bkpt_if3[0]),
       .instr_vcr_i           (instr_vcr_if3[0]),
       .instr_expt_catch_i    (abuf_expt_catch_if3),
       .instr_rst_catch_i     (abuf_rst_catch_if3),
       // Outputs
       .iq_instr_if3_o        (iq_instr0_if3[47:0])
      );

  ca53ifu_pf_iq_format_i1
    u_ca53ifu_pf_instr1
      (// Inputs
       .instr_i               (instr1_if3[39:0]),
       .instr_valid_if3_i     (instr_valid_if3[1]),
       .instr_is_a32_i        (instr_is_a32_if3),
       .instr_is_a64_i        (instr_is_a64_if3),
       .instr_is_t16_i        (instr_is_t16_if3[1]),
       .instr_is_thumb_i      (instr_is_thumb_if3),
       .instr_is_dp_i         (instr_is_dp[1]),
       .instr_is_ls_i         (instr_is_ls[1]),
       .instr_is_fn_i         (instr_is_fn[1]),
       .instr_t16t32_i        (instr1_t16t32[39:0]),
       .instr_dual_slot0_i    (instr_dual_slot0[1]),
       .instr_dual_slot1_i    (instr_dual_slot1[1]),
       .taken_i               (instr_brn_taken_if3[1]),
       .instr_brn_t_cond_i    (instr_brn_t_cond_if3[1]),
       .instr_brn_t3_i        (instr_brn_t3_if3[1]),
       .cpsr_itd_i            (cpsr_itd),
       .it_undef_i            (instr1_it_undef),
       .it_cc_i               (instr1_it_cond[3:0]),
       .it_block_i            (in_it_block[1]),
       // Outputs
       .iq_instr_if3_o        (iq_instr1_if3[47:0])
      );

  ca53ifu_pf_iq_format_ret
    u_ca53ifu_pf_iq_format_ret
      (// Inputs
       .crs_hit_addr_i        (crs_hit_addr_if3[48:0]),
       .btac_hit_addr_i       (btac_hit_addr_if4[48:0]),
       .instr0_i              (instr0_if3[39:0]),
       .instr1_i              (instr1_if3[39:0]),
       .instr_is_t16_i        (instr_is_t16_if3),
       .instr_valid_if3_i     (instr_valid_if3),
       .instr_abt_if3_i       (instr_abt_if3[0]),
       .instr_vcr_if3_i       (instr_vcr_if3[0]),
       .instr_hw_bkpt_if3_i   (instr_hw_bkpt_if3[0]),
       .branch_never_taken_i  (branch_never_taken),
       .instr_is_a32_if3_i    (instr_is_a32_if3),
       .instr_is_a64_if3_i    (instr_is_a64_if3),
       .instr_is_thumb_if3_i  (instr_is_thumb_if3),
       .taken_i0_if3_i        (taken_i0_if3),
       .taken_i1_if3_i        (taken_i1_if3),
       .it_block_i            (in_it_block),
       .it_cc_0_i             (cpsr_it_cond[3:1]),
       .it_cc_1_i             (instr1_it_cond[3:1]),
       .s32_btac_if3_i        (s32_btac_if3),
       .s32_return_if3_i      (s32_return_if3),
       .t16_btac_if3_i        (t16_btac_if3),
       .t16_return_if3_i      (t16_return_if3),
       .return_hit_if4_i      (return_hit_if4),
       .aarch64_state_i       (aarch64_state),
       // Outputs
       .spec_crs_btac_valid_o (spec_crs_btac_valid),
       .iq_pred_addr_if4_o    (iq_pred_addr_if4),
       .brn_return_if3_o      (brn_return_if3),
       .brn_btac_if3_o        (brn_btac_if3)
      );


  // ------------------------------------------------------
  // Pre-decode checking and correction
  // ------------------------------------------------------

  // Checker for incomplete instructions that cross cache line boundaries
  //
  // This is to cope with unlikely possibility where a T32 instruction spans a cache line
  // boundary, the cache line in the B-Buffer has been evicted and the T32B portion modified
  // to be something that should be undefined while the T32A portion in the cache line in the
  // A-Buffer still reports the original predecode value in the top bits which is not undefined.
  //
  // Going back through the pre-decode process each time a T32 instruction spans a cache line
  // boundary would hurt performance too much so this pre-decode checker looks at the common
  // instructions and checks that they can be trusted.
  ca53ifu_pf_pdc_checker
    u_ca53ifu_pf_pdc_checker
      (.instr_pdc_i      ({abuf_if3[78:60],bbuf_if3[15:0]}),
       .instr_pdc_pass_o (instr_pdc_pass)
      );

  // The following pre-decode errors need to be detected by the checker:
  //
  // 1 - T32a T32a (should be: T32a T32b)
  //     - Typically occurs when crossing a cache line boundary, but can
  // also occur at the fetch line boundary if the processor branches into
  // the middle of a cache line and then has to fetch from the beginning
  // of the cache line to the critical first word.
  //
  // 2 - Incomplete instruction
  //     -Incomplete Sidebands whether appearing anywhere in the cache line or
  //      fetch line needs to be send back to PDC for correction through T32 PD.
  //      This is identified by an instruction having an incomplete Sideband.
  //
  // 3 - T16 (should be: T32a)
  //     - Typically occurs when transiting through a literal pool and the last
  // 16-bits of the literal pool are predecoded as a T32a and the first real 16-bits
  // afterwards are marked as a T32b when they should have been T32a.
  //
  // 4 - Cache-hit to LFB-hit
  //     - A T32 instruction that gets a cache hit in fetch buffer A with the T32a
  // portion followed by an LFB hit in fetch buffer B with the T32b portion could
  // be hiding some broken code (unlikely though) due to a cache clean operation
  // in the middle of fetching a line. It can only happen between a cache hit and an
  // LFB hit because between two LFB hits the Incomplete bit is set due to translation
  // in isolation
  //
  // 5 - Micro-TLB hit to Micro-TLB miss OR miss-too-miss (caused by flush)
  //     - If the micro-TLB has been flushed by either the DPU or TLB the PFU is not
  // forced.  If a T32a portion was fetched before the flush and is in fetch buffer A
  // and a T32b portion was fetched after the flush and is in fetch buffer B the
  // potential exists for broken code (e.g. the page mapping has changed).
  //       Furthermore, a micro-TLB miss followed by another micro-TLB miss must also
  // be taken into account (the unlikely event of two flushes close together)
  //
  // 6 - BTIC hazard
  //     - A T32 instruction that gets the A portion from the abuf via the BTIC can be
  // matched with a T32b portion from the bbuf which comes from the cache or the LFB.
  // If for any reason the line contains modified code which was not flushed it can
  // cause the PFU to pass corrupted code to the DPU
  //
  // 7 - WAY hazard
  //     - A T32 instruction that gets the A portion from the abuf via one way can be
  // matched with a T32b portion from the bbuf which comes from a different way. This
  // is only possible because due to CP15 hazard we can end up with two TAGs containing
  // the same information. While this is rare in order to hit this error we also need
  // one of the ways to be invalidated between two requests so that hits will come
  // from different ways.
  //
  // There are many different error patterns that can occur (e.g. T32a T32b T32a T32b
  // should have been decoded as T32b T32a T32b T32a), but fundamentally the
  // combinations above are the only ones we need to spot in order to do correction.
  //
  // If an error is detected in instr1, but instr0 is valid we allow instr0 to be passed
  // to the DPU then move instr1 into the instr0 slot and stall.  We don't send instr1
  // back through the pre-decode process early just in case the DPU IQ signals a stall
  // and we end up overwriting instr0 with the corrected
  //
  // 7 - Top Of Cache Line (TOCL) Hazard
  // - If a T32 instruction that crosses a cache line boundary and the pdc_checker
  //   cannot pass the instruction forward to DPU as the instruction does not have
  //   a valid sideband in trusted decider then such an error needs to be send back
  //   to pdc for T32 PD.


  // Detect errors in instruction-0
  assign instr0_two_t32a    = instr_is_thumb_if3 &  instr0_if3[19] &  instr0_if3[39];

  assign instr0_incomplete  = instr_is_thumb_if3 & (instr0_if3[19:13] == 7'b1111111);

  assign instr0_topcl       = instr_is_thumb_if3 & (instr0_if3[19]) & (abuf_va_if3[5:3] == 3'b111) & (ip_if3[2:1] == 2'b11) & ~instr_pdc_pass  & ~instr_been_corrected;

  assign instr0_not_t16     = instr_is_thumb_if3 & ~instr0_if3[19] & ((instr0_if3[15:13] == 3'b111) &
                                                                      (instr0_if3[12:11] != 2'b00)); // B (imm)

  // The following error dection will not only be set in the unlike event of a CP15 op between two sequential accesses
  // but also it is used to signal incomplete that are found initially between the b and c buffer which are not captured
  // by instr0_incomplete which only looks at incoming incompletes. Furthermore it will also be set an a subset of
  // instr0_utlb_flush cases since in those cases we do have two types of error
  assign instr0_cwf_hazard  = instr_is_thumb_if3 & abuf_if3[79] & ip_top_buf_if3 &
                              bbuf_cwf_hit_if3 & ~abuf_cwf_hit_if3 & ~instr_been_corrected;

  assign instr0_way_hazard  = instr_is_thumb_if3 & abuf_if3[79] & ip_top_buf_if3 &
                              (bbuf_way_if3[1:0] != abuf_way_if3[1:0]) & ~instr_pdc_pass & ~instr_been_corrected;

  assign instr0_utlb_flush  = instr_is_thumb_if3 & abuf_if3[79] & ip_top_buf_if3 &
                              bbuf_utlb_flushed_if3 & ~instr_been_corrected;

  assign instr0_btic_hazard = instr_is_thumb_if3 & abuf_if3[79] & ip_top_buf_if3 &
                              abuf_btic_if3 & ~bbuf_btic_if3 & ~instr_been_corrected;

  assign instr0_opcode_err  = instr0_two_t32a | instr0_incomplete | instr0_btic_hazard |
                              instr0_not_t16  | instr0_cwf_hazard | instr0_utlb_flush  |
                              instr0_way_hazard | instr0_topcl;

  assign instr0_pdec_err    = (instr_valid_if3[0] & ~instr_abt_if3[0] & ~instr_vcr_if3[0] & ~instr_hw_bkpt_if3[0] &
                               ~instr_sw_bkpt_if3 & instr0_opcode_err);

  // Detect errors in instruction-1
  assign instr1_two_t32a    = instr_is_thumb_if3 &  instr1_if3[19] &  instr1_if3[39];

  assign instr1_incomplete  = instr_is_thumb_if3 & (instr1_if3[19:13] == 7'b1111111);

  assign instr1_topcl       = instr_is_thumb_if3 & (instr1_if3[19]) & (abuf_va_if3[5:3] == 3'b111) & ((ip_if3[2:1] + instr0_size[1:0]) == 2'b11) & ~instr_pdc_pass;

  assign instr1_not_t16     = instr_is_thumb_if3 & ~instr1_if3[19] & ((instr1_if3[15:13] == 3'b111) &
                                                                      (instr1_if3[12:11] != 2'b00)); // B (imm)

  // The following error dection will not only be set in the unlike event of a CP15 op between two sequential accesses
  // but also it is used to signal incomplete that are found initially between the b and c buffer which are not captured
  // by instr1_incomplete which only looks at incoming incompletes. Furthermore it will also be set an a subset of
  // instr1_utlb_flush cases since in those cases we do have two types of error
  assign instr1_cwf_hazard  = instr_is_thumb_if3 & abuf_if3[79] & (ip_push_one[1:0] == 2'b11) &
                              bbuf_cwf_hit_if3 & ~abuf_cwf_hit_if3;

  assign instr1_way_hazard  = instr_is_thumb_if3 & abuf_if3[79] & (ip_push_one[1:0] == 2'b11) &
                              (bbuf_way_if3[1:0] != abuf_way_if3[1:0]) & ~instr_pdc_pass;

  assign instr1_utlb_flush  = instr_is_thumb_if3 & abuf_if3[79] & (ip_push_one[1:0] == 2'b11) &
                              bbuf_utlb_flushed_if3;

  assign instr1_btic_hazard = instr_is_thumb_if3 & abuf_if3[79] & (ip_push_one[1:0] == 2'b11) &
                              abuf_btic_if3 & ~bbuf_btic_if3;

  assign instr1_opcode_err  = instr1_two_t32a | instr1_incomplete | instr1_btic_hazard |
                              instr1_not_t16  | instr1_cwf_hazard | instr1_utlb_flush  |
                              instr1_way_hazard | instr1_topcl;

  assign instr1_pdec_err    = (instr_valid_if3[1] & instr1_opcode_err);

  // The predecode request from the PFU to the ICU needs to be subtly different from the instr0_pdec_err
  // signal.  If the pre-decode error is caused by a 'not_t16' and that instruction is at the top of the
  // buffer _and_ the 'b' buffer is empty we must wait until the 'b' buffer is valid so that a fully formed
  // instruction can be sent back through the pre-decode process.
  assign pdc_req_if3 = (instr_valid_if3[0] & ~instr_abt_if3[0] & ~instr_vcr_if3[0] & ~instr_hw_bkpt_if3[0] & ~instr_sw_bkpt_if3 &
                        (instr0_two_t32a | (instr0_not_t16 & ((ip_if3[2:1] != 2'b11) | bvalid_if3)) | instr0_incomplete | instr0_btic_hazard | instr0_cwf_hazard | instr0_way_hazard | instr0_utlb_flush | instr0_topcl));

  // Recreate instruction for the pre-decoder.
  assign pdc_data_if3 = (({29{(instr0_incomplete | instr0_btic_hazard | instr0_cwf_hazard | instr0_way_hazard | instr0_utlb_flush | instr0_topcl) &
                              ~instr0_two_t32a}} & {instr0_if3[12: 0], instr0_if3[35:20]}) |
                         ({29{ instr0_two_t32a}} & {instr0_if3[12: 0], 3'b111, instr0_if3[32:20]}) |
                         ({29{ instr0_not_t16}}  & {instr0_if3[12: 0], (instr0_if3[39] ? {3'b111, instr0_if3[32:20]} : instr0_if3[35:20])}));

  // Ensure that MMU on/off is stable.  If the MMU has been turned on/off (which results in a micro-TLB
  // flush), we want to suppress the 'way' indicators on predecode errors since there could be a new
  // cache line with a different physical address at the same location as the pre-decode error which
  // came from an old cache line and old physical address.
  // We want to do the same if we have a cwf type of error since we do not want to correct the new data
  // just placed by the LFB with old data from the cache. This can happen on a uTLB flush or in a CP15
  // inval op, in either case the fetch_q is not flushed.
  assign fetch_q_stable_if3 = ~(ip_top_buf_if3 & bvalid_if3 & (bbuf_utlb_flushed_if3 | (bbuf_cwf_hit_if3 & ~abuf_cwf_hit_if3)));

  // Indicate the cache way(s) in which the pre-decode error occured, but factor in suppression
  // signal generated above.
  assign pdc_way_0_if3 = {2{fetch_q_stable_if3}} &                                                                   abuf_way_if3[1:0] & {2{~abuf_pdc_hazard_if3}};
  assign pdc_way_1_if3 = {2{fetch_q_stable_if3}} & (ip_top_buf_if3 ? bbuf_way_if3[1:0] & {2{~bbuf_pdc_hazard_if3}} : abuf_way_if3[1:0] & {2{~abuf_pdc_hazard_if3}});

  // If a cross-buffer instruction has been corrected then ensure that the predecode checker
  // doesn't put it back through the process.
  assign nxt_instr_been_corrected = icb_pdc_valid_if2_i & ~pfb_push[0] & ~dpu_pfu_force;

  assign instr_been_corrected_en = (icb_pdc_valid_if2_i & pdc_req_if3) | pfb_push[0] | dpu_pfu_force;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      instr_been_corrected <= 1'b0;
    else if (instr_been_corrected_en)
      instr_been_corrected <= nxt_instr_been_corrected;


  // ------------------------------------------------------
  // Branch predictor
  // ------------------------------------------------------

  // DPU -> Branch Predictor
  assign cm_flush_no_br = dpu_fe_valid_ret_i | (dpu_fe_valid_wr_i & ~dpu_pred_br_wr_i);

  ca53ifu_pf_bpd
    u_ca53ifu_pf_bpd
      (// Inputs
       .clk                      (clk),
       .reset_n                  (reset_n),
       .DFTSE                    (DFTSE),
       .dpu_pred_br_wr_i         (dpu_pred_br_wr_i),
       .cm_branch_i              (cm_branch),
       .cm_taken_i               (cm_taken),
       .cm_mispredicted_i        (cm_mispredicted),
       .cm_flush_no_br_i         (cm_flush_no_br),
       .instr_valid_if3_i        (instr_valid_if3[1:0]),
       .valid_if2_i              (valid_if2),
       .avalid_if3_i             (avalid_if3),
       .next64_if3_i             (next64_if3),
       .btic_hit_if3_i           (btic_hit_if3),
       .nxt_ip_if3_i             (nxt_ip_if3[2:1]),
       .va_if2_i                 (va_if2[12:3]),
       .abuf_va_if3_i            (abuf_va_if3[12:3]),
       .abuf_va_plus1_if3_i      (abuf_va_plus1_if3[12:3]),
       .abuf_va_plus2_if3_i      (abuf_va_plus2_if3[12:3]),
       .btic_abuf_va_if3_i       (btic_abuf_va_if3[11:3]),
       .btic_bbuf_va_if3_i       (btic_bbuf_va_if3[11:3]),
       .dpu_br_addr_ex2_i        (dpu_br_addr_ex2_i[12:3]),
       .dpu_pred_br_ex2_i        (dpu_pred_br_ex2_i),
       .brn_predicted_if3_i      (brn_predicted_if3[1:0]),
       .pfb_push_i               (pfb_push[1:0]),
       .instr_abt_if3_i          (instr_abt_if3[0]),
       .instr0_opcode_err_i      (instr0_opcode_err),
       .instr1_possible_i        (instr1_possible),
       .instr_is_thumb_bpd_if3_i (instr_is_thumb_bpd_if3),
       .instr0_pdec_err_i        (instr0_pdec_err),
       .abuf_mid_poss_t32_i      (abuf_if3[59]),
       .dbg_valid_if2_i          (dbg_valid_if2),
       .dpu_iq_full_i            (dpu_iq_full_i),
       // Outputs
       .taken_i0_if3_o           (taken_i0_if3),
       .taken_i1_if3_o           (taken_i1_if3)
      );

  // ------------------------------------------------------
  // Call Return Stack (CRS)
  // ------------------------------------------------------

  // Call/Return stack speculative push/pop signals
  assign crs_spec_push = ~dpu_pfu_force & ~dpu_iq_full_i & ~instr0_pdec_err & ((spec_crs_btac_valid[0] & instr_brn_link_if3[0]) |
                                                                               (spec_crs_btac_valid[1] & instr_brn_link_if3[1] & ~instr1_pdec_err & instr1_possible));
  assign crs_spec_pop  = return_hit_if4 & ~branch_never_taken;
  assign crs_spec_addr = instr_brn_link_if3[0] ? {va_push_one_if3[48:1], cpsr_state[0]} :
                                                 {va_push_two_if3[48:1], cpsr_state[0]};

  ca53ifu_pf_crs
    u_ca53ifu_pf_crs
      (.clk                 (clk),
       .reset_n             (reset_n),
       .dpu_pf_force_i      (dpu_pfu_force),
       .crs_disable_i       (crs_disable),
       .crs_sp_push_i       (crs_spec_push),
       .crs_sp_pop_i        (crs_spec_pop),
       .crs_cm_push_i       (crs_commited_push),
       .crs_cm_pop_i        (crs_commited_pop),
       .crs_addr_i          (crs_spec_addr[48:0]),
       .crs_hit_addr_if3_o  (crs_hit_addr_if3[48:0])
     );

  // Indicate that a return packet will be pushed on the following cycle
  assign nxt_return_hit_if4 = (~dpu_pfu_force &
                               ((brn_return_if3[0] & ~dpu_iq_full_i & ~instr0_pdec_err) |
                                (brn_return_if3[1] & ~dpu_iq_full_i & ~instr0_opcode_err & ~instr1_opcode_err & instr1_possible)));

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      return_hit_if4 <= 1'b0;
    else
      return_hit_if4 <= nxt_return_hit_if4;

  // ------------------------------------------------------
  // Branch Target Address Cache (BTAC)
  // ------------------------------------------------------

  ca53ifu_pf_btac
    u_ca53ifu_pf_btac
      (// Inputs
       .clk                       (clk),
       .reset_n                   (reset_n),
       .btac_disable_i            (btac_disable),
       .DFTSE                     (DFTSE),
       .DFTRAMHOLD                (DFTRAMHOLD),
       .instr_valid_if3_i         (instr_valid_if3[1:0]),
       .early_instr1_possible_i   (early_instr1_possible),
       .abuf_if3_i                (abuf_if3[79:0]),
       .spec_btac_if3_i           (spec_btac_if3[1:0]),
       .brn_btac_if3_i            (brn_btac_if3[1:0]),
       .dpu_btac_ret_i            (dpu_btac_ret_i),
       .pfb_push_i                (pfb_push[1:0]),
       .dpu_pf_force_i            (dpu_pfu_force),
       .dpu_fe_valid_ret_i        (dpu_fe_valid_ret_i),
       .dpu_fe_valid_wr_i         (dpu_fe_valid_wr_i),
       .dpu_iq_full_i             (dpu_iq_full_i),
       .va_if1_i                  (va_if1[48:1]),
       .abuf_va_if3_i             (abuf_va_if3[17:3]),
       .bbuf_va_if3_i             (bbuf_va_if3[17:3]),
       .instr_is_thumb_if3_i      (instr_is_thumb_if3),
       .ip_if3_i                  (ip_if3[2:1]),
       .cpsr_state_i              (cpsr_state[0]),
       .btac_stg0_ram_rdata_i     (btac_stg0_ram_rdata_i[49:0]),
       .btac_stg1_ram_rdata_i     (btac_stg1_ram_rdata_i[58:0]),
       .ctl_mbist_req_i           (ctl_mbist_req_i),
       .ctl_mbist_btac_en_mb4_i   (ctl_mbist_btac_en_mb4_i[1:0]),
       .ctl_mbist_btac_addr_mb4_i (ctl_mbist_btac_addr_mb4_i[6:0]),
       .ctl_mbist_btac_wr_mb4_i   (ctl_mbist_btac_wr_mb4_i),
       .ctl_mbist_btac_wdata_mb4_i(ctl_mbist_btac_wdata_mb4_i[58:0]),
       // Outputs
       .btac_stg0_ram_en_o        (btac_stg0_ram_en_o),
       .btac_stg0_ram_wr_o        (btac_stg0_ram_wr_o),
       .btac_stg0_ram_wdata_o     (btac_stg0_ram_wdata_o[49:0]),
       .btac_stg0_ram_addr_o      (btac_stg0_ram_addr_o[6:0]),
       .btac_stg1_ram_en_o        (btac_stg1_ram_en_o),
       .btac_stg1_ram_wr_o        (btac_stg1_ram_wr_o),
       .btac_stg1_ram_wdata_o     (btac_stg1_ram_wdata_o[58:0]),
       .btac_stg1_ram_addr_o      (btac_stg1_ram_addr_o[6:0]),
       .brn_btac_pushed_if3_o     (brn_btac_pushed_if3),
       .btac_invalidate_o         (btac_invalidate),
       .btac_lookup_stall_if4_o   (btac_lookup_stall_if4),
       .btac_skew_loopkup_if4_o   (btac_skew_loopkup_if4),
       .btac_hit_addr_if4_o       (btac_hit_addr_if4[48:0]),
       .btac_hit_if4_o            (btac_hit_if4)
       );

  // ------------------------------------------------------
  // Branch Target Instruction Cache (BTIC)
  // ------------------------------------------------------

  ca53ifu_pf_btic
    u_ca53ifu_pf_btic
      (// Inputs
       .clk                     (clk),
       .reset_n                 (reset_n),
       .btic_disable_i          (btic_disable),
       .DFTSE                   (DFTSE),
       .dpu_iq_full_i           (dpu_iq_full_i),
       .dpu_iq_part_full_i      (dpu_iq_part_full_i),
       .dpu_pred_br_wr_i        (dpu_pred_br_wr_i),
       .dpu_fe_valid_ret_i      (dpu_fe_valid_ret_i),
       .abuf_va_if3_i           ({abuf_va_if3[48:3], ip_if3[2:1]}),
       .bbuf_va_if3_i           (bbuf_va_if3[48:3]),
       .va_instr1_if3_i         (va_push_one_if3[48:1]),
       .valid_if2_i             (valid_if2),
       .avalid_if3_i            (avalid_if3),
       .bvalid_if3_i            (bvalid_if3),
       .abuf_state_if3_i        (abuf_state_if3),
       .abuf_bkpt_if3_i         (abuf_bkpt_if3[3:0]),
       .bbuf_bkpt_if3_i         (bbuf_bkpt_if3[3:0]),
       .abuf_vcr_if3_i          (abuf_vcr_if3[1:0]),
       .bbuf_vcr_if3_i          (bbuf_vcr_if3[1:0]),
       .abuf_abt_if3_i          (abuf_abt_if3),
       .bbuf_abt_if3_i          (bbuf_abt_if3),
       .instr_sw_bkpt_if3_i     (instr_sw_bkpt_if3),
       .instr_valid_if3_i       (instr_valid_if3[1:0]),
       .instr_is_a32_if3_i      (instr_is_a32_if3),
       .instr_is_a64_if3_i      (instr_is_a64_if3),
       .instr_is_thumb_if3_i    (instr_is_thumb_if3),
       .instr_pty_if3_i         (instr_pty_if3[1:0]),
       .abuf_if3_i              (abuf_if3[79:0]),
       .bbuf_if3_i              (bbuf_if3[79:0]),
       .icb_hit_if2_i           (icb_hit_if2_i),
       .icb_lfb_hit_if2_i       (icb_lfb_hit_if2_i),
       .tlb_hit_if2_i           (tlb_hit_if2),
       .early_instr_taken_i     (early_instr_taken[1:0]),
       .instr_brn_btic_i        (instr_brn_btic[1:0]),
       .instr0_brn_i            (instr0_brn),
       .instr0_opcode_err_i     (instr0_opcode_err),
       .instr1_opcode_err_i     (instr1_opcode_err),
       .instr1_possible_i       (instr1_possible),
       .spec_instr0_t32_i       (instr0_if3[19]),
       .dpu_pfu_force_i         (dpu_pfu_force),
       .force_if0_i             (force_if0),
       .icb_flush_btic_i        (icb_flush_btic_i),
       .icb_cacheable_if2_i     (icb_cacheable_if2_i),
       .dpu_flush_i_utlb_i      (dpu_flush_i_utlb_i),
       .tlb_i_utlb_flush_i      (tlb_i_utlb_flush_i),
       .hyp_mode_if1_i          (hyp_mode_if1),
       .hyp_mode_if2_i          (hyp_mode_if2),
       .in_debug_or_wfx_i       (in_debug_or_wfx),
       // Outputs
       .btic_hit_if3_o          (btic_hit_if3),
       .btic_abuf_if3_o         (btic_abuf_if3[79:0]),
       .btic_bbuf_if3_o         (btic_bbuf_if3[79:0]),
       .btic_bbuf_valid_if3_o   (btic_bbuf_valid_if3),
       .btic_abuf_va_if3_o      (btic_abuf_va_if3[48:1]),
       .btic_bbuf_va_if3_o      (btic_bbuf_va_if3[48:3]),
       .btic_cbuf_va_if3_o      (btic_cbuf_va_if3[12:3]),
       .btic_target_va_if2_o    (btic_target_va_if2[48:3])
      );

  // ------------------------------------------------------
  // Fetch throttle predictor
  // ------------------------------------------------------

  ca53ifu_pf_throttle
    u_ca53ifu_pf_throttle
      (// Inputs
       .clk                       (clk),
       .reset_n                   (reset_n),
       .DFTSE                     (DFTSE),
       .throttle_enable_nxt_cyc_i (throttle_enable_nxt_cyc),
       .dpu_iq_full_i             (dpu_iq_full_i),
       .dpu_pfu_force_i           (dpu_pfu_force),
       .ip_if3_i                  (ip_if3[2:1]),
       .instr0_brn_i              (instr0_brn),
       .force_if0_i               (force_if0),
       .force_if1_i               (force_if1),
       .force_if1_pf_i            (force_if1_pf),
       .force_if3_i               (force_if3),
       .pfb_valid_if1_i           (pfb_valid_if1),
       .va_if1_i                  (va_if1[12:2]),
       .valid_if2_i               (valid_if2),
       .avalid_if3_i              (avalid_if3),
       .bvalid_if3_i              (bvalid_if3),
       .cvalid_if3_i              (cvalid_if3),
       .next64_if3_i              (next64_if3),
       .iutlb_miss_req_i          (iutlb_miss_req),
       // Outputs
       .throttle_if1_o            (throttle_if1),
       .ifu_evnt_throttle_o       (ifu_evnt_throttle_o)
      );

  // ------------------------------------------------------
  // AGU Operand generation
  // ------------------------------------------------------
  // We need to recognize when the adder is for aarch64 or for aarch32 because the full 64 bit adder
  // is only valid for aarch64 while for aarch32 only the bottom 32bits are used.
  // The following legs need updating:
  // o During a force the b_operand could include the top bits set in aarch32, the a_operand is correctly set
  // o During a branch immediate again we need to look after the b_operand
  // o We also need to look after the crs because it could push in aarch64 with some top bits set and pop in aarch32. This
  //   is legal but an unlike scenario in real code
  assign aarch64_state = cpsr_state == 2'b10;

  // Operands for the AGU are prepared in if0


  // Operand generation for dpu_force
  assign agu_a_operand_frc[63:0] = dpu_fe_valid_ret_i ? dpu_fe_addr_opa_ret_i[63:0] :
                                                        {{16{dpu_fe_addr_opa_wr_i[48]}}, dpu_fe_addr_opa_wr_i[47:1], 1'b0};
  assign agu_b_operand_frc[63:0] = dpu_fe_valid_ret_i ? { {32{(dpu_fe_isa_ret_i == 2'b10) & dpu_fe_addr_opb_ret_i[17]}}, {14{dpu_fe_addr_opb_ret_i[17]}}, dpu_fe_addr_opb_ret_i[17:1], 1'b0} :
                                                        { {32{(dpu_fe_isa_wr_i == 2'b10)  & dpu_fe_addr_opb_wr_i[27] }}, { 4{dpu_fe_addr_opb_wr_i[27] }}, dpu_fe_addr_opb_wr_i[27:1] , 1'b0};

  // Operand generation for instruction-0 branch immediate
  // For the a operand, to obtain the PC from the fetch address we +4 in Thumb state and +8 in ARM state.
  assign agu_a_operand_imm0[63:0] = {({{16{abuf_va_if3[48]}}, abuf_va_if3[47:3], ip_if3[2]} + {(~cpsr_state[0] & ~cpsr_state[1]), (cpsr_state[0] & ~cpsr_state[1])}),
                                     (instr_brn_exchange_t_if3[0] ? 1'b0 : ip_if3[1]),
                                     1'b0};
  assign agu_b_operand_imm0[63:0] = { {32{aarch64_state & instr0_brn_offset_if3[27]}}, {4{instr0_brn_offset_if3[27]}}, instr0_brn_offset_if3[27:1], 1'b0};

  // Operand generation for instruction-1 branch immediate
  // For the a operand, to obtain the PC from the fetch address we +4 in Thumb state and +8 in A32 state
  assign agu_a_operand_imm1[63:0] = {({{16{va_push_one_if3[48]}}, va_push_one_if3[47:2]} + {(~cpsr_state[0] & ~cpsr_state[1]), (cpsr_state[0] & ~cpsr_state[1])}),
                                     (instr_brn_exchange_t_if3[1] ? 1'b0 : va_push_one_if3[1]),
                                     1'b0};
  assign agu_b_operand_imm1[63:0] = { {32{aarch64_state & instr1_brn_offset_if3[27]}}, {4{instr1_brn_offset_if3[27]}}, instr1_brn_offset_if3[27:1], 1'b0};

  // Operand generation for sequential fetch
  assign agu_a_operand_seq[63:0] = {{16{va_if1[48]}}, va_if1[47:3], 3'b000};
  assign agu_b_operand_seq[63:0] = {{60{      1'b0}},         1'b1, 3'b000};

  // Generate AGU operand selects
  assign agu_a_operand_sel = {dpu_pfu_force,
                              btac_hit_if4,
                              ((brn_return_if3[0] & ~dpu_iq_full_i & ~instr0_opcode_err) |
                               (brn_return_if3[1] & ~dpu_iq_full_i & ~instr0_opcode_err & instr1_possible & ~instr1_opcode_err)),
                              btic_hit_if3,
                              (instr0_brn_imm_if3 & ~dpu_iq_full_i & ~instr0_opcode_err),
                              (instr1_brn_imm_if3 & ~dpu_iq_full_i & ~instr0_opcode_err & ~dpu_pfu_force & instr1_possible & ~instr1_opcode_err)};

  assign agu_b_operand_sel = {dpu_pfu_force,
                              btac_hit_if4,
                              ((brn_return_if3[0] & ~btic_hit_if3 & ~dpu_iq_full_i & ~instr0_opcode_err) |
                               (brn_return_if3[1] & ~btic_hit_if3 & ~dpu_iq_full_i & ~instr0_opcode_err & instr1_possible & ~instr1_opcode_err)),
                              (instr0_brn_imm_if3 & ~btic_hit_if3 & ~dpu_iq_full_i & ~instr0_opcode_err),
                              (instr1_brn_imm_if3 & ~btic_hit_if3 & ~dpu_iq_full_i & ~instr0_opcode_err & instr1_possible & ~instr1_opcode_err)};

  // AGU operand generation
  always @*
    case (agu_a_operand_sel[5:0])
      // always correct
      `ca53ifu_sel_1xxxxx : agu_a_operand_if0 = agu_a_operand_frc[63:0];
      // a crs or a btac could push aarch64 and pop aarch32
      `ca53ifu_sel_01xxxx : agu_a_operand_if0 = {{16{aarch64_state & btac_hit_addr_if4[48]}}, ({16{aarch64_state}} & btac_hit_addr_if4[47:32]), btac_hit_addr_if4[31:1], 1'b0};
      `ca53ifu_sel_001xxx : agu_a_operand_if0 = {{16{aarch64_state & crs_hit_addr_if3[48]}}, ({16{aarch64_state}} & crs_hit_addr_if3[47:32]), crs_hit_addr_if3[31:1], 1'b0};
      // a btic can store bit 32 set because of wrapping around, we must clear it after words
      `ca53ifu_sel_0001xx : agu_a_operand_if0 = {{16{aarch64_state & btic_target_va_if2[48]}}, ({16{aarch64_state}} & btic_target_va_if2[47:32]), btic_target_va_if2[31:3], 3'b000};
      // could overflow during wrap around, cannot doing during calculation because the adder could overflow
      `ca53ifu_sel_00001x : agu_a_operand_if0 = {({32{aarch64_state}} & agu_a_operand_imm0[63:32]),agu_a_operand_imm0[31:0]};
      `ca53ifu_sel_000001 : agu_a_operand_if0 = {({32{aarch64_state}} & agu_a_operand_imm1[63:32]),agu_a_operand_imm1[31:0]};
      // could overflow during wrap around but only bit 32 which is dealt in the A+B=K logic in if1, no changes needed
      `ca53ifu_sel_000000 : agu_a_operand_if0 = agu_a_operand_seq[63:0];
      default             : agu_a_operand_if0 = {64{1'bx}};
    endcase

  always @*
    case (agu_b_operand_sel[4:0])
      // correction for aarch32 done during calculation
      `ca53ifu_sel_1xxxx : agu_b_operand_if0 = agu_b_operand_frc[63:0];
      // not used
      `ca53ifu_sel_01xxx : agu_b_operand_if0 = {64{1'b0}};
      `ca53ifu_sel_001xx : agu_b_operand_if0 = {64{1'b0}};
      // correction for aarch32 done during calculation
      `ca53ifu_sel_0001x : agu_b_operand_if0 = agu_b_operand_imm0[63:0];
      `ca53ifu_sel_00001 : agu_b_operand_if0 = agu_b_operand_imm1[63:0];
      // always correct
      `ca53ifu_sel_00000 : agu_b_operand_if0 = agu_b_operand_seq[63:0];
      default            : agu_b_operand_if0 = {64{1'bx}};
    endcase

  // ------------------------------------------------------
  // AGU
  // ------------------------------------------------------

  // Create interleave points for 4K and 1M carry-outs to do A+B=K in the micro-TLB entries
  assign agu_a_operand_adder[66:0] = {agu_a_operand_if1[63:32], 1'b0,          agu_a_operand_if1[31:20], 1'b0, agu_a_operand_if1[19:12], 1'b0, agu_a_operand_if1[11:0]};
  assign agu_b_operand_adder[66:0] = {agu_b_operand_if1[63:32], aarch64_state, agu_b_operand_if1[31:20], 1'b1, agu_b_operand_if1[19:12], 1'b1, agu_b_operand_if1[11:0]};

  // Address calculation for the instruction caches is done in if1 in a single 34-bit AGU
  assign {agu_result_adder[63:32],
          ncarry_out_64,
          agu_result_adder[31:20],
          ncarry_out_1m,
          agu_result_adder[19:12],
          ncarry_out_4k,
          agu_result_adder[11: 0]} = agu_a_operand_adder[66:0] + agu_b_operand_adder[66:0];

  assign carry_out_1m = ~ncarry_out_1m;
  assign carry_out_4k = ~ncarry_out_4k;

  // Address calculation for the instruction caches is done in if1 in a single 32-bit AGU.
  assign va_if1[63:0] = {agu_result_adder[63:20], agu_result_adder[19:12], agu_result_adder[11: 0]};

  // ------------------------------------------------------
  // Virtual address based abort calculations
  // ------------------------------------------------------

  // An unaligned address in if1 sets kill_if1.  The aborting request will be
  // sent to the ICB in if1 but killed in if2.  This type of abort also prevents
  // any TLB lookups.
  assign pc_unalign_abort = (~cpsr_state[0] & (va_if1[1] | va_if1[0])) |
                            (~cpsr_state[1] & cpsr_state[0] & va_if1[0]);

  // Indicate a translation abort when the VA is out of range.
  //
  //   TTBR0 range: 0x00000000_00000000 - 0x0000FFFF_FFFFFFFF (EL0/EL1/EL2/EL3)
  //   TTBR1 range: 0xFFFF0000_00000000 - 0xFFFFFFFF_FFFFFFFF (EL0/EL1 only)
  //
  // The TBI0/1 (top byte ignored) bits tell us whether the top byte of the
  // address should be used to address match in the TTBR0/1 regions. This is
  // only applicable when the MMU is on.
  always @*
    case ({exception_level_3, exception_level_2, exception_level_1, exception_level_0})
      `CA53_ONE_HOT_EL0,
      `CA53_ONE_HOT_EL1 : out_of_range_abort = (va_if1[48] ? ((~&va_if1[55:49]) | (~tlb_tcr_el1_tbi_i[1] & (~&va_if1[63:56]))) :
                                                              ((|va_if1[55:49]) | (~tlb_tcr_el1_tbi_i[0] & ( |va_if1[63:56])))) & (cpsr_state == 2'b10);
      `CA53_ONE_HOT_EL2 : out_of_range_abort = ((|va_if1[55:48]) | (~tlb_tcr_el2_tbi0_i & (|va_if1[63:56]))) & (cpsr_state == 2'b10);
      `CA53_ONE_HOT_EL3 : out_of_range_abort = ((|va_if1[55:48]) | (~tlb_tcr_el3_tbi0_i & (|va_if1[63:56]))) & (cpsr_state == 2'b10);
      default           : out_of_range_abort = 1'bx;
    endcase

  // Qualify the PC and out-of-range aborts with valid & force so that abort flags are cleared appropriately
  assign pc_unalign_abort_if1           = pfb_valid_if1 & ~force_if0 & pc_unalign_abort;
  assign out_of_range_abort_mmu_on_if1  = pfb_valid_if1 & ~force_if0 & out_of_range_abort &  dpu_mmu_on_i;
  assign out_of_range_abort_mmu_off_if1 = pfb_valid_if1 & ~force_if0 & out_of_range_abort & ~dpu_mmu_on_i;

  // ------------------------------------------------------
  // Micro TLB
  // ------------------------------------------------------

  // The instruction micro TLB resides in the if1 stage after the AGU and supports
  // both 4K and 1M page sizes.
  //
  // If a uTLB miss occurs the request stalls in if1.  Unlike the data side uTLB,
  // if a uTLB miss occurs the address from the main TLB does not get muxed in late,
  // but is written into the micro-TLB entry.  This approach is taken because timing
  // on the if1 stall signal is so tight due to it being used to suppress the PFU
  // valid signal that the instruction cache RAMs use.
  ca53ifu_pf_utlb
    u_ca53ifu_pf_utlb
      (// Inputs
       .clk                       (clk),
       .reset_n                   (reset_n),
       .DFTSE                     (DFTSE),
       .agu_a_operand_if1_i       (agu_a_operand_if1[48:12]),
       .agu_b_operand_if1_i       (agu_b_operand_if1[48:12]),
       .va_if1_i                  (va_if1[63:12]),
       .carry_out_4k_i            (carry_out_4k),
       .carry_out_1m_i            (carry_out_1m),
       .aarch64_state_i           (aarch64_state),
       .dpu_mmu_on_i              (dpu_mmu_on_i),
       .dpu_flush_i_utlb_i        (dpu_flush_i_utlb_i),
       .dpu_dacr_i                (dpu_dacr_i),
       .sif_only_i                (sif_only),
       .ns_state_i                (ns_state),
       .default_cacheable_i       (default_cacheable),
       .exception_level_0_i       (exception_level_0),
       .exception_level_2_i       (exception_level_2),
       .exception_level_3_i       (exception_level_3),
       .pfb_aarch64_at_el3_i      (aarch64_at_el3),
       .tlb_i_utlb_data_i         (tlb_i_utlb_data_i[96:0]),
       .tlb_i_utlb_enable_i       (tlb_i_utlb_enable_i),
       .tlb_i_utlb_might_enable_i (tlb_i_utlb_might_enable_i),
       .tlb_i_utlb_valid_i        (tlb_i_utlb_valid_i),
       .tlb_i_utlb_flush_i        (tlb_i_utlb_flush_i),
       .tlb_i_utlb_lpae_i         (tlb_i_utlb_lpae_i),
       .tlb_lpae_mode_i           (tlb_lpae_mode_i),
       .force_if0_i               (force_if0),
       .abort_inbound_i           (abort_inbound),
       .stop_pfb_i                (stop_pfb),
       .pfb_valid_if1_i           (pfb_valid_if1),
       // Outputs
       .tlb_hit_if1_o             (tlb_hit_if1),
       .main_tlb_abort_if1_o      (main_tlb_abort_if1),
       .micro_tlb_abort_if1_o     (micro_tlb_abort_if1),
       .tlb_abort_type_if1_o      (tlb_abort_type_if1[6:0]),
       .stage2_abort_if1_o        (stage2_abort_if1),
       .lpae_abort_if1_o          (lpae_abort_if1),
       .pa_if1_o                  (pa_if1[39:12]),
       .attributes_if1_o          (attributes_if1[7:0]),
       .ns_dsc_if1_o              (ns_dsc_if1),
       .abort_ipa_if1_o           (abort_ipa_if1[27:0])
      );

  // If there is a micro-TLB miss then assert the iutlb_miss_req signal that goes to
  // the main TLB and keep it asserted until the correct page is returned or force
  // or an abort/stop condition is signalled
  assign nxt_iutlb_miss_req = (((pfb_valid_if1 & ~tlb_hit_if1 & ~pc_unalign_abort & ~out_of_range_abort) | iutlb_miss_req) & // Set condition
                               ~(abort_if2 | nxt_stop_pfb_if3 | force_if0 | tlb_i_utlb_enable_i));                           // Clear condition

  assign iutlb_miss_req_en = ~stall_if2;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      iutlb_miss_req <= 1'b0;
    else if (iutlb_miss_req_en)
      iutlb_miss_req <= nxt_iutlb_miss_req;

  // If the micro-TLB has been flushed we need to keep track of it for the pre-decode
  // error detection logic
  assign utlb_flushed_if0 = dpu_flush_i_utlb_i | tlb_i_utlb_flush_i | (utlb_flushed_if1 & stall_if1);

  // ------------------------------------------------------
  // Primary outputs
  // ------------------------------------------------------

  assign ifu_instr0_if3_o           = iq_instr0_if3[47:0];
  assign ifu_instr1_if3_o           = iq_instr1_if3[47:0];
  assign ifu_instr_valid_if3_o      = pfb_push[1:0];
  assign ifu_early_two_valid_if3_o  = pfb_early_two_valid;
  assign ifu_pred_addr_if4_o        = iq_pred_addr_if4[48:0];
  assign ifu_pred_addr_valid_if4_o  = btac_hit_if4 | return_hit_if4;
  assign ifu_ifar_o                 = {abuf_va_if3[31:3], ip_if3[2:1]};
  assign ifu_ifsr_o                 = abort_type_if3[6:0];
  assign ifu_ifsr_stage2_o          = stage2_abort_if3[1:0];
  assign ifu_ifsr_lpae_o            = ifsr_lpae;
  assign ifu_hpfar_o                = abort_ipa_if3[27:0];
  assign ifu_evnt_ic_miss_wait_o    = evnt_stall_if2;
  assign ifu_evnt_iutlb_miss_wait_o = iutlb_miss_req;
  assign ifu_utlb_miss_req_o        = iutlb_miss_req;
  assign ifu_valid_if2_o            = valid_if2;
  assign pfb_va_if1_o               = va_if1[14:2];
  assign pfb_first_if1_o            = first_if1;
  assign pfb_valid_if1_o            = pfb_valid_if1;
  assign pfb_force_if1_o            = force_if1;
  assign pfb_utlb_hit_if2_o         = tlb_hit_if2;
  assign pfb_state_if2_o            = clean_state_if2[1:0];
  assign pfb_pa_if2_o               = {pa_if2[39:12], va_if2[11:4]};
  assign pfb_kill_if2_o             = kill_if2;
  assign pfb_attributes_if2_o       = attributes_if2[7:0];
  assign pfb_priv_if2_o             = priv_mode_if2;
  assign pfb_va_if2_o               = va_if2[63:0];
  assign pfb_ns_dsc_if2_o           = ns_dsc_if2;
  assign pfb_pdc_data_if3_o         = pdc_data_if3;
  assign pfb_pdc_ctl_if3_o          = {pdc_way_1_if3, pdc_way_0_if3, abuf_va_if3[14:3], ip_if3[2:1], pdc_req_if3};
  assign pfb_mbist_data_o           = cbuf_if3[79:0];
  assign pfb_in_debug_or_wfx_o      = in_debug_or_wfx;
  assign pfb_context_sync_o         = context_sync_lfb_drain;
  assign pfb_dbg_a64_state_o        = dbg_a64_state;
  // This represents avalid_if3 + bvalid_if3 + cvalid_if3
  assign pfb_valid_buffers_o[0]     = avalid_if3 & ~(bvalid_if3 ^ cvalid_if3);
  assign pfb_valid_buffers_o[1]     = bvalid_if3;

  // ------------------------------------------------------
  // OVL
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  wire [1:0] check_pfb_valid_buffers;
  assign check_pfb_valid_buffers = avalid_if3 + bvalid_if3 + cvalid_if3;

  assert_never  #(`OVL_FATAL, `OVL_ASSERT, "avalid_if3 + bvalid_if3 + cvalid_if3 wrong encoding")
  ovl_check_valid_buffer (.clk       (clk),
                          .reset_n   (reset_n),
                          .test_expr (check_pfb_valid_buffers != pfb_valid_buffers_o));
  reg ovl_pfu_alive;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_pfu_alive <= 1'b0;
    else
      ovl_pfu_alive <= pfb_valid_if1 | ovl_pfu_alive;

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pfb_valid_if1_o")
  u_ovl_x_pfb_valid_if1_o (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (pfb_valid_if1_o));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dpu_fe_valid_ret_i")
  u_ovl_x_dpu_fe_valid_ret_i (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (dpu_fe_valid_ret_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_dbg_a64_state")
  u_ovl_x_en_dbg_a64_state (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (en_dbg_a64_state));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_abort_ctl_if2")
  u_ovl_x_en_abort_ctl_if2 (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (ovl_pfu_alive),
                            .test_expr (en_abort_ctl_if2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_abort_data_if2")
  u_ovl_x_en_abort_data_if2 (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (ovl_pfu_alive),
                             .test_expr (en_abort_data_if2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_abuf_idata")
  u_ovl_x_en_abuf_idata (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_abuf_idata));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_addr_if1")
  u_ovl_x_en_addr_if1 (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (en_addr_if1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_addr_hi_if2")
  u_ovl_x_en_addr_hi_if2 (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (en_addr_hi_if2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_addr_lo_if2")
  u_ovl_x_en_addr_lo_if2 (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (en_addr_lo_if2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_bbuf_idata")
  u_ovl_x_en_bbuf_idata (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_bbuf_idata));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_cbuf_idata")
  u_ovl_x_en_cbuf_idata (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_cbuf_idata));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_line_if2")
  u_ovl_x_en_line_if2 (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (en_line_if2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_valid_if1")
  u_ovl_x_en_valid_if1 (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (en_valid_if1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_valid_if2")
  u_ovl_x_en_valid_if2 (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (en_valid_if2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: instr_been_corrected_en")
  u_ovl_x_instr_been_corrected_en (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (instr_been_corrected_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: instr_en")
  u_ovl_x_instr_en (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (instr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: iutlb_miss_req_en")
  u_ovl_x_iutlb_miss_req_en (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (iutlb_miss_req_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pfb_push[0]")
  u_ovl_x_pfb_push0 (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (pfb_push[0]));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: va_if3_en")
  u_ovl_x_va_if3_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (va_if3_en));


  // ----------------------------------------------------------------------------
  // OVL declarations
  // ----------------------------------------------------------------------------

  reg         ovl_first_if2;
  reg         ovl_valid_if2;
  reg         ovl_dpu_force;
  wire [1:0]  ovl_instr_valid_if3;
  reg         ovl_in_debug;
  reg         ovl_icu_dbg_hit_if3;

  always @(posedge clk or negedge reset_n)
    if(!reset_n)
      ovl_icu_dbg_hit_if3 <= 1'b0;
    else
      ovl_icu_dbg_hit_if3 <= icb_dbg_hit_if2_i;
  always @(posedge clk or negedge reset_n)
    if(!reset_n)
      ovl_in_debug <= 1'b0;
    else if (dpu_fe_valid_ret_i)
      ovl_in_debug <= dpu_halt_ifu_i;

  // ----------------------------------------------------------------------------
  // Commit push and pop mutually exclusive
  // ----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Commit push and pop mutually exclusive")
    ovl_pfu_cm_crs (.clk       (clk),
                    .reset_n   (reset_n),
                    .test_expr (crs_commited_push & crs_commited_pop));
  // OVL_ASSERT_END

  // ----------------------------------------------------------------------------
  // The valid_if1 signal must be asserted for pfb_valid_if1 to be asserted
  // ----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"The pfb_valid_if1_o signal is asserted incorrectly")
    ovl_pfu_valid_if1_req (.clk             (clk),
                           .reset_n         (reset_n),
                           .antecedent_expr (pfb_valid_if1_o),
                           .consequent_expr (valid_if1));
  // OVL_ASSERT_END

  // ----------------------------------------------------------------------------
  // If a stall occurs due to a uTLB miss and not a fetch_stall or a fetch_hold
  // then the pfb_valid_if1 signal will be asserted in the first cycle before
  // being suppressed by iutlb_miss_req in the next cycle (power optimization)
  // ----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"pfb_valid_if1 not asserted in first cycle of uTLB miss")
    ovl_pfu_pfu_valid_if1 (.clk             (clk),
                           .reset_n         (reset_n),
                           .antecedent_expr (valid_if1 & ~tlb_hit_if1 & ~iutlb_miss_req & ~fetch_stall_if1),
                           .consequent_expr (pfb_valid_if1));
  // OVL_ASSERT_END

  // ----------------------------------------------------------------------------
  // The iutlb_miss_req signal should be removed on a TLB update
  // ----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_next #(`OVL_FATAL,1,1,0,`OVL_ASSERT,"uTLB update yet PFU still stalled and main TLB request still signalled")
    ovl_pfu_tlb_missed (.clk         (clk),
                        .reset_n     (reset_n),
                        .start_event (tlb_i_utlb_enable_i & tlb_i_utlb_valid_i),
                        .test_expr   (~iutlb_miss_req));
  // OVL_ASSERT_END

  // ----------------------------------------------------------------------------
  // The tlb_i_utlb_enable_i bus should be low on the cycle following a DPU force
  // ----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  always @(posedge clk or negedge reset_n)
    if(!reset_n)
      ovl_dpu_force <= 1'b0;
    else
      ovl_dpu_force <= dpu_fe_valid_wr_i | dpu_fe_valid_ret_i;

  assert_never #(`OVL_FATAL, `OVL_ASSERT,"uTLB enables cannot be asserted in the cycle immediately following a DPU force")
    ovl_pfu_dpu_force (.clk        (clk),
                      .reset_n     (reset_n),
                      .test_expr   (ovl_dpu_force & tlb_i_utlb_enable_i));
  // OVL_ASSERT_END

  // ----------------------------------------------------------------------------
  // A valid request with a uTLB miss should be suppressed on the next cycle
  // ----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_next #(`OVL_FATAL,1,1,0,`OVL_ASSERT,"PFU request issued in if1, but uTLB missed and not suppressed in if2")
    ovl_pfu_req_suppress (.clk         (clk),
                          .reset_n     (reset_n),
                          .start_event ((pfb_valid_if1_o & ~tlb_hit_if1) & ~force_if0 & ~stall_if2),
                          .test_expr   (~pfb_utlb_hit_if2_o));
  // OVL_ASSERT_END

  // ----------------------------------------------------------------------------
  // The pre-decode error request signal to the ICU should only be asserted if
  // there is a pre-decode error in instruction 0.
  // ----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"The pre-decode error request signal should not be asserted")
    ovl_pfu_bad_pdc_req1 (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (pdc_req_if3),
                          .consequent_expr (instr0_pdec_err));
  // OVL_ASSERT_END

  // ----------------------------------------------------------------------------
  // A pre-decode error request should not occur if the fetch buffers
  // are not valid.
  // ----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Pre-decode error request yet no valid fetch buffers")
    ovl_pfu_bad_pdc_req2 (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (pdc_req_if3),
                          .consequent_expr (avalid_if3));
  // OVL_ASSERT_END

  // ----------------------------------------------------------------------------
  // If a uTLB abort occurs then the pfu_kill_if2 signal should be asserted
  // ----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"uTLB abort occured, but pfu_kill_if2 not signalled")
    ovl_pfu_kill_if2 (.clk             (clk),
                      .reset_n         (reset_n),
                      .antecedent_expr (micro_tlb_abort_if2),
                      .consequent_expr (pfb_kill_if2_o));
  // OVL_ASSERT_END

  // ----------------------------------------------------------------------------
  // Check the registered address value used by the branch predictor
  // ----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"abuf_va_plus1 bus used by BPD incorrect")
    ovl_abuf_va_plus1 (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (avalid_if3 & ~abort_inbound & ~ovl_in_debug),
                       .consequent_expr (abuf_va_plus1_if3[12:3] == (abuf_va_if3[12:3] + 1'b1)));
  // OVL_ASSERT_END


  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"abuf_va_plus2 bus used by BPD incorrect")
    ovl_abuf_va_plus2 (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (cvalid_if3 & ~abort_inbound & ~ovl_in_debug),
                       .consequent_expr (abuf_va_plus2_if3[12:3] == (abuf_va_plus1_if3[12:3] + 1'b1)));
  // OVL_ASSERT_END

  // ----------------------------------------------------------------------------
  // Check fast valids against real valids
  // ----------------------------------------------------------------------------

  assign ovl_instr_valid_if3[0] = (bvalid_if3 |
                                   (avalid_if3 & ~ip_if3[2]) |
                                   (avalid_if3 &  ip_if3[2] & ~ip_if3[1]) |
                                   (avalid_if3 &  ip_if3[2] &  ip_if3[1] & instr_is_t16_if3[0]));

  assign ovl_instr_valid_if3[1] = (~dbg_valid_if3 &
                                   (bvalid_if3 |
                                    (avalid_if3 & ~ip_if3[2] & ~ip_if3[1]) |
                                    (avalid_if3 & ~ip_if3[2] & instr_is_t16_if3[0]) |
                                    (avalid_if3 & ~ip_if3[2] & instr_is_t32_if3[0] & instr_is_t16_if3[1]) |
                                    (avalid_if3 &  ip_if3[2] & ~ip_if3[1] & instr_is_t16_if3[0] & instr_is_t16_if3[1])));

  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL, `OVL_ASSERT, "Fast valid signals do not match precise, slower valids")
    ovl_pfu_fast_valid (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (ovl_instr_valid_if3[1:0] == instr_valid_if3[1:0]));
  // OVL_ASSERT_END

  // ----------------------------------------------------------------------------
  // Not possible to get a uTLB abort and an external abort at the same time
  // ----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
   assert_never #(`OVL_FATAL, `OVL_ASSERT, "External abort should not happen in the same cycle as a uTLB abort without kill")
    ovl_pfu_imposs_abort (.clk       (clk),
                          .reset_n   (reset_n),
                          .test_expr (micro_tlb_abort_if2 & icb_ext_abort_if2_i & ~pfb_kill_if2_o));
  // OVL_ASSERT_END

  // ----------------------------------------------------------------------------
  // Check that there aren't any valid instructions presented by the PFU between
  // reset_n and the first fetch.  The assertion is ok despite tying off the
  // reset signal to 1'b1 as it allows the start event to be reset_n.
  // ----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg         pf_disable;
  always @(posedge clk or negedge reset_n)
    if(!reset_n)
      pf_disable <= 1'b1;
    else if (dpu_fe_valid_ret_i)
      pf_disable <= 1'b0;

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Incorrect pfu_instr_valid_if3 between last cycle of reset and reset fetch request")
    ovl_pfu_no_instr_v_between_rst_and_frc (.clk       (clk),
                                            .reset_n   (reset_n),
                                            .test_expr (pf_disable & (|ifu_instr_valid_if3_o)));

  // OVL_ASSERT_END

  // ----------------------------------------------------------------------------
  // Unknown checks on signals used in IQ format-0 iq_cond_code
  // priority case statement
  // ----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT, "Casez unknown check on iq_format0/iq_cond_code: (instr_abt_i | bkpvcr)")
    ovl_iq0_cond_casez_abt_bkpvcr  (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (ifu_instr_valid_if3_o[0]),
                                    .test_expr ((u_ca53ifu_pf_instr0.instr_abt_i | u_ca53ifu_pf_instr0.bkpvcr)));

  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT, "Casez unknown check on iq_format0/iq_cond_code: (instr_is_a32_i | instr_is_a64_i)")
    ovl_iq0_cond_casez_instr_arm   (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (ifu_instr_valid_if3_o[0] & ((u_ca53ifu_pf_instr0.instr_abt_i | u_ca53ifu_pf_instr0.bkpvcr) == 1'b0)),
                                    .test_expr ((u_ca53ifu_pf_instr0.instr_is_a32_i | u_ca53ifu_pf_instr0.instr_is_a64_i)));

  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT, "Casez unknown check on iq_format0/iq_cond_code: (it_block_i & ~instr_brn_t_cond_i)")
    ovl_iq0_cond_casez_it_brn_t    (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (ifu_instr_valid_if3_o[0] & ({(u_ca53ifu_pf_instr0.instr_abt_i | u_ca53ifu_pf_instr0.bkpvcr),
                                                                             (u_ca53ifu_pf_instr0.instr_is_a32_i | u_ca53ifu_pf_instr0.instr_is_a64_i)} == 2'b00)),
                                    .test_expr ((u_ca53ifu_pf_instr0.it_block_i | u_ca53ifu_pf_instr0.instr_brn_t_cond_i)));

  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT, "Casez unknown check on iq_format0/iq_cond_code: (instr_is_t16_i & ~undef)")
    ovl_iq0_cond_casez_t16_undef   (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (ifu_instr_valid_if3_o[0] & ({(u_ca53ifu_pf_instr0.instr_abt_i | u_ca53ifu_pf_instr0.bkpvcr),
                                                                             (u_ca53ifu_pf_instr0.instr_is_a32_i | u_ca53ifu_pf_instr0.instr_is_a64_i),
                                                                             (u_ca53ifu_pf_instr0.it_block_i & ~u_ca53ifu_pf_instr0.instr_brn_t_cond_i)} == 3'b000)),
                                    .test_expr ((u_ca53ifu_pf_instr0.instr_is_t16_i & ~u_ca53ifu_pf_instr0.undef)));

  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT, "Casez unknown check on iq_format0/iq_cond_code: instr_brn_t3_i")
    ovl_iq0_cond_casez_brn_t3      (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (ifu_instr_valid_if3_o[0] & ({(u_ca53ifu_pf_instr0.instr_abt_i | u_ca53ifu_pf_instr0.bkpvcr),
                                                                             (u_ca53ifu_pf_instr0.instr_is_a32_i | u_ca53ifu_pf_instr0.instr_is_a64_i),
                                                                             (u_ca53ifu_pf_instr0.it_block_i & ~u_ca53ifu_pf_instr0.instr_brn_t_cond_i),
                                                                             (u_ca53ifu_pf_instr0.instr_is_t16_i & ~u_ca53ifu_pf_instr0.undef)} == 4'b0000)),
                                    .test_expr (u_ca53ifu_pf_instr0.instr_brn_t3_i));
  // OVL_ASSERT_END

  // ----------------------------------------------------------------------------
  // Unknown checks on signals used in IQ format-0 iq_main_field
  // priority case statement
  // ----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT, "Casez unknown check on iq_format0/iq_main_field: instr_abt_i")
    ovl_iq0_main_casez_instr_abt   (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (ifu_instr_valid_if3_o[0]),
                                    .test_expr (u_ca53ifu_pf_instr0.instr_abt_i));

  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT, "Casez unknown check on iq_format0/iq_main_field: bkpvcr")
    ovl_iq0_main_casez_bkpvcr      (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (ifu_instr_valid_if3_o[0] & (u_ca53ifu_pf_instr0.instr_abt_i == 1'b0)),
                                    .test_expr (u_ca53ifu_pf_instr0.bkpvcr));

  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT, "Casez unknown check on iq_format0/iq_main_field: (instr_is_t16_i & ~undef)")
    ovl_iq0_main_casez_t16_undef   (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (ifu_instr_valid_if3_o[0] & ({u_ca53ifu_pf_instr0.instr_abt_i,
                                                                             u_ca53ifu_pf_instr0.bkpvcr} == 2'b00)),
                                    .test_expr ((u_ca53ifu_pf_instr0.instr_is_t16_i & ~u_ca53ifu_pf_instr0.undef)));

  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT, "Casez unknown check on iq_format0/iq_main_field: instr_is_t16_i")
    ovl_iq0_main_casez_t16         (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (ifu_instr_valid_if3_o[0] & ({u_ca53ifu_pf_instr0.instr_abt_i,
                                                                             u_ca53ifu_pf_instr0.bkpvcr,
                                                                             (u_ca53ifu_pf_instr0.instr_is_t16_i & ~u_ca53ifu_pf_instr0.undef)} == 3'b000)),
                                    .test_expr (~u_ca53ifu_pf_instr0.instr_is_t16_i));
  // OVL_ASSERT_END

  // ----------------------------------------------------------------------------
  // Unknown checks on signals used in IQ format-1 iq_cond_code
  // priority casez statement
  // ----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT, "Casez unknown check on iq_format1/iq_cond_code: (instr_is_a32_i | instr_is_a64_i)")
    ovl_iq1_cond_casez_instr_arm   (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (ifu_instr_valid_if3_o[1]),
                                    .test_expr ((u_ca53ifu_pf_instr1.instr_is_a32_i | u_ca53ifu_pf_instr1.instr_is_a64_i)));

  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT, "Casez unknown check on iq_format1/iq_cond_code: (it_block_i & ~instr_brn_t_cond_i)")
    ovl_iq1_cond_casez_it_brn_t    (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (ifu_instr_valid_if3_o[1] & ((u_ca53ifu_pf_instr1.instr_is_a32_i | u_ca53ifu_pf_instr1.instr_is_a64_i) == 1'b0)),
                                    .test_expr ((u_ca53ifu_pf_instr1.it_block_i | u_ca53ifu_pf_instr1.instr_brn_t_cond_i)));

  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT, "Casez unknown check on iq_format1/iq_cond_code: (instr_is_t16_i & ~undef)")
    ovl_iq1_cond_casez_t16_undef   (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (ifu_instr_valid_if3_o[1] & ({(u_ca53ifu_pf_instr1.instr_is_a32_i | u_ca53ifu_pf_instr1.instr_is_a64_i),
                                                                             (u_ca53ifu_pf_instr1.it_block_i & ~u_ca53ifu_pf_instr1.instr_brn_t_cond_i)} == 2'b00)),
                                    .test_expr ((u_ca53ifu_pf_instr1.instr_is_t16_i & ~u_ca53ifu_pf_instr1.undef)));

  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT, "Casez unknown check on iq_format1/iq_cond_code: instr_brn_t3_i")
    ovl_iq1_cond_casez_brn_t3      (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (ifu_instr_valid_if3_o[1] & ({(u_ca53ifu_pf_instr1.instr_is_a32_i | u_ca53ifu_pf_instr1.instr_is_a64_i),
                                                                             (u_ca53ifu_pf_instr1.it_block_i & ~u_ca53ifu_pf_instr1.instr_brn_t_cond_i),
                                                                             (u_ca53ifu_pf_instr1.instr_is_t16_i & ~u_ca53ifu_pf_instr1.undef)} == 3'b000)),
                                    .test_expr (u_ca53ifu_pf_instr1.instr_brn_t3_i));
  // OVL_ASSERT_END

  // ----------------------------------------------------------------------------
  // Unknown checks on signals used in IQ format-1 iq_main_field
  // priority casez statement
  // ----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT, "Casez unknown check on iq_format1/iq_main_field: (instr_is_t16_i & ~undef)")
    ovl_iq1_main_casez_t16_undef   (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (ifu_instr_valid_if3_o[1]),
                                    .test_expr ((u_ca53ifu_pf_instr1.instr_is_t16_i & ~u_ca53ifu_pf_instr1.undef)));

  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT, "Casez unknown check on iq_format1/iq_main_field: instr_is_t16_i")
    ovl_iq1_main_casez_t16         (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (ifu_instr_valid_if3_o[1] & ((u_ca53ifu_pf_instr1.instr_is_t16_i & ~u_ca53ifu_pf_instr1.undef) == 1'b0)),
                                    .test_expr (~u_ca53ifu_pf_instr1.instr_is_t16_i));
  // OVL_ASSERT_END

  //-----------------------------------------------------------------------------
  // cpsr_state checks
  //-----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Must not be in A32 state if ICB debug hit is asserted")
    ovl_pfu_debug_state (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (dbg_valid_if3),
                         .consequent_expr (cpsr_state != 2'b00));

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"CPSR State should never be 2'b11")
    ovl_cpsr_state (.clk       (clk),
                    .reset_n   (reset_n),
                    .test_expr (cpsr_state == 2'b11));
  // OVL_ASSERT_END

  //
  // OVL_ASSUME_START
  //
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"ICU dbg hit while not in debug")
  ovl_dbg_0 (.clk       (clk),
             .reset_n   (reset_n),
             .test_expr (~ovl_in_debug & icb_dbg_hit_if2_i));

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"DPU IQ full while in debug")
  ovl_dbg_1 (.clk       (clk),
             .reset_n   (reset_n),
             .test_expr (ovl_in_debug & dpu_iq_full_i));

  reg         ovl_first_pfu_req_seen;
  reg         ovl_first_dpu_force_seen;
  always @(posedge clk or negedge reset_n)
    if(!reset_n)
      ovl_first_pfu_req_seen <= 1'b0;
    else if (pfb_valid_if1_o)
      ovl_first_pfu_req_seen <= 1'b1;
  always @(posedge clk or negedge reset_n)
    if(!reset_n)
      ovl_first_dpu_force_seen <= 1'b0;
    else if (dpu_fe_valid_ret_i)
      ovl_first_dpu_force_seen <= 1'b1;


  assert_never #(`OVL_FATAL,`OVL_ASSERT,"TLB abort and PFU not started")
    ovl_tlb_abort_0 (.clk       (clk),
                     .reset_n   (reset_n),
                     .test_expr (~ovl_first_pfu_req_seen & |tlb_i_utlb_data_i[81:80] & tlb_i_utlb_enable_i));
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Force from WR and PFU not started")
    ovl_force_wr_0 (.clk       (clk),
                    .reset_n   (reset_n),
                    .test_expr (~ovl_first_pfu_req_seen & dpu_fe_valid_wr_i));

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Instr1 in IT while dpu_sctlr_itd_i set")
    ovl_itd_instr1 (.clk       (clk),
                    .reset_n   (reset_n),
                    .test_expr (cpsr_itd & in_it_block[1] & ifu_instr_valid_if3_o[1] & ifu_instr_valid_if3_o[0] & instr_it_if3[0]));

  //----------------------------------------------------------------------------
  // Branch decode checks
  //----------------------------------------------------------------------------

  // If instr0/instr1 is a branch immediate the branch offset selector must be
  // one of the valid cases.  Note this is checked here becuase the branch
  // decode module is purely combinatorial so has no input clock.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Instr-0 branch offset is not valid")
    ovl_i0_br_offset_chk
      (.clk             (clk),
       .reset_n         (reset_n),
       .antecedent_expr (u_ca53ifu_pf_dec_branch.instr_valid_if3_i[0] & u_ca53ifu_pf_dec_branch.instr_brn_imm_if3[0]),
       .consequent_expr ((u_ca53ifu_pf_dec_branch.gen_comb_dec[0].br_offset_sel >= 4'b0000) &
                         (u_ca53ifu_pf_dec_branch.gen_comb_dec[0].br_offset_sel <= 4'b1011)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Instr-1 branch offset is not valid")
    ovl_i1_br_offset_chk
      (.clk             (clk),
       .reset_n         (reset_n),
       .antecedent_expr (u_ca53ifu_pf_dec_branch.instr_valid_if3_i[1] & u_ca53ifu_pf_dec_branch.instr_brn_imm_if3[1] & instr1_possible),
       .consequent_expr ((u_ca53ifu_pf_dec_branch.gen_comb_dec[1].br_offset_sel >= 4'b0000) &
                         (u_ca53ifu_pf_dec_branch.gen_comb_dec[1].br_offset_sel <= 4'b1011)));

  // ------------------------------------------------------
  // Exception level signals must be one-hot
  // ------------------------------------------------------

  assert_one_hot #(`OVL_FATAL,4,`OVL_ASSERT, "Locally captured exception level must be one-hot")
    ovl_el_one_hot (.clk       (clk),
                    .reset_n   (reset_n),
                    .test_expr ({exception_level_3, exception_level_2, exception_level_1, exception_level_0}));

  // ------------------------------------------------------
  // Out-of-Range abort should never be unknown
  // ------------------------------------------------------

  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT, "Out-of-Range abort should never be unknown")
    ovl_out_of_range_unknown (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (out_of_range_abort));

`endif //  `ifdef ARM_ASSERT_ON

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53ifu_defs.v"
`undef CA53_UNDEFINE
/*END*/
