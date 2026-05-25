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
// Abstract : TLB Top level block. The TLB performs pagewalks to translate
//            virtual addresses into physical addresses, and may cache the
//            result of those translations.
//-----------------------------------------------------------------------------

`include "ca53tlb_defs.v"
`include "ca53_biu_tlb_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53_dpu_tlb_defs.v"
`include "ca53_ifu_tlb_defs.v"
`include "ca53_tlb_rams_defs.v"
`include "cortexa53params.v"

module ca53tlb `CA53_TLB_PARAM_DECL
  (
   //------------------------------------------------------------------------------
   // Global signals
   //------------------------------------------------------------------------------

   input  wire                               clk,
   input  wire                               reset_n,
   input  wire                               dbg_resetn_i,
   input  wire                               DFTSE,
   input  wire                               DFTRAMHOLD,

   //------------------------------------------------------------------------------
   // BIU Interface
   //------------------------------------------------------------------------------

   output wire                         [1:0] tlb_mem_granule_o,
   output wire                        [39:0] tlb_walk_addr_o,
   output wire                         [7:0] tlb_walk_attrs_o,
   output wire                               tlb_walk_ns_dsc_o,
   output wire                               tlb_walk_size_o,
   output wire                         [1:0] tlb_walk_way_o,
   output wire                               tlb_walk_nc_req_o,
   output wire                               tlb_walk_lf_active_o,
   output wire                               tlb_walk_lf_req_o,
   input  wire                               biu_walk_ack_i,
   input  wire                         [2:0] biu_walk_resp_i,
   input  wire                        [63:0] biu_walk_data_i,
   input  wire                               biu_walk_lf_hazard_i,
   input  wire                        [52:0] biu_mbist_in_data_hi_mb3_i,
   output wire                       [116:0] tlb_mbist_out_data_mb6_o,

   //------------------------------------------------------------------------------
   // DCU Interface
   //------------------------------------------------------------------------------

   input  wire                               dcu_va_valid_dc1_i,
   input  wire                               dcu_va_valid_early_dc1_i,
   input  wire                         [2:0] dcu_transl_type_dc1_i,
   input  wire                               dcu_ongoing_burst_dc1_i,
   input  wire                               dcu_store_dc1_i,
   input  wire                               dcu_wpt_check_512_dc1_i,
   input  wire                               dcu_priv_dc1_i,
   output wire                        [15:0] tlb_wpt_hit_dc1_o,
   input  wire                         [5:0] dcu_cp_reg_en_dc2_i,
   input  wire                               dcu_cp_reg_write_active_i,
   input  wire                               dcu_cp_reg_write_dc3_i,    //cp15 write signal
   input  wire                         [5:0] dcu_cp_reg_en_dc3_i,       //cp15 write address

   input  wire                               dcu_cp_valid_tlb_i,        //cp15 maint op valid
   input  wire                        [63:0] dcu_cp_reg_data_i,         //cp15 write data
   input  wire                               dcu_cp_reg_size_i,         //cp15 write data size
   input  wire                        [61:0] dcu_cp_addr_tlb_i,         //cp15 maint op addr/other info to compare
   input  wire                               dcu_cp_ns_i,
   input  wire                         [4:0] dcu_cp_op_tlb_i,
   output wire                        [63:0] tlb_cp_read_data_dc2_o,
   output wire                               tlb_cp_reg_write_ready_o,
   output wire                               tlb_cp_ack_o,
   input  wire                               dcu_cache_walk_ack_m1_i,
   input  wire                        [63:0] dcu_cache_walk_data_m2_i,
   input  wire                               dcu_ecc_err_m3_i,
   input  wire                               dcu_cache_walk_hit_m2_i,
   input  wire                         [3:0] dcu_cache_walk_victim_way_m2_i,
   input  wire                               dcu_cache_walk_has_priority_m0_i,
   output wire                         [1:0] tlb_cache_walk_lookup_req_m0_o,
   output wire                        [39:3] tlb_cache_walk_addr_o,
   output wire                               tlb_cache_walk_ns_dsc_o,
   input  wire                               dcu_block_lookups_i,
   output wire                               tlb_lpae_mode_o,
   output wire                               tlb_lpae_mode_s_o,
   output wire                         [7:0] tlb_vmid_o,
   output wire                               tlb_pagewalk_invalidated_o,

   //------------------------------------------------------------------------------
   // DPU Interface
   //------------------------------------------------------------------------------

   input  wire                               dpu_apb_active_i,
   input  wire                        [63:0] dpu_va_dc1_i,
   input  wire                               dpu_utlb_hit_dc1_i,
   input  wire                               dpu_hivecs_i,
   input  wire                               dpu_ipa_to_pa_en_i,
   input  wire                               dpu_default_cacheable_i,
   input  wire                               dpu_tlb_abandon_i,
   input  wire                         [3:0] dpu_dbg_vid_i,
   input  wire                               dpu_mmu_on_el3_i,
   input  wire                               dpu_mmu_on_el1_i,
   input  wire                               dpu_mmu_on_el2_i,
   input  wire                               dpu_dcache_on_el3_i,
   input  wire                               dpu_dcache_on_el1_i,
   input  wire                               dpu_dcache_on_el2_i,
   input  wire                               dpu_endian_el3_i,
   input  wire                               dpu_endian_el1_i,
   input  wire                               dpu_endian_el2_i,
   input  wire                               dpu_icache_on_i,
   input  wire                               dpu_s2_dcache_on_i,
   input  wire                               dpu_tex_remap_enable_el3_i,
   input  wire                               dpu_tex_remap_enable_el1_i,
   input  wire                               dpu_access_flag_enable_el3_i,
   input  wire                               dpu_access_flag_enable_el1_i,
   input  wire                               dpu_sctlr_wxn_el3_i,
   input  wire                               dpu_sctlr_wxn_el1_i,
   input  wire                               dpu_sctlr_wxn_el2_i,
   input  wire                               dpu_sctlr_uwxn_el3_i,
   input  wire                               dpu_sctlr_uwxn_el1_i,
   input  wire                               dpu_pr_tablewalk_i,
   input  wire                               dpu_scr_el3_ns_i,
   input  wire                               dpu_ns_state_i,
   input  wire                        [31:5] dpu_vec_base_s_dc1_i,
   input  wire                        [31:5] dpu_vec_base_ns_dc1_i,
   input  wire                        [31:5] dpu_mon_vec_base_dc1_i,
   input  wire                         [4:0] dpu_mode_iss_i,
   input  wire                         [1:0] dpu_exception_level_i,
   input  wire                         [3:1] dpu_aarch64_at_el_i,
   input  wire                               dpu_dbg_tlb_sw_bkpt_wpt_en_i,
   input  wire                               dpu_dbg_tlb_hw_bkpt_wpt_en_i,
   input  wire                               dpu_dbg_sample_contextid_i,
   input  wire                               dpu_dbg_wr_i,
   input  wire                        [11:2] dpu_dbg_addr_i,
   input  wire                        [31:0] dpu_dbg_wdata_i,
   output wire                        [31:0] tlb_dbg_rdata_o,
   output wire                               tlb_wfx_ready_o,
   output wire                               tlb_d_utlb_enable_o,
   output wire                               tlb_d_utlb_might_enable_o,
   output wire                               tlb_d_utlb_valid_o,
   output wire                               tlb_d_utlb_lpae_o,
   output wire                        [95:0] tlb_d_utlb_data_o,
   output wire                               tlb_d_utlb_flush_o,
   output wire                         [1:0] tlb_d_tcr_el1_tbi_o,
   output wire                               tlb_d_tcr_el2_tbi0_o,
   output wire                               tlb_d_tcr_el3_tbi0_o,
   output wire                               tlb_evnt_data_pagewalk_o,
   output wire                               tlb_evnt_instr_pagewalk_o,
   output wire                               tlb_pty_valid_o,
   output wire                         [1:0] tlb_pty_way_bank_id_o,
   output wire                         [7:0] tlb_pty_index_o,

   //------------------------------------------------------------------------------
   // IFU Interface
   //------------------------------------------------------------------------------

   input  wire                               ifu_utlb_miss_req_i,
   input  wire                        [63:0] ifu_va_if2_i,
   input  wire                               ifu_cp_dbg_valid_i,
   input  wire                        [31:0] ifu_cp_dbg_1_i,
   input  wire                        [31:0] ifu_cp_dbg_0_i,
   output wire                               tlb_i_utlb_enable_o,
   output wire                               tlb_i_utlb_might_enable_o,
   output wire                               tlb_i_utlb_valid_o,
   output wire                               tlb_i_utlb_lpae_o,
   output wire                        [96:0] tlb_i_utlb_data_o,
   output wire                               tlb_i_utlb_flush_o,
   output wire                         [3:0] tlb_bkpt_hit_if2_o,
   output wire                         [1:0] tlb_vcr_hit_if2_o,

   //------------------------------------------------------------------------------
   // Governor Interface
   //------------------------------------------------------------------------------

   input  wire                               gov_mbist_req_i,

   //------------------------------------------------------------------------------
   // RAMs Interface
   //------------------------------------------------------------------------------

   output wire                        [3:0] tlb_ram_en_o,
   output wire                              tlb_ram_wr_o,
   output wire [(`CA53_TLB_RAM_ADDR_W-1):0] tlb_ram_addr_o,
   output wire        [`CA53_TLB_RAM_W-1:0] tlb_ram_wdata_o,
   input  wire        [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata0_i,
   input  wire        [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata1_i,
   input  wire        [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata2_i,
   input  wire        [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata3_i,

   //------------------------------------------------------------------------------
   // TLB External interface
   //------------------------------------------------------------------------------

   output wire                        [31:0] tlb_context_id_o

   );

  //------------------------------------------------------------------------------
  // Flop declarations
  //------------------------------------------------------------------------------

  reg                            clk_enable;
  reg                            mbist_en;

  //------------------------------------------------------------------------------
  // Wire declarations
  //------------------------------------------------------------------------------

  wire                            clk_cpregs;
  wire                            next_clk_enable;
  wire                     [31:0] context_id;
  wire                     [31:0] context_id_etm;
  wire                            tlb_cp_reg_write_ready;
  wire                      [7:0] tlb_vmid;
  wire                            dpu_current_a64;

  wire                            dpu_dbg_vid_ns;
  wire                            walk_ipa_cache_ecc_err;
  wire                      [3:0] walk_ipa_cache_ecc_err_way;
  // MBIST signals
  wire                    [116:0] mbist_in_data_mb3;
  wire                      [3:0] mbist_read_en_mb4;
  wire                      [3:0] mbist_write_en_mb4;
  wire                            dcu_mbist_sel;
  wire                            dcu_mbist_cfg_mb3;
  wire                            dcu_mbist_read_en_mb3;
  wire                            dcu_mbist_write_en_mb3;
  wire                      [6:0] dcu_mbist_array_mb3;
  wire                      [7:0] dcu_mbist_addr_mb3;

  /*ARMAUTO*/
  // The following wires were automatically generated
  // to interconnect instantiations where appropriate.
  wire         [`CA53_ASID_W-1:0] asid_a32_pagewalk;
  wire         [`CA53_ASID_W-1:0] asid_a64_pagewalk;
  wire         [`CA53_ASID_W-1:0] asid_lookup;
  wire         [`CA53_ASID_W-1:0] asid_pagewalk;
  wire                            cp_inv_finished;
  wire                      [3:0] cp_lookup_hit_way;
  wire                            cp_op_waiting;
  wire                     [63:0] dbg_cp_read_data_dc2;
  wire                      [1:0] dbgdr_ram_way;
  wire      [`CA53_TLB_RAM_W-1:0] dbgdr_reg_wr_data;
  wire                            dbgdr_reg_wr_en;
  wire                      [1:0] first_available_way;
  wire                      [5:0] htcr_attrs;
  wire                      [2:0] htcr_t0sz;
  wire                     [47:4] httbr_addr;
  wire                     [37:0] ipa_cache_data;
  wire                      [3:0] ipa_cache_hit_way;
  wire                            ipa_hitmap_flush;
  wire                            lookup_aarch64;
  wire                      [3:1] lookup_aarch64_at_el;
  wire                            lookup_aarch64_at_el3_early;
  wire                            lookup_aarch64_early;
  wire                            lookup_active;
  wire         [`CA53_ASID_W-1:0] lookup_compare_asid;
  wire                            lookup_compare_el3;
  wire                            lookup_compare_hyp;
  wire                            lookup_compare_ns;
  wire                      [2:0] lookup_compare_size;
  wire                            lookup_compare_size_ipa;
  wire                            lookup_compare_use_asid;
  wire                            lookup_compare_use_global;
  wire                            lookup_compare_use_va;
  wire                            lookup_compare_use_vmid;
  wire                    [48:12] lookup_compare_va;
  wire                      [7:0] lookup_compare_vmid;
  wire                            lookup_d_utlb_might_enable;
  wire                            lookup_d_utlb_next_might_enable;
  wire                            lookup_ecc_err;
  wire                      [6:0] lookup_ecc_err_addr;
  wire                            lookup_ecc_err_early;
  wire                      [3:0] lookup_ecc_err_way;
  wire                      [3:0] lookup_ecc_err_way_early;
  wire                            lookup_el2;
  wire                            lookup_el3_el2;
  wire                            lookup_el3_el2_g64;
  wire                      [1:0] lookup_exception_level;
  wire                      [3:2] lookup_exception_level_early;
  wire                            lookup_hit;
  wire                            lookup_i_utlb_might_enable;
  wire                            lookup_i_utlb_next_might_enable;
  wire                            lookup_iside;
  wire                            lookup_mmuon;
  wire                            lookup_ns;
  wire                            lookup_ns_early;
  wire                      [2:0] lookup_ram_d_size;
  wire                      [2:0] lookup_ram_i_size;
  wire                      [7:0] lookup_ram_next_addr;
  wire                            lookup_ram_next_req;
  wire                            lookup_ram_pri;
  wire                            lookup_ram_ready;
  wire                            lookup_ram_req;
  wire                      [3:0] lookup_ram_way;
  wire                            lookup_ram_wr;
  wire                            lookup_s1s2_a64_g64;
  wire                            lookup_stage2_a64_g64;
  wire                            lookup_state_lookup;
  wire                      [5:0] lookup_tcr_a64_muxed_t0sz;
  wire                            lookup_ttbr0_sign_match;
  wire                            lookup_v2p_ipa;
  wire                    [48:12] lookup_va;
  wire                    [47:20] lookup_va_early;
  wire                            lookup_va_mmuoff_sign_err;
  wire                            lookup_va_sign_err;
  wire                      [1:0] lookup_victim_way_size0;
  wire                      [1:0] lookup_victim_way_size1;
  wire                      [1:0] lookup_victim_way_size2;
  wire                      [1:0] lookup_victim_way_size3;
  wire                     [31:0] mair0;
  wire                     [31:0] mair1;
  wire      [`CA53_TLB_RAM_W-1:0] mbist_in_data_mb4;
  wire                            pagewalk_a64;
  wire                            pagewalk_aarch64_at_el3;
  wire                            pagewalk_busy_dside;
  wire                            pagewalk_busy_iside;
  wire                     [95:0] pagewalk_d_utlb_data;
  wire                            pagewalk_d_utlb_enable;
  wire                            pagewalk_d_utlb_next_might_enable;
  wire                            pagewalk_enable_walk_compare;
  wire                      [1:0] pagewalk_exception_level;
  wire                      [2:0] pagewalk_hitmap_size;
  wire                            pagewalk_hitmap_update_dside;
  wire                            pagewalk_hitmap_update_iside;
  wire                            pagewalk_hyp;
  wire                     [96:0] pagewalk_i_utlb_data;
  wire                            pagewalk_i_utlb_enable;
  wire                            pagewalk_i_utlb_next_might_enable;
  wire                            pagewalk_invalidated;
  wire                    [39:16] pagewalk_ipa_compare_ipa;
  wire                      [2:0] pagewalk_ipa_compare_size;
  wire                            pagewalk_lpae;
  wire                            pagewalk_ns;
  wire                      [7:0] pagewalk_ram_addr;
  wire                            pagewalk_ram_pri;
  wire                            pagewalk_ram_req;
  wire                      [3:0] pagewalk_ram_way;
  wire                            pagewalk_ram_wr;
  wire      [`CA53_TLB_RAM_W-1:0] pagewalk_ram_wr_data;
  wire                            pagewalk_size_reduced;
  wire                            pagewalk_state_idle;
  wire                            pagewalk_state_ipa_compare;
  wire                            pagewalk_va_sign;
  wire                      [7:0] pagewalk_vmid;
  wire                            sel_victim_round_robin;
  wire                            stage2_pagewalk_a64_g64;
  wire                            start_pagewalk;
  wire                      [5:0] tcr_a64_el1_attrs0;
  wire                      [5:0] tcr_a64_el1_attrs1;
  wire                      [1:0] tcr_a64_el1_epd;
  wire                      [2:0] tcr_a64_el1_ips;
  wire                      [5:0] tcr_a64_el1_t0sz;
  wire                      [5:0] tcr_a64_el1_t1sz;
  wire                            tcr_a64_el1_tg0;
  wire                            tcr_a64_el1_tg1;
  wire                      [2:0] tcr_a64_el2_ps;
  wire                      [5:0] tcr_a64_el2_t0sz;
  wire                            tcr_a64_el2_tg0;
  wire                      [5:0] tcr_a64_el3_attrs;
  wire                      [2:0] tcr_a64_el3_ps;
  wire                      [5:0] tcr_a64_el3_t0sz;
  wire                            tcr_a64_el3_tg0;
  wire                            tcr_tbi0;
  wire                            tcr_tbi1;
  wire                            tlb_pty_valid_cp;
  wire                            tlb_pty_valid_non_cp;
  wire                      [2:0] tlb_pty_way_cp;
  wire                      [2:0] tlb_pty_way_non_cp;
  wire                      [5:0] ttbcr_attrs0;
  wire                      [5:0] ttbcr_attrs1;
  wire                            ttbcr_eae_ns;
  wire                            ttbcr_eae_s;
  wire                      [1:0] ttbcr_epd;
  wire                      [2:0] ttbcr_t0sz;
  wire                      [2:0] ttbcr_t1sz;
  wire                     [47:4] ttbr0_a64_el1_addr;
  wire                     [47:4] ttbr0_a64_el2_addr;
  wire                     [47:4] ttbr0_a64_el3_addr;
  wire                     [47:4] ttbr0_addr;
  wire                     [47:4] ttbr1_a64_el1_addr;
  wire                     [47:4] ttbr1_addr;
  wire                      [5:0] vtcr_attrs;
  wire                      [2:0] vtcr_ps;
  wire                      [1:0] vtcr_sl0;
  wire                      [5:0] vtcr_t0sz;
  wire                            vtcr_tg0;
  wire                     [47:4] vttbr_addr;
  wire                     [46:0] walk_cache_data;
  wire                            walk_cache_hit;
  wire                      [3:0] walk_ipa_ecc_err_addr;
  wire                      [1:0] walk_ram_arch;
  wire                     [23:0] walk_ram_masked_va;
  /*END*/

  // ------------------------------------------------------
  // Intermediate clock gate for CP registers
  // ------------------------------------------------------

  // Avoid clocking the CP15 and debug registers unless there is a register
  // write that might happen.
  assign next_clk_enable = dcu_cp_reg_write_active_i | dpu_apb_active_i | gov_mbist_req_i;

  // The enable is reset to 1 because the gated clock is used in the debug
  // reset domain as well as the core reset domain, and so must not be gated
  // out if the core logic is being reset while the debug logic is not.
  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    clk_enable <= 1'b1;
  end else begin
    clk_enable <= next_clk_enable;
  end

  ca53_cell_inter_clkgate u_inter_clkgate_cpregs (.clk_i         (clk),
                                                  .clk_enable_i  (clk_enable),
                                                  .clk_senable_i (DFTSE),
                                                  .clk_gated_o   (clk_cpregs));

  // ------------------------------------------------------
  // MBIST
  // ------------------------------------------------------
  assign dcu_mbist_sel          = dcu_cp_addr_tlb_i[34];
  assign dcu_mbist_cfg_mb3      = dcu_cp_addr_tlb_i[33];
  assign dcu_mbist_read_en_mb3  = dcu_cp_addr_tlb_i[32];
  assign dcu_mbist_write_en_mb3 = dcu_cp_addr_tlb_i[31];
  assign dcu_mbist_array_mb3    = dcu_cp_addr_tlb_i[24:18];
  assign dcu_mbist_addr_mb3     = dcu_cp_addr_tlb_i[13:6];

  always @(posedge clk_cpregs or negedge reset_n)
  if (~reset_n) begin
    mbist_en <= 1'b0;
  end else begin
    mbist_en <= gov_mbist_req_i;
  end

  assign mbist_in_data_mb3 = {biu_mbist_in_data_hi_mb3_i[52:0], biu_walk_data_i[63:0]};

  // ------------------------------------------------------
  // Common Logic and local assignments
  // ------------------------------------------------------

  // EL0-A32 with EL1-A64 and current exception EL0 should still do A64
  // pagewalk and hence dpu_mode_iss_i[4] can not always be used by TLB
  assign dpu_current_a64 = (dpu_exception_level_i == 2'b11) ? dpu_aarch64_at_el_i[3] :
                           (dpu_exception_level_i == 2'b10) ? dpu_aarch64_at_el_i[2] :
                                                              dpu_aarch64_at_el_i[1];

  assign dpu_dbg_vid_ns             = dpu_dbg_vid_i[3];
  assign walk_ipa_cache_ecc_err     = lookup_ecc_err;
  assign walk_ipa_cache_ecc_err_way = lookup_ecc_err_way[3:0];

  //------------------------------------------------------------------------------
  // RAM control block. Arbitrates accesses to the RAMs, and compares RAM outputs.
  //------------------------------------------------------------------------------

  ca53tlb_ramctl `CA53_TLB_PARAM_INST u_tlb_ramctl (/*ARMAUTO*/
    // Inputs
    .clk                                 (clk),
    .reset_n                             (reset_n),
    .DFTRAMHOLD                          (DFTRAMHOLD),
    .tlb_ram_rdata0_i                    (tlb_ram_rdata0_i[`CA53_TLB_RAM_W-1:0]),
    .tlb_ram_rdata1_i                    (tlb_ram_rdata1_i[`CA53_TLB_RAM_W-1:0]),
    .tlb_ram_rdata2_i                    (tlb_ram_rdata2_i[`CA53_TLB_RAM_W-1:0]),
    .tlb_ram_rdata3_i                    (tlb_ram_rdata3_i[`CA53_TLB_RAM_W-1:0]),
    .lookup_ram_req_i                    (lookup_ram_req),
    .lookup_ram_way_i                    (lookup_ram_way[3:0]),
    .lookup_ram_next_req_i               (lookup_ram_next_req),
    .lookup_ram_wr_i                     (lookup_ram_wr),
    .lookup_ram_ready_i                  (lookup_ram_ready),
    .lookup_ram_next_addr_i              (lookup_ram_next_addr[7:0]),
    .lookup_ram_d_size_i                 (lookup_ram_d_size[2:0]),
    .lookup_ram_i_size_i                 (lookup_ram_i_size[2:0]),
    .lookup_state_lookup_i               (lookup_state_lookup),
    .dcu_va_valid_early_dc1_i            (dcu_va_valid_early_dc1_i),
    .dpu_utlb_hit_dc1_i                  (dpu_utlb_hit_dc1_i),
    .dpu_va_dc1_i                        (dpu_va_dc1_i[35:12]),
    .dcu_transl_type_dc1_i               (dcu_transl_type_dc1_i[2:0]),
    .ifu_utlb_miss_req_i                 (ifu_utlb_miss_req_i),
    .ifu_va_if2_i                        (ifu_va_if2_i[35:12]),
    .lookup_compare_va_i                 (lookup_compare_va[48:12]),
    .lookup_va_sign_err_i                (lookup_va_sign_err),
    .lookup_compare_size_i               (lookup_compare_size[2:0]),
    .lookup_compare_size_ipa_i           (lookup_compare_size_ipa),
    .lookup_compare_ns_i                 (lookup_compare_ns),
    .lookup_compare_hyp_i                (lookup_compare_hyp),
    .lookup_compare_el3_i                (lookup_compare_el3),
    .lookup_compare_asid_i               (lookup_compare_asid[`CA53_ASID_W-1:0]),
    .lookup_compare_vmid_i               (lookup_compare_vmid[7:0]),
    .lookup_s1s2_a64_g64_i               (lookup_s1s2_a64_g64),
    .lookup_compare_use_va_i             (lookup_compare_use_va),
    .lookup_compare_use_asid_i           (lookup_compare_use_asid),
    .lookup_compare_use_global_i         (lookup_compare_use_global),
    .lookup_compare_use_vmid_i           (lookup_compare_use_vmid),
    .lookup_i_utlb_might_enable_i        (lookup_i_utlb_might_enable),
    .lookup_d_utlb_might_enable_i        (lookup_d_utlb_might_enable),
    .lookup_i_utlb_next_might_enable_i   (lookup_i_utlb_next_might_enable),
    .lookup_d_utlb_next_might_enable_i   (lookup_d_utlb_next_might_enable),
    .pagewalk_i_utlb_enable_i            (pagewalk_i_utlb_enable),
    .pagewalk_d_utlb_enable_i            (pagewalk_d_utlb_enable),
    .pagewalk_i_utlb_next_might_enable_i (pagewalk_i_utlb_next_might_enable),
    .pagewalk_d_utlb_next_might_enable_i (pagewalk_d_utlb_next_might_enable),
    .pagewalk_d_utlb_data_i              (pagewalk_d_utlb_data[`CA53_DUTLB_DATA_W-1:0]),
    .pagewalk_i_utlb_data_i              (pagewalk_i_utlb_data[`CA53_IUTLB_DATA_W-1:0]),
    .pagewalk_va_sign_i                  (pagewalk_va_sign),
    .walk_ram_masked_va_i                (walk_ram_masked_va[23:0]),
    .pagewalk_hyp_i                      (pagewalk_hyp),
    .pagewalk_a64_i                      (pagewalk_a64),
    .pagewalk_exception_level_i          (pagewalk_exception_level[1:0]),
    .pagewalk_ns_i                       (pagewalk_ns),
    .pagewalk_lpae_i                     (pagewalk_lpae),
    .pagewalk_enable_walk_compare_i      (pagewalk_enable_walk_compare),
    .asid_pagewalk_i                     (asid_pagewalk[`CA53_ASID_W-1:0]),
    .pagewalk_vmid_i                     (pagewalk_vmid[7:0]),
    .walk_ram_arch_i                     (walk_ram_arch[1:0]),
    .pagewalk_ipa_compare_ipa_i          (pagewalk_ipa_compare_ipa[39:16]),
    .pagewalk_ipa_compare_size_i         (pagewalk_ipa_compare_size[2:0]),
    .stage2_pagewalk_a64_g64_i           (stage2_pagewalk_a64_g64),
    .pagewalk_state_ipa_compare_i        (pagewalk_state_ipa_compare),
    .pagewalk_ram_req_i                  (pagewalk_ram_req),
    .pagewalk_ram_way_i                  (pagewalk_ram_way[3:0]),
    .pagewalk_ram_wr_i                   (pagewalk_ram_wr),
    .pagewalk_ram_addr_i                 (pagewalk_ram_addr[7:0]),
    .pagewalk_ram_wr_data_i              (pagewalk_ram_wr_data[`CA53_TLB_RAM_W-1:0]),
    .pagewalk_busy_iside_i               (pagewalk_busy_iside),
    .pagewalk_busy_dside_i               (pagewalk_busy_dside),
    .mbist_en_i                          (mbist_en),
    .dcu_mbist_array_mb3_i               (dcu_mbist_array_mb3[1:0]),
    .dcu_mbist_addr_mb3_i                (dcu_mbist_addr_mb3[7:0]),
    .mbist_in_data_mb4_i                 (mbist_in_data_mb4[`CA53_TLB_RAM_W-1:0]),
    .mbist_read_en_mb4_i                 (mbist_read_en_mb4[3:0]),
    .mbist_write_en_mb4_i                (mbist_write_en_mb4[3:0]),
    .dbgdr_ram_way_i                     (dbgdr_ram_way[1:0]),
    .tlb_pty_valid_cp_i                  (tlb_pty_valid_cp),
    .tlb_pty_valid_non_cp_i              (tlb_pty_valid_non_cp),
    .tlb_pty_way_cp_i                    (tlb_pty_way_cp[2:0]),
    .tlb_pty_way_non_cp_i                (tlb_pty_way_non_cp[2:0]),
    // Outputs
    .tlb_ram_en_o                        (tlb_ram_en_o[3:0]),
    .tlb_ram_wr_o                        (tlb_ram_wr_o),
    .tlb_ram_addr_o                      (tlb_ram_addr_o[7:0]),
    .tlb_ram_wdata_o                     (tlb_ram_wdata_o[`CA53_TLB_RAM_W-1:0]),
    .tlb_d_utlb_data_o                   (tlb_d_utlb_data_o[`CA53_DUTLB_DATA_W-1:0]),
    .tlb_i_utlb_data_o                   (tlb_i_utlb_data_o[`CA53_IUTLB_DATA_W-1:0]),
    .tlb_i_utlb_might_enable_o           (tlb_i_utlb_might_enable_o),
    .tlb_d_utlb_might_enable_o           (tlb_d_utlb_might_enable_o),
    .tlb_i_utlb_enable_o                 (tlb_i_utlb_enable_o),
    .tlb_d_utlb_enable_o                 (tlb_d_utlb_enable_o),
    .tlb_i_utlb_valid_o                  (tlb_i_utlb_valid_o),
    .tlb_d_utlb_valid_o                  (tlb_d_utlb_valid_o),
    .tlb_i_utlb_lpae_o                   (tlb_i_utlb_lpae_o),
    .tlb_d_utlb_lpae_o                   (tlb_d_utlb_lpae_o),
    .cp_lookup_hit_way_o                 (cp_lookup_hit_way[3:0]),
    .lookup_hit_o                        (lookup_hit),
    .sel_victim_round_robin_o            (sel_victim_round_robin),
    .first_available_way_o               (first_available_way[1:0]),
    .walk_cache_hit_o                    (walk_cache_hit),
    .walk_cache_data_o                   (walk_cache_data[46:0]),
    .ipa_cache_hit_way_o                 (ipa_cache_hit_way[3:0]),
    .ipa_cache_data_o                    (ipa_cache_data[37:0]),
    .pagewalk_ram_pri_o                  (pagewalk_ram_pri),
    .lookup_ram_pri_o                    (lookup_ram_pri),
    .dbgdr_reg_wr_data_o                 (dbgdr_reg_wr_data[`CA53_TLB_RAM_W-1:0]),
    .lookup_ecc_err_o                    (lookup_ecc_err),
    .lookup_ecc_err_way_o                (lookup_ecc_err_way[3:0]),
    .lookup_ecc_err_addr_o               (lookup_ecc_err_addr[6:0]),
    .walk_ipa_ecc_err_addr_o             (walk_ipa_ecc_err_addr[3:0]),
    .tlb_pty_valid_o                     (tlb_pty_valid_o),
    .tlb_pty_way_bank_id_o               (tlb_pty_way_bank_id_o[1:0]),
    .tlb_pty_index_o                     (tlb_pty_index_o[7:0])
  );  // u_tlb_ramctl


  //------------------------------------------------------------------------------
  // TLB Lookup block. Controls main TLB lookups and CP15 maintenance operations.
  //------------------------------------------------------------------------------


  ca53tlb_lookup `CA53_TLB_PARAM_INST u_tlb_lookup (/*ARMAUTO*/
    // Inputs
    .clk                               (clk),
    .reset_n                           (reset_n),
    .dpu_ns_state_i                    (dpu_ns_state_i),
    .dpu_scr_el3_ns_i                  (dpu_scr_el3_ns_i),
    .dpu_mmu_on_el3_i                  (dpu_mmu_on_el3_i),
    .dpu_mmu_on_el1_i                  (dpu_mmu_on_el1_i),
    .dpu_mmu_on_el2_i                  (dpu_mmu_on_el2_i),
    .dcu_va_valid_dc1_i                (dcu_va_valid_dc1_i),
    .dcu_va_valid_early_dc1_i          (dcu_va_valid_early_dc1_i),
    .dcu_transl_type_dc1_i             (dcu_transl_type_dc1_i[2:0]),
    .dpu_utlb_hit_dc1_i                (dpu_utlb_hit_dc1_i),
    .dpu_va_dc1_i                      (dpu_va_dc1_i[63:12]),
    .dcu_block_lookups_i               (dcu_block_lookups_i),
    .ifu_utlb_miss_req_i               (ifu_utlb_miss_req_i),
    .ifu_va_if2_i                      (ifu_va_if2_i[63:12]),
    .lookup_ram_pri_i                  (lookup_ram_pri),
    .pagewalk_state_idle_i             (pagewalk_state_idle),
    .pagewalk_busy_iside_i             (pagewalk_busy_iside),
    .pagewalk_busy_dside_i             (pagewalk_busy_dside),
    .pagewalk_invalidated_i            (pagewalk_invalidated),
    .asid_lookup_i                     (asid_lookup[`CA53_ASID_W-1:0]),
    .tcr_tbi0_i                        (tcr_tbi0),
    .tcr_tbi1_i                        (tcr_tbi1),
    .dcu_cp_ns_i                       (dcu_cp_ns_i),
    .dcu_cp_addr_tlb_i                 (dcu_cp_addr_tlb_i[`CA53_DCU_CP_ADDR_W-1:0]),
    .tlb_vmid_i                        (tlb_vmid[7:0]),
    .dpu_default_cacheable_i           (dpu_default_cacheable_i),
    .dpu_exception_level_i             (dpu_exception_level_i[1:0]),
    .dpu_aarch64_at_el_i               (dpu_aarch64_at_el_i[3:1]),
    .dpu_tlb_abandon_i                 (dpu_tlb_abandon_i),
    .sel_victim_round_robin_i          (sel_victim_round_robin),
    .first_available_way_i             (first_available_way[1:0]),
    .lookup_hit_i                      (lookup_hit),
    .cp_lookup_hit_way_i               (cp_lookup_hit_way[3:0]),
    .pagewalk_hitmap_update_iside_i    (pagewalk_hitmap_update_iside),
    .pagewalk_hitmap_update_dside_i    (pagewalk_hitmap_update_dside),
    .pagewalk_hitmap_size_i            (pagewalk_hitmap_size[2:0]),
    .pagewalk_size_reduced_i           (pagewalk_size_reduced),
    .ttbcr_eae_s_i                     (ttbcr_eae_s),
    .ttbcr_eae_ns_i                    (ttbcr_eae_ns),
    .dcu_cp_valid_tlb_i                (dcu_cp_valid_tlb_i),
    .dcu_cp_op_tlb_i                   (dcu_cp_op_tlb_i[`CA53_DCU_CP_OP_W-1:0]),
    .lookup_ecc_err_i                  (lookup_ecc_err),
    .lookup_ecc_err_way_i              (lookup_ecc_err_way[3:0]),
    .mbist_en_i                        (mbist_en),
    .tcr_a64_el1_t0sz_i                (tcr_a64_el1_t0sz[5:0]),
    .tcr_a64_el2_t0sz_i                (tcr_a64_el2_t0sz[5:0]),
    .tcr_a64_el3_t0sz_i                (tcr_a64_el3_t0sz[5:0]),
    .tcr_a64_el2_tg0_i                 (tcr_a64_el2_tg0),
    .tcr_a64_el3_tg0_i                 (tcr_a64_el3_tg0),
    .vtcr_tg0_i                        (vtcr_tg0),
    .dpu_ipa_to_pa_en_i                (dpu_ipa_to_pa_en_i),
    // Outputs
    .start_pagewalk_o                  (start_pagewalk),
    .lookup_active_o                   (lookup_active),
    .lookup_iside_o                    (lookup_iside),
    .lookup_victim_way_size0_o         (lookup_victim_way_size0[1:0]),
    .lookup_victim_way_size1_o         (lookup_victim_way_size1[1:0]),
    .lookup_victim_way_size2_o         (lookup_victim_way_size2[1:0]),
    .lookup_victim_way_size3_o         (lookup_victim_way_size3[1:0]),
    .lookup_va_o                       (lookup_va[48:12]),
    .lookup_va_sign_err_o              (lookup_va_sign_err),
    .lookup_va_mmuoff_sign_err_o       (lookup_va_mmuoff_sign_err),
    .lookup_ns_o                       (lookup_ns),
    .lookup_mmuon_o                    (lookup_mmuon),
    .lookup_el2_o                      (lookup_el2),
    .lookup_v2p_ipa_o                  (lookup_v2p_ipa),
    .tlb_cp_reg_write_ready_o          (tlb_cp_reg_write_ready),
    .tlb_wfx_ready_o                   (tlb_wfx_ready_o),
    .cp_op_waiting_o                   (cp_op_waiting),
    .cp_inv_finished_o                 (cp_inv_finished),
    .tlb_cp_ack_o                      (tlb_cp_ack_o),
    .lookup_ram_req_o                  (lookup_ram_req),
    .lookup_ram_way_o                  (lookup_ram_way[3:0]),
    .lookup_ram_next_req_o             (lookup_ram_next_req),
    .lookup_ram_wr_o                   (lookup_ram_wr),
    .lookup_ram_ready_o                (lookup_ram_ready),
    .lookup_ram_next_addr_o            (lookup_ram_next_addr[7:0]),
    .lookup_ram_d_size_o               (lookup_ram_d_size[2:0]),
    .lookup_ram_i_size_o               (lookup_ram_i_size[2:0]),
    .lookup_state_lookup_o             (lookup_state_lookup),
    .lookup_compare_va_o               (lookup_compare_va[48:12]),
    .lookup_compare_size_o             (lookup_compare_size[2:0]),
    .lookup_compare_size_ipa_o         (lookup_compare_size_ipa),
    .lookup_compare_ns_o               (lookup_compare_ns),
    .lookup_compare_hyp_o              (lookup_compare_hyp),
    .lookup_compare_el3_o              (lookup_compare_el3),
    .lookup_compare_asid_o             (lookup_compare_asid[`CA53_ASID_W-1:0]),
    .lookup_compare_vmid_o             (lookup_compare_vmid[7:0]),
    .lookup_compare_use_va_o           (lookup_compare_use_va),
    .lookup_compare_use_asid_o         (lookup_compare_use_asid),
    .lookup_compare_use_global_o       (lookup_compare_use_global),
    .lookup_compare_use_vmid_o         (lookup_compare_use_vmid),
    .lookup_i_utlb_might_enable_o      (lookup_i_utlb_might_enable),
    .lookup_d_utlb_might_enable_o      (lookup_d_utlb_might_enable),
    .lookup_i_utlb_next_might_enable_o (lookup_i_utlb_next_might_enable),
    .lookup_d_utlb_next_might_enable_o (lookup_d_utlb_next_might_enable),
    .ipa_hitmap_flush_o                (ipa_hitmap_flush),
    .dbgdr_reg_wr_en_o                 (dbgdr_reg_wr_en),
    .dbgdr_ram_way_o                   (dbgdr_ram_way[1:0]),
    .lookup_aarch64_at_el_o            (lookup_aarch64_at_el[3:1]),
    .lookup_aarch64_o                  (lookup_aarch64),
    .lookup_exception_level_o          (lookup_exception_level[1:0]),
    .lookup_exception_level_early_o    (lookup_exception_level_early[3:2]),
    .lookup_ecc_err_early_o            (lookup_ecc_err_early),
    .lookup_ecc_err_way_early_o        (lookup_ecc_err_way_early[3:0]),
    .lookup_va_early_o                 (lookup_va_early[47:20]),
    .lookup_ns_early_o                 (lookup_ns_early),
    .lookup_aarch64_at_el3_early_o     (lookup_aarch64_at_el3_early),
    .lookup_aarch64_early_o            (lookup_aarch64_early),
    .lookup_tcr_a64_muxed_t0sz_o       (lookup_tcr_a64_muxed_t0sz[5:0]),
    .lookup_stage2_a64_g64_o           (lookup_stage2_a64_g64),
    .lookup_el3_el2_o                  (lookup_el3_el2),
    .lookup_el3_el2_g64_o              (lookup_el3_el2_g64),
    .lookup_ttbr0_sign_match_o         (lookup_ttbr0_sign_match),
    .tlb_pty_valid_cp_o                (tlb_pty_valid_cp),
    .tlb_pty_way_cp_o                  (tlb_pty_way_cp[2:0])
  );  // u_tlb_lookup


  //-----------------------------------------------------------------------------
  // TLB Pagewalk block
  //-----------------------------------------------------------------------------


  ca53tlb_pagewalk `CA53_TLB_PARAM_INST u_tlb_pagewalk (/*ARMAUTO*/
    // Inputs
    .clk                                 (clk),
    .reset_n                             (reset_n),
    .DFTSE                               (DFTSE),
    .start_pagewalk_i                    (start_pagewalk),
    .lookup_active_i                     (lookup_active),
    .lookup_va_i                         (lookup_va[48:12]),
    .lookup_va_sign_err_i                (lookup_va_sign_err),
    .lookup_va_mmuoff_sign_err_i         (lookup_va_mmuoff_sign_err),
    .lookup_ns_i                         (lookup_ns),
    .lookup_mmuon_i                      (lookup_mmuon),
    .lookup_iside_i                      (lookup_iside),
    .lookup_v2p_ipa_i                    (lookup_v2p_ipa),
    .lookup_aarch64_at_el_i              (lookup_aarch64_at_el[3:1]),
    .lookup_exception_level_i            (lookup_exception_level[1:0]),
    .lookup_exception_level_early_i      (lookup_exception_level_early[3:2]),
    .lookup_va_early_i                   (lookup_va_early[47:20]),
    .lookup_ns_early_i                   (lookup_ns_early),
    .lookup_aarch64_at_el3_early_i       (lookup_aarch64_at_el3_early),
    .lookup_aarch64_early_i              (lookup_aarch64_early),
    .lookup_tcr_a64_muxed_t0sz_i         (lookup_tcr_a64_muxed_t0sz[5:0]),
    .lookup_stage2_a64_g64_i             (lookup_stage2_a64_g64),
    .lookup_el3_el2_i                    (lookup_el3_el2),
    .lookup_el3_el2_g64_i                (lookup_el3_el2_g64),
    .lookup_ttbr0_sign_match_i           (lookup_ttbr0_sign_match),
    .lookup_victim_way_size0_i           (lookup_victim_way_size0[1:0]),
    .lookup_victim_way_size1_i           (lookup_victim_way_size1[1:0]),
    .lookup_victim_way_size2_i           (lookup_victim_way_size2[1:0]),
    .lookup_victim_way_size3_i           (lookup_victim_way_size3[1:0]),
    .pagewalk_ram_pri_i                  (pagewalk_ram_pri),
    .sel_victim_round_robin_i            (sel_victim_round_robin),
    .first_available_way_i               (first_available_way[1:0]),
    .walk_cache_hit_i                    (walk_cache_hit),
    .walk_cache_data_i                   (walk_cache_data[46:0]),
    .ipa_cache_hit_way_i                 (ipa_cache_hit_way[3:0]),
    .ipa_cache_data_i                    (ipa_cache_data[37:0]),
    .ipa_hitmap_flush_i                  (ipa_hitmap_flush),
    .dpu_ipa_to_pa_en_i                  (dpu_ipa_to_pa_en_i),
    .dpu_default_cacheable_i             (dpu_default_cacheable_i),
    .dpu_pr_tablewalk_i                  (dpu_pr_tablewalk_i),
    .dpu_tlb_abandon_i                   (dpu_tlb_abandon_i),
    .dpu_sctlr_wxn_el3_i                 (dpu_sctlr_wxn_el3_i),
    .dpu_sctlr_wxn_el1_i                 (dpu_sctlr_wxn_el1_i),
    .dpu_sctlr_wxn_el2_i                 (dpu_sctlr_wxn_el2_i),
    .dpu_sctlr_uwxn_el3_i                (dpu_sctlr_uwxn_el3_i),
    .dpu_sctlr_uwxn_el1_i                (dpu_sctlr_uwxn_el1_i),
    .dpu_tex_remap_enable_el3_i          (dpu_tex_remap_enable_el3_i),
    .dpu_tex_remap_enable_el1_i          (dpu_tex_remap_enable_el1_i),
    .dpu_access_flag_enable_el3_i        (dpu_access_flag_enable_el3_i),
    .dpu_access_flag_enable_el1_i        (dpu_access_flag_enable_el1_i),
    .dpu_endian_el3_i                    (dpu_endian_el3_i),
    .dpu_endian_el1_i                    (dpu_endian_el1_i),
    .dpu_endian_el2_i                    (dpu_endian_el2_i),
    .dpu_icache_on_i                     (dpu_icache_on_i),
    .dpu_dcache_on_el1_i                 (dpu_dcache_on_el1_i),
    .dpu_dcache_on_el2_i                 (dpu_dcache_on_el2_i),
    .dpu_dcache_on_el3_i                 (dpu_dcache_on_el3_i),
    .dpu_s2_dcache_on_i                  (dpu_s2_dcache_on_i),
    .ifu_utlb_miss_req_i                 (ifu_utlb_miss_req_i),
    .dcu_va_valid_dc1_i                  (dcu_va_valid_dc1_i),
    .cp_op_waiting_i                     (cp_op_waiting),
    .dcu_cache_walk_ack_m1_i             (dcu_cache_walk_ack_m1_i),
    .dcu_cache_walk_hit_m2_i             (dcu_cache_walk_hit_m2_i),
    .dcu_cache_walk_victim_way_m2_i      (dcu_cache_walk_victim_way_m2_i[3:0]),
    .dcu_cache_walk_data_m2_i            (dcu_cache_walk_data_m2_i[63:0]),
    .dcu_ecc_err_m3_i                    (dcu_ecc_err_m3_i),
    .dcu_cache_walk_has_priority_m0_i    (dcu_cache_walk_has_priority_m0_i),
    .biu_walk_lf_hazard_i                (biu_walk_lf_hazard_i),
    .biu_walk_ack_i                      (biu_walk_ack_i),
    .biu_walk_data_i                     (biu_walk_data_i[63:0]),
    .biu_walk_resp_i                     (biu_walk_resp_i[2:0]),
    .ttbr0_addr_i                        (ttbr0_addr[47:4]),
    .ttbr1_addr_i                        (ttbr1_addr[47:4]),
    .httbr_addr_i                        (httbr_addr[47:4]),
    .vttbr_addr_i                        (vttbr_addr[47:4]),
    .ttbcr_t0sz_i                        (ttbcr_t0sz[2:0]),
    .ttbcr_t1sz_i                        (ttbcr_t1sz[2:0]),
    .ttbcr_epd_i                         (ttbcr_epd[1:0]),
    .ttbcr_attrs0_i                      (ttbcr_attrs0[5:0]),
    .ttbcr_attrs1_i                      (ttbcr_attrs1[5:0]),
    .ttbcr_eae_s_i                       (ttbcr_eae_s),
    .ttbcr_eae_ns_i                      (ttbcr_eae_ns),
    .htcr_t0sz_i                         (htcr_t0sz[2:0]),
    .htcr_attrs_i                        (htcr_attrs[5:0]),
    .vtcr_t0sz_i                         (vtcr_t0sz[5:0]),
    .vtcr_sl0_i                          (vtcr_sl0[1:0]),
    .vtcr_attrs_i                        (vtcr_attrs[5:0]),
    .vtcr_tg0_i                          (vtcr_tg0),
    .vtcr_ps_i                           (vtcr_ps[2:0]),
    .mair0_i                             (mair0[31:0]),
    .mair1_i                             (mair1[31:0]),
    .tlb_vmid_i                          (tlb_vmid[7:0]),
    .asid_a32_pagewalk_i                 (asid_a32_pagewalk[`CA53_ASID_W-1:0]),
    .asid_a64_pagewalk_i                 (asid_a64_pagewalk[`CA53_ASID_W-1:0]),
    .ttbr0_a64_el1_addr_i                (ttbr0_a64_el1_addr[47:4]),
    .ttbr1_a64_el1_addr_i                (ttbr1_a64_el1_addr[47:4]),
    .ttbr0_a64_el2_addr_i                (ttbr0_a64_el2_addr[47:4]),
    .ttbr0_a64_el3_addr_i                (ttbr0_a64_el3_addr[47:4]),
    .tcr_a64_el1_t0sz_i                  (tcr_a64_el1_t0sz[5:0]),
    .tcr_a64_el1_t1sz_i                  (tcr_a64_el1_t1sz[5:0]),
    .tcr_a64_el3_t0sz_i                  (tcr_a64_el3_t0sz[5:0]),
    .tcr_a64_el2_t0sz_i                  (tcr_a64_el2_t0sz[5:0]),
    .tcr_a64_el1_ips_i                   (tcr_a64_el1_ips[2:0]),
    .tcr_a64_el2_ps_i                    (tcr_a64_el2_ps[2:0]),
    .tcr_a64_el3_ps_i                    (tcr_a64_el3_ps[2:0]),
    .tcr_a64_el1_epd_i                   (tcr_a64_el1_epd[1:0]),
    .tcr_a64_el1_attrs0_i                (tcr_a64_el1_attrs0[5:0]),
    .tcr_a64_el1_attrs1_i                (tcr_a64_el1_attrs1[5:0]),
    .tcr_a64_el3_attrs_i                 (tcr_a64_el3_attrs[5:0]),
    .tcr_a64_el1_tg0_i                   (tcr_a64_el1_tg0),
    .tcr_a64_el1_tg1_i                   (tcr_a64_el1_tg1),
    .lookup_aarch64_i                    (lookup_aarch64),
    .lookup_ecc_err_early_i              (lookup_ecc_err_early),
    .lookup_ecc_err_way_early_i          (lookup_ecc_err_way_early[3:0]),
    .lookup_ecc_err_addr_i               (lookup_ecc_err_addr[6:0]),
    .walk_ipa_cache_ecc_err_i            (walk_ipa_cache_ecc_err),
    .walk_ipa_cache_ecc_err_way_i        (walk_ipa_cache_ecc_err_way[3:0]),
    .walk_ipa_ecc_err_addr_i             (walk_ipa_ecc_err_addr[3:0]),
    // Outputs
    .pagewalk_ram_req_o                  (pagewalk_ram_req),
    .pagewalk_ram_way_o                  (pagewalk_ram_way[3:0]),
    .pagewalk_ram_wr_o                   (pagewalk_ram_wr),
    .pagewalk_ram_addr_o                 (pagewalk_ram_addr[7:0]),
    .pagewalk_ram_wr_data_o              (pagewalk_ram_wr_data[`CA53_TLB_RAM_W-1:0]),
    .pagewalk_i_utlb_enable_o            (pagewalk_i_utlb_enable),
    .pagewalk_d_utlb_enable_o            (pagewalk_d_utlb_enable),
    .pagewalk_i_utlb_next_might_enable_o (pagewalk_i_utlb_next_might_enable),
    .pagewalk_d_utlb_next_might_enable_o (pagewalk_d_utlb_next_might_enable),
    .pagewalk_d_utlb_data_o              (pagewalk_d_utlb_data[95:0]),
    .pagewalk_i_utlb_data_o              (pagewalk_i_utlb_data[96:0]),
    .pagewalk_invalidated_o              (pagewalk_invalidated),
    .pagewalk_state_idle_o               (pagewalk_state_idle),
    .pagewalk_busy_iside_o               (pagewalk_busy_iside),
    .pagewalk_busy_dside_o               (pagewalk_busy_dside),
    .pagewalk_size_reduced_o             (pagewalk_size_reduced),
    .pagewalk_hitmap_update_iside_o      (pagewalk_hitmap_update_iside),
    .pagewalk_hitmap_update_dside_o      (pagewalk_hitmap_update_dside),
    .pagewalk_hitmap_size_o              (pagewalk_hitmap_size[2:0]),
    .pagewalk_ipa_compare_ipa_o          (pagewalk_ipa_compare_ipa[39:16]),
    .pagewalk_ipa_compare_size_o         (pagewalk_ipa_compare_size[2:0]),
    .stage2_pagewalk_a64_g64_o           (stage2_pagewalk_a64_g64),
    .pagewalk_state_ipa_compare_o        (pagewalk_state_ipa_compare),
    .tlb_cache_walk_lookup_req_m0_o      (tlb_cache_walk_lookup_req_m0_o[1:0]),
    .tlb_cache_walk_addr_o               (tlb_cache_walk_addr_o[39:3]),
    .tlb_cache_walk_ns_dsc_o             (tlb_cache_walk_ns_dsc_o),
    .tlb_walk_nc_req_o                   (tlb_walk_nc_req_o),
    .tlb_walk_lf_req_o                   (tlb_walk_lf_req_o),
    .tlb_walk_lf_active_o                (tlb_walk_lf_active_o),
    .tlb_walk_attrs_o                    (tlb_walk_attrs_o[7:0]),
    .tlb_walk_way_o                      (tlb_walk_way_o[1:0]),
    .tlb_walk_addr_o                     (tlb_walk_addr_o[39:0]),
    .tlb_walk_ns_dsc_o                   (tlb_walk_ns_dsc_o),
    .tlb_walk_size_o                     (tlb_walk_size_o),
    .pagewalk_ns_o                       (pagewalk_ns),
    .pagewalk_lpae_o                     (pagewalk_lpae),
    .pagewalk_hyp_o                      (pagewalk_hyp),
    .pagewalk_a64_o                      (pagewalk_a64),
    .pagewalk_va_sign_o                  (pagewalk_va_sign),
    .walk_ram_masked_va_o                (walk_ram_masked_va[23:0]),
    .pagewalk_vmid_o                     (pagewalk_vmid[7:0]),
    .walk_ram_arch_o                     (walk_ram_arch[1:0]),
    .pagewalk_enable_walk_compare_o      (pagewalk_enable_walk_compare),
    .tlb_evnt_data_pagewalk_o            (tlb_evnt_data_pagewalk_o),
    .tlb_evnt_instr_pagewalk_o           (tlb_evnt_instr_pagewalk_o),
    .asid_pagewalk_o                     (asid_pagewalk[`CA53_ASID_W-1:0]),
    .pagewalk_aarch64_at_el3_o           (pagewalk_aarch64_at_el3),
    .pagewalk_exception_level_o          (pagewalk_exception_level[1:0]),
    .lookup_s1s2_a64_g64_o               (lookup_s1s2_a64_g64),
    .tlb_pty_valid_non_cp_o              (tlb_pty_valid_non_cp),
    .tlb_pty_way_non_cp_o                (tlb_pty_way_non_cp[2:0])
  );  // u_tlb_pagewalk

  //------------------------------------------------------------------------------
  // TLB block for debug operations
  //------------------------------------------------------------------------------

  ca53tlb_dbg u_tlb_dbg (/*ARMAUTO*/
    // Inputs
    .clk                          (clk),
    .clk_cpregs                   (clk_cpregs),
    .dbg_resetn_i                 (dbg_resetn_i),
    .dpu_dbg_tlb_sw_bkpt_wpt_en_i (dpu_dbg_tlb_sw_bkpt_wpt_en_i),
    .dpu_dbg_tlb_hw_bkpt_wpt_en_i (dpu_dbg_tlb_hw_bkpt_wpt_en_i),
    .dpu_dbg_sample_contextid_i   (dpu_dbg_sample_contextid_i),
    .dpu_dbg_addr_i               (dpu_dbg_addr_i[11:2]),
    .dpu_dbg_wdata_i              (dpu_dbg_wdata_i[31:0]),
    .dpu_dbg_wr_i                 (dpu_dbg_wr_i),
    .dcu_priv_dc1_i               (dcu_priv_dc1_i),
    .dcu_store_dc1_i              (dcu_store_dc1_i),
    .dcu_wpt_check_512_dc1_i      (dcu_wpt_check_512_dc1_i),
    .dcu_cp_reg_en_dc2_i          (dcu_cp_reg_en_dc2_i[5:0]),
    .dcu_cp_reg_write_dc3_i       (dcu_cp_reg_write_dc3_i),
    .dcu_cp_reg_en_dc3_i          (dcu_cp_reg_en_dc3_i[5:0]),
    .dcu_cp_reg_data_i            (dcu_cp_reg_data_i[48:0]),
    .dcu_cp_reg_size_i            (dcu_cp_reg_size_i),
    .ifu_va_if2_i                 (ifu_va_if2_i[48:3]),
    .dpu_va_dc1_i                 (dpu_va_dc1_i[48:3]),
    .dpu_hivecs_i                 (dpu_hivecs_i),
    .dpu_mode_iss_i               (dpu_mode_iss_i[4:0]),
    .dpu_exception_level_i        (dpu_exception_level_i[1:0]),
    .dpu_aarch64_at_el_i          (dpu_aarch64_at_el_i[3:1]),
    .dpu_current_a64_i            (dpu_current_a64),
    .dpu_vec_base_s_dc1_i         (dpu_vec_base_s_dc1_i[31:5]),
    .dpu_vec_base_ns_dc1_i        (dpu_vec_base_ns_dc1_i[31:5]),
    .dpu_mon_vec_base_dc1_i       (dpu_mon_vec_base_dc1_i[31:5]),
    .dpu_ns_state_i               (dpu_ns_state_i),
    .dpu_dbg_vid_i                (dpu_dbg_vid_i[3:0]),
    .tlb_cp_reg_write_ready_i     (tlb_cp_reg_write_ready),
    .context_id_i                 (context_id[31:0]),
    .tlb_vmid_i                   (tlb_vmid[7:0]),
    // Outputs
    .tlb_dbg_rdata_o              (tlb_dbg_rdata_o[31:0]),
    .tlb_wpt_hit_dc1_o            (tlb_wpt_hit_dc1_o[15:0]),
    .dbg_cp_read_data_dc2_o       (dbg_cp_read_data_dc2[63:0]),
    .tlb_bkpt_hit_if2_o           (tlb_bkpt_hit_if2_o[3:0]),
    .tlb_vcr_hit_if2_o            (tlb_vcr_hit_if2_o[1:0])
  );  // u_tlb_dbg

  //------------------------------------------------------------------------------
  // TLB block for CP15 registers
  //------------------------------------------------------------------------------


  ca53tlb_cp_regs `CA53_TLB_PARAM_INST u_tlb_cp_regs (/*ARMAUTO*/
    // Inputs
    .clk                        (clk),
    .clk_cpregs                 (clk_cpregs),
    .reset_n                    (reset_n),
    .dcu_cp_reg_en_dc2_i        (dcu_cp_reg_en_dc2_i[5:0]),
    .dbg_cp_read_data_dc2_i     (dbg_cp_read_data_dc2[63:0]),
    .dcu_cp_reg_write_dc3_i     (dcu_cp_reg_write_dc3_i),
    .dcu_cp_reg_en_dc3_i        (dcu_cp_reg_en_dc3_i[5:0]),
    .dcu_cp_reg_data_i          (dcu_cp_reg_data_i[63:0]),
    .dcu_cp_reg_size_i          (dcu_cp_reg_size_i),
    .tlb_cp_reg_write_ready_i   (tlb_cp_reg_write_ready),
    .dpu_scr_el3_ns_i           (dpu_scr_el3_ns_i),
    .dpu_ns_state_i             (dpu_ns_state_i),
    .pagewalk_ns_i              (pagewalk_ns),
    .pagewalk_hyp_i             (pagewalk_hyp),
    .lookup_ns_i                (lookup_ns),
    .lookup_el2_i               (lookup_el2),
    .lookup_exception_level_i   (lookup_exception_level[1:0]),
    .lookup_aarch64_i           (lookup_aarch64),
    .dpu_current_a64_i          (dpu_current_a64),
    .dpu_exception_level_i      (dpu_exception_level_i[1:0]),
    .dpu_aarch64_at_el_i        (dpu_aarch64_at_el_i[3:1]),
    .dcu_ongoing_burst_dc1_i    (dcu_ongoing_burst_dc1_i),
    .cp_inv_finished_i          (cp_inv_finished),
    .pagewalk_i_utlb_enable_i   (pagewalk_i_utlb_enable),
    .pagewalk_d_utlb_enable_i   (pagewalk_d_utlb_enable),
    .pagewalk_invalidated_i     (pagewalk_invalidated),
    .pagewalk_aarch64_at_el3_i  (pagewalk_aarch64_at_el3),
    .pagewalk_exception_level_i (pagewalk_exception_level[1:0]),
    .mbist_en_i                 (mbist_en),
    .dcu_mbist_sel_i            (dcu_mbist_sel),
    .dcu_mbist_cfg_mb3_i        (dcu_mbist_cfg_mb3),
    .dcu_mbist_read_en_mb3_i    (dcu_mbist_read_en_mb3),
    .dcu_mbist_write_en_mb3_i   (dcu_mbist_write_en_mb3),
    .dcu_mbist_array_mb3_i      (dcu_mbist_array_mb3[6:0]),
    .mbist_in_data_mb3_i        (mbist_in_data_mb3[116:0]),
    .ifu_cp_dbg_valid_i         (ifu_cp_dbg_valid_i),
    .ifu_cp_dbg_1_i             (ifu_cp_dbg_1_i[31:0]),
    .ifu_cp_dbg_0_i             (ifu_cp_dbg_0_i[31:0]),
    .dbgdr_reg_wr_en_i          (dbgdr_reg_wr_en),
    .dbgdr_reg_wr_data_i        (dbgdr_reg_wr_data[`CA53_TLB_RAM_W-1:0]),
    .dpu_dbg_vid_ns_i           (dpu_dbg_vid_ns),
    .dpu_mmu_on_el3_i           (dpu_mmu_on_el3_i),
    .dpu_mmu_on_el2_i           (dpu_mmu_on_el2_i),
    .dpu_mmu_on_el1_i           (dpu_mmu_on_el1_i),
    .dpu_ipa_to_pa_en_i         (dpu_ipa_to_pa_en_i),
    .dpu_default_cacheable_i    (dpu_default_cacheable_i),
    // Outputs
    .tlb_cp_read_data_dc2_o     (tlb_cp_read_data_dc2_o[63:0]),
    .tlb_lpae_mode_o            (tlb_lpae_mode_o),
    .tlb_lpae_mode_s_o          (tlb_lpae_mode_s_o),
    .ttbr0_addr_o               (ttbr0_addr[47:4]),
    .ttbr1_addr_o               (ttbr1_addr[47:4]),
    .httbr_addr_o               (httbr_addr[47:4]),
    .vttbr_addr_o               (vttbr_addr[47:4]),
    .ttbcr_t0sz_o               (ttbcr_t0sz[2:0]),
    .ttbcr_t1sz_o               (ttbcr_t1sz[2:0]),
    .ttbcr_epd_o                (ttbcr_epd[1:0]),
    .ttbcr_attrs0_o             (ttbcr_attrs0[5:0]),
    .ttbcr_attrs1_o             (ttbcr_attrs1[5:0]),
    .ttbcr_eae_s_o              (ttbcr_eae_s),
    .ttbcr_eae_ns_o             (ttbcr_eae_ns),
    .htcr_t0sz_o                (htcr_t0sz[2:0]),
    .htcr_attrs_o               (htcr_attrs[5:0]),
    .vtcr_attrs_o               (vtcr_attrs[5:0]),
    .vtcr_t0sz_o                (vtcr_t0sz[5:0]),
    .vtcr_sl0_o                 (vtcr_sl0[1:0]),
    .vtcr_tg0_o                 (vtcr_tg0),
    .vtcr_ps_o                  (vtcr_ps[2:0]),
    .mair0_o                    (mair0[31:0]),
    .mair1_o                    (mair1[31:0]),
    .context_id_o               (context_id[31:0]),
    .context_id_etm_o           (context_id_etm[31:0]),
    .asid_lookup_o              (asid_lookup[`CA53_ASID_W-1:0]),
    .asid_a32_pagewalk_o        (asid_a32_pagewalk[`CA53_ASID_W-1:0]),
    .asid_a64_pagewalk_o        (asid_a64_pagewalk[`CA53_ASID_W-1:0]),
    .tcr_tbi0_o                 (tcr_tbi0),
    .tcr_tbi1_o                 (tcr_tbi1),
    .tlb_d_tcr_el1_tbi_o        (tlb_d_tcr_el1_tbi_o[1:0]),
    .tlb_d_tcr_el2_tbi0_o       (tlb_d_tcr_el2_tbi0_o),
    .tlb_d_tcr_el3_tbi0_o       (tlb_d_tcr_el3_tbi0_o),
    .tlb_vmid_o                 (tlb_vmid[7:0]),
    .ttbr0_a64_el1_addr_o       (ttbr0_a64_el1_addr[47:4]),
    .ttbr1_a64_el1_addr_o       (ttbr1_a64_el1_addr[47:4]),
    .ttbr0_a64_el2_addr_o       (ttbr0_a64_el2_addr[47:4]),
    .ttbr0_a64_el3_addr_o       (ttbr0_a64_el3_addr[47:4]),
    .tcr_a64_el1_t0sz_o         (tcr_a64_el1_t0sz[5:0]),
    .tcr_a64_el1_t1sz_o         (tcr_a64_el1_t1sz[5:0]),
    .tcr_a64_el2_t0sz_o         (tcr_a64_el2_t0sz[5:0]),
    .tcr_a64_el3_t0sz_o         (tcr_a64_el3_t0sz[5:0]),
    .tcr_a64_el1_ips_o          (tcr_a64_el1_ips[2:0]),
    .tcr_a64_el2_ps_o           (tcr_a64_el2_ps[2:0]),
    .tcr_a64_el3_ps_o           (tcr_a64_el3_ps[2:0]),
    .tcr_a64_el1_epd_o          (tcr_a64_el1_epd[1:0]),
    .tcr_a64_el1_attrs0_o       (tcr_a64_el1_attrs0[5:0]),
    .tcr_a64_el1_attrs1_o       (tcr_a64_el1_attrs1[5:0]),
    .tcr_a64_el3_attrs_o        (tcr_a64_el3_attrs[5:0]),
    .tcr_a64_el1_tg0_o          (tcr_a64_el1_tg0),
    .tcr_a64_el1_tg1_o          (tcr_a64_el1_tg1),
    .tcr_a64_el2_tg0_o          (tcr_a64_el2_tg0),
    .tcr_a64_el3_tg0_o          (tcr_a64_el3_tg0),
    .tlb_i_utlb_flush_o         (tlb_i_utlb_flush_o),
    .tlb_d_utlb_flush_o         (tlb_d_utlb_flush_o),
    .mbist_in_data_mb4_o        (mbist_in_data_mb4[`CA53_TLB_RAM_W-1:0]),
    .mbist_read_en_mb4_o        (mbist_read_en_mb4[3:0]),
    .mbist_write_en_mb4_o       (mbist_write_en_mb4[3:0]),
    .tlb_mbist_out_data_mb6_o   (tlb_mbist_out_data_mb6_o[116:0]),
    .tlb_mem_granule_o          (tlb_mem_granule_o[1:0])
  );  // u_tlb_cp_regs

  //------------------------------------------------------------------------------
  // Output alias assignments
  //------------------------------------------------------------------------------

  assign tlb_cp_reg_write_ready_o = tlb_cp_reg_write_ready;

  assign tlb_context_id_o = context_id_etm;

  assign tlb_vmid_o = tlb_vmid;

  assign tlb_pagewalk_invalidated_o = pagewalk_invalidated;

  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  reg ovl_dpu_tlb_abandon_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ovl_dpu_tlb_abandon_reg <= 1'b0;
  end else begin
    ovl_dpu_tlb_abandon_reg <= dpu_tlb_abandon_i;
  end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Pagewalk and lookup must not both happen for the iside at the same time")
  u_ovl_lookup_pagewalk1 (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (u_tlb_lookup.ovl_lookup_in_progress & pagewalk_busy_iside),
                          .consequent_expr (~lookup_iside));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Pagewalk and lookup must not both happen for the iside at the same time")
  u_ovl_lookup_pagewalk2 (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (u_tlb_lookup.ovl_lookup_in_progress & pagewalk_busy_dside),
                          .consequent_expr (lookup_iside));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The uTLB must not be updated when a DPU register changes")
  u_ovl_utlb_update_abandon1 (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (dpu_tlb_abandon_i),
                              .consequent_expr (~tlb_i_utlb_enable_o));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The uTLB must not be updated when a DPU register changes")
  u_ovl_utlb_update_abandon2 (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (dpu_tlb_abandon_i),
                              .consequent_expr (~tlb_d_utlb_enable_o));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The uTLB must not be updated when a DPU register changes")
  u_ovl_utlb_update_abandon3 (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (ovl_dpu_tlb_abandon_reg),
                              .consequent_expr (~tlb_i_utlb_enable_o));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The uTLB must not be updated when a DPU register changes")
  u_ovl_utlb_update_abandon4 (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (ovl_dpu_tlb_abandon_reg),
                              .consequent_expr (~tlb_d_utlb_enable_o));

`endif


endmodule // ca53tlb

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_tlb_rams_defs.v"
`include "ca53_ifu_tlb_defs.v"
`include "ca53_dpu_tlb_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53_biu_tlb_defs.v"
`include "ca53tlb_defs.v"
`undef CA53_UNDEFINE
/*END*/

