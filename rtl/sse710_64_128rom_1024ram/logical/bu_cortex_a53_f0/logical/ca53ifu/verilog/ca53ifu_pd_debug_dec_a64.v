//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2011-11-22 09:41:16 +0000 (Tue, 22 Nov 2011) $
//
//      Revision            : $Revision: 192264 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : ARM predecoder. It translates, when possible, an ARM instruction
// into a T32 instruction. It sets the sideband signals for unpredictable,
// undefined and dual issue behaviour
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53ifu_pd_debug_dec_a64
  (input  [31:0] raw_encoding_i,
   output [28:0] arm_to_t32_o,
   output        sf_o,
   output        m_o,
   output        n_o,
   output        fifth_loc_o,
   output        d_o,
   output        undef_o

   );

  // -----------------------------
  // Wire declarations
  // -----------------------------
  reg [28:0]     a64_to_t32;
  reg            ccbit_sf;
  reg            ccbit_m;
  reg            ccbit_n;
  reg            ccbit_d;
  reg            fifth_loc;

  wire           undef;

  assign arm_to_t32_o  = a64_to_t32;
  assign undef_o       = undef;
  assign  sf_o         = ccbit_sf;
  assign  m_o          = ccbit_m;
  assign  n_o          = ccbit_n;
  assign  d_o          = ccbit_d;
  assign fifth_loc_o   = fifth_loc;

 // -----------------------------
  // Main code
  // -----------------------------

  // ------------------------------------------------------
  // Start automatically generated logic
  // ------------------------------------------------------
  always @*
    casez (raw_encoding_i[31:0])
 32'b?001111001100100000000?????????? : begin a64_to_t32 = {9'b011101001,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],7'b0010000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* FCVTAS_429  */
 32'b?0011110011??000000000?????????? : begin a64_to_t32 = {9'b011100101,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],raw_encoding_i[20:19],5'b10000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* FCVT{N|P|M|Z}S_425  */
 32'b?001111000100101000000?????????? : begin a64_to_t32 = {9'b011101011,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],7'b0010000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* FCVTAU_422  */
 32'b?001111001100101000000?????????? : begin a64_to_t32 = {9'b011101011,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],7'b0010000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* FCVTAU_430  */
 32'b0001111000100110000000?????????? : begin a64_to_t32 = {9'b011100001,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],7'b0010000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* FMOV_423  */
 32'b1001111001100110000000?????????? : begin a64_to_t32 = {9'b011100001,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],7'b0010000}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* FMOV_431  */
 32'b0001111000100111000000?????????? : begin a64_to_t32 = {9'b011100000,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],7'b0010000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; fifth_loc = 1'b0; end /* FMOV_424  */
 32'b1001111010101110000000?????????? : begin a64_to_t32 = {9'b011100001,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],7'b0110000}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* FMOV_433  */
 32'b?001111000100100000000?????????? : begin a64_to_t32 = {9'b011101001,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],7'b0010000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* FCVTAS_421  */
 32'b1001111010101111000000?????????? : begin a64_to_t32 = {9'b011100000,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],7'b0110000}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; fifth_loc = 1'b0; end /* FMOV_434  */
 32'b1001111001100111000000?????????? : begin a64_to_t32 = {9'b011100000,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],7'b0010000}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; fifth_loc = 1'b0; end /* FMOV_432  */
 32'b?0011110001??001000000?????????? : begin a64_to_t32 = {9'b011100111,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],raw_encoding_i[20:19],5'b10000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* FCVT{N|P|M|Z}U_418  */
 32'b?0011110001??000000000?????????? : begin a64_to_t32 = {9'b011100101,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],raw_encoding_i[20:19],5'b10000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* FCVT{N|P|M|Z}S_417  */
 32'b?0011110011??001000000?????????? : begin a64_to_t32 = {9'b011100111,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],raw_encoding_i[20:19],5'b10000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* FCVT{N|P|M|Z}U_426  */
 32'b00001000000?????0??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],8'b11110100,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* STXRB_123  */
 32'b00111000000????????????????????? : begin a64_to_t32 = {9'b110000000,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* ST{U}RB_158  */
 32'b10001000000?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],8'b11111110,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* STLXR_137  */
 32'b10111000000????????????????????? : begin a64_to_t32 = {9'b110000100,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* ST{U}R_160  */
 32'b11001000000?????0??????????????? : begin a64_to_t32 = {9'b010000100,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[19:16],8'b00000000}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* STXR (64-bit)_126  */
 32'b11001000100?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111110101111}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* STLR (64-bit)_150  */
 32'b0?001110000????1001011?????????? : begin a64_to_t32 = {7'b0111001,raw_encoding_i[19],1'b1,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1011,raw_encoding_i[8],raw_encoding_i[18],raw_encoding_i[17],5'b10000}; ccbit_sf = raw_encoding_i[30]; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* SMOV (byte)_458  */
 32'b10001000000?????0??????????????? : begin a64_to_t32 = {9'b010000100,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[19:16],8'b00000000}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* STXR_125  */
 32'b?101000101?????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b101010,raw_encoding_i[8:5],1'b0,raw_encoding_i[20:18],raw_encoding_i[3:0],raw_encoding_i[17:10]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* SUB (immediate)_12  */
 32'b01001110000??100001011?????????? : begin a64_to_t32 = {7'b0111000,raw_encoding_i[19],1'b1,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1011,raw_encoding_i[8],7'b0010000}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* SMOV (word)_460  */
 32'b11001000001?????0??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],4'b0111,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = raw_encoding_i[14]; end /* STXP (64-bit)_132  */
 32'b?001111001100010000000?????????? : begin a64_to_t32 = {9'b011100100,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],7'b0010000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; fifth_loc = 1'b0; end /* SCVTF_427  */
 32'b01001000000?????0??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],8'b11110101,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* STXRH_124  */
 32'b00001000100?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111110001111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* STLRB_147  */
 32'b1101010100001??????????????????? : begin a64_to_t32 = {5'b01110,raw_encoding_i[18:16],1'b0,raw_encoding_i[15:12],raw_encoding_i[3:0],4'b1101,raw_encoding_i[7:5],1'b1,raw_encoding_i[11:8]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* SYS_290  */
 32'b01111000000????????????????????? : begin a64_to_t32 = {9'b110000010,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* ST{U}RH_159  */
 32'b01001000000?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],8'b11111101,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* STLXRH_136  */
 32'b00001000000?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],8'b11111100,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* STLXRB_135  */
 32'b01001000100?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111110011111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* STLRH_148  */
 32'b11001000001?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],4'b1111,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = raw_encoding_i[14]; end /* STLXP (64-bit)_144  */
 32'b10001000001?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],4'b1111,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = raw_encoding_i[14]; end /* STLXP_143  */
 32'b10001000001?????0??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],4'b0111,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = raw_encoding_i[14]; end /* STXP_131  */
 32'b11001000000?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],8'b11111110,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* STLXR (64-bit)_138  */
 32'b10001000100?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111110101111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* STLR_149  */
 32'b?101000100?????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b101010,raw_encoding_i[8:5],1'b0,raw_encoding_i[20:18],raw_encoding_i[3:0],raw_encoding_i[17:10]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* SUB (immediate)_11  */
 32'b?001111000100010000000?????????? : begin a64_to_t32 = {9'b011100100,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],7'b0010000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; fifth_loc = 1'b0; end /* SCVTF_419  */
 32'b1101010100101??????????????????? : begin a64_to_t32 = {5'b01110,raw_encoding_i[18:16],1'b1,raw_encoding_i[15:12],raw_encoding_i[3:0],4'b1101,raw_encoding_i[7:5],1'b1,raw_encoding_i[11:8]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* SYSL_292  */
 32'b0?001110000???10001011?????????? : begin a64_to_t32 = {7'b0111000,raw_encoding_i[19],1'b1,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1011,raw_encoding_i[8],raw_encoding_i[18],6'b110000}; ccbit_sf = raw_encoding_i[30]; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* SMOV (hword)_459  */
 32'b11111000000????????????????????? : begin a64_to_t32 = {9'b110000110,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* ST{U}R (64-bit)_161  */
 32'b?10100101??????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[16],6'b100100,raw_encoding_i[20:17],1'b0,raw_encoding_i[15:13],raw_encoding_i[3:0],raw_encoding_i[12:5]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[22]; ccbit_n = raw_encoding_i[21]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* MOVZ_272  */
 32'b110101010001???????????????????? : begin a64_to_t32 = {5'b01110,raw_encoding_i[18:16],1'b0,raw_encoding_i[15:12],raw_encoding_i[3:0],3'b111,raw_encoding_i[19],raw_encoding_i[7:5],1'b1,raw_encoding_i[11:8]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* MSR (system register)_291  */
 32'b110101010011???????????????????? : begin a64_to_t32 = {5'b01110,raw_encoding_i[18:16],1'b1,raw_encoding_i[15:12],raw_encoding_i[3:0],3'b111,raw_encoding_i[19],raw_encoding_i[7:5],1'b1,raw_encoding_i[11:8]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* MRS_293  */
 32'b?00100101??????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[16],6'b100101,raw_encoding_i[20:17],1'b0,raw_encoding_i[15:13],raw_encoding_i[3:0],raw_encoding_i[12:5]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[22]; ccbit_n = raw_encoding_i[21]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* MOVN_271  */
 32'b?11100101??????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[16],6'b101100,raw_encoding_i[20:17],1'b0,raw_encoding_i[15:13],raw_encoding_i[3:0],raw_encoding_i[12:5]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[22]; ccbit_n = raw_encoding_i[21]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* MOVK_273  */
 32'b11010101000000110011????01011111 : begin a64_to_t32 = {25'b1001110111111100011110010,raw_encoding_i[11:8]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; fifth_loc = 1'b0; end /* CLREX_286  */
 32'b00001000010?????0??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111101001111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LDXRB_127  */
 32'b01111000110????????????????????? : begin a64_to_t32 = {9'b110010011,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LD{U}RSH (32-bit)_171  */
 32'b10001000011?????0??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],8'b01111111}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[14]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LDXP_133  */
 32'b00111000010????????????????????? : begin a64_to_t32 = {9'b110000001,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LD{U}RB_162  */
 32'b01001000110?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111110011111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LDARH_152  */
 32'b11001000011?????0??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],8'b01111111}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[14]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LDXP (64-bit)_134  */
 32'b01111000010????????????????????? : begin a64_to_t32 = {9'b110000011,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LD{U}RH_163  */
 32'b11001000010?????0??????????????? : begin a64_to_t32 = {9'b010000101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111100000000}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LDXR (64-bit)_130  */
 32'b10001000010?????0??????????????? : begin a64_to_t32 = {9'b010000101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111100000000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LDXR_129  */
 32'b10111000100????????????????????? : begin a64_to_t32 = {9'b110010101,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LD{U}RSW_168  */
 32'b00111000100????????????????????? : begin a64_to_t32 = {9'b110010001,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LD{U}RSB_166  */
 32'b10001000110?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111110101111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LDAR_153  */
 32'b00001000110?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111110001111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LDARB_151  */
 32'b01111000100????????????????????? : begin a64_to_t32 = {9'b110010011,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LD{U}RSH_167  */
 32'b10111000010????????????????????? : begin a64_to_t32 = {9'b110000101,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LD{U}R_164  */
 32'b00111000110????????????????????? : begin a64_to_t32 = {9'b110010001,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LD{U}RSB (32-bit)_170  */
 32'b11001000010?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111111101111}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LDAXR (64-bit)_142  */
 32'b10001000011?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],8'b11111111}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[14]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LDAXP_145  */
 32'b01001000010?????0??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111101011111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LDXRH_128  */
 32'b11001000110?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111110101111}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LDAR (64-bit)_154  */
 32'b10001000010?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111111101111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LDAXR_141  */
 32'b01001000010?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111111011111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LDAXRH_140  */
 32'b11111000010????????????????????? : begin a64_to_t32 = {9'b110000111,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LD{U}R (64-bit)_165  */
 32'b00001000010?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111111001111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LDAXRB_139  */
 32'b11001000011?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],8'b11111111}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[14]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* LDAXP (64-bit)_146  */
 32'b?001000101?????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b100000,raw_encoding_i[8:5],1'b0,raw_encoding_i[20:18],raw_encoding_i[3:0],raw_encoding_i[17:10]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* ADD (immediate)_10  */
 32'b?001000100?????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b100000,raw_encoding_i[8:5],1'b0,raw_encoding_i[20:18],raw_encoding_i[3:0],raw_encoding_i[17:10]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* ADD (immediate)_9  */
 32'b11111000100?????????00?????????? : begin a64_to_t32 = {9'b110010111,raw_encoding_i[8:5],raw_encoding_i[3:0],4'b1010,raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* PRFUM_169  */
 32'b11010101000000110010???????11111 : begin a64_to_t32 = {22'b1001110101111100000000,raw_encoding_i[11:8],raw_encoding_i[7:5]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; fifth_loc = 1'b0; end /* HINT_285  */
 32'b11010100101????????????????00001 : begin a64_to_t32 = {29'b10111100011111000000000000001}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; fifth_loc = 1'b0; end /* DCPS1_102  */
 32'b0?001110000?1000000011?????????? : begin a64_to_t32 = {7'b0111011,raw_encoding_i[30],1'b0,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1011,raw_encoding_i[3],7'b0110000}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; fifth_loc = 1'b0; end /* DUP (dword from ARM)_453  */
 32'b0?001110000???10000011?????????? : begin a64_to_t32 = {7'b0111010,raw_encoding_i[30],1'b0,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1011,raw_encoding_i[3],7'b0110000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; fifth_loc = 1'b0; end /* DUP (hword from ARM)_451  */
 32'b11010100101????????????????00011 : begin a64_to_t32 = {29'b10111100011111000000000000011}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; fifth_loc = 1'b0; end /* DCPS3_104  */
 32'b11010101000000110011????10111111 : begin a64_to_t32 = {25'b1001110111111100011110101,raw_encoding_i[11:8]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; fifth_loc = 1'b0; end /* DMB_288  */
 32'b0?001110000????1000011?????????? : begin a64_to_t32 = {7'b0111011,raw_encoding_i[30],1'b0,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1011,raw_encoding_i[3],7'b0010000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; fifth_loc = 1'b0; end /* DUP (byte from ARM)_450  */
 32'b0?001110000??100000011?????????? : begin a64_to_t32 = {7'b0111010,raw_encoding_i[30],1'b0,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1011,raw_encoding_i[3],7'b0010000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; fifth_loc = 1'b0; end /* DUP (word from ARM)_452  */
 32'b11010100101????????????????00010 : begin a64_to_t32 = {29'b10111100011111000000000000010}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; fifth_loc = 1'b0; end /* DCPS2_103  */
 32'b11010110101111110000001111100000 : begin a64_to_t32 = {29'b10011110111111000111100000000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; fifth_loc = 1'b0; end /* DRPS_310  */
 32'b11010101000000110011????10011111 : begin a64_to_t32 = {25'b1001110111111100011110100,raw_encoding_i[11:8]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; fifth_loc = 1'b0; end /* DSB_287  */
 32'b0?001110000?????000001?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[19:16],raw_encoding_i[2:0],raw_encoding_i[4],5'b11000,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[20]; ccbit_d = 1'b0; fifth_loc = 1'b0; end /* DUP_449  */
 32'b01001110000???10000111?????????? : begin a64_to_t32 = {7'b0111000,raw_encoding_i[19],1'b0,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1011,raw_encoding_i[3],raw_encoding_i[18],6'b110000}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; fifth_loc = 1'b0; end /* INS (hword from ARM)_455  */
 32'b01001110000??100000111?????????? : begin a64_to_t32 = {7'b0111000,raw_encoding_i[19],1'b0,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1011,raw_encoding_i[3],7'b0010000}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; fifth_loc = 1'b0; end /* INS (word from ARM)_456  */
 32'b01001110000????1000111?????????? : begin a64_to_t32 = {7'b0111001,raw_encoding_i[19],1'b0,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1011,raw_encoding_i[3],raw_encoding_i[18],raw_encoding_i[17],5'b10000}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; fifth_loc = 1'b0; end /* INS (byte from ARM)_454  */
 32'b01101110000?????0????1?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[13],2'b11,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[19:16],3'b111,raw_encoding_i[12],raw_encoding_i[3],raw_encoding_i[11],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[14]; ccbit_d = 1'b0; fifth_loc = 1'b0; end /* INS (from vector)_465  */
 32'b11010101000000110011????11011111 : begin a64_to_t32 = {25'b1001110111111100011110110,raw_encoding_i[11:8]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; fifth_loc = 1'b0; end /* ISB_289  */
 32'b01001110000?1000000111?????????? : begin a64_to_t32 = {9'b011100010,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1011,raw_encoding_i[3],7'b1010000}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; fifth_loc = 1'b0; end /* INS (dword from ARM)_457  */
 32'b00001110000??100001111?????????? : begin a64_to_t32 = {7'b0111010,raw_encoding_i[19],1'b1,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1011,raw_encoding_i[8],7'b0010000}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* UMOV (word)_463  */
 32'b01001110000?1000001111?????????? : begin a64_to_t32 = {9'b011101011,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1011,raw_encoding_i[8],7'b1010000}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* UMOV (dword)_464  */
 32'b00001110000???10001111?????????? : begin a64_to_t32 = {7'b0111010,raw_encoding_i[19],1'b1,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1011,raw_encoding_i[8],raw_encoding_i[18],6'b110000}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* UMOV (hword)_462  */
 32'b?001111001100011000000?????????? : begin a64_to_t32 = {9'b011100110,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],7'b0010000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; fifth_loc = 1'b0; end /* UCVTF_428  */
 32'b00001110000????1001111?????????? : begin a64_to_t32 = {7'b0111011,raw_encoding_i[19],1'b1,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1011,raw_encoding_i[8],raw_encoding_i[18],raw_encoding_i[17],5'b10000}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; fifth_loc = 1'b0; end /* UMOV (byte)_461  */
 32'b?001111000100011000000?????????? : begin a64_to_t32 = {9'b011100110,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],7'b0010000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; fifth_loc = 1'b0; end /* UCVTF_420  */
      default : begin a64_to_t32 = {29{1'b0}}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; fifth_loc = 1'b0; end
    endcase

  wire   net_0_1, net_0_2, net_0_3, net_0_4, net_0_5, net_0_6, net_0_7, net_0_8, net_0_9, net_0_10,
         net_0_11, net_0_12, net_0_13, net_0_14, net_0_15, net_0_16, net_0_17, net_0_18,
         net_0_19, net_0_20, net_0_21, net_0_22, net_0_23, net_0_24, net_0_25, net_0_26,
         net_0_27, net_0_28, net_0_29, net_0_30, net_0_31, net_0_32, net_0_33, net_0_34,
         net_0_35, net_0_36, net_0_37, net_0_38, net_0_39, net_0_40, net_0_41, net_0_42,
         net_0_43, net_0_44, net_0_45, net_0_46, net_0_47, net_0_48, net_0_49, net_0_50,
         net_0_51, net_0_52, net_0_53, net_0_54, net_0_55, net_0_56, net_0_57, net_0_58,
         net_0_59, net_0_60, net_0_61, net_0_62, net_0_63, net_0_64, net_0_65, net_0_66,
         net_0_67, net_0_68, net_0_69, net_0_70, net_0_71, net_0_72, net_0_73, net_0_74,
         net_0_75, net_0_76, net_0_77, net_0_78, net_0_79, net_0_80, net_0_81, net_0_82,
         net_0_83, net_0_84, net_0_85, net_0_86, net_0_87, net_0_88, net_0_89, net_0_90,
         net_0_91, net_0_92, net_0_93, net_0_94, net_0_95, net_0_96, net_0_97, net_0_98,
         net_0_99, net_0_100, net_0_101, net_0_102, net_0_103, net_0_104, net_0_105, net_0_106,
         net_0_107, net_0_108, net_0_109, net_0_110, net_0_111, net_0_112, net_0_113,
         net_0_114, net_0_115, net_0_116, net_0_117, net_0_118, net_0_119, net_0_120,
         net_0_121, net_0_122, net_0_123, net_0_124, net_0_125, net_0_126, net_0_127,
         net_0_128, net_0_129, net_0_130, net_0_131, net_0_132, net_0_133, net_0_134,
         net_0_135, net_0_136, net_0_137, net_0_138, net_0_139, net_0_140, net_0_141,
         net_0_142, net_0_143, net_0_144, net_0_145, net_0_146, net_0_147, net_0_148,
         net_0_149, net_0_150, net_0_151, net_0_152, net_0_153, net_0_154, net_0_155,
         net_0_156, net_0_157, net_0_158, net_0_159, net_0_160, net_0_161, net_0_162,
         net_0_163, net_0_164, net_0_165, net_0_166, net_0_167, net_0_168, net_0_169,
         net_0_170, net_0_171, net_0_172, net_0_173, net_0_174, net_0_175, net_0_176,
         net_0_177, net_0_178, net_0_179, net_0_180, net_0_181, net_0_182, net_0_183,
         net_0_184, net_0_185, net_0_186, net_0_187, net_0_188, net_0_189, net_0_190,
         net_0_191, net_0_192;

  assign net_0_1 = ~raw_encoding_i[31];
  assign net_0_2 = ~raw_encoding_i[29];
  assign net_0_3 = ~raw_encoding_i[25];
  assign net_0_4 = ~raw_encoding_i[23];
  assign net_0_5 = ~raw_encoding_i[22];
  assign net_0_6 = ~raw_encoding_i[21];
  assign net_0_7 = ~raw_encoding_i[13];
  assign net_0_8 = ~raw_encoding_i[10];
  assign net_0_9 = ~raw_encoding_i[4];
  assign undef = ~(net_0_10 & net_0_11);
  assign net_0_11 = ~(raw_encoding_i[27] & net_0_12);
  assign net_0_12 = (net_0_13 | raw_encoding_i[24]);
  assign net_0_13 = ~(net_0_14 & net_0_15);
  assign net_0_15 = (net_0_16 & net_0_17);
  assign net_0_17 = ~(net_0_18 & net_0_19);
  assign net_0_19 = ~(net_0_4 | net_0_1);
  assign net_0_18 = ~(net_0_20 & net_0_21);
  assign net_0_21 = ~(raw_encoding_i[22] & raw_encoding_i[28]);
  assign net_0_20 = (net_0_22 | net_0_23);
  assign net_0_22 = ~(raw_encoding_i[29] & raw_encoding_i[30]);
  assign net_0_16 = (net_0_24 & net_0_25);
  assign net_0_25 = ~(raw_encoding_i[25] & net_0_26);
  assign net_0_26 = ~(net_0_27 & net_0_28);
  assign net_0_28 = ~(net_0_8 & net_0_6);
  assign net_0_27 = (net_0_29 & net_0_30);
  assign net_0_30 = ~(net_0_31 & net_0_32);
  assign net_0_32 = (raw_encoding_i[21] & raw_encoding_i[20]);
  assign net_0_29 = (raw_encoding_i[26] & net_0_33);
  assign net_0_33 = (net_0_34 | raw_encoding_i[29]);
  assign net_0_34 = (net_0_35 | net_0_36);
  assign net_0_35 = (net_0_7 | raw_encoding_i[12]);
  assign net_0_24 = ~(net_0_37 & net_0_38);
  assign net_0_38 = ~(net_0_5 | net_0_6);
  assign net_0_37 = (net_0_39 & net_0_40);
  assign net_0_40 = ~(net_0_41 & net_0_42);
  assign net_0_42 = ~(net_0_43 & net_0_44);
  assign net_0_41 = ~(net_0_45 & net_0_46);
  assign net_0_46 = (net_0_7 ^ raw_encoding_i[3]);
  assign net_0_45 = (net_0_47 & net_0_48);
  assign net_0_48 = ~(net_0_9 & net_0_7);
  assign net_0_47 = (net_0_9 ^ raw_encoding_i[14]);
  assign net_0_39 = (net_0_43 | net_0_49);
  assign net_0_43 = (net_0_50 & net_0_51);
  assign net_0_51 = ~(net_0_52 & net_0_53);
  assign net_0_53 = ~(raw_encoding_i[2] & net_0_54);
  assign net_0_52 = ~(net_0_55 & net_0_56);
  assign net_0_56 = (net_0_8 ^ raw_encoding_i[0]);
  assign net_0_55 = (net_0_57 & net_0_58);
  assign net_0_58 = ~(raw_encoding_i[11] ^ raw_encoding_i[1]);
  assign net_0_57 = (raw_encoding_i[10] | raw_encoding_i[11]);
  assign net_0_50 = ~(raw_encoding_i[12] ^ raw_encoding_i[2]);
  assign net_0_14 = (raw_encoding_i[29] | net_0_59);
  assign net_0_59 = (net_0_60 & net_0_61);
  assign net_0_61 = ~(raw_encoding_i[28] & net_0_3);
  assign net_0_60 = ~(raw_encoding_i[12] & net_0_62);
  assign net_0_62 = (net_0_63 & net_0_64);
  assign net_0_64 = ~(net_0_3 | net_0_7);
  assign net_0_63 = (raw_encoding_i[30] & net_0_36);
  assign net_0_10 = (net_0_65 & net_0_66);
  assign net_0_66 = (net_0_67 | raw_encoding_i[28]);
  assign net_0_67 = (net_0_68 & net_0_69);
  assign net_0_69 = ~(raw_encoding_i[21] & net_0_70);
  assign net_0_70 = ~(net_0_71 & net_0_72);
  assign net_0_72 = ~(net_0_73 & raw_encoding_i[22]);
  assign net_0_73 = (net_0_44 & net_0_49);
  assign net_0_49 = (net_0_54 & net_0_74);
  assign net_0_74 = ~(raw_encoding_i[12] | raw_encoding_i[2]);
  assign net_0_54 = (net_0_23 & net_0_75);
  assign net_0_23 = ~(raw_encoding_i[10] | raw_encoding_i[11]);
  assign net_0_44 = ~(raw_encoding_i[13] | net_0_76);
  assign net_0_76 = (raw_encoding_i[14] | net_0_77);
  assign net_0_68 = (net_0_78 & net_0_79);
  assign net_0_79 = (net_0_80 | raw_encoding_i[19]);
  assign net_0_80 = (net_0_36 | net_0_3);
  assign net_0_36 = (raw_encoding_i[16] | net_0_31);
  assign net_0_31 = (raw_encoding_i[17] | raw_encoding_i[18]);
  assign net_0_78 = (net_0_81 & net_0_82);
  assign net_0_82 = (raw_encoding_i[15] | net_0_4);
  assign net_0_81 = (raw_encoding_i[27] & net_0_83);
  assign net_0_83 = ~(raw_encoding_i[29] & net_0_3);
  assign net_0_65 = (net_0_84 & net_0_85);
  assign net_0_85 = ~(raw_encoding_i[25] & net_0_86);
  assign net_0_86 = ~(net_0_87 & net_0_88);
  assign net_0_88 = (net_0_2 | raw_encoding_i[30]);
  assign net_0_87 = (net_0_89 & net_0_90);
  assign net_0_90 = (raw_encoding_i[31] | net_0_91);
  assign net_0_91 = ~(raw_encoding_i[22] & net_0_92);
  assign net_0_92 = (net_0_93 | raw_encoding_i[23]);
  assign net_0_89 = (raw_encoding_i[23] | net_0_94);
  assign net_0_94 = (raw_encoding_i[27] & net_0_95);
  assign net_0_95 = ~(net_0_96 & raw_encoding_i[21]);
  assign net_0_84 = (net_0_97 & net_0_98);
  assign net_0_98 = ~(raw_encoding_i[26] & net_0_99);
  assign net_0_99 = ~(net_0_100 & net_0_101);
  assign net_0_101 = (net_0_102 & net_0_103);
  assign net_0_103 = ~(net_0_104 & net_0_105);
  assign net_0_105 = ~(raw_encoding_i[27] & net_0_106);
  assign net_0_106 = (net_0_107 | raw_encoding_i[30]);
  assign net_0_107 = ~(net_0_108 & net_0_109);
  assign net_0_109 = ~(net_0_110 & net_0_111);
  assign net_0_111 = (net_0_8 | raw_encoding_i[18]);
  assign net_0_110 = ~(raw_encoding_i[12] ^ raw_encoding_i[13]);
  assign net_0_108 = ~(net_0_112 & net_0_113);
  assign net_0_113 = ~(raw_encoding_i[12] & net_0_7);
  assign net_0_112 = (raw_encoding_i[16] | raw_encoding_i[17]);
  assign net_0_104 = ~(raw_encoding_i[30] & net_0_114);
  assign net_0_114 = ~(raw_encoding_i[23] & net_0_115);
  assign net_0_115 = (net_0_116 | raw_encoding_i[2]);
  assign net_0_116 = (net_0_77 | net_0_117);
  assign net_0_117 = (net_0_75 & net_0_118);
  assign net_0_118 = ~(raw_encoding_i[7] & raw_encoding_i[6]);
  assign net_0_77 = (raw_encoding_i[4] | raw_encoding_i[3]);
  assign net_0_102 = (net_0_119 & net_0_120);
  assign net_0_120 = ~(net_0_121 & net_0_122);
  assign net_0_122 = ~(raw_encoding_i[19] | raw_encoding_i[20]);
  assign net_0_121 = ~(net_0_123 & net_0_124);
  assign net_0_124 = ~(raw_encoding_i[24] & net_0_125);
  assign net_0_125 = ~(net_0_126 & net_0_127);
  assign net_0_127 = (net_0_128 & net_0_129);
  assign net_0_129 = (raw_encoding_i[0] & raw_encoding_i[1]);
  assign net_0_128 = (raw_encoding_i[2] & raw_encoding_i[13]);
  assign net_0_126 = (net_0_130 & net_0_131);
  assign net_0_131 = (raw_encoding_i[3] & raw_encoding_i[16]);
  assign net_0_130 = (net_0_132 & raw_encoding_i[17]);
  assign net_0_132 = (net_0_133 & net_0_134);
  assign net_0_134 = ~(raw_encoding_i[12] & net_0_135);
  assign net_0_135 = ~(net_0_136 & net_0_137);
  assign net_0_137 = ~(raw_encoding_i[6] & raw_encoding_i[5]);
  assign net_0_136 = (raw_encoding_i[7] | raw_encoding_i[6]);
  assign net_0_133 = ~(net_0_9 | raw_encoding_i[14]);
  assign net_0_123 = (net_0_138 & net_0_139);
  assign net_0_139 = (net_0_140 | raw_encoding_i[22]);
  assign net_0_140 = ~(net_0_71 & net_0_93);
  assign net_0_93 = (raw_encoding_i[17] & raw_encoding_i[18]);
  assign net_0_71 = ~(net_0_1 | raw_encoding_i[23]);
  assign net_0_138 = (net_0_141 & net_0_142);
  assign net_0_142 = (net_0_143 | net_0_7);
  assign net_0_141 = ~(raw_encoding_i[15] & net_0_6);
  assign net_0_119 = (net_0_144 & net_0_145);
  assign net_0_145 = (net_0_146 & net_0_147);
  assign net_0_147 = (net_0_148 & net_0_149);
  assign net_0_149 = ~(net_0_150 & raw_encoding_i[30]);
  assign net_0_150 = ~(net_0_143 | raw_encoding_i[24]);
  assign net_0_143 = (net_0_6 | raw_encoding_i[23]);
  assign net_0_148 = (net_0_2 | raw_encoding_i[10]);
  assign net_0_146 = (net_0_151 & net_0_152);
  assign net_0_152 = (raw_encoding_i[10] | net_0_153);
  assign net_0_153 = ~(net_0_1 & net_0_96);
  assign net_0_96 = (raw_encoding_i[17] & raw_encoding_i[19]);
  assign net_0_151 = (raw_encoding_i[25] | net_0_154);
  assign net_0_154 = ~(raw_encoding_i[23] & net_0_75);
  assign net_0_144 = (net_0_155 & net_0_156);
  assign net_0_156 = (net_0_157 & net_0_158);
  assign net_0_158 = ~(net_0_1 & net_0_3);
  assign net_0_157 = (net_0_5 | net_0_8);
  assign net_0_155 = (net_0_159 & net_0_160);
  assign net_0_160 = ~(raw_encoding_i[28] & net_0_161);
  assign net_0_161 = ~(raw_encoding_i[21] | raw_encoding_i[24]);
  assign net_0_159 = (net_0_162 & net_0_163);
  assign net_0_163 = (net_0_1 | raw_encoding_i[28]);
  assign net_0_162 = (net_0_5 | raw_encoding_i[27]);
  assign net_0_100 = ~(raw_encoding_i[25] & net_0_164);
  assign net_0_164 = ~(net_0_165 & net_0_166);
  assign net_0_166 = (net_0_167 | raw_encoding_i[10]);
  assign net_0_167 = (net_0_168 & net_0_169);
  assign net_0_169 = (net_0_170 | raw_encoding_i[17]);
  assign net_0_168 = ~(raw_encoding_i[11] | net_0_171);
  assign net_0_171 = (raw_encoding_i[30] & net_0_172);
  assign net_0_172 = ~(raw_encoding_i[20] & raw_encoding_i[16]);
  assign net_0_165 = (net_0_173 & net_0_174);
  assign net_0_174 = (net_0_8 | net_0_6);
  assign net_0_173 = (net_0_175 & net_0_176);
  assign net_0_176 = (net_0_177 & net_0_178);
  assign net_0_178 = (net_0_179 | raw_encoding_i[27]);
  assign net_0_179 = (net_0_180 & net_0_181);
  assign net_0_181 = (raw_encoding_i[8] & raw_encoding_i[5]);
  assign net_0_180 = (raw_encoding_i[9] & net_0_75);
  assign net_0_75 = ~(raw_encoding_i[1] | raw_encoding_i[0]);
  assign net_0_177 = (net_0_182 | raw_encoding_i[29]);
  assign net_0_182 = ~(raw_encoding_i[14] | net_0_183);
  assign net_0_183 = ~(raw_encoding_i[11] | net_0_184);
  assign net_0_184 = ~(raw_encoding_i[12] | raw_encoding_i[13]);
  assign net_0_175 = ~(raw_encoding_i[15] | net_0_185);
  assign net_0_185 = (raw_encoding_i[23] & net_0_170);
  assign net_0_170 = ~(raw_encoding_i[18] & raw_encoding_i[19]);
  assign net_0_97 = (net_0_186 & net_0_187);
  assign net_0_187 = (raw_encoding_i[25] | net_0_188);
  assign net_0_188 = (net_0_189 & net_0_190);
  assign net_0_190 = (net_0_191 | raw_encoding_i[26]);
  assign net_0_191 = (raw_encoding_i[27] | raw_encoding_i[24]);
  assign net_0_189 = (net_0_2 | net_0_6);
  assign net_0_186 = ~(raw_encoding_i[24] & net_0_192);
  assign net_0_192 = ~(net_0_4 & net_0_2);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
