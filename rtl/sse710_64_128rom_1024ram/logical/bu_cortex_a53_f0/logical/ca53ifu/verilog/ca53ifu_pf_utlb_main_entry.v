//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2007-2015 ARM Limited.
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
// Abstract : Main instruction micro TLB entry including hit logic
//-----------------------------------------------------------------------------

`include "ca53ifu_defs.v"
`include "cortexa53params.v"

module ca53ifu_pf_utlb_main_entry (
  // Inputs
  input wire          clk,
  input wire          clk_iutlb,
  input wire          reset_n,
  input wire [19:12]  va_if1_i,
  input wire [47:12]  agu_a_operand_if1_i,
  input wire [47:12]  agu_b_operand_if1_i,
  input wire [48:12]  agu_a_xor_agu_b_i,
  input wire [47:12]  agu_a_and_agu_b_i,
  input wire          carry_out_4k_i,
  input wire          carry_out_1m_i,
  input wire          aarch64_state_i,
  input wire [80:0]   intf_entry_data_i,
  input wire          nxt_utlb_entry_valid_i,
  input wire          utlb_valid_enable_i,
  input wire          utlb_entry_enable_i,
  input wire          tlb_i_utlb_flush_i,
  input wire          dpu_flush_i_utlb_i,
  input wire          exception_level_0_i,
  input wire          exception_level_2_i,
  input wire          exception_level_3_i,
  input wire          pfb_aarch64_at_el3_i,
  // Outputs
  output wire         utlb_entry_valid_o,
  output wire         hit_if1_o,
  output wire         micro_tlb_abort_o,
  output wire [6:0]   abort_type_o,
  output wire         ns_dsc_if1_o,
  output wire [39:12] pa_if1_o,
  output wire [7:0]   attr_if1_o);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg [80:0]     utlb_entry;
  reg            utlb_entry_valid;
  wire           permission_abort;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [48:12]   csa_sum;
  wire [47:12]   csa_carry;
  wire [19:12]   combine_4k;
  wire [48:20]   combine_1m;
  wire           hit_4k;
  wire           hit_1m;
  wire           el_match;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Micro TLB register
  // ------------------------------------------------------

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      utlb_entry_valid <= 1'b0;
    else if (utlb_valid_enable_i)
      utlb_entry_valid <= nxt_utlb_entry_valid_i;

  // Register the micro-TLB data
  // [   80] Size
  // [   79] XS1Nonusr
  // [   78] XS1Usr
  // [77:76] Level, LPAE or VMSA
  // [75:68] MemAttrs
  // [67:66] EL
  // [   65] NS
  // [64:37] PA
  // [36: 0] VA
  always @(posedge clk_iutlb)
    if (utlb_entry_enable_i)
      utlb_entry <= intf_entry_data_i[80:0];

  // ------------------------------------------------------
  // Full adders for a+b=k calculation
  // ------------------------------------------------------

  assign csa_sum[48:12]   = agu_a_xor_agu_b_i[48:12] ^ ~utlb_entry[36:0];
  assign csa_carry[47:12] = ( agu_a_and_agu_b_i[47:12] |
                             (agu_a_operand_if1_i[47:12] & ~utlb_entry[35:0]) |
                             (agu_b_operand_if1_i[47:12] & ~utlb_entry[35:0]));

  // ------------------------------------------------------
  // Hit detection
  // ------------------------------------------------------

  // Compute hit for 1-MByte page sizes
  assign combine_1m[48:20] = csa_sum[48:20] ^ {csa_carry[47:32], csa_carry[31] & aarch64_state_i, csa_carry[30:20], carry_out_1m_i};
  assign hit_1m            = &combine_1m[48:20];

  // Compute hit for 4-KByte page sizes, but do not do the compare on the
  // 1-MByte bits again since this has already been done.
  assign combine_4k[19:12] = csa_sum[19:12] ^ {csa_carry[18:12], carry_out_4k_i};
  assign hit_4k            = &combine_4k[19:12];

  // a uTLB match must look at the Exception level EL as well because in two occasions it will not flush the
  // uTLB on an Exception level change.
  // o if in AARCH64 and in EL3 we could go to secure EL1 without a flush
  // o we could enter or exit hypervisor without a flush
  assign el_match = exception_level_3_i & pfb_aarch64_at_el3_i ? utlb_entry[67:66] == `CA53_EL3 :
                    exception_level_2_i                        ? utlb_entry[67:66] == `CA53_EL2 :
                                                                 utlb_entry[67:66] == `CA53_EL0; // EL1 not used by TLB

  // Mux between page sizes to produce a final hit signal.  The page size is stored in the
  // TLB entry for simplicity.  When a DPU flush is signalled the DACR or LPAE mode can
  // change and when a TLB flush is signalled the LPAE mode can change so we don't
  // want to incorrectly abort (or not abort) on the new value with the old page table.
  assign hit_if1_o = ((utlb_entry_valid & el_match & ~dpu_flush_i_utlb_i & ~tlb_i_utlb_flush_i &  utlb_entry[80] & hit_1m) |
                      (utlb_entry_valid & el_match & ~dpu_flush_i_utlb_i & ~tlb_i_utlb_flush_i & ~utlb_entry[80] & hit_1m & hit_4k));

  // ------------------------------------------------------
  // Abort resolution
  // ------------------------------------------------------

  // This section resolves all micro-TLB related aborts.
  assign permission_abort = exception_level_0_i ? ~utlb_entry[78] : ~utlb_entry[79];

  // ------------------------------------------------------
  // Output generation
  // ------------------------------------------------------

  // Entry valid signal
  assign utlb_entry_valid_o = utlb_entry_valid;

  // Abort indicator
  assign micro_tlb_abort_o = permission_abort;

  // Abort type bus
  assign abort_type_o[6:0] = (permission_abort ? {`CA53_FAULT_LPAE_PERMISSION, utlb_entry[77:76]} :
                              {7{1'b0}});

  // Non-secure bit
  assign ns_dsc_if1_o = utlb_entry[65];

  // Physical address
  assign pa_if1_o[39:12] = {utlb_entry[64:45], (utlb_entry[80] ? va_if1_i[19:12] : utlb_entry[44:37])};

  // Attributes
  assign attr_if1_o[7:0] = utlb_entry[75:68];

  // ------------------------------------------------------
  // OVL
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: utlb_entry_enable_i")
  u_ovl_x_utlb_entry_enable_i (.clk       (clk_iutlb),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (utlb_entry_enable_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: utlb_valid_enable_i")
  u_ovl_x_utlb_valid_enable_i (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (utlb_valid_enable_i));


`endif
endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53ifu_defs.v"
`undef CA53_UNDEFINE
/*END*/
