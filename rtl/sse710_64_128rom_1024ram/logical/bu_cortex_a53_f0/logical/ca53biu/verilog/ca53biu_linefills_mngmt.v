//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2015 ARM Limited.
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
// Abstract : BIU linefills management
//-----------------------------------------------------------------------------
//
// Overview
// -------
// The linefill requests and the BIU L1 data cache allocation are handled in this module.
// Other features:
//  o cacheable loads hazards handling
//  o data prefetch management

`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53biu_defs.v"

module ca53biu_linefills_mngmt #(parameter CPU_CACHE_PROTECTION = 1'b0)
  (
   //----------------------------------------------------------------------------
   // Clock and Reset
   //----------------------------------------------------------------------------

   input  wire                                                     clk,
   input  wire                                                     reset_n,
   input  wire                                                     DFTSE,

   //----------------------------------------------------------------------------
   // MBIST
   //----------------------------------------------------------------------------

   input  wire                                                     biu_mbist_req_i,

   //------------------------------------------------------------------------------
   // RAMs interface
   //------------------------------------------------------------------------------

   input wire [2:0]                                                dc_size_i,

   //------------------------------------------------------------------------------
   // DPU D-cache on
   //------------------------------------------------------------------------------

   input  wire                                                     dpu_dcache_on_i,

   //-----------------------------------------------------------------------------
   // DPU configure prefetch stream detection
   //-----------------------------------------------------------------------------

   input  wire [2:0]                                               dpu_enable_data_prefetch_i,
   input  wire [1:0]                                               dpu_enable_data_prefetch_streams_i,
   input  wire                                                     dpu_data_prefetch_stride_detect_i,
   input  wire                                                     dpu_disable_data_prefetch_stores_pattern_i,
   input  wire                                                     dpu_disable_data_prefetch_readunique_i,

   //-----------------------------------------------------------------------------
   // Memory granule: 2'b00: 4k, 2'b01: 16k, 2'b11: 64k
   //-----------------------------------------------------------------------------

   input  wire [1:0]                                               tlb_mem_granule_i,

   //------------------------------------------------------------------------------
   // BIU AR req channel
   //------------------------------------------------------------------------------

   input  wire                                                     biu_ar_valid_i,
   input  wire [40:6]                                              biu_ar_addr_i,
   input  wire [7:0]                                               biu_ar_attrs_i,
   input  wire [2:0]                                               biu_ar_lf_master_i,

   //------------------------------------------------------------------------------
   // CCB linefills hazard interface
   //------------------------------------------------------------------------------

   input  wire [3:0]                                               dcu_ccb_ways_i,
   input  wire [13:6]                                              dcu_ccb_index_i,
   output wire                                                     biu_ccb_lf_hazard_o,

   //-----------------------------------------------------------------------------
   // DC1 loads
   //-----------------------------------------------------------------------------

   input  wire                                                     dcu_load_dc1_i,
   input  wire                                                     dcu_lf_req_dc1_i,
   input  wire [1:0]                                               dcu_lf_way_dc1_i,
   input  wire                                                     dcu_leaving_dc1_i,
   input  wire [39:12]                                             dpu_pa_dc1_i,
   input  wire [11:4]                                              dpu_va_dc1_i,
   input  wire                                                     dpu_ns_dsc_dc1_i,
   input  wire [7:0]                                               dcu_attrs_dc1_i,

   //-----------------------------------------------------------------------------
   // DC2 linefill request
   //-----------------------------------------------------------------------------

   input  wire                                                     dcu_load_dc2_i,
   input  wire [39:4]                                              dcu_pa_dc2_i,
   input  wire                                                     dcu_ns_dsc_dc2_i,
   input  wire [7:0]                                               dcu_attrs_dc2_i,
   input  wire                                                     dcu_exclusive_dc2_i,
   input  wire                                                     dcu_lf_req_dc2_i,
   input  wire [1:0]                                               dcu_lf_way_dc2_i,
   input  wire                                                     dcu_leaving_dc2_i,

   //-----------------------------------------------------------------------------
   // DC3 linefill request
   //-----------------------------------------------------------------------------

   input  wire                                                     dcu_load_dc3_i,
   input  wire                                                     dcu_lf_req_dc3_i,
   input  wire [1:0]                                               dcu_lf_way_dc3_i,
   input  wire [39:4]                                              dcu_pa_dc3_i,
   input  wire                                                     dcu_ns_dsc_dc3_i,
   input  wire [7:0]                                               dcu_attrs_dc3_i,
   input  wire                                                     dcu_exclusive_dc3_i,
   input  wire                                                     dcu_pldw_dc3_i,
   input  wire                                                     biu_leaving_dc3_i,

   //-----------------------------------------------------------------------------
   // DCU linefill sideband signals
   //-----------------------------------------------------------------------------

   input  wire                                                     dcu_lf_active_i,
   input  wire                                                     dcu_stop_pf_i,
   input  wire                                                     dcu_drain_stb_lf_i,
   output wire [7:0]                                               biu_lf_in_progress_o,
   output wire                                                     biu_suppress_tlb_hit_o,
   output wire                                                     biu_lf_ready_dc2_o,
   output wire                                                     biu_lf_next_ready_dc3_o,
   output wire                                                     biu_suppress_load_hit_dc2_o,

   //------------------------------------------------------------------------------
   // TLB linefill request
   //------------------------------------------------------------------------------

   input  wire                                                     tlb_walk_lf_active_i,
   input  wire                                                     tlb_walk_lf_req_i,
   input  wire [39:4]                                              tlb_walk_addr_i,
   input  wire                                                     tlb_walk_ns_dsc_i,
   input  wire [7:0]                                               tlb_walk_attrs_i,
   input  wire [1:0]                                               tlb_walk_way_i,
   output wire                                                     biu_walk_lf_hazard_o,

   //-----------------------------------------------------------------------------
   // STB linefill request & hazards check
   //-----------------------------------------------------------------------------

   input  wire [4:0]                                               stb_slots_valid_i,
   input  wire [39:4]                                              stb_slot0_addr_i,
   input  wire [39:4]                                              stb_slot1_addr_i,
   input  wire [39:4]                                              stb_slot2_addr_i,
   input  wire [39:4]                                              stb_slot3_addr_i,
   input  wire [39:4]                                              stb_slot4_addr_i,
   input  wire [4:0]                                               stb_slots_ns_dsc_i,
   input  wire [1:0]                                               stb_slot0_way_i,
   input  wire [1:0]                                               stb_slot1_way_i,
   input  wire [1:0]                                               stb_slot2_way_i,
   input  wire [1:0]                                               stb_slot3_way_i,
   input  wire [1:0]                                               stb_slot4_way_i,
   input  wire [7:0]                                               stb_slot0_attrs_i,
   input  wire [7:0]                                               stb_slot1_attrs_i,
   input  wire [7:0]                                               stb_slot2_attrs_i,
   input  wire [7:0]                                               stb_slot3_attrs_i,
   input  wire [7:0]                                               stb_slot4_attrs_i,
   output wire [4:0]                                               biu_lf_hazard_o,
   output wire [4:0]                                               biu_lf_hazard_migratory_o,
   output wire [4:0]                                               biu_lf_real_hazard_o,
   output wire [1:0]                                               biu_lf_hazard_way_slot0_o,
   output wire [1:0]                                               biu_lf_hazard_way_slot1_o,
   output wire [1:0]                                               biu_lf_hazard_way_slot2_o,
   output wire [1:0]                                               biu_lf_hazard_way_slot3_o,
   output wire [1:0]                                               biu_lf_hazard_way_slot4_o,
   output wire [4:0]                                               biu_lf_serialized_o,
   output wire [4:0]                                               biu_ev_hazard_o,
   input  wire                                                     stb_lf_active_i,
   input  wire [4:0]                                               stb_lf_req_i,
   input  wire [4:0]                                               stb_lf_merge_i,
   input  wire [4:0]                                               stb_lf_earliest_slot_i,
   output wire [4:0]                                               biu_lf_can_merge_o,
   input  wire [4:0]                                               stb_slot_cachewrite_m1_i,
   input  wire                                                     dcu_stb_data_ack_m1_i,
   input  wire                                                     dcu_stb_req_dc3_i,
   output wire                                                     biu_dirty_lf_in_progress_o,
   output wire                                                     biu_excl_lf_in_progress_o,

   //------------------------------------------------------------------------------
   // SCU interface
   //------------------------------------------------------------------------------

   input  wire                                                     scu_dr_valid_i,
   input  wire [4:0]                                               scu_dr_id_i,
   input  wire [4:0]                                               scu_dr_resp_i,
   input  wire [1:0]                                               scu_dr_chunk_i,
   input  wire [7:0]                                               scu_ev_done_i,

   //------------------------------------------------------------------------------
   // BIU linefills imprecise aborts
   //------------------------------------------------------------------------------

   output wire                                                     linefill_imp_abort_o,
   output wire [1:0]                                               linefill_imp_fault_o,

   //------------------------------------------------------------------------------
   // DCU allocation interface
   //------------------------------------------------------------------------------

   output wire [255:0]                                             biu_alloc_data_m0_o,
   output wire                                                     biu_alloc_tag_req_m0_o,
   output wire                                                     biu_alloc_data_req_m0_o,
   output wire                                                     biu_alloc_halfline_m0_o,
   output wire                                                     biu_alloc_dirty_req_m0_o,
   output wire [39:4]                                              biu_alloc_addr_m0_o,
   output wire                                                     biu_alloc_ns_dsc_m0_o,
   output wire [3:0]                                               biu_alloc_way_m0_o,
   output wire [1:0]                                               biu_alloc_tag_moesi_m0_o,
   input  wire                                                     dcu_alloc_has_priority_m0_i,
   output wire [1:0]                                               biu_alloc_dirty_moesi_m1_o,
   output wire                                                     biu_alloc_dirty_age_m1_o,
   output wire [7:0]                                               biu_alloc_attrs_m1_o,
   input  wire                                                     dcu_alloc_ack_m1_i,

   //------------------------------------------------------------------------------
   // DCU prefetch TAG interface
   //------------------------------------------------------------------------------

   output wire                                                     biu_pf_tag_req_m0_o,
   output wire [39:6]                                              biu_pf_tag_addr_m0_o,
   output wire                                                     biu_pf_tag_ns_dsc_m0_o,
   input  wire                                                     dcu_pf_tag_has_priority_m0_i,
   input  wire                                                     dcu_pf_tag_ack_m1_i,
   input  wire                                                     dcu_pf_tag_hit_m2_i,
   input  wire                                                     dcu_ecc_tag_err_m3_i,

   //----------------------------------------------------------------------------
   // Prefetchers LF request active (factorized into AR active output)
   //----------------------------------------------------------------------------

   output wire                                                     pf_lf_active_o,

   //------------------------------------------------------------------------------
   // BIU linefill request
   //------------------------------------------------------------------------------

   output wire                                                     biu_lf_req_o,
   output wire [39:4]                                              biu_lf_addr_o,
   output wire                                                     biu_lf_ns_dsc_o,
   output wire [7:0]                                               biu_lf_attrs_o,
   output wire [3:0]                                               biu_lf_way_o,
   output wire [2:0]                                               biu_lf_descr_id_o,
   output wire [2:0]                                               biu_lf_master_o,
   input  wire                                                     biu_lf_ack_i,


   //------------------------------------------------------------------------------
   // BIU Read allocate mode
   //------------------------------------------------------------------------------

   input  wire                                                     biu_read_alloc_pend_i,
   output wire                                                     lf_descr_inc_ramode_o,
   output wire                                                     lf_descr_leave_ramode_o,

   //------------------------------------------------------------------------------
   // BIU Read buffers interface
   //------------------------------------------------------------------------------

   input  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_valid_i,
   input  wire [128*`CA53_BIU_RBUFS_NUM-1:0]                       rbuf_data_packed_i,
   input  wire [2*`CA53_BIU_RBUFS_NUM-1:0]                         rbuf_chunk_packed_i,
   input  wire [`CA53_BIU_LF_DESCR_NUM_W*`CA53_BIU_RBUFS_NUM-1:0]  rbuf_id_packed_i,
   input  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_age_i,
   input  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_for_lf_valid_i,
   input  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_for_lf_oldest_sel_i,
   output wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_for_dc2_o,
   output wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_for_dc3_o,
   output wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_for_tlb_o,
   output wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_evict_done_o,
   output wire [`CA53_BIU_RBUFS_NUM-1:0]                           biu_alloc_rbuf_clr_o,
   output wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        biu_alloc_lf_descr_m0_o,
   output wire [3:0]                                               biu_alloc_chunk_req_m0_o,
   output wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        biu_alloc_lf_descr_m1_o,
   output wire [3:0]                                               biu_alloc_chunk_req_m1_o,

   //-----------------------------------------------------------------------------
   // PLD L1 sideband signals
   //-----------------------------------------------------------------------------

   input  wire                                                     ar_block_i,
   input  wire [3:0]                                               ar_credits_used_i,
   input  wire                                                     stb_ar_req_i,
   input  wire                                                     stb_is_dvm_i,

   //-----------------------------------------------------------------------------
   // Gov Management
   //-----------------------------------------------------------------------------

   input  wire                                                     gov_wfx_drain_req_i,
   output wire [`CA53_BIU_PF_STREAM_NUM-1:0]                       pf_stream_idle_o,

   //------------------------------------------------------------------------------
   // LF performance counters
   //------------------------------------------------------------------------------

   output wire                                                     biu_evnt_rw_lf_o,
   output wire                                                     biu_evnt_pf_lf_o
  );

  //-----------------------------------------------------------------------------
  // Registers
  //-----------------------------------------------------------------------------

  reg                                           clk_enable;
  reg                                           gov_wfx_drain_req_prev_cycle;
  reg                                           dcu_stop_pf_prev_cycle;
  reg  [1:0]                                    tlb_mem_granule_cpy;
  reg                                           biu_load_pa_hz_dc2_valid;
  reg                                           biu_load_pa_hz_dc3_valid;
  reg                                           biu_store_pa_hz_slot0_valid;
  reg                                           biu_store_pa_hz_slot1_valid;
  reg                                           biu_store_pa_hz_slot2_valid;
  reg                                           biu_store_pa_hz_slot3_valid;
  reg                                           biu_store_pa_hz_slot4_valid;
  reg  [40:6]                                   biu_load_pa_hz_dc2;
  reg  [40:6]                                   biu_load_pa_hz_dc3;
  reg  [40:6]                                   biu_store_pa_hz_slot0;
  reg  [40:6]                                   biu_store_pa_hz_slot1;
  reg  [40:6]                                   biu_store_pa_hz_slot2;
  reg  [40:6]                                   biu_store_pa_hz_slot3;
  reg  [40:6]                                   biu_store_pa_hz_slot4;
  reg                                           biu_suppress_load_hit_dc2;
  reg                                           biu_suppress_tlb_hit;
  reg                                           biu_walk_lf_hazard;
  reg  [`CA53_BIU_STB4_LF:`CA53_BIU_STB0_LF]    biu_lf_real_hazard;
  reg  [`CA53_BIU_STB4_LF:`CA53_BIU_STB0_LF]    biu_lf_hazard_migratory;
  reg  [1:0]                                    biu_lf_hazard_way_slot[`CA53_BIU_STB4_LF:`CA53_BIU_STB0_LF];
  reg  [`CA53_BIU_STB4_LF:`CA53_BIU_STB0_LF]    biu_lf_serialized;
  reg  [`CA53_BIU_STB4_LF:`CA53_BIU_STB0_LF]    biu_lf_can_merge;
  reg  [`CA53_BIU_STB4_LF:`CA53_BIU_STB0_LF]    biu_ev_hazard;
  reg                                           biu_dirty_lf_in_progress;
  reg                                           biu_lf_active_prev_cycle;
  reg  [40:6]                                   biu_lf_addr_last;
  reg  [2:0]                                    dpu_enable_data_prefetch_prev_cycle;
  reg  [1:0]                                    dpu_enable_data_prefetch_streams_prev_cycle;
  reg                                           dpu_data_prefetch_stride_detect_prev_cycle;
  reg                                           dpu_disable_data_prefetch_stores_pattern_prev_cycle;
  reg                                           dpu_disable_data_prefetch_readunique_prev_cycle;
  reg  [`CA53_BIU_LF_DESCR_NUM_W-1:0]           lf_descr_rr;
  reg  [3:0]                                    master_lf_descr_index_match_way_merged [`CA53_BIU_LF_MASTERS_NUM-1:0];
  reg                                           stb_must_drain;
  reg  [3:0]                                    lf_descr_pf_cnt;
  reg  [40:6]                                   pf_lf_addr;
  reg  [3:0]                                    pf_lf_way;
  reg  [7:0]                                    pf_lf_attrs;
  reg                                           pf_lf_pldw;
  reg  [`CA53_BIU_PF_STREAM_NUM-1:0]            pf_stream_dcu_tag_req_rr_sel;
  reg  [`CA53_BIU_PF_STREAM_NUM:0]              pf_stream_lf_req_rr_sel;
  reg                                           biu_evnt_rw_lf;
  reg                                           biu_evnt_pf_lf;

  //-----------------------------------------------------------------------------
  // Wires
  //-----------------------------------------------------------------------------

  wire                                          clk_pf_lf;
  wire                                          next_clk_enable;
  wire [13:6]                                   dcu_index_mask;
  wire                                          pf_lf_valid;
  wire                                          pf_lf_req;
  wire                                          biu_excl_lf_in_progress;
  wire                                          biu_lf_valid_active;
  wire                                          biu_pa_hz_en;
  wire                                          biu_load_pa_hz_dc2_en;
  wire                                          biu_load_pa_hz_dc3_en;
  wire                                          biu_store_pa_hz_slot0_en;
  wire                                          biu_store_pa_hz_slot1_en;
  wire                                          biu_store_pa_hz_slot2_en;
  wire                                          biu_store_pa_hz_slot3_en;
  wire                                          biu_store_pa_hz_slot4_en;
  wire                                          next_biu_load_pa_hz_dc2_valid;
  wire                                          next_biu_load_pa_hz_dc3_valid;
  wire                                          next_biu_store_pa_hz_slot0_valid;
  wire                                          next_biu_store_pa_hz_slot1_valid;
  wire                                          next_biu_store_pa_hz_slot2_valid;
  wire                                          next_biu_store_pa_hz_slot3_valid;
  wire                                          next_biu_store_pa_hz_slot4_valid;
  wire [40:6]                                   next_biu_load_pa_hz_dc2;
  wire [40:6]                                   next_biu_load_pa_hz_dc3;
  wire [40:6]                                   next_biu_store_pa_hz_slot0;
  wire [40:6]                                   next_biu_store_pa_hz_slot1;
  wire [40:6]                                   next_biu_store_pa_hz_slot2;
  wire [40:6]                                   next_biu_store_pa_hz_slot3;
  wire [40:6]                                   next_biu_store_pa_hz_slot4;
  wire                                          biu_lf_req;
  wire [`CA53_BIU_LF_MASTERS_NUM-1:1]           biu_lf_req_no_hz;
  wire                                          biu_lf_req_arb_stb_sel;
  wire                                          biu_lf_req_arb_pf_sel;
  wire [2:0]                                    biu_lf_master [2:0];
  wire [40:4]                                   biu_lf_addr [2:0];
  wire [7:0]                                    biu_lf_attrs [2:0];
  wire [3:0]                                    biu_lf_way [2:0];
  wire [4:0]                                    biu_lf_master_arb_out;
  wire [40:4]                                   biu_lf_addr_arb_out;
  wire [7:0]                                    biu_lf_attrs_arb_out;
  wire [3:0]                                    biu_lf_way_arb_out;
  wire                                          biu_lf_active;
  wire                                          biu_lf_active_extended;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             biu_lf_init;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             biu_ccb_lf_hazard;
  wire [4:0]                                    biu_lf_hazard;
  wire [`CA53_BIU_LF_DESCR_NUM_W-1:0]           next_lf_descr_rr;
  wire                                          lf_descr_rr_en;
  wire                                          lf_descr_available;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_idle;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_valid;
  wire [4:0]                                    lf_descr_master [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [3:0]                                    lf_descr_way [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire                                          stb_lf_earliest_slot_hz;
  wire [4:0]                                    stb_priority_mask;
  wire                                          stb_must_drain_en;
  wire                                          next_stb_must_drain;
  wire [`CA53_BIU_LF_MASTERS_NUM-1:0]           master_valid;
  wire [`CA53_BIU_LF_MASTERS_NUM-1:0]           master_hz_valid;
  wire [`CA53_BIU_LF_MASTERS_NUM-1:0]           master_lf_req;
  wire [40:4]                                   master_lf_addr [`CA53_BIU_LF_MASTERS_NUM-1:0];
  wire [40:6]                                   master_lf_addr_hz [`CA53_BIU_LF_MASTERS_NUM-1:0];
  wire [3:0]                                    master_lf_way [`CA53_BIU_LF_MASTERS_NUM-1:0];
  wire [7:0]                                    master_lf_attrs [`CA53_BIU_LF_MASTERS_NUM-1:0];
  wire [2:0]                                    master_lf_type [`CA53_BIU_LF_MASTERS_NUM-1:0];
  wire [`CA53_BIU_LF_MASTERS_NUM-1:0]           master_lf_descr_match;
  wire [`CA53_BIU_LF_MASTERS_NUM-1:0]           master_lf_descr_index_way_hz;
  wire [`CA53_BIU_LF_MASTERS_NUM-1:1]           master_lf_req_hz;
  wire [`CA53_BIU_LF_MASTERS_NUM-1:1]           master_lf_req_can_progress;
  wire [`CA53_BIU_LF_MASTERS_NUM-1:1]           master_lf_req_sel [2:0];
  wire [3:0]                                    master_lf_way_new [`CA53_BIU_LF_MASTERS_NUM-1:1];
  wire [3:0]                                    master_lf_way_final [`CA53_BIU_LF_MASTERS_NUM-1:1];
  wire [2*`CA53_BIU_LF_MASTERS_NUM-1:0]         master_lf_addr_packed;
  wire [35*`CA53_BIU_LF_MASTERS_NUM-1:0]        master_lf_addr_hz_packed;
  wire [4*`CA53_BIU_LF_MASTERS_NUM-1:0]         master_lf_way_packed;
  wire [39:6]                                   lf_descr_addr [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_ns_dsc;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_passed_as_dirty;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_ack_m1;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_migratory;
  wire [7:0]                                    lf_descr_attrs [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [3:0]                                    lf_descr_chunk_fetched_from_scu [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [3:0]                                    lf_descr_chunk_need_release [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [3:0]                                    lf_descr_chunk_allocated_from_stb [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [3:0]                                    lf_descr_chunk_allocated_from_biu [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [4:0]                                    lf_descr_stb_can_merge [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_tag_done;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_tag_err;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_unique;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_exclusive;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_evict_done;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_err_from_scu;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_fetched_last;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_fetched_last_prev_cycle;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_fetched_none;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_for_write;
  wire [`CA53_BIU_LF_MASTERS_NUM-1:0]           lf_descr_index_match_rot90 [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [`CA53_BIU_LF_MASTERS_NUM-1:0]           lf_descr_index_way_match_rot90 [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [`CA53_BIU_LF_MASTERS_NUM-1:0]           lf_descr_match_rot90 [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [`CA53_BIU_LF_MASTERS_NUM-1:0]           lf_descr_pf_match_rot90 [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_index_match [`CA53_BIU_LF_MASTERS_NUM-1:0];
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_index_way_match [`CA53_BIU_LF_MASTERS_NUM-1:0];
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_match [`CA53_BIU_LF_MASTERS_NUM-1:0];
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_pf_match [`CA53_BIU_LF_MASTERS_NUM-1:0];
  wire [3:0]                                    lf_descr_chunk_pend_m0 [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_last_pend_m1;
  wire [3:0]                                    lf_descr_chunk_pend_m1 [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_available_sel;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_inc_ramode;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_leave_ramode;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_imp_abort;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_imp_fault_dec;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_imp_fault_ecc;
  wire [34*`CA53_BIU_LF_DESCR_NUM-1:0]          lf_descr_addr_packed;
  wire [4*`CA53_BIU_LF_DESCR_NUM-1:0]           lf_descr_way_packed;
  wire [4*`CA53_BIU_LF_DESCR_NUM-1:0]           lf_descr_chunk_fetched_from_scu_packed;
  wire [4*`CA53_BIU_LF_DESCR_NUM-1:0]           lf_descr_chunk_allocated_from_stb_packed;
  wire [4*`CA53_BIU_LF_DESCR_NUM-1:0]           lf_descr_chunk_need_release_packed;
  wire [5*`CA53_BIU_LF_DESCR_NUM-1:0]           lf_descr_match_stb_packed;
  wire [8*`CA53_BIU_LF_DESCR_NUM-1:0]           lf_descr_attrs_packed;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             biu_alloc_lf_descr_m0;
  wire [3:0]                                    biu_alloc_chunk_req_m0;
  wire [39:4]                                   biu_alloc_addr_m0;
  wire                                          biu_alloc_ns_dsc_m0;
  wire                                          biu_alloc_lf_descr_from_pf_m0;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             biu_alloc_lf_descr_m1;
  wire [3:0]                                    biu_alloc_chunk_req_m1;
  wire                                          biu_alloc_last_m1;
  wire                                          lf_descr_pf_stride_ingress_en;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_pf_stride_egress_en;
  wire [1:0]                                    lf_descr_pf_stride_egress_cnt [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [3:0]                                    lf_descr_pf_stride_egress_stride [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_pf_stride_egress_en_pri [2:0];
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_pf_stride_egress_en_pri_sel [2:0];
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_pf_stride_egress_en_sel;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_pf_stream_alloc_active;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_pf_stream_alloc_req;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_pf_stream_alloc_hz_req;
  wire [40:6]                                   lf_descr_pf_stream_alloc_addr [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [3:0]                                    lf_descr_pf_stream_alloc_stride [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [7:0]                                    lf_descr_pf_stream_alloc_attrs [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_pf_stream_alloc_req_sel;
  wire [1:0]                                    lf_descr_pf_stride_ingress_cnt;
  wire [3:0]                                    lf_descr_pf_stride_ingress_stride;
  wire [40:6]                                   pf_stream_addr;
  wire [3:0]                                    pf_stream_stride;
  wire [7:0]                                    pf_stream_attrs;
  wire                                          pf_stream_pldw;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             pf_stream_alloc_hz;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             pf_stream_alloc_ack;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            biu_pf_tag_active;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            biu_pf_tag_active_arb;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            biu_pf_tag_req_m0;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            biu_pf_tag_req_m1;
  wire [39:6]                                   biu_pf_tag_addr_m0 [`CA53_BIU_PF_STREAM_NUM-1:0];
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            biu_pf_tag_ns_dsc_m0;
  wire                                          biu_pf_tag_req_m0_sel;
  wire [39:6]                                   biu_pf_tag_addr_m0_sel;
  wire                                          biu_pf_tag_ns_dsc_m0_sel;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            dcu_pf_tag_has_priority_m0;
  wire [`CA53_BIU_PF_STREAM_NUM:0]              pf_stream_idle;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            pf_stream_idle_sel;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            pf_stream_alloc_sel;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            pf_stream_throttle;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            pf_stream_throttle_sel;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            pf_stream_lf_used;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            pf_stream_cancel_throttle;
  wire                                          pf_stream_eligible_for_pf_lf_init;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            pf_stream_req_active;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            pf_stream_req;
  wire [40:6]                                   pf_stream_match_ingress_addr;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            pf_stream_match_ingress_hz;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            pf_stream_match_egress_hz;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            pf_stream_lf_active_early;
  wire [`CA53_BIU_PF_STREAM_NUM:0]              pf_stream_lf_active;
  wire [`CA53_BIU_PF_STREAM_NUM:0]              pf_stream_lf_req;
  wire                                          pf_stream_lf_req_dc1_sel;
  wire [40:6]                                   pf_stream_lf_addr [`CA53_BIU_PF_STREAM_NUM:0];
  wire [7:0]                                    pf_stream_lf_attrs [`CA53_BIU_PF_STREAM_NUM:0];
  wire [3:0]                                    pf_stream_lf_way [`CA53_BIU_PF_STREAM_NUM:0];
  wire [`CA53_BIU_PF_STREAM_NUM:0]              pf_stream_lf_pldw;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            pf_stream_lf_ack;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            pf_stream_lf_match_non_pf;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            pf_stream_lf_match_pf;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             dcu_stb_match_lf;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            dcu_stb_match_lf_from_pf;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            dpu_enable_data_prefetch_streams_abort_mask;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_from_pf;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_from_pf_stream [`CA53_BIU_PF_STREAM_NUM-1:0];
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            lf_descr_from_pf_stream_valid;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            pf_stream_pldw_abort;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            pf_stream_abort;
  wire                                          pf_streams_drop;
  wire                                          pf_stream_dcu_tag_req_rr_sel_en;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]            next_pf_stream_dcu_tag_req_rr_sel;
  wire [`CA53_BIU_PF_STREAM_NUM_W-1:0]          pf_stream_dcu_tag_req_rr_sel_bin;
  wire [3:0]                                    next_lf_descr_pf_cnt;
  wire                                          pf_stream_lf_req_throttle;
  wire [1:0]                                    pf_lf_stream_id;
  wire [40:6]                                   next_pf_lf_addr;
  wire [3:0]                                    next_pf_lf_way;
  wire [7:0]                                    next_pf_lf_attrs;
  wire                                          next_pf_lf_pldw;
  wire                                          next_biu_evnt_rw_lf;
  wire                                          next_biu_evnt_pf_lf;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_biu_evnt_rw_lf;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_biu_evnt_pf_lf;
  wire                                          lf_descr_at_least_two_available;
  wire                                          index_way_available;
  wire                                          biu_lf_ready_dc2;
  wire                                          biu_lf_next_ready_dc3;
  wire [`CA53_BIU_PF_STREAM_NUM:0]              pf_stream_lf_active_arb;
  wire [`CA53_BIU_PF_STREAM_NUM_W-1:0]          pf_stream_lf_req_rr_sel_bin;
  wire                                          pf_stream_lf_req_rr_sel_en;
  wire                                          pf_lf_en;
  wire                                          tlb_mem_granule_cpy_en;

  //-----------------------------------------------------------------------------
  // Generate variables
  //-----------------------------------------------------------------------------

  genvar                                        index_i;
  genvar                                        index_j;

  //-----------------------------------------------------------------------------
  // Intermediate clock gate
  //-----------------------------------------------------------------------------

  // Enable the gated clock when there is an arbitrated linefill request next clock cycle from
  // the data prefetch streams or DC1.

  assign next_clk_enable = |{dcu_lf_active_i, ~pf_stream_idle};

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      clk_enable <= 1'b0;
    end else begin
      clk_enable <= next_clk_enable;
    end

  ca53_cell_inter_clkgate u_inter_clkgate_lf_mngmt (.clk_i         (clk),
                                                    .clk_enable_i  (clk_enable),
                                                    .clk_senable_i (DFTSE),
                                                    .clk_gated_o   (clk_pf_lf));

  //-----------------------------------------------------------------------------
  // DCU cache index mask
  //-----------------------------------------------------------------------------

  assign dcu_index_mask = {dc_size_i, 5'b11111};

  //-----------------------------------------------------------------------------
  // Linefill request management
  //-----------------------------------------------------------------------------

  // Get if there is any linefill descriptor not in use.

  assign lf_descr_available = ~&lf_descr_valid;

  // Pick the linefill descriptor not in use based on a round robin basis.

  assign next_lf_descr_rr = `CA53_BIU_ONEHOT2BIN_8_3(lf_descr_available_sel) +
                            {{(`CA53_BIU_LF_DESCR_NUM_W-1){1'b0}}, 1'b1      };

  assign lf_descr_rr_en = biu_lf_ack_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      lf_descr_rr <= {`CA53_BIU_LF_DESCR_NUM_W{1'b0}};
    end else if (lf_descr_rr_en) begin
      lf_descr_rr <= next_lf_descr_rr;
    end

  assign lf_descr_idle = ~lf_descr_valid;

  // Pick one of the available linefill descriptors

  ca53_rr_arb #(.WIDTH(8)) u_biu_lf_descr_arb (
    .clk          (clk),
    .reset_n      (reset_n),
    .rr_counter_i (lf_descr_rr),
    .requests_i   (lf_descr_idle),
    .arb_o        (lf_descr_available_sel)
  );

  // The DCU and TLB normally have priority over the STB but the STB is given
  // priority if it needs to drain for a DVM sync.

  assign stb_must_drain_en   = dcu_drain_stb_lf_i | stb_must_drain;

  assign next_stb_must_drain = dcu_drain_stb_lf_i & (|master_lf_req_can_progress[`CA53_BIU_STB4_LF:`CA53_BIU_STB0_LF]);

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      stb_must_drain <= 1'b0;
    end else if (stb_must_drain_en) begin
      stb_must_drain <= next_stb_must_drain;
    end

  // In order to improve the dynamic power, the DC2/DC3/STB addresses used for hazard check are updated only when
  // there is a potential LF valid next clock cycle and if there is a load transaction valid in the corresponding
  // DCU/STB stage next clock cycle and thus reducing the toggle activity on the DC2/DC3/STB addresses factorized
  // in the hazard check logic.

  // Compute if there is a potential LF descriptor valid next clock cycle

  assign biu_lf_valid_active              = (|lf_descr_valid)                                   |
                                            (|(master_valid[`CA53_BIU_PF_LF:`CA53_BIU_DC3_LF] &
                                               master_lf_req[`CA53_BIU_PF_LF:`CA53_BIU_DC3_LF] ));

  assign next_biu_load_pa_hz_dc2[40:6]    = // Register the DCU DC1 address if the DC1 moves to DC2 and if there is a potential LF descriptor valid next clock cycle
                                            (dcu_load_dc1_i & dcu_leaving_dc1_i) ? {dpu_ns_dsc_dc1_i, dpu_pa_dc1_i[39:12], dpu_va_dc1_i[11:6]} :
                                            // Register the DCU DC2 address if the DC2 does not move to DC3 and if there is a potential LF descriptor valid next clock cycle
                                                                                   {dcu_ns_dsc_dc2_i, dcu_pa_dc2_i[39:6]};

  assign next_biu_load_pa_hz_dc3[40:6]    = // Register the DCU DC2 address if the DC2 moves to DC3 and if there is a potential LF descriptor valid next clock cycle
                                            (dcu_load_dc2_i & dcu_leaving_dc2_i) ? {dcu_ns_dsc_dc2_i, dcu_pa_dc2_i[39:6]} :
                                            // Register the DCU DC3 address if the DC3 does not leave and if there is a potential LF descriptor valid next clock cycle
                                                                                   {dcu_ns_dsc_dc3_i, dcu_pa_dc3_i[39:6]};

  assign next_biu_store_pa_hz_slot0[40:6] = (dcu_stb_req_dc3_i   &
                                             ~stb_slots_valid_i[0]) ? {dcu_ns_dsc_dc3_i, dcu_pa_dc3_i[39:6]}        :
                                                                      {stb_slots_ns_dsc_i[0], stb_slot0_addr_i[39:6]};

  assign next_biu_store_pa_hz_slot1[40:6] = (dcu_stb_req_dc3_i     &
                                             ~stb_slots_valid_i[1] &
                                             stb_slots_valid_i[0]   ) ? {dcu_ns_dsc_dc3_i, dcu_pa_dc3_i[39:6]}         :
                                                                        {stb_slots_ns_dsc_i[1], stb_slot1_addr_i[39:6]};

  assign next_biu_store_pa_hz_slot2[40:6] = (dcu_stb_req_dc3_i       &
                                             ~stb_slots_valid_i[2]   &
                                             (&stb_slots_valid_i[1:0])) ? {dcu_ns_dsc_dc3_i, dcu_pa_dc3_i[39:6]}        :
                                                                          {stb_slots_ns_dsc_i[2], stb_slot2_addr_i[39:6]};

  assign next_biu_store_pa_hz_slot3[40:6] = (dcu_stb_req_dc3_i       &
                                             ~stb_slots_valid_i[3]   &
                                             (&stb_slots_valid_i[2:0])) ? {dcu_ns_dsc_dc3_i, dcu_pa_dc3_i[39:6]}        :
                                                                          {stb_slots_ns_dsc_i[3], stb_slot3_addr_i[39:6]};

  assign next_biu_store_pa_hz_slot4[40:6] = (dcu_stb_req_dc3_i       &
                                             ~stb_slots_valid_i[4]   &
                                             (&stb_slots_valid_i[3:0])) ? {dcu_ns_dsc_dc3_i, dcu_pa_dc3_i[39:6]}        :
                                                                          {stb_slots_ns_dsc_i[4], stb_slot4_addr_i[39:6]};

  assign biu_pa_hz_en                     = (~&pf_stream_idle & |lf_descr_from_pf) | biu_lf_valid_active;

  assign biu_load_pa_hz_dc2_en            = biu_pa_hz_en                                                                 &
                                            ((dcu_load_dc1_i & dcu_leaving_dc1_i) | (dcu_load_dc2_i & ~dcu_leaving_dc2_i));

  assign biu_load_pa_hz_dc3_en            = biu_pa_hz_en                                                                 &
                                            ((dcu_load_dc2_i & dcu_leaving_dc2_i) | (dcu_load_dc3_i & ~biu_leaving_dc3_i));

  assign biu_store_pa_hz_slot0_en         = biu_pa_hz_en                                            &
                                            ((stb_slots_valid_i[0] & ~biu_store_pa_hz_slot0_valid) |
                                             (dcu_stb_req_dc3_i & ~stb_slots_valid_i[0]            ));

  assign biu_store_pa_hz_slot1_en         = biu_pa_hz_en                                                       &
                                            ((stb_slots_valid_i[1] & ~biu_store_pa_hz_slot1_valid)            |
                                             (dcu_stb_req_dc3_i & ~stb_slots_valid_i[1] & stb_slots_valid_i[0]));

  assign biu_store_pa_hz_slot2_en         = biu_pa_hz_en                                                            &
                                            ((stb_slots_valid_i[2] & ~biu_store_pa_hz_slot2_valid)                 |
                                             (dcu_stb_req_dc3_i & ~stb_slots_valid_i[2] & (&stb_slots_valid_i[1:0])));

  assign biu_store_pa_hz_slot3_en         = biu_pa_hz_en                                                            &
                                            ((stb_slots_valid_i[3] & ~biu_store_pa_hz_slot3_valid)                 |
                                             (dcu_stb_req_dc3_i & ~stb_slots_valid_i[3] & (&stb_slots_valid_i[2:0])));

  assign biu_store_pa_hz_slot4_en         = biu_pa_hz_en                                                            &
                                            ((stb_slots_valid_i[4] & ~biu_store_pa_hz_slot4_valid)                 |
                                             (dcu_stb_req_dc3_i & ~stb_slots_valid_i[4] & (&stb_slots_valid_i[3:0])));

  assign next_biu_load_pa_hz_dc2_valid    = biu_load_pa_hz_dc2_en                         |
                                            (biu_load_pa_hz_dc2_valid & ~dcu_leaving_dc2_i);

  assign next_biu_load_pa_hz_dc3_valid    = biu_load_pa_hz_dc3_en                         |
                                            (biu_load_pa_hz_dc3_valid & ~biu_leaving_dc3_i);

  assign next_biu_store_pa_hz_slot0_valid = biu_store_pa_hz_slot0_en                           |
                                            (biu_store_pa_hz_slot0_valid & stb_slots_valid_i[0]);

  assign next_biu_store_pa_hz_slot1_valid = biu_store_pa_hz_slot1_en                           |
                                            (biu_store_pa_hz_slot1_valid & stb_slots_valid_i[1]);

  assign next_biu_store_pa_hz_slot2_valid = biu_store_pa_hz_slot2_en                           |
                                            (biu_store_pa_hz_slot2_valid & stb_slots_valid_i[2]);

  assign next_biu_store_pa_hz_slot3_valid = biu_store_pa_hz_slot3_en                           |
                                            (biu_store_pa_hz_slot3_valid & stb_slots_valid_i[3]);

  assign next_biu_store_pa_hz_slot4_valid = biu_store_pa_hz_slot4_en                           |
                                            (biu_store_pa_hz_slot4_valid & stb_slots_valid_i[4]);

  always @(posedge clk)
    if (biu_load_pa_hz_dc2_en) begin
      biu_load_pa_hz_dc2 <= next_biu_load_pa_hz_dc2;
    end

  always @(posedge clk)
    if (biu_load_pa_hz_dc3_en) begin
      biu_load_pa_hz_dc3 <= next_biu_load_pa_hz_dc3;
    end

  always @(posedge clk)
    if (biu_store_pa_hz_slot0_en) begin
      biu_store_pa_hz_slot0 <= next_biu_store_pa_hz_slot0;
    end

  always @(posedge clk)
    if (biu_store_pa_hz_slot1_en) begin
      biu_store_pa_hz_slot1 <= next_biu_store_pa_hz_slot1;
    end

  always @(posedge clk)
    if (biu_store_pa_hz_slot2_en) begin
      biu_store_pa_hz_slot2 <= next_biu_store_pa_hz_slot2;
    end

  always @(posedge clk)
    if (biu_store_pa_hz_slot3_en) begin
      biu_store_pa_hz_slot3 <= next_biu_store_pa_hz_slot3;
    end

  always @(posedge clk)
    if (biu_store_pa_hz_slot4_en) begin
      biu_store_pa_hz_slot4 <= next_biu_store_pa_hz_slot4;
    end

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      biu_load_pa_hz_dc2_valid    <= 1'b0;
      biu_load_pa_hz_dc3_valid    <= 1'b0;
      biu_store_pa_hz_slot0_valid <= 1'b0;
      biu_store_pa_hz_slot1_valid <= 1'b0;
      biu_store_pa_hz_slot2_valid <= 1'b0;
      biu_store_pa_hz_slot3_valid <= 1'b0;
      biu_store_pa_hz_slot4_valid <= 1'b0;
    end else begin
      biu_load_pa_hz_dc2_valid    <= next_biu_load_pa_hz_dc2_valid;
      biu_load_pa_hz_dc3_valid    <= next_biu_load_pa_hz_dc3_valid;
      biu_store_pa_hz_slot0_valid <= next_biu_store_pa_hz_slot0_valid;
      biu_store_pa_hz_slot1_valid <= next_biu_store_pa_hz_slot1_valid;
      biu_store_pa_hz_slot2_valid <= next_biu_store_pa_hz_slot2_valid;
      biu_store_pa_hz_slot3_valid <= next_biu_store_pa_hz_slot3_valid;
      biu_store_pa_hz_slot4_valid <= next_biu_store_pa_hz_slot4_valid;
    end

  // Linefill masters index map: CCB (only hazard check), DC3, DC2, STB[4:0], PF

  // o Linefill master index 0: CCB (no Linefill request => only hazard check)

  assign master_valid[`CA53_BIU_CCB]          = 1'b1;
  assign master_hz_valid[`CA53_BIU_CCB]       = 1'b1;
  assign master_lf_req[`CA53_BIU_CCB]         = 1'b0;
  assign master_lf_addr[`CA53_BIU_CCB]        = {37{1'b0}};
  assign master_lf_addr_hz[`CA53_BIU_CCB]     = {{27{1'b0}}, dcu_ccb_index_i[13:6]};
  assign master_lf_way[`CA53_BIU_CCB]         = dcu_ccb_ways_i;
  assign master_lf_attrs[`CA53_BIU_CCB]       = {8{1'b0}};
  assign master_lf_type[`CA53_BIU_CCB]        = `CA53_BIU_LF_MASTER_NONE;

  // o Linefill master index 1: DC3

  assign master_valid[`CA53_BIU_DC3_LF]       = dcu_load_dc3_i;
  assign master_hz_valid[`CA53_BIU_DC3_LF]    = dcu_load_dc3_i & biu_load_pa_hz_dc3_valid;
  assign master_lf_req[`CA53_BIU_DC3_LF]      = dcu_lf_req_dc3_i & ~stb_must_drain & (~dcu_exclusive_dc3_i | ~biu_excl_lf_in_progress);
  assign master_lf_addr[`CA53_BIU_DC3_LF]     = {dcu_ns_dsc_dc3_i, dcu_pa_dc3_i[39:4]};
  assign master_lf_addr_hz[`CA53_BIU_DC3_LF]  = biu_load_pa_hz_dc3[40:6];
  assign master_lf_way[`CA53_BIU_DC3_LF]      = (4'h1 << dcu_lf_way_dc3_i);
  assign master_lf_attrs[`CA53_BIU_DC3_LF]    = dcu_attrs_dc3_i;
  assign master_lf_type[`CA53_BIU_DC3_LF]     = dcu_exclusive_dc3_i ? `CA53_BIU_LF_MASTER_DCU_LDREX :
                                                dcu_pldw_dc3_i      ? `CA53_BIU_LF_MASTER_DCU_PLDW  :
                                                                      `CA53_BIU_LF_MASTER_DCU;

  // o Linefill master index 2: DC2

  assign master_valid[`CA53_BIU_DC2_LF]       = dcu_load_dc2_i;
  assign master_hz_valid[`CA53_BIU_DC2_LF]    = dcu_load_dc2_i & biu_load_pa_hz_dc2_valid;
  assign master_lf_req[`CA53_BIU_DC2_LF]      = dcu_lf_req_dc2_i & ~stb_must_drain & (~dcu_exclusive_dc2_i | ~biu_excl_lf_in_progress);
  assign master_lf_addr[`CA53_BIU_DC2_LF]     = {dcu_ns_dsc_dc2_i, dcu_pa_dc2_i[39:4]};
  assign master_lf_addr_hz[`CA53_BIU_DC2_LF]  = biu_load_pa_hz_dc2[40:6];
  assign master_lf_way[`CA53_BIU_DC2_LF]      = (4'h1 << dcu_lf_way_dc2_i);
  assign master_lf_attrs[`CA53_BIU_DC2_LF]    = dcu_attrs_dc2_i;
  assign master_lf_type[`CA53_BIU_DC2_LF]     = dcu_exclusive_dc2_i ? `CA53_BIU_LF_MASTER_DCU_LDREX :
                                                                      `CA53_BIU_LF_MASTER_DCU;

  // o Linefill master index 3: TLB

  assign master_valid[`CA53_BIU_TLB_LF]       = 1'b1;
  assign master_hz_valid[`CA53_BIU_TLB_LF]    = 1'b1;
  assign master_lf_req[`CA53_BIU_TLB_LF]      = tlb_walk_lf_req_i & ~stb_must_drain;
  assign master_lf_addr[`CA53_BIU_TLB_LF]     = {tlb_walk_ns_dsc_i, tlb_walk_addr_i[39:4]};
  assign master_lf_addr_hz[`CA53_BIU_TLB_LF]  = {tlb_walk_ns_dsc_i, tlb_walk_addr_i[39:6]};
  assign master_lf_way[`CA53_BIU_TLB_LF]      = (4'h1 << tlb_walk_way_i);
  assign master_lf_attrs[`CA53_BIU_TLB_LF]    = tlb_walk_attrs_i;
  assign master_lf_type[`CA53_BIU_TLB_LF]     = `CA53_BIU_LF_MASTER_TLB;

  // o Linefill master index 4: STB slot 0

  assign master_valid[`CA53_BIU_STB0_LF]      = stb_slots_valid_i[0];
  assign master_hz_valid[`CA53_BIU_STB0_LF]   = stb_slots_valid_i[0] & biu_store_pa_hz_slot0_valid;
  assign master_lf_req[`CA53_BIU_STB0_LF]     = stb_lf_req_i[0];
  assign master_lf_addr[`CA53_BIU_STB0_LF]    = {stb_slots_ns_dsc_i[0], stb_slot0_addr_i[39:4]};
  assign master_lf_addr_hz[`CA53_BIU_STB0_LF] = biu_store_pa_hz_slot0;
  assign master_lf_way[`CA53_BIU_STB0_LF]     = (4'h1 << stb_slot0_way_i);
  assign master_lf_attrs[`CA53_BIU_STB0_LF]   = stb_slot0_attrs_i;
  assign master_lf_type[`CA53_BIU_STB0_LF]    = `CA53_BIU_LF_MASTER_STB;

  // o Linefill master index 5: STB slot 1

  assign master_valid[`CA53_BIU_STB1_LF]      = stb_slots_valid_i[1];
  assign master_hz_valid[`CA53_BIU_STB1_LF]   = stb_slots_valid_i[1] & biu_store_pa_hz_slot1_valid;
  assign master_lf_req[`CA53_BIU_STB1_LF]     = stb_lf_req_i[1];
  assign master_lf_addr[`CA53_BIU_STB1_LF]    = {stb_slots_ns_dsc_i[1], stb_slot1_addr_i[39:4]};
  assign master_lf_addr_hz[`CA53_BIU_STB1_LF] = biu_store_pa_hz_slot1;
  assign master_lf_way[`CA53_BIU_STB1_LF]     = (4'h1 << stb_slot1_way_i);
  assign master_lf_attrs[`CA53_BIU_STB1_LF]   = stb_slot1_attrs_i;
  assign master_lf_type[`CA53_BIU_STB1_LF]    = `CA53_BIU_LF_MASTER_STB;

  // o Linefill master index 6: STB slot 2

  assign master_valid[`CA53_BIU_STB2_LF]      = stb_slots_valid_i[2];
  assign master_hz_valid[`CA53_BIU_STB2_LF]   = stb_slots_valid_i[2] & biu_store_pa_hz_slot2_valid;
  assign master_lf_req[`CA53_BIU_STB2_LF]     = stb_lf_req_i[2];
  assign master_lf_addr[`CA53_BIU_STB2_LF]    = {stb_slots_ns_dsc_i[2], stb_slot2_addr_i[39:4]};
  assign master_lf_addr_hz[`CA53_BIU_STB2_LF] = biu_store_pa_hz_slot2;
  assign master_lf_way[`CA53_BIU_STB2_LF]     = (4'h1 << stb_slot2_way_i);
  assign master_lf_attrs[`CA53_BIU_STB2_LF]   = stb_slot2_attrs_i;
  assign master_lf_type[`CA53_BIU_STB2_LF]    = `CA53_BIU_LF_MASTER_STB;

  // o Linefill master index 7: STB slot 3

  assign master_valid[`CA53_BIU_STB3_LF]      = stb_slots_valid_i[3];
  assign master_hz_valid[`CA53_BIU_STB3_LF]   = stb_slots_valid_i[3] & biu_store_pa_hz_slot3_valid;
  assign master_lf_req[`CA53_BIU_STB3_LF]     = stb_lf_req_i[3];
  assign master_lf_addr[`CA53_BIU_STB3_LF]    = {stb_slots_ns_dsc_i[3], stb_slot3_addr_i[39:4]};
  assign master_lf_addr_hz[`CA53_BIU_STB3_LF] = biu_store_pa_hz_slot3;
  assign master_lf_way[`CA53_BIU_STB3_LF]     = (4'h1 << stb_slot3_way_i);
  assign master_lf_attrs[`CA53_BIU_STB3_LF]   = stb_slot3_attrs_i;
  assign master_lf_type[`CA53_BIU_STB3_LF]    = `CA53_BIU_LF_MASTER_STB;

  // o Linefill master index 8: STB slot 4

  assign master_valid[`CA53_BIU_STB4_LF]      = stb_slots_valid_i[4];
  assign master_hz_valid[`CA53_BIU_STB4_LF]   = stb_slots_valid_i[4] & biu_store_pa_hz_slot4_valid;
  assign master_lf_req[`CA53_BIU_STB4_LF]     = stb_lf_req_i[4];
  assign master_lf_addr[`CA53_BIU_STB4_LF]    = {stb_slots_ns_dsc_i[4], stb_slot4_addr_i[39:4]};
  assign master_lf_addr_hz[`CA53_BIU_STB4_LF] = biu_store_pa_hz_slot4;
  assign master_lf_way[`CA53_BIU_STB4_LF]     = (4'h1 << stb_slot4_way_i);
  assign master_lf_attrs[`CA53_BIU_STB4_LF]   = stb_slot4_attrs_i;
  assign master_lf_type[`CA53_BIU_STB4_LF]    = `CA53_BIU_LF_MASTER_STB;

  // o Linefill master index 9: PF (including the DC1 linefill requests)

  assign master_valid[`CA53_BIU_PF_LF]        = pf_lf_valid;
  assign master_hz_valid[`CA53_BIU_PF_LF]     = pf_lf_valid;
  assign master_lf_req[`CA53_BIU_PF_LF]       = pf_lf_req & ~dcu_stop_pf_i;
  assign master_lf_addr[`CA53_BIU_PF_LF]      = {pf_lf_addr[40:6], 2'b00};
  assign master_lf_addr_hz[`CA53_BIU_PF_LF]   = pf_lf_addr[40:6];
  assign master_lf_way[`CA53_BIU_PF_LF]       = pf_lf_way;
  assign master_lf_attrs[`CA53_BIU_PF_LF]     = pf_lf_attrs;
  assign master_lf_type[`CA53_BIU_PF_LF]      = pf_stream_lf_req_dc1_sel                                        ? `CA53_BIU_LF_MASTER_DCU     :
                                                (pf_lf_pldw & ~dpu_disable_data_prefetch_readunique_prev_cycle) ? `CA53_BIU_LF_MASTER_PF_PLDW :
                                                                                                                  `CA53_BIU_LF_MASTER_PF;

  // Rotate 90 degrees the lf_descr_match, lf_descr_index_match & lf_descr_index_way_match arrays

  generate
    for (index_i = 0; index_i < `CA53_BIU_LF_DESCR_NUM; index_i = index_i + 1) begin : gen_lf_descr_match_rot90_outer
      for (index_j = 0; index_j < `CA53_BIU_LF_MASTERS_NUM; index_j = index_j + 1) begin : gen_lf_descr_match_rot90_inner
        assign lf_descr_match[index_j][index_i]           = lf_descr_match_rot90[index_i][index_j];
        assign lf_descr_pf_match[index_j][index_i]        = lf_descr_pf_match_rot90[index_i][index_j];
        assign lf_descr_index_match[index_j][index_i]     = lf_descr_index_match_rot90[index_i][index_j];
        assign lf_descr_index_way_match[index_j][index_i] = lf_descr_index_way_match_rot90[index_i][index_j];
      end
    end
  endgenerate

  // Compute linefill descriptor hazard per each linefill master

  generate
    for (index_i = 0; index_i < `CA53_BIU_LF_MASTERS_NUM; index_i = index_i + 1) begin : gen_master_lf_match
      assign master_lf_descr_match[index_i] = (|lf_descr_match[index_i][`CA53_BIU_LF_DESCR_NUM-1:0]);
    end
  endgenerate

  // Compute index-way hazard per each linefill master

  generate
    for (index_i = 0; index_i < `CA53_BIU_LF_MASTERS_NUM; index_i = index_i + 1) begin : gen_master_lf_descr_index_way_hz_outer
      if (index_i <= `CA53_BIU_STB4_LF) begin : gen_master_lf_descr_index_way_hz_nested_0
         always @* begin : index_way_mux_0
           integer    index_k;
           reg [3:0]  tmp_master_lf_descr_index_match_way_merged;

           tmp_master_lf_descr_index_match_way_merged = {4{1'b0}};

           for (index_k = 0; index_k < `CA53_BIU_LF_DESCR_NUM; index_k = index_k + 1) begin
             tmp_master_lf_descr_index_match_way_merged = tmp_master_lf_descr_index_match_way_merged    |
                                                          ({4{lf_descr_index_match[index_i][index_k]}} &
                                                           lf_descr_way[index_k][3:0]                   );
           end

           master_lf_descr_index_match_way_merged[index_i][3:0] = tmp_master_lf_descr_index_match_way_merged;
         end

         assign master_lf_descr_index_way_hz[index_i] = &master_lf_descr_index_match_way_merged[index_i][3:0];
       end else begin : gen_master_lf_descr_index_way_hz_nested_0_else
         always @* begin : index_way_mux_1
           integer    index_k;
           reg [3:0]  tmp_master_lf_descr_index_match_way_merged;

           tmp_master_lf_descr_index_match_way_merged = {4{1'b0}};

           for (index_k = 0; index_k < `CA53_BIU_LF_DESCR_NUM; index_k = index_k + 1) begin
             tmp_master_lf_descr_index_match_way_merged = tmp_master_lf_descr_index_match_way_merged    |
                                                          ({4{lf_descr_index_match[index_i][index_k]}} &
                                                           lf_descr_way[index_k][3:0]                   );
           end

           master_lf_descr_index_match_way_merged[index_i][3:0] = tmp_master_lf_descr_index_match_way_merged;
         end

         assign master_lf_descr_index_way_hz[index_i] = |(master_lf_descr_index_match_way_merged[index_i][3:0] & master_lf_way[index_i]);
       end
    end
  endgenerate

  // Select the way per each linefill master request:
  // o the way requested by the initiator of the linefill, if no index/way linefill hazard [highest priority]
  // o the first way available for which there isn't an index/way linefill hazard          [lowest priority]

  generate
    for (index_i = `CA53_BIU_DC3_LF; index_i < `CA53_BIU_LF_MASTERS_NUM; index_i = index_i + 1) begin : gen_master_lf_way_new_outer
      for (index_j = 0; index_j < 4; index_j = index_j + 1) begin : gen_master_lf_way_new_inner
        if (index_j == 0) begin : gen_master_lf_way_new_nested_0
          assign master_lf_way_new[index_i][0] = ~master_lf_descr_index_match_way_merged[index_i][0];
        end else begin : gen_master_lf_way_new_nested_0_else
          assign master_lf_way_new[index_i][index_j] = ~master_lf_descr_index_match_way_merged[index_i][index_j]     &
                                                       (&master_lf_descr_index_match_way_merged[index_i][index_j-1:0]);
        end
      end
    end
  endgenerate

  generate
    for (index_i = `CA53_BIU_DC3_LF; index_i < `CA53_BIU_LF_MASTERS_NUM; index_i = index_i + 1) begin : gen_master_lf_way_final
      assign master_lf_way_final[index_i] = (|(master_lf_way[index_i] & master_lf_descr_index_match_way_merged[index_i])) ?
                                              master_lf_way_new[index_i] :
                                              master_lf_way[index_i];
    end
  endgenerate

  // Compute the STB hazards for the earliest slot

  assign stb_lf_earliest_slot_hz = |(stb_lf_earliest_slot_i                                             &
                                     (master_lf_descr_match[`CA53_BIU_STB4_LF:`CA53_BIU_STB0_LF]       |
                                      master_lf_descr_index_way_hz[`CA53_BIU_STB4_LF:`CA53_BIU_STB0_LF ]));

  // Compute the STB mask in order to prioritize the earliest STB slot, if no hazard.

  assign stb_priority_mask = stb_lf_earliest_slot_i | {5{stb_lf_earliest_slot_hz}};

  // Determine which linefill request requires access to the AR channel

  generate
    for (index_i = `CA53_BIU_DC3_LF; index_i < `CA53_BIU_LF_MASTERS_NUM; index_i = index_i + 1) begin : gen_master_lf_req_can_progress
      if (index_i < `CA53_BIU_STB0_LF) begin : gen_master_lf_req_can_progress_nested_0
        // index_i < `CA53_BIU_STB0_LF

        // Linefill request can progress if there is no linefill match hazard and
        // there is a way available to same L1 data cache index

        assign master_lf_req_hz[index_i]           = master_lf_descr_match[index_i]      |
                                                     master_lf_descr_index_way_hz[index_i];

        assign master_lf_req_can_progress[index_i] = master_lf_req[index_i]   &
                                                     ~master_lf_req_hz[index_i];

      end else if (index_i <= `CA53_BIU_STB4_LF) begin : gen_master_lf_req_can_progress_nested_0_else_0
        // `CA53_BIU_STB0_LF <= index_i <= `CA53_BIU_STB4_LF //

        // STB linefill can progress if it's the earliest slot and
        // there is no hazard, or if it's not the earliest slot but
        // the earliest slot has a hazard

        assign master_lf_req_hz[index_i]           = master_lf_descr_match[index_i]      |
                                                     master_lf_descr_index_way_hz[index_i];

        assign master_lf_req_can_progress[index_i] = master_lf_req[index_i]                       &
                                                     stb_priority_mask[index_i-`CA53_BIU_STB0_LF] &
                                                     ~master_lf_req_hz[index_i];

      end else begin : gen_master_lf_req_can_progress_nested_0_else_1
        // index_i > `CA53_BIU_STB4_LF//

        // PF linefill request can progress if there is no linefill match hazard
        // and no index-way hazard to same L1 data cache index

        assign master_lf_req_hz[index_i]           = master_lf_descr_match[index_i]      |
                                                     master_lf_descr_index_way_hz[index_i];

        assign master_lf_req_can_progress[index_i] = master_lf_req[index_i]   &
                                                     ~master_lf_req_hz[index_i];

      end
    end
  endgenerate

  // Linefill master request winning arbiter
  // o priority: DC3 > DC2 > TLB > STB[4:0] > PF[3:0] (where ">" means priority higher than)

  // Distribute the main linefill request arbiter in order to ease the timing closure:
  // o branch 0: DC3, DC2 and TLB
  // o branch 1: STB[4:0]
  // o branch 2: PF[3:0] and DC1

  // Linefill request arbitration winner selection for DC3, DC2 and TLB (ie branch 0 of the main linefill request arbiter)

  generate
    for (index_i = `CA53_BIU_DC3_LF; index_i <= `CA53_BIU_TLB_LF; index_i = index_i + 1) begin : gen_master_lf_req_0
      if (index_i == 1) begin : gen_master_lf_req_0_nested_0
        assign master_lf_req_sel[0][index_i] = master_lf_req_can_progress[`CA53_BIU_DC3_LF];
      end else begin : gen_master_lf_req_nested_0_else
        assign master_lf_req_sel[0][index_i] = master_lf_req_can_progress[index_i] & ~(|master_lf_req_can_progress[index_i-1:`CA53_BIU_DC3_LF]);
      end
    end
  endgenerate

  // DC3, DC2 and TLB linefill request arbitration winner mux

  `CA53_BIU_ONEHOT_MUX(biu_lf_addr[0]  , 37, 4, master_lf_req_sel[0], master_lf_addr,      3, 1, g_mux_lf_addr_req_0)
  `CA53_BIU_ONEHOT_MUX(biu_lf_attrs[0] ,  8, 0, master_lf_req_sel[0], master_lf_attrs,     3, 1, g_mux_lf_attrs_req_0)
  `CA53_BIU_ONEHOT_MUX(biu_lf_way[0]   ,  4, 0, master_lf_req_sel[0], master_lf_way_final, 3, 1, g_mux_lf_way_req_0)
  `CA53_BIU_ONEHOT_MUX(biu_lf_master[0],  3, 0, master_lf_req_sel[0], master_lf_type,      3, 1, g_mux_lf_type_req_0)

  // Linefill request arbitration winner selection for STB[4:0] (ie branch 1 of the main linefill request arbiter)

  generate
    for (index_i = `CA53_BIU_STB0_LF; index_i <= `CA53_BIU_STB4_LF; index_i = index_i + 1) begin : gen_master_lf_req_1
      if (index_i == `CA53_BIU_STB0_LF) begin : gen_master_lf_req_1_nested_0
        assign master_lf_req_sel[1][index_i] = master_lf_req_can_progress[`CA53_BIU_STB0_LF];
      end else begin : gen_master_lf_req_nested_1_else
        assign master_lf_req_sel[1][index_i] = master_lf_req_can_progress[index_i] & ~(|master_lf_req_can_progress[index_i-1:`CA53_BIU_STB0_LF]);
      end
    end
  endgenerate

  // STB[4:0] linefill request arbitration winner mux

  `CA53_BIU_ONEHOT_MUX(biu_lf_addr[1]  , 37, 4, master_lf_req_sel[1], master_lf_addr,      5, 4, g_mux_lf_addr_req_1)
  `CA53_BIU_ONEHOT_MUX(biu_lf_attrs[1] ,  8, 0, master_lf_req_sel[1], master_lf_attrs,     5, 4, g_mux_lf_attrs_req_1)
  `CA53_BIU_ONEHOT_MUX(biu_lf_way[1]   ,  4, 0, master_lf_req_sel[1], master_lf_way_final, 5, 4, g_mux_lf_way_req_1)
  `CA53_BIU_ONEHOT_MUX(biu_lf_master[1],  3, 0, master_lf_req_sel[1], master_lf_type,      5, 4, g_mux_lf_type_req_1)

  // Linefill request arbitration winner selection for PF[3:0] (ie branch 2 of the main linefill request arbiter)

  assign master_lf_req_sel[2][`CA53_BIU_PF_LF] = master_lf_req_can_progress[`CA53_BIU_PF_LF];

  // PF[3:0] linefill request arbitration winner

  assign biu_lf_addr[2]   = master_lf_addr     [`CA53_BIU_PF_LF][40:4];
  assign biu_lf_attrs[2]  = master_lf_attrs    [`CA53_BIU_PF_LF][7:0];
  assign biu_lf_way[2]    = master_lf_way_final[`CA53_BIU_PF_LF][3:0];
  assign biu_lf_master[2] = master_lf_type     [`CA53_BIU_PF_LF][2:0];

  assign biu_lf_req_no_hz = master_lf_req[`CA53_BIU_PF_LF:`CA53_BIU_DC3_LF] & ~master_lf_req_hz[`CA53_BIU_PF_LF:`CA53_BIU_DC3_LF];

  assign biu_lf_req       = (|biu_lf_req_no_hz[`CA53_BIU_PF_LF:`CA53_BIU_DC3_LF]) & lf_descr_available;

  // Select if the STB[4:0] gets priority for the linefill request arbitration

  assign biu_lf_req_arb_stb_sel = ~|biu_lf_req_no_hz[`CA53_BIU_TLB_LF:`CA53_BIU_DC3_LF];

  // Select if the PF gets priority for the linefill request arbitration

  assign biu_lf_req_arb_pf_sel = ~|biu_lf_req_no_hz[`CA53_BIU_STB4_LF:`CA53_BIU_DC3_LF];

  // Compute the winner outputs of the linefill request arbitration

  assign biu_lf_addr_arb_out   = biu_lf_addr[0]                                  |
                                 (biu_lf_addr[1] & {37{biu_lf_req_arb_stb_sel}}) |
                                 (biu_lf_addr[2] & {37{biu_lf_req_arb_pf_sel}}   );
  assign biu_lf_attrs_arb_out  = biu_lf_attrs[0]                                 |
                                 (biu_lf_attrs[1] & {8{biu_lf_req_arb_stb_sel}}) |
                                 (biu_lf_attrs[2] & {8{biu_lf_req_arb_pf_sel}}   );
  assign biu_lf_way_arb_out    = biu_lf_way[0]                                 |
                                 (biu_lf_way[1] & {4{biu_lf_req_arb_stb_sel}}) |
                                 (biu_lf_way[2] & {4{biu_lf_req_arb_pf_sel}}   );
  assign biu_lf_master_arb_out = {pf_lf_stream_id[1:0] & {2{biu_lf_req_arb_pf_sel}},
                                  (biu_lf_master[0]                                 |
                                   (biu_lf_master[1] & {3{biu_lf_req_arb_stb_sel}}) |
                                   (biu_lf_master[2] & {3{biu_lf_req_arb_pf_sel}}   ))};

  // Register the last LF address winner of the LF request arbiter and thus avoid
  // toggling it when there isn't a potential LF issued to the AR channel.
  // (ie dynamic power improvement on the prefetch stride detection at the LF descriptor level)

  always @(posedge clk)
    if (biu_lf_req) begin
      biu_lf_addr_last <= biu_lf_addr_arb_out[40:6];
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign pf_lf_active_o    = |pf_stream_lf_active_early[`CA53_BIU_PF_STREAM_NUM-1:0];
  assign biu_lf_req_o      = biu_lf_req;
  assign biu_lf_addr_o     = biu_lf_addr_arb_out[39:4];
  assign biu_lf_ns_dsc_o   = biu_lf_addr_arb_out[40];
  assign biu_lf_attrs_o    = biu_lf_attrs_arb_out;
  assign biu_lf_way_o      = biu_lf_way_arb_out;
  assign biu_lf_descr_id_o = `CA53_BIU_ONEHOT2BIN_8_3(lf_descr_available_sel);
  assign biu_lf_master_o   = biu_lf_master_arb_out[2:0];

  //------------------------------------------------------------------------------
  // CCB hazard interface
  //------------------------------------------------------------------------------

  generate
    for (index_i = 0; index_i < `CA53_BIU_LF_DESCR_NUM; index_i = index_i + 1) begin : gen_ccb_lf_hazard
      assign biu_ccb_lf_hazard[index_i] = lf_descr_index_way_match[`CA53_BIU_CCB][index_i] &
                                          lf_descr_evict_done[index_i]                     &
                                          (|lf_descr_chunk_fetched_from_scu[index_i]       );
    end
  endgenerate

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_ccb_lf_hazard_o = |biu_ccb_lf_hazard;

  //------------------------------------------------------------------------------
  // TLB LF hazard
  //------------------------------------------------------------------------------

  // Suppress the TLB load hit which does not have the requested chunk allocated into the cache
  // Assert the TLB LF hazard for lines matching the TLB address

  always @* begin : tlb_ld_hz_mux
    integer index_k;
    reg     tmp_biu_suppress_load_hit_tlb;
    reg     tmp_biu_walk_lf_hazard;

    tmp_biu_suppress_load_hit_tlb = 1'b0;
    tmp_biu_walk_lf_hazard        = 1'b0;

    for (index_k = 0; index_k < `CA53_BIU_LF_DESCR_NUM; index_k = index_k + 1) begin
      tmp_biu_suppress_load_hit_tlb = tmp_biu_suppress_load_hit_tlb                         |
                                      (lf_descr_match[`CA53_BIU_TLB_LF][index_k]          &
                                       lf_descr_tag_done[index_k]                         &
                                       ~|((lf_descr_chunk_allocated_from_stb[index_k] |
                                           lf_descr_chunk_allocated_from_biu[index_k]  ) &
                                          ~{4{lf_descr_err_from_scu[index_k]}}           &
                                          (4'h1 << tlb_walk_addr_i[5:4]                   )));
      tmp_biu_walk_lf_hazard        = tmp_biu_walk_lf_hazard                  |
                                      lf_descr_match[`CA53_BIU_TLB_LF][index_k];
    end

    biu_suppress_tlb_hit = tmp_biu_suppress_load_hit_tlb;
    biu_walk_lf_hazard   = tmp_biu_walk_lf_hazard;
  end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_walk_lf_hazard_o   = biu_walk_lf_hazard;
  assign biu_suppress_tlb_hit_o = biu_suppress_tlb_hit;

  //------------------------------------------------------------------------------
  // DCU linefills in progress
  //------------------------------------------------------------------------------

  // Suppress the DC2 load hit which does not have the requested chunk allocated into the cache

  always @* begin : dc2_ld_hz_mux_0
    integer index_k;
    reg     tmp_biu_suppress_load_hit_dc2;

    tmp_biu_suppress_load_hit_dc2 = 1'b0;

    for (index_k = 0; index_k < `CA53_BIU_LF_DESCR_NUM; index_k = index_k + 1) begin
      tmp_biu_suppress_load_hit_dc2 = tmp_biu_suppress_load_hit_dc2                         |
                                      (lf_descr_match[`CA53_BIU_DC2_LF][index_k]          &
                                       lf_descr_tag_done[index_k]                         &
                                       ~|((lf_descr_chunk_allocated_from_stb[index_k] |
                                           lf_descr_chunk_allocated_from_biu[index_k]  ) &
                                          ~{4{lf_descr_err_from_scu[index_k]}}           &
                                          (4'h1 << dcu_pa_dc2_i[5:4]                      )));
    end

    biu_suppress_load_hit_dc2 = tmp_biu_suppress_load_hit_dc2;
  end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_lf_in_progress_o        = lf_descr_valid;
  assign biu_suppress_load_hit_dc2_o = biu_suppress_load_hit_dc2;

  //------------------------------------------------------------------------------
  // DC2 linefill ready (used to retire the PLD L1 instructions)
  //------------------------------------------------------------------------------

  assign biu_lf_ready_dc2 = // DC2 LF descr match
                            (|lf_descr_match[`CA53_BIU_DC2_LF][`CA53_BIU_LF_DESCR_NUM-1:0]);

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_lf_ready_dc2_o = biu_lf_ready_dc2;

  //------------------------------------------------------------------------------
  // DC3 linefill next ready (used to retire the PLD L1 instructions)
  //------------------------------------------------------------------------------

  // Detect if there are at least two linefill descriptors available, and thus guarantee an eventual PLD L1 next clock cycle.
  // The potential linefill initiated/released into the current clock cycle it is not factorized in order to ease the timing closure.

  assign lf_descr_at_least_two_available = ~(lf_descr_valid == 8'b01111111) &
                                           ~(lf_descr_valid == 8'b10111111) &
                                           ~(lf_descr_valid == 8'b11011111) &
                                           ~(lf_descr_valid == 8'b11101111) &
                                           ~(lf_descr_valid == 8'b11110111) &
                                           ~(lf_descr_valid == 8'b11111011) &
                                           ~(lf_descr_valid == 8'b11111101) &
                                           ~(lf_descr_valid == 8'b11111110) &
                                           ~(lf_descr_valid == 8'b11111111  );

  // Detect if there is at least one way available to the same index, and thus guarantee an eventual PLD L1 next clock cycle.
  // The potential linefill initiated/released into the current clock cycle it is not factorized in order to ease the timing closure.

  assign index_way_available = ~&master_lf_descr_index_match_way_merged[`CA53_BIU_DC2_LF][3:0];

  assign biu_lf_next_ready_dc3 = (// DC2 moving to DC3
                                  dcu_leaving_dc2_i                        &
                                  // AR channel not blocked
                                  ~ar_block_i                              &
                                  // AR credits available
                                  (ar_credits_used_i < 4'h7)               &
                                  // LFs descriptors available
                                  lf_descr_at_least_two_available          &
                                  // STB DVM request not pending
                                  // (DVM multipart not factorized in order to ease the timing closure)
                                  ~(stb_ar_req_i & stb_is_dvm_i)           &
                                  // DC2 LF request index-way available
                                  index_way_available                      &
                                  // DC3 linefill request not asserted
                                  ~dcu_lf_req_dc3_i                         )                    |
                                 (// DC2 not moving to DC3
                                  ~dcu_leaving_dc2_i                                            &
                                  // LF descr match
                                  (|lf_descr_match[`CA53_BIU_DC3_LF][`CA53_BIU_LF_DESCR_NUM-1:0]));

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_lf_next_ready_dc3_o = biu_lf_next_ready_dc3;

  //------------------------------------------------------------------------------
  // STB cacheable/hazards/RA interfaces
  //------------------------------------------------------------------------------

  // Compute biu_lf_hazard

  assign biu_lf_hazard = master_lf_descr_match[`CA53_BIU_STB4_LF:`CA53_BIU_STB0_LF];

  // Compute biu_lf_real_hazard

  generate
    for (index_i = `CA53_BIU_STB0_LF; index_i <= `CA53_BIU_STB4_LF; index_i = index_i + 1) begin : gen_biu_lf_real_hazard
      always @* begin : stb_ld_hz_mux_0
        integer index_k;
        reg     tmp_biu_lf_real_hazard;

        tmp_biu_lf_real_hazard = 1'b0;

        for (index_k = 0; index_k < `CA53_BIU_LF_DESCR_NUM; index_k = index_k + 1) begin
          tmp_biu_lf_real_hazard = tmp_biu_lf_real_hazard             |
                                   (lf_descr_match[index_i][index_k] &
                                    (~lf_descr_tag_done[index_k] |
                                     ~lf_descr_unique[index_k]       ));
        end

        biu_lf_real_hazard[index_i] = tmp_biu_lf_real_hazard;
      end
    end
  endgenerate

  // Compute biu_lf_hazard_way_slot/biu_lf_hazard_migratory/biu_lf_can_merge

  generate
    for (index_i = `CA53_BIU_STB0_LF; index_i <= `CA53_BIU_STB4_LF; index_i = index_i + 1) begin : gen_biu_lf_hazard_way_slot
      always @* begin : stb_ld_hz_mux_1
        integer   index_k;
        reg [1:0] tmp_biu_lf_hazard_way_slot;
        reg       tmp_biu_lf_hazard_migratory;
        reg       tmp_biu_lf_can_merge;
        reg       tmp_biu_lf_serialized;

        tmp_biu_lf_hazard_way_slot  = 2'b00;
        tmp_biu_lf_hazard_migratory = 1'b0;
        tmp_biu_lf_can_merge        = 1'b0;
        tmp_biu_lf_serialized       = 1'b0;
        
        for (index_k = 0; index_k < `CA53_BIU_LF_DESCR_NUM; index_k = index_k + 1) begin
          tmp_biu_lf_hazard_way_slot  = tmp_biu_lf_hazard_way_slot                  |
                                        ({2{lf_descr_match[index_i][index_k]}}    &
                                         `CA53_BIU_ONEHOT2BIN(lf_descr_way[index_k]));
          tmp_biu_lf_hazard_migratory = tmp_biu_lf_hazard_migratory        |
                                        (lf_descr_match[index_i][index_k] &
                                         lf_descr_migratory[index_k]       );
          tmp_biu_lf_can_merge        = tmp_biu_lf_can_merge                                         |
                                        (lf_descr_match[index_i][index_k]                           &
                                         lf_descr_stb_can_merge[index_k][index_i-`CA53_BIU_STB0_LF] &
                                         lf_descr_unique[index_k]                                    );
          tmp_biu_lf_serialized       = tmp_biu_lf_serialized                        |
                                        (lf_descr_match[index_i][index_k]           &
                                         (|lf_descr_chunk_fetched_from_scu[index_k] ));
        end

        biu_lf_hazard_way_slot[index_i]  = tmp_biu_lf_hazard_way_slot;
        biu_lf_hazard_migratory[index_i] = tmp_biu_lf_hazard_migratory;
        biu_lf_can_merge[index_i]        = tmp_biu_lf_can_merge;
        biu_lf_serialized[index_i]       = tmp_biu_lf_serialized;
      end
    end
  endgenerate

  // Compute biu_ev_hazard

  // The BIU raises an eviction hazard if an STB slot matches the index and
  // way of a linefill that received and external abort.

  generate
    for (index_i = `CA53_BIU_STB0_LF; index_i <= `CA53_BIU_STB4_LF; index_i = index_i + 1) begin : gen_biu_ev_hazard
      always @* begin : stb_ld_hz_mux_2
        integer indek_k;
        reg     tmp_biu_ev_hazard;

        tmp_biu_ev_hazard = 1'b0;

        for (indek_k = 0; indek_k < `CA53_BIU_LF_DESCR_NUM; indek_k = indek_k + 1) begin
          tmp_biu_ev_hazard = tmp_biu_ev_hazard                            |
                              (lf_descr_index_way_match[index_i][indek_k] &
                               lf_descr_err_from_scu[indek_k]              );
        end

        biu_ev_hazard[index_i] = tmp_biu_ev_hazard;
      end
    end
  endgenerate

  // Compute biu_dirty_lf_in_progress

  always @* begin : stb_ld_hz_mux_3
    integer indek_k;
    reg     tmp_biu_dirty_lf_in_progress;

    tmp_biu_dirty_lf_in_progress = 1'b0;

    for (indek_k = 0; indek_k < `CA53_BIU_LF_DESCR_NUM; indek_k = indek_k + 1) begin
      tmp_biu_dirty_lf_in_progress = tmp_biu_dirty_lf_in_progress                |
                                     (lf_descr_valid[indek_k]                   &
                                      |lf_descr_chunk_allocated_from_stb[indek_k]);
    end

    biu_dirty_lf_in_progress = tmp_biu_dirty_lf_in_progress;
  end

  // Outstanding exclusive linefill transaction

  assign biu_excl_lf_in_progress = |(lf_descr_valid & lf_descr_exclusive);

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_lf_hazard_o            = biu_lf_hazard;
  assign biu_lf_hazard_migratory_o  = biu_lf_hazard_migratory[`CA53_BIU_STB4_LF:`CA53_BIU_STB0_LF];
  assign biu_lf_real_hazard_o       = biu_lf_real_hazard[`CA53_BIU_STB4_LF:`CA53_BIU_STB0_LF];
  assign biu_lf_hazard_way_slot0_o  = biu_lf_hazard_way_slot[`CA53_BIU_STB0_LF];
  assign biu_lf_hazard_way_slot1_o  = biu_lf_hazard_way_slot[`CA53_BIU_STB1_LF];
  assign biu_lf_hazard_way_slot2_o  = biu_lf_hazard_way_slot[`CA53_BIU_STB2_LF];
  assign biu_lf_hazard_way_slot3_o  = biu_lf_hazard_way_slot[`CA53_BIU_STB3_LF];
  assign biu_lf_hazard_way_slot4_o  = biu_lf_hazard_way_slot[`CA53_BIU_STB4_LF];
  assign biu_lf_serialized_o        = biu_lf_serialized;
  assign biu_lf_can_merge_o         = biu_lf_can_merge[`CA53_BIU_STB4_LF:`CA53_BIU_STB0_LF];
  assign biu_ev_hazard_o            = biu_ev_hazard[`CA53_BIU_STB4_LF:`CA53_BIU_STB0_LF];
  assign biu_dirty_lf_in_progress_o = biu_dirty_lf_in_progress;
  assign biu_excl_lf_in_progress_o  = biu_excl_lf_in_progress;

  //-----------------------------------------------------------------------------
  // Read allocate mode
  //-----------------------------------------------------------------------------

  // Provide information if linefills have had all bytes merged into by the STB

  assign lf_descr_inc_ramode_o   = (|lf_descr_inc_ramode);
  assign lf_descr_leave_ramode_o = (|lf_descr_leave_ramode);

  //------------------------------------------------------------------------------
  // Imprecise aborts
  //------------------------------------------------------------------------------

  // Merge the imprecise abort info from all linefill descriptors

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign linefill_imp_abort_o = |lf_descr_imp_abort;
  assign linefill_imp_fault_o = {// ECC fault
                                 |(lf_descr_imp_abort & lf_descr_imp_fault_ecc),
                                 // DEC fault
                                 |(lf_descr_imp_abort & lf_descr_imp_fault_dec)};

  //------------------------------------------------------------------------------
  // BIU's L1 data cache allocation management interconnect
  //------------------------------------------------------------------------------

  // Pack the linefill descriptors content (DCU allocation management)

  generate
    for (index_i = 0; index_i < `CA53_BIU_LF_DESCR_NUM; index_i = index_i + 1) begin : gen_unpack_lf_descr_arrays
      assign lf_descr_addr_packed                     [34*index_i+33:34*index_i] = lf_descr_addr                     [index_i];
      assign lf_descr_way_packed                      [4*index_i+3:4*index_i]    = lf_descr_way                      [index_i];
      assign lf_descr_chunk_fetched_from_scu_packed   [4*index_i+3:4*index_i]    = lf_descr_chunk_fetched_from_scu   [index_i];
      assign lf_descr_chunk_allocated_from_stb_packed [4*index_i+3:4*index_i]    = lf_descr_chunk_allocated_from_stb [index_i];
      assign lf_descr_chunk_need_release_packed       [4*index_i+3:4*index_i]    = lf_descr_chunk_need_release       [index_i];
      assign lf_descr_match_stb_packed                [5*index_i+4:5*index_i]    = {lf_descr_match[`CA53_BIU_STB4_LF][index_i],
                                                                                    lf_descr_match[`CA53_BIU_STB3_LF][index_i],
                                                                                    lf_descr_match[`CA53_BIU_STB2_LF][index_i],
                                                                                    lf_descr_match[`CA53_BIU_STB1_LF][index_i],
                                                                                    lf_descr_match[`CA53_BIU_STB0_LF][index_i]};
      assign lf_descr_attrs_packed                    [8*index_i+7:8*index_i]    = lf_descr_attrs                    [index_i];
    end
  endgenerate

  // Route the biu_alloc_dirty_req_m1 and dcu_alloc_ack_m1_i
  // to the corresponding linefill descriptor

  assign lf_descr_last_pend_m1 = {`CA53_BIU_LF_DESCR_NUM{biu_alloc_last_m1}} & biu_alloc_lf_descr_m1;
  assign lf_descr_ack_m1       = {`CA53_BIU_LF_DESCR_NUM{dcu_alloc_ack_m1_i}} & biu_alloc_lf_descr_m1;

  // L1 data cache chunk allocation pending in M0

  generate
    for (index_i = 0; index_i < `CA53_BIU_LF_DESCR_NUM; index_i = index_i + 1) begin : gen_lf_descr_chunk_pend_m0
      assign lf_descr_chunk_pend_m0[index_i] = biu_alloc_chunk_req_m0            &
                                               {4{biu_alloc_lf_descr_m0[index_i]}};
    end
  endgenerate

  // L1 data cache chunk allocation pending in M1

  generate
    for (index_i = 0; index_i < `CA53_BIU_LF_DESCR_NUM; index_i = index_i + 1) begin : gen_lf_descr_chunk_pend_m1
      assign lf_descr_chunk_pend_m1[index_i] = biu_alloc_chunk_req_m1            &
                                               {4{biu_alloc_lf_descr_m1[index_i]}};
    end
  endgenerate

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign lf_descr_evict_done_o    = lf_descr_evict_done;

  assign biu_alloc_addr_m0_o      = biu_alloc_addr_m0;
  assign biu_alloc_ns_dsc_m0_o    = biu_alloc_ns_dsc_m0;
  assign biu_alloc_lf_descr_m0_o  = biu_alloc_lf_descr_m0;
  assign biu_alloc_chunk_req_m0_o = biu_alloc_chunk_req_m0;
  assign biu_alloc_lf_descr_m1_o  = biu_alloc_lf_descr_m1;
  assign biu_alloc_chunk_req_m1_o = biu_alloc_chunk_req_m1;

  //-----------------------------------------------------------------------------
  // Determine which descriptors are fetching data for the TLB/DC2/DC3.
  // This is used to forward data from the read buffers to their destination
  // before allocation into the L1 data cache.
  //-----------------------------------------------------------------------------

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  generate
    for (index_i = 0; index_i < `CA53_BIU_LF_DESCR_NUM; index_i = index_i + 1) begin : gen_lf_descr_for_tlb_dc2_dc3
      assign lf_descr_for_tlb_o[index_i] = lf_descr_valid[index_i]                                   &
                                           `CA53_BIU_LF_FOR_TLB_LD_PENDING(lf_descr_master[index_i]) &
                                           `CA53_MEM_COHERENT(tlb_walk_attrs_i);
      assign lf_descr_for_dc2_o[index_i] = lf_descr_match[`CA53_BIU_DC2_LF][index_i]                                    &
                                           ~|(lf_descr_chunk_allocated_from_stb[index_i] & (4'h1 << dcu_pa_dc2_i[5:4])) &
                                           `CA53_MEM_COHERENT(dcu_attrs_dc2_i);
      assign lf_descr_for_dc3_o[index_i] = lf_descr_match[`CA53_BIU_DC3_LF][index_i]                                    &
                                           ~|(lf_descr_chunk_allocated_from_stb[index_i] & (4'h1 << dcu_pa_dc3_i[5:4])) &
                                           `CA53_MEM_COHERENT(dcu_attrs_dc3_i);
    end
  endgenerate

  //-----------------------------------------------------------------------------
  // Data prefetch management
  //-----------------------------------------------------------------------------

  //-----------------------------------------------------------------------------
  // Register the DPU prefetch configuration inputs
  //-----------------------------------------------------------------------------

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dpu_enable_data_prefetch_prev_cycle                 <= 3'b000;
      dpu_enable_data_prefetch_streams_prev_cycle         <= 2'b00;
      dpu_data_prefetch_stride_detect_prev_cycle          <= 1'b0;
      dpu_disable_data_prefetch_stores_pattern_prev_cycle <= 1'b0;
      dpu_disable_data_prefetch_readunique_prev_cycle     <= 1'b0;
    end else begin
      dpu_enable_data_prefetch_prev_cycle                 <= dpu_enable_data_prefetch_i;
      dpu_enable_data_prefetch_streams_prev_cycle         <= dpu_enable_data_prefetch_streams_i;
      dpu_data_prefetch_stride_detect_prev_cycle          <= dpu_data_prefetch_stride_detect_i;
      dpu_disable_data_prefetch_stores_pattern_prev_cycle <= dpu_disable_data_prefetch_stores_pattern_i;
      dpu_disable_data_prefetch_readunique_prev_cycle     <= dpu_disable_data_prefetch_readunique_i;
    end

  //-----------------------------------------------------------------------------
  // The BIU stores a copy of the TLB memory granule, and uses that copy to detect
  // a prefetch crossing a page boundary. The BIU's copy of the granule is always
  // the same or smaller than the granule used for the translation of any store
  // in the STB. The copy is updated when:
  // o no STB slot valid;
  // o STB not empty and the new memory granule is lower than the copy.
  //-----------------------------------------------------------------------------

  assign tlb_mem_granule_cpy_en = (~|stb_slots_valid_i)                   |
                                  (tlb_mem_granule_i < tlb_mem_granule_cpy);

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      tlb_mem_granule_cpy <= 2'b00;
    end else if (tlb_mem_granule_cpy_en) begin
      tlb_mem_granule_cpy <= tlb_mem_granule_i;
    end

  //-----------------------------------------------------------------------------
  // PF streams abort ctrl
  //-----------------------------------------------------------------------------

  // Register the DPU WFX drain request/DCU stop prefetchers in order to ease the timing closure

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      gov_wfx_drain_req_prev_cycle <= 1'b0;
      dcu_stop_pf_prev_cycle       <= 1'b0;
    end else begin
      gov_wfx_drain_req_prev_cycle <= gov_wfx_drain_req_i;
      dcu_stop_pf_prev_cycle       <= dcu_stop_pf_i;
    end

  assign dpu_enable_data_prefetch_streams_abort_mask = (dpu_enable_data_prefetch_prev_cycle == 3'b000)        ? 4'b1111 :
                                                       (dpu_enable_data_prefetch_streams_prev_cycle == 2'b00) ? 4'b1110 :
                                                       (dpu_enable_data_prefetch_streams_prev_cycle == 2'b01) ? 4'b1100 :
                                                       (dpu_enable_data_prefetch_streams_prev_cycle == 2'b10) ? 4'b1000 :
                                                                                                                4'b0000;

  assign pf_streams_drop = |{// D-cache off
                             ~dpu_dcache_on_i,
                             // WFI or WFE instruction is in progress
                             gov_wfx_drain_req_prev_cycle,
                             // TLB memory granule being changed
                             (tlb_mem_granule_cpy ^ tlb_mem_granule_i),
                             // DSB instruction is committed
                             dcu_stop_pf_prev_cycle,
                             // An external abort is seen on a linefill to any linefill descriptor
                             (lf_descr_err_from_scu & lf_descr_valid)};

  assign pf_stream_pldw_abort = ~pf_stream_idle[`CA53_BIU_PF_STREAM_NUM-1:0]   &
                                pf_stream_lf_pldw[`CA53_BIU_PF_STREAM_NUM-1:0] &
                                {`CA53_BIU_PF_STREAM_NUM{biu_read_alloc_pend_i}};

  assign pf_stream_abort = dpu_enable_data_prefetch_streams_abort_mask |
                           pf_stream_pldw_abort                        |
                           {`CA53_BIU_PF_STREAM_NUM{pf_streams_drop}   };

  //-----------------------------------------------------------------------------
  // Linefill descriptors stride forward arbiter:
  // o get the lowest physical index of the LF descriptors w/ stride detected
  //   per each PF counter value bin
  // o give the priority to the branch with higher PF counter value bin
  //-----------------------------------------------------------------------------

  generate
    for (index_i = 0; index_i < 3; index_i = index_i + 1) begin : gen_arb_lf_descr_pf_stride_egress_en_pri_outer_0
      for (index_j = 0; index_j < `CA53_BIU_LF_DESCR_NUM; index_j = index_j + 1) begin : gen_arb_lf_descr_pf_stride_egress_en_pri_inner_0
        assign lf_descr_pf_stride_egress_en_pri[index_i][index_j] = lf_descr_pf_stride_egress_en[index_j] & (lf_descr_pf_stride_egress_cnt[index_j] == index_i[1:0]);
      end
    end
  endgenerate

  generate
    for (index_i = 0; index_i < 3; index_i = index_i + 1) begin : gen_arb_lf_descr_pf_stride_egress_en_pri_sel_outer_0
      for (index_j = 0; index_j < `CA53_BIU_LF_DESCR_NUM; index_j = index_j + 1) begin : gen_arb_lf_descr_pf_stride_egress_en_pri_sel_0
        if (index_j == 0) begin : gen_arb_lf_descr_pf_stride_egress_en_pri_sel_0_nested_0
          assign lf_descr_pf_stride_egress_en_pri_sel[index_i][0] = lf_descr_pf_stride_egress_en_pri[index_i][0];
        end else begin : gen_arb_lf_descr_pf_stride_egress_en_pri_sel_0_else
          assign lf_descr_pf_stride_egress_en_pri_sel[index_i][index_j] = lf_descr_pf_stride_egress_en_pri[index_i][index_j] & ~(|lf_descr_pf_stride_egress_en_pri[index_i][index_j-1:0]);
        end
      end
    end
  endgenerate

  assign lf_descr_pf_stride_egress_en_sel = lf_descr_pf_stride_egress_en_pri_sel[2][`CA53_BIU_LF_DESCR_NUM-1:0]                           |
                                            (lf_descr_pf_stride_egress_en_pri_sel[1][`CA53_BIU_LF_DESCR_NUM-1:0]                       &
                                             {`CA53_BIU_LF_DESCR_NUM{~|lf_descr_pf_stride_egress_en_pri[2][`CA53_BIU_LF_DESCR_NUM-1:0]}}) |
                                            (lf_descr_pf_stride_egress_en_pri_sel[0][`CA53_BIU_LF_DESCR_NUM-1:0]                         &
                                             {`CA53_BIU_LF_DESCR_NUM{~|lf_descr_pf_stride_egress_en_pri[1][`CA53_BIU_LF_DESCR_NUM-1:0]}} &
                                             {`CA53_BIU_LF_DESCR_NUM{~|lf_descr_pf_stride_egress_en_pri[2][`CA53_BIU_LF_DESCR_NUM-1:0]}  });

  // Select if any linefill descriptor requires PF stride forward

  assign lf_descr_pf_stride_ingress_en = |lf_descr_pf_stride_egress_en;

  // Linefill descriptor PF stride match arbitration winner mux

  `CA53_BIU_ONEHOT_MUX(lf_descr_pf_stride_ingress_cnt,    2, 0, lf_descr_pf_stride_egress_en_sel, lf_descr_pf_stride_egress_cnt,    `CA53_BIU_LF_DESCR_NUM, 0, g_mux_pf_stride_cnt)
  `CA53_BIU_ONEHOT_MUX(lf_descr_pf_stride_ingress_stride, 4, 0, lf_descr_pf_stride_egress_en_sel, lf_descr_pf_stride_egress_stride, `CA53_BIU_LF_DESCR_NUM, 0, g_mux_pf_stride)

  //-----------------------------------------------------------------------------
  // PF streams allocation arbiter:
  // o get the lowest physical index of linefill descr requesting the PF stream allocation
  //-----------------------------------------------------------------------------

  generate
    for (index_i = 0; index_i < `CA53_BIU_LF_DESCR_NUM; index_i = index_i + 1) begin : gen_arb_lf_descr_pf_stream_req_0
      if (index_i == 0) begin : gen_arb_lf_descr_pf_stream_req_0_nested_0
        assign lf_descr_pf_stream_alloc_req_sel[0] = lf_descr_pf_stream_alloc_req[0];
      end else begin : gen_arb_lf_descr_pf_stream_req_0_nested_0_else
        assign lf_descr_pf_stream_alloc_req_sel[index_i] = lf_descr_pf_stream_alloc_req[index_i] & ~(|lf_descr_pf_stream_alloc_req[index_i-1:0]);
      end
    end
  endgenerate

  // Linefill descriptor PF stream request arbitration winner mux

  generate
    for (index_i = 0; index_i < `CA53_BIU_LF_DESCR_NUM; index_i = index_i + 1) begin : g_lf_for_wr
      assign lf_descr_for_write[index_i] = `CA53_BIU_LF_FOR_WRITE(lf_descr_master[index_i]);
    end
  endgenerate

  `CA53_BIU_ONEHOT_MUX(pf_stream_addr,  35, 6, lf_descr_pf_stream_alloc_req_sel, lf_descr_pf_stream_alloc_addr,   `CA53_BIU_LF_DESCR_NUM, 0, g_mux_pf_str_addr)
  `CA53_BIU_ONEHOT_MUX(pf_stream_stride, 4, 0, lf_descr_pf_stream_alloc_req_sel, lf_descr_pf_stream_alloc_stride, `CA53_BIU_LF_DESCR_NUM, 0, g_mux_pf_str_stride)
  `CA53_BIU_ONEHOT_MUX(pf_stream_attrs,  8, 0, lf_descr_pf_stream_alloc_req_sel, lf_descr_pf_stream_alloc_attrs,  `CA53_BIU_LF_DESCR_NUM, 0, g_mux_pf_str_atrs)

  assign pf_stream_pldw = |(lf_descr_for_write & lf_descr_pf_stream_alloc_req_sel);

  // Get the lowest physical index of a PF stream not in use

  generate
    for (index_i = 0; index_i < `CA53_BIU_PF_STREAM_NUM; index_i = index_i + 1) begin : gen_arb_pf_stream_idle_sel_0
      if (index_i == 0) begin : gen_arb_pf_stream_idle_sel_0_nested_0
        assign pf_stream_idle_sel[0]     = pf_stream_idle[0];
        assign pf_stream_throttle_sel[0] = pf_stream_throttle[0];
      end else begin : gen_arb_pf_stream_idle_sel_0_nested_0_else
        assign pf_stream_idle_sel[index_i]     = pf_stream_idle[index_i] & ~(|pf_stream_idle[index_i-1:0]);
        assign pf_stream_throttle_sel[index_i] = pf_stream_throttle[index_i] & ~(|pf_stream_throttle[index_i-1:0]);
      end
    end
  endgenerate

  // Mask the PF stream selection with the mask of the allowed PF streams from the DPU

  assign pf_stream_alloc_sel = pf_stream_idle_sel & ~dpu_enable_data_prefetch_streams_abort_mask & {`CA53_BIU_PF_STREAM_NUM{~|lf_descr_pf_stream_alloc_hz_req}};

  assign pf_stream_alloc_hz  = (lf_descr_pf_stream_alloc_hz_req | ({`CA53_BIU_LF_DESCR_NUM{~|lf_descr_pf_stream_alloc_hz_req}} & lf_descr_pf_stream_alloc_req_sel)) & {`CA53_BIU_LF_DESCR_NUM{|pf_stream_match_ingress_hz}};

  assign pf_stream_alloc_ack = lf_descr_pf_stream_alloc_req_sel & {`CA53_BIU_LF_DESCR_NUM{|pf_stream_alloc_sel}};

  // Select if an eligible LF for PF stream started (used to enable the PF stream clock and to resume the PF stream from STATE_ADDR_PAGE_CROSSED state)

  assign pf_stream_eligible_for_pf_lf_init = biu_ar_valid_i                                                                                                             &
                                             `CA53_BIU_LF_ELIGIBLE_FOR_PF(biu_ar_lf_master_i, biu_read_alloc_pend_i, dpu_disable_data_prefetch_stores_pattern_prev_cycle);

  // Enable the PF stream clock:

  assign pf_stream_req_active = {`CA53_BIU_PF_STREAM_NUM{// PF stride detection config change
                                                         (dpu_data_prefetch_stride_detect_prev_cycle ^ dpu_data_prefetch_stride_detect_i) |
                                                         // Potential PF req access from the LF descr next clock cycle
                                                         (|lf_descr_pf_stream_alloc_req)                                                  |
                                                         ((|lf_descr_pf_stream_alloc_active) & pf_stream_eligible_for_pf_lf_init          )}};

  // Route the PF stream request to the selected PF stream

  assign pf_stream_req = pf_stream_alloc_sel & {`CA53_BIU_PF_STREAM_NUM{|lf_descr_pf_stream_alloc_req}};

  // Force the PF stream FSM transition from the STATE_THROTTLE_PF_LF_INVALID to the STATE_IDLE state when:
  // o all PF streams in STATE_THROTTLE_PF_LF_INVALID and there is a pending PF stream request
  // o no LF descriptor had been previously initiated by the PF stream

  assign pf_stream_lf_used = {~|lf_descr_from_pf_stream[3][`CA53_BIU_LF_DESCR_NUM-1:0],
                              ~|lf_descr_from_pf_stream[2][`CA53_BIU_LF_DESCR_NUM-1:0],
                              ~|lf_descr_from_pf_stream[1][`CA53_BIU_LF_DESCR_NUM-1:0],
                              ~|lf_descr_from_pf_stream[0][`CA53_BIU_LF_DESCR_NUM-1:0]};

  assign pf_stream_cancel_throttle = pf_stream_throttle_sel & {`CA53_BIU_PF_STREAM_NUM{(|lf_descr_pf_stream_alloc_req) & ~|pf_stream_alloc_sel & ~|lf_descr_pf_stream_alloc_hz_req}};

  //-----------------------------------------------------------------------------
  // Round-robin counter to select the prefetch stream having priority to the DCU PF tag interface
  //-----------------------------------------------------------------------------

  // Select the PF stream based on:
  // o round robin basis when more than one PF stream active
  // o set to PF stream 0 when no PF stream active

  // Pick one of the prefetch streams dcu tag active streams

  assign pf_stream_dcu_tag_req_rr_sel_bin = `CA53_BIU_ONEHOT2BIN(pf_stream_dcu_tag_req_rr_sel);

  ca53_rr_arb #(.WIDTH(`CA53_BIU_PF_STREAM_NUM)) u_biu_pf_stream_dcu_tag_req_arb (
    .clk          (clk),
    .reset_n      (reset_n),
    .rr_counter_i (pf_stream_dcu_tag_req_rr_sel_bin),
    .requests_i   (biu_pf_tag_active[`CA53_BIU_PF_STREAM_NUM-1:0]),
    .arb_o        (biu_pf_tag_active_arb[`CA53_BIU_PF_STREAM_NUM-1:0])
  );

  assign next_pf_stream_dcu_tag_req_rr_sel = (~|biu_pf_tag_active_arb) ? {{`CA53_BIU_PF_STREAM_NUM-1{1'b0}}, 1'b1} :
                                                                         biu_pf_tag_active_arb;

  assign pf_stream_dcu_tag_req_rr_sel_en   = ~|((pf_stream_dcu_tag_req_rr_sel[`CA53_BIU_PF_STREAM_NUM-1:0]) &
                                                (biu_pf_tag_req_m0[`CA53_BIU_PF_STREAM_NUM-1:0] |
                                                 biu_pf_tag_req_m1[`CA53_BIU_PF_STREAM_NUM-1:0  ]           ));

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      pf_stream_dcu_tag_req_rr_sel <= {{`CA53_BIU_PF_STREAM_NUM-1{1'b0}}, 1'b1};
    end else if (pf_stream_dcu_tag_req_rr_sel_en) begin
      pf_stream_dcu_tag_req_rr_sel <= next_pf_stream_dcu_tag_req_rr_sel;
    end

  `CA53_BIU_ONEHOT_MUX(biu_pf_tag_addr_m0_sel, 34, 6, pf_stream_dcu_tag_req_rr_sel, biu_pf_tag_addr_m0, `CA53_BIU_PF_STREAM_NUM, 0, g_mux_pf_tag_addr_m0)

  assign biu_pf_tag_req_m0_sel    = |(biu_pf_tag_req_m0 & pf_stream_dcu_tag_req_rr_sel);
  assign biu_pf_tag_ns_dsc_m0_sel = |(biu_pf_tag_ns_dsc_m0 & pf_stream_dcu_tag_req_rr_sel);

  // Route the dcu_pf_tag_has_priority_m0_i to the PF stream which was given the priority

  assign dcu_pf_tag_has_priority_m0 = pf_stream_dcu_tag_req_rr_sel & {`CA53_BIU_PF_STREAM_NUM{dcu_pf_tag_has_priority_m0_i}};

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_pf_tag_req_m0_o    = biu_pf_tag_req_m0_sel;
  assign biu_pf_tag_addr_m0_o   = biu_pf_tag_addr_m0_sel;
  assign biu_pf_tag_ns_dsc_m0_o = biu_pf_tag_ns_dsc_m0_sel;

  //-----------------------------------------------------------------------------
  // PF streams/DC1 linefill allocation arbiter
  //-----------------------------------------------------------------------------

  // Pick one of the prefetch streams linefill request active streams based on a round-robin fair.

  assign pf_stream_lf_req_rr_sel_bin = `CA53_BIU_ONEHOT2BIN(pf_stream_lf_req_rr_sel);

  ca53_rr_arb #(.WIDTH(`CA53_BIU_PF_STREAM_NUM)) u_biu_pf_stream_lf_req_arb (
    .clk          (clk),
    .reset_n      (reset_n),
    .rr_counter_i (pf_stream_lf_req_rr_sel_bin),
    .requests_i   (pf_stream_lf_active[`CA53_BIU_PF_STREAM_NUM-1:0]),
    .arb_o        (pf_stream_lf_active_arb[`CA53_BIU_PF_STREAM_NUM-1:0])
  );

  // The DC1 linefill request gets arbitrated, if no PF stream linefill active.

  assign pf_stream_lf_active[`CA53_BIU_DC1_LF]       = dcu_load_dc3_i & dcu_lf_req_dc1_i & ~dcu_leaving_dc1_i & ~stb_must_drain;
  assign pf_stream_lf_req   [`CA53_BIU_DC1_LF]       = dcu_load_dc3_i & dcu_lf_req_dc1_i & ~stb_must_drain;
  assign pf_stream_idle     [`CA53_BIU_DC1_LF]       = ~(dcu_load_dc3_i & dcu_lf_req_dc1_i & ~stb_must_drain);
  assign pf_stream_lf_addr  [`CA53_BIU_DC1_LF][40:6] = {dpu_ns_dsc_dc1_i, dpu_pa_dc1_i[39:12], dpu_va_dc1_i[11:6]};
  assign pf_stream_lf_way   [`CA53_BIU_DC1_LF][3:0]  = (4'h1 << dcu_lf_way_dc1_i);
  assign pf_stream_lf_attrs [`CA53_BIU_DC1_LF][7:0]  = dcu_attrs_dc1_i;
  assign pf_stream_lf_pldw  [`CA53_BIU_DC1_LF]       = 1'b0;

  assign pf_stream_lf_active_arb[`CA53_BIU_DC1_LF] = pf_stream_lf_active[`CA53_BIU_DC1_LF] & ~|pf_stream_lf_active[`CA53_BIU_PF_STREAM_NUM-1:0];

  assign pf_stream_lf_req_rr_sel_en = ~|(pf_stream_lf_req_rr_sel[`CA53_BIU_PF_STREAM_NUM:0] &
                                         pf_stream_lf_active[`CA53_BIU_PF_STREAM_NUM:0]      ) |
                                      (master_valid[`CA53_BIU_PF_LF]               &
                                       master_lf_descr_index_way_hz[`CA53_BIU_PF_LF]           );

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      pf_stream_lf_req_rr_sel <= {(`CA53_BIU_PF_STREAM_NUM+1){1'b0}};
    end else if (pf_stream_lf_req_rr_sel_en) begin
      pf_stream_lf_req_rr_sel <= pf_stream_lf_active_arb;
    end

  // Counter for the outstanding transactions initiated by the PF streams:
  // o +1 when a new linefill is intiated by a PF stream
  // o -1 when a linefill receives all chunks (used the registered value in order to ease the timing closure)
  // o lf_descr_pf_cnt when others

  assign next_lf_descr_pf_cnt = lf_descr_pf_cnt                                                                                          +
                                {3'b000, (biu_lf_ack_i & biu_lf_req_arb_pf_sel & ~pf_stream_lf_req_dc1_sel)}                             -
                                {3'b000, |(lf_descr_from_pf & lf_descr_valid & lf_descr_fetched_last & ~lf_descr_fetched_last_prev_cycle)};

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      lf_descr_pf_cnt <= 4'h0;
    end else begin
      lf_descr_pf_cnt <= next_lf_descr_pf_cnt[3:0];
    end

  // Limit the maximum number of outstanding transactions initiated by the prefetch streams:
  // o 0-6: dpu_enable_data_prefetch_prev_cycle's value up to six
  // o 8:   dpu_enable_data_prefetch_prev_cycle's value is seven
  // Note:  The BIU allows dynamic configuration of the dpu_enable_data_prefetch_prev_cycle ("higher than" comparison used)

  assign pf_stream_lf_req_throttle = // DPU sets the max outstanding transactions initiated by the prefetch streams to 1-6
                                     (lf_descr_pf_cnt >= {1'b0, dpu_enable_data_prefetch_prev_cycle}) &
                                     // Allow up to eight outstanding transactions initiated by the prefetch stream
                                     ~&dpu_enable_data_prefetch_prev_cycle;

  // Compute if the DC1 linefill request got arbitrated

  assign pf_stream_lf_req_dc1_sel = pf_stream_lf_req_rr_sel[`CA53_BIU_DC1_LF];

  // Data prefetch linefill request winner mux

  assign pf_lf_valid = |(pf_stream_lf_req_rr_sel & ~pf_stream_idle);
  assign pf_lf_req   = (~pf_stream_lf_req_throttle | pf_stream_lf_req_dc1_sel) &
                       |(pf_stream_lf_req_rr_sel & pf_stream_lf_req            );

  // In order to ease the timing closure, register the PF stream linefill related
  // signals for the potential next clock cycle LF request from the PF streams.

  `CA53_BIU_ONEHOT_MUX(next_pf_lf_addr, 35, 6, pf_stream_lf_active_arb, pf_stream_lf_addr,  (`CA53_BIU_PF_STREAM_NUM+1), 0, g_mux_pf_lf_req_addr)
  `CA53_BIU_ONEHOT_MUX(next_pf_lf_way,   4, 0, pf_stream_lf_active_arb, pf_stream_lf_way,   (`CA53_BIU_PF_STREAM_NUM+1), 0, g_mux_pf_lf_req_way)
  `CA53_BIU_ONEHOT_MUX(next_pf_lf_attrs, 8, 0, pf_stream_lf_active_arb, pf_stream_lf_attrs, (`CA53_BIU_PF_STREAM_NUM+1), 0, g_mux_pf_lf_req_attr)

  assign next_pf_lf_pldw = |(pf_stream_lf_pldw & pf_stream_lf_active_arb);

  assign pf_lf_en = pf_stream_lf_req_rr_sel_en & (|pf_stream_lf_active[`CA53_BIU_PF_STREAM_NUM:0]);

  always @(posedge clk_pf_lf)
    if (pf_lf_en) begin
      pf_lf_addr  <= next_pf_lf_addr;
      pf_lf_way   <= next_pf_lf_way;
      pf_lf_attrs <= next_pf_lf_attrs;
      pf_lf_pldw  <= next_pf_lf_pldw;
    end

  assign pf_lf_stream_id = `CA53_BIU_ONEHOT2BIN(pf_stream_lf_req_rr_sel);

  // Forward the LF acknowledge to the corresponding PF stream

  assign pf_stream_lf_ack = pf_stream_lf_req_rr_sel[`CA53_BIU_PF_STREAM_NUM-1:0]          &
                            {`CA53_BIU_PF_STREAM_NUM{biu_lf_ack_i & biu_lf_req_arb_pf_sel}};

  //-----------------------------------------------------------------------------
  // PF streams hazard interconnect
  //-----------------------------------------------------------------------------

  // Select the PF stream address for the hazard check against the other PF streams

  assign pf_stream_match_ingress_addr = (|lf_descr_pf_stream_alloc_hz_req) ? biu_ar_addr_i : pf_stream_addr;

  // Forward the PF stream hazard check results to the corresponding PF stream

  assign pf_stream_match_egress_hz = {`CA53_BIU_PF_STREAM_NUM{|pf_stream_match_ingress_hz}};

  //-----------------------------------------------------------------------------
  // DCU/STB requests hazards against linefills initiated by PF
  //-----------------------------------------------------------------------------

  generate
    for (index_i = 0; index_i < `CA53_BIU_LF_DESCR_NUM; index_i = index_i + 1) begin : gen_lf_descr_from_pf
      assign lf_descr_from_pf[index_i] = (lf_descr_master[index_i][2:0] == `CA53_BIU_LF_MASTER_PF)    |
                                         (lf_descr_master[index_i][2:0] == `CA53_BIU_LF_MASTER_PF_PLDW);
    end
  endgenerate

  generate
    for (index_i = 0; index_i < `CA53_BIU_PF_STREAM_NUM; index_i = index_i + 1) begin : gen_lf_descr_from_pf_stream_outer
      for (index_j = 0; index_j < `CA53_BIU_LF_DESCR_NUM; index_j = index_j + 1) begin : gen_lf_descr_from_pf_stream_inner
        assign lf_descr_from_pf_stream[index_i][index_j] = lf_descr_from_pf[index_j]                     &
                                                           (lf_descr_master[index_j][4:3] == index_i[1:0]);
      end
    end
  endgenerate

  generate
    for (index_i = 0; index_i < `CA53_BIU_PF_STREAM_NUM; index_i = index_i + 1) begin : gen_lf_descr_from_pf_stream_valid
      assign lf_descr_from_pf_stream_valid[index_i] = |(lf_descr_from_pf_stream[index_i][`CA53_BIU_LF_DESCR_NUM-1:0] &
                                                        lf_descr_valid[`CA53_BIU_LF_DESCR_NUM-1:0]                    );
    end
  endgenerate

  assign dcu_stb_match_lf[`CA53_BIU_LF_DESCR_NUM-1:0] = lf_descr_pf_match[`CA53_BIU_DC2_LF][`CA53_BIU_LF_DESCR_NUM-1:0]  |
                                                        lf_descr_pf_match[`CA53_BIU_DC3_LF][`CA53_BIU_LF_DESCR_NUM-1:0]  |
                                                        lf_descr_pf_match[`CA53_BIU_STB4_LF][`CA53_BIU_LF_DESCR_NUM-1:0] |
                                                        lf_descr_pf_match[`CA53_BIU_STB3_LF][`CA53_BIU_LF_DESCR_NUM-1:0] |
                                                        lf_descr_pf_match[`CA53_BIU_STB2_LF][`CA53_BIU_LF_DESCR_NUM-1:0] |
                                                        lf_descr_pf_match[`CA53_BIU_STB1_LF][`CA53_BIU_LF_DESCR_NUM-1:0] |
                                                        lf_descr_pf_match[`CA53_BIU_STB0_LF][`CA53_BIU_LF_DESCR_NUM-1:0];

  generate
    for (index_i = 0; index_i < `CA53_BIU_PF_STREAM_NUM; index_i = index_i + 1) begin : gen_dcu_stb_match_lf_from_pf
      assign dcu_stb_match_lf_from_pf[index_i] = |(dcu_stb_match_lf[`CA53_BIU_LF_DESCR_NUM-1:0]               &
                                                   lf_descr_from_pf_stream[index_i][`CA53_BIU_LF_DESCR_NUM-1:0]);
    end
  endgenerate

  //-----------------------------------------------------------------------------
  // PF streams hazards check against the outstanding linefills
  //-----------------------------------------------------------------------------

  assign pf_stream_lf_match_pf     = pf_stream_lf_req_rr_sel[`CA53_BIU_PF_STREAM_NUM-1:0]             &
                                     {|((lf_descr_from_pf_stream[2][`CA53_BIU_LF_DESCR_NUM-1:0] |
                                         lf_descr_from_pf_stream[1][`CA53_BIU_LF_DESCR_NUM-1:0] |
                                         lf_descr_from_pf_stream[0][`CA53_BIU_LF_DESCR_NUM-1:0]  ) &
                                        lf_descr_match[`CA53_BIU_PF_LF][`CA53_BIU_LF_DESCR_NUM-1:0] ),
                                      |((lf_descr_from_pf_stream[3][`CA53_BIU_LF_DESCR_NUM-1:0] |
                                         lf_descr_from_pf_stream[1][`CA53_BIU_LF_DESCR_NUM-1:0] |
                                         lf_descr_from_pf_stream[0][`CA53_BIU_LF_DESCR_NUM-1:0]  ) &
                                        lf_descr_match[`CA53_BIU_PF_LF][`CA53_BIU_LF_DESCR_NUM-1:0] ),
                                      |((lf_descr_from_pf_stream[3][`CA53_BIU_LF_DESCR_NUM-1:0] |
                                         lf_descr_from_pf_stream[2][`CA53_BIU_LF_DESCR_NUM-1:0] |
                                         lf_descr_from_pf_stream[0][`CA53_BIU_LF_DESCR_NUM-1:0]  ) &
                                        lf_descr_match[`CA53_BIU_PF_LF][`CA53_BIU_LF_DESCR_NUM-1:0] ),
                                      |((lf_descr_from_pf_stream[3][`CA53_BIU_LF_DESCR_NUM-1:0] |
                                         lf_descr_from_pf_stream[2][`CA53_BIU_LF_DESCR_NUM-1:0] |
                                         lf_descr_from_pf_stream[1][`CA53_BIU_LF_DESCR_NUM-1:0  ]) &
                                        lf_descr_match[`CA53_BIU_PF_LF][`CA53_BIU_LF_DESCR_NUM-1:0] ) };

  assign pf_stream_lf_match_non_pf = pf_stream_lf_req_rr_sel[`CA53_BIU_PF_STREAM_NUM-1:0]                                      &
                                     {`CA53_BIU_PF_STREAM_NUM{|{lf_descr_match[`CA53_BIU_PF_LF][`CA53_BIU_LF_DESCR_NUM-1:0] &
                                                                ~lf_descr_from_pf[`CA53_BIU_LF_DESCR_NUM-1:0]                }}};

  //-----------------------------------------------------------------------------
  // PF streams hazards check against the LF descr DCU allocations from M1
  //-----------------------------------------------------------------------------

  assign biu_alloc_lf_descr_from_pf_m0 = |(lf_descr_from_pf & biu_alloc_lf_descr_m0);

  //-----------------------------------------------------------------------------
  // Export the prefetch streams status (factorized into the next_biu_wfx_ready computation)
  //-----------------------------------------------------------------------------

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign pf_stream_idle_o = pf_stream_idle[`CA53_BIU_PF_STREAM_NUM-1:0];

  //------------------------------------------------------------------------------
  // LF performance counters
  //------------------------------------------------------------------------------

  assign next_biu_evnt_rw_lf = |lf_descr_biu_evnt_rw_lf[`CA53_BIU_LF_DESCR_NUM-1:0];
  assign next_biu_evnt_pf_lf = |lf_descr_biu_evnt_pf_lf[`CA53_BIU_LF_DESCR_NUM-1:0];

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      biu_evnt_rw_lf <= 1'b0;
      biu_evnt_pf_lf <= 1'b0;
    end else begin
      biu_evnt_rw_lf <= next_biu_evnt_rw_lf;
      biu_evnt_pf_lf <= next_biu_evnt_pf_lf;
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_evnt_rw_lf_o = biu_evnt_rw_lf;
  assign biu_evnt_pf_lf_o = biu_evnt_pf_lf;

  //-----------------------------------------------------------------------------
  // Linefill descriptors
  //-----------------------------------------------------------------------------

  // Enable the clock at the linefill descriptors level when there is a potential linefill request next clock cycle

  assign biu_lf_active = |{dcu_lf_active_i, stb_lf_active_i, tlb_walk_lf_active_i, pf_stream_lf_active};

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      biu_lf_active_prev_cycle <= 1'b0;
    end else begin
      biu_lf_active_prev_cycle <= biu_lf_active;
    end

  // Extend the linefill clock request by an extra cycle in order to cover the gap
  // in between the biu_lf_active and the corresponding lf_descr_valid being set

  assign biu_lf_active_extended = biu_lf_active | biu_lf_active_prev_cycle;

  // Route the linefill initialization to the corresponding linefill descriptor

  assign biu_lf_init = {`CA53_BIU_LF_DESCR_NUM{biu_lf_ack_i}} & lf_descr_available_sel;

  // Pack the master_lf_addr and master_lf_way arrays

  generate
    for (index_i = 0; index_i < `CA53_BIU_LF_MASTERS_NUM; index_i = index_i + 1) begin : gen_pack_master_lf_addr
      assign master_lf_addr_packed[2*index_i+1:2*index_i]       = master_lf_addr[index_i][5:4];
      assign master_lf_addr_hz_packed[35*index_i+34:35*index_i] = master_lf_addr_hz[index_i][40:6];
      assign master_lf_way_packed[4*index_i+3:4*index_i]        = master_lf_way[index_i][3:0];
    end
  endgenerate

  // Instantiate the linefill descriptors

  generate
    for (index_i = 0; index_i < `CA53_BIU_LF_DESCR_NUM; index_i = index_i + 1) begin : gen_ca53biu_linefill_descriptor_0
      ca53biu_linefill_descriptor #(.LF_DESCR_ID(index_i)) u_ca53biu_linefill_descriptor (
        .clk                                        (clk),
        .reset_n                                    (reset_n),
        .DFTSE                                      (DFTSE),
        .dcu_index_mask_i                           (dcu_index_mask[13:6]),
        .biu_lf_active_i                            (biu_lf_active_extended),
        .biu_lf_init_i                              (biu_lf_init[index_i]),
        .biu_lf_attrs_i                             (biu_lf_attrs_arb_out),
        .biu_lf_way_i                               (biu_lf_way_arb_out),
        .biu_lf_addr_i                              (biu_lf_addr_arb_out[40:6]),
        .biu_lf_master_i                            (biu_lf_master_arb_out[4:0]),
        .scu_dr_valid_i                             (scu_dr_valid_i),
        .scu_dr_id_i                                (scu_dr_id_i[4:0]),
        .scu_dr_resp_i                              (scu_dr_resp_i[4:0]),
        .scu_dr_chunk_i                             (scu_dr_chunk_i[1:0]),
        .scu_ev_done_i                              (scu_ev_done_i[index_i]),
        .stb_lf_merge_i                             (stb_lf_merge_i[4:0]),
        .stb_slot_cachewrite_m1_i                   (stb_slot_cachewrite_m1_i[4:0]),
        .dcu_stb_data_ack_m1_i                      (dcu_stb_data_ack_m1_i),
        .master_valid_i                             (master_hz_valid[`CA53_BIU_LF_MASTERS_NUM-1:0]),
        .master_lf_addr_packed_i                    (master_lf_addr_packed[2*`CA53_BIU_LF_MASTERS_NUM-1:0]),
        .master_lf_addr_hz_packed_i                 (master_lf_addr_hz_packed[35*`CA53_BIU_LF_MASTERS_NUM-1:0]),
        .master_lf_way_packed_i                     (master_lf_way_packed[4*`CA53_BIU_LF_MASTERS_NUM-1:0]),
        .lf_descr_index_match_o                     (lf_descr_index_match_rot90[index_i][`CA53_BIU_LF_MASTERS_NUM-1:0]),
        .lf_descr_index_way_match_o                 (lf_descr_index_way_match_rot90[index_i][`CA53_BIU_LF_MASTERS_NUM-1:0]),
        .lf_descr_match_o                           (lf_descr_match_rot90[index_i][`CA53_BIU_LF_MASTERS_NUM-1:0]),
        .lf_descr_pf_match_o                        (lf_descr_pf_match_rot90[index_i][`CA53_BIU_LF_MASTERS_NUM-1:0]),
        .lf_descr_fetched_none_o                    (lf_descr_fetched_none[index_i]),
        .lf_descr_fetched_last_o                    (lf_descr_fetched_last[index_i]),
        .lf_descr_fetched_last_prev_cycle_o         (lf_descr_fetched_last_prev_cycle[index_i]),
        .lf_descr_valid_o                           (lf_descr_valid[index_i]),
        .lf_descr_master_o                          (lf_descr_master[index_i][4:0]),
        .lf_descr_way_o                             (lf_descr_way[index_i]),
        .lf_descr_tag_done_o                        (lf_descr_tag_done[index_i]),
        .lf_descr_tag_err_o                         (lf_descr_tag_err[index_i]),
        .lf_descr_unique_o                          (lf_descr_unique[index_i]),
        .lf_descr_exclusive_o                       (lf_descr_exclusive[index_i]),
        .lf_descr_evict_done_o                      (lf_descr_evict_done[index_i]),
        .lf_descr_err_from_scu_o                    (lf_descr_err_from_scu[index_i]),
        .lf_descr_chunk_fetched_from_scu_o          (lf_descr_chunk_fetched_from_scu[index_i][3:0]),
        .lf_descr_chunk_need_release_o              (lf_descr_chunk_need_release[index_i][3:0]),
        .lf_descr_chunk_allocated_from_stb_o        (lf_descr_chunk_allocated_from_stb[index_i][3:0]),
        .lf_descr_chunk_allocated_from_biu_o        (lf_descr_chunk_allocated_from_biu[index_i][3:0]),
        .lf_descr_stb_can_merge_o                   (lf_descr_stb_can_merge[index_i][4:0]),
        .lf_descr_addr_o                            (lf_descr_addr[index_i][39:6]),
        .lf_descr_ns_dsc_o                          (lf_descr_ns_dsc[index_i]),
        .lf_descr_passed_as_dirty_o                 (lf_descr_passed_as_dirty[index_i]),
        .lf_descr_migratory_o                       (lf_descr_migratory[index_i]),
        .lf_descr_attrs_o                           (lf_descr_attrs[index_i][7:0]),
        .dcu_alloc_ack_m1_i                         (lf_descr_ack_m1[index_i]),
        .biu_alloc_chunk_pend_m0_i                  (lf_descr_chunk_pend_m0[index_i]),
        .biu_alloc_chunk_pend_m1_i                  (lf_descr_chunk_pend_m1[index_i]),
        .biu_alloc_last_pend_m1_i                   (lf_descr_last_pend_m1[index_i]),
        .lf_descr_inc_ramode_o                      (lf_descr_inc_ramode[index_i]),
        .lf_descr_leave_ramode_o                    (lf_descr_leave_ramode[index_i]),
        .lf_descr_imp_abort_o                       (lf_descr_imp_abort[index_i]),
        .lf_descr_imp_fault_dec_o                   (lf_descr_imp_fault_dec[index_i]),
        .lf_descr_imp_fault_ecc_o                   (lf_descr_imp_fault_ecc[index_i]),
        .dpu_data_prefetch_stride_detect_i          (dpu_data_prefetch_stride_detect_prev_cycle),
        .dpu_disable_data_prefetch_stores_pattern_i (dpu_disable_data_prefetch_stores_pattern_prev_cycle),
        .read_alloc_mode_i                          (biu_read_alloc_pend_i),
        .biu_ar_valid_i                             (biu_ar_valid_i),
        .biu_ar_addr_i                              (biu_lf_addr_last),
        .biu_ar_lf_master_i                         (biu_ar_lf_master_i[2:0]),
        .lf_descr_pf_stride_ingress_en_i            (lf_descr_pf_stride_ingress_en),
        .lf_descr_pf_stride_ingress_cnt_i           (lf_descr_pf_stride_ingress_cnt),
        .lf_descr_pf_stride_ingress_stride_i        (lf_descr_pf_stride_ingress_stride),
        .lf_descr_pf_stride_egress_en_o             (lf_descr_pf_stride_egress_en[index_i]),
        .lf_descr_pf_stride_egress_cnt_o            (lf_descr_pf_stride_egress_cnt[index_i]),
        .lf_descr_pf_stride_egress_stride_o         (lf_descr_pf_stride_egress_stride[index_i]),
        .lf_descr_pf_stream_alloc_active_o          (lf_descr_pf_stream_alloc_active[index_i]),
        .lf_descr_pf_stream_alloc_req_o             (lf_descr_pf_stream_alloc_req[index_i]),
        .lf_descr_pf_stream_alloc_hz_req_o          (lf_descr_pf_stream_alloc_hz_req[index_i]),
        .lf_descr_pf_stream_alloc_addr_o            (lf_descr_pf_stream_alloc_addr[index_i]),
        .lf_descr_pf_stream_alloc_stride_o          (lf_descr_pf_stream_alloc_stride[index_i]),
        .lf_descr_pf_stream_alloc_attrs_o           (lf_descr_pf_stream_alloc_attrs[index_i]),
        .pf_stream_alloc_ack_i                      (pf_stream_alloc_ack[index_i]),
        .pf_stream_alloc_hz_i                       (pf_stream_alloc_hz[index_i]),
        .pf_streams_drop_i                          (pf_streams_drop),
        .lf_descr_biu_evnt_rw_lf_o                  (lf_descr_biu_evnt_rw_lf[index_i]),
        .lf_descr_biu_evnt_pf_lf_o                  (lf_descr_biu_evnt_pf_lf[index_i])
      ); // u_ca53biu_linefill_descriptor
    end
  endgenerate

  //-----------------------------------------------------------------------------
  // Data prefetch management streams
  //-----------------------------------------------------------------------------

  // Instantiate the data prefetch management streams

  generate
    for (index_i = 0; index_i < `CA53_BIU_PF_STREAM_NUM; index_i = index_i + 1) begin : gen_ca53biu_prefetch_stream_mngmt_0
      ca53biu_prefetch_stream_mngmt #(.CPU_CACHE_PROTECTION(CPU_CACHE_PROTECTION), .PF_STREAM_ID(index_i)) u_ca53biu_prefetch_stream_mngmt (
        .clk                                        (clk),
        .reset_n                                    (reset_n),
        .DFTSE                                      (DFTSE),
        .tlb_mem_granule_i                          (tlb_mem_granule_cpy),
        .biu_alloc_lf_descr_m0_i                    (biu_alloc_lf_descr_m0),
        .biu_alloc_lf_descr_from_pf_m0_i            (biu_alloc_lf_descr_from_pf_m0),
        .biu_alloc_lf_descr_addr_m0_i               (biu_alloc_addr_m0[39:6]),
        .biu_alloc_lf_descr_ns_dsc_m0_i             (biu_alloc_ns_dsc_m0),
        .biu_pf_tag_active_o                        (biu_pf_tag_active[index_i]),
        .biu_pf_tag_req_m0_o                        (biu_pf_tag_req_m0[index_i]),
        .biu_pf_tag_req_m1_o                        (biu_pf_tag_req_m1[index_i]),
        .biu_pf_tag_addr_m0_o                       (biu_pf_tag_addr_m0[index_i]),
        .biu_pf_tag_ns_dsc_m0_o                     (biu_pf_tag_ns_dsc_m0[index_i]),
        .dcu_pf_tag_has_priority_m0_i               (dcu_pf_tag_has_priority_m0[index_i]),
        .dcu_pf_tag_ack_m1_i                        (dcu_pf_tag_ack_m1_i),
        .dcu_pf_tag_hit_m2_i                        (dcu_pf_tag_hit_m2_i),
        .dcu_ecc_tag_err_m3_i                       (dcu_ecc_tag_err_m3_i),
        .pf_stream_lf_used_i                        (pf_stream_lf_used[index_i]),
        .pf_stream_cancel_throttle_i                (pf_stream_cancel_throttle[index_i]),
        .pf_stream_eligible_for_pf_lf_init_i        (pf_stream_eligible_for_pf_lf_init),
        .pf_stream_req_active_i                     (pf_stream_req_active[index_i]),
        .pf_stream_req_i                            (pf_stream_req[index_i]),
        .pf_stream_addr_i                           (pf_stream_addr),
        .pf_stream_stride_i                         (pf_stream_stride),
        .pf_stream_attrs_i                          (pf_stream_attrs),
        .pf_stream_pldw_i                           (pf_stream_pldw),
        .pf_stream_idle_o                           (pf_stream_idle[index_i]),
        .pf_stream_throttle_o                       (pf_stream_throttle[index_i]),
        .pf_stream_match_ingress_addr_i             (pf_stream_match_ingress_addr),
        .pf_stream_match_ingress_hz_o               (pf_stream_match_ingress_hz[index_i]),
        .pf_stream_match_egress_hz_i                (pf_stream_match_egress_hz[index_i]),
        .lf_descr_from_pf_stream_valid_i            (lf_descr_from_pf_stream_valid[index_i]),
        .pf_lf_active_early_o                       (pf_stream_lf_active_early[index_i]),
        .pf_lf_active_o                             (pf_stream_lf_active[index_i]),
        .pf_lf_req_o                                (pf_stream_lf_req[index_i]),
        .pf_lf_addr_o                               (pf_stream_lf_addr[index_i]),
        .pf_lf_attrs_o                              (pf_stream_lf_attrs[index_i]),
        .pf_lf_way_o                                (pf_stream_lf_way[index_i]),
        .pf_lf_pldw_o                               (pf_stream_lf_pldw[index_i]),
        .pf_lf_ack_i                                (pf_stream_lf_ack[index_i]),
        .pf_lf_match_non_pf_i                       (pf_stream_lf_match_non_pf[index_i]),
        .pf_lf_match_pf_i                           (pf_stream_lf_match_pf[index_i]),
        .dcu_stb_match_lf_from_pf_i                 (dcu_stb_match_lf_from_pf[index_i]),
        .biu_ar_addr_i                              (biu_ar_addr_i[40:6]),
        .biu_ar_attrs_i                             (biu_ar_attrs_i[7:0]),
        .biu_ar_lf_master_i                         (biu_ar_lf_master_i[2:0]),
        .pf_stream_abort_i                          (pf_stream_abort[index_i])
      ); // u_ca53biu_prefetch_stream_mngmt
    end
  endgenerate

  //-----------------------------------------------------------------------------
  // DCU linefills allocation management
  //-----------------------------------------------------------------------------

  // Instantiate the DCU linefills allocation management

  ca53biu_dcu_alloc_mngmt u_ca53biu_dcu_alloc_mngmt (
    .clk                                            (clk),
    .reset_n                                        (reset_n),
    .DFTSE                                          (DFTSE),
    .biu_mbist_req_i                                (biu_mbist_req_i),
    .biu_lf_active_i                                (biu_lf_active_extended),
    .biu_alloc_data_m0_o                            (biu_alloc_data_m0_o),
    .biu_alloc_tag_req_m0_o                         (biu_alloc_tag_req_m0_o),
    .biu_alloc_data_req_m0_o                        (biu_alloc_data_req_m0_o),
    .biu_alloc_halfline_m0_o                        (biu_alloc_halfline_m0_o),
    .biu_alloc_dirty_req_m0_o                       (biu_alloc_dirty_req_m0_o),
    .biu_alloc_addr_m0_o                            (biu_alloc_addr_m0),
    .biu_alloc_ns_dsc_m0_o                          (biu_alloc_ns_dsc_m0),
    .biu_alloc_way_m0_o                             (biu_alloc_way_m0_o),
    .biu_alloc_tag_moesi_m0_o                       (biu_alloc_tag_moesi_m0_o),
    .dcu_alloc_has_priority_m0_i                    (dcu_alloc_has_priority_m0_i),
    .biu_alloc_dirty_moesi_m1_o                     (biu_alloc_dirty_moesi_m1_o),
    .biu_alloc_dirty_age_m1_o                       (biu_alloc_dirty_age_m1_o),
    .biu_alloc_attrs_m1_o                           (biu_alloc_attrs_m1_o),
    .dcu_alloc_ack_m1_i                             (dcu_alloc_ack_m1_i),
    .stb_slot0_addr_i                               (stb_slot0_addr_i[5:4]),
    .stb_slot1_addr_i                               (stb_slot1_addr_i[5:4]),
    .stb_slot2_addr_i                               (stb_slot2_addr_i[5:4]),
    .stb_slot3_addr_i                               (stb_slot3_addr_i[5:4]),
    .stb_slot4_addr_i                               (stb_slot4_addr_i[5:4]),
    .stb_slot_cachewrite_m1_i                       (stb_slot_cachewrite_m1_i),
    .rbuf_valid_i                                   (rbuf_valid_i),
    .rbuf_data_packed_i                             (rbuf_data_packed_i),
    .rbuf_chunk_packed_i                            (rbuf_chunk_packed_i),
    .rbuf_id_packed_i                               (rbuf_id_packed_i),
    .rbuf_age_i                                     (rbuf_age_i),
    .rbuf_for_lf_valid_i                            (rbuf_for_lf_valid_i),
    .rbuf_for_lf_oldest_sel_i                       (rbuf_for_lf_oldest_sel_i),
    .biu_alloc_rbuf_clr_o                           (biu_alloc_rbuf_clr_o),
    .biu_alloc_lf_descr_m0_o                        (biu_alloc_lf_descr_m0),
    .biu_alloc_chunk_req_m0_o                       (biu_alloc_chunk_req_m0),
    .biu_alloc_lf_descr_m1_o                        (biu_alloc_lf_descr_m1),
    .biu_alloc_chunk_req_m1_o                       (biu_alloc_chunk_req_m1),
    .biu_alloc_last_m1_o                            (biu_alloc_last_m1),
    .lf_descr_valid_i                               (lf_descr_valid),
    .lf_descr_unique_i                              (lf_descr_unique),
    .lf_descr_evict_done_i                          (lf_descr_evict_done),
    .lf_descr_fetched_none_i                        (lf_descr_fetched_none),
    .lf_descr_err_from_scu_i                        (lf_descr_err_from_scu),
    .lf_descr_tag_done_i                            (lf_descr_tag_done),
    .lf_descr_tag_err_i                             (lf_descr_tag_err),
    .lf_descr_addr_packed_i                         (lf_descr_addr_packed),
    .lf_descr_ns_dsc_i                              (lf_descr_ns_dsc),
    .lf_descr_way_packed_i                          (lf_descr_way_packed),
    .lf_descr_passed_as_dirty_i                     (lf_descr_passed_as_dirty),
    .lf_descr_chunk_fetched_from_scu_packed_i       (lf_descr_chunk_fetched_from_scu_packed),
    .lf_descr_chunk_allocated_from_stb_packed_i     (lf_descr_chunk_allocated_from_stb_packed),
    .lf_descr_chunk_need_release_packed_i           (lf_descr_chunk_need_release_packed),
    .lf_descr_match_stb_packed_i                    (lf_descr_match_stb_packed),
    .lf_descr_migratory_i                           (lf_descr_migratory),
    .lf_descr_attrs_packed_i                        (lf_descr_attrs_packed)
  ); // u_ca53biu_dcu_alloc_mngmt


`ifdef ARM_ASSERT_ON
  // ----------------------------------------------------------------------------
  // ARMAUTO assertions
  // ----------------------------------------------------------------------------

  /* ARMAUTO_X */
  assert_never_unknown          #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tlb_mem_granule_cpy_en")
  u_ovl_x_tlb_mem_granule_cpy_en (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (tlb_mem_granule_cpy_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: biu_lf_req")
  u_ovl_x_biu_lf_req    (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (biu_lf_req));

  assert_never_unknown         #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: biu_load_pa_hz_dc2_en")
  u_ovl_x_biu_load_pa_hz_dc2_en (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (biu_load_pa_hz_dc2_en));

  assert_never_unknown         #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: biu_load_pa_hz_dc3_en")
  u_ovl_x_biu_load_pa_hz_dc3_en (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (biu_load_pa_hz_dc3_en));

  assert_never_unknown            #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: biu_store_pa_hz_slot0_en")
  u_ovl_x_biu_store_pa_hz_slot0_en (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (biu_store_pa_hz_slot0_en));

  assert_never_unknown            #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: biu_store_pa_hz_slot1_en")
  u_ovl_x_biu_store_pa_hz_slot1_en (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (biu_store_pa_hz_slot1_en));

  assert_never_unknown            #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: biu_store_pa_hz_slot2_en")
  u_ovl_x_biu_store_pa_hz_slot2_en (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (biu_store_pa_hz_slot2_en));

  assert_never_unknown            #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: biu_store_pa_hz_slot3_en")
  u_ovl_x_biu_store_pa_hz_slot3_en (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (biu_store_pa_hz_slot3_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: biu_store_pa_hz_slot4_en")
  u_ovl_x_biu_store_pa_hz_slot4_en (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (biu_store_pa_hz_slot4_en));

  assert_never_unknown  #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: lf_descr_rr_en")
  u_ovl_x_lf_descr_rr_en (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (lf_descr_rr_en));

  assert_never_unknown                   #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pf_stream_dcu_tag_req_rr_sel_en")
  u_ovl_x_pf_stream_dcu_tag_req_rr_sel_en (.clk       (clk),
                                           .reset_n   (reset_n),
                                           .qualifier (1'b1),
                                           .test_expr (pf_stream_dcu_tag_req_rr_sel_en));

  assert_never_unknown     #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: stb_must_drain_en")
  u_ovl_x_stb_must_drain_en (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (stb_must_drain_en));

  assert_never_unknown               #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pf_stream_lf_req_rr_sel_en")
  u_ovl_x_pf_stream_lf_req_rr_sel_en  (.clk       (clk),
                                       .reset_n   (reset_n),
                                       .qualifier (1'b1),
                                       .test_expr (pf_stream_lf_req_rr_sel_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pf_lf_en")
  u_ovl_x_pf_lf_en      (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (pf_lf_en));

  //-----------------------------------------------------------------------------
  // Other assertions
  //-----------------------------------------------------------------------------

  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "DC3 must match only one LF descriptor")
  u_ovl_lf_mngmt_01    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (lf_descr_match[`CA53_BIU_DC3_LF][`CA53_BIU_LF_DESCR_NUM-1:0]));

  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "DC2 must match only one LF descriptor")
  u_ovl_lf_mngmt_02    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (lf_descr_match[`CA53_BIU_DC2_LF][`CA53_BIU_LF_DESCR_NUM-1:0]));

  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "STB0 slot must match one one LF descriptor")
  u_ovl_lf_mngmt_03    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (lf_descr_match[`CA53_BIU_STB0_LF][`CA53_BIU_LF_DESCR_NUM-1:0]));

  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "STB1 slot must match only one LF descriptor")
  u_ovl_lf_mngmt_04    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (lf_descr_match[`CA53_BIU_STB1_LF][`CA53_BIU_LF_DESCR_NUM-1:0]));

  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "STB2 slot must match only one LF descriptor")
  u_ovl_lf_mngmt_05    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (lf_descr_match[`CA53_BIU_STB2_LF][`CA53_BIU_LF_DESCR_NUM-1:0]));

  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "STB3 slot must match only one LF descriptor")
  u_ovl_lf_mngmt_06    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (lf_descr_match[`CA53_BIU_STB3_LF][`CA53_BIU_LF_DESCR_NUM-1:0]));

  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "STB4 slot must match only one LF descriptor")
  u_ovl_lf_mngmt_07    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (lf_descr_match[`CA53_BIU_STB4_LF][`CA53_BIU_LF_DESCR_NUM-1:0]));

  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "PF[3:0] must match only one LF descriptor")
  u_ovl_lf_mngmt_08    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (lf_descr_match[`CA53_BIU_PF_LF][`CA53_BIU_LF_DESCR_NUM-1:0]));

  assert_never_unknown #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "lf_descr_for_dc2_o must never be unknown")
  u_ovl_lf_mngmt_09     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (lf_descr_for_dc2_o));

  assert_never_unknown #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "lf_descr_for_dc3_o must never be unknown")
  u_ovl_lf_mngmt_10     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (lf_descr_for_dc3_o));

  assert_never_unknown #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "lf_descr_for_tlb_o must never be unknown")
  u_ovl_lf_mngmt_11     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (lf_descr_for_tlb_o));

  assert_never_unknown #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "lf_descr_leave_ramode must never be unknown")
  u_ovl_lf_mngmt_12     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (lf_descr_leave_ramode));

  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "lf_descr_inc_ramode must be zero or one-hot")
  u_ovl_lf_mngmt_13    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (lf_descr_inc_ramode));

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "lf_descr_pf_cnt must never be unknown")
  u_ovl_lf_mngmt_14     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (lf_descr_pf_cnt));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "lf_descr_pf_cnt must be zero, if no LF descriptor valid")
  u_ovl_lf_mngmt_15   (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (~|lf_descr_valid),
                       .consequent_expr (~|lf_descr_pf_cnt));


  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "lf_descr_pf_cnt cannot underflow")
  u_ovl_lf_mngmt_16   (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (lf_descr_pf_cnt == 4'h0),
                       .consequent_expr ((next_lf_descr_pf_cnt == 4'h0) |
                                          next_lf_descr_pf_cnt == 4'h1  ));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "lf_descr_pf_cnt cannot be higher than the total number of LF descriptors")
  u_ovl_lf_mngmt_17   (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (lf_descr_pf_cnt == 4'h8),
                       .consequent_expr ((next_lf_descr_pf_cnt == 4'h8) |
                                          next_lf_descr_pf_cnt == 4'h7  ));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "lf_descr_pf_cnt cannot be increment/decrement more than one unit")
  u_ovl_lf_mngmt_18   (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (1'b1),
                       .consequent_expr ((next_lf_descr_pf_cnt == lf_descr_pf_cnt)       |
                                         (next_lf_descr_pf_cnt == (lf_descr_pf_cnt - 1)) |
                                         (next_lf_descr_pf_cnt == (lf_descr_pf_cnt + 1)  )));

  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_PF_STREAM_NUM+1, `OVL_ASSERT, "pf_stream_lf_req_rr_sel must be zero or one-hot")
  u_ovl_lf_mngmt_19    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (pf_stream_lf_req_rr_sel));

  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_PF_STREAM_NUM, `OVL_ASSERT, "pf_stream_dcu_tag_req_rr_sel must be zero or one-hot")
  u_ovl_lf_mngmt_20    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (pf_stream_dcu_tag_req_rr_sel));

  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "lf_descr_pf_stride_egress_en_sel must be zero or one-hot")
  u_ovl_lf_mngmt_21    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (lf_descr_pf_stride_egress_en_sel));

  assert_never_unknown #(`OVL_FATAL, `CA53_BIU_PF_STREAM_NUM, `OVL_ASSERT, "pf_stream_abort must never be unknown")
  u_ovl_lf_mngmt_22     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (pf_stream_abort));

  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "lf_descr_pf_stream_alloc_req_sel must be zero or one-hot")
  u_ovl_lf_mngmt_23    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (lf_descr_pf_stream_alloc_req_sel));


  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "biu_evnt_rw_lf_o must never be unknown")
  u_ovl_lf_mngmt_24     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (biu_evnt_rw_lf_o));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "lf_descr_biu_evnt_pf_lf_o must never be unknown")
  u_ovl_lf_mngmt_25     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (biu_evnt_pf_lf_o));

  assert_zero_one_hot #(`OVL_FATAL, 2, `OVL_ASSERT, "lf_descr_biu_evnt_rw_lf_o and lf_descr_biu_evnt_pf_lf_o are mutual exclusive")
  u_ovl_lf_mngmt_26    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr ({biu_evnt_rw_lf_o, biu_evnt_pf_lf_o}));

  assert_never_unknown #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "lf_descr_pf_stream_alloc_active must never be unknown")
  u_ovl_lf_mngmt_27     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (lf_descr_pf_stream_alloc_active));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "linefill_imp_fault_o must not be unknown when linefill_imp_abort_o is set")
  u_ovl_lf_mngmt_28     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (linefill_imp_abort_o),
                         .test_expr (linefill_imp_fault_o));

  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "lf_descr_for_dc2_o must be zero or one-hot")
  u_ovl_lf_mngmt_29    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (lf_descr_for_dc2_o));

  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "lf_descr_for_dc3_o must be zero or one-hot")
  u_ovl_lf_mngmt_30    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (lf_descr_for_dc3_o));

  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "lf_descr_for_tlb_o must be zero or one-hot")
  u_ovl_lf_mngmt_31    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (lf_descr_for_tlb_o));

  // Register the biu_lf_valid_active
  reg ovl_biu_lf_valid_active_prev_cycle;
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_biu_lf_valid_active_prev_cycle <= 1'b0;
    end else begin
      ovl_biu_lf_valid_active_prev_cycle <= biu_lf_valid_active;
    end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The biu_lf_valid_active must have been set previous cycle when the LF are valid")
  u_ovl_lf_mngmt_32   (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (|lf_descr_valid),
                       .consequent_expr (ovl_biu_lf_valid_active_prev_cycle));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "biu_load_pa_hz_dc2 must match dcu_pa_dc2_i when the LF are valid")
  u_ovl_lf_mngmt_33   (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (|lf_descr_valid & dcu_load_dc2_i),
                       .consequent_expr (biu_load_pa_hz_dc2[40:6] == {dcu_ns_dsc_dc2_i, dcu_pa_dc2_i[39:6]}));
                       
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "biu_load_pa_hz_dc3 must match dcu_pa_dc3_i when the LF are valid")
  u_ovl_lf_mngmt_34   (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (|lf_descr_valid & dcu_load_dc3_i),
                       .consequent_expr (biu_load_pa_hz_dc3[40:6] == {dcu_ns_dsc_dc3_i, dcu_pa_dc3_i[39:6]}));                       

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "biu_store_pa_hz_slot0 must match stb_slot0_addr_i when the LF are valid")
  u_ovl_lf_mngmt_35   (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (|lf_descr_valid & stb_slots_valid_i[0]),
                       .consequent_expr (biu_store_pa_hz_slot0[40:6] == {stb_slots_ns_dsc_i[0], stb_slot0_addr_i[39:6]}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "biu_store_pa_hz_slot1 must match stb_slot1_addr_i when the LF are valid")
  u_ovl_lf_mngmt_36   (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (|lf_descr_valid & stb_slots_valid_i[1]),
                       .consequent_expr (biu_store_pa_hz_slot1[40:6] == {stb_slots_ns_dsc_i[1], stb_slot1_addr_i[39:6]}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "biu_store_pa_hz_slot2 must match stb_slot2_addr_i when the LF are valid")
  u_ovl_lf_mngmt_37   (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (|lf_descr_valid & stb_slots_valid_i[2]),
                       .consequent_expr (biu_store_pa_hz_slot2[40:6] == {stb_slots_ns_dsc_i[2], stb_slot2_addr_i[39:6]}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "biu_store_pa_hz_slot3 must match stb_slot3_addr_i when the LF are valid")
  u_ovl_lf_mngmt_38   (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (|lf_descr_valid & stb_slots_valid_i[3]),
                       .consequent_expr (biu_store_pa_hz_slot3[40:6] == {stb_slots_ns_dsc_i[3], stb_slot3_addr_i[39:6]}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "biu_store_pa_hz_slot4 must match stb_slot4_addr_i when the LF are valid")
  u_ovl_lf_mngmt_39   (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (|lf_descr_valid & stb_slots_valid_i[4]),
                       .consequent_expr (biu_store_pa_hz_slot4[40:6] == {stb_slots_ns_dsc_i[4], stb_slot4_addr_i[39:6]}));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "biu_excl_lf_in_progress must never be unknown")
  u_ovl_lf_mngmt_40     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (biu_excl_lf_in_progress));

  assert_never_unknown #(`OVL_FATAL, 3, `OVL_ASSERT, "dpu_enable_data_prefetch_prev_cycle must never be unknown")
  u_ovl_lf_mngmt_41     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (dpu_enable_data_prefetch_prev_cycle));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "dpu_enable_data_prefetch_streams_prev_cycle must never be unknown")
  u_ovl_lf_mngmt_42     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (dpu_enable_data_prefetch_streams_prev_cycle));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "dpu_data_prefetch_stride_detect_prev_cycle must never be unknown")
  u_ovl_lf_mngmt_43     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (dpu_data_prefetch_stride_detect_prev_cycle));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "dpu_disable_data_prefetch_stores_pattern_prev_cycle must never be unknown")
  u_ovl_lf_mngmt_44     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (dpu_disable_data_prefetch_stores_pattern_prev_cycle));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "dpu_disable_data_prefetch_readunique_prev_cycle must never be unknown")
  u_ovl_lf_mngmt_45     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (dpu_disable_data_prefetch_readunique_prev_cycle));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "gov_wfx_drain_req_prev_cycle must never be unknown")
  u_ovl_lf_mngmt_46     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (gov_wfx_drain_req_prev_cycle));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "tlb_mem_granule_cpy must never be unknown")
  u_ovl_lf_mngmt_47     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (tlb_mem_granule_cpy));

  assert_implication   #(`OVL_FATAL, `OVL_ASSERT, "The clock must be enabled when there is an arbitrated LF request next clock cycle from the data prefetch streams or DC1")
  u_ovl_lf_mngmt_48     (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (pf_lf_en),
                         .consequent_expr (clk_enable));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "next_clk_enable must never be unknown")
  u_ovl_lf_mngmt_49     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (next_clk_enable));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "The prefetch streams must be in progress, if a linefill descriptor was initiated from prefetch previous cycle")
  u_ovl_lf_mngmt_50     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (|lf_descr_biu_evnt_pf_lf[`CA53_BIU_LF_DESCR_NUM-1:0]),
                         .test_expr (&pf_stream_idle));

`endif

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53biu_defs.v"
`undef CA53_UNDEFINE

endmodule // ca53biu_linefills_mngmt
