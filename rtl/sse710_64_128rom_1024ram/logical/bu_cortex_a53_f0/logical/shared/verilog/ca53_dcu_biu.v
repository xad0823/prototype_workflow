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


// This is the specification for the interface between the DCU and the BIU for
// DCU load requests and BIU cache arbiter requests.
// Inputs and outputs are from the point of view of the DCU.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_dcu_biu_defs.v"
`include "cortexa53params.v"
`include "ca53_ace_defs.v"

module ca53_dcu_biu #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         biu_pld_l2_next_ready_i,
  input         biu_read_data_valid_dc2_i,
  input  [63:0] biu_read_data_dc2_i,
  input         biu_read_abort_dc2_i,
  input   [1:0] biu_read_fault_dc2_i,
  input         biu_suppress_load_hit_dc2_i,
  input         biu_lf_ready_dc2_i,
  input         biu_lf_next_ready_dc3_i,
  input         biu_read_data_valid_dc3_i,
  input  [63:0] biu_read_data_dc3_i,
  input         biu_read_abort_dc3_i,
  input   [1:0] biu_read_fault_dc3_i,
  input         biu_ecc_cinv_ack_i,
  input         biu_ecc_cinv_complete_i,
  input   [7:0] biu_lf_in_progress_i,
  input   [3:0] biu_pf_in_progress_i,
  input [255:0] biu_alloc_data_m0_i,
  input         biu_alloc_tag_req_m0_i,
  input         biu_alloc_data_req_m0_i,
  input         biu_alloc_halfline_m0_i,
  input         biu_alloc_dirty_req_m0_i,
  input  [39:4] biu_alloc_addr_m0_i,
  input         biu_alloc_ns_dsc_m0_i,
  input   [3:0] biu_alloc_way_m0_i,
  input   [1:0] biu_alloc_tag_moesi_m0_i,
  input   [1:0] biu_alloc_dirty_moesi_m1_i,
  input         biu_alloc_dirty_age_m1_i,
  input   [7:0] biu_alloc_attrs_m1_i,
  input         biu_pf_tag_req_m0_i,
  input  [39:6] biu_pf_tag_addr_m0_i,
  input         biu_pf_tag_ns_dsc_m0_i,
  input         biu_ccb_lf_hazard_i,
  input         biu_strex_bresp_valid_i,
  input   [1:0] biu_strex_bresp_i,
  input         biu_dirty_lf_in_progress_i,
  input         biu_suppress_tlb_hit_i,
  input         dpu_kill_wr_i,
  input         dpu_flush_i,
  input         dpu_ready_wr_i,
  input         dpu_ready_cc_fail_wr_i,
  input [39:12] dpu_pa_dc1_i,
  input  [11:6] dpu_va_dc1_i,
  input         dpu_ns_dsc_dc1_i,
  input   [4:0] stb_slots_valid_i,
  input   [4:0] stb_slots_dev_ng_i,
  input         dcu_store_cp15_dc3_i,
  input   [7:0] dcu_stb_attrs_dc3_i,
  input         stb_cache_data_req_m0_i,
  input         stb_cache_data_wr_m0_i,
  input         dcu_stb_data_has_priority_m0_i,
  input         dcu_stb_data_ack_m1_i,
  input         gov_mbist_req_i,
  input         dcu_cache_walk_ack_m1_i,
  input         dcu_load_dc1_i,
  input         dcu_leaving_dc1_i,
  input         dcu_lf_active_i,
  input         dcu_load_dc2_i,
  input  [39:0] dcu_pa_dc2_i,
  input         dcu_ns_dsc_dc2_i,
  input   [7:0] dcu_attrs_dc2_i,
  input   [1:0] dcu_size_dc2_i,
  input   [3:0] dcu_length_dc2_i,
  input         dcu_pld_l2_req_dc2_i,
  input         dcu_exclusive_dc2_i,
  input         dcu_lf_req_dc1_i,
  input   [1:0] dcu_lf_way_dc1_i,
  input   [7:0] dcu_attrs_dc1_i,
  input         dcu_lf_req_dc2_i,
  input   [1:0] dcu_lf_way_dc2_i,
  input         dcu_biu_req_dc2_i,
  input         dcu_biu_active_i,
  input         dcu_leaving_dc2_i,
  input         dcu_load_dc3_i,
  input         dcu_lf_req_dc3_i,
  input   [1:0] dcu_lf_way_dc3_i,
  input         dcu_neon_access_dc3_i,
  input         dcu_biu_req_dc3_i,
  input         dcu_stb_req_dc3_i,
  input  [39:0] dcu_pa_dc3_i,
  input         dcu_pipe_valid_dc3_i,
  input         dcu_valid_dc3_i,
  input         dcu_ns_dsc_dc3_i,
  input         dcu_priv_dc3_i,
  input   [7:0] dcu_attrs_dc3_i,
  input   [1:0] dcu_size_dc3_i,
  input   [3:0] dcu_length_dc3_i,
  input         dcu_exclusive_dc3_i,
  input         dcu_pldw_dc3_i,
  input         dcu_pld_l2_req_dc3_i,
  input         dcu_stop_pf_i,
  input         dcu_drain_stb_lf_i,
  input         dcu_ecc_cinv_req_i,
  input   [7:0] dcu_ecc_cinv_index_i,
  input   [1:0] dcu_ecc_cinv_way_i,
  input  [55:0] dcu_ecc_syndrome_m3_i,
  input         dcu_ecc_fatal_m3_i,
  input         dcu_ecc_tag_err_m3_i,
  input         dcu_snoop_dw_active_i,
  input         dcu_snoop_valid_m2_i,
  input [255:0] dcu_snoop_data_m2_i,
  input   [1:0] dcu_snoop_chunk_m2_i,
  input   [1:0] dcu_snoop_rotate_m2_i,
  input   [3:0] dcu_snoop_l2db_id_m2_i,
  input         dcu_snoop_last_m2_i,
  input         dcu_alloc_has_priority_m0_i,
  input         dcu_alloc_ack_m1_i,
  input         dcu_pf_tag_has_priority_m0_i,
  input         dcu_pf_tag_ack_m1_i,
  input         dcu_pf_tag_hit_m2_i,
  input         dcu_ccb_req_active_i,
  input   [3:0] dcu_ccb_ways_i,
  input  [13:6] dcu_ccb_index_i,
  input  [63:0] dcu_mbist_out_data_mb6_i,
  input   [6:0] dcu_mbist_data_checkbits_mb6_i,
  input   [8:0] dcu_mbist_array_mb3_i);


  wire         biu_pld_l2_next_ready = biu_pld_l2_next_ready_i;
  wire         biu_read_data_valid_dc2 = biu_read_data_valid_dc2_i;
  wire  [63:0] biu_read_data_dc2 = biu_read_data_dc2_i;
  wire         biu_read_abort_dc2 = biu_read_abort_dc2_i;
  wire   [1:0] biu_read_fault_dc2 = biu_read_fault_dc2_i;
  wire         biu_suppress_load_hit_dc2 = biu_suppress_load_hit_dc2_i;
  wire         biu_lf_ready_dc2 = biu_lf_ready_dc2_i;
  wire         biu_lf_next_ready_dc3 = biu_lf_next_ready_dc3_i;
  wire         biu_read_data_valid_dc3 = biu_read_data_valid_dc3_i;
  wire  [63:0] biu_read_data_dc3 = biu_read_data_dc3_i;
  wire         biu_read_abort_dc3 = biu_read_abort_dc3_i;
  wire   [1:0] biu_read_fault_dc3 = biu_read_fault_dc3_i;
  wire         biu_ecc_cinv_ack = biu_ecc_cinv_ack_i;
  wire         biu_ecc_cinv_complete = biu_ecc_cinv_complete_i;
  wire   [7:0] biu_lf_in_progress = biu_lf_in_progress_i;
  wire   [3:0] biu_pf_in_progress = biu_pf_in_progress_i;
  wire [255:0] biu_alloc_data_m0 = biu_alloc_data_m0_i;
  wire         biu_alloc_tag_req_m0 = biu_alloc_tag_req_m0_i;
  wire         biu_alloc_data_req_m0 = biu_alloc_data_req_m0_i;
  wire         biu_alloc_halfline_m0 = biu_alloc_halfline_m0_i;
  wire         biu_alloc_dirty_req_m0 = biu_alloc_dirty_req_m0_i;
  wire  [39:4] biu_alloc_addr_m0 = biu_alloc_addr_m0_i;
  wire         biu_alloc_ns_dsc_m0 = biu_alloc_ns_dsc_m0_i;
  wire   [3:0] biu_alloc_way_m0 = biu_alloc_way_m0_i;
  wire   [1:0] biu_alloc_tag_moesi_m0 = biu_alloc_tag_moesi_m0_i;
  wire   [1:0] biu_alloc_dirty_moesi_m1 = biu_alloc_dirty_moesi_m1_i;
  wire         biu_alloc_dirty_age_m1 = biu_alloc_dirty_age_m1_i;
  wire   [7:0] biu_alloc_attrs_m1 = biu_alloc_attrs_m1_i;
  wire         biu_pf_tag_req_m0 = biu_pf_tag_req_m0_i;
  wire  [39:6] biu_pf_tag_addr_m0 = biu_pf_tag_addr_m0_i;
  wire         biu_pf_tag_ns_dsc_m0 = biu_pf_tag_ns_dsc_m0_i;
  wire         biu_ccb_lf_hazard = biu_ccb_lf_hazard_i;
  wire         biu_strex_bresp_valid = biu_strex_bresp_valid_i;
  wire   [1:0] biu_strex_bresp = biu_strex_bresp_i;
  wire         biu_dirty_lf_in_progress = biu_dirty_lf_in_progress_i;
  wire         biu_suppress_tlb_hit = biu_suppress_tlb_hit_i;
  wire         dpu_kill_wr = dpu_kill_wr_i;
  wire         dpu_flush = dpu_flush_i;
  wire         dpu_ready_wr = dpu_ready_wr_i;
  wire         dpu_ready_cc_fail_wr = dpu_ready_cc_fail_wr_i;
  wire [39:12] dpu_pa_dc1 = dpu_pa_dc1_i;
  wire  [11:6] dpu_va_dc1 = dpu_va_dc1_i;
  wire         dpu_ns_dsc_dc1 = dpu_ns_dsc_dc1_i;
  wire   [4:0] stb_slots_valid = stb_slots_valid_i;
  wire   [4:0] stb_slots_dev_ng = stb_slots_dev_ng_i;
  wire         dcu_store_cp15_dc3 = dcu_store_cp15_dc3_i;
  wire   [7:0] dcu_stb_attrs_dc3 = dcu_stb_attrs_dc3_i;
  wire         stb_cache_data_req_m0 = stb_cache_data_req_m0_i;
  wire         stb_cache_data_wr_m0 = stb_cache_data_wr_m0_i;
  wire         dcu_stb_data_has_priority_m0 = dcu_stb_data_has_priority_m0_i;
  wire         dcu_stb_data_ack_m1 = dcu_stb_data_ack_m1_i;
  wire         gov_mbist_req = gov_mbist_req_i;
  wire         dcu_cache_walk_ack_m1 = dcu_cache_walk_ack_m1_i;
  wire         dcu_load_dc1 = dcu_load_dc1_i;
  wire         dcu_leaving_dc1 = dcu_leaving_dc1_i;
  wire         dcu_lf_active = dcu_lf_active_i;
  wire         dcu_load_dc2 = dcu_load_dc2_i;
  wire  [39:0] dcu_pa_dc2 = dcu_pa_dc2_i;
  wire         dcu_ns_dsc_dc2 = dcu_ns_dsc_dc2_i;
  wire   [7:0] dcu_attrs_dc2 = dcu_attrs_dc2_i;
  wire   [1:0] dcu_size_dc2 = dcu_size_dc2_i;
  wire   [3:0] dcu_length_dc2 = dcu_length_dc2_i;
  wire         dcu_pld_l2_req_dc2 = dcu_pld_l2_req_dc2_i;
  wire         dcu_exclusive_dc2 = dcu_exclusive_dc2_i;
  wire         dcu_lf_req_dc1 = dcu_lf_req_dc1_i;
  wire   [1:0] dcu_lf_way_dc1 = dcu_lf_way_dc1_i;
  wire   [7:0] dcu_attrs_dc1 = dcu_attrs_dc1_i;
  wire         dcu_lf_req_dc2 = dcu_lf_req_dc2_i;
  wire   [1:0] dcu_lf_way_dc2 = dcu_lf_way_dc2_i;
  wire         dcu_biu_req_dc2 = dcu_biu_req_dc2_i;
  wire         dcu_biu_active = dcu_biu_active_i;
  wire         dcu_leaving_dc2 = dcu_leaving_dc2_i;
  wire         dcu_load_dc3 = dcu_load_dc3_i;
  wire         dcu_lf_req_dc3 = dcu_lf_req_dc3_i;
  wire   [1:0] dcu_lf_way_dc3 = dcu_lf_way_dc3_i;
  wire         dcu_neon_access_dc3 = dcu_neon_access_dc3_i;
  wire         dcu_biu_req_dc3 = dcu_biu_req_dc3_i;
  wire         dcu_stb_req_dc3 = dcu_stb_req_dc3_i;
  wire  [39:0] dcu_pa_dc3 = dcu_pa_dc3_i;
  wire         dcu_pipe_valid_dc3 = dcu_pipe_valid_dc3_i;
  wire         dcu_valid_dc3 = dcu_valid_dc3_i;
  wire         dcu_ns_dsc_dc3 = dcu_ns_dsc_dc3_i;
  wire         dcu_priv_dc3 = dcu_priv_dc3_i;
  wire   [7:0] dcu_attrs_dc3 = dcu_attrs_dc3_i;
  wire   [1:0] dcu_size_dc3 = dcu_size_dc3_i;
  wire   [3:0] dcu_length_dc3 = dcu_length_dc3_i;
  wire         dcu_exclusive_dc3 = dcu_exclusive_dc3_i;
  wire         dcu_pldw_dc3 = dcu_pldw_dc3_i;
  wire         dcu_pld_l2_req_dc3 = dcu_pld_l2_req_dc3_i;
  wire         dcu_stop_pf = dcu_stop_pf_i;
  wire         dcu_drain_stb_lf = dcu_drain_stb_lf_i;
  wire         dcu_ecc_cinv_req = dcu_ecc_cinv_req_i;
  wire   [7:0] dcu_ecc_cinv_index = dcu_ecc_cinv_index_i;
  wire   [1:0] dcu_ecc_cinv_way = dcu_ecc_cinv_way_i;
  wire  [55:0] dcu_ecc_syndrome_m3 = dcu_ecc_syndrome_m3_i;
  wire         dcu_ecc_fatal_m3 = dcu_ecc_fatal_m3_i;
  wire         dcu_ecc_tag_err_m3 = dcu_ecc_tag_err_m3_i;
  wire         dcu_snoop_dw_active = dcu_snoop_dw_active_i;
  wire         dcu_snoop_valid_m2 = dcu_snoop_valid_m2_i;
  wire [255:0] dcu_snoop_data_m2 = dcu_snoop_data_m2_i;
  wire   [1:0] dcu_snoop_chunk_m2 = dcu_snoop_chunk_m2_i;
  wire   [1:0] dcu_snoop_rotate_m2 = dcu_snoop_rotate_m2_i;
  wire   [3:0] dcu_snoop_l2db_id_m2 = dcu_snoop_l2db_id_m2_i;
  wire         dcu_snoop_last_m2 = dcu_snoop_last_m2_i;
  wire         dcu_alloc_has_priority_m0 = dcu_alloc_has_priority_m0_i;
  wire         dcu_alloc_ack_m1 = dcu_alloc_ack_m1_i;
  wire         dcu_pf_tag_has_priority_m0 = dcu_pf_tag_has_priority_m0_i;
  wire         dcu_pf_tag_ack_m1 = dcu_pf_tag_ack_m1_i;
  wire         dcu_pf_tag_hit_m2 = dcu_pf_tag_hit_m2_i;
  wire         dcu_ccb_req_active = dcu_ccb_req_active_i;
  wire   [3:0] dcu_ccb_ways = dcu_ccb_ways_i;
  wire  [13:6] dcu_ccb_index = dcu_ccb_index_i;
  wire  [63:0] dcu_mbist_out_data_mb6 = dcu_mbist_out_data_mb6_i;
  wire   [6:0] dcu_mbist_data_checkbits_mb6 = dcu_mbist_data_checkbits_mb6_i;
  wire   [8:0] dcu_mbist_array_mb3 = dcu_mbist_array_mb3_i;

  wire         next_ongoing_burst_dc3;
  wire  [63:0] dc2_data_valid;
  wire         flush_dc2;
  wire  [40:0] dcu_pa_incr_dc3;
  wire  [40:0] dcu_pa_incr_dc2;
  wire         load_dc2_could_change;
  wire         dcu_load_last_beat_dc3;
  wire         new_burst_dc3;
  wire         cc_fail_or_flush_dc2;
  wire         cc_fail_or_flush_dc3;
  wire         flush_dc3;
  wire         dcu_load_last_beat_dc2;
  wire         cross64_dc3;
  wire         ongoing_burst_finishing_dc3;

  reg         previous_dcu_leaving_dc3;
  reg         alloc_tag_in_m1;
  reg         write_in_m1;
  reg  [39:0] previous_pa_dc2;
  reg  [39:0] previous_pa_dc3;
  reg   [7:0] previous_attrs_dc2;
  reg         previous_exclusive_dc2;
  reg         dc3_part_of_ongoing_burst;
  reg         previous_ns_dsc_dc1;
  reg   [7:0] previous_attrs_dc3;
  reg         pf_tag_in_m1;
  reg         previous_ns_dsc_dc2;
  reg         load_dc2_held_while_stalled;
  reg         ongoing_burst_dc3;
  reg         alloc_dirty_in_m1;
  reg         non_reset_seen;
  reg   [3:0] previous_length_dc3;
  reg         alloc_data_in_m1;
  reg   [3:0] previous_length_dc2;
  reg  [39:6] previous_pa_dc1;

  reg         dcu_leaving_dc1_reg;
  reg   [7:0] dcu_attrs_dc3_reg;
  reg         dcu_cache_walk_ack_m1_reg;
  reg         dcu_lf_req_dc3_reg;
  reg   [7:0] biu_alloc_attrs_m1_reg;
  reg  [39:0] dcu_pa_dc2_reg;
  reg   [1:0] dcu_lf_way_dc2_reg;
  reg   [7:0] dcu_attrs_dc2_reg;
  reg         dcu_pldw_dc3_reg;
  reg   [3:0] dcu_length_dc3_reg;
  reg         dcu_biu_req_dc3_reg;
  reg         dcu_pf_tag_ack_m1_reg;
  reg         dcu_pf_tag_ack_m1_reg_reg;
  reg         dcu_priv_dc3_reg;
  reg   [1:0] dcu_size_dc2_reg;
  reg         dcu_load_dc3_reg;
  reg         dcu_exclusive_dc2_reg;
  reg         dpu_kill_wr_reg;
  reg         dcu_lf_active_reg;
  reg         dcu_ns_dsc_dc2_reg;
  reg         biu_read_data_valid_dc2_reg;
  reg         dcu_load_dc2_reg;
  reg   [3:0] dcu_length_dc2_reg;
  reg   [1:0] dcu_size_dc3_reg;
  reg   [1:0] dcu_lf_way_dc3_reg;
  reg         dcu_snoop_valid_m2_reg;
  reg         ongoing_burst_dc3_reg;
  reg         dcu_lf_req_dc1_reg;
  reg   [1:0] dcu_lf_way_dc1_reg;
  reg         alloc_dirty_in_m1_reg;
  reg         dcu_lf_req_dc2_reg;
  reg         dcu_exclusive_dc3_reg;
  reg         cc_fail_or_flush_dc2_reg;
  reg         biu_read_data_valid_dc3_reg;
  reg         dcu_ns_dsc_dc3_reg;
  reg         biu_pld_l2_next_ready_reg;
  reg         biu_pld_l2_next_ready_reg_reg;
  reg         dcu_load_dc1_reg;
  reg         cc_fail_or_flush_dc3_reg;
  reg         dcu_valid_dc3_reg;
  reg         dcu_pld_l2_req_dc2_reg;
  reg         dcu_load_last_beat_dc2_reg;
  reg         dcu_biu_req_dc2_reg;
  reg         dpu_ready_wr_reg;
  reg         dcu_leaving_dc2_reg;
  reg         dc3_part_of_ongoing_burst_reg;
  reg         dcu_pld_l2_req_dc3_reg;
  reg   [1:0] biu_alloc_dirty_moesi_m1_reg;
  reg         ongoing_burst_finishing_dc3_reg;
  reg         dcu_alloc_ack_m1_reg;
  reg         dcu_snoop_dw_active_reg;
  reg  [39:0] dcu_pa_dc3_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    dcu_leaving_dc1_reg <= 1'b0;
    dcu_attrs_dc3_reg <= {8{1'b0}};
    dcu_cache_walk_ack_m1_reg <= 1'b0;
    dcu_lf_req_dc3_reg <= 1'b0;
    biu_alloc_attrs_m1_reg <= {8{1'b0}};
    dcu_pa_dc2_reg <= {40{1'b0}};
    dcu_lf_way_dc2_reg <= 2'b00;
    dcu_attrs_dc2_reg <= {8{1'b0}};
    dcu_pldw_dc3_reg <= 1'b0;
    dcu_length_dc3_reg <= 4'b0000;
    dcu_biu_req_dc3_reg <= 1'b0;
    dcu_pf_tag_ack_m1_reg <= 1'b0;
    dcu_pf_tag_ack_m1_reg_reg <= 1'b0;
    dcu_priv_dc3_reg <= 1'b0;
    dcu_size_dc2_reg <= 2'b00;
    dcu_load_dc3_reg <= 1'b0;
    dcu_exclusive_dc2_reg <= 1'b0;
    dpu_kill_wr_reg <= 1'b0;
    dcu_lf_active_reg <= 1'b0;
    dcu_ns_dsc_dc2_reg <= 1'b0;
    biu_read_data_valid_dc2_reg <= 1'b0;
    dcu_load_dc2_reg <= 1'b0;
    dcu_length_dc2_reg <= 4'b0000;
    dcu_size_dc3_reg <= 2'b00;
    dcu_lf_way_dc3_reg <= 2'b00;
    dcu_snoop_valid_m2_reg <= 1'b0;
    ongoing_burst_dc3_reg <= 1'b0;
    dcu_lf_req_dc1_reg <= 1'b0;
    dcu_lf_way_dc1_reg <= 2'b00;
    alloc_dirty_in_m1_reg <= 1'b0;
    dcu_lf_req_dc2_reg <= 1'b0;
    dcu_exclusive_dc3_reg <= 1'b0;
    cc_fail_or_flush_dc2_reg <= 1'b0;
    biu_read_data_valid_dc3_reg <= 1'b0;
    dcu_ns_dsc_dc3_reg <= 1'b0;
    biu_pld_l2_next_ready_reg <= 1'b0;
    biu_pld_l2_next_ready_reg_reg <= 1'b0;
    dcu_load_dc1_reg <= 1'b0;
    cc_fail_or_flush_dc3_reg <= 1'b0;
    dcu_valid_dc3_reg <= 1'b0;
    dcu_pld_l2_req_dc2_reg <= 1'b0;
    dcu_load_last_beat_dc2_reg <= 1'b0;
    dcu_biu_req_dc2_reg <= 1'b0;
    dpu_ready_wr_reg <= 1'b0;
    dcu_leaving_dc2_reg <= 1'b0;
    dc3_part_of_ongoing_burst_reg <= 1'b0;
    dcu_pld_l2_req_dc3_reg <= 1'b0;
    biu_alloc_dirty_moesi_m1_reg <= 2'b00;
    ongoing_burst_finishing_dc3_reg <= 1'b0;
    dcu_alloc_ack_m1_reg <= 1'b0;
    dcu_snoop_dw_active_reg <= 1'b0;
    dcu_pa_dc3_reg <= {40{1'b0}};
  end
  else
  begin
    biu_pld_l2_next_ready_reg <= biu_pld_l2_next_ready;
    biu_pld_l2_next_ready_reg_reg <= biu_pld_l2_next_ready_reg;
    biu_read_data_valid_dc2_reg <= biu_read_data_valid_dc2;
    biu_read_data_valid_dc3_reg <= biu_read_data_valid_dc3;
    biu_alloc_dirty_moesi_m1_reg <= biu_alloc_dirty_moesi_m1;
    biu_alloc_attrs_m1_reg <= biu_alloc_attrs_m1;
    dpu_kill_wr_reg <= dpu_kill_wr;
    dpu_ready_wr_reg <= dpu_ready_wr;
    dcu_cache_walk_ack_m1_reg <= dcu_cache_walk_ack_m1;
    dcu_load_dc1_reg <= dcu_load_dc1;
    dcu_leaving_dc1_reg <= dcu_leaving_dc1;
    dcu_lf_active_reg <= dcu_lf_active;
    dcu_load_dc2_reg <= dcu_load_dc2;
    dcu_pa_dc2_reg <= dcu_pa_dc2;
    dcu_ns_dsc_dc2_reg <= dcu_ns_dsc_dc2;
    dcu_attrs_dc2_reg <= dcu_attrs_dc2;
    dcu_size_dc2_reg <= dcu_size_dc2;
    dcu_length_dc2_reg <= dcu_length_dc2;
    dcu_pld_l2_req_dc2_reg <= dcu_pld_l2_req_dc2;
    dcu_exclusive_dc2_reg <= dcu_exclusive_dc2;
    dcu_lf_req_dc1_reg <= dcu_lf_req_dc1;
    dcu_lf_way_dc1_reg <= dcu_lf_way_dc1;
    dcu_lf_req_dc2_reg <= dcu_lf_req_dc2;
    dcu_lf_way_dc2_reg <= dcu_lf_way_dc2;
    dcu_biu_req_dc2_reg <= dcu_biu_req_dc2;
    dcu_leaving_dc2_reg <= dcu_leaving_dc2;
    dcu_load_dc3_reg <= dcu_load_dc3;
    dcu_lf_req_dc3_reg <= dcu_lf_req_dc3;
    dcu_lf_way_dc3_reg <= dcu_lf_way_dc3;
    dcu_biu_req_dc3_reg <= dcu_biu_req_dc3;
    dcu_pa_dc3_reg <= dcu_pa_dc3;
    dcu_valid_dc3_reg <= dcu_valid_dc3;
    dcu_ns_dsc_dc3_reg <= dcu_ns_dsc_dc3;
    dcu_priv_dc3_reg <= dcu_priv_dc3;
    dcu_attrs_dc3_reg <= dcu_attrs_dc3;
    dcu_size_dc3_reg <= dcu_size_dc3;
    dcu_length_dc3_reg <= dcu_length_dc3;
    dcu_exclusive_dc3_reg <= dcu_exclusive_dc3;
    dcu_pldw_dc3_reg <= dcu_pldw_dc3;
    dcu_pld_l2_req_dc3_reg <= dcu_pld_l2_req_dc3;
    dcu_snoop_dw_active_reg <= dcu_snoop_dw_active;
    dcu_snoop_valid_m2_reg <= dcu_snoop_valid_m2;
    dcu_alloc_ack_m1_reg <= dcu_alloc_ack_m1;
    dcu_pf_tag_ack_m1_reg <= dcu_pf_tag_ack_m1;
    dcu_pf_tag_ack_m1_reg_reg <= dcu_pf_tag_ack_m1_reg;
    ongoing_burst_dc3_reg <= ongoing_burst_dc3;
    alloc_dirty_in_m1_reg <= alloc_dirty_in_m1;
    cc_fail_or_flush_dc2_reg <= cc_fail_or_flush_dc2;
    cc_fail_or_flush_dc3_reg <= cc_fail_or_flush_dc3;
    dcu_load_last_beat_dc2_reg <= dcu_load_last_beat_dc2;
    dc3_part_of_ongoing_burst_reg <= dc3_part_of_ongoing_burst;
    ongoing_burst_finishing_dc3_reg <= ongoing_burst_finishing_dc3;
  end



  //-----------------------------------------------------------------------------
  //
  // DC1 Address Request Channel
  //
  //-----------------------------------------------------------------------------

  // There is a valid load transaction in dc1.
  //  output dcu_load_dc1 valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_load_dc1 X or Z")
  u_ovl_intf_x_dcu_load_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_load_dc1));


  // The transaction in dc1 is moving into dc2 next cycle.
  //  output dcu_leaving_dc1 valid always timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_leaving_dc1 X or Z")
  u_ovl_intf_x_dcu_leaving_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_leaving_dc1));


  //-----------------------------------------------------------------------------
  //
  // DC2 Address Request Channel
  //
  //-----------------------------------------------------------------------------

  // The DCU may request a new linefill in the following clock cycle
  //  output dcu_lf_active valid always timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_lf_active X or Z")
  u_ovl_intf_x_dcu_lf_active (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_lf_active));


  // There is a valid load transaction in dc2.
  //  output dcu_load_dc2 valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_load_dc2 X or Z")
  u_ovl_intf_x_dcu_load_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_load_dc2));


  // The physical address of the transaction in dc2.
  //  output [39:0] dcu_pa_dc2 valid dcu_load_dc2 timing 20%

  assert_never_unknown #(`OVL_FATAL, 40, OUTOPTIONS, "dcu_pa_dc2 X or Z")
  u_ovl_intf_x_dcu_pa_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc2),
    .test_expr (dcu_pa_dc2));


  // The TrustZone non-secure bit of the transaction in dc2.
  //  output dcu_ns_dsc_dc2 valid dcu_load_dc2 timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_ns_dsc_dc2 X or Z")
  u_ovl_intf_x_dcu_ns_dsc_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc2),
    .test_expr (dcu_ns_dsc_dc2));


  // The memory type, inner and outer cacheability and shareability attributes of the load in dc2.
  // See cortexa53params for the encoding.
  //  output [7:0] dcu_attrs_dc2 valid dcu_load_dc2 timing 20%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "dcu_attrs_dc2 X or Z")
  u_ovl_intf_x_dcu_attrs_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc2),
    .test_expr (dcu_attrs_dc2));


  // The size of the transaction
  //  output [1:0] dcu_size_dc2 valid dcu_load_dc2 timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "dcu_size_dc2 X or Z")
  u_ovl_intf_x_dcu_size_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc2),
    .test_expr (dcu_size_dc2));


  // The number of transactions following in the burst. Zero if this is not a
  // burst, zero or one if this is the last transaction in a burst.
  //  output [3:0] dcu_length_dc2 valid dcu_load_dc2 timing 50%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "dcu_length_dc2 X or Z")
  u_ovl_intf_x_dcu_length_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc2),
    .test_expr (dcu_length_dc2));


  // A PLD L2 request to BIU.
  //  output dcu_pld_l2_req_dc2 valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_pld_l2_req_dc2 X or Z")
  u_ovl_intf_x_dcu_pld_l2_req_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_pld_l2_req_dc2));


  // The BIU indicates that the PLD will be ready next cycle.
  //  input biu_pld_l2_next_ready valid always timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_pld_l2_next_ready X or Z")
  u_ovl_intf_x_biu_pld_l2_next_ready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_pld_l2_next_ready));


  // The transaction is a load exclusive instruction.
  //  output dcu_exclusive_dc2 valid dcu_load_dc2 timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_exclusive_dc2 X or Z")
  u_ovl_intf_x_dcu_exclusive_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc2),
    .test_expr (dcu_exclusive_dc2));


  // The DCU wants to start a speculative linefill for a load which has missed
  // in the cache and stalled in DC1.
  //  output       dcu_lf_req_dc1 valid always         timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_lf_req_dc1 X or Z")
  u_ovl_intf_x_dcu_lf_req_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_lf_req_dc1));

  //  output [1:0] dcu_lf_way_dc1 valid dcu_lf_req_dc1 timing 20%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "dcu_lf_way_dc1 X or Z")
  u_ovl_intf_x_dcu_lf_way_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_lf_req_dc1),
    .test_expr (dcu_lf_way_dc1));

  //  output [7:0] dcu_attrs_dc1  valid dcu_lf_req_dc1 timing 70%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "dcu_attrs_dc1 X or Z")
  u_ovl_intf_x_dcu_attrs_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_lf_req_dc1),
    .test_expr (dcu_attrs_dc1));


  // The load in dc2 missed in the cache and is stalled. The BIU can use this
  // to start a speculative linefill if it has an LF descriptor free, there is no
  // outstanding linefill to this address already, and has already serviced any
  // request from dc3. The DCU must not assert this if there was an STB hazard
  // last cycle, because otherwise it would be possible to start a linefill on
  // AXI in the same cycle as a store to the same address is written out on AXI.
  //  output dcu_lf_req_dc2 valid always timing 35%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_lf_req_dc2 X or Z")
  u_ovl_intf_x_dcu_lf_req_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_lf_req_dc2));


  // The way to allocate the line to. This is only a hint, the BIU may pick a
  // different way if needed to avoid hazards.
  //  output [1:0] dcu_lf_way_dc2 valid dcu_lf_req_dc2 timing 20%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "dcu_lf_way_dc2 X or Z")
  u_ovl_intf_x_dcu_lf_way_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_lf_req_dc2),
    .test_expr (dcu_lf_way_dc2));


  // The load in dc2 wants to start a BIU request for a non-cacheable load.
  //  output dcu_biu_req_dc2 valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_biu_req_dc2 X or Z")
  u_ovl_intf_x_dcu_biu_req_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_biu_req_dc2));


  // There must be a load in dc1 to generate a linefill request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_lf_req_dc1  => dcu_load_dc1")
  u_ovl_intf_assert_0c8d38aff90029d11dfd8198a4f7fef1cb734ec8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_lf_req_dc1 ),
    .consequent_expr (dcu_load_dc1));


  // The DCU linefill must have been previously active if a linefill request is made

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(dcu_lf_req_dc1 | dcu_lf_req_dc2 | dcu_lf_req_dc3)  => dcu_lf_active@1")
  u_ovl_intf_assert_40564e5a6919fd802975d44d50fef0a440abb7b4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((dcu_lf_req_dc1 | dcu_lf_req_dc2 | dcu_lf_req_dc3) ),
    .consequent_expr (dcu_lf_active_reg));


  // Linefill requests must be to cacheable memory and must only be issued
  // when the cache is on.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_lf_req_dc1  => `CA53_MEM_NORMAL(dcu_attrs_dc1) & `CA53_MEM_COHERENT(dcu_attrs_dc1)")
  u_ovl_intf_assert_b4857059556c3f37fab6c963fa726c6f1fee7448 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_lf_req_dc1 ),
    .consequent_expr (`CA53_MEM_NORMAL(dcu_attrs_dc1) & `CA53_MEM_COHERENT(dcu_attrs_dc1)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_lf_req_dc2  => `CA53_MEM_NORMAL(dcu_attrs_dc2) & `CA53_MEM_COHERENT(dcu_attrs_dc2)")
  u_ovl_intf_assert_60a0ba1715363edaa620a573ba07e93ba4a3d4c1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_lf_req_dc2 ),
    .consequent_expr (`CA53_MEM_NORMAL(dcu_attrs_dc2) & `CA53_MEM_COHERENT(dcu_attrs_dc2)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_lf_req_dc3  => `CA53_MEM_NORMAL(dcu_attrs_dc3) & `CA53_MEM_COHERENT(dcu_attrs_dc3)")
  u_ovl_intf_assert_3efe1c1974570e97b9dc9f5a20904a8628cd930e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_lf_req_dc3 ),
    .consequent_expr (`CA53_MEM_NORMAL(dcu_attrs_dc3) & `CA53_MEM_COHERENT(dcu_attrs_dc3)));


  // There must be a load in dc2 to generate a linefill request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_lf_req_dc2  => dcu_load_dc2")
  u_ovl_intf_assert_5f7162154352c6032641a631ca955c8140a57321 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_lf_req_dc2 ),
    .consequent_expr (dcu_load_dc2));


  // Early (speculative) BIU request.
  //  output dcu_biu_active valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_biu_active X or Z")
  u_ovl_intf_x_dcu_biu_active (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_biu_active));


  // dcu_biu_active must be active if there is a request from DCU

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(dcu_pld_l2_req_dc2 | dcu_pld_l2_req_dc3 | dcu_biu_req_dc2    | dcu_biu_req_dc3    | dcu_lf_req_dc1     | dcu_lf_req_dc2     | dcu_lf_req_dc3     | dcu_ecc_cinv_req    )  => dcu_biu_active")
  u_ovl_intf_assert_ffe6f952ecfcc2374291da9603e46f4a04881d7f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((dcu_pld_l2_req_dc2 | dcu_pld_l2_req_dc3 | dcu_biu_req_dc2    | dcu_biu_req_dc3    | dcu_lf_req_dc1     | dcu_lf_req_dc2     | dcu_lf_req_dc3     | dcu_ecc_cinv_req    ) ),
    .consequent_expr (dcu_biu_active));





  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    previous_pa_dc1 <= {34{1'b0}};
  else if (dcu_load_dc1 & dcu_leaving_dc1)
    previous_pa_dc1 <= {dpu_pa_dc1[39:12], dpu_va_dc1[11:6]};


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    previous_ns_dsc_dc1 <= 1'b0;
  else if (dcu_load_dc1 & dcu_leaving_dc1)
    previous_ns_dsc_dc1 <= dpu_ns_dsc_dc1;


  // A load in DC2 must have the same address it had in DC1

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc2  => dcu_pa_dc2[39:6]  == previous_pa_dc1[39:6]")
  u_ovl_intf_assert_a4c70b8e6b1ae5de5c4213bd8d86538e620b15cf (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc2 ),
    .consequent_expr (dcu_pa_dc2[39:6]  == previous_pa_dc1[39:6]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc2  => dcu_ns_dsc_dc2    == previous_ns_dsc_dc1")
  u_ovl_intf_assert_3c1ba5710fc1aa8f76ee200fa3abfed900c1f8ff (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc2 ),
    .consequent_expr (dcu_ns_dsc_dc2    == previous_ns_dsc_dc1));


  // A load in dc2 must have been pending and not leaving previous cycle or
  // dc1 load moving to dc2 previous cycle

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc2  => (dcu_load_dc1@1 & dcu_leaving_dc1@1) | (dcu_load_dc2@1 & ~dcu_leaving_dc2@1)")
  u_ovl_intf_assert_9524cd49d87b9fc5e45c7525ab07c9d5e24d0632 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc2 ),
    .consequent_expr ((dcu_load_dc1_reg & dcu_leaving_dc1_reg) | (dcu_load_dc2_reg & ~dcu_leaving_dc2_reg)));


  // A load arriving in dc2 must have left dc1.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dcu_load_dc2@1 & dcu_load_dc2  => dcu_load_dc1@1 & dcu_leaving_dc1@1")
  u_ovl_intf_assert_81a1a34463b0a6840119050a6100e133a5822f75 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dcu_load_dc2_reg & dcu_load_dc2 ),
    .consequent_expr (dcu_load_dc1_reg & dcu_leaving_dc1_reg));


  // A non-load leaving dc1 must reach dc2.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dcu_load_dc1@1 & dcu_leaving_dc1@1  => ~dcu_load_dc2")
  u_ovl_intf_assert_5e13de2b47c20d05cc16285478956a65537e57fd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dcu_load_dc1_reg & dcu_leaving_dc1_reg ),
    .consequent_expr (~dcu_load_dc2));


  // CC fail or flush during a load request to the BIU.
  assign flush_dc2             = (dpu_kill_wr & ~dcu_pipe_valid_dc3)              | (dpu_flush & (~dpu_ready_wr | dcu_pipe_valid_dc3));
  assign cc_fail_or_flush_dc2  = flush_dc2 | (dpu_ready_cc_fail_wr & ~dcu_pipe_valid_dc3);

  // The transaction in dc2 is moving into dc3 next cycle.
  //  output dcu_leaving_dc2 valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_leaving_dc2 X or Z")
  u_ovl_intf_x_dcu_leaving_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_leaving_dc2));


  // There must be a load in dc2 to generate a BIU request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc2  => dcu_load_dc2")
  u_ovl_intf_assert_22b27497438177423051415c90abd493c9d39406 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc2 ),
    .consequent_expr (dcu_load_dc2));


  // There must be a load in dc2 to generate a BIU pld request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_pld_l2_req_dc2  => dcu_load_dc2")
  u_ovl_intf_assert_de1909495eab835d775b2766364ee01f7fa7744f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_pld_l2_req_dc2 ),
    .consequent_expr (dcu_load_dc2));


  // Exclusive must not be issued in DC2 for normal NC.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc2  => ~dcu_exclusive_dc2")
  u_ovl_intf_assert_491632467b14535da7061217cacb9aa6e77344ff (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc2 ),
    .consequent_expr (~dcu_exclusive_dc2));


  // A request in DC2 should never be to device memory

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc2  => ~`CA53_MEM_DEVICE(dcu_attrs_dc2)")
  u_ovl_intf_assert_2a17be4c418ff3fb1a54eee49d0908572da68e42 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc2 ),
    .consequent_expr (~`CA53_MEM_DEVICE(dcu_attrs_dc2)));


  // A DC2 request should be held until the data is available, moved to DC3 or dropped

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc2@1 & ~cc_fail_or_flush_dc2@1 & ~dcu_leaving_dc2@1 & ~biu_read_data_valid_dc2@1  => dcu_load_dc2")
  u_ovl_intf_assert_d4e67e1818fbaf40d62bc9640211436f04638c5c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc2_reg & ~cc_fail_or_flush_dc2_reg & ~dcu_leaving_dc2_reg & ~biu_read_data_valid_dc2_reg ),
    .consequent_expr (dcu_load_dc2));


  // A DC2 request should be moved to DC3, if dcu_leaving_dc2 and no data received nor dropped

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc2@1 & ~cc_fail_or_flush_dc2@1 & dcu_leaving_dc2@1 & ~biu_read_data_valid_dc2@1  => dcu_load_dc3")
  u_ovl_intf_assert_63e21b907c7302ef60caf8972550a1ce5ac17056 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc2_reg & ~cc_fail_or_flush_dc2_reg & dcu_leaving_dc2_reg & ~biu_read_data_valid_dc2_reg ),
    .consequent_expr (dcu_load_dc3));


  // A DC2 request should be removed once the data is available and not moved to DC3

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc2@1 & biu_read_data_valid_dc2@1 & ~dcu_leaving_dc2@1  => ~dcu_biu_req_dc2")
  u_ovl_intf_assert_4a2204c0ad4b2dc7ab507d52479eb9941ef151b4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc2_reg & biu_read_data_valid_dc2_reg & ~dcu_leaving_dc2_reg ),
    .consequent_expr (~dcu_biu_req_dc2));


  // A DC2 PLD L2 request should be to coherent memory

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_pld_l2_req_dc2  => `CA53_MEM_COHERENT(dcu_attrs_dc2)")
  u_ovl_intf_assert_877ac54521c34fea3d526a0a86aa471041849fb1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_pld_l2_req_dc2 ),
    .consequent_expr (`CA53_MEM_COHERENT(dcu_attrs_dc2)));


  // A DC2 PLD L2 request should be removed once the BIU is ready to accept

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_pld_l2_req_dc2@1 & ~cc_fail_or_flush_dc2@1 & biu_pld_l2_next_ready@2 & ~biu_read_data_valid_dc2@1 & ~dcu_pld_l2_req_dc3@1 & ~dcu_leaving_dc2@1  => ~dcu_pld_l2_req_dc2")
  u_ovl_intf_assert_53ecf8872d27e7205fef81539736bb82690de9cb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_pld_l2_req_dc2_reg & ~cc_fail_or_flush_dc2_reg & biu_pld_l2_next_ready_reg_reg & ~biu_read_data_valid_dc2_reg & ~dcu_pld_l2_req_dc3_reg & ~dcu_leaving_dc2_reg ),
    .consequent_expr (~dcu_pld_l2_req_dc2));


  // The BIU cannot accept PLD L2 requests back to back

  assert_implication #(`OVL_FATAL, INOPTIONS, "biu_pld_l2_next_ready@2 &                                                                                ((dcu_pld_l2_req_dc2@1 & ~cc_fail_or_flush_dc2@1 & ~(dcu_pld_l2_req_dc3@1 & cc_fail_or_flush_dc3@1)) |   (dcu_pld_l2_req_dc3@1 & ~cc_fail_or_flush_dc3@1))  => ~biu_pld_l2_next_ready@1 &                                                                               ~biu_pld_l2_next_ready")
  u_ovl_intf_assume_05f115cfc90fa00c9e6c4a65906255f240bb245f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_pld_l2_next_ready_reg_reg &                                                                                ((dcu_pld_l2_req_dc2_reg & ~cc_fail_or_flush_dc2_reg & ~(dcu_pld_l2_req_dc3_reg & cc_fail_or_flush_dc3_reg)) |   (dcu_pld_l2_req_dc3_reg & ~cc_fail_or_flush_dc3_reg)) ),
    .consequent_expr (~biu_pld_l2_next_ready_reg &                                                                               ~biu_pld_l2_next_ready));


  // The address and attributes of a request must remain stable until the request has completed.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc2@1 & ~cc_fail_or_flush_dc2@1 & ~dcu_leaving_dc2@1 & ~biu_read_data_valid_dc2@1  => dcu_pa_dc2        == dcu_pa_dc2@1")
  u_ovl_intf_assert_a1661907673417bb1d11c56edbb7bd4ec649e4f4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc2_reg & ~cc_fail_or_flush_dc2_reg & ~dcu_leaving_dc2_reg & ~biu_read_data_valid_dc2_reg ),
    .consequent_expr (dcu_pa_dc2        == dcu_pa_dc2_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc2@1 & ~cc_fail_or_flush_dc2@1 & ~dcu_leaving_dc2@1 & ~biu_read_data_valid_dc2@1  => dcu_ns_dsc_dc2    == dcu_ns_dsc_dc2@1")
  u_ovl_intf_assert_7db4f50a42f1963b3a8b4d77ce7e635a2586d735 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc2_reg & ~cc_fail_or_flush_dc2_reg & ~dcu_leaving_dc2_reg & ~biu_read_data_valid_dc2_reg ),
    .consequent_expr (dcu_ns_dsc_dc2    == dcu_ns_dsc_dc2_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc2@1 & ~cc_fail_or_flush_dc2@1 & ~dcu_leaving_dc2@1 & ~biu_read_data_valid_dc2@1  => dcu_attrs_dc2     == dcu_attrs_dc2@1")
  u_ovl_intf_assert_4e1229f630b3bf0d4419a0b92ae7dd8b459d3b5d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc2_reg & ~cc_fail_or_flush_dc2_reg & ~dcu_leaving_dc2_reg & ~biu_read_data_valid_dc2_reg ),
    .consequent_expr (dcu_attrs_dc2     == dcu_attrs_dc2_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc2@1 & ~cc_fail_or_flush_dc2@1 & ~dcu_leaving_dc2@1 & ~biu_read_data_valid_dc2@1  => dcu_size_dc2      == dcu_size_dc2@1")
  u_ovl_intf_assert_27b4a9a0f92bb42540bdfaec9cf9f04b8621ff74 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc2_reg & ~cc_fail_or_flush_dc2_reg & ~dcu_leaving_dc2_reg & ~biu_read_data_valid_dc2_reg ),
    .consequent_expr (dcu_size_dc2      == dcu_size_dc2_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc2@1 & ~cc_fail_or_flush_dc2@1 & ~dcu_leaving_dc2@1 & ~biu_read_data_valid_dc2@1  => dcu_length_dc2    == dcu_length_dc2@1")
  u_ovl_intf_assert_94cdf8bf59d6fd789060b70e163382a1828c8300 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc2_reg & ~cc_fail_or_flush_dc2_reg & ~dcu_leaving_dc2_reg & ~biu_read_data_valid_dc2_reg ),
    .consequent_expr (dcu_length_dc2    == dcu_length_dc2_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc2@1 & ~cc_fail_or_flush_dc2@1 & ~dcu_leaving_dc2@1 & ~biu_read_data_valid_dc2@1  => dcu_exclusive_dc2 == dcu_exclusive_dc2@1")
  u_ovl_intf_assert_b653e95b4de3ed6a4177c129b2e65aaf7f7f0be8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc2_reg & ~cc_fail_or_flush_dc2_reg & ~dcu_leaving_dc2_reg & ~biu_read_data_valid_dc2_reg ),
    .consequent_expr (dcu_exclusive_dc2 == dcu_exclusive_dc2_reg));


  // Compute DC2 last beat info
  assign dcu_load_last_beat_dc2  = ~|dcu_length_dc2[3:1] & (~dcu_length_dc2[0] | ~dcu_pa_dc2[2]);

  //-----------------------------------------------------------------------------
  //
  // DC2 Read Data Channel
  //
  //-----------------------------------------------------------------------------

  // Assuming the transaction in dc2 is a load, indicates if the
  // load hit in the read buffers.
  //  input biu_read_data_valid_dc2 valid dcu_load_dc2 timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_read_data_valid_dc2 X or Z")
  u_ovl_intf_x_biu_read_data_valid_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc2),
    .test_expr (biu_read_data_valid_dc2));


  assign dc2_data_valid  = {64{dcu_load_dc2 & biu_read_data_valid_dc2}};

  // The data from the LFBs that is being requested by the load in dc2.
  //  input [63:0] biu_read_data_dc2 valid mask dc2_data_valid timing 60%

  assert_never_unknown #(`OVL_FATAL, 64, INOPTIONS, "biu_read_data_dc2 & (dc2_data_valid) X or Z")
  u_ovl_intf_x_ce990897fec039ae3fd157e9e4e6a4b119a91f5f (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_read_data_dc2 & (dc2_data_valid)));


  // Indicates the data hit in dc2 has an error response.
  //  input biu_read_abort_dc2 valid dcu_load_dc2 timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_read_abort_dc2 X or Z")
  u_ovl_intf_x_biu_read_abort_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc2),
    .test_expr (biu_read_abort_dc2));


  // The type of abort for the data hit in dc2:
  // 2'b00 SLVERR
  // 2'b01 DECERR
  // 2'b10 ECCERR
  // (LDREXERR not possible in DC2)
  //  input [1:0] biu_read_fault_dc2 valid biu_read_abort_dc2 timing 75%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "biu_read_fault_dc2 X or Z")
  u_ovl_intf_x_biu_read_fault_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_read_abort_dc2),
    .test_expr (biu_read_fault_dc2));



  assert_implication #(`OVL_FATAL, INOPTIONS, "biu_read_abort_dc2  => biu_read_fault_dc2 in [2'b00, 2'b01, 2'b10]")
  u_ovl_intf_assume_94edbbcca0b7aaacb773892b0b264dec515e4aa7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_read_abort_dc2 ),
    .consequent_expr (((biu_read_fault_dc2 == 2'b00) | (biu_read_fault_dc2 ==  2'b01) | (biu_read_fault_dc2 ==  2'b10))));


  // The load matches a LF that has half allocated into the cache and the
  // load is in the halfline that has not been allocated. The cache should
  // be forced not to hit.
  //  input biu_suppress_load_hit_dc2 valid dcu_load_dc2 timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_suppress_load_hit_dc2 X or Z")
  u_ovl_intf_x_biu_suppress_load_hit_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc2),
    .test_expr (biu_suppress_load_hit_dc2));


  //-----------------------------------------------------------------------------
  //
  // DC3 Address Request Channel
  //
  //-----------------------------------------------------------------------------

  // There is a valid load in dc3. It may not have been committed.
  //  output dcu_load_dc3 valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_load_dc3 X or Z")
  u_ovl_intf_x_dcu_load_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_load_dc3));


  // The load in dc3 missed in the cache and wants a linefill started.
  //  output dcu_lf_req_dc3 valid always timing 35%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_lf_req_dc3 X or Z")
  u_ovl_intf_x_dcu_lf_req_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_lf_req_dc3));


  // The way to allocate the line to. This is only a hint, the BIU may pick a
  // different way if needed to avoid hazards.
  //  output [1:0] dcu_lf_way_dc3 valid dcu_lf_req_dc3 timing 20%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "dcu_lf_way_dc3 X or Z")
  u_ovl_intf_x_dcu_lf_way_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_lf_req_dc3),
    .test_expr (dcu_lf_way_dc3));


  // The BIU can accept a DC2 linefill request on this cycle, or a DC3 linefill
  // request for the instruction currently in DC2 on the next cycle. PLDs can
  // use this to decide when to retire.
  //  input biu_lf_ready_dc2 valid always timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_lf_ready_dc2 X or Z")
  u_ovl_intf_x_biu_lf_ready_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_lf_ready_dc2));


  // The BIU will be able to accept a linefill request for the instruction
  // currently in DC3 on the next cycle. PLDs can use this to decide when to
  // retire.
  //  input biu_lf_next_ready_dc3 valid always timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_lf_next_ready_dc3 X or Z")
  u_ovl_intf_x_biu_lf_next_ready_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_lf_next_ready_dc3));


  // The BIU request is for a NEON instruction
  //  output dcu_neon_access_dc3 valid dcu_biu_req_dc3 timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_neon_access_dc3 X or Z")
  u_ovl_intf_x_dcu_neon_access_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_biu_req_dc3),
    .test_expr (dcu_neon_access_dc3));


  // The load in dc3 wants to start a BIU request for a non-cacheable, transient, or device load.
  // This request must be ignored if cc_fail_or_flush_dc3 is asserted.
  // For load multiple transactions, the cc_fail_or_flush_dc3 will also signal
  // the last clock cycle when a load related to the same transaction is requested to the BIU.
  // (ie the DC3 load request is considered a new transaction in the current clock cycle 
  //     if the cc_fail_or_flush_dc3 has been asserted on the previous clock cycle)
  //  output dcu_biu_req_dc3 valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_biu_req_dc3 X or Z")
  u_ovl_intf_x_dcu_biu_req_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_biu_req_dc3));


  // A committed store or CP15 in dc3 is ready to enter the STB. The BIU
  // uses this to update address information for linefill hazard checking.
  //  output dcu_stb_req_dc3 valid always timing 35%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_stb_req_dc3 X or Z")
  u_ovl_intf_x_dcu_stb_req_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_stb_req_dc3));


  // CC fail or flush during a load request to the BIU.
  assign flush_dc3             = dpu_kill_wr | (dpu_flush & ~dpu_ready_wr);
  assign cc_fail_or_flush_dc3  = flush_dc3 | dpu_ready_cc_fail_wr;

  // The address of the transaction in dc3.
  //  output [39:0] dcu_pa_dc3 valid dcu_load_dc3 timing 30%

  assert_never_unknown #(`OVL_FATAL, 40, OUTOPTIONS, "dcu_pa_dc3 X or Z")
  u_ovl_intf_x_dcu_pa_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc3),
    .test_expr (dcu_pa_dc3));


  // The BIU uses DCU's valid_dc3 internal signal to keep track of bursts correctly
  //  output dcu_pipe_valid_dc3 valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_pipe_valid_dc3 X or Z")
  u_ovl_intf_x_dcu_pipe_valid_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_pipe_valid_dc3));

  //  output dcu_valid_dc3 valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_valid_dc3 X or Z")
  u_ovl_intf_x_dcu_valid_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_valid_dc3));


  // The TrustZone non-secure state of the transaction in dc3.
  //  output dcu_ns_dsc_dc3 valid dcu_load_dc3 timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_ns_dsc_dc3 X or Z")
  u_ovl_intf_x_dcu_ns_dsc_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc3),
    .test_expr (dcu_ns_dsc_dc3));


  // The privileged state of the transaction in dc3. For cacheable requests
  // this must always be set, regardless of the actual state.
  //  output dcu_priv_dc3 valid dcu_load_dc3 timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_priv_dc3 X or Z")
  u_ovl_intf_x_dcu_priv_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc3),
    .test_expr (dcu_priv_dc3));


  // The memory type, inner and outer cacheability and shareability attributes of the load in dc3.
  // See cortexa53params for the encoding.
  //  output [7:0] dcu_attrs_dc3 valid dcu_load_dc3 timing 30%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "dcu_attrs_dc3 X or Z")
  u_ovl_intf_x_dcu_attrs_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc3),
    .test_expr (dcu_attrs_dc3));


  // The size of the transaction
  //  output [1:0] dcu_size_dc3 valid dcu_load_dc3 timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "dcu_size_dc3 X or Z")
  u_ovl_intf_x_dcu_size_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc3),
    .test_expr (dcu_size_dc3));


  // The number of transactions following in the burst. Zero if this is not a
  // burst, zero or one if this is the last transaction in a burst.
  //  output [3:0] dcu_length_dc3 valid dcu_load_dc3 timing 50%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "dcu_length_dc3 X or Z")
  u_ovl_intf_x_dcu_length_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc3),
    .test_expr (dcu_length_dc3));


  // The transaction is a load exclusive instruction.
  //  output dcu_exclusive_dc3 valid dcu_load_dc3 timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_exclusive_dc3 X or Z")
  u_ovl_intf_x_dcu_exclusive_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc3),
    .test_expr (dcu_exclusive_dc3));


  // The transaction is a PLDW. Any linefill request should ask for exclusive
  // access to the cache line.
  //  output dcu_pldw_dc3 valid dcu_load_dc3 timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_pldw_dc3 X or Z")
  u_ovl_intf_x_dcu_pldw_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc3),
    .test_expr (dcu_pldw_dc3));


  // A PLD L2 request to BIU.
  //  output dcu_pld_l2_req_dc3 valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_pld_l2_req_dc3 X or Z")
  u_ovl_intf_x_dcu_pld_l2_req_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_pld_l2_req_dc3));


  // A DSB or CP15 maintenance op is in dc3, or there is an outstanding DVM
  // Sync waiting on an LFB, and so the BIU should stop the data prefetcher.
  //  output dcu_stop_pf valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_stop_pf X or Z")
  u_ovl_intf_x_dcu_stop_pf (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_stop_pf));


  // A DVM sync is waiting on the STB draining, so STB linefills should be
  // prioritised over DCU ones.
  //  output dcu_drain_stb_lf valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_drain_stb_lf X or Z")
  u_ovl_intf_x_dcu_drain_stb_lf (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_drain_stb_lf));


  // Some attribute encodings are unused.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3  => ~`CA53_MEM_UNUSED(dcu_attrs_dc3)")
  u_ovl_intf_assert_a9f1f011e04c21e74d469036e2084d696948d38d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3 ),
    .consequent_expr (~`CA53_MEM_UNUSED(dcu_attrs_dc3)));




  // A Device load request must not be made while there are valid Device STB slots (excludes GRE)

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & (`CA53_MEM_nGnRnE(dcu_attrs_dc3) | `CA53_MEM_nGnRE(dcu_attrs_dc3) | `CA53_MEM_nGRE(dcu_attrs_dc3))  => ~(|stb_slots_dev_ng)")
  u_ovl_intf_assert_64ebf063ab94b07e48b4f0a65fcdda8e3fe25ce9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & (`CA53_MEM_nGnRnE(dcu_attrs_dc3) | `CA53_MEM_nGnRE(dcu_attrs_dc3) | `CA53_MEM_nGRE(dcu_attrs_dc3)) ),
    .consequent_expr (~(|stb_slots_dev_ng)));


  // The cache line and attributes of a store in DC3 must match those presented to the STB

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_cp15_dc3  => dcu_stb_attrs_dc3 == dcu_attrs_dc3")
  u_ovl_intf_assert_57d1737454ad97f01a966afa2e0885894bd0f42e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 ),
    .consequent_expr (dcu_stb_attrs_dc3 == dcu_attrs_dc3));


  // Exclusive addresses must be aligned with their access size.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & dcu_exclusive_dc3 & (dcu_size_dc3 == `CA53_SIZE_DWORD)  => dcu_pa_dc3[2:0] == 3'b000")
  u_ovl_intf_assert_2d35d0fc669c9c8b3fbaa6401b29490a6e758b7b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & dcu_exclusive_dc3 & (dcu_size_dc3 == `CA53_SIZE_DWORD) ),
    .consequent_expr (dcu_pa_dc3[2:0] == 3'b000));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & dcu_exclusive_dc3 & (dcu_size_dc3 == `CA53_SIZE_WORD)   => dcu_pa_dc3[1:0] == 2'b00")
  u_ovl_intf_assert_28757aea465e8fbc6f18d98c5fc466ee105550f5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & dcu_exclusive_dc3 & (dcu_size_dc3 == `CA53_SIZE_WORD)  ),
    .consequent_expr (dcu_pa_dc3[1:0] == 2'b00));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & dcu_exclusive_dc3 & (dcu_size_dc3 == `CA53_SIZE_HWORD)  => dcu_pa_dc3[0] == 1'b0")
  u_ovl_intf_assert_d4555cf4206af26e511d04169ac1d21d35415637 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & dcu_exclusive_dc3 & (dcu_size_dc3 == `CA53_SIZE_HWORD) ),
    .consequent_expr (dcu_pa_dc3[0] == 1'b0));


  // Compute DC3 last beat info
  assign dcu_load_last_beat_dc3  = ~|dcu_length_dc3[3:1] & (~dcu_length_dc3[0] | ~dcu_pa_dc3[2]);

  // Exclusives are only indicated on shareable memory.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_exclusive_dc2 & dcu_load_dc2     => `CA53_MEM_SHAREABLE(dcu_attrs_dc2)")
  u_ovl_intf_assert_39a986d100693d664b6ccf6666a8cde6c8871226 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_exclusive_dc2 & dcu_load_dc2    ),
    .consequent_expr (`CA53_MEM_SHAREABLE(dcu_attrs_dc2)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3 & dcu_exclusive_dc3  => `CA53_MEM_SHAREABLE(dcu_attrs_dc3)")
  u_ovl_intf_assert_cb29a32c3bac5f1a79876815127b69a758b780d8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3 & dcu_exclusive_dc3 ),
    .consequent_expr (`CA53_MEM_SHAREABLE(dcu_attrs_dc3)));


  // There must be a load in dc3 to generate a linefill request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_lf_req_dc3  => dcu_load_dc3")
  u_ovl_intf_assert_fb274f5ac4bb068e729edfb70cc61f9084142030 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_lf_req_dc3 ),
    .consequent_expr (dcu_load_dc3));


  // There must be a load in dc3 to generate a BIU request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3  => dcu_load_dc3")
  u_ovl_intf_assert_567eb1ab0fe9a2ca9f8e2f1eed1084bd90fa22b3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3 ),
    .consequent_expr (dcu_load_dc3));


  // There must be a load in dc3 to generate a BIU pld request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_pld_l2_req_dc3  => dcu_load_dc3")
  u_ovl_intf_assert_1c33bcc4302fddb6b1ba24cab61b110c35144434 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_pld_l2_req_dc3 ),
    .consequent_expr (dcu_load_dc3));


  // The victim way indicated for a linefill must not change while the linefill
  // is being requested

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_lf_req_dc1@1 & dcu_lf_req_dc1 & ~dcu_leaving_dc1@1  => dcu_lf_way_dc1 == dcu_lf_way_dc1@1")
  u_ovl_intf_assert_484dc4bb371d765c55ac3d26afddce6e591ff411 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_lf_req_dc1_reg & dcu_lf_req_dc1 & ~dcu_leaving_dc1_reg ),
    .consequent_expr (dcu_lf_way_dc1 == dcu_lf_way_dc1_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_lf_req_dc2@1 & dcu_lf_req_dc2 & ~dcu_leaving_dc2@1  => dcu_lf_way_dc2 == dcu_lf_way_dc2@1")
  u_ovl_intf_assert_cbc8ffd2f3654b5d11fe784ad859a97b7c173b1a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_lf_req_dc2_reg & dcu_lf_req_dc2 & ~dcu_leaving_dc2_reg ),
    .consequent_expr (dcu_lf_way_dc2 == dcu_lf_way_dc2_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_lf_req_dc3@1 & dcu_lf_req_dc3 & ~dcu_leaving_dc2@1  => dcu_lf_way_dc3 == dcu_lf_way_dc3@1")
  u_ovl_intf_assert_a3bc8da412a6a4ee4b80a2a7e536003dc4769a4f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_lf_req_dc3_reg & dcu_lf_req_dc3 & ~dcu_leaving_dc2_reg ),
    .consequent_expr (dcu_lf_way_dc3 == dcu_lf_way_dc3_reg));


  // When a load makes a linefill request in one pipe stage and then continues
  // to make the request in the next pipe stage, the way indicated must be
  // consistent.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_lf_req_dc1@1 & dcu_leaving_dc1@1 & dcu_lf_req_dc2  => dcu_lf_way_dc2 == dcu_lf_way_dc1@1")
  u_ovl_intf_assert_5d318aa4a4952f94b723c5cefe42d95f6308cbc0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_lf_req_dc1_reg & dcu_leaving_dc1_reg & dcu_lf_req_dc2 ),
    .consequent_expr (dcu_lf_way_dc2 == dcu_lf_way_dc1_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_lf_req_dc2@1 & dcu_leaving_dc2@1 & dcu_lf_req_dc3  => dcu_lf_way_dc3 == dcu_lf_way_dc2@1")
  u_ovl_intf_assert_892c1b7ef7016b0b9d572db18424b081b1ef2a2b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_lf_req_dc2_reg & dcu_leaving_dc2_reg & dcu_lf_req_dc3 ),
    .consequent_expr (dcu_lf_way_dc3 == dcu_lf_way_dc2_reg));


  // Can't make NC, L1 and L2 LF request at the same time

  assert_zero_one_hot #(`OVL_FATAL, 3, OUTOPTIONS, "{dcu_biu_req_dc2, dcu_lf_req_dc2, dcu_pld_l2_req_dc2}")
  u_ovl_intf_assert_b47ed32410e82d3cdfc1bd6a24574562c156e887 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ({dcu_biu_req_dc2, dcu_lf_req_dc2, dcu_pld_l2_req_dc2}));


  assert_zero_one_hot #(`OVL_FATAL, 3, OUTOPTIONS, "{dcu_biu_req_dc3, dcu_lf_req_dc3, dcu_pld_l2_req_dc3}")
  u_ovl_intf_assert_536b158f1ed792eadb090832ecc82f0b7cd224e2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ({dcu_biu_req_dc3, dcu_lf_req_dc3, dcu_pld_l2_req_dc3}));


  // A load in dc3 must have been pending and not leaving previous cycle or
  // dc2 load moving to dc3 previous cycle


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    previous_dcu_leaving_dc3 <= 1'b0;
  else
    previous_dcu_leaving_dc3 <= dcu_valid_dc3 & dpu_ready_wr;



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3  => (dcu_load_dc2@1 & dcu_leaving_dc2@1) | (dcu_load_dc3@1 & ~previous_dcu_leaving_dc3)")
  u_ovl_intf_assert_c65c33536668bcf48aafdb6518dc4d92653ee610 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 ),
    .consequent_expr ((dcu_load_dc2_reg & dcu_leaving_dc2_reg) | (dcu_load_dc3_reg & ~previous_dcu_leaving_dc3)));


  // A load arriving in dc3 must have left dc2.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dcu_load_dc3@1 & dcu_load_dc3  => dcu_load_dc2@1 & dcu_leaving_dc2@1")
  u_ovl_intf_assert_6490231b4aee0fb01e83e23e2083d0e1bfb5b1a0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dcu_load_dc3_reg & dcu_load_dc3 ),
    .consequent_expr (dcu_load_dc2_reg & dcu_leaving_dc2_reg));


  // A non-load leaving dc2 must reach dc3.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dcu_load_dc2@1 & dcu_leaving_dc2@1  => ~dcu_load_dc3")
  u_ovl_intf_assert_1612f1680f2f11e87801d9476315207fcc060136 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dcu_load_dc2_reg & dcu_leaving_dc2_reg ),
    .consequent_expr (~dcu_load_dc3));


  // There must be no transaction in DC3 next clk cycle, if the DC3 leaving and no DC2 leaving

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_valid_dc3@1 & dpu_ready_wr@1 & ~dcu_leaving_dc2@1  => ~dcu_load_dc3 & ~dcu_lf_req_dc3 & ~dcu_biu_req_dc3 & ~dcu_stb_req_dc3 & ~dcu_pld_l2_req_dc3")
  u_ovl_intf_assert_cb3c5dfe3cb18e056e82a449d8bfe3a348cee884 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc3_reg & dpu_ready_wr_reg & ~dcu_leaving_dc2_reg ),
    .consequent_expr (~dcu_load_dc3 & ~dcu_lf_req_dc3 & ~dcu_biu_req_dc3 & ~dcu_stb_req_dc3 & ~dcu_pld_l2_req_dc3));


  // Nothing can leave dc2 if dc3 is not ready to leave.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3  => ~dcu_leaving_dc2")
  u_ovl_intf_assert_9750fa52e58cd6a4f3057cb33aea9a2b84d1579e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3 ),
    .consequent_expr (~dcu_leaving_dc2));


  // A request should be held until the data is available.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3@1 & ~cc_fail_or_flush_dc3@1 & ~biu_read_data_valid_dc3@1  => dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3")
  u_ovl_intf_assert_7cca69bf24472cf75687bf78303f3c23755ee431 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3_reg & ~cc_fail_or_flush_dc3_reg & ~biu_read_data_valid_dc3_reg ),
    .consequent_expr (dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3));


  // A request should be removed once the data is available.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3@1 & biu_read_data_valid_dc3@1  => ~dcu_biu_req_dc3")
  u_ovl_intf_assert_70ae4e80eeb0a85acd02bfa1e4ceb1b7751a8c2e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3_reg & biu_read_data_valid_dc3_reg ),
    .consequent_expr (~dcu_biu_req_dc3));


  // Loads in dc2 and dc3 are flushed following a kill.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc2  => ~dpu_kill_wr@1")
  u_ovl_intf_assert_e80b1eaa20c58dbc81c4fb5db06f498a183300f0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc2 ),
    .consequent_expr (~dpu_kill_wr_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3  => ~dpu_kill_wr@1")
  u_ovl_intf_assert_0e6999128523b403d7a59d03f7e2dac89750bda0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 ),
    .consequent_expr (~dpu_kill_wr_reg));


  // All cacheable loads must be marked as privileged.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3 & `CA53_MEM_COHERENT(dcu_attrs_dc3)  => dcu_priv_dc3")
  u_ovl_intf_assert_0c613e60313081662b48225dd05162aca4b0ab83 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 & `CA53_MEM_COHERENT(dcu_attrs_dc3) ),
    .consequent_expr (dcu_priv_dc3));


  // A cacheable exclusive load cannot make a non-cacheable request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3 & dcu_exclusive_dc3 & `CA53_MEM_COHERENT(dcu_attrs_dc3)  => ~dcu_biu_req_dc3")
  u_ovl_intf_assert_4db94cb69f8d194348c9185e9dcc02dccc86ea60 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 & dcu_exclusive_dc3 & `CA53_MEM_COHERENT(dcu_attrs_dc3) ),
    .consequent_expr (~dcu_biu_req_dc3));


  // A load cannot be both a PLDW and a LDREX.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3 & dcu_pldw_dc3  => ~dcu_exclusive_dc3")
  u_ovl_intf_assert_4424d29efc8d8e2e6de4195c47a56fb9ce980454 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 & dcu_pldw_dc3 ),
    .consequent_expr (~dcu_exclusive_dc3));


  // A PLDW cannot make a non-cacheable request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3 & dcu_pldw_dc3  => ~dcu_biu_req_dc3")
  u_ovl_intf_assert_17317c614bdca50006920a326cd4e8a6d5cdfd4e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 & dcu_pldw_dc3 ),
    .consequent_expr (~dcu_biu_req_dc3));


  // A PLDW cannot be a multiple.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3 & dcu_pldw_dc3  => dcu_load_last_beat_dc3 == 1")
  u_ovl_intf_assert_10bb61979773983317227cd2ca6625aee0ffef27 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 & dcu_pldw_dc3 ),
    .consequent_expr (dcu_load_last_beat_dc3 == 1));


  // The address and attributes of a request must remain stable until the request has completed.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3@1 & ~cc_fail_or_flush_dc3@1 & ~biu_read_data_valid_dc3@1  => dcu_pa_dc3        == dcu_pa_dc3@1")
  u_ovl_intf_assert_239b62e7660c5245986e469e011cc8fdb0ee1be7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3_reg & ~cc_fail_or_flush_dc3_reg & ~biu_read_data_valid_dc3_reg ),
    .consequent_expr (dcu_pa_dc3        == dcu_pa_dc3_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3@1 & ~cc_fail_or_flush_dc3@1 & ~biu_read_data_valid_dc3@1  => dcu_ns_dsc_dc3    == dcu_ns_dsc_dc3@1")
  u_ovl_intf_assert_cb577a0b8dbe6ce95edfc916373007b33e0d8e56 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3_reg & ~cc_fail_or_flush_dc3_reg & ~biu_read_data_valid_dc3_reg ),
    .consequent_expr (dcu_ns_dsc_dc3    == dcu_ns_dsc_dc3_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3@1 & ~cc_fail_or_flush_dc3@1 & ~biu_read_data_valid_dc3@1  => dcu_priv_dc3      == dcu_priv_dc3@1")
  u_ovl_intf_assert_cecbc7cd59534fa00a4d88ed9dc762cf3548f4f2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3_reg & ~cc_fail_or_flush_dc3_reg & ~biu_read_data_valid_dc3_reg ),
    .consequent_expr (dcu_priv_dc3      == dcu_priv_dc3_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3@1 & ~cc_fail_or_flush_dc3@1 & ~biu_read_data_valid_dc3@1  => dcu_attrs_dc3     == dcu_attrs_dc3@1")
  u_ovl_intf_assert_6d2c3e9d0978fcaf4c1456808767e9fe694d1ada (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3_reg & ~cc_fail_or_flush_dc3_reg & ~biu_read_data_valid_dc3_reg ),
    .consequent_expr (dcu_attrs_dc3     == dcu_attrs_dc3_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3@1 & ~cc_fail_or_flush_dc3@1 & ~biu_read_data_valid_dc3@1  => dcu_size_dc3      == dcu_size_dc3@1")
  u_ovl_intf_assert_cc0bf3c99a0ee8dd0ced7a9b88ef207b74c2f656 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3_reg & ~cc_fail_or_flush_dc3_reg & ~biu_read_data_valid_dc3_reg ),
    .consequent_expr (dcu_size_dc3      == dcu_size_dc3_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3@1 & ~cc_fail_or_flush_dc3@1 & ~biu_read_data_valid_dc3@1  => dcu_length_dc3    == dcu_length_dc3@1")
  u_ovl_intf_assert_6dc7d8bdcf2c655c86c84cf9ec780463c837c33e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3_reg & ~cc_fail_or_flush_dc3_reg & ~biu_read_data_valid_dc3_reg ),
    .consequent_expr (dcu_length_dc3    == dcu_length_dc3_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3@1 & ~cc_fail_or_flush_dc3@1 & ~biu_read_data_valid_dc3@1  => dcu_exclusive_dc3 == dcu_exclusive_dc3@1")
  u_ovl_intf_assert_6cbf70d05bbb93d10f62d55d6c1956847c8a9205 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3_reg & ~cc_fail_or_flush_dc3_reg & ~biu_read_data_valid_dc3_reg ),
    .consequent_expr (dcu_exclusive_dc3 == dcu_exclusive_dc3_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3@1 & ~cc_fail_or_flush_dc3@1 & ~biu_read_data_valid_dc3@1  => dcu_pldw_dc3      == dcu_pldw_dc3@1")
  u_ovl_intf_assert_6146a80782b43a8429626cacf0b98ab587d4b501 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3_reg & ~cc_fail_or_flush_dc3_reg & ~biu_read_data_valid_dc3_reg ),
    .consequent_expr (dcu_pldw_dc3      == dcu_pldw_dc3_reg));


  // Anything with a length of 0 or 1 should have been marked as last when it was in dc2
  // (the last beat of an LSM can be for either one or two words).

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3 & ~cc_fail_or_flush_dc3 & dcu_load_dc2@1 & dcu_leaving_dc2@1 & ~cc_fail_or_flush_dc2@1  => dcu_load_last_beat_dc2@1 == dcu_load_last_beat_dc3")
  u_ovl_intf_assert_805d72d28d3e8a1b2f0b127fdd46f2154db6558f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 & ~cc_fail_or_flush_dc3 & dcu_load_dc2_reg & dcu_leaving_dc2_reg & ~cc_fail_or_flush_dc2_reg ),
    .consequent_expr (dcu_load_last_beat_dc2_reg == dcu_load_last_beat_dc3));


  // A multiple to Dev must be word or dword sized

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & ~dcu_load_last_beat_dc3 & ~`CA53_MEM_NORMAL(dcu_attrs_dc3) & ~dcu_neon_access_dc3  => dcu_size_dc3 in [`CA53_SIZE_WORD, `CA53_SIZE_DWORD]")
  u_ovl_intf_assert_8f225bea5a869ba1453d7efedf1ee10893537c8b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & ~dcu_load_last_beat_dc3 & ~`CA53_MEM_NORMAL(dcu_attrs_dc3) & ~dcu_neon_access_dc3 ),
    .consequent_expr (((dcu_size_dc3 == `CA53_SIZE_WORD) | (dcu_size_dc3 ==  `CA53_SIZE_DWORD))));


  // All multiples must be dword, word or halfword sized (the DPU will only issue word sized LSMs, but
  // halfwords to normal memory which are cross64 but don't cross a cache line boundary will be
  // converted into multiples, but still mark their size as halfword.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & ~dcu_load_last_beat_dc3 & ~`CA53_MEM_COHERENT(dcu_attrs_dc3)  => dcu_size_dc3 in [`CA53_SIZE_DWORD, `CA53_SIZE_WORD, `CA53_SIZE_HWORD]")
  u_ovl_intf_assert_9f3278d5b18baebbe298d46c95c43f2f8db8080b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & ~dcu_load_last_beat_dc3 & ~`CA53_MEM_COHERENT(dcu_attrs_dc3) ),
    .consequent_expr (((dcu_size_dc3 == `CA53_SIZE_DWORD) | (dcu_size_dc3 ==  `CA53_SIZE_WORD) | (dcu_size_dc3 ==  `CA53_SIZE_HWORD))));


  // A Dev load that is halfword sized must be aligned unless for NEON

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3 & ~dcu_neon_access_dc3 & ~cc_fail_or_flush_dc3 & ~`CA53_MEM_NORMAL(dcu_attrs_dc3) & (dcu_size_dc3 == `CA53_SIZE_HWORD)  => dcu_pa_dc3[0] == 1'b0")
  u_ovl_intf_assert_91ee8f441f4d78b3eab1822f3cd72f3c0eca5277 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3 & ~dcu_neon_access_dc3 & ~cc_fail_or_flush_dc3 & ~`CA53_MEM_NORMAL(dcu_attrs_dc3) & (dcu_size_dc3 == `CA53_SIZE_HWORD) ),
    .consequent_expr (dcu_pa_dc3[0] == 1'b0));


  // Multiples that are not due to crossing a 64-bit boundary are always aligned.
  assign cross64_dc3  = (dcu_length_dc3 != 0) & ({3'h0, dcu_pa_dc3[2:0]} + {(dcu_length_dc3+1), 2'b00}) > 4'b1000;

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & ~cross64_dc3 & (dcu_length_dc3 != 0) & (dcu_size_dc3 == `CA53_SIZE_DWORD)  => dcu_pa_dc3[2:0] == 3'b000")
  u_ovl_intf_assert_eedc54ed28b9b6e40cc4f7e380bf5c610bc530c1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & ~cross64_dc3 & (dcu_length_dc3 != 0) & (dcu_size_dc3 == `CA53_SIZE_DWORD) ),
    .consequent_expr (dcu_pa_dc3[2:0] == 3'b000));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & ~cross64_dc3 & (dcu_length_dc3 != 0) & (dcu_size_dc3 == `CA53_SIZE_WORD)   => dcu_pa_dc3[1:0] == 2'b00")
  u_ovl_intf_assert_520592893ee154c8de6b149690f8124191b867ce (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & ~cross64_dc3 & (dcu_length_dc3 != 0) & (dcu_size_dc3 == `CA53_SIZE_WORD)  ),
    .consequent_expr (dcu_pa_dc3[1:0] == 2'b00));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & ~cross64_dc3 & (dcu_length_dc3 != 0) & (dcu_size_dc3 == `CA53_SIZE_HWORD)  => dcu_pa_dc3[0] == 1'b0")
  u_ovl_intf_assert_6453cd6dc223868d90dcf7763dd01f3e0b37ff5a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 & ~cross64_dc3 & (dcu_length_dc3 != 0) & (dcu_size_dc3 == `CA53_SIZE_HWORD) ),
    .consequent_expr (dcu_pa_dc3[0] == 1'b0));


  // Detect an ongoing Dev/Normal NC DC3 burst. This includes bursts of length 1 where both words are
  // returned in the same beat.

  assign new_burst_dc3  = ~dcu_biu_req_dc3_reg & dcu_biu_req_dc3 & ~dcu_load_last_beat_dc3;

  assign next_ongoing_burst_dc3  = (ongoing_burst_dc3 | new_burst_dc3) & ~cc_fail_or_flush_dc3 & ~ongoing_burst_finishing_dc3;

  assign ongoing_burst_finishing_dc3  = ongoing_burst_dc3 & dcu_load_dc3 & dcu_load_last_beat_dc3;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    ongoing_burst_dc3 <= 1'b0;
  else
    ongoing_burst_dc3 <= next_ongoing_burst_dc3;


  assign dcu_pa_incr_dc2  = dcu_pa_dc2[39:0] - {previous_pa_dc2[39:2], 2'b00};


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    previous_pa_dc2 <= {40{1'b0}};
  else if (dcu_load_dc2 & dcu_leaving_dc2)
    previous_pa_dc2 <= dcu_pa_dc2;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    previous_attrs_dc2 <= {8{1'b0}};
  else if (dcu_load_dc2 & dcu_leaving_dc2)
    previous_attrs_dc2 <= dcu_attrs_dc2;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    previous_ns_dsc_dc2 <= 1'b0;
  else if (dcu_load_dc2 & dcu_leaving_dc2)
    previous_ns_dsc_dc2 <= dcu_ns_dsc_dc2;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    previous_exclusive_dc2 <= 1'b0;
  else if (dcu_load_dc2 & dcu_leaving_dc2)
    previous_exclusive_dc2 <= dcu_exclusive_dc2;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    previous_length_dc2 <= 4'b0000;
  else if (dcu_load_dc2 & dcu_leaving_dc2)
    previous_length_dc2 <= dcu_length_dc2;


  assign dcu_pa_incr_dc3  = dcu_pa_dc3[39:0] - {previous_pa_dc3[39:2], 2'b00};


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    previous_pa_dc3 <= {40{1'b0}};
  else if (dcu_load_dc3)
    previous_pa_dc3 <= dcu_pa_dc3;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    previous_attrs_dc3 <= {8{1'b0}};
  else if (dcu_load_dc3)
    previous_attrs_dc3 <= dcu_attrs_dc3;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    previous_length_dc3 <= 4'b0000;
  else if (dcu_load_dc3)
    previous_length_dc3 <= dcu_length_dc3;


  // Attributes must be the same for each beat in a burst.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc2@1 & dcu_leaving_dc2@1 & ongoing_burst_dc3 & dcu_load_dc3  => dcu_attrs_dc3 == previous_attrs_dc3")
  u_ovl_intf_assert_772f086601ea79e829c883f4340f47e3a554ffdf (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc2_reg & dcu_leaving_dc2_reg & ongoing_burst_dc3 & dcu_load_dc3 ),
    .consequent_expr (dcu_attrs_dc3 == previous_attrs_dc3));


  // Burst length must decrement by the number of words requested in each beat.
  // This will normally be two words, except for at the end of a burst (in which
  // case the decrement is irrelevant), or the first access if the address is
  // word aligned but not doubleword aligned.
  // - a x64 load dword will mark the length as 1 on both halves, which is
  // acceptable as the BIU just needs the length to indicate at least the number
  // of words accessed.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc2@1 & dcu_leaving_dc2@1 & ongoing_burst_dc3  => (dcu_length_dc3 >= previous_length_dc3 - (previous_pa_dc3[2] ? 1 : 2)) | (dcu_length_dc3 == 0)")
  u_ovl_intf_assert_87d9871e041ed80ae8746565f9984a091dd7f9bf (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc2_reg & dcu_leaving_dc2_reg & ongoing_burst_dc3 ),
    .consequent_expr ((dcu_length_dc3 >= previous_length_dc3 - (previous_pa_dc3[2] ? 1 : 2)) | (dcu_length_dc3 == 0)));


  // The address must increment by either one or two words, depending on how many are transferred

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc2@1 & dcu_leaving_dc2@1 & ongoing_burst_dc3  => dcu_pa_incr_dc3 == (previous_pa_dc3[2] ? 4 : 8)")
  u_ovl_intf_assert_c247c2e5aeac58cbe0214a71e62dda0b1e36cdb1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc2_reg & dcu_leaving_dc2_reg & ongoing_burst_dc3 ),
    .consequent_expr (dcu_pa_incr_dc3 == (previous_pa_dc3[2] ? 4 : 8)));


  // Address and attributes for a load in DC3 must not change unless another load moves in from DC2

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3 & dcu_load_dc3@1 & ~(dcu_load_dc2@1 & dcu_leaving_dc2@1)  => dcu_pa_dc3@1        == dcu_pa_dc3")
  u_ovl_intf_assert_56e888f4c976d3c4680e2393ec530434a4956c88 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 & dcu_load_dc3_reg & ~(dcu_load_dc2_reg & dcu_leaving_dc2_reg) ),
    .consequent_expr (dcu_pa_dc3_reg        == dcu_pa_dc3));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3 & dcu_load_dc3@1 & ~(dcu_load_dc2@1 & dcu_leaving_dc2@1)  => dcu_ns_dsc_dc3@1    == dcu_ns_dsc_dc3")
  u_ovl_intf_assert_a6734157aa439fed5eca89dbb78f1424590dac02 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 & dcu_load_dc3_reg & ~(dcu_load_dc2_reg & dcu_leaving_dc2_reg) ),
    .consequent_expr (dcu_ns_dsc_dc3_reg    == dcu_ns_dsc_dc3));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3 & dcu_load_dc3@1 & ~(dcu_load_dc2@1 & dcu_leaving_dc2@1)  => dcu_attrs_dc3@1     == dcu_attrs_dc3")
  u_ovl_intf_assert_d0ab02b477961f15bd8b86ab2e206327cfa4ec82 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 & dcu_load_dc3_reg & ~(dcu_load_dc2_reg & dcu_leaving_dc2_reg) ),
    .consequent_expr (dcu_attrs_dc3_reg     == dcu_attrs_dc3));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3 & dcu_load_dc3@1 & ~(dcu_load_dc2@1 & dcu_leaving_dc2@1)  => dcu_length_dc3@1    == dcu_length_dc3")
  u_ovl_intf_assert_f828386aa83ea5ad16b0ad0851016c070e05f654 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 & dcu_load_dc3_reg & ~(dcu_load_dc2_reg & dcu_leaving_dc2_reg) ),
    .consequent_expr (dcu_length_dc3_reg    == dcu_length_dc3));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3 & dcu_load_dc3@1 & ~(dcu_load_dc2@1 & dcu_leaving_dc2@1)  => dcu_exclusive_dc3@1 == dcu_exclusive_dc3")
  u_ovl_intf_assert_b1fdfa9ceb88de98e5fc6800dd779073708ec7df (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 & dcu_load_dc3_reg & ~(dcu_load_dc2_reg & dcu_leaving_dc2_reg) ),
    .consequent_expr (dcu_exclusive_dc3_reg == dcu_exclusive_dc3));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3 & dcu_load_dc3@1 & ~(dcu_load_dc2@1 & dcu_leaving_dc2@1)  => dcu_priv_dc3@1      == dcu_priv_dc3")
  u_ovl_intf_assert_adf19877195bc8142081aca832da97b9da691e8f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 & dcu_load_dc3_reg & ~(dcu_load_dc2_reg & dcu_leaving_dc2_reg) ),
    .consequent_expr (dcu_priv_dc3_reg      == dcu_priv_dc3));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3 & dcu_load_dc3@1 & ~(dcu_load_dc2@1 & dcu_leaving_dc2@1)  => dcu_size_dc3@1      == dcu_size_dc3")
  u_ovl_intf_assert_631ee08951b029178c43eaa62b29d07f0dc64f74 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 & dcu_load_dc3_reg & ~(dcu_load_dc2_reg & dcu_leaving_dc2_reg) ),
    .consequent_expr (dcu_size_dc3_reg      == dcu_size_dc3));


  // If there is a load in DC2 and DC3, the address and attributes in DC2 must
  // not change until either the valid load leaves DC2, DC3 becomes empty or
  // we get a cc_fail_or_flush_dc2
  assign load_dc2_could_change  = dcu_leaving_dc2_reg | ~dcu_load_dc2 | ~dcu_load_dc3 | cc_fail_or_flush_dc2_reg;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    load_dc2_held_while_stalled <= 1'b0;
  else
    load_dc2_held_while_stalled <= (dcu_load_dc2 & dcu_load_dc3 & ~dcu_leaving_dc2 & ~cc_fail_or_flush_dc2) | (load_dc2_held_while_stalled & ~load_dc2_could_change);



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "load_dc2_held_while_stalled & ~load_dc2_could_change  => dcu_pa_dc2@1 == dcu_pa_dc2")
  u_ovl_intf_assert_313ce4fe5ca620220563455aefc0892882423596 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (load_dc2_held_while_stalled & ~load_dc2_could_change ),
    .consequent_expr (dcu_pa_dc2_reg == dcu_pa_dc2));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "load_dc2_held_while_stalled & ~load_dc2_could_change  => dcu_ns_dsc_dc2@1 == dcu_ns_dsc_dc2")
  u_ovl_intf_assert_a881264a6ff471d02d974108ea51d2a0f3db44c5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (load_dc2_held_while_stalled & ~load_dc2_could_change ),
    .consequent_expr (dcu_ns_dsc_dc2_reg == dcu_ns_dsc_dc2));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "load_dc2_held_while_stalled & ~load_dc2_could_change  => dcu_attrs_dc2@1 == dcu_attrs_dc2")
  u_ovl_intf_assert_ce9650839310afb335b7a8d03ad294d4f0b35d66 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (load_dc2_held_while_stalled & ~load_dc2_could_change ),
    .consequent_expr (dcu_attrs_dc2_reg == dcu_attrs_dc2));


  // A load in DC3 must have the same address and attributes it had in DC2

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3  => dcu_pa_dc3[39:0]  == previous_pa_dc2")
  u_ovl_intf_assert_3207bd3a369c6bb250fd67913330b1e1597f7b8c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 ),
    .consequent_expr (dcu_pa_dc3[39:0]  == previous_pa_dc2));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3  => dcu_length_dc3    == previous_length_dc2")
  u_ovl_intf_assert_4711c0531c4bf349497d71c1e7b01564321101c6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 ),
    .consequent_expr (dcu_length_dc3    == previous_length_dc2));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3  => dcu_attrs_dc3     == previous_attrs_dc2")
  u_ovl_intf_assert_9a31807c2f39c0cfd3730c4f89f792d5704dcdc6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 ),
    .consequent_expr (dcu_attrs_dc3     == previous_attrs_dc2));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3  => dcu_ns_dsc_dc3    == previous_ns_dsc_dc2")
  u_ovl_intf_assert_e97ff45a44b83f88be7a7ae651ad80ecedcf6bbc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 ),
    .consequent_expr (dcu_ns_dsc_dc3    == previous_ns_dsc_dc2));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_load_dc3  => dcu_exclusive_dc3 == previous_exclusive_dc2")
  u_ovl_intf_assert_b89896deb5893740f7055750d2294b6c8c29a544 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc3 ),
    .consequent_expr (dcu_exclusive_dc3 == previous_exclusive_dc2));


  // An ongoing burst for which the last beat has not yet entered DC3 implies that a load in DC2 is part of the same burst
  // Notes:
  // o The address must increment by either one or two words, depending on how many are transferred
  // o Length can be inconsistent on x64 burst as for DC3

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ongoing_burst_dc3 & ~ongoing_burst_finishing_dc3 & dcu_load_dc2  => dcu_pa_incr_dc2   == (previous_pa_dc2[2] ? 4 : 8)")
  u_ovl_intf_assert_6752d33ca6acc1e6a8be7aedbddc37c2600271de (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ongoing_burst_dc3 & ~ongoing_burst_finishing_dc3 & dcu_load_dc2 ),
    .consequent_expr (dcu_pa_incr_dc2   == (previous_pa_dc2[2] ? 4 : 8)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ongoing_burst_dc3 & ~ongoing_burst_finishing_dc3 & dcu_load_dc2  => dcu_attrs_dc2     == previous_attrs_dc2")
  u_ovl_intf_assert_a3beb12655a1f45ec7bdf86befea6c15124e383d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ongoing_burst_dc3 & ~ongoing_burst_finishing_dc3 & dcu_load_dc2 ),
    .consequent_expr (dcu_attrs_dc2     == previous_attrs_dc2));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ongoing_burst_dc3 & ~ongoing_burst_finishing_dc3 & dcu_load_dc2  => dcu_ns_dsc_dc2    == previous_ns_dsc_dc2")
  u_ovl_intf_assert_20832385dc799c48d1c5409305db36c7e6febcc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ongoing_burst_dc3 & ~ongoing_burst_finishing_dc3 & dcu_load_dc2 ),
    .consequent_expr (dcu_ns_dsc_dc2    == previous_ns_dsc_dc2));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ongoing_burst_dc3 & ~ongoing_burst_finishing_dc3 & dcu_load_dc2  => dcu_exclusive_dc2 == previous_exclusive_dc2")
  u_ovl_intf_assert_353710ae2866d1380e7648bc51b2e0126116c2c6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ongoing_burst_dc3 & ~ongoing_burst_finishing_dc3 & dcu_load_dc2 ),
    .consequent_expr (dcu_exclusive_dc2 == previous_exclusive_dc2));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ongoing_burst_dc3 & dcu_load_dc3 & dcu_load_dc2 & (dcu_length_dc3[3:1] > 0)  => dcu_pa_incr_dc2   == (previous_pa_dc2[2] ? 4 : 8)")
  u_ovl_intf_assert_b0a7cf7125470cd48df47ad43fb34ed8f88319e3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ongoing_burst_dc3 & dcu_load_dc3 & dcu_load_dc2 & (dcu_length_dc3[3:1] > 0) ),
    .consequent_expr (dcu_pa_incr_dc2   == (previous_pa_dc2[2] ? 4 : 8)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ongoing_burst_dc3 & dcu_load_dc3 & dcu_load_dc2 & (dcu_length_dc3[3:1] > 0)  => dcu_attrs_dc2     == previous_attrs_dc2")
  u_ovl_intf_assert_cda546c878feb1bb730d5bc5d31024f298718e88 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ongoing_burst_dc3 & dcu_load_dc3 & dcu_load_dc2 & (dcu_length_dc3[3:1] > 0) ),
    .consequent_expr (dcu_attrs_dc2     == previous_attrs_dc2));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ongoing_burst_dc3 & dcu_load_dc3 & dcu_load_dc2 & (dcu_length_dc3[3:1] > 0)  => dcu_ns_dsc_dc2    == previous_ns_dsc_dc2")
  u_ovl_intf_assert_1b479c125b564eafe42decb8ab33d7d78012f00c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ongoing_burst_dc3 & dcu_load_dc3 & dcu_load_dc2 & (dcu_length_dc3[3:1] > 0) ),
    .consequent_expr (dcu_ns_dsc_dc2    == previous_ns_dsc_dc2));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ongoing_burst_dc3 & dcu_load_dc3 & dcu_load_dc2 & (dcu_length_dc3[3:1] > 0)  => dcu_exclusive_dc2 == previous_exclusive_dc2")
  u_ovl_intf_assert_99d19202ba632a80a0dd38bc00fc0820a848c09e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ongoing_burst_dc3 & dcu_load_dc3 & dcu_load_dc2 & (dcu_length_dc3[3:1] > 0) ),
    .consequent_expr (dcu_exclusive_dc2 == previous_exclusive_dc2));


  // A load in DC2 that is part of an ongoing burst must remain in DC2 until it reaches DC3

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ongoing_burst_dc3@1 & ~ongoing_burst_finishing_dc3@1 & dcu_load_dc2@1 & ~dcu_leaving_dc2@1 & ~cc_fail_or_flush_dc2@1  => dcu_load_dc2")
  u_ovl_intf_assert_0d1a8886332021fcf8f70c99543f1256ff546208 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ongoing_burst_dc3_reg & ~ongoing_burst_finishing_dc3_reg & dcu_load_dc2_reg & ~dcu_leaving_dc2_reg & ~cc_fail_or_flush_dc2_reg ),
    .consequent_expr (dcu_load_dc2));


  // Bursts never cross a 64 byte boundary

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc2 & ~cc_fail_or_flush_dc2  => (dcu_pa_dc2[5:0] + {dcu_length_dc2, 2'b00}) < 7'b1000000")
  u_ovl_intf_assert_a1f26fbbede57e6d03e16678258e30dca1c193d9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc2 & ~cc_fail_or_flush_dc2 ),
    .consequent_expr ((dcu_pa_dc2[5:0] + {dcu_length_dc2, 2'b00}) < 7'b1000000));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3  => (dcu_pa_dc3[5:0] + {dcu_length_dc3, 2'b00}) < 7'b1000000")
  u_ovl_intf_assert_67518c44d57bffb99406a80d9d8adeeefaf041a0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3 & ~cc_fail_or_flush_dc3 ),
    .consequent_expr ((dcu_pa_dc3[5:0] + {dcu_length_dc3, 2'b00}) < 7'b1000000));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dc3_part_of_ongoing_burst <= 1'b0;
  else
    dc3_part_of_ongoing_burst <= dcu_leaving_dc2 & next_ongoing_burst_dc3;


  // The DCU always get the requested data from DC3 unless is a flush or cc_fail

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_biu_req_dc3@1 & ~cc_fail_or_flush_dc3@1 & ~dc3_part_of_ongoing_burst@1 & ~biu_read_data_valid_dc3@1  => dcu_biu_req_dc3")
  u_ovl_intf_assert_6333cd3d29e0ea2de9bdf97a10e67b25737bf974 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_biu_req_dc3_reg & ~cc_fail_or_flush_dc3_reg & ~dc3_part_of_ongoing_burst_reg & ~biu_read_data_valid_dc3_reg ),
    .consequent_expr (dcu_biu_req_dc3));


  // A DC3 PLD L2 request should be to coherent memory

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_pld_l2_req_dc3  => `CA53_MEM_COHERENT(dcu_attrs_dc3)")
  u_ovl_intf_assert_9e3c70c722b43380a186abeff2c681b01e14796c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_pld_l2_req_dc3 ),
    .consequent_expr (`CA53_MEM_COHERENT(dcu_attrs_dc3)));


  // A DC3 PLD L2 request should be held until the BIU is ready to accept or dropped

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_pld_l2_req_dc3@1 & ~cc_fail_or_flush_dc3@1 & ~biu_read_data_valid_dc3@1 & ~biu_pld_l2_next_ready@2  => dcu_pld_l2_req_dc3")
  u_ovl_intf_assert_4f59a54ac04b14956d556d3144e78afa8f1fdc83 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_pld_l2_req_dc3_reg & ~cc_fail_or_flush_dc3_reg & ~biu_read_data_valid_dc3_reg & ~biu_pld_l2_next_ready_reg_reg ),
    .consequent_expr (dcu_pld_l2_req_dc3));


  // A DC3 PLD L2 request should be removed once the BIU is ready to accept or dropped

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_pld_l2_req_dc3@1 & ~cc_fail_or_flush_dc3@1 & biu_pld_l2_next_ready@2 & ~biu_read_data_valid_dc3@1 & ~dcu_leaving_dc2@1  => ~dcu_pld_l2_req_dc3")
  u_ovl_intf_assert_cc8684f99d747c5cacc43e1780127da48d600416 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_pld_l2_req_dc3_reg & ~cc_fail_or_flush_dc3_reg & biu_pld_l2_next_ready_reg_reg & ~biu_read_data_valid_dc3_reg & ~dcu_leaving_dc2_reg ),
    .consequent_expr (~dcu_pld_l2_req_dc3));


  //-----------------------------------------------------------------------------
  //
  // DC3 Read Data Channel
  //
  //-----------------------------------------------------------------------------

  // Data is available from the read buffer.
  //  input biu_read_data_valid_dc3 valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_read_data_valid_dc3 X or Z")
  u_ovl_intf_x_biu_read_data_valid_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_read_data_valid_dc3));


  // The data from the read buffers.
  // If dcu_leaving_dc2 is set, then this data matches the dc2 address,
  // otherwise it matches the dc3 address.
  //  input [63:0] biu_read_data_dc3 valid biu_read_data_valid_dc3 timing 75%

  assert_never_unknown #(`OVL_FATAL, 64, INOPTIONS, "biu_read_data_dc3 X or Z")
  u_ovl_intf_x_biu_read_data_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_read_data_valid_dc3),
    .test_expr (biu_read_data_dc3));


  // An external abort has been detected on a linefill or DCU read.
  // This refers to data leaving the AXI read registers.
  // it is asserted for a ldrex. Not sure how to implement that as a valid
  // mask, but as that signal might be going anyway, not too worried for now.
  //  input biu_read_abort_dc3 valid biu_read_data_valid_dc3 timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_read_abort_dc3 X or Z")
  u_ovl_intf_x_biu_read_abort_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_read_data_valid_dc3),
    .test_expr (biu_read_abort_dc3));


  // The type of abort:
  // 2'b00 SLVERR
  // 2'b01 DECERR
  // 2'b10 ECCERR
  // 2'b11 LDREXERR
  //  input [1:0] biu_read_fault_dc3 valid biu_read_abort_dc3 timing 60%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "biu_read_fault_dc3 X or Z")
  u_ovl_intf_x_biu_read_fault_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_read_abort_dc3),
    .test_expr (biu_read_fault_dc3));


  //-----------------------------------------------------------------------------
  //
  // ECC Correction State Machine
  //
  //-----------------------------------------------------------------------------

  // ECC Error Correction State machine Clean/Invalidate Request
  //  output dcu_ecc_cinv_req valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_ecc_cinv_req X or Z")
  u_ovl_intf_x_dcu_ecc_cinv_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_ecc_cinv_req));


  // BIU Clean/Invalidate acknowledge for the ECC Error Correction State machine
  //  input biu_ecc_cinv_ack valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_ecc_cinv_ack X or Z")
  u_ovl_intf_x_biu_ecc_cinv_ack (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_ecc_cinv_ack));


  // BIU Clean/Invalidate complete for the ECC Error Correction State machine
  //  input biu_ecc_cinv_complete valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_ecc_cinv_complete X or Z")
  u_ovl_intf_x_biu_ecc_cinv_complete (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_ecc_cinv_complete));


  // ECC Error Correction State machine gives the index of the line  with the ECC error
  //  output [7:0] dcu_ecc_cinv_index valid dcu_ecc_cinv_req timing 40%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "dcu_ecc_cinv_index X or Z")
  u_ovl_intf_x_dcu_ecc_cinv_index (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_ecc_cinv_req),
    .test_expr (dcu_ecc_cinv_index));


  // ECC Error Correction State machine gives the way of the line  with the ECC error
  //  output [1:0] dcu_ecc_cinv_way valid dcu_ecc_cinv_req timing 40%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "dcu_ecc_cinv_way X or Z")
  u_ovl_intf_x_dcu_ecc_cinv_way (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_ecc_cinv_req),
    .test_expr (dcu_ecc_cinv_way));


  //-----------------------------------------------------------------------------
  //
  // ECC Data Transfer
  //
  //-----------------------------------------------------------------------------

  // ECC Syndrome Information for repair of a single error of data
  //  output [55:0] dcu_ecc_syndrome_m3 valid dcu_snoop_valid_m2@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, 56, OUTOPTIONS, "dcu_ecc_syndrome_m3 X or Z")
  u_ovl_intf_x_dcu_ecc_syndrome_m3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_snoop_valid_m2_reg),
    .test_expr (dcu_ecc_syndrome_m3));


  // ECC Fatal Error from data RAM
  //  output dcu_ecc_fatal_m3 valid dcu_snoop_valid_m2@1 timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_ecc_fatal_m3 X or Z")
  u_ovl_intf_x_dcu_ecc_fatal_m3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_snoop_valid_m2_reg),
    .test_expr (dcu_ecc_fatal_m3));


  // ECC Error from Tag RAM
  //  output dcu_ecc_tag_err_m3 valid dcu_pf_tag_ack_m1@2 timing 55%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_ecc_tag_err_m3 X or Z")
  u_ovl_intf_x_dcu_ecc_tag_err_m3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_pf_tag_ack_m1_reg_reg),
    .test_expr (dcu_ecc_tag_err_m3));


  //-----------------------------------------------------------------------------
  //
  // Snoop Data Channel
  //
  //-----------------------------------------------------------------------------

  // The DCU may write a new snoop data in the following clock cycle
  //  output dcu_snoop_dw_active valid always timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_snoop_dw_active X or Z")
  u_ovl_intf_x_dcu_snoop_dw_active (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_snoop_dw_active));


  // The DCU is supplying new snoop data this cycle. This can be the data to be
  // repaired or clean/invalidated by the BIU.
  //  output dcu_snoop_valid_m2 valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_snoop_valid_m2 X or Z")
  u_ovl_intf_x_dcu_snoop_valid_m2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_snoop_valid_m2));


  // Snoop data from the cache arbiter
  //  output [255:0] dcu_snoop_data_m2 valid dcu_snoop_valid_m2 timing 60%

  assert_never_unknown #(`OVL_FATAL, 256, OUTOPTIONS, "dcu_snoop_data_m2 X or Z")
  u_ovl_intf_x_dcu_snoop_data_m2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_snoop_valid_m2),
    .test_expr (dcu_snoop_data_m2));


  // The chunk within the burst, i.e. bits [5:4] of the address.
  //  output [1:0] dcu_snoop_chunk_m2 valid dcu_snoop_valid_m2 timing 60%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "dcu_snoop_chunk_m2 X or Z")
  u_ovl_intf_x_dcu_snoop_chunk_m2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_snoop_valid_m2),
    .test_expr (dcu_snoop_chunk_m2));


  // The number of dwords to be rotated due to the corkscrew
  //  output [1:0] dcu_snoop_rotate_m2 valid dcu_snoop_valid_m2 timing 60%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "dcu_snoop_rotate_m2 X or Z")
  u_ovl_intf_x_dcu_snoop_rotate_m2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_snoop_valid_m2),
    .test_expr (dcu_snoop_rotate_m2));


  // The ID the data relates to.
  //  output [3:0] dcu_snoop_l2db_id_m2 valid dcu_snoop_valid_m2 timing 60%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "dcu_snoop_l2db_id_m2 X or Z")
  u_ovl_intf_x_dcu_snoop_l2db_id_m2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_snoop_valid_m2),
    .test_expr (dcu_snoop_l2db_id_m2));


  // Last of the two halflines
  //  output dcu_snoop_last_m2 valid dcu_snoop_valid_m2 timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_snoop_last_m2 X or Z")
  u_ovl_intf_x_dcu_snoop_last_m2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_snoop_valid_m2),
    .test_expr (dcu_snoop_last_m2));


  // The DCU snoop must have been previously active if a new snoop data is being written

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_snoop_valid_m2  => dcu_snoop_dw_active@1")
  u_ovl_intf_assert_a51ead709814409a98e5a47eaec6a5cce98d753a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_snoop_valid_m2 ),
    .consequent_expr (dcu_snoop_dw_active_reg));


  //-----------------------------------------------------------------------------
  //
  // Write Address Channel
  //
  //-----------------------------------------------------------------------------

  // Set for each LF when there is a linefill in progress. The DCU should not
  // start any CP15 cache access while this is non-zero.
  //  input [7:0] biu_lf_in_progress valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 8, INOPTIONS, "biu_lf_in_progress X or Z")
  u_ovl_intf_x_biu_lf_in_progress (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_lf_in_progress));


  // Set for each PF when there is a prefetch stream in progress.
  //  input [3:0] biu_pf_in_progress valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 4, INOPTIONS, "biu_pf_in_progress X or Z")
  u_ovl_intf_x_biu_pf_in_progress (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_pf_in_progress));


  // The DCU synchronously resets the linefill tracking registers by sampling the
  // lf inputs on the first cycle after reset, assuming they will be
  // empty.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    non_reset_seen <= 1'b0;
  else
    non_reset_seen <= 1'b1;



  assert_implication #(`OVL_FATAL, INOPTIONS, "~non_reset_seen  => ~|biu_lf_in_progress")
  u_ovl_intf_assume_cbbff2ce41de43a2d2d129076f8a933083d71706 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~non_reset_seen ),
    .consequent_expr (~|biu_lf_in_progress));


  //-----------------------------------------------------------------------------
  //
  // BIU to dcache arbiter for LF allocations
  //
  //-----------------------------------------------------------------------------

  // The data to be written to the data RAMs. This bus is also used to
  // propagate MBIST data.
  //  input [255:0] biu_alloc_data_m0 valid biu_alloc_data_req_m0 timing 50%

  assert_never_unknown #(`OVL_FATAL, 256, INOPTIONS, "biu_alloc_data_m0 X or Z")
  u_ovl_intf_x_biu_alloc_data_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_alloc_data_req_m0),
    .test_expr (biu_alloc_data_m0));


  // A linefill buffer wishes to write to the tag RAM.
  //  input biu_alloc_tag_req_m0 valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_alloc_tag_req_m0 X or Z")
  u_ovl_intf_x_biu_alloc_tag_req_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_alloc_tag_req_m0));


  // A linefill buffer wishes to write to the data RAM.
  //  input biu_alloc_data_req_m0 valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_alloc_data_req_m0 X or Z")
  u_ovl_intf_x_biu_alloc_data_req_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_alloc_data_req_m0));


  // A linefill buffer wishes to write a full halfline to the data RAM.
  //  input biu_alloc_halfline_m0 valid biu_alloc_data_req_m0 timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_alloc_halfline_m0 X or Z")
  u_ovl_intf_x_biu_alloc_halfline_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_alloc_data_req_m0),
    .test_expr (biu_alloc_halfline_m0));


  // A linefill buffer wishes to write to the dirty RAM.
  //  input biu_alloc_dirty_req_m0 valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_alloc_dirty_req_m0 X or Z")
  u_ovl_intf_x_biu_alloc_dirty_req_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_alloc_dirty_req_m0));


  // The address etc. for the linefill
  //  input [39:4]  biu_alloc_addr_m0       valid biu_alloc_data_req_m0 timing 60%

  assert_never_unknown #(`OVL_FATAL, 36, INOPTIONS, "biu_alloc_addr_m0 X or Z")
  u_ovl_intf_x_biu_alloc_addr_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_alloc_data_req_m0),
    .test_expr (biu_alloc_addr_m0));

  //  input         biu_alloc_ns_dsc_m0     valid biu_alloc_tag_req_m0  timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_alloc_ns_dsc_m0 X or Z")
  u_ovl_intf_x_biu_alloc_ns_dsc_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_alloc_tag_req_m0),
    .test_expr (biu_alloc_ns_dsc_m0));

  //  input [3:0]   biu_alloc_way_m0        valid biu_alloc_data_req_m0 timing 60%

  assert_never_unknown #(`OVL_FATAL, 4, INOPTIONS, "biu_alloc_way_m0 X or Z")
  u_ovl_intf_x_biu_alloc_way_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_alloc_data_req_m0),
    .test_expr (biu_alloc_way_m0));


  // The way should be one-hot when making a request

  assert_one_hot #(`OVL_FATAL, 4, INOPTIONS, "(biu_alloc_data_req_m0 | biu_alloc_tag_req_m0 | biu_alloc_dirty_req_m0) ? biu_alloc_way_m0 : 4'b0001")
  u_ovl_intf_assume_9e24fdc5f819b3af9b40fdbf1714d32b6c834935 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ((biu_alloc_data_req_m0 | biu_alloc_tag_req_m0 | biu_alloc_dirty_req_m0) ? biu_alloc_way_m0 : 4'b0001));


  // The partial MOESI state of the line being allocated to be written into
  // the tag RAM.
  // Encoding:
  // 00 Invalid (used if the line externally aborted).
  // 01 Shared
  // 10 Unique, not migratory
  // 11 Unique, migratory
  //  input [1:0] biu_alloc_tag_moesi_m0 valid (biu_alloc_tag_req_m0 | biu_alloc_dirty_req_m0) timing 60%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "biu_alloc_tag_moesi_m0 X or Z")
  u_ovl_intf_x_biu_alloc_tag_moesi_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier ((biu_alloc_tag_req_m0 | biu_alloc_dirty_req_m0)),
    .test_expr (biu_alloc_tag_moesi_m0));


  // The cache arbitration will give priority to the allocation this cycle
  // (i.e. no higher priority source has requested access).
  // If set and the BIU makes a request then the request will be accepted and
  // the BIU should deassert biu_alloc_*_req_m0 in the next cycle (unless
  // it wishes to make another request).
  //  output dcu_alloc_has_priority_m0 valid always timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_alloc_has_priority_m0 X or Z")
  u_ovl_intf_x_dcu_alloc_has_priority_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_alloc_has_priority_m0));


  // The alloc request is in m1 and has not been delayed due to a higher
  // priority request. The RAMs will be enabled this cycle.
  //  output dcu_alloc_ack_m1 valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_alloc_ack_m1 X or Z")
  u_ovl_intf_x_dcu_alloc_ack_m1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_alloc_ack_m1));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    alloc_tag_in_m1 <= 1'b0;
  else
    alloc_tag_in_m1 <= ((biu_alloc_tag_req_m0 & dcu_alloc_has_priority_m0) | (alloc_tag_in_m1 & ~dcu_alloc_ack_m1));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    alloc_data_in_m1 <= 1'b0;
  else
    alloc_data_in_m1 <= ((biu_alloc_data_req_m0 & dcu_alloc_has_priority_m0) | (alloc_data_in_m1 & ~dcu_alloc_ack_m1));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    alloc_dirty_in_m1 <= 1'b0;
  else
    alloc_dirty_in_m1 <= ((biu_alloc_dirty_req_m0 & dcu_alloc_has_priority_m0) | (alloc_dirty_in_m1 & ~dcu_alloc_ack_m1));


  // The partial MOESI state of the line being allocated to be written into
  // the dirty RAM.
  // Encoding:
  // - For a tag MOESIs of Shared, and Unique, not migratory:
  // [1] => 1'b0, [0] => Dirty
  // - For a tag MOESI of Unique migratory:
  // [1] => Locally Modified, [0] => Dirty
  //  input [1:0] biu_alloc_dirty_moesi_m1 valid alloc_dirty_in_m1 timing 20%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "biu_alloc_dirty_moesi_m1 X or Z")
  u_ovl_intf_x_biu_alloc_dirty_moesi_m1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (alloc_dirty_in_m1),
    .test_expr (biu_alloc_dirty_moesi_m1));


  // The age information to write to the dirty RAM.
  //  input biu_alloc_dirty_age_m1 valid alloc_dirty_in_m1 timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_alloc_dirty_age_m1 X or Z")
  u_ovl_intf_x_biu_alloc_dirty_age_m1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (alloc_dirty_in_m1),
    .test_expr (biu_alloc_dirty_age_m1));


  // The attributes to write to the dirty RAM.
  //  input [7:0] biu_alloc_attrs_m1 valid alloc_dirty_in_m1 timing 20%

  assert_never_unknown #(`OVL_FATAL, 8, INOPTIONS, "biu_alloc_attrs_m1 X or Z")
  u_ovl_intf_x_biu_alloc_attrs_m1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (alloc_dirty_in_m1),
    .test_expr (biu_alloc_attrs_m1));


  // A tag request is never accompanied by a dirty request.

  assert_zero_one_hot #(`OVL_FATAL, 2, INOPTIONS, "{biu_alloc_tag_req_m0, biu_alloc_dirty_req_m0}")
  u_ovl_intf_assume_4314cb071293305826d014dd6bd430f4a5badb72 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ({biu_alloc_tag_req_m0, biu_alloc_dirty_req_m0}));


  // The BIU will only make allocation requests when there is a linefill in
  // progress.

  assert_implication #(`OVL_FATAL, INOPTIONS, "biu_alloc_data_req_m0  => |biu_lf_in_progress")
  u_ovl_intf_assume_08fc1908c18cf19f7bac0b1432e5dfe436b4bd18 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_alloc_data_req_m0 ),
    .consequent_expr (|biu_lf_in_progress));


  // The DCU must not acknowledge if there was no request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_alloc_ack_m1  => alloc_data_in_m1 | alloc_tag_in_m1 | alloc_dirty_in_m1")
  u_ovl_intf_assert_1bd340bd789f8e420ccfa8a3f352562b18803c46 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_alloc_ack_m1 ),
    .consequent_expr (alloc_data_in_m1 | alloc_tag_in_m1 | alloc_dirty_in_m1));


  // If the request is stalled in dc1 then can change from clean to dirty, but not vice versa.

  assert_implication #(`OVL_FATAL, INOPTIONS, "alloc_dirty_in_m1@1 & ~dcu_alloc_ack_m1@1 & biu_alloc_dirty_moesi_m1[0]@1  => biu_alloc_dirty_moesi_m1[0]")
  u_ovl_intf_assume_6b03822754cd864d5d2780562d0555c1996147da (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (alloc_dirty_in_m1_reg & ~dcu_alloc_ack_m1_reg & biu_alloc_dirty_moesi_m1_reg[0] ),
    .consequent_expr (biu_alloc_dirty_moesi_m1[0]));


  // If the request is stalled in dc1 then the attrs must remain stable.

  assert_implication #(`OVL_FATAL, INOPTIONS, "alloc_dirty_in_m1@1 & ~dcu_alloc_ack_m1@1  => biu_alloc_attrs_m1 == biu_alloc_attrs_m1@1")
  u_ovl_intf_assume_fc75b9195962252facd6fb7fd4b439f78e709531 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (alloc_dirty_in_m1_reg & ~dcu_alloc_ack_m1_reg ),
    .consequent_expr (biu_alloc_attrs_m1 == biu_alloc_attrs_m1_reg));




  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    write_in_m1 <= 1'b0;
  else if (dcu_stb_data_ack_m1 | ~write_in_m1)
    write_in_m1 <= stb_cache_data_req_m0 & stb_cache_data_wr_m0 & dcu_stb_data_has_priority_m0;


  // The DCU must not give data priority to the STB and a linefill allocation in the same cycle.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_alloc_data_req_m0 & dcu_alloc_has_priority_m0  => ~dcu_stb_data_has_priority_m0")
  u_ovl_intf_assert_41db15351ae9ba28b3b922997ab251b90a193993 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_alloc_data_req_m0 & dcu_alloc_has_priority_m0 ),
    .consequent_expr (~dcu_stb_data_has_priority_m0));


  // The DCU must not give priority to the STB while a linefill allocation is stalled in M1.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "alloc_data_in_m1 & ~dcu_alloc_ack_m1  => ~dcu_stb_data_has_priority_m0")
  u_ovl_intf_assert_6c6e9dff874c1ee78764d5c66f33de3355f9076b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (alloc_data_in_m1 & ~dcu_alloc_ack_m1 ),
    .consequent_expr (~dcu_stb_data_has_priority_m0));


  // The DCU must not give priority to a linefill allocation while another linefill allocation is stalled in M1.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "alloc_data_in_m1 & ~dcu_alloc_ack_m1  => ~dcu_alloc_has_priority_m0")
  u_ovl_intf_assert_1d741b1eb5fbb934c45ccb99ccda3acafbfa65c5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (alloc_data_in_m1 & ~dcu_alloc_ack_m1 ),
    .consequent_expr (~dcu_alloc_has_priority_m0));


  // The DCU must not give priority to a data linefill allocation while a cachewrite is stalled in M1.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "write_in_m1 & ~dcu_stb_data_ack_m1  => ~(dcu_alloc_has_priority_m0 & biu_alloc_data_req_m0)")
  u_ovl_intf_assert_b2ffaa30e761f8f9d3e8e8968b0737e71ec1289a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (write_in_m1 & ~dcu_stb_data_ack_m1 ),
    .consequent_expr (~(dcu_alloc_has_priority_m0 & biu_alloc_data_req_m0)));


  // The DCU must not acknowledge the STB and a linefill allocation in the same cycle.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "alloc_data_in_m1 & dcu_alloc_ack_m1  => ~dcu_stb_data_ack_m1")
  u_ovl_intf_assert_73e530a1f406d993515941d56cc35200ed2c6b42 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (alloc_data_in_m1 & dcu_alloc_ack_m1 ),
    .consequent_expr (~dcu_stb_data_ack_m1));


  //-----------------------------------------------------------------------------
  //
  // BIU to dcache arbiter for prefetches
  //
  //-----------------------------------------------------------------------------

  // An prefetch wishes to lookup the tag RAMs.
  //  input biu_pf_tag_req_m0 valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_pf_tag_req_m0 X or Z")
  u_ovl_intf_x_biu_pf_tag_req_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_pf_tag_req_m0));


  // The address etc. for the prefetch
  //  input [39:6]  biu_pf_tag_addr_m0    valid biu_pf_tag_req_m0     timing 60%

  assert_never_unknown #(`OVL_FATAL, 34, INOPTIONS, "biu_pf_tag_addr_m0 X or Z")
  u_ovl_intf_x_biu_pf_tag_addr_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_pf_tag_req_m0),
    .test_expr (biu_pf_tag_addr_m0));

  //  input         biu_pf_tag_ns_dsc_m0  valid biu_pf_tag_req_m0     timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_pf_tag_ns_dsc_m0 X or Z")
  u_ovl_intf_x_biu_pf_tag_ns_dsc_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_pf_tag_req_m0),
    .test_expr (biu_pf_tag_ns_dsc_m0));


  // The cache arbitration will give priority to the prefetch this cycle
  // (i.e. no higher priority source has requested access).
  // If set and the BIU makes a request then the request will be accepted and
  // the BIU should deassert biu_pf_tag_req_m0 in the next cycle (unless
  // it wishes to make another request).
  //  output dcu_pf_tag_has_priority_m0 valid always timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_pf_tag_has_priority_m0 X or Z")
  u_ovl_intf_x_dcu_pf_tag_has_priority_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_pf_tag_has_priority_m0));


  // The prefetch tag request is in m1 and has not been delayed due to
  // a higher priority request. The RAMs will be enabled this cycle.
  //  output dcu_pf_tag_ack_m1 valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_pf_tag_ack_m1 X or Z")
  u_ovl_intf_x_dcu_pf_tag_ack_m1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_pf_tag_ack_m1));


  // The result of the prefetch tag lookup.
  //  output dcu_pf_tag_hit_m2 valid dcu_pf_tag_ack_m1@1 timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_pf_tag_hit_m2 X or Z")
  u_ovl_intf_x_dcu_pf_tag_hit_m2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_pf_tag_ack_m1_reg),
    .test_expr (dcu_pf_tag_hit_m2));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    pf_tag_in_m1 <= 1'b0;
  else
    pf_tag_in_m1 <= ((biu_pf_tag_req_m0 & dcu_pf_tag_has_priority_m0) | (pf_tag_in_m1 & ~dcu_pf_tag_ack_m1));


  // The DCU cannot accept a new request if the previous one is stalled.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "pf_tag_in_m1 & ~dcu_pf_tag_ack_m1  => ~(dcu_pf_tag_has_priority_m0 | (dcu_alloc_has_priority_m0 & biu_alloc_tag_req_m0))")
  u_ovl_intf_assert_0854ab40e74ac008dff82b0245838a82109587dc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pf_tag_in_m1 & ~dcu_pf_tag_ack_m1 ),
    .consequent_expr (~(dcu_pf_tag_has_priority_m0 | (dcu_alloc_has_priority_m0 & biu_alloc_tag_req_m0))));


  // The DCU must not acknowledge if there was no request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_pf_tag_ack_m1  => pf_tag_in_m1")
  u_ovl_intf_assert_04d10852203044220974b3a5549283cbb11f9bc4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_pf_tag_ack_m1 ),
    .consequent_expr (pf_tag_in_m1));


  //-----------------------------------------------------------------------------
  //
  // DCU CCB to BIU (for hazard checking)
  //
  //-----------------------------------------------------------------------------

  // A CCB request is taking place, and is not stalled.
  //  output dcu_ccb_req_active valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_ccb_req_active X or Z")
  u_ovl_intf_x_dcu_ccb_req_active (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_ccb_req_active));


  // The way that the CCB request is accessing.
  //  output [3:0] dcu_ccb_ways valid dcu_ccb_req_active timing 20%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "dcu_ccb_ways X or Z")
  u_ovl_intf_x_dcu_ccb_ways (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_ccb_req_active),
    .test_expr (dcu_ccb_ways));


  // The index that the CCB request is for.
  //  output [13:6] dcu_ccb_index valid dcu_ccb_req_active timing 20%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "dcu_ccb_index X or Z")
  u_ovl_intf_x_dcu_ccb_index (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_ccb_req_active),
    .test_expr (dcu_ccb_index));


  // The index/way matches a linefill that has all of its data, but has not been
  // fully allocated, and so the CCB should wait.
  //  input biu_ccb_lf_hazard valid dcu_ccb_req_active timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_ccb_lf_hazard X or Z")
  u_ovl_intf_x_biu_ccb_lf_hazard (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_ccb_req_active),
    .test_expr (biu_ccb_lf_hazard));


  //-----------------------------------------------------------------------------
  //
  // MBIST interface
  //
  //-----------------------------------------------------------------------------



  // MBIST data for Tag and Dirty RAMs
  //  output [63:0] dcu_mbist_out_data_mb6 valid  gov_mbist_req timing 40%

  assert_never_unknown #(`OVL_FATAL, 64, OUTOPTIONS, "dcu_mbist_out_data_mb6 X or Z")
  u_ovl_intf_x_dcu_mbist_out_data_mb6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbist_req),
    .test_expr (dcu_mbist_out_data_mb6));


  // MBIST data RAM checkbits for the specified bank
  //  output  [6:0] dcu_mbist_data_checkbits_mb6 valid gov_mbist_req timing 80%

  assert_never_unknown #(`OVL_FATAL, 7, OUTOPTIONS, "dcu_mbist_data_checkbits_mb6 X or Z")
  u_ovl_intf_x_dcu_mbist_data_checkbits_mb6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbist_req),
    .test_expr (dcu_mbist_data_checkbits_mb6));


  // MBIST array
  //  output  [8:0] dcu_mbist_array_mb3 valid gov_mbist_req timing 40%

  assert_never_unknown #(`OVL_FATAL, 9, OUTOPTIONS, "dcu_mbist_array_mb3 X or Z")
  u_ovl_intf_x_dcu_mbist_array_mb3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbist_req),
    .test_expr (dcu_mbist_array_mb3));


  //-----------------------------------------------------------------------------
  //
  // Misc
  //
  //-----------------------------------------------------------------------------

  // A write response has been received for a store exclusive.
  //  input biu_strex_bresp_valid valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_strex_bresp_valid X or Z")
  u_ovl_intf_x_biu_strex_bresp_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_strex_bresp_valid));


  // The response:
  // 00 OKAY (STREX failed)
  // 01 EXOKAY (STREX passed)
  // 10 SLVERR
  // 11 DECERR
  //  input [1:0] biu_strex_bresp valid biu_strex_bresp_valid timing 40%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "biu_strex_bresp X or Z")
  u_ovl_intf_x_biu_strex_bresp (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_strex_bresp_valid),
    .test_expr (biu_strex_bresp));


  // The BIU has a linefill in progress that has had some store data merged into
  // it from the STB. The DCU should not allow a DSB to retire while this is
  // set.
  // Note that this should not include lines that are returned from the SCU in
  // the modified state, unless they have since had store data from this CPU
  // merged into them.
  //  input biu_dirty_lf_in_progress valid always timing 25%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_dirty_lf_in_progress X or Z")
  u_ovl_intf_x_biu_dirty_lf_in_progress (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_dirty_lf_in_progress));



  // The TLB walk address matches an LF that has only half allocated into
  // the cache, and so the cache should be forced not to hit on a TLB request.
  //  input biu_suppress_tlb_hit valid dcu_cache_walk_ack_m1@1 timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_suppress_tlb_hit X or Z")
  u_ovl_intf_x_biu_suppress_tlb_hit (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_cache_walk_ack_m1_reg),
    .test_expr (biu_suppress_tlb_hit));


  // There must be a linefill in progress if there is a dirty linefill.

  assert_implication #(`OVL_FATAL, INOPTIONS, "biu_dirty_lf_in_progress  => |biu_lf_in_progress")
  u_ovl_intf_assume_bc61baf5a6a0f81bda44e41c8e65b12e72c1b5a6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_dirty_lf_in_progress ),
    .consequent_expr (|biu_lf_in_progress));


  // The BIU can only forward data from a read buffer to when
  // there is an LF in progress or DC2 NC normal request.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_load_dc2 & biu_read_data_valid_dc2  => |biu_lf_in_progress | dcu_biu_req_dc2")
  u_ovl_intf_assume_e548e5c2e0c00966fa97da13fe49f47de154d6cc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc2 & biu_read_data_valid_dc2 ),
    .consequent_expr (|biu_lf_in_progress | dcu_biu_req_dc2));


  // If a load hits an aborted LF entry then all the data for that doubleword
  // must be present.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_load_dc2 & biu_read_abort_dc2  => biu_read_data_valid_dc2")
  u_ovl_intf_assume_3cca10e13959b949ac0478fba065fc5de6eaf7a2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc2 & biu_read_abort_dc2 ),
    .consequent_expr (biu_read_data_valid_dc2));


  // The BIU should only ever forward data for normal memory.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_load_dc2 & biu_read_data_valid_dc2  => `CA53_MEM_NORMAL(dcu_attrs_dc2)")
  u_ovl_intf_assume_417e6ca8ecb8e2c9cfe2587224553d483b72a064 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_load_dc2 & biu_read_data_valid_dc2 ),
    .consequent_expr (`CA53_MEM_NORMAL(dcu_attrs_dc2)));





endmodule

`define CA53_UNDEFINE
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`include "ca53_dcu_biu_defs.v"
`undef CA53_UNDEFINE

`endif

