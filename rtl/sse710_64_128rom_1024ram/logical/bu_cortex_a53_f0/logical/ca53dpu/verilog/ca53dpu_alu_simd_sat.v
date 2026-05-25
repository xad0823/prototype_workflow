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
// Abstract : Logic which provides the SIMD Saturation.
//-----------------------------------------------------------------------------
//
// Overview
// --------
// This module takes the 32-bit result from the ALU and if required provides
// SIMD saturation

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_alu_simd_sat (
  input  wire         alu_wr_sat_valid_i,        // Indicate if saturation is required.
  input  wire         alu_wr_valid_simd_i,       // Indicates a SIMD operation
  input  wire         alu_wr_simd_size_i,        // Set for a 16-bit SIMD operation, clear for 8-bit.
  input  wire         alu_wr_simd_sign_arth_i,   // Indicates if signed saturation is required.
  input  wire  [31:0] raw_alu_data_wr_i,         // The alu operand to be operated on.
  input  wire   [3:0] simd_sat_overflow_wr_i,    // Saturation indicators for each byte
  input  wire   [3:0] simd_sat_direction_wr_i,   // Saturation sign for each byte (1 = negative)

  output reg   [31:0] alu_data_simd_sat_wr_o,    // The new saturated output for the RF.
  output wire         simd_sat_qbit_wr_o         // V5E Saturation has occured, so set Q-bit.
);

  //-----------------------------------------------------------------------
  // Local Parameters
  //-----------------------------------------------------------------------

  localparam [31:0] SAT_POS_VAL_SIGN_32   = 32'h7fff_ffff;
  localparam [31:0] SAT_NEG_VAL_SIGN_32   = 32'h8000_0000;

  localparam [15:0] SAT_POS_VAL_SIGN_16   = 16'h7fff;
  localparam [15:0] SAT_NEG_VAL_SIGN_16   = 16'h8000;
  localparam [15:0] SAT_POS_VAL_UNSIGN_16 = 16'hffff;
  localparam [15:0] SAT_NEG_VAL_UNSIGN_16 = 16'h0000;

  localparam [ 7:0] SAT_POS_VAL_SIGN_8    = 8'h7f;
  localparam [ 7:0] SAT_NEG_VAL_SIGN_8    = 8'h80;
  localparam [ 7:0] SAT_POS_VAL_UNSIGN_8  = 8'hff;
  localparam [ 7:0] SAT_NEG_VAL_UNSIGN_8  = 8'h00;

  //-----------------------------------------------------------------------
  // Reg declarations.
  //-----------------------------------------------------------------------

  reg  [31:0] simd_sat_value_8;
  reg  [31:0] simd_sat_value_16;
  reg  [31:0] simd_sat_value_32;

  //==================================
  // 8-bit Saturation
  //=================================
  // Byte 0
  always @*
    case ({simd_sat_overflow_wr_i[0], alu_wr_simd_sign_arth_i, simd_sat_direction_wr_i[0]})
      `ca53dpu_sel_0xx: simd_sat_value_8[ 7: 0] = raw_alu_data_wr_i[ 7: 0];
        3'b100        : simd_sat_value_8[ 7: 0] = SAT_POS_VAL_UNSIGN_8;
        3'b101        : simd_sat_value_8[ 7: 0] = SAT_NEG_VAL_UNSIGN_8;
        3'b110        : simd_sat_value_8[ 7: 0] = SAT_POS_VAL_SIGN_8;
        3'b111        : simd_sat_value_8[ 7: 0] = SAT_NEG_VAL_SIGN_8;
      default         : simd_sat_value_8[ 7: 0] = {8{1'bx}};
    endcase

  //Byte 1:
  always @*
    case ({simd_sat_overflow_wr_i[1], alu_wr_simd_sign_arth_i, simd_sat_direction_wr_i[1]})
      `ca53dpu_sel_0xx: simd_sat_value_8[15: 8] = raw_alu_data_wr_i[15: 8];
        3'b100        : simd_sat_value_8[15: 8] = SAT_POS_VAL_UNSIGN_8;
        3'b101        : simd_sat_value_8[15: 8] = SAT_NEG_VAL_UNSIGN_8;
        3'b110        : simd_sat_value_8[15: 8] = SAT_POS_VAL_SIGN_8;
        3'b111        : simd_sat_value_8[15: 8] = SAT_NEG_VAL_SIGN_8;
      default         : simd_sat_value_8[15: 8] = {8{1'bx}};
    endcase

  //Byte 2:
  always @*
    case ({simd_sat_overflow_wr_i[2], alu_wr_simd_sign_arth_i, simd_sat_direction_wr_i[2]})
      `ca53dpu_sel_0xx: simd_sat_value_8[23:16] = raw_alu_data_wr_i[23:16];
        3'b100        : simd_sat_value_8[23:16] = SAT_POS_VAL_UNSIGN_8;
        3'b101        : simd_sat_value_8[23:16] = SAT_NEG_VAL_UNSIGN_8;
        3'b110        : simd_sat_value_8[23:16] = SAT_POS_VAL_SIGN_8;
        3'b111        : simd_sat_value_8[23:16] = SAT_NEG_VAL_SIGN_8;
      default         : simd_sat_value_8[23:16] = {8{1'bx}};
    endcase

  //Byte 3:
  always @*
    case ({simd_sat_overflow_wr_i[3], alu_wr_simd_sign_arth_i, simd_sat_direction_wr_i[3]})
      `ca53dpu_sel_0xx: simd_sat_value_8[31:24] = raw_alu_data_wr_i[31:24];
        3'b100        : simd_sat_value_8[31:24] = SAT_POS_VAL_UNSIGN_8;
        3'b101        : simd_sat_value_8[31:24] = SAT_NEG_VAL_UNSIGN_8;
        3'b110        : simd_sat_value_8[31:24] = SAT_POS_VAL_SIGN_8;
        3'b111        : simd_sat_value_8[31:24] = SAT_NEG_VAL_SIGN_8;
      default         : simd_sat_value_8[31:24] = {8{1'bx}};
    endcase

  //==================================
  // 16-bit Saturation
  //=================================

  // Low halfword:
  always @*
    case ({simd_sat_overflow_wr_i[1], alu_wr_simd_sign_arth_i, simd_sat_direction_wr_i[1]})
      `ca53dpu_sel_0xx: simd_sat_value_16[15: 0] = raw_alu_data_wr_i[15: 0];
        3'b100        : simd_sat_value_16[15: 0] = SAT_POS_VAL_UNSIGN_16;
        3'b101        : simd_sat_value_16[15: 0] = SAT_NEG_VAL_UNSIGN_16;
        3'b110        : simd_sat_value_16[15: 0] = SAT_POS_VAL_SIGN_16;
        3'b111        : simd_sat_value_16[15: 0] = SAT_NEG_VAL_SIGN_16;
      default         : simd_sat_value_16[15: 0] = {16{1'bx}};
    endcase

  // High halfword:
  always @*
    case ({simd_sat_overflow_wr_i[3], alu_wr_simd_sign_arth_i, simd_sat_direction_wr_i[3]})
      `ca53dpu_sel_0xx: simd_sat_value_16[31:16] = raw_alu_data_wr_i[31:16];
        3'b100        : simd_sat_value_16[31:16] = SAT_POS_VAL_UNSIGN_16;
        3'b101        : simd_sat_value_16[31:16] = SAT_NEG_VAL_UNSIGN_16;
        3'b110        : simd_sat_value_16[31:16] = SAT_POS_VAL_SIGN_16;
        3'b111        : simd_sat_value_16[31:16] = SAT_NEG_VAL_SIGN_16;
      default         : simd_sat_value_16[31:16] = {16{1'bx}};
    endcase

  //===============================================
  // 32-bit Signed Saturation
  // Required by QADD, QDADD, QSUB, QDSUB V5E Saturate
  // instructions.
  //===============================================

  always @*
    case ({simd_sat_overflow_wr_i[3], simd_sat_direction_wr_i[3]})
      `ca53dpu_sel_0x: simd_sat_value_32[31: 0] = raw_alu_data_wr_i[31: 0];
        2'b10        : simd_sat_value_32[31: 0] = SAT_POS_VAL_SIGN_32;
        2'b11        : simd_sat_value_32[31: 0] = SAT_NEG_VAL_SIGN_32;
      default        : simd_sat_value_32[31: 0] = {32{1'bx}};
    endcase          
                     
  //--------------------------------
  //        Final Mux.
  //--------------------------------

  always @*
    case ({alu_wr_sat_valid_i, alu_wr_valid_simd_i, alu_wr_simd_size_i})
      `ca53dpu_sel_0xx: alu_data_simd_sat_wr_o = raw_alu_data_wr_i;
      `ca53dpu_sel_10x: alu_data_simd_sat_wr_o = simd_sat_value_32;
        3'b110        : alu_data_simd_sat_wr_o = simd_sat_value_8;
        3'b111        : alu_data_simd_sat_wr_o = simd_sat_value_16;
      default         : alu_data_simd_sat_wr_o = {32{1'bx}};
    endcase           
                      
  assign simd_sat_qbit_wr_o = simd_sat_overflow_wr_i[3] & alu_wr_sat_valid_i & ~alu_wr_valid_simd_i;

endmodule // ca53dpu_alu_simd_sat

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
