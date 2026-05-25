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

module ca53dpu_fp_clz54 (
  input  wire  [53:0] opa,
  output wire   [5:0] res
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg   [2:0] clz_byte0;
  reg   [2:0] clz_byte1;
  reg   [2:0] clz_byte2;
  reg   [2:0] clz_byte3;
  reg   [2:0] clz_byte4;
  reg   [2:0] clz_byte5;
  reg   [2:0] clz_byte6;
  reg   [5:0] clz_result;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire  [6:0] check_byte;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Byte evaluation
  // ------------------------------------------------------

  // Evaluate each byte to see if it contains a '1'
  assign check_byte[0] = |(opa[ 5: 0]);
  assign check_byte[1] = |(opa[13: 6]);
  assign check_byte[2] = |(opa[21:14]);
  assign check_byte[3] = |(opa[29:22]);
  assign check_byte[4] = |(opa[37:30]);
  assign check_byte[5] = |(opa[45:38]);
  assign check_byte[6] = |(opa[53:46]);

  // ------------------------------------------------------
  // Byte-0 leading '1' check
  // ------------------------------------------------------

  always @*
    case ({2'b00, opa[5:0]})
      // Most significant '1' in bit 5
      `ca53dpu_sel_001x_xxxx : clz_byte0 = 3'b000;
      // Most significant '1' in bit 4
      `ca53dpu_sel_0001_xxxx : clz_byte0 = 3'b001;
      // Most significant '1' in bit 3
      `ca53dpu_sel_0000_1xxx : clz_byte0 = 3'b010;
      // Most significant '1' in bit 2
      `ca53dpu_sel_0000_01xx : clz_byte0 = 3'b011;
      // Most significant '1' in bit 1
      8'b0000_0010,
      8'b0000_0011           : clz_byte0 = 3'b100;
      // Most significant '1' in bit 0
      8'b0000_0001           : clz_byte0 = 3'b101;
      8'b0000_0000           : clz_byte0 = 3'b110;
      default                : clz_byte0 = 3'bxxx;
    endcase

  // ------------------------------------------------------
  // Byte-1 leading '1' check
  // ------------------------------------------------------

  always @*
    case (opa[13:6])
      // Most significant '1' in bit 7
      `ca53dpu_sel_1xxx_xxxx : clz_byte1 = 3'b000;
      // Most significant '1' in bit 6
      `ca53dpu_sel_01xx_xxxx : clz_byte1 = 3'b001;
      // Most significant '1' in bit 5
      `ca53dpu_sel_001x_xxxx : clz_byte1 = 3'b010;
      // Most significant '1' in bit 4
      `ca53dpu_sel_0001_xxxx : clz_byte1 = 3'b011;
      // Most significant '1' in bit 3
      `ca53dpu_sel_0000_1xxx : clz_byte1 = 3'b100;
      // Most significant '1' in bit 2
      `ca53dpu_sel_0000_01xx : clz_byte1 = 3'b101;
      // Most significant '1' in bit 1
      8'b0000_0010,
      8'b0000_0011           : clz_byte1 = 3'b110;
      // Most significant '1' in bit 0
      8'b0000_0001           : clz_byte1 = 3'b111;
      8'b0000_0000           : clz_byte1 = 3'b111;
      default                : clz_byte1 = 3'bxxx;
    endcase

  // ------------------------------------------------------
  // Byte-2 leading '1' check
  // ------------------------------------------------------

  always @*
    case (opa[21:14])
      // Most significant '1' in bit 7
      `ca53dpu_sel_1xxx_xxxx : clz_byte2 = 3'b000;
      // Most significant '1' in bit 6
      `ca53dpu_sel_01xx_xxxx : clz_byte2 = 3'b001;
      // Most significant '1' in bit 5
      `ca53dpu_sel_001x_xxxx : clz_byte2 = 3'b010;
      // Most significant '1' in bit 4
      `ca53dpu_sel_0001_xxxx : clz_byte2 = 3'b011;
      // Most significant '1' in bit 3
      `ca53dpu_sel_0000_1xxx : clz_byte2 = 3'b100;
      // Most significant '1' in bit 2
      `ca53dpu_sel_0000_01xx : clz_byte2 = 3'b101;
      // Most significant '1' in bit 1
      8'b0000_0010,
      8'b0000_0011           : clz_byte2 = 3'b110;
      // Most significant '1' in bit 0
      8'b0000_0001           : clz_byte2 = 3'b111;
      8'b0000_0000           : clz_byte2 = 3'b111;
      default                : clz_byte2 = 3'bxxx;
    endcase

  // ------------------------------------------------------
  // Byte-3 leading '1' check
  // ------------------------------------------------------

  always @*
    case (opa[29:22])
      // Most significant '1' in bit 7
      `ca53dpu_sel_1xxx_xxxx : clz_byte3 = 3'b000;
      // Most significant '1' in bit 6
      `ca53dpu_sel_01xx_xxxx : clz_byte3 = 3'b001;
      // Most significant '1' in bit 5
      `ca53dpu_sel_001x_xxxx : clz_byte3 = 3'b010;
      // Most significant '1' in bit 4
      `ca53dpu_sel_0001_xxxx : clz_byte3 = 3'b011;
      // Most significant '1' in bit 3
      `ca53dpu_sel_0000_1xxx : clz_byte3 = 3'b100;
      // Most significant '1' in bit 2
      `ca53dpu_sel_0000_01xx : clz_byte3 = 3'b101;
      // Most significant '1' in bit 1
      8'b0000_0010,
      8'b0000_0011           : clz_byte3 = 3'b110;
      // Most significant '1' in bit 0
      8'b0000_0001           : clz_byte3 = 3'b111;
      8'b0000_0000           : clz_byte3 = 3'b111;
      default                : clz_byte3 = 3'bxxx;
    endcase

  // ------------------------------------------------------
  // Byte-4 leading '1' check
  // ------------------------------------------------------

  always @*
    case (opa[37:30])
      // Most significant '1' in bit 7
      `ca53dpu_sel_1xxx_xxxx : clz_byte4 = 3'b000;
      // Most significant '1' in bit 6
      `ca53dpu_sel_01xx_xxxx : clz_byte4 = 3'b001;
      // Most significant '1' in bit 5
      `ca53dpu_sel_001x_xxxx : clz_byte4 = 3'b010;
      // Most significant '1' in bit 4
      `ca53dpu_sel_0001_xxxx : clz_byte4 = 3'b011;
      // Most significant '1' in bit 3
      `ca53dpu_sel_0000_1xxx : clz_byte4 = 3'b100;
      // Most significant '1' in bit 2
      `ca53dpu_sel_0000_01xx : clz_byte4 = 3'b101;
      // Most significant '1' in bit 1
      8'b0000_0010,
      8'b0000_0011           : clz_byte4 = 3'b110;
      // Most significant '1' in bit 0
      8'b0000_0001           : clz_byte4 = 3'b111;
      8'b0000_0000           : clz_byte4 = 3'b111;
      default                : clz_byte4 = 3'bxxx;
    endcase

  // ------------------------------------------------------
  // Byte-5 leading '1' check
  // ------------------------------------------------------

  always @*
    case (opa[45:38])
      // Most significant '1' in bit 7
      `ca53dpu_sel_1xxx_xxxx : clz_byte5 = 3'b000;
      // Most significant '1' in bit 6
      `ca53dpu_sel_01xx_xxxx : clz_byte5 = 3'b001;
      // Most significant '1' in bit 5
      `ca53dpu_sel_001x_xxxx : clz_byte5 = 3'b010;
      // Most significant '1' in bit 4
      `ca53dpu_sel_0001_xxxx : clz_byte5 = 3'b011;
      // Most significant '1' in bit 3
      `ca53dpu_sel_0000_1xxx : clz_byte5 = 3'b100;
      // Most significant '1' in bit 2
      `ca53dpu_sel_0000_01xx : clz_byte5 = 3'b101;
      // Most significant '1' in bit 1
      8'b0000_0010,
      8'b0000_0011           : clz_byte5 = 3'b110;
      // Most significant '1' in bit 0
      8'b0000_0001           : clz_byte5 = 3'b111;
      8'b0000_0000           : clz_byte5 = 3'b111;
      default                : clz_byte5 = 3'bxxx;
    endcase

  // ------------------------------------------------------
  // Byte-6 leading '1' check
  // ------------------------------------------------------

  always @*
    case (opa[53:46])
      // Most significant '1' in bit 7
      `ca53dpu_sel_1xxx_xxxx : clz_byte6 = 3'b000;
      // Most significant '1' in bit 6
      `ca53dpu_sel_01xx_xxxx : clz_byte6 = 3'b001;
      // Most significant '1' in bit 5
      `ca53dpu_sel_001x_xxxx : clz_byte6 = 3'b010;
      // Most significant '1' in bit 4
      `ca53dpu_sel_0001_xxxx : clz_byte6 = 3'b011;
      // Most significant '1' in bit 3
      `ca53dpu_sel_0000_1xxx : clz_byte6 = 3'b100;
      // Most significant '1' in bit 2
      `ca53dpu_sel_0000_01xx : clz_byte6 = 3'b101;
      // Most significant '1' in bit 1
      8'b0000_0010,
      8'b0000_0011           : clz_byte6 = 3'b110;
      // Most significant '1' in bit 0
      8'b0000_0001           : clz_byte6 = 3'b111;
      8'b0000_0000           : clz_byte6 = 3'b111;
      default                : clz_byte6 = 3'bxxx;
    endcase

  // ------------------------------------------------------
  // Select between results
  // ------------------------------------------------------

  always @*
    case (check_byte[6:0])
      // Most significant '1' is in Byte6
      `ca53dpu_sel_1xx_xxxx : clz_result[5:0] = {3'b000, clz_byte6[2:0]};
      // Most significant '1' is in Byte5
      `ca53dpu_sel_01x_xxxx : clz_result[5:0] = {3'b001, clz_byte5[2:0]};
      // Most significant '1' is in Byte4
      `ca53dpu_sel_001_xxxx : clz_result[5:0] = {3'b010, clz_byte4[2:0]};
      // Most significant '1' is in Byte3
      `ca53dpu_sel_000_1xxx : clz_result[5:0] = {3'b011, clz_byte3[2:0]};
      // Most significant '1' is in Byte2
      `ca53dpu_sel_000_01xx : clz_result[5:0] = {3'b100, clz_byte2[2:0]};
      // Most significant '1' is in Byte1
      `ca53dpu_sel_000_001x : clz_result[5:0] = {3'b101, clz_byte1[2:0]};
      // Most significant '1' is in Byte0
      7'b000_0001           : clz_result[5:0] = {3'b110, clz_byte0[2:0]};
      // Operand value is zero
      7'b000_0000           : clz_result[5:0] = 6'b110_110;
      default               : clz_result[5:0] = 6'bxxx_xxx;
    endcase

  assign res = clz_result;

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
