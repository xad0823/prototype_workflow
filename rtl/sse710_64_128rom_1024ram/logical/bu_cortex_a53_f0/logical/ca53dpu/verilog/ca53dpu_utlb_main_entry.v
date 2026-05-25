//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2015 ARM Limited.
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
// Abstract : Micro TLB Entry
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_utlb_main_entry (
  // Inputs
  input  wire         clk,
  input  wire         clk_dutlb,
  input  wire         reset_n,
  input  wire         aarch64_state_iss_i,
  input  wire [47:12] agu_a_operand_i,
  input  wire [47:12] agu_b_operand_i,
  input  wire [48:12] agu_a_xor_agu_b_i,
  input  wire [47:12] agu_a_and_agu_b_i,
  input  wire         nxt_utlb_entry_valid_i,
  input  wire         utlb_valid_enable_i,
  input  wire         utlb_entry_enable_i,
  input  wire [82:0]  utlb_data_i,
  input  wire         carry_out_4k_i,
  input  wire  [1:0]  dpu_exception_level_i,
  // Outputs
  output wire         utlb_entry_valid_o,
  output wire         hit_iss_o,
  output wire [39:12] pa_dc1_o,
  output wire [12:0]  attr_dc1_o,
  output wire         ns_dsc_dc1_o,
  output wire  [3:0]  level_dc1_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg   [82:0]  utlb_entry;
  reg           utlb_entry_valid;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire  [48:12] csa_sum;
  wire  [47:12] csa_carry;
  wire  [48:12] combine_4k;
  wire          hit_4k;
  wire          excp_level_match;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Micro TLB register
  // ------------------------------------------------------

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      utlb_entry_valid <= 1'b0;
    else if (utlb_valid_enable_i)
      utlb_entry_valid <= nxt_utlb_entry_valid_i;

  // Register the micro-TLB data
  always @(posedge clk_dutlb)
    if (utlb_entry_enable_i)
      utlb_entry <= utlb_data_i[82:0];

  // ------------------------------------------------------
  // Full adder for a+b=k calculation
  // ------------------------------------------------------

  assign csa_sum[48:12]   = agu_a_xor_agu_b_i[48:12] ^ ~utlb_entry[36:0];
  assign csa_carry[47:12] = agu_a_and_agu_b_i[47:12]                      |
                            (agu_a_operand_i[47:12] & ~utlb_entry[35:0])  |
                            (agu_b_operand_i[47:12] & ~utlb_entry[35:0]);

  // ------------------------------------------------------
  // Hit (final part of a+b=k calculation)
  // ------------------------------------------------------

  // Compute hit for 4-KByte page sizes
  // Carry calculation for bit 31 is special, as in AArch32 the address
  // addition should not cause a carry out of bit 31
  assign combine_4k[48:12] = csa_sum[48:12] ^ {csa_carry[47:32], csa_carry[31] & aarch64_state_iss_i, csa_carry[30:12], carry_out_4k_i};
  assign hit_4k            = &combine_4k;

  // EL2 and AArch64 EL3 use separate page tables
  assign excp_level_match  = ((dpu_exception_level_i == `CA53_EL3) & aarch64_state_iss_i) ? (utlb_entry[69:66] == 4'b1_100) :
                              (dpu_exception_level_i == `CA53_EL2)                        ? (utlb_entry[69:66] == 4'b0_100) :
                                                                                            (utlb_entry[68:66] !=   3'b100);

  // ------------------------------------------------------
  // Output generation
  // ------------------------------------------------------

  assign utlb_entry_valid_o = utlb_entry_valid;

  // Qualify the raw address match to form the final hit signal
  assign hit_iss_o = utlb_entry_valid & excp_level_match & hit_4k;

  // Signal physical address
  assign pa_dc1_o[39:12]  = utlb_entry[64:37];

  // Attributes
  assign attr_dc1_o[12:0] = utlb_entry[78:66];

  // Non-secure bit
  assign ns_dsc_dc1_o     = utlb_entry[65];

  // Level
  assign level_dc1_o      = utlb_entry[82:79];

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: utlb_entry_enable_i")
  u_ovl_x_utlb_entry_enable_i (.clk       (clk_dutlb),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (utlb_entry_enable_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: utlb_valid_enable_i")
  u_ovl_x_utlb_valid_enable_i (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (utlb_valid_enable_i));
  // OVL_ASSERT_END

`endif

endmodule // ca53dpu_utlb_main_entry

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
