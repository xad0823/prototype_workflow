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

module ca53dpu_fp_unpack_opa (
  // Inputs
  input  wire               [63:0]  fad_a_data_f1_i,
  input  wire  [`CA53_FP_OP_W-1:0]  fp_op_f1_i,
  input  wire                [1:0]  neon_size_sel_f1_i,
  input  wire                       dual_fp_f1_i,
  input  wire                [6:0]  imm_data_f1_i,
  // Outputs
  output wire                [1:0]  fp_a_sign_f1_o,
  output wire               [10:0]  fp_a_exp0_f1_o,
  output wire               [10:0]  fp_a_exp1_f1_o,
  output wire              [106:22] fp_a_frac_f1_o,
  output wire                [1:0]  fp_a_exp_max_f1_o,
  output wire                [1:0]  fp_a_exp_zero_f1_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg           sign0;
  reg           sign1;
  reg   [10:0]  exp0;
  reg   [10:0]  exp1;
  reg  [106:22] fraction;
  reg           max_exp0;
  reg           max_exp1;
  reg           zero_exp0;
  reg           zero_exp1;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  always @*
    case (fp_op_f1_i)
      `CA53_FP_OP_ADD,
      `CA53_FP_OP_SUB,
      `CA53_FP_OP_RSB,
      `CA53_FP_OP_HADD,
      `CA53_FP_OP_ABD,
      `CA53_FP_OP_CMP,
      `CA53_FP_OP_CMPE,
      `CA53_FP_OP_ACMPE,
      `CA53_FP_OP_MAX,
      `CA53_FP_OP_MAXNM,
      `CA53_FP_OP_MIN,
      `CA53_FP_OP_MINNM: begin
        case (neon_size_sel_f1_i)
          2'b10: begin  // Single precision
            sign0             = fad_a_data_f1_i[31];
            zero_exp0         = fad_a_data_f1_i[30:23] == 8'h00;
            max_exp0          = fad_a_data_f1_i[30:23] == 8'hFF;
            exp0              = {fad_a_data_f1_i[30], {3{~fad_a_data_f1_i[30]}}, fad_a_data_f1_i[29:23]} |
                                { {10{1'b0}}, (fad_a_data_f1_i[30:23] == 8'h00)}; // Rebias to DP

            fraction[106:53]  = {(fad_a_data_f1_i[30:23] != 8'h00), fad_a_data_f1_i[22:0], {30{1'b0}}};
          end

          2'b11: begin  // Double precision
            sign0             = fad_a_data_f1_i[63];
            zero_exp0         = fad_a_data_f1_i[62:52] == 11'h000;
            max_exp0          = fad_a_data_f1_i[62:52] == 11'h7FF;
            exp0              = (fad_a_data_f1_i[62:52] | { {10{1'b0}}, (fad_a_data_f1_i[62:52] == 11'h000)});

            fraction[106:53]  = {(fad_a_data_f1_i[62:52] != 11'h000), fad_a_data_f1_i[51:0], 1'b0};
          end

          default: begin
            sign0             = 1'bx;
            zero_exp0         = 1'bx;
            max_exp0          = 1'bx;
            exp0              = {11{1'bx}};
            fraction[106:53]  = {54{1'bx}};
          end
        endcase
      end

      `CA53_FP_OP_F2H_B: begin
        sign0             = 1'b0;
        zero_exp0         = 1'b0;
        max_exp0          = 1'b0;
        exp0              = 11'h3F1;

        fraction[106:53]  = {54{1'b0}};
      end

      `CA53_FP_OP_F2H_T: begin
        sign0             = 1'b0;
        zero_exp0         = 1'b0;
        max_exp0          = 1'b0;
        exp0              = 11'h3F1;

        fraction[106:53]  = {54{1'b0}};
      end

      `CA53_FP_OP_S2I,
      `CA53_FP_OP_D2I,
      `CA53_FP_OP_D2FP: begin
        sign0           = 1'b0;
        zero_exp0       = 1'b1;
        max_exp0        = 1'b0;
        exp0            = (dual_fp_f1_i                  ? 11'h411 :
                           (neon_size_sel_f1_i == 2'b11) ? 11'h427 :
                                                           11'h447) + imm_data_f1_i[6:0];

        fraction[106:53]  = {54{1'b0}};
      end

      `CA53_FP_OP_D2S: begin
        sign0           = 1'b0;
        zero_exp0       = 1'b1;
        max_exp0        = 1'b0;
        // Insert a fake exponent for DP->SP conversions to get correct shift
        exp0            = 11'h381;

        fraction[106:53]  = {54{1'b0}};
      end

      `CA53_FP_OP_RINT,
      `CA53_FP_OP_RINTX: begin
        sign0           = 1'b0;
        zero_exp0       = 1'b1;
        max_exp0        = 1'b0;
        // Insert a fake exponent for round-to-integral to get correct shift
        exp0            = dual_fp_f1_i ? 11'h431
                                       : 11'h467;

        fraction[106:53]  = {54{1'b0}};
      end

      `CA53_FP_OP_MOV,
      `CA53_FP_OP_ABS,
      `CA53_FP_OP_NEG,
      `CA53_FP_OP_H2F_B,
      `CA53_FP_OP_H2F_T,
      `CA53_FP_OP_I2S,
      `CA53_FP_OP_I2D,
      `CA53_FP_OP_S2D,
      `CA53_FP_OP_RECPX: begin
        sign0           = 1'b0;
        zero_exp0       = 1'b1;
        max_exp0        = 1'b0;
        exp0            = 11'h000;

        fraction[106:53]  = {54{1'b0}};
      end

      default: begin
        sign0             = 1'bx;
        zero_exp0         = 1'bx;
        max_exp0          = 1'bx;
        exp0              = {11{1'bx}};
        fraction[106:53]  = {54{1'bx}};
      end
    endcase

  always @*
    case (fp_op_f1_i)
      `CA53_FP_OP_ADD,
      `CA53_FP_OP_SUB,
      `CA53_FP_OP_RSB,
      `CA53_FP_OP_HADD,
      `CA53_FP_OP_ABD,
      `CA53_FP_OP_CMP,
      `CA53_FP_OP_CMPE,
      `CA53_FP_OP_ACMPE,
      `CA53_FP_OP_MAX,
      `CA53_FP_OP_MAXNM,
      `CA53_FP_OP_MIN,
      `CA53_FP_OP_MINNM: begin
        case ({dual_fp_f1_i, neon_size_sel_f1_i})
          3'b1_10: begin  // Single precision (vector operation, 2nd operand)
            sign1           = fad_a_data_f1_i[63];
            zero_exp1       = fad_a_data_f1_i[62:55] == 8'h00;
            max_exp1        = fad_a_data_f1_i[62:55] == 8'hFF;
            exp1            = {fad_a_data_f1_i[62], {3{~fad_a_data_f1_i[62]}}, fad_a_data_f1_i[61:55]} | // Rebias to DP
                              { {10{1'b0}}, (fad_a_data_f1_i[62:55] == 8'h00)};

            fraction[52:22] = {1'b0, (fad_a_data_f1_i[62:55] != 8'h00), fad_a_data_f1_i[54:32], {6{1'b0}} };
          end

          3'b0_11,        // Double precision (scalar operation, low bits)
          3'b0_10: begin  // Single precision (scalar operation)
            sign1           = sign0;
            zero_exp1       = zero_exp0;
            max_exp1        = max_exp0;
            exp1            = exp0;

            fraction[52:22] = {31{1'b0}};
          end

          default: begin
            sign1           = 1'bx;
            zero_exp1       = 1'bx;
            max_exp1        = 1'bx;
            exp1            = {11{1'bx}};
            fraction[52:22] = {31{1'bx}};
          end
        endcase
      end

      `CA53_FP_OP_F2H_B: begin
        case (dual_fp_f1_i)
          1'b1: begin
            sign1             = 1'b0;
            zero_exp1         = 1'b0;
            max_exp1          = 1'b0;
            exp1              = 11'h3F1;

            fraction[52:22]   = {31{1'b0}};
          end

          1'b0: begin
            sign1           = 1'b0;
            zero_exp1       = 1'b0;
            max_exp1        = 1'b0;
            exp1            = 11'h3F0;

            fraction[52:22] = {2'b01, fad_a_data_f1_i[31:16], {13{1'b0}} };
          end

          default: begin
            sign1           = 1'bx;
            zero_exp1       = 1'bx;
            max_exp1        = 1'bx;
            exp1            = {11{1'bx}};
            fraction[52:22] = {31{1'bx}};
          end
        endcase
      end

      `CA53_FP_OP_F2H_T: begin
        sign1           = 1'b0;
        zero_exp1       = 1'b0;
        max_exp1        = 1'b0;
        exp1            = 11'h3F0;

        fraction[52:22] = {2'b01, fad_a_data_f1_i[15: 0], {13{1'b0}} };
      end

      `CA53_FP_OP_S2I,
      `CA53_FP_OP_D2I,
      `CA53_FP_OP_D2FP: begin
        sign1           = 1'b0;
        zero_exp1       = 1'b1;
        max_exp1        = 1'b0;
        exp1            = (dual_fp_f1_i                  ? 11'h410 :
                           (neon_size_sel_f1_i == 2'b11) ? 11'h427 :
                                                           11'h447) + imm_data_f1_i[6:0];

        fraction[52:22] = {31{1'b0}};
      end

      `CA53_FP_OP_D2S: begin
        sign1           = 1'b0;
        zero_exp1       = 1'b1;
        max_exp1        = 1'b0;
        // Insert a fake exponent for DP->SP conversions to get correct shift
        exp1            = 11'h381;

        fraction[52:22] = {31{1'b0}};
      end

      `CA53_FP_OP_RINT,
      `CA53_FP_OP_RINTX: begin
        sign1           = 1'b0;
        zero_exp1       = 1'b1;
        max_exp1        = 1'b0;
        // Insert a fake exponent for round-to-integral to get correct shift
        exp1            = dual_fp_f1_i ? 11'h430
                                       : 11'h467;

        fraction[52:22] = {31{1'b0}};
      end

      `CA53_FP_OP_MOV,
      `CA53_FP_OP_ABS,
      `CA53_FP_OP_NEG,
      `CA53_FP_OP_H2F_B,
      `CA53_FP_OP_H2F_T,
      `CA53_FP_OP_I2S,
      `CA53_FP_OP_I2D,
      `CA53_FP_OP_S2D,
      `CA53_FP_OP_RECPX: begin
        sign1           = 1'b0;
        zero_exp1       = 1'b1;
        max_exp1        = 1'b0;
        exp1            = 11'h000;

        fraction[52:22] = {31{1'b0}};
      end

      default: begin
        sign1           = 1'bx;
        zero_exp1       = 1'bx;
        max_exp1        = 1'bx;
        exp1            = {11{1'bx}};
        fraction[52:22] = {31{1'bx}};
      end
    endcase

  assign fp_a_sign_f1_o     = {sign1, sign0};
  assign fp_a_exp0_f1_o     = exp0;
  assign fp_a_exp1_f1_o     = exp1;
  assign fp_a_frac_f1_o     = fraction;
  assign fp_a_exp_max_f1_o  = {max_exp1, max_exp0};
  assign fp_a_exp_zero_f1_o = {zero_exp1, zero_exp0};

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
