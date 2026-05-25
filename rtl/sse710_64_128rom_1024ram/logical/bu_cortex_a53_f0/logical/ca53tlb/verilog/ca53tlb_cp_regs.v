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
// Abstract : TLB CP15 Register block. This does not contain debug registers.
//-----------------------------------------------------------------------------

`include "ca53tlb_defs.v"
`include "ca53_biu_tlb_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53_dpu_tlb_defs.v"
`include "ca53_ifu_tlb_defs.v"
`include "ca53_tlb_rams_defs.v"
`include "cortexa53params.v"

module ca53tlb_cp_regs `CA53_TLB_PARAM_DECL
  (
   input  wire                         clk,
   input  wire                         clk_cpregs,
   input  wire                         reset_n,

   input  wire [5:0]                   dcu_cp_reg_en_dc2_i,
   input  wire [63:0]                  dbg_cp_read_data_dc2_i,
   output wire [63:0]                  tlb_cp_read_data_dc2_o,
   input  wire                         dcu_cp_reg_write_dc3_i,
   input  wire [5:0]                   dcu_cp_reg_en_dc3_i,
   input  wire [63:0]                  dcu_cp_reg_data_i,
   input  wire                         dcu_cp_reg_size_i,
   input  wire                         tlb_cp_reg_write_ready_i,
   input  wire                         dpu_scr_el3_ns_i,
   input  wire                         dpu_ns_state_i,

   input  wire                         pagewalk_ns_i,
   input  wire                         pagewalk_hyp_i,
   input  wire                         lookup_ns_i,
   input  wire                         lookup_el2_i,
   input  wire [1:0]                   lookup_exception_level_i,
   input  wire                         lookup_aarch64_i,
   input  wire                         dpu_current_a64_i,
   input  wire [1:0]                   dpu_exception_level_i,
   input  wire [3:1]                   dpu_aarch64_at_el_i,
   output wire                         tlb_lpae_mode_o,
   output wire                         tlb_lpae_mode_s_o,

   output wire [47:4]                  ttbr0_addr_o,
   output wire [47:4]                  ttbr1_addr_o,
   output wire [47:4]                  httbr_addr_o,
   output wire [47:4]                  vttbr_addr_o,
   output wire [2:0]                   ttbcr_t0sz_o,
   output wire [2:0]                   ttbcr_t1sz_o,
   output wire [1:0]                   ttbcr_epd_o,
   output wire [5:0]                   ttbcr_attrs0_o,
   output wire [5:0]                   ttbcr_attrs1_o,
   output wire                         ttbcr_eae_s_o,
   output wire                         ttbcr_eae_ns_o,
   output wire [2:0]                   htcr_t0sz_o,
   output wire [5:0]                   htcr_attrs_o,
   output wire [5:0]                   vtcr_attrs_o,
   output wire [5:0]                   vtcr_t0sz_o,
   output wire [1:0]                   vtcr_sl0_o,
   output wire                         vtcr_tg0_o,
   output wire [2:0]                   vtcr_ps_o,
   output wire [31:0]                  mair0_o,
   output wire [31:0]                  mair1_o,
   output wire [31:0]                  context_id_o,
   output wire [31:0]                  context_id_etm_o,
   output wire [`CA53_ASID_W-1:0]      asid_lookup_o,
   output wire [`CA53_ASID_W-1:0]      asid_a32_pagewalk_o,
   output wire [`CA53_ASID_W-1:0]      asid_a64_pagewalk_o,
   output wire                         tcr_tbi0_o,
   output wire                         tcr_tbi1_o,
   output wire [1:0]                   tlb_d_tcr_el1_tbi_o,
   output wire                         tlb_d_tcr_el2_tbi0_o,
   output wire                         tlb_d_tcr_el3_tbi0_o,
   output wire [7:0]                   tlb_vmid_o,

   output wire [47:4]                  ttbr0_a64_el1_addr_o,
   output wire [47:4]                  ttbr1_a64_el1_addr_o,
   output wire [47:4]                  ttbr0_a64_el2_addr_o,
   output wire [47:4]                  ttbr0_a64_el3_addr_o,

   output wire [5:0]                   tcr_a64_el1_t0sz_o,
   output wire [5:0]                   tcr_a64_el1_t1sz_o,
   output wire [5:0]                   tcr_a64_el2_t0sz_o,
   output wire [5:0]                   tcr_a64_el3_t0sz_o,

   output wire [2:0]                   tcr_a64_el1_ips_o,
   output wire [2:0]                   tcr_a64_el2_ps_o,
   output wire [2:0]                   tcr_a64_el3_ps_o,

   output wire [1:0]                   tcr_a64_el1_epd_o,

   output wire [5:0]                   tcr_a64_el1_attrs0_o,
   output wire [5:0]                   tcr_a64_el1_attrs1_o,
   output wire [5:0]                   tcr_a64_el3_attrs_o,
   output wire                         tcr_a64_el1_tg0_o,
   output wire                         tcr_a64_el1_tg1_o,
   output wire                         tcr_a64_el2_tg0_o,
   output wire                         tcr_a64_el3_tg0_o,

   input  wire                         dcu_ongoing_burst_dc1_i,
   output wire                         tlb_i_utlb_flush_o,
   output wire                         tlb_d_utlb_flush_o,
   input  wire                         cp_inv_finished_i,
   input  wire                         pagewalk_i_utlb_enable_i,
   input  wire                         pagewalk_d_utlb_enable_i,
   input  wire                         pagewalk_invalidated_i,
   input  wire                         pagewalk_aarch64_at_el3_i,
   input  wire [1:0]                   pagewalk_exception_level_i,

   input  wire                         mbist_en_i,
   input  wire                         dcu_mbist_sel_i,
   input  wire                         dcu_mbist_cfg_mb3_i,
   input  wire                         dcu_mbist_read_en_mb3_i,
   input  wire                         dcu_mbist_write_en_mb3_i,
   input  wire [6:0]                   dcu_mbist_array_mb3_i,
   input  wire [116:0]                 mbist_in_data_mb3_i,
   output wire [`CA53_TLB_RAM_W-1:0]   mbist_in_data_mb4_o,
   output wire [3:0]                   mbist_read_en_mb4_o,
   output wire [3:0]                   mbist_write_en_mb4_o,
   output wire [116:0]                 tlb_mbist_out_data_mb6_o,

   input  wire                         ifu_cp_dbg_valid_i,
   input  wire [31:0]                  ifu_cp_dbg_1_i,
   input  wire [31:0]                  ifu_cp_dbg_0_i,

   input  wire                         dbgdr_reg_wr_en_i,
   input  wire [`CA53_TLB_RAM_W-1:0]   dbgdr_reg_wr_data_i,
   input  wire                         dpu_dbg_vid_ns_i,

   input  wire                         dpu_mmu_on_el3_i,
   input  wire                         dpu_mmu_on_el2_i,
   input  wire                         dpu_mmu_on_el1_i,
   input  wire                         dpu_ipa_to_pa_en_i,
   input  wire                         dpu_default_cacheable_i,
   output wire [1:0]                   tlb_mem_granule_o
   );

  //------------------------------------------------------------------------------
  // Flop declarations
  //------------------------------------------------------------------------------

  reg [54:0]                           ttbr0_value_s;
  reg [54:0]                           ttbr1_value_s;
  reg [62:0]                           ttbr0_value_ns;
  reg [62:0]                           ttbr1_value_ns;

  reg [51:0]                           vttbr_value_ns;
  reg [43:0]                           httbr_value_ns;
  reg [26:0]                           ttbcr_value_s;
  reg [16:0]                           htcr_value_ns;
  reg [17:0]                           vtcr_value_ns;
  reg [35:0]                           ttbcr_value_ns;
  reg [47:0]                           par_value_s;
  reg [47:0]                           par_value_ns;
  reg [31:0]                           mair0_value_s;
  reg [31:0]                           mair0_value_ns;
  reg [31:0]                           mair1_value_s;
  reg [31:0]                           mair1_value_ns;
  reg [31:0]                           hmair0_value_ns;
  reg [31:0]                           hmair1_value_ns;
  reg [31:0]                           context_id_value_s;
  reg [31:0]                           context_id_value_ns;
  reg [31:0]                           dbgdr0_value;
  reg [31:0]                           dbgdr1_value;
  reg [31:0]                           dbgdr2_value;
  reg [`CA53_TLB_RAM_W-1:96]           dbgdr3_value;
  reg                                  i_utlb_flush;
  reg                                  d_utlb_flush;
  reg                                  pagewalk_invalidated_flush;

  reg [1:0]                            tlb_mem_granule;
  //------------------------------------------------------------------------------
  // Wire declarations
  //------------------------------------------------------------------------------

  wire                                 wr_enable_ns;
  wire                                 wr_enable_s;
  wire                                 wr_enable_unbanked;

  wire [63:0]                          read_ttbr0_value_s;
  wire                                 wr_enable_ttbr0_s_only;
  wire                                 wr_enable_ttbr0_el3_only;
  wire                                 wr_enable_ttbr0_s;
  wire                                 wr_enable_ttbr0_s_hi;
  wire [63:0]                          read_ttbr0_value_ns;
  wire                                 wr_enable_ttbr0_ns;
  wire                                 wr_enable_ttbr0_ns_hi;

  wire [63:0]                          read_ttbr1_value_s;
  wire                                 wr_enable_ttbr1_s;
  wire                                 wr_enable_ttbr1_s_hi;
  wire [63:0]                          read_ttbr1_value_ns;
  wire                                 wr_enable_ttbr1_ns;
  wire                                 wr_enable_ttbr1_ns_hi;

  wire [63:0]                          read_vttbr_value_ns;
  wire                                 wr_enable_vttbr_ns;
  wire                                 wr_enable_vttbr_ns_hi;

  wire [63:0]                          read_httbr_value_ns;
  wire                                 wr_enable_httbr_ns;
  wire                                 wr_enable_httbr_ns_hi;

  wire [63:0]                          read_ttbcr_value_s;
  wire                                 wr_enable_ttbcr_s_only;
  wire                                 wr_enable_tcr_el3_only;
  wire                                 wr_enable_ttbcr_s;
  wire [63:0]                          read_ttbcr_value_ns;
  wire                                 wr_enable_ttbcr_ns;
  wire                                 wr_enable_ttbcr_ns_hi;

  wire [63:0]                          read_htcr_value_ns;
  wire                                 wr_enable_htcr_ns;

  wire [63:0]                          read_vtcr_value_ns;
  wire                                 wr_enable_vtcr_ns;

  wire [63:0]                          read_par_value_s;
  wire                                 wr_enable_par_s;
  wire                                 wr_enable_par_s_hi;
  wire [63:0]                          read_par_value_ns;
  wire                                 wr_enable_par_ns;
  wire                                 wr_enable_par_ns_hi;

  wire [31:0]                          next_mair0_value_s;
  wire [63:0]                          read_mair0_value_s;
  wire                                 wr_enable_mair0_s_only;
  wire                                 wr_enable_mair0_el3_only;
  wire                                 wr_enable_mair0_s;
  wire [31:0]                          next_mair0_value_ns;
  wire [63:0]                          read_mair0_value_ns;
  wire                                 wr_enable_mair0_ns;

  wire [63:0]                          read_mair1_value_s;
  wire                                 wr_enable_mair1_s_only;
  wire                                 wr_enable_mair1_el3_only;
  wire                                 wr_enable_mair1_s;
  wire [63:0]                          read_mair1_value_ns;
  wire                                 wr_enable_mair1_ns;

  wire [63:0]                          read_hmair0_value_ns;
  wire                                 wr_enable_hmair0_ns;

  wire [63:0]                          read_hmair1_value_ns;
  wire                                 wr_enable_hmair1_ns;

  wire [63:0]                          read_context_id_value_s;
  wire                                 wr_enable_context_id_s;
  wire [63:0]                          read_context_id_value_ns;
  wire                                 wr_enable_context_id_ns;

  wire [31:0]                          next_dbgdr0_value;
  wire [63:0]                          read_dbgdr0_value;
  wire                                 wr_enable_dbgdr_reg;
  wire                                 wr_enable_dbgdr;

  wire [31:0]                          next_dbgdr1_value;
  wire [63:0]                          read_dbgdr1_value;

  wire [31:0]                          next_dbgdr2_value;
  wire [63:0]                          read_dbgdr2_value;

  wire [`CA53_TLB_RAM_W-1:96]          next_dbgdr3_value;
  wire [63:0]                          read_dbgdr3_value;

  wire                                 utlb_flush_cp;
  wire                                 next_i_utlb_flush;
  wire                                 next_d_utlb_flush;
  wire                                 next_pagewalk_invalidated_flush;

  wire [7:0]                           asid_s;
  wire [7:0]                           asid_ns;

  wire                                 rd_el3_a32_curr_ns;
  wire                                 rd_el3_a32_curr_s;
  wire                                 rd_el3_a64;
  wire                                 rd_el3_a64_curr_a32;

  wire [31:0]                          next_mair1_value_s;
  wire [31:0]                          next_mair1_value_ns;
  wire [31:0]                          next_hmair1_value_ns;

  wire [`CA53_ASID_W-1:0]              asid_a32_lookup;
  wire [`CA53_ASID_W-1:0]              asid_a64_lookup;

  wire [31:0]                          next_mair1_value_ns_func;
  wire [29:0]                          next_mair1_value_ns_mbist;
  wire [3:0]                           tlb_mbist_sel_mb3;

  wire                                 vtcr_tg0;
  wire                                 tcr_a64_el1_tg0;
  wire                                 tcr_a64_el1_tg1;
  wire                                 tcr_a64_el2_tg0;
  wire                                 tcr_a64_el3_tg0;
  wire [1:0]                           tcr_a64_el1_epd;
  wire                                 el1_tg01;
  wire                                 el01_sec_with_g64k;
  wire                                 el01_nsec_with_g64k;
  wire                                 el2_with_g64k;
  wire                                 el3_with_g64k;

  wire [1:0]                           next_tlb_mem_granule;

  //------------------------------------------------------------------------------
  // Global enables
  //------------------------------------------------------------------------------

  assign wr_enable_ns = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & dpu_scr_el3_ns_i;
  assign wr_enable_s  = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & ~dpu_scr_el3_ns_i;
  assign wr_enable_unbanked = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i;

  //------------------------------------------------------------------------------
  // Secure TTBR0 register
  //------------------------------------------------------------------------------

  // These flops are accessed for
  //   EL3  EL1
  //   A32  A32  CA53_CP15_REG_TTBR0_EL1 in secure state.
  //             No separate regs for EL3 in AR32.
  //   A64  A32  CA53_CP15_REG_TTBR0_EL3, irrespective of the security state.
  //             (CA53_CP15_REG_TTBR0_EL1 accesses ttbr0_value_ns flops instead of ttbr0_value_s)
  //   A64  A64  CA53_CP15_REG_TTBR0_EL3 irrespective of security state.
  //             (CA53_CP15_REG_TTBR0_EL1 accesses ttbr0_value_ns flops instead of ttbr0_value_s)
  assign wr_enable_ttbr0_s_only   = (~dpu_aarch64_at_el_i[3] & wr_enable_s & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_TTBR0_EL1));
  assign wr_enable_ttbr0_el3_only = ( dpu_aarch64_at_el_i[3] & wr_enable_unbanked & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_TTBR0_EL3));
  assign wr_enable_ttbr0_s        = wr_enable_ttbr0_s_only | wr_enable_ttbr0_el3_only;

  assign wr_enable_ttbr0_s_hi = wr_enable_ttbr0_s & dcu_cp_reg_size_i;


  always @(posedge clk_cpregs)
  if (wr_enable_ttbr0_s) begin
    ttbr0_value_s[30:0] <= {dcu_cp_reg_data_i[31:3],dcu_cp_reg_data_i[1:0]};
  end

  always @(posedge clk_cpregs)
  if (wr_enable_ttbr0_s_hi) begin
    ttbr0_value_s[54:31] <= dcu_cp_reg_data_i[55:32]; // TTBR0 has 8-bit ASID, TTBR_EL3 doesn't use ASID
  end

  assign read_ttbr0_value_s = {8'h00,                // [63:56] TTBR0 have 8-bit ASID, TTBR_EL3 doesn't have ASID
                               ttbr0_value_s[54:31], // [55:32]
                               ttbr0_value_s[30:2],  // [31:3]
                               1'b0,                 // [2]
                               ttbr0_value_s[1:0]};  // [1:0]

  //------------------------------------------------------------------------------
  // Non-secure TTBR0 register
  //------------------------------------------------------------------------------

  // These flops are accessed for
  //   EL3  EL1
  //   A32  A32  CA53_CP15_REG_TTBR0_EL1/CA53_CP15_REG_TTBR0_EL1 (same) address in NS state
  //   A64  A32  CA53_CP15_REG_TTBR0_EL1/CA53_CP15_REG_TTBR0_EL1 (same) address irrespective of
  //             state, with A32 format
  //   A64  A64  CA53_CP15_REG_TTBR0_EL1/CA53_CP15_REG_TTBR0_EL1 (same) address irrespective of
  //             state, with A64 format
  assign wr_enable_ttbr0_ns = (~dpu_aarch64_at_el_i[3] & wr_enable_ns & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_TTBR0_EL1)) |
                              ( dpu_aarch64_at_el_i[3] & wr_enable_unbanked & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_TTBR0_EL1));

  assign wr_enable_ttbr0_ns_hi = wr_enable_ttbr0_ns & dcu_cp_reg_size_i;

  always @(posedge clk_cpregs)
  if (wr_enable_ttbr0_ns) begin
    ttbr0_value_ns[30:0]  <= {dcu_cp_reg_data_i[31:3],dcu_cp_reg_data_i[1:0]};
  end

  always @(posedge clk_cpregs)
  if (wr_enable_ttbr0_ns_hi) begin
    ttbr0_value_ns[62:31] <= dcu_cp_reg_data_i[63:32];
  end

  // ASID is 8-bits in A32 with LPAE,  8/16 bit in A64
  assign read_ttbr0_value_ns = {ttbr0_value_ns[62:31], // [63:32]
                                ttbr0_value_ns[30:2],  // [31:3]
                                1'b0,                  // [2]
                                ttbr0_value_ns[1:0]};  // [1:0]

  //------------------------------------------------------------------------------
  // Secure TTBR1 register
  //------------------------------------------------------------------------------

  // These flops are accessed for
  //   EL3  EL1
  //   A32  A32  CA53_CP15_REG_TTBR1_EL1 address in secure state
  //   A64  A32  Unused (CA53_CP15_REG_TTBR1_EL1 will access ttbr1_value_ns flops instead of ttbr1_value_s,
  //             irrespective of security state, with A32 format)
  //   A64  A64  Unused (CA53_CP15_REG_TTBR1_EL1 will access ttbr1_value_ns flops instead of ttbr1_value_s,
  //             irrespective of security state, with A64 format)
  assign wr_enable_ttbr1_s    = ~dpu_aarch64_at_el_i[3] & wr_enable_s & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_TTBR1_EL1);
  assign wr_enable_ttbr1_s_hi = wr_enable_ttbr1_s & dcu_cp_reg_size_i;


  always @(posedge clk_cpregs)
  if (wr_enable_ttbr1_s) begin
    ttbr1_value_s[30:0] <= {dcu_cp_reg_data_i[31:3],dcu_cp_reg_data_i[1:0]};
  end

  always @(posedge clk_cpregs)
  if (wr_enable_ttbr1_s_hi) begin
    ttbr1_value_s[54:31] <= dcu_cp_reg_data_i[55:32];
  end

  assign read_ttbr1_value_s = {8'h00,                // [63:56]
                               ttbr1_value_s[54:47], // [55:48]
                               ttbr1_value_s[46:39], // [47:40]
                               ttbr1_value_s[38:31], // [39:32]
                               ttbr1_value_s[30:2],  // [31:3]
                               1'b0,                 // [2]
                               ttbr1_value_s[1:0]};  // [1:0]

  //------------------------------------------------------------------------------
  // Non-secure TTBR1 register
  //------------------------------------------------------------------------------

  // These flops are accessed for
  //   EL3  EL1
  //   A32  A32  CA53_CP15_REG_TTBR1_EL1/CA53_CP15_REG_TTBR1_EL1 (same) address in NS state
  //   A64  A32  CA53_CP15_REG_TTBR1_EL1/CA53_CP15_REG_TTBR1_EL1 address irrespective of
  //             state, with A32 format
  //   A64  A64  CA53_CP15_REG_TTBR1_EL1/CA53_CP15_REG_TTBR1_EL1 address irrespective of
  //             state, with A64 format
  assign wr_enable_ttbr1_ns = (~dpu_aarch64_at_el_i[3] & wr_enable_ns & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_TTBR1_EL1)) |
                              ( dpu_aarch64_at_el_i[3] & wr_enable_unbanked & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_TTBR1_EL1));

  assign wr_enable_ttbr1_ns_hi = wr_enable_ttbr1_ns & dcu_cp_reg_size_i;

  always @(posedge clk_cpregs)
  if (wr_enable_ttbr1_ns) begin
    ttbr1_value_ns[30:0] <= {dcu_cp_reg_data_i[31:3],dcu_cp_reg_data_i[1:0]};
  end

  always @(posedge clk_cpregs)
  if (wr_enable_ttbr1_ns_hi) begin
    ttbr1_value_ns[62:31] <= dcu_cp_reg_data_i[63:32];
  end

  assign read_ttbr1_value_ns = {ttbr1_value_ns[62:31],  // [63:32]
                                ttbr1_value_ns[30:2],   // [31:3]
                                1'b0,                   // [2]
                                ttbr1_value_ns[1:0]};   // [1:0]

  //------------------------------------------------------------------------------
  // VTTBR register
  //------------------------------------------------------------------------------

  // These flops are accessed for
  //   EL3  EL2
  //   A32  A32  CA53_CP15_REG_VTTBR_EL2/CA53_CP15_REG_VTTBR_EL2 (same) address in NS state
  //   A64  A32  CA53_CP15_REG_VTTBR_EL2/CA53_CP15_REG_VTTBR_EL2 (same) address irrespective of
  //             state, with A32 format
  //   A64  A64  CA53_CP15_REG_VTTBR_EL2/CA53_CP15_REG_VTTBR_EL2 (same) address irrespective of
  //             state, with A64 format
  assign wr_enable_vttbr_ns = (~dpu_aarch64_at_el_i[3] & wr_enable_ns & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_VTTBR_EL2)) |
                              ( dpu_aarch64_at_el_i[3] & wr_enable_unbanked & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_VTTBR_EL2));
  assign wr_enable_vttbr_ns_hi = wr_enable_vttbr_ns & dcu_cp_reg_size_i;

  always @(posedge clk_cpregs)
  if (wr_enable_vttbr_ns) begin
    vttbr_value_ns[27:0] <= dcu_cp_reg_data_i[31:4];
  end

  always @(posedge clk_cpregs)
  if (wr_enable_vttbr_ns_hi) begin
    vttbr_value_ns[43:28] <=  dcu_cp_reg_data_i[47:32];
  end

  // Only the VMID bits need to be reset
  always @(posedge clk_cpregs or negedge reset_n)
  if (~reset_n) begin
    vttbr_value_ns[51:44] <= {8{1'b0}};
  end else if (wr_enable_vttbr_ns_hi) begin
    vttbr_value_ns[51:44] <= dcu_cp_reg_data_i[55:48];
  end

  assign read_vttbr_value_ns = {8'h00,                   // [63:52]
                                vttbr_value_ns[51:44],   // [55:48]
                                vttbr_value_ns[43:28],   // [47:32]
                                vttbr_value_ns[27:0],    // [31:4]
                                4'b0000};                // [3:0]

  assign tlb_vmid_o = vttbr_value_ns[51:44];

  //------------------------------------------------------------------------------
  // HTTBR register
  //------------------------------------------------------------------------------

  // These flops are accessed for
  //   EL3  EL2
  //   A32  A32  CA53_CP15_REG_TTBR0_EL2/CA53_CP15_REG_TTBR0_EL2 (same) address in NS state
  //   A64  A32  CA53_CP15_REG_TTBR0_EL2/CA53_CP15_REG_TTBR0_EL2 (same) address irrespective of
  //             state, with A32 format
  //   A64  A64  CA53_CP15_REG_TTBR0_EL2/CA53_CP15_REG_TTBR0_EL2 (same) address irrespective of
  //             state, with A64 format
  assign wr_enable_httbr_ns = (~dpu_aarch64_at_el_i[3] & wr_enable_ns & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_TTBR0_EL2)) |
                              ( dpu_aarch64_at_el_i[3] & wr_enable_unbanked & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_TTBR0_EL2));

  assign wr_enable_httbr_ns_hi = wr_enable_httbr_ns & dcu_cp_reg_size_i;

  always @(posedge clk_cpregs)
  if (wr_enable_httbr_ns) begin
    httbr_value_ns[27:0] <= dcu_cp_reg_data_i[31:4];
  end

  always @(posedge clk_cpregs)
  if (wr_enable_httbr_ns_hi) begin
    httbr_value_ns[43:28] <= dcu_cp_reg_data_i[47:32];
  end

  assign read_httbr_value_ns = {16'h0000,              // [63:48]
                                httbr_value_ns[43:28], // [47:32]
                                httbr_value_ns[27:0],  // [31:4]
                                4'b0000};              // [3:0]

  //------------------------------------------------------------------------------
  // Secure TTBCR register
  //------------------------------------------------------------------------------

  // These flops are accessed for
  //   EL3  EL1
  //   A32  A32  CA53_CP15_REG_TCR_EL1 in secure state.
  //             No separate regs for EL3 in AR32.
  //   A64  A32  No banking. CA53_CP15_REG_TCR_EL1 (same as CA53_CP15_REG_TTBCR_EL1) accesses ttbcr_value_ns
  //             flops instead of ttbcr_value_s
  //             CA53_CP15_REG_TTBR0_EL3, irrespective of the security state
  //   A64  A64  No banking. CA53_CP15_REG_TCR_EL1 (same as CA53_CP15_REG_TTBCR_EL1) accesses ttbcr_value_ns
  //             flops instead of ttbcr_value_s
  //             CA53_CP15_REG_TCR_EL3, irrespective of security state.
  assign wr_enable_ttbcr_s_only = (~dpu_aarch64_at_el_i[3] & wr_enable_s & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_TCR_EL1));
  assign wr_enable_tcr_el3_only = ( dpu_aarch64_at_el_i[3] & wr_enable_unbanked & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_TCR_EL3));
  assign wr_enable_ttbcr_s = wr_enable_ttbcr_s_only | wr_enable_tcr_el3_only;

  always @(posedge clk_cpregs or negedge reset_n)
  if (~reset_n) begin
    ttbcr_value_s <= {27{1'b0}};
  end else if (wr_enable_ttbcr_s) begin
    ttbcr_value_s <= {dcu_cp_reg_data_i[31],
                      dcu_cp_reg_data_i[29:22],
                      dcu_cp_reg_data_i[20],
                      dcu_cp_reg_data_i[18:16],
                      dcu_cp_reg_data_i[14:7],
                      dcu_cp_reg_data_i[5:0]};
  end

  assign read_ttbcr_value_s = {32'h00000000,         // [63:32]
                               ttbcr_value_s[26],    // [31]
                               1'b0,                 // [30]
                               ttbcr_value_s[25:18], // [29:22]
                               1'b0,                 // [21]
                               ttbcr_value_s[17],    // [20]
                               1'b0,                 // [19]
                               ttbcr_value_s[16:14], // [18:16]
                               1'b0,                 // [15]
                               ttbcr_value_s[13:6],  // [14:7]
                               1'b0,                 // [6]
                               ttbcr_value_s[5:0]};  // [5:0]

  //------------------------------------------------------------------------------
  // Non-secure TTBCR register
  //------------------------------------------------------------------------------

  // These flops are accessed for
  //   EL3  EL1
  //   A32  A32  CA53_CP15_REG_TCR_EL1/CA53_CP15_REG_TCR_EL1 (same) address in NS state
  //   A64  A32  CA53_CP15_REG_TCR_EL1/CA53_CP15_REG_TCR_EL1 (same) address irrespective of
  //             state, with A32 format
  //   A64  A64  CA53_CP15_REG_TCR_EL1/CA53_CP15_REG_TCR_EL1 (same) address irrespective of
  //             state, with A64 format
  assign wr_enable_ttbcr_ns = (~dpu_aarch64_at_el_i[3] & wr_enable_ns & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_TCR_EL1)) |
                              ( dpu_aarch64_at_el_i[3] & wr_enable_unbanked & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_TCR_EL1));

  assign wr_enable_ttbcr_ns_hi = wr_enable_ttbcr_ns & dcu_cp_reg_size_i;

  // Bit[31] is not used in A64 but used in A32
  always @(posedge clk_cpregs or negedge reset_n)
  if (~reset_n) begin
    ttbcr_value_ns[29:0] <= {30{1'b0}};
  end else if (wr_enable_ttbcr_ns) begin
    ttbcr_value_ns[29:0] <= {dcu_cp_reg_data_i[31:16], dcu_cp_reg_data_i[14:7], dcu_cp_reg_data_i[5:0]};
  end

  always @(posedge clk_cpregs or negedge reset_n)
  if (~reset_n) begin
    ttbcr_value_ns[35:30] <= {6{1'b0}};
  end else if (wr_enable_ttbcr_ns_hi) begin
    ttbcr_value_ns[35:30] <= {dcu_cp_reg_data_i[38:36], dcu_cp_reg_data_i[34:32]};
  end

  assign read_ttbcr_value_ns = {{25{1'b0}},             // [63:39]
                                ttbcr_value_ns[35:33],  // [38:36]
                                1'b0,                   // [35]
                                ttbcr_value_ns[32:30],  // [34:32]
                                ttbcr_value_ns[29],     // [31]
                                ttbcr_value_ns[28:14],  // [30:16]
                                1'b0,                   // [15]
                                ttbcr_value_ns[13:6],   // [14:7]
                                1'b0,                   // [6]
                                ttbcr_value_ns[5:0]};   // [5:0]

  //------------------------------------------------------------------------------
  // HTCR register
  //------------------------------------------------------------------------------

  // These flops are accessed for
  //   EL3  EL2
  //   A32  A32  CA53_CP15_REG_TCR_EL2/CA53_CP15_REG_TCR_EL2 (same) address in NS state
  //   A64  A32  CA53_CP15_REG_TCR_EL2/CA53_CP15_REG_TCR_EL2 (same) address irrespective of
  //             state, with A32 format
  //   A64  A64  CA53_CP15_REG_TCR_EL2/CA53_CP15_REG_TCR_EL2 (same) address irrespective of
  //             state, with A64 format
  assign wr_enable_htcr_ns = (~dpu_aarch64_at_el_i[3] & wr_enable_ns & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_TCR_EL2)) |
                             ( dpu_aarch64_at_el_i[3] & wr_enable_unbanked & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_TCR_EL2));

  always @(posedge clk_cpregs or negedge reset_n)
  if (~reset_n) begin
    htcr_value_ns <= {17{1'b0}};
  end else if (wr_enable_htcr_ns) begin
    htcr_value_ns <= {dcu_cp_reg_data_i[20],
                      dcu_cp_reg_data_i[18:16],
                      dcu_cp_reg_data_i[14:8],
                      dcu_cp_reg_data_i[5:0]};
  end

  assign read_htcr_value_ns = {32'h00000000,          // [63:32]
                               1'b1,                  // [31]
                               {7{1'b0}},             // [30:24]
                               1'b1,                  // [23]
                               {2{1'b0}},             // [22:21]
                               htcr_value_ns[16],     // [20]
                               1'b0,                  // [19]
                               htcr_value_ns[15:13],  // [18:16]
                               1'b0,                  // [15]
                               htcr_value_ns[12:6],   // [14:8]
                               2'b00,                 // [7:6]
                               htcr_value_ns[5:0]};   // [5:0]

  //------------------------------------------------------------------------------
  // VTCR register
  //------------------------------------------------------------------------------

  // These flops are accessed for
  //   EL3  EL2
  //   A32  A32  CA53_CP15_REG_VTCR_EL2/CA53_CP15_REG_VTCR_EL2 (same) address in NS state
  //   A64  A32  CA53_CP15_REG_VTCR_EL2/CA53_CP15_REG_VTCR_EL2 (same) address irrespective of
  //             state, with A32 format
  //   A64  A64  CA53_CP15_REG_VTCR_EL2/CA53_CP15_REG_VTCR_EL2 (same) address irrespective of
  //             state, with A64 format
  assign wr_enable_vtcr_ns = (~dpu_aarch64_at_el_i[3] & wr_enable_ns & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_VTCR_EL2)) |
                             ( dpu_aarch64_at_el_i[3] & wr_enable_unbanked & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_VTCR_EL2));

  always @(posedge clk_cpregs)
  if (wr_enable_vtcr_ns) begin
    vtcr_value_ns <= {dcu_cp_reg_data_i[18:16],dcu_cp_reg_data_i[14:0]};
  end

  assign read_vtcr_value_ns ={32'h00000000,         // [63:32]
                              1'b1,                 // [31]
                              {12{1'b0}},           // [30:19]
                              vtcr_value_ns[17:15], // [18:16]
                              1'b0,                 // [15]
                              vtcr_value_ns[14:5],  // [14:5]
                              vtcr_value_ns[4],     // [4]
                              vtcr_value_ns[3:0]};  // [3:0]

  //------------------------------------------------------------------------------
  // Secure PAR register
  //------------------------------------------------------------------------------

  // The V2P op is a write-only ghost operation in the DCU pipeline, so doesn't
  // need factoring into the read.
  //
  // The ns bits used here are different for the two ops because a register write
  // to the PAR using an MCR uses ns_scr like all of the other register writes, but
  // V2P ops use the current security state of the processor to determine which
  // version of the register to write.

  // These flops are accessed for
  //   EL3  EL1
  //   A32  A32  CA53_CP15_REG_PAR_EL1 address in secure state
  //   A64  A32  CA53_CP15_REG_PAR_EL1 will access par_value_ns flops instead of par_value_s,
  //             irrespective of security state, with A32 format
  //   A64  A64  CA53_CP15_REG_PAR_EL1 will access par_value_ns flops instead of par_value_s,
  //             irrespective of security state, with A64 format
  assign wr_enable_par_s = (~dpu_aarch64_at_el_i[3] & dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i &
                            (((dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_PAR_EL1) & ~dpu_scr_el3_ns_i) |
                             ((dcu_cp_reg_en_dc3_i == `CA53_CP15_V2P_PAR) & ~dpu_ns_state_i)));
  assign wr_enable_par_s_hi = wr_enable_par_s & dcu_cp_reg_size_i;

  always @(posedge clk_cpregs)
  if (wr_enable_par_s) begin
    par_value_s[31:0] <=  dcu_cp_reg_data_i[31:0];
  end

  always @(posedge clk_cpregs)
  if (wr_enable_par_s_hi) begin
    par_value_s[47:32] <= {dcu_cp_reg_data_i[63:56],dcu_cp_reg_data_i[39:32]};
  end

  // Register is unused in A64
  assign read_par_value_s = {par_value_s[47:40],
                             16'h0000,
                             par_value_s[39:0]};

  //------------------------------------------------------------------------------
  // Non-secure PAR register
  //------------------------------------------------------------------------------

  // These flops are accessed for
  //   EL3  EL1
  //   A32  A32  CA53_CP15_REG_PAR_EL1/CA53_CP15_REG_PAR_EL1 (same) address in NS state
  //   A64  A32  CA53_CP15_REG_PAR_EL1/CA53_CP15_REG_PAR_EL1 (same) address irrespective
  //             of security state, with A32 format
  //   A64  A64  CA53_CP15_REG_PAR_EL1/CA53_CP15_REG_PAR_EL1 (same) address irrespective
  //             of security state, with A64 format
  assign wr_enable_par_ns = (~dpu_aarch64_at_el_i[3] & dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i &
                             (((dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_PAR_EL1) & dpu_scr_el3_ns_i) |
                              ((dcu_cp_reg_en_dc3_i == `CA53_CP15_V2P_PAR) & dpu_ns_state_i))) |
                            (dpu_aarch64_at_el_i[3] & dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i &
                             ((dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_PAR_EL1)  |
                              (dcu_cp_reg_en_dc3_i == `CA53_CP15_V2P_PAR)));
  assign wr_enable_par_ns_hi = wr_enable_par_ns & dcu_cp_reg_size_i;

  always @(posedge clk_cpregs)
  if (wr_enable_par_ns) begin
    par_value_ns[31:0] <= dcu_cp_reg_data_i[31:0];
  end

  always @(posedge clk_cpregs)
  if (wr_enable_par_ns_hi) begin
    par_value_ns[47:32] <= {dcu_cp_reg_data_i[63:56],dcu_cp_reg_data_i[39:32]};
  end

  assign read_par_value_ns = {par_value_ns[47:40],
                             16'h0000,
                             par_value_ns[39:0]}; // Read in A64 returns bit[11]  written in A32

  //------------------------------------------------------------------------------
  // Secure PRRR/MAIR0 register
  //------------------------------------------------------------------------------

  // MBIST makes use of this register to carry information from mb3 to mb4

  // LS 32 bits from mair1_s and from mair0_s make 64-bit mair_el3
  // These flops are accessed for
  //   EL3  EL1
  //   A32  A32  CA53_CP15_REG_MAIR0 in secure state.
  //             No separate regs for EL3 in AR32.
  //   A64  A32  No banking. CA53_CP15_REG_MAIR0 (same as CA53_CP15_REG_MAIR_EL1) accesses mair0_value_ns
  //             flops instead of mair0_value_s
  //             CA53_CP15_REG_MAIR_EL3, irrespective of security state (for LS 32-bits of MAIR_EL3)
  //   A64  A64  No banking. CA53_CP15_REG_MAIR0 (same as CA53_CP15_REG_MAIR_EL1) accesses mair0_value_ns
  //             flops instead of mair0_value_s
  //             CA53_CP15_REG_MAIR_EL3, irrespective of security state (for LS 32-bits of MAIR_EL3)
  assign wr_enable_mair0_s_only   = (~dpu_aarch64_at_el_i[3] & wr_enable_s & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_MAIR_EL1));
  assign wr_enable_mair0_el3_only = ( dpu_aarch64_at_el_i[3] & wr_enable_unbanked & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_MAIR_EL3));
  assign wr_enable_mair0_s = wr_enable_mair0_s_only | wr_enable_mair0_el3_only | mbist_en_i;

  assign next_mair0_value_s = mbist_en_i ? mbist_in_data_mb3_i[31:0] : dcu_cp_reg_data_i[31:0];

  always @(posedge clk_cpregs or negedge reset_n)
  if (~reset_n) begin
    mair0_value_s <= 32'h00098aa4;
  end else if (wr_enable_mair0_s) begin
    mair0_value_s <= next_mair0_value_s;
  end

  assign read_mair0_value_s = {32'h00000000,
                               mair0_value_s[31:0]};

  //------------------------------------------------------------------------------
  // Non-secure PRRR/MAIR0 register
  //------------------------------------------------------------------------------

  // MBIST makes use of this register to carry information from mb3 to mb4

  // LS 32 bits from mair1_ns and from mair0_ns make 64-bit mair_el1 if EL3 is
  // A64 and current exception level is also A64
  // These flops are accessed for
  //   EL3  EL1
  //   A32  A32  CA53_CP15_REG_MAIR0/CA53_CP15_REG_MAIR_EL1 (same) address in NS state
  //   A64  A32  CA53_CP15_REG_MAIR0/CA53_CP15_REG_MAIR_EL1 (same) address irrespective of
  //             security state, with A32 format i.e. as single 32-bit register
  //   A64  A64  CA53_CP15_REG_MAIR0/CA53_CP15_REG_MAIR_EL1 (same) address irrespective of
  //             security state, with A64 format for LS-32 bits of 64-bit MAIR_EL1
  assign wr_enable_mair0_ns = (~dpu_aarch64_at_el_i[3] & wr_enable_ns & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_MAIR_EL1)) |
                              ( dpu_aarch64_at_el_i[3] & ~dpu_current_a64_i & wr_enable_unbanked & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_MAIR_EL1)) |
                              ( dpu_aarch64_at_el_i[3] & dpu_current_a64_i  & wr_enable_unbanked & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_MAIR_EL1)) |
                               mbist_en_i;

  assign next_mair0_value_ns = mbist_en_i ? mbist_in_data_mb3_i[63:32] : dcu_cp_reg_data_i[31:0];

  always @(posedge clk_cpregs or negedge reset_n)
  if (~reset_n) begin
    mair0_value_ns <= 32'h00098aa4;
  end else if (wr_enable_mair0_ns) begin
    mair0_value_ns <= next_mair0_value_ns;
  end

  assign read_mair0_value_ns = {32'h00000000,
                                mair0_value_ns[31:0]};

  //------------------------------------------------------------------------------
  // Secure NMRR/MAIR1 register
  //------------------------------------------------------------------------------

  // LS 32 bits from mair1_s and from mair0_s make 64-bit mair_el3
  // These flops are accessed for
  //   EL3  EL1
  //   A32  A32  CA53_CP15_REG_MAIR1 in secure state.
  //             No separate regs for EL3 in AR32.
  //   A64  A32  No banking. CA53_CP15_REG_MAIR1 accesses mair1_value_ns
  //             flops instead of mair1_value_s
  //             CA53_CP15_REG_MAIR_EL3, irrespective of security state (for MS 32-bits of MAIR_EL3)
  //   A64  A64  No banking. CA53_CP15_REG_MAIR1 accesses mair1_value_ns
  //             flops instead of mair1_value_s
  //             CA53_CP15_REG_MAIR_EL3, irrespective of security state (for MS 32-bits of MAIR_EL3)
  assign wr_enable_mair1_s_only   = (~dpu_aarch64_at_el_i[3] & wr_enable_s & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_MAIR1));
  assign wr_enable_mair1_el3_only = ( dpu_aarch64_at_el_i[3] & wr_enable_unbanked & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_MAIR_EL3) & dcu_cp_reg_size_i);
  assign wr_enable_mair1_s        = wr_enable_mair1_s_only | wr_enable_mair1_el3_only | mbist_en_i;

  // MBIST select signal and MBIST are registered using MAIR register
  assign next_mair1_value_s =  mbist_en_i ? mbist_in_data_mb3_i[95:64] :
                                           ((dpu_aarch64_at_el_i[3] & dcu_cp_reg_size_i) ? dcu_cp_reg_data_i[63:32] :
                                                                                           dcu_cp_reg_data_i[31:0]);

  always @(posedge clk_cpregs or negedge reset_n)
  if (~reset_n) begin
    mair1_value_s <= 32'h44e048e0;
  end else if (wr_enable_mair1_s) begin
    mair1_value_s <= next_mair1_value_s;
  end

  assign read_mair1_value_s = {32'h00000000,
                               mair1_value_s[31:0]};

  //------------------------------------------------------------------------------
  // Non-secure NMRR/MAIR1 register
  //------------------------------------------------------------------------------

  // LS 32 bits from mair1_ns and from mair0_ns make 64-bit mair_el1
  // These flops are accessed for
  //   EL3  EL1
  //   A32  A32  CA53_CP15_REG_MAIR1 address in NS state
  //   A64  A32  CA53_CP15_REG_MAIR1 address irrespective of security state, with A32 format
  //   A64  A64  CA53_CP15_REG_MAIR_EL1 address irrespective of
  //             security state, for MS-32 bits of MAIR_EL1
  assign wr_enable_mair1_ns = (~dpu_aarch64_at_el_i[3] & wr_enable_ns & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_MAIR1)) |
                              (dpu_aarch64_at_el_i[3] & ~dpu_current_a64_i & wr_enable_unbanked & 
                                (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_MAIR1)) |
                              (dpu_aarch64_at_el_i[3] & dpu_current_a64_i & wr_enable_unbanked & 
                                (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_MAIR_EL1) & dcu_cp_reg_size_i) |
                              mbist_en_i;


  assign tlb_mbist_sel_mb3 = ({4{mair1_value_ns[29] & (dcu_mbist_array_mb3_i[6:3] == 4'b0100)}} &
                              {(dcu_mbist_array_mb3_i[1:0] == 2'b11),
                               (dcu_mbist_array_mb3_i[1:0] == 2'b10),
                               (dcu_mbist_array_mb3_i[1:0] == 2'b01),
                               (dcu_mbist_array_mb3_i[1:0] == 2'b00)}) |
                             {4{dcu_mbist_cfg_mb3_i}};

  // Functional value of mair1_ns register
  assign next_mair1_value_ns_func = (dpu_aarch64_at_el_i[3] & dpu_current_a64_i & dcu_cp_reg_size_i) ?
                                       dcu_cp_reg_data_i[63:32] : dcu_cp_reg_data_i[31:0];

  // MBIST data to be saved in register
  assign next_mair1_value_ns_mbist = {dcu_mbist_sel_i,                                     // mair1_value_ns[29]
                                      ({4{dcu_mbist_read_en_mb3_i}}  & tlb_mbist_sel_mb3), // mair1_value_ns[28:25]
                                      ({4{dcu_mbist_write_en_mb3_i}} & tlb_mbist_sel_mb3), // mair1_value_ns[24:21]
                                      mbist_in_data_mb3_i[116:96]};                        // mair1_value_ns[20:0]

  assign next_mair1_value_ns = {next_mair1_value_ns_func[31:30],
                                (mbist_en_i ? next_mair1_value_ns_mbist : next_mair1_value_ns_func[29:0])};

  always @(posedge clk_cpregs or negedge reset_n)
  if (~reset_n) begin
    mair1_value_ns <= 32'h44e048e0;
  end else if (wr_enable_mair1_ns) begin
    mair1_value_ns <= next_mair1_value_ns;
  end

  assign read_mair1_value_ns = {32'h00000000,
                                mair1_value_ns[31:0]};

  //------------------------------------------------------------------------------
  // HMAIR0 register
  //------------------------------------------------------------------------------

  // LS 32 bits from hmair1_ns and from hmair0_ns make 64-bit mair_el1
  // These flops are accessed for
  //   EL3  EL2
  //   A32  A32  CA53_CP15_REG_HMAIR0/CA53_CP15_REG_MAIR_EL2 (same) address in NS state.
  //   A64  A32  CA53_CP15_REG_HMAIR0/CA53_CP15_REG_MAIR_EL2 (same) address irrespective of
  //             state, with A32 format.
  //   A64  A64  CA53_CP15_REG_HMAIR0/CA53_CP15_REG_MAIR_EL2 (same) address irrespective of
  //             state, with A64 format, for LS-32 bits of CA53_CP15_REG_MAIR_EL2
  assign wr_enable_hmair0_ns = (~dpu_aarch64_at_el_i[3] & wr_enable_ns & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_MAIR_EL2)) |
                               ( dpu_aarch64_at_el_i[3] & ~dpu_current_a64_i & wr_enable_unbanked & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_MAIR_EL2)) |
                               ( dpu_aarch64_at_el_i[3] & dpu_current_a64_i &  wr_enable_unbanked & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_MAIR_EL2));

  always @(posedge clk_cpregs)
  if (wr_enable_hmair0_ns) begin
    hmair0_value_ns <= dcu_cp_reg_data_i[31:0];
  end

  assign read_hmair0_value_ns = {32'h00000000,
                                 hmair0_value_ns[31:0]};

  //------------------------------------------------------------------------------
  // HMAIR1 register
  //------------------------------------------------------------------------------

  // LS 32 bits from hmair1_ns and from hmair0_ns make 64-bit mair_el1
  // These flops are accessed for
  //   EL3  EL2
  //   A32  A32  CA53_CP15_REG_HMAIR1 address in NS state.
  //   A64  A32  CA53_CP15_REG_HMAIR1 address irrespective of security state, with A32 format
  //   A64  A64  CA53_CP15_REG_MAIR_EL2 address irrespective of
  //             state, with A64 format, for MS-32 bits of CA53_CP15_REG_MAIR_EL2
  assign wr_enable_hmair1_ns = (~dpu_aarch64_at_el_i[3] & wr_enable_ns & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_HMAIR1)) |
                               (dpu_aarch64_at_el_i[3] & ~dpu_current_a64_i & wr_enable_unbanked & 
                                (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_HMAIR1)) |
                               (dpu_aarch64_at_el_i[3] & dpu_current_a64_i & wr_enable_unbanked & 
                                (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_MAIR_EL2) & dcu_cp_reg_size_i); //MAIR_EL2[63:32] uses HAIR1 flops

  assign next_hmair1_value_ns = (dpu_aarch64_at_el_i[3] & dpu_current_a64_i & dcu_cp_reg_size_i) ? dcu_cp_reg_data_i[63:32] : dcu_cp_reg_data_i[31:0];

  always @(posedge clk_cpregs)
  if (wr_enable_hmair1_ns) begin
    hmair1_value_ns <= next_hmair1_value_ns;
  end

  assign read_hmair1_value_ns = {32'h00000000,
                                 hmair1_value_ns[31:0]};

  //------------------------------------------------------------------------------
  // Secure Context ID register
  //------------------------------------------------------------------------------

  assign wr_enable_context_id_s = (~dpu_aarch64_at_el_i[3] & wr_enable_s & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_CTXTID_EL1));

  always @(posedge clk_cpregs or negedge reset_n)
  if (~reset_n) begin
    context_id_value_s <= {32{1'b0}};
  end else if (wr_enable_context_id_s) begin
    context_id_value_s <= dcu_cp_reg_data_i[31:0];
  end

  assign read_context_id_value_s = {32'h00000000,
                                    context_id_value_s[31:0]};

  //------------------------------------------------------------------------------
  // Non-secure Context ID register
  //------------------------------------------------------------------------------

  assign wr_enable_context_id_ns = (~dpu_aarch64_at_el_i[3] & wr_enable_ns & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_CTXTID_EL1)) |
                                   (dpu_aarch64_at_el_i[3] & wr_enable_unbanked & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_CTXTID_EL1));

  always @(posedge clk_cpregs or negedge reset_n)
  if (~reset_n) begin
    context_id_value_ns <= {32{1'b0}};
  end else if (wr_enable_context_id_ns) begin
    context_id_value_ns <= dcu_cp_reg_data_i[31:0];
  end

  assign read_context_id_value_ns = {32'h00000000,
                                     context_id_value_ns[31:0]};

  //------------------------------------------------------------------------------
  // TLB DBG RAM Read register 0
  //------------------------------------------------------------------------------

  // For DCU request, all debug registers are enabled at same time, and unused
  // registers are cleared to zero.
  // Same is true IFU request. On ifu_cp_dbg_valid_i request from IFU, all
  // registers are enabled, and unused registers are cleared to zero.
  // TLB RAM writes always uses all four debug registers
  assign wr_enable_dbgdr_reg = wr_enable_unbanked & ((dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_CDBGDR0) |
                                                     (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_CDBGDR1) |
                                                     (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_CDBGDR2) |
                                                     (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_CDBGDR3));

  assign wr_enable_dbgdr = (wr_enable_dbgdr_reg |
                            ifu_cp_dbg_valid_i |
                            mbist_en_i |
                            dbgdr_reg_wr_en_i);

  assign next_dbgdr0_value = (ifu_cp_dbg_valid_i ? ifu_cp_dbg_0_i :
                             (mbist_en_i | dbgdr_reg_wr_en_i) ? dbgdr_reg_wr_data_i[31:0] :
                              dcu_cp_reg_data_i[31:0]);

  always @(posedge clk_cpregs)
  if (wr_enable_dbgdr) begin
    dbgdr0_value <= next_dbgdr0_value;
  end

  assign read_dbgdr0_value = {32'h00000000,
                              dbgdr0_value[31:0]};

  //------------------------------------------------------------------------------
  // TLB DBG RAM Read register 1
  //------------------------------------------------------------------------------

  assign next_dbgdr1_value = (ifu_cp_dbg_valid_i ? ifu_cp_dbg_1_i :
                             (mbist_en_i | dbgdr_reg_wr_en_i) ? dbgdr_reg_wr_data_i[63:32] :
                             dcu_cp_reg_data_i[63:32]);

  always @(posedge clk_cpregs)
  if (wr_enable_dbgdr) begin
    dbgdr1_value <= next_dbgdr1_value;
  end

  assign read_dbgdr1_value = {32'h00000000,
                               dbgdr1_value[31:0]};

  //------------------------------------------------------------------------------
  // TLB DBG RAM Read register 2
  //------------------------------------------------------------------------------

  assign next_dbgdr2_value = {32{mbist_en_i | dbgdr_reg_wr_en_i}} & dbgdr_reg_wr_data_i[95:64];

  always @(posedge clk_cpregs)
  if (wr_enable_dbgdr) begin
    dbgdr2_value <= next_dbgdr2_value;
  end

  assign read_dbgdr2_value = {{32{1'b0}},
                                dbgdr2_value[31:0]};

  //------------------------------------------------------------------------------
  // TLB DBG RAM Read register 3
  //------------------------------------------------------------------------------

  generate if (CPU_CACHE_PROTECTION) begin : g_protection_regs0
    assign next_dbgdr3_value = {21{mbist_en_i | dbgdr_reg_wr_en_i}} & dbgdr_reg_wr_data_i[116:96];
  end else begin : g_protection_stubs_regs0
    assign next_dbgdr3_value = {18{mbist_en_i | dbgdr_reg_wr_en_i}} & dbgdr_reg_wr_data_i[113:96];
  end endgenerate

  always @(posedge clk_cpregs)
  if (wr_enable_dbgdr) begin
    dbgdr3_value <= next_dbgdr3_value;
  end


  assign read_dbgdr3_value = {{32{1'b0}},
                              {(32-(`CA53_TLB_RAM_W-96)){1'b0}},
                              dbgdr3_value[`CA53_TLB_RAM_W-1:96]};

  //------------------------------------------------------------------------------
  // Output signal generation
  //------------------------------------------------------------------------------

  assign rd_el3_a32_curr_ns  = ~dpu_aarch64_at_el_i[3] & dpu_scr_el3_ns_i;
  assign rd_el3_a32_curr_s   = ~dpu_aarch64_at_el_i[3] & ~dpu_scr_el3_ns_i;
  assign rd_el3_a64          = dpu_aarch64_at_el_i[3];
  assign rd_el3_a64_curr_a32 = dpu_aarch64_at_el_i[3] & ~dpu_current_a64_i;

  assign tlb_cp_read_data_dc2_o =
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_TTBR0_EL1) & (rd_el3_a32_curr_s)) }} & 
             read_ttbr0_value_s) | // TTBR0_S
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_TTBR0_EL1) & (rd_el3_a32_curr_ns | rd_el3_a64)) }} & 
             read_ttbr0_value_ns)| // TTBR0_NS/TTBR0_EL1
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_TTBR1_EL1) & (rd_el3_a32_curr_s)) }} & 
             read_ttbr1_value_s) | // TTBR1_S
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_TTBR1_EL1) & (rd_el3_a32_curr_ns | rd_el3_a64)) }} & 
             read_ttbr1_value_ns)| // TTBR1_NS/TTBR1_EL1
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_TTBR0_EL2) & (rd_el3_a32_curr_ns | rd_el3_a64)) }} & 
             read_httbr_value_ns)| // HTTBR_NS/TTBR0_EL2
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_VTTBR_EL2) & (rd_el3_a32_curr_ns | rd_el3_a64)) }} & 
             read_vttbr_value_ns)| // VTTBR_NS/VTTBR_EL2
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_TTBR0_EL3) & (rd_el3_a64)) }} & 
             read_ttbr0_value_s) | // TTBR0_EL3
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_TCR_EL1) & (rd_el3_a32_curr_s)) }} & 
             read_ttbcr_value_s) | // TTBCR_S
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_TCR_EL3) & (rd_el3_a64)) }} & 
             read_ttbcr_value_s) | // TTBR0_EL3
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_TCR_EL1) & (rd_el3_a32_curr_ns | rd_el3_a64)) }} & 
             read_ttbcr_value_ns)| // TTBCR_NS/TCR_EL1
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_TCR_EL2) & (rd_el3_a32_curr_ns | rd_el3_a64)) }} & 
             read_htcr_value_ns) | // HTCR_NS/TCR_EL2
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_VTCR_EL2) & (rd_el3_a32_curr_ns | rd_el3_a64)) }} & 
             read_vtcr_value_ns) | // VTCR_NS/VTCR0_EL2
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_MAIR_EL1) & (rd_el3_a32_curr_s)) }} & 
             read_mair0_value_s) | // MAIR0_S
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_MAIR1) & (rd_el3_a32_curr_s)) }} &
             read_mair1_value_s) | // MAIR1_S
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_MAIR_EL3) & (rd_el3_a64)) }} & 
             {read_mair1_value_s[31:0],read_mair0_value_s[31:0]}) | // MAIR_EL3
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_MAIR_EL1) & (rd_el3_a32_curr_ns | rd_el3_a64_curr_a32)) }} & 
             read_mair0_value_ns) | // MAIR0_NS
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_MAIR1) & (rd_el3_a32_curr_ns | rd_el3_a64_curr_a32)) }} & 
             read_mair1_value_ns) | // MAIR1_NS
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_MAIR_EL1) & (dpu_current_a64_i)) }} &
             {read_mair1_value_ns[31:0],read_mair0_value_ns[31:0]}) | // MAIR_EL1
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_MAIR_EL2) & (rd_el3_a32_curr_ns | rd_el3_a64_curr_a32)) }} & 
             read_hmair0_value_ns) | // HMAIR0_NS
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_HMAIR1) & (rd_el3_a32_curr_ns | rd_el3_a64_curr_a32)) }} & 
             read_hmair1_value_ns) | // HMAIR1_NS
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_MAIR_EL2) & (dpu_current_a64_i)) }} & 
             {read_hmair1_value_ns[31:0],read_hmair0_value_ns[31:0]}) | // HMAIR_EL2
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_PAR_EL1) & (rd_el3_a32_curr_s)) }} & 
             read_par_value_s)  | // PAR_S
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_PAR_EL1) & (rd_el3_a32_curr_ns | rd_el3_a64)) }} & 
             read_par_value_ns) | // PAR_NS/PAR_EL1
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_CTXTID_EL1) & (rd_el3_a32_curr_s)) }} & 
             read_context_id_value_s)  | // CTXID_S
           ({64{ ((dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_CTXTID_EL1) & (rd_el3_a32_curr_ns | rd_el3_a64)) }} & 
             read_context_id_value_ns) | // CTXID_NS/CTXID_EL1
           ({64{ (dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_CDBGDR0)}} & 
             read_dbgdr0_value) |
           ({64{ (dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_CDBGDR1)}} & 
             read_dbgdr1_value) |
           ({64{ (dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_CDBGDR2)}} & 
             read_dbgdr2_value) |
           ({64{ (dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_CDBGDR3)}} & 
             read_dbgdr3_value) |
           (dbg_cp_read_data_dc2_i);

  //----------------------------------------------------------------------------
  // uTLB flush calculation
  //----------------------------------------------------------------------------

  // Whichever security state we are in, a write to any register that may
  // alter the result of a translation must flush the uTLB.
  assign utlb_flush_cp = ((dcu_cp_reg_write_dc3_i &
                           tlb_cp_reg_write_ready_i &
                           ~dcu_cp_reg_en_dc3_i[5] &
                           ~(wr_enable_par_s |
                             wr_enable_par_ns |
                             wr_enable_dbgdr_reg)) |
                          cp_inv_finished_i);

  // The IFU takes a cycle to calculate the hit, and if we flush in that cycle
  // the hit will be suppressed, so we need to delay the flush by a cycle.
  assign next_pagewalk_invalidated_flush = (pagewalk_i_utlb_enable_i &
                                            pagewalk_invalidated_i);

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    pagewalk_invalidated_flush <= 1'b0;
  end else begin
    pagewalk_invalidated_flush <= next_pagewalk_invalidated_flush;
  end

  // Flush the iside uTLB the cycle after a register is written, and two cycles
  // after a pagewalk completes if there was an invalidate during that pagewalk.
  assign next_i_utlb_flush = utlb_flush_cp | pagewalk_invalidated_flush;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    i_utlb_flush <= 1'b0;
  end else begin
    i_utlb_flush <= next_i_utlb_flush;
  end

  assign tlb_i_utlb_flush_o = i_utlb_flush;

  // The dside uTLB must only be flushed when there is not an ongoing burst in
  // progress, to ensure that all of the burst gets the same translation and
  // attributes. Therefore if we want to flush during such a period, we need
  // to delay sending it to the DPU until the burst has finished.
  assign next_d_utlb_flush = (utlb_flush_cp |
                              (d_utlb_flush & dcu_ongoing_burst_dc1_i) |
                              (pagewalk_d_utlb_enable_i & pagewalk_invalidated_i));

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    d_utlb_flush <= 1'b0;
  end else begin
    d_utlb_flush <= next_d_utlb_flush;
  end

  assign tlb_d_utlb_flush_o = d_utlb_flush & ~dcu_ongoing_burst_dc1_i;


  // mair1_value_ns[20:0] for 117-bit RAM
  // mair1_value_ns[17:0] for 114-bit RAM
  assign mbist_in_data_mb4_o  = {mair1_value_ns[`CA53_TLB_RAM_W-97:0],mair1_value_s[31:0],
                                 mair0_value_ns[31:0], mair0_value_s[31:0]};

  assign mbist_read_en_mb4_o  = mair1_value_ns[28:25];
  assign mbist_write_en_mb4_o = mair1_value_ns[24:21];

  //------------------------------------------------------------------------------
  // Output register values to the rest of the TLB
  //------------------------------------------------------------------------------

  // Outputs used by the pagewalk logic.
  // - For EL3 in A32, select the correct secure/nonsecure banked register.
  // - For EL3 in A64, and current pagewalk in A32 (checked in pagewalk block), select A32
  //   format from unbanked register
  assign ttbr0_addr_o = (pagewalk_aarch64_at_el3_i | pagewalk_ns_i) ? read_ttbr0_value_ns[47:4] : read_ttbr0_value_s[47:4];
  assign ttbr1_addr_o = (pagewalk_aarch64_at_el3_i | pagewalk_ns_i) ? read_ttbr1_value_ns[47:4] : read_ttbr1_value_s[47:4];
  assign httbr_addr_o = read_httbr_value_ns[47:4];
  assign vttbr_addr_o = read_vttbr_value_ns[47:4];

  // - For EL3 in A64, and current pagewalk A64 (checked in pagewalk block), select
  //   aarch64 format from unbanked registers.
  assign ttbr0_a64_el1_addr_o = read_ttbr0_value_ns[47:4];
  assign ttbr1_a64_el1_addr_o = read_ttbr1_value_ns[47:4];
  assign ttbr0_a64_el2_addr_o = read_httbr_value_ns[47:4];
  assign ttbr0_a64_el3_addr_o = read_ttbr0_value_s[47:4];

  // - For EL3 in A32, select the correct secure/nonsecure banked register.
  // - For EL3 in A64, and current pagewalk A32, select A32 format from unbanked
  //   register. (Pagewalk arch is not checked here as it get muxed in pagewalk block)
  assign ttbcr_t0sz_o = (pagewalk_aarch64_at_el3_i | pagewalk_ns_i) ? read_ttbcr_value_ns[2:0] : read_ttbcr_value_s[2:0];
  assign ttbcr_t1sz_o = (pagewalk_aarch64_at_el3_i | pagewalk_ns_i) ? (read_ttbcr_value_ns[31] ? read_ttbcr_value_ns[18:16] : 3'b000):
                                                                        (read_ttbcr_value_s[31]  ? read_ttbcr_value_s[18:16]  : 3'b000);
  assign htcr_t0sz_o  = read_htcr_value_ns[2:0];
  assign vtcr_t0sz_o  = read_vtcr_value_ns[5:0];

  // - For EL3 in A64, and current pagewalk A64, select A64 format from unbanked
  //   registers. (Pagewalk aarch is not checked here as it get muxed in pagewalk block)
  assign tcr_a64_el1_t0sz_o = read_ttbcr_value_ns[5:0];
  assign tcr_a64_el1_t1sz_o = read_ttbcr_value_ns[21:16];
  assign tcr_a64_el2_t0sz_o = read_htcr_value_ns[5:0];
  assign tcr_a64_el3_t0sz_o = read_ttbcr_value_s[5:0];

  assign tcr_a64_el1_ips_o = read_ttbcr_value_ns[34:32];
  assign tcr_a64_el2_ps_o  = read_htcr_value_ns[18:16];
  assign tcr_a64_el3_ps_o  = read_ttbcr_value_s[18:16];

  // With EL3 A32, EPD is defined for banked registers
  // With EL3 A64, current exception A32, EPD is defined for unbanked registers
  // With EL3 A64, current exception A64, EPD is defined for unbanked registers
  assign ttbcr_epd_o = (pagewalk_aarch64_at_el3_i | pagewalk_ns_i) ?
                           (read_ttbcr_value_ns[31] ? {read_ttbcr_value_ns[23], read_ttbcr_value_ns[7]}
                                                    : read_ttbcr_value_ns[5:4]) :
                           (read_ttbcr_value_s[31] ? {read_ttbcr_value_s[23], read_ttbcr_value_s[7]}
                                                    :  read_ttbcr_value_s[5:4]);

  assign tcr_a64_el1_epd = {read_ttbcr_value_ns[23], read_ttbcr_value_ns[7]}; // {EPD1,EPD0}
  assign tcr_a64_el1_epd_o = tcr_a64_el1_epd;  

  // Output {S, NOS, RGN, IRGN} as the attributes.
  assign ttbcr_attrs0_o =(pagewalk_aarch64_at_el3_i |  pagewalk_ns_i) ?
                                          (read_ttbcr_value_ns[31] ? read_ttbcr_value_ns[13:8] :
                                           {read_ttbr0_value_ns[1], read_ttbr0_value_ns[5],
                                            read_ttbr0_value_ns[4:3],
                                            read_ttbr0_value_ns[0], read_ttbr0_value_ns[6]}) :
                                          (read_ttbcr_value_s[31] ? read_ttbcr_value_s[13:8] :
                                           {read_ttbr0_value_s[1], read_ttbr0_value_s[5],
                                            read_ttbr0_value_s[4:3],
                                            read_ttbr0_value_s[0], read_ttbr0_value_s[6]});

  assign ttbcr_attrs1_o = (pagewalk_aarch64_at_el3_i | pagewalk_ns_i) ?
                                          (read_ttbcr_value_ns[31] ? read_ttbcr_value_ns[29:24] :
                                           {read_ttbr1_value_ns[1], read_ttbr1_value_ns[5],
                                            read_ttbr1_value_ns[4:3],
                                            read_ttbr1_value_ns[0], read_ttbr1_value_ns[6]}) :
                                          (read_ttbcr_value_s[31] ? read_ttbcr_value_s[29:24] :
                                           {read_ttbr1_value_s[1], read_ttbr1_value_s[5],
                                            read_ttbr1_value_s[4:3],
                                            read_ttbr1_value_s[0], read_ttbr1_value_s[6]});

  assign tcr_a64_el1_attrs0_o = read_ttbcr_value_ns[13:8];  // A64-EL1
  assign tcr_a64_el1_attrs1_o = read_ttbcr_value_ns[29:24]; // A64-EL1
  assign tcr_a64_el3_attrs_o  = read_ttbcr_value_s[13:8];   // A64-EL3

  assign htcr_attrs_o = read_htcr_value_ns[13:8]; // A32-EL2, A64-EL2
  assign vtcr_attrs_o = read_vtcr_value_ns[13:8]; // A32-S2,  A64-S2


  assign ttbcr_eae_s_o  = read_ttbcr_value_s[31];
  assign ttbcr_eae_ns_o = read_ttbcr_value_ns[31];

  assign vtcr_sl0_o = read_vtcr_value_ns[7:6];
  assign vtcr_tg0   = read_vtcr_value_ns[14];
  assign vtcr_tg0_o = vtcr_tg0;
  assign vtcr_ps_o  = read_vtcr_value_ns[18:16];

  assign tcr_a64_el1_tg0 = read_ttbcr_value_ns[14];
  assign tcr_a64_el1_tg1 = read_ttbcr_value_ns[30];
  assign tcr_a64_el2_tg0 = read_htcr_value_ns[14];
  assign tcr_a64_el3_tg0 = read_ttbcr_value_s[14];

  assign tcr_a64_el1_tg0_o = tcr_a64_el1_tg0;
  assign tcr_a64_el1_tg1_o = tcr_a64_el1_tg1;
  assign tcr_a64_el2_tg0_o = tcr_a64_el2_tg0;
  assign tcr_a64_el3_tg0_o = tcr_a64_el3_tg0;

  // Granule information for BIU prefetcher
  // - V2P operations don't start prefetcher and are not related
  // - For EL3-A64, use TCR_EL3 TG0
  // - For EL2-A64, use TCR_EL2 TG0
  // - For EL1/EL0 A64, use 4K granule if either TCR_EL1 TG0 or TG1 is 4K
  //   This is because TTBR0/TTBR1 usage can not be determined until VA is taken into account
  //   Also check that translation is not disabled for TTBR0/TTBR1 using
  //   corresponding EPD bits
  // - For Non-Secure EL1/EL0, if stage2 is enabled include VTCR_TG0 status
  assign el3_with_g64k = (dpu_exception_level_i == 2'b11) & 
                         dpu_aarch64_at_el_i[3] & dpu_mmu_on_el3_i & tcr_a64_el3_tg0 ;

  assign el2_with_g64k = (dpu_exception_level_i == 2'b10) & 
                         dpu_aarch64_at_el_i[2] & dpu_mmu_on_el2_i & tcr_a64_el2_tg0;

  // Support for granule calculation
  assign el1_tg01 = (tcr_a64_el1_tg0 & tcr_a64_el1_tg1); // TTBR0 & TTBR1 both are ON

  assign el01_sec_with_g64k = ~dpu_exception_level_i[1] & dpu_aarch64_at_el_i[1] & ~dpu_ns_state_i & 
                              dpu_mmu_on_el1_i & el1_tg01;

  assign el01_nsec_with_g64k = ~dpu_exception_level_i[1] & dpu_aarch64_at_el_i[1] & dpu_ns_state_i & 
                                // Stage1 ON, Stage2 ON
                               (((dpu_mmu_on_el1_i & ~dpu_default_cacheable_i) & 
                                 (dpu_ipa_to_pa_en_i | dpu_default_cacheable_i)) ? 
                                   (el1_tg01 & vtcr_tg0) :
                                // Stage1 only
                                (dpu_mmu_on_el1_i & ~dpu_default_cacheable_i) ? el1_tg01 :
                                // Stage2 only or none
                                ((dpu_ipa_to_pa_en_i | dpu_default_cacheable_i) & vtcr_tg0));

  assign next_tlb_mem_granule = (el3_with_g64k | el2_with_g64k | 
                                 el01_sec_with_g64k | el01_nsec_with_g64k) ? 2'b11 : 2'b00;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    tlb_mem_granule <= 2'b00;
  end else begin
    tlb_mem_granule <= next_tlb_mem_granule;
  end

  assign tlb_mem_granule_o = tlb_mem_granule;

  // Other misc outputs
  assign mair0_o = pagewalk_hyp_i ? hmair0_value_ns : // A32-EL2, A64-EL2
                   ((pagewalk_aarch64_at_el3_i & (pagewalk_exception_level_i == 2'b00 | pagewalk_exception_level_i == 2'b01)) |
                    (pagewalk_ns_i)) ? mair0_value_ns : // A32-NS-El1, A64-EL1/EL0
                                       mair0_value_s;   // A32-S-EL3, A64-EL3

  assign mair1_o = pagewalk_hyp_i ? hmair1_value_ns :
                   ((pagewalk_aarch64_at_el3_i & (pagewalk_exception_level_i == 2'b00 | pagewalk_exception_level_i == 2'b01)) |
                    (pagewalk_ns_i)) ? mair1_value_ns :
                                       mair1_value_s;

  // If TTBCR.EAE is set then the ASID comes from either TTBR0 or TTBR1
  // depending on TTBCR.A1, otherwise it is taken from the lower bits of
  // the context ID.
  assign asid_ns = read_ttbcr_value_ns[31] ? (read_ttbcr_value_ns[22] ? read_ttbr1_value_ns[55:48] :
                                                                        read_ttbr0_value_ns[55:48]) :
                                             context_id_value_ns[7:0];

  assign asid_s = read_ttbcr_value_s[31] ? (read_ttbcr_value_s[22] ? read_ttbr1_value_s[55:48] :
                                                                     read_ttbr0_value_s[55:48]) :
                                            context_id_value_s[7:0];

  // Outputs used by the pagewalk logic.
  // - For EL3 in A32, select the correct secure/nonsecure banked register.
  // - For EL3 in A64, and current pagewalk in A32 (checked in pagewalk block), select A32
  //   format from unbanked register
  // Indicate a fixed ASID for hyp mode for comparisons in the walk cache match.
  assign asid_a32_pagewalk_o = {8'h00,                    // Extend by 8 bits
                                (pagewalk_hyp_i ? 8'h00 : // Hypervisor doesn't use ASID
                                 (pagewalk_aarch64_at_el3_i | pagewalk_ns_i) ? asid_ns : asid_s)};

  // - For EL3 in A64, and current pagewalk A64 (checked in pagewalk block), select
  //   A64 format from unbanked registers.
  // Indicate a fixed ASID for hyp mode and EL3 for comparisons in the walk cache match.
  assign asid_a64_pagewalk_o = (pagewalk_hyp_i | pagewalk_exception_level_i == 2'b11) ? 16'h0000 :
                               read_ttbcr_value_ns[22] ?  // ASID source TTBR1 or TTBR0
                                 (read_ttbcr_value_ns[36] ? read_ttbr1_value_ns[63:48] : {8'h00,read_ttbr1_value_ns[55:48]}) :
                                 (read_ttbcr_value_ns[36] ? read_ttbr0_value_ns[63:48] : {8'h00,read_ttbr0_value_ns[55:48]});

  // The lookup logic needs the ASID as well, and may be for a different
  // security state to any pagewalk.

  // - For EL3 in A32, select the correct secure/nonsecure banked register.
  // - For EL3 in A64, and current lookup in A32 (checked in lookup block), select A32
  //   format from unbanked register
  // Indicate a fixed ASID for hyp mode for comparisons in the walk cache match.
  assign asid_a32_lookup = {8'h00, (lookup_el2_i ? 8'h00 :
                                    ((dpu_aarch64_at_el_i[3] | lookup_ns_i) ? asid_ns : asid_s))};

  // - For EL3 in A64, and current lookup A64 (checked in lookup block), select
  //   A64 format from unbanked registers.
  // Indicate a fixed ASID for hyp mode and EL3 for comparisons in the walk cache match.
  assign asid_a64_lookup = (lookup_el2_i | (lookup_exception_level_i == 2'b11)) ? 16'h0000 :
                           (read_ttbcr_value_ns[22]) ?  // ASID source TTBR1 or TTBR0
                             (read_ttbcr_value_ns[36] ? read_ttbr1_value_ns[63:48] : {8'h00,read_ttbr1_value_ns[55:48]}) :
                             (read_ttbcr_value_ns[36] ? read_ttbr0_value_ns[63:48] : {8'h00,read_ttbr0_value_ns[55:48]});


  assign asid_lookup_o = lookup_aarch64_i ? asid_a64_lookup : asid_a32_lookup;

  // For A32, indicate the EAE bit for the current state and mode
  // For current exception level A64, always set
  assign tlb_lpae_mode_o = (dpu_current_a64_i) |
                           (dpu_exception_level_i == 2'b10) |
                           ((dpu_ns_state_i | dpu_aarch64_at_el_i[3]) ? read_ttbcr_value_ns[31] : read_ttbcr_value_s[31]);

  // For AArch32, indicate the secure EAE bit.
  // For AArch64, there are no banked registers
  assign tlb_lpae_mode_s_o = ~dpu_aarch64_at_el_i[3] ? read_ttbcr_value_s[31] : 1'b0;


  // Output the context ID for use in the breakpoint/watchpoint matching using dbg_vid_ns signal
  assign context_id_o = (dpu_aarch64_at_el_i[3] | dpu_dbg_vid_ns_i) ?
                         context_id_value_ns : context_id_value_s;

  // Output the context ID for use in the ETM using dpu_ns_state signal
  assign context_id_etm_o = (dpu_aarch64_at_el_i[3] | dpu_ns_state_i) ?
                            context_id_value_ns : context_id_value_s;

  // TBI is only used in A64.
  assign tcr_tbi0_o = (~lookup_exception_level_i[1]) ? read_ttbcr_value_ns[37] :     // TBI0 EL1/EL0
                      (lookup_exception_level_i == 2'b10) ? read_htcr_value_ns[20] : // TBI0 EL2
                                                            read_ttbcr_value_s[20];  // TBI0 EL3

  assign tcr_tbi1_o = read_ttbcr_value_ns[38]; // TBI1 EL1/EL0

  // outputs to DPU
  assign tlb_d_tcr_el1_tbi_o  = read_ttbcr_value_ns[38:37];
  assign tlb_d_tcr_el2_tbi0_o = read_htcr_value_ns[20];
  assign tlb_d_tcr_el3_tbi0_o = read_ttbcr_value_s[20];

  generate if (CPU_CACHE_PROTECTION) begin : CPU_CACHE_PROTECTION_DBGDR3
    assign tlb_mbist_out_data_mb6_o = {dbgdr3_value[`CA53_TLB_RAM_W-1:96], dbgdr2_value[31:0],
                                       dbgdr1_value[31:0],   dbgdr0_value[31:0]};

  end else begin : CPU_CACHE_PROTECTION_DBGDR3_STUBS
    assign tlb_mbist_out_data_mb6_o = {3'b000, dbgdr3_value[`CA53_TLB_RAM_W-1:96], dbgdr2_value[31:0],
                                       dbgdr1_value[31:0],   dbgdr0_value[31:0]};
  end endgenerate

  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON


  assert_implication #(`OVL_FATAL, `OVL_ASSERT,  "A secure register in the TLB can only be accessed in secure state")
  u_ovl_secure_wr_en_set_in_non_secure (.clk       (clk),
                                        .reset_n   (reset_n),
                                        .antecedent_expr (wr_enable_ttbr0_s_only |
                                                          wr_enable_ttbr1_s |
                                                          wr_enable_ttbcr_s_only |
                                                          wr_enable_par_s   |
                                                          wr_enable_mair0_s_only |
                                                          wr_enable_mair1_s_only |
                                                          wr_enable_context_id_s),
                                        .consequent_expr (~dpu_ns_state_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_context_id_ns")
  u_ovl_x_wr_enable_context_id_ns (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (wr_enable_context_id_ns));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_context_id_s")
  u_ovl_x_wr_enable_context_id_s (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (wr_enable_context_id_s));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_dbgdr")
  u_ovl_x_wr_enable_dbgdr   (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (wr_enable_dbgdr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_hmair0_ns")
  u_ovl_x_wr_enable_hmair0_ns (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (wr_enable_hmair0_ns));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_hmair1_ns")
  u_ovl_x_wr_enable_hmair1_ns (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (wr_enable_hmair1_ns));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_htcr_ns")
  u_ovl_x_wr_enable_htcr_ns (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (wr_enable_htcr_ns));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_httbr_ns")
  u_ovl_x_wr_enable_httbr_ns (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (wr_enable_httbr_ns));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_httbr_ns_hi")
  u_ovl_x_wr_enable_httbr_ns_hi (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (wr_enable_httbr_ns_hi));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_mair0_ns")
  u_ovl_x_wr_enable_mair0_ns (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (wr_enable_mair0_ns));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_mair0_s")
  u_ovl_x_wr_enable_mair0_s (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (wr_enable_mair0_s));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_mair1_ns")
  u_ovl_x_wr_enable_mair1_ns (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (wr_enable_mair1_ns));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_mair1_s")
  u_ovl_x_wr_enable_mair1_s (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (wr_enable_mair1_s));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_par_ns")
  u_ovl_x_wr_enable_par_ns (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (wr_enable_par_ns));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_par_ns_hi")
  u_ovl_x_wr_enable_par_ns_hi (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (wr_enable_par_ns_hi));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_par_s")
  u_ovl_x_wr_enable_par_s (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (wr_enable_par_s));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_par_s_hi")
  u_ovl_x_wr_enable_par_s_hi (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (wr_enable_par_s_hi));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_ttbcr_ns")
  u_ovl_x_wr_enable_ttbcr_ns (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (wr_enable_ttbcr_ns));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_ttbcr_ns_hi")
  u_ovl_x_wr_enable_ttbcr_ns_hi (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (wr_enable_ttbcr_ns_hi));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_ttbcr_s")
  u_ovl_x_wr_enable_ttbcr_s (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (wr_enable_ttbcr_s));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_ttbr0_ns")
  u_ovl_x_wr_enable_ttbr0_ns (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (wr_enable_ttbr0_ns));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_ttbr0_ns_hi")
  u_ovl_x_wr_enable_ttbr0_ns_hi (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (wr_enable_ttbr0_ns_hi));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_ttbr0_s")
  u_ovl_x_wr_enable_ttbr0_s (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (wr_enable_ttbr0_s));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_ttbr0_s_hi")
  u_ovl_x_wr_enable_ttbr0_s_hi (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (wr_enable_ttbr0_s_hi));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_ttbr1_ns")
  u_ovl_x_wr_enable_ttbr1_ns (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (wr_enable_ttbr1_ns));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_ttbr1_ns_hi")
  u_ovl_x_wr_enable_ttbr1_ns_hi (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (wr_enable_ttbr1_ns_hi));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_ttbr1_s")
  u_ovl_x_wr_enable_ttbr1_s (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (wr_enable_ttbr1_s));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_ttbr1_s_hi")
  u_ovl_x_wr_enable_ttbr1_s_hi (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (wr_enable_ttbr1_s_hi));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_vtcr_ns")
  u_ovl_x_wr_enable_vtcr_ns (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (wr_enable_vtcr_ns));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_vttbr_ns")
  u_ovl_x_wr_enable_vttbr_ns (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (wr_enable_vttbr_ns));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_enable_vttbr_ns_hi")
  u_ovl_x_wr_enable_vttbr_ns_hi (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (wr_enable_vttbr_ns_hi));


`endif

endmodule

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
