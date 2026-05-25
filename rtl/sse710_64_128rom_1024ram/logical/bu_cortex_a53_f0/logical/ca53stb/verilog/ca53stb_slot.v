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
// Abstract : STB (Store Buffer) slot state machine
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// The STB contains five identical slots that each hold up to 128 bits of
// data. These slots are controlled by this state machine.

`include "ca53stb_defs.v"
`include "ca53_stb_biu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "cortexa53params.v"

module ca53stb_slot `CA53_STB_PARAM_DECL
 (

  //----------------------------------------------------------------------------
  // Clock and Reset
  //----------------------------------------------------------------------------

  input wire          clk,
  input wire          slot_clk,
  input wire          reset_n,


  //----------------------------------------------------------------------------
  // The contents of this slot
  //----------------------------------------------------------------------------

  output wire         slot_valid_o,
  output wire         slot_emptying_o,
  output wire         slot_state_biureq_o,
  output wire         slot_state_biumerge_o,
  output wire         slot_state_biuack_o,
  output wire         slot_state_biuresp_o,
  output wire         slot_state_biudata_o,
  output wire         slot_state_lfreq_o,
  output wire         slot_state_lookupreq_o,
  output wire         slot_state_lookupm1_o,
  output wire         slot_state_lookupm2_o,
  output wire         slot_state_special_o,
  output wire         slot_state_tagwrite_o,
  output wire         slot_state_cachemerge_o,
  output wire         slot_state_cachewritereq_o,
  output wire         slot_state_cachereadm0_o,
  output wire         slot_state_cachereadm1_o,
  output wire         slot_state_cachereadm2_o,
  output wire         slot_state_cacheecc_o,
  output wire         slot_state_cachewritem1_o,
  output wire         slot_state_cp15resp_o,
  output wire         slot_state_cleanunique_req_o,
  output wire         slot_state_cleanunique_ack_o,
  output wire         slot_state_cleanunique_resp_o,
  output wire         slot_state_barrier_ack_o,
  output wire         slot_write_sync_cmo_ack_o,
  output wire [7:0]   slot_attrs_o,
  output wire [39:0]  slot_addr_o,
  output wire         slot_ns_o,
  output wire [127:0] slot_data_o,
  output wire [15:0]  slot_cache_bls_o,
  output wire [127:0] slot_write_data_o,
  output wire [15:0]  slot_write_bls_o,
  output wire [1:0]   slot_write_chunk_o,
  output wire         slot_write_last_o,
  output wire         slot_mergeable_o,
  output wire         slot_barriered_o,
  output wire [3:0]   slot_earlier_o,
  output wire [3:0]   slot_earlier_lf_o,
  output wire         slot_cp15_o,
  output wire         slot_dsb_o,
  output wire [3:0]   slot_way_onehot_o,
  output wire [1:0]   slot_way_o,
  output wire         slot_migratory_o,
  output wire [1:0]   slot_ar_way_o,
  output wire         slot_lf_hz_seen_o,
  output wire         slot_lf_hz_capture_o,
  output wire         slot_coherent_o,
  output wire [3:0]   slot_l2dbid_o,
  output wire         slot_no_alloc_on_miss_o,
  output wire         slot_more_dev_expected_o,
  output wire [2:0]   slot_sameline_beat_count_o,
  output wire         slot_has_cleanunique_duty_o,
  output wire         slot_load_sameline_seen_o,
  output wire         slot_load_sameline_o,


  //----------------------------------------------------------------------------
  // Other slots
  //----------------------------------------------------------------------------

  input wire          slota_valid_i,
  input wire          slota_emptying_i,
  input wire          slota_state_biureq_i,
  input wire          slota_state_biuack_i,
  input wire          slota_state_biuresp_i,
  input wire          slota_state_biudata_i,
  input wire          slota_state_lfreq_i,
  input wire          slota_state_lookupreq_i,
  input wire          slota_state_lookupm1_i,
  input wire          slota_state_lookupm2_i,
  input wire          slota_state_tagwrite_i,
  input wire          slota_state_cachemerge_i,
  input wire          slota_state_cachereadm0_i,
  input wire          slota_state_cachereadm1_i,
  input wire          slota_state_cachereadm2_i,
  input wire          slota_state_cacheecc_i,
  input wire          slota_state_cachewritereq_i,
  input wire          slota_state_cachewritem1_i,
  input wire          slota_state_cp15resp_i,
  input wire          slota_state_cleanunique_req_i,
  input wire          slota_state_cleanunique_ack_i,
  input wire          slota_state_cleanunique_resp_i,
  input wire          slota_mergeable_i,
  input wire          slota_barriered_i,
  input wire          slota_has_lookup_priority_i,
  input wire          slota_has_tagwrite_priority_i,
  input wire          slota_ar_resp_valid_i,
  input wire          slota_has_write_addr_priority_i,
  input wire          slota_has_cleanunique_priority_i,
  input wire [1:0]    slota_way_i,
  input wire          slota_migratory_i,
  input wire          slota_ev_hazard_i,
  input wire          slota_ev_hz_seen_i,
  input wire          slota_lf_hz_seen_i,
  input wire          slota_lf_hz_capture_i,
  input wire          slota_coherent_i,
  input wire          slota_biu_lf_hazard_i,
  input wire [3:0]    slota_l2dbid_i,
  input wire          slota_no_alloc_on_miss_i,
  input wire [2:0]    slota_sameline_beat_count_i,
  input wire          slota_wants_write_data_priority_i,
  input wire          slota_write_accept_i,
  input wire          slota_more_dev_expected_i,
  input wire          slota_lf_req_i,
  input wire          slota_has_cleanunique_duty_i,
  input wire          slota_load_sameline_seen_i,
  input wire          slota_load_sameline_i,

  input wire          slotb_valid_i,
  input wire          slotb_emptying_i,
  input wire          slotb_state_biureq_i,
  input wire          slotb_state_biuack_i,
  input wire          slotb_state_biuresp_i,
  input wire          slotb_state_biudata_i,
  input wire          slotb_state_lfreq_i,
  input wire          slotb_state_lookupreq_i,
  input wire          slotb_state_lookupm1_i,
  input wire          slotb_state_lookupm2_i,
  input wire          slotb_state_tagwrite_i,
  input wire          slotb_state_cachemerge_i,
  input wire          slotb_state_cachereadm0_i,
  input wire          slotb_state_cachereadm1_i,
  input wire          slotb_state_cachereadm2_i,
  input wire          slotb_state_cacheecc_i,
  input wire          slotb_state_cachewritereq_i,
  input wire          slotb_state_cachewritem1_i,
  input wire          slotb_state_cp15resp_i,
  input wire          slotb_state_cleanunique_req_i,
  input wire          slotb_state_cleanunique_ack_i,
  input wire          slotb_state_cleanunique_resp_i,
  input wire          slotb_mergeable_i,
  input wire          slotb_barriered_i,
  input wire          slotb_has_lookup_priority_i,
  input wire          slotb_has_tagwrite_priority_i,
  input wire          slotb_ar_resp_valid_i,
  input wire          slotb_has_write_addr_priority_i,
  input wire          slotb_has_cleanunique_priority_i,
  input wire [1:0]    slotb_way_i,
  input wire          slotb_migratory_i,
  input wire          slotb_ev_hazard_i,
  input wire          slotb_ev_hz_seen_i,
  input wire          slotb_lf_hz_seen_i,
  input wire          slotb_lf_hz_capture_i,
  input wire          slotb_coherent_i,
  input wire          slotb_biu_lf_hazard_i,
  input wire [3:0]    slotb_l2dbid_i,
  input wire          slotb_no_alloc_on_miss_i,
  input wire [2:0]    slotb_sameline_beat_count_i,
  input wire          slotb_wants_write_data_priority_i,
  input wire          slotb_write_accept_i,
  input wire          slotb_more_dev_expected_i,
  input wire          slotb_lf_req_i,
  input wire          slotb_has_cleanunique_duty_i,
  input wire          slotb_load_sameline_seen_i,
  input wire          slotb_load_sameline_i,

  input wire          slotc_valid_i,
  input wire          slotc_emptying_i,
  input wire          slotc_state_biureq_i,
  input wire          slotc_state_biuack_i,
  input wire          slotc_state_biuresp_i,
  input wire          slotc_state_biudata_i,
  input wire          slotc_state_lfreq_i,
  input wire          slotc_state_lookupreq_i,
  input wire          slotc_state_lookupm1_i,
  input wire          slotc_state_lookupm2_i,
  input wire          slotc_state_tagwrite_i,
  input wire          slotc_state_cachemerge_i,
  input wire          slotc_state_cachereadm0_i,
  input wire          slotc_state_cachereadm1_i,
  input wire          slotc_state_cachereadm2_i,
  input wire          slotc_state_cacheecc_i,
  input wire          slotc_state_cachewritereq_i,
  input wire          slotc_state_cachewritem1_i,
  input wire          slotc_state_cp15resp_i,
  input wire          slotc_state_cleanunique_req_i,
  input wire          slotc_state_cleanunique_ack_i,
  input wire          slotc_state_cleanunique_resp_i,
  input wire          slotc_mergeable_i,
  input wire          slotc_barriered_i,
  input wire          slotc_has_lookup_priority_i,
  input wire          slotc_has_tagwrite_priority_i,
  input wire          slotc_ar_resp_valid_i,
  input wire          slotc_has_write_addr_priority_i,
  input wire          slotc_has_cleanunique_priority_i,
  input wire [1:0]    slotc_way_i,
  input wire          slotc_migratory_i,
  input wire          slotc_ev_hazard_i,
  input wire          slotc_ev_hz_seen_i,
  input wire          slotc_lf_hz_seen_i,
  input wire          slotc_lf_hz_capture_i,
  input wire          slotc_coherent_i,
  input wire          slotc_biu_lf_hazard_i,
  input wire [3:0]    slotc_l2dbid_i,
  input wire          slotc_no_alloc_on_miss_i,
  input wire [2:0]    slotc_sameline_beat_count_i,
  input wire          slotc_wants_write_data_priority_i,
  input wire          slotc_write_accept_i,
  input wire          slotc_more_dev_expected_i,
  input wire          slotc_lf_req_i,
  input wire          slotc_has_cleanunique_duty_i,
  input wire          slotc_load_sameline_seen_i,
  input wire          slotc_load_sameline_i,

  input wire          slotd_valid_i,
  input wire          slotd_emptying_i,
  input wire          slotd_state_biureq_i,
  input wire          slotd_state_biuack_i,
  input wire          slotd_state_biuresp_i,
  input wire          slotd_state_biudata_i,
  input wire          slotd_state_lfreq_i,
  input wire          slotd_state_lookupreq_i,
  input wire          slotd_state_lookupm1_i,
  input wire          slotd_state_lookupm2_i,
  input wire          slotd_state_tagwrite_i,
  input wire          slotd_state_cachemerge_i,
  input wire          slotd_state_cachereadm0_i,
  input wire          slotd_state_cachereadm1_i,
  input wire          slotd_state_cachereadm2_i,
  input wire          slotd_state_cacheecc_i,
  input wire          slotd_state_cachewritereq_i,
  input wire          slotd_state_cachewritem1_i,
  input wire          slotd_state_cp15resp_i,
  input wire          slotd_state_cleanunique_req_i,
  input wire          slotd_state_cleanunique_ack_i,
  input wire          slotd_state_cleanunique_resp_i,
  input wire          slotd_mergeable_i,
  input wire          slotd_barriered_i,
  input wire          slotd_has_lookup_priority_i,
  input wire          slotd_has_tagwrite_priority_i,
  input wire          slotd_ar_resp_valid_i,
  input wire          slotd_has_write_addr_priority_i,
  input wire          slotd_has_cleanunique_priority_i,
  input wire [1:0]    slotd_way_i,
  input wire          slotd_migratory_i,
  input wire          slotd_ev_hazard_i,
  input wire          slotd_ev_hz_seen_i,
  input wire          slotd_lf_hz_seen_i,
  input wire          slotd_lf_hz_capture_i,
  input wire          slotd_coherent_i,
  input wire          slotd_biu_lf_hazard_i,
  input wire [3:0]    slotd_l2dbid_i,
  input wire          slotd_no_alloc_on_miss_i,
  input wire [2:0]    slotd_sameline_beat_count_i,
  input wire          slotd_wants_write_data_priority_i,
  input wire          slotd_write_accept_i,
  input wire          slotd_more_dev_expected_i,
  input wire          slotd_lf_req_i,
  input wire          slotd_has_cleanunique_duty_i,
  input wire          slotd_load_sameline_seen_i,
  input wire          slotd_load_sameline_i,


  //----------------------------------------------------------------------------
  // DC2 interface to the DCU
  //----------------------------------------------------------------------------

  input wire [39:3]   dcu_pa_dc2_i,
  input wire          dcu_ns_dsc_dc2_i,
  input wire [7:0]    dcu_attrs_dc2_i,

  output wire         slot_can_merge_dc2_o,
  output wire         slot_sameline_dc2_o,
  output wire         slot_load_sameline_dc2_o,
  output wire         slot_attr_mismatch_dc2_o,
  output wire [15:0]  slot_hit_dc2_o,


  //----------------------------------------------------------------------------
  // New requests from the DCU
  //----------------------------------------------------------------------------

  input wire          slot_new_req_dc3_i,
  input wire          slot_store_merge_dc3_i,
  input wire [39:0]   dcu_pa_dc3_i,
  input wire          dcu_ns_dsc_dc3_i,
  input wire          dcu_priv_dc3_i,
  input wire          dcu_stb_exclusive_dc3_i,
  input wire          dcu_stb_mergeable_dc3_i,
  input wire          dcu_store_cp15_dc3_i,
  input wire          dcu_stlr_dc3_i,
  input wire [7:0]    dcu_stb_attrs_dc3_i,
  input wire [127:0]  dpu_st_data_wr_i,
  input wire [15:0]   dcu_store_bls_dc3_i,
  input wire          dcu_store_last_dc3_i,
  input wire          dcu_store_dsb_dc3_i,
  input wire          dcu_store_dmb_dc3_i,
  input wire          dcu_force_non_mergeable_dc3_i,
  input wire          slota_new_req_dc3_i,
  input wire          slotb_new_req_dc3_i,
  input wire          slotc_new_req_dc3_i,
  input wire          slotd_new_req_dc3_i,
  input wire          slot_dcu_store_sameline_dc3_i,
  input wire          slota_dcu_store_sameline_dc3_i,
  input wire          slotb_dcu_store_sameline_dc3_i,
  input wire          slotc_dcu_store_sameline_dc3_i,
  input wire          slotd_dcu_store_sameline_dc3_i,


  //----------------------------------------------------------------------------
  // DCU cache arbiter
  //----------------------------------------------------------------------------

  input wire          dcu_stb_tag_has_priority_m0_i,
  input wire          dcu_stb_data_has_priority_m0_i,

  input wire          dcu_stb_tag_ack_m1_i,
  input wire          dcu_stb_data_ack_m1_i,

  input wire [3:0]    dcu_stb_tag_hit_m2_i,
  input wire          dcu_stb_tag_shared_m2_i,
  input wire          dcu_stb_tag_migratory_m2_i,
  input wire [3:0]    dcu_stb_victim_way_m2_i,
  input wire [127:0]  dcu_stb_read_data_m2_i,
  input wire [3:0]    dcu_stb_read_wls_m2_i,

  input wire          dcu_ecc_data_err_m3_i,
  input wire          dcu_ecc_in_progress_i,
  input wire [1:0]    tag_hit_shared_m3_i,
  input wire          tag_ecc_err_m3_i,


  //----------------------------------------------------------------------------
  // BIU interface
  //----------------------------------------------------------------------------

  input  wire         biu_stb_write_accept_i,

  output wire         slot_wants_write_data_priority_o,
  output wire         slot_has_write_data_priority_o,
  output wire         slot_write_data_suppress_o,
  output wire         slot_write_accept_o,

  output wire         slot_lf_active_o,
  output wire         slot_lf_req_o,
  output wire         slot_lf_merge_o,
  input  wire         slot_biu_lf_hazard_i,
  input  wire         slot_biu_lf_real_hazard_i,
  input  wire         slot_biu_lf_hazard_migratory_i,
  input  wire [1:0]   slot_biu_lf_hazard_way_i,
  input  wire         slot_biu_lf_serialized_i,
  input  wire         slot_biu_lf_can_merge_i,
  input  wire         biu_dirty_lf_in_progress_i,
  input  wire         biu_excl_lf_in_progress_i,

  input  wire         biu_stb_ar_ack_i,
  input  wire [1:0]   biu_stb_ar_resp_i,

  input  wire         slot_biu_ev_hazard_i,
  output wire         slot_ev_hazard_o,
  output wire         slot_ev_hz_seen_o,
  output wire         slot_wants_ar_priority_o,
  output wire         slot_might_want_ar_priority_o,
  input  wire         slot_has_ar_priority_i,
  output wire         slot_already_has_ar_priority_o,
  output wire         slot_ar_suppress_o,
  output wire [39:0]  slot_ar_addr_o,
  output wire         slot_ar_ns_o,
  output wire         slot_ar_priv_o,
  output wire         slot_ar_excl_o,

  output wire [15:0]  slot_cp15_asid_o,
  output wire [7:0]   slot_cp15_vmid_o,
  output wire [24:0]  slot_cp15_va_o,


  //----------------------------------------------------------------------------
  // RAM interface
  //----------------------------------------------------------------------------

  input  wire [2:0]   dc_size_i,


  //----------------------------------------------------------------------------
  // Misc
  //----------------------------------------------------------------------------

  input  wire         slot_force_drain_i,
  input  wire         slot_force_drain_biudata_i,
  input  wire         stb_cycle_count_127_i,
  input  wire         stb_cycle_count_1023_i,
  input  wire         biu_read_alloc_mode_i,
  input  wire         next_dev_bursting_i,
  input  wire         dev_delay_ar_req_i,

  input  wire         dcu_leaving_dc2_i,
  input  wire         dcu_store_dc2_i,
  input  wire         slot_load_sameline_dc3_i,

  input  wire         dpu_kill_wr_i,

  output wire         slot_wants_lookup_priority_o,
  input  wire         slot_has_lookup_priority_i,

  output wire         slot_might_want_cache_data_priority_o,
  output wire         slot_wants_cache_data_priority_o,
  input  wire         slot_has_cache_data_priority_i,

  output wire         slot_wants_tagwrite_priority_o,
  input  wire         slot_has_tagwrite_priority_i,

  output wire         slot_wants_write_addr_priority_o,
  input  wire         slot_has_write_addr_priority_i,

  output wire         slot_wants_cleanunique_priority_o,
  input  wire         slot_has_cleanunique_priority_i,

  input  wire         slot_ar_resp_valid_i,
  input  wire [3:0]   biu_stb_ar_resp_l2dbid_i,
  output wire         slot_biu_write_req_active_o,

  input  wire [13:6]  dcu_ccb_index_i,
  input  wire [3:0]   dcu_ccb_ways_i,
  input  wire         dcu_ccb_req_valid_i,
  output wire         slot_block_ccb_o,

  input  wire         dcu_exclusive_monitor_i,
  input  wire         dvm_sync_needed_i,
  input  wire         propagate_barrier_i,
  input  wire         dpu_disable_dmb_i,

  input  wire         dvm_complete_i,

  output wire         slot_block_loads_dc1_o,

  output wire         slot_excl_fail_o,
  output wire         slot_excl_done_o,

  output wire [7:0]   slot_type_o,

  output wire         slot_might_req_o,
  output wire         slot_force_non_mergeable_o,
  input  wire         stb_force_non_mergeable_i
  );


  //----------------------------------------------------------------------------
  // Flops
  //----------------------------------------------------------------------------

  reg [`CA53_SLOT_WIDTH-1:0]  slot_state;  // The current state of the slot

  reg [7:0]   slot_attrs;                  // The memory type and attributes
  reg         slot_last;                   // The last beat of a device burst
  reg         slot_stlr;                   // The store is a store release
  reg         slot_exclusive;              // The store is a store exclusive
  reg         slot_cp15;                   // The store is a CP15 operation
  reg         slot_priv;                   // User or privileged mode, only valid for device
                                           // and strongly ordered
  reg [39:0]  slot_addr;                   // The physical address of the slot
  reg         slot_ns;                     // The non-secure bit from the page table descriptor
  reg [127:0] slot_data;                   // The data payload
  reg [15:0]  slot_bls;                    // The byte lane strobes for the data
  reg [3:0]   slot_32bit_chunks;           // The 32-bit data chunks that contain valid read
                                           // or write data
  reg         slot_barriered;              // This slot has been followed by a barrier
  reg [1:0]   slot_way;                    // The cache way that hit, compressed into 3 bits
  reg         slot_way_valid_lfreq;        // The way information has been updated to match
                                           // an ongoing linefill (only valid in LFREQ).
  reg         slot_migratory;              // Whether the slot hit a migratory line
  reg         slot_ev_hz_seen;             // An eviction hazard has been seen by this
                                           // slot since the last lookup
                                           // by this slot since activation.
  reg         slot_lf_req_suppress;        // A linefill request should be suppressed.
  reg         slot_lf_hz_seen;             // A linefill hazard has been seen by this slot
  reg         slot_lf_can_merge;           // The slot can merge into a linefill.
  reg         slot_post_lf_merge;          // The slot will merge after a linefill completes.
  reg [3:0]   slot_sameline;               // Which other slots are in the same
                                           // cache line as this one
  reg [3:0]   slot_same_dev_write;         // Which other slots are in the same
                                           // device write as this one
  reg         slot_more_dev_expected;      // More beats are expected for the device
                                           // write that this slot is a part of.
  reg [3:0]   slot_earlier;                // Slots that are earlier than this one
  reg [3:0]   slot_real_earlier;           // Which slots must drain before this one can
  reg         slot_merge_count_1023_seen;  // The slot has seen the cycle count reach
                                           // 1023 at least once since waiting for a merge.
  reg [1:0]   slot_drain_count_1023_seen;  // The slot has seen the cycle count reach
                                           // 1023 at least once since activation.
  reg         slot_ccb_hz_seen;            // The slot has seen a CCB hazard.
  reg [3:0]   slot_l2dbid;                 // The SCU data buffer allocated to a write.
  reg         slot_no_alloc_on_miss;       // The slot should not start a linefill
                                           // on a cache miss.
  reg [2:0]   slot_sameline_beat_count;    // The number of slots that have been sent for the
                                           // same Normal or GRE burst.
  reg         slot_has_cleanunique_duty;   // The slot has sole responsibility for performing
                                           // a CleanUnique (only used when CPU cache
                                           // protection is present).
  reg         slot_load_sameline_seen;     // A load to the sameline as the slot
                                           // was in dc2/dc3 last cycle.
  reg         slot_wait_for_beat;          // Delay sending data to the BIU until
                                           // another slot is activated for the same
                                           // line of device burst.


  //----------------------------------------------------------------------------
  // Wires
  //----------------------------------------------------------------------------

  wire [`CA53_SLOT_WIDTH-1:0] modified_slot_state;
  reg [`CA53_SLOT_WIDTH-1:0]  next_slot_state;
  wire [39:0]  next_slot_addr;
  wire [127:0] next_slot_data;
  wire [15:0]  slot_data_en;
  wire [15:0]  slot_data_en_cache_read;
  wire [15:0]  slot_data_en_store;
  wire [15:0]  slot_data_en_cp15;
  wire [15:0]  slot_cache_bls;
  wire [15:0]  next_slot_bls;
  wire         next_slot_barriered;
  wire         slot_mergeable;
  wire [3:0]   next_slot_earlier;
  wire [3:0]   slots_valid;
  wire [3:0]   slots_mergeable;
  wire [3:0]   slots_barriered;
  wire [3:0]   new_slot_earlier;
  wire [3:0]   new_slot_real_earlier;
  wire         wait_for_earlier_slot;
  wire         wait_for_second_dev_beat;
  wire         next_slot_last;
  wire [3:0]   slots_have_lookup_priority;
  wire [3:0]   slots_have_tagwrite_priority;
  wire [3:0]   slots_ar_resp_valid;
  wire [3:0]   slots_have_write_addr_priority;
  wire [3:0]   slots_have_cleanunique_priority;
  wire [3:0]   slots_have_cleanunique_duty;
  wire [3:0]   slots_load_sameline_seen;
  wire [3:0]   slots_load_sameline;
  wire [3:0]   slots_ev_hazard;
  wire [3:0]   slots_ev_hz_seen;
  wire [3:0]   slots_lf_req;
  wire [3:0]   slots_lf_hz_seen;
  wire [3:0]   slots_lf_hz_capture;
  wire         slot_valid;
  wire         slot_emptying;
  wire         slot_coherent;
  wire         new_req_from_idle;
  wire         real_new_req_from_idle;
  wire [3:0]   next_slot_sameline;
  wire [3:0]   next_slot_same_dev_write;
  wire         next_slot_more_dev_expected;
  wire [3:0]   next_slot_real_earlier;
  wire [3:0]   slots_dcu_store_sameline_dc3;
  wire         line_match_dc2;
  wire         qword_match_dc2;
  wire         attr_match_dc2;
  wire         slot_load_sameline_dc2;
  wire [3:0]   new_other_slots_sameline;
  wire [3:0]   new_other_slots_same_dev_write;
  wire         slot_state_en;
  wire [3:0]   slots_new_req_dc3;
  wire [3:0]   slots_state_biureq;
  wire [3:0]   slots_state_biuack;
  wire [3:0]   slots_state_biuresp;
  wire [3:0]   slots_state_biudata;
  wire [3:0]   slots_state_lfreq;
  wire [3:0]   slots_state_lookupreq;
  wire [3:0]   slots_state_lookupm1;
  wire [3:0]   slots_state_lookupm2;
  wire [3:0]   slots_state_tagwrite;
  wire [3:0]   slots_state_cachemerge;
  wire [3:0]   slots_state_cachereadm0;
  wire [3:0]   slots_state_cachereadm1;
  wire [3:0]   slots_state_cachereadm2;
  wire [3:0]   slots_state_cacheecc;
  wire [3:0]   slots_state_cachewritereq;
  wire [3:0]   slots_state_cachewritem1;
  wire [3:0]   slots_state_cp15resp;
  wire [3:0]   slots_state_cleanunique_req;
  wire [3:0]   slots_state_cleanunique_ack;
  wire [3:0]   slots_state_cleanunique_resp;
  wire         skip_to_biureq;
  wire         skip_to_biuack;
  wire         skip_to_biuresp;
  wire         skip_to_biudata;
  wire         skip_to_lfreq;
  wire         skip_to_lookupm1;
  wire         skip_to_lookupm2;
  wire         skip_to_special;
  wire         skip_to_tagwrite;
  wire         skip_to_cachemerge;
  wire         sync_slots;
  wire         start_lookup;
  wire [1:0]   next_slot_way;
  wire [3:0]   slot_way_onehot;
  wire         next_slot_migratory;
  wire         next_slot_ev_hz_seen;
  wire         next_slot_lf_hz_seen;
  wire         slot_lf_hz_capture;
  wire         slot_full;
  wire         next_slot_full;
  wire         slot_excl_done;
  wire         slot_excl_fail;
  wire         slot_wants_cp15_priority;
  wire         slot_wants_cleanunique_priority;
  wire         slot_real_new_req_dc3;
  wire         slot_state_biureq;
  wire         slot_state_biuack;
  wire         slot_state_biuresp;
  wire         slot_state_biudata;
  wire         slot_state_cachewritem1;
  wire         slot_state_biumerge;
  wire         slot_state_lookupreq;
  wire         slot_state_lookupm1;
  wire         slot_state_lookupm2;
  wire         slot_state_special;
  wire         slot_state_lfreq;
  wire         slot_state_cleanunique_req;
  wire         slot_state_cleanunique_ack;
  wire         slot_state_cleanunique_resp;
  wire         slot_state_tagwrite;
  wire         slot_state_cachemerge;
  wire         slot_state_cachereadm0;
  wire         slot_state_cachereadm1;
  wire         slot_state_cachereadm2;
  wire         slot_state_cacheecc;
  wire         slot_state_cacheecc_wait;
  wire         slot_state_cachewritereq;
  wire         slot_state_cp15req;
  wire         slot_state_cp15ack;
  wire         slot_state_cp15resp;
  wire         slot_state_dvmdata;
  wire         slot_state_syncreq;
  wire         slot_state_syncack;
  wire         slot_state_syncresp1;
  wire         slot_state_syncresp2;
  wire         slot_state_barrier_req;
  wire         slot_state_barrier_ack;
  wire         slot_state_barrier_resp;
  wire         slot_migratory_en;
  wire         slot_way_en;
  wire         slot_bls_en;
  wire         ar_resp_valid;
  wire         tagwrite_accepted;
  wire [7:0]   dc_index_mask;
  wire         ccb_index_match;
  wire         ccb_way_match;
  wire         ccb_ev_hazard;
  wire         slot_ev_hazard_lf;
  wire         slot_ev_hazard_ccb;
  wire         slot_ev_hazard_cu;
  wire         slot_ev_hazard_ecc;
  wire         slot_ev_hazard_clr;
  wire [3:0]   slots_sameline_hit;
  wire [3:0]   slots_hit;
  wire         slot_ev_hazard;
  wire [1:0]   tag_way_m2;
  wire [3:0]   slots_biu_lf_hazard;
  wire [3:0]   early_slot_sameline;
  wire [3:0]   early_slot_same_dev_write;
  wire [3:0]   early_slot_same_burst;
  wire [3:0]   slots_emptying;
  wire         next_slot_merge_count_1023_seen;
  wire         slot_merge_timeout;
  wire         next_slot_ccb_hz_seen;
  wire         slot_wants_barrier_priority;
  wire         slot_write_committed;
  wire [3:0]   next_slot_l2dbid;
  wire         skip_to_cleanunique_req;
  wire         skip_to_cleanunique_ack;
  wire         skip_to_cleanunique_resp;
  wire         ar_resp_fail;
  wire         ar_resp_excl_fail;
  wire         slot_wants_write_addr_priority;
  wire         slot_wants_write_data_priority;
  wire         slot_might_want_ar_priority;
  wire         slot_wants_ar_priority;
  wire         slot_has_write_data_priority;
  wire         slot_write_data_suppress;
  wire         slot_already_has_ar_priority;
  wire [3:0]   slots_want_write_data_priority;
  wire [3:0]   slots_write_accept;
  wire [3:0]   slots_more_dev_expected;
  wire         slot_write_accept;
  wire         slot_biu_write_stalled;
  wire         slot_cache_write_stalled;
  wire         slot_wants_cache_write_priority;
  wire         slot_wants_cache_read_priority;
  wire [3:0]   next_slot_32bit_chunks;
  wire [3:0]   slot_partial_chunks;
  wire         next_slot_no_alloc_on_miss;
  wire         slot_sameline_write_accept;
  wire         early_sameline_write_accept;
  wire [2:0]   next_slot_sameline_beat_count;
  wire         slot_sameline_beat_count_incr;
  wire [2:0]   slot_sameline_beat_count_plus_one;
  wire         early_sameline_beat_count_incr;
  wire [2:0]   early_sameline_beat_count;
  wire [2:0]   early_sameline_beat_count_plus_one;
  wire [7:0]   cp15_type;
  wire [4:0]   cp15_type_tlb_op;
  wire [4:0]   cp15_type_tlb_non_is;
  wire         cp15_aarch64;
  wire         cp15_is_tlb_maint;
  wire         cp15_is_bp_maint;
  wire         cp15_is_dc_maint;
  wire         cp15_is_dc_maint_sw;
  wire         cp15_is_dsb;
  wire         cp15_is_dmb_affecting_loads;
  wire         match_ipa;
  wire [31:0]  cp15_va_aarch32;
  wire [48:0]  cp15_va_aarch64;
  wire [47:0]  cp15_ipa;
  wire [48:0]  cp15_ipa_va;
  wire [7:0]   cp15_asid_aarch32;
  wire [15:0]  cp15_asid_aarch64;
  wire [39:0]  dc_maint_sw_addr;
  wire         addr_sel_sw;
  wire         addr_sel_ipa_va;
  wire         addr_sel_pa;
  wire         slot_has_cleanunique_duty_set;
  wire         slot_has_cleanunique_duty_clr;
  wire         next_slot_has_cleanunique_duty;
  wire         next_slot_load_sameline_seen;
  wire         slot_load_sameline;
  wire         part_cache_read_required;
  wire         full_cache_read_required;
  wire         next_slot_wait_for_beat;
  wire         slot_lf_merge;
  wire         next_slot_lf_req_suppress;
  wire         next_slot_lf_can_merge;
  wire         next_slot_post_lf_merge;
  wire         next_slot_way_valid_lfreq;
  wire         barrier_can_propagate;
  wire         start_speculatively_waiting;
  wire         stop_speculatively_waiting;
  wire         slot_drain_count_1023_seen_clr;
  wire         slot_drain_count_1023_seen_incr;
  wire [1:0]   slot_drain_count_1023_seen_plus_one;
  wire [1:0]   next_slot_drain_count_1023_seen;


  //----------------------------------------------------------------------------
  // Other slots
  //----------------------------------------------------------------------------

  // Combine various signals to simplify expressions that use them.

  assign slots_have_lookup_priority = {slotd_has_lookup_priority_i,
                                       slotc_has_lookup_priority_i,
                                       slotb_has_lookup_priority_i,
                                       slota_has_lookup_priority_i};

  assign slots_have_tagwrite_priority = {slotd_has_tagwrite_priority_i,
                                         slotc_has_tagwrite_priority_i,
                                         slotb_has_tagwrite_priority_i,
                                         slota_has_tagwrite_priority_i};

  assign slots_ar_resp_valid = {slotd_ar_resp_valid_i,
                                slotc_ar_resp_valid_i,
                                slotb_ar_resp_valid_i,
                                slota_ar_resp_valid_i};

  assign slots_have_write_addr_priority = {slotd_has_write_addr_priority_i,
                                           slotc_has_write_addr_priority_i,
                                           slotb_has_write_addr_priority_i,
                                           slota_has_write_addr_priority_i};

  assign slots_have_cleanunique_priority = {slotd_has_cleanunique_priority_i,
                                            slotc_has_cleanunique_priority_i,
                                            slotb_has_cleanunique_priority_i,
                                            slota_has_cleanunique_priority_i};

  assign slots_have_cleanunique_duty = {slotd_has_cleanunique_duty_i,
                                        slotc_has_cleanunique_duty_i,
                                        slotb_has_cleanunique_duty_i,
                                        slota_has_cleanunique_duty_i};

  assign slots_load_sameline_seen = {slotd_load_sameline_seen_i,
                                     slotc_load_sameline_seen_i,
                                     slotb_load_sameline_seen_i,
                                     slota_load_sameline_seen_i};

  assign slots_load_sameline = {slotd_load_sameline_i,
                                slotc_load_sameline_i,
                                slotb_load_sameline_i,
                                slota_load_sameline_i};

  assign slots_ev_hazard = {slotd_ev_hazard_i,
                            slotc_ev_hazard_i,
                            slotb_ev_hazard_i,
                            slota_ev_hazard_i};

  assign slots_ev_hz_seen = {slotd_ev_hz_seen_i,
                             slotc_ev_hz_seen_i,
                             slotb_ev_hz_seen_i,
                             slota_ev_hz_seen_i};

  assign slots_lf_req = {slotd_lf_req_i,
                         slotc_lf_req_i,
                         slotb_lf_req_i,
                         slota_lf_req_i};

  assign slots_lf_hz_seen = {slotd_lf_hz_seen_i,
                             slotc_lf_hz_seen_i,
                             slotb_lf_hz_seen_i,
                             slota_lf_hz_seen_i};

  assign slots_lf_hz_capture = {slotd_lf_hz_capture_i,
                                slotc_lf_hz_capture_i,
                                slotb_lf_hz_capture_i,
                                slota_lf_hz_capture_i};

  assign slots_valid = {slotd_valid_i,
                        slotc_valid_i,
                        slotb_valid_i,
                        slota_valid_i};

  assign slots_emptying = {slotd_emptying_i,
                           slotc_emptying_i,
                           slotb_emptying_i,
                           slota_emptying_i};

  assign slots_mergeable = {slotd_mergeable_i,
                            slotc_mergeable_i,
                            slotb_mergeable_i,
                            slota_mergeable_i};

  assign slots_barriered = {slotd_barriered_i,
                            slotc_barriered_i,
                            slotb_barriered_i,
                            slota_barriered_i};

  assign slots_state_biureq = {slotd_state_biureq_i,
                               slotc_state_biureq_i,
                               slotb_state_biureq_i,
                               slota_state_biureq_i};

  assign slots_state_biuack = {slotd_state_biuack_i,
                               slotc_state_biuack_i,
                               slotb_state_biuack_i,
                               slota_state_biuack_i};

  assign slots_state_biuresp = {slotd_state_biuresp_i,
                                slotc_state_biuresp_i,
                                slotb_state_biuresp_i,
                                slota_state_biuresp_i};

  assign slots_state_biudata = {slotd_state_biudata_i,
                                slotc_state_biudata_i,
                                slotb_state_biudata_i,
                                slota_state_biudata_i};

  assign slots_state_lfreq = {slotd_state_lfreq_i,
                              slotc_state_lfreq_i,
                              slotb_state_lfreq_i,
                              slota_state_lfreq_i};

  assign slots_state_lookupreq = {slotd_state_lookupreq_i,
                                  slotc_state_lookupreq_i,
                                  slotb_state_lookupreq_i,
                                  slota_state_lookupreq_i};

  assign slots_state_lookupm1 = {slotd_state_lookupm1_i,
                                 slotc_state_lookupm1_i,
                                 slotb_state_lookupm1_i,
                                 slota_state_lookupm1_i};

  assign slots_state_lookupm2 = {slotd_state_lookupm2_i,
                                 slotc_state_lookupm2_i,
                                 slotb_state_lookupm2_i,
                                 slota_state_lookupm2_i};

  assign slots_state_tagwrite = {slotd_state_tagwrite_i,
                                 slotc_state_tagwrite_i,
                                 slotb_state_tagwrite_i,
                                 slota_state_tagwrite_i};

  assign slots_state_cachemerge = {slotd_state_cachemerge_i,
                                   slotc_state_cachemerge_i,
                                   slotb_state_cachemerge_i,
                                   slota_state_cachemerge_i};

  assign slots_state_cachereadm0 = {slotd_state_cachereadm0_i,
                                    slotc_state_cachereadm0_i,
                                    slotb_state_cachereadm0_i,
                                    slota_state_cachereadm0_i};

  assign slots_state_cachereadm1 = {slotd_state_cachereadm1_i,
                                    slotc_state_cachereadm1_i,
                                    slotb_state_cachereadm1_i,
                                    slota_state_cachereadm1_i};

  assign slots_state_cachereadm2 = {slotd_state_cachereadm2_i,
                                    slotc_state_cachereadm2_i,
                                    slotb_state_cachereadm2_i,
                                    slota_state_cachereadm2_i};

  assign slots_state_cacheecc = {slotd_state_cacheecc_i,
                                 slotc_state_cacheecc_i,
                                 slotb_state_cacheecc_i,
                                 slota_state_cacheecc_i};

  assign slots_state_cachewritereq = {slotd_state_cachewritereq_i,
                                      slotc_state_cachewritereq_i,
                                      slotb_state_cachewritereq_i,
                                      slota_state_cachewritereq_i};

  assign slots_state_cachewritem1 = {slotd_state_cachewritem1_i,
                                     slotc_state_cachewritem1_i,
                                     slotb_state_cachewritem1_i,
                                     slota_state_cachewritem1_i};

  assign slots_state_cp15resp = {slotd_state_cp15resp_i,
                                 slotc_state_cp15resp_i,
                                 slotb_state_cp15resp_i,
                                 slota_state_cp15resp_i};

  assign slots_state_cleanunique_req = {slotd_state_cleanunique_req_i,
                                        slotc_state_cleanunique_req_i,
                                        slotb_state_cleanunique_req_i,
                                        slota_state_cleanunique_req_i};

  assign slots_state_cleanunique_ack = {slotd_state_cleanunique_ack_i,
                                        slotc_state_cleanunique_ack_i,
                                        slotb_state_cleanunique_ack_i,
                                        slota_state_cleanunique_ack_i};

  assign slots_state_cleanunique_resp = {slotd_state_cleanunique_resp_i,
                                         slotc_state_cleanunique_resp_i,
                                         slotb_state_cleanunique_resp_i,
                                         slota_state_cleanunique_resp_i};

  assign slots_biu_lf_hazard = {slotd_biu_lf_hazard_i,
                                slotc_biu_lf_hazard_i,
                                slotb_biu_lf_hazard_i,
                                slota_biu_lf_hazard_i};

  assign slots_dcu_store_sameline_dc3 = {slotd_dcu_store_sameline_dc3_i,
                                         slotc_dcu_store_sameline_dc3_i,
                                         slotb_dcu_store_sameline_dc3_i,
                                         slota_dcu_store_sameline_dc3_i};

  assign slots_new_req_dc3 = {slotd_new_req_dc3_i & ~dpu_kill_wr_i,
                              slotc_new_req_dc3_i & ~dpu_kill_wr_i,
                              slotb_new_req_dc3_i & ~dpu_kill_wr_i,
                              slota_new_req_dc3_i & ~dpu_kill_wr_i};

  assign slots_want_write_data_priority = {slotd_wants_write_data_priority_i,
                                           slotc_wants_write_data_priority_i,
                                           slotb_wants_write_data_priority_i,
                                           slota_wants_write_data_priority_i};

  assign slots_write_accept = {slotd_write_accept_i,
                               slotc_write_accept_i,
                               slotb_write_accept_i,
                               slota_write_accept_i};

  assign slots_more_dev_expected = {slotd_more_dev_expected_i,
                                    slotc_more_dev_expected_i,
                                    slotb_more_dev_expected_i,
                                    slota_more_dev_expected_i};


  //----------------------------------------------------------------------------
  // State machine logic
  //----------------------------------------------------------------------------

  always @*
  begin
    next_slot_state = modified_slot_state;
    case (modified_slot_state)
      // ----------------------------------------------------------------------
      // Idle
      // ----------------------------------------------------------------------
      `CA53_SLOT_IDLE: begin
        if (slot_new_req_dc3_i) begin
          if (dcu_store_cp15_dc3_i) begin
            if (dcu_store_dmb_dc3_i | dcu_store_dsb_dc3_i) begin
              if (dvm_sync_needed_i & dcu_store_dsb_dc3_i) begin
                next_slot_state = `CA53_SLOT_SYNCREQ;
              end else begin
                next_slot_state = `CA53_SLOT_BARRIER_REQ;
              end
            end else begin
              next_slot_state = `CA53_SLOT_CP15REQ;
            end
          end else begin
            if (`CA53_MEM_COHERENT(dcu_stb_attrs_dc3_i)) begin
              // Skip some or all of the lookup states if possible. Note that
              // these skip signals are not one hot, as there may be more than
              // one other slot in the same line, each in a different state.
              // Therefore pick the state that has done the largest amount of the
              // lookup already.
              if (skip_to_lfreq) begin
                next_slot_state = `CA53_SLOT_LFREQ;
              end else if (skip_to_cachemerge) begin
                next_slot_state = `CA53_SLOT_CACHEMERGE;
              end else if (skip_to_tagwrite) begin
                next_slot_state = `CA53_SLOT_TAGWRITE;
              end else if (skip_to_cleanunique_resp) begin
                next_slot_state = `CA53_SLOT_CLEANUNIQUE_RESP;
              end else if (skip_to_cleanunique_ack) begin
                next_slot_state = `CA53_SLOT_CLEANUNIQUE_ACK;
              end else if (skip_to_cleanunique_req) begin
                next_slot_state = `CA53_SLOT_CLEANUNIQUE_REQ;
              end else if (skip_to_biudata) begin
                next_slot_state = `CA53_SLOT_BIUDATA;
              end else if (skip_to_biuresp) begin
                next_slot_state = `CA53_SLOT_BIURESP;
              end else if (skip_to_biuack) begin
                next_slot_state = `CA53_SLOT_BIUACK;
              end else if (skip_to_biureq) begin
                next_slot_state = `CA53_SLOT_BIUREQ;
              end else if (skip_to_special) begin
                next_slot_state = `CA53_SLOT_SPECIAL;
              end else if (skip_to_lookupm2) begin
                next_slot_state = `CA53_SLOT_LOOKUPM2;
              end else if (skip_to_lookupm1) begin
                next_slot_state = `CA53_SLOT_LOOKUPM1;
              end else begin
                next_slot_state = `CA53_SLOT_LOOKUPREQ;
              end
            end else if (skip_to_biudata) begin
              next_slot_state = `CA53_SLOT_BIUDATA;
            end else if (skip_to_biuresp) begin
              next_slot_state = `CA53_SLOT_BIURESP;
            end else if (skip_to_biuack) begin
              next_slot_state = `CA53_SLOT_BIUACK;
            end else if (skip_to_biureq) begin
              next_slot_state = `CA53_SLOT_BIUREQ;
            end else if (dcu_stlr_dc3_i |
                         dcu_stb_exclusive_dc3_i |
                         ~dcu_stb_mergeable_dc3_i) begin
              next_slot_state = `CA53_SLOT_BIUREQ;
            end else begin
              next_slot_state = `CA53_SLOT_BIUMERGE;
            end
          end
        end
      end
      // ----------------------------------------------------------------------
      // Cache lookup
      // ----------------------------------------------------------------------
      `CA53_SLOT_LOOKUPREQ: begin
        if (slot_ev_hz_seen) begin
          // A STREX must fail if it sees an eviction hazard. Non-exclusives
          // wait for the hazard to clear and retry the lookup.
          if (slot_exclusive) begin
            next_slot_state = `CA53_SLOT_IDLE;
          end
        end else begin
          if (slot_biu_lf_hazard_i) begin
            // slot_biu_lf_real_hazard is ignored because the slot might not
            // have correct way information yet. This means an aborting linefill
            // hazard can not be reliably detected this cycle, and would not
            // be detected in CACHEWRITEREQ if the linefill completes this
            // cycle. Linefill completion and aborts are detected in LFREQ.
            next_slot_state = `CA53_SLOT_LFREQ;
          end else if (skip_to_cachemerge) begin
            next_slot_state = `CA53_SLOT_CACHEMERGE;
          end else if (sync_slots) begin
            // Stay in LOOKUPREQ until sameline slots are ready to perform a
            // lookup.
          end else if (start_lookup) begin
            // Start the lookup if we have priority, or if another slot in the
            // same line has priority.
            next_slot_state = `CA53_SLOT_LOOKUPM1;
          end
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_LOOKUPM1: begin
        if (dcu_stb_tag_ack_m1_i) begin
          next_slot_state = `CA53_SLOT_LOOKUPM2;
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_LOOKUPM2: begin
        if (slot_biu_lf_hazard_i) begin
          // slot_biu_lf_real_hazard is ignored because the slot might not
          // have correct way information yet. This means an aborting linefill
          // hazard can not be reliably detected this cycle, and would not
          // be detected in CACHEWRITEREQ if the linefill completes this
          // cycle. Linefill completion and aborts are detected in LFREQ.
          next_slot_state = `CA53_SLOT_LFREQ;
        end else begin
          // Go to the 'special' state when the real state depends on the
          // result of the tag lookup. This avoids the need to factor the
          // late hit signal into this next state logic.
          next_slot_state = `CA53_SLOT_SPECIAL;
        end
      end
      // ----------------------------------------------------------------------
      // Cache writes
      // ----------------------------------------------------------------------
      `CA53_SLOT_CACHEMERGE: begin
        if (slot_ev_hz_seen) begin
          next_slot_state = `CA53_SLOT_LOOKUPREQ;
        end else if (slot_full) begin
          next_slot_state = `CA53_SLOT_CACHEWRITEREQ;
        end else if (~slot_mergeable | slot_stlr |
                     slot_force_drain_i | slot_ccb_hz_seen) begin
          if (part_cache_read_required) begin
            next_slot_state = `CA53_SLOT_CACHEREADM0;
          end else begin
            next_slot_state = `CA53_SLOT_CACHEWRITEREQ;
          end
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_CACHEREADM0: begin
        if (CPU_CACHE_PROTECTION != 0) begin
          if (slot_has_cache_data_priority_i & dcu_stb_data_has_priority_m0_i) begin
            next_slot_state = `CA53_SLOT_CACHEREADM1;
          end else if (slot_ev_hz_seen) begin
            next_slot_state = `CA53_SLOT_LOOKUPREQ;
          end else if (slot_has_cleanunique_duty &
                       ~full_cache_read_required) begin
            next_slot_state = `CA53_SLOT_CLEANUNIQUE_REQ;
          end else if (~slot_has_cleanunique_duty &
                       ~part_cache_read_required) begin
            next_slot_state = `CA53_SLOT_CACHEWRITEREQ;
          end
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_CACHEREADM1: begin
        if (CPU_CACHE_PROTECTION != 0) begin
          if (dcu_stb_data_ack_m1_i) begin
            next_slot_state = `CA53_SLOT_CACHEREADM2;
          end
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_CACHEREADM2: begin
        if (CPU_CACHE_PROTECTION != 0) begin
          next_slot_state = `CA53_SLOT_CACHEECC;
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_CACHEECC: begin
        if (CPU_CACHE_PROTECTION != 0) begin
          if (dcu_ecc_data_err_m3_i) begin
            next_slot_state = `CA53_SLOT_CACHEECC_WAIT;
          end else if (slot_ev_hz_seen) begin
            next_slot_state = `CA53_SLOT_LOOKUPREQ;
          end else if (slot_has_cleanunique_duty) begin
            next_slot_state = `CA53_SLOT_CLEANUNIQUE_REQ;
          end else begin
            next_slot_state = `CA53_SLOT_CACHEWRITEREQ;
          end
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_CACHEECC_WAIT: begin
        if (CPU_CACHE_PROTECTION != 0) begin
          if (~dcu_ecc_in_progress_i) begin
            next_slot_state = `CA53_SLOT_LOOKUPREQ;
          end
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_CACHEWRITEREQ: begin
        if (slot_has_cache_data_priority_i & dcu_stb_data_has_priority_m0_i) begin
          next_slot_state = `CA53_SLOT_CACHEWRITEM1;
        end else if (slot_exclusive &
                     ~dcu_exclusive_monitor_i &
                     ~slot_has_cleanunique_duty) begin
          // The slot hit in the cache but the exclusive monitor has since been
          // cleared so the STREX fails. This is ignored if a CleanUnique has
          // been performed, as the exclusive monitor will have been checked
          // before the CleanUnique and a successful CleanUnique guarantees
          // that exclusivity has been retained.
          next_slot_state = `CA53_SLOT_IDLE;
        end else if (slot_ev_hz_seen &
                     ~slot_has_cleanunique_duty &
                     ~(slot_lf_hz_seen & slot_lf_can_merge)) begin
          // Return to lookup if there's an eviction hazard, unless the slot
          // must complete. The slot must complete if it has CleanUnique duty
          // so that dirty information is not lost (the slot will block the
          // eviction). The slot must also complete if a linefill aborted so
          // that the slot does not repeatedly request the same aborting
          // linefill (the BIU will wait for the merge and then raise an
          // imprecise abort). The slot can also complete if it was granted
          // permission to merge into a linefill because of having 128-bits
          // of data. A CleanUnique eviction hazard can be ignored as long
          // as the linefill is still available to be merged into and CCB
          // requests will be blocked.
          next_slot_state = `CA53_SLOT_LOOKUPREQ;
        end else if (part_cache_read_required & ~slot_lf_hz_seen) begin
          // If a read is required for ECC then go to the CACHEREADM0 state.
          // Delay this transition if there is a linefill in progress as we
          // don't know if the relevant data has been allocated yet.
          next_slot_state = `CA53_SLOT_CACHEREADM0;
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_CACHEWRITEM1: begin
        if (dcu_stb_data_ack_m1_i) begin
          next_slot_state = `CA53_SLOT_IDLE;
        end
      end
      // ----------------------------------------------------------------------
      // Linefill requests
      // ----------------------------------------------------------------------
      `CA53_SLOT_LFREQ: begin
        if (slot_exclusive & ~(slot_lf_hz_seen & dcu_exclusive_monitor_i)) begin
          next_slot_state = `CA53_SLOT_IDLE;
        end else if (slot_way_valid_lfreq &
                     slot_biu_lf_hazard_i & ~slot_biu_lf_real_hazard_i) begin
          // A linefill has started, the line is unique, and the tag has been
          // updated. The store data can be sent to the DCU (if it is writing
          // a full quadword, which is checked for in the CACHEWRITEREQ state).
          // This is qualified with the slot way information being valid
          // because CACHEWRITEREQ looks at a registered version of
          // slot_biu_ev_hazard and this is only valid when slot way
          // information is valid. If the aborting linefill were to complete
          // in the same cycle that the slot transitioned to CACHEWRITEREQ,
          // with way information being invalid, the eviction hazard would be
          // missed.
          next_slot_state = `CA53_SLOT_CACHEWRITEREQ;
        end else if (slot_lf_hz_seen & ~slot_biu_lf_hazard_i) begin
          // There was a hazard, but it has now gone. Therefore the linefill is
          // probably (but not guaranteed to be) in the cache, so we must redo
          // the lookup.
          next_slot_state = `CA53_SLOT_LOOKUPREQ;
        end
      end
      // ----------------------------------------------------------------------
      // Non-cacheable (or non-allocating) requests
      // ----------------------------------------------------------------------
      `CA53_SLOT_BIUMERGE: begin
        // The first beat of a Normal non-cacheable or Device GRE burst waits
        // here for more data before requesting an l2db id. Non-allocating
        // coherent stores do not wait in BIUMERGE as the attributes are more
        // likely to indicate a store stream, for which speculative waiting in
        // BIUDATA will be enabled. Since coherent stores do not enter this
        // state, no transition to LFREQ is necessary following a linefill
        // hazard (a linefill hazard to the same line indicates an attribute
        // mismatch).
        if (skip_to_biuack) begin
          next_slot_state = `CA53_SLOT_BIUACK;
        end else if (slot_force_drain_i | slot_merge_timeout) begin
          next_slot_state = `CA53_SLOT_BIUREQ;
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_BIUREQ: begin
        if (slot_lf_hz_seen) begin
          // If a hazarding linefill starts before a non-allocating coherent
          // store has been accepted by the BIU, the store must move to LFREQ.
          // This is so the store will merge into the cache and subsequent
          // loads will receive the correct data. The BIU is responsible for
          // suppressing an AR request if there is a linefill hazard. The
          // transition to LFREQ uses the registered hazard to avoid the
          // unregistered hazard factoring into skip logic for new slots.
          next_slot_state = `CA53_SLOT_LFREQ;
        end else if (slot_has_write_addr_priority_i |
                     (|(slots_have_write_addr_priority & (slot_sameline | slot_same_dev_write)))) begin
          next_slot_state = `CA53_SLOT_BIUACK;
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_BIUACK: begin
        // The BIU registers the ACK before sending it to the STB. If the slot
        // has seen a load to the sameline then the AR request is suppressed
        // to allow data to be forwarded (it cannot be forwarded from the BIU
        // if it is sent there after the load has been serialized). If the ACK
        // is received in the cycle that the AR request is being suppressed
        // then it must have been serialized before the load and must continue
        // to BIURESP.
        if (biu_stb_ar_ack_i) begin
          next_slot_state = `CA53_SLOT_BIURESP;
        end else if (slot_lf_hz_seen) begin
          // See BIUREQ for explanation.
          next_slot_state = `CA53_SLOT_LFREQ;
        end else if (slot_load_sameline_seen) begin
          next_slot_state = `CA53_SLOT_BIUREQ;
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_BIURESP: begin
        if (ar_resp_valid) begin
          next_slot_state = `CA53_SLOT_BIUDATA;
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_BIUDATA: begin
        if (slot_write_accept) begin
          if (slot_stlr & ~slot_exclusive) begin
            // The store part of an STLR must send a DSB afterwards to ensure
            // multi-copy atomicity. No DVM sync is required as the DSB is
            // only there to ensure observability of the store before
            // subseqent loads to the same address can have data forwarded from
            // the STB. Exclusive store releases do not require the DSB because
            // the DCU waits for the write response.
            next_slot_state = `CA53_SLOT_BARRIER_REQ;
          end else begin
            next_slot_state = `CA53_SLOT_IDLE;
          end
        end
      end
      // ----------------------------------------------------------------------
      // CleanUniques (following cache hit in shared state)
      // ----------------------------------------------------------------------
      `CA53_SLOT_CLEANUNIQUE_REQ: begin
        if (slot_exclusive & ~dcu_exclusive_monitor_i) begin
          // A STREX hit in the cache but the exclusive monitor has since been
          // cleared so the STREX fails. The monitor must be checked before the
          // CleanUnique request is made because the STREX must proceed (and
          // therefore pass) if an exclusive CleanUnique completes successfully
          // (so that dirty information is not lost).
          next_slot_state = `CA53_SLOT_IDLE;
        end else if (slot_has_cleanunique_priority_i |
                     (|(slots_have_cleanunique_priority & slot_sameline))) begin
          next_slot_state = `CA53_SLOT_CLEANUNIQUE_ACK;
        end else if (slot_ev_hz_seen) begin
          next_slot_state = `CA53_SLOT_LOOKUPREQ;
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_CLEANUNIQUE_ACK: begin
        if (biu_stb_ar_ack_i) begin
          next_slot_state = `CA53_SLOT_CLEANUNIQUE_RESP;
        end else if (slot_ev_hz_seen) begin
          // The line is being evicted. The request has been suppressed in this
          // cycle and the request from the previous cycle was not ACK'd so we
          // retry the lookup. For non-exclusives this is not strictly
          // necessary as the CleanUnique response will indicate whether the
          // line is still present in the cache. However, a STREX must
          // observe eviction hazards up to the cycle when the CleanUnique is
          // sent to the SCU so that if the line is re-allocated, it is not
          // mistaken for meeting exclusivity requirements. The STREX is
          // failed from the LOOKUPREQ state.
          next_slot_state = `CA53_SLOT_LOOKUPREQ;
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_CLEANUNIQUE_RESP: begin
        if (ar_resp_valid) begin
          if (slot_exclusive & ar_resp_excl_fail) begin
            // The exclusive failed. The line is no longer in the cache or the
            // interconnect failed the CleanUnique. The SCU ensures the line is
            // not invalidated in other CPUs so no dirty information is lost
            // when the write is abandonned.
            next_slot_state = `CA53_SLOT_IDLE;
          end else if (~slot_exclusive & ar_resp_fail) begin
            // The line is no longer in the cache.
            next_slot_state = `CA53_SLOT_LOOKUPREQ;
          end else begin
            next_slot_state = `CA53_SLOT_TAGWRITE;
          end
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_TAGWRITE: begin
        if (tagwrite_accepted) begin
          // The tag update has been accepted. The slot with CleanUnique duty
          // proceeds directly to CACHEWRITEREQ in order to update the dirty
          // RAM (it has already done a cache read if necessary). Other slots
          // proceed to CACHEWRITEREQ or CACHEREADM0 depending on whether they
          // have enough data for the ECC calculation (if cache protection is
          // present).
          if (part_cache_read_required) begin
            next_slot_state = `CA53_SLOT_CACHEREADM0;
          end else begin
            next_slot_state = `CA53_SLOT_CACHEWRITEREQ;
          end
        end
      end
      // ----------------------------------------------------------------------
      // CP15
      // ----------------------------------------------------------------------
      `CA53_SLOT_CP15REQ: begin
        if (slot_has_ar_priority_i) begin
          next_slot_state = `CA53_SLOT_CP15ACK;
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_CP15ACK: begin
        if (biu_stb_ar_ack_i) begin
          next_slot_state = `CA53_SLOT_CP15RESP;
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_CP15RESP: begin
        if (ar_resp_valid) begin
          if (cp15_is_dc_maint) begin
            next_slot_state = `CA53_SLOT_IDLE;
          end else begin
            next_slot_state = `CA53_SLOT_DVMDATA;
          end
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_DVMDATA: begin
        if (slot_write_accept) begin
          if (cp15_is_dsb) begin
            next_slot_state = `CA53_SLOT_SYNCRESP2;
          end else begin
            next_slot_state = `CA53_SLOT_IDLE;
          end
        end
      end
      // ----------------------------------------------------------------------
      // Barriers
      // ----------------------------------------------------------------------
      `CA53_SLOT_SYNCREQ: begin
        if (slot_has_ar_priority_i) begin
          next_slot_state = `CA53_SLOT_SYNCACK;
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_SYNCACK: begin
        if (biu_stb_ar_ack_i) begin
          next_slot_state = `CA53_SLOT_SYNCRESP1;
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_SYNCRESP1: begin
        if (slot_ar_resp_valid_i) begin
          next_slot_state = `CA53_SLOT_DVMDATA;
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_SYNCRESP2: begin
        if (dvm_complete_i) begin
          next_slot_state = `CA53_SLOT_BARRIER_REQ;
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_BARRIER_REQ: begin
        if (slot_has_ar_priority_i) begin
          next_slot_state = `CA53_SLOT_BARRIER_ACK;
        end else if (barrier_can_propagate &
                     ~propagate_barrier_i) begin
          next_slot_state = `CA53_SLOT_IDLE;
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_BARRIER_ACK: begin
        if (biu_stb_ar_ack_i) begin
          next_slot_state = `CA53_SLOT_BARRIER_RESP;
        end
      end
      // ----------------------------------------------------------------------
      `CA53_SLOT_BARRIER_RESP: begin
        if (slot_ar_resp_valid_i) begin
          next_slot_state = `CA53_SLOT_IDLE;
        end
      end
      // ----------------------------------------------------------------------
      default: next_slot_state = `CA53_SLOT_X;
    endcase
  end

  // Create the real request signal by factoring DPU exceptions into it.
  // Because this is factored into the enable terms, most other places can
  // just use the unqualified slot_new_req_dc3 which is a lot earlier than
  // dpu_kill_wr.
  assign slot_real_new_req_dc3 = slot_new_req_dc3_i & ~dpu_kill_wr_i;

  assign slot_state_en = slot_valid | slot_real_new_req_dc3;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    slot_state <= `CA53_SLOT_IDLE;
  end else if (slot_state_en) begin
    slot_state <= next_slot_state;
  end

  // Decode states. The ones that are timing critical are encoded to enable
  // trivial decode logic.

  assign slot_valid = `CA53_SLOT_VALID(slot_state);

  assign slot_state_biureq = `CA53_SLOT_STATE_BIUREQ(slot_state,
                                                     tag_hit_shared_m3_i[1],
                                                     tag_ecc_err_m3_i,
                                                     slot_no_alloc_on_miss,
                                                     slot_ev_hz_seen);

  assign slot_state_biuack = `CA53_SLOT_STATE_BIUACK(slot_state);

  assign slot_state_biuresp = `CA53_SLOT_STATE_BIURESP(slot_state);

  assign slot_state_biudata = `CA53_SLOT_STATE_BIUDATA(slot_state);

  assign slot_state_cachewritem1 = `CA53_SLOT_STATE_CACHEWRITEM1(slot_state);

  assign slot_state_lookupreq = `CA53_SLOT_STATE_LOOKUPREQ(slot_state,
                                                           tag_hit_shared_m3_i[1],
                                                           tag_ecc_err_m3_i,
                                                           slot_no_alloc_on_miss,
                                                           slot_ev_hz_seen);

  assign slot_state_lookupm1 = `CA53_SLOT_STATE_LOOKUPM1(slot_state);

  assign slot_state_lookupm2 = `CA53_SLOT_STATE_LOOKUPM2(slot_state);

  assign slot_state_special = `CA53_SLOT_STATE_SPECIAL(slot_state);

  assign slot_state_lfreq = `CA53_SLOT_STATE_LFREQ(slot_state, tag_hit_shared_m3_i[1], tag_ecc_err_m3_i, slot_no_alloc_on_miss);

  assign slot_state_cleanunique_req = `CA53_SLOT_STATE_CLEANUNIQUE_REQ(slot_state, tag_hit_shared_m3_i[0], tag_ecc_err_m3_i, full_cache_read_required);

  assign slot_state_cleanunique_ack = `CA53_SLOT_STATE_CLEANUNIQUE_ACK(slot_state);

  assign slot_state_cleanunique_resp = `CA53_SLOT_STATE_CLEANUNIQUE_RESP(slot_state);

  assign slot_state_tagwrite = `CA53_SLOT_STATE_TAGWRITE(slot_state);

  assign slot_state_biumerge = `CA53_SLOT_STATE_BIUMERGE(slot_state);

  assign slot_state_cachemerge = `CA53_SLOT_STATE_CACHEMERGE(slot_state,
                                                             (slot_mergeable & ~slot_full),
                                                             (tag_hit_shared_m3_i == 2'b10),
                                                             tag_ecc_err_m3_i);

  assign slot_state_cachereadm0 = `CA53_SLOT_STATE_CACHEREADM0(slot_state, tag_hit_shared_m3_i[0], tag_ecc_err_m3_i, full_cache_read_required);

  assign slot_state_cachereadm1 = `CA53_SLOT_STATE_CACHEREADM1(slot_state);

  assign slot_state_cachereadm2 = `CA53_SLOT_STATE_CACHEREADM2(slot_state);

  assign slot_state_cacheecc = `CA53_SLOT_STATE_CACHEECC(slot_state);

  assign slot_state_cacheecc_wait = `CA53_SLOT_STATE_CACHEECC_WAIT(slot_state, tag_ecc_err_m3_i);

  assign slot_state_cachewritereq = `CA53_SLOT_STATE_CACHEWRITEREQ(slot_state,
                                                                   (slot_mergeable & ~slot_full),
                                                                   (tag_hit_shared_m3_i == 2'b10),
                                                                   tag_ecc_err_m3_i);

  assign slot_state_cp15req = `CA53_SLOT_STATE_CP15REQ(slot_state);

  assign slot_state_cp15ack = `CA53_SLOT_STATE_CP15ACK(slot_state);

  assign slot_state_cp15resp = `CA53_SLOT_STATE_CP15RESP(slot_state);

  assign slot_state_dvmdata = `CA53_SLOT_STATE_DVMDATA(slot_state);

  assign slot_state_syncreq = `CA53_SLOT_STATE_SYNCREQ(slot_state);

  assign slot_state_syncack = `CA53_SLOT_STATE_SYNCACK(slot_state);

  assign slot_state_syncresp1 = `CA53_SLOT_STATE_SYNCRESP1(slot_state);
  assign slot_state_syncresp2 = `CA53_SLOT_STATE_SYNCRESP2(slot_state);

  assign slot_state_barrier_req = `CA53_SLOT_STATE_BARRIER_REQ(slot_state);
  assign slot_state_barrier_ack = `CA53_SLOT_STATE_BARRIER_ACK(slot_state);
  assign slot_state_barrier_resp = `CA53_SLOT_STATE_BARRIER_RESP(slot_state);

  // Convert the special states into the real state that they represent now
  // that the hit information is known.
  assign modified_slot_state = `CA53_SLOT_MODIFIED_STATE(slot_state,
                                                         (slot_mergeable & ~slot_full),
                                                         tag_hit_shared_m3_i,
                                                         tag_ecc_err_m3_i,
                                                         full_cache_read_required,
                                                         slot_no_alloc_on_miss,
                                                         slot_ev_hz_seen);

  assign new_req_from_idle = slot_new_req_dc3_i & ~slot_valid;

  assign real_new_req_from_idle = slot_new_req_dc3_i & ~slot_valid & ~dpu_kill_wr_i;

  // Calculate when the slot is going back to the idle state. This is logically
  // the same as slot_valid & ~next_slot_valid, but without a lot of
  // unnecessary logic factored in.
  assign slot_emptying = (slot_write_accept &
                          ~(slot_state_biudata & slot_stlr & ~slot_exclusive) &
                          ~(slot_state_dvmdata & cp15_is_dsb)) |
                         (slot_state_lookupreq &
                          slot_exclusive & slot_ev_hz_seen) |
                         (slot_state_cleanunique_req &
                          slot_exclusive & ~dcu_exclusive_monitor_i) |
                         (slot_state_cleanunique_resp &
                          slot_exclusive & ar_resp_valid & ar_resp_excl_fail) |
                         (slot_state_cachewritereq &
                          slot_exclusive & ~dcu_exclusive_monitor_i & ~slot_has_cleanunique_duty) |
                         (slot_state_cachewritem1 & dcu_stb_data_ack_m1_i) |
                         (slot_state_lfreq & (slot_exclusive &
                                              ~(slot_lf_hz_seen & dcu_exclusive_monitor_i))) |
                         (slot_state_cp15resp & slot_ar_resp_valid_i & cp15_is_dc_maint) |
                         (slot_state_barrier_req &
                          barrier_can_propagate & ~propagate_barrier_i) |
                         (slot_state_barrier_resp & slot_ar_resp_valid_i);

  // Skip to the BIUREQ, BIUACK, or BIURESP states if other slots in the same line
  // are progressing through these states.
  assign early_slot_same_burst = early_slot_sameline | early_slot_same_dev_write;

  assign skip_to_biureq = (|(slots_state_biureq & early_slot_same_burst & ~slots_lf_hz_seen & ~slots_have_write_addr_priority)) |
                          (|(slots_state_biuack & early_slot_same_burst & ~slots_lf_hz_seen & slots_load_sameline_seen) & ~biu_stb_ar_ack_i);

  assign skip_to_biuack = (|(slots_state_biuack & early_slot_same_burst & ~slots_lf_hz_seen & ~slots_load_sameline_seen) & ~biu_stb_ar_ack_i) |
                          (|(slots_have_write_addr_priority & early_slot_same_burst));

  assign skip_to_biuresp = (|(slots_state_biuresp & early_slot_same_burst) & ~ar_resp_valid) |
                           (|(slots_state_biuack & early_slot_same_burst) & biu_stb_ar_ack_i);

  assign skip_to_biudata = (|(slots_state_biudata & early_slot_same_burst & ~slots_write_accept)) |
                           (|(slots_state_biuresp & early_slot_same_burst) & ar_resp_valid);

  // Skip to LFREQ if other slots in the same line are there or moving there from BIUACK.
  // Don't skip if another slot in LFREQ has seen a linefill hazard, because the linefill
  // might be completing this cycle and transitioning to LFREQ will cause a second linefill
  // request. Transitioning based on slot_biu_lf_hazard_i is done separately.
  // Note: biu_stb_ar_ack_i is known to be low when there is a registered linefill
  //       hazard in the BIUACK state because the AR request will have been
  //       suppressed by the BIU in the previous cycle.
  assign skip_to_lfreq = (|(slots_state_lfreq & ~slots_lf_hz_seen & early_slot_sameline)) |
                         (|((slots_state_biureq |
                             slots_state_biuack) & slots_lf_hz_seen & early_slot_sameline));

  // This is effectively next_slot_sameline, but without factoring new requests
  // that are going to other slots. These cannot affect the behaviour of this
  // slot on this cycle, so ignore them to help timing.
  assign early_slot_sameline = slot_valid ? slot_sameline :
                               (slots_dcu_store_sameline_dc3 & slots_valid);

  // Move from lookup req state to lookup m1 when this slot gets priority, or
  // when any other slot in the same line gets priority (because the tag result
  // will be identical if the slots are in the same line).
  assign start_lookup = ((slot_has_lookup_priority_i |
                          (|(slots_have_lookup_priority & slot_sameline))) &
                         dcu_stb_tag_has_priority_m0_i);

  // Skip the lookup request state if a slot in the same line is staying in or
  // about to move to the lookupm1 state. From here they will both progress
  // through the rest of the lookup in lockstep.
  assign skip_to_lookupm1 = ((|(slots_have_lookup_priority & early_slot_sameline) &
                              dcu_stb_tag_has_priority_m0_i) |
                             (|(slots_state_lookupm1 & early_slot_sameline) &
                              ~dcu_stb_tag_ack_m1_i));

  // Skip the lookup request and m1 states if a slot in the same line is about
  // to move to the lookupm2 state. From here they will both progress
  // through the rest of the lookup in lockstep.
  assign skip_to_lookupm2 = (|(slots_state_lookupm1 & early_slot_sameline) &
                             dcu_stb_tag_ack_m1_i);

  // Skip the lookup states to the special state if another slot in the same
  // line will be going to the special state.
  assign skip_to_special = |(slots_state_lookupm2 & early_slot_sameline & ~slots_biu_lf_hazard);

  // Skip the lookup states if another slot in the same line has hit in the cache.
  assign skip_to_cachemerge = |((slots_state_cachemerge |
                                 (~slots_have_cleanunique_duty &
                                  (slots_state_cachereadm0 |
                                   slots_state_cachereadm1 |
                                   slots_state_cachereadm2 |
                                   slots_state_cacheecc)) |
                                 slots_state_cachewritereq |
                                 slots_state_cachewritem1 |
                                 (slots_state_tagwrite &
                                  {4{tagwrite_accepted}})) &
                                ~slots_ev_hz_seen &
                                early_slot_sameline);

  // Skip to the cleanunique_req state if another slot in the sameline is
  // making a request.
  assign skip_to_cleanunique_req = |((slots_state_cleanunique_req |
                                      (slots_have_cleanunique_duty &
                                       (slots_state_cachereadm0 |
                                        slots_state_cachereadm1 |
                                        slots_state_cachereadm2 |
                                        slots_state_cacheecc))) &
                                     ~slots_ev_hz_seen &
                                     early_slot_sameline);

  // Wait for the ack if another slot in the sameline has made a request
  // this cycle.
  assign skip_to_cleanunique_ack = |((slots_state_cleanunique_ack |
                                      slots_have_cleanunique_priority) &
                                     ~slots_ev_hz_seen &
                                     early_slot_sameline);

  // Skip to resp if another slot is also going there or remaining there.
  assign skip_to_cleanunique_resp = (|(slots_state_cleanunique_resp & early_slot_sameline) &
                                     ~|(slots_ar_resp_valid & early_slot_sameline)) |
                                    (|(slots_state_cleanunique_ack & {4{biu_stb_ar_ack_i}} & early_slot_sameline));

  // Skip to the tag write state if another slot in the same line has done
  // a CleanUnique. If the SCU gives an EXOKAY response to a non-exclusive
  // then the line is no longer in the cache and the lookup needs to be
  // redone.
  assign skip_to_tagwrite = (|(slots_state_tagwrite & early_slot_sameline) &
                             ~|(slots_have_tagwrite_priority &
                                {4{dcu_stb_tag_has_priority_m0_i}} & early_slot_sameline)) |
                            (|(slots_state_cleanunique_resp & early_slot_sameline &
                               {4{ar_resp_valid}}) &
                             ~ar_resp_fail);

  // A write to the tag RAM following a CleanUnique has been accepted by the cache
  // arbiter for either this slot or another in the sameline (which will have
  // been writing exactly the same value as this slot wanted to).
  assign tagwrite_accepted = (slot_has_tagwrite_priority_i |
                              (|(slots_have_tagwrite_priority & early_slot_sameline))) &
                             dcu_stb_tag_has_priority_m0_i;

  // When a CleanUnique completes, determine whether it passed or failed. An
  // exclusive CleanUnique will fail and return to IDLE on an OKAY response.
  // A non-exclusive CleanUnique will fail on an EXOKAY response. These
  // responses indicate that the line is no longer in the L1 cache. A SLVERR
  // or DECERR is treated as a pass to be consistent with the SCU. The STB
  // will update the tag as normal and the BIU will raise an imprecise abort.
  assign ar_resp_fail = (biu_stb_ar_resp_i == 2'b01);
  assign ar_resp_excl_fail = (biu_stb_ar_resp_i == 2'b00);

  // An address request has completed either for this slot, or another slot in
  // the same line.
  assign ar_resp_valid = (slot_ar_resp_valid_i |
                           (|(slots_ar_resp_valid & (early_slot_sameline | early_slot_same_dev_write))));

  // When a response is received for an address request, record the SCU buffer that is
  // associated with it.  When skipping the address request, we must pick the buffer from
  // another slot in the same line. It doesn't matter which, as they must all be the same.
  assign next_slot_l2dbid = ar_resp_valid ? biu_stb_ar_resp_l2dbid_i :
                            (slot_valid ? slot_l2dbid :
                             (({4{early_slot_sameline[3] | early_slot_same_dev_write[3]}} & slotd_l2dbid_i) |
                              ({4{early_slot_sameline[2] | early_slot_same_dev_write[2]}} & slotc_l2dbid_i) |
                              ({4{early_slot_sameline[1] | early_slot_same_dev_write[1]}} & slotb_l2dbid_i) |
                              ({4{early_slot_sameline[0] | early_slot_same_dev_write[0]}} & slota_l2dbid_i)));

  always @(posedge clk)
  if (slot_state_en) begin
    slot_l2dbid <= next_slot_l2dbid;
  end

  assign slot_l2dbid_o = slot_l2dbid;


  //----------------------------------------------------------------------------
  // Address and data formatting (for stores and CP15 operations)
  //----------------------------------------------------------------------------

  assign cp15_type = slot_bls[7:0];

  // Identify type of cp15 op.
  assign cp15_is_tlb_maint = `CA53_CPOP_8_IS_TLBM(cp15_type);
  assign cp15_is_bp_maint = `CA53_CPOP_8_IS_BPM(cp15_type);
  assign cp15_is_dc_maint = `CA53_CPOP_8_IS_DCM(cp15_type);
  assign cp15_is_dc_maint_sw = `CA53_CPOP_8_IS_DCM_SW(cp15_type);
  assign cp15_is_dsb = `CA53_CPOP_8_IS_DSB(cp15_type);
  assign cp15_is_dmb_affecting_loads = `CA53_CPOP_8_IS_DMB(cp15_type) &
                                       ~`CA53_CPOP_8_IS_DMBST(cp15_type);

  // Extract 5-bit op (valid for TLB ops).
  assign cp15_type_tlb_op = cp15_type[4:0];

  // Force non-IS version of TLB op to simplify comparisons.
  assign cp15_type_tlb_non_is = `CA53_CPOP_5_TLBM_AS_NON_IS(cp15_type_tlb_op);

  // Determine whether the cp15 op is aarch64. Valid for TLB ops and also BP ops,
  // which naturally fall out to be aarch32. IC ops fall out to be aarch32 (even
  // aarch64 versions) which is considered valid within the STB because we only
  // do instruction cache invalidates by PA and therefore only need to send
  // the virtual index (bits [27:12]) which is available when treating the
  // instruction cache op as the aarch32 version.
  assign cp15_aarch64 = `CA53_CPOP_8_TLBM_IS_AA64(cp15_type);

  assign match_ipa = (cp15_type_tlb_non_is == `CA53_CPOP_5_TLBIIPAS2E1) |
                     (cp15_type_tlb_non_is == `CA53_CPOP_5_TLBIIPAS2LE1);

  assign cp15_ipa = {{8{cp15_aarch64}} & slot_data[35:28], slot_data[27:0], 12'h000};

  // Match VA[31:12] for TLB ops and full VA for BP/DC ops.
  assign cp15_va_aarch32 = {slot_data[31:12], {12{~cp15_is_tlb_maint}} & slot_data[11:0]};

  assign cp15_va_aarch64 = // Match VA[48:12] for TLB ops.
                           ({49{cp15_is_tlb_maint}} & {slot_data[36:0], 12'h000}) |
                           // Otherise match VA[48:0]. VA[48:45] are suppressed for
                           // DVM Syncs to prevent them propagating into the SBZ
                           // bits of the external DVM Sync request.
                           ({49{~cp15_is_tlb_maint}} &
                            {slot_data[48:45] & ~{4{slot_state_syncreq | slot_state_syncack}},
                             slot_data[44:0]});

  assign cp15_ipa_va = ({49{match_ipa}}                  & {1'b0, cp15_ipa}) |
                       ({49{~match_ipa &  cp15_aarch64}} & cp15_va_aarch64)  |
                       ({49{~match_ipa & ~cp15_aarch64}} & {17'h00000, cp15_va_aarch32});

  assign dc_maint_sw_addr = {8'h00, slot_data[31:28],       // way
                             11'h000, slot_data[16:6],      // set
                             2'b00, slot_data[3:1], 1'b0};  // level

  assign cp15_asid_aarch32 = slot_data[7:0];

  assign cp15_asid_aarch64 = slot_data[63:48];

  assign slot_cp15_asid_o = cp15_aarch64 ? cp15_asid_aarch64 : {8'h00, cp15_asid_aarch32};

  assign slot_cp15_vmid_o = slot_bls[15:8];

  assign slot_cp15_va_o = {cp15_ipa_va[48:40], cp15_ipa_va[27:12]};

  assign addr_sel_ipa_va = (slot_state_cp15req | slot_state_cp15ack) & (cp15_is_tlb_maint | cp15_is_bp_maint);
  assign addr_sel_sw = (slot_state_cp15req | slot_state_cp15ack) & cp15_is_dc_maint_sw;
  assign addr_sel_pa = ~addr_sel_sw & ~addr_sel_ipa_va;

  assign slot_ar_addr_o = ({40{addr_sel_ipa_va}} & cp15_ipa_va[39:0]) |
                          ({40{addr_sel_sw}} & dc_maint_sw_addr) |
                          ({40{addr_sel_pa}} & slot_addr);

  assign slot_ar_ns_o = slot_ns;

  // Override priv information from the DCU for some transactions.
  assign slot_ar_priv_o = slot_priv;

  assign slot_write_data_o = slot_state_biudata ?
                             slot_data :
                             {81'h0_0000_0000_0000_0000_0000,
                              `CA53_CPOP_8_IS_ICM_MVA(cp15_type) ?
                              {9'h000, slot_addr[39:6]} : // PA[39:6] for ICI by MVA
                              cp15_ipa_va[48:6],          // VA[48:6] for TLB/BP ops
                              4'b0000};

  assign slot_write_bls_o = slot_state_biudata ?
                            slot_bls :
                            16'h00FF;

  // DVM messages always send a single chunk, marking it as chunk 0.
  assign slot_write_chunk_o = {2{slot_state_biudata}} &
                              slot_addr[5:4];

  // DVM message data is always maked as last. Non-mergeable writes propagate
  // last information from the DCU. Mergeable writes calculate last information
  // based on sameline slots.
  assign slot_write_last_o = ~slot_state_biudata |
                             (`CA53_MEM_MERGEABLE(slot_attrs) ?
                              ~|(slots_state_biudata & slot_sameline) :
                              slot_last);


  //----------------------------------------------------------------------------
  // Hazards
  //----------------------------------------------------------------------------

  // Record when this slot has seen a linefill hazard. This is used to detect
  // when the hazard has gone away, so that the slot will not continue
  // requesting a linefill if the line may now be in the cache.
  //
  // If slot_lf_hz_seen is already asserted and the slot state might be in LFREQ
  // next cycle then slot_lf_hz_seen is extended for an additional cycle. This
  // is so the slot does not request another linefill from LFREQ if the linefill
  // hazard has been dropped.
  //
  // Only linefill hazards on coherent slots are recorded, as non-coherent and
  // coherent transactions must not hazard on each other.
  assign slot_lf_hz_capture = (slot_coherent & slot_biu_lf_hazard_i) |
                              ((slot_state_lfreq |
                                slot_state_lookupm2 |
                                slot_state_biureq |
                                slot_state_biuack) & slot_lf_hz_seen);
  
  assign next_slot_lf_hz_seen = (slot_valid & slot_lf_hz_capture) |
                                (|(early_slot_sameline & slots_lf_hz_capture));
  
  always @(posedge clk)
  if (slot_state_en) begin
    slot_lf_hz_seen <= next_slot_lf_hz_seen;
  end

  // If a linefill hazard was seen but is not present in the LFREQ state then
  // the slot needs to return to LOOKUPREQ. A sameline slot might be moving to
  // LFREQ at this time, with slot_lf_hz_seen asserted to ensure that it too
  // returns to LOOKUPREQ. To avoid a captured linefill hazard being maintained
  // indefinitely due to out-of-step slots, the sameline slots are brought
  // in-step.
  assign sync_slots = |(slot_sameline & ~slots_state_lookupreq) & slot_lf_hz_seen;

  // The slot will block CCB requests to the same index and way under the
  // following scenarios:
  //
  // - A CCB request hazards on a slot that has completed a CleanUnique, but
  //   has not updated the tag and dirty RAMs. The CCB request must be blocked
  //   from starting until the RAM update has taken place. This prevents livelock
  //   if two CPUs are trying to get unique access to the same line at the same
  //   time, ensuring that whichever one of the two gets serialized first will
  //   perform its write.
  //
  // - A CCB request hazards on a slot that has seen a linefill allocate as
  //   unique. If the slot does not contain a full 128 bits of data then
  //   it will not be able to merge, and might have to do a read-modify-write.
  //   The CCB request is hazarded until the read-modify-write completes.
  //   This prevents ReadUniques from multiple CPUs causing the line to be
  //   move back and forth with the line continually being invalidated
  //   before any CPU completes its read-modify-write.
  // 
  // - A CCB request hazards on a slot that is in the process of writing the
  //   data. The slot will be ignoring eviction hazards at this point so the
  //   CCB request must not read the data or dirty state until after the 
  //   write has completed.
  assign dc_index_mask = {dc_size_i, 5'b11111};

  assign ccb_index_match = (slot_addr[13:6] & dc_index_mask) ==
                           (dcu_ccb_index_i & dc_index_mask);

  assign ccb_way_match = |(slot_way_onehot & dcu_ccb_ways_i);

  assign slot_block_ccb_o = ccb_index_match & ccb_way_match &
                            (slot_post_lf_merge |
                             slot_state_tagwrite |
                             (slot_state_cachewritereq &
                              (~wait_for_earlier_slot &
                               ~(slot_lf_hz_seen & ~slot_lf_can_merge))) |
                             slot_state_cachewritem1);

  // Calculate if a CCB request might be going to evict the line that this
  // slot hit. If the slot is not blocking the CCB request then it will
  // have to redo its tag lookup. The hazard will be ignored if the slot
  // has completed a CleanUnique as dirty data might have been invalidated
  // in other CPUs and the slot now has responsibility to complete the
  // store so that the dirty status is retained (the slot will block CCB
  // requests in this case).
  //
  // The slot pessimistically hazards on an index match in the LOOKUPM2
  // state because way information is not yet available. Similarly for
  // LOOKUPREQ as there is no point clearing slot_ev_hz_seen if the slot
  // will pessimistically hazard again in M2. Other than in these states,
  // CCB eviction hazards are only observed when way information is valid
  // (ie in cache hit states).
  assign ccb_ev_hazard = dcu_ccb_req_valid_i & ccb_index_match &
                         (ccb_way_match |
                          slot_state_lookupm2 |
                          (slot_ev_hz_seen & slot_state_lookupreq));

  // Detect when this slot has seen an eviction hazard. This is used to
  // avoid requesting a new linefill until the eviction has completed or
  // to return to the lookup request state if the slot has already hit in
  // the cache. An eviction can be signaled by an address hazard with a
  // snoop, a linefill that has aborted, or a CleanUnique that fails (due
  // to a previously serialized linefill that aborted).

  // An ongoing linefill received an error response and will be invalidated.
  // This hazard is ignored if the BIU has accepted a merge request as the
  // linefill descriptor will remain active until the merge completes. A
  // merge from a slot that started a linefill must succeed in order that
  // an imprecise abort is raised. This prevents the slot from repeatedly
  // starting linefills for the same aborting line. The eviction hazard is
  // index-way based and therefore only observe in states where the slot
  // way information is valid.
  assign slot_ev_hazard_lf = ((slot_state_lfreq & slot_way_valid_lfreq) |
                              slot_state_cachemerge |
                              slot_state_cachereadm0 |
                              slot_state_cachewritereq |
                              slot_state_cachewritem1) &
                             slot_biu_ev_hazard_i;

  // A snoop to the same line as the slot might have changed the MOESI state.
  // We must ignore CCB hazards if we are blocking the CCB request, but need to
  // check for CCB hazards the cycle before we might start blocking, so that we
  // don't try to block a CCB request that has already started.
  assign slot_ev_hazard_ccb = (slot_state_lookupm2 |
                               slot_state_cleanunique_req |
                               slot_state_cleanunique_ack |
                               slot_state_cachemerge |
                               slot_state_cachereadm0 |
                               slot_state_cachereadm1 |
                               slot_state_cachereadm2 |
                               slot_state_cacheecc |
                               (slot_state_cachewritereq &
                                (wait_for_earlier_slot |
                                 (slot_lf_hz_seen & ~slot_lf_can_merge)))) &
                              ccb_ev_hazard &
                              ~slot_post_lf_merge;

  // A CleanUnique response indicates that the line is no longer allocated or
  // is going to be invalidated due to an aborting linefill.
  assign slot_ev_hazard_cu = slot_state_cleanunique_resp &
                             slot_ar_resp_valid_i &
                             ar_resp_fail &
                             ~slot_exclusive;

  // A lookup or cache read received an ECC error. The line will be evicted
  // during its correction. Sameline slots use the eviction hazard to avoid
  // repeating a lookup and causing the same tag error to be signalled twice.
  // Data errors do not always need to be observed by sameline slots but
  // keeping slots consistent allow more robust unit level and formal
  // verification. It is also necessary in the case where a slot is waiting
  // in CLEANUNIQUE_REQ and a sameline slot with CleanUnique duty receives
  // a data error. The slot with CleanUnique duty is likely to start a
  // linefill after the correction, leaving sameline slots stranded in
  // CLEANUNIQUE_REQ if they do not see an eviction hazard.
  assign slot_ev_hazard_ecc = (CPU_CACHE_PROTECTION != 0) &
                              ((slot_state_special & tag_ecc_err_m3_i) |
                               (slot_state_cacheecc & dcu_ecc_data_err_m3_i) |
                               (slot_state_cacheecc_wait & dcu_ecc_in_progress_i));

  // Clear eviction hazards once the lookup has restarted.
  assign slot_ev_hazard_clr = slot_state_lookupm1 |
                              slot_state_lookupm2 |
                              (slot_state_lookupreq & ~(ccb_ev_hazard |
                                                        slot_biu_ev_hazard_i));

  // Consolodate eviction hazards.
  assign slot_ev_hazard = slot_ev_hazard_lf |
                          slot_ev_hazard_ccb |
                          slot_ev_hazard_cu |
                          slot_ev_hazard_ecc |
                          (slot_valid & slot_ev_hz_seen & ~slot_ev_hazard_clr);

  // Pick the value from other slots in the sameline if this slot is new.
  assign next_slot_ev_hz_seen = (slot_ev_hazard & slot_valid) | (|(early_slot_sameline & slots_ev_hazard));

  always @(posedge clk)
  if (slot_state_en) begin
    slot_ev_hz_seen <= next_slot_ev_hz_seen;
  end

  // It is necessary to force the slot to drain if it has seen a CCB hazard,
  // to ensure that the slot becomes visible to the other observer eventually.
  // For most CCB requests the slot will naturally drain afterwards, because
  // the line will now be invalid or shared/owned (and hence will need a
  // ReadUnique or CleanUnique request), but for a few requests the state will
  // not have changed and so the slot may end up back in cachemerge after doing
  // the lookup.
  assign next_slot_ccb_hz_seen = slot_valid & (ccb_ev_hazard | slot_ccb_hz_seen);

  always @(posedge clk)
  if (slot_state_en) begin
    slot_ccb_hz_seen <= next_slot_ccb_hz_seen;
  end

                                 
  //----------------------------------------------------------------------------
  // Track CleanUnique duty
  //----------------------------------------------------------------------------

  // If a cache lookup hits a shared line then the earliest slot in the lookup
  // M2 state has responsibility for performing the CleanUnique.
  //
  // A slot with CleanUnique duty ignores eviction hazards once the CleanUnique
  // has completed. This is because dirty data might have been invalidated in
  // other CPUs and the slot must proceed with the write in order to maintain
  // the dirty status of the line. The slot will block CCB requests to the same
  // address during this time.
  //
  // When CleanUnique duty is assigned, slots in the same line that do not have
  // CleanUnique duty wait in the CleanUnique request state until the slot that
  // does have CleanUnique duty is ready to perform the CleanUnique. When CPU
  // cache protection is not present, this will be immediately following the
  // lookup. When CPU cache protection is present, if the slot with CleanUnique
  // duty does not have 128 bits of valid data then it must first traverse the
  // cache read states. The slot must have 128 bits of valid data before the
  // CleanUnique to ensure that no cache reads that might see an ECC error are
  // performed after the CleanUnique (the slot must update the cache following
  // a successful CleanUnique and therefore must have valid data to write).
  assign slot_has_cleanunique_duty_set = slot_state_lookupm2 &
                                         dcu_stb_tag_shared_m2_i &
                                         ~slot_biu_lf_hazard_i &
                                         ~|(slots_state_lookupm2 & slot_earlier) &
                                         ~|(slots_have_cleanunique_duty & slot_sameline);

  assign slot_has_cleanunique_duty_clr = // New request
                                         new_req_from_idle |
                                         // Tag lookup received ECC error
                                         (slot_state_special &
                                          tag_ecc_err_m3_i) |
                                         // Data read received ECC error
                                         (slot_state_cacheecc &
                                          dcu_ecc_data_err_m3_i) |
                                         // CleanUnique failed
                                         (slot_state_cleanunique_resp &
                                          ar_resp_valid &
                                          ar_resp_fail &
                                          ~slot_exclusive) |
                                         // Eviction seen before
                                         // CleanUnique completed
                                         (slot_ev_hz_seen &
                                          (slot_state_cachereadm0 |
                                           slot_state_cacheecc |
                                           slot_state_cleanunique_req |
                                           (slot_state_cleanunique_ack & ~biu_stb_ar_ack_i)));

  assign next_slot_has_cleanunique_duty = slot_has_cleanunique_duty_set |
                                          (slot_has_cleanunique_duty &
                                           ~slot_has_cleanunique_duty_clr);

  always @(posedge clk)
  if (slot_state_en) begin
    slot_has_cleanunique_duty <= next_slot_has_cleanunique_duty;
  end


  //----------------------------------------------------------------------------
  // Track way information
  //----------------------------------------------------------------------------

  // A slot can receive way information directly from the DCU following a cache
  // hit or directly from the BIU following a linefill allocation. If a slot
  // skips the lookup or linefill request states based on information in another
  // slot then it must retrieve way information from the other slot.

  // Another slot is known to have hit in the cache if it's performing a
  // CleanUnique or doing a cache read or write.
  assign slots_hit = slots_state_cleanunique_req |
                     slots_state_cleanunique_ack |
                     slots_state_cleanunique_resp |
                     slots_state_tagwrite |
                     slots_state_cachemerge |
                     slots_state_cachereadm0 |
                     slots_state_cachereadm1 |
                     slots_state_cachereadm2 |
                     slots_state_cacheecc |
                     slots_state_cachewritereq |
                     slots_state_cachewritem1;

  // Calculate which other slots hit in the cache and are in the sameline as
  // this new request.
  assign slots_sameline_hit = slots_hit & early_slot_sameline;


  // The way to record if this slot is in m2. This is the way that hit, unless
  // no way hit in which case the victim way chosen by the DCU is used, so that
  // it can be passed to the BIU later if a linefill is requested.
  // The result is encoded into 2 bits to save area.
  assign tag_way_m2 = (|dcu_stb_tag_hit_m2_i ? {|dcu_stb_tag_hit_m2_i[3:2],
                                                dcu_stb_tag_hit_m2_i[3] | dcu_stb_tag_hit_m2_i[1]} :
                       {|dcu_stb_victim_way_m2_i[3:2],
                        dcu_stb_victim_way_m2_i[3] | dcu_stb_victim_way_m2_i[1]});

  // If moving from idle then pick the way from one of the other slots in the
  // same line. If moving to a hit state, then it must pick the way from another
  // slot that hit (it doesn't matter which other slot if there are several that
  // hit, as they must all have hit in the same way). If there's a linefill in
  // progress then take the way information from the linefill. If moving to a
  // miss state then the way is just a hint and so can be picked from any slot
  // that is in the sameline.
  assign next_slot_way = ((slot_state_lookupm2 |
                           (|(slots_state_lookupm2 & early_slot_sameline))) ? tag_way_m2 :
                          slots_sameline_hit[0] ? slota_way_i :
                          slots_sameline_hit[1] ? slotb_way_i :
                          slots_sameline_hit[2] ? slotc_way_i :
                          slots_sameline_hit[3] ? slotd_way_i :
                          slot_state_lfreq       ? slot_biu_lf_hazard_way_i :
                          early_slot_sameline[0] ? slota_way_i :
                          early_slot_sameline[1] ? slotb_way_i :
                          early_slot_sameline[2] ? slotc_way_i :
                          early_slot_sameline[3] ? slotd_way_i :
                          2'b00);

  assign slot_way_en = real_new_req_from_idle |
                       slot_state_lookupreq |
                       slot_state_lookupm2 |
                       (slot_state_lfreq & slot_biu_lf_hazard_i);

  always @(posedge clk)
  if (slot_way_en) begin
    slot_way <= next_slot_way;
  end

  // Determine whether the way information is valid in the LFREQ state (it
  // won't be until the cycle after a linefill hazard is seen). This is needed
  // for qualifying biu_ev_hazard.
  assign next_slot_way_valid_lfreq = slot_state_lfreq & slot_biu_lf_hazard_i;

  always @(posedge clk)
  if (slot_state_en) begin
    slot_way_valid_lfreq <= next_slot_way_valid_lfreq;
  end

  // Expand the way to onehot for use elsewhere.
  assign slot_way_onehot = {slot_way == 2'b11,
                            slot_way == 2'b10,
                            slot_way == 2'b01,
                            slot_way == 2'b00};

  // Tell the SCU which way hit for CleanUnique requests.
  assign slot_ar_way_o = slot_way;


  //----------------------------------------------------------------------------
  // Track migratory information
  //----------------------------------------------------------------------------

  // The STB records migratory information on tag lookups and sends the
  // information back to the DCU when writing data. If there is a linefill
  // hazard, the STB will retrieve migratory information from the BIU.
  
  assign next_slot_migratory = // If the slot or a sameline slot is in lookupm2,
                               // record migratory information from the DCU.
                               (slot_state_lookupm2 |
                                (|(slots_state_lookupm2 &
                                   early_slot_sameline))) ?
                               dcu_stb_tag_migratory_m2_i :
                               // Otherwise, if a sameline slot hit in the
                               // cache then copy migratory information from
                               // that slot.
                               slots_sameline_hit[0] ? slota_migratory_i :
                               slots_sameline_hit[1] ? slotb_migratory_i :
                               slots_sameline_hit[2] ? slotc_migratory_i :
                               slots_sameline_hit[3] ? slotd_migratory_i :
                               // Otherwise, if the slot sees a linefill
                               // hazard then take migratory information
                               // from the BIU.
                               slot_biu_lf_hazard_migratory_i;

  assign slot_migratory_en = real_new_req_from_idle |
                             slot_state_lookupreq |
                             slot_state_lookupm2 |
                             (slot_state_lfreq & slot_biu_lf_hazard_i);

  always @(posedge clk)
  if (slot_migratory_en) begin
    slot_migratory <= next_slot_migratory;
  end

  assign slot_migratory_o = slot_migratory;


  //----------------------------------------------------------------------------
  // Track which slots are in the same burst
  //----------------------------------------------------------------------------

  // Another slot is becoming valid that will be in the same line as this slot
  assign new_other_slots_sameline = (slots_new_req_dc3 &
                                     {4{slot_dcu_store_sameline_dc3_i}});

  // Record which slots the DCU reports as being in the same line as this slot,
  // provided they are still mergeable. Clear the sameline bit when the
  // corresponding slot becomes idle.
  assign next_slot_sameline = ((slots_valid & ~slots_emptying &
                                (new_req_from_idle ? slots_dcu_store_sameline_dc3 :
                                                     slot_sameline)) |
                               new_other_slots_sameline);

  always @(posedge clk)
  if (slot_state_en) begin
    slot_sameline <= next_slot_sameline;
  end

  // For device bursts, record whether more beats are expected.
  assign next_slot_more_dev_expected = (new_req_from_idle | slot_more_dev_expected) &
                                       next_dev_bursting_i &
                                       ~slot_emptying;

  always @(posedge clk)
  if (slot_state_en) begin
    slot_more_dev_expected <= next_slot_more_dev_expected;
  end

  // Record whether the slot needs to delay making an AR request for a device
  // burst.
  assign wait_for_second_dev_beat = slot_more_dev_expected & dev_delay_ar_req_i;

  // Another slot is becoming valid and is part of the same device write as this slot.
  assign new_other_slots_same_dev_write = slots_new_req_dc3 &
                                          {4{slot_more_dev_expected}};

  // Record which slots are part of the same device write.
  assign next_slot_same_dev_write = (slots_valid & ~slots_emptying &
                                    (new_req_from_idle ? slots_more_dev_expected :
                                                         slot_same_dev_write)) |
                                    new_other_slots_same_dev_write;

  always @(posedge clk)
  if (slot_state_en) begin
    slot_same_dev_write <= next_slot_same_dev_write;
  end

  // This is effectively next_slot_same_dev_write, but without factoring new requests
  // that are going to other slots. These cannot affect the behaviour of this
  // slot on this cycle, so ignore them to help timing.
  assign early_slot_same_dev_write = slot_valid ? slot_same_dev_write :
                                                  (slots_valid & slots_more_dev_expected);


  //----------------------------------------------------------------------------
  // Barrier, mergeable, and earlier slot information
  //----------------------------------------------------------------------------

  // A slot is marked as barriered if it is or has had a barrier or any CP15 op
  // inserted after it, or if the DCU wants to force it to be non-mergeable
  // e.g. on an attribute mismatch.
  assign next_slot_barriered = (new_req_from_idle ?
                                (dcu_store_cp15_dc3_i | dcu_stlr_dc3_i) :
                                (slot_barriered | dcu_force_non_mergeable_dc3_i));

  always @(posedge clk)
  if (slot_state_en) begin
    slot_barriered <= next_slot_barriered;
  end

  // A slot is mergeable if it is a store to device GRE or normal memory, is not
  // exclusive, and hasn't had a barrier executed after it.
  assign slot_mergeable = `CA53_MEM_MERGEABLE(slot_attrs) &
                          ~slot_barriered &
                          ~slot_exclusive;

  // Any other slot that is non-mergeable (either because it is a CP op or
  // barrier, or has been forced to be non-mergeable by a barrier or for
  // other reasons), must complete before this one can. If this slot is for
  // non-gathering device memory then any other slot for device memory must
  // complete before this one.
  // If everything is being forced non-mergeable this cycle (e.g. due to an
  // attribute mismatch) then all existing slots must complete earlier than
  // this one.
  assign new_slot_real_earlier = slots_valid & ~slots_emptying &
                                 ({4{dcu_force_non_mergeable_dc3_i}} |
                                  slots_barriered |
                                  ({4{~`CA53_MEM_MERGEABLE(dcu_stb_attrs_dc3_i)}} & ~slots_mergeable));

  assign next_slot_real_earlier = new_req_from_idle ? new_slot_real_earlier : (slots_valid & ~slots_emptying &
                                                                               slot_real_earlier & {4{~slot_emptying}});

  always @(posedge clk)
  if (slot_state_en) begin
    slot_real_earlier <= next_slot_real_earlier;
  end

  assign new_slot_earlier = slots_valid & ~slots_emptying;

  // Clear an earlier bit when the slot it refers to goes to idle
  assign next_slot_earlier = new_req_from_idle ? new_slot_earlier : (slots_valid & ~slots_emptying &
                                                                     slot_earlier & {4{~slot_emptying}});

  always @(posedge clk)
  if (slot_state_en) begin
    slot_earlier <= next_slot_earlier;
  end

  // Determine which earlier slots are requesting a linefill. This is used to
  // tell the BIU which linefill request to priorize.

  assign slot_earlier_lf_o = slot_earlier & slots_lf_req;

  // The slot must not write any data if other slots are earlier than it.
  assign wait_for_earlier_slot = |slot_real_earlier;

  // Signal to the DCU if there is a DMB that affects loads, a store release
  // (which must be multi-copy atomic), or a DC maintenance operation ongoing.
  // Also block loads if a store is potentially unable to progress because the
  // due to loads (eg a load stream is keeping linefill buffers busy, or a line
  // is being repeatedly fetched in a shared state by loads and then evicted
  // before the store completes).
  assign slot_block_loads_dc1_o = // DMB that affects loads
                                  ((slot_state_barrier_req |
                                    slot_state_barrier_ack |
                                    (slot_state_barrier_resp & ~slot_ar_resp_valid_i)) &
                                   cp15_is_dmb_affecting_loads) |
                                  // Store part of STLR (barrier part covered by above)
                                  (slot_valid & slot_stlr) |
                                  // DC maintenance
                                  ((slot_state_cp15req |
                                    slot_state_cp15ack |
                                    (slot_state_cp15resp & ~slot_ar_resp_valid_i)) &
                                   cp15_is_dc_maint) |
                                  // Loads potententially preventing store completion
                                  (slot_valid & (&slot_drain_count_1023_seen));


  //----------------------------------------------------------------------------
  // BIU write control: Beat tracking
  //----------------------------------------------------------------------------

  // Keep track of the number of slots in the same line (Normal or GRE memory)
  // that have sent data to the BIU. The STB delays sending the last beat unless
  // it's the fourth beat in a burst (if it's the fourth beat then it's probably
  // the last beat in a cacheline burst). This gives subsequent store data a
  // better chance to merging into an ongoing burst. After four beats have been
  // counted, the counter increments every 128 cycles and eventually requests
  // that the DCU makes slots non-mergeable. This ensures a burst completes
  // eventually even if it's being continually merged into.
  assign slot_sameline_write_accept = |(slot_sameline & slots_write_accept);

  assign slot_sameline_beat_count_incr = // Increment on write accept if beat
                                         // count less than 4
                                         (slot_sameline_write_accept &
                                          ~slot_sameline_beat_count[2]) |
                                         // Otherwise increment on drain
                                         // indicator but saturate at 7.
                                         (stb_cycle_count_127_i &
                                          slot_sameline_beat_count[2] &
                                          ~&slot_sameline_beat_count[1:0]);

  assign early_sameline_write_accept = |(early_slot_sameline & slots_write_accept);

  assign early_sameline_beat_count_incr = // Increment on write accept if beat
                                          // count less than 4
                                          (early_sameline_write_accept &
                                           ~early_sameline_beat_count[2]) |
                                          // Otherwise increment on drain
                                          // indicator but saturate at 7.
                                          (stb_cycle_count_127_i &
                                           early_sameline_beat_count[2] &
                                           ~&early_sameline_beat_count[1:0]);

  assign early_sameline_beat_count = early_slot_sameline[0] ? slota_sameline_beat_count_i :
                                     early_slot_sameline[1] ? slotb_sameline_beat_count_i :
                                     early_slot_sameline[2] ? slotc_sameline_beat_count_i :
                                     early_slot_sameline[3] ? slotd_sameline_beat_count_i :
                                     3'b000;

  assign early_sameline_beat_count_plus_one = early_sameline_beat_count + 3'b001;

  assign next_slot_sameline_beat_count = new_req_from_idle ?
                                         // New slot activation
                                         (early_sameline_beat_count_incr ?
                                          early_sameline_beat_count_plus_one :
                                          early_sameline_beat_count) :
                                         // Slot already valid
                                         (slot_sameline_beat_count_incr ?
                                          slot_sameline_beat_count_plus_one :
                                          slot_sameline_beat_count);

  always @(posedge clk)
  if (slot_state_en) begin
    slot_sameline_beat_count <= next_slot_sameline_beat_count;
  end

  assign slot_sameline_beat_count_plus_one = slot_sameline_beat_count + 3'b001;


  //----------------------------------------------------------------------------
  // BIU write control: Speculative waiting for more beats
  //----------------------------------------------------------------------------

  // Determine whether the slot should delay sending write data until another
  // slot is activated with data for the same line or device burst. A slot
  // activating for a device burst must be able to retrieve l2db id information
  // from a previous slot. A slot holding Normal or Device GRE data can
  // speculatively wait for more data to optimise the burst.
  assign next_slot_wait_for_beat = new_req_from_idle ?
                                   // Slot activating
                                   ~dcu_stb_exclusive_dc3_i &
                                   ~dcu_store_cp15_dc3_i &
                                   ~dcu_stlr_dc3_i &
                                   (`CA53_MEM_MERGEABLE(dcu_stb_attrs_dc3_i) ?
                                    start_speculatively_waiting :
                                    next_slot_more_dev_expected) :
                                   // Slot valid
                                   (slot_wait_for_beat &
                                    (`CA53_MEM_MERGEABLE(slot_attrs) ?
                                     ~stop_speculatively_waiting :
                                     ~|new_other_slots_same_dev_write));
  
  // Coherent stores will speculatively wait in BIUDATA for more store data
  // up until the 4th beat (probably the last beat of a cacheline write).
  // Normal and Device GRE slots behave similarly, but the first beat does
  // not speculatively wait in BIUDATA. Instead it speculatlively waits in
  // BIUMERGE (before requesting an l2db id).
  assign start_speculatively_waiting = ~|early_slot_sameline ?
                                       // First beat
                                       `CA53_MEM_COHERENT(dcu_stb_attrs_dc3_i) :
                                       // Subsequent beat
                                       ((next_slot_sameline_beat_count < 3'b011) |
                                        ~&dcu_store_bls_dc3_i);

  assign stop_speculatively_waiting = // There will be no more sameline slots.
                                      next_slot_barriered |
                                      // A sameline slot is being accepted. It
                                      // will takeover the waiting.
                                      (|(new_other_slots_sameline & ~slots_valid)) |
                                      // This is the 4th (or later) beat and
                                      // it has a full 128 bits of data. It's
                                      // probably the last beat of a cacheline
                                      // write.
                                      ((slot_sameline_beat_count == 3'b010) &
                                       slot_sameline_write_accept &
                                       next_slot_full) |
                                      ((slot_sameline_beat_count >= 3'b011) &
                                       next_slot_full) |
                                      // A linefill has started and won't be
                                      // able to complete until the write to
                                      // the sameline has finished.
                                      slot_biu_lf_hazard_i |
                                      // All slots are full and not likely to
                                      // become available before this one so
                                      // no point waiting for a sameline store
                                      // to be accepted.
                                      (&slots_valid & ~|slot_earlier) |
                                      // Another unit is requesting the slot be
                                      // drained.
                                      slot_force_drain_biudata_i |
                                      // None of the above have taken effect
                                      // and we've waited long enough.
                                      slot_merge_timeout;
  
  always @(posedge clk)
  if (slot_state_en) begin
    slot_wait_for_beat <= next_slot_wait_for_beat;
  end

  //----------------------------------------------------------------------------
  // BIU write control: Requests
  //----------------------------------------------------------------------------

  // This slot wants to send data to the BIU.
  assign slot_wants_write_data_priority = slot_state_dvmdata |
                                          (slot_state_biudata & ~slot_wait_for_beat);

  assign slot_has_write_data_priority = slot_wants_write_data_priority &
                                        ~|(slots_want_write_data_priority & slot_earlier);

  assign slot_write_data_suppress = slot_mergeable & slot_store_merge_dc3_i;

  assign slot_write_accept = slot_has_write_data_priority &
                             ~slot_write_data_suppress &
                             biu_stb_write_accept_i;

  // Tell the BIU if we might be making a request in the following cycle. This
  // can be used to gate the clock for the write buffer. Transitions to BIUDATA
  // using skip_to_biudata are ignored as another slot will be asserting the
  // active signal in this case.
  assign slot_biu_write_req_active_o = slot_state_biuresp |
                                       slot_state_biudata |
                                       slot_state_syncresp1 |
                                       (slot_state_cp15resp & ~cp15_is_dc_maint) |
                                       slot_state_dvmdata;


  //----------------------------------------------------------------------------
  // Merge timeout
  //----------------------------------------------------------------------------

  // Record when the cycle counter reaches 1023 whilst still in the BIUMERGE
  // state. A drain is forced if we then see the counter reach 1023 again whilst
  // still in said state. This means that unless forced to drain for other
  // reasons, the slot will wait in BIUMERGE for no longer than 2048 cycles.
  //
  // The flag is also used in the BIUDATA state to end speculative waiting for
  // more beats in the same line. Additionally, if the cycle counter reaches
  // 1023 twice while in BIUDATA, and the slot is not speculatively waiting,
  // then STB tells the DCU to force slots to become non-mergeable. This guards
  // against a continual stream of stores preventing progress. The cycle count
  // is only observed in BIUDATA if there are no earlier slots in BIUDATA, as
  // this slot might simply be waiting for multiple earlier slots to get
  // priority over eviction data. The slot cannot simply wait for all earlier
  // slots because an earlier slot might be waiting for an l2db id that cannot
  // be allocated until this slot sends its data.
  //
  // Similarly, if a slot is in CACHEWRITEREQ and is not waiting for a preceding
  // store or linefill to complete, then the STB tells the DCU to force slots
  // to become non-mergeable. This addresses the architectural requirement that
  // the store becomes visible within its shareablility domain within a finite
  // time.
  assign slot_biu_write_stalled = slot_state_biudata &
                                  slot_mergeable &
                                  ~|(slots_state_biudata & slot_earlier);

  assign slot_cache_write_stalled = slot_state_cachewritereq &
                                    ~|slot_earlier &
                                    ~slot_lf_hz_seen;

  // Update merge count. Note: This refers to the number of cycles waiting
  // spent waiting for a merge, not the number of merges.
  assign next_slot_merge_count_1023_seen = // Potential stall states
                                           (slot_state_biumerge |
                                            slot_biu_write_stalled |
                                            slot_cache_write_stalled) &
                                           // Timer
                                           (slot_merge_count_1023_seen |
                                            stb_cycle_count_1023_i);
  
  always @(posedge clk)
  if (slot_state_en) begin
    slot_merge_count_1023_seen <= next_slot_merge_count_1023_seen;
  end

  assign slot_merge_timeout = slot_merge_count_1023_seen & stb_cycle_count_1023_i;

  assign slot_force_non_mergeable_o = slot_valid &
                                      ~slot_barriered &
                                      (// No end in sight for this burst
                                       &slot_sameline_beat_count |
                                       // No drain in sight for this slot
                                       ((slot_cache_write_stalled |
                                         (slot_biu_write_stalled &
                                          ~slot_wait_for_beat)) &
                                        slot_merge_timeout));

  
  //----------------------------------------------------------------------------
  // Drain timeout
  //----------------------------------------------------------------------------

  // Keep track of how many times the cycle counter reaches 1023. On the third
  // occurance, slot_block_loads_dc1 is asserted until the store completes.
  // This ensures that the store makes progress eventually even when followed
  // by a load stream (which might consume all the linefill buffers or hazard
  // with the store).
  //
  // For example, one CPU with a store in the STB and a regular load to the same
  // line might continually allocate the line in a shared state while another
  // CPU repeatedly stores to the same line, causing it to be invalidated in
  // the first CPU before the store in the first CPU completes. Blocking loads
  // ensures that the STB eventually starts a ReadUnique linefill and merges
  // into the line.
  //
  // The counter is reset when in the CACHEMERGE state, as the slot will not
  // exit this state unless it needs to (there is no timeout) and we must not
  // block the load-store pipe indefinitely. The exception is when the line
  // has potentially been evicted one or more times already (slot_ccb_hz_seen
  // is set) as the slot will leave CACHEMERGE immediately, and clearing the
  // counter would prevent detection of the above scenario.   
  assign slot_drain_count_1023_seen_clr = ~slot_valid |
                                          (slot_state_cachemerge & ~slot_ccb_hz_seen);
  
  assign slot_drain_count_1023_seen_incr = ~&slot_drain_count_1023_seen &
                                           ~wait_for_earlier_slot &
                                           stb_cycle_count_1023_i;

  assign slot_drain_count_1023_seen_plus_one = slot_drain_count_1023_seen + 2'b01;
  
  assign next_slot_drain_count_1023_seen = slot_drain_count_1023_seen_clr  ? 2'b00 :
                                           slot_drain_count_1023_seen_incr ?
                                           slot_drain_count_1023_seen_plus_one :
                                           slot_drain_count_1023_seen;

  always @(posedge clk)
  if (slot_state_en) begin
    slot_drain_count_1023_seen <= next_slot_drain_count_1023_seen;
  end
  
  
  //----------------------------------------------------------------------------
  // Slot storage
  //----------------------------------------------------------------------------

  // Always 128-bit align the address for normal memory, so that it does not
  // need changing when new data is merged in
  assign next_slot_addr = {dcu_pa_dc3_i[39:4],
                           (`CA53_MEM_NORMAL(dcu_stb_attrs_dc3_i) &
                            ~(dcu_stb_exclusive_dc3_i & ~`CA53_MEM_COHERENT(dcu_stb_attrs_dc3_i)) &
                            ~dcu_store_cp15_dc3_i) ? 4'b0000 : dcu_pa_dc3_i[3:0]};

  // Last information is recorded for non-mergeable memory. For mergeable
  // memory, it is calculated from sameline slot information when sending
  // data to the BIU.
  assign next_slot_last = dcu_store_last_dc3_i & ~`CA53_MEM_MERGEABLE(dcu_stb_attrs_dc3_i);

  // Determine whether a cache miss should result in a linefill. If there is a
  // slot in the sameline as this one then copy the information from that slot.
  // Otherwise, mark the slot as non-write-allocating if read allocate mode is
  // enabled at the time of slot activation, or if the attributes have the nWA
  // or transient hint set. Cacheable STLR always allocate on a miss to ensure
  // multi-copy atomicity.
  assign next_slot_no_alloc_on_miss = early_slot_sameline[3] ? slotd_no_alloc_on_miss_i :
                                      early_slot_sameline[2] ? slotc_no_alloc_on_miss_i :
                                      early_slot_sameline[1] ? slotb_no_alloc_on_miss_i :
                                      early_slot_sameline[0] ? slota_no_alloc_on_miss_i :
                                      (~dcu_stb_exclusive_dc3_i &
                                       ~dcu_stlr_dc3_i &
                                       (biu_read_alloc_mode_i |
                                        ~`CA53_MEM_WBWA(dcu_stb_attrs_dc3_i) |
                                        `CA53_MEM_TRANSIENT(dcu_stb_attrs_dc3_i)));

  // Attributes that remain constant while the slot is in use.
  always @(posedge slot_clk)
  if (real_new_req_from_idle) begin
    slot_attrs <= dcu_stb_attrs_dc3_i;
    slot_last <= next_slot_last;
    slot_stlr <= dcu_stlr_dc3_i;
    slot_exclusive <= dcu_stb_exclusive_dc3_i;
    slot_cp15 <= dcu_store_cp15_dc3_i;
    slot_priv <= dcu_priv_dc3_i;
    slot_ns <= dcu_ns_dsc_dc3_i;
    slot_addr <= next_slot_addr;
    slot_no_alloc_on_miss <= next_slot_no_alloc_on_miss;
  end

  // The slot is being used for a DSB operation.
  assign slot_dsb_o = slot_valid & slot_cp15 & `CA53_CPOP_8_IS_DSB(cp15_type);

  // Decode attributes.
  assign slot_coherent = `CA53_MEM_COHERENT(slot_attrs);

  // Data gets updated on a bytewise basis when new data is merged in.
  assign slot_data_en_store = {16{slot_real_new_req_dc3}} & dcu_store_bls_dc3_i;

  // Enable lower 8 bytes for CP15 ops (assumes aarch64).
  assign slot_data_en_cp15 = {16{slot_real_new_req_dc3}} & {8'h00, {8{dcu_store_cp15_dc3_i}}};

  generate if (CPU_CACHE_PROTECTION) begin : gen_cpu_cache_protection_01

    wire [15:0] slot_data_en_dpu;

    // Data gets updated on a 32-bit basis for cache reads.
    assign slot_data_en_cache_read = ~slot_bls &
                                     // All non-valid bytes are updated if a CleanUnique is required.
                                     ({16{slot_state_cachereadm2 & slot_has_cleanunique_duty}} |
                                      // Otherwise only non-valid bytes within the 32-bit chunks
                                      // being written to are updated.
                                      {{4{slot_state_cachereadm2 & dcu_stb_read_wls_m2_i[3]}},
                                       {4{slot_state_cachereadm2 & dcu_stb_read_wls_m2_i[2]}},
                                       {4{slot_state_cachereadm2 & dcu_stb_read_wls_m2_i[1]}},
                                       {4{slot_state_cachereadm2 & dcu_stb_read_wls_m2_i[0]}}});

    // Mux store/CP15 data from the DPU with read data from the cache, giving store data priority.
    assign slot_data_en_dpu = slot_data_en_store | slot_data_en_cp15;

    assign next_slot_data = ( `CA53_STB_BYTE_TO_BIT_STROBES(slot_data_en_dpu) & dpu_st_data_wr_i) |
                            (~`CA53_STB_BYTE_TO_BIT_STROBES(slot_data_en_dpu) & dcu_stb_read_data_m2_i);

    assign slot_data_en = (slot_real_new_req_dc3 & dcu_store_cp15_dc3_i) ?
                          16'h00FF :  
                          (slot_data_en_store | slot_data_en_cache_read);

  end else begin : gen_cpu_cache_protection_01_else

    assign slot_data_en_cache_read = 16'h0000;
    assign next_slot_data = dpu_st_data_wr_i;
    assign slot_data_en = (slot_real_new_req_dc3 & dcu_store_cp15_dc3_i) ?
                          16'h00FF :  
                          slot_data_en_store;

  end endgenerate

  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_slot_data
      always @(posedge slot_clk)
      if (slot_data_en[i]) begin
        slot_data[i*8+7:i*8] <= next_slot_data[i*8+7:i*8];
      end
    end
  endgenerate

  // The byte lane strobes get incrementally set each time new data is merged in.
  // The strobes are not updated when merging in cache read data because the line
  // might be evicted before the store is written to the cache and the the slot
  // will need to redo the cache read after performing a linefill. For CP15 ops,
  // operation type and VMID information is encoded in slot_data_en_store.
  assign next_slot_bls = ({16{slot_valid}} & slot_bls) | slot_data_en_store;

  assign slot_bls_en = slot_real_new_req_dc3;

  always @(posedge slot_clk)
  if (slot_bls_en) begin
    slot_bls <= next_slot_bls;
  end

  // The slot is full if all 16 bytes have valid data.
  assign slot_full = &slot_bls;

  assign next_slot_full = &(slot_data_en_store | slot_bls);

  generate if (CPU_CACHE_PROTECTION) begin : gen_cpu_cache_protection_02

    // Keep track of each 32-bit chunk that contains valid data. Valid data can
    // be from store merges or from cache reads. If the slot has to redo its
    // tag lookup following an eviction hazard then the valid chunks are reset
    // to those containing 32 bits of store data.
    assign next_slot_32bit_chunks = ({4{slot_valid & ~slot_state_lookupreq}} & slot_32bit_chunks) |
                                    {&next_slot_bls[15:12] | (slot_state_cachereadm2 & dcu_stb_read_wls_m2_i[3]),
                                     &next_slot_bls[11:8]  | (slot_state_cachereadm2 & dcu_stb_read_wls_m2_i[2]),
                                     &next_slot_bls[7:4]   | (slot_state_cachereadm2 & dcu_stb_read_wls_m2_i[1]),
                                     &next_slot_bls[3:0]   | (slot_state_cachereadm2 & dcu_stb_read_wls_m2_i[0])};

    always @(posedge clk)
    if (slot_state_en) begin
      slot_32bit_chunks <= next_slot_32bit_chunks;
    end

    // Determine which chunks contain partial data.
    assign slot_partial_chunks = {|slot_bls[15:12] & ~slot_32bit_chunks[3],
                                  |slot_bls[11:8]  & ~slot_32bit_chunks[2],
                                  |slot_bls[7:4]   & ~slot_32bit_chunks[1],
                                  |slot_bls[3:0]   & ~slot_32bit_chunks[0]};

    // The slot needs read data if it does not contain data in 32-bit chunks.
    assign part_cache_read_required = |slot_partial_chunks;

    // If the slot has CleanUnique duty then it must do a full cache read
    // so that there is no risk of store data merging into a previously
    // empty 32-bit chunk during the CleanUnique and triggering a second
    // read. This is avoided because the subsequent read might see an ECC
    // error and cause the line to be evicted before the dirty information
    // is updated for the CleanUnique.
    assign full_cache_read_required = slot_has_cleanunique_duty &
                                      ~&slot_32bit_chunks;

  end else begin : gen_cpu_cache_protection_02_else

    assign part_cache_read_required = 1'b0;
    assign full_cache_read_required = 1'b0;

  end endgenerate


  //----------------------------------------------------------------------------
  // DC2 hazard checking and forwarding
  //----------------------------------------------------------------------------

  // The DC2 request is in the same line as this slot.
  assign line_match_dc2 = {slot_valid, dcu_ns_dsc_dc2_i, dcu_pa_dc2_i[39:6]} == {1'b1, slot_ns, slot_addr[39:6]};

  // The DC2 request is in the same quadword as this slot.
  assign qword_match_dc2 = (dcu_pa_dc2_i[5:4] == slot_addr[5:4]);

  // The attributes of DC2 match this slot.
  assign attr_match_dc2 = (dcu_attrs_dc2_i[7:0] == slot_attrs);

  // Tell the DCU if the DC2 request is in the same line as this slot. This must
  // factor mergeable in because if the slot is not mergeable then either it is
  // not normal memory (and hence should ignore the sameline information) or
  // there was a barrier after this slot, and so should not be merged together in
  // the same burst.
  // If the attributes do not match then the DCU must force all slots to become
  // non-mergeable and therefore they will not end up marked as being in the
  // same line.
  assign slot_sameline_dc2_o = line_match_dc2 &
                               attr_match_dc2 &
                               slot_mergeable &
                               ~stb_force_non_mergeable_i;

  // Non-cacheable loads must detect hazards on any slot that matches the
  // address and ns bit.
  assign slot_load_sameline_dc2 = line_match_dc2 & ~slot_cp15;

  // Detect when the slot is being (or is about to be) sent to the BIU, cache
  // or LFB. Once this happens the data is either sent or it is too late to
  // change it.
  assign slot_write_committed = (slot_write_accept |
                                 slot_state_cachewritem1 |
                                 (slot_state_cachewritereq & slot_has_cache_data_priority_i & dcu_stb_data_has_priority_m0_i));

  // Tell the DCU if the DC2 request is in the same quadword as this slot,
  // and can be merged into the slot. If the slot has already started writing
  // its data then it cannot be merged into as the destination may not see the
  // new data.
  assign slot_can_merge_dc2_o = (line_match_dc2 &
                                 qword_match_dc2 &
                                 attr_match_dc2 &
                                 slot_mergeable &
                                 ~stb_force_non_mergeable_i &
                                 ~slot_write_committed);

  // Signal to the DCU if the slot is in the same line, but with different
  // attributes. The DCU will then force all slots to become non-mergeable
  // before the new store to ensure that it cannot merge.
  assign slot_attr_mismatch_dc2_o = line_match_dc2 & ~slot_barriered & ~attr_match_dc2;

  // Return which bytes in the DC2 request match data held by this slot.
  // Slots containing stores to memory that is neither normal nor device
  // GRE should not be forwarded as any load must read the data from external
  // memory. If the coherency mismatches then don't forward, for consistency
  // with the SCU hazarding which will not hazard between memory types.
  assign slot_hit_dc2_o = ({16{line_match_dc2}} &
                           {{8{dcu_pa_dc2_i[3]}}, {8{~dcu_pa_dc2_i[3]}}} &
                           ({16{qword_match_dc2 & ~slot_cp15 &
                               `CA53_MEM_MERGEABLE(slot_attrs) &
                               (`CA53_MEM_COHERENT(slot_attrs) == `CA53_MEM_COHERENT(dcu_attrs_dc2_i))}} &
                            slot_bls[15:0]));


  //----------------------------------------------------------------------------
  // Requests for arbitration
  //----------------------------------------------------------------------------

  // The slot asks for BIU priority if it is in the BIU request state. However
  // it must delay the request if:
  // - A new store is about to merge into this slot, so that the merge can happen
  //   before the data is sent to the BIU.
  // - An earlier slot that must be kept in order has not yet completed.
  // - There is a load in progress to the same address. The slot must be kept
  //   around so that the data can be forwarded to the load if needed.
  // - A linefill started to the same line. The slot must move to LFREQ and
  //   merge into the cache so that a subsequent load will receive the correct
  //   data. Note: The BIU is responsible for suppressing the AR request when
  //   there is a linefill hazard, but the STB suppresses the request on
  //   slot_lf_hz_seen because slot_wants_write_addr_priority factors into
  //   slot_has_ar_priority, which factors into whether a newly activating slot
  //   skips to BIUREQ. A new slot must not skip to BIUREQ if this slot is
  //   moving to LFREQ.

  // BIU write address request.
  assign slot_wants_write_addr_priority = slot_state_biureq &
                                          ~wait_for_second_dev_beat &
                                          ~wait_for_earlier_slot &
                                          ~slot_load_sameline_seen &
                                          ~slot_lf_hz_seen;

  // We ignore the earlier bit for other slots that are in the cp15resp state,
  // because they cannot be overtaken once they have been arbitrated.
  assign slot_wants_cp15_priority = (slot_state_cp15req &
                                     ~|(slot_real_earlier & ~slots_state_cp15resp)) |
                                    (slot_state_syncreq & ~|slot_real_earlier);

  // The slot may request a CleanUnique. However it must only request
  // priority if it can guarantee that it will be ready to write the tag
  // and data once the response is received (as CCB requests will be blocked
  // while it is trying to write the tag and data).
  //
  // When CPU cache protection is present, only the slot with CleanUnique
  // responsibility can request the CleanUnique. Other slots wait in the
  // CleanUnique request state until the slot with CleanUnique duty has
  // completed its cache read (if needed), and then track that slot through
  // the CleanUnique states.
  //
  // Exclusive CleanUniques must wait for exclusive linefills to complete.
  // If the STREX matches the LDREX address, this won't be an issue as the
  // slot will see the linefill hazard and move to LFREQ. However, a LDREX
  // can start a linefill and then be followed by a LDREX/STREX that hit in
  // the cache. The STREX must wait for the LDREX that started the linefill
  // to complete in this scenario even though it's to a different address.
  assign slot_wants_cleanunique_priority = slot_state_cleanunique_req &
                                           ~(slot_exclusive & ~dcu_exclusive_monitor_i) &
                                           ~wait_for_earlier_slot &
                                           ~slot_ev_hz_seen &
                                           ~biu_excl_lf_in_progress_i &
                                           slot_has_cleanunique_duty;

  // A locally modified linefill might not have been serialised yet. We must
  // not send the barrier until the write has been serialised.
  assign barrier_can_propagate = ~wait_for_earlier_slot &
                                 ~biu_dirty_lf_in_progress_i;

  assign slot_wants_barrier_priority = slot_state_barrier_req &
                                       barrier_can_propagate &
                                       propagate_barrier_i;

  // Signal when a slot is in BIUACK for a write or CP15ACK for a cache
  // maintenance operation. This is used to set the flag determining whether
  // a later barrier must propagate to the BIU.
  assign slot_write_sync_cmo_ack_o = slot_state_biuack |
                                     slot_state_syncack |
                                     (slot_state_cp15ack & cp15_is_dc_maint);

  // Collate AR requests.
  assign slot_wants_ar_priority = slot_wants_cleanunique_priority |
                                  slot_wants_barrier_priority |
                                  slot_wants_cp15_priority |
                                  slot_wants_write_addr_priority;

  assign slot_already_has_ar_priority = `CA53_SLOT_ALREADY_HAS_AR(slot_state);

  assign slot_might_want_ar_priority = ~slot_has_ar_priority_i &
                                       (// Might make CleanUnique request
                                        (slot_has_cleanunique_duty &
                                         (slot_state_cleanunique_req |
                                          slot_state_cacheecc |
                                          slot_state_cachereadm0)) |
                                        // Might make barrier request
                                        (slot_state_barrier_req |
                                         slot_state_syncresp2) |
                                        // Might make CP15 request
                                        slot_state_cp15req |
                                        // Might make BIU write request
                                        (slot_state_biureq |
                                         (slot_state_biumerge & (slot_force_drain_i | slot_merge_timeout))) |
                                        // Might make CleanUnique or BIU write request
                                        slot_state_lookupm2);

  // If a load is seen to the same line as a store that has not been serialized
  // then the AR request for the store is suppressed until the data can be
  // forwarded.
  assign slot_load_sameline = slot_valid &
                              `CA53_MEM_MERGEABLE(slot_attrs) &
                              ((slot_load_sameline_dc2 &
                                dcu_leaving_dc2_i & ~dcu_store_dc2_i &
                                (`CA53_MEM_COHERENT(slot_attrs) ==
                                 `CA53_MEM_COHERENT(dcu_attrs_dc2_i))) |
                               (slot_load_sameline_dc3_i &
                                (`CA53_MEM_COHERENT(slot_attrs) ==
                                 `CA53_MEM_COHERENT(dcu_stb_attrs_dc3_i))));

  assign next_slot_load_sameline_seen = slot_valid ?
                                        slot_load_sameline :
                                        |(early_slot_sameline & slots_load_sameline);

  always @(posedge clk)
  if (slot_state_en) begin
    slot_load_sameline_seen <= next_slot_load_sameline_seen;
  end

  assign slot_ar_suppress_o = (slot_state_biuack & (slot_lf_hz_seen | slot_load_sameline_seen)) |
                              (slot_state_cleanunique_ack & slot_ev_hz_seen);

  // Indicate the slot might want to make a request next cycle.
  assign slot_might_req_o = // Slot is already making a request and waiting for ack
                            (slot_already_has_ar_priority & ~biu_stb_ar_ack_i) |
                            // Slot is in a request state
                            (slot_state_cleanunique_req & slot_has_cleanunique_duty) |
                            (slot_state_barrier_req & (dpu_disable_dmb_i | propagate_barrier_i)) |
                            slot_state_cp15req |
                            slot_state_syncreq |
                            slot_state_biureq |
                            // Slot is moving from SYNCRESP2 to BARRIER_REQ
                            (slot_state_syncresp2 & dvm_complete_i) |
                            // Slot is potentially moving from BIUDATA to BARRIER_REQ
                            (slot_state_biudata & slot_stlr) |
                            // Slot is potentially moving from BIUMERGE to BIUREQ
                            (slot_state_biumerge & (slot_force_drain_i | slot_merge_timeout)) |
                            // Slot is potentially staying in LFREQ
                            (slot_state_lfreq & ~slot_lf_hz_seen) |
                            // Slot is potentially moving from CACHEREADM0/CACHEECC to CLEANUNIQUE_REQ
                            (slot_state_cachereadm0 & slot_has_cleanunique_duty & ~full_cache_read_required) |
                            (slot_state_cacheecc & slot_has_cleanunique_duty) |
                            // Slot is moving from IDLE
                            (new_req_from_idle & (// ... to SYNCREQ, BARRIER_REQ, or CP15REQ
                                                  dcu_store_cp15_dc3_i |
                                                  // ... to BIUREQ
                                                  (~`CA53_MEM_COHERENT(dcu_stb_attrs_dc3_i) &
                                                   (dcu_stlr_dc3_i |
                                                    dcu_stb_exclusive_dc3_i |
                                                    ~dcu_stb_mergeable_dc3_i))));

  assign slot_type_o = // DVM Sync
                       (slot_state_syncreq | slot_state_syncack) ? `CA53_CPOP_8_SYNC :
                       // CleanUnique
                       (slot_state_cleanunique_req | slot_state_cleanunique_ack) ? `CA53_CPOP_8_CLEANUNIQUE :
                       // Store to BIU
                       (slot_state_biureq | slot_state_biuack) ? `CA53_CPOP_8_WRITE :
                       // Implicit DSB following non-cacheable store release
                       (slot_stlr & ~slot_cp15) ? `CA53_CPOP_8_DSBSY :                                    
                       // DMB, DSB, or maintenance operation.
                       // This includes the DMB part of a store release. The DMB
                       // is inserted by the DPU before the store part and looks
                       // like any other DMB.
                       cp15_type;

  // Mark stores and CleanUniques that are part of a STREX, as exclusive on
  // the AR channel, but suppress the exclusivity for the implicit DSB that is
  // sent after a STLR.
  assign slot_ar_excl_o = slot_exclusive &
                          ~(slot_state_barrier_req | slot_state_barrier_ack);

  // Ask for a cache lookup whenever we don't know if the data is in the cache
  // or not. If there is a linefill hazard then we know the data cannot be in
  // the cache yet, so no need to lookup, but this is factored in later.
  // If the slot has seen an eviction hazard then wait for it to go away before
  // starting the lookup.
  assign slot_wants_lookup_priority_o = slot_state_lookupreq &
                                        ~slot_ev_hz_seen &
                                        ~(slot_lf_hz_seen & sync_slots);

  // The slot asks for cache data write priority if it is in the cache write
  // request state. However it must delay the request if:
  // - A new store is about to merge into this slot, so that the merge can
  //   happen before the data is sent to the cache.
  // - An earlier slot that must be kept in order has not yet completed.
  // - The exclusive monitor has been cleared since this slot entered the STB.
  //   If the slot has successfully completed a CleanUnique for the store then
  //   the clearing must be ignored and the write must proceed to ensure dirty
  //   information is not lost.
  // - The slot needs to do a cache read to complete a 32-bit chunk. This is
  //   ignored if an aborting linefill is in progress as the store must merge
  //   to prevent repeatedly requesting the same aborting linefill, and the
  //   merged data will be lost anyway.
  // - There is a eviction hazard, as the line we want to write to may not be
  //   in the cache anymore by the time we write to it. The hazard is ignored
  //   if this slot has to update the dirty RAM following a CleanUnique.
  //   This is OK because:
  //   a) The slot will block ccb evictions during this time.
  //   b) If an aborting linefill was serialized before the CleanUnique
  //      then the CleanUnique will have failed.
  //   c) If the CleanUnique was serialized before the aborting linefill
  //      then the line was valid in the cache and the linefill cannot
  //      start without there first being a CCB eviction hazard.
  // - There is a linefill hazard and the slot is not writing a full 128 bits
  //   of data. This is ignored if the linefill aborted as the store must merge
  //   to prevent repeatedly requesting the same aborting linefill, and the
  //   merged data will be lost anyway.
  assign slot_wants_cache_write_priority = slot_state_cachewritereq &
                                           // Check for incoming merges
                                           ~slot_store_merge_dc3_i &
                                           // Check for slots that must
                                           // complete before this one
                                           ~wait_for_earlier_slot &
                                           // Check exclusive monitor
                                           ~(slot_exclusive &
                                             ~dcu_exclusive_monitor_i &
                                             ~slot_has_cleanunique_duty) &
                                           // If merging into a linefill,
                                           // check merge permission
                                           (slot_lf_hz_seen ?
                                            slot_lf_can_merge :
                                            // If not merging into a linefill,
                                            // check eviction and RmW hazards
                                            (~part_cache_read_required &
                                             (~slot_ev_hz_seen | slot_has_cleanunique_duty)));

  // The slot asks for cache data read priority if it is in the cache read
  // m0 state. However it must suppress the request if:
  // - An earlier slot that must be kept in order has not yet completed.
  // - There is a linefill hazard indicating that the required read data
  //   might not be present in the cache.
  // - The slot now has all the data needed for the ECC calculation.
  assign slot_wants_cache_read_priority = slot_state_cachereadm0 &
                                          ~wait_for_earlier_slot &
                                          ~slot_lf_hz_seen &
                                          (part_cache_read_required |
                                           full_cache_read_required);

  assign slot_wants_cache_data_priority_o = slot_wants_cache_write_priority |
                                            slot_wants_cache_read_priority;

  // Determine whether the slot might want cache read or write priority next
  // cycle. This is factored into the slot selection for cache arbitration but
  // does not need to be accurate as the selected slot will be qualified with
  // the actual request signal next cycle.
  assign slot_might_want_cache_data_priority_o = // Slot in the cache read or write
                                                 // request state.
                                                 slot_state_cachewritereq |
                                                 slot_state_cachereadm0 |
                                                 // Slot transitioning due to a linefill
                                                 // having updated the tag.
                                                 (slot_state_lfreq &
                                                  slot_biu_lf_hazard_i &
                                                  ~slot_biu_lf_real_hazard_i) |
                                                 // Slot has finished waiting for merge.
                                                 (slot_state_cachemerge &
                                                  (slot_full | ~slot_mergeable | slot_stlr |
                                                   slot_force_drain_i | slot_ccb_hz_seen)) |
                                                 // Slot has finished a read and doesn't
                                                 // need to do a CleanUnique.
                                                 (slot_state_cacheecc &
                                                  ~slot_has_cleanunique_duty) |
                                                 // A CleanUnique has been completed for
                                                 // the line and the slot will make a
                                                 // cache read or write request as soon
                                                 // as the tag update is accepted.
                                                 slot_state_tagwrite;

  generate if (CPU_CACHE_PROTECTION) begin : gen_cpu_cache_protection_03

    // Cache byte strobes are set for each byte being read or written. A slot with
    // CleanUnique duty reads all words that it does not have all the bytes for. This
    // ensures a second read is not needed after the CleanUnique (an ECC error would
    // cause the CleanUnique to be abandonned and we could lose dirty information).
    // A slot without CleanUnique duty only reads the words it has some but not all
    // bytes for.
    assign slot_cache_bls = // Reads. The slot state is not factored in to improve
                            // timing. If no read is necessary these terms will
                            // reduce to 16'h0000.
                            ({16{slot_has_cleanunique_duty}} & {{4{~slot_32bit_chunks[3]}},
                                                                {4{~slot_32bit_chunks[2]}},
                                                                {4{~slot_32bit_chunks[1]}},
                                                                {4{~slot_32bit_chunks[0]}}}) |
                            (slot_state_cachewritereq ? // Writes
                                                        slot_bls :
                                                        // Non-CleanUnique duty reads
                                                        {{4{slot_partial_chunks[3]}},
                                                         {4{slot_partial_chunks[2]}},
                                                         {4{slot_partial_chunks[1]}},
                                                         {4{slot_partial_chunks[0]}}});

  end else begin : gen_cpu_cache_protection_03_else

    // Cache byte strobes are set for each byte being written.
    assign slot_cache_bls = slot_bls;

  end endgenerate

  // Request tag write priority after a CleanUnique has completed. The slot with
  // CleanUnique duty must ignore eviction hazards and proceed through the tag
  // and data write states to ensure that dirty information is not lost. It will
  // block evictions during this time.
  assign slot_wants_tagwrite_priority_o = slot_state_tagwrite;

 
  //----------------------------------------------------------------------------
  // Linefill requests and merging
  //----------------------------------------------------------------------------

  // The slot asks for a linefill if it is in the linefill request state.
  // However the linefill must not be started if:
  // - There has been a linefill hazard. We must not start a new linefill
  //   to the same address.
  // - There is currently a linefill hazard. The BIU is responsible for masking
  //   out the request if this condition is true.
  // - It is a store exclusive. If the line is not already in the cache or
  //   a linefill buffer then the exclusive must fail.
  // - The slot has earlier slots that will prevent a linefill merge and
  //   the slot has already seen an eviction hazard. This is to prevent
  //   a circular dependency where the slot needs the earlier slot to
  //   complete before it can merge and the earlier slot needs later slots
  //   to stop making linefill requests so its AR request can be arbitrated
  //   by the BIU (the linefills might continually see eviction hazards due
  //   to snoop requests).
  assign next_slot_lf_req_suppress = (slot_valid ? slot_exclusive : dcu_stb_exclusive_dc3_i) |
                                     (slot_valid & (slot_lf_req_suppress | slot_ev_hz_seen) & wait_for_earlier_slot);

  always @(posedge clk)
  if (slot_state_en) begin
    slot_lf_req_suppress <= next_slot_lf_req_suppress;
  end

  assign slot_lf_req_o = slot_state_lfreq &
                         ~slot_lf_hz_seen &
                         ~slot_lf_req_suppress;

  // Tell the BIU if we might be making a linefill request next cycle. This
  // This does not have to factor in transitions to LFREQ caused by a linefill
  // hazard because the linefill hazard indicates that the BIU is already
  // clocking the linefill buffers.
  assign slot_lf_active_o = slot_state_lfreq |
                            slot_state_lookupm2;

  // Tell the BIU that the slot wants to merge into a linefill. If it's not
  // too late, the BIU delays descriptor de-activation until the merge completes.
  // This serves the following functions:
  // - It gives the STB time to complete full cacheline merges and therefore
  //   facilitates entry into read allocate mode.
  // - If the linefill receives an abort, it ensures that the merge can proceed.
  //   If the merge could not proceed then the slot would continually miss in
  //   the cache and restart the aborting linefill with no imprecise abort
  //   being raised.
  //
  // The signal is only asserted if the merge can take place without first
  // performing a cache read. This means the slot must have 128 bits of valid
  // data, or the data does not matter because an external abort will cause
  // the line to be invalidated and raise an imprecise abort. Since the BIU
  // can delay decriptor activation based on this signal, the signal is
  // only asserted if the merge is not dependent on the completion of any
  // other slot.
  assign slot_lf_merge = ~wait_for_earlier_slot &
                         // Slot full. This looks at CACHEMERGE because the slot might
                         // have skipped there even though there is a linefill hazard.
                         // If the slot is full, it will transition to CACHEWRITEREQ so
                         // slot_lf_merge is asserted to facilitate entry into read
                         // allocate mode.
                         ((slot_full & ((slot_state_lfreq & slot_way_valid_lfreq) |
                                        slot_state_cachemerge |
                                        slot_state_cachewritereq |
                                        slot_state_cachewritem1)) |
                         // Aborting linefill. This does not include the CACHEMERGE
                         // state because the slot is not guaranteed to be able to
                         // transition directly to CACHEWRITEREQ unless the slot is
                         // full. This is OK since a slot only needs to merge into an
                         // aborting linefill if it started the linefill.
                          (slot_biu_ev_hazard_i & ((slot_state_lfreq & slot_way_valid_lfreq) |
                                                   slot_state_cachewritereq |
                                                   slot_state_cachewritem1)));

  // Record when a linefill merge request has granted permission by the BIU.
  // The BIU will delay invalidating the line on an external abort, or
  // otherwise de-activating the linefill descriptor until the merge completes.
  assign next_slot_lf_can_merge = slot_lf_merge &
                                  slot_biu_lf_can_merge_i;

  always @(posedge clk)
  if (slot_state_en) begin
    slot_lf_can_merge <= next_slot_lf_can_merge;
  end

  // The slot will not be able to merge into a linefill while the linefill is in
  // progress if the slot does not contain 128 bits of data. However, the line
  // might be continually evicted from this CPU after the linefill completes
  // and before the store data is written (ie two CPUs issuing ReadUniques for
  // the same line where each needs to do a read-modify-write between the
  // linefill finishing and the store completing). To avoid this, a flag is set
  // to allow hazarding CCB requests to be blocked until after the store
  // completes, but only when the line is known to be unique and the linefill
  // has been serialized. If the line is not unique then blocking a hazarding
  // CCB request would prevent a CleanUnique serialized after the CCB request
  // from making forward progress. If the linefill has not been serialized then
  // blocking a hazarding CCB request would prevent the linefill from being
  // serialized. Normally there will be no hazarding CCB requests before the
  // linefill is serialized, but it is possible on an ECC error.

  assign next_slot_post_lf_merge = // Set on unique, serialized linefill if
                                   // slot is guaranteed to be able to progress
                                   // after the linefill completes. Only set
                                   // when in or moving to CACHEWRITEREQ
                                   // (the line will be confirmed unique on
                                   // the transition but the linefill might not
                                   // be serialized until after the slot moves
                                   // there).
                                   (slot_post_lf_merge |
                                    ((slot_state_cachewritereq |
                                      (slot_state_lfreq & slot_way_valid_lfreq)) &
                                     slot_biu_lf_hazard_i &
                                     slot_biu_lf_serialized_i &
                                     ~slot_biu_lf_real_hazard_i &
                                     ~wait_for_earlier_slot)) &
                                   // Clear on eviction hazards (linefill
                                   // receiving external abort or ECC error
                                   // during read-modify-write).
                                   ~(slot_ev_hz_seen | slot_emptying);

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    slot_post_lf_merge <= 1'b0;
  end else if (slot_state_en) begin
    slot_post_lf_merge <= next_slot_post_lf_merge;
  end

  
  //----------------------------------------------------------------------------
  // Exclusive signalling to the DCU
  //----------------------------------------------------------------------------

  // Signal to the DCU when a coherent STREX has been completed.
  assign slot_excl_done = slot_exclusive & `CA53_MEM_COHERENT(slot_attrs) & slot_emptying;

  // Signal to the DCU when a cacheable STREX has been abandoned because it failed.
  assign slot_excl_fail = slot_excl_done & ~slot_state_cachewritem1;


  //----------------------------------------------------------------------------
  // Assign to output variables
  //----------------------------------------------------------------------------

  assign slot_valid_o = slot_valid;
  assign slot_emptying_o = slot_emptying;
  assign slot_state_biumerge_o = slot_state_biumerge;
  assign slot_state_biureq_o = slot_state_biureq;
  assign slot_state_biuack_o = slot_state_biuack;
  assign slot_state_biuresp_o = slot_state_biuresp;
  assign slot_state_biudata_o = slot_state_biudata;
  assign slot_state_lfreq_o = slot_state_lfreq;
  assign slot_state_lookupreq_o = slot_state_lookupreq;
  assign slot_state_lookupm1_o = slot_state_lookupm1;
  assign slot_state_lookupm2_o = slot_state_lookupm2;
  assign slot_state_special_o = slot_state_special;
  assign slot_state_tagwrite_o = slot_state_tagwrite;
  assign slot_state_cachemerge_o = slot_state_cachemerge;
  assign slot_state_cachereadm0_o = slot_state_cachereadm0;
  assign slot_state_cachereadm1_o = slot_state_cachereadm1;
  assign slot_state_cachereadm2_o = slot_state_cachereadm2;
  assign slot_state_cacheecc_o = slot_state_cacheecc;
  assign slot_state_cachewritereq_o = slot_state_cachewritereq;
  assign slot_state_cachewritem1_o = slot_state_cachewritem1;
  assign slot_state_cp15resp_o = slot_state_cp15resp;
  assign slot_state_cleanunique_req_o = slot_state_cleanunique_req;
  assign slot_state_cleanunique_ack_o = slot_state_cleanunique_ack;
  assign slot_state_cleanunique_resp_o = slot_state_cleanunique_resp;
  assign slot_state_barrier_ack_o = slot_state_barrier_ack;
  assign slot_attrs_o = slot_attrs;
  assign slot_addr_o = slot_addr;
  assign slot_ns_o = slot_ns;
  assign slot_data_o = slot_data;
  assign slot_cache_bls_o = slot_cache_bls;
  assign slot_mergeable_o = slot_mergeable;
  assign slot_barriered_o = slot_barriered;
  assign slot_load_sameline_dc2_o = slot_load_sameline_dc2;
  assign slot_earlier_o = slot_earlier;
  assign slot_cp15_o = slot_cp15;
  assign slot_way_onehot_o = slot_way_onehot;
  assign slot_way_o = slot_way;
  assign slot_excl_done_o = slot_excl_done;
  assign slot_excl_fail_o = slot_excl_fail;
  assign slot_ev_hazard_o = slot_ev_hazard;
  assign slot_ev_hz_seen_o = slot_ev_hz_seen;
  assign slot_wants_ar_priority_o = slot_wants_ar_priority;
  assign slot_might_want_ar_priority_o = slot_might_want_ar_priority;
  assign slot_already_has_ar_priority_o = slot_already_has_ar_priority;
  assign slot_wants_write_data_priority_o = slot_wants_write_data_priority;
  assign slot_has_write_data_priority_o = slot_has_write_data_priority;
  assign slot_write_data_suppress_o = slot_write_data_suppress;
  assign slot_write_accept_o = slot_write_accept;
  assign slot_wants_write_addr_priority_o = slot_wants_write_addr_priority;
  assign slot_wants_cleanunique_priority_o = slot_wants_cleanunique_priority;
  assign slot_lf_hz_seen_o = slot_lf_hz_seen;
  assign slot_lf_hz_capture_o = slot_lf_hz_capture;
  assign slot_lf_merge_o = slot_lf_merge;
  assign slot_coherent_o = slot_coherent;
  assign slot_more_dev_expected_o = slot_more_dev_expected;
  assign slot_no_alloc_on_miss_o = slot_no_alloc_on_miss;
  assign slot_sameline_beat_count_o = slot_sameline_beat_count;
  assign slot_has_cleanunique_duty_o = slot_has_cleanunique_duty;
  assign slot_load_sameline_seen_o = slot_load_sameline_seen;
  assign slot_load_sameline_o = slot_load_sameline;


`ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVLs
  //----------------------------------------------------------------------------

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Last is zero for slots to normal or device GRE memory")
  u_ovl_merge_last (.clk             (clk),
                    .reset_n         (reset_n),
                    .antecedent_expr (slot_valid & `CA53_MEM_MERGEABLE(slot_attrs)),
                    .consequent_expr (~slot_last));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Can only merge into a mergable slot")
  u_ovl_merge_mergeable (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (slot_valid & slot_real_new_req_dc3),
                         .consequent_expr (slot_mergeable));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Attributes the same when merging")
  u_ovl_merge_attrs (.clk             (clk),
                     .reset_n         (reset_n),
                     .antecedent_expr (slot_valid & slot_real_new_req_dc3),
                     .consequent_expr (slot_attrs == dcu_stb_attrs_dc3_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Address the same when merging")
  u_ovl_merge_addr (.clk             (clk),
                    .reset_n         (reset_n),
                    .antecedent_expr (slot_valid & slot_real_new_req_dc3),
                    .consequent_expr (slot_addr[39:4] == dcu_pa_dc3_i[39:4]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "NS bit the same when merging")
  u_ovl_merge_ns (.clk             (clk),
                  .reset_n         (reset_n),
                  .antecedent_expr (slot_valid & slot_real_new_req_dc3),
                  .consequent_expr (slot_ns == dcu_ns_dsc_dc3_i));

  reg    ovl_previous_merge;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ovl_previous_merge <= 1'b0;
  end else begin
    ovl_previous_merge <= slot_valid & slot_real_new_req_dc3;
  end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A slot just merged to cannot go straight to idle")
  u_ovl_merge_not_idle (.clk             (clk),
                        .reset_n         (reset_n),
                        .antecedent_expr (ovl_previous_merge),
                        .consequent_expr (slot_valid));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A slot cannot be in the same line as four other slots unless one of the stores has been committed (would imply cacheline > 64B)")
  u_ovl_sameline (.clk             (clk),
                  .reset_n         (reset_n),
                  .antecedent_expr (slot_valid & (&slot_sameline)),
                  .consequent_expr (slot_state_cachewritem1 | (|slots_state_cachewritem1)));
  
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A slot cannot be made part of the same line as a slot that must drain earlier than it")
  u_ovl_sameline_earlier (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (slot_valid),
                          .consequent_expr (~|(slot_sameline & slot_real_earlier)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "An write request being accepted by the BIU cannot have any earlier bits set")
  u_ovl_write_earlier_slots (.clk             (clk),
                             .reset_n         (reset_n),
                             .antecedent_expr (slot_wants_write_addr_priority & slot_has_ar_priority_i),
                             .consequent_expr (~|(slot_real_earlier & ~(slots_state_biuack |
                                                                        slots_state_biuresp |
                                                                        slots_state_biudata))));

  generate if (CPU_CACHE_PROTECTION) begin : gen_cpu_cache_protection_04

    assert_always #(`OVL_FATAL, `OVL_ASSERT, "Only some slot states are valid")
    u_ovl_valid_slot_states_ecc (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .test_expr ((modified_slot_state == `CA53_SLOT_IDLE) |
                                             (modified_slot_state == `CA53_SLOT_LOOKUPREQ) |
                                             (modified_slot_state == `CA53_SLOT_LOOKUPM1) |
                                             (modified_slot_state == `CA53_SLOT_LOOKUPM2) |
                                             (modified_slot_state == `CA53_SLOT_CACHEMERGE) |
                                             (modified_slot_state == `CA53_SLOT_CACHEREADM0) |
                                             (modified_slot_state == `CA53_SLOT_CACHEREADM1) |
                                             (modified_slot_state == `CA53_SLOT_CACHEREADM2) |
                                             (modified_slot_state == `CA53_SLOT_CACHEECC) |
                                             (modified_slot_state == `CA53_SLOT_CACHEWRITEREQ) |
                                             (modified_slot_state == `CA53_SLOT_CACHEWRITEM1) |
                                             (modified_slot_state == `CA53_SLOT_CACHEECC_WAIT) |
                                             (modified_slot_state == `CA53_SLOT_LFREQ) |
                                             (modified_slot_state == `CA53_SLOT_BIUMERGE) |
                                             (modified_slot_state == `CA53_SLOT_BIUREQ) |
                                             (modified_slot_state == `CA53_SLOT_BIUACK) |
                                             (modified_slot_state == `CA53_SLOT_BIURESP) |
                                             (modified_slot_state == `CA53_SLOT_BIUDATA) |
                                             (modified_slot_state == `CA53_SLOT_CLEANUNIQUE_REQ) |
                                             (modified_slot_state == `CA53_SLOT_CLEANUNIQUE_ACK) |
                                             (modified_slot_state == `CA53_SLOT_CLEANUNIQUE_RESP) |
                                             (modified_slot_state == `CA53_SLOT_TAGWRITE) |
                                             (modified_slot_state == `CA53_SLOT_CP15REQ) |
                                             (modified_slot_state == `CA53_SLOT_CP15ACK) |
                                             (modified_slot_state == `CA53_SLOT_CP15RESP) |
                                             (modified_slot_state == `CA53_SLOT_DVMDATA) |
                                             (modified_slot_state == `CA53_SLOT_SYNCREQ) |
                                             (modified_slot_state == `CA53_SLOT_SYNCACK) |
                                             (modified_slot_state == `CA53_SLOT_SYNCRESP1) |
                                             (modified_slot_state == `CA53_SLOT_SYNCRESP2) |
                                             (modified_slot_state == `CA53_SLOT_BARRIER_REQ) |
                                             (modified_slot_state == `CA53_SLOT_BARRIER_ACK) |
                                             (modified_slot_state == `CA53_SLOT_BARRIER_RESP)));

  end else begin : gen_cpu_cache_protection_04_else

    assert_always #(`OVL_FATAL, `OVL_ASSERT, "Only some slot states are valid")
    u_ovl_valid_slot_states (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr ((modified_slot_state == `CA53_SLOT_IDLE) |
                                         (modified_slot_state == `CA53_SLOT_LOOKUPREQ) |
                                         (modified_slot_state == `CA53_SLOT_LOOKUPM1) |
                                         (modified_slot_state == `CA53_SLOT_LOOKUPM2) |
                                         (modified_slot_state == `CA53_SLOT_CACHEMERGE) |
                                         (modified_slot_state == `CA53_SLOT_CACHEWRITEREQ) |
                                         (modified_slot_state == `CA53_SLOT_CACHEWRITEM1) |
                                         (modified_slot_state == `CA53_SLOT_LFREQ) |
                                         (modified_slot_state == `CA53_SLOT_BIUMERGE) |
                                         (modified_slot_state == `CA53_SLOT_BIUREQ) |
                                         (modified_slot_state == `CA53_SLOT_BIUACK) |
                                         (modified_slot_state == `CA53_SLOT_BIURESP) |
                                         (modified_slot_state == `CA53_SLOT_BIUDATA) |
                                         (modified_slot_state == `CA53_SLOT_CLEANUNIQUE_REQ) |
                                         (modified_slot_state == `CA53_SLOT_CLEANUNIQUE_ACK) |
                                         (modified_slot_state == `CA53_SLOT_CLEANUNIQUE_RESP) |
                                         (modified_slot_state == `CA53_SLOT_TAGWRITE) |
                                         (modified_slot_state == `CA53_SLOT_CP15REQ) |
                                         (modified_slot_state == `CA53_SLOT_CP15ACK) |
                                         (modified_slot_state == `CA53_SLOT_CP15RESP) |
                                         (modified_slot_state == `CA53_SLOT_DVMDATA) |
                                         (modified_slot_state == `CA53_SLOT_SYNCREQ) |
                                         (modified_slot_state == `CA53_SLOT_SYNCACK) |
                                         (modified_slot_state == `CA53_SLOT_SYNCRESP1) |
                                         (modified_slot_state == `CA53_SLOT_SYNCRESP2) |
                                         (modified_slot_state == `CA53_SLOT_BARRIER_REQ) |
                                         (modified_slot_state == `CA53_SLOT_BARRIER_ACK) |
                                         (modified_slot_state == `CA53_SLOT_BARRIER_RESP)));

  end endgenerate

  wire ovl_slot_state_idle = `CA53_SLOT_STATE_IDLE(slot_state);

  assert_one_hot #(`OVL_FATAL, 33, `OVL_ASSERT, "Slot states should be one hot")
  u_ovl_slot_states_onehot (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({ovl_slot_state_idle,
                                         slot_state_lookupreq,
                                         slot_state_lookupm1,
                                         slot_state_lookupm2,
                                         slot_state_cachemerge,
                                         slot_state_cachereadm0,
                                         slot_state_cachereadm1,
                                         slot_state_cachereadm2,
                                         slot_state_cacheecc,
                                         slot_state_cachewritereq,
                                         slot_state_cachewritem1,
                                         slot_state_cacheecc_wait,
                                         slot_state_lfreq,
                                         slot_state_biumerge,
                                         slot_state_biureq,
                                         slot_state_biuack,
                                         slot_state_biuresp,
                                         slot_state_biudata,
                                         slot_state_cleanunique_req,
                                         slot_state_cleanunique_ack,
                                         slot_state_cleanunique_resp,
                                         slot_state_tagwrite,
                                         slot_state_cp15req,
                                         slot_state_cp15ack,
                                         slot_state_cp15resp,
                                         slot_state_dvmdata,
                                         slot_state_syncreq,
                                         slot_state_syncack,
                                         slot_state_syncresp1,
                                         slot_state_syncresp2,
                                         slot_state_barrier_req,
                                         slot_state_barrier_ack,
                                         slot_state_barrier_resp}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "CP15 operations only use some states")
  u_ovl_cp15_states_1 (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (slot_valid & slot_cp15),
                       .consequent_expr (slot_state_cp15req |
                                         slot_state_cp15ack |
                                         slot_state_cp15resp |
                                         slot_state_dvmdata |
                                         slot_state_syncreq |
                                         slot_state_syncack |
                                         slot_state_syncresp1 |
                                         slot_state_syncresp2 |
                                         slot_state_barrier_req |
                                         slot_state_barrier_ack |
                                         slot_state_barrier_resp));
   
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Some states are only used by CP15 operations")
  u_ovl_cp15_states_2 (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (slot_state_cp15req |
                                         slot_state_cp15ack |
                                         slot_state_cp15resp |
                                         slot_state_dvmdata |
                                         slot_state_syncreq |
                                         slot_state_syncack |
                                         slot_state_syncresp1 |
                                         slot_state_syncresp2),
                       .consequent_expr (slot_valid & slot_cp15));
 
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Barrier states are only used by CP15 operations and STLR")
  u_ovl_barrier_states (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (slot_state_barrier_req |
                                         slot_state_barrier_ack |
                                         slot_state_barrier_resp),
                       .consequent_expr (slot_valid & (slot_cp15 | slot_stlr)));
                       
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Barrier states are only used by the store part of STLR if it's non-coherent")
  u_ovl_stlr_barrier_non_coherent (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr ((slot_valid & slot_stlr & ~slot_cp15) &
                                                     (slot_state_barrier_req |
                                                      slot_state_barrier_ack |
                                                      slot_state_barrier_resp)),
                                   .consequent_expr (~`CA53_MEM_COHERENT(slot_attrs)));
                       
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Some slot states are only entered when ECC is enabled")
  u_ovl_ecc_states (.clk             (clk),
                    .reset_n         (reset_n),
                    .antecedent_expr (|{slot_state_cachereadm0,
                                        slot_state_cachereadm1,
                                        slot_state_cachereadm2,
                                        slot_state_cacheecc,
                                        slot_state_cacheecc_wait}),
                    .consequent_expr (CPU_CACHE_PROTECTION != 0));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_idle_transition (.clk         (clk),
                              .reset_n     (reset_n),
                              .start_event (ovl_slot_state_idle),
                              .test_expr   (ovl_slot_state_idle |
                                            slot_state_biumerge |
                                            slot_state_biureq |
                                            slot_state_biuack |
                                            slot_state_biuresp |
                                            slot_state_biudata |
                                            slot_state_cp15req |
                                            slot_state_lookupreq |
                                            slot_state_lookupm1 |
                                            slot_state_lookupm2 |
                                            slot_state_cacheecc_wait |
                                            slot_state_lfreq |
                                            slot_state_cleanunique_req |
                                            slot_state_cleanunique_ack |
                                            slot_state_cleanunique_resp |
                                            slot_state_syncreq |
                                            slot_state_barrier_req |
                                            slot_state_tagwrite |
                                            slot_state_cachemerge |
                                            slot_state_cachewritereq));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_lookupreq_transition (.clk         (clk),
                                   .reset_n     (reset_n),
                                   .start_event (slot_state_lookupreq),
                                   .test_expr   (slot_state_lookupreq |
                                                 ovl_slot_state_idle |
                                                 slot_state_lookupm1 |
                                                 slot_state_lfreq |
                                                 slot_state_cachemerge));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_lookupm1_transition (.clk         (clk),
                                  .reset_n     (reset_n),
                                  .start_event (slot_state_lookupm1),
                                  .test_expr   (slot_state_lookupm1 |
                                                slot_state_lookupm2));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_lookupm2_transition (.clk         (clk),
                                  .reset_n     (reset_n),
                                  .start_event (slot_state_lookupm2),
                                  .test_expr   (slot_state_cacheecc_wait |
                                                slot_state_lookupreq |
                                                slot_state_cachereadm0 |
                                                slot_state_cleanunique_req |
                                                slot_state_lfreq |
                                                slot_state_cachemerge |
                                                slot_state_cachewritereq |
                                                slot_state_biureq));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_cachemerge_transition (.clk         (clk),
                                    .reset_n     (reset_n),
                                    .start_event (slot_state_cachemerge),
                                    .test_expr   (slot_state_cachemerge |
                                                  slot_state_cachereadm0 |
                                                  slot_state_cachewritereq |
                                                  slot_state_lookupreq));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_cachereadm0_transition (.clk         (clk),
                                     .reset_n     (reset_n),
                                     .start_event (slot_state_cachereadm0),
                                     .test_expr   (slot_state_cachereadm0 |
                                                   slot_state_cachereadm1 |
                                                   slot_state_lookupreq |
                                                   slot_state_cleanunique_req|
                                                   slot_state_cachewritereq));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_cachereadm1_transition (.clk         (clk),
                                     .reset_n     (reset_n),
                                     .start_event (slot_state_cachereadm1),
                                     .test_expr   (slot_state_cachereadm1 |
                                                   slot_state_cachereadm2));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_cachereadm2_transition (.clk         (clk),
                                     .reset_n     (reset_n),
                                     .start_event (slot_state_cachereadm2),
                                     .test_expr   (slot_state_cachereadm2 |
                                                   slot_state_cacheecc));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_cachewritereq_transition (.clk         (clk),
                                       .reset_n     (reset_n),
                                       .start_event (slot_state_cachewritereq),
                                       .test_expr   (slot_state_cachewritereq |
                                                     ovl_slot_state_idle |
                                                     slot_state_lookupreq |
                                                     slot_state_cachewritem1 |
                                                     slot_state_cachereadm0));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_cachewritem1_transition (.clk         (clk),
                                      .reset_n     (reset_n),
                                      .start_event (slot_state_cachewritem1),
                                      .test_expr   (slot_state_cachewritem1 |
                                                    ovl_slot_state_idle));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_cacheecc_wait_transition (.clk         (clk),
                                       .reset_n     (reset_n),
                                       .start_event (slot_state_cacheecc_wait),
                                       .test_expr   (slot_state_cacheecc_wait |
                                                     slot_state_lookupreq));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_lfreq_transition (.clk         (clk),
                               .reset_n     (reset_n),
                               .start_event (slot_state_lfreq),
                               .test_expr   (slot_state_lfreq |
                                             slot_state_lookupreq |
                                             slot_state_cachewritereq |
                                             ovl_slot_state_idle));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_biumerge_transition (.clk         (clk),
                                  .reset_n     (reset_n),
                                  .start_event (slot_state_biumerge),
                                  .test_expr   (slot_state_biumerge |
                                                slot_state_biureq |
                                                slot_state_biuack));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_biureq_transition (.clk         (clk),
                                .reset_n     (reset_n),
                                .start_event (slot_state_biureq),
                                .test_expr   (slot_state_biureq |
                                              slot_state_biuack |
                                              slot_state_lfreq));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_biuack_transition (.clk         (clk),
                                .reset_n     (reset_n),
                                .start_event (slot_state_biuack),
                                .test_expr   (slot_state_biuack |
                                              slot_state_biureq |
                                              slot_state_biuresp |
                                              slot_state_lfreq));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_biuresp_transition (.clk         (clk),
                                 .reset_n     (reset_n),
                                 .start_event (slot_state_biuresp),
                                 .test_expr   (slot_state_biuresp |
                                               slot_state_biudata));
  
  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_biudata_transition (.clk         (clk),
                                 .reset_n     (reset_n),
                                 .start_event (slot_state_biudata),
                                 .test_expr   (slot_state_biudata |
                                               slot_state_barrier_req |
                                               ovl_slot_state_idle));
  
  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_cleanunique_req_transition (.clk         (clk),
                                         .reset_n     (reset_n),
                                         .start_event (slot_state_cleanunique_req),
                                         .test_expr   (slot_state_cleanunique_req |
                                                       ovl_slot_state_idle |
                                                       slot_state_cleanunique_ack |
                                                       slot_state_lookupreq));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_cleanunique_ack_transition (.clk         (clk),
                                         .reset_n     (reset_n),
                                         .start_event (slot_state_cleanunique_ack),
                                         .test_expr   (slot_state_cleanunique_ack |
                                                       slot_state_lookupreq |
                                                       slot_state_cleanunique_resp));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_cleanunique_resp_transition (.clk         (clk),
                                          .reset_n     (reset_n),
                                          .start_event (slot_state_cleanunique_resp),
                                          .test_expr   (slot_state_cleanunique_resp |
                                                        ovl_slot_state_idle |
                                                        slot_state_lookupreq |
                                                        slot_state_tagwrite));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_tagwrite_transition (.clk         (clk),
                                  .reset_n     (reset_n),
                                  .start_event (slot_state_tagwrite),
                                  .test_expr   (slot_state_tagwrite |
                                                slot_state_cachereadm0 |
                                                slot_state_cachewritereq));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_cp15req_transition (.clk         (clk),
                                 .reset_n     (reset_n),
                                 .start_event (slot_state_cp15req),
                                 .test_expr   (slot_state_cp15req |
                                               slot_state_cp15ack));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_cp15ack_transition (.clk         (clk),
                                 .reset_n     (reset_n),
                                 .start_event (slot_state_cp15ack),
                                 .test_expr   (slot_state_cp15ack |
                                               slot_state_cp15resp));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_cp15resp_transition (.clk         (clk),
                                  .reset_n     (reset_n),
                                  .start_event (slot_state_cp15resp),
                                  .test_expr   (slot_state_cp15resp |
                                                slot_state_dvmdata |
                                                ovl_slot_state_idle));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_dvmdata_transition (.clk         (clk),
                                 .reset_n     (reset_n),
                                 .start_event (slot_state_dvmdata),
                                 .test_expr   (slot_state_dvmdata |
                                               slot_state_syncresp2 |
                                               ovl_slot_state_idle));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_syncreq_transition (.clk         (clk),
                                 .reset_n     (reset_n),
                                 .start_event (slot_state_syncreq),
                                 .test_expr   (slot_state_syncreq |
                                               slot_state_syncack));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_syncack_transition (.clk         (clk),
                                 .reset_n     (reset_n),
                                 .start_event (slot_state_syncack),
                                 .test_expr   (slot_state_syncack |
                                               slot_state_syncresp1));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_syncresp1_transition (.clk         (clk),
                                   .reset_n     (reset_n),
                                   .start_event (slot_state_syncresp1),
                                   .test_expr   (slot_state_syncresp1 |
                                                 slot_state_dvmdata));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_syncresp2_transition (.clk         (clk),
                                   .reset_n     (reset_n),
                                   .start_event (slot_state_syncresp2),
                                   .test_expr   (slot_state_syncresp2 |
                                                 slot_state_barrier_req));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_barrier_req_transition (.clk         (clk),
                                     .reset_n     (reset_n),
                                     .start_event (slot_state_barrier_req),
                                     .test_expr   (slot_state_barrier_req |
                                                   slot_state_barrier_ack |
                                                   ovl_slot_state_idle));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_barrier_ack_transition (.clk         (clk),
                                     .reset_n     (reset_n),
                                     .start_event (slot_state_barrier_ack),
                                     .test_expr   (slot_state_barrier_ack |
                                                   slot_state_barrier_resp));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid slot state transition")
  u_ovl_slot_barrier_resp_transition (.clk         (clk),
                                      .reset_n     (reset_n),
                                      .start_event (slot_state_barrier_resp),
                                      .test_expr   (slot_state_barrier_resp |
                                                    ovl_slot_state_idle));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A new slot cannot be in the same line as this one if this one is no longer mergeable")
  u_ovl_new_sameline_slots (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (slot_valid & |new_other_slots_sameline),
                            .consequent_expr (slot_mergeable));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A CP15 slot cannot be mergeable")
  u_ovl_cp15_not_mergeable (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (slot_valid & slot_cp15),
                            .consequent_expr (~slot_mergeable));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A slot in the biumerge state must be mergeable")
  u_ovl_biumerge_mergeable (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (slot_state_biumerge),
                            .consequent_expr (slot_mergeable));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Exclusives should never burst")
  u_ovl_excl_single_beat (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (slot_valid & slot_exclusive),
                          .consequent_expr (~|slot_sameline & ~|slot_same_dev_write));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Exclusives should never request linefills")
  u_ovl_excl_no_lf_req (.clk             (clk),
                        .reset_n         (reset_n),
                        .antecedent_expr (slot_valid & slot_exclusive),
                        .consequent_expr (~slot_lf_req_o));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Must never be trying to write a tag if other slots are earlier")
  u_ovl_tagwrite_no_earlier (.clk             (clk),
                             .reset_n         (reset_n),
                             .antecedent_expr ((slot_state_tagwrite)),
                             .consequent_expr ((~wait_for_earlier_slot) |
                                               (|(slot_sameline & slots_state_tagwrite))));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "slot_sameline must never be set for an invalid slot")
  u_ovl_sameline_valid (.clk             (clk),
                        .reset_n         (reset_n),
                        .antecedent_expr (slot_valid),
                        .consequent_expr (~|(slot_sameline & ~slots_valid)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Must be in biuresp, barrier_resp, cleanunique_resp, cp15ack, synresp1, or syncresp2 state when receiving an ar_resp_valid")
  u_ovl_ar_resp_valid (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (slot_ar_resp_valid_i),
                       .consequent_expr (slot_state_biuresp |
                                         slot_state_barrier_resp |
                                         slot_state_cleanunique_resp |
                                         slot_state_cp15resp |
                                         slot_state_syncresp1 |
                                         slot_state_syncresp2));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Non-coherent slots must not enter coherent states")
  u_ovl_ncoh_wrong_states (.clk             (clk),
                           .reset_n         (reset_n),
                           .antecedent_expr (slot_valid & ~`CA53_MEM_COHERENT(slot_attrs)),
                           .consequent_expr (~slot_state_lookupreq &
                                             ~slot_state_lookupm1 &
                                             ~slot_state_lookupm2 &
                                             ~slot_state_cachemerge &
                                             ~slot_state_cachereadm0 &
                                             ~slot_state_cachereadm1 &
                                             ~slot_state_cachereadm2 &
                                             ~slot_state_cacheecc &
                                             ~slot_state_cacheecc_wait &
                                             ~slot_state_cachewritereq &
                                             ~slot_state_cachewritem1 &
                                             ~slot_state_cleanunique_req &
                                             ~slot_state_cleanunique_ack &
                                             ~slot_state_cleanunique_resp &
                                             ~slot_state_tagwrite &
                                             ~slot_state_lfreq));
  
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Coherent slots must not enter non-coherent states")
  u_ovl_coh_wrong_states (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (slot_valid & `CA53_MEM_COHERENT(slot_attrs)),
                          .consequent_expr (~slot_state_biumerge));
  
  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "STREX must not skip lookup states")
  u_ovl_strex_transition (.clk         (clk),
                          .reset_n     (reset_n),
                          .start_event (new_req_from_idle & ~dpu_kill_wr_i & dcu_stb_exclusive_dc3_i),
                          .test_expr   (slot_state_lookupreq | slot_state_biureq | slot_state_cacheecc_wait));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "A slot must only remain in the special state for one cycle")
  u_ovl_special_one_cycle (.clk         (clk),
                           .reset_n     (reset_n),
                           .start_event (`CA53_SLOT_STATE_SPECIAL(slot_state)),
                           .test_expr   (~`CA53_SLOT_STATE_SPECIAL(slot_state)));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "The store part of a non-cacheable store release must be followed by an implicit DSB that propagates to the BIU to ensure multi-copy atomicity")
  u_ovl_stlr_barrier (.clk         (clk),
                      .reset_n     (reset_n),
                      .start_event (slot_state_biudata & slot_write_accept & slot_stlr & ~slot_exclusive),
                      .test_expr   (slot_state_barrier_req & propagate_barrier_i));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "DVM Sync must be followed by a barrier that propagates to the BIU")
  u_ovl_sync_barrier (.clk         (clk),
                      .reset_n     (reset_n),
                      .start_event (slot_state_syncresp2 & dvm_complete_i),
                      .test_expr   (slot_state_barrier_req & propagate_barrier_i));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Sync_slots should only take one cycle")
  u_ovl_sync_slots_single_cycle (.clk         (clk),
                                 .reset_n     (reset_n),
                                 .start_event (slot_state_lookupreq & ~slot_ev_hz_seen & sync_slots),
                                 .test_expr   (~(slot_state_lookupreq & sync_slots)));
  
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Cannot miss in a shared line")
  u_ovl_miss_shared (.clk             (clk),
                     .reset_n         (reset_n),
                     .antecedent_expr (`CA53_SLOT_STATE_SPECIAL(slot_state)),
                     .consequent_expr (tag_hit_shared_m3_i != 2'b01));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A shareable STREX must never be in the cachemerge or biumerge states")
  u_ovl_strex_not_merge (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (slot_valid & slot_exclusive),
                         .consequent_expr (~(slot_state_cachemerge |
                                             slot_state_biumerge)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "slot_already_has_ar_priority optimization must be correct")
  u_ovl_slot_already_has_ar_opt (.clk             (clk),
                                 .reset_n         (reset_n),
                                 .antecedent_expr (slot_already_has_ar_priority),
                                 .consequent_expr (slot_state_biuack |
                                                   slot_state_cleanunique_ack |
                                                   slot_state_cp15ack |
                                                   slot_state_syncack |
                                                   slot_state_barrier_ack));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Slot_emptying optimization must be correct")
  u_ovl_slot_emptying (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (slot_emptying),
                       .consequent_expr (slot_valid & (next_slot_state == `CA53_SLOT_IDLE)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The sameline beat count must saturate at 7")
  u_ovl_slot_sameline_beat_count (.clk             (clk),
                                  .reset_n         (reset_n),
                                  .antecedent_expr (slot_valid & (slot_sameline_beat_count == 3'b111)),
                                  .consequent_expr (next_slot_sameline_beat_count == 3'b111));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The number of times slot_drain_count_1023 is seen must saturate at 3")
  u_ovl_slot_drain_count (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (slot_valid & ~slot_state_cachemerge &
                                            (slot_drain_count_1023_seen == 2'b11)),
                          .consequent_expr (next_slot_drain_count_1023_seen == 2'b11));

  // The following is true within the STB even for aarch64 versions because we only send instruction
  // cache invalidates by PA and therefore only need to send the virtual index (bits [27:12]). As we
  // don't need to access the upper bits of the VA, we can treat all instruction cache invalidates as
  // aarch32.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Instruction cache maintenance ops must use the AA32 register format")
  u_ovl_slot_ic_maint_aa32 (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (slot_valid & ((cp15_type == `CA53_CPOP_8_ICIALLUIS) |
                                                            (cp15_type == `CA53_CPOP_8_ICIALLU) |
                                                            (cp15_type == `CA53_CPOP_8_ICIMVAU) |
                                                            (cp15_type == `CA53_CPOP_8_ICIVAU))),
                            .consequent_expr (~cp15_aarch64));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Branch predictor maintenance ops must use the AA32 register format")
  u_ovl_slot_bp_maint_aa32 (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (slot_valid & ((cp15_type == `CA53_CPOP_8_BPIALLIS) |
                                                            (cp15_type == `CA53_CPOP_8_BPIMVA))),
                            .consequent_expr (~cp15_aarch64));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Aarch32 cp15 ops should never send VA[48:40]")
  u_ovl_slot_aa32_upper_va (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (slot_valid & ~cp15_aarch64),
                            .consequent_expr (slot_cp15_va_o[24:16] == 9'h000));

  assert_one_hot #(`OVL_FATAL, 3, `OVL_ASSERT, "Address select must be one hot")
  u_ovl_slot_addr_sel_onehot (.clk (clk),
                              .reset_n (reset_n),
                              .test_expr ({addr_sel_ipa_va, addr_sel_sw, addr_sel_pa}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A CleanUnique request must wait for barriered slots to complete")
  u_ovl_slot_cleanunique_real_earlier (.clk             (clk),
                                       .reset_n         (reset_n),
                                       .antecedent_expr (slot_wants_cleanunique_priority),
                                       .consequent_expr (~|slot_real_earlier));

  // Track when a slot completes a CleanUnique request.
  wire  ovl_slot_cleanunique_done_en;
  wire  ovl_next_slot_cleanunique_done;
  reg   ovl_slot_cleanunique_done;

  assign ovl_slot_cleanunique_done_en = new_req_from_idle |
                                        (slot_state_cleanunique_resp & ar_resp_valid);

  assign ovl_next_slot_cleanunique_done = slot_has_cleanunique_duty &
                                          slot_state_cleanunique_resp &
                                          slot_ar_resp_valid_i &
                                          (slot_exclusive ? ~ar_resp_excl_fail : ~ar_resp_fail) &
                                          ~(slot_ev_hz_seen | slot_ev_hazard | ccb_ev_hazard);

  always @(posedge clk)
  if (ovl_slot_cleanunique_done_en) begin
    ovl_slot_cleanunique_done <= ovl_next_slot_cleanunique_done;
  end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "If a CleanUnique has been completed for a store then the write must complete")
  u_ovl_slot_cleanunique_complete (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (slot_emptying & ovl_slot_cleanunique_done),
                                   .consequent_expr (slot_state_cachewritem1));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "If a CleanUnique has been completed for a store then snoops to the same line must be blocked until the store completes")
  // An exception at unit level is when there is a linefill in progress for a line that hit in the cache.
  u_ovl_slot_cleanunique_block_ccb (.clk             (clk),
                                    .reset_n         (reset_n),
                                    .antecedent_expr (slot_valid & ccb_ev_hazard & ovl_slot_cleanunique_done &
                                                      ~(slot_state_cachewritereq & slot_lf_hz_seen & ~slot_lf_can_merge)),
                                    .consequent_expr (slot_block_ccb_o));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A slot should never redo a CleanUnique request")
  u_ovl_slot_cleanunique_once (.clk             (clk),
                               .reset_n         (reset_n),
                               .antecedent_expr (slot_valid & ovl_slot_cleanunique_done),
                               .consequent_expr (~slot_wants_cleanunique_priority));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Eviction hazards must be ignored after a CleanUnique has completed")
  u_ovl_slot_cleanunique_ignore_ev (.clk             (clk),
                                    .reset_n         (reset_n),
                                    .antecedent_expr (slot_valid & ovl_slot_cleanunique_done),
                                    .consequent_expr (~slot_state_lookupreq));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A slot must never do a cache read after a CleanUnique request")
  u_ovl_slot_cleanunique_read (.clk             (clk),
                               .reset_n         (reset_n),
                               .antecedent_expr (slot_valid & ovl_slot_cleanunique_done),
                               .consequent_expr (~slot_wants_cache_read_priority));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Only one slot can have CleanUnique duty for a given line")
  u_ovl_slot_cleanunique_duty_onehot (.clk             (clk),
                                      .reset_n         (reset_n),
                                      .antecedent_expr (slot_valid & slot_has_cleanunique_duty),
                                      .consequent_expr (~|(slot_sameline & slots_have_cleanunique_duty)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A slot in the CleanUnique request state implies one of the slots has CleanUnique duty")
  u_ovl_slot_cleanunique_duty_req (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (slot_state_cleanunique_req & ~slot_ev_hz_seen),
                                   .consequent_expr (slot_has_cleanunique_duty |
                                                     (|(slot_sameline & slots_have_cleanunique_duty))));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A slot with CleanUnique duty can only be in certain states")
  u_ovl_slot_cleanunique_duty_states (.clk             (clk),
                                      .reset_n         (reset_n),
                                      .antecedent_expr (slot_has_cleanunique_duty),
                                      .consequent_expr (ovl_slot_state_idle |
                                                        slot_state_cachereadm0 |
                                                        slot_state_cachereadm1 |
                                                        slot_state_cachereadm2 |
                                                        slot_state_cacheecc |
                                                        slot_state_cacheecc_wait |
                                                        slot_state_cleanunique_req |
                                                        slot_state_cleanunique_ack |
                                                        slot_state_cleanunique_resp |
                                                        slot_state_tagwrite |
                                                        slot_state_cachewritereq |
                                                        slot_state_cachewritem1));

  generate if (CPU_CACHE_PROTECTION) begin : gen_cpu_cache_protection_05

    reg  ovl_force_lf_merge;
    wire ovl_next_force_lf_merge;

    assign ovl_next_force_lf_merge = slot_lf_merge &
                                     slot_biu_lf_can_merge_i &
                                     slot_biu_ev_hazard_i;

    always @(posedge clk) begin
      ovl_force_lf_merge <= ovl_next_force_lf_merge;
    end

    assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A slot must have data for all 32-bit chunks when requesting a CleanUnique")
    u_ovl_slot_cleanunique_all_chunks (.clk             (clk),
                                       .reset_n         (reset_n),
                                       .antecedent_expr (slot_wants_cleanunique_priority),
                                       .consequent_expr (&slot_32bit_chunks));

    assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Slot data must be in 32-bit chunks before it can be written to the cache")
    u_ovl_slot_32bit_cachewrite (.clk             (clk),
                                 .reset_n         (reset_n),
                                 .antecedent_expr (slot_wants_cache_write_priority & ~ovl_force_lf_merge),
                                 .consequent_expr ((slot_32bit_chunks[3] | ~|slot_bls[15:12]) &
                                                   (slot_32bit_chunks[2] | ~|slot_bls[11:8]) &
                                                   (slot_32bit_chunks[1] | ~|slot_bls[7:4]) &
                                                   (slot_32bit_chunks[0] | ~|slot_bls[3:0])));

  end endgenerate

  reg  ovl_first_cycle_in_state;
  wire ovl_next_first_cycle_in_state;

  assign ovl_next_first_cycle_in_state = (modified_slot_state != next_slot_state);

  always @(posedge clk) begin
    ovl_first_cycle_in_state <= ovl_next_first_cycle_in_state;
  end
  
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A slot blocking CCB requests for a post linefill merge can only be in certain states")
  u_ovl_slot_post_lf_merge_states (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (slot_post_lf_merge),
                                   .consequent_expr ((slot_state_lookupreq & ovl_first_cycle_in_state) |
                                                     slot_state_lfreq |
                                                     slot_state_cachereadm0 |
                                                     slot_state_cachereadm1 |
                                                     slot_state_cachereadm2 |
                                                     slot_state_cacheecc |
                                                     (slot_state_cacheecc_wait & ovl_first_cycle_in_state) |
                                                     slot_state_cachewritereq |
                                                     slot_state_cachewritem1));
  
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Non-mergeable stores to mergeable memory should not wait for beats")
  u_ovl_wait_for_beat_normal (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (slot_valid &
                                                ~slot_mergeable &
                                                `CA53_MEM_MERGEABLE(slot_attrs)),
                              .consequent_expr (~slot_wait_for_beat));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Stores to non-mergeable memory should not wait for beats if the DCU has sent all the data")
  u_ovl_wait_for_beat_non_mergeable (.clk             (clk),
                                     .reset_n         (reset_n),
                                     .antecedent_expr (slot_valid & ~`CA53_MEM_MERGEABLE(slot_attrs) & ~slot_more_dev_expected),
                                     .consequent_expr (~slot_wait_for_beat));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Slot must not request a barrier from IDLE")
  u_ovl_force_non_mergeable (.clk             (clk),
                             .reset_n         (reset_n),
                             .antecedent_expr (slot_force_non_mergeable_o),
                             .consequent_expr (slot_valid));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Slot must not block loads from IDLE")
  u_ovl_block_loads_dc1_idle (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (slot_block_loads_dc1_o),
                              .consequent_expr (slot_valid));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Slot must not block loads from CACHEMERGE as the slot will not exit CACHEMERGE until it has to")
  u_ovl_block_loads_dc1_cachemerge (.clk         (clk),
                                    .reset_n     (reset_n),
                                    .start_event (slot_state_cachemerge & slot_block_loads_dc1_o),
                                    .test_expr   (~(slot_state_cachemerge & slot_block_loads_dc1_o)));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Slot should not wait for beats again after de-asserting slot_wait_for_beat")
  u_ovl_wait_for_beat_reassertion (.clk         (clk),
                                   .reset_n     (reset_n),
                                   .start_event (slot_valid & ~slot_wait_for_beat),
                                   .test_expr   (~slot_wait_for_beat));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "slot_lf_hz_seen must be asserted in LFREQ if it was asserted in the cycle before LFREQ")
  u_ovl_lf_hz_seen_lfreq (.clk         (clk),
                          .reset_n     (reset_n),
                          .start_event (slot_valid & slot_lf_hz_seen),
                          .test_expr   (slot_lf_hz_seen | ~slot_state_lfreq));

  // X checks on signals used in if statements in the next state logic.
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_new_req_dc3_i never X")
  u_ovl_x_1 (.clk       (clk),
             .reset_n   (reset_n),
             .qualifier (1'b1),
             .test_expr (slot_new_req_dc3_i));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "dvm_sync_needed_i never X")
  u_ovl_x_2 (.clk       (clk),
             .reset_n   (reset_n),
             .qualifier (1'b1),
             .test_expr (dvm_sync_needed_i));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "skip_to_lfreq never X")
  u_ovl_x_3 (.clk       (clk),
             .reset_n   (reset_n),
             .qualifier ((slot_state != `CA53_SLOT_IDLE) | slot_new_req_dc3_i),
             .test_expr (skip_to_lfreq));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "skip_to_cachemerge never X")
  u_ovl_x_4 (.clk       (clk),
             .reset_n   (reset_n),
             .qualifier ((slot_state != `CA53_SLOT_IDLE) | slot_new_req_dc3_i),
             .test_expr (skip_to_cachemerge));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "skip_to_tagwrite never X")
  u_ovl_x_5 (.clk       (clk),
             .reset_n   (reset_n),
             .qualifier ((slot_state != `CA53_SLOT_IDLE) | slot_new_req_dc3_i),
             .test_expr (skip_to_tagwrite));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "skip_to_cleanunique_resp never X")
  u_ovl_x_6 (.clk       (clk),
             .reset_n   (reset_n),
             .qualifier ((slot_state != `CA53_SLOT_IDLE) | slot_new_req_dc3_i),
             .test_expr (skip_to_cleanunique_resp));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "skip_to_cleanunique_ack never X")
  u_ovl_x_7 (.clk       (clk),
             .reset_n   (reset_n),
             .qualifier ((slot_state != `CA53_SLOT_IDLE) | slot_new_req_dc3_i),
             .test_expr (skip_to_cleanunique_ack));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "skip_to_cleanunique_req never X")
  u_ovl_x_8 (.clk       (clk),
             .reset_n   (reset_n),
             .qualifier ((slot_state != `CA53_SLOT_IDLE) | slot_new_req_dc3_i),
             .test_expr (skip_to_cleanunique_req));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "skip_to_biudata never X")
  u_ovl_x_9 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier ((slot_state != `CA53_SLOT_IDLE) | slot_new_req_dc3_i),
              .test_expr (skip_to_biudata));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "skip_to_biuresp never X")
  u_ovl_x_10 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier ((slot_state != `CA53_SLOT_IDLE) | slot_new_req_dc3_i),
              .test_expr (skip_to_biuresp));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "skip_to_biuack never X")
  u_ovl_x_11 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier ((slot_state != `CA53_SLOT_IDLE) | slot_new_req_dc3_i),
              .test_expr (skip_to_biuack));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "skip_to_biureq never X")
  u_ovl_x_12 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier ((slot_state != `CA53_SLOT_IDLE) | slot_new_req_dc3_i),
              .test_expr (skip_to_biureq));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "skip_to_special never X")
  u_ovl_x_13 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier ((slot_state != `CA53_SLOT_IDLE) | slot_new_req_dc3_i),
              .test_expr (skip_to_special));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "skip_to_lookupm2 never X")
  u_ovl_x_14 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier ((slot_state != `CA53_SLOT_IDLE) | slot_new_req_dc3_i),
              .test_expr (skip_to_lookupm2));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "skip_to_lookupm1 never X")
  u_ovl_x_15 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier ((slot_state != `CA53_SLOT_IDLE) | slot_new_req_dc3_i),
              .test_expr (skip_to_lookupm1));
  
  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "early_slot_sameline never X")
  u_ovl_x_16 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier ((slot_state != `CA53_SLOT_IDLE) | slot_new_req_dc3_i),
              .test_expr (early_slot_sameline));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_biu_lf_hazard_i never X")
  u_ovl_x_17 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_biu_lf_hazard_i));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_biu_lf_real_hazard_i never X")
  u_ovl_x_18 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_biu_lf_real_hazard_i));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "start_lookup never X")
  u_ovl_x_19 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state == `CA53_SLOT_LOOKUPREQ),
              .test_expr (start_lookup));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "dcu_stb_tag_ack_m1_i never X")
  u_ovl_x_20 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state == `CA53_SLOT_LOOKUPM1),
              .test_expr (dcu_stb_tag_ack_m1_i));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_force_drain_i never X")
  u_ovl_x_21 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_force_drain_i));
  
  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "tag_hit_shared_m3_i never X")
  u_ovl_x_22 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (`CA53_SLOT_STATE_SPECIAL(slot_state)),
              .test_expr (tag_hit_shared_m3_i));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "tag_ecc_err_m3_i never X")
  u_ovl_x_23 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (`CA53_SLOT_STATE_SPECIAL(slot_state)),
              .test_expr (tag_ecc_err_m3_i));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_lf_hz_seen never X")
  u_ovl_x_24 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_lf_hz_seen));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_way_valid_lfreq never X")
  u_ovl_x_25 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_way_valid_lfreq));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_ev_hz_seen never X")
  u_ovl_x_26 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_ev_hz_seen));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_ev_hazard never X")
  u_ovl_x_27 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_ev_hazard));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_write_accept never X")
  u_ovl_x_28 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_write_accept));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "ar_resp_valid never X")
  u_ovl_x_29 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (ar_resp_valid));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "tagwrite_accepted never X")
  u_ovl_x_30 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (tagwrite_accepted));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_merge_timeout never X")
  u_ovl_x_31 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_merge_timeout));
  
  assert_never_unknown #(`OVL_FATAL, 8, `OVL_ASSERT, "slot_attrs never X")
  u_ovl_x_32 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_attrs));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_mergeable never X")
  u_ovl_x_33 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_mergeable));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_stlr never X")
  u_ovl_x_34 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_stlr));
  
  assert_never_unknown #(`OVL_FATAL, `CA53_SLOT_WIDTH, `OVL_ASSERT, "slot_state never X")
  u_ovl_x_35 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (1'b1),
              .test_expr (slot_state));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_exclusive never X")
  u_ovl_x_36 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_exclusive));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_state_cachewritereq never X")
  u_ovl_x_37 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_state_cachewritereq));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_has_cache_data_priority_i never X")
  u_ovl_x_38 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_has_cache_data_priority_i));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_ccb_hz_seen never X")
  u_ovl_x_39 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_ccb_hz_seen));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "part_cache_read_required never X")
  u_ovl_x_40 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (part_cache_read_required));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "full_cache_read_required never X")
  u_ovl_x_41 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (full_cache_read_required));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_has_cleanunique_duty never X")
  u_ovl_x_42 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_has_cleanunique_duty));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_lf_can_merge never X")
  u_ovl_x_43 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_lf_can_merge));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_full never X")
  u_ovl_x_44 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_full));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_write_committed never X")
  u_ovl_x_45 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_write_committed));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "new_req_from_idle never X")
  u_ovl_x_46 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (1'b1),
              .test_expr (new_req_from_idle));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_emptying never X")
  u_ovl_x_47 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (1'b1),
              .test_expr (slot_emptying));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_state_en never X")
  u_ovl_x_48 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (1'b1),
              .test_expr (slot_state_en));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_bls_en never X")
  u_ovl_x_49 (.clk       (slot_clk),
              .reset_n   (reset_n),
              .qualifier (1'b1),
              .test_expr (slot_bls_en));
  
  assert_never_unknown #(`OVL_FATAL, 16, `OVL_ASSERT, "slot_data_en never X")
  u_ovl_x_50 (.clk       (slot_clk),
              .reset_n   (reset_n),
              .qualifier (1'b1),
              .test_expr (slot_data_en));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_way_en never X")
  u_ovl_x_51 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (1'b1),
              .test_expr (slot_way_en));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_migratory_en never X")
  u_ovl_x_52 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (1'b1),
              .test_expr (slot_migratory_en));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "ovl_slot_cleanunique_done_en never X")
  u_ovl_x_53 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (1'b1),
              .test_expr (ovl_slot_cleanunique_done_en));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "ccb_ev_hazard never X")
  u_ovl_x_54 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_valid),
              .test_expr (ccb_ev_hazard));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_valid never X")
  u_ovl_x_55 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (1'b1),
              .test_expr (slot_valid));
  
  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "slot_sameline never X")
  u_ovl_x_56 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_sameline));
  
  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "slot_same_dev_write never X")
  u_ovl_x_57 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_same_dev_write));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_load_sameline never X")
  u_ovl_x_58 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_load_sameline_seen));
  
  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "slots_load_sameline_seen never X")
  u_ovl_x_59 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr ((slots_load_sameline_seen & slot_sameline)));
  
  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "slots_state_cacheecc never X")
  u_ovl_x_60 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slots_state_cacheecc));
  
  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "slots_state_cleanunique_ack never X")
  u_ovl_x_61 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slots_state_cleanunique_ack));
  
  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "slots_state_cleanunique_resp never X")
  u_ovl_x_62 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slots_state_cleanunique_resp));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "ar_resp_excl_fail never X")
  u_ovl_x_63 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state_cleanunique_resp & ar_resp_valid),
              .test_expr (ar_resp_excl_fail));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "cp15_is_dsb never X")
  u_ovl_x_64 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (cp15_is_dsb));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "cp15_is_dc_maint never X")
  u_ovl_x_65 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (cp15_is_dc_maint));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_has_ar_priority_i never X")
  u_ovl_x_66 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_has_ar_priority_i));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "slot_ar_resp_valid_i never X")
  u_ovl_x_67 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (slot_ar_resp_valid_i));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "dvm_complete_i never X")
  u_ovl_x_68 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (dvm_complete_i));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "barrier_can_propagate never X")
  u_ovl_x_69 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (barrier_can_propagate));
  
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "propagate_barrier_i never X")
  u_ovl_x_70 (.clk       (clk),
              .reset_n   (reset_n),
              .qualifier (slot_state != `CA53_SLOT_IDLE),
              .test_expr (propagate_barrier_i));

`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53_stb_biu_defs.v"
`include "ca53stb_defs.v"
`undef CA53_UNDEFINE
/*END*/
