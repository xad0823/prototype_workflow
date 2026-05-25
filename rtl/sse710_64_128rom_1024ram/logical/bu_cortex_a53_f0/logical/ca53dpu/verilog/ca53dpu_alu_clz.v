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
// Abstract : Count Leading Zeros unit
//-----------------------------------------------------------------------------
//
// Determines the position of the Most Significant '1' in a 32-bit or 64-bit value.
//
// The Zero detection of the input operand is not done within this CLZ module.
// It makes use of the Zero detection unit residing in the Ex2 stage of the ALU
// pipeline.
//
// Partition on a byte boundary and evaluate where the leading '1' is in each
// byte. In parallel determine which byte the leading '1' is in and use this
// result as a mux select for the byte evaluation.
//
// Extended to count leading sign bits when signal sign_count_i set.
//
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_alu_clz(
  // Inputs
  input  wire  [63:0] data_i,
  input  wire         ctl_64bit_op_i,   // select 64 bit operation
  input  wire         sel_sign_count_i, // Select count leading sign bits
  input  wire         sel_zero_count_i, // Select count leading zero bits
  // Outputs
  output wire   [6:0] clz_res_o
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
  reg   [2:0] clz_byte7;
  reg   [6:0] clz_result_64;
  reg   [6:0] clz_result_32;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [63:0] data_i_adj;
  wire  [7:0] check_byte;
  wire        sign_bit;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Adjust input data for count leading sign operation
  // ------------------------------------------------------

  assign sign_bit = ctl_64bit_op_i ? data_i[63] : data_i[31];

  // Input control is one-hot to data gate the inputs to the CLZ logic when it
  // is not being used (to save power)
  assign data_i_adj = ({64{sel_sign_count_i}} & (sign_bit ? {~data_i[62:0], 1'b1}
                                                          : { data_i[62:0], 1'b1})) |
                      ({64{sel_zero_count_i}} & data_i);

  // ------------------------------------------------------
  // Byte evaluation
  // ------------------------------------------------------

  // Evaluate each byte to see if it contains a '1'
  assign check_byte[0] = |(data_i_adj[ 7: 0]); // Check bits [ 7: 0]
  assign check_byte[1] = |(data_i_adj[15: 8]); // Check bits [15: 8]
  assign check_byte[2] = |(data_i_adj[23:16]); // Check bits [23:16]
  assign check_byte[3] = |(data_i_adj[31:24]); // Check bits [31:24]
  assign check_byte[4] = |(data_i_adj[39:32]); // Check bits [39:32]
  assign check_byte[5] = |(data_i_adj[47:40]); // Check bits [47:40]
  assign check_byte[6] = |(data_i_adj[55:48]); // Check bits [55:48]
  assign check_byte[7] = |(data_i_adj[63:56]); // Check bits [63:56]

  // ------------------------------------------------------
  // Byte-0 leading '1' check
  // ------------------------------------------------------

  always @*
    case (data_i_adj[7:0])
      // Most significant '1' in bit 7
      `ca53dpu_sel_1xxx_xxxx : clz_byte0 = 3'b000;
      // Most significant '1' in bit 6
      `ca53dpu_sel_01xx_xxxx : clz_byte0 = 3'b001;
      // Most significant '1' in bit 5
      `ca53dpu_sel_001x_xxxx : clz_byte0 = 3'b010;
      // Most significant '1' in bit 4
      `ca53dpu_sel_0001_xxxx : clz_byte0 = 3'b011;
      // Most significant '1' in bit 3
      `ca53dpu_sel_0000_1xxx : clz_byte0 = 3'b100;
      // Most significant '1' in bit 2
      `ca53dpu_sel_0000_01xx : clz_byte0 = 3'b101;
      // Most significant '1' in bit 1
      8'b0000_0010,
      8'b0000_0011           : clz_byte0 = 3'b110;
      // Most significant '1' in bit 0
      8'b0000_0001           : clz_byte0 = 3'b111;
      8'b0000_0000           : clz_byte0 = 3'b111;
      default                : clz_byte0 = 3'bxxx;
    endcase

  // ------------------------------------------------------
  // Byte-1 leading '1' check
  // ------------------------------------------------------

  always @*
    case (data_i_adj[15:8])
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
    case (data_i_adj[23:16])
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
    case (data_i_adj[31:24])
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
    case (data_i_adj[39:32])
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
    case (data_i_adj[47:40])
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
    case (data_i_adj[55:48])
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
  // Byte-7 leading '1' check
  // ------------------------------------------------------

  always @*
    case (data_i_adj[63:56])
      // Most significant '1' in bit 7
      `ca53dpu_sel_1xxx_xxxx : clz_byte7 = 3'b000;
      // Most significant '1' in bit 6
      `ca53dpu_sel_01xx_xxxx : clz_byte7 = 3'b001;
      // Most significant '1' in bit 5
      `ca53dpu_sel_001x_xxxx : clz_byte7 = 3'b010;
      // Most significant '1' in bit 4
      `ca53dpu_sel_0001_xxxx : clz_byte7 = 3'b011;
      // Most significant '1' in bit 3
      `ca53dpu_sel_0000_1xxx : clz_byte7 = 3'b100;
      // Most significant '1' in bit 2
      `ca53dpu_sel_0000_01xx : clz_byte7 = 3'b101;
      // Most significant '1' in bit 1
      8'b0000_0010,
      8'b0000_0011           : clz_byte7 = 3'b110;
      // Most significant '1' in bit 0
      8'b0000_0001           : clz_byte7 = 3'b111;
      8'b0000_0000           : clz_byte7 = 3'b111;
      default                : clz_byte7 = 3'bxxx;
    endcase

  // ------------------------------------------------------
  // Select between results 32 bits
  // ------------------------------------------------------

  always @*
    case (check_byte[3:0])
      // Most significant '1' is in Byte3
      `ca53dpu_sel_1xxx : clz_result_32[6:0] = {4'b0000, clz_byte3[2:0]};
      // Most significant '1' is in Byte2
      `ca53dpu_sel_01xx : clz_result_32[6:0] = {4'b0001, clz_byte2[2:0]};
      // Most significant '1' is in Byte1
      `ca53dpu_sel_001x : clz_result_32[6:0] = {4'b0010, clz_byte1[2:0]};
      // Most significant '1' is in Byte0
      4'b0001           : clz_result_32[6:0] = {4'b0011, clz_byte0[2:0]};
      // Operand value is zero
      4'b0000           : clz_result_32[6:0] = 7'b0100_000;
      default           : clz_result_32[6:0] = 7'bxxxx_xxx;
    endcase

  // ------------------------------------------------------
  // Select between results 64 bits
  // ------------------------------------------------------

  always @*
    case (check_byte[7:0])
      // Most significant '1' is in Byte7
      `ca53dpu_sel_1xxx_xxxx : clz_result_64[6:0] = {4'b0000, clz_byte7[2:0]};
      // Most significant '1' is in Byte6
      `ca53dpu_sel_01xx_xxxx : clz_result_64[6:0] = {4'b0001, clz_byte6[2:0]};
      // Most significant '1' is in Byte5
      `ca53dpu_sel_001x_xxxx : clz_result_64[6:0] = {4'b0010, clz_byte5[2:0]};
      // Most significant '1' is in Byte4
      `ca53dpu_sel_0001_xxxx : clz_result_64[6:0] = {4'b0011, clz_byte4[2:0]};
      // Most significant '1' is in Byte3
      `ca53dpu_sel_0000_1xxx : clz_result_64[6:0] = {4'b0100, clz_byte3[2:0]};
      // Most significant '1' is in Byte2
      `ca53dpu_sel_0000_01xx : clz_result_64[6:0] = {4'b0101, clz_byte2[2:0]};
      // Most significant '1' is in Byte1
      8'b0000_0010,
      8'b0000_0011           : clz_result_64[6:0] = {4'b0110, clz_byte1[2:0]};
      // Most significant '1' is in Byte0
      8'b0000_0001           : clz_result_64[6:0] = {4'b0111, clz_byte0[2:0]};
      8'b0000_0000           : clz_result_64[6:0] =  7'b1000_000;
      default                : clz_result_64[6:0] =  7'bxxxx_xxx;
    endcase

  assign clz_res_o = ctl_64bit_op_i ? clz_result_64 : clz_result_32;

endmodule // ca53dpu_alu_clz

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
