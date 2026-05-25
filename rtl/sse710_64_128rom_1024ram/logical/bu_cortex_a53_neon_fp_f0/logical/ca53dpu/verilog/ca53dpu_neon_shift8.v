//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2014 ARM Limited.
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
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Neon byte shifter module
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Takes as input a pair of bytes to be shifted by up to seven places left
// Each byte is masked before shift

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_neon_shift8 (
  // Inputs
  input  wire [7:0] neon_perm_opa_f2_i,     // High input data to this shifter
  input  wire [7:0] neon_perm_opb_f2_i,     // Low input data to this shifter
  input  wire       shift_right_i,          // Shift direction - 1 for right
  input  wire [2:0] shift_amt_i,            // Amount to shift left by
  input  wire       neon_narrowing_op_f2_i, // Narrowing shift?
  input  wire [1:0] byte_mask_i,            // Mask to apply to input data
  input  wire       sign_bit_i,             // Bit to fill in place of masked data
  input  wire       neon_mask_sel_f2_i,     // Selects shift operand for the mask production
  // Outputs
  output wire [7:0] neon_shift_res_f2_o,    // Shifted data out
  output wire       round_bit_o,            // Rounding bit (discarded MSB)
  output wire       sat_res_o,              // Some non-sign bits were discarded
  output wire [7:0] neon_shift_mask_f2_o    // Produced mask out
);

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [15:0] shift_operand;
  wire [15:0] sat_dtct_operand;
  wire [15:0] mask_operand;
  wire [15:0] sat_operand;
  wire [15:0] shift_tmp;
  wire [15:0] sat_tmp;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // Mask rotated data to turn rotate operation into shift
  assign shift_operand[15: 8] = (byte_mask_i[1] | neon_narrowing_op_f2_i) ? neon_perm_opa_f2_i
                                                                          : {8{sign_bit_i & shift_right_i}};
  assign shift_operand[ 7: 0] = (byte_mask_i[0] | neon_narrowing_op_f2_i) ? neon_perm_opb_f2_i
                                                                          : {8{sign_bit_i & shift_right_i}};

  // Perform data shift
  assign shift_tmp = shift_operand << shift_amt_i[2:0];

  assign neon_shift_res_f2_o = shift_tmp[15:8];

  // Round bit is most significant discarded bit
  assign round_bit_o = shift_tmp[7] & shift_right_i;

  // Perform opposite masking to calculate if any non-sign bits
  // have been shifted away
  assign sat_dtct_operand[15: 8] = (neon_narrowing_op_f2_i |
                                    byte_mask_i[1])        ? {8{sign_bit_i}}    :
                                                             neon_perm_opa_f2_i;
  assign sat_dtct_operand[ 7: 0] =  byte_mask_i[0]         ? {8{sign_bit_i}}    :
                                    neon_narrowing_op_f2_i ? neon_perm_opa_f2_i :
                                                             neon_perm_opb_f2_i;

  // Produce mask for VSRI/VSLI instructions
  assign mask_operand[15: 8] = {8{byte_mask_i[1]}};
  assign mask_operand[ 7: 0] = {8{byte_mask_i[0]}};

  // MUX to select the operand to be shifted for saturation detect or mask production
  assign sat_operand =  neon_mask_sel_f2_i ? mask_operand : sat_dtct_operand;

  // Perform saturation shift
  assign sat_tmp = sat_operand << shift_amt_i[2:0];

  // Calculate if any discarded bits should cause saturation
  // Qualified by shift direction in parent module
  assign sat_res_o = |(sat_tmp[15:8] ^ {8{sign_bit_i}});

  // Mask result for VSRI/VSLI instructions
  assign neon_shift_mask_f2_o = sat_tmp[15:8];

endmodule // ca53dpu_neon_shift8

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
