//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2015-02-17 13:54:57 +0000 (Tue, 17 Feb 2015) $
//
//      Revision            : $Revision: 302088 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

// This is the specification for the interface between the DPU and DCU
// Inputs and outputs are from the point of view of the DPU.

// Pull in the CPOP encodings

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_dpu_dcu_defs.v"
`include "cortexa53params.v"
`include "cortexa53params.v"

module ca53_dpu_dcu #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         dcu_ready_cp_iss_i,
  input         dcu_ready_iss_i,
  input         dcu_valid_dc3_i,
  input  [63:0] dcu_ld_data_dc3_i,
  input         dcu_strex_okay_dc3_i,
  input         dcu_wpt_hit_dc3_i,
  input         dcu_p_abort_dc3_i,
  input         dcu_ecc_err_dc3_i,
  input   [3:0] dcu_p_domain_dc3_i,
  input   [6:0] dcu_p_fault_dc3_i,
  input   [1:0] dcu_p_fault_stage_dc3_i,
  input         dcu_v2p_lpae_dc3_i,
  input         dcu_p_direction_dc3_i,
  input         dcu_cm_operation_dc3_i,
  input  [63:0] dcu_va_dc3_i,
  input [39:12] dcu_pa_dc3_i,
  input         dcu_dbg_dsb_ack_i,
  input         dcu_evnt_dc_access_i,
  input         dcu_ecc_fatal_i,
  input         dcu_ecc_valid_i,
  input   [1:0] dcu_ecc_ramid_i,
  input   [2:0] dcu_ecc_way_bank_id_i,
  input  [10:0] dcu_ecc_index_i,
  input         tlb_d_utlb_enable_i,
  input         dpu_valid_iss_i,
  input         dpu_valid_cp_iss_i,
  input         dpu_store_iss_i,
  input  [15:0] dpu_strobe_iss_i,
  input         dpu_excl_iss_i,
  input  [21:0] dpu_periphbase_i,
  input         dpu_pld_iss_i,
  input         dpu_pld_level_iss_i,
  input         dpu_priv_iss_i,
  input         dpu_first_iss_i,
  input         dpu_force_first_iss_i,
  input         dpu_second_x64_iss_i,
  input         dpu_neon_access_iss_i,
  input   [4:0] dpu_length_iss_i,
  input   [1:0] dpu_size_iss_i,
  input         dpu_req_align_iss_i,
  input   [2:0] dpu_align_size_iss_i,
  input         dpu_burst_iss_i,
  input         dpu_cross_64_iss_i,
  input   [8:0] dpu_cp_op_iss_i,
  input         dpu_non_temporal_iss_i,
  input         dpu_ldar_stlr_iss_i,
  input  [48:6] dpu_agu_a_operand_iss_i,
  input  [48:6] dpu_agu_b_operand_iss_i,
  input         dpu_agu_carry_out_64b_iss_i,
  input  [63:0] dpu_va_dc1_i,
  input         dpu_utlb_hit_dc1_i,
  input   [3:0] dpu_utlb_hit_entry_dc1_i,
  input [39:12] dpu_pa_dc1_i,
  input  [12:0] dpu_attributes_dc1_i,
  input         dpu_ns_dsc_dc1_i,
  input         dpu_lpae_dc1_i,
  input   [3:0] dpu_level_dc1_i,
  input   [3:0] dpu_domain_dc1_i,
  input   [8:0] dpu_fault_dc1_i,
  input         dpu_abort_dc1_i,
  input         dpu_stack_align_expt_dc1_i,
  input         dpu_ready_wr_i,
  input  [63:0] dpu_cp_data_wr_i,
  input [127:0] dpu_st_data_wr_i,
  input         dpu_kill_wr_i,
  input         dpu_cc_fail_wr_i,
  input         dpu_ready_cc_fail_wr_i,
  input         dpu_ready_cc_pass_wr_i,
  input         dpu_flush_i,
  input         dpu_ns_state_i,
  input         dpu_scr_el3_ns_i,
  input   [1:0] dpu_exception_level_i,
  input   [3:1] dpu_aarch64_at_el_i,
  input         dpu_aarch64_state_i,
  input         dpu_clear_excl_mon_i,
  input         dpu_dbg_dsb_req_i,
  input         dpu_mmu_on_el1_i,
  input         dpu_mmu_on_el2_i,
  input         dpu_mmu_on_el3_i,
  input         dpu_dcache_on_el1_i,
  input         dpu_dcache_on_el2_i,
  input         dpu_dcache_on_el3_i,
  input         dpu_s2_dcache_on_i,
  input         dpu_l1deien_i,
  input         dpu_disable_dmb_i,
  input         dpu_disable_no_allocate_i,
  input         dpu_icache_on_i,
  input         dpu_ipa_to_pa_en_i,
  input         dpu_default_cacheable_i);


  wire         dcu_ready_cp_iss = dcu_ready_cp_iss_i;
  wire         dcu_ready_iss = dcu_ready_iss_i;
  wire         dcu_valid_dc3 = dcu_valid_dc3_i;
  wire  [63:0] dcu_ld_data_dc3 = dcu_ld_data_dc3_i;
  wire         dcu_strex_okay_dc3 = dcu_strex_okay_dc3_i;
  wire         dcu_wpt_hit_dc3 = dcu_wpt_hit_dc3_i;
  wire         dcu_p_abort_dc3 = dcu_p_abort_dc3_i;
  wire         dcu_ecc_err_dc3 = dcu_ecc_err_dc3_i;
  wire   [3:0] dcu_p_domain_dc3 = dcu_p_domain_dc3_i;
  wire   [6:0] dcu_p_fault_dc3 = dcu_p_fault_dc3_i;
  wire   [1:0] dcu_p_fault_stage_dc3 = dcu_p_fault_stage_dc3_i;
  wire         dcu_v2p_lpae_dc3 = dcu_v2p_lpae_dc3_i;
  wire         dcu_p_direction_dc3 = dcu_p_direction_dc3_i;
  wire         dcu_cm_operation_dc3 = dcu_cm_operation_dc3_i;
  wire  [63:0] dcu_va_dc3 = dcu_va_dc3_i;
  wire [39:12] dcu_pa_dc3 = dcu_pa_dc3_i;
  wire         dcu_dbg_dsb_ack = dcu_dbg_dsb_ack_i;
  wire         dcu_evnt_dc_access = dcu_evnt_dc_access_i;
  wire         dcu_ecc_fatal = dcu_ecc_fatal_i;
  wire         dcu_ecc_valid = dcu_ecc_valid_i;
  wire   [1:0] dcu_ecc_ramid = dcu_ecc_ramid_i;
  wire   [2:0] dcu_ecc_way_bank_id = dcu_ecc_way_bank_id_i;
  wire  [10:0] dcu_ecc_index = dcu_ecc_index_i;
  wire         tlb_d_utlb_enable = tlb_d_utlb_enable_i;
  wire         dpu_valid_iss = dpu_valid_iss_i;
  wire         dpu_valid_cp_iss = dpu_valid_cp_iss_i;
  wire         dpu_store_iss = dpu_store_iss_i;
  wire  [15:0] dpu_strobe_iss = dpu_strobe_iss_i;
  wire         dpu_excl_iss = dpu_excl_iss_i;
  wire  [21:0] dpu_periphbase = dpu_periphbase_i;
  wire         dpu_pld_iss = dpu_pld_iss_i;
  wire         dpu_pld_level_iss = dpu_pld_level_iss_i;
  wire         dpu_priv_iss = dpu_priv_iss_i;
  wire         dpu_first_iss = dpu_first_iss_i;
  wire         dpu_force_first_iss = dpu_force_first_iss_i;
  wire         dpu_second_x64_iss = dpu_second_x64_iss_i;
  wire         dpu_neon_access_iss = dpu_neon_access_iss_i;
  wire   [4:0] dpu_length_iss = dpu_length_iss_i;
  wire   [1:0] dpu_size_iss = dpu_size_iss_i;
  wire         dpu_req_align_iss = dpu_req_align_iss_i;
  wire   [2:0] dpu_align_size_iss = dpu_align_size_iss_i;
  wire         dpu_burst_iss = dpu_burst_iss_i;
  wire         dpu_cross_64_iss = dpu_cross_64_iss_i;
  wire   [8:0] dpu_cp_op_iss = dpu_cp_op_iss_i;
  wire         dpu_non_temporal_iss = dpu_non_temporal_iss_i;
  wire         dpu_ldar_stlr_iss = dpu_ldar_stlr_iss_i;
  wire  [48:6] dpu_agu_a_operand_iss = dpu_agu_a_operand_iss_i;
  wire  [48:6] dpu_agu_b_operand_iss = dpu_agu_b_operand_iss_i;
  wire         dpu_agu_carry_out_64b_iss = dpu_agu_carry_out_64b_iss_i;
  wire  [63:0] dpu_va_dc1 = dpu_va_dc1_i;
  wire         dpu_utlb_hit_dc1 = dpu_utlb_hit_dc1_i;
  wire   [3:0] dpu_utlb_hit_entry_dc1 = dpu_utlb_hit_entry_dc1_i;
  wire [39:12] dpu_pa_dc1 = dpu_pa_dc1_i;
  wire  [12:0] dpu_attributes_dc1 = dpu_attributes_dc1_i;
  wire         dpu_ns_dsc_dc1 = dpu_ns_dsc_dc1_i;
  wire         dpu_lpae_dc1 = dpu_lpae_dc1_i;
  wire   [3:0] dpu_level_dc1 = dpu_level_dc1_i;
  wire   [3:0] dpu_domain_dc1 = dpu_domain_dc1_i;
  wire   [8:0] dpu_fault_dc1 = dpu_fault_dc1_i;
  wire         dpu_abort_dc1 = dpu_abort_dc1_i;
  wire         dpu_stack_align_expt_dc1 = dpu_stack_align_expt_dc1_i;
  wire         dpu_ready_wr = dpu_ready_wr_i;
  wire  [63:0] dpu_cp_data_wr = dpu_cp_data_wr_i;
  wire [127:0] dpu_st_data_wr = dpu_st_data_wr_i;
  wire         dpu_kill_wr = dpu_kill_wr_i;
  wire         dpu_cc_fail_wr = dpu_cc_fail_wr_i;
  wire         dpu_ready_cc_fail_wr = dpu_ready_cc_fail_wr_i;
  wire         dpu_ready_cc_pass_wr = dpu_ready_cc_pass_wr_i;
  wire         dpu_flush = dpu_flush_i;
  wire         dpu_ns_state = dpu_ns_state_i;
  wire         dpu_scr_el3_ns = dpu_scr_el3_ns_i;
  wire   [1:0] dpu_exception_level = dpu_exception_level_i;
  wire   [3:1] dpu_aarch64_at_el = dpu_aarch64_at_el_i;
  wire         dpu_aarch64_state = dpu_aarch64_state_i;
  wire         dpu_clear_excl_mon = dpu_clear_excl_mon_i;
  wire         dpu_dbg_dsb_req = dpu_dbg_dsb_req_i;
  wire         dpu_mmu_on_el1 = dpu_mmu_on_el1_i;
  wire         dpu_mmu_on_el2 = dpu_mmu_on_el2_i;
  wire         dpu_mmu_on_el3 = dpu_mmu_on_el3_i;
  wire         dpu_dcache_on_el1 = dpu_dcache_on_el1_i;
  wire         dpu_dcache_on_el2 = dpu_dcache_on_el2_i;
  wire         dpu_dcache_on_el3 = dpu_dcache_on_el3_i;
  wire         dpu_s2_dcache_on = dpu_s2_dcache_on_i;
  wire         dpu_l1deien = dpu_l1deien_i;
  wire         dpu_disable_dmb = dpu_disable_dmb_i;
  wire         dpu_disable_no_allocate = dpu_disable_no_allocate_i;
  wire         dpu_icache_on = dpu_icache_on_i;
  wire         dpu_ipa_to_pa_en = dpu_ipa_to_pa_en_i;
  wire         dpu_default_cacheable = dpu_default_cacheable_i;

  wire         en2;
  wire         v2p_iss;
  wire         leaving_dcu;
  wire         set_way_iss;
  wire  [63:0] cp_data_wr_mask;
  wire         dpu_ready_wr_real;
  wire         valid_cp_wr;
  wire         valid_ldr_or_pld;
  wire   [1:0] v2p_el_iss;
  wire         hword_strobe_antecedent;
  wire         clrex_iss;
  wire   [2:0] v2p_transl_type_iss;
  wire         word_strobe_antecedent;
  wire  [48:6] agu_addr_iss;
  wire         en0;
  wire         last_iss;
  wire         utlb_stall;
  wire         valid_dbgdr;
  wire         byte_strobe_antecedent;
  wire         entering_dcu_noflush;
  wire  [63:0] data_wr_mask;
  wire   [1:0] transl_el_dc1;
  wire         nxt_committed_burst;
  wire         entering_dcu;
  wire         valid_ld;
  wire         dpu_ignores_ld_data;
  wire         kill_or_cc_fail_wr;
  wire         dpu_utlb_hit_dc1_real;
  wire   [1:0] next_trans_no_flush;
  wire         dpu_valid_any_iss;
  wire   [7:0] attrs_dc1;
  wire         dword_strobe_antecedent;
  wire  [63:0] ld_data_mask;
  wire         entering_dcu_needs_transl;
  wire         en1;
  wire         first_iss;
  wire   [1:0] next_trans_flush;

  reg         valid1;
  reg         committed_burst;
  reg         valid0;
  reg   [1:0] size0;
  reg         prev_dpu_store_iss;
  reg         last0;
  reg         dpu_pld_iss1;
  reg         valid_ldr_or_pld1;
  reg  [63:0] prev_va;
  reg         first1;
  reg         valid_dbgdr0;
  reg         valid_cp_wr0;
  reg         valid_ldr_or_pld2;
  reg         last2;
  reg         v2ph_dc1;
  reg         dpu_valid_any_iss1;
  reg         v2p_dc1;
  reg         valid_ld0;
  reg  [15:0] strobe2;
  reg         valid_cp_wr2;
  reg         dpu_pld_iss2;
  reg         dpu_valid_any_iss0;
  reg         valid2;
  reg         initialization_done;
  reg         waiting_for_transl;
  reg   [1:0] size1;
  reg         valid_ld1;
  reg  [15:0] strobe0;
  reg         dpu_pld_iss0;
  reg         v2pe3_dc1;
  reg   [1:0] size2;
  reg   [1:0] v2p_el_dc1;
  reg         valid_dbgdr1;
  reg         last1;
  reg         dpu_clrex_iss1;
  reg         first0;
  reg         valid_cp_wr1;
  reg         valid_dbgdr2;
  reg         first2;
  reg         dpu_valid_any_iss2;
  reg   [1:0] trans_in_dcu;
  reg         dpu_clrex_iss0;
  reg  [15:0] strobe1;
  reg         v2pc_dc1;
  reg         dpu_clrex_iss2;
  reg  [48:6] agu_addr_dc1;
  reg         valid_ldr_or_pld0;
  reg         valid_ld2;

  reg         initialization_done_reg;
  reg         dpu_flush_reg;
  reg         dpu_store_iss_reg;
  reg         leaving_dcu_reg;
  reg         dpu_cc_fail_wr_reg;
  reg         dpu_dcache_on_el1_reg;
  reg         dpu_ready_wr_real_reg;
  reg         dpu_second_x64_iss_reg;
  reg   [2:0] dpu_align_size_iss_reg;
  reg         dpu_disable_no_allocate_reg;
  reg  [63:0] dpu_cp_data_wr_reg;
  reg         dcu_p_abort_dc3_reg;
  reg         dcu_wpt_hit_dc3_reg;
  reg         dpu_excl_iss_reg;
  reg         dpu_aarch64_state_reg;
  reg         dpu_kill_wr_reg;
  reg         dpu_first_iss_reg;
  reg         dpu_s2_dcache_on_reg;
  reg         dpu_dcache_on_el3_reg;
  reg         dcu_ecc_err_dc3_reg;
  reg         dcu_ready_iss_reg;
  reg   [1:0] dpu_size_iss_reg;
  reg         dpu_disable_dmb_reg;
  reg  [15:0] dpu_strobe_iss_reg;
  reg         valid_cp_wr0_reg;
  reg         dpu_utlb_hit_dc1_reg;
  reg   [4:0] dpu_length_iss_reg;
  reg         entering_dcu_noflush_reg;
  reg         tlb_d_utlb_enable_reg;
  reg         dpu_dbg_dsb_req_reg;
  reg         entering_dcu_reg;
  reg         dpu_ns_state_reg;
  reg   [1:0] trans_in_dcu_reg;
  reg         dcu_valid_dc3_reg;
  reg         dpu_cross_64_iss_reg;
  reg         dpu_dcache_on_el2_reg;
  reg         dpu_req_align_iss_reg;
  reg         kill_or_cc_fail_wr_reg;
  reg         dpu_pld_iss_reg;
  reg   [1:0] dpu_exception_level_reg;
  reg         dpu_ready_wr_reg;
  reg         dpu_valid_any_iss_reg;
  reg         dpu_priv_iss_reg;
  reg         dpu_valid_iss_reg;
  reg         dcu_dbg_dsb_ack_reg;
  reg         entering_dcu_needs_transl_reg;
  reg         dpu_valid_cp_iss_reg;
  reg         dpu_burst_iss_reg;
  reg   [8:0] dpu_cp_op_iss_reg;
  reg         dpu_force_first_iss_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    initialization_done_reg <= 1'b0;
    dpu_flush_reg <= 1'b0;
    dpu_store_iss_reg <= 1'b0;
    leaving_dcu_reg <= 1'b0;
    dpu_cc_fail_wr_reg <= 1'b0;
    dpu_dcache_on_el1_reg <= 1'b0;
    dpu_ready_wr_real_reg <= 1'b0;
    dpu_second_x64_iss_reg <= 1'b0;
    dpu_align_size_iss_reg <= 3'b000;
    dpu_disable_no_allocate_reg <= 1'b0;
    dpu_cp_data_wr_reg <= {64{1'b0}};
    dcu_p_abort_dc3_reg <= 1'b0;
    dcu_wpt_hit_dc3_reg <= 1'b0;
    dpu_excl_iss_reg <= 1'b0;
    dpu_aarch64_state_reg <= 1'b0;
    dpu_kill_wr_reg <= 1'b0;
    dpu_first_iss_reg <= 1'b0;
    dpu_s2_dcache_on_reg <= 1'b0;
    dpu_dcache_on_el3_reg <= 1'b0;
    dcu_ecc_err_dc3_reg <= 1'b0;
    dcu_ready_iss_reg <= 1'b0;
    dpu_size_iss_reg <= 2'b00;
    dpu_disable_dmb_reg <= 1'b0;
    dpu_strobe_iss_reg <= {16{1'b0}};
    valid_cp_wr0_reg <= 1'b0;
    dpu_utlb_hit_dc1_reg <= 1'b0;
    dpu_length_iss_reg <= {5{1'b0}};
    entering_dcu_noflush_reg <= 1'b0;
    tlb_d_utlb_enable_reg <= 1'b0;
    dpu_dbg_dsb_req_reg <= 1'b0;
    entering_dcu_reg <= 1'b0;
    dpu_ns_state_reg <= 1'b0;
    trans_in_dcu_reg <= 2'b00;
    dcu_valid_dc3_reg <= 1'b0;
    dpu_cross_64_iss_reg <= 1'b0;
    dpu_dcache_on_el2_reg <= 1'b0;
    dpu_req_align_iss_reg <= 1'b0;
    kill_or_cc_fail_wr_reg <= 1'b0;
    dpu_pld_iss_reg <= 1'b0;
    dpu_exception_level_reg <= 2'b00;
    dpu_ready_wr_reg <= 1'b0;
    dpu_valid_any_iss_reg <= 1'b0;
    dpu_priv_iss_reg <= 1'b0;
    dpu_valid_iss_reg <= 1'b0;
    dcu_dbg_dsb_ack_reg <= 1'b0;
    entering_dcu_needs_transl_reg <= 1'b0;
    dpu_valid_cp_iss_reg <= 1'b0;
    dpu_burst_iss_reg <= 1'b0;
    dpu_cp_op_iss_reg <= {9{1'b0}};
    dpu_force_first_iss_reg <= 1'b0;
  end
  else
  begin
    dcu_ready_iss_reg <= dcu_ready_iss;
    dcu_valid_dc3_reg <= dcu_valid_dc3;
    dcu_wpt_hit_dc3_reg <= dcu_wpt_hit_dc3;
    dcu_p_abort_dc3_reg <= dcu_p_abort_dc3;
    dcu_ecc_err_dc3_reg <= dcu_ecc_err_dc3;
    dcu_dbg_dsb_ack_reg <= dcu_dbg_dsb_ack;
    tlb_d_utlb_enable_reg <= tlb_d_utlb_enable;
    dpu_valid_iss_reg <= dpu_valid_iss;
    dpu_valid_cp_iss_reg <= dpu_valid_cp_iss;
    dpu_store_iss_reg <= dpu_store_iss;
    dpu_strobe_iss_reg <= dpu_strobe_iss;
    dpu_excl_iss_reg <= dpu_excl_iss;
    dpu_pld_iss_reg <= dpu_pld_iss;
    dpu_priv_iss_reg <= dpu_priv_iss;
    dpu_first_iss_reg <= dpu_first_iss;
    dpu_force_first_iss_reg <= dpu_force_first_iss;
    dpu_second_x64_iss_reg <= dpu_second_x64_iss;
    dpu_length_iss_reg <= dpu_length_iss;
    dpu_size_iss_reg <= dpu_size_iss;
    dpu_req_align_iss_reg <= dpu_req_align_iss;
    dpu_align_size_iss_reg <= dpu_align_size_iss;
    dpu_burst_iss_reg <= dpu_burst_iss;
    dpu_cross_64_iss_reg <= dpu_cross_64_iss;
    dpu_cp_op_iss_reg <= dpu_cp_op_iss;
    dpu_utlb_hit_dc1_reg <= dpu_utlb_hit_dc1;
    dpu_ready_wr_reg <= dpu_ready_wr;
    dpu_cp_data_wr_reg <= dpu_cp_data_wr;
    dpu_kill_wr_reg <= dpu_kill_wr;
    dpu_cc_fail_wr_reg <= dpu_cc_fail_wr;
    dpu_flush_reg <= dpu_flush;
    dpu_ns_state_reg <= dpu_ns_state;
    dpu_exception_level_reg <= dpu_exception_level;
    dpu_aarch64_state_reg <= dpu_aarch64_state;
    dpu_dbg_dsb_req_reg <= dpu_dbg_dsb_req;
    dpu_dcache_on_el1_reg <= dpu_dcache_on_el1;
    dpu_dcache_on_el2_reg <= dpu_dcache_on_el2;
    dpu_dcache_on_el3_reg <= dpu_dcache_on_el3;
    dpu_s2_dcache_on_reg <= dpu_s2_dcache_on;
    dpu_disable_dmb_reg <= dpu_disable_dmb;
    dpu_disable_no_allocate_reg <= dpu_disable_no_allocate;
    initialization_done_reg <= initialization_done;
    leaving_dcu_reg <= leaving_dcu;
    dpu_ready_wr_real_reg <= dpu_ready_wr_real;
    valid_cp_wr0_reg <= valid_cp_wr0;
    entering_dcu_noflush_reg <= entering_dcu_noflush;
    entering_dcu_reg <= entering_dcu;
    trans_in_dcu_reg <= trans_in_dcu;
    kill_or_cc_fail_wr_reg <= kill_or_cc_fail_wr;
    dpu_valid_any_iss_reg <= dpu_valid_any_iss;
    entering_dcu_needs_transl_reg <= entering_dcu_needs_transl;
  end



  // Any DPU outputs initialized by the reset FSM rather than by reset itself
  // will not be valid for the 1st two cycles after reset has been deasserted

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    initialization_done <= 1'b0;
  else
    initialization_done <= 1'b1;

  assign dpu_ignores_ld_data  = dcu_p_abort_dc3 | dcu_wpt_hit_dc3 | dcu_ecc_err_dc3 | dpu_kill_wr | ~dpu_ready_wr | dpu_cc_fail_wr;

  // The DPU only needs the bytes requested to be valid.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    strobe0 <= {16{1'b0}};
  else if (en0)
    strobe0 <= (leaving_dcu & valid1) ? strobe1 : dpu_strobe_iss;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    strobe1 <= {16{1'b0}};
  else if (en1)
    strobe1 <= (leaving_dcu & valid2) ? strobe2 : dpu_strobe_iss;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    strobe2 <= {16{1'b0}};
  else if (en2)
    strobe2 <= dpu_strobe_iss;


  assign data_wr_mask  = { {8{strobe0[15] | strobe0[7]}}, {8{strobe0[14] | strobe0[6]}}, {8{strobe0[13] | strobe0[5]}}, {8{strobe0[12] | strobe0[4]}}, {8{strobe0[11] | strobe0[3]}}, {8{strobe0[10] | strobe0[2]}}, {8{strobe0[9]  | strobe0[1]}}, {8{strobe0[8]  | strobe0[0]}} };


  // Ignore Xs on DBGDRx reads, as load data can be X in unit level simulation for those requests.
  assign ld_data_mask  = {64{dcu_valid_dc3 & valid_ld0 & ~valid_dbgdr0 & ~dpu_ignores_ld_data}} & data_wr_mask;

  // ------------------------------------------------------
  // Interface signals
  // ------------------------------------------------------

  // Inputs to the DPU from the DCU
  //  input          dcu_ready_cp_iss           valid always                                              timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_ready_cp_iss X or Z")
  u_ovl_intf_x_dcu_ready_cp_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_ready_cp_iss));

  //  input          dcu_ready_iss              valid always                                              timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_ready_iss X or Z")
  u_ovl_intf_x_dcu_ready_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_ready_iss));


  //  input          dcu_valid_dc3              valid always                                              timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_valid_dc3 X or Z")
  u_ovl_intf_x_dcu_valid_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_valid_dc3));

  //  input [63:0]   dcu_ld_data_dc3            valid mask ld_data_mask                                   timing 17%

  assert_never_unknown #(`OVL_FATAL, 64, INOPTIONS, "dcu_ld_data_dc3 & (ld_data_mask) X or Z")
  u_ovl_intf_x_2d50c8d14f3c04271dfc564b45c63cf59725e617 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_ld_data_dc3 & (ld_data_mask)));

  //  input          dcu_strex_okay_dc3         valid dcu_valid_dc3                                       timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_strex_okay_dc3 X or Z")
  u_ovl_intf_x_dcu_strex_okay_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_valid_dc3),
    .test_expr (dcu_strex_okay_dc3));

  //  input          dcu_wpt_hit_dc3            valid dcu_valid_dc3                                       timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_wpt_hit_dc3 X or Z")
  u_ovl_intf_x_dcu_wpt_hit_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_valid_dc3),
    .test_expr (dcu_wpt_hit_dc3));

  //  input          dcu_p_abort_dc3            valid dcu_valid_dc3                                       timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_p_abort_dc3 X or Z")
  u_ovl_intf_x_dcu_p_abort_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_valid_dc3),
    .test_expr (dcu_p_abort_dc3));

  //  input          dcu_ecc_err_dc3            valid dcu_valid_dc3                                       timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_ecc_err_dc3 X or Z")
  u_ovl_intf_x_dcu_ecc_err_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_valid_dc3),
    .test_expr (dcu_ecc_err_dc3));

  //  input [3:0]    dcu_p_domain_dc3           valid dcu_p_abort_dc3                                     timing 40%

  assert_never_unknown #(`OVL_FATAL, 4, INOPTIONS, "dcu_p_domain_dc3 X or Z")
  u_ovl_intf_x_dcu_p_domain_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_p_abort_dc3),
    .test_expr (dcu_p_domain_dc3));

  //  input [6:0]    dcu_p_fault_dc3            valid dcu_p_abort_dc3                                     timing 40%

  assert_never_unknown #(`OVL_FATAL, 7, INOPTIONS, "dcu_p_fault_dc3 X or Z")
  u_ovl_intf_x_dcu_p_fault_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_p_abort_dc3),
    .test_expr (dcu_p_fault_dc3));

  //  input [1:0]    dcu_p_fault_stage_dc3      valid dcu_p_abort_dc3                                     timing 40%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "dcu_p_fault_stage_dc3 X or Z")
  u_ovl_intf_x_dcu_p_fault_stage_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_p_abort_dc3),
    .test_expr (dcu_p_fault_stage_dc3));

  //  input          dcu_v2p_lpae_dc3           valid dcu_p_abort_dc3 & (dcu_p_fault_stage_dc3 == 2'b00)  timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_v2p_lpae_dc3 X or Z")
  u_ovl_intf_x_dcu_v2p_lpae_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_p_abort_dc3 & (dcu_p_fault_stage_dc3 == 2'b00)),
    .test_expr (dcu_v2p_lpae_dc3));

  //  input          dcu_p_direction_dc3        valid (dcu_p_abort_dc3 | dcu_wpt_hit_dc3)                 timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_p_direction_dc3 X or Z")
  u_ovl_intf_x_dcu_p_direction_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier ((dcu_p_abort_dc3 | dcu_wpt_hit_dc3)),
    .test_expr (dcu_p_direction_dc3));

  //  input          dcu_cm_operation_dc3       valid (dcu_p_abort_dc3 | dcu_wpt_hit_dc3)                 timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_cm_operation_dc3 X or Z")
  u_ovl_intf_x_dcu_cm_operation_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier ((dcu_p_abort_dc3 | dcu_wpt_hit_dc3)),
    .test_expr (dcu_cm_operation_dc3));

  //  input [63:0]   dcu_va_dc3                 valid dcu_valid_dc3                                       timing 30%

  assert_never_unknown #(`OVL_FATAL, 64, INOPTIONS, "dcu_va_dc3 X or Z")
  u_ovl_intf_x_dcu_va_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_valid_dc3),
    .test_expr (dcu_va_dc3));

  //  input [39:12]  dcu_pa_dc3                 valid dcu_valid_dc3 & dcu_p_abort_dc3 & dcu_p_fault_stage_dc3[1] timing 30%

  assert_never_unknown #(`OVL_FATAL, 28, INOPTIONS, "dcu_pa_dc3 X or Z")
  u_ovl_intf_x_dcu_pa_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_valid_dc3 & dcu_p_abort_dc3 & dcu_p_fault_stage_dc3[1]),
    .test_expr (dcu_pa_dc3));


  //  input          dcu_dbg_dsb_ack            valid dpu_dbg_dsb_req                                     timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_dbg_dsb_ack X or Z")
  u_ovl_intf_x_dcu_dbg_dsb_ack (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_dbg_dsb_req),
    .test_expr (dcu_dbg_dsb_ack));

  //  input          dcu_evnt_dc_access         valid always                                              timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_evnt_dc_access X or Z")
  u_ovl_intf_x_dcu_evnt_dc_access (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_evnt_dc_access));


  //  input          dcu_ecc_fatal              valid dcu_ecc_valid                                       timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_ecc_fatal X or Z")
  u_ovl_intf_x_dcu_ecc_fatal (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_ecc_valid),
    .test_expr (dcu_ecc_fatal));

  //  input          dcu_ecc_valid              valid always                                              timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_ecc_valid X or Z")
  u_ovl_intf_x_dcu_ecc_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_ecc_valid));

  //  input [1:0]    dcu_ecc_ramid              valid dcu_ecc_valid                                       timing 50%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "dcu_ecc_ramid X or Z")
  u_ovl_intf_x_dcu_ecc_ramid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_ecc_valid),
    .test_expr (dcu_ecc_ramid));

  //  input [2:0]    dcu_ecc_way_bank_id        valid dcu_ecc_valid                                       timing 50%

  assert_never_unknown #(`OVL_FATAL, 3, INOPTIONS, "dcu_ecc_way_bank_id X or Z")
  u_ovl_intf_x_dcu_ecc_way_bank_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_ecc_valid),
    .test_expr (dcu_ecc_way_bank_id));

  //  input [10:0]   dcu_ecc_index              valid dcu_ecc_valid                                       timing 50%

  assert_never_unknown #(`OVL_FATAL, 11, INOPTIONS, "dcu_ecc_index X or Z")
  u_ovl_intf_x_dcu_ecc_index (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_ecc_valid),
    .test_expr (dcu_ecc_index));


  // Outputs from the DPU to the DCU                                                               
  //  output         dpu_valid_iss              valid always                                              timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_valid_iss X or Z")
  u_ovl_intf_x_dpu_valid_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_valid_iss));

  //  output         dpu_valid_cp_iss           valid always                                              timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_valid_cp_iss X or Z")
  u_ovl_intf_x_dpu_valid_cp_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_valid_cp_iss));

  //  output         dpu_store_iss              valid always                                              timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_store_iss X or Z")
  u_ovl_intf_x_dpu_store_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_store_iss));

  //  output [15:0]  dpu_strobe_iss             valid dpu_valid_iss | dpu_valid_cp_iss                    timing 80%

  assert_never_unknown #(`OVL_FATAL, 16, OUTOPTIONS, "dpu_strobe_iss X or Z")
  u_ovl_intf_x_dpu_strobe_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss | dpu_valid_cp_iss),
    .test_expr (dpu_strobe_iss));

  //  output         dpu_excl_iss               valid dpu_valid_iss | dpu_valid_cp_iss                    timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_excl_iss X or Z")
  u_ovl_intf_x_dpu_excl_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss | dpu_valid_cp_iss),
    .test_expr (dpu_excl_iss));

  //  output [21:0]  dpu_periphbase             valid initialization_done@1                               timing 50%

  assert_never_unknown #(`OVL_FATAL, 22, OUTOPTIONS, "dpu_periphbase X or Z")
  u_ovl_intf_x_dpu_periphbase (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (initialization_done_reg),
    .test_expr (dpu_periphbase));

  //  output         dpu_pld_iss                valid dpu_valid_iss | dpu_valid_cp_iss                    timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_pld_iss X or Z")
  u_ovl_intf_x_dpu_pld_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss | dpu_valid_cp_iss),
    .test_expr (dpu_pld_iss));

  //  output         dpu_pld_level_iss          valid dpu_valid_iss | dpu_valid_cp_iss                    timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_pld_level_iss X or Z")
  u_ovl_intf_x_dpu_pld_level_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss | dpu_valid_cp_iss),
    .test_expr (dpu_pld_level_iss));

  //  output         dpu_priv_iss               valid dpu_valid_iss | dpu_valid_cp_iss                    timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_priv_iss X or Z")
  u_ovl_intf_x_dpu_priv_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss | dpu_valid_cp_iss),
    .test_expr (dpu_priv_iss));

  //  output         dpu_first_iss              valid dpu_valid_iss | dpu_valid_cp_iss                    timing 90%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_first_iss X or Z")
  u_ovl_intf_x_dpu_first_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss | dpu_valid_cp_iss),
    .test_expr (dpu_first_iss));

  //  output         dpu_force_first_iss        valid dpu_valid_iss | dpu_valid_cp_iss                    timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_force_first_iss X or Z")
  u_ovl_intf_x_dpu_force_first_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss | dpu_valid_cp_iss),
    .test_expr (dpu_force_first_iss));

  //  output         dpu_second_x64_iss         valid dpu_valid_iss | dpu_valid_cp_iss                    timing 90%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_second_x64_iss X or Z")
  u_ovl_intf_x_dpu_second_x64_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss | dpu_valid_cp_iss),
    .test_expr (dpu_second_x64_iss));

  //  output         dpu_neon_access_iss        valid dpu_valid_iss                                       timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_neon_access_iss X or Z")
  u_ovl_intf_x_dpu_neon_access_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss),
    .test_expr (dpu_neon_access_iss));

  //  output [4:0]   dpu_length_iss             valid dpu_valid_iss | dpu_valid_cp_iss                    timing 80%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "dpu_length_iss X or Z")
  u_ovl_intf_x_dpu_length_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss | dpu_valid_cp_iss),
    .test_expr (dpu_length_iss));

  //  output [1:0]   dpu_size_iss               valid dpu_valid_iss | dpu_valid_cp_iss                    timing 80%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "dpu_size_iss X or Z")
  u_ovl_intf_x_dpu_size_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss | dpu_valid_cp_iss),
    .test_expr (dpu_size_iss));

  //  output         dpu_req_align_iss          valid dpu_valid_iss | dpu_valid_cp_iss                    timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_req_align_iss X or Z")
  u_ovl_intf_x_dpu_req_align_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss | dpu_valid_cp_iss),
    .test_expr (dpu_req_align_iss));

  //  output [2:0]   dpu_align_size_iss         valid dpu_valid_iss | dpu_valid_cp_iss                    timing 80%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "dpu_align_size_iss X or Z")
  u_ovl_intf_x_dpu_align_size_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss | dpu_valid_cp_iss),
    .test_expr (dpu_align_size_iss));

  //  output         dpu_burst_iss              valid dpu_valid_iss | dpu_valid_cp_iss                    timing 90%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_burst_iss X or Z")
  u_ovl_intf_x_dpu_burst_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss | dpu_valid_cp_iss),
    .test_expr (dpu_burst_iss));

  //  output         dpu_cross_64_iss           valid dpu_valid_iss | dpu_valid_cp_iss                    timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_cross_64_iss X or Z")
  u_ovl_intf_x_dpu_cross_64_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss | dpu_valid_cp_iss),
    .test_expr (dpu_cross_64_iss));

  //  output [8:0]   dpu_cp_op_iss              valid dpu_valid_cp_iss                                    timing 80%

  assert_never_unknown #(`OVL_FATAL, 9, OUTOPTIONS, "dpu_cp_op_iss X or Z")
  u_ovl_intf_x_dpu_cp_op_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_cp_iss),
    .test_expr (dpu_cp_op_iss));

  //  output         dpu_non_temporal_iss       valid dpu_valid_iss | dpu_valid_cp_iss                    timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_non_temporal_iss X or Z")
  u_ovl_intf_x_dpu_non_temporal_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss | dpu_valid_cp_iss),
    .test_expr (dpu_non_temporal_iss));

  //  output         dpu_ldar_stlr_iss          valid dpu_valid_iss | dpu_valid_cp_iss                    timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_ldar_stlr_iss X or Z")
  u_ovl_intf_x_dpu_ldar_stlr_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss | dpu_valid_cp_iss),
    .test_expr (dpu_ldar_stlr_iss));

  //  output [48:6]  dpu_agu_a_operand_iss      valid dpu_valid_iss                                       timing 50%

  assert_never_unknown #(`OVL_FATAL, 43, OUTOPTIONS, "dpu_agu_a_operand_iss X or Z")
  u_ovl_intf_x_dpu_agu_a_operand_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss),
    .test_expr (dpu_agu_a_operand_iss));

  //  output [48:6]  dpu_agu_b_operand_iss      valid dpu_valid_iss                                       timing 50%

  assert_never_unknown #(`OVL_FATAL, 43, OUTOPTIONS, "dpu_agu_b_operand_iss X or Z")
  u_ovl_intf_x_dpu_agu_b_operand_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss),
    .test_expr (dpu_agu_b_operand_iss));

  //  output         dpu_agu_carry_out_64b_iss  valid dpu_valid_iss                                       timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_agu_carry_out_64b_iss X or Z")
  u_ovl_intf_x_dpu_agu_carry_out_64b_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_valid_iss),
    .test_expr (dpu_agu_carry_out_64b_iss));


  //  output [63:0]  dpu_va_dc1                 valid entering_dcu@1                                      timing 20%

  assert_never_unknown #(`OVL_FATAL, 64, OUTOPTIONS, "dpu_va_dc1 X or Z")
  u_ovl_intf_x_dpu_va_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (entering_dcu_reg),
    .test_expr (dpu_va_dc1));

  //  output         dpu_utlb_hit_dc1           valid entering_dcu@1                                      timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_utlb_hit_dc1 X or Z")
  u_ovl_intf_x_dpu_utlb_hit_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (entering_dcu_reg),
    .test_expr (dpu_utlb_hit_dc1));

  //  output [3:0]   dpu_utlb_hit_entry_dc1     valid dpu_utlb_hit_dc1                                    timing 17%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "dpu_utlb_hit_entry_dc1 X or Z")
  u_ovl_intf_x_dpu_utlb_hit_entry_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_utlb_hit_dc1),
    .test_expr (dpu_utlb_hit_entry_dc1));

  //  output [39:12] dpu_pa_dc1                 valid dpu_utlb_hit_dc1                                    timing 30%

  assert_never_unknown #(`OVL_FATAL, 28, OUTOPTIONS, "dpu_pa_dc1 X or Z")
  u_ovl_intf_x_dpu_pa_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_utlb_hit_dc1),
    .test_expr (dpu_pa_dc1));

  //  output [12:0]  dpu_attributes_dc1         valid dpu_utlb_hit_dc1                                    timing 60%

  assert_never_unknown #(`OVL_FATAL, 13, OUTOPTIONS, "dpu_attributes_dc1 X or Z")
  u_ovl_intf_x_dpu_attributes_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_utlb_hit_dc1),
    .test_expr (dpu_attributes_dc1));

  //  output         dpu_ns_dsc_dc1             valid dpu_utlb_hit_dc1                                    timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_ns_dsc_dc1 X or Z")
  u_ovl_intf_x_dpu_ns_dsc_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_utlb_hit_dc1),
    .test_expr (dpu_ns_dsc_dc1));

  //  output         dpu_lpae_dc1               valid dpu_utlb_hit_dc1                                    timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_lpae_dc1 X or Z")
  u_ovl_intf_x_dpu_lpae_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_utlb_hit_dc1),
    .test_expr (dpu_lpae_dc1));

  //  output [3:0]   dpu_level_dc1              valid dpu_utlb_hit_dc1                                    timing 40%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "dpu_level_dc1 X or Z")
  u_ovl_intf_x_dpu_level_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_utlb_hit_dc1),
    .test_expr (dpu_level_dc1));

  //  output [3:0]   dpu_domain_dc1             valid dpu_utlb_hit_dc1_real & ~dpu_flush & dpu_abort_dc1  timing 40%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "dpu_domain_dc1 X or Z")
  u_ovl_intf_x_dpu_domain_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_utlb_hit_dc1_real & ~dpu_flush & dpu_abort_dc1),
    .test_expr (dpu_domain_dc1));

  //  output [8:0]   dpu_fault_dc1              valid dpu_utlb_hit_dc1_real & ~dpu_flush & dpu_abort_dc1  timing 60%

  assert_never_unknown #(`OVL_FATAL, 9, OUTOPTIONS, "dpu_fault_dc1 X or Z")
  u_ovl_intf_x_dpu_fault_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_utlb_hit_dc1_real & ~dpu_flush & dpu_abort_dc1),
    .test_expr (dpu_fault_dc1));

  //  output         dpu_abort_dc1              valid dpu_utlb_hit_dc1_real & ~dpu_flush                  timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_abort_dc1 X or Z")
  u_ovl_intf_x_dpu_abort_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_utlb_hit_dc1_real & ~dpu_flush),
    .test_expr (dpu_abort_dc1));

  //  output         dpu_stack_align_expt_dc1   valid entering_dcu@1 & dpu_valid_iss@1                    timing 17%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_stack_align_expt_dc1 X or Z")
  u_ovl_intf_x_dpu_stack_align_expt_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (entering_dcu_reg & dpu_valid_iss_reg),
    .test_expr (dpu_stack_align_expt_dc1));


  //  output         dpu_ready_wr               valid always                                              timing 17%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_ready_wr X or Z")
  u_ovl_intf_x_dpu_ready_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_ready_wr));

  //  output         dpu_kill_wr                valid always                                              timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_kill_wr X or Z")
  u_ovl_intf_x_dpu_kill_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_kill_wr));

  //  output         dpu_cc_fail_wr             valid dpu_ready_wr                                        timing 17%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_cc_fail_wr X or Z")
  u_ovl_intf_x_dpu_cc_fail_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_ready_wr),
    .test_expr (dpu_cc_fail_wr));

  //  output         dpu_ready_cc_fail_wr       valid always                                              timing 17%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_ready_cc_fail_wr X or Z")
  u_ovl_intf_x_dpu_ready_cc_fail_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_ready_cc_fail_wr));

  //  output         dpu_ready_cc_pass_wr       valid always                                              timing 17%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_ready_cc_pass_wr X or Z")
  u_ovl_intf_x_dpu_ready_cc_pass_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_ready_cc_pass_wr));


  //  output         dpu_flush                  valid always                                              timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_flush X or Z")
  u_ovl_intf_x_dpu_flush (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_flush));


  //  output         dpu_ns_state               valid always                                              timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_ns_state X or Z")
  u_ovl_intf_x_dpu_ns_state (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_ns_state));

  //  output         dpu_scr_el3_ns             valid always                                              timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_scr_el3_ns X or Z")
  u_ovl_intf_x_dpu_scr_el3_ns (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_scr_el3_ns));

  //  output [1:0]   dpu_exception_level        valid always                                              timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "dpu_exception_level X or Z")
  u_ovl_intf_x_dpu_exception_level (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_exception_level));

  //  output [3:1]   dpu_aarch64_at_el          valid always                                              timing 30%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "dpu_aarch64_at_el X or Z")
  u_ovl_intf_x_dpu_aarch64_at_el (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_aarch64_at_el));

  //  output         dpu_aarch64_state          valid always                                              timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_aarch64_state X or Z")
  u_ovl_intf_x_dpu_aarch64_state (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_aarch64_state));


  //  output         dpu_clear_excl_mon         valid always                                              timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_clear_excl_mon X or Z")
  u_ovl_intf_x_dpu_clear_excl_mon (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_clear_excl_mon));

  //  output         dpu_dbg_dsb_req            valid always                                              timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dbg_dsb_req X or Z")
  u_ovl_intf_x_dpu_dbg_dsb_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dbg_dsb_req));

  //  output         dpu_mmu_on_el1             valid always                                              timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_mmu_on_el1 X or Z")
  u_ovl_intf_x_dpu_mmu_on_el1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_mmu_on_el1));

  //  output         dpu_mmu_on_el2             valid always                                              timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_mmu_on_el2 X or Z")
  u_ovl_intf_x_dpu_mmu_on_el2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_mmu_on_el2));

  //  output         dpu_mmu_on_el3             valid always                                              timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_mmu_on_el3 X or Z")
  u_ovl_intf_x_dpu_mmu_on_el3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_mmu_on_el3));

  //  output         dpu_dcache_on_el1          valid always                                              timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dcache_on_el1 X or Z")
  u_ovl_intf_x_dpu_dcache_on_el1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dcache_on_el1));

  //  output         dpu_dcache_on_el2          valid always                                              timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dcache_on_el2 X or Z")
  u_ovl_intf_x_dpu_dcache_on_el2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dcache_on_el2));

  //  output         dpu_dcache_on_el3          valid always                                              timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dcache_on_el3 X or Z")
  u_ovl_intf_x_dpu_dcache_on_el3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dcache_on_el3));

  //  output         dpu_s2_dcache_on           valid always                                              timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_s2_dcache_on X or Z")
  u_ovl_intf_x_dpu_s2_dcache_on (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_s2_dcache_on));

  //  output         dpu_l1deien                valid initialization_done@1                               timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_l1deien X or Z")
  u_ovl_intf_x_dpu_l1deien (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (initialization_done_reg),
    .test_expr (dpu_l1deien));

  //  output         dpu_disable_dmb            valid initialization_done@1                               timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_disable_dmb X or Z")
  u_ovl_intf_x_dpu_disable_dmb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (initialization_done_reg),
    .test_expr (dpu_disable_dmb));

  //  output         dpu_disable_no_allocate    valid initialization_done@1                               timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_disable_no_allocate X or Z")
  u_ovl_intf_x_dpu_disable_no_allocate (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (initialization_done_reg),
    .test_expr (dpu_disable_no_allocate));

  //  output         dpu_icache_on              valid always                                              timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_icache_on X or Z")
  u_ovl_intf_x_dpu_icache_on (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_icache_on));

  //  output         dpu_ipa_to_pa_en           valid always                                              timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_ipa_to_pa_en X or Z")
  u_ovl_intf_x_dpu_ipa_to_pa_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_ipa_to_pa_en));

  //  output         dpu_default_cacheable      valid always                                              timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_default_cacheable X or Z")
  u_ovl_intf_x_dpu_default_cacheable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_default_cacheable));


  // ------------------------------------------------------
  // Interface description (DPU-Inputs/DCU-Outputs)
  // ------------------------------------------------------

  // dpu_aarch64_state
  // The current exception level is AArch64

  // dpu_aarch64_at_el[3:1]:
  // This signal indicates whether each of EL1-3 is AArch64

  // dcu_ready_cp_iss:
  // Indicates to the DPU that the DCU is ready to accept a
  // transaction that does not need to do an MVA to PA translation.
  // This signal will only be used for CP operations that do not do
  // cache maintenance by address.  If this signal is not asserted and
  // there is a load-store or cp transaction in the Iss stage of the
  // DPU then the DPU must stall.  The signal will be deasserted when
  // the DCU pipeline is stalled and can not accept a new transaction,
  // except on the first cycle when a micro-TLB miss occurred.

  // dcu_ready_iss:
  // Indicates to the DPU that the DCU is ready to accept a
  // transaction that needs to do an MVA to PA translation.
  // If this signal is not asserted and there is a load-store or cp
  // cache maintenance by address transaction in the Iss stage of the
  // DPU then the DPU must stall.  The signal will be deasserted when
  // the DCU pipeline is stalled and can not accept a new transaction,
  // except on the first cycle when a micro-TLB miss occurred.


  // dcu_valid_dc3:
  // Indicates that there is a completed transaction in the DC3 stage
  // and all DC3 stage DCU signals are valid.

  // dcu_ld_data_dc3:
  // Load data from the DCU for the DPU.

  // dcu_strex_okay_dc3:
  // If asserted the store exclusive transaction in DC3 got an EXOKAY
  // response.  If deasserted the response was EXFAIL.

  // dcu_wpt_hit_dc3:
  // If asserted the access hit a watchpoint.

  // dcu_p_abort_dc3:
  // The data being returned caused a precise abort.  If an abort is
  // detected at any point in a multi-cycle access (unaligned,
  // multiple or double), this signal may be asserted part way through
  // the instruction.

  // dcu_p_domain_dc3:
  // This bus is valid when the dcu_p_abort_dc3 signal is asserted and
  // indicates the domain of the fault.

  // dcu_p_fault_dc3:
  // The bits to be written into the fault fields of the DFSR. Bit[6] is
  // EXT, bits[5:0] are Fault Status[5:0]. The encoding is always in LPAE
  // format, if the DPU decides to take the exception as VMSA then it must
  // convert to that format before writing the DFSR. This bus is valid when
  // the dcu_p_abort_dc3 signal is asserted.

  // dcu_p_fault_stage_dc3:
  // The stage of translation which caused the fault reported on
  // dcu_p_fault_dc3. Encoding matches that used on dpu_fault_dc1[8:7]
  // when there is a tranlation fault:
  // 00 => Stage 1 fault
  // 01 => Unused
  // 10 => Stage 2 fault
  // 11 => Stage 2 fault from first stage pagewalk

  // dcu_v2p_lpae_dc3:
  // For V2P instructions, indicates the LPAE/VMSA mode used for the address
  // translation in DC1.

  // dcu_cm_operation_dc3:
  // Indicates the data fault came from a Cache Maintenance Operation or
  // VA tp PA operations for synchronous faults only. This bus is valid
  // when the dcu_p_abort_dc3 signal is asserted.

  // dcu_p_direction_dc3:
  // Indicates whether the transaction that is aborting is a load (1'b0)
  // or a store/CP15 (1'b1).

  // dcu_va_dc3:
  // The virtual address of the transaction in the DC3 stage.
  // Consumed by the ETM.

  // dcu_pa_dc3:
  // The IPA on which a second stage fault occurred, to be written into the
  // HPFAR.

  // dcu_wfx_ready:
  // Indicates that the DCU has no requests in progress and thus is ready
  // to enter WFx state. This may be asserted at any time, even if the DPU
  // has not requested a WFx. It may also be deasserted at any time, even
  // if the DPU has requested a WFx and the DCU was previously ready (this
  // can happen if a new CCB request comes in from the SCU).

  // dcu_dbg_dsb_ack:
  // The DCU has completed the DSB requested by the debug logic.

  // dcu_evnt_dc_access:
  // Event signal for data cache access. A cacheable load or
  // store transaction accessed (or will access) the cache.

  // dcu_evnt_pld_accepted:
  // Event signal for a preload instruction that has been accepted.

  // dcu_evnt_pld_dropped:
  // Event signal for a preload instruction that has been dropped.

  // dcu_ecc_valid:
  // Indicate that there is an ECC error on the L1 data cache RAMs to
  // allow the DPU cp15 CPUMERRSR register and events to be updated.
  // This signal must always be valid (never x) and must be one-shot (single-cycle)
  // for each ECC error, though it is possible to get back-to-back ECC
  // errors.  ECC errors are considered to be both correctable and
  // uncorrectable errors.

  // dcu_ecc_fatal:
  // On a valid ECC error indicate that the error was uncorrectable.
  // Fatal errors are only possible on the Data RAMs since the Dirty and
  // tag RAM is only parity protected (and fatal errors are invisible on
  // parity protected instances).

  // dcu_ecc_ramid:
  // On a valid ECC error indicate which RAM produced the error
  // 2'b00 = Data Tag RAM
  // 2'b01 = Data Data RAM
  // 2'b10 = Data Dirty RAM
  // 2'b11 = illegal, should not be presented to the DPU

  // dcu_ecc_way_bank_id:
  // On a valid ECC error indicate which bank of the RAM produced the error
  // 3'h0 = Bank-0 (Data) or Way-0 (Tag) or Dirty
  // 3'h1 = Bank-1 (Data) or Way-1 (Tag)
  // 3'h2 = Bank-2 (Data) or Way-2 (Tag)
  // 3'h3 = Bank-3 (Data) or Way-3 (Tag)
  // 3'h4 = Bank-4 (Data)
  // 3'h5 = Bank-5 (Data)
  // 3'h6 = Bank-6 (Data)
  // 3'h7 = Bank-7 (Data)

  // dcu_ecc_index:
  // On a vald ECC error indicate the index of the RAM which produced the error.
  // - On a tag error, [7:0] correspond to tagram_addr[7:0], [10:8] are 0
  // - On a dirty error, [8:0] correspond to dirtyram_addr[8:0], [10:9] are 0
  // - On a data error, [10:0] correspond to dataram_addr[10:0]
  // Essentially this bus communicates the unmodified RAM address to allow
  // partners to identify which portion of the RAM has failed.

  // ------------------------------------------------------
  // Interface description (DCU-Inputs/DPU-Outputs)
  // ------------------------------------------------------

  // dpu_valid_iss:
  // The DPU has a valid request in the Iss stage, that has not
  // previously been accepted by the DCU, and the request requires an MVA to
  // PA translation. This could be:
  // A load or store instruction
  // A CP15 cache maintenance by address instruction
  // A CP15 VA to PA translation instruction

  // dpu_valid_cp_iss:
  // The DPU has a valid request in the Iss stage, that has not
  // previously been accepted by the DCU, and the request is a CP14
  // or CP15 register read/write or cache/TLB maintenance operation.

  // dpu_store_iss:
  // The request in the DPU Iss stage is a store if asserted, load if
  // deasserted.
  // This is qualified by the DPU having a valid instruction is iss, so that the
  // STB can use it speculatively without having to qualify it with dpu_valid_iss.

  // dpu_strobe_iss:
  // The byte lane strobes for load and store data.

  // dpu_excl_iss:
  // The request in the DPU Iss stage is an exclusive.

  // dpu_pld_iss:
  // The request in the DPU Iss stage is a preload instruction.
  // If dpu_store_iss is also asserted then it is a PLDW, otherwise PLD.

  // dpu_priv_iss:
  // The request in the DPU Iss stage is a privileged access if
  // asserted or a user access if deasserted.

  // dpu_first_iss:
  // The request in the DPU Iss stage is in the first cycle of the
  // request or the access has crossed a 64-byte boundary (cache line
  // boundary).

  // dpu_second_x64_iss:
  // This signal is only for use by the OVLs in this file.  It is not
  // expected to have any functional significance in the DCU.

  // dpu_length_iss:
  // Number of remaining requests required to complete the
  // transaction.  Must be valid on every cycle of the access.
  // Encoding is one less than the total length, i.e. LDR length is
  // 5'b00000, LDM of 3 length is 5'b00010

  // dpu_size_iss:
  // Indicates the size of the request in the Iss stage.
  // This is the size of transaction that must be performed, which may be
  // different from the element size if this is a NEON load/store.
  // Instructions that use the size WORD encoding include:
  //   - LDR/STR, LDREX/STREX, LDM/STM, all Floating-Point
  // Instructions that use the size DWORD encoding include:
  //   - LDRD/STRD, LDREXD/STREXD, RFE/SRS and NEON Load-Stores
  //
  // Note that architecturally LDRD/STRD are only single copy 64-bit
  // atomic if they are aligned on a 64-bit boundary (but they must be
  // either 32-bit or 64-bit aligned).  LDREXD/STREXD must always be
  // single copy 64-bit atomic.  Architecturally, RFE/SRS only need to
  // be 32-bit aligned, but treating them the same as LDRD/STRD
  // (i.e. 32-bit atomic on 32-bit boundaries, 64-bit atomic on 64-bit
  // boundaries) is a stricter interpretation of the architecture and
  // therefore is allowed.

  // dpu_req_align_iss:
  // Indicates if alignment checking should be forced. This is required
  // for LS exclusives, LDC/STC instructions, certain NEON instructions
  // and can also be explicitly requested via a CP15 bit.

  // dpu_align_size_iss:
  // Indicates the size of boundary to which the access should be
  // aligned. Strict alignment checking requires the DCU to check that
  // the address is aligned to the specified size.
  // The DPU indicates a DCZ instruction by setting align_size_iss to an
  // otherwise unused value.

  // dpu_burst_iss:
  // The request is part of a burst and more beats will be sent

  // dpu_cross_64_iss:
  // The request crosses a 64-bit fetch boundary, and therefore is split
  // into two transactions. Both transactions are marked as cross_64.
  // The DCU must merge the first transaction's data into the second.

  // dpu_cp_op_iss:
  // The type of CP operation or register access.

  // dpu_agu_a_operand_iss, dpu_agu_b_operand_iss, dpu_agu_carry_out_64b_iss:
  // The operands used to form the virtual address for the instruction. These
  // are combined by the DPU and registered to form dpu_va_dc1, however the 
  // individual operands are used in Iss by the cache way tracker in the DCU.

  // The various AT* (V2P*) operations are distinguished by setting dpu_priv_iss
  // and dpu_store_iss appropriately.
  // The variants of *TLBIALL, *TLBIMVA, and *TLBIASID do not need to be
  // distinguished from each other.

  // dpu_exception_level:
  // The current exception level.

  // dpu_va_dc1:
  // The virtual address for the DC1 stage from which the physical
  // address was derived. This is pipelined through the DCU and given
  // back to the DPU in dc3 for the ETM.

  // dpu_utlb_hit_dc1:
  // The micro-TLB hit so the valid instruction that was issued in the
  // Iss stage can proceed.  If there was a micro-TLB miss the
  // instruction proceeds to the end of the DPU pipeline and waits for
  // the DCU to catch up.  If another LS instruction occurs behind the
  // micro-TLB miss it will stall in the DPU Iss stage because the
  // dcu_ready_iss signal will be deasserted.  Once the page has been
  // loaded into the micro-TLB the dpu_utlb_hit_dc1 will be asserted
  // and the request will continue down the DCU pipeline.

  // dpu_utlb_hit_entry_dc1:
  // Which micro-TLB entry hit

  // dpu_pa_dc1:
  // The physical address for memories in the DC1 stage.  The address
  // is generated in the DPU as the micro-TLB resides partially in the
  // Iss stage and partially in the DC1 stage for timing reasons.

  // dpu_ns_dsc_dc1:
  // The page descriptor in the uTLB refers to non-secure memory if asserted.

  // dpu_attributes_dc1:
  // On successful translations, the page table attributes from the micro-TLB.
  //
  // Page table attributes encoding:
  // Bits 12:5 Memory Type
  // Bits 4:3  Second stage access permissions/Hyp mode first stage
  //           permissions.
  // Bits 2:0  First stage access permissions
  //
  // Bit 2 1 0
  //     0 0 0 No access
  //     0 0 1 RW priv, no access user
  //     0 1 0 RW priv, RO user
  //     0 1 1 RW priv, RW user
  //     1 0 0 Fetched in EL2/AA64 EL3 mode*
  //     1 0 1 RO priv, no access user
  //     1 1 0 RO priv, RO user
  //     1 1 1 RO priv, RO user
  //
  // * In EL2/AA64 EL3, bits 2:0 are 3'b100, and there is only one stage
  //   of permissions checking. The first stage permissions are encoded on
  //   bits 4:3 using the same encoding as for bits 2:0, with the lowest
  //   bit implicitly set.
  //
  // Bit 4 3
  //     0 0 No access
  //     0 1 RO
  //     1 0 WO
  //     1 1 RW
  //
  // Bits 12:5 defined in cortexa53params
  //

  // dpu_fault_dc1:
  // On aborts, describes the type of fault.
  //
  // Fault type encoding:
  // Bits 8:7 Stage of translation causing fault
  // Bits 6:0 Fault encoding in LPAE format
  //
  // Bit  8 7
  //      0 0 Fault in first stage of translation
  //      1 0 Fault in second stage of translation
  //      1 1 Fault from second stage fault in first stage pagewalk
  //      0 1 Unused
  //

  // dpu_level_dc1:
  // The page size found by a translation, or the level of the translation.
  // The format depends on the current mode of the uTLB (VMSA/LPAE), as
  // indicated by the TLB.
  // Used by V2P* instructions to write the SS bit in the PAR, and for
  // selecting the correct fault type on permission faults.
  // The level for each stage of translation is encoded as:
  // dpu_level_dc1[1:0] = S1 Level
  // dpu_level_dc1[3:2] = S2 Level
  //
  // The S2 level will always be in LPAE format if there was a S2 translation,
  // otherwise it will be 2'b00.
  //
  // Encoding:


  // dpu_abort_dc1:
  // A fault has been detected during the translation of the virtual address
  // in DC1.

  // dpu_stack_align_expt_dc1:
  // The transaction address has been generated using a misaligned stack 
  // pointer. The DCU should return a STACK_ALIGN abort in DC3. Should be
  // ignored by the DCU on transactions which do not have a valid VA (as
  // indicated by dpu_valid_iss)

  // dpu_domain_dc1:
  // The domain in which the fault indicated by dpu_abort_dc1 occurred.

  // dpu_ready_wr:
  // The LS instruction is in the Wr stage of the DPU and the DPU is
  // ready to retire the transaction.

  // dpu_cp_data_wr:
  // CP15 write data for the DCU to distribute to other units.  Will
  // only be used if a valid MCR operation is in the Wr stage and
  // writes to a CP15 register outside the DPU.

  // dpu_st_data_wr:
  // Store data. For normal stores the DPU sends the data directly to
  // the STB, but for memory mapped accesses to GIC registers the DCU
  // registers the data and passes it on to the GIC.

  // dpu_kill_wr:
  // Kill or flush the request in the Wr stage.  Caused by a general
  // flush (asserted with dpu_flush).

  // dpu_cc_fail_wr:
  // ccfail the request in the Wr stage.  Caused only by an instruction that is ccfailed.

  // dpu_ready_cc_fail_wr:
  // Timing optimized signal that combines dpu_ready_wr and dpu_cc_fail_wr:
  // The LS instruction is in the Wr stage of the DPU and the DPU is
  // ready to retire the transaction, which has also CC failed.

  // dpu_ready_cc_pass_wr:
  // Timing optimized signal that combines dpu_ready_wr and dpu_cc_fail_wr:
  // The LS instruction is in the Wr stage of the DPU and the DPU is
  // ready to retire the transaction, which has also CC passed.

  // dpu_flush:
  // Flush all outstanding memory requests except for the one in Wr.

  // dpu_ns_state:
  // The DPU is in a non-secure state. This is only true if the NS bit is
  // set and the DPU is not in monitor mode.

  // dpu_scr_el3_ns:
  // The value from the SCR_EL3.NS bit

  // dpu_dbg_dsb_req:
  // The debug logic is requesting a DSB to drain all buffers.

  // dpu_s2_dcache_on:
  // Enable the data cache for Stage 2 translations.

  // dpu_l1deien:
  // Controlled by the CP15 auxiliary register.

  // dpu_disable_dmb:
  // Controlled by the CP15 auxiliary register.

  // dpu_disable_no_allocate:
  // Controlled by the CP15 auxiliary register.

  // dpu_ipa_to_pa_en:
  // The HCR.VM bit is set, enabling second stage translations.

  // dpu_default_cacheable:
  // The HCR.DC bit is set, so the default memory type is cacheable.
  // When this is set and HCR.VM is clear, the system behaves as if HCR.VM were asserted.

  // ------------------------------------------------------
  // Interface OVLs
  // ------------------------------------------------------

  // DPU must not initiate a CP15 instruction when the DCU is initiating
  // automatic invalidate on deassertion of reset

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~initialization_done  => ~dpu_valid_cp_iss")
  u_ovl_intf_assert_8e41525ce72478d06d624c62520f6c2635177973 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~initialization_done ),
    .consequent_expr (~dpu_valid_cp_iss));


  // ------------------------------------------------------
  // Iss and dc3 handshake rules
  // ------------------------------------------------------

  // To avoid a snake path, the DPU must factor a uTLB miss in locally
  assign utlb_stall  = entering_dcu_reg & dpu_valid_iss_reg & ~dpu_utlb_hit_dc1;

  // After the initial uTLB miss, the DCU registers that it is stalling waiting
  // for a translation, and stops stalling when it sees the TLB write the
  // uTLB, assuming that this means the uTLB will hit on the next cycle.


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "tlb_d_utlb_enable@1  => dpu_utlb_hit_dc1")
  u_ovl_intf_assert_478da5f3df1915bd7acbd543d66c307f1cb2426d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_d_utlb_enable_reg ),
    .consequent_expr (dpu_utlb_hit_dc1));


  // If the uTLB misses, it can only hit on the same instruction after being
  // updated by the TLB. Note that some test benches can drive a hit for an
  // instruction which does not enter DC1 because it is flushed on the cycle
  // it is accepted. The behaviour of the uTLB does not matter in this case,
  // so the assert allows a hit in this case.
  assign entering_dcu_noflush  = (dpu_valid_iss ? dcu_ready_iss : (dpu_valid_cp_iss & dcu_ready_cp_iss)) & ~utlb_stall;


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dpu_utlb_hit_dc1@1 & dpu_utlb_hit_dc1  => tlb_d_utlb_enable@1 | entering_dcu_noflush@1")
  u_ovl_intf_assert_7af42b782e431ed1d0477b71cd4cb95a8c6778ac (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dpu_utlb_hit_dc1_reg & dpu_utlb_hit_dc1 ),
    .consequent_expr (tlb_d_utlb_enable_reg | entering_dcu_noflush_reg));


  // Once the uTLB has hit, it must continue to hit for the same instruction

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_utlb_hit_dc1@1 & ~dpu_utlb_hit_dc1  => entering_dcu_noflush@1")
  u_ovl_intf_assert_6671741cf141b399b8ba4ec210aec9dd54ce6157 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_utlb_hit_dc1_reg & ~dpu_utlb_hit_dc1 ),
    .consequent_expr (entering_dcu_noflush_reg));


  // A transaction enters dc1 when there is a valid transaction in iss and the
  // DCU can accept that type of transaction, and the previous transaction is
  // not stalling in dc1 due to the first cycle of a uTLB miss.
  assign entering_dcu  = (dpu_valid_iss ? dcu_ready_iss : (dpu_valid_cp_iss & dcu_ready_cp_iss)) & ~dpu_flush & ~utlb_stall;

  // DPU can not indicate hit in uTLB entry which does not exist

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1  => dpu_utlb_hit_entry_dc1 < 4'd10")
  u_ovl_intf_assert_33605eac6f1e8246e6669a68c896c01e17b55ced (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg ),
    .consequent_expr (dpu_utlb_hit_entry_dc1 < 4'd10));


  // The following combinations of dpu_ready_wr, dpu_kill_wr, dpu_cc_fail_wr and
  // dpu_flush are possible and have the meaning shown:

  // ready_wr kill_wr cc_fail_wr flush

  // 0        0       0          0     IDLE
  // 1        0       0          0     COMMIT
  // 1        0       1          0     CCFAIL
  // 1        1       0          1     Exception (DataAbort, FIQ, IRQ, null pointer check)
  // 1        1       1          1        "
  // 0        1       0          1     Non-LSU exception
  // 0        1       1          1        "
  // 0        0       0          1     Non-LSU with branch
  // 0        0       1          1        "
  // 1        0       0          1     Load (not multiple or 1st cycle of cross-64) dual-issued with branch
  // 1        0       1          1     Ccfailing load (not multiple or 1st cycle of cross-64) dual-issued with branch
  // 0        0       1          0     Non-LSU CCFAIL (ignored by DCU)
  // 0        1       0          0     Not possible
  // 0        1       1          0     Not possible
  // 1        1       1          0     Not possible
  // 1        1       0          0     Not possible

  assign kill_or_cc_fail_wr  = dpu_kill_wr | (dpu_cc_fail_wr & dpu_ready_wr);

  // Can't have a dpu_kill_wr without a dpu_flush


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_kill_wr  => dpu_flush")
  u_ovl_intf_assert_e39ed8a2d4b36c61f8ede86260c0fe163012702d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_kill_wr ),
    .consequent_expr (dpu_flush));


  // DPU may flush its own pipeline one cycle after indicating flush and kill
  // to the DCU and therefore may indicate that there is a load / store in Wr
  // when the DCU pipeline is empty
  assign dpu_ready_wr_real  = dpu_ready_wr & ~(dpu_flush_reg & kill_or_cc_fail_wr_reg);

  // A transaction leaves the DCU when both the DPU and DCU are ready to
  // retire it, or it leaves immediately if the DPU kills/ccfails it.
  assign leaving_dcu  = dpu_ready_wr_real & (dcu_valid_dc3 | kill_or_cc_fail_wr);

  // Once committed, a transaction must remain committed until it retires or is flushed.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_ready_wr_real@1 & ~leaving_dcu@1  => dpu_ready_wr")
  u_ovl_intf_assert_89db85596d8a104cebac6ed4e01c3a81f7c6017c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_ready_wr_real_reg & ~leaving_dcu_reg ),
    .consequent_expr (dpu_ready_wr));


  // A transaction cannot ccfail after it has been committed.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_ready_wr_real@1 & ~dpu_cc_fail_wr@1 & ~leaving_dcu@1  => ~dpu_cc_fail_wr")
  u_ovl_intf_assert_81e6d0c4c7a4a0322860fc90bdcd6a9a2e786222 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_ready_wr_real_reg & ~dpu_cc_fail_wr_reg & ~leaving_dcu_reg ),
    .consequent_expr (~dpu_cc_fail_wr));


  // A transaction cannot be killed after it has been committed.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_ready_wr_real@1 & ~dpu_kill_wr@1 & ~leaving_dcu@1  => ~dpu_kill_wr")
  u_ovl_intf_assert_e1f3cde7700a5cf393ca1d1262792f52a3f1f0a8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_ready_wr_real_reg & ~dpu_kill_wr_reg & ~leaving_dcu_reg ),
    .consequent_expr (~dpu_kill_wr));


  // Treat the DCU pipe as a FIFO

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    valid0 <= 1'b0;
  else
    valid0 <= leaving_dcu ? ((valid1 | entering_dcu) & ~dpu_flush) : (entering_dcu | (valid0 & ~(dpu_flush & ~dpu_ready_wr)));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    valid1 <= 1'b0;
  else
    valid1 <= (leaving_dcu ? (valid2 | (valid1 & entering_dcu)) : (valid1 | (entering_dcu & valid0))) & ~dpu_flush;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    valid2 <= 1'b0;
  else
    valid2 <= (leaving_dcu ? (valid2 & entering_dcu) : (valid2 | (entering_dcu & valid1))) & ~dpu_flush;


  assign en0  = ~valid0 | leaving_dcu;
  assign en1  = ~valid1 | leaving_dcu;
  assign en2  = ~valid2 | leaving_dcu;

  assign v2p_iss  = (((dpu_cp_op_iss == `CA53_CPOP_ATS1C) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS12NSO) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS1H) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS1E01) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS12E01) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS1E2) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS1E3)));

  assign clrex_iss  = (dpu_cp_op_iss == `CA53_CPOP_CLREX);

  assign set_way_iss  = (((dpu_cp_op_iss == `CA53_CPOP_DCISW) | (dpu_cp_op_iss ==  `CA53_CPOP_DCCISW) | (dpu_cp_op_iss ==  `CA53_CPOP_DCCSW)));

  // Pipeline whether it's a load (overridden if a V2P because store_iss is then used to indicate
  // whether the translation is for a read or write. V2P always does a CP register write). Also
  // needed on set/way ops, as cp_data_wr is used in that case to indicate the way.
  assign valid_cp_wr  = (dpu_valid_cp_iss & ~(((dpu_cp_op_iss == `CA53_CPOP_CLREX) | (dpu_cp_op_iss ==   `CA53_CPOP_DMBNS) | (dpu_cp_op_iss ==  `CA53_CPOP_DMBIS) | (dpu_cp_op_iss ==  `CA53_CPOP_DMBOS) | (dpu_cp_op_iss ==  `CA53_CPOP_DMBSY) | (dpu_cp_op_iss ==  `CA53_CPOP_DMBNSHLD) | (dpu_cp_op_iss ==  `CA53_CPOP_DMBISHLD) | (dpu_cp_op_iss ==  `CA53_CPOP_DMBOSHLD) | (dpu_cp_op_iss ==  `CA53_CPOP_DMBLD) | (dpu_cp_op_iss ==  `CA53_CPOP_DMBNSST) | (dpu_cp_op_iss ==  `CA53_CPOP_DMBISST) | (dpu_cp_op_iss ==  `CA53_CPOP_DMBOSST) | (dpu_cp_op_iss ==  `CA53_CPOP_DMBSYST)))) & ~dpu_flush & (dpu_store_iss | v2p_iss | set_way_iss);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    valid_cp_wr0 <= 1'b0;
  else if (en0)
    valid_cp_wr0 <= (leaving_dcu & valid1) ? valid_cp_wr1 : valid_cp_wr;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    valid_cp_wr1 <= 1'b0;
  else if (en1)
    valid_cp_wr1 <= (leaving_dcu & valid2) ? valid_cp_wr2 : valid_cp_wr;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    valid_cp_wr2 <= 1'b0;
  else if (en2)
    valid_cp_wr2 <= valid_cp_wr;


  assign valid_ld     = ( dpu_valid_cp_iss | dpu_valid_iss) & ~dpu_flush & ~dpu_store_iss & ~dpu_pld_iss & ~(dpu_valid_cp_iss & (v2p_iss | clrex_iss));

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    valid_ld0 <= 1'b0;
  else if (en0)
    valid_ld0 <= (leaving_dcu & valid1) ? valid_ld1 : valid_ld;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    valid_ld1 <= 1'b0;
  else if (en1)
    valid_ld1 <= (leaving_dcu & valid2) ? valid_ld2 : valid_ld;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    valid_ld2 <= 1'b0;
  else if (en2)
    valid_ld2 <= valid_ld;


  // Pipeline whether it's a DBGDRx read, because X-checking on ld_data_dc3 is suppressed in
  // that case, as the unit level test benches can return X on cache debug ops, when the op
  // is to a RAM which isn't initialised yet.
  assign valid_dbgdr  = valid_ld & (dpu_valid_cp_iss & (((dpu_cp_op_iss == `CA53_CPOP_CDBGDR0) | (dpu_cp_op_iss ==  `CA53_CPOP_CDBGDR1) | (dpu_cp_op_iss ==  `CA53_CPOP_CDBGDR2))));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    valid_dbgdr0 <= 1'b0;
  else if (en0)
    valid_dbgdr0 <= (leaving_dcu & valid1) ? valid_dbgdr1 : valid_dbgdr;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    valid_dbgdr1 <= 1'b0;
  else if (en1)
    valid_dbgdr1 <= (leaving_dcu & valid2) ? valid_dbgdr2 : valid_dbgdr;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    valid_dbgdr2 <= 1'b0;
  else if (en2)
    valid_dbgdr2 <= valid_dbgdr;


  // Only load instructions should return ECC errors
  assign valid_ldr_or_pld    = dpu_valid_iss & ~dpu_flush & (~dpu_store_iss | dpu_pld_iss);

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    valid_ldr_or_pld0 <= 1'b0;
  else if (en0)
    valid_ldr_or_pld0 <= (leaving_dcu & valid1) ? valid_ldr_or_pld1 : valid_ldr_or_pld;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    valid_ldr_or_pld1 <= 1'b0;
  else if (en1)
    valid_ldr_or_pld1 <= (leaving_dcu & valid2) ? valid_ldr_or_pld2 : valid_ldr_or_pld;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    valid_ldr_or_pld2 <= 1'b0;
  else if (en2)
    valid_ldr_or_pld2 <= valid_ldr_or_pld;



  assert_implication #(`OVL_FATAL, INOPTIONS, "dpu_ready_wr_real & dcu_valid_dc3 & dcu_ecc_err_dc3  => valid_ldr_or_pld0")
  u_ovl_intf_assume_6e579a1a0b5ff9a9d03fd4e1facb7c3d6c2fe9b5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_ready_wr_real & dcu_valid_dc3 & dcu_ecc_err_dc3 ),
    .consequent_expr (valid_ldr_or_pld0));


  // Next count of transactions assuming no flushes.
  assign next_trans_no_flush  = ((entering_dcu & ~leaving_dcu) ? trans_in_dcu + 2'b01 : (~entering_dcu & leaving_dcu) ? trans_in_dcu - 2'b01 : trans_in_dcu);

  // Next count of transactions assuming a flush.
  // Any transaction in wr is not flushed unless explicitly killed.
  assign next_trans_flush  = (dpu_ready_wr_real & ~leaving_dcu) ? 2'b01 : 2'b00;

  // Count the number of transactions in progress in the DCU.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    trans_in_dcu <= 2'b00;
  else
    trans_in_dcu <= dpu_flush ? next_trans_flush : next_trans_no_flush;


  // Sanity check the fifo matches the handshake count

  assert_always #(`OVL_FATAL, OUTOPTIONS, "(valid0 + valid1 + valid2) == trans_in_dcu")
  u_ovl_intf_assert_f852214de929f81a00be3ab1f681451d1674641e (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ((valid0 + valid1 + valid2) == trans_in_dcu));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "leaving_dcu  => valid0")
  u_ovl_intf_assert_0e94d2aa4efda89ffb2db8b6a7a9f2b52dce0374 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (leaving_dcu ),
    .consequent_expr (valid0));


  // Assume entry in DCU

  assert_implication #(`OVL_FATAL, INOPTIONS, "entering_dcu  => (trans_in_dcu < 2'b11) | leaving_dcu")
  u_ovl_intf_assume_9f65474df925f4dea45ddcd55059ed595e18fe81 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu ),
    .consequent_expr ((trans_in_dcu < 2'b11) | leaving_dcu));


  // If the DCU can accept a normal load or store then it must also be able
  // to accept a CP access.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_ready_iss  => dcu_ready_cp_iss")
  u_ovl_intf_assume_63c21764ead8d7413aff490ec53902f79d19274b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_ready_iss ),
    .consequent_expr (dcu_ready_cp_iss));


  // The DPU must not present a new transaction the cycle after a flush.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_flush@1  => ~(dpu_valid_cp_iss | dpu_valid_iss) | dpu_flush")
  u_ovl_intf_assert_bc4832f1c10644959e91cd3d5fffed85f20bfde4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_flush_reg ),
    .consequent_expr (~(dpu_valid_cp_iss | dpu_valid_iss) | dpu_flush));


  // The DPU cannot assert ready if there are no transactions in progress.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(trans_in_dcu == 2'b00)  => ~dpu_ready_wr_real")
  u_ovl_intf_assert_7194fa293823791cc8abb335fbc40d6870dbb1fb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((trans_in_dcu == 2'b00) ),
    .consequent_expr (~dpu_ready_wr_real));


  // The DPU cannot assert ready the cycle after the transaction was in iss.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(trans_in_dcu@1 == 2'b00)  => ~dpu_ready_wr_real")
  u_ovl_intf_assert_c9cb915ac358a08d5a4440ab1701a7c5e6dd383e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((trans_in_dcu_reg == 2'b00) ),
    .consequent_expr (~dpu_ready_wr_real));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(trans_in_dcu@1 == 2'b01) & leaving_dcu@1  => ~dpu_ready_wr_real")
  u_ovl_intf_assert_fb69403380652be4230a9abca402ac5292b8c9cc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((trans_in_dcu_reg == 2'b01) & leaving_dcu_reg ),
    .consequent_expr (~dpu_ready_wr_real));


  // The DCU cannot assert ready if there are no transactions in progress.

  assert_implication #(`OVL_FATAL, INOPTIONS, "(trans_in_dcu == 2'b00)  => ~dcu_valid_dc3")
  u_ovl_intf_assume_f779624d2ec211684e45a9036d58dbf93fbaaaab (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((trans_in_dcu == 2'b00) ),
    .consequent_expr (~dcu_valid_dc3));


  // The DCU cannot contain more than 3 transactions.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(trans_in_dcu == 2'b11) & ~leaving_dcu  => ~entering_dcu")
  u_ovl_intf_assert_d41e26a3f9ec869c0affe4a0f5c1d14dd68dc7e2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((trans_in_dcu == 2'b11) & ~leaving_dcu ),
    .consequent_expr (~entering_dcu));


  // The DPU cannot change exception level or aarch64 state when there is a
  // transaction in the DCU.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_aarch64_state   != dpu_aarch64_state@1    => dpu_flush ? (next_trans_flush == 2'b00) : trans_in_dcu == 2'b00")
  u_ovl_intf_assert_07d1240f2b58ac0b6ea90ae199572be814cfa70e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_aarch64_state   != dpu_aarch64_state_reg   ),
    .consequent_expr (dpu_flush ? (next_trans_flush == 2'b00) : trans_in_dcu == 2'b00));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_exception_level != dpu_exception_level@1  => dpu_flush ? (next_trans_flush == 2'b00) : trans_in_dcu == 2'b00")
  u_ovl_intf_assert_d35e89e64eae02c70d434528b69948ff76d25344 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_exception_level != dpu_exception_level_reg ),
    .consequent_expr (dpu_flush ? (next_trans_flush == 2'b00) : trans_in_dcu == 2'b00));


  // ------------------------------------------------------
  // Iss/dc1 signal rules
  // ------------------------------------------------------

  assign dpu_valid_any_iss  = (dpu_valid_iss | dpu_valid_cp_iss) & ~dpu_flush;

  // The DPU cannot change the type of access if it stalls in iss. (Note that
  // cannot have assertion on dpu_cross_64_iss because this may change due to
  // opposite condition code cancelling in the DPU.)

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_any_iss & dpu_valid_any_iss@1 & ~entering_dcu@1  => dpu_store_iss       == dpu_store_iss@1")
  u_ovl_intf_assert_6a9992709d2f1ecee72afd872995dd4214598c31 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_any_iss & dpu_valid_any_iss_reg & ~entering_dcu_reg ),
    .consequent_expr (dpu_store_iss       == dpu_store_iss_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_any_iss & dpu_valid_any_iss@1 & ~entering_dcu@1  => dpu_excl_iss        == dpu_excl_iss@1")
  u_ovl_intf_assert_11656d79dd80966d4cab5fb03fcb5e88697e7973 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_any_iss & dpu_valid_any_iss_reg & ~entering_dcu_reg ),
    .consequent_expr (dpu_excl_iss        == dpu_excl_iss_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_any_iss & dpu_valid_any_iss@1 & ~entering_dcu@1  => dpu_pld_iss         == dpu_pld_iss@1")
  u_ovl_intf_assert_b26a6c9490c477447d684f009c0cf68327fb7818 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_any_iss & dpu_valid_any_iss_reg & ~entering_dcu_reg ),
    .consequent_expr (dpu_pld_iss         == dpu_pld_iss_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_any_iss & dpu_valid_any_iss@1 & ~entering_dcu@1  => dpu_priv_iss        == dpu_priv_iss@1")
  u_ovl_intf_assert_1c23d3333a083976f827427989cce33f2b489ff1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_any_iss & dpu_valid_any_iss_reg & ~entering_dcu_reg ),
    .consequent_expr (dpu_priv_iss        == dpu_priv_iss_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_any_iss & dpu_valid_any_iss@1 & ~entering_dcu@1  => dpu_first_iss       == dpu_first_iss@1")
  u_ovl_intf_assert_ba9f656b42bffde4c230f076952c284dd4d8669a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_any_iss & dpu_valid_any_iss_reg & ~entering_dcu_reg ),
    .consequent_expr (dpu_first_iss       == dpu_first_iss_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_any_iss & dpu_valid_any_iss@1 & ~entering_dcu@1  => dpu_force_first_iss == dpu_force_first_iss@1")
  u_ovl_intf_assert_50aefd34023e515b846939133d1789b4ddc51c5a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_any_iss & dpu_valid_any_iss_reg & ~entering_dcu_reg ),
    .consequent_expr (dpu_force_first_iss == dpu_force_first_iss_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_any_iss & dpu_valid_any_iss@1 & ~entering_dcu@1  => dpu_length_iss      == dpu_length_iss@1")
  u_ovl_intf_assert_eb94f025c302e46649ec4554054fe3c03e2e6040 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_any_iss & dpu_valid_any_iss_reg & ~entering_dcu_reg ),
    .consequent_expr (dpu_length_iss      == dpu_length_iss_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_any_iss & dpu_valid_any_iss@1 & ~entering_dcu@1  => dpu_size_iss        == dpu_size_iss@1")
  u_ovl_intf_assert_6924a4cc6f40ac0c266199f43d086b231c436f70 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_any_iss & dpu_valid_any_iss_reg & ~entering_dcu_reg ),
    .consequent_expr (dpu_size_iss        == dpu_size_iss_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_any_iss & dpu_valid_any_iss@1 & ~entering_dcu@1  => dpu_req_align_iss   == dpu_req_align_iss@1")
  u_ovl_intf_assert_312032e9fb7a6be099cbe1a2b8c8f9e5da3b7500 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_any_iss & dpu_valid_any_iss_reg & ~entering_dcu_reg ),
    .consequent_expr (dpu_req_align_iss   == dpu_req_align_iss_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_any_iss & dpu_valid_any_iss@1 & ~entering_dcu@1  => dpu_align_size_iss  == dpu_align_size_iss@1")
  u_ovl_intf_assert_fd027d0f6e7e88f28b569cf954bd9dc44c4dc237 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_any_iss & dpu_valid_any_iss_reg & ~entering_dcu_reg ),
    .consequent_expr (dpu_align_size_iss  == dpu_align_size_iss_reg));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_cp_iss & ~dpu_flush & dpu_valid_cp_iss@1 & ~dpu_flush@1 & ~entering_dcu@1  => dpu_cp_op_iss == dpu_cp_op_iss@1")
  u_ovl_intf_assert_d7b5e4e75cda10125af5d6bfe5a5580291443016 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_cp_iss & ~dpu_flush & dpu_valid_cp_iss_reg & ~dpu_flush_reg & ~entering_dcu_reg ),
    .consequent_expr (dpu_cp_op_iss == dpu_cp_op_iss_reg));


  // A preload cannot be a CP op, exclusive or LDAR/STLR

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_any_iss & dpu_pld_iss  => ~(dpu_valid_cp_iss | dpu_excl_iss | dpu_ldar_stlr_iss)")
  u_ovl_intf_assert_0b5ce3fb5eaed64f7882d1086cdd97394111ce5c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_any_iss & dpu_pld_iss ),
    .consequent_expr (~(dpu_valid_cp_iss | dpu_excl_iss | dpu_ldar_stlr_iss)));


  // First should be high for any access smaller than word (which could be LDM/STM/LDP/STP) that is not 2nd half of cross-64

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(dpu_valid_any_iss & (dpu_size_iss < `CA53_SIZE_WORD))  => (dpu_first_iss | (dpu_cross_64_iss & dpu_second_x64_iss))")
  u_ovl_intf_assert_c616349070e642b516e8dc13e3dd16dca3c11940 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((dpu_valid_any_iss & (dpu_size_iss < `CA53_SIZE_WORD)) ),
    .consequent_expr ((dpu_first_iss | (dpu_cross_64_iss & dpu_second_x64_iss))));


  // Length should be at least 1 for doublewords

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & ~dpu_valid_cp_iss & (dpu_size_iss == `CA53_SIZE_DWORD)  => dpu_length_iss > 5'b00000")
  u_ovl_intf_assert_74eb900d97b13636d2d97f2f68346e2020ebe1cc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & ~dpu_valid_cp_iss & (dpu_size_iss == `CA53_SIZE_DWORD) ),
    .consequent_expr (dpu_length_iss > 5'b00000));


  // The dpu_first_iss signal must be asserted when accessing a new cache line

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & (dpu_va_dc1[5:3] == 3'b000)  => dpu_first_iss@1")
  u_ovl_intf_assert_ee74b4c5b77cda5ac2060cb39394ffd174648db5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & (dpu_va_dc1[5:3] == 3'b000) ),
    .consequent_expr (dpu_first_iss_reg));


  // The dpu_first_iss signal must always be asserted on CP ops

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_cp_iss  => dpu_first_iss")
  u_ovl_intf_assert_bea30e26326e5e8f274e86710945004c3d55d311 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_cp_iss ),
    .consequent_expr (dpu_first_iss));


  // The top bits of the VA must be zero in AA32 and when doing an address
  // translation instruction for an AA32 exception level in AA64.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & dpu_valid_iss@1 & (~dpu_aarch64_state | (dpu_valid_cp_iss@1 & (((dpu_cp_op_iss@1 in [`CA53_CPOP_ATS1E01, `CA53_CPOP_ATS12E01]) & ~dpu_aarch64_at_el[1]) | ((dpu_cp_op_iss@1 in [`CA53_CPOP_ATS1E2                      ]) & ~dpu_aarch64_at_el[2]))))  => (dpu_va_dc1[63:32] == {32{1'b0}})")
  u_ovl_intf_assert_feeeb611d8bd3dca659386a2a083838f21848112 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & dpu_valid_iss_reg & (~dpu_aarch64_state | (dpu_valid_cp_iss_reg & (((((dpu_cp_op_iss_reg == `CA53_CPOP_ATS1E01) | (dpu_cp_op_iss_reg ==  `CA53_CPOP_ATS12E01))) & ~dpu_aarch64_at_el[1]) | ((((dpu_cp_op_iss_reg == `CA53_CPOP_ATS1E2                      ))) & ~dpu_aarch64_at_el[2])))) ),
    .consequent_expr ((dpu_va_dc1[63:32] == {32{1'b0}})));


  // When transferring more than a word of data (as indicated by the length),
  // either req_align must be set (for an LSM), or the size must be Dword (for
  // an LDP/STP)

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu & dpu_valid_iss & ~dpu_valid_cp_iss & (dpu_length_iss > 5'b00000)  => dpu_req_align_iss | (dpu_size_iss == `CA53_SIZE_DWORD)")
  u_ovl_intf_assert_a12bd4a2f9f737286595a23c617ae9a70ca34380 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu & dpu_valid_iss & ~dpu_valid_cp_iss & (dpu_length_iss > 5'b00000) ),
    .consequent_expr (dpu_req_align_iss | (dpu_size_iss == `CA53_SIZE_DWORD)));


  // The dpu_burst_iss signal should be set on all but the last beat of a multiple
  // and the first part of a cross 64

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & (((dpu_length_iss[4:2] > 3'b000) | ((dpu_length_iss[1] != 1'b0) & ~dpu_store_iss)) | (dpu_cross_64_iss & ~dpu_second_x64_iss))  => dpu_burst_iss")
  u_ovl_intf_assert_6d083f55a32653e57f9ce6838c689e9660310286 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & (((dpu_length_iss[4:2] > 3'b000) | ((dpu_length_iss[1] != 1'b0) & ~dpu_store_iss)) | (dpu_cross_64_iss & ~dpu_second_x64_iss)) ),
    .consequent_expr (dpu_burst_iss));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & ~dpu_store_iss@1 & (dpu_length_iss@1 == 5'b00001) & (dpu_size_iss@1 == `CA53_SIZE_WORD) & dpu_va_dc1[2]  => dpu_burst_iss@1")
  u_ovl_intf_assert_f3c48f4e50431c355beb378c10121879fc6cd365 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & ~dpu_store_iss_reg & (dpu_length_iss_reg == 5'b00001) & (dpu_size_iss_reg == `CA53_SIZE_WORD) & dpu_va_dc1[2] ),
    .consequent_expr (dpu_burst_iss_reg));


  // The only CP op which can set burst_iss is the DMB for an STLR

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_cp_iss & dpu_burst_iss  => dpu_ldar_stlr_iss")
  u_ovl_intf_assert_8f8ec0973c59a998c4b53145ae0e9a737e4d99e9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_cp_iss & dpu_burst_iss ),
    .consequent_expr (dpu_ldar_stlr_iss));


  // Any instruction with size Word and length 0 must only access one word
  // - Only 4 strobes must be set, but they could be any four consecutive strobes, as they
  // will be shifted by the alignment specified by the base register.
  // - If the access is unaligned, less than 4 strobes could be set if the access crosses a
  // 64-bit boundary

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu & (dpu_size_iss == `CA53_SIZE_WORD) & (dpu_length_iss == 0) & dpu_first_iss & ~dpu_second_x64_iss  => dpu_strobe_iss in [16'b0000000000001111, 16'b0000000000011110, 16'b0000000000111100, 16'b0000000001111000, 16'b0000000011110000, 16'b0000000111100000, 16'b0000001111000000, 16'b0000011110000000, 16'b0000111100000000, 16'b0001111000000000, 16'b0011110000000000, 16'b0111100000000000, 16'b1111000000000000, 16'b1110000000000000, 16'b1100000000000000, 16'b1000000000000000, 16'b0000000011100000,    16'b0000000011000000,    16'b0000000010000000]")
  u_ovl_intf_assert_21c904e34c88164429182f56d95f02d1bf460ee2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu & (dpu_size_iss == `CA53_SIZE_WORD) & (dpu_length_iss == 0) & dpu_first_iss & ~dpu_second_x64_iss ),
    .consequent_expr (((dpu_strobe_iss == 16'b0000000000001111) | (dpu_strobe_iss ==  16'b0000000000011110) | (dpu_strobe_iss ==  16'b0000000000111100) | (dpu_strobe_iss ==  16'b0000000001111000) | (dpu_strobe_iss ==  16'b0000000011110000) | (dpu_strobe_iss ==  16'b0000000111100000) | (dpu_strobe_iss ==  16'b0000001111000000) | (dpu_strobe_iss ==  16'b0000011110000000) | (dpu_strobe_iss ==  16'b0000111100000000) | (dpu_strobe_iss ==  16'b0001111000000000) | (dpu_strobe_iss ==  16'b0011110000000000) | (dpu_strobe_iss ==  16'b0111100000000000) | (dpu_strobe_iss ==  16'b1111000000000000) | (dpu_strobe_iss ==  16'b1110000000000000) | (dpu_strobe_iss ==  16'b1100000000000000) | (dpu_strobe_iss ==  16'b1000000000000000) | (dpu_strobe_iss ==  16'b0000000011100000) | (dpu_strobe_iss ==     16'b0000000011000000) | (dpu_strobe_iss ==     16'b0000000010000000))));


  // The strobes on stores must always be sequential.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[0]  & ~dpu_strobe_iss[1]   => ~|dpu_strobe_iss[15:2]")
  u_ovl_intf_assert_141745597fd4111c3ba8fa65d3a9edd1de4c71fb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[0]  & ~dpu_strobe_iss[1]  ),
    .consequent_expr (~|dpu_strobe_iss[15:2]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[1]  & ~dpu_strobe_iss[2]   => ~|dpu_strobe_iss[15:3]")
  u_ovl_intf_assert_44f490a5a7a1cd94c5cabed78e0aa0ea6f806383 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[1]  & ~dpu_strobe_iss[2]  ),
    .consequent_expr (~|dpu_strobe_iss[15:3]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[2]  & ~dpu_strobe_iss[3]   => ~|dpu_strobe_iss[15:4]")
  u_ovl_intf_assert_349bef5853a23b4a76c85def6de1e113a1a79669 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[2]  & ~dpu_strobe_iss[3]  ),
    .consequent_expr (~|dpu_strobe_iss[15:4]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[3]  & ~dpu_strobe_iss[4]   => ~|dpu_strobe_iss[15:5]")
  u_ovl_intf_assert_eecb3d47d68a3cb0666d2c0a36888fede03ff819 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[3]  & ~dpu_strobe_iss[4]  ),
    .consequent_expr (~|dpu_strobe_iss[15:5]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[4]  & ~dpu_strobe_iss[5]   => ~|dpu_strobe_iss[15:6]")
  u_ovl_intf_assert_3c57b770e24a9aba598058a43728731d8484bb92 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[4]  & ~dpu_strobe_iss[5]  ),
    .consequent_expr (~|dpu_strobe_iss[15:6]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[5]  & ~dpu_strobe_iss[6]   => ~|dpu_strobe_iss[15:7]")
  u_ovl_intf_assert_2751ce348ff25d0975545418ee5ce9c9dacbe08b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[5]  & ~dpu_strobe_iss[6]  ),
    .consequent_expr (~|dpu_strobe_iss[15:7]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[6]  & ~dpu_strobe_iss[7]   => ~|dpu_strobe_iss[15:8]")
  u_ovl_intf_assert_817e98fadcb5394488350ae7f847ddf99bf68aff (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[6]  & ~dpu_strobe_iss[7]  ),
    .consequent_expr (~|dpu_strobe_iss[15:8]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[7]  & ~dpu_strobe_iss[8]   => ~|dpu_strobe_iss[15:9]")
  u_ovl_intf_assert_3597ee57fda95a5d0a95f4c12e3fbde8bd6a26b2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[7]  & ~dpu_strobe_iss[8]  ),
    .consequent_expr (~|dpu_strobe_iss[15:9]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[8]  & ~dpu_strobe_iss[9]   => ~|dpu_strobe_iss[15:10]")
  u_ovl_intf_assert_17f1cee5cad2a32cf202bdf646d2b91cd51f1ecd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[8]  & ~dpu_strobe_iss[9]  ),
    .consequent_expr (~|dpu_strobe_iss[15:10]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[9]  & ~dpu_strobe_iss[10]  => ~|dpu_strobe_iss[15:11]")
  u_ovl_intf_assert_2c5a942302e94adf71569a20d4498e3cd696d895 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[9]  & ~dpu_strobe_iss[10] ),
    .consequent_expr (~|dpu_strobe_iss[15:11]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[10] & ~dpu_strobe_iss[11]  => ~|dpu_strobe_iss[15:12]")
  u_ovl_intf_assert_689c2e87a5d9398a6938dfbf2bd439f2af16393f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[10] & ~dpu_strobe_iss[11] ),
    .consequent_expr (~|dpu_strobe_iss[15:12]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[11] & ~dpu_strobe_iss[12]  => ~|dpu_strobe_iss[15:13]")
  u_ovl_intf_assert_5bf4eb06b573abe8ed48df164b03544111853d70 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[11] & ~dpu_strobe_iss[12] ),
    .consequent_expr (~|dpu_strobe_iss[15:13]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[12] & ~dpu_strobe_iss[13]  => ~|dpu_strobe_iss[15:14]")
  u_ovl_intf_assert_6a58e3dbd5fe5ba47522ef8aeb9e8f999b9caac2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[12] & ~dpu_strobe_iss[13] ),
    .consequent_expr (~|dpu_strobe_iss[15:14]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[13] & ~dpu_strobe_iss[14]  => ~dpu_strobe_iss[15]")
  u_ovl_intf_assert_27f1916b811c333aaa0dd5c77b0ecb46f43fd3f4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & ~dpu_valid_cp_iss & dpu_store_iss & dpu_strobe_iss[13] & ~dpu_strobe_iss[14] ),
    .consequent_expr (~dpu_strobe_iss[15]));


  // V2P operations should never hit in the uTLB, as they need to do a full
  // translation through the TLB.
  // - clear if have handshake in Iss but transaction is flushed, as this can
  // change translation result and DCU will be empty after flush anyway.
  assign v2p_transl_type_iss  = (((dpu_cp_op_iss == `CA53_CPOP_ATS1C) | (dpu_cp_op_iss ==     `CA53_CPOP_ATS1E01)))   ? {2'b01, dpu_priv_iss} : (((dpu_cp_op_iss == `CA53_CPOP_ATS12NSO) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS12E01)))  ? {2'b10, dpu_priv_iss} : (((dpu_cp_op_iss == `CA53_CPOP_ATS1H) | (dpu_cp_op_iss ==     `CA53_CPOP_ATS1E2)))    ? 3'b110                : (((dpu_cp_op_iss == `CA53_CPOP_ATS1E3)))                         ? 3'b111                : 3'b000;
  assign v2p_el_iss           = ({2{v2p_transl_type_iss[2:1] == 2'b11}}   & v2p_transl_type_iss[1:0]) | ({2{v2p_transl_type_iss[2:0] == 3'b011}}  & {~dpu_ns_state & ~dpu_aarch64_at_el[3], 1'b1});


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    v2p_dc1 <= 1'b0;
  else if (entering_dcu_noflush | dpu_flush)
    v2p_dc1 <= dpu_valid_cp_iss & ~dpu_flush & v2p_iss;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    v2pc_dc1 <= 1'b0;
  else if (entering_dcu_noflush | dpu_flush)
    v2pc_dc1 <= dpu_valid_cp_iss & ~dpu_flush & ((dpu_cp_op_iss == `CA53_CPOP_ATS1C) | (dpu_cp_op_iss == `CA53_CPOP_ATS1E01));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    v2ph_dc1 <= 1'b0;
  else if (entering_dcu_noflush | dpu_flush)
    v2ph_dc1 <= dpu_valid_cp_iss & ~dpu_flush & ((dpu_cp_op_iss == `CA53_CPOP_ATS1H) | (dpu_cp_op_iss == `CA53_CPOP_ATS1E2));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    v2pe3_dc1 <= 1'b0;
  else if (entering_dcu_noflush | dpu_flush)
    v2pe3_dc1 <= dpu_valid_cp_iss & ~dpu_flush & (dpu_cp_op_iss == `CA53_CPOP_ATS1E3);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    v2p_el_dc1 <= 2'b00;
  else if (entering_dcu_noflush | dpu_flush)
    v2p_el_dc1 <= v2p_el_iss;



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu_noflush@1 & v2p_dc1  => ~dpu_utlb_hit_dc1")
  u_ovl_intf_assert_56b131f7f27094bfe3a035e89a0ace7c09d5e3bf (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_noflush_reg & v2p_dc1 ),
    .consequent_expr (~dpu_utlb_hit_dc1));


  // S2 permissions for an ATS1C should always be R+W

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "v2pc_dc1 & dpu_utlb_hit_dc1  => dpu_attributes_dc1[4:3] == 2'b11")
  u_ovl_intf_assert_eb7c13906ba1126f3a82ffce4aa876e7c8918bad (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (v2pc_dc1 & dpu_utlb_hit_dc1 ),
    .consequent_expr (dpu_attributes_dc1[4:3] == 2'b11));


  // LPAE mode should always be set for ATS1H/ATS1E2/ATS1E3 translations

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "v2ph_dc1  & dpu_utlb_hit_dc1  => dpu_lpae_dc1")
  u_ovl_intf_assert_3b684c5354fb581def88d58d69b62228c511107c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (v2ph_dc1  & dpu_utlb_hit_dc1 ),
    .consequent_expr (dpu_lpae_dc1));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "v2pe3_dc1 & dpu_utlb_hit_dc1  => dpu_lpae_dc1")
  u_ovl_intf_assert_27697bf20f16f988694f7532d84938af0a6054e5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (v2pe3_dc1 & dpu_utlb_hit_dc1 ),
    .consequent_expr (dpu_lpae_dc1));


  // The level indicated to the DCU must be valid for the current mode, but is not used on aborts.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    waiting_for_transl <= 1'b0;
  else
    waiting_for_transl <= (entering_dcu_needs_transl_reg | waiting_for_transl) & ~dpu_utlb_hit_dc1 & ~dpu_flush;


  assign dpu_utlb_hit_dc1_real  = dpu_utlb_hit_dc1 & (entering_dcu_needs_transl_reg | waiting_for_transl);

  // - S1 level is VMSA or LPAE format depending current mode

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_utlb_hit_dc1_real & ~dpu_flush & dpu_lpae_dc1 & ~dpu_abort_dc1   => dpu_level_dc1[1:0] in [`CA53_LPAE_TRANSL_LEVEL_1, `CA53_LPAE_TRANSL_LEVEL_2, `CA53_LPAE_TRANSL_LEVEL_3]")
  u_ovl_intf_assert_1812b58edde9cc6a037726faa4dabbb39e53649b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_utlb_hit_dc1_real & ~dpu_flush & dpu_lpae_dc1 & ~dpu_abort_dc1  ),
    .consequent_expr (((dpu_level_dc1[1:0] == `CA53_LPAE_TRANSL_LEVEL_1) | (dpu_level_dc1[1:0] ==  `CA53_LPAE_TRANSL_LEVEL_2) | (dpu_level_dc1[1:0] ==  `CA53_LPAE_TRANSL_LEVEL_3))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_utlb_hit_dc1_real & ~dpu_flush & ~dpu_lpae_dc1 & ~dpu_abort_dc1  => dpu_level_dc1[1:0] in [`CA53_VMSA_PAGE_SIZE_SSECTION, `CA53_VMSA_PAGE_SIZE_SECTION, `CA53_VMSA_PAGE_SIZE_PAGE]")
  u_ovl_intf_assert_ffc17f210c9b4a62ad2d639797d478bdfb379ff2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_utlb_hit_dc1_real & ~dpu_flush & ~dpu_lpae_dc1 & ~dpu_abort_dc1 ),
    .consequent_expr (((dpu_level_dc1[1:0] == `CA53_VMSA_PAGE_SIZE_SSECTION) | (dpu_level_dc1[1:0] ==  `CA53_VMSA_PAGE_SIZE_SECTION) | (dpu_level_dc1[1:0] ==  `CA53_VMSA_PAGE_SIZE_PAGE))));


  // Not all encodings of fault stage are valid

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_utlb_hit_dc1_real & dpu_abort_dc1  => dpu_fault_dc1[8:7] in [2'b00, 2'b10, 2'b11]")
  u_ovl_intf_assert_11f699e1ca357116ea3e7543efecde4c6e9e75b3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_utlb_hit_dc1_real & dpu_abort_dc1 ),
    .consequent_expr (((dpu_fault_dc1[8:7] == 2'b00) | (dpu_fault_dc1[8:7] ==  2'b10) | (dpu_fault_dc1[8:7] ==  2'b11))));


  // Not all encodings of fault type are valid

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_utlb_hit_dc1_real & dpu_abort_dc1 & ~dpu_lpae_dc1 & ~dpu_fault_dc1[8]   => dpu_fault_dc1[6:0] in [`CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2, `CA53_FAULT_LPAE_TRANSLATION_L1, `CA53_FAULT_LPAE_TRANSLATION_L2, `CA53_FAULT_LPAE_ACCESS_L1, `CA53_FAULT_LPAE_ACCESS_L2, `CA53_FAULT_LPAE_DOMAIN_L1, `CA53_FAULT_LPAE_DOMAIN_L2]")
  u_ovl_intf_assert_b249f70d622d4523408bb7ae30803b2fc393a337 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_utlb_hit_dc1_real & dpu_abort_dc1 & ~dpu_lpae_dc1 & ~dpu_fault_dc1[8]  ),
    .consequent_expr (((dpu_fault_dc1[6:0] == `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_TRANSLATION_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_TRANSLATION_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ACCESS_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ACCESS_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_DOMAIN_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_DOMAIN_L2))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_utlb_hit_dc1_real & dpu_abort_dc1 &  dpu_lpae_dc1 & ~dpu_fault_dc1[8]   => dpu_fault_dc1[6:0] in [`CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3, `CA53_FAULT_LPAE_TRANSLATION_L0, `CA53_FAULT_LPAE_TRANSLATION_L1, `CA53_FAULT_LPAE_TRANSLATION_L2, `CA53_FAULT_LPAE_TRANSLATION_L3, `CA53_FAULT_LPAE_ACCESS_L0, `CA53_FAULT_LPAE_ACCESS_L1, `CA53_FAULT_LPAE_ACCESS_L2, `CA53_FAULT_LPAE_ACCESS_L3, `CA53_FAULT_LPAE_ADDR_SIZE_L0, `CA53_FAULT_LPAE_ADDR_SIZE_L1, `CA53_FAULT_LPAE_ADDR_SIZE_L2, `CA53_FAULT_LPAE_ADDR_SIZE_L3]")
  u_ovl_intf_assert_c0ceb574078413ab7d9e89e12f8bdc37435f2e61 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_utlb_hit_dc1_real & dpu_abort_dc1 &  dpu_lpae_dc1 & ~dpu_fault_dc1[8]  ),
    .consequent_expr (((dpu_fault_dc1[6:0] == `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_TRANSLATION_L0) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_TRANSLATION_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_TRANSLATION_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_TRANSLATION_L3) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ACCESS_L0) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ACCESS_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ACCESS_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ACCESS_L3) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L0) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L3))));


  // - Stage 2 faults are always reported using the LPAE encoding format.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_utlb_hit_dc1_real & dpu_abort_dc1 &                  dpu_fault_dc1[8]   => dpu_fault_dc1[6:0] in [`CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3, `CA53_FAULT_LPAE_TRANSLATION_L0, `CA53_FAULT_LPAE_TRANSLATION_L1, `CA53_FAULT_LPAE_TRANSLATION_L2, `CA53_FAULT_LPAE_TRANSLATION_L3, `CA53_FAULT_LPAE_ACCESS_L0, `CA53_FAULT_LPAE_ACCESS_L1, `CA53_FAULT_LPAE_ACCESS_L2, `CA53_FAULT_LPAE_ACCESS_L3, `CA53_FAULT_LPAE_ADDR_SIZE_L0, `CA53_FAULT_LPAE_ADDR_SIZE_L1, `CA53_FAULT_LPAE_ADDR_SIZE_L2, `CA53_FAULT_LPAE_ADDR_SIZE_L3,  `CA53_FAULT_LPAE_PERMISSION_L0, `CA53_FAULT_LPAE_PERMISSION_L1, `CA53_FAULT_LPAE_PERMISSION_L2, `CA53_FAULT_LPAE_PERMISSION_L3]")
  u_ovl_intf_assert_590ec2fd867fdfd8867c218d6c9446babdc5df0a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_utlb_hit_dc1_real & dpu_abort_dc1 &                  dpu_fault_dc1[8]  ),
    .consequent_expr (((dpu_fault_dc1[6:0] == `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_TRANSLATION_L0) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_TRANSLATION_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_TRANSLATION_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_TRANSLATION_L3) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ACCESS_L0) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ACCESS_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ACCESS_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ACCESS_L3) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L0) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L3) | (dpu_fault_dc1[6:0] ==   `CA53_FAULT_LPAE_PERMISSION_L0) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PERMISSION_L1) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PERMISSION_L2) | (dpu_fault_dc1[6:0] ==  `CA53_FAULT_LPAE_PERMISSION_L3))));


  // The TLB can only generate S1 faults when HCR.VM is not asserted

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_utlb_hit_dc1_real & dpu_abort_dc1 & ~(dpu_ipa_to_pa_en | dpu_default_cacheable)  => dpu_fault_dc1[8:7] == 2'b00")
  u_ovl_intf_assert_3d93015807b4542ff2e06fbf059bc3b9030c0662 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_utlb_hit_dc1_real & dpu_abort_dc1 & ~(dpu_ipa_to_pa_en | dpu_default_cacheable) ),
    .consequent_expr (dpu_fault_dc1[8:7] == 2'b00));


  // The TLB will never generate an S2 fault for an ATS1C (but it can generate S2 faults on S1 pagewalks)

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_utlb_hit_dc1 & dpu_abort_dc1 & v2pc_dc1  => dpu_fault_dc1[8:7] in [2'b00, 2'b11]")
  u_ovl_intf_assert_90d6a6698b1914a513e230e4f6ad687f18f44a6f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_utlb_hit_dc1 & dpu_abort_dc1 & v2pc_dc1 ),
    .consequent_expr (((dpu_fault_dc1[8:7] == 2'b00) | (dpu_fault_dc1[8:7] ==  2'b11))));


  // An ATS1C which does a secure translation will never generate an S2 fault on an S1 pagewalk,
  // as secure translations cannot generate S2 faults.
  // - Note that in AA64, ATS1E01 instructions use the SCR.NS bit to determine the security of the translation
  // - AA32 ATS1C instructions in secure state always do a secure translation

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_utlb_hit_dc1 & dpu_abort_dc1 & v2pc_dc1 & ~dpu_ns_state & (~dpu_aarch64_at_el[3] | ~dpu_scr_el3_ns)  => dpu_fault_dc1[8:7] == 2'b00")
  u_ovl_intf_assert_800061f1a7d4a4fb9da5463e66719b2d2153f362 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_utlb_hit_dc1 & dpu_abort_dc1 & v2pc_dc1 & ~dpu_ns_state & (~dpu_aarch64_at_el[3] | ~dpu_scr_el3_ns) ),
    .consequent_expr (dpu_fault_dc1[8:7] == 2'b00));


  // A uTLB hit (as opposed to a main TLB lookup which updates the uTLB) cannot indicate
  // a translation abort, as to have been written into the uTLB the original translation
  // must not have aborted, however domain faults can be indicated as these are generated
  // by the DPU. The DPU will not mask the utlb hit signal for operations which do not do
  // a memory translation, so it is not valid to look at the signals in that case.
  // - A transaction which requires a memory translation is indicated by dpu_valid_iss
  // being set.
  assign entering_dcu_needs_transl  = dpu_valid_iss & dcu_ready_iss & ~dpu_flush & ~utlb_stall;


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu_needs_transl@1 & dpu_utlb_hit_dc1  => ~dpu_abort_dc1 | (dpu_fault_dc1[6:0] in [`CA53_FAULT_LPAE_DOMAIN_L1,`CA53_FAULT_LPAE_DOMAIN_L2] & ~dpu_lpae_dc1)")
  u_ovl_intf_assert_f6fdbc63b3a64cbffd7dc2a0fc371677e3f43c8a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_needs_transl_reg & dpu_utlb_hit_dc1 ),
    .consequent_expr (~dpu_abort_dc1 | (((dpu_fault_dc1[6:0] == `CA53_FAULT_LPAE_DOMAIN_L1) | (dpu_fault_dc1[6:0] == `CA53_FAULT_LPAE_DOMAIN_L2)) & ~dpu_lpae_dc1)));


  // In EL2-3, there is no TTBR1, so VA[48] must always be 0 on a valid translation
  assign transl_el_dc1  = v2p_dc1 ? v2p_el_dc1 : dpu_exception_level;


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_utlb_hit_dc1_real & ~dpu_flush & ~dpu_abort_dc1 & ((transl_el_dc1 == `CA53_EL2) | (transl_el_dc1 == `CA53_EL3))  => dpu_va_dc1[48] == 1'b0")
  u_ovl_intf_assert_fb7a3add89b0cc676b260f531c199d904525aa53 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_utlb_hit_dc1_real & ~dpu_flush & ~dpu_abort_dc1 & ((transl_el_dc1 == `CA53_EL2) | (transl_el_dc1 == `CA53_EL3)) ),
    .consequent_expr (dpu_va_dc1[48] == 1'b0));


  // The AGU operands provided in Iss must be consistent with the VA provided in DC1
  assign agu_addr_iss  = dpu_agu_a_operand_iss + dpu_agu_b_operand_iss + dpu_agu_carry_out_64b_iss;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    agu_addr_dc1 <= {43{1'b0}};
  else if (entering_dcu_needs_transl)
    agu_addr_dc1 <= agu_addr_iss;



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu_needs_transl@1 &  dpu_aarch64_state  => dpu_va_dc1[48:6] == agu_addr_dc1[48:6]")
  u_ovl_intf_assert_42d0c90eb28823c451e0f6c9821a16502a555cf1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_needs_transl_reg &  dpu_aarch64_state ),
    .consequent_expr (dpu_va_dc1[48:6] == agu_addr_dc1[48:6]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu_needs_transl@1 & ~dpu_aarch64_state  => dpu_va_dc1[31:6] == agu_addr_dc1[31:6]")
  u_ovl_intf_assert_94da37ae917b6d85d9de2d4058ef84122ce2bf68 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_needs_transl_reg & ~dpu_aarch64_state ),
    .consequent_expr (dpu_va_dc1[31:6] == agu_addr_dc1[31:6]));


  // A CP register read or write must be word or doubleword sized

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_cp_iss & dpu_cp_op_iss in [`CA53_CPOP_CDBGDR0,   `CA53_CPOP_CDBGDR1,  `CA53_CPOP_CDBGDR2,   `CA53_CPOP_CDBGDR3, `CA53_CPOP_TTBR0,     `CA53_CPOP_TTBR1,    `CA53_CPOP_TTBR0_EL1, `CA53_CPOP_TTBR0_EL2,      `CA53_CPOP_TTBR0_EL3, `CA53_CPOP_TTBCR,     `CA53_CPOP_TCR_EL1,  `CA53_CPOP_TCR_EL2,   `CA53_CPOP_TCR_EL3, `CA53_CPOP_HTTBR,     `CA53_CPOP_VTTBR,    `CA53_CPOP_VTTBR_EL2, `CA53_CPOP_HTCR,      `CA53_CPOP_VTCR,     `CA53_CPOP_VTCR_EL2,  `CA53_CPOP_PAR,            `CA53_CPOP_PAR_EL1, `CA53_CPOP_MAIR0,     `CA53_CPOP_MAIR1,    `CA53_CPOP_MAIR_EL1,  `CA53_CPOP_MAIR_EL2,       `CA53_CPOP_MAIR_EL3, `CA53_CPOP_HMAIR0,    `CA53_CPOP_HMAIR1,   `CA53_CPOP_CONTEXTIDR,`CA53_CPOP_CONTEXTIDR_EL1, `CA53_CPOP_DBGBVR0,   `CA53_CPOP_DBGBVR1,  `CA53_CPOP_DBGBVR2,   `CA53_CPOP_DBGBVR3,        `CA53_CPOP_DBGBVR4,  `CA53_CPOP_DBGBVR5, `CA53_CPOP_DBGBXVR4,  `CA53_CPOP_DBGBXVR5, `CA53_CPOP_DBGBCR0,   `CA53_CPOP_DBGBCR1,  `CA53_CPOP_DBGBCR2,   `CA53_CPOP_DBGBCR3,        `CA53_CPOP_DBGBCR4,  `CA53_CPOP_DBGBCR5, `CA53_CPOP_DBGWVR0,   `CA53_CPOP_DBGWVR1,  `CA53_CPOP_DBGWVR2,   `CA53_CPOP_DBGWVR3, `CA53_CPOP_DBGWCR0,   `CA53_CPOP_DBGWCR1,  `CA53_CPOP_DBGWCR2,   `CA53_CPOP_DBGWCR3, `CA53_CPOP_DBGVCR]  => (dpu_size_iss in [`CA53_SIZE_WORD, `CA53_SIZE_DWORD])")
  u_ovl_intf_assert_1a682dc71d5ef9a1f81d88b3e11af9220519f1e1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_cp_iss & ((dpu_cp_op_iss == `CA53_CPOP_CDBGDR0) | (dpu_cp_op_iss ==    `CA53_CPOP_CDBGDR1) | (dpu_cp_op_iss ==   `CA53_CPOP_CDBGDR2) | (dpu_cp_op_iss ==    `CA53_CPOP_CDBGDR3) | (dpu_cp_op_iss ==  `CA53_CPOP_TTBR0) | (dpu_cp_op_iss ==      `CA53_CPOP_TTBR1) | (dpu_cp_op_iss ==     `CA53_CPOP_TTBR0_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_TTBR0_EL2) | (dpu_cp_op_iss ==       `CA53_CPOP_TTBR0_EL3) | (dpu_cp_op_iss ==  `CA53_CPOP_TTBCR) | (dpu_cp_op_iss ==      `CA53_CPOP_TCR_EL1) | (dpu_cp_op_iss ==   `CA53_CPOP_TCR_EL2) | (dpu_cp_op_iss ==    `CA53_CPOP_TCR_EL3) | (dpu_cp_op_iss ==  `CA53_CPOP_HTTBR) | (dpu_cp_op_iss ==      `CA53_CPOP_VTTBR) | (dpu_cp_op_iss ==     `CA53_CPOP_VTTBR_EL2) | (dpu_cp_op_iss ==  `CA53_CPOP_HTCR) | (dpu_cp_op_iss ==       `CA53_CPOP_VTCR) | (dpu_cp_op_iss ==      `CA53_CPOP_VTCR_EL2) | (dpu_cp_op_iss ==   `CA53_CPOP_PAR) | (dpu_cp_op_iss ==             `CA53_CPOP_PAR_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_MAIR0) | (dpu_cp_op_iss ==      `CA53_CPOP_MAIR1) | (dpu_cp_op_iss ==     `CA53_CPOP_MAIR_EL1) | (dpu_cp_op_iss ==   `CA53_CPOP_MAIR_EL2) | (dpu_cp_op_iss ==        `CA53_CPOP_MAIR_EL3) | (dpu_cp_op_iss ==  `CA53_CPOP_HMAIR0) | (dpu_cp_op_iss ==     `CA53_CPOP_HMAIR1) | (dpu_cp_op_iss ==    `CA53_CPOP_CONTEXTIDR) | (dpu_cp_op_iss == `CA53_CPOP_CONTEXTIDR_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGBVR0) | (dpu_cp_op_iss ==    `CA53_CPOP_DBGBVR1) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBVR2) | (dpu_cp_op_iss ==    `CA53_CPOP_DBGBVR3) | (dpu_cp_op_iss ==         `CA53_CPOP_DBGBVR4) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBVR5) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGBXVR4) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBXVR5) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGBCR0) | (dpu_cp_op_iss ==    `CA53_CPOP_DBGBCR1) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBCR2) | (dpu_cp_op_iss ==    `CA53_CPOP_DBGBCR3) | (dpu_cp_op_iss ==         `CA53_CPOP_DBGBCR4) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBCR5) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGWVR0) | (dpu_cp_op_iss ==    `CA53_CPOP_DBGWVR1) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGWVR2) | (dpu_cp_op_iss ==    `CA53_CPOP_DBGWVR3) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGWCR0) | (dpu_cp_op_iss ==    `CA53_CPOP_DBGWCR1) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGWCR2) | (dpu_cp_op_iss ==    `CA53_CPOP_DBGWCR3) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGVCR)) ),
    .consequent_expr ((((dpu_size_iss == `CA53_SIZE_WORD) | (dpu_size_iss ==  `CA53_SIZE_DWORD)))));


  // A PLD or PLDW instruction cannot be or unaligned

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & dpu_pld_iss  => ~dpu_cross_64_iss")
  u_ovl_intf_assert_ec45ce43c9e8368e4228db4b75cd1d233b64ffe1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & dpu_pld_iss ),
    .consequent_expr (~dpu_cross_64_iss));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dpu_valid_any_iss0 <= 1'b0;
  else if (en0)
    dpu_valid_any_iss0 <= (leaving_dcu & valid1) ? dpu_valid_any_iss1 : dpu_valid_any_iss;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dpu_valid_any_iss1 <= 1'b0;
  else if (en1)
    dpu_valid_any_iss1 <= (leaving_dcu & valid2) ? dpu_valid_any_iss2 : dpu_valid_any_iss;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dpu_valid_any_iss2 <= 1'b0;
  else if (en2)
    dpu_valid_any_iss2 <= dpu_valid_any_iss;



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dpu_pld_iss0 <= 1'b0;
  else if (en0)
    dpu_pld_iss0 <= (leaving_dcu & valid1) ? dpu_pld_iss1 : dpu_pld_iss;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dpu_pld_iss1 <= 1'b0;
  else if (en1)
    dpu_pld_iss1 <= (leaving_dcu & valid2) ? dpu_pld_iss2 : dpu_pld_iss;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dpu_pld_iss2 <= 1'b0;
  else if (en2)
    dpu_pld_iss2 <= dpu_pld_iss;


  // A PLD or PLDW instruction must not be aborted

  assert_implication #(`OVL_FATAL, INOPTIONS, "leaving_dcu & dcu_valid_dc3 & dpu_valid_any_iss0 & dpu_pld_iss0  => ~dcu_p_abort_dc3")
  u_ovl_intf_assume_aa25bb5ce8b0dc8d5ae51b81240666fb3f71ba48 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (leaving_dcu & dcu_valid_dc3 & dpu_valid_any_iss0 & dpu_pld_iss0 ),
    .consequent_expr (~dcu_p_abort_dc3));


  // A PLD or PLDW instruction must not trigger a watchpoint

  assert_implication #(`OVL_FATAL, INOPTIONS, "leaving_dcu & dcu_valid_dc3 & dpu_valid_any_iss0 & dpu_pld_iss0  => ~dcu_wpt_hit_dc3")
  u_ovl_intf_assume_fe76c68e9b5b6ec9267b2f7366ab4d4c2f383db7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (leaving_dcu & dcu_valid_dc3 & dpu_valid_any_iss0 & dpu_pld_iss0 ),
    .consequent_expr (~dcu_wpt_hit_dc3));


  // A CP instruction cannot be an exclusive (unless STLXR), PLD, PLDW or unaligned

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_cp_iss & ~dpu_flush  => ~(dpu_excl_iss & ~dpu_ldar_stlr_iss) & ~dpu_pld_iss & ~dpu_cross_64_iss")
  u_ovl_intf_assert_43307a533b302e758e9c4758bf1c522609fae5b4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_cp_iss & ~dpu_flush ),
    .consequent_expr (~(dpu_excl_iss & ~dpu_ldar_stlr_iss) & ~dpu_pld_iss & ~dpu_cross_64_iss));


  // The only CP OP which can have ldar_stlr_iss set is the DMBSY for an STLR

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_cp_iss & ~dpu_flush & dpu_ldar_stlr_iss  => (dpu_cp_op_iss == `CA53_CPOP_DMBSY)")
  u_ovl_intf_assert_e1aa66445c7fdc5f3b2623bd2cb036fa4e907cb4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_cp_iss & ~dpu_flush & dpu_ldar_stlr_iss ),
    .consequent_expr ((dpu_cp_op_iss == `CA53_CPOP_DMBSY)));


  // Accesses that cross 64-bit boundaries can not be byte sized

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & dpu_cross_64_iss  => (dpu_size_iss != `CA53_SIZE_BYTE)")
  u_ovl_intf_assert_c4305a97dffb26e50a0545acda905fd6e8618ef7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & dpu_cross_64_iss ),
    .consequent_expr ((dpu_size_iss != `CA53_SIZE_BYTE)));


  // Accesses that cross 64-bit boundaries can not be exclusives

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss & dpu_cross_64_iss  => ~dpu_excl_iss")
  u_ovl_intf_assert_1106daa378ec4c71b47c6f85cdabc508f08e3669 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss & dpu_cross_64_iss ),
    .consequent_expr (~dpu_excl_iss));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dpu_clrex_iss0 <= 1'b0;
  else if (en0)
    dpu_clrex_iss0 <= (leaving_dcu & valid1) ? dpu_clrex_iss1 : (dpu_valid_cp_iss & (dpu_cp_op_iss == `CA53_CPOP_CLREX));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dpu_clrex_iss1 <= 1'b0;
  else if (en1)
    dpu_clrex_iss1 <= (leaving_dcu & valid2) ? dpu_clrex_iss2 : (dpu_valid_cp_iss & (dpu_cp_op_iss == `CA53_CPOP_CLREX));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dpu_clrex_iss2 <= 1'b0;
  else if (en2)
    dpu_clrex_iss2 <= (dpu_valid_cp_iss & (dpu_cp_op_iss == `CA53_CPOP_CLREX));


  // A CLREX instruction must not be aborted

  assert_implication #(`OVL_FATAL, INOPTIONS, "leaving_dcu & dcu_valid_dc3 & dpu_valid_any_iss0 & dpu_clrex_iss0  => ~dcu_p_abort_dc3")
  u_ovl_intf_assume_c6449d2d3cdb2e5173daf625cc6f98de82776e1a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (leaving_dcu & dcu_valid_dc3 & dpu_valid_any_iss0 & dpu_clrex_iss0 ),
    .consequent_expr (~dcu_p_abort_dc3));


  // Alignment bits must have valid encoding

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_any_iss  => dpu_align_size_iss in [`CA53_ALIGN_NONE, `CA53_ALIGN_16BIT, `CA53_ALIGN_32BIT, `CA53_ALIGN_64BIT, `CA53_ALIGN_128BIT, `CA53_ALIGN_256BIT, `CA53_ALIGN_DCZVA ]")
  u_ovl_intf_assert_300b57ef0f29009039b09e31b43095a6038ee359 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_any_iss ),
    .consequent_expr (((dpu_align_size_iss == `CA53_ALIGN_NONE) | (dpu_align_size_iss ==  `CA53_ALIGN_16BIT) | (dpu_align_size_iss ==  `CA53_ALIGN_32BIT) | (dpu_align_size_iss ==  `CA53_ALIGN_64BIT) | (dpu_align_size_iss ==  `CA53_ALIGN_128BIT) | (dpu_align_size_iss ==  `CA53_ALIGN_256BIT) | (dpu_align_size_iss ==  `CA53_ALIGN_DCZVA ))));


  // The strobes should always be set on non-CP ops

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu & ~dpu_valid_cp_iss  => dpu_strobe_iss != 16'h0000")
  u_ovl_intf_assert_04995116058e4dcf1a0b15e625c09c2bfc4a7bf9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu & ~dpu_valid_cp_iss ),
    .consequent_expr (dpu_strobe_iss != 16'h0000));


  // The size, address and byte strobes must all be consistent.
  // Note that NEON accesses will always be doubleword aligned, but can have strobes requesting less data
  // than their size suggests.
  assign byte_strobe_antecedent  = entering_dcu_reg & dpu_valid_iss_reg & (dpu_size_iss_reg == `CA53_SIZE_BYTE);

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0000)  => dpu_strobe_iss@1 == 16'b0000_0000_0000_0001")
  u_ovl_intf_assert_a8fffa3319769ca1ca240f6aac39bfb42c71b273 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0000) ),
    .consequent_expr (dpu_strobe_iss_reg == 16'b0000_0000_0000_0001));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0001)  => dpu_strobe_iss@1 == 16'b0000_0000_0000_0010")
  u_ovl_intf_assert_200f8911cc32b1ace3564f26c2ac6b9a7cf43379 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0001) ),
    .consequent_expr (dpu_strobe_iss_reg == 16'b0000_0000_0000_0010));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0010)  => dpu_strobe_iss@1 == 16'b0000_0000_0000_0100")
  u_ovl_intf_assert_b439d02d441f351aef91d78744390461d94e0bfb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0010) ),
    .consequent_expr (dpu_strobe_iss_reg == 16'b0000_0000_0000_0100));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0011)  => dpu_strobe_iss@1 == 16'b0000_0000_0000_1000")
  u_ovl_intf_assert_dc7328a65fabb3b81ce6b0600e0436a535c64c27 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0011) ),
    .consequent_expr (dpu_strobe_iss_reg == 16'b0000_0000_0000_1000));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0100)  => dpu_strobe_iss@1 == 16'b0000_0000_0001_0000")
  u_ovl_intf_assert_cf566f8dc1e372266b525f7547caf8c17b784b53 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0100) ),
    .consequent_expr (dpu_strobe_iss_reg == 16'b0000_0000_0001_0000));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0101)  => dpu_strobe_iss@1 == 16'b0000_0000_0010_0000")
  u_ovl_intf_assert_4449d6ef507ffa21a4bf4fd2efcfcb9d99991c0e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0101) ),
    .consequent_expr (dpu_strobe_iss_reg == 16'b0000_0000_0010_0000));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0110)  => dpu_strobe_iss@1 == 16'b0000_0000_0100_0000")
  u_ovl_intf_assert_c4fc99b32de00823bb86b5cdba548a748539f57c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0110) ),
    .consequent_expr (dpu_strobe_iss_reg == 16'b0000_0000_0100_0000));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0111)  => dpu_strobe_iss@1 == 16'b0000_0000_1000_0000")
  u_ovl_intf_assert_6d55af0121398993b181997585c591745a9c50c2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0111) ),
    .consequent_expr (dpu_strobe_iss_reg == 16'b0000_0000_1000_0000));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1000)  => dpu_strobe_iss@1 == 16'b0000_0001_0000_0000")
  u_ovl_intf_assert_e52bcdc6cff3425a25893cbbd98f434a948141a4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1000) ),
    .consequent_expr (dpu_strobe_iss_reg == 16'b0000_0001_0000_0000));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1001)  => dpu_strobe_iss@1 == 16'b0000_0010_0000_0000")
  u_ovl_intf_assert_9fdbd7fae5e4dd2b2f7064576ab9fc96cf507bac (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1001) ),
    .consequent_expr (dpu_strobe_iss_reg == 16'b0000_0010_0000_0000));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1010)  => dpu_strobe_iss@1 == 16'b0000_0100_0000_0000")
  u_ovl_intf_assert_dece29432c42d17740241ed88913111bcaa777f8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1010) ),
    .consequent_expr (dpu_strobe_iss_reg == 16'b0000_0100_0000_0000));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1011)  => dpu_strobe_iss@1 == 16'b0000_1000_0000_0000")
  u_ovl_intf_assert_d408d602a721ff988fdd33d4a84a27a91c598d7c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1011) ),
    .consequent_expr (dpu_strobe_iss_reg == 16'b0000_1000_0000_0000));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1100)  => dpu_strobe_iss@1 == 16'b0001_0000_0000_0000")
  u_ovl_intf_assert_32fabadb445dec470d80c49aa18e9d496a6eff92 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1100) ),
    .consequent_expr (dpu_strobe_iss_reg == 16'b0001_0000_0000_0000));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1101)  => dpu_strobe_iss@1 == 16'b0010_0000_0000_0000")
  u_ovl_intf_assert_1209cb4cf2097e94a4527468ba318023c85134c3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1101) ),
    .consequent_expr (dpu_strobe_iss_reg == 16'b0010_0000_0000_0000));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1110)  => dpu_strobe_iss@1 == 16'b0100_0000_0000_0000")
  u_ovl_intf_assert_44e69f3485a9420b52399ff94ec4f3f451811579 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1110) ),
    .consequent_expr (dpu_strobe_iss_reg == 16'b0100_0000_0000_0000));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1111)  => dpu_strobe_iss@1 == 16'b1000_0000_0000_0000")
  u_ovl_intf_assert_f570864c26cf6a417a8bb0a876bb7010aeea6b1c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (byte_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1111) ),
    .consequent_expr (dpu_strobe_iss_reg == 16'b1000_0000_0000_0000));


  assign hword_strobe_antecedent  = entering_dcu_reg & dpu_valid_iss_reg & (dpu_size_iss_reg == `CA53_SIZE_HWORD);

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0000)  => dpu_strobe_iss@1 in [16'b0000_0000_0000_0011, 16'b0000_0000_0000_0001]")
  u_ovl_intf_assert_f184c35933ccf0543e94197e106fb6cdc1c41a22 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0000) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_0000_0011) | (dpu_strobe_iss_reg ==  16'b0000_0000_0000_0001))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0001)  => dpu_strobe_iss@1 in [16'b0000_0000_0000_0110]")
  u_ovl_intf_assert_88600bc5b78956028cd2e542db74a96fe6422d52 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0001) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_0000_0110))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0010)  => dpu_strobe_iss@1 in [16'b0000_0000_0000_1100]")
  u_ovl_intf_assert_94182b7c9520ae0bbf4cd63f039d6638ee4fda8e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0010) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_0000_1100))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0011)  => dpu_strobe_iss@1 in [16'b0000_0000_0001_1000]")
  u_ovl_intf_assert_8a46edebb36239f26e0d037e9ffebb364f9dc875 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0011) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_0001_1000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0100)  => dpu_strobe_iss@1 in [16'b0000_0000_0011_0000]")
  u_ovl_intf_assert_6841d35ee41a654de3322690618932d6a86bb062 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0100) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_0011_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0101)  => dpu_strobe_iss@1 in [16'b0000_0000_0110_0000]")
  u_ovl_intf_assert_1010f32749c1127f05926e4f518442d664201f18 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0101) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_0110_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0110)  => dpu_strobe_iss@1 in [16'b0000_0000_1100_0000]")
  u_ovl_intf_assert_1a5c4ba9934c2e8a26fcfd3396e65d66081958a0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0110) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_1100_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0111)  => dpu_strobe_iss@1 in [16'b0000_0001_1000_0000, 16'b0000_0000_1000_0000]")
  u_ovl_intf_assert_bf9bfd06ccef069b44b63df3e5950f690ea212bc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0111) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0001_1000_0000) | (dpu_strobe_iss_reg ==  16'b0000_0000_1000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1000)  => dpu_strobe_iss@1 in [16'b0000_0011_0000_0000, 16'b0000_0001_0000_0000]")
  u_ovl_intf_assert_91f3cb112fed0e415c3c3d1d5fd99d5e4b082e26 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1000) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0011_0000_0000) | (dpu_strobe_iss_reg ==  16'b0000_0001_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1001)  => dpu_strobe_iss@1 in [16'b0000_0110_0000_0000]")
  u_ovl_intf_assert_7018d51fbd9db91a8f1a23efcc195f4d99f76aca (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1001) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0110_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1010)  => dpu_strobe_iss@1 in [16'b0000_1100_0000_0000]")
  u_ovl_intf_assert_1f8a2a0d73d7bcffecd48cecb19f82d5d5b33a9f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1010) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_1100_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1011)  => dpu_strobe_iss@1 in [16'b0001_1000_0000_0000]")
  u_ovl_intf_assert_0384a3e180482622edaf4288c675c8c35a1ca3fe (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1011) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0001_1000_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1100)  => dpu_strobe_iss@1 in [16'b0011_0000_0000_0000]")
  u_ovl_intf_assert_b524ca6817f0ec32f879167cd76b3bc26da37fa8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1100) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0011_0000_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1101)  => dpu_strobe_iss@1 in [16'b0110_0000_0000_0000]")
  u_ovl_intf_assert_1ee57da6a9fb84d406b26933d2e5dc4e4fca0a5c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1101) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0110_0000_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1110)  => dpu_strobe_iss@1 in [16'b1100_0000_0000_0000]")
  u_ovl_intf_assert_30c3059ef140e84039d32a60b470984918cbc543 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1110) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b1100_0000_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1111)  => dpu_strobe_iss@1 in [16'b1000_0000_0000_0000]")
  u_ovl_intf_assert_172acda855408ce987c7d5716ddfe60ce7ea7189 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (hword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1111) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b1000_0000_0000_0000))));


  // Note unaligned LSM's can produce some strange combinations, which doesn't matter because they will DABORT
  assign word_strobe_antecedent  = entering_dcu_reg & dpu_valid_iss_reg & (dpu_size_iss_reg == `CA53_SIZE_WORD) & (dpu_length_iss_reg == 5'b0000);

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0000)  => dpu_strobe_iss@1 in [16'b0000_0000_0000_1111,  16'b0000_0000_0000_0111,  16'b0000_0000_0000_0011, 16'b0000_0000_0000_0001]")
  u_ovl_intf_assert_af2b9c03816ddc6767b150325038355e37357d8d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0000) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_0000_1111) | (dpu_strobe_iss_reg ==   16'b0000_0000_0000_0111) | (dpu_strobe_iss_reg ==   16'b0000_0000_0000_0011) | (dpu_strobe_iss_reg ==  16'b0000_0000_0000_0001))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0001)  => dpu_strobe_iss@1 in [16'b0000_0000_0001_1110]")
  u_ovl_intf_assert_05a53d2b11e1fb3712da4655aa3fc5e12e450e33 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0001) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_0001_1110))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0010)  => dpu_strobe_iss@1 in [16'b0000_0000_0011_1100]")
  u_ovl_intf_assert_80717467cab5b18878e9d0afb9e501a22240a3d1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0010) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_0011_1100))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0011)  => dpu_strobe_iss@1 in [16'b0000_0000_0111_1000]")
  u_ovl_intf_assert_5400aff8531695032e37b71515f6f94c86ec4baf (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0011) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_0111_1000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0100)  => dpu_strobe_iss@1 in [16'b0000_0000_1111_0000]")
  u_ovl_intf_assert_bb8f07303e74d6eb3a4cd519556c6944d65bd440 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0100) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_1111_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0101)  => dpu_strobe_iss@1 in [16'b0000_0001_1110_0000, 16'b0000_0000_1110_0000]")
  u_ovl_intf_assert_dc4565d3429ffff2f171f7e8ae5a5d9fd38900a0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0101) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0001_1110_0000) | (dpu_strobe_iss_reg ==  16'b0000_0000_1110_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0110)  => dpu_strobe_iss@1 in [16'b0000_0011_1100_0000, 16'b0000_0000_1100_0000]")
  u_ovl_intf_assert_7875d19f7ff614a309001cd257b3a19b90b9f85a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0110) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0011_1100_0000) | (dpu_strobe_iss_reg ==  16'b0000_0000_1100_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0111)  => dpu_strobe_iss@1 in [16'b0000_0111_1000_0000, 16'b0000_0000_1000_0000]")
  u_ovl_intf_assert_bd6aab57a095d1cae9a8df0de9ee3476e50627d8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0111) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0111_1000_0000) | (dpu_strobe_iss_reg ==  16'b0000_0000_1000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1000)  => dpu_strobe_iss@1 in [16'b0000_1111_0000_0000, 16'b0000_0111_0000_0000,  16'b0000_0011_0000_0000, 16'b0000_0001_0000_0000]")
  u_ovl_intf_assert_f98f67b554625f16c810bf2be5f4b5696c1b3522 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1000) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_1111_0000_0000) | (dpu_strobe_iss_reg ==  16'b0000_0111_0000_0000) | (dpu_strobe_iss_reg ==   16'b0000_0011_0000_0000) | (dpu_strobe_iss_reg ==  16'b0000_0001_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1001)  => dpu_strobe_iss@1 in [16'b0001_1110_0000_0000]")
  u_ovl_intf_assert_f7db4f280a2b5a87062419ac45eaf5b9715f3dfc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1001) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0001_1110_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1010)  => dpu_strobe_iss@1 in [16'b0011_1100_0000_0000]")
  u_ovl_intf_assert_7401ccc817fb66b83a7c8d678e9cdcb8ffeff946 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1010) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0011_1100_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1011)  => dpu_strobe_iss@1 in [16'b0111_1000_0000_0000]")
  u_ovl_intf_assert_63f97d0b7c230d5578e8aeec43cef3c5e689cd73 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1011) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0111_1000_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1100)  => dpu_strobe_iss@1 in [16'b1111_0000_0000_0000]")
  u_ovl_intf_assert_5984874d96e6908cadbba01de25b3c988ed38c1b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1100) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b1111_0000_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1101)  => dpu_strobe_iss@1 in [16'b1110_0000_0000_0000]")
  u_ovl_intf_assert_0bd472337b37b054c246dee6df3908fb9505ed4c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1101) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b1110_0000_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1110)  => dpu_strobe_iss@1 in [16'b1100_0000_0000_0000]")
  u_ovl_intf_assert_821b01d34fd2f035b277549db78a0c4262f826f8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1110) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b1100_0000_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1111)  => dpu_strobe_iss@1 in [16'b1000_0000_0000_0000]")
  u_ovl_intf_assert_3bdae3069c05861753e02d2ca6632d8558d21150 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (word_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1111) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b1000_0000_0000_0000))));


  assign dword_strobe_antecedent  = entering_dcu_reg & dpu_valid_iss_reg & (dpu_size_iss_reg == `CA53_SIZE_DWORD) && (dpu_length_iss_reg == 5'b00001);

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0000)  => dpu_strobe_iss@1 in [16'b0000_0000_1111_1111, 16'b0000_0000_0111_1111,   16'b0000_0000_0011_1111, 16'b0000_0000_0001_1111, 16'b0000_0000_0000_1111, 16'b0000_0000_0000_0111, 16'b0000_0000_0000_0011, 16'b0000_0000_0000_0001]")
  u_ovl_intf_assert_c85bbeb84eadb97c657f2493c8c47b077901e49c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0000) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_1111_1111) | (dpu_strobe_iss_reg ==  16'b0000_0000_0111_1111) | (dpu_strobe_iss_reg ==    16'b0000_0000_0011_1111) | (dpu_strobe_iss_reg ==  16'b0000_0000_0001_1111) | (dpu_strobe_iss_reg ==  16'b0000_0000_0000_1111) | (dpu_strobe_iss_reg ==  16'b0000_0000_0000_0111) | (dpu_strobe_iss_reg ==  16'b0000_0000_0000_0011) | (dpu_strobe_iss_reg ==  16'b0000_0000_0000_0001))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0001)  => dpu_strobe_iss@1 in [16'b0000_0001_1111_1110, 16'b0000_0000_1111_1110]")
  u_ovl_intf_assert_baf48059b5030e7fe39e3b00b9636ba6b5c71ac8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0001) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0001_1111_1110) | (dpu_strobe_iss_reg ==  16'b0000_0000_1111_1110))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0010)  => dpu_strobe_iss@1 in [16'b0000_0011_1111_1100, 16'b0000_0000_1111_1100]")
  u_ovl_intf_assert_df53c9fc41edec6049ecffd369ba25c7971c274e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0010) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0011_1111_1100) | (dpu_strobe_iss_reg ==  16'b0000_0000_1111_1100))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0011)  => dpu_strobe_iss@1 in [16'b0000_0111_1111_1000, 16'b0000_0000_1111_1000]")
  u_ovl_intf_assert_af863e3a5983b7352846967c80c957a79cbb1603 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0011) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0111_1111_1000) | (dpu_strobe_iss_reg ==  16'b0000_0000_1111_1000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0100)  => dpu_strobe_iss@1 in [16'b0000_1111_1111_0000, 16'b0000_0000_1111_0000]")
  u_ovl_intf_assert_5516ff72ca40e07d0606308cf63edd2813b11e35 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0100) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_1111_1111_0000) | (dpu_strobe_iss_reg ==  16'b0000_0000_1111_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0101)  => dpu_strobe_iss@1 in [16'b0001_1111_1110_0000, 16'b0000_0000_1110_0000]")
  u_ovl_intf_assert_61590e360fa08c4d97791e93eb9565c20658cfce (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0101) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0001_1111_1110_0000) | (dpu_strobe_iss_reg ==  16'b0000_0000_1110_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0110)  => dpu_strobe_iss@1 in [16'b0011_1111_1100_0000, 16'b0000_0000_1100_0000]")
  u_ovl_intf_assert_21d461c47358eb6cb5e77e23cb13036243cc3cfd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0110) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0011_1111_1100_0000) | (dpu_strobe_iss_reg ==  16'b0000_0000_1100_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0111)  => dpu_strobe_iss@1 in [16'b0111_1111_1000_0000, 16'b0000_0000_1000_0000]")
  u_ovl_intf_assert_9a0f6facedcde20270d2e4c23d01d0f1e3d3d5ff (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b0111) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0111_1111_1000_0000) | (dpu_strobe_iss_reg ==  16'b0000_0000_1000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1000)  => dpu_strobe_iss@1 in [16'b1111_1111_0000_0000, 16'b0111_1111_0000_0000,   16'b0011_1111_0000_0000, 16'b0001_1111_0000_0000, 16'b0000_1111_0000_0000, 16'b0000_0111_0000_0000, 16'b0000_0011_0000_0000, 16'b0000_0001_0000_0000]")
  u_ovl_intf_assert_ce92c80da10f6f27716eeb4a535ea33282c52c2f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1000) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b1111_1111_0000_0000) | (dpu_strobe_iss_reg ==  16'b0111_1111_0000_0000) | (dpu_strobe_iss_reg ==    16'b0011_1111_0000_0000) | (dpu_strobe_iss_reg ==  16'b0001_1111_0000_0000) | (dpu_strobe_iss_reg ==  16'b0000_1111_0000_0000) | (dpu_strobe_iss_reg ==  16'b0000_0111_0000_0000) | (dpu_strobe_iss_reg ==  16'b0000_0011_0000_0000) | (dpu_strobe_iss_reg ==  16'b0000_0001_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1001)  => dpu_strobe_iss@1 in [16'b1111_1110_0000_0000]")
  u_ovl_intf_assert_a266463341feb50c657054a1a5b61c7231414d0e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1001) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b1111_1110_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1010)  => dpu_strobe_iss@1 in [16'b1111_1100_0000_0000]")
  u_ovl_intf_assert_122283bb63c9580438a21e2f966ba716beecf450 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1010) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b1111_1100_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1011)  => dpu_strobe_iss@1 in [16'b1111_1000_0000_0000]")
  u_ovl_intf_assert_fcdf0317d1f3d23429a8702768a7af221361b076 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1011) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b1111_1000_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1100)  => dpu_strobe_iss@1 in [16'b1111_0000_0000_0000]")
  u_ovl_intf_assert_39de89945b7c927a3d5c607a56733eb5666b94a7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1100) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b1111_0000_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1101)  => dpu_strobe_iss@1 in [16'b1110_0000_0000_0000]")
  u_ovl_intf_assert_94a2b7ebc277e117ac0671861bf98d58a833d363 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1101) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b1110_0000_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1110)  => dpu_strobe_iss@1 in [16'b1100_0000_0000_0000]")
  u_ovl_intf_assert_5533c5543e51c0fe77f8db9869c0cea803975df5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1110) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b1100_0000_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1111)  => dpu_strobe_iss@1 in [16'b1000_0000_0000_0000]")
  u_ovl_intf_assert_cd073f5029b7de0edc4cded9796ed1a85cf80bda (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dword_strobe_antecedent & (dpu_va_dc1[3:0] == 4'b1111) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b1000_0000_0000_0000))));


  // The strobes on doubleword aligned accesses must be accurate on exclusives

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & dpu_valid_iss@1 & dpu_excl_iss@1 & (dpu_size_iss@1 == `CA53_SIZE_HWORD) & (dpu_va_dc1[3:0] == 4'b0000)  => dpu_strobe_iss@1 in [16'b0000_0000_0000_0011]")
  u_ovl_intf_assert_0e9c58c2a3a3c6f611b724905431c7d9beb79c13 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & dpu_valid_iss_reg & dpu_excl_iss_reg & (dpu_size_iss_reg == `CA53_SIZE_HWORD) & (dpu_va_dc1[3:0] == 4'b0000) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_0000_0011))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & dpu_valid_iss@1 & dpu_excl_iss@1 & (dpu_size_iss@1 == `CA53_SIZE_HWORD) & (dpu_va_dc1[3:0] == 4'b1000)  => dpu_strobe_iss@1 in [16'b0000_0011_0000_0000]")
  u_ovl_intf_assert_d2950e10258850954a7e8cbadd625dd182e9b343 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & dpu_valid_iss_reg & dpu_excl_iss_reg & (dpu_size_iss_reg == `CA53_SIZE_HWORD) & (dpu_va_dc1[3:0] == 4'b1000) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0011_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & dpu_valid_iss@1 & dpu_excl_iss@1 & (dpu_size_iss@1 == `CA53_SIZE_WORD)  & (dpu_va_dc1[3:0] == 4'b0000)  => dpu_strobe_iss@1 in [16'b0000_0000_0000_1111]")
  u_ovl_intf_assert_645537868a2f8190bc8d4f7216a3ce05991fd9dd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & dpu_valid_iss_reg & dpu_excl_iss_reg & (dpu_size_iss_reg == `CA53_SIZE_WORD)  & (dpu_va_dc1[3:0] == 4'b0000) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_0000_1111))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & dpu_valid_iss@1 & dpu_excl_iss@1 & (dpu_size_iss@1 == `CA53_SIZE_WORD)  & (dpu_va_dc1[3:0] == 4'b1000)  => dpu_strobe_iss@1 in [16'b0000_1111_0000_0000]")
  u_ovl_intf_assert_5ee4e887369d48725b9f203fa6a144ac3ad61e96 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & dpu_valid_iss_reg & dpu_excl_iss_reg & (dpu_size_iss_reg == `CA53_SIZE_WORD)  & (dpu_va_dc1[3:0] == 4'b1000) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_1111_0000_0000))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & dpu_valid_iss@1 & dpu_excl_iss@1 & (dpu_size_iss@1 == `CA53_SIZE_DWORD) & (dpu_va_dc1[3:0] == 4'b0000)  => dpu_strobe_iss@1 in [16'b0000_0000_1111_1111,  16'b1111_1111_1111_1111]")
  u_ovl_intf_assert_64088ad9d0720bc6d56e9e4eb0126102ce58ff55 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & dpu_valid_iss_reg & dpu_excl_iss_reg & (dpu_size_iss_reg == `CA53_SIZE_DWORD) & (dpu_va_dc1[3:0] == 4'b0000) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_1111_1111) | (dpu_strobe_iss_reg ==   16'b1111_1111_1111_1111))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & dpu_valid_iss@1 & dpu_excl_iss@1 & (dpu_size_iss@1 == `CA53_SIZE_DWORD) & (dpu_va_dc1[3:0] == 4'b1000)  => dpu_strobe_iss@1 in [16'b1111_1111_0000_0000]")
  u_ovl_intf_assert_8bd763e656fb037fd080c067d8daf1ef96eb5b53 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & dpu_valid_iss_reg & dpu_excl_iss_reg & (dpu_size_iss_reg == `CA53_SIZE_DWORD) & (dpu_va_dc1[3:0] == 4'b1000) ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b1111_1111_0000_0000))));


  // Only the second part of a cross_64 can access less than the whole word if the size is word
  // - Note unaligned LSM's can produce some strange combinations, which doesn't matter because they will DABORT

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & dpu_valid_iss@1 & (dpu_size_iss@1 == `CA53_SIZE_WORD) & (dpu_va_dc1[1:0] == 2'b00) & ~dpu_second_x64_iss@1 & (dpu_length_iss@1 == 5'b00000)   => dpu_strobe_iss@1 in [16'b0000_0000_0000_1111, 16'b0000_0000_0001_1110, 16'b0000_0000_0011_1100, 16'b0000_0000_0111_1000, 16'b0000_0000_1111_0000, 16'b0000_1111_0000_0000, 16'b0001_1110_0000_0000, 16'b0011_1100_0000_0000, 16'b0111_1000_0000_0000, 16'b1111_0000_0000_0000]")
  u_ovl_intf_assert_292b9f564993877e22ccb0680bd320b06ced3922 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & dpu_valid_iss_reg & (dpu_size_iss_reg == `CA53_SIZE_WORD) & (dpu_va_dc1[1:0] == 2'b00) & ~dpu_second_x64_iss_reg & (dpu_length_iss_reg == 5'b00000)  ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_0000_1111) | (dpu_strobe_iss_reg ==  16'b0000_0000_0001_1110) | (dpu_strobe_iss_reg ==  16'b0000_0000_0011_1100) | (dpu_strobe_iss_reg ==  16'b0000_0000_0111_1000) | (dpu_strobe_iss_reg ==  16'b0000_0000_1111_0000) | (dpu_strobe_iss_reg ==  16'b0000_1111_0000_0000) | (dpu_strobe_iss_reg ==  16'b0001_1110_0000_0000) | (dpu_strobe_iss_reg ==  16'b0011_1100_0000_0000) | (dpu_strobe_iss_reg ==  16'b0111_1000_0000_0000) | (dpu_strobe_iss_reg ==  16'b1111_0000_0000_0000))));


  // Only the second part of a cross_64 can access less than a half-word if the size is half-word

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & dpu_valid_iss@1 & (dpu_size_iss@1 == `CA53_SIZE_HWORD) & (dpu_va_dc1[1:0] == 2'b00) & ~dpu_second_x64_iss@1   => dpu_strobe_iss@1 in [16'b0000_0000_0000_0011, 16'b0000_0000_0000_0110, 16'b0000_0000_0000_1100, 16'b0000_0000_0001_1000, 16'b0000_0000_0011_0000, 16'b0000_0000_0110_0000, 16'b0000_0000_1100_0000, 16'b0000_0001_1000_0000, 16'b0000_0011_0000_0000, 16'b0000_0110_0000_0000, 16'b0000_1100_0000_0000, 16'b0001_1000_0000_0000, 16'b0011_0000_0000_0000, 16'b0110_0000_0000_0000, 16'b1100_0000_0000_0000]")
  u_ovl_intf_assert_364c40eae30ddebf0e566528d15a62204406cc2b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & dpu_valid_iss_reg & (dpu_size_iss_reg == `CA53_SIZE_HWORD) & (dpu_va_dc1[1:0] == 2'b00) & ~dpu_second_x64_iss_reg  ),
    .consequent_expr (((dpu_strobe_iss_reg == 16'b0000_0000_0000_0011) | (dpu_strobe_iss_reg ==  16'b0000_0000_0000_0110) | (dpu_strobe_iss_reg ==  16'b0000_0000_0000_1100) | (dpu_strobe_iss_reg ==  16'b0000_0000_0001_1000) | (dpu_strobe_iss_reg ==  16'b0000_0000_0011_0000) | (dpu_strobe_iss_reg ==  16'b0000_0000_0110_0000) | (dpu_strobe_iss_reg ==  16'b0000_0000_1100_0000) | (dpu_strobe_iss_reg ==  16'b0000_0001_1000_0000) | (dpu_strobe_iss_reg ==  16'b0000_0011_0000_0000) | (dpu_strobe_iss_reg ==  16'b0000_0110_0000_0000) | (dpu_strobe_iss_reg ==  16'b0000_1100_0000_0000) | (dpu_strobe_iss_reg ==  16'b0001_1000_0000_0000) | (dpu_strobe_iss_reg ==  16'b0011_0000_0000_0000) | (dpu_strobe_iss_reg ==  16'b0110_0000_0000_0000) | (dpu_strobe_iss_reg ==  16'b1100_0000_0000_0000))));


  // Exclusives must always have strict alignment checking

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_any_iss & dpu_excl_iss & dpu_first_iss  => (dpu_req_align_iss & (dpu_align_size_iss == {1'b0, dpu_size_iss})) | (dpu_req_align_iss & (dpu_align_size_iss[2] & (dpu_size_iss == `CA53_SIZE_DWORD))) |   (dpu_align_size_iss == {1'b0, `CA53_SIZE_BYTE})")
  u_ovl_intf_assert_57e60dbd33ca679b07738d559162b04a53d7f28b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_any_iss & dpu_excl_iss & dpu_first_iss ),
    .consequent_expr ((dpu_req_align_iss & (dpu_align_size_iss == {1'b0, dpu_size_iss})) | (dpu_req_align_iss & (dpu_align_size_iss[2] & (dpu_size_iss == `CA53_SIZE_DWORD))) |   (dpu_align_size_iss == {1'b0, `CA53_SIZE_BYTE})));


  // CP ops must have align size as none (unless for STLR)
  // - note DCZ is not marked as a CP op

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_cp_iss & ~dpu_flush & ~dpu_ldar_stlr_iss  => dpu_align_size_iss == `CA53_ALIGN_NONE")
  u_ovl_intf_assert_4300eaf95ab45c1e8f30938d315c3ea9efcf5744 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_cp_iss & ~dpu_flush & ~dpu_ldar_stlr_iss ),
    .consequent_expr (dpu_align_size_iss == `CA53_ALIGN_NONE));


  // The address of the first access of a cross-64 load must be consistent with the size
  // - note that on LDP.32 instructions, the size is indicated as word, but the alignment check
  //   is done across 64-bits, as that is the amount of data transferred, so that is not checked
  //   here

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & dpu_valid_iss@1 & ~dpu_store_iss@1 &  (dpu_size_iss@1 == `CA53_SIZE_HWORD)                           & dpu_cross_64_iss@1 & ~dpu_second_x64_iss@1  => dpu_va_dc1[2:0] > 3'b110")
  u_ovl_intf_assert_a33fab45cf988ad457c68bdd67dff13b1dcb90bd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & dpu_valid_iss_reg & ~dpu_store_iss_reg &  (dpu_size_iss_reg == `CA53_SIZE_HWORD)                           & dpu_cross_64_iss_reg & ~dpu_second_x64_iss_reg ),
    .consequent_expr (dpu_va_dc1[2:0] > 3'b110));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & dpu_valid_iss@1 & ~dpu_store_iss@1 &  (dpu_size_iss@1 == `CA53_SIZE_WORD)  & (dpu_length_iss@1 == 0) & dpu_cross_64_iss@1 & ~dpu_second_x64_iss@1  => dpu_va_dc1[2:0] > 3'b100")
  u_ovl_intf_assert_04b48bea9d38433b4d3a417b8c48277acdb6d0ae (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & dpu_valid_iss_reg & ~dpu_store_iss_reg &  (dpu_size_iss_reg == `CA53_SIZE_WORD)  & (dpu_length_iss_reg == 0) & dpu_cross_64_iss_reg & ~dpu_second_x64_iss_reg ),
    .consequent_expr (dpu_va_dc1[2:0] > 3'b100));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & dpu_valid_iss@1 & ~dpu_store_iss@1 & ((dpu_size_iss@1 == `CA53_SIZE_DWORD) | (dpu_length_iss@1 > 0)) & dpu_cross_64_iss@1 & ~dpu_second_x64_iss@1  => dpu_va_dc1[2:0] > 3'b000")
  u_ovl_intf_assert_a7ff948d2cac63ff72960d30c79ed56ef3f19bcd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & dpu_valid_iss_reg & ~dpu_store_iss_reg & ((dpu_size_iss_reg == `CA53_SIZE_DWORD) | (dpu_length_iss_reg > 0)) & dpu_cross_64_iss_reg & ~dpu_second_x64_iss_reg ),
    .consequent_expr (dpu_va_dc1[2:0] > 3'b000));


  // The address of the first access of a cross-128 store must be consistent with the size

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & dpu_valid_iss@1 &  dpu_store_iss@1 &  (dpu_size_iss@1 == `CA53_SIZE_HWORD)                           & dpu_cross_64_iss@1 & ~dpu_second_x64_iss@1  => dpu_va_dc1[3:0] > 4'b1110")
  u_ovl_intf_assert_32a4f43999c7b4dcebfc1242c399fc8c6d729acc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & dpu_valid_iss_reg &  dpu_store_iss_reg &  (dpu_size_iss_reg == `CA53_SIZE_HWORD)                           & dpu_cross_64_iss_reg & ~dpu_second_x64_iss_reg ),
    .consequent_expr (dpu_va_dc1[3:0] > 4'b1110));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & dpu_valid_iss@1 &  dpu_store_iss@1 &  (dpu_size_iss@1 == `CA53_SIZE_WORD)  & (dpu_length_iss@1 == 0) & dpu_cross_64_iss@1 & ~dpu_second_x64_iss@1  => dpu_va_dc1[3:0] > 4'b1100")
  u_ovl_intf_assert_46a957ccb2ae08e959b24a0b888f7a637c404e52 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & dpu_valid_iss_reg &  dpu_store_iss_reg &  (dpu_size_iss_reg == `CA53_SIZE_WORD)  & (dpu_length_iss_reg == 0) & dpu_cross_64_iss_reg & ~dpu_second_x64_iss_reg ),
    .consequent_expr (dpu_va_dc1[3:0] > 4'b1100));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & dpu_valid_iss@1 &  dpu_store_iss@1 & ((dpu_size_iss@1 == `CA53_SIZE_DWORD) | (dpu_length_iss@1 > 0)) & dpu_cross_64_iss@1 & ~dpu_second_x64_iss@1  => dpu_va_dc1[3:0] > 4'b0000")
  u_ovl_intf_assert_fb42bef0ad245344580b65cdc62521e67138b0fd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & dpu_valid_iss_reg &  dpu_store_iss_reg & ((dpu_size_iss_reg == `CA53_SIZE_DWORD) | (dpu_length_iss_reg > 0)) & dpu_cross_64_iss_reg & ~dpu_second_x64_iss_reg ),
    .consequent_expr (dpu_va_dc1[3:0] > 4'b0000));


  // The address of the second cross-64 must be word aligned

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & dpu_valid_iss@1 & dpu_second_x64_iss@1  => dpu_va_dc1[1:0] == 2'b00")
  u_ovl_intf_assert_cf01ff306e7b853ebf8d8e333dbcb505f88b9abe (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & dpu_valid_iss_reg & dpu_second_x64_iss_reg ),
    .consequent_expr (dpu_va_dc1[1:0] == 2'b00));


  // Both halves of a cross-64 must agree about whether cross-64 is store or not.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    prev_dpu_store_iss <= 1'b0;
  else if (entering_dcu)
    prev_dpu_store_iss <= dpu_store_iss;



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu & dpu_cross_64_iss & dpu_second_x64_iss  => dpu_store_iss == prev_dpu_store_iss")
  u_ovl_intf_assert_89694ccb27d569f35f788dc043875c4e2341f573 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu & dpu_cross_64_iss & dpu_second_x64_iss ),
    .consequent_expr (dpu_store_iss == prev_dpu_store_iss));


  // Only some encodings of cp_op are valid.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_cp_iss & ~dpu_flush   => dpu_cp_op_iss in [`CA53_CPOP_L2_CTLR,   `CA53_CPOP_L2_ECTLR,  `CA53_CPOP_L2_ACTLR, `CA53_CPOP_L2_MEM_ERR_SR, `CA53_CPOP_CDBGDCT,   `CA53_CPOP_CDBGDCD,   `CA53_CPOP_CDBGICT,  `CA53_CPOP_CDBGICD,  `CA53_CPOP_CDBGTD, `CA53_CPOP_CDBGDR0,   `CA53_CPOP_CDBGDR1,   `CA53_CPOP_CDBGDR2,  `CA53_CPOP_CDBGDR3, `CA53_CPOP_ATS1C,     `CA53_CPOP_ATS12NSO,  `CA53_CPOP_ATS1H, `CA53_CPOP_ATS1E01,   `CA53_CPOP_ATS12E01,  `CA53_CPOP_ATS1E2,   `CA53_CPOP_ATS1E3, `CA53_CPOP_TTBR0,     `CA53_CPOP_TTBR1,     `CA53_CPOP_TTBR0_EL1,`CA53_CPOP_TTBR0_EL2,`CA53_CPOP_TTBR0_EL3, `CA53_CPOP_TTBCR,     `CA53_CPOP_TCR_EL1,   `CA53_CPOP_TCR_EL2,  `CA53_CPOP_TCR_EL3,  `CA53_CPOP_HTTBR, `CA53_CPOP_VTTBR,     `CA53_CPOP_VTTBR_EL2, `CA53_CPOP_HTCR,     `CA53_CPOP_VTCR,     `CA53_CPOP_VTCR_EL2, `CA53_CPOP_PAR,       `CA53_CPOP_PAR_EL1,   `CA53_CPOP_HMAIR0,   `CA53_CPOP_HMAIR1, `CA53_CPOP_MAIR0,     `CA53_CPOP_MAIR1,     `CA53_CPOP_MAIR_EL1, `CA53_CPOP_MAIR_EL2, `CA53_CPOP_MAIR_EL3, `CA53_CPOP_CONTEXTIDR,`CA53_CPOP_CONTEXTIDR_EL1, `CA53_CPOP_DBGBVR0,   `CA53_CPOP_DBGBVR1,  `CA53_CPOP_DBGBVR2,  `CA53_CPOP_DBGBVR3,  `CA53_CPOP_DBGBVR4,  `CA53_CPOP_DBGBVR5, `CA53_CPOP_DBGBXVR4,  `CA53_CPOP_DBGBXVR5, `CA53_CPOP_DBGBCR0,   `CA53_CPOP_DBGBCR1,  `CA53_CPOP_DBGBCR2,  `CA53_CPOP_DBGBCR3,  `CA53_CPOP_DBGBCR4,  `CA53_CPOP_DBGBCR5, `CA53_CPOP_DBGWVR0,   `CA53_CPOP_DBGWVR1,  `CA53_CPOP_DBGWVR2,  `CA53_CPOP_DBGWVR3, `CA53_CPOP_DBGWCR0,   `CA53_CPOP_DBGWCR1,  `CA53_CPOP_DBGWCR2,  `CA53_CPOP_DBGWCR3, `CA53_CPOP_DBGVCR, `CA53_CPOP_ICIALLU,     `CA53_CPOP_ICIALLUIS,     `CA53_CPOP_ICIMVAU, `CA53_CPOP_TLBIALLIS,   `CA53_CPOP_TLBIMVAIS,     `CA53_CPOP_TLBIASIDIS,     `CA53_CPOP_TLBIMVAAIS, `CA53_CPOP_TLBIMVALIS,  `CA53_CPOP_TLBIMVAALIS, `CA53_CPOP_TLBIMVAHIS,  `CA53_CPOP_TLBIALLHIS,    `CA53_CPOP_TLBIALLNSNHIS,  `CA53_CPOP_TLBIMVALHIS, `CA53_CPOP_TLBIALL,     `CA53_CPOP_TLBIMVA,       `CA53_CPOP_TLBIASID,       `CA53_CPOP_TLBIMVAA, `CA53_CPOP_TLBIMVAL,    `CA53_CPOP_TLBIMVAAL, `CA53_CPOP_TLBIMVAH,    `CA53_CPOP_TLBIALLH,      `CA53_CPOP_TLBIALLNSNH,    `CA53_CPOP_TLBIMVALH, `CA53_CPOP_TLBIIPAS2,   `CA53_CPOP_TLBIIPAS2IS,   `CA53_CPOP_TLBIIPAS2L,     `CA53_CPOP_TLBIIPAS2LIS, `CA53_CPOP_TLBIVAE1,    `CA53_CPOP_TLBIVAE1IS,    `CA53_CPOP_TLBIVALE1,      `CA53_CPOP_TLBIVALE1IS, `CA53_CPOP_TLBIVAAE1,   `CA53_CPOP_TLBIVAAE1IS,   `CA53_CPOP_TLBIVAALE1,     `CA53_CPOP_TLBIVAALE1IS, `CA53_CPOP_TLBIIPAS2E1, `CA53_CPOP_TLBIIPAS2E1IS, `CA53_CPOP_TLBIIPAS2LE1,   `CA53_CPOP_TLBIIPAS2LE1IS, `CA53_CPOP_TLBIVAE2,    `CA53_CPOP_TLBIVAE2IS,    `CA53_CPOP_TLBIVALE2,      `CA53_CPOP_TLBIVALE2IS, `CA53_CPOP_TLBIVAE3,    `CA53_CPOP_TLBIVAE3IS,    `CA53_CPOP_TLBIVALE3,      `CA53_CPOP_TLBIVALE3IS, `CA53_CPOP_TLBIASIDE1,  `CA53_CPOP_TLBIASIDE1IS,  `CA53_CPOP_TLBIVMALLE1,    `CA53_CPOP_TLBIVMALLE1IS, `CA53_CPOP_TLBIVMALLS12E1, `CA53_CPOP_TLBIVMALLS12E1IS, `CA53_CPOP_TLBIALLE1,   `CA53_CPOP_TLBIALLE1IS,   `CA53_CPOP_TLBIALLE2,      `CA53_CPOP_TLBIALLE2IS, `CA53_CPOP_TLBIALLE3,   `CA53_CPOP_TLBIALLE3IS, `CA53_CPOP_DCISW,       `CA53_CPOP_DCIMVAC, `CA53_CPOP_DCCISW,      `CA53_CPOP_DCCIMVAC, `CA53_CPOP_DCCSW,       `CA53_CPOP_DCCMVAC,  `CA53_CPOP_DCCMVAU, `CA53_CPOP_CLREX, `CA53_CPOP_BPIALLIS,    `CA53_CPOP_BPIMVA, `CA53_CPOP_DMBNSHLD,    `CA53_CPOP_DMBISHLD, `CA53_CPOP_DMBOSHLD, `CA53_CPOP_DMBLD, `CA53_CPOP_DSBNS,       `CA53_CPOP_DSBIS,    `CA53_CPOP_DSBOS,    `CA53_CPOP_DSBSY, `CA53_CPOP_DMBNS,       `CA53_CPOP_DMBIS,    `CA53_CPOP_DMBOS,    `CA53_CPOP_DMBSY, `CA53_CPOP_DMBNSST,     `CA53_CPOP_DMBISST,  `CA53_CPOP_DMBOSST,  `CA53_CPOP_DMBSYST, `CA53_CPOP_CNTFRQ_EL0,       `CA53_CPOP_CNTPCT_EL0,       `CA53_CPOP_CNTVCT_EL0, `CA53_CPOP_CNTKCTL_EL1,      `CA53_CPOP_CNTVOFF_EL2,      `CA53_CPOP_CNTHCTL_EL2, `CA53_CPOP_CNTP_TVAL_EL0,    `CA53_CPOP_CNTP_CTL_EL0,     `CA53_CPOP_CNTP_CVAL_EL0, `CA53_CPOP_CNTV_TVAL_EL0,    `CA53_CPOP_CNTV_CTL_EL0,     `CA53_CPOP_CNTV_CVAL_EL0, `CA53_CPOP_CNTHP_TVAL_EL2,   `CA53_CPOP_CNTHP_CTL_EL2,    `CA53_CPOP_CNTHP_CVAL_EL2, `CA53_CPOP_CNTPS_TVAL_EL1,   `CA53_CPOP_CNTPS_CTL_EL1,    `CA53_CPOP_CNTPS_CVAL_EL1, `CA53_CPOP_GICC_IAR1_EL1,    `CA53_CPOP_GICC_IAR0_EL1,    `CA53_CPOP_GICC_EOIR1_EL1, `CA53_CPOP_GICC_EOIR0_EL1,   `CA53_CPOP_GICC_HPPIR1_EL1,  `CA53_CPOP_GICC_HPPIR0_EL1, `CA53_CPOP_GICC_BPR1_EL1,    `CA53_CPOP_GICC_BPR0_EL1,    `CA53_CPOP_GICC_DIR_EL1, `CA53_CPOP_GICC_PMR_EL1,     `CA53_CPOP_GICC_RPR_EL1,     `CA53_CPOP_GICC_AP0R0_EL1, `CA53_CPOP_GICC_AP1R0_EL1,   `CA53_CPOP_GICC_IGRPEN0_EL1, `CA53_CPOP_GICC_IGRPEN1_EL1, `CA53_CPOP_GICC_IGRPEN1_EL3, `CA53_CPOP_GICC_SRE_EL1,     `CA53_CPOP_GICC_SRE_EL2, `CA53_CPOP_GICC_SRE_EL3,     `CA53_CPOP_GICC_CTLR_EL1,    `CA53_CPOP_GICC_CTLR_EL3, `CA53_CPOP_GICC_SGI0R_EL1,   `CA53_CPOP_GICC_SGI1R_EL1,   `CA53_CPOP_GICC_ASGI1R_EL1, `CA53_CPOP_GICV_IAR1,        `CA53_CPOP_GICV_IAR0,        `CA53_CPOP_GICV_EOIR1, `CA53_CPOP_GICV_EOIR0,       `CA53_CPOP_GICV_HPPIR1,      `CA53_CPOP_GICV_HPPIR0, `CA53_CPOP_GICH_VMCR_BPR1,   `CA53_CPOP_GICH_VMCR_BPR0,   `CA53_CPOP_GICV_DIR, `CA53_CPOP_GICH_VMCR_PMR,    `CA53_CPOP_GICV_RPR,         `CA53_CPOP_GICH_AP1R0, `CA53_CPOP_GICH_AP0R0,       `CA53_CPOP_GICH_VMCR_VENG0,  `CA53_CPOP_GICH_VMCR_VENG1, `CA53_CPOP_GICH_HCR_SRE,     `CA53_CPOP_GICV_CTLR,        `CA53_CPOP_GICH_HCR, `CA53_CPOP_GICH_VTR,         `CA53_CPOP_GICH_VMCR,        `CA53_CPOP_GICH_MISR, `CA53_CPOP_GICH_EISR,        `CA53_CPOP_GICH_ELSR, `CA53_CPOP_GICH_LR0,         `CA53_CPOP_GICH_LR0_L,       `CA53_CPOP_GICH_LR0_H, `CA53_CPOP_GICH_LR1,         `CA53_CPOP_GICH_LR1_L,       `CA53_CPOP_GICH_LR1_H, `CA53_CPOP_GICH_LR2,         `CA53_CPOP_GICH_LR2_L,       `CA53_CPOP_GICH_LR2_H, `CA53_CPOP_GICH_LR3,         `CA53_CPOP_GICH_LR3_L,       `CA53_CPOP_GICH_LR3_H]")
  u_ovl_intf_assert_e8ceccbe83bc7d55409d2721bf748fafbebfc7a6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_cp_iss & ~dpu_flush  ),
    .consequent_expr (((dpu_cp_op_iss == `CA53_CPOP_L2_CTLR) | (dpu_cp_op_iss ==    `CA53_CPOP_L2_ECTLR) | (dpu_cp_op_iss ==   `CA53_CPOP_L2_ACTLR) | (dpu_cp_op_iss ==  `CA53_CPOP_L2_MEM_ERR_SR) | (dpu_cp_op_iss ==  `CA53_CPOP_CDBGDCT) | (dpu_cp_op_iss ==    `CA53_CPOP_CDBGDCD) | (dpu_cp_op_iss ==    `CA53_CPOP_CDBGICT) | (dpu_cp_op_iss ==   `CA53_CPOP_CDBGICD) | (dpu_cp_op_iss ==   `CA53_CPOP_CDBGTD) | (dpu_cp_op_iss ==  `CA53_CPOP_CDBGDR0) | (dpu_cp_op_iss ==    `CA53_CPOP_CDBGDR1) | (dpu_cp_op_iss ==    `CA53_CPOP_CDBGDR2) | (dpu_cp_op_iss ==   `CA53_CPOP_CDBGDR3) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS1C) | (dpu_cp_op_iss ==      `CA53_CPOP_ATS12NSO) | (dpu_cp_op_iss ==   `CA53_CPOP_ATS1H) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS1E01) | (dpu_cp_op_iss ==    `CA53_CPOP_ATS12E01) | (dpu_cp_op_iss ==   `CA53_CPOP_ATS1E2) | (dpu_cp_op_iss ==    `CA53_CPOP_ATS1E3) | (dpu_cp_op_iss ==  `CA53_CPOP_TTBR0) | (dpu_cp_op_iss ==      `CA53_CPOP_TTBR1) | (dpu_cp_op_iss ==      `CA53_CPOP_TTBR0_EL1) | (dpu_cp_op_iss == `CA53_CPOP_TTBR0_EL2) | (dpu_cp_op_iss == `CA53_CPOP_TTBR0_EL3) | (dpu_cp_op_iss ==  `CA53_CPOP_TTBCR) | (dpu_cp_op_iss ==      `CA53_CPOP_TCR_EL1) | (dpu_cp_op_iss ==    `CA53_CPOP_TCR_EL2) | (dpu_cp_op_iss ==   `CA53_CPOP_TCR_EL3) | (dpu_cp_op_iss ==   `CA53_CPOP_HTTBR) | (dpu_cp_op_iss ==  `CA53_CPOP_VTTBR) | (dpu_cp_op_iss ==      `CA53_CPOP_VTTBR_EL2) | (dpu_cp_op_iss ==  `CA53_CPOP_HTCR) | (dpu_cp_op_iss ==      `CA53_CPOP_VTCR) | (dpu_cp_op_iss ==      `CA53_CPOP_VTCR_EL2) | (dpu_cp_op_iss ==  `CA53_CPOP_PAR) | (dpu_cp_op_iss ==        `CA53_CPOP_PAR_EL1) | (dpu_cp_op_iss ==    `CA53_CPOP_HMAIR0) | (dpu_cp_op_iss ==    `CA53_CPOP_HMAIR1) | (dpu_cp_op_iss ==  `CA53_CPOP_MAIR0) | (dpu_cp_op_iss ==      `CA53_CPOP_MAIR1) | (dpu_cp_op_iss ==      `CA53_CPOP_MAIR_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_MAIR_EL2) | (dpu_cp_op_iss ==  `CA53_CPOP_MAIR_EL3) | (dpu_cp_op_iss ==  `CA53_CPOP_CONTEXTIDR) | (dpu_cp_op_iss == `CA53_CPOP_CONTEXTIDR_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGBVR0) | (dpu_cp_op_iss ==    `CA53_CPOP_DBGBVR1) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBVR2) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBVR3) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBVR4) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBVR5) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGBXVR4) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBXVR5) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGBCR0) | (dpu_cp_op_iss ==    `CA53_CPOP_DBGBCR1) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBCR2) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBCR3) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBCR4) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBCR5) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGWVR0) | (dpu_cp_op_iss ==    `CA53_CPOP_DBGWVR1) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGWVR2) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGWVR3) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGWCR0) | (dpu_cp_op_iss ==    `CA53_CPOP_DBGWCR1) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGWCR2) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGWCR3) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGVCR) | (dpu_cp_op_iss ==  `CA53_CPOP_ICIALLU) | (dpu_cp_op_iss ==      `CA53_CPOP_ICIALLUIS) | (dpu_cp_op_iss ==      `CA53_CPOP_ICIMVAU) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIALLIS) | (dpu_cp_op_iss ==    `CA53_CPOP_TLBIMVAIS) | (dpu_cp_op_iss ==      `CA53_CPOP_TLBIASIDIS) | (dpu_cp_op_iss ==      `CA53_CPOP_TLBIMVAAIS) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIMVALIS) | (dpu_cp_op_iss ==   `CA53_CPOP_TLBIMVAALIS) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIMVAHIS) | (dpu_cp_op_iss ==   `CA53_CPOP_TLBIALLHIS) | (dpu_cp_op_iss ==     `CA53_CPOP_TLBIALLNSNHIS) | (dpu_cp_op_iss ==   `CA53_CPOP_TLBIMVALHIS) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIALL) | (dpu_cp_op_iss ==      `CA53_CPOP_TLBIMVA) | (dpu_cp_op_iss ==        `CA53_CPOP_TLBIASID) | (dpu_cp_op_iss ==        `CA53_CPOP_TLBIMVAA) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIMVAL) | (dpu_cp_op_iss ==     `CA53_CPOP_TLBIMVAAL) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIMVAH) | (dpu_cp_op_iss ==     `CA53_CPOP_TLBIALLH) | (dpu_cp_op_iss ==       `CA53_CPOP_TLBIALLNSNH) | (dpu_cp_op_iss ==     `CA53_CPOP_TLBIMVALH) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIIPAS2) | (dpu_cp_op_iss ==    `CA53_CPOP_TLBIIPAS2IS) | (dpu_cp_op_iss ==    `CA53_CPOP_TLBIIPAS2L) | (dpu_cp_op_iss ==      `CA53_CPOP_TLBIIPAS2LIS) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIVAE1) | (dpu_cp_op_iss ==     `CA53_CPOP_TLBIVAE1IS) | (dpu_cp_op_iss ==     `CA53_CPOP_TLBIVALE1) | (dpu_cp_op_iss ==       `CA53_CPOP_TLBIVALE1IS) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIVAAE1) | (dpu_cp_op_iss ==    `CA53_CPOP_TLBIVAAE1IS) | (dpu_cp_op_iss ==    `CA53_CPOP_TLBIVAALE1) | (dpu_cp_op_iss ==      `CA53_CPOP_TLBIVAALE1IS) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIIPAS2E1) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIIPAS2E1IS) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIIPAS2LE1) | (dpu_cp_op_iss ==    `CA53_CPOP_TLBIIPAS2LE1IS) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIVAE2) | (dpu_cp_op_iss ==     `CA53_CPOP_TLBIVAE2IS) | (dpu_cp_op_iss ==     `CA53_CPOP_TLBIVALE2) | (dpu_cp_op_iss ==       `CA53_CPOP_TLBIVALE2IS) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIVAE3) | (dpu_cp_op_iss ==     `CA53_CPOP_TLBIVAE3IS) | (dpu_cp_op_iss ==     `CA53_CPOP_TLBIVALE3) | (dpu_cp_op_iss ==       `CA53_CPOP_TLBIVALE3IS) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIASIDE1) | (dpu_cp_op_iss ==   `CA53_CPOP_TLBIASIDE1IS) | (dpu_cp_op_iss ==   `CA53_CPOP_TLBIVMALLE1) | (dpu_cp_op_iss ==     `CA53_CPOP_TLBIVMALLE1IS) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIVMALLS12E1) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIVMALLS12E1IS) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIALLE1) | (dpu_cp_op_iss ==    `CA53_CPOP_TLBIALLE1IS) | (dpu_cp_op_iss ==    `CA53_CPOP_TLBIALLE2) | (dpu_cp_op_iss ==       `CA53_CPOP_TLBIALLE2IS) | (dpu_cp_op_iss ==  `CA53_CPOP_TLBIALLE3) | (dpu_cp_op_iss ==    `CA53_CPOP_TLBIALLE3IS) | (dpu_cp_op_iss ==  `CA53_CPOP_DCISW) | (dpu_cp_op_iss ==        `CA53_CPOP_DCIMVAC) | (dpu_cp_op_iss ==  `CA53_CPOP_DCCISW) | (dpu_cp_op_iss ==       `CA53_CPOP_DCCIMVAC) | (dpu_cp_op_iss ==  `CA53_CPOP_DCCSW) | (dpu_cp_op_iss ==        `CA53_CPOP_DCCMVAC) | (dpu_cp_op_iss ==   `CA53_CPOP_DCCMVAU) | (dpu_cp_op_iss ==  `CA53_CPOP_CLREX) | (dpu_cp_op_iss ==  `CA53_CPOP_BPIALLIS) | (dpu_cp_op_iss ==     `CA53_CPOP_BPIMVA) | (dpu_cp_op_iss ==  `CA53_CPOP_DMBNSHLD) | (dpu_cp_op_iss ==     `CA53_CPOP_DMBISHLD) | (dpu_cp_op_iss ==  `CA53_CPOP_DMBOSHLD) | (dpu_cp_op_iss ==  `CA53_CPOP_DMBLD) | (dpu_cp_op_iss ==  `CA53_CPOP_DSBNS) | (dpu_cp_op_iss ==        `CA53_CPOP_DSBIS) | (dpu_cp_op_iss ==     `CA53_CPOP_DSBOS) | (dpu_cp_op_iss ==     `CA53_CPOP_DSBSY) | (dpu_cp_op_iss ==  `CA53_CPOP_DMBNS) | (dpu_cp_op_iss ==        `CA53_CPOP_DMBIS) | (dpu_cp_op_iss ==     `CA53_CPOP_DMBOS) | (dpu_cp_op_iss ==     `CA53_CPOP_DMBSY) | (dpu_cp_op_iss ==  `CA53_CPOP_DMBNSST) | (dpu_cp_op_iss ==      `CA53_CPOP_DMBISST) | (dpu_cp_op_iss ==   `CA53_CPOP_DMBOSST) | (dpu_cp_op_iss ==   `CA53_CPOP_DMBSYST) | (dpu_cp_op_iss ==  `CA53_CPOP_CNTFRQ_EL0) | (dpu_cp_op_iss ==        `CA53_CPOP_CNTPCT_EL0) | (dpu_cp_op_iss ==        `CA53_CPOP_CNTVCT_EL0) | (dpu_cp_op_iss ==  `CA53_CPOP_CNTKCTL_EL1) | (dpu_cp_op_iss ==       `CA53_CPOP_CNTVOFF_EL2) | (dpu_cp_op_iss ==       `CA53_CPOP_CNTHCTL_EL2) | (dpu_cp_op_iss ==  `CA53_CPOP_CNTP_TVAL_EL0) | (dpu_cp_op_iss ==     `CA53_CPOP_CNTP_CTL_EL0) | (dpu_cp_op_iss ==      `CA53_CPOP_CNTP_CVAL_EL0) | (dpu_cp_op_iss ==  `CA53_CPOP_CNTV_TVAL_EL0) | (dpu_cp_op_iss ==     `CA53_CPOP_CNTV_CTL_EL0) | (dpu_cp_op_iss ==      `CA53_CPOP_CNTV_CVAL_EL0) | (dpu_cp_op_iss ==  `CA53_CPOP_CNTHP_TVAL_EL2) | (dpu_cp_op_iss ==    `CA53_CPOP_CNTHP_CTL_EL2) | (dpu_cp_op_iss ==     `CA53_CPOP_CNTHP_CVAL_EL2) | (dpu_cp_op_iss ==  `CA53_CPOP_CNTPS_TVAL_EL1) | (dpu_cp_op_iss ==    `CA53_CPOP_CNTPS_CTL_EL1) | (dpu_cp_op_iss ==     `CA53_CPOP_CNTPS_CVAL_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_IAR1_EL1) | (dpu_cp_op_iss ==     `CA53_CPOP_GICC_IAR0_EL1) | (dpu_cp_op_iss ==     `CA53_CPOP_GICC_EOIR1_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_EOIR0_EL1) | (dpu_cp_op_iss ==    `CA53_CPOP_GICC_HPPIR1_EL1) | (dpu_cp_op_iss ==   `CA53_CPOP_GICC_HPPIR0_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_BPR1_EL1) | (dpu_cp_op_iss ==     `CA53_CPOP_GICC_BPR0_EL1) | (dpu_cp_op_iss ==     `CA53_CPOP_GICC_DIR_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_PMR_EL1) | (dpu_cp_op_iss ==      `CA53_CPOP_GICC_RPR_EL1) | (dpu_cp_op_iss ==      `CA53_CPOP_GICC_AP0R0_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_AP1R0_EL1) | (dpu_cp_op_iss ==    `CA53_CPOP_GICC_IGRPEN0_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_IGRPEN1_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_IGRPEN1_EL3) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_SRE_EL1) | (dpu_cp_op_iss ==      `CA53_CPOP_GICC_SRE_EL2) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_SRE_EL3) | (dpu_cp_op_iss ==      `CA53_CPOP_GICC_CTLR_EL1) | (dpu_cp_op_iss ==     `CA53_CPOP_GICC_CTLR_EL3) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_SGI0R_EL1) | (dpu_cp_op_iss ==    `CA53_CPOP_GICC_SGI1R_EL1) | (dpu_cp_op_iss ==    `CA53_CPOP_GICC_ASGI1R_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICV_IAR1) | (dpu_cp_op_iss ==         `CA53_CPOP_GICV_IAR0) | (dpu_cp_op_iss ==         `CA53_CPOP_GICV_EOIR1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICV_EOIR0) | (dpu_cp_op_iss ==        `CA53_CPOP_GICV_HPPIR1) | (dpu_cp_op_iss ==       `CA53_CPOP_GICV_HPPIR0) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_VMCR_BPR1) | (dpu_cp_op_iss ==    `CA53_CPOP_GICH_VMCR_BPR0) | (dpu_cp_op_iss ==    `CA53_CPOP_GICV_DIR) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_VMCR_PMR) | (dpu_cp_op_iss ==     `CA53_CPOP_GICV_RPR) | (dpu_cp_op_iss ==          `CA53_CPOP_GICH_AP1R0) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_AP0R0) | (dpu_cp_op_iss ==        `CA53_CPOP_GICH_VMCR_VENG0) | (dpu_cp_op_iss ==   `CA53_CPOP_GICH_VMCR_VENG1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_HCR_SRE) | (dpu_cp_op_iss ==      `CA53_CPOP_GICV_CTLR) | (dpu_cp_op_iss ==         `CA53_CPOP_GICH_HCR) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_VTR) | (dpu_cp_op_iss ==          `CA53_CPOP_GICH_VMCR) | (dpu_cp_op_iss ==         `CA53_CPOP_GICH_MISR) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_EISR) | (dpu_cp_op_iss ==         `CA53_CPOP_GICH_ELSR) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_LR0) | (dpu_cp_op_iss ==          `CA53_CPOP_GICH_LR0_L) | (dpu_cp_op_iss ==        `CA53_CPOP_GICH_LR0_H) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_LR1) | (dpu_cp_op_iss ==          `CA53_CPOP_GICH_LR1_L) | (dpu_cp_op_iss ==        `CA53_CPOP_GICH_LR1_H) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_LR2) | (dpu_cp_op_iss ==          `CA53_CPOP_GICH_LR2_L) | (dpu_cp_op_iss ==        `CA53_CPOP_GICH_LR2_H) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_LR3) | (dpu_cp_op_iss ==          `CA53_CPOP_GICH_LR3_L) | (dpu_cp_op_iss ==        `CA53_CPOP_GICH_LR3_H))));


  // Only some cp operations do an address translation.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_cp_iss & ~dpu_flush  => dpu_valid_iss == ((dpu_cp_op_iss in [`CA53_CPOP_ICIMVAU, `CA53_CPOP_DCIMVAC, `CA53_CPOP_DCCMVAC,  `CA53_CPOP_DCCMVAU, `CA53_CPOP_DCCIMVAC, `CA53_CPOP_ATS1C,   `CA53_CPOP_ATS12NSO, `CA53_CPOP_ATS1H, `CA53_CPOP_ATS1E01, `CA53_CPOP_ATS12E01, `CA53_CPOP_ATS1E2, `CA53_CPOP_ATS1E3]) | ((dpu_cp_op_iss == `CA53_CPOP_DMBSY) & dpu_ldar_stlr_iss))")
  u_ovl_intf_assert_fbf3ac5a88e80217d9f3a920a55b0a8b05b47f5d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_cp_iss & ~dpu_flush ),
    .consequent_expr (dpu_valid_iss == ((((dpu_cp_op_iss == `CA53_CPOP_ICIMVAU) | (dpu_cp_op_iss ==  `CA53_CPOP_DCIMVAC) | (dpu_cp_op_iss ==  `CA53_CPOP_DCCMVAC) | (dpu_cp_op_iss ==   `CA53_CPOP_DCCMVAU) | (dpu_cp_op_iss ==  `CA53_CPOP_DCCIMVAC) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS1C) | (dpu_cp_op_iss ==    `CA53_CPOP_ATS12NSO) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS1H) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS1E01) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS12E01) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS1E2) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS1E3))) | ((dpu_cp_op_iss == `CA53_CPOP_DMBSY) & dpu_ldar_stlr_iss))));


  // Only cp register accesses (and V2P* that are doing a translation for a read) can be reads

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_cp_iss & ~dpu_store_iss  => dpu_cp_op_iss in [`CA53_CPOP_TTBR0,   `CA53_CPOP_TTBR1,    `CA53_CPOP_TTBR0_EL1, `CA53_CPOP_TTBR0_EL2,`CA53_CPOP_TTBR0_EL3, `CA53_CPOP_HTCR,    `CA53_CPOP_TTBCR,    `CA53_CPOP_TCR_EL1,   `CA53_CPOP_TCR_EL2,  `CA53_CPOP_TCR_EL3, `CA53_CPOP_VTCR,    `CA53_CPOP_VTCR_EL2, `CA53_CPOP_HTTBR,     `CA53_CPOP_VTTBR,    `CA53_CPOP_VTTBR_EL2, `CA53_CPOP_PAR,     `CA53_CPOP_PAR_EL1, `CA53_CPOP_MAIR0,   `CA53_CPOP_MAIR1,    `CA53_CPOP_MAIR_EL1,  `CA53_CPOP_MAIR_EL2, `CA53_CPOP_MAIR_EL3, `CA53_CPOP_HMAIR0,  `CA53_CPOP_HMAIR1,   `CA53_CPOP_CONTEXTIDR,`CA53_CPOP_CONTEXTIDR_EL1, `CA53_CPOP_L2_CTLR, `CA53_CPOP_L2_ECTLR, `CA53_CPOP_L2_ACTLR,  `CA53_CPOP_L2_MEM_ERR_SR, `CA53_CPOP_CDBGDR0, `CA53_CPOP_CDBGDR1,  `CA53_CPOP_CDBGDR2,   `CA53_CPOP_CDBGDR3, `CA53_CPOP_DBGVCR, `CA53_CPOP_DBGBVR0, `CA53_CPOP_DBGBVR1,  `CA53_CPOP_DBGBVR2,   `CA53_CPOP_DBGBVR3,  `CA53_CPOP_DBGBVR4,  `CA53_CPOP_DBGBVR5, `CA53_CPOP_DBGBXVR4,`CA53_CPOP_DBGBXVR5, `CA53_CPOP_DBGBCR0, `CA53_CPOP_DBGBCR1,  `CA53_CPOP_DBGBCR2, `CA53_CPOP_DBGBCR3,    `CA53_CPOP_DBGBCR4,  `CA53_CPOP_DBGBCR5, `CA53_CPOP_DBGWVR0, `CA53_CPOP_DBGWVR1,  `CA53_CPOP_DBGWVR2, `CA53_CPOP_DBGWVR3, `CA53_CPOP_DBGWCR0, `CA53_CPOP_DBGWCR1,  `CA53_CPOP_DBGWCR2, `CA53_CPOP_DBGWCR3, `CA53_CPOP_ATS1C,   `CA53_CPOP_ATS12NSO, `CA53_CPOP_ATS1H, `CA53_CPOP_ATS1E01, `CA53_CPOP_ATS12E01, `CA53_CPOP_ATS1E2,  `CA53_CPOP_ATS1E3, `CA53_CPOP_CNTFRQ_EL0,       `CA53_CPOP_CNTPCT_EL0,       `CA53_CPOP_CNTVCT_EL0, `CA53_CPOP_CNTKCTL_EL1,      `CA53_CPOP_CNTVOFF_EL2,      `CA53_CPOP_CNTHCTL_EL2, `CA53_CPOP_CNTP_TVAL_EL0,    `CA53_CPOP_CNTP_CTL_EL0,     `CA53_CPOP_CNTP_CVAL_EL0, `CA53_CPOP_CNTV_TVAL_EL0,    `CA53_CPOP_CNTV_CTL_EL0,     `CA53_CPOP_CNTV_CVAL_EL0, `CA53_CPOP_CNTHP_TVAL_EL2,   `CA53_CPOP_CNTHP_CTL_EL2,    `CA53_CPOP_CNTHP_CVAL_EL2, `CA53_CPOP_CNTPS_TVAL_EL1,   `CA53_CPOP_CNTPS_CTL_EL1,    `CA53_CPOP_CNTPS_CVAL_EL1, `CA53_CPOP_GICC_IAR1_EL1,    `CA53_CPOP_GICC_IAR0_EL1,    `CA53_CPOP_GICC_EOIR1_EL1, `CA53_CPOP_GICC_EOIR0_EL1,   `CA53_CPOP_GICC_HPPIR1_EL1,  `CA53_CPOP_GICC_HPPIR0_EL1, `CA53_CPOP_GICC_BPR1_EL1,    `CA53_CPOP_GICC_BPR0_EL1,    `CA53_CPOP_GICC_DIR_EL1, `CA53_CPOP_GICC_PMR_EL1,     `CA53_CPOP_GICC_RPR_EL1,     `CA53_CPOP_GICC_AP0R0_EL1, `CA53_CPOP_GICC_AP1R0_EL1,   `CA53_CPOP_GICC_IGRPEN0_EL1, `CA53_CPOP_GICC_IGRPEN1_EL1, `CA53_CPOP_GICC_IGRPEN1_EL3, `CA53_CPOP_GICC_SRE_EL1,     `CA53_CPOP_GICC_SRE_EL2, `CA53_CPOP_GICC_SRE_EL3,     `CA53_CPOP_GICC_CTLR_EL1,    `CA53_CPOP_GICC_CTLR_EL3, `CA53_CPOP_GICC_SGI0R_EL1,   `CA53_CPOP_GICC_SGI1R_EL1,   `CA53_CPOP_GICC_ASGI1R_EL1, `CA53_CPOP_GICV_IAR1,        `CA53_CPOP_GICV_IAR0,        `CA53_CPOP_GICV_EOIR1, `CA53_CPOP_GICV_EOIR0,       `CA53_CPOP_GICV_HPPIR1,      `CA53_CPOP_GICV_HPPIR0, `CA53_CPOP_GICH_VMCR_BPR1,   `CA53_CPOP_GICH_VMCR_BPR0,   `CA53_CPOP_GICV_DIR, `CA53_CPOP_GICH_VMCR_PMR,    `CA53_CPOP_GICV_RPR,         `CA53_CPOP_GICH_AP1R0, `CA53_CPOP_GICH_AP0R0,       `CA53_CPOP_GICH_VMCR_VENG0,  `CA53_CPOP_GICH_VMCR_VENG1, `CA53_CPOP_GICH_HCR_SRE,     `CA53_CPOP_GICV_CTLR,        `CA53_CPOP_GICH_HCR, `CA53_CPOP_GICH_VTR,         `CA53_CPOP_GICH_VMCR,        `CA53_CPOP_GICH_MISR, `CA53_CPOP_GICH_EISR,        `CA53_CPOP_GICH_ELSR, `CA53_CPOP_GICH_LR0,         `CA53_CPOP_GICH_LR0_L,       `CA53_CPOP_GICH_LR0_H, `CA53_CPOP_GICH_LR1,         `CA53_CPOP_GICH_LR1_L,       `CA53_CPOP_GICH_LR1_H, `CA53_CPOP_GICH_LR2,         `CA53_CPOP_GICH_LR2_L,       `CA53_CPOP_GICH_LR2_H, `CA53_CPOP_GICH_LR3,         `CA53_CPOP_GICH_LR3_L,       `CA53_CPOP_GICH_LR3_H,  `CA53_CPOP_CLREX]")
  u_ovl_intf_assert_59c9c154f554c742c426d791bc02a93d4b24a450 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_cp_iss & ~dpu_store_iss ),
    .consequent_expr (((dpu_cp_op_iss == `CA53_CPOP_TTBR0) | (dpu_cp_op_iss ==    `CA53_CPOP_TTBR1) | (dpu_cp_op_iss ==     `CA53_CPOP_TTBR0_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_TTBR0_EL2) | (dpu_cp_op_iss == `CA53_CPOP_TTBR0_EL3) | (dpu_cp_op_iss ==  `CA53_CPOP_HTCR) | (dpu_cp_op_iss ==     `CA53_CPOP_TTBCR) | (dpu_cp_op_iss ==     `CA53_CPOP_TCR_EL1) | (dpu_cp_op_iss ==    `CA53_CPOP_TCR_EL2) | (dpu_cp_op_iss ==   `CA53_CPOP_TCR_EL3) | (dpu_cp_op_iss ==  `CA53_CPOP_VTCR) | (dpu_cp_op_iss ==     `CA53_CPOP_VTCR_EL2) | (dpu_cp_op_iss ==  `CA53_CPOP_HTTBR) | (dpu_cp_op_iss ==      `CA53_CPOP_VTTBR) | (dpu_cp_op_iss ==     `CA53_CPOP_VTTBR_EL2) | (dpu_cp_op_iss ==  `CA53_CPOP_PAR) | (dpu_cp_op_iss ==      `CA53_CPOP_PAR_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_MAIR0) | (dpu_cp_op_iss ==    `CA53_CPOP_MAIR1) | (dpu_cp_op_iss ==     `CA53_CPOP_MAIR_EL1) | (dpu_cp_op_iss ==   `CA53_CPOP_MAIR_EL2) | (dpu_cp_op_iss ==  `CA53_CPOP_MAIR_EL3) | (dpu_cp_op_iss ==  `CA53_CPOP_HMAIR0) | (dpu_cp_op_iss ==   `CA53_CPOP_HMAIR1) | (dpu_cp_op_iss ==    `CA53_CPOP_CONTEXTIDR) | (dpu_cp_op_iss == `CA53_CPOP_CONTEXTIDR_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_L2_CTLR) | (dpu_cp_op_iss ==  `CA53_CPOP_L2_ECTLR) | (dpu_cp_op_iss ==  `CA53_CPOP_L2_ACTLR) | (dpu_cp_op_iss ==   `CA53_CPOP_L2_MEM_ERR_SR) | (dpu_cp_op_iss ==  `CA53_CPOP_CDBGDR0) | (dpu_cp_op_iss ==  `CA53_CPOP_CDBGDR1) | (dpu_cp_op_iss ==   `CA53_CPOP_CDBGDR2) | (dpu_cp_op_iss ==    `CA53_CPOP_CDBGDR3) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGVCR) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGBVR0) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGBVR1) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBVR2) | (dpu_cp_op_iss ==    `CA53_CPOP_DBGBVR3) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBVR4) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBVR5) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGBXVR4) | (dpu_cp_op_iss == `CA53_CPOP_DBGBXVR5) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGBCR0) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGBCR1) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBCR2) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGBCR3) | (dpu_cp_op_iss ==     `CA53_CPOP_DBGBCR4) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGBCR5) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGWVR0) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGWVR1) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGWVR2) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGWVR3) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGWCR0) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGWCR1) | (dpu_cp_op_iss ==   `CA53_CPOP_DBGWCR2) | (dpu_cp_op_iss ==  `CA53_CPOP_DBGWCR3) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS1C) | (dpu_cp_op_iss ==    `CA53_CPOP_ATS12NSO) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS1H) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS1E01) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS12E01) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS1E2) | (dpu_cp_op_iss ==   `CA53_CPOP_ATS1E3) | (dpu_cp_op_iss ==  `CA53_CPOP_CNTFRQ_EL0) | (dpu_cp_op_iss ==        `CA53_CPOP_CNTPCT_EL0) | (dpu_cp_op_iss ==        `CA53_CPOP_CNTVCT_EL0) | (dpu_cp_op_iss ==  `CA53_CPOP_CNTKCTL_EL1) | (dpu_cp_op_iss ==       `CA53_CPOP_CNTVOFF_EL2) | (dpu_cp_op_iss ==       `CA53_CPOP_CNTHCTL_EL2) | (dpu_cp_op_iss ==  `CA53_CPOP_CNTP_TVAL_EL0) | (dpu_cp_op_iss ==     `CA53_CPOP_CNTP_CTL_EL0) | (dpu_cp_op_iss ==      `CA53_CPOP_CNTP_CVAL_EL0) | (dpu_cp_op_iss ==  `CA53_CPOP_CNTV_TVAL_EL0) | (dpu_cp_op_iss ==     `CA53_CPOP_CNTV_CTL_EL0) | (dpu_cp_op_iss ==      `CA53_CPOP_CNTV_CVAL_EL0) | (dpu_cp_op_iss ==  `CA53_CPOP_CNTHP_TVAL_EL2) | (dpu_cp_op_iss ==    `CA53_CPOP_CNTHP_CTL_EL2) | (dpu_cp_op_iss ==     `CA53_CPOP_CNTHP_CVAL_EL2) | (dpu_cp_op_iss ==  `CA53_CPOP_CNTPS_TVAL_EL1) | (dpu_cp_op_iss ==    `CA53_CPOP_CNTPS_CTL_EL1) | (dpu_cp_op_iss ==     `CA53_CPOP_CNTPS_CVAL_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_IAR1_EL1) | (dpu_cp_op_iss ==     `CA53_CPOP_GICC_IAR0_EL1) | (dpu_cp_op_iss ==     `CA53_CPOP_GICC_EOIR1_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_EOIR0_EL1) | (dpu_cp_op_iss ==    `CA53_CPOP_GICC_HPPIR1_EL1) | (dpu_cp_op_iss ==   `CA53_CPOP_GICC_HPPIR0_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_BPR1_EL1) | (dpu_cp_op_iss ==     `CA53_CPOP_GICC_BPR0_EL1) | (dpu_cp_op_iss ==     `CA53_CPOP_GICC_DIR_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_PMR_EL1) | (dpu_cp_op_iss ==      `CA53_CPOP_GICC_RPR_EL1) | (dpu_cp_op_iss ==      `CA53_CPOP_GICC_AP0R0_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_AP1R0_EL1) | (dpu_cp_op_iss ==    `CA53_CPOP_GICC_IGRPEN0_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_IGRPEN1_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_IGRPEN1_EL3) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_SRE_EL1) | (dpu_cp_op_iss ==      `CA53_CPOP_GICC_SRE_EL2) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_SRE_EL3) | (dpu_cp_op_iss ==      `CA53_CPOP_GICC_CTLR_EL1) | (dpu_cp_op_iss ==     `CA53_CPOP_GICC_CTLR_EL3) | (dpu_cp_op_iss ==  `CA53_CPOP_GICC_SGI0R_EL1) | (dpu_cp_op_iss ==    `CA53_CPOP_GICC_SGI1R_EL1) | (dpu_cp_op_iss ==    `CA53_CPOP_GICC_ASGI1R_EL1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICV_IAR1) | (dpu_cp_op_iss ==         `CA53_CPOP_GICV_IAR0) | (dpu_cp_op_iss ==         `CA53_CPOP_GICV_EOIR1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICV_EOIR0) | (dpu_cp_op_iss ==        `CA53_CPOP_GICV_HPPIR1) | (dpu_cp_op_iss ==       `CA53_CPOP_GICV_HPPIR0) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_VMCR_BPR1) | (dpu_cp_op_iss ==    `CA53_CPOP_GICH_VMCR_BPR0) | (dpu_cp_op_iss ==    `CA53_CPOP_GICV_DIR) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_VMCR_PMR) | (dpu_cp_op_iss ==     `CA53_CPOP_GICV_RPR) | (dpu_cp_op_iss ==          `CA53_CPOP_GICH_AP1R0) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_AP0R0) | (dpu_cp_op_iss ==        `CA53_CPOP_GICH_VMCR_VENG0) | (dpu_cp_op_iss ==   `CA53_CPOP_GICH_VMCR_VENG1) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_HCR_SRE) | (dpu_cp_op_iss ==      `CA53_CPOP_GICV_CTLR) | (dpu_cp_op_iss ==         `CA53_CPOP_GICH_HCR) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_VTR) | (dpu_cp_op_iss ==          `CA53_CPOP_GICH_VMCR) | (dpu_cp_op_iss ==         `CA53_CPOP_GICH_MISR) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_EISR) | (dpu_cp_op_iss ==         `CA53_CPOP_GICH_ELSR) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_LR0) | (dpu_cp_op_iss ==          `CA53_CPOP_GICH_LR0_L) | (dpu_cp_op_iss ==        `CA53_CPOP_GICH_LR0_H) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_LR1) | (dpu_cp_op_iss ==          `CA53_CPOP_GICH_LR1_L) | (dpu_cp_op_iss ==        `CA53_CPOP_GICH_LR1_H) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_LR2) | (dpu_cp_op_iss ==          `CA53_CPOP_GICH_LR2_L) | (dpu_cp_op_iss ==        `CA53_CPOP_GICH_LR2_H) | (dpu_cp_op_iss ==  `CA53_CPOP_GICH_LR3) | (dpu_cp_op_iss ==          `CA53_CPOP_GICH_LR3_L) | (dpu_cp_op_iss ==        `CA53_CPOP_GICH_LR3_H) | (dpu_cp_op_iss ==   `CA53_CPOP_CLREX))));


  // Some cp operations can only occur in secure state

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_cp_iss & ~dpu_flush & dpu_ns_state  => ~(dpu_cp_op_iss in [`CA53_CPOP_CDBGDR0, `CA53_CPOP_CDBGDR1, `CA53_CPOP_CDBGDR2, `CA53_CPOP_CDBGDCT, `CA53_CPOP_CDBGICT, `CA53_CPOP_CDBGDCD, `CA53_CPOP_CDBGICD, `CA53_CPOP_CDBGTD])")
  u_ovl_intf_assert_4cddfaaac2b5356bc19db2227d9f019cb695f88b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_cp_iss & ~dpu_flush & dpu_ns_state ),
    .consequent_expr (~(((dpu_cp_op_iss == `CA53_CPOP_CDBGDR0) | (dpu_cp_op_iss ==  `CA53_CPOP_CDBGDR1) | (dpu_cp_op_iss ==  `CA53_CPOP_CDBGDR2) | (dpu_cp_op_iss ==  `CA53_CPOP_CDBGDCT) | (dpu_cp_op_iss ==  `CA53_CPOP_CDBGICT) | (dpu_cp_op_iss ==  `CA53_CPOP_CDBGDCD) | (dpu_cp_op_iss ==  `CA53_CPOP_CDBGICD) | (dpu_cp_op_iss ==  `CA53_CPOP_CDBGTD)))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_cp_iss & ~dpu_flush & dpu_ns_state & dpu_exception_level != `CA53_EL2  => ~(dpu_cp_op_iss in [`CA53_CPOP_ATS12NSO, `CA53_CPOP_ATS1H])")
  u_ovl_intf_assert_dfb0712c42f72801652fc970548b8d537e1f3084 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_cp_iss & ~dpu_flush & dpu_ns_state & dpu_exception_level != `CA53_EL2 ),
    .consequent_expr (~(((dpu_cp_op_iss == `CA53_CPOP_ATS12NSO) | (dpu_cp_op_iss ==  `CA53_CPOP_ATS1H)))));


  assign attrs_dc1  = dpu_attributes_dc1[12:5];

  // Some uTLB attribute encodings are not possible.
  // Must not generate illegal memory types (the main TLB will never put illegal types into the uTLB).

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_utlb_hit_dc1 & ~dpu_abort_dc1  => ~`CA53_MEM_UNUSED(attrs_dc1)")
  u_ovl_intf_assert_41c58f381fb6958fb6716420d9bcd60b07897e7e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_utlb_hit_dc1 & ~dpu_abort_dc1 ),
    .consequent_expr (~`CA53_MEM_UNUSED(attrs_dc1)));


  // The uTLB must never contain a secure page when the DPU is in non-secure state.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_valid_iss@1 & ~dpu_flush@1 & dcu_ready_iss@1 & dpu_utlb_hit_dc1 & ~dpu_ns_dsc_dc1  => ~dpu_ns_state | dpu_flush")
  u_ovl_intf_assert_a927f52d4812a599e1a33b58db3bc8a4cd18a3a4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_valid_iss_reg & ~dpu_flush_reg & dcu_ready_iss_reg & dpu_utlb_hit_dc1 & ~dpu_ns_dsc_dc1 ),
    .consequent_expr (~dpu_ns_state | dpu_flush));


  // The uTLB should not set the overridden bit for device memory on stage 2 translation faults

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_abort_dc1 & `CA53_MEM_DEVICE(attrs_dc1) & dpu_fault_dc1[8]  => ~`CA53_MEM_DEV_OVERRIDE(attrs_dc1)")
  u_ovl_intf_assert_4aa60cdabe132ec79c7e183e63f53d0172601bba (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_abort_dc1 & `CA53_MEM_DEVICE(attrs_dc1) & dpu_fault_dc1[8] ),
    .consequent_expr (~`CA53_MEM_DEV_OVERRIDE(attrs_dc1)));


  // The DPU can only signal a stack alignment fault in AArch64

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & dpu_valid_iss@1 & dpu_stack_align_expt_dc1  => dpu_aarch64_state")
  u_ovl_intf_assert_191ed39f07e218c8149729d412c3682f3963e82a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & dpu_valid_iss_reg & dpu_stack_align_expt_dc1 ),
    .consequent_expr (dpu_aarch64_state));


  // ------------------------------------------------------
  // Wr/dc3 signal rules
  // ------------------------------------------------------


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    size0 <= 2'b00;
  else if (en0)
    size0 <= (leaving_dcu & valid1) ? size1 : dpu_size_iss;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    size1 <= 2'b00;
  else if (en1)
    size1 <= (leaving_dcu & valid2) ? size2 : dpu_size_iss;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    size2 <= 2'b00;
  else if (en2)
    size2 <= dpu_size_iss;


  assign cp_data_wr_mask  = size0[0] ? 64'hffff_ffff_ffff_ffff : 64'h0000_0000_ffff_ffff;


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_ready_wr_real@1 & ~leaving_dcu@1 & valid_cp_wr0@1  => (dpu_cp_data_wr & cp_data_wr_mask) == (dpu_cp_data_wr@1 & cp_data_wr_mask)")
  u_ovl_intf_assert_565610431caa99bf3ccd7779a86fb700a14d0911 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_ready_wr_real_reg & ~leaving_dcu_reg & valid_cp_wr0_reg ),
    .consequent_expr ((dpu_cp_data_wr & cp_data_wr_mask) == (dpu_cp_data_wr_reg & cp_data_wr_mask)));


  assign first_iss  = dpu_first_iss & (((dpu_size_iss >= `CA53_SIZE_WORD) & (dpu_length_iss > 0)) | (dpu_cross_64_iss & ~dpu_second_x64_iss));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    first0 <= 1'b0;
  else if (en0)
    first0 <= (leaving_dcu & valid1) ? first1 : first_iss;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    first1 <= 1'b0;
  else if (en1)
    first1 <= (leaving_dcu & valid2) ? first2 : first_iss;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    first2 <= 1'b0;
  else if (en2)
    first2 <= first_iss;


  assign last_iss  = (((dpu_length_iss[4:2] == 4'b0000) & ((dpu_length_iss[1] == 1'b0) | (dpu_store_iss & (dpu_size_iss == `CA53_SIZE_DWORD)))) | (dpu_cross_64_iss & dpu_second_x64_iss & (dpu_length_iss == 0)));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    last0 <= 1'b0;
  else if (en0)
    last0 <= (leaving_dcu & valid1) ? last1 : last_iss;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    last1 <= 1'b0;
  else if (en1)
    last1 <= (leaving_dcu & valid2) ? last2 : last_iss;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    last2 <= 1'b0;
  else if (en2)
    last2 <= last_iss;


  // If a precise abort is returned the DPU must cause a flush the next cycle.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "leaving_dcu@1 & dcu_p_abort_dc3@1 & ~kill_or_cc_fail_wr@1  => dpu_flush & dpu_kill_wr")
  u_ovl_intf_assert_592a5aa65435cb5cbf73ad7e576a5d333a070aa1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (leaving_dcu_reg & dcu_p_abort_dc3_reg & ~kill_or_cc_fail_wr_reg ),
    .consequent_expr (dpu_flush & dpu_kill_wr));


  // If a watchpoint is returned the DPU must cause a flush the next cycle.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "leaving_dcu@1 & dcu_wpt_hit_dc3@1 & ~kill_or_cc_fail_wr@1  => dpu_flush & dpu_kill_wr")
  u_ovl_intf_assert_18ff7d4e5c338e3cbfbfe01bd6d0eae3f0c7e26a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (leaving_dcu_reg & dcu_wpt_hit_dc3_reg & ~kill_or_cc_fail_wr_reg ),
    .consequent_expr (dpu_flush & dpu_kill_wr));


  // If an ecc error is returned the DPU must cause a flush the next cycle.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "leaving_dcu@1 & dcu_ecc_err_dc3@1 & ~kill_or_cc_fail_wr@1  => dpu_flush & dpu_kill_wr")
  u_ovl_intf_assert_664d52ceca5075f7d9874f572b2521cbd95e4587 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (leaving_dcu_reg & dcu_ecc_err_dc3_reg & ~kill_or_cc_fail_wr_reg ),
    .consequent_expr (dpu_flush & dpu_kill_wr));


  assign nxt_committed_burst  = (committed_burst ? ~(last0 & leaving_dcu) : (first0 & ~last0 & (~dpu_flush | dpu_ready_wr))) & ~kill_or_cc_fail_wr;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    committed_burst <= 1'b0;
  else if (dpu_ready_wr | kill_or_cc_fail_wr | dpu_flush)
    committed_burst <= nxt_committed_burst;


  // The DPU must not flush a burst unless it precisely aborted.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "committed_burst & ~(leaving_dcu@1 & (dcu_p_abort_dc3@1 | dcu_wpt_hit_dc3@1 | dcu_ecc_err_dc3@1))  => ~dpu_kill_wr")
  u_ovl_intf_assert_0793f40630f50c201864cfd2fe5ab6a88ca28b3d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (committed_burst & ~(leaving_dcu_reg & (dcu_p_abort_dc3_reg | dcu_wpt_hit_dc3_reg | dcu_ecc_err_dc3_reg)) ),
    .consequent_expr (~dpu_kill_wr));


  // The DPU must not flush part of the burst while leaving some of it in wr.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(nxt_committed_burst | committed_burst) & dpu_flush & ~dpu_kill_wr  => last0 & dpu_ready_wr")
  u_ovl_intf_assert_e87fffffbcd98e3e164722451308830d6713fe4c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((nxt_committed_burst | committed_burst) & dpu_flush & ~dpu_kill_wr ),
    .consequent_expr (last0 & dpu_ready_wr));


  // Once the DCU asserts dcu_valid_dc3, it must keep it asserted until the DPU
  // either commits or cancels the instruction.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc3@1 & ~dpu_ready_wr@1 & ~dpu_kill_wr@1 & ~dpu_flush@1  => dcu_valid_dc3")
  u_ovl_intf_assume_905dc0091b726e06414627a4b2d9ae73930a50d1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc3_reg & ~dpu_ready_wr_reg & ~dpu_kill_wr_reg & ~dpu_flush_reg ),
    .consequent_expr (dcu_valid_dc3));


  // Only some encodings of dcu_p_fault_stage_dc3 are valid.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc3 & dcu_p_abort_dc3  => dcu_p_fault_stage_dc3 in [2'b00, 2'b10, 2'b11]")
  u_ovl_intf_assume_bb132ea91ab22b4057860f04acdc21fde8dcd66c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc3 & dcu_p_abort_dc3 ),
    .consequent_expr (((dcu_p_fault_stage_dc3 == 2'b00) | (dcu_p_fault_stage_dc3 ==  2'b10) | (dcu_p_fault_stage_dc3 ==  2'b11))));


  // Only some encodings of dcu_p_fault_dc3 are valid.
  // - Stage 1

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc3 & dcu_p_abort_dc3 & ~dcu_p_fault_stage_dc3[1]  => dcu_p_fault_dc3 in [`CA53_FAULT_LPAE_ALIGNMENT, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3, `CA53_FAULT_LPAE_TRANSLATION_L0, `CA53_FAULT_LPAE_TRANSLATION_L1, `CA53_FAULT_LPAE_TRANSLATION_L2, `CA53_FAULT_LPAE_TRANSLATION_L3, `CA53_FAULT_LPAE_ACCESS_L0, `CA53_FAULT_LPAE_ACCESS_L1, `CA53_FAULT_LPAE_ACCESS_L2, `CA53_FAULT_LPAE_ACCESS_L3, `CA53_FAULT_LPAE_PERMISSION_L0, `CA53_FAULT_LPAE_PERMISSION_L1, `CA53_FAULT_LPAE_PERMISSION_L2, `CA53_FAULT_LPAE_PERMISSION_L3, `CA53_FAULT_LPAE_ADDR_SIZE_L0, `CA53_FAULT_LPAE_ADDR_SIZE_L1, `CA53_FAULT_LPAE_ADDR_SIZE_L2, `CA53_FAULT_LPAE_ADDR_SIZE_L3, `CA53_FAULT_LPAE_ECC, `CA53_FAULT_LPAE_LDREX,  `CA53_FAULT_LPAE_STACK_ALIGN,  `CA53_FAULT_LPAE_EXT_DEC, `CA53_FAULT_LPAE_EXT_SLV,  `CA53_FAULT_LPAE_DOMAIN_L1, `CA53_FAULT_LPAE_DOMAIN_L2]")
  u_ovl_intf_assume_c63360e04719baee6f7d92646616fb09dac7b206 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc3 & dcu_p_abort_dc3 & ~dcu_p_fault_stage_dc3[1] ),
    .consequent_expr (((dcu_p_fault_dc3 == `CA53_FAULT_LPAE_ALIGNMENT) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_TRANSLATION_L0) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_TRANSLATION_L1) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_TRANSLATION_L2) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_TRANSLATION_L3) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ACCESS_L0) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ACCESS_L1) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ACCESS_L2) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ACCESS_L3) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PERMISSION_L0) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PERMISSION_L1) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PERMISSION_L2) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PERMISSION_L3) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ADDR_SIZE_L0) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ADDR_SIZE_L1) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ADDR_SIZE_L2) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ADDR_SIZE_L3) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ECC) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_LDREX) | (dcu_p_fault_dc3 ==   `CA53_FAULT_LPAE_STACK_ALIGN) | (dcu_p_fault_dc3 ==   `CA53_FAULT_LPAE_EXT_DEC) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_EXT_SLV) | (dcu_p_fault_dc3 ==   `CA53_FAULT_LPAE_DOMAIN_L1) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_DOMAIN_L2))));


  // - Stage 2

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc3 & dcu_p_abort_dc3 & dcu_p_fault_stage_dc3[1]  => dcu_p_fault_dc3 in [`CA53_FAULT_LPAE_ALIGNMENT, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3, `CA53_FAULT_LPAE_TRANSLATION_L0, `CA53_FAULT_LPAE_TRANSLATION_L1, `CA53_FAULT_LPAE_TRANSLATION_L2, `CA53_FAULT_LPAE_TRANSLATION_L3, `CA53_FAULT_LPAE_ACCESS_L0, `CA53_FAULT_LPAE_ACCESS_L1, `CA53_FAULT_LPAE_ACCESS_L2, `CA53_FAULT_LPAE_ACCESS_L3, `CA53_FAULT_LPAE_ECC, `CA53_FAULT_LPAE_LDREX, `CA53_FAULT_LPAE_PERMISSION_L0, `CA53_FAULT_LPAE_PERMISSION_L1, `CA53_FAULT_LPAE_PERMISSION_L2, `CA53_FAULT_LPAE_PERMISSION_L3, `CA53_FAULT_LPAE_ADDR_SIZE_L0, `CA53_FAULT_LPAE_ADDR_SIZE_L1, `CA53_FAULT_LPAE_ADDR_SIZE_L2, `CA53_FAULT_LPAE_ADDR_SIZE_L3,  `CA53_FAULT_LPAE_STACK_ALIGN]")
  u_ovl_intf_assume_a17fa079e9c6187cc3794a0c5494a53149542715 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc3 & dcu_p_abort_dc3 & dcu_p_fault_stage_dc3[1] ),
    .consequent_expr (((dcu_p_fault_dc3 == `CA53_FAULT_LPAE_ALIGNMENT) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_TRANSLATION_L0) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_TRANSLATION_L1) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_TRANSLATION_L2) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_TRANSLATION_L3) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ACCESS_L0) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ACCESS_L1) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ACCESS_L2) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ACCESS_L3) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ECC) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_LDREX) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PERMISSION_L0) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PERMISSION_L1) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PERMISSION_L2) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_PERMISSION_L3) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ADDR_SIZE_L0) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ADDR_SIZE_L1) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ADDR_SIZE_L2) | (dcu_p_fault_dc3 ==  `CA53_FAULT_LPAE_ADDR_SIZE_L3) | (dcu_p_fault_dc3 ==   `CA53_FAULT_LPAE_STACK_ALIGN))));


  // Stack alignment exceptions can only be reported in AArch64

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc3 & dcu_p_abort_dc3 & ~dpu_flush & (dcu_p_fault_dc3 == `CA53_FAULT_LPAE_STACK_ALIGN)  => dpu_aarch64_state")
  u_ovl_intf_assume_e639d0a90a1246a46f6089c81e672e1ca96155fd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc3 & dcu_p_abort_dc3 & ~dpu_flush & (dcu_p_fault_dc3 == `CA53_FAULT_LPAE_STACK_ALIGN) ),
    .consequent_expr (dpu_aarch64_state));


  // - and are always stage 1

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc3 & dcu_p_abort_dc3 & (dcu_p_fault_dc3 == `CA53_FAULT_LPAE_STACK_ALIGN)  => (dcu_p_fault_stage_dc3 == 2'b00)")
  u_ovl_intf_assume_da81e8a4942c763fa97bec45c3e8a505cda7c097 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc3 & dcu_p_abort_dc3 & (dcu_p_fault_dc3 == `CA53_FAULT_LPAE_STACK_ALIGN) ),
    .consequent_expr ((dcu_p_fault_stage_dc3 == 2'b00)));


  // Timing optimized Ready/CC-Pass signal rules.  Note that since reset is X for the
  // first cycle in the DPU testbench we need to wait for initialization before these
  // OVLs are valid.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "initialization_done & ~dpu_ready_wr & ~dpu_cc_fail_wr  => ~dpu_ready_cc_fail_wr")
  u_ovl_intf_assert_5a450f1f35005c58e8277a6ab0efc010a034b279 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (initialization_done & ~dpu_ready_wr & ~dpu_cc_fail_wr ),
    .consequent_expr (~dpu_ready_cc_fail_wr));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "initialization_done & ~dpu_ready_wr &  dpu_cc_fail_wr  => ~dpu_ready_cc_fail_wr")
  u_ovl_intf_assert_ed8651f7379e719b75a312f0c629b3ec765ac3ba (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (initialization_done & ~dpu_ready_wr &  dpu_cc_fail_wr ),
    .consequent_expr (~dpu_ready_cc_fail_wr));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "initialization_done &  dpu_ready_wr & ~dpu_cc_fail_wr  => ~dpu_ready_cc_fail_wr")
  u_ovl_intf_assert_a98eaf6fe064e049475cf9f6aff49eeef098d051 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (initialization_done &  dpu_ready_wr & ~dpu_cc_fail_wr ),
    .consequent_expr (~dpu_ready_cc_fail_wr));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "initialization_done &  dpu_ready_wr &  dpu_cc_fail_wr  => dpu_ready_cc_fail_wr")
  u_ovl_intf_assert_cf380d827308b2d3041885b11ed62fa70e7fdbeb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (initialization_done &  dpu_ready_wr &  dpu_cc_fail_wr ),
    .consequent_expr (dpu_ready_cc_fail_wr));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "initialization_done & ~dpu_ready_wr & ~dpu_cc_fail_wr  => ~dpu_ready_cc_pass_wr")
  u_ovl_intf_assert_74369771c7bc73fde4cf1791f3a14e971ab9c7dd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (initialization_done & ~dpu_ready_wr & ~dpu_cc_fail_wr ),
    .consequent_expr (~dpu_ready_cc_pass_wr));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "initialization_done & ~dpu_ready_wr &  dpu_cc_fail_wr  => ~dpu_ready_cc_pass_wr")
  u_ovl_intf_assert_12384c72bee19cc0359965e83ca5ff0b35a4380e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (initialization_done & ~dpu_ready_wr &  dpu_cc_fail_wr ),
    .consequent_expr (~dpu_ready_cc_pass_wr));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "initialization_done &  dpu_ready_wr & ~dpu_cc_fail_wr  => dpu_ready_cc_pass_wr")
  u_ovl_intf_assert_ab4eeef368f27837cccffa4ecdc6a163fdf10c02 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (initialization_done &  dpu_ready_wr & ~dpu_cc_fail_wr ),
    .consequent_expr (dpu_ready_cc_pass_wr));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "initialization_done &  dpu_ready_wr &  dpu_cc_fail_wr  => ~dpu_ready_cc_pass_wr")
  u_ovl_intf_assert_5603c5f54e6f3a17fee5a190e1fad1621a5d3475 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (initialization_done &  dpu_ready_wr &  dpu_cc_fail_wr ),
    .consequent_expr (~dpu_ready_cc_pass_wr));


  // ------------------------------------------------------
  // Miscellaneous signal rules
  // ------------------------------------------------------

  // The DPU should not turn the cache on or off if the DCU pipeline is not empty.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_dcache_on_el1  != dpu_dcache_on_el1@1   => (trans_in_dcu == 0) & ~committed_burst")
  u_ovl_intf_assert_3e86108717ffbef655bb8250a2a6e54da184dd33 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_dcache_on_el1  != dpu_dcache_on_el1_reg  ),
    .consequent_expr ((trans_in_dcu == 0) & ~committed_burst));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_dcache_on_el2  != dpu_dcache_on_el2@1   => (trans_in_dcu == 0) & ~committed_burst")
  u_ovl_intf_assert_b4ff95122af9e84aad004f569ec083519665471f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_dcache_on_el2  != dpu_dcache_on_el2_reg  ),
    .consequent_expr ((trans_in_dcu == 0) & ~committed_burst));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_dcache_on_el3  != dpu_dcache_on_el3@1   => (trans_in_dcu == 0) & ~committed_burst")
  u_ovl_intf_assert_f53e0f24dc944b7d0982da83165a7eeb1f588ad0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_dcache_on_el3  != dpu_dcache_on_el3_reg  ),
    .consequent_expr ((trans_in_dcu == 0) & ~committed_burst));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_s2_dcache_on   != dpu_s2_dcache_on@1    => (trans_in_dcu == 0) & ~committed_burst")
  u_ovl_intf_assert_2972e4581b9a5b2bc43604de4714c549c4f98942 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_s2_dcache_on   != dpu_s2_dcache_on_reg   ),
    .consequent_expr ((trans_in_dcu == 0) & ~committed_burst));


  // The DPU should not change the control bits if the DCU pipeline is not empty.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_disable_dmb != dpu_disable_dmb@1  => (trans_in_dcu == 0) & ~committed_burst")
  u_ovl_intf_assert_0e9764bcb8a788762c401a48aea02beffd959809 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_disable_dmb != dpu_disable_dmb_reg ),
    .consequent_expr ((trans_in_dcu == 0) & ~committed_burst));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_disable_no_allocate != dpu_disable_no_allocate@1  => (trans_in_dcu == 0) & ~committed_burst")
  u_ovl_intf_assert_008e4d79479e9648784bfcc565f3399bbd2d813c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_disable_no_allocate != dpu_disable_no_allocate_reg ),
    .consequent_expr ((trans_in_dcu == 0) & ~committed_burst));


  // The DPU should not change security state if the DCU pipeline is not empty
  // (unless a flush is signalled and the exception is changing the security state)

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dpu_kill_wr & dpu_ns_state != dpu_ns_state@1  => (trans_in_dcu == 0) & ~committed_burst")
  u_ovl_intf_assert_a832a1a4e8f13d497669672b2a3262f5bd1442a1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dpu_kill_wr & dpu_ns_state != dpu_ns_state_reg ),
    .consequent_expr ((trans_in_dcu == 0) & ~committed_burst));


  // The DPU should not request a DSB if the DCU pipeline is not empty.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_dbg_dsb_req  => (trans_in_dcu == 0) & ~committed_burst")
  u_ovl_intf_assert_67fd5f0c59de5ca0823e7db702b103177403acc9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_dbg_dsb_req ),
    .consequent_expr ((trans_in_dcu == 0) & ~committed_burst));


  // The DPU must hold the DSB request until it is acked.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_dbg_dsb_req@1 & ~dcu_dbg_dsb_ack@1  => dpu_dbg_dsb_req")
  u_ovl_intf_assert_0c66109b0131f092a85b8be7ff2c5140b0800fce (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_dbg_dsb_req_reg & ~dcu_dbg_dsb_ack_reg ),
    .consequent_expr (dpu_dbg_dsb_req));


  // The DPU must drop the request once it has been acked.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_dbg_dsb_req@1 & dcu_dbg_dsb_ack@1  => ~dpu_dbg_dsb_req")
  u_ovl_intf_assert_9c604cba4e87f6966bf570932af3003441550df6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_dbg_dsb_req_reg & dcu_dbg_dsb_ack_reg ),
    .consequent_expr (~dpu_dbg_dsb_req));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    prev_va <= {64{1'b0}};
  else if (entering_dcu_reg)
    prev_va <= dpu_va_dc1;



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "entering_dcu@1 & ~dpu_first_iss@1 & ~dpu_store_iss@1 & ~dpu_force_first_iss@1  => prev_va[63:6] == dpu_va_dc1[63:6]")
  u_ovl_intf_assert_249d2682dd72d15d5d97f883806d6ff79d175682 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (entering_dcu_reg & ~dpu_first_iss_reg & ~dpu_store_iss_reg & ~dpu_force_first_iss_reg ),
    .consequent_expr (prev_va[63:6] == dpu_va_dc1[63:6]));



endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "cortexa53params.v"
`include "ca53_dpu_dcu_defs.v"
`undef CA53_UNDEFINE

`endif

