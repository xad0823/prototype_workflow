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
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : DCU Load/Store Pipe
//
// The load/store pipe consists of 3 pipeline stages: DC1, DC2 and DC3. They
// correspond to ex1, ex2 and wr in the DPU but do not operate in lockstep.
// The load/store pipe also contains the local exclusive monitor, used by
// LDREX/STREX/CLREX instructions.
//
//-----------------------------------------------------------------------------

`include "ca53_dpu_dcu_defs.v"
`include "ca53_gov_dcu_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53dcu_defs.v"
`include "cortexa53params.v"

module ca53dcu_lspipe `CA53_DCU_PARAM_DECL
  (
   input   wire             clk,
   input   wire             reset_n,
   input   wire             DFTSE,


   //--------------------------------------------------------------------------
   // DCU Top-Level Interface
   //--------------------------------------------------------------------------

   input   wire             mbist_en_i,

   output  wire             ls_wfx_ready_o,


   //--------------------------------------------------------------------------
   // DPU Interface
   //--------------------------------------------------------------------------

   input   wire      [3:1]  dpu_aarch64_at_el_i,
   input   wire             dpu_valid_iss_i,
   input   wire             dpu_valid_cp_iss_i,
   input   wire             dpu_store_iss_i,
   input   wire     [15:0]  dpu_strobe_iss_i,
   input   wire      [1:0]  dpu_exception_level_i,
   input   wire             dpu_aarch64_state_i,
   input   wire             dpu_excl_iss_i,
   input   wire     [21:0]  dpu_periphbase_i,
   input   wire             dpu_pld_iss_i,
   input   wire             dpu_pld_level_iss_i,
   input   wire             dpu_priv_iss_i,
   input   wire             dpu_first_iss_i,
   input   wire      [4:0]  dpu_length_iss_i,
   input   wire      [1:0]  dpu_size_iss_i,
   input   wire             dpu_req_align_iss_i,
   input   wire      [2:0]  dpu_align_size_iss_i,
   input   wire             dpu_non_temporal_iss_i,
   input   wire             dpu_ldar_stlr_iss_i,
   input   wire             dpu_burst_iss_i,
   input   wire             dpu_cross_64_iss_i,
   input   wire             dpu_icache_on_i,
   input   wire             dpu_second_x64_iss_i,
   input   wire             dpu_neon_access_iss_i,
   input   wire      [8:0]  dpu_cp_op_iss_i,
   input   wire     [63:0]  dpu_va_dc1_i,
   input   wire             dpu_utlb_hit_dc1_i,
   input   wire      [3:0]  dpu_utlb_hit_entry_dc1_i,
   input   wire    [39:12]  dpu_pa_dc1_i,
   input   wire     [12:0]  dpu_attributes_dc1_i,
   input   wire      [8:0]  dpu_fault_dc1_i,
   input   wire             dpu_ns_dsc_dc1_i,
   input   wire             dpu_ready_wr_i,
   input   wire     [63:0]  dpu_cp_data_wr_i,
   input   wire    [127:0]  dpu_st_data_wr_i,
   input   wire             dpu_kill_wr_i,
   input   wire             dpu_flush_i,
   input   wire             dpu_cc_fail_wr_i,
   input   wire             dpu_ready_cc_fail_wr_i,
   input   wire             dpu_ready_cc_pass_wr_i,
   input   wire             dpu_ns_state_i,
   input   wire             dpu_scr_el3_ns_i,
   input   wire             dpu_dbg_dsb_req_i,
   input   wire             dpu_clear_excl_mon_i,
   input   wire             dpu_mmu_on_el1_i,
   input   wire             dpu_mmu_on_el2_i,
   input   wire             dpu_mmu_on_el3_i,
   input   wire             dpu_dcache_on_el1_i,
   input   wire             dpu_dcache_on_el2_i,
   input   wire             dpu_dcache_on_el3_i,
   input   wire             dpu_s2_dcache_on_i,
   input   wire             dpu_disable_dmb_i,
   input   wire             dpu_disable_no_allocate_i,
   input   wire      [3:0]  dpu_level_dc1_i,
   input   wire             dpu_stack_align_expt_dc1_i,
   input   wire             dpu_abort_dc1_i,
   input   wire      [3:0]  dpu_domain_dc1_i,
   input   wire             dpu_lpae_dc1_i,
   input   wire             dpu_ipa_to_pa_en_i,
   input   wire             dpu_default_cacheable_i,

   output  wire             dcu_ecc_err_dc3_o,
   output  wire             dcu_excl_mon_cleared_o,
   output  wire             dcu_ready_cp_iss_o,
   output  wire             dcu_ready_iss_o,
   output  wire             dcu_valid_dc3_o,
   output  wire     [63:0]  dcu_ld_data_dc3_o,
   output  wire             dcu_strex_okay_dc3_o,
   output  wire             dcu_wpt_hit_dc3_o,
   output  wire             dcu_p_abort_dc3_o,
   output  wire      [6:0]  dcu_p_fault_dc3_o,
   output  wire      [1:0]  dcu_p_fault_stage_dc3_o,
   output  wire      [3:0]  dcu_p_domain_dc3_o,
   output  wire             dcu_p_direction_dc3_o,
   output  wire             dcu_v2p_lpae_dc3_o,
   output  wire             dcu_cm_operation_dc3_o,
   output  wire     [63:0]  dcu_va_dc3_o,
   output  wire             dcu_dbg_dsb_ack_o,
   output  wire             dcu_evnt_dc_access_o,


   //--------------------------------------------------------------------------
   // Governor Interface
   //--------------------------------------------------------------------------

   input   wire             giccdisable_i,
   input   wire             gov_stall_dsb_rs_i,
   input   wire             gov_cp_ack_i,
   input   wire     [63:0]  gov_cp_rdata_i,

   output  wire     [17:0]  dcu_cp_gov_addr_o,
   output  wire             dcu_cp_gov_ns_o,
   output  wire             dcu_cp_gov_req_o,
   output  wire      [2:0]  dcu_cp_gov_sel_o,
   output  wire     [63:0]  dcu_cp_gov_wdata_o,
   output  wire             dcu_cp_gov_wenable_o,


   //--------------------------------------------------------------------------
   // TLB Interface
   //--------------------------------------------------------------------------

   input   wire     [15:0]  tlb_wpt_hit_dc1_i,
   input   wire     [63:0]  tlb_cp_read_data_dc2_i,
   input   wire             tlb_cp_ack_i,
   input   wire             tlb_cp_reg_write_ready_i,
   input   wire      [7:0]  tlb_vmid_i,
   input   wire             tlb_d_utlb_enable_i,
   input   wire      [1:0]  tlb_d_tcr_el1_tbi_i,
   input   wire             tlb_d_tcr_el2_tbi0_i,
   input   wire             tlb_d_tcr_el3_tbi0_i,

   output  wire             dcu_ongoing_burst_dc1_o,
   output  wire     [61:0]  dcu_cp_addr_tlb_o,
   output  wire      [5:0]  dcu_cp_reg_en_dc2_o,
   output  wire             dcu_cp_reg_write_dc3_o,
   output  wire             dcu_cp_reg_write_active_o,
   output  wire      [5:0]  dcu_cp_reg_en_dc3_o,
   output  wire     [63:0]  dcu_cp_reg_data_o,
   output  wire             dcu_cp_reg_size_o,
   output  wire             dcu_cp_valid_tlb_o,
   output  wire      [4:0]  dcu_cp_op_tlb_o,
   output  wire             dcu_priv_dc1_o,
   output  wire             dcu_block_lookups_o,
   output  wire             dcu_wpt_check_512_dc1_o,
   output  wire      [2:0]  dcu_transl_type_dc1_o,
   output  wire             dcu_va_valid_dc1_o,
   output  wire             dcu_va_valid_early_dc1_o,


   //--------------------------------------------------------------------------
   // BIU Interface
   //--------------------------------------------------------------------------

   input   wire             biu_pld_l2_next_ready_i,
   input   wire             biu_read_data_valid_dc2_i,
   input   wire     [63:0]  biu_read_data_dc2_i,
   input   wire             biu_read_data_valid_dc3_i,
   input   wire     [63:0]  biu_read_data_dc3_i,
   input   wire             biu_lf_ready_dc2_i,
   input   wire             biu_lf_next_ready_dc3_i,
   input   wire             biu_strex_bresp_valid_i,
   input   wire      [1:0]  biu_strex_bresp_i,
   input   wire             biu_read_abort_dc3_i,
   input   wire      [1:0]  biu_read_fault_dc3_i,
   input   wire             biu_dirty_lf_in_progress_i,
   input   wire             biu_read_abort_dc2_i,
   input   wire      [1:0]  biu_read_fault_dc2_i,

   output  wire             dcu_lf_req_dc1_o,
   output  wire      [1:0]  dcu_lf_way_dc1_o,
   output  wire      [7:0]  dcu_attrs_dc1_o,
   output  wire      [7:0]  dcu_attrs_dc2_o,
   output  wire             ls_biu_active_o,
   output  wire             dcu_exclusive_dc2_o,
   output  wire             dcu_leaving_dc1_o,
   output  wire             dcu_leaving_dc2_o,
   output  wire      [3:0]  dcu_length_dc2_o,
   output  wire             dcu_lf_req_dc2_o,
   output  wire      [1:0]  dcu_lf_way_dc2_o,
   output  wire             dcu_lf_active_o,
   output  wire             dcu_load_dc1_o,
   output  wire             dcu_load_dc2_o,
   output  wire     [63:0]  dcu_mbist_out_data_mb6_o,
   output  wire             dcu_ns_dsc_dc2_o,
   output  wire     [39:0]  dcu_pa_dc2_o,
   output  wire             dcu_pld_l2_req_dc2_o,
   output  wire      [1:0]  dcu_size_dc2_o,
   output  wire             dcu_biu_req_dc2_o,
   output  wire             dcu_load_dc3_o,
   output  wire             dcu_lf_req_dc3_o,
   output  wire      [1:0]  dcu_lf_way_dc3_o,
   output  wire             dcu_biu_req_dc3_o,
   output  wire     [39:0]  dcu_pa_dc3_o,
   output  wire             dcu_ns_dsc_dc3_o,
   output  wire             dcu_priv_dc3_o,
   output  wire      [7:0]  dcu_attrs_dc3_o,
   output  wire      [1:0]  dcu_size_dc3_o,
   output  wire      [3:0]  dcu_length_dc3_o,
   output  wire             dcu_neon_access_dc3_o,
   output  wire             dcu_pipe_valid_dc3_o,
   output  wire             dcu_store_last_dc3_o,
   output  wire             dcu_exclusive_dc3_o,
   output  wire             dcu_pldw_dc3_o,
   output  wire             dcu_pld_l2_req_dc3_o,
   output  wire             ls_stop_pf_o,


   //--------------------------------------------------------------------------
   // IFU Interface
   //--------------------------------------------------------------------------

   input   wire             ifu_cp_ack_i,

   output  wire     [39:0]  dcu_cp_addr_ifu_o,
   output  wire             dcu_cp_valid_ifu_o,
   output  wire      [2:0]  dcu_cp_op_ifu_o,

   // The following dcu_cp_* signal are shared with the TLB interface
   output  wire             dcu_cp_ns_o,


   //--------------------------------------------------------------------------
   // SCU Interface
   //--------------------------------------------------------------------------

   input   wire             scu_broadcastinner_i,


   //--------------------------------------------------------------------------
   // STB Interface
   //--------------------------------------------------------------------------

   input   wire      [4:0]  stb_slots_valid_i,
   input   wire      [4:0]  stb_slots_emptying_i,
   input   wire      [4:0]  stb_slots_dev_ng_i,
   input   wire             stb_cacheable_strex_done_i,
   input   wire             stb_strex_failed_i,
   input   wire      [4:0]  stb_can_merge_dc2_i,
   input   wire      [4:0]  stb_sameline_dc2_i,
   input   wire      [4:0]  stb_load_sameline_dc2_i,
   input   wire             stb_attr_mismatch_dc2_i,
   input   wire      [7:0]  stb_hit_dc2_i,
   input   wire     [63:0]  stb_data_dc2_i,
   input   wire             stb_block_loads_dc1_i,
   input   wire             stb_force_non_mergeable_i,

   output  wire             dcu_drain_entire_stb_o,
   output  wire             dcu_exclusive_monitor_o,
   output  wire             dcu_store_dc1_o,
   output  wire             dcu_valid_dc2_o,
   output  wire             dcu_store_dc2_o,
   output  wire             dcu_store_dc3_o,
   output  wire             dcu_stb_req_dc3_o,
   output  wire             dcu_stlr_dc3_o,
   output  wire      [4:0]  dcu_store_merge_dc3_o,
   output  wire      [4:0]  dcu_store_sameline_dc3_o,
   output  wire      [4:0]  dcu_load_sameline_dc3_o,
   output  wire             dcu_store_cp15_dc3_o,
   output  wire             dcu_store_dmb_dc3_o,
   output  wire             dcu_store_dsb_dc3_o,
   output  wire             dcu_dvm_sync_needed_dc3_o,
   output  wire     [15:0]  dcu_store_bls_dc3_o,
   output  wire             dcu_force_non_mergeable_dc3_o,
   output  wire      [7:0]  dcu_stb_attrs_dc3_o,
   output  wire             dcu_stb_exclusive_dc3_o,


   //--------------------------------------------------------------------------
   // Cache arbiter
   //--------------------------------------------------------------------------

   input   wire             dc_ecc_tag_err_m2_i,
   input   wire             dc_ecc_err_m3_i,
   input   wire             dc_load_has_priority_m1_i,
   input   wire             dc_load_hit_m2_i,
   input   wire             dc_load_raw_hit_m2_i,
   input   wire     [63:0]  dc_load_data_m2_i,
   input   wire     [63:0]  dc_debug_tag_data_m2_i,
   input   wire      [1:0]  dc_load_victim_way_m2_i,
   input   wire             dcu_ecc_in_progress_i,
   input   wire             load_lookup_m2_i,
   input   wire             alloc_invalidating_tag_m1_i,
   input   wire             dc_throttle_loads_i,
   input   wire             dc_load_index_match_m1_i,

   output  wire             dc_load_req_m1_o,
   output  wire             dc_valid_load_req_m1_o,
   output  wire             dc_load_tag_req_only_m1_o,
   output  wire             dc_load_first_m1_o,
   output  wire             dc_force_non_seq_o,
   output  wire             dc_force_first_o,
   output  wire     [39:3]  dc_load_addr_m1_o,
   output  wire             dc_load_tag_ns_dsc_m1_o,
   output  wire      [7:0]  dc_load_bls_m1_o,


   //--------------------------------------------------------------------------
   // Dcache CP15 maintenance operations control block
   //--------------------------------------------------------------------------

   input   wire             dc_inv_all_in_progress_i,
   input   wire             cp15_inv_all_force_miss_i,
   input   wire             dc_cp15_ack_i,
   input   wire             tag_debug_op_ack_i,
   input   wire             data_debug_op_ack_i,
   input   wire             force_reset_i,

   output  wire             dc_cp15_start_dc3_o,
   output  wire             dc_cp15_op_data_dc3_o,
   output  wire     [13:3]  dc_cp15_addr_dc3_o,
   output  wire      [1:0]  dc_cp15_way_dc3_o,


   //--------------------------------------------------------------------------
   // CCB
   //--------------------------------------------------------------------------

   input   wire     [40:6]  ccb_write_addr_m1_i,
   input   wire             ccb_invalidating_tag_m1_i,
   input   wire             ccb_throttle_loads_i,
   input   wire     [34:0]  mbist_ctl_data_mb3_i,


   //--------------------------------------------------------------------------
   // DVM block
   //--------------------------------------------------------------------------

   input   wire             dcu_dvm_valid_tlb_i,
   input   wire             dvm_ns_i,
   input   wire     [61:0]  dvm_cp_addr_i,
   input   wire      [4:0]  dvm_tlb_cp_op_i,
   input   wire      [2:0]  dvm_ifu_cp_op_i,
   input   wire             dvm_in_progress_i,

   output  wire             valid_dc1_o,
   output  wire             valid_dc2_o,
   output  wire             valid_dc3_o,
   output  wire             next_valid_dc2_o,
   output  wire             next_valid_dc3_o,
   output  wire             dsb_dc1_o,
   output  wire             dsb_dc2_o,
   output  wire             dsb_dc3_o,
   output  wire             block_dvm_dc3_o,
   output  wire             v_enable_dc1_o,
   output  wire             v_enable_dc2_o,
   output  wire             v_enable_dc3_o


  );


  //---------------------------------------------------------------------------
  // Local parameters
  //---------------------------------------------------------------------------

  localparam BIT_ALIGN_WD = 8;  // When used in DC2
  localparam BIT_MEM_MAP  = 8;  // When used in DC3
  localparam BIT_NEON     = 7;
  localparam BIT_PRIV     = 6;
  localparam BIT_STORE    = 5;
  localparam BIT_EXCL     = 4;
  localparam BIT_PLD_L2   = 3;
  localparam BIT_PLD      = 2;
  localparam BIT_2ND_X64  = 1;
  localparam BIT_CROSS_64 = 0;

  localparam [2:0] LF_IDLE = 3'b000;
  localparam [2:0] LF_M1   = 3'b100;  // Encoded so can decode M1 by looking at 1 bit
  localparam [2:0] LF_M2   = 3'b001;
  localparam [2:0] LF_REQ  = 3'b010;
  localparam [2:0] LF_HIT  = 3'b011;
  localparam [2:0] LF_X    = 3'bxxx;


  //---------------------------------------------------------------------------
  // Signal declarations
  //---------------------------------------------------------------------------

  wire           abort_dc1;
  reg   [ 7: 0]  abort_dc2;
  reg            abort_dc3;
  wire           align_fault_s2_dc1;
  wire           align_fault_taken_dc1;
  wire           va_fault_taken_dc1;
  wire           out_of_range_dc1;
  reg            ttbr_tbi;
  wire           stack_align_fault_taken_dc1;
  reg   [ 4: 0]  align_mask_dc1;
  reg   [ 2: 0]  align_size_dc1;
  wire           attr_mismatch_dc2;
  reg            attr_mismatch_dc3;
  wire  [ 7: 0]  attrs_dc1;
  reg   [ 7: 0]  attrs_dc2;
  reg   [ 7: 0]  attrs_dc3;
  wire           block_dvm_dc3;
  reg            block_loads_dc1;
  wire           broadcast_cp15_dc3;
  wire           cache_off_dc1;
  wire  [ 3: 0]  cache_words_remaining_dc1;
  wire           cacheable_dc2;
  wire           cacheable_dc3;
  wire           cacheable_ntrans_dc2;
  wire           cacheable_ntrans_dc3;
  wire           cc_fail_dc1;
  wire           cc_fail_dc2;
  wire           cc_fail_or_flush_dc1;
  wire           cc_fail_or_flush_dc2;
  wire           cc_fail_or_flush_dc3;
  wire           excl_line_removed_from_cache;
  wire           clrex_dc1;
  wire           clrex_dc2;
  wire           clrex_dc3;
  wire           committing_excl_dc3;
  wire           complete_cache_hit_load_dc2;
  wire           complete_simple_dc2;
  wire           complete_simple_dc3;
  wire           complete_cp_op_dc3;
  wire           complete_cp_reg_dc2;
  wire           complete_cp_reg_dc3;
  wire           complete_dc2;
  wire           complete_dc3;
  wire           complete_dsb_dc3;
  wire           complete_exception_dc2;
  wire           complete_exception_dc3;
  wire           complete_gov_dc3;
  wire           complete_load_dc2;
  wire           complete_load_dc3;
  wire           complete_store_dc2;
  wire           complete_store_dc3;
  wire           dcu_needs_dvm_intf_dc2;
  wire           dcu_needs_dvm_intf_dc3;
  reg            cp15_done_dc3;
  wire           cp15_needs_broadcast_dc2;
  reg            cp15_needs_broadcast_dc3;
  wire  [61: 0]  dcu_cp_addr;
  wire           cp_dc_debug_op_dc3;
  wire           cp_dc_ic_debug_op_dc2;
  wire           cp_dc_ic_debug_op_dc3;
  wire           cp_dc_maint_op_dc1;
  wire           cp_ifu_maint_dc1;
  wire           cp_dc_maint_op_dc2;
  wire           cp_debug_op_dc3;
  wire           gov_op_dc3;
  wire           cp_v2p_dc1;
  reg            cp_inst_dc1;
  reg            cp_inst_dc2;
  reg            cp_inst_dc3;
  wire           cp_is_bp_maint_dc1;
  wire           cp_is_bp_maint_dc2;
  wire           cp_is_bp_maint_dc3;
  wire           cp_is_dc_debug_dc3;
  wire           cp_is_gic_dc3;
  wire           cp_is_dc_maint_dc1;
  wire           cp_is_dc_maint_dc2;
  wire           cp_is_dc_maint_dc3;
  wire           cp_is_ic_debug_dc3;
  wire           cp_is_ifu_maint_dc1;
  wire           cp_is_ifu_maint_dc2;
  wire           cp_is_ifu_maint_dc3;
  wire           cp_is_maint_mva_dc1;
  wire           cp_is_mva_dc1;
  wire           cp_is_mva_dc2;
  wire           cp_is_reg_dc1;
  wire           cp_is_tlb_debug_dc3;
  wire           cp_is_ic_debug_dc2;
  wire           cp_is_dc_debug_dc2;
  wire           cp_is_tlb_debug_dc2;
  wire           cp_is_tlb_maint_dc1;
  wire           cp_is_tlb_maint_dc2;
  wire           cp_is_tlb_maint_dc3;
  wire           cp_is_v2p_dc1;
  wire           cp_is_v2p_dc2;
  wire           cp_is_v2p_dc3;
  wire  [15: 0]  cp_inst_strobe_dc3;
  reg   [ 8: 0]  cp_op_dc1;
  reg   [ 8: 0]  cp_op_dc2;
  reg   [ 8: 0]  cp_op_dc3;
  wire           cp_read_dc1;
  reg            cp_read_dc3;
  wire           cp_write_dc1;
  reg            cp_write_dc2;
  reg            cp_write_dc3;
  wire           cross_64_dc1;
  wire           cross_64_dc2;
  wire           second_x64_dc1;
  reg   [63: 0]  data_dc2;
  reg   [63: 0]  data_dc3;
  wire  [ 7: 0]  data_dc_mux_en_dc2;
  wire  [ 7: 0]  data_en_dc2;
  wire  [ 7: 0]  data_en_dc3;
  wire  [ 7: 0]  data_biu_mux_en_dc2;
  reg   [ 7: 0]  data_mask_dc2;
  reg   [ 7: 0]  data_mask_dc3;
  wire  [ 7: 0]  data_stb_mux_en_dc2;
  wire           dc_inv_mva_dc1;
  wire           dcache_hit_enable_dc2;
  wire           dcache_on_dc1;
  wire           mmu_on_dc1;
  wire           dccmvau_dc1;
  wire           dcu_biu_req_dc3;
  reg            dcu_cp_read_dc2;
  wire           dcu_cp_reg_write_no_exc;
  wire           dcu_cp_valid;
  reg            dcu_dbg_dsb_ack;
  wire           dcu_excl_shareable_dc2;
  wire           dcu_excl_shareable_dc3;
  wire           dcu_leaving_dc2;
  wire           dcu_lf_req_dc2;
  wire           dcu_lf_req_dc3;
  reg   [ 1: 0]  dcu_lf_way_dc2;
  reg   [ 1: 0]  dcu_lf_way_dc3;
  reg            dcu_load_dc2;
  wire           dcu_load_dc3;
  wire  [39: 0]  dcu_pa_dc3;
  wire           dcu_ready_cp_iss;
  wire           dcu_ready_iss;
  wire  [ 1: 0]  dcu_size_dc2;
  reg   [ 1: 0]  dcu_size_dc3;
  wire           dcu_stb_req_dc3;
  wire  [ 4: 0]  dcu_store_merge_dc2;
  reg   [ 4: 0]  dcu_store_merge_dc3;
  wire  [ 4: 0]  dcu_store_sameline_dc2;
  reg   [ 4: 0]  dcu_store_sameline_dc3;
  wire  [ 2: 0]  dcu_transl_type_dc1;
  wire           next_dcu_va_valid_early_dc1;
  reg            dcu_va_valid_early_dc1;
  wire           dcu_va_valid_dc1;
  reg            dcu_valid_dc3;
  wire           dczva_dc1;
  wire           dmb_dc1;
  wire           dmb_dc2;
  wire           dmb_dc3;
  wire           dmb_full_dc3;
  wire           dmbld_dc1;
  wire           dmbld_dc2;
  wire           dmbld_dc3;
  wire           dmbst_dc1;
  wire           dmbst_dc2;
  wire           dmbst_dc3;
  reg   [ 3: 0]  domain_dc2;
  reg   [ 3: 0]  domain_dc3;
  wire           domain_fault_dc1;
  wire           quadword_match;
  wire           dpu_fault_taken_dc1;
  wire  [ 6: 0]  dpu_fault_type_dc1;
  wire           dsb_dc1;
  wire           dsb_dc2;
  wire           dsb_dc3;
  wire           dxb_dc1;
  wire           dxb_dc2;
  wire           dxb_dc3;
  wire           barrier_iss;
  wire           force_dsb_iss;
  reg            ecc_err_dc2;
  reg            ecc_err_dc3;
  wire           early_stall_dc1;
  wire           enable_dc1;
  wire           enable_dc2;
  wire           enable_dc3;
  reg            new_va_top_byte_dc2;
  wire           next_new_va_top_byte_dc2;
  wire           enable_transl_dc2;
  wire           suppress_enable_transl_dc2;
  wire           enable_va_top_byte_dc2;
  wire           enable_va_top_byte_dc3;
  wire           enable_va_upper_dc2;
  wire           enable_va_upper_dc3;
  wire           utlb_entry_match_dc1_dc2;
  wire           enable_transl_dc3;
  wire           excl_dc1;
  wire           excl_dc2;
  wire           excl_dc3;
  wire           align_size_word_dc2;
  reg            exclusive_monitor;
  wire           next_exclusive_monitor;
  reg   [40: 6]  exclusive_tag;
  reg            exclusive_tag_cacheable;
  wire  [ 6: 0]  fault_dc1;
  reg   [ 6: 0]  fault_dc2;
  reg   [ 6: 0]  fault_dc3;
  wire  [ 1: 0]  fault_stage_dc1;
  reg   [ 1: 0]  fault_stage_dc2;
  reg   [ 1: 0]  fault_stage_dc3;
  reg            first_dc1;
  reg            first_dc2;
  reg            first_dc3;
  wire           flush_dc1;
  wire           flush_dc2;
  wire           flush_dc3;
  wire           force_nc_dc1;
  wire           force_transient_dc1;
  wire           force_no_write_alloc_dc1;
  wire           force_dword_dc2;
  wire           force_non_mergeable_early_dc3;
  wire           force_word_dc2;
  reg   [17: 0]  gov_addr_dc3;
  reg            gov_cp_ack_reg;
  reg   [63: 0]  gov_cp_data_dc3;
  wire           gov_cp_data_en_dc3;
  wire           gov_cp_req_data_en_dc3;
  wire           gov_mem_abort_dc2;
  wire           gov_mem_access_dc2;
  wire           gov_mem_access_dc3;
  reg            gov_ns_dc3;
  reg   [ 2: 0]  gov_sel_dc3;
  reg            gov_wenable_dc3;
  reg            gov_req_dc3;
  reg            icache_on;
  wire           instr_non_mergeable_dc3;
  wire  [ 7: 0]  ld_data_biu_dc3_en_dc3;
  wire  [ 7: 0]  ld_data_dc2_en_dc3;
  wire  [ 7: 0]  ld_data_dc_en_dc3;
  wire  [ 7: 0]  ld_data_biu_dc2_en_dc3;
  wire  [ 7: 0]  ld_data_stb_en_dc3;
  wire  [ 7: 0]  ld_data_tlb_en_dc3;
  reg   [ 1: 0]  ldar_stlr_barrier_type_dc3;
  reg   [ 4: 0]  length_dc1;
  reg   [ 3: 0]  length_dc2;
  wire  [ 3: 0]  final_length_dc2;
  wire           new_biu_abort_dc2;
  wire           line_match;
  reg            load_dc1;
  reg            load_dc3;
  wire           load_done_dc2;
  wire           load_done_dc3;
  wire           load_last_dc2;
  wire  [ 4: 0]  load_sameline_dc2;
  reg   [ 4: 0]  dcu_load_sameline_dc3;
  wire  [ 7: 0]  load_strobe_dc2;
  wire  [ 7: 0]  load_strobe_dc3;
  reg            ldar_stlr_dc1;
  reg            ldar_stlr_dc2;
  reg            ldar_stlr_dc3;
  wire           merge_sameline_en;
  wire           load_sameline_en;
  wire           mergeable_dc2;
  wire           mergeable_dc3;
  wire           must_enable_transl_dc1;
  wire  [ 7: 0]  new_abort_dc2;
  wire           new_abort_dc3;
  wire           new_biu_abort_dc3;
  wire  [ 7: 0]  new_data_mask_dc2;
  wire  [ 7: 0]  new_data_mask_dc3;
  wire  [ 6: 0]  biu_fault_dc2;
  wire  [ 6: 0]  biu_fault_dc3;
  wire  [ 6: 0]  new_fault_dc2;
  wire  [ 6: 0]  new_fault_dc3;
  wire  [ 4: 0]  new_slot;
  wire           new_slot_avail;
  reg            new_transl_dc2;
  wire  [ 7: 0]  next_abort_dc2;
  wire           next_abort_dc3;
  wire           next_cp15_done_dc3;
  wire  [ 8: 0]  next_cp_op_dc1;
  wire  [ 8: 0]  next_cp_op_dc2;
  wire  [ 8: 0]  next_cp_op_dc3;
  wire  [63: 0]  next_data_dc2;
  wire  [63: 0]  next_data_dc3;
  wire  [ 7: 0]  next_data_mask_dc2;
  wire  [ 7: 0]  next_data_mask_dc3;
  wire           next_dcu_cp_read_dc2;
  wire           next_dcu_dbg_dsb_ack;
  wire  [ 1: 0]  next_dcu_lf_way_dc2;
  wire  [ 1: 0]  next_dcu_lf_way_dc3;
  wire           next_dcu_load_dc2;
  wire  [ 4: 0]  next_dcu_store_merge_dc3;
  wire           next_dcu_valid_dc3;
  wire           next_block_loads_dc1;
  wire  [ 3: 0]  next_domain_dc2;
  wire  [40: 6]  next_exclusive_tag;
  wire  [ 6: 0]  next_fault_dc2;
  wire           abort_dc2_en;
  wire           fault_dc2_en;
  wire           fault_dc3_en;
  wire  [ 6: 0]  next_fault_dc3;
  wire  [17: 0]  next_gov_addr_dc3;
  wire  [63: 0]  next_gov_cp_data_dc3;
  wire           next_gov_req_dc3;
  wire  [ 2: 0]  next_gov_sel_dc3;
  wire           next_load_dc1;
  wire           next_load_done_dc2;
  wire           next_load_done_dc3;
  wire           next_misc_stall_load;
  wire           throttle_loads_dc1;
  wire           next_new_transl_dc2;
  wire           next_ns_dsc_dc3;
  wire           next_ongoing_burst_dc1;
  wire           clear_ongoing_burst_dc1;
  wire           next_slot_avail_dc2;
  wire           next_slot_avail_dc3;
  wire  [ 4: 0]  next_slots_valid;
  wire           next_stb_empty;
  wire           next_stb_not_full;
  wire  [ 4: 0]  next_stb_slots_valid;
  wire           next_store_sent_dc3;
  wire           next_strex_monitor_failed_dc3;
  wire           next_tlb_lookup_stall_dc1;
  wire           next_transl_valid_dc2;
  wire           next_valid_dc1;
  wire           next_valid_dc2;
  wire           next_valid_dc3;
  wire           no_abort_dc3;
  reg            non_temporal_dc1;
  wire           cacheable_ntrans_dc1;
  wire           normal_dc1;
  wire           normal_dc2;
  wire           normal_dc3;
  reg            ns_dsc_dc2;
  reg            ns_dsc_dc3;
  reg            dcu_ongoing_burst_dc1;
  wire  [39: 0]  pa_dc2;
  wire  [63: 0]  par_dc3;
  wire  [ 7: 0]  par_lpae_attrs_dc3;
  wire  [11: 0]  par_lpae_fault_dc3;
  wire  [ 3: 0]  par_lpae_inner_attrs_dc3;
  wire  [63: 0]  par_lpae_nofault_dc3;
  wire  [ 3: 0]  par_lpae_outer_attrs_dc3;
  wire  [11: 0]  par_vmsa_fault_dc3;
  wire  [ 2: 0]  par_vmsa_inner_dc3;
  wire  [63: 0]  par_vmsa_nofault_dc3;
  wire  [ 1: 0]  par_vmsa_outer_dc3;
  wire  [31:12]  par_vmsa_pa_dc3;
  wire  [ 1: 0]  perm_fault_level_dc1;
  reg            perm_fault_s1_dc1;
  wire           perm_fault_s2_dc1;
  wire           perm_fault_taken_dc1;
  wire           pld_dc1;
  wire           pld_dc2;
  wire           pld_dc3;
  wire           pldw_dc3;
  wire           pldl2_dc2;
  wire           pldl2_dc3;
  wire           pld_l2_req_dc2;
  wire           pld_l2_req_dc3;
  reg            previous_stall_dc2;
  wire           neon_dc3;
  reg            priv_dc3;
  wire           next_priv_dc3;
  reg            priv_perm_check_dc1;
  wire  [ 7: 0]  raw_mem_attrs_dc1;
  wire           raw_hazard_dc2;
  wire           raw_sameline_dc2;
  wire           reg_en_dc1;
  wire           reg_en_dc3;
  wire           reg_en_stall_dc2;
  wire           reg_en_valid_dc2;
  reg            req_align_dc1;
  wire  [ 1: 0]  s1_exc_level;
  wire           s1_transl_valid_dc1;
  wire           s2_exc_level_el0_el1;
  wire           set_exclusive_monitor;
  wire           shareable_dc2;
  wire           shareable_dc3;
  reg   [ 1: 0]  size_dc1;
  reg   [ 1: 0]  size_dc2;
  wire           slot_avail;
  wire           stall_dc1;
  wire           stall_dc2;
  wire           stall_dc3;
  reg            stb_empty;
  wire  [ 7: 0]  stb_hit_mergeable_dc2;
  reg            stb_not_full;
  wire  [ 4: 0]  stb_or_new_slot_dc3;
  wire           stb_store_req_early_dc3;
  wire           stb_force_non_mergeable_dc2;
  reg            stb_force_non_mergeable_dc3;
  wire           store_dc1;
  wire           store_dc2;
  reg            store_dc3;
  reg            raw_store_dc1;
  reg            raw_store_dc2;
  reg            raw_store_dc3;
  reg            store_sent_dc3;
  wire           strex_monitor_failed_dc2;
  reg            strex_monitor_failed_dc3;
  reg   [15: 0]  strobe_dc1;
  reg   [15: 0]  strobe_dc2;
  reg   [15: 0]  strobe_dc3;
  wire           supersection_dc1;
  reg            supersection_dc2;
  reg            supersection_dc3;
  reg            tlb_lookup_stall_dc1;
  reg            pipe_full_stall_dc1;
  wire           next_pipe_full_stall_dc1;
  reg   [ 2: 0]  next_lf_state_dc1;
  reg   [ 2: 0]  lf_state_dc1;
  wire  [ 1: 0]  next_dcu_lf_way_dc1;
  reg   [ 1: 0]  dcu_lf_way_dc1;
  reg   [ 2: 0]  transl_type_iss;
  reg   [ 2: 0]  transl_type_dc1;
  reg            transl_valid_dc2;
  reg   [ 3: 0]  utlb_entry_dc2;
  wire  [ 4: 0]  true_length_dc1;
  wire  [ 3: 0]  final_length_dc1;
  reg   [ 3: 0]  length_dc3;
  wire           unaligned_dc1;
  reg   [39:12]  upper_pa_dc2;
  reg   [39:12]  upper_pa_dc3;
  wire           v2p_abort_dc1;
  reg            v2p_abort_dc2;
  reg            v2p_abort_dc3;
  wire           v2p_lpae_dc1;
  reg            v2p_lpae_dc2;
  reg            v2p_lpae_dc3;
  wire           transl_ns_state_dc1;
  reg            v2p_ns_state_dc1;
  wire           v2p_trap_dc1;
  wire           v_enable_dc1;
  wire           v_enable_dc2;
  wire           v_enable_dc3;
  wire  [63: 0]  next_va_dc2;
  reg   [63: 0]  va_dc2;
  reg   [63: 0]  va_dc3;
  reg            valid_dc1;
  reg            valid_dc2;
  reg            valid_dc3;
  wire           valid_nabt_dc2;
  wire           valid_nabt_dc3;
  reg   [ 6: 0]  vmsa_fault_dc3;
  wire           waiting_for_utlb_dc1;
  wire           watchpoint_dc1;
  reg            watchpoint_dc2;
  reg            watchpoint_dc3;
  wire           waw_attr_mismatch_dc2;
  wire  [ 3: 0]  words_accessed_dc2;
  wire           dcu_ecc_err_dc2;
  wire           dcu_ecc_err_dc3;
  reg            seen_load_m3_dc2;
  wire           load_m3_dc2;
  wire           next_seen_load_m3_dc3;
  reg            seen_load_m3_dc3;
  wire           load_m3_dc3;
  wire           next_ecc_err_dc3;
  wire           next_seen_load_m3_dc2;
  wire           next_ecc_err_dc2;
  wire           check_s1_perm_faults_dc1;
  wire           check_s2_perm_faults_dc1;
  wire           next_raw_store_dc1;
  wire           next_clk_dc2_enable;
  wire           next_clk_dc3_enable;
  wire           next_clk_rare_enable;
  reg            clk_dc2_enable;
  reg            clk_dc3_enable;
  reg            clk_rare_enable;
  wire           clk_dc2;
  wire           clk_dc3;
  wire           clk_rare;
  wire           gov_op_dc2;
  wire           next_excl_in_flight_cleared;
  reg            excl_in_flight_cleared;
  wire           excl_in_flight_match;
  wire           excl_mon_match;
  wire  [40: 6]  excl_in_flight_addr;
  wire           next_excl_mon_cleared;
  reg            excl_mon_cleared;
  reg            load_req_dc1;
  wire           next_load_req_dc1;
  wire           stall_iss;
  wire           biu_pld_l2_ready_dc2;
  reg            biu_pld_l2_ready;

  genvar dc2_byte, dc3_byte;


  //---------------------------------------------------------------------------
  // Instruction flush/CC fail
  //---------------------------------------------------------------------------

  // The DPU can flush the pipe in three ways:
  //
  // 1. Flush all DCU load store pipe stages (asserts dpu_flush and dpu_kill_wr)
  //
  // 2. Flush all stages except wr - i.e. everything except the earliest valid
  //    transaction in the pipe (with dpu_flush)
  //
  // 3. Flush just the request in wr with dpu_cc_fail_wr (this will be the earliest
  //    valid transaction in the pipe)

  assign flush_dc1 = (dpu_kill_wr_i & ~valid_dc3 & ~valid_dc2) |
                     (dpu_flush_i & (~dpu_ready_wr_i | valid_dc2 | valid_dc3));

  assign flush_dc2 = (dpu_kill_wr_i & ~valid_dc3) |
                     (dpu_flush_i & (~dpu_ready_wr_i | valid_dc3));

  assign flush_dc3 = dpu_kill_wr_i | (dpu_flush_i & ~dpu_ready_wr_i);

  // cc_fail earliest transaction in the pipeline

  assign cc_fail_dc1 = dpu_ready_cc_fail_wr_i & ~valid_dc3 & ~valid_dc2;
  assign cc_fail_dc2 = dpu_ready_cc_fail_wr_i & ~valid_dc3;

  assign cc_fail_or_flush_dc1 = flush_dc1 | cc_fail_dc1;
  assign cc_fail_or_flush_dc2 = flush_dc2 | cc_fail_dc2;
  assign cc_fail_or_flush_dc3 = flush_dc3 | dpu_ready_cc_fail_wr_i;


  //---------------------------------------------------------------------------
  // Regional clock gates
  //---------------------------------------------------------------------------
  // The lspipe contains three regional clock gates which take out larger
  // portions of the clock tree than the local clock enables. One is used for
  // the registers between DC1 and DC2 and the registers within DC2, another for
  // the registers between DC2 and DC3 and the registers within DC3, and the
  // third for registers which are not commonly used (those for governor
  // accesses and relating to the exclusive monitor).

  // Enable DC2 clock if may be pipelining something into DC2, or will have
  // transaction in DC2 on next cycle
  // - As this is used for the DC2 skid buffer, it must be set during MBIST and
  // when there is a DC debug operation in DC3, as these both use that register
  // - In general could pipeline on the next cycle when there is something in
  // DC1 (or will be on the next cycle), but when stalled waiting for a main TLB
  // lookup it is known a cycle in advance when the stall will resolve, so this
  // can factor in to the enable to save additional power on uTLB misses.
  assign next_clk_dc2_enable  = enable_dc1 | (valid_dc1 & ~(tlb_lookup_stall_dc1 & ~tlb_d_utlb_enable_i)) | // May pipeline DC1->DC2
                                stall_dc2 |
                                mbist_en_i |  (valid_dc3 & cp_inst_dc3 & cp_is_dc_debug_dc3);

  assign next_clk_dc3_enable  = enable_dc2 | valid_dc2 | stall_dc3;

  assign next_clk_rare_enable = (enable_dc2 &       load_dc1 & excl_dc1) |
                                (enable_dc3 & ((dcu_load_dc2 & excl_dc2) | gov_op_dc2)) |
                                (valid_dc3  & ((dcu_load_dc3 & excl_dc3) | gov_op_dc3));

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      clk_dc2_enable  <= 1'b0;
      clk_dc3_enable  <= 1'b1;  // Used by synchronously reset data_dc3, so enable initially
      clk_rare_enable <= 1'b0;
    end else begin
      clk_dc2_enable  <= next_clk_dc2_enable;
      clk_dc3_enable  <= next_clk_dc3_enable;
      clk_rare_enable <= next_clk_rare_enable;
    end

  ca53_cell_inter_clkgate u_inter_clkgate_dc2  (.clk_i         (clk),
                                                .clk_enable_i  (clk_dc2_enable),
                                                .clk_senable_i (DFTSE),
                                                .clk_gated_o   (clk_dc2));

  ca53_cell_inter_clkgate u_inter_clkgate_dc3  (.clk_i         (clk),
                                                .clk_enable_i  (clk_dc3_enable),
                                                .clk_senable_i (DFTSE),
                                                .clk_gated_o   (clk_dc3));

  ca53_cell_inter_clkgate u_inter_clkgate_rare (.clk_i         (clk),
                                                .clk_enable_i  (clk_rare_enable),
                                                .clk_senable_i (DFTSE),
                                                .clk_gated_o   (clk_rare));


  //---------------------------------------------------------------------------
  // Track external state
  //---------------------------------------------------------------------------
  // The load/store pipe must track various state which is not related to
  // a particular pipeline stage.

  //-----------
  // STB slots
  //-----------
  // Track which slots are valid in the STB, to save factoring the external
  // input into critical signals.
  assign next_stb_slots_valid = (stb_slots_valid_i & ~stb_slots_emptying_i) |
                                ({5{dcu_stb_req_dc3 & ~dpu_kill_wr_i}} & stb_or_new_slot_dc3);

  assign next_stb_empty    = ~|next_stb_slots_valid;
  assign next_stb_not_full = ~&next_stb_slots_valid;

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      stb_empty     <= 1'b1;
      stb_not_full  <= 1'b1;
    end else begin
      stb_empty     <= next_stb_empty;
      stb_not_full  <= next_stb_not_full;
    end


  //------------------
  // DMBs in progress
  //------------------
  // The STB indicates when a DMB, STLR or Data Cache maintance operation is in
  // progress, but the signal is too late to use directly. The signal is set
  // when the DCU puts a DMB Full, STLR or DC* into the STB from DC3, so the
  // the DCU registers when this happens and tracks the signal from the STB
  // clearing. The STB can also set the signal if it needs to block loads in
  // order to help a store make progress.
  //
  // Since this register is used to block loads, other conditions which need to
  // block loads are also factored in, to improve timing as only one register
  // needs to factor into the stall terms on the next cycle.

  // - stall a load in DC1 when there is an exclusive or DMB/DMBLD in DC2 or DC3
  // - stall a load in DC1 when the STB indicates an ongoing DMB, STLR, DC*, or
  //   a store that can't make progress due to continual evictions.
  // - only stall the first beat so an LDXP does not stall against itself and
  //   the STB doesn't block loads in the middle of a burst.
  assign next_misc_stall_load = (v_enable_dc1 ? dpu_first_iss_i : first_dc1) &
                                (stb_block_loads_dc1_i |
                                 ((excl_dc1 | clrex_dc1 | (dmb_dc1 & ~dmbst_dc1) | dmbld_dc1 | ldar_stlr_dc1) & v_enable_dc2 & next_valid_dc2)      |
                                 ((excl_dc2 | clrex_dc2 | (dmb_dc2 & ~dmbst_dc2) | dmbld_dc2 | ldar_stlr_dc2) & valid_dc2 & ~cc_fail_or_flush_dc2)  |
                                 ((excl_dc3 | clrex_dc3 | (dmb_dc3 & ~dmbst_dc3) | dmbld_dc3 | ldar_stlr_dc3) & stall_dc3));

  // - throttle load requests by blocking loads in DC1 when indicated by
  // cachearb or CCB.
  assign throttle_loads_dc1   = dc_throttle_loads_i | ccb_throttle_loads_i;

  assign next_block_loads_dc1 = next_misc_stall_load                        |
                                throttle_loads_dc1                          |
                                (dcu_stb_req_dc3 & (dmb_full_dc3 |                // Set when putting DMB Full (including STLR barrier)
                                                    (ldar_stlr_dc3 & store_dc3) | // - or STLR store
                                                    cp_is_dc_maint_dc3));         // - or DC* maintenance instruction

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      block_loads_dc1 <= 1'b0;
    else
      block_loads_dc1 <= next_block_loads_dc1;


  //---------------------------------------------------------------------------
  // Iss -> DC1
  //---------------------------------------------------------------------------
  // Stall iss if DC1 stalled, if the ECC state machine is active (and ECC
  // present), or based on instructions already in the DCU.

generate if (CPU_CACHE_PROTECTION) begin : g_ecc_stall_iss_ecc
  // Only start stalling on ECC correction in progress after a DPU flush, so do
  // not stall half way through committed burst on unrelated ECC correction.
  reg   ecc_stall_iss;
  wire  next_ecc_stall_iss;

  assign next_ecc_stall_iss = dcu_ecc_in_progress_i & (dpu_flush_i | ecc_stall_iss);

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ecc_stall_iss <= 1'b0;
    else
      ecc_stall_iss <= next_ecc_stall_iss;

  assign stall_iss = early_stall_dc1 | ecc_stall_iss;

end else begin : g_ecc_stall_iss_no_ecc

  assign stall_iss = early_stall_dc1;

end endgenerate

  // DCU is ready to accept a new CP instruction when either DC1 is empty or the transaction
  // in DC1 is not stalling in this cycle (unless it is first cycle and uTLB has missed)
  // The DCU is also not ready if there is a DSB in any pipeline stage.
  assign dcu_ready_cp_iss = ~stall_iss &
                            ~(valid_dc1 & dsb_dc1) &
                            ~(valid_dc2 & dsb_dc2) &
                            ~(valid_dc3 & dsb_dc3);

  // DCU is ready to accept a new transaction from the DPU that requires an address
  // translation when all the conditions for dcu_ready_cp_iss are satisfied (see above)
  // and there are no CP instructions in the pipeline.
  assign dcu_ready_iss    = ~stall_iss &
                            ~(valid_dc1 & cp_inst_dc1 & ~dmb_dc1 & ~dmbld_dc1) &  // CP Op which isn't DMB/DMBST/DMBLD
                            ~(valid_dc2 & cp_inst_dc2 & ~dmb_dc2 & ~dmbld_dc2) &
                            ~(valid_dc3 & cp_inst_dc3 & ~dmb_dc3 & ~dmbld_dc3);

  assign dcu_ready_cp_iss_o = dcu_ready_cp_iss;
  assign dcu_ready_iss_o    = dcu_ready_iss;

  // Update valid in DC1 whenever not stalled or if clearing valid on a flush
  assign v_enable_dc1   = ~stall_dc1 | flush_dc1;
  assign next_valid_dc1 = (dpu_valid_iss_i ? dcu_ready_iss : (dpu_valid_cp_iss_i & dcu_ready_cp_iss)) & ~dpu_flush_i;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      valid_dc1 <= 1'b0;
    else if (v_enable_dc1)
      valid_dc1 <= next_valid_dc1;

  // Tell the TLB the type of translation to perform. For non-V2P ops, this is
  // forced to be "normal", i.e. for the current mode and security state in DC1.
  // - Driven in DC1, but calculated in Iss and pipelined to improve timing into
  // TLB
  always @*
    case(dpu_cp_op_iss_i[1:0])
      2'b00  : transl_type_iss = dpu_priv_iss_i ? `CA53_TRANSL_V2P_S1_EL1  : `CA53_TRANSL_V2P_S1_EL0;   // ATS1C, ATS1E01
      2'b01  : transl_type_iss = dpu_priv_iss_i ? `CA53_TRANSL_V2P_S12_EL1 : `CA53_TRANSL_V2P_S12_EL0;  // ATS12NSO, ATS12E01
      2'b10  : transl_type_iss = `CA53_TRANSL_V2P_S1_EL2; // ATS1H, ATS1E2
      2'b11  : transl_type_iss = `CA53_TRANSL_V2P_S1_EL3; // ATS1E3
      default: transl_type_iss = 3'bxxx;
    endcase

  // cp_op_dcX serves two purposes:
  // - For cp operations, it holds the CP opcode
  // - For non-cp operations, each bit encodes an instruction property:
  // Bit 8 - Align size set to word (when used in DC2)/Governor memory mapped access (when used in DC3)
  // Bit 7 - NEON
  // Bit 6 - Priv
  // Bit 5 - Store (or PLDW if set with bit[2])
  // Bit 4 - Exclusive
  // Bit 3 - PLDL2
  // Bit 2 - PLD
  // Bit 1 - 2nd Cross 64
  // Bit 0 - Cross 64

  // Convert all DMBs into DSBs if the disable_dmb chicken bit is set, except
  // the DMB for an STLR (this remains a DMB in the DCU but does not activate
  // the barrier optimisations in the STB when the chicken bit is set).
  assign barrier_iss   = `CA53_CPOP_IS_BAR(dpu_cp_op_iss_i); // Barrier space
  assign force_dsb_iss = barrier_iss & ~dpu_ldar_stlr_iss_i & dpu_disable_dmb_i;

  assign next_cp_op_dc1 = dpu_valid_cp_iss_i ? ({dpu_cp_op_iss_i[8:5],
                                                 (force_dsb_iss ? 3'b101 : dpu_cp_op_iss_i[4:2]),  // Convert DMB to DSB if appropriate
                                                 dpu_cp_op_iss_i[1:0]})
                                             : {(dpu_align_size_iss_i == `CA53_ALIGN_32BIT),
                                                dpu_neon_access_iss_i,
                                                dpu_priv_iss_i,
                                                dpu_store_iss_i,
                                                dpu_excl_iss_i,
                                                (dpu_pld_iss_i & dpu_pld_level_iss_i),
                                                dpu_pld_iss_i,
                                                dpu_second_x64_iss_i,
                                                dpu_cross_64_iss_i};

  // PLDW should behave as a load
  assign next_load_dc1 = (~dpu_store_iss_i | dpu_pld_iss_i) & ~dpu_valid_cp_iss_i;

  // DCIMVA should behave as a store for permission checking, other DC/IC cache
  // maintenance operations should behave as loads
  assign next_raw_store_dc1 = (dpu_valid_cp_iss_i &
                               (`CA53_CPOP_IS_ICM(dpu_cp_op_iss_i) |
                                `CA53_CPOP_IS_DCM(dpu_cp_op_iss_i)))  ? (dpu_cp_op_iss_i == `CA53_CPOP_DCIMVAC) : dpu_store_iss_i;

  // Only update the main DC1 pipeline registers when there is a valid request from
  // the DPU in Iss, and the DCU is not stalled in DC1 or waiting for the TLB.
  // If the DPU is flushing the current transaction but there is another valid
  // one in issue, then also enable registers.
  // Note that this may result in the DC1 registers being enabled when
  // a transaction is not advancing from iss, as the DCU may be stalling iss
  // independently of DC1 advancing, however this will be rare so that in most
  // situations the registers will only be enabled when a new transaction is
  // entering DC1.
  assign enable_dc1 = v_enable_dc1 & (dpu_valid_iss_i | dpu_valid_cp_iss_i);

  // Update DC1 pipeline registers
  always @(posedge clk)
    if (enable_dc1) begin
      cp_inst_dc1         <= dpu_valid_cp_iss_i;
      size_dc1            <= dpu_size_iss_i;
      length_dc1          <= dpu_length_iss_i;
      load_dc1            <= next_load_dc1;
      strobe_dc1          <= dpu_strobe_iss_i;
      first_dc1           <= dpu_first_iss_i;
      align_size_dc1      <= dpu_align_size_iss_i;
      req_align_dc1       <= dpu_req_align_iss_i;
      cp_op_dc1           <= next_cp_op_dc1;
      non_temporal_dc1    <= dpu_non_temporal_iss_i;
      ldar_stlr_dc1       <= dpu_ldar_stlr_iss_i;
      raw_store_dc1       <= next_raw_store_dc1;
      priv_perm_check_dc1 <= dpu_priv_iss_i;
      transl_type_dc1     <= transl_type_iss;
      icache_on           <= dpu_icache_on_i;
    end


  //---------------------------------------------------------------------------
  // DC1
  //---------------------------------------------------------------------------
  // DC1 performs the following functions:
  // - Get uTLB lookup result from DPU (if required)
  // - Indicate to TLB when address translation required, in case of uTLB
  //   miss
  // - Cache arbiter request on loads (corresponds to M1 in cache arbiter
  //   pipeline)
  // - Fault calculation

  // Generic enable term used to clock gate various DC1 registers too small
  // to justify their own clock gate.
  assign reg_en_dc1 = dpu_flush_i | enable_dc1 | valid_dc1;


  //--------------------
  // Instruction decode
  //--------------------

  // CP op types
  // - Unqualified (need to be qualified with cp_inst_dc1 where used)
  assign cp_is_ifu_maint_dc1  = `CA53_CPOP_IS_ICM(cp_op_dc1);
  assign cp_is_bp_maint_dc1   = `CA53_CPOP_IS_BPM(cp_op_dc1);
  assign cp_is_tlb_maint_dc1  = `CA53_CPOP_IS_TLBM(cp_op_dc1);
  assign cp_is_dc_maint_dc1   = `CA53_CPOP_IS_DCM(cp_op_dc1);
  assign cp_is_v2p_dc1        = `CA53_CPOP_IS_V2P(cp_op_dc1);
  assign cp_is_maint_mva_dc1  = `CA53_CPOP_IS_DCM_MVA(cp_op_dc1) | // DCIMVAC, DCCMVAC, DCCMVAU, DCCIMVAC
                                `CA53_CPOP_IS_ICM_MVA(cp_op_dc1);  // ICIMVAU
  assign cp_is_reg_dc1        = `CA53_CPOP_IS_REG(cp_op_dc1);
  assign cp_is_mva_dc1        = cp_is_maint_mva_dc1 | cp_is_v2p_dc1;

  // - Qualified with cp_inst_dc1
  assign cp_write_dc1       = cp_inst_dc1 & ((raw_store_dc1 & cp_is_reg_dc1) | cp_is_v2p_dc1);
  assign cp_read_dc1        = cp_inst_dc1 & ~raw_store_dc1 & cp_is_reg_dc1;
  assign dccmvau_dc1        = cp_inst_dc1 & cp_is_dc_maint_dc1 & ~cp_op_dc1[3];
  assign dc_inv_mva_dc1     = cp_inst_dc1 & cp_is_dc_maint_dc1 & cp_op_dc1[2] & cp_op_dc1[0]; // DCIMVAC, DCCIMVAC
  assign cp_dc_maint_op_dc1 = cp_inst_dc1 & cp_is_dc_maint_dc1;
  assign clrex_dc1          = cp_inst_dc1 & `CA53_CPOP_IS_CLREX_NOP(cp_op_dc1);  // CLREX/NOP space (can't have NOP in DC1)
  assign cp_ifu_maint_dc1   = cp_inst_dc1 & cp_is_ifu_maint_dc1;
  assign cp_v2p_dc1         = cp_inst_dc1 & cp_is_v2p_dc1;

  // - Barriers
  assign dxb_dc1    = cp_inst_dc1 & `CA53_CPOP_IS_BAR(cp_op_dc1) & ~`CA53_CPOP_IS_DMBLD(cp_op_dc1); // Barrier space
  assign dsb_dc1    = cp_inst_dc1 & `CA53_CPOP_IS_DSB(cp_op_dc1);
  assign dmb_dc1    = cp_inst_dc1 & `CA53_CPOP_IS_DMB(cp_op_dc1) & ~`CA53_CPOP_IS_DMBLD(cp_op_dc1);
  assign dmbld_dc1  = cp_inst_dc1 & `CA53_CPOP_IS_DMBLD(cp_op_dc1); // DMB Load-Load/Store only
  assign dmbst_dc1  = dxb_dc1 & ~cp_op_dc1[2];  // For barriers, bit[2] is Full/nST - as there is no DSBST, can just decode DxBST

  // Properties encoded on cp_op bus
  assign store_dc1      = ~cp_inst_dc1 & cp_op_dc1[BIT_STORE] & ~cp_op_dc1[BIT_PLD];
  assign pld_dc1        = ~cp_inst_dc1 & cp_op_dc1[BIT_PLD];
  assign excl_dc1       = ~cp_inst_dc1 & cp_op_dc1[BIT_EXCL];
  assign cross_64_dc1   = ~cp_inst_dc1 & cp_op_dc1[BIT_CROSS_64];
  assign second_x64_dc1 = ~cp_inst_dc1 & cp_op_dc1[BIT_2ND_X64];

  // DCZVA instruction
  // - indicated by DPU setting align_size to a special encoding
  assign dczva_dc1 = (align_size_dc1 == `CA53_ALIGN_DCZVA);

  // Memory attributes
  assign raw_mem_attrs_dc1 = dpu_attributes_dc1_i[12:5];

  // For V2P instructions the exception level should be the one that the
  // translation stage will be. All other operations should use the current
  // exception level.
  assign s2_exc_level_el0_el1 = cp_v2p_dc1 ? ((transl_type_dc1 == `CA53_TRANSL_V2P_S12_EL0) |
                                              (transl_type_dc1 == `CA53_TRANSL_V2P_S12_EL1))
                                           : ~dpu_exception_level_i[1];

  assign s1_exc_level = cp_v2p_dc1 ? (({2{transl_type_dc1[2:1] == 2'b11}}  & transl_type_dc1[1:0]) |
                                      ({2{transl_type_dc1[2:0] == 3'b011}} & {~dpu_ns_state_i & ~dpu_aarch64_at_el_i[3], 1'b1}))
                                   : dpu_exception_level_i[1:0];

  // Determine nS state to use for V2P translation
  always @*
    case ({dpu_aarch64_state_i, cp_op_dc1})
      {1'b0, `CA53_CPOP_ATS1C}    : v2p_ns_state_dc1 = dpu_ns_state_i;
      // AA32 ATS12NSO always uses non-secure
      {1'b0, `CA53_CPOP_ATS12NSO} : v2p_ns_state_dc1 = 1'b1;
      {1'b0, `CA53_CPOP_ATS1H}    : v2p_ns_state_dc1 = 1'b1;
      // AA64 *E01 at EL3 uses SCR.nS to determine whether to do secure or non-secure translation
      {1'b1, `CA53_CPOP_ATS1E01}  : v2p_ns_state_dc1 = dpu_ns_state_i | ((dpu_exception_level_i == `CA53_EL3) & dpu_scr_el3_ns_i);
      {1'b1, `CA53_CPOP_ATS12E01} : v2p_ns_state_dc1 = dpu_ns_state_i | ((dpu_exception_level_i == `CA53_EL3) & dpu_scr_el3_ns_i);
      {1'b1, `CA53_CPOP_ATS1E2}   : v2p_ns_state_dc1 = 1'b1;
      {1'b1, `CA53_CPOP_ATS1E3}   : v2p_ns_state_dc1 = dpu_ns_state_i;  // Will always be 0 (can only execute at EL3)
      default                     : v2p_ns_state_dc1 = 1'bx;
    endcase

  assign transl_ns_state_dc1 = (cp_v2p_dc1 & v2p_ns_state_dc1) | dpu_ns_state_i;

  // Select mmu_on and dcache_on according to the exception level used for the
  // translation (usually the current exception level, but can be different on
  // V2P ops)
  assign mmu_on_dc1    =  (s1_exc_level == `CA53_EL3)                      ? dpu_mmu_on_el3_i :
                          (s1_exc_level == `CA53_EL2)                      ? dpu_mmu_on_el2_i :
                          (s1_exc_level == `CA53_EL1)                      ? dpu_mmu_on_el1_i :
                          (~transl_ns_state_dc1 & ~dpu_aarch64_at_el_i[3]) ? dpu_mmu_on_el3_i
                                                                           : dpu_mmu_on_el1_i;

  assign dcache_on_dc1 = ((s1_exc_level == `CA53_EL3)                      ? dpu_dcache_on_el3_i :
                          (s1_exc_level == `CA53_EL2)                      ? dpu_dcache_on_el2_i :
                          (s1_exc_level == `CA53_EL1)                      ? dpu_dcache_on_el1_i :
                          (~transl_ns_state_dc1 & ~dpu_aarch64_at_el_i[3]) ? dpu_dcache_on_el3_i
                                                                           : dpu_dcache_on_el1_i) |
                         // HCR.DC bit effectively forces SCTLR.C bit in nS EL0-1
                         (dpu_default_cacheable_i & transl_ns_state_dc1 & ~s1_exc_level[1]);

  // Convert memory marked as cacheable to be non-cacheable when the cache is off or
  // in nS EL0-1 and stage 2 data cache disable is set (HCR.CD) and HCR.VM or
  // HCR.DC is set.
  assign cache_off_dc1 = cp_ifu_maint_dc1 ? ~icache_on  // Qualified by DPU
                                          : (~dcache_on_dc1 | (~dpu_s2_dcache_on_i & s2_exc_level_el0_el1 & transl_ns_state_dc1));

  assign force_nc_dc1  = `CA53_MEM_NORMAL(raw_mem_attrs_dc1) & cache_off_dc1;

  // - Convert memory marked as non-transient to be transient on non-temporal loads
  assign force_transient_dc1 = `CA53_MEM_COHERENT(raw_mem_attrs_dc1) & non_temporal_dc1;

  // - Clear the inner write allocate bit on coherent memory for DCZVA instruction to
  // prevent the STB from performing a linefill just to clear the data
  assign force_no_write_alloc_dc1 = `CA53_MEM_COHERENT(raw_mem_attrs_dc1) & dczva_dc1;

  // Force NC has priority over force_transient/no write alloc.
  assign attrs_dc1 = force_nc_dc1 ? `CA53_MEM_DCACHE_DISABLED :
                                    {raw_mem_attrs_dc1[7],
                                     raw_mem_attrs_dc1[6] | force_transient_dc1,
                                     raw_mem_attrs_dc1[5],
                                     raw_mem_attrs_dc1[4] & ~force_no_write_alloc_dc1,
                                     raw_mem_attrs_dc1[3:0]};

  assign normal_dc1           = `CA53_MEM_NORMAL(raw_mem_attrs_dc1);  // Normal-ness of memory not affected by forcing, so can use raw attrs
  assign cacheable_ntrans_dc1 = `CA53_MEM_COHERENT(attrs_dc1) & ~((`CA53_MEM_TRANSIENT(attrs_dc1) | ~`CA53_MEM_WBRA(attrs_dc1)) &
                                                                  ~(excl_dc1 | pld_dc1 | dpu_disable_no_allocate_i));


  //-------------
  // Stall logic
  //-------------

  // Record when the DCU is in the middle of a main TLB lookup. This is used
  // to qualify the early_stall_dc1 signal, for which the uTLB hit signal is
  // too late but which must be set eventually during a main TLB lookup, to
  // avoid deadlock.
  assign next_tlb_lookup_stall_dc1 = dcu_va_valid_dc1 & ~flush_dc1 &  // A translation is required (va_valid factors in cc_fail)
                                     ~dpu_utlb_hit_dc1_i &            // Set on uTLB miss
                                     ~tlb_d_utlb_enable_i;            // Until uTLB written by TLB

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      tlb_lookup_stall_dc1 <= 1'b0;
    else if (reg_en_dc1)
      tlb_lookup_stall_dc1 <= next_tlb_lookup_stall_dc1;

  // Early version of stall does not include the uTLB miss from the DPU
  assign early_stall_dc1 = valid_dc1 &
                           // Don't stall if DC1 CC failing
                           ~(dpu_ready_cc_fail_wr_i & ~valid_dc2 & ~valid_dc3) &
                             // Stall if waiting for translation result
                           (tlb_lookup_stall_dc1 |
                             // Loads stall in the following circumstances:
                            (load_dc1 &
                             // - When they do not have priority for the
                             // cache arbiter (all loads make a cache lookup
                             // request, even if they are not cacheable).
                             (~dc_load_has_priority_m1_i |
                             // - When the pipeline is full (even if DC3 is CC
                             // failing, to save factoring cc_fail into the
                             // critical dc_load_req_m1)
                              pipe_full_stall_dc1 |
                             // - When loads are blocked
                              block_loads_dc1)) |
                             // Stall on DC2:
                            (valid_dc2 &
                             // DC2 is CP15 stalled on DVM
                             ((dcu_needs_dvm_intf_dc2 & dvm_in_progress_i) |
                             // DC2 is exclusive
                              (first_dc1 & (excl_dc2 | clrex_dc2)) |
                             // DC1 is CP read and DC2 is CP write/debug op,
                             // to avoid RAW hazard in TLB registers.
                              (cp_read_dc1 & (cp_write_dc2 | cp_dc_ic_debug_op_dc2)) |
                             // Do not stall if DC2/3 CC failing
                              (~dpu_ready_cc_fail_wr_i &
                               ( // DC2 can stall on DC3 if:
                                valid_dc3 &
                                 // - RAW Hazard
                                (raw_hazard_dc2 |
                                 // - Attribute mismatch
                                 (first_dc2 & dcu_load_dc2 & attr_mismatch_dc3) |
                                 // - DC3 stalled
                                 ~(dpu_ready_wr_i & dcu_valid_dc3)))))) |
                             // Stall on DC3:
                            (valid_dc3 &
                             // DC3 is exclusive
                             ((first_dc1 & (excl_dc3 | clrex_dc3)) |
                             // DC1 is CP read and DC3 is CP write/debug op,
                             // to avoid RAW hazard in TLB registers.
                             (cp_read_dc1 & (cp_write_dc3 | cp_dc_ic_debug_op_dc3)))));

  // Wait for uTLB on transactions that require a VA translation
  assign waiting_for_utlb_dc1 = dcu_va_valid_dc1 & ~dpu_utlb_hit_dc1_i;

  // Stalling or waiting for TLB due to a uTLB miss
  assign stall_dc1 = early_stall_dc1 | waiting_for_utlb_dc1;


  //----------------------
  // Address translations
  //----------------------

  // Translation request for main TLB (TLB interprets this as a lookup request
  // if dpu_utlb_hit_dc1 is deasserted).
  // Asserted if there is a valid transaction in DC1 that requires an address
  // translation.

  // - Early version does not factor in cc_fail and is calculated a cycle in
  // advance to improve timing into TLB.
  assign next_dcu_va_valid_early_dc1 = v_enable_dc1 ? (next_valid_dc1 & dpu_valid_iss_i)
                                                    : (valid_dc1      & dcu_va_valid_early_dc1);

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      dcu_va_valid_early_dc1 <= 1'b0;
    else
      dcu_va_valid_early_dc1 <= next_dcu_va_valid_early_dc1;

  // - Full version factors in cc_fail, so TLB can spot when an instruction no
  // longer needs a translation, and so can detect a new request (va_valid_early
  // will not be deasserted between two instructions if the first cc fails).
  assign dcu_va_valid_dc1 = dcu_va_valid_early_dc1 & ~cc_fail_dc1;

  assign dcu_transl_type_dc1 = {3{cp_v2p_dc1}} & transl_type_dc1; // Mask to 3'b000 (CA53_TRANSL_NORMAL) on non-V2P

  // Ongoing burst signal for TLB
  // - set on the first transaction of a burst, cleared on last transaction or if CC fail.
  assign next_ongoing_burst_dc1 = (next_valid_dc1 & ~waiting_for_utlb_dc1) 
                                    ? dpu_burst_iss_i                                     // Set when new burst entering DC1
                                    : (dcu_ongoing_burst_dc1 & ~clear_ongoing_burst_dc1); // Maintain once set until either replaced
                                                                                          // by non-burst instruction, or flushed.

  assign clear_ongoing_burst_dc1 = flush_dc1 | 
                                   // Transaction which set ongoing burst is cc failing:
                                    cc_fail_dc1                                       | 
                                   (cc_fail_dc2            &  ~valid_dc1            ) | 
                                   (dpu_ready_cc_fail_wr_i & ~(valid_dc1 | valid_dc2));

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      dcu_ongoing_burst_dc1 <= 1'b0;
    else
      dcu_ongoing_burst_dc1 <= next_ongoing_burst_dc1;

  assign dcu_va_valid_early_dc1_o = dcu_va_valid_early_dc1;
  assign dcu_va_valid_dc1_o       = dcu_va_valid_dc1;
  assign dcu_transl_type_dc1_o    = dcu_transl_type_dc1;
  assign dcu_ongoing_burst_dc1_o  = dcu_ongoing_burst_dc1;


  //----------------
  // Fault checking
  //----------------
  // Faults are always encoded internally in LPAE format, even in VMSA mode.
  // This is converted to VMSA format in DC3 (for PAR writes) or by the DPU
  // (for DFSR writes), if VMSA format is required.
  //
  // More than one fault type can be indicated/detected for a single
  // instruction, and for loads/stores are prioritised as follows:
  //
  // 1.  Stack alignment faults indicated by DPU
  // 2.  Alignment faults caused by requested alignment checking
  // 3.  Out of range VA faults
  // 4.  Translation faults affecting S1 of the translation (i.e. S1 or S2 on
  //     S1 walk)
  // 5.  Alignment faults caused by the S1 memory type
  // 6.  Domain faults
  // 7.  S1 permission faults
  // 8.  Translation faults affecting S2 of the translation (i.e. S2 faults)
  // 9.  Alignment faults caused by the S2 memory type (i.e. S2 Device has
  //     overridden S1 memory type)
  // 10. S2 permission faults
  // 11. External aborts (can only happen on loads in DC2/3)
  //
  // The DMB for an STLR is treated as a store for the purposes of fault
  // checking, to ensure that if the DMB succeeds so will the store.
  //
  // DCZVA instructions are generally treated as stores for fault checking,
  // however they always generate unaligned faults when to device memory,
  // regardless of their actual alignment.
  //
  // Other CP ops which do a memory translation can generally only take stack
  // pointer alignment, out of range VA and translation faults (not including
  // domain faults).
  //
  // DCIMVAC instructions do a stage 1 permissions check in AA64, and do a stage
  // 2 permission check in both AA32 and AA64. Other cache maintenance
  // instructions executed at EL0 (only possible in AA64) do both a stage 1 and
  // stage 2 permissions check.
  //
  // V2P operations are a special case and are handled separately.
  //
  // CP ops which do not do a memory translation cannot cause any aborts in
  // DC1.

  // Stack alignment faults
  // - DPU calculates when a misaligned stack pointer is being used and indicates
  // it to the DCU
  // - only valid on transactions which have a valid address
  assign stack_align_fault_taken_dc1 = dpu_stack_align_expt_dc1_i & dcu_va_valid_early_dc1;

  // Alignment faults
  always @*
    case(align_size_dc1)
      `CA53_ALIGN_NONE   : align_mask_dc1 = 5'b11111;
      `CA53_ALIGN_16BIT  : align_mask_dc1 = 5'b11110;
      `CA53_ALIGN_32BIT  : align_mask_dc1 = 5'b11100;
      `CA53_ALIGN_64BIT  : align_mask_dc1 = 5'b11000;
      `CA53_ALIGN_128BIT : align_mask_dc1 = 5'b10000;
      `CA53_ALIGN_256BIT : align_mask_dc1 = 5'b00000;
      default            : align_mask_dc1 = 5'bxxxxx;
    endcase

  // - Alignment faults are only detected on firsts
  // - CP ops other than the barrier for an STLR cannot generate alignment
  // faults
  assign unaligned_dc1 = first_dc1 & (~cp_inst_dc1 | ldar_stlr_dc1) &
                         (((dpu_va_dc1_i[4:0] & align_mask_dc1) != dpu_va_dc1_i[4:0]) |
                          // DCZ instructions are forced to be unaligned, but do not have req_align set,
                          // which means they will always cause unaligned abort to device memory, which
                          // is required by the architecture
                          dczva_dc1);

  // - Alignment faults caused by memory type can only happen when there has
  // been a successful S1 translation, so the memory attributes are valid.
  assign s1_transl_valid_dc1 = ~out_of_range_dc1 &                // S1 valid when VA used for translation is valid
                               (~dpu_abort_dc1_i |                // and no abort from DPU
                                domain_fault_dc1 |                // - or when abort is for Domain fault
                                (dpu_fault_dc1_i[8:7] == 2'b10)); // - or when abort is for S2 translation

  assign align_fault_taken_dc1 = unaligned_dc1 &                          // Take align fault if unaligned and:
                                 ~stack_align_fault_taken_dc1 &           // - no stack alignment fault
                                 (req_align_dc1 |                         // - alignment checking requested
                                  (~normal_dc1 &                          // - or Device memory
                                   s1_transl_valid_dc1 &                  //   and memory attributes valid
                                   ~(`CA53_MEM_DEV_OVERRIDE(attrs_dc1) &  // S2 alignment fault can be masked by:
                                     (perm_fault_s1_dc1 |                 // - S1 permission fault
                                      dpu_abort_dc1_i))));                // - S1/S2 Translation fault/Domain fault

  // - The alignment fault will be reported as S2 if it is caused by the
  // memory type and the memory type was overridden by the S2 translation.
  // Note that for this to happen, the S2 translation must have succeeded, so
  // there cannot have been a translation abort.
  assign align_fault_s2_dc1 = unaligned_dc1 & ~req_align_dc1 &                  // Align fault
                              ~normal_dc1 & `CA53_MEM_DEV_OVERRIDE(attrs_dc1) & // Caused by S2 memory type
                              ~(dpu_abort_dc1_i |                               // Not masked by Translation/Domain fault
                                stack_align_fault_taken_dc1 |                   // - or stack pointer alignment exception
                                out_of_range_dc1 |                              // - or VA fault
                                perm_fault_s1_dc1);                             // - or S1 permission fault

  // Out of range address faults
  // - When the MMU is off then the output address from the first stage of
  //   translation is equal to the input address. This means there can be no out
  //   of range VA fault, but that the address must be checked to be within the
  //   valid physical address address range (40-bits)
  // - When the MMU is on, the output address must be in one of the valid
  //   virtual address ranges:
  //   - When using TTBR0, bits [63:48] of the VA must be zero
  //   - When using TTBR1, bits [63:48] of the VA must be one
  //   - The relevant TCR.TBI bit can force the type byte of the VA to be
  //     ignored
  //
  // Note that since the entries in the uTLB in the DPU are tagged with bits
  // [48:12] of the input address, out of range entries can alias to valid uTLB
  // entries and so must be detected here.
  // - When the MMU is off, if bits [48:40] are not zero, the TLB will return a
  // translation fault, and the uTLB entry will not be marked as valid, so
  // aliases on these bits can be ignored.
  // - In EL2-3 there is no TTBR1, but if bit [48] is set the uTLB will miss, so
  // it is safe to rely on it being correct (this is checked in the DPU/DCU
  // interface).

  always @*
    case (s1_exc_level)
      `CA53_EL0,
      `CA53_EL1: ttbr_tbi = dpu_va_dc1_i[48] ? tlb_d_tcr_el1_tbi_i[1]   // Using TTBR1
                                             : tlb_d_tcr_el1_tbi_i[0];  // Using TTBR0
      `CA53_EL2: ttbr_tbi = tlb_d_tcr_el2_tbi0_i;
      `CA53_EL3: ttbr_tbi = tlb_d_tcr_el3_tbi0_i;
      default  : ttbr_tbi = 1'bx;
    endcase

  assign out_of_range_dc1 = dpu_va_dc1_i[48] ? ((~&dpu_va_dc1_i[55:49]) | (~ttbr_tbi & (~&dpu_va_dc1_i[63:56])))  // Using TTBR1
                                             : (( |dpu_va_dc1_i[55:49]) | (~ttbr_tbi & ( |dpu_va_dc1_i[63:56]))); // Using TTBR0

  // - only valid on transactions which have a valid address
  assign va_fault_taken_dc1 = out_of_range_dc1 &
                              dcu_va_valid_early_dc1 &
                              ~stack_align_fault_taken_dc1 &
                              ~(unaligned_dc1 & req_align_dc1);

  // Translation/Domain faults (i.e. faults indicated by DPU)
  assign dpu_fault_type_dc1 = dpu_fault_dc1_i[6:0];

  assign domain_fault_dc1 = `CA53_FAULT_DOMAIN(dpu_fault_type_dc1);

  // - Note any translation fault indicated by the DPU when there is an out
  // of range VA fault must itself be an out of range VA fault, as the
  // uTLB must have missed (only domain faults can happen on a hit, which are
  // only possible in VMSA mode and so cannot happen at the same time as an
  // out of range VA), and the TLB will always return an out of range fault
  // on a translation for an out of range address.
  assign dpu_fault_taken_dc1 = dpu_abort_dc1_i &
                               // - No stack alignment fault
                               ~stack_align_fault_taken_dc1 &
                               // - No alignment fault
                               ~(unaligned_dc1 &
                                 (req_align_dc1 |
                                  (~normal_dc1 & ((domain_fault_dc1 & ~`CA53_MEM_DEV_OVERRIDE(attrs_dc1)) |  // Domain fault has priority over S2 alignment fault
                                                  (dpu_fault_dc1_i[8:7] == 2'b10))))) & // Can't get S2 alignment fault if S2 translation fault,
                                                                                        // as attrs_dc1[4] must be clear in that case
                               // - Ignore domain faults on CP ops other than V2P and STLR DMB
                               ~(domain_fault_dc1 & cp_inst_dc1 & ~(cp_is_v2p_dc1 | ldar_stlr_dc1)) &
                               // - Fault on S1 (domain or translation)
                               ((dpu_fault_dc1_i[8:7] != 2'b10) |
                               // - Or no S1 permission fault
                                ~(perm_fault_s1_dc1 & check_s1_perm_faults_dc1));

  // Permission faults
  // - Check stage 1 permission faults on AA64 DCIVAC instructions and all cache
  // maintenance instructions at EL0
  // - Also V2P, STLR barriers and all non-CP instructions
  assign check_s1_perm_faults_dc1 = ~cp_inst_dc1 | ldar_stlr_dc1 | cp_is_v2p_dc1 |
                                    ((cp_op_dc1 == `CA53_CPOP_DCIMVAC) & dpu_aarch64_state_i) |
                                    (cp_is_maint_mva_dc1 & (dpu_exception_level_i == `CA53_EL0));

  // - Check stage 2 permission faults on all DCIMVAC/DCIVAC (AA32+AA64) and all
  // cache maintenance instructions at EL0
  // - Also V2P, STLR barriers and all non-CP instructions
  assign check_s2_perm_faults_dc1 = ~cp_inst_dc1 | ldar_stlr_dc1 | cp_is_v2p_dc1 |
                                    (cp_op_dc1 == `CA53_CPOP_DCIMVAC) |
                                    (cp_is_maint_mva_dc1 & (dpu_exception_level_i == `CA53_EL0));


  // - S1 permissions are on dpu_attributes[2:0]
  always @*
    case (dpu_attributes_dc1_i[2:0])
      3'b000  : perm_fault_s1_dc1 = 1'b1;                     // No access
      3'b001  : perm_fault_s1_dc1 = ~priv_perm_check_dc1;     // RW Priv, no access User
      3'b010  :                                               // RW Priv, RO User
        case ({raw_store_dc1, priv_perm_check_dc1})
          2'b00, 2'b01, 2'b11   : perm_fault_s1_dc1 = 1'b0;
          2'b10                 : perm_fault_s1_dc1 = 1'b1;
          default               : perm_fault_s1_dc1 = 1'bx;
        endcase
      3'b011  : perm_fault_s1_dc1 = 1'b0;                     // RW Priv, RW User
      3'b100  :                                               // EL2/3 - S1 permissions use S2 space
        case (dpu_attributes_dc1_i[4:3])
          2'b00, 2'b01 : perm_fault_s1_dc1 = 1'b0;            // (RW Priv)
          2'b10, 2'b11 : perm_fault_s1_dc1 = raw_store_dc1;   // (RO Priv)
          default      : perm_fault_s1_dc1 = 1'bx;
        endcase
      3'b101  :                                               // RO Priv, no access User
        case ({raw_store_dc1, priv_perm_check_dc1})
          2'b00, 2'b10, 2'b11   : perm_fault_s1_dc1 = 1'b1;
          2'b01                 : perm_fault_s1_dc1 = 1'b0;
          default               : perm_fault_s1_dc1 = 1'bx;
        endcase
      3'b110,                                                 // RO Priv, RO User
      3'b111  :  perm_fault_s1_dc1 = raw_store_dc1;
      default :  perm_fault_s1_dc1 = 1'bx;
    endcase

  // - S2 permissions are on dpu_attributes[4:3]
  assign perm_fault_s2_dc1 = (dpu_attributes_dc1_i[2:0] != 3'b100) &      // Can't have S2 faults if only have 1 stage of translation
                             ~(raw_store_dc1 ? dpu_attributes_dc1_i[4]    // [4] is writeable bit
                                             : dpu_attributes_dc1_i[3]);  // [3] is readable bit

  assign perm_fault_taken_dc1 = // No stack alignment fault
                                ~stack_align_fault_taken_dc1 &
                                // Not out of range VA
                                ~out_of_range_dc1 &
                                // No S1 alignment fault (note can't get permission
                                // fault if S1 translation not valid, so don't
                                // need to qualify normal_dc1)
                                ~(unaligned_dc1 &
                                  (req_align_dc1 | (~normal_dc1 & ~`CA53_MEM_DEV_OVERRIDE(attrs_dc1)))) &
                                // S1 fault and S1 permissions valid
                                ((perm_fault_s1_dc1 & check_s1_perm_faults_dc1 &
                                  (~dpu_abort_dc1_i | (dpu_fault_dc1_i[8:7] == 2'b10))) |   // NB Domain faults are higher priority than S1 permission
                                // S2 fault and no DPU abort or alignment
                                // fault (note don't need to qualify with
                                // cp_inst because S2 permission fault is
                                // lower priority than lowest priority fault
                                // in CP inst case).
                                 (perm_fault_s2_dc1 &
                                 // - S2 is valid on domain faults, but domain
                                 // is higher priority (but cannot have domain
                                 // fault on cache maintenance op)
                                  (~dpu_abort_dc1_i | (domain_fault_dc1 & cp_inst_dc1 & (cp_is_dc_maint_dc1 | cp_is_ifu_maint_dc1))) &
                                  ~(unaligned_dc1 & ~normal_dc1))); // S1 alignment faults have priority over all permission faults

  // - The level to report for a permission fault comes from dpu_level_dc1.
  // The S1/S2 level is selected based on the stage of the permission fault,
  // and for S1 permission faults in VMSA mode, the SSection encoding needs
  // to be converted to L1.
  assign perm_fault_level_dc1 = (perm_fault_s1_dc1 & check_s1_perm_faults_dc1)
                                  ? {dpu_level_dc1_i[1],                      // S1 has priority over S2
                                     (dpu_lpae_dc1_i ? dpu_level_dc1_i[0]
                                                     : ~dpu_level_dc1_i[1])}  // - Convert SSection to L1
                                  : dpu_level_dc1_i[3:2];                     // S2 level always in LPAE format

  // Form fault encoding to send to DPU
  assign fault_dc1 = ({7{align_fault_taken_dc1}}        & `CA53_FAULT_LPAE_ALIGNMENT)                           |
                     ({7{va_fault_taken_dc1}}           & (mmu_on_dc1 ?  `CA53_FAULT_LPAE_TRANSLATION_L0 :        // Out of range VA
                                                                         `CA53_FAULT_LPAE_ADDR_SIZE_L0))        | // Out of range PA
                     ({7{dpu_fault_taken_dc1}}          & dpu_fault_type_dc1)                                   |
                     ({7{perm_fault_taken_dc1}}         & {`CA53_FAULT_LPAE_PERMISSION, perm_fault_level_dc1})  |
                     ({7{stack_align_fault_taken_dc1}}  & `CA53_FAULT_LPAE_STACK_ALIGN);

  // Set fault stage
  // - defaults to 2'b00 (S1)
  assign fault_stage_dc1 = ({2{align_fault_s2_dc1}}                               & 2'b10) |                // S2 alignment fault
                           ({2{dpu_fault_taken_dc1}}                              & dpu_fault_dc1_i[8:7]) | // DPU reports fault stage for translation/domain
                           ({2{perm_fault_taken_dc1 &
                               ~(check_s1_perm_faults_dc1 & perm_fault_s1_dc1)}}  & 2'b10);                 // S2 permission fault

  // Caculate when there is any kind of abort in DC1 which will trap to the
  // DPU.
  // - Aborts on V2P operations are normally not trapped to the DPU, as they
  // write a faulting entry into the PAR instead, however there are
  // exceptions to this.
  assign abort_dc1 = stack_align_fault_taken_dc1 |                              // Stack alignment
                     (unaligned_dc1 &                                           // Alignment (unaligned factors in cp_inst)
                      (req_align_dc1 | ~normal_dc1)) |                          // - if S1 not valid will generate DPU abort
                     ((dpu_abort_dc1_i | va_fault_taken_dc1) &                  // DPU faults or out of range VA faults trap on:
                      (~cp_inst_dc1 | ldar_stlr_dc1 |                           // - Load/Store
                       (cp_is_mva_dc1 & ~(domain_fault_dc1 & dpu_abort_dc1_i) & // - CP15, unless domain fault
                        (~cp_is_v2p_dc1 | v2p_trap_dc1)))) |                    // - Unless being masked by V2P
                     ((perm_fault_s1_dc1 & check_s1_perm_faults_dc1 & ~cp_v2p_dc1) |
                      (perm_fault_s2_dc1 & check_s2_perm_faults_dc1 & ~cp_v2p_dc1));

  // Special cases for V2P instructions

  // - Calculate format (VMSA/LPAE) to use for the PAR on V2P instructions. This
  // needs to be done in DC1, as the format depends on the mode used for the
  // translation, which is only available in DC1.
  // - This signal is also sent to the DPU in DC3 so it can determine the
  // format to use for the DFSR when V2Ps trap. In this case it should be the
  // same as dpu_lpae_dc1. Note this does not need to be valid for a S2 fault on
  // an S1 pagewalk, as the fault stage overrides the translation mode in
  // determining the DFSR format in this case.

  // Should use LPAE format if:
  // - doing an LPAE translation
  // - doing a VMSA translation but in LPAE mode
  // - doing a VA -> PA translation and might get a 40-bit PA (i.e. HCR.VM set)
  // - have got a stage 2 fault (in general can only get S2 faults when HCR.VM
  //   is set, but as this can be cached in the TLB could still get an S2 fault
  //   with HCR.VM=0)
  // Note for the same reason, could get a 40-bit PA with HCR.VM=0, but as that
  // can't be detected VMSA format is still used, and the upper bits of the PA
  // are truncated.
  assign v2p_lpae_dc1 = cp_inst_dc1 & cp_is_v2p_dc1 &
                        (dpu_lpae_dc1_i |
                         dpu_aarch64_state_i |
                         fault_stage_dc1[1] |
                         ((cp_op_dc1[1:0] == 2'b01) & (dpu_ipa_to_pa_en_i | dpu_default_cacheable_i)) | // ATS12NSO
                         ((cp_op_dc1[1:0] == 2'b00) & (dpu_exception_level_i == 2'b10)));               // ATS1C

  // - Calculate when a V2P operation should trap an abort to the DPU rather
  // than writing a faulting entry into the PAR.
  assign v2p_trap_dc1 = dpu_abort_dc1_i &
                        // Trap when there is an external abort on a pagewalk
                        ((`CA53_FAULT_PAGEWALK_EXT(dpu_fault_type_dc1) &
                          ((dpu_fault_dc1_i[8:7] != 2'b10) |            // S1 faults always trap
                           ~perm_fault_s1_dc1)) |                       // S2 faults can be masked by S1 permission fault (which won't trap)
                         // Or when there is an S2 fault on an S1 pagewalk for an ATS1C in nS EL1
                         ((cp_op_dc1[1:0] == 2'b00) &                   // ATS1C
                          dpu_ns_state_i & ~dpu_exception_level_i[1] &  // nS EL1
                          (dpu_fault_dc1_i[8:7] == 2'b11)));            // Second stage fault on first stage walk

  // - Record when there has been any abort in DC1, and so a faulting entry
  // should be written into the PAR. Note this is different from abort_dc1,
  // which records when an abort should be trapped to the DPU.
  assign v2p_abort_dc1 = cp_inst_dc1 & cp_is_v2p_dc1 & (dpu_abort_dc1_i    |
                                                        va_fault_taken_dc1 |
                                                        perm_fault_s1_dc1  |
                                                        perm_fault_s2_dc1);


  //--------
  // Length
  //--------
  // Calculate the length for a burst (number of words in burst - 1). Normally
  // this will be the same as the length indicated by the DPU, but needs to
  // be changed in the following circumstances:
  // - When a transaction is cross 64, it may need to access more words than
  // the DPU indicates (the DPU length assumes the transaction is aligned).
  // In this case, on a load the length needs to be incremented to ensure
  // that the BIU fetches enough beats to satisfy the full burst. On stores
  // this does not matter, because the STB does not care about how many beats
  // there are in a burst.
  // - When the burst length will cause a cache line to be crossed. In such
  // cases the DCU treats the burst as two separate instructions, the first
  // with enough beats to go up to the cache line boundary. The DPU asserts
  // dpu_first automatically on the first beat of the burst in the new cache
  // line, so the DCU just has to adjust the length on the first part.
  assign true_length_dc1 = (load_dc1 & cross_64_dc1 & ~second_x64_dc1 & (dpu_va_dc1_i[2:0] != 3'b100)) ? (length_dc1 + 5'b00001)
                                                                                                       : length_dc1;

  // Calculate the number of words left in the cache line after the current
  // address (the cache line contains 64B/4 = 16 words).
  assign cache_words_remaining_dc1 = 4'b1111 - dpu_va_dc1_i[5:2];

  // - Don't change the length on a DCZVA as will always be cache-line aligned,
  // but DPU does not force alignment on first beat, so calculation can be
  // incorrect.
  assign final_length_dc1 = ((true_length_dc1 > {1'b0, cache_words_remaining_dc1}) & ~dczva_dc1)
                              ? cache_words_remaining_dc1
                              : true_length_dc1[3:0];


  //------------------------
  // Cache arbiter requests
  //------------------------
  // Always make request whether cacheable or not, and assuming uTLB will
  // hit, but not if stalling for a reason which can be detected early.
  // RAW hazard in DC2 won't stop cache load request because otherwise it
  // would be a critical path.

  // For most cases, the calculation of whether to to suppress the load request
  // can be done a cycle in advance, so the load request is as early as possible
  // in the next cycle.
  assign next_load_req_dc1 = (v_enable_dc1 ? (next_valid_dc1 & next_load_dc1) : (valid_dc1 & load_dc1)) &
                             ~(mbist_en_i               |
                               dc_inv_all_in_progress_i |
                               next_block_loads_dc1     |
                               next_tlb_lookup_stall_dc1);

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      load_req_dc1 <= 1'b0;
    else
      load_req_dc1 <= next_load_req_dc1;

  // Suppress the load request if DC1 is stalling because the pipeline is full
  // and the transaction in DC3 has not been completed (this is required to
  // prevent deadlock in situations where DC3 relies on the cache arbiter being
  // free - e.g. when a store is waiting for a slot in the STB, and the STB
  // needs to access the cache to free up a slot).
  // - To improve timing this is registered
  assign next_pipe_full_stall_dc1 = (v_enable_dc2 ? next_valid_dc2 : valid_dc2) &
                                    (v_enable_dc3 ? next_valid_dc3 : valid_dc3) &
                                    ~next_dcu_valid_dc3;

  always @(posedge clk)
    pipe_full_stall_dc1 <= next_pipe_full_stall_dc1;

  // Make M1 request either for full load requqest or speculative DC1 linefill
  assign dc_load_req_m1_o        = lf_state_dc1[2] | (~pipe_full_stall_dc1 & load_req_dc1);  // lf_state_dc1[2] => LF_M1
  assign dc_load_addr_m1_o       = {dpu_pa_dc1_i, dpu_va_dc1_i[11:3]};
  assign dc_load_tag_ns_dsc_m1_o = dpu_ns_dsc_dc1_i;
  assign dc_load_bls_m1_o        = strobe_dc1[15:8] | strobe_dc1[7:0];

  // Indicate to the cache arbiter when the request is for a valid load which is
  // not stalled, and therefore will not be dropped.
  assign dc_valid_load_req_m1_o = load_req_dc1 &
                                  ~stall_dc1 & ~cc_fail_or_flush_dc1 &  // Load will be in DC2 on next cycle
                                  ~dpu_abort_dc1_i;                     // PA in DC1 is valid

  // The load way tracking logic must be reset when there is a uTLB miss (as
  // the subsequent uTLB write could affect the state of a tracked uTLB
  // entry). Note that uTLB aborts do not need factoring in, as the uTLB
  // can only hit and generate an abort on domain faults, which do not
  // affect the translation.
  assign dc_force_non_seq_o = valid_dc1 & ~dpu_utlb_hit_dc1_i;

  // Indicate when the request is for a first in DC1, which the cache arbiter
  // can use to predict when a request will hit in the cache way tracker, and so
  // improve the arbitration.
  assign dc_load_first_m1_o = first_dc1;

  // A load which is flushed or gets an abort will not allocate a cache way
  // tracker entry, so any subsequent beats of the instruction which are not
  // marked as first by the DPU must be forced to be first in the cache
  // arbiter to prevent arbitration problems.
  assign dc_force_first_o = valid_dc1 & (cc_fail_or_flush_dc1 | dpu_abort_dc1_i);


  //---------------
  // DC1 Linefills
  //---------------
  // DC1 linefill requests are controlled by a state machine which tracks a
  // cache lookup while the transaction in DC1 is stalled. The lookup request
  // makes a tag request once a load is stalled in DC1 because the pipeline is
  // full and stalling. The request is considered a low priority by the BIU, and
  // there is no handshake signal back to say that it has been accepted.
  // Instead, the DCU checks for writes by the BIU (or STB, as when a full
  // linefill chunk has been merged into by the STB, the STB does the tag write
  // rather than the BIU) to the data RAM for a cache line with the same index
  // as the load request (note the way cannot be checked as the BIU can use a
  // different victim way than the one indicated by the DCU, but false index
  // matches are expected to be sufficiently rare as to not affect performance).
  // This covers both a linefill started by the DC1 linefill request writing in
  // the cache, and a linefill which happened to be ongoing to the same address
  // anyway (such as one started by the STB). Once such a write is detected, or
  // if the lookup hits, the DCU does not make any DC1 linefill request.

  always @* begin
    if (~pipe_full_stall_dc1 | cc_fail_or_flush_dc1) begin
      // When not stalling in DC1 (or when stalling but not because pipeline
      // full), return to idle for next instruction.
      next_lf_state_dc1 = LF_IDLE;
    end else begin
      case (lf_state_dc1)
        LF_IDLE:
          // Start when loads not blocked, uTLB has hit (so PA valid), address
          // is cacheable and there is no abort (otherwise shouldn't start
          // linefill) and loads aren't been throttled (to maintain QoS in cache
          // arbiter).
          next_lf_state_dc1 = (load_req_dc1 & dpu_utlb_hit_dc1_i &
                               cacheable_ntrans_dc1 & ~abort_dc1 &
                               ~throttle_loads_dc1 & ~stb_block_loads_dc1_i) ? LF_M1 : LF_IDLE;
        LF_M1  :
          // If throttled while waiting for priority, go back to idle and start
          // again.
          next_lf_state_dc1 = dc_load_has_priority_m1_i                    ? LF_M2   :
                              (throttle_loads_dc1 | stb_block_loads_dc1_i) ? LF_IDLE :
                                                                             LF_M1;
        LF_M2  :
          // Could have an alloc/STB write granted in M1 while lookup in M2, so
          // treat that as hit.
          // - Need to use raw_hit as final hit is qualified with
          // ~biu_suppress_dc2, which is not valid for DC1 address.
          next_lf_state_dc1 = (dc_load_raw_hit_m2_i | dc_load_index_match_m1_i | dc_ecc_tag_err_m2_i) ? LF_HIT : LF_REQ;
        LF_REQ :
          // If cache arbiter indicates matching alloc/STB write while making
          // linefill request, go to hit state to suppress request.
          next_lf_state_dc1 = dc_load_index_match_m1_i ? LF_HIT : LF_REQ;
        LF_HIT :
          // Remain in hit state until next transaction (which will force state
          // machine to idle).
          next_lf_state_dc1 = LF_HIT;
        default:
          next_lf_state_dc1 = LF_X;
      endcase
    end
  end

  // Note state does not need to be reset as forced to IDLE on instruction
  // entering DC1
  always @(posedge clk)
    lf_state_dc1 <= next_lf_state_dc1;

  // Register the victim way to use for the linefill when the lookup is in M2
  assign next_dcu_lf_way_dc1 = (lf_state_dc1 == LF_M2) ? dc_load_victim_way_m2_i
                                                       : dcu_lf_way_dc1;

  always @(posedge clk)
    dcu_lf_way_dc1 <= next_dcu_lf_way_dc1;

  // Indicate to cache arbiter when load request is for
  assign dc_load_tag_req_only_m1_o  = pipe_full_stall_dc1 & lf_state_dc1[2]; // lf_state_dc1 == LF_M1;

  // Linefill request interface to BIU
  assign dcu_lf_req_dc1_o = valid_dc1 & (lf_state_dc1 == LF_REQ); // Stop making request if no longer in DC1
  assign dcu_lf_way_dc1_o = dcu_lf_way_dc1;
  assign dcu_attrs_dc1_o  = attrs_dc1;


  //-------------------------
  // Outputs to other blocks
  //-------------------------

  // There is a valid store, barrier, or CP15 in DC1. The STB can use this
  // to decide how many slots to start to drain. This is only a hint to the
  // STB, and is optimistic in that it can be asserted for operations which
  // may ultimately not be broadcast.
  // This signal is also used by the TLB to detect whether the access in DC1
  // is a load or store, for watchpoint masking.
  assign dcu_store_dc1_o  = valid_dc1 & (store_dc1 |
                                         (cp_inst_dc1 & (dxb_dc1             |
                                                         cp_is_tlb_maint_dc1 |
                                                         cp_is_bp_maint_dc1  |
                                                         cp_is_ifu_maint_dc1 |
                                                         cp_is_dc_maint_dc1)));

  // Tell the TLB that there is a privileged access in DC1. Used by the TLB
  // for calculating watchpoints.
  assign dcu_priv_dc1_o = valid_dc1 & priv_perm_check_dc1;

  // Tell TLB to check for watchpoints accross a whole cache line (512-bits) on
  // DCZVA and DCIMVAC operations (i.e. all cache maintenance instructions which
  // can cause watchpoints).
  assign dcu_wpt_check_512_dc1_o = valid_dc1 & (cp_inst_dc1 | dczva_dc1); // DCU will ignore wpt_hit on CP ops other than DCIMVAC

  // Indicate details of the load in DC1 to the BIU
  assign dcu_load_dc1_o     = valid_dc1 & load_dc1;
  assign dcu_leaving_dc1_o  = valid_dc1 & ~stall_dc1;


  //---------------------------------------------------------------------------
  // DC1 -> DC2
  //---------------------------------------------------------------------------

  //------------
  // Valid flag
  //------------
  // Update valid in DC2 whenever not stalling or if clearing valid on a flush

  assign v_enable_dc2   = ~stall_dc2 | cc_fail_or_flush_dc2;
  assign next_valid_dc2 = valid_dc1 & ~cc_fail_or_flush_dc1 & ~stall_dc1;

  always @(posedge clk_dc2 or negedge reset_n)
   if (!reset_n)
     valid_dc2 <= 1'b0;
   else if (v_enable_dc2)
     valid_dc2 <= next_valid_dc2;


  //-------------
  // New signals
  //-------------
  // The following signals are not pipelined straight from DC1, but are
  // either created in DC1 solely for use in subsequent stages, or modified
  // between DC1 and DC2.

  // Clear the domain if there is no TLB fault. While the DFSR may contain an
  // UNKNOWN value on permission or align faults, it should not contain the last
  // domain value, which may have been from secure state.
  assign next_domain_dc2 = dpu_domain_dc1_i & {4{dpu_fault_taken_dc1}};

  // The following DCache maintenance operations are converted to different
  // operations in certain situations:
  // - DC invalidate by MVA/VA are converted to clean+invalidate by HCR.VM (this
  //   is only valid in nS EL0-1)
  // - DCCMVAU instructions (encoding 7'b1100011) are converted to NOPs
  //   (encoding 7'b1000011) when BROADCASTINNER is not set, as the operations
  //   have no effect in that case.
  // PLDs are converted to PLDL2 if they are to transient memory
  assign next_cp_op_dc2 = {cp_op_dc1[8:5],
                           (cp_op_dc1[4] & ~(dccmvau_dc1 & ~scu_broadcastinner_i)),       // DCCMVAU -> NOP
                           (cp_op_dc1[3] | (pld_dc1 & `CA53_MEM_TRANSIENT(attrs_dc1))),   // PLD -> PLDL2
                           cp_op_dc1[2],
                           (cp_op_dc1[1] | (dc_inv_mva_dc1 &                              // DCIMVAC -> DCCIMVAC if:
                                            (dpu_ipa_to_pa_en_i |                         // HCR.VM is set
                                             dpu_default_cacheable_i) &                   // (or treated as set because of HCR.DC)
                                            ~dpu_exception_level_i[1] & dpu_ns_state_i)), // - and applies
                           cp_op_dc1[0]};

  // Mask watchpoint hit from TLB with byte strobes for this access
  // Don't cause a watchpoint for PLD, PLDW, DxB or CP15 maintenance ops except
  // DCZVA and DCIMVAC.
  assign watchpoint_dc1 = |(tlb_wpt_hit_dc1_i & strobe_dc1) & ~pld_dc1 & (~cp_inst_dc1 | (cp_op_dc1 == `CA53_CPOP_DCIMVAC));

  // Determine whether the region is a supersection to pass down the pipeline as it
  // is needed when writing the PAR in DC3. Supersections are only valid in
  // VMSA mode, but the supersection encoding is not used in LPAE mode, so
  // the signal does not need qualifying with the mode.
  assign supersection_dc1 = (dpu_level_dc1_i[1:0] == `CA53_VMSA_PAGE_SIZE_SSECTION);

  // Align VA on DCZVA unless there is an abort, in which case need to return
  // raw address to DPU
  assign next_va_dc2 = {dpu_va_dc1_i[63:6],
                        (dpu_va_dc1_i[5:0] & {6{~(dczva_dc1 & first_dc1 & ~(abort_dc1 | (|tlb_wpt_hit_dc1_i)))}})};


  //---------------------------
  // Pipeline register enables
  //---------------------------
  // There are two main pipeline register enables used for the DC2 registers.
  // One is asserted whenever a new instruction is pipelined from DC1, and is
  // used for basic instruction properties. Not all registers require this
  // enable though, as registers which store the result of a translation will
  // not need updating when the result of the translation is guaranteed to be
  // the same as for the previous instruction. For these registers, a second
  // enable is used, which is suppressed when the registers are guaranteed
  // not to need updating.

  // General enable term - always asserted when pipelining new instruction.
  assign enable_dc2 = ~stall_dc2 & ~stall_dc1 & valid_dc1 & ~cc_fail_or_flush_dc1;

  // Enable term used for translation registers
  // - This enable is also asserted on non-common cases (CP ops, exclusives
  // and aborting instructions) to allow as many registers as possible to use
  // it.
  // - The instruction in DC1 will have the same translation result if it
  // hits in the same uTLB entry as the previous instruction, and the
  // previous instruction made it to DC2 (i.e. it was not flushed).
  // - Must force when may change attributes, as this can cause two accesses
  // which hit in the same uTLB entry to get different attributes. Note this
  // does not need to factor in force_nc, as that can only change when the
  // cache on-ness changes, which will cause a uTLB flush.

  // - Track when the enable can be used
  assign must_enable_transl_dc1 = force_transient_dc1 | abort_dc1 | force_no_write_alloc_dc1 | cp_inst_dc1 | ldar_stlr_dc1 | excl_dc1;

  assign next_transl_valid_dc2 = (enable_transl_dc2 &         // Set when pipelining new transaction:
                                  ~must_enable_transl_dc1) |  // - which doesn't force enable_transl to be enabled
                                 (transl_valid_dc2 &          // Maintain once set
                                  ~(cc_fail_or_flush_dc1 |    // - clear on flush or when enable forced
                                    ~dpu_utlb_hit_dc1_i |
                                    (valid_dc1 & must_enable_transl_dc1)));

  // - Note this register must be clocked off the free-running clock, as
  // there could be a flush while the pipeline is stalled on a uTLB miss.
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      transl_valid_dc2 <= 1'b0;
    else
      transl_valid_dc2 <= next_transl_valid_dc2;

  // - Must get same translation result when hitting in same uTLB entry
  assign utlb_entry_match_dc1_dc2   = {transl_valid_dc2, dpu_utlb_hit_entry_dc1_i} == {1'b1, utlb_entry_dc2};

  assign suppress_enable_transl_dc2 = (utlb_entry_match_dc1_dc2 & transl_valid_dc2) & ~must_enable_transl_dc1;

  assign enable_transl_dc2          = enable_dc2 & ~suppress_enable_transl_dc2;

  // Version of enable_transl_dc2 for use on upper half of VA
  // - va[63:32] only needs to be pipelined in AA64
  assign enable_va_upper_dc2        = enable_transl_dc2 & dpu_aarch64_state_i;

  // When the relevant TCR.TBI bit is set, the type byte of the VA is ignored
  // for the purpose of address translations, and can be used for pointer
  // tagging by software. In this case, the top byte of the VA is not
  // translation data and must be enabled with normal transaction data on
  // enable_dc2.
  assign enable_va_top_byte_dc2     = enable_dc2 & (~suppress_enable_transl_dc2 | ttbr_tbi) & dpu_aarch64_state_i;


  //-----------
  // Registers
  //-----------

  always @(posedge clk_dc2)
    if (enable_dc2) begin
      va_dc2[11:0]      <= next_va_dc2[11:0];
      size_dc2          <= size_dc1;
      length_dc2        <= final_length_dc1;
      strobe_dc2        <= strobe_dc1;
      first_dc2         <= first_dc1;
      cp_op_dc2         <= next_cp_op_dc2;
      watchpoint_dc2    <= watchpoint_dc1;
      raw_store_dc2     <= raw_store_dc1;
    end

  always @(posedge clk_dc2)
    if (enable_transl_dc2) begin
      va_dc2[31:12]     <= next_va_dc2[31:12];
      attrs_dc2         <= attrs_dc1;
      upper_pa_dc2      <= dpu_pa_dc1_i;
      ns_dsc_dc2        <= dpu_ns_dsc_dc1_i;
      ldar_stlr_dc2     <= ldar_stlr_dc1;
      supersection_dc2  <= supersection_dc1;  // Only used on V2P, which always asserts enable_transl
      cp_inst_dc2       <= cp_inst_dc1;
      cp_write_dc2      <= cp_write_dc1;
      v2p_lpae_dc2      <= v2p_lpae_dc1;
      v2p_abort_dc2     <= v2p_abort_dc1;
      fault_stage_dc2   <= fault_stage_dc1;
      domain_dc2        <= next_domain_dc2;
      utlb_entry_dc2    <= dpu_utlb_hit_entry_dc1_i;
    end

  always @(posedge clk_dc2)
    if (enable_va_upper_dc2)
      va_dc2[55:32]     <= next_va_dc2[55:32];

  always @(posedge clk_dc2)
    if (enable_va_top_byte_dc2)
      va_dc2[63:56]     <= next_va_dc2[63:56];

  // dcu_load_dc2 and dcu_cp_read_dc2 factor into the critical next_data_dc3
  // logic, so rather than qualify with valid in DC2, they are defined to
  // always be valid.
  assign next_dcu_load_dc2    = load_dc1    & next_valid_dc2;
  assign next_dcu_cp_read_dc2 = cp_read_dc1 & next_valid_dc2;

  always @(posedge clk_dc2 or negedge reset_n)
    if (!reset_n) begin
      dcu_load_dc2    <= 1'b0;
      dcu_cp_read_dc2 <= 1'b0;
    end else if (v_enable_dc2) begin
      dcu_load_dc2    <= next_dcu_load_dc2;
      dcu_cp_read_dc2 <= next_dcu_cp_read_dc2;
    end


  //---------------------------------------------------------------------------
  // DC2
  //---------------------------------------------------------------------------
  // DC2 performs the following functions:
  // - Get load data from cache arbiter (corresponds to M2 in cache arbiter
  //   pipeline)
  // - Get STB, BIU and cache debug op data
  // - Store load data in skid buffer if stalled
  // - Make speculative linefill request to BIU if stalled
  // - Detect various hazards with the STB to pipeline result to DC3
  // - Detect access to memory mapped governor registers

  // Generic enable terms used to clock gate various DC2 registers
  assign reg_en_stall_dc2 = enable_dc2 | stall_dc2;
  assign reg_en_valid_dc2 = enable_dc2 | valid_dc2;

  // DC2 valid and not aborted
  assign valid_nabt_dc2 = valid_dc2 & ~|abort_dc2;


  //--------------------
  // Instruction decode
  //--------------------

  // CP op types
  // - Unqualified (need to be qualified with cp_inst_dc2 where used)
  assign cp_is_tlb_maint_dc2    = `CA53_CPOP_IS_TLBM(cp_op_dc2);
  assign cp_is_dc_maint_dc2     = `CA53_CPOP_IS_DCM(cp_op_dc2);
  assign cp_is_ifu_maint_dc2    = `CA53_CPOP_IS_ICM(cp_op_dc2);
  assign cp_is_bp_maint_dc2     = `CA53_CPOP_IS_BPM(cp_op_dc2);
  assign cp_is_v2p_dc2          = `CA53_CPOP_IS_V2P(cp_op_dc2);
  assign cp_is_mva_dc2          = `CA53_CPOP_IS_DCM_MVA(cp_op_dc2) | // DCIMVAC, DCCMVAC, DCCMVAU, DCCIMVAC
                                  `CA53_CPOP_IS_ICM_MVA(cp_op_dc2) | // ICIMVAU
                                  cp_is_v2p_dc2;
  assign cp_is_dc_debug_dc2     = `CA53_CPOP_IS_CDBG_DC(cp_op_dc2);
  assign cp_is_ic_debug_dc2     = `CA53_CPOP_IS_CDBG_IC(cp_op_dc2);
  assign cp_is_tlb_debug_dc2    = `CA53_CPOP_IS_CDBG_TLB(cp_op_dc2);

  // - Qualified with cp_inst_dc2
  assign dcu_needs_dvm_intf_dc2 = cp_inst_dc2 & (cp_is_tlb_debug_dc2 | cp_is_ic_debug_dc2); // IFU/TLB debug ops send over DVM interface
  assign cp_dc_maint_op_dc2     = cp_inst_dc2 & cp_is_dc_maint_dc2;
  assign cp_dc_ic_debug_op_dc2  = cp_inst_dc2 & (cp_is_dc_debug_dc2 | cp_is_ic_debug_dc2);
  assign clrex_dc2              = cp_inst_dc2 & `CA53_CPOP_IS_CLREX(cp_op_dc2);

  // - Barriers
  assign dxb_dc2   = cp_inst_dc2 & `CA53_CPOP_IS_BAR(cp_op_dc2) & ~`CA53_CPOP_IS_DMBLD(cp_op_dc2); // Barrier space but no DMBLD
  assign dsb_dc2   = cp_inst_dc2 & `CA53_CPOP_IS_DSB(cp_op_dc2);
  assign dmb_dc2   = cp_inst_dc2 & `CA53_CPOP_IS_DMB(cp_op_dc2) & ~`CA53_CPOP_IS_DMBLD(cp_op_dc2);
  assign dmbld_dc2 = cp_inst_dc2 & `CA53_CPOP_IS_DMBLD(cp_op_dc2); // DMB Load-Load/Store only
  assign dmbst_dc2 = dxb_dc2 & ~cp_op_dc2[2];  // For barriers, bit[2] is Full/nST - as there is no DSBST, can just decode DxBST

  // Properties encoded on cp_op bus
  assign store_dc2            = ~cp_inst_dc2 & cp_op_dc2[BIT_STORE] & ~cp_op_dc2[BIT_PLD];
  assign pld_dc2              = ~cp_inst_dc2 & cp_op_dc2[BIT_PLD];
  assign pldl2_dc2            = ~cp_inst_dc2 & cp_op_dc2[BIT_PLD_L2];
  assign excl_dc2             = ~cp_inst_dc2 & cp_op_dc2[BIT_EXCL];
  assign cross_64_dc2         = ~cp_inst_dc2 & cp_op_dc2[BIT_CROSS_64];
  assign align_size_word_dc2  = ~cp_inst_dc2 & cp_op_dc2[BIT_ALIGN_WD];

  // Compose the physical address
  assign pa_dc2 = {upper_pa_dc2[39:12], va_dc2[11:0]};

  // Decode memory attributes of accesses in DC2
  assign normal_dc2           = `CA53_MEM_NORMAL(attrs_dc2);
  assign cacheable_dc2        = `CA53_MEM_COHERENT(attrs_dc2);
  assign cacheable_ntrans_dc2 = `CA53_MEM_COHERENT(attrs_dc2) & ~((`CA53_MEM_TRANSIENT(attrs_dc2) | ~`CA53_MEM_WBRA(attrs_dc2)) &
                                                                  ~(excl_dc2 | pld_dc2 | dpu_disable_no_allocate_i));
  assign shareable_dc2        = `CA53_MEM_SHAREABLE(attrs_dc2);

  // If to non-shareable memory, then LDREX and STREX are treated as a normal
  // load or store respectively
  assign dcu_excl_shareable_dc2 = excl_dc2 & shareable_dc2;

  // Access to governor registers
  // - Either CP15 or memory mapped
  assign gov_op_dc2 = (cp_inst_dc2 & `CA53_CPOP_IS_GOV(cp_op_dc2)) | gov_mem_access_dc2;


  //-------------
  // Stall logic
  //-------------
  // - Stall in DC2 if DC3 is full and stalling or there is a RAW hazard
  //   between DC2 and DC3.
  // - Stall on attribute mismatch between DC2 and DC3.
  // - Stall a TLB/IFU debug operation if there is a DVM message being
  // processed, which is using the TLB/IFU interface in DC3.

  // Check for RAW hazard between load in DC2 and store in DC3
  // - Common parts of RAW/WAW comparators
  assign line_match       = ({ns_dsc_dc2, pa_dc2[39:6]}  == {ns_dsc_dc3, dcu_pa_dc3[39:6]});
  assign quadword_match   = ({line_match, pa_dc2[5:4]}   == {1'b1, dcu_pa_dc3[5:4]});

  assign raw_hazard_dc2      = dcu_load_dc2 & store_dc3 & quadword_match & |(strobe_dc2 & strobe_dc3);  // Used where valid_dc3 implied

  assign stall_dc2 = valid_dc2 &
                     ((dcu_needs_dvm_intf_dc2 & dvm_in_progress_i) |
                      (~dpu_ready_cc_fail_wr_i & // DC2/3 not CC failing
                       (// DC2 can stall on DC3 if:
                        valid_dc3 &
                         // - RAW Hazard
                        (raw_hazard_dc2 |
                         // - Attribute mismatch
                         (first_dc2 & dcu_load_dc2 & attr_mismatch_dc3) |
                         // - DC3 stalled
                         ~(dpu_ready_wr_i & dcu_valid_dc3)))));


  //------------------------
  // Instruction conversion
  //------------------------
  // Instructions can have their size converted in DC2.

  // The size presented externally must be converted in the following cases:
  // - The size is converted to Doubleword when an unaligned normal access is
  // fits within a 64-bit boundary (i.e. it is not cross64). The alignment
  // on doublewords does not need to be checked as unaliged doublewords must
  // be cross64, and the memory type does not need to be checked as
  // unaligned halfword/word accesses to Device memory will align fault in
  // DC1.
  assign force_dword_dc2 = ~cp_inst_dc2 & ~cross_64_dc2 &                     // Size must be preserved on TLB register writes
                           (((size_dc2 == `CA53_SIZE_HWORD) & va_dc2[0]) |    // Check for natural alignment
                            ((size_dc2 == `CA53_SIZE_WORD)  & (|va_dc2[1:0])));

  // - The size is converted to Word when a doubleword accesses a word or
  // less of data in the current transaction. This is required to ensure that
  // word aligned LDRD/STRD instructions to Device memory indicate the size
  // of each access on AXI as 32-bit to prevent over reading/writing of data.
  // The calculation is performed as a word or less being accessed (rather
  // than exactly one word) as this is more area efficient. This has the side
  // effect that NEON doublewords with access less than a word in one access
  // and more than a word in another will have the smaller access marked as
  // Word and the larger access marked as Doubleword. This is acceptible as
  // in both cases all the bytes required by the instruction will be
  // addressed.
  // - Note that the strobes must be used to detect this case rather than the
  // address, as both halves of the cross64 must have their size converted,
  // and the DPU will align the address on the second access.

  assign words_accessed_dc2 = {(|strobe_dc2[15:12]),
                               (|strobe_dc2[11:8]),
                               (|strobe_dc2[7:4]),
                               (|strobe_dc2[3:0])};

  assign force_word_dc2 = (size_dc2 == `CA53_SIZE_DWORD) &
                          ~cp_inst_dc2 &
                          (length_dc2[3:1] == 3'b000) &       // Not accessing more than a doubleword
                          ((words_accessed_dc2 == 4'b0001) |
                           (words_accessed_dc2 == 4'b0010) |
                           (words_accessed_dc2 == 4'b0100) |
                           (words_accessed_dc2 == 4'b1000));  // Accessing bytes in only one word

  assign dcu_size_dc2 = force_dword_dc2 ? `CA53_SIZE_DWORD :
                        force_word_dc2  ? `CA53_SIZE_WORD
                                        : size_dc2;

  // Convert the length to 0 when this is the last beat of a transaction and its
  // size is converted to word. This is to prevent the second beat of an LDRD
  // which is x64 but 32-bit aligned from looking like an LDM of two registers
  // to the BIU, and thus accessing too much data (which is illegal if it is to
  // Device memory).
  assign final_length_dc2 = length_dc2 & {4{~(load_last_dc2 & force_word_dc2)}};


  //-------------
  // Skid buffer
  //-------------
  // DC2 contains a skid buffer used to store cache hit, BIU and STB data
  // for instructions stalled in DC2. The skid buffer is also used to store RAM
  // data on dcache debug ops before passing it to the TLB, and for the
  // pipelining of MBIST data.
  //
  // Multiple sources can indicate that they have data for an instruction in
  // DC2, and the data from each is merged in priority order, which the
  // newest data having highest priority:
  // - STB (newest)
  // - Data already in DC2
  // - BIU
  // - Cache

  // STB hits
  // - only allow to hit on mergeable memory as non-mergeable loads must wait
  // for the STB to drain before making an external load request
  // - ignore on non-cacheable LDREXs as these must be forced to go external
  assign stb_hit_mergeable_dc2 = {8{`CA53_MEM_MERGEABLE(attrs_dc2) & ~(dcu_excl_shareable_dc2 & ~cacheable_dc2)}} & stb_hit_dc2_i;

  // Cache hits
  // - Only merge from Dcache on first cycle in DC2, as this corresponds to
  // the cycle the instruction is in M2 in the cache arbiter pipeline.
  // - The cache is only allowed to hit on cacheable transactions, when the
  // cache is on. Note that when the cache is off the attributes are forced
  // to NC, so this does not need to be checked here.
  always @(posedge clk_dc2 or negedge reset_n)
    if (!reset_n)
      previous_stall_dc2 <= 1'b0;
    else if (reg_en_valid_dc2)
      previous_stall_dc2 <= stall_dc2;

  assign dcache_hit_enable_dc2 = ~previous_stall_dc2 &
                                 ~cp15_inv_all_force_miss_i &
                                 cacheable_dc2;

  // Track which bytes of the skid buffer contain data
  // - A PLD being accepted by the BIU sets the data mask to cause the DCU to
  // suppress the request and allow the instruction to retire.
  assign new_data_mask_dc2 = {8{dcu_load_dc2}} &
                             (data_mask_dc2                                 |
                              stb_hit_mergeable_dc2                         |
                              {8{biu_read_data_valid_dc2_i}}                |
                              {8{dcache_hit_enable_dc2 & dc_load_hit_m2_i}} |
                              {8{pld_dc2 & previous_stall_dc2 & (pldl2_dc2 ? biu_pld_l2_ready_dc2 : biu_lf_ready_dc2_i)}});

  assign next_data_mask_dc2 = {8{stall_dc2}} & new_data_mask_dc2;

  always @(posedge clk_dc2)
    if (reg_en_valid_dc2)
      data_mask_dc2 <= next_data_mask_dc2;

  // Mux between sources of load data in DC2
  // - The DC2 skid buffer is also used for pipelining tag data during MBIST,
  // using the same datapath as Tag debug ops.
  assign data_dc_mux_en_dc2  = {8{data_debug_op_ack_i}} | ({8{dcu_load_dc2 & dcache_hit_enable_dc2 & ~biu_read_data_valid_dc2_i}} & ~stb_hit_dc2_i);
  assign data_stb_mux_en_dc2 = {8{dcu_load_dc2}} & stb_hit_mergeable_dc2;
  assign data_biu_mux_en_dc2 = {8{dcu_load_dc2 & biu_read_data_valid_dc2_i}} & ~stb_hit_dc2_i;

  generate for (dc2_byte=0; dc2_byte<8; dc2_byte=dc2_byte+1) begin: g_next_data_dc2
    assign next_data_dc2[dc2_byte*8 +: 8] = ({8{data_dc_mux_en_dc2[dc2_byte]}}    & dc_load_data_m2_i[dc2_byte*8 +: 8])  |
                                            ({8{data_stb_mux_en_dc2[dc2_byte]}}   & stb_data_dc2_i[dc2_byte*8 +: 8])     |
                                            ({8{data_biu_mux_en_dc2[dc2_byte]}}   & biu_read_data_dc2_i[dc2_byte*8 +: 8]) |
                                            ({8{tag_debug_op_ack_i | mbist_en_i}} & dc_debug_tag_data_m2_i[dc2_byte*8 +: 8]);
  end endgenerate

  // Register enable
  // - As loads use a 64-bit data path, the strobes are formed by ORing the
  // strobes for the upper and lower dword from the DPU.
  assign load_strobe_dc2 = strobe_dc2[15:8] | strobe_dc2[7:0];

  assign data_en_dc2 = ({8{dcu_load_dc2 & stall_dc2}} & load_strobe_dc2 & ({8{dcache_hit_enable_dc2}} |
                                                                           stb_hit_mergeable_dc2 |
                                                                           ({8{biu_read_data_valid_dc2_i}} & ~data_mask_dc2))) |
                       ({8{dc_cp15_ack_i | mbist_en_i}});

  always @(posedge clk_dc2)
    begin
      if (data_en_dc2[7])
        data_dc2[63:56] <= next_data_dc2[63:56];
      if (data_en_dc2[6])
        data_dc2[55:48] <= next_data_dc2[55:48];
      if (data_en_dc2[5])
        data_dc2[47:40] <= next_data_dc2[47:40];
      if (data_en_dc2[4])
        data_dc2[39:32] <= next_data_dc2[39:32];
      if (data_en_dc2[3])
        data_dc2[31:24] <= next_data_dc2[31:24];
      if (data_en_dc2[2])
        data_dc2[23:16] <= next_data_dc2[23:16];
      if (data_en_dc2[1])
        data_dc2[15:8]  <= next_data_dc2[15:8];
      if (data_en_dc2[0])
        data_dc2[7:0]   <= next_data_dc2[7:0];
    end

  // Send data to BIU to use during MBIST.
  assign dcu_mbist_out_data_mb6_o = data_dc2;


  //------------
  // ECC Errors
  //------------
generate if (CPU_CACHE_PROTECTION) begin : g_ecc_err_dc2
  // If a load stalls in DC2 it will be in DC2 when the ECC error information
  // is available in M3 from the cache arbiter. When the load first enters DC2
  // it will be in M2 in the cache arbiter pipeline. Loads never stall in M2, so
  // it will be in M3 on the second cycle it is in DC2 (i.e. the first cycle
  // when stall_dc2 and previous_stall_dc2 are set).
  // - Note do not need to factor in inv_all_force_miss, as cannot have any
  // lookup in M3 when doing invalidate all on reset, as load requests are
  // suppressed and prearb requests are blocked in the cachearb during
  // invalidate all on reset.

  assign load_m3_dc2 = dcu_load_dc2 & cacheable_dc2 &           // Done lookup
                       previous_stall_dc2 & ~seen_load_m3_dc2;  // In M3

  assign next_seen_load_m3_dc2 = enable_dc2 ? 1'b0 : (load_m3_dc2 | seen_load_m3_dc2);
  assign next_ecc_err_dc2      = enable_dc2 ? 1'b0 : ((load_m3_dc2 & dc_ecc_err_m3_i) | ecc_err_dc2);

  always @(posedge clk_dc2)
    if (reg_en_stall_dc2) begin
      seen_load_m3_dc2 <= next_seen_load_m3_dc2;
      ecc_err_dc2      <= next_ecc_err_dc2;
    end

  assign dcu_ecc_err_dc2 = (load_m3_dc2 & dc_ecc_err_m3_i) | ecc_err_dc2;

end else begin : g_ecc_err_dc2_no_ecc
  assign dcu_ecc_err_dc2 = 1'b0; // Used by complete_exception logic so must be valid when no ECC
end endgenerate


  //---------------------------------
  // Memory mapped governor accesses
  //---------------------------------
  // Detect when a load or store in DC2 is accessing a GIC register via the
  // governor.
  //
  // The actual access will be done in DC3, but the detection is done here,
  // as is the calculation of whether the access should abort. This improves
  // timing, and also simplifies the logic for retiring the instruction.

  // Detect whether address means will access GIC registers via the governor
  assign gov_mem_access_dc2 = ~cp_inst_dc2 & (dpu_periphbase_i == pa_dc2[39:18]) & ~giccdisable_i;

  // Memory mapped accesses via the governor must be Word sized singles to Device
  // memory, with the align size matching the size (i.e. not NEON with special
  // alignment), and must not be exclusives, otherwise they abort.
  assign gov_mem_abort_dc2 = gov_mem_access_dc2 & (normal_dc2                    |  // Not device
                                                   (size_dc2 != `CA53_SIZE_WORD) |  // Not Word sized
                                                   ~align_size_word_dc2          |  // With 32-bit alignment
                                                   excl_dc2                      |  // Exclusive
                                                   (length_dc2 > 4'b0000));         // Not single


  //--------
  // Aborts
  //--------
  // An abort can be raised in DC2 when the skid buffer is used to store data
  // with an abort attached to it. This can only happen for BIU data, as
  // dcache and STB data cannot abort.

  // Look at aborts from the BIU if the DCU doesn't already have (and isn't
  // getting from the STB) all its data.
  assign new_biu_abort_dc2 = dcu_load_dc2 & normal_dc2 & biu_read_abort_dc2_i;

  // If there is an external abort in DC2 this cycle or there was an external
  // abort in a previous cycle, this is cleared by any bytes received from the
  // STB, but this does not apply to governor aborts as these should always
  // cause an abort.
  assign new_abort_dc2 = (abort_dc2              & ~(stb_hit_mergeable_dc2 & {8{`CA53_FAULT_EXT(fault_dc2)}}))  |
                         ({8{new_biu_abort_dc2}} & load_strobe_dc2 & ~data_mask_dc2 & ~stb_hit_mergeable_dc2)   |
                         {8{gov_mem_abort_dc2}};

  // If there has previously been an abort, then that must take priority,
  // otherwise the abort (if any) can only come from the BIU or a memory mapped
  // governor access.
  // - Note LDREX faults are not possible in DC2
  assign biu_fault_dc2 = ({7{biu_read_fault_dc2_i == 2'b10}}  & `CA53_FAULT_LPAE_ECC)     |
                         ({7{biu_read_fault_dc2_i == 2'b01}}  & `CA53_FAULT_LPAE_EXT_DEC) |
                         ({7{biu_read_fault_dc2_i == 2'b00}}  & `CA53_FAULT_LPAE_EXT_SLV);

  assign new_fault_dc2 = gov_mem_abort_dc2 ? `CA53_FAULT_LPAE_EXT_SLV : biu_fault_dc2;

  // abort_dc2 is the registered abort information, new_abort_dc2 also
  // includes external aborts that are being raised in DC2 on this cycle.
  assign next_abort_dc2 = enable_dc2 ? {8{abort_dc1}} : new_abort_dc2;
  assign next_fault_dc2 = enable_dc2 ? fault_dc1      : new_fault_dc2;

  // Enable abort flops when moving from DC1->DC2 or when there is a new or
  // existing abort (need to enable when existing abort as can clear strobes on
  // merging STB data in, after abort first seen).
  assign abort_dc2_en =  enable_dc2                                | (stall_dc2 & ((|abort_dc2) | (|new_abort_dc2)));

  // Only enable fault flops when there is an abort
  assign fault_dc2_en = (enable_dc2 & (abort_dc1 | v2p_abort_dc1)) | (stall_dc2 & (~|abort_dc2) & (new_biu_abort_dc2 | gov_mem_abort_dc2));

  always @(posedge clk_dc2)
    if (abort_dc2_en)
      abort_dc2 <= next_abort_dc2;

  always @(posedge clk_dc2)
    if (fault_dc2_en)
      fault_dc2 <= next_fault_dc2;


  //-------------------
  // Linefill requests
  //-------------------
  // Normal loads can request a linefill from DC2 if the load missed in the
  // cache and has stalled in DC2. The BIU treats this as a lower priority
  // than any DC3 request and uses it to start a speculative linefill if it
  // has resource free and has already serviced any request from DC3.

  assign load_done_dc2  = ((data_mask_dc2 & load_strobe_dc2) == load_strobe_dc2);

  assign dcu_lf_req_dc2 = dcu_load_dc2 & ~pldl2_dc2 & cacheable_ntrans_dc2 &
                          (~|abort_dc2) & ~load_done_dc2 & ~cc_fail_dc2 & previous_stall_dc2 &
                          ~dcu_ecc_err_dc2 & ~(dcu_ecc_err_dc3 & valid_dc3);

  // DC2 can get linefill way from DC1 if DC1 has already done a lookup and
  // started a linefill, or from cache arbiter if load lookup M2 on first cycle
  // in DC2
  assign next_dcu_lf_way_dc2 = (enable_dc2 & (lf_state_dc1 == LF_REQ))                   ? dcu_lf_way_dc1          :
                               (valid_dc2 &  (lf_state_dc1 != LF_M2) & load_lookup_m2_i) ? dc_load_victim_way_m2_i :
                                                                                           dcu_lf_way_dc2;

  always @(posedge clk_dc2 or negedge reset_n)
    if (!reset_n)
      dcu_lf_way_dc2  <= 2'b00;
    else
      dcu_lf_way_dc2  <= next_dcu_lf_way_dc2;

  // L2 linefill requests for PLDL2
  assign pld_l2_req_dc2 = valid_nabt_dc2 & pldl2_dc2 &
                          cacheable_dc2 & ~load_done_dc2 & previous_stall_dc2;

  // Track when a PLD request is accepted by the BIU
  always @(posedge clk)
    biu_pld_l2_ready <= biu_pld_l2_next_ready_i;

  // DC3 always has priority over DC2
  assign biu_pld_l2_ready_dc2 = biu_pld_l2_ready & ~pld_l2_req_dc3;


  //--------------------------------------------
  // Sameline and merge information for the STB
  //--------------------------------------------

  // Find the first available free slot
  assign new_slot = {~stb_slots_valid_i[4] & (&stb_slots_valid_i[3:0]),
                     ~stb_slots_valid_i[3] & (&stb_slots_valid_i[2:0]),
                     ~stb_slots_valid_i[2] & (&stb_slots_valid_i[1:0]),
                     ~stb_slots_valid_i[1] & stb_slots_valid_i[0],
                     ~stb_slots_valid_i[0]};

  // Work out whether any slots will be available after the current store is
  // accepted, not factoring in slots emptying this cycle.
  assign new_slot_avail = |(~(new_slot | stb_slots_valid_i));

  // Work out which slot will be used by the store (if any) in DC3.
  assign stb_or_new_slot_dc3 = |dcu_store_merge_dc3 ? dcu_store_merge_dc3 : new_slot;

  // If the STB reports that the attributes of the transaction in DC2 are
  // different to a transaction within the same cache line that is either in the
  // STB or in DC3 (and hence about to enter the STB), then the slot must be
  // marked as non-mergeable to keep the mismatched transactions apart.

  // - Detect when there will be an STB req for a store in DC3, without
  // store_sent and strex_failed factored in (as there cannot be anything in
  // DC2 when there is an STREX in DC3).
  assign stb_store_req_early_dc3 = dpu_ready_cc_pass_wr_i & valid_nabt_dc3 & store_dc3 &
                                   ~gov_mem_access_dc3 & ~(watchpoint_dc3 & `CA53_MEM_MERGEABLE(attrs_dc3));

  assign waw_attr_mismatch_dc2 = stb_store_req_early_dc3 &
                                 ~dpu_kill_wr_i &
                                 line_match &
                                 (attrs_dc2 != attrs_dc3);

  assign attr_mismatch_dc2 = valid_dc2 & store_dc2 &
                             ((stb_attr_mismatch_dc2_i & ~force_non_mergeable_early_dc3) |  // Ignore mismatch if DC3 can't merge anyway
                              (waw_attr_mismatch_dc2   & ~cp_inst_dc3));                    // Do not report mismatch if DMB in DC3

  assign stb_force_non_mergeable_dc2 = valid_dc2 & store_dc2 &
                                       (stb_force_non_mergeable_i & ~force_non_mergeable_early_dc3);

  // The store in DC2 may potentially merge into a slot if it is to normal
  // or GRE memory, unless it is a shareable STREX or the STB is requesting
  // slots become non-mergeable.
  assign mergeable_dc2 = valid_nabt_dc2 & store_dc2 &
                         ~cc_fail_dc2 & ~stall_dc2 &
                         `CA53_MEM_MERGEABLE(attrs_dc2) &
                         ~attr_mismatch_dc2 &
                         ~dcu_excl_shareable_dc2 &
                         ~ldar_stlr_dc2 &
                         ~stb_force_non_mergeable_dc2;

  // The store in DC3 may be merged into (once it reaches the STB) if it is
  // normal or device GRE and is not part of a store release. The STB will,
  // for non-coherent store releases, insert an implicit barrier to guarantee
  // observability of the store before subsequent loads to the same address
  // can have data forwarded from a subsequent store.
  assign mergeable_dc3 = stb_store_req_early_dc3 & `CA53_MEM_MERGEABLE(attrs_dc3) & ~ldar_stlr_dc3;

  // Combine the information from the STB and the slot from DC3 if there is a
  // WAW hazard, to determine which slot if any the store will merge into.
  // If DC3 is currently marking a slot non-mergeable then the information
  // from the STB must be ignored as that relates to slots that existed before
  // the barriered slot. The barrier should not factor into the WAW part
  // because the barrier is being inserted before the transaction in DC3.
  assign dcu_store_merge_dc2 = ({5{mergeable_dc2 & ~force_non_mergeable_early_dc3}} & stb_can_merge_dc2_i) |
                               ({5{mergeable_dc2 & mergeable_dc3 & quadword_match}} & stb_or_new_slot_dc3);

  // Factor flush in after the merge information has been used to calculate the
  // slot_available logic, to help timing.
  assign next_dcu_store_merge_dc3 = dcu_store_merge_dc2 & ~{5{flush_dc2}};

  // Combine the information from the STB and the slot from DC3 if there is a
  // WAW hazard, to determine which slots contain stores that are within the
  // same 64Byte line (and haven't had a DMB between them).
  assign dcu_store_sameline_dc2 = ({5{mergeable_dc2 & ~force_non_mergeable_early_dc3}} & stb_sameline_dc2_i) |
                                  ({5{mergeable_dc2 & mergeable_dc3 & line_match}} & stb_or_new_slot_dc3);

  // Update the merge/sameline registers when a transaction leaves DC3 or when
  // a store is despatched to the STB. (This will normally be the same cycle, except
  // for STREX to shareable memory, and in this case store merge must not be
  // asserted because that would prevent the STREX from leaving the STB, which in
  // turn would prevent DC3 from retiring.)
  assign merge_sameline_en = v_enable_dc3 | (stb_store_req_early_dc3 & slot_avail);

  always @(posedge clk_dc3 or negedge reset_n)
    if (!reset_n) begin
      dcu_store_merge_dc3     <= 5'b00000;
      dcu_store_sameline_dc3  <= 5'b00000;
    end else if (merge_sameline_en) begin
      dcu_store_merge_dc3     <= next_dcu_store_merge_dc3;
      dcu_store_sameline_dc3  <= dcu_store_sameline_dc2;
    end

  // Work out which slots are in the same line as a load in DC2. This information
  // is then passed back to the STB in DC3, so that the STB can keep the data
  // around for forwarding to the load.
  assign raw_sameline_dc2 = stb_store_req_early_dc3 & ~dpu_kill_wr_i & line_match;

  // - last beat of load when length is 0, or length is 1 (i.e. loading 64-bits)
  // and doubleword aligned (so can do in one cycle).
  assign load_last_dc2 = (length_dc2[3:1] == 3'b000) & (~length_dc2[0]          | // 32-bits
                                                        (va_dc2[2:0] == 3'b000) | // 64-bits and getting all on this transaction
                                                        (va_dc2[5:3] == 3'b111)); // 64-bits and not getting all this tx, but at end of cache line, so will get rest in next cache line, which will effectively be a new burst

  // - ignore on exclusive shareable non-cacheable, as these will wait for STB
  // to drain before making BIU request and will not forward from the STB.
  assign load_sameline_dc2 = {5{dcu_load_dc2 & `CA53_MEM_MERGEABLE(attrs_dc2) &
                                ~(dcu_excl_shareable_dc2 & ~cacheable_ntrans_dc2) &
                                ~cc_fail_or_flush_dc2 & ~load_last_dc2}} &
                             (stb_load_sameline_dc2_i |
                              ({5{raw_sameline_dc2}} & stb_or_new_slot_dc3));

  // During the middle of a committed multiple the value of load sameline must
  // be preserved even if there is a bubble.
  assign dcu_leaving_dc2 = valid_dc2 & ~stall_dc2;

  assign load_sameline_en = dcu_leaving_dc2 | cc_fail_or_flush_dc3;

  // - uses free running clock as can be cleared when DC3 empty
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      dcu_load_sameline_dc3 <= 5'b00000;
    end else if (load_sameline_en) begin
      dcu_load_sameline_dc3 <= load_sameline_dc2;
    end

  assign dcu_store_merge_dc3_o     = dcu_store_merge_dc3;
  assign dcu_store_sameline_dc3_o  = dcu_store_sameline_dc3;
  assign dcu_load_sameline_dc3_o   = dcu_load_sameline_dc3;

  // Deterimine if the STB slot is valid on the next cycle.
  assign next_slots_valid = stb_slots_valid_i & ~stb_slots_emptying_i;


  // --------------------------
  // Exclusive monitor checking
  // --------------------------
  // On STREXs, the local monitor is checked in DC2, and the result pipelined
  // to DC3 to pass back to the DPU. Note that a STREX which passes the local
  // monitor can still fail, if it does not get the correct response or there
  // has been a hazarded detected by the STB. The exclusive monitor is only
  // passed if the cacheability of the STREX matches the cacheability of the
  // LDREX which set the monitor. Attribute mismatches other than on the
  // cacheability are ignored.
  assign strex_monitor_failed_dc2 = store_dc2 & excl_dc2 &
                                    ({exclusive_monitor, exclusive_tag,            exclusive_tag_cacheable} !=
                                     {             1'b1, ns_dsc_dc2, pa_dc2[39:6], cacheable_dc2          });

  // If a STREX passes the local monitor in DC2 but subsequently fails
  // because of the response from the STB/BIU, set the monitor failed signal
  // so the STREX does not return OK to the DPU.
  assign next_strex_monitor_failed_dc3 = stall_dc3 ? (strex_monitor_failed_dc3 |
                                                      ((stb_cacheable_strex_done_i & stb_strex_failed_i) |
                                                       (biu_strex_bresp_valid_i    & (biu_strex_bresp_i != 2'b01))))
                                                   : strex_monitor_failed_dc2;

  always @(posedge clk_dc3)
    if (reg_en_dc3)
      strex_monitor_failed_dc3 <= next_strex_monitor_failed_dc3;


  //-------------------------
  // Outputs to other blocks
  //-------------------------
  assign dcu_size_dc2_o         = dcu_size_dc2;
  assign dcu_length_dc2_o       = final_length_dc2;
  assign dcu_attrs_dc2_o        = attrs_dc2;
  assign dcu_pld_l2_req_dc2_o   = pld_l2_req_dc2;
  assign dcu_exclusive_dc2_o    = dcu_excl_shareable_dc2; // Only indicate shareable exclusives to BIU/STB
  assign dcu_pa_dc2_o           = pa_dc2[39:0];
  assign dcu_ns_dsc_dc2_o       = ns_dsc_dc2;
  assign dcu_load_dc2_o         = dcu_load_dc2;
  assign dcu_leaving_dc2_o      = dcu_leaving_dc2;
  assign dcu_lf_req_dc2_o       = dcu_lf_req_dc2;
  assign dcu_lf_way_dc2_o       = dcu_lf_way_dc2;
  assign dcu_valid_dc2_o        = valid_dc2;

  // Indicate to the STB that there is an operation in DC2 which may require
  // an STB slot. It can use this to decide how many slots to start to drain.
  assign dcu_store_dc2_o      = valid_dc2 & (store_dc2 | (cp_inst_dc2 & ~cp_op_dc2[8] & cp_op_dc2[6] & ~`CA53_CPOP_IS_DMBLD(cp_op_dc2)));

  // Indicate the register being accessed on a CP write to the TLB. The
  // encoding matches that used on the DPU interface, so data can be taken
  // straight from the cp_op bus.
  assign dcu_cp_reg_en_dc2_o  = {6{dcu_cp_read_dc2}} & cp_op_dc2[5:0];  // Lowest 6-bits passed to TLB

  // The BIU contains logic to support speculative non-cacheable requests from
  // DC2, however this is not used.
  assign dcu_biu_req_dc2_o = 1'b0;


  //---------------------------------------------------------------------------
  // DC2 -> DC3
  //---------------------------------------------------------------------------

  //------------
  // Valid flag
  //------------
  // Update valid in DC3 whenever not stall or if clearing valid on a flush
  // Clock the valid flags when not stalled or there is a ccfail or flush

  assign v_enable_dc3   = ~valid_dc3 | (dpu_ready_wr_i & dcu_valid_dc3) | cc_fail_or_flush_dc3;
  assign next_valid_dc3 = valid_dc2 & ~cc_fail_or_flush_dc2 & ~stall_dc2;

  always @(posedge clk_dc3 or negedge reset_n)
    if (!reset_n)
      valid_dc3 <= 1'b0;
    else if (v_enable_dc3)
      valid_dc3 <= next_valid_dc3;


  //-------------
  // New signals
  //-------------
  // The following signals are not pipelined straight from DC2, but are
  // either created in DC2 solely for use in DC3, or modified between DC2 and
  // DC3.

  // The way comes from the cache arbiter in M2, so if a load lookup is
  // stalled in DC2, the linefill way for DC3 comes from the cache arbiter.
  // When there has not been a stall in DC2, the way is masked to zero if
  // there is no M2 lookup. The DCU can only susbsequently request a linefill
  // in this case if the previous access did not stall, and so must have
  // gotten data from the BIU. This means the linefill being requested will
  // already be in progress, so the BIU will ignore the new request.
  assign next_dcu_lf_way_dc3 = previous_stall_dc2 ? dcu_lf_way_dc2
                                                  : {2{load_lookup_m2_i}} & dc_load_victim_way_m2_i;

  // The decision on whether a CP15 operation needs to broadcast via the STB
  // is made in DC2 and pipelined to DC3, to improve timing.
  assign cp15_needs_broadcast_dc2 = cp_inst_dc2 &
                                    (cp_is_tlb_maint_dc2 |  // TLB Maintenance
                                     cp_is_bp_maint_dc2  |  // Branch Prediction
                                     cp_is_ifu_maint_dc2 |  // IFU Maintenance
                                     cp_is_dc_maint_dc2);   // DC* Maintenance

  // CP ops that don't do an address translation must get their ns bit (that is
  // used if forwarding the operation) from the DPU's ns state. This is done in
  // DC2 rather than DC3 to help timing as ns_dsc_dc3 is used in the address
  // hazard comparators.
  assign next_ns_dsc_dc3 = (cp_inst_dc2 & ~cp_is_mva_dc2) ? dpu_ns_state_i : ns_dsc_dc2;

  // For CP operations which are broadcast as DVM operations, the priv signal to the STB
  // is reused to indicate the value of SCR_EL3.NS, as this determines the security state
  // indicated on the broadcast DVM.
  assign next_priv_dc3 = cp_inst_dc2 ? dpu_scr_el3_ns_i : cp_op_dc2[BIT_PRIV];

  // Governor memory accesses are detected in DC2 and pipelined to DC3. Since
  // BIT_ALIGN_WD is only used before DC3, that bit is reused as BIT_MEM_MAP in
  // DC3.
  assign next_cp_op_dc3 = {(cp_inst_dc2 ? cp_op_dc2[8] : gov_mem_access_dc2),
                           cp_op_dc2[7:0]};


  //---------------------------
  // Pipeline register enables
  //---------------------------
  // In the same way as for between DC1 and DC2, there are two main pipeline
  // register enable terms used for DC3 registers: one for all instructions
  // and one for instructions with new address translations.

  // General enable term - always asserted when pipelining new instruction.
  assign enable_dc3 = ~stall_dc3 & ~stall_dc2 & valid_dc2 & ~cc_fail_or_flush_dc2;

  // Enable term for translation registers
  // - Track when the enable needs to be used. This will be whenever a new
  // translation has been pipelined from DC1 to DC2 but has not yet been
  // pipelined as far as DC3.
  assign next_new_transl_dc2      = enable_transl_dc2      | (new_transl_dc2      & ~enable_dc3);
  // - Need to track when top byte of VA may have changed separately as TBI can
  // change between instructions (as they can use different TTBRs).
  assign next_new_va_top_byte_dc2 = enable_va_top_byte_dc2 | (new_va_top_byte_dc2 & ~enable_dc3);

  always @(posedge clk_dc2 or negedge reset_n)
    if (!reset_n) begin
      new_transl_dc2      <= 1'b0;
      new_va_top_byte_dc2 <= 1'b0;
    end else if (reg_en_valid_dc2) begin
      new_transl_dc2      <= next_new_transl_dc2;
      new_va_top_byte_dc2 <= next_new_va_top_byte_dc2;
    end

  assign enable_transl_dc3      = enable_dc3 & new_transl_dc2;
  // - va[63:32] only needs to be pipelined in AA64
  assign enable_va_upper_dc3    = enable_transl_dc3 & dpu_aarch64_state_i;
  assign enable_va_top_byte_dc3 = enable_dc3 & new_va_top_byte_dc2;


  //-----------
  // Registers
  //-----------

  always @(posedge clk_dc3)
    if (enable_dc3) begin
      va_dc3[11:0]                <= va_dc2[11:0];
      ns_dsc_dc3                  <= next_ns_dsc_dc3;
      priv_dc3                    <= next_priv_dc3;
      dcu_size_dc3                <= dcu_size_dc2;
      length_dc3                  <= final_length_dc2;
      load_dc3                    <= dcu_load_dc2;
      store_dc3                   <= store_dc2; // store_dc3 is used is some critical signals in DC3, so a dedicated register is used
      strobe_dc3                  <= strobe_dc2;
      cp_op_dc3                   <= next_cp_op_dc3;
      attr_mismatch_dc3           <= attr_mismatch_dc2;
      first_dc3                   <= first_dc2;
      watchpoint_dc3              <= watchpoint_dc2;
      raw_store_dc3               <= raw_store_dc2;
      stb_force_non_mergeable_dc3 <= stb_force_non_mergeable_dc2;
    end

  always @(posedge clk_dc3)
    if (enable_transl_dc3) begin
      va_dc3[31:12]               <= va_dc2[31:12];
      upper_pa_dc3                <= upper_pa_dc2;
      attrs_dc3                   <= attrs_dc2;
      ldar_stlr_dc3               <= ldar_stlr_dc2;
      supersection_dc3            <= supersection_dc2;         // Only used on V2P, which always asserts enable_transl
      v2p_lpae_dc3                <= v2p_lpae_dc2;
      v2p_abort_dc3               <= v2p_abort_dc2;
      cp_inst_dc3                 <= cp_inst_dc2;
      cp_read_dc3                 <= dcu_cp_read_dc2;
      cp_write_dc3                <= cp_write_dc2;
      cp15_needs_broadcast_dc3    <= cp15_needs_broadcast_dc2; // Only used on CP15, which always asserts enable_transl
      fault_stage_dc3             <= fault_stage_dc2;
      domain_dc3                  <= domain_dc2;
    end

  always @(posedge clk_dc3)
    if (enable_va_upper_dc3)
      va_dc3[55:32] <= va_dc2[55:32];

  always @(posedge clk_dc3)
    if (enable_va_top_byte_dc3)
      va_dc3[63:56] <= va_dc2[63:56];

  // The way normally gets updated on a first, but if an instruction CC fails then
  // the first part may be killed before it reaches DC3, while a subsequent
  // part is killed after it reaches DC3 and therefore may make use of the way.
  // Hence the way needs resetting to prevent X propagation on the first load
  // instruction out of reset.
  always @(posedge clk_dc3 or negedge reset_n)
    if (!reset_n)
      dcu_lf_way_dc3 <= 2'b00;
    else if (enable_dc3)
      dcu_lf_way_dc3 <= next_dcu_lf_way_dc3;


  //---------------------------------------------------------------------------
  // DC3
  //---------------------------------------------------------------------------
  // DC3 performs the following functions:
  // - Puts stores and CP ops to be broadcast into the STB
  // - Makes linefill and non-cacheable requests to the BIU
  // - Indicates to the DPU when an instruction is complete and can retire,
  //   and provides instruction information required back to DPU
  // - Returns load data to the DPU
  // - Has interface to TLB/IFU/CP15/Governor blocks for controlling CP ops

  // Generic enable term used to clock gate various DC3 registers.
  assign reg_en_dc3 = enable_dc3 | stall_dc3;

  // DC3 valid and not aborted
  // - Watchpoints normally count as an abort, except on subsequent beats of
  // stores, where the DCU needs to make a final request to the STB with the
  // length set to 0 and no strobes set, to inform the STB that the burst is
  // finishing.
  assign no_abort_dc3   = ~(abort_dc3 | dcu_ecc_err_dc3 |
                            (watchpoint_dc3 & (first_dc3 | load_dc3)));

  assign valid_nabt_dc3 = valid_dc3 & no_abort_dc3;


  //--------------------
  // Instruction decode
  //--------------------

  // CP op types
  // - Unqualified (need to be qualified with cp_inst_dc3 where used)
  assign cp_is_v2p_dc3              = `CA53_CPOP_IS_V2P(cp_op_dc3);
  assign cp_is_tlb_maint_dc3        = `CA53_CPOP_IS_TLBM(cp_op_dc3);
  assign cp_is_dc_maint_dc3         = `CA53_CPOP_IS_DCM(cp_op_dc3);
  assign cp_is_ifu_maint_dc3        = `CA53_CPOP_IS_ICM(cp_op_dc3);
  assign cp_is_bp_maint_dc3         = `CA53_CPOP_IS_BPM(cp_op_dc3);
  assign cp_is_dc_debug_dc3         = `CA53_CPOP_IS_CDBG_DC(cp_op_dc3);
  assign cp_is_gic_dc3              = `CA53_CPOP_IS_GIC(cp_op_dc3);
  assign cp_is_tlb_debug_dc3        = `CA53_CPOP_IS_CDBG_TLB(cp_op_dc3);
  assign cp_is_ic_debug_dc3         = `CA53_CPOP_IS_CDBG_IC(cp_op_dc3); // CDBGIC*

  // - Qualified with cp_inst_dc3
  assign cp_debug_op_dc3            = cp_inst_dc3 & `CA53_CPOP_IS_CDBG(cp_op_dc3);
  assign cp_dc_debug_op_dc3         = cp_inst_dc3 & cp_is_dc_debug_dc3; // DCU debug ops
  assign cp_dc_ic_debug_op_dc3      = cp_inst_dc3 & (cp_is_dc_debug_dc3 | cp_is_ic_debug_dc3);
  assign dcu_needs_dvm_intf_dc3     = cp_inst_dc3 & (cp_is_tlb_debug_dc3 | cp_is_ic_debug_dc3); // IFU/TLB debug ops sent over DVM interface
  assign clrex_dc3                  = cp_inst_dc3 & `CA53_CPOP_IS_CLREX(cp_op_dc3);

  // - Barriers
  assign dxb_dc3       = cp_inst_dc3 & `CA53_CPOP_IS_BAR(cp_op_dc3) & ~`CA53_CPOP_IS_DMBLD(cp_op_dc3); // Barrier space but no DMBLD
  assign dsb_dc3       = cp_inst_dc3 & `CA53_CPOP_IS_DSB(cp_op_dc3);
  assign dmb_dc3       = cp_inst_dc3 & `CA53_CPOP_IS_DMB(cp_op_dc3) & ~`CA53_CPOP_IS_DMBLD(cp_op_dc3);
  assign dmbld_dc3     = cp_inst_dc3 & `CA53_CPOP_IS_DMBLD(cp_op_dc3); // DMB Load-Load/Store only
  assign dmbst_dc3     = dxb_dc3 & ~cp_op_dc3[2];  // For barriers, bit[2] is Full/nST - as there is no DSBST, can just decode DxBST
  assign dmb_full_dc3  = dmb_dc3 & cp_op_dc3[2];   // [2] => Full DMB

  // Properties encoded on cp_op bus
  // - Note store_dc3 pipelined in separate register, to improve timing
  assign gov_mem_access_dc3 = ~cp_inst_dc3 & cp_op_dc3[BIT_MEM_MAP];
  assign neon_dc3           = ~cp_inst_dc3 & cp_op_dc3[BIT_NEON];
  assign pldw_dc3           = ~cp_inst_dc3 & cp_op_dc3[BIT_STORE] & cp_op_dc3[BIT_PLD];
  assign pld_dc3            = ~cp_inst_dc3 & cp_op_dc3[BIT_PLD];
  assign pldl2_dc3          = ~cp_inst_dc3 & cp_op_dc3[BIT_PLD_L2];
  assign excl_dc3           = ~cp_inst_dc3 & cp_op_dc3[BIT_EXCL];

  // Compose the physical address
  assign dcu_pa_dc3 = {upper_pa_dc3,
                       va_dc3[11:0]};

  // Decode memory attributes of accesses in DC3
  assign normal_dc3           = `CA53_MEM_NORMAL(attrs_dc3);
  assign cacheable_dc3        = `CA53_MEM_COHERENT(attrs_dc3);
  assign cacheable_ntrans_dc3 = `CA53_MEM_COHERENT(attrs_dc3) & ~((`CA53_MEM_TRANSIENT(attrs_dc3) | ~`CA53_MEM_WBRA(attrs_dc3)) &
                                                                  ~(excl_dc3 | pld_dc3 | dpu_disable_no_allocate_i));
  assign shareable_dc3        = `CA53_MEM_SHAREABLE(attrs_dc3);

  // Valid load instruction
  assign dcu_load_dc3   = valid_dc3 & load_dc3;

  // If to non-shareable memory, then LDREX and STREX are treated as a normal
  // load or store respectively
  assign dcu_excl_shareable_dc3 = excl_dc3 & shareable_dc3;

  // Access to governor registers
  // - Either CP15 or memory mapped
  assign gov_op_dc3 = (cp_inst_dc3 & `CA53_CPOP_IS_GOV(cp_op_dc3)) | gov_mem_access_dc3;


  //-------------
  // Stall logic
  //-------------
  // Stall in DC3 if
  // - the DPU has not yet committed the transaction
  // - the DCU has not yet completed the transaction
  assign stall_dc3 = valid_dc3 & ~(dpu_ready_wr_i & (dcu_valid_dc3 | dpu_cc_fail_wr_i));


  //----------------
  // Store requests
  //----------------
  // Store instructions, broadcast CP ops and set/way cache maintenance
  // instructions enter the STB from DC3.
  assign broadcast_cp15_dc3 = dcu_valid_dc3 & cp15_needs_broadcast_dc3;  // Operation done locally and ready to retire

  // Assert store request once instruction which must enter STB has been
  // committed by the DPU and hold the request until the STB has accepted the
  // transaction (i.e. mergeable slot or valid slot becomes free - DC3 will
  // stall until then).
  assign dcu_stb_req_dc3 = dpu_ready_cc_pass_wr_i & valid_nabt_dc3 &
                           ( // Committed write/CP15 to broadcast/DMB/DSB
                             (store_dc3 | broadcast_cp15_dc3 | dxb_dc3) &
                             // Not a memory mapped access to governor
                             ~gov_mem_access_dc3 &
                             // A watchpoint for mergeable memory should suppress the request
                             ~(watchpoint_dc3 & `CA53_MEM_MERGEABLE(attrs_dc3)) &
                             // DSB/STREX not sent & STREX passed local monitor
                             ~store_sent_dc3 & ~strex_monitor_failed_dc3);

  assign dcu_stb_req_dc3_o = dcu_stb_req_dc3;

  // Most stores retire as they enter the STB, however DSBs and STREXs remain
  // in DC3, and so need to suppress their stb_req.
  assign next_store_sent_dc3 = stall_dc3 & ~gov_mem_access_dc3 &  // Stores to governor do not go through STB
                               ((dcu_excl_shareable_dc3 & store_dc3 & ~strex_monitor_failed_dc3) | dsb_dc3) &
                               (store_sent_dc3 | (dpu_ready_wr_i & stb_not_full));

  always @(posedge clk_dc3)
    if (reg_en_dc3)
      store_sent_dc3 <= next_store_sent_dc3;

  // Indicate when there are certain types of CP15 operation which may be
  // broadcast.
  assign dcu_store_dmb_dc3_o   = dmb_dc3;
  assign dcu_store_dsb_dc3_o   = dsb_dc3;
  assign dcu_store_cp15_dc3_o  = ~store_dc3;
  assign dcu_stlr_dc3_o        = ldar_stlr_dc3 & store_dc3;

  // Indicate to the STB when a CP operation will require that a DVM Sync is
  // issued on the next DSB.
  assign dcu_dvm_sync_needed_dc3_o = cp_is_tlb_maint_dc3 | cp_is_bp_maint_dc3 | cp_is_ifu_maint_dc3;

  // Only shareable exclusives are marked as exclusive to the STB.
  assign dcu_stb_exclusive_dc3_o = excl_dc3 & shareable_dc3 & store_dc3;

  // Mark the following transactions as non-mergeable to the STB:
  // - CP Ops
  // - Shareable STREX
  // - Any store with an attribute mismatch
  assign instr_non_mergeable_dc3 = cp_inst_dc3 |
                                   (store_dc3 & excl_dc3 & shareable_dc3) |
                                   (store_dc3 & ldar_stlr_dc3) |
                                   attr_mismatch_dc3 |
                                   stb_force_non_mergeable_dc3;

  // - early version of force_non_mergeable without dpu_ready_wr factored in
  // for use in DC2 (on signals which are only used when DC2 is not stalled,
  // which implies that an instruction is retiring DC3 and so dpu_ready_wr
  // must be asserted).
  assign force_non_mergeable_early_dc3 = valid_dc3 & instr_non_mergeable_dc3 &  // Valid, non-mergeable instruction
                                         ~dpu_cc_fail_wr_i & ~dpu_kill_wr_i &   // Not CC failed or killed
                                         ~store_sent_dc3;                       // Suppress after sent DSB/STREX

  assign dcu_force_non_mergeable_dc3_o = force_non_mergeable_early_dc3 & dpu_ready_wr_i;

  // Indicate when there is an operation in DC3 which may require an STB
  // slot. The STB can use this to decide how many slots to start to drain.
  assign dcu_store_dc3_o  = valid_dc3 & ~store_sent_dc3 & // Suppress once STREX/DSB put into STB
                            (store_dc3 | (cp_inst_dc3 & ~cp_op_dc3[8] & cp_op_dc3[6] & ~`CA53_CPOP_IS_DMBLD(cp_op_dc3)));

  // Convert the shareability of the barrier for an STLR to match the
  // shareability of the store (only for cacheable memory - non-cacheable uses
  // DMBSY, which is what the DPU provides). Note the shareability is stored in
  // the attributes in a different format than is used for barriers, so it needs
  // to be converted.
  always @*
    case (attrs_dc3[1:0])
      2'b00   : ldar_stlr_barrier_type_dc3 = 2'b00;  // Non-shareable
      2'b10   : ldar_stlr_barrier_type_dc3 = 2'b10;  // Outer shareable
      2'b11   : ldar_stlr_barrier_type_dc3 = 2'b01;  // Inner shareable
      default : ldar_stlr_barrier_type_dc3 = 2'bxx;
    endcase

  // For stores, the strobes sent to the STB need to be consistent with
  // the amount of data valid. This will normally match the strobes
  // provided by the DPU, except on watchpoints where the strobes are
  // forced to be all zero, as the DCU may need to make a final request
  // to the STB to terminate a burst.
  // For CP ops, the strobes are reused to convey the operation type and
  // VMID for the operation.
  assign cp_inst_strobe_dc3 = {tlb_vmid_i,       // [15:8]   VMID (for TLB/BP DVM)
                               cp_op_dc3[7:2],   // [7:0]    Operation (cp_op is encoded to be allow bit-slice to be used)
                               ((ldar_stlr_dc3 & cp_inst_dc3 & cacheable_dc3) ?  ldar_stlr_barrier_type_dc3
                                                                              : cp_op_dc3[1:0])};

  assign dcu_store_bls_dc3_o = ({16{cp_inst_dc3}}                     & cp_inst_strobe_dc3) |
                               ({16{~(watchpoint_dc3 | cp_inst_dc3)}} & strobe_dc3);   // Suppress strobes on watchpoint

  // The attributes passed to the STB depend on the type of operation being
  // passed:
  // - For stores the attributes need to be for the store in DC3.
  // - For CP15 operations being broadcast, the attributes are ignored on all
  //   other than DC*MVA ops. For those, the attributes should always
  //   indicate the shareability of the instruction, Inner WB Cacheable, and
  //   either Outer WB Cacheable (on PoC ops), or Outer NC (on PoU ops).
  assign dcu_stb_attrs_dc3_o = cp_is_dc_maint_dc3 ? {(cp_op_dc3[3] ? 6'b101111   // - WB/WB (on DC*MVA bit[3] indicates PoC operation)
                                                                   : 6'b011101), // - WB/NC
                                                     attrs_dc3[1:0]}             // - Shareability preserved
                                                  : attrs_dc3;                   // Store

  // Stores to normal memory or cacheable loads always marked as privileged,
  // unless it is a shareable non-cacheable STREX.
  assign dcu_priv_dc3_o   = valid_dc3 & (priv_dc3 |
                                         (store_dc3 & normal_dc3 & ~(dcu_excl_shareable_dc3 & ~cacheable_dc3)) |
                                         (load_dc3 & cacheable_dc3));

  // Indicate last on watchpoint as will stop sending beats (and DPU will
  // subsequently sent a kill)
  assign dcu_store_last_dc3_o = ((length_dc3[3:2] == 2'b00) & ((dcu_size_dc3 == `CA53_SIZE_DWORD) | (length_dc3[1] == 1'b0))) |
                                watchpoint_dc3;

  // Send the attributes to other blocks
  // - Note this signal is shared with the BIU interface
  assign dcu_attrs_dc3_o = attrs_dc3;

  // Indicate size - shared with BIU interface
  assign dcu_size_dc3_o  = dcu_size_dc3;


  //---------------
  // Load requests
  //---------------
  // The DCU makes linefill requests using dcu_lf_req and non-cacheable load
  // requests using dcu_biu_req for loads from DC3 which did not get all
  // their data from the dcache, STB or BIU.

  // Determine when a load has got all its data
  assign load_strobe_dc3 = strobe_dc3[15:8] | strobe_dc3[7:0];

  assign load_done_dc3  = ((data_mask_dc3 & load_strobe_dc3) == load_strobe_dc3);

  // Make a linefill request for a load or PLD if cacheable and cache on
  assign dcu_lf_req_dc3 = valid_nabt_dc3 & load_dc3 & ~pldl2_dc3 &
                          ~dpu_ready_cc_fail_wr_i & ~load_done_dc3 & cacheable_ntrans_dc3;

  assign dcu_lf_way_dc3_o = dcu_lf_way_dc3;

  // L2 linefill requests for PLDL2
  assign pld_l2_req_dc3 = valid_nabt_dc3 & pldl2_dc3 &
                          cacheable_dc3 & ~load_done_dc3;

  // Make a non-cacheable request if not cacheable or cache off
  // - A non-gathering device load must wait for the STB and BIU to drain of
  //   earlier non-gathering device stores before making a load request.
  // - A non-cacheable LDREX must wait for the STB to drain, as it will not
  //   forward data from the STB (to ensure it goes external)
  // - Memory mapped accesses to the governor do not go through the BIU
  assign dcu_biu_req_dc3 = valid_nabt_dc3 & dpu_ready_cc_pass_wr_i & load_dc3 & ~load_done_dc3 &
                           ~(`CA53_MEM_DEVICE_nG(attrs_dc3) & (|stb_slots_dev_ng_i)) &
                           ~(dcu_excl_shareable_dc3 & ~stb_empty) &
                           ~(cacheable_ntrans_dc3 | pld_dc3 | gov_mem_access_dc3);

  assign dcu_biu_req_dc3_o      = dcu_biu_req_dc3;
  assign dcu_lf_req_dc3_o       = dcu_lf_req_dc3;
  assign dcu_pldw_dc3_o         = pldw_dc3;
  assign dcu_pld_l2_req_dc3_o   = pld_l2_req_dc3;
  assign dcu_load_dc3_o         = dcu_load_dc3;
  assign dcu_ns_dsc_dc3_o       = ns_dsc_dc3;
  assign dcu_pa_dc3_o           = dcu_pa_dc3;
  assign dcu_length_dc3_o       = length_dc3;
  assign dcu_neon_access_dc3_o  = neon_dc3;

  // Only shareable exclusives are indicated as being exclusive to the BIU.
  assign dcu_exclusive_dc3_o = dcu_excl_shareable_dc3;


  //-----------
  // Load data
  //-----------
  // The DC3 load data register is where data is returned to the DPU from.
  // Data can be provided from the STB, BIU, dcache, the TLB (on CP register
  // reads) and the DC2 skid buffer. Only the BIU can provide data for a load
  // stalled in DC3.

  // Track which bytes of the data register have been loaded
  // - When moving from DC2 will load any bytes already loaded in DC2, and
  // any new bytes being provided to DC2 on that cycle.
  // - Set the data mask when a PLD L2 is accepted to track that it has been
  // accepted.
  assign new_data_mask_dc3 = {8{biu_read_data_valid_dc3_i}}    |
                             {8{pldl2_dc3 & biu_pld_l2_ready}} |
                             data_mask_dc3;

  // Register data and mask in DC3 if stalled, otherwise get from DC2
  assign next_data_mask_dc3 = stall_dc3 ? new_data_mask_dc3 : new_data_mask_dc2;

  always @(posedge clk_dc3)
    if (reg_en_dc3)
      data_mask_dc3 <= next_data_mask_dc3;

  // Mux between sources of load data
  // - It is necessary to use the fully qualified stb_hit_mergeable_dc2 for
  // the STB mux enable term, instead of the raw signal from the STB, as there
  // could be a non-gathering device multiple in DC2 with an address match on
  // normal or device GRE data in the STB (which won't forward, because of the
  // attribute mismatch), and the multiple will instead get the data from AXI.
  // This is not necessary for the dcache, BIU DC2 or data_dc2 mux enables, as
  // if the data can come from any of those sources it could also come from the
  // STB, so using the unqualified STB input is fine.
  assign ld_data_dc_en_dc3      = {8{dcu_load_dc2 & ~stall_dc3 & ~biu_read_data_valid_dc2_i & dcache_hit_enable_dc2}} & ~stb_hit_dc2_i & ~data_mask_dc2;
  assign ld_data_biu_dc2_en_dc3 = {8{dcu_load_dc2 & ~stall_dc3 &  biu_read_data_valid_dc2_i}}                         & ~stb_hit_dc2_i & ~data_mask_dc2;
  assign ld_data_stb_en_dc3     = {8{dcu_load_dc2 & ~stall_dc3}} & stb_hit_mergeable_dc2;
  assign ld_data_dc2_en_dc3     = {8{~stall_dc3 & ~force_reset_i}} & data_mask_dc2 & ~stb_hit_dc2_i;
  assign ld_data_tlb_en_dc3     = {8{dcu_cp_read_dc2 & ~stall_dc3}};
  assign ld_data_biu_dc3_en_dc3 = {8{stall_dc3 & biu_read_data_valid_dc3_i}} & ~data_mask_dc3;

  generate for (dc3_byte=0; dc3_byte<8; dc3_byte=dc3_byte+1) begin: g_next_data_dc3
    assign next_data_dc3[dc3_byte*8 +: 8] = ({8{ld_data_dc_en_dc3[dc3_byte]}}      & dc_load_data_m2_i[dc3_byte*8 +: 8])      |
                                            ({8{ld_data_stb_en_dc3[dc3_byte]}}     & stb_data_dc2_i[dc3_byte*8 +: 8])         |
                                            ({8{ld_data_biu_dc2_en_dc3[dc3_byte]}} & biu_read_data_dc2_i[dc3_byte*8 +: 8])    |
                                            ({8{ld_data_dc2_en_dc3[dc3_byte]}}     & data_dc2[dc3_byte*8 +: 8])               |
                                            ({8{ld_data_tlb_en_dc3[dc3_byte]}}     & tlb_cp_read_data_dc2_i[dc3_byte*8 +: 8]) |
                                            ({8{ld_data_biu_dc3_en_dc3[dc3_byte]}} & biu_read_data_dc3_i[dc3_byte*8 +: 8])    |
                                            ({8{gov_cp_ack_reg}}                   & gov_cp_data_dc3[dc3_byte*8 +: 8]);
  end endgenerate

  // Register enable
  // - Clock valid data from DC2 when not stalling in DC3, otherwise get from AXI
  // Update only the bytes that are loaded this cycle
  // This enables data from 2nd cross_64 transaction to be merged with the first
  // - The register is enabled on the first cycle after reset to synchonously
  // reset it, to prevent X-propagation into the DPU, as the load data
  // factors into the AGU forwarding paths.
  assign data_en_dc3 = stall_dc3 ? (load_strobe_dc3 &
                                    (({8{load_dc3 & biu_read_data_valid_dc3_i}} & ~data_mask_dc3) |
                                     {8{gov_op_dc3 & ~raw_store_dc3 & gov_cp_ack_reg}}))
                                 : {8{force_reset_i}} |
                                   ({8{~pld_dc2}} &
                                    ({8{dcu_cp_read_dc2}} |
                                     ({8{dcu_load_dc2}} & load_strobe_dc2 &
                                      ({8{dcache_hit_enable_dc2}} |
                                       stb_hit_mergeable_dc2 |
                                       {8{biu_read_data_valid_dc2_i}} |
                                       data_mask_dc2))));

  // Data output register
  always @(posedge clk_dc3)
    begin
      if (data_en_dc3[7])
        data_dc3[63:56] <= next_data_dc3[63:56];
      if (data_en_dc3[6])
        data_dc3[55:48] <= next_data_dc3[55:48];
      if (data_en_dc3[5])
        data_dc3[47:40] <= next_data_dc3[47:40];
      if (data_en_dc3[4])
        data_dc3[39:32] <= next_data_dc3[39:32];
      if (data_en_dc3[3])
        data_dc3[31:24] <= next_data_dc3[31:24];
      if (data_en_dc3[2])
        data_dc3[23:16] <= next_data_dc3[23:16];
      if (data_en_dc3[1])
        data_dc3[15:8]  <= next_data_dc3[15:8];
      if (data_en_dc3[0])
        data_dc3[7:0]   <= next_data_dc3[7:0];
    end

  // Send data to DPU
  assign dcu_ld_data_dc3_o = data_dc3;


  //--------
  // Aborts
  //--------
  // Aborts in DC3 can when moving a new instruction into DC3 can be set by
  // outstanding aborts in DC2, or new aborts being raised in DC2 on that
  // cycle. Once stalled in DC3, new aborts can only be caused by an abort
  // being indicated on AXI read data, or on a shareable non-cacheabe STREX
  // (since these stall in DC3 until the store is complete, any external fault
  // can be reported precisely).
  // - Note if a STREX gets an OK instead of an EXOK response, this will cause
  // the STREX to fail but does not cause an abort.

  // AXI read data aborts when stalled in DC3
  // - Abort only taken if aborting data will be used
  assign new_biu_abort_dc3 = dcu_load_dc3 & |(load_strobe_dc3 & ~data_mask_dc3) &
                             biu_read_data_valid_dc3_i & biu_read_abort_dc3_i;

  // AXI read data or STREX response abort in DC3
  assign new_abort_dc3 = new_biu_abort_dc3 | (biu_strex_bresp_valid_i & biu_strex_bresp_i[1]);

  // Abort type in DC3
  assign biu_fault_dc3 = ({7{biu_read_fault_dc3_i == 2'b11}}  & `CA53_FAULT_LPAE_LDREX)   |
                         ({7{biu_read_fault_dc3_i == 2'b10}}  & `CA53_FAULT_LPAE_ECC)     |
                         ({7{biu_read_fault_dc3_i == 2'b01}}  & `CA53_FAULT_LPAE_EXT_DEC) |
                         ({7{biu_read_fault_dc3_i == 2'b00}}  & `CA53_FAULT_LPAE_EXT_SLV);

  assign new_fault_dc3 = ({7{new_biu_abort_dc3}}                                & biu_fault_dc3)            |
                         ({7{biu_strex_bresp_valid_i &  biu_strex_bresp_i[0]}}  & `CA53_FAULT_LPAE_EXT_DEC) |
                         ({7{biu_strex_bresp_valid_i & ~biu_strex_bresp_i[0]}}  & `CA53_FAULT_LPAE_EXT_SLV);

  // Select DC2 abort when moving instruction into DC3, otherwise use DC3
  // abort.
  assign next_abort_dc3 = enable_dc3 ? (|new_abort_dc2)                                           : (new_abort_dc3 | abort_dc3);
  assign next_fault_dc3 = enable_dc3 ? ((|abort_dc2 | v2p_abort_dc2) ? fault_dc2 : new_fault_dc2) : new_fault_dc3;

  // Enable fault flops when there is an abort
  // (abort_dc3 is too small for its own clock gate, so uses generic enable)
  assign fault_dc3_en = (enable_dc3 & (|new_abort_dc2 | v2p_abort_dc2)) | (stall_dc3 & ~abort_dc3 & new_abort_dc3);

  always @(posedge clk_dc3)
    if (reg_en_dc3)
      abort_dc3 <= next_abort_dc3;

  always @(posedge clk_dc3)
    if (fault_dc3_en)
      fault_dc3 <= next_fault_dc3;

  // Return abort and fault information to DPU
  assign dcu_p_abort_dc3_o        = valid_dc3 & abort_dc3 & ~pld_dc3;
  assign dcu_p_direction_dc3_o    = ~load_dc3;
  assign dcu_p_fault_dc3_o        = fault_dc3;
  assign dcu_p_domain_dc3_o       = domain_dc3;
  assign dcu_p_fault_stage_dc3_o  = fault_stage_dc3;


  //-------------
  // Watchpoints
  //-------------
  // Watchpoints are always returned to the DPU as soon as they are seen. If
  // there is a watchpoint part way through a burst (either a multiple or x64),
  // then:
  // - For loads, the DCU stops sending requests to the BIU immediately and
  // returns the watchpoint to the DPU. This will cause a dpu_kill on the next
  // cycle, which will terminate the burst in the BIU
  // - For stores, the DCU makes a final request to the STB with the length
  // forced to 0 and all the strobes clear, to indicate that the burst is
  // terminating.
  assign dcu_wpt_hit_dc3_o = watchpoint_dc3;


  //--------
  // ECC Errors
  //--------
generate if (CPU_CACHE_PROTECTION) begin : g_ecc_err_dc3
  // If a load does not stall in DC2, then its first cycle in DC3 will
  // correspond to M3 in the cache arbiter pipeline, when ECC error information
  // is available.

  assign load_m3_dc3 = load_dc3 & cacheable_dc3 & ~seen_load_m3_dc3;

  assign next_seen_load_m3_dc3 = enable_dc3 ? (seen_load_m3_dc2 | load_m3_dc2) : 1'b1; // Only time wont have seen is on first cycle in DC3
  assign next_ecc_err_dc3      = enable_dc3 ? dcu_ecc_err_dc2                  : ((load_m3_dc3 & dc_ecc_err_m3_i) | ecc_err_dc3);

  always @(posedge clk_dc3)
    if (reg_en_dc3) begin
      seen_load_m3_dc3 <= next_seen_load_m3_dc3;
      ecc_err_dc3      <= next_ecc_err_dc3;
    end

  assign dcu_ecc_err_dc3 = (load_m3_dc3 & dc_ecc_err_m3_i) | ecc_err_dc3;

end else begin : g_ecc_err_dc3_no_ecc
  assign dcu_ecc_err_dc3 = 1'b0; // Used by complete_exception logic so must be valid when no ECC
end endgenerate

  assign dcu_ecc_err_dc3_o = dcu_ecc_err_dc3;


  //-----------------------
  // Dcache/TLB/IFU CP ops
  //-----------------------
  // Dcache, TLB and IFU debug ops access the relevant block from DC3 to
  // complete their operation. The rest of the operations will broadcast so they
  // stall in DC3 until they can enter the STB.

  // Dcache debug ops
  // The lspipe tells the CP15 to start when the instruction has been committed in
  // DC3, and continues to do so until it completes.
  assign dc_cp15_start_dc3_o = valid_nabt_dc3 & ~cc_fail_or_flush_dc3 &
                               cp_dc_debug_op_dc3 &
                               dpu_ready_wr_i &
                               ~dcu_valid_dc3 & ~cp15_done_dc3;

  // - Form the address to send to the CP15 block (masked to zero when no debug
  // to prevent toggling)
  assign dc_cp15_addr_dc3_o = {11{cp_inst_dc3 & cp_is_dc_debug_dc3}} & dpu_cp_data_wr_i[13:3];
  assign dc_cp15_way_dc3_o  =  {2{cp_inst_dc3 & cp_is_dc_debug_dc3}} & dpu_cp_data_wr_i[31:30];

  // - Indicate the type of Debug CP op (tag or data) to the CP15 block
  assign dc_cp15_op_data_dc3_o = cp_op_dc3[0];

  // TLB/IFU CP ops

  // - The CP interface to the TLB/IFU is shared between DC3 and DVM
  // operations. DC3 has priority for the interface whenever there is
  // a TLB/IFU cp op in DC3 and the operation has not completed.
  assign block_dvm_dc3 = valid_dc3 & dcu_needs_dvm_intf_dc3 & ~cp15_done_dc3;
  assign block_dvm_dc3_o = block_dvm_dc3;

  // - Detect when there is a valid CP15 which has not completed locally
  // yet (an op can continue to stall in DC3 after completing if it is
  // waiting to be broadcast, but the TLB/IFU do not need to be aware of
  // this).
  assign dcu_cp_valid = valid_nabt_dc3 & ~dcu_valid_dc3 &
                        dpu_ready_cc_pass_wr_i &
                        cp_inst_dc3 & ~cp15_done_dc3;

  // - Indicate to TLB/IFU that the DCU has a CP op for it
  // - Note that the request to the TLB/IFU needs to factor dpu_kill_wr in, but
  // as this would be a critical signal into dcu_cp_valid_ifu it is factored
  // in inside the IFU. The signal to the TLB is less critical so it is
  // factored in here.
  assign dcu_cp_valid_ifu_o = dcu_cp_valid & cp_is_ic_debug_dc3; // NB - dvm_valid sent separately to IFU
  assign dcu_cp_valid_tlb_o = (dcu_cp_valid & ~dpu_kill_wr_i & cp_is_tlb_debug_dc3) | dcu_dvm_valid_tlb_i;

  // - Form the opcode to send to the IFU
  assign dcu_cp_op_ifu_o = block_dvm_dc3  ? cp_op_dc3[2:0]    // Local op encoding matches cp_op[2:0]
                                          : dvm_ifu_cp_op_i;  // Use DVM opcode for forwarded ops

  // - Form the opcode to send to the TLB
  assign dcu_cp_op_tlb_o = block_dvm_dc3  ? `CA53_CP_TLB_DBG   // Local TLB operation can only be the Debug op CDBGTD
                                          : dvm_tlb_cp_op_i;   // Use DVM opcode for forwarded ops

  assign dcu_cp_addr = mbist_en_i    ? {27'h0000000, mbist_ctl_data_mb3_i} :
                       block_dvm_dc3 ? {9'b000000000, dpu_cp_data_wr_i[63:48], dpu_cp_data_wr_i[36:0]} :
                                       dvm_cp_addr_i;

  assign dcu_cp_addr_tlb_o = dcu_cp_addr;

  assign dcu_cp_addr_ifu_o = dcu_cp_addr[39:0];

  assign dcu_cp_ns_o =  block_dvm_dc3 ? ns_dsc_dc3 : dvm_ns_i;

  // Track when an operation has completed locally
  assign next_cp15_done_dc3 = cp_inst_dc3 & valid_dc3 &
                              ~dcu_valid_dc3 &                                // Clear when operation leaves DC3
                              dpu_ready_cc_pass_wr_i & ~dpu_kill_wr_i &       // Set when operation completes
                              (((cp_is_ic_debug_dc3 | cp_is_tlb_debug_dc3) &  // - need to qualify to prevent being set on DVM operations
                                (ifu_cp_ack_i | tlb_cp_ack_i)) |              // - but TLB and IFU both block DVM, so no need to qualify each with correct type
                               dc_cp15_ack_i |
                               cp15_done_dc3);                                // Maintain until retire

  always @(posedge clk_dc3 or negedge reset_n)
    if (!reset_n)
      cp15_done_dc3 <= 1'b0;
    else if (reg_en_dc3)
      cp15_done_dc3 <= next_cp15_done_dc3;


  //--------------------
  // Governor interface
  //--------------------

  // Requests to governor
  // - Needs to be registered
  assign next_gov_req_dc3 = valid_nabt_dc3 & dpu_ready_cc_pass_wr_i & ~dpu_kill_wr_i &
                            gov_op_dc3 &
                            ~gov_cp_ack_reg & ~dcu_valid_dc3; // Suppress once get ack until instruction retired

  always @(posedge clk_rare or negedge reset_n)
    if (!reset_n)
      gov_req_dc3 <= 1'b0;
    else
      gov_req_dc3 <= next_gov_req_dc3;

  assign dcu_cp_gov_req_o = gov_req_dc3;

  // Ack and data need to be registered to decouple timing from governor
  always @(posedge clk_rare or negedge reset_n)
    if (!reset_n)
      gov_cp_ack_reg <= 1'b0;
    else
      gov_cp_ack_reg <= gov_cp_ack_i;

  // Read data from governor must be registered, as must write data sent
  // to the governor. The same flops can be used for this, because can
  // never read and write at same time.
  // - The GIC will align the 32-bit read data for a memory mapped access
  // to the correct half of the 64-bit bus based on the address alignment.
  // - The GIC will select between the upper and lower 32-bits of the 64-bit
  // write data based on the address alignment for memory mapped acceses
  // - However the DCU must select the correct half of the 128-bit store
  // data to send to the governor.
  // - On CP15 mapped accesses, the store data contains the data for the
  // register being stored, so do not need to mux that separately
  assign next_gov_cp_data_dc3 = raw_store_dc3 ? ((gov_mem_access_dc3 & dcu_pa_dc3[3]) ? dpu_st_data_wr_i[127:64]  // Memory mapped store to upper Dword
                                                                                      : dpu_st_data_wr_i[63:0])   // Lower Dword/CP15 mapped
                                              : gov_cp_rdata_i;

  // - Although do not generally use governor signals directly, it is
  // possible to use the ack signal directly to enable to data register.
  assign gov_cp_data_en_dc3 = valid_dc3 & dpu_ready_cc_pass_wr_i & gov_op_dc3 &
                              // Register on cycle before make request for writes and on ack for reads
                              // - will register on both regardless of write/read
                              (~gov_req_dc3 | gov_cp_ack_i);

  always @(posedge clk_rare)
    if (gov_cp_data_en_dc3)
      gov_cp_data_dc3 <= next_gov_cp_data_dc3;

  // Indicate to governor where to route request to
  assign next_gov_sel_dc3   = gov_mem_access_dc3  ? `CA53_GIC_DCU_MEM : // Memory mapped GIC access
                              cp_is_gic_dc3       ? `CA53_GIC_DCU_SYS : // CP15 mapped GIC access
                                                    cp_op_dc3[7:5];     // CP15 mapped Governor register

  // Indicate the address of the register to access
  assign next_gov_addr_dc3  = gov_mem_access_dc3 ? dcu_pa_dc3[17:0] : {{9{1'b0}}, cp_op_dc3[8:0]};

  // Register data sent to governor when starting request
  assign gov_cp_req_data_en_dc3 = valid_dc3 & dpu_ready_cc_pass_wr_i & gov_op_dc3 & ~gov_req_dc3;

  always @(posedge clk_rare)
    if (gov_cp_req_data_en_dc3) begin
      gov_addr_dc3    <= next_gov_addr_dc3;
      gov_ns_dc3      <= ns_dsc_dc3;  // Ignored if not memory mapped
      gov_sel_dc3     <= next_gov_sel_dc3;
      gov_wenable_dc3 <= raw_store_dc3;
    end

  // Ouputs to governor interface
  assign dcu_cp_gov_addr_o    = gov_addr_dc3;
  assign dcu_cp_gov_ns_o      = gov_ns_dc3;
  assign dcu_cp_gov_sel_o     = gov_sel_dc3;
  assign dcu_cp_gov_wenable_o = gov_wenable_dc3;
  assign dcu_cp_gov_wdata_o   = gov_cp_data_dc3;


  //----------------
  // V2P operations
  //----------------

  // Assemble data to write to PAR for V2P* instructions

  // For VMSA Mode:
  // - PA to write depends on supersection bit
  assign par_vmsa_pa_dc3 = {upper_pa_dc3[31:24],
                            supersection_dc3 ? {upper_pa_dc3[39:32], 4'b0000} :
                                                upper_pa_dc3[23:12]};

  // - Inner memory attributes from the translation table entry
  // The attributes are all zero for NC accesses so there is no term for NC
  assign par_vmsa_inner_dc3 = ({3{`CA53_MEM_COHERENT(attrs_dc3) & ~`CA53_MEM_WBWA(attrs_dc3)}}                              & 3'b111) |
                              ({3{`CA53_MEM_WT(attrs_dc3)}}                                                                 & 3'b110) |
                              ({3{`CA53_MEM_WB(attrs_dc3) & (`CA53_MEM_WBWA(attrs_dc3) | ~`CA53_MEM_COHERENT(attrs_dc3))}}  & 3'b101) |
                              ({3{`CA53_MEM_GRE(attrs_dc3) | `CA53_MEM_nGRE(attrs_dc3) | `CA53_MEM_nGnRE(attrs_dc3)}}       & 3'b011) |
                              ({3{`CA53_MEM_nGnRnE(attrs_dc3)}}                                                             & 3'b001);

  // - Outer memory attributes from the translation table entry
  // Device regions are marked as 2'b00
  // The attributes are all zero for NC accesses so there is no term for NC
  assign par_vmsa_outer_dc3 = ({2{`CA53_MEM_OUTER_WT(attrs_dc3)}} & 2'b10) |
                              ({2{`CA53_MEM_OUTER_WB(attrs_dc3)}} & {~attrs_dc3[2], 1'b1});

  // For LPAE Mode:
  // - Inner and outer attributes use the same format as for the MAIR
  // entries.
  assign par_lpae_inner_attrs_dc3 = ({4{`CA53_MEM_NC(attrs_dc3)}}        & 4'b0100) |
                                    ({4{`CA53_MEM_WB(attrs_dc3) &
                                        ~`CA53_MEM_COHERENT(attrs_dc3)}} & 4'b1111) |
                                    ({4{`CA53_MEM_WB(attrs_dc3) &
                                        `CA53_MEM_COHERENT(attrs_dc3)}}  & {~`CA53_MEM_TRANSIENT(attrs_dc3), 1'b1, attrs_dc3[5:4]}) |
                                    ({4{`CA53_MEM_WT(attrs_dc3)}}        & 4'b1010);

  assign par_lpae_outer_attrs_dc3 = ({4{`CA53_MEM_OUTER_NC(attrs_dc3)}} & 4'b0100)                 |
                                    ({4{`CA53_MEM_OUTER_WT(attrs_dc3)}} & {2'b10, attrs_dc3[3:2]}) |
                                    ({4{`CA53_MEM_OUTER_WB(attrs_dc3)}} & {2'b11, attrs_dc3[3:2]});

  assign par_lpae_attrs_dc3 = ({8{`CA53_MEM_GRE(attrs_dc3)}}    & 8'b00001100) |  // Fixed encoding for GRE
                              ({8{`CA53_MEM_nGRE(attrs_dc3)}}   & 8'b00001000) |  // nGRE
                              ({8{`CA53_MEM_nGnRE(attrs_dc3)}}  & 8'b00000100) |  // nGnRE
                              ({8{`CA53_MEM_nGnRnE(attrs_dc3)}} & 8'b00000000) |  // and nGnRnE
                              ({8{`CA53_MEM_NORMAL(attrs_dc3)}} & {par_lpae_outer_attrs_dc3, par_lpae_inner_attrs_dc3});

  // Format of PAR depends on whether translation fault occurred.
  // If a translation fault occurs on a V2P (and does not trap to the DPU), the
  // F-bit in the PAR is set and no abort is generated.

  // Convert LPAE format faults to VMSA for when VMSA format needed.
  // - Note that the ext bit is valid for both LPAE and VMSA format, so does
  // not need converting. Therefore only the lower six bits of the LPAE fault
  // encoding need to be looked at. Additionally, the PAR is only written
  // with the bottom five bits of FS in VMSA format, and FS[4] is always
  // zero, so only the bottom four bits of the VMSA fault need encoding.
  always @*
    case (fault_dc3)
      `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1: vmsa_fault_dc3 = `CA53_FAULT_VMSA_PAGEWALK_EXT1_DEC;
      `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2: vmsa_fault_dc3 = `CA53_FAULT_VMSA_PAGEWALK_EXT2_DEC;
      `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1: vmsa_fault_dc3 = `CA53_FAULT_VMSA_PAGEWALK_EXT1_SLV;
      `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2: vmsa_fault_dc3 = `CA53_FAULT_VMSA_PAGEWALK_EXT2_SLV;
      `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1: vmsa_fault_dc3 = `CA53_FAULT_VMSA_PAGEWALK_EXT1_ECC;
      `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2: vmsa_fault_dc3 = `CA53_FAULT_VMSA_PAGEWALK_EXT2_ECC;
      `CA53_FAULT_LPAE_TRANSLATION_L1:      vmsa_fault_dc3 = `CA53_FAULT_VMSA_TRANSLATION_SEC;
      `CA53_FAULT_LPAE_TRANSLATION_L2:      vmsa_fault_dc3 = `CA53_FAULT_VMSA_TRANSLATION_PAGE;
      `CA53_FAULT_LPAE_ACCESS_L1:           vmsa_fault_dc3 = `CA53_FAULT_VMSA_ACCESS_SEC;
      `CA53_FAULT_LPAE_ACCESS_L2:           vmsa_fault_dc3 = `CA53_FAULT_VMSA_ACCESS_PAGE;
      `CA53_FAULT_LPAE_ALIGNMENT:           vmsa_fault_dc3 = `CA53_FAULT_VMSA_ALIGNMENT;
      `CA53_FAULT_LPAE_PERMISSION_L1:       vmsa_fault_dc3 = `CA53_FAULT_VMSA_PERMISSION_SEC;
      `CA53_FAULT_LPAE_PERMISSION_L2:       vmsa_fault_dc3 = `CA53_FAULT_VMSA_PERMISSION_PAGE;
      `CA53_FAULT_LPAE_DOMAIN_L1:           vmsa_fault_dc3 = `CA53_FAULT_VMSA_DOMAIN_SEC;
      `CA53_FAULT_LPAE_DOMAIN_L2:           vmsa_fault_dc3 = `CA53_FAULT_VMSA_DOMAIN_PAGE;
      `CA53_FAULT_LPAE_EXT_DEC:             vmsa_fault_dc3 = `CA53_FAULT_VMSA_EXT_DEC;
      `CA53_FAULT_LPAE_EXT_SLV:             vmsa_fault_dc3 = `CA53_FAULT_VMSA_EXT_SLV;
      `CA53_FAULT_LPAE_ECC:                 vmsa_fault_dc3 = `CA53_FAULT_VMSA_ECC;
      `CA53_FAULT_LPAE_LDREX:               vmsa_fault_dc3 = `CA53_FAULT_VMSA_LDREX;
      default:                              vmsa_fault_dc3 = 7'bxxxxxxx;
    endcase

  assign par_vmsa_fault_dc3   = {5'b00000,            // [11:8] == 0
                                 fault_dc3[6],        // [7] is Ext
                                 vmsa_fault_dc3[4:0], // FS[4:0]
                                 1'b1};               // Fault bit

  assign par_lpae_fault_dc3   = {2'b10,               // Fixed for LPAE
                                 fault_stage_dc3,     // Stage of translation causing fault
                                 1'b0,                // Fixed for LPAE
                                 fault_dc3[5:0],      // FS[5:0]
                                 1'b1};

  assign par_vmsa_nofault_dc3 = {{32{1'b0}},          // [63:32]  Unused for VMSA
                                 par_vmsa_pa_dc3,     // [31:12]  PA (bottom bits masked if super section)
                                 1'b0,                // [11]     (0)
                                 attrs_dc3[0],        // [10]     NOS (Not Outer Shareable)
                                 ns_dsc_dc3,          // [9]      nS
                                 1'b0,                // [8]      IMP DEF (unused)
                                 shareable_dc3,       // [7]      SH (shareable)
                                 par_vmsa_inner_dc3,  // [6:4]    Inner attributes, as encoded above
                                 par_vmsa_outer_dc3,  // [3:2]    Outer attributes, as encoded above
                                 supersection_dc3,    // [1]      SS (super section)
                                 1'b0};               // [0]      F (0 as no fault)

  assign par_lpae_nofault_dc3 = {par_lpae_attrs_dc3,  // [63:56]  Memory Attributes
                                 {16{1'b0}},          // [55:40]  UNK/SBZP
                                 upper_pa_dc3,        // [39:12]  PA[39:12]
                                 1'b1,                // [11]     Fixed encoding of 1
                                 1'b0,                // [10]     IMP DEF (unused)
                                 ns_dsc_dc3,          // [9]      nS
                                 attrs_dc3[1:0],      // [8:7]    Shareability (held in attrs in correct format)
                                 6'b000000,           // [6:1]    UNK/SBZP
                                 1'b0};               // [0]      F (0 as no fault)

  assign par_dc3 = v2p_abort_dc3 ? (v2p_lpae_dc3  ? {{52{1'b0}}, par_lpae_fault_dc3}    // LPAE format used for stage 2 VMSA faults
                                                  : {{52{1'b0}}, par_vmsa_fault_dc3})
                                 : (v2p_lpae_dc3  ? par_lpae_nofault_dc3
                                                  : par_vmsa_nofault_dc3);


  //---------------------
  // TLB register writes
  //---------------------

  // Indicate to the TLB when there is a CP15 register write in DC2/3 which
  // might assert dcu_cp_reg_write_dc3 on the next cycle. This is pessimistic
  // in that it may be asserted when there is not going to be a register
  // write on the next cycle.
  // The signal is also asserted when there is an IFU/TLB debug op in DC3, as
  // this could also result in the debug register in the TLB being written,
  // and removes the need for a separate signal from the IFU to the TLB.
  assign dcu_cp_reg_write_active_o = v_enable_dc3 ? (next_valid_dc3 & cp_write_dc2)   // Reg write moving into DC3 (no need to factor debug, as will always stall)
                                                  : (valid_nabt_dc3 & (cp_write_dc3 | // Reg write or debug op in DC3
                                                                       cp_debug_op_dc3));

  // Write the TLB register when a register write is committed
  assign dcu_cp_reg_write_dc3_o = dcu_cp_reg_write_no_exc & dcu_valid_dc3 &
                                  dpu_ready_cc_pass_wr_i & ~flush_dc3;

  // Version without dpu_ready_cc_pass_wr_i, flush_dc3 factored in, for use
  // when blocking the TLB during a CP register write. This must happen even
  // if the instruction is not committed yet.
  assign dcu_cp_reg_write_no_exc = valid_nabt_dc3 & (cp_write_dc3 | (cp_inst_dc3 & cp_is_dc_debug_dc3 & cp15_done_dc3));

  // Indicate the register being written
  // - Force write to PAR for V2P, to data register for dcache debug ops,
  // otherwise use register encoding from cp_op
  assign dcu_cp_reg_en_dc3_o = ({6{(cp_op_dc3[6:3] == 4'b0001)}}                        & `CA53_CP15_V2P_PAR) |     // Force V2P to write PAR
                               ({6{cp_dc_debug_op_dc3}}                                 & `CA53_CP15_REG_CDBGDR0) | // Debug ops indicate DR0
                               ({6{(cp_op_dc3[6:3] != 4'b0001) & ~cp_dc_debug_op_dc3}}  & cp_op_dc3[5:0]);          // Pass through as-is

  // Data to write to register is from DPU unless a V2P instruction or a debug
  // operation
  // - Qualified with cp_inst_dc3 to provide data gating when not in use
  assign dcu_cp_reg_data_o = ({64{cp_inst_dc3 & cp_is_v2p_dc3}}                         & par_dc3)  |
                             ({64{cp_inst_dc3 & cp_is_dc_debug_dc3}}                    & data_dc2) |
                             ({64{cp_inst_dc3 & ~(cp_is_v2p_dc3 | cp_is_dc_debug_dc3)}} & dpu_cp_data_wr_i);

  // Size of write is as indicated by the DPU except on PAR writes, which are
  // always 64-bit.
  assign dcu_cp_reg_size_o = dcu_size_dc3[0] | cp_is_v2p_dc3;


  //------------------------
  // Instruction completion
  //------------------------
  // The DCU completes an instruction by asserting dcu_valid_dc3. Once the
  // instruction is also committed by the DPU, using dpu_ready_wr, the
  // instruction will retire. Note that an instruction can be normally be
  // committed before or after it is completed by the DCU, though some
  // instructions must be committed first.
  //
  // The signal to the DPU is registered to improve timing, so the DCU must
  // decide a cycle in advance whether an instruction will be complete on the
  // next cycle.
  //
  // Instructions can be completed when moving from DC2 into DC3, if they
  // have no work to do in DC3, or, in the case of stores, they are
  // guaranteed to be able to enter the STB on the first cycle they are in
  // DC3.
  //
  // Instructions can also stall in DC3, in which case they will complete
  // from DC3.

  //-------
  // - DC2
  //-------
  // Detect when an instruction moving from DC2 to DC3 can complete

  // Exceptions
  // - Complete any instruction that aborts or hits a watchpoint.
  // - Subsequent beats of a store burst which hit a watchpoint complete
  // as stores, as they need to make a final request to the STB.
  // - Loads which get an external abort still complete as loads rather
  // than exceptions.
  // - Loads which get an ECC error will complete as exceptions, in case
  // the error is in the tag RAM and they miss and so will not set load_done.
  assign complete_exception_dc2 = (|abort_dc2 & ~`CA53_FAULT_EXT(fault_dc2)) |
                                  gov_mem_abort_dc2 | dcu_ecc_err_dc2 |
                                  (watchpoint_dc2 & (~(store_dc2 & ~first_dc2) |  // Watchpoint on non-first store completes as store
                                                     gov_mem_access_dc2));        // - but on governor access always completes as exception

  // Stores/DMBs
  // - Complete store if it can enter the STB on the next cycle.
  // Barriers enter the STB as if they were stores and so are completed in
  // the same way. DSBs always stall in DC3, so only DMBs can be completed
  // from DC2.
  // - Determine whether an STB slot will be available in DC3 for a store
  // moving from DC2 to DC3.
  assign next_slot_avail_dc2 = (|stb_slots_emptying_i) |
                               (|dcu_store_merge_dc2) |
                               (dcu_stb_req_dc3 ? (new_slot_avail |
                                                   ((|new_slot) & (|dcu_store_merge_dc3)))
                                                : stb_not_full);

  assign complete_store_dc2 = (store_dc2 | dmb_dc2) &
                               // Stores to the governor can never complete from DC2
                              ~gov_mem_access_dc2 &
                               // STREX can complete immediately if failed local monitor
                              (strex_monitor_failed_dc2 |
                               // - Room in STB on next cycle
                               (next_slot_avail_dc2 &
                               // - Shareable STREX needs to wait for
                               //   response in DC3, so can't complete from
                               //   DC2
                                ~dcu_excl_shareable_dc2));

  // Loads
  // - Complete load/PLD when it has all its data, or, for a PLD, when its
  // linefill has been accepted.
  // - Loads can complete when they hit in the cache, but the cache hit
  // signal is very late from the RAMs, so loads are completed on a separate
  // signal which factors directly into next_dcu_valid_dc3.

  // - Calculate when a load is getting all its data in DC2 this cycle
  // (excluding cache hits), and so could complete on the next cycle if it is
  // moving to DC3.
  assign next_load_done_dc2 = &(stb_hit_mergeable_dc2 |
                                {8{biu_read_data_valid_dc2_i}} |
                                data_mask_dc2 |
                                ~load_strobe_dc2);

  assign complete_load_dc2 = dcu_load_dc2 &
                             (next_load_done_dc2 |
                              (pld_dc2 & ((pldl2_dc2 ? ((previous_stall_dc2 & biu_pld_l2_ready_dc2) | // Accepted from DC2 on this cycle
                                                        biu_pld_l2_next_ready_i)                      // Will be accepted from DC3 on next cycle
                                                     : biu_lf_ready_dc2_i) |                          // Will be accepted from DC3 on next cycle
                                          ~cacheable_dc2)));                                          // No LF needed
  // TLB register reads/writes
  // - Reads can always complete from DC2, as the TLB can never stall
  // a register read. Writes can complete from DC2 if they can be accepted by
  // the TLB.
  assign complete_cp_reg_dc2 = (cp_write_dc2 & tlb_cp_reg_write_ready_i) |
                               dcu_cp_read_dc2;

  // CLREX/NOP/DMBLD
  // - CP ops do any work required from DC3, so most cannot complete from DC2,
  // however some operations can always complete immediately:
  //   - NOPs do no work and so can always complete straight away
  //   - CLREXs just clear the exclusive monitor which they can always do
  //     immediately
  //   - DMBLDs just stall subsequent loads in DC1, so they do no actual work
  //     themselves
  assign complete_simple_dc2 = cp_inst_dc2 & (`CA53_CPOP_IS_CLREX_NOP(cp_op_dc2) | dmbld_dc2);

  // Any instruction
  // (other than loads which hit in the cache)
  assign complete_dc2 = valid_dc2 &
                        // DC2 not being killed/flushed/CC failing
                        ~cc_fail_or_flush_dc2 &
                        // DC2 not stalled
                        ~stall_dc2 &
                        // Instruction can complete
                        (complete_exception_dc2 |
                         complete_store_dc2 |
                         complete_load_dc2 |
                         complete_cp_reg_dc2 |
                         complete_simple_dc2);

  // Loads hitting in the cache
  assign complete_cache_hit_load_dc2 = dcu_load_dc2 &                               // Implies valid_dc2
                                       ~cc_fail_or_flush_dc2 & ~stall_dc2 &         // Conditions for suppress complete of any instruction in DC2
                                       (dcache_hit_enable_dc2 & dc_load_hit_m2_i);  // Can always complete if hit in cache


  //-------
  // - DC3
  //-------
  // Detect when an instruction stalled in DC3 can complete

  // Exceptions
  // - Complete any instruction that aborts or hits a watchpoint.
  // - Subsequent beats of a store burst which hit a watchpoint complete
  // as stores, as they need to make a final request to the STB.
  // - Loads which get an external abort still complete as loads rather
  // than exceptions.
  // - Loads which get an ECC error will complete as exceptions, in case
  // the error is in the tag RAM and they miss and so will not set load_done.
  assign complete_exception_dc3 = (abort_dc3 & (~`CA53_FAULT_EXT(fault_dc3) | gov_mem_access_dc3)) |
                                  dcu_ecc_err_dc3 |
                                  (watchpoint_dc3 & (~(store_dc3 & ~first_dc3) |  // Watchpoint on non-first store completes as store
                                                     gov_mem_access_dc3));        // - but on governor access always completes as exception

  // Stores/DMBs/BP/DC Ops
  // - Branch Predictor or Data Cache Maintenance CP ops have no local effect,
  // they just enter the STB if they need to be broadcast. Therefore they behave
  //  the same as DMBs and so can complete under the same conditions.
  // - Deterimine when there will be an STB slot available on the next cycle
  assign slot_avail          = stb_not_full | (|dcu_store_merge_dc3);
  assign next_slot_avail_dc3 = slot_avail | (|stb_slots_emptying_i);

  assign complete_store_dc3 = (store_dc3 | dmb_dc3 | (cp_inst_dc3 & (cp_is_bp_maint_dc3 | cp_is_dc_maint_dc3 | cp_is_tlb_maint_dc3 | cp_is_ifu_maint_dc3))) &
                               // Memory mapped accesses to GIC registers via the governor
                               // do not go via the STB and are completed separately
                              ~gov_mem_access_dc3 &
                               // STREX which fails local monitor completes straight away,
                               // otherwise wait for STB to drain.
                              (strex_monitor_failed_dc3 |
                                 // Slot will be available on next cycle
                               (next_slot_avail_dc3 &
                                 // - Shareable STREX needs to wait for
                                 //   response from BIU/STB
                                ~(excl_dc3 & ~(~shareable_dc3 |              // Non-shareable will only use local monitor
                                               stb_cacheable_strex_done_i |
                                               biu_strex_bresp_valid_i))));

  // Loads
  // - Complete load/PLD when it has all its data, or, for a PLD, when its
  // linefill has been accepted.
  // - Calculate when a load will have all its data on the next cycle
  assign next_load_done_dc3 = &({8{biu_read_data_valid_dc3_i}} |    // Done when AXI data available
                                data_mask_dc3 | ~load_strobe_dc3);  // Or when all required data is available

  assign complete_load_dc3 = load_dc3 &
                             (next_load_done_dc3 |
                              (pld_dc3 & ((pldl2_dc3 ? biu_pld_l2_next_ready_i      // LF accepted
                                                     : biu_lf_next_ready_dc3_i)  |
                                          ~cacheable_dc3                         |  // No LF needed
                                          dcu_valid_dc3)));                         // Keep asserted after LF accepted

  // DSBs
  // - DSBs enter the STB from DC3 and wait for the STB to drain all its slots
  // (including that for the DSB, which will be the last slot to drain).
  // - The GIC (via the governor) can delay the completion of DSBs after certain
  // CP ops
  assign complete_dsb_dc3 = dsb_dc3 & store_sent_dc3 & ~|next_slots_valid & ~gov_stall_dsb_rs_i;

  // TLB register reads/writes
  // - Reads can always complete immediately, as the TLB can never stall
  // a register read. TLB writes complete once they can be accepted by the
  // TLB. Note that dcache debug ops behave like TLB register writes after
  // they have completed locally, as they need to write the CDBGDRx registers
  // in the TLB.
  assign complete_cp_reg_dc3 = ((cp_write_dc3 | (cp_inst_dc3 & cp_is_dc_debug_dc3 & cp15_done_dc3)) &
                               tlb_cp_reg_write_ready_i) |
                               cp_read_dc3;

  // Governor accesses
  // - Complete when get ack from governor (registered). This is a one-shot
  // signal from the governor, but since the instruction must have been
  // committed by the DPU before the handshake was started, the instruction
  // will retire as soon as completed by the DCU, so do not need to worry about
  // keeping complete asserted after ack removed.
  assign complete_gov_dc3 = gov_cp_ack_reg;

  // CLREX/NOP/DMBLD
  // - NOPs do no work and so can always complete straight away
  // - CLREXs just clear the exclusive monitor which they can always do
  // immediately
  // - DMBLDs just stall subsequent loads in DC1, so they do no actual work
  // themselves
  assign complete_simple_dc3 = cp_inst_dc3 & (`CA53_CPOP_IS_CLREX_NOP(cp_op_dc3) | dmbld_dc3);

  // CP ops
  // - TLB/IFU/DC CP ops complete once they have completed their local
  // operation and, if required, entered the STB to be broadcast.
  assign complete_cp_op_dc3 = cp_inst_dc3 &
                              (((cp_is_tlb_debug_dc3 | cp_is_ic_debug_dc3) & (tlb_cp_ack_i | ifu_cp_ack_i)) | // TLB/IFU debug completing locally
                               (~cp_is_dc_debug_dc3 & cp15_done_dc3));

  // Any instruction
  assign complete_dc3 = valid_dc3 &
                        // DC3 not being killed
                        ~dpu_kill_wr_i &
                        // DC3 stalled and not being flushed/CC
                        // failing
                        ~(dpu_ready_wr_i ? (dpu_cc_fail_wr_i | dcu_valid_dc3) : dpu_flush_i) &
                        // Instruction can complete
                        (complete_exception_dc3 |
                         complete_store_dc3     |
                         complete_load_dc3      |
                         complete_dsb_dc3       |
                         complete_cp_reg_dc3    |
                         complete_gov_dc3       |
                         complete_simple_dc3    |
                         complete_cp_op_dc3);


  //-----------------
  // - DPU interface
  //-----------------

  // Indicate to the DPU when an instruction is complete
  assign next_dcu_valid_dc3 = complete_dc3 | complete_dc2 | complete_cache_hit_load_dc2;

  always @(posedge clk_dc3 or negedge reset_n)
    if (!reset_n)
      dcu_valid_dc3 <= 1'b0;
    else
      dcu_valid_dc3 <= next_dcu_valid_dc3;

  assign dcu_valid_dc3_o = dcu_valid_dc3;

  // Return attributes about the instruction being completed to the DPU
  // - The instruction is a cache maintenance (DCU or IFU) or V2P operation.
  // Used to set the HSR/ESR.ISS.CM bit in the DPU if there is a fault.
  assign dcu_cm_operation_dc3_o = cp_inst_dc3 & (cp_is_ifu_maint_dc3 |
                                                 cp_is_dc_maint_dc3  |
                                                 cp_is_v2p_dc3       |
                                                 (cp_op_dc3 == `CA53_CPOP_NOP)); // DCCMVAU can abort on translation before being NOP'd,
                                                                                 // and so requires accurate cm_operation

  assign dcu_va_dc3_o           = {({32{dpu_aarch64_state_i}} & va_dc3[63:32]), va_dc3[31:0]};
  assign dcu_v2p_lpae_dc3_o     = v2p_lpae_dc3;
  assign dcu_strex_okay_dc3_o   = ~strex_monitor_failed_dc3; // STREX succeeds if monitor still set when retire


  //---------------------------------------------------------------------------
  // Exclusive monitor
  //---------------------------------------------------------------------------
  // The exclusive monitor is set when a LDREX successfully completes in DC3.
  // If a STREX is attempted to the same address as the exclusive tag and
  // the monitor is set, then the STREX succeeds and is put into the STB,
  // otherwise it fails. Note that a STREX can still fail after passing the
  // initial local monitor check, as the STB detects hazards and re-checks
  // the monitor. The monitor records whether it was set for a cacheable or
  // non-cacheable line, which is used to check the cacheability of the STREX
  // matches that of the LDREX.

  // The monitor is cleared if there is an invalidating snoop to the same
  // address as the monitor is set for, and if any allocation gets an external
  // abort, regardless of whether it is to the same address or not (this is
  // expected to be sufficiently rare that it will not affect performance). The
  // address matching uses a full address comparison rather than a set/way
  // match, because the LDREX could have data forwarded from the STB in which
  // case the way is not known.

  // A snoop request could invalidate the line any point after the load has done
  // it's tag lookup in DC1/M1 (but not on the same cycle as LDREXs are always
  // marked as first to the cache arbiter so will never be granted arbitration
  // on the same cycle as a snoop tag request - the second cycle of an LDXP does
  // not affect the monitor). Therefore as well as checking the exclusive
  // monitor address it is necessary to check the address of a LDREX in DC2/3.
  // Separate comparators are used as a speculative LDREX in DC2/3 should not
  // affect the main exclusive monitor if it ultimately is flushed/cc failed.

  // Check address of LDREX in DC2/3
  // - note that as exclusives stall in DC1 whilst there is another exclusive in
  // the pipeline there can never be an exclusive in DC2 and DC3 at the same
  // time
  // - the only exception is LDXP where the first half can be in DC3 with the
  // second half in DC2, however these will either be to the same cache line
  // address (so the following mux enables do not need to be one-hot) or will
  // abort (and so not update the monitor).
  assign excl_in_flight_addr = ({35{dcu_load_dc2 & excl_dc2}} & {ns_dsc_dc2,     pa_dc2[39:6]}) |
                               ({35{dcu_load_dc3 & excl_dc3}} & {ns_dsc_dc3, dcu_pa_dc3[39:6]});

  assign excl_in_flight_match = ({ccb_write_addr_m1_i, ccb_invalidating_tag_m1_i} == {excl_in_flight_addr, 1'b1}) | alloc_invalidating_tag_m1_i;

  // - track when line has been removed from cache for a LDREX in flight
  assign next_excl_in_flight_cleared = (excl_in_flight_match | excl_in_flight_cleared) &        // Set on match and maintain
                                       ((dcu_load_dc2 & excl_dc2) | (dcu_load_dc3 & excl_dc3)); // while exclusive in flight

  always @(posedge clk)
    excl_in_flight_cleared <= next_excl_in_flight_cleared;

  // Check address of main exclusive monitor
  assign excl_mon_match       = ({ccb_write_addr_m1_i, ccb_invalidating_tag_m1_i} == {exclusive_tag,       1'b1}) | alloc_invalidating_tag_m1_i;

  // The exclusive monitor is updated on a retiring, non-aborting
  // LDREX, CLREX or STREX.
  // - For LDXP only update the exclusive monitor on the first half of the pair
  // (note LDXP is the only multi-cycle exclusive instruction, as STXP completes
  // in a single cycle).
  assign committing_excl_dc3 = ((excl_dc3 & first_dc3) | clrex_dc3) &   // LDREX/STREX/CLREX
                               dpu_ready_cc_pass_wr_i & dcu_valid_dc3 & // Retiring this cycle
                               no_abort_dc3 & ~dpu_kill_wr_i;           // Not aborting/killed

  // Set when retiring non-aborting LDREX and line has not already been removed
  // from cache (and is not being removed this cycle)
  assign set_exclusive_monitor = load_dc3 & excl_dc3 & first_dc3 &                  // LDREX
                                 dpu_ready_cc_pass_wr_i & dcu_valid_dc3 &           // Retiring this cycle
                                 no_abort_dc3 & ~dpu_kill_wr_i &                    // Not aborting/killed
                                 ~(excl_in_flight_cleared | excl_in_flight_match);  // Line not already removed from cache

  // Clear when removed from cache (cleared on STREX and CLREX when they retire), or when
  // indicated by DPU (i.e. on an exception return).
  assign excl_line_removed_from_cache = exclusive_monitor & excl_mon_match;

  assign next_exclusive_monitor = set_exclusive_monitor |
                                  (exclusive_monitor & ~(committing_excl_dc3          | // STREX/CLREX
                                                         excl_line_removed_from_cache |
                                                         dpu_clear_excl_mon_i));

  // Note the exclusive monitor can be cleared when there is nothing in the
  // pipe, and so must be clocked off the free running clock.
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      exclusive_monitor <= 1'b0;
    else
      exclusive_monitor <= next_exclusive_monitor;

  // Indicate to other blocks when exclusive monitor set
  assign dcu_exclusive_monitor_o = exclusive_monitor;

  // Exclusive access tag
  assign next_exclusive_tag = {ns_dsc_dc3, dcu_pa_dc3[39:6]};

  always @(posedge clk_rare)
    if (set_exclusive_monitor) begin
      exclusive_tag           <= next_exclusive_tag;
      exclusive_tag_cacheable <= cacheable_dc3;
    end

  // Indicate when the monitor is cleared
  // - do not include when the monitor is cleared because of dpu_clear_excl_mon,
  // to prevent exception return events being counted twice
  // - this needs to be registered for timing reasons
  assign next_excl_mon_cleared = ((exclusive_monitor &
                                   (excl_line_removed_from_cache |        // Line removed from cache
                                    (committing_excl_dc3 & ~load_dc3))) | // CLREX/STREX committed
                                  (committing_excl_dc3 &
                                   load_dc3 &
                                   (excl_in_flight_cleared |
                                    excl_in_flight_match)));  // LDREX committed and line removed from cache whilst in flight

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      excl_mon_cleared <= 1'b0;
    else
      excl_mon_cleared <= next_excl_mon_cleared;

  assign dcu_excl_mon_cleared_o = excl_mon_cleared;


  //---------------------------------------------------------------------------
  // Misc.
  //---------------------------------------------------------------------------

  //-----
  // TLB
  //-----

  // Tell the TLB to not start any new iside lookups (and hence pagewalks)
  // once the current one has finished.
  assign dcu_block_lookups_o = dcu_cp_reg_write_no_exc;


  // ---
  // BIU
  // ---

  // Indicate to BIU when might make a linefill or non-cacheable request on this
  // cycle (used to improve timing in BIU).
  assign ls_biu_active_o = (valid_dc1 & (lf_state_dc1 == LF_REQ))                |
                           (dcu_load_dc2 & ~load_done_dc2 & previous_stall_dc2)  |
                           (dcu_load_dc3 & ~load_done_dc3);

  // Indicate to BIU when might make a linefill request on next cycle
  assign dcu_lf_active_o = (valid_dc1 & ((lf_state_dc1 == LF_M2) | (lf_state_dc1 == LF_REQ))) |
                           (valid_nabt_dc2 & dcu_load_dc2 & cacheable_ntrans_dc2 & ~load_done_dc2) |
                           (valid_nabt_dc3 &     load_dc3 & cacheable_ntrans_dc3 & ~load_done_dc3);

  // The BIU uses DCU's valid_dc3 internal signal to keep track of bursts correctly
  assign dcu_pipe_valid_dc3_o = valid_dc3;

  // Stop prefetcher when any CP15 maintenance op, CP15 register write, or DSB in DC3
  assign ls_stop_pf_o = valid_dc3 &                     // There is an operation in DC3
                        cp_inst_dc3 &                   // It's a CP instruction (CP15 maintenance/barrier/CP15 write)
                        ~`CA53_CPOP_IS_DMB(cp_op_dc3) & // and is not a DMB
                        dpu_ready_cc_pass_wr_i;         // And it's being committed by the DPU


  // ---
  // STB
  // ---
  // Tell the STB to drain all its slots
  assign dcu_drain_entire_stb_o = (valid_dc3 & (instr_non_mergeable_dc3 | (dcu_excl_shareable_dc3 & ~cacheable_dc3))) |
                                  (valid_dc2 & (dxb_dc2 | (store_dc2 & dcu_excl_shareable_dc2) | cp_dc_maint_op_dc2)) |
                                  (valid_dc1 & (dxb_dc1 | (store_dc1 & excl_dc1              ) | cp_dc_maint_op_dc1)) | // shareable_dc1 too late for STREX
                                  dpu_dbg_dsb_req_i;


  // ---
  // DPU
  // ---
  // Indicate to the DPU when a dbg_dsb can complete. The DPU will only
  // request a dbg_dsb when the DCU pipeline is empty, so this does not need
  // to be factored in. The signal is too late to send to the DPU directly, so
  // register.
  assign next_dcu_dbg_dsb_ack = stb_empty & ~biu_dirty_lf_in_progress_i;

  always @(posedge clk)
    dcu_dbg_dsb_ack <= next_dcu_dbg_dsb_ack;

  assign dcu_dbg_dsb_ack_o = dcu_dbg_dsb_ack;

  // DCU Event Signal
  // Signal that a cacheable load or store has been committed and that
  // the dcache was on.
  assign dcu_evnt_dc_access_o = (load_dc3 | store_dc3) &
                                cacheable_dc3 & // Attributes forced to NC if cache off
                                dcu_valid_dc3 & dpu_ready_wr_i;

  // Indicate lspipe is ready for WFx when it is empty.
  assign ls_wfx_ready_o = ~(valid_dc1 | valid_dc2 | valid_dc3);


  //-------------------------
  // Outputs to other blocks
  //-------------------------

  // Indicate the instructions in the lspipe to the DVM block to allow it to
  // track them.
  assign valid_dc1_o               = valid_dc1;
  assign valid_dc2_o               = valid_dc2;
  assign valid_dc3_o               = valid_dc3;
  assign dsb_dc1_o                 = dsb_dc1;
  assign dsb_dc2_o                 = dsb_dc2;
  assign dsb_dc3_o                 = dsb_dc3;
  assign next_valid_dc2_o          = next_valid_dc2;
  assign next_valid_dc3_o          = next_valid_dc3;
  assign v_enable_dc1_o            = v_enable_dc1;
  assign v_enable_dc2_o            = v_enable_dc2;
  assign v_enable_dc3_o            = v_enable_dc3;


  //---------------------------------------------------------------------------
  // OVLs
  //---------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  //-------------------
  // LSPipe Properties
  //-------------------

  // The pipe stage valid signals should always be valid.
  // - valid_dc1
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "valid_dc1 should never be X")
  u_ovl_valid_dc1_x        (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (valid_dc1));

  // - valid_dc2
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "valid_dc2 should never be X")
  u_ovl_valid_dc2_x        (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (valid_dc2));

  // - valid_dc3
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "valid_dc3 should never be X")
  u_ovl_valid_dc3_x        (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (valid_dc3));

  // dcu_load_dc2 is used to mean (valid_dc2 & load_dc2)
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "dcu_load_dc2 should never be X")
  u_ovl_dcu_load_dc2_x     (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (dcu_load_dc2));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dcu_load_dc2 should only be asserted when valid_dc2 asserted")
  u_ovl_load_dc2_valid   (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (dcu_load_dc2),
                          .consequent_expr (valid_dc2));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dcu_cp_read_dc2 should only be asserted when valid_dc2 asserted")
  u_ovl_cp_rd_dc2_valid  (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (dcu_cp_read_dc2),
                          .consequent_expr (valid_dc2));

  // Should always stall DC1 when pipe full
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Load should always stall DC1 on pipe full")
  u_ovl_stall_dc1_full   (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (valid_dc1 & load_dc1 & pipe_full_stall_dc1),
                          .consequent_expr (stall_dc1));

  // Should always have a load M2 when LF state machine in DC1 is in M2 state
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Should always have lookup_m2 when in LF_M2")
  u_ovl_lf_m2_lookup     (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (valid_dc1 & (lf_state_dc1 == LF_M2)),
                          .consequent_expr (load_lookup_m2_i));

  // When there is an instruction in DC2, or a DC cache debug op in DC3, clk_dc2
  // must be active and have been active on previous cycle.
  reg ovl_clk_dc2_enable_prev;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_clk_dc2_enable_prev <= 1'b0;
    else
      ovl_clk_dc2_enable_prev <= clk_dc2_enable;

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Instruction in DC2 but clk_dc2 not active")
  u_ovl_clk_dc2_valid    (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (valid_dc2 | dc_cp15_ack_i | mbist_en_i),
                          .consequent_expr (clk_dc2_enable & ovl_clk_dc2_enable_prev));

  // When there is an instruction in DC3, clk_dc3 must be active and must have
  // been active on previous cycle.
  reg ovl_clk_dc3_enable_prev;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_clk_dc3_enable_prev <= 1'b0;
    else
      ovl_clk_dc3_enable_prev <= clk_dc3_enable;

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Instruction in DC3 but clk_dc3 not active")
  u_ovl_clk_dc3_valid    (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (valid_dc3),
                          .consequent_expr (clk_dc3_enable & ovl_clk_dc3_enable_prev));

  // When there is a LDREX or governor op in DC3, clk_rare must be active and
  // must have been active on the previous cycle
  reg ovl_clk_rare_enable_prev;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_clk_rare_enable_prev <= 1'b0;
    else
      ovl_clk_rare_enable_prev <= clk_rare_enable;

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "'Rare' instruction in DC3 but clk_rare not active")
  u_ovl_clk_rare_valid   (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (valid_dc3  & ((dcu_load_dc3 & excl_dc3) | gov_op_dc3)),
                          .consequent_expr (clk_rare_enable));

  // When an instruction is moving from DC1 to DC2 and any of the DC2
  // registers required by the instruction which are gated by
  // enable_transl_dc2 are changing, enable_transl_dc2 must be enabled.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Instruction requires enable_transl_dc2 enabled, but it is not")
  u_ovl_transl_dc2_valid (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (enable_dc2 &
                                            ((dpu_va_dc1_i[31:12] != va_dc2[31:12])   |
                                             ((dpu_va_dc1_i[55:32] != va_dc2[55:32]) & dpu_aarch64_state_i) |
                                             (attrs_dc1           != attrs_dc2)       |
                                             (dpu_pa_dc1_i        != upper_pa_dc2)    |
                                             (dpu_ns_dsc_dc1_i    != ns_dsc_dc2)      |
                                             (cp_inst_dc1         != cp_inst_dc2)     |
                                             (cp_write_dc1        != cp_write_dc2)    |
                                             (fault_stage_dc1     != fault_stage_dc2) |
                                             (next_domain_dc2     != domain_dc2)      |
                                             (v2p_abort_dc1       != v2p_abort_dc2)   |
                                             // Following only need to be
                                             // accurate on V2P:
                                             (cp_inst_dc1 & cp_is_v2p_dc1 &
                                              ((supersection_dc1  != supersection_dc2) |
                                               (v2p_lpae_dc1      != v2p_lpae_dc2))))),
                          .consequent_expr (enable_transl_dc2));

  // When an instruction is moving from DC1 to DC2 and the top byte of the
  // address is changing, enable_va_top_byte_dc2 must be enabled.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Instruction requires enable_va_top_byte_dc2 enabled, but it is not")
  u_ovl_top_va_dc2_valid (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (enable_dc2 & dpu_aarch64_state_i & (dpu_va_dc1_i[63:56] != va_dc2[63:56])),
                          .consequent_expr (enable_va_top_byte_dc2));

  // When an instruction is moving from DC2 to DC3 and any of the DC3
  // registers required by the instruction which are gated by
  // enable_transl_dc3 are changing, enable_transl_dc3 must be enabled.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Instruction requires enable_transl_dc3 enabled, but it is not")
  u_ovl_transl_dc3_valid (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (enable_dc3 &
                                            ((va_dc2[31:12]             != va_dc3[31:12])             |
                                             ((va_dc2[55:32]            != va_dc3[55:32]) & dpu_aarch64_state_i) |
                                             (attrs_dc2                 != attrs_dc3)                 |
                                             (upper_pa_dc2              != upper_pa_dc3)              |
                                             (cp_inst_dc2               != cp_inst_dc3)               |
                                             (cp_write_dc2              != cp_write_dc3)              |
                                             (dcu_cp_read_dc2           != cp_read_dc3)               |
                                             (fault_stage_dc2           != fault_stage_dc3)           |
                                             (domain_dc2                != domain_dc3)                |
                                             (cp15_needs_broadcast_dc2  != cp15_needs_broadcast_dc3)  |
                                             // Following only need to be
                                             // accurate on V2P:
                                             (cp_inst_dc2 & (~cp_op_dc2[8] & cp_op_dc2[6:3] == 4'b0001) & // V2P encoding space
                                              ((supersection_dc2  != supersection_dc3) |
                                               (v2p_lpae_dc2      != v2p_lpae_dc3))))),
                          .consequent_expr (enable_transl_dc3));

  // When an instruction is moving from DC2 to DC3 and the top byte of the
  // address is changing, enable_va_top_byte_dc3 must be enabled.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Instruction requires enable_va_top_byte_dc3 enabled, but it is not")
  u_ovl_top_va_dc3_valid (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (enable_dc3 & dpu_aarch64_state_i & (va_dc2[63:56] != va_dc3[63:56])),
                          .consequent_expr (enable_va_top_byte_dc3));

  // The internal regs for tracking the STB state must be consistent with the
  // actual inputs from the STB.
  assert_always #(`OVL_FATAL, `OVL_ASSERT, "stb_empty inaccurate")
  u_ovl_stb_empty_valid  (.clk             (clk),
                          .reset_n         (reset_n),
                          .test_expr       (stb_empty == (stb_slots_valid_i == 5'b00000)));

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "stb_not_full inaccurate")
  u_ovl_stb_full_valid   (.clk             (clk),
                          .reset_n         (reset_n),
                          .test_expr       (stb_not_full == (stb_slots_valid_i != 5'b11111)));

  // If a load can hit in the cache in M2, it must have made an M1 lookup
  // request in the previous cycle.
  reg ovl_cache_lookup_m2;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_cache_lookup_m2 <= 1'b0;
    else
      ovl_cache_lookup_m2 <= (dc_load_req_m1_o & dc_load_has_priority_m1_i);

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Load allowed to hit in cache without doing a lookup on previous cycle")
  u_ovl_cache_hit_lookup (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (dcu_load_dc2 & dcache_hit_enable_dc2),
                          .consequent_expr (ovl_cache_lookup_m2));

  // The reserved encoding for shareability should never be seen on attrs_dc3,
  // so the x-assignment in the ldar_stlr_barrier_type_dc3 case statement should
  // not be reachable.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unused value for shareability seen on attrs_dc3")
  u_ovl_attrs_dc3_unused (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (dcu_stb_req_dc3 & ldar_stlr_dc3 & cp_inst_dc3 & cacheable_dc3),
                          .consequent_expr (attrs_dc3[1:0] != 2'b01));

  // The case statement used to generate vmsa_fault_dc3 is not fully populated,
  // so it has reachable x-assignment. The output should never be assigned to
  // X when it is used.
  assert_never_unknown #(`OVL_FATAL, 7, `OVL_ASSERT, "vmsa_fault_dc3 should not be X when used")
  u_ovl_vmsa_fault_dc3_x   (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (valid_nabt_dc3 & cp_inst_dc3 & cp_is_v2p_dc3 & v2p_abort_dc3 & ~v2p_lpae_dc3),
                            .test_expr (vmsa_fault_dc3));

  // The varaibles in the if statement in the next_lf_state_dc1 process should
  // never be X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: next_lf_state_dc1")
  u_ovl_x_lf_state_dc1 (.clk       (clk_dc2),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (~pipe_full_stall_dc1 | cc_fail_or_flush_dc1));

  // The case statement used to generate align_mask_dc1 is not fully populated,
  // so it has reachable x-assignment. The output should never be assigned to
  // X, because the input to the case statement should never be one of the
  // un-populated values.
  assert_never_unknown #(`OVL_FATAL, 5, `OVL_ASSERT, "align_mask_dc1 should not be X when used")
  u_ovl_align_mask_dc1_x   (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (valid_dc1 & first_dc1 & ~cp_inst_dc1 & ~dczva_dc1),
                            .test_expr (align_mask_dc1));

  // The complete_dc2 and complete_dc3 signals should never be asserted at the
  // same time, as an instruction can only retire from DC3 if DC3 is stalled,
  // in which case an instruction in DC2 cannot retire.
  assert_zero_one_hot #(`OVL_FATAL, 2, `OVL_ASSERT, "complete_dc2/3 signals are mutually exclusive")
  u_ovl_retire_dc2_3_oneh  (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({complete_dc2, complete_dc3}));

  // The attr_mismatch_dc3 signal should never be asserted for a PLD or CP
  // instruction, as it is pipelined from attr_mismatch_dc2, which is
  // qualified with store_dc2, which implies DC2 was not a PLD or CP
  // instruction when it was calculated.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "attr_mismatch_dc3 should never be set for a CP instruction or a PLD")
  u_ovl_attr_mis_dc3     (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (valid_dc3 & attr_mismatch_dc3),
                          .consequent_expr (~(cp_inst_dc3 | pld_dc3)));

  // block_loads_dc1 should always be asserted for a first in DC1 when there is
  // an exclusive or DMB/DMBLD in DC2 or DC3.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "block_loads_dc1 not asserted for required stall condition")
  u_ovl_block_ld_stall   (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (valid_dc1 & load_dc1 & first_dc1 &
                                            ((valid_dc2 & (excl_dc2 | clrex_dc2 | (dmb_dc2 & ~dmbst_dc2) | dmbld_dc2 | ldar_stlr_dc2)) |
                                             (valid_dc3 & (excl_dc3 | clrex_dc3 | (dmb_dc3 & ~dmbst_dc3) | dmbld_dc3 | ldar_stlr_dc3)))),
                          .consequent_expr (block_loads_dc1));

  // load_req_dc1 should only be set when there is an actual load in DC1
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "load_req_dc1 asserted when no load in DC1")
  u_ovl_load_req_valid   (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (load_req_dc1),
                          .consequent_expr (valid_dc1 & load_dc1));

  // transl_valid_dc2 should never be asserted on CP operations
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "transl_valid_dc2 should never be set for CP ops")
  u_ovl_transl_dc2_cp    (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (transl_valid_dc2),
                          .consequent_expr (~(valid_dc2 & cp_inst_dc2)));

  // store_sent_dc3 should only be asserted when there is a DSB or STREX in DC3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "store_sent should only be asserted for DSBs and STREXs")
  u_ovl_store_sent_dc3   (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (valid_dc3 & store_sent_dc3),
                          .consequent_expr (dsb_dc3 | (store_dc3 & excl_dc3)));

  // strex_monitor_failed_dc3 should only be asserted when there is a STREX
  // in DC3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "strex_monitor_failed_dc3 should only be asserted for STREXs")
  u_ovl_strex_mon_failed (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (valid_dc3 & strex_monitor_failed_dc3),
                          .consequent_expr (store_dc3 & excl_dc3));

  // waw_attr_mismatch_dc2 should only be set when making an stb_req
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "waw_attr_mismatch set when not making STB req")
  u_ovl_waw_attr_stb_req (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (waw_attr_mismatch_dc2 & ~(watchpoint_dc3 & ~`CA53_MEM_MERGEABLE(attrs_dc3))),
                          .consequent_expr (dcu_stb_req_dc3));

  // stb_store_req_early_dc3 should only be set when there is an actual stb_req in
  // DC3, unless it is for a STREX
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "waw_attr_mismatch set when not making STB req")
  u_ovl_stb_req_early    (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (stb_store_req_early_dc3 &
                                            ~(store_dc3 & excl_dc3)),
                          .consequent_expr (dcu_stb_req_dc3));

  // The address used for LDREX address hazarding in the cache arbiter is shared
  // for DC2/DC3, so cannot have LDREX in both at same time
  // - on an LDXP can have first half in DC3 and second half in DC2, but these
  // should either have the same address or abort (because of an alignment
  // fault)
  wire ovl_ldxp_dc2_dc3 = valid_dc3 & excl_dc3 & dcu_load_dc3 & first_dc3 &
                          valid_dc2 & excl_dc2 & dcu_load_dc2 & ~first_dc2;

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Second half of LDXP in DC2 does not have same address as DC3 and does not have abort")
  u_ovl_ldxp_same_addr   (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (ovl_ldxp_dc2_dc3),
                          .consequent_expr (({ns_dsc_dc2, pa_dc2[39:6]} == {ns_dsc_dc3, dcu_pa_dc3[39:6]}) | abort_dc3));

  assert_zero_one_hot #(`OVL_FATAL, 2, `OVL_ASSERT, "LDREX in DC2 and DC3 at same time")
  u_ovl_ldrex_dc2_dc3      (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({2{~ovl_ldxp_dc2_dc3}} &
                                        {(valid_dc2 & dcu_load_dc2 & excl_dc2),
                                         (valid_dc3 & dcu_load_dc3 & excl_dc3)}));

  // The exclusive tag etc. should never be X when the monitor is active.
  // - exclusive_tag
  assert_never_unknown #(`OVL_FATAL, 35, `OVL_ASSERT, "exclusive_tag never X when exclusive monitor active")
  u_ovl_x_excl_tag         (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (exclusive_monitor),
                            .test_expr (exclusive_tag));

  // - exclusive_tag_cacheable
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "exclusive_tag_cacheable never X when exclusive monitor active")
  u_ovl_x_excl_tag_cache   (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (exclusive_monitor),
                            .test_expr (exclusive_tag_cacheable));

  // Not all encodings of fault_stage_dc1 are valid
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "fault_stage_dc1 must be valid when there is an abort")
  u_ovl_fault_stage_dc1_valid     (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (valid_dc1 & abort_dc1),
                                   .consequent_expr ((fault_stage_dc1 == 2'b00) |
                                                     (fault_stage_dc1 == 2'b10) |
                                                     (fault_stage_dc1 == 2'b11)));

  // Some combinations of barriers must always be observed.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "DMBSTs must be DMBs - DC1")
  u_ovl_dmbst_is_dmb_dc1   (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (valid_dc1 & dmbst_dc1),
                            .consequent_expr (dmb_dc1));

  assert_zero_one_hot #(`OVL_FATAL, 3, `OVL_ASSERT, "DMBs, DMBLDs and DSBs are mutually exclusive - DC1")
  u_ovl_dmb_dsb_onehot_dc1 (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({3{valid_dc1}} & {dmb_dc1, dmbld_dc1, dsb_dc1}));

  assert_zero_one_hot #(`OVL_FATAL, 3, `OVL_ASSERT, "DMBs, DMBLDs and DSBs are mutually exclusive - DC2")
  u_ovl_dmb_dsb_onehot_dc2 (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({3{valid_dc2}} & {dmb_dc2, dmbld_dc2, dsb_dc2}));

  assert_zero_one_hot #(`OVL_FATAL, 3, `OVL_ASSERT, "DMBs, DMBLDs and DSBs are mutually exclusive - DC3")
  u_ovl_dmb_dsb_onehot_dc3 (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({3{valid_dc3}} & {dmb_dc3, dmbld_dc3, dsb_dc3}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Updating DC1 pipeline registers implies that DC1 valid bit is updated")
  u_ovl_enable_dc1 (.clk             (clk),
                    .reset_n         (reset_n),
                    .antecedent_expr (enable_dc1),
                    .consequent_expr (v_enable_dc1));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Updating DC2 pipeline registers implies that DC2 valid bit is updated")
  u_ovl_enable_dc2 (.clk             (clk),
                    .reset_n         (reset_n),
                    .antecedent_expr (enable_dc2),
                    .consequent_expr (v_enable_dc2));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Updating DC3 pipeline registers implies that DC3 valid bit is updated")
  u_ovl_enable_dc3 (.clk             (clk),
                    .reset_n         (reset_n),
                    .antecedent_expr (enable_dc3),
                    .consequent_expr (v_enable_dc3));

  // STREXs should not make STB requests if they fail the local monitor
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "STB request when local monitor failed")
  u_ovl_stb_req_monitor_fail (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc3 & strex_monitor_failed_dc3),
                              .consequent_expr (~dcu_stb_req_dc3));

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Loads should not enter DC1 if there is a cache debug op in DC3")
  u_ovl_load_dc1_debug_dc3 (.clk (clk),
                            .reset_n (reset_n),
                            .test_expr (valid_dc1 & load_dc1 & valid_dc3 & cp_dc_debug_op_dc3));

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Stores should not enter DC1 if there is a cache debug op in DC3")
  u_ovl_store_dc1_debug_dc3 (.clk (clk),
                             .reset_n (reset_n),
                             .test_expr (valid_dc1 & store_dc1 & valid_dc3 & cp_dc_debug_op_dc3));

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Loads should not enter DC1 if there is a CP15 op in DC2")
  u_ovl_load_dc1_cp15_dc2 (.clk (clk),
                           .reset_n (reset_n),
                           .test_expr (valid_dc1 & load_dc1 & valid_dc2 & cp_inst_dc2 & ~dxb_dc2 & ~dmbld_dc2));

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Loads should not enter DC1 if there is a CP15 op in DC3")
  u_ovl_load_dc1_cp15_dc3 (.clk (clk),
                           .reset_n (reset_n),
                           .test_expr (valid_dc1 & load_dc1 & valid_dc3 & cp_inst_dc3 & ~dxb_dc3 & ~dmbld_dc3));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Local cp op and forwarded op cannot happen at the same time.")
  u_ovl_local_fwd_cp (.clk             (clk),
                      .reset_n         (reset_n),
                      .antecedent_expr (dcu_cp_valid & ~dpu_kill_wr_i & cp_is_tlb_debug_dc3),
                      .consequent_expr (~dcu_dvm_valid_tlb_i));


  //-----------------------------
  // DC1 LF state machine states
  //-----------------------------
  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid DC1 linefill state machine transition")
  u_ovl_dc1_transition_idle (.clk         (clk),
                             .reset_n     (reset_n),
                             .start_event (lf_state_dc1 == LF_IDLE),
                             .test_expr   (((lf_state_dc1 == LF_IDLE) |
                                            (lf_state_dc1 == LF_M1))));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid DC1 linefill state machine transition")
  u_ovl_dc1_transition_m1   (.clk         (clk),
                             .reset_n     (reset_n),
                             .start_event (lf_state_dc1 == LF_M1),
                             .test_expr   (((lf_state_dc1 == LF_M1) |
                                            (lf_state_dc1 == LF_M2) |
                                            (lf_state_dc1 == LF_IDLE))));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid DC1 linefill state machine transition")
  u_ovl_dc1_transition_m2   (.clk         (clk),
                             .reset_n     (reset_n),
                             .start_event (lf_state_dc1 == LF_M2),
                             .test_expr   (((lf_state_dc1 == LF_HIT) |
                                            (lf_state_dc1 == LF_REQ) |
                                            (lf_state_dc1 == LF_IDLE))));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid DC1 linefill state machine transition")
  u_ovl_dc1_transition_req  (.clk         (clk),
                             .reset_n     (reset_n),
                             .start_event (lf_state_dc1 == LF_REQ),
                             .test_expr   (((lf_state_dc1 == LF_HIT) |
                                            (lf_state_dc1 == LF_REQ) |
                                            (lf_state_dc1 == LF_IDLE))));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid DC1 linefill state machine transition")
  u_ovl_dc1_transition_hit  (.clk         (clk),
                             .reset_n     (reset_n),
                             .start_event (lf_state_dc1 == LF_HIT),
                             .test_expr   (((lf_state_dc1 == LF_HIT) |
                                            (lf_state_dc1 == LF_IDLE))));


  //---------------
  // CP Op Decodes
  //---------------
  // Different classes of CP operation are decoded in different stages of the
  // pipeline. Each signal should only be asserted for the correct CP
  // operations.

  // barrier_iss
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "barrier_iss mismatch with CP operation type")
  u_ovl_cp_dec_barrier_iss   (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (dpu_valid_cp_iss_i & ~dpu_flush_i),
                              .consequent_expr (barrier_iss ==
                                                ((dpu_cp_op_iss_i == `CA53_CPOP_DMBNSHLD) |
                                                 (dpu_cp_op_iss_i == `CA53_CPOP_DMBISHLD) |
                                                 (dpu_cp_op_iss_i == `CA53_CPOP_DMBOSHLD) |
                                                 (dpu_cp_op_iss_i == `CA53_CPOP_DMBLD)    |
                                                 (dpu_cp_op_iss_i == `CA53_CPOP_DSBNS)    |
                                                 (dpu_cp_op_iss_i == `CA53_CPOP_DSBIS)    |
                                                 (dpu_cp_op_iss_i == `CA53_CPOP_DSBOS)    |
                                                 (dpu_cp_op_iss_i == `CA53_CPOP_DSBSY)    |
                                                 (dpu_cp_op_iss_i == `CA53_CPOP_DMBNS)    |
                                                 (dpu_cp_op_iss_i == `CA53_CPOP_DMBIS)    |
                                                 (dpu_cp_op_iss_i == `CA53_CPOP_DMBOS)    |
                                                 (dpu_cp_op_iss_i == `CA53_CPOP_DMBSY)    |
                                                 (dpu_cp_op_iss_i == `CA53_CPOP_DMBNSST)  |
                                                 (dpu_cp_op_iss_i == `CA53_CPOP_DMBISST)  |
                                                 (dpu_cp_op_iss_i == `CA53_CPOP_DMBOSST)  |
                                                 (dpu_cp_op_iss_i == `CA53_CPOP_DMBSYST))));

  // cp_is_reg_dc1
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_reg_dc1 assert for wrong CP operation")
  u_ovl_cp_dec_is_reg_dc1    (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc1 & cp_inst_dc1),
                              .consequent_expr (cp_is_reg_dc1 ==
                                                ((cp_op_dc1 == `CA53_CPOP_CDBGDR0)       |
                                                 (cp_op_dc1 == `CA53_CPOP_CDBGDR1)       |
                                                 (cp_op_dc1 == `CA53_CPOP_CDBGDR2)       |
                                                 (cp_op_dc1 == `CA53_CPOP_CDBGDR3)       |
                                                 (cp_op_dc1 == `CA53_CPOP_TTBR0)         |
                                                 (cp_op_dc1 == `CA53_CPOP_TTBR1)         |
                                                 (cp_op_dc1 == `CA53_CPOP_TTBCR)         |
                                                 (cp_op_dc1 == `CA53_CPOP_TTBR0_EL1)     |
                                                 (cp_op_dc1 == `CA53_CPOP_TTBR0_EL2)     |
                                                 (cp_op_dc1 == `CA53_CPOP_TTBR0_EL3)     |
                                                 (cp_op_dc1 == `CA53_CPOP_TCR_EL1)       |
                                                 (cp_op_dc1 == `CA53_CPOP_TCR_EL2)       |
                                                 (cp_op_dc1 == `CA53_CPOP_TCR_EL3)       |
                                                 (cp_op_dc1 == `CA53_CPOP_HTTBR)         |
                                                 (cp_op_dc1 == `CA53_CPOP_TTBR0_EL2)     |
                                                 (cp_op_dc1 == `CA53_CPOP_VTTBR)         |
                                                 (cp_op_dc1 == `CA53_CPOP_VTTBR_EL2)     |
                                                 (cp_op_dc1 == `CA53_CPOP_HTCR)          |
                                                 (cp_op_dc1 == `CA53_CPOP_TCR_EL2)       |
                                                 (cp_op_dc1 == `CA53_CPOP_VTCR)          |
                                                 (cp_op_dc1 == `CA53_CPOP_VTCR_EL2)      |
                                                 (cp_op_dc1 == `CA53_CPOP_PAR)           |
                                                 (cp_op_dc1 == `CA53_CPOP_PAR_EL1)       |
                                                 (cp_op_dc1 == `CA53_CPOP_MAIR0)         |
                                                 (cp_op_dc1 == `CA53_CPOP_MAIR1)         |
                                                 (cp_op_dc1 == `CA53_CPOP_MAIR_EL1)      |
                                                 (cp_op_dc1 == `CA53_CPOP_MAIR_EL2)      |
                                                 (cp_op_dc1 == `CA53_CPOP_MAIR_EL3)      |
                                                 (cp_op_dc1 == `CA53_CPOP_HMAIR0)        |
                                                 (cp_op_dc1 == `CA53_CPOP_HMAIR1)        |
                                                 (cp_op_dc1 == `CA53_CPOP_CONTEXTIDR)    |
                                                 (cp_op_dc1 == `CA53_CPOP_CONTEXTIDR_EL1)|
                                                 (cp_op_dc1 == `CA53_CPOP_TTBR0_EL3)     |
                                                 (cp_op_dc1 == `CA53_CPOP_TCR_EL3)       |
                                                 (cp_op_dc1 == `CA53_CPOP_MAIR_EL3)      |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGBVR0)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGBVR1)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGBVR2)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGBVR3)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGBVR4)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGBVR5)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGBXVR4)      |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGBXVR5)      |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGBCR0)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGBCR1)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGBCR2)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGBCR3)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGBCR4)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGBCR5)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGWVR0)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGWVR1)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGWVR2)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGWVR3)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGWCR0)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGWCR1)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGWCR2)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGWCR3)       |
                                                 (cp_op_dc1 == `CA53_CPOP_DBGVCR))));

  // cp_is_ifu_maint_dc1
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_ifu_maint_dc1 mismatch with CP operation type")
  u_ovl_cp_dec_is_ifu_dc1    (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc1 & cp_inst_dc1),
                              .consequent_expr (cp_is_ifu_maint_dc1 ==
                                                ((cp_op_dc1 == `CA53_CPOP_ICIALLU) |
                                                 (cp_op_dc1 == `CA53_CPOP_ICIALLUIS) |
                                                 (cp_op_dc1 == `CA53_CPOP_ICIMVAU))));

  // cp_is_dc_maint_dc1
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_dc_maint_dc1 mismatch with CP operation type")
  u_ovl_cp_dec_is_dc_dc1     (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc1 & cp_inst_dc1),
                              .consequent_expr (cp_is_dc_maint_dc1 ==
                                                ((cp_op_dc1 == `CA53_CPOP_DCIMVAC) |
                                                 (cp_op_dc1 == `CA53_CPOP_DCCIMVAC) |
                                                 (cp_op_dc1 == `CA53_CPOP_DCCMVAC) |
                                                 (cp_op_dc1 == `CA53_CPOP_DCCMVAU) |
                                                 (cp_op_dc1 == `CA53_CPOP_DCISW) |
                                                 (cp_op_dc1 == `CA53_CPOP_DCCISW) |
                                                 (cp_op_dc1 == `CA53_CPOP_DCCSW))));

  // cp_dc_maint_op_dc1
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_dc_maint_op_dc1 mismatch with CP operation type")
  u_ovl_cp_dec_dc_maint_dc1  (.clk            (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc1),
                              .consequent_expr (cp_dc_maint_op_dc1 ==
                                                (cp_inst_dc1 &
                                                 ((cp_op_dc1 == `CA53_CPOP_DCISW)    |
                                                  (cp_op_dc1 == `CA53_CPOP_DCCSW)    |
                                                  (cp_op_dc1 == `CA53_CPOP_DCCISW)   |
                                                  (cp_op_dc1 == `CA53_CPOP_DCIMVAC)  |
                                                  (cp_op_dc1 == `CA53_CPOP_DCCMVAC)  |
                                                  (cp_op_dc1 == `CA53_CPOP_DCCMVAU)  |
                                                  (cp_op_dc1 == `CA53_CPOP_DCCIMVAC)))));

  // cp_ifu_maint_dc1
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_ifu_maint_dc1 mismatch with CP operation type")
  u_ovl_cp_dec_ifu_maint_dc1 (.clk            (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc1),
                              .consequent_expr (cp_ifu_maint_dc1 ==
                                                (cp_inst_dc1 &
                                                 ((cp_op_dc1 == `CA53_CPOP_ICIALLU) |
                                                  (cp_op_dc1 == `CA53_CPOP_ICIALLUIS) |
                                                  (cp_op_dc1 == `CA53_CPOP_ICIMVAU)))));

  // cp_is_v2p_dc1
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_v2p_dc1 mismatch with CP operation type")
  u_ovl_cp_dec_is_v2p_dc1    (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc1 & cp_inst_dc1),
                              .consequent_expr (cp_is_v2p_dc1 ==
                                                ((cp_op_dc1 == `CA53_CPOP_ATS1C)    |
                                                 (cp_op_dc1 == `CA53_CPOP_ATS12NSO) |
                                                 (cp_op_dc1 == `CA53_CPOP_ATS1H)    |
                                                 (cp_op_dc1 == `CA53_CPOP_ATS1E01)  |
                                                 (cp_op_dc1 == `CA53_CPOP_ATS12E01) |
                                                 (cp_op_dc1 == `CA53_CPOP_ATS1E2)   |
                                                 (cp_op_dc1 == `CA53_CPOP_ATS1E3))));

  // cp_is_maint_mva_dc1
  // - Cache maintenance operations by MVA
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_maint_mva_dc1 mismatch with CP operation type")
  u_ovl_cp_dec_is_maint_mva_dc1  (.clk             (clk),
                                  .reset_n         (reset_n),
                                  .antecedent_expr (valid_dc1 & cp_inst_dc1),
                                  .consequent_expr (cp_is_maint_mva_dc1 ==
                                                    ((cp_op_dc1 == `CA53_CPOP_ICIMVAU)  |
                                                     (cp_op_dc1 == `CA53_CPOP_DCIMVAC)  |
                                                     (cp_op_dc1 == `CA53_CPOP_DCCIMVAC) |
                                                     (cp_op_dc1 == `CA53_CPOP_DCCMVAC)  |
                                                     (cp_op_dc1 == `CA53_CPOP_DCCMVAU))));

  // cp_is_mva_dc1
  // - Any CP operation which does an address translation (including V2P)
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_mva_dc1 mismatch with CP operation type")
  u_ovl_cp_dec_is_mva_dc1    (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc1 & cp_inst_dc1),
                              .consequent_expr (cp_is_mva_dc1 ==
                                                ((cp_op_dc1 == `CA53_CPOP_ICIMVAU)  |
                                                 (cp_op_dc1 == `CA53_CPOP_DCIMVAC)  |
                                                 (cp_op_dc1 == `CA53_CPOP_DCCIMVAC) |
                                                 (cp_op_dc1 == `CA53_CPOP_DCCMVAC)  |
                                                 (cp_op_dc1 == `CA53_CPOP_DCCMVAU)  |
                                                 (cp_op_dc1 == `CA53_CPOP_ATS1C)    |
                                                 (cp_op_dc1 == `CA53_CPOP_ATS12NSO) |
                                                 (cp_op_dc1 == `CA53_CPOP_ATS1H)    |
                                                 (cp_op_dc1 == `CA53_CPOP_ATS1E01)  |
                                                 (cp_op_dc1 == `CA53_CPOP_ATS12E01) |
                                                 (cp_op_dc1 == `CA53_CPOP_ATS1E2)   |
                                                 (cp_op_dc1 == `CA53_CPOP_ATS1E3))));

  // dxb_dc1
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dxb_dc1 mismatch with CP operation type")
  u_ovl_cp_dec_dxb_dc1       (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc1 & cp_inst_dc1),
                              .consequent_expr (dxb_dc1 ==
                                                ((cp_op_dc1 == `CA53_CPOP_DSBNS) |
                                                 (cp_op_dc1 == `CA53_CPOP_DSBIS) |
                                                 (cp_op_dc1 == `CA53_CPOP_DSBOS) |
                                                 (cp_op_dc1 == `CA53_CPOP_DSBSY) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBNS) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBIS) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBOS) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBSY) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBNSST) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBISST) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBOSST) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBSYST))));

  // dsb_dc1
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dsb_dc1 mismatch with CP operation type")
  u_ovl_cp_dec_dsb_dc1       (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc1 & cp_inst_dc1),
                              .consequent_expr (dsb_dc1 ==
                                                ((cp_op_dc1 == `CA53_CPOP_DSBNS) |
                                                 (cp_op_dc1 == `CA53_CPOP_DSBIS) |
                                                 (cp_op_dc1 == `CA53_CPOP_DSBOS) |
                                                 (cp_op_dc1 == `CA53_CPOP_DSBSY))));

  // dmb_dc1
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dmb_dc1 mismatch with CP operation type")
  u_ovl_cp_dec_dmb_dc1       (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc1 & cp_inst_dc1),
                              .consequent_expr (dmb_dc1 ==
                                                ((cp_op_dc1 == `CA53_CPOP_DMBNS) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBIS) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBOS) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBSY) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBNSST) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBISST) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBOSST) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBSYST))));

  // dmbld_dc1
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dmbld_dc1 mismatch with CP operation type")
  u_ovl_cp_dec_dmbld_dc1       (.clk             (clk),
                                .reset_n         (reset_n),
                                .antecedent_expr (valid_dc1 & cp_inst_dc1),
                                .consequent_expr (dmbld_dc1 ==
                                                  ((cp_op_dc1 == `CA53_CPOP_DMBNSHLD) |
                                                   (cp_op_dc1 == `CA53_CPOP_DMBISHLD) |
                                                   (cp_op_dc1 == `CA53_CPOP_DMBOSHLD) |
                                                   (cp_op_dc1 == `CA53_CPOP_DMBLD))));

  // dmbst_dc1
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dmbst_dc1 mismatch with CP operation type")
  u_ovl_cp_dec_dmbst_dc1     (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc1 & cp_inst_dc1),
                              .consequent_expr (dmbst_dc1 ==
                                                ((cp_op_dc1 == `CA53_CPOP_DMBNSST) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBISST) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBOSST) |
                                                 (cp_op_dc1 == `CA53_CPOP_DMBSYST))));

  // clrex_dc1
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "clrex_dc1 mismatch with CP operation type")
  u_ovl_cp_dec_clrex_dc1     (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc1 & cp_inst_dc1),
                              .consequent_expr (clrex_dc1 == (cp_op_dc1 == `CA53_CPOP_CLREX)));

  // cp_is_mva_dc2
  // - Any CP operation which does an address translation (including V2P)
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_mva_dc2 mismatch with CP operation type")
  u_ovl_cp_dec_is_mva_dc2    (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc2 & cp_inst_dc2),
                              .consequent_expr (cp_is_mva_dc2 ==
                                                ((cp_op_dc2 == `CA53_CPOP_ICIMVAU)  |
                                                 (cp_op_dc2 == `CA53_CPOP_DCIMVAC)  |
                                                 (cp_op_dc2 == `CA53_CPOP_DCCIMVAC) |
                                                 (cp_op_dc2 == `CA53_CPOP_DCCMVAC)  |
                                                 (cp_op_dc2 == `CA53_CPOP_DCCMVAU)  |
                                                 (cp_op_dc2 == `CA53_CPOP_ATS1C)    |
                                                 (cp_op_dc2 == `CA53_CPOP_ATS12NSO) |
                                                 (cp_op_dc2 == `CA53_CPOP_ATS1H)    |
                                                 (cp_op_dc2 == `CA53_CPOP_ATS1E01)  |
                                                 (cp_op_dc2 == `CA53_CPOP_ATS12E01) |
                                                 (cp_op_dc2 == `CA53_CPOP_ATS1E2)   |
                                                 (cp_op_dc2 == `CA53_CPOP_ATS1E3))));

  // cp_dc_maint_op_dc2
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_dc_maint_op_dc2 mismatch with CP operation type")
  u_ovl_cp_dec_dc_maint_dc2  (.clk            (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc2),
                              .consequent_expr (cp_dc_maint_op_dc2 ==
                                                (cp_inst_dc2 &
                                                 ((cp_op_dc2 == `CA53_CPOP_DCISW)    |
                                                  (cp_op_dc2 == `CA53_CPOP_DCCSW)    |
                                                  (cp_op_dc2 == `CA53_CPOP_DCCISW)   |
                                                  (cp_op_dc2 == `CA53_CPOP_DCIMVAC)  |
                                                  (cp_op_dc2 == `CA53_CPOP_DCCMVAC)  |
                                                  (cp_op_dc2 == `CA53_CPOP_DCCMVAU)  |
                                                  (cp_op_dc2 == `CA53_CPOP_DCCIMVAC)))));

  // cp_is_dc_maint_mva_dc2
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_dc_maint_mva_dc2 mismatch with CP operation type")
  u_ovl_cp_dec_dc_mva_dc2    (.clk            (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc2),
                              .consequent_expr (`CA53_CPOP_IS_DCM_MVA(cp_op_dc2) ==
                                                (cp_inst_dc2 &
                                                 ((cp_op_dc2 == `CA53_CPOP_DCIMVAC)  |
                                                  (cp_op_dc2 == `CA53_CPOP_DCCMVAC)  |
                                                  (cp_op_dc2 == `CA53_CPOP_DCCMVAU)  |
                                                  (cp_op_dc2 == `CA53_CPOP_DCCIMVAC)))));

  // cp_dc_ic_debug_op_dc2
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_dc_ic_debug_op_dc2 mismatch with CP operation type")
  u_ovl_cp_dec_dc_ic_debug_dc2 (.clk            (clk),
                                .reset_n         (reset_n),
                                .antecedent_expr (valid_dc2),
                                .consequent_expr (cp_dc_ic_debug_op_dc2 ==
                                                  (cp_inst_dc2 &
                                                   ((cp_op_dc2 == `CA53_CPOP_CDBGDCT) |
                                                    (cp_op_dc2 == `CA53_CPOP_CDBGDCD) |
                                                    (cp_op_dc2 == `CA53_CPOP_CDBGICT) |
                                                    (cp_op_dc2 == `CA53_CPOP_CDBGICD)))));

  // dxb_dc2
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dxb_dc2 mismatch with CP operation type")
  u_ovl_cp_dec_dxb_dc2       (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc2 & cp_inst_dc2),
                              .consequent_expr (dxb_dc2 ==
                                                ((cp_op_dc2 == `CA53_CPOP_DSBNS) |
                                                 (cp_op_dc2 == `CA53_CPOP_DSBIS) |
                                                 (cp_op_dc2 == `CA53_CPOP_DSBOS) |
                                                 (cp_op_dc2 == `CA53_CPOP_DSBSY) |
                                                 (cp_op_dc2 == `CA53_CPOP_DMBNS) |
                                                 (cp_op_dc2 == `CA53_CPOP_DMBIS) |
                                                 (cp_op_dc2 == `CA53_CPOP_DMBOS) |
                                                 (cp_op_dc2 == `CA53_CPOP_DMBSY) |
                                                 (cp_op_dc2 == `CA53_CPOP_DMBNSST) |
                                                 (cp_op_dc2 == `CA53_CPOP_DMBISST) |
                                                 (cp_op_dc2 == `CA53_CPOP_DMBOSST) |
                                                 (cp_op_dc2 == `CA53_CPOP_DMBSYST))));

  // dsb_dc2
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dsb_dc2 mismatch with CP operation type")
  u_ovl_cp_dec_dsb_dc2       (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc2 & cp_inst_dc2),
                              .consequent_expr (dsb_dc2 ==
                                                ((cp_op_dc2 == `CA53_CPOP_DSBNS) |
                                                 (cp_op_dc2 == `CA53_CPOP_DSBIS) |
                                                 (cp_op_dc2 == `CA53_CPOP_DSBOS) |
                                                 (cp_op_dc2 == `CA53_CPOP_DSBSY))));

  // dmb_dc2
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dmb_dc2 mismatch with CP operation type")
  u_ovl_cp_dec_dmb_dc2       (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc2 & cp_inst_dc2),
                              .consequent_expr (dmb_dc2 ==
                                                ((cp_op_dc2 == `CA53_CPOP_DMBNS) |
                                                 (cp_op_dc2 == `CA53_CPOP_DMBIS) |
                                                 (cp_op_dc2 == `CA53_CPOP_DMBOS) |
                                                 (cp_op_dc2 == `CA53_CPOP_DMBSY) |
                                                 (cp_op_dc2 == `CA53_CPOP_DMBNSST) |
                                                 (cp_op_dc2 == `CA53_CPOP_DMBISST) |
                                                 (cp_op_dc2 == `CA53_CPOP_DMBOSST) |
                                                 (cp_op_dc2 == `CA53_CPOP_DMBSYST))));

  // clrex_dc2
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "clrex_dc2 mismatch with CP operation type")
  u_ovl_cp_dec_clrex_dc2     (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc2 & cp_inst_dc2),
                              .consequent_expr (clrex_dc2 == (cp_op_dc2 == `CA53_CPOP_CLREX)));

  // cp_is_dc_maint_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_dc_maint_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_is_dc_dc3     (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc3 & cp_inst_dc3),
                              .consequent_expr (cp_is_dc_maint_dc3 ==
                                                ((cp_op_dc3 == `CA53_CPOP_DCIMVAC) |
                                                 (cp_op_dc3 == `CA53_CPOP_DCCIMVAC) |
                                                 (cp_op_dc3 == `CA53_CPOP_DCCMVAC) |
                                                 (cp_op_dc3 == `CA53_CPOP_DCCMVAU) |
                                                 (cp_op_dc3 == `CA53_CPOP_DCISW) |
                                                 (cp_op_dc3 == `CA53_CPOP_DCCISW) |
                                                 (cp_op_dc3 == `CA53_CPOP_DCCSW))));

  // cp_is_dc_maint_mva_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_dc_maint_mva_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_is_dc_mva_dc3 (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc3 & cp_inst_dc3),
                              .consequent_expr (`CA53_CPOP_IS_DCM_MVA(cp_op_dc3) ==
                                                ((cp_op_dc3 == `CA53_CPOP_DCIMVAC) |
                                                 (cp_op_dc3 == `CA53_CPOP_DCCIMVAC) |
                                                 (cp_op_dc3 == `CA53_CPOP_DCCMVAC) |
                                                 (cp_op_dc3 == `CA53_CPOP_DCCMVAU))));

  // cp_is_dc_maint_setway_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_dc_maint_setway_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_is_dc_sw_dc3  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc3 & cp_inst_dc3),
                              .consequent_expr (`CA53_CPOP_IS_DCM_SW(cp_op_dc3) ==
                                                ((cp_op_dc3 == `CA53_CPOP_DCISW) |
                                                 (cp_op_dc3 == `CA53_CPOP_DCCISW) |
                                                 (cp_op_dc3 == `CA53_CPOP_DCCSW))));

  // cp_is_ifu_maint_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_ifu_maint_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_is_ifu_m_dc3  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc3 & cp_inst_dc3),
                              .consequent_expr (cp_is_ifu_maint_dc3 ==
                                                ((cp_op_dc3 == `CA53_CPOP_ICIALLU) |
                                                 (cp_op_dc3 == `CA53_CPOP_ICIALLUIS) |
                                                 (cp_op_dc3 == `CA53_CPOP_ICIMVAU))));

  // cp_is_bp_maint_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_bp_maint_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_is_bp_dc3     (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc3 & cp_inst_dc3),
                              .consequent_expr (cp_is_bp_maint_dc3 ==
                                                ((cp_op_dc3 == `CA53_CPOP_BPIALLIS) |
                                                 (cp_op_dc3 == `CA53_CPOP_BPIMVA))));

  // cp_is_v2p_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_v2p_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_is_v2p_dc3    (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc3 & cp_inst_dc3),
                              .consequent_expr (cp_is_v2p_dc3 ==
                                                ((cp_op_dc3 == `CA53_CPOP_ATS1C)    |
                                                 (cp_op_dc3 == `CA53_CPOP_ATS12NSO) |
                                                 (cp_op_dc3 == `CA53_CPOP_ATS1H)    |
                                                 (cp_op_dc3 == `CA53_CPOP_ATS1E01)  |
                                                 (cp_op_dc3 == `CA53_CPOP_ATS12E01) |
                                                 (cp_op_dc3 == `CA53_CPOP_ATS1E2)   |
                                                 (cp_op_dc3 == `CA53_CPOP_ATS1E3))));

  // cp_is_ic_debug_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_ic_debug_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_is_ifu_dc3    (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc3 & cp_inst_dc3),
                              .consequent_expr (cp_is_ic_debug_dc3 ==
                                                ((cp_op_dc3 == `CA53_CPOP_CDBGICT) |
                                                 (cp_op_dc3 == `CA53_CPOP_CDBGICD))));

  // cp_is_ifu_maint_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_ifu_maint_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_is_ifu_maint_dc3    (.clk             (clk),
                                    .reset_n         (reset_n),
                                    .antecedent_expr (valid_dc3 & cp_inst_dc3),
                                    .consequent_expr (cp_is_ifu_maint_dc3 ==
                                                      ((cp_op_dc3 == `CA53_CPOP_ICIALLU)   |
                                                       (cp_op_dc3 == `CA53_CPOP_ICIALLUIS) |
                                                       (cp_op_dc3 == `CA53_CPOP_ICIMVAU))));

  // cp_is_tlb_debug_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_tlb_debug_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_is_tlb_dc3    (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc3 & cp_inst_dc3),
                              .consequent_expr (cp_is_tlb_debug_dc3 ==
                                                ((cp_op_dc3 == `CA53_CPOP_CDBGTD))));

  // cp_is_tlb_maint_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_tlb_maint_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_is_tlb_maint_dc3    (.clk             (clk),
                                    .reset_n         (reset_n),
                                    .antecedent_expr (valid_dc3 & cp_inst_dc3),
                                    .consequent_expr (cp_is_tlb_maint_dc3 ==
                                                      ((cp_op_dc3 == `CA53_CPOP_TLBIALLIS)     |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIMVAIS)     |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIASIDIS)    |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIMVAAIS)    |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIALL)       |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIMVA)       |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIASID)      |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIMVAA)      |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIMVAHIS)    |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIALLHIS)    |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIALLNSNHIS) |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIMVAL)      |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIMVALIS)    |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIMVAAL)     |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIMVAALIS)   |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIMVALH)     |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIMVALHIS)   |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIMVAH)      |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIALLH)      |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIALLNSNH)   |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIIPAS2)     |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIIPAS2IS)   |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIIPAS2L)    |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIIPAS2LIS)  |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVAE1)      |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVAE1IS)    |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVALE1)     |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVALE1IS)   |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVAAE1)     |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVAAE1IS)   |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVAALE1)    |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVAALE1IS)  |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIIPAS2E1)   |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIIPAS2E1IS) |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIIPAS2LE1)  |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIIPAS2LE1IS)|
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVAE2)      |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVAE2IS)    |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVALE2)     |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVALE2IS)   |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVAE3)      |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVAE3IS)    |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVALE3)     |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVALE3IS)   |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIASIDE1)    |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIASIDE1IS)  |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVMALLE1)   |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVMALLE1IS) |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVMALLS12E1)|
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIVMALLS12E1IS) |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIALLE1)     |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIALLE1IS)   |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIALLE2 )    |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIALLE2IS)   |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIALLE3)     |
                                                       (cp_op_dc3 == `CA53_CPOP_TLBIALLE3IS))));

  // cp_is_dc_debug_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_is_dc_debug_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_is_dc_dbg_dc3 (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc3 & cp_inst_dc3),
                              .consequent_expr (cp_is_dc_debug_dc3 ==
                                                ((cp_op_dc3 == `CA53_CPOP_CDBGDCT)  |
                                                 (cp_op_dc3 == `CA53_CPOP_CDBGDCD))));

  // cp_dc_debug_op_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_dc_debug_op_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_dc_debug_dc3  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc3),
                              .consequent_expr (cp_dc_debug_op_dc3 ==
                                                (cp_inst_dc3 &
                                                 ((cp_op_dc3 == `CA53_CPOP_CDBGDCT)  |
                                                  (cp_op_dc3 == `CA53_CPOP_CDBGDCD)))));

  // cp_dc_ic_debug_op_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_dc_ic_debug_op_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_dc_ic_debug_dc3 (.clk            (clk),
                                .reset_n         (reset_n),
                                .antecedent_expr (valid_dc3),
                                .consequent_expr (cp_dc_ic_debug_op_dc3 ==
                                                  (cp_inst_dc3 &
                                                   ((cp_op_dc3 == `CA53_CPOP_CDBGDCT) |
                                                    (cp_op_dc3 == `CA53_CPOP_CDBGDCD) |
                                                    (cp_op_dc3 == `CA53_CPOP_CDBGICT) |
                                                    (cp_op_dc3 == `CA53_CPOP_CDBGICD)))));

  // cp_debug_op_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_debug_op_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_debug_dc3     (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc3),
                              .consequent_expr (cp_debug_op_dc3 ==
                                                (cp_inst_dc3 &
                                                 ((cp_op_dc3 == `CA53_CPOP_CDBGDCT) |
                                                  (cp_op_dc3 == `CA53_CPOP_CDBGDCD) |
                                                  (cp_op_dc3 == `CA53_CPOP_CDBGICT) |
                                                  (cp_op_dc3 == `CA53_CPOP_CDBGICD) |
                                                  (cp_op_dc3 == `CA53_CPOP_CDBGTD)  |
                                                  (cp_op_dc3 == `CA53_CPOP_CDBGDR0) |
                                                  (cp_op_dc3 == `CA53_CPOP_CDBGDR1) |
                                                  (cp_op_dc3 == `CA53_CPOP_CDBGDR2) |
                                                  (cp_op_dc3 == `CA53_CPOP_CDBGDR3)))));

  // dxb_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dxb_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_dxb_dc3       (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc3 & cp_inst_dc3),
                              .consequent_expr (dxb_dc3 ==
                                                ((cp_op_dc3 == `CA53_CPOP_DSBNS) |
                                                 (cp_op_dc3 == `CA53_CPOP_DSBIS) |
                                                 (cp_op_dc3 == `CA53_CPOP_DSBOS) |
                                                 (cp_op_dc3 == `CA53_CPOP_DSBSY) |
                                                 (cp_op_dc3 == `CA53_CPOP_DMBNS) |
                                                 (cp_op_dc3 == `CA53_CPOP_DMBIS) |
                                                 (cp_op_dc3 == `CA53_CPOP_DMBOS) |
                                                 (cp_op_dc3 == `CA53_CPOP_DMBSY) |
                                                 (cp_op_dc3 == `CA53_CPOP_DMBNSST) |
                                                 (cp_op_dc3 == `CA53_CPOP_DMBISST) |
                                                 (cp_op_dc3 == `CA53_CPOP_DMBOSST) |
                                                 (cp_op_dc3 == `CA53_CPOP_DMBSYST))));

  // dsb_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dsb_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_dsb_dc3       (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc3 & cp_inst_dc3),
                              .consequent_expr (dsb_dc3 ==
                                                ((cp_op_dc3 == `CA53_CPOP_DSBNS) |
                                                 (cp_op_dc3 == `CA53_CPOP_DSBIS) |
                                                 (cp_op_dc3 == `CA53_CPOP_DSBOS) |
                                                 (cp_op_dc3 == `CA53_CPOP_DSBSY))));

  // dmb_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dmb_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_dmb_dc3       (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc3 & cp_inst_dc3),
                              .consequent_expr (dmb_dc3 ==
                                                ((cp_op_dc3 == `CA53_CPOP_DMBNS) |
                                                 (cp_op_dc3 == `CA53_CPOP_DMBIS) |
                                                 (cp_op_dc3 == `CA53_CPOP_DMBOS) |
                                                 (cp_op_dc3 == `CA53_CPOP_DMBSY) |
                                                 (cp_op_dc3 == `CA53_CPOP_DMBNSST) |
                                                 (cp_op_dc3 == `CA53_CPOP_DMBISST) |
                                                 (cp_op_dc3 == `CA53_CPOP_DMBOSST) |
                                                 (cp_op_dc3 == `CA53_CPOP_DMBSYST))));

  // dmbld_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dmbld_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_dmbld_dc3       (.clk             (clk),
                                .reset_n         (reset_n),
                                .antecedent_expr (valid_dc3 & cp_inst_dc3),
                                .consequent_expr (dmbld_dc3 ==
                                                  ((cp_op_dc3 == `CA53_CPOP_DMBNSHLD) |
                                                   (cp_op_dc3 == `CA53_CPOP_DMBISHLD) |
                                                   (cp_op_dc3 == `CA53_CPOP_DMBOSHLD) |
                                                   (cp_op_dc3 == `CA53_CPOP_DMBLD))));

  // clrex_dc3
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "clrex_dc3 mismatch with CP operation type")
  u_ovl_cp_dec_clrex_dc3     (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (valid_dc3 & cp_inst_dc3),
                              .consequent_expr (clrex_dc3 == (cp_op_dc3 == `CA53_CPOP_CLREX)));


  //--------------------------
  // Register enable X-checks
  //--------------------------

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 8, `OVL_ASSERT, "Register enable x-check: data_en_dc2")
  u_ovl_x_data_en_dc2  (.clk       (clk_dc2),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (data_en_dc2));

  assert_never_unknown #(`OVL_FATAL, 8, `OVL_ASSERT, "Register enable x-check: data_en_dc3")
  u_ovl_x_data_en_dc3  (.clk       (clk_dc3),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (data_en_dc3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: abort_dc2_en")
  u_ovl_x_abort_dc2_en (.clk       (clk_dc2),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (abort_dc2_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: enable_va_top_byte_dc2")
  u_ovl_x_enable_va_top_byte_dc2 (.clk       (clk_dc2),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (enable_va_top_byte_dc2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: enable_va_top_byte_dc3")
  u_ovl_x_enable_va_top_byte_dc3 (.clk       (clk_dc3),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (enable_va_top_byte_dc3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: enable_va_upper_dc2")
  u_ovl_x_enable_va_upper_dc2 (.clk       (clk_dc2),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (enable_va_upper_dc2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: enable_va_upper_dc3")
  u_ovl_x_enable_va_upper_dc3 (.clk       (clk_dc3),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (enable_va_upper_dc3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: fault_dc2_en")
  u_ovl_x_fault_dc2_en (.clk       (clk_dc2),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (fault_dc2_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: fault_dc3_en")
  u_ovl_x_fault_dc3_en (.clk       (clk_dc3),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (fault_dc3_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_sameline_en")
  u_ovl_x_load_sameline_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (load_sameline_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: set_exclusive_monitor")
  u_ovl_x_set_exclusive_monitor (.clk       (clk_rare),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (set_exclusive_monitor));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: gov_cp_data_en_dc3")
  u_ovl_x_gov_cp_data_en_dc3 (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (gov_cp_data_en_dc3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: gov_cp_req_data_en_dc3")
  u_ovl_x_gov_cp_req_data_en_dc3 (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (gov_cp_req_data_en_dc3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dcu_leaving_dc2")
  u_ovl_x_dcu_leaving_dc2 (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (dcu_leaving_dc2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reg_en_dc1")
  u_ovl_x_reg_en_dc1 (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (reg_en_dc1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reg_en_dc3")
  u_ovl_x_reg_en_dc3 (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (reg_en_dc3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reg_en_stall_dc2")
  u_ovl_x_reg_en_stall_dc2 (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (reg_en_stall_dc2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reg_en_valid_dc2")
  u_ovl_x_reg_en_valid_dc2 (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (reg_en_valid_dc2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable X-Check: v_enable_dc1")
  u_ovl_x_check_v_enable_dc1 (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (v_enable_dc1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable X-Check: enable_dc1")
  u_ovl_x_check_enable_dc1 (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (enable_dc1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable X-Check: v_enable_dc2")
  u_ovl_x_check_v_enable_dc2 (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (v_enable_dc2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable X-Check: enable_dc2")
  u_ovl_x_check_enable_dc2 (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (enable_dc2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable X-Check: enable_transl_dc2")
  u_ovl_x_check_enable_transl_dc2 (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (enable_transl_dc2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable X-Check: stall_dc2")
  u_ovl_x_check_stall_dc2 (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (stall_dc2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable X-Check: merge_sameline_en")
  u_ovl_x_check_merge_sameline_en (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (merge_sameline_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable X-Check: v_enable_dc3")
  u_ovl_x_check_v_enable_dc3 (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (v_enable_dc3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable X-Check: enable_dc3")
  u_ovl_x_check_enable_dc3 (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (enable_dc3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable X-Check: enable_transl_dc3")
  u_ovl_x_check_enable_transl_dc3 (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (enable_transl_dc3));


  //---------------------------
  // Mux enable one-hot checks
  //---------------------------

  // fault_dc1
  assert_zero_one_hot #(`OVL_FATAL, 5, `OVL_ASSERT, "fault_dc1 enables must be one hot")
  u_ovl_fault_dc1_en_oneh   (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr ({5{valid_dc1 & (abort_dc1 | v2p_abort_dc1)}} &
                                         {align_fault_taken_dc1,
                                          stack_align_fault_taken_dc1,
                                          dpu_fault_taken_dc1 | va_fault_taken_dc1, // Can happen at same time with same fault type
                                          perm_fault_taken_dc1,
                                          ~((unaligned_dc1 &
                                             (req_align_dc1 | ~normal_dc1)) |
                                            dpu_abort_dc1_i |
                                            stack_align_fault_taken_dc1 |
                                            va_fault_taken_dc1 |
                                            perm_fault_s1_dc1 |
                                            perm_fault_s2_dc1)}));

  // - when there is an abort/v2p_abort in DC1, one of the fault_dc1 mux
  // enable terms must be asserted.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "fault_dc1 must have one enable term asserted when there is an abort in DC1")
  u_ovl_fault_dc1_en_abt    (.clk             (clk),
                             .reset_n         (reset_n),
                             .antecedent_expr (valid_dc1 & (abort_dc1 | v2p_abort_dc1) & dpu_utlb_hit_dc1_i & dcu_va_valid_dc1 & ~flush_dc1),
                             .consequent_expr (|{align_fault_taken_dc1,
                                                 dpu_fault_taken_dc1,
                                                 stack_align_fault_taken_dc1,
                                                 va_fault_taken_dc1,
                                                 perm_fault_taken_dc1,
                                                 stack_align_fault_taken_dc1,
                                                 ~((unaligned_dc1 &
                                                    (req_align_dc1 | ~normal_dc1)) |
                                                   dpu_abort_dc1_i |
                                                   stack_align_fault_taken_dc1 |
                                                   va_fault_taken_dc1 |
                                                   perm_fault_s1_dc1 |
                                                   perm_fault_s2_dc1)}));

  // fault_stage_dc1
  assert_zero_one_hot #(`OVL_FATAL, 3, `OVL_ASSERT, "fault_stage_dc1 enables must be one hot")
  u_ovl_fault_stage_dc1_en  (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr ({3{valid_dc1 & (abort_dc1 | v2p_abort_dc1)}} &
                                         {align_fault_s2_dc1,
                                          dpu_fault_taken_dc1,
                                          (perm_fault_taken_dc1 & ~perm_fault_s1_dc1)}));

  // next_data_dc2 (each byte should be one-hot)
  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "data_dc2 mux enables (lane 7)")
  u_ovl_data_dc2_en_7      (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({data_dc_mux_en_dc2[7], data_stb_mux_en_dc2[7], data_biu_mux_en_dc2[7], tag_debug_op_ack_i}));

  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "data_dc2 mux enables (lane 6)")
  u_ovl_data_dc2_en_6      (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({data_dc_mux_en_dc2[6], data_stb_mux_en_dc2[6], data_biu_mux_en_dc2[6], tag_debug_op_ack_i}));

  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "data_dc2 mux enables (lane 5)")
  u_ovl_data_dc2_en_5      (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({data_dc_mux_en_dc2[5], data_stb_mux_en_dc2[5], data_biu_mux_en_dc2[5], tag_debug_op_ack_i}));

  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "data_dc2 mux enables (lane 4)")
  u_ovl_data_dc2_en_4      (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({data_dc_mux_en_dc2[4], data_stb_mux_en_dc2[4], data_biu_mux_en_dc2[4], tag_debug_op_ack_i}));

  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "data_dc2 mux enables (lane 3)")
  u_ovl_data_dc2_en_3      (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({data_dc_mux_en_dc2[3], data_stb_mux_en_dc2[3], data_biu_mux_en_dc2[3], tag_debug_op_ack_i}));

  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "data_dc2 mux enables (lane 2)")
  u_ovl_data_dc2_en_2      (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({data_dc_mux_en_dc2[2], data_stb_mux_en_dc2[2], data_biu_mux_en_dc2[2], tag_debug_op_ack_i}));

  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "data_dc2 mux enables (lane 1)")
  u_ovl_data_dc2_en_1      (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({data_dc_mux_en_dc2[1], data_stb_mux_en_dc2[1], data_biu_mux_en_dc2[1], tag_debug_op_ack_i}));

  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "data_dc2 mux enables (lane 0)")
  u_ovl_data_dc2_en_0      (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({data_dc_mux_en_dc2[0], data_stb_mux_en_dc2[0], data_biu_mux_en_dc2[0], tag_debug_op_ack_i}));

  // next_data_dc3 (each byte should be one-hot)
  assert_zero_one_hot #(`OVL_FATAL, 6, `OVL_ASSERT, "data_dc3 mux enables (lane 7)")
  u_ovl_data_dc3_en_7      (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({6{data_en_dc3[7]}} & {ld_data_dc_en_dc3[7], ld_data_stb_en_dc3[7], ld_data_biu_dc2_en_dc3[7], ld_data_dc2_en_dc3[7], ld_data_tlb_en_dc3[7], ld_data_biu_dc3_en_dc3[7]}));

  assert_zero_one_hot #(`OVL_FATAL, 6, `OVL_ASSERT, "data_dc3 mux enables (lane 6)")
  u_ovl_data_dc3_en_6      (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({6{data_en_dc3[6]}} & {ld_data_dc_en_dc3[6], ld_data_stb_en_dc3[6], ld_data_biu_dc2_en_dc3[6], ld_data_dc2_en_dc3[6], ld_data_tlb_en_dc3[6], ld_data_biu_dc3_en_dc3[6]}));

  assert_zero_one_hot #(`OVL_FATAL, 6, `OVL_ASSERT, "data_dc3 mux enables (lane 5)")
  u_ovl_data_dc3_en_5      (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({6{data_en_dc3[5]}} & {ld_data_dc_en_dc3[5], ld_data_stb_en_dc3[5], ld_data_biu_dc2_en_dc3[5], ld_data_dc2_en_dc3[5], ld_data_tlb_en_dc3[5], ld_data_biu_dc3_en_dc3[5]}));

  assert_zero_one_hot #(`OVL_FATAL, 6, `OVL_ASSERT, "data_dc3 mux enables (lane 4)")
  u_ovl_data_dc3_en_4      (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({6{data_en_dc3[4]}} & {ld_data_dc_en_dc3[4], ld_data_stb_en_dc3[4], ld_data_biu_dc2_en_dc3[4], ld_data_dc2_en_dc3[4], ld_data_tlb_en_dc3[4], ld_data_biu_dc3_en_dc3[4]}));

  assert_zero_one_hot #(`OVL_FATAL, 6, `OVL_ASSERT, "data_dc3 mux enables (lane 3)")
  u_ovl_data_dc3_en_3      (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({6{data_en_dc3[3]}} & {ld_data_dc_en_dc3[3], ld_data_stb_en_dc3[3], ld_data_biu_dc2_en_dc3[3], ld_data_dc2_en_dc3[3], ld_data_tlb_en_dc3[3], ld_data_biu_dc3_en_dc3[3]}));

  assert_zero_one_hot #(`OVL_FATAL, 6, `OVL_ASSERT, "data_dc3 mux enables (lane 2)")
  u_ovl_data_dc3_en_2      (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({6{data_en_dc3[2]}} & {ld_data_dc_en_dc3[2], ld_data_stb_en_dc3[2], ld_data_biu_dc2_en_dc3[2], ld_data_dc2_en_dc3[2], ld_data_tlb_en_dc3[2], ld_data_biu_dc3_en_dc3[2]}));

  assert_zero_one_hot #(`OVL_FATAL, 6, `OVL_ASSERT, "data_dc3 mux enables (lane 1)")
  u_ovl_data_dc3_en_1      (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({6{data_en_dc3[1]}} & {ld_data_dc_en_dc3[1], ld_data_stb_en_dc3[1], ld_data_biu_dc2_en_dc3[1], ld_data_dc2_en_dc3[1], ld_data_tlb_en_dc3[1], ld_data_biu_dc3_en_dc3[1]}));

  assert_zero_one_hot #(`OVL_FATAL, 6, `OVL_ASSERT, "data_dc3 mux enables (lane 0)")
  u_ovl_data_dc3_en_0      (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({6{data_en_dc3[0]}} & {ld_data_dc_en_dc3[0], ld_data_stb_en_dc3[0], ld_data_biu_dc2_en_dc3[0], ld_data_dc2_en_dc3[0], ld_data_tlb_en_dc3[0], ld_data_biu_dc3_en_dc3[0]}));

  // par_vmsa_inner_dc3
  assert_zero_one_hot #(`OVL_FATAL, 5, `OVL_ASSERT, "par_vmsa_inner_dc3 enables one-hot")
  u_ovl_par_vmsa_inner_onehot (.clk       (clk),
                               .reset_n   (reset_n),
                               .test_expr ({5{valid_dc3}} & {`CA53_MEM_WB(attrs_dc3) & ~`CA53_MEM_WBWA(attrs_dc3),
                                                             `CA53_MEM_WT(attrs_dc3),
                                                             `CA53_MEM_WBWA(attrs_dc3),
                                                             `CA53_MEM_GRE(attrs_dc3) |
                                                             `CA53_MEM_nGRE(attrs_dc3) |
                                                             `CA53_MEM_nGnRE(attrs_dc3),
                                                             `CA53_MEM_nGnRnE(attrs_dc3)}));

  // par_lpae_attrs_dc3
  assert_zero_one_hot #(`OVL_FATAL, 5, `OVL_ASSERT, "par_lpae_attrs_dc3 enables one-hot")
  u_ovl_par_lpae_attrs_onehot (.clk       (clk),
                               .reset_n   (reset_n),
                               .test_expr ({5{valid_dc3}} & {`CA53_MEM_GRE(attrs_dc3),
                                                             `CA53_MEM_nGRE(attrs_dc3),
                                                             `CA53_MEM_nGnRE(attrs_dc3),
                                                             `CA53_MEM_nGnRnE(attrs_dc3),
                                                             `CA53_MEM_NORMAL(attrs_dc3)}));

  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "par_lpae_inner_attrs_dc3 enables one-hot")
  u_ovl_par_lpae_inner_attrs_onehot (.clk       (clk),
                                     .reset_n   (reset_n),
                                     .test_expr ({4{valid_dc3}} & {`CA53_MEM_NC(attrs_dc3),
                                                                   `CA53_MEM_WB(attrs_dc3) & ~`CA53_MEM_COHERENT(attrs_dc3),
                                                                   `CA53_MEM_WB(attrs_dc3) & `CA53_MEM_COHERENT(attrs_dc3),
                                                                   `CA53_MEM_WT(attrs_dc3)}));

  assert_zero_one_hot #(`OVL_FATAL, 3, `OVL_ASSERT, "par_lpae_outer_attrs_dc3 enables one-hot")
  u_ovl_par_lpae_outer_attrs_onehot (.clk       (clk),
                                     .reset_n   (reset_n),
                                     .test_expr ({3{valid_dc3}} & {`CA53_MEM_OUTER_NC(attrs_dc3),
                                                                   `CA53_MEM_OUTER_WT(attrs_dc3),
                                                                   `CA53_MEM_OUTER_WB(attrs_dc3)}));


  // dcu_cp_reg_en_dc3
  assert_zero_one_hot #(`OVL_FATAL, 3, `OVL_ASSERT, "dcu_cp_reg_en_dc3 enables one-hot")
  u_ovl_dcu_cp_reg_en_onehot  (.clk       (clk),
                               .reset_n   (reset_n),
                               .test_expr ({3{dcu_cp_reg_write_dc3_o}} &
                                           {(cp_op_dc3[6:3] == 4'b0001),
                                            (cp_dc_debug_op_dc3),
                                            ((cp_op_dc3[6:3] != 4'b0001) & ~cp_dc_debug_op_dc3)}));


  //----------------------------
  // Interfaces to other blocks
  //----------------------------

  // The priority scheme in the cache arbiter should ensure that a load is not
  // stalled or throttled for longer than a maximum number of cycles. Since data
  // requests are the highest priorty request, and tag accesses are only blocked
  // by CCB requests which cannot be made back to back, the upper bound on how
  // long a load can stall is set by how long a load can be throttled for. The
  // worst case for that is when a prearb request is being blocked by a snoop
  // request, where loads will be blocked for up to 3 cycles while the snoop
  // drains, then an additional cycle when the prearb request drains. The
  // maximum stall is therefore 4 cycles.
  reg [3:0] ovl_load_m1_stall_count;
  reg       ovl_block_loads_no_throttle_dc1;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_block_loads_no_throttle_dc1 <= 1'b0;
    else
      ovl_block_loads_no_throttle_dc1 <= next_misc_stall_load |
                                         (dcu_stb_req_dc3 & (dmb_full_dc3 |
                                                             (ldar_stlr_dc3 & store_dc3) |
                                                             cp_is_dc_maint_dc3));

  wire ovl_load_req_m1_no_throttle = valid_dc1 & load_dc1 &
                                     ~dc_inv_all_in_progress_i & ~tlb_lookup_stall_dc1 &
                                     ~ovl_block_loads_no_throttle_dc1 &
                                     ~(valid_dc2 & valid_dc3 & ~dcu_valid_dc3 & ~dpu_ready_cc_fail_wr_i);

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_load_m1_stall_count <= {4{1'b0}};
    else
      ovl_load_m1_stall_count <= (ovl_load_req_m1_no_throttle & ~(dc_load_req_m1_o & dc_load_has_priority_m1_i)) ? (ovl_load_m1_stall_count + 1'b1)
                                                                                                                 : {4{1'b0}};

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "Load request stalled longer than theoretical maximum")
  u_ovl_load_cache_stall_max       (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .test_expr (ovl_load_m1_stall_count <= 4'd4));

  // The DCU takes the size given to the TLB on reg writes from one bit of
  // the size. This is possible as the size should always be word or
  // doubleword on TLB reg writes. Note that the size is forced for V2P PAR
  // writes, and the TLB ignores the size on CDBGDRn writes, so the size does
  // not have to be accurate in those cases.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The size for CP reg writes should always be word or doubleword")
  u_ovl_cp_reg_wr_size   (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (dcu_cp_reg_write_dc3_o & ~(cp_inst_dc3 & (cp_is_v2p_dc3 | cp_dc_debug_op_dc3))),
                          .consequent_expr ((dcu_size_dc3 == `CA53_SIZE_WORD) |
                                            (dcu_size_dc3 == `CA53_SIZE_DWORD)));

  // The DCU should never issue a CP write on the same cycle as a CP read, as
  // this could cause a RAW hazard.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "DCU should never do CP write at same time as CP read")
  u_ovl_cp_reg_rd_wr     (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (dcu_cp_reg_write_dc3_o),
                          .consequent_expr (~dcu_cp_read_dc2));

  // CP reads are issued from DC2 and writes from DC3. This means there
  // cannot be a write on the cycle after a read, as it would have to be from
  // the same instruction.
  reg ovl_prev_cp_read;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_prev_cp_read <= 1'b0;
    else
      ovl_prev_cp_read <= dcu_cp_read_dc2;

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "DCU should never do CP write on cycle after CP read")
  u_ovl_cp_reg_rd_prev   (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (dcu_cp_reg_write_dc3_o),
                          .consequent_expr (~ovl_prev_cp_read));

  // DCU Should never make an STB request for a CC failing instruction
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "CC Failing instructions should not make STB reqs")
  u_ovl_stb_req_cc_fail  (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (dcu_stb_req_dc3),
                          .consequent_expr (~dpu_ready_cc_fail_wr_i));

  // The force miss signal from the CP15 block is used in DC2, and should be
  // valid by the time an instruction reaches that far.
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "cp15_force_miss never X when DC2 valid")
  u_ovl_cp15_force_miss_dc2 (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (valid_dc2),
                             .test_expr (cp15_inv_all_force_miss_i));

  // The CP15 block should always assert force reset on the first cycle out
  // of reset
  reg ovl_first_cycle_after_reset;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_first_cycle_after_reset <= 1'b1;
    else
      ovl_first_cycle_after_reset <= 1'b0;

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "CP15 should indicate force_reset on first cycle after reset")
  u_ovl_force_reset      (.clk             (clk),
                          .reset_n         (reset_n),
                          .test_expr       (force_reset_i == ovl_first_cycle_after_reset));

  // The CP15 block should only ack a CP15 operation when one is in progress
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "CP15 should only ack an operation when one is being requested")
  u_ovl_cp15_ack         (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (dc_cp15_ack_i),
                          .consequent_expr (dc_cp15_start_dc3_o));

  // The CP15 block should only ack a DC CP15 operation (maintenance or
  // debug)
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "CP15 should only ack an operation when one is being requested")
  u_ovl_cp15_ack_op_type (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (dc_cp15_ack_i),
                          .consequent_expr (cp_is_dc_debug_dc3));

  // Debug op acks should be received with the normal ack
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "CP15 should ack debug when operation complete")
  u_ovl_cp15_debug_ack   (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (tag_debug_op_ack_i | data_debug_op_ack_i),
                          .consequent_expr (dc_cp15_ack_i));

  // The debug_op_ack signals from the CP15 block should never be X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "tag_debug_op_ack should never be X")
  u_ovl_x_tag_debug_op_ack       (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (tag_debug_op_ack_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "data_debug_op_ack should never be X")
  u_ovl_x_data_debug_op_ack      (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (data_debug_op_ack_i));

  // The debug_op_ack signals from the CP15 block should only be asserted
  // when there is a debug op of the type being acked in DC3.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Tag debug ops should only be acked when there is a valid tag debug op")
  u_ovl_tag_debug_ack_valid  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (tag_debug_op_ack_i),
                              .consequent_expr (valid_dc3 & dpu_ready_wr_i & ~dpu_cc_fail_wr_i & cp_inst_dc3 & (cp_op_dc3 == `CA53_CPOP_CDBGDCT)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Data debug ops should only be acked when there is a valid data debug op")
  u_ovl_data_debug_ack_valid (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (data_debug_op_ack_i),
                              .consequent_expr (valid_dc3 & dpu_ready_wr_i & ~dpu_cc_fail_wr_i & cp_inst_dc3 & (cp_op_dc3 == `CA53_CPOP_CDBGDCD)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dpu_kill_wr must flush at least one pipeline stage")
  u_ovl_dpu_kill_wr_flushes_lspipe (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (dpu_kill_wr_i),
                                   .consequent_expr (flush_dc1 | flush_dc2 | flush_dc3));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dpu_flush without dpu_ready_wr and dpu_kill_wr must flush at least one pipeline stage")
  u_ovl_dpu_flush_flushes_lspipe (.clk             (clk),
                                  .reset_n         (reset_n),
                                  .antecedent_expr (dpu_flush_i & ~dpu_ready_wr_i),
                                  .consequent_expr (flush_dc1 | flush_dc2 | flush_dc3));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dpu_flush with dpu_ready_wr and no dpu_kill_wr can only flush DC2 and/or DC1")
  u_ovl_dpu_flush_ready_wr_lspipe (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (dpu_flush_i & dpu_ready_wr_i & ~dpu_kill_wr_i),
                                   .consequent_expr ((~flush_dc1 & ~flush_dc2 & ~flush_dc3) |
                                                     (~flush_dc1 & flush_dc2 & ~flush_dc3) |
                                                     (flush_dc1 & flush_dc2 & ~flush_dc3) |
                                                     (flush_dc1 & ~flush_dc2 & ~flush_dc3)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dpu_cc_fail_wr must flush at least one pipeline stage")
  u_ovl_dpu_cc_fail_flushes_lspipe (.clk             (clk),
                                    .reset_n         (reset_n),
                                    .antecedent_expr (dpu_cc_fail_wr_i & dpu_ready_wr_i),
                                    .consequent_expr (cc_fail_dc1 | cc_fail_dc2 | (dpu_ready_cc_fail_wr_i & valid_dc3)));

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "If flushing DC1 and DC3, must also flush DC2")
  u_ovl_flush_illegal_dc1 (.clk (clk),
                              .reset_n (reset_n),
                              .test_expr (flush_dc1 & ~flush_dc2 & flush_dc3));

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "If ccfailing DC1 and DC3, must also ccfail DC2")
  u_ovl_ccfail_illegal_dc1 (.clk (clk),
                            .reset_n (reset_n),
                            .test_expr (cc_fail_dc1 & ~cc_fail_dc2 & (dpu_ready_cc_fail_wr_i & valid_dc3)));

  reg       ovl_dcu_va_valid_dc1_reg;
  reg       ovl_dpu_utlb_hit_dc1_reg;
  reg [2:0] ovl_dcu_transl_type_dc1_reg;

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_dcu_va_valid_dc1_reg    <= 1'b0;
      ovl_dpu_utlb_hit_dc1_reg    <= 1'b0;
      ovl_dcu_transl_type_dc1_reg <= 2'b00;
    end else begin
      ovl_dcu_va_valid_dc1_reg    <= dcu_va_valid_dc1;
      ovl_dpu_utlb_hit_dc1_reg    <= dpu_utlb_hit_dc1_i;
      ovl_dcu_transl_type_dc1_reg <= dcu_transl_type_dc1;
    end

  wire transl_valid_dc1 = dcu_va_valid_dc1 & dpu_utlb_hit_dc1_i;  // Translation is valid on the cycle the hit signal is asserted and the VA is still marked as valid

  assert_implication #(`OVL_FATAL, `OVL_ASSERT,
    "While lookup request stays high and ready is not signalled, the transl type should not change unless the operation has been flushed")
  u_ovl_transl_type_dc1 (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (ovl_dcu_va_valid_dc1_reg & dcu_va_valid_dc1 & ~ovl_dpu_utlb_hit_dc1_reg & ~transl_valid_dc1),
                         .consequent_expr ((dcu_transl_type_dc1 == ovl_dcu_transl_type_dc1_reg) | dpu_flush_i));

  // The lspipe will suppress load lookups during invalidate all on reset, and
  // the cachearb will block prearb requests, so there can never be an ECC error
  // indicated for a load which which was issued during invalidate all on reset.

  // - cp15_inv_all_force_miss_i is set up to last request M2, so register to
  // catch last requests M3 cycle.
  reg ovl_inv_all_force_miss_reg;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_inv_all_force_miss_reg <= 1'b0;
    else
      ovl_inv_all_force_miss_reg <= cp15_inv_all_force_miss_i;

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Can't get ECC error indicated to lspipe during invalidate all on reset")
  u_ovl_ecc_err_inv_all  (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (cp15_inv_all_force_miss_i | ovl_inv_all_force_miss_reg),
                          .consequent_expr (~dc_ecc_err_m3_i));


  //-----------------------------------------------
  // Additional properties for Formal Verification
  //-----------------------------------------------
  // The following assertions are required for DCU formal verification and
  // are converted to assumes when running the formal tool. They are
  // included here rather than in the interface files because they either
  // rely on signals that are not available on the interfaces, or rely on
  // properties of several blocks in combination.

  // The BIU should only assert strex_bresp_valid for exclusives which are
  // shareable and do not use ACE transactions on AXI. This is a property of
  // both the STB/BIU interface (that the STB will only request an AXI request
  // which can generate biu_strex_bresp_valid when it contains a suitable
  // STREX) and the DCU (that it will not retire the STREX after putting in
  // to the STB until it sees the response).
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "biu_strex_bresp should only be used for shareable, non-ACE STREXs")
  u_ovl_strex_bresp      (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (biu_strex_bresp_valid_i),
                          .consequent_expr (valid_dc3 & store_dc3 & dcu_excl_shareable_dc3 & store_sent_dc3 & ~`CA53_MEM_COHERENT(attrs_dc3)));

  // The BIU will not provide a response for a STREX until after the STREX
  // has left the STB.
  reg       ovl_shareable_exclusive_in_progress;
  reg       ovl_seen_exclusive_stb_drain;
  reg       ovl_shareable_exclusive_in_progress_reg;
  reg [4:0] ovl_stb_slots_valid_reg;

  wire ovl_slots_draining = |ovl_stb_slots_valid_reg & ~|stb_slots_valid_i;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_shareable_exclusive_in_progress <= 1'b0;
    else if ((dcu_exclusive_dc3_o && dcu_stb_req_dc3 && ~dpu_kill_wr_i) || dcu_leaving_dc2)
      ovl_shareable_exclusive_in_progress <= dcu_stb_req_dc3 & ~dpu_kill_wr_i & dcu_exclusive_dc3_o & store_dc3 &
                                             `CA53_MEM_SHAREABLE(attrs_dc3) & ~dcu_leaving_dc2;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_seen_exclusive_stb_drain <= 1'b0;
    else if ((ovl_shareable_exclusive_in_progress_reg && ovl_slots_draining) || dcu_leaving_dc2)
      ovl_seen_exclusive_stb_drain <= (ovl_shareable_exclusive_in_progress_reg & ovl_slots_draining & ~(dcu_stb_req_dc3 & ~dpu_kill_wr_i)) & ~dcu_leaving_dc2;

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_stb_slots_valid_reg                 <= 5'b00000;
      ovl_shareable_exclusive_in_progress_reg <= 1'b0;
    end else begin
      ovl_stb_slots_valid_reg                 <= stb_slots_valid_i;
      ovl_shareable_exclusive_in_progress_reg <= ovl_shareable_exclusive_in_progress;
    end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "BIU should only provide STREX BRESP after STREX left STB")
  u_ovl_exclusive_bresp (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (dcu_exclusive_dc3_o & ~ovl_seen_exclusive_stb_drain),
                         .consequent_expr (~biu_strex_bresp_valid_i));

  // The BIU will not provide data for a governor access, but this cannot be
  // checked in the interface as it does not know about governor accesses.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "BIU cannot provide read data for governor accesses - DC2")
  u_ovl_biu_gov_dc2     (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (dcu_load_dc2 & gov_mem_access_dc2 & ~gov_mem_abort_dc2),
                         .consequent_expr (~biu_read_data_valid_dc2_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "BIU cannot provide read data for governor accesses - DC3")
  u_ovl_biu_gov_dc3     (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (dcu_load_dc3 & gov_mem_access_dc3 & ~abort_dc3),
                         .consequent_expr (~biu_read_data_valid_dc3_i));

  // When the TLB ack's a cp operation, it will normally flush the uTLB on
  // the next cycle. This can be deferred by an ongoing burst, in which case
  // the flush will happen as soon as the ongoing burst signal is deasserted.
  // The flush means that anything in iss, moving into DC1 on the cycle the
  // flush happens, should not hit in the uTLB on the first cycle it is in
  // DC1.
  // The lists in the DVM block rely on this behaviour, but the necessary
  // signals are not available there.
  // This is a property of the DCU/TLB/DPU and so cannot be asserted on any
  // single interface.
  reg ovl_utlb_flush_pending;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_utlb_flush_pending <= 1'b0;
    else
      ovl_utlb_flush_pending <= tlb_cp_ack_i | (ovl_utlb_flush_pending & dcu_ongoing_burst_dc1);

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "uTLB being flushed should suppress uTLB hit for an instruction leaving iss on the same cycle")
  u_ovl_utlb_flush_hit_suppress    (.clk         (clk),
                                    .reset_n     (reset_n),
                                    .start_event (ovl_utlb_flush_pending & ~dcu_ongoing_burst_dc1 & v_enable_dc1),
                                    .test_expr   (~(dcu_va_valid_dc1 & dpu_utlb_hit_dc1_i)));

  // Aborts, other than domain faults, can only be indicated as a result of
  // a main TLB lookup, not a uTLB hit.
  // This is a property of the DCU/TLB/DPU and so cannot be asserted on any
  // single interface.
  reg ovl_prev_utlb_hit_dc1;
  reg ovl_prev_abort_dc1;
  reg ovl_prev_va_valid_dc1;
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_prev_utlb_hit_dc1 <= 1'b0;
      ovl_prev_abort_dc1    <= 1'b0;
      ovl_prev_va_valid_dc1 <= 1'b0;
    end else begin
      ovl_prev_utlb_hit_dc1 <= dpu_utlb_hit_dc1_i;
      ovl_prev_abort_dc1    <= dpu_abort_dc1_i;
      ovl_prev_va_valid_dc1 <= dcu_va_valid_dc1;
    end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Aborts can only be reported on lookups, not utlb hits")
  u_ovl_abort_only_on_lookup      (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (dcu_va_valid_dc1 &
                                                     dpu_abort_dc1_i & ~ovl_prev_abort_dc1 &            // Abort becoming set this cycle
                                                     ~`CA53_FAULT_DOMAIN(dpu_fault_type_dc1)),
                                   .consequent_expr (~ovl_prev_utlb_hit_dc1 & ovl_prev_va_valid_dc1));  // => requesting lookup in previous cycle

  // The only time the BIU can indicate it has data available for
  // a non-cacheable load in DC2 is if it is part of a multiple, for which
  // the first has already reached DC3 and made a request.
  // This cannot be asserted in the DCU/BIU interface as the relationship
  // between data being provided for beats of a burst and the related
  // instructions progress down the DCU pipeline is a property of the DPU/DCU
  // interface and the DCU internal state, which is not available on the
  // interface, so it is not possible to accurately track the progress of the
  // multiple in the interface.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "BIU should not provide data for non-cacheable first in DC2")
  u_ovl_biu_nc_load_dc2  (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (valid_dc2 & first_dc2 & ~cacheable_dc2 & enable_dc3), // data_valid is valid for DC2 on cycle it moves into DC3
                          .consequent_expr (~(biu_read_data_valid_dc2_i & dcu_load_dc2)));

  // The DPU will give the same result for a translation to an address as the
  // previous translation for the same page if neither translation was for
  // a CP15, the first translation didn't abort, and the second translation
  // hits in the uTLB.
  // This cannot be asserted in the interface without modelling the uTLB,
  // because after a translation to an address, there could be any number of
  // subsequent translations to different addresses which are all flushed,
  // followed by a translation to the original address. The DCU relies on
  // that final translation getting the same result as the first.

  reg [3:0]   ovl_prev_transl_utlb_entry;
  reg [39:12] ovl_prev_transl_pa;
  reg [63:12] ovl_prev_transl_va;
  reg [12:0]  ovl_prev_transl_attrs;
  reg         ovl_prev_transl_ns;
  reg         ovl_prev_transl_lpae;
  reg         ovl_prev_transl_valid;
  reg         ovl_prev_cache_off;
  reg         ovl_prev_aa64;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_prev_transl_valid <= 1'b0;
    else
      ovl_prev_transl_valid <= cc_fail_or_flush_dc1 ? 1'b0 :
                               enable_dc2           ? (abort_dc1 ? 1'b0 : (dpu_utlb_hit_dc1_i & ~cp_inst_dc1 & ~dpu_abort_dc1_i))
                                                    : (ovl_prev_transl_valid & ~(valid_dc1 & (cp_inst_dc1 | ~dpu_utlb_hit_dc1_i)));

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_prev_transl_utlb_entry  <= {4{1'b0}};
      ovl_prev_transl_pa          <= {28{1'b0}};
      ovl_prev_transl_va          <= {52{1'b0}};
      ovl_prev_transl_attrs       <= {13{1'b0}};
      ovl_prev_transl_ns          <= 1'b0;
      ovl_prev_transl_lpae        <= 1'b0;
      ovl_prev_cache_off          <= 1'b0;
      ovl_prev_aa64               <= 1'b0;
    end else if (enable_dc2) begin
      ovl_prev_transl_utlb_entry  <= dpu_utlb_hit_entry_dc1_i;
      ovl_prev_transl_va          <= dpu_va_dc1_i[63:12];
      ovl_prev_transl_pa          <= dpu_pa_dc1_i;
      ovl_prev_transl_attrs       <= dpu_attributes_dc1_i;
      ovl_prev_transl_ns          <= dpu_ns_dsc_dc1_i;
      ovl_prev_transl_lpae        <= dpu_lpae_dc1_i;
      ovl_prev_cache_off          <= cache_off_dc1;
      ovl_prev_aa64               <= dpu_aarch64_state_i;
    end

  reg utlb_miss_dc1;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      utlb_miss_dc1 <= 1'b0;
    else
      utlb_miss_dc1 <= utlb_miss_dc1 ? ~v_enable_dc1
                                     : (dcu_va_valid_dc1 & (~dpu_flush_i | (~dpu_kill_wr_i | ~dpu_ready_wr_i)) & ~dpu_utlb_hit_dc1_i);

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two translations from DPU which hit in same uTLB entry should produce same translation result")
  u_ovl_dpu_transl_valid (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (ovl_prev_transl_valid & dcu_va_valid_dc1 & ~flush_dc1 & ~abort_dc1 & ~cp_inst_dc1 & dpu_utlb_hit_dc1_i & ~utlb_miss_dc1 &
                                            (ovl_prev_transl_utlb_entry == dpu_utlb_hit_entry_dc1_i)),
                          .consequent_expr ((dpu_pa_dc1_i         == ovl_prev_transl_pa)        &
                                            // VA[63:56] only needs to be consistent in AA64 when TBI set,
                                            // VA[55:32] only needs to be consistent in AA64
                                            ( (dpu_aarch64_state_i ? (ttbr_tbi ? (dpu_va_dc1_i[55:12] == ovl_prev_transl_va[55:12])
                                                                               : (dpu_va_dc1_i[63:12] == ovl_prev_transl_va[63:12]))
                                                                   :             (dpu_va_dc1_i[31:12] == ovl_prev_transl_va[31:12])) ) &
                                            (dpu_attributes_dc1_i == ovl_prev_transl_attrs)     &
                                            (dpu_ns_dsc_dc1_i     == ovl_prev_transl_ns)        &
                                            (dpu_lpae_dc1_i       == ovl_prev_transl_lpae)      &
                                            (cache_off_dc1        == ovl_prev_cache_off)        &
                                            (dpu_aarch64_state_i  == ovl_prev_aa64)));

  // The following are from DPU interface, but there they need to factor in
  // dpu_flush. It is possible to get a dpu_flush which doesn't actually
  // flush anything from the pipe, so a wrong value on that cycle can still
  // make it to DC3 and get retired to the DPU.
  // The asserts therefore need to use flush_dc1, but this is not available
  // on the interface.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "DPU S1 LPAE level invalid")
  u_ovl_dpu_s1_lpae_lvl  (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (dpu_utlb_hit_dc1_i & dcu_va_valid_dc1 & ~flush_dc1 & dpu_lpae_dc1_i & s1_transl_valid_dc1),
                          .consequent_expr ((dpu_level_dc1_i[1:0] == `CA53_LPAE_TRANSL_LEVEL_1) |
                                            (dpu_level_dc1_i[1:0] == `CA53_LPAE_TRANSL_LEVEL_2) |
                                            (dpu_level_dc1_i[1:0] == `CA53_LPAE_TRANSL_LEVEL_3)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "DPU S1 VMSA level invalid")
  u_ovl_dpu_s1_vmsa_lvl  (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (dpu_utlb_hit_dc1_i & dcu_va_valid_dc1 & ~flush_dc1 & ~dpu_lpae_dc1_i & s1_transl_valid_dc1),
                          .consequent_expr ((dpu_level_dc1_i[1:0] == `CA53_VMSA_PAGE_SIZE_SSECTION) |
                                            (dpu_level_dc1_i[1:0] == `CA53_VMSA_PAGE_SIZE_SECTION) |
                                            (dpu_level_dc1_i[1:0] == `CA53_VMSA_PAGE_SIZE_PAGE)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "DPU S2 level implies no S2 translation, but got restricted S2 permissions")
  u_ovl_dpu_s2_lvl_perms (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (dpu_utlb_hit_dc1_i & dcu_va_valid_dc1 & ~flush_dc1 & ~dpu_abort_dc1_i &
                                            (dpu_level_dc1_i[3:2] == 2'b00) & (dpu_attributes_dc1_i[2:0] != 3'b100)),
                          .consequent_expr (dpu_attributes_dc1_i[4:3] == 2'b11));

`endif

endmodule // ca53dcu_lspipe

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dcu_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53_gov_dcu_defs.v"
`include "ca53_dpu_dcu_defs.v"
`undef CA53_UNDEFINE
/*END*/
