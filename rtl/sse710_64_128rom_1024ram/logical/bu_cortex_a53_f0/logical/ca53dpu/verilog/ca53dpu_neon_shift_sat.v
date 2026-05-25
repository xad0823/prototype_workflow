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
// Abstract : Neon shift saturation module
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Takes partially calculated saturation control from the F2 shifter, and
// calculates the full saturation control vector (in F3)


`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_neon_shift_sat (
  // Inputs
  input  wire   [1:0] neon_size_sel_f3_i,       // Element size for shift
  input  wire   [2:0] neon_width_op_sel_f3_i,   // Indicates if a V[Q][R]SHR[U]N or V[Q]MOV[U]N is taking place
  input  wire   [2:0] neon_sat_op_sel_f3_i,     // The type of saturation taking place
  input  wire  [63:0] frc_opa_f3_i,             // Shifted data value
  input  wire  [63:0] neon_frc_opc_f3_i,        // The encoded saturation control
  input  wire  [63:0] frc_res_f3_i,             // Shifted and rounded data value
  // Outputs
  output wire  [15:0] neon_shift_sat_f3_o       // Saturation control vector
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg  [15:0] shift_sat_res;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire        narrowing;
  wire        sat_unsigned;
  wire  [7:0] sat_bytes;
  wire  [7:0] shift_right;
  wire  [7:0] sign_bits;
  wire [15:0] narrow_sat_res;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  assign narrowing = neon_width_op_sel_f3_i == 3'b001;

  assign sat_bytes      = neon_frc_opc_f3_i[ 7: 0];
  assign sign_bits      = neon_frc_opc_f3_i[15: 8];
  assign shift_right    = neon_frc_opc_f3_i[23:16];
  assign narrow_sat_res = neon_frc_opc_f3_i[39:24];

  // Calculate saturation control

  assign sat_unsigned = neon_sat_op_sel_f3_i == `CA53_NEON_SAT_SHF_UNSIGNED;

  always @*
    case (neon_size_sel_f3_i)
      2'b00: begin // 8-bit
        shift_sat_res[15:14] = {sign_bits[7], ( sat_bytes[7]   | (sat_unsigned ? (sign_bits[7] ^ (frc_opa_f3_i[63] & ~frc_res_f3_i[63]))
                                                                               : (sign_bits[7] ^ (frc_opa_f3_i[63] |  frc_res_f3_i[63]))))
                                                                 & (~shift_right[7] | narrowing)};
        shift_sat_res[13:12] = {sign_bits[6], ( sat_bytes[6]   | (sat_unsigned ? (sign_bits[6] ^ (frc_opa_f3_i[55] & ~frc_res_f3_i[55]))
                                                                               : (sign_bits[6] ^ (frc_opa_f3_i[55] |  frc_res_f3_i[55]))))
                                                                 & (~shift_right[6] | narrowing)};
        shift_sat_res[11:10] = {sign_bits[5], ( sat_bytes[5]   | (sat_unsigned ? (sign_bits[5] ^ (frc_opa_f3_i[47] & ~frc_res_f3_i[47]))
                                                                               : (sign_bits[5] ^ (frc_opa_f3_i[47] |  frc_res_f3_i[47]))))
                                                                 & (~shift_right[5] | narrowing)};
        shift_sat_res[ 9: 8] = {sign_bits[4], ( sat_bytes[4]   | (sat_unsigned ? (sign_bits[4] ^ (frc_opa_f3_i[39] & ~frc_res_f3_i[39]))
                                                                               : (sign_bits[4] ^ (frc_opa_f3_i[39] |  frc_res_f3_i[39]))))
                                                                 & (~shift_right[4] | narrowing)};
        shift_sat_res[ 7: 6] = {sign_bits[3], ( sat_bytes[3]   | (sat_unsigned ? (sign_bits[3] ^ (frc_opa_f3_i[31] & ~frc_res_f3_i[31]))
                                                                               : (sign_bits[3] ^ (frc_opa_f3_i[31] |  frc_res_f3_i[31]))))
                                                                 & (~shift_right[3] | narrowing)};
        shift_sat_res[ 5: 4] = {sign_bits[2], ( sat_bytes[2]   | (sat_unsigned ? (sign_bits[2] ^ (frc_opa_f3_i[23] & ~frc_res_f3_i[23]))
                                                                               : (sign_bits[2] ^ (frc_opa_f3_i[23] |  frc_res_f3_i[23]))))
                                                                 & (~shift_right[2] | narrowing)};
        shift_sat_res[ 3: 2] = {sign_bits[1], ( sat_bytes[1]   | (sat_unsigned ? (sign_bits[1] ^ (frc_opa_f3_i[15] & ~frc_res_f3_i[15]))
                                                                               : (sign_bits[1] ^ (frc_opa_f3_i[15] |  frc_res_f3_i[15]))))
                                                                 & (~shift_right[1] | narrowing)};
        shift_sat_res[ 1: 0] = {sign_bits[0], ( sat_bytes[0]   | (sat_unsigned ? (sign_bits[0] ^ (frc_opa_f3_i[ 7] & ~frc_res_f3_i[ 7]))
                                                                               : (sign_bits[0] ^ (frc_opa_f3_i[ 7] |  frc_res_f3_i[ 7]))))
                                                                 & (~shift_right[0] | narrowing)};
      end
      2'b01: begin // 16-bit
        shift_sat_res[15: 8] = {8{1'b0}};
        shift_sat_res[ 7: 6] = {sign_bits[7], (|sat_bytes[7:6] | (sat_unsigned ? (sign_bits[7] ^ (frc_opa_f3_i[63] & ~frc_res_f3_i[63]))
                                                                               : (sign_bits[7] ^ (frc_opa_f3_i[63] |  frc_res_f3_i[63]))))
                                                                 & (~shift_right[6] | narrowing)};
        shift_sat_res[ 5: 4] = {sign_bits[5], (|sat_bytes[5:4] | (sat_unsigned ? (sign_bits[5] ^ (frc_opa_f3_i[47] & ~frc_res_f3_i[47]))
                                                                               : (sign_bits[5] ^ (frc_opa_f3_i[47] |  frc_res_f3_i[47]))))
                                                                 & (~shift_right[4] | narrowing)};
        shift_sat_res[ 3: 2] = {sign_bits[3], (|sat_bytes[3:2] | (sat_unsigned ? (sign_bits[3] ^ (frc_opa_f3_i[31] & ~frc_res_f3_i[31]))
                                                                               : (sign_bits[3] ^ (frc_opa_f3_i[31] |  frc_res_f3_i[31]))))
                                                                 & (~shift_right[2] | narrowing)};
        shift_sat_res[ 1: 0] = {sign_bits[1], (|sat_bytes[1:0] | (sat_unsigned ? (sign_bits[1] ^ (frc_opa_f3_i[15] & ~frc_res_f3_i[15]))
                                                                               : (sign_bits[1] ^ (frc_opa_f3_i[15] |  frc_res_f3_i[15]))))
                                                                 & (~shift_right[0] | narrowing)};
      end
      2'b10: begin // 32-bit
        shift_sat_res[15: 4] = {12{1'b0}};
        shift_sat_res[ 3: 2] = {sign_bits[7], (|sat_bytes[7:4] | (sat_unsigned ? (sign_bits[7] ^ (frc_opa_f3_i[63] & ~frc_res_f3_i[63]))
                                                                               : (sign_bits[7] ^ (frc_opa_f3_i[63] |  frc_res_f3_i[63]))))
                                                                 & (~shift_right[4] | narrowing)};
        shift_sat_res[ 1: 0] = {sign_bits[3], (|sat_bytes[3:0] | (sat_unsigned ? (sign_bits[3] ^ (frc_opa_f3_i[31] & ~frc_res_f3_i[31]))
                                                                               : (sign_bits[3] ^ (frc_opa_f3_i[31] |  frc_res_f3_i[31]))))
                                                                 & (~shift_right[0] | narrowing)};
      end
      2'b11: begin // 64-bit
        shift_sat_res[15: 2] = {14{1'b0}};
        shift_sat_res[ 1: 0] = {sign_bits[7], (|sat_bytes[7:0] | (sat_unsigned ? (sign_bits[7] ^ (frc_opa_f3_i[63] & ~frc_res_f3_i[63]))
                                                                               : (sign_bits[7] ^ (frc_opa_f3_i[63] |  frc_res_f3_i[63]))))
                                                                 & (~shift_right[0] | narrowing)};
      end
      default: begin
        shift_sat_res[15: 0] = {16{1'bx}};
      end
    endcase


  assign neon_shift_sat_f3_o = shift_sat_res | ({16{narrowing}} & narrow_sat_res);

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/

