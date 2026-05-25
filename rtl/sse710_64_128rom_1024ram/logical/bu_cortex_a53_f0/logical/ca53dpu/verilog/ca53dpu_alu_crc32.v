//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2013-2015 ARM Limited.
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
// Abstract : CRC32 block
//-----------------------------------------------------------------------------
//
// Given an input data word of 8, 16, 32 or 64 bits and an input 32-bit
// checksum, calculates the CRC32 or CRC32C checksum of the data word
//
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_alu_crc32 (
  // Inputs
  input  wire        clk,
  input  wire        reset_n,
  input  wire [31:0] alu_data_a_ex2_i,
  input  wire [63:0] alu_data_b_ex2_i,
  input  wire  [5:3] alu_data_c_ex1_i,
  input  wire        crc32_valid_ex1_i,
  input  wire        en_alu_pipe_lo_ex2_i,
  input  wire        alu_ex2_simd_sign_arth_i,  // SIMD control overloaded to distinguish between CRC32 and CRC32C
  // Outputs
  output wire [31:0] crc32_res_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg         crc32_valid_ex2;
  reg         sel_crc32_8bit;
  reg         sel_crc32_16bit;
  reg         sel_crc32_32bit;
  reg         sel_crc32_64bit;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire        nxt_sel_crc32_8bit;
  wire        nxt_sel_crc32_16bit;
  wire        nxt_sel_crc32_32bit;
  wire        nxt_sel_crc32_64bit;
  wire [87:0] aligned_acc;
  wire [87:0] crc_input;
  wire [31:0] res_common;
  wire [31:0] res_crc32;
  wire [31:0] res_crc32c;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  assign nxt_sel_crc32_8bit  = crc32_valid_ex1_i & alu_data_c_ex1_i[5:3] == 3'b011;
  assign nxt_sel_crc32_16bit = crc32_valid_ex1_i & alu_data_c_ex1_i[5:3] == 3'b010;
  assign nxt_sel_crc32_32bit = crc32_valid_ex1_i & alu_data_c_ex1_i[5:3] == 3'b000;
  assign nxt_sel_crc32_64bit = crc32_valid_ex1_i & alu_data_c_ex1_i[5:3] == 3'b100; 

  always @(posedge clk)
    if (en_alu_pipe_lo_ex2_i) begin
      crc32_valid_ex2 <= crc32_valid_ex1_i;
      sel_crc32_8bit  <= nxt_sel_crc32_8bit;
      sel_crc32_16bit <= nxt_sel_crc32_16bit;
      sel_crc32_32bit <= nxt_sel_crc32_32bit;
      sel_crc32_64bit <= nxt_sel_crc32_64bit;
    end

  assign aligned_acc = ({88{sel_crc32_8bit}}  & {             alu_data_a_ex2_i[31: 0], {56{1'b0}} }) |
                       ({88{sel_crc32_16bit}} & { { 8{1'b0}}, alu_data_a_ex2_i[31: 0], {48{1'b0}} }) |
                       ({88{sel_crc32_32bit}} & { {24{1'b0}}, alu_data_a_ex2_i[31: 0], {32{1'b0}} }) |
                       ({88{sel_crc32_64bit}} & { {56{1'b0}}, alu_data_a_ex2_i[31: 0]             });

  // The alignment of the input data is performed in the Ex1 shifter
  // To reduce power for non-64-bit operations, the data is presented
  // rotated by 32 bits

  assign crc_input = aligned_acc ^ ({ {24{1'b0}}, {32{crc32_valid_ex2}} & alu_data_b_ex2_i[31: 0], {32{sel_crc32_64bit}} & alu_data_b_ex2_i[63:32]});

  // ------------------------------------------------------
  // Start automatically generated logic
  // ------------------------------------------------------

  assign res_common[ 0] = crc_input[58] ^ crc_input[55] ^ crc_input[52] ^ crc_input[48] ^
                          crc_input[39] ^ crc_input[38] ^ crc_input[36] ^ crc_input[34] ^
                          crc_input[33] ^ crc_input[27] ^ crc_input[19] ^ crc_input[17] ^
                          crc_input[16] ^ crc_input[11] ^ crc_input[10];
  assign res_common[ 1] = crc_input[59] ^ crc_input[56] ^ crc_input[53] ^ crc_input[49] ^
                          crc_input[40] ^ crc_input[39] ^ crc_input[37] ^ crc_input[35] ^
                          crc_input[34] ^ crc_input[28] ^ crc_input[20] ^ crc_input[18] ^
                          crc_input[17] ^ crc_input[12] ^ crc_input[11] ^ crc_input[ 0];
  assign res_common[ 2] = crc_input[60] ^ crc_input[57] ^ crc_input[54] ^ crc_input[50] ^
                          crc_input[41] ^ crc_input[40] ^ crc_input[38] ^ crc_input[36] ^
                          crc_input[35] ^ crc_input[29] ^ crc_input[21] ^ crc_input[19] ^
                          crc_input[18] ^ crc_input[13] ^ crc_input[12] ^ crc_input[ 1] ^
                          crc_input[ 0];
  assign res_common[ 3] = crc_input[61] ^ crc_input[58] ^ crc_input[55] ^ crc_input[51] ^
                          crc_input[42] ^ crc_input[41] ^ crc_input[39] ^ crc_input[37] ^
                          crc_input[36] ^ crc_input[30] ^ crc_input[22] ^ crc_input[20] ^
                          crc_input[19] ^ crc_input[14] ^ crc_input[13] ^ crc_input[ 2] ^
                          crc_input[ 1];
  assign res_common[ 4] = crc_input[62] ^ crc_input[58] ^ crc_input[42] ^ crc_input[40] ^
                          crc_input[39] ^ crc_input[36] ^ crc_input[34] ^ crc_input[31] ^
                          crc_input[23] ^ crc_input[20] ^ crc_input[18] ^ crc_input[15] ^
                          crc_input[14] ^ crc_input[13] ^ crc_input[10] ^ crc_input[ 5] ^
                          crc_input[ 3];
  assign res_common[ 5] = crc_input[63] ^ crc_input[60] ^ crc_input[57] ^ crc_input[40] ^
                          crc_input[39] ^ crc_input[38] ^ crc_input[35] ^ crc_input[32] ^
                          crc_input[24] ^ crc_input[22] ^ crc_input[15] ^ crc_input[14] ^
                          crc_input[ 6] ^ crc_input[ 4] ^ crc_input[ 2];
  assign res_common[ 6] = crc_input[61] ^ crc_input[60] ^ crc_input[55] ^ crc_input[48] ^
                          crc_input[46] ^ crc_input[35] ^ crc_input[34] ^ crc_input[25] ^
                          crc_input[23] ^ crc_input[22] ^ crc_input[15] ^ crc_input[14] ^
                          crc_input[11] ^ crc_input[ 7] ^ crc_input[ 2] ^ crc_input[ 1];
  assign res_common[ 7] = crc_input[62] ^ crc_input[61] ^ crc_input[49] ^ crc_input[46] ^
                          crc_input[43] ^ crc_input[35] ^ crc_input[33] ^ crc_input[28] ^
                          crc_input[27] ^ crc_input[26] ^ crc_input[24] ^ crc_input[23] ^
                          crc_input[15] ^ crc_input[13] ^ crc_input[12] ^ crc_input[ 8] ^
                          crc_input[ 3];
  assign res_common[ 8] = crc_input[63] ^ crc_input[62] ^ crc_input[50] ^ crc_input[47] ^
                          crc_input[44] ^ crc_input[36] ^ crc_input[34] ^ crc_input[29] ^
                          crc_input[28] ^ crc_input[27] ^ crc_input[25] ^ crc_input[24] ^
                          crc_input[16] ^ crc_input[14] ^ crc_input[13] ^ crc_input[ 9] ^
                          crc_input[ 4];
  assign res_common[ 9] = crc_input[63] ^ crc_input[54] ^ crc_input[51] ^ crc_input[47] ^
                          crc_input[45] ^ crc_input[40] ^ crc_input[32] ^ crc_input[27] ^
                          crc_input[26] ^ crc_input[25] ^ crc_input[22] ^ crc_input[18] ^
                          crc_input[16] ^ crc_input[15] ^ crc_input[ 6] ^ crc_input[ 2] ^
                          crc_input[ 1];
  assign res_common[10] = crc_input[58] ^ crc_input[54] ^ crc_input[37] ^ crc_input[29] ^
                          crc_input[26] ^ crc_input[23] ^ crc_input[21] ^ crc_input[14] ^
                          crc_input[11] ^ crc_input[10] ^ crc_input[ 7];
  assign res_common[11] = crc_input[59] ^ crc_input[55] ^ crc_input[38] ^ crc_input[30] ^
                          crc_input[27] ^ crc_input[24] ^ crc_input[22] ^ crc_input[15] ^
                          crc_input[12] ^ crc_input[11] ^ crc_input[ 8];
  assign res_common[12] = crc_input[55] ^ crc_input[52] ^ crc_input[48] ^ crc_input[47] ^
                          crc_input[43] ^ crc_input[41] ^ crc_input[38] ^ crc_input[36] ^
                          crc_input[34] ^ crc_input[31] ^ crc_input[25] ^ crc_input[23] ^
                          crc_input[12] ^ crc_input[ 9];
  assign res_common[13] = crc_input[57] ^ crc_input[53] ^ crc_input[49] ^ crc_input[44] ^
                          crc_input[42] ^ crc_input[35] ^ crc_input[32] ^ crc_input[29] ^
                          crc_input[26] ^ crc_input[24] ^ crc_input[17] ^ crc_input[ 5];
  assign res_common[14] = crc_input[57] ^ crc_input[54] ^ crc_input[50] ^ crc_input[45] ^
                          crc_input[41] ^ crc_input[38] ^ crc_input[30] ^ crc_input[25] ^
                          crc_input[16] ^ crc_input[11] ^ crc_input[ 6] ^ crc_input[ 5];
  assign res_common[15] = crc_input[58] ^ crc_input[55] ^ crc_input[51] ^ crc_input[46] ^
                          crc_input[42] ^ crc_input[39] ^ crc_input[31] ^ crc_input[26] ^
                          crc_input[17] ^ crc_input[12] ^ crc_input[ 7] ^ crc_input[ 6];
  assign res_common[16] = crc_input[59] ^ crc_input[56] ^ crc_input[55] ^ crc_input[54] ^
                          crc_input[47] ^ crc_input[43] ^ crc_input[33] ^ crc_input[30] ^
                          crc_input[18] ^ crc_input[14] ^ crc_input[13] ^ crc_input[11] ^
                          crc_input[ 8] ^ crc_input[ 7] ^ crc_input[ 3];
  assign res_common[17] = crc_input[60] ^ crc_input[57] ^ crc_input[56] ^ crc_input[55] ^
                          crc_input[48] ^ crc_input[44] ^ crc_input[34] ^ crc_input[31] ^
                          crc_input[19] ^ crc_input[15] ^ crc_input[14] ^ crc_input[12] ^
                          crc_input[ 9] ^ crc_input[ 8] ^ crc_input[ 4];
  assign res_common[18] = crc_input[61] ^ crc_input[60] ^ crc_input[49] ^ crc_input[47] ^
                          crc_input[45] ^ crc_input[41] ^ crc_input[38] ^ crc_input[35] ^
                          crc_input[32] ^ crc_input[21] ^ crc_input[20] ^ crc_input[15] ^
                          crc_input[11] ^ crc_input[ 9];
  assign res_common[19] = crc_input[62] ^ crc_input[61] ^ crc_input[59] ^ crc_input[58] ^
                          crc_input[57] ^ crc_input[50] ^ crc_input[42] ^ crc_input[17] ^
                          crc_input[13] ^ crc_input[12] ^ crc_input[11] ^ crc_input[ 2] ^
                          crc_input[ 0];
  assign res_common[20] = crc_input[63] ^ crc_input[62] ^ crc_input[60] ^ crc_input[59] ^
                          crc_input[54] ^ crc_input[51] ^ crc_input[43] ^ crc_input[30] ^
                          crc_input[18] ^ crc_input[16] ^ crc_input[13] ^ crc_input[12] ^
                          crc_input[ 4];
  assign res_common[21] = crc_input[63] ^ crc_input[61] ^ crc_input[47] ^ crc_input[44] ^
                          crc_input[37] ^ crc_input[34] ^ crc_input[31] ^ crc_input[28] ^
                          crc_input[27] ^ crc_input[21] ^ crc_input[11] ^ crc_input[ 4] ^
                          crc_input[ 3] ^ crc_input[ 1] ^ crc_input[ 0];
  assign res_common[22] = crc_input[62] ^ crc_input[59] ^ crc_input[52] ^ crc_input[45] ^
                          crc_input[40] ^ crc_input[30] ^ crc_input[27] ^ crc_input[12] ^
                          crc_input[10];
  assign res_common[23] = crc_input[63] ^ crc_input[59] ^ crc_input[55] ^ crc_input[53] ^
                          crc_input[52] ^ crc_input[31] ^ crc_input[29] ^ crc_input[21] ^
                          crc_input[18] ^ crc_input[17];
  assign res_common[24] = crc_input[58] ^ crc_input[55] ^ crc_input[53] ^ crc_input[48] ^
                          crc_input[47] ^ crc_input[41] ^ crc_input[40] ^ crc_input[38] ^
                          crc_input[34] ^ crc_input[29] ^ crc_input[21] ^ crc_input[17] ^
                          crc_input[16] ^ crc_input[13] ^ crc_input[ 5];
  assign res_common[25] = crc_input[59] ^ crc_input[58] ^ crc_input[56] ^ crc_input[55] ^
                          crc_input[52] ^ crc_input[49] ^ crc_input[42] ^ crc_input[41] ^
                          crc_input[38] ^ crc_input[34] ^ crc_input[33] ^ crc_input[22] ^
                          crc_input[18] ^ crc_input[16] ^ crc_input[11] ^ crc_input[ 3] ^
                          crc_input[ 1];
  assign res_common[26] = crc_input[58] ^ crc_input[53] ^ crc_input[50] ^ crc_input[42] ^
                          crc_input[35] ^ crc_input[23] ^ crc_input[22] ^ crc_input[21] ^
                          crc_input[13] ^ crc_input[12] ^ crc_input[10] ^ crc_input[ 4];
  assign res_common[27] = crc_input[59] ^ crc_input[55] ^ crc_input[52] ^ crc_input[51] ^
                          crc_input[43] ^ crc_input[38] ^ crc_input[34] ^ crc_input[33] ^
                          crc_input[32] ^ crc_input[24] ^ crc_input[23] ^ crc_input[22] ^
                          crc_input[17] ^ crc_input[16] ^ crc_input[13] ^ crc_input[ 6] ^
                          crc_input[ 5] ^ crc_input[ 0];
  assign res_common[28] = crc_input[60] ^ crc_input[56] ^ crc_input[55] ^ crc_input[54] ^
                          crc_input[53] ^ crc_input[48] ^ crc_input[44] ^ crc_input[32] ^
                          crc_input[30] ^ crc_input[25] ^ crc_input[24] ^ crc_input[23] ^
                          crc_input[18] ^ crc_input[ 9] ^ crc_input[ 7];
  assign res_common[29] = crc_input[61] ^ crc_input[57] ^ crc_input[56] ^ crc_input[55] ^
                          crc_input[54] ^ crc_input[49] ^ crc_input[45] ^ crc_input[33] ^
                          crc_input[31] ^ crc_input[26] ^ crc_input[25] ^ crc_input[24] ^
                          crc_input[19] ^ crc_input[10] ^ crc_input[ 8];
  assign res_common[30] = crc_input[62] ^ crc_input[57] ^ crc_input[56] ^ crc_input[54] ^
                          crc_input[50] ^ crc_input[46] ^ crc_input[39] ^ crc_input[36] ^
                          crc_input[35] ^ crc_input[26] ^ crc_input[25] ^ crc_input[19] ^
                          crc_input[17] ^ crc_input[16] ^ crc_input[14] ^ crc_input[ 3] ^
                          crc_input[ 0];
  assign res_common[31] = crc_input[63] ^ crc_input[57] ^ crc_input[54] ^ crc_input[51] ^
                          crc_input[47] ^ crc_input[38] ^ crc_input[37] ^ crc_input[35] ^
                          crc_input[33] ^ crc_input[32] ^ crc_input[26] ^ crc_input[18] ^
                          crc_input[16] ^ crc_input[15] ^ crc_input[10] ^ crc_input[ 9];

  assign res_crc32[ 0]  = crc_input[54] ^ crc_input[40] ^ crc_input[35] ^ crc_input[32] ^
                          crc_input[30] ^ crc_input[20] ^ crc_input[14] ^ crc_input[ 9] ^
                          crc_input[ 6] ^ crc_input[ 4] ^ crc_input[ 3] ^ crc_input[ 1];
  assign res_crc32[ 1]  = crc_input[55] ^ crc_input[41] ^ crc_input[36] ^ crc_input[33] ^
                          crc_input[31] ^ crc_input[21] ^ crc_input[15] ^ crc_input[10] ^
                          crc_input[ 7] ^ crc_input[ 5] ^ crc_input[ 4] ^ crc_input[ 2];
  assign res_crc32[ 2]  = crc_input[56] ^ crc_input[42] ^ crc_input[37] ^ crc_input[34] ^
                          crc_input[32] ^ crc_input[22] ^ crc_input[16] ^ crc_input[11] ^
                          crc_input[ 8] ^ crc_input[ 6] ^ crc_input[ 5] ^ crc_input[ 3];
  assign res_crc32[ 3]  = crc_input[57] ^ crc_input[43] ^ crc_input[38] ^ crc_input[35] ^
                          crc_input[33] ^ crc_input[23] ^ crc_input[17] ^ crc_input[12] ^
                          crc_input[ 9] ^ crc_input[ 7] ^ crc_input[ 6] ^ crc_input[ 4] ^
                          crc_input[ 0];
  assign res_crc32[ 4]  = crc_input[59] ^ crc_input[56] ^ crc_input[52] ^ crc_input[44] ^
                          crc_input[43] ^ crc_input[38] ^ crc_input[37] ^ crc_input[24] ^
                          crc_input[21] ^ crc_input[ 8] ^ crc_input[ 7] ^ crc_input[ 2] ^
                          crc_input[ 1] ^ crc_input[ 0];
  assign res_crc32[ 5]  = crc_input[59] ^ crc_input[53] ^ crc_input[45] ^ crc_input[44] ^
                          crc_input[43] ^ crc_input[41] ^ crc_input[37] ^ crc_input[25] ^
                          crc_input[21] ^ crc_input[19] ^ crc_input[16] ^ crc_input[11] ^
                          crc_input[ 9] ^ crc_input[ 8] ^ crc_input[ 3] ^ crc_input[ 1];
  assign res_crc32[ 6]  = crc_input[52] ^ crc_input[45] ^ crc_input[44] ^ crc_input[42] ^
                          crc_input[41] ^ crc_input[32] ^ crc_input[30] ^ crc_input[27] ^
                          crc_input[26] ^ crc_input[19] ^ crc_input[12] ^ crc_input[ 6] ^
                          crc_input[ 5];
  assign res_crc32[ 7]  = crc_input[56] ^ crc_input[53] ^ crc_input[47] ^ crc_input[45] ^
                          crc_input[42] ^ crc_input[36] ^ crc_input[31] ^ crc_input[20] ^
                          crc_input[16] ^ crc_input[ 7] ^ crc_input[ 6] ^ crc_input[ 2] ^
                          crc_input[ 0];
  assign res_crc32[ 8]  = crc_input[57] ^ crc_input[54] ^ crc_input[48] ^ crc_input[46] ^
                          crc_input[43] ^ crc_input[37] ^ crc_input[32] ^ crc_input[21] ^
                          crc_input[17] ^ crc_input[ 8] ^ crc_input[ 7] ^ crc_input[ 3] ^
                          crc_input[ 1];
  assign res_crc32[ 9]  = crc_input[52] ^ crc_input[49] ^ crc_input[44] ^ crc_input[39] ^
                          crc_input[37] ^ crc_input[36] ^ crc_input[34] ^ crc_input[29] ^
                          crc_input[28] ^ crc_input[20] ^ crc_input[19] ^ crc_input[11] ^
                          crc_input[ 8] ^ crc_input[ 5] ^ crc_input[ 3];
  assign res_crc32[10]  = crc_input[53] ^ crc_input[50] ^ crc_input[46] ^ crc_input[45] ^
                          crc_input[41] ^ crc_input[39] ^ crc_input[36] ^ crc_input[34] ^
                          crc_input[32] ^ crc_input[28] ^ crc_input[12] ^ crc_input[ 2] ^
                          crc_input[ 1];
  assign res_crc32[11]  = crc_input[54] ^ crc_input[51] ^ crc_input[47] ^ crc_input[46] ^
                          crc_input[42] ^ crc_input[40] ^ crc_input[37] ^ crc_input[35] ^
                          crc_input[33] ^ crc_input[29] ^ crc_input[13] ^ crc_input[ 3] ^
                          crc_input[ 2];
  assign res_crc32[12]  = crc_input[60] ^ crc_input[56] ^ crc_input[39] ^ crc_input[30] ^
                          crc_input[28] ^ crc_input[16] ^ crc_input[14] ^ crc_input[13] ^
                          crc_input[ 4] ^ crc_input[ 3];
  assign res_crc32[13]  = crc_input[61] ^ crc_input[56] ^ crc_input[48] ^ crc_input[40] ^
                          crc_input[39] ^ crc_input[37] ^ crc_input[31] ^ crc_input[15] ^
                          crc_input[14] ^ crc_input[13] ^ crc_input[10] ^ crc_input[ 4];
  assign res_crc32[14]  = crc_input[62] ^ crc_input[58] ^ crc_input[49] ^ crc_input[43] ^
                          crc_input[40] ^ crc_input[36] ^ crc_input[33] ^ crc_input[32] ^
                          crc_input[27] ^ crc_input[18] ^ crc_input[15] ^ crc_input[14];
  assign res_crc32[15]  = crc_input[63] ^ crc_input[59] ^ crc_input[50] ^ crc_input[44] ^
                          crc_input[41] ^ crc_input[37] ^ crc_input[34] ^ crc_input[33] ^
                          crc_input[28] ^ crc_input[19] ^ crc_input[16] ^ crc_input[15];
  assign res_crc32[16]  = crc_input[60] ^ crc_input[58] ^ crc_input[51] ^ crc_input[48] ^
                          crc_input[45] ^ crc_input[42] ^ crc_input[39] ^ crc_input[36] ^
                          crc_input[29] ^ crc_input[19] ^ crc_input[10] ^ crc_input[ 9] ^
                          crc_input[ 6] ^ crc_input[ 4] ^ crc_input[ 1];
  assign res_crc32[17]  = crc_input[61] ^ crc_input[59] ^ crc_input[52] ^ crc_input[49] ^
                          crc_input[46] ^ crc_input[43] ^ crc_input[40] ^ crc_input[37] ^
                          crc_input[30] ^ crc_input[20] ^ crc_input[11] ^ crc_input[10] ^
                          crc_input[ 7] ^ crc_input[ 5] ^ crc_input[ 2] ^ crc_input[ 0];
  assign res_crc32[18]  = crc_input[62] ^ crc_input[58] ^ crc_input[57] ^ crc_input[56] ^
                          crc_input[53] ^ crc_input[50] ^ crc_input[44] ^ crc_input[31] ^
                          crc_input[16] ^ crc_input[13] ^ crc_input[12] ^ crc_input[10] ^
                          crc_input[ 8] ^ crc_input[ 6] ^ crc_input[ 5] ^ crc_input[ 3] ^
                          crc_input[ 1];
  assign res_crc32[19]  = crc_input[63] ^ crc_input[54] ^ crc_input[51] ^ crc_input[48] ^
                          crc_input[46] ^ crc_input[45] ^ crc_input[39] ^ crc_input[36] ^
                          crc_input[33] ^ crc_input[32] ^ crc_input[22] ^ crc_input[21] ^
                          crc_input[16] ^ crc_input[14] ^ crc_input[10] ^ crc_input[ 9] ^
                          crc_input[ 7] ^ crc_input[ 6] ^ crc_input[ 4];
  assign res_crc32[20]  = crc_input[49] ^ crc_input[48] ^ crc_input[47] ^ crc_input[46] ^
                          crc_input[39] ^ crc_input[38] ^ crc_input[37] ^ crc_input[36] ^
                          crc_input[35] ^ crc_input[32] ^ crc_input[27] ^ crc_input[23] ^
                          crc_input[22] ^ crc_input[20] ^ crc_input[19] ^ crc_input[15] ^
                          crc_input[ 9] ^ crc_input[ 8] ^ crc_input[ 7] ^ crc_input[ 6] ^
                          crc_input[ 5];
  assign res_crc32[21]  = crc_input[60] ^ crc_input[58] ^ crc_input[54] ^ crc_input[50] ^
                          crc_input[49] ^ crc_input[35] ^ crc_input[32] ^ crc_input[30] ^
                          crc_input[24] ^ crc_input[23] ^ crc_input[13] ^ crc_input[ 8] ^
                          crc_input[ 7] ^ crc_input[ 5];
  assign res_crc32[22]  = crc_input[61] ^ crc_input[58] ^ crc_input[54] ^ crc_input[51] ^
                          crc_input[50] ^ crc_input[39] ^ crc_input[34] ^ crc_input[31] ^
                          crc_input[29] ^ crc_input[28] ^ crc_input[25] ^ crc_input[24] ^
                          crc_input[22] ^ crc_input[20] ^ crc_input[19] ^ crc_input[17] ^
                          crc_input[16] ^ crc_input[11] ^ crc_input[ 8] ^ crc_input[ 5] ^
                          crc_input[ 3] ^ crc_input[ 2];
  assign res_crc32[23]  = crc_input[62] ^ crc_input[60] ^ crc_input[51] ^ crc_input[46] ^
                          crc_input[41] ^ crc_input[40] ^ crc_input[35] ^ crc_input[32] ^
                          crc_input[30] ^ crc_input[28] ^ crc_input[26] ^ crc_input[25] ^
                          crc_input[23] ^ crc_input[20] ^ crc_input[13] ^ crc_input[12] ^
                          crc_input[11] ^ crc_input[ 9] ^ crc_input[ 6] ^ crc_input[ 4] ^
                          crc_input[ 3] ^ crc_input[ 0];
  assign res_crc32[24]  = crc_input[63] ^ crc_input[61] ^ crc_input[60] ^ crc_input[56] ^
                          crc_input[42] ^ crc_input[39] ^ crc_input[35] ^ crc_input[31] ^
                          crc_input[26] ^ crc_input[24] ^ crc_input[22] ^ crc_input[20] ^
                          crc_input[18] ^ crc_input[12] ^ crc_input[11] ^ crc_input[ 9] ^
                          crc_input[ 7] ^ crc_input[ 6] ^ crc_input[ 3];
  assign res_crc32[25]  = crc_input[62] ^ crc_input[61] ^ crc_input[57] ^ crc_input[43] ^
                          crc_input[25] ^ crc_input[23] ^ crc_input[21] ^ crc_input[20] ^
                          crc_input[13] ^ crc_input[12] ^ crc_input[ 9] ^ crc_input[ 8] ^
                          crc_input[ 7];
  assign res_crc32[26]  = crc_input[63] ^ crc_input[62] ^ crc_input[60] ^ crc_input[59] ^
                          crc_input[57] ^ crc_input[56] ^ crc_input[44] ^ crc_input[43] ^
                          crc_input[39] ^ crc_input[34] ^ crc_input[26] ^ crc_input[24] ^
                          crc_input[19] ^ crc_input[17] ^ crc_input[14] ^ crc_input[ 9] ^
                          crc_input[ 8] ^ crc_input[ 2] ^ crc_input[ 0];
  assign res_crc32[27]  = crc_input[63] ^ crc_input[61] ^ crc_input[60] ^ crc_input[57] ^
                          crc_input[48] ^ crc_input[45] ^ crc_input[44] ^ crc_input[39] ^
                          crc_input[30] ^ crc_input[25] ^ crc_input[19] ^ crc_input[18] ^
                          crc_input[15] ^ crc_input[ 4];
  assign res_crc32[28]  = crc_input[62] ^ crc_input[61] ^ crc_input[49] ^ crc_input[46] ^
                          crc_input[45] ^ crc_input[38] ^ crc_input[36] ^ crc_input[31] ^
                          crc_input[27] ^ crc_input[26] ^ crc_input[11] ^ crc_input[10] ^
                          crc_input[ 5] ^ crc_input[ 4] ^ crc_input[ 3];
  assign res_crc32[29]  = crc_input[63] ^ crc_input[62] ^ crc_input[50] ^ crc_input[47] ^
                          crc_input[46] ^ crc_input[39] ^ crc_input[37] ^ crc_input[32] ^
                          crc_input[28] ^ crc_input[27] ^ crc_input[12] ^ crc_input[11] ^
                          crc_input[ 6] ^ crc_input[ 5] ^ crc_input[ 4];
  assign res_crc32[30]  = crc_input[63] ^ crc_input[52] ^ crc_input[51] ^ crc_input[47] ^
                          crc_input[30] ^ crc_input[29] ^ crc_input[28] ^ crc_input[13] ^
                          crc_input[12] ^ crc_input[10] ^ crc_input[ 7] ^ crc_input[ 5] ^
                          crc_input[ 4] ^ crc_input[ 1];
  assign res_crc32[31]  = crc_input[53] ^ crc_input[39] ^ crc_input[34] ^ crc_input[31] ^
                          crc_input[29] ^ crc_input[19] ^ crc_input[13] ^ crc_input[ 8] ^
                          crc_input[ 5] ^ crc_input[ 3] ^ crc_input[ 2] ^ crc_input[ 0];

  assign res_crc32c[ 0] = crc_input[60] ^ crc_input[59] ^ crc_input[57] ^ crc_input[56] ^
                          crc_input[47] ^ crc_input[46] ^ crc_input[43] ^ crc_input[41] ^
                          crc_input[37] ^ crc_input[29] ^ crc_input[28] ^ crc_input[22] ^
                          crc_input[21] ^ crc_input[18] ^ crc_input[13] ^ crc_input[ 5] ^
                          crc_input[ 2] ^ crc_input[ 0];
  assign res_crc32c[ 1] = crc_input[61] ^ crc_input[60] ^ crc_input[58] ^ crc_input[57] ^
                          crc_input[48] ^ crc_input[47] ^ crc_input[44] ^ crc_input[42] ^
                          crc_input[38] ^ crc_input[30] ^ crc_input[29] ^ crc_input[23] ^
                          crc_input[22] ^ crc_input[19] ^ crc_input[14] ^ crc_input[ 6] ^
                          crc_input[ 3] ^ crc_input[ 1];
  assign res_crc32c[ 2] = crc_input[62] ^ crc_input[61] ^ crc_input[59] ^ crc_input[58] ^
                          crc_input[49] ^ crc_input[48] ^ crc_input[45] ^ crc_input[43] ^
                          crc_input[39] ^ crc_input[31] ^ crc_input[30] ^ crc_input[24] ^
                          crc_input[23] ^ crc_input[20] ^ crc_input[15] ^ crc_input[ 7] ^
                          crc_input[ 4] ^ crc_input[ 2];
  assign res_crc32c[ 3] = crc_input[63] ^ crc_input[62] ^ crc_input[60] ^ crc_input[59] ^
                          crc_input[50] ^ crc_input[49] ^ crc_input[46] ^ crc_input[44] ^
                          crc_input[40] ^ crc_input[32] ^ crc_input[31] ^ crc_input[25] ^
                          crc_input[24] ^ crc_input[21] ^ crc_input[16] ^ crc_input[ 8] ^
                          crc_input[ 5] ^ crc_input[ 3];
  assign res_crc32c[ 4] = crc_input[63] ^ crc_input[61] ^ crc_input[57] ^ crc_input[55] ^
                          crc_input[51] ^ crc_input[50] ^ crc_input[48] ^ crc_input[46] ^
                          crc_input[45] ^ crc_input[32] ^ crc_input[29] ^ crc_input[28] ^
                          crc_input[27] ^ crc_input[26] ^ crc_input[25] ^ crc_input[19] ^
                          crc_input[16] ^ crc_input[11] ^ crc_input[ 9] ^ crc_input[ 6] ^
                          crc_input[ 4];
  assign res_crc32c[ 5] = crc_input[62] ^ crc_input[55] ^ crc_input[51] ^ crc_input[49] ^
                          crc_input[48] ^ crc_input[36] ^ crc_input[34] ^ crc_input[30] ^
                          crc_input[26] ^ crc_input[20] ^ crc_input[18] ^ crc_input[13] ^
                          crc_input[12] ^ crc_input[ 7] ^ crc_input[ 0];
  assign res_crc32c[ 6] = crc_input[63] ^ crc_input[59] ^ crc_input[57] ^ crc_input[50] ^
                          crc_input[49] ^ crc_input[47] ^ crc_input[43] ^ crc_input[40] ^
                          crc_input[38] ^ crc_input[31] ^ crc_input[29] ^ crc_input[28] ^
                          crc_input[18] ^ crc_input[17] ^ crc_input[10] ^ crc_input[ 8] ^
                          crc_input[ 3];
  assign res_crc32c[ 7] = crc_input[59] ^ crc_input[57] ^ crc_input[55] ^ crc_input[52] ^
                          crc_input[51] ^ crc_input[50] ^ crc_input[44] ^ crc_input[38] ^
                          crc_input[37] ^ crc_input[34] ^ crc_input[32] ^ crc_input[30] ^
                          crc_input[22] ^ crc_input[21] ^ crc_input[17] ^ crc_input[10] ^
                          crc_input[ 9] ^ crc_input[ 5] ^ crc_input[ 4];
  assign res_crc32c[ 8] = crc_input[60] ^ crc_input[58] ^ crc_input[56] ^ crc_input[53] ^
                          crc_input[52] ^ crc_input[51] ^ crc_input[45] ^ crc_input[39] ^
                          crc_input[38] ^ crc_input[35] ^ crc_input[33] ^ crc_input[31] ^
                          crc_input[23] ^ crc_input[22] ^ crc_input[18] ^ crc_input[11] ^
                          crc_input[10] ^ crc_input[ 6] ^ crc_input[ 5] ^ crc_input[ 0];
  assign res_crc32c[ 9] = crc_input[61] ^ crc_input[60] ^ crc_input[58] ^ crc_input[56] ^
                          crc_input[55] ^ crc_input[53] ^ crc_input[43] ^ crc_input[41] ^
                          crc_input[38] ^ crc_input[35] ^ crc_input[33] ^ crc_input[30] ^
                          crc_input[24] ^ crc_input[23] ^ crc_input[21] ^ crc_input[14] ^
                          crc_input[13] ^ crc_input[12] ^ crc_input[ 7];
  assign res_crc32c[10] = crc_input[62] ^ crc_input[61] ^ crc_input[60] ^ crc_input[47] ^
                          crc_input[44] ^ crc_input[43] ^ crc_input[42] ^ crc_input[38] ^
                          crc_input[31] ^ crc_input[25] ^ crc_input[24] ^ crc_input[18] ^
                          crc_input[15] ^ crc_input[ 8] ^ crc_input[ 5] ^ crc_input[ 3] ^
                          crc_input[ 0];
  assign res_crc32c[11] = crc_input[63] ^ crc_input[62] ^ crc_input[61] ^ crc_input[48] ^
                          crc_input[45] ^ crc_input[44] ^ crc_input[43] ^ crc_input[39] ^
                          crc_input[32] ^ crc_input[26] ^ crc_input[25] ^ crc_input[19] ^
                          crc_input[16] ^ crc_input[ 9] ^ crc_input[ 6] ^ crc_input[ 4] ^
                          crc_input[ 1] ^ crc_input[ 0];
  assign res_crc32c[12] = crc_input[63] ^ crc_input[62] ^ crc_input[59] ^ crc_input[58] ^
                          crc_input[57] ^ crc_input[49] ^ crc_input[45] ^ crc_input[44] ^
                          crc_input[40] ^ crc_input[37] ^ crc_input[29] ^ crc_input[26] ^
                          crc_input[22] ^ crc_input[21] ^ crc_input[20] ^ crc_input[19] ^
                          crc_input[18] ^ crc_input[11] ^ crc_input[ 7] ^ crc_input[ 1] ^
                          crc_input[ 0];
  assign res_crc32c[13] = crc_input[63] ^ crc_input[55] ^ crc_input[52] ^ crc_input[50] ^
                          crc_input[47] ^ crc_input[45] ^ crc_input[43] ^ crc_input[36] ^
                          crc_input[34] ^ crc_input[33] ^ crc_input[30] ^ crc_input[28] ^
                          crc_input[23] ^ crc_input[20] ^ crc_input[18] ^ crc_input[16] ^
                          crc_input[12] ^ crc_input[11] ^ crc_input[ 8] ^ crc_input[ 1] ^
                          crc_input[ 0];
  assign res_crc32c[14] = crc_input[60] ^ crc_input[59] ^ crc_input[55] ^ crc_input[53] ^
                          crc_input[52] ^ crc_input[51] ^ crc_input[47] ^ crc_input[44] ^
                          crc_input[39] ^ crc_input[35] ^ crc_input[31] ^ crc_input[28] ^
                          crc_input[24] ^ crc_input[22] ^ crc_input[12] ^ crc_input[10] ^
                          crc_input[ 9] ^ crc_input[ 1] ^ crc_input[ 0];
  assign res_crc32c[15] = crc_input[61] ^ crc_input[60] ^ crc_input[56] ^ crc_input[54] ^
                          crc_input[53] ^ crc_input[52] ^ crc_input[48] ^ crc_input[45] ^
                          crc_input[40] ^ crc_input[36] ^ crc_input[32] ^ crc_input[29] ^
                          crc_input[25] ^ crc_input[23] ^ crc_input[13] ^ crc_input[11] ^
                          crc_input[10] ^ crc_input[ 2] ^ crc_input[ 1];
  assign res_crc32c[16] = crc_input[62] ^ crc_input[61] ^ crc_input[57] ^ crc_input[53] ^
                          crc_input[52] ^ crc_input[49] ^ crc_input[46] ^ crc_input[41] ^
                          crc_input[40] ^ crc_input[37] ^ crc_input[32] ^ crc_input[27] ^
                          crc_input[26] ^ crc_input[24] ^ crc_input[12] ^ crc_input[ 2];
  assign res_crc32c[17] = crc_input[63] ^ crc_input[62] ^ crc_input[58] ^ crc_input[54] ^
                          crc_input[53] ^ crc_input[50] ^ crc_input[47] ^ crc_input[42] ^
                          crc_input[41] ^ crc_input[38] ^ crc_input[33] ^ crc_input[28] ^
                          crc_input[27] ^ crc_input[25] ^ crc_input[13] ^ crc_input[ 3];
  assign res_crc32c[18] = crc_input[63] ^ crc_input[54] ^ crc_input[52] ^ crc_input[51] ^
                          crc_input[46] ^ crc_input[42] ^ crc_input[37] ^ crc_input[36] ^
                          crc_input[33] ^ crc_input[27] ^ crc_input[26] ^ crc_input[22] ^
                          crc_input[19] ^ crc_input[18] ^ crc_input[17] ^ crc_input[14] ^
                          crc_input[ 4] ^ crc_input[ 2] ^ crc_input[ 0];
  assign res_crc32c[19] = crc_input[60] ^ crc_input[56] ^ crc_input[53] ^ crc_input[41] ^
                          crc_input[29] ^ crc_input[23] ^ crc_input[20] ^ crc_input[15] ^
                          crc_input[ 3] ^ crc_input[ 1];
  assign res_crc32c[20] = crc_input[61] ^ crc_input[58] ^ crc_input[57] ^ crc_input[42] ^
                          crc_input[24] ^ crc_input[21] ^ crc_input[14] ^ crc_input[ 3] ^
                          crc_input[ 2] ^ crc_input[ 1] ^ crc_input[ 0];
  assign res_crc32c[21] = crc_input[62] ^ crc_input[57] ^ crc_input[56] ^ crc_input[48] ^
                          crc_input[46] ^ crc_input[41] ^ crc_input[39] ^ crc_input[38] ^
                          crc_input[36] ^ crc_input[33] ^ crc_input[29] ^ crc_input[25] ^
                          crc_input[18] ^ crc_input[16] ^ crc_input[15] ^ crc_input[14] ^
                          crc_input[10];
  assign res_crc32c[22] = crc_input[63] ^ crc_input[60] ^ crc_input[56] ^ crc_input[55] ^
                          crc_input[49] ^ crc_input[46] ^ crc_input[43] ^ crc_input[42] ^
                          crc_input[41] ^ crc_input[36] ^ crc_input[35] ^ crc_input[33] ^
                          crc_input[32] ^ crc_input[26] ^ crc_input[21] ^ crc_input[18] ^
                          crc_input[15] ^ crc_input[13] ^ crc_input[ 4] ^ crc_input[ 1];
  assign res_crc32c[23] = crc_input[61] ^ crc_input[58] ^ crc_input[50] ^ crc_input[48] ^
                          crc_input[44] ^ crc_input[42] ^ crc_input[39] ^ crc_input[38] ^
                          crc_input[14] ^ crc_input[10];
  assign res_crc32c[24] = crc_input[62] ^ crc_input[57] ^ crc_input[54] ^ crc_input[52] ^
                          crc_input[51] ^ crc_input[49] ^ crc_input[46] ^ crc_input[45] ^
                          crc_input[37] ^ crc_input[36] ^ crc_input[33] ^ crc_input[32] ^
                          crc_input[30] ^ crc_input[28] ^ crc_input[27] ^ crc_input[15] ^
                          crc_input[10] ^ crc_input[ 2] ^ crc_input[ 0];
  assign res_crc32c[25] = crc_input[63] ^ crc_input[54] ^ crc_input[53] ^ crc_input[50] ^
                          crc_input[48] ^ crc_input[47] ^ crc_input[46] ^ crc_input[39] ^
                          crc_input[37] ^ crc_input[35] ^ crc_input[31] ^ crc_input[30] ^
                          crc_input[29] ^ crc_input[28] ^ crc_input[17] ^ crc_input[14] ^
                          crc_input[ 6];
  assign res_crc32c[26] = crc_input[54] ^ crc_input[52] ^ crc_input[51] ^ crc_input[49] ^
                          crc_input[46] ^ crc_input[41] ^ crc_input[40] ^ crc_input[37] ^
                          crc_input[33] ^ crc_input[32] ^ crc_input[31] ^ crc_input[30] ^
                          crc_input[28] ^ crc_input[27] ^ crc_input[16] ^ crc_input[15] ^
                          crc_input[11] ^ crc_input[ 7] ^ crc_input[ 5];
  assign res_crc32c[27] = crc_input[54] ^ crc_input[53] ^ crc_input[50] ^ crc_input[47] ^
                          crc_input[42] ^ crc_input[41] ^ crc_input[36] ^ crc_input[31] ^
                          crc_input[29] ^ crc_input[28] ^ crc_input[14] ^ crc_input[12] ^
                          crc_input[11] ^ crc_input[ 8];
  assign res_crc32c[28] = crc_input[52] ^ crc_input[51] ^ crc_input[43] ^ crc_input[42] ^
                          crc_input[39] ^ crc_input[37] ^ crc_input[35] ^ crc_input[34] ^
                          crc_input[33] ^ crc_input[29] ^ crc_input[17] ^ crc_input[15] ^
                          crc_input[14] ^ crc_input[13] ^ crc_input[12] ^ crc_input[ 6] ^
                          crc_input[ 1];
  assign res_crc32c[29] = crc_input[53] ^ crc_input[52] ^ crc_input[44] ^ crc_input[43] ^
                          crc_input[40] ^ crc_input[38] ^ crc_input[36] ^ crc_input[35] ^
                          crc_input[34] ^ crc_input[30] ^ crc_input[18] ^ crc_input[16] ^
                          crc_input[15] ^ crc_input[14] ^ crc_input[13] ^ crc_input[ 7] ^
                          crc_input[ 2];
  assign res_crc32c[30] = crc_input[58] ^ crc_input[55] ^ crc_input[53] ^ crc_input[45] ^
                          crc_input[44] ^ crc_input[41] ^ crc_input[37] ^ crc_input[34] ^
                          crc_input[32] ^ crc_input[31] ^ crc_input[27] ^ crc_input[20] ^
                          crc_input[15] ^ crc_input[11] ^ crc_input[ 9] ^ crc_input[ 8];
  assign res_crc32c[31] = crc_input[59] ^ crc_input[58] ^ crc_input[56] ^ crc_input[55] ^
                          crc_input[46] ^ crc_input[45] ^ crc_input[42] ^ crc_input[40] ^
                          crc_input[36] ^ crc_input[28] ^ crc_input[27] ^ crc_input[21] ^
                          crc_input[20] ^ crc_input[17] ^ crc_input[12] ^ crc_input[ 4] ^
                          crc_input[ 1];


  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  assign crc32_res_o = {8'h00, crc_input[87:64]} ^ res_common ^ (alu_ex2_simd_sign_arth_i ? res_crc32c : res_crc32);

  // ------------------------------------------------------
  // OVL definitions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_alu_pipe_lo_ex2_i")
  u_ovl_x_en_alu_pipe_lo_ex2_i (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (en_alu_pipe_lo_ex2_i));


`endif

endmodule // ca53dpu_alu_crc32

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
