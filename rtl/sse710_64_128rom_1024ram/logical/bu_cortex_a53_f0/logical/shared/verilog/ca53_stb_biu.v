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


// This is the specification for the interface between the STB and the BIU for
// starting linefills and doing non-cacheable writes.
// Inputs and outputs are from the point of view of the STB.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_stb_biu_defs.v"
`include "cortexa53params.v"
`include "cortexa53params.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_dcu_stb_defs.v"

module ca53_stb_biu #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input   [4:0] biu_lf_hazard_i,
  input   [4:0] biu_lf_real_hazard_i,
  input   [4:0] biu_lf_hazard_migratory_i,
  input   [1:0] biu_lf_hazard_way_slot0_i,
  input   [1:0] biu_lf_hazard_way_slot1_i,
  input   [1:0] biu_lf_hazard_way_slot2_i,
  input   [1:0] biu_lf_hazard_way_slot3_i,
  input   [1:0] biu_lf_hazard_way_slot4_i,
  input   [4:0] biu_lf_serialized_i,
  input   [4:0] biu_ev_hazard_i,
  input   [4:0] biu_lf_can_merge_i,
  input         biu_stb_write_accept_i,
  input         biu_read_alloc_mode_i,
  input         biu_stb_ar_ack_i,
  input         biu_stb_ar_resp_valid_i,
  input   [1:0] biu_stb_ar_resp_i,
  input   [4:0] biu_stb_ar_resp_id_i,
  input   [3:0] biu_stb_ar_resp_l2dbid_i,
  input         biu_dirty_lf_in_progress_i,
  input         biu_excl_lf_in_progress_i,
  input         dcu_stb_req_dc3_i,
  input         dcu_store_cp15_dc3_i,
  input  [39:0] dcu_pa_dc3_i,
  input         dcu_ns_dsc_dc3_i,
  input         stb_cache_data_req_m0_i,
  input         stb_cache_data_wr_m0_i,
  input         dcu_stb_data_has_priority_m0_i,
  input         dcu_stb_data_ack_m1_i,
  input         scu_dvm_complete_i,
  input   [4:0] stb_slots_valid_i,
  input  [39:0] stb_slot0_addr_i,
  input  [39:0] stb_slot1_addr_i,
  input  [39:0] stb_slot2_addr_i,
  input  [39:0] stb_slot3_addr_i,
  input  [39:0] stb_slot4_addr_i,
  input   [4:0] stb_slots_ns_dsc_i,
  input   [1:0] stb_slot0_way_i,
  input   [1:0] stb_slot1_way_i,
  input   [1:0] stb_slot2_way_i,
  input   [1:0] stb_slot3_way_i,
  input   [1:0] stb_slot4_way_i,
  input   [7:0] stb_slot0_attrs_i,
  input   [7:0] stb_slot1_attrs_i,
  input   [7:0] stb_slot2_attrs_i,
  input   [7:0] stb_slot3_attrs_i,
  input   [7:0] stb_slot4_attrs_i,
  input         stb_lf_active_i,
  input   [4:0] stb_lf_req_i,
  input   [4:0] stb_lf_earliest_slot_i,
  input   [4:0] stb_lf_merge_i,
  input   [4:0] stb_slot_cachewrite_m1_i,
  input         stb_biu_write_req_i,
  input   [3:0] stb_biu_write_l2dbid_i,
  input   [1:0] stb_biu_write_chunk_i,
  input [127:0] stb_biu_write_data_i,
  input  [15:0] stb_biu_write_bls_i,
  input         stb_biu_write_last_i,
  input         stb_biu_write_req_active_i,
  input         stb_ar_req_i,
  input         stb_ar_early_req_i,
  input   [4:0] stb_ar_id_i,
  input   [1:0] stb_ar_way_i,
  input   [7:0] stb_ar_type_i,
  input  [39:0] stb_ar_addr_i,
  input         stb_ar_ns_dsc_i,
  input   [7:0] stb_ar_attrs_i,
  input         stb_ar_priv_i,
  input         stb_ar_excl_i,
  input  [15:0] stb_ar_asid_i,
  input   [7:0] stb_ar_vmid_i,
  input  [24:0] stb_ar_va_i);


  wire   [4:0] biu_lf_hazard = biu_lf_hazard_i;
  wire   [4:0] biu_lf_real_hazard = biu_lf_real_hazard_i;
  wire   [4:0] biu_lf_hazard_migratory = biu_lf_hazard_migratory_i;
  wire   [1:0] biu_lf_hazard_way_slot0 = biu_lf_hazard_way_slot0_i;
  wire   [1:0] biu_lf_hazard_way_slot1 = biu_lf_hazard_way_slot1_i;
  wire   [1:0] biu_lf_hazard_way_slot2 = biu_lf_hazard_way_slot2_i;
  wire   [1:0] biu_lf_hazard_way_slot3 = biu_lf_hazard_way_slot3_i;
  wire   [1:0] biu_lf_hazard_way_slot4 = biu_lf_hazard_way_slot4_i;
  wire   [4:0] biu_lf_serialized = biu_lf_serialized_i;
  wire   [4:0] biu_ev_hazard = biu_ev_hazard_i;
  wire   [4:0] biu_lf_can_merge = biu_lf_can_merge_i;
  wire         biu_stb_write_accept = biu_stb_write_accept_i;
  wire         biu_read_alloc_mode = biu_read_alloc_mode_i;
  wire         biu_stb_ar_ack = biu_stb_ar_ack_i;
  wire         biu_stb_ar_resp_valid = biu_stb_ar_resp_valid_i;
  wire   [1:0] biu_stb_ar_resp = biu_stb_ar_resp_i;
  wire   [4:0] biu_stb_ar_resp_id = biu_stb_ar_resp_id_i;
  wire   [3:0] biu_stb_ar_resp_l2dbid = biu_stb_ar_resp_l2dbid_i;
  wire         biu_dirty_lf_in_progress = biu_dirty_lf_in_progress_i;
  wire         biu_excl_lf_in_progress = biu_excl_lf_in_progress_i;
  wire         dcu_stb_req_dc3 = dcu_stb_req_dc3_i;
  wire         dcu_store_cp15_dc3 = dcu_store_cp15_dc3_i;
  wire  [39:0] dcu_pa_dc3 = dcu_pa_dc3_i;
  wire         dcu_ns_dsc_dc3 = dcu_ns_dsc_dc3_i;
  wire         stb_cache_data_req_m0 = stb_cache_data_req_m0_i;
  wire         stb_cache_data_wr_m0 = stb_cache_data_wr_m0_i;
  wire         dcu_stb_data_has_priority_m0 = dcu_stb_data_has_priority_m0_i;
  wire         dcu_stb_data_ack_m1 = dcu_stb_data_ack_m1_i;
  wire         scu_dvm_complete = scu_dvm_complete_i;
  wire   [4:0] stb_slots_valid = stb_slots_valid_i;
  wire  [39:0] stb_slot0_addr = stb_slot0_addr_i;
  wire  [39:0] stb_slot1_addr = stb_slot1_addr_i;
  wire  [39:0] stb_slot2_addr = stb_slot2_addr_i;
  wire  [39:0] stb_slot3_addr = stb_slot3_addr_i;
  wire  [39:0] stb_slot4_addr = stb_slot4_addr_i;
  wire   [4:0] stb_slots_ns_dsc = stb_slots_ns_dsc_i;
  wire   [1:0] stb_slot0_way = stb_slot0_way_i;
  wire   [1:0] stb_slot1_way = stb_slot1_way_i;
  wire   [1:0] stb_slot2_way = stb_slot2_way_i;
  wire   [1:0] stb_slot3_way = stb_slot3_way_i;
  wire   [1:0] stb_slot4_way = stb_slot4_way_i;
  wire   [7:0] stb_slot0_attrs = stb_slot0_attrs_i;
  wire   [7:0] stb_slot1_attrs = stb_slot1_attrs_i;
  wire   [7:0] stb_slot2_attrs = stb_slot2_attrs_i;
  wire   [7:0] stb_slot3_attrs = stb_slot3_attrs_i;
  wire   [7:0] stb_slot4_attrs = stb_slot4_attrs_i;
  wire         stb_lf_active = stb_lf_active_i;
  wire   [4:0] stb_lf_req = stb_lf_req_i;
  wire   [4:0] stb_lf_earliest_slot = stb_lf_earliest_slot_i;
  wire   [4:0] stb_lf_merge = stb_lf_merge_i;
  wire   [4:0] stb_slot_cachewrite_m1 = stb_slot_cachewrite_m1_i;
  wire         stb_biu_write_req = stb_biu_write_req_i;
  wire   [3:0] stb_biu_write_l2dbid = stb_biu_write_l2dbid_i;
  wire   [1:0] stb_biu_write_chunk = stb_biu_write_chunk_i;
  wire [127:0] stb_biu_write_data = stb_biu_write_data_i;
  wire  [15:0] stb_biu_write_bls = stb_biu_write_bls_i;
  wire         stb_biu_write_last = stb_biu_write_last_i;
  wire         stb_biu_write_req_active = stb_biu_write_req_active_i;
  wire         stb_ar_req = stb_ar_req_i;
  wire         stb_ar_early_req = stb_ar_early_req_i;
  wire   [4:0] stb_ar_id = stb_ar_id_i;
  wire   [1:0] stb_ar_way = stb_ar_way_i;
  wire   [7:0] stb_ar_type = stb_ar_type_i;
  wire  [39:0] stb_ar_addr = stb_ar_addr_i;
  wire         stb_ar_ns_dsc = stb_ar_ns_dsc_i;
  wire   [7:0] stb_ar_attrs = stb_ar_attrs_i;
  wire         stb_ar_priv = stb_ar_priv_i;
  wire         stb_ar_excl = stb_ar_excl_i;
  wire  [15:0] stb_ar_asid = stb_ar_asid_i;
  wire   [7:0] stb_ar_vmid = stb_ar_vmid_i;
  wire  [24:0] stb_ar_va = stb_ar_va_i;

  wire         stb_ar_type_ic;
  wire         implicit_dsb;
  wire         stb_ar_type_dvm;
  wire         stb_ar_type_dc;
  wire [127:0] stb_biu_write_data_valid_mask;
  wire   [4:0] stb_ar_req_onehot;
  wire         stb_has_store_slots;
  wire         stb_ar_type_tlb;
  wire         stb_ar_type_bar;
  wire         biu_ar_req_suppress;
  wire  [15:0] stb_biu_write_data_valid;
  wire   [4:0] resp_received;
  wire         stb_ar_type_bp;
  wire   [4:0] req_sent;
  wire         new_stb_ar_req_excl;

  reg   [4:0] outstanding_reqs;
  reg         write_in_m1;
  reg   [4:0] outstanding_write_reqs;
  reg  [15:0] l2db_outstanding;
  reg   [4:0] slots_store;
  reg         outstanding_dvm_sync;

  reg         stb_ar_req_reg;
  reg   [4:0] stb_slots_ns_dsc_reg;
  reg  [39:0] stb_ar_addr_reg;
  reg         stb_biu_write_req_active_reg;
  reg         stb_lf_active_reg;
  reg   [1:0] biu_lf_hazard_way_slot0_reg;
  reg   [4:0] stb_ar_id_reg;
  reg   [4:0] biu_lf_can_merge_reg;
  reg   [4:0] stb_lf_req_reg;
  reg  [39:0] stb_slot0_addr_reg;
  reg   [1:0] biu_lf_hazard_way_slot3_reg;
  reg         biu_ar_req_suppress_reg;
  reg         dcu_ns_dsc_dc3_reg;
  reg   [4:0] stb_slots_valid_reg;
  reg         stb_ar_excl_reg;
  reg  [39:0] dcu_pa_dc3_reg;
  reg   [4:0] stb_lf_merge_reg;
  reg   [1:0] biu_lf_hazard_way_slot2_reg;
  reg         stb_ar_ns_dsc_reg;
  reg  [39:0] stb_slot1_addr_reg;
  reg   [1:0] biu_lf_hazard_way_slot4_reg;
  reg  [39:0] stb_slot4_addr_reg;
  reg         dcu_stb_req_dc3_reg;
  reg  [39:0] stb_slot3_addr_reg;
  reg   [4:0] stb_slot_cachewrite_m1_reg;
  reg   [7:0] stb_ar_type_reg;
  reg  [39:0] stb_slot2_addr_reg;
  reg   [4:0] biu_lf_hazard_reg;
  reg         biu_stb_ar_ack_reg;
  reg   [1:0] biu_lf_hazard_way_slot1_reg;
  reg         biu_dirty_lf_in_progress_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    stb_ar_req_reg <= 1'b0;
    stb_slots_ns_dsc_reg <= {5{1'b0}};
    stb_ar_addr_reg <= {40{1'b0}};
    stb_biu_write_req_active_reg <= 1'b0;
    stb_lf_active_reg <= 1'b0;
    biu_lf_hazard_way_slot0_reg <= 2'b00;
    stb_ar_id_reg <= {5{1'b0}};
    biu_lf_can_merge_reg <= {5{1'b0}};
    stb_lf_req_reg <= {5{1'b0}};
    stb_slot0_addr_reg <= {40{1'b0}};
    biu_lf_hazard_way_slot3_reg <= 2'b00;
    biu_ar_req_suppress_reg <= 1'b0;
    dcu_ns_dsc_dc3_reg <= 1'b0;
    stb_slots_valid_reg <= {5{1'b0}};
    stb_ar_excl_reg <= 1'b0;
    dcu_pa_dc3_reg <= {40{1'b0}};
    stb_lf_merge_reg <= {5{1'b0}};
    biu_lf_hazard_way_slot2_reg <= 2'b00;
    stb_ar_ns_dsc_reg <= 1'b0;
    stb_slot1_addr_reg <= {40{1'b0}};
    biu_lf_hazard_way_slot4_reg <= 2'b00;
    stb_slot4_addr_reg <= {40{1'b0}};
    dcu_stb_req_dc3_reg <= 1'b0;
    stb_slot3_addr_reg <= {40{1'b0}};
    stb_slot_cachewrite_m1_reg <= {5{1'b0}};
    stb_ar_type_reg <= {8{1'b0}};
    stb_slot2_addr_reg <= {40{1'b0}};
    biu_lf_hazard_reg <= {5{1'b0}};
    biu_stb_ar_ack_reg <= 1'b0;
    biu_lf_hazard_way_slot1_reg <= 2'b00;
    biu_dirty_lf_in_progress_reg <= 1'b0;
  end
  else
  begin
    biu_lf_hazard_reg <= biu_lf_hazard;
    biu_lf_hazard_way_slot0_reg <= biu_lf_hazard_way_slot0;
    biu_lf_hazard_way_slot1_reg <= biu_lf_hazard_way_slot1;
    biu_lf_hazard_way_slot2_reg <= biu_lf_hazard_way_slot2;
    biu_lf_hazard_way_slot3_reg <= biu_lf_hazard_way_slot3;
    biu_lf_hazard_way_slot4_reg <= biu_lf_hazard_way_slot4;
    biu_lf_can_merge_reg <= biu_lf_can_merge;
    biu_stb_ar_ack_reg <= biu_stb_ar_ack;
    biu_dirty_lf_in_progress_reg <= biu_dirty_lf_in_progress;
    dcu_stb_req_dc3_reg <= dcu_stb_req_dc3;
    dcu_pa_dc3_reg <= dcu_pa_dc3;
    dcu_ns_dsc_dc3_reg <= dcu_ns_dsc_dc3;
    stb_slots_valid_reg <= stb_slots_valid;
    stb_slot0_addr_reg <= stb_slot0_addr;
    stb_slot1_addr_reg <= stb_slot1_addr;
    stb_slot2_addr_reg <= stb_slot2_addr;
    stb_slot3_addr_reg <= stb_slot3_addr;
    stb_slot4_addr_reg <= stb_slot4_addr;
    stb_slots_ns_dsc_reg <= stb_slots_ns_dsc;
    stb_lf_active_reg <= stb_lf_active;
    stb_lf_req_reg <= stb_lf_req;
    stb_lf_merge_reg <= stb_lf_merge;
    stb_slot_cachewrite_m1_reg <= stb_slot_cachewrite_m1;
    stb_biu_write_req_active_reg <= stb_biu_write_req_active;
    stb_ar_req_reg <= stb_ar_req;
    stb_ar_id_reg <= stb_ar_id;
    stb_ar_type_reg <= stb_ar_type;
    stb_ar_addr_reg <= stb_ar_addr;
    stb_ar_ns_dsc_reg <= stb_ar_ns_dsc;
    stb_ar_excl_reg <= stb_ar_excl;
    biu_ar_req_suppress_reg <= biu_ar_req_suppress;
  end



  //----------------------------------------------------------------------------
  //
  // Linefill requests and hazards
  //
  //----------------------------------------------------------------------------

  // The STB slots that currently have a valid transaction in them.
  //  output [4:0] stb_slots_valid valid always timing 17%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "stb_slots_valid X or Z")
  u_ovl_intf_x_stb_slots_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_slots_valid));


  // The STB exports the slot addresses to the BIU for hazard checking.
  //  output [39:0] stb_slot0_addr valid stb_slots_valid[0] timing 15%

  assert_never_unknown #(`OVL_FATAL, 40, OUTOPTIONS, "stb_slot0_addr X or Z")
  u_ovl_intf_x_stb_slot0_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_slots_valid[0]),
    .test_expr (stb_slot0_addr));

  //  output [39:0] stb_slot1_addr valid stb_slots_valid[1] timing 15%

  assert_never_unknown #(`OVL_FATAL, 40, OUTOPTIONS, "stb_slot1_addr X or Z")
  u_ovl_intf_x_stb_slot1_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_slots_valid[1]),
    .test_expr (stb_slot1_addr));

  //  output [39:0] stb_slot2_addr valid stb_slots_valid[2] timing 15%

  assert_never_unknown #(`OVL_FATAL, 40, OUTOPTIONS, "stb_slot2_addr X or Z")
  u_ovl_intf_x_stb_slot2_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_slots_valid[2]),
    .test_expr (stb_slot2_addr));

  //  output [39:0] stb_slot3_addr valid stb_slots_valid[3] timing 15%

  assert_never_unknown #(`OVL_FATAL, 40, OUTOPTIONS, "stb_slot3_addr X or Z")
  u_ovl_intf_x_stb_slot3_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_slots_valid[3]),
    .test_expr (stb_slot3_addr));

  //  output [39:0] stb_slot4_addr valid stb_slots_valid[4] timing 15%

  assert_never_unknown #(`OVL_FATAL, 40, OUTOPTIONS, "stb_slot4_addr X or Z")
  u_ovl_intf_x_stb_slot4_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_slots_valid[4]),
    .test_expr (stb_slot4_addr));


  // The TrustZone non-secure status of the address in the slots.
  //  output [4:0] stb_slots_ns_dsc valid mask stb_slots_valid timing 10%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "stb_slots_ns_dsc & (stb_slots_valid) X or Z")
  u_ovl_intf_x_4c7a24db06c60010007c94271865e47fcb749d61 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_slots_ns_dsc & (stb_slots_valid)));


  // The STB exports the slot ways to the BIU for eviction hazard checking.
  // If the slot missed, then it indicates the way requested for a linefill.
  //  output [1:0] stb_slot0_way valid stb_slots_valid[0] timing 15%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "stb_slot0_way X or Z")
  u_ovl_intf_x_stb_slot0_way (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_slots_valid[0]),
    .test_expr (stb_slot0_way));

  //  output [1:0] stb_slot1_way valid stb_slots_valid[1] timing 15%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "stb_slot1_way X or Z")
  u_ovl_intf_x_stb_slot1_way (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_slots_valid[1]),
    .test_expr (stb_slot1_way));

  //  output [1:0] stb_slot2_way valid stb_slots_valid[2] timing 15%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "stb_slot2_way X or Z")
  u_ovl_intf_x_stb_slot2_way (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_slots_valid[2]),
    .test_expr (stb_slot2_way));

  //  output [1:0] stb_slot3_way valid stb_slots_valid[3] timing 15%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "stb_slot3_way X or Z")
  u_ovl_intf_x_stb_slot3_way (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_slots_valid[3]),
    .test_expr (stb_slot3_way));

  //  output [1:0] stb_slot4_way valid stb_slots_valid[4] timing 15%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "stb_slot4_way X or Z")
  u_ovl_intf_x_stb_slot4_way (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_slots_valid[4]),
    .test_expr (stb_slot4_way));


  // The memory type and attributes of the each slot. The BIU uses these when
  // starting a linefill due to stb_lf_req.
  // See cortexa53params for the encoding.
  //  output [7:0] stb_slot0_attrs valid stb_slots_valid[0] timing 20%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "stb_slot0_attrs X or Z")
  u_ovl_intf_x_stb_slot0_attrs (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_slots_valid[0]),
    .test_expr (stb_slot0_attrs));

  //  output [7:0] stb_slot1_attrs valid stb_slots_valid[1] timing 20%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "stb_slot1_attrs X or Z")
  u_ovl_intf_x_stb_slot1_attrs (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_slots_valid[1]),
    .test_expr (stb_slot1_attrs));

  //  output [7:0] stb_slot2_attrs valid stb_slots_valid[2] timing 20%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "stb_slot2_attrs X or Z")
  u_ovl_intf_x_stb_slot2_attrs (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_slots_valid[2]),
    .test_expr (stb_slot2_attrs));

  //  output [7:0] stb_slot3_attrs valid stb_slots_valid[3] timing 20%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "stb_slot3_attrs X or Z")
  u_ovl_intf_x_stb_slot3_attrs (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_slots_valid[3]),
    .test_expr (stb_slot3_attrs));

  //  output [7:0] stb_slot4_attrs valid stb_slots_valid[4] timing 20%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "stb_slot4_attrs X or Z")
  u_ovl_intf_x_stb_slot4_attrs (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_slots_valid[4]),
    .test_expr (stb_slot4_attrs));


  // The BIU detected a linefill hazard for each slot.
  // There is a linefill that has started but not finished to the same address
  // as the slot.
  //  input [4:0] biu_lf_hazard valid mask stb_slots_valid timing 40%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "biu_lf_hazard & (stb_slots_valid) X or Z")
  u_ovl_intf_x_c75b8165e9cae962edec289b1d63ce890c99b874 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_lf_hazard & (stb_slots_valid)));


  // There is a linefill that has started to the same address as the slot, and
  // either the tag has not been written yet or the line might not be unique.
  //  input [4:0] biu_lf_real_hazard valid mask stb_slots_valid timing 40%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "biu_lf_real_hazard & (stb_slots_valid) X or Z")
  u_ovl_intf_x_ba17c5a0ef52b0a7d76afbd846a7c5f6ae02c671 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_lf_real_hazard & (stb_slots_valid)));


  // The migratory information for a linefill that hazards with an STB slot.
  //  input [4:0] biu_lf_hazard_migratory valid mask biu_lf_hazard timing 40%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "biu_lf_hazard_migratory & (biu_lf_hazard) X or Z")
  u_ovl_intf_x_c819f96d2741998f7b3fc6d423e44153eb4a1eaf (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_lf_hazard_migratory & (biu_lf_hazard)));


  // The way a linefill that hazards with an STB slot is allocating to.
  //  input [1:0] biu_lf_hazard_way_slot0 valid mask {2{biu_lf_hazard[0]}} timing 40%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "biu_lf_hazard_way_slot0 & ({2{biu_lf_hazard[0]}}) X or Z")
  u_ovl_intf_x_cb6b9dafc4dd48e64cb1d13d957e8a643db2833f (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_lf_hazard_way_slot0 & ({2{biu_lf_hazard[0]}})));

  //  input [1:0] biu_lf_hazard_way_slot1 valid mask {2{biu_lf_hazard[1]}} timing 40%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "biu_lf_hazard_way_slot1 & ({2{biu_lf_hazard[1]}}) X or Z")
  u_ovl_intf_x_e1eb09b269e843c8e9e43f96447d9e62b603a885 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_lf_hazard_way_slot1 & ({2{biu_lf_hazard[1]}})));

  //  input [1:0] biu_lf_hazard_way_slot2 valid mask {2{biu_lf_hazard[2]}} timing 40%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "biu_lf_hazard_way_slot2 & ({2{biu_lf_hazard[2]}}) X or Z")
  u_ovl_intf_x_723e9ef3b6187afdb9042f97f75e2486c863f475 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_lf_hazard_way_slot2 & ({2{biu_lf_hazard[2]}})));

  //  input [1:0] biu_lf_hazard_way_slot3 valid mask {2{biu_lf_hazard[3]}} timing 40%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "biu_lf_hazard_way_slot3 & ({2{biu_lf_hazard[3]}}) X or Z")
  u_ovl_intf_x_b7989b4346a0963b80856edf6f94ef5c876c5edd (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_lf_hazard_way_slot3 & ({2{biu_lf_hazard[3]}})));

  //  input [1:0] biu_lf_hazard_way_slot4 valid mask {2{biu_lf_hazard[4]}} timing 40%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "biu_lf_hazard_way_slot4 & ({2{biu_lf_hazard[4]}}) X or Z")
  u_ovl_intf_x_5adfe0dcd1a387742abd6ef2e804ce65233a8623 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_lf_hazard_way_slot4 & ({2{biu_lf_hazard[4]}})));


  // A linefill that hazards with an STB slot has been serialized.
  //  input [4:0] biu_lf_serialized valid mask biu_lf_hazard timing 40%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "biu_lf_serialized & (biu_lf_hazard) X or Z")
  u_ovl_intf_x_011073f8f1e94de889f591c3760d8eea46bde111 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_lf_serialized & (biu_lf_hazard)));


  // A linefill to the same index and way as the slot received an external abort.
  //  input [4:0] biu_ev_hazard valid mask stb_slots_valid timing 35%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "biu_ev_hazard & (stb_slots_valid) X or Z")
  u_ovl_intf_x_f7428405dc2bf25187641169f2e9666ff2b6d23a (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_ev_hazard & (stb_slots_valid)));


  // The STB may request a new linefill in the following clock cycle
  //  output stb_lf_active valid always timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "stb_lf_active X or Z")
  u_ovl_intf_x_stb_lf_active (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_lf_active));


  // The STB is requesting the BIU starts a new linefill for the specified
  // slots, assuming that there is not a linefill hazard for the slot this cycle.
  // The BIU must locally qualify this with ~biu_lf_hazard.
  // The BIU can only accept the request from at most one slot per cycle.
  // The address of the linefill should be taken from the stb_slot*_addr signals.
  //  output [4:0] stb_lf_req valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "stb_lf_req X or Z")
  u_ovl_intf_x_stb_lf_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_lf_req));


  // The STB indicates which slot that is requesting a linefill is the earliest.
  // The BIU must pick this slot in preference to any other, unless there is a
  // lf or ev hazard against it (in which case the BIU should pick the lowest
  // numbered slot that doesn't have a hazard).
  //  output [4:0] stb_lf_earliest_slot valid |stb_lf_req timing 35%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "stb_lf_earliest_slot X or Z")
  u_ovl_intf_x_stb_lf_earliest_slot (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|stb_lf_req),
    .test_expr (stb_lf_earliest_slot));


  // The STB wants to merge into a linefill. The BIU must locally qualify
  // this with whether a linefill to the same line as the slot is unique. If
  // it is then the BIU must delay linefill de-activation. For non-aborting
  // linefills, this facilitates entry into read-allocate mode. For aborting
  // linefills it ensures an imprecise abort is raised. This prevents the STB
  // from repeatedly starting linefills to the same aborting line.
  //  output [4:0] stb_lf_merge valid mask biu_lf_hazard timing 55%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "stb_lf_merge & (biu_lf_hazard) X or Z")
  u_ovl_intf_x_d7c66d0ff0168dec101308c61059136c33d8c42b (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_lf_merge & (biu_lf_hazard)));


  // The BIU indicates whether it will wait for an STB merge presented on
  // stb_lf_merge. The BIU will not wait if it has already arbitrated the M0
  // request for tag invalidation following an external abort. Once
  // biu_lf_can_merge has been asserted, it must remain asserted until the
  // STB merge has completed (stb_lf_merge is de-asserted).
  //  input [4:0] biu_lf_can_merge valid mask biu_lf_hazard timing 50%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "biu_lf_can_merge & (biu_lf_hazard) X or Z")
  u_ovl_intf_x_921657c7e0647631feb77f4f4339ee5ba4857609 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_lf_can_merge & (biu_lf_hazard)));


  // The STB is writing a slot to the cache. The BIU must take notice of this
  // if the slot has a linefill hazard as the line must now be marked as dirty.
  //  output [4:0] stb_slot_cachewrite_m1 valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "stb_slot_cachewrite_m1 X or Z")
  u_ovl_intf_x_stb_slot_cachewrite_m1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_slot_cachewrite_m1));




  // Track what a slot is being used for.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    slots_store <= {5{1'b0}};
  else if (dcu_stb_req_dc3)
    slots_store <= (stb_slots_valid & slots_store) | (~stb_slots_valid & {5{~dcu_store_cp15_dc3}});


  // The activating slots have to start filling from the lowest available physical index

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[1] & ~stb_slots_valid[1]@1  => stb_slots_valid[0]@1")
  u_ovl_intf_assert_1d73b66e1267087baf2460616b5bfd1027a42a4f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[1] & ~stb_slots_valid_reg[1] ),
    .consequent_expr (stb_slots_valid_reg[0]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[2] & ~stb_slots_valid[2]@1  => &stb_slots_valid[1:0]@1")
  u_ovl_intf_assert_872a57bebd5bb5e2389041c6ebb3e874eb1a85c4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[2] & ~stb_slots_valid_reg[2] ),
    .consequent_expr (&stb_slots_valid_reg[1:0]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[3] & ~stb_slots_valid[3]@1  => &stb_slots_valid[2:0]@1")
  u_ovl_intf_assert_82d4476ae85f99e80285308ebcb6615aa4d51de6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[3] & ~stb_slots_valid_reg[3] ),
    .consequent_expr (&stb_slots_valid_reg[2:0]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[4] & ~stb_slots_valid[4]@1  => &stb_slots_valid[3:0]@1")
  u_ovl_intf_assert_8d37efc307f3da40f4d12f1d891c5b4b7dab312f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[4] & ~stb_slots_valid_reg[4] ),
    .consequent_expr (&stb_slots_valid_reg[3:0]));


  // The dcu_stb_req_dc3 must have been set previous clock cycle if there is a new activating slot

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[0] & ~stb_slots_valid[0]@1  => dcu_stb_req_dc3@1")
  u_ovl_intf_assert_26549f9e5e5d652e5d85b50136c6a6796147cc66 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[0] & ~stb_slots_valid_reg[0] ),
    .consequent_expr (dcu_stb_req_dc3_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[1] & ~stb_slots_valid[1]@1  => dcu_stb_req_dc3@1")
  u_ovl_intf_assert_c679ab5134d6730b7a003915be1d7808739a7529 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[1] & ~stb_slots_valid_reg[1] ),
    .consequent_expr (dcu_stb_req_dc3_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[2] & ~stb_slots_valid[2]@1  => dcu_stb_req_dc3@1")
  u_ovl_intf_assert_0cfa5ac4dc762eef4eef7029ff9522646e376cb1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[2] & ~stb_slots_valid_reg[2] ),
    .consequent_expr (dcu_stb_req_dc3_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[3] & ~stb_slots_valid[3]@1  => dcu_stb_req_dc3@1")
  u_ovl_intf_assert_dd209bfbeed326fd0c8bb2a4541bef1693d30a06 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[3] & ~stb_slots_valid_reg[3] ),
    .consequent_expr (dcu_stb_req_dc3_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[4] & ~stb_slots_valid[4]@1  => dcu_stb_req_dc3@1")
  u_ovl_intf_assert_0b3f24f6134b67c836fd1bc4b6b9c9fe8a47c639 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[4] & ~stb_slots_valid_reg[4] ),
    .consequent_expr (dcu_stb_req_dc3_reg));


  // The STB slots addressses must use the dc3 address from previous clock cycle if there is a new activating slot

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[0] & ~stb_slots_valid[0]@1  => (stb_slot0_addr[39:6] == dcu_pa_dc3[39:6]@1)")
  u_ovl_intf_assert_6e547596d716de2b31587f1e66cabf611d28bb46 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[0] & ~stb_slots_valid_reg[0] ),
    .consequent_expr ((stb_slot0_addr[39:6] == dcu_pa_dc3_reg[39:6])));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[1] & ~stb_slots_valid[1]@1  => (stb_slot1_addr[39:6] == dcu_pa_dc3[39:6]@1)")
  u_ovl_intf_assert_b35e0d8977f36c7bff0029e7769a8c10f349a9db (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[1] & ~stb_slots_valid_reg[1] ),
    .consequent_expr ((stb_slot1_addr[39:6] == dcu_pa_dc3_reg[39:6])));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[2] & ~stb_slots_valid[2]@1  => (stb_slot2_addr[39:6] == dcu_pa_dc3[39:6]@1)")
  u_ovl_intf_assert_a852af7149024b4326bc8e5968d3aace472933e9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[2] & ~stb_slots_valid_reg[2] ),
    .consequent_expr ((stb_slot2_addr[39:6] == dcu_pa_dc3_reg[39:6])));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[3] & ~stb_slots_valid[3]@1  => (stb_slot3_addr[39:6] == dcu_pa_dc3[39:6]@1)")
  u_ovl_intf_assert_24cb44e9a6c07adddfbc85fb6fe5e0bc4c4630e8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[3] & ~stb_slots_valid_reg[3] ),
    .consequent_expr ((stb_slot3_addr[39:6] == dcu_pa_dc3_reg[39:6])));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[4] & ~stb_slots_valid[4]@1  => (stb_slot4_addr[39:6] == dcu_pa_dc3[39:6]@1)")
  u_ovl_intf_assert_fc00e0f2d6b94f020c1066262f206137ad13d84c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[4] & ~stb_slots_valid_reg[4] ),
    .consequent_expr ((stb_slot4_addr[39:6] == dcu_pa_dc3_reg[39:6])));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[0] & ~stb_slots_valid[0]@1  => (stb_slots_ns_dsc[0] == dcu_ns_dsc_dc3@1)")
  u_ovl_intf_assert_4c870ba9abeb0c214ef9390392f35035681e87a0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[0] & ~stb_slots_valid_reg[0] ),
    .consequent_expr ((stb_slots_ns_dsc[0] == dcu_ns_dsc_dc3_reg)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[1] & ~stb_slots_valid[1]@1  => (stb_slots_ns_dsc[1] == dcu_ns_dsc_dc3@1)")
  u_ovl_intf_assert_5c54f228e4bfc0aa0acfd4bd34ad9391357b9671 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[1] & ~stb_slots_valid_reg[1] ),
    .consequent_expr ((stb_slots_ns_dsc[1] == dcu_ns_dsc_dc3_reg)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[2] & ~stb_slots_valid[2]@1  => (stb_slots_ns_dsc[2] == dcu_ns_dsc_dc3@1)")
  u_ovl_intf_assert_70d3ddeeb777f8db9ce18a9b6e1a575281d1ff52 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[2] & ~stb_slots_valid_reg[2] ),
    .consequent_expr ((stb_slots_ns_dsc[2] == dcu_ns_dsc_dc3_reg)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[3] & ~stb_slots_valid[3]@1  => (stb_slots_ns_dsc[3] == dcu_ns_dsc_dc3@1)")
  u_ovl_intf_assert_561a81c2393c87428feb2148e02845737540c004 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[3] & ~stb_slots_valid_reg[3] ),
    .consequent_expr ((stb_slots_ns_dsc[3] == dcu_ns_dsc_dc3_reg)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[4] & ~stb_slots_valid[4]@1  => (stb_slots_ns_dsc[4] == dcu_ns_dsc_dc3@1)")
  u_ovl_intf_assert_009912712dc2cc8aab2aefe3583376b4c4963eb7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[4] & ~stb_slots_valid_reg[4] ),
    .consequent_expr ((stb_slots_ns_dsc[4] == dcu_ns_dsc_dc3_reg)));


  // The STB slots addressses must not change for an activated slot

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[0] & stb_slots_valid[0]@1  => (stb_slot0_addr[39:6] == stb_slot0_addr[39:6]@1)")
  u_ovl_intf_assert_a343bc487891cf62b83de22af510203742d26d01 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[0] & stb_slots_valid_reg[0] ),
    .consequent_expr ((stb_slot0_addr[39:6] == stb_slot0_addr_reg[39:6])));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[1] & stb_slots_valid[1]@1  => (stb_slot1_addr[39:6] == stb_slot1_addr[39:6]@1)")
  u_ovl_intf_assert_fc8bc2bad75cd4e2a8ed62183639e66dcdaa44e8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[1] & stb_slots_valid_reg[1] ),
    .consequent_expr ((stb_slot1_addr[39:6] == stb_slot1_addr_reg[39:6])));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[2] & stb_slots_valid[2]@1  => (stb_slot2_addr[39:6] == stb_slot2_addr[39:6]@1)")
  u_ovl_intf_assert_a22fefcb43de90612d185dd01a65b7e88bf7807a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[2] & stb_slots_valid_reg[2] ),
    .consequent_expr ((stb_slot2_addr[39:6] == stb_slot2_addr_reg[39:6])));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[3] & stb_slots_valid[3]@1  => (stb_slot3_addr[39:6] == stb_slot3_addr[39:6]@1)")
  u_ovl_intf_assert_76e378734705e185358756a9561e76859a219508 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[3] & stb_slots_valid_reg[3] ),
    .consequent_expr ((stb_slot3_addr[39:6] == stb_slot3_addr_reg[39:6])));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[4] & stb_slots_valid[4]@1  => (stb_slot4_addr[39:6] == stb_slot4_addr[39:6]@1)")
  u_ovl_intf_assert_9a6cdccb9be9638d602f97541e631eb2ac07da04 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[4] & stb_slots_valid_reg[4] ),
    .consequent_expr ((stb_slot4_addr[39:6] == stb_slot4_addr_reg[39:6])));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[0] & stb_slots_valid[0]@1  => (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[0]@1)")
  u_ovl_intf_assert_970d5d7498e0257fb9ac99fb3e083f5f145c806f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[0] & stb_slots_valid_reg[0] ),
    .consequent_expr ((stb_slots_ns_dsc[0] == stb_slots_ns_dsc_reg[0])));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[1] & stb_slots_valid[1]@1  => (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[1]@1)")
  u_ovl_intf_assert_0607e3c776f3d92913d5a3b4f856c309b65454be (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[1] & stb_slots_valid_reg[1] ),
    .consequent_expr ((stb_slots_ns_dsc[1] == stb_slots_ns_dsc_reg[1])));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[2] & stb_slots_valid[2]@1  => (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[2]@1)")
  u_ovl_intf_assert_0d8e712205007f089cd3e5299edd2665ea16a6eb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[2] & stb_slots_valid_reg[2] ),
    .consequent_expr ((stb_slots_ns_dsc[2] == stb_slots_ns_dsc_reg[2])));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[3] & stb_slots_valid[3]@1  => (stb_slots_ns_dsc[3] == stb_slots_ns_dsc[3]@1)")
  u_ovl_intf_assert_a16b896017d6b0661f41bc295164688fc938c050 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[3] & stb_slots_valid_reg[3] ),
    .consequent_expr ((stb_slots_ns_dsc[3] == stb_slots_ns_dsc_reg[3])));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_slots_valid[4] & stb_slots_valid[4]@1  => (stb_slots_ns_dsc[4] == stb_slots_ns_dsc[4]@1)")
  u_ovl_intf_assert_06b593709b86bf836bc527ec8f00d459db2a5e69 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[4] & stb_slots_valid_reg[4] ),
    .consequent_expr ((stb_slots_ns_dsc[4] == stb_slots_ns_dsc_reg[4])));


  // The STB has valid store slots.
  assign stb_has_store_slots  = |(stb_slots_valid & slots_store);

  // Only one new STB slot can become busy per cycle.

  assert_zero_one_hot #(`OVL_FATAL, 5, OUTOPTIONS, "(stb_slots_valid & ~stb_slots_valid@1)")
  u_ovl_intf_assert_1d65542f1ef30d69d253e8b47786186dffb5f386 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ((stb_slots_valid & ~stb_slots_valid_reg)));


  // There cannot be a real hazard if there isn't a hazard.

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[0] & biu_lf_real_hazard[0]  => biu_lf_hazard[0]")
  u_ovl_intf_assume_a3f6950d9bf1b998de876ddab5035d931f1a7930 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[0] & biu_lf_real_hazard[0] ),
    .consequent_expr (biu_lf_hazard[0]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[1] & biu_lf_real_hazard[1]  => biu_lf_hazard[1]")
  u_ovl_intf_assume_7183407ec727e34796e57ea59df52aefe0eb313b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[1] & biu_lf_real_hazard[1] ),
    .consequent_expr (biu_lf_hazard[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[2] & biu_lf_real_hazard[2]  => biu_lf_hazard[2]")
  u_ovl_intf_assume_4a50523271410e2d046288b9a3c47b274b47393b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[2] & biu_lf_real_hazard[2] ),
    .consequent_expr (biu_lf_hazard[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[3] & biu_lf_real_hazard[3]  => biu_lf_hazard[3]")
  u_ovl_intf_assume_da84033c6aafaea0ff5a9a6b5220768c61714f43 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[3] & biu_lf_real_hazard[3] ),
    .consequent_expr (biu_lf_hazard[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[4] & biu_lf_real_hazard[4]  => biu_lf_hazard[4]")
  u_ovl_intf_assume_023e022b5a3de8d9dde6d9d869331d8fbd336744 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[4] & biu_lf_real_hazard[4] ),
    .consequent_expr (biu_lf_hazard[4]));


  // If a linefill request causes a hazard then the slot should stop
  // requesting the linefill.

  assert_always #(`OVL_FATAL, OUTOPTIONS, "~|(stb_lf_req@1 & biu_lf_hazard@1 & stb_lf_req)")
  u_ovl_intf_assert_714392f831b5396d08ac784bf14d0a453bdbab21 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (~|(stb_lf_req_reg & biu_lf_hazard_reg & stb_lf_req)));


  // A linefill cannot change the way it is allocating to mid-hazard

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[0] & stb_slots_valid@1[0] & biu_lf_hazard[0] & biu_lf_hazard@1[0]  => biu_lf_hazard_way_slot0 == biu_lf_hazard_way_slot0@1")
  u_ovl_intf_assume_1ff9001fc3481bafbc7d0ef81cda242c28938e77 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[0] & stb_slots_valid_reg[0] & biu_lf_hazard[0] & biu_lf_hazard_reg[0] ),
    .consequent_expr (biu_lf_hazard_way_slot0 == biu_lf_hazard_way_slot0_reg));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[1] & stb_slots_valid@1[1] & biu_lf_hazard[1] & biu_lf_hazard@1[1]  => biu_lf_hazard_way_slot1 == biu_lf_hazard_way_slot1@1")
  u_ovl_intf_assume_068c8ec390ecadc60d775c401005ea141ed9a11d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[1] & stb_slots_valid_reg[1] & biu_lf_hazard[1] & biu_lf_hazard_reg[1] ),
    .consequent_expr (biu_lf_hazard_way_slot1 == biu_lf_hazard_way_slot1_reg));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[2] & stb_slots_valid@1[2] & biu_lf_hazard[2] & biu_lf_hazard@1[2]  => biu_lf_hazard_way_slot2 == biu_lf_hazard_way_slot2@1")
  u_ovl_intf_assume_82ec00824e790bc5a7b6d69b69cac17e46ade5bc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[2] & stb_slots_valid_reg[2] & biu_lf_hazard[2] & biu_lf_hazard_reg[2] ),
    .consequent_expr (biu_lf_hazard_way_slot2 == biu_lf_hazard_way_slot2_reg));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[3] & stb_slots_valid@1[3] & biu_lf_hazard[3] & biu_lf_hazard@1[3]  => biu_lf_hazard_way_slot3 == biu_lf_hazard_way_slot3@1")
  u_ovl_intf_assume_0679cf60edaa9c791a6a4eed23f730d61a470000 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[3] & stb_slots_valid_reg[3] & biu_lf_hazard[3] & biu_lf_hazard_reg[3] ),
    .consequent_expr (biu_lf_hazard_way_slot3 == biu_lf_hazard_way_slot3_reg));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_slots_valid[4] & stb_slots_valid@1[4] & biu_lf_hazard[4] & biu_lf_hazard@1[4]  => biu_lf_hazard_way_slot4 == biu_lf_hazard_way_slot4@1")
  u_ovl_intf_assume_2b1f7d394078469d00281ea0c15192d59b216973 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_slots_valid[4] & stb_slots_valid_reg[4] & biu_lf_hazard[4] & biu_lf_hazard_reg[4] ),
    .consequent_expr (biu_lf_hazard_way_slot4 == biu_lf_hazard_way_slot4_reg));


  // If one slot gets a linefill hazard then all slots in the same line must
  // also get the hazard.

  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[1] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[1]) & (stb_slot0_addr[39:6] == stb_slot1_addr[39:6]))  => biu_lf_hazard[0] == biu_lf_hazard[1]")
  u_ovl_intf_assume_a9cb3923e060c487b346f24bd3d1b019aea6e062 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[1] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[1]) & (stb_slot0_addr[39:6] == stb_slot1_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard[0] == biu_lf_hazard[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[2] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[2]) & (stb_slot0_addr[39:6] == stb_slot2_addr[39:6]))  => biu_lf_hazard[0] == biu_lf_hazard[2]")
  u_ovl_intf_assume_f6ee4e95ae217f37f4b33a1e7c8c96155312764c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[2] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[2]) & (stb_slot0_addr[39:6] == stb_slot2_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard[0] == biu_lf_hazard[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[3] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[3]) & (stb_slot0_addr[39:6] == stb_slot3_addr[39:6]))  => biu_lf_hazard[0] == biu_lf_hazard[3]")
  u_ovl_intf_assume_f50de5e246de4d51be6e54a1ae8eef5263b406e5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[3] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[3]) & (stb_slot0_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard[0] == biu_lf_hazard[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[4] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[4]) & (stb_slot0_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_hazard[0] == biu_lf_hazard[4]")
  u_ovl_intf_assume_aae7c22a851986f269b669bf0f0a70ca51a39ca0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[4] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[4]) & (stb_slot0_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard[0] == biu_lf_hazard[4]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[2] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[2]) & (stb_slot1_addr[39:6] == stb_slot2_addr[39:6]))  => biu_lf_hazard[1] == biu_lf_hazard[2]")
  u_ovl_intf_assume_d8838d0a8b7247ff695f684f2ed7f884546f38e9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[2] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[2]) & (stb_slot1_addr[39:6] == stb_slot2_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard[1] == biu_lf_hazard[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[3] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[3]) & (stb_slot1_addr[39:6] == stb_slot3_addr[39:6]))  => biu_lf_hazard[1] == biu_lf_hazard[3]")
  u_ovl_intf_assume_ffe93e5f1fce432626514139667ed69741f0bc00 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[3] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[3]) & (stb_slot1_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard[1] == biu_lf_hazard[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[4] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[4]) & (stb_slot1_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_hazard[1] == biu_lf_hazard[4]")
  u_ovl_intf_assume_f23c74eecbf8f71a92892192bb22497028733bdc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[4] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[4]) & (stb_slot1_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard[1] == biu_lf_hazard[4]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[2] & stb_slots_valid[3] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[3]) & (stb_slot2_addr[39:6] == stb_slot3_addr[39:6]))  => biu_lf_hazard[2] == biu_lf_hazard[3]")
  u_ovl_intf_assume_6b2d13dc2bd51c711c64723fdd07dd2cb8e22567 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[2] & stb_slots_valid[3] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[3]) & (stb_slot2_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard[2] == biu_lf_hazard[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[2] & stb_slots_valid[4] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[4]) & (stb_slot2_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_hazard[2] == biu_lf_hazard[4]")
  u_ovl_intf_assume_6caf90a268edd7352d029b78d61ad4927975b055 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[2] & stb_slots_valid[4] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[4]) & (stb_slot2_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard[2] == biu_lf_hazard[4]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[3] & stb_slots_valid[4] & (stb_slots_ns_dsc[3] == stb_slots_ns_dsc[4]) & (stb_slot3_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_hazard[3] == biu_lf_hazard[4]")
  u_ovl_intf_assume_d436d4088e3be99b14719b24d48cfa9587ff79fc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[3] & stb_slots_valid[4] & (stb_slots_ns_dsc[3] == stb_slots_ns_dsc[4]) & (stb_slot3_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard[3] == biu_lf_hazard[4]));


  // If one slot gets a linefill hazard then all slots in the same line must
  // receive the same linefill hazard way information.

  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[1] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[1]) & (stb_slot0_addr[39:6] == stb_slot1_addr[39:6]))  => biu_lf_hazard_way_slot0 == biu_lf_hazard_way_slot1")
  u_ovl_intf_assume_4ad974f8284c85cb094cb50fb5c580e573269f7f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[1] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[1]) & (stb_slot0_addr[39:6] == stb_slot1_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_way_slot0 == biu_lf_hazard_way_slot1));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[2] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[2]) & (stb_slot0_addr[39:6] == stb_slot2_addr[39:6]))  => biu_lf_hazard_way_slot0 == biu_lf_hazard_way_slot2")
  u_ovl_intf_assume_fa74772ea8011e712244206ca66e8de968edcfd0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[2] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[2]) & (stb_slot0_addr[39:6] == stb_slot2_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_way_slot0 == biu_lf_hazard_way_slot2));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[3] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[3]) & (stb_slot0_addr[39:6] == stb_slot3_addr[39:6]))  => biu_lf_hazard_way_slot0 == biu_lf_hazard_way_slot3")
  u_ovl_intf_assume_7735a49876214d354dbba4b42fa854f68c154049 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[3] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[3]) & (stb_slot0_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_way_slot0 == biu_lf_hazard_way_slot3));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[4] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[4]) & (stb_slot0_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_hazard_way_slot0 == biu_lf_hazard_way_slot4")
  u_ovl_intf_assume_5af0d66e56a39ba0f9487038e3f6d086c860bb66 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[4] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[4]) & (stb_slot0_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_way_slot0 == biu_lf_hazard_way_slot4));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[2] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[2]) & (stb_slot1_addr[39:6] == stb_slot2_addr[39:6]))  => biu_lf_hazard_way_slot1 == biu_lf_hazard_way_slot2")
  u_ovl_intf_assume_d50697b4dd89c41b05ac40ed28701dea23ccc25b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[2] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[2]) & (stb_slot1_addr[39:6] == stb_slot2_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_way_slot1 == biu_lf_hazard_way_slot2));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[3] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[3]) & (stb_slot1_addr[39:6] == stb_slot3_addr[39:6]))  => biu_lf_hazard_way_slot1 == biu_lf_hazard_way_slot3")
  u_ovl_intf_assume_aa3aa6e6c6ac4f23f3532868885c5fb44f5f501c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[3] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[3]) & (stb_slot1_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_way_slot1 == biu_lf_hazard_way_slot3));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[4] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[4]) & (stb_slot1_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_hazard_way_slot1 == biu_lf_hazard_way_slot4")
  u_ovl_intf_assume_67c4a49d89035eb2f6194a84f799a567e581f785 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[4] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[4]) & (stb_slot1_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_way_slot1 == biu_lf_hazard_way_slot4));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[2] & stb_slots_valid[3] & biu_lf_hazard[2] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[3]) & (stb_slot2_addr[39:6] == stb_slot3_addr[39:6]))  => biu_lf_hazard_way_slot2 == biu_lf_hazard_way_slot3")
  u_ovl_intf_assume_c98952aa1de97ae7ed22ddc6c78aaa90f4a614b7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[2] & stb_slots_valid[3] & biu_lf_hazard[2] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[3]) & (stb_slot2_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_way_slot2 == biu_lf_hazard_way_slot3));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[2] & stb_slots_valid[4] & biu_lf_hazard[2] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[4]) & (stb_slot2_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_hazard_way_slot2 == biu_lf_hazard_way_slot4")
  u_ovl_intf_assume_bf6027003c7d35879042379f362281702505caf1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[2] & stb_slots_valid[4] & biu_lf_hazard[2] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[4]) & (stb_slot2_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_way_slot2 == biu_lf_hazard_way_slot4));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[3] & stb_slots_valid[4] & biu_lf_hazard[3] & (stb_slots_ns_dsc[3] == stb_slots_ns_dsc[4]) & (stb_slot3_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_hazard_way_slot3 == biu_lf_hazard_way_slot4")
  u_ovl_intf_assume_cd379a31356621bdd7619d81c32fe8642f169ce6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[3] & stb_slots_valid[4] & biu_lf_hazard[3] & (stb_slots_ns_dsc[3] == stb_slots_ns_dsc[4]) & (stb_slot3_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_way_slot3 == biu_lf_hazard_way_slot4));


  // If one slot gets a linefill hazard then all slots in the same line must
  // receive the same migratory information.

  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[1] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[1]) & (stb_slot0_addr[39:6] == stb_slot1_addr[39:6]))  => biu_lf_hazard_migratory[0] == biu_lf_hazard_migratory[1]")
  u_ovl_intf_assume_bf812a8046612e8738a7a3fabcde4d8fdb683fb5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[1] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[1]) & (stb_slot0_addr[39:6] == stb_slot1_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_migratory[0] == biu_lf_hazard_migratory[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[2] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[2]) & (stb_slot0_addr[39:6] == stb_slot2_addr[39:6]))  => biu_lf_hazard_migratory[0] == biu_lf_hazard_migratory[2]")
  u_ovl_intf_assume_91a789eff7bf17d69ac8c145ea8d0b0f493f421f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[2] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[2]) & (stb_slot0_addr[39:6] == stb_slot2_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_migratory[0] == biu_lf_hazard_migratory[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[3] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[3]) & (stb_slot0_addr[39:6] == stb_slot3_addr[39:6]))  => biu_lf_hazard_migratory[0] == biu_lf_hazard_migratory[3]")
  u_ovl_intf_assume_39f0d7e4cc6dd49b5bf461049a4acfc7ef556176 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[3] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[3]) & (stb_slot0_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_migratory[0] == biu_lf_hazard_migratory[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[4] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[4]) & (stb_slot0_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_hazard_migratory[0] == biu_lf_hazard_migratory[4]")
  u_ovl_intf_assume_8238b5993ee51c506973fd7cbf81204189fed454 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[4] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[4]) & (stb_slot0_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_migratory[0] == biu_lf_hazard_migratory[4]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[2] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[2]) & (stb_slot1_addr[39:6] == stb_slot2_addr[39:6]))  => biu_lf_hazard_migratory[1] == biu_lf_hazard_migratory[2]")
  u_ovl_intf_assume_419b01c69a68afeaacd6671484f71ad09f39b68b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[2] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[2]) & (stb_slot1_addr[39:6] == stb_slot2_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_migratory[1] == biu_lf_hazard_migratory[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[3] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[3]) & (stb_slot1_addr[39:6] == stb_slot3_addr[39:6]))  => biu_lf_hazard_migratory[1] == biu_lf_hazard_migratory[3]")
  u_ovl_intf_assume_545e2347b7a74bac18c98d239811c334159b6d35 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[3] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[3]) & (stb_slot1_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_migratory[1] == biu_lf_hazard_migratory[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[4] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[4]) & (stb_slot1_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_hazard_migratory[1] == biu_lf_hazard_migratory[4]")
  u_ovl_intf_assume_90a73a8ea2d1183d408f0f7dc04c8fd406eb6aa7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[4] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[4]) & (stb_slot1_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_migratory[1] == biu_lf_hazard_migratory[4]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[2] & stb_slots_valid[3] & biu_lf_hazard[2] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[3]) & (stb_slot2_addr[39:6] == stb_slot3_addr[39:6]))  => biu_lf_hazard_migratory[2] == biu_lf_hazard_migratory[3]")
  u_ovl_intf_assume_b52e13a6660171fefbd2fd2322365ed7a71c0c5a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[2] & stb_slots_valid[3] & biu_lf_hazard[2] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[3]) & (stb_slot2_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_migratory[2] == biu_lf_hazard_migratory[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[2] & stb_slots_valid[4] & biu_lf_hazard[2] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[4]) & (stb_slot2_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_hazard_migratory[2] == biu_lf_hazard_migratory[4]")
  u_ovl_intf_assume_dc5634a10425a08df9fc7131504af7bcebaa3ea8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[2] & stb_slots_valid[4] & biu_lf_hazard[2] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[4]) & (stb_slot2_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_migratory[2] == biu_lf_hazard_migratory[4]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[3] & stb_slots_valid[4] & biu_lf_hazard[3] & (stb_slots_ns_dsc[3] == stb_slots_ns_dsc[4]) & (stb_slot3_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_hazard_migratory[3] == biu_lf_hazard_migratory[4]")
  u_ovl_intf_assume_763b46bab6d078de4c05b1903f1583493042235f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[3] & stb_slots_valid[4] & biu_lf_hazard[3] & (stb_slots_ns_dsc[3] == stb_slots_ns_dsc[4]) & (stb_slot3_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_hazard_migratory[3] == biu_lf_hazard_migratory[4]));


  // If one slot gets a linefill hazard then all slots in the same line must
  // receive the same serialized information.

  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[1] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[1]) & (stb_slot0_addr[39:6] == stb_slot1_addr[39:6]))  => biu_lf_serialized[0] == biu_lf_serialized[1]")
  u_ovl_intf_assume_c675d5c8b8bfe505d40db2cf90e4a4ab2dabd371 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[1] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[1]) & (stb_slot0_addr[39:6] == stb_slot1_addr[39:6])) ),
    .consequent_expr (biu_lf_serialized[0] == biu_lf_serialized[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[2] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[2]) & (stb_slot0_addr[39:6] == stb_slot2_addr[39:6]))  => biu_lf_serialized[0] == biu_lf_serialized[2]")
  u_ovl_intf_assume_b467976af25e5b8efdabb39fdf79f62b8d308bc0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[2] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[2]) & (stb_slot0_addr[39:6] == stb_slot2_addr[39:6])) ),
    .consequent_expr (biu_lf_serialized[0] == biu_lf_serialized[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[3] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[3]) & (stb_slot0_addr[39:6] == stb_slot3_addr[39:6]))  => biu_lf_serialized[0] == biu_lf_serialized[3]")
  u_ovl_intf_assume_a388ae663f272098187b393906894ba081d02df5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[3] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[3]) & (stb_slot0_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_lf_serialized[0] == biu_lf_serialized[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[4] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[4]) & (stb_slot0_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_serialized[0] == biu_lf_serialized[4]")
  u_ovl_intf_assume_dd462306f92641abb27379a20090602993478a03 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[4] & biu_lf_hazard[0] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[4]) & (stb_slot0_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_serialized[0] == biu_lf_serialized[4]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[2] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[2]) & (stb_slot1_addr[39:6] == stb_slot2_addr[39:6]))  => biu_lf_serialized[1] == biu_lf_serialized[2]")
  u_ovl_intf_assume_6e1a173f8814900fa4ea4180034172f6f842f7c5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[2] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[2]) & (stb_slot1_addr[39:6] == stb_slot2_addr[39:6])) ),
    .consequent_expr (biu_lf_serialized[1] == biu_lf_serialized[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[3] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[3]) & (stb_slot1_addr[39:6] == stb_slot3_addr[39:6]))  => biu_lf_serialized[1] == biu_lf_serialized[3]")
  u_ovl_intf_assume_e5189cccce20a39d50847f5743bcfeb609e6fe3e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[3] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[3]) & (stb_slot1_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_lf_serialized[1] == biu_lf_serialized[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[4] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[4]) & (stb_slot1_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_serialized[1] == biu_lf_serialized[4]")
  u_ovl_intf_assume_41dbdb76858c8ffd5aaef04dbba2d6d52d6d0515 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[4] & biu_lf_hazard[1] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[4]) & (stb_slot1_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_serialized[1] == biu_lf_serialized[4]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[2] & stb_slots_valid[3] & biu_lf_hazard[2] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[3]) & (stb_slot2_addr[39:6] == stb_slot3_addr[39:6]))  => biu_lf_serialized[2] == biu_lf_serialized[3]")
  u_ovl_intf_assume_ae95d97dd8f8a769099316f53c80f5ed412d6bd2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[2] & stb_slots_valid[3] & biu_lf_hazard[2] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[3]) & (stb_slot2_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_lf_serialized[2] == biu_lf_serialized[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[2] & stb_slots_valid[4] & biu_lf_hazard[2] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[4]) & (stb_slot2_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_serialized[2] == biu_lf_serialized[4]")
  u_ovl_intf_assume_e69ebc5c9fe366f07c796b126c73014cc1531a3d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[2] & stb_slots_valid[4] & biu_lf_hazard[2] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[4]) & (stb_slot2_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_serialized[2] == biu_lf_serialized[4]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[3] & stb_slots_valid[4] & biu_lf_hazard[3] & (stb_slots_ns_dsc[3] == stb_slots_ns_dsc[4]) & (stb_slot3_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_serialized[3] == biu_lf_serialized[4]")
  u_ovl_intf_assume_cd919eecd067cf0e4f1cb10000364a21e31c3866 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[3] & stb_slots_valid[4] & biu_lf_hazard[3] & (stb_slots_ns_dsc[3] == stb_slots_ns_dsc[4]) & (stb_slot3_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_serialized[3] == biu_lf_serialized[4]));


  // If one slot gets a real linefill hazard then all slots in the same line
  // must also get the hazard.

  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[1] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[1]) & (stb_slot0_addr[39:6] == stb_slot1_addr[39:6]))  => biu_lf_real_hazard[0] == biu_lf_real_hazard[1]")
  u_ovl_intf_assume_ab1321d67f8514596b6968cfc874fe578b8fd453 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[1] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[1]) & (stb_slot0_addr[39:6] == stb_slot1_addr[39:6])) ),
    .consequent_expr (biu_lf_real_hazard[0] == biu_lf_real_hazard[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[2] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[2]) & (stb_slot0_addr[39:6] == stb_slot2_addr[39:6]))  => biu_lf_real_hazard[0] == biu_lf_real_hazard[2]")
  u_ovl_intf_assume_1811a40b1537b93bab920e515a6ead99cb4be77b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[2] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[2]) & (stb_slot0_addr[39:6] == stb_slot2_addr[39:6])) ),
    .consequent_expr (biu_lf_real_hazard[0] == biu_lf_real_hazard[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[3] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[3]) & (stb_slot0_addr[39:6] == stb_slot3_addr[39:6]))  => biu_lf_real_hazard[0] == biu_lf_real_hazard[3]")
  u_ovl_intf_assume_8e808af570f40405267e48987d49c8052f021be0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[3] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[3]) & (stb_slot0_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_lf_real_hazard[0] == biu_lf_real_hazard[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[4] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[4]) & (stb_slot0_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_real_hazard[0] == biu_lf_real_hazard[4]")
  u_ovl_intf_assume_40ef6adf5186406e1f4cd19f59a601ad548d5daa (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[4] & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[4]) & (stb_slot0_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_real_hazard[0] == biu_lf_real_hazard[4]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[2] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[2]) & (stb_slot1_addr[39:6] == stb_slot2_addr[39:6]))  => biu_lf_real_hazard[1] == biu_lf_real_hazard[2]")
  u_ovl_intf_assume_6b2525b841f5a298d40a30dea174b54971472b85 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[2] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[2]) & (stb_slot1_addr[39:6] == stb_slot2_addr[39:6])) ),
    .consequent_expr (biu_lf_real_hazard[1] == biu_lf_real_hazard[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[3] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[3]) & (stb_slot1_addr[39:6] == stb_slot3_addr[39:6]))  => biu_lf_real_hazard[1] == biu_lf_real_hazard[3]")
  u_ovl_intf_assume_f0326da59a972650daa3d530b502b92eacff4753 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[3] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[3]) & (stb_slot1_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_lf_real_hazard[1] == biu_lf_real_hazard[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[4] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[4]) & (stb_slot1_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_real_hazard[1] == biu_lf_real_hazard[4]")
  u_ovl_intf_assume_5023000497d0db2923a229fc01456cca2a504541 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[4] & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[4]) & (stb_slot1_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_real_hazard[1] == biu_lf_real_hazard[4]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[2] & stb_slots_valid[3] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[3]) & (stb_slot2_addr[39:6] == stb_slot3_addr[39:6]))  => biu_lf_real_hazard[2] == biu_lf_real_hazard[3]")
  u_ovl_intf_assume_804de8f51225c9d6434dd4c5df91b9c39d2e2830 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[2] & stb_slots_valid[3] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[3]) & (stb_slot2_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_lf_real_hazard[2] == biu_lf_real_hazard[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[2] & stb_slots_valid[4] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[4]) & (stb_slot2_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_real_hazard[2] == biu_lf_real_hazard[4]")
  u_ovl_intf_assume_8ffdc3d21303d0529d66d378a1eb90c8f3038930 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[2] & stb_slots_valid[4] & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[4]) & (stb_slot2_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_real_hazard[2] == biu_lf_real_hazard[4]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[3] & stb_slots_valid[4] & (stb_slots_ns_dsc[3] == stb_slots_ns_dsc[4]) & (stb_slot3_addr[39:6] == stb_slot4_addr[39:6]))  => biu_lf_real_hazard[3] == biu_lf_real_hazard[4]")
  u_ovl_intf_assume_4f94717f4656ae4f8b0c14fd0796f17b059a59e6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[3] & stb_slots_valid[4] & (stb_slots_ns_dsc[3] == stb_slots_ns_dsc[4]) & (stb_slot3_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_lf_real_hazard[3] == biu_lf_real_hazard[4]));


  // If one slot gets an eviction hazard then all slots in the same line must
  // also get the hazard.

  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[1] & (stb_slot0_way == stb_slot1_way) & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[1]) & (stb_slot0_addr[39:6] == stb_slot1_addr[39:6]))  => biu_ev_hazard[0] == biu_ev_hazard[1]")
  u_ovl_intf_assume_d524bbe573bb19540034bd76f548e6fe0b7a0b03 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[1] & (stb_slot0_way == stb_slot1_way) & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[1]) & (stb_slot0_addr[39:6] == stb_slot1_addr[39:6])) ),
    .consequent_expr (biu_ev_hazard[0] == biu_ev_hazard[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[2] & (stb_slot0_way == stb_slot2_way) & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[2]) & (stb_slot0_addr[39:6] == stb_slot2_addr[39:6]))  => biu_ev_hazard[0] == biu_ev_hazard[2]")
  u_ovl_intf_assume_b7c46f18bd3a07453dee4aefcf6021297741f114 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[2] & (stb_slot0_way == stb_slot2_way) & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[2]) & (stb_slot0_addr[39:6] == stb_slot2_addr[39:6])) ),
    .consequent_expr (biu_ev_hazard[0] == biu_ev_hazard[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[3] & (stb_slot0_way == stb_slot3_way) & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[3]) & (stb_slot0_addr[39:6] == stb_slot3_addr[39:6]))  => biu_ev_hazard[0] == biu_ev_hazard[3]")
  u_ovl_intf_assume_77fe26d212f14d6652db93773d4e42ca9100ebbc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[3] & (stb_slot0_way == stb_slot3_way) & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[3]) & (stb_slot0_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_ev_hazard[0] == biu_ev_hazard[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[0] & stb_slots_valid[4] & (stb_slot0_way == stb_slot4_way) & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[4]) & (stb_slot0_addr[39:6] == stb_slot4_addr[39:6]))  => biu_ev_hazard[0] == biu_ev_hazard[4]")
  u_ovl_intf_assume_97627911affba8aa4c767768c946ef097f8cb6d9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[0] & stb_slots_valid[4] & (stb_slot0_way == stb_slot4_way) & (stb_slots_ns_dsc[0] == stb_slots_ns_dsc[4]) & (stb_slot0_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_ev_hazard[0] == biu_ev_hazard[4]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[2] & (stb_slot1_way == stb_slot2_way) & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[2]) & (stb_slot1_addr[39:6] == stb_slot2_addr[39:6]))  => biu_ev_hazard[1] == biu_ev_hazard[2]")
  u_ovl_intf_assume_fef9e0c6649984ebbba124aa40fea290b7f9076c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[2] & (stb_slot1_way == stb_slot2_way) & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[2]) & (stb_slot1_addr[39:6] == stb_slot2_addr[39:6])) ),
    .consequent_expr (biu_ev_hazard[1] == biu_ev_hazard[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[3] & (stb_slot1_way == stb_slot3_way) & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[3]) & (stb_slot1_addr[39:6] == stb_slot3_addr[39:6]))  => biu_ev_hazard[1] == biu_ev_hazard[3]")
  u_ovl_intf_assume_d05c67596479c189d3d4bf627041e5bfd80456c6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[3] & (stb_slot1_way == stb_slot3_way) & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[3]) & (stb_slot1_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_ev_hazard[1] == biu_ev_hazard[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[1] & stb_slots_valid[4] & (stb_slot1_way == stb_slot4_way) & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[4]) & (stb_slot1_addr[39:6] == stb_slot4_addr[39:6]))  => biu_ev_hazard[1] == biu_ev_hazard[4]")
  u_ovl_intf_assume_93914ffbbacc810a38cd64c19dd9c2a1b033daf3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[1] & stb_slots_valid[4] & (stb_slot1_way == stb_slot4_way) & (stb_slots_ns_dsc[1] == stb_slots_ns_dsc[4]) & (stb_slot1_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_ev_hazard[1] == biu_ev_hazard[4]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[2] & stb_slots_valid[3] & (stb_slot2_way == stb_slot3_way) & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[3]) & (stb_slot2_addr[39:6] == stb_slot3_addr[39:6]))  => biu_ev_hazard[2] == biu_ev_hazard[3]")
  u_ovl_intf_assume_b32a5add28e2aaf23e274f0f80cc10fa03a625b3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[2] & stb_slots_valid[3] & (stb_slot2_way == stb_slot3_way) & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[3]) & (stb_slot2_addr[39:6] == stb_slot3_addr[39:6])) ),
    .consequent_expr (biu_ev_hazard[2] == biu_ev_hazard[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[2] & stb_slots_valid[4] & (stb_slot2_way == stb_slot4_way) & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[4]) & (stb_slot2_addr[39:6] == stb_slot4_addr[39:6]))  => biu_ev_hazard[2] == biu_ev_hazard[4]")
  u_ovl_intf_assume_fca7f7a9d2518f003101a6bfca5d46769fb3c183 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[2] & stb_slots_valid[4] & (stb_slot2_way == stb_slot4_way) & (stb_slots_ns_dsc[2] == stb_slots_ns_dsc[4]) & (stb_slot2_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_ev_hazard[2] == biu_ev_hazard[4]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(stb_slots_valid[3] & stb_slots_valid[4] & (stb_slot3_way == stb_slot4_way) & (stb_slots_ns_dsc[3] == stb_slots_ns_dsc[4]) & (stb_slot3_addr[39:6] == stb_slot4_addr[39:6]))  => biu_ev_hazard[3] == biu_ev_hazard[4]")
  u_ovl_intf_assume_98f8682083f53abfe0f519cf9f1f6e3f3bf01d00 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((stb_slots_valid[3] & stb_slots_valid[4] & (stb_slot3_way == stb_slot4_way) & (stb_slots_ns_dsc[3] == stb_slots_ns_dsc[4]) & (stb_slot3_addr[39:6] == stb_slot4_addr[39:6])) ),
    .consequent_expr (biu_ev_hazard[3] == biu_ev_hazard[4]));


  // Only one slot can write to the cache at a time.

  assert_zero_one_hot #(`OVL_FATAL, 5, OUTOPTIONS, "stb_slot_cachewrite_m1")
  u_ovl_intf_assert_ffa669cfa9c3ae3cbbb6b9ccb3d423369dd80479 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (stb_slot_cachewrite_m1));


  // The STB should never write data to the cache if it is requesting a linefill.

  assert_always #(`OVL_FATAL, OUTOPTIONS, "~|(stb_slot_cachewrite_m1 & stb_lf_req)")
  u_ovl_intf_assert_6737e6bd9c0b2c6b2f8c6465d48f93eb10783722 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (~|(stb_slot_cachewrite_m1 & stb_lf_req)));


  // The STB cannot make a linefill request from an empty slot.

  assert_always #(`OVL_FATAL, OUTOPTIONS, "~|(stb_lf_req & ~stb_slots_valid)")
  u_ovl_intf_assert_446acf4f9a6cf6d3c6a1a3661597e3fc601a1d5e (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (~|(stb_lf_req & ~stb_slots_valid)));


  // The STB cannot write to the cache from an empty slot.

  assert_always #(`OVL_FATAL, OUTOPTIONS, "~|(stb_slot_cachewrite_m1 & ~stb_slots_valid)")
  u_ovl_intf_assert_f0df9be3856031eeca145abf693be5efdf626f88 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (~|(stb_slot_cachewrite_m1 & ~stb_slots_valid)));


  // The STB cannot write to the cache in the first cycle the slot was valid.

  assert_always #(`OVL_FATAL, OUTOPTIONS, "~|(stb_slot_cachewrite_m1 & ~stb_slots_valid@1)")
  u_ovl_intf_assert_653ae8c2809f1280089c2e215200ff5ef00b2803 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (~|(stb_slot_cachewrite_m1 & ~stb_slots_valid_reg)));


  // Linefills may only be requested from slots that are cacheable.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_lf_req[0]  => `CA53_MEM_NORMAL(stb_slot0_attrs) & `CA53_MEM_WB(stb_slot0_attrs)")
  u_ovl_intf_assert_f630a7920967ca19cabf0f506663b86c931cb9ee (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_lf_req[0] ),
    .consequent_expr (`CA53_MEM_NORMAL(stb_slot0_attrs) & `CA53_MEM_WB(stb_slot0_attrs)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_lf_req[1]  => `CA53_MEM_NORMAL(stb_slot1_attrs) & `CA53_MEM_WB(stb_slot1_attrs)")
  u_ovl_intf_assert_d0460bcfa4f64040fb29784375b79b538b75d300 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_lf_req[1] ),
    .consequent_expr (`CA53_MEM_NORMAL(stb_slot1_attrs) & `CA53_MEM_WB(stb_slot1_attrs)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_lf_req[2]  => `CA53_MEM_NORMAL(stb_slot2_attrs) & `CA53_MEM_WB(stb_slot2_attrs)")
  u_ovl_intf_assert_0203de5b07f8ed992211b2e632ac8181b47fd300 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_lf_req[2] ),
    .consequent_expr (`CA53_MEM_NORMAL(stb_slot2_attrs) & `CA53_MEM_WB(stb_slot2_attrs)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_lf_req[3]  => `CA53_MEM_NORMAL(stb_slot3_attrs) & `CA53_MEM_WB(stb_slot3_attrs)")
  u_ovl_intf_assert_55eb06422d166779bcc0370cea25c44fc8ead304 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_lf_req[3] ),
    .consequent_expr (`CA53_MEM_NORMAL(stb_slot3_attrs) & `CA53_MEM_WB(stb_slot3_attrs)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_lf_req[4]  => `CA53_MEM_NORMAL(stb_slot4_attrs) & `CA53_MEM_WB(stb_slot4_attrs)")
  u_ovl_intf_assert_ef2eeb0ade6088dee3346eaa8ffe67df0cdffd06 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_lf_req[4] ),
    .consequent_expr (`CA53_MEM_NORMAL(stb_slot4_attrs) & `CA53_MEM_WB(stb_slot4_attrs)));


  // Linefills may only be requested from slots containing stores.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|stb_lf_req  => stb_has_store_slots")
  u_ovl_intf_assert_2b30b4153b9069b2e1c09410d00cfc08f67dc601 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|stb_lf_req ),
    .consequent_expr (stb_has_store_slots));


  // The STB should always indicate which linefill request is the earliest.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|stb_lf_req  => |stb_lf_earliest_slot")
  u_ovl_intf_assert_6df0aca4b631493100d400b683c45723b74e561e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|stb_lf_req ),
    .consequent_expr (|stb_lf_earliest_slot));


  // The earliest slot making a linefill request must be making a linefill request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|stb_lf_req  => ~|(stb_lf_earliest_slot & ~stb_lf_req)")
  u_ovl_intf_assert_8e171109549f440fe9475e23ded14312dfe544ee (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|stb_lf_req ),
    .consequent_expr (~|(stb_lf_earliest_slot & ~stb_lf_req)));


  // Only one STB slot can make the earliest linefill request.

  assert_zero_one_hot #(`OVL_FATAL, 5, OUTOPTIONS, "({5{|stb_lf_req}} & stb_lf_earliest_slot)")
  u_ovl_intf_assert_832ff6e1ed68787557613e6f3010d2f12e5d18a0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (({5{|stb_lf_req}} & stb_lf_earliest_slot)));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    write_in_m1 <= 1'b0;
  else if (dcu_stb_data_ack_m1 | ~write_in_m1)
    write_in_m1 <= stb_cache_data_req_m0 & stb_cache_data_wr_m0 & dcu_stb_data_has_priority_m0;


  // The STB must only write to the cache when it has priority.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|stb_slot_cachewrite_m1  => write_in_m1")
  u_ovl_intf_assert_ac2d6a042ca39b2945eeeee1aa351b7da4c61b35 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|stb_slot_cachewrite_m1 ),
    .consequent_expr (write_in_m1));


  // The STB linefill must have been previously active if a linefill request is made

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|stb_lf_req  => stb_lf_active@1")
  u_ovl_intf_assert_f9f97e4caa4a389c35f569fa463eaf7f1576a9c5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|stb_lf_req ),
    .consequent_expr (stb_lf_active_reg));


  // The STB slot has to be valid if the slot linefill merge is asserted

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_lf_merge[0]  => stb_slots_valid[0]")
  u_ovl_intf_assert_1574021068970516a7c36a67ad81aba5be33422e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_lf_merge[0] ),
    .consequent_expr (stb_slots_valid[0]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_lf_merge[1]  => stb_slots_valid[1]")
  u_ovl_intf_assert_a190d2f3c9594de6d4713ec4c4d5af5175df7b9a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_lf_merge[1] ),
    .consequent_expr (stb_slots_valid[1]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_lf_merge[2]  => stb_slots_valid[2]")
  u_ovl_intf_assert_562f4ac871f6071facad96c445c643fdd4fd6285 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_lf_merge[2] ),
    .consequent_expr (stb_slots_valid[2]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_lf_merge[3]  => stb_slots_valid[3]")
  u_ovl_intf_assert_c02aefc8c66ddb398198e8c724595bed6af748a1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_lf_merge[3] ),
    .consequent_expr (stb_slots_valid[3]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_lf_merge[4]  => stb_slots_valid[4]")
  u_ovl_intf_assert_12a17789e6174121059719b5d909224c58b003c3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_lf_merge[4] ),
    .consequent_expr (stb_slots_valid[4]));


  // If the BIU says the STB can merge then it must continue to allow the STB to
  // merge until the merge request has gone away.

  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_lf_merge[0] & stb_lf_merge@1[0] & biu_lf_can_merge@1[0]  => biu_lf_can_merge[0]")
  u_ovl_intf_assume_2802db11d5bcb9c76318b6eea0e0554985ca9a1c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_lf_merge[0] & stb_lf_merge_reg[0] & biu_lf_can_merge_reg[0] ),
    .consequent_expr (biu_lf_can_merge[0]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_lf_merge[1] & stb_lf_merge@1[1] & biu_lf_can_merge@1[1]  => biu_lf_can_merge[1]")
  u_ovl_intf_assume_5d6afb92acec5d9043deaf7571ba74941d85cdf3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_lf_merge[1] & stb_lf_merge_reg[1] & biu_lf_can_merge_reg[1] ),
    .consequent_expr (biu_lf_can_merge[1]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_lf_merge[2] & stb_lf_merge@1[2] & biu_lf_can_merge@1[2]  => biu_lf_can_merge[2]")
  u_ovl_intf_assume_dab53226813a08a0fedf9f9998ae81a749000f35 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_lf_merge[2] & stb_lf_merge_reg[2] & biu_lf_can_merge_reg[2] ),
    .consequent_expr (biu_lf_can_merge[2]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_lf_merge[3] & stb_lf_merge@1[3] & biu_lf_can_merge@1[3]  => biu_lf_can_merge[3]")
  u_ovl_intf_assume_0376bcb98c9f064a597f03d5171be91008901b1c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_lf_merge[3] & stb_lf_merge_reg[3] & biu_lf_can_merge_reg[3] ),
    .consequent_expr (biu_lf_can_merge[3]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "stb_lf_merge[4] & stb_lf_merge@1[4] & biu_lf_can_merge@1[4]  => biu_lf_can_merge[4]")
  u_ovl_intf_assume_435f68ebacf8a8a38f1df9a08ba22de96f70749a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_lf_merge[4] & stb_lf_merge_reg[4] & biu_lf_can_merge_reg[4] ),
    .consequent_expr (biu_lf_can_merge[4]));


  //----------------------------------------------------------------------------
  //
  // Write channel to SCU
  //
  //----------------------------------------------------------------------------

  // The STB is sending a write that the BIU should send on the write
  // channel to the SCU.
  // The request must not be dropped once it has started.
  //  output stb_biu_write_req valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "stb_biu_write_req X or Z")
  u_ovl_intf_x_stb_biu_write_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_biu_write_req));


  // The L2 data buffer ID that has previously been allocated for this write.
  //  output [3:0] stb_biu_write_l2dbid valid stb_biu_write_req timing 50%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "stb_biu_write_l2dbid X or Z")
  u_ovl_intf_x_stb_biu_write_l2dbid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_biu_write_req),
    .test_expr (stb_biu_write_l2dbid));


  // The quadword chunk within the cacheline that the access relates to.
  //  output [1:0] stb_biu_write_chunk valid stb_biu_write_req timing 50%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "stb_biu_write_chunk X or Z")
  u_ovl_intf_x_stb_biu_write_chunk (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_biu_write_req),
    .test_expr (stb_biu_write_chunk));


  assign stb_biu_write_data_valid  = {16{stb_biu_write_req}} & stb_biu_write_bls;

  assign stb_biu_write_data_valid_mask  = {{8{stb_biu_write_data_valid[15]}}, {8{stb_biu_write_data_valid[14]}}, {8{stb_biu_write_data_valid[13]}}, {8{stb_biu_write_data_valid[12]}}, {8{stb_biu_write_data_valid[11]}}, {8{stb_biu_write_data_valid[10]}}, {8{stb_biu_write_data_valid[9]}}, {8{stb_biu_write_data_valid[8]}}, {8{stb_biu_write_data_valid[7]}}, {8{stb_biu_write_data_valid[6]}}, {8{stb_biu_write_data_valid[5]}}, {8{stb_biu_write_data_valid[4]}}, {8{stb_biu_write_data_valid[3]}}, {8{stb_biu_write_data_valid[2]}}, {8{stb_biu_write_data_valid[1]}}, {8{stb_biu_write_data_valid[0]}}};

  // The write data.
  //  output [127:0] stb_biu_write_data valid mask stb_biu_write_data_valid_mask timing 60%

  assert_never_unknown #(`OVL_FATAL, 128, OUTOPTIONS, "stb_biu_write_data & (stb_biu_write_data_valid_mask) X or Z")
  u_ovl_intf_x_de9db0bd880f1cb6e00a7a1ab0cd8c8bbb797582 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_biu_write_data & (stb_biu_write_data_valid_mask)));


  // The byte lane strobes of the slot making the write request. Some requests
  // can have no byte strobes set (watchpointed device STMs).
  //  output [15:0] stb_biu_write_bls valid stb_biu_write_req timing 60%

  assert_never_unknown #(`OVL_FATAL, 16, OUTOPTIONS, "stb_biu_write_bls X or Z")
  u_ovl_intf_x_stb_biu_write_bls (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_biu_write_req),
    .test_expr (stb_biu_write_bls));


  // The chunk is the last in this line that the STB has data for.
  //  output stb_biu_write_last valid stb_biu_write_req timing 75%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "stb_biu_write_last X or Z")
  u_ovl_intf_x_stb_biu_write_last (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_biu_write_req),
    .test_expr (stb_biu_write_last));


  // If a request is being made, then the BIU will accept it this cycle.
  // This signal may be asserted when a request isn't being made, in which case
  // the STB can ignore it.
  //  input biu_stb_write_accept valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_stb_write_accept X or Z")
  u_ovl_intf_x_biu_stb_write_accept (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_stb_write_accept));


  // The STB has a slot that is active and may make a biu write request in the
  // following cycle.
  //  output stb_biu_write_req_active valid always timing 90%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "stb_biu_write_req_active X or Z")
  u_ovl_intf_x_stb_biu_write_req_active (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_biu_write_req_active));


  // A write request can only be sent to the BIU when there is a valid STB slot

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_biu_write_req  => |stb_slots_valid")
  u_ovl_intf_assert_e4011e7537d5225b0c53f30ea52d92c158f2a79d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_biu_write_req ),
    .consequent_expr (|stb_slots_valid));


  // A slot must have previously been active if a request is being made.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_biu_write_req  => stb_biu_write_req_active@1")
  u_ovl_intf_assert_9a5152d22f84923e2e25194dcf66397b0f01058e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_biu_write_req ),
    .consequent_expr (stb_biu_write_req_active_reg));



  //----------------------------------------------------------------------------
  //
  // Read allocate mode
  //
  //----------------------------------------------------------------------------

  // The BIU is currently in read allocate mode.
  //  input biu_read_alloc_mode valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_read_alloc_mode X or Z")
  u_ovl_intf_x_biu_read_alloc_mode (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_read_alloc_mode));



  //----------------------------------------------------------------------------
  //
  // Cache maintenance, DVM, CleanUnique, and write address requests
  //
  //----------------------------------------------------------------------------

  // The STB wants the BIU to send an address request to the SCU on the ar
  // channel. The STB must hold the request until it receives an ack from the
  // BIU. Any request made in the cycle an ack is being returned must be
  // ignored by the BIU.
  //  output stb_ar_req valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "stb_ar_req X or Z")
  u_ovl_intf_x_stb_ar_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_ar_req));


  // An earlier, speculative, request indication. Used to enable clock gates.
  //  output stb_ar_early_req valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "stb_ar_early_req X or Z")
  u_ovl_intf_x_stb_ar_early_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (stb_ar_early_req));


  // The ID the BIU should use on the ar channel to send to the SCU.
  //  output [4:0] stb_ar_id valid stb_ar_req timing 60%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "stb_ar_id X or Z")
  u_ovl_intf_x_stb_ar_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_ar_req),
    .test_expr (stb_ar_id));


  // The way for CleanUnique that the BIU should use on the ar channel to send
  // to the SCU.
  //  output [1:0] stb_ar_way valid stb_ar_req timing 60%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "stb_ar_way X or Z")
  u_ovl_intf_x_stb_ar_way (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_ar_req),
    .test_expr (stb_ar_way));


  // The type of coherency request to be sent. This has the same encoding as
  // the CP ops from the DCU to STB.
  //  output [7:0] stb_ar_type valid stb_ar_req timing 60%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "stb_ar_type X or Z")
  u_ovl_intf_x_stb_ar_type (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_ar_req),
    .test_expr (stb_ar_type));


  // The address of the request or the cache set/level for the D-cache maintenance ops by set/way.
  // D-cache maintenance ops by set/way address encoding: stb_ar_addr[16:6] = Set, stb_ar_addr[3:1] = Level.
  //  output [39:0] stb_ar_addr valid stb_ar_req timing 60%

  assert_never_unknown #(`OVL_FATAL, 40, OUTOPTIONS, "stb_ar_addr X or Z")
  u_ovl_intf_x_stb_ar_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_ar_req),
    .test_expr (stb_ar_addr));


  // The TrustZone non-secure bit of the request.
  // For non-address based maintenance operations it is instead the ns_state
  // of the DPU when the instruction was executed.
  //  output stb_ar_ns_dsc valid stb_ar_req timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "stb_ar_ns_dsc X or Z")
  u_ovl_intf_x_stb_ar_ns_dsc (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_ar_req),
    .test_expr (stb_ar_ns_dsc));


  // The attributes to send for non-DVM messages.
  //  output [7:0] stb_ar_attrs valid stb_ar_req timing 60%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "stb_ar_attrs X or Z")
  u_ovl_intf_x_stb_ar_attrs (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_ar_req),
    .test_expr (stb_ar_attrs));


  // The privilege state. Non-exclusive writes to normal memory should always
  // be marked as privileged.
  // For non-address based maintenance operations it is instead the scr_el3.ns
  // bit from the DPU when the instruction was executed.
  //  output stb_ar_priv valid stb_ar_req timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "stb_ar_priv X or Z")
  u_ovl_intf_x_stb_ar_priv (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_ar_req),
    .test_expr (stb_ar_priv));


  // The request is due to a STREX, and so should have ARLOCK set.
  //  output stb_ar_excl valid stb_ar_req timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "stb_ar_excl X or Z")
  u_ovl_intf_x_stb_ar_excl (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_ar_req),
    .test_expr (stb_ar_excl));


  // The ASID to send if required for DVM messages.
  //  output [15:0] stb_ar_asid valid stb_ar_req & stb_ar_type_dvm timing 60%

  assert_never_unknown #(`OVL_FATAL, 16, OUTOPTIONS, "stb_ar_asid X or Z")
  u_ovl_intf_x_stb_ar_asid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_ar_req & stb_ar_type_dvm),
    .test_expr (stb_ar_asid));


  // The VMID to send if required for DVM messages.
  //  output [7:0] stb_ar_vmid valid stb_ar_req & stb_ar_type_dvm timing 60%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "stb_ar_vmid X or Z")
  u_ovl_intf_x_stb_ar_vmid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_ar_req & stb_ar_type_dvm),
    .test_expr (stb_ar_vmid));


  // Bits {[48:40], [27:12]} of the VA to send if required for DVM messages.
  //  output [24:0] stb_ar_va valid stb_ar_req & stb_ar_type_dvm timing 60%

  assert_never_unknown #(`OVL_FATAL, 25, OUTOPTIONS, "stb_ar_va X or Z")
  u_ovl_intf_x_stb_ar_va (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (stb_ar_req & stb_ar_type_dvm),
    .test_expr (stb_ar_va));


  // The response from the BIU to say that the request has been accepted and
  // presented to the SCU (but not completed).  For multi-part DVM messages,
  // the ack will be sent when the BIU is presenting the last part to the SCU.
  //  input biu_stb_ar_ack valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_stb_ar_ack X or Z")
  u_ovl_intf_x_biu_stb_ar_ack (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_stb_ar_ack));


  // A read response has been received by the BIU.
  //  input biu_stb_ar_resp_valid valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_stb_ar_resp_valid X or Z")
  u_ovl_intf_x_biu_stb_ar_resp_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_stb_ar_resp_valid));


  // The value of the read response.
  //  input [1:0] biu_stb_ar_resp valid biu_stb_ar_resp_valid timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "biu_stb_ar_resp X or Z")
  u_ovl_intf_x_biu_stb_ar_resp (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_stb_ar_resp_valid),
    .test_expr (biu_stb_ar_resp));


  // The ID of the response.
  //  input [4:0] biu_stb_ar_resp_id valid biu_stb_ar_resp_valid timing 30%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "biu_stb_ar_resp_id X or Z")
  u_ovl_intf_x_biu_stb_ar_resp_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_stb_ar_resp_valid),
    .test_expr (biu_stb_ar_resp_id));


  // The L2 data buffer allocated in the SCU, for write and DVM requests.
  //  input [3:0] biu_stb_ar_resp_l2dbid valid biu_stb_ar_resp_valid timing 30%

  assert_never_unknown #(`OVL_FATAL, 4, INOPTIONS, "biu_stb_ar_resp_l2dbid X or Z")
  u_ovl_intf_x_biu_stb_ar_resp_l2dbid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_stb_ar_resp_valid),
    .test_expr (biu_stb_ar_resp_l2dbid));



  assign stb_ar_type_ic  = ((stb_ar_type == `CA53_CPOP_8_ICIALLUIS) | (stb_ar_type ==   `CA53_CPOP_8_ICIALLU) | (stb_ar_type ==  `CA53_CPOP_8_ICIMVAU));

  assign stb_ar_type_dc  = ((stb_ar_type == `CA53_CPOP_8_DCISW) | (stb_ar_type ==  `CA53_CPOP_8_DCCSW) | (stb_ar_type ==  `CA53_CPOP_8_DCCISW) | (stb_ar_type ==  `CA53_CPOP_8_DCIMVAC) | (stb_ar_type ==  `CA53_CPOP_8_DCCMVAC) | (stb_ar_type ==  `CA53_CPOP_8_DCCMVAU) | (stb_ar_type ==  `CA53_CPOP_8_DCCIMVAC));

  assign stb_ar_type_tlb  = ((stb_ar_type == `CA53_CPOP_8_TLBIALL) | (stb_ar_type ==  `CA53_CPOP_8_TLBIALLIS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIMVA) | (stb_ar_type ==  `CA53_CPOP_8_TLBIMVAIS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIASID) | (stb_ar_type ==  `CA53_CPOP_8_TLBIASIDIS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIMVAA) | (stb_ar_type ==  `CA53_CPOP_8_TLBIMVAAIS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIMVAH) | (stb_ar_type ==  `CA53_CPOP_8_TLBIMVAHIS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIALLH) | (stb_ar_type ==  `CA53_CPOP_8_TLBIALLHIS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIALLNSNH) | (stb_ar_type ==  `CA53_CPOP_8_TLBIALLNSNHIS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIMVAL) | (stb_ar_type ==  `CA53_CPOP_8_TLBIMVALIS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIMVAAL) | (stb_ar_type ==  `CA53_CPOP_8_TLBIMVAALIS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIMVALH) | (stb_ar_type ==  `CA53_CPOP_8_TLBIMVALHIS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIIPAS2) | (stb_ar_type ==  `CA53_CPOP_8_TLBIIPAS2IS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIIPAS2L) | (stb_ar_type ==  `CA53_CPOP_8_TLBIIPAS2LIS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVAE1) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVAE1IS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVALE1) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVALE1IS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVAAE1) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVAAE1IS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVAALE1) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVAALE1IS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIIPAS2E1) | (stb_ar_type ==  `CA53_CPOP_8_TLBIIPAS2E1IS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIIPAS2LE1) | (stb_ar_type ==  `CA53_CPOP_8_TLBIIPAS2LE1IS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVAE2) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVAE2IS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVALE2) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVALE2IS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVAE3) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVAE3IS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVALE3) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVALE3IS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIASIDE1) | (stb_ar_type ==  `CA53_CPOP_8_TLBIASIDE1IS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVMALLE1) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVMALLE1IS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVMALLS12E1) | (stb_ar_type ==  `CA53_CPOP_8_TLBIVMALLS12E1IS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIALLE1) | (stb_ar_type ==  `CA53_CPOP_8_TLBIALLE1IS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIALLE2) | (stb_ar_type ==  `CA53_CPOP_8_TLBIALLE2IS) | (stb_ar_type ==  `CA53_CPOP_8_TLBIALLE3) | (stb_ar_type ==  `CA53_CPOP_8_TLBIALLE3IS));

  assign stb_ar_type_bp  = ((stb_ar_type == `CA53_CPOP_8_BPIALLIS) | (stb_ar_type ==  `CA53_CPOP_8_BPIMVA));

  assign stb_ar_type_bar  = ((stb_ar_type == `CA53_CPOP_8_DSBNS) | (stb_ar_type ==  `CA53_CPOP_8_DSBIS) | (stb_ar_type ==  `CA53_CPOP_8_DSBOS) | (stb_ar_type ==  `CA53_CPOP_8_DSBSY) | (stb_ar_type ==  `CA53_CPOP_8_DMBNS) | (stb_ar_type ==  `CA53_CPOP_8_DMBIS) | (stb_ar_type ==  `CA53_CPOP_8_DMBOS) | (stb_ar_type ==  `CA53_CPOP_8_DMBSY) | (stb_ar_type ==  `CA53_CPOP_8_DMBNSST) | (stb_ar_type ==  `CA53_CPOP_8_DMBISST) | (stb_ar_type ==  `CA53_CPOP_8_DMBOSST) | (stb_ar_type ==  `CA53_CPOP_8_DMBSYST));

  assign stb_ar_type_dvm  = stb_ar_type_ic | stb_ar_type_bp | stb_ar_type_tlb | (stb_ar_type == `CA53_CPOP_8_SYNC);

  // An early request must be signaled if a real request is being made.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req  => stb_ar_early_req")
  u_ovl_intf_assert_95a969938b5cb8a66b83782736dc7fde00edd03b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req ),
    .consequent_expr (stb_ar_early_req));


  // An early request must be signaled if a linefill request is being made.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|stb_lf_req  => stb_ar_early_req")
  u_ovl_intf_assert_41464f4fdf5ad2f5c2a77c7cbf390360dfcb1280 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|stb_lf_req ),
    .consequent_expr (stb_ar_early_req));


  // Only valid types allowed.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req  => stb_ar_type_ic | stb_ar_type_bp | stb_ar_type_tlb | stb_ar_type_dc | stb_ar_type_bar | stb_ar_type in [`CA53_CPOP_8_CLEANUNIQUE, `CA53_CPOP_8_SYNC, `CA53_CPOP_8_WRITE]")
  u_ovl_intf_assert_8e07c281a5ebe1493f63c6c0d2aab84ba1852b89 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req ),
    .consequent_expr (stb_ar_type_ic | stb_ar_type_bp | stb_ar_type_tlb | stb_ar_type_dc | stb_ar_type_bar | ((stb_ar_type == `CA53_CPOP_8_CLEANUNIQUE) | (stb_ar_type ==  `CA53_CPOP_8_SYNC) | (stb_ar_type ==  `CA53_CPOP_8_WRITE))));


  // Dcache clean/invalidate requests must be to inner WB memory.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req & stb_ar_type_dc & (stb_ar_type != `CA53_CPOP_8_DCCMVAU)  => (`CA53_MEM_WB(stb_ar_attrs) & `CA53_MEM_OUTER_WB(stb_ar_attrs))")
  u_ovl_intf_assert_3efe6863e7682f907c68f607a4188cb07ed7b28d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req & stb_ar_type_dc & (stb_ar_type != `CA53_CPOP_8_DCCMVAU) ),
    .consequent_expr ((`CA53_MEM_WB(stb_ar_attrs) & `CA53_MEM_OUTER_WB(stb_ar_attrs))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req & (stb_ar_type == `CA53_CPOP_8_DCCMVAU)  => (`CA53_MEM_WB(stb_ar_attrs) & `CA53_MEM_OUTER_NC(stb_ar_attrs))")
  u_ovl_intf_assert_f41f098e99828c93d6e3a045ccd3f4a265bcb0e6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req & (stb_ar_type == `CA53_CPOP_8_DCCMVAU) ),
    .consequent_expr ((`CA53_MEM_WB(stb_ar_attrs) & `CA53_MEM_OUTER_NC(stb_ar_attrs))));


  // CleanUnique requests must be to coherent memory.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req & (stb_ar_type == `CA53_CPOP_8_CLEANUNIQUE)  => `CA53_MEM_COHERENT(stb_ar_attrs)")
  u_ovl_intf_assert_460b6bad3633837b1f1d8d631c44196b44033ded (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req & (stb_ar_type == `CA53_CPOP_8_CLEANUNIQUE) ),
    .consequent_expr (`CA53_MEM_COHERENT(stb_ar_attrs)));


  // Only CleanUnique and write requests may be exclusive.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req & !(stb_ar_type in [`CA53_CPOP_8_CLEANUNIQUE, `CA53_CPOP_8_WRITE])  => ~stb_ar_excl")
  u_ovl_intf_assert_c3f8ad76aa8b8f7c98812ee6078753d9cd319949 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req & !(((stb_ar_type == `CA53_CPOP_8_CLEANUNIQUE) | (stb_ar_type ==  `CA53_CPOP_8_WRITE))) ),
    .consequent_expr (~stb_ar_excl));


  // Exclusive requests must be to shareable memory.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req & stb_ar_excl  => `CA53_MEM_SHAREABLE(stb_ar_attrs)")
  u_ovl_intf_assert_f84bbffd877fc4a0365b285a3ef8023e7da2ef5f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req & stb_ar_excl ),
    .consequent_expr (`CA53_MEM_SHAREABLE(stb_ar_attrs)));


  // The BIU suppresses WRITEUNIQUE AR requests if there is a linefill hazard.
  assign biu_ar_req_suppress  = stb_ar_req & (stb_ar_type == `CA53_CPOP_8_WRITE) & `CA53_MEM_COHERENT(stb_ar_attrs) & |(biu_lf_hazard & {stb_ar_id == `CA53_RID_STB4, stb_ar_id == `CA53_RID_STB3, stb_ar_id == `CA53_RID_STB2, stb_ar_id == `CA53_RID_STB1, stb_ar_id == `CA53_RID_STB0});

  // The BIU must only ack if there is a request.

  assert_implication #(`OVL_FATAL, INOPTIONS, "biu_stb_ar_ack  => stb_ar_req@1 & ~biu_ar_req_suppress@1")
  u_ovl_intf_assume_8cffd5bf51e71990d55de4e77dfe472b398710d3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_stb_ar_ack ),
    .consequent_expr (stb_ar_req_reg & ~biu_ar_req_suppress_reg));


  // The STB must hold the request until it is acked. Stores are an
  // exception as the request might be dropped due to a load in the
  // sameline (so the data can be forwarded). The STB must observe
  // the acknowledge if it is returned in the cycle that the request
  // is dropped.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req@1 & ~biu_stb_ar_ack@1 & !(stb_ar_type@1 in [`CA53_CPOP_8_CLEANUNIQUE, `CA53_CPOP_8_WRITE])  => stb_ar_req")
  u_ovl_intf_assert_2c907e4b7173a37df6933ff6e7d0eedcda3328d1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req_reg & ~biu_stb_ar_ack_reg & !(((stb_ar_type_reg == `CA53_CPOP_8_CLEANUNIQUE) | (stb_ar_type_reg ==  `CA53_CPOP_8_WRITE))) ),
    .consequent_expr (stb_ar_req));


  // Back to back acks are not allowed.

  assert_implication #(`OVL_FATAL, INOPTIONS, "biu_stb_ar_ack  => ~biu_stb_ar_ack@1")
  u_ovl_intf_assume_f8fc1a1221cc9eadaa067bfcbda4bd7efc317c79 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_stb_ar_ack ),
    .consequent_expr (~biu_stb_ar_ack_reg));


  // The type, address and ns signals should be constant for the request.
  // Note that on Write and CleanUnique requests, the ID may change provided
  // that it changes to a slot that is in the sameline as the old slot.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req@1 & ~biu_stb_ar_ack@1 & ~biu_ar_req_suppress@1  => stb_ar_type == stb_ar_type@1")
  u_ovl_intf_assert_380a59d90a7dfbb2be7a8c6da25906892e67f8b1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req_reg & ~biu_stb_ar_ack_reg & ~biu_ar_req_suppress_reg ),
    .consequent_expr (stb_ar_type == stb_ar_type_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req@1 & ~biu_stb_ar_ack@1 & ~biu_ar_req_suppress@1  => stb_ar_ns_dsc == stb_ar_ns_dsc@1")
  u_ovl_intf_assert_ec0eb74373dd7834074f510ed0c8cd122e9d544d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req_reg & ~biu_stb_ar_ack_reg & ~biu_ar_req_suppress_reg ),
    .consequent_expr (stb_ar_ns_dsc == stb_ar_ns_dsc_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req@1 & ~biu_stb_ar_ack@1 & ~biu_ar_req_suppress@1  => stb_ar_addr[39:6] == stb_ar_addr@1[39:6]")
  u_ovl_intf_assert_933ee30a3d9e528f0f54597eb991bd6d9a088ff9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req_reg & ~biu_stb_ar_ack_reg & ~biu_ar_req_suppress_reg ),
    .consequent_expr (stb_ar_addr[39:6] == stb_ar_addr_reg[39:6]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req@1 & ~biu_stb_ar_ack@1 & ~biu_ar_req_suppress@1 & ~(stb_ar_type in [`CA53_CPOP_8_CLEANUNIQUE, `CA53_CPOP_8_WRITE])  => stb_ar_addr[5:0] == stb_ar_addr@1[5:0]")
  u_ovl_intf_assert_add20df6d754a5ac2825f0b4ff7ee832735604b4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req_reg & ~biu_stb_ar_ack_reg & ~biu_ar_req_suppress_reg & ~(((stb_ar_type == `CA53_CPOP_8_CLEANUNIQUE) | (stb_ar_type ==  `CA53_CPOP_8_WRITE))) ),
    .consequent_expr (stb_ar_addr[5:0] == stb_ar_addr_reg[5:0]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req@1 & ~biu_stb_ar_ack@1 & ~biu_ar_req_suppress@1 & ~(stb_ar_type in [`CA53_CPOP_8_CLEANUNIQUE, `CA53_CPOP_8_WRITE])  => stb_ar_id == stb_ar_id@1")
  u_ovl_intf_assert_b8a94e0a41c87668f5fceb9cd0b5730ffb6a6b22 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req_reg & ~biu_stb_ar_ack_reg & ~biu_ar_req_suppress_reg & ~(((stb_ar_type == `CA53_CPOP_8_CLEANUNIQUE) | (stb_ar_type ==  `CA53_CPOP_8_WRITE))) ),
    .consequent_expr (stb_ar_id == stb_ar_id_reg));


  // The way for a CleanUnique is always onehot.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req & (stb_ar_type == `CA53_CPOP_8_CLEANUNIQUE)  => stb_ar_way in [3'b000, 3'b001, 3'b010, 3'b011]")
  u_ovl_intf_assert_3db6adc7f30f21ee9a6654cbef53e767446773d4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req & (stb_ar_type == `CA53_CPOP_8_CLEANUNIQUE) ),
    .consequent_expr (((stb_ar_way == 3'b000) | (stb_ar_way ==  3'b001) | (stb_ar_way ==  3'b010) | (stb_ar_way ==  3'b011))));


  assign req_sent  = {5{biu_stb_ar_ack}} & {stb_ar_id_reg == `CA53_RID_STB4, stb_ar_id_reg == `CA53_RID_STB3, stb_ar_id_reg == `CA53_RID_STB2, stb_ar_id_reg == `CA53_RID_STB1, stb_ar_id_reg == `CA53_RID_STB0};

  assign resp_received  = {5{biu_stb_ar_resp_valid}} & {biu_stb_ar_resp_id == `CA53_RID_STB4, biu_stb_ar_resp_id == `CA53_RID_STB3, biu_stb_ar_resp_id == `CA53_RID_STB2, biu_stb_ar_resp_id == `CA53_RID_STB1, biu_stb_ar_resp_id == `CA53_RID_STB0};

  // Track outstanding requests

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_reqs <= {5{1'b0}};
  else
    outstanding_reqs <= (outstanding_reqs & ~resp_received) | req_sent;


  // Track outstanding write requests (includes DVM messages as they send data to the BIU)

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_write_reqs <= {5{1'b0}};
  else
    outstanding_write_reqs <= ((outstanding_write_reqs & ~resp_received) | (req_sent & {5{(stb_ar_type == `CA53_CPOP_8_WRITE) | stb_ar_type_dvm}}));


  // Track outstanding DVM Sync requests

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_dvm_sync <= 1'b0;
  else
    outstanding_dvm_sync <= (stb_ar_req & (stb_ar_type == `CA53_CPOP_8_SYNC) & biu_stb_ar_ack) | (outstanding_dvm_sync & ~scu_dvm_complete);


  // Track outstanding l2db IDs

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    l2db_outstanding <= {16{1'b0}};
  else
    l2db_outstanding <= ((l2db_outstanding & ~({16{stb_biu_write_req & biu_stb_write_accept & stb_biu_write_last}} & (1'b1 << stb_biu_write_l2dbid))) | ({16{|(resp_received & outstanding_write_reqs)}} & (1'b1 << biu_stb_ar_resp_l2dbid)));



  // The SCU must not return an L2DBID already in use.

  assert_implication #(`OVL_FATAL, INOPTIONS, "|(resp_received & outstanding_write_reqs)  => ~l2db_outstanding[biu_stb_ar_resp_l2dbid]")
  u_ovl_intf_assume_47c56a422b153a867635e3a23ce217645efc5a96 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|(resp_received & outstanding_write_reqs) ),
    .consequent_expr (~l2db_outstanding[biu_stb_ar_resp_l2dbid]));


  // The STB must not send a write with an L2DBID that was not allocated by the SCU.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_biu_write_req  => l2db_outstanding[stb_biu_write_l2dbid]")
  u_ovl_intf_assert_0d3d59fac2f798c8a7d98a75df7231c0494e1614 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_biu_write_req ),
    .consequent_expr (l2db_outstanding[stb_biu_write_l2dbid]));


  // Only valid read IDs are allowed.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req  => stb_ar_id in [`CA53_RID_STB4, `CA53_RID_STB3, `CA53_RID_STB2, `CA53_RID_STB1, `CA53_RID_STB0]")
  u_ovl_intf_assert_874eb11e1093de8d6a1be86f92315e7eb7e4f297 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req ),
    .consequent_expr (((stb_ar_id == `CA53_RID_STB4) | (stb_ar_id ==  `CA53_RID_STB3) | (stb_ar_id ==  `CA53_RID_STB2) | (stb_ar_id ==  `CA53_RID_STB1) | (stb_ar_id ==  `CA53_RID_STB0))));


  assign stb_ar_req_onehot  = {stb_ar_req & (stb_ar_id == `CA53_RID_STB4), stb_ar_req & (stb_ar_id == `CA53_RID_STB3), stb_ar_req & (stb_ar_id == `CA53_RID_STB2), stb_ar_req & (stb_ar_id == `CA53_RID_STB1), stb_ar_req & (stb_ar_id == `CA53_RID_STB0)};

  // Normal non-exclusive writes are always privileged.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req & (stb_ar_type == `CA53_CPOP_8_WRITE) & `CA53_MEM_NORMAL(stb_ar_attrs) & ~stb_ar_excl  => stb_ar_priv")
  u_ovl_intf_assert_b688f718742a32ea8131750fe7307e4479ce89e1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req & (stb_ar_type == `CA53_CPOP_8_WRITE) & `CA53_MEM_NORMAL(stb_ar_attrs) & ~stb_ar_excl ),
    .consequent_expr (stb_ar_priv));


  // Exclusives to coherent memory are never sent to the BIU.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req & (stb_ar_type == `CA53_CPOP_8_WRITE) & `CA53_MEM_COHERENT(stb_ar_attrs)  => ~stb_ar_excl")
  u_ovl_intf_assert_aab17fd15a8eac9b220f391d84704e44b65c7610 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req & (stb_ar_type == `CA53_CPOP_8_WRITE) & `CA53_MEM_COHERENT(stb_ar_attrs) ),
    .consequent_expr (~stb_ar_excl));


  // The STB cannot make a request from an empty slot.

  assert_always #(`OVL_FATAL, OUTOPTIONS, "~|(stb_ar_req_onehot & ~stb_slots_valid)")
  u_ovl_intf_assert_a6445c916ccec20d513e3224c5b9321242676fdd (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (~|(stb_ar_req_onehot & ~stb_slots_valid)));


  // The cacheline of a write request must match that of the slot making the request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req_onehot[4] & (stb_ar_type == `CA53_CPOP_8_WRITE)  => stb_ar_addr[39:6] == stb_slot4_addr[39:6]")
  u_ovl_intf_assert_f81a30143744808c95b865ace47bfa45cbb3e80c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req_onehot[4] & (stb_ar_type == `CA53_CPOP_8_WRITE) ),
    .consequent_expr (stb_ar_addr[39:6] == stb_slot4_addr[39:6]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req_onehot[3] & (stb_ar_type == `CA53_CPOP_8_WRITE)  => stb_ar_addr[39:6] == stb_slot3_addr[39:6]")
  u_ovl_intf_assert_ec8d87b7b4c967eb50db21aefd3254855bcc81e9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req_onehot[3] & (stb_ar_type == `CA53_CPOP_8_WRITE) ),
    .consequent_expr (stb_ar_addr[39:6] == stb_slot3_addr[39:6]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req_onehot[2] & (stb_ar_type == `CA53_CPOP_8_WRITE)  => stb_ar_addr[39:6] == stb_slot2_addr[39:6]")
  u_ovl_intf_assert_f95b0f79d51a51d9ca55dd5c7539f0b26fea9634 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req_onehot[2] & (stb_ar_type == `CA53_CPOP_8_WRITE) ),
    .consequent_expr (stb_ar_addr[39:6] == stb_slot2_addr[39:6]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req_onehot[1] & (stb_ar_type == `CA53_CPOP_8_WRITE)  => stb_ar_addr[39:6] == stb_slot1_addr[39:6]")
  u_ovl_intf_assert_a5f6b64bcb1d688e6727f50a120e6f80bd3efa81 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req_onehot[1] & (stb_ar_type == `CA53_CPOP_8_WRITE) ),
    .consequent_expr (stb_ar_addr[39:6] == stb_slot1_addr[39:6]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req_onehot[0] & (stb_ar_type == `CA53_CPOP_8_WRITE)  => stb_ar_addr[39:6] == stb_slot0_addr[39:6]")
  u_ovl_intf_assert_0a10393defc80830c9c57297fe5c89c066825d65 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req_onehot[0] & (stb_ar_type == `CA53_CPOP_8_WRITE) ),
    .consequent_expr (stb_ar_addr[39:6] == stb_slot0_addr[39:6]));


  // The ns descriptor of a write request must match that of the slot making the request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req_onehot[4] & (stb_ar_type == `CA53_CPOP_8_WRITE)  => stb_ar_ns_dsc == stb_slots_ns_dsc[4]")
  u_ovl_intf_assert_cf1afe319b80576b6004562d74e130dea5ac188f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req_onehot[4] & (stb_ar_type == `CA53_CPOP_8_WRITE) ),
    .consequent_expr (stb_ar_ns_dsc == stb_slots_ns_dsc[4]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req_onehot[3] & (stb_ar_type == `CA53_CPOP_8_WRITE)  => stb_ar_ns_dsc == stb_slots_ns_dsc[3]")
  u_ovl_intf_assert_cbca7ecaca00d3f43d0ea4255837337e236d18e2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req_onehot[3] & (stb_ar_type == `CA53_CPOP_8_WRITE) ),
    .consequent_expr (stb_ar_ns_dsc == stb_slots_ns_dsc[3]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req_onehot[2] & (stb_ar_type == `CA53_CPOP_8_WRITE)  => stb_ar_ns_dsc == stb_slots_ns_dsc[2]")
  u_ovl_intf_assert_6b6367768bf1c7cbe17ce0eeeda713c90addce1a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req_onehot[2] & (stb_ar_type == `CA53_CPOP_8_WRITE) ),
    .consequent_expr (stb_ar_ns_dsc == stb_slots_ns_dsc[2]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req_onehot[1] & (stb_ar_type == `CA53_CPOP_8_WRITE)  => stb_ar_ns_dsc == stb_slots_ns_dsc[1]")
  u_ovl_intf_assert_60ca497009c7c62d9ba6e8bc4a5b2fd77a3ebfeb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req_onehot[1] & (stb_ar_type == `CA53_CPOP_8_WRITE) ),
    .consequent_expr (stb_ar_ns_dsc == stb_slots_ns_dsc[1]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req_onehot[0] & (stb_ar_type == `CA53_CPOP_8_WRITE)  => stb_ar_ns_dsc == stb_slots_ns_dsc[0]")
  u_ovl_intf_assert_332379d79768ed7988ee517f21b4cd92aa2b6791 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req_onehot[0] & (stb_ar_type == `CA53_CPOP_8_WRITE) ),
    .consequent_expr (stb_ar_ns_dsc == stb_slots_ns_dsc[0]));


  // The STB must not send a new request for an ID that is still outstanding.

  assert_always #(`OVL_FATAL, OUTOPTIONS, "~|(req_sent & outstanding_reqs)")
  u_ovl_intf_assert_7aa5cb8def97b03f4572e6382bdad3722f0bc584 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (~|(req_sent & outstanding_reqs)));


  // The STB must not send a new DVM sync request when there is one outstanding.

  assert_always #(`OVL_FATAL, OUTOPTIONS, "~(stb_ar_req & (stb_ar_type == `CA53_CPOP_8_SYNC) & outstanding_dvm_sync)")
  u_ovl_intf_assert_47faaac34de394b06739addc2bf9f57feb0e501d (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (~(stb_ar_req & (stb_ar_type == `CA53_CPOP_8_SYNC) & outstanding_dvm_sync)));


  // The SCU must only respond to requests that have been made.

  assert_always #(`OVL_FATAL, INOPTIONS, "~|(resp_received & ~outstanding_reqs)")
  u_ovl_intf_assume_e78b4982f73f2ca4ff1352b069b9e0b941082ef5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (~|(resp_received & ~outstanding_reqs)));


  // The SCU must only respond to DVM sync requests that have been made.

  assert_always #(`OVL_FATAL, INOPTIONS, "~(scu_dvm_complete & ~outstanding_dvm_sync)")
  u_ovl_intf_assume_d7a0ad964e90e61d4277857d43ee9bde00182553 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (~(scu_dvm_complete & ~outstanding_dvm_sync)));


  //----------------------------------------------------------------------------
  //
  // Misc
  //
  //----------------------------------------------------------------------------

  // The BIU has a linefill in progress that has had some store data merged into
  // it from the STB. The STB should not send a barrier while this is set.
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


  // The BIU has a exclusive linefill in progress.
  // The STB should not send an exclusive CleanUnique while this is set.
  //  input biu_excl_lf_in_progress valid always timing 25%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_excl_lf_in_progress X or Z")
  u_ovl_intf_x_biu_excl_lf_in_progress (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_excl_lf_in_progress));


  // New exclusive CleanUnqiue request
  assign new_stb_ar_req_excl  = stb_ar_req & (stb_ar_type == `CA53_CPOP_8_CLEANUNIQUE) & stb_ar_excl & ~(stb_ar_req_reg & (stb_ar_type_reg == `CA53_CPOP_8_CLEANUNIQUE) & stb_ar_excl_reg);

  // The STB should not start an exclusive CleanUnique request while there is an exclusive linefill in progress.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "new_stb_ar_req_excl  => ~biu_excl_lf_in_progress")
  u_ovl_intf_assert_d084d3378146f79297abce449c72dd997ee9608d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (new_stb_ar_req_excl ),
    .consequent_expr (~biu_excl_lf_in_progress));


  // The STB inserts a DSB for non-coherent STLR to force the store to become
  // observable before store data can be forwarded to a load to the same address.
  assign implicit_dsb  = |(stb_ar_req_onehot & slots_store) & (stb_ar_type == `CA53_CPOP_8_DSBSY);

  // A dirty linefill happened before the barrier so the barrier should not
  // be sent to the BIU until the linefill has completed. This is not required
  // for an implicit DSB inserted for a STLR as the implicit DSB is only sent
  // for non-coherent STLR, and only inserted to prevent data forwarding until
  // the write response for the STLR has been received.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "stb_ar_req & stb_ar_type_bar & ~implicit_dsb  => ~biu_dirty_lf_in_progress")
  u_ovl_intf_assert_11ac652835bdaf70e418e7504263c005cbf2324d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (stb_ar_req & stb_ar_type_bar & ~implicit_dsb ),
    .consequent_expr (~biu_dirty_lf_in_progress));


  // A dirty linefill can only start due to a merge.

  assert_implication #(`OVL_FATAL, INOPTIONS, "biu_dirty_lf_in_progress & ~biu_dirty_lf_in_progress@1  => |stb_slot_cachewrite_m1@1")
  u_ovl_intf_assume_68ebb190d3acd9a660fef99c28e3af445a61fcbe (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_dirty_lf_in_progress & ~biu_dirty_lf_in_progress_reg ),
    .consequent_expr (|stb_slot_cachewrite_m1_reg));



endmodule

`define CA53_UNDEFINE
`include "ca53_dcu_stb_defs.v"
`include "ca53_biu_scu_defs.v"
`include "cortexa53params.v"
`include "cortexa53params.v"
`include "ca53_stb_biu_defs.v"
`undef CA53_UNDEFINE

`endif

