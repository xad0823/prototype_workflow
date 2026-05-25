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
// Abstract: Generates the output for General Purpose saturate
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// This block is responsible for generating the final result for the general
// purpose saturate instructions. Only used for AArch32 instructions.
//
//----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_alu_gen_sat (
  // Inputs
  input  wire         alu_ex2_simd_sign_arth_i, // Signed vs unsigned sat
  input  wire         alu_ex2_no_valid_simd_i,  // 2x16 SIMD vs 1x32 no-SIMD
  input  wire  [31:0] alu_data_b_ex2_i,         // Data to be saturated
  input  wire  [31:0] alu_mask_data_ex2_i,      // Mask data from maskgen in Ex1
  // Outputs
  output wire  [31:0] gen_sat_out_ex2_o,
  output wire         gen_sat_overflow_out_ex2_o
  );

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire        operand_sign_hi;
  wire        operand_sign_lo;
  wire        masked_bits_hi;
  wire        masked_bits_lo;
  wire        overflow_hi;
  wire        overflow_lo;
  wire [31:0] mask;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // Mask we want is actually the generated mask shifted right by one
  assign mask = alu_ex2_no_valid_simd_i ? {1'b0, alu_mask_data_ex2_i[31:1]} :
                                          {1'b0, alu_mask_data_ex2_i[15:1],  1'b0, alu_mask_data_ex2_i[15:1]};

  // Extract the signs for each half word. For a 32-bit operand, the lower half
  // uses the sign of the whole word
  assign operand_sign_hi = alu_data_b_ex2_i[31];
  assign operand_sign_lo = alu_ex2_no_valid_simd_i ? operand_sign_hi : alu_data_b_ex2_i[15];

  // Calculate if each half word overflows.
  // For positive numbers, alu_mask_data_ex2_i will represent the maximum
  // output value (in the form 000...111) - so any value that has bits set
  // above those in the mask is too large.
  // For signed negative numbers, alu_mask_data_ex2_i holds the minimum
  // (most negative) output value (in the form 111...000) - so any value which
  // has clear bits in the upper part is too small
  // Negative numbers always overflow for unsigned output (handled later)
  assign masked_bits_hi = |(operand_sign_hi ? ~(alu_data_b_ex2_i[31:16] |  mask[31:16])
                                            :  (alu_data_b_ex2_i[31:16] & ~mask[31:16]));
  assign masked_bits_lo = |(operand_sign_lo ? ~(alu_data_b_ex2_i[15:0]  |  mask[15:0] )
                                            :  (alu_data_b_ex2_i[15:0]  & ~mask[15:0] ));

  // Calculate the relevant overflows depending whether this is a 16- or 32-bit operation
  assign overflow_hi = masked_bits_hi | (alu_ex2_no_valid_simd_i & masked_bits_lo) | (~alu_ex2_simd_sign_arth_i & operand_sign_hi);
  assign overflow_lo = masked_bits_lo | (alu_ex2_no_valid_simd_i & masked_bits_hi) | (~alu_ex2_simd_sign_arth_i & operand_sign_lo);

  // Handle the negative unsigned case, and select whether to return the mask
  // (the saturated value) or the original data
  assign gen_sat_out_ex2_o[31:16] = (operand_sign_hi & ~alu_ex2_simd_sign_arth_i) ? 16'h0000
                                  : overflow_hi ? operand_sign_hi ? ~mask[31:16]
                                                                  :  mask[31:16]
                                                : alu_data_b_ex2_i[31:16];
  assign gen_sat_out_ex2_o[15:0]  = (operand_sign_lo & ~alu_ex2_simd_sign_arth_i) ? 16'h0000
                                  : overflow_lo ? operand_sign_lo ? ~mask[15:0]
                                                                  :  mask[15:0]
                                                : alu_data_b_ex2_i[15:0];

  // Indicate whether overflow occurred
  assign gen_sat_overflow_out_ex2_o = overflow_hi | overflow_lo;

endmodule // ca53dpu_alu_gen_sat

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
