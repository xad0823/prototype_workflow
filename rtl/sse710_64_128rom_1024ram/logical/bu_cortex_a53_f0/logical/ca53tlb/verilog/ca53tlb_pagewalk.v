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
// Abstract : TLB pagetable walk logic, including control for the walk cache
// and IPA cache.
//-----------------------------------------------------------------------------

`include "ca53tlb_defs.v"
`include "ca53_biu_tlb_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53_dpu_tlb_defs.v"
`include "ca53_ifu_tlb_defs.v"
`include "ca53_tlb_rams_defs.v"
`include "cortexa53params.v"

module ca53tlb_pagewalk `CA53_TLB_PARAM_DECL
 (
  input  wire                          clk,
  input  wire                          reset_n,
  input  wire                          DFTSE,

  input  wire                          start_pagewalk_i,
  input  wire                          lookup_active_i,
  input  wire [48:12]                  lookup_va_i,
  input  wire                          lookup_va_sign_err_i,
  input  wire                          lookup_va_mmuoff_sign_err_i,
  input  wire                          lookup_ns_i,
  input  wire                          lookup_mmuon_i,
  input  wire                          lookup_iside_i,
  input  wire                          lookup_v2p_ipa_i,
  input  wire [3:1]                    lookup_aarch64_at_el_i,
  input  wire [1:0]                    lookup_exception_level_i,
  input  wire [3:2]                    lookup_exception_level_early_i,

  // Support for granule calculation
  input  wire [47:20]                  lookup_va_early_i,
  input  wire                          lookup_ns_early_i,
  input  wire                          lookup_aarch64_at_el3_early_i,
  input  wire                          lookup_aarch64_early_i,

  input  wire [5:0]                    lookup_tcr_a64_muxed_t0sz_i,
  input  wire                          lookup_stage2_a64_g64_i,
  input  wire                          lookup_el3_el2_i,
  input  wire                          lookup_el3_el2_g64_i,
  input  wire                          lookup_ttbr0_sign_match_i,

  input  wire [1:0]                    lookup_victim_way_size0_i,
  input  wire [1:0]                    lookup_victim_way_size1_i,
  input  wire [1:0]                    lookup_victim_way_size2_i,
  input  wire [1:0]                    lookup_victim_way_size3_i,

  output wire                          pagewalk_ram_req_o,
  output wire [3:0]                    pagewalk_ram_way_o,
  output wire                          pagewalk_ram_wr_o,
  output wire [7:0]                    pagewalk_ram_addr_o,
  output wire [`CA53_TLB_RAM_W-1:0]    pagewalk_ram_wr_data_o,
  output wire                          pagewalk_i_utlb_enable_o,
  output wire                          pagewalk_d_utlb_enable_o,
  output wire                          pagewalk_i_utlb_next_might_enable_o,
  output wire                          pagewalk_d_utlb_next_might_enable_o,
  output wire [95:0]                   pagewalk_d_utlb_data_o,
  output wire [96:0]                   pagewalk_i_utlb_data_o,
  output wire                          pagewalk_invalidated_o,
  output wire                          pagewalk_state_idle_o,
  output wire                          pagewalk_busy_iside_o,
  output wire                          pagewalk_busy_dside_o,
  input  wire                          pagewalk_ram_pri_i,
  output wire                          pagewalk_size_reduced_o,
  output wire                          pagewalk_hitmap_update_iside_o,
  output wire                          pagewalk_hitmap_update_dside_o,
  output wire [2:0]                    pagewalk_hitmap_size_o,
  output reg  [39:16]                  pagewalk_ipa_compare_ipa_o,
  output wire [2:0]                    pagewalk_ipa_compare_size_o,
  output wire                          stage2_pagewalk_a64_g64_o,
  output wire                          pagewalk_state_ipa_compare_o,

  input  wire                          sel_victim_round_robin_i,
  input  wire [1:0]                    first_available_way_i,
  input  wire                          walk_cache_hit_i,
  input  wire [46:0]                   walk_cache_data_i,
  input  wire [3:0]                    ipa_cache_hit_way_i,
  input  wire [37:0]                   ipa_cache_data_i,
  input  wire                          ipa_hitmap_flush_i,

  input  wire                          dpu_ipa_to_pa_en_i,
  input  wire                          dpu_default_cacheable_i,
  input  wire                          dpu_pr_tablewalk_i,
  input  wire                          dpu_tlb_abandon_i,
  input  wire                          dpu_sctlr_wxn_el3_i,
  input  wire                          dpu_sctlr_wxn_el1_i,
  input  wire                          dpu_sctlr_wxn_el2_i,
  input  wire                          dpu_sctlr_uwxn_el3_i,
  input  wire                          dpu_sctlr_uwxn_el1_i,
  input  wire                          dpu_tex_remap_enable_el3_i,
  input  wire                          dpu_tex_remap_enable_el1_i,
  input  wire                          dpu_access_flag_enable_el3_i,
  input  wire                          dpu_access_flag_enable_el1_i,
  input  wire                          dpu_endian_el3_i,
  input  wire                          dpu_endian_el1_i,
  input  wire                          dpu_endian_el2_i,
  input  wire                          dpu_icache_on_i,
  input  wire                          dpu_dcache_on_el1_i,
  input  wire                          dpu_dcache_on_el2_i,
  input  wire                          dpu_dcache_on_el3_i,

  input  wire                          dpu_s2_dcache_on_i,

  input  wire                          ifu_utlb_miss_req_i,
  input  wire                          dcu_va_valid_dc1_i,
  input  wire                          cp_op_waiting_i,

  output wire [1:0]                    tlb_cache_walk_lookup_req_m0_o,
  output wire [39:3]                   tlb_cache_walk_addr_o,
  output wire                          tlb_cache_walk_ns_dsc_o,

  input  wire                          dcu_cache_walk_ack_m1_i,
  input  wire                          dcu_cache_walk_hit_m2_i,
  input  wire [3:0]                    dcu_cache_walk_victim_way_m2_i,
  input  wire [63:0]                   dcu_cache_walk_data_m2_i,
  input  wire                          dcu_ecc_err_m3_i,
  input  wire                          dcu_cache_walk_has_priority_m0_i,

  output wire                          tlb_walk_nc_req_o,
  output wire                          tlb_walk_lf_req_o,
  output wire                          tlb_walk_lf_active_o,
  output wire [7:0]                    tlb_walk_attrs_o,
  output wire [1:0]                    tlb_walk_way_o,
  output wire [39:0]                   tlb_walk_addr_o,
  output wire                          tlb_walk_ns_dsc_o,
  output wire                          tlb_walk_size_o,

  input  wire                          biu_walk_lf_hazard_i,
  input  wire                          biu_walk_ack_i,
  input  wire [63:0]                   biu_walk_data_i,
  input  wire [2:0]                    biu_walk_resp_i,

  input  wire [47:4]                   ttbr0_addr_i,
  input  wire [47:4]                   ttbr1_addr_i,
  input  wire [47:4]                   httbr_addr_i,
  input  wire [47:4]                   vttbr_addr_i,


  input  wire [2:0]                    ttbcr_t0sz_i,
  input  wire [2:0]                    ttbcr_t1sz_i,
  input  wire [1:0]                    ttbcr_epd_i,


  input  wire [5:0]                    ttbcr_attrs0_i,
  input  wire [5:0]                    ttbcr_attrs1_i,
  input  wire                          ttbcr_eae_s_i,
  input  wire                          ttbcr_eae_ns_i,
  input  wire [2:0]                    htcr_t0sz_i,
  input  wire [5:0]                    htcr_attrs_i,
  input  wire [5:0]                    vtcr_t0sz_i,
  input  wire [1:0]                    vtcr_sl0_i,
  input  wire [5:0]                    vtcr_attrs_i,
  input  wire                          vtcr_tg0_i,
  input  wire [2:0]                    vtcr_ps_i,

  input  wire [31:0]                   mair0_i,
  input  wire [31:0]                   mair1_i,
  input  wire [7:0]                    tlb_vmid_i,
  input  wire [`CA53_ASID_W-1:0]       asid_a32_pagewalk_i,
  input  wire [`CA53_ASID_W-1:0]       asid_a64_pagewalk_i,

  input  wire [47:4]                   ttbr0_a64_el1_addr_i,
  input  wire [47:4]                   ttbr1_a64_el1_addr_i,
  input  wire [47:4]                   ttbr0_a64_el2_addr_i,
  input  wire [47:4]                   ttbr0_a64_el3_addr_i,
  input  wire [5:0]                    tcr_a64_el1_t0sz_i,
  input  wire [5:0]                    tcr_a64_el1_t1sz_i,
  input  wire [5:0]                    tcr_a64_el3_t0sz_i,
  input  wire [5:0]                    tcr_a64_el2_t0sz_i,
  input  wire [2:0]                    tcr_a64_el1_ips_i,
  input  wire [2:0]                    tcr_a64_el2_ps_i,
  input  wire [2:0]                    tcr_a64_el3_ps_i,
  input  wire [1:0]                    tcr_a64_el1_epd_i,
  input  wire [5:0]                    tcr_a64_el1_attrs0_i,
  input  wire [5:0]                    tcr_a64_el1_attrs1_i,
  input  wire [5:0]                    tcr_a64_el3_attrs_i,
  input  wire                          tcr_a64_el1_tg0_i,
  input  wire                          tcr_a64_el1_tg1_i,

  output wire                          pagewalk_ns_o,
  output wire                          pagewalk_lpae_o,
  output wire                          pagewalk_hyp_o,
  output wire                          pagewalk_a64_o,
  output wire                          pagewalk_va_sign_o,
  output wire [23:0]                   walk_ram_masked_va_o,
  output wire [7:0]                    pagewalk_vmid_o,
  output wire [1:0]                    walk_ram_arch_o,
  output wire                          pagewalk_enable_walk_compare_o,

  output wire                          tlb_evnt_data_pagewalk_o,
  output wire                          tlb_evnt_instr_pagewalk_o,
  output wire [`CA53_ASID_W-1:0]       asid_pagewalk_o,

  input  wire                          lookup_aarch64_i, // Current request architecture
  output wire                          pagewalk_aarch64_at_el3_o,
  output wire [1:0]                    pagewalk_exception_level_o,

  input  wire                          lookup_ecc_err_early_i,
  input  wire [3:0]                    lookup_ecc_err_way_early_i,
  input  wire [6:0]                    lookup_ecc_err_addr_i,

  input wire                           walk_ipa_cache_ecc_err_i,
  input wire  [3:0]                    walk_ipa_cache_ecc_err_way_i,
  input wire  [3:0]                    walk_ipa_ecc_err_addr_i,

  output wire                          lookup_s1s2_a64_g64_o, // Support for granule calculation

  output wire                          tlb_pty_valid_non_cp_o, // Support for ECC reporting
  output wire [2:0]                    tlb_pty_way_non_cp_o
);

  //------------------------------------------------------------------------------
  // Flop declarations
  //------------------------------------------------------------------------------

  reg [`CA53_PAGEWALK_ST_WIDTH-1:0]    pagewalk_state;

  reg [2:0]                            pagewalk_stage1_level;
  reg [2:0]                            pagewalk_stage2_level;

  reg [48:12]                          pagewalk_va;
  reg                                  pagewalk_va_sign_err;
  reg                                  pagewalk_va_mmuoff_sign_err;
  reg                                  pagewalk_iside;
  reg [39:2]                           pagewalk_addr;
  reg                                  pagewalk_ns;
  reg [1:0]                            pagewalk_swizzle;
  reg                                  pagewalk_mmuon;
  reg                                  pagewalk_v2p_ipa;
  reg                                  pagewalk_ns_dsc;
  reg                                  pagewalk_ram_req;
  reg [7:0]                            pagewalk_ram_addr;
  reg                                  pagewalk_req_dropped;
  reg                                  pagewalk_abandoned;
  reg                                  pagewalk_invalidated;
  reg [1:0]                            pagewalk_victim_way_size0;
  reg [1:0]                            pagewalk_victim_way_size1;
  reg [1:0]                            pagewalk_victim_way_size2;
  reg [1:0]                            pagewalk_victim_way_size3;

  reg [63:0]                           pagewalk_raw_data;
  reg [2:0]                            pagewalk_rresp;
  reg [7:0]                            pagewalk_attrs;
  reg [7:0]                            pagewalk_attrs_to_walk_cache;
  reg                                  pagewalk_size;
  reg [1:0]                            tlb_walk_way;

  reg [2:0]                            stage1_ap;
  wire                                 stage1_xn;

  reg                                  stage1_xn_usr;
  reg                                  stage1_xn_nusr;
  reg                                  stage1_pxn;
  reg                                  stage1_ns;
  reg                                  stage1_ng;
  reg [2:0]                            stage1_domain_only;
  reg                                  stage1_domain_only_ls;
  reg                                  stage1_domain_muxed;
  reg [7:0]                            stage1_attrs;
  reg [2:0]                            stage1_page_size;
  reg [39:2]                           stage1_addr;
  reg                                  stage1_translation_completed;
  reg  [2:0]                           combined_page_size;
  reg  [1:0]                           next_combined_page_size_ext; //TLB RAM format of combined page size
  reg  [1:0]                           combined_page_size_ext; //TLB RAM format of combined page size

  reg [1:0]                            walk_victim_round_robin;
  reg [1:0]                            walk_victim_way;
  reg                                  walk_cache_previous_hit;

  reg                                  ipa_cache_previous_hit;
  reg [1:0]                            ipa_page_size;
  reg [3:0]                            ipa_master_hitmap;
  reg [5:0]                            ipa_size_order;
  reg [1:0]                            ipa_compare_size;
  reg [2:0]                            ipa_size_remaining;
  reg [1:0]                            ipa_victim_round_robin;
  reg [1:0]                            ipa_victim_way_size0_early;
  reg [1:0]                            ipa_victim_way_size1_early;
  reg [1:0]                            ipa_victim_way_size2_early;
  reg [1:0]                            ipa_victim_way_size3_early;

  reg                                  clk_enable;

  reg  [39:0]                          stage1_a64_g4_start_addr;
  reg  [39:0]                          stage1_a64_g64_start_addr;
  reg  [39:0]                          stage2_a64_g4_start_addr;
  reg  [39:0]                          stage2_a64_g64_start_addr;

  reg [`CA53_PAGEWALK_ST_WIDTH-1:0]    next_pagewalk_state;
  reg                                  next_pagewalk_ram_req;
  reg                                  next_pagewalk_ram_tlb;
  reg                                  next_pagewalk_ram_walk;
  reg                                  next_pagewalk_ram_ipa;
  reg [39:0]                           stage1_start_addr;
  reg [39:0]                           stage2_start_addr;
  reg [6:0]                            tlb_wr_addr;
  reg [63:0]                           pagewalk_data;
  reg [47:19]                          ram_masked_va;
  reg [39:12]                          ram_masked_pa;
  reg [2:0]                            stage1_raw_page_size; // 3-bit local format, same as TLB RAM S1-size field encoding
  reg [1:0]                            stage2_raw_page_size_ext; // 2-bit format, same as IPA RAM size format
  reg [2:0]                            stage2_raw_page_size; // 3-bit local format, same as TLB RAM S1-size field encoding
  reg [39:0]                           pagewalk_output_addr;

  reg [6:0]                            ttbcr_t0sz_mask;
  reg [6:0]                            ttbcr_t1sz_mask;
  wire [5:0]                           capped_vtcr_t0sz;
  reg [14:0]                           vtcr_t0sz_mask;
  reg [14:0]                           vtcr_a64_el2_t0sz_mask;
  reg [1:0]                            next_pagewalk_swizzle;
  reg [2:0]                            ipa_compare_level;
  reg [3:0]                            ipa_cache_addr;
  reg [39:16]                          ipa_ram_masked_ipa;
  reg [39:12]                          ipa_ram_masked_pa;
  reg [3:1]                            pagewalk_aarch64_at_el;
  reg [1:0]                            pagewalk_exception_level;
  reg                                  pagewalk_a64;
  reg [22:0]                           tcr_a64_el1_t0sz_mask;
  reg [22:0]                           tcr_a64_el1_t1sz_mask;
  reg [1:0]                            pagewalk_victim_way;
  reg [1:0]                            selected_ipa_victim_way;

  reg                                  stage1_a32_pagewalk_disable;
  reg                                  stage1_a32_pagewalk_disable_out_addr;
  reg                                  stage1_a64_pagewalk_disable;
  reg                                  stage1_a64_pagewalk_disable_out_addr;
  reg                                  stage2_a32_pagewalk_disable;
  reg                                  stage2_a32_pagewalk_disable_out_addr;
  reg                                  stage2_a64_pagewalk_disable;
  reg                                  stage2_a64_pagewalk_disable_out_addr;
  reg                                  xs1nonusr;
  reg                                  xs1usr;
  reg                                  pagewalk_match_a64_ttbr0;
  reg                                  pagewalk_tcr_a64_tg;
  reg                                  pagewalk_lpae;
  reg  [7:0]                           tcr_a64_el1_ps_mask;
  reg  [7:0]                           vtcr_a64_el2_ps_mask;
  reg                                  stage2_a32_t0sz_sl0_mismatch;
  reg                                  stage2_a64_g4_t0sz_sl0_mismatch;
  reg                                  stage2_a64_g64_t0sz_sl0_mismatch;
  reg  [3:0]                           pagewalk_walk_cache_addr;
  reg                                  pagewalk_dcache_on;
  reg                                  dcu_cache_walk_previous_hit;

  //------------------------------------------------------------------------------
  // Wire declarations
  //------------------------------------------------------------------------------

  wire [39:0]                          stage1_a64_start_addr;
  wire [39:0]                          stage2_a64_start_addr;
  wire [2:0]                           next_combined_page_size; // 3-bit local format, same as TLB RAM S1-size field
  wire [7:0]                           next_pagewalk_ram_addr;
  wire                                 pagewalk_state_idle;
  wire                                 pagewalk_state_lookup_m0;
  wire                                 pagewalk_state_lookup_m2;
  wire                                 pagewalk_state_lookup_m3;
  wire                                 pagewalk_state_linefill;
  wire                                 pagewalk_state_linefill_hz;
  wire                                 pagewalk_state_process;
  wire                                 pagewalk_state_tlb_write;
  wire                                 pagewalk_state_biu_axi_wait;
  wire                                 pagewalk_state_walk_lookup;
  wire                                 pagewalk_state_walk_compare;
  wire                                 pagewalk_state_walk_wait;
  wire                                 pagewalk_state_walk_write;
  wire                                 pagewalk_state_ipa_lookup;
  wire                                 pagewalk_state_ipa_compare;
  wire                                 pagewalk_state_ipa_write;
  wire                                 pagewalk_state_tlb_write0;
  wire                                 pagewalk_state_walk_write0;
  wire                                 pagewalk_state_ipa_write0;
  wire                                 pagewalk_state_ipa_wait;

  wire [47:4]                          stage1_ttbr_addr;
  wire [47:4]                          stage1_a64_ttbr_addr;
  wire [39:0]                          walk_cache_start_addr;
  wire [39:0]                          next_pagewalk_addr;
  wire                                 access_flag_enable_vmsa;
  wire                                 access_flag_fault;
  wire                                 translation_fault;
  wire [5:0]                           tex_c_b_s;
  wire [4:0]                           attrindx_sh;
  wire                                 next_pagewalk_abandoned;
  wire                                 abandon_pagewalk;
  wire                                 next_pagewalk_invalidated;
  wire [3:0]                           walk_cache_addr;
  wire [2:0]                           next_pagewalk_stage1_level;
  wire [2:0]                           next_pagewalk_stage2_level;
  wire                                 pagewalk_stage1_level_idle;
  wire                                 pagewalk_stage1_level0;
  wire                                 pagewalk_stage1_level1;
  wire                                 pagewalk_stage1_level2;
  wire                                 pagewalk_stage1_level3;
  wire                                 pagewalk_stage2_level1;
  wire                                 pagewalk_stage2_level2;
  wire                                 pagewalk_stage2_level3;
  wire                                 pagewalk_stage1;
  wire                                 pagewalk_stage2;
  wire                                 pagewalk_level_en;
  wire                                 another_fetch_required;
  wire [7:0]                           pagewalk_vmid;
  wire [2:0]                           next_stage1_ap;

  wire                                 next_stage1_xn_usr;
  wire                                 next_stage1_xn_usr_nowalk;
  wire                                 next_stage1_xn_nusr;
  wire                                 next_stage1_xn_nusr_nowalk;

  wire                                 next_stage1_pxn;
  wire                                 next_stage1_pxn_nowalk;
  wire                                 next_stage1_ns;
  wire                                 next_stage1_ns_nowalk;
  wire                                 next_stage1_ng;
  wire [2:0]                           next_stage1_domain_only;
  wire                                 next_stage1_domain_only_ls;
  wire                                 next_stage1_domain_muxed;
  wire [2:0]                           next_stage1_domain_nowalk_only;
  wire                                 next_stage1_domain_nowalk_only_ls;
  wire                                 next_stage1_domain_nowalk_muxed;
  wire [7:0]                           next_stage1_attrs;
  wire [2:0]                           next_stage1_page_size; // 3-bit local format, same as TLB RAM S1-size
  wire [39:2]                          next_stage1_addr;
  wire [41:0]                          pagewalk_input_addr;
  wire [2:0]                           next_stage1_ap_nowalk;
  wire [2:0]                           next_stage1_ap_lpae;
  wire [2:0]                           next_stage1_ap_vmsa;

  wire                                 next_stage1_xn_common_lpae;
  wire                                 next_stage1_xn_usr_lpae;
  wire                                 next_stage1_xn_nusr_lpae;

  wire                                 next_stage1_xn_usr_vmsa;
  wire                                 next_stage1_xn_nusr_vmsa;

  wire                                 next_stage1_pxn_lpae;
  wire                                 next_stage1_pxn_vmsa;
  wire                                 next_stage1_ns_lpae;
  wire                                 next_stage1_ns_vmsa;
  wire [1:0]                           pagewalk_hap;
  wire [1:0]                           pagewalk_hap_ram;
  wire [2:0]                           pagewalk_ap;
  wire [2:0]                           pagewalk_ap_ram;
  wire                                 pagewalk_abort;
  wire                                 stage1_en;
  wire [7:0]                           remapped_attrs;
  wire                                 pagewalk_state_en;
  wire                                 current_fetch_lpae;
  wire [6:0]                           pagewalk_fault_type;
  wire                                 pagewalk_ram_written;
  wire                                 pagewalk_addr_en;
  wire                                 match_ttbr0;
  wire                                 match_ttbr1;
  wire                                 match_ttbr0_out_addr;
  wire                                 match_vttbr0_out_addr;
  wire                                 pagewalk_use_ttbr0;
  wire                                 pagewalk_use_ttbr1;
  wire [1:0]                           next_tlb_walk_way;
  wire [63:0]                          ipa_cache_data_expanded;
  wire [63:0]                          next_pagewalk_raw_data;
  wire                                 pagewalk_data_en;
  wire [2:0]                           next_pagewalk_rresp;
  wire                                 external_abort;
  wire                                 external_dec_abort;
  wire                                 external_ecc_abort;
  wire [5:0]                           raw_attrs;
  wire [7:0]                           next_pagewalk_attrs;
  wire [7:0]                           next_pagewalk_attrs_to_walk_cache;
  wire [7:0]                           walk_cache_attr_data; // Attribute field of walk cache data signals
  wire                                 next_pagewalk_size;
  wire                                 next_pagewalk_req_dropped;
  wire                                 pagewalk_utlb_enable;
  wire                                 pagewalk_utlb_next_might_enable;
  wire [2:0]                           ttbcr_sz;
  wire [5:0]                           tcr_a64_sz;
  wire [2:0]                           stage1_start_level;
  wire                                 match_vttbr;
  wire                                 match_a64_vttbr;
  wire                                 stage2_translation_required_normal;
  wire                                 stage2_translation_required;
  wire                                 stage1_translation_will_complete;
  wire                                 stage1_translation_complete;
  wire                                 stage2_translation_will_complete;
  wire                                 stage2_translation_complete;
  wire                                 next_stage1_translation_completed;
  wire                                 start_next_translation;
  wire                                 start_stage1_translation;
  wire                                 start_stage2_translation;
  wire                                 next_ipa_cache_previous_hit;
  wire [2:0]                           pagewalk_level;
  wire [3:0]                           stage2_memattrs;
  wire [1:0]                           stage2_sh;
  wire [7:0]                           combined_attrs;
  wire [7:0]                           stage1_mmuoff_attrs;
  wire [7:0]                           stage1_memattrs;
  wire [7:0]                           ttbcr_attrs;
  wire                                 stage2_permission_fault;
  wire                                 stage2_dev_so_fault;
  wire [1:0]                           stage1_level;
  wire                                 next_pagewalk_ns_dsc;
  wire                                 pagewalk_wxn;
  wire                                 pagewalk_uwxn;
  wire                                 force_stage1_xn_usr;
  wire                                 force_stage1_xn_nusr;

  wire                                 force_stage1_pxn;
  wire                                 endian_swizzle;
  wire [113:0]                         tlb_ram_common_wr_data;
  wire [`CA53_TLB_RAM_W-1:0]           tlb_ram_wr_data;
  wire [113:0]                         walk_ram_common_wr_data;
  wire [`CA53_TLB_RAM_W-1:0]           walk_ram_wr_data;
  wire [113:0]                         ipa_ram_common_wr_data;
  wire [`CA53_TLB_RAM_W-1:0]           ipa_ram_wr_data;
  wire [3:0]                           next_ipa_master_hitmap;
  wire                                 ipa_master_hitmap_en;
  wire [7:0]                           full_ipa_size_order;
  wire [1:0]                           ipa_order_update_size;
  wire [1:0]                           ipa_size_order_shift;
  wire [5:0]                           next_ipa_size_order;
  wire                                 ipa_size_order_en;
  wire [3:0]                           ipa_size_order_valid;
  wire [3:0]                           ipa_size_valid;
  wire [2:0]                           next_ipa_size_remaining;
  wire [2:0]                           ipa_size_sel;
  wire [1:0]                           next_ipa_page_size;
  wire                                 ipa_size_en;
  wire [1:0]                           next_ipa_victim_round_robin;
  wire [1:0]                           ipa_victim_way;
  wire [3:0]                           ipa_compare_size_onehot;
  wire [1:0]                           ipa_victim_way_size0;
  wire [1:0]                           ipa_victim_way_size1;
  wire [1:0]                           ipa_victim_way_size2;
  wire [1:0]                           ipa_victim_way_size3;
  wire [1:0]                           next_ipa_victim_way_size0_early;
  wire [1:0]                           next_ipa_victim_way_size1_early;
  wire [1:0]                           next_ipa_victim_way_size2_early;
  wire [1:0]                           next_ipa_victim_way_size3_early;
  wire                                 ipa_victim_ways_en;
  wire [1:0]                           next_walk_victim_round_robin;
  wire [1:0]                           next_walk_victim_way;
  wire                                 next_walk_cache_previous_hit;
  wire                                 clk_pagewalk;
  wire                                 next_clk_enable;
  wire [1:0]                           i_utlb_excp_level;
  wire                                 ttbcr_coherent;
  wire [1:0]                           ttbcr_inner_alloc_hint;
  wire [1:0]                           ttbcr_outer_alloc_hint;
  wire                                 dside_default_cacheable;
  wire                                 lpae_translation_fault;
  wire [2:0]                           start_level_a32;
  wire [2:0]                           start_level_a64_g4;
  wire [2:0]                           start_level_a64_g64;
  wire                                 start_level0_a64_g4;
  wire                                 start_level1_a64_g4;
  wire                                 start_level1_a64_g64;
  wire                                 start_level2_a64_g64;
  wire                                 stage1_start_level3_a64_g64;
  wire [2:0]                           next_pagewalk_stage1_update;
  wire [2:0]                           next_pagewalk_stage2_update;
  wire [3:0]                           main_ram_en;
  wire [3:0]                           walk_ram_en;
  wire [3:0]                           ipa_ram_en;
  wire [1:0]                           walk_ram_arch;
  wire                                 match_a64_ttbr0;
  wire                                 match_a64_ttbr1;
  wire                                 pagewalk_exception_level3;
  wire                                 pagewalk_exception_level2;
  wire                                 pagewalk_exception_level1;
  wire                                 pagewalk_exception_level0;
  wire                                 pagewalk_exception_level01; // EL0 OR EL1
  wire                                 pagewalk_a32;
  wire                                 pagewalk_a64_g4;
  wire                                 pagewalk_a64_g64;
  wire [5:0]                           ttbcr_attrs01;
  wire [5:0]                           tcr_a64_el1_attrs01;
  wire [`CA53_ASID_W-1:0]              asid_pagewalk;
  wire [2:0]                           tcr_a64_elx_ps;
  wire                                 match_a64_output_addr;
  wire                                 translation_fault_out_addr;
  wire                                 translation_fault_a64_out_addr;
  wire                                 mmuoff_fault_out_addr;
  wire                                 sel_mux_input_start_addr;
  wire                                 sel_mux_input_subsequent_addr;
  wire [39:2]                          mux_input_start_addr;
  wire [39:2]                          mux_input_subsequent_addr;
  wire                                 stage2_match_a64_output_addr;
  wire                                 next_any_stage1_pagewalk_disable;
  wire                                 next_any_stage2_pagewalk_disable;
  wire                                 next_any_pagewalk_disable;
  wire                                 stage2_a64_g64_pagewalk_disable_addr;
  wire                                 stage2_pagewalk_a32;
  wire                                 stage2_pagewalk_a64;
  wire                                 stage2_pagewalk_a64_g4;
  wire                                 stage2_pagewalk_a64_g64;
  wire                                 a32_pagewalk_disable;
  wire                                 a32_pagewalk_disable_out_addr;
  wire                                 a64_pagewalk_disable;
  wire                                 a64_pagewalk_disable_out_addr;
  wire                                 next_stage1_a32_pagewalk_disable;
  wire                                 next_stage1_a32_pagewalk_disable_out_addr;
  wire                                 next_stage2_a32_pagewalk_disable;
  wire                                 next_stage2_a32_pagewalk_disable_out_addr;
  wire                                 next_stage1_a64_pagewalk_disable;
  wire                                 next_stage1_a64_pagewalk_disable_out_addr;
  wire                                 next_stage2_a64_pagewalk_disable;
  wire                                 next_stage2_a64_pagewalk_disable_out_addr;
  wire                                 lookup_match_a64_ttbr0;
  wire                                 lookup_tcr_a64_tg;
  wire                                 lookup_a64_g64;
  wire                                 lookup_lpae;
  wire                                 lookup_s1s2_a64_g64;// Support for granule calculation
  wire [3:0]                           lookup_walk_cache_addr;
  wire                                 raw_dcache_on;
  wire                                 dpu_dcache_on;
  wire                                 next_fetch_is_stage2;
  wire                                 tlb_walk_lf_req;
  wire                                 next_pagewalk_dcache_on;
  wire                                 next_xs1usr_a32;
  wire                                 next_xs1usr_a64;
  wire                                 next_xs1usr;
  wire                                 next_xs1nonusr;
  wire                                 next_xs2_a32;
  wire                                 next_xs2_a64;
  wire                                 next_xs2;
  wire                                 next_xs1nonusr_el1ns_el3s_a32;
  wire                                 next_xs1nonusr_el1ns_el1s_a64;
  wire [23:0]                          walk_ram_masked_va;

  wire                                 use_write0_states;
  wire                                 next_dcu_cache_walk_previous_hit;
  wire                                 walk_cache_ecc_err;
  wire [3:0]                           walk_cache_ecc_err_way;
  wire                                 ipa_cache_ecc_err;
  wire [3:0]                           ipa_cache_ecc_err_way;
  wire [3:0]                           ipa_cache_ecc_err_addr;
  wire                                 pagewalk_ecc_err_cmn;
  wire [3:0]                           pagewalk_ecc_err_way_cmn;
  wire [6:0]                           pagewalk_ecc_err_addr_cmn;

  // Support for ECC reporting
  wire                                 tlb_pty_valid_non_cp_cmn;

  //----------------------------------------------------------------------------
  // Intermediate clock gate
  //----------------------------------------------------------------------------

  // Avoid clocking the pagewalk logic unless there is a pagewalk in progress
  // or a lookup that might start a pagewalk.
  assign next_clk_enable = lookup_active_i | ~pagewalk_state_idle;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    clk_enable <= 1'b0;
  end else begin
    clk_enable <= next_clk_enable;
  end

  ca53_cell_inter_clkgate u_inter_clkgate_pagewalk (.clk_i         (clk),
                                                    .clk_enable_i  (clk_enable),
                                                    .clk_senable_i (DFTSE),
                                                    .clk_gated_o   (clk_pagewalk));

  //----------------------------------------------------------------------------
  // Capture the details of the pagewalk request
  //----------------------------------------------------------------------------

  always @(posedge clk_pagewalk)
  if (start_pagewalk_i) begin
    pagewalk_va                 <= lookup_va_i;
    pagewalk_va_sign_err        <= lookup_va_sign_err_i;
    pagewalk_va_mmuoff_sign_err <= lookup_va_mmuoff_sign_err_i;
    pagewalk_iside              <= lookup_iside_i;
    pagewalk_ns                 <= lookup_ns_i;
    pagewalk_victim_way_size0   <= lookup_victim_way_size0_i;
    pagewalk_victim_way_size1   <= lookup_victim_way_size1_i;
    pagewalk_victim_way_size2   <= lookup_victim_way_size2_i;
    pagewalk_victim_way_size3   <= lookup_victim_way_size3_i;
    pagewalk_mmuon              <= lookup_mmuon_i;
    pagewalk_v2p_ipa            <= lookup_v2p_ipa_i;
    pagewalk_aarch64_at_el      <= lookup_aarch64_at_el_i;
    pagewalk_exception_level    <= lookup_exception_level_i;
    pagewalk_a64                <= lookup_aarch64_i;
    pagewalk_walk_cache_addr    <= lookup_walk_cache_addr;
    pagewalk_match_a64_ttbr0    <= lookup_match_a64_ttbr0;
    pagewalk_tcr_a64_tg         <= lookup_tcr_a64_tg;
    pagewalk_lpae               <= lookup_lpae;
  end

  generate if (CPU_CACHE_PROTECTION) begin : g_protection_pw1

    reg        pagewalk_ecc_err;
    reg [3:0]  pagewalk_ecc_err_way;
    reg [6:0]  pagewalk_ecc_err_addr;

    always @(posedge clk_pagewalk)
    if (start_pagewalk_i) begin
        pagewalk_ecc_err      <= lookup_ecc_err_early_i;
        pagewalk_ecc_err_way  <= lookup_ecc_err_way_early_i;
        pagewalk_ecc_err_addr <= lookup_ecc_err_addr_i;
    end

    assign pagewalk_ecc_err_cmn      = pagewalk_ecc_err;
    assign pagewalk_ecc_err_way_cmn  = pagewalk_ecc_err_way;
    assign pagewalk_ecc_err_addr_cmn = pagewalk_ecc_err_addr;

  end else begin : g_protection_stubs_pw1

    assign pagewalk_ecc_err_cmn      = 1'b0;
    assign pagewalk_ecc_err_way_cmn  = {4{1'b0}};
    assign pagewalk_ecc_err_addr_cmn = {7{1'b0}};

  end endgenerate

  assign pagewalk_exception_level3 = (pagewalk_exception_level == 2'b11);
  assign pagewalk_exception_level2 = (pagewalk_exception_level == 2'b10);
  assign pagewalk_exception_level1 = (pagewalk_exception_level == 2'b01);
  assign pagewalk_exception_level0 = (pagewalk_exception_level == 2'b00);
  assign pagewalk_exception_level01 = ~pagewalk_exception_level[1]; // EL0 OR EL1

  assign pagewalk_a32 = ~pagewalk_a64;
  assign pagewalk_a64_g4 = pagewalk_a64 & ~pagewalk_tcr_a64_tg;
  assign pagewalk_a64_g64 = pagewalk_a64 & pagewalk_tcr_a64_tg;

  assign stage2_pagewalk_a32 = ~pagewalk_aarch64_at_el[2];
  assign stage2_pagewalk_a64 = pagewalk_aarch64_at_el[2];
  assign stage2_pagewalk_a64_g4 = pagewalk_aarch64_at_el[2] & ~vtcr_tg0_i;
  assign stage2_pagewalk_a64_g64 = pagewalk_aarch64_at_el[2] & vtcr_tg0_i;
  assign stage2_pagewalk_a64_g64_o = stage2_pagewalk_a64_g64;

  //------------------------------------------------------------------------------
  // State machine for pagetable walks
  //------------------------------------------------------------------------------

  generate if (CPU_CACHE_PROTECTION) begin : g_protection_pw2
    assign use_write0_states = 1'b1;
  end else begin : g_protection_stubs_pw2
    assign use_write0_states = 1'b0;
  end endgenerate

  always @*
  begin

    next_pagewalk_state = pagewalk_state;
    next_pagewalk_ram_req = 1'b0;
    // Determine which type of RAM access will be next cycle. If there is no RAM
    // access then these are ignored.
    next_pagewalk_ram_tlb = 1'b0;
    next_pagewalk_ram_walk = 1'b0;
    next_pagewalk_ram_ipa = 1'b0;

    case (pagewalk_state)
      `CA53_PAGEWALK_ST_IDLE: begin
        if (start_pagewalk_i) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_WALK_LOOKUP;
          next_pagewalk_ram_req = (lookup_mmuon_i & ~lookup_ecc_err_early_i);
        end
        next_pagewalk_ram_walk = 1'b1;
      end

      `CA53_PAGEWALK_ST_WALK_LOOKUP: begin
        if (pagewalk_ram_pri_i) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_WALK_COMPARE;
        end else begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_WALK_LOOKUP;
          next_pagewalk_ram_req = (pagewalk_mmuon & ~pagewalk_ecc_err_cmn);
        end
        next_pagewalk_ram_walk = 1'b1;
      end

      `CA53_PAGEWALK_ST_WALK_COMPARE: begin
        if (pagewalk_req_dropped | abandon_pagewalk) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
        end else begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_WALK_WAIT;
        end
      end

      `CA53_PAGEWALK_ST_WALK_WAIT: begin
        if (pagewalk_req_dropped | abandon_pagewalk) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
        // WALK cache ECC error checked. 
        // If there was main TLB RAM ECC error, WALK cache is not read 
        // in WALK lookup state. Main TLB RAM ECC error (pagewalk_ecc_err_cmn) 
        // is checked next
        end else if (walk_cache_ecc_err) begin
            next_pagewalk_state = `CA53_PAGEWALK_ST_WALK_WRITE0;
        end else if ( pagewalk_ecc_err_cmn |
                      next_any_pagewalk_disable |
                     (~pagewalk_mmuon & ~stage2_translation_required) |
                     ( stage2_translation_required & mmuoff_fault_out_addr)) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_PROCESS;
        end else if (start_stage2_translation) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IPA_LOOKUP;
          next_pagewalk_ram_req = 1'b1;
        end else if (start_stage1_translation ?
                       (`CA53_MEM_COHERENT(combined_attrs) & raw_dcache_on) :           // walk cache not hit
                       (`CA53_MEM_COHERENT(pagewalk_attrs) & pagewalk_dcache_on)) begin // walk cache hit
          next_pagewalk_state = `CA53_PAGEWALK_ST_LOOKUP_M0;
        end else begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_BIU_NC_REQ;
        end
        next_pagewalk_ram_ipa = 1'b1;
      end

      `CA53_PAGEWALK_ST_LOOKUP_M0: begin
        if (dcu_cache_walk_has_priority_m0_i) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_LOOKUP_M1;
        end else if (biu_walk_lf_hazard_i) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_BIU_LF_HZ;
        end
      end

      `CA53_PAGEWALK_ST_LOOKUP_M1: begin
        if (dcu_cache_walk_ack_m1_i) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_LOOKUP_M2;
        end
      end

      `CA53_PAGEWALK_ST_LOOKUP_M2: begin
        if (dcu_cache_walk_hit_m2_i) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_LOOKUP_M3;
        end else if (biu_walk_lf_hazard_i) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_BIU_LF_HZ;
        end else begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_LOOKUP_M3;
        end
      end


      `CA53_PAGEWALK_ST_LOOKUP_M3: begin
        // DCU ECC error set on DCU data (hit or miss) 
        if (dcu_ecc_err_m3_i) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_LOOKUP_M0;
        // No DCU ECC error, and it was a hit 
        end else if (dcu_cache_walk_previous_hit) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_PROCESS;
        end else if (biu_walk_lf_hazard_i) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_BIU_LF_HZ;
        end else begin
            next_pagewalk_state = `CA53_PAGEWALK_ST_BIU_LF_REQ;
        end
      end

      `CA53_PAGEWALK_ST_BIU_LF_REQ: begin
        if (biu_walk_ack_i) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_PROCESS;
        end else if (biu_walk_lf_hazard_i) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_BIU_LF_HZ;
        end else if (pagewalk_invalidated & pagewalk_req_dropped) begin
          // If nothing is going to use the result of the pagewalk then there
          // is no benefit in continuing. It also avoids the TLB linefill
          // request being delayed indefinitely by higher priority DCU and
          // STB requests.
          next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
        end
      end

      `CA53_PAGEWALK_ST_BIU_LF_HZ: begin
        if (biu_walk_ack_i) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_PROCESS;
        end else if (~biu_walk_lf_hazard_i) begin
          if (abandon_pagewalk) begin
            next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
          end else begin
            next_pagewalk_state = `CA53_PAGEWALK_ST_LOOKUP_M0;
          end
        end
      end

      `CA53_PAGEWALK_ST_PROCESS: begin
        if (abandon_pagewalk) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
        end else if (stage2_translation_complete & ~pagewalk_abort & 
                     ~pagewalk_invalidated & ~ipa_cache_previous_hit) begin
          // CPU_CACHE_PROTECTION dependent code start
          if (use_write0_states) begin
            next_pagewalk_state = `CA53_PAGEWALK_ST_IPA_WRITE0;
          end else begin
            next_pagewalk_state = `CA53_PAGEWALK_ST_IPA_WRITE;
            next_pagewalk_ram_req = 1'b1;
            next_pagewalk_ram_ipa = 1'b1;
          end
          // CPU_CACHE_PROTECTION dependent code end
        end else if (another_fetch_required) begin
          // For next S2, after fetching S1 descriptor in a two stage translation
          if (start_stage2_translation & ~pagewalk_invalidated) begin
            // Next S2, after fetching an S1 descriptor, is out of range
            if (next_any_stage2_pagewalk_disable) begin
              next_pagewalk_state = `CA53_PAGEWALK_ST_PROCESS;
            end else begin
              next_pagewalk_state = `CA53_PAGEWALK_ST_IPA_LOOKUP;
              next_pagewalk_ram_req = 1'b1;
              next_pagewalk_ram_ipa = 1'b1;
            end
          end else if (((stage2_translation_complete | ~stage2_translation_required) &
                        ~stage1_translation_complete &
                        // If start level is L3, walk cache should not be written.
                        // This also avoids the case when start level is L3,
                        // IPA hit --> Process state --> WALK_WRITE
                        (pagewalk_lpae ? ((pagewalk_stage1_level == 3'b010) & ~stage1_start_level3_a64_g64) :
                                         (pagewalk_stage1_level == 3'b001))) &
                       ~pagewalk_invalidated) begin
            // CPU_CACHE_PROTECTION dependent code start
            if (use_write0_states) begin
              next_pagewalk_state = `CA53_PAGEWALK_ST_WALK_WRITE0;
            end else begin
              next_pagewalk_state = `CA53_PAGEWALK_ST_WALK_WRITE;
              next_pagewalk_ram_req = 1'b1;
              next_pagewalk_ram_walk = 1'b1;
            end
            // CPU_CACHE_PROTECTION dependent code end
          end else if (`CA53_MEM_COHERENT(combined_attrs) & raw_dcache_on) begin
            next_pagewalk_state = `CA53_PAGEWALK_ST_LOOKUP_M0;
          end else begin
            next_pagewalk_state = `CA53_PAGEWALK_ST_BIU_NC_REQ;
          end
        end else if ((pagewalk_abort |
                      pagewalk_invalidated |
                      (~pagewalk_mmuon & ~(pagewalk_ns &
                                           ~pagewalk_exception_level2 &
                                           dpu_default_cacheable_i)) |
                      pagewalk_v2p_ipa) & ~pagewalk_ecc_err_cmn) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
        end else begin
            // CPU_CACHE_PROTECTION dependent code start
            if (use_write0_states) begin
              next_pagewalk_state = `CA53_PAGEWALK_ST_TLB_WRITE0;
            end else begin
              next_pagewalk_state = `CA53_PAGEWALK_ST_TLB_WRITE;
              next_pagewalk_ram_req = 1'b1;
              next_pagewalk_ram_tlb = 1'b1;
            end
            // CPU_CACHE_PROTECTION dependent code end
        end
      end

      `CA53_PAGEWALK_ST_WALK_WRITE: begin
        if (abandon_pagewalk) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
        end else if (pagewalk_ram_pri_i) begin
          if (pagewalk_req_dropped | walk_cache_ecc_err) begin
            next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
          end else if (`CA53_MEM_COHERENT(pagewalk_attrs) & pagewalk_dcache_on) begin
            next_pagewalk_state = `CA53_PAGEWALK_ST_LOOKUP_M0;
          end else begin
            next_pagewalk_state = `CA53_PAGEWALK_ST_BIU_NC_REQ;
          end
        end else begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_WALK_WRITE;
          next_pagewalk_ram_req = 1'b1;
        end
        next_pagewalk_ram_walk = 1'b1;
      end

      `CA53_PAGEWALK_ST_IPA_LOOKUP: begin
        if (abandon_pagewalk) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
        end else if (pagewalk_ram_pri_i) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IPA_COMPARE;
          next_pagewalk_ram_req = |next_ipa_size_remaining;
        end else begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IPA_LOOKUP;
          next_pagewalk_ram_req = 1'b1;
        end
        next_pagewalk_ram_ipa = 1'b1;
      end

      `CA53_PAGEWALK_ST_IPA_COMPARE: begin
        if (abandon_pagewalk) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
        // IPA read in previous cycle with ECC error.
        // This has preference over hit in current cycle.
        // With protection off, ipa_cache_ecc_err is hardwired to zero and
        // this condition will get removed
        end else if (ipa_cache_ecc_err) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IPA_WRITE0; 
        // IPA read in current cycle is hit. Its ECC is checked in IPA WAIT state 
        end else if (|ipa_cache_hit_way_i) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IPA_WAIT;
        // No hits, no ECC error of up to 2nd last IPA read. Check ECC of last 
        // IPA read in IPA WAIT state
        end else if (~|ipa_size_remaining) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IPA_WAIT;
        end else begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IPA_COMPARE;
          next_pagewalk_ram_req = |next_ipa_size_remaining;
        end
        next_pagewalk_ram_ipa = 1'b1;
      end

      `CA53_PAGEWALK_ST_IPA_WAIT: begin
        if (abandon_pagewalk) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
        // ECC error check on previous cycle data, where previous cycle
        // could be IPA data hit or very last IPA data read
        end else if (ipa_cache_ecc_err) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IPA_WRITE0;
        end else if (ipa_cache_previous_hit)  begin  // Hit with no ECC error
          next_pagewalk_state = `CA53_PAGEWALK_ST_PROCESS;
        end else begin // No hit, no ECC error
          if (`CA53_MEM_COHERENT(pagewalk_attrs) & pagewalk_dcache_on) begin
            next_pagewalk_state = `CA53_PAGEWALK_ST_LOOKUP_M0;
          end else begin
            next_pagewalk_state = `CA53_PAGEWALK_ST_BIU_NC_REQ;
          end
        end
      end

      `CA53_PAGEWALK_ST_IPA_WRITE: begin
        if (abandon_pagewalk) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
        end else if (pagewalk_ram_pri_i) begin
          if (ipa_cache_ecc_err) begin
            next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
          end else if ((pagewalk_lpae ? ((pagewalk_stage1_level == 3'b010) & ~stage1_start_level3_a64_g64) :
                                (pagewalk_stage1_level == 3'b001)) &
              ~stage1_translation_completed) begin
            // CPU_CACHE_PROTECTION dependent logic start
            if (use_write0_states) begin
              next_pagewalk_state = `CA53_PAGEWALK_ST_WALK_WRITE0;
            end else begin
              next_pagewalk_state = `CA53_PAGEWALK_ST_WALK_WRITE;
              next_pagewalk_ram_req = 1'b1;
              next_pagewalk_ram_walk = 1'b1;
            end
            // CPU_CACHE_PROTECTION dependent logic end
          end else if (another_fetch_required) begin
            if (`CA53_MEM_COHERENT(combined_attrs) & raw_dcache_on) begin
              next_pagewalk_state = `CA53_PAGEWALK_ST_LOOKUP_M0;
            end else begin
              next_pagewalk_state = `CA53_PAGEWALK_ST_BIU_NC_REQ;
            end
          end else if ((~pagewalk_mmuon & ~(pagewalk_ns &
                                            ~pagewalk_exception_level2 &
                                            dpu_default_cacheable_i)) |
                       pagewalk_v2p_ipa) begin
            next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
          end else begin
            // CPU_CACHE_PROTECTION dependent logic start
            if (use_write0_states) begin
              next_pagewalk_state = `CA53_PAGEWALK_ST_TLB_WRITE0;
            end else begin
              next_pagewalk_state = `CA53_PAGEWALK_ST_TLB_WRITE;
              next_pagewalk_ram_req = 1'b1;
              next_pagewalk_ram_tlb = 1'b1;
            end
            // CPU_CACHE_PROTECTION dependent logic end
          end
        end else begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IPA_WRITE;
          next_pagewalk_ram_req = 1'b1;
          next_pagewalk_ram_ipa = 1'b1;
        end
      end

      `CA53_PAGEWALK_ST_TLB_WRITE0: begin
        if (abandon_pagewalk) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
        end else begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_TLB_WRITE;
          next_pagewalk_ram_req = 1'b1;
        end
        next_pagewalk_ram_tlb = 1'b1;
      end

      `CA53_PAGEWALK_ST_WALK_WRITE0: begin
        if (abandon_pagewalk) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
        end else begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_WALK_WRITE;
          next_pagewalk_ram_req = 1'b1;
        end
        next_pagewalk_ram_walk = 1'b1;
      end

      `CA53_PAGEWALK_ST_IPA_WRITE0: begin
        if (abandon_pagewalk) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
        end else begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IPA_WRITE;
          next_pagewalk_ram_req = 1'b1;
        end
        next_pagewalk_ram_ipa = 1'b1;
      end

      `CA53_PAGEWALK_ST_TLB_WRITE: begin
        // Wait in the TLB write state until the RAMs are available to accept the write.
        if (pagewalk_ram_pri_i | abandon_pagewalk) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_IDLE;
        end else begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_TLB_WRITE;
          next_pagewalk_ram_req = 1'b1;
        end
        next_pagewalk_ram_tlb = 1'b1;
      end

      `CA53_PAGEWALK_ST_BIU_NC_REQ: begin
        if (biu_walk_ack_i) begin
          next_pagewalk_state = `CA53_PAGEWALK_ST_PROCESS;
        end
      end

      default: begin
        next_pagewalk_state = `CA53_PAGEWALK_ST_X;
      end
    endcase
  end


  assign pagewalk_state_en = start_pagewalk_i | ~pagewalk_state_idle | pagewalk_invalidated;

  always @(posedge clk_pagewalk or negedge reset_n)
  if (~reset_n) begin
    pagewalk_state <= `CA53_PAGEWALK_ST_IDLE;
  end else if (pagewalk_state_en) begin
    pagewalk_state <= next_pagewalk_state;
  end

  assign pagewalk_state_idle          = pagewalk_state == `CA53_PAGEWALK_ST_IDLE;
  assign pagewalk_state_lookup_m0     = pagewalk_state == `CA53_PAGEWALK_ST_LOOKUP_M0;
  assign pagewalk_state_lookup_m2     = pagewalk_state == `CA53_PAGEWALK_ST_LOOKUP_M2;
  assign pagewalk_state_lookup_m3     = pagewalk_state == `CA53_PAGEWALK_ST_LOOKUP_M3;
  assign pagewalk_state_linefill      = pagewalk_state == `CA53_PAGEWALK_ST_BIU_LF_REQ;
  assign pagewalk_state_linefill_hz   = pagewalk_state == `CA53_PAGEWALK_ST_BIU_LF_HZ;
  assign pagewalk_state_process       = pagewalk_state == `CA53_PAGEWALK_ST_PROCESS;
  assign pagewalk_state_tlb_write     = pagewalk_state == `CA53_PAGEWALK_ST_TLB_WRITE;
  assign pagewalk_state_biu_axi_wait  = pagewalk_state == `CA53_PAGEWALK_ST_BIU_NC_REQ;
  assign pagewalk_state_walk_lookup   = pagewalk_state == `CA53_PAGEWALK_ST_WALK_LOOKUP;
  assign pagewalk_state_walk_compare  = pagewalk_state == `CA53_PAGEWALK_ST_WALK_COMPARE;
  assign pagewalk_state_walk_wait     = pagewalk_state == `CA53_PAGEWALK_ST_WALK_WAIT;
  assign pagewalk_state_walk_write    = pagewalk_state == `CA53_PAGEWALK_ST_WALK_WRITE;
  assign pagewalk_state_ipa_lookup    = pagewalk_state == `CA53_PAGEWALK_ST_IPA_LOOKUP;
  assign pagewalk_state_ipa_compare   = pagewalk_state == `CA53_PAGEWALK_ST_IPA_COMPARE;
  assign pagewalk_state_ipa_write     = pagewalk_state == `CA53_PAGEWALK_ST_IPA_WRITE;
  assign pagewalk_state_tlb_write0    = pagewalk_state == `CA53_PAGEWALK_ST_TLB_WRITE0;
  assign pagewalk_state_walk_write0   = pagewalk_state == `CA53_PAGEWALK_ST_WALK_WRITE0;
  assign pagewalk_state_ipa_write0    = pagewalk_state == `CA53_PAGEWALK_ST_IPA_WRITE0;
  assign pagewalk_state_ipa_wait      = pagewalk_state == `CA53_PAGEWALK_ST_IPA_WAIT;

  assign pagewalk_state_ipa_compare_o = pagewalk_state_ipa_compare;


  // If a control bit in the DPU that might alter the pagewalk result have
  // changed, then abandon the pagewalk to avoid an inconsistent result. The
  // request that started the pagewalk will redo the lookup and then start a
  // new pagewalk later.
  assign abandon_pagewalk = dpu_tlb_abandon_i | pagewalk_abandoned;

  assign next_pagewalk_abandoned = abandon_pagewalk & ~pagewalk_state_idle;

  always @(posedge clk_pagewalk or negedge reset_n)
  if (~reset_n) begin
    pagewalk_abandoned <= 1'b0;
  end else if (pagewalk_state_en) begin
    pagewalk_abandoned <= next_pagewalk_abandoned;
  end

  // If a forwarded CP op is waiting then it must be able to complete even if
  // the AR channel is blocked. Therefore if the pagewalk is waiting for a BIU
  // response, then allow the CP op to complete while the pagewalk continues.
  // The pagewalk must give its result to the request that started it, to ensure
  // that it can make forward progress even if there are continuous invalidates.
  // However the main TLB or uTLB must not be updated as the entry might have
  // been one that should be invalidated.
  assign next_pagewalk_invalidated = (cp_op_waiting_i &
                                      ((pagewalk_state_biu_axi_wait |
                                        pagewalk_state_linefill |
                                        pagewalk_state_linefill_hz) & ~biu_walk_ack_i)) |
                                     (cp_op_waiting_i &
                                      pagewalk_state_lookup_m3 & dcu_ecc_err_m3_i) |
                                     (pagewalk_invalidated & ~pagewalk_state_idle);

  always @(posedge clk_pagewalk or negedge reset_n)
  if (~reset_n) begin
    pagewalk_invalidated <= 1'b0;
  end else if (pagewalk_state_en) begin
    pagewalk_invalidated <= next_pagewalk_invalidated;
  end

  assign pagewalk_invalidated_o = pagewalk_invalidated;

  //------------------------------------------------------------------------------
  // Stage and level control
  //------------------------------------------------------------------------------

  // Secure modes and Hyp mode never do a stage 2 translation i.e.
  // both in A32 and in A64, only EL0/EL1 can do a stage2 translation.
  // If HCR.DC is set but HCR.VM is not set then this is UNPREDICTABLE. We treat it
  // as if HCR.VM was set.
  // V2P_S1_EL0/1 operations give IPA which means in a two stage walk, after last
  // descriptor of stage1 is fetched, last stage2 walk is skipped.
  assign stage2_translation_required_normal = ~pagewalk_ecc_err_cmn &
                                               (pagewalk_ns & ~pagewalk_exception_level2 &
                                                (dpu_ipa_to_pa_en_i |
                                                 dpu_default_cacheable_i));

  assign stage2_translation_required = stage2_translation_required_normal & 
                                       ~(pagewalk_v2p_ipa & stage1_translation_will_complete);

  // Start a stage 1 translation once the walk cache lookup has completed. Note
  // that the first access for this translation may actually be a stage 2 access.
  assign start_stage1_translation = pagewalk_state_walk_wait & ~walk_cache_previous_hit;

  // Start the next stage/level of translation if we have processed the
  // current one, and have written to the IPA cache if needed. It will be
  // before the walk cache or main TLB is written, as those need the stage1
  // registers to be updated with the results beforehand.
  assign start_next_translation = ((pagewalk_state_process & ~pagewalk_abort &
                                    (pagewalk_invalidated |
                                     ~(stage2_translation_complete & ~ipa_cache_previous_hit))) |
                                   (pagewalk_state_ipa_write & pagewalk_ram_pri_i));


  // Start a stage2 translation every time we have an IPA to translate, if enabled.
  assign start_stage2_translation = (stage2_translation_required &
                                     (start_stage1_translation |
                                      (pagewalk_stage1 & start_next_translation)));

  // Choose the level to start the stage1 translation from. VMSA always starts
  // at level 1, but LPAE may start at 1 or 2. The start level is set to 0 if no
  // stage1 translation needs to be performed. If a stage2 translation is
  // needed then the start level is one less than the first level, to allow a
  // stage2 translation to find the physical address of the first stage1 table.
  assign start_level_a32 = (pagewalk_lpae & (ttbcr_sz[2:1] != 2'b00)) ? 
                            (stage2_translation_required ? 3'b001 : 3'b010) :
                            (stage2_translation_required ? 3'b111 : 3'b001) ;

  assign start_level0_a64_g4 = (tcr_a64_sz[5:4] == 2'b00) |                // 0-to-15
                               ( {tcr_a64_sz[5],tcr_a64_sz[3]} == 2'b00) | // 16-to-23
                               (({tcr_a64_sz[5],tcr_a64_sz[3]} == 2'b01) & tcr_a64_sz[2:0]==3'b000); // 24

  assign start_level1_a64_g4 = ((tcr_a64_sz[5:3] == 3'b011) & tcr_a64_sz[2:0] != 3'b000) |           // 25-to-31
                               (({tcr_a64_sz[5],tcr_a64_sz[4]} == 2'b10) & tcr_a64_sz[3:1]==3'b000); // 32-to-33

  assign start_level_a64_g4  = start_level0_a64_g4 ? (stage2_translation_required ? 3'b111 : 3'b000):
                               start_level1_a64_g4 ? (stage2_translation_required ? 3'b000 : 3'b001):
                                                     (stage2_translation_required ? 3'b001 : 3'b010);

  assign start_level1_a64_g64 = (tcr_a64_sz[5:4] == 2'b00) |   // 0-to-15
                                (({tcr_a64_sz[5],tcr_a64_sz[3]} == 2'b00) &
                                 (tcr_a64_sz[2:1] != 2'b11)); // 16-to-21

  assign start_level2_a64_g64 = ((tcr_a64_sz[5:4] == 2'b01) & (tcr_a64_sz[2:1] == 2'b11)) |  // 22-to-23
                                (tcr_a64_sz[5:3] == 3'b011) |                                // 24-to-31
                                ((tcr_a64_sz[5:2] == 4'b1000) & (tcr_a64_sz[1:0] != 2'b11)); // 32-to-34

  assign start_level_a64_g64 = start_level1_a64_g64 ? (stage2_translation_required ? 3'b000 : 3'b001) : // start at L1
                               start_level2_a64_g64 ? (stage2_translation_required ? 3'b001 : 3'b010) : // start at L2
                                                      (stage2_translation_required ? 3'b010 : 3'b011) ; // start at L3

  assign stage1_start_level3_a64_g64 = pagewalk_a64_g64 & ~start_level1_a64_g64 & ~start_level2_a64_g64;

  assign stage1_start_level = ((pagewalk_a32 &
                                (next_stage1_a32_pagewalk_disable |
                                 next_stage1_a32_pagewalk_disable_out_addr)) |
                               (pagewalk_a64 &
                                (next_stage1_a64_pagewalk_disable |
                                 next_stage1_a64_pagewalk_disable_out_addr)) |
                               (~pagewalk_mmuon) | // No pagewalk, idle level
                               (pagewalk_ecc_err_cmn)) ? 3'b111 :
                               walk_cache_previous_hit ? 
                                (pagewalk_lpae ? 3'b011 : 3'b010): // Walk hit, last level after WALK RAM access
                               pagewalk_a64_g64 ? start_level_a64_g64 : // Pagewalk, A64-64K granule
                               pagewalk_a64_g4  ? start_level_a64_g4  : // Pagewalk, A64-4K granule
                                                  start_level_a32;      // Pagewalk, A32

  // Increment the stage1 level every time a stage 1 fetch completes and does
  // not terminate the walk.
  // - For A32, idle level = 3'b111, 1st level is 3'b001, transition from 3'b111 to 3'b001 is forced
  // - For A64, idle level = 3'b111, 1st level is 3'b000, transition is natural
  assign next_pagewalk_stage1_update = ((pagewalk_stage1_level == 3'b111) & pagewalk_a32) ? 3'b001 : 
                                        (pagewalk_stage1_level + 3'b001);

  assign next_pagewalk_stage1_level = (pagewalk_state_idle ? 3'b111 :
                                       pagewalk_state_walk_wait ? stage1_start_level :
                                       ((stage2_translation_complete | ~stage2_translation_required) &
                                        ~stage1_translation_completed & 
                                        ~pagewalk_state_ipa_compare) ? next_pagewalk_stage1_update :
                                       pagewalk_stage1_level);

  // Increment stage2 level each time a fetch completes within a stage2 walk
  // - For A32, idle level is 3'b111, and 1st level is 3'b001, transition from 3'b111 to 3'b001 is forced
  // - For A64, stage2 can not have L0 (neither for 4K granule nor for 64K granule), idle level is 3'b111, 
  //   and transition b/w 3'b111 and 3'b001 is forced
  assign next_pagewalk_stage2_update = (pagewalk_stage2_level == 3'b111) ? 3'b001 : 
                                        (pagewalk_stage2_level + 3'b001);

  // S2level in uTLB data gives S2 transaction completion level. For stage2 fault on very first level
  //  - For A64-64k granule S2Level is L2
  //  - For A32 and A64-4k granule, S2Level is L1
  assign next_pagewalk_stage2_level =
                     (|ipa_cache_hit_way_i ? ipa_compare_level :
                      ((pagewalk_state_idle) |
                       (~stage2_translation_required) |
                       (pagewalk_state_walk_wait & 
                         ((pagewalk_a32 & next_stage1_a32_pagewalk_disable) |
                          (pagewalk_a32 & next_stage1_a32_pagewalk_disable_out_addr) |
                          (pagewalk_a64 & next_stage1_a64_pagewalk_disable) |
                          (pagewalk_a64 & next_stage1_a64_pagewalk_disable_out_addr)))) ? 3'b111 :
                      ((pagewalk_state_walk_wait | start_stage2_translation) &
                       stage2_a64_g64_pagewalk_disable_addr) ? 3'b010 :
                      ((pagewalk_state_walk_wait | start_stage2_translation) & 
                       next_any_stage2_pagewalk_disable) ? 3'b001 :
                      stage2_translation_complete ? 3'b111 :
                      start_stage2_translation ? (stage2_pagewalk_a64_g64 ?
                                                  {1'b0, ~vtcr_sl0_i[1],~vtcr_sl0_i[0]} :   // A64-64k start level
                                                  {1'b0, ~vtcr_sl0_i[0], vtcr_sl0_i[0]} ) : // A32/A64-4k start level
                      start_next_translation ? next_pagewalk_stage2_update :
                      pagewalk_stage2_level);

  // Enable the levels each time a fetch completes, unless this is the last
  // fetch (either due to a complete translation or an abort) in which case
  // the level must not be altered to ensure the uTLB and RAM sizes or fault
  // encoding can be generated correctly.
  assign pagewalk_level_en = (start_pagewalk_i |
                              pagewalk_state_walk_wait |
                              (start_next_translation & another_fetch_required) |
                              pagewalk_state_ipa_compare); // For pagewalk level update on IPA cache hit

  always @(posedge clk_pagewalk)
  if (pagewalk_level_en) begin
    pagewalk_stage1_level <= next_pagewalk_stage1_level;
    pagewalk_stage2_level <= next_pagewalk_stage2_level;
  end

  // Decode the stage and level the current fetch is for.
  // Stage2 pagewalk level for 4K granule can not start at L0, as output address
  // is restricted to 40-bits, which restricts SL0 value to have starting level
  // L1 or L2 only
  assign pagewalk_stage1_level_idle = (pagewalk_stage1_level == 3'b111) & (pagewalk_stage2_level == 3'b111);
  assign pagewalk_stage1_level0     = (pagewalk_stage1_level == 3'b000) & (pagewalk_stage2_level == 3'b111);
  assign pagewalk_stage1_level1     = (pagewalk_stage1_level == 3'b001) & (pagewalk_stage2_level == 3'b111);
  assign pagewalk_stage1_level2     = (pagewalk_stage1_level == 3'b010) & (pagewalk_stage2_level == 3'b111);
  assign pagewalk_stage1_level3     = (pagewalk_stage1_level == 3'b011) & (pagewalk_stage2_level == 3'b111);
  assign pagewalk_stage2_level1     = (pagewalk_stage2_level == 3'b001);
  assign pagewalk_stage2_level2     = (pagewalk_stage2_level == 3'b010);
  assign pagewalk_stage2_level3     = (pagewalk_stage2_level == 3'b011);

  assign pagewalk_stage1 = (pagewalk_stage2_level == 3'b111);
  assign pagewalk_stage2 = (pagewalk_stage2_level != 3'b111);

  assign pagewalk_level = pagewalk_stage2 ? pagewalk_stage2_level : pagewalk_stage1_level;


  // The format of the current fetch may vary when switching between stages.
  assign current_fetch_lpae = pagewalk_lpae | pagewalk_stage2;

  // Detect when the current stage1 translation has reached its final level.
  assign stage1_translation_will_complete = ((pagewalk_stage1_level_idle & ~pagewalk_mmuon) |
                                             (pagewalk_stage1_level_idle & pagewalk_ecc_err_cmn) |
                                             (current_fetch_lpae ? (((pagewalk_stage1_level1 |
                                                                      pagewalk_stage1_level2) & ~pagewalk_data[1]) |
                                                                    pagewalk_stage1_level3) :
                                                                   ((pagewalk_stage1_level1 &
                                                                     (pagewalk_data[1:0] != 2'b01)) |
                                                                    pagewalk_stage1_level2)));

  // Detect when the current stage1 translation has completed (but the end
  // result may not be known yet as a final stage2 translation may be needed).
  assign stage1_translation_complete = (stage1_translation_will_complete | pagewalk_abort);

  // Record when the first stage has completed, so that we don't try to
  // continue it after the next stage2 translation.
  assign next_stage1_translation_completed = (((start_stage1_translation |
                                                start_next_translation) & stage1_translation_complete) |
                                              stage1_translation_completed) & ~pagewalk_state_idle;

  always @(posedge clk_pagewalk)
  if (pagewalk_level_en) begin
    stage1_translation_completed <= next_stage1_translation_completed;
  end

  // Detect when the current stage2 translation will complete as it has reached the final level.
  // Any illegal level+block combinations are handled when generating translation faults
  assign stage2_translation_will_complete = ((pagewalk_stage2_level1 | pagewalk_stage2_level2) &
                                              ~pagewalk_data[1]) |   // Block descriptor on L1 or L2
                                             pagewalk_stage2_level3; // Page descriptor on L3

  // Detect when the current stage2 translation has completed.
  // - For IPA cache hit case, this signal asserts with PROCESS state
  //   IPA_LOOKUP --> IPA_COMPARE --> PROCESS
  // - next_pagewalk_stage2_level mux uses stage2_translation_complete to force idle level. If 
  //   pagewalk_state_ipa_compare is not excluded in signal below, stage2_translation_complete will be 
  //   asserted, next_pagewalk_stage2_level mux will have stage2 idle level, and as pagewalk_level_en is
  //   asserted in IPA compare state, pagewalk_stage2_level will become idle, instead of having correct 
  //   stage2 level. That is why, stage2_translation_complete should not be asserted in IPA compare state
  // - IPA wait state doesn't need to be excluded, as pagewalk_level_en is not asserted in this state
  assign stage2_translation_complete = (~pagewalk_state_ipa_compare &
                                        (stage2_translation_will_complete |
                                         pagewalk_abort));

  // Continue fetching until both stages have completed (if required), or there
  // is an abort. If only an IPA result is required, then the final stage2
  // translation must not be performed (but the stage 2 translations needed for
  // each stage 1 descriptor address must still be performed).
  //
  assign another_fetch_required = ~((stage1_translation_will_complete & ~stage2_translation_required) |
                                    (stage1_translation_completed & stage2_translation_will_complete) |
                                    pagewalk_abort);

  //----------------------------------------------------------------------------
  // A32 Pagewalk output generation
  //----------------------------------------------------------------------------

  // For non-secure non-hyp translations, decide whether to use TTBR0 or TTBR1
  // (or neither). The size of the TTBR0 region is 2^(32-ttbcr_t0sz) from the
  // bottom of the virtual address space, while the TTBR1 region is
  // 2^(32-ttbcr_t1sz) from the top of the virtual address space. If the two
  // regions overlap, then TTBR1 takes priority unless ttbcr_t1sz is zero. If
  // the address falls between the two regions then a translation fault will be
  // generated.
  // For HYP or stage2 translations, there is only one HTTBR/VTTBR, but we still
  // have to determine if the input address falls within its size or not.


  // Expand the size fields into a mask, to determine which region the input
  // address falls within.
  always @*
  case (pagewalk_exception_level2 ? htcr_t0sz_i : ttbcr_t0sz_i)
    3'b000:  ttbcr_t0sz_mask = 7'b0000000;
    3'b001:  ttbcr_t0sz_mask = 7'b1000000;
    3'b010:  ttbcr_t0sz_mask = 7'b1100000;
    3'b011:  ttbcr_t0sz_mask = 7'b1110000;
    3'b100:  ttbcr_t0sz_mask = 7'b1111000;
    3'b101:  ttbcr_t0sz_mask = 7'b1111100;
    3'b110:  ttbcr_t0sz_mask = 7'b1111110;
    3'b111:  ttbcr_t0sz_mask = 7'b1111111;
    default: ttbcr_t0sz_mask = 7'bxxxxxxx;
  endcase

  always @*
  case (ttbcr_t1sz_i)
    3'b000:  ttbcr_t1sz_mask = 7'b1111111;
    3'b001:  ttbcr_t1sz_mask = 7'b0111111;
    3'b010:  ttbcr_t1sz_mask = 7'b0011111;
    3'b011:  ttbcr_t1sz_mask = 7'b0001111;
    3'b100:  ttbcr_t1sz_mask = 7'b0000111;
    3'b101:  ttbcr_t1sz_mask = 7'b0000011;
    3'b110:  ttbcr_t1sz_mask = 7'b0000001;
    3'b111:  ttbcr_t1sz_mask = 7'b0000000;
    default: ttbcr_t1sz_mask = 7'bxxxxxxx;
  endcase

  always @*
  case (vtcr_t0sz_i[3:0])
    4'b1000: vtcr_t0sz_mask = 15'b000000000000000; //-8
    4'b1001: vtcr_t0sz_mask = 15'b100000000000000; //-7
    4'b1010: vtcr_t0sz_mask = 15'b110000000000000; //-6
    4'b1011: vtcr_t0sz_mask = 15'b111000000000000; //-5
    4'b1100: vtcr_t0sz_mask = 15'b111100000000000; //-4
    4'b1101: vtcr_t0sz_mask = 15'b111110000000000; //-3
    4'b1110: vtcr_t0sz_mask = 15'b111111000000000; //-2
    4'b1111: vtcr_t0sz_mask = 15'b111111100000000; //-1
    4'b0000: vtcr_t0sz_mask = 15'b111111110000000; // 0
    4'b0001: vtcr_t0sz_mask = 15'b111111111000000; // 1
    4'b0010: vtcr_t0sz_mask = 15'b111111111100000; // 2
    4'b0011: vtcr_t0sz_mask = 15'b111111111110000; // 3
    4'b0100: vtcr_t0sz_mask = 15'b111111111111000; // 4
    4'b0101: vtcr_t0sz_mask = 15'b111111111111100; // 5
    4'b0110: vtcr_t0sz_mask = 15'b111111111111110; // 6
    4'b0111: vtcr_t0sz_mask = 15'b111111111111111; // 7
    default: vtcr_t0sz_mask = 15'bxxxxxxxxxxxxxxx;
  endcase

  // The virtual address is within the TTBR0 region if the relevant upper
  // address bits are all zero, or the TTBR1 region if the relevant bits
  // are all one. Note that both of these may match if the sizes are set to
  // create overlapping regions.
  assign match_ttbr0 = ~|(pagewalk_va[31:25] & ttbcr_t0sz_mask); // mask bits set should have address bits zero
  assign match_ttbr1 =  &(pagewalk_va[31:25] | ttbcr_t1sz_mask); // mask bits clear should have address bits one

  // The intermediate physical address is within the VTTBR region if the
  // relevant upper address bits are all zero.
  assign match_vttbr = ~|(next_stage1_addr[39:25] & vtcr_t0sz_mask);

  // Select which TTBR to use. These two signals are one hot.
  assign pagewalk_use_ttbr0 = match_ttbr0 & (~match_ttbr1 | (ttbcr_t1sz_i == 3'b000) | pagewalk_exception_level2);
  assign pagewalk_use_ttbr1 = ((ttbcr_t1sz_i == 3'b000) ? ~match_ttbr0 : match_ttbr1) & ~pagewalk_exception_level2;

  // With MMU OFF, there is no pagewalk and and this signal is always negated
  // With MMU ON, translation fault will be generated if the virtual address falls outside
  // both TTBR0 and TTBR1 regions (or outside the HTTBR region if in hypervisor
  // mode), or if the pagewalk disable bit is set for the region that the
  // address does fall within.
  assign next_stage1_a32_pagewalk_disable = (pagewalk_mmuon &
                                            ~((pagewalk_use_ttbr0 & ~(ttbcr_epd_i[0] & ~pagewalk_exception_level2)) |
                                             (pagewalk_use_ttbr1 & ~ttbcr_epd_i[1])));

  assign next_stage2_a32_pagewalk_disable = stage2_translation_required & 
                                             (~match_vttbr |
                                              vtcr_sl0_i[1] |
                                              (stage2_pagewalk_a32 & stage2_a32_t0sz_sl0_mismatch));

  // A64 Output address size fault
  //  Address size fault now includes A32 LPAE case. It can not
  //  be generated for A32 VMSA.
  //  Output address should be within maximum output address range
  //  - Bits[47:40] of output address (from selected base address) should be clear for  A32-LPAE
  assign match_ttbr0_out_addr = ~|(stage1_ttbr_addr[47:40]);

  // This signal detects address size fault on base address
  // registers at start of pagewalk. Equivalent signal to detect address size faults
  // on addresses fetched from the descriptors in A32-LPAE is translation_fault_out_addr
  assign next_stage1_a32_pagewalk_disable_out_addr = pagewalk_lpae & pagewalk_mmuon & ~match_ttbr0_out_addr;

  assign match_vttbr0_out_addr = ~|(vttbr_addr_i[47:40]);

  assign next_stage2_a32_pagewalk_disable_out_addr = stage2_translation_required & ~match_vttbr0_out_addr;

  //----------------------------------------------------------------------------
  // Common pagewalk disable signals
  //----------------------------------------------------------------------------


  // Common stage1 pagewalk disable signal
  assign next_any_stage1_pagewalk_disable = pagewalk_a64 ? (next_stage1_a64_pagewalk_disable |
                                                            next_stage1_a64_pagewalk_disable_out_addr) :
                                                           (next_stage1_a32_pagewalk_disable |
                                                            next_stage1_a32_pagewalk_disable_out_addr);

  // Partial signals of next_any_stage2_pagewalk_disable logic. These are
  // required to drive correct S2level field in uTLB if there is fault on very first level
  assign stage2_a64_g64_pagewalk_disable_addr  = stage2_pagewalk_a64_g64 &
                                                 (next_stage2_a64_pagewalk_disable | 
                                                  next_stage2_a64_pagewalk_disable_out_addr);

  // Common stage2 pagewalk disable signal
  assign next_any_stage2_pagewalk_disable = stage2_pagewalk_a64 ? (next_stage2_a64_pagewalk_disable |
                                                                   next_stage2_a64_pagewalk_disable_out_addr) :
                                                                  (next_stage2_a32_pagewalk_disable |
                                                                   next_stage2_a32_pagewalk_disable_out_addr);

  // Common pagewalk disable signal
  assign next_any_pagewalk_disable = next_any_stage1_pagewalk_disable | next_any_stage2_pagewalk_disable;

  //----------------------------------------------------------------------------
  // A32 Pagewalk start address
  //----------------------------------------------------------------------------

  assign stage1_ttbr_addr = pagewalk_exception_level2 ? httbr_addr_i :
                            pagewalk_use_ttbr0 ? ttbr0_addr_i :
                                                 ttbr1_addr_i;

  // Pick the correct size field for the stage1 translation
  assign ttbcr_sz = (pagewalk_exception_level2 ? htcr_t0sz_i :
                     pagewalk_use_ttbr0 ? ttbcr_t0sz_i:
                                          ttbcr_t1sz_i);

  always @*
  case ({ttbcr_sz, pagewalk_lpae})
    4'b000_0: stage1_start_addr = {8'h00, stage1_ttbr_addr[31:14], pagewalk_va[31:20], 2'b00};
    4'b001_0: stage1_start_addr = {8'h00, stage1_ttbr_addr[31:13], pagewalk_va[30:20], 2'b00};
    4'b010_0: stage1_start_addr = {8'h00, stage1_ttbr_addr[31:12], pagewalk_va[29:20], 2'b00};
    4'b011_0: stage1_start_addr = {8'h00, stage1_ttbr_addr[31:11], pagewalk_va[28:20], 2'b00};
    4'b100_0: stage1_start_addr = {8'h00, stage1_ttbr_addr[31:10], pagewalk_va[27:20], 2'b00};
    4'b101_0: stage1_start_addr = {8'h00, stage1_ttbr_addr[31:9],  pagewalk_va[26:20], 2'b00};
    4'b110_0: stage1_start_addr = {8'h00, stage1_ttbr_addr[31:8],  pagewalk_va[25:20], 2'b00};
    4'b111_0: stage1_start_addr = {8'h00, stage1_ttbr_addr[31:7],  pagewalk_va[24:20], 2'b00};
    4'b000_1: stage1_start_addr = {stage1_ttbr_addr[39:5],  pagewalk_va[31:30], 3'b000};
    4'b001_1: stage1_start_addr = {stage1_ttbr_addr[39:4],  pagewalk_va[30],    3'b000};
    4'b010_1: stage1_start_addr = {stage1_ttbr_addr[39:12], pagewalk_va[29:21], 3'b000};
    4'b011_1: stage1_start_addr = {stage1_ttbr_addr[39:11], pagewalk_va[28:21], 3'b000};
    4'b100_1: stage1_start_addr = {stage1_ttbr_addr[39:10], pagewalk_va[27:21], 3'b000};
    4'b101_1: stage1_start_addr = {stage1_ttbr_addr[39:9],  pagewalk_va[26:21], 3'b000};
    4'b110_1: stage1_start_addr = {stage1_ttbr_addr[39:8],  pagewalk_va[25:21], 3'b000};
    4'b111_1: stage1_start_addr = {stage1_ttbr_addr[39:7],  pagewalk_va[24:21], 3'b000};
    default:  stage1_start_addr = {40{1'bx}};
  endcase

  //----------------------------------------------------------------------------
  // A64 Pagewalk output generation
  //----------------------------------------------------------------------------

  // Calculate mask for A64 VA[47:25]
  always @*
  case (lookup_tcr_a64_muxed_t0sz_i) 
    // L0
    6'b000000, 6'b000001, 6'b000010, 6'b000011,
    6'b000100, 6'b000101, 6'b000110, 6'b000111,
    6'b001000, 6'b001001, 6'b001010, 6'b001011,
    6'b001100, 6'b001101, 6'b001110, 6'b001111,

    6'b010000: tcr_a64_el1_t0sz_mask = {20'h00000,3'b000};
    6'b010001: tcr_a64_el1_t0sz_mask = {20'h80000,3'b000};
    6'b010010: tcr_a64_el1_t0sz_mask = {20'hC0000,3'b000};
    6'b010011: tcr_a64_el1_t0sz_mask = {20'hE0000,3'b000};

    6'b010100: tcr_a64_el1_t0sz_mask = {20'hF0000,3'b000};
    6'b010101: tcr_a64_el1_t0sz_mask = {20'hF8000,3'b000};
    6'b010110: tcr_a64_el1_t0sz_mask = {20'hFC000,3'b000};
    6'b010111: tcr_a64_el1_t0sz_mask = {20'hFE000,3'b000};

    6'b011000: tcr_a64_el1_t0sz_mask = {20'hFF000,3'b000};
    // L1
    6'b011001: tcr_a64_el1_t0sz_mask = {20'hFF800,3'b000};
    6'b011010: tcr_a64_el1_t0sz_mask = {20'hFFC00,3'b000};
    6'b011011: tcr_a64_el1_t0sz_mask = {20'hFFE00,3'b000};

    6'b011100: tcr_a64_el1_t0sz_mask = {20'hFFF00,3'b000};
    6'b011101: tcr_a64_el1_t0sz_mask = {20'hFFF80,3'b000};
    6'b011110: tcr_a64_el1_t0sz_mask = {20'hFFFC0,3'b000};
    6'b011111: tcr_a64_el1_t0sz_mask = {20'hFFFE0,3'b000};

    6'b100000: tcr_a64_el1_t0sz_mask = {20'hFFFF0,3'b000};
    6'b100001: tcr_a64_el1_t0sz_mask = {20'hFFFF8,3'b000};
    // L2
    6'b100010: tcr_a64_el1_t0sz_mask = {20'hFFFFC,3'b000};
    6'b100011: tcr_a64_el1_t0sz_mask = {20'hFFFFE,3'b000};

    6'b100100: tcr_a64_el1_t0sz_mask = {20'hFFFFF,3'b000};
    6'b100101: tcr_a64_el1_t0sz_mask = {20'hFFFFF,3'b100};
    6'b100110: tcr_a64_el1_t0sz_mask = {20'hFFFFF,3'b110};
    6'b100111,

    6'b101000, 6'b101001, 6'b101010, 6'b101011,
    6'b101100, 6'b101101, 6'b101110, 6'b101111,
    6'b110000, 6'b110001, 6'b110010, 6'b110011,
    6'b110100, 6'b110101, 6'b110110, 6'b110111,
    6'b111000, 6'b111001, 6'b111010, 6'b111011,

    6'b111100,
    6'b111101,
    6'b111110,
    6'b111111: tcr_a64_el1_t0sz_mask = {20'hFFFFF,3'b111};
    default:   tcr_a64_el1_t0sz_mask = {23{1'bx}};
  endcase


  always @*
  case (tcr_a64_el1_t1sz_i)
    // L0
    6'b000000, 6'b000001, 6'b000010, 6'b000011,
    6'b000100, 6'b000101, 6'b000110, 6'b000111,
    6'b001000, 6'b001001, 6'b001010, 6'b001011,
    6'b001100, 6'b001101, 6'b001110, 6'b001111,

    6'b010000: tcr_a64_el1_t1sz_mask = {20'hFFFFF,3'b111};
    6'b010001: tcr_a64_el1_t1sz_mask = {20'h7FFFF,3'b111};
    6'b010010: tcr_a64_el1_t1sz_mask = {20'h3FFFF,3'b111};
    6'b010011: tcr_a64_el1_t1sz_mask = {20'h1FFFF,3'b111};

    6'b010100: tcr_a64_el1_t1sz_mask = {20'h0FFFF,3'b111};
    6'b010101: tcr_a64_el1_t1sz_mask = {20'h07FFF,3'b111};
    6'b010110: tcr_a64_el1_t1sz_mask = {20'h03FFF,3'b111};
    6'b010111: tcr_a64_el1_t1sz_mask = {20'h01FFF,3'b111};

    6'b011000: tcr_a64_el1_t1sz_mask = {20'h00FFF,3'b111};
    // L1
    6'b011001: tcr_a64_el1_t1sz_mask = {20'h007FF,3'b111};
    6'b011010: tcr_a64_el1_t1sz_mask = {20'h003FF,3'b111};
    6'b011011: tcr_a64_el1_t1sz_mask = {20'h001FF,3'b111};

    6'b011100: tcr_a64_el1_t1sz_mask = {20'h000FF,3'b111};
    6'b011101: tcr_a64_el1_t1sz_mask = {20'h0007F,3'b111};
    6'b011110: tcr_a64_el1_t1sz_mask = {20'h0003F,3'b111};
    6'b011111: tcr_a64_el1_t1sz_mask = {20'h0001F,3'b111};

    6'b100000: tcr_a64_el1_t1sz_mask = {20'h0000F,3'b111};
    6'b100001: tcr_a64_el1_t1sz_mask = {20'h00007,3'b111};
    // L2
    6'b100010: tcr_a64_el1_t1sz_mask = {20'h00003,3'b111};
    6'b100011: tcr_a64_el1_t1sz_mask = {20'h00001,3'b111};

    6'b100100: tcr_a64_el1_t1sz_mask = {20'h00000,3'b111};
    6'b100101: tcr_a64_el1_t1sz_mask = {20'h00000,3'b011};
    6'b100110: tcr_a64_el1_t1sz_mask = {20'h00000,3'b001};
    6'b100111,

    6'b101000, 6'b101001, 6'b101010, 6'b101011,
    6'b101100, 6'b101101, 6'b101110, 6'b101111,
    6'b110000, 6'b110001, 6'b110010, 6'b110011,
    6'b110100, 6'b110101, 6'b110110, 6'b110111,
    6'b111000, 6'b111001, 6'b111010, 6'b111011,

    6'b111100,
    6'b111101,
    6'b111110,
    6'b111111: tcr_a64_el1_t1sz_mask = {20'h00000,3'b000};
    default:   tcr_a64_el1_t1sz_mask = {23{1'bx}};
  endcase


  // Because of CortexA53 PA size of 40-bits
  //  - Effective minimum value of VTCR_EL2.T0SZ is 24
  //  - Maximum value of SL0 field for 4K granule
  always @*
  case (capped_vtcr_t0sz[5:0])
    6'b000000, 6'b000001, 6'b000010, 6'b000011,
    6'b000100, 6'b000101, 6'b000110, 6'b000111,
    6'b001000, 6'b001001, 6'b001010, 6'b001011,
    6'b001100, 6'b001101, 6'b001110, 6'b001111,
    6'b010000, 6'b010001, 6'b010010, 6'b010011,
    6'b010100, 6'b010101, 6'b010110, 6'b010111,

    6'b011000: vtcr_a64_el2_t0sz_mask = 15'b000000000000000; // t0sz 0-to-24
    6'b011001: vtcr_a64_el2_t0sz_mask = 15'b100000000000000; // t0sz 25
    6'b011010: vtcr_a64_el2_t0sz_mask = 15'b110000000000000; // t0sz 26
    6'b011011: vtcr_a64_el2_t0sz_mask = 15'b111000000000000; // t0sz 27

    6'b011100: vtcr_a64_el2_t0sz_mask = 15'b111100000000000; // t0sz 28
    6'b011101: vtcr_a64_el2_t0sz_mask = 15'b111110000000000; // t0sz 29
    6'b011110: vtcr_a64_el2_t0sz_mask = 15'b111111000000000; // t0sz 30
    6'b011111: vtcr_a64_el2_t0sz_mask = 15'b111111100000000; // t0sz 31

    6'b100000: vtcr_a64_el2_t0sz_mask = 15'b111111110000000; // t0sz 32
    6'b100001: vtcr_a64_el2_t0sz_mask = 15'b111111111000000; // t0sz 33
    6'b100010: vtcr_a64_el2_t0sz_mask = 15'b111111111100000; // t0sz 34
    6'b100011: vtcr_a64_el2_t0sz_mask = 15'b111111111110000; // t0sz 35

    6'b100100: vtcr_a64_el2_t0sz_mask = 15'b111111111111000; // t0sz 36
    6'b100101: vtcr_a64_el2_t0sz_mask = 15'b111111111111100; // t0sz 37
    6'b100110: vtcr_a64_el2_t0sz_mask = 15'b111111111111110; // t0sz 38
    6'b100111,

    6'b101000, 6'b101001, 6'b101010, 6'b101011,
    6'b101100, 6'b101101, 6'b101110, 6'b101111,
    6'b110000, 6'b110001, 6'b110010, 6'b110011,
    6'b110100, 6'b110101, 6'b110110, 6'b110111,
    6'b111000, 6'b111001, 6'b111010, 6'b111011,

    6'b111100,
    6'b111101,
    6'b111110,
    6'b111111: vtcr_a64_el2_t0sz_mask = 15'b111111111111111; // t0sz 39-to-63
    default:   vtcr_a64_el2_t0sz_mask = 15'bxxxxxxxxxxxxxxx;
  endcase


  assign match_a64_ttbr0 = pagewalk_match_a64_ttbr0;

  // Mask bits that are clear, should have address bits set
  assign match_a64_ttbr1 = ~pagewalk_va_sign_err & pagewalk_va[48] &
                           (&(pagewalk_va[47:25] | tcr_a64_el1_t1sz_mask));

  // The intermediate physical address is within the VTTBR region if the
  // relevant upper address bits are all zero.
  assign match_a64_vttbr = ~|(next_stage1_addr[39:25] & vtcr_a64_el2_t0sz_mask);

  // A translation fault will be generated if the virtual address falls outside
  // both TTBR0_EL1 and TTBR1_EL1 regions (or outside the TTBR0_EL2, TTBR0_EL3 regions)
  // or if the pagewalk disable bit is set for the region that the address does fall within.
  assign next_stage1_a64_pagewalk_disable = pagewalk_mmuon &
                                            ~(match_a64_ttbr0 & 
                                              pagewalk_exception_level01 & // outside EL0/EL1 TTBR0 region
                                              ~tcr_a64_el1_epd_i[0]) &     // EL0/EL1 TTBR0 region PW disabled
                                            ~(match_a64_ttbr0 & pagewalk_exception_level2) & // outside EL2 region
                                            ~(match_a64_ttbr0 & pagewalk_exception_level3) & // outside EL3 region
                                            ~(match_a64_ttbr1 & pagewalk_exception_level01 & // outside EL0/EL1 TTBR1 region
                                              ~tcr_a64_el1_epd_i[1]);     // EL0/EL1 TTBR1 region PW disabled

  // A64 Stage2 translation fault is generated if
  //   - IPA is out of T0SZ range
  //   - SL0 has illegal value for A64-4K or A64-64K granule (i.e. SL0=2 or SL0=3)
  //   - SL0 has legal but  inconsistent value with T0SZ
  assign next_stage2_a64_pagewalk_disable = stage2_translation_required & 
                                             (~match_a64_vttbr |
                                              vtcr_sl0_i[1] |
                                              (stage2_pagewalk_a64_g4 & stage2_a64_g4_t0sz_sl0_mismatch) |
                                              (stage2_pagewalk_a64_g64 & stage2_a64_g64_t0sz_sl0_mismatch));

  // calculating PS mask for detecting A64 output address size fault
  assign tcr_a64_elx_ps = pagewalk_exception_level3 ? tcr_a64_el3_ps_i:
                          pagewalk_exception_level2 ? tcr_a64_el2_ps_i:
                                                      tcr_a64_el1_ips_i;

  always @*
  case (tcr_a64_elx_ps)
    3'b000: tcr_a64_el1_ps_mask = 8'hFF; // Mask for 32-bit output address size 4GB
    3'b001: tcr_a64_el1_ps_mask = 8'hF0; // Mask for 36-bit output address size 64GB
    3'b010,
    3'b011,
    3'b100,
    3'b101,
    3'b110,
    3'b111: tcr_a64_el1_ps_mask = 8'h00; // Mask for 40-bit output address size 1TB
    default:tcr_a64_el1_ps_mask = {8{1'bx}};
  endcase

  // Output address should be within max output address range
  // - TTBRx_ELx[47:40] of output address (from selected base address) should be clear
  // - TTBRx_ELx[39:IPS/PS equivalent bits] should be clear
  assign match_a64_output_addr = ~|{stage1_a64_ttbr_addr[47:40],
                                    (stage1_a64_ttbr_addr[39:32] & tcr_a64_el1_ps_mask)};

  // next_a64_pagewalk_disable_out_addr detects output
  // address size fault on base address registers at start of walk.
  // Equivalent signal to detect output address size faults on the
  // addresses fetched from the descriptors is translation_fault_a64_out_addr
  assign next_stage1_a64_pagewalk_disable_out_addr = pagewalk_mmuon & ~match_a64_output_addr;

  // vtcr_ps value is used for
  //  - masking output address of vttbr
  always @*
  case (vtcr_ps_i[2:0])
    3'b000: begin vtcr_a64_el2_ps_mask = 8'hFF; // Mask for 32-bit output address size 4GB
            end
    3'b001: begin vtcr_a64_el2_ps_mask = 8'hF0; // Mask for 36-bit output address size 64GB
            end
    3'b010,
    3'b011,
    3'b100,
    3'b101,
    3'b110,
    3'b111: begin vtcr_a64_el2_ps_mask = 8'h00; // Mask for 40-bit output address size 1TB
            end
    default: begin vtcr_a64_el2_ps_mask = {8{1'bx}};
             end
  endcase

  // Cap IPA not to be more than output address (40-bits) by capping vtcr_t0sz values less 
  // than 24 to 24
  assign capped_vtcr_t0sz = ((vtcr_t0sz_i[5:4] == 2'b00) ||
                             (vtcr_t0sz_i[5:3] == 3'b010)) ? 6'b01_1000 : vtcr_t0sz_i[5:0];

  assign stage2_match_a64_output_addr = ~|{vttbr_addr_i[47:40],(vttbr_addr_i[39:32] & vtcr_a64_el2_ps_mask)};

  assign next_stage2_a64_pagewalk_disable_out_addr = stage2_translation_required & ~stage2_match_a64_output_addr;

  //----------------------------------------------------------------------------
  // A64-4K granule pagewalk start address
  //----------------------------------------------------------------------------

  assign stage1_a64_ttbr_addr = (pagewalk_exception_level3) ? ttbr0_a64_el3_addr_i :
                                (pagewalk_exception_level2) ? ttbr0_a64_el2_addr_i :
                                            match_a64_ttbr0 ? ttbr0_a64_el1_addr_i :
                                                              ttbr1_a64_el1_addr_i ;

  assign tcr_a64_sz = (pagewalk_exception_level3) ? tcr_a64_el3_t0sz_i :
                      (pagewalk_exception_level2) ? tcr_a64_el2_t0sz_i :
                                  match_a64_ttbr0 ? tcr_a64_el1_t0sz_i :
                                                    tcr_a64_el1_t1sz_i ;
  always @*
  case (tcr_a64_sz)
    //L0
    6'b000000, 6'b000001, 6'b000010, 6'b000011,
    6'b000100, 6'b000101, 6'b000110, 6'b000111,
    6'b001000, 6'b001001, 6'b001010, 6'b001011,
    6'b001100, 6'b001101, 6'b001110, 6'b001111,

    6'b010000: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:12], pagewalk_va[47:39], 3'b000};
    6'b010001: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:11], pagewalk_va[46:39], 3'b000};
    6'b010010: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:10], pagewalk_va[45:39], 3'b000};
    6'b010011: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:9],  pagewalk_va[44:39], 3'b000};

    6'b010100: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:8],  pagewalk_va[43:39], 3'b000};
    6'b010101: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:7],  pagewalk_va[42:39], 3'b000};
    6'b010110: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:6],  pagewalk_va[41:39], 3'b000};
    6'b010111: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:5],  pagewalk_va[40:39], 3'b000};

    6'b011000: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:4],  pagewalk_va[39]   , 3'b000};
    //L1
    6'b011001: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:12], pagewalk_va[38:30], 3'b000};
    6'b011010: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:11], pagewalk_va[37:30], 3'b000};
    6'b011011: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:10], pagewalk_va[36:30], 3'b000};

    6'b011100: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:9],  pagewalk_va[35:30], 3'b000};
    6'b011101: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:8],  pagewalk_va[34:30], 3'b000};
    6'b011110: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:7],  pagewalk_va[33:30], 3'b000};
    6'b011111: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:6],  pagewalk_va[32:30], 3'b000};

    6'b100000: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:5],  pagewalk_va[31:30], 3'b000};
    6'b100001: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:4],  pagewalk_va[30]   , 3'b000};
    //L2
    6'b100010: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:12], pagewalk_va[29:21], 3'b000};
    6'b100011: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:11], pagewalk_va[28:21], 3'b000};

    6'b100100: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:10], pagewalk_va[27:21], 3'b000};
    6'b100101: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:9],  pagewalk_va[26:21], 3'b000};
    6'b100110: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:8],  pagewalk_va[25:21], 3'b000};
    6'b100111,

    6'b101000, 6'b101001, 6'b101010, 6'b101011,
    6'b101100, 6'b101101, 6'b101110, 6'b101111,
    6'b110000, 6'b110001, 6'b110010, 6'b110011,
    6'b110100, 6'b110101, 6'b110110, 6'b110111,
    6'b111000, 6'b111001, 6'b111010, 6'b111011,

    6'b111100,
    6'b111101,
    6'b111110,
    6'b111111: stage1_a64_g4_start_addr = {stage1_a64_ttbr_addr[39:7], pagewalk_va[24:21], 3'b000};
    default:   stage1_a64_g4_start_addr = {40{1'bx}};
  endcase

  //----------------------------------------------------------------------------
  // A64-64K granule pagewalk start address
  //----------------------------------------------------------------------------

  always @*
  case (tcr_a64_sz)
    //L1
    6'b000000, 6'b000001, 6'b000010, 6'b000011,
    6'b000100, 6'b000101, 6'b000110, 6'b000111,
    6'b001000, 6'b001001, 6'b001010, 6'b001011,
    6'b001100, 6'b001101, 6'b001110, 6'b001111,

    6'b010000: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:9],  pagewalk_va[47:42], 3'b000};
    6'b010001: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:8],  pagewalk_va[46:42], 3'b000};
    6'b010010: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:7],  pagewalk_va[45:42], 3'b000};
    6'b010011: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:6],  pagewalk_va[44:42], 3'b000};

    6'b010100: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:5],  pagewalk_va[43:42], 3'b000};
    6'b010101: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:4],  pagewalk_va[42:42], 3'b000};
    //L2
    6'b010110: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:16], pagewalk_va[41:29], 3'b000};
    6'b010111: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:15], pagewalk_va[40:29], 3'b000};

    6'b011000: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:14], pagewalk_va[39:29], 3'b000};
    6'b011001: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:13], pagewalk_va[38:29], 3'b000};
    6'b011010: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:12], pagewalk_va[37:29], 3'b000};
    6'b011011: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:11], pagewalk_va[36:29], 3'b000};

    6'b011100: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:10], pagewalk_va[35:29], 3'b000};
    6'b011101: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:9],  pagewalk_va[34:29], 3'b000};
    6'b011110: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:8],  pagewalk_va[33:29], 3'b000};
    6'b011111: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:7],  pagewalk_va[32:29], 3'b000};

    6'b100000: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:6],  pagewalk_va[31:29], 3'b000};
    6'b100001: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:5],  pagewalk_va[30:29], 3'b000};
    6'b100010: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:4],  pagewalk_va[29:29], 3'b000};
    //L3
    6'b100011: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:16], pagewalk_va[28:16], 3'b000};

    6'b100100: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:15], pagewalk_va[27:16], 3'b000};
    6'b100101: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:14], pagewalk_va[26:16], 3'b000};
    6'b100110: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:13], pagewalk_va[25:16], 3'b000};
    6'b100111,

    6'b101000, 6'b101001, 6'b101010, 6'b101011,
    6'b101100, 6'b101101, 6'b101110, 6'b101111,
    6'b110000, 6'b110001, 6'b110010, 6'b110011,
    6'b110100, 6'b110101, 6'b110110, 6'b110111,
    6'b111000, 6'b111001, 6'b111010, 6'b111011,

    6'b111100,
    6'b111101,
    6'b111110,
    6'b111111: stage1_a64_g64_start_addr = {stage1_a64_ttbr_addr[39:12], pagewalk_va[24:16], 3'b000};
    default:   stage1_a64_g64_start_addr = {40{1'bx}};
  endcase

  assign stage1_a64_start_addr = pagewalk_a64_g64 ? stage1_a64_g64_start_addr : stage1_a64_g4_start_addr;

  //----------------------------------------------------------------------------
  // A32 stage2 start address calculation
  //----------------------------------------------------------------------------

  // Calculate the start address for a stage2 pagewalk, by combining the VTTBR
  // with the upper bits of the input address.
  // Note that some combinations of t0sz and sl0 are UNPREDICTABLE, and so we
  // saturate the size value to ensure that these map onto the nearest valid
  // address.
  always @*
  case ({vtcr_t0sz_i[3:0], vtcr_sl0_i[0]})
    // SL0=0 i.e. S2L2
    5'b1000_0,                                                                                    // -8
    5'b1001_0,                                                                                    // -7
    5'b1010_0,                                                                                    // -6
    5'b1011_0,                                                                                    // -5
    5'b1100_0,                                                                                    // -4
    5'b1101_0: begin stage2_start_addr = {vttbr_addr_i[39:16], next_stage1_addr[33:21], 3'b000};  // -3
                     stage2_a32_t0sz_sl0_mismatch = 1'b1;
               end
    5'b1110_0: begin stage2_start_addr = {vttbr_addr_i[39:16], next_stage1_addr[33:21], 3'b000};  // -2
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b1111_0: begin stage2_start_addr = {vttbr_addr_i[39:15], next_stage1_addr[32:21], 3'b000};  // -1
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b0000_0: begin stage2_start_addr = {vttbr_addr_i[39:14], next_stage1_addr[31:21], 3'b000};  //  0
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b0001_0: begin stage2_start_addr = {vttbr_addr_i[39:13], next_stage1_addr[30:21], 3'b000};  //  1
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b0010_0: begin stage2_start_addr = {vttbr_addr_i[39:12], next_stage1_addr[29:21], 3'b000};  //  2
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b0011_0: begin stage2_start_addr = {vttbr_addr_i[39:11], next_stage1_addr[28:21], 3'b000};  //  3
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b0100_0: begin stage2_start_addr = {vttbr_addr_i[39:10], next_stage1_addr[27:21], 3'b000};  //  4
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b0101_0: begin stage2_start_addr = {vttbr_addr_i[39:9],  next_stage1_addr[26:21], 3'b000};  //  5
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b0110_0: begin stage2_start_addr = {vttbr_addr_i[39:8],  next_stage1_addr[25:21], 3'b000};  //  6
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b0111_0: begin stage2_start_addr = {vttbr_addr_i[39:7],  next_stage1_addr[24:21], 3'b000};  //  7
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    // SL0=1 i.e. S2L1
    5'b1000_1: begin stage2_start_addr = {vttbr_addr_i[39:13], next_stage1_addr[39:30], 3'b000};  // -8
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b1001_1: begin stage2_start_addr = {vttbr_addr_i[39:12], next_stage1_addr[38:30], 3'b000};  // -7
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b1010_1: begin stage2_start_addr = {vttbr_addr_i[39:11], next_stage1_addr[37:30], 3'b000};  // -6
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b1011_1: begin stage2_start_addr = {vttbr_addr_i[39:10], next_stage1_addr[36:30], 3'b000};  // -5
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b1100_1: begin stage2_start_addr = {vttbr_addr_i[39:9],  next_stage1_addr[35:30], 3'b000};  // -4
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b1101_1: begin stage2_start_addr = {vttbr_addr_i[39:8],  next_stage1_addr[34:30], 3'b000};  // -3
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b1110_1: begin stage2_start_addr = {vttbr_addr_i[39:7],  next_stage1_addr[33:30], 3'b000};  // -2
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b1111_1: begin stage2_start_addr = {vttbr_addr_i[39:6],  next_stage1_addr[32:30], 3'b000};  // -1
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b0000_1: begin stage2_start_addr = {vttbr_addr_i[39:5],  next_stage1_addr[31:30], 3'b000};  //  0
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b0001_1: begin stage2_start_addr = {vttbr_addr_i[39:4],  next_stage1_addr[30],    3'b000};  //  1
                     stage2_a32_t0sz_sl0_mismatch = 1'b0;
               end
    5'b0010_1,                                                                                    //  2
    5'b0011_1,                                                                                    //  3
    5'b0100_1,                                                                                    //  4
    5'b0101_1,                                                                                    //  5
    5'b0110_1,                                                                                    //  6
    5'b0111_1: begin stage2_start_addr = {vttbr_addr_i[39:4],  next_stage1_addr[30],    3'b000};  //  7
                     stage2_a32_t0sz_sl0_mismatch = 1'b1;
               end
    default: begin   stage2_start_addr = {40{1'bx}};
                     stage2_a32_t0sz_sl0_mismatch = 1'bx;
               end
  endcase

  //----------------------------------------------------------------------------
  // A64-4K granule stage2 start address calculation
  //----------------------------------------------------------------------------

  // - SL0=2 (i.e. level0) and SL=3 (i.e. reserved) generate translation fault as 
  //   these are not allowed due to output address restricted to 40-bits

  always @*
  case ({capped_vtcr_t0sz[5:0], vtcr_sl0_i[0]})
    // SL0=0 i.e. stage2 level2
    //    0-29 are inconsistent sizes for SL0=0 and cause fault
    //   40-63 are undefined sizes for SL0=0 and treated as 39
    7'b000000_0, 7'b000001_0, 7'b000010_0, 7'b000011_0,
    7'b000100_0, 7'b000101_0, 7'b000110_0, 7'b000111_0,
    7'b001000_0, 7'b001001_0, 7'b001010_0, 7'b001011_0,
    7'b001100_0, 7'b001101_0, 7'b001110_0, 7'b001111_0,
    7'b010000_0, 7'b010001_0, 7'b010010_0, 7'b010011_0,
    7'b010100_0, 7'b010101_0, 7'b010110_0, 7'b010111_0,
    7'b011000_0, 7'b011001_0, 7'b011010_0, 7'b011011_0,
    7'b011100_0,
    7'b011101_0: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:16], next_stage1_addr[33:21], 3'b000}; // 0-to-29 used as 30
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b1;
                 end

    7'b011110_0: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:16], next_stage1_addr[33:21], 3'b000}; // 30
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b011111_0: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:15], next_stage1_addr[32:21], 3'b000}; // 31
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100000_0: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:14], next_stage1_addr[31:21], 3'b000}; // 32
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100001_0: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:13], next_stage1_addr[30:21], 3'b000}; // 33
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100010_0: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:12], next_stage1_addr[29:21], 3'b000}; // 34
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100011_0: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:11], next_stage1_addr[28:21], 3'b000}; // 35
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100100_0: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:10], next_stage1_addr[27:21], 3'b000}; // 36
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100101_0: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:9], next_stage1_addr[26:21], 3'b000}; // 37
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100110_0: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:8], next_stage1_addr[25:21], 3'b000}; // 38
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100111_0: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:7], next_stage1_addr[24:21], 3'b000}; // 39
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b101000_0, 7'b101001_0, 7'b101010_0, 7'b101011_0,
    7'b101100_0, 7'b101101_0, 7'b101110_0, 7'b101111_0,
    7'b110000_0, 7'b110001_0, 7'b110010_0, 7'b110011_0,
    7'b110100_0, 7'b110101_0, 7'b110110_0, 7'b110111_0,
    7'b111000_0, 7'b111001_0, 7'b111010_0, 7'b111011_0,
    7'b111100_0, 7'b111101_0, 7'b111110_0,
    7'b111111_0: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:7], next_stage1_addr[24:21], 3'b000}; // 40-to-63 used as 39
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    // SL0=1 i.e. stage2 level1
    //    0-20 are undefined sizes for SL0=1 and used as 24
    //   21-23 are undefined sizes (as output address is restricted to 40-bits) and used as 24
    //   34-63 are inconsistent sizes for SL0=1 and cause fault
    7'b000000_1, 7'b000001_1, 7'b000010_1, 7'b000011_1,
    7'b000100_1, 7'b000101_1, 7'b000110_1, 7'b000111_1,
    7'b001000_1, 7'b001001_1, 7'b001010_1, 7'b001011_1,
    7'b001100_1, 7'b001101_1, 7'b001110_1, 7'b001111_1,
    7'b010000_1, 7'b010001_1, 7'b010010_1, 7'b010011_1,
    7'b010100_1, // 0-t0-20 don't care
    7'b010101_1,
    7'b010110_1,
    7'b010111_1,
    7'b011000_1: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:13], next_stage1_addr[39:30], 3'b000}; // 21-to-23 used as 24
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b011001_1: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:12], next_stage1_addr[38:30], 3'b000}; // 25
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b011010_1: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:11], next_stage1_addr[37:30], 3'b000}; // 26
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b011011_1: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:10], next_stage1_addr[36:30], 3'b000}; // 27
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b011100_1: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:9], next_stage1_addr[35:30], 3'b000}; // 28
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b011101_1: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:8], next_stage1_addr[34:30], 3'b000}; // 29
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b011110_1: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:7], next_stage1_addr[33:30], 3'b000}; // 30
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b011111_1: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:6], next_stage1_addr[32:30], 3'b000}; // 31
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100000_1: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:5], next_stage1_addr[31:30], 3'b000}; // 32
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100001_1: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:4], next_stage1_addr[30], 3'b000};    // 33
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100010_1,
    7'b100011_1,
    7'b100100_1, 7'b100101_1, 7'b100110_1, 7'b100111_1,
    7'b101000_1, 7'b101001_1, 7'b101010_1, 7'b101011_1,
    7'b101100_1, 7'b101101_1, 7'b101110_1, 7'b101111_1,
    7'b110000_1, 7'b110001_1, 7'b110010_1, 7'b110011_1,
    7'b110100_1, 7'b110101_1, 7'b110110_1, 7'b110111_1,
    7'b111000_1, 7'b111001_1, 7'b111010_1, 7'b111011_1,
    7'b111100_1, 7'b111101_1, 7'b111110_1,
    7'b111111_1: begin stage2_a64_g4_start_addr = {vttbr_addr_i[39:4], next_stage1_addr[30], 3'b000}; // 34-to-63 used as 33
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'b1;
                 end
    default:     begin stage2_a64_g4_start_addr = {40{1'bx}};
                       stage2_a64_g4_t0sz_sl0_mismatch = 1'bx;
                 end
  endcase

  //----------------------------------------------------------------------------
  // A64-4K granule stage2 start address calculation
  //----------------------------------------------------------------------------

  // - SL0=2 (i.e. L1) and SL=3 (i.e. reserved) generate translation fault as these are not allowed
  always @*
  case ({capped_vtcr_t0sz[5:0], vtcr_sl0_i[0]})
    // SL0=0 i.e. S2L3
    //    0-30 are inconsistent sizes for SL0=0 and cause fault
    //   40-63 are undefined sizes for SL0=0 and treated as 39
    7'b000000_0, 7'b000001_0, 7'b000010_0, 7'b000011_0,
    7'b000100_0, 7'b000101_0, 7'b000110_0, 7'b000111_0,
    7'b001000_0, 7'b001001_0, 7'b001010_0, 7'b001011_0,
    7'b001100_0, 7'b001101_0, 7'b001110_0, 7'b001111_0,
    7'b010000_0, 7'b010001_0, 7'b010010_0, 7'b010011_0,
    7'b010100_0, 7'b010101_0, 7'b010110_0, 7'b010111_0,
    7'b011000_0, 7'b011001_0, 7'b011010_0, 7'b011011_0,
    7'b011100_0,
    7'b011101_0,
    7'b011110_0: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:20], next_stage1_addr[32:16], 3'b000}; // 0-to-30 used as 31
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b1;
                 end

    7'b011111_0: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:20], next_stage1_addr[32:16], 3'b000}; // 31
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100000_0: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:19], next_stage1_addr[31:16], 3'b000}; // 32
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100001_0: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:18], next_stage1_addr[30:16], 3'b000}; // 33
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100010_0: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:17], next_stage1_addr[29:16], 3'b000}; // 34
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100011_0: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:16], next_stage1_addr[28:16], 3'b000}; // 35
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100100_0: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:15], next_stage1_addr[27:16], 3'b000}; // 36
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100101_0: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:14], next_stage1_addr[26:16], 3'b000}; // 37
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100110_0: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:13], next_stage1_addr[25:16], 3'b000}; // 38
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100111_0: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:12], next_stage1_addr[24:16], 3'b000}; // 39
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b101000_0, 7'b101001_0, 7'b101010_0, 7'b101011_0,
    7'b101100_0, 7'b101101_0, 7'b101110_0, 7'b101111_0,
    7'b110000_0, 7'b110001_0, 7'b110010_0, 7'b110011_0,
    7'b110100_0, 7'b110101_0, 7'b110110_0, 7'b110111_0,
    7'b111000_0, 7'b111001_0, 7'b111010_0, 7'b111011_0,
    7'b111100_0, 7'b111101_0, 7'b111110_0,
    7'b111111_0: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:12], next_stage1_addr[24:16], 3'b000}; // 40-to-63 used as 39
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    // SL0=1 i.e. S2L2
    //    0-17 are undefined sizes for SL0=1 and treated as 18
    //   18-23 are undefined sizes (as output address is restricted to 40-bits) and treated as 18
    //   35-63 are inconsistent sizes for SL0=1 and cause fault
    7'b000000_1, 7'b000001_1, 7'b000010_1, 7'b000011_1,
    7'b000100_1, 7'b000101_1, 7'b000110_1, 7'b000111_1,
    7'b001000_1, 7'b001001_1, 7'b001010_1, 7'b001011_1,
    7'b001100_1, 7'b001101_1, 7'b001110_1, 7'b001111_1,
    7'b010000_1,
    7'b010001_1, // 0-to-17 don't care
    7'b010010_1,
    7'b010011_1,
    7'b010100_1,
    7'b010101_1,
    7'b010110_1,
    7'b010111_1,
    7'b011000_1: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:14], next_stage1_addr[39:29], 3'b000}; // 18-to-23 used as 24
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b011001_1: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:13], next_stage1_addr[38:29], 3'b000}; // 25
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b011010_1: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:12], next_stage1_addr[37:29], 3'b000}; // 26
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b011011_1: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:11], next_stage1_addr[36:29], 3'b000}; // 27
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b011100_1: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:10], next_stage1_addr[35:29], 3'b000}; // 28
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b011101_1: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:9],  next_stage1_addr[34:29], 3'b000}; // 29
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b011110_1: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:8],  next_stage1_addr[33:29], 3'b000}; // 30
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b011111_1: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:7],  next_stage1_addr[32:29], 3'b000}; // 31
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100000_1: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:6],  next_stage1_addr[31:29], 3'b000}; // 32
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100001_1: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:5],  next_stage1_addr[30:29], 3'b000}; // 33
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100010_1: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:4],  next_stage1_addr[29], 3'b000};    // 34
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b0;
                 end
    7'b100011_1,
    7'b100100_1, 7'b100101_1, 7'b100110_1, 7'b100111_1,
    7'b101000_1, 7'b101001_1, 7'b101010_1, 7'b101011_1,
    7'b101100_1, 7'b101101_1, 7'b101110_1, 7'b101111_1,
    7'b110000_1, 7'b110001_1, 7'b110010_1, 7'b110011_1,
    7'b110100_1, 7'b110101_1, 7'b110110_1, 7'b110111_1,
    7'b111000_1, 7'b111001_1, 7'b111010_1, 7'b111011_1,
    7'b111100_1, 7'b111101_1, 7'b111110_1,
    7'b111111_1: begin stage2_a64_g64_start_addr = {vttbr_addr_i[39:4],  next_stage1_addr[29], 3'b000}; // 35-to-63 used as 34
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'b1;
                 end
    default:     begin stage2_a64_g64_start_addr = {40{1'bx}};
                       stage2_a64_g64_t0sz_sl0_mismatch = 1'bx;
                 end
  endcase


  assign stage2_a64_start_addr = vtcr_tg0_i ? stage2_a64_g64_start_addr : stage2_a64_g4_start_addr;

  //----------------------------------------------------------------------------
  // Walk cache start address calculation 
  //----------------------------------------------------------------------------

  // S1-A64-64K gran, S2 not required
  // S1-A64-64K gran, S2-A64-64K gran
  //    Bits[39:16] i.e. top 24-bits of descriptor address are taken from walk cache PA top 24 bits
  //    Bits[15:3]  i.e. next 13-bits of descriptor address are taken from VA[28:16]
  //    Bits[2:0]   are always zero
  // S1-A64-64K gran, S2-A64-4K gran
  //    Bits[39:12] i.e. top 28-bits of descriptor address are taken from walk cache PA top 28-bits
  //    Bits[11:3]  i.e. next 9-bits of descriptor address are taken from VA[24:16]
  //    Bits[2:0]   are always zero
  // S1-A64-4K gran, S2-Any
  // S1-LPAE         S2-Any
  //    Bits[39:12] i.e. top 28-bits of descriptor address are taken from walk cache PA top 28-bits
  //    Bits[11:3]  i.e. next 9-bits of descriptor address are taken from VA[20:12]
  //    Bits[2:0]   are always zero
  // S1-VMSA         S2-Any
  //    Bits[39:32] are zero, but we take these from walk cache PA top 8-bits
  //    Bits[31:10] i.e top 22 bits of descriptor address are taken from  walk cache PA next  22-bits
  //    Bits[9:2]   i.e. next 8-bits of descriptor address are taken from VA[19:12]
  //    Bits[1:0]   are always zero

  assign walk_cache_start_addr = 
           (pagewalk_a64_g64 & 
            ((~stage2_translation_required_normal) |
             (stage2_translation_required_normal & stage2_pagewalk_a64_g64))) ? {walk_cache_data_i[42:19], pagewalk_va[28:16], 3'b000} :
           (pagewalk_a64_g64 & stage2_pagewalk_a64_g4)                        ? {walk_cache_data_i[42:15], pagewalk_va[24:16], 3'b000} :
           pagewalk_lpae                                                      ? {walk_cache_data_i[42:15], pagewalk_va[20:12], 3'b000} :
                                                                                {walk_cache_data_i[42:13], pagewalk_va[19:12], 2'b00};

  //----------------------------------------------------------------------------
  // Next pagewalk address mux 
  //----------------------------------------------------------------------------

  // The address of the next level of pagewalk is either a start address, or
  // comes from the result of the current level (which could be stage 1 or 2).
  assign next_pagewalk_addr = pagewalk_state_walk_compare ? walk_cache_start_addr :
                              start_stage2_translation ? (stage2_pagewalk_a64 ? stage2_a64_start_addr : stage2_start_addr) :
                              start_stage1_translation ? (pagewalk_a64 ? stage1_a64_start_addr : stage1_start_addr) :
                              pagewalk_output_addr;

  //----------------------------------------------------------------------------
  // Pagewalk Attributes
  //----------------------------------------------------------------------------

  // Dcache ON mux 
  assign dpu_dcache_on = pagewalk_exception_level2 ? dpu_dcache_on_el2_i :
                         ((pagewalk_exception_level0 & pagewalk_ns) |
                          (pagewalk_exception_level0 & ~pagewalk_ns & pagewalk_aarch64_at_el[3]) |
                          (pagewalk_exception_level1)) ? dpu_dcache_on_el1_i :
                         dpu_dcache_on_el3_i;

  // Select the correct S, NOS, RGN and IRGN bits to use for the pagewalk.
  assign ttbcr_attrs01       =  pagewalk_use_ttbr0 ? ttbcr_attrs0_i : ttbcr_attrs1_i;
  assign tcr_a64_el1_attrs01 =  match_a64_ttbr0    ? tcr_a64_el1_attrs0_i : tcr_a64_el1_attrs1_i;

  assign next_fetch_is_stage2 = stage2_translation_required & ~(pagewalk_stage2 & stage2_translation_will_complete);

  assign raw_attrs = (next_fetch_is_stage2) ? vtcr_attrs_i :                            // A32/A64 stage2
                     (pagewalk_exception_level2) ? htcr_attrs_i :                       // A32/A64 EL2
                     (pagewalk_a64 & pagewalk_exception_level3) ? tcr_a64_el3_attrs_i : // A64 EL3
                     (pagewalk_a64) ? tcr_a64_el1_attrs01 :                             // A64 EL1/EL0
                      ttbcr_attrs01 ;                                                   // A32 EL1/EL0-NS, EL3/EL0-S


  assign raw_dcache_on = next_fetch_is_stage2 ? dpu_s2_dcache_on_i : dpu_dcache_on;


  // Convert the S, NOS, RGN, IRGN bits from the TTBCR/TTBRs into the standard
  // internal attributes format.
  assign ttbcr_coherent = raw_attrs[0] & raw_attrs[2];

  assign ttbcr_attrs[7:6] = (ttbcr_coherent ? 2'b10 :          // Coherent
                             (raw_attrs[2]  ? 2'b00 : 2'b01)); // Non-coherent

  assign ttbcr_inner_alloc_hint = raw_attrs[1] ? 2'b10 : 2'b11;
  assign ttbcr_outer_alloc_hint = raw_attrs[3] ? 2'b10 : 2'b11;

  assign ttbcr_attrs[5:4] = (ttbcr_coherent   ? ttbcr_inner_alloc_hint :
                             ~|raw_attrs[3:2] ? 2'b11 :                   // Outer NC
                             raw_attrs[2]     ? {1'b1, raw_attrs[1]} :    // Outer WB
                             (&raw_attrs[1:0] ? 2'b01 : raw_attrs[1:0])); // Outer WT

  assign ttbcr_attrs[3:2] = (|raw_attrs[3:2] ? ttbcr_outer_alloc_hint : // Outer WB or WT
                             (raw_attrs[0] ? 2'b01 : raw_attrs[1:0]));  // Outer NC
  assign ttbcr_attrs[1:0] = {raw_attrs[5], (raw_attrs[5] & raw_attrs[4])};


  assign next_pagewalk_dcache_on = pagewalk_state_walk_compare ? dpu_dcache_on : raw_dcache_on;


  assign walk_cache_attr_data = walk_cache_data_i[7:0];

  assign next_pagewalk_attrs = pagewalk_state_walk_compare ?
                                 ((`CA53_MEM_NORMAL(walk_cache_attr_data) & ~dpu_dcache_on) ?
                                   `CA53_PAGE_INNER_NC_OUTER_NC_SHARE_OS : walk_cache_attr_data) :
                                 ((`CA53_MEM_NORMAL(combined_attrs) & ~raw_dcache_on) ?
                                   `CA53_PAGE_INNER_NC_OUTER_NC_SHARE_OS : combined_attrs);

  assign next_pagewalk_attrs_to_walk_cache = combined_attrs[7:0];


  // Calculate the size of the next fetch, based on whether it will be LPAE or not.
  assign next_pagewalk_size = (pagewalk_lpae |
                               start_stage2_translation |
                               (pagewalk_stage2 & ~stage2_translation_complete));

  // For LPAE, the security state of the pagewalk may be modified for
  // subsequent levels by the NSTable bits, whereas in VMSA it is always
  // the same for all levels.
  // Note that if a stage2 translation is in progress, then the pagewalk
  // must be in non-secure state and therefore stage1_ns and pagewalk_ns
  // are both set, and hence it doesn't matter which we pick.
  assign next_pagewalk_ns_dsc = pagewalk_lpae ? next_stage1_ns : pagewalk_ns;

  // The address must not be enabled after the last fetch, because
  // pagewalk_data needs to be valid in the RAM write state, and this
  // depends on the address not changing.
  assign pagewalk_addr_en = (pagewalk_state_walk_compare |
                             start_stage1_translation |
                             (start_next_translation & another_fetch_required));

  always @(posedge clk_pagewalk)
  if (pagewalk_addr_en) begin
    pagewalk_dcache_on                   <= next_pagewalk_dcache_on;
    pagewalk_addr                        <= next_pagewalk_addr[39:2];
    pagewalk_ns_dsc                      <= next_pagewalk_ns_dsc;
    pagewalk_attrs                       <= next_pagewalk_attrs;
    pagewalk_attrs_to_walk_cache         <= next_pagewalk_attrs_to_walk_cache;
    pagewalk_size                        <= next_pagewalk_size;
    stage1_a32_pagewalk_disable          <= next_stage1_a32_pagewalk_disable;
    stage1_a32_pagewalk_disable_out_addr <= next_stage1_a32_pagewalk_disable_out_addr;
    stage1_a64_pagewalk_disable          <= next_stage1_a64_pagewalk_disable;
    stage1_a64_pagewalk_disable_out_addr <= next_stage1_a64_pagewalk_disable_out_addr;
    stage2_a32_pagewalk_disable          <= next_stage2_a32_pagewalk_disable;
    stage2_a32_pagewalk_disable_out_addr <= next_stage2_a32_pagewalk_disable_out_addr;
    stage2_a64_pagewalk_disable          <= next_stage2_a64_pagewalk_disable;
    stage2_a64_pagewalk_disable_out_addr <= next_stage2_a64_pagewalk_disable_out_addr;
  end

  assign a32_pagewalk_disable          = (stage1_a32_pagewalk_disable & pagewalk_a32) |
                                         (stage2_a32_pagewalk_disable & stage2_pagewalk_a32);

  assign a32_pagewalk_disable_out_addr = (stage1_a32_pagewalk_disable_out_addr & pagewalk_a32) |
                                         (stage2_a32_pagewalk_disable_out_addr & stage2_pagewalk_a32);

  assign a64_pagewalk_disable          = (stage1_a64_pagewalk_disable & pagewalk_a64) |
                                         (stage2_a64_pagewalk_disable & stage2_pagewalk_a64);

  assign a64_pagewalk_disable_out_addr = (stage1_a64_pagewalk_disable_out_addr & pagewalk_a64) |
                                         (stage2_a64_pagewalk_disable_out_addr & stage2_pagewalk_a64);

  // Make an nc request to the BIU for non-cacheable pagewalks, or for
  // cacheable pagewalks when the cache must not be allocated to. The request
  // must be held until the BIU ack is received.
  assign tlb_walk_nc_req_o = pagewalk_state_biu_axi_wait;

  // Make a linefill request for cacheable pagewalks that can allocate into
  // the cache. If the BIU signals a linefill hazard for the address being
  // requested by the TLB, then we must stop making a linefill request to
  // ensure that the BIU does not start a second linefill to the same address.
  assign tlb_walk_lf_req = pagewalk_state_linefill & ~(pagewalk_invalidated &
                                                       pagewalk_req_dropped);
  assign tlb_walk_lf_req_o = tlb_walk_lf_req;

  // Clock enable for LF request for BIU. Asserted if LF request is asserted OR
  // next state is line fill request state.
  assign tlb_walk_lf_active_o = (pagewalk_state_lookup_m3 | tlb_walk_lf_req);

  // All cacheable pagewalks must start by requesting a dcache lookup.
  // LPAE fetches want both words, VMSA only requires one.
  assign tlb_cache_walk_lookup_req_m0_o = ({2{pagewalk_state_lookup_m0}} &
                                           ({2{pagewalk_size}} |
                                            {pagewalk_addr[2], ~pagewalk_addr[2]}));

  // Send the previously calculated pagewalk address to the BIU or DCU.
  assign tlb_walk_addr_o = {pagewalk_addr[39:2], 2'b00};
  assign tlb_cache_walk_addr_o = pagewalk_addr[39:3];

  assign tlb_walk_ns_dsc_o = pagewalk_ns_dsc;
  assign tlb_cache_walk_ns_dsc_o = pagewalk_ns_dsc;

  assign tlb_walk_attrs_o = pagewalk_attrs[7:0];

  assign tlb_walk_size_o = pagewalk_size;

  //----------------------------------------------------------------------------
  // Capture of data from BIU or DCU or IPA cache
  //----------------------------------------------------------------------------

  // Expand the IPA cache hit data into the same format is if it had been
  // loaded from memory.
  assign ipa_cache_data_expanded = {9'h000,                      // ipa_cache_data_expanded[63:55] Reserved0
                                    ipa_cache_data_i[8],         // ipa_cache_data_expanded[54]    XN
                                    1'b0,                        // ipa_cache_data_expanded[53]    Reserved0
                                    (((ipa_compare_size == 2'b01) & ~ipa_cache_data_i[37]) | // size=64K and A32/A64_g4
                                     ((ipa_compare_size == 2'b10) &  ipa_cache_data_i[37])), // size=2M  and A64_g64
                                    12'h000,                     // ipa_cache_data_expanded[51:40] Reserved0
                                    ipa_cache_data_i[36:9],      // ipa_cache_data_expanded[39:12] PA
                                    1'b0,                        // ipa_cache_data_expanded[11]    Reserved0
                                    1'b1,                        // ipa_cache_data_expanded[10]    AF
                                    ipa_cache_data_i[5:4],       // ipa_cache_data_expanded[9:8]   SH
                                    ipa_cache_data_i[7:6],       // ipa_cache_data_expanded[7:6]   HAP
                                    ipa_cache_data_i[3:0],       // ipa_cache_data_expanded[5:2]   Memory attributes
                                    ((ipa_compare_size == 2'b00) |                         // 4K is always page
                                     (ipa_compare_size == 2'b01) |                         // 64K is always page
                                     ((ipa_compare_size == 2'b10) & ipa_cache_data_i[37])),// 2M in A64_g64 is always page
                                    1'b1}; // ipa_cache_data_expanded[1:0]   descriptor type


  assign next_pagewalk_raw_data = pagewalk_state_lookup_m2   ? dcu_cache_walk_data_m2_i :
                                  pagewalk_state_ipa_compare ? ipa_cache_data_expanded : 
                                                               biu_walk_data_i;

  // The caches can never return an error response.
  // Bit[2] of BIU response gives Synchronous parity error
  assign next_pagewalk_rresp = biu_walk_ack_i ? biu_walk_resp_i : {1'b0,`CA53_RESP_OKAY};

  // Store the way that the DCU indicates should be preferred for a victim way
  // if a linefill is requested.
  assign next_tlb_walk_way = {|dcu_cache_walk_victim_way_m2_i[3:2],
                              dcu_cache_walk_victim_way_m2_i[3] |
                              dcu_cache_walk_victim_way_m2_i[1]};

  // DCU ECC error signal is asserted a clock cycle after the hit signal. So hit signal is 
  // registered and checked in the SM after checking ECC signal
  assign next_dcu_cache_walk_previous_hit = pagewalk_state_lookup_m2 ? dcu_cache_walk_hit_m2_i : 
                                                                       dcu_cache_walk_previous_hit;

  // If the relevant SCTLR.EE bit is set then we must interpret the data as big
  // endian format. The IPA cache data was swizzled before putting into the
  // cache and therefore should not be swizzled again.
  assign endian_swizzle = ((pagewalk_exception_level2 | pagewalk_stage2) ? dpu_endian_el2_i :
                           ((pagewalk_exception_level0 & pagewalk_ns) |
                            (pagewalk_exception_level0 & ~pagewalk_ns & pagewalk_aarch64_at_el[3]) |
                            (pagewalk_exception_level1)) ? dpu_endian_el1_i :
                           dpu_endian_el3_i) & ~pagewalk_state_ipa_compare;

  always @*
  case ({endian_swizzle, current_fetch_lpae, pagewalk_addr[2]})
    3'b000:  next_pagewalk_swizzle = 2'b00;
    3'b001:  next_pagewalk_swizzle = 2'b01;
    3'b010,
    3'b011:  next_pagewalk_swizzle = 2'b00;
    3'b100:  next_pagewalk_swizzle = 2'b10;
    3'b101,
    3'b110,
    3'b111:  next_pagewalk_swizzle = 2'b11;
    default: next_pagewalk_swizzle = 2'bxx;
  endcase

  // Capture data from DCU cache lookups, IPA cache lookups, or BIU requests
  // (either non-cacheable or linefills).
  // - For IPA cache hit case, hit IPA data is registered is IPA compare state. ECC
  //   is checked in IPA wait state. Enable should not be asserted in IPA wait state
  assign pagewalk_data_en = pagewalk_state_lookup_m2 | pagewalk_state_ipa_compare | biu_walk_ack_i;

  always @(posedge clk_pagewalk)
  if (pagewalk_data_en) begin
    pagewalk_raw_data           <= next_pagewalk_raw_data;
    pagewalk_rresp              <= next_pagewalk_rresp;
    tlb_walk_way                <= next_tlb_walk_way;
    pagewalk_swizzle            <= next_pagewalk_swizzle;
    dcu_cache_walk_previous_hit <= next_dcu_cache_walk_previous_hit;
  end

  assign tlb_walk_way_o = tlb_walk_way;

  // Perform endian and alignment swizzling. LPAE format descriptor are 64bit
  // aligned, and are swizzled on a 64bit basis. VMSA descriptors are swizzled
  // on a word basis, and are only word aligned, so we also need to select
  // either the upper or lower word.
  always @*
  case (pagewalk_swizzle)
    2'b00: pagewalk_data = pagewalk_raw_data;
    2'b01: pagewalk_data = {pagewalk_raw_data[63:32], pagewalk_raw_data[63:32]};
    2'b10: pagewalk_data = {pagewalk_raw_data[7:0],
                            pagewalk_raw_data[15:8],
                            pagewalk_raw_data[23:16],
                            pagewalk_raw_data[31:24],
                            pagewalk_raw_data[7:0],
                            pagewalk_raw_data[15:8],
                            pagewalk_raw_data[23:16],
                            pagewalk_raw_data[31:24]};
    2'b11: pagewalk_data = {pagewalk_raw_data[7:0],
                            pagewalk_raw_data[15:8],
                            pagewalk_raw_data[23:16],
                            pagewalk_raw_data[31:24],
                            pagewalk_raw_data[39:32],
                            pagewalk_raw_data[47:40],
                            pagewalk_raw_data[55:48],
                            pagewalk_raw_data[63:56]};
    default: pagewalk_data = {64{1'bx}};
  endcase

  //----------------------------------------------------------------------------
  // Pagetable entry decoding
  //----------------------------------------------------------------------------

  // Decode various fields from the pagewalk data, depending on the current
  // format, stage and level. These signals assume we are in the process state
  // and that the data is valid.
  assign external_abort = (pagewalk_level != 3'b111) & (pagewalk_rresp != {1'b0,`CA53_RESP_OKAY});

  assign external_dec_abort = (pagewalk_level != 3'b111) & (pagewalk_rresp == {1'b0,`CA53_RESP_DECERR});

  assign external_ecc_abort = (pagewalk_level != 3'b111) & pagewalk_rresp[2];
  


  // Translation fault detection
  assign lpae_translation_fault = (~pagewalk_data[0]) |                             // Invalid descriptor at any level
                                  ((pagewalk_level == 3'b000) & ~pagewalk_data[1])| // A64-4K S1L0 block. S2L0 not possible
                                  ((pagewalk_level == 3'b001) & ~pagewalk_data[1] &
                                    pagewalk_stage1 & pagewalk_a64_g64) |           // A64-64K S1L1 block, S2L1 not possible
                                  ((pagewalk_level == 3'b011) & ~pagewalk_data[1]); // Reserved at L3

  assign translation_fault = (pagewalk_level != 3'b111) &
                             (current_fetch_lpae ? lpae_translation_fault : (~|pagewalk_data[1:0]));

  assign translation_fault_out_addr = current_fetch_lpae & (pagewalk_level != 3'b111) &
                                      pagewalk_a32 & (|pagewalk_data[47:40]);

  // translation_fault_a64_out_addr detects output address size faults on the
  // addresses fetched from the descriptors.
  assign translation_fault_a64_out_addr = (pagewalk_level != 3'b111) & 
                                          (pagewalk_stage2 ? stage2_pagewalk_a64 : pagewalk_a64) &
                                          |{pagewalk_data[47:40],
                                            (pagewalk_data[39:32] & (pagewalk_stage2 ? vtcr_a64_el2_ps_mask :
                                                                                       tcr_a64_el1_ps_mask))};

  // For MMU off case, VA is same as output address. In addition to checking
  // VA[63:48], additional bits VA[47:40] are also checked. But unlike the
  // va_sign_err which is used to generate Translation fault on input address,
  // va_mmuoff_sign_err is used to generate Address size fault on output address
  // This is done both for A32 and A64
  assign mmuoff_fault_out_addr = pagewalk_a64 & ~pagewalk_mmuon & pagewalk_va_mmuoff_sign_err;

  // Access flag enable is implicitly high for all LPAE pagewalks.
  // Note that access_flag_fault is calculated assuming there is not a
  // translation fault.
  assign access_flag_enable_vmsa = ((pagewalk_exception_level0 & pagewalk_ns) |
                                    (pagewalk_exception_level0 & ~pagewalk_ns & pagewalk_aarch64_at_el[3]) |
                                    (pagewalk_exception_level1)) ? dpu_access_flag_enable_el1_i :
                                    dpu_access_flag_enable_el3_i;

  assign access_flag_fault = ((pagewalk_level != 3'b111) &
                              ((access_flag_enable_vmsa | current_fetch_lpae) &
                               (current_fetch_lpae ?
                                ((pagewalk_level == 3'b011) ? ~pagewalk_data[10] :
                                                             (~pagewalk_data[1] & ~pagewalk_data[10])) :
                                (pagewalk_stage1_level2 ? ~pagewalk_data[4] :
                                                          (pagewalk_data[1] & ~pagewalk_data[10])))));

  // If the IPA of a stage1 descriptor maps to a region of memory that does not
  // have read permissions then we must not fetch it, and cause an abort.
  assign stage2_permission_fault = (pagewalk_stage2 & ~stage1_translation_completed &
                                    (pagewalk_stage2_level3 |
                                     ~pagewalk_data[1]) &
                                    ~pagewalk_data[6]);

  // If the IPA of a stage1 descriptor maps to a region of memory that is
  // device or strongly ordered, then the hypervisor can configure this to
  // cause an abort.
  assign stage2_dev_so_fault = (pagewalk_stage2 & ~stage1_translation_completed &
                                dpu_pr_tablewalk_i &
                                (pagewalk_stage2_level3 |
                                 ~pagewalk_data[1]) &
                                ~|pagewalk_data[5:4]);

  // The stage1 attributes must be registered once they have been decoded, so
  // that they are retained if a stage2 translation is performed. Additionally,
  // some bits are updated after each level of the stage1 walk, such as the
  // APTable bits.
  // The default values are either the most permissive option for fields that
  // are updated after each level, or the default values required when SCTLR.M
  // is low.


  // For LPAE, on every level except the final level, the current access
  // permission bits are reduced by the APTable bits from the table entry.
  // For the final level, the AP bits from the block entry are combined with
  // the existing bits (which are the most permissive permissions allowed
  // after applying the APTable bits from previous levels).
  assign next_stage1_ap_lpae = ((((pagewalk_stage1_level1 | pagewalk_stage1_level2)
                                   & ~pagewalk_data[1]) |
                                  pagewalk_stage1_level3) ?
                                  {pagewalk_data[7] | stage1_ap[2], pagewalk_data[6] & stage1_ap[1], 1'b1} :
                                (pagewalk_stage1_level0 |
                                 pagewalk_stage1_level1 |
                                 pagewalk_stage1_level2) ?
                                {stage1_ap[2] | pagewalk_data[62], stage1_ap[1] & ~pagewalk_data[61], 1'b1} :
                                stage1_ap);

  // For VMSA, the access permissions are only updated on the final level of
  // the stage1 walk.
  assign next_stage1_ap_vmsa = ((pagewalk_stage1_level1 & pagewalk_data[1]) ? {pagewalk_data[15], pagewalk_data[11:10]} :
                                pagewalk_stage1_level2 ? {pagewalk_data[9], pagewalk_data[5:4]} :
                                stage1_ap);

  assign next_stage1_ap_nowalk = (start_stage1_translation ? 3'b011 : // Full access
                                  (current_fetch_lpae ? next_stage1_ap_lpae : next_stage1_ap_vmsa));

  assign next_stage1_ap = pagewalk_state_walk_compare ? {walk_cache_data_i[9:8], 1'b1} : next_stage1_ap_nowalk;

  // Encode HYP entries into the unused encoding of the access permissions
  // EL3 is qualified with A64 as EL3 in A32 doesn't force this signal to 3'b100
  assign pagewalk_ap = (pagewalk_exception_level2 | (pagewalk_exception_level3 & pagewalk_a64)) ? 3'b100 : // For A32-Hyp and A64-EL2/EL3
                       (next_stage1_ap_nowalk == 3'b100) ? 3'b000 : // Reserved value forced to valid no access value
                       next_stage1_ap_nowalk;

  // RAM writes can use the registered versions which are earlier.
  // EL3 is qualified with A64 as EL3 in A32 doesn't force this signal to 3'b100
  assign pagewalk_ap_ram = (pagewalk_exception_level2 | (pagewalk_exception_level3 & pagewalk_a64)) ? 3'b100 : // For A32-Hyp and A64-EL2/EL3
                           (stage1_ap == 3'b100) ? 3'b000 : // Reserved value forced to valid no access value
                           stage1_ap;

  // If in HYP, then HAP contains the access permissions from the first and only
  // stage, otherwise they are the second stage permissions (or full access if
  // no second stage was performed).
  // Force to full access if the pagewalk aborts, to prevent x propagation.
  assign pagewalk_hap = (pagewalk_exception_level2 & ~pagewalk_abort) ? {next_stage1_ap_nowalk[2],1'b0} :
                        (pagewalk_exception_level3 & pagewalk_a64 & ~pagewalk_abort) ? {next_stage1_ap_nowalk[2],1'b1} :
                        (pagewalk_stage2 & ~pagewalk_abort) ? pagewalk_data[7:6] :
                        2'b11;

  assign pagewalk_hap_ram = pagewalk_exception_level2 ? {stage1_ap[2],1'b0} :
                            (pagewalk_exception_level3 & pagewalk_a64) ? {stage1_ap[2],1'b1} :
                            pagewalk_stage2 ? pagewalk_data[7:6] :
                            2'b11;

  //--------------------------------------------------------------------------
  // For LPAE, the XN bit is a combination of the XN bit from the final level
  // and all XNTable bits from previous levels.
  assign next_stage1_xn_common_lpae = ((((pagewalk_stage1_level1 | pagewalk_stage1_level2)
                                          & ~pagewalk_data[1]) |    // L1/L2 block desc (L0 can not have block) OR
                                          pagewalk_stage1_level3) ? // L3 descriptor
                                          pagewalk_data[54] :       // assign descriptor XN bit
                                       (pagewalk_stage1_level0 |
                                        pagewalk_stage1_level1 |
                                        pagewalk_stage1_level2) ?   // L0/L1/L2 table descriptor
                                        pagewalk_data[60] :         // assign XNTable bit
                                        1'b0);                      // else 0

  assign next_stage1_xn_usr_lpae     = next_stage1_xn_common_lpae | stage1_xn_usr;
  assign next_stage1_xn_nusr_lpae    = next_stage1_xn_common_lpae | stage1_xn_nusr;

  // For VMSA, the XN bit is only updated on the final level of the stage1 walk.
  assign next_stage1_xn_usr_vmsa = ((pagewalk_stage1_level1 & pagewalk_data[1]) ?
                                    pagewalk_data[4] : // S1L1 section/super section desc
                                    pagewalk_stage1_level2 ? (pagewalk_data[1] ?
                                    pagewalk_data[0] : pagewalk_data[15]) : // S1L2 small Page desc: large page desc
                                    stage1_xn_usr);

  assign next_stage1_xn_nusr_vmsa = ((pagewalk_stage1_level1 & pagewalk_data[1]) ?
                                     pagewalk_data[4] : // S1L1 section/super section desc
                                     pagewalk_stage1_level2 ? (pagewalk_data[1] ?
                                     pagewalk_data[0] : pagewalk_data[15]) : // S1L2 small Page desc: large page desc
                                     stage1_xn_nusr);


  assign pagewalk_wxn = pagewalk_exception_level2 ? dpu_sctlr_wxn_el2_i :
                        ((pagewalk_exception_level0 & pagewalk_ns) |
                         (pagewalk_exception_level0 & ~pagewalk_ns & pagewalk_aarch64_at_el[3]) |
                         (pagewalk_exception_level1)) ? dpu_sctlr_wxn_el1_i :
                        dpu_sctlr_wxn_el3_i;

  // XN for user
  //  Access permission's pre-condition to force XN for user when SCTLR.WXN is set
  //  Special cases
  //   - For current exception EL0 and in VMSA, AFE=0, execute permissions are only 
  //     removed for EL0 R/W (AP[2:0]=3'b011) and not removed for EL0 RO (AP[2:0]=3'b010.
  //   - EL0 execute permissions are not removed when EL1-A64 and AP[2:1]=2'b00
  assign force_stage1_xn_usr = stage1_translation_complete &
                               pagewalk_mmuon & pagewalk_wxn &
                               ((~next_stage1_ap_nowalk[2] &
                                 ((~pagewalk_lpae & ~access_flag_enable_vmsa) ? (&next_stage1_ap_nowalk[1:0]) :
                                                                                (|next_stage1_ap_nowalk[1:0]))) &
                                ~(pagewalk_aarch64_at_el[1] & (next_stage1_ap_nowalk[2:1] == 2'b00)) );

  assign next_stage1_xn_usr_nowalk = (start_stage1_translation ? 1'b0 :
                                      ((current_fetch_lpae ? next_stage1_xn_usr_lpae : next_stage1_xn_usr_vmsa) |
                                       force_stage1_xn_usr));

  assign next_stage1_xn_usr = pagewalk_state_walk_compare ? walk_cache_data_i[10] : next_stage1_xn_usr_nowalk;

  // XN for non user
  assign force_stage1_xn_nusr = stage1_translation_complete &
                                pagewalk_mmuon & pagewalk_wxn &
                                (~next_stage1_ap_nowalk[2] & |next_stage1_ap_nowalk[1:0]);

  assign next_stage1_xn_nusr_nowalk = (start_stage1_translation ? 1'b0 :
                                       ((current_fetch_lpae ? next_stage1_xn_nusr_lpae : next_stage1_xn_nusr_vmsa) |
                                       force_stage1_xn_nusr));

  assign next_stage1_xn_nusr = pagewalk_state_walk_compare ? walk_cache_data_i[10] : next_stage1_xn_nusr_nowalk;

  //---------------------------------------------------------------------------------------------------------
  // PXN Calculation
  //---------------------------------------------------------------------------------------------------------

  // For LPAE, the PXN bit is a combination of the PXN bit from the final level
  // and all PXNTable bits from previous levels.
  assign next_stage1_pxn_lpae = (((((pagewalk_stage1_level1 | pagewalk_stage1_level2) &
                                     ~pagewalk_data[1]) |    // L1/L2 block desc (L0 can not have block) OR
                                   pagewalk_stage1_level3) ? // L3 descriptor
                                   pagewalk_data[53] :       // assign descriptor PXN bit
                                  (pagewalk_stage1_level0 |
                                   pagewalk_stage1_level1 |
                                   pagewalk_stage1_level2) ? // L0/L1/L2 table descriptor
                                   pagewalk_data[59] :       // assign PXNTable bit
                                  1'b0) | stage1_pxn);       // Other wise 0. also OR registered PXN

  // For VMSA, the PXN bit is only updated on the first level of the stage1 walk.
  assign next_stage1_pxn_vmsa = (pagewalk_stage1_level1 ? (pagewalk_data[1] ? pagewalk_data[0] : pagewalk_data[2]) :
                                 stage1_pxn);

  assign pagewalk_uwxn = pagewalk_exception_level2 ? 1'b0 :
                        ((pagewalk_exception_level0 & pagewalk_ns) |
                         (pagewalk_exception_level0 & ~pagewalk_ns & pagewalk_aarch64_at_el[3]) |
                         (pagewalk_exception_level1)) ? dpu_sctlr_uwxn_el1_i :
                        dpu_sctlr_uwxn_el3_i;

  // For A32
  //   If SCTLR.UWXN is set then any user writeable page implicitly has PXN set.
  // For A64
  //   If SCTLR.WXN is set, then any writeable memory at EL1 has PXN set
  //   If memory is writeable at EL0 (irrespective of WXN/UWNX) has PXN set
  assign force_stage1_pxn = stage1_translation_complete & pagewalk_mmuon &
                            (pagewalk_a32 ? (pagewalk_uwxn & (next_stage1_ap_nowalk == 3'b011)) : // A32- UWXN & writeable at EL0
                                            ((pagewalk_wxn  & ~|next_stage1_ap_nowalk[2:1]) | // A64- WXN & writeable at only-EL1
                                             (next_stage1_ap_nowalk[2:1] == 2'b01))); // A64- writeable at EL1/EL0


  assign next_stage1_pxn_nowalk = (start_stage1_translation ? 1'b0 :
                                   ((current_fetch_lpae ? next_stage1_pxn_lpae : next_stage1_pxn_vmsa) |
                                    force_stage1_pxn));

  assign next_stage1_pxn = pagewalk_state_walk_compare ? walk_cache_data_i[11] : next_stage1_pxn_nowalk;

  //-----------------------------------------------------------
  // Permissions in Executable format
  //-----------------------------------------------------------

  assign next_xs1usr_a32 = ~next_stage1_xn_usr_nowalk & next_stage1_ap_nowalk[1];
  assign next_xs1usr_a64 = ~next_stage1_xn_usr_nowalk;

  // Choose XS1USR-A32 if
  //   EL3-A32
  //   EL3-A64 & EL1-A32
  // else XS1USR-A64
  assign next_xs1usr = pagewalk_mmuon ?
                        (((~pagewalk_aarch64_at_el[3]) |
                         (pagewalk_aarch64_at_el[3] & ~pagewalk_aarch64_at_el[1])) ?
                            next_xs1usr_a32 :
                            next_xs1usr_a64) : 1'b1;


  assign next_xs1nonusr_el1ns_el3s_a32 = ~next_stage1_xn_nusr_nowalk & ~next_stage1_pxn_nowalk &
                                         (pagewalk_lpae | (|next_stage1_ap_nowalk[1:0]));

  assign next_xs1nonusr_el1ns_el1s_a64 = ~next_stage1_pxn_nowalk & (next_stage1_ap_nowalk[2:1] != 2'b01);

  // For MMU OFF
  //   If current pagewalk MMU if OFF, default values of AP and PXN don't
  //   combine to give executable permissions and are forced to be executable
  // For MMU ON
  //   XS1NonUsr are same for current-EL2-A32/current-EL2-A64/current-EL3-A64
  //   else choose XS1NonUsr to be A32 if
  //    - EL3-A32
  //    - EL3-A64 & EL1-A32
  //   else XS1NonUsr-A64
  assign next_xs1nonusr = pagewalk_mmuon ?
                            ( ((pagewalk_exception_level2) |
                               (pagewalk_exception_level3 & pagewalk_aarch64_at_el[3])) ? ~next_stage1_xn_nusr_nowalk :
                              ((~pagewalk_aarch64_at_el[3]) |
                               (pagewalk_aarch64_at_el[3] & ~pagewalk_aarch64_at_el[1])) ?
                                  next_xs1nonusr_el1ns_el3s_a32 :
                                  next_xs1nonusr_el1ns_el1s_a64 ) : 1'b1;

  assign next_xs2_a32 = pagewalk_data[6] & ~pagewalk_data[54];  //HAP[0] & Not(S2-XN)
  assign next_xs2_a64 = ~pagewalk_data[54]; // Not(S2-XN)
  assign next_xs2     = pagewalk_stage2 ? (pagewalk_aarch64_at_el[2] ? next_xs2_a64 : next_xs2_a32) : 1'b1;

  always @(posedge clk_pagewalk)
  if (stage1_en) begin
    xs1nonusr <= next_xs1nonusr;
    xs1usr    <= next_xs1usr;
  end

  //---------------------------------------------------------------------------------------------------------
  // NS Calculation
  //---------------------------------------------------------------------------------------------------------

  // The NS bit is set when the walk is started from non-secure state, or if
  // any level of the walk has its NS or NSTable bit set. Once the NS bit is
  // set, it cannot be cleared for the rest of the walk. This ensures that no
  // page table entries fetched from non-secure memory can give access to
  // secure memory. Note that the behaviour of fetching subsequent levels
  // differs between formats - for LPAE further levels are fetched from
  // non-secure memory if this NS bit is set, whereas for VMSA the second level
  // is always fetched from the same security state as the first level was.
  assign next_stage1_ns_lpae = ((((pagewalk_stage1_level1 | pagewalk_stage1_level2)
                                  & ~pagewalk_data[1]) |   // L1/L2 block desc (L0 can not have block) OR
                                 pagewalk_stage1_level3) ? // L3 page desc
                                 pagewalk_data[5] :        // Assign NS bit
                                (pagewalk_stage1_level0 |
                                 pagewalk_stage1_level1 |
                                 pagewalk_stage1_level2) ? // L0/L1/L2 table descriptor
                                 pagewalk_data[63] :       // Assign NSTable bit
                                 1'b0);

  assign next_stage1_ns_vmsa = pagewalk_stage1_level1 & (pagewalk_data[1] ? pagewalk_data[19] : pagewalk_data[3]);

  assign next_stage1_ns_nowalk = (start_stage1_translation ? pagewalk_ns :
                                  ((current_fetch_lpae ? next_stage1_ns_lpae : next_stage1_ns_vmsa) |
                                   stage1_ns));

  assign next_stage1_ns = pagewalk_state_walk_compare ? walk_cache_data_i[12] : next_stage1_ns_nowalk;

  //---------------------------------------------------------------------------------------------------------
  // NG Calculation
  //---------------------------------------------------------------------------------------------------------

  // The not-global bit is only fetched from the final level of the walk.
  // However if the walk is from secure state, but the entry is fetched from
  // non-secure memory then the nG bit must be set to avoid the non-secure
  // data overlaying existing secure non-global entries in the TLB.
  // If stage 1 is not enabled then the nG bit should be 0 (this only has any
  // effect if the HCR.DC bit is also set), and in HYP mode it should also be
  // zero to ensure that the ASID is ignored on lookups.

  // For aarch64, L0 can not have a block desc and NG is not defined for pagetable desc.
  // However if L0 desc had NSTable bit set, and DPU was in secure mode, then non-global
  // signal should be asserted, but it is taken care of using pagewalk_ns_desc and
  // pagewalk_ns signals
  assign next_stage1_ng = ((pagewalk_state_walk_compare |
                            start_stage1_translation |
                            pagewalk_exception_level2) ? 1'b0 :
                           (((pagewalk_stage1_level1 & ~current_fetch_lpae) ? // VMSA case
                             pagewalk_data[17] :
                             (pagewalk_stage1_level1 |   // L1 block desc (L0 can not have block) OR
                              pagewalk_stage1_level2 |   // L2 block desc
                              pagewalk_stage1_level3) ?  // L3 page desc
                              pagewalk_data[11] : stage1_ng) |
                            (pagewalk_ns_dsc & ~pagewalk_ns)));

  // The domain only exists in VMSA format, and then only for pages and
  // sections. It is implicitly zero for super sections.
  assign next_stage1_domain_nowalk_only = (start_stage1_translation ? 3'b000 :
                                           ((pagewalk_stage1_level1 & ~current_fetch_lpae) &
                                            (~pagewalk_data[1] | ~pagewalk_data[18])) ? pagewalk_data[8:6] :
                                           stage1_domain_only[2:0]);

  assign next_stage1_domain_nowalk_only_ls = (start_stage1_translation ? 1'b0:
                                             ((pagewalk_stage1_level1 & ~current_fetch_lpae) &
                                              (~pagewalk_data[1] | ~pagewalk_data[18])) ? pagewalk_data[5] :
                                             stage1_domain_only_ls);

  assign next_stage1_domain_nowalk_muxed   = (start_stage1_translation ? 1'b0:
                                             ((pagewalk_stage1_level1 & ~current_fetch_lpae) &
                                              (~pagewalk_data[1] | ~pagewalk_data[18])) ? pagewalk_data[5] :
                                             stage1_domain_muxed);

  // - Domain field is used for
  //     - storing domain information for VMSA
  //     - storing contiguous bit for A64-64K case with contiguous bit set
  // - For A32 and A64-4K, S1 pagesize 2M gives an equivalent S1-level2.
  //   For A64-64k, a 64K page with contiguous bit set also gives equivalent S1 size 2M(16kx32) but
  //   S1-level3. This is reported correctly on a pagewalk. But TLB RAM saves the page size (2M)
  //   and not S1 level. This means on a later lookup hit, lookup can not distinguish between 2M
  //   from S1-L2 and 2M from S1-L3. To avoid this 2M size when got from A64-64K granule L3, is
  //   saved in domain[0], as domain is unused in LPAE-A32/A64
  assign next_stage1_domain_only = pagewalk_state_walk_compare ? walk_cache_data_i[46:44] : 
                                    next_stage1_domain_nowalk_only[2:0];

  assign next_stage1_domain_only_ls = pagewalk_state_walk_compare ? walk_cache_data_i[43] : 
                                       next_stage1_domain_nowalk_only_ls ;

  assign next_stage1_domain_muxed = pagewalk_state_walk_compare ? walk_cache_data_i[43] :
                                     (~pagewalk_lpae) ? next_stage1_domain_nowalk_muxed :
                                     pagewalk_a64_g64;

  // TEX, C, B and S bits only exist in VMSA
  assign tex_c_b_s = {(pagewalk_stage1_level2 & pagewalk_data[1]) ? pagewalk_data[8:6] :
                                                                    pagewalk_data[14:12],
                      pagewalk_data[3],
                      pagewalk_data[2],
                      pagewalk_stage1_level2 ? pagewalk_data[10] : pagewalk_data[16]};

  // The attrindx and SH fields only exist in LPAE
  assign attrindx_sh = {pagewalk_data[4:2], pagewalk_data[9:8]};

  // Select the stage1 attributes for combining with stage2. These will be
  // from the TTBR/TTBCR if the stage1 walk is in progress, or from the final
  // stage1 attributes if the stage1 walk is finished.
  assign stage1_memattrs = ( (stage1_translation_will_complete | stage1_translation_completed) &
                             (~start_stage1_translation) &
                             ((pagewalk_stage2 & stage2_translation_will_complete) |
                              ~stage2_translation_required) ) ? stage1_attrs : ttbcr_attrs;

  // Extract the stage2 memory type and shareability, or set to the default
  // which results in no modification of stage1 attributes if no stage2
  // translation is being performed.
  assign stage2_memattrs = (pagewalk_stage2 & stage2_translation_complete) ? pagewalk_data[5:2] : 4'b1111;
  assign stage2_sh = (pagewalk_stage2 & stage2_translation_complete) ? pagewalk_data[9:8] : 2'b00;


  // Perform the remapping of the attributes based on the memory attribute
  // indirection registers, and combine with the stage2 attributes.
  ca53tlb_remap u_remap (/*ARMAUTO*/
    // Inputs
    .pagewalk_lpae_i             (pagewalk_lpae),
    .pagewalk_ns_i               (pagewalk_ns),
    .pagewalk_exception_level0_i (pagewalk_exception_level0),
    .pagewalk_exception_level1_i (pagewalk_exception_level1),
    .pagewalk_aarch64_at_el3_i   (pagewalk_aarch64_at_el[3]),
    .dpu_tex_remap_enable_el1_i  (dpu_tex_remap_enable_el1_i),
    .dpu_tex_remap_enable_el3_i  (dpu_tex_remap_enable_el3_i),
    .mair0_i                     (mair0_i[31:0]),
    .mair1_i                     (mair1_i[31:0]),
    .tex_c_b_s_i                 (tex_c_b_s[5:0]),
    .attrindx_sh_i               (attrindx_sh[4:0]),
    .stage1_memattrs_i           (stage1_memattrs[7:0]),
    .stage2_memattrs_i           (stage2_memattrs[3:0]),
    .stage2_sh_i                 (stage2_sh[1:0]),
    // Outputs
    .remapped_attrs_o            (remapped_attrs[7:0]),
    .combined_attrs_o            (combined_attrs[7:0])
  );  // u_remap


  assign dside_default_cacheable = dpu_default_cacheable_i & pagewalk_ns & ~pagewalk_exception_level2;
  assign stage1_mmuoff_attrs     = dside_default_cacheable ? `CA53_PAGE_INNER_WBRWA_OUTER_WBRWA_SHARE_NS :
                                   pagewalk_iside          ? (dpu_icache_on_i ? `CA53_PAGE_INNER_WT_OUTER_WT_SHARE_NS :
                                                                                `CA53_PAGE_INNER_NC_OUTER_NC_SHARE_OS) :
                                                             `CA53_PAGE_DEV_STAGE1_NGNRNE_SHARE_OS;

  // The memory type attributes are initialised to the default values as if
  // SCTLR.M was unset. They are overridden when the attributes are available
  // from the final level of the stage1 walk if one is performed, after any
  // required TEX remapping has been applied. They are again overridden when
  // the final stage2 walk is complete, if required, to combine the stage1 and
  // stage2 attributes together.
  assign next_stage1_attrs = (start_stage1_translation ? stage1_mmuoff_attrs :
                              (pagewalk_stage1 & stage1_translation_complete &
                               (pagewalk_stage1_level != 3'b111)) ? remapped_attrs :
                              (stage2_translation_complete & ~pagewalk_abort) ? combined_attrs :
                              stage1_attrs);

  // - Calculate the page size from the final level of stage 1 walk
  // - TLB RAM "combined size" field doesn't have 1G encoding, but TLB RAM "s1 size" has 1G encoding
  // - Only A64-4k uses L0 and L0 can not have block (i.e. translation can not complete on L0), so
  //   L0 is covered by default
  // - A64-64K in L1 can not have a block (i.e. translation complete), so only
  //   possible size for L1 covers A32 1G block and A64-4k 1G block
  //
  always @*
  case ({pagewalk_stage1_level, pagewalk_lpae})
    4'b111_0: stage1_raw_page_size = `CA53_STAGE_1M;
    4'b111_1: stage1_raw_page_size = `CA53_STAGE_1G;
    4'b001_0: stage1_raw_page_size = pagewalk_data[18] ? `CA53_STAGE_16M : `CA53_STAGE_1M; // 16M(SuperSection) or 1M(Section)
    4'b001_1: stage1_raw_page_size = `CA53_STAGE_1G;
    4'b010_0: stage1_raw_page_size = pagewalk_data[1] ? `CA53_STAGE_4K : `CA53_STAGE_64K;  // 4k(Small Page) or 64k(Large Page)
    4'b010_1: stage1_raw_page_size = pagewalk_a64_g64 ? `CA53_STAGE_512M : `CA53_STAGE_2M;
    4'b011_0,
    4'b011_1: stage1_raw_page_size = pagewalk_a64_g64 ? 
                                      (pagewalk_data[52] ? `CA53_STAGE_2M : `CA53_STAGE_64K): // 2M(Cont Page) or 64k(Page)
                                      (pagewalk_data[52] ? `CA53_STAGE_64K : `CA53_STAGE_4K); // 64k(Cont Page) or 4k(Page)
    default: stage1_raw_page_size = 3'bxxx;
  endcase

  // 2-bit format, same as IPA RAM size format, value 2'11 represents 512M
  always @*
  case (pagewalk_stage2_level)
    3'b111:   stage2_raw_page_size_ext = 2'b11; // 512M
    3'b001:   stage2_raw_page_size_ext = 2'b11; // 512M
    3'b010:   stage2_raw_page_size_ext = stage2_pagewalk_a64_g64 ? 2'b11 : 2'b10; // 512M(A64-64K) : 2M(A64-4K/A32)
    3'b011:   stage2_raw_page_size_ext = stage2_pagewalk_a64_g64 ? 
                                          (pagewalk_data[52] ? 2'b10 : 2'b01) : // 2M(A64-64K cont hint) : 64K(A64-64k)
                                          (pagewalk_data[52] ? 2'b01 : 2'b00); // 64K(A64-4k cont hint) : 4K(A64-4k)
    default:  stage2_raw_page_size_ext = 2'bxx;
  endcase

  always @*
  case (pagewalk_stage2_level)
    3'b111:  stage2_raw_page_size = `CA53_STAGE_1G;
    3'b001:  stage2_raw_page_size = `CA53_STAGE_1G;
    3'b010:  stage2_raw_page_size = stage2_pagewalk_a64_g64 ? 
                                     `CA53_STAGE_512M : `CA53_STAGE_2M; // 512M(A64-64K) : 2M(A64-4K) and A32
    3'b011:  stage2_raw_page_size = stage2_pagewalk_a64_g64 ? 
                                     (pagewalk_data[52] ? `CA53_STAGE_2M : 
                                                          `CA53_STAGE_64K) : // 2M(A64-64K cont hint) : 64K(A64-64k)
                                     (pagewalk_data[52] ? `CA53_STAGE_64K : 
                                                          `CA53_STAGE_4K);  // 64K(A64-4k cont hint) : 4K(A64-4k)
    default: stage2_raw_page_size =  3'bxxx;
  endcase

  // We must store the stage 1 page size before it is potentially altered by
  // any stage 2 translation. The main TLB needs to record the original stage1
  // size so it can identify the correct entries on an invalidate operation.
  assign next_stage1_page_size = (pagewalk_stage1 ? stage1_raw_page_size :
                                  stage1_page_size);


  // combined_page_size encodes seven possible block/page sizes (4K,64k,1M,2M,16M,512M,1G), using same
  // format as used by stage1_page_size. This is used for comparison against stage1_page_size
  // to construct pagewalk_size_reduced.
  // combined_page_size_ext encodes the six possible block/page sizes (4K,64k,1M,2M,16M,512M) in the
  // format of main TLB RAM combined page size field. It is also used for constructing
  // VA mask, PA mask, selecting index bits of RAM address, and pagewalk victim way selection logic.

  // The resulting page size must be the smallest of the stage 1 or stage 2
  // sizes, because the intersection of the two is the only part that we have
  // a valid translation for.
  assign next_combined_page_size = (pagewalk_stage1 ? stage1_raw_page_size :
                                    (stage2_raw_page_size < stage1_page_size) ? stage2_raw_page_size :
                                    combined_page_size);

  always @*
  case (next_combined_page_size)
    `CA53_STAGE_4K  : next_combined_page_size_ext = 2'b00;
    `CA53_STAGE_64K : next_combined_page_size_ext = 2'b01;
    `CA53_STAGE_1M  ,
    `CA53_STAGE_2M  : next_combined_page_size_ext = 2'b10;
    `CA53_STAGE_16M ,
    `CA53_STAGE_512M,
    `CA53_STAGE_1G  : next_combined_page_size_ext = 2'b11;
    default:          next_combined_page_size_ext = {2{1'bx}};
  endcase

  // VA is 48-bit but for constructing next descriptor address, only VA[41:0] is required
  // For A32-VMSA pagewalk_va[41:32] are zero (from DPU), pagewalk_input_addr[11:0] are forced to zero
  // For A32-LPAE pagewalk_va[41:32] are zero (from DPU), pagewalk_input_addr[11:0] are forced to zero
  // For A64-4K  pagewalk_input_addr[11:0] are forced to zero
  // For A64-64K pagewalk_input_addr[15:0] are forced to zero
  // For Stage2,  input address is 40-bits, so pagewalk_input_addr[41:40] are forced to zero
  assign pagewalk_input_addr = pagewalk_stage1 ? {pagewalk_va[41:12], 12'h000} : {2'b00, stage1_addr[39:2], 2'b00};

  // Combine the input address and the page table entry to get the output
  // address of either the next level table or the final translation.
  always @*
  case ({pagewalk_level, current_fetch_lpae})
    // A64-4K-granule, A64-64k granule can not start at L0
    4'b000_1: pagewalk_output_addr =  {pagewalk_data[39:12], pagewalk_input_addr[38:30], 3'b000}; // Table

    // A32-VMSA
    4'b001_0: pagewalk_output_addr = pagewalk_data[1] ?
                                      (pagewalk_data[18] ? 
                                        ({pagewalk_data[8:5], pagewalk_data[23:20],
                                          pagewalk_data[31:24], pagewalk_input_addr[23:0]}) : // 16M SuperSection
                                        ({8'h00, pagewalk_data[31:20], pagewalk_input_addr[19:0]})) : // 1M Section
                                      ({8'h00, pagewalk_data[31:10], pagewalk_input_addr[19:12], 2'b00}); // Table

    // A32-LPAE, A64-4K-granule, A64-64K-granule
    // - Note that 1G block case is unique. Although TLB gets 1G descriptor
    //   it saves it as 512M block in TLB RAM. For 512M block, PA saved in TLB RAM needs
    //   bits[39:29] from descriptor but as the descriptor is for 1G, it only gives [39:30]
    //   and bit[29] of PA (to be saved in TLB RAM in uTLB) is concatenated from VA.
    4'b001_1: pagewalk_output_addr = (pagewalk_stage2 ? stage2_pagewalk_a64_g64 :pagewalk_a64_g64) ?
                                       ({pagewalk_data[39:16], pagewalk_input_addr[41:29], 3'b000}): //Table
                                       (pagewalk_data[1] ? {pagewalk_data[39:12], pagewalk_input_addr[29:21], 3'b000}: //Table
                                                           {pagewalk_data[39:30], pagewalk_input_addr[29:0]}); //1G Block
    // A32-VMSA
    4'b010_0: pagewalk_output_addr = pagewalk_data[1] ? {8'h00, pagewalk_data[31:12], pagewalk_input_addr[11:0]} : // 4k  Page
                                                        {8'h00, pagewalk_data[31:16], pagewalk_input_addr[15:0]};  // 64k Page

    // A32-LPAE, A64-4K-granule, A64-64K-granule
    4'b010_1:
              pagewalk_output_addr = (pagewalk_stage2 ? stage2_pagewalk_a64_g64 :pagewalk_a64_g64) ?
                                       (pagewalk_data[1] ? {pagewalk_data[39:16], pagewalk_input_addr[28:16], 3'b000} : // Table
                                                           {pagewalk_data[39:29], pagewalk_input_addr[28:0]} ): // 512M Block
                                       (pagewalk_data[1] ? {pagewalk_data[39:12], pagewalk_input_addr[20:12], 3'b000} : // Table
                                                           {pagewalk_data[39:21], pagewalk_input_addr[20:0]} ); // 2M Block
    // A32-LPAE, A64-4K-granule, A64-64K-granule
    4'b011_0,
    4'b011_1: pagewalk_output_addr = (pagewalk_stage2 ? stage2_pagewalk_a64_g64 :pagewalk_a64_g64) ?
                                      (pagewalk_data[52] ? 
                                        {pagewalk_data[39:21], pagewalk_input_addr[20:0]}: // 64K*32=2M Contiguous block
                                        {pagewalk_data[39:16], pagewalk_input_addr[15:0]}): // 64K Page
                                      (pagewalk_data[52] ? 
                                        {pagewalk_data[39:16], pagewalk_input_addr[15:0]}:  // 4K*16=64K Contiguous block
                                        {pagewalk_data[39:12], pagewalk_input_addr[11:0]}); // 4K

    default: pagewalk_output_addr = {40{1'bx}};
  endcase


  // Store the IPA after every level of the stage1 translation, and the final PA.
  assign sel_mux_input_start_addr = (pagewalk_state_walk_compare | start_stage1_translation);

  // For A32, Bits 39:32 are cleared to zero by DPU
  assign mux_input_start_addr = pagewalk_mmuon ? (pagewalk_a64 ? stage1_a64_start_addr[39:2] : stage1_start_addr[39:2] )
                                               : (pagewalk_a64 ? {pagewalk_va[39:12], {10{1'b0}}} :
                                                                 {8'h00, pagewalk_va[31:12], {10{1'b0}}});

  assign sel_mux_input_subsequent_addr = (pagewalk_stage1 &
                                          ~a32_pagewalk_disable &          // A32 input address out of range
                                          ~a32_pagewalk_disable_out_addr & // A32 output address out of range
                                          ~a64_pagewalk_disable &          // A64 input address out of range
                                          ~a64_pagewalk_disable_out_addr & // A64 output address out of range
                                          (pagewalk_stage1_level != 3'b111)) |
                                         (stage1_translation_completed & stage2_translation_complete & ~pagewalk_abort);

  assign mux_input_subsequent_addr = pagewalk_output_addr[39:2];

  assign next_stage1_addr = sel_mux_input_start_addr ? mux_input_start_addr :
                            sel_mux_input_subsequent_addr ? mux_input_subsequent_addr : stage1_addr;


  // Update the fields on every level of a stage 1 walk, and the final level of the last stage2 walk.
  assign stage1_en = (pagewalk_state_walk_compare |
                      start_stage1_translation |
                      (start_next_translation & (pagewalk_stage1 | ~another_fetch_required)));

  always @(posedge clk_pagewalk)
  if (stage1_en) begin
    stage1_ap              <= next_stage1_ap;
    stage1_xn_usr          <= next_stage1_xn_usr;
    stage1_xn_nusr         <= next_stage1_xn_nusr;
    stage1_pxn             <= next_stage1_pxn;
    stage1_ns              <= next_stage1_ns;
    stage1_ng              <= next_stage1_ng;
    stage1_domain_only     <= next_stage1_domain_only;
    stage1_domain_only_ls  <= next_stage1_domain_only_ls;
    stage1_domain_muxed    <= next_stage1_domain_muxed;
    stage1_attrs           <= next_stage1_attrs;
    stage1_addr            <= next_stage1_addr;
    stage1_page_size       <= next_stage1_page_size;
    combined_page_size     <= next_combined_page_size;
    combined_page_size_ext <= next_combined_page_size_ext;
  end

  // XN is same for user and non-user up to the 2nd last pagewalk level which is 
  // saved in walk cache. Values change only for the last level where these may 
  // be forced differently for user and non-user depending on permissions
  assign stage1_xn = stage1_xn_usr;

  //----------------------------------------------------------------------------
  // IPA cache control
  //----------------------------------------------------------------------------

  // Maintain a record of which page sizes might be present in the IPA cache.
  assign next_ipa_master_hitmap = ((ipa_master_hitmap | (4'b0001 << ipa_page_size)) &
                                   ~{4{ipa_hitmap_flush_i}});

  assign ipa_master_hitmap_en = (pagewalk_state_ipa_write & pagewalk_ram_pri_i & ~ipa_cache_ecc_err) | ipa_hitmap_flush_i;

  always @(posedge clk_pagewalk or negedge reset_n)
  if (~reset_n) begin
    ipa_master_hitmap <= 4'b0000;
  end else if (ipa_master_hitmap_en) begin
    ipa_master_hitmap <= next_ipa_master_hitmap;
  end

  // Maintain the order of the most recently used page sizes. This is updated
  // whenever an IPA lookup hits.
  //
  // The order is arranged as 4 entries of 2 bits each:
  // [1:0] is the highest priority size
  // [3:2] is the second highest priority size
  // [5:4] is the third highest priority size
  // [7:6] is the lowest priority, but is calculated from the others rather than stored.


  // Calculate the lowest priority size. This is the size that isn't already present in the 3 stored entries.
  assign full_ipa_size_order[5:0] = ipa_size_order;
  assign full_ipa_size_order[6] = full_ipa_size_order[4] ^ full_ipa_size_order[2] ^ full_ipa_size_order[0];
  assign full_ipa_size_order[7] = full_ipa_size_order[5] ^ full_ipa_size_order[3] ^ full_ipa_size_order[1];

  assign ipa_order_update_size = pagewalk_state_ipa_write ? ipa_page_size : ipa_compare_size;

  // Work out which entries need to be shifted down the priority, to fit the
  // new entry as the highest priority. Only entries above the current position
  // of the new size need to shift.
  assign ipa_size_order_shift[0] = (ipa_order_update_size != full_ipa_size_order[1:0]);
  assign ipa_size_order_shift[1] = (ipa_order_update_size != full_ipa_size_order[3:2]) & ipa_size_order_shift[0];

  // Shift the entries as calculated above, and insert the new entry.
  assign next_ipa_size_order = {ipa_size_order_shift[1] ? full_ipa_size_order[3:2] : full_ipa_size_order[5:4],
                                ipa_size_order_shift[0] ? full_ipa_size_order[1:0] : full_ipa_size_order[3:2],
                                ipa_order_update_size};

  // Update the order whenever a lookup hits or a stage2 walk completes.
  assign ipa_size_order_en = (|ipa_cache_hit_way_i) | (pagewalk_state_ipa_write & pagewalk_ram_pri_i & ~ipa_cache_ecc_err);

  // The size order is reset to give 4k highest priority, followed by the other
  // sizes in increasing order. This ensures that the list always contains
  // exactly one of each page size.
  always @(posedge clk_pagewalk or negedge reset_n)
  if (~reset_n) begin
    ipa_size_order <= 6'b10_01_00;
  end else if (ipa_size_order_en) begin
    ipa_size_order <= next_ipa_size_order;
  end

  // Calculate which entries in ipa_size_order are valid (i.e. present in
  // the master hitmap). The highest priority size is always treated as valid,
  // even if it is not in the master hitmap.
  assign ipa_size_order_valid[3] = ipa_master_hitmap[full_ipa_size_order[7:6]];
  assign ipa_size_order_valid[2] = ipa_master_hitmap[full_ipa_size_order[5:4]];
  assign ipa_size_order_valid[1] = ipa_master_hitmap[full_ipa_size_order[3:2]];
  assign ipa_size_order_valid[0] = 1'b1;

  // Indicate which entries in ipa_size_order are valid and haven't already
  // been accessed.
  assign ipa_size_valid = pagewalk_state_ipa_lookup ? ipa_size_order_valid : {ipa_size_remaining, 1'b0};

  assign ipa_size_en = (pagewalk_state_process |
                        start_stage2_translation |
                        ((pagewalk_state_ipa_lookup |
                          pagewalk_state_ipa_compare) & pagewalk_ram_pri_i));

  // Work out the sizes that are still to be looked up after the one being
  // accessed this cycle has been removed. This will use all sizes in order
  // of priority, until all the remaining sizes are not present in the master
  // hitmap. If a lower priority size is present in the master hitmap when a
  // higher priority size is not, then the higher priority size will be looked
  // up even though it doesn't need to be. However this situation should very
  // rarely occur because anything in the master hitmap is likely to be
  // accessed more than something that is not.
  assign next_ipa_size_remaining = { ipa_size_valid[3]   & |ipa_size_valid[2:0],
                                    |ipa_size_valid[3:2] & |ipa_size_valid[1:0],
                                    |ipa_size_valid[3:1] &  ipa_size_valid[0]};


  always @(posedge clk_pagewalk)
  if (ipa_size_en) begin
    ipa_size_remaining <= next_ipa_size_remaining;
  end

  // On the first cycle we always select the highest priority size, otherwise
  // the highest priority size that hasn't already been looked up.
  assign ipa_size_sel = {ipa_size_remaining[0], pagewalk_state_ipa_lookup, start_stage2_translation};

  assign next_ipa_page_size = ipa_size_en ? ((pagewalk_state_process &
                                             ~start_stage2_translation) ? stage2_raw_page_size_ext :
                                             ipa_size_sel[0] ? full_ipa_size_order[1:0] :
                                             ipa_size_sel[1] ? full_ipa_size_order[3:2] :
                                             ipa_size_sel[2] ? full_ipa_size_order[5:4] :
                                                               full_ipa_size_order[7:6]) :
                                            ipa_page_size;

  // Record the page size from the last stage2 translation, for use in the IPA
  // cache write.
  always @(posedge clk_pagewalk)
  if (ipa_size_en) begin
    ipa_page_size    <= next_ipa_page_size;
    ipa_compare_size <= ipa_page_size;
  end

  assign pagewalk_ipa_compare_size_o = {ipa_compare_size, 1'b1};

  always @*
  case (ipa_compare_size)
    2'b00,
    2'b01:   ipa_compare_level = 3'b011; // Level for 64K/4K
    2'b10:   ipa_compare_level = ipa_cache_data_i[37] ? 3'b011 : 3'b010; // Level for 2M block
    2'b11:   ipa_compare_level = ipa_cache_data_i[37] ? 3'b010 : 3'b001; // Level for 512M block
    default: ipa_compare_level = 3'bxxx;
  endcase

  // Mask the IPA to compare against with the page size.
  always @*
  case (ipa_compare_size)
    2'b00:   pagewalk_ipa_compare_ipa_o =  stage1_addr[39:16];              // 4k
    2'b01:   pagewalk_ipa_compare_ipa_o = {stage1_addr[39:20], {4{1'b0}}};  // 64k
    2'b10:   pagewalk_ipa_compare_ipa_o = {stage1_addr[39:25], {9{1'b0}}};  // 2M
    2'b11:   pagewalk_ipa_compare_ipa_o = {stage1_addr[39:33], {17{1'b0}}}; // 512M
    default: pagewalk_ipa_compare_ipa_o = {24{1'bx}};
  endcase

  // Store whether a lookup hit in the IPA cache lookup, to prevent writing the
  // hit data immediately back into the IPA cache in the following cycle.
  assign next_ipa_cache_previous_hit = pagewalk_state_ipa_compare ? |ipa_cache_hit_way_i :
                                                                    (ipa_cache_previous_hit &
                                                                     ~pagewalk_state_idle);

  always @(posedge clk_pagewalk)
  if (pagewalk_state_en) begin
    ipa_cache_previous_hit <= next_ipa_cache_previous_hit;
  end

  //-----------------------------------------------------------------------------
  // IPA cache victim way selection
  //-----------------------------------------------------------------------------

  // Increment the round robin counter every time the IPA cache is written.
  assign next_ipa_victim_round_robin = (pagewalk_state_ipa_write & pagewalk_ram_pri_i & ~ipa_cache_ecc_err) ?
                                       (ipa_victim_round_robin+2'b01) : ipa_victim_round_robin;

  always @(posedge clk_pagewalk or negedge reset_n)
  if (~reset_n) begin
    ipa_victim_round_robin <= 2'b00;
  end else if (pagewalk_state_en) begin
    ipa_victim_round_robin <= next_ipa_victim_round_robin;
  end

  // Based on the valid bits seen from the RAMs during a lookup read data phase,
  // pick the victim way for the current size. If one way is invalid, then pick
  // that, otherwise choose randomly based on the round robin counter.
  assign ipa_victim_way = sel_victim_round_robin_i ? ipa_victim_round_robin : first_available_way_i;

  assign ipa_compare_size_onehot = {ipa_compare_size == 2'b11,
                                    ipa_compare_size == 2'b10,
                                    ipa_compare_size == 2'b01,
                                    ipa_compare_size == 2'b00};

  // The page size of the new entry will not be known until the walk
  // completes, and so we need to store a victim way for each possible page
  // size. These are updated when that particular size is accessed. If a size
  // is not accessed (because it is not present in the master hitmap) then the
  // victim way is initialised to the random value (from the round robin
  // counter).
  assign ipa_victim_way_size0 = ipa_compare_size_onehot[0] ? ipa_victim_way : ipa_victim_way_size0_early;
  assign ipa_victim_way_size1 = ipa_compare_size_onehot[1] ? ipa_victim_way : ipa_victim_way_size1_early;
  assign ipa_victim_way_size2 = ipa_compare_size_onehot[2] ? ipa_victim_way : ipa_victim_way_size2_early;
  assign ipa_victim_way_size3 = ipa_compare_size_onehot[3] ? ipa_victim_way : ipa_victim_way_size3_early;

  assign next_ipa_victim_way_size0_early = pagewalk_state_ipa_lookup ? ipa_victim_round_robin : ipa_victim_way_size0;
  assign next_ipa_victim_way_size1_early = pagewalk_state_ipa_lookup ? ipa_victim_round_robin : ipa_victim_way_size1;
  assign next_ipa_victim_way_size2_early = pagewalk_state_ipa_lookup ? ipa_victim_round_robin : ipa_victim_way_size2;
  assign next_ipa_victim_way_size3_early = pagewalk_state_ipa_lookup ? ipa_victim_round_robin : ipa_victim_way_size3;

  assign ipa_victim_ways_en = pagewalk_state_ipa_compare | pagewalk_state_ipa_lookup;

  always @(posedge clk_pagewalk)
  if (ipa_victim_ways_en) begin
    ipa_victim_way_size0_early <= next_ipa_victim_way_size0_early;
    ipa_victim_way_size1_early <= next_ipa_victim_way_size1_early;
    ipa_victim_way_size2_early <= next_ipa_victim_way_size2_early;
    ipa_victim_way_size3_early <= next_ipa_victim_way_size3_early;
  end

  always @*
  case (ipa_page_size)
    2'b00:   selected_ipa_victim_way = ipa_victim_way_size0_early;
    2'b01:   selected_ipa_victim_way = ipa_victim_way_size1_early;
    2'b10:   selected_ipa_victim_way = ipa_victim_way_size2_early;
    2'b11:   selected_ipa_victim_way = ipa_victim_way_size3_early;
    default: selected_ipa_victim_way = 2'bxx;
  endcase

  assign ipa_ram_en = {(selected_ipa_victim_way==2'b11), (selected_ipa_victim_way==2'b10),
                       (selected_ipa_victim_way==2'b01), (selected_ipa_victim_way==2'b00)};

  //-----------------------------------------------------------------------------
  // Walk cache victim way selection
  //-----------------------------------------------------------------------------

  // Increment the round robin counter every time the walk cache is written.
  assign next_walk_victim_round_robin = (pagewalk_state_walk_write & pagewalk_ram_pri_i & ~walk_cache_ecc_err) ?
                                        (walk_victim_round_robin + 2'b01) : walk_victim_round_robin;

  always @(posedge clk_pagewalk or negedge reset_n)
  if (~reset_n) begin
    walk_victim_round_robin <= 2'b00;
  end else if (pagewalk_state_en) begin
    walk_victim_round_robin <= next_walk_victim_round_robin;
  end

  // Based on the valid bits seen from the RAMs during a lookup read data phase,
  // pick the victim way. If one way is invalid, then pick that, otherwise choose
  // randomly based on the round robin counter.
  assign next_walk_victim_way = pagewalk_state_walk_compare ?
                                 (sel_victim_round_robin_i ? walk_victim_round_robin : first_available_way_i) :
                                 walk_victim_way;

  // On main TLB RAM lookup ECC error, walk cache is not read and hit signal
  // should be ignored
  assign next_walk_cache_previous_hit = ~pagewalk_ecc_err_cmn & walk_cache_hit_i & ~stage1_start_level3_a64_g64;

  always @(posedge clk_pagewalk)
  if (pagewalk_state_en) begin
    walk_victim_way         <= next_walk_victim_way;
    walk_cache_previous_hit <= next_walk_cache_previous_hit;
  end

  assign walk_ram_en = {(walk_victim_way==2'b11), (walk_victim_way==2'b10),
                        (walk_victim_way==2'b01), (walk_victim_way==2'b00)};

  //----------------------------------------------------------------------------
  // uTLB update
  //----------------------------------------------------------------------------

  // Record when the request that started the pagewalk has been dropped before
  // the pagewalk has completed. This does not stop the pagewalk,
  // and the RAMs will still be written with the result, but the uTLB must not
  // be updated because the DPU/PFU would assume that the update is for the
  // current instruction which will not be the same as the one that started the
  // original request.
  assign next_pagewalk_req_dropped = ((pagewalk_req_dropped |
                                       ~(pagewalk_iside ? ifu_utlb_miss_req_i : dcu_va_valid_dc1_i)) &
                                      ~pagewalk_state_idle);

  always @(posedge clk_pagewalk)
  if (pagewalk_state_en) begin
    pagewalk_req_dropped <= next_pagewalk_req_dropped;
  end


  // Enable the uTLB when the final result of the pagewalk is available,
  // provided that the original request is still being made.
  assign pagewalk_utlb_enable = (pagewalk_state_process & 
                                 ~pagewalk_ecc_err_cmn &
                                 ~another_fetch_required &
                                 ~abandon_pagewalk &
                                 ~pagewalk_req_dropped);

  assign pagewalk_i_utlb_enable_o = pagewalk_utlb_enable &  pagewalk_iside & ifu_utlb_miss_req_i;
  assign pagewalk_d_utlb_enable_o = pagewalk_utlb_enable & ~pagewalk_iside & dcu_va_valid_dc1_i;

  // Provide an early indication the cycle before if the uTLB is likely to be enabled.
  assign pagewalk_utlb_next_might_enable = ((pagewalk_state_walk_wait |
                                             pagewalk_state_lookup_m3 |
                                             pagewalk_state_ipa_wait | // Next state may be PROCESS state
                                             ((pagewalk_state_biu_axi_wait |
                                               pagewalk_state_linefill |
                                               pagewalk_state_linefill_hz) & biu_walk_ack_i) |
                                             (pagewalk_state_process &
                                              another_fetch_required &
                                              start_stage2_translation &
                                              next_any_stage2_pagewalk_disable)) &
                                            ~abandon_pagewalk &
                                            ~pagewalk_req_dropped);

  assign pagewalk_i_utlb_next_might_enable_o = pagewalk_utlb_next_might_enable &  pagewalk_iside & ifu_utlb_miss_req_i;
  assign pagewalk_d_utlb_next_might_enable_o = pagewalk_utlb_next_might_enable & ~pagewalk_iside & dcu_va_valid_dc1_i;

  // external_dec_abort is covered by external_abort.
  assign pagewalk_abort = pagewalk_state_process &
                              (a32_pagewalk_disable |
                               a32_pagewalk_disable_out_addr |
                               a64_pagewalk_disable |
                               a64_pagewalk_disable_out_addr |
                               external_abort    |
                               translation_fault |              // A32/A64 common input addr out of range
                               translation_fault_out_addr |     // A32 output addr out of range MMU on
                               translation_fault_a64_out_addr | // A64 output addr out of range MMU on
                               mmuoff_fault_out_addr |          // A32/A64 common output addr out of range for MMU off
                               access_flag_fault |
                               stage2_permission_fault |
                               stage2_dev_so_fault);

  // If there was a fault, then determine the fault type encoding to write to
  // the uTLB.
  assign pagewalk_fault_type =
              (stage1_a32_pagewalk_disable & pagewalk_a32) ? `CA53_FAULT_LPAE_TRANSLATION_L1 :
              (stage1_a64_pagewalk_disable & pagewalk_a64) ? `CA53_FAULT_LPAE_TRANSLATION_L0 :
              // A32 S1 address size fault is always reported as L0 fault
              // A64 S1 MMU off fault is reported as L0 fault, irrespective of granule value
              ((stage1_a32_pagewalk_disable_out_addr & pagewalk_a32) |
               (stage1_a64_pagewalk_disable_out_addr & pagewalk_a64) |
               (mmuoff_fault_out_addr))                    ? `CA53_FAULT_LPAE_ADDR_SIZE_L0 :
              (stage2_a32_pagewalk_disable & stage2_pagewalk_a32) ? `CA53_FAULT_LPAE_TRANSLATION_L1 :
              // Although A64-4K S2 starts at L1 and A64-64K S2 starts at L2, S2
              // translation fault from base address is reported as L0
              (stage2_a64_pagewalk_disable & stage2_pagewalk_a64) ? `CA53_FAULT_LPAE_TRANSLATION_L0 :
              // A32 S2 address size fault is always reported as L0 fault
              ((stage2_a32_pagewalk_disable_out_addr & stage2_pagewalk_a32) |
               (stage2_a64_pagewalk_disable_out_addr & stage2_pagewalk_a64)) ? `CA53_FAULT_LPAE_ADDR_SIZE_L0 :
              external_ecc_abort               ? {`CA53_FAULT_LPAE_PAGEWALK_EXT_ECC, pagewalk_level[1:0]} :
              external_dec_abort               ? {`CA53_FAULT_LPAE_PAGEWALK_EXT_DEC, pagewalk_level[1:0]} :
              external_abort                   ? {`CA53_FAULT_LPAE_PAGEWALK_EXT_SLV, pagewalk_level[1:0]} :
              translation_fault                ? {`CA53_FAULT_LPAE_TRANSLATION,      pagewalk_level[1:0]} :
              (translation_fault_out_addr |
               translation_fault_a64_out_addr) ? {`CA53_FAULT_LPAE_ADDR_SIZE,        pagewalk_level[1:0]} :
              access_flag_fault                ? {`CA53_FAULT_LPAE_ACCESS,           pagewalk_level[1:0]} :
                                                 {`CA53_FAULT_LPAE_PERMISSION,       pagewalk_level[1:0]};

  // Pagewalk disabled faults, and MMU off are always reported as level 1.
  // SuperSections are encoded as zero because the DCU needs to distinguish
  // them from sections, but the DCU and PFU will convert the level back to 1
  // if needed for the fault encodings.
  assign stage1_level = ((pagewalk_stage1_level == 3'b111) |
                         (pagewalk_stage1_level == 3'b000)) ? 2'b01 : // Pagewalk disabled, MMU off, or fault in A64-L0
                        ((next_stage1_page_size == `CA53_STAGE_16M) & ~pagewalk_lpae &
                          ~(pagewalk_stage1 & (external_abort | translation_fault))) ? 2'b00 :// SuperSection encoded as zero
                        pagewalk_stage1_level[1:0]; // pagewalk_stage1_level is 3-bit

  // Format the data ready for the uTLB.
  // uTLB data encoding:
  // Domain     [95:92]
  // Fault type [91:85]
  // Fault      [84:83]
  // S2Level    [82:81]
  // S1Level    [80:79]
  // MemAttrs   [78:71]
  // HAP        [70:69]
  // AP/HYP     [68:66]
  // NS         [65]
  // PA         [64:37]
  // VA         [36:0]

  // pagewalk_va[48] gives sign bit for VA[63:48]. For cases with
  // VA[63:48] not all set or all clear, TLB generates translation fault. With
  // translation fault, pagewalk_va[48] can be set or clear and should be ignored
  assign pagewalk_d_utlb_data_o = {
                                   next_stage1_domain_nowalk_only, next_stage1_domain_nowalk_only_ls,
                                   pagewalk_fault_type,
                                   {(pagewalk_abort & 
                                      ~(pagewalk_stage2 & ~mmuoff_fault_out_addr & ~stage1_translation_completed)),
                                    (pagewalk_abort & pagewalk_stage2 & ~mmuoff_fault_out_addr)},
                                   ((pagewalk_stage2_level == 3'b111) ? 2'b00 : pagewalk_stage2_level[1:0]),
                                   stage1_level,
                                   next_stage1_attrs,
                                   pagewalk_hap,
                                   pagewalk_ap,
                                   next_stage1_ns_nowalk,
                                   next_stage1_addr[39:12],
                                   pagewalk_va[48],
                                   pagewalk_va[47:12]};
  // uTLB data encoding:
  // Size       [96]
  // XS1Nonusr  [95]
  // XS2        [94]
  // XS1Usr     [93]
  // Domain     [92:89]
  // Fault type [88:82]
  // Fault      [81:80]
  // S2Level    [79:78]
  // S1Level    [77:76]
  // MemAttrs   [75:68]
  //
  // ExcpLevel  [67:66]
  // NS         [65]
  // PA         [64:37]
  // VA         [36:0]

  // For EL3 in A32
  //  - NS EL1/EL0 are reported as 2'b00
  //  - S  EL3/EL0 are reported as 2'b00
  //  - Other exceptions are reported as such
  // For EL3 in A64
  //  - NS EL1/EL0 are reported as 2'b00
  //  - S  EL1/EL0 are reported as 2'b00
  //  - Other exceptions are reported as such
  assign i_utlb_excp_level = ((pagewalk_exception_level == 2'b00) |
                              (pagewalk_exception_level == 2'b01) |
                              ((pagewalk_exception_level == 2'b11) & pagewalk_a32)) ? 2'b00
                                                                                 : pagewalk_exception_level;

  assign pagewalk_i_utlb_data_o = {`CA53_STAGE_1M_OR_MORE(next_combined_page_size),
                                   next_xs1nonusr,
                                   next_xs2,
                                   next_xs1usr,
                                   next_stage1_domain_nowalk_only, next_stage1_domain_nowalk_only_ls,
                                   pagewalk_fault_type,
                                   {(pagewalk_abort & 
                                     ~(pagewalk_stage2 & ~mmuoff_fault_out_addr & ~stage1_translation_completed)),
                                    (pagewalk_abort & pagewalk_stage2 & ~mmuoff_fault_out_addr)},
                                   ((pagewalk_stage2_level==3'b111) ? 2'b00 : pagewalk_stage2_level[1:0]),
                                   stage1_level,
                                   next_stage1_attrs,
                                   i_utlb_excp_level,
                                   next_stage1_ns_nowalk,
                                   next_stage1_addr[39:12],
                                   pagewalk_va[48],
                                   pagewalk_va[47:12]};

  //----------------------------------------------------------------------------
  // Main TLB RAM requests
  //----------------------------------------------------------------------------

  // Make a request to write the RAMs whenever we are in the tlb write state.
  // Also request access to the RAMs for walk cache lookups and writes, and
  // IPA cache lookups and writes.
  // The write will only happen if pagewalk RAM writes also have priority this
  // cycle.

  always @(posedge clk_pagewalk or negedge reset_n)
  if (~reset_n) begin
    pagewalk_ram_req <= 1'b0;
  end else if (pagewalk_state_en) begin
    pagewalk_ram_req <= next_pagewalk_ram_req;
  end

  assign pagewalk_ram_req_o = pagewalk_ram_req;

  // The way to write is determined from the victim ways given by the lookup
  // block. The way depends on the page size, because the RAM index written
  // depends on the size and therefore the valid ways already present may vary.
  always @*
  case (combined_page_size_ext)
   2'b00:   pagewalk_victim_way = pagewalk_victim_way_size0;
   2'b01:   pagewalk_victim_way = pagewalk_victim_way_size1;
   2'b10:   pagewalk_victim_way = pagewalk_victim_way_size2;
   2'b11:   pagewalk_victim_way = pagewalk_victim_way_size3;
   default: pagewalk_victim_way = 2'bxx;
  endcase

  //One hot RAM enables
  assign main_ram_en = {(pagewalk_victim_way==2'b11), (pagewalk_victim_way==2'b10),
                        (pagewalk_victim_way==2'b01), (pagewalk_victim_way==2'b00)};

  generate if (CPU_CACHE_PROTECTION) begin : g_protection_pw3
  
    wire [3:0] next_muxed_main_ram_en;
    wire [3:0] next_muxed_walk_ram_en;
    wire [3:0] next_muxed_ipa_ram_en;
  
    reg [3:0] muxed_main_ram_en;
    reg [3:0] muxed_walk_ram_en;
    reg [3:0] muxed_ipa_ram_en;
  
    assign next_muxed_main_ram_en = pagewalk_ecc_err_cmn ? pagewalk_ecc_err_way_cmn : main_ram_en;
    assign next_muxed_walk_ram_en = walk_cache_ecc_err ? walk_cache_ecc_err_way : walk_ram_en;
    assign next_muxed_ipa_ram_en  = ipa_cache_ecc_err ? ipa_cache_ecc_err_way : ipa_ram_en;
  
    // Write enables are registered in WRITE0 state
    always @(posedge clk_pagewalk)
    if (pagewalk_state_en) begin
      muxed_main_ram_en <= next_muxed_main_ram_en;
      muxed_walk_ram_en <= next_muxed_walk_ram_en;
      muxed_ipa_ram_en  <= next_muxed_ipa_ram_en;
    end
  
    assign pagewalk_ram_way_o = (({4{pagewalk_state_tlb_write}} & muxed_main_ram_en) |      // main RAM write enables
                                 ({4{pagewalk_state_walk_lookup & (pagewalk_mmuon & ~pagewalk_ecc_err_cmn)}}) | // WALK RAM read enables
                                 ({4{pagewalk_state_walk_write}} & muxed_walk_ram_en) |     // WALK RAM write enables
                                 ({4{pagewalk_state_ipa_lookup |
                                    (pagewalk_state_ipa_compare & |ipa_size_remaining)}}) | // IPA RAM read enables
                                 ({4{pagewalk_state_ipa_write}} & muxed_ipa_ram_en));       // IPA RAM write enables
  
    // Support for ECC reporting
    //  For slightly better timing, mux is separated from RAM mux,It uses only write state and ECC enables
    //  Only Bits[2:0] are used as Bit[3] is selected in default condition by logic using this signal
    assign tlb_pty_way_non_cp_o = (({3{pagewalk_state_tlb_write}} & pagewalk_ecc_err_way_cmn[2:0]) | // main RAM write enables
                                   ({3{pagewalk_state_walk_write}} & walk_cache_ecc_err_way[2:0]) |  // WALK RAM write enables
                                   ({3{pagewalk_state_ipa_write}} & ipa_cache_ecc_err_way[2:0]));    // IPA RAM write enables
  
  end else begin : g_protection_stubs_pw3

    assign pagewalk_ram_way_o = (({4{pagewalk_state_tlb_write}} & main_ram_en) |           // main RAM write enables
                                 ({4{pagewalk_state_walk_lookup & pagewalk_mmuon}}) |      // WALK RAM read enables
                                 ({4{pagewalk_state_walk_write}} & walk_ram_en) |          // WALK RAM write enables
                                 {4{pagewalk_state_ipa_lookup |
                                    (pagewalk_state_ipa_compare & |ipa_size_remaining)}} | // IPA RAM read enables
                                 ({4{pagewalk_state_ipa_write}} & ipa_ram_en));            // IPA RAM write enables
  
    // Support for ECC reporting
    assign tlb_pty_way_non_cp_o = {3{1'b0}};
  
  end endgenerate

  assign pagewalk_ram_wr_o = (pagewalk_state_tlb_write |
                              pagewalk_state_walk_write |
                              pagewalk_state_ipa_write);

  // On TLB RAM invalidation due to ECC error, hitmap register is not updated,
  // and even signals to DPU are not asserted 
  assign pagewalk_ram_written = pagewalk_state_tlb_write & pagewalk_ram_pri_i & ~pagewalk_ecc_err_cmn;

  // Select the correct portion of the address based on the size being written.
  always @*
  case ({next_combined_page_size_ext,pagewalk_lpae})
    3'b00_0,
    3'b00_1: tlb_wr_addr = pagewalk_va[18:12]; // 4k
    3'b01_0,
    3'b01_1: tlb_wr_addr = pagewalk_va[22:16]; // 64k
    3'b10_0: tlb_wr_addr = pagewalk_va[26:20]; // 1M
    3'b10_1: tlb_wr_addr = pagewalk_va[27:21]; // 2M
    3'b11_0: tlb_wr_addr = pagewalk_va[30:24]; // 16M
    3'b11_1: tlb_wr_addr = pagewalk_va[35:29]; // 512M
    default: tlb_wr_addr = {7{1'bx}};
  endcase

  // Support for granule calculation 
  // - VA[48] is set, if VA[63:48] are all set
  // - With VA[48] clear,VA[63:48] could  be all clear or some bits clear with others
  //   set. So use pagewalk_va_sign_err
  // Mask bits, that are set, should have address bits clear
  assign lookup_match_a64_ttbr0 = lookup_ttbr0_sign_match_i &
                                  (~|(lookup_va_early_i[47:25] & tcr_a64_el1_t0sz_mask));

  assign lookup_tcr_a64_tg = lookup_el3_el2_i ? lookup_el3_el2_g64_i :
                             lookup_match_a64_ttbr0 ? tcr_a64_el1_tg0_i :
                                                      tcr_a64_el1_tg1_i ;

  assign lookup_a64_g64 = lookup_aarch64_early_i & lookup_tcr_a64_tg;

  // The final format is LPAE only if the stage1 translation is not VMSA OR in aarch64
  // The final format is LPAE only if the stage1 translation is not VMSA
  assign lookup_lpae = lookup_aarch64_early_i | lookup_exception_level_early_i[2] |
                        ((lookup_aarch64_at_el3_early_i | lookup_ns_early_i) ? ttbcr_eae_ns_i : ttbcr_eae_s_i);

  assign lookup_s1s2_a64_g64 = (lookup_a64_g64 & lookup_stage2_a64_g64_i);

  assign lookup_s1s2_a64_g64_o = lookup_s1s2_a64_g64;

  assign lookup_walk_cache_addr = ~lookup_lpae ? lookup_va_early_i[23:20]: // VMSA
                                  lookup_s1s2_a64_g64 ? lookup_va_early_i[32:29]: // S1-A64-64K and S2 not required or S2 is A64-64K
                                                        lookup_va_early_i[24:21]; // S1-A64-4K S2-Any

  assign walk_cache_addr = pagewalk_state_idle ? lookup_walk_cache_addr : pagewalk_walk_cache_addr;


  always @*
  case (next_ipa_page_size)
    2'b00:   ipa_cache_addr = stage1_en ? next_stage1_addr[15:12] : stage1_addr[15:12]; // 4k
    2'b01:   ipa_cache_addr = stage1_en ? next_stage1_addr[19:16] : stage1_addr[19:16]; // 64k
    2'b10:   ipa_cache_addr = stage1_en ? next_stage1_addr[24:21] : stage1_addr[24:21]; // 2M
    2'b11:   ipa_cache_addr = stage1_en ? next_stage1_addr[32:29] : stage1_addr[32:29]; // 512M
    default: ipa_cache_addr = {4{1'bx}};
  endcase

  generate if (CPU_CACHE_PROTECTION) begin : g_protection_pw4
    reg [6:0]  tlb_wr_addr_early;
  
    always @(posedge clk_pagewalk) 
    if (pagewalk_state_en) begin
      tlb_wr_addr_early <= tlb_wr_addr; 
    end
  
    assign next_pagewalk_ram_addr = (({8{next_pagewalk_ram_tlb}}  & (pagewalk_ecc_err_cmn ? {1'b0, pagewalk_ecc_err_addr_cmn} :
                                                                                            {1'b0, tlb_wr_addr_early})) |
                                     ({8{next_pagewalk_ram_walk}} & {`CA53_RAM_WALK_PREFIX_ADDR, walk_cache_addr}) |
                                     ({8{next_pagewalk_ram_ipa}}  & (ipa_cache_ecc_err ? {`CA53_RAM_IPA_PREFIX_ADDR,ipa_cache_ecc_err_addr}:
                                                                                         {`CA53_RAM_IPA_PREFIX_ADDR,ipa_cache_addr })));
  end else begin : g_protection_stubs_pw4
    assign next_pagewalk_ram_addr = (({8{next_pagewalk_ram_tlb}}  & {1'b0, tlb_wr_addr}) |
                                     ({8{next_pagewalk_ram_walk}} & {`CA53_RAM_WALK_PREFIX_ADDR, walk_cache_addr}) |
                                     ({8{next_pagewalk_ram_ipa}}  & {`CA53_RAM_IPA_PREFIX_ADDR, ipa_cache_addr}));
  end endgenerate

  // Register the RAM address so it is available early in the cycle the RAMs
  // are accessed.
  always @(posedge clk_pagewalk)
  if (pagewalk_state_en) begin
    pagewalk_ram_addr <= next_pagewalk_ram_addr;
  end

  assign pagewalk_ram_addr_o = pagewalk_ram_addr;

  // Mask the lower bits (depending on page size) of the VA before writing to
  // the RAM. This avoids the need to mask them when reading the RAM as part
  // of the comparators, which are more timing critical.
  always @*
  case ({combined_page_size_ext, pagewalk_lpae})
    3'b000,
    3'b001:  ram_masked_va =  pagewalk_va[47:19]; // 4k
    3'b010,
    3'b011:  ram_masked_va = {pagewalk_va[47:23], {4{1'b0}}}; // 64k
    3'b100:  ram_masked_va = {pagewalk_va[47:27], {8{1'b0}}}; // 1M
    3'b101:  ram_masked_va = {pagewalk_va[47:28], {9{1'b0}}}; // 2M
    3'b110:  ram_masked_va = {pagewalk_va[47:31], {12{1'b0}}};// 16M
    3'b111:  ram_masked_va = {pagewalk_va[47:36], {17{1'b0}}};// 512M
    default: ram_masked_va = {29{1'bx}};
  endcase

  // -Mask the lower bits (depending on page size) of the PA before writing to
  //  the RAM. This avoids the need to mask them when reading the RAM.
  // -For 1G block at L1, TLB stores 1G block size as 512M block size, and
  //  although 1G block descriptor has only address bits [39:30] valid, logic
  //  takes a VA bit to make it to fill bit [29] to make it [39:29]
  always @*
  case ({combined_page_size_ext, pagewalk_lpae})
    3'b000,
    3'b001:  ram_masked_pa =  stage1_addr[39:12]; // 4k
    3'b010,
    3'b011:  ram_masked_pa = {stage1_addr[39:16], {4{1'b0}}};  // 64k
    3'b100:  ram_masked_pa = {stage1_addr[39:20], {8{1'b0}}};  // 1M
    3'b101:  ram_masked_pa = {stage1_addr[39:21], {9{1'b0}}};  // 2M
    3'b110:  ram_masked_pa = {stage1_addr[39:24], {12{1'b0}}}; // 16M
    3'b111:  ram_masked_pa = {stage1_addr[39:29], {17{1'b0}}}; // 512M
    default: ram_masked_pa = {28{1'bx}};
  endcase

  // Mask the lower bits depending on the size being written to the IPA cache.
  always @*
  case (ipa_page_size)
    2'b00:   ipa_ram_masked_ipa =  stage1_addr[39:16];              // 4k
    2'b01:   ipa_ram_masked_ipa = {stage1_addr[39:20], {4{1'b0}}};  // 64k
    2'b10:   ipa_ram_masked_ipa = {stage1_addr[39:25], {9{1'b0}}};  // 2M
    2'b11:   ipa_ram_masked_ipa = {stage1_addr[39:33], {17{1'b0}}}; // 512M
    default: ipa_ram_masked_ipa = {24{1'bx}};
  endcase

  always @*
  case (ipa_page_size)
    2'b00:   ipa_ram_masked_pa =  pagewalk_data[39:12];              // 4k
    2'b01:   ipa_ram_masked_pa = {pagewalk_data[39:16], {4{1'b0}}};  // 64k
    2'b10:   ipa_ram_masked_pa = {pagewalk_data[39:21], {9{1'b0}}};  // 2M
    2'b11:   ipa_ram_masked_pa = {pagewalk_data[39:29], {17{1'b0}}}; // 512M
    default: ipa_ram_masked_pa = {28{1'bx}};
  endcase

  // If in a secure or hyp mode, then the lookup logic must be forced to match
  // on the VMID, so to help this always write it as a known value.
  assign pagewalk_vmid = tlb_vmid_i & {8{pagewalk_ns & ~pagewalk_exception_level2}};
  assign asid_pagewalk = pagewalk_a64 ? asid_a64_pagewalk_i : asid_a32_pagewalk_i;
  assign asid_pagewalk_o = asid_pagewalk;

  //---------------------------------------------------------------------------
  // TLB RAM Data Write
  //---------------------------------------------------------------------------

  assign tlb_ram_common_wr_data = {114{~pagewalk_ecc_err_cmn}} &
                                  {((pagewalk_stage2_level==3'b111) ? 2'b00 : pagewalk_stage2_level[1:0]),
                                   stage1_page_size,
                                   {stage1_domain_only,
                                    stage1_domain_muxed},
                                   stage1_attrs,
                                   next_xs2,   // [96]
                                   xs1nonusr,  // [95]
                                   xs1usr,     // [94]
                                   ram_masked_pa,
                                   stage1_ns,
                                   pagewalk_hap_ram,
                                   pagewalk_ap_ram,
                                   stage1_ng,
                                   {combined_page_size_ext,
                                    pagewalk_lpae},
                                   asid_pagewalk,
                                   pagewalk_vmid,
                                   pagewalk_ns,
                                   ram_masked_va[47:19],
                                   pagewalk_va[48], // sign bit
                                   1'b1};

  //---------------------------------------------------------------------------
  // Walk RAM Data Write
  //---------------------------------------------------------------------------

  // Format the data ready for a walk cache write.
  assign walk_ram_masked_va = ~pagewalk_lpae ?  pagewalk_va[47:24]: // VMSA
                              (pagewalk_a64_g64 &  // S1-A64-64K, S2 not required or is also A64-64K
                               ((~stage2_translation_required_normal) |
                                (stage2_translation_required_normal & stage2_pagewalk_a64_g64))) ? {pagewalk_va[47:33], {9{1'b0}}} :
                                                                                                   {pagewalk_va[47:25], 1'b0}; // S1-A64-4K S2-Any

 // S1-A64-64K gran, S2 not required
 // S1-A64-64K gran, S2-A64-64K gran
 //   encoded as 2'b11
 // S1-A64-64K gran, S2-A64-4K gran
 //   encoded as 2'b10
 // S1-A64-4K gran, S2-Any
 // S1-LPAE, S2-Any
 //    encoded as 2'b01
 // S1-VMSA, S2-Any
 //    encoded as 2'b00
  assign walk_ram_arch = (pagewalk_a64_g64 & 
                          ((~stage2_translation_required_normal) |
                           (stage2_translation_required_normal & stage2_pagewalk_a64_g64))) ? 2'b11 :
                         (pagewalk_a64_g64 & stage2_pagewalk_a64_g4)                        ? 2'b10 :
                         pagewalk_lpae                                                      ? 2'b01 : 2'b00;

  assign walk_ram_masked_va_o = walk_ram_masked_va;
  assign walk_ram_arch_o = walk_ram_arch;

  assign walk_ram_common_wr_data = {114{~walk_cache_ecc_err}} &
                                   {pagewalk_addr[39:10],        // [113:84]
                                    walk_ram_masked_va,          // [83:60]
                                    pagewalk_va[48],             // [59]
                                    {3{1'b0}},                   // [58:56]
                                    asid_pagewalk,               // [55:40]
                                    pagewalk_vmid,               // [39:32]
                                    pagewalk_ns,                 // [31]
                                    {9{1'b0}},                   // [30:22]
                                    {stage1_domain_only,
                                     stage1_domain_only_ls},     // [21:18]
                                    walk_ram_arch,               // [17:16]
                                    stage1_ns,                   // [15]
                                    stage1_pxn,                  // [14]
                                    stage1_xn,                   // [13]
                                    stage1_ap[2:1],              // [12:11]
                                    (pagewalk_exception_level3 &
                                     pagewalk_a64),              // [10] EL3 in A64
                                    pagewalk_exception_level2,   // [9]
                                    pagewalk_attrs_to_walk_cache,// [8:1]
                                    1'b1};                       // [0]

  //---------------------------------------------------------------------------
  // IPA RAM Data Write
  //---------------------------------------------------------------------------

  assign ipa_ram_common_wr_data = {114{~ipa_cache_ecc_err}} &
                                  {ipa_ram_masked_pa[39:12],  // [113:86]
                                   ipa_ram_masked_ipa[39:16], // [85:62]
                                   {3{1'b0}},                 // [61:59] unused
                                   {ipa_page_size, 1'b1},     // [58:56]
                                   {16{1'b0}},                // [55:40]
                                   pagewalk_vmid,             // [39:32]
                                   {21{1'b0}},                // [31:11]
                                   stage2_pagewalk_a64_g64,
                                   pagewalk_data[5:2],        // [9:6]
                                   pagewalk_data[54],         // [5]
                                   pagewalk_data[7:6],        // [4:3]
                                   pagewalk_data[9:8],        // [2:1]
                                   1'b1};                     // [0]

  //---------------------------------------------------------------------------
  // MAIN TLB RAM, WALK cahce and IPA cache write ECC
  //---------------------------------------------------------------------------

  generate if (CPU_CACHE_PROTECTION) begin : g_protection_pw5

    reg  [2:0]     ram_parity;
    wire [2:0]     next_ram_parity;
    wire [113:0]   muxed_ram_common_wr_data;
  
    assign muxed_ram_common_wr_data = (({114{pagewalk_state_tlb_write0}}  & tlb_ram_common_wr_data[113:0]) |
                                       ({114{pagewalk_state_walk_write0}} & walk_ram_common_wr_data[113:0]) |
                                       ({114{pagewalk_state_ipa_write0}}  & ipa_ram_common_wr_data[113:0]));
  
    assign next_ram_parity = (pagewalk_state_ipa_write0 | 
                              pagewalk_state_walk_write0 | 
                              pagewalk_state_tlb_write0) ? 
                               {^muxed_ram_common_wr_data[113:62],
                                ^muxed_ram_common_wr_data[61:31],
                                ^muxed_ram_common_wr_data[30:0]} : ram_parity;
  
    always @(posedge clk_pagewalk)
    if (pagewalk_state_en) begin
      ram_parity <= next_ram_parity;
    end
  
    assign tlb_ram_wr_data  = {ram_parity,tlb_ram_common_wr_data};
    assign walk_ram_wr_data = {ram_parity,walk_ram_common_wr_data};
    assign ipa_ram_wr_data  = {ram_parity,ipa_ram_common_wr_data};
   
  end else begin : g_protection_stubs_pw5
  
    assign tlb_ram_wr_data  = tlb_ram_common_wr_data[113:0];
    assign walk_ram_wr_data = walk_ram_common_wr_data[113:0];
    assign ipa_ram_wr_data  = ipa_ram_common_wr_data[113:0];
  
  
  end endgenerate

  //---------------------------------------------------------------------------
  // WALK and IPA cache read ECC
  //---------------------------------------------------------------------------
  generate if (CPU_CACHE_PROTECTION) begin : g_protection_pw6
  
    wire       next_walk_cache_ecc_err_early;
    wire [3:0] next_walk_cache_ecc_err_way_early;
    reg        walk_cache_ecc_err_early;
    reg  [3:0] walk_cache_ecc_err_way_early;
    wire       next_ipa_cache_ecc_err_early;
    wire [3:0] next_ipa_cache_ecc_err_way_early;
    wire [3:0] next_ipa_cache_ecc_err_addr_early;
    reg        ipa_cache_ecc_err_early;
    reg  [3:0] ipa_cache_ecc_err_way_early;
    reg  [3:0] ipa_cache_ecc_err_addr_early;
  
    // WALK cache ECC 
    // If there is an ECC error from looking up main TLB RAM (i.e. pagewalk_ecc_err_cmn)
    // WALK cache read and WALK cache ECC error are not generated
    assign next_walk_cache_ecc_err_early = pagewalk_state_walk_compare ?
                                            (walk_ipa_cache_ecc_err_i & ~pagewalk_ecc_err_cmn & pagewalk_mmuon) :
                                            (walk_cache_ecc_err_early & ~pagewalk_state_idle);
  
    assign next_walk_cache_ecc_err_way_early = pagewalk_state_walk_compare ? walk_ipa_cache_ecc_err_way_i :
                                                                             walk_cache_ecc_err_way_early;
  
    // WALK cache ECC error is reset because if there was main TLB ECC error
    // WALK cache is not read, and it is checked before checking main
    // TLB ECC error
    always @(posedge clk_pagewalk or negedge reset_n)
    if (~reset_n) begin
      walk_cache_ecc_err_early <= 1'b0;
    end else begin
      walk_cache_ecc_err_early <= next_walk_cache_ecc_err_early;
    end
  
    always @(posedge clk_pagewalk)
    if (pagewalk_state_en) begin
      walk_cache_ecc_err_way_early <= next_walk_cache_ecc_err_way_early;
    end
  
    assign walk_cache_ecc_err     = walk_cache_ecc_err_early;
    assign walk_cache_ecc_err_way = walk_cache_ecc_err_way_early;
  
    // IPA cache ECC 
    assign next_ipa_cache_ecc_err_early = (pagewalk_state_ipa_compare & ~ipa_cache_ecc_err_early) ?
                                           (walk_ipa_cache_ecc_err_i & ~pagewalk_ecc_err_cmn) :
                                           (ipa_cache_ecc_err_early & ~pagewalk_state_idle);
  
    assign next_ipa_cache_ecc_err_way_early = (pagewalk_state_ipa_compare & ~ipa_cache_ecc_err_early) ? 
                                                                         walk_ipa_cache_ecc_err_way_i :
                                                                         ipa_cache_ecc_err_way_early;
  
    assign next_ipa_cache_ecc_err_addr_early =  pagewalk_state_ipa_compare ? walk_ipa_ecc_err_addr_i[3:0]:
                                                                             ipa_cache_ecc_err_addr_early;
  
    always @(posedge clk_pagewalk or negedge reset_n)
    if (~reset_n) begin
      ipa_cache_ecc_err_early <= 1'b0;
    end else begin
      ipa_cache_ecc_err_early <= next_ipa_cache_ecc_err_early; 
    end
  
    always @(posedge clk_pagewalk)
    if (pagewalk_state_en) begin
      ipa_cache_ecc_err_way_early  <= next_ipa_cache_ecc_err_way_early;
      ipa_cache_ecc_err_addr_early <= next_ipa_cache_ecc_err_addr_early;
    end
  
    assign ipa_cache_ecc_err      = ipa_cache_ecc_err_early;
    assign ipa_cache_ecc_err_way  = ipa_cache_ecc_err_way_early;
    assign ipa_cache_ecc_err_addr = ipa_cache_ecc_err_addr_early;
  
    // Support for ECC reporting
    assign tlb_pty_valid_non_cp_cmn = pagewalk_ram_pri_i & 
                                       ((pagewalk_state_tlb_write  & pagewalk_ecc_err_cmn) |
                                        (pagewalk_state_walk_write & walk_cache_ecc_err) |
                                        (pagewalk_state_ipa_write  & ipa_cache_ecc_err));
  
  end else begin : g_protection_stubs_pw6
  
    assign walk_cache_ecc_err       = 1'b0;
    assign walk_cache_ecc_err_way   = 4'h0;
    assign ipa_cache_ecc_err        = 1'b0;
    assign ipa_cache_ecc_err_way    = 4'h0;
    assign ipa_cache_ecc_err_addr   = 4'h0;
    // Support for ECC reporting
    assign tlb_pty_valid_non_cp_cmn = 1'b0;
  
  end endgenerate

  assign tlb_pty_valid_non_cp_o = tlb_pty_valid_non_cp_cmn;

  //---------------------------------------------------------------------------
  // RAM Data Write
  //---------------------------------------------------------------------------

  generate if (CPU_CACHE_PROTECTION) begin : g_protection_pw7
    assign pagewalk_ram_wr_data_o = (({117{pagewalk_state_tlb_write}}  & tlb_ram_wr_data ) |
                                     ({117{pagewalk_state_walk_write}} & walk_ram_wr_data) |
                                     ({117{pagewalk_state_ipa_write}}  & ipa_ram_wr_data ));
  end else begin : g_protection_stubs_pw7
    assign pagewalk_ram_wr_data_o = (({114{pagewalk_state_tlb_write}}  & tlb_ram_wr_data ) |
                                     ({114{pagewalk_state_walk_write}} & walk_ram_wr_data) |
                                     ({114{pagewalk_state_ipa_write}}  & ipa_ram_wr_data ));
  end endgenerate

  // Suppress the walk cache hit if stage1 is not enabled.
  assign pagewalk_enable_walk_compare_o = pagewalk_state_walk_compare & pagewalk_mmuon;

  // Update the hitmap and lookup size ordering logic with the size of this page.
  assign pagewalk_hitmap_update_iside_o = pagewalk_ram_written & pagewalk_iside;
  assign pagewalk_hitmap_update_dside_o = pagewalk_ram_written & ~pagewalk_iside;
  assign pagewalk_hitmap_size_o = {combined_page_size_ext, pagewalk_lpae};

  // Indicate to the lookup block that the main TLB now contains an entry where
  // the size is smaller than the original stage1 size.
  assign pagewalk_size_reduced_o = pagewalk_ram_written & (combined_page_size != stage1_page_size);

  //------------------------------------------------------------------------------
  // Output alias assignments
  //------------------------------------------------------------------------------

  // Outputs back to the lookup block.
  assign pagewalk_state_idle_o = pagewalk_state_idle;
  assign pagewalk_busy_iside_o = ~(pagewalk_state_idle | pagewalk_abandoned) & pagewalk_iside;
  assign pagewalk_busy_dside_o = ~(pagewalk_state_idle | pagewalk_abandoned) & ~pagewalk_iside;

  assign pagewalk_ns_o      = pagewalk_ns;
  assign pagewalk_lpae_o    = pagewalk_lpae;
  assign pagewalk_hyp_o     = pagewalk_exception_level2;
  assign pagewalk_a64_o     = pagewalk_a64;
  assign pagewalk_va_sign_o = pagewalk_va[48];
  assign pagewalk_vmid_o    = pagewalk_vmid;

  assign pagewalk_aarch64_at_el3_o  = pagewalk_aarch64_at_el[3];
  assign pagewalk_exception_level_o = pagewalk_exception_level;

  // Event outputs
  assign tlb_evnt_data_pagewalk_o  = pagewalk_ram_written & ~pagewalk_iside;
  assign tlb_evnt_instr_pagewalk_o = pagewalk_ram_written &  pagewalk_iside;

  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  assert_always #(`OVL_FATAL,`OVL_ASSERT,"The TLB Pagewalk state machine is in an illegal state")
  u_ovl_pagewalk_valid_state (.clk            (clk),
                              .reset_n        (reset_n),
                              .test_expr      ((pagewalk_state == `CA53_PAGEWALK_ST_IDLE) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_LOOKUP_M0) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_LOOKUP_M1) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_LOOKUP_M2) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_LOOKUP_M3) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_BIU_LF_REQ) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_BIU_LF_HZ) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_PROCESS) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_WALK_LOOKUP) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_WALK_COMPARE) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_WALK_WAIT) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_WALK_WRITE) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_IPA_LOOKUP) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_IPA_COMPARE) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_IPA_WRITE) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_TLB_WRITE) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_BIU_NC_REQ) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_TLB_WRITE0) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_WALK_WRITE0) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_IPA_WRITE0)  |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_IPA_WAIT)));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT, "start_pagewalk_i should only be asserted if the pagewalk is idle")
  u_ovl_new_pagewalk_in_idle (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (start_pagewalk_i),
                              .consequent_expr (pagewalk_state == `CA53_PAGEWALK_ST_IDLE));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT, "All Hyp pagewalks must be non-secure")
  u_ovl_hyp_is_ns (.clk             (clk),
                   .reset_n         (reset_n),
                   .antecedent_expr ((pagewalk_state != `CA53_PAGEWALK_ST_IDLE) & pagewalk_exception_level2),
                   .consequent_expr (pagewalk_ns));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT, "A non-secure pagewalk must result in a non-secure translation")
  u_ovl_ns_result_ns1 (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (((pagewalk_state != `CA53_PAGEWALK_ST_IDLE) &
                                          (pagewalk_state != `CA53_PAGEWALK_ST_WALK_LOOKUP) &
                                          (pagewalk_state != `CA53_PAGEWALK_ST_WALK_COMPARE) &
                                          (pagewalk_state != `CA53_PAGEWALK_ST_WALK_WAIT)) & ~walk_cache_ecc_err & pagewalk_ns),
                       .consequent_expr (stage1_ns));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT, "A non-secure pagewalk must result in a non-secure translation")
  u_ovl_ns_result_ns2 (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (((pagewalk_state != `CA53_PAGEWALK_ST_IDLE) &
                                          (pagewalk_state != `CA53_PAGEWALK_ST_WALK_LOOKUP) &
                                          (pagewalk_state != `CA53_PAGEWALK_ST_WALK_COMPARE)) & ~walk_cache_ecc_err & pagewalk_ns),
                       .consequent_expr (next_stage1_ns));


  assert_implication #(`OVL_FATAL,`OVL_ASSERT, "Once a pagewalk has gone non-secure is must remain so")
  u_ovl_ns_remains_set (.clk             (clk),
                        .reset_n         (reset_n),
                        .antecedent_expr (((pagewalk_state != `CA53_PAGEWALK_ST_IDLE) &
                                           (pagewalk_state != `CA53_PAGEWALK_ST_WALK_LOOKUP) &
                                           (pagewalk_state != `CA53_PAGEWALK_ST_WALK_COMPARE) &
                                           (pagewalk_state != `CA53_PAGEWALK_ST_WALK_WAIT)) & stage1_ns),
                        .consequent_expr (next_stage1_ns));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT, "A non-secure pagewalk must always fetch from non-secure memory")
  u_ovl_ns_fetch1 (.clk             (clk),
                   .reset_n         (reset_n),
                   .antecedent_expr (((pagewalk_state == `CA53_PAGEWALK_ST_BIU_NC_REQ) |
                                      (pagewalk_state == `CA53_PAGEWALK_ST_BIU_LF_REQ) |
                                      (pagewalk_state == `CA53_PAGEWALK_ST_BIU_LF_HZ)) & pagewalk_ns),
                   .consequent_expr (pagewalk_ns_dsc));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT, "A non-secure fetch must always result in a non-secure translation")
  u_ovl_ns_fetch2 (.clk             (clk),
                   .reset_n         (reset_n),
                   .antecedent_expr (((pagewalk_state == `CA53_PAGEWALK_ST_BIU_NC_REQ) |
                                      (pagewalk_state == `CA53_PAGEWALK_ST_BIU_LF_REQ) |
                                      (pagewalk_state == `CA53_PAGEWALK_ST_BIU_LF_HZ)) & pagewalk_ns_dsc),
                   .consequent_expr (stage1_ns));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT, "A non-secure LPAE pagewalk must always fetch from non-secure memory")
  u_ovl_ns_fetch3 (.clk             (clk),
                   .reset_n         (reset_n),
                   .antecedent_expr (((pagewalk_state == `CA53_PAGEWALK_ST_BIU_NC_REQ) |
                                      (pagewalk_state == `CA53_PAGEWALK_ST_BIU_LF_REQ) |
                                      (pagewalk_state == `CA53_PAGEWALK_ST_BIU_LF_HZ)) &
                                     pagewalk_lpae & ~pagewalk_abandoned & stage1_ns),
                   .consequent_expr (pagewalk_ns_dsc));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT, "LPAE fetches must be doubleword aligned")
  u_ovl_lpae_doubleword (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (((pagewalk_state == `CA53_PAGEWALK_ST_BIU_NC_REQ) |
                                            (pagewalk_state == `CA53_PAGEWALK_ST_BIU_LF_REQ) |
                                            (pagewalk_state == `CA53_PAGEWALK_ST_BIU_LF_HZ)) &
                                           pagewalk_lpae & ~pagewalk_abandoned),
                         .consequent_expr (pagewalk_addr[2] == 1'b0));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT, "BIU NC req with dcache off should have NC attributes")
  u_ovl_biu_nc_req_attr (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (tlb_walk_nc_req_o &
                                           ~abandon_pagewalk &
                                           ~(`CA53_MEM_DEVICE(tlb_walk_attrs_o)) &
                                           ((~dpu_dcache_on & pagewalk_stage2_level[2]) |
                                            (~dpu_s2_dcache_on_i & ~pagewalk_stage2_level[2]))),
                         .consequent_expr (tlb_walk_attrs_o == `CA53_PAGE_INNER_NC_OUTER_NC_SHARE_OS));

  reg [1:0] ovl_pagewalk_data_valid;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ovl_pagewalk_data_valid <= 2'b00;
  end else if ((pagewalk_state != `CA53_PAGEWALK_ST_PROCESS) &
               (next_pagewalk_state == `CA53_PAGEWALK_ST_PROCESS)) begin
    ovl_pagewalk_data_valid <= {current_fetch_lpae, 1'b1};
  end

  assert_win_unchange #(`OVL_FATAL, 32, `OVL_ASSERT, "pagewalk_data must remain constant while it is being used")
  u_ovl_pagewalk_data_constant1 (.clk         (clk),
                                 .reset_n     (reset_n),
                                 .start_event ((pagewalk_state == `CA53_PAGEWALK_ST_PROCESS) &
                                               ((next_pagewalk_state == `CA53_PAGEWALK_ST_IPA_WRITE) |
                                                (next_pagewalk_state == `CA53_PAGEWALK_ST_TLB_WRITE)) &
                                               (pagewalk_level != 3'b111) &
                                               ovl_pagewalk_data_valid[0]),
                                 .test_expr   (pagewalk_data[31:0]),
                                 .end_event   ((next_pagewalk_state != `CA53_PAGEWALK_ST_IPA_WRITE) &
                                               (next_pagewalk_state != `CA53_PAGEWALK_ST_TLB_WRITE)));

  assert_win_unchange #(`OVL_FATAL, 32, `OVL_ASSERT, "pagewalk_data must remain constant while it is being used")
  u_ovl_pagewalk_data_constant2 (.clk         (clk),
                                 .reset_n     (reset_n),
                                 .start_event ((pagewalk_state == `CA53_PAGEWALK_ST_PROCESS) &
                                               ((next_pagewalk_state == `CA53_PAGEWALK_ST_IPA_WRITE) |
                                                (next_pagewalk_state == `CA53_PAGEWALK_ST_TLB_WRITE)) &
                                               (pagewalk_level != 3'b111) &
                                               ovl_pagewalk_data_valid[1]),
                                 .test_expr   (pagewalk_data[63:32]),
                                 .end_event   ((next_pagewalk_state != `CA53_PAGEWALK_ST_IPA_WRITE) &
                                               (next_pagewalk_state != `CA53_PAGEWALK_ST_TLB_WRITE)));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT, "Cannot use both TTBRs at the same time")
  u_ovl_both_ttbrs (.clk             (clk),
                    .reset_n         (reset_n),
                    .antecedent_expr ((pagewalk_state != `CA53_PAGEWALK_ST_IDLE)),
                    .consequent_expr (~(pagewalk_use_ttbr0 & pagewalk_use_ttbr1)));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT, "Must have ram priority when in ipa compare state")
  u_ovl_ram_pri_ipa_compare (.clk             (clk),
                             .reset_n         (reset_n),
                             .antecedent_expr (pagewalk_state == `CA53_PAGEWALK_ST_IPA_COMPARE),
                             .consequent_expr (pagewalk_ram_pri_i));

  wire [3:0] ovl_size_order_set = ((1'b1 << full_ipa_size_order[7:6]) |
                                   (1'b1 << full_ipa_size_order[5:4]) |
                                   (1'b1 << full_ipa_size_order[3:2]) |
                                   (1'b1 << full_ipa_size_order[1:0]));

  assert_always #(`OVL_FATAL,`OVL_ASSERT, "full_ipa_size_order contains exactly one entry for each size")
  u_ovl_ipa_size_unique (.clk       (clk),
                         .reset_n   (reset_n),
                         .test_expr (ovl_size_order_set == 4'b1111));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT, "Invalidated pagewalks must not access the RAM")
  u_ovl_invalidate_no_ram (.clk             (clk),
                           .reset_n         (reset_n),
                           .antecedent_expr (pagewalk_invalidated),
                           .consequent_expr (~pagewalk_ram_req));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT, "Pagewalk cannot be invalidated at the start")
  u_ovl_invalidated_idle (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (pagewalk_state_walk_lookup),
                          .consequent_expr (~pagewalk_invalidated));

  assert_always #(`OVL_FATAL,`OVL_ASSERT, "The registered pagewalk_ram_req must be the same as if calculated combinatorially")
  u_ovl_pagewalk_ram_req (.clk       (clk),
                          .reset_n   (reset_n),
                          .test_expr (pagewalk_ram_req == (pagewalk_state_tlb_write |
                                                           (pagewalk_state_walk_lookup & pagewalk_mmuon & ~pagewalk_ecc_err_cmn) |
                                                           pagewalk_state_walk_write |
                                                           pagewalk_state_ipa_lookup |
                                                           (pagewalk_state_ipa_compare & |ipa_size_remaining) |
                                                           pagewalk_state_ipa_write)));


  // X checks on signals used in if statements

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "start_pagewalk_i should never be X in IDLE state when PW starts")
  u_ovl_x_start_pagewalk_i (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (start_pagewalk_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pagewalk_ram_wr_ack_i should never be X in IDLE state when PW starts")
  u_ovl_x_pagewalk_ram_wr_ack_i (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (start_pagewalk_i),
                                 .test_expr (pagewalk_ram_written));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "abandon_pagewalk should never be X")
  u_ovl_x_abandon_pagewalk (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (abandon_pagewalk));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "a32_pagewalk_disable should never be X in IDLE state when PW starts")
  u_ovl_x_a32_pagewalk_disable (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier ((pagewalk_state == `CA53_PAGEWALK_ST_PROCESS) & pagewalk_a32),
                                .test_expr (a32_pagewalk_disable));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "a32_pagewalk_disable_out_addr should never be X in IDLE state when PW starts")
  u_ovl_x_a32_pagewalk_disable_out_addr (.clk       (clk),
                                         .reset_n   (reset_n),
                                         .qualifier ((pagewalk_state == `CA53_PAGEWALK_ST_PROCESS) & pagewalk_a32),
                                         .test_expr (a32_pagewalk_disable_out_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "a64_pagewalk_disable should never be X in IDLE state when PW starts")
  u_ovl_x_a64_pagewalk_disable (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier ((pagewalk_state == `CA53_PAGEWALK_ST_PROCESS) & pagewalk_a64),
                                .test_expr (a64_pagewalk_disable));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "a64_pagewalk_disable_out_addr should never be X in IDLE state when PW starts")
  u_ovl_x_a64_pagewalk_disable_out_addr (.clk       (clk),
                                         .reset_n   (reset_n),
                                         .qualifier ((pagewalk_state == `CA53_PAGEWALK_ST_PROCESS) & pagewalk_a64),
                                         .test_expr (a64_pagewalk_disable_out_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "biu_walk_lf_hazard should never be X in lookup/lf states")
  u_ovl_x_biu_walk_lf_hazard (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier ((pagewalk_state == `CA53_PAGEWALK_ST_LOOKUP_M0) |
                                          (pagewalk_state == `CA53_PAGEWALK_ST_LOOKUP_M2) |
                                          (pagewalk_state == `CA53_PAGEWALK_ST_BIU_LF_REQ) |
                                          (pagewalk_state == `CA53_PAGEWALK_ST_BIU_LF_HZ)),
                              .test_expr (biu_walk_lf_hazard_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "ipa_cache_previous_hit should never be X")
  u_ovl_x_ipa_cache_previous_hit (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (pagewalk_state == `CA53_PAGEWALK_ST_PROCESS),
                                  .test_expr (ipa_cache_previous_hit));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pagewalk_abort should never be X")
  u_ovl_x_pagewalk_abort (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (pagewalk_state == `CA53_PAGEWALK_ST_PROCESS),
                          .test_expr (pagewalk_abort));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "start_stage2_translation should never be X")
  u_ovl_x_start_stage2_translation (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier ((pagewalk_state == `CA53_PAGEWALK_ST_PROCESS) |
                                                (pagewalk_state == `CA53_PAGEWALK_ST_WALK_WAIT)),
                                    .test_expr (start_stage2_translation));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "next_stage2_a32_pagewalk_disable should never be X")
  u_ovl_x_stage2_pagewalk_disable (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (pagewalk_state == `CA53_PAGEWALK_ST_PROCESS),
                                   .test_expr (next_stage2_a32_pagewalk_disable));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "stage2_translation_complete should never be X")
  u_ovl_x_stage2_translation_complete (.clk       (clk),
                                       .reset_n   (reset_n),
                                       .qualifier (pagewalk_state == `CA53_PAGEWALK_ST_PROCESS),
                                       .test_expr (stage2_translation_complete));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "stage2_translation_required should never be X")
  u_ovl_x_stage2_translation_required (.clk       (clk),
                                       .reset_n   (reset_n),
                                       .qualifier ((pagewalk_state == `CA53_PAGEWALK_ST_PROCESS) |
                                                   (pagewalk_state == `CA53_PAGEWALK_ST_WALK_WAIT)),
                                       .test_expr (stage2_translation_required));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pagewalk_req_dropped should never be X")
  u_ovl_x_pagewalk_req_dropped (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (pagewalk_state != `CA53_PAGEWALK_ST_IDLE),
                                .test_expr (pagewalk_req_dropped));

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "ipa_cache_hit_way_i should never be X")
  u_ovl_x_ipa_cache_hit_way_i (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (pagewalk_state == `CA53_PAGEWALK_ST_IPA_COMPARE),
                               .test_expr (ipa_cache_hit_way_i));

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "ipa_size_valid should never be X")
  u_ovl_x_ipa_size_valid (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier ((pagewalk_state == `CA53_PAGEWALK_ST_IPA_LOOKUP) |
                                      (pagewalk_state == `CA53_PAGEWALK_ST_IPA_COMPARE)),
                          .test_expr (ipa_size_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "another_fetch_required should never be X")
  u_ovl_x_another_fetch_required (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier ((pagewalk_state == `CA53_PAGEWALK_ST_PROCESS) |
                                              (pagewalk_state == `CA53_PAGEWALK_ST_IPA_WRITE)),
                                  .test_expr (another_fetch_required));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pagewalk_ram_pri_i should never be X")
  u_ovl_x_pagewalk_ram_pri_i (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (pagewalk_ram_pri_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "next_any_pagewalk_disable should never be X")
  u_ovl_x_next_any_pagewalk_disable (.clk       (clk),
                                     .reset_n   (reset_n),
                                     .qualifier (pagewalk_state == `CA53_PAGEWALK_ST_WALK_WAIT),
                                     .test_expr (next_any_pagewalk_disable));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pagewalk_mmuon should never be X")
  u_ovl_x_pagewalk_mmuon (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (pagewalk_state != `CA53_PAGEWALK_ST_IDLE),
                          .test_expr (pagewalk_mmuon));


  assert_never_unknown #(`OVL_FATAL, 8, `OVL_ASSERT, "pagewalk_attrs should never be X")
  u_ovl_x_pagewalk_attrs (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier ((pagewalk_state == `CA53_PAGEWALK_ST_WALK_WRITE) |
                                      (pagewalk_state == `CA53_PAGEWALK_ST_IPA_COMPARE) |
                                      ((pagewalk_state == `CA53_PAGEWALK_ST_WALK_WAIT) &
                                        ~(pagewalk_ecc_err_cmn |
                                          next_any_pagewalk_disable |
                                          (~pagewalk_mmuon & ~stage2_translation_required) |
                                          ( stage2_translation_required & mmuoff_fault_out_addr)) &
                                       ~start_stage2_translation &
                                       ~start_stage1_translation)),
                          .test_expr (pagewalk_attrs));

  assert_never_unknown #(`OVL_FATAL, 8, `OVL_ASSERT, "next_pagewalk_attrs should never be X")
  u_ovl_x_next_pagewalk_attrs (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (((pagewalk_state == `CA53_PAGEWALK_ST_WALK_WAIT) &
                                            ~pagewalk_req_dropped & ~abandon_pagewalk &
                                            ~next_any_pagewalk_disable &
                                            ~(~pagewalk_mmuon & ~stage2_translation_required) &
                                            ~start_stage2_translation) |
                                           ((pagewalk_state == `CA53_PAGEWALK_ST_PROCESS) &
                                            ~abandon_pagewalk &
                                            ~(stage2_translation_complete & ~pagewalk_abort &
                                              ~ipa_cache_previous_hit) &
                                            another_fetch_required & ~start_stage2_translation &
                                            ~((stage2_translation_complete | ~stage2_translation_required) &
                                              ~stage1_translation_complete &
                                              (pagewalk_lpae ? (pagewalk_stage1_level == 3'b010) :
                                                               (pagewalk_stage1_level == 3'b001)))) |
                                           ((pagewalk_state == `CA53_PAGEWALK_ST_IPA_WRITE) &
                                            ~abandon_pagewalk & pagewalk_ram_pri_i &
                                            ~((pagewalk_lpae ? (pagewalk_stage1_level == 3'b010) :
                                                               (pagewalk_stage1_level == 3'b001)) &
                                              ~stage1_translation_completed) & another_fetch_required)),
                               .test_expr (next_pagewalk_attrs));

  assert_never_unknown #(`OVL_FATAL, 8, `OVL_ASSERT, "combined_attrs should never be X")
  u_ovl_x_combined_attrs (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (((pagewalk_state == `CA53_PAGEWALK_ST_PROCESS) &
                                       ~(stage2_translation_complete & ~pagewalk_abort &
                                         ~pagewalk_invalidated & ~ipa_cache_previous_hit) &
                                       another_fetch_required &
                                       ~(start_stage2_translation & ~pagewalk_invalidated) &
                                       ~(((stage2_translation_complete | ~stage2_translation_required) &
                                          ~stage1_translation_complete &
                                          (pagewalk_lpae ? (pagewalk_stage1_level == 3'b010) :
                                                           (pagewalk_stage1_level == 3'b001))) &
                                         ~pagewalk_invalidated)) |
                                      (pagewalk_state == `CA53_PAGEWALK_ST_IPA_WRITE) |
                                      ((pagewalk_state == `CA53_PAGEWALK_ST_WALK_WAIT) &
                                       ~(next_any_pagewalk_disable |
                                         (~pagewalk_mmuon & ~stage2_translation_required)) &
                                       ~start_stage2_translation &
                                       start_stage1_translation)),
                                      .test_expr (combined_attrs));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "stage1_translation_complete should never be X")
  u_ovl_x_stage1_translation_complete (.clk       (clk),
                                       .reset_n   (reset_n),
                                       .qualifier ((pagewalk_state == `CA53_PAGEWALK_ST_PROCESS) &
                                                   another_fetch_required),
                                       .test_expr (stage1_translation_complete));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pagewalk_lpae should never be X")
  u_ovl_x_pagewalk_lpae (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (pagewalk_state != `CA53_PAGEWALK_ST_IDLE),
                         .test_expr (pagewalk_lpae));

  assert_never_unknown #(`OVL_FATAL, 3, `OVL_ASSERT, "pagewalk_stage1_level should never be X")
  u_ovl_x_pagewalk_stage1_level (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (pagewalk_state != `CA53_PAGEWALK_ST_IDLE),
                                 .test_expr (pagewalk_stage1_level));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pagewalk_ns should never be X")
  u_ovl_x_pagewalk_ns (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (pagewalk_state != `CA53_PAGEWALK_ST_IDLE),
                       .test_expr (pagewalk_ns));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "pagewalk_exception_level should never be X")
  u_ovl_x_pagewalk_exp (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (pagewalk_state != `CA53_PAGEWALK_ST_IDLE),
                         .test_expr (pagewalk_exception_level));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pagewalk_v2p_ipa should never be X")
  u_ovl_x_pagewalk_v2p_ipa (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (pagewalk_state != `CA53_PAGEWALK_ST_IDLE),
                            .test_expr (pagewalk_v2p_ipa));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "start_stage1_translation should never be X")
  u_ovl_x_start_stage1_translation (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (pagewalk_state == `CA53_PAGEWALK_ST_WALK_WAIT),
                                    .test_expr (start_stage1_translation));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pagewalk_invalidated should never be X")
  u_ovl_x_pagewalk_invalidated (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (pagewalk_state == `CA53_PAGEWALK_ST_PROCESS),
                                .test_expr (pagewalk_invalidated));

  assert_never_unknown #(`OVL_FATAL, 3, `OVL_ASSERT, "ipa_size_remaining should never be X")
  u_ovl_x_ipa_size_remaining (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (pagewalk_state == `CA53_PAGEWALK_ST_IPA_COMPARE),
                              .test_expr (ipa_size_remaining));

  assert_never_unknown #(`OVL_FATAL, 3, `OVL_ASSERT, "next_ipa_size_remaining should never be X")
  u_ovl_x_next_ipa_size_remaining (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier ((pagewalk_state == `CA53_PAGEWALK_ST_IPA_LOOKUP) |
                                               (pagewalk_state == `CA53_PAGEWALK_ST_IPA_COMPARE)),
                                   .test_expr (next_ipa_size_remaining));

  assert_never_unknown #(`OVL_FATAL, `CA53_PAGEWALK_ST_WIDTH, `OVL_ASSERT, "pagewalk_state should never be X")
  u_ovl_x_pagewalk_state (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (pagewalk_state));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ipa_master_hitmap_en")
  u_ovl_x_ipa_master_hitmap_en (.clk       (clk_pagewalk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (ipa_master_hitmap_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ipa_size_en")
  u_ovl_x_ipa_size_en (.clk       (clk_pagewalk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (ipa_size_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ipa_size_order_en")
  u_ovl_x_ipa_size_order_en (.clk       (clk_pagewalk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (ipa_size_order_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ipa_victim_ways_en")
  u_ovl_x_ipa_victim_ways_en (.clk       (clk_pagewalk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (ipa_victim_ways_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pagewalk_addr_en")
  u_ovl_x_pagewalk_addr_en (.clk       (clk_pagewalk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (pagewalk_addr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pagewalk_data_en")
  u_ovl_x_pagewalk_data_en (.clk       (clk_pagewalk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (pagewalk_data_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pagewalk_level_en")
  u_ovl_x_pagewalk_level_en (.clk       (clk_pagewalk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (pagewalk_level_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pagewalk_state_en")
  u_ovl_x_pagewalk_state_en (.clk       (clk_pagewalk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (pagewalk_state_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: stage1_en")
  u_ovl_x_stage1_en (.clk       (clk_pagewalk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (stage1_en));

 assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "dcu_cache_walk_has_priority_m0_i should never be X")
  u_ovl_x_dcu_cache_walk_has_priority_m0_i (.clk       (clk),
                                            .reset_n   (reset_n),
                                            .qualifier (pagewalk_state == `CA53_PAGEWALK_ST_LOOKUP_M0),
                                            .test_expr (dcu_cache_walk_has_priority_m0_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "dcu_cache_walk_ack_m1_i should never be X")
  u_ovl_x_dcu_cache_walk_ack_m1_i (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (pagewalk_state == `CA53_PAGEWALK_ST_LOOKUP_M1),
                                   .test_expr (dcu_cache_walk_ack_m1_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "dcu_cache_walk_hit_m2_i should never be X")
  u_ovl_x_dcu_cache_walk_hit_m2_i (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (pagewalk_state == `CA53_PAGEWALK_ST_LOOKUP_M2),
                                   .test_expr (dcu_cache_walk_hit_m2_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "next_any_stage2_pagewalk_disable should never be X")
  u_ovl_x_next_any_stage2_pagewalk_disable (.clk       (clk),
                                            .reset_n   (reset_n),
                                            .qualifier (pagewalk_state == `CA53_PAGEWALK_ST_PROCESS),
                                            .test_expr (next_any_stage2_pagewalk_disable));

`endif



endmodule // ca53tlb_pagewalk

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

