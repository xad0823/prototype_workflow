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

module ca53dpu_fp_clz64 (
  input  wire  [63:0] clz_input_f3_i,
  input  wire   [1:0] neon_size_sel_f3_i,
  output reg   [63:0] neon_clz_res_f3_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg   [2:0] clz_byte [7:0];

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire  [7:0] check_byte;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Individual byte calculations
  // ------------------------------------------------------

  genvar i;
  generate for (i = 0; i < 8; i = i + 1) begin : g_byte
    assign check_byte[i] = |clz_input_f3_i[i*8+:8];

    always @*
      case (clz_input_f3_i[i*8+:8])
        `ca53dpu_sel_1xxx_xxxx : clz_byte[i] = 3'b000;
        `ca53dpu_sel_01xx_xxxx : clz_byte[i] = 3'b001;
        `ca53dpu_sel_001x_xxxx : clz_byte[i] = 3'b010;
        `ca53dpu_sel_0001_xxxx : clz_byte[i] = 3'b011;
        `ca53dpu_sel_0000_1xxx : clz_byte[i] = 3'b100;
        `ca53dpu_sel_0000_01xx : clz_byte[i] = 3'b101;
        `ca53dpu_sel_0000_001x : clz_byte[i] = 3'b110;
          8'b0000_0001         : clz_byte[i] = 3'b111;
          8'b0000_0000         : clz_byte[i] = 3'b000;
        default                : clz_byte[i] = 3'bxxx;
      endcase
  end endgenerate

  // ------------------------------------------------------
  // Produce the result
  // ------------------------------------------------------

  always @*
    case (neon_size_sel_f3_i)
      2'b10: begin // 32-bits
        case (check_byte[7:4])
          // Most significant '1' is in Byte7
          `ca53dpu_sel_1xxx : neon_clz_res_f3_o[63:32] = {27'h0000000, 2'b00, clz_byte[7]};
          // Most significant '1' is in Byte6
          `ca53dpu_sel_01xx : neon_clz_res_f3_o[63:32] = {27'h0000000, 2'b01, clz_byte[6]};
          // Most significant '1' is in Byte5
          `ca53dpu_sel_001x : neon_clz_res_f3_o[63:32] = {27'h0000000, 2'b10, clz_byte[5]};
          // Most significant '1' is in Byte4
          4'b0001           : neon_clz_res_f3_o[63:32] = {27'h0000000, 2'b11, clz_byte[4]};
          // Operand value is zero
          4'b0000           : neon_clz_res_f3_o[63:32] = {26'h0000000, 6'b100000};
          default           : neon_clz_res_f3_o[63:32] = {32{1'bx}};
        endcase
        case (check_byte[3:0])
          // Most significant '1' is in Byte3
          `ca53dpu_sel_1xxx : neon_clz_res_f3_o[31:0] = {27'h0000000, 2'b00, clz_byte[3]};
          // Most significant '1' is in Byte2
          `ca53dpu_sel_01xx : neon_clz_res_f3_o[31:0] = {27'h0000000, 2'b01, clz_byte[2]};
          // Most significant '1' is in Byte1
          `ca53dpu_sel_001x : neon_clz_res_f3_o[31:0] = {27'h0000000, 2'b10, clz_byte[1]};
          // Most significant '1' is in Byte0
          4'b0001           : neon_clz_res_f3_o[31:0] = {27'h0000000, 2'b11, clz_byte[0]};
          // Operand value is zero
          4'b0000           : neon_clz_res_f3_o[31:0] = {26'h0000000, 6'b100000};
          default           : neon_clz_res_f3_o[31:0] = {32{1'bx}};
        endcase
      end

      2'b01: begin // 16-bits
        case (check_byte[7:6])
          // Most significant '1' is in Byte7
          2'b10,
          2'b11  : neon_clz_res_f3_o[63:48] = {12'h000, 1'b0, clz_byte[7]};
          // Most significant '1' is in Byte6
          2'b01  : neon_clz_res_f3_o[63:48] = {12'h000, 1'b1, clz_byte[6]};
          2'b00  : neon_clz_res_f3_o[63:48] = {11'h000, 5'b10000};
          default: neon_clz_res_f3_o[63:48] = {16{1'bx}};
        endcase
        case (check_byte[5:4])
          // Most significant '1' is in Byte5
          2'b10,
          2'b11  : neon_clz_res_f3_o[47:32] = {12'h000, 1'b0, clz_byte[5]};
          // Most significant '1' is in Byte4
          2'b01  : neon_clz_res_f3_o[47:32] = {12'h000, 1'b1, clz_byte[4]};
          2'b00  : neon_clz_res_f3_o[47:32] = {11'h000, 5'b10000};
          default: neon_clz_res_f3_o[47:32] = {16{1'bx}};
        endcase
        case (check_byte[3:2])
          // Most significant '1' is in Byte3
          2'b10,
          2'b11  : neon_clz_res_f3_o[31:16] = {12'h000, 1'b0, clz_byte[3]};
          // Most significant '1' is in Byte2
          2'b01  : neon_clz_res_f3_o[31:16] = {12'h000, 1'b1, clz_byte[2]};
          2'b00  : neon_clz_res_f3_o[31:16] = {11'h000, 5'b10000};
          default: neon_clz_res_f3_o[31:16] = {16{1'bx}};
        endcase
        case (check_byte[1:0])
          // Most significant '1' is in Byte1
          2'b10,
          2'b11  : neon_clz_res_f3_o[15:0]  = {12'h000, 1'b0, clz_byte[1]};
          // Most significant '1' is in Byte0
          2'b01  : neon_clz_res_f3_o[15:0]  = {12'h000, 1'b1, clz_byte[0]};
          2'b00  : neon_clz_res_f3_o[15:0]  = {11'h000, 5'b10000};
          default: neon_clz_res_f3_o[15:0]  = {16{1'bx}};
        endcase
      end

      2'b00: begin // 8-bits
        neon_clz_res_f3_o[63:56] = {4'b0000, ~check_byte[7], clz_byte[7]};
        neon_clz_res_f3_o[55:48] = {4'b0000, ~check_byte[6], clz_byte[6]};
        neon_clz_res_f3_o[47:40] = {4'b0000, ~check_byte[5], clz_byte[5]};
        neon_clz_res_f3_o[39:32] = {4'b0000, ~check_byte[4], clz_byte[4]};
        neon_clz_res_f3_o[31:24] = {4'b0000, ~check_byte[3], clz_byte[3]};
        neon_clz_res_f3_o[23:16] = {4'b0000, ~check_byte[2], clz_byte[2]};
        neon_clz_res_f3_o[15:8]  = {4'b0000, ~check_byte[1], clz_byte[1]};
        neon_clz_res_f3_o[7:0]   = {4'b0000, ~check_byte[0], clz_byte[0]};
      end

      default: neon_clz_res_f3_o = {64{1'bx}};
    endcase

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
