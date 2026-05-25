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
// Abstract : Logic which doubles, and if required, saturates the input
// operand
//-----------------------------------------------------------------------------
//
// Overview
// --------
// This module takes a 32-bit or 64bit signed operand and if required
//     a) doubles its value
//     b) if the doubled value overflows, then the result is saturated.

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_alu_sat_dbl (
  // Inputs
  input  wire  [63:0] alu_data_a_ex1_i,
  input  wire         ctl_64bit_op_ex1_i,
  // Outputs
  output wire  [63:0] alu_data_a_dbl_sat_ex1_o,
  output wire         alu_sat_dbl_set_qbit_ex1_o
  );

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire        sign_a_operand_original;
  wire        sign_a_operand_dbl_value;
  wire [63:0] dbl_value_a_operand;
  wire [63:0] sat_pos_operand;
  wire [63:0] sat_neg_operand;
  wire        overflow_pos_dir;
  wire        overflow_neg_dir;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // Extract the sign bit of the original and the doubled value.
  assign sign_a_operand_original  = ctl_64bit_op_ex1_i ? alu_data_a_ex1_i[63]    : alu_data_a_ex1_i[31];
  assign sign_a_operand_dbl_value = ctl_64bit_op_ex1_i ? dbl_value_a_operand[63] : dbl_value_a_operand[31];

  // Overflow in the positive direction if the original operand is positve
  // and the doubling value gives a negative result.
  assign overflow_pos_dir = ~sign_a_operand_original & sign_a_operand_dbl_value;

  // Overflow in the negative direction if the original operand is negative
  // and the doubling value gives a positive result.
  assign overflow_neg_dir = sign_a_operand_original & ~sign_a_operand_dbl_value;

  // The doubling of the a_operand is achieved by shifting to the left by one
  // bit, padding the lsbit with zero.
  assign dbl_value_a_operand = {alu_data_a_ex1_i[62:0], 1'b0};

  // Select 32 or 64bit saturation value
  assign sat_pos_operand = ctl_64bit_op_ex1_i ? `CA53_SAT_POS_64_VALUE : `CA53_SAT_POS_32_VALUE;
  assign sat_neg_operand = ctl_64bit_op_ex1_i ? `CA53_SAT_NEG_64_VALUE : `CA53_SAT_NEG_32_VALUE;

  // Check if the doubling of the a_operand has resulted in an overflow.
  assign alu_data_a_dbl_sat_ex1_o = (overflow_pos_dir ? sat_pos_operand : // Overflow positive direction: Saturate to positive value
                                     overflow_neg_dir ? sat_neg_operand : // Overflow negative direction: Saturate to negative value
                                     dbl_value_a_operand);                // No overflow: Return the doubled value

  // If doubling of the operand requested and the doubling resulted in an
  // overflow, then indicate to CPSR to set Q-flag.
  assign alu_sat_dbl_set_qbit_ex1_o = (overflow_pos_dir | overflow_neg_dir);

endmodule //ca53dpu_alu_sat_dbl

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
