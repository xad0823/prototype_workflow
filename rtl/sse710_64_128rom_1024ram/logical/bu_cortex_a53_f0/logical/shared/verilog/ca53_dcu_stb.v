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

// This is the specification for the interface between the DCU and STB.
// Inputs and outputs are from the point of view of the DCU.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_dcu_stb_defs.v"
`include "cortexa53params.v"

module ca53_dcu_stb #(parameter CPU_CACHE_PROTECTION = 0, parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input   [4:0] stb_slots_valid_i,
  input   [4:0] stb_slots_emptying_i,
  input   [4:0] stb_slots_dev_ng_i,
  input   [4:0] stb_slots_dsb_i,
  input         stb_block_loads_dc1_i,
  input         stb_cacheable_strex_done_i,
  input         stb_strex_failed_i,
  input   [4:0] stb_can_merge_dc2_i,
  input   [4:0] stb_sameline_dc2_i,
  input   [4:0] stb_load_sameline_dc2_i,
  input         stb_attr_mismatch_dc2_i,
  input   [7:0] stb_hit_dc2_i,
  input  [63:0] stb_data_dc2_i,
  input         stb_force_non_mergeable_i,
  input         stb_cache_tag_req_m0_i,
  input         stb_cache_tag_wr_m0_i,
  input   [3:0] stb_cache_tag_way_m0_i,
  input  [39:6] stb_cache_tag_addr_m0_i,
  input         stb_cache_tag_ns_dsc_m0_i,
  input         stb_cache_data_req_m0_i,
  input         stb_cache_data_wr_m0_i,
  input  [13:4] stb_cache_data_addr_m0_i,
  input   [3:0] stb_cache_data_way_m0_i,
  input [127:0] stb_cache_write_data_m0_i,
  input  [15:0] stb_cache_data_bls_m0_i,
  input   [7:0] stb_cache_data_attrs_m0_i,
  input         stb_cache_data_migratory_m0_i,
  input         stb_block_ccb_i,
  input         stb_defer_ccb_i,
  input         dpu_kill_wr_i,
  input   [4:0] biu_ev_hazard_i,
  input   [4:0] stb_lf_merge_i,
  input   [4:0] biu_lf_can_merge_i,
  input         dcu_drain_entire_stb_i,
  input   [4:0] dcu_drain_slots_i,
  input         dcu_exclusive_monitor_i,
  input         dcu_store_dc1_i,
  input         dcu_valid_dc2_i,
  input         dcu_store_dc2_i,
  input  [39:3] dcu_pa_dc2_i,
  input         dcu_ns_dsc_dc2_i,
  input   [7:0] dcu_attrs_dc2_i,
  input         dcu_leaving_dc2_i,
  input         dcu_store_dc3_i,
  input         dcu_stb_req_dc3_i,
  input         dcu_stlr_dc3_i,
  input   [4:0] dcu_store_merge_dc3_i,
  input   [4:0] dcu_store_sameline_dc3_i,
  input   [4:0] dcu_load_sameline_dc3_i,
  input  [39:0] dcu_pa_dc3_i,
  input         dcu_ns_dsc_dc3_i,
  input         dcu_priv_dc3_i,
  input         dcu_stb_exclusive_dc3_i,
  input         dcu_store_cp15_dc3_i,
  input         dcu_dvm_sync_needed_dc3_i,
  input         dcu_store_dmb_dc3_i,
  input         dcu_store_dsb_dc3_i,
  input   [7:0] dcu_stb_attrs_dc3_i,
  input  [15:0] dcu_store_bls_dc3_i,
  input         dcu_store_last_dc3_i,
  input         dcu_force_non_mergeable_dc3_i,
  input         dcu_stb_tag_has_priority_m0_i,
  input         dcu_stb_tag_ack_m1_i,
  input   [3:0] dcu_stb_tag_hit_m2_i,
  input         dcu_stb_tag_shared_m2_i,
  input         dcu_stb_tag_migratory_m2_i,
  input   [3:0] dcu_stb_victim_way_m2_i,
  input         dcu_ecc_data_err_m3_i,
  input         dcu_ecc_tag_err_m2_i,
  input         dcu_ecc_in_progress_i,
  input         dcu_stb_data_has_priority_m0_i,
  input         dcu_stb_data_ack_m1_i,
  input [127:0] dcu_stb_read_data_m2_i,
  input         dcu_ccb_req_valid_i,
  input  [13:6] dcu_ccb_index_i,
  input   [3:0] dcu_ccb_ways_i);


  wire   [4:0] stb_slots_valid = stb_slots_valid_i;
  wire   [4:0] stb_slots_emptying = stb_slots_emptying_i;
  wire   [4:0] stb_slots_dev_ng = stb_slots_dev_ng_i;
  wire   [4:0] stb_slots_dsb = stb_slots_dsb_i;
  wire         stb_block_loads_dc1 = stb_block_loads_dc1_i;
  wire         stb_cacheable_strex_done = stb_cacheable_strex_done_i;
  wire         stb_strex_failed = stb_strex_failed_i;
  wire   [4:0] stb_can_merge_dc2 = stb_can_merge_dc2_i;
  wire   [4:0] stb_sameline_dc2 = stb_sameline_dc2_i;
  wire   [4:0] stb_load_sameline_dc2 = stb_load_sameline_dc2_i;
  wire         stb_attr_mismatch_dc2 = stb_attr_mismatch_dc2_i;
  wire   [7:0] stb_hit_dc2 = stb_hit_dc2_i;
  wire  [63:0] stb_data_dc2 = stb_data_dc2_i;
  wire         stb_force_non_mergeable = stb_force_non_mergeable_i;
  wire         stb_cache_tag_req_m0 = stb_cache_tag_req_m0_i;
  wire         stb_cache_tag_wr_m0 = stb_cache_tag_wr_m0_i;
  wire   [3:0] stb_cache_tag_way_m0 = stb_cache_tag_way_m0_i;
  wire  [39:6] stb_cache_tag_addr_m0 = stb_cache_tag_addr_m0_i;
  wire         stb_cache_tag_ns_dsc_m0 = stb_cache_tag_ns_dsc_m0_i;
  wire         stb_cache_data_req_m0 = stb_cache_data_req_m0_i;
  wire         stb_cache_data_wr_m0 = stb_cache_data_wr_m0_i;
  wire  [13:4] stb_cache_data_addr_m0 = stb_cache_data_addr_m0_i;
  wire   [3:0] stb_cache_data_way_m0 = stb_cache_data_way_m0_i;
  wire [127:0] stb_cache_write_data_m0 = stb_cache_write_data_m0_i;
  wire  [15:0] stb_cache_data_bls_m0 = stb_cache_data_bls_m0_i;
  wire   [7:0] stb_cache_data_attrs_m0 = stb_cache_data_attrs_m0_i;
  wire         stb_cache_data_migratory_m0 = stb_cache_data_migratory_m0_i;
  wire         stb_block_ccb = stb_block_ccb_i;
  wire         stb_defer_ccb = stb_defer_ccb_i;
  wire         dpu_kill_wr = dpu_kill_wr_i;
  wire   [4:0] biu_ev_hazard = biu_ev_hazard_i;
  wire   [4:0] stb_lf_merge = stb_lf_merge_i;
  wire   [4:0] biu_lf_can_merge = biu_lf_can_merge_i;
  wire         dcu_drain_entire_stb = dcu_drain_entire_stb_i;
  wire   [4:0] dcu_drain_slots = dcu_drain_slots_i;
  wire         dcu_exclusive_monitor = dcu_exclusive_monitor_i;
  wire         dcu_store_dc1 = dcu_store_dc1_i;
  wire         dcu_valid_dc2 = dcu_valid_dc2_i;
  wire         dcu_store_dc2 = dcu_store_dc2_i;
  wire  [39:3] dcu_pa_dc2 = dcu_pa_dc2_i;
  wire         dcu_ns_dsc_dc2 = dcu_ns_dsc_dc2_i;
  wire   [7:0] dcu_attrs_dc2 = dcu_attrs_dc2_i;
  wire         dcu_leaving_dc2 = dcu_leaving_dc2_i;
  wire         dcu_store_dc3 = dcu_store_dc3_i;
  wire         dcu_stb_req_dc3 = dcu_stb_req_dc3_i;
  wire         dcu_stlr_dc3 = dcu_stlr_dc3_i;
  wire   [4:0] dcu_store_merge_dc3 = dcu_store_merge_dc3_i;
  wire   [4:0] dcu_store_sameline_dc3 = dcu_store_sameline_dc3_i;
  wire   [4:0] dcu_load_sameline_dc3 = dcu_load_sameline_dc3_i;
  wire  [39:0] dcu_pa_dc3 = dcu_pa_dc3_i;
  wire         dcu_ns_dsc_dc3 = dcu_ns_dsc_dc3_i;
  wire         dcu_priv_dc3 = dcu_priv_dc3_i;
  wire         dcu_stb_exclusive_dc3 = dcu_stb_exclusive_dc3_i;
  wire         dcu_store_cp15_dc3 = dcu_store_cp15_dc3_i;
  wire         dcu_dvm_sync_needed_dc3 = dcu_dvm_sync_needed_dc3_i;
  wire         dcu_store_dmb_dc3 = dcu_store_dmb_dc3_i;
  wire         dcu_store_dsb_dc3 = dcu_store_dsb_dc3_i;
  wire   [7:0] dcu_stb_attrs_dc3 = dcu_stb_attrs_dc3_i;
  wire  [15:0] dcu_store_bls_dc3 = dcu_store_bls_dc3_i;
  wire         dcu_store_last_dc3 = dcu_store_last_dc3_i;
  wire         dcu_force_non_mergeable_dc3 = dcu_force_non_mergeable_dc3_i;
  wire         dcu_stb_tag_has_priority_m0 = dcu_stb_tag_has_priority_m0_i;
  wire         dcu_stb_tag_ack_m1 = dcu_stb_tag_ack_m1_i;
  wire   [3:0] dcu_stb_tag_hit_m2 = dcu_stb_tag_hit_m2_i;
  wire         dcu_stb_tag_shared_m2 = dcu_stb_tag_shared_m2_i;
  wire         dcu_stb_tag_migratory_m2 = dcu_stb_tag_migratory_m2_i;
  wire   [3:0] dcu_stb_victim_way_m2 = dcu_stb_victim_way_m2_i;
  wire         dcu_ecc_data_err_m3 = dcu_ecc_data_err_m3_i;
  wire         dcu_ecc_tag_err_m2 = dcu_ecc_tag_err_m2_i;
  wire         dcu_ecc_in_progress = dcu_ecc_in_progress_i;
  wire         dcu_stb_data_has_priority_m0 = dcu_stb_data_has_priority_m0_i;
  wire         dcu_stb_data_ack_m1 = dcu_stb_data_ack_m1_i;
  wire [127:0] dcu_stb_read_data_m2 = dcu_stb_read_data_m2_i;
  wire         dcu_ccb_req_valid = dcu_ccb_req_valid_i;
  wire  [13:6] dcu_ccb_index = dcu_ccb_index_i;
  wire   [3:0] dcu_ccb_ways = dcu_ccb_ways_i;

  wire         cp15_op_type_tlb_aa64;
  wire   [4:0] slot_filling_dc3;
  wire         mergeable_from_dc3;
  wire         cp15_op_type_bar;
  wire  [11:0] misc_attrs_dc3;
  wire   [4:0] cp_sameline_dc2;
  wire   [4:0] slots_store;
  wire   [4:0] slots_nonmergeable;
  wire   [4:0] real_store_sameline_dc3;
  wire   [7:0] cp15_op_type;
  wire         cp15_op_type_ic;
  wire         stb_has_store_slots;
  wire         waw_hazard_dc2;
  wire         cp15_op_type_bp;
  wire         dev_req_dc3;
  wire         dmb_dc3;
  wire   [4:0] can_sameline_dc3;
  wire [127:0] write_bls_m0;
  wire         broadcast_cp_op_not_by_addr;
  wire         stb_force_non_mergeable_dc2;
  wire         barrier_dc3;
  wire         store_causes_block_loads;
  wire   [4:0] next_slot_to_fill;
  wire   [4:0] can_merge_dc3;
  wire         waw_line_dc2;
  wire         ongoing_burst;
  wire         next_merge_slot_changed;
  wire   [4:0] real_sameqword_dc2;
  wire         waw_attr_mismatch_dc2;
  wire         store_accepted_dc3;
  wire         excl_req_dc3;
  wire  [31:0] bytes_transferred;
  wire   [4:0] cp_sameline_dc3;
  wire   [4:0] can_load_sameline_dc3;
  wire         dsb_dc3;
  wire         store_data_valid;
  wire         ongoing_burst_device;
  wire         mergeable_to_dc3;
  wire         unchanged_dc2;
  wire         cp15_op_type_tlb_aa32;
  wire   [4:0] real_sameline_dc2;
  wire         cp15_op_type_dc;
  wire         raw_line_dc2;

  reg   [4:0] force_lf_merge;
  reg         tag_write_in_m1;
  reg   [4:0] stb_load_sameline_dc3;
  reg         prev_ns_dc2;
  reg         ongoing_burst_mergeable;
  reg         slot2_cp15;
  reg [127:0] read_bls_m1;
  reg         ongoing_burst_device_gre;
  reg  [40:0] slot2_addr;
  reg   [4:0] raw_line_hazard_slot_dc3;
  reg         write_in_m1;
  reg         accepted_strex;
  reg   [7:0] slot2_attrs;
  reg         slot0_store;
  reg         previous_ns_from_dc2;
  reg         merge_slot_changed;
  reg         slot3_cp15;
  reg         slot0_valid_cp_addr;
  reg  [39:3] prev_pa_dc2;
  reg  [33:0] next_cacheline;
  reg   [4:0] waw_line_hazard_slot_dc3;
  reg  [39:3] previous_pa_from_dc2;
  reg   [7:0] slot0_attrs;
  reg   [4:0] stb_can_merge_dc3;
  reg         slot1_store;
  reg  [40:0] slot0_addr;
  reg   [4:0] stb_sameline_dc3;
  reg         attr_mismatch_dc3;
  reg         stb_force_non_mergeable_dc3;
  reg         non_mergeable_was_in_dc3;
  reg  [40:0] slot1_addr;
  reg   [7:0] slot1_attrs;
  reg         request_killed;
  reg         ongoing_cacheable_strex;
  reg  [39:0] next_pa;
  reg         slot2_valid_cp_addr;
  reg   [7:0] previous_attrs_from_dc2;
  reg   [7:0] slot4_attrs;
  reg         slot0_cp15;
  reg   [4:0] slots_were_nonmergeable;
  reg         prev_dc2_valid;
  reg   [4:0] slots_barriered;
  reg   [4:0] waw_hazard_slot_dc3;
  reg         out_of_reset;
  reg         slot4_valid_cp_addr;
  reg         slot3_valid_cp_addr;
  reg         slot3_store;
  reg         read_in_m1;
  reg [127:0] read_bls_m2;
  reg         slot1_valid_cp_addr;
  reg   [7:0] slot3_attrs;
  reg         non_reset_seen;
  reg  [40:0] slot4_addr;
  reg  [11:0] next_misc_attrs;
  reg         slot2_store;
  reg  [40:0] slot3_addr;
  reg         lookup_in_m1;
  reg         slot4_store;
  reg         ongoing_burst_device_ng;
  reg         slot4_cp15;
  reg         slot1_cp15;

  reg   [4:0] slot_filling_dc3_reg;
  reg         stb_force_non_mergeable_reg;
  reg   [7:0] dcu_stb_attrs_dc3_reg;
  reg  [39:3] dcu_pa_dc2_reg;
  reg   [7:0] dcu_attrs_dc2_reg;
  reg         dcu_store_dc3_reg;
  reg         stb_strex_failed_reg;
  reg         dcu_stb_req_dc3_reg;
  reg         dcu_store_dc2_reg;
  reg         dcu_force_non_mergeable_dc3_reg;
  reg         stb_has_store_slots_reg;
  reg         dpu_kill_wr_reg;
  reg         dcu_ns_dsc_dc2_reg;
  reg         dcu_stb_tag_ack_m1_reg;
  reg         dcu_stb_tag_ack_m1_reg_reg;
  reg   [4:0] dcu_store_merge_dc3_reg;
  reg         dcu_ecc_in_progress_reg;
  reg         dcu_ecc_in_progress_reg_reg;
  reg         dcu_ecc_tag_err_m2_reg;
  reg         out_of_reset_reg;
  reg   [4:0] stb_load_sameline_dc2_reg;
  reg         dcu_stb_data_ack_m1_reg;
  reg         dcu_stb_data_ack_m1_reg_reg;
  reg         dcu_store_cp15_dc3_reg;
  reg         dcu_stb_exclusive_dc3_reg;
  reg   [4:0] stb_slots_dev_ng_reg;
  reg         read_in_m1_reg;
  reg         read_in_m1_reg_reg;
  reg         barrier_dc3_reg;
  reg   [4:0] stb_slots_emptying_reg;
  reg         store_causes_block_loads_reg;
  reg         stb_cacheable_strex_done_reg;
  reg         store_accepted_dc3_reg;
  reg   [4:0] stb_slots_dsb_reg;
  reg         dsb_dc3_reg;
  reg         lookup_in_m1_reg;
  reg         lookup_in_m1_reg_reg;
  reg         dcu_leaving_dc2_reg;
  reg   [4:0] stb_slots_valid_reg;
  reg         dcu_valid_dc2_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    slot_filling_dc3_reg <= {5{1'b0}};
    stb_force_non_mergeable_reg <= 1'b0;
    dcu_stb_attrs_dc3_reg <= {8{1'b0}};
    dcu_pa_dc2_reg <= {37{1'b0}};
    dcu_attrs_dc2_reg <= {8{1'b0}};
    dcu_store_dc3_reg <= 1'b0;
    stb_strex_failed_reg <= 1'b0;
    dcu_stb_req_dc3_reg <= 1'b0;
    dcu_store_dc2_reg <= 1'b0;
    dcu_force_non_mergeable_dc3_reg <= 1'b0;
    stb_has_store_slots_reg <= 1'b0;
    dpu_kill_wr_reg <= 1'b0;
    dcu_ns_dsc_dc2_reg <= 1'b0;
    dcu_stb_tag_ack_m1_reg <= 1'b0;
    dcu_stb_tag_ack_m1_reg_reg <= 1'b0;
    dcu_store_merge_dc3_reg <= {5{1'b0}};
    dcu_ecc_in_progress_reg <= 1'b0;
    dcu_ecc_in_progress_reg_reg <= 1'b0;
    dcu_ecc_tag_err_m2_reg <= 1'b0;
    out_of_reset_reg <= 1'b0;
    stb_load_sameline_dc2_reg <= {5{1'b0}};
    dcu_stb_data_ack_m1_reg <= 1'b0;
    dcu_stb_data_ack_m1_reg_reg <= 1'b0;
    dcu_store_cp15_dc3_reg <= 1'b0;
    dcu_stb_exclusive_dc3_reg <= 1'b0;
    stb_slots_dev_ng_reg <= {5{1'b0}};
    read_in_m1_reg <= 1'b0;
    read_in_m1_reg_reg <= 1'b0;
    barrier_dc3_reg <= 1'b0;
    stb_slots_emptying_reg <= {5{1'b0}};
    store_causes_block_loads_reg <= 1'b0;
    stb_cacheable_strex_done_reg <= 1'b0;
    store_accepted_dc3_reg <= 1'b0;
    stb_slots_dsb_reg <= {5{1'b0}};
    dsb_dc3_reg <= 1'b0;
    lookup_in_m1_reg <= 1'b0;
    lookup_in_m1_reg_reg <= 1'b0;
    dcu_leaving_dc2_reg <= 1'b0;
    stb_slots_valid_reg <= {5{1'b0}};
    dcu_valid_dc2_reg <= 1'b0;
  end
  else
  begin
    stb_slots_valid_reg <= stb_slots_valid;
    stb_slots_emptying_reg <= stb_slots_emptying;
    stb_slots_dev_ng_reg <= stb_slots_dev_ng;
    stb_slots_dsb_reg <= stb_slots_dsb;
    stb_cacheable_strex_done_reg <= stb_cacheable_strex_done;
    stb_strex_failed_reg <= stb_strex_failed;
    stb_load_sameline_dc2_reg <= stb_load_sameline_dc2;
    stb_force_non_mergeable_reg <= stb_force_non_mergeable;
    dpu_kill_wr_reg <= dpu_kill_wr;
    dcu_valid_dc2_reg <= dcu_valid_dc2;
    dcu_store_dc2_reg <= dcu_store_dc2;
    dcu_pa_dc2_reg <= dcu_pa_dc2;
    dcu_ns_dsc_dc2_reg <= dcu_ns_dsc_dc2;
    dcu_attrs_dc2_reg <= dcu_attrs_dc2;
    dcu_leaving_dc2_reg <= dcu_leaving_dc2;
    dcu_store_dc3_reg <= dcu_store_dc3;
    dcu_stb_req_dc3_reg <= dcu_stb_req_dc3;
    dcu_store_merge_dc3_reg <= dcu_store_merge_dc3;
    dcu_stb_exclusive_dc3_reg <= dcu_stb_exclusive_dc3;
    dcu_store_cp15_dc3_reg <= dcu_store_cp15_dc3;
    dcu_stb_attrs_dc3_reg <= dcu_stb_attrs_dc3;
    dcu_force_non_mergeable_dc3_reg <= dcu_force_non_mergeable_dc3;
    dcu_stb_tag_ack_m1_reg <= dcu_stb_tag_ack_m1;
    dcu_stb_tag_ack_m1_reg_reg <= dcu_stb_tag_ack_m1_reg;
    dcu_ecc_tag_err_m2_reg <= dcu_ecc_tag_err_m2;
    dcu_ecc_in_progress_reg <= dcu_ecc_in_progress;
    dcu_ecc_in_progress_reg_reg <= dcu_ecc_in_progress_reg;
    dcu_stb_data_ack_m1_reg <= dcu_stb_data_ack_m1;
    dcu_stb_data_ack_m1_reg_reg <= dcu_stb_data_ack_m1_reg;
    slot_filling_dc3_reg <= slot_filling_dc3;
    stb_has_store_slots_reg <= stb_has_store_slots;
    out_of_reset_reg <= out_of_reset;
    read_in_m1_reg <= read_in_m1;
    read_in_m1_reg_reg <= read_in_m1_reg;
    barrier_dc3_reg <= barrier_dc3;
    store_causes_block_loads_reg <= store_causes_block_loads;
    store_accepted_dc3_reg <= store_accepted_dc3;
    dsb_dc3_reg <= dsb_dc3;
    lookup_in_m1_reg <= lookup_in_m1;
    lookup_in_m1_reg_reg <= lookup_in_m1_reg;
  end



  //----------------------------------------------------------------------------
  //
  // Signals not relating to a particular pipe stage
  //
  //----------------------------------------------------------------------------

  // The slots currently busy in the STB.
  //  input [4:0] stb_slots_valid valid always timing 17%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "stb_slots_valid X or Z")
  u_ovl_intf_x_stb_slots_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_slots_valid));


  // The slots that are currently valid but will be empty in the next cycle.
  //  input [4:0] stb_slots_emptying valid always timing 80%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "stb_slots_emptying X or Z")
  u_ovl_intf_x_stb_slots_emptying (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_slots_emptying));


  // The slots currently busy that contain stores to non-gathering device memory.
  //  input [4:0] stb_slots_dev_ng valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "stb_slots_dev_ng X or Z")
  u_ovl_intf_x_stb_slots_dev_ng (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_slots_dev_ng));


  // The slots currently busy that contain a DSB.
  //  input [4:0] stb_slots_dsb valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "stb_slots_dsb X or Z")
  u_ovl_intf_x_stb_slots_dsb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_slots_dsb));


  // The STB contains a DMB affecting loads, a store release (which must be
  // multi-copy atomic), a DC matinenance operation that is still in progress,
  // or a store that cannot make progress due to loads continually fetching a
  // line in a shared state which is then continually invalidated before the
  // store completes.
  //  input stb_block_loads_dc1 valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "stb_block_loads_dc1 X or Z")
  u_ovl_intf_x_stb_block_loads_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_block_loads_dc1));


  // The DCU is requesting that the STB starts to drain as fast as it can.
  // This may be because an instruction needs the STB to be empty (e.g. a
  // committed CP15), or it may be a speculative hint (e.g. a DSB or CP15
  // in dc1 or dc2, or a DMB).
  //  output dcu_drain_entire_stb valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_drain_entire_stb X or Z")
  u_ovl_intf_x_dcu_drain_entire_stb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_drain_entire_stb));


  // Drain the indicated slot(s).
  //  output [4:0] dcu_drain_slots valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "dcu_drain_slots X or Z")
  u_ovl_intf_x_dcu_drain_slots (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_drain_slots));


  // The current state of the exclusive monitor. The STB should abandon a
  // STREX if this goes low before the write has completed.
  //  output dcu_exclusive_monitor valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_exclusive_monitor X or Z")
  u_ovl_intf_x_dcu_exclusive_monitor (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_exclusive_monitor));


  // A STREX to cacheable memory has completed.
  //  input stb_cacheable_strex_done valid always timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "stb_cacheable_strex_done X or Z")
  u_ovl_intf_x_stb_cacheable_strex_done (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_cacheable_strex_done));


  // The STREX failed.
  //  input stb_strex_failed valid stb_cacheable_strex_done timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "stb_strex_failed X or Z")
  u_ovl_intf_x_stb_strex_failed (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_cacheable_strex_done),
    .test_expr (stb_strex_failed));


  // The slots must all be empty on the first cycle after reset, as the DCU samples them
  // at this point to initialise the DVM Complete tracking registers.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    non_reset_seen <= 1'b0;
  else
    non_reset_seen <= 1'b1;


  assert_implication #(`OVL_FATAL, INOPTIONS, "~non_reset_seen  => ~|stb_slots_valid")
  u_ovl_intf_assume_6699b94164684382ba3916ca7b4c23fa0d59666f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~non_reset_seen ),
    .consequent_expr (~|stb_slots_valid));


  // Only one new slot can become busy per cycle.

  assert_zero_one_hot #(`OVL_FATAL, 5, INOPTIONS, "(stb_slots_valid & ~stb_slots_valid@1)")
  u_ovl_intf_assume_1d65542f1ef30d69d253e8b47786186dffb5f386 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ((stb_slots_valid & ~stb_slots_valid_reg)));


  // The valid bits must go low the cycle after the DCU was told they are emptying.

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid@1[0] & stb_slots_emptying@1[0]  => ~stb_slots_valid[0]")
  u_ovl_intf_assume_d69280abc56023eb26077a4f0c56f81ee8ddaa7f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid_reg[0] & stb_slots_emptying_reg[0] ),
    .consequent_expr (~stb_slots_valid[0]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid@1[1] & stb_slots_emptying@1[1]  => ~stb_slots_valid[1]")
  u_ovl_intf_assume_2c14e799b94e2dc8fbd0e70106773ac99b6592e4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid_reg[1] & stb_slots_emptying_reg[1] ),
    .consequent_expr (~stb_slots_valid[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid@1[2] & stb_slots_emptying@1[2]  => ~stb_slots_valid[2]")
  u_ovl_intf_assume_b21044234284efc98f591111b9861b9440ddea27 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid_reg[2] & stb_slots_emptying_reg[2] ),
    .consequent_expr (~stb_slots_valid[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid@1[3] & stb_slots_emptying@1[3]  => ~stb_slots_valid[3]")
  u_ovl_intf_assume_6df63e2a9fdfe0dc75dfcfaca52b34cf49f7cafc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid_reg[3] & stb_slots_emptying_reg[3] ),
    .consequent_expr (~stb_slots_valid[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid@1[4] & stb_slots_emptying@1[4]  => ~stb_slots_valid[4]")
  u_ovl_intf_assume_cdc85e4fbb608fb2b68bed7b79c429204e077b3e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid_reg[4] & stb_slots_emptying_reg[4] ),
    .consequent_expr (~stb_slots_valid[4]));


  // The DCU must be told when the slot is going invalid.

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid@1[0] & ~stb_slots_valid[0]  => stb_slots_emptying@1[0]")
  u_ovl_intf_assume_33305a669ea072c099bcf6a4f6155c7d5b7da387 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid_reg[0] & ~stb_slots_valid[0] ),
    .consequent_expr (stb_slots_emptying_reg[0]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid@1[1] & ~stb_slots_valid[1]  => stb_slots_emptying@1[1]")
  u_ovl_intf_assume_2f093cc72df64b0e2d94bf250a19ff7d7a4a238b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid_reg[1] & ~stb_slots_valid[1] ),
    .consequent_expr (stb_slots_emptying_reg[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid@1[2] & ~stb_slots_valid[2]  => stb_slots_emptying@1[2]")
  u_ovl_intf_assume_8bb03951c59f2c44f04328dc3738e699bc8264a2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid_reg[2] & ~stb_slots_valid[2] ),
    .consequent_expr (stb_slots_emptying_reg[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid@1[3] & ~stb_slots_valid[3]  => stb_slots_emptying@1[3]")
  u_ovl_intf_assume_e72bbaf286faa889b49542cddcc5dcb91719095a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid_reg[3] & ~stb_slots_valid[3] ),
    .consequent_expr (stb_slots_emptying_reg[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid@1[4] & ~stb_slots_valid[4]  => stb_slots_emptying@1[4]")
  u_ovl_intf_assume_e340600b617a763fa461879262c9955004a07287 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid_reg[4] & ~stb_slots_valid[4] ),
    .consequent_expr (stb_slots_emptying_reg[4]));


  // A slot can't be emptying if it is already empty

  assert_implication #(`OVL_FATAL, INOPTIONS, "~stb_slots_valid[0]   => ~stb_slots_emptying[0]")
  u_ovl_intf_assume_46ad89278cff596f35bc85c4e75123204978e00a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~stb_slots_valid[0]  ),
    .consequent_expr (~stb_slots_emptying[0]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "~stb_slots_valid[1]   => ~stb_slots_emptying[1]")
  u_ovl_intf_assume_2ab1101c7642742621214b6662eed8e3888e2f5c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~stb_slots_valid[1]  ),
    .consequent_expr (~stb_slots_emptying[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "~stb_slots_valid[2]   => ~stb_slots_emptying[2]")
  u_ovl_intf_assume_e4b454f25437656b6ecadd6cddf47573ced75812 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~stb_slots_valid[2]  ),
    .consequent_expr (~stb_slots_emptying[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "~stb_slots_valid[3]   => ~stb_slots_emptying[3]")
  u_ovl_intf_assume_16054f22999f60f3f61724b923d17cc8e4bfdfcf (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~stb_slots_valid[3]  ),
    .consequent_expr (~stb_slots_emptying[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "~stb_slots_valid[4]   => ~stb_slots_emptying[4]")
  u_ovl_intf_assume_ceba69b2919a71d2adb1e6213cf2f1c8916d4397 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~stb_slots_valid[4]  ),
    .consequent_expr (~stb_slots_emptying[4]));


  // If the STB allocates to a new slot then it must pick the lowest free slot.

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[1] & ~stb_slots_valid@1[1]  => stb_slots_valid@1[0]")
  u_ovl_intf_assume_aaf01e227da6d129a3fe060271196541adece6cb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[1] & ~stb_slots_valid_reg[1] ),
    .consequent_expr (stb_slots_valid_reg[0]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[2] & ~stb_slots_valid@1[2]  => &stb_slots_valid@1[1:0]")
  u_ovl_intf_assume_de670bb336e4a89bf02dc149ace5732f93a27662 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[2] & ~stb_slots_valid_reg[2] ),
    .consequent_expr (&stb_slots_valid_reg[1:0]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[3] & ~stb_slots_valid@1[3]  => &stb_slots_valid@1[2:0]")
  u_ovl_intf_assume_7a79cfcd430d5e4eef3fb62c385d089acadf615e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[3] & ~stb_slots_valid_reg[3] ),
    .consequent_expr (&stb_slots_valid_reg[2:0]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[4] & ~stb_slots_valid@1[4]  => &stb_slots_valid@1[3:0]")
  u_ovl_intf_assume_4bf247673037a28d5963a4a69eef544dbd899e5c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[4] & ~stb_slots_valid_reg[4] ),
    .consequent_expr (&stb_slots_valid_reg[3:0]));


  // A slot cannot contain a non-gathering device store if it is not busy.

  assert_always #(`OVL_FATAL, INOPTIONS, "~|(stb_slots_dev_ng & ~stb_slots_valid)")
  u_ovl_intf_assume_e258ff5834d1faaea4d4af85d7208017addc5d80 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (~|(stb_slots_dev_ng & ~stb_slots_valid)));


  // A slot cannot change memory type while it is busy.

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[0] & stb_slots_valid@1[0]  => stb_slots_dev_ng[0] == stb_slots_dev_ng@1[0]")
  u_ovl_intf_assume_49364f98334ba5d1e83d3dbffc938c03acceb26a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[0] & stb_slots_valid_reg[0] ),
    .consequent_expr (stb_slots_dev_ng[0] == stb_slots_dev_ng_reg[0]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[1] & stb_slots_valid@1[1]  => stb_slots_dev_ng[1] == stb_slots_dev_ng@1[1]")
  u_ovl_intf_assume_a7611fc865b51d825971fca41f4b36c8be092a8b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[1] & stb_slots_valid_reg[1] ),
    .consequent_expr (stb_slots_dev_ng[1] == stb_slots_dev_ng_reg[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[2] & stb_slots_valid@1[2]  => stb_slots_dev_ng[2] == stb_slots_dev_ng@1[2]")
  u_ovl_intf_assume_bc744ab329fb3e7c48c7bf98f8c14254c46159a0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[2] & stb_slots_valid_reg[2] ),
    .consequent_expr (stb_slots_dev_ng[2] == stb_slots_dev_ng_reg[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[3] & stb_slots_valid@1[3]  => stb_slots_dev_ng[3] == stb_slots_dev_ng@1[3]")
  u_ovl_intf_assume_94f2b9b4fe19e2225326360a1a54af667e17e9c1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[3] & stb_slots_valid_reg[3] ),
    .consequent_expr (stb_slots_dev_ng[3] == stb_slots_dev_ng_reg[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[4] & stb_slots_valid@1[4]  => stb_slots_dev_ng[4] == stb_slots_dev_ng@1[4]")
  u_ovl_intf_assume_d1cace2aa0f046ebbe2dac1aa6d140f40aad95c3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[4] & stb_slots_valid_reg[4] ),
    .consequent_expr (stb_slots_dev_ng[4] == stb_slots_dev_ng_reg[4]));


  // A slot cannot contain a DSB if it is not busy.

  assert_always #(`OVL_FATAL, INOPTIONS, "~|(stb_slots_dsb & ~stb_slots_valid)")
  u_ovl_intf_assume_e701288243e0943567ef74a1696b1218583b6247 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (~|(stb_slots_dsb & ~stb_slots_valid)));


  // A slot cannot change whether it has a DSB or not if it is not busy.

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[0] & stb_slots_valid@1[0]  => stb_slots_dsb[0] == stb_slots_dsb@1[0]")
  u_ovl_intf_assume_1f7199f01230f8a1ec200747905879b1acfadd11 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[0] & stb_slots_valid_reg[0] ),
    .consequent_expr (stb_slots_dsb[0] == stb_slots_dsb_reg[0]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[1] & stb_slots_valid@1[1]  => stb_slots_dsb[1] == stb_slots_dsb@1[1]")
  u_ovl_intf_assume_8beb9656586d02a35ce3666b4919bc4fa6fe9fb3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[1] & stb_slots_valid_reg[1] ),
    .consequent_expr (stb_slots_dsb[1] == stb_slots_dsb_reg[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[2] & stb_slots_valid@1[2]  => stb_slots_dsb[2] == stb_slots_dsb@1[2]")
  u_ovl_intf_assume_bcd6ae4becdedbf286a52d9a3d94036838d38949 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[2] & stb_slots_valid_reg[2] ),
    .consequent_expr (stb_slots_dsb[2] == stb_slots_dsb_reg[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[3] & stb_slots_valid@1[3]  => stb_slots_dsb[3] == stb_slots_dsb@1[3]")
  u_ovl_intf_assume_2cc27c2ce4bd2370210d0261c7406eb4be3b08b0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[3] & stb_slots_valid_reg[3] ),
    .consequent_expr (stb_slots_dsb[3] == stb_slots_dsb_reg[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[4] & stb_slots_valid@1[4]  => stb_slots_dsb[4] == stb_slots_dsb@1[4]")
  u_ovl_intf_assume_57f41a30aa5f07a46317c6b199f1e8425de484d2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[4] & stb_slots_valid_reg[4] ),
    .consequent_expr (stb_slots_dsb[4] == stb_slots_dsb_reg[4]));


  // Track what a slot is being used for

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot0_store <= 1'b0;
  else if (dcu_stb_req_dc3 & ~stb_slots_valid[0])
    slot0_store <= ~dcu_store_cp15_dc3;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot1_store <= 1'b0;
  else if (dcu_stb_req_dc3 & ~stb_slots_valid[1] & stb_slots_valid[0])
    slot1_store <= ~dcu_store_cp15_dc3;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot2_store <= 1'b0;
  else if (dcu_stb_req_dc3 & ~stb_slots_valid[2] & (|stb_slots_valid[1:0]))
    slot2_store <= ~dcu_store_cp15_dc3;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot3_store <= 1'b0;
  else if (dcu_stb_req_dc3 & ~stb_slots_valid[3] & (|stb_slots_valid[2:0]))
    slot3_store <= ~dcu_store_cp15_dc3;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot4_store <= 1'b0;
  else if (dcu_stb_req_dc3 & ~stb_slots_valid[4] & (|stb_slots_valid[3:0]))
    slot4_store <= ~dcu_store_cp15_dc3;


  assign slots_store  = {slot4_store, slot3_store, slot2_store, slot1_store, slot0_store};


  //----------------------------------------------------------------------------
  //
  // DC1 interface
  //
  //----------------------------------------------------------------------------

  // There is a valid store or CP15 in DC1. The STB can use this to decide how
  // many slots to start to drain.
  //  output dcu_store_dc1 valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_store_dc1 X or Z")
  u_ovl_intf_x_dcu_store_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_store_dc1));



  //----------------------------------------------------------------------------
  //
  // DC2 interface for loads and stores
  //
  //----------------------------------------------------------------------------

  // The DCU sends information to the STB about the transaction in dc2.
  // The STB responds in the same cycle.


  // There is a valid transaction in dc2.
  //  output dcu_valid_dc2 valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_valid_dc2 X or Z")
  u_ovl_intf_x_dcu_valid_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_valid_dc2));


  // There is a valid store or CP15 in DC2. The STB can use this to decide how
  // many slots to start to drain.
  //  output dcu_store_dc2 valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_store_dc2 X or Z")
  u_ovl_intf_x_dcu_store_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_store_dc2));


  // The physical address of the transaction in dc2.
  //  output [39:3] dcu_pa_dc2 valid dcu_valid_dc2 timing 20%

  assert_never_unknown #(`OVL_FATAL, 37, OUTOPTIONS, "dcu_pa_dc2 X or Z")
  u_ovl_intf_x_dcu_pa_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_valid_dc2),
    .test_expr (dcu_pa_dc2));


  // The TrustZone non-secure bit of the transaction in dc2.
  //  output dcu_ns_dsc_dc2 valid dcu_valid_dc2 timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_ns_dsc_dc2 X or Z")
  u_ovl_intf_x_dcu_ns_dsc_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_valid_dc2),
    .test_expr (dcu_ns_dsc_dc2));


  // The memory type, inner and outer cacheability and shareability attributes of the store in dc2.
  // See cortexa53params for the encoding.
  //
  // The attributes may take on reserved values for instructions that
  // don't need a translation
  //  output [7:0] dcu_attrs_dc2 valid dcu_valid_dc2 timing 20%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "dcu_attrs_dc2 X or Z")
  u_ovl_intf_x_dcu_attrs_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_valid_dc2),
    .test_expr (dcu_attrs_dc2));


  // The transaction in dc2 is moving into dc3 next cycle (unless it got
  // ccfailed or flushed).
  //  output dcu_leaving_dc2 valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_leaving_dc2 X or Z")
  u_ovl_intf_x_dcu_leaving_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_leaving_dc2));




  // The STB indicates which slot (if any) the dc2 transaction may merge into
  // when it reaches dc3.
  //  input [4:0] stb_can_merge_dc2 valid dcu_valid_dc2 timing 80%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "stb_can_merge_dc2 X or Z")
  u_ovl_intf_x_stb_can_merge_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_valid_dc2),
    .test_expr (stb_can_merge_dc2));


  // The STB indicates which slots contain a transaction in the same cache
  // line (for cacheable memory) or the same 512 bit burst (for non-cacheable
  // memory) as the transaction in dc2.
  // If there was a DMB done between the transactions then they must not be
  // marked as being in the same line.
  //  input [4:0] stb_sameline_dc2 valid dcu_valid_dc2 timing 80%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "stb_sameline_dc2 X or Z")
  u_ovl_intf_x_stb_sameline_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_valid_dc2),
    .test_expr (stb_sameline_dc2));


  // The STB indicates which slots contain a transaction in the same cache
  // line (for cacheable memory) or the same 512 bit burst (for non-cacheable
  // memory) as the transaction in dc2.
  // This is set even if there was a DMB done between the transactions, and
  // should be used by the DCU to generate dcu_load_sameline_dc3.
  //  input [4:0] stb_load_sameline_dc2 valid dcu_valid_dc2 timing 80%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "stb_load_sameline_dc2 X or Z")
  u_ovl_intf_x_stb_load_sameline_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_valid_dc2),
    .test_expr (stb_load_sameline_dc2));


  // Indicates that one or more slots matched the address of the transaction
  // in dc2, but the attributes were different. If so, the DCU must mark the
  // store as non-mergeable when it reaches dc3.
  //  input stb_attr_mismatch_dc2 valid dcu_valid_dc2 timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "stb_attr_mismatch_dc2 X or Z")
  u_ovl_intf_x_stb_attr_mismatch_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_valid_dc2),
    .test_expr (stb_attr_mismatch_dc2));


  // Assuming the transaction in dc2 is a load, indicates which bytes of the
  // load hit in the STB.
  //  input [7:0] stb_hit_dc2 valid dcu_valid_dc2 timing 65%

  assert_never_unknown #(`OVL_FATAL, 8, INOPTIONS, "stb_hit_dc2 X or Z")
  u_ovl_intf_x_stb_hit_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_valid_dc2),
    .test_expr (stb_hit_dc2));


  // The data from the STB that is being requested by the load in dc2.
  //  input [63:0] stb_data_dc2 valid dcu_valid_dc2 timing 75%

  assert_never_unknown #(`OVL_FATAL, 64, INOPTIONS, "stb_data_dc2 X or Z")
  u_ovl_intf_x_stb_data_dc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_valid_dc2),
    .test_expr (stb_data_dc2));


  // There cannot be a store in dc2 if dc2 is empty.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_store_dc2  => dcu_valid_dc2")
  u_ovl_intf_assert_4978311b3f8acf6b7f3d3ed188063872c5b3897e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_store_dc2 ),
    .consequent_expr (dcu_valid_dc2));


  // A transaction must be present in dc2 before it can leave.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_leaving_dc2  => dcu_valid_dc2")
  u_ovl_intf_assert_c9cce871afa127a516350dfe51e8929eb574afcd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_leaving_dc2 ),
    .consequent_expr (dcu_valid_dc2));


  // It is not possible to merge into more than one slot

  assert_zero_one_hot #(`OVL_FATAL, 5, INOPTIONS, "{5{dcu_valid_dc2}} & stb_can_merge_dc2")
  u_ovl_intf_assume_3bb87a965e21c2bf61691932aceee6bffa1b6988 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ({5{dcu_valid_dc2}} & stb_can_merge_dc2));


  // A slot cannot be merged into if it is empty.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2  => ~|(stb_can_merge_dc2 & ~stb_slots_valid)")
  u_ovl_intf_assume_6fac1d006678d42ec46f7d0d4aea5139c00f119b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 ),
    .consequent_expr (~|(stb_can_merge_dc2 & ~stb_slots_valid)));


  // If we can merge into a slot then it must be in the same line.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2  => ~|(stb_can_merge_dc2 & ~stb_sameline_dc2)")
  u_ovl_intf_assume_a3658a9231f9e74f5582b8bb2cb8d82c81e2a3a9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 ),
    .consequent_expr (~|(stb_can_merge_dc2 & ~stb_sameline_dc2)));


  // A slot cannot be in the same line if it is empty.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2  => ~|(stb_sameline_dc2 & ~stb_slots_valid)")
  u_ovl_intf_assume_45a096ece4a67519a3e87ca14d6a40ede93ded4c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 ),
    .consequent_expr (~|(stb_sameline_dc2 & ~stb_slots_valid)));


  // If there is an attribute mismatch then none of the slots should be marked as in the sameline

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & stb_attr_mismatch_dc2  => ~|stb_sameline_dc2")
  u_ovl_intf_assume_b8bcbcb57917ec7312c5e88c58089284ef13bbeb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & stb_attr_mismatch_dc2 ),
    .consequent_expr (~|stb_sameline_dc2));


  // A slot cannot be in the same line if it is empty.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2  => ~|(stb_load_sameline_dc2 & ~stb_slots_valid)")
  u_ovl_intf_assume_9c8a61c2f1e706327f7517be27e51cb3a4c11ad5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 ),
    .consequent_expr (~|(stb_load_sameline_dc2 & ~stb_slots_valid)));


  assign unchanged_dc2  = ({dcu_ns_dsc_dc2, dcu_pa_dc2[39:6]} == {dcu_ns_dsc_dc2_reg, dcu_pa_dc2_reg[39:6]}) & dcu_valid_dc2 & dcu_valid_dc2_reg;

  // The access in dc2 must not change while it remains in dc2.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_valid_dc2@1 & ~dcu_leaving_dc2@1 & dcu_valid_dc2  => {dcu_ns_dsc_dc2, dcu_pa_dc2} == {dcu_ns_dsc_dc2@1, dcu_pa_dc2@1}")
  u_ovl_intf_assert_92b72682a60b6f05bc99635229136dd1edbcc1f6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2_reg & ~dcu_leaving_dc2_reg & dcu_valid_dc2 ),
    .consequent_expr ({dcu_ns_dsc_dc2, dcu_pa_dc2} == {dcu_ns_dsc_dc2_reg, dcu_pa_dc2_reg}));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_valid_dc2@1 & ~dcu_leaving_dc2@1 & dcu_valid_dc2  => dcu_attrs_dc2 == dcu_attrs_dc2@1")
  u_ovl_intf_assert_60a8ec44157c1529ee9271dd0aaf44c4e3ac4c55 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2_reg & ~dcu_leaving_dc2_reg & dcu_valid_dc2 ),
    .consequent_expr (dcu_attrs_dc2 == dcu_attrs_dc2_reg));


  // load_sameline cannot change while the address in DC2 and slot validity are unchanged

  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] == stb_slots_valid@1[0]) & unchanged_dc2  => stb_load_sameline_dc2[0] == stb_load_sameline_dc2@1[0]")
  u_ovl_intf_assume_6edafd6b50709c0eb7ffe51fd90edd063804ff1e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] == stb_slots_valid_reg[0]) & unchanged_dc2 ),
    .consequent_expr (stb_load_sameline_dc2[0] == stb_load_sameline_dc2_reg[0]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] == stb_slots_valid@1[1]) & unchanged_dc2  => stb_load_sameline_dc2[1] == stb_load_sameline_dc2@1[1]")
  u_ovl_intf_assume_79d18f58a2f6b00524c6a6bfcda569c036ddca0a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] == stb_slots_valid_reg[1]) & unchanged_dc2 ),
    .consequent_expr (stb_load_sameline_dc2[1] == stb_load_sameline_dc2_reg[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[2] == stb_slots_valid@1[2]) & unchanged_dc2  => stb_load_sameline_dc2[2] == stb_load_sameline_dc2@1[2]")
  u_ovl_intf_assume_399d5df81c192e73ac81261906eb2c8db6cff21d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[2] == stb_slots_valid_reg[2]) & unchanged_dc2 ),
    .consequent_expr (stb_load_sameline_dc2[2] == stb_load_sameline_dc2_reg[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[3] == stb_slots_valid@1[3]) & unchanged_dc2  => stb_load_sameline_dc2[3] == stb_load_sameline_dc2@1[3]")
  u_ovl_intf_assume_5707340226fe3bd80b38c877b347dd9e90ff9c0a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[3] == stb_slots_valid_reg[3]) & unchanged_dc2 ),
    .consequent_expr (stb_load_sameline_dc2[3] == stb_load_sameline_dc2_reg[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[4] == stb_slots_valid@1[4]) & unchanged_dc2  => stb_load_sameline_dc2[4] == stb_load_sameline_dc2@1[4]")
  u_ovl_intf_assume_42516ed34e51e7723706ebdda587d6cf32bb48c4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[4] == stb_slots_valid_reg[4]) & unchanged_dc2 ),
    .consequent_expr (stb_load_sameline_dc2[4] == stb_load_sameline_dc2_reg[4]));


  // A slot cannot hit if it is empty.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & ~|stb_slots_valid  => ~|stb_hit_dc2")
  u_ovl_intf_assume_3bc7f74a67afa368d27301bdac18b643aee611f5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & ~|stb_slots_valid ),
    .consequent_expr (~|stb_hit_dc2));


  // The STB data must be zero for bytes that didn't hit

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & ~stb_hit_dc2[0]  => stb_data_dc2[7:0]   == 8'b00000000")
  u_ovl_intf_assume_a536334b2504a26cc6f81194ddea201c28dc8616 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & ~stb_hit_dc2[0] ),
    .consequent_expr (stb_data_dc2[7:0]   == 8'b00000000));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & ~stb_hit_dc2[1]  => stb_data_dc2[15:8]  == 8'b00000000")
  u_ovl_intf_assume_9a4b9596f511043a0e906049fee3a778321febfe (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & ~stb_hit_dc2[1] ),
    .consequent_expr (stb_data_dc2[15:8]  == 8'b00000000));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & ~stb_hit_dc2[2]  => stb_data_dc2[23:16] == 8'b00000000")
  u_ovl_intf_assume_e819dd853ef568752563fc42ba669edfbc1dde89 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & ~stb_hit_dc2[2] ),
    .consequent_expr (stb_data_dc2[23:16] == 8'b00000000));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & ~stb_hit_dc2[3]  => stb_data_dc2[31:24] == 8'b00000000")
  u_ovl_intf_assume_52fd9a03b19a772533146e486b833bd51bbc9a4a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & ~stb_hit_dc2[3] ),
    .consequent_expr (stb_data_dc2[31:24] == 8'b00000000));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & ~stb_hit_dc2[4]  => stb_data_dc2[39:32] == 8'b00000000")
  u_ovl_intf_assume_f026ca89d890342b78862b6f3dc8e5fd851f4832 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & ~stb_hit_dc2[4] ),
    .consequent_expr (stb_data_dc2[39:32] == 8'b00000000));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & ~stb_hit_dc2[5]  => stb_data_dc2[47:40] == 8'b00000000")
  u_ovl_intf_assume_44319920cfe2bc91e0a76e2c169f484a2678b08f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & ~stb_hit_dc2[5] ),
    .consequent_expr (stb_data_dc2[47:40] == 8'b00000000));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & ~stb_hit_dc2[6]  => stb_data_dc2[55:48] == 8'b00000000")
  u_ovl_intf_assume_42fd96a50b1e8a83c58343856e518e4c72883c81 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & ~stb_hit_dc2[6] ),
    .consequent_expr (stb_data_dc2[55:48] == 8'b00000000));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & ~stb_hit_dc2[7]  => stb_data_dc2[63:56] == 8'b00000000")
  u_ovl_intf_assume_be3851fde7fd233cfd5de0a54a18f45fd681314d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & ~stb_hit_dc2[7] ),
    .consequent_expr (stb_data_dc2[63:56] == 8'b00000000));


  // If no CP15 hazard is indicated to an address, and a new CP15 is not put into the STB,
  // then a subsequent access to the same line cannot see a CP15 hazard.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    prev_pa_dc2 <= {37{1'b0}};
  else if (dcu_leaving_dc2)
    prev_pa_dc2 <= dcu_pa_dc2;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    prev_ns_dc2 <= 1'b0;
  else if (dcu_leaving_dc2)
    prev_ns_dc2 <= dcu_ns_dsc_dc2;



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    prev_dc2_valid <= 1'b0;
  else if (dcu_leaving_dc2 | dcu_stb_req_dc3)
    prev_dc2_valid <= (dcu_leaving_dc2 | prev_dc2_valid) & ~(dcu_stb_req_dc3 & dcu_store_cp15_dc3 & ~(dcu_store_dmb_dc3 | dcu_store_dsb_dc3));


  // A CP15 hazard cannot be indicated on a slot which does not contain a CP15.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot0_cp15 <= 1'b0;
  else if (dcu_stb_req_dc3 & ~stb_slots_valid[0])
    slot0_cp15 <= dcu_store_cp15_dc3 & ~dcu_store_dmb_dc3 & ~dcu_store_dsb_dc3;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot1_cp15 <= 1'b0;
  else if (dcu_stb_req_dc3 & ~stb_slots_valid[1] & stb_slots_valid[0])
    slot1_cp15 <= dcu_store_cp15_dc3 & ~dcu_store_dmb_dc3 & ~dcu_store_dsb_dc3;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot2_cp15 <= 1'b0;
  else if (dcu_stb_req_dc3 & ~stb_slots_valid[2] & |stb_slots_valid[1:0])
    slot2_cp15 <= dcu_store_cp15_dc3 & ~dcu_store_dmb_dc3 & ~dcu_store_dsb_dc3;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot3_cp15 <= 1'b0;
  else if (dcu_stb_req_dc3 & ~stb_slots_valid[3] & |stb_slots_valid[2:0])
    slot3_cp15 <= dcu_store_cp15_dc3 & ~dcu_store_dmb_dc3 & ~dcu_store_dsb_dc3;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot4_cp15 <= 1'b0;
  else if (dcu_stb_req_dc3 & ~stb_slots_valid[4] & |stb_slots_valid[3:0])
    slot4_cp15 <= dcu_store_cp15_dc3 & ~dcu_store_dmb_dc3 & ~dcu_store_dsb_dc3;



  //----------------------------------------------------------------------------
  //
  // DC3 interface for stores
  //
  //----------------------------------------------------------------------------

  // There is a valid store or CP15 in DC3 (but it may not have been committed
  // yet). The STB can use this to decide how many slots to start to drain.
  //  output dcu_store_dc3 valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_store_dc3 X or Z")
  u_ovl_intf_x_dcu_store_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_store_dc3));


  // A committed store or CP15 in dc3 is ready to enter the STB.
  //  output dcu_stb_req_dc3 valid always timing 35%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_stb_req_dc3 X or Z")
  u_ovl_intf_x_dcu_stb_req_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_stb_req_dc3));


  // The instruction is a Store Release
  //  output dcu_stlr_dc3 valid dcu_stb_req_dc3 timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_stlr_dc3 X or Z")
  u_ovl_intf_x_dcu_stlr_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_stb_req_dc3),
    .test_expr (dcu_stlr_dc3));


  // The instruction in wr was killed by the DPU. If asserted then any request
  // on dcu_stb_req_dc3 must be ignored. This is sent directly rather than being
  // factored into dcu_stb_req_dc3 by the DCU to help timing.

  // The store in dc3 can merge into the specified slot. This is based on the
  // info the STB returned in dc2.
  // Must be valid for the store in dc3, even if not requesting this cycle.
  // May go low without a request if the store was killed.
  //  output [4:0] dcu_store_merge_dc3 valid always timing 15%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "dcu_store_merge_dc3 X or Z")
  u_ovl_intf_x_dcu_store_merge_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_store_merge_dc3));


  // The store in dc3 is in the same line as the specified slots. This is based
  // on the info the STB returned in dc2.
  //  output [4:0] dcu_store_sameline_dc3 valid dcu_stb_req_dc3 timing 30%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "dcu_store_sameline_dc3 X or Z")
  u_ovl_intf_x_dcu_store_sameline_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_stb_req_dc3),
    .test_expr (dcu_store_sameline_dc3));


  // There is an nc load, or a cacheable load that needs to do a linefill, in
  // dc3 that is in the same line as the specified slots.
  // This is based on the info the STB returned in dc2. The STB can use this to
  // ensure it does not send the store out to AXI at the same time as the load
  // is being sent.
  // If dc3 is empty due to a bubble part way through an NC burst then the DCU
  // must hold the value of this signal until the next transaction.
  //  output [4:0] dcu_load_sameline_dc3 valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "dcu_load_sameline_dc3 X or Z")
  u_ovl_intf_x_dcu_load_sameline_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_load_sameline_dc3));


  // The physical address of the store/CP15 instruction (if done address 
  // translation) in dc3.
  // - This is not valid on barriers.
  //  output [39:0] dcu_pa_dc3 valid dcu_stb_req_dc3 & ~barrier_dc3 timing 30%

  assert_never_unknown #(`OVL_FATAL, 40, OUTOPTIONS, "dcu_pa_dc3 X or Z")
  u_ovl_intf_x_dcu_pa_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_stb_req_dc3 & ~barrier_dc3),
    .test_expr (dcu_pa_dc3));


  // The TrustZone non-secure state for the request being made from dc3. This
  // does not need to be valid on barrier operations, as the encoding on
  // AxPROT is fixed for barriers. For address based operations, this is the
  // ns bit from the page descriptor, for other cache/TLB maintenance ops it
  // is the NS state of the DPU.
  //  output dcu_ns_dsc_dc3 valid dcu_stb_req_dc3 & ~barrier_dc3 timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_ns_dsc_dc3 X or Z")
  u_ovl_intf_x_dcu_ns_dsc_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_stb_req_dc3 & ~barrier_dc3),
    .test_expr (dcu_ns_dsc_dc3));


  // Set if the transaction was generated from a privileged mode.
  // This must always be set for stores to normal memory, even if in user mode.
  // For cache and TLB maintenance ops, this stores the SCR_EL3.NS bit instead.
  //  output dcu_priv_dc3 valid dcu_stb_req_dc3 timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_priv_dc3 X or Z")
  u_ovl_intf_x_dcu_priv_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_stb_req_dc3),
    .test_expr (dcu_priv_dc3));


  // The transaction is a store exclusive instruction.
  //  output dcu_stb_exclusive_dc3 valid dcu_stb_req_dc3 timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_stb_exclusive_dc3 X or Z")
  u_ovl_intf_x_dcu_stb_exclusive_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_stb_req_dc3),
    .test_expr (dcu_stb_exclusive_dc3));


  // The transaction is a CP15 instruction that must be broadcast to other CPUs.
  // The type of operation is given in the store data.
  //  output dcu_store_cp15_dc3 valid dcu_stb_req_dc3 timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_store_cp15_dc3 X or Z")
  u_ovl_intf_x_dcu_store_cp15_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_stb_req_dc3),
    .test_expr (dcu_store_cp15_dc3));


  // The CP15 operation being broadcast requires that a DVM Sync is issued on
  // the next DSB.
  //  output dcu_dvm_sync_needed_dc3 valid (dcu_stb_req_dc3 & dcu_store_cp15_dc3) timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_dvm_sync_needed_dc3 X or Z")
  u_ovl_intf_x_dcu_dvm_sync_needed_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier ((dcu_stb_req_dc3 & dcu_store_cp15_dc3)),
    .test_expr (dcu_dvm_sync_needed_dc3));


  // - This should be the case for all TLB, ICU and BP ops

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & dcu_store_cp15_dc3  => dcu_dvm_sync_needed_dc3 == (cp15_op_type_ic | cp15_op_type_bp | cp15_op_type_tlb_aa32 | cp15_op_type_tlb_aa64)")
  u_ovl_intf_assert_e0a116a2721f54f1c0a878f862a157cc40a6de43 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & dcu_store_cp15_dc3 ),
    .consequent_expr (dcu_dvm_sync_needed_dc3 == (cp15_op_type_ic | cp15_op_type_bp | cp15_op_type_tlb_aa32 | cp15_op_type_tlb_aa64)));


  // Early information about certain type of broadcast operations.
  //  output dcu_store_dmb_dc3   valid dcu_stb_req_dc3 timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_store_dmb_dc3 X or Z")
  u_ovl_intf_x_dcu_store_dmb_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_stb_req_dc3),
    .test_expr (dcu_store_dmb_dc3));

  //  output dcu_store_dsb_dc3   valid dcu_stb_req_dc3 timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_store_dsb_dc3 X or Z")
  u_ovl_intf_x_dcu_store_dsb_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_stb_req_dc3),
    .test_expr (dcu_store_dsb_dc3));


  // DMB/DSB should be marked as CP15

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & (dcu_store_dmb_dc3 | dcu_store_dsb_dc3)  => dcu_store_cp15_dc3")
  u_ovl_intf_assert_dc93dbe1e74a974ab6208f65f48352c89a26fce1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & (dcu_store_dmb_dc3 | dcu_store_dsb_dc3) ),
    .consequent_expr (dcu_store_cp15_dc3));



  assert_zero_one_hot #(`OVL_FATAL, 2, OUTOPTIONS, "({2{dcu_stb_req_dc3}} & {dcu_store_dmb_dc3, dcu_store_dsb_dc3})")
  u_ovl_intf_assert_7012cad3afce3875c516b42135b3e6f2a07d7cb6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (({2{dcu_stb_req_dc3}} & {dcu_store_dmb_dc3, dcu_store_dsb_dc3})));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3  => dcu_store_dmb_dc3 == (dcu_store_cp15_dc3 & (dcu_store_bls_dc3[7:0] in [`CA53_CPOP_8_DMBNS,     `CA53_CPOP_8_DMBIS, `CA53_CPOP_8_DMBOS,     `CA53_CPOP_8_DMBSY, `CA53_CPOP_8_DMBNSST,   `CA53_CPOP_8_DMBISST, `CA53_CPOP_8_DMBOSST,   `CA53_CPOP_8_DMBSYST]))")
  u_ovl_intf_assert_a79c74bbc28b074660e902b8113cc96e0df9520b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 ),
    .consequent_expr (dcu_store_dmb_dc3 == (dcu_store_cp15_dc3 & (((dcu_store_bls_dc3[7:0] == `CA53_CPOP_8_DMBNS) | (dcu_store_bls_dc3[7:0] ==      `CA53_CPOP_8_DMBIS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBOS) | (dcu_store_bls_dc3[7:0] ==      `CA53_CPOP_8_DMBSY) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBNSST) | (dcu_store_bls_dc3[7:0] ==    `CA53_CPOP_8_DMBISST) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBOSST) | (dcu_store_bls_dc3[7:0] ==    `CA53_CPOP_8_DMBSYST))))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3  => dcu_store_dsb_dc3 == (dcu_store_cp15_dc3 & (dcu_store_bls_dc3[7:0] in [`CA53_CPOP_8_DSBNS,     `CA53_CPOP_8_DSBIS, `CA53_CPOP_8_DSBOS,     `CA53_CPOP_8_DSBSY]))")
  u_ovl_intf_assert_21585f4075a37e5ad1ec76954607904f58e92f9c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 ),
    .consequent_expr (dcu_store_dsb_dc3 == (dcu_store_cp15_dc3 & (((dcu_store_bls_dc3[7:0] == `CA53_CPOP_8_DSBNS) | (dcu_store_bls_dc3[7:0] ==      `CA53_CPOP_8_DSBIS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DSBOS) | (dcu_store_bls_dc3[7:0] ==      `CA53_CPOP_8_DSBSY))))));


  // The memory type, inner and outer cacheability and shareability attributes
  // for the request being made from dc3. Not valid on barriers (shareability
  // for barriers is encoded in the operation type).
  // Same encoding as dcu_attrs_dc2
  //  output [7:0] dcu_stb_attrs_dc3 valid (dcu_stb_req_dc3 & ~barrier_dc3) | (|dcu_load_sameline_dc3) timing 50%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "dcu_stb_attrs_dc3 X or Z")
  u_ovl_intf_x_dcu_stb_attrs_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier ((dcu_stb_req_dc3 & ~barrier_dc3) | (|dcu_load_sameline_dc3)),
    .test_expr (dcu_stb_attrs_dc3));


  // The byte lane strobes for the store data. Reused on CP ops to encode the
  // operation type ([7:0]) and VMID ([15:8]).
  //  output [15:0] dcu_store_bls_dc3 valid dcu_stb_req_dc3 timing 50%

  assert_never_unknown #(`OVL_FATAL, 16, OUTOPTIONS, "dcu_store_bls_dc3 X or Z")
  u_ovl_intf_x_dcu_store_bls_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_stb_req_dc3),
    .test_expr (dcu_store_bls_dc3));


  // Store data may be x for non-cp15 ops.
  assign store_data_valid  = dcu_stb_req_dc3 & ~dpu_kill_wr & dcu_store_cp15_dc3;

  // The last transaction in a burst
  //  output dcu_store_last_dc3 valid dcu_stb_req_dc3 timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_store_last_dc3 X or Z")
  u_ovl_intf_x_dcu_store_last_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_stb_req_dc3),
    .test_expr (dcu_store_last_dc3));


  // The STB slot is unable to drain to the BIU or complete a cache write due
  // to a stream of merging stores. The DCU must force subsequent stores to
  // form a separate burst.
  //  input stb_force_non_mergeable valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "stb_force_non_mergeable X or Z")
  u_ovl_intf_x_stb_force_non_mergeable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_force_non_mergeable));


  // A DMB or strongly ordered access is in dc3 and has been committed.
  // The STB should ensure that any stores following this cycle cannot complete
  // before anything already in the STB.
  //  output dcu_force_non_mergeable_dc3 valid always timing 65%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_force_non_mergeable_dc3 X or Z")
  u_ovl_intf_x_dcu_force_non_mergeable_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_force_non_mergeable_dc3));


  // There cannot be a store request if there is no store in dc3.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3  => dcu_store_dc3")
  u_ovl_intf_assert_0391f5829dfaa4ef4988534caa5bda7ec040071e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 ),
    .consequent_expr (dcu_store_dc3));


  // A store moving into dc3 must have previously been in dc2.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_store_dc3 & ~dcu_store_dc3@1  => dcu_store_dc2@1 & dcu_leaving_dc2@1")
  u_ovl_intf_assert_88037eb2ffd5ae810641a6c346cccfb45fa4d29c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_store_dc3 & ~dcu_store_dc3_reg ),
    .consequent_expr (dcu_store_dc2_reg & dcu_leaving_dc2_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_store_dc3 & store_accepted_dc3@1  => dcu_store_dc2@1 & dcu_leaving_dc2@1")
  u_ovl_intf_assert_c420a0bbb881a3e5588a5dce03de62ba052a820d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_store_dc3 & store_accepted_dc3_reg ),
    .consequent_expr (dcu_store_dc2_reg & dcu_leaving_dc2_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_store_dc3 & dcu_leaving_dc2@1  => dcu_store_dc2@1")
  u_ovl_intf_assert_7f9b579b9fe981e0e03bda640012de89d4ff750b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_store_dc3 & dcu_leaving_dc2_reg ),
    .consequent_expr (dcu_store_dc2_reg));


  // The STB must be notified a cycle before a new request to allow time for
  // the intermediate clock gate to be enabled.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3  => dcu_store_dc3@1 | (dcu_store_dc2@1 & dcu_leaving_dc2@1)")
  u_ovl_intf_assert_a9a52310633ba0bca46d1e9c68c6c7092f30da60 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 ),
    .consequent_expr (dcu_store_dc3_reg | (dcu_store_dc2_reg & dcu_leaving_dc2_reg)));


  // Cannot merge if there is no store in dc3.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dcu_store_dc3  => ~|dcu_store_merge_dc3")
  u_ovl_intf_assert_e980253f34d5ebcf1c9184afdf4cbfa94f1d3d75 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dcu_store_dc3 ),
    .consequent_expr (~|dcu_store_merge_dc3));


  // It is not possible to merge into more than one slot.

  assert_zero_one_hot #(`OVL_FATAL, 5, OUTOPTIONS, "dcu_store_merge_dc3")
  u_ovl_intf_assert_1c9d359d9398c6f996532884122aa8c5e5f04103 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (dcu_store_merge_dc3));


  assign next_merge_slot_changed  = ~dcu_leaving_dc2 & (merge_slot_changed | (~dcu_leaving_dc2_reg & (dcu_store_merge_dc3_reg != dcu_store_merge_dc3)));

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    merge_slot_changed <= 1'b0;
  else
    merge_slot_changed <= next_merge_slot_changed;


  // The slot that a store is merging into cannot change until the store
  // is accepted, killed, or flushed.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dcu_leaving_dc2@1 & dcu_stb_req_dc3  => (dcu_store_merge_dc3@1 == dcu_store_merge_dc3)")
  u_ovl_intf_assert_7f60ca94e3eefaeafeb4fe0445ec82398aa8e95f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dcu_leaving_dc2_reg & dcu_stb_req_dc3 ),
    .consequent_expr ((dcu_store_merge_dc3_reg == dcu_store_merge_dc3)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "merge_slot_changed  => ~dcu_stb_req_dc3")
  u_ovl_intf_assert_9841a157ca35bdec547531ca9b91b8cabbf24428 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (merge_slot_changed ),
    .consequent_expr (~dcu_stb_req_dc3));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    request_killed <= 1'b0;
  else if (dpu_kill_wr | request_killed)
    request_killed <= ~dcu_leaving_dc2;


  // A killed request must stay dead.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "request_killed  => ~dcu_stb_req_dc3")
  u_ovl_intf_assert_f1c65c317fcc57422551d354c91456307aa1338d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (request_killed ),
    .consequent_expr (~dcu_stb_req_dc3));


  // The store in dc3 can move into the STB if there is a spare slot, or if it can merge into a busy slot.
  assign store_accepted_dc3  = dcu_stb_req_dc3 & ~dpu_kill_wr & (|dcu_store_merge_dc3 | ~&stb_slots_valid);

  // A pending request in dc3 cannot be overridden by a new request in dc2

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dpu_kill_wr & dcu_leaving_dc2  => store_accepted_dc3")
  u_ovl_intf_assert_a86c7843029c8160d23a70787542f637a9582710 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dpu_kill_wr & dcu_leaving_dc2 ),
    .consequent_expr (store_accepted_dc3));


  // A pending request in dc3 cannot disappear unless flushed.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3@1 & ~dpu_kill_wr@1 & ~store_accepted_dc3@1  => dcu_stb_req_dc3")
  u_ovl_intf_assert_e194589e5f6269199eb5849d2c48a3f9a103d97a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3_reg & ~dpu_kill_wr_reg & ~store_accepted_dc3_reg ),
    .consequent_expr (dcu_stb_req_dc3));


  // Exclusives must be marked as shareable

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & dcu_stb_exclusive_dc3  => `CA53_MEM_SHAREABLE(dcu_stb_attrs_dc3)")
  u_ovl_intf_assert_caedf7c57e154fb67e2e2dcb060187dd6ba938c6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & dcu_stb_exclusive_dc3 ),
    .consequent_expr (`CA53_MEM_SHAREABLE(dcu_stb_attrs_dc3)));


  // A store must not remain in dc3 once the STB has accepted it, unless it was a shareable STREX or DSB
  assign dsb_dc3  = dcu_stb_req_dc3 & dcu_store_cp15_dc3 & (((dcu_store_bls_dc3[7:0] == `CA53_CPOP_8_DSBNS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DSBIS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DSBOS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DSBSY)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "store_accepted_dc3@1 & ~(dcu_stb_exclusive_dc3@1 & `CA53_MEM_SHAREABLE(dcu_stb_attrs_dc3@1)) & ~dsb_dc3@1 & ~(dcu_store_dc2@1 & dcu_leaving_dc2@1)  => ~dcu_store_dc3")
  u_ovl_intf_assert_6ac58dc1e0b711a42d2763adbdcb672e61bbccbb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (store_accepted_dc3_reg & ~(dcu_stb_exclusive_dc3_reg & `CA53_MEM_SHAREABLE(dcu_stb_attrs_dc3_reg)) & ~dsb_dc3_reg & ~(dcu_store_dc2_reg & dcu_leaving_dc2_reg) ),
    .consequent_expr (~dcu_store_dc3));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    non_mergeable_was_in_dc3 <= 1'b0;
  else
    non_mergeable_was_in_dc3 <= (dcu_force_non_mergeable_dc3 | non_mergeable_was_in_dc3) & ~(dcu_leaving_dc2 | (stb_cacheable_strex_done & stb_strex_failed));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    accepted_strex <= 1'b0;
  else
    accepted_strex <= (store_accepted_dc3 & dcu_stb_exclusive_dc3 & `CA53_MEM_SHAREABLE(dcu_stb_attrs_dc3)) | (accepted_strex & ~(dcu_leaving_dc2 | (stb_cacheable_strex_done & stb_strex_failed)));


  // A new instruction cannot enter dc3 until the strex has left.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "store_accepted_dc3 & dcu_stb_exclusive_dc3 & `CA53_MEM_SHAREABLE(dcu_stb_attrs_dc3)  => ~dcu_leaving_dc2")
  u_ovl_intf_assert_91e639f86d391328ee8b6a830b0c4898e62f2af1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (store_accepted_dc3 & dcu_stb_exclusive_dc3 & `CA53_MEM_SHAREABLE(dcu_stb_attrs_dc3) ),
    .consequent_expr (~dcu_leaving_dc2));


  // The STREX can't leave dc3 until its slot has completed.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "accepted_strex & |stb_slots_valid  => ~dcu_leaving_dc2")
  u_ovl_intf_assert_93e90142af6e9558155789608fdc2bf8abbc1cf7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (accepted_strex & |stb_slots_valid ),
    .consequent_expr (~dcu_leaving_dc2));


  // If the STB asserts stb_force_non_mergeable, it must continue to assert it until the
  // DCU responds by asserting dcu_force_non_mergeable_dc3.

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_force_non_mergeable@1 & ~dcu_force_non_mergeable_dc3@1  => stb_force_non_mergeable")
  u_ovl_intf_assume_e46670ac98551f897bff0e25edfba15efa1ecd1e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_force_non_mergeable_reg & ~dcu_force_non_mergeable_dc3_reg ),
    .consequent_expr (stb_force_non_mergeable));


  // A store that asserts dcu_force_non_mergeable_dc3 must continue to assert it while it
  // remains in dc3.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_store_dc3 & ~accepted_strex & non_mergeable_was_in_dc3  => dcu_force_non_mergeable_dc3")
  u_ovl_intf_assert_bc283a79a20b8aba1ed82f5f4c426d931ebb2f2e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_store_dc3 & ~accepted_strex & non_mergeable_was_in_dc3 ),
    .consequent_expr (dcu_force_non_mergeable_dc3));


  // The DCU must de-assert dcu_force_non_mergeable_dc3 after the store has entered the STB.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "store_accepted_dc3@1 & dcu_force_non_mergeable_dc3@1 & ~dcu_leaving_dc2@1  => ~dcu_force_non_mergeable_dc3")
  u_ovl_intf_assert_6c807115052136f5f42e07574c423b1c9dc34d99 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (store_accepted_dc3_reg & dcu_force_non_mergeable_dc3_reg & ~dcu_leaving_dc2_reg ),
    .consequent_expr (~dcu_force_non_mergeable_dc3));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    stb_can_merge_dc3 <= {5{1'b0}};
  else if (dcu_leaving_dc2 | store_accepted_dc3)
    stb_can_merge_dc3 <= (dcu_leaving_dc2 & ~stb_force_non_mergeable & ~dcu_force_non_mergeable_dc3) ? stb_can_merge_dc2 : 5'b00000;


  assign mergeable_to_dc3  = `CA53_MEM_MERGEABLE(dcu_stb_attrs_dc3) & ~dcu_store_cp15_dc3 & ~dcu_stlr_dc3 & ~stb_force_non_mergeable_dc2;

  assign mergeable_from_dc3  = ~dcu_stb_exclusive_dc3 & `CA53_MEM_MERGEABLE(dcu_stb_attrs_dc3) & ~dcu_store_cp15_dc3 & ~dcu_stlr_dc3;

  assign waw_attr_mismatch_dc2  = store_accepted_dc3 & ((dcu_pa_dc3[39:6] == dcu_pa_dc2[39:6]) & (dcu_ns_dsc_dc3 == dcu_ns_dsc_dc2) & (dcu_stb_attrs_dc3 != dcu_attrs_dc2) & ~barrier_dc3);

  assign waw_line_dc2  = store_accepted_dc3 & ((dcu_pa_dc3[39:6] == dcu_pa_dc2[39:6]) & (dcu_ns_dsc_dc3   == dcu_ns_dsc_dc2) & (dcu_stb_attrs_dc3 == dcu_attrs_dc2) & mergeable_to_dc3);

  assign raw_line_dc2  = store_accepted_dc3 & ~dcu_store_cp15_dc3 & ~dcu_stlr_dc3 & ~dcu_store_dc2 & (dcu_pa_dc3[39:6] == dcu_pa_dc2[39:6]) & (dcu_ns_dsc_dc3   == dcu_ns_dsc_dc2);

  assign waw_hazard_dc2  = waw_line_dc2 & (dcu_pa_dc3[5:4] == dcu_pa_dc2[5:4]);

  assign next_slot_to_fill  = {~stb_slots_valid[4] & (&stb_slots_valid[3:0]), ~stb_slots_valid[3] & (&stb_slots_valid[2:0]), ~stb_slots_valid[2] & (&stb_slots_valid[1:0]), ~stb_slots_valid[1] & stb_slots_valid[0], ~stb_slots_valid[0]};

  assign slot_filling_dc3  = {5{store_accepted_dc3}} & (|dcu_store_merge_dc3 ? dcu_store_merge_dc3 : next_slot_to_fill);

  // A new store to a slot must result in the slot becoming valid.

  assert_implication #(`OVL_FATAL, INOPTIONS, "slot_filling_dc3@1[0]  => stb_slots_valid[0]")
  u_ovl_intf_assume_230dcf5ca4628fc75de37992cc9c40468374f972 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (slot_filling_dc3_reg[0] ),
    .consequent_expr (stb_slots_valid[0]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "slot_filling_dc3@1[1]  => stb_slots_valid[1]")
  u_ovl_intf_assume_f786452f971558c6984475959c4571e0b696bf78 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (slot_filling_dc3_reg[1] ),
    .consequent_expr (stb_slots_valid[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "slot_filling_dc3@1[2]  => stb_slots_valid[2]")
  u_ovl_intf_assume_5f0229cb70d54e7618745963c172f03ad3388349 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (slot_filling_dc3_reg[2] ),
    .consequent_expr (stb_slots_valid[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "slot_filling_dc3@1[3]  => stb_slots_valid[3]")
  u_ovl_intf_assume_66a1faa9960587fb752a6385efcedfdbaa3794b9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (slot_filling_dc3_reg[3] ),
    .consequent_expr (stb_slots_valid[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "slot_filling_dc3@1[4]  => stb_slots_valid[4]")
  u_ovl_intf_assume_43ec324d008c99ab765b79126ee42e39f2fdc170 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (slot_filling_dc3_reg[4] ),
    .consequent_expr (stb_slots_valid[4]));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    waw_line_hazard_slot_dc3 <= {5{1'b0}};
  else if (dcu_leaving_dc2 | store_accepted_dc3)
    waw_line_hazard_slot_dc3 <= {5{dcu_leaving_dc2 & waw_line_dc2}} & slot_filling_dc3;



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    raw_line_hazard_slot_dc3 <= {5{1'b0}};
  else if (dcu_leaving_dc2 | store_accepted_dc3)
    raw_line_hazard_slot_dc3 <= {5{dcu_leaving_dc2 & raw_line_dc2}} & slot_filling_dc3;



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    waw_hazard_slot_dc3 <= {5{1'b0}};
  else if (dcu_leaving_dc2 | store_accepted_dc3)
    waw_hazard_slot_dc3 <= {5{dcu_leaving_dc2 & waw_hazard_dc2}} & slot_filling_dc3;


  assign stb_force_non_mergeable_dc2  = stb_force_non_mergeable & ~dcu_force_non_mergeable_dc3;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    stb_force_non_mergeable_dc3 <= 1'b0;
  else if (dcu_leaving_dc2 | store_accepted_dc3)
    stb_force_non_mergeable_dc3 <= stb_force_non_mergeable_dc2;



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    attr_mismatch_dc3 <= 1'b0;
  else if (dcu_leaving_dc2 | store_accepted_dc3)
    attr_mismatch_dc3 <= dcu_leaving_dc2 & (waw_attr_mismatch_dc2 | (stb_attr_mismatch_dc2 & ~dcu_force_non_mergeable_dc3));


  // The DCU may only say a slot can merge if the STB previously said it could
  // (when in dc2), or the slot has just become valid with a WAW hazard. But
  // the DCU may say a slot cannot merge even if the STB said it could.
  assign can_merge_dc3  = (stb_can_merge_dc3 | waw_hazard_slot_dc3) & {5{mergeable_from_dc3}};


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dpu_kill_wr  => ~|(dcu_store_merge_dc3 & ~can_merge_dc3)")
  u_ovl_intf_assert_98a0ad256473a0d07d887c61efe3792b966175c6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dpu_kill_wr ),
    .consequent_expr (~|(dcu_store_merge_dc3 & ~can_merge_dc3)));


  // If the DCU is not merging when the STB said it could, it must mark the new
  // store as non-mergeable.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dpu_kill_wr & |(can_merge_dc3 & ~dcu_store_merge_dc3)  => dcu_force_non_mergeable_dc3")
  u_ovl_intf_assert_15d11654e7f60206a87d94f2804284bc9fd59274 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dpu_kill_wr & |(can_merge_dc3 & ~dcu_store_merge_dc3) ),
    .consequent_expr (dcu_force_non_mergeable_dc3));


  // A store that is stalled in dc3 cannot merge into slots that it previously couldn't

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dcu_leaving_dc2@1  => ~|(dcu_store_merge_dc3 & ~dcu_store_merge_dc3@1)")
  u_ovl_intf_assert_3fd9347f5ceb60fc864f04456f57ef8cedf4e1f7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dcu_leaving_dc2_reg ),
    .consequent_expr (~|(dcu_store_merge_dc3 & ~dcu_store_merge_dc3_reg)));


  // If the attrs don't match then cannot merge.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & attr_mismatch_dc3  => ~|dcu_store_merge_dc3")
  u_ovl_intf_assert_cd078877a123d0719dbf4fd4d4d061180cdd7db5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & attr_mismatch_dc3 ),
    .consequent_expr (~|dcu_store_merge_dc3));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    stb_sameline_dc3 <= {5{1'b0}};
  else if (dcu_leaving_dc2 | store_accepted_dc3)
    stb_sameline_dc3 <= (dcu_leaving_dc2 & ~stb_force_non_mergeable & ~dcu_force_non_mergeable_dc3) ? stb_sameline_dc2 : 5'b00000;


  assign can_sameline_dc3  = (stb_sameline_dc3 | waw_line_hazard_slot_dc3) & {5{mergeable_from_dc3}};


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    stb_load_sameline_dc3 <= {5{1'b0}};
  else if (dcu_leaving_dc2 | store_accepted_dc3)
    stb_load_sameline_dc3 <= {5{dcu_leaving_dc2 & ~dcu_store_dc2}} & stb_load_sameline_dc2;


  assign can_load_sameline_dc3  = {5{~dcu_store_dc3}} & (stb_load_sameline_dc3 | raw_line_hazard_slot_dc3);

  // The DCU may only say a slot is in the same line if the STB previously said it could,
  // or the slot that has just become valid was the same line.
  // But the DCU may say a slot isn't the same line even if the STB said it was.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dpu_kill_wr  => ~|(dcu_store_sameline_dc3 & ~can_sameline_dc3)")
  u_ovl_intf_assert_98fedbf6ad9b20f0811626cc7ee163d1631fe527 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dpu_kill_wr ),
    .consequent_expr (~|(dcu_store_sameline_dc3 & ~can_sameline_dc3)));


  // The DCU may only say a slot is in the same line as a load if the STB
  // previously said it could.

  assert_always #(`OVL_FATAL, OUTOPTIONS, "~|(dcu_load_sameline_dc3 & ~can_load_sameline_dc3)")
  u_ovl_intf_assert_d21dedbebb4b08db3418211911024cc107c22c14 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (~|(dcu_load_sameline_dc3 & ~can_load_sameline_dc3)));


  // If the DCU is saying the load is in the same line, then it must do so for all slots that match.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|dcu_load_sameline_dc3  => dcu_load_sameline_dc3 == can_load_sameline_dc3")
  u_ovl_intf_assert_94e5fed289259a9ba9d46b477901a848cf747330 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|dcu_load_sameline_dc3 ),
    .consequent_expr (dcu_load_sameline_dc3 == can_load_sameline_dc3));


  // The DCU may only say a slot is in the same line if the STB previously said it could,
  // or the slot that has just become valid was the same line.
  // If the DCU is not saying it is in the sameline when the STB said it could, it must
  // mark the new store as non-mergeable.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dpu_kill_wr & |(can_sameline_dc3 & ~dcu_store_sameline_dc3)  => dcu_force_non_mergeable_dc3")
  u_ovl_intf_assert_7f98c50660b4dd1b70e44e0d59f85f5f33dea3da (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dpu_kill_wr & |(can_sameline_dc3 & ~dcu_store_sameline_dc3) ),
    .consequent_expr (dcu_force_non_mergeable_dc3));


  // If the attrs don't match then cannot be marked as sameline.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & attr_mismatch_dc3  => ~|dcu_store_sameline_dc3")
  u_ovl_intf_assert_a2031f196511ab285cadf2306080674840872601 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & attr_mismatch_dc3 ),
    .consequent_expr (~|dcu_store_sameline_dc3));


  assign real_store_sameline_dc3  = {{dcu_ns_dsc_dc3, dcu_pa_dc3[39:6]} == slot4_addr[40:6], {dcu_ns_dsc_dc3, dcu_pa_dc3[39:6]} == slot3_addr[40:6], {dcu_ns_dsc_dc3, dcu_pa_dc3[39:6]} == slot2_addr[40:6], {dcu_ns_dsc_dc3, dcu_pa_dc3[39:6]} == slot1_addr[40:6], {dcu_ns_dsc_dc3, dcu_pa_dc3[39:6]} == slot0_addr[40:6]};

  // The DCU may only say a slot is in the same line if it is in the same line.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & dcu_store_sameline_dc3[0] & stb_slots_valid[0]  => real_store_sameline_dc3[0]")
  u_ovl_intf_assert_859e28370cd424115d515f12806634ad23eb798e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & dcu_store_sameline_dc3[0] & stb_slots_valid[0] ),
    .consequent_expr (real_store_sameline_dc3[0]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & dcu_store_sameline_dc3[1] & stb_slots_valid[1]  => real_store_sameline_dc3[1]")
  u_ovl_intf_assert_21df359f2377cc0e58e3ea75bbf8a67b15b4511b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & dcu_store_sameline_dc3[1] & stb_slots_valid[1] ),
    .consequent_expr (real_store_sameline_dc3[1]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & dcu_store_sameline_dc3[2] & stb_slots_valid[2]  => real_store_sameline_dc3[2]")
  u_ovl_intf_assert_79308fb18065919900159646291f9d9f47c0b17b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & dcu_store_sameline_dc3[2] & stb_slots_valid[2] ),
    .consequent_expr (real_store_sameline_dc3[2]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & dcu_store_sameline_dc3[3] & stb_slots_valid[3]  => real_store_sameline_dc3[3]")
  u_ovl_intf_assert_ce101c818f79ee083ab842967a86404493386994 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & dcu_store_sameline_dc3[3] & stb_slots_valid[3] ),
    .consequent_expr (real_store_sameline_dc3[3]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & dcu_store_sameline_dc3[4] & stb_slots_valid[4]  => real_store_sameline_dc3[4]")
  u_ovl_intf_assert_fefe714ebfdbb96fdb7374a2e8d48c92ca9bf279 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & dcu_store_sameline_dc3[4] & stb_slots_valid[4] ),
    .consequent_expr (real_store_sameline_dc3[4]));


  // If the attrs don't match then the DCU must mark the store as non-mergeable (unless it is a CP15)

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dpu_kill_wr & attr_mismatch_dc3 & ~dcu_store_cp15_dc3  => dcu_force_non_mergeable_dc3")
  u_ovl_intf_assert_dc360fa6c096b1c4bb144804e5166b8f1820c5d2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dpu_kill_wr & attr_mismatch_dc3 & ~dcu_store_cp15_dc3 ),
    .consequent_expr (dcu_force_non_mergeable_dc3));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot0_addr <= {41{1'b0}};
  else if (store_accepted_dc3 & next_slot_to_fill[0])
    slot0_addr <= {dcu_ns_dsc_dc3, dcu_pa_dc3};


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot1_addr <= {41{1'b0}};
  else if (store_accepted_dc3 & next_slot_to_fill[1])
    slot1_addr <= {dcu_ns_dsc_dc3, dcu_pa_dc3};


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot2_addr <= {41{1'b0}};
  else if (store_accepted_dc3 & next_slot_to_fill[2])
    slot2_addr <= {dcu_ns_dsc_dc3, dcu_pa_dc3};


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot3_addr <= {41{1'b0}};
  else if (store_accepted_dc3 & next_slot_to_fill[3])
    slot3_addr <= {dcu_ns_dsc_dc3, dcu_pa_dc3};


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot4_addr <= {41{1'b0}};
  else if (store_accepted_dc3 & next_slot_to_fill[4])
    slot4_addr <= {dcu_ns_dsc_dc3, dcu_pa_dc3};


  assign real_sameqword_dc2  = stb_slots_valid & {{dcu_ns_dsc_dc2, dcu_pa_dc2[39:4]} == slot4_addr[40:4], {dcu_ns_dsc_dc2, dcu_pa_dc2[39:4]} == slot3_addr[40:4], {dcu_ns_dsc_dc2, dcu_pa_dc2[39:4]} == slot2_addr[40:4], {dcu_ns_dsc_dc2, dcu_pa_dc2[39:4]} == slot1_addr[40:4], {dcu_ns_dsc_dc2, dcu_pa_dc2[39:4]} == slot0_addr[40:4]};

  // The sameline and merge signals from the STB must only be set if the addresses match.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & stb_can_merge_dc2[0]  => real_sameqword_dc2[0]")
  u_ovl_intf_assume_7784e1b2a4f33b463bba72a67c236f8b61c692c6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & stb_can_merge_dc2[0] ),
    .consequent_expr (real_sameqword_dc2[0]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & stb_can_merge_dc2[1]  => real_sameqword_dc2[1]")
  u_ovl_intf_assume_665612c8d473494faf6b9f45947b36072015501a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & stb_can_merge_dc2[1] ),
    .consequent_expr (real_sameqword_dc2[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & stb_can_merge_dc2[2]  => real_sameqword_dc2[2]")
  u_ovl_intf_assume_6fda4d04ea22d058d8bf1f553a51a538d41fafae (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & stb_can_merge_dc2[2] ),
    .consequent_expr (real_sameqword_dc2[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & stb_can_merge_dc2[3]  => real_sameqword_dc2[3]")
  u_ovl_intf_assume_eb316cd33880898c5acf527b2b48b52dcbd9a838 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & stb_can_merge_dc2[3] ),
    .consequent_expr (real_sameqword_dc2[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & stb_can_merge_dc2[4]  => real_sameqword_dc2[4]")
  u_ovl_intf_assume_d0c66476d51df0d8270eadb3b46ec1302ccc3cec (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & stb_can_merge_dc2[4] ),
    .consequent_expr (real_sameqword_dc2[4]));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slots_barriered <= {5{1'b0}};
  else
    slots_barriered <= (stb_slots_valid & (slots_barriered | {5{dcu_force_non_mergeable_dc3 | (dcu_stb_req_dc3 & ~dpu_kill_wr & dcu_store_cp15_dc3)}})) | (slot_filling_dc3 & {5{dcu_store_cp15_dc3 | dcu_stlr_dc3}});


  // A slot cannot be in the sameline if there was a barrier between it and the new store.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2  => ~|(slots_barriered & stb_sameline_dc2)")
  u_ovl_intf_assume_d6c16e8d5f2df1308dde4c7903977f16b44207c7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 ),
    .consequent_expr (~|(slots_barriered & stb_sameline_dc2)));


  assign real_sameline_dc2  = (stb_slots_valid[4:0] & {{dcu_ns_dsc_dc2, dcu_pa_dc2[39:6]} == slot4_addr[40:6], {dcu_ns_dsc_dc2, dcu_pa_dc2[39:6]} == slot3_addr[40:6], {dcu_ns_dsc_dc2, dcu_pa_dc2[39:6]} == slot2_addr[40:6], {dcu_ns_dsc_dc2, dcu_pa_dc2[39:6]} == slot1_addr[40:6], {dcu_ns_dsc_dc2, dcu_pa_dc2[39:6]} == slot0_addr[40:6]});


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & stb_sameline_dc2[0]  => real_sameline_dc2[0] & ~slots_barriered[0]")
  u_ovl_intf_assume_c0fe5d7c335ddfa610735f1d0245f11527eea6b7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & stb_sameline_dc2[0] ),
    .consequent_expr (real_sameline_dc2[0] & ~slots_barriered[0]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & stb_sameline_dc2[1]  => real_sameline_dc2[1] & ~slots_barriered[1]")
  u_ovl_intf_assume_3c893a2b20bfd72f097c13b43d31373f81a283f0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & stb_sameline_dc2[1] ),
    .consequent_expr (real_sameline_dc2[1] & ~slots_barriered[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & stb_sameline_dc2[2]  => real_sameline_dc2[2] & ~slots_barriered[2]")
  u_ovl_intf_assume_bcfb4af9bfe782e9b980342fb7a1cdf353a57dbe (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & stb_sameline_dc2[2] ),
    .consequent_expr (real_sameline_dc2[2] & ~slots_barriered[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & stb_sameline_dc2[3]  => real_sameline_dc2[3] & ~slots_barriered[3]")
  u_ovl_intf_assume_f3ac8ff425ba0a74de22695f073d17988ef3a954 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & stb_sameline_dc2[3] ),
    .consequent_expr (real_sameline_dc2[3] & ~slots_barriered[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & stb_sameline_dc2[4]  => real_sameline_dc2[4] & ~slots_barriered[4]")
  u_ovl_intf_assume_f53c6197c9867ff2bf8143b55fc2242168e4c2eb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & stb_sameline_dc2[4] ),
    .consequent_expr (real_sameline_dc2[4] & ~slots_barriered[4]));



  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & stb_load_sameline_dc2[0]  => real_sameline_dc2[0]")
  u_ovl_intf_assume_3c1adca87e304732dee6b78a52cb9549037447a4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & stb_load_sameline_dc2[0] ),
    .consequent_expr (real_sameline_dc2[0]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & stb_load_sameline_dc2[1]  => real_sameline_dc2[1]")
  u_ovl_intf_assume_2604ca1dc3e03dfd93585797c657c1b4a8f1efc5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & stb_load_sameline_dc2[1] ),
    .consequent_expr (real_sameline_dc2[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & stb_load_sameline_dc2[2]  => real_sameline_dc2[2]")
  u_ovl_intf_assume_a2e02bde1d3688cf96c07e3aefad3d191219e93c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & stb_load_sameline_dc2[2] ),
    .consequent_expr (real_sameline_dc2[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & stb_load_sameline_dc2[3]  => real_sameline_dc2[3]")
  u_ovl_intf_assume_b22d8ed0b69d435a9b9ee3a47228ba06beab610e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & stb_load_sameline_dc2[3] ),
    .consequent_expr (real_sameline_dc2[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & stb_load_sameline_dc2[4]  => real_sameline_dc2[4]")
  u_ovl_intf_assume_058c3a9b888ccddb954159da0c529eb9c938bc44 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & stb_load_sameline_dc2[4] ),
    .consequent_expr (real_sameline_dc2[4]));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot0_attrs <= {8{1'b0}};
  else if (store_accepted_dc3 & next_slot_to_fill[0])
    slot0_attrs <= dcu_stb_attrs_dc3;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot1_attrs <= {8{1'b0}};
  else if (store_accepted_dc3 & next_slot_to_fill[1])
    slot1_attrs <= dcu_stb_attrs_dc3;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot2_attrs <= {8{1'b0}};
  else if (store_accepted_dc3 & next_slot_to_fill[2])
    slot2_attrs <= dcu_stb_attrs_dc3;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot3_attrs <= {8{1'b0}};
  else if (store_accepted_dc3 & next_slot_to_fill[3])
    slot3_attrs <= dcu_stb_attrs_dc3;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot4_attrs <= {8{1'b0}};
  else if (store_accepted_dc3 & next_slot_to_fill[4])
    slot4_attrs <= dcu_stb_attrs_dc3;



  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & real_sameline_dc2[0] & ~slots_barriered[0] & (dcu_attrs_dc2 != slot0_attrs)  => stb_attr_mismatch_dc2")
  u_ovl_intf_assume_80c1438a5d48af440aa30d0aafe2bac6f303e47a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & real_sameline_dc2[0] & ~slots_barriered[0] & (dcu_attrs_dc2 != slot0_attrs) ),
    .consequent_expr (stb_attr_mismatch_dc2));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & real_sameline_dc2[1] & ~slots_barriered[1] & (dcu_attrs_dc2 != slot1_attrs)  => stb_attr_mismatch_dc2")
  u_ovl_intf_assume_6f50dc9b1f5503605fd1cce1a9943019286f56b7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & real_sameline_dc2[1] & ~slots_barriered[1] & (dcu_attrs_dc2 != slot1_attrs) ),
    .consequent_expr (stb_attr_mismatch_dc2));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & real_sameline_dc2[2] & ~slots_barriered[2] & (dcu_attrs_dc2 != slot2_attrs)  => stb_attr_mismatch_dc2")
  u_ovl_intf_assume_d2116dad3481ddecb2cf334ba0361b2136a292e3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & real_sameline_dc2[2] & ~slots_barriered[2] & (dcu_attrs_dc2 != slot2_attrs) ),
    .consequent_expr (stb_attr_mismatch_dc2));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & real_sameline_dc2[3] & ~slots_barriered[3] & (dcu_attrs_dc2 != slot3_attrs)  => stb_attr_mismatch_dc2")
  u_ovl_intf_assume_8951541aa36cc0149e674ac9544d96dd9c1b01ca (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & real_sameline_dc2[3] & ~slots_barriered[3] & (dcu_attrs_dc2 != slot3_attrs) ),
    .consequent_expr (stb_attr_mismatch_dc2));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & real_sameline_dc2[4] & ~slots_barriered[4] & (dcu_attrs_dc2 != slot4_attrs)  => stb_attr_mismatch_dc2")
  u_ovl_intf_assume_e3d585fd5fa58cbf22f4239cbd71efc6f1b003c0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & real_sameline_dc2[4] & ~slots_barriered[4] & (dcu_attrs_dc2 != slot4_attrs) ),
    .consequent_expr (stb_attr_mismatch_dc2));



  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & stb_attr_mismatch_dc2  => ((real_sameline_dc2[0] & ~slots_barriered[0] & (dcu_attrs_dc2 != slot0_attrs)) | (real_sameline_dc2[1] & ~slots_barriered[1] & (dcu_attrs_dc2 != slot1_attrs)) | (real_sameline_dc2[2] & ~slots_barriered[2] & (dcu_attrs_dc2 != slot2_attrs)) | (real_sameline_dc2[3] & ~slots_barriered[3] & (dcu_attrs_dc2 != slot3_attrs)) | (real_sameline_dc2[4] & ~slots_barriered[4] & (dcu_attrs_dc2 != slot4_attrs)))")
  u_ovl_intf_assume_6002157790987fa01d04abfd93f311d0ff1c6414 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & stb_attr_mismatch_dc2 ),
    .consequent_expr (((real_sameline_dc2[0] & ~slots_barriered[0] & (dcu_attrs_dc2 != slot0_attrs)) | (real_sameline_dc2[1] & ~slots_barriered[1] & (dcu_attrs_dc2 != slot1_attrs)) | (real_sameline_dc2[2] & ~slots_barriered[2] & (dcu_attrs_dc2 != slot2_attrs)) | (real_sameline_dc2[3] & ~slots_barriered[3] & (dcu_attrs_dc2 != slot3_attrs)) | (real_sameline_dc2[4] & ~slots_barriered[4] & (dcu_attrs_dc2 != slot4_attrs)))));


  assign slots_nonmergeable  = {5{dcu_valid_dc2 & ~stb_attr_mismatch_dc2}} & real_sameqword_dc2 & ~stb_can_merge_dc2;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slots_were_nonmergeable <= {5{1'b0}};
  else
    slots_were_nonmergeable <= stb_slots_valid & (slots_were_nonmergeable | slots_nonmergeable | {5{dcu_force_non_mergeable_dc3}});


  // Once the STB has said a matching doubleword cannot merge into a slot, then
  // nothing else can merge into that slot either.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & slots_were_nonmergeable[4]  => ~stb_can_merge_dc2[4]")
  u_ovl_intf_assume_5d812cb3c2e669bcba623a31bb0ecd3a1b6831a8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & slots_were_nonmergeable[4] ),
    .consequent_expr (~stb_can_merge_dc2[4]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & slots_were_nonmergeable[3]  => ~stb_can_merge_dc2[3]")
  u_ovl_intf_assume_ccd9b5c4f74254641fecc8566b6f14512ebc964f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & slots_were_nonmergeable[3] ),
    .consequent_expr (~stb_can_merge_dc2[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & slots_were_nonmergeable[2]  => ~stb_can_merge_dc2[2]")
  u_ovl_intf_assume_7b477151e7f17e75a35c5d8d13600e5c3ac802f4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & slots_were_nonmergeable[2] ),
    .consequent_expr (~stb_can_merge_dc2[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & slots_were_nonmergeable[1]  => ~stb_can_merge_dc2[1]")
  u_ovl_intf_assume_9fc527fe48e7b58422e56aa3f91e9e50087b0d87 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & slots_were_nonmergeable[1] ),
    .consequent_expr (~stb_can_merge_dc2[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_valid_dc2 & slots_were_nonmergeable[0]  => ~stb_can_merge_dc2[0]")
  u_ovl_intf_assume_7773facfe132a4f097fb5e23779b51047d75f2ec (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_valid_dc2 & slots_were_nonmergeable[0] ),
    .consequent_expr (~stb_can_merge_dc2[0]));


  // The STB must indicate a DMB in progress as soon as a new DMB is accepted
  assign dmb_dc3  = dcu_stb_req_dc3 & dcu_store_cp15_dc3 & (((dcu_store_bls_dc3[7:0] == `CA53_CPOP_8_DMBNS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBIS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBOS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBSY) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBNSST) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBISST) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBOSST) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBSYST)));

  // A STLR must never merge into an existing slot, as it is always preceded by
  // by a barrier.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dpu_kill_wr & dcu_stlr_dc3  => ~|dcu_store_merge_dc3")
  u_ovl_intf_assert_eb7ad20b681eb53f8c7fb9be143197a949125388 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dpu_kill_wr & dcu_stlr_dc3 ),
    .consequent_expr (~|dcu_store_merge_dc3));


  // STB stb_block_loads_dc1 signal must become asserted in response to a full
  // DMB, DC maintenance operation, or STLR store entering the store buffer
  assign store_causes_block_loads  = dcu_stb_req_dc3 &  ((dcu_store_cp15_dc3 & (((dcu_store_bls_dc3[7:0] == `CA53_CPOP_8_DMBNS) | (dcu_store_bls_dc3[7:0] ==    `CA53_CPOP_8_DMBIS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBOS) | (dcu_store_bls_dc3[7:0] ==    `CA53_CPOP_8_DMBSY) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DCIMVAC) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DCISW) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DCCMVAC) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DCCSW) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DCCMVAU) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DCCIMVAC) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DCCISW)))) | dcu_stlr_dc3);


  assert_implication #(`OVL_FATAL, INOPTIONS, "store_accepted_dc3@1 & store_causes_block_loads@1  => stb_block_loads_dc1")
  u_ovl_intf_assume_29cc813f1c058cb18cb03b5fd326fb1dba401b8b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (store_accepted_dc3_reg & store_causes_block_loads_reg ),
    .consequent_expr (stb_block_loads_dc1));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot0_valid_cp_addr <= 1'b0;
  else if (store_accepted_dc3 & next_slot_to_fill[0])
    slot0_valid_cp_addr <= dcu_store_cp15_dc3 & ~broadcast_cp_op_not_by_addr;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot1_valid_cp_addr <= 1'b0;
  else if (store_accepted_dc3 & next_slot_to_fill[1])
    slot1_valid_cp_addr <= dcu_store_cp15_dc3 & ~broadcast_cp_op_not_by_addr;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot2_valid_cp_addr <= 1'b0;
  else if (store_accepted_dc3 & next_slot_to_fill[2])
    slot2_valid_cp_addr <= dcu_store_cp15_dc3 & ~broadcast_cp_op_not_by_addr;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot3_valid_cp_addr <= 1'b0;
  else if (store_accepted_dc3 & next_slot_to_fill[3])
    slot3_valid_cp_addr <= dcu_store_cp15_dc3 & ~broadcast_cp_op_not_by_addr;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slot4_valid_cp_addr <= 1'b0;
  else if (store_accepted_dc3 & next_slot_to_fill[4])
    slot4_valid_cp_addr <= dcu_store_cp15_dc3 & ~broadcast_cp_op_not_by_addr;


  assign cp_sameline_dc3  = (stb_slots_valid & {slot4_valid_cp_addr, slot3_valid_cp_addr, slot2_valid_cp_addr, slot1_valid_cp_addr, slot0_valid_cp_addr} & {{dcu_ns_dsc_dc3, dcu_pa_dc3[39:6]} == slot4_addr[40:6], {dcu_ns_dsc_dc3, dcu_pa_dc3[39:6]} == slot3_addr[40:6], {dcu_ns_dsc_dc3, dcu_pa_dc3[39:6]} == slot2_addr[40:6], {dcu_ns_dsc_dc3, dcu_pa_dc3[39:6]} == slot1_addr[40:6], {dcu_ns_dsc_dc3, dcu_pa_dc3[39:6]} == slot0_addr[40:6]});

  // STB must indicate when a DCU address in DC2 matches a CP15 slot address
  assign cp_sameline_dc2  = (stb_slots_valid[4:0] & {slot4_valid_cp_addr, slot3_valid_cp_addr, slot2_valid_cp_addr, slot1_valid_cp_addr, slot0_valid_cp_addr} & {{dcu_ns_dsc_dc2, dcu_pa_dc2[39:6]} == slot4_addr[40:6], {dcu_ns_dsc_dc2, dcu_pa_dc2[39:6]} == slot3_addr[40:6], {dcu_ns_dsc_dc2, dcu_pa_dc2[39:6]} == slot2_addr[40:6], {dcu_ns_dsc_dc2, dcu_pa_dc2[39:6]} == slot1_addr[40:6], {dcu_ns_dsc_dc2, dcu_pa_dc2[39:6]} == slot0_addr[40:6]});



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    previous_pa_from_dc2 <= {37{1'b0}};
  else if (dcu_leaving_dc2)
    previous_pa_from_dc2 <= dcu_pa_dc2[39:3];


  // The address should be the same in dc3 as when it was in dc2 - unless it is a cp op
  // that is being broadcast that is not based purely on the pa.
  // - ICIMVAU is included here because some bits of the va are merged with the pa.

  assign broadcast_cp_op_not_by_addr  = dcu_store_cp15_dc3 & (((dcu_store_bls_dc3[7:0] == `CA53_CPOP_8_DCISW) | (dcu_store_bls_dc3[7:0] ==       `CA53_CPOP_8_DCCSW) | (dcu_store_bls_dc3[7:0] ==           `CA53_CPOP_8_DCCISW) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_ICIALLUIS) | (dcu_store_bls_dc3[7:0] ==   `CA53_CPOP_8_ICIALLU) | (dcu_store_bls_dc3[7:0] ==         `CA53_CPOP_8_ICIMVAU) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIALL) | (dcu_store_bls_dc3[7:0] ==     `CA53_CPOP_8_TLBIALLIS) | (dcu_store_bls_dc3[7:0] ==       `CA53_CPOP_8_TLBIALLH) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIALLHIS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIALLNSNH) | (dcu_store_bls_dc3[7:0] ==     `CA53_CPOP_8_TLBIALLNSNHIS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIMVA) | (dcu_store_bls_dc3[7:0] ==     `CA53_CPOP_8_TLBIMVAIS) | (dcu_store_bls_dc3[7:0] ==       `CA53_CPOP_8_TLBIMVAHIS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIMVAH) | (dcu_store_bls_dc3[7:0] ==    `CA53_CPOP_8_TLBIMVAA) | (dcu_store_bls_dc3[7:0] ==        `CA53_CPOP_8_TLBIMVAAIS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIASID) | (dcu_store_bls_dc3[7:0] ==    `CA53_CPOP_8_TLBIASIDIS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIVAE3) | (dcu_store_bls_dc3[7:0] ==    `CA53_CPOP_8_TLBIVAE3IS) | (dcu_store_bls_dc3[7:0] ==      `CA53_CPOP_8_TLBIVALE3) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIVALE3IS) | (dcu_store_bls_dc3[7:0] == `CA53_CPOP_8_TLBIVMALLS12E1) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIVMALLS12E1IS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIALLE3) | (dcu_store_bls_dc3[7:0] ==   `CA53_CPOP_8_TLBIALLE3IS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIMVAL) | (dcu_store_bls_dc3[7:0] ==    `CA53_CPOP_8_TLBIMVALIS) | (dcu_store_bls_dc3[7:0] ==      `CA53_CPOP_8_TLBIMVALH) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIMVALHIS) | (dcu_store_bls_dc3[7:0] == `CA53_CPOP_8_TLBIMVAAL) | (dcu_store_bls_dc3[7:0] ==       `CA53_CPOP_8_TLBIMVAALIS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIVAE1) | (dcu_store_bls_dc3[7:0] ==    `CA53_CPOP_8_TLBIVALE1) | (dcu_store_bls_dc3[7:0] ==       `CA53_CPOP_8_TLBIVAAE1) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIVAALE1) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIASIDE1) | (dcu_store_bls_dc3[7:0] ==      `CA53_CPOP_8_TLBIVMALLE1) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIALLE1) | (dcu_store_bls_dc3[7:0] ==   `CA53_CPOP_8_TLBIIPAS2E1) | (dcu_store_bls_dc3[7:0] ==     `CA53_CPOP_8_TLBIIPAS2LE1) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIVAE2) | (dcu_store_bls_dc3[7:0] ==    `CA53_CPOP_8_TLBIVALE2) | (dcu_store_bls_dc3[7:0] ==       `CA53_CPOP_8_TLBIALLE2) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIIPAS2) | (dcu_store_bls_dc3[7:0] ==   `CA53_CPOP_8_TLBIIPAS2IS) | (dcu_store_bls_dc3[7:0] ==     `CA53_CPOP_8_TLBIIPAS2L) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIIPAS2LIS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIVAE1IS) | (dcu_store_bls_dc3[7:0] ==    `CA53_CPOP_8_TLBIVALE1IS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIVAAE1IS) | (dcu_store_bls_dc3[7:0] == `CA53_CPOP_8_TLBIVAALE1IS) | (dcu_store_bls_dc3[7:0] ==    `CA53_CPOP_8_TLBIASIDE1IS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIVMALLE1IS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIALLE1IS) | (dcu_store_bls_dc3[7:0] == `CA53_CPOP_8_TLBIIPAS2E1IS) | (dcu_store_bls_dc3[7:0] ==   `CA53_CPOP_8_TLBIIPAS2LE1IS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIVAE2IS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_TLBIVALE2IS) | (dcu_store_bls_dc3[7:0] ==     `CA53_CPOP_8_TLBIALLE2IS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_BPIALLIS) | (dcu_store_bls_dc3[7:0] ==    `CA53_CPOP_8_BPIMVA) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DSBNS) | (dcu_store_bls_dc3[7:0] ==       `CA53_CPOP_8_DSBIS) | (dcu_store_bls_dc3[7:0] ==           `CA53_CPOP_8_DSBOS) | (dcu_store_bls_dc3[7:0] ==     `CA53_CPOP_8_DSBSY) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBNS) | (dcu_store_bls_dc3[7:0] ==       `CA53_CPOP_8_DMBIS) | (dcu_store_bls_dc3[7:0] ==           `CA53_CPOP_8_DMBOS) | (dcu_store_bls_dc3[7:0] ==     `CA53_CPOP_8_DMBSY) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBNSST) | (dcu_store_bls_dc3[7:0] ==     `CA53_CPOP_8_DMBISST) | (dcu_store_bls_dc3[7:0] ==         `CA53_CPOP_8_DMBOSST) | (dcu_store_bls_dc3[7:0] ==   `CA53_CPOP_8_DMBSYST)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(dcu_stb_req_dc3 & ~broadcast_cp_op_not_by_addr) | (|dcu_load_sameline_dc3)  => dcu_pa_dc3[39:3] == previous_pa_from_dc2[39:3]")
  u_ovl_intf_assert_3155fff29ded5c180e011c2f70f8f21ffebf2088 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((dcu_stb_req_dc3 & ~broadcast_cp_op_not_by_addr) | (|dcu_load_sameline_dc3) ),
    .consequent_expr (dcu_pa_dc3[39:3] == previous_pa_from_dc2[39:3]));




  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    previous_ns_from_dc2 <= 1'b0;
  else if (dcu_leaving_dc2)
    previous_ns_from_dc2 <= dcu_ns_dsc_dc2;


  // The nonsecure bit should be the same in dc3 as when it was in dc2 for operations which have an address

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & (~dcu_store_cp15_dc3 | ~broadcast_cp_op_not_by_addr)  => dcu_ns_dsc_dc3 == previous_ns_from_dc2")
  u_ovl_intf_assert_5aaf4702d8a2f782084447ad415ece9973b8a69e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & (~dcu_store_cp15_dc3 | ~broadcast_cp_op_not_by_addr) ),
    .consequent_expr (dcu_ns_dsc_dc3 == previous_ns_from_dc2));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    previous_attrs_from_dc2 <= {8{1'b0}};
  else if (dcu_leaving_dc2)
    previous_attrs_from_dc2 <= dcu_attrs_dc2;


  // The attributes should be the same in dc3 as when it was in dc2, unless the request is a CP15.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_cp15_dc3  => dcu_stb_attrs_dc3 == previous_attrs_from_dc2")
  u_ovl_intf_assert_06b3abd5888bd25224f28cdb468bf618bad0f608 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 ),
    .consequent_expr (dcu_stb_attrs_dc3 == previous_attrs_from_dc2));


  // STREX and CP15 are mutually exclusive.

  assert_zero_one_hot #(`OVL_FATAL, 2, OUTOPTIONS, "{2{dcu_stb_req_dc3}} & {dcu_stb_exclusive_dc3, dcu_store_cp15_dc3}")
  u_ovl_intf_assert_5a5a4a8fdbc09f924776c93887d54dc9dd4c2f9b (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ({2{dcu_stb_req_dc3}} & {dcu_stb_exclusive_dc3, dcu_store_cp15_dc3}));


  // Some attribute encodings are unused.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_cp15_dc3  => ~`CA53_MEM_UNUSED(dcu_stb_attrs_dc3)")
  u_ovl_intf_assert_2960bbbaa0e0eb3d9251ddb356d35e555f248d1b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 ),
    .consequent_expr (~`CA53_MEM_UNUSED(dcu_stb_attrs_dc3)));


  // Record when there is an ongoing burst.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    ongoing_burst_mergeable <= 1'b0;
  else if (store_accepted_dc3 | dpu_kill_wr)
    ongoing_burst_mergeable <= `CA53_MEM_MERGEABLE(dcu_stb_attrs_dc3) & ~dcu_store_last_dc3  & ~dpu_kill_wr;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    ongoing_burst_device_gre <= 1'b0;
  else if (store_accepted_dc3 | dpu_kill_wr)
    ongoing_burst_device_gre <= `CA53_MEM_GRE(dcu_stb_attrs_dc3) & ~dcu_store_last_dc3 & ~dpu_kill_wr;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    ongoing_burst_device_ng <= 1'b0;
  else if (store_accepted_dc3)
    ongoing_burst_device_ng <= `CA53_MEM_DEVICE_nG(dcu_stb_attrs_dc3) & ~dcu_store_last_dc3;


  assign ongoing_burst_device  = ongoing_burst_device_gre | ongoing_burst_device_ng;
  assign ongoing_burst  = ongoing_burst_mergeable | ongoing_burst_device;

  // Note that device bursts will always be to aligned addresses, but may not transfer a full
  // burst worth of data. This can happen on an STP which crosses a page boundary (and so is also
  // x128) and goes from normal memory (so it does not align fail) to device memory. In this case
  // the address will always be aligned for the device beats, and the dcu_store_last information
  // wil be accurate, but the strobes may indicate less than a full amount of data being 
  // transferred.
  // Note that any beat not marked as last will be consistent, as only the last beat of a x128
  // STP transfers less than 128-bits.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dpu_kill_wr & ~dcu_store_last_dc3 & ~`CA53_MEM_NORMAL(dcu_stb_attrs_dc3)  => dcu_store_bls_dc3 in [16'hFFFF, 16'hFF00, 16'h00FF, 16'h000F, 16'h00F0, 16'h0F00, 16'hF000]")
  u_ovl_intf_assert_df6decfd0290763ec5e8f7a7fc8b0f6e3ccf3d96 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dpu_kill_wr & ~dcu_store_last_dc3 & ~`CA53_MEM_NORMAL(dcu_stb_attrs_dc3) ),
    .consequent_expr (((dcu_store_bls_dc3 == 16'hFFFF) | (dcu_store_bls_dc3 ==  16'hFF00) | (dcu_store_bls_dc3 ==  16'h00FF) | (dcu_store_bls_dc3 ==  16'h000F) | (dcu_store_bls_dc3 ==  16'h00F0) | (dcu_store_bls_dc3 ==  16'h0F00) | (dcu_store_bls_dc3 ==  16'hF000))));


  // Device bursts must be word aligned

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(dcu_stb_req_dc3 & ~dpu_kill_wr & `CA53_MEM_DEVICE(dcu_stb_attrs_dc3) & (~dcu_store_last_dc3 | ongoing_burst_device))  => dcu_pa_dc3[1:0] == 2'b00")
  u_ovl_intf_assert_be3d688ae8c947dd9b81efa356694c6cafbfb410 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((dcu_stb_req_dc3 & ~dpu_kill_wr & `CA53_MEM_DEVICE(dcu_stb_attrs_dc3) & (~dcu_store_last_dc3 | ongoing_burst_device)) ),
    .consequent_expr (dcu_pa_dc3[1:0] == 2'b00));


  // Only non-gathering Device stores can have zero byte strobes (strobes are suppressed on a watchpoint).

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dpu_kill_wr & (dcu_store_bls_dc3 == 16'h0000)  => `CA53_MEM_DEVICE_nG(dcu_stb_attrs_dc3)")
  u_ovl_intf_assert_7b7b0069f3dedf64d6a9a51d528b11548dd924b5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dpu_kill_wr & (dcu_store_bls_dc3 == 16'h0000) ),
    .consequent_expr (`CA53_MEM_DEVICE_nG(dcu_stb_attrs_dc3)));


  assign misc_attrs_dc3  = {dcu_ns_dsc_dc3, dcu_priv_dc3, dcu_stb_attrs_dc3, dcu_stb_exclusive_dc3, dcu_store_cp15_dc3};


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    next_misc_attrs <= {12{1'b0}};
  else if (store_accepted_dc3)
    next_misc_attrs <= misc_attrs_dc3;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    next_cacheline <= {34{1'b0}};
  else if (store_accepted_dc3)
    next_cacheline <= dcu_pa_dc3[39:6];


  // The transaction attributes must be the same for the whole burst.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dpu_kill_wr & ongoing_burst  => misc_attrs_dc3 == next_misc_attrs")
  u_ovl_intf_assert_964739437321fb24823a99d93ecedbe5807f4f55 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dpu_kill_wr & ongoing_burst ),
    .consequent_expr (misc_attrs_dc3 == next_misc_attrs));


  // The transaction cacheline must be the same for the whole burst.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dpu_kill_wr & ongoing_burst  => dcu_pa_dc3[39:6] == next_cacheline")
  u_ovl_intf_assert_f78060ed852c5e96298dada3f843a6e247ce8d5d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dpu_kill_wr & ongoing_burst ),
    .consequent_expr (dcu_pa_dc3[39:6] == next_cacheline));


  // Stores to normal memory that might be merged to must always be marked as privileged.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & `CA53_MEM_NORMAL(dcu_stb_attrs_dc3) & ~(dcu_stb_exclusive_dc3 & `CA53_MEM_SHAREABLE(dcu_stb_attrs_dc3) & ~`CA53_MEM_COHERENT(dcu_stb_attrs_dc3)) & ~dcu_store_cp15_dc3  => dcu_priv_dc3")
  u_ovl_intf_assert_f60c205ccd67d7ba27c1f293c0b4108e0075d17a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & `CA53_MEM_NORMAL(dcu_stb_attrs_dc3) & ~(dcu_stb_exclusive_dc3 & `CA53_MEM_SHAREABLE(dcu_stb_attrs_dc3) & ~`CA53_MEM_COHERENT(dcu_stb_attrs_dc3)) & ~dcu_store_cp15_dc3 ),
    .consequent_expr (dcu_priv_dc3));


  // CP15 cannot be a burst.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_last_dc3  => ~dcu_store_cp15_dc3")
  u_ovl_intf_assert_723235d4cb37259dc53476390ca8aa1f07888a6b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_last_dc3 ),
    .consequent_expr (~dcu_store_cp15_dc3));


  // Exclusives can never be a burst

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_last_dc3  => ~dcu_stb_exclusive_dc3")
  u_ovl_intf_assert_7aadfca8ba577cbbd212a0d121851405a080fa64 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_last_dc3 ),
    .consequent_expr (~dcu_stb_exclusive_dc3));


  // Store releases can never be a burst

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_last_dc3  => ~dcu_stlr_dc3")
  u_ovl_intf_assert_88f17ee38b3ef369a0ad9f3430263539693d32fd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_last_dc3 ),
    .consequent_expr (~dcu_stlr_dc3));


  // Bursts cannot cross a 64byte boundary

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_last_dc3 & ~dpu_kill_wr  => (dcu_pa_dc3[5:2] + ((dcu_store_bls_dc3 in [16'h0000, 16'h00FF, 16'hFF00]) ? 2'b10 :   1'b1)) < 16")
  u_ovl_intf_assert_0745b5bea6bba58cd695008215ec890dd3065c69 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_last_dc3 & ~dpu_kill_wr ),
    .consequent_expr ((dcu_pa_dc3[5:2] + ((((dcu_store_bls_dc3 == 16'h0000) | (dcu_store_bls_dc3 ==  16'h00FF) | (dcu_store_bls_dc3 ==  16'hFF00))) ? 2'b10 :   1'b1)) < 16));



  // For bursts, the address will normally increase by 8 for subsequent transactions in dc3, except for
  // after the first transaction of an STM which is word aligned only, which will only transfer 32-bits
  // in the first transaction, and so the address will increase by 4.
  assign bytes_transferred  = dcu_store_bls_dc3[0]  + dcu_store_bls_dc3[1]  + dcu_store_bls_dc3[2]  + dcu_store_bls_dc3[3]  + dcu_store_bls_dc3[4]  + dcu_store_bls_dc3[5]  + dcu_store_bls_dc3[6]  + dcu_store_bls_dc3[7]  + dcu_store_bls_dc3[8]  + dcu_store_bls_dc3[9]  + dcu_store_bls_dc3[10] + dcu_store_bls_dc3[11] + dcu_store_bls_dc3[12] + dcu_store_bls_dc3[13] + dcu_store_bls_dc3[14] + dcu_store_bls_dc3[15];


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    next_pa <= {40{1'b0}};
  else if (store_accepted_dc3)
    next_pa <= dcu_pa_dc3 + bytes_transferred;



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dpu_kill_wr & ongoing_burst  => dcu_pa_dc3 == next_pa")
  u_ovl_intf_assert_5130fa3abe9ed9f83b2d54eedd586af5e99c45c6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dpu_kill_wr & ongoing_burst ),
    .consequent_expr (dcu_pa_dc3 == next_pa));


  // Exclusives must always be size aligned
  assign excl_req_dc3  = dcu_stb_req_dc3 & ~dpu_kill_wr & ~dcu_store_cp15_dc3 & dcu_stb_exclusive_dc3;
  assign dev_req_dc3   = dcu_stb_req_dc3 & ~dpu_kill_wr & ~dcu_store_cp15_dc3 & ~`CA53_MEM_NORMAL(dcu_stb_attrs_dc3);

  // Stores should only ever access sequential bytes

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[0]  & ~dcu_store_bls_dc3[1]   => ~|dcu_store_bls_dc3[15:2]")
  u_ovl_intf_assert_1b7c5bd709f5c1cd6ca875d5933ab686dc837638 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[0]  & ~dcu_store_bls_dc3[1]  ),
    .consequent_expr (~|dcu_store_bls_dc3[15:2]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[1]  & ~dcu_store_bls_dc3[2]   => ~|dcu_store_bls_dc3[15:3]")
  u_ovl_intf_assert_9ffef30c6fa484c92257ac3da8e862f05ebc1735 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[1]  & ~dcu_store_bls_dc3[2]  ),
    .consequent_expr (~|dcu_store_bls_dc3[15:3]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[2]  & ~dcu_store_bls_dc3[3]   => ~|dcu_store_bls_dc3[15:4]")
  u_ovl_intf_assert_fee3dddf3030b38254ce8f37c0e2c814a772e9d3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[2]  & ~dcu_store_bls_dc3[3]  ),
    .consequent_expr (~|dcu_store_bls_dc3[15:4]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[3]  & ~dcu_store_bls_dc3[4]   => ~|dcu_store_bls_dc3[15:5]")
  u_ovl_intf_assert_5beb24410198f175bfa34ce49244bfa1d80743fd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[3]  & ~dcu_store_bls_dc3[4]  ),
    .consequent_expr (~|dcu_store_bls_dc3[15:5]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[4]  & ~dcu_store_bls_dc3[5]   => ~|dcu_store_bls_dc3[15:6]")
  u_ovl_intf_assert_462cd3965f267a4eddf1fb4494416ab05d013fa0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[4]  & ~dcu_store_bls_dc3[5]  ),
    .consequent_expr (~|dcu_store_bls_dc3[15:6]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[5]  & ~dcu_store_bls_dc3[6]   => ~|dcu_store_bls_dc3[15:7]")
  u_ovl_intf_assert_d6de4be2d9724c71083ae78eaf6ae153ecd7e68a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[5]  & ~dcu_store_bls_dc3[6]  ),
    .consequent_expr (~|dcu_store_bls_dc3[15:7]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[6]  & ~dcu_store_bls_dc3[7]   => ~|dcu_store_bls_dc3[15:8]")
  u_ovl_intf_assert_9ebfbb2bbd5f3a81c50fe8f2cccd75a934e0f230 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[6]  & ~dcu_store_bls_dc3[7]  ),
    .consequent_expr (~|dcu_store_bls_dc3[15:8]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[7]  & ~dcu_store_bls_dc3[8]   => ~|dcu_store_bls_dc3[15:9]")
  u_ovl_intf_assert_c382b2f5e19615d4f491766f6c43715ceb0e92e0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[7]  & ~dcu_store_bls_dc3[8]  ),
    .consequent_expr (~|dcu_store_bls_dc3[15:9]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[8]  & ~dcu_store_bls_dc3[9]   => ~|dcu_store_bls_dc3[15:10]")
  u_ovl_intf_assert_eb4274496d19d4a1b840e9aa92094ec030e9b2a4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[8]  & ~dcu_store_bls_dc3[9]  ),
    .consequent_expr (~|dcu_store_bls_dc3[15:10]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[9]  & ~dcu_store_bls_dc3[10]  => ~|dcu_store_bls_dc3[15:11]")
  u_ovl_intf_assert_b9d9e9f0d98f9a288a899a26881009cf11072554 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[9]  & ~dcu_store_bls_dc3[10] ),
    .consequent_expr (~|dcu_store_bls_dc3[15:11]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[10] & ~dcu_store_bls_dc3[11]  => ~|dcu_store_bls_dc3[15:12]")
  u_ovl_intf_assert_9b44c3feb9cdce011b4949bc561addc0096f9aaf (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[10] & ~dcu_store_bls_dc3[11] ),
    .consequent_expr (~|dcu_store_bls_dc3[15:12]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[11] & ~dcu_store_bls_dc3[12]  => ~|dcu_store_bls_dc3[15:13]")
  u_ovl_intf_assert_6fa1617fb2740101f09d10c5badfe9c4636c0fc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[11] & ~dcu_store_bls_dc3[12] ),
    .consequent_expr (~|dcu_store_bls_dc3[15:13]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[12] & ~dcu_store_bls_dc3[13]  => ~|dcu_store_bls_dc3[15:14]")
  u_ovl_intf_assert_1eeb3b63f4dce6843be38c5fc4163a1040c51942 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[12] & ~dcu_store_bls_dc3[13] ),
    .consequent_expr (~|dcu_store_bls_dc3[15:14]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[13] & ~dcu_store_bls_dc3[14]  => ~dcu_store_bls_dc3[15]")
  u_ovl_intf_assert_620d639034ec5772aa27fdc53df359a35e0346e5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dcu_store_cp15_dc3 & dcu_store_bls_dc3[13] & ~dcu_store_bls_dc3[14] ),
    .consequent_expr (~dcu_store_bls_dc3[15]));


  // A non-mergeable store should always cause the STB to start draining.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_force_non_mergeable_dc3  => dcu_drain_entire_stb")
  u_ovl_intf_assert_e862bbefb37f12951a905d8ce92522d93c301326 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_force_non_mergeable_dc3 ),
    .consequent_expr (dcu_drain_entire_stb));


  // A store cannot be marked as non-mergeable, unless the store
  // is strongly ordered, a STREX, a STLR, an attribute mismatch
  // was detected, or the STB requested it to be.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_force_non_mergeable_dc3 & dcu_stb_req_dc3  => (dcu_stb_exclusive_dc3 | dcu_stlr_dc3 | dcu_store_cp15_dc3 | attr_mismatch_dc3 | stb_force_non_mergeable_dc3)")
  u_ovl_intf_assert_c4a02e1145a9b5cfffcaedf51e22bc22623d5cd6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_force_non_mergeable_dc3 & dcu_stb_req_dc3 ),
    .consequent_expr ((dcu_stb_exclusive_dc3 | dcu_stlr_dc3 | dcu_store_cp15_dc3 | attr_mismatch_dc3 | stb_force_non_mergeable_dc3)));


  // A CP15 op must be marked as non-mergeable, unless store buffer empty

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dpu_kill_wr & dcu_store_cp15_dc3 & |stb_slots_valid  => dcu_force_non_mergeable_dc3")
  u_ovl_intf_assert_9a94d5313e3df4c9139107ec2648189ae350eac1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dpu_kill_wr & dcu_store_cp15_dc3 & |stb_slots_valid ),
    .consequent_expr (dcu_force_non_mergeable_dc3));


  // A STREX must be marked as non-mergeable.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dpu_kill_wr & (dcu_stb_exclusive_dc3 & `CA53_MEM_SHAREABLE(dcu_stb_attrs_dc3)) & ~dcu_store_cp15_dc3  => dcu_force_non_mergeable_dc3")
  u_ovl_intf_assert_89d8e8775861cb0fa6f4774229f1b45c756c1cb8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dpu_kill_wr & (dcu_stb_exclusive_dc3 & `CA53_MEM_SHAREABLE(dcu_stb_attrs_dc3)) & ~dcu_store_cp15_dc3 ),
    .consequent_expr (dcu_force_non_mergeable_dc3));


  // An increase in busy slots can only be due to a new request.

  assert_implication #(`OVL_FATAL, INOPTIONS, "~(dcu_stb_req_dc3@1 & ~dpu_kill_wr@1)  => ~|(stb_slots_valid & ~stb_slots_valid@1)")
  u_ovl_intf_assume_bed12ca5f5158e9ef4327df02c6b42dc3a9fb06e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~(dcu_stb_req_dc3_reg & ~dpu_kill_wr_reg) ),
    .consequent_expr (~|(stb_slots_valid & ~stb_slots_valid_reg)));


  // A new request that is merging cannot cause an increase in busy slots.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_stb_req_dc3@1 & |dcu_store_merge_dc3@1  => ~|(stb_slots_valid & ~stb_slots_valid@1)")
  u_ovl_intf_assume_6756b1ddcca70232ee817d33a474f1da303c3a19 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3_reg & |dcu_store_merge_dc3_reg ),
    .consequent_expr (~|(stb_slots_valid & ~stb_slots_valid_reg)));


  // An increase in device slots can only be due to a new device or strongly ordered request.

  assert_implication #(`OVL_FATAL, INOPTIONS, "~(dcu_stb_req_dc3@1 & ~dpu_kill_wr@1 & ~`CA53_MEM_NORMAL(dcu_stb_attrs_dc3@1))  => ~|(stb_slots_dev_ng & ~stb_slots_dev_ng@1)")
  u_ovl_intf_assume_28f4629151fe6f91d47822653eda3f3168f0424a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~(dcu_stb_req_dc3_reg & ~dpu_kill_wr_reg & ~`CA53_MEM_NORMAL(dcu_stb_attrs_dc3_reg)) ),
    .consequent_expr (~|(stb_slots_dev_ng & ~stb_slots_dev_ng_reg)));


  // The STB has valid store slots.
  assign stb_has_store_slots  = |(stb_slots_valid & slots_store);

  // An increase in store slots can only be due to a new non-CP15 request.

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_has_store_slots & ~stb_has_store_slots@1  => dcu_stb_req_dc3@1 & ~dpu_kill_wr@1 & ~dcu_store_cp15_dc3@1")
  u_ovl_intf_assume_b82f9163ce16091c177587271823013af219b65a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_has_store_slots & ~stb_has_store_slots_reg ),
    .consequent_expr (dcu_stb_req_dc3_reg & ~dpu_kill_wr_reg & ~dcu_store_cp15_dc3_reg));


  // A shareable STREX cannot merge into another slot

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & ~dpu_kill_wr & dcu_stb_exclusive_dc3 & `CA53_MEM_SHAREABLE(dcu_stb_attrs_dc3)  => ~|dcu_store_merge_dc3")
  u_ovl_intf_assert_ade31b8e0bf01efb6b9fc8a0284e93dcd11fa4d2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & ~dpu_kill_wr & dcu_stb_exclusive_dc3 & `CA53_MEM_SHAREABLE(dcu_stb_attrs_dc3) ),
    .consequent_expr (~|dcu_store_merge_dc3));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    ongoing_cacheable_strex <= 1'b0;
  else if (store_accepted_dc3 | stb_cacheable_strex_done)
    ongoing_cacheable_strex <= (dcu_stb_req_dc3 & ~dpu_kill_wr & dcu_stb_exclusive_dc3 & `CA53_MEM_SHAREABLE(dcu_stb_attrs_dc3) & `CA53_MEM_COHERENT(dcu_stb_attrs_dc3));


  // A STREX cannot be done if there is not one in progress.

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_cacheable_strex_done  => ongoing_cacheable_strex")
  u_ovl_intf_assume_dcd55383235825932ea01f0733f04512cdae86d9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_cacheable_strex_done ),
    .consequent_expr (ongoing_cacheable_strex));


  // The STB cannot become empty until the STREX has completed.

  assert_implication #(`OVL_FATAL, INOPTIONS, "ongoing_cacheable_strex  => |stb_slots_valid")
  u_ovl_intf_assume_67c04c407a225418fd50b757bd3ac32ad421c612 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ongoing_cacheable_strex ),
    .consequent_expr (|stb_slots_valid));


  // A STREX that doesn't fail is done on the cycle that the last slot is going invalid

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_cacheable_strex_done@1 & ~stb_strex_failed@1  => ~|stb_slots_valid")
  u_ovl_intf_assume_e43a277d45de6299989102208053a99491f1a392 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_cacheable_strex_done_reg & ~stb_strex_failed_reg ),
    .consequent_expr (~|stb_slots_valid));


  // When a STREX is indicated as done, it will leave the STB on the same cycle.

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_cacheable_strex_done  => |stb_slots_emptying")
  u_ovl_intf_assume_d806b631dd69adb7c3c79b9b379896de11435ff7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_cacheable_strex_done ),
    .consequent_expr (|stb_slots_emptying));


  // CP15 operations store the operation type in the byte strobes.
  assign cp15_op_type  = dcu_store_bls_dc3[7:0];

  assign cp15_op_type_bp  = ((cp15_op_type == `CA53_CPOP_8_BPIALLIS) | (cp15_op_type ==  `CA53_CPOP_8_BPIMVA));

  assign cp15_op_type_ic  = ((cp15_op_type == `CA53_CPOP_8_ICIALLUIS) | (cp15_op_type ==  `CA53_CPOP_8_ICIALLU) | (cp15_op_type ==  `CA53_CPOP_8_ICIMVAU));

  assign cp15_op_type_dc  = ((cp15_op_type == `CA53_CPOP_8_DCIMVAC) | (cp15_op_type ==  `CA53_CPOP_8_DCISW) | (cp15_op_type ==  `CA53_CPOP_8_DCCMVAC) | (cp15_op_type ==  `CA53_CPOP_8_DCCSW) | (cp15_op_type ==  `CA53_CPOP_8_DCCMVAU) | (cp15_op_type ==  `CA53_CPOP_8_DCCIMVAC) | (cp15_op_type ==  `CA53_CPOP_8_DCCISW));

  // The DCU only sends barriers that affect stores to the STB.
  assign cp15_op_type_bar  = ((cp15_op_type == `CA53_CPOP_8_DSBNS) | (cp15_op_type ==  `CA53_CPOP_8_DSBIS) | (cp15_op_type ==  `CA53_CPOP_8_DSBOS) | (cp15_op_type ==  `CA53_CPOP_8_DSBSY) | (cp15_op_type ==  `CA53_CPOP_8_DMBNS) | (cp15_op_type ==  `CA53_CPOP_8_DMBIS) | (cp15_op_type ==  `CA53_CPOP_8_DMBOS) | (cp15_op_type ==  `CA53_CPOP_8_DMBSY) | (cp15_op_type ==  `CA53_CPOP_8_DMBNSST) | (cp15_op_type ==  `CA53_CPOP_8_DMBISST) | (cp15_op_type ==  `CA53_CPOP_8_DMBOSST) | (cp15_op_type ==  `CA53_CPOP_8_DMBSYST));

  assign cp15_op_type_tlb_aa32  = ((cp15_op_type == `CA53_CPOP_8_TLBIALL) | (cp15_op_type ==  `CA53_CPOP_8_TLBIALLIS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIMVA) | (cp15_op_type ==  `CA53_CPOP_8_TLBIMVAIS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIASID) | (cp15_op_type ==  `CA53_CPOP_8_TLBIASIDIS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIMVAA) | (cp15_op_type ==  `CA53_CPOP_8_TLBIMVAAIS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIMVAH) | (cp15_op_type ==  `CA53_CPOP_8_TLBIMVAHIS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIALLH) | (cp15_op_type ==  `CA53_CPOP_8_TLBIALLHIS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIALLNSNH) | (cp15_op_type ==  `CA53_CPOP_8_TLBIALLNSNHIS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIMVAL) | (cp15_op_type ==  `CA53_CPOP_8_TLBIMVALIS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIMVAAL) | (cp15_op_type ==  `CA53_CPOP_8_TLBIMVAALIS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIMVALH) | (cp15_op_type ==  `CA53_CPOP_8_TLBIMVALHIS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIIPAS2) | (cp15_op_type ==  `CA53_CPOP_8_TLBIIPAS2IS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIIPAS2L) | (cp15_op_type ==  `CA53_CPOP_8_TLBIIPAS2LIS));

  assign cp15_op_type_tlb_aa64  = ((cp15_op_type == `CA53_CPOP_8_TLBIVAE1) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVAE1IS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVALE1) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVALE1IS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVAAE1) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVAAE1IS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVAALE1) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVAALE1IS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIIPAS2E1) | (cp15_op_type ==  `CA53_CPOP_8_TLBIIPAS2E1IS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIIPAS2LE1) | (cp15_op_type ==  `CA53_CPOP_8_TLBIIPAS2LE1IS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVAE2) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVAE2IS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVALE2) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVALE2IS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVAE3) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVAE3IS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVALE3) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVALE3IS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIASIDE1) | (cp15_op_type ==  `CA53_CPOP_8_TLBIASIDE1IS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVMALLE1) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVMALLE1IS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVMALLS12E1) | (cp15_op_type ==  `CA53_CPOP_8_TLBIVMALLS12E1IS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIALLE1) | (cp15_op_type ==  `CA53_CPOP_8_TLBIALLE1IS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIALLE2) | (cp15_op_type ==  `CA53_CPOP_8_TLBIALLE2IS) | (cp15_op_type ==  `CA53_CPOP_8_TLBIALLE3) | (cp15_op_type ==  `CA53_CPOP_8_TLBIALLE3IS));



  // Only a limited set of CP15 op encodings are possible

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & dcu_store_cp15_dc3  => cp15_op_type_tlb_aa32 | cp15_op_type_tlb_aa64 | cp15_op_type_dc | cp15_op_type_ic | cp15_op_type_bp | cp15_op_type_bar")
  u_ovl_intf_assert_8f559368625797274930c54ba45a4cb2f3739aeb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & dcu_store_cp15_dc3 ),
    .consequent_expr (cp15_op_type_tlb_aa32 | cp15_op_type_tlb_aa64 | cp15_op_type_dc | cp15_op_type_ic | cp15_op_type_bp | cp15_op_type_bar));


  // A CP15 op cannot merge into another slot.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & dcu_store_cp15_dc3  => ~|dcu_store_merge_dc3")
  u_ovl_intf_assert_728aa2e77759e88d8ea6007e1ef817f1e4759c9d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & dcu_store_cp15_dc3 ),
    .consequent_expr (~|dcu_store_merge_dc3));


  // All dcache ops to the PoC should have WB attributes.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & dcu_store_cp15_dc3 & dcu_store_bls_dc3[7:0] in [`CA53_CPOP_8_DCISW, `CA53_CPOP_8_DCCSW, `CA53_CPOP_8_DCCISW, `CA53_CPOP_8_DCIMVAC, `CA53_CPOP_8_DCCMVAC, `CA53_CPOP_8_DCCIMVAC]  => (`CA53_MEM_WB(dcu_stb_attrs_dc3) & `CA53_MEM_OUTER_WB(dcu_stb_attrs_dc3))")
  u_ovl_intf_assert_dbc8351b5d3e809150072adbc6ad796013e9ecb8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & dcu_store_cp15_dc3 & ((dcu_store_bls_dc3[7:0] == `CA53_CPOP_8_DCISW) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DCCSW) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DCCISW) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DCIMVAC) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DCCMVAC) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DCCIMVAC)) ),
    .consequent_expr ((`CA53_MEM_WB(dcu_stb_attrs_dc3) & `CA53_MEM_OUTER_WB(dcu_stb_attrs_dc3))));


  // All dcache ops to the PoU should have outer NC attributes.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3 & dcu_store_cp15_dc3 & (dcu_store_bls_dc3[7:0] == `CA53_CPOP_8_DCCMVAU)  => (`CA53_MEM_WB(dcu_stb_attrs_dc3) & `CA53_MEM_OUTER_NC(dcu_stb_attrs_dc3))")
  u_ovl_intf_assert_260bcb4f93ab5e898d69555911a5eb0d0dac5911 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3 & dcu_store_cp15_dc3 & (dcu_store_bls_dc3[7:0] == `CA53_CPOP_8_DCCMVAU) ),
    .consequent_expr ((`CA53_MEM_WB(dcu_stb_attrs_dc3) & `CA53_MEM_OUTER_NC(dcu_stb_attrs_dc3))));


  // The DCU cannot put a non-CP15 store in to the STB on the cycle after putting
  // a CP15 in to the STB.
  assign barrier_dc3  = dcu_stb_req_dc3 & dcu_store_cp15_dc3 & (((dcu_store_bls_dc3[7:0] == `CA53_CPOP_8_DSBNS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DSBIS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DSBOS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DSBSY) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBNS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBIS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBOS) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBSY) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBNSST) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBISST) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBOSST) | (dcu_store_bls_dc3[7:0] ==  `CA53_CPOP_8_DMBSYST)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_req_dc3@1 & dcu_store_cp15_dc3@1 & ~barrier_dc3@1  => ~(dcu_stb_req_dc3 & ~dcu_store_cp15_dc3)")
  u_ovl_intf_assert_f53bd34f5d1f66a29536f0980a46c4013e2a0985 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_req_dc3_reg & dcu_store_cp15_dc3_reg & ~barrier_dc3_reg ),
    .consequent_expr (~(dcu_stb_req_dc3 & ~dcu_store_cp15_dc3)));


  //-----------------------------------------------------------------------------
  //
  // STB to DCU cache arbiter tag lookup/write
  //
  //-----------------------------------------------------------------------------

  // The STB wishes to start a new tag access.
  // If it is not accepted, the STB may choose to abandon the request next cycle.
  //  input stb_cache_tag_req_m0 valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "stb_cache_tag_req_m0 X or Z")
  u_ovl_intf_x_stb_cache_tag_req_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_cache_tag_req_m0));


  // The access is a write.
  //  input stb_cache_tag_wr_m0 valid stb_cache_tag_req_m0 timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "stb_cache_tag_wr_m0 X or Z")
  u_ovl_intf_x_stb_cache_tag_wr_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_cache_tag_req_m0),
    .test_expr (stb_cache_tag_wr_m0));


  // The ways to access.
  //  input [3:0] stb_cache_tag_way_m0 valid stb_cache_tag_req_m0 timing 70%

  assert_never_unknown #(`OVL_FATAL, 4, INOPTIONS, "stb_cache_tag_way_m0 X or Z")
  u_ovl_intf_x_stb_cache_tag_way_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_cache_tag_req_m0),
    .test_expr (stb_cache_tag_way_m0));


  // The address of the tag access.
  //  input [39:6] stb_cache_tag_addr_m0 valid stb_cache_tag_req_m0 timing 70%

  assert_never_unknown #(`OVL_FATAL, 34, INOPTIONS, "stb_cache_tag_addr_m0 X or Z")
  u_ovl_intf_x_stb_cache_tag_addr_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_cache_tag_req_m0),
    .test_expr (stb_cache_tag_addr_m0));


  // The TrustZone nonsecure state of the access.
  //  input stb_cache_tag_ns_dsc_m0 valid stb_cache_tag_req_m0 timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "stb_cache_tag_ns_dsc_m0 X or Z")
  u_ovl_intf_x_stb_cache_tag_ns_dsc_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_cache_tag_req_m0),
    .test_expr (stb_cache_tag_ns_dsc_m0));



  // The cache arbitration will give priority to the STB this cycle (i.e. no
  // higher priority source has requested access).
  // If set and the STB makes a request then the request will be accepted and
  // the STB should deassert stb_cache_tag_req_m0 in the next cycle (unless
  // it wishes to make another request).
  //  output dcu_stb_tag_has_priority_m0 valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_stb_tag_has_priority_m0 X or Z")
  u_ovl_intf_x_dcu_stb_tag_has_priority_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_stb_tag_has_priority_m0));


  // The tag request is in m1 and has not been delayed due to a read request.
  // The RAMs will be enabled this cycle, and the result will be available in
  // the next cycle.
  //  output dcu_stb_tag_ack_m1 valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_stb_tag_ack_m1 X or Z")
  u_ovl_intf_x_dcu_stb_tag_ack_m1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_stb_tag_ack_m1));


  // The result of the lookup.
  //  output [3:0] dcu_stb_tag_hit_m2 valid lookup_in_m1@1 & dcu_stb_tag_ack_m1@1 timing 80%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "dcu_stb_tag_hit_m2 X or Z")
  u_ovl_intf_x_dcu_stb_tag_hit_m2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (lookup_in_m1_reg & dcu_stb_tag_ack_m1_reg),
    .test_expr (dcu_stb_tag_hit_m2));


  // The MOESI state of the way that hit was shared.
  //  output dcu_stb_tag_shared_m2 valid lookup_in_m1@1 & dcu_stb_tag_ack_m1@1 timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_stb_tag_shared_m2 X or Z")
  u_ovl_intf_x_dcu_stb_tag_shared_m2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (lookup_in_m1_reg & dcu_stb_tag_ack_m1_reg),
    .test_expr (dcu_stb_tag_shared_m2));


  // The migratory status of the line that hit.
  //  output dcu_stb_tag_migratory_m2 valid lookup_in_m1@1 & dcu_stb_tag_ack_m1@1 timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_stb_tag_migratory_m2 X or Z")
  u_ovl_intf_x_dcu_stb_tag_migratory_m2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (lookup_in_m1_reg & dcu_stb_tag_ack_m1_reg),
    .test_expr (dcu_stb_tag_migratory_m2));


  // The victim way to perform linefill to if the lookup failed.
  //  output [3:0] dcu_stb_victim_way_m2 valid lookup_in_m1@1 & dcu_stb_tag_ack_m1@1 timing 85%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "dcu_stb_victim_way_m2 X or Z")
  u_ovl_intf_x_dcu_stb_victim_way_m2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (lookup_in_m1_reg & dcu_stb_tag_ack_m1_reg),
    .test_expr (dcu_stb_victim_way_m2));


  // There is an ECC error in Data
  //  output dcu_ecc_data_err_m3 valid read_in_m1@2 & dcu_stb_data_ack_m1@2 timing 55%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_ecc_data_err_m3 X or Z")
  u_ovl_intf_x_dcu_ecc_data_err_m3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (read_in_m1_reg_reg & dcu_stb_data_ack_m1_reg_reg),
    .test_expr (dcu_ecc_data_err_m3));


  // There is an ECC error in Tag
  //  output dcu_ecc_tag_err_m2 valid lookup_in_m1@1 & dcu_stb_tag_ack_m1@1 timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_ecc_tag_err_m2 X or Z")
  u_ovl_intf_x_dcu_ecc_tag_err_m2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (lookup_in_m1_reg & dcu_stb_tag_ack_m1_reg),
    .test_expr (dcu_ecc_tag_err_m2));


  // ECC Error Correction State machine is in progress
  //  output dcu_ecc_in_progress valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_ecc_in_progress X or Z")
  u_ovl_intf_x_dcu_ecc_in_progress (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_ecc_in_progress));


  // At least one way in the request must be set.

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_cache_tag_req_m0  => |stb_cache_tag_way_m0")
  u_ovl_intf_assume_5e1ea59c4719d04a22fe2b3a747b07ce6c7283c5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_cache_tag_req_m0 ),
    .consequent_expr (|stb_cache_tag_way_m0));


  // Can only make request when STB contains a store

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_cache_tag_req_m0  => |(stb_slots_valid & slots_store)")
  u_ovl_intf_assume_ece84e2973bac04662d7ee52faceb525143fc79a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_cache_tag_req_m0 ),
    .consequent_expr (|(stb_slots_valid & slots_store)));


  // For writes, only one way should be set.

  assert_zero_one_hot #(`OVL_FATAL, 4, INOPTIONS, "{4{stb_cache_tag_req_m0 & stb_cache_tag_wr_m0}} & stb_cache_tag_way_m0")
  u_ovl_intf_assume_35ba24085740593b475332318e72a0dceac37966 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ({4{stb_cache_tag_req_m0 & stb_cache_tag_wr_m0}} & stb_cache_tag_way_m0));


  // For lookups, all ways must be set.

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_cache_tag_req_m0 & ~stb_cache_tag_wr_m0  => &stb_cache_tag_way_m0")
  u_ovl_intf_assume_4b89d08d4482d301d6642d596da93bdcabaa920c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_cache_tag_req_m0 & ~stb_cache_tag_wr_m0 ),
    .consequent_expr (&stb_cache_tag_way_m0));


  // Cannot have multiple ways hitting unless there's an ECC error.

  assert_zero_one_hot #(`OVL_FATAL, 4, OUTOPTIONS, "{4{lookup_in_m1@1 & dcu_stb_tag_ack_m1@1 & ~(dcu_ecc_tag_err_m2 & (CPU_CACHE_PROTECTION != 0))}} & dcu_stb_tag_hit_m2")
  u_ovl_intf_assert_6665d44e1d7fd94ebeaa607f310911677815070b (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ({4{lookup_in_m1_reg & dcu_stb_tag_ack_m1_reg & ~(dcu_ecc_tag_err_m2 & (CPU_CACHE_PROTECTION != 0))}} & dcu_stb_tag_hit_m2));


  // Cannot have multiple victim ways unless there's an ECC error.

  assert_zero_one_hot #(`OVL_FATAL, 4, OUTOPTIONS, "{4{lookup_in_m1@1 & dcu_stb_tag_ack_m1@1 & ~(dcu_ecc_tag_err_m2 & (CPU_CACHE_PROTECTION != 0))}} & dcu_stb_victim_way_m2")
  u_ovl_intf_assert_4c18657494b176e29ed3bdc2b393db65b0768539 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ({4{lookup_in_m1_reg & dcu_stb_tag_ack_m1_reg & ~(dcu_ecc_tag_err_m2 & (CPU_CACHE_PROTECTION != 0))}} & dcu_stb_victim_way_m2));


  // The DCU starts indicating that an ECC correction is in progress in M3.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_ecc_tag_err_m2@1 & lookup_in_m1@2 & dcu_stb_tag_ack_m1@2  => dcu_ecc_in_progress")
  u_ovl_intf_assert_b992f3ecc585a56c5d751a7a6d00a500823f7d88 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_ecc_tag_err_m2_reg & lookup_in_m1_reg_reg & dcu_stb_tag_ack_m1_reg_reg ),
    .consequent_expr (dcu_ecc_in_progress));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_ecc_data_err_m3 & read_in_m1@2 & dcu_stb_data_ack_m1@2  => dcu_ecc_in_progress")
  u_ovl_intf_assert_c5810af9742fbf49a58b7ccde14bbf388c6603f1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_ecc_data_err_m3 & read_in_m1_reg_reg & dcu_stb_data_ack_m1_reg_reg ),
    .consequent_expr (dcu_ecc_in_progress));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    out_of_reset <= 1'b0;
  else
    out_of_reset <= 1;


  // An ECC corection stays in progress for at least 2 cycles.
  // The STB relies on this for efficient lock-step of slots in the same line.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "out_of_reset@1 & dcu_ecc_in_progress@1 & ~dcu_ecc_in_progress@2  => dcu_ecc_in_progress")
  u_ovl_intf_assert_24db2939b055cd6e6867c7da97f3c09efc3b6748 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (out_of_reset_reg & dcu_ecc_in_progress_reg & ~dcu_ecc_in_progress_reg_reg ),
    .consequent_expr (dcu_ecc_in_progress));


  // Must have one victim way.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "lookup_in_m1@1 & dcu_stb_tag_ack_m1@1  => |dcu_stb_victim_way_m2")
  u_ovl_intf_assert_395c1f685ba8ba2828c2b81c080e0d6002075759 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (lookup_in_m1_reg & dcu_stb_tag_ack_m1_reg ),
    .consequent_expr (|dcu_stb_victim_way_m2));


  // A line can only be shared if it hit.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "lookup_in_m1@1 & dcu_stb_tag_ack_m1@1 & dcu_stb_tag_shared_m2  => |dcu_stb_tag_hit_m2")
  u_ovl_intf_assert_b8f966ec7a3953516e062e72237aa32298677737 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (lookup_in_m1_reg & dcu_stb_tag_ack_m1_reg & dcu_stb_tag_shared_m2 ),
    .consequent_expr (|dcu_stb_tag_hit_m2));


  // A line can only be migratory if it hit.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "lookup_in_m1@1 & dcu_stb_tag_ack_m1@1 & dcu_stb_tag_migratory_m2  => |dcu_stb_tag_hit_m2")
  u_ovl_intf_assert_50f4afceb39f3e6b139c91d4aaffc0de7c974113 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (lookup_in_m1_reg & dcu_stb_tag_ack_m1_reg & dcu_stb_tag_migratory_m2 ),
    .consequent_expr (|dcu_stb_tag_hit_m2));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    tag_write_in_m1 <= 1'b0;
  else if (dcu_stb_tag_ack_m1 | ~tag_write_in_m1)
    tag_write_in_m1 <= stb_cache_tag_req_m0 & stb_cache_tag_wr_m0 & dcu_stb_tag_has_priority_m0;



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    lookup_in_m1 <= 1'b0;
  else if (dcu_stb_tag_ack_m1 | ~lookup_in_m1)
    lookup_in_m1 <= stb_cache_tag_req_m0 & ~stb_cache_tag_wr_m0 & dcu_stb_tag_has_priority_m0;


  // The DCU cannot accept a new request if the previous one is stalled.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(tag_write_in_m1 | lookup_in_m1) & ~dcu_stb_tag_ack_m1  => ~dcu_stb_tag_has_priority_m0")
  u_ovl_intf_assert_8089e9389f57bcd30eb73327d127d60847bff634 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((tag_write_in_m1 | lookup_in_m1) & ~dcu_stb_tag_ack_m1 ),
    .consequent_expr (~dcu_stb_tag_has_priority_m0));


  // The DCU must not acknowledge if there was no request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_tag_ack_m1  => tag_write_in_m1 | lookup_in_m1")
  u_ovl_intf_assert_e4e25866d366ca34fe4867abdef461632c3086ed (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_tag_ack_m1 ),
    .consequent_expr (tag_write_in_m1 | lookup_in_m1));


  //-----------------------------------------------------------------------------
  //
  // STB to DCU cache arbiter data read/write and dirty write
  //
  //-----------------------------------------------------------------------------

  // The STB wishes to start a new write request to the data and dirty RAMs or
  // a read request to the data RAM. It may do this in the same cycle as a tag
  // access for a different slot.
  //  input stb_cache_data_req_m0 valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "stb_cache_data_req_m0 X or Z")
  u_ovl_intf_x_stb_cache_data_req_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_cache_data_req_m0));


  // The access is a write.
  //  input stb_cache_data_wr_m0 valid stb_cache_data_req_m0 timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "stb_cache_data_wr_m0 X or Z")
  u_ovl_intf_x_stb_cache_data_wr_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_cache_data_req_m0),
    .test_expr (stb_cache_data_wr_m0));


  // The index to access.
  //  input [13:4] stb_cache_data_addr_m0 valid stb_cache_data_req_m0 timing 70%

  assert_never_unknown #(`OVL_FATAL, 10, INOPTIONS, "stb_cache_data_addr_m0 X or Z")
  u_ovl_intf_x_stb_cache_data_addr_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_cache_data_req_m0),
    .test_expr (stb_cache_data_addr_m0));


  // The way to access.
  //  input [3:0] stb_cache_data_way_m0 valid stb_cache_data_req_m0 timing 70%

  assert_never_unknown #(`OVL_FATAL, 4, INOPTIONS, "stb_cache_data_way_m0 X or Z")
  u_ovl_intf_x_stb_cache_data_way_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_cache_data_req_m0),
    .test_expr (stb_cache_data_way_m0));


  // The write data (for when stb_cache_data_wr_m0 is asserted)
  //  input [127:0] stb_cache_write_data_m0 valid mask write_bls_m0 timing 40%

  assert_never_unknown #(`OVL_FATAL, 128, INOPTIONS, "stb_cache_write_data_m0 & (write_bls_m0) X or Z")
  u_ovl_intf_x_0432a4166dfbad76312fd93458cf14a02e57f9c4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_cache_write_data_m0 & (write_bls_m0)));


  // The byte lane strobes of the data.
  //  input [15:0] stb_cache_data_bls_m0 valid stb_cache_data_req_m0 timing 70%

  assert_never_unknown #(`OVL_FATAL, 16, INOPTIONS, "stb_cache_data_bls_m0 X or Z")
  u_ovl_intf_x_stb_cache_data_bls_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_cache_data_req_m0),
    .test_expr (stb_cache_data_bls_m0));


  // The attributes to write to the dirty RAM on a data write.
  //  input [7:0] stb_cache_data_attrs_m0 valid (stb_cache_data_req_m0 & stb_cache_data_wr_m0) timing 70%

  assert_never_unknown #(`OVL_FATAL, 8, INOPTIONS, "stb_cache_data_attrs_m0 X or Z")
  u_ovl_intf_x_stb_cache_data_attrs_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier ((stb_cache_data_req_m0 & stb_cache_data_wr_m0)),
    .test_expr (stb_cache_data_attrs_m0));


  // The migratory status of the line, used when updating the dirty RAM on a data write.
  //  input stb_cache_data_migratory_m0 valid (stb_cache_data_req_m0 & stb_cache_data_wr_m0) timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "stb_cache_data_migratory_m0 X or Z")
  u_ovl_intf_x_stb_cache_data_migratory_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier ((stb_cache_data_req_m0 & stb_cache_data_wr_m0)),
    .test_expr (stb_cache_data_migratory_m0));


  // The data arbitration will give priority to the STB this cycle (i.e. no
  // higher priority source has requested access).
  // If set and the STB makes a request then the request will be accepted and
  // the STB should deassert stb_cache_data_req_m0 in the next cycle (unless
  // it wishes to make another request).
  //  output dcu_stb_data_has_priority_m0 valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_stb_data_has_priority_m0 X or Z")
  u_ovl_intf_x_dcu_stb_data_has_priority_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_stb_data_has_priority_m0));


  // The write request is in m1 and has not been delayed due to a read request.
  // The data will be written to the RAMs this cycle.
  //  output dcu_stb_data_ack_m1 valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_stb_data_ack_m1 X or Z")
  u_ovl_intf_x_dcu_stb_data_ack_m1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_stb_data_ack_m1));




  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    force_lf_merge <= {5{1'b0}};
  else
    force_lf_merge <= (stb_lf_merge & biu_lf_can_merge & biu_ev_hazard) | (stb_slots_valid & force_lf_merge);


  assign write_bls_m0  = {128{stb_cache_data_req_m0 & stb_cache_data_wr_m0}} & (((CPU_CACHE_PROTECTION != 0) & ~|force_lf_merge) ? {{32{|stb_cache_data_bls_m0[15:12]}}, {32{|stb_cache_data_bls_m0[11:8]}}, {32{|stb_cache_data_bls_m0[7:4]}}, {32{|stb_cache_data_bls_m0[3:0]}}} : {{8{stb_cache_data_bls_m0[15]}}, {8{stb_cache_data_bls_m0[14]}}, {8{stb_cache_data_bls_m0[13]}}, {8{stb_cache_data_bls_m0[12]}}, {8{stb_cache_data_bls_m0[11]}}, {8{stb_cache_data_bls_m0[10]}}, {8{stb_cache_data_bls_m0[9]}}, {8{stb_cache_data_bls_m0[8]}}, {8{stb_cache_data_bls_m0[7]}}, {8{stb_cache_data_bls_m0[6]}}, {8{stb_cache_data_bls_m0[5]}}, {8{stb_cache_data_bls_m0[4]}}, {8{stb_cache_data_bls_m0[3]}}, {8{stb_cache_data_bls_m0[2]}}, {8{stb_cache_data_bls_m0[1]}}, {8{stb_cache_data_bls_m0[0]}}});


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    write_in_m1 <= 1'b0;
  else if (dcu_stb_data_ack_m1 | ~write_in_m1)
    write_in_m1 <= stb_cache_data_req_m0 & stb_cache_data_wr_m0 & dcu_stb_data_has_priority_m0;



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_in_m1 <= 1'b0;
  else if (dcu_stb_data_ack_m1 | ~read_in_m1)
    read_in_m1 <= stb_cache_data_req_m0 & ~stb_cache_data_wr_m0 & dcu_stb_data_has_priority_m0;



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_bls_m1 <= {128{1'b0}};
  else if (dcu_stb_data_ack_m1 | ~read_in_m1)
    read_bls_m1 <= ({128{stb_cache_data_req_m0 & ~stb_cache_data_wr_m0 & dcu_stb_data_has_priority_m0}} & {{32{|stb_cache_data_bls_m0[15:12]}}, {32{|stb_cache_data_bls_m0[11:8]}}, {32{|stb_cache_data_bls_m0[7:4]}}, {32{|stb_cache_data_bls_m0[3:0]}}});



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_bls_m2 <= {128{1'b0}};
  else
    read_bls_m2 <= {128{read_in_m1 & dcu_stb_data_ack_m1}} & read_bls_m1;


  // Read data is provided the cycle after the request is acknowledged.
  //  output [127:0] dcu_stb_read_data_m2 valid mask read_bls_m2 timing 50%

  assert_never_unknown #(`OVL_FATAL, 128, OUTOPTIONS, "dcu_stb_read_data_m2 & (read_bls_m2) X or Z")
  u_ovl_intf_x_1f35f528b61a0d4b583f1893c76daae6ffd00589 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_stb_read_data_m2 & (read_bls_m2)));


  // The BLS should never be zero for a write.

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_cache_data_req_m0  => |stb_cache_data_bls_m0")
  u_ovl_intf_assume_be70fe98077463759ae6ba17a683ab5ad46e9ba7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_cache_data_req_m0 ),
    .consequent_expr (|stb_cache_data_bls_m0));


  // At least one way in the request must be set.

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_cache_data_req_m0  => |stb_cache_data_way_m0")
  u_ovl_intf_assume_cf226719de049f691a46c3c24f4342d038686622 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_cache_data_req_m0 ),
    .consequent_expr (|stb_cache_data_way_m0));


  // Cannot access to multiple ways.

  assert_zero_one_hot #(`OVL_FATAL, 4, INOPTIONS, "{4{stb_cache_data_req_m0}} & stb_cache_data_way_m0")
  u_ovl_intf_assume_ea19fdf319dc4818b5a7d1bff7c4f612465e8958 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ({4{stb_cache_data_req_m0}} & stb_cache_data_way_m0));


  // Can only make request when a slot is active and contains a store.

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_cache_data_req_m0  => |(stb_slots_valid & slots_store)")
  u_ovl_intf_assume_bceb9bcbbd7a203aa1650e9633f46696a04e5997 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_cache_data_req_m0 ),
    .consequent_expr (|(stb_slots_valid & slots_store)));


  // The DCU cannot accept a new request if the previous one is stalled.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(write_in_m1 | read_in_m1) & ~dcu_stb_data_ack_m1  => ~dcu_stb_data_has_priority_m0")
  u_ovl_intf_assert_c8cc3413dd8a06b938989f08ef8d01745e8d13de (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((write_in_m1 | read_in_m1) & ~dcu_stb_data_ack_m1 ),
    .consequent_expr (~dcu_stb_data_has_priority_m0));


  // The DCU must not acknowledge if there was no request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_stb_data_ack_m1  => write_in_m1 | read_in_m1")
  u_ovl_intf_assert_237ec9f346922e48f5953c16ab6aa4eb1afe6ced (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_stb_data_ack_m1 ),
    .consequent_expr (write_in_m1 | read_in_m1));


  //-----------------------------------------------------------------------------
  //
  // DCU CCB to STB (for hazard checking)
  //
  //-----------------------------------------------------------------------------

  // There is a valid CCB request in the DCU
  //  output dcu_ccb_req_valid valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_ccb_req_valid X or Z")
  u_ovl_intf_x_dcu_ccb_req_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_ccb_req_valid));


  // The index that the CCB request is for.
  //  output [13:6] dcu_ccb_index valid dcu_ccb_req_valid timing 20%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "dcu_ccb_index X or Z")
  u_ovl_intf_x_dcu_ccb_index (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_ccb_req_valid),
    .test_expr (dcu_ccb_index));


  // The way that the CCB request is for.
  //  output [3:0] dcu_ccb_ways valid dcu_ccb_req_valid timing 20%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "dcu_ccb_ways X or Z")
  u_ovl_intf_x_dcu_ccb_ways (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_ccb_req_valid),
    .test_expr (dcu_ccb_ways));


  // The index/way matches a line that the STB is part way through a tag or data
  // write for and so the DCU should prevent the CCB from starting.
  //  input stb_block_ccb valid dcu_ccb_req_valid timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "stb_block_ccb X or Z")
  u_ovl_intf_x_stb_block_ccb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_ccb_req_valid),
    .test_expr (stb_block_ccb));


  // The STB is trying to send data to the BIU but the BIU is not accepting the
  // request this cycle, potentially due to a CCB data transfer having higher
  // priority for the write channel. If the DCU is performing a CCB data transfer
  // then it should defer accepting the next snoop request until the STB makes
  // progress.
  //  input stb_defer_ccb valid always timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "stb_defer_ccb X or Z")
  u_ovl_intf_x_stb_defer_ccb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_defer_ccb));


  // CCB requests are for one way only.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_ccb_req_valid  => dcu_ccb_ways in [4'b0001, 4'b0010, 4'b0100, 4'b1000]")
  u_ovl_intf_assert_2cfb412c69e17af65c72b254d86f7cf245cacdf6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_ccb_req_valid ),
    .consequent_expr (((dcu_ccb_ways == 4'b0001) | (dcu_ccb_ways ==  4'b0010) | (dcu_ccb_ways ==  4'b0100) | (dcu_ccb_ways ==  4'b1000))));



endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_dcu_stb_defs.v"
`undef CA53_UNDEFINE

`endif

