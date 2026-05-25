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
// Abstract: Sign bit extractor
// ----------------------------------------------------------------------------
//
// Overview
// ========
// This block obtains the value of any bit in a word given its bit position
// It is used for sign extension from an arbitrary bit (e.g. in SBFX). The
// actual sign extension is performed in the LU
//
//----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_alu_sbitx (
  input  wire   [5:0] alu_mskgen_ex2_i,
  input  wire  [63:0] alu_data_b_ex2_i,
  output wire  [63:0] alu_ex2_data_b_smask_o
);

  reg [63:0]  sign_mask;

  always @*
    case (alu_mskgen_ex2_i)
      6'b000000 : sign_mask =   {64{alu_data_b_ex2_i[ 0]}};
      6'b000001 : sign_mask = { {63{alu_data_b_ex2_i[ 1]}},     1'b0   };
      6'b000010 : sign_mask = { {62{alu_data_b_ex2_i[ 2]}}, { 2{1'b0}} };
      6'b000011 : sign_mask = { {61{alu_data_b_ex2_i[ 3]}}, { 3{1'b0}} };
      6'b000100 : sign_mask = { {60{alu_data_b_ex2_i[ 4]}}, { 4{1'b0}} };
      6'b000101 : sign_mask = { {59{alu_data_b_ex2_i[ 5]}}, { 5{1'b0}} };
      6'b000110 : sign_mask = { {58{alu_data_b_ex2_i[ 6]}}, { 6{1'b0}} };
      6'b000111 : sign_mask = { {57{alu_data_b_ex2_i[ 7]}}, { 7{1'b0}} };
      6'b001000 : sign_mask = { {56{alu_data_b_ex2_i[ 8]}}, { 8{1'b0}} };
      6'b001001 : sign_mask = { {55{alu_data_b_ex2_i[ 9]}}, { 9{1'b0}} };
      6'b001010 : sign_mask = { {54{alu_data_b_ex2_i[10]}}, {10{1'b0}} };
      6'b001011 : sign_mask = { {53{alu_data_b_ex2_i[11]}}, {11{1'b0}} };
      6'b001100 : sign_mask = { {52{alu_data_b_ex2_i[12]}}, {12{1'b0}} };
      6'b001101 : sign_mask = { {51{alu_data_b_ex2_i[13]}}, {13{1'b0}} };
      6'b001110 : sign_mask = { {50{alu_data_b_ex2_i[14]}}, {14{1'b0}} };
      6'b001111 : sign_mask = { {49{alu_data_b_ex2_i[15]}}, {15{1'b0}} };
      6'b010000 : sign_mask = { {48{alu_data_b_ex2_i[16]}}, {16{1'b0}} };
      6'b010001 : sign_mask = { {47{alu_data_b_ex2_i[17]}}, {17{1'b0}} };
      6'b010010 : sign_mask = { {46{alu_data_b_ex2_i[18]}}, {18{1'b0}} };
      6'b010011 : sign_mask = { {45{alu_data_b_ex2_i[19]}}, {19{1'b0}} };
      6'b010100 : sign_mask = { {44{alu_data_b_ex2_i[20]}}, {20{1'b0}} };
      6'b010101 : sign_mask = { {43{alu_data_b_ex2_i[21]}}, {21{1'b0}} };
      6'b010110 : sign_mask = { {42{alu_data_b_ex2_i[22]}}, {22{1'b0}} };
      6'b010111 : sign_mask = { {41{alu_data_b_ex2_i[23]}}, {23{1'b0}} };
      6'b011000 : sign_mask = { {40{alu_data_b_ex2_i[24]}}, {24{1'b0}} };
      6'b011001 : sign_mask = { {39{alu_data_b_ex2_i[25]}}, {25{1'b0}} };
      6'b011010 : sign_mask = { {38{alu_data_b_ex2_i[26]}}, {26{1'b0}} };
      6'b011011 : sign_mask = { {37{alu_data_b_ex2_i[27]}}, {27{1'b0}} };
      6'b011100 : sign_mask = { {36{alu_data_b_ex2_i[28]}}, {28{1'b0}} };
      6'b011101 : sign_mask = { {35{alu_data_b_ex2_i[29]}}, {29{1'b0}} };
      6'b011110 : sign_mask = { {34{alu_data_b_ex2_i[30]}}, {30{1'b0}} };
      6'b011111 : sign_mask = { {33{alu_data_b_ex2_i[31]}}, {31{1'b0}} };
      6'b100000 : sign_mask = { {32{alu_data_b_ex2_i[32]}}, {32{1'b0}} };
      6'b100001 : sign_mask = { {31{alu_data_b_ex2_i[33]}}, {33{1'b0}} };
      6'b100010 : sign_mask = { {30{alu_data_b_ex2_i[34]}}, {34{1'b0}} };
      6'b100011 : sign_mask = { {29{alu_data_b_ex2_i[35]}}, {35{1'b0}} };
      6'b100100 : sign_mask = { {28{alu_data_b_ex2_i[36]}}, {36{1'b0}} };
      6'b100101 : sign_mask = { {27{alu_data_b_ex2_i[37]}}, {37{1'b0}} };
      6'b100110 : sign_mask = { {26{alu_data_b_ex2_i[38]}}, {38{1'b0}} };
      6'b100111 : sign_mask = { {25{alu_data_b_ex2_i[39]}}, {39{1'b0}} };
      6'b101000 : sign_mask = { {24{alu_data_b_ex2_i[40]}}, {40{1'b0}} };
      6'b101001 : sign_mask = { {23{alu_data_b_ex2_i[41]}}, {41{1'b0}} };
      6'b101010 : sign_mask = { {22{alu_data_b_ex2_i[42]}}, {42{1'b0}} };
      6'b101011 : sign_mask = { {21{alu_data_b_ex2_i[43]}}, {43{1'b0}} };
      6'b101100 : sign_mask = { {20{alu_data_b_ex2_i[44]}}, {44{1'b0}} };
      6'b101101 : sign_mask = { {19{alu_data_b_ex2_i[45]}}, {45{1'b0}} };
      6'b101110 : sign_mask = { {18{alu_data_b_ex2_i[46]}}, {46{1'b0}} };
      6'b101111 : sign_mask = { {17{alu_data_b_ex2_i[47]}}, {47{1'b0}} };
      6'b110000 : sign_mask = { {16{alu_data_b_ex2_i[48]}}, {48{1'b0}} };
      6'b110001 : sign_mask = { {15{alu_data_b_ex2_i[49]}}, {49{1'b0}} };
      6'b110010 : sign_mask = { {14{alu_data_b_ex2_i[50]}}, {50{1'b0}} };
      6'b110011 : sign_mask = { {13{alu_data_b_ex2_i[51]}}, {51{1'b0}} };
      6'b110100 : sign_mask = { {12{alu_data_b_ex2_i[52]}}, {52{1'b0}} };
      6'b110101 : sign_mask = { {11{alu_data_b_ex2_i[53]}}, {53{1'b0}} };
      6'b110110 : sign_mask = { {10{alu_data_b_ex2_i[54]}}, {54{1'b0}} };
      6'b110111 : sign_mask = { { 9{alu_data_b_ex2_i[55]}}, {55{1'b0}} };
      6'b111000 : sign_mask = { { 8{alu_data_b_ex2_i[56]}}, {56{1'b0}} };
      6'b111001 : sign_mask = { { 7{alu_data_b_ex2_i[57]}}, {57{1'b0}} };
      6'b111010 : sign_mask = { { 6{alu_data_b_ex2_i[58]}}, {58{1'b0}} };
      6'b111011 : sign_mask = { { 5{alu_data_b_ex2_i[59]}}, {59{1'b0}} };
      6'b111100 : sign_mask = { { 4{alu_data_b_ex2_i[60]}}, {60{1'b0}} };
      6'b111101 : sign_mask = { { 3{alu_data_b_ex2_i[61]}}, {61{1'b0}} };
      6'b111110 : sign_mask = { { 2{alu_data_b_ex2_i[62]}}, {62{1'b0}} };
      6'b111111 : sign_mask = {     alu_data_b_ex2_i[63],   {63{1'b0}} };
      default   : sign_mask = {64{1'bx}};
    endcase // case (alu_mskgen_ex2_i)

  assign alu_ex2_data_b_smask_o = sign_mask;

endmodule // ca53dpu_alu_sbitx

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
