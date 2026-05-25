//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2013-2015 ARM Limited.
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

// This is the specification for the interface between the DPU and TLB

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_dpu_tlb_defs.v"
`include "cortexa53params.v"
`include "cortexa53params.v"

module ca53_dpu_tlb #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         tlb_d_utlb_flush_i,
  input         tlb_d_utlb_enable_i,
  input         tlb_d_utlb_might_enable_i,
  input         tlb_d_utlb_lpae_i,
  input         tlb_d_utlb_valid_i,
  input  [95:0] tlb_d_utlb_data_i,
  input         tlb_lpae_mode_i,
  input         tlb_lpae_mode_s_i,
  input   [1:0] tlb_d_tcr_el1_tbi_i,
  input         tlb_d_tcr_el2_tbi0_i,
  input         tlb_d_tcr_el3_tbi0_i,
  input  [31:0] tlb_dbg_rdata_i,
  input         tlb_evnt_data_pagewalk_i,
  input         tlb_evnt_instr_pagewalk_i,
  input         tlb_pty_valid_i,
  input   [1:0] tlb_pty_way_bank_id_i,
  input   [7:0] tlb_pty_index_i,
  input  [63:0] dpu_va_dc1_i,
  input         dpu_utlb_hit_dc1_i,
  input         dpu_tlb_abandon_i,
  input         dpu_scr_el3_ns_i,
  input         dpu_ns_state_i,
  input         dpu_mmu_on_el1_i,
  input         dpu_mmu_on_el2_i,
  input         dpu_mmu_on_el3_i,
  input         dpu_dcache_on_el1_i,
  input         dpu_dcache_on_el2_i,
  input         dpu_dcache_on_el3_i,
  input         dpu_icache_on_i,
  input         dpu_sctlr_uwxn_el3_i,
  input         dpu_sctlr_uwxn_el1_i,
  input         dpu_sctlr_wxn_el3_i,
  input         dpu_sctlr_wxn_el1_i,
  input         dpu_sctlr_wxn_el2_i,
  input         dpu_access_flag_enable_el3_i,
  input         dpu_access_flag_enable_el1_i,
  input         dpu_tex_remap_enable_el3_i,
  input         dpu_tex_remap_enable_el1_i,
  input         dpu_endian_el3_i,
  input         dpu_endian_el1_i,
  input         dpu_endian_el2_i,
  input         dpu_hivecs_i,
  input   [3:0] dpu_dbg_vid_i,
  input         dpu_s2_dcache_on_i,
  input  [31:5] dpu_vec_base_s_dc1_i,
  input  [31:5] dpu_vec_base_ns_dc1_i,
  input  [31:5] dpu_mon_vec_base_dc1_i,
  input   [4:0] dpu_mode_iss_i,
  input   [1:0] dpu_exception_level_i,
  input   [3:1] dpu_aarch64_at_el_i,
  input         dpu_dbg_tlb_sw_bkpt_wpt_en_i,
  input         dpu_dbg_tlb_hw_bkpt_wpt_en_i,
  input         dpu_dbg_sample_contextid_i,
  input         dpu_default_cacheable_i,
  input         dpu_ipa_to_pa_en_i,
  input         dpu_pr_tablewalk_i,
  input         dpu_apb_active_i,
  input         dpu_dbg_wr_i,
  input  [11:2] dpu_dbg_addr_i,
  input  [31:0] dpu_dbg_wdata_i);


  wire         tlb_d_utlb_flush = tlb_d_utlb_flush_i;
  wire         tlb_d_utlb_enable = tlb_d_utlb_enable_i;
  wire         tlb_d_utlb_might_enable = tlb_d_utlb_might_enable_i;
  wire         tlb_d_utlb_lpae = tlb_d_utlb_lpae_i;
  wire         tlb_d_utlb_valid = tlb_d_utlb_valid_i;
  wire  [95:0] tlb_d_utlb_data = tlb_d_utlb_data_i;
  wire         tlb_lpae_mode = tlb_lpae_mode_i;
  wire         tlb_lpae_mode_s = tlb_lpae_mode_s_i;
  wire   [1:0] tlb_d_tcr_el1_tbi = tlb_d_tcr_el1_tbi_i;
  wire         tlb_d_tcr_el2_tbi0 = tlb_d_tcr_el2_tbi0_i;
  wire         tlb_d_tcr_el3_tbi0 = tlb_d_tcr_el3_tbi0_i;
  wire  [31:0] tlb_dbg_rdata = tlb_dbg_rdata_i;
  wire         tlb_evnt_data_pagewalk = tlb_evnt_data_pagewalk_i;
  wire         tlb_evnt_instr_pagewalk = tlb_evnt_instr_pagewalk_i;
  wire         tlb_pty_valid = tlb_pty_valid_i;
  wire   [1:0] tlb_pty_way_bank_id = tlb_pty_way_bank_id_i;
  wire   [7:0] tlb_pty_index = tlb_pty_index_i;
  wire  [63:0] dpu_va_dc1 = dpu_va_dc1_i;
  wire         dpu_utlb_hit_dc1 = dpu_utlb_hit_dc1_i;
  wire         dpu_tlb_abandon = dpu_tlb_abandon_i;
  wire         dpu_scr_el3_ns = dpu_scr_el3_ns_i;
  wire         dpu_ns_state = dpu_ns_state_i;
  wire         dpu_mmu_on_el1 = dpu_mmu_on_el1_i;
  wire         dpu_mmu_on_el2 = dpu_mmu_on_el2_i;
  wire         dpu_mmu_on_el3 = dpu_mmu_on_el3_i;
  wire         dpu_dcache_on_el1 = dpu_dcache_on_el1_i;
  wire         dpu_dcache_on_el2 = dpu_dcache_on_el2_i;
  wire         dpu_dcache_on_el3 = dpu_dcache_on_el3_i;
  wire         dpu_icache_on = dpu_icache_on_i;
  wire         dpu_sctlr_uwxn_el3 = dpu_sctlr_uwxn_el3_i;
  wire         dpu_sctlr_uwxn_el1 = dpu_sctlr_uwxn_el1_i;
  wire         dpu_sctlr_wxn_el3 = dpu_sctlr_wxn_el3_i;
  wire         dpu_sctlr_wxn_el1 = dpu_sctlr_wxn_el1_i;
  wire         dpu_sctlr_wxn_el2 = dpu_sctlr_wxn_el2_i;
  wire         dpu_access_flag_enable_el3 = dpu_access_flag_enable_el3_i;
  wire         dpu_access_flag_enable_el1 = dpu_access_flag_enable_el1_i;
  wire         dpu_tex_remap_enable_el3 = dpu_tex_remap_enable_el3_i;
  wire         dpu_tex_remap_enable_el1 = dpu_tex_remap_enable_el1_i;
  wire         dpu_endian_el3 = dpu_endian_el3_i;
  wire         dpu_endian_el1 = dpu_endian_el1_i;
  wire         dpu_endian_el2 = dpu_endian_el2_i;
  wire         dpu_hivecs = dpu_hivecs_i;
  wire   [3:0] dpu_dbg_vid = dpu_dbg_vid_i;
  wire         dpu_s2_dcache_on = dpu_s2_dcache_on_i;
  wire  [31:5] dpu_vec_base_s_dc1 = dpu_vec_base_s_dc1_i;
  wire  [31:5] dpu_vec_base_ns_dc1 = dpu_vec_base_ns_dc1_i;
  wire  [31:5] dpu_mon_vec_base_dc1 = dpu_mon_vec_base_dc1_i;
  wire   [4:0] dpu_mode_iss = dpu_mode_iss_i;
  wire   [1:0] dpu_exception_level = dpu_exception_level_i;
  wire   [3:1] dpu_aarch64_at_el = dpu_aarch64_at_el_i;
  wire         dpu_dbg_tlb_sw_bkpt_wpt_en = dpu_dbg_tlb_sw_bkpt_wpt_en_i;
  wire         dpu_dbg_tlb_hw_bkpt_wpt_en = dpu_dbg_tlb_hw_bkpt_wpt_en_i;
  wire         dpu_dbg_sample_contextid = dpu_dbg_sample_contextid_i;
  wire         dpu_default_cacheable = dpu_default_cacheable_i;
  wire         dpu_ipa_to_pa_en = dpu_ipa_to_pa_en_i;
  wire         dpu_pr_tablewalk = dpu_pr_tablewalk_i;
  wire         dpu_apb_active = dpu_apb_active_i;
  wire         dpu_dbg_wr = dpu_dbg_wr_i;
  wire  [11:2] dpu_dbg_addr = dpu_dbg_addr_i;
  wire  [31:0] dpu_dbg_wdata = dpu_dbg_wdata_i;

  wire         initialize_dpu_dbg;
  wire         dly_reset;
  wire         flush_utlb;
  wire   [7:0] mem_attrs;

  reg         dly_reset2;
  reg         dpu_tlb_abandon_dly;
  reg         dpu_dbg_held_reset_n;
  reg         out_of_reset;
  reg         dly_reset1;

  reg         dpu_mmu_on_el1_reg;
  reg         dpu_mmu_on_el3_reg;
  reg         dpu_dcache_on_el1_reg;
  reg         dpu_sctlr_uwxn_el1_reg;
  reg         dpu_mmu_on_el2_reg;
  reg         dpu_sctlr_wxn_el2_reg;
  reg         dpu_default_cacheable_reg;
  reg         dpu_access_flag_enable_el1_reg;
  reg         dpu_sctlr_uwxn_el3_reg;
  reg         dpu_s2_dcache_on_reg;
  reg         dpu_dcache_on_el3_reg;
  reg         dpu_sctlr_wxn_el1_reg;
  reg         out_of_reset_reg;
  reg         dpu_tlb_abandon_reg;
  reg         tlb_d_utlb_enable_reg;
  reg         dpu_tex_remap_enable_el1_reg;
  reg         dpu_ns_state_reg;
  reg         dpu_dcache_on_el2_reg;
  reg         dpu_tex_remap_enable_el3_reg;
  reg         dpu_sctlr_wxn_el3_reg;
  reg         dpu_endian_el1_reg;
  reg         dpu_pr_tablewalk_reg;
  reg         dpu_endian_el2_reg;
  reg         dpu_access_flag_enable_el3_reg;
  reg         dpu_ipa_to_pa_en_reg;
  reg         dpu_endian_el3_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    dpu_mmu_on_el1_reg <= 1'b0;
    dpu_mmu_on_el3_reg <= 1'b0;
    dpu_dcache_on_el1_reg <= 1'b0;
    dpu_sctlr_uwxn_el1_reg <= 1'b0;
    dpu_mmu_on_el2_reg <= 1'b0;
    dpu_sctlr_wxn_el2_reg <= 1'b0;
    dpu_default_cacheable_reg <= 1'b0;
    dpu_access_flag_enable_el1_reg <= 1'b0;
    dpu_sctlr_uwxn_el3_reg <= 1'b0;
    dpu_s2_dcache_on_reg <= 1'b0;
    dpu_dcache_on_el3_reg <= 1'b0;
    dpu_sctlr_wxn_el1_reg <= 1'b0;
    out_of_reset_reg <= 1'b0;
    dpu_tlb_abandon_reg <= 1'b0;
    tlb_d_utlb_enable_reg <= 1'b0;
    dpu_tex_remap_enable_el1_reg <= 1'b0;
    dpu_ns_state_reg <= 1'b0;
    dpu_dcache_on_el2_reg <= 1'b0;
    dpu_tex_remap_enable_el3_reg <= 1'b0;
    dpu_sctlr_wxn_el3_reg <= 1'b0;
    dpu_endian_el1_reg <= 1'b0;
    dpu_pr_tablewalk_reg <= 1'b0;
    dpu_endian_el2_reg <= 1'b0;
    dpu_access_flag_enable_el3_reg <= 1'b0;
    dpu_ipa_to_pa_en_reg <= 1'b0;
    dpu_endian_el3_reg <= 1'b0;
  end
  else
  begin
    tlb_d_utlb_enable_reg <= tlb_d_utlb_enable;
    dpu_tlb_abandon_reg <= dpu_tlb_abandon;
    dpu_ns_state_reg <= dpu_ns_state;
    dpu_mmu_on_el1_reg <= dpu_mmu_on_el1;
    dpu_mmu_on_el2_reg <= dpu_mmu_on_el2;
    dpu_mmu_on_el3_reg <= dpu_mmu_on_el3;
    dpu_dcache_on_el1_reg <= dpu_dcache_on_el1;
    dpu_dcache_on_el2_reg <= dpu_dcache_on_el2;
    dpu_dcache_on_el3_reg <= dpu_dcache_on_el3;
    dpu_sctlr_uwxn_el3_reg <= dpu_sctlr_uwxn_el3;
    dpu_sctlr_uwxn_el1_reg <= dpu_sctlr_uwxn_el1;
    dpu_sctlr_wxn_el3_reg <= dpu_sctlr_wxn_el3;
    dpu_sctlr_wxn_el1_reg <= dpu_sctlr_wxn_el1;
    dpu_sctlr_wxn_el2_reg <= dpu_sctlr_wxn_el2;
    dpu_access_flag_enable_el3_reg <= dpu_access_flag_enable_el3;
    dpu_access_flag_enable_el1_reg <= dpu_access_flag_enable_el1;
    dpu_tex_remap_enable_el3_reg <= dpu_tex_remap_enable_el3;
    dpu_tex_remap_enable_el1_reg <= dpu_tex_remap_enable_el1;
    dpu_endian_el3_reg <= dpu_endian_el3;
    dpu_endian_el1_reg <= dpu_endian_el1;
    dpu_endian_el2_reg <= dpu_endian_el2;
    dpu_s2_dcache_on_reg <= dpu_s2_dcache_on;
    dpu_default_cacheable_reg <= dpu_default_cacheable;
    dpu_ipa_to_pa_en_reg <= dpu_ipa_to_pa_en;
    dpu_pr_tablewalk_reg <= dpu_pr_tablewalk;
    out_of_reset_reg <= out_of_reset;
  end



  // ---------------------------------------------------------------------------
  // Micro TLB Update signals
  // ---------------------------------------------------------------------------

  // Flush the entire uTLB. This will invalidate all the entries previously
  // fetched into the data uTLB. The TLB should ensure it is not asserted
  // alongside the enable signal.
  //  input tlb_d_utlb_flush valid always timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_d_utlb_flush X or Z")
  u_ovl_intf_x_tlb_d_utlb_flush (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_d_utlb_flush));


  // The enable signal is asserted to write a single entry to the data
  // micro-TLB. The Main TLB block will prevent back-to-back updates to
  // the micro-TLB from occurring. The Fields within the micro-TLB Entry
  // are made explicit below.
  //  input tlb_d_utlb_enable valid always timing 85%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_d_utlb_enable X or Z")
  u_ovl_intf_x_tlb_d_utlb_enable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_d_utlb_enable));


  // The micro-TLB might be written this cycle, depending on whether the
  // RAM lookup hit or not. This speculative signal can be provided earlier
  // than the accurate version.
  //  input tlb_d_utlb_might_enable valid always timing 65%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_d_utlb_might_enable X or Z")
  u_ovl_intf_x_tlb_d_utlb_might_enable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_d_utlb_might_enable));


  // The format of the uTLB entry being written. When set the format is LPAE,
  // otherwise it is VMSAv7.
  // For AArch64, this is always set. If EL1 is AArch64 and EL0 is AArch32 and
  // current mode is EL0, even then this signal is set as TLB uses EL1 AArch for
  // doing EL0 translations.
  //  input tlb_d_utlb_lpae valid tlb_d_utlb_enable timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_d_utlb_lpae X or Z")
  u_ovl_intf_x_tlb_d_utlb_lpae (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_d_utlb_enable),
    .test_expr (tlb_d_utlb_lpae));


  // The valid bit to write to the uTLB entry that is enabled. Normally this
  // will be set, however on some types of aborts or CP15 VtoP operations an
  // entry may be written with the valid bit cleared. This entry should hit
  // for the single transaction that caused the lookup, but not for any
  // following transactions.
  //  input tlb_d_utlb_valid valid tlb_d_utlb_enable timing 85%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_d_utlb_valid X or Z")
  u_ovl_intf_x_tlb_d_utlb_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_d_utlb_enable),
    .test_expr (tlb_d_utlb_valid));


  // The data to write to the uTLB entry that is being enabled.
  // uTLB data encoding:
  //
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
  //
  // The AP field indicates the access permissions for the first stage of
  // translation, unless it contains the value 100, in which case the entry
  // was fetched in EL2/3, and HAP contain the access permissions of the
  // first and only stage of translation.
  //
  // The MemAttrs contains the memory type and shareability, encoded the same
  // as stored in the main TLB RAM, which is documented in the TLB specification.
  //
  // The NS bit indicates the non-secure state of the physical memory address,
  // as indicated in the page descriptor.
  //
  // The S2Level field indicates how many levels of stage2 were needed
  // for the translation:
  //  00 - No stage2 translation was performed
  //  01 - first level
  //  10 - second level
  //  11 - third level
  //
  //
  // The S1Level field indicates how many levels of stage1 were needed
  // for the translation:
  //  00 - first level, supersection (VMSAv7 only)
  //  01 - first level
  //  10 - second level
  //  11 - third level (LPAE only)
  //
  // The fault bits indicate if a fault occurred:
  // 00 - No fault.
  // 01 - Stage2 fault due to a stage1 pagewalk.
  // 10 - Stage1 fault.
  // 11 - Stage2 fault. Note that there could still be a stage1 fault
  //      (permission, domain, or alignment) which is detected after this,
  //      and must take priority.
  //
  // The fault type encodes what type of fault occurred if bits [65:64] are
  // non-zero. It has the same encoding as dcu_p_abort_dc3.
  // If bit [64] is set, indicating a stage2 fault, then bits [47:20] contain
  // the IPA of the faulting access instead of the PA. The level fields contain
  // the level the fault was, for either the first stage or second stage
  // depending on the fault type.
  //  input [95:0] tlb_d_utlb_data valid tlb_d_utlb_enable timing 85%

  assert_never_unknown #(`OVL_FATAL, 96, INOPTIONS, "tlb_d_utlb_data X or Z")
  u_ovl_intf_x_tlb_d_utlb_data (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_d_utlb_enable),
    .test_expr (tlb_d_utlb_data));



  // When asserted the format of all micro-TLB main entries are LPAE. When
  // deasserted the format of all the non-hyp micro-TLB main entries is VMSAv7.
  // The tlb_d_utlb_flush or flush_d_utlb signal will be asserted on a change so
  // there can never be a mix in the non-hyp entries.
  // Note that this is not the same as tlb_d_utlb_lpae, because it refers to the
  // existing main entries in the uTLB, and not the interface entry or the new
  // entry being written. While the two will often be the same, they may differ
  // when in hyp mode, or when executing some CP15 VtoP operations.

  //  input tlb_lpae_mode valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_lpae_mode X or Z")
  u_ovl_intf_x_tlb_lpae_mode (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_lpae_mode));


  // The secure version of tlb_lpae_mode, i.e. the secure TTBCR.EAE. This is
  // needed if the DPU is trapping a non-secure abort into secure state.
  //  input tlb_lpae_mode_s valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_lpae_mode_s X or Z")
  u_ovl_intf_x_tlb_lpae_mode_s (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_lpae_mode_s));


  // The speculative enable signal must be set if the entry is really enabled.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_d_utlb_enable  => tlb_d_utlb_might_enable")
  u_ovl_intf_assume_8630bbe866aa274fe6488bf1c0d46facb34a86c0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_d_utlb_enable ),
    .consequent_expr (tlb_d_utlb_might_enable));


  // There are no back to back writes to the micro TLB

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_d_utlb_enable@1  => ~tlb_d_utlb_enable")
  u_ovl_intf_assume_099500bcaafc8858121a538bcf770878c73d7165 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_d_utlb_enable_reg ),
    .consequent_expr (~tlb_d_utlb_enable));


  // Once enabled, might enable must remain low until the next lookup starts.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_d_utlb_enable@1  => ~tlb_d_utlb_might_enable")
  u_ovl_intf_assume_4ca380d6eb0f27b69cb87f5d03560e9eaa799b55 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_d_utlb_enable_reg ),
    .consequent_expr (~tlb_d_utlb_might_enable));


  assign mem_attrs  = tlb_d_utlb_data[78:71];

  // Only some page type encodings are valid, when there is a valid stage1 translation

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_d_utlb_enable & (tlb_d_utlb_data[84:83] in [2'b00, 2'b11])  => ~`CA53_MEM_UNUSED(mem_attrs)")
  u_ovl_intf_assume_54ef5fca9b1d070b085d7bbb267498443942eda4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_d_utlb_enable & (((tlb_d_utlb_data[84:83] == 2'b00) | (tlb_d_utlb_data[84:83] ==  2'b11))) ),
    .consequent_expr (~`CA53_MEM_UNUSED(mem_attrs)));


  // Only VMSA can generate supersections

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_d_utlb_enable & tlb_d_utlb_lpae  => (tlb_d_utlb_data[80:79] != 2'b00)")
  u_ovl_intf_assume_979bf53324e4b33b01343d5d305e10bf38f7f587 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_d_utlb_enable & tlb_d_utlb_lpae ),
    .consequent_expr ((tlb_d_utlb_data[80:79] != 2'b00)));


  // Only LPAE can generate level 3 entries

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_d_utlb_enable & ~tlb_d_utlb_lpae  => (tlb_d_utlb_data[80:79] != 2'b11)")
  u_ovl_intf_assume_769efa95cec6b196fb7c86f269b238ff38bc57b2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_d_utlb_enable & ~tlb_d_utlb_lpae ),
    .consequent_expr ((tlb_d_utlb_data[80:79] != 2'b11)));


  // A faulting entry should never be valid for following instructions.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_d_utlb_enable & |tlb_d_utlb_data[84:83]  => ~tlb_d_utlb_valid")
  u_ovl_intf_assume_f2c25833e94d6234f5997c49d95b84a5de514e88 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_d_utlb_enable & |tlb_d_utlb_data[84:83] ),
    .consequent_expr (~tlb_d_utlb_valid));


  // A stage2 fault cannot happen if no stage2 translation was done.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_d_utlb_enable & tlb_d_utlb_data[83]  => tlb_d_utlb_data[82:81] != 2'b00")
  u_ovl_intf_assume_4069fb8593ad6b3b2c8515e3d1318bf4a79c00f9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_d_utlb_enable & tlb_d_utlb_data[83] ),
    .consequent_expr (tlb_d_utlb_data[82:81] != 2'b00));


  // The uTLB should not set the overridden bit for device memory on stage 2 translation faults

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_d_utlb_enable & `CA53_MEM_DEVICE(mem_attrs) & (tlb_d_utlb_data[84:83] == 2'b11)  => ~`CA53_MEM_DEV_OVERRIDE(mem_attrs)")
  u_ovl_intf_assume_1c7783e06ca52e96ccb656912d522a4354c0664b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_d_utlb_enable & `CA53_MEM_DEVICE(mem_attrs) & (tlb_d_utlb_data[84:83] == 2'b11) ),
    .consequent_expr (~`CA53_MEM_DEV_OVERRIDE(mem_attrs)));


  // Only some fault encodings are valid for S1 VMSA faults.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_d_utlb_enable & (tlb_d_utlb_data[84:83] == 2'b10) & ~tlb_d_utlb_lpae  => tlb_d_utlb_data[91:85] in [`CA53_FAULT_LPAE_ADDR_SIZE_L0, `CA53_FAULT_LPAE_ADDR_SIZE_L1, `CA53_FAULT_LPAE_ADDR_SIZE_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2, `CA53_FAULT_LPAE_TRANSLATION_L1, `CA53_FAULT_LPAE_TRANSLATION_L2, `CA53_FAULT_LPAE_ACCESS_L1, `CA53_FAULT_LPAE_ACCESS_L2]")
  u_ovl_intf_assume_202cf887f739dd2d3ed11458937bc6abe55bc7c2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_d_utlb_enable & (tlb_d_utlb_data[84:83] == 2'b10) & ~tlb_d_utlb_lpae ),
    .consequent_expr (((tlb_d_utlb_data[91:85] == `CA53_FAULT_LPAE_ADDR_SIZE_L0) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_TRANSLATION_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_TRANSLATION_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ACCESS_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ACCESS_L2))));


  // Only some fault encodings are valid for S1 LPAE faults.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_d_utlb_enable & (tlb_d_utlb_data[84:83] == 2'b10) & tlb_d_utlb_lpae  => tlb_d_utlb_data[91:85] in [`CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3, `CA53_FAULT_LPAE_TRANSLATION_L0, `CA53_FAULT_LPAE_TRANSLATION_L1, `CA53_FAULT_LPAE_TRANSLATION_L2, `CA53_FAULT_LPAE_TRANSLATION_L3, `CA53_FAULT_LPAE_ACCESS_L0, `CA53_FAULT_LPAE_ACCESS_L1, `CA53_FAULT_LPAE_ACCESS_L2, `CA53_FAULT_LPAE_ACCESS_L3, `CA53_FAULT_LPAE_ADDR_SIZE_L0, `CA53_FAULT_LPAE_ADDR_SIZE_L1, `CA53_FAULT_LPAE_ADDR_SIZE_L2, `CA53_FAULT_LPAE_ADDR_SIZE_L3]")
  u_ovl_intf_assume_fb4616c55bb508f013a3cb1c4d6fcdedc49c0c7b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_d_utlb_enable & (tlb_d_utlb_data[84:83] == 2'b10) & tlb_d_utlb_lpae ),
    .consequent_expr (((tlb_d_utlb_data[91:85] == `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_TRANSLATION_L0) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_TRANSLATION_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_TRANSLATION_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_TRANSLATION_L3) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ACCESS_L0) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ACCESS_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ACCESS_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ACCESS_L3) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L0) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L3))));


  // Only some fault encodings are valid for S2 faults.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_d_utlb_enable & tlb_d_utlb_data[83]  => tlb_d_utlb_data[91:85] in [`CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3, `CA53_FAULT_LPAE_TRANSLATION_L0, `CA53_FAULT_LPAE_TRANSLATION_L1, `CA53_FAULT_LPAE_TRANSLATION_L2, `CA53_FAULT_LPAE_TRANSLATION_L3, `CA53_FAULT_LPAE_ACCESS_L0, `CA53_FAULT_LPAE_ACCESS_L1, `CA53_FAULT_LPAE_ACCESS_L2, `CA53_FAULT_LPAE_ACCESS_L3, `CA53_FAULT_LPAE_PERMISSION_L1, `CA53_FAULT_LPAE_PERMISSION_L2, `CA53_FAULT_LPAE_PERMISSION_L3, `CA53_FAULT_LPAE_ADDR_SIZE_L0, `CA53_FAULT_LPAE_ADDR_SIZE_L1, `CA53_FAULT_LPAE_ADDR_SIZE_L2, `CA53_FAULT_LPAE_ADDR_SIZE_L3]")
  u_ovl_intf_assume_1493a9f00bb38c0119766f47aec55f2994a803a8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_d_utlb_enable & tlb_d_utlb_data[83] ),
    .consequent_expr (((tlb_d_utlb_data[91:85] == `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_TRANSLATION_L0) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_TRANSLATION_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_TRANSLATION_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_TRANSLATION_L3) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ACCESS_L0) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ACCESS_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ACCESS_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ACCESS_L3) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PERMISSION_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PERMISSION_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_PERMISSION_L3) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L0) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L1) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L2) | (tlb_d_utlb_data[91:85] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L3))));


  // In A32, current LPAE mode must be the same as the secure one if we are in secure state.
  // (If an exception taken in monitor occurs in hypervisor mode, there is one cycle
  // when dpu_ns_state is 0 and dpu_mode_iss still indicates hypervisor mode. This is safe
  // because the DPU will be asserting flush and forcing the PFU in this cycle.)
  // Note: Don't start checking this until dpu_aarch64_at_el becomes valid which
  // is two clock cycles of reset negates

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dly_reset1 <= 1'b0;
  else
    dly_reset1 <= 1'b1;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dly_reset2 <= 1'b0;
  else
    dly_reset2 <= dly_reset1;

  assign dly_reset  = dly_reset1 & dly_reset2;

  assert_implication #(`OVL_FATAL, INOPTIONS, "~dpu_aarch64_at_el[3] & (dpu_mode_iss[3:0] != `CA53_MODE_HYP) & ~dpu_ns_state  => tlb_lpae_mode == tlb_lpae_mode_s")
  u_ovl_intf_assume_76194eceb60ac3306940bdd00c389ff6a8406d7c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dpu_aarch64_at_el[3] & (dpu_mode_iss[3:0] != `CA53_MODE_HYP) & ~dpu_ns_state ),
    .consequent_expr (tlb_lpae_mode == tlb_lpae_mode_s));


  // Status signal to DPU
  // EL1 TBI is a two bit signal giving TCR_EL1{TBI1,TBI0},
  //  input [1:0]    tlb_d_tcr_el1_tbi    valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "tlb_d_tcr_el1_tbi X or Z")
  u_ovl_intf_x_tlb_d_tcr_el1_tbi (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_d_tcr_el1_tbi));

  //  input          tlb_d_tcr_el2_tbi0   valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_d_tcr_el2_tbi0 X or Z")
  u_ovl_intf_x_tlb_d_tcr_el2_tbi0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_d_tcr_el2_tbi0));

  //  input          tlb_d_tcr_el3_tbi0   valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_d_tcr_el3_tbi0 X or Z")
  u_ovl_intf_x_tlb_d_tcr_el3_tbi0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_d_tcr_el3_tbi0));


  // ---------------------------------------------------------------------------
  // Translation request signals
  // ---------------------------------------------------------------------------

  // NOTE - the X checks for these signals are performed in ca53_dpu_dcu
  // because the valid for these signals is only visible in that interface

  // The DPU VA is the complete virtual address of the data transaction in the
  // DC1 stage of the DCU's load store pipline. It is used for watchpoint
  // matching and main TLB lookups.

  // The hit signal indicates a micro TLB hit for the transaction currently in DC1.

  // Whether pagewalk should be abandoned due to change in DPU held configuration
  //  output dpu_tlb_abandon valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_tlb_abandon X or Z")
  u_ovl_intf_x_dpu_tlb_abandon (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_tlb_abandon));


  // ---------------------------------------------------------------------------
  // TrustZone status signals
  // ---------------------------------------------------------------------------

  // The NS bit from the Secure Configuration Register.
  // This must only change when the DCU pipe is empty, and hence there cannot
  // be any TLB CP15 register reads or writes in progress when it changes.
  //  output dpu_scr_el3_ns valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_scr_el3_ns X or Z")
  u_ovl_intf_x_dpu_scr_el3_ns (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_scr_el3_ns));


  // The non-secure state of the DPU. Set if the NS bit from the Secure
  // Configuration Register is set and not in monitor mode.
  // If this changes it must always be accompanied by a pipeline flush.
  //  output dpu_ns_state valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_ns_state X or Z")
  u_ovl_intf_x_dpu_ns_state (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_ns_state));


  // NS bit from SCR should always be set in non-secure state then the TLB

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_ns_state  => dpu_scr_el3_ns")
  u_ovl_intf_assert_25f20e9da268619ed351ca6986c49dcfe4680d97 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_ns_state ),
    .consequent_expr (dpu_scr_el3_ns));


  // If the dpu_ns_state changes the micro-TLB flush signal must be asserted.
  assign flush_utlb  = dpu_ns_state != dpu_ns_state_reg;

  // When there is a write in uTLB in non-secure state then the
  // should be in non-secure state.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_d_utlb_enable & dpu_ns_state & ~flush_utlb  => tlb_d_utlb_data[65]")
  u_ovl_intf_assume_66d3b22914668fa39473b1e7596c1dc160e60b88 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_d_utlb_enable & dpu_ns_state & ~flush_utlb ),
    .consequent_expr (tlb_d_utlb_data[65]));


  // When the MMU is off and there is a write in uTLB in secure state for the 
  // current excpetion level then the TLB should be in secure state.
  // The tlb_d_utlb_valid signal is used in order not to fire in the case of 
  // a V2P* operation.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_d_utlb_enable & ~dpu_ns_state & tlb_d_utlb_valid & ~flush_utlb & (dpu_exception_level == `CA53_EL3) & ~dpu_mmu_on_el3 & (tlb_d_utlb_data[68:66] == 3'b100)  => ~tlb_d_utlb_data[65]")
  u_ovl_intf_assume_2b6eeb8acb579646ff09cced70fc7b1d1882acc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_d_utlb_enable & ~dpu_ns_state & tlb_d_utlb_valid & ~flush_utlb & (dpu_exception_level == `CA53_EL3) & ~dpu_mmu_on_el3 & (tlb_d_utlb_data[68:66] == 3'b100) ),
    .consequent_expr (~tlb_d_utlb_data[65]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_d_utlb_enable & ~dpu_ns_state & tlb_d_utlb_valid & ~flush_utlb & (dpu_exception_level == `CA53_EL1) & ~dpu_mmu_on_el1 & (tlb_d_utlb_data[68:66] != 3'b100)  => ~tlb_d_utlb_data[65]")
  u_ovl_intf_assume_3998bb10b147d0daebc015a90d5151439ba9137c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_d_utlb_enable & ~dpu_ns_state & tlb_d_utlb_valid & ~flush_utlb & (dpu_exception_level == `CA53_EL1) & ~dpu_mmu_on_el1 & (tlb_d_utlb_data[68:66] != 3'b100) ),
    .consequent_expr (~tlb_d_utlb_data[65]));


  // ---------------------------------------------------------------------------
  // System Control Register Signals
  // ---------------------------------------------------------------------------

  // MMU on (Bit 0 of SCTLR and HSCTLR)
  //  output          dpu_mmu_on_el1                valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_mmu_on_el1 X or Z")
  u_ovl_intf_x_dpu_mmu_on_el1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_mmu_on_el1));

  //  output          dpu_mmu_on_el2                valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_mmu_on_el2 X or Z")
  u_ovl_intf_x_dpu_mmu_on_el2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_mmu_on_el2));

  //  output          dpu_mmu_on_el3                valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_mmu_on_el3 X or Z")
  u_ovl_intf_x_dpu_mmu_on_el3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_mmu_on_el3));


  // DCache on
  //  output          dpu_dcache_on_el1             valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dcache_on_el1 X or Z")
  u_ovl_intf_x_dpu_dcache_on_el1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dcache_on_el1));

  //  output          dpu_dcache_on_el2             valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dcache_on_el2 X or Z")
  u_ovl_intf_x_dpu_dcache_on_el2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dcache_on_el2));

  //  output          dpu_dcache_on_el3             valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dcache_on_el3 X or Z")
  u_ovl_intf_x_dpu_dcache_on_el3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dcache_on_el3));


  // Instruction cache on (Bit 12 of SCTLR and HSCTLR)
  //  output          dpu_icache_on                 valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_icache_on X or Z")
  u_ovl_intf_x_dpu_icache_on (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_icache_on));


  // User writeable fetches are XN (Bit 20 of SCTLR)
  //  output          dpu_sctlr_uwxn_el3            valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_sctlr_uwxn_el3 X or Z")
  u_ovl_intf_x_dpu_sctlr_uwxn_el3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_sctlr_uwxn_el3));

  //  output          dpu_sctlr_uwxn_el1            valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_sctlr_uwxn_el1 X or Z")
  u_ovl_intf_x_dpu_sctlr_uwxn_el1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_sctlr_uwxn_el1));


  // Writeable fetches are XN (Bit 19 of SCTLR and HSCTLR)
  //  output          dpu_sctlr_wxn_el3             valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_sctlr_wxn_el3 X or Z")
  u_ovl_intf_x_dpu_sctlr_wxn_el3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_sctlr_wxn_el3));

  //  output          dpu_sctlr_wxn_el1             valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_sctlr_wxn_el1 X or Z")
  u_ovl_intf_x_dpu_sctlr_wxn_el1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_sctlr_wxn_el1));

  //  output          dpu_sctlr_wxn_el2             valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_sctlr_wxn_el2 X or Z")
  u_ovl_intf_x_dpu_sctlr_wxn_el2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_sctlr_wxn_el2));


  // Access flag enable (Bit 29 of SCTLR), always HIGH in hypervisor mode
  //  output          dpu_access_flag_enable_el3    valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_access_flag_enable_el3 X or Z")
  u_ovl_intf_x_dpu_access_flag_enable_el3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_access_flag_enable_el3));

  //  output          dpu_access_flag_enable_el1    valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_access_flag_enable_el1 X or Z")
  u_ovl_intf_x_dpu_access_flag_enable_el1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_access_flag_enable_el1));


  // TEX remap enable (Bit 28 of SCTLR), always HIGH in hypervisor mode
  //  output          dpu_tex_remap_enable_el3      valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_tex_remap_enable_el3 X or Z")
  u_ovl_intf_x_dpu_tex_remap_enable_el3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_tex_remap_enable_el3));

  //  output          dpu_tex_remap_enable_el1      valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_tex_remap_enable_el1 X or Z")
  u_ovl_intf_x_dpu_tex_remap_enable_el1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_tex_remap_enable_el1));


  // Exception endian control signal (Bit 25 of SCTLR)
  //  output          dpu_endian_el3                valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_endian_el3 X or Z")
  u_ovl_intf_x_dpu_endian_el3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_endian_el3));

  //  output          dpu_endian_el1                valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_endian_el1 X or Z")
  u_ovl_intf_x_dpu_endian_el1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_endian_el1));

  //  output          dpu_endian_el2                valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_endian_el2 X or Z")
  u_ovl_intf_x_dpu_endian_el2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_endian_el2));


  // Hivecs control signal (Bit 13 of SCTLR), not registered in the DPU
  //  output          dpu_hivecs                    valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_hivecs X or Z")
  u_ovl_intf_x_dpu_hivecs (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_hivecs));


  // Upper bits of the EDVIDSR register
  //  output    [3:0] dpu_dbg_vid                   valid dpu_dbg_sample_contextid timing 50%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "dpu_dbg_vid X or Z")
  u_ovl_intf_x_dpu_dbg_vid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_dbg_sample_contextid),
    .test_expr (dpu_dbg_vid));


  // The dcache can be accessed for cacheable pagewalks.
  //  output dpu_s2_dcache_on                       valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_s2_dcache_on X or Z")
  u_ovl_intf_x_dpu_s2_dcache_on (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_s2_dcache_on));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    out_of_reset <= 1'b0;
  else
    out_of_reset <= 1'b1;


  // The TLB must be told to abandon pagewalks and lookups if any SCTLR changes.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_mmu_on_el1 != dpu_mmu_on_el1@1  => dpu_tlb_abandon")
  u_ovl_intf_assert_f186f37115e955ef58f0f19fc83aeca8c7e63345 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_mmu_on_el1 != dpu_mmu_on_el1_reg ),
    .consequent_expr (dpu_tlb_abandon));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_mmu_on_el2 != dpu_mmu_on_el2@1  => dpu_tlb_abandon")
  u_ovl_intf_assert_2817f5aae0baa13e947209e8222f843901e91598 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_mmu_on_el2 != dpu_mmu_on_el2_reg ),
    .consequent_expr (dpu_tlb_abandon));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_mmu_on_el3 != dpu_mmu_on_el3@1  => dpu_tlb_abandon")
  u_ovl_intf_assert_cf0e3c139553e9a37eeb9a4c61927e96cdb7f2cf (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_mmu_on_el3 != dpu_mmu_on_el3_reg ),
    .consequent_expr (dpu_tlb_abandon));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_sctlr_uwxn_el3 != dpu_sctlr_uwxn_el3@1  => dpu_tlb_abandon")
  u_ovl_intf_assert_9bb0288fc7eb2de44dbd1d2b4d19d2ab89e62456 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_sctlr_uwxn_el3 != dpu_sctlr_uwxn_el3_reg ),
    .consequent_expr (dpu_tlb_abandon));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_sctlr_uwxn_el1 != dpu_sctlr_uwxn_el1@1  => dpu_tlb_abandon")
  u_ovl_intf_assert_8dad9e1fbfc0c8ab29d916a091fa18c3bada312a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_sctlr_uwxn_el1 != dpu_sctlr_uwxn_el1_reg ),
    .consequent_expr (dpu_tlb_abandon));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_sctlr_wxn_el3 != dpu_sctlr_wxn_el3@1  => dpu_tlb_abandon")
  u_ovl_intf_assert_0d0be187def00b00e6db1f822b366adcb9d5ca37 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_sctlr_wxn_el3 != dpu_sctlr_wxn_el3_reg ),
    .consequent_expr (dpu_tlb_abandon));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_sctlr_wxn_el1 != dpu_sctlr_wxn_el1@1  => dpu_tlb_abandon")
  u_ovl_intf_assert_edf94f95f8c903fadd90746a570b77da8b43752b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_sctlr_wxn_el1 != dpu_sctlr_wxn_el1_reg ),
    .consequent_expr (dpu_tlb_abandon));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_sctlr_wxn_el2 != dpu_sctlr_wxn_el2@1  => dpu_tlb_abandon")
  u_ovl_intf_assert_43fabc64fbf3e9b2f70c9438c2210dc2e272d5a9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_sctlr_wxn_el2 != dpu_sctlr_wxn_el2_reg ),
    .consequent_expr (dpu_tlb_abandon));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_access_flag_enable_el3 != dpu_access_flag_enable_el3@1  => dpu_tlb_abandon")
  u_ovl_intf_assert_ce6ac3ebbe0fb7b4bdb32ccdbf37e163ff0b625d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_access_flag_enable_el3 != dpu_access_flag_enable_el3_reg ),
    .consequent_expr (dpu_tlb_abandon));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_access_flag_enable_el1 != dpu_access_flag_enable_el1@1  => dpu_tlb_abandon")
  u_ovl_intf_assert_4e33f2d3d42a463bcee243e7989c73f9ffa17059 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_access_flag_enable_el1 != dpu_access_flag_enable_el1_reg ),
    .consequent_expr (dpu_tlb_abandon));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_tex_remap_enable_el3 != dpu_tex_remap_enable_el3@1  => dpu_tlb_abandon")
  u_ovl_intf_assert_a0d19b0ce3557c0305134a7494f67fc574902cde (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_tex_remap_enable_el3 != dpu_tex_remap_enable_el3_reg ),
    .consequent_expr (dpu_tlb_abandon));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_tex_remap_enable_el1 != dpu_tex_remap_enable_el1@1  => dpu_tlb_abandon")
  u_ovl_intf_assert_2ea7e2db8bd9d6742321ef50a7246e2d2c7fa3f7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_tex_remap_enable_el1 != dpu_tex_remap_enable_el1_reg ),
    .consequent_expr (dpu_tlb_abandon));

  // The EE bits may be set immediately after a reset based on an external input.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "out_of_reset@1 & (dpu_endian_el3 != dpu_endian_el3@1)  => dpu_tlb_abandon")
  u_ovl_intf_assert_a365259999c44e9b149c9cb9f6dedfe84579f043 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (out_of_reset_reg & (dpu_endian_el3 != dpu_endian_el3_reg) ),
    .consequent_expr (dpu_tlb_abandon));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "out_of_reset@1 & (dpu_endian_el1 != dpu_endian_el1@1)  => dpu_tlb_abandon")
  u_ovl_intf_assert_ffc5f7e995efe215158ec388518122e83cd49316 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (out_of_reset_reg & (dpu_endian_el1 != dpu_endian_el1_reg) ),
    .consequent_expr (dpu_tlb_abandon));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "out_of_reset@1 & (dpu_endian_el2 != dpu_endian_el2@1)  => dpu_tlb_abandon")
  u_ovl_intf_assert_f06b7ba269ab14ecf2be0595018b9bd0b0380a04 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (out_of_reset_reg & (dpu_endian_el2 != dpu_endian_el2_reg) ),
    .consequent_expr (dpu_tlb_abandon));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "out_of_reset@1 & (dpu_dcache_on_el1 != dpu_dcache_on_el1@1)  => dpu_tlb_abandon")
  u_ovl_intf_assert_3bbfde3ccf1eaf6e582898baa1ed5f77e5e3e09d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (out_of_reset_reg & (dpu_dcache_on_el1 != dpu_dcache_on_el1_reg) ),
    .consequent_expr (dpu_tlb_abandon));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "out_of_reset@1 & (dpu_dcache_on_el2 != dpu_dcache_on_el2@1)  => dpu_tlb_abandon")
  u_ovl_intf_assert_f400c3302bb70841a72d054cfd7a6b83d8e2e93f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (out_of_reset_reg & (dpu_dcache_on_el2 != dpu_dcache_on_el2_reg) ),
    .consequent_expr (dpu_tlb_abandon));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "out_of_reset@1 & (dpu_dcache_on_el3 != dpu_dcache_on_el3@1)  => dpu_tlb_abandon")
  u_ovl_intf_assert_0e130acc03af99c22d69b4076f9af9d71c046655 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (out_of_reset_reg & (dpu_dcache_on_el3 != dpu_dcache_on_el3_reg) ),
    .consequent_expr (dpu_tlb_abandon));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dpu_tlb_abandon_dly <= 1'b0;
  else
    dpu_tlb_abandon_dly <= dpu_tlb_abandon;


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "out_of_reset@1 & (dpu_s2_dcache_on != dpu_s2_dcache_on@1)  => dpu_tlb_abandon_dly")
  u_ovl_intf_assert_0a041795ca9438bb9ae2f6090b9892c1470e2809 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (out_of_reset_reg & (dpu_s2_dcache_on != dpu_s2_dcache_on_reg) ),
    .consequent_expr (dpu_tlb_abandon_dly));


  // ---------------------------------------------------------------------------
  // Breakpoints and watchpoints
  // ---------------------------------------------------------------------------

  // Vector Base Addresses.
  // Muxing between secure and non-secure versions of the vector base address
  // is done in TLB.yes
  //  output [31:5]   dpu_vec_base_s_dc1            valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 27, OUTOPTIONS, "dpu_vec_base_s_dc1 X or Z")
  u_ovl_intf_x_dpu_vec_base_s_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_vec_base_s_dc1));

  //  output [31:5]   dpu_vec_base_ns_dc1           valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 27, OUTOPTIONS, "dpu_vec_base_ns_dc1 X or Z")
  u_ovl_intf_x_dpu_vec_base_ns_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_vec_base_ns_dc1));


  // The architectural mode that the DPU is currently in. Used by the TLB to
  // mask off breakpoint hits according to the bits set in the Debug Breakpoint
  // registers, and to indicate when in HYP mode.
  // The encodings are given by the `CA53_MODE_* defines.
  //  output [4:0]    dpu_mode_iss                  valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "dpu_mode_iss X or Z")
  u_ovl_intf_x_dpu_mode_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_mode_iss));


  // The exception level of the processor. It is used to indicate current
  // exception level of DPU
  // 2'b00 => EL0 Applications
  // 2'b01 => EL1 OS Kernel and associated functions that are typically
  // described as "privileged"
  // 2'b10 => EL2 Hypervisor
  // 2'b11 => EL3 Security Monitor
  //  output [1:0]    dpu_exception_level           valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "dpu_exception_level X or Z")
  u_ovl_intf_x_dpu_exception_level (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_exception_level));


  // This signal gives Arch information of corresponding exception levels
  // even when DPU is in a different exception level
  //  output [3:1]    dpu_aarch64_at_el             valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "dpu_aarch64_at_el X or Z")
  u_ovl_intf_x_dpu_aarch64_at_el (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_aarch64_at_el));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(dpu_aarch64_at_el[3] == 1'b0)  => (dpu_aarch64_at_el[2:1] == 2'b00)")
  u_ovl_intf_assert_982c5a3097ad8ff022776ab3f813451fac1f1c61 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((dpu_aarch64_at_el[3] == 1'b0) ),
    .consequent_expr ((dpu_aarch64_at_el[2:1] == 2'b00)));


  // Global Debug Enable signals - no breakpoint or watchpoint events should be
  // generated by the TLB when this is deasserted.
  // The enable can change at any time.
  // Two versions
  // sw - applies to debug software exceptions
  // hw - applies to halting debug
  //  output          dpu_dbg_tlb_sw_bkpt_wpt_en       valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dbg_tlb_sw_bkpt_wpt_en X or Z")
  u_ovl_intf_x_dpu_dbg_tlb_sw_bkpt_wpt_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dbg_tlb_sw_bkpt_wpt_en));

  //  output          dpu_dbg_tlb_hw_bkpt_wpt_en       valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dbg_tlb_hw_bkpt_wpt_en X or Z")
  u_ovl_intf_x_dpu_dbg_tlb_hw_bkpt_wpt_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dbg_tlb_hw_bkpt_wpt_en));


  // Debug Context ID sample signal.
  // The debug block in the DPU can request that the TLB samples the
  // context ID register using this signal. dpu_apb_active must be asserted
  // the cycle before the contextid is sampled.
  //  output          dpu_dbg_sample_contextid      valid always timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dbg_sample_contextid X or Z")
  u_ovl_intf_x_dpu_dbg_sample_contextid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dbg_sample_contextid));


  // ---------------------------------------------------------------------------
  // Hyp Configuration Register Signals
  // ---------------------------------------------------------------------------

  //  output          dpu_default_cacheable         valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_default_cacheable X or Z")
  u_ovl_intf_x_dpu_default_cacheable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_default_cacheable));

  //  output          dpu_ipa_to_pa_en              valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_ipa_to_pa_en X or Z")
  u_ovl_intf_x_dpu_ipa_to_pa_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_ipa_to_pa_en));

  //  output          dpu_pr_tablewalk              valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_pr_tablewalk X or Z")
  u_ovl_intf_x_dpu_pr_tablewalk (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_pr_tablewalk));


  // The TLB must be told to abandon pagewalks and lookups if the HCR changes.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_default_cacheable != dpu_default_cacheable@1  => dpu_tlb_abandon")
  u_ovl_intf_assert_d41567211d7ae796668e7c25e5d093b96ae11828 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_default_cacheable != dpu_default_cacheable_reg ),
    .consequent_expr (dpu_tlb_abandon));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_ipa_to_pa_en != dpu_ipa_to_pa_en@1  => dpu_tlb_abandon@1")
  u_ovl_intf_assert_bd6bb65dd54bf4182e390694ab610fa2fce7e3e8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_ipa_to_pa_en != dpu_ipa_to_pa_en_reg ),
    .consequent_expr (dpu_tlb_abandon_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_pr_tablewalk != dpu_pr_tablewalk@1  => dpu_tlb_abandon")
  u_ovl_intf_assert_fc6ac6d939562c521054dcd79289abcae145a7df (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_pr_tablewalk != dpu_pr_tablewalk_reg ),
    .consequent_expr (dpu_tlb_abandon));


  // EL2 can only be non-secure

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(dpu_exception_level == 2'b10)  => dpu_ns_state")
  u_ovl_intf_assert_0fb7fe60af4504a2cdbf3fbf2580f37eaaa2c1cf (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((dpu_exception_level == 2'b10) ),
    .consequent_expr (dpu_ns_state));


  // Monitor mode is always secure.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(dpu_mode_iss[3:0] == `CA53_MODE_MON) & dpu_dbg_tlb_sw_bkpt_wpt_en  => (~dpu_ns_state | ~dpu_ns_state@1) ")
  u_ovl_intf_assert_dd48a285e84b61993f96bb68c4236c5c2d69142a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((dpu_mode_iss[3:0] == `CA53_MODE_MON) & dpu_dbg_tlb_sw_bkpt_wpt_en ),
    .consequent_expr ((~dpu_ns_state | ~dpu_ns_state_reg) ));


  // ---------------------------------------------------------------------------
  // Debug signals for APB register access
  // ---------------------------------------------------------------------------

  // The wr and rd signals are generated from the PSEL and PWRITE APB signals
  // These signals may be asserted for more than one cycle for a transaction,
  // so any side-effects must be idempotent
  // The address is the (registered) APB address - the DBG_* macros in
  // cortexa53params.v map encodings to registers

  // To prevent the need to reset registers in the RTL to get
  // OVLs working correctly after reset we wait until at least one
  // write transaction has been signalled. If the first transaction
  // is a read the dpu logic will make sures Xs are not propagted

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dpu_dbg_held_reset_n <= 1'b0;
  else if (dpu_dbg_wr)
    dpu_dbg_held_reset_n <= 1'b1;

  assign initialize_dpu_dbg  = dpu_dbg_held_reset_n | dpu_dbg_wr;

  //  output          dpu_apb_active    valid always                    timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_apb_active X or Z")
  u_ovl_intf_x_dpu_apb_active (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_apb_active));

  //  output          dpu_dbg_wr        valid always                    timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dbg_wr X or Z")
  u_ovl_intf_x_dpu_dbg_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dbg_wr));

  //  output [11:2]   dpu_dbg_addr      valid initialize_dpu_dbg        timing 20%

  assert_never_unknown #(`OVL_FATAL, 10, OUTOPTIONS, "dpu_dbg_addr X or Z")
  u_ovl_intf_x_dpu_dbg_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (initialize_dpu_dbg),
    .test_expr (dpu_dbg_addr));

  //  output [31:0]   dpu_dbg_wdata     valid dpu_dbg_wr                timing 20%

  assert_never_unknown #(`OVL_FATAL, 32, OUTOPTIONS, "dpu_dbg_wdata X or Z")
  u_ovl_intf_x_dpu_dbg_wdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_dbg_wr),
    .test_expr (dpu_dbg_wdata));



  // The speculative dpu_apb_active must be asserted the cycle before a
  // request is made (but can be asserted at other times as well)
  // assert dpu_dbg_wr => dpu_apb_active@1;
  // assert dpu_dbg_sample_contextid => dpu_apb_active@1;
  // dpu_apb_active is reset by dbg_resetn_i so unless we get other assertions
  // sensitive to dbg_resetn_i we cant have this implemented.


  // ---------------------------------------------------------------------------
  // System Metrics Events
  // ---------------------------------------------------------------------------

  // These event signals indicate the completion of a data pagewalk or
  // instruction pagewalk respectively.
  //  input          tlb_evnt_data_pagewalk    valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_evnt_data_pagewalk X or Z")
  u_ovl_intf_x_tlb_evnt_data_pagewalk (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_evnt_data_pagewalk));

  //  input          tlb_evnt_instr_pagewalk   valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_evnt_instr_pagewalk X or Z")
  u_ovl_intf_x_tlb_evnt_instr_pagewalk (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_evnt_instr_pagewalk));



  // ---------------------------------------------------------------------------
  // Parity Error
  // ---------------------------------------------------------------------------

  // tlb_pty_valid:
  // Indicate that there is a parity error on the TLB RAMs to allow the DPU cp15
  // CPUMERRSR register and events to be updated.
  // This signal must always be valid (never x) and must be one-shot (single-cycle)
  // for each parity error, though it is possible to get back-to-back parity
  // errors.
  //  input        tlb_pty_valid         valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_pty_valid X or Z")
  u_ovl_intf_x_tlb_pty_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_pty_valid));


  // tlb_pty_way_bank_id:
  // On a valid parity error indicate which way produced the error:
  // 2'b00 = Way-0
  // 2'b01 = Way-1
  // 2'b10 = Way-2
  // 2'b11 = Way-3
  //  input [1:0]  tlb_pty_way_bank_id   valid tlb_pty_valid timing 50%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "tlb_pty_way_bank_id X or Z")
  u_ovl_intf_x_tlb_pty_way_bank_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_pty_valid),
    .test_expr (tlb_pty_way_bank_id));


  // tlb_pty_index:
  // On a vald parity error indicate the index of the RAM which produced the error.
  // Essentially this bus communicates the unmodified RAM address to allow partners
  // to identify which portion of the RAM has failed.
  //  input [7:0]  tlb_pty_index         valid tlb_pty_valid timing 50%

  assert_never_unknown #(`OVL_FATAL, 8, INOPTIONS, "tlb_pty_index X or Z")
  u_ovl_intf_x_tlb_pty_index (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_pty_valid),
    .test_expr (tlb_pty_index));



endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "cortexa53params.v"
`include "ca53_dpu_tlb_defs.v"
`undef CA53_UNDEFINE

`endif

