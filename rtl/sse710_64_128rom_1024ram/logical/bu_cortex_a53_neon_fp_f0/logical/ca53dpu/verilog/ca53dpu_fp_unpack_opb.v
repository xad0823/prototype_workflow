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

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_fp_unpack_opb (
  // Inputs
  input  wire              [63:0] fad_b_data_f1_i,
  input  wire              [63:0] fad_c_data_f1_i,
  input  wire [`CA53_FP_OP_W-1:0] fp_op_f1_i,
  input  wire               [1:0] neon_size_sel_f1_i,
  input  wire                     neon_unsigned_op_f1_i,
  input  wire                     fused_mac_f1_i,
  input  wire                     fpscr_ahp_i,
  input  wire                     dual_fp_f1_i,
  input  wire               [6:0] imm_data_f1_i,
  // Outputs
  output wire               [1:0] fp_b_sign_f1_o,
  output wire              [11:0] fp_b_exp0_f1_o,
  output wire              [11:0] fp_b_exp1_f1_o,
  output wire             [107:1] fp_b_frac_f1_o,
  output wire               [1:0] fp_b_exp_max_f1_o,
  output wire               [1:0] fp_b_exp_zero_f1_o,
  output wire                     can_flush_opb_f1_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg           sign0;
  reg           sign1;
  reg    [11:0] exp0;
  reg    [11:0] exp1;
  reg   [107:1] fraction;
  reg           max_exp0;
  reg           max_exp1;
  reg           zero_exp0;
  reg           zero_exp1;
  reg           can_flush;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire   [11:0] fixed_point_exp;
  wire          in_is_integer;
  wire    [1:0] in_size;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  assign fixed_point_exp = {5'b0100_0, imm_data_f1_i[6:0]}; // Create double-precision exponent

  assign in_is_integer = (fp_op_f1_i == `CA53_FP_OP_I2S) |
                         (fp_op_f1_i == `CA53_FP_OP_I2D);

  assign in_size = (fp_op_f1_i == `CA53_FP_OP_H2F_B) ? 2'b01 :
                   (fp_op_f1_i == `CA53_FP_OP_H2F_T) ? 2'b00 :  // Mark top 16-bit as 00 to distinguish from bottom
                   (fp_op_f1_i == `CA53_FP_OP_S2I)   ? 2'b10 :
                   (fp_op_f1_i == `CA53_FP_OP_D2I)   ? 2'b11 :
                   (fp_op_f1_i == `CA53_FP_OP_D2FP)  ? 2'b11 :
                   (fp_op_f1_i == `CA53_FP_OP_D2S)   ? 2'b11 :
                                                       neon_size_sel_f1_i;

  always @*
    case ({in_is_integer, in_size})
      3'b0_10: begin  // Single precision
        sign0             = fad_b_data_f1_i[31];
        zero_exp0         = ({fad_c_data_f1_i[24], fad_b_data_f1_i[30:23]} == 9'h000);
        max_exp0          = (fad_b_data_f1_i[30:23] == 8'hFF) & (~fused_mac_f1_i | fad_c_data_f1_i[24]);
        exp0              = ({3'h0, fad_c_data_f1_i[24], fad_b_data_f1_i[30:23]} + 12'h380) | // Rebias to DP
                            { {11{1'b0}}, ({fad_c_data_f1_i[24], fad_b_data_f1_i[30:23]} == 9'h000)};

        fraction[107:54]  = {1'b0, ({fad_c_data_f1_i[24], fad_b_data_f1_i[30:23]} != 9'h000), fad_b_data_f1_i[22:0], fad_c_data_f1_i[23:0], 5'h00};

        can_flush         = ~fused_mac_f1_i;
      end

      3'b0_11: begin  // Double precision
        sign0             = fad_b_data_f1_i[63];
        zero_exp0         = ({fad_c_data_f1_i[53], fad_b_data_f1_i[62:52]} == 12'h000);
        max_exp0          = (fad_b_data_f1_i[62:52] == 11'h7FF) & (~fused_mac_f1_i | fad_c_data_f1_i[53]);
        exp0              = {fad_c_data_f1_i[53], fad_b_data_f1_i[62:52]} |
                            { {11{1'b0}}, ({fad_c_data_f1_i[53], fad_b_data_f1_i[62:52]} == 12'h000)};

        fraction[107:54]  = {1'b0, (({fad_c_data_f1_i[53], fad_b_data_f1_i[62:52]} != 12'h000)), fad_b_data_f1_i[51:0]};

        can_flush         = ~fused_mac_f1_i;
      end

      3'b0_01: begin  // Half precision, bottom 16 bits
        sign0             = fad_b_data_f1_i[15];
        zero_exp0         =  fad_b_data_f1_i[14:10] == 5'h00;
        max_exp0          = (fad_b_data_f1_i[14:10] == 5'h1F) & ~fpscr_ahp_i;
        exp0              = ({7'h00, fad_b_data_f1_i[14:11], fad_b_data_f1_i[10]} + 12'h3F0) | // Rebias to DP
                            { {11{1'b0}}, (fad_b_data_f1_i[14:10] == 5'h00)};

        fraction[107:54]  = {1'b0, (fad_b_data_f1_i[14:10] != 5'h00), fad_b_data_f1_i[9:0], {42{1'b0}} };

        can_flush = 1'b0;
      end

      3'b0_00: begin  // Half precision, top 16 bits
        sign0             = fad_b_data_f1_i[31];
        zero_exp0         =  fad_b_data_f1_i[30:26] == 5'h00;
        max_exp0          = (fad_b_data_f1_i[30:26] == 5'h1F) & ~fpscr_ahp_i;
        exp0              = ({7'h00, fad_b_data_f1_i[30:27], fad_b_data_f1_i[26]} + 12'h3F0) | // Rebias to DP
                            { {11{1'b0}}, (fad_b_data_f1_i[30:26] == 5'h00)};

        fraction[107:54]  = {1'b0, (fad_b_data_f1_i[30:26] != 5'h00), fad_b_data_f1_i[25:16], {42{1'b0}} };

        can_flush         = 1'b0;
      end

      3'b1_11: begin  // 64-bit integer/fixed-point
        sign0             = ~neon_unsigned_op_f1_i & fad_b_data_f1_i[63];
        zero_exp0         = 1'b0;
        max_exp0          = 1'b0;
        exp0              = fixed_point_exp;

        fraction[107:54]  = { {3{~neon_unsigned_op_f1_i & fad_b_data_f1_i[63]}}, fad_b_data_f1_i[63:13] };

        can_flush         = 1'b0;
      end

      3'b1_10: begin  // 32-bit integer/fixed-point
        sign0             = ~neon_unsigned_op_f1_i & fad_b_data_f1_i[31];
        zero_exp0         = 1'b0;
        max_exp0          = 1'b0;
        exp0              = fixed_point_exp;

        fraction[107:54]  = { {3{~neon_unsigned_op_f1_i & fad_b_data_f1_i[31]}}, fad_b_data_f1_i[31:0], {19{1'b0}} };

        can_flush         = 1'b0;
      end

      3'b1_01: begin  // 16-bit integer/fixed-point
        sign0             = ~neon_unsigned_op_f1_i & fad_b_data_f1_i[15];
        zero_exp0         = 1'b0;
        max_exp0          = 1'b0;
        exp0              = fixed_point_exp;

        fraction[107:54]  = { {19{~neon_unsigned_op_f1_i & fad_b_data_f1_i[15]}}, fad_b_data_f1_i[15:0], {19{1'b0}} };

        can_flush         = 1'b0;
      end

      default: begin
        sign0             = 1'bx;
        zero_exp0         = 1'bx;
        max_exp0          = 1'bx;
        exp0              = {12{1'bx}};
        fraction[107:54]  = {54{1'bx}};
        can_flush         = 1'bx;
      end
    endcase

  always @*
    case ({dual_fp_f1_i, in_is_integer, in_size})
      4'b0_0_11: begin  // Double precision (low bits of scalar operation)
        case (fused_mac_f1_i)
          1'b1: begin
            sign1           = sign0;
            zero_exp1       = zero_exp0;
            max_exp1        = max_exp0;
            exp1            = exp0;

            fraction[53: 1] = fad_c_data_f1_i[52:0];
          end
          1'b0: begin
            sign1           = sign0;
            zero_exp1       = zero_exp0;
            max_exp1        = max_exp0;
            exp1            = exp0;

            fraction[53: 1] = {53{1'b0}};
          end
          default: begin
            sign1           = 1'bx;
            zero_exp1       = 1'bx;
            max_exp1        = 1'bx;
            exp1            = {12{1'bx}};
            fraction[53: 1] = {53{1'bx}};
          end
        endcase
      end

      4'b1_0_10: begin  // Single precision (vector operation, 2nd operand)
        sign1           = fad_b_data_f1_i[63];
        zero_exp1       = ({fad_c_data_f1_i[49], fad_b_data_f1_i[62:55]} == 9'h000);
        max_exp1        = (fad_b_data_f1_i[62:55] == 8'hFF) & (~fused_mac_f1_i |  fad_c_data_f1_i[49]);
        exp1            = ({3'h0, fad_c_data_f1_i[49], fad_b_data_f1_i[62:55]} + 12'h380) | // Rebias to DP
                          { {11{1'b0}}, ({fad_c_data_f1_i[49], fad_b_data_f1_i[62:55]} == 9'h000)};

        fraction[53: 1] = {2'b00, ({fad_c_data_f1_i[49], fad_b_data_f1_i[62:55]} != 9'h000),
                           fad_b_data_f1_i[54:32], fad_c_data_f1_i[48:25], {3{1'b0}} };
      end

      4'b1_0_01: begin  // Half precision (vector operation, 2nd operand)
        sign1             = fad_b_data_f1_i[31];
        zero_exp1         =  fad_b_data_f1_i[30:26] == 5'h00;
        max_exp1          = (fad_b_data_f1_i[30:26] == 5'h1F) & ~fpscr_ahp_i;
        exp1              = ({7'h00, fad_b_data_f1_i[30:26]} + 12'h3F0) | // Rebias to DP
                          { {11{1'b0}}, (fad_b_data_f1_i[30:26] == 5'h00)};

        fraction[53: 1]  = {2'b00, (fad_b_data_f1_i[30:26] != 5'h00), fad_b_data_f1_i[25:16], {40{1'b0}} };
      end

      4'b0_1_11: begin  // 64-bit integer/fixed-point (low bits)
        sign1             = ~neon_unsigned_op_f1_i & fad_b_data_f1_i[63];
        zero_exp1         = 1'b0;
        max_exp1          = 1'b0;
        exp1              = fixed_point_exp;

        fraction[53: 1]  = { fad_b_data_f1_i[12: 0], {40{1'b0}} };
      end

      4'b1_1_10: begin  // 32-bit integer/fixed-point (vector operation, 2nd operand)
        sign1             = ~neon_unsigned_op_f1_i & fad_b_data_f1_i[63];
        zero_exp1         = 1'b0;
        max_exp1          = 1'b0;
        exp1              = fixed_point_exp;

        fraction[53: 1]  = { 1'b0, {3{~neon_unsigned_op_f1_i & fad_b_data_f1_i[63]}}, fad_b_data_f1_i[63:32], {17{1'b0}} };
      end

      4'b0_0_10,        // Single precision (scalar operation, unused bits)
      4'b0_0_01,        // Half precision, bottom 16 bits (scalar operation, unused bits)
      4'b0_0_00,        // Half precision, top 16 bits (scalar operation, unused bits)
      4'b0_1_10,        // 32-bit integer/fixed-point (scalar operation, unused bits)
      4'b0_1_01: begin  // 16-bit integer/fixed-point (scalar operation, unused bits)
        sign1           = sign0;
        zero_exp1       = zero_exp0;
        max_exp1        = max_exp0;
        exp1            = exp0;

        fraction[53: 1] = {53{1'b0}};
      end

      default: begin
        sign1           = 1'bx;
        zero_exp1       = 1'bx;
        max_exp1        = 1'bx;
        exp1            = {12{1'bx}};
        fraction[53: 1] = {53{1'bx}};
      end
    endcase

  assign fp_b_sign_f1_o     = {sign1, sign0};
  assign fp_b_exp0_f1_o     = exp0;
  assign fp_b_exp1_f1_o     = exp1;
  assign fp_b_frac_f1_o     = fraction;
  assign fp_b_exp_max_f1_o  = {max_exp1, max_exp0};
  assign fp_b_exp_zero_f1_o = {zero_exp1, zero_exp0};
  assign can_flush_opb_f1_o = can_flush;

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
