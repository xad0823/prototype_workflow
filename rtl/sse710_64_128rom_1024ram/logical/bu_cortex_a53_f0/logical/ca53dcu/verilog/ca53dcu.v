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
// Abstract : DCU Top Level.
//
// The Data Cache Unit includes the data cache RAM controller, the load store
// pipeline, some CP15 logic and the snoop interface with the SCU
//
//-----------------------------------------------------------------------------

`include "cortexa53params.v"
`include "ca53dcu_defs.v"

module ca53dcu `CA53_DCU_PARAM_DECL
  (
   input   wire                             clk,
   input   wire                             reset_n,
   input   wire                             DFTSE,
   input   wire                             DFTRAMHOLD,


   //--------------------------------------------------------------------------
   // BIU Interface
   //--------------------------------------------------------------------------

   input   wire                             biu_read_data_valid_dc2_i,
   input   wire                     [63:0]  biu_read_data_dc2_i,
   input   wire                             biu_read_abort_dc2_i,
   input   wire                      [1:0]  biu_read_fault_dc2_i,
   input   wire                             biu_suppress_load_hit_dc2_i,
   input   wire                             biu_read_data_valid_dc3_i,
   input   wire                     [63:0]  biu_read_data_dc3_i,
   input   wire                             biu_lf_ready_dc2_i,
   input   wire                             biu_lf_next_ready_dc3_i,
   input   wire                      [7:0]  biu_lf_in_progress_i,
   input   wire                      [3:0]  biu_pf_in_progress_i,
   input   wire                             biu_ecc_cinv_ack_i,
   input   wire                             biu_ecc_cinv_complete_i,
   input   wire                             biu_alloc_tag_req_m0_i,
   input   wire                    [255:0]  biu_alloc_data_m0_i,
   input   wire                             biu_alloc_data_req_m0_i,
   input   wire                             biu_alloc_halfline_m0_i,
   input   wire                             biu_alloc_dirty_req_m0_i,
   input   wire                      [1:0]  biu_alloc_tag_moesi_m0_i,
   input   wire                      [1:0]  biu_alloc_dirty_moesi_m1_i,
   input   wire                             biu_alloc_dirty_age_m1_i,
   input   wire                      [7:0]  biu_alloc_attrs_m1_i,
   input   wire                     [39:4]  biu_alloc_addr_m0_i,
   input   wire                             biu_alloc_ns_dsc_m0_i,
   input   wire                      [3:0]  biu_alloc_way_m0_i,
   input   wire                             biu_ccb_lf_hazard_i,
   input   wire                             biu_pld_l2_next_ready_i,
   input   wire                             biu_pf_tag_req_m0_i,
   input   wire                     [39:6]  biu_pf_tag_addr_m0_i,
   input   wire                             biu_pf_tag_ns_dsc_m0_i,
   input   wire                             biu_strex_bresp_valid_i,
   input   wire                      [1:0]  biu_strex_bresp_i,
   input   wire                             biu_read_abort_dc3_i,
   input   wire                      [1:0]  biu_read_fault_dc3_i,
   input   wire                             biu_dirty_lf_in_progress_i,
   input   wire                             biu_suppress_tlb_hit_i,

   output  wire                             dcu_lf_req_dc1_o,
   output  wire                      [1:0]  dcu_lf_way_dc1_o,
   output  wire                             dcu_lf_active_o,
   output  wire                             dcu_leaving_dc1_o,
   output  wire                             dcu_load_dc1_o,
   output  wire                             dcu_load_dc2_o,
   output  wire                      [8:0]  dcu_mbist_array_mb3_o,
   output  wire                     [39:0]  dcu_pa_dc2_o,
   output  wire                             dcu_ns_dsc_dc2_o,
   output  wire                      [7:0]  dcu_attrs_dc1_o,
   output  wire                      [7:0]  dcu_attrs_dc2_o,
   output  wire                      [1:0]  dcu_size_dc2_o,
   output  wire                      [3:0]  dcu_length_dc2_o,
   output  wire                             dcu_pld_l2_req_dc2_o,
   output  wire                             dcu_exclusive_dc2_o,
   output  wire                             dcu_leaving_dc2_o,
   output  wire                             dcu_lf_req_dc2_o,
   output  wire                      [1:0]  dcu_lf_way_dc2_o,
   output  wire                             dcu_biu_active_o,
   output  wire                             dcu_biu_req_dc2_o,
   output  wire                             dcu_load_dc3_o,
   output  wire                             dcu_lf_req_dc3_o,
   output  wire                      [1:0]  dcu_lf_way_dc3_o,
   output  wire                             dcu_neon_access_dc3_o,
   output  wire                             dcu_biu_req_dc3_o,
   output  wire                     [39:0]  dcu_pa_dc3_o,
   output  wire                             dcu_pipe_valid_dc3_o,
   output  wire                             dcu_ns_dsc_dc3_o,
   output  wire                             dcu_priv_dc3_o,
   output  wire                      [7:0]  dcu_attrs_dc3_o,
   output  wire                      [1:0]  dcu_size_dc3_o,
   output  wire                      [3:0]  dcu_length_dc3_o,
   output  wire                             dcu_exclusive_dc3_o,
   output  wire                             dcu_pldw_dc3_o,
   output  wire                             dcu_pld_l2_req_dc3_o,
   output  wire                             dcu_stop_pf_o,
   output  wire                             dcu_ecc_cinv_req_o,
   output  wire                      [7:0]  dcu_ecc_cinv_index_o,
   output  wire                      [1:0]  dcu_ecc_cinv_way_o,
   output  wire                     [55:0]  dcu_ecc_syndrome_m3_o,
   output  wire                             dcu_ecc_fatal_m3_o,
   output  wire                             dcu_ecc_tag_err_m3_o,
   output  wire                      [6:0]  dcu_mbist_data_checkbits_mb6_o,
   output  wire                     [63:0]  dcu_mbist_out_data_mb6_o,
   output  wire                             dcu_snoop_dw_active_o,
   output  wire                             dcu_snoop_valid_m2_o,
   output  wire                    [255:0]  dcu_snoop_data_m2_o,
   output  wire                      [1:0]  dcu_snoop_chunk_m2_o,
   output  wire                      [1:0]  dcu_snoop_rotate_m2_o,
   output  wire                      [3:0]  dcu_snoop_l2db_id_m2_o,
   output  wire                             dcu_snoop_last_m2_o,
   output  wire                             dcu_alloc_has_priority_m0_o,
   output  wire                             dcu_alloc_ack_m1_o,
   output  wire                             dcu_pf_tag_has_priority_m0_o,
   output  wire                             dcu_pf_tag_ack_m1_o,
   output  wire                             dcu_pf_tag_hit_m2_o,
   output  wire                      [3:0]  dcu_ccb_ways_o,
   output  wire                     [13:6]  dcu_ccb_index_o,
   output  wire                             dcu_ccb_req_active_o,
   output  wire                             dcu_ccb_req_valid_o,
   output  wire                             dcu_drain_stb_lf_o,


   //--------------------------------------------------------------------------
   // IFU Interface
   //--------------------------------------------------------------------------

   input   wire                      [2:0]  ifu_outstanding_lfb_i,
   input   wire                             ifu_cp_ack_i,
   input   wire                             ifu_valid_if2_i,

   output  wire                             dcu_cp_valid_ifu_o,
   output  wire                             dcu_dvm_valid_ifu_o,
   output  wire                     [39:0]  dcu_cp_addr_ifu_o,
   output  wire                      [2:0]  dcu_cp_op_ifu_o,

   // The following dcu_cp_* signal are shared with the TLB interface
   output  wire                             dcu_cp_ns_o,


   //--------------------------------------------------------------------------
   // RAMS Interface
   //--------------------------------------------------------------------------

   input   wire                      [2:0]  dc_size_i,
   input   wire   [(`CA53_DTAG_RAM_W-1):0]  dc_tagram_rdata0_i,
   input   wire   [(`CA53_DTAG_RAM_W-1):0]  dc_tagram_rdata1_i,
   input   wire   [(`CA53_DTAG_RAM_W-1):0]  dc_tagram_rdata2_i,
   input   wire   [(`CA53_DTAG_RAM_W-1):0]  dc_tagram_rdata3_i,
   input   wire  [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_rdata0_i,
   input   wire  [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_rdata1_i,
   input   wire  [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_rdata2_i,
   input   wire  [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_rdata3_i,
   input   wire  [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_rdata4_i,
   input   wire  [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_rdata5_i,
   input   wire  [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_rdata6_i,
   input   wire  [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_rdata7_i,
   input   wire [(`CA53_DDIRTY_RAM_W-1):0]  dc_dirtyram_rdata_i,

   output  wire                      [3:0]  dc_tagram_en_o,
   output  wire                             dc_tagram_wr_o,
   output  wire   [(`CA53_DTAG_RAM_W-1):0]  dc_tagram_wdata_o,
   output  wire                      [7:0]  dc_tagram_addr_o,
   output  wire                      [7:0]  dc_dataram_en_o,
   output  wire                             dc_dataram_wr_o,
   output  wire  [(`CA53_DDATA_WEN_W-1):0]  dc_dataram_strb0_o,
   output  wire  [(`CA53_DDATA_WEN_W-1):0]  dc_dataram_strb1_o,
   output  wire  [(`CA53_DDATA_WEN_W-1):0]  dc_dataram_strb2_o,
   output  wire  [(`CA53_DDATA_WEN_W-1):0]  dc_dataram_strb3_o,
   output  wire  [(`CA53_DDATA_WEN_W-1):0]  dc_dataram_strb4_o,
   output  wire  [(`CA53_DDATA_WEN_W-1):0]  dc_dataram_strb5_o,
   output  wire  [(`CA53_DDATA_WEN_W-1):0]  dc_dataram_strb6_o,
   output  wire  [(`CA53_DDATA_WEN_W-1):0]  dc_dataram_strb7_o,
   output  wire                     [10:0]  dc_dataram_addr0_o,
   output  wire                     [10:0]  dc_dataram_addr1_o,
   output  wire                     [10:0]  dc_dataram_addr2_o,
   output  wire                     [10:0]  dc_dataram_addr3_o,
   output  wire                     [10:0]  dc_dataram_addr4_o,
   output  wire                     [10:0]  dc_dataram_addr5_o,
   output  wire                     [10:0]  dc_dataram_addr6_o,
   output  wire                     [10:0]  dc_dataram_addr7_o,
   output  wire  [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_wdata0_o,
   output  wire  [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_wdata1_o,
   output  wire  [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_wdata2_o,
   output  wire  [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_wdata3_o,
   output  wire  [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_wdata4_o,
   output  wire  [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_wdata5_o,
   output  wire  [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_wdata6_o,
   output  wire  [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_wdata7_o,
   output  wire                             dc_dirtyram_en_o,
   output  wire                             dc_dirtyram_wr_o,
   output  wire [(`CA53_DDIRTY_RAM_W-1):0]  dc_dirtyram_strb_o,
   output  wire                      [8:0]  dc_dirtyram_addr_o,
   output  wire [(`CA53_DDIRTY_RAM_W-1):0]  dc_dirtyram_wdata_o,


   //--------------------------------------------------------------------------
   // STB Interface
   //--------------------------------------------------------------------------

   input   wire                      [4:0]  stb_slots_valid_i,
   input   wire                      [4:0]  stb_slots_emptying_i,
   input   wire                      [4:0]  stb_slots_dev_ng_i,
   input   wire                      [4:0]  stb_slots_dsb_i,
   input   wire                             stb_cacheable_strex_done_i,
   input   wire                             stb_strex_failed_i,
   input   wire                      [4:0]  stb_can_merge_dc2_i,
   input   wire                      [4:0]  stb_sameline_dc2_i,
   input   wire                      [4:0]  stb_load_sameline_dc2_i,
   input   wire                             stb_attr_mismatch_dc2_i,
   input   wire                      [7:0]  stb_hit_dc2_i,
   input   wire                     [63:0]  stb_data_dc2_i,
   input   wire                             stb_cache_tag_req_m0_i,
   input   wire                             stb_cache_tag_wr_m0_i,
   input   wire                      [3:0]  stb_cache_tag_way_m0_i,
   input   wire                     [39:6]  stb_cache_tag_addr_m0_i,
   input   wire                             stb_cache_tag_ns_dsc_m0_i,
   input   wire                             stb_cache_data_req_m0_i,
   input   wire                             stb_cache_data_wr_m0_i,
   input   wire                     [13:4]  stb_cache_data_addr_m0_i,
   input   wire                      [3:0]  stb_cache_data_way_m0_i,
   input   wire                     [15:0]  stb_cache_data_bls_m0_i,
   input   wire                      [7:0]  stb_cache_data_attrs_m0_i,
   input   wire                             stb_cache_data_migratory_m0_i,
   input   wire                    [127:0]  stb_cache_write_data_m0_i,
   input   wire                             stb_defer_ccb_i,
   input   wire                             stb_block_ccb_i,
   input   wire                             stb_block_loads_dc1_i,
   input   wire                             stb_force_non_mergeable_i,

   output  wire                             dcu_dvm_sync_needed_dc3_o,
   output  wire                             dcu_drain_entire_stb_o,
   output  wire                      [4:0]  dcu_drain_slots_o,
   output  wire                             dcu_ecc_data_err_m3_o,
   output  wire                             dcu_ecc_in_progress_o,
   output  wire                             dcu_ecc_tag_err_m2_o,
   output  wire                             dcu_exclusive_monitor_o,
   output  wire                      [4:0]  dcu_load_sameline_dc3_o,
   output  wire                             dcu_valid_dc2_o,
   output  wire                             dcu_stb_req_dc3_o,
   output  wire                             dcu_stlr_dc3_o,
   output  wire                             dcu_store_dc1_o,
   output  wire                             dcu_store_dc2_o,
   output  wire                             dcu_store_dc3_o,
   output  wire                      [4:0]  dcu_store_merge_dc3_o,
   output  wire                      [4:0]  dcu_store_sameline_dc3_o,
   output  wire                             dcu_store_cp15_dc3_o,
   output  wire                             dcu_store_dmb_dc3_o,
   output  wire                             dcu_store_dsb_dc3_o,
   output  wire                      [7:0]  dcu_stb_attrs_dc3_o,
   output  wire                     [15:0]  dcu_store_bls_dc3_o,
   output  wire                             dcu_store_last_dc3_o,
   output  wire                             dcu_stb_tag_has_priority_m0_o,
   output  wire                             dcu_stb_tag_ack_m1_o,
   output  wire                      [3:0]  dcu_stb_tag_hit_m2_o,
   output  wire                             dcu_stb_tag_migratory_m2_o,
   output  wire                             dcu_stb_tag_shared_m2_o,
   output  wire                      [3:0]  dcu_stb_victim_way_m2_o,
   output  wire                             dcu_stb_data_has_priority_m0_o,
   output  wire                             dcu_stb_data_ack_m1_o,
   output  wire                    [127:0]  dcu_stb_read_data_m2_o,
   output  wire                             dcu_force_non_mergeable_dc3_o,
   output  wire                             dcu_stb_exclusive_dc3_o,


   //--------------------------------------------------------------------------
   // TLB Interface
   //--------------------------------------------------------------------------

   input   wire                     [15:0]  tlb_wpt_hit_dc1_i,
   input   wire                     [39:3]  tlb_cache_walk_addr_i,
   input   wire                      [1:0]  tlb_cache_walk_lookup_req_m0_i,
   input   wire                             tlb_cache_walk_ns_dsc_i,
   input   wire                     [63:0]  tlb_cp_read_data_dc2_i,
   input   wire                             tlb_cp_ack_i,
   input   wire                             tlb_cp_reg_write_ready_i,
   input   wire                      [7:0]  tlb_vmid_i,
   input   wire                             tlb_d_utlb_enable_i,
   input   wire                      [1:0]  tlb_d_tcr_el1_tbi_i,
   input   wire                             tlb_d_tcr_el2_tbi0_i,
   input   wire                             tlb_d_tcr_el3_tbi0_i,
   input   wire                             tlb_pagewalk_invalidated_i,

   output  wire                             dcu_cp_valid_tlb_o,
   output  wire                      [4:0]  dcu_cp_op_tlb_o,
   output  wire                      [2:0]  dcu_transl_type_dc1_o,
   output  wire                             dcu_cache_walk_has_priority_m0_o,
   output  wire                             dcu_va_valid_dc1_o,
   output  wire                             dcu_va_valid_early_dc1_o,
   output  wire                             dcu_ongoing_burst_dc1_o,
   output  wire                             dcu_cache_walk_ack_m1_o,
   output  wire                     [63:0]  dcu_cache_walk_data_m2_o,
   output  wire                             dcu_ecc_err_m3_o,
   output  wire                             dcu_cache_walk_hit_m2_o,
   output  wire                      [3:0]  dcu_cache_walk_victim_way_m2_o,
   output  wire                     [61:0]  dcu_cp_addr_tlb_o,
   output  wire                      [5:0]  dcu_cp_reg_en_dc2_o,
   output  wire                             dcu_cp_reg_write_dc3_o,
   output  wire                             dcu_cp_reg_write_active_o,
   output  wire                      [5:0]  dcu_cp_reg_en_dc3_o,
   output  wire                     [63:0]  dcu_cp_reg_data_o,
   output  wire                             dcu_cp_reg_size_o,
   output  wire                             dcu_priv_dc1_o,
   output  wire                             dcu_block_lookups_o,
   output  wire                             dcu_wpt_check_512_dc1_o,


   //--------------------------------------------------------------------------
   // DPU Interface
   //--------------------------------------------------------------------------

   input   wire                      [3:1]  dpu_aarch64_at_el_i,
   input   wire                             dpu_abort_dc1_i,
   input   wire                      [2:0]  dpu_align_size_iss_i,
   input   wire                             dpu_burst_iss_i,
   input   wire                             dpu_cross_64_iss_i,
   input   wire                      [8:0]  dpu_cp_op_iss_i,
   input   wire                             dpu_dbg_dsb_req_i,
   input   wire                             dpu_clear_excl_mon_i,
   input   wire                             dpu_mmu_on_el1_i,
   input   wire                             dpu_mmu_on_el2_i,
   input   wire                             dpu_mmu_on_el3_i,
   input   wire                             dpu_dcache_on_el1_i,
   input   wire                             dpu_dcache_on_el2_i,
   input   wire                             dpu_dcache_on_el3_i,
   input   wire                             dpu_default_cacheable_i,
   input   wire                             dpu_l1deien_i,
   input   wire                             dpu_disable_dmb_i,
   input   wire                             dpu_disable_no_allocate_i,
   input   wire                      [3:0]  dpu_domain_dc1_i,
   input   wire                      [1:0]  dpu_exception_level_i,
   input   wire                             dpu_aarch64_state_i,
   input   wire                             dpu_excl_iss_i,
   input   wire                             dpu_first_iss_i,
   input   wire                             dpu_force_first_iss_i,
   input   wire                             dpu_icache_on_i,
   input   wire                      [3:0]  dpu_level_dc1_i,
   input   wire                     [21:0]  dpu_periphbase_i,
   input   wire                             dpu_pld_iss_i,
   input   wire                             dpu_pld_level_iss_i,
   input   wire                             dpu_priv_iss_i,
   input   wire                             dpu_store_iss_i,
   input   wire                     [15:0]  dpu_strobe_iss_i,
   input   wire                             dpu_second_x64_iss_i,
   input   wire                             dpu_neon_access_iss_i,
   input   wire                             dpu_s2_dcache_on_i,
   input   wire                             dpu_valid_iss_i,
   input   wire                             dpu_valid_cp_iss_i,
   input   wire                      [4:0]  dpu_length_iss_i,
   input   wire                      [1:0]  dpu_size_iss_i,
   input   wire                             dpu_req_align_iss_i,
   input   wire                             dpu_non_temporal_iss_i,
   input   wire                             dpu_ldar_stlr_iss_i,
   input   wire                     [63:0]  dpu_va_dc1_i,
   input   wire                             dpu_utlb_hit_dc1_i,
   input   wire                      [3:0]  dpu_utlb_hit_entry_dc1_i,
   input   wire                    [39:12]  dpu_pa_dc1_i,
   input   wire                     [12:0]  dpu_attributes_dc1_i,
   input   wire                      [8:0]  dpu_fault_dc1_i,
   input   wire                             dpu_ns_dsc_dc1_i,
   input   wire                             dpu_ready_wr_i,
   input   wire                     [63:0]  dpu_cp_data_wr_i,
   input   wire                    [127:0]  dpu_st_data_wr_i,
   input   wire                             dpu_kill_wr_i,
   input   wire                             dpu_flush_i,
   input   wire                     [48:6]  dpu_agu_a_operand_iss_i,
   input   wire                     [48:6]  dpu_agu_b_operand_iss_i,
   input   wire                             dpu_agu_carry_out_64b_iss_i,
   input   wire                             dpu_cc_fail_wr_i,
   input   wire                             dpu_ready_cc_fail_wr_i,
   input   wire                             dpu_ready_cc_pass_wr_i,
   input   wire                             dpu_ns_state_i,
   input   wire                             dpu_scr_el3_ns_i,
   input   wire                             dpu_stack_align_expt_dc1_i,
   input   wire                             dpu_lpae_dc1_i,
   input   wire                             dpu_ipa_to_pa_en_i,

   output  wire                             dcu_ecc_err_dc3_o,
   output  wire                             dcu_ecc_fatal_o,
   output  wire                             dcu_ecc_valid_o,
   output  wire                       [1:0] dcu_ecc_ramid_o,
   output  wire                       [2:0] dcu_ecc_way_bank_id_o,
   output  wire                      [10:0] dcu_ecc_index_o,
   output  wire                             dcu_evnt_dc_access_o,
   output  wire                             dcu_excl_mon_cleared_o,
   output  wire                             dcu_ready_cp_iss_o,
   output  wire                             dcu_ready_iss_o,
   output  wire                             dcu_valid_dc3_o,
   output  wire                     [63:0]  dcu_ld_data_dc3_o,
   output  wire                             dcu_strex_okay_dc3_o,
   output  wire                             dcu_wpt_hit_dc3_o,
   output  wire                             dcu_p_abort_dc3_o,
   output  wire                      [6:0]  dcu_p_fault_dc3_o,
   output  wire                      [1:0]  dcu_p_fault_stage_dc3_o,
   output  wire                      [3:0]  dcu_p_domain_dc3_o,
   output  wire                             dcu_p_direction_dc3_o,
   output  wire                             dcu_v2p_lpae_dc3_o,
   output  wire                             dcu_cm_operation_dc3_o,
   output  wire                     [63:0]  dcu_va_dc3_o,
   output  wire                             dcu_dbg_dsb_ack_o,


   //--------------------------------------------------------------------------
   // Governor Interface
   //--------------------------------------------------------------------------

   input   wire                             gov_giccdisable_i,
   input   wire                             gov_stall_dsb_i,
   input   wire                             gov_cp_ack_i,
   input   wire                     [63:0]  gov_cp_rdata_i,
   input   wire                             gov_mbist_req_i,
   input   wire                             gov_wfx_drain_req_i,
   input   wire                             gov_standbywfe_i,
   input   wire                             gov_standbywfi_i,
   input   wire                             gov_dbgl1rstdisable_i,

   output  wire                     [17:0]  dcu_cp_gov_addr_o,
   output  wire                             dcu_cp_gov_ns_o,
   output  wire                             dcu_cp_gov_req_o,
   output  wire                      [2:0]  dcu_cp_gov_sel_o,
   output  wire                     [63:0]  dcu_cp_gov_wdata_o,
   output  wire                             dcu_cp_gov_wenable_o,
   output  wire                             dcu_wfx_ready_o,


   //--------------------------------------------------------------------------
   // SCU Interface
   //--------------------------------------------------------------------------

   input   wire                     [40:0]  scu_ac_addr_i,
   input   wire                      [2:0]  scu_ac_id_i,
   input   wire                      [3:0]  scu_ac_l2db_id_i,
   input   wire                      [3:0]  scu_ac_snoop_i,
   input   wire                             scu_ac_valid_i,
   input   wire                      [3:0]  scu_ac_way_i,
   input   wire                             scu_broadcastinner_i,
   input   wire                      [7:0]  scu_reqbufs_busy_i,

   output  wire                             dcu_ac_ready_o,
   output  wire                             dcu_cr_alloc_o,
   output  wire                             dcu_cr_dirty_o,
   output  wire                      [2:0]  dcu_cr_id_o,
   output  wire                             dcu_cr_migratory_o,
   output  wire                             dcu_cr_age_o,
   output  wire                             dcu_cr_valid_o,
   output  wire                             dcu_dvm_complete_o

  );


  //---------------------------------------------------------------------------
  // Signal declarations
  //---------------------------------------------------------------------------

  /*ARMAUTO*/
  // The following wires were automatically generated
  // to interconnect instantiations where appropriate.
  wire                              alloc_invalidating_tag_m1;
  wire                              block_dvm_dc3;
  wire                              ccb_block_prearb_tag_m1;
  wire                       [13:5] ccb_data_addr_m1;
  wire                              ccb_data_req_m1;
  wire                              ccb_valid_data_req_m1;
  wire                       [13:6] ccb_dirty_addr_m1;
  wire                              ccb_dirty_m2;
  wire                              ccb_dirty_req_m1;
  wire                        [3:0] ccb_dirty_way_m1;
  wire                        [3:0] ccb_dirty_wdata_m1;
  wire                        [3:0] ccb_hit_dirty_m2;
  wire                              ccb_ecc_make_inv;
  wire                              ccb_invalidating_tag_m1;
  wire                       [13:6] ccb_lookup_addr;
  wire                              ccb_inv_snoop_m2;
  wire                        [3:0] ccb_lookup_way;
  wire                        [1:0] ccb_tag_moesi_m1;
  wire                              ccb_tag_req_m1;
  wire                              ccb_throttle_loads;
  wire                       [40:6] ccb_write_addr_m1;
  wire                        [3:0] ccb_write_way_m1;
  wire                              cp15_data_has_priority_m0;
  wire                              cp15_data_req_m0;
  wire                              cp15_inv_all_force_miss;
  wire                              cp15_inv_all_req;
  wire                       [13:3] cp15_addr_m0;
  wire                              cp15_tag_has_priority_m0;
  wire                              cp15_tag_req_m0;
  wire                        [3:0] cp15_way_m0;
  wire                              cp15_wr_m0;
  wire                              data_debug_op_ack;
  wire                              dc_ccb_data_has_priorty_m1;
  wire                              dc_cp15_ack;
  wire                              dc_cp15_ack_m1;
  wire                       [13:3] dc_cp15_addr_dc3;
  wire                              dc_cp15_op_data_dc3;
  wire                              dc_cp15_start_dc3;
  wire                        [1:0] dc_cp15_way_dc3;
  wire                       [63:0] dc_debug_tag_data_m2;
  wire                              dc_ecc_err_m3;
  wire                              dc_ecc_tag_err_m2;
  wire                              dc_force_first;
  wire                              dc_force_non_seq;
  wire                              dc_inv_all_in_progress;
  wire                       [39:3] dc_load_addr_m1;
  wire                        [7:0] dc_load_bls_m1;
  wire                       [63:0] dc_load_data_m2;
  wire                              dc_load_first_m1;
  wire                              dc_load_has_priority_m1;
  wire                              dc_load_hit_m2;
  wire                              dc_load_index_match_m1;
  wire                              dc_load_raw_hit_m2;
  wire                              dc_load_req_m1;
  wire                              dc_load_tag_ns_dsc_m1;
  wire                              dc_load_tag_req_only_m1;
  wire                        [1:0] dc_load_victim_way_m2;
  wire                              dc_throttle_loads;
  wire                              dc_throttle_snoops;
  wire                              dc_valid_load_req_m1;
  wire                              dcu_dvm_valid_tlb;
  wire                              dcu_ecc_cinv_req;
  wire                              dcu_ecc_in_progress;
  wire                              dsb_dc1;
  wire                              dsb_dc2;
  wire                              dsb_dc3;
  wire                       [61:0] dvm_cp_addr;
  wire                        [2:0] dvm_ifu_cp_op;
  wire                              dvm_in_progress;
  wire                              dvm_ns;
  wire                        [4:0] dvm_tlb_cp_op;
  wire                              force_reset;
  wire                              inv_all_tlb_ifu;
  wire                              load_lookup_m2;
  wire                       [10:0] mbist_addr_mb3;
  wire                        [8:0] mbist_array_mb3;
  wire   [(`CA53_DDIRTY_RAM_W-1):0] mbist_be_mb3;
  wire                              mbist_cfg_mb3;
  wire                       [34:0] mbist_ctl_data_mb3;
  wire                              mbist_read_en_mb3;
  wire                              mbist_sel_mb3;
  wire                              mbist_write_en_mb3;
  wire                              next_valid_dc2;
  wire                              next_valid_dc3;
  wire                              tag_debug_op_ack;
  wire                              v_enable_dc1;
  wire                              v_enable_dc2;
  wire                              v_enable_dc3;
  wire                              valid_dc1;
  wire                              valid_dc2;
  wire                              valid_dc3;
  /*END*/
  wire                              ccb_wfx_ready;
  wire                              ls_wfx_ready;
  wire                              next_dcu_wfx_ready;
  reg                               dcu_wfx_ready;
  wire                              dcu_ongoing_burst_dc1;
  wire                              dvm_stop_pf;
  wire                              ls_stop_pf;
  reg                               mbist_en;
  reg                               giccdisable;
  reg                               dbgl1rstdisable_rs;
  reg                               gov_stall_dsb_rs;
  wire                              dcu_ready_iss;
  wire                              ls_biu_active;


  //---------------------------------------------------------------------------
  // Main Code
  //---------------------------------------------------------------------------

  // External MBIST enable used by several blocks and needs registering.
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      mbist_en <= 1'b0;
    else
      mbist_en <= gov_mbist_req_i;

  // Register slice signals from governor to decouple timing
  always @(posedge clk) begin
    dbgl1rstdisable_rs <= gov_dbgl1rstdisable_i;
    gov_stall_dsb_rs   <= gov_stall_dsb_i;
  end

  // - External GICCDISABLE signal only changes on reset
  always @(posedge clk)
    if (force_reset)
      giccdisable <= gov_giccdisable_i;

  // Aliases for top level outputs that are also inputs to another DCU block
  assign dcu_ecc_cinv_req_o       = dcu_ecc_cinv_req;
  assign dcu_ecc_in_progress_o    = dcu_ecc_in_progress;
  assign dcu_ongoing_burst_dc1_o  = dcu_ongoing_burst_dc1;
  assign dcu_ready_iss_o          = dcu_ready_iss;
  assign dcu_mbist_array_mb3_o    = mbist_array_mb3;

  // The DCU asserts wfx_ready if the load-store pipeline and CCB block are
  // idle, and invalidate all on reset and the ECC correction state machine are not ongoing.
  assign next_dcu_wfx_ready = ls_wfx_ready & ccb_wfx_ready & ~dc_inv_all_in_progress & ~dcu_ecc_in_progress;

  always @(posedge clk)
    dcu_wfx_ready <= next_dcu_wfx_ready;

  assign dcu_wfx_ready_o = dcu_wfx_ready;

  // Assert stop_pf to BIU whenever DVM or lspipe require it.
  assign dcu_stop_pf_o = dvm_stop_pf | ls_stop_pf;

  // Indicate active to BIU when lspipe indicates it or making ECC correction
  // request
  assign dcu_biu_active_o = ls_biu_active | dcu_ecc_cinv_req;


  //---------------------------------------------------------------------------
  // Load store pipeline
  //---------------------------------------------------------------------------

  ca53dcu_lspipe `CA53_DCU_PARAM_INST u_lspipe (
    /*ARMAUTO*/
    // Inputs
    .clk                           (clk),
    .reset_n                       (reset_n),
    .DFTSE                         (DFTSE),
    .mbist_en_i                    (mbist_en),
    .dpu_aarch64_at_el_i           (dpu_aarch64_at_el_i[3:1]),
    .dpu_valid_iss_i               (dpu_valid_iss_i),
    .dpu_valid_cp_iss_i            (dpu_valid_cp_iss_i),
    .dpu_store_iss_i               (dpu_store_iss_i),
    .dpu_strobe_iss_i              (dpu_strobe_iss_i[15:0]),
    .dpu_exception_level_i         (dpu_exception_level_i[1:0]),
    .dpu_aarch64_state_i           (dpu_aarch64_state_i),
    .dpu_excl_iss_i                (dpu_excl_iss_i),
    .dpu_periphbase_i              (dpu_periphbase_i[21:0]),
    .dpu_pld_iss_i                 (dpu_pld_iss_i),
    .dpu_pld_level_iss_i           (dpu_pld_level_iss_i),
    .dpu_priv_iss_i                (dpu_priv_iss_i),
    .dpu_first_iss_i               (dpu_first_iss_i),
    .dpu_length_iss_i              (dpu_length_iss_i[4:0]),
    .dpu_size_iss_i                (dpu_size_iss_i[1:0]),
    .dpu_req_align_iss_i           (dpu_req_align_iss_i),
    .dpu_align_size_iss_i          (dpu_align_size_iss_i[2:0]),
    .dpu_non_temporal_iss_i        (dpu_non_temporal_iss_i),
    .dpu_ldar_stlr_iss_i           (dpu_ldar_stlr_iss_i),
    .dpu_burst_iss_i               (dpu_burst_iss_i),
    .dpu_cross_64_iss_i            (dpu_cross_64_iss_i),
    .dpu_icache_on_i               (dpu_icache_on_i),
    .dpu_second_x64_iss_i          (dpu_second_x64_iss_i),
    .dpu_neon_access_iss_i         (dpu_neon_access_iss_i),
    .dpu_cp_op_iss_i               (dpu_cp_op_iss_i[8:0]),
    .dpu_va_dc1_i                  (dpu_va_dc1_i[63:0]),
    .dpu_utlb_hit_dc1_i            (dpu_utlb_hit_dc1_i),
    .dpu_utlb_hit_entry_dc1_i      (dpu_utlb_hit_entry_dc1_i[3:0]),
    .dpu_pa_dc1_i                  (dpu_pa_dc1_i[39:12]),
    .dpu_attributes_dc1_i          (dpu_attributes_dc1_i[12:0]),
    .dpu_fault_dc1_i               (dpu_fault_dc1_i[8:0]),
    .dpu_ns_dsc_dc1_i              (dpu_ns_dsc_dc1_i),
    .dpu_ready_wr_i                (dpu_ready_wr_i),
    .dpu_cp_data_wr_i              (dpu_cp_data_wr_i[63:0]),
    .dpu_st_data_wr_i              (dpu_st_data_wr_i[127:0]),
    .dpu_kill_wr_i                 (dpu_kill_wr_i),
    .dpu_flush_i                   (dpu_flush_i),
    .dpu_cc_fail_wr_i              (dpu_cc_fail_wr_i),
    .dpu_ready_cc_fail_wr_i        (dpu_ready_cc_fail_wr_i),
    .dpu_ready_cc_pass_wr_i        (dpu_ready_cc_pass_wr_i),
    .dpu_ns_state_i                (dpu_ns_state_i),
    .dpu_scr_el3_ns_i              (dpu_scr_el3_ns_i),
    .dpu_dbg_dsb_req_i             (dpu_dbg_dsb_req_i),
    .dpu_clear_excl_mon_i          (dpu_clear_excl_mon_i),
    .dpu_mmu_on_el1_i              (dpu_mmu_on_el1_i),
    .dpu_mmu_on_el2_i              (dpu_mmu_on_el2_i),
    .dpu_mmu_on_el3_i              (dpu_mmu_on_el3_i),
    .dpu_dcache_on_el1_i           (dpu_dcache_on_el1_i),
    .dpu_dcache_on_el2_i           (dpu_dcache_on_el2_i),
    .dpu_dcache_on_el3_i           (dpu_dcache_on_el3_i),
    .dpu_s2_dcache_on_i            (dpu_s2_dcache_on_i),
    .dpu_disable_dmb_i             (dpu_disable_dmb_i),
    .dpu_disable_no_allocate_i     (dpu_disable_no_allocate_i),
    .dpu_level_dc1_i               (dpu_level_dc1_i[3:0]),
    .dpu_stack_align_expt_dc1_i    (dpu_stack_align_expt_dc1_i),
    .dpu_abort_dc1_i               (dpu_abort_dc1_i),
    .dpu_domain_dc1_i              (dpu_domain_dc1_i[3:0]),
    .dpu_lpae_dc1_i                (dpu_lpae_dc1_i),
    .dpu_ipa_to_pa_en_i            (dpu_ipa_to_pa_en_i),
    .dpu_default_cacheable_i       (dpu_default_cacheable_i),
    .giccdisable_i                 (giccdisable),
    .gov_stall_dsb_rs_i            (gov_stall_dsb_rs),
    .gov_cp_ack_i                  (gov_cp_ack_i),
    .gov_cp_rdata_i                (gov_cp_rdata_i[63:0]),
    .tlb_wpt_hit_dc1_i             (tlb_wpt_hit_dc1_i[15:0]),
    .tlb_cp_read_data_dc2_i        (tlb_cp_read_data_dc2_i[63:0]),
    .tlb_cp_ack_i                  (tlb_cp_ack_i),
    .tlb_cp_reg_write_ready_i      (tlb_cp_reg_write_ready_i),
    .tlb_vmid_i                    (tlb_vmid_i[7:0]),
    .tlb_d_utlb_enable_i           (tlb_d_utlb_enable_i),
    .tlb_d_tcr_el1_tbi_i           (tlb_d_tcr_el1_tbi_i[1:0]),
    .tlb_d_tcr_el2_tbi0_i          (tlb_d_tcr_el2_tbi0_i),
    .tlb_d_tcr_el3_tbi0_i          (tlb_d_tcr_el3_tbi0_i),
    .biu_pld_l2_next_ready_i       (biu_pld_l2_next_ready_i),
    .biu_read_data_valid_dc2_i     (biu_read_data_valid_dc2_i),
    .biu_read_data_dc2_i           (biu_read_data_dc2_i[63:0]),
    .biu_read_data_valid_dc3_i     (biu_read_data_valid_dc3_i),
    .biu_read_data_dc3_i           (biu_read_data_dc3_i[63:0]),
    .biu_lf_ready_dc2_i            (biu_lf_ready_dc2_i),
    .biu_lf_next_ready_dc3_i       (biu_lf_next_ready_dc3_i),
    .biu_strex_bresp_valid_i       (biu_strex_bresp_valid_i),
    .biu_strex_bresp_i             (biu_strex_bresp_i[1:0]),
    .biu_read_abort_dc3_i          (biu_read_abort_dc3_i),
    .biu_read_fault_dc3_i          (biu_read_fault_dc3_i[1:0]),
    .biu_dirty_lf_in_progress_i    (biu_dirty_lf_in_progress_i),
    .biu_read_abort_dc2_i          (biu_read_abort_dc2_i),
    .biu_read_fault_dc2_i          (biu_read_fault_dc2_i[1:0]),
    .ifu_cp_ack_i                  (ifu_cp_ack_i),
    .scu_broadcastinner_i          (scu_broadcastinner_i),
    .stb_slots_valid_i             (stb_slots_valid_i[4:0]),
    .stb_slots_emptying_i          (stb_slots_emptying_i[4:0]),
    .stb_slots_dev_ng_i            (stb_slots_dev_ng_i[4:0]),
    .stb_cacheable_strex_done_i    (stb_cacheable_strex_done_i),
    .stb_strex_failed_i            (stb_strex_failed_i),
    .stb_can_merge_dc2_i           (stb_can_merge_dc2_i[4:0]),
    .stb_sameline_dc2_i            (stb_sameline_dc2_i[4:0]),
    .stb_load_sameline_dc2_i       (stb_load_sameline_dc2_i[4:0]),
    .stb_attr_mismatch_dc2_i       (stb_attr_mismatch_dc2_i),
    .stb_hit_dc2_i                 (stb_hit_dc2_i[7:0]),
    .stb_data_dc2_i                (stb_data_dc2_i[63:0]),
    .stb_block_loads_dc1_i         (stb_block_loads_dc1_i),
    .stb_force_non_mergeable_i     (stb_force_non_mergeable_i),
    .dc_ecc_tag_err_m2_i           (dc_ecc_tag_err_m2),
    .dc_ecc_err_m3_i               (dc_ecc_err_m3),
    .dc_load_has_priority_m1_i     (dc_load_has_priority_m1),
    .dc_load_hit_m2_i              (dc_load_hit_m2),
    .dc_load_raw_hit_m2_i          (dc_load_raw_hit_m2),
    .dc_load_data_m2_i             (dc_load_data_m2[63:0]),
    .dc_debug_tag_data_m2_i        (dc_debug_tag_data_m2[63:0]),
    .dc_load_victim_way_m2_i       (dc_load_victim_way_m2[1:0]),
    .dcu_ecc_in_progress_i         (dcu_ecc_in_progress),
    .load_lookup_m2_i              (load_lookup_m2),
    .alloc_invalidating_tag_m1_i   (alloc_invalidating_tag_m1),
    .dc_throttle_loads_i           (dc_throttle_loads),
    .dc_load_index_match_m1_i      (dc_load_index_match_m1),
    .dc_inv_all_in_progress_i      (dc_inv_all_in_progress),
    .cp15_inv_all_force_miss_i     (cp15_inv_all_force_miss),
    .dc_cp15_ack_i                 (dc_cp15_ack),
    .tag_debug_op_ack_i            (tag_debug_op_ack),
    .data_debug_op_ack_i           (data_debug_op_ack),
    .force_reset_i                 (force_reset),
    .ccb_write_addr_m1_i           (ccb_write_addr_m1[40:6]),
    .ccb_invalidating_tag_m1_i     (ccb_invalidating_tag_m1),
    .ccb_throttle_loads_i          (ccb_throttle_loads),
    .mbist_ctl_data_mb3_i          (mbist_ctl_data_mb3[34:0]),
    .dcu_dvm_valid_tlb_i           (dcu_dvm_valid_tlb),
    .dvm_ns_i                      (dvm_ns),
    .dvm_cp_addr_i                 (dvm_cp_addr[61:0]),
    .dvm_tlb_cp_op_i               (dvm_tlb_cp_op[4:0]),
    .dvm_ifu_cp_op_i               (dvm_ifu_cp_op[2:0]),
    .dvm_in_progress_i             (dvm_in_progress),
    // Outputs
    .ls_wfx_ready_o                (ls_wfx_ready),
    .dcu_ecc_err_dc3_o             (dcu_ecc_err_dc3_o),
    .dcu_excl_mon_cleared_o        (dcu_excl_mon_cleared_o),
    .dcu_ready_cp_iss_o            (dcu_ready_cp_iss_o),
    .dcu_ready_iss_o               (dcu_ready_iss),
    .dcu_valid_dc3_o               (dcu_valid_dc3_o),
    .dcu_ld_data_dc3_o             (dcu_ld_data_dc3_o[63:0]),
    .dcu_strex_okay_dc3_o          (dcu_strex_okay_dc3_o),
    .dcu_wpt_hit_dc3_o             (dcu_wpt_hit_dc3_o),
    .dcu_p_abort_dc3_o             (dcu_p_abort_dc3_o),
    .dcu_p_fault_dc3_o             (dcu_p_fault_dc3_o[6:0]),
    .dcu_p_fault_stage_dc3_o       (dcu_p_fault_stage_dc3_o[1:0]),
    .dcu_p_domain_dc3_o            (dcu_p_domain_dc3_o[3:0]),
    .dcu_p_direction_dc3_o         (dcu_p_direction_dc3_o),
    .dcu_v2p_lpae_dc3_o            (dcu_v2p_lpae_dc3_o),
    .dcu_cm_operation_dc3_o        (dcu_cm_operation_dc3_o),
    .dcu_va_dc3_o                  (dcu_va_dc3_o[63:0]),
    .dcu_dbg_dsb_ack_o             (dcu_dbg_dsb_ack_o),
    .dcu_evnt_dc_access_o          (dcu_evnt_dc_access_o),
    .dcu_cp_gov_addr_o             (dcu_cp_gov_addr_o[17:0]),
    .dcu_cp_gov_ns_o               (dcu_cp_gov_ns_o),
    .dcu_cp_gov_req_o              (dcu_cp_gov_req_o),
    .dcu_cp_gov_sel_o              (dcu_cp_gov_sel_o[2:0]),
    .dcu_cp_gov_wdata_o            (dcu_cp_gov_wdata_o[63:0]),
    .dcu_cp_gov_wenable_o          (dcu_cp_gov_wenable_o),
    .dcu_ongoing_burst_dc1_o       (dcu_ongoing_burst_dc1),
    .dcu_cp_addr_tlb_o             (dcu_cp_addr_tlb_o[61:0]),
    .dcu_cp_reg_en_dc2_o           (dcu_cp_reg_en_dc2_o[5:0]),
    .dcu_cp_reg_write_dc3_o        (dcu_cp_reg_write_dc3_o),
    .dcu_cp_reg_write_active_o     (dcu_cp_reg_write_active_o),
    .dcu_cp_reg_en_dc3_o           (dcu_cp_reg_en_dc3_o[5:0]),
    .dcu_cp_reg_data_o             (dcu_cp_reg_data_o[63:0]),
    .dcu_cp_reg_size_o             (dcu_cp_reg_size_o),
    .dcu_cp_valid_tlb_o            (dcu_cp_valid_tlb_o),
    .dcu_cp_op_tlb_o               (dcu_cp_op_tlb_o[4:0]),
    .dcu_priv_dc1_o                (dcu_priv_dc1_o),
    .dcu_block_lookups_o           (dcu_block_lookups_o),
    .dcu_wpt_check_512_dc1_o       (dcu_wpt_check_512_dc1_o),
    .dcu_transl_type_dc1_o         (dcu_transl_type_dc1_o[2:0]),
    .dcu_va_valid_dc1_o            (dcu_va_valid_dc1_o),
    .dcu_va_valid_early_dc1_o      (dcu_va_valid_early_dc1_o),
    .dcu_lf_req_dc1_o              (dcu_lf_req_dc1_o),
    .dcu_lf_way_dc1_o              (dcu_lf_way_dc1_o[1:0]),
    .dcu_attrs_dc1_o               (dcu_attrs_dc1_o[7:0]),
    .dcu_attrs_dc2_o               (dcu_attrs_dc2_o[7:0]),
    .ls_biu_active_o               (ls_biu_active),
    .dcu_exclusive_dc2_o           (dcu_exclusive_dc2_o),
    .dcu_leaving_dc1_o             (dcu_leaving_dc1_o),
    .dcu_leaving_dc2_o             (dcu_leaving_dc2_o),
    .dcu_length_dc2_o              (dcu_length_dc2_o[3:0]),
    .dcu_lf_req_dc2_o              (dcu_lf_req_dc2_o),
    .dcu_lf_way_dc2_o              (dcu_lf_way_dc2_o[1:0]),
    .dcu_lf_active_o               (dcu_lf_active_o),
    .dcu_load_dc1_o                (dcu_load_dc1_o),
    .dcu_load_dc2_o                (dcu_load_dc2_o),
    .dcu_mbist_out_data_mb6_o      (dcu_mbist_out_data_mb6_o[63:0]),
    .dcu_ns_dsc_dc2_o              (dcu_ns_dsc_dc2_o),
    .dcu_pa_dc2_o                  (dcu_pa_dc2_o[39:0]),
    .dcu_pld_l2_req_dc2_o          (dcu_pld_l2_req_dc2_o),
    .dcu_size_dc2_o                (dcu_size_dc2_o[1:0]),
    .dcu_biu_req_dc2_o             (dcu_biu_req_dc2_o),
    .dcu_load_dc3_o                (dcu_load_dc3_o),
    .dcu_lf_req_dc3_o              (dcu_lf_req_dc3_o),
    .dcu_lf_way_dc3_o              (dcu_lf_way_dc3_o[1:0]),
    .dcu_biu_req_dc3_o             (dcu_biu_req_dc3_o),
    .dcu_pa_dc3_o                  (dcu_pa_dc3_o[39:0]),
    .dcu_ns_dsc_dc3_o              (dcu_ns_dsc_dc3_o),
    .dcu_priv_dc3_o                (dcu_priv_dc3_o),
    .dcu_attrs_dc3_o               (dcu_attrs_dc3_o[7:0]),
    .dcu_size_dc3_o                (dcu_size_dc3_o[1:0]),
    .dcu_length_dc3_o              (dcu_length_dc3_o[3:0]),
    .dcu_neon_access_dc3_o         (dcu_neon_access_dc3_o),
    .dcu_pipe_valid_dc3_o          (dcu_pipe_valid_dc3_o),
    .dcu_store_last_dc3_o          (dcu_store_last_dc3_o),
    .dcu_exclusive_dc3_o           (dcu_exclusive_dc3_o),
    .dcu_pldw_dc3_o                (dcu_pldw_dc3_o),
    .dcu_pld_l2_req_dc3_o          (dcu_pld_l2_req_dc3_o),
    .ls_stop_pf_o                  (ls_stop_pf),
    .dcu_cp_addr_ifu_o             (dcu_cp_addr_ifu_o[39:0]),
    .dcu_cp_valid_ifu_o            (dcu_cp_valid_ifu_o),
    .dcu_cp_op_ifu_o               (dcu_cp_op_ifu_o[2:0]),
    .dcu_cp_ns_o                   (dcu_cp_ns_o),
    .dcu_drain_entire_stb_o        (dcu_drain_entire_stb_o),
    .dcu_exclusive_monitor_o       (dcu_exclusive_monitor_o),
    .dcu_store_dc1_o               (dcu_store_dc1_o),
    .dcu_valid_dc2_o               (dcu_valid_dc2_o),
    .dcu_store_dc2_o               (dcu_store_dc2_o),
    .dcu_store_dc3_o               (dcu_store_dc3_o),
    .dcu_stb_req_dc3_o             (dcu_stb_req_dc3_o),
    .dcu_stlr_dc3_o                (dcu_stlr_dc3_o),
    .dcu_store_merge_dc3_o         (dcu_store_merge_dc3_o[4:0]),
    .dcu_store_sameline_dc3_o      (dcu_store_sameline_dc3_o[4:0]),
    .dcu_load_sameline_dc3_o       (dcu_load_sameline_dc3_o[4:0]),
    .dcu_store_cp15_dc3_o          (dcu_store_cp15_dc3_o),
    .dcu_store_dmb_dc3_o           (dcu_store_dmb_dc3_o),
    .dcu_store_dsb_dc3_o           (dcu_store_dsb_dc3_o),
    .dcu_dvm_sync_needed_dc3_o     (dcu_dvm_sync_needed_dc3_o),
    .dcu_store_bls_dc3_o           (dcu_store_bls_dc3_o[15:0]),
    .dcu_force_non_mergeable_dc3_o (dcu_force_non_mergeable_dc3_o),
    .dcu_stb_attrs_dc3_o           (dcu_stb_attrs_dc3_o[7:0]),
    .dcu_stb_exclusive_dc3_o       (dcu_stb_exclusive_dc3_o),
    .dc_load_req_m1_o              (dc_load_req_m1),
    .dc_valid_load_req_m1_o        (dc_valid_load_req_m1),
    .dc_load_tag_req_only_m1_o     (dc_load_tag_req_only_m1),
    .dc_load_first_m1_o            (dc_load_first_m1),
    .dc_force_non_seq_o            (dc_force_non_seq),
    .dc_force_first_o              (dc_force_first),
    .dc_load_addr_m1_o             (dc_load_addr_m1[39:3]),
    .dc_load_tag_ns_dsc_m1_o       (dc_load_tag_ns_dsc_m1),
    .dc_load_bls_m1_o              (dc_load_bls_m1[7:0]),
    .dc_cp15_start_dc3_o           (dc_cp15_start_dc3),
    .dc_cp15_op_data_dc3_o         (dc_cp15_op_data_dc3),
    .dc_cp15_addr_dc3_o            (dc_cp15_addr_dc3[13:3]),
    .dc_cp15_way_dc3_o             (dc_cp15_way_dc3[1:0]),
    .valid_dc1_o                   (valid_dc1),
    .valid_dc2_o                   (valid_dc2),
    .valid_dc3_o                   (valid_dc3),
    .next_valid_dc2_o              (next_valid_dc2),
    .next_valid_dc3_o              (next_valid_dc3),
    .dsb_dc1_o                     (dsb_dc1),
    .dsb_dc2_o                     (dsb_dc2),
    .dsb_dc3_o                     (dsb_dc3),
    .block_dvm_dc3_o               (block_dvm_dc3),
    .v_enable_dc1_o                (v_enable_dc1),
    .v_enable_dc2_o                (v_enable_dc2),
    .v_enable_dc3_o                (v_enable_dc3)
  );  // u_lspipe


  //---------------------------------------------------------------------------
  // Cache arbiter and cache RAM interface
  //---------------------------------------------------------------------------

  ca53dcu_cachearb `CA53_DCU_PARAM_INST u_cachearb (
    /*ARMAUTO*/
    // Inputs
    .clk                              (clk),
    .reset_n                          (reset_n),
    .DFTRAMHOLD                       (DFTRAMHOLD),
    .dpu_l1deien_i                    (dpu_l1deien_i),
    .dpu_exception_level_1_i          (dpu_exception_level_i[1]),
    .dpu_force_first_iss_i            (dpu_force_first_iss_i),
    .dc_load_req_m1_i                 (dc_load_req_m1),
    .dc_load_tag_req_only_m1_i        (dc_load_tag_req_only_m1),
    .dc_valid_load_req_m1_i           (dc_valid_load_req_m1),
    .dc_load_first_m1_i               (dc_load_first_m1),
    .dc_force_non_seq_i               (dc_force_non_seq),
    .dc_force_first_i                 (dc_force_first),
    .dc_load_addr_m1_i                (dc_load_addr_m1[39:3]),
    .dc_load_tag_ns_dsc_m1_i          (dc_load_tag_ns_dsc_m1),
    .dc_load_bls_m1_i                 (dc_load_bls_m1[7:0]),
    .dcu_ready_iss_i                  (dcu_ready_iss),
    .cp15_tag_req_m0_i                (cp15_tag_req_m0),
    .cp15_data_req_m0_i               (cp15_data_req_m0),
    .dc_inv_all_in_progress_i         (dc_inv_all_in_progress),
    .cp15_way_m0_i                    (cp15_way_m0[3:0]),
    .cp15_addr_m0_i                   (cp15_addr_m0[13:3]),
    .cp15_wr_m0_i                     (cp15_wr_m0),
    .ccb_tag_req_m1_i                 (ccb_tag_req_m1),
    .ccb_block_prearb_tag_m1_i        (ccb_block_prearb_tag_m1),
    .ccb_dirty_req_m1_i               (ccb_dirty_req_m1),
    .ccb_dirty_wdata_m1_i             (ccb_dirty_wdata_m1[3:0]),
    .ccb_dirty_addr_m1_i              (ccb_dirty_addr_m1[13:6]),
    .ccb_dirty_way_m1_i               (ccb_dirty_way_m1[3:0]),
    .ccb_write_addr_m1_i              (ccb_write_addr_m1[40:6]),
    .ccb_write_way_m1_i               (ccb_write_way_m1[3:0]),
    .ccb_tag_moesi_m1_i               (ccb_tag_moesi_m1[1:0]),
    .ccb_data_req_m1_i                (ccb_data_req_m1),
    .ccb_valid_data_req_m1_i          (ccb_valid_data_req_m1),
    .ccb_ecc_make_inv_i               (ccb_ecc_make_inv),
    .ccb_lookup_way_i                 (ccb_lookup_way[3:0]),
    .ccb_lookup_addr_i                (ccb_lookup_addr[13:6]),
    .ccb_inv_snoop_m2_i               (ccb_inv_snoop_m2),
    .ccb_data_addr_m1_i               (ccb_data_addr_m1[13:5]),
    .ccb_dirty_m2_i                   (ccb_dirty_m2),
    .dpu_va_dc1_i                     (dpu_va_dc1_i[48:6]),
    .dpu_valid_iss_i                  (dpu_valid_iss_i),
    .dpu_flush_i                      (dpu_flush_i),
    .dpu_aarch64_state_i              (dpu_aarch64_state_i),
    .dpu_agu_a_operand_iss_i          (dpu_agu_a_operand_iss_i[48:6]),
    .dpu_agu_b_operand_iss_i          (dpu_agu_b_operand_iss_i[48:6]),
    .dpu_agu_carry_out_64b_iss_i      (dpu_agu_carry_out_64b_iss_i),
    .biu_alloc_tag_req_m0_i           (biu_alloc_tag_req_m0_i),
    .biu_alloc_data_req_m0_i          (biu_alloc_data_req_m0_i),
    .biu_alloc_halfline_m0_i          (biu_alloc_halfline_m0_i),
    .biu_alloc_dirty_req_m0_i         (biu_alloc_dirty_req_m0_i),
    .biu_alloc_tag_moesi_m0_i         (biu_alloc_tag_moesi_m0_i[1:0]),
    .biu_alloc_data_m0_i              (biu_alloc_data_m0_i[255:0]),
    .biu_alloc_dirty_moesi_m1_i       (biu_alloc_dirty_moesi_m1_i[1:0]),
    .biu_alloc_dirty_age_m1_i         (biu_alloc_dirty_age_m1_i),
    .biu_alloc_attrs_m1_i             (biu_alloc_attrs_m1_i[7:0]),
    .biu_ecc_cinv_ack_i               (biu_ecc_cinv_ack_i),
    .biu_ecc_cinv_complete_i          (biu_ecc_cinv_complete_i),
    .biu_pf_tag_req_m0_i              (biu_pf_tag_req_m0_i),
    .biu_alloc_addr_m0_i              (biu_alloc_addr_m0_i[39:4]),
    .biu_pf_tag_addr_m0_i             (biu_pf_tag_addr_m0_i[39:6]),
    .biu_alloc_ns_dsc_m0_i            (biu_alloc_ns_dsc_m0_i),
    .biu_pf_tag_ns_dsc_m0_i           (biu_pf_tag_ns_dsc_m0_i),
    .biu_alloc_way_m0_i               (biu_alloc_way_m0_i[3:0]),
    .biu_suppress_load_hit_dc2_i      (biu_suppress_load_hit_dc2_i),
    .biu_suppress_tlb_hit_i           (biu_suppress_tlb_hit_i),
    .stb_cache_tag_req_m0_i           (stb_cache_tag_req_m0_i),
    .stb_cache_tag_wr_m0_i            (stb_cache_tag_wr_m0_i),
    .stb_cache_tag_way_m0_i           (stb_cache_tag_way_m0_i[3:0]),
    .stb_cache_tag_addr_m0_i          (stb_cache_tag_addr_m0_i[39:6]),
    .stb_cache_tag_ns_dsc_m0_i        (stb_cache_tag_ns_dsc_m0_i),
    .stb_cache_data_req_m0_i          (stb_cache_data_req_m0_i),
    .stb_cache_data_addr_m0_i         (stb_cache_data_addr_m0_i[13:4]),
    .stb_cache_data_way_m0_i          (stb_cache_data_way_m0_i[3:0]),
    .stb_cache_data_wr_m0_i           (stb_cache_data_wr_m0_i),
    .stb_cache_data_bls_m0_i          (stb_cache_data_bls_m0_i[15:0]),
    .stb_cache_data_attrs_m0_i        (stb_cache_data_attrs_m0_i[7:0]),
    .stb_cache_data_migratory_m0_i    (stb_cache_data_migratory_m0_i),
    .stb_cache_write_data_m0_i        (stb_cache_write_data_m0_i[127:0]),
    .tlb_cache_walk_addr_i            (tlb_cache_walk_addr_i[39:3]),
    .tlb_cache_walk_lookup_req_m0_i   (tlb_cache_walk_lookup_req_m0_i[1:0]),
    .tlb_cache_walk_ns_dsc_i          (tlb_cache_walk_ns_dsc_i),
    .dc_size_i                        (dc_size_i[2:0]),
    .dc_tagram_rdata0_i               (dc_tagram_rdata0_i[(`CA53_DTAG_RAM_W-1):0]),
    .dc_tagram_rdata1_i               (dc_tagram_rdata1_i[(`CA53_DTAG_RAM_W-1):0]),
    .dc_tagram_rdata2_i               (dc_tagram_rdata2_i[(`CA53_DTAG_RAM_W-1):0]),
    .dc_tagram_rdata3_i               (dc_tagram_rdata3_i[(`CA53_DTAG_RAM_W-1):0]),
    .dc_dataram_rdata0_i              (dc_dataram_rdata0_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata1_i              (dc_dataram_rdata1_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata2_i              (dc_dataram_rdata2_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata3_i              (dc_dataram_rdata3_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata4_i              (dc_dataram_rdata4_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata5_i              (dc_dataram_rdata5_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata6_i              (dc_dataram_rdata6_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata7_i              (dc_dataram_rdata7_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dirtyram_rdata_i              (dc_dirtyram_rdata_i[(`CA53_DDIRTY_RAM_W-1):0]),
    .mbist_en_i                       (mbist_en),
    .mbist_sel_mb3_i                  (mbist_sel_mb3),
    .mbist_cfg_mb3_i                  (mbist_cfg_mb3),
    .mbist_read_en_mb3_i              (mbist_read_en_mb3),
    .mbist_write_en_mb3_i             (mbist_write_en_mb3),
    .mbist_be_mb3_i                   (mbist_be_mb3[(`CA53_DDIRTY_RAM_W-1):0]),
    .mbist_array_mb3_i                (mbist_array_mb3[6:0]),
    .mbist_addr_mb3_i                 (mbist_addr_mb3[10:0]),
    // Outputs
    .dc_ecc_tag_err_m2_o              (dc_ecc_tag_err_m2),
    .dc_ecc_err_m3_o                  (dc_ecc_err_m3),
    .dc_load_has_priority_m1_o        (dc_load_has_priority_m1),
    .dc_load_index_match_m1_o         (dc_load_index_match_m1),
    .dc_load_hit_m2_o                 (dc_load_hit_m2),
    .dc_load_raw_hit_m2_o             (dc_load_raw_hit_m2),
    .dc_load_data_m2_o                (dc_load_data_m2[63:0]),
    .dc_debug_tag_data_m2_o           (dc_debug_tag_data_m2[63:0]),
    .dc_load_victim_way_m2_o          (dc_load_victim_way_m2[1:0]),
    .alloc_invalidating_tag_m1_o      (alloc_invalidating_tag_m1),
    .load_lookup_m2_o                 (load_lookup_m2),
    .dc_throttle_loads_o              (dc_throttle_loads),
    .dc_cp15_ack_m1_o                 (dc_cp15_ack_m1),
    .cp15_data_has_priority_m0_o      (cp15_data_has_priority_m0),
    .cp15_tag_has_priority_m0_o       (cp15_tag_has_priority_m0),
    .ccb_hit_dirty_m2_o               (ccb_hit_dirty_m2[3:0]),
    .dc_ccb_data_has_priorty_m1_o     (dc_ccb_data_has_priorty_m1),
    .dc_throttle_snoops_o             (dc_throttle_snoops),
    .dcu_alloc_has_priority_m0_o      (dcu_alloc_has_priority_m0_o),
    .dcu_alloc_ack_m1_o               (dcu_alloc_ack_m1_o),
    .dcu_ecc_valid_o                  (dcu_ecc_valid_o),
    .dcu_ecc_fatal_o                  (dcu_ecc_fatal_o),
    .dcu_ecc_ramid_o                  (dcu_ecc_ramid_o[1:0]),
    .dcu_ecc_way_bank_id_o            (dcu_ecc_way_bank_id_o[2:0]),
    .dcu_ecc_index_o                  (dcu_ecc_index_o[10:0]),
    .dcu_ecc_cinv_index_o             (dcu_ecc_cinv_index_o[7:0]),
    .dcu_ecc_cinv_req_o               (dcu_ecc_cinv_req),
    .dcu_ecc_cinv_way_o               (dcu_ecc_cinv_way_o[1:0]),
    .dcu_ecc_fatal_m3_o               (dcu_ecc_fatal_m3_o),
    .dcu_ecc_syndrome_m3_o            (dcu_ecc_syndrome_m3_o[55:0]),
    .dcu_ecc_tag_err_m3_o             (dcu_ecc_tag_err_m3_o),
    .dcu_pf_tag_has_priority_m0_o     (dcu_pf_tag_has_priority_m0_o),
    .dcu_pf_tag_ack_m1_o              (dcu_pf_tag_ack_m1_o),
    .dcu_pf_tag_hit_m2_o              (dcu_pf_tag_hit_m2_o),
    .dcu_snoop_data_m2_o              (dcu_snoop_data_m2_o[255:0]),
    .dcu_mbist_data_checkbits_mb6_o   (dcu_mbist_data_checkbits_mb6_o[6:0]),
    .dcu_ecc_data_err_m3_o            (dcu_ecc_data_err_m3_o),
    .dcu_ecc_in_progress_o            (dcu_ecc_in_progress),
    .dcu_ecc_tag_err_m2_o             (dcu_ecc_tag_err_m2_o),
    .dcu_stb_tag_has_priority_m0_o    (dcu_stb_tag_has_priority_m0_o),
    .dcu_stb_tag_ack_m1_o             (dcu_stb_tag_ack_m1_o),
    .dcu_stb_tag_hit_m2_o             (dcu_stb_tag_hit_m2_o[3:0]),
    .dcu_stb_tag_migratory_m2_o       (dcu_stb_tag_migratory_m2_o),
    .dcu_stb_victim_way_m2_o          (dcu_stb_victim_way_m2_o[3:0]),
    .dcu_stb_tag_shared_m2_o          (dcu_stb_tag_shared_m2_o),
    .dcu_stb_data_has_priority_m0_o   (dcu_stb_data_has_priority_m0_o),
    .dcu_stb_data_ack_m1_o            (dcu_stb_data_ack_m1_o),
    .dcu_stb_read_data_m2_o           (dcu_stb_read_data_m2_o[127:0]),
    .dcu_cache_walk_has_priority_m0_o (dcu_cache_walk_has_priority_m0_o),
    .dcu_cache_walk_ack_m1_o          (dcu_cache_walk_ack_m1_o),
    .dcu_cache_walk_data_m2_o         (dcu_cache_walk_data_m2_o[63:0]),
    .dcu_cache_walk_hit_m2_o          (dcu_cache_walk_hit_m2_o),
    .dcu_cache_walk_victim_way_m2_o   (dcu_cache_walk_victim_way_m2_o[3:0]),
    .dcu_ecc_err_m3_o                 (dcu_ecc_err_m3_o),
    .dc_tagram_en_o                   (dc_tagram_en_o[3:0]),
    .dc_tagram_wr_o                   (dc_tagram_wr_o),
    .dc_tagram_wdata_o                (dc_tagram_wdata_o[(`CA53_DTAG_RAM_W-1):0]),
    .dc_tagram_addr_o                 (dc_tagram_addr_o[7:0]),
    .dc_dataram_en_o                  (dc_dataram_en_o[7:0]),
    .dc_dataram_wr_o                  (dc_dataram_wr_o),
    .dc_dataram_strb0_o               (dc_dataram_strb0_o[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb1_o               (dc_dataram_strb1_o[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb2_o               (dc_dataram_strb2_o[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb3_o               (dc_dataram_strb3_o[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb4_o               (dc_dataram_strb4_o[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb5_o               (dc_dataram_strb5_o[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb6_o               (dc_dataram_strb6_o[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb7_o               (dc_dataram_strb7_o[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_addr0_o               (dc_dataram_addr0_o[10:0]),
    .dc_dataram_addr1_o               (dc_dataram_addr1_o[10:0]),
    .dc_dataram_addr2_o               (dc_dataram_addr2_o[10:0]),
    .dc_dataram_addr3_o               (dc_dataram_addr3_o[10:0]),
    .dc_dataram_addr4_o               (dc_dataram_addr4_o[10:0]),
    .dc_dataram_addr5_o               (dc_dataram_addr5_o[10:0]),
    .dc_dataram_addr6_o               (dc_dataram_addr6_o[10:0]),
    .dc_dataram_addr7_o               (dc_dataram_addr7_o[10:0]),
    .dc_dataram_wdata0_o              (dc_dataram_wdata0_o[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata1_o              (dc_dataram_wdata1_o[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata2_o              (dc_dataram_wdata2_o[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata3_o              (dc_dataram_wdata3_o[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata4_o              (dc_dataram_wdata4_o[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata5_o              (dc_dataram_wdata5_o[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata6_o              (dc_dataram_wdata6_o[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata7_o              (dc_dataram_wdata7_o[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dirtyram_en_o                 (dc_dirtyram_en_o),
    .dc_dirtyram_wr_o                 (dc_dirtyram_wr_o),
    .dc_dirtyram_strb_o               (dc_dirtyram_strb_o[(`CA53_DDIRTY_RAM_W-1):0]),
    .dc_dirtyram_addr_o               (dc_dirtyram_addr_o[8:0]),
    .dc_dirtyram_wdata_o              (dc_dirtyram_wdata_o[(`CA53_DDIRTY_RAM_W-1):0])
  );  // u_cachearb


  //---------------------------------------------------------------------------
  // CP15 maintenance ops control block
  //---------------------------------------------------------------------------

  ca53dcu_cp15 u_cp15 (
    /*ARMAUTO*/
    // Inputs
    .clk                         (clk),
    .reset_n                     (reset_n),
    .dc_cp15_start_dc3_i         (dc_cp15_start_dc3),
    .dc_cp15_op_data_dc3_i       (dc_cp15_op_data_dc3),
    .dc_cp15_addr_dc3_i          (dc_cp15_addr_dc3[13:3]),
    .dc_cp15_way_dc3_i           (dc_cp15_way_dc3[ 1:0]),
    .dc_cp15_ack_m1_i            (dc_cp15_ack_m1),
    .cp15_data_has_priority_m0_i (cp15_data_has_priority_m0),
    .cp15_tag_has_priority_m0_i  (cp15_tag_has_priority_m0),
    .dbgl1rstdisable_rs_i        (dbgl1rstdisable_rs),
    .mbist_en_i                  (mbist_en),
    .dc_size_i                   (dc_size_i[2:0]),
    // Outputs
    .cp15_inv_all_force_miss_o   (cp15_inv_all_force_miss),
    .dc_inv_all_in_progress_o    (dc_inv_all_in_progress),
    .dc_cp15_ack_o               (dc_cp15_ack),
    .tag_debug_op_ack_o          (tag_debug_op_ack),
    .data_debug_op_ack_o         (data_debug_op_ack),
    .force_reset_o               (force_reset),
    .cp15_tag_req_m0_o           (cp15_tag_req_m0),
    .cp15_data_req_m0_o          (cp15_data_req_m0),
    .cp15_wr_m0_o                (cp15_wr_m0),
    .cp15_way_m0_o               (cp15_way_m0[3:0]),
    .cp15_addr_m0_o              (cp15_addr_m0[13:3]),
    .cp15_inv_all_req_o          (cp15_inv_all_req),
    .inv_all_tlb_ifu_o           (inv_all_tlb_ifu)
  );  // u_cp15


  //---------------------------------------------------------------------------
  // CCB Control
  //---------------------------------------------------------------------------

  ca53dcu_ccbctl `CA53_DCU_PARAM_INST u_ccbctl (
    /*ARMAUTO*/
    // Inputs
    .clk                          (clk),
    .reset_n                      (reset_n),
    .DFTSE                        (DFTSE),
    .scu_ac_addr_i                (scu_ac_addr_i[40:0]),
    .scu_ac_id_i                  (scu_ac_id_i[2:0]),
    .scu_ac_l2db_id_i             (scu_ac_l2db_id_i[3:0]),
    .scu_reqbufs_busy_i           (scu_reqbufs_busy_i[7:0]),
    .scu_ac_snoop_i               (scu_ac_snoop_i[3:0]),
    .scu_ac_valid_i               (scu_ac_valid_i),
    .scu_ac_way_i                 (scu_ac_way_i[3:0]),
    .gov_wfx_drain_req_i          (gov_wfx_drain_req_i),
    .gov_standbywfe_i             (gov_standbywfe_i),
    .gov_standbywfi_i             (gov_standbywfi_i),
    .biu_ccb_lf_hazard_i          (biu_ccb_lf_hazard_i),
    .biu_lf_in_progress_i         (biu_lf_in_progress_i[7:0]),
    .biu_pf_in_progress_i         (biu_pf_in_progress_i[3:0]),
    .ccb_hit_dirty_m2_i           (ccb_hit_dirty_m2[3:0]),
    .dc_ccb_data_has_priorty_m1_i (dc_ccb_data_has_priorty_m1),
    .dc_throttle_snoops_i         (dc_throttle_snoops),
    .cp15_inv_all_req_i           (cp15_inv_all_req),
    .inv_all_tlb_ifu_i            (inv_all_tlb_ifu),
    .force_reset_i                (force_reset),
    .stb_defer_ccb_i              (stb_defer_ccb_i),
    .stb_block_ccb_i              (stb_block_ccb_i),
    .stb_slots_valid_i            (stb_slots_valid_i[4:0]),
    .stb_slots_dsb_i              (stb_slots_dsb_i[4:0]),
    .block_dvm_dc3_i              (block_dvm_dc3),
    .dcu_ongoing_burst_dc1_i      (dcu_ongoing_burst_dc1),
    .dsb_dc1_i                    (dsb_dc1),
    .dsb_dc2_i                    (dsb_dc2),
    .dsb_dc3_i                    (dsb_dc3),
    .next_valid_dc2_i             (next_valid_dc2),
    .next_valid_dc3_i             (next_valid_dc3),
    .v_enable_dc1_i               (v_enable_dc1),
    .v_enable_dc2_i               (v_enable_dc2),
    .v_enable_dc3_i               (v_enable_dc3),
    .valid_dc1_i                  (valid_dc1),
    .valid_dc2_i                  (valid_dc2),
    .valid_dc3_i                  (valid_dc3),
    .ifu_cp_ack_i                 (ifu_cp_ack_i),
    .ifu_valid_if2_i              (ifu_valid_if2_i),
    .ifu_outstanding_lfb_i        (ifu_outstanding_lfb_i[2:0]),
    .tlb_cp_ack_i                 (tlb_cp_ack_i),
    .tlb_pagewalk_invalidated_i   (tlb_pagewalk_invalidated_i),
    .mbist_en_i                   (mbist_en),
    // Outputs
    .dcu_ac_ready_o               (dcu_ac_ready_o),
    .dcu_cr_alloc_o               (dcu_cr_alloc_o),
    .dcu_cr_dirty_o               (dcu_cr_dirty_o),
    .dcu_cr_id_o                  (dcu_cr_id_o[2:0]),
    .dcu_cr_migratory_o           (dcu_cr_migratory_o),
    .dcu_cr_age_o                 (dcu_cr_age_o),
    .dcu_cr_valid_o               (dcu_cr_valid_o),
    .dcu_dvm_complete_o           (dcu_dvm_complete_o),
    .dcu_ccb_ways_o               (dcu_ccb_ways_o[3:0]),
    .dcu_ccb_index_o              (dcu_ccb_index_o[13:6]),
    .dcu_ccb_req_active_o         (dcu_ccb_req_active_o),
    .dvm_stop_pf_o                (dvm_stop_pf),
    .dcu_drain_stb_lf_o           (dcu_drain_stb_lf_o),
    .dcu_snoop_dw_active_o        (dcu_snoop_dw_active_o),
    .dcu_snoop_valid_m2_o         (dcu_snoop_valid_m2_o),
    .dcu_snoop_chunk_m2_o         (dcu_snoop_chunk_m2_o[1:0]),
    .dcu_snoop_rotate_m2_o        (dcu_snoop_rotate_m2_o[1:0]),
    .dcu_snoop_l2db_id_m2_o       (dcu_snoop_l2db_id_m2_o[3:0]),
    .dcu_snoop_last_m2_o          (dcu_snoop_last_m2_o),
    .ccb_data_req_m1_o            (ccb_data_req_m1),
    .ccb_valid_data_req_m1_o      (ccb_valid_data_req_m1),
    .ccb_tag_req_m1_o             (ccb_tag_req_m1),
    .ccb_dirty_req_m1_o           (ccb_dirty_req_m1),
    .ccb_write_addr_m1_o          (ccb_write_addr_m1[40:6]),
    .ccb_dirty_addr_m1_o          (ccb_dirty_addr_m1[13:6]),
    .ccb_data_addr_m1_o           (ccb_data_addr_m1[13:5]),
    .ccb_write_way_m1_o           (ccb_write_way_m1[3:0]),
    .ccb_dirty_way_m1_o           (ccb_dirty_way_m1[3:0]),
    .ccb_ecc_make_inv_o           (ccb_ecc_make_inv),
    .ccb_lookup_way_o             (ccb_lookup_way[3:0]),
    .ccb_lookup_addr_o            (ccb_lookup_addr[13:6]),
    .ccb_inv_snoop_m2_o           (ccb_inv_snoop_m2),
    .ccb_tag_moesi_m1_o           (ccb_tag_moesi_m1[1:0]),
    .ccb_dirty_wdata_m1_o         (ccb_dirty_wdata_m1[3:0]),
    .ccb_block_prearb_tag_m1_o    (ccb_block_prearb_tag_m1),
    .ccb_dirty_m2_o               (ccb_dirty_m2),
    .mbist_sel_mb3_o              (mbist_sel_mb3),
    .mbist_cfg_mb3_o              (mbist_cfg_mb3),
    .mbist_read_en_mb3_o          (mbist_read_en_mb3),
    .mbist_write_en_mb3_o         (mbist_write_en_mb3),
    .mbist_be_mb3_o               (mbist_be_mb3[(`CA53_DDIRTY_RAM_W-1):0]),
    .mbist_array_mb3_o            (mbist_array_mb3[8:0]),
    .mbist_addr_mb3_o             (mbist_addr_mb3[10:0]),
    .dcu_drain_slots_o            (dcu_drain_slots_o[4:0]),
    .dcu_ccb_req_valid_o          (dcu_ccb_req_valid_o),
    .dcu_dvm_valid_ifu_o          (dcu_dvm_valid_ifu_o),
    .dcu_dvm_valid_tlb_o          (dcu_dvm_valid_tlb),
    .dvm_ns_o                     (dvm_ns),
    .dvm_cp_addr_o                (dvm_cp_addr[61:0]),
    .dvm_tlb_cp_op_o              (dvm_tlb_cp_op[4:0]),
    .dvm_ifu_cp_op_o              (dvm_ifu_cp_op[2:0]),
    .dvm_in_progress_o            (dvm_in_progress),
    .ccb_invalidating_tag_m1_o    (ccb_invalidating_tag_m1),
    .ccb_throttle_loads_o         (ccb_throttle_loads),
    .mbist_ctl_data_mb3_o         (mbist_ctl_data_mb3[34:0]),
    .ccb_wfx_ready_o              (ccb_wfx_ready)
  );  // u_ccbctl


  //---------------------------------------------------------------------------
  // OVLs
  //---------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON
  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: force_reset")
  u_ovl_x_force_reset (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (force_reset));

`endif

endmodule // ca53dcu

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53dcu_defs.v"
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
