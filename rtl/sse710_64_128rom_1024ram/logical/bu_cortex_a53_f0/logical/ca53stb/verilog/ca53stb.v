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
// Abstract : STB (Store Buffer) Top Level
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// The STB holds stores once they have left the DCU's load store pipeline and
// have been committed by the DPU. From the STB, the store can request access
// to the cache RAMs via the DCU, request the BIU to start linefills, or
// request the BIU to pass write data to the SCU. The STB is capable of merging
// several store transactions into a single transaction if they are to the same
// quadword address and to normal memory.

`include "ca53stb_defs.v"
`include "ca53_stb_biu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53_biu_scu_defs.v"
`include "cortexa53params.v"

module ca53stb `CA53_STB_PARAM_DECL
 (

  //----------------------------------------------------------------------------
  // Clock and Reset
  //----------------------------------------------------------------------------

  input   wire             clk,
  input   wire             reset_n,
  input   wire             DFTSE,

  //----------------------------------------------------------------------------
  // DCU Interface
  //----------------------------------------------------------------------------

  output  wire      [4:0]  stb_slots_emptying_o,
  output  wire      [4:0]  stb_slots_dev_ng_o,
  output  wire      [4:0]  stb_slots_dsb_o,
  output  wire             stb_block_loads_dc1_o,
  input   wire             dcu_drain_entire_stb_i,
  input   wire      [4:0]  dcu_drain_slots_i,
  input   wire             dcu_ecc_data_err_m3_i,
  input   wire             dcu_ecc_tag_err_m2_i,
  input   wire             dcu_ecc_in_progress_i,
  input   wire             dcu_exclusive_monitor_i,
  output  wire             stb_cacheable_strex_done_o,
  output  wire             stb_strex_failed_o,
  input   wire             dcu_store_dc1_i,
  input   wire             dcu_valid_dc2_i,
  input   wire             dcu_store_dc2_i,
  input   wire     [39:3]  dcu_pa_dc2_i,
  input   wire             dcu_ns_dsc_dc2_i,
  input   wire      [7:0]  dcu_attrs_dc2_i,
  input   wire             dcu_leaving_dc2_i,
  output  wire      [4:0]  stb_can_merge_dc2_o,
  output  wire      [4:0]  stb_sameline_dc2_o,
  output  wire      [4:0]  stb_load_sameline_dc2_o,
  output  wire             stb_attr_mismatch_dc2_o,
  output  wire      [7:0]  stb_hit_dc2_o,
  output  wire     [63:0]  stb_data_dc2_o,
  input   wire             dcu_store_dc3_i,
  input   wire             dcu_stb_req_dc3_i,
  input   wire             dcu_stlr_dc3_i,
  input   wire      [4:0]  dcu_store_merge_dc3_i,
  input   wire      [4:0]  dcu_store_sameline_dc3_i,
  input   wire      [4:0]  dcu_load_sameline_dc3_i,
  input   wire     [39:0]  dcu_pa_dc3_i,
  input   wire             dcu_ns_dsc_dc3_i,
  input   wire             dcu_priv_dc3_i,
  input   wire             dcu_stb_exclusive_dc3_i,
  input   wire             dcu_store_cp15_dc3_i,
  input   wire             dcu_dvm_sync_needed_dc3_i,
  input   wire             dcu_store_dmb_dc3_i,
  input   wire             dcu_store_dsb_dc3_i,
  input   wire      [7:0]  dcu_stb_attrs_dc3_i,
  input   wire     [15:0]  dcu_store_bls_dc3_i,
  input   wire             dcu_store_last_dc3_i,
  input   wire             dcu_force_non_mergeable_dc3_i,
  output  wire             stb_force_non_mergeable_o,
  output  wire             stb_cache_tag_req_m0_o,
  output  wire             stb_cache_tag_wr_m0_o,
  output  wire      [3:0]  stb_cache_tag_way_m0_o,
  output  wire     [39:6]  stb_cache_tag_addr_m0_o,
  output  wire             stb_cache_tag_ns_dsc_m0_o,
  input   wire             dcu_stb_tag_has_priority_m0_i,
  input   wire             dcu_stb_tag_ack_m1_i,
  input   wire      [3:0]  dcu_stb_tag_hit_m2_i,
  input   wire             dcu_stb_tag_shared_m2_i,
  input   wire             dcu_stb_tag_migratory_m2_i,
  input   wire      [3:0]  dcu_stb_victim_way_m2_i,
  output  wire             stb_cache_data_req_m0_o,
  output  wire             stb_cache_data_wr_m0_o,
  output  wire     [13:4]  stb_cache_data_addr_m0_o,
  output  wire      [3:0]  stb_cache_data_way_m0_o,
  output  wire     [15:0]  stb_cache_data_bls_m0_o,
  output  wire      [7:0]  stb_cache_data_attrs_m0_o,
  output  wire             stb_cache_data_migratory_m0_o,
  input   wire             dcu_stb_data_has_priority_m0_i,
  input   wire             dcu_stb_data_ack_m1_i,
  output  wire    [127:0]  stb_cache_write_data_m0_o,
  input   wire    [127:0]  dcu_stb_read_data_m2_i,
  input   wire             dcu_ccb_req_valid_i,
  input   wire     [13:6]  dcu_ccb_index_i,
  input   wire      [3:0]  dcu_ccb_ways_i,
  output  wire             stb_block_ccb_o,
  output  wire             stb_defer_ccb_o,

  //----------------------------------------------------------------------------
  // BIU Interface
  //----------------------------------------------------------------------------

  output  wire      [4:0]  stb_slots_valid_o,
  output  wire     [39:0]  stb_slot0_addr_o,
  output  wire     [39:0]  stb_slot1_addr_o,
  output  wire     [39:0]  stb_slot2_addr_o,
  output  wire     [39:0]  stb_slot3_addr_o,
  output  wire     [39:0]  stb_slot4_addr_o,
  output  wire      [4:0]  stb_slots_ns_dsc_o,
  output  wire      [1:0]  stb_slot0_way_o,
  output  wire      [1:0]  stb_slot1_way_o,
  output  wire      [1:0]  stb_slot2_way_o,
  output  wire      [1:0]  stb_slot3_way_o,
  output  wire      [1:0]  stb_slot4_way_o,
  output  wire      [7:0]  stb_slot0_attrs_o,
  output  wire      [7:0]  stb_slot1_attrs_o,
  output  wire      [7:0]  stb_slot2_attrs_o,
  output  wire      [7:0]  stb_slot3_attrs_o,
  output  wire      [7:0]  stb_slot4_attrs_o,
  input   wire      [4:0]  biu_lf_hazard_i,
  input   wire      [4:0]  biu_lf_real_hazard_i,
  input   wire      [4:0]  biu_lf_hazard_migratory_i,
  input   wire      [1:0]  biu_lf_hazard_way_slot0_i,
  input   wire      [1:0]  biu_lf_hazard_way_slot1_i,
  input   wire      [1:0]  biu_lf_hazard_way_slot2_i,
  input   wire      [1:0]  biu_lf_hazard_way_slot3_i,
  input   wire      [1:0]  biu_lf_hazard_way_slot4_i,
  input   wire      [4:0]  biu_lf_serialized_i,
  input   wire      [4:0]  biu_ev_hazard_i,
  output  wire             stb_lf_active_o,
  output  wire      [4:0]  stb_lf_req_o,
  output  wire      [4:0]  stb_lf_merge_o,
  output  wire      [4:0]  stb_lf_earliest_slot_o,
  input   wire      [4:0]  biu_lf_can_merge_i,
  output  wire      [4:0]  stb_slot_cachewrite_m1_o,
  output  wire             stb_biu_write_req_o,
  output  wire      [3:0]  stb_biu_write_l2dbid_o,
  output  wire      [1:0]  stb_biu_write_chunk_o,
  output  wire    [127:0]  stb_biu_write_data_o,
  output  wire     [15:0]  stb_biu_write_bls_o,
  output  wire             stb_biu_write_last_o,
  input   wire             biu_stb_write_accept_i,
  output  wire             stb_biu_write_req_active_o,
  input   wire             biu_read_alloc_mode_i,
  output  wire             stb_ar_early_req_o,
  output  wire             stb_ar_req_o,
  output  wire      [4:0]  stb_ar_id_o,
  output  wire      [1:0]  stb_ar_way_o,
  output  wire      [7:0]  stb_ar_type_o,
  output  wire     [39:0]  stb_ar_addr_o,
  output  wire             stb_ar_ns_dsc_o,
  output  wire      [7:0]  stb_ar_attrs_o,
  output  wire             stb_ar_priv_o,
  output  wire             stb_ar_excl_o,
  output  wire     [15:0]  stb_ar_asid_o,
  output  wire      [7:0]  stb_ar_vmid_o,
  output  wire     [24:0]  stb_ar_va_o,
  input   wire             biu_stb_ar_ack_i,
  input   wire             biu_stb_ar_resp_valid_i,
  input   wire      [1:0]  biu_stb_ar_resp_i,
  input   wire      [4:0]  biu_stb_ar_resp_id_i,
  input   wire      [3:0]  biu_stb_ar_resp_l2dbid_i,
  input   wire             biu_dirty_lf_in_progress_i,
  input   wire             biu_excl_lf_in_progress_i,

  //----------------------------------------------------------------------------
  // DPU Interface
  //----------------------------------------------------------------------------

  output  wire             stb_evnt_stb_stall_o,
  input   wire             dpu_store_iss_i,
  input   wire             dpu_kill_wr_i,
  input   wire    [127:0]  dpu_st_data_wr_i,
  input   wire             dpu_disable_dmb_i,

  //----------------------------------------------------------------------------
  // GOV Interface
  //----------------------------------------------------------------------------

  input   wire             gov_wfx_drain_req_i,
  output  wire             stb_wfx_ready_o,

  //----------------------------------------------------------------------------
  // SCU Interface
  //----------------------------------------------------------------------------

  input   wire             scu_dvm_complete_i,
  input   wire             scu_drain_stb_i,

  //----------------------------------------------------------------------------
  // RAM Interface
  //----------------------------------------------------------------------------

  input   wire      [2:0]  dc_size_i);

  //----------------------------------------------------------------------------
  // Flops
  //----------------------------------------------------------------------------

  reg         dev_bursting;             // Record if we are in the middle of receiving
                                        // a device burst from the DCU.

  reg         dev_delay_ar_req;         // Record if a device burst from the DCU
                                        // needs to delay making an AR request.
  
  reg [1:0]   tag_hit_shared_m3;        // The result of the previous cycle's lookup.

  reg         tag_ecc_err_m3_reg;       // The ECC result of the previous
                                        // cycle's lookup.

  reg [9:0]   cycle_count;              // Count when slots are active so that they can
                                        // be forced to drain after a finite period.

  reg         dvm_sync_needed;          // Record when other DVM messages have been
                                        // sent since the last DVM sync.

  reg         propagate_barrier;        // Record whether a barrier needs to propagate
                                        // to the BIU.
  
  reg         clk_enable;               // Enable for intermediate clock gate.

  reg [4:0]   slots_clk_enable;         // Enable for intermediate clock gate.

  reg         stb_evnt_stb_stall;       // Event signal registered for timing.

  reg [4:0]   cache_data_slot_select;   // Slot select for cache data priority.

  reg [4:0]   ar_slot_select;           // Slot select for AR priority.

  reg [3:0]   dcu_stb_read_wls_m1;      // M1 version of cache read word strobes.

  reg [3:0]   dcu_stb_read_wls_m2;      // M2 version of cache read word strobes.

  reg         dvm_complete;             // Registered version of scu_dvm_complete_i.

  reg         scu_drain_stb;            // Registered version of scu_drain_stb_i.

  reg         wfx_drain_req;            // Registered version of gov_wfx_drain_req_i.

  reg         stb_ar_early_req_non_m3;  // STB might make a request this cycle.

  reg         stb_force_non_mergeable;  // STB wants the DCU to prevent further
                                        // merging into current slots/bursts.


  //----------------------------------------------------------------------------
  // Wires
  //----------------------------------------------------------------------------

  wire         slot0_clk;
  wire         slot1_clk;
  wire         slot2_clk;
  wire         slot3_clk;
  wire         slot4_clk;

  wire         slot0_new_req_dc3;
  wire         slot1_new_req_dc3;
  wire         slot2_new_req_dc3;
  wire         slot3_new_req_dc3;
  wire         slot4_new_req_dc3;

  wire         slot0_valid;
  wire         slot1_valid;
  wire         slot2_valid;
  wire         slot3_valid;
  wire         slot4_valid;

  wire         slot0_emptying;
  wire         slot1_emptying;
  wire         slot2_emptying;
  wire         slot3_emptying;
  wire         slot4_emptying;

  wire [7:0]   slot0_attrs;
  wire [7:0]   slot1_attrs;
  wire [7:0]   slot2_attrs;
  wire [7:0]   slot3_attrs;
  wire [7:0]   slot4_attrs;

  wire         slot0_migratory;
  wire         slot1_migratory;
  wire         slot2_migratory;
  wire         slot3_migratory;
  wire         slot4_migratory;

  wire [39:0]  slot0_addr;
  wire [39:0]  slot1_addr;
  wire [39:0]  slot2_addr;
  wire [39:0]  slot3_addr;
  wire [39:0]  slot4_addr;

  wire [39:0]  slot0_ar_addr;
  wire [39:0]  slot1_ar_addr;
  wire [39:0]  slot2_ar_addr;
  wire [39:0]  slot3_ar_addr;
  wire [39:0]  slot4_ar_addr;

  wire         slot0_ns;
  wire         slot1_ns;
  wire         slot2_ns;
  wire         slot3_ns;
  wire         slot4_ns;

  wire         slot0_ar_ns;
  wire         slot1_ar_ns;
  wire         slot2_ar_ns;
  wire         slot3_ar_ns;
  wire         slot4_ar_ns;

  wire [127:0] slot0_data;
  wire [127:0] slot1_data;
  wire [127:0] slot2_data;
  wire [127:0] slot3_data;
  wire [127:0] slot4_data;

  wire [15:0]  slot0_cache_bls;
  wire [15:0]  slot1_cache_bls;
  wire [15:0]  slot2_cache_bls;
  wire [15:0]  slot3_cache_bls;
  wire [15:0]  slot4_cache_bls;

  wire [127:0] slot0_write_data;
  wire [127:0] slot1_write_data;
  wire [127:0] slot2_write_data;
  wire [127:0] slot3_write_data;
  wire [127:0] slot4_write_data;

  wire [15:0]  slot0_write_bls;
  wire [15:0]  slot1_write_bls;
  wire [15:0]  slot2_write_bls;
  wire [15:0]  slot3_write_bls;
  wire [15:0]  slot4_write_bls;

  wire [1:0]   slot0_write_chunk;
  wire [1:0]   slot1_write_chunk;
  wire [1:0]   slot2_write_chunk;
  wire [1:0]   slot3_write_chunk;
  wire [1:0]   slot4_write_chunk;
  
  wire         slot0_write_last;
  wire         slot1_write_last;
  wire         slot2_write_last;
  wire         slot3_write_last;
  wire         slot4_write_last;

  wire         slot0_ar_priv;
  wire         slot1_ar_priv;
  wire         slot2_ar_priv;
  wire         slot3_ar_priv;
  wire         slot4_ar_priv;

  wire         slot0_mergeable;
  wire         slot1_mergeable;
  wire         slot2_mergeable;
  wire         slot3_mergeable;
  wire         slot4_mergeable;

  wire         slot0_barriered;
  wire         slot1_barriered;
  wire         slot2_barriered;
  wire         slot3_barriered;
  wire         slot4_barriered;

  wire         slot0_ev_hazard;
  wire         slot1_ev_hazard;
  wire         slot2_ev_hazard;
  wire         slot3_ev_hazard;
  wire         slot4_ev_hazard;

  wire         slot0_ev_hz_seen;
  wire         slot1_ev_hz_seen;
  wire         slot2_ev_hz_seen;
  wire         slot3_ev_hz_seen;
  wire         slot4_ev_hz_seen;

  wire         slot0_biu_lf_hazard;
  wire         slot1_biu_lf_hazard;
  wire         slot2_biu_lf_hazard;
  wire         slot3_biu_lf_hazard;
  wire         slot4_biu_lf_hazard;

  wire         slot0_biu_lf_real_hazard;
  wire         slot1_biu_lf_real_hazard;
  wire         slot2_biu_lf_real_hazard;
  wire         slot3_biu_lf_real_hazard;
  wire         slot4_biu_lf_real_hazard;

  wire         slot0_biu_lf_hazard_migratory;
  wire         slot1_biu_lf_hazard_migratory;
  wire         slot2_biu_lf_hazard_migratory;
  wire         slot3_biu_lf_hazard_migratory;
  wire         slot4_biu_lf_hazard_migratory;

  wire         slot0_biu_lf_serialized;
  wire         slot1_biu_lf_serialized;
  wire         slot2_biu_lf_serialized;
  wire         slot3_biu_lf_serialized;
  wire         slot4_biu_lf_serialized;

  wire         slot0_biu_lf_can_merge;
  wire         slot1_biu_lf_can_merge;
  wire         slot2_biu_lf_can_merge;
  wire         slot3_biu_lf_can_merge;
  wire         slot4_biu_lf_can_merge;
  
  wire         slot0_dcu_store_sameline_dc3;
  wire         slot1_dcu_store_sameline_dc3;
  wire         slot2_dcu_store_sameline_dc3;
  wire         slot3_dcu_store_sameline_dc3;
  wire         slot4_dcu_store_sameline_dc3;

  wire         slot0_state_biureq;
  wire         slot1_state_biureq;
  wire         slot2_state_biureq;
  wire         slot3_state_biureq;
  wire         slot4_state_biureq;

  wire         slot0_state_biuack;
  wire         slot1_state_biuack;
  wire         slot2_state_biuack;
  wire         slot3_state_biuack;
  wire         slot4_state_biuack;

  wire         slot0_state_biuresp;
  wire         slot1_state_biuresp;
  wire         slot2_state_biuresp;
  wire         slot3_state_biuresp;
  wire         slot4_state_biuresp;

  wire         slot0_state_biudata;
  wire         slot1_state_biudata;
  wire         slot2_state_biudata;
  wire         slot3_state_biudata;
  wire         slot4_state_biudata;

  wire         slot0_state_lfreq;
  wire         slot1_state_lfreq;
  wire         slot2_state_lfreq;
  wire         slot3_state_lfreq;
  wire         slot4_state_lfreq;

  wire         slot0_state_lookupreq;
  wire         slot1_state_lookupreq;
  wire         slot2_state_lookupreq;
  wire         slot3_state_lookupreq;
  wire         slot4_state_lookupreq;

  wire         slot0_state_lookupm1;
  wire         slot1_state_lookupm1;
  wire         slot2_state_lookupm1;
  wire         slot3_state_lookupm1;
  wire         slot4_state_lookupm1;

  wire         slot0_state_lookupm2;
  wire         slot1_state_lookupm2;
  wire         slot2_state_lookupm2;
  wire         slot3_state_lookupm2;
  wire         slot4_state_lookupm2;

  wire         slot0_state_special;
  wire         slot1_state_special;
  wire         slot2_state_special;
  wire         slot3_state_special;
  wire         slot4_state_special;

  wire         slot0_state_cleanunique_req;
  wire         slot1_state_cleanunique_req;
  wire         slot2_state_cleanunique_req;
  wire         slot3_state_cleanunique_req;
  wire         slot4_state_cleanunique_req;

  wire         slot0_state_cleanunique_ack;
  wire         slot1_state_cleanunique_ack;
  wire         slot2_state_cleanunique_ack;
  wire         slot3_state_cleanunique_ack;
  wire         slot4_state_cleanunique_ack;

  wire         slot0_state_cleanunique_resp;
  wire         slot1_state_cleanunique_resp;
  wire         slot2_state_cleanunique_resp;
  wire         slot3_state_cleanunique_resp;
  wire         slot4_state_cleanunique_resp;

  wire         slot0_state_barrier_ack;
  wire         slot1_state_barrier_ack;
  wire         slot2_state_barrier_ack;
  wire         slot3_state_barrier_ack;
  wire         slot4_state_barrier_ack;

  wire         slot0_state_tagwrite;
  wire         slot1_state_tagwrite;
  wire         slot2_state_tagwrite;
  wire         slot3_state_tagwrite;
  wire         slot4_state_tagwrite;

  wire         slot0_state_cachemerge;
  wire         slot1_state_cachemerge;
  wire         slot2_state_cachemerge;
  wire         slot3_state_cachemerge;
  wire         slot4_state_cachemerge;

  wire         slot0_state_cachereadm0;
  wire         slot1_state_cachereadm0;
  wire         slot2_state_cachereadm0;
  wire         slot3_state_cachereadm0;
  wire         slot4_state_cachereadm0;

  wire         slot0_state_cachereadm1;
  wire         slot1_state_cachereadm1;
  wire         slot2_state_cachereadm1;
  wire         slot3_state_cachereadm1;
  wire         slot4_state_cachereadm1;

  wire         slot0_state_cachereadm2;
  wire         slot1_state_cachereadm2;
  wire         slot2_state_cachereadm2;
  wire         slot3_state_cachereadm2;
  wire         slot4_state_cachereadm2;

  wire         slot0_state_cacheecc;
  wire         slot1_state_cacheecc;
  wire         slot2_state_cacheecc;
  wire         slot3_state_cacheecc;
  wire         slot4_state_cacheecc;

  wire         slot0_state_cachewritereq;
  wire         slot1_state_cachewritereq;
  wire         slot2_state_cachewritereq;
  wire         slot3_state_cachewritereq;
  wire         slot4_state_cachewritereq;

  wire         slot0_state_cachewritem1;
  wire         slot1_state_cachewritem1;
  wire         slot2_state_cachewritem1;
  wire         slot3_state_cachewritem1;
  wire         slot4_state_cachewritem1;

  wire         slot0_state_biumerge;
  wire         slot1_state_biumerge;
  wire         slot2_state_biumerge;
  wire         slot3_state_biumerge;
  wire         slot4_state_biumerge;

  wire         slot0_state_cp15resp;
  wire         slot1_state_cp15resp;
  wire         slot2_state_cp15resp;
  wire         slot3_state_cp15resp;
  wire         slot4_state_cp15resp;

  wire         slot0_write_sync_cmo_ack;
  wire         slot1_write_sync_cmo_ack;
  wire         slot2_write_sync_cmo_ack;
  wire         slot3_write_sync_cmo_ack;
  wire         slot4_write_sync_cmo_ack;

  wire         slot0_ar_excl;
  wire         slot1_ar_excl;
  wire         slot2_ar_excl;
  wire         slot3_ar_excl;
  wire         slot4_ar_excl;

  wire [7:0]   slot0_type;
  wire [7:0]   slot1_type;
  wire [7:0]   slot2_type;
  wire [7:0]   slot3_type;
  wire [7:0]   slot4_type;

  wire         slot0_sameline_dc2;
  wire         slot1_sameline_dc2;
  wire         slot2_sameline_dc2;
  wire         slot3_sameline_dc2;
  wire         slot4_sameline_dc2;

  wire         slot0_load_sameline_dc2;
  wire         slot1_load_sameline_dc2;
  wire         slot2_load_sameline_dc2;
  wire         slot3_load_sameline_dc2;
  wire         slot4_load_sameline_dc2;

  wire         slot0_load_sameline_seen;
  wire         slot1_load_sameline_seen;
  wire         slot2_load_sameline_seen;
  wire         slot3_load_sameline_seen;
  wire         slot4_load_sameline_seen;
  
  wire         slot0_load_sameline;
  wire         slot1_load_sameline;
  wire         slot2_load_sameline;
  wire         slot3_load_sameline;
  wire         slot4_load_sameline;
  
  wire         slot0_can_merge_dc2;
  wire         slot1_can_merge_dc2;
  wire         slot2_can_merge_dc2;
  wire         slot3_can_merge_dc2;
  wire         slot4_can_merge_dc2;

  wire         slot0_attr_mismatch_dc2;
  wire         slot1_attr_mismatch_dc2;
  wire         slot2_attr_mismatch_dc2;
  wire         slot3_attr_mismatch_dc2;
  wire         slot4_attr_mismatch_dc2;

  wire [15:0]  slot0_hit_dc2;
  wire [15:0]  slot1_hit_dc2;
  wire [15:0]  slot2_hit_dc2;
  wire [15:0]  slot3_hit_dc2;
  wire [15:0]  slot4_hit_dc2;

  wire [15:0]  slot0_real_hit_dc2;
  wire [15:0]  slot1_real_hit_dc2;
  wire [15:0]  slot2_real_hit_dc2;
  wire [15:0]  slot3_real_hit_dc2;
  wire [15:0]  slot4_real_hit_dc2;

  wire [63:0]  slot0_hit_data_dc2_hi;
  wire [63:0]  slot1_hit_data_dc2_hi;
  wire [63:0]  slot2_hit_data_dc2_hi;
  wire [63:0]  slot3_hit_data_dc2_hi;
  wire [63:0]  slot4_hit_data_dc2_hi;

  wire [63:0]  slot0_hit_data_dc2_lo;
  wire [63:0]  slot1_hit_data_dc2_lo;
  wire [63:0]  slot2_hit_data_dc2_lo;
  wire [63:0]  slot3_hit_data_dc2_lo;
  wire [63:0]  slot4_hit_data_dc2_lo;

  wire         slot0_block_ccb;
  wire         slot1_block_ccb;
  wire         slot2_block_ccb;
  wire         slot3_block_ccb;
  wire         slot4_block_ccb;

  wire         slot0_force_drain;
  wire         slot1_force_drain;
  wire         slot2_force_drain;
  wire         slot3_force_drain;
  wire         slot4_force_drain;

  wire         slot0_force_drain_biudata;
  wire         slot1_force_drain_biudata;
  wire         slot2_force_drain_biudata;
  wire         slot3_force_drain_biudata;
  wire         slot4_force_drain_biudata;

  wire         slot0_dsb;
  wire         slot1_dsb;
  wire         slot2_dsb;
  wire         slot3_dsb;
  wire         slot4_dsb;

  wire         slot0_cp15;
  wire         slot1_cp15;
  wire         slot2_cp15;
  wire         slot3_cp15;
  wire         slot4_cp15;

  wire [15:0]  slot0_cp15_asid;
  wire [15:0]  slot1_cp15_asid;
  wire [15:0]  slot2_cp15_asid;
  wire [15:0]  slot3_cp15_asid;
  wire [15:0]  slot4_cp15_asid;

  wire [7:0]   slot0_cp15_vmid;
  wire [7:0]   slot1_cp15_vmid;
  wire [7:0]   slot2_cp15_vmid;
  wire [7:0]   slot3_cp15_vmid;
  wire [7:0]   slot4_cp15_vmid;

  wire [24:0]  slot0_cp15_va;
  wire [24:0]  slot1_cp15_va;
  wire [24:0]  slot2_cp15_va;
  wire [24:0]  slot3_cp15_va;
  wire [24:0]  slot4_cp15_va;

  wire         slot0_wants_write_addr_priority;
  wire         slot1_wants_write_addr_priority;
  wire         slot2_wants_write_addr_priority;
  wire         slot3_wants_write_addr_priority;
  wire         slot4_wants_write_addr_priority;

  wire         slot0_has_write_addr_priority;
  wire         slot1_has_write_addr_priority;
  wire         slot2_has_write_addr_priority;
  wire         slot3_has_write_addr_priority;
  wire         slot4_has_write_addr_priority;

  wire         slot0_wants_ar_priority;
  wire         slot1_wants_ar_priority;
  wire         slot2_wants_ar_priority;
  wire         slot3_wants_ar_priority;
  wire         slot4_wants_ar_priority;

  wire         slot0_might_want_ar_priority;
  wire         slot1_might_want_ar_priority;
  wire         slot2_might_want_ar_priority;
  wire         slot3_might_want_ar_priority;
  wire         slot4_might_want_ar_priority;

  wire         slot0_ar_resp_valid;
  wire         slot1_ar_resp_valid;
  wire         slot2_ar_resp_valid;
  wire         slot3_ar_resp_valid;
  wire         slot4_ar_resp_valid;

  wire         slot0_wants_lookup_priority;
  wire         slot1_wants_lookup_priority;
  wire         slot2_wants_lookup_priority;
  wire         slot3_wants_lookup_priority;
  wire         slot4_wants_lookup_priority;

  wire         slot0_has_lookup_priority;
  wire         slot1_has_lookup_priority;
  wire         slot2_has_lookup_priority;
  wire         slot3_has_lookup_priority;
  wire         slot4_has_lookup_priority;

  wire         slot0_might_want_cache_data_priority;
  wire         slot1_might_want_cache_data_priority;
  wire         slot2_might_want_cache_data_priority;
  wire         slot3_might_want_cache_data_priority;
  wire         slot4_might_want_cache_data_priority;

  wire         slot0_wants_cache_data_priority;
  wire         slot1_wants_cache_data_priority;
  wire         slot2_wants_cache_data_priority;
  wire         slot3_wants_cache_data_priority;
  wire         slot4_wants_cache_data_priority;

  wire         slot0_has_cache_data_priority;
  wire         slot1_has_cache_data_priority;
  wire         slot2_has_cache_data_priority;
  wire         slot3_has_cache_data_priority;
  wire         slot4_has_cache_data_priority;

  wire         slot0_wants_cleanunique_priority;
  wire         slot1_wants_cleanunique_priority;
  wire         slot2_wants_cleanunique_priority;
  wire         slot3_wants_cleanunique_priority;
  wire         slot4_wants_cleanunique_priority;

  wire         slot0_has_cleanunique_priority;
  wire         slot1_has_cleanunique_priority;
  wire         slot2_has_cleanunique_priority;
  wire         slot3_has_cleanunique_priority;
  wire         slot4_has_cleanunique_priority;

  wire         slot0_has_cleanunique_duty;
  wire         slot1_has_cleanunique_duty;
  wire         slot2_has_cleanunique_duty;
  wire         slot3_has_cleanunique_duty;
  wire         slot4_has_cleanunique_duty;

  wire         slot0_lf_active;
  wire         slot1_lf_active;
  wire         slot2_lf_active;
  wire         slot3_lf_active;
  wire         slot4_lf_active;

  wire         slot0_lf_req;
  wire         slot1_lf_req;
  wire         slot2_lf_req;
  wire         slot3_lf_req;
  wire         slot4_lf_req;

  wire         slot0_lf_merge;
  wire         slot1_lf_merge;
  wire         slot2_lf_merge;
  wire         slot3_lf_merge;
  wire         slot4_lf_merge;

  wire         slot0_lf_hz_capture;
  wire         slot1_lf_hz_capture;
  wire         slot2_lf_hz_capture;
  wire         slot3_lf_hz_capture;
  wire         slot4_lf_hz_capture;

  wire         slot0_lf_hz_seen;
  wire         slot1_lf_hz_seen;
  wire         slot2_lf_hz_seen;
  wire         slot3_lf_hz_seen;
  wire         slot4_lf_hz_seen;

  wire         slot0_coherent;
  wire         slot1_coherent;
  wire         slot2_coherent;
  wire         slot3_coherent;
  wire         slot4_coherent;

  wire         slot0_excl_fail;
  wire         slot1_excl_fail;
  wire         slot2_excl_fail;
  wire         slot3_excl_fail;
  wire         slot4_excl_fail;

  wire         slot0_excl_done;
  wire         slot1_excl_done;
  wire         slot2_excl_done;
  wire         slot3_excl_done;
  wire         slot4_excl_done;

  wire [3:0]   slot0_way_onehot;
  wire [3:0]   slot1_way_onehot;
  wire [3:0]   slot2_way_onehot;
  wire [3:0]   slot3_way_onehot;
  wire [3:0]   slot4_way_onehot;

  wire [1:0]   slot0_way;
  wire [1:0]   slot1_way;
  wire [1:0]   slot2_way;
  wire [1:0]   slot3_way;
  wire [1:0]   slot4_way;

  wire [1:0]   slot0_ar_way;
  wire [1:0]   slot1_ar_way;
  wire [1:0]   slot2_ar_way;
  wire [1:0]   slot3_ar_way;
  wire [1:0]   slot4_ar_way;

  wire [3:0]   slot0_l2dbid;
  wire [3:0]   slot1_l2dbid;
  wire [3:0]   slot2_l2dbid;
  wire [3:0]   slot3_l2dbid;
  wire [3:0]   slot4_l2dbid;

  wire         slot0_no_alloc_on_miss;
  wire         slot1_no_alloc_on_miss;
  wire         slot2_no_alloc_on_miss;
  wire         slot3_no_alloc_on_miss;
  wire         slot4_no_alloc_on_miss;

  wire [2:0]   slot0_sameline_beat_count;
  wire [2:0]   slot1_sameline_beat_count;
  wire [2:0]   slot2_sameline_beat_count;
  wire [2:0]   slot3_sameline_beat_count;
  wire [2:0]   slot4_sameline_beat_count;

  wire         slot0_biu_write_req_active;
  wire         slot1_biu_write_req_active;
  wire         slot2_biu_write_req_active;
  wire         slot3_biu_write_req_active;
  wire         slot4_biu_write_req_active;

  wire         slot0_wants_tagwrite_priority;
  wire         slot1_wants_tagwrite_priority;
  wire         slot2_wants_tagwrite_priority;
  wire         slot3_wants_tagwrite_priority;
  wire         slot4_wants_tagwrite_priority;

  wire         slot0_has_tagwrite_priority;
  wire         slot1_has_tagwrite_priority;
  wire         slot2_has_tagwrite_priority;
  wire         slot3_has_tagwrite_priority;
  wire         slot4_has_tagwrite_priority;

  wire [3:0]   slot0_earlier;
  wire [3:0]   slot1_earlier;
  wire [3:0]   slot2_earlier;
  wire [3:0]   slot3_earlier;
  wire [3:0]   slot4_earlier;

  wire [3:0]   slot0_earlier_lf;
  wire [3:0]   slot1_earlier_lf;
  wire [3:0]   slot2_earlier_lf;
  wire [3:0]   slot3_earlier_lf;
  wire [3:0]   slot4_earlier_lf;

  wire         slot0_block_loads_dc1;
  wire         slot1_block_loads_dc1;
  wire         slot2_block_loads_dc1;
  wire         slot3_block_loads_dc1;
  wire         slot4_block_loads_dc1;

  wire         slot0_has_ar_priority;
  wire         slot1_has_ar_priority;
  wire         slot2_has_ar_priority;
  wire         slot3_has_ar_priority;
  wire         slot4_has_ar_priority;

  wire         slot0_already_has_ar_priority;
  wire         slot1_already_has_ar_priority;
  wire         slot2_already_has_ar_priority;
  wire         slot3_already_has_ar_priority;
  wire         slot4_already_has_ar_priority;

  wire         slot0_ar_suppress;
  wire         slot1_ar_suppress;
  wire         slot2_ar_suppress;
  wire         slot3_ar_suppress;
  wire         slot4_ar_suppress;

  wire         slot0_might_req;
  wire         slot1_might_req;
  wire         slot2_might_req;
  wire         slot3_might_req;
  wire         slot4_might_req;

  wire         slot0_wants_write_data_priority;
  wire         slot1_wants_write_data_priority;
  wire         slot2_wants_write_data_priority;
  wire         slot3_wants_write_data_priority;
  wire         slot4_wants_write_data_priority;

  wire         slot0_has_write_data_priority;
  wire         slot1_has_write_data_priority;
  wire         slot2_has_write_data_priority;
  wire         slot3_has_write_data_priority;
  wire         slot4_has_write_data_priority;

  wire         slot0_write_data_suppress;
  wire         slot1_write_data_suppress;
  wire         slot2_write_data_suppress;
  wire         slot3_write_data_suppress;
  wire         slot4_write_data_suppress;

  wire         slot0_write_accept;
  wire         slot1_write_accept;
  wire         slot2_write_accept;
  wire         slot3_write_accept;
  wire         slot4_write_accept;

  wire         slot0_force_non_mergeable;
  wire         slot1_force_non_mergeable;
  wire         slot2_force_non_mergeable;
  wire         slot3_force_non_mergeable;
  wire         slot4_force_non_mergeable;
  
  wire         slot0_more_dev_expected;
  wire         slot1_more_dev_expected;
  wire         slot2_more_dev_expected;
  wire         slot3_more_dev_expected;
  wire         slot4_more_dev_expected;

  wire [127:0] slot0_real_bit_hit_dc2;
  wire [127:0] slot1_real_bit_hit_dc2;
  wire [127:0] slot2_real_bit_hit_dc2;
  wire [127:0] slot3_real_bit_hit_dc2;
  wire [127:0] slot4_real_bit_hit_dc2;

  wire [4:0]   slots_lowest_idle;
  wire [4:0]   slots_already_have_ar_priority;
  wire [4:0]   slots_ar_suppress;
  wire [4:0]   slots_might_want_ar_priority;
  wire [4:0]   slots_might_want_ar_priority_earliest;
  wire [4:0]   slots_want_ar_priority;
  wire [4:0]   slots_want_ar_priority_earliest;
  wire [4:0]   next_ar_slot_select;
  wire         ar_slot_select_en;
  wire         stb_ar_req;

  wire [4:0]   slots_state_lookupm2;
  wire [4:0]   slots_state_cachemerge;
  wire [4:0]   slots_state_biumerge;
  wire [4:0]   slots_state_cachewritem1;
  wire [4:0]   slots_valid;
  wire [4:0]   slots_coherent;
  wire [4:0]   slots_emptying;
  wire [4:0]   slots_force_non_mergeable;

  wire         stb_biu_write_req;

  wire [4:0]   earliest_slot_might_want_cache_data_priority;
  wire [4:0]   earliest_slot_wanting_cache_data_priority;
  wire [4:0]   earliest_slot_lookupm2;
  wire [4:0]   earliest_coherent_slot;
  wire [4:0]   slots_want_cache_data_priority;
  wire [4:0]   next_cache_data_slot_select;
  wire         cache_data_slot_select_en;
  wire         stb_cache_data_req_m0;

  wire         next_dev_bursting;
  wire         next_dev_delay_ar_req;
  wire [2:0]   num_stores;
  wire         stb_attr_mismatch_dc2;
  wire [4:0]   stb_can_merge_dc2;
  wire [4:0]   tag_sel;
  wire         drain_one_slot;
  wire [1:0]   next_tag_hit_shared_m3;
  wire         any_slot_has_tagwrite_priority;
  wire [39:0]  stb_ar_addr;
  wire         cycle_count_incr;
  wire         cycle_count_en;
  wire [9:0]   next_cycle_count;
  wire         stb_cycle_count_127;
  wire         stb_cycle_count_1023;
  wire         next_dvm_sync_needed;
  wire         dvm_sync_needed_en;
  wire         next_stb_evnt_stb_stall;
  wire         next_clk_enable;
  wire         clk_stb;
  wire [4:0]   next_slots_clk_enable;
  wire [2:0]   num_slots_empty;
  wire         too_many_slots_cachemerge;
  wire         next_tag_ecc_err_m3;
  wire         tag_ecc_err_m3_en;
  wire         tag_ecc_err_m3;
  wire         dcu_stb_mergeable_dc3;
  wire [15:0]  stb_cache_data_bls_m0;
  wire         dcu_stb_read_wls_m1_en;
  wire [3:0]   next_dcu_stb_read_wls_m1;
  wire         propagate_barrier_en;
  wire         next_propagate_barrier;
  wire         stb_en;
  wire [4:0]   next_slots_valid;
  wire [4:0]   slots_new_req_dc3;
  wire [4:0]   slots_state_cachereadm1;
  wire [4:0]   dcu_store_merge_dc3_other_slot;
  wire [4:0]   next_slots_lowest_idle;
  wire         next_stb_ar_early_req_non_m3;
  wire         stb_ar_early_req_m3;
  wire         next_stb_force_non_mergeable;
  

  // ---------------------------------------------------------------------------
  // Intermediate clock gates
  // ---------------------------------------------------------------------------

  // Avoid clocking some parts of the STB when there is no possibility of them
  // being updated.
  assign next_clk_enable = |slots_state_cachereadm1 |
                           dcu_store_dc3_i |
                           (dcu_store_dc2_i & dcu_leaving_dc2_i);

  ca53_cell_inter_clkgate u_inter_clkgate_stb (.clk_i         (clk),
                                               .clk_enable_i  (clk_enable),
                                               .clk_senable_i (DFTSE),
                                               .clk_gated_o   (clk_stb));

  assign slots_state_cachereadm1 = {slot4_state_cachereadm1,
                                    slot3_state_cachereadm1,
                                    slot2_state_cachereadm1,
                                    slot1_state_cachereadm1,
                                    slot0_state_cachereadm1};

  assign slots_new_req_dc3 = {slot4_new_req_dc3,
                              slot3_new_req_dc3,
                              slot2_new_req_dc3,
                              slot1_new_req_dc3,
                              slot0_new_req_dc3};
  
  assign next_slots_valid = slots_new_req_dc3 | (slots_valid & ~slots_emptying);
  
  assign next_slots_lowest_idle = { next_slots_valid[0] &  next_slots_valid[1] &  next_slots_valid[2] &  next_slots_valid[3] & ~next_slots_valid[4],
                                    next_slots_valid[0] &  next_slots_valid[1] &  next_slots_valid[2] & ~next_slots_valid[3],
                                    next_slots_valid[0] &  next_slots_valid[1] & ~next_slots_valid[2],
                                    next_slots_valid[0] & ~next_slots_valid[1],
                                   ~next_slots_valid[0]};

  assign dcu_store_merge_dc3_other_slot = {                              (|dcu_store_merge_dc3_i[3:0]),
                                            dcu_store_merge_dc3_i[4]   | (|dcu_store_merge_dc3_i[2:0]),
                                           |dcu_store_merge_dc3_i[4:3] | (|dcu_store_merge_dc3_i[1:0]),
                                           |dcu_store_merge_dc3_i[4:2] |   dcu_store_merge_dc3_i[0],
                                           |dcu_store_merge_dc3_i[4:1]};

  assign next_slots_clk_enable = // Slot receiving read data
                                 slots_state_cachereadm1 |
                                 // Slot receiving merge data
                                 (slots_valid &
                                  (({5{dcu_store_dc3_i & ~dcu_stb_req_dc3_i}} & dcu_store_merge_dc3_i) |
                                   ({5{dcu_store_dc2_i & dcu_leaving_dc2_i}} & stb_can_merge_dc2))) |
                                 // Slot activating
                                 // (might be followed by a merge)
                                 ({5{dcu_store_dc2_i & dcu_leaving_dc2_i}} & slots_new_req_dc3) |
                                 // Slot might activate
                                 (next_slots_lowest_idle &
                                  (({5{dcu_store_dc3_i}} & ~dcu_store_merge_dc3_other_slot) |
                                   ({5{dcu_store_dc2_i & dcu_leaving_dc2_i}})));

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    clk_enable <= 1'b0;
    slots_clk_enable <= 5'b00000;
  end else begin
    clk_enable <= next_clk_enable;
    slots_clk_enable <= next_slots_clk_enable;
  end

  ca53_cell_inter_clkgate u_inter_clkgate_slot0 (.clk_i         (clk),
                                                 .clk_enable_i  (slots_clk_enable[0]),
                                                 .clk_senable_i (DFTSE),
                                                 .clk_gated_o   (slot0_clk));

  ca53_cell_inter_clkgate u_inter_clkgate_slot1 (.clk_i         (clk),
                                                 .clk_enable_i  (slots_clk_enable[1]),
                                                 .clk_senable_i (DFTSE),
                                                 .clk_gated_o   (slot1_clk));
  
  ca53_cell_inter_clkgate u_inter_clkgate_slot2 (.clk_i         (clk),
                                                 .clk_enable_i  (slots_clk_enable[2]),
                                                 .clk_senable_i (DFTSE),
                                                 .clk_gated_o   (slot2_clk));
  
  ca53_cell_inter_clkgate u_inter_clkgate_slot3 (.clk_i         (clk),
                                                 .clk_enable_i  (slots_clk_enable[3]),
                                                 .clk_senable_i (DFTSE),
                                                 .clk_gated_o   (slot3_clk));
  
  ca53_cell_inter_clkgate u_inter_clkgate_slot4 (.clk_i         (clk),
                                                 .clk_enable_i  (slots_clk_enable[4]),
                                                 .clk_senable_i (DFTSE),
                                                 .clk_gated_o   (slot4_clk));

  
  //----------------------------------------------------------------------------
  // Register signals for timing
  //----------------------------------------------------------------------------

  assign stb_en = dcu_stb_req_dc3_i | (|slots_valid);
  
  always @(posedge clk)
  if (stb_en) begin
    dvm_complete <= scu_dvm_complete_i;
  end
  
  // Signals that can be asserted when a slot is valid and de-asserted after
  // the STB has drained are registered every cycle to capture the de-assertion.
  always @(posedge clk) begin
    scu_drain_stb <= scu_drain_stb_i;
    wfx_drain_req <= gov_wfx_drain_req_i;
  end
  

  //----------------------------------------------------------------------------
  // Main code
  //----------------------------------------------------------------------------

  // Combine various signals to simplify expressions that use them

  assign slots_valid = {slot4_valid,
                        slot3_valid,
                        slot2_valid,
                        slot1_valid,
                        slot0_valid};

  assign slots_emptying = {slot4_emptying,
                           slot3_emptying,
                           slot2_emptying,
                           slot1_emptying,
                           slot0_emptying};

  assign slots_force_non_mergeable = {slot4_force_non_mergeable,
                                      slot3_force_non_mergeable,
                                      slot2_force_non_mergeable,
                                      slot1_force_non_mergeable,
                                      slot0_force_non_mergeable};

  assign slots_state_lookupm2 = {slot4_state_lookupm2,
                                 slot3_state_lookupm2,
                                 slot2_state_lookupm2,
                                 slot1_state_lookupm2,
                                 slot0_state_lookupm2};                                 
  
  assign slots_state_cachemerge = {slot4_state_cachemerge,
                                   slot3_state_cachemerge,
                                   slot2_state_cachemerge,
                                   slot1_state_cachemerge,
                                   slot0_state_cachemerge};

  assign slots_state_cachewritem1 = {slot4_state_cachewritem1,
                                     slot3_state_cachewritem1,
                                     slot2_state_cachewritem1,
                                     slot1_state_cachewritem1,
                                     slot0_state_cachewritem1};

  assign slots_state_biumerge = {slot4_state_biumerge,
                                 slot3_state_biumerge,
                                 slot2_state_biumerge,
                                 slot1_state_biumerge,
                                 slot0_state_biumerge};

  assign slots_coherent = {slot4_coherent,
                           slot3_coherent,
                           slot2_coherent,
                           slot1_coherent,
                           slot0_coherent};

  assign slot0_biu_lf_hazard = biu_lf_hazard_i[0];
  assign slot1_biu_lf_hazard = biu_lf_hazard_i[1];
  assign slot2_biu_lf_hazard = biu_lf_hazard_i[2];
  assign slot3_biu_lf_hazard = biu_lf_hazard_i[3];
  assign slot4_biu_lf_hazard = biu_lf_hazard_i[4];

  assign slot0_biu_lf_real_hazard = biu_lf_real_hazard_i[0];
  assign slot1_biu_lf_real_hazard = biu_lf_real_hazard_i[1];
  assign slot2_biu_lf_real_hazard = biu_lf_real_hazard_i[2];
  assign slot3_biu_lf_real_hazard = biu_lf_real_hazard_i[3];
  assign slot4_biu_lf_real_hazard = biu_lf_real_hazard_i[4];

  assign slot0_biu_lf_hazard_migratory = biu_lf_hazard_migratory_i[0];
  assign slot1_biu_lf_hazard_migratory = biu_lf_hazard_migratory_i[1];
  assign slot2_biu_lf_hazard_migratory = biu_lf_hazard_migratory_i[2];
  assign slot3_biu_lf_hazard_migratory = biu_lf_hazard_migratory_i[3];
  assign slot4_biu_lf_hazard_migratory = biu_lf_hazard_migratory_i[4];

  assign slot0_biu_lf_serialized = biu_lf_serialized_i[0];
  assign slot1_biu_lf_serialized = biu_lf_serialized_i[1];
  assign slot2_biu_lf_serialized = biu_lf_serialized_i[2];
  assign slot3_biu_lf_serialized = biu_lf_serialized_i[3];
  assign slot4_biu_lf_serialized = biu_lf_serialized_i[4];

  assign slot0_biu_lf_can_merge = biu_lf_can_merge_i[0];
  assign slot1_biu_lf_can_merge = biu_lf_can_merge_i[1];
  assign slot2_biu_lf_can_merge = biu_lf_can_merge_i[2];
  assign slot3_biu_lf_can_merge = biu_lf_can_merge_i[3];
  assign slot4_biu_lf_can_merge = biu_lf_can_merge_i[4];

  assign slot0_dcu_store_sameline_dc3 = dcu_store_sameline_dc3_i[0];
  assign slot1_dcu_store_sameline_dc3 = dcu_store_sameline_dc3_i[1];
  assign slot2_dcu_store_sameline_dc3 = dcu_store_sameline_dc3_i[2];
  assign slot3_dcu_store_sameline_dc3 = dcu_store_sameline_dc3_i[3];
  assign slot4_dcu_store_sameline_dc3 = dcu_store_sameline_dc3_i[4];

  // Record whether a device burst is being received from the DCU. This is
  // needed to identify parts of the same burst and transfer l2dbid information.
  assign next_dev_bursting = (dcu_stb_req_dc3_i & ~dpu_kill_wr_i &
                              dcu_store_dc3_i & ~dcu_store_cp15_dc3_i & ~&slots_valid) ?
                             (~`CA53_MEM_MERGEABLE(dcu_stb_attrs_dc3_i) & ~dcu_store_last_dc3_i) :
                             dev_bursting;

  // Detect when the first beat of device burst will take the last STB slot.
  // The burst must not make an AR request until there is space for the second
  // beat because it will wait for the second beat before sending the data, and
  // taking the last of the SCU write buffers might prevent the other slots from
  // from draining (thus preventing the second beat from being accepted
  // indefinitely).
  assign next_dev_delay_ar_req = dev_bursting ?
                                 // Ongoing burst
                                 (dev_delay_ar_req & ~|slots_emptying) :
                                 // New burst
                                 (next_dev_bursting &
                                  ~|slots_emptying &
                                  (num_slots_empty == 3'b001));                         
  
  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    dev_bursting <= 1'b0;
    dev_delay_ar_req <= 1'b0;
  end else if (stb_en) begin
    dev_bursting <= next_dev_bursting;
    dev_delay_ar_req <= next_dev_delay_ar_req;
  end
  
  // Register the tag hit information from a cache lookup. This is not factored
  // directly into each slot's state machine next state logic, because it arrives
  // fairly late. The registered m3 version can instead be used in the following
  // cycle.
  assign next_tag_hit_shared_m3 = {|dcu_stb_tag_hit_m2_i, dcu_stb_tag_shared_m2_i};

  always @(posedge clk)
  if (stb_en) begin
    tag_hit_shared_m3 <= next_tag_hit_shared_m3;
  end

  generate if (CPU_CACHE_PROTECTION) begin : gen_cpu_cache_protection_01
    
    // Similarly, register the ECC information.
    assign tag_ecc_err_m3_en = |slots_state_lookupm2 |
                               tag_ecc_err_m3;
    
    assign next_tag_ecc_err_m3 = |slots_state_lookupm2 &
                                 dcu_ecc_tag_err_m2_i;
    
    always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      tag_ecc_err_m3_reg <= 1'b0;
    end else if (tag_ecc_err_m3_en) begin
      tag_ecc_err_m3_reg <= next_tag_ecc_err_m3;
    end
    
    assign tag_ecc_err_m3 = tag_ecc_err_m3_reg;
    
  end else begin : gen_cpu_cache_protection_01_else
    
    assign tag_ecc_err_m3_en = 1'b0;
    assign next_tag_ecc_err_m3 = 1'b0;
    assign tag_ecc_err_m3 = 1'b0;
    
  end endgenerate

  // Determine the lowest numbered idle slot.
  assign slots_lowest_idle = { slot0_valid &  slot1_valid &  slot2_valid &  slot3_valid & ~slot4_valid,
                               slot0_valid &  slot1_valid &  slot2_valid & ~slot3_valid,
                               slot0_valid &  slot1_valid & ~slot2_valid,
                               slot0_valid & ~slot1_valid,
                              ~slot0_valid};

  // Pick which slot to assign a new request to. If merging, then pick the
  // slot specified by the DCU, otherwise pick the first idle slot.
  // The request is conditional on dpu_kill_wr not being asserted, however
  // that is later arriving and hence is factored in later in the slot, and
  // only in the places where it matters.
  assign slot0_new_req_dc3 = dcu_stb_req_dc3_i & (dcu_store_merge_dc3_i[0] |
                                                  (slots_lowest_idle[0] &
                                                   ~|dcu_store_merge_dc3_i[4:1]));

  assign slot1_new_req_dc3 = dcu_stb_req_dc3_i & (dcu_store_merge_dc3_i[1] |
                                                  (slots_lowest_idle[1] &
                                                   ~|{dcu_store_merge_dc3_i[4:2], dcu_store_merge_dc3_i[0]}));

  assign slot2_new_req_dc3 = dcu_stb_req_dc3_i & (dcu_store_merge_dc3_i[2] |
                                                  (slots_lowest_idle[2] &
                                                   ~|{dcu_store_merge_dc3_i[4:3], dcu_store_merge_dc3_i[1:0]}));

  assign slot3_new_req_dc3 = dcu_stb_req_dc3_i & (dcu_store_merge_dc3_i[3] |
                                                  (slots_lowest_idle[3] &
                                                   ~|{dcu_store_merge_dc3_i[4], dcu_store_merge_dc3_i[2:0]}));

  assign slot4_new_req_dc3 = dcu_stb_req_dc3_i & (dcu_store_merge_dc3_i[4] |
                                                  (slots_lowest_idle[4] &
                                                   ~|dcu_store_merge_dc3_i[3:0]));


  // Set when any ICU, BP, or TLB op goes into the STB. Cleared when a DSB enters
  // the STB. If no DVM messages are sent between two DSBs being executed then
  // there is no need to send a new DVM sync.
  assign next_dvm_sync_needed = (dvm_sync_needed |
                                 dcu_dvm_sync_needed_dc3_i) &
                                ~dcu_store_dsb_dc3_i;

  assign dvm_sync_needed_en = dcu_stb_req_dc3_i & dcu_store_cp15_dc3_i & ~&slots_valid & ~dpu_kill_wr_i;

  always @(posedge clk_stb or negedge reset_n)
  if (~reset_n) begin
    dvm_sync_needed <= 1'b0;
  end else if (dvm_sync_needed_en) begin
    dvm_sync_needed <= next_dvm_sync_needed;
  end

  // Set when a write or cache maintenance operation is sent to the BIU. Cleared
  // when a barrier enters the STB. If no writes or cache maintenance operations
  // are sent to the BIU between the two DSBs being executed then there is no
  // need for the second DSB to propagate to the BIU.
  //
  // If DMBs are being mapped to DSBs then this optimized behaviour is disabled
  // and all DSBs propagate to the BIU.
  assign next_propagate_barrier = dpu_disable_dmb_i |
                                  (biu_stb_ar_ack_i &
                                   (// Set on write or CMO
                                    (slot0_write_sync_cmo_ack |
                                     slot1_write_sync_cmo_ack |
                                     slot2_write_sync_cmo_ack |
                                     slot3_write_sync_cmo_ack |
                                     slot4_write_sync_cmo_ack) |
                                    // Clear on barrier
                                    (propagate_barrier &
                                     ~(slot0_state_barrier_ack |
                                       slot1_state_barrier_ack |
                                       slot2_state_barrier_ack |
                                       slot3_state_barrier_ack |
                                       slot4_state_barrier_ack))));

  assign propagate_barrier_en = biu_stb_ar_ack_i |
                                (~propagate_barrier & dpu_disable_dmb_i);
                                   
  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    propagate_barrier <= 1'b0;
  end else if (propagate_barrier_en) begin
    propagate_barrier <= next_propagate_barrier;
  end

  
  //----------------------------------------------------------------------------
  // Slot draining
  //----------------------------------------------------------------------------

  // Count the number of slots that are empty.
  assign num_slots_empty = {1'b0, ~slot0_valid} +
                           {1'b0, ~slot1_valid} +
                           {1'b0, ~slot2_valid} +
                           {1'b0, ~slot3_valid} +
                           {1'b0, ~slot4_valid};

  // Look ahead in the DCU pipeline and count the number of stores in flight.
  // This is a speculative count, but we need to start draining slots before
  // the speculation is resolved otherwise the slots will not have drained
  // in time and hence the pipe will stall.
  // Note that the iss signal is direct from the DPU, and is not qualified with
  // the transaction entering the DCU as this would be too late. However it is
  // qualified in the DPU with it being a store instruction.
  assign num_stores = (dpu_store_iss_i +
                       dcu_store_dc1_i +
                       dcu_store_dc2_i +
                       (dcu_store_dc3_i & ~|dcu_store_merge_dc3_i));


  // If more than 2 slots are in the cachemerge state then start to drain.
  assign too_many_slots_cachemerge = ({{2{1'b0}}, slots_state_cachemerge[0]} +
                                      {{2{1'b0}}, slots_state_cachemerge[1]} +
                                      {{2{1'b0}}, slots_state_cachemerge[2]} +
                                      {{2{1'b0}}, slots_state_cachemerge[3]} +
                                      {{2{1'b0}}, slots_state_cachemerge[4]}) > 3'b010;

  // Drain one slot per cycle until sufficient slots are available for all the
  // expected stores.
  assign drain_one_slot = ((num_stores > num_slots_empty) |
                           too_many_slots_cachemerge);

  // Choose which slot to drain. If any slot is in the cachemerge state, then
  // pick the lowest numbered slot that is, otherwise pick the lowest numbered
  // slot that is in the biumerge state. scu_drain_stb does not factor into
  // these drain signals because the requests that slots drain if they're
  // already in BIUDATA (holding up release of an l2db id).
  assign slot0_force_drain = (wfx_drain_req | dcu_drain_entire_stb_i | dcu_drain_slots_i[0] |
                              (drain_one_slot & (slots_state_cachemerge[0] |
                                                 ~|slots_state_cachemerge)));

  assign slot1_force_drain = (wfx_drain_req | dcu_drain_entire_stb_i | dcu_drain_slots_i[1] |
                              (drain_one_slot & ((slots_state_cachemerge[1] & ~slots_state_cachemerge[0]) |
                                                 (~|slots_state_cachemerge & ~slots_state_biumerge[0]))));

  assign slot2_force_drain = (wfx_drain_req | dcu_drain_entire_stb_i | dcu_drain_slots_i[2] |
                              (drain_one_slot & ((slots_state_cachemerge[2] & ~|slots_state_cachemerge[1:0]) |
                                                 (~|slots_state_cachemerge & ~|slots_state_biumerge[1:0]))));

  assign slot3_force_drain = (wfx_drain_req | dcu_drain_entire_stb_i | dcu_drain_slots_i[3] |
                              (drain_one_slot & ((slots_state_cachemerge[3] & ~|slots_state_cachemerge[2:0]) |
                                                 (~|slots_state_cachemerge & ~|slots_state_biumerge[2:0]))));

  assign slot4_force_drain = (wfx_drain_req | dcu_drain_entire_stb_i | dcu_drain_slots_i[4] |
                              (drain_one_slot & ((slots_state_cachemerge[4] & ~|slots_state_cachemerge[3:0]) |
                                                 (~|slots_state_cachemerge & ~|slots_state_biumerge[3:0]))));

  // Tell slots to stop speculatively waiting if all slots must drain.
  assign slot0_force_drain_biudata = wfx_drain_req | scu_drain_stb |
                                     dcu_drain_entire_stb_i | dcu_drain_slots_i[0];

  assign slot1_force_drain_biudata = wfx_drain_req | scu_drain_stb |
                                     dcu_drain_entire_stb_i | dcu_drain_slots_i[1];

  assign slot2_force_drain_biudata = wfx_drain_req | scu_drain_stb |
                                     dcu_drain_entire_stb_i | dcu_drain_slots_i[2];

  assign slot3_force_drain_biudata = wfx_drain_req | scu_drain_stb |
                                     dcu_drain_entire_stb_i | dcu_drain_slots_i[3];

  assign slot4_force_drain_biudata = wfx_drain_req | scu_drain_stb |
                                     dcu_drain_entire_stb_i | dcu_drain_slots_i[4];

  // The STB is ready to go into WFx state only if all slots are idle.
  assign stb_wfx_ready_o = ~|slots_valid;

  // Increment the cycle counter whenever at least one slot is active.
  assign cycle_count_incr = |slots_valid;

  // Reset the cycle counter if nothing is active.
  assign next_cycle_count = cycle_count_incr ? (cycle_count + 10'b0000000001) : 10'b0000000000;

  assign cycle_count_en = |cycle_count | cycle_count_incr;

  // The counter is 10 bits, so that when combined with the 2-bit counter
  // in each slot it gives between 2048 and 3072 cycles. The lower 7 bits
  // are also combined with a 1-bit counter to give between 128 and 256
  // cycles.
  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    cycle_count <= 10'b0000000000;
  end else if (cycle_count_en) begin
    cycle_count <= next_cycle_count;
  end

  // Signal to the slots when the counter has reached certain values. The slots
  // can then decide whether to drain based on this.
  assign stb_cycle_count_127 = &cycle_count[6:0];
  assign stb_cycle_count_1023 = &cycle_count[9:0];


  //----------------------------------------------------------------------------
  // DC2 hazarding and forwarding
  //----------------------------------------------------------------------------

  // Report any slots that match the dc2 address but have different memory
  // attributes. The DCU will then force the slots to be non-mergeable before
  // the store is passed to the STB, to keep the mismatched transactions
  // separate.
  assign stb_attr_mismatch_dc2 = slot4_attr_mismatch_dc2 |
                                 slot3_attr_mismatch_dc2 |
                                 slot2_attr_mismatch_dc2 |
                                 slot1_attr_mismatch_dc2 |
                                 slot0_attr_mismatch_dc2;

  assign stb_attr_mismatch_dc2_o = stb_attr_mismatch_dc2;

  // A store in dc2 cannot merge if there is an attribute mismatch, because
  // the mismatch will cause it to force existing slots to be non-mergeable.
  assign stb_can_merge_dc2 = {slot4_can_merge_dc2,
                              slot3_can_merge_dc2,
                              slot2_can_merge_dc2,
                              slot1_can_merge_dc2,
                              slot0_can_merge_dc2};

  assign stb_can_merge_dc2_o = stb_can_merge_dc2;
  
  // A store in dc2 cannot be marked as being in the same line if there is
  // an attribute mismatch, because the mismatch will cause it to force
  // existing slots to be non-mergeable.
  assign stb_sameline_dc2_o = {slot4_sameline_dc2,
                               slot3_sameline_dc2,
                               slot2_sameline_dc2,
                               slot1_sameline_dc2,
                               slot0_sameline_dc2};

  // A load in dc2 needs to know which slots are in the same line, so that if
  // it is an NC load it can later avoid hazards against the matching slots.
  assign stb_load_sameline_dc2_o = {slot4_load_sameline_dc2,
                                    slot3_load_sameline_dc2,
                                    slot2_load_sameline_dc2,
                                    slot1_load_sameline_dc2,
                                    slot0_load_sameline_dc2};


  // Report to the DCU which bytes the STB has that match the address in dc2.
  assign stb_hit_dc2_o = slot4_hit_dc2[15:8] | slot4_hit_dc2[7:0] |
                         slot3_hit_dc2[15:8] | slot3_hit_dc2[7:0] |
                         slot2_hit_dc2[15:8] | slot2_hit_dc2[7:0] |
                         slot1_hit_dc2[15:8] | slot1_hit_dc2[7:0] |
                         slot0_hit_dc2[15:8] | slot0_hit_dc2[7:0];

  // Multiple slots may have the same address, so use the earlier bits to pick
  // the most recent copy of each byte.
  assign slot0_real_hit_dc2 = slot0_hit_dc2 & ~((slot1_hit_dc2 & {16{slot1_earlier[0]}}) |
                                                (slot2_hit_dc2 & {16{slot2_earlier[0]}}) |
                                                (slot3_hit_dc2 & {16{slot3_earlier[0]}}) |
                                                (slot4_hit_dc2 & {16{slot4_earlier[0]}}));

  assign slot1_real_hit_dc2 = slot1_hit_dc2 & ~((slot0_hit_dc2 & {16{slot0_earlier[0]}}) |
                                                (slot2_hit_dc2 & {16{slot2_earlier[1]}}) |
                                                (slot3_hit_dc2 & {16{slot3_earlier[1]}}) |
                                                (slot4_hit_dc2 & {16{slot4_earlier[1]}}));

  assign slot2_real_hit_dc2 = slot2_hit_dc2 & ~((slot0_hit_dc2 & {16{slot0_earlier[1]}}) |
                                                (slot1_hit_dc2 & {16{slot1_earlier[1]}}) |
                                                (slot3_hit_dc2 & {16{slot3_earlier[2]}}) |
                                                (slot4_hit_dc2 & {16{slot4_earlier[2]}}));

  assign slot3_real_hit_dc2 = slot3_hit_dc2 & ~((slot0_hit_dc2 & {16{slot0_earlier[2]}}) |
                                                (slot1_hit_dc2 & {16{slot1_earlier[2]}}) |
                                                (slot2_hit_dc2 & {16{slot2_earlier[2]}}) |
                                                (slot4_hit_dc2 & {16{slot4_earlier[3]}}));

  assign slot4_real_hit_dc2 = slot4_hit_dc2 & ~((slot0_hit_dc2 & {16{slot0_earlier[3]}}) |
                                                (slot1_hit_dc2 & {16{slot1_earlier[3]}}) |
                                                (slot2_hit_dc2 & {16{slot2_earlier[3]}}) |
                                                (slot3_hit_dc2 & {16{slot3_earlier[3]}}));

  // Mux the data based on which slot hit.
  assign slot0_real_bit_hit_dc2 = `CA53_STB_BYTE_TO_BIT_STROBES(slot0_real_hit_dc2);
  assign slot1_real_bit_hit_dc2 = `CA53_STB_BYTE_TO_BIT_STROBES(slot1_real_hit_dc2);
  assign slot2_real_bit_hit_dc2 = `CA53_STB_BYTE_TO_BIT_STROBES(slot2_real_hit_dc2);
  assign slot3_real_bit_hit_dc2 = `CA53_STB_BYTE_TO_BIT_STROBES(slot3_real_hit_dc2);
  assign slot4_real_bit_hit_dc2 = `CA53_STB_BYTE_TO_BIT_STROBES(slot4_real_hit_dc2);

  assign slot0_hit_data_dc2_hi = slot0_real_bit_hit_dc2[127:64] & slot0_data[127:64];
  assign slot1_hit_data_dc2_hi = slot1_real_bit_hit_dc2[127:64] & slot1_data[127:64];
  assign slot2_hit_data_dc2_hi = slot2_real_bit_hit_dc2[127:64] & slot2_data[127:64];
  assign slot3_hit_data_dc2_hi = slot3_real_bit_hit_dc2[127:64] & slot3_data[127:64];
  assign slot4_hit_data_dc2_hi = slot4_real_bit_hit_dc2[127:64] & slot4_data[127:64];

  assign slot0_hit_data_dc2_lo = slot0_real_bit_hit_dc2[63:0] & slot0_data[63:0];
  assign slot1_hit_data_dc2_lo = slot1_real_bit_hit_dc2[63:0] & slot1_data[63:0];
  assign slot2_hit_data_dc2_lo = slot2_real_bit_hit_dc2[63:0] & slot2_data[63:0];
  assign slot3_hit_data_dc2_lo = slot3_real_bit_hit_dc2[63:0] & slot3_data[63:0];
  assign slot4_hit_data_dc2_lo = slot4_real_bit_hit_dc2[63:0] & slot4_data[63:0];

  assign stb_data_dc2_o = slot0_hit_data_dc2_hi | slot0_hit_data_dc2_lo |
                          slot1_hit_data_dc2_hi | slot1_hit_data_dc2_lo |
                          slot2_hit_data_dc2_hi | slot2_hit_data_dc2_lo |
                          slot3_hit_data_dc2_hi | slot3_hit_data_dc2_lo |
                          slot4_hit_data_dc2_hi | slot4_hit_data_dc2_lo;


  //----------------------------------------------------------------------------
  // BIU Arbitration
  //----------------------------------------------------------------------------

  assign stb_biu_write_req = (slot4_has_write_data_priority & ~slot4_write_data_suppress) |
                             (slot3_has_write_data_priority & ~slot3_write_data_suppress) |
                             (slot2_has_write_data_priority & ~slot2_write_data_suppress) |
                             (slot1_has_write_data_priority & ~slot1_write_data_suppress) |
                             (slot0_has_write_data_priority & ~slot0_write_data_suppress);

  assign stb_biu_write_req_o = stb_biu_write_req;

  assign stb_biu_write_l2dbid_o = ({4{slot4_has_write_data_priority}} & slot4_l2dbid) |
                                  ({4{slot3_has_write_data_priority}} & slot3_l2dbid) |
                                  ({4{slot2_has_write_data_priority}} & slot2_l2dbid) |
                                  ({4{slot1_has_write_data_priority}} & slot1_l2dbid) |
                                  ({4{slot0_has_write_data_priority}} & slot0_l2dbid);

  assign stb_biu_write_chunk_o = ({2{slot4_has_write_data_priority}} & slot4_write_chunk) |
                                 ({2{slot3_has_write_data_priority}} & slot3_write_chunk) |
                                 ({2{slot2_has_write_data_priority}} & slot2_write_chunk) |
                                 ({2{slot1_has_write_data_priority}} & slot1_write_chunk) |
                                 ({2{slot0_has_write_data_priority}} & slot0_write_chunk);

  assign stb_biu_write_data_o = ({128{slot4_has_write_data_priority}} & slot4_write_data) |
                                ({128{slot3_has_write_data_priority}} & slot3_write_data) |
                                ({128{slot2_has_write_data_priority}} & slot2_write_data) |
                                ({128{slot1_has_write_data_priority}} & slot1_write_data) |
                                ({128{slot0_has_write_data_priority}} & slot0_write_data);

  assign stb_biu_write_bls_o = ({16{slot4_has_write_data_priority}} & slot4_write_bls) |
                               ({16{slot3_has_write_data_priority}} & slot3_write_bls) |
                               ({16{slot2_has_write_data_priority}} & slot2_write_bls) |
                               ({16{slot1_has_write_data_priority}} & slot1_write_bls) |
                               ({16{slot0_has_write_data_priority}} & slot0_write_bls);

  assign stb_biu_write_last_o = (slot4_has_write_data_priority & slot4_write_last) |
                                (slot3_has_write_data_priority & slot3_write_last) |
                                (slot2_has_write_data_priority & slot2_write_last) |
                                (slot1_has_write_data_priority & slot1_write_last) |
                                (slot0_has_write_data_priority & slot0_write_last);

  // Indicate if there is a slot active that might make a BIU request in the
  // following cycle.
  assign stb_biu_write_req_active_o = (slot4_biu_write_req_active |
                                       slot3_biu_write_req_active |
                                       slot2_biu_write_req_active |
                                       slot1_biu_write_req_active |
                                       slot0_biu_write_req_active);


  //----------------------------------------------------------------------------
  // CCB arbitration
  //----------------------------------------------------------------------------
  
  // Data transfers for snoop requests have higher priority than stores in the
  // STB when requesting the BIU write channel. To ensure stores make progress,
  // the STB tells the DCU when it is waiting for write data to be accepted.
  // The DCU will delay acceptance of the next snoop request if stb_defer_ccb
  // is asserted during a CCB transfer. The signal must be de-asserted when a
  // write is accepted so that priority alternates between stores and snoop
  // requests.
  assign stb_defer_ccb_o = stb_biu_write_req & ~biu_stb_write_accept_i;
  
  
  //----------------------------------------------------------------------------
  // Cache tag arbitration
  //----------------------------------------------------------------------------

  // If any slot wants to write to the tag RAMs, then the order doesn't matter
  // so the pick the lowest numbered slot.
  assign slot0_has_tagwrite_priority = slot0_wants_tagwrite_priority;

  assign slot1_has_tagwrite_priority = (slot1_wants_tagwrite_priority &
                                        ~slot0_wants_tagwrite_priority);

  assign slot2_has_tagwrite_priority = (slot2_wants_tagwrite_priority &
                                        ~(slot0_wants_tagwrite_priority |
                                          slot1_wants_tagwrite_priority));

  assign slot3_has_tagwrite_priority = (slot3_wants_tagwrite_priority &
                                        ~(slot0_wants_tagwrite_priority |
                                          slot1_wants_tagwrite_priority |
                                          slot2_wants_tagwrite_priority));

  assign slot4_has_tagwrite_priority = (slot4_wants_tagwrite_priority &
                                        ~(slot0_wants_tagwrite_priority |
                                          slot1_wants_tagwrite_priority |
                                          slot2_wants_tagwrite_priority |
                                          slot3_wants_tagwrite_priority));


  // If any slot wants to write to the tag RAM then it will get priority over
  // any that wants to lookup in the tags.
  assign any_slot_has_tagwrite_priority = (slot0_wants_tagwrite_priority |
                                           slot1_wants_tagwrite_priority |
                                           slot2_wants_tagwrite_priority |
                                           slot3_wants_tagwrite_priority |
                                           slot4_wants_tagwrite_priority);

  assign stb_cache_tag_wr_m0_o = any_slot_has_tagwrite_priority;

  // All ways must be read when doing a lookup, otherwise only a single way.
  assign stb_cache_tag_way_m0_o = ({4{~any_slot_has_tagwrite_priority}} |
                                   ({4{slot0_has_tagwrite_priority}} & slot0_way_onehot) |
                                   ({4{slot1_has_tagwrite_priority}} & slot1_way_onehot) |
                                   ({4{slot2_has_tagwrite_priority}} & slot2_way_onehot) |
                                   ({4{slot3_has_tagwrite_priority}} & slot3_way_onehot) |
                                   ({4{slot4_has_tagwrite_priority}} & slot4_way_onehot));

  // Give lookup priority to the lowest numbered slot that wants it. There is
  // no point in doing a lookup if the slot has a linefill hazard, because if
  // the data is in the linefill buffer then we know it cannot also be in the
  // cache.
  assign slot0_has_lookup_priority = (~any_slot_has_tagwrite_priority &
                                      slot0_wants_lookup_priority) & ~slot0_biu_lf_hazard;

  assign slot1_has_lookup_priority = (~any_slot_has_tagwrite_priority &
                                      slot1_wants_lookup_priority &
                                      ~slot0_wants_lookup_priority) & ~slot1_biu_lf_hazard;

  assign slot2_has_lookup_priority = (~any_slot_has_tagwrite_priority &
                                      slot2_wants_lookup_priority &
                                      ~(slot0_wants_lookup_priority |
                                        slot1_wants_lookup_priority)) & ~slot2_biu_lf_hazard;

  assign slot3_has_lookup_priority = (~any_slot_has_tagwrite_priority &
                                      slot3_wants_lookup_priority &
                                      ~(slot0_wants_lookup_priority |
                                        slot1_wants_lookup_priority |
                                        slot2_wants_lookup_priority)) & ~slot3_biu_lf_hazard;

  assign slot4_has_lookup_priority = (~any_slot_has_tagwrite_priority &
                                      slot4_wants_lookup_priority &
                                      ~(slot0_wants_lookup_priority |
                                        slot1_wants_lookup_priority |
                                        slot2_wants_lookup_priority |
                                        slot3_wants_lookup_priority)) & ~slot4_biu_lf_hazard;


  // Make a request to the cache arbiter if any slot wants to read or write
  // the tag RAM.
  assign stb_cache_tag_req_m0_o = (any_slot_has_tagwrite_priority |
                                   slot0_has_lookup_priority |
                                   slot1_has_lookup_priority |
                                   slot2_has_lookup_priority |
                                   slot3_has_lookup_priority |
                                   slot4_has_lookup_priority);

  // Mux the tag request information based on which slot got priority.
  assign tag_sel = {slot4_has_tagwrite_priority | slot4_has_lookup_priority,
                    slot3_has_tagwrite_priority | slot3_has_lookup_priority,
                    slot2_has_tagwrite_priority | slot2_has_lookup_priority,
                    slot1_has_tagwrite_priority | slot1_has_lookup_priority,
                    slot0_has_tagwrite_priority | slot0_has_lookup_priority};

  assign stb_cache_tag_addr_m0_o = (({34{tag_sel[0]}} & slot0_addr[39:6]) |
                                    ({34{tag_sel[1]}} & slot1_addr[39:6]) |
                                    ({34{tag_sel[2]}} & slot2_addr[39:6]) |
                                    ({34{tag_sel[3]}} & slot3_addr[39:6]) |
                                    ({34{tag_sel[4]}} & slot4_addr[39:6]));

  assign stb_cache_tag_ns_dsc_m0_o = ((tag_sel[0] & slot0_ns) |
                                      (tag_sel[1] & slot1_ns) |
                                      (tag_sel[2] & slot2_ns) |
                                      (tag_sel[3] & slot3_ns) |
                                      (tag_sel[4] & slot4_ns));


  //----------------------------------------------------------------------------
  // Cache data arbitration
  //----------------------------------------------------------------------------

  // Give data priority to the earliest slot that wants or might want it. This
  // is independent from the tag lookup (while any one slot cannot be doing both
  // at once, different slots could be).
  assign earliest_slot_wanting_cache_data_priority = {slot4_wants_cache_data_priority & ~cache_data_slot_select[4] &
                                                      ~|(slot4_earlier & {slot3_wants_cache_data_priority & ~cache_data_slot_select[3],
                                                                          slot2_wants_cache_data_priority & ~cache_data_slot_select[2],
                                                                          slot1_wants_cache_data_priority & ~cache_data_slot_select[1],
                                                                          slot0_wants_cache_data_priority & ~cache_data_slot_select[0]}),
                                                      slot3_wants_cache_data_priority & ~cache_data_slot_select[3] &
                                                      ~|(slot3_earlier & {slot4_wants_cache_data_priority & ~cache_data_slot_select[4],
                                                                          slot2_wants_cache_data_priority & ~cache_data_slot_select[2],
                                                                          slot1_wants_cache_data_priority & ~cache_data_slot_select[1],
                                                                          slot0_wants_cache_data_priority & ~cache_data_slot_select[0]}),
                                                      slot2_wants_cache_data_priority & ~cache_data_slot_select[2] &
                                                      ~|(slot2_earlier & {slot4_wants_cache_data_priority & ~cache_data_slot_select[4],
                                                                          slot3_wants_cache_data_priority & ~cache_data_slot_select[3],
                                                                          slot1_wants_cache_data_priority & ~cache_data_slot_select[1],
                                                                          slot0_wants_cache_data_priority & ~cache_data_slot_select[0]}),
                                                      slot1_wants_cache_data_priority & ~cache_data_slot_select[1] &
                                                      ~|(slot1_earlier & {slot4_wants_cache_data_priority & ~cache_data_slot_select[4],
                                                                          slot3_wants_cache_data_priority & ~cache_data_slot_select[3],
                                                                          slot2_wants_cache_data_priority & ~cache_data_slot_select[2],
                                                                          slot0_wants_cache_data_priority & ~cache_data_slot_select[0]}),
                                                      slot0_wants_cache_data_priority & ~cache_data_slot_select[0] &
                                                      ~|(slot0_earlier & {slot4_wants_cache_data_priority & ~cache_data_slot_select[4],
                                                                          slot3_wants_cache_data_priority & ~cache_data_slot_select[3],
                                                                          slot2_wants_cache_data_priority & ~cache_data_slot_select[2],
                                                                          slot1_wants_cache_data_priority & ~cache_data_slot_select[1]})};

  assign earliest_slot_might_want_cache_data_priority = {slot4_might_want_cache_data_priority & ~slot4_has_cache_data_priority &
                                                         ~|(slot4_earlier & {slot3_might_want_cache_data_priority & ~slot3_has_cache_data_priority,
                                                                             slot2_might_want_cache_data_priority & ~slot2_has_cache_data_priority,
                                                                             slot1_might_want_cache_data_priority & ~slot1_has_cache_data_priority,
                                                                             slot0_might_want_cache_data_priority & ~slot0_has_cache_data_priority}),
                                                         slot3_might_want_cache_data_priority & ~slot3_has_cache_data_priority &
                                                         ~|(slot3_earlier & {slot4_might_want_cache_data_priority & ~slot4_has_cache_data_priority,
                                                                             slot2_might_want_cache_data_priority & ~slot2_has_cache_data_priority,
                                                                             slot1_might_want_cache_data_priority & ~slot1_has_cache_data_priority,
                                                                             slot0_might_want_cache_data_priority & ~slot0_has_cache_data_priority}),
                                                         slot2_might_want_cache_data_priority & ~slot2_has_cache_data_priority &
                                                         ~|(slot2_earlier & {slot4_might_want_cache_data_priority & ~slot4_has_cache_data_priority,
                                                                             slot3_might_want_cache_data_priority & ~slot3_has_cache_data_priority,
                                                                             slot1_might_want_cache_data_priority & ~slot1_has_cache_data_priority,
                                                                             slot0_might_want_cache_data_priority & ~slot0_has_cache_data_priority}),
                                                         slot1_might_want_cache_data_priority & ~slot1_has_cache_data_priority &
                                                         ~|(slot1_earlier & {slot4_might_want_cache_data_priority & ~slot4_has_cache_data_priority,
                                                                             slot3_might_want_cache_data_priority & ~slot3_has_cache_data_priority,
                                                                             slot2_might_want_cache_data_priority & ~slot2_has_cache_data_priority,
                                                                             slot0_might_want_cache_data_priority & ~slot0_has_cache_data_priority}),
                                                         slot0_might_want_cache_data_priority & ~slot0_has_cache_data_priority &
                                                         ~|(slot0_earlier & {slot4_might_want_cache_data_priority & ~slot4_has_cache_data_priority,
                                                                             slot3_might_want_cache_data_priority & ~slot3_has_cache_data_priority,
                                                                             slot2_might_want_cache_data_priority & ~slot2_has_cache_data_priority,
                                                                             slot1_might_want_cache_data_priority & ~slot1_has_cache_data_priority})};

  assign earliest_slot_lookupm2 = {slot4_state_lookupm2 &
                                   ~|(slot4_earlier & {slot3_state_lookupm2,
                                                       slot2_state_lookupm2,
                                                       slot1_state_lookupm2,
                                                       slot0_state_lookupm2}),
                                   slot3_state_lookupm2 &
                                   ~|(slot3_earlier & {slot4_state_lookupm2,
                                                       slot2_state_lookupm2,
                                                       slot1_state_lookupm2,
                                                       slot0_state_lookupm2}),
                                   slot2_state_lookupm2 &
                                   ~|(slot2_earlier & {slot4_state_lookupm2,
                                                       slot3_state_lookupm2,
                                                       slot1_state_lookupm2,
                                                       slot0_state_lookupm2}),
                                   slot1_state_lookupm2 &
                                   ~|(slot1_earlier & {slot4_state_lookupm2,
                                                       slot3_state_lookupm2,
                                                       slot2_state_lookupm2,
                                                       slot0_state_lookupm2}),
                                   slot0_state_lookupm2 &
                                   ~|(slot0_earlier & {slot4_state_lookupm2,
                                                       slot3_state_lookupm2,
                                                       slot2_state_lookupm2,
                                                       slot1_state_lookupm2})};

  assign earliest_coherent_slot = {slot4_valid & slot4_coherent &
                                   ~|(slot4_earlier & {slot3_valid & slot3_coherent,
                                                       slot2_valid & slot2_coherent,
                                                       slot1_valid & slot1_coherent,
                                                       slot0_valid & slot0_coherent}),
                                   slot3_valid & slot3_coherent &
                                   ~|(slot3_earlier & {slot4_valid & slot4_coherent,
                                                       slot2_valid & slot2_coherent,
                                                       slot1_valid & slot1_coherent,
                                                       slot0_valid & slot0_coherent}),
                                   slot2_valid & slot2_coherent &
                                   ~|(slot2_earlier & {slot4_valid & slot4_coherent,
                                                       slot3_valid & slot3_coherent,
                                                       slot1_valid & slot1_coherent,
                                                       slot0_valid & slot0_coherent}),
                                   slot1_valid & slot1_coherent &
                                   ~|(slot1_earlier & {slot4_valid & slot4_coherent,
                                                       slot3_valid & slot3_coherent,
                                                       slot2_valid & slot2_coherent,
                                                       slot0_valid & slot0_coherent}),
                                   slot0_valid & slot0_coherent &
                                   ~|(slot0_earlier & {slot4_valid & slot4_coherent,
                                                       slot3_valid & slot3_coherent,
                                                       slot2_valid & slot2_coherent,
                                                       slot1_valid & slot1_coherent})};

  assign slots_want_cache_data_priority = {slot4_wants_cache_data_priority,
                                           slot3_wants_cache_data_priority,
                                           slot2_wants_cache_data_priority,
                                           slot1_wants_cache_data_priority,
                                           slot0_wants_cache_data_priority};

  assign next_cache_data_slot_select = (stb_cache_data_req_m0 &
                                        ~dcu_stb_data_has_priority_m0_i)               ? cache_data_slot_select :
                                       (|earliest_slot_wanting_cache_data_priority)    ? earliest_slot_wanting_cache_data_priority :
                                       (|earliest_slot_might_want_cache_data_priority) ? earliest_slot_might_want_cache_data_priority :
                                       (|slots_state_lookupm2)                         ? earliest_slot_lookupm2 : earliest_coherent_slot;

  assign cache_data_slot_select_en = |(slots_valid & slots_coherent & ~cache_data_slot_select);

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    cache_data_slot_select <= 5'b00000;
  end else if (cache_data_slot_select_en) begin
    cache_data_slot_select <= next_cache_data_slot_select;
  end

  assign slot0_has_cache_data_priority = slot0_wants_cache_data_priority & cache_data_slot_select[0];
  assign slot1_has_cache_data_priority = slot1_wants_cache_data_priority & cache_data_slot_select[1];
  assign slot2_has_cache_data_priority = slot2_wants_cache_data_priority & cache_data_slot_select[2];
  assign slot3_has_cache_data_priority = slot3_wants_cache_data_priority & cache_data_slot_select[3];
  assign slot4_has_cache_data_priority = slot4_wants_cache_data_priority & cache_data_slot_select[4];

  assign stb_cache_data_req_m0 = |(slots_want_cache_data_priority & cache_data_slot_select);

  assign stb_cache_data_req_m0_o = stb_cache_data_req_m0;
  
  // Mux all the request information needed for m0 arbitration.
  assign stb_cache_data_wr_m0_o = (cache_data_slot_select[0] & slot0_state_cachewritereq) |
                                  (cache_data_slot_select[1] & slot1_state_cachewritereq) |
                                  (cache_data_slot_select[2] & slot2_state_cachewritereq) |
                                  (cache_data_slot_select[3] & slot3_state_cachewritereq) |
                                  (cache_data_slot_select[4] & slot4_state_cachewritereq);

  assign stb_cache_data_addr_m0_o = ({10{cache_data_slot_select[0]}} & slot0_addr[13:4]) |
                                    ({10{cache_data_slot_select[1]}} & slot1_addr[13:4]) |
                                    ({10{cache_data_slot_select[2]}} & slot2_addr[13:4]) |
                                    ({10{cache_data_slot_select[3]}} & slot3_addr[13:4]) |
                                    ({10{cache_data_slot_select[4]}} & slot4_addr[13:4]);

  assign stb_cache_data_way_m0_o = ({4{cache_data_slot_select[0]}} & slot0_way_onehot) |
                                   ({4{cache_data_slot_select[1]}} & slot1_way_onehot) |
                                   ({4{cache_data_slot_select[2]}} & slot2_way_onehot) |
                                   ({4{cache_data_slot_select[3]}} & slot3_way_onehot) |
                                   ({4{cache_data_slot_select[4]}} & slot4_way_onehot);

  assign stb_cache_write_data_m0_o = ({128{cache_data_slot_select[0]}} & slot0_data) |
                                     ({128{cache_data_slot_select[1]}} & slot1_data) |
                                     ({128{cache_data_slot_select[2]}} & slot2_data) |
                                     ({128{cache_data_slot_select[3]}} & slot3_data) |
                                     ({128{cache_data_slot_select[4]}} & slot4_data);

  assign stb_cache_data_bls_m0 = ({16{cache_data_slot_select[0]}} & slot0_cache_bls) |
                                 ({16{cache_data_slot_select[1]}} & slot1_cache_bls) |
                                 ({16{cache_data_slot_select[2]}} & slot2_cache_bls) |
                                 ({16{cache_data_slot_select[3]}} & slot3_cache_bls) |
                                 ({16{cache_data_slot_select[4]}} & slot4_cache_bls);

  assign stb_cache_data_bls_m0_o = stb_cache_data_bls_m0;

  assign stb_cache_data_attrs_m0_o = ({8{cache_data_slot_select[0]}} & slot0_attrs) |
                                     ({8{cache_data_slot_select[1]}} & slot1_attrs) |
                                     ({8{cache_data_slot_select[2]}} & slot2_attrs) |
                                     ({8{cache_data_slot_select[3]}} & slot3_attrs) |
                                     ({8{cache_data_slot_select[4]}} & slot4_attrs);

  assign stb_cache_data_migratory_m0_o = (cache_data_slot_select[0] & slot0_migratory) |
                                         (cache_data_slot_select[1] & slot1_migratory) |
                                         (cache_data_slot_select[2] & slot2_migratory) |
                                         (cache_data_slot_select[3] & slot3_migratory) |
                                         (cache_data_slot_select[4] & slot4_migratory);

  // Pipeline M0 word strobes to M2. This is used to only update bytes for read
  // data that was requested during a RmW sequence. If the DCU merges into a
  // previously empty word between M0 and M2 then the STB slot will know that
  // the read data is not valid for other bytes in the new word. The slot will
  // then repeat the read part of the RmW process.
  assign dcu_stb_read_wls_m1_en = stb_cache_data_req_m0 & dcu_stb_data_has_priority_m0_i;

  assign next_dcu_stb_read_wls_m1 = {|stb_cache_data_bls_m0[15:12],
                                          |stb_cache_data_bls_m0[11:8],
                                          |stb_cache_data_bls_m0[7:4],
                                          |stb_cache_data_bls_m0[3:0]};

  always @(posedge clk)
  if (dcu_stb_read_wls_m1_en) begin
    dcu_stb_read_wls_m1 <= next_dcu_stb_read_wls_m1;
  end

  always @(posedge clk)
  if (dcu_stb_data_ack_m1_i) begin
    dcu_stb_read_wls_m2 <= dcu_stb_read_wls_m1;
  end
  
  
  //----------------------------------------------------------------------------
  // Linefill arbitration
  //----------------------------------------------------------------------------

  // Tell the BIU if we might make a linefill request next cycle.
  assign stb_lf_active_o = slot4_lf_active |
                           slot3_lf_active |
                           slot2_lf_active |
                           slot1_lf_active |
                           slot0_lf_active;

  // Tell the BIU which slots want to start a linefill. The BIU must mask this
  // out for any slot that has a linefill hazard.
  assign stb_lf_req_o = {slot4_lf_req,
                         slot3_lf_req,
                         slot2_lf_req,
                         slot1_lf_req,
                         slot0_lf_req};

  // Determine which slot making a linefill request is the earliest.
  assign stb_lf_earliest_slot_o = {slot4_lf_req & ~|slot4_earlier_lf,
                                   slot3_lf_req & ~|slot3_earlier_lf,
                                   slot2_lf_req & ~|slot2_earlier_lf,
                                   slot1_lf_req & ~|slot1_earlier_lf,
                                   slot0_lf_req & ~|slot0_earlier_lf};

  // Tell the BIU which slots want to merge data into a linefill.
  assign stb_lf_merge_o = {slot4_lf_merge,
                           slot3_lf_merge,
                           slot2_lf_merge,
                           slot1_lf_merge,
                           slot0_lf_merge};

  // Indicate to the BIU if a slot is writing to the cache, so that if there is
  // a matching linefill then the BIU can mark it as dirty.
  assign stb_slot_cachewrite_m1_o = slots_state_cachewritem1;


  //----------------------------------------------------------------------------
  // Address request arbitration
  //----------------------------------------------------------------------------

  // Give data priority to the earliest slot that wants or might want it. If no
  // slot wants it then select the earliest idle slot as that slot might make a
  // CP15 or BIU write request as soon as it is activated.
  assign slots_want_ar_priority_earliest = {slot4_wants_ar_priority &
                                            ~|(slot4_earlier & {slot3_wants_ar_priority,
                                                                slot2_wants_ar_priority,
                                                                slot1_wants_ar_priority,
                                                                slot0_wants_ar_priority}),
                                            slot3_wants_ar_priority &
                                            ~|(slot3_earlier & {slot4_wants_ar_priority,
                                                                slot2_wants_ar_priority,
                                                                slot1_wants_ar_priority,
                                                                slot0_wants_ar_priority}),
                                            slot2_wants_ar_priority &
                                            ~|(slot2_earlier & {slot4_wants_ar_priority,
                                                                slot3_wants_ar_priority,
                                                                slot1_wants_ar_priority,
                                                                slot0_wants_ar_priority}),
                                            slot1_wants_ar_priority &
                                            ~|(slot1_earlier & {slot4_wants_ar_priority,
                                                                slot3_wants_ar_priority,
                                                                slot2_wants_ar_priority,
                                                                slot0_wants_ar_priority}),
                                            slot0_wants_ar_priority &
                                            ~|(slot0_earlier & {slot4_wants_ar_priority,
                                                                slot3_wants_ar_priority,
                                                                slot2_wants_ar_priority,
                                                                slot1_wants_ar_priority})};
  
  assign slots_might_want_ar_priority_earliest = {slot4_might_want_ar_priority &
                                                  ~|(slot4_earlier & {slot3_might_want_ar_priority,
                                                                      slot2_might_want_ar_priority,
                                                                      slot1_might_want_ar_priority,
                                                                      slot0_might_want_ar_priority}),
                                                  slot3_might_want_ar_priority &
                                                  ~|(slot3_earlier & {slot4_might_want_ar_priority,
                                                                      slot2_might_want_ar_priority,
                                                                      slot1_might_want_ar_priority,
                                                                      slot0_might_want_ar_priority}),
                                                  slot2_might_want_ar_priority &
                                                  ~|(slot2_earlier & {slot4_might_want_ar_priority,
                                                                      slot3_might_want_ar_priority,
                                                                      slot1_might_want_ar_priority,
                                                                      slot0_might_want_ar_priority}),
                                                  slot1_might_want_ar_priority &
                                                  ~|(slot1_earlier & {slot4_might_want_ar_priority,
                                                                      slot3_might_want_ar_priority,
                                                                      slot2_might_want_ar_priority,
                                                                      slot0_might_want_ar_priority}),
                                                  slot0_might_want_ar_priority &
                                                  ~|(slot0_earlier & {slot4_might_want_ar_priority,
                                                                      slot3_might_want_ar_priority,
                                                                      slot2_might_want_ar_priority,
                                                                      slot1_might_want_ar_priority})};

  assign slots_want_ar_priority = {slot4_wants_ar_priority,
                                   slot3_wants_ar_priority,
                                   slot2_wants_ar_priority,
                                   slot1_wants_ar_priority,
                                   slot0_wants_ar_priority};

  assign slots_already_have_ar_priority = {slot4_already_has_ar_priority,
                                           slot3_already_has_ar_priority,
                                           slot2_already_has_ar_priority,
                                           slot1_already_has_ar_priority,
                                           slot0_already_has_ar_priority};

  assign slots_might_want_ar_priority = {slot4_might_want_ar_priority,
                                         slot3_might_want_ar_priority,
                                         slot2_might_want_ar_priority,
                                         slot1_might_want_ar_priority,
                                         slot0_might_want_ar_priority};

  assign slots_ar_suppress = {slot4_ar_suppress,
                              slot3_ar_suppress,
                              slot2_ar_suppress,
                              slot1_ar_suppress,
                              slot0_ar_suppress};

  assign next_ar_slot_select = (stb_ar_req & ~biu_stb_ar_ack_i) ? ar_slot_select :
                               |slots_want_ar_priority ? slots_want_ar_priority_earliest :
                               |slots_might_want_ar_priority ? slots_might_want_ar_priority_earliest :
                               slots_lowest_idle;
  
  assign ar_slot_select_en = dcu_stb_req_dc3_i |
                             (|slots_might_want_ar_priority) |
                             (|slots_want_ar_priority);

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ar_slot_select <= 5'b00000;
  end else if (ar_slot_select_en) begin
    ar_slot_select <= next_ar_slot_select;
  end

  assign slot0_has_ar_priority = slot0_wants_ar_priority & ar_slot_select[0];
  assign slot1_has_ar_priority = slot1_wants_ar_priority & ar_slot_select[1];
  assign slot2_has_ar_priority = slot2_wants_ar_priority & ar_slot_select[2];
  assign slot3_has_ar_priority = slot3_wants_ar_priority & ar_slot_select[3];
  assign slot4_has_ar_priority = slot4_wants_ar_priority & ar_slot_select[4];

  assign slot0_has_cleanunique_priority = slot0_wants_cleanunique_priority & ar_slot_select[0];
  assign slot1_has_cleanunique_priority = slot1_wants_cleanunique_priority & ar_slot_select[1];
  assign slot2_has_cleanunique_priority = slot2_wants_cleanunique_priority & ar_slot_select[2];
  assign slot3_has_cleanunique_priority = slot3_wants_cleanunique_priority & ar_slot_select[3];
  assign slot4_has_cleanunique_priority = slot4_wants_cleanunique_priority & ar_slot_select[4];

  assign slot0_has_write_addr_priority = slot0_wants_write_addr_priority & ar_slot_select[0];
  assign slot1_has_write_addr_priority = slot1_wants_write_addr_priority & ar_slot_select[1];
  assign slot2_has_write_addr_priority = slot2_wants_write_addr_priority & ar_slot_select[2];
  assign slot3_has_write_addr_priority = slot3_wants_write_addr_priority & ar_slot_select[3];
  assign slot4_has_write_addr_priority = slot4_wants_write_addr_priority & ar_slot_select[4];

  // Make a request to the SCU via the BIU address channel.
  assign stb_ar_req = |(slots_want_ar_priority & ar_slot_select) |
                      (|slots_already_have_ar_priority) &
                      ~|slots_ar_suppress;

  assign stb_ar_req_o = stb_ar_req;
  
  assign stb_ar_type_o = ({8{ar_slot_select[0]}} & slot0_type) |
                         ({8{ar_slot_select[1]}} & slot1_type) |
                         ({8{ar_slot_select[2]}} & slot2_type) |
                         ({8{ar_slot_select[3]}} & slot3_type) |
                         ({8{ar_slot_select[4]}} & slot4_type);


  assign stb_ar_excl_o = ((ar_slot_select[0] & slot0_ar_excl) |
                          (ar_slot_select[1] & slot1_ar_excl) |
                          (ar_slot_select[2] & slot2_ar_excl) |
                          (ar_slot_select[3] & slot3_ar_excl) |
                          (ar_slot_select[4] & slot4_ar_excl));

  assign stb_ar_addr = (({40{ar_slot_select[0]}} & slot0_ar_addr) |
                        ({40{ar_slot_select[1]}} & slot1_ar_addr) |
                        ({40{ar_slot_select[2]}} & slot2_ar_addr) |
                        ({40{ar_slot_select[3]}} & slot3_ar_addr) |
                        ({40{ar_slot_select[4]}} & slot4_ar_addr));

  assign stb_ar_addr_o = stb_ar_addr;

  assign stb_ar_asid_o = (({16{ar_slot_select[0]}} & slot0_cp15_asid) |
                          ({16{ar_slot_select[1]}} & slot1_cp15_asid) |
                          ({16{ar_slot_select[2]}} & slot2_cp15_asid) |
                          ({16{ar_slot_select[3]}} & slot3_cp15_asid) |
                          ({16{ar_slot_select[4]}} & slot4_cp15_asid));

  assign stb_ar_vmid_o = (({8{ar_slot_select[0]}} & slot0_cp15_vmid) |
                          ({8{ar_slot_select[1]}} & slot1_cp15_vmid) |
                          ({8{ar_slot_select[2]}} & slot2_cp15_vmid) |
                          ({8{ar_slot_select[3]}} & slot3_cp15_vmid) |
                          ({8{ar_slot_select[4]}} & slot4_cp15_vmid));

  assign stb_ar_va_o = ({25{ar_slot_select[0]}} & slot0_cp15_va) |
                       ({25{ar_slot_select[1]}} & slot1_cp15_va) |
                       ({25{ar_slot_select[2]}} & slot2_cp15_va) |
                       ({25{ar_slot_select[3]}} & slot3_cp15_va) |
                       ({25{ar_slot_select[4]}} & slot4_cp15_va);

  assign stb_ar_ns_dsc_o = ((ar_slot_select[0] & slot0_ar_ns) |
                            (ar_slot_select[1] & slot1_ar_ns) |
                            (ar_slot_select[2] & slot2_ar_ns) |
                            (ar_slot_select[3] & slot3_ar_ns) |
                            (ar_slot_select[4] & slot4_ar_ns));

  assign stb_ar_attrs_o = (({8{ar_slot_select[0]}} & slot0_attrs) |
                           ({8{ar_slot_select[1]}} & slot1_attrs) |
                           ({8{ar_slot_select[2]}} & slot2_attrs) |
                           ({8{ar_slot_select[3]}} & slot3_attrs) |
                           ({8{ar_slot_select[4]}} & slot4_attrs));

  assign stb_ar_priv_o = ((ar_slot_select[0] & slot0_ar_priv) |
                          (ar_slot_select[1] & slot1_ar_priv) |
                          (ar_slot_select[2] & slot2_ar_priv) |
                          (ar_slot_select[3] & slot3_ar_priv) |
                          (ar_slot_select[4] & slot4_ar_priv));

  // Pick the ID to use based on the slot being sent.
  assign stb_ar_id_o = (({5{ar_slot_select[0]}} & `CA53_RID_STB0) |
                        ({5{ar_slot_select[1]}} & `CA53_RID_STB1) |
                        ({5{ar_slot_select[2]}} & `CA53_RID_STB2) |
                        ({5{ar_slot_select[3]}} & `CA53_RID_STB3) |
                        ({5{ar_slot_select[4]}} & `CA53_RID_STB4));

  // The SCU needs the way for CleanUnique operations.
  assign stb_ar_way_o = (({2{ar_slot_select[0]}} & slot0_ar_way) |
                         ({2{ar_slot_select[1]}} & slot1_ar_way) |
                         ({2{ar_slot_select[2]}} & slot2_ar_way) |
                         ({2{ar_slot_select[3]}} & slot3_ar_way) |
                         ({2{ar_slot_select[4]}} & slot4_ar_way));

  // Decode the slot ID when the SCU has acknowledged the request.
  assign slot0_ar_resp_valid = biu_stb_ar_resp_valid_i & (biu_stb_ar_resp_id_i == `CA53_RID_STB0);
  assign slot1_ar_resp_valid = biu_stb_ar_resp_valid_i & (biu_stb_ar_resp_id_i == `CA53_RID_STB1);
  assign slot2_ar_resp_valid = biu_stb_ar_resp_valid_i & (biu_stb_ar_resp_id_i == `CA53_RID_STB2);
  assign slot3_ar_resp_valid = biu_stb_ar_resp_valid_i & (biu_stb_ar_resp_id_i == `CA53_RID_STB3);
  assign slot4_ar_resp_valid = biu_stb_ar_resp_valid_i & (biu_stb_ar_resp_id_i == `CA53_RID_STB4);


  //----------------------------------------------------------------------------
  // Early request indication
  //----------------------------------------------------------------------------

  // The STB gives an early indication when making a request for which the BIU
  // might make and AR request to the SCU in the following cycle. This is used
  // to enable the SCU's clock gate for the CPU slave request buffers. The BIU
  // might make an AR request to the SCU for an AR request from the STB, or for
  // a linefill request from the STB.
  assign stb_ar_early_req_o  = stb_ar_early_req_m3 |
                               stb_ar_early_req_non_m3;

  assign stb_ar_early_req_m3 = (slot0_state_special |
                                slot1_state_special |
                                slot2_state_special |
                                slot3_state_special |
                                slot4_state_special) & (~tag_hit_shared_m3[1] |
                                                        tag_hit_shared_m3[0]);

  assign next_stb_ar_early_req_non_m3 = slot0_might_req |
                                        slot1_might_req |
                                        slot2_might_req |
                                        slot3_might_req |
                                        slot4_might_req;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      stb_ar_early_req_non_m3 <= 1'b0;
    end else begin
      stb_ar_early_req_non_m3 <= next_stb_ar_early_req_non_m3;
    end

  
  //----------------------------------------------------------------------------
  // Force non-mergeable request
  //----------------------------------------------------------------------------

  // The STB must prevent a continual stream of stores from continually merging
  // so that stores become observable in finite time and a snoop request to a
  // particular line is not blocked indefinitely.
  //
  // Two scenarios must be accounted for:
  // 1) The DCU continually merges into the same STB slot, preventing the slot
  //    from making progress in the CACHEWRITEREQ or BIUDATA states.
  // 2) The DCU continually activates STB slots for beats marked as sameline,
  //    resulting in a 'last' beat never being sent to the BIU.
  //
  // For both scenarios, a flag is set after multiple assertions of the max
  // drain signal. The flag is used to tell the DCU to force slots to become
  // non-mergeable, allowing them to drain.

  assign next_stb_force_non_mergeable = stb_force_non_mergeable ?
                                        // Previous request not actioned.
                                        // It might no longer be necessary
                                        // but a handshake provides more
                                        // robust protection against a
                                        // continual stream of stores.
                                        ~dcu_force_non_mergeable_dc3_i :
                                        // New request covering both
                                        // scenarios (but only pulsed 
                                        // on senario 1).
                                        |slots_force_non_mergeable;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      stb_force_non_mergeable <= 1'b0;
    end else begin
      stb_force_non_mergeable <= next_stb_force_non_mergeable;
    end

  assign stb_force_non_mergeable_o = stb_force_non_mergeable;


  //----------------------------------------------------------------------------
  // DMB and DSB requests
  //----------------------------------------------------------------------------

  assign stb_block_loads_dc1_o = (slot0_block_loads_dc1 |
                                  slot1_block_loads_dc1 |
                                  slot2_block_loads_dc1 |
                                  slot3_block_loads_dc1 |
                                  slot4_block_loads_dc1);


  //----------------------------------------------------------------------------
  // Miscellaneous outputs
  //----------------------------------------------------------------------------

  assign stb_slots_valid_o = slots_valid;

  assign stb_slots_emptying_o = slots_emptying;

  assign stb_slot0_addr_o = slot0_addr;
  assign stb_slot1_addr_o = slot1_addr;
  assign stb_slot2_addr_o = slot2_addr;
  assign stb_slot3_addr_o = slot3_addr;
  assign stb_slot4_addr_o = slot4_addr;

  assign stb_slots_ns_dsc_o = {slot4_ns,
                               slot3_ns,
                               slot2_ns,
                               slot1_ns,
                               slot0_ns};

  assign stb_slot0_way_o = slot0_way;
  assign stb_slot1_way_o = slot1_way;
  assign stb_slot2_way_o = slot2_way;
  assign stb_slot3_way_o = slot3_way;
  assign stb_slot4_way_o = slot4_way;

  assign stb_slot0_attrs_o = slot0_attrs;
  assign stb_slot1_attrs_o = slot1_attrs;
  assign stb_slot2_attrs_o = slot2_attrs;
  assign stb_slot3_attrs_o = slot3_attrs;
  assign stb_slot4_attrs_o = slot4_attrs;

  assign stb_slots_dev_ng_o = {slot4_valid & ~`CA53_MEM_MERGEABLE(slot4_attrs) & ~slot4_cp15,
                               slot3_valid & ~`CA53_MEM_MERGEABLE(slot3_attrs) & ~slot3_cp15,
                               slot2_valid & ~`CA53_MEM_MERGEABLE(slot2_attrs) & ~slot2_cp15,
                               slot1_valid & ~`CA53_MEM_MERGEABLE(slot1_attrs) & ~slot1_cp15,
                               slot0_valid & ~`CA53_MEM_MERGEABLE(slot0_attrs) & ~slot0_cp15};

  assign stb_slots_dsb_o = {slot4_dsb,
                            slot3_dsb,
                            slot2_dsb,
                            slot1_dsb,
                            slot0_dsb};

  assign stb_strex_failed_o = (slot0_excl_fail |
                               slot1_excl_fail |
                               slot2_excl_fail |
                               slot3_excl_fail |
                               slot4_excl_fail);

  assign stb_cacheable_strex_done_o = (slot0_excl_done |
                                       slot1_excl_done |
                                       slot2_excl_done |
                                       slot3_excl_done |
                                       slot4_excl_done);

  assign stb_block_ccb_o = (slot0_block_ccb |
                            slot1_block_ccb |
                            slot2_block_ccb |
                            slot3_block_ccb |
                            slot4_block_ccb);

  // Signal an event whenever the DCU gets stalled because a slot is not available.
  assign next_stb_evnt_stb_stall = dcu_stb_req_dc3_i & ~|dcu_store_merge_dc3_i & (&slots_valid) & ~dpu_kill_wr_i;

  always @(posedge clk_stb or negedge reset_n)
  if (~reset_n) begin
    stb_evnt_stb_stall <= 1'b0;
  end else begin
    stb_evnt_stb_stall <= next_stb_evnt_stb_stall;
  end

  assign stb_evnt_stb_stall_o = stb_evnt_stb_stall;


  //----------------------------------------------------------------------------
  // Instantiate the slots
  //----------------------------------------------------------------------------

  assign dcu_stb_mergeable_dc3 = `CA53_MEM_MERGEABLE(dcu_stb_attrs_dc3_i);

  ca53stb_slot `CA53_STB_PARAM_INST u_slot0 (
    /*ARMAUTO*/
    //TEMPLATE s/slot_/slot0_/
    //TEMPLATE s/slota_/slot1_/
    //TEMPLATE s/slotb_/slot2_/
    //TEMPLATE s/slotc_/slot3_/
    //TEMPLATE s/slotd_/slot4_/
    .slot_load_sameline_dc3_i              (dcu_load_sameline_dc3_i[0]),
    .slot_store_merge_dc3_i                (dcu_store_merge_dc3_i[0]),
    .slot_biu_ev_hazard_i                  (biu_ev_hazard_i[0]),
    .slot_biu_lf_hazard_way_i              (biu_lf_hazard_way_slot0_i),
    // Inputs
    .clk                                   (clk),
    .slot_clk                              (slot0_clk),
    .reset_n                               (reset_n),
    .slota_valid_i                         (slot1_valid),
    .slota_emptying_i                      (slot1_emptying),
    .slota_state_biureq_i                  (slot1_state_biureq),
    .slota_state_biuack_i                  (slot1_state_biuack),
    .slota_state_biuresp_i                 (slot1_state_biuresp),
    .slota_state_biudata_i                 (slot1_state_biudata),
    .slota_state_lfreq_i                   (slot1_state_lfreq),
    .slota_state_lookupreq_i               (slot1_state_lookupreq),
    .slota_state_lookupm1_i                (slot1_state_lookupm1),
    .slota_state_lookupm2_i                (slot1_state_lookupm2),
    .slota_state_tagwrite_i                (slot1_state_tagwrite),
    .slota_state_cachemerge_i              (slot1_state_cachemerge),
    .slota_state_cachereadm0_i             (slot1_state_cachereadm0),
    .slota_state_cachereadm1_i             (slot1_state_cachereadm1),
    .slota_state_cachereadm2_i             (slot1_state_cachereadm2),
    .slota_state_cacheecc_i                (slot1_state_cacheecc),
    .slota_state_cachewritereq_i           (slot1_state_cachewritereq),
    .slota_state_cachewritem1_i            (slot1_state_cachewritem1),
    .slota_state_cp15resp_i                (slot1_state_cp15resp),
    .slota_state_cleanunique_req_i         (slot1_state_cleanunique_req),
    .slota_state_cleanunique_ack_i         (slot1_state_cleanunique_ack),
    .slota_state_cleanunique_resp_i        (slot1_state_cleanunique_resp),
    .slota_mergeable_i                     (slot1_mergeable),
    .slota_barriered_i                     (slot1_barriered),
    .slota_has_lookup_priority_i           (slot1_has_lookup_priority),
    .slota_has_tagwrite_priority_i         (slot1_has_tagwrite_priority),
    .slota_ar_resp_valid_i                 (slot1_ar_resp_valid),
    .slota_has_write_addr_priority_i       (slot1_has_write_addr_priority),
    .slota_has_cleanunique_priority_i      (slot1_has_cleanunique_priority),
    .slota_way_i                           (slot1_way[1:0]),
    .slota_migratory_i                     (slot1_migratory),
    .slota_ev_hazard_i                     (slot1_ev_hazard),
    .slota_ev_hz_seen_i                    (slot1_ev_hz_seen),
    .slota_lf_hz_seen_i                    (slot1_lf_hz_seen),
    .slota_lf_hz_capture_i                 (slot1_lf_hz_capture),
    .slota_coherent_i                      (slot1_coherent),
    .slota_biu_lf_hazard_i                 (slot1_biu_lf_hazard),
    .slota_l2dbid_i                        (slot1_l2dbid[3:0]),
    .slota_no_alloc_on_miss_i              (slot1_no_alloc_on_miss),
    .slota_sameline_beat_count_i           (slot1_sameline_beat_count[2:0]),
    .slota_wants_write_data_priority_i     (slot1_wants_write_data_priority),
    .slota_write_accept_i                  (slot1_write_accept),
    .slota_more_dev_expected_i             (slot1_more_dev_expected),
    .slota_lf_req_i                        (slot1_lf_req),
    .slota_has_cleanunique_duty_i          (slot1_has_cleanunique_duty),
    .slota_load_sameline_seen_i            (slot1_load_sameline_seen),
    .slota_load_sameline_i                 (slot1_load_sameline),
    .slotb_valid_i                         (slot2_valid),
    .slotb_emptying_i                      (slot2_emptying),
    .slotb_state_biureq_i                  (slot2_state_biureq),
    .slotb_state_biuack_i                  (slot2_state_biuack),
    .slotb_state_biuresp_i                 (slot2_state_biuresp),
    .slotb_state_biudata_i                 (slot2_state_biudata),
    .slotb_state_lfreq_i                   (slot2_state_lfreq),
    .slotb_state_lookupreq_i               (slot2_state_lookupreq),
    .slotb_state_lookupm1_i                (slot2_state_lookupm1),
    .slotb_state_lookupm2_i                (slot2_state_lookupm2),
    .slotb_state_tagwrite_i                (slot2_state_tagwrite),
    .slotb_state_cachemerge_i              (slot2_state_cachemerge),
    .slotb_state_cachereadm0_i             (slot2_state_cachereadm0),
    .slotb_state_cachereadm1_i             (slot2_state_cachereadm1),
    .slotb_state_cachereadm2_i             (slot2_state_cachereadm2),
    .slotb_state_cacheecc_i                (slot2_state_cacheecc),
    .slotb_state_cachewritereq_i           (slot2_state_cachewritereq),
    .slotb_state_cachewritem1_i            (slot2_state_cachewritem1),
    .slotb_state_cp15resp_i                (slot2_state_cp15resp),
    .slotb_state_cleanunique_req_i         (slot2_state_cleanunique_req),
    .slotb_state_cleanunique_ack_i         (slot2_state_cleanunique_ack),
    .slotb_state_cleanunique_resp_i        (slot2_state_cleanunique_resp),
    .slotb_mergeable_i                     (slot2_mergeable),
    .slotb_barriered_i                     (slot2_barriered),
    .slotb_has_lookup_priority_i           (slot2_has_lookup_priority),
    .slotb_has_tagwrite_priority_i         (slot2_has_tagwrite_priority),
    .slotb_ar_resp_valid_i                 (slot2_ar_resp_valid),
    .slotb_has_write_addr_priority_i       (slot2_has_write_addr_priority),
    .slotb_has_cleanunique_priority_i      (slot2_has_cleanunique_priority),
    .slotb_way_i                           (slot2_way[1:0]),
    .slotb_migratory_i                     (slot2_migratory),
    .slotb_ev_hazard_i                     (slot2_ev_hazard),
    .slotb_ev_hz_seen_i                    (slot2_ev_hz_seen),
    .slotb_lf_hz_seen_i                    (slot2_lf_hz_seen),
    .slotb_lf_hz_capture_i                 (slot2_lf_hz_capture),
    .slotb_coherent_i                      (slot2_coherent),
    .slotb_biu_lf_hazard_i                 (slot2_biu_lf_hazard),
    .slotb_l2dbid_i                        (slot2_l2dbid[3:0]),
    .slotb_no_alloc_on_miss_i              (slot2_no_alloc_on_miss),
    .slotb_sameline_beat_count_i           (slot2_sameline_beat_count[2:0]),
    .slotb_wants_write_data_priority_i     (slot2_wants_write_data_priority),
    .slotb_write_accept_i                  (slot2_write_accept),
    .slotb_more_dev_expected_i             (slot2_more_dev_expected),
    .slotb_lf_req_i                        (slot2_lf_req),
    .slotb_has_cleanunique_duty_i          (slot2_has_cleanunique_duty),
    .slotb_load_sameline_seen_i            (slot2_load_sameline_seen),
    .slotb_load_sameline_i                 (slot2_load_sameline),
    .slotc_valid_i                         (slot3_valid),
    .slotc_emptying_i                      (slot3_emptying),
    .slotc_state_biureq_i                  (slot3_state_biureq),
    .slotc_state_biuack_i                  (slot3_state_biuack),
    .slotc_state_biuresp_i                 (slot3_state_biuresp),
    .slotc_state_biudata_i                 (slot3_state_biudata),
    .slotc_state_lfreq_i                   (slot3_state_lfreq),
    .slotc_state_lookupreq_i               (slot3_state_lookupreq),
    .slotc_state_lookupm1_i                (slot3_state_lookupm1),
    .slotc_state_lookupm2_i                (slot3_state_lookupm2),
    .slotc_state_tagwrite_i                (slot3_state_tagwrite),
    .slotc_state_cachemerge_i              (slot3_state_cachemerge),
    .slotc_state_cachereadm0_i             (slot3_state_cachereadm0),
    .slotc_state_cachereadm1_i             (slot3_state_cachereadm1),
    .slotc_state_cachereadm2_i             (slot3_state_cachereadm2),
    .slotc_state_cacheecc_i                (slot3_state_cacheecc),
    .slotc_state_cachewritereq_i           (slot3_state_cachewritereq),
    .slotc_state_cachewritem1_i            (slot3_state_cachewritem1),
    .slotc_state_cp15resp_i                (slot3_state_cp15resp),
    .slotc_state_cleanunique_req_i         (slot3_state_cleanunique_req),
    .slotc_state_cleanunique_ack_i         (slot3_state_cleanunique_ack),
    .slotc_state_cleanunique_resp_i        (slot3_state_cleanunique_resp),
    .slotc_mergeable_i                     (slot3_mergeable),
    .slotc_barriered_i                     (slot3_barriered),
    .slotc_has_lookup_priority_i           (slot3_has_lookup_priority),
    .slotc_has_tagwrite_priority_i         (slot3_has_tagwrite_priority),
    .slotc_ar_resp_valid_i                 (slot3_ar_resp_valid),
    .slotc_has_write_addr_priority_i       (slot3_has_write_addr_priority),
    .slotc_has_cleanunique_priority_i      (slot3_has_cleanunique_priority),
    .slotc_way_i                           (slot3_way[1:0]),
    .slotc_migratory_i                     (slot3_migratory),
    .slotc_ev_hazard_i                     (slot3_ev_hazard),
    .slotc_ev_hz_seen_i                    (slot3_ev_hz_seen),
    .slotc_lf_hz_seen_i                    (slot3_lf_hz_seen),
    .slotc_lf_hz_capture_i                 (slot3_lf_hz_capture),
    .slotc_coherent_i                      (slot3_coherent),
    .slotc_biu_lf_hazard_i                 (slot3_biu_lf_hazard),
    .slotc_l2dbid_i                        (slot3_l2dbid[3:0]),
    .slotc_no_alloc_on_miss_i              (slot3_no_alloc_on_miss),
    .slotc_sameline_beat_count_i           (slot3_sameline_beat_count[2:0]),
    .slotc_wants_write_data_priority_i     (slot3_wants_write_data_priority),
    .slotc_write_accept_i                  (slot3_write_accept),
    .slotc_more_dev_expected_i             (slot3_more_dev_expected),
    .slotc_lf_req_i                        (slot3_lf_req),
    .slotc_has_cleanunique_duty_i          (slot3_has_cleanunique_duty),
    .slotc_load_sameline_seen_i            (slot3_load_sameline_seen),
    .slotc_load_sameline_i                 (slot3_load_sameline),
    .slotd_valid_i                         (slot4_valid),
    .slotd_emptying_i                      (slot4_emptying),
    .slotd_state_biureq_i                  (slot4_state_biureq),
    .slotd_state_biuack_i                  (slot4_state_biuack),
    .slotd_state_biuresp_i                 (slot4_state_biuresp),
    .slotd_state_biudata_i                 (slot4_state_biudata),
    .slotd_state_lfreq_i                   (slot4_state_lfreq),
    .slotd_state_lookupreq_i               (slot4_state_lookupreq),
    .slotd_state_lookupm1_i                (slot4_state_lookupm1),
    .slotd_state_lookupm2_i                (slot4_state_lookupm2),
    .slotd_state_tagwrite_i                (slot4_state_tagwrite),
    .slotd_state_cachemerge_i              (slot4_state_cachemerge),
    .slotd_state_cachereadm0_i             (slot4_state_cachereadm0),
    .slotd_state_cachereadm1_i             (slot4_state_cachereadm1),
    .slotd_state_cachereadm2_i             (slot4_state_cachereadm2),
    .slotd_state_cacheecc_i                (slot4_state_cacheecc),
    .slotd_state_cachewritereq_i           (slot4_state_cachewritereq),
    .slotd_state_cachewritem1_i            (slot4_state_cachewritem1),
    .slotd_state_cp15resp_i                (slot4_state_cp15resp),
    .slotd_state_cleanunique_req_i         (slot4_state_cleanunique_req),
    .slotd_state_cleanunique_ack_i         (slot4_state_cleanunique_ack),
    .slotd_state_cleanunique_resp_i        (slot4_state_cleanunique_resp),
    .slotd_mergeable_i                     (slot4_mergeable),
    .slotd_barriered_i                     (slot4_barriered),
    .slotd_has_lookup_priority_i           (slot4_has_lookup_priority),
    .slotd_has_tagwrite_priority_i         (slot4_has_tagwrite_priority),
    .slotd_ar_resp_valid_i                 (slot4_ar_resp_valid),
    .slotd_has_write_addr_priority_i       (slot4_has_write_addr_priority),
    .slotd_has_cleanunique_priority_i      (slot4_has_cleanunique_priority),
    .slotd_way_i                           (slot4_way[1:0]),
    .slotd_migratory_i                     (slot4_migratory),
    .slotd_ev_hazard_i                     (slot4_ev_hazard),
    .slotd_ev_hz_seen_i                    (slot4_ev_hz_seen),
    .slotd_lf_hz_seen_i                    (slot4_lf_hz_seen),
    .slotd_lf_hz_capture_i                 (slot4_lf_hz_capture),
    .slotd_coherent_i                      (slot4_coherent),
    .slotd_biu_lf_hazard_i                 (slot4_biu_lf_hazard),
    .slotd_l2dbid_i                        (slot4_l2dbid[3:0]),
    .slotd_no_alloc_on_miss_i              (slot4_no_alloc_on_miss),
    .slotd_sameline_beat_count_i           (slot4_sameline_beat_count[2:0]),
    .slotd_wants_write_data_priority_i     (slot4_wants_write_data_priority),
    .slotd_write_accept_i                  (slot4_write_accept),
    .slotd_more_dev_expected_i             (slot4_more_dev_expected),
    .slotd_lf_req_i                        (slot4_lf_req),
    .slotd_has_cleanunique_duty_i          (slot4_has_cleanunique_duty),
    .slotd_load_sameline_seen_i            (slot4_load_sameline_seen),
    .slotd_load_sameline_i                 (slot4_load_sameline),
    .dcu_pa_dc2_i                          (dcu_pa_dc2_i[39:3]),
    .dcu_ns_dsc_dc2_i                      (dcu_ns_dsc_dc2_i),
    .dcu_attrs_dc2_i                       (dcu_attrs_dc2_i[7:0]),
    .slot_new_req_dc3_i                    (slot0_new_req_dc3),
    .dcu_pa_dc3_i                          (dcu_pa_dc3_i[39:0]),
    .dcu_ns_dsc_dc3_i                      (dcu_ns_dsc_dc3_i),
    .dcu_priv_dc3_i                        (dcu_priv_dc3_i),
    .dcu_stb_exclusive_dc3_i               (dcu_stb_exclusive_dc3_i),
    .dcu_stb_mergeable_dc3_i               (dcu_stb_mergeable_dc3),
    .dcu_store_cp15_dc3_i                  (dcu_store_cp15_dc3_i),
    .dcu_stlr_dc3_i                        (dcu_stlr_dc3_i),
    .dcu_stb_attrs_dc3_i                   (dcu_stb_attrs_dc3_i[7:0]),
    .dpu_st_data_wr_i                      (dpu_st_data_wr_i[127:0]),
    .dcu_store_bls_dc3_i                   (dcu_store_bls_dc3_i[15:0]),
    .dcu_store_last_dc3_i                  (dcu_store_last_dc3_i),
    .dcu_store_dsb_dc3_i                   (dcu_store_dsb_dc3_i),
    .dcu_store_dmb_dc3_i                   (dcu_store_dmb_dc3_i),
    .dcu_force_non_mergeable_dc3_i         (dcu_force_non_mergeable_dc3_i),
    .slota_new_req_dc3_i                   (slot1_new_req_dc3),
    .slotb_new_req_dc3_i                   (slot2_new_req_dc3),
    .slotc_new_req_dc3_i                   (slot3_new_req_dc3),
    .slotd_new_req_dc3_i                   (slot4_new_req_dc3),
    .slot_dcu_store_sameline_dc3_i         (slot0_dcu_store_sameline_dc3),
    .slota_dcu_store_sameline_dc3_i        (slot1_dcu_store_sameline_dc3),
    .slotb_dcu_store_sameline_dc3_i        (slot2_dcu_store_sameline_dc3),
    .slotc_dcu_store_sameline_dc3_i        (slot3_dcu_store_sameline_dc3),
    .slotd_dcu_store_sameline_dc3_i        (slot4_dcu_store_sameline_dc3),
    .dcu_stb_tag_has_priority_m0_i         (dcu_stb_tag_has_priority_m0_i),
    .dcu_stb_data_has_priority_m0_i        (dcu_stb_data_has_priority_m0_i),
    .dcu_stb_tag_ack_m1_i                  (dcu_stb_tag_ack_m1_i),
    .dcu_stb_data_ack_m1_i                 (dcu_stb_data_ack_m1_i),
    .dcu_stb_tag_hit_m2_i                  (dcu_stb_tag_hit_m2_i[3:0]),
    .dcu_stb_tag_shared_m2_i               (dcu_stb_tag_shared_m2_i),
    .dcu_stb_tag_migratory_m2_i            (dcu_stb_tag_migratory_m2_i),
    .dcu_stb_victim_way_m2_i               (dcu_stb_victim_way_m2_i[3:0]),
    .dcu_stb_read_data_m2_i                (dcu_stb_read_data_m2_i[127:0]),
    .dcu_stb_read_wls_m2_i                 (dcu_stb_read_wls_m2[3:0]),
    .dcu_ecc_data_err_m3_i                 (dcu_ecc_data_err_m3_i),
    .dcu_ecc_in_progress_i                 (dcu_ecc_in_progress_i),
    .tag_hit_shared_m3_i                   (tag_hit_shared_m3[1:0]),
    .tag_ecc_err_m3_i                      (tag_ecc_err_m3),
    .biu_stb_write_accept_i                (biu_stb_write_accept_i),
    .slot_biu_lf_hazard_i                  (slot0_biu_lf_hazard),
    .slot_biu_lf_real_hazard_i             (slot0_biu_lf_real_hazard),
    .slot_biu_lf_hazard_migratory_i        (slot0_biu_lf_hazard_migratory),
    .slot_biu_lf_serialized_i              (slot0_biu_lf_serialized),
    .slot_biu_lf_can_merge_i               (slot0_biu_lf_can_merge),
    .biu_dirty_lf_in_progress_i            (biu_dirty_lf_in_progress_i),
    .biu_excl_lf_in_progress_i             (biu_excl_lf_in_progress_i),
    .biu_stb_ar_ack_i                      (biu_stb_ar_ack_i),
    .biu_stb_ar_resp_i                     (biu_stb_ar_resp_i[1:0]),
    .slot_has_ar_priority_i                (slot0_has_ar_priority),
    .dc_size_i                             (dc_size_i[2:0]),
    .slot_force_drain_i                    (slot0_force_drain),
    .slot_force_drain_biudata_i            (slot0_force_drain_biudata),
    .stb_cycle_count_127_i                 (stb_cycle_count_127),
    .stb_cycle_count_1023_i                (stb_cycle_count_1023),
    .biu_read_alloc_mode_i                 (biu_read_alloc_mode_i),
    .next_dev_bursting_i                   (next_dev_bursting),
    .dev_delay_ar_req_i                    (dev_delay_ar_req),
    .dcu_leaving_dc2_i                     (dcu_leaving_dc2_i),
    .dcu_store_dc2_i                       (dcu_store_dc2_i),
    .dpu_kill_wr_i                         (dpu_kill_wr_i),
    .slot_has_lookup_priority_i            (slot0_has_lookup_priority),
    .slot_has_cache_data_priority_i        (slot0_has_cache_data_priority),
    .slot_has_tagwrite_priority_i          (slot0_has_tagwrite_priority),
    .slot_has_write_addr_priority_i        (slot0_has_write_addr_priority),
    .slot_has_cleanunique_priority_i       (slot0_has_cleanunique_priority),
    .slot_ar_resp_valid_i                  (slot0_ar_resp_valid),
    .biu_stb_ar_resp_l2dbid_i              (biu_stb_ar_resp_l2dbid_i[3:0]),
    .dcu_ccb_index_i                       (dcu_ccb_index_i[13:6]),
    .dcu_ccb_ways_i                        (dcu_ccb_ways_i[3:0]),
    .dcu_ccb_req_valid_i                   (dcu_ccb_req_valid_i),
    .dcu_exclusive_monitor_i               (dcu_exclusive_monitor_i),
    .dvm_sync_needed_i                     (dvm_sync_needed),
    .propagate_barrier_i                   (propagate_barrier),
    .dpu_disable_dmb_i                     (dpu_disable_dmb_i),
    .dvm_complete_i                        (dvm_complete),
    .stb_force_non_mergeable_i             (stb_force_non_mergeable),
    // Outputs
    .slot_valid_o                          (slot0_valid),
    .slot_emptying_o                       (slot0_emptying),
    .slot_state_biureq_o                   (slot0_state_biureq),
    .slot_state_biumerge_o                 (slot0_state_biumerge),
    .slot_state_biuack_o                   (slot0_state_biuack),
    .slot_state_biuresp_o                  (slot0_state_biuresp),
    .slot_state_biudata_o                  (slot0_state_biudata),
    .slot_state_lfreq_o                    (slot0_state_lfreq),
    .slot_state_lookupreq_o                (slot0_state_lookupreq),
    .slot_state_lookupm1_o                 (slot0_state_lookupm1),
    .slot_state_lookupm2_o                 (slot0_state_lookupm2),
    .slot_state_special_o                  (slot0_state_special),
    .slot_state_tagwrite_o                 (slot0_state_tagwrite),
    .slot_state_cachemerge_o               (slot0_state_cachemerge),
    .slot_state_cachewritereq_o            (slot0_state_cachewritereq),
    .slot_state_cachereadm0_o              (slot0_state_cachereadm0),
    .slot_state_cachereadm1_o              (slot0_state_cachereadm1),
    .slot_state_cachereadm2_o              (slot0_state_cachereadm2),
    .slot_state_cacheecc_o                 (slot0_state_cacheecc),
    .slot_state_cachewritem1_o             (slot0_state_cachewritem1),
    .slot_state_cp15resp_o                 (slot0_state_cp15resp),
    .slot_state_cleanunique_req_o          (slot0_state_cleanunique_req),
    .slot_state_cleanunique_ack_o          (slot0_state_cleanunique_ack),
    .slot_state_cleanunique_resp_o         (slot0_state_cleanunique_resp),
    .slot_state_barrier_ack_o              (slot0_state_barrier_ack),
    .slot_write_sync_cmo_ack_o             (slot0_write_sync_cmo_ack),
    .slot_attrs_o                          (slot0_attrs[7:0]),
    .slot_addr_o                           (slot0_addr[39:0]),
    .slot_ns_o                             (slot0_ns),
    .slot_data_o                           (slot0_data[127:0]),
    .slot_cache_bls_o                      (slot0_cache_bls[15:0]),
    .slot_write_data_o                     (slot0_write_data[127:0]),
    .slot_write_bls_o                      (slot0_write_bls[15:0]),
    .slot_write_chunk_o                    (slot0_write_chunk[1:0]),
    .slot_write_last_o                     (slot0_write_last),
    .slot_mergeable_o                      (slot0_mergeable),
    .slot_barriered_o                      (slot0_barriered),
    .slot_earlier_o                        (slot0_earlier[3:0]),
    .slot_earlier_lf_o                     (slot0_earlier_lf[3:0]),
    .slot_cp15_o                           (slot0_cp15),
    .slot_dsb_o                            (slot0_dsb),
    .slot_way_onehot_o                     (slot0_way_onehot[3:0]),
    .slot_way_o                            (slot0_way[1:0]),
    .slot_migratory_o                      (slot0_migratory),
    .slot_ar_way_o                         (slot0_ar_way[1:0]),
    .slot_lf_hz_seen_o                     (slot0_lf_hz_seen),
    .slot_lf_hz_capture_o                  (slot0_lf_hz_capture),
    .slot_coherent_o                       (slot0_coherent),
    .slot_l2dbid_o                         (slot0_l2dbid[3:0]),
    .slot_no_alloc_on_miss_o               (slot0_no_alloc_on_miss),
    .slot_more_dev_expected_o              (slot0_more_dev_expected),
    .slot_sameline_beat_count_o            (slot0_sameline_beat_count[2:0]),
    .slot_has_cleanunique_duty_o           (slot0_has_cleanunique_duty),
    .slot_load_sameline_seen_o             (slot0_load_sameline_seen),
    .slot_load_sameline_o                  (slot0_load_sameline),
    .slot_can_merge_dc2_o                  (slot0_can_merge_dc2),
    .slot_sameline_dc2_o                   (slot0_sameline_dc2),
    .slot_load_sameline_dc2_o              (slot0_load_sameline_dc2),
    .slot_attr_mismatch_dc2_o              (slot0_attr_mismatch_dc2),
    .slot_hit_dc2_o                        (slot0_hit_dc2[15:0]),
    .slot_wants_write_data_priority_o      (slot0_wants_write_data_priority),
    .slot_has_write_data_priority_o        (slot0_has_write_data_priority),
    .slot_write_data_suppress_o            (slot0_write_data_suppress),
    .slot_write_accept_o                   (slot0_write_accept),
    .slot_lf_active_o                      (slot0_lf_active),
    .slot_lf_req_o                         (slot0_lf_req),
    .slot_lf_merge_o                       (slot0_lf_merge),
    .slot_ev_hazard_o                      (slot0_ev_hazard),
    .slot_ev_hz_seen_o                     (slot0_ev_hz_seen),
    .slot_wants_ar_priority_o              (slot0_wants_ar_priority),
    .slot_might_want_ar_priority_o         (slot0_might_want_ar_priority),
    .slot_already_has_ar_priority_o        (slot0_already_has_ar_priority),
    .slot_ar_suppress_o                    (slot0_ar_suppress),
    .slot_ar_addr_o                        (slot0_ar_addr[39:0]),
    .slot_ar_ns_o                          (slot0_ar_ns),
    .slot_ar_priv_o                        (slot0_ar_priv),
    .slot_ar_excl_o                        (slot0_ar_excl),
    .slot_cp15_asid_o                      (slot0_cp15_asid[15:0]),
    .slot_cp15_vmid_o                      (slot0_cp15_vmid[7:0]),
    .slot_cp15_va_o                        (slot0_cp15_va[24:0]),
    .slot_wants_lookup_priority_o          (slot0_wants_lookup_priority),
    .slot_might_want_cache_data_priority_o (slot0_might_want_cache_data_priority),
    .slot_wants_cache_data_priority_o      (slot0_wants_cache_data_priority),
    .slot_wants_tagwrite_priority_o        (slot0_wants_tagwrite_priority),
    .slot_wants_write_addr_priority_o      (slot0_wants_write_addr_priority),
    .slot_wants_cleanunique_priority_o     (slot0_wants_cleanunique_priority),
    .slot_biu_write_req_active_o           (slot0_biu_write_req_active),
    .slot_block_ccb_o                      (slot0_block_ccb),
    .slot_block_loads_dc1_o                (slot0_block_loads_dc1),
    .slot_excl_fail_o                      (slot0_excl_fail),
    .slot_excl_done_o                      (slot0_excl_done),
    .slot_type_o                           (slot0_type[7:0]),
    .slot_might_req_o                      (slot0_might_req),
    .slot_force_non_mergeable_o            (slot0_force_non_mergeable)
  );  // u_slot0

  ca53stb_slot `CA53_STB_PARAM_INST u_slot1 (
    /*ARMAUTO*/
    //TEMPLATE s/slot_/slot1_/
    //TEMPLATE s/slota_/slot0_/
    //TEMPLATE s/slotb_/slot2_/
    //TEMPLATE s/slotc_/slot3_/
    //TEMPLATE s/slotd_/slot4_/
    .slot_load_sameline_dc3_i              (dcu_load_sameline_dc3_i[1]),
    .slot_store_merge_dc3_i                (dcu_store_merge_dc3_i[1]),
    .slot_biu_ev_hazard_i                  (biu_ev_hazard_i[1]),
    .slot_biu_lf_hazard_way_i              (biu_lf_hazard_way_slot1_i),
    // Inputs
    .clk                                   (clk),
    .slot_clk                              (slot1_clk),
    .reset_n                               (reset_n),
    .slota_valid_i                         (slot0_valid),
    .slota_emptying_i                      (slot0_emptying),
    .slota_state_biureq_i                  (slot0_state_biureq),
    .slota_state_biuack_i                  (slot0_state_biuack),
    .slota_state_biuresp_i                 (slot0_state_biuresp),
    .slota_state_biudata_i                 (slot0_state_biudata),
    .slota_state_lfreq_i                   (slot0_state_lfreq),
    .slota_state_lookupreq_i               (slot0_state_lookupreq),
    .slota_state_lookupm1_i                (slot0_state_lookupm1),
    .slota_state_lookupm2_i                (slot0_state_lookupm2),
    .slota_state_tagwrite_i                (slot0_state_tagwrite),
    .slota_state_cachemerge_i              (slot0_state_cachemerge),
    .slota_state_cachereadm0_i             (slot0_state_cachereadm0),
    .slota_state_cachereadm1_i             (slot0_state_cachereadm1),
    .slota_state_cachereadm2_i             (slot0_state_cachereadm2),
    .slota_state_cacheecc_i                (slot0_state_cacheecc),
    .slota_state_cachewritereq_i           (slot0_state_cachewritereq),
    .slota_state_cachewritem1_i            (slot0_state_cachewritem1),
    .slota_state_cp15resp_i                (slot0_state_cp15resp),
    .slota_state_cleanunique_req_i         (slot0_state_cleanunique_req),
    .slota_state_cleanunique_ack_i         (slot0_state_cleanunique_ack),
    .slota_state_cleanunique_resp_i        (slot0_state_cleanunique_resp),
    .slota_mergeable_i                     (slot0_mergeable),
    .slota_barriered_i                     (slot0_barriered),
    .slota_has_lookup_priority_i           (slot0_has_lookup_priority),
    .slota_has_tagwrite_priority_i         (slot0_has_tagwrite_priority),
    .slota_ar_resp_valid_i                 (slot0_ar_resp_valid),
    .slota_has_write_addr_priority_i       (slot0_has_write_addr_priority),
    .slota_has_cleanunique_priority_i      (slot0_has_cleanunique_priority),
    .slota_way_i                           (slot0_way[1:0]),
    .slota_migratory_i                     (slot0_migratory),
    .slota_ev_hazard_i                     (slot0_ev_hazard),
    .slota_ev_hz_seen_i                    (slot0_ev_hz_seen),
    .slota_lf_hz_seen_i                    (slot0_lf_hz_seen),
    .slota_lf_hz_capture_i                 (slot0_lf_hz_capture),
    .slota_coherent_i                      (slot0_coherent),
    .slota_biu_lf_hazard_i                 (slot0_biu_lf_hazard),
    .slota_l2dbid_i                        (slot0_l2dbid[3:0]),
    .slota_no_alloc_on_miss_i              (slot0_no_alloc_on_miss),
    .slota_sameline_beat_count_i           (slot0_sameline_beat_count[2:0]),
    .slota_wants_write_data_priority_i     (slot0_wants_write_data_priority),
    .slota_write_accept_i                  (slot0_write_accept),
    .slota_more_dev_expected_i             (slot0_more_dev_expected),
    .slota_lf_req_i                        (slot0_lf_req),
    .slota_has_cleanunique_duty_i          (slot0_has_cleanunique_duty),
    .slota_load_sameline_seen_i            (slot0_load_sameline_seen),
    .slota_load_sameline_i                 (slot0_load_sameline),
    .slotb_valid_i                         (slot2_valid),
    .slotb_emptying_i                      (slot2_emptying),
    .slotb_state_biureq_i                  (slot2_state_biureq),
    .slotb_state_biuack_i                  (slot2_state_biuack),
    .slotb_state_biuresp_i                 (slot2_state_biuresp),
    .slotb_state_biudata_i                 (slot2_state_biudata),
    .slotb_state_lfreq_i                   (slot2_state_lfreq),
    .slotb_state_lookupreq_i               (slot2_state_lookupreq),
    .slotb_state_lookupm1_i                (slot2_state_lookupm1),
    .slotb_state_lookupm2_i                (slot2_state_lookupm2),
    .slotb_state_tagwrite_i                (slot2_state_tagwrite),
    .slotb_state_cachemerge_i              (slot2_state_cachemerge),
    .slotb_state_cachereadm0_i             (slot2_state_cachereadm0),
    .slotb_state_cachereadm1_i             (slot2_state_cachereadm1),
    .slotb_state_cachereadm2_i             (slot2_state_cachereadm2),
    .slotb_state_cacheecc_i                (slot2_state_cacheecc),
    .slotb_state_cachewritereq_i           (slot2_state_cachewritereq),
    .slotb_state_cachewritem1_i            (slot2_state_cachewritem1),
    .slotb_state_cp15resp_i                (slot2_state_cp15resp),
    .slotb_state_cleanunique_req_i         (slot2_state_cleanunique_req),
    .slotb_state_cleanunique_ack_i         (slot2_state_cleanunique_ack),
    .slotb_state_cleanunique_resp_i        (slot2_state_cleanunique_resp),
    .slotb_mergeable_i                     (slot2_mergeable),
    .slotb_barriered_i                     (slot2_barriered),
    .slotb_has_lookup_priority_i           (slot2_has_lookup_priority),
    .slotb_has_tagwrite_priority_i         (slot2_has_tagwrite_priority),
    .slotb_ar_resp_valid_i                 (slot2_ar_resp_valid),
    .slotb_has_write_addr_priority_i       (slot2_has_write_addr_priority),
    .slotb_has_cleanunique_priority_i      (slot2_has_cleanunique_priority),
    .slotb_way_i                           (slot2_way[1:0]),
    .slotb_migratory_i                     (slot2_migratory),
    .slotb_ev_hazard_i                     (slot2_ev_hazard),
    .slotb_ev_hz_seen_i                    (slot2_ev_hz_seen),
    .slotb_lf_hz_seen_i                    (slot2_lf_hz_seen),
    .slotb_lf_hz_capture_i                 (slot2_lf_hz_capture),
    .slotb_coherent_i                      (slot2_coherent),
    .slotb_biu_lf_hazard_i                 (slot2_biu_lf_hazard),
    .slotb_l2dbid_i                        (slot2_l2dbid[3:0]),
    .slotb_no_alloc_on_miss_i              (slot2_no_alloc_on_miss),
    .slotb_sameline_beat_count_i           (slot2_sameline_beat_count[2:0]),
    .slotb_wants_write_data_priority_i     (slot2_wants_write_data_priority),
    .slotb_write_accept_i                  (slot2_write_accept),
    .slotb_more_dev_expected_i             (slot2_more_dev_expected),
    .slotb_lf_req_i                        (slot2_lf_req),
    .slotb_has_cleanunique_duty_i          (slot2_has_cleanunique_duty),
    .slotb_load_sameline_seen_i            (slot2_load_sameline_seen),
    .slotb_load_sameline_i                 (slot2_load_sameline),
    .slotc_valid_i                         (slot3_valid),
    .slotc_emptying_i                      (slot3_emptying),
    .slotc_state_biureq_i                  (slot3_state_biureq),
    .slotc_state_biuack_i                  (slot3_state_biuack),
    .slotc_state_biuresp_i                 (slot3_state_biuresp),
    .slotc_state_biudata_i                 (slot3_state_biudata),
    .slotc_state_lfreq_i                   (slot3_state_lfreq),
    .slotc_state_lookupreq_i               (slot3_state_lookupreq),
    .slotc_state_lookupm1_i                (slot3_state_lookupm1),
    .slotc_state_lookupm2_i                (slot3_state_lookupm2),
    .slotc_state_tagwrite_i                (slot3_state_tagwrite),
    .slotc_state_cachemerge_i              (slot3_state_cachemerge),
    .slotc_state_cachereadm0_i             (slot3_state_cachereadm0),
    .slotc_state_cachereadm1_i             (slot3_state_cachereadm1),
    .slotc_state_cachereadm2_i             (slot3_state_cachereadm2),
    .slotc_state_cacheecc_i                (slot3_state_cacheecc),
    .slotc_state_cachewritereq_i           (slot3_state_cachewritereq),
    .slotc_state_cachewritem1_i            (slot3_state_cachewritem1),
    .slotc_state_cp15resp_i                (slot3_state_cp15resp),
    .slotc_state_cleanunique_req_i         (slot3_state_cleanunique_req),
    .slotc_state_cleanunique_ack_i         (slot3_state_cleanunique_ack),
    .slotc_state_cleanunique_resp_i        (slot3_state_cleanunique_resp),
    .slotc_mergeable_i                     (slot3_mergeable),
    .slotc_barriered_i                     (slot3_barriered),
    .slotc_has_lookup_priority_i           (slot3_has_lookup_priority),
    .slotc_has_tagwrite_priority_i         (slot3_has_tagwrite_priority),
    .slotc_ar_resp_valid_i                 (slot3_ar_resp_valid),
    .slotc_has_write_addr_priority_i       (slot3_has_write_addr_priority),
    .slotc_has_cleanunique_priority_i      (slot3_has_cleanunique_priority),
    .slotc_way_i                           (slot3_way[1:0]),
    .slotc_migratory_i                     (slot3_migratory),
    .slotc_ev_hazard_i                     (slot3_ev_hazard),
    .slotc_ev_hz_seen_i                    (slot3_ev_hz_seen),
    .slotc_lf_hz_seen_i                    (slot3_lf_hz_seen),
    .slotc_lf_hz_capture_i                 (slot3_lf_hz_capture),
    .slotc_coherent_i                      (slot3_coherent),
    .slotc_biu_lf_hazard_i                 (slot3_biu_lf_hazard),
    .slotc_l2dbid_i                        (slot3_l2dbid[3:0]),
    .slotc_no_alloc_on_miss_i              (slot3_no_alloc_on_miss),
    .slotc_sameline_beat_count_i           (slot3_sameline_beat_count[2:0]),
    .slotc_wants_write_data_priority_i     (slot3_wants_write_data_priority),
    .slotc_write_accept_i                  (slot3_write_accept),
    .slotc_more_dev_expected_i             (slot3_more_dev_expected),
    .slotc_lf_req_i                        (slot3_lf_req),
    .slotc_has_cleanunique_duty_i          (slot3_has_cleanunique_duty),
    .slotc_load_sameline_seen_i            (slot3_load_sameline_seen),
    .slotc_load_sameline_i                 (slot3_load_sameline),
    .slotd_valid_i                         (slot4_valid),
    .slotd_emptying_i                      (slot4_emptying),
    .slotd_state_biureq_i                  (slot4_state_biureq),
    .slotd_state_biuack_i                  (slot4_state_biuack),
    .slotd_state_biuresp_i                 (slot4_state_biuresp),
    .slotd_state_biudata_i                 (slot4_state_biudata),
    .slotd_state_lfreq_i                   (slot4_state_lfreq),
    .slotd_state_lookupreq_i               (slot4_state_lookupreq),
    .slotd_state_lookupm1_i                (slot4_state_lookupm1),
    .slotd_state_lookupm2_i                (slot4_state_lookupm2),
    .slotd_state_tagwrite_i                (slot4_state_tagwrite),
    .slotd_state_cachemerge_i              (slot4_state_cachemerge),
    .slotd_state_cachereadm0_i             (slot4_state_cachereadm0),
    .slotd_state_cachereadm1_i             (slot4_state_cachereadm1),
    .slotd_state_cachereadm2_i             (slot4_state_cachereadm2),
    .slotd_state_cacheecc_i                (slot4_state_cacheecc),
    .slotd_state_cachewritereq_i           (slot4_state_cachewritereq),
    .slotd_state_cachewritem1_i            (slot4_state_cachewritem1),
    .slotd_state_cp15resp_i                (slot4_state_cp15resp),
    .slotd_state_cleanunique_req_i         (slot4_state_cleanunique_req),
    .slotd_state_cleanunique_ack_i         (slot4_state_cleanunique_ack),
    .slotd_state_cleanunique_resp_i        (slot4_state_cleanunique_resp),
    .slotd_mergeable_i                     (slot4_mergeable),
    .slotd_barriered_i                     (slot4_barriered),
    .slotd_has_lookup_priority_i           (slot4_has_lookup_priority),
    .slotd_has_tagwrite_priority_i         (slot4_has_tagwrite_priority),
    .slotd_ar_resp_valid_i                 (slot4_ar_resp_valid),
    .slotd_has_write_addr_priority_i       (slot4_has_write_addr_priority),
    .slotd_has_cleanunique_priority_i      (slot4_has_cleanunique_priority),
    .slotd_way_i                           (slot4_way[1:0]),
    .slotd_migratory_i                     (slot4_migratory),
    .slotd_ev_hazard_i                     (slot4_ev_hazard),
    .slotd_ev_hz_seen_i                    (slot4_ev_hz_seen),
    .slotd_lf_hz_seen_i                    (slot4_lf_hz_seen),
    .slotd_lf_hz_capture_i                 (slot4_lf_hz_capture),
    .slotd_coherent_i                      (slot4_coherent),
    .slotd_biu_lf_hazard_i                 (slot4_biu_lf_hazard),
    .slotd_l2dbid_i                        (slot4_l2dbid[3:0]),
    .slotd_no_alloc_on_miss_i              (slot4_no_alloc_on_miss),
    .slotd_sameline_beat_count_i           (slot4_sameline_beat_count[2:0]),
    .slotd_wants_write_data_priority_i     (slot4_wants_write_data_priority),
    .slotd_write_accept_i                  (slot4_write_accept),
    .slotd_more_dev_expected_i             (slot4_more_dev_expected),
    .slotd_lf_req_i                        (slot4_lf_req),
    .slotd_has_cleanunique_duty_i          (slot4_has_cleanunique_duty),
    .slotd_load_sameline_seen_i            (slot4_load_sameline_seen),
    .slotd_load_sameline_i                 (slot4_load_sameline),
    .dcu_pa_dc2_i                          (dcu_pa_dc2_i[39:3]),
    .dcu_ns_dsc_dc2_i                      (dcu_ns_dsc_dc2_i),
    .dcu_attrs_dc2_i                       (dcu_attrs_dc2_i[7:0]),
    .slot_new_req_dc3_i                    (slot1_new_req_dc3),
    .dcu_pa_dc3_i                          (dcu_pa_dc3_i[39:0]),
    .dcu_ns_dsc_dc3_i                      (dcu_ns_dsc_dc3_i),
    .dcu_priv_dc3_i                        (dcu_priv_dc3_i),
    .dcu_stb_exclusive_dc3_i               (dcu_stb_exclusive_dc3_i),
    .dcu_stb_mergeable_dc3_i               (dcu_stb_mergeable_dc3),
    .dcu_store_cp15_dc3_i                  (dcu_store_cp15_dc3_i),
    .dcu_stlr_dc3_i                        (dcu_stlr_dc3_i),
    .dcu_stb_attrs_dc3_i                   (dcu_stb_attrs_dc3_i[7:0]),
    .dpu_st_data_wr_i                      (dpu_st_data_wr_i[127:0]),
    .dcu_store_bls_dc3_i                   (dcu_store_bls_dc3_i[15:0]),
    .dcu_store_last_dc3_i                  (dcu_store_last_dc3_i),
    .dcu_store_dsb_dc3_i                   (dcu_store_dsb_dc3_i),
    .dcu_store_dmb_dc3_i                   (dcu_store_dmb_dc3_i),
    .dcu_force_non_mergeable_dc3_i         (dcu_force_non_mergeable_dc3_i),
    .slota_new_req_dc3_i                   (slot0_new_req_dc3),
    .slotb_new_req_dc3_i                   (slot2_new_req_dc3),
    .slotc_new_req_dc3_i                   (slot3_new_req_dc3),
    .slotd_new_req_dc3_i                   (slot4_new_req_dc3),
    .slot_dcu_store_sameline_dc3_i         (slot1_dcu_store_sameline_dc3),
    .slota_dcu_store_sameline_dc3_i        (slot0_dcu_store_sameline_dc3),
    .slotb_dcu_store_sameline_dc3_i        (slot2_dcu_store_sameline_dc3),
    .slotc_dcu_store_sameline_dc3_i        (slot3_dcu_store_sameline_dc3),
    .slotd_dcu_store_sameline_dc3_i        (slot4_dcu_store_sameline_dc3),
    .dcu_stb_tag_has_priority_m0_i         (dcu_stb_tag_has_priority_m0_i),
    .dcu_stb_data_has_priority_m0_i        (dcu_stb_data_has_priority_m0_i),
    .dcu_stb_tag_ack_m1_i                  (dcu_stb_tag_ack_m1_i),
    .dcu_stb_data_ack_m1_i                 (dcu_stb_data_ack_m1_i),
    .dcu_stb_tag_hit_m2_i                  (dcu_stb_tag_hit_m2_i[3:0]),
    .dcu_stb_tag_shared_m2_i               (dcu_stb_tag_shared_m2_i),
    .dcu_stb_tag_migratory_m2_i            (dcu_stb_tag_migratory_m2_i),
    .dcu_stb_victim_way_m2_i               (dcu_stb_victim_way_m2_i[3:0]),
    .dcu_stb_read_data_m2_i                (dcu_stb_read_data_m2_i[127:0]),
    .dcu_stb_read_wls_m2_i                 (dcu_stb_read_wls_m2[3:0]),
    .dcu_ecc_data_err_m3_i                 (dcu_ecc_data_err_m3_i),
    .dcu_ecc_in_progress_i                 (dcu_ecc_in_progress_i),
    .tag_hit_shared_m3_i                   (tag_hit_shared_m3[1:0]),
    .tag_ecc_err_m3_i                      (tag_ecc_err_m3),
    .biu_stb_write_accept_i                (biu_stb_write_accept_i),
    .slot_biu_lf_hazard_i                  (slot1_biu_lf_hazard),
    .slot_biu_lf_real_hazard_i             (slot1_biu_lf_real_hazard),
    .slot_biu_lf_hazard_migratory_i        (slot1_biu_lf_hazard_migratory),
    .slot_biu_lf_serialized_i              (slot1_biu_lf_serialized),
    .slot_biu_lf_can_merge_i               (slot1_biu_lf_can_merge),
    .biu_dirty_lf_in_progress_i            (biu_dirty_lf_in_progress_i),
    .biu_excl_lf_in_progress_i             (biu_excl_lf_in_progress_i),
    .biu_stb_ar_ack_i                      (biu_stb_ar_ack_i),
    .biu_stb_ar_resp_i                     (biu_stb_ar_resp_i[1:0]),
    .slot_has_ar_priority_i                (slot1_has_ar_priority),
    .dc_size_i                             (dc_size_i[2:0]),
    .slot_force_drain_i                    (slot1_force_drain),
    .slot_force_drain_biudata_i            (slot1_force_drain_biudata),
    .stb_cycle_count_127_i                 (stb_cycle_count_127),
    .stb_cycle_count_1023_i                (stb_cycle_count_1023),
    .biu_read_alloc_mode_i                 (biu_read_alloc_mode_i),
    .next_dev_bursting_i                   (next_dev_bursting),
    .dev_delay_ar_req_i                    (dev_delay_ar_req),
    .dcu_leaving_dc2_i                     (dcu_leaving_dc2_i),
    .dcu_store_dc2_i                       (dcu_store_dc2_i),
    .dpu_kill_wr_i                         (dpu_kill_wr_i),
    .slot_has_lookup_priority_i            (slot1_has_lookup_priority),
    .slot_has_cache_data_priority_i        (slot1_has_cache_data_priority),
    .slot_has_tagwrite_priority_i          (slot1_has_tagwrite_priority),
    .slot_has_write_addr_priority_i        (slot1_has_write_addr_priority),
    .slot_has_cleanunique_priority_i       (slot1_has_cleanunique_priority),
    .slot_ar_resp_valid_i                  (slot1_ar_resp_valid),
    .biu_stb_ar_resp_l2dbid_i              (biu_stb_ar_resp_l2dbid_i[3:0]),
    .dcu_ccb_index_i                       (dcu_ccb_index_i[13:6]),
    .dcu_ccb_ways_i                        (dcu_ccb_ways_i[3:0]),
    .dcu_ccb_req_valid_i                   (dcu_ccb_req_valid_i),
    .dcu_exclusive_monitor_i               (dcu_exclusive_monitor_i),
    .dvm_sync_needed_i                     (dvm_sync_needed),
    .propagate_barrier_i                   (propagate_barrier),
    .dpu_disable_dmb_i                     (dpu_disable_dmb_i),
    .dvm_complete_i                        (dvm_complete),
    .stb_force_non_mergeable_i             (stb_force_non_mergeable),
    // Outputs
    .slot_valid_o                          (slot1_valid),
    .slot_emptying_o                       (slot1_emptying),
    .slot_state_biureq_o                   (slot1_state_biureq),
    .slot_state_biumerge_o                 (slot1_state_biumerge),
    .slot_state_biuack_o                   (slot1_state_biuack),
    .slot_state_biuresp_o                  (slot1_state_biuresp),
    .slot_state_biudata_o                  (slot1_state_biudata),
    .slot_state_lfreq_o                    (slot1_state_lfreq),
    .slot_state_lookupreq_o                (slot1_state_lookupreq),
    .slot_state_lookupm1_o                 (slot1_state_lookupm1),
    .slot_state_lookupm2_o                 (slot1_state_lookupm2),
    .slot_state_special_o                  (slot1_state_special),
    .slot_state_tagwrite_o                 (slot1_state_tagwrite),
    .slot_state_cachemerge_o               (slot1_state_cachemerge),
    .slot_state_cachewritereq_o            (slot1_state_cachewritereq),
    .slot_state_cachereadm0_o              (slot1_state_cachereadm0),
    .slot_state_cachereadm1_o              (slot1_state_cachereadm1),
    .slot_state_cachereadm2_o              (slot1_state_cachereadm2),
    .slot_state_cacheecc_o                 (slot1_state_cacheecc),
    .slot_state_cachewritem1_o             (slot1_state_cachewritem1),
    .slot_state_cp15resp_o                 (slot1_state_cp15resp),
    .slot_state_cleanunique_req_o          (slot1_state_cleanunique_req),
    .slot_state_cleanunique_ack_o          (slot1_state_cleanunique_ack),
    .slot_state_cleanunique_resp_o         (slot1_state_cleanunique_resp),
    .slot_state_barrier_ack_o              (slot1_state_barrier_ack),
    .slot_write_sync_cmo_ack_o             (slot1_write_sync_cmo_ack),
    .slot_attrs_o                          (slot1_attrs[7:0]),
    .slot_addr_o                           (slot1_addr[39:0]),
    .slot_ns_o                             (slot1_ns),
    .slot_data_o                           (slot1_data[127:0]),
    .slot_cache_bls_o                      (slot1_cache_bls[15:0]),
    .slot_write_data_o                     (slot1_write_data[127:0]),
    .slot_write_bls_o                      (slot1_write_bls[15:0]),
    .slot_write_chunk_o                    (slot1_write_chunk[1:0]),
    .slot_write_last_o                     (slot1_write_last),
    .slot_mergeable_o                      (slot1_mergeable),
    .slot_barriered_o                      (slot1_barriered),
    .slot_earlier_o                        (slot1_earlier[3:0]),
    .slot_earlier_lf_o                     (slot1_earlier_lf[3:0]),
    .slot_cp15_o                           (slot1_cp15),
    .slot_dsb_o                            (slot1_dsb),
    .slot_way_onehot_o                     (slot1_way_onehot[3:0]),
    .slot_way_o                            (slot1_way[1:0]),
    .slot_migratory_o                      (slot1_migratory),
    .slot_ar_way_o                         (slot1_ar_way[1:0]),
    .slot_lf_hz_seen_o                     (slot1_lf_hz_seen),
    .slot_lf_hz_capture_o                  (slot1_lf_hz_capture),
    .slot_coherent_o                       (slot1_coherent),
    .slot_l2dbid_o                         (slot1_l2dbid[3:0]),
    .slot_no_alloc_on_miss_o               (slot1_no_alloc_on_miss),
    .slot_more_dev_expected_o              (slot1_more_dev_expected),
    .slot_sameline_beat_count_o            (slot1_sameline_beat_count[2:0]),
    .slot_has_cleanunique_duty_o           (slot1_has_cleanunique_duty),
    .slot_load_sameline_seen_o             (slot1_load_sameline_seen),
    .slot_load_sameline_o                  (slot1_load_sameline),
    .slot_can_merge_dc2_o                  (slot1_can_merge_dc2),
    .slot_sameline_dc2_o                   (slot1_sameline_dc2),
    .slot_load_sameline_dc2_o              (slot1_load_sameline_dc2),
    .slot_attr_mismatch_dc2_o              (slot1_attr_mismatch_dc2),
    .slot_hit_dc2_o                        (slot1_hit_dc2[15:0]),
    .slot_wants_write_data_priority_o      (slot1_wants_write_data_priority),
    .slot_has_write_data_priority_o        (slot1_has_write_data_priority),
    .slot_write_data_suppress_o            (slot1_write_data_suppress),
    .slot_write_accept_o                   (slot1_write_accept),
    .slot_lf_active_o                      (slot1_lf_active),
    .slot_lf_req_o                         (slot1_lf_req),
    .slot_lf_merge_o                       (slot1_lf_merge),
    .slot_ev_hazard_o                      (slot1_ev_hazard),
    .slot_ev_hz_seen_o                     (slot1_ev_hz_seen),
    .slot_wants_ar_priority_o              (slot1_wants_ar_priority),
    .slot_might_want_ar_priority_o         (slot1_might_want_ar_priority),
    .slot_already_has_ar_priority_o        (slot1_already_has_ar_priority),
    .slot_ar_suppress_o                    (slot1_ar_suppress),
    .slot_ar_addr_o                        (slot1_ar_addr[39:0]),
    .slot_ar_ns_o                          (slot1_ar_ns),
    .slot_ar_priv_o                        (slot1_ar_priv),
    .slot_ar_excl_o                        (slot1_ar_excl),
    .slot_cp15_asid_o                      (slot1_cp15_asid[15:0]),
    .slot_cp15_vmid_o                      (slot1_cp15_vmid[7:0]),
    .slot_cp15_va_o                        (slot1_cp15_va[24:0]),
    .slot_wants_lookup_priority_o          (slot1_wants_lookup_priority),
    .slot_might_want_cache_data_priority_o (slot1_might_want_cache_data_priority),
    .slot_wants_cache_data_priority_o      (slot1_wants_cache_data_priority),
    .slot_wants_tagwrite_priority_o        (slot1_wants_tagwrite_priority),
    .slot_wants_write_addr_priority_o      (slot1_wants_write_addr_priority),
    .slot_wants_cleanunique_priority_o     (slot1_wants_cleanunique_priority),
    .slot_biu_write_req_active_o           (slot1_biu_write_req_active),
    .slot_block_ccb_o                      (slot1_block_ccb),
    .slot_block_loads_dc1_o                (slot1_block_loads_dc1),
    .slot_excl_fail_o                      (slot1_excl_fail),
    .slot_excl_done_o                      (slot1_excl_done),
    .slot_type_o                           (slot1_type[7:0]),
    .slot_might_req_o                      (slot1_might_req),
    .slot_force_non_mergeable_o            (slot1_force_non_mergeable)
  );  // u_slot1

  ca53stb_slot `CA53_STB_PARAM_INST u_slot2 (
    /*ARMAUTO*/
    //TEMPLATE s/slot_/slot2_/
    //TEMPLATE s/slota_/slot0_/
    //TEMPLATE s/slotb_/slot1_/
    //TEMPLATE s/slotc_/slot3_/
    //TEMPLATE s/slotd_/slot4_/
    .slot_load_sameline_dc3_i              (dcu_load_sameline_dc3_i[2]),
    .slot_store_merge_dc3_i                (dcu_store_merge_dc3_i[2]),
    .slot_biu_ev_hazard_i                  (biu_ev_hazard_i[2]),
    .slot_biu_lf_hazard_way_i              (biu_lf_hazard_way_slot2_i),
    // Inputs
    .clk                                   (clk),
    .slot_clk                              (slot2_clk),
    .reset_n                               (reset_n),
    .slota_valid_i                         (slot0_valid),
    .slota_emptying_i                      (slot0_emptying),
    .slota_state_biureq_i                  (slot0_state_biureq),
    .slota_state_biuack_i                  (slot0_state_biuack),
    .slota_state_biuresp_i                 (slot0_state_biuresp),
    .slota_state_biudata_i                 (slot0_state_biudata),
    .slota_state_lfreq_i                   (slot0_state_lfreq),
    .slota_state_lookupreq_i               (slot0_state_lookupreq),
    .slota_state_lookupm1_i                (slot0_state_lookupm1),
    .slota_state_lookupm2_i                (slot0_state_lookupm2),
    .slota_state_tagwrite_i                (slot0_state_tagwrite),
    .slota_state_cachemerge_i              (slot0_state_cachemerge),
    .slota_state_cachereadm0_i             (slot0_state_cachereadm0),
    .slota_state_cachereadm1_i             (slot0_state_cachereadm1),
    .slota_state_cachereadm2_i             (slot0_state_cachereadm2),
    .slota_state_cacheecc_i                (slot0_state_cacheecc),
    .slota_state_cachewritereq_i           (slot0_state_cachewritereq),
    .slota_state_cachewritem1_i            (slot0_state_cachewritem1),
    .slota_state_cp15resp_i                (slot0_state_cp15resp),
    .slota_state_cleanunique_req_i         (slot0_state_cleanunique_req),
    .slota_state_cleanunique_ack_i         (slot0_state_cleanunique_ack),
    .slota_state_cleanunique_resp_i        (slot0_state_cleanunique_resp),
    .slota_mergeable_i                     (slot0_mergeable),
    .slota_barriered_i                     (slot0_barriered),
    .slota_has_lookup_priority_i           (slot0_has_lookup_priority),
    .slota_has_tagwrite_priority_i         (slot0_has_tagwrite_priority),
    .slota_ar_resp_valid_i                 (slot0_ar_resp_valid),
    .slota_has_write_addr_priority_i       (slot0_has_write_addr_priority),
    .slota_has_cleanunique_priority_i      (slot0_has_cleanunique_priority),
    .slota_way_i                           (slot0_way[1:0]),
    .slota_migratory_i                     (slot0_migratory),
    .slota_ev_hazard_i                     (slot0_ev_hazard),
    .slota_ev_hz_seen_i                    (slot0_ev_hz_seen),
    .slota_lf_hz_seen_i                    (slot0_lf_hz_seen),
    .slota_lf_hz_capture_i                 (slot0_lf_hz_capture),
    .slota_coherent_i                      (slot0_coherent),
    .slota_biu_lf_hazard_i                 (slot0_biu_lf_hazard),
    .slota_l2dbid_i                        (slot0_l2dbid[3:0]),
    .slota_no_alloc_on_miss_i              (slot0_no_alloc_on_miss),
    .slota_sameline_beat_count_i           (slot0_sameline_beat_count[2:0]),
    .slota_wants_write_data_priority_i     (slot0_wants_write_data_priority),
    .slota_write_accept_i                  (slot0_write_accept),
    .slota_more_dev_expected_i             (slot0_more_dev_expected),
    .slota_lf_req_i                        (slot0_lf_req),
    .slota_has_cleanunique_duty_i          (slot0_has_cleanunique_duty),
    .slota_load_sameline_seen_i            (slot0_load_sameline_seen),
    .slota_load_sameline_i                 (slot0_load_sameline),
    .slotb_valid_i                         (slot1_valid),
    .slotb_emptying_i                      (slot1_emptying),
    .slotb_state_biureq_i                  (slot1_state_biureq),
    .slotb_state_biuack_i                  (slot1_state_biuack),
    .slotb_state_biuresp_i                 (slot1_state_biuresp),
    .slotb_state_biudata_i                 (slot1_state_biudata),
    .slotb_state_lfreq_i                   (slot1_state_lfreq),
    .slotb_state_lookupreq_i               (slot1_state_lookupreq),
    .slotb_state_lookupm1_i                (slot1_state_lookupm1),
    .slotb_state_lookupm2_i                (slot1_state_lookupm2),
    .slotb_state_tagwrite_i                (slot1_state_tagwrite),
    .slotb_state_cachemerge_i              (slot1_state_cachemerge),
    .slotb_state_cachereadm0_i             (slot1_state_cachereadm0),
    .slotb_state_cachereadm1_i             (slot1_state_cachereadm1),
    .slotb_state_cachereadm2_i             (slot1_state_cachereadm2),
    .slotb_state_cacheecc_i                (slot1_state_cacheecc),
    .slotb_state_cachewritereq_i           (slot1_state_cachewritereq),
    .slotb_state_cachewritem1_i            (slot1_state_cachewritem1),
    .slotb_state_cp15resp_i                (slot1_state_cp15resp),
    .slotb_state_cleanunique_req_i         (slot1_state_cleanunique_req),
    .slotb_state_cleanunique_ack_i         (slot1_state_cleanunique_ack),
    .slotb_state_cleanunique_resp_i        (slot1_state_cleanunique_resp),
    .slotb_mergeable_i                     (slot1_mergeable),
    .slotb_barriered_i                     (slot1_barriered),
    .slotb_has_lookup_priority_i           (slot1_has_lookup_priority),
    .slotb_has_tagwrite_priority_i         (slot1_has_tagwrite_priority),
    .slotb_ar_resp_valid_i                 (slot1_ar_resp_valid),
    .slotb_has_write_addr_priority_i       (slot1_has_write_addr_priority),
    .slotb_has_cleanunique_priority_i      (slot1_has_cleanunique_priority),
    .slotb_way_i                           (slot1_way[1:0]),
    .slotb_migratory_i                     (slot1_migratory),
    .slotb_ev_hazard_i                     (slot1_ev_hazard),
    .slotb_ev_hz_seen_i                    (slot1_ev_hz_seen),
    .slotb_lf_hz_seen_i                    (slot1_lf_hz_seen),
    .slotb_lf_hz_capture_i                 (slot1_lf_hz_capture),
    .slotb_coherent_i                      (slot1_coherent),
    .slotb_biu_lf_hazard_i                 (slot1_biu_lf_hazard),
    .slotb_l2dbid_i                        (slot1_l2dbid[3:0]),
    .slotb_no_alloc_on_miss_i              (slot1_no_alloc_on_miss),
    .slotb_sameline_beat_count_i           (slot1_sameline_beat_count[2:0]),
    .slotb_wants_write_data_priority_i     (slot1_wants_write_data_priority),
    .slotb_write_accept_i                  (slot1_write_accept),
    .slotb_more_dev_expected_i             (slot1_more_dev_expected),
    .slotb_lf_req_i                        (slot1_lf_req),
    .slotb_has_cleanunique_duty_i          (slot1_has_cleanunique_duty),
    .slotb_load_sameline_seen_i            (slot1_load_sameline_seen),
    .slotb_load_sameline_i                 (slot1_load_sameline),
    .slotc_valid_i                         (slot3_valid),
    .slotc_emptying_i                      (slot3_emptying),
    .slotc_state_biureq_i                  (slot3_state_biureq),
    .slotc_state_biuack_i                  (slot3_state_biuack),
    .slotc_state_biuresp_i                 (slot3_state_biuresp),
    .slotc_state_biudata_i                 (slot3_state_biudata),
    .slotc_state_lfreq_i                   (slot3_state_lfreq),
    .slotc_state_lookupreq_i               (slot3_state_lookupreq),
    .slotc_state_lookupm1_i                (slot3_state_lookupm1),
    .slotc_state_lookupm2_i                (slot3_state_lookupm2),
    .slotc_state_tagwrite_i                (slot3_state_tagwrite),
    .slotc_state_cachemerge_i              (slot3_state_cachemerge),
    .slotc_state_cachereadm0_i             (slot3_state_cachereadm0),
    .slotc_state_cachereadm1_i             (slot3_state_cachereadm1),
    .slotc_state_cachereadm2_i             (slot3_state_cachereadm2),
    .slotc_state_cacheecc_i                (slot3_state_cacheecc),
    .slotc_state_cachewritereq_i           (slot3_state_cachewritereq),
    .slotc_state_cachewritem1_i            (slot3_state_cachewritem1),
    .slotc_state_cp15resp_i                (slot3_state_cp15resp),
    .slotc_state_cleanunique_req_i         (slot3_state_cleanunique_req),
    .slotc_state_cleanunique_ack_i         (slot3_state_cleanunique_ack),
    .slotc_state_cleanunique_resp_i        (slot3_state_cleanunique_resp),
    .slotc_mergeable_i                     (slot3_mergeable),
    .slotc_barriered_i                     (slot3_barriered),
    .slotc_has_lookup_priority_i           (slot3_has_lookup_priority),
    .slotc_has_tagwrite_priority_i         (slot3_has_tagwrite_priority),
    .slotc_ar_resp_valid_i                 (slot3_ar_resp_valid),
    .slotc_has_write_addr_priority_i       (slot3_has_write_addr_priority),
    .slotc_has_cleanunique_priority_i      (slot3_has_cleanunique_priority),
    .slotc_way_i                           (slot3_way[1:0]),
    .slotc_migratory_i                     (slot3_migratory),
    .slotc_ev_hazard_i                     (slot3_ev_hazard),
    .slotc_ev_hz_seen_i                    (slot3_ev_hz_seen),
    .slotc_lf_hz_seen_i                    (slot3_lf_hz_seen),
    .slotc_lf_hz_capture_i                 (slot3_lf_hz_capture),
    .slotc_coherent_i                      (slot3_coherent),
    .slotc_biu_lf_hazard_i                 (slot3_biu_lf_hazard),
    .slotc_l2dbid_i                        (slot3_l2dbid[3:0]),
    .slotc_no_alloc_on_miss_i              (slot3_no_alloc_on_miss),
    .slotc_sameline_beat_count_i           (slot3_sameline_beat_count[2:0]),
    .slotc_wants_write_data_priority_i     (slot3_wants_write_data_priority),
    .slotc_write_accept_i                  (slot3_write_accept),
    .slotc_more_dev_expected_i             (slot3_more_dev_expected),
    .slotc_lf_req_i                        (slot3_lf_req),
    .slotc_has_cleanunique_duty_i          (slot3_has_cleanunique_duty),
    .slotc_load_sameline_seen_i            (slot3_load_sameline_seen),
    .slotc_load_sameline_i                 (slot3_load_sameline),
    .slotd_valid_i                         (slot4_valid),
    .slotd_emptying_i                      (slot4_emptying),
    .slotd_state_biureq_i                  (slot4_state_biureq),
    .slotd_state_biuack_i                  (slot4_state_biuack),
    .slotd_state_biuresp_i                 (slot4_state_biuresp),
    .slotd_state_biudata_i                 (slot4_state_biudata),
    .slotd_state_lfreq_i                   (slot4_state_lfreq),
    .slotd_state_lookupreq_i               (slot4_state_lookupreq),
    .slotd_state_lookupm1_i                (slot4_state_lookupm1),
    .slotd_state_lookupm2_i                (slot4_state_lookupm2),
    .slotd_state_tagwrite_i                (slot4_state_tagwrite),
    .slotd_state_cachemerge_i              (slot4_state_cachemerge),
    .slotd_state_cachereadm0_i             (slot4_state_cachereadm0),
    .slotd_state_cachereadm1_i             (slot4_state_cachereadm1),
    .slotd_state_cachereadm2_i             (slot4_state_cachereadm2),
    .slotd_state_cacheecc_i                (slot4_state_cacheecc),
    .slotd_state_cachewritereq_i           (slot4_state_cachewritereq),
    .slotd_state_cachewritem1_i            (slot4_state_cachewritem1),
    .slotd_state_cp15resp_i                (slot4_state_cp15resp),
    .slotd_state_cleanunique_req_i         (slot4_state_cleanunique_req),
    .slotd_state_cleanunique_ack_i         (slot4_state_cleanunique_ack),
    .slotd_state_cleanunique_resp_i        (slot4_state_cleanunique_resp),
    .slotd_mergeable_i                     (slot4_mergeable),
    .slotd_barriered_i                     (slot4_barriered),
    .slotd_has_lookup_priority_i           (slot4_has_lookup_priority),
    .slotd_has_tagwrite_priority_i         (slot4_has_tagwrite_priority),
    .slotd_ar_resp_valid_i                 (slot4_ar_resp_valid),
    .slotd_has_write_addr_priority_i       (slot4_has_write_addr_priority),
    .slotd_has_cleanunique_priority_i      (slot4_has_cleanunique_priority),
    .slotd_way_i                           (slot4_way[1:0]),
    .slotd_migratory_i                     (slot4_migratory),
    .slotd_ev_hazard_i                     (slot4_ev_hazard),
    .slotd_ev_hz_seen_i                    (slot4_ev_hz_seen),
    .slotd_lf_hz_seen_i                    (slot4_lf_hz_seen),
    .slotd_lf_hz_capture_i                 (slot4_lf_hz_capture),
    .slotd_coherent_i                      (slot4_coherent),
    .slotd_biu_lf_hazard_i                 (slot4_biu_lf_hazard),
    .slotd_l2dbid_i                        (slot4_l2dbid[3:0]),
    .slotd_no_alloc_on_miss_i              (slot4_no_alloc_on_miss),
    .slotd_sameline_beat_count_i           (slot4_sameline_beat_count[2:0]),
    .slotd_wants_write_data_priority_i     (slot4_wants_write_data_priority),
    .slotd_write_accept_i                  (slot4_write_accept),
    .slotd_more_dev_expected_i             (slot4_more_dev_expected),
    .slotd_lf_req_i                        (slot4_lf_req),
    .slotd_has_cleanunique_duty_i          (slot4_has_cleanunique_duty),
    .slotd_load_sameline_seen_i            (slot4_load_sameline_seen),
    .slotd_load_sameline_i                 (slot4_load_sameline),
    .dcu_pa_dc2_i                          (dcu_pa_dc2_i[39:3]),
    .dcu_ns_dsc_dc2_i                      (dcu_ns_dsc_dc2_i),
    .dcu_attrs_dc2_i                       (dcu_attrs_dc2_i[7:0]),
    .slot_new_req_dc3_i                    (slot2_new_req_dc3),
    .dcu_pa_dc3_i                          (dcu_pa_dc3_i[39:0]),
    .dcu_ns_dsc_dc3_i                      (dcu_ns_dsc_dc3_i),
    .dcu_priv_dc3_i                        (dcu_priv_dc3_i),
    .dcu_stb_exclusive_dc3_i               (dcu_stb_exclusive_dc3_i),
    .dcu_stb_mergeable_dc3_i               (dcu_stb_mergeable_dc3),
    .dcu_store_cp15_dc3_i                  (dcu_store_cp15_dc3_i),
    .dcu_stlr_dc3_i                        (dcu_stlr_dc3_i),
    .dcu_stb_attrs_dc3_i                   (dcu_stb_attrs_dc3_i[7:0]),
    .dpu_st_data_wr_i                      (dpu_st_data_wr_i[127:0]),
    .dcu_store_bls_dc3_i                   (dcu_store_bls_dc3_i[15:0]),
    .dcu_store_last_dc3_i                  (dcu_store_last_dc3_i),
    .dcu_store_dsb_dc3_i                   (dcu_store_dsb_dc3_i),
    .dcu_store_dmb_dc3_i                   (dcu_store_dmb_dc3_i),
    .dcu_force_non_mergeable_dc3_i         (dcu_force_non_mergeable_dc3_i),
    .slota_new_req_dc3_i                   (slot0_new_req_dc3),
    .slotb_new_req_dc3_i                   (slot1_new_req_dc3),
    .slotc_new_req_dc3_i                   (slot3_new_req_dc3),
    .slotd_new_req_dc3_i                   (slot4_new_req_dc3),
    .slot_dcu_store_sameline_dc3_i         (slot2_dcu_store_sameline_dc3),
    .slota_dcu_store_sameline_dc3_i        (slot0_dcu_store_sameline_dc3),
    .slotb_dcu_store_sameline_dc3_i        (slot1_dcu_store_sameline_dc3),
    .slotc_dcu_store_sameline_dc3_i        (slot3_dcu_store_sameline_dc3),
    .slotd_dcu_store_sameline_dc3_i        (slot4_dcu_store_sameline_dc3),
    .dcu_stb_tag_has_priority_m0_i         (dcu_stb_tag_has_priority_m0_i),
    .dcu_stb_data_has_priority_m0_i        (dcu_stb_data_has_priority_m0_i),
    .dcu_stb_tag_ack_m1_i                  (dcu_stb_tag_ack_m1_i),
    .dcu_stb_data_ack_m1_i                 (dcu_stb_data_ack_m1_i),
    .dcu_stb_tag_hit_m2_i                  (dcu_stb_tag_hit_m2_i[3:0]),
    .dcu_stb_tag_shared_m2_i               (dcu_stb_tag_shared_m2_i),
    .dcu_stb_tag_migratory_m2_i            (dcu_stb_tag_migratory_m2_i),
    .dcu_stb_victim_way_m2_i               (dcu_stb_victim_way_m2_i[3:0]),
    .dcu_stb_read_data_m2_i                (dcu_stb_read_data_m2_i[127:0]),
    .dcu_stb_read_wls_m2_i                 (dcu_stb_read_wls_m2[3:0]),
    .dcu_ecc_data_err_m3_i                 (dcu_ecc_data_err_m3_i),
    .dcu_ecc_in_progress_i                 (dcu_ecc_in_progress_i),
    .tag_hit_shared_m3_i                   (tag_hit_shared_m3[1:0]),
    .tag_ecc_err_m3_i                      (tag_ecc_err_m3),
    .biu_stb_write_accept_i                (biu_stb_write_accept_i),
    .slot_biu_lf_hazard_i                  (slot2_biu_lf_hazard),
    .slot_biu_lf_real_hazard_i             (slot2_biu_lf_real_hazard),
    .slot_biu_lf_hazard_migratory_i        (slot2_biu_lf_hazard_migratory),
    .slot_biu_lf_serialized_i              (slot2_biu_lf_serialized),
    .slot_biu_lf_can_merge_i               (slot2_biu_lf_can_merge),
    .biu_dirty_lf_in_progress_i            (biu_dirty_lf_in_progress_i),
    .biu_excl_lf_in_progress_i             (biu_excl_lf_in_progress_i),
    .biu_stb_ar_ack_i                      (biu_stb_ar_ack_i),
    .biu_stb_ar_resp_i                     (biu_stb_ar_resp_i[1:0]),
    .slot_has_ar_priority_i                (slot2_has_ar_priority),
    .dc_size_i                             (dc_size_i[2:0]),
    .slot_force_drain_i                    (slot2_force_drain),
    .slot_force_drain_biudata_i            (slot2_force_drain_biudata),
    .stb_cycle_count_127_i                 (stb_cycle_count_127),
    .stb_cycle_count_1023_i                (stb_cycle_count_1023),
    .biu_read_alloc_mode_i                 (biu_read_alloc_mode_i),
    .next_dev_bursting_i                   (next_dev_bursting),
    .dev_delay_ar_req_i                    (dev_delay_ar_req),
    .dcu_leaving_dc2_i                     (dcu_leaving_dc2_i),
    .dcu_store_dc2_i                       (dcu_store_dc2_i),
    .dpu_kill_wr_i                         (dpu_kill_wr_i),
    .slot_has_lookup_priority_i            (slot2_has_lookup_priority),
    .slot_has_cache_data_priority_i        (slot2_has_cache_data_priority),
    .slot_has_tagwrite_priority_i          (slot2_has_tagwrite_priority),
    .slot_has_write_addr_priority_i        (slot2_has_write_addr_priority),
    .slot_has_cleanunique_priority_i       (slot2_has_cleanunique_priority),
    .slot_ar_resp_valid_i                  (slot2_ar_resp_valid),
    .biu_stb_ar_resp_l2dbid_i              (biu_stb_ar_resp_l2dbid_i[3:0]),
    .dcu_ccb_index_i                       (dcu_ccb_index_i[13:6]),
    .dcu_ccb_ways_i                        (dcu_ccb_ways_i[3:0]),
    .dcu_ccb_req_valid_i                   (dcu_ccb_req_valid_i),
    .dcu_exclusive_monitor_i               (dcu_exclusive_monitor_i),
    .dvm_sync_needed_i                     (dvm_sync_needed),
    .propagate_barrier_i                   (propagate_barrier),
    .dpu_disable_dmb_i                     (dpu_disable_dmb_i),
    .dvm_complete_i                        (dvm_complete),
    .stb_force_non_mergeable_i             (stb_force_non_mergeable),
    // Outputs
    .slot_valid_o                          (slot2_valid),
    .slot_emptying_o                       (slot2_emptying),
    .slot_state_biureq_o                   (slot2_state_biureq),
    .slot_state_biumerge_o                 (slot2_state_biumerge),
    .slot_state_biuack_o                   (slot2_state_biuack),
    .slot_state_biuresp_o                  (slot2_state_biuresp),
    .slot_state_biudata_o                  (slot2_state_biudata),
    .slot_state_lfreq_o                    (slot2_state_lfreq),
    .slot_state_lookupreq_o                (slot2_state_lookupreq),
    .slot_state_lookupm1_o                 (slot2_state_lookupm1),
    .slot_state_lookupm2_o                 (slot2_state_lookupm2),
    .slot_state_special_o                  (slot2_state_special),
    .slot_state_tagwrite_o                 (slot2_state_tagwrite),
    .slot_state_cachemerge_o               (slot2_state_cachemerge),
    .slot_state_cachewritereq_o            (slot2_state_cachewritereq),
    .slot_state_cachereadm0_o              (slot2_state_cachereadm0),
    .slot_state_cachereadm1_o              (slot2_state_cachereadm1),
    .slot_state_cachereadm2_o              (slot2_state_cachereadm2),
    .slot_state_cacheecc_o                 (slot2_state_cacheecc),
    .slot_state_cachewritem1_o             (slot2_state_cachewritem1),
    .slot_state_cp15resp_o                 (slot2_state_cp15resp),
    .slot_state_cleanunique_req_o          (slot2_state_cleanunique_req),
    .slot_state_cleanunique_ack_o          (slot2_state_cleanunique_ack),
    .slot_state_cleanunique_resp_o         (slot2_state_cleanunique_resp),
    .slot_state_barrier_ack_o              (slot2_state_barrier_ack),
    .slot_write_sync_cmo_ack_o             (slot2_write_sync_cmo_ack),
    .slot_attrs_o                          (slot2_attrs[7:0]),
    .slot_addr_o                           (slot2_addr[39:0]),
    .slot_ns_o                             (slot2_ns),
    .slot_data_o                           (slot2_data[127:0]),
    .slot_cache_bls_o                      (slot2_cache_bls[15:0]),
    .slot_write_data_o                     (slot2_write_data[127:0]),
    .slot_write_bls_o                      (slot2_write_bls[15:0]),
    .slot_write_chunk_o                    (slot2_write_chunk[1:0]),
    .slot_write_last_o                     (slot2_write_last),
    .slot_mergeable_o                      (slot2_mergeable),
    .slot_barriered_o                      (slot2_barriered),
    .slot_earlier_o                        (slot2_earlier[3:0]),
    .slot_earlier_lf_o                     (slot2_earlier_lf[3:0]),
    .slot_cp15_o                           (slot2_cp15),
    .slot_dsb_o                            (slot2_dsb),
    .slot_way_onehot_o                     (slot2_way_onehot[3:0]),
    .slot_way_o                            (slot2_way[1:0]),
    .slot_migratory_o                      (slot2_migratory),
    .slot_ar_way_o                         (slot2_ar_way[1:0]),
    .slot_lf_hz_seen_o                     (slot2_lf_hz_seen),
    .slot_lf_hz_capture_o                  (slot2_lf_hz_capture),
    .slot_coherent_o                       (slot2_coherent),
    .slot_l2dbid_o                         (slot2_l2dbid[3:0]),
    .slot_no_alloc_on_miss_o               (slot2_no_alloc_on_miss),
    .slot_more_dev_expected_o              (slot2_more_dev_expected),
    .slot_sameline_beat_count_o            (slot2_sameline_beat_count[2:0]),
    .slot_has_cleanunique_duty_o           (slot2_has_cleanunique_duty),
    .slot_load_sameline_seen_o             (slot2_load_sameline_seen),
    .slot_load_sameline_o                  (slot2_load_sameline),
    .slot_can_merge_dc2_o                  (slot2_can_merge_dc2),
    .slot_sameline_dc2_o                   (slot2_sameline_dc2),
    .slot_load_sameline_dc2_o              (slot2_load_sameline_dc2),
    .slot_attr_mismatch_dc2_o              (slot2_attr_mismatch_dc2),
    .slot_hit_dc2_o                        (slot2_hit_dc2[15:0]),
    .slot_wants_write_data_priority_o      (slot2_wants_write_data_priority),
    .slot_has_write_data_priority_o        (slot2_has_write_data_priority),
    .slot_write_data_suppress_o            (slot2_write_data_suppress),
    .slot_write_accept_o                   (slot2_write_accept),
    .slot_lf_active_o                      (slot2_lf_active),
    .slot_lf_req_o                         (slot2_lf_req),
    .slot_lf_merge_o                       (slot2_lf_merge),
    .slot_ev_hazard_o                      (slot2_ev_hazard),
    .slot_ev_hz_seen_o                     (slot2_ev_hz_seen),
    .slot_wants_ar_priority_o              (slot2_wants_ar_priority),
    .slot_might_want_ar_priority_o         (slot2_might_want_ar_priority),
    .slot_already_has_ar_priority_o        (slot2_already_has_ar_priority),
    .slot_ar_suppress_o                    (slot2_ar_suppress),
    .slot_ar_addr_o                        (slot2_ar_addr[39:0]),
    .slot_ar_ns_o                          (slot2_ar_ns),
    .slot_ar_priv_o                        (slot2_ar_priv),
    .slot_ar_excl_o                        (slot2_ar_excl),
    .slot_cp15_asid_o                      (slot2_cp15_asid[15:0]),
    .slot_cp15_vmid_o                      (slot2_cp15_vmid[7:0]),
    .slot_cp15_va_o                        (slot2_cp15_va[24:0]),
    .slot_wants_lookup_priority_o          (slot2_wants_lookup_priority),
    .slot_might_want_cache_data_priority_o (slot2_might_want_cache_data_priority),
    .slot_wants_cache_data_priority_o      (slot2_wants_cache_data_priority),
    .slot_wants_tagwrite_priority_o        (slot2_wants_tagwrite_priority),
    .slot_wants_write_addr_priority_o      (slot2_wants_write_addr_priority),
    .slot_wants_cleanunique_priority_o     (slot2_wants_cleanunique_priority),
    .slot_biu_write_req_active_o           (slot2_biu_write_req_active),
    .slot_block_ccb_o                      (slot2_block_ccb),
    .slot_block_loads_dc1_o                (slot2_block_loads_dc1),
    .slot_excl_fail_o                      (slot2_excl_fail),
    .slot_excl_done_o                      (slot2_excl_done),
    .slot_type_o                           (slot2_type[7:0]),
    .slot_might_req_o                      (slot2_might_req),
    .slot_force_non_mergeable_o            (slot2_force_non_mergeable)
  );  // u_slot2

  ca53stb_slot `CA53_STB_PARAM_INST u_slot3 (
    /*ARMAUTO*/
    //TEMPLATE s/slot_/slot3_/
    //TEMPLATE s/slota_/slot0_/
    //TEMPLATE s/slotb_/slot1_/
    //TEMPLATE s/slotc_/slot2_/
    //TEMPLATE s/slotd_/slot4_/
    .slot_load_sameline_dc3_i              (dcu_load_sameline_dc3_i[3]),
    .slot_store_merge_dc3_i                (dcu_store_merge_dc3_i[3]),
    .slot_biu_ev_hazard_i                  (biu_ev_hazard_i[3]),
    .slot_biu_lf_hazard_way_i              (biu_lf_hazard_way_slot3_i),
    // Inputs
    .clk                                   (clk),
    .slot_clk                              (slot3_clk),
    .reset_n                               (reset_n),
    .slota_valid_i                         (slot0_valid),
    .slota_emptying_i                      (slot0_emptying),
    .slota_state_biureq_i                  (slot0_state_biureq),
    .slota_state_biuack_i                  (slot0_state_biuack),
    .slota_state_biuresp_i                 (slot0_state_biuresp),
    .slota_state_biudata_i                 (slot0_state_biudata),
    .slota_state_lfreq_i                   (slot0_state_lfreq),
    .slota_state_lookupreq_i               (slot0_state_lookupreq),
    .slota_state_lookupm1_i                (slot0_state_lookupm1),
    .slota_state_lookupm2_i                (slot0_state_lookupm2),
    .slota_state_tagwrite_i                (slot0_state_tagwrite),
    .slota_state_cachemerge_i              (slot0_state_cachemerge),
    .slota_state_cachereadm0_i             (slot0_state_cachereadm0),
    .slota_state_cachereadm1_i             (slot0_state_cachereadm1),
    .slota_state_cachereadm2_i             (slot0_state_cachereadm2),
    .slota_state_cacheecc_i                (slot0_state_cacheecc),
    .slota_state_cachewritereq_i           (slot0_state_cachewritereq),
    .slota_state_cachewritem1_i            (slot0_state_cachewritem1),
    .slota_state_cp15resp_i                (slot0_state_cp15resp),
    .slota_state_cleanunique_req_i         (slot0_state_cleanunique_req),
    .slota_state_cleanunique_ack_i         (slot0_state_cleanunique_ack),
    .slota_state_cleanunique_resp_i        (slot0_state_cleanunique_resp),
    .slota_mergeable_i                     (slot0_mergeable),
    .slota_barriered_i                     (slot0_barriered),
    .slota_has_lookup_priority_i           (slot0_has_lookup_priority),
    .slota_has_tagwrite_priority_i         (slot0_has_tagwrite_priority),
    .slota_ar_resp_valid_i                 (slot0_ar_resp_valid),
    .slota_has_write_addr_priority_i       (slot0_has_write_addr_priority),
    .slota_has_cleanunique_priority_i      (slot0_has_cleanunique_priority),
    .slota_way_i                           (slot0_way[1:0]),
    .slota_migratory_i                     (slot0_migratory),
    .slota_ev_hazard_i                     (slot0_ev_hazard),
    .slota_ev_hz_seen_i                    (slot0_ev_hz_seen),
    .slota_lf_hz_seen_i                    (slot0_lf_hz_seen),
    .slota_lf_hz_capture_i                 (slot0_lf_hz_capture),
    .slota_coherent_i                      (slot0_coherent),
    .slota_biu_lf_hazard_i                 (slot0_biu_lf_hazard),
    .slota_l2dbid_i                        (slot0_l2dbid[3:0]),
    .slota_no_alloc_on_miss_i              (slot0_no_alloc_on_miss),
    .slota_sameline_beat_count_i           (slot0_sameline_beat_count[2:0]),
    .slota_wants_write_data_priority_i     (slot0_wants_write_data_priority),
    .slota_write_accept_i                  (slot0_write_accept),
    .slota_more_dev_expected_i             (slot0_more_dev_expected),
    .slota_lf_req_i                        (slot0_lf_req),
    .slota_has_cleanunique_duty_i          (slot0_has_cleanunique_duty),
    .slota_load_sameline_seen_i            (slot0_load_sameline_seen),
    .slota_load_sameline_i                 (slot0_load_sameline),
    .slotb_valid_i                         (slot1_valid),
    .slotb_emptying_i                      (slot1_emptying),
    .slotb_state_biureq_i                  (slot1_state_biureq),
    .slotb_state_biuack_i                  (slot1_state_biuack),
    .slotb_state_biuresp_i                 (slot1_state_biuresp),
    .slotb_state_biudata_i                 (slot1_state_biudata),
    .slotb_state_lfreq_i                   (slot1_state_lfreq),
    .slotb_state_lookupreq_i               (slot1_state_lookupreq),
    .slotb_state_lookupm1_i                (slot1_state_lookupm1),
    .slotb_state_lookupm2_i                (slot1_state_lookupm2),
    .slotb_state_tagwrite_i                (slot1_state_tagwrite),
    .slotb_state_cachemerge_i              (slot1_state_cachemerge),
    .slotb_state_cachereadm0_i             (slot1_state_cachereadm0),
    .slotb_state_cachereadm1_i             (slot1_state_cachereadm1),
    .slotb_state_cachereadm2_i             (slot1_state_cachereadm2),
    .slotb_state_cacheecc_i                (slot1_state_cacheecc),
    .slotb_state_cachewritereq_i           (slot1_state_cachewritereq),
    .slotb_state_cachewritem1_i            (slot1_state_cachewritem1),
    .slotb_state_cp15resp_i                (slot1_state_cp15resp),
    .slotb_state_cleanunique_req_i         (slot1_state_cleanunique_req),
    .slotb_state_cleanunique_ack_i         (slot1_state_cleanunique_ack),
    .slotb_state_cleanunique_resp_i        (slot1_state_cleanunique_resp),
    .slotb_mergeable_i                     (slot1_mergeable),
    .slotb_barriered_i                     (slot1_barriered),
    .slotb_has_lookup_priority_i           (slot1_has_lookup_priority),
    .slotb_has_tagwrite_priority_i         (slot1_has_tagwrite_priority),
    .slotb_ar_resp_valid_i                 (slot1_ar_resp_valid),
    .slotb_has_write_addr_priority_i       (slot1_has_write_addr_priority),
    .slotb_has_cleanunique_priority_i      (slot1_has_cleanunique_priority),
    .slotb_way_i                           (slot1_way[1:0]),
    .slotb_migratory_i                     (slot1_migratory),
    .slotb_ev_hazard_i                     (slot1_ev_hazard),
    .slotb_ev_hz_seen_i                    (slot1_ev_hz_seen),
    .slotb_lf_hz_seen_i                    (slot1_lf_hz_seen),
    .slotb_lf_hz_capture_i                 (slot1_lf_hz_capture),
    .slotb_coherent_i                      (slot1_coherent),
    .slotb_biu_lf_hazard_i                 (slot1_biu_lf_hazard),
    .slotb_l2dbid_i                        (slot1_l2dbid[3:0]),
    .slotb_no_alloc_on_miss_i              (slot1_no_alloc_on_miss),
    .slotb_sameline_beat_count_i           (slot1_sameline_beat_count[2:0]),
    .slotb_wants_write_data_priority_i     (slot1_wants_write_data_priority),
    .slotb_write_accept_i                  (slot1_write_accept),
    .slotb_more_dev_expected_i             (slot1_more_dev_expected),
    .slotb_lf_req_i                        (slot1_lf_req),
    .slotb_has_cleanunique_duty_i          (slot1_has_cleanunique_duty),
    .slotb_load_sameline_seen_i            (slot1_load_sameline_seen),
    .slotb_load_sameline_i                 (slot1_load_sameline),
    .slotc_valid_i                         (slot2_valid),
    .slotc_emptying_i                      (slot2_emptying),
    .slotc_state_biureq_i                  (slot2_state_biureq),
    .slotc_state_biuack_i                  (slot2_state_biuack),
    .slotc_state_biuresp_i                 (slot2_state_biuresp),
    .slotc_state_biudata_i                 (slot2_state_biudata),
    .slotc_state_lfreq_i                   (slot2_state_lfreq),
    .slotc_state_lookupreq_i               (slot2_state_lookupreq),
    .slotc_state_lookupm1_i                (slot2_state_lookupm1),
    .slotc_state_lookupm2_i                (slot2_state_lookupm2),
    .slotc_state_tagwrite_i                (slot2_state_tagwrite),
    .slotc_state_cachemerge_i              (slot2_state_cachemerge),
    .slotc_state_cachereadm0_i             (slot2_state_cachereadm0),
    .slotc_state_cachereadm1_i             (slot2_state_cachereadm1),
    .slotc_state_cachereadm2_i             (slot2_state_cachereadm2),
    .slotc_state_cacheecc_i                (slot2_state_cacheecc),
    .slotc_state_cachewritereq_i           (slot2_state_cachewritereq),
    .slotc_state_cachewritem1_i            (slot2_state_cachewritem1),
    .slotc_state_cp15resp_i                (slot2_state_cp15resp),
    .slotc_state_cleanunique_req_i         (slot2_state_cleanunique_req),
    .slotc_state_cleanunique_ack_i         (slot2_state_cleanunique_ack),
    .slotc_state_cleanunique_resp_i        (slot2_state_cleanunique_resp),
    .slotc_mergeable_i                     (slot2_mergeable),
    .slotc_barriered_i                     (slot2_barriered),
    .slotc_has_lookup_priority_i           (slot2_has_lookup_priority),
    .slotc_has_tagwrite_priority_i         (slot2_has_tagwrite_priority),
    .slotc_ar_resp_valid_i                 (slot2_ar_resp_valid),
    .slotc_has_write_addr_priority_i       (slot2_has_write_addr_priority),
    .slotc_has_cleanunique_priority_i      (slot2_has_cleanunique_priority),
    .slotc_way_i                           (slot2_way[1:0]),
    .slotc_migratory_i                     (slot2_migratory),
    .slotc_ev_hazard_i                     (slot2_ev_hazard),
    .slotc_ev_hz_seen_i                    (slot2_ev_hz_seen),
    .slotc_lf_hz_seen_i                    (slot2_lf_hz_seen),
    .slotc_lf_hz_capture_i                 (slot2_lf_hz_capture),
    .slotc_coherent_i                      (slot2_coherent),
    .slotc_biu_lf_hazard_i                 (slot2_biu_lf_hazard),
    .slotc_l2dbid_i                        (slot2_l2dbid[3:0]),
    .slotc_no_alloc_on_miss_i              (slot2_no_alloc_on_miss),
    .slotc_sameline_beat_count_i           (slot2_sameline_beat_count[2:0]),
    .slotc_wants_write_data_priority_i     (slot2_wants_write_data_priority),
    .slotc_write_accept_i                  (slot2_write_accept),
    .slotc_more_dev_expected_i             (slot2_more_dev_expected),
    .slotc_lf_req_i                        (slot2_lf_req),
    .slotc_has_cleanunique_duty_i          (slot2_has_cleanunique_duty),
    .slotc_load_sameline_seen_i            (slot2_load_sameline_seen),
    .slotc_load_sameline_i                 (slot2_load_sameline),
    .slotd_valid_i                         (slot4_valid),
    .slotd_emptying_i                      (slot4_emptying),
    .slotd_state_biureq_i                  (slot4_state_biureq),
    .slotd_state_biuack_i                  (slot4_state_biuack),
    .slotd_state_biuresp_i                 (slot4_state_biuresp),
    .slotd_state_biudata_i                 (slot4_state_biudata),
    .slotd_state_lfreq_i                   (slot4_state_lfreq),
    .slotd_state_lookupreq_i               (slot4_state_lookupreq),
    .slotd_state_lookupm1_i                (slot4_state_lookupm1),
    .slotd_state_lookupm2_i                (slot4_state_lookupm2),
    .slotd_state_tagwrite_i                (slot4_state_tagwrite),
    .slotd_state_cachemerge_i              (slot4_state_cachemerge),
    .slotd_state_cachereadm0_i             (slot4_state_cachereadm0),
    .slotd_state_cachereadm1_i             (slot4_state_cachereadm1),
    .slotd_state_cachereadm2_i             (slot4_state_cachereadm2),
    .slotd_state_cacheecc_i                (slot4_state_cacheecc),
    .slotd_state_cachewritereq_i           (slot4_state_cachewritereq),
    .slotd_state_cachewritem1_i            (slot4_state_cachewritem1),
    .slotd_state_cp15resp_i                (slot4_state_cp15resp),
    .slotd_state_cleanunique_req_i         (slot4_state_cleanunique_req),
    .slotd_state_cleanunique_ack_i         (slot4_state_cleanunique_ack),
    .slotd_state_cleanunique_resp_i        (slot4_state_cleanunique_resp),
    .slotd_mergeable_i                     (slot4_mergeable),
    .slotd_barriered_i                     (slot4_barriered),
    .slotd_has_lookup_priority_i           (slot4_has_lookup_priority),
    .slotd_has_tagwrite_priority_i         (slot4_has_tagwrite_priority),
    .slotd_ar_resp_valid_i                 (slot4_ar_resp_valid),
    .slotd_has_write_addr_priority_i       (slot4_has_write_addr_priority),
    .slotd_has_cleanunique_priority_i      (slot4_has_cleanunique_priority),
    .slotd_way_i                           (slot4_way[1:0]),
    .slotd_migratory_i                     (slot4_migratory),
    .slotd_ev_hazard_i                     (slot4_ev_hazard),
    .slotd_ev_hz_seen_i                    (slot4_ev_hz_seen),
    .slotd_lf_hz_seen_i                    (slot4_lf_hz_seen),
    .slotd_lf_hz_capture_i                 (slot4_lf_hz_capture),
    .slotd_coherent_i                      (slot4_coherent),
    .slotd_biu_lf_hazard_i                 (slot4_biu_lf_hazard),
    .slotd_l2dbid_i                        (slot4_l2dbid[3:0]),
    .slotd_no_alloc_on_miss_i              (slot4_no_alloc_on_miss),
    .slotd_sameline_beat_count_i           (slot4_sameline_beat_count[2:0]),
    .slotd_wants_write_data_priority_i     (slot4_wants_write_data_priority),
    .slotd_write_accept_i                  (slot4_write_accept),
    .slotd_more_dev_expected_i             (slot4_more_dev_expected),
    .slotd_lf_req_i                        (slot4_lf_req),
    .slotd_has_cleanunique_duty_i          (slot4_has_cleanunique_duty),
    .slotd_load_sameline_seen_i            (slot4_load_sameline_seen),
    .slotd_load_sameline_i                 (slot4_load_sameline),
    .dcu_pa_dc2_i                          (dcu_pa_dc2_i[39:3]),
    .dcu_ns_dsc_dc2_i                      (dcu_ns_dsc_dc2_i),
    .dcu_attrs_dc2_i                       (dcu_attrs_dc2_i[7:0]),
    .slot_new_req_dc3_i                    (slot3_new_req_dc3),
    .dcu_pa_dc3_i                          (dcu_pa_dc3_i[39:0]),
    .dcu_ns_dsc_dc3_i                      (dcu_ns_dsc_dc3_i),
    .dcu_priv_dc3_i                        (dcu_priv_dc3_i),
    .dcu_stb_exclusive_dc3_i               (dcu_stb_exclusive_dc3_i),
    .dcu_stb_mergeable_dc3_i               (dcu_stb_mergeable_dc3),
    .dcu_store_cp15_dc3_i                  (dcu_store_cp15_dc3_i),
    .dcu_stlr_dc3_i                        (dcu_stlr_dc3_i),
    .dcu_stb_attrs_dc3_i                   (dcu_stb_attrs_dc3_i[7:0]),
    .dpu_st_data_wr_i                      (dpu_st_data_wr_i[127:0]),
    .dcu_store_bls_dc3_i                   (dcu_store_bls_dc3_i[15:0]),
    .dcu_store_last_dc3_i                  (dcu_store_last_dc3_i),
    .dcu_store_dsb_dc3_i                   (dcu_store_dsb_dc3_i),
    .dcu_store_dmb_dc3_i                   (dcu_store_dmb_dc3_i),
    .dcu_force_non_mergeable_dc3_i         (dcu_force_non_mergeable_dc3_i),
    .slota_new_req_dc3_i                   (slot0_new_req_dc3),
    .slotb_new_req_dc3_i                   (slot1_new_req_dc3),
    .slotc_new_req_dc3_i                   (slot2_new_req_dc3),
    .slotd_new_req_dc3_i                   (slot4_new_req_dc3),
    .slot_dcu_store_sameline_dc3_i         (slot3_dcu_store_sameline_dc3),
    .slota_dcu_store_sameline_dc3_i        (slot0_dcu_store_sameline_dc3),
    .slotb_dcu_store_sameline_dc3_i        (slot1_dcu_store_sameline_dc3),
    .slotc_dcu_store_sameline_dc3_i        (slot2_dcu_store_sameline_dc3),
    .slotd_dcu_store_sameline_dc3_i        (slot4_dcu_store_sameline_dc3),
    .dcu_stb_tag_has_priority_m0_i         (dcu_stb_tag_has_priority_m0_i),
    .dcu_stb_data_has_priority_m0_i        (dcu_stb_data_has_priority_m0_i),
    .dcu_stb_tag_ack_m1_i                  (dcu_stb_tag_ack_m1_i),
    .dcu_stb_data_ack_m1_i                 (dcu_stb_data_ack_m1_i),
    .dcu_stb_tag_hit_m2_i                  (dcu_stb_tag_hit_m2_i[3:0]),
    .dcu_stb_tag_shared_m2_i               (dcu_stb_tag_shared_m2_i),
    .dcu_stb_tag_migratory_m2_i            (dcu_stb_tag_migratory_m2_i),
    .dcu_stb_victim_way_m2_i               (dcu_stb_victim_way_m2_i[3:0]),
    .dcu_stb_read_data_m2_i                (dcu_stb_read_data_m2_i[127:0]),
    .dcu_stb_read_wls_m2_i                 (dcu_stb_read_wls_m2[3:0]),
    .dcu_ecc_data_err_m3_i                 (dcu_ecc_data_err_m3_i),
    .dcu_ecc_in_progress_i                 (dcu_ecc_in_progress_i),
    .tag_hit_shared_m3_i                   (tag_hit_shared_m3[1:0]),
    .tag_ecc_err_m3_i                      (tag_ecc_err_m3),
    .biu_stb_write_accept_i                (biu_stb_write_accept_i),
    .slot_biu_lf_hazard_i                  (slot3_biu_lf_hazard),
    .slot_biu_lf_real_hazard_i             (slot3_biu_lf_real_hazard),
    .slot_biu_lf_hazard_migratory_i        (slot3_biu_lf_hazard_migratory),
    .slot_biu_lf_serialized_i              (slot3_biu_lf_serialized),
    .slot_biu_lf_can_merge_i               (slot3_biu_lf_can_merge),
    .biu_dirty_lf_in_progress_i            (biu_dirty_lf_in_progress_i),
    .biu_excl_lf_in_progress_i             (biu_excl_lf_in_progress_i),
    .biu_stb_ar_ack_i                      (biu_stb_ar_ack_i),
    .biu_stb_ar_resp_i                     (biu_stb_ar_resp_i[1:0]),
    .slot_has_ar_priority_i                (slot3_has_ar_priority),
    .dc_size_i                             (dc_size_i[2:0]),
    .slot_force_drain_i                    (slot3_force_drain),
    .slot_force_drain_biudata_i            (slot3_force_drain_biudata),
    .stb_cycle_count_127_i                 (stb_cycle_count_127),
    .stb_cycle_count_1023_i                (stb_cycle_count_1023),
    .biu_read_alloc_mode_i                 (biu_read_alloc_mode_i),
    .next_dev_bursting_i                   (next_dev_bursting),
    .dev_delay_ar_req_i                    (dev_delay_ar_req),
    .dcu_leaving_dc2_i                     (dcu_leaving_dc2_i),
    .dcu_store_dc2_i                       (dcu_store_dc2_i),
    .dpu_kill_wr_i                         (dpu_kill_wr_i),
    .slot_has_lookup_priority_i            (slot3_has_lookup_priority),
    .slot_has_cache_data_priority_i        (slot3_has_cache_data_priority),
    .slot_has_tagwrite_priority_i          (slot3_has_tagwrite_priority),
    .slot_has_write_addr_priority_i        (slot3_has_write_addr_priority),
    .slot_has_cleanunique_priority_i       (slot3_has_cleanunique_priority),
    .slot_ar_resp_valid_i                  (slot3_ar_resp_valid),
    .biu_stb_ar_resp_l2dbid_i              (biu_stb_ar_resp_l2dbid_i[3:0]),
    .dcu_ccb_index_i                       (dcu_ccb_index_i[13:6]),
    .dcu_ccb_ways_i                        (dcu_ccb_ways_i[3:0]),
    .dcu_ccb_req_valid_i                   (dcu_ccb_req_valid_i),
    .dcu_exclusive_monitor_i               (dcu_exclusive_monitor_i),
    .dvm_sync_needed_i                     (dvm_sync_needed),
    .propagate_barrier_i                   (propagate_barrier),
    .dpu_disable_dmb_i                     (dpu_disable_dmb_i),
    .dvm_complete_i                        (dvm_complete),
    .stb_force_non_mergeable_i             (stb_force_non_mergeable),
    // Outputs
    .slot_valid_o                          (slot3_valid),
    .slot_emptying_o                       (slot3_emptying),
    .slot_state_biureq_o                   (slot3_state_biureq),
    .slot_state_biumerge_o                 (slot3_state_biumerge),
    .slot_state_biuack_o                   (slot3_state_biuack),
    .slot_state_biuresp_o                  (slot3_state_biuresp),
    .slot_state_biudata_o                  (slot3_state_biudata),
    .slot_state_lfreq_o                    (slot3_state_lfreq),
    .slot_state_lookupreq_o                (slot3_state_lookupreq),
    .slot_state_lookupm1_o                 (slot3_state_lookupm1),
    .slot_state_lookupm2_o                 (slot3_state_lookupm2),
    .slot_state_special_o                  (slot3_state_special),
    .slot_state_tagwrite_o                 (slot3_state_tagwrite),
    .slot_state_cachemerge_o               (slot3_state_cachemerge),
    .slot_state_cachewritereq_o            (slot3_state_cachewritereq),
    .slot_state_cachereadm0_o              (slot3_state_cachereadm0),
    .slot_state_cachereadm1_o              (slot3_state_cachereadm1),
    .slot_state_cachereadm2_o              (slot3_state_cachereadm2),
    .slot_state_cacheecc_o                 (slot3_state_cacheecc),
    .slot_state_cachewritem1_o             (slot3_state_cachewritem1),
    .slot_state_cp15resp_o                 (slot3_state_cp15resp),
    .slot_state_cleanunique_req_o          (slot3_state_cleanunique_req),
    .slot_state_cleanunique_ack_o          (slot3_state_cleanunique_ack),
    .slot_state_cleanunique_resp_o         (slot3_state_cleanunique_resp),
    .slot_state_barrier_ack_o              (slot3_state_barrier_ack),
    .slot_write_sync_cmo_ack_o             (slot3_write_sync_cmo_ack),
    .slot_attrs_o                          (slot3_attrs[7:0]),
    .slot_addr_o                           (slot3_addr[39:0]),
    .slot_ns_o                             (slot3_ns),
    .slot_data_o                           (slot3_data[127:0]),
    .slot_cache_bls_o                      (slot3_cache_bls[15:0]),
    .slot_write_data_o                     (slot3_write_data[127:0]),
    .slot_write_bls_o                      (slot3_write_bls[15:0]),
    .slot_write_chunk_o                    (slot3_write_chunk[1:0]),
    .slot_write_last_o                     (slot3_write_last),
    .slot_mergeable_o                      (slot3_mergeable),
    .slot_barriered_o                      (slot3_barriered),
    .slot_earlier_o                        (slot3_earlier[3:0]),
    .slot_earlier_lf_o                     (slot3_earlier_lf[3:0]),
    .slot_cp15_o                           (slot3_cp15),
    .slot_dsb_o                            (slot3_dsb),
    .slot_way_onehot_o                     (slot3_way_onehot[3:0]),
    .slot_way_o                            (slot3_way[1:0]),
    .slot_migratory_o                      (slot3_migratory),
    .slot_ar_way_o                         (slot3_ar_way[1:0]),
    .slot_lf_hz_seen_o                     (slot3_lf_hz_seen),
    .slot_lf_hz_capture_o                  (slot3_lf_hz_capture),
    .slot_coherent_o                       (slot3_coherent),
    .slot_l2dbid_o                         (slot3_l2dbid[3:0]),
    .slot_no_alloc_on_miss_o               (slot3_no_alloc_on_miss),
    .slot_more_dev_expected_o              (slot3_more_dev_expected),
    .slot_sameline_beat_count_o            (slot3_sameline_beat_count[2:0]),
    .slot_has_cleanunique_duty_o           (slot3_has_cleanunique_duty),
    .slot_load_sameline_seen_o             (slot3_load_sameline_seen),
    .slot_load_sameline_o                  (slot3_load_sameline),
    .slot_can_merge_dc2_o                  (slot3_can_merge_dc2),
    .slot_sameline_dc2_o                   (slot3_sameline_dc2),
    .slot_load_sameline_dc2_o              (slot3_load_sameline_dc2),
    .slot_attr_mismatch_dc2_o              (slot3_attr_mismatch_dc2),
    .slot_hit_dc2_o                        (slot3_hit_dc2[15:0]),
    .slot_wants_write_data_priority_o      (slot3_wants_write_data_priority),
    .slot_has_write_data_priority_o        (slot3_has_write_data_priority),
    .slot_write_data_suppress_o            (slot3_write_data_suppress),
    .slot_write_accept_o                   (slot3_write_accept),
    .slot_lf_active_o                      (slot3_lf_active),
    .slot_lf_req_o                         (slot3_lf_req),
    .slot_lf_merge_o                       (slot3_lf_merge),
    .slot_ev_hazard_o                      (slot3_ev_hazard),
    .slot_ev_hz_seen_o                     (slot3_ev_hz_seen),
    .slot_wants_ar_priority_o              (slot3_wants_ar_priority),
    .slot_might_want_ar_priority_o         (slot3_might_want_ar_priority),
    .slot_already_has_ar_priority_o        (slot3_already_has_ar_priority),
    .slot_ar_suppress_o                    (slot3_ar_suppress),
    .slot_ar_addr_o                        (slot3_ar_addr[39:0]),
    .slot_ar_ns_o                          (slot3_ar_ns),
    .slot_ar_priv_o                        (slot3_ar_priv),
    .slot_ar_excl_o                        (slot3_ar_excl),
    .slot_cp15_asid_o                      (slot3_cp15_asid[15:0]),
    .slot_cp15_vmid_o                      (slot3_cp15_vmid[7:0]),
    .slot_cp15_va_o                        (slot3_cp15_va[24:0]),
    .slot_wants_lookup_priority_o          (slot3_wants_lookup_priority),
    .slot_might_want_cache_data_priority_o (slot3_might_want_cache_data_priority),
    .slot_wants_cache_data_priority_o      (slot3_wants_cache_data_priority),
    .slot_wants_tagwrite_priority_o        (slot3_wants_tagwrite_priority),
    .slot_wants_write_addr_priority_o      (slot3_wants_write_addr_priority),
    .slot_wants_cleanunique_priority_o     (slot3_wants_cleanunique_priority),
    .slot_biu_write_req_active_o           (slot3_biu_write_req_active),
    .slot_block_ccb_o                      (slot3_block_ccb),
    .slot_block_loads_dc1_o                (slot3_block_loads_dc1),
    .slot_excl_fail_o                      (slot3_excl_fail),
    .slot_excl_done_o                      (slot3_excl_done),
    .slot_type_o                           (slot3_type[7:0]),
    .slot_might_req_o                      (slot3_might_req),
    .slot_force_non_mergeable_o            (slot3_force_non_mergeable)
  );  // u_slot3

  ca53stb_slot `CA53_STB_PARAM_INST u_slot4 (
    /*ARMAUTO*/
    //TEMPLATE s/slot_/slot4_/
    //TEMPLATE s/slota_/slot0_/
    //TEMPLATE s/slotb_/slot1_/
    //TEMPLATE s/slotc_/slot2_/
    //TEMPLATE s/slotd_/slot3_/
    .slot_load_sameline_dc3_i              (dcu_load_sameline_dc3_i[4]),
    .slot_store_merge_dc3_i                (dcu_store_merge_dc3_i[4]),
    .slot_biu_ev_hazard_i                  (biu_ev_hazard_i[4]),
    .slot_biu_lf_hazard_way_i              (biu_lf_hazard_way_slot4_i),
    // Inputs
    .clk                                   (clk),
    .slot_clk                              (slot4_clk),
    .reset_n                               (reset_n),
    .slota_valid_i                         (slot0_valid),
    .slota_emptying_i                      (slot0_emptying),
    .slota_state_biureq_i                  (slot0_state_biureq),
    .slota_state_biuack_i                  (slot0_state_biuack),
    .slota_state_biuresp_i                 (slot0_state_biuresp),
    .slota_state_biudata_i                 (slot0_state_biudata),
    .slota_state_lfreq_i                   (slot0_state_lfreq),
    .slota_state_lookupreq_i               (slot0_state_lookupreq),
    .slota_state_lookupm1_i                (slot0_state_lookupm1),
    .slota_state_lookupm2_i                (slot0_state_lookupm2),
    .slota_state_tagwrite_i                (slot0_state_tagwrite),
    .slota_state_cachemerge_i              (slot0_state_cachemerge),
    .slota_state_cachereadm0_i             (slot0_state_cachereadm0),
    .slota_state_cachereadm1_i             (slot0_state_cachereadm1),
    .slota_state_cachereadm2_i             (slot0_state_cachereadm2),
    .slota_state_cacheecc_i                (slot0_state_cacheecc),
    .slota_state_cachewritereq_i           (slot0_state_cachewritereq),
    .slota_state_cachewritem1_i            (slot0_state_cachewritem1),
    .slota_state_cp15resp_i                (slot0_state_cp15resp),
    .slota_state_cleanunique_req_i         (slot0_state_cleanunique_req),
    .slota_state_cleanunique_ack_i         (slot0_state_cleanunique_ack),
    .slota_state_cleanunique_resp_i        (slot0_state_cleanunique_resp),
    .slota_mergeable_i                     (slot0_mergeable),
    .slota_barriered_i                     (slot0_barriered),
    .slota_has_lookup_priority_i           (slot0_has_lookup_priority),
    .slota_has_tagwrite_priority_i         (slot0_has_tagwrite_priority),
    .slota_ar_resp_valid_i                 (slot0_ar_resp_valid),
    .slota_has_write_addr_priority_i       (slot0_has_write_addr_priority),
    .slota_has_cleanunique_priority_i      (slot0_has_cleanunique_priority),
    .slota_way_i                           (slot0_way[1:0]),
    .slota_migratory_i                     (slot0_migratory),
    .slota_ev_hazard_i                     (slot0_ev_hazard),
    .slota_ev_hz_seen_i                    (slot0_ev_hz_seen),
    .slota_lf_hz_seen_i                    (slot0_lf_hz_seen),
    .slota_lf_hz_capture_i                 (slot0_lf_hz_capture),
    .slota_coherent_i                      (slot0_coherent),
    .slota_biu_lf_hazard_i                 (slot0_biu_lf_hazard),
    .slota_l2dbid_i                        (slot0_l2dbid[3:0]),
    .slota_no_alloc_on_miss_i              (slot0_no_alloc_on_miss),
    .slota_sameline_beat_count_i           (slot0_sameline_beat_count[2:0]),
    .slota_wants_write_data_priority_i     (slot0_wants_write_data_priority),
    .slota_write_accept_i                  (slot0_write_accept),
    .slota_more_dev_expected_i             (slot0_more_dev_expected),
    .slota_lf_req_i                        (slot0_lf_req),
    .slota_has_cleanunique_duty_i          (slot0_has_cleanunique_duty),
    .slota_load_sameline_seen_i            (slot0_load_sameline_seen),
    .slota_load_sameline_i                 (slot0_load_sameline),
    .slotb_valid_i                         (slot1_valid),
    .slotb_emptying_i                      (slot1_emptying),
    .slotb_state_biureq_i                  (slot1_state_biureq),
    .slotb_state_biuack_i                  (slot1_state_biuack),
    .slotb_state_biuresp_i                 (slot1_state_biuresp),
    .slotb_state_biudata_i                 (slot1_state_biudata),
    .slotb_state_lfreq_i                   (slot1_state_lfreq),
    .slotb_state_lookupreq_i               (slot1_state_lookupreq),
    .slotb_state_lookupm1_i                (slot1_state_lookupm1),
    .slotb_state_lookupm2_i                (slot1_state_lookupm2),
    .slotb_state_tagwrite_i                (slot1_state_tagwrite),
    .slotb_state_cachemerge_i              (slot1_state_cachemerge),
    .slotb_state_cachereadm0_i             (slot1_state_cachereadm0),
    .slotb_state_cachereadm1_i             (slot1_state_cachereadm1),
    .slotb_state_cachereadm2_i             (slot1_state_cachereadm2),
    .slotb_state_cacheecc_i                (slot1_state_cacheecc),
    .slotb_state_cachewritereq_i           (slot1_state_cachewritereq),
    .slotb_state_cachewritem1_i            (slot1_state_cachewritem1),
    .slotb_state_cp15resp_i                (slot1_state_cp15resp),
    .slotb_state_cleanunique_req_i         (slot1_state_cleanunique_req),
    .slotb_state_cleanunique_ack_i         (slot1_state_cleanunique_ack),
    .slotb_state_cleanunique_resp_i        (slot1_state_cleanunique_resp),
    .slotb_mergeable_i                     (slot1_mergeable),
    .slotb_barriered_i                     (slot1_barriered),
    .slotb_has_lookup_priority_i           (slot1_has_lookup_priority),
    .slotb_has_tagwrite_priority_i         (slot1_has_tagwrite_priority),
    .slotb_ar_resp_valid_i                 (slot1_ar_resp_valid),
    .slotb_has_write_addr_priority_i       (slot1_has_write_addr_priority),
    .slotb_has_cleanunique_priority_i      (slot1_has_cleanunique_priority),
    .slotb_way_i                           (slot1_way[1:0]),
    .slotb_migratory_i                     (slot1_migratory),
    .slotb_ev_hazard_i                     (slot1_ev_hazard),
    .slotb_ev_hz_seen_i                    (slot1_ev_hz_seen),
    .slotb_lf_hz_seen_i                    (slot1_lf_hz_seen),
    .slotb_lf_hz_capture_i                 (slot1_lf_hz_capture),
    .slotb_coherent_i                      (slot1_coherent),
    .slotb_biu_lf_hazard_i                 (slot1_biu_lf_hazard),
    .slotb_l2dbid_i                        (slot1_l2dbid[3:0]),
    .slotb_no_alloc_on_miss_i              (slot1_no_alloc_on_miss),
    .slotb_sameline_beat_count_i           (slot1_sameline_beat_count[2:0]),
    .slotb_wants_write_data_priority_i     (slot1_wants_write_data_priority),
    .slotb_write_accept_i                  (slot1_write_accept),
    .slotb_more_dev_expected_i             (slot1_more_dev_expected),
    .slotb_lf_req_i                        (slot1_lf_req),
    .slotb_has_cleanunique_duty_i          (slot1_has_cleanunique_duty),
    .slotb_load_sameline_seen_i            (slot1_load_sameline_seen),
    .slotb_load_sameline_i                 (slot1_load_sameline),
    .slotc_valid_i                         (slot2_valid),
    .slotc_emptying_i                      (slot2_emptying),
    .slotc_state_biureq_i                  (slot2_state_biureq),
    .slotc_state_biuack_i                  (slot2_state_biuack),
    .slotc_state_biuresp_i                 (slot2_state_biuresp),
    .slotc_state_biudata_i                 (slot2_state_biudata),
    .slotc_state_lfreq_i                   (slot2_state_lfreq),
    .slotc_state_lookupreq_i               (slot2_state_lookupreq),
    .slotc_state_lookupm1_i                (slot2_state_lookupm1),
    .slotc_state_lookupm2_i                (slot2_state_lookupm2),
    .slotc_state_tagwrite_i                (slot2_state_tagwrite),
    .slotc_state_cachemerge_i              (slot2_state_cachemerge),
    .slotc_state_cachereadm0_i             (slot2_state_cachereadm0),
    .slotc_state_cachereadm1_i             (slot2_state_cachereadm1),
    .slotc_state_cachereadm2_i             (slot2_state_cachereadm2),
    .slotc_state_cacheecc_i                (slot2_state_cacheecc),
    .slotc_state_cachewritereq_i           (slot2_state_cachewritereq),
    .slotc_state_cachewritem1_i            (slot2_state_cachewritem1),
    .slotc_state_cp15resp_i                (slot2_state_cp15resp),
    .slotc_state_cleanunique_req_i         (slot2_state_cleanunique_req),
    .slotc_state_cleanunique_ack_i         (slot2_state_cleanunique_ack),
    .slotc_state_cleanunique_resp_i        (slot2_state_cleanunique_resp),
    .slotc_mergeable_i                     (slot2_mergeable),
    .slotc_barriered_i                     (slot2_barriered),
    .slotc_has_lookup_priority_i           (slot2_has_lookup_priority),
    .slotc_has_tagwrite_priority_i         (slot2_has_tagwrite_priority),
    .slotc_ar_resp_valid_i                 (slot2_ar_resp_valid),
    .slotc_has_write_addr_priority_i       (slot2_has_write_addr_priority),
    .slotc_has_cleanunique_priority_i      (slot2_has_cleanunique_priority),
    .slotc_way_i                           (slot2_way[1:0]),
    .slotc_migratory_i                     (slot2_migratory),
    .slotc_ev_hazard_i                     (slot2_ev_hazard),
    .slotc_ev_hz_seen_i                    (slot2_ev_hz_seen),
    .slotc_lf_hz_seen_i                    (slot2_lf_hz_seen),
    .slotc_lf_hz_capture_i                 (slot2_lf_hz_capture),
    .slotc_coherent_i                      (slot2_coherent),
    .slotc_biu_lf_hazard_i                 (slot2_biu_lf_hazard),
    .slotc_l2dbid_i                        (slot2_l2dbid[3:0]),
    .slotc_no_alloc_on_miss_i              (slot2_no_alloc_on_miss),
    .slotc_sameline_beat_count_i           (slot2_sameline_beat_count[2:0]),
    .slotc_wants_write_data_priority_i     (slot2_wants_write_data_priority),
    .slotc_write_accept_i                  (slot2_write_accept),
    .slotc_more_dev_expected_i             (slot2_more_dev_expected),
    .slotc_lf_req_i                        (slot2_lf_req),
    .slotc_has_cleanunique_duty_i          (slot2_has_cleanunique_duty),
    .slotc_load_sameline_seen_i            (slot2_load_sameline_seen),
    .slotc_load_sameline_i                 (slot2_load_sameline),
    .slotd_valid_i                         (slot3_valid),
    .slotd_emptying_i                      (slot3_emptying),
    .slotd_state_biureq_i                  (slot3_state_biureq),
    .slotd_state_biuack_i                  (slot3_state_biuack),
    .slotd_state_biuresp_i                 (slot3_state_biuresp),
    .slotd_state_biudata_i                 (slot3_state_biudata),
    .slotd_state_lfreq_i                   (slot3_state_lfreq),
    .slotd_state_lookupreq_i               (slot3_state_lookupreq),
    .slotd_state_lookupm1_i                (slot3_state_lookupm1),
    .slotd_state_lookupm2_i                (slot3_state_lookupm2),
    .slotd_state_tagwrite_i                (slot3_state_tagwrite),
    .slotd_state_cachemerge_i              (slot3_state_cachemerge),
    .slotd_state_cachereadm0_i             (slot3_state_cachereadm0),
    .slotd_state_cachereadm1_i             (slot3_state_cachereadm1),
    .slotd_state_cachereadm2_i             (slot3_state_cachereadm2),
    .slotd_state_cacheecc_i                (slot3_state_cacheecc),
    .slotd_state_cachewritereq_i           (slot3_state_cachewritereq),
    .slotd_state_cachewritem1_i            (slot3_state_cachewritem1),
    .slotd_state_cp15resp_i                (slot3_state_cp15resp),
    .slotd_state_cleanunique_req_i         (slot3_state_cleanunique_req),
    .slotd_state_cleanunique_ack_i         (slot3_state_cleanunique_ack),
    .slotd_state_cleanunique_resp_i        (slot3_state_cleanunique_resp),
    .slotd_mergeable_i                     (slot3_mergeable),
    .slotd_barriered_i                     (slot3_barriered),
    .slotd_has_lookup_priority_i           (slot3_has_lookup_priority),
    .slotd_has_tagwrite_priority_i         (slot3_has_tagwrite_priority),
    .slotd_ar_resp_valid_i                 (slot3_ar_resp_valid),
    .slotd_has_write_addr_priority_i       (slot3_has_write_addr_priority),
    .slotd_has_cleanunique_priority_i      (slot3_has_cleanunique_priority),
    .slotd_way_i                           (slot3_way[1:0]),
    .slotd_migratory_i                     (slot3_migratory),
    .slotd_ev_hazard_i                     (slot3_ev_hazard),
    .slotd_ev_hz_seen_i                    (slot3_ev_hz_seen),
    .slotd_lf_hz_seen_i                    (slot3_lf_hz_seen),
    .slotd_lf_hz_capture_i                 (slot3_lf_hz_capture),
    .slotd_coherent_i                      (slot3_coherent),
    .slotd_biu_lf_hazard_i                 (slot3_biu_lf_hazard),
    .slotd_l2dbid_i                        (slot3_l2dbid[3:0]),
    .slotd_no_alloc_on_miss_i              (slot3_no_alloc_on_miss),
    .slotd_sameline_beat_count_i           (slot3_sameline_beat_count[2:0]),
    .slotd_wants_write_data_priority_i     (slot3_wants_write_data_priority),
    .slotd_write_accept_i                  (slot3_write_accept),
    .slotd_more_dev_expected_i             (slot3_more_dev_expected),
    .slotd_lf_req_i                        (slot3_lf_req),
    .slotd_has_cleanunique_duty_i          (slot3_has_cleanunique_duty),
    .slotd_load_sameline_seen_i            (slot3_load_sameline_seen),
    .slotd_load_sameline_i                 (slot3_load_sameline),
    .dcu_pa_dc2_i                          (dcu_pa_dc2_i[39:3]),
    .dcu_ns_dsc_dc2_i                      (dcu_ns_dsc_dc2_i),
    .dcu_attrs_dc2_i                       (dcu_attrs_dc2_i[7:0]),
    .slot_new_req_dc3_i                    (slot4_new_req_dc3),
    .dcu_pa_dc3_i                          (dcu_pa_dc3_i[39:0]),
    .dcu_ns_dsc_dc3_i                      (dcu_ns_dsc_dc3_i),
    .dcu_priv_dc3_i                        (dcu_priv_dc3_i),
    .dcu_stb_exclusive_dc3_i               (dcu_stb_exclusive_dc3_i),
    .dcu_stb_mergeable_dc3_i               (dcu_stb_mergeable_dc3),
    .dcu_store_cp15_dc3_i                  (dcu_store_cp15_dc3_i),
    .dcu_stlr_dc3_i                        (dcu_stlr_dc3_i),
    .dcu_stb_attrs_dc3_i                   (dcu_stb_attrs_dc3_i[7:0]),
    .dpu_st_data_wr_i                      (dpu_st_data_wr_i[127:0]),
    .dcu_store_bls_dc3_i                   (dcu_store_bls_dc3_i[15:0]),
    .dcu_store_last_dc3_i                  (dcu_store_last_dc3_i),
    .dcu_store_dsb_dc3_i                   (dcu_store_dsb_dc3_i),
    .dcu_store_dmb_dc3_i                   (dcu_store_dmb_dc3_i),
    .dcu_force_non_mergeable_dc3_i         (dcu_force_non_mergeable_dc3_i),
    .slota_new_req_dc3_i                   (slot0_new_req_dc3),
    .slotb_new_req_dc3_i                   (slot1_new_req_dc3),
    .slotc_new_req_dc3_i                   (slot2_new_req_dc3),
    .slotd_new_req_dc3_i                   (slot3_new_req_dc3),
    .slot_dcu_store_sameline_dc3_i         (slot4_dcu_store_sameline_dc3),
    .slota_dcu_store_sameline_dc3_i        (slot0_dcu_store_sameline_dc3),
    .slotb_dcu_store_sameline_dc3_i        (slot1_dcu_store_sameline_dc3),
    .slotc_dcu_store_sameline_dc3_i        (slot2_dcu_store_sameline_dc3),
    .slotd_dcu_store_sameline_dc3_i        (slot3_dcu_store_sameline_dc3),
    .dcu_stb_tag_has_priority_m0_i         (dcu_stb_tag_has_priority_m0_i),
    .dcu_stb_data_has_priority_m0_i        (dcu_stb_data_has_priority_m0_i),
    .dcu_stb_tag_ack_m1_i                  (dcu_stb_tag_ack_m1_i),
    .dcu_stb_data_ack_m1_i                 (dcu_stb_data_ack_m1_i),
    .dcu_stb_tag_hit_m2_i                  (dcu_stb_tag_hit_m2_i[3:0]),
    .dcu_stb_tag_shared_m2_i               (dcu_stb_tag_shared_m2_i),
    .dcu_stb_tag_migratory_m2_i            (dcu_stb_tag_migratory_m2_i),
    .dcu_stb_victim_way_m2_i               (dcu_stb_victim_way_m2_i[3:0]),
    .dcu_stb_read_data_m2_i                (dcu_stb_read_data_m2_i[127:0]),
    .dcu_stb_read_wls_m2_i                 (dcu_stb_read_wls_m2[3:0]),
    .dcu_ecc_data_err_m3_i                 (dcu_ecc_data_err_m3_i),
    .dcu_ecc_in_progress_i                 (dcu_ecc_in_progress_i),
    .tag_hit_shared_m3_i                   (tag_hit_shared_m3[1:0]),
    .tag_ecc_err_m3_i                      (tag_ecc_err_m3),
    .biu_stb_write_accept_i                (biu_stb_write_accept_i),
    .slot_biu_lf_hazard_i                  (slot4_biu_lf_hazard),
    .slot_biu_lf_real_hazard_i             (slot4_biu_lf_real_hazard),
    .slot_biu_lf_hazard_migratory_i        (slot4_biu_lf_hazard_migratory),
    .slot_biu_lf_serialized_i              (slot4_biu_lf_serialized),
    .slot_biu_lf_can_merge_i               (slot4_biu_lf_can_merge),
    .biu_dirty_lf_in_progress_i            (biu_dirty_lf_in_progress_i),
    .biu_excl_lf_in_progress_i             (biu_excl_lf_in_progress_i),
    .biu_stb_ar_ack_i                      (biu_stb_ar_ack_i),
    .biu_stb_ar_resp_i                     (biu_stb_ar_resp_i[1:0]),
    .slot_has_ar_priority_i                (slot4_has_ar_priority),
    .dc_size_i                             (dc_size_i[2:0]),
    .slot_force_drain_i                    (slot4_force_drain),
    .slot_force_drain_biudata_i            (slot4_force_drain_biudata),
    .stb_cycle_count_127_i                 (stb_cycle_count_127),
    .stb_cycle_count_1023_i                (stb_cycle_count_1023),
    .biu_read_alloc_mode_i                 (biu_read_alloc_mode_i),
    .next_dev_bursting_i                   (next_dev_bursting),
    .dev_delay_ar_req_i                    (dev_delay_ar_req),
    .dcu_leaving_dc2_i                     (dcu_leaving_dc2_i),
    .dcu_store_dc2_i                       (dcu_store_dc2_i),
    .dpu_kill_wr_i                         (dpu_kill_wr_i),
    .slot_has_lookup_priority_i            (slot4_has_lookup_priority),
    .slot_has_cache_data_priority_i        (slot4_has_cache_data_priority),
    .slot_has_tagwrite_priority_i          (slot4_has_tagwrite_priority),
    .slot_has_write_addr_priority_i        (slot4_has_write_addr_priority),
    .slot_has_cleanunique_priority_i       (slot4_has_cleanunique_priority),
    .slot_ar_resp_valid_i                  (slot4_ar_resp_valid),
    .biu_stb_ar_resp_l2dbid_i              (biu_stb_ar_resp_l2dbid_i[3:0]),
    .dcu_ccb_index_i                       (dcu_ccb_index_i[13:6]),
    .dcu_ccb_ways_i                        (dcu_ccb_ways_i[3:0]),
    .dcu_ccb_req_valid_i                   (dcu_ccb_req_valid_i),
    .dcu_exclusive_monitor_i               (dcu_exclusive_monitor_i),
    .dvm_sync_needed_i                     (dvm_sync_needed),
    .propagate_barrier_i                   (propagate_barrier),
    .dpu_disable_dmb_i                     (dpu_disable_dmb_i),
    .dvm_complete_i                        (dvm_complete),
    .stb_force_non_mergeable_i             (stb_force_non_mergeable),
    // Outputs
    .slot_valid_o                          (slot4_valid),
    .slot_emptying_o                       (slot4_emptying),
    .slot_state_biureq_o                   (slot4_state_biureq),
    .slot_state_biumerge_o                 (slot4_state_biumerge),
    .slot_state_biuack_o                   (slot4_state_biuack),
    .slot_state_biuresp_o                  (slot4_state_biuresp),
    .slot_state_biudata_o                  (slot4_state_biudata),
    .slot_state_lfreq_o                    (slot4_state_lfreq),
    .slot_state_lookupreq_o                (slot4_state_lookupreq),
    .slot_state_lookupm1_o                 (slot4_state_lookupm1),
    .slot_state_lookupm2_o                 (slot4_state_lookupm2),
    .slot_state_special_o                  (slot4_state_special),
    .slot_state_tagwrite_o                 (slot4_state_tagwrite),
    .slot_state_cachemerge_o               (slot4_state_cachemerge),
    .slot_state_cachewritereq_o            (slot4_state_cachewritereq),
    .slot_state_cachereadm0_o              (slot4_state_cachereadm0),
    .slot_state_cachereadm1_o              (slot4_state_cachereadm1),
    .slot_state_cachereadm2_o              (slot4_state_cachereadm2),
    .slot_state_cacheecc_o                 (slot4_state_cacheecc),
    .slot_state_cachewritem1_o             (slot4_state_cachewritem1),
    .slot_state_cp15resp_o                 (slot4_state_cp15resp),
    .slot_state_cleanunique_req_o          (slot4_state_cleanunique_req),
    .slot_state_cleanunique_ack_o          (slot4_state_cleanunique_ack),
    .slot_state_cleanunique_resp_o         (slot4_state_cleanunique_resp),
    .slot_state_barrier_ack_o              (slot4_state_barrier_ack),
    .slot_write_sync_cmo_ack_o             (slot4_write_sync_cmo_ack),
    .slot_attrs_o                          (slot4_attrs[7:0]),
    .slot_addr_o                           (slot4_addr[39:0]),
    .slot_ns_o                             (slot4_ns),
    .slot_data_o                           (slot4_data[127:0]),
    .slot_cache_bls_o                      (slot4_cache_bls[15:0]),
    .slot_write_data_o                     (slot4_write_data[127:0]),
    .slot_write_bls_o                      (slot4_write_bls[15:0]),
    .slot_write_chunk_o                    (slot4_write_chunk[1:0]),
    .slot_write_last_o                     (slot4_write_last),
    .slot_mergeable_o                      (slot4_mergeable),
    .slot_barriered_o                      (slot4_barriered),
    .slot_earlier_o                        (slot4_earlier[3:0]),
    .slot_earlier_lf_o                     (slot4_earlier_lf[3:0]),
    .slot_cp15_o                           (slot4_cp15),
    .slot_dsb_o                            (slot4_dsb),
    .slot_way_onehot_o                     (slot4_way_onehot[3:0]),
    .slot_way_o                            (slot4_way[1:0]),
    .slot_migratory_o                      (slot4_migratory),
    .slot_ar_way_o                         (slot4_ar_way[1:0]),
    .slot_lf_hz_seen_o                     (slot4_lf_hz_seen),
    .slot_lf_hz_capture_o                  (slot4_lf_hz_capture),
    .slot_coherent_o                       (slot4_coherent),
    .slot_l2dbid_o                         (slot4_l2dbid[3:0]),
    .slot_no_alloc_on_miss_o               (slot4_no_alloc_on_miss),
    .slot_more_dev_expected_o              (slot4_more_dev_expected),
    .slot_sameline_beat_count_o            (slot4_sameline_beat_count[2:0]),
    .slot_has_cleanunique_duty_o           (slot4_has_cleanunique_duty),
    .slot_load_sameline_seen_o             (slot4_load_sameline_seen),
    .slot_load_sameline_o                  (slot4_load_sameline),
    .slot_can_merge_dc2_o                  (slot4_can_merge_dc2),
    .slot_sameline_dc2_o                   (slot4_sameline_dc2),
    .slot_load_sameline_dc2_o              (slot4_load_sameline_dc2),
    .slot_attr_mismatch_dc2_o              (slot4_attr_mismatch_dc2),
    .slot_hit_dc2_o                        (slot4_hit_dc2[15:0]),
    .slot_wants_write_data_priority_o      (slot4_wants_write_data_priority),
    .slot_has_write_data_priority_o        (slot4_has_write_data_priority),
    .slot_write_data_suppress_o            (slot4_write_data_suppress),
    .slot_write_accept_o                   (slot4_write_accept),
    .slot_lf_active_o                      (slot4_lf_active),
    .slot_lf_req_o                         (slot4_lf_req),
    .slot_lf_merge_o                       (slot4_lf_merge),
    .slot_ev_hazard_o                      (slot4_ev_hazard),
    .slot_ev_hz_seen_o                     (slot4_ev_hz_seen),
    .slot_wants_ar_priority_o              (slot4_wants_ar_priority),
    .slot_might_want_ar_priority_o         (slot4_might_want_ar_priority),
    .slot_already_has_ar_priority_o        (slot4_already_has_ar_priority),
    .slot_ar_suppress_o                    (slot4_ar_suppress),
    .slot_ar_addr_o                        (slot4_ar_addr[39:0]),
    .slot_ar_ns_o                          (slot4_ar_ns),
    .slot_ar_priv_o                        (slot4_ar_priv),
    .slot_ar_excl_o                        (slot4_ar_excl),
    .slot_cp15_asid_o                      (slot4_cp15_asid[15:0]),
    .slot_cp15_vmid_o                      (slot4_cp15_vmid[7:0]),
    .slot_cp15_va_o                        (slot4_cp15_va[24:0]),
    .slot_wants_lookup_priority_o          (slot4_wants_lookup_priority),
    .slot_might_want_cache_data_priority_o (slot4_might_want_cache_data_priority),
    .slot_wants_cache_data_priority_o      (slot4_wants_cache_data_priority),
    .slot_wants_tagwrite_priority_o        (slot4_wants_tagwrite_priority),
    .slot_wants_write_addr_priority_o      (slot4_wants_write_addr_priority),
    .slot_wants_cleanunique_priority_o     (slot4_wants_cleanunique_priority),
    .slot_biu_write_req_active_o           (slot4_biu_write_req_active),
    .slot_block_ccb_o                      (slot4_block_ccb),
    .slot_block_loads_dc1_o                (slot4_block_loads_dc1),
    .slot_excl_fail_o                      (slot4_excl_fail),
    .slot_excl_done_o                      (slot4_excl_done),
    .slot_type_o                           (slot4_type[7:0]),
    .slot_might_req_o                      (slot4_might_req),
    .slot_force_non_mergeable_o            (slot4_force_non_mergeable)
  );  // u_slot4


  //----------------------------------------------------------------------------
  // OVLs
  //----------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  wire [3:0]  ovl_slot0_sameline = u_slot0.slot_sameline;
  wire [3:0]  ovl_slot1_sameline = u_slot1.slot_sameline;
  wire [3:0]  ovl_slot2_sameline = u_slot2.slot_sameline;
  wire [3:0]  ovl_slot3_sameline = u_slot3.slot_sameline;
  wire [3:0]  ovl_slot4_sameline = u_slot4.slot_sameline;

  wire [3:0]  ovl_slot0_same_dev_write = u_slot0.slot_same_dev_write;
  wire [3:0]  ovl_slot1_same_dev_write = u_slot1.slot_same_dev_write;
  wire [3:0]  ovl_slot2_same_dev_write = u_slot2.slot_same_dev_write;
  wire [3:0]  ovl_slot3_same_dev_write = u_slot3.slot_same_dev_write;
  wire [3:0]  ovl_slot4_same_dev_write = u_slot4.slot_same_dev_write;

  wire [3:0]  ovl_slot0_sameburst = u_slot0.slot_sameline | u_slot0.slot_same_dev_write;
  wire [3:0]  ovl_slot1_sameburst = u_slot1.slot_sameline | u_slot1.slot_same_dev_write;
  wire [3:0]  ovl_slot2_sameburst = u_slot2.slot_sameline | u_slot2.slot_same_dev_write;
  wire [3:0]  ovl_slot3_sameburst = u_slot3.slot_sameline | u_slot3.slot_same_dev_write;
  wire [3:0]  ovl_slot4_sameburst = u_slot4.slot_sameline | u_slot4.slot_same_dev_write;

  assert_zero_one_hot #(`OVL_FATAL, 5, `OVL_ASSERT, "Only one slot can be assigned to a new request")
  u_ovl_new_req_dc3 (.clk       (clk),
                     .reset_n   (reset_n),
                     .test_expr ({slot0_new_req_dc3,
                                  slot1_new_req_dc3,
                                  slot2_new_req_dc3,
                                  slot3_new_req_dc3,
                                  slot4_new_req_dc3}));

  assert_zero_one_hot #(`OVL_FATAL, 5, `OVL_ASSERT, "Only one slot can be selected for cache priority")
  u_ovl_cache_slot_select (.clk       (clk),
                           .reset_n   (reset_n),
                           .test_expr (cache_data_slot_select));

  assert_zero_one_hot #(`OVL_FATAL, 5, `OVL_ASSERT, "Only one slot is in CACHEWRITEM1")
  u_ovl_cachewritem1 (.clk       (clk),
                      .reset_n   (reset_n),
                      .test_expr ({slot0_state_cachewritem1,
                                   slot1_state_cachewritem1,
                                   slot2_state_cachewritem1,
                                   slot3_state_cachewritem1,
                                   slot4_state_cachewritem1}));

  assert_zero_one_hot #(`OVL_FATAL, 5, `OVL_ASSERT, "More than one slot marked as lowest IDLE")
  u_ovl_lowest_idle_slot (.clk       (clk),
                          .reset_n   (reset_n),
                          .test_expr (slots_lowest_idle));

  assert_zero_one_hot #(`OVL_FATAL, 5, `OVL_ASSERT, "More than one slot has BIU AR priority")
  u_ovl_biu_ar_pri (.clk       (clk),
                     .reset_n   (reset_n),
                     .test_expr ({slot0_has_ar_priority,
                                  slot1_has_ar_priority,
                                  slot2_has_ar_priority,
                                  slot3_has_ar_priority,
                                  slot4_has_ar_priority}));

  assert_zero_one_hot #(`OVL_FATAL, 5, `OVL_ASSERT, "More than one slot has BIU data priority")
  u_ovl_biu_data_pri (.clk       (clk),
                      .reset_n   (reset_n),
                      .test_expr ({slot0_has_write_data_priority,
                                   slot1_has_write_data_priority,
                                   slot2_has_write_data_priority,
                                   slot3_has_write_data_priority,
                                   slot4_has_write_data_priority}));

  wire ovl_stb_biu_write_exclusive = ((slot0_has_write_data_priority & slot0_ar_excl) |
                                      (slot1_has_write_data_priority & slot1_ar_excl) |
                                      (slot2_has_write_data_priority & slot2_ar_excl) |
                                      (slot3_has_write_data_priority & slot3_ar_excl) |
                                      (slot4_has_write_data_priority & slot4_ar_excl));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Exclusive writes must be marked as last")
  u_ovl_biu_excl_last (.clk       (clk),
                       .reset_n   (reset_n),
                       .antecedent_expr (ovl_stb_biu_write_exclusive),
                       .consequent_expr (stb_biu_write_last_o));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Sameline bits must be consistent between slots")
  u_ovl_sameline_consistent0 (.clk (clk),
                              .reset_n (reset_n),
                              .antecedent_expr (slot0_valid),
                              .consequent_expr (ovl_slot0_sameline == {slot4_valid & ovl_slot4_sameline[0],
                                                                       slot3_valid & ovl_slot3_sameline[0],
                                                                       slot2_valid & ovl_slot2_sameline[0],
                                                                       slot1_valid & ovl_slot1_sameline[0]}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Sameline bits must be consistent between slots")
  u_ovl_sameline_consistent1 (.clk (clk),
                              .reset_n (reset_n),
                              .antecedent_expr (slot1_valid),
                              .consequent_expr (ovl_slot1_sameline == {slot4_valid & ovl_slot4_sameline[1],
                                                                       slot3_valid & ovl_slot3_sameline[1],
                                                                       slot2_valid & ovl_slot2_sameline[1],
                                                                       slot0_valid & ovl_slot0_sameline[0]}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Sameline bits must be consistent between slots")
  u_ovl_sameline_consistent2 (.clk (clk),
                              .reset_n (reset_n),
                              .antecedent_expr (slot2_valid),
                              .consequent_expr (ovl_slot2_sameline == {slot4_valid & ovl_slot4_sameline[2],
                                                                       slot3_valid & ovl_slot3_sameline[2],
                                                                       slot1_valid & ovl_slot1_sameline[1],
                                                                       slot0_valid & ovl_slot0_sameline[1]}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Sameline bits must be consistent between slots")
  u_ovl_sameline_consistent3 (.clk (clk),
                              .reset_n (reset_n),
                              .antecedent_expr (slot3_valid),
                              .consequent_expr (ovl_slot3_sameline == {slot4_valid & ovl_slot4_sameline[3],
                                                                       slot2_valid & ovl_slot2_sameline[2],
                                                                       slot1_valid & ovl_slot1_sameline[2],
                                                                       slot0_valid & ovl_slot0_sameline[2]}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Sameline bits must be consistent between slots")
  u_ovl_sameline_consistent4 (.clk (clk),
                              .reset_n (reset_n),
                              .antecedent_expr (slot4_valid),
                              .consequent_expr (ovl_slot4_sameline == {slot3_valid & ovl_slot3_sameline[3],
                                                                       slot2_valid & ovl_slot2_sameline[3],
                                                                       slot1_valid & ovl_slot1_sameline[3],
                                                                       slot0_valid & ovl_slot0_sameline[3]}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Same_dev_write bits must be consistent between slots")
  u_ovl_same_dev_write_consistent0 (.clk (clk),
                                    .reset_n (reset_n),
                                    .antecedent_expr (slot0_valid),
                                    .consequent_expr (ovl_slot0_same_dev_write == {slot4_valid & ovl_slot4_same_dev_write[0],
                                                                                   slot3_valid & ovl_slot3_same_dev_write[0],
                                                                                   slot2_valid & ovl_slot2_same_dev_write[0],
                                                                                   slot1_valid & ovl_slot1_same_dev_write[0]}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Same_dev_write bits must be consistent between slots")
  u_ovl_same_dev_write_consistent1 (.clk (clk),
                                    .reset_n (reset_n),
                                    .antecedent_expr (slot1_valid),
                                    .consequent_expr (ovl_slot1_same_dev_write == {slot4_valid & ovl_slot4_same_dev_write[1],
                                                                                   slot3_valid & ovl_slot3_same_dev_write[1],
                                                                                   slot2_valid & ovl_slot2_same_dev_write[1],
                                                                                   slot0_valid & ovl_slot0_same_dev_write[0]}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Same_dev_write bits must be consistent between slots")
  u_ovl_same_dev_write_consistent2 (.clk (clk),
                                    .reset_n (reset_n),
                                    .antecedent_expr (slot2_valid),
                                    .consequent_expr (ovl_slot2_same_dev_write == {slot4_valid & ovl_slot4_same_dev_write[2],
                                                                                   slot3_valid & ovl_slot3_same_dev_write[2],
                                                                                   slot1_valid & ovl_slot1_same_dev_write[1],
                                                                                   slot0_valid & ovl_slot0_same_dev_write[1]}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Same_dev_write bits must be consistent between slots")
  u_ovl_same_dev_write_consistent3 (.clk (clk),
                                    .reset_n (reset_n),
                                    .antecedent_expr (slot3_valid),
                                    .consequent_expr (ovl_slot3_same_dev_write == {slot4_valid & ovl_slot4_same_dev_write[3],
                                                                                   slot2_valid & ovl_slot2_same_dev_write[2],
                                                                                   slot1_valid & ovl_slot1_same_dev_write[2],
                                                                                   slot0_valid & ovl_slot0_same_dev_write[2]}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Same_dev_write bits must be consistent between slots")
  u_ovl_same_dev_write_consistent4 (.clk (clk),
                                    .reset_n (reset_n),
                                    .antecedent_expr (slot4_valid),
                                    .consequent_expr (ovl_slot4_same_dev_write == {slot3_valid & ovl_slot3_same_dev_write[3],
                                                                                   slot2_valid & ovl_slot2_same_dev_write[3],
                                                                                   slot1_valid & ovl_slot1_same_dev_write[3],
                                                                                   slot0_valid & ovl_slot0_same_dev_write[3]}));

  assert_zero_one_hot #(`OVL_FATAL, 10, `OVL_ASSERT, "More than one slot has cache tag priority")
  u_ovl_tag_pri (.clk       (clk),
                 .reset_n   (reset_n),
                 .test_expr ({slot4_has_tagwrite_priority,
                              slot3_has_tagwrite_priority,
                              slot2_has_tagwrite_priority,
                              slot1_has_tagwrite_priority,
                              slot0_has_tagwrite_priority,
                              slot4_has_lookup_priority,
                              slot3_has_lookup_priority,
                              slot2_has_lookup_priority,
                              slot1_has_lookup_priority,
                              slot0_has_lookup_priority}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm1 must be in the same line")
  u_ovl_lookupm1_sameline0 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot0_state_lookupm1 & slot1_state_lookupm1),
                            .consequent_expr (ovl_slot0_sameline[0] & ovl_slot1_sameline[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm1 must be in the same line")
  u_ovl_lookupm1_sameline1 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot0_state_lookupm1 & slot2_state_lookupm1),
                            .consequent_expr (ovl_slot0_sameline[1] & ovl_slot2_sameline[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm1 must be in the same line")
  u_ovl_lookupm1_sameline2 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot0_state_lookupm1 & slot3_state_lookupm1),
                            .consequent_expr (ovl_slot0_sameline[2] & ovl_slot3_sameline[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm1 must be in the same line")
  u_ovl_lookupm1_sameline3 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot0_state_lookupm1 & slot4_state_lookupm1),
                            .consequent_expr (ovl_slot0_sameline[3] & ovl_slot4_sameline[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm1 must be in the same line")
  u_ovl_lookupm1_sameline4 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot1_state_lookupm1 & slot2_state_lookupm1),
                            .consequent_expr (ovl_slot1_sameline[1] & ovl_slot2_sameline[1]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm1 must be in the same line")
  u_ovl_lookupm1_sameline5 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot1_state_lookupm1 & slot3_state_lookupm1),
                            .consequent_expr (ovl_slot1_sameline[2] & ovl_slot3_sameline[1]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm1 must be in the same line")
  u_ovl_lookupm1_sameline6 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot1_state_lookupm1 & slot4_state_lookupm1),
                            .consequent_expr (ovl_slot1_sameline[3] & ovl_slot4_sameline[1]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm1 must be in the same line")
  u_ovl_lookupm1_sameline7 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot2_state_lookupm1 & slot3_state_lookupm1),
                            .consequent_expr (ovl_slot2_sameline[2] & ovl_slot3_sameline[2]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm1 must be in the same line")
  u_ovl_lookupm1_sameline8 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot2_state_lookupm1 & slot4_state_lookupm1),
                            .consequent_expr (ovl_slot2_sameline[3] & ovl_slot4_sameline[2]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm1 must be in the same line")
  u_ovl_lookupm1_sameline9 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot3_state_lookupm1 & slot4_state_lookupm1),
                            .consequent_expr (ovl_slot3_sameline[3] & ovl_slot4_sameline[3]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm2 must be in the same line")
  u_ovl_lookupm2_sameline0 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot0_state_lookupm2 & slot1_state_lookupm2),
                            .consequent_expr (ovl_slot0_sameline[0] & ovl_slot1_sameline[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm2 must be in the same line")
  u_ovl_lookupm2_sameline1 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot0_state_lookupm2 & slot2_state_lookupm2),
                            .consequent_expr (ovl_slot0_sameline[1] & ovl_slot2_sameline[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm2 must be in the same line")
  u_ovl_lookupm2_sameline2 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot0_state_lookupm2 & slot3_state_lookupm2),
                            .consequent_expr (ovl_slot0_sameline[2] & ovl_slot3_sameline[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm2 must be in the same line")
  u_ovl_lookupm2_sameline3 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot0_state_lookupm2 & slot4_state_lookupm2),
                            .consequent_expr (ovl_slot0_sameline[3] & ovl_slot4_sameline[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm2 must be in the same line")
  u_ovl_lookupm2_sameline4 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot1_state_lookupm2 & slot2_state_lookupm2),
                            .consequent_expr (ovl_slot1_sameline[1] & ovl_slot2_sameline[1]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm2 must be in the same line")
  u_ovl_lookupm2_sameline5 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot1_state_lookupm2 & slot3_state_lookupm2),
                            .consequent_expr (ovl_slot1_sameline[2] & ovl_slot3_sameline[1]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm2 must be in the same line")
  u_ovl_lookupm2_sameline6 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot1_state_lookupm2 & slot4_state_lookupm2),
                            .consequent_expr (ovl_slot1_sameline[3] & ovl_slot4_sameline[1]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm2 must be in the same line")
  u_ovl_lookupm2_sameline7 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot2_state_lookupm2 & slot3_state_lookupm2),
                            .consequent_expr (ovl_slot2_sameline[2] & ovl_slot3_sameline[2]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm2 must be in the same line")
  u_ovl_lookupm2_sameline8 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot2_state_lookupm2 & slot4_state_lookupm2),
                            .consequent_expr (ovl_slot2_sameline[3] & ovl_slot4_sameline[2]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in lookupm2 must be in the same line")
  u_ovl_lookupm2_sameline9 (.clk (clk),
                            .reset_n (reset_n),
                            .antecedent_expr (slot3_state_lookupm2 & slot4_state_lookupm2),
                            .consequent_expr (ovl_slot3_sameline[3] & ovl_slot4_sameline[3]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in cleanunique_ack must be in the same line")
  u_ovl_cleanunique_ack_sameline0 (.clk (clk),
                                   .reset_n (reset_n),
                                   .antecedent_expr (slot0_state_cleanunique_ack & slot1_state_cleanunique_ack),
                                   .consequent_expr (ovl_slot0_sameline[0] & ovl_slot1_sameline[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in cleanunique_ack must be in the same line")
  u_ovl_cleanunique_ack_sameline1 (.clk (clk),
                                   .reset_n (reset_n),
                                   .antecedent_expr (slot0_state_cleanunique_ack & slot2_state_cleanunique_ack),
                                   .consequent_expr (ovl_slot0_sameline[1] & ovl_slot2_sameline[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in cleanunique_ack must be in the same line")
  u_ovl_cleanunique_ack_sameline2 (.clk (clk),
                                   .reset_n (reset_n),
                                   .antecedent_expr (slot0_state_cleanunique_ack & slot3_state_cleanunique_ack),
                                   .consequent_expr (ovl_slot0_sameline[2] & ovl_slot3_sameline[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in cleanunique_ack must be in the same line")
  u_ovl_cleanunique_ack_sameline3 (.clk (clk),
                                   .reset_n (reset_n),
                                   .antecedent_expr (slot0_state_cleanunique_ack & slot4_state_cleanunique_ack),
                                   .consequent_expr (ovl_slot0_sameline[3] & ovl_slot4_sameline[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in cleanunique_ack must be in the same line")
  u_ovl_cleanunique_ack_sameline4 (.clk (clk),
                                   .reset_n (reset_n),
                                   .antecedent_expr (slot1_state_cleanunique_ack & slot2_state_cleanunique_ack),
                                   .consequent_expr (ovl_slot1_sameline[1] & ovl_slot2_sameline[1]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in cleanunique_ack must be in the same line")
  u_ovl_cleanunique_ack_sameline5 (.clk (clk),
                                   .reset_n (reset_n),
                                   .antecedent_expr (slot1_state_cleanunique_ack & slot3_state_cleanunique_ack),
                                   .consequent_expr (ovl_slot1_sameline[2] & ovl_slot3_sameline[1]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in cleanunique_ack must be in the same line")
  u_ovl_cleanunique_ack_sameline6 (.clk (clk),
                                   .reset_n (reset_n),
                                   .antecedent_expr (slot1_state_cleanunique_ack & slot4_state_cleanunique_ack),
                                   .consequent_expr (ovl_slot1_sameline[3] & ovl_slot4_sameline[1]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in cleanunique_ack must be in the same line")
  u_ovl_cleanunique_ack_sameline7 (.clk (clk),
                                   .reset_n (reset_n),
                                   .antecedent_expr (slot2_state_cleanunique_ack & slot3_state_cleanunique_ack),
                                   .consequent_expr (ovl_slot2_sameline[2] & ovl_slot3_sameline[2]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in cleanunique_ack must be in the same line")
  u_ovl_cleanunique_ack_sameline8 (.clk (clk),
                                   .reset_n (reset_n),
                                   .antecedent_expr (slot2_state_cleanunique_ack & slot4_state_cleanunique_ack),
                                   .consequent_expr (ovl_slot2_sameline[3] & ovl_slot4_sameline[2]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots both in cleanunique_ack must be in the same line")
  u_ovl_cleanunique_ack_sameline9 (.clk (clk),
                                   .reset_n (reset_n),
                                   .antecedent_expr (slot3_state_cleanunique_ack & slot4_state_cleanunique_ack),
                                   .consequent_expr (ovl_slot3_sameline[3] & ovl_slot4_sameline[3]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_addr0 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot0_valid & ovl_slot0_sameburst[0]),
                         .consequent_expr (slot0_addr[39:6] == slot1_addr[39:6]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_addr1 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot0_valid & ovl_slot0_sameburst[1]),
                         .consequent_expr (slot0_addr[39:6] == slot2_addr[39:6]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_addr2 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot0_valid & ovl_slot0_sameburst[2]),
                         .consequent_expr (slot0_addr[39:6] == slot3_addr[39:6]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_addr3 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot0_valid & ovl_slot0_sameburst[3]),
                         .consequent_expr (slot0_addr[39:6] == slot4_addr[39:6]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_addr4 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot1_valid & ovl_slot1_sameburst[1]),
                         .consequent_expr (slot1_addr[39:6] == slot2_addr[39:6]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_addr5 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot1_valid & ovl_slot1_sameburst[2]),
                         .consequent_expr (slot1_addr[39:6] == slot3_addr[39:6]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_addr6 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot1_valid & ovl_slot1_sameburst[3]),
                         .consequent_expr (slot1_addr[39:6] == slot4_addr[39:6]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_addr7 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot2_valid & ovl_slot2_sameburst[2]),
                         .consequent_expr (slot2_addr[39:6] == slot3_addr[39:6]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_addr8 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot2_valid & ovl_slot2_sameburst[3]),
                         .consequent_expr (slot2_addr[39:6] == slot4_addr[39:6]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_addr9 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot3_valid & ovl_slot3_sameburst[3]),
                         .consequent_expr (slot3_addr[39:6] == slot4_addr[39:6]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_ns0 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (slot0_valid & ovl_slot0_sameburst[0]),
                       .consequent_expr (slot0_ns == slot1_ns));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_ns1 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (slot0_valid & ovl_slot0_sameburst[1]),
                       .consequent_expr (slot0_ns == slot2_ns));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_ns2 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (slot0_valid & ovl_slot0_sameburst[2]),
                       .consequent_expr (slot0_ns == slot3_ns));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_ns3 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (slot0_valid & ovl_slot0_sameburst[3]),
                       .consequent_expr (slot0_ns == slot4_ns));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_ns4 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (slot1_valid & ovl_slot1_sameburst[1]),
                       .consequent_expr (slot1_ns == slot2_ns));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_ns5 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (slot1_valid & ovl_slot1_sameburst[2]),
                       .consequent_expr (slot1_ns == slot3_ns));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_ns6 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (slot1_valid & ovl_slot1_sameburst[3]),
                       .consequent_expr (slot1_ns == slot4_ns));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_ns7 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (slot2_valid & ovl_slot2_sameburst[2]),
                       .consequent_expr (slot2_ns == slot3_ns));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_ns8 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (slot2_valid & ovl_slot2_sameburst[3]),
                       .consequent_expr (slot2_ns == slot4_ns));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching addresses")
  u_ovl_sameburst_ns9 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (slot3_valid & ovl_slot3_sameburst[3]),
                       .consequent_expr (slot3_ns == slot4_ns));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching attributes")
  u_ovl_sameburst_attr0 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot0_valid & ovl_slot0_sameburst[0]),
                         .consequent_expr (slot0_attrs == slot1_attrs));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching attributes")
  u_ovl_sameburst_attr1 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot0_valid & ovl_slot0_sameburst[1]),
                         .consequent_expr (slot0_attrs == slot2_attrs));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching attributes")
  u_ovl_sameburst_attr2 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot0_valid & ovl_slot0_sameburst[2]),
                         .consequent_expr (slot0_attrs == slot3_attrs));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching attributes")
  u_ovl_sameburst_attr3 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot0_valid & ovl_slot0_sameburst[3]),
                         .consequent_expr (slot0_attrs == slot4_attrs));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching attributes")
  u_ovl_sameburst_attr4 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot1_valid & ovl_slot1_sameburst[1]),
                         .consequent_expr (slot1_attrs == slot2_attrs));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching attributes")
  u_ovl_sameburst_attr5 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot1_valid & ovl_slot1_sameburst[2]),
                         .consequent_expr (slot1_attrs == slot3_attrs));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching attributes")
  u_ovl_sameburst_attr6 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot1_valid & ovl_slot1_sameburst[3]),
                         .consequent_expr (slot1_attrs == slot4_attrs));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching attributes")
  u_ovl_sameburst_attr7 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot2_valid & ovl_slot2_sameburst[2]),
                         .consequent_expr (slot2_attrs == slot3_attrs));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching attributes")
  u_ovl_sameburst_attr8 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot2_valid & ovl_slot2_sameburst[3]),
                         .consequent_expr (slot2_attrs == slot4_attrs));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst must have matching attributes")
  u_ovl_sameburst_attr9 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot3_valid & ovl_slot3_sameburst[3]),
                         .consequent_expr (slot3_attrs == slot4_attrs));


  wire ovl_slot0_state_hit = (slot0_state_cleanunique_req |
                              slot0_state_cleanunique_ack |
                              slot0_state_cleanunique_resp |
                              slot0_state_tagwrite |
                              slot0_state_cachemerge |
                              slot0_state_cachereadm0 |
                              slot0_state_cachereadm1 |
                              slot0_state_cachereadm2 |
                              slot0_state_cacheecc |
                              slot0_state_cachewritereq |
                              slot0_state_cachewritem1);

  wire ovl_slot1_state_hit = (slot1_state_cleanunique_req |
                              slot1_state_cleanunique_ack |
                              slot1_state_cleanunique_resp |
                              slot1_state_tagwrite |
                              slot1_state_cachemerge |
                              slot1_state_cachereadm0 |
                              slot1_state_cachereadm1 |
                              slot1_state_cachereadm2 |
                              slot1_state_cacheecc |
                              slot1_state_cachewritereq |
                              slot1_state_cachewritem1);

  wire ovl_slot2_state_hit = (slot2_state_cleanunique_req |
                              slot2_state_cleanunique_ack |
                              slot2_state_cleanunique_resp |
                              slot2_state_tagwrite |
                              slot2_state_cachemerge |
                              slot2_state_cachereadm0 |
                              slot2_state_cachereadm1 |
                              slot2_state_cachereadm2 |
                              slot2_state_cacheecc |
                              slot2_state_cachewritereq |
                              slot2_state_cachewritem1);

  wire ovl_slot3_state_hit = (slot3_state_cleanunique_req |
                              slot3_state_cleanunique_ack |
                              slot3_state_cleanunique_resp |
                              slot3_state_tagwrite |
                              slot3_state_cachemerge |
                              slot3_state_cachereadm0 |
                              slot3_state_cachereadm1 |
                              slot3_state_cachereadm2 |
                              slot3_state_cacheecc |
                              slot3_state_cachewritereq |
                              slot3_state_cachewritem1);

  wire ovl_slot4_state_hit = (slot4_state_cleanunique_req |
                              slot4_state_cleanunique_ack |
                              slot4_state_cleanunique_resp |
                              slot4_state_tagwrite |
                              slot4_state_cachemerge |
                              slot4_state_cachereadm0 |
                              slot4_state_cachereadm1 |
                              slot4_state_cachereadm2 |
                              slot4_state_cacheecc |
                              slot4_state_cachewritereq |
                              slot4_state_cachewritem1);

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same way")
  u_ovl_sameline_way0 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (ovl_slot0_state_hit & ovl_slot0_sameline[0] & ovl_slot1_state_hit),
                       .consequent_expr (slot0_way == slot1_way));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same way")
  u_ovl_sameline_way1 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (ovl_slot0_state_hit & ovl_slot0_sameline[1] & ovl_slot2_state_hit),
                       .consequent_expr (slot0_way == slot2_way));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same way")
  u_ovl_sameline_way2 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (ovl_slot0_state_hit & ovl_slot0_sameline[2] & ovl_slot3_state_hit),
                       .consequent_expr (slot0_way == slot3_way));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same way")
  u_ovl_sameline_way3 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (ovl_slot0_state_hit & ovl_slot0_sameline[3] & ovl_slot4_state_hit),
                       .consequent_expr (slot0_way == slot4_way));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same way")
  u_ovl_sameline_way4 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (ovl_slot1_state_hit & ovl_slot1_sameline[1] & ovl_slot2_state_hit),
                       .consequent_expr (slot1_way == slot2_way));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same way")
  u_ovl_sameline_way5 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (ovl_slot1_state_hit & ovl_slot1_sameline[2] & ovl_slot3_state_hit),
                       .consequent_expr (slot1_way == slot3_way));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same way")
  u_ovl_sameline_way6 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (ovl_slot1_state_hit & ovl_slot1_sameline[3] & ovl_slot4_state_hit),
                       .consequent_expr (slot1_way == slot4_way));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same way")
  u_ovl_sameline_way7 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (ovl_slot2_state_hit & ovl_slot2_sameline[2] & ovl_slot3_state_hit),
                       .consequent_expr (slot2_way == slot3_way));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same way")
  u_ovl_sameline_way8 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (ovl_slot2_state_hit & ovl_slot2_sameline[3] & ovl_slot4_state_hit),
                       .consequent_expr (slot2_way == slot4_way));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same way")
  u_ovl_sameline_way9 (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (ovl_slot3_state_hit & ovl_slot3_sameline[3] & ovl_slot4_state_hit),
                       .consequent_expr (slot3_way == slot4_way));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same migratory information")
  u_ovl_sameline_migratory0 (.clk (clk),
                             .reset_n (reset_n),
                             .antecedent_expr (ovl_slot0_state_hit & ovl_slot0_sameline[0] & ovl_slot1_state_hit),
                             .consequent_expr (slot0_migratory == slot1_migratory));
  
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same migratory information")
  u_ovl_sameline_migratory1 (.clk (clk),
                             .reset_n (reset_n),
                             .antecedent_expr (ovl_slot0_state_hit & ovl_slot0_sameline[1] & ovl_slot2_state_hit),
                             .consequent_expr (slot0_migratory == slot2_migratory));
  
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same migratory information")
  u_ovl_sameline_migratory2 (.clk (clk),
                             .reset_n (reset_n),
                             .antecedent_expr (ovl_slot0_state_hit & ovl_slot0_sameline[2] & ovl_slot3_state_hit),
                             .consequent_expr (slot0_migratory == slot3_migratory));
  
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same migratory information")
  u_ovl_sameline_migratory3 (.clk (clk),
                             .reset_n (reset_n),
                             .antecedent_expr (ovl_slot0_state_hit & ovl_slot0_sameline[3] & ovl_slot4_state_hit),
                             .consequent_expr (slot0_migratory == slot4_migratory));
  
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same migratory information")
  u_ovl_sameline_migratory4 (.clk (clk),
                             .reset_n (reset_n),
                             .antecedent_expr (ovl_slot1_state_hit & ovl_slot1_sameline[1] & ovl_slot2_state_hit),
                             .consequent_expr (slot1_migratory == slot2_migratory));
  
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same migratory information")
  u_ovl_sameline_migratory5 (.clk (clk),
                             .reset_n (reset_n),
                             .antecedent_expr (ovl_slot1_state_hit & ovl_slot1_sameline[2] & ovl_slot3_state_hit),
                             .consequent_expr (slot1_migratory == slot3_migratory));
  
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same migratory information")
  u_ovl_sameline_migratory6 (.clk (clk),
                             .reset_n (reset_n),
                             .antecedent_expr (ovl_slot1_state_hit & ovl_slot1_sameline[3] & ovl_slot4_state_hit),
                             .consequent_expr (slot1_migratory == slot4_migratory));
  
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same migratory information")
  u_ovl_sameline_migratory7 (.clk (clk),
                             .reset_n (reset_n),
                             .antecedent_expr (ovl_slot2_state_hit & ovl_slot2_sameline[2] & ovl_slot3_state_hit),
                             .consequent_expr (slot2_migratory == slot3_migratory));
  
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same migratory information")
  u_ovl_sameline_migratory8 (.clk (clk),
                             .reset_n (reset_n),
                             .antecedent_expr (ovl_slot2_state_hit & ovl_slot2_sameline[3] & ovl_slot4_state_hit),
                             .consequent_expr (slot2_migratory == slot4_migratory));
  
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline that hit must have hit the same migratory information")
  u_ovl_sameline_migratory9 (.clk (clk),
                             .reset_n (reset_n),
                             .antecedent_expr (ovl_slot3_state_hit & ovl_slot3_sameline[3] & ovl_slot4_state_hit),
                             .consequent_expr (slot3_migratory == slot4_migratory));

  wire ovl_slot0_state_biu = (slot0_state_biumerge |
                              slot0_state_biureq |
                              slot0_state_biuack |
                              slot0_state_biuresp |
                              slot0_state_biudata);

  wire ovl_slot1_state_biu = (slot1_state_biumerge |
                              slot1_state_biureq |
                              slot1_state_biuack |
                              slot1_state_biuresp |
                              slot1_state_biudata);

  wire ovl_slot2_state_biu = (slot2_state_biumerge |
                              slot2_state_biureq |
                              slot2_state_biuack |
                              slot2_state_biuresp |
                              slot2_state_biudata);

  wire ovl_slot3_state_biu = (slot3_state_biumerge |
                              slot3_state_biureq |
                              slot3_state_biuack |
                              slot3_state_biuresp |
                              slot3_state_biudata);

  wire ovl_slot4_state_biu = (slot4_state_biumerge |
                              slot4_state_biureq |
                              slot4_state_biuack |
                              slot4_state_biuresp |
                              slot4_state_biudata);

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss0 (.clk (clk),
                        .reset_n (reset_n),
                        .antecedent_expr (ovl_slot0_state_biu & ovl_slot0_sameline[0]),
                        .consequent_expr (~ovl_slot1_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss1 (.clk (clk),
                        .reset_n (reset_n),
                        .antecedent_expr (ovl_slot0_state_biu & ovl_slot0_sameline[1]),
                        .consequent_expr (~ovl_slot2_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss2 (.clk (clk),
                        .reset_n (reset_n),
                        .antecedent_expr (ovl_slot0_state_biu & ovl_slot0_sameline[2]),
                        .consequent_expr (~ovl_slot3_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss3 (.clk (clk),
                        .reset_n (reset_n),
                        .antecedent_expr (ovl_slot0_state_biu & ovl_slot0_sameline[3]),
                        .consequent_expr (~ovl_slot4_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss4 (.clk (clk),
                        .reset_n (reset_n),
                        .antecedent_expr (ovl_slot1_state_biu & ovl_slot1_sameline[0]),
                        .consequent_expr (~ovl_slot0_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss5 (.clk (clk),
                        .reset_n (reset_n),
                        .antecedent_expr (ovl_slot1_state_biu & ovl_slot1_sameline[1]),
                        .consequent_expr (~ovl_slot2_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss6 (.clk (clk),
                        .reset_n (reset_n),
                        .antecedent_expr (ovl_slot1_state_biu & ovl_slot1_sameline[2]),
                        .consequent_expr (~ovl_slot3_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss7 (.clk (clk),
                        .reset_n (reset_n),
                        .antecedent_expr (ovl_slot1_state_biu & ovl_slot1_sameline[3]),
                        .consequent_expr (~ovl_slot4_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss8 (.clk (clk),
                        .reset_n (reset_n),
                        .antecedent_expr (ovl_slot2_state_biu & ovl_slot2_sameline[0]),
                        .consequent_expr (~ovl_slot0_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss9 (.clk (clk),
                        .reset_n (reset_n),
                        .antecedent_expr (ovl_slot2_state_biu & ovl_slot2_sameline[1]),
                        .consequent_expr (~ovl_slot1_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss10 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (ovl_slot2_state_biu & ovl_slot2_sameline[2]),
                         .consequent_expr (~ovl_slot3_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss11 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (ovl_slot2_state_biu & ovl_slot2_sameline[3]),
                         .consequent_expr (~ovl_slot4_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss12 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (ovl_slot3_state_biu & ovl_slot3_sameline[0]),
                         .consequent_expr (~ovl_slot0_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss13 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (ovl_slot3_state_biu & ovl_slot3_sameline[1]),
                         .consequent_expr (~ovl_slot1_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss14 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (ovl_slot3_state_biu & ovl_slot3_sameline[2]),
                         .consequent_expr (~ovl_slot2_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss15 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (ovl_slot3_state_biu & ovl_slot3_sameline[3]),
                         .consequent_expr (~ovl_slot4_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss16 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (ovl_slot4_state_biu & ovl_slot4_sameline[0]),
                         .consequent_expr (~ovl_slot0_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss17 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (ovl_slot4_state_biu & ovl_slot4_sameline[1]),
                         .consequent_expr (~ovl_slot1_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss18 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (ovl_slot4_state_biu & ovl_slot4_sameline[2]),
                         .consequent_expr (~ovl_slot2_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline cannot hit and go to the BIU")
  u_ovl_sameline_miss19 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (ovl_slot4_state_biu & ovl_slot4_sameline[3]),
                         .consequent_expr (~ovl_slot3_state_hit));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst going to the BIU must have the same l2dbid")
  u_ovl_sameburst_l2dbid0 (.clk (clk),
                           .reset_n (reset_n),
                           .antecedent_expr (slot0_state_biudata & ovl_slot0_sameburst[0]),
                           .consequent_expr (slot0_l2dbid == slot1_l2dbid));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst going to the BIU must have the same l2dbid")
  u_ovl_sameburst_l2dbid1 (.clk (clk),
                           .reset_n (reset_n),
                           .antecedent_expr (slot0_state_biudata & ovl_slot0_sameburst[1]),
                           .consequent_expr (slot0_l2dbid == slot2_l2dbid));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst going to the BIU must have the same l2dbid")
  u_ovl_sameburst_l2dbid2 (.clk (clk),
                           .reset_n (reset_n),
                           .antecedent_expr (slot0_state_biudata & ovl_slot0_sameburst[2]),
                           .consequent_expr (slot0_l2dbid == slot3_l2dbid));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst going to the BIU must have the same l2dbid")
  u_ovl_sameburst_l2dbid3 (.clk (clk),
                           .reset_n (reset_n),
                           .antecedent_expr (slot0_state_biudata & ovl_slot0_sameburst[3]),
                           .consequent_expr (slot0_l2dbid == slot4_l2dbid));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst going to the BIU must have the same l2dbid")
  u_ovl_sameburst_l2dbid4 (.clk (clk),
                           .reset_n (reset_n),
                           .antecedent_expr (slot1_state_biudata & ovl_slot1_sameburst[1]),
                           .consequent_expr (slot1_l2dbid == slot2_l2dbid));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst going to the BIU must have the same l2dbid")
  u_ovl_sameburst_l2dbid5 (.clk (clk),
                           .reset_n (reset_n),
                           .antecedent_expr (slot1_state_biudata & ovl_slot1_sameburst[2]),
                           .consequent_expr (slot1_l2dbid == slot3_l2dbid));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst going to the BIU must have the same l2dbid")
  u_ovl_sameburst_l2dbid6 (.clk (clk),
                           .reset_n (reset_n),
                           .antecedent_expr (slot1_state_biudata & ovl_slot1_sameburst[3]),
                           .consequent_expr (slot1_l2dbid == slot4_l2dbid));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst going to the BIU must have the same l2dbid")
  u_ovl_sameburst_l2dbid7 (.clk (clk),
                           .reset_n (reset_n),
                           .antecedent_expr (slot2_state_biudata & ovl_slot2_sameburst[2]),
                           .consequent_expr (slot2_l2dbid == slot3_l2dbid));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst going to the BIU must have the same l2dbid")
  u_ovl_sameburst_l2dbid8 (.clk (clk),
                           .reset_n (reset_n),
                           .antecedent_expr (slot2_state_biudata & ovl_slot2_sameburst[3]),
                           .consequent_expr (slot2_l2dbid == slot4_l2dbid));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameburst going to the BIU must have the same l2dbid")
  u_ovl_sameburst_l2dbid9 (.clk (clk),
                           .reset_n (reset_n),
                           .antecedent_expr (slot3_state_biudata & ovl_slot3_sameburst[3]),
                           .consequent_expr (slot3_l2dbid == slot4_l2dbid));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same eviction hazard")
  u_ovl_sameline_ev_hz0 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot0_valid & ovl_slot0_sameline[0]),
                         .consequent_expr (slot0_ev_hz_seen == slot1_ev_hz_seen));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same eviction hazard")
  u_ovl_sameline_ev_hz1 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot0_valid & ovl_slot0_sameline[1]),
                         .consequent_expr (slot0_ev_hz_seen == slot2_ev_hz_seen));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same eviction hazard")
  u_ovl_sameline_ev_hz2 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot0_valid & ovl_slot0_sameline[2]),
                         .consequent_expr (slot0_ev_hz_seen == slot3_ev_hz_seen));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same eviction hazard")
  u_ovl_sameline_ev_hz3 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot0_valid & ovl_slot0_sameline[3]),
                         .consequent_expr (slot0_ev_hz_seen == slot4_ev_hz_seen));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same eviction hazard")
  u_ovl_sameline_ev_hz4 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot1_valid & ovl_slot1_sameline[1]),
                         .consequent_expr (slot1_ev_hz_seen == slot2_ev_hz_seen));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same eviction hazard")
  u_ovl_sameline_ev_hz5 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot1_valid & ovl_slot1_sameline[2]),
                         .consequent_expr (slot1_ev_hz_seen == slot3_ev_hz_seen));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same eviction hazard")
  u_ovl_sameline_ev_hz6 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot1_valid & ovl_slot1_sameline[3]),
                         .consequent_expr (slot1_ev_hz_seen == slot4_ev_hz_seen));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same eviction hazard")
  u_ovl_sameline_ev_hz7 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot2_valid & ovl_slot2_sameline[2]),
                         .consequent_expr (slot2_ev_hz_seen == slot3_ev_hz_seen));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same eviction hazard")
  u_ovl_sameline_ev_hz8 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot2_valid & ovl_slot2_sameline[3]),
                         .consequent_expr (slot2_ev_hz_seen == slot4_ev_hz_seen));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same eviction hazard")
  u_ovl_sameline_ev_hz9 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot3_valid & ovl_slot3_sameline[3]),
                         .consequent_expr (slot3_ev_hz_seen == slot4_ev_hz_seen));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same (no) alloc on miss behaviour")
  u_ovl_sameline_no_alloc0 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot0_valid & ovl_slot0_sameline[0]),
                         .consequent_expr (slot0_no_alloc_on_miss == slot1_no_alloc_on_miss));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same (no) alloc on miss behaviour")
  u_ovl_sameline_no_alloc1 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot0_valid & ovl_slot0_sameline[1]),
                         .consequent_expr (slot0_no_alloc_on_miss == slot2_no_alloc_on_miss));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same (no) alloc on miss behaviour")
  u_ovl_sameline_no_alloc2 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot0_valid & ovl_slot0_sameline[2]),
                         .consequent_expr (slot0_no_alloc_on_miss == slot3_no_alloc_on_miss));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same (no) alloc on miss behaviour")
  u_ovl_sameline_no_alloc3 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot0_valid & ovl_slot0_sameline[3]),
                         .consequent_expr (slot0_no_alloc_on_miss == slot4_no_alloc_on_miss));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same (no) alloc on miss behaviour")
  u_ovl_sameline_no_alloc4 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot1_valid & ovl_slot1_sameline[1]),
                         .consequent_expr (slot1_no_alloc_on_miss == slot2_no_alloc_on_miss));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same (no) alloc on miss behaviour")
  u_ovl_sameline_no_alloc5 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot1_valid & ovl_slot1_sameline[2]),
                         .consequent_expr (slot1_no_alloc_on_miss == slot3_no_alloc_on_miss));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same (no) alloc on miss behaviour")
  u_ovl_sameline_no_alloc6 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot1_valid & ovl_slot1_sameline[3]),
                         .consequent_expr (slot1_no_alloc_on_miss == slot4_no_alloc_on_miss));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same (no) alloc on miss behaviour")
  u_ovl_sameline_no_alloc7 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot2_valid & ovl_slot2_sameline[2]),
                         .consequent_expr (slot2_no_alloc_on_miss == slot3_no_alloc_on_miss));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same (no) alloc on miss behaviour")
  u_ovl_sameline_no_alloc8 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot2_valid & ovl_slot2_sameline[3]),
                         .consequent_expr (slot2_no_alloc_on_miss == slot4_no_alloc_on_miss));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same (no) alloc on miss behaviour")
  u_ovl_sameline_no_alloc9 (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (slot3_valid & ovl_slot3_sameline[3]),
                         .consequent_expr (slot3_no_alloc_on_miss == slot4_no_alloc_on_miss));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same beat count")
  u_ovl_sameline_beat_count0 (.clk (clk),
                               .reset_n (reset_n),
                               .antecedent_expr (slot0_valid & ovl_slot0_sameline[0]),
                               .consequent_expr (slot0_sameline_beat_count == slot1_sameline_beat_count));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same beat count")
  u_ovl_sameline_beat_count1 (.clk (clk),
                               .reset_n (reset_n),
                               .antecedent_expr (slot0_valid & ovl_slot0_sameline[1]),
                               .consequent_expr (slot0_sameline_beat_count == slot2_sameline_beat_count));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same beat count")
  u_ovl_sameline_beat_count2 (.clk (clk),
                               .reset_n (reset_n),
                               .antecedent_expr (slot0_valid & ovl_slot0_sameline[2]),
                               .consequent_expr (slot0_sameline_beat_count == slot3_sameline_beat_count));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same beat count")
  u_ovl_sameline_beat_count3 (.clk (clk),
                               .reset_n (reset_n),
                               .antecedent_expr (slot0_valid & ovl_slot0_sameline[3]),
                               .consequent_expr (slot0_sameline_beat_count == slot4_sameline_beat_count));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same beat count")
  u_ovl_sameline_beat_count4 (.clk (clk),
                               .reset_n (reset_n),
                               .antecedent_expr (slot1_valid & ovl_slot1_sameline[1]),
                               .consequent_expr (slot1_sameline_beat_count == slot2_sameline_beat_count));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same beat count")
  u_ovl_sameline_beat_count5 (.clk (clk),
                               .reset_n (reset_n),
                               .antecedent_expr (slot1_valid & ovl_slot1_sameline[2]),
                               .consequent_expr (slot1_sameline_beat_count == slot3_sameline_beat_count));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same beat count")
  u_ovl_sameline_beat_count6 (.clk (clk),
                               .reset_n (reset_n),
                               .antecedent_expr (slot1_valid & ovl_slot1_sameline[3]),
                               .consequent_expr (slot1_sameline_beat_count == slot4_sameline_beat_count));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same beat count")
  u_ovl_sameline_beat_count7 (.clk (clk),
                               .reset_n (reset_n),
                               .antecedent_expr (slot2_valid & ovl_slot2_sameline[2]),
                               .consequent_expr (slot2_sameline_beat_count == slot3_sameline_beat_count));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same beat count")
  u_ovl_sameline_beat_count8 (.clk (clk),
                               .reset_n (reset_n),
                               .antecedent_expr (slot2_valid & ovl_slot2_sameline[3]),
                               .consequent_expr (slot2_sameline_beat_count == slot4_sameline_beat_count));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots marked as sameline must have the same beat count")
  u_ovl_sameline_beat_count9 (.clk (clk),
                               .reset_n (reset_n),
                               .antecedent_expr (slot3_valid & ovl_slot3_sameline[3]),
                               .consequent_expr (slot3_sameline_beat_count == slot4_sameline_beat_count));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots with the same address must have an earlier bit set")
  u_ovl_earlier0 (.clk (clk),
                  .reset_n (reset_n),
                  .antecedent_expr (slot0_valid & ~slot0_cp15 & slot1_valid & ~slot1_cp15 &
                                    ({slot0_ns, slot0_addr[39:4]} == {slot1_ns, slot1_addr[39:4]})),
                  .consequent_expr (slot0_earlier[0] | slot1_earlier[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots with the same address must have an earlier bit set")
  u_ovl_earlier1 (.clk (clk),
                  .reset_n (reset_n),
                  .antecedent_expr (slot0_valid & ~slot0_cp15 & slot2_valid & ~slot2_cp15 &
                                    ({slot0_ns, slot0_addr[39:4]} == {slot2_ns, slot2_addr[39:4]})),
                  .consequent_expr (slot0_earlier[1] | slot2_earlier[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots with the same address must have an earlier bit set")
  u_ovl_earlier2 (.clk (clk),
                  .reset_n (reset_n),
                  .antecedent_expr (slot0_valid & ~slot0_cp15 & slot3_valid & ~slot3_cp15 &
                                    ({slot0_ns, slot0_addr[39:4]} == {slot3_ns, slot3_addr[39:4]})),
                  .consequent_expr (slot0_earlier[2] | slot3_earlier[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots with the same address must have an earlier bit set")
  u_ovl_earlier3 (.clk (clk),
                  .reset_n (reset_n),
                  .antecedent_expr (slot0_valid & ~slot0_cp15 & slot4_valid & ~slot4_cp15 &
                                    ({slot0_ns, slot0_addr[39:4]} == {slot4_ns, slot4_addr[39:4]})),
                  .consequent_expr (slot0_earlier[3] | slot4_earlier[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots with the same address must have an earlier bit set")
  u_ovl_earlier4 (.clk (clk),
                  .reset_n (reset_n),
                  .antecedent_expr (slot1_valid & ~slot1_cp15 & slot2_valid & ~slot2_cp15 &
                                    ({slot1_ns, slot1_addr[39:4]} == {slot2_ns, slot2_addr[39:4]})),
                  .consequent_expr (slot1_earlier[1] | slot2_earlier[1]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots with the same address must have an earlier bit set")
  u_ovl_earlier5 (.clk (clk),
                  .reset_n (reset_n),
                  .antecedent_expr (slot1_valid & ~slot1_cp15 & slot3_valid & ~slot3_cp15 &
                                    ({slot1_ns, slot1_addr[39:4]} == {slot3_ns, slot3_addr[39:4]})),
                  .consequent_expr (slot1_earlier[2] | slot3_earlier[1]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots with the same address must have an earlier bit set")
  u_ovl_earlier6 (.clk (clk),
                  .reset_n (reset_n),
                  .antecedent_expr (slot1_valid & ~slot1_cp15 & slot4_valid & ~slot4_cp15 &
                                    ({slot1_ns, slot1_addr[39:4]} == {slot4_ns, slot4_addr[39:4]})),
                  .consequent_expr (slot1_earlier[3] | slot4_earlier[1]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots with the same address must have an earlier bit set")
  u_ovl_earlier7 (.clk (clk),
                  .reset_n (reset_n),
                  .antecedent_expr (slot2_valid & ~slot2_cp15 & slot3_valid & ~slot3_cp15 &
                                    ({slot2_ns, slot2_addr[39:4]} == {slot3_ns, slot3_addr[39:4]})),
                  .consequent_expr (slot2_earlier[2] | slot3_earlier[2]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots with the same address must have an earlier bit set")
  u_ovl_earlier8 (.clk (clk),
                  .reset_n (reset_n),
                  .antecedent_expr (slot2_valid & ~slot2_cp15 & slot4_valid & ~slot4_cp15 &
                                    ({slot2_ns, slot2_addr[39:4]} == {slot4_ns, slot4_addr[39:4]})),
                  .consequent_expr (slot2_earlier[3] | slot4_earlier[2]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two slots with the same address must have an earlier bit set")
  u_ovl_earlier9 (.clk (clk),
                  .reset_n (reset_n),
                  .antecedent_expr (slot3_valid & ~slot3_cp15 & slot4_valid & ~slot4_cp15 &
                                    ({slot3_ns, slot3_addr[39:4]} == {slot4_ns, slot4_addr[39:4]})),
                  .consequent_expr (slot3_earlier[3] | slot4_earlier[3]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "AR request must only be made when a slot has priority")
  u_ovl_ar_req (.clk (clk),
                .reset_n (reset_n),
                .antecedent_expr (stb_ar_req_o),
                .consequent_expr (slot0_has_ar_priority | slot0_already_has_ar_priority |
                                  slot1_has_ar_priority | slot1_already_has_ar_priority |
                                  slot2_has_ar_priority | slot2_already_has_ar_priority |
                                  slot3_has_ar_priority | slot3_already_has_ar_priority |
                                  slot4_has_ar_priority | slot4_already_has_ar_priority));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "AR request must be suppressed if the selected slot is suppressing its request")
  u_ovl_ar_req_suppress (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (stb_ar_req_o),
                         .consequent_expr (~|(ar_slot_select & slots_ar_suppress)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Early AR request must be asserted if there is an AR request")
  u_ovl_ar_early_req (.clk (clk),
                      .reset_n (reset_n),
                      .antecedent_expr (stb_ar_req_o),
                      .consequent_expr (stb_ar_early_req_o));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Early AR request must be asserted if there is a linefill request")
  u_ovl_early_lfreq (.clk (clk),
                     .reset_n (reset_n),
                     .antecedent_expr (|stb_lf_req_o),
                     .consequent_expr (stb_ar_early_req_o));

  assert_zero_one_hot #(`OVL_FATAL, 5, `OVL_ASSERT, "Only one slot can contain a strex")
  u_ovl_only_one_strex (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (slots_valid & {slot4_ar_excl,
                                                   slot3_ar_excl,
                                                   slot2_ar_excl,
                                                   slot1_ar_excl,
                                                   slot0_ar_excl}));

  wire [39:0] ovl_ar_addr = ((slot0_has_ar_priority | slot0_already_has_ar_priority) ? slot0_ar_addr :
                             (slot1_has_ar_priority | slot1_already_has_ar_priority) ? slot1_ar_addr :
                             (slot2_has_ar_priority | slot2_already_has_ar_priority) ? slot2_ar_addr :
                             (slot3_has_ar_priority | slot3_already_has_ar_priority) ? slot3_ar_addr :
                             (slot4_has_ar_priority | slot4_already_has_ar_priority) ? slot4_ar_addr :
                             40'h0000000000);

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "stb_ar_addr signal correct")
  u_ovl_ar_addr_correct (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (stb_ar_req_o),
                         .consequent_expr (stb_ar_addr[39:6] == ovl_ar_addr[39:6]));

  wire ovl_ar_ns = ((slot0_has_ar_priority | slot0_already_has_ar_priority) ? slot0_ar_ns :
                    (slot1_has_ar_priority | slot1_already_has_ar_priority) ? slot1_ar_ns :
                    (slot2_has_ar_priority | slot2_already_has_ar_priority) ? slot2_ar_ns :
                    (slot3_has_ar_priority | slot3_already_has_ar_priority) ? slot3_ar_ns :
                    (slot4_has_ar_priority | slot4_already_has_ar_priority) ? slot4_ar_ns :
                    1'b0);

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "stb_ar_ns signal correct")
  u_ovl_ar_ns_correct (.clk (clk),
                       .reset_n (reset_n),
                       .antecedent_expr (stb_ar_req_o),
                       .consequent_expr (stb_ar_ns_dsc_o == ovl_ar_ns));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Only coherent memory can be written to the cache")
  u_ovl_cache_wr_coherent (.clk (clk),
                           .reset_n (reset_n),
                           .antecedent_expr (stb_cache_data_req_m0_o),
                           .consequent_expr (`CA53_MEM_COHERENT(stb_cache_data_attrs_m0_o)));

  wire [7:0] ovl_stb_cache_tag_attrs_m0 = ({8{slot4_has_tagwrite_priority}} & slot4_attrs) |
                                          ({8{slot3_has_tagwrite_priority}} & slot3_attrs) |
                                          ({8{slot2_has_tagwrite_priority}} & slot2_attrs) |
                                          ({8{slot1_has_tagwrite_priority}} & slot1_attrs) |
                                          ({8{slot0_has_tagwrite_priority}} & slot0_attrs);

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Only coherent memory can update cache tags")
  u_ovl_tag_wr_coherent (.clk (clk),
                         .reset_n (reset_n),
                         .antecedent_expr (any_slot_has_tagwrite_priority),
                         .consequent_expr (`CA53_MEM_COHERENT(ovl_stb_cache_tag_attrs_m0)));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Optimized barrier behaviour should be disabled when dpu_disable_dmb is asserted")
  u_ovl_optimized_barrier_disable (.clk         (clk),
                                   .reset_n     (reset_n),
                                   .start_event (dpu_disable_dmb_i),
                                   .test_expr   (propagate_barrier));

  /*ARMAUTO_X*/
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dcu_stb_data_ack_m1_i")
  u_ovl_x_dcu_stb_data_ack_m1_i (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (dcu_stb_data_ack_m1_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dcu_stb_read_wls_m1_en")
  u_ovl_x_dcu_stb_read_wls_m1_en (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (dcu_stb_read_wls_m1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: propagate_barrier_en")
  u_ovl_x_propagate_barrier_en (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (propagate_barrier_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ar_slot_select_en")
  u_ovl_x_ar_slot_select_en (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (ar_slot_select_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cache_data_slot_select_en")
  u_ovl_x_cache_data_slot_select_en (.clk       (clk),
                                     .reset_n   (reset_n),
                                     .qualifier (1'b1),
                                     .test_expr (cache_data_slot_select_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cycle_count_en")
  u_ovl_x_cycle_count_en (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (cycle_count_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dvm_sync_needed_en")
  u_ovl_x_dvm_sync_needed_en (.clk       (clk_stb),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (dvm_sync_needed_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: stb_en")
  u_ovl_x_stb_en (.clk       (clk_stb),
                  .reset_n   (reset_n),
                  .qualifier (1'b1),
                  .test_expr (stb_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tag_ecc_err_m3_en")
  u_ovl_x_tag_ecc_err_m3_en (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (tag_ecc_err_m3_en));

  /*END*/

`endif

endmodule // ca53stb

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53_stb_biu_defs.v"
`include "ca53stb_defs.v"
`undef CA53_UNDEFINE
/*END*/
