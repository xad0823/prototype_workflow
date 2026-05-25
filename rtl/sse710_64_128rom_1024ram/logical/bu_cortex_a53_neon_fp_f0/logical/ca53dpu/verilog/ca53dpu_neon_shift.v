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
// Abstract : Neon shifter module
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Takes as input two 64-bit vectors of rotated bytes. Each pair of bytes
// is interpreted as a 16-bit input value and then shifted left by the low order
// three bits of the corresponding byte in the operand B input vector


`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_neon_shift (
  // Inputs
  input  wire   [1:0] neon_size_f2_i,           // Element size for shift
  input  wire         neon_unsigned_f2_i,       // Unsigned/signed elements
  input  wire         neon_narrowing_op_f2_i,   // Indicates if a V[Q][R]SHR[U]N or V[Q]MOV[U]N is taking place
  input  wire         neon_mask_sel_f2_i,
  input  wire         neon_shift_reg_f2_i,
  input  wire   [7:0] imm_data_f2_i,            // Immediate data
  input  wire  [63:0] frc_opa_f2_i,             // The source operand to be shifted, used to get signs
  input  wire  [63:0] frc_opb_f2_i,             // The shift amounts, always signed bytes
  input  wire  [63:0] neon_perm_opa_f2_i,       // Rotated data from
  input  wire  [63:0] neon_perm_opb_f2_i,       // the permute block
  // Outputs
  output wire  [63:0] neon_shift_res_f2_o,      // Shifted data output
  output reg   [63:0] neon_shift_round_f2_o,    // Rounding vector to be added to opa
  output wire  [63:0] neon_shift_mask_f2_o,     // Mask for shift and insert
  output wire  [63:0] neon_sat_res_f2_o         // Saturation control vector
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg   [7:0] shift_right;
  reg  [23:0] shift_amt;
  reg  [15:0] byte_mask;
  reg   [7:0] sign_bits;
  reg  [15:0] narrow_sat_res;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [63:0] sh_amount_f2;
  wire  [7:0] sat_bytes;
  wire  [7:0] round_bits;
  wire  [7:1] nrw_satbyte_a;
  wire  [7:1] nrw_satbyte_b;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // Normally, the operand indicating the shift amount(s) is in the F2 OpB register.
  // If a narrowing shift is taking place, this register is used for source data, but
  // thankfully all narrowing shifts use an immediate and not a register shift amount,
  // so the shift amount can be regenerated from the immediate data pipe
  // Shift and accumulate and shift and insert also use OpB for data

  assign sh_amount_f2 = neon_shift_reg_f2_i ? frc_opb_f2_i[63:0]
                                            : {8{imm_data_f2_i[7:0]}};

  // Generate a set of byte masks to indicate which bytes from the rotated
  // input data are valid
  // For values that are being shifted to the right and sign-extended with 1's,
  // set the appropriate bit in sign_bits

  always @*
    case (neon_size_f2_i)
      2'b00: begin // 8-bit
        shift_right[0] = sh_amount_f2[ 7];
        shift_right[1] = sh_amount_f2[15];
        shift_right[2] = sh_amount_f2[23];
        shift_right[3] = sh_amount_f2[31];
        shift_right[4] = sh_amount_f2[39];
        shift_right[5] = sh_amount_f2[47];
        shift_right[6] = sh_amount_f2[55];
        shift_right[7] = sh_amount_f2[63];

        shift_amt[ 2: 0] = sh_amount_f2[ 2: 0];
        shift_amt[ 5: 3] = sh_amount_f2[10: 8];
        shift_amt[ 8: 6] = sh_amount_f2[18:16];
        shift_amt[11: 9] = sh_amount_f2[26:24];
        shift_amt[14:12] = sh_amount_f2[34:32];
        shift_amt[17:15] = sh_amount_f2[42:40];
        shift_amt[20:18] = sh_amount_f2[50:48];
        shift_amt[23:21] = sh_amount_f2[58:56];

        case (neon_narrowing_op_f2_i)
          1'b1: byte_mask[15: 0] = 16'b10_10_10_10_10_10_10_10;
          1'b0: begin
            byte_mask[ 1: 0] = (2'b10 << {(sh_amount_f2[ 6: 3] ^ (sh_amount_f2[ 7] ? 4'b1111 : 4'b0000)), 1'b0})
                                ^ {2{&sh_amount_f2[ 7: 3]}};
            byte_mask[ 3: 2] = (2'b10 << {(sh_amount_f2[14:11] ^ (sh_amount_f2[15] ? 4'b1111 : 4'b0000)), 1'b0})
                                ^ {2{&sh_amount_f2[15:11]}};
            byte_mask[ 5: 4] = (2'b10 << {(sh_amount_f2[22:19] ^ (sh_amount_f2[23] ? 4'b1111 : 4'b0000)), 1'b0})
                                ^ {2{&sh_amount_f2[23:19]}};
            byte_mask[ 7: 6] = (2'b10 << {(sh_amount_f2[30:27] ^ (sh_amount_f2[31] ? 4'b1111 : 4'b0000)), 1'b0})
                                ^ {2{&sh_amount_f2[31:27]}};
            byte_mask[ 9: 8] = (2'b10 << {(sh_amount_f2[38:35] ^ (sh_amount_f2[39] ? 4'b1111 : 4'b0000)), 1'b0})
                                ^ {2{&sh_amount_f2[39:35]}};
            byte_mask[11:10] = (2'b10 << {(sh_amount_f2[46:43] ^ (sh_amount_f2[47] ? 4'b1111 : 4'b0000)), 1'b0})
                                ^ {2{&sh_amount_f2[47:43]}};
            byte_mask[13:12] = (2'b10 << {(sh_amount_f2[54:51] ^ (sh_amount_f2[55] ? 4'b1111 : 4'b0000)), 1'b0})
                                ^ {2{&sh_amount_f2[55:51]}};
            byte_mask[15:14] = (2'b10 << {(sh_amount_f2[62:59] ^ (sh_amount_f2[63] ? 4'b1111 : 4'b0000)), 1'b0})
                                ^ {2{&sh_amount_f2[63:59]}};
          end
          default: byte_mask[15:0] = {16{1'bx}};
        endcase

        sign_bits = {8{~neon_unsigned_f2_i}} & (neon_narrowing_op_f2_i ? {frc_opb_f2_i[63],
                                                                          frc_opb_f2_i[47],
                                                                          frc_opb_f2_i[31],
                                                                          frc_opb_f2_i[15],
                                                                          frc_opa_f2_i[63],
                                                                          frc_opa_f2_i[47],
                                                                          frc_opa_f2_i[31],
                                                                          frc_opa_f2_i[15]}
                                                                       : {frc_opa_f2_i[63],
                                                                          frc_opa_f2_i[55],
                                                                          frc_opa_f2_i[47],
                                                                          frc_opa_f2_i[39],
                                                                          frc_opa_f2_i[31],
                                                                          frc_opa_f2_i[23],
                                                                          frc_opa_f2_i[15],
                                                                          frc_opa_f2_i[ 7]});
      end
      2'b01: begin // 16-bit
        shift_right[1:0] = {2{sh_amount_f2[ 7]}};
        shift_right[3:2] = {2{sh_amount_f2[23]}};
        shift_right[5:4] = {2{sh_amount_f2[39]}};
        shift_right[7:6] = {2{sh_amount_f2[55]}};

        shift_amt[ 5: 0] = {2{sh_amount_f2[ 2: 0]}};
        shift_amt[11: 6] = {2{sh_amount_f2[18:16]}};
        shift_amt[17:12] = {2{sh_amount_f2[34:32]}};
        shift_amt[23:18] = {2{sh_amount_f2[50:48]}};

        case (neon_narrowing_op_f2_i)
          1'b1: byte_mask[15: 0] = 16'b1011_1011_1011_1011;
          1'b0: begin
            byte_mask[ 3: 0] = (4'b1110 << {(sh_amount_f2[ 6: 3] ^ (sh_amount_f2[ 7] ? 4'b1110 : 4'b0000)), 1'b0})
                                ^ {4{&sh_amount_f2[ 7: 4]}};
            byte_mask[ 7: 4] = (4'b1110 << {(sh_amount_f2[22:19] ^ (sh_amount_f2[23] ? 4'b1110 : 4'b0000)), 1'b0})
                                ^ {4{&sh_amount_f2[23:20]}};
            byte_mask[11: 8] = (4'b1110 << {(sh_amount_f2[38:35] ^ (sh_amount_f2[39] ? 4'b1110 : 4'b0000)), 1'b0})
                                ^ {4{&sh_amount_f2[39:36]}};
            byte_mask[15:12] = (4'b1110 << {(sh_amount_f2[54:51] ^ (sh_amount_f2[55] ? 4'b1110 : 4'b0000)), 1'b0})
                                ^ {4{&sh_amount_f2[55:52]}};
          end
          default: byte_mask[15:0] = {16{1'bx}};
        endcase

        sign_bits = {8{~neon_unsigned_f2_i}} & (neon_narrowing_op_f2_i ? { {2{frc_opb_f2_i[63]}},
                                                                           {2{frc_opb_f2_i[31]}},
                                                                           {2{frc_opa_f2_i[63]}},
                                                                           {2{frc_opa_f2_i[31]}} }
                                                                       : { {2{frc_opa_f2_i[63]}},
                                                                           {2{frc_opa_f2_i[47]}},
                                                                           {2{frc_opa_f2_i[31]}},
                                                                           {2{frc_opa_f2_i[15]}} });
      end
      2'b10: begin // 32-bit
        shift_right[3:0] = {4{sh_amount_f2[ 7]}};
        shift_right[7:4] = {4{sh_amount_f2[39]}};

        shift_amt[11: 0] = {4{sh_amount_f2[ 2: 0]}};
        shift_amt[23:12] = {4{sh_amount_f2[34:32]}};

        case (neon_narrowing_op_f2_i)
          1'b1: byte_mask[15: 0] = 16'b10111111_10111111;
          1'b0: begin
            byte_mask[ 7: 0] = (8'b1111_1110 << {(sh_amount_f2[ 6: 3] ^ (sh_amount_f2[ 7] ? 4'b1100 : 4'b0000)), 1'b0})
                                ^ {8{&sh_amount_f2[ 7: 5]}};
            byte_mask[15: 8] = (8'b1111_1110 << {(sh_amount_f2[38:35] ^ (sh_amount_f2[39] ? 4'b1100 : 4'b0000)), 1'b0})
                                ^ {8{&sh_amount_f2[39:37]}};
          end
          default: byte_mask[15:0] = {16{1'bx}};
        endcase

        sign_bits = {8{~neon_unsigned_f2_i}} & (neon_narrowing_op_f2_i ? { {4{frc_opb_f2_i[63]}},
                                                                           {4{frc_opa_f2_i[63]}} }
                                                                       : { {4{frc_opa_f2_i[63]}},
                                                                           {4{frc_opa_f2_i[31]}} });
      end
      2'b11: begin // 64-bit
        shift_right[7:0] = {8{sh_amount_f2[ 7]}};

        shift_amt[23: 0] = {8{sh_amount_f2[ 2: 0]}};

        byte_mask[15: 0] = (16'b1111_1111_1111_1110 << {(sh_amount_f2[6:3] ^ (sh_amount_f2[7] ? 4'b1000 : 4'b0000)), 1'b0})
                            ^ {16{&sh_amount_f2[7:6]}};

        sign_bits = {8{~neon_unsigned_f2_i}} & {8{frc_opa_f2_i[63]}};
      end
      default: begin
        shift_right[7:0] = {8{1'bx}};
        shift_amt[23: 0] = {24{1'bx}};
        byte_mask[15: 0] = {16{1'bx}};
        sign_bits[ 7: 0] = {8{1'bx}};
      end
    endcase

  // Perform eight shifts

  ca53dpu_neon_shift8 u_shift8[7:0] (
    .neon_perm_opa_f2_i     (neon_perm_opa_f2_i),
    .neon_perm_opb_f2_i     (neon_perm_opb_f2_i),
    .shift_right_i          (shift_right),
    .shift_amt_i            (shift_amt),
    .neon_narrowing_op_f2_i (neon_narrowing_op_f2_i),
    .byte_mask_i            (byte_mask),
    .sign_bit_i             (sign_bits),
    .neon_mask_sel_f2_i     (neon_mask_sel_f2_i),

    .neon_shift_res_f2_o    (neon_shift_res_f2_o),
    .round_bit_o            (round_bits),
    .sat_res_o              (sat_bytes),
    .neon_shift_mask_f2_o   (neon_shift_mask_f2_o)
  );


  // Calculate saturation control

  assign nrw_satbyte_b[7] = |(frc_opb_f2_i[63:56] ^ {8{sign_bits[7]}});
  assign nrw_satbyte_b[6] = |(frc_opb_f2_i[55:48] ^ {8{sign_bits[7]}});
  assign nrw_satbyte_b[5] = |(frc_opb_f2_i[47:40] ^ {8{sign_bits[6]}});
  assign nrw_satbyte_b[4] = |(frc_opb_f2_i[39:32] ^ {8{sign_bits[6]}});
  assign nrw_satbyte_b[3] = |(frc_opb_f2_i[31:24] ^ {8{sign_bits[5]}});
  assign nrw_satbyte_b[2] = |(frc_opb_f2_i[23:16] ^ {8{sign_bits[5]}});
  assign nrw_satbyte_b[1] = |(frc_opb_f2_i[15: 8] ^ {8{sign_bits[4]}});
  assign nrw_satbyte_a[7] = |(frc_opa_f2_i[63:56] ^ {8{sign_bits[3]}});
  assign nrw_satbyte_a[6] = |(frc_opa_f2_i[55:48] ^ {8{sign_bits[3]}});
  assign nrw_satbyte_a[5] = |(frc_opa_f2_i[47:40] ^ {8{sign_bits[2]}});
  assign nrw_satbyte_a[4] = |(frc_opa_f2_i[39:32] ^ {8{sign_bits[2]}});
  assign nrw_satbyte_a[3] = |(frc_opa_f2_i[31:24] ^ {8{sign_bits[1]}});
  assign nrw_satbyte_a[2] = |(frc_opa_f2_i[23:16] ^ {8{sign_bits[1]}});
  assign nrw_satbyte_a[1] = |(frc_opa_f2_i[15: 8] ^ {8{sign_bits[0]}});

  always @*
    case (neon_size_f2_i)
      2'b00: begin // 16 -> 8-bit
        case (shift_right[0])
          1'b0:     narrow_sat_res = {1'b0, nrw_satbyte_b[7],
                                      1'b0, nrw_satbyte_b[5],
                                      1'b0, nrw_satbyte_b[3],
                                      1'b0, nrw_satbyte_b[1],
                                      1'b0, nrw_satbyte_a[7],
                                      1'b0, nrw_satbyte_a[5],
                                      1'b0, nrw_satbyte_a[3],
                                      1'b0, nrw_satbyte_a[1]};
          1'b1:     narrow_sat_res = {16{1'b0}};
          default:  narrow_sat_res = {16{1'bx}};
        endcase
      end

      2'b01: begin // 32 -> 16-bit
        narrow_sat_res[15: 8] = {8{1'b0}};

        case ({shift_right[0], sh_amount_f2[3]})
          `ca53dpu_sel_0x: narrow_sat_res[ 7: 0] = {1'b0, nrw_satbyte_b[7] | nrw_satbyte_b[6],
                                                    1'b0, nrw_satbyte_b[3] | nrw_satbyte_b[2],
                                                    1'b0, nrw_satbyte_a[7] | nrw_satbyte_a[6],
                                                    1'b0, nrw_satbyte_a[3] | nrw_satbyte_a[2]};
          2'b11          : narrow_sat_res[ 7: 0] = {1'b0, nrw_satbyte_b[7],
                                                    1'b0, nrw_satbyte_b[3],
                                                    1'b0, nrw_satbyte_a[7],
                                                    1'b0, nrw_satbyte_a[3]};
          2'b10          : narrow_sat_res[ 7: 0] = {8{1'b0}};
          default        : narrow_sat_res[ 7: 0] = {8{1'bx}};
        endcase
      end

      2'b10: begin // 64 -> 32-bit
        narrow_sat_res[15: 4] = {12{1'b0}};

        case ({shift_right[0], sh_amount_f2[4:3]})
          `ca53dpu_sel_0xx: narrow_sat_res[ 3: 0] = {1'b0, nrw_satbyte_b[7] | nrw_satbyte_b[6] | nrw_satbyte_b[5] | nrw_satbyte_b[4],
                                                     1'b0, nrw_satbyte_a[7] | nrw_satbyte_a[6] | nrw_satbyte_a[5] | nrw_satbyte_a[4]};
          3'b111          : narrow_sat_res[ 3: 0] = {1'b0, nrw_satbyte_b[7] | nrw_satbyte_b[6] | nrw_satbyte_b[5],
                                                     1'b0, nrw_satbyte_a[7] | nrw_satbyte_a[6] | nrw_satbyte_a[5]};
          3'b110          : narrow_sat_res[ 3: 0] = {1'b0, nrw_satbyte_b[7] | nrw_satbyte_b[6],
                                                     1'b0, nrw_satbyte_a[7] | nrw_satbyte_a[6]};
          3'b101          : narrow_sat_res[ 3: 0] = {1'b0, nrw_satbyte_b[7],
                                                     1'b0, nrw_satbyte_a[7]};
          3'b100          : narrow_sat_res[ 3: 0] = {4{1'b0}};
          default         : narrow_sat_res[ 3: 0] = {4{1'bx}};
        endcase
      end

      2'b11:    narrow_sat_res = {16{1'b0}};

      default:  narrow_sat_res = {16{1'bx}};
    endcase

  assign neon_sat_res_f2_o = { {24{1'b0}}, narrow_sat_res, shift_right, sign_bits, sat_bytes};

  // Calculate rounding vector
  always @*
    case (neon_size_f2_i)
      2'b00: begin // 8-bit
        neon_shift_round_f2_o = { { 7{1'b0}}, round_bits[7],
                                  { 7{1'b0}}, round_bits[6],
                                  { 7{1'b0}}, round_bits[5],
                                  { 7{1'b0}}, round_bits[4],
                                  { 7{1'b0}}, round_bits[3],
                                  { 7{1'b0}}, round_bits[2],
                                  { 7{1'b0}}, round_bits[1],
                                  { 7{1'b0}}, round_bits[0] };
      end
      2'b01: begin // 16-bit
        neon_shift_round_f2_o = { {15{1'b0}}, round_bits[6],
                                  {15{1'b0}}, round_bits[4],
                                  {15{1'b0}}, round_bits[2],
                                  {15{1'b0}}, round_bits[0] };
      end
      2'b10: begin // 32-bit
        neon_shift_round_f2_o = { {31{1'b0}}, round_bits[4],
                                  {31{1'b0}}, round_bits[0] };
      end
      2'b11: begin // 64-bit
        neon_shift_round_f2_o = { {63{1'b0}}, round_bits[0] };
      end
      default: begin
        neon_shift_round_f2_o = {64{1'bx}};
      end
    endcase

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/

