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
// Abstract : BIU (Bus Interface Unit) Top Level
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// The Bus Interface Unit (BIU) is responsible for driving the SCU read/write
// interfaces. The BIU also contains buffering to decouple the IFU
// and the data cache from the BIU-SCU interface.
// The state machines to control data side linefills live inside the BIU.

`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53biu_defs.v"

module ca53biu
  `CA53_BIU_PARAM_DECL
    (

     //------------------------------------------------------------------------------
     // Clock and Reset
     //------------------------------------------------------------------------------

     input wire                             clk,
     input wire                             reset_n,
     input wire                             DFTSE,

     //------------------------------------------------------------------------------
     // RAMs Interface
     //------------------------------------------------------------------------------

     input wire [2:0]                       dc_size_i,

     //------------------------------------------------------------------------------
     // DPU Interface
     //------------------------------------------------------------------------------

     output wire                            biu_w_imp_abort_o,
     output wire [1:0]                      biu_w_imp_fault_o,
     output wire [1:0]                      biu_evnt_ext_mem_req_o,
     output wire [1:0]                      biu_evnt_ext_mem_req_nc_o,
     output wire                            biu_evnt_rw_lf_o,
     output wire                            biu_evnt_pf_lf_o,
     output wire                            biu_evnt_ramode_o,
     output wire                            biu_evnt_ramode_enter_o,
     input  wire                            dpu_dcache_on_i,
     input  wire [1:0]                      dpu_ramode_cnt_l1_i,
     input  wire [1:0]                      dpu_ramode_cnt_l2_i,
     input  wire                            dpu_disable_device_split_throttle_i,
     input  wire [2:0]                      dpu_enable_data_prefetch_i,
     input  wire [1:0]                      dpu_enable_data_prefetch_streams_i,
     input  wire                            dpu_data_prefetch_stride_detect_i,
     input  wire                            dpu_disable_data_prefetch_stores_pattern_i,
     input  wire                            dpu_disable_data_prefetch_readunique_i,
     input  wire                            dpu_kill_wr_i,
     input  wire                            dpu_flush_i,
     input  wire                            dpu_ready_wr_i,
     input  wire                            dpu_ready_cc_fail_wr_i,
     input  wire [39:12]                    dpu_pa_dc1_i,
     input  wire [11:4]                     dpu_va_dc1_i,
     input  wire                            dpu_ns_dsc_dc1_i,

     //------------------------------------------------------------------------------
     // GOV Interface
     //------------------------------------------------------------------------------

     input  wire                            gov_mbist_req_i,
     input  wire                            gov_wfx_drain_req_i,
     output wire                            biu_wfx_ready_o,

     //------------------------------------------------------------------------------
     // SCU Interface
     //------------------------------------------------------------------------------

     input  wire                            scu_ar_credit_i,
     input  wire                            scu_ar_block_i,
     output wire                            biu_ar_active_o,
     output wire                            biu_ar_valid_o,
     output wire [4:0]                      biu_ar_id_o,
     output wire [4:0]                      biu_ar_type_o,
     output wire [7:0]                      biu_ar_attrs_o,
     output wire [4:0]                      biu_ar_way_o,
     output wire [40:0]                     biu_ar_addr_o,
     output wire [1:0]                      biu_ar_len_o,
     output wire [2:0]                      biu_ar_size_o,
     output wire                            biu_ar_lock_o,
     output wire                            biu_ar_priv_o,
     output wire                            biu_dr_credit_o,
     input  wire                            scu_dr_valid_i,
     input  wire [4:0]                      scu_dr_id_i,
     input  wire [5:0]                      scu_dr_resp_i,
     input  wire [1:0]                      scu_dr_chunk_i,
     input  wire [127:0]                    scu_dr_data_i,
     input  wire                            scu_rr_valid_i,
     input  wire [4:0]                      scu_rr_id_i,
     input  wire [1:0]                      scu_rr_resp_i,
     input  wire [3:0]                      scu_rr_l2db_id_i,
     input  wire [7:0]                      scu_ev_done_i,
     output wire                            biu_dw_valid_o,
     output wire [3:0]                      biu_dw_l2db_id_o,
     output wire [3:0]                      biu_dw_chunks_valid_o,
     output wire                            biu_dw_last_o,
     output wire [255:0]                    biu_dw_data_o,
     output wire [31:0]                     biu_dw_strb_o,
     output wire                            biu_dw_err_o,
     output wire                            biu_dw_fatal_o,
     input  wire                            scu_db_excl_valid_i,
     input  wire [1:0]                      scu_db_excl_resp_i,
     input  wire                            scu_db_decerr_i,
     input  wire                            scu_db_slverr_i,
     input  wire                            scu_leave_ramode_i,

     //------------------------------------------------------------------------------
     // TLB Interface
     //------------------------------------------------------------------------------

     input  wire [1:0]                      tlb_mem_granule_i,
     input  wire [39:0]                     tlb_walk_addr_i,
     input  wire [7:0]                      tlb_walk_attrs_i,
     input  wire                            tlb_walk_ns_dsc_i,
     input  wire                            tlb_walk_size_i,
     input  wire                            tlb_walk_nc_req_i,
     input  wire                            tlb_walk_lf_active_i,
     input  wire                            tlb_walk_lf_req_i,
     output wire                            biu_walk_ack_o,
     output wire [2:0]                      biu_walk_resp_o,
     output wire [63:0]                     biu_walk_data_o,
     output wire                            biu_walk_lf_hazard_o,
     input  wire [1:0]                      tlb_walk_way_i,

     //------------------------------------------------------------------------------
     // DCU Interface
     //------------------------------------------------------------------------------

     input  wire                            dcu_lf_active_i,
     input  wire                            dcu_leaving_dc1_i,
     input  wire                            dcu_load_dc1_i,
     input  wire                            dcu_load_dc2_i,
     input  wire [8:0]                      dcu_mbist_array_mb3_i,
     input  wire                            dcu_biu_active_i,
     input  wire                            dcu_biu_req_dc2_i,
     input  wire [39:0]                     dcu_pa_dc2_i,
     input  wire                            dcu_ns_dsc_dc2_i,
     input  wire [7:0]                      dcu_attrs_dc2_i,
     input  wire [1:0]                      dcu_size_dc2_i,
     input  wire [3:0]                      dcu_length_dc2_i,
     input  wire                            dcu_pld_l2_req_dc2_i,
     input  wire                            dcu_exclusive_dc2_i,
     input  wire                            dcu_lf_req_dc1_i,
     input  wire [1:0]                      dcu_lf_way_dc1_i,
     input  wire [7:0]                      dcu_attrs_dc1_i,
     input  wire                            dcu_lf_req_dc2_i,
     input  wire [1:0]                      dcu_lf_way_dc2_i,
     input  wire                            dcu_leaving_dc2_i,
     output wire                            biu_pld_l2_next_ready_o,
     output wire                            biu_read_data_valid_dc2_o,
     output wire [63:0]                     biu_read_data_dc2_o,
     output wire                            biu_read_abort_dc2_o,
     output wire [1:0]                      biu_read_fault_dc2_o,
     output wire                            biu_suppress_load_hit_dc2_o,
     input  wire                            dcu_load_dc3_i,
     input  wire                            dcu_lf_req_dc3_i,
     input  wire [1:0]                      dcu_lf_way_dc3_i,
     output wire                            biu_lf_ready_dc2_o,
     output wire                            biu_lf_next_ready_dc3_o,
     input  wire                            dcu_neon_access_dc3_i,
     input  wire                            dcu_biu_req_dc3_i,
     input  wire                            dcu_stb_req_dc3_i,
     input  wire [39:0]                     dcu_pa_dc3_i,
     input  wire                            dcu_pipe_valid_dc3_i,
     input  wire                            dcu_valid_dc3_i,
     input  wire                            dcu_ns_dsc_dc3_i,
     input  wire                            dcu_priv_dc3_i,
     input  wire [7:0]                      dcu_attrs_dc3_i,
     input  wire [1:0]                      dcu_size_dc3_i,
     input  wire [3:0]                      dcu_length_dc3_i,
     input  wire                            dcu_exclusive_dc3_i,
     input  wire                            dcu_pldw_dc3_i,
     input  wire                            dcu_pld_l2_req_dc3_i,
     input  wire                            dcu_stop_pf_i,
     input  wire                            dcu_drain_stb_lf_i,
     output wire                            biu_read_data_valid_dc3_o,
     output wire [63:0]                     biu_read_data_dc3_o,
     output wire                            biu_read_abort_dc3_o,
     output wire [1:0]                      biu_read_fault_dc3_o,
     input  wire                            dcu_ecc_cinv_req_i,
     output wire                            biu_ecc_cinv_ack_o,
     output wire                            biu_ecc_cinv_complete_o,
     input  wire [7:0]                      dcu_ecc_cinv_index_i,
     input  wire [1:0]                      dcu_ecc_cinv_way_i,
     input  wire [55:0]                     dcu_ecc_syndrome_m3_i,
     input  wire                            dcu_ecc_fatal_m3_i,
     input  wire                            dcu_ecc_tag_err_m3_i,
     input  wire                            dcu_snoop_dw_active_i,
     input  wire                            dcu_snoop_valid_m2_i,
     input  wire [255:0]                    dcu_snoop_data_m2_i,
     input  wire [1:0]                      dcu_snoop_chunk_m2_i,
     input  wire [1:0]                      dcu_snoop_rotate_m2_i,
     input  wire [3:0]                      dcu_snoop_l2db_id_m2_i,
     input  wire                            dcu_snoop_last_m2_i,
     output wire [7:0]                      biu_lf_in_progress_o,
     output wire [3:0]                      biu_pf_in_progress_o,
     output wire [255:0]                    biu_alloc_data_m0_o,
     output wire                            biu_alloc_tag_req_m0_o,
     output wire                            biu_alloc_data_req_m0_o,
     output wire                            biu_alloc_halfline_m0_o,
     output wire                            biu_alloc_dirty_req_m0_o,
     output wire [39:4]                     biu_alloc_addr_m0_o,
     output wire                            biu_alloc_ns_dsc_m0_o,
     output wire [3:0]                      biu_alloc_way_m0_o,
     output wire [1:0]                      biu_alloc_tag_moesi_m0_o,
     input  wire                            dcu_alloc_has_priority_m0_i,
     output wire [1:0]                      biu_alloc_dirty_moesi_m1_o,
     output wire                            biu_alloc_dirty_age_m1_o,
     output wire [7:0]                      biu_alloc_attrs_m1_o,
     input  wire                            dcu_alloc_ack_m1_i,
     input  wire                            dcu_stb_data_ack_m1_i,
     output wire                            biu_pf_tag_req_m0_o,
     output wire [39:6]                     biu_pf_tag_addr_m0_o,
     output wire                            biu_pf_tag_ns_dsc_m0_o,
     input  wire                            dcu_pf_tag_has_priority_m0_i,
     input  wire                            dcu_pf_tag_ack_m1_i,
     input  wire                            dcu_pf_tag_hit_m2_i,
     input  wire                            dcu_ccb_req_active_i,
     input  wire [3:0]                      dcu_ccb_ways_i,
     input  wire [13:6]                     dcu_ccb_index_i,
     output wire                            biu_ccb_lf_hazard_o,
     output wire                            biu_strex_bresp_valid_o,
     output wire [1:0]                      biu_strex_bresp_o,
     output wire                            biu_suppress_tlb_hit_o,

     //------------------------------------------------------------------------------
     // IFU Interface
     //------------------------------------------------------------------------------

     output wire                            biu_i_arready_o,
     output wire                            biu_i_rvalid_o,
     output wire [1:0]                      biu_i_rid_o,
     output wire [127:0]                    biu_i_rdata_o,
     output wire [2:0]                      biu_i_rresp_o,
     output wire [1:0]                      biu_i_rchunk_o,
     input  wire                            ifu_arvalid_i,
     input  wire [1:0]                      ifu_arid_i,
     input  wire [39:0]                     ifu_araddr_i,
     input  wire [1:0]                      ifu_arlen_i,
     input  wire [7:0]                      ifu_attrs_i,
     input  wire [1:0]                      ifu_arprot_i,
     input  wire                            ifu_rready_i,
     input  wire [2:0]                      ifu_outstanding_lfb_i,

     //------------------------------------------------------------------------------
     // STB Interface
     //------------------------------------------------------------------------------

     input  wire [4:0]                      stb_slots_valid_i,
     input  wire [39:0]                     stb_slot0_addr_i,
     input  wire [39:0]                     stb_slot1_addr_i,
     input  wire [39:0]                     stb_slot2_addr_i,
     input  wire [39:0]                     stb_slot3_addr_i,
     input  wire [39:0]                     stb_slot4_addr_i,
     input  wire [4:0]                      stb_slots_ns_dsc_i,
     input  wire [1:0]                      stb_slot0_way_i,
     input  wire [1:0]                      stb_slot1_way_i,
     input  wire [1:0]                      stb_slot2_way_i,
     input  wire [1:0]                      stb_slot3_way_i,
     input  wire [1:0]                      stb_slot4_way_i,
     input  wire [7:0]                      stb_slot0_attrs_i,
     input  wire [7:0]                      stb_slot1_attrs_i,
     input  wire [7:0]                      stb_slot2_attrs_i,
     input  wire [7:0]                      stb_slot3_attrs_i,
     input  wire [7:0]                      stb_slot4_attrs_i,
     output wire [4:0]                      biu_lf_hazard_o,
     output wire [4:0]                      biu_lf_real_hazard_o,
     output wire [4:0]                      biu_lf_hazard_migratory_o,
     output wire [1:0]                      biu_lf_hazard_way_slot0_o,
     output wire [1:0]                      biu_lf_hazard_way_slot1_o,
     output wire [1:0]                      biu_lf_hazard_way_slot2_o,
     output wire [1:0]                      biu_lf_hazard_way_slot3_o,
     output wire [1:0]                      biu_lf_hazard_way_slot4_o,
     output wire [4:0]                      biu_lf_serialized_o,
     output wire [4:0]                      biu_ev_hazard_o,
     input  wire                            stb_lf_active_i,
     input  wire [4:0]                      stb_lf_req_i,
     input  wire [4:0]                      stb_lf_merge_i,
     input  wire [4:0]                      stb_lf_earliest_slot_i,
     output wire [4:0]                      biu_lf_can_merge_o,
     input  wire [4:0]                      stb_slot_cachewrite_m1_i,
     input  wire                            stb_biu_write_req_i,
     input  wire [3:0]                      stb_biu_write_l2dbid_i,
     input  wire [1:0]                      stb_biu_write_chunk_i,
     input  wire [127:0]                    stb_biu_write_data_i,
     input  wire [15:0]                     stb_biu_write_bls_i,
     input  wire                            stb_biu_write_last_i,
     output wire                            biu_stb_write_accept_o,
     input  wire                            stb_biu_write_req_active_i,
     output wire                            biu_read_alloc_mode_o,
     input  wire                            stb_ar_req_i,
     input  wire                            stb_ar_early_req_i,
     input  wire [4:0]                      stb_ar_id_i,
     input  wire [1:0]                      stb_ar_way_i,
     input  wire [7:0]                      stb_ar_type_i,
     input  wire [39:0]                     stb_ar_addr_i,
     input  wire                            stb_ar_ns_dsc_i,
     input  wire [7:0]                      stb_ar_attrs_i,
     input  wire                            stb_ar_priv_i,
     input  wire                            stb_ar_excl_i,
     input  wire [15:0]                     stb_ar_asid_i,
     input  wire [7:0]                      stb_ar_vmid_i,
     input  wire [24:0]                     stb_ar_va_i,
     output wire                            biu_stb_ar_ack_o,
     output wire                            biu_stb_ar_resp_valid_o,
     output wire [1:0]                      biu_stb_ar_resp_o,
     output wire [4:0]                      biu_stb_ar_resp_id_o,
     output wire [3:0]                      biu_stb_ar_resp_l2dbid_o,
     output wire                            biu_dirty_lf_in_progress_o,
     output wire                            biu_excl_lf_in_progress_o,

     //------------------------------------------------------------------------------
     // MBIST Dedicated Data-path Interface
     //------------------------------------------------------------------------------

     input  wire [116:0]                    tlb_mbist_out_data_mb6_i,
     input  wire [`CA53_IDATA_RAM_W-1:0]    ifu_mbist_out_data_mb6_i,
     input  wire [63:0]                     dcu_mbist_out_data_mb6_i,
     input  wire [6:0]                      dcu_mbist_data_checkbits_mb6_i,
     output wire [52:0]                     biu_mbist_in_data_hi_mb3_o

     );

  //------------------------------------------------------------------------------
  // Registers
  //------------------------------------------------------------------------------

  reg                                                     biu_wfx_ready;
  reg                                                     biu_w_imp_abort;
  reg  [1:0]                                              biu_w_imp_fault;
  reg                                                     biu_mbist_req;
  reg  [`DCU_MBIST_ARRAY_W-1:0]                           biu_mbist_array;

  //------------------------------------------------------------------------------
  // Wires
  //------------------------------------------------------------------------------

  wire                                                    next_biu_wfx_ready;
  wire                                                    biu_ar_valid;
  wire [4:0]                                              biu_ar_id;
  wire [40:0]                                             biu_ar_addr;
  wire [7:0]                                              biu_ar_attrs;
  wire [4:0]                                              biu_ar_type;
  wire [1:0]                                              biu_ar_len;
  wire [2:0]                                              biu_ar_lf_master;
  wire                                                    biu_dr_credit;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                       biu_lf_in_progress;
  wire [4:0]                                              biu_lf_hazard;
  wire                                                    biu_dirty_lf_in_progress;
  wire                                                    biu_read_data_valid_dc2;
  wire                                                    biu_read_data_valid_dc3;
  wire                                                    biu_read_data_valid_dc3_dev;
  wire                                                    biu_walk_ack;
  wire                                                    biu_ar_ready_dev;
  wire [2:0]                                              biu_ar_id_dev;
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]                      dcu_nc_ar_id_used;
  wire                                                    pld_l2_ar_id_used;
  wire                                                    dc2_trans_outstanding;
  wire [1:0]                                              dc2_trans_outstanding_id;
  wire                                                    dc2_trans_last_beat;
  wire                                                    dc3_trans_outstanding;
  wire [1:0]                                              dc3_trans_outstanding_id;
  wire [1:0]                                              dc3_trans_cross128;
  wire                                                    dc3_trans_last_beat;
  wire                                                    tlb_nc_load_outstanding;
  wire                                                    dev_active;
  wire                                                    dev_req;
  wire [5:0]                                              dev_addr;
  wire [2:0]                                              dev_size;
  wire [1:0]                                              dev_length;
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]                      dev_id_outstanding;
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]                      dev_id_pending;
  wire                                                    dev_idle;
  wire                                                    write_imp_abort;
  wire                                                    write_imp_fault;
  wire                                                    wbuf_valid;
  wire                                                    linefill_imp_abort;
  wire [1:0]                                              linefill_imp_fault;
  wire                                                    cp15_coh_imp_abort;
  wire                                                    cp15_coh_imp_fault;
  wire                                                    biu_lf_req;
  wire [39:4]                                             biu_lf_addr;
  wire                                                    biu_lf_ns_dsc;
  wire [7:0]                                              biu_lf_attrs;
  wire [3:0]                                              biu_lf_way;
  wire [2:0]                                              biu_lf_descr_id;
  wire [2:0]                                              biu_lf_master;
  wire                                                    biu_lf_ack;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                          rbuf_valid;
  wire [128*`CA53_BIU_RBUFS_NUM-1:0]                      rbuf_data_packed;
  wire [2*`CA53_BIU_RBUFS_NUM-1:0]                        rbuf_chunk_packed;
  wire [`CA53_BIU_LF_DESCR_NUM_W*`CA53_BIU_RBUFS_NUM-1:0] rbuf_id_packed;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                          rbuf_age;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                          rbuf_for_lf_valid;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                          rbuf_for_lf_oldest_sel;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                       lf_descr_for_dc2;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                       lf_descr_for_dc3;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                       lf_descr_for_tlb;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                       lf_descr_evict_done;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                          biu_alloc_rbuf_clr;
  wire                                                    next_biu_w_imp_abort;
  wire [1:0]                                              next_biu_w_imp_fault;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                       biu_alloc_lf_descr_m0;
  wire [3:0]                                              biu_alloc_chunk_req_m0;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                       biu_alloc_lf_descr_m1;
  wire [3:0]                                              biu_alloc_chunk_req_m1;
  wire                                                    biu_cc_fail_or_flush_dc3;
  wire                                                    biu_leaving_dc3;
  wire                                                    biu_load_dc3;
  wire [5:0]                                              biu_load_pa_dc3;
  wire [`CA53_BIU_PF_STREAM_NUM-1:0]                      pf_stream_idle;
  wire                                                    pf_lf_active;
  wire                                                    ar_block;
  wire [3:0]                                              ar_credits_used;
  wire                                                    stb_is_dvm;
  wire                                                    lf_descr_inc_ramode;
  wire                                                    lf_descr_leave_ramode;
  wire                                                    biu_evnt_ramode;
  wire                                                    biu_read_alloc_pend;

  //------------------------------------------------------------------------------
  // AR channel - Addr request arbiter
  //------------------------------------------------------------------------------

  ca53biu_addr_req_arbiter u_addr_req_arbiter (
    .clk                                 (clk),
    .reset_n                             (reset_n),
    .dpu_ramode_cnt_l1_i                 (dpu_ramode_cnt_l1_i),
    .dpu_ramode_cnt_l2_i                 (dpu_ramode_cnt_l2_i),
    .ifu_arvalid_i                       (ifu_arvalid_i),
    .ifu_arid_i                          (ifu_arid_i),
    .ifu_araddr_i                        (ifu_araddr_i),
    .ifu_arlen_i                         (ifu_arlen_i),
    .ifu_attrs_i                         (ifu_attrs_i),
    .ifu_arprot_i                        (ifu_arprot_i),
    .biu_i_arready_o                     (biu_i_arready_o),
    .tlb_walk_nc_req_i                   (tlb_walk_nc_req_i),
    .tlb_walk_lf_req_i                   (tlb_walk_lf_req_i),
    .tlb_walk_addr_i                     (tlb_walk_addr_i),
    .tlb_walk_ns_dsc_i                   (tlb_walk_ns_dsc_i),
    .tlb_walk_size_i                     (tlb_walk_size_i),
    .tlb_walk_attrs_i                    (tlb_walk_attrs_i),
    .dcu_ecc_cinv_req_i                  (dcu_ecc_cinv_req_i),
    .biu_ecc_cinv_ack_o                  (biu_ecc_cinv_ack_o),
    .dcu_ecc_cinv_index_i                (dcu_ecc_cinv_index_i),
    .dcu_ecc_cinv_way_i                  (dcu_ecc_cinv_way_i),
    .dpu_dcache_on_i                     (dpu_dcache_on_i),
    .dpu_kill_wr_i                       (dpu_kill_wr_i),
    .dpu_flush_i                         (dpu_flush_i),
    .dpu_ready_wr_i                      (dpu_ready_wr_i),
    .dpu_ready_cc_fail_wr_i              (dpu_ready_cc_fail_wr_i),
    .dcu_biu_active_i                    (dcu_biu_active_i),
    .dcu_load_dc2_i                      (dcu_load_dc2_i),
    .dcu_biu_req_dc2_i                   (dcu_biu_req_dc2_i),
    .dcu_pa_dc2_i                        (dcu_pa_dc2_i),
    .dcu_ns_dsc_dc2_i                    (dcu_ns_dsc_dc2_i),
    .dcu_attrs_dc2_i                     (dcu_attrs_dc2_i),
    .dcu_size_dc2_i                      (dcu_size_dc2_i),
    .dcu_length_dc2_i                    (dcu_length_dc2_i),
    .dcu_pld_l2_req_dc2_i                (dcu_pld_l2_req_dc2_i),
    .dcu_leaving_dc2_i                   (dcu_leaving_dc2_i),
    .dcu_load_dc3_i                      (dcu_load_dc3_i),
    .dcu_biu_req_dc3_i                   (dcu_biu_req_dc3_i),
    .dcu_pa_dc3_i                        (dcu_pa_dc3_i[39:6]),
    .dcu_pipe_valid_dc3_i                (dcu_pipe_valid_dc3_i),
    .dcu_valid_dc3_i                     (dcu_valid_dc3_i),
    .dcu_ns_dsc_dc3_i                    (dcu_ns_dsc_dc3_i),
    .dcu_priv_dc3_i                      (dcu_priv_dc3_i),
    .dcu_attrs_dc3_i                     (dcu_attrs_dc3_i),
    .dcu_size_dc3_i                      (dcu_size_dc3_i),
    .dcu_length_dc3_i                    (dcu_length_dc3_i),
    .dcu_pld_l2_req_dc3_i                (dcu_pld_l2_req_dc3_i),
    .dcu_exclusive_dc3_i                 (dcu_exclusive_dc3_i),
    .biu_pld_l2_next_ready_o             (biu_pld_l2_next_ready_o),
    .biu_cc_fail_or_flush_dc3_o          (biu_cc_fail_or_flush_dc3),
    .biu_leaving_dc3_o                   (biu_leaving_dc3),
    .biu_load_dc3_o                      (biu_load_dc3),
    .biu_load_pa_dc3_o                   (biu_load_pa_dc3),
    .pf_lf_active_i                      (pf_lf_active),
    .biu_lf_req_i                        (biu_lf_req),
    .biu_lf_addr_i                       (biu_lf_addr),
    .biu_lf_ns_dsc_i                     (biu_lf_ns_dsc),
    .biu_lf_attrs_i                      (biu_lf_attrs),
    .biu_lf_way_i                        (biu_lf_way),
    .biu_lf_descr_id_i                   (biu_lf_descr_id),
    .biu_lf_master_i                     (biu_lf_master),
    .biu_lf_ack_o                        (biu_lf_ack),
    .biu_dirty_lf_in_progress_i          (biu_dirty_lf_in_progress),
    .dev_active_i                        (dev_active),
    .dev_req_i                           (dev_req),
    .dev_addr_i                          (dev_addr),
    .dev_size_i                          (dev_size),
    .dev_length_i                        (dev_length),
    .stb_ar_req_i                        (stb_ar_req_i),
    .stb_ar_early_req_i                  (stb_ar_early_req_i),
    .stb_ar_id_i                         (stb_ar_id_i),
    .stb_ar_way_i                        (stb_ar_way_i),
    .stb_ar_type_i                       (stb_ar_type_i),
    .stb_ar_addr_i                       (stb_ar_addr_i),
    .stb_ar_ns_dsc_i                     (stb_ar_ns_dsc_i),
    .stb_ar_attrs_i                      (stb_ar_attrs_i),
    .stb_ar_priv_i                       (stb_ar_priv_i),
    .stb_ar_excl_i                       (stb_ar_excl_i),
    .stb_ar_asid_i                       (stb_ar_asid_i),
    .stb_ar_vmid_i                       (stb_ar_vmid_i),
    .stb_ar_va_i                         (stb_ar_va_i),
    .biu_stb_ar_ack_o                    (biu_stb_ar_ack_o),
    .biu_lf_hazard_i                     (biu_lf_hazard),
    .scu_ar_credit_i                     (scu_ar_credit_i),
    .scu_ar_block_i                      (scu_ar_block_i),
    .biu_ar_active_o                     (biu_ar_active_o),
    .biu_ar_valid_o                      (biu_ar_valid),
    .biu_ar_id_o                         (biu_ar_id),
    .biu_ar_type_o                       (biu_ar_type),
    .biu_ar_attrs_o                      (biu_ar_attrs),
    .biu_ar_way_o                        (biu_ar_way_o),
    .biu_ar_addr_o                       (biu_ar_addr),
    .biu_ar_len_o                        (biu_ar_len),
    .biu_ar_size_o                       (biu_ar_size_o),
    .biu_ar_lock_o                       (biu_ar_lock_o),
    .biu_ar_priv_o                       (biu_ar_priv_o),
    .biu_ar_lf_master_o                  (biu_ar_lf_master),
    .scu_leave_ramode_i                  (scu_leave_ramode_i),
    .lf_descr_inc_ramode_i               (lf_descr_inc_ramode),
    .lf_descr_leave_ramode_i             (lf_descr_leave_ramode),
    .biu_evnt_ramode_o                   (biu_evnt_ramode),
    .biu_evnt_ramode_enter_o             (biu_evnt_ramode_enter_o),
    .biu_read_alloc_pend_o               (biu_read_alloc_pend),
    .dcu_nc_ar_id_used_i                 (dcu_nc_ar_id_used),
    .pld_l2_ar_id_used_i                 (pld_l2_ar_id_used),
    .data_fwd_dc2_i                      (biu_read_data_valid_dc2),
    .data_fwd_dc3_i                      (biu_read_data_valid_dc3),
    .data_fwd_tlb_i                      (biu_walk_ack),
    .dc2_trans_outstanding_o             (dc2_trans_outstanding),
    .dc2_trans_outstanding_id_o          (dc2_trans_outstanding_id),
    .dc2_trans_last_beat_o               (dc2_trans_last_beat),
    .dc3_trans_outstanding_o             (dc3_trans_outstanding),
    .dc3_trans_outstanding_id_o          (dc3_trans_outstanding_id),
    .dc3_trans_cross128_o                (dc3_trans_cross128),
    .dc3_trans_last_beat_o               (dc3_trans_last_beat),
    .tlb_nc_load_outstanding_o           (tlb_nc_load_outstanding),
    .biu_ar_ready_dev_o                  (biu_ar_ready_dev),
    .biu_ar_id_dev_o                     (biu_ar_id_dev),
    .ar_block_o                          (ar_block),
    .ar_credits_used_o                   (ar_credits_used),
    .stb_is_dvm_o                        (stb_is_dvm),
    .biu_evnt_ext_mem_req_o              (biu_evnt_ext_mem_req_o),
    .biu_evnt_ext_mem_req_nc_o           (biu_evnt_ext_mem_req_nc_o)
  );  // u_addr_req_arbiter

  //------------------------------------------------------------------------------
  // Device loads split management
  //------------------------------------------------------------------------------

  ca53biu_devsplit_mngmt u_ca53biu_devsplit_mngmt (
    .clk                                 (clk),
    .reset_n                             (reset_n),
    .dpu_disable_device_split_throttle_i (dpu_disable_device_split_throttle_i),
    .biu_cc_fail_or_flush_dc3_i          (biu_cc_fail_or_flush_dc3),
    .biu_leaving_dc3_i                   (biu_leaving_dc3),
    .biu_load_dc3_i                      (biu_load_dc3),
    .biu_load_pa_dc3_i                   (biu_load_pa_dc3),
    .dcu_neon_access_dc3_i               (dcu_neon_access_dc3_i),
    .dcu_biu_req_dc3_i                   (dcu_biu_req_dc3_i),
    .dcu_attrs_dc3_i                     (dcu_attrs_dc3_i),
    .dcu_size_dc3_i                      (dcu_size_dc3_i),
    .dcu_length_dc3_i                    (dcu_length_dc3_i),
    .dc3_trans_cross128_i                (dc3_trans_cross128),
    .dc3_trans_last_beat_i               (dc3_trans_last_beat),
    .biu_ar_ready_dev_i                  (biu_ar_ready_dev),
    .biu_ar_id_dev_i                     (biu_ar_id_dev),
    .data_fwd_dc3_i                      (biu_read_data_valid_dc3_dev),
    .dev_active_o                        (dev_active),
    .dev_req_o                           (dev_req),
    .dev_addr_o                          (dev_addr),
    .dev_size_o                          (dev_size),
    .dev_length_o                        (dev_length),
    .dev_id_outstanding_o                (dev_id_outstanding),
    .dev_id_pending_o                    (dev_id_pending),
    .dev_idle_o                          (dev_idle)
  ); // u_ca53biu_devsplit_mngmt

  //------------------------------------------------------------------------------
  // DR channel - Data read buffers
  //------------------------------------------------------------------------------

  ca53biu_data_read_buffers u_ca53biu_data_read_buffers (
    .clk                                 (clk),
    .reset_n                             (reset_n),
    .DFTSE                               (DFTSE),
    .biu_mbist_req_i                     (biu_mbist_req),
    .biu_mbist_in_data_hi_mb3_o          (biu_mbist_in_data_hi_mb3_o),
    .biu_ar_valid_i                      (biu_ar_valid),
    .biu_ar_id_i                         (biu_ar_id),
    .biu_ar_len_i                        (biu_ar_len),
    .biu_dr_credit_o                     (biu_dr_credit),
    .scu_dr_valid_i                      (scu_dr_valid_i),
    .scu_dr_id_i                         (scu_dr_id_i),
    .scu_dr_resp_i                       (scu_dr_resp_i),
    .scu_dr_chunk_i                      (scu_dr_chunk_i),
    .scu_dr_data_i                       (scu_dr_data_i),
    .scu_rr_valid_i                      (scu_rr_valid_i),
    .scu_rr_id_i                         (scu_rr_id_i),
    .scu_rr_resp_i                       (scu_rr_resp_i),
    .scu_rr_l2db_id_i                    (scu_rr_l2db_id_i),
    .biu_i_rvalid_o                      (biu_i_rvalid_o),
    .biu_i_rid_o                         (biu_i_rid_o),
    .biu_i_rdata_o                       (biu_i_rdata_o),
    .biu_i_rresp_o                       (biu_i_rresp_o),
    .biu_i_rchunk_o                      (biu_i_rchunk_o),
    .ifu_rready_i                        (ifu_rready_i),
    .ifu_outstanding_lfb_i               (ifu_outstanding_lfb_i),
    .biu_walk_ack_o                      (biu_walk_ack),
    .biu_walk_resp_o                     (biu_walk_resp_o),
    .biu_walk_data_o                     (biu_walk_data_o),
    .dcu_load_dc2_i                      (dcu_load_dc2_i),
    .dcu_load_dc3_i                      (dcu_load_dc3_i),
    .dcu_biu_req_dc2_i                   (dcu_biu_req_dc2_i),
    .dcu_biu_req_dc3_i                   (dcu_biu_req_dc3_i),
    .dcu_exclusive_dc2_i                 (dcu_exclusive_dc2_i),
    .dcu_exclusive_dc3_i                 (dcu_exclusive_dc3_i),
    .biu_read_data_valid_dc2_o           (biu_read_data_valid_dc2),
    .biu_read_data_dc2_o                 (biu_read_data_dc2_o),
    .biu_read_abort_dc2_o                (biu_read_abort_dc2_o),
    .biu_read_fault_dc2_o                (biu_read_fault_dc2_o[1:0]),
    .biu_read_data_valid_dc3_dev_o       (biu_read_data_valid_dc3_dev),
    .biu_read_data_valid_dc3_o           (biu_read_data_valid_dc3),
    .biu_read_data_dc3_o                 (biu_read_data_dc3_o),
    .biu_read_abort_dc3_o                (biu_read_abort_dc3_o),
    .biu_read_fault_dc3_o                (biu_read_fault_dc3_o[1:0]),
    .biu_ecc_cinv_complete_o             (biu_ecc_cinv_complete_o),
    .biu_stb_ar_resp_valid_o             (biu_stb_ar_resp_valid_o),
    .biu_stb_ar_resp_o                   (biu_stb_ar_resp_o),
    .biu_stb_ar_resp_id_o                (biu_stb_ar_resp_id_o),
    .biu_stb_ar_resp_l2dbid_o            (biu_stb_ar_resp_l2dbid_o),
    .dcu_nc_ar_id_used_o                 (dcu_nc_ar_id_used),
    .pld_l2_ar_id_used_o                 (pld_l2_ar_id_used),
    .dc3_trans_valid_i                   (dc3_trans_outstanding),
    .dc3_trans_id_i                      (dc3_trans_outstanding_id),
    .dc3_trans_last_beat_i               (dc3_trans_last_beat),
    .dc3_trans_pa_i                      (biu_load_pa_dc3[5:3]),
    .dc2_trans_valid_i                   (dc2_trans_outstanding),
    .dc2_trans_id_i                      (dc2_trans_outstanding_id),
    .dc2_trans_last_beat_i               (dc2_trans_last_beat),
    .dc2_trans_pa_i                      (dcu_pa_dc2_i[5:3]),
    .tlb_nc_trans_valid_i                (tlb_nc_load_outstanding),
    .tlb_trans_pa_i                      (tlb_walk_addr_i[5:3]),
    .dev_id_outstanding_i                (dev_id_outstanding),
    .dev_id_pending_i                    (dev_id_pending),
    .rbuf_data_packed_o                  (rbuf_data_packed),
    .rbuf_chunk_packed_o                 (rbuf_chunk_packed),
    .rbuf_id_packed_o                    (rbuf_id_packed),
    .rbuf_age_o                          (rbuf_age),
    .rbuf_for_lf_valid_o                 (rbuf_for_lf_valid),
    .rbuf_for_lf_oldest_sel_o            (rbuf_for_lf_oldest_sel),
    .lf_descr_for_dc2_i                  (lf_descr_for_dc2),
    .lf_descr_for_dc3_i                  (lf_descr_for_dc3),
    .lf_descr_for_tlb_i                  (lf_descr_for_tlb),
    .lf_descr_evict_done_i               (lf_descr_evict_done),
    .biu_alloc_rbuf_clr_i                (biu_alloc_rbuf_clr),
    .biu_alloc_lf_descr_m0_i             (biu_alloc_lf_descr_m0),
    .biu_alloc_chunk_req_m0_i            (biu_alloc_chunk_req_m0),
    .biu_alloc_lf_descr_m1_i             (biu_alloc_lf_descr_m1),
    .biu_alloc_chunk_req_m1_i            (biu_alloc_chunk_req_m1),
    .biu_lf_in_progress_i                (biu_lf_in_progress),
    .rbuf_valid_o                        (rbuf_valid),
    .cp15_coh_imp_abort_o                (cp15_coh_imp_abort),
    .cp15_coh_imp_fault_o                (cp15_coh_imp_fault)
  ); // u_ca53biu_data_read_buffers

  //------------------------------------------------------------------------------
  // DW channel - Data write buffers
  //------------------------------------------------------------------------------

  ca53biu_data_write_buffers #(.CPU_CACHE_PROTECTION(CPU_CACHE_PROTECTION)) u_ca53biu_data_write_buffers (
    .clk                                 (clk),
    .reset_n                             (reset_n),
    .DFTSE                               (DFTSE),
    .biu_mbist_req_i                     (biu_mbist_req),
    .biu_mbist_array_i                   (biu_mbist_array),
    .tlb_mbist_out_data_mb6_i            (tlb_mbist_out_data_mb6_i),
    .ifu_mbist_out_data_mb6_i            (ifu_mbist_out_data_mb6_i),
    .dcu_mbist_out_data_mb6_i            (dcu_mbist_out_data_mb6_i),
    .dcu_mbist_data_checkbits_mb6_i      (dcu_mbist_data_checkbits_mb6_i),
    .dcu_ecc_syndrome_m3_i               (dcu_ecc_syndrome_m3_i),
    .dcu_ecc_fatal_m3_i                  (dcu_ecc_fatal_m3_i),
    .dcu_snoop_dw_active_i               (dcu_snoop_dw_active_i),
    .dcu_snoop_valid_m2_i                (dcu_snoop_valid_m2_i),
    .dcu_snoop_data_m2_i                 (dcu_snoop_data_m2_i),
    .dcu_snoop_chunk_m2_i                (dcu_snoop_chunk_m2_i),
    .dcu_snoop_rotate_m2_i               (dcu_snoop_rotate_m2_i),
    .dcu_snoop_l2db_id_m2_i              (dcu_snoop_l2db_id_m2_i),
    .dcu_snoop_last_m2_i                 (dcu_snoop_last_m2_i),
    .biu_strex_bresp_valid_o             (biu_strex_bresp_valid_o),
    .biu_strex_bresp_o                   (biu_strex_bresp_o),
    .stb_biu_write_req_i                 (stb_biu_write_req_i),
    .stb_biu_write_l2dbid_i              (stb_biu_write_l2dbid_i),
    .stb_biu_write_chunk_i               (stb_biu_write_chunk_i),
    .stb_biu_write_data_i                (stb_biu_write_data_i),
    .stb_biu_write_bls_i                 (stb_biu_write_bls_i),
    .stb_biu_write_last_i                (stb_biu_write_last_i),
    .biu_stb_write_accept_o              (biu_stb_write_accept_o),
    .stb_biu_write_req_active_i          (stb_biu_write_req_active_i),
    .biu_dw_valid_o                      (biu_dw_valid_o),
    .biu_dw_l2db_id_o                    (biu_dw_l2db_id_o),
    .biu_dw_chunks_valid_o               (biu_dw_chunks_valid_o),
    .biu_dw_last_o                       (biu_dw_last_o),
    .biu_dw_data_o                       (biu_dw_data_o),
    .biu_dw_strb_o                       (biu_dw_strb_o),
    .biu_dw_err_o                        (biu_dw_err_o),
    .biu_dw_fatal_o                      (biu_dw_fatal_o),
    .scu_db_excl_valid_i                 (scu_db_excl_valid_i),
    .scu_db_excl_resp_i                  (scu_db_excl_resp_i),
    .scu_db_decerr_i                     (scu_db_decerr_i),
    .scu_db_slverr_i                     (scu_db_slverr_i),
    .write_imp_abort_o                   (write_imp_abort),
    .write_imp_fault_o                   (write_imp_fault),
    .wbuf_valid_o                        (wbuf_valid)
  ); // u_ca53biu_data_write_buffers

  //------------------------------------------------------------------------------
  // Linefills management (LFs req, DCU alloc & Prefetcher)
  //------------------------------------------------------------------------------

  ca53biu_linefills_mngmt #(.CPU_CACHE_PROTECTION(CPU_CACHE_PROTECTION)) u_ca53biu_linefills_mngmt (
    .clk                                        (clk),
    .reset_n                                    (reset_n),
    .DFTSE                                      (DFTSE),
    .biu_mbist_req_i                            (biu_mbist_req),
    .dc_size_i                                  (dc_size_i),
    .dpu_dcache_on_i                            (dpu_dcache_on_i),
    .dpu_enable_data_prefetch_i                 (dpu_enable_data_prefetch_i),
    .dpu_enable_data_prefetch_streams_i         (dpu_enable_data_prefetch_streams_i),
    .dpu_data_prefetch_stride_detect_i          (dpu_data_prefetch_stride_detect_i),
    .dpu_disable_data_prefetch_stores_pattern_i (dpu_disable_data_prefetch_stores_pattern_i),
    .dpu_disable_data_prefetch_readunique_i     (dpu_disable_data_prefetch_readunique_i),
    .tlb_mem_granule_i                          (tlb_mem_granule_i),
    .biu_ar_valid_i                             (biu_ar_valid),
    .biu_ar_addr_i                              (biu_ar_addr[40:6]),
    .biu_ar_attrs_i                             (biu_ar_attrs[7:0]),
    .biu_ar_lf_master_i                         (biu_ar_lf_master),
    .dcu_ccb_ways_i                             (dcu_ccb_ways_i),
    .dcu_ccb_index_i                            (dcu_ccb_index_i),
    .biu_ccb_lf_hazard_o                        (biu_ccb_lf_hazard_o),
    .dcu_load_dc1_i                             (dcu_load_dc1_i),
    .dcu_lf_req_dc1_i                           (dcu_lf_req_dc1_i),
    .dcu_lf_way_dc1_i                           (dcu_lf_way_dc1_i),
    .dcu_leaving_dc1_i                          (dcu_leaving_dc1_i),
    .dpu_pa_dc1_i                               (dpu_pa_dc1_i),
    .dpu_va_dc1_i                               (dpu_va_dc1_i),
    .dpu_ns_dsc_dc1_i                           (dpu_ns_dsc_dc1_i),
    .dcu_attrs_dc1_i                            (dcu_attrs_dc1_i),
    .dcu_load_dc2_i                             (dcu_load_dc2_i),
    .dcu_pa_dc2_i                               (dcu_pa_dc2_i[39:4]),
    .dcu_ns_dsc_dc2_i                           (dcu_ns_dsc_dc2_i),
    .dcu_attrs_dc2_i                            (dcu_attrs_dc2_i),
    .dcu_exclusive_dc2_i                        (dcu_exclusive_dc2_i),
    .dcu_lf_req_dc2_i                           (dcu_lf_req_dc2_i),
    .dcu_lf_way_dc2_i                           (dcu_lf_way_dc2_i),
    .dcu_leaving_dc2_i                          (dcu_leaving_dc2_i),
    .dcu_load_dc3_i                             (dcu_load_dc3_i),
    .dcu_lf_req_dc3_i                           (dcu_lf_req_dc3_i),
    .dcu_lf_way_dc3_i                           (dcu_lf_way_dc3_i),
    .dcu_pa_dc3_i                               (dcu_pa_dc3_i[39:4]),
    .dcu_ns_dsc_dc3_i                           (dcu_ns_dsc_dc3_i),
    .dcu_attrs_dc3_i                            (dcu_attrs_dc3_i),
    .dcu_exclusive_dc3_i                        (dcu_exclusive_dc3_i),
    .dcu_pldw_dc3_i                             (dcu_pldw_dc3_i),
    .biu_leaving_dc3_i                          (biu_leaving_dc3),
    .dcu_lf_active_i                            (dcu_lf_active_i),
    .dcu_stop_pf_i                              (dcu_stop_pf_i),
    .dcu_drain_stb_lf_i                         (dcu_drain_stb_lf_i),
    .biu_lf_in_progress_o                       (biu_lf_in_progress),
    .biu_suppress_tlb_hit_o                     (biu_suppress_tlb_hit_o),
    .biu_lf_ready_dc2_o                         (biu_lf_ready_dc2_o),
    .biu_lf_next_ready_dc3_o                    (biu_lf_next_ready_dc3_o),
    .biu_suppress_load_hit_dc2_o                (biu_suppress_load_hit_dc2_o),
    .tlb_walk_lf_active_i                       (tlb_walk_lf_active_i),
    .tlb_walk_lf_req_i                          (tlb_walk_lf_req_i),
    .tlb_walk_addr_i                            (tlb_walk_addr_i[39:4]),
    .tlb_walk_ns_dsc_i                          (tlb_walk_ns_dsc_i),
    .tlb_walk_attrs_i                           (tlb_walk_attrs_i),
    .tlb_walk_way_i                             (tlb_walk_way_i),
    .biu_walk_lf_hazard_o                       (biu_walk_lf_hazard_o),
    .stb_slots_valid_i                          (stb_slots_valid_i),
    .stb_slot0_addr_i                           (stb_slot0_addr_i[39:4]),
    .stb_slot1_addr_i                           (stb_slot1_addr_i[39:4]),
    .stb_slot2_addr_i                           (stb_slot2_addr_i[39:4]),
    .stb_slot3_addr_i                           (stb_slot3_addr_i[39:4]),
    .stb_slot4_addr_i                           (stb_slot4_addr_i[39:4]),
    .stb_slots_ns_dsc_i                         (stb_slots_ns_dsc_i),
    .stb_slot0_way_i                            (stb_slot0_way_i),
    .stb_slot1_way_i                            (stb_slot1_way_i),
    .stb_slot2_way_i                            (stb_slot2_way_i),
    .stb_slot3_way_i                            (stb_slot3_way_i),
    .stb_slot4_way_i                            (stb_slot4_way_i),
    .stb_slot0_attrs_i                          (stb_slot0_attrs_i),
    .stb_slot1_attrs_i                          (stb_slot1_attrs_i),
    .stb_slot2_attrs_i                          (stb_slot2_attrs_i),
    .stb_slot3_attrs_i                          (stb_slot3_attrs_i),
    .stb_slot4_attrs_i                          (stb_slot4_attrs_i),
    .biu_lf_hazard_o                            (biu_lf_hazard),
    .biu_lf_hazard_migratory_o                  (biu_lf_hazard_migratory_o),
    .biu_lf_real_hazard_o                       (biu_lf_real_hazard_o),
    .biu_lf_hazard_way_slot0_o                  (biu_lf_hazard_way_slot0_o),
    .biu_lf_hazard_way_slot1_o                  (biu_lf_hazard_way_slot1_o),
    .biu_lf_hazard_way_slot2_o                  (biu_lf_hazard_way_slot2_o),
    .biu_lf_hazard_way_slot3_o                  (biu_lf_hazard_way_slot3_o),
    .biu_lf_hazard_way_slot4_o                  (biu_lf_hazard_way_slot4_o),
    .biu_lf_serialized_o                        (biu_lf_serialized_o),
    .biu_ev_hazard_o                            (biu_ev_hazard_o),
    .stb_lf_active_i                            (stb_lf_active_i),
    .stb_lf_req_i                               (stb_lf_req_i),
    .stb_lf_merge_i                             (stb_lf_merge_i),
    .stb_lf_earliest_slot_i                     (stb_lf_earliest_slot_i),
    .biu_lf_can_merge_o                         (biu_lf_can_merge_o),
    .stb_slot_cachewrite_m1_i                   (stb_slot_cachewrite_m1_i),
    .dcu_stb_data_ack_m1_i                      (dcu_stb_data_ack_m1_i),
    .dcu_stb_req_dc3_i                          (dcu_stb_req_dc3_i),
    .biu_dirty_lf_in_progress_o                 (biu_dirty_lf_in_progress),
    .biu_excl_lf_in_progress_o                  (biu_excl_lf_in_progress_o),
    .scu_dr_valid_i                             (scu_dr_valid_i),
    .scu_dr_id_i                                (scu_dr_id_i),
    .scu_dr_resp_i                              (scu_dr_resp_i[4:0]),
    .scu_dr_chunk_i                             (scu_dr_chunk_i),
    .scu_ev_done_i                              (scu_ev_done_i),
    .linefill_imp_abort_o                       (linefill_imp_abort),
    .linefill_imp_fault_o                       (linefill_imp_fault),
    .biu_alloc_data_m0_o                        (biu_alloc_data_m0_o),
    .biu_alloc_tag_req_m0_o                     (biu_alloc_tag_req_m0_o),
    .biu_alloc_data_req_m0_o                    (biu_alloc_data_req_m0_o),
    .biu_alloc_halfline_m0_o                    (biu_alloc_halfline_m0_o),
    .biu_alloc_dirty_req_m0_o                   (biu_alloc_dirty_req_m0_o),
    .biu_alloc_addr_m0_o                        (biu_alloc_addr_m0_o),
    .biu_alloc_ns_dsc_m0_o                      (biu_alloc_ns_dsc_m0_o),
    .biu_alloc_way_m0_o                         (biu_alloc_way_m0_o),
    .biu_alloc_tag_moesi_m0_o                   (biu_alloc_tag_moesi_m0_o),
    .dcu_alloc_has_priority_m0_i                (dcu_alloc_has_priority_m0_i),
    .biu_alloc_dirty_moesi_m1_o                 (biu_alloc_dirty_moesi_m1_o),
    .biu_alloc_dirty_age_m1_o                   (biu_alloc_dirty_age_m1_o),
    .biu_alloc_attrs_m1_o                       (biu_alloc_attrs_m1_o),
    .dcu_alloc_ack_m1_i                         (dcu_alloc_ack_m1_i),
    .biu_pf_tag_req_m0_o                        (biu_pf_tag_req_m0_o),
    .biu_pf_tag_addr_m0_o                       (biu_pf_tag_addr_m0_o),
    .biu_pf_tag_ns_dsc_m0_o                     (biu_pf_tag_ns_dsc_m0_o),
    .dcu_pf_tag_has_priority_m0_i               (dcu_pf_tag_has_priority_m0_i),
    .dcu_pf_tag_ack_m1_i                        (dcu_pf_tag_ack_m1_i),
    .dcu_pf_tag_hit_m2_i                        (dcu_pf_tag_hit_m2_i),
    .dcu_ecc_tag_err_m3_i                       (dcu_ecc_tag_err_m3_i),
    .pf_lf_active_o                             (pf_lf_active),
    .biu_lf_req_o                               (biu_lf_req),
    .biu_lf_addr_o                              (biu_lf_addr),
    .biu_lf_ns_dsc_o                            (biu_lf_ns_dsc),
    .biu_lf_attrs_o                             (biu_lf_attrs),
    .biu_lf_way_o                               (biu_lf_way),
    .biu_lf_descr_id_o                          (biu_lf_descr_id),
    .biu_lf_master_o                            (biu_lf_master),
    .biu_lf_ack_i                               (biu_lf_ack),
    .biu_read_alloc_pend_i                      (biu_read_alloc_pend),
    .lf_descr_inc_ramode_o                      (lf_descr_inc_ramode),
    .lf_descr_leave_ramode_o                    (lf_descr_leave_ramode),
    .rbuf_valid_i                               (rbuf_valid),
    .rbuf_data_packed_i                         (rbuf_data_packed),
    .rbuf_chunk_packed_i                        (rbuf_chunk_packed),
    .rbuf_id_packed_i                           (rbuf_id_packed),
    .rbuf_age_i                                 (rbuf_age),
    .rbuf_for_lf_valid_i                        (rbuf_for_lf_valid),
    .rbuf_for_lf_oldest_sel_i                   (rbuf_for_lf_oldest_sel),
    .lf_descr_for_dc2_o                         (lf_descr_for_dc2),
    .lf_descr_for_dc3_o                         (lf_descr_for_dc3),
    .lf_descr_for_tlb_o                         (lf_descr_for_tlb),
    .lf_descr_evict_done_o                      (lf_descr_evict_done),
    .biu_alloc_rbuf_clr_o                       (biu_alloc_rbuf_clr),
    .biu_alloc_lf_descr_m0_o                    (biu_alloc_lf_descr_m0),
    .biu_alloc_chunk_req_m0_o                   (biu_alloc_chunk_req_m0),
    .biu_alloc_lf_descr_m1_o                    (biu_alloc_lf_descr_m1),
    .biu_alloc_chunk_req_m1_o                   (biu_alloc_chunk_req_m1),
    .ar_block_i                                 (ar_block),
    .ar_credits_used_i                          (ar_credits_used),
    .stb_ar_req_i                               (stb_ar_req_i),
    .stb_is_dvm_i                               (stb_is_dvm),
    .gov_wfx_drain_req_i                        (gov_wfx_drain_req_i),
    .pf_stream_idle_o                           (pf_stream_idle),
    .biu_evnt_rw_lf_o                           (biu_evnt_rw_lf_o),
    .biu_evnt_pf_lf_o                           (biu_evnt_pf_lf_o)
  ); // u_ca53biu_linefills_mngmt

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_ar_valid_o             = biu_ar_valid;
  assign biu_ar_addr_o              = biu_ar_addr;
  assign biu_ar_attrs_o             = biu_ar_attrs;
  assign biu_ar_id_o                = biu_ar_id;
  assign biu_ar_type_o              = biu_ar_type;
  assign biu_ar_len_o               = biu_ar_len;
  assign biu_dr_credit_o            = biu_dr_credit;
  assign biu_lf_in_progress_o       = biu_lf_in_progress;
  assign biu_pf_in_progress_o       = ~pf_stream_idle;
  assign biu_lf_hazard_o            = biu_lf_hazard;
  assign biu_dirty_lf_in_progress_o = biu_dirty_lf_in_progress;
  assign biu_read_data_valid_dc2_o  = biu_read_data_valid_dc2;
  assign biu_read_data_valid_dc3_o  = biu_read_data_valid_dc3;
  assign biu_walk_ack_o             = biu_walk_ack;
  assign biu_read_alloc_mode_o      = biu_evnt_ramode;
  assign biu_evnt_ramode_o          = biu_evnt_ramode;

  //------------------------------------------------------------------------------
  // GOV Interface
  //------------------------------------------------------------------------------

  assign next_biu_wfx_ready = (~|{// BIU-SCU AR request status
                                  biu_ar_valid,
                                  // BIU-SCU DR credit status
                                  biu_dr_credit,
                                  // BIU non-caheable IDs validity status
                                  dcu_nc_ar_id_used,
                                  // BIU PLD L2 ID validity status
                                  pld_l2_ar_id_used,
                                  // BIU device AR request status
                                  dev_req,
                                  // BIU linefill descriptors validity status
                                  biu_lf_in_progress,
                                  // BIU read buffers validity status
                                  rbuf_valid,
                                  // BIU write buffers validity status
                                  wbuf_valid,
                                  // SCU decode or slave error
                                  write_imp_abort,
                                  // BIU imprecise abort
                                  biu_w_imp_abort}) &
                              // BIU device idle
                              dev_idle         &
                              // BIU data prefetch streams idle
                              (&pf_stream_idle);

  // Register the next_biu_wfx_ready
  // o set to one during reset in order to reflect the value of the cluster
  // after it enters WFI for shut down

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      biu_wfx_ready <= 1'b1;
    end else begin
      biu_wfx_ready <= next_biu_wfx_ready;
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_wfx_ready_o = biu_wfx_ready;

  //-----------------------------------------------------------------------------
  // Imprecise aborts
  //-----------------------------------------------------------------------------

  // An imprecise abort can result from:
  // - a dirty linefill where some of the read data aborted (either SLV/DEC error or ECC error)
  // - a write that returns an error response
  // - a cp15 coherency request that returns an error response

  assign next_biu_w_imp_abort = linefill_imp_abort |
                                write_imp_abort    |
                                cp15_coh_imp_abort;

  // ECCERR annd DECERR fault encoding

  assign next_biu_w_imp_fault = {// ECC fault on a dirty linefill
                                 linefill_imp_fault[1],
                                 // DECERR response overrides a SLVERR response.
                                 linefill_imp_fault[0]                   |
                                 (write_imp_abort    & write_imp_fault)  |
                                 (cp15_coh_imp_abort & cp15_coh_imp_fault)};

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      biu_w_imp_abort <= 1'b0;
      biu_w_imp_fault <= 2'b00;
    end else begin
      biu_w_imp_abort <= next_biu_w_imp_abort;
      biu_w_imp_fault <= next_biu_w_imp_fault;
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_w_imp_abort_o = biu_w_imp_abort;
  assign biu_w_imp_fault_o = biu_w_imp_fault;

  //-----------------------------------------------------------------------------
  // MBIST
  //-----------------------------------------------------------------------------

  // TLB MBIST data paths:
  // o shared the TLB read data for the biu_mbist_in_data_mb3[63:0]
  // o dedicated MBIST data path for the biu_mbist_in_data_mb3[TLB_MBIST_DATA_W-1:64] (biu_mbist_in_data_hi_mb3_o)
  // o dedicated MBIST data path for the TLB mem data out (tlb_mbist_out_data_mb6_i)

  // DCU MBIST data paths:
  // o shared the DCU alloc channel for the DCU mem data in
  // o shared the DCU snoop data write for the DCU DATA mem out
  // o dedicated channel for the DCU mem TAG/DIRTY/ECC mem out (dcu_mbist_out_data_mb6_i/dcu_mbist_data_checkbits_mb6_i)

  // IFU MBIST data paths:
  // o shared the IFU read data for the IFU mem data in
  // o dedicated MBIST data path for the IFU mem data out (ifu_mbist_out_data_mb6_i)

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      biu_mbist_req   <= 1'b0;
      biu_mbist_array <= {`DCU_MBIST_ARRAY_W{1'b0}};
    end else begin
      biu_mbist_req   <= gov_mbist_req_i;
      biu_mbist_array <= dcu_mbist_array_mb3_i[`DCU_MBIST_ARRAY_W-1:0];
    end

`ifdef ARM_ASSERT_ON

  // ----------------------------------------------------------------------------
  // ARMAUTO assertions
  // ----------------------------------------------------------------------------

  /* ARMAUTO_X */

  assert_never_unknown                   #(`OVL_FATAL, 1, `OVL_ASSERT, "biu_wfx_ready must never be unknown")
  u_ovl_x_biu_wfx_ready                   (.clk       (clk),
                                           .reset_n   (reset_n),
                                           .qualifier (1'b1),
                                           .test_expr (biu_wfx_ready));

  assert_never_unknown                   #(`OVL_FATAL, 1, `OVL_ASSERT, "biu_w_imp_abort must never be unknown")
  u_ovl_x_biu_w_imp_abort                 (.clk       (clk),
                                           .reset_n   (reset_n),
                                           .qualifier (1'b1),
                                           .test_expr (biu_w_imp_abort));

  assert_never_unknown                   #(`OVL_FATAL, 2, `OVL_ASSERT, "biu_w_imp_fault must never be unknown")
  u_ovl_x_biu_w_imp_fault                 (.clk       (clk),
                                           .reset_n   (reset_n),
                                           .qualifier (1'b1),
                                           .test_expr (biu_w_imp_fault));

  assert_never_unknown                   #(`OVL_FATAL, 1, `OVL_ASSERT, "biu_mbist_req must never be unknown")
  u_ovl_x_biu_mbist_req                   (.clk       (clk),
                                           .reset_n   (reset_n),
                                           .qualifier (1'b1),
                                           .test_expr (biu_mbist_req));

  assert_never_unknown                   #(`OVL_FATAL, `DCU_MBIST_ARRAY_W, `OVL_ASSERT, "biu_mbist_array must never be unknown while in MBIST mode")
  u_ovl_x_biu_mbist_array                 (.clk       (clk),
                                           .reset_n   (reset_n),
                                           .qualifier (biu_mbist_req),
                                           .test_expr (biu_mbist_array));

`endif


endmodule // ca53biu

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53biu_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
