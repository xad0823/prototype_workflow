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
`include "ca53ifu_defs.v"

module ca53ifu_pd_a64
  (input [31:0]  raw_encoding_i,
   output [28:0] a64_to_t32_o,
   output        arm_only_o,
   output [5:0]  sideband_o,
   output        sf_o,
   output        m_o,
   output        n_o,
   output        d_o
   );

  // -----------------------------
  // Wire declarations
  // -----------------------------
  reg [28:0]     a64_to_t32;
  reg            ccbit_sf;
  reg            ccbit_m;
  reg            ccbit_n;
  reg            ccbit_d;

  wire [5:0]     defined_sideband;
  wire           a64_only;
  wire           undef;
  wire           drps_undef;

  assign a64_to_t32_o  = a64_to_t32;
  assign sideband_o    = undef | drps_undef ? `ca53ifu_pd_undef : defined_sideband;
  assign arm_only_o    = a64_only;
  assign  sf_o         = ccbit_sf;
  assign  m_o          = ccbit_m;
  assign  n_o          = ccbit_n;
  assign  d_o          = ccbit_d;

  //DRPS Undefine (0xd6bf03e0) : Defined sideband will come out as valid but this
  //instruction is undefined in A64.
  assign drps_undef = (raw_encoding_i == 32'hd6bf03e0);

 // -----------------------------
  // Main code
  // -----------------------------

  // ------------------------------------------------------
  // Start automatically generated logic
  // ------------------------------------------------------
  always @*
    casez (raw_encoding_i[31:0])
 32'b?001111001100100000000?????????? : begin a64_to_t32 = {9'b011101001,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],7'b0010000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* FCVTAS_429  */
 32'b010111100?100001101110?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],6'b111111,raw_encoding_i[2:0],raw_encoding_i[4],3'b101,raw_encoding_i[22],2'b11,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTMS_649  */
 32'b?0011110011??000000000?????????? : begin a64_to_t32 = {9'b011100101,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],raw_encoding_i[20:19],5'b10000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* FCVT{N|P|M|Z}S_425  */
 32'b0001111001100101010000?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],6'b111011,raw_encoding_i[2:0],raw_encoding_i[4],6'b101101,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTM_336  */
 32'b?001111000100101000000?????????? : begin a64_to_t32 = {9'b011101011,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],7'b0010000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* FCVTAU_422  */
 32'b0001111000100100110000?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],6'b111010,raw_encoding_i[2:0],raw_encoding_i[4],6'b101001,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTP_322  */
 32'b0??01110??1?????110101?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1101,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FADD/FADDP/FSUB/FABD_496  */
 32'b?001111001011000???????????????? : begin a64_to_t32 = {9'b011101101,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],raw_encoding_i[15],raw_encoding_i[10],1'b1,raw_encoding_i[14:11]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* FCVTZS_410  */
 32'b00011110011?????100010?????????? : begin a64_to_t32 = {6'b011100,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FNMUL_379  */
 32'b0111111001100001011010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],6'b111010,raw_encoding_i[2:0],raw_encoding_i[4],6'b011001,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTXN_644  */
 32'b011111100?100001101010?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],6'b111101,raw_encoding_i[2:0],raw_encoding_i[4],3'b101,raw_encoding_i[22],2'b01,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTNU_646  */
 32'b0??01110??1?????111101?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1111,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* F{MIN|MAX}{P}_501  */
 32'b00011110001?????001110?????????? : begin a64_to_t32 = {6'b011100,raw_encoding_i[3],2'b11,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1010,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FSUB_365  */
 32'b0001111001100111110000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110110,raw_encoding_i[2:0],raw_encoding_i[4],6'b101101,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTI_340  */
 32'b01?11110??1?????111111?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1111,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRECPS/FRSQRTS_522  */
 32'b01111110??1?????111011?????????? : begin a64_to_t32 = {6'b111110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1110,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FAC{GE|GT}_521  */
 32'b0101111111??????1001?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1001,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* FMUL_751  */
 32'b0?0011100?1?????110111?????????? : begin a64_to_t32 = {6'b111110,raw_encoding_i[3],1'b1,raw_encoding_i[22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1101,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMULX_497  */
 32'b0?10111110??????1001?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1110,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* FMULX_729  */
 32'b00011110011?????011010?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMAXNM_377  */
 32'b00011110001?????000010?????????? : begin a64_to_t32 = {6'b011100,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1010,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMUL_362  */
 32'b0?0011100?100001100110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b10,raw_encoding_i[2:0],raw_encoding_i[4],5'b01101,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTM_612  */
 32'b?001111001100101000000?????????? : begin a64_to_t32 = {9'b011101011,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],7'b0010000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* FCVTAU_430  */
 32'b0001111000100110000000?????????? : begin a64_to_t32 = {9'b011100001,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],7'b0010000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* FMOV_423  */
 32'b0?00111110??????0001?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0001,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* FMLA_711  */
 32'b0101111111??????0001?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0001,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* FMLA_743  */
 32'b0?001110??1?????111111?????????? : begin a64_to_t32 = {6'b011110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1111,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRECPS/FRSQRTS_502  */
 32'b0001111000100000010000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110000,raw_encoding_i[2:0],raw_encoding_i[4],6'b101001,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMOV_315  */
 32'b00011110011?????001000?????00000 : begin a64_to_t32 = {6'b011101,raw_encoding_i[8],6'b110100,raw_encoding_i[7:5],raw_encoding_i[9],6'b101101,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCMP_350  */
 32'b010111101?100001101110?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b111101,raw_encoding_i[2:0],raw_encoding_i[4],3'b101,raw_encoding_i[22],2'b11,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTZS_651  */
 32'b00011110011?????001000?????11000 : begin a64_to_t32 = {6'b011101,raw_encoding_i[8],6'b110101,raw_encoding_i[7:5],raw_encoding_i[9],12'b101111000000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCMPE (with zero)_353  */
 32'b011111100?1?????110111?????????? : begin a64_to_t32 = {6'b111110,raw_encoding_i[3],1'b0,raw_encoding_i[22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1101,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMUL_519  */
 32'b1001111001100110000000?????????? : begin a64_to_t32 = {9'b011100001,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],7'b0010000}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* FMOV_431  */
 32'b0001111001100000110000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110000,raw_encoding_i[2:0],raw_encoding_i[4],6'b101111,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FABS_329  */
 32'b00011110011?????????11?????????? : begin a64_to_t32 = {6'b111100,raw_encoding_i[3],raw_encoding_i[15:14],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[13]; ccbit_n = raw_encoding_i[12]; ccbit_d = 1'b0; end /* FCSEL_391  */
 32'b0001111000100110010000?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],6'b111000,raw_encoding_i[2:0],raw_encoding_i[4],6'b101001,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTA_325  */
 32'b0?00111111??????0101?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0101,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* FMLS_720  */
 32'b0001111000100000110000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110000,raw_encoding_i[2:0],raw_encoding_i[4],6'b101011,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FABS_316  */
 32'b0001111001100010010000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110111,raw_encoding_i[2:0],raw_encoding_i[4],6'b101111,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVT (DP > SP)_332  */
 32'b0001111000100111110000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110110,raw_encoding_i[2:0],raw_encoding_i[4],6'b101001,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTI_327  */
 32'b010111101?100001110110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b11,raw_encoding_i[2:0],raw_encoding_i[4],6'b010100,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRECPE_657  */
 32'b00011110001?????001010?????????? : begin a64_to_t32 = {6'b011100,raw_encoding_i[3],2'b11,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1010,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FADD_364  */
 32'b00011110001?????001000?????10000 : begin a64_to_t32 = {6'b011101,raw_encoding_i[8],6'b110100,raw_encoding_i[7:5],raw_encoding_i[9],6'b101011,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCMPE_348  */
 32'b0?0011101?100000111110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],5'b01110,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FABS_601  */
 32'b0?1011100?1?????110111?????????? : begin a64_to_t32 = {6'b111110,raw_encoding_i[3],1'b0,raw_encoding_i[22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1101,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMUL_498  */
 32'b00011110011?????001110?????????? : begin a64_to_t32 = {6'b011100,raw_encoding_i[3],2'b11,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FSUB_374  */
 32'b0101111110??????0001?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0001,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* FMLA_742  */
 32'b010111101?100001111110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b11,raw_encoding_i[2:0],raw_encoding_i[4],6'b011100,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRECPX_659  */
 32'b01?11110??1?????111001?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1110,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCM{EQ|GE|GT}_520  */
 32'b0?00111111??????0001?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0001,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* FMLA_712  */
 32'b01?1111101??????111111?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],raw_encoding_i[21:16],raw_encoding_i[2:0],raw_encoding_i[4],6'b111110,raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTZ{S|U}_688  */
 32'b01?11111001?????111111?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],1'b1,raw_encoding_i[20:16],raw_encoding_i[2:0],raw_encoding_i[4],6'b111100,raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTZ{S|U}_687  */
 32'b0111111110??????1001?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1110,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* FMULX_752  */
 32'b0111111111??????1001?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1110,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* FMULX_753  */
 32'b011111100?100001101110?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],6'b111111,raw_encoding_i[2:0],raw_encoding_i[4],3'b101,raw_encoding_i[22],2'b01,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTMU_650  */
 32'b00011110011?????001000?????10000 : begin a64_to_t32 = {6'b011101,raw_encoding_i[8],6'b110100,raw_encoding_i[7:5],raw_encoding_i[9],6'b101111,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCMPE_352  */
 32'b00011110001?????????01?????0???? : begin a64_to_t32 = {7'b1111000,raw_encoding_i[15:14],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[13]; ccbit_n = raw_encoding_i[12]; ccbit_d = 1'b0; end /* FCCMP_383  */
 32'b0?10111111??????1001?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1110,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* FMULX_730  */
 32'b00011111010?????1??????????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[12:10],raw_encoding_i[14],raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[13]; end /* FMSUB_400  */
 32'b0001111000100010110000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110111,raw_encoding_i[2:0],raw_encoding_i[4],6'b101011,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVT (SP > DP)_319  */
 32'b0?101110??1?????111011?????????? : begin a64_to_t32 = {6'b111110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1110,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FAC{GE|GT}_500  */
 32'b0?0011101?100001100010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b10,raw_encoding_i[2:0],raw_encoding_i[4],5'b01111,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTP_613  */
 32'b00011110011?????????01?????0???? : begin a64_to_t32 = {7'b1111000,raw_encoding_i[15:14],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1011,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[13]; ccbit_n = raw_encoding_i[12]; ccbit_d = 1'b0; end /* FCCMP_385  */
 32'b00011111001?????1??????????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[12:10],raw_encoding_i[14],raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[13]; end /* FNMSUB_398  */
 32'b00011110011?????000110?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FDIV_372  */
 32'b010111101?100001101010?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],6'b111110,raw_encoding_i[2:0],raw_encoding_i[4],3'b101,raw_encoding_i[22],2'b11,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTPS_647  */
 32'b00011110001?????010110?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1010,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMIN_367  */
 32'b0001111001100001010000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110001,raw_encoding_i[2:0],raw_encoding_i[4],6'b101101,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FNEG_330  */
 32'b011111101?100001110110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b11,raw_encoding_i[2:0],raw_encoding_i[4],6'b010110,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRSQRTE_658  */
 32'b00011110001?????100010?????????? : begin a64_to_t32 = {6'b011100,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1010,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FNMUL_370  */
 32'b0101111111??????0101?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0101,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* FMLS_747  */
 32'b0??011101?100001101110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b11,raw_encoding_i[2:0],raw_encoding_i[4],4'b0111,raw_encoding_i[29],raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTZ[SU]_621  */
 32'b011111101?1?????110101?????????? : begin a64_to_t32 = {6'b111110,raw_encoding_i[3],1'b1,raw_encoding_i[22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1101,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FABD_517  */
 32'b00011110011?????????01?????1???? : begin a64_to_t32 = {7'b1111000,raw_encoding_i[15:14],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1011,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[13]; ccbit_n = raw_encoding_i[12]; ccbit_d = 1'b0; end /* FCCMPE_386  */
 32'b0??0111101??????111111?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],raw_encoding_i[21:16],raw_encoding_i[2:0],raw_encoding_i[4],5'b11111,raw_encoding_i[30],raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTZ{S|U}_674  */
 32'b0001111000100111000000?????????? : begin a64_to_t32 = {9'b011100000,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],7'b0010000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* FMOV_424  */
 32'b?001111001011001???????????????? : begin a64_to_t32 = {9'b011100011,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],raw_encoding_i[15],raw_encoding_i[10],1'b1,raw_encoding_i[14:11]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* FCVTZU_411  */
 32'b0001111000100011110000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110011,raw_encoding_i[2:0],raw_encoding_i[4],6'b101001,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVT (SP > HP)_320  */
 32'b00011110011?????001010?????????? : begin a64_to_t32 = {6'b011100,raw_encoding_i[3],2'b11,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FADD_373  */
 32'b00011110001?????001000?????00000 : begin a64_to_t32 = {6'b011101,raw_encoding_i[8],6'b110100,raw_encoding_i[7:5],raw_encoding_i[9],6'b101001,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCMP_346  */
 32'b0??011100?100001110010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b11,raw_encoding_i[2:0],raw_encoding_i[4],4'b0000,raw_encoding_i[29],raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTA[SU]_622  */
 32'b0?0011101?100000111010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],5'b01100,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCMLT_600  */
 32'b0001111000100001010000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110001,raw_encoding_i[2:0],raw_encoding_i[4],6'b101001,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FNEG_317  */
 32'b0001111000100101110000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110110,raw_encoding_i[2:0],raw_encoding_i[4],6'b101011,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTZ_324  */
 32'b0?1011100?1?????111111?????????? : begin a64_to_t32 = {6'b111110,raw_encoding_i[3],1'b0,raw_encoding_i[22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1111,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FDIV_503  */
 32'b1001111010101110000000?????????? : begin a64_to_t32 = {9'b011100001,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],7'b0110000}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* FMOV_433  */
 32'b0001111000100100010000?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],6'b111001,raw_encoding_i[2:0],raw_encoding_i[4],6'b101001,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTN_321  */
 32'b0?00111110??????0101?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0101,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* FMLS_719  */
 32'b0001111011100010010000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110010,raw_encoding_i[2:0],raw_encoding_i[4],6'b101001,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVT (HP>SP)_341  */
 32'b00011110001?????011010?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1010,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMAXNM_368  */
 32'b010111100?1?????110111?????????? : begin a64_to_t32 = {6'b111110,raw_encoding_i[3],1'b1,raw_encoding_i[22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1101,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMULX_518  */
 32'b0?1011100?100001100110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b10,raw_encoding_i[2:0],raw_encoding_i[4],5'b01001,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTX_616  */
 32'b0?00111000100001011010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],6'b110110,raw_encoding_i[2:0],raw_encoding_i[4],6'b011000,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTN (S->H)_607  */
 32'b0??011101?100000110110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],4'b0101,raw_encoding_i[29],raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCM{EQ|LE}_599  */
 32'b00011110011?????011110?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMINNM_378  */
 32'b?001111000100100000000?????????? : begin a64_to_t32 = {9'b011101001,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],7'b0010000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* FCVTAS_421  */
 32'b0101111110??????1001?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1001,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* FMUL_750  */
 32'b0?00111111??????1001?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1001,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* FMUL_728  */
 32'b0?00111110??????1001?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1001,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* FMUL_727  */
 32'b?001111000011000???????????????? : begin a64_to_t32 = {9'b011101101,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],raw_encoding_i[15],raw_encoding_i[10],1'b1,raw_encoding_i[14:11]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* FCVTZS_406  */
 32'b00011111000?????1??????????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[12:10],raw_encoding_i[14],raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[13]; end /* FMSUB_396  */
 32'b0?00111100000???111101?????????? : begin a64_to_t32 = {raw_encoding_i[18],5'b11111,raw_encoding_i[3],3'b000,raw_encoding_i[17],raw_encoding_i[16],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],5'b11110,raw_encoding_i[30],2'b01,raw_encoding_i[8],raw_encoding_i[7],raw_encoding_i[6],raw_encoding_i[5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMOV (s)_704  */
 32'b0001111011100010110000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110010,raw_encoding_i[2:0],raw_encoding_i[4],6'b101101,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVT (DP > HP)_342  */
 32'b0001111001100001110000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110001,raw_encoding_i[2:0],raw_encoding_i[4],6'b101111,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FSQRT_331  */
 32'b0?0011100?100001100010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b10,raw_encoding_i[2:0],raw_encoding_i[4],5'b01000,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTN_611  */
 32'b0001111001100000010000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110000,raw_encoding_i[2:0],raw_encoding_i[4],6'b101101,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMOV_328  */
 32'b010111100?100001110010?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],6'b111100,raw_encoding_i[2:0],raw_encoding_i[4],3'b101,raw_encoding_i[22],2'b11,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTAS_653  */
 32'b00011110001?????????01?????1???? : begin a64_to_t32 = {7'b1111000,raw_encoding_i[15:14],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[13]; ccbit_n = raw_encoding_i[12]; ccbit_d = 1'b0; end /* FCCMPE_384  */
 32'b0??011100?100001101010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b11,raw_encoding_i[2:0],raw_encoding_i[4],4'b0001,raw_encoding_i[29],raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTN[SU]_618  */
 32'b01?111101?100000110010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],4'b0100,raw_encoding_i[29],1'b0,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCM{GT|GE}_639  */
 32'b0?1011101?100001111110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b11,raw_encoding_i[2:0],raw_encoding_i[4],5'b01111,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FSQRT_628  */
 32'b0001111000100101010000?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],6'b111011,raw_encoding_i[2:0],raw_encoding_i[4],6'b101001,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTM_323  */
 32'b0?00111000100001011110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],6'b110110,raw_encoding_i[2:0],raw_encoding_i[4],6'b011100,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTL (H->S)_609  */
 32'b0?1011101?100001110110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b11,raw_encoding_i[2:0],raw_encoding_i[4],5'b01011,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRSQRTE_627  */
 32'b0001111001100100110000?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],6'b111010,raw_encoding_i[2:0],raw_encoding_i[4],6'b101101,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTP_335  */
 32'b0001111000100001110000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110001,raw_encoding_i[2:0],raw_encoding_i[4],6'b101011,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FSQRT_318  */
 32'b0??0111001100001011010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],6'b111010,raw_encoding_i[2:0],raw_encoding_i[4],5'b01100,raw_encoding_i[29],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVT{X}N (D->S)_608  */
 32'b00011110011????????10000000????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],2'b11,raw_encoding_i[20:17],raw_encoding_i[2:0],raw_encoding_i[4],8'b10110000,raw_encoding_i[16:13]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMOV_358  */
 32'b00011111011?????1??????????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],2'b11,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[12:10],raw_encoding_i[14],raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[13]; end /* FNMSUB_402  */
 32'b0110111100000???111101?????????? : begin a64_to_t32 = {raw_encoding_i[18],5'b11111,raw_encoding_i[3],3'b000,raw_encoding_i[17],raw_encoding_i[16],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],8'b11110111,raw_encoding_i[8],raw_encoding_i[7],raw_encoding_i[6],raw_encoding_i[5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMOV (d)_705  */
 32'b0001111001100110010000?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],6'b111000,raw_encoding_i[2:0],raw_encoding_i[4],6'b101101,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTA_338  */
 32'b0001111000100111010000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110111,raw_encoding_i[2:0],raw_encoding_i[4],6'b101001,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTX_326  */
 32'b00011111011?????0??????????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],2'b11,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[12:10],raw_encoding_i[14],raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[13]; end /* FNMADD_401  */
 32'b00011110011?????010110?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMIN_376  */
 32'b01?111101?100000110110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],4'b0101,raw_encoding_i[29],1'b0,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCM{EQ|LE}_640  */
 32'b0001111001100101110000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110110,raw_encoding_i[2:0],raw_encoding_i[4],6'b101111,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTZ_337  */
 32'b0?1011101?100000111110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],5'b01111,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FNEG_602  */
 32'b0?001110??1?????110001?????????? : begin a64_to_t32 = {6'b111110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1111,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* F{MAX|MIN}NM_493  */
 32'b0001111001100011110000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110011,raw_encoding_i[2:0],raw_encoding_i[4],6'b101101,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVT (DP > HP)_333  */
 32'b0??011101?100000110010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],4'b0100,raw_encoding_i[29],raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCM{GT|GE}_598  */
 32'b0??011100?100001101110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b11,raw_encoding_i[2:0],raw_encoding_i[4],4'b0011,raw_encoding_i[29],raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTM[SU]_620  */
 32'b00011111010?????0??????????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[12:10],raw_encoding_i[14],raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[13]; end /* FMADD_399  */
 32'b011111101?100001101010?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],6'b111110,raw_encoding_i[2:0],raw_encoding_i[4],3'b101,raw_encoding_i[22],2'b01,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTPU_648  */
 32'b00011110001????????10000000????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],2'b11,raw_encoding_i[20:17],raw_encoding_i[2:0],raw_encoding_i[4],8'b10100000,raw_encoding_i[16:13]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMOV_357  */
 32'b00011110011?????001000?????01000 : begin a64_to_t32 = {6'b011101,raw_encoding_i[8],6'b110101,raw_encoding_i[7:5],raw_encoding_i[9],12'b101101000000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCMP (with zero)_351  */
 32'b0?00111001100001011110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],6'b111010,raw_encoding_i[2:0],raw_encoding_i[4],6'b011100,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTL (S->D)_610  */
 32'b011111100?100001110010?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],6'b111100,raw_encoding_i[2:0],raw_encoding_i[4],3'b101,raw_encoding_i[22],2'b01,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTAU_654  */
 32'b0??011101?100001101010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b11,raw_encoding_i[2:0],raw_encoding_i[4],4'b0010,raw_encoding_i[29],raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTP[SU]_619  */
 32'b1001111010101111000000?????????? : begin a64_to_t32 = {9'b011100000,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],7'b0110000}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* FMOV_434  */
 32'b?001111000011001???????????????? : begin a64_to_t32 = {9'b011100011,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],raw_encoding_i[15],raw_encoding_i[10],1'b1,raw_encoding_i[14:11]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* FCVTZU_407  */
 32'b0?001110??1?????110011?????????? : begin a64_to_t32 = {6'b011110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1100,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FML{A|S}_495  */
 32'b0?0011101?100001100110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b10,raw_encoding_i[2:0],raw_encoding_i[4],5'b01011,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTZ_614  */
 32'b0?0011101?100001110110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b11,raw_encoding_i[2:0],raw_encoding_i[4],5'b01010,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRECPE_626  */
 32'b1001111001100111000000?????????? : begin a64_to_t32 = {9'b011100000,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],7'b0010000}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* FMOV_432  */
 32'b0?101110??1?????110001?????????? : begin a64_to_t32 = {6'b111110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1100,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* F{MAX|MIN}NMP_494  */
 32'b00011110011?????010010?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMAX_375  */
 32'b0??01111001?????111111?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],1'b1,raw_encoding_i[20:16],raw_encoding_i[2:0],raw_encoding_i[4],5'b11110,raw_encoding_i[30],raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTZ{S|U}_673  */
 32'b010111100?100001101010?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],6'b111101,raw_encoding_i[2:0],raw_encoding_i[4],3'b101,raw_encoding_i[22],2'b11,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTNS_645  */
 32'b?0011110001??001000000?????????? : begin a64_to_t32 = {9'b011100111,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],raw_encoding_i[20:19],5'b10000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* FCVT{N|P|M|Z}U_418  */
 32'b011111101?100001101110?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b111100,raw_encoding_i[2:0],raw_encoding_i[4],3'b101,raw_encoding_i[22],2'b11,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCVTZU_652  */
 32'b00011110001?????000110?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1010,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FDIV_363  */
 32'b0??01110??1?????111001?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1110,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCM{EQ|GE|GT}_499  */
 32'b0101111110??????0101?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0101,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* FMLS_746  */
 32'b0001111001100100010000?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],6'b111001,raw_encoding_i[2:0],raw_encoding_i[4],6'b101101,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTN_334  */
 32'b?0011110001??000000000?????????? : begin a64_to_t32 = {9'b011100101,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],raw_encoding_i[20:19],5'b10000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* FCVT{N|P|M|Z}S_417  */
 32'b00011110001?????001000?????01000 : begin a64_to_t32 = {6'b011101,raw_encoding_i[8],6'b110101,raw_encoding_i[7:5],raw_encoding_i[9],12'b101001000000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCMP (with zero)_347  */
 32'b00011110001?????????11?????????? : begin a64_to_t32 = {6'b111100,raw_encoding_i[3],raw_encoding_i[15:14],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1010,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[13]; ccbit_n = raw_encoding_i[12]; ccbit_d = 1'b0; end /* FCSEL_390  */
 32'b0001111001100111010000?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b110111,raw_encoding_i[2:0],raw_encoding_i[4],6'b101101,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTX_339  */
 32'b00011110001?????011110?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1010,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMINNM_369  */
 32'b010111101?100000111010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],6'b011000,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCMLT_641  */
 32'b00011110001?????001000?????11000 : begin a64_to_t32 = {6'b011101,raw_encoding_i[8],6'b110101,raw_encoding_i[7:5],raw_encoding_i[9],12'b101011000000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FCMPE (with zero)_349  */
 32'b00011111000?????0??????????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[12:10],raw_encoding_i[14],raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[13]; end /* FMADD_395  */
 32'b00011110011?????000010?????????? : begin a64_to_t32 = {6'b011100,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMUL_371  */
 32'b0?1011100?100001100010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b10,raw_encoding_i[2:0],raw_encoding_i[4],5'b01010,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTA_615  */
 32'b0?1011101?100001100110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b10,raw_encoding_i[2:0],raw_encoding_i[4],5'b01001,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FRINTI_617  */
 32'b00011110001?????010010?????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1010,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* FMAX_366  */
 32'b00011111001?????0??????????????? : begin a64_to_t32 = {6'b111101,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[12:10],raw_encoding_i[14],raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[13]; end /* FNMADD_397  */
 32'b?0011110011??001000000?????????? : begin a64_to_t32 = {9'b011100111,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1010,raw_encoding_i[8],raw_encoding_i[20:19],5'b10000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* FCVT{N|P|M|Z}U_426  */
 32'b00001000000?????0??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],8'b11110100,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STXRB_123  */
 32'b0011110110?????????????????????? : begin a64_to_t32 = {6'b110110,raw_encoding_i[3],2'b00,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* STR (128-bit FP reg)_207  */
 32'b0??01110??1?????011111?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0111,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}ABA_484  */
 32'b0?00111101??????1011?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQDMULL_733  */
 32'b01?11110??1?????010001?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[18:16],raw_encoding_i[20],raw_encoding_i[2:0],raw_encoding_i[4],4'b0100,raw_encoding_i[19],1'b0,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}SHL_510  */
 32'b0?00111110??????0011?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0011,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQDMLAL_716  */
 32'b0??0111100001???10???1?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],3'b001,raw_encoding_i[18:16],raw_encoding_i[2:0],raw_encoding_i[4],2'b10,raw_encoding_i[13:12],1'b0,raw_encoding_i[11],raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SHRN; SQSHRUN; RSHRN; SQRSHRUN; {S|U}QSHRN; {S|U}QRSHRN; {S|U}SHLL_668  */
 32'b0101111000101000001010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],6'b111010,raw_encoding_i[2:0],raw_encoding_i[4],6'b001111,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SHA256SU0_791  */
 32'b00111000000????????????????????? : begin a64_to_t32 = {9'b110000000,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ST{U}RB_158  */
 32'b0??01110011?????001100?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0011,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}SUBW_537  */
 32'b0??01110101?????000100?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0001,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}ADDW_532  */
 32'b10011011010?????0??????????????? : begin a64_to_t32 = {9'b110111100,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b0010,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* SMULH_90  */
 32'b10001000000?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],8'b11111110,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STLXR_137  */
 32'b0??01110011?????101000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1010,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}MLSL_555  */
 32'b0??01110011?????110000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1100,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}MULL_562  */
 32'b0101111101??????1101?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1101,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQRDMULH_758  */
 32'b10111000000????????????????????? : begin a64_to_t32 = {9'b110000100,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ST{U}R_160  */
 32'b01111110??100000011110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b00,raw_encoding_i[2:0],raw_encoding_i[4],6'b011110,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQNEG_633  */
 32'b11001000000?????0??????????????? : begin a64_to_t32 = {9'b010000100,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[19:16],8'b00000000}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STXR (64-bit)_126  */
 32'b01011110000?????000100?????????? : begin a64_to_t32 = {6'b011110,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1100,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SHA1P_780  */
 32'b0101111110??????1100?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1100,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQDMULH_757  */
 32'b0011100100?????????????????????? : begin a64_to_t32 = {9'b110001000,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STRB_185  */
 32'b11001000100?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111110101111}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STLR (64-bit)_150  */
 32'b0??0111101??????0???01?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],raw_encoding_i[21:16],raw_encoding_i[2:0],raw_encoding_i[4],1'b0,raw_encoding_i[14:12],1'b1,raw_encoding_i[30],raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {|S|U}SHR; {S|U}SRA; {S|U}RSHR; {S|U}RSRA; SRI; SHL; SLI; SQSHLU; {S|U}QSHL_667  */
 32'b0?001110000????1001011?????????? : begin a64_to_t32 = {7'b0111001,raw_encoding_i[19],1'b1,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1011,raw_encoding_i[8],raw_encoding_i[18],raw_encoding_i[17],5'b10000}; ccbit_sf = raw_encoding_i[30]; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* SMOV (byte)_458  */
 32'b0??0111101??????111001?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],raw_encoding_i[21:16],raw_encoding_i[2:0],raw_encoding_i[4],5'b11101,raw_encoding_i[30],raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}CVTF_672  */
 32'b?1?01011001????????????????????? : begin a64_to_t32 = {8'b01011001,raw_encoding_i[29],raw_encoding_i[8:5],1'b0,raw_encoding_i[15:13],raw_encoding_i[3:0],1'b0,raw_encoding_i[12:10],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* SUB (register)_5  */
 32'b0101111110??????0111?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0111,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQDMLSL_749  */
 32'b0??01110011?????011100?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0111,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}ABDL_549  */
 32'b10001000000?????0??????????????? : begin a64_to_t32 = {9'b010000100,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[19:16],8'b00000000}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STXR_125  */
 32'b01011110000?????011000?????????? : begin a64_to_t32 = {6'b111110,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1100,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SHA256SU1_785  */
 32'b0?00111101??????1100?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1100,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQDMULH_735  */
 32'b0?001110101?????110100?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1101,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQDMULL_565  */
 32'b0??0111100001???0???01?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],3'b001,raw_encoding_i[18:16],raw_encoding_i[2:0],raw_encoding_i[4],1'b0,raw_encoding_i[14:12],1'b0,raw_encoding_i[30],raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {|S|U}SHR; {S|U}SRA; {S|U}RSHR; {S|U}RSRA; SRI; SHL; SLI; SQSHLU; {S|U}QSHL_664  */
 32'b?1?11010000?????000000?????????? : begin a64_to_t32 = {8'b01011011,raw_encoding_i[29],raw_encoding_i[8:5],4'b0000,raw_encoding_i[3:0],4'b0000,raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* SBC (register)_26  */
 32'b0??01110101?????000000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0000,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}ADDL_529  */
 32'b0??01111001?????0???01?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],1'b1,raw_encoding_i[20:16],raw_encoding_i[2:0],raw_encoding_i[4],1'b0,raw_encoding_i[14:12],1'b0,raw_encoding_i[30],raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {|S|U}SHR; {S|U}SRA; {S|U}RSHR; {S|U}RSRA; SRI; SHL; SLI; SQSHLU; {S|U}QSHL_666  */
 32'b01?11110??1?????010111?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[18:16],raw_encoding_i[20],raw_encoding_i[2:0],raw_encoding_i[4],4'b0101,raw_encoding_i[19],1'b0,raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}QRSHL_513  */
 32'b01011110011?????100100?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1001,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQDMLAL_571  */
 32'b01111000001?????????10?????????? : begin a64_to_t32 = {9'b110000010,raw_encoding_i[8:5],raw_encoding_i[3:0],2'b00,raw_encoding_i[15:13],2'b00,raw_encoding_i[12],raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STRH_213  */
 32'b?111000100?????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b101011,raw_encoding_i[8:5],1'b0,raw_encoding_i[20:18],raw_encoding_i[3:0],raw_encoding_i[17:10]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* SUB (immediate)_15  */
 32'b01011110000?????010100?????????? : begin a64_to_t32 = {6'b111110,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1100,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SHA256H2_784  */
 32'b01?11111001?????111001?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],1'b1,raw_encoding_i[20:16],raw_encoding_i[2:0],raw_encoding_i[4],6'b111000,raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}CVTF_685  */
 32'b11111100000????????????????????? : begin a64_to_t32 = {6'b110001,raw_encoding_i[3],2'b10,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],1'b1,raw_encoding_i[11],1'b0,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* ST{U}R (64-bit FP reg)_175  */
 32'b1111110100?????????????????????? : begin a64_to_t32 = {6'b110101,raw_encoding_i[3],2'b10,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* STR (64-bit FP reg)_202  */
 32'b?101000101?????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b101010,raw_encoding_i[8:5],1'b0,raw_encoding_i[20:18],raw_encoding_i[3:0],raw_encoding_i[17:10]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* SUB (immediate)_12  */
 32'b01011110101?????110100?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1101,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQDMULL_576  */
 32'b0??01110??1?????101001?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1010,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}MAXP_489  */
 32'b0??01110??1?????010001?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[18:16],raw_encoding_i[20],raw_encoding_i[2:0],raw_encoding_i[4],4'b0100,raw_encoding_i[19],raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}SHL_477  */
 32'b?1?01011??0????????????????????? : begin a64_to_t32 = {8'b01011101,raw_encoding_i[29],raw_encoding_i[8:5],raw_encoding_i[15:12],raw_encoding_i[3:0],raw_encoding_i[11:10],raw_encoding_i[23:22],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* SUB (register)_21  */
 32'b1010100??0?????????????????????? : begin a64_to_t32 = {4'b0010,raw_encoding_i[24],2'b11,raw_encoding_i[23],1'b0,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],1'b0,raw_encoding_i[21:15]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STP (64-bit regs)_242  */
 32'b0??01110??100001010010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b10,raw_encoding_i[2:0],raw_encoding_i[4],5'b00101,raw_encoding_i[29],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* [SU]QXTN_606  */
 32'b0?00111101??????0011?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0011,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQDMLAL_715  */
 32'b0??0111101??????1010?0?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1010,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* {S|U}MULL_731  */
 32'b01?11111001?????100??1?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],1'b1,raw_encoding_i[20:16],raw_encoding_i[2:0],raw_encoding_i[4],3'b100,raw_encoding_i[12],1'b0,raw_encoding_i[11],raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SHRN; SQSHRUN; RSHRN; SQRSHRUN; {S|U}QSHRN; {S|U}QRSHRN_684  */
 32'b01001110000??100001011?????????? : begin a64_to_t32 = {7'b0111000,raw_encoding_i[19],1'b1,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1011,raw_encoding_i[8],7'b0010000}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* SMOV (word)_460  */
 32'b0??01110001?????011100?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0111,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}ABDL_548  */
 32'b0??01110001?????000000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0000,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}ADDL_527  */
 32'b0??01110??1?????011101?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0111,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}ABD_483  */
 32'b11010100000????????????????00011 : begin a64_to_t32 = {9'b101111111,raw_encoding_i[20:17],4'b1000,raw_encoding_i[16:5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SMC_99  */
 32'b0??01110??1?????011011?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0110,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}MIN_482  */
 32'b11001000001?????0??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],4'b0111,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STXP (64-bit)_132  */
 32'b0??01110001?????000100?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0001,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}ADDW_530  */
 32'b01?11111001?????0???01?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],1'b1,raw_encoding_i[20:16],raw_encoding_i[2:0],raw_encoding_i[4],1'b0,raw_encoding_i[14:12],2'b00,raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {|S|U}SHR; {S|U}SRA; {S|U}RSHR; {S|U}RSRA; SRI; SHL; SLI; SQSHLU; {S|U}QSHL_680  */
 32'b?001111001100010000000?????????? : begin a64_to_t32 = {9'b011100100,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],7'b0010000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* SCVTF_427  */
 32'b0??0111101??????0110?0?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0110,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* {S|U}MLSL_721  */
 32'b01001000000?????0??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],8'b11110101,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STXRH_124  */
 32'b0101111110??????1101?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1101,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQRDMULH_759  */
 32'b01011110000?????000000?????????? : begin a64_to_t32 = {6'b011110,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1100,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SHA1C_779  */
 32'b1010110??0?????????????????????? : begin a64_to_t32 = {4'b0011,raw_encoding_i[24],1'b0,raw_encoding_i[3],raw_encoding_i[23],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[20:15],raw_encoding_i[13],1'b1,raw_encoding_i[12:10],raw_encoding_i[14]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[21]; end /* STP (128-bit FP regs)_248  */
 32'b01?1111101??????111001?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],raw_encoding_i[21:16],raw_encoding_i[2:0],raw_encoding_i[4],6'b111010,raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}CVTF_686  */
 32'b00001000100?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111110001111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STLRB_147  */
 32'b1101010100001??????????????????? : begin a64_to_t32 = {5'b01110,raw_encoding_i[18:16],1'b0,raw_encoding_i[15:12],raw_encoding_i[3:0],4'b1101,raw_encoding_i[7:5],1'b1,raw_encoding_i[11:8]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* SYS_290  */
 32'b01?1111100001???100??1?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],3'b001,raw_encoding_i[18:16],raw_encoding_i[2:0],raw_encoding_i[4],3'b100,raw_encoding_i[12],1'b0,raw_encoding_i[11],raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQSHRUN; SQRSHRUN; {S|U}QSHRN; {S|U}QRSHRN_682  */
 32'b0??01110101?????100000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1000,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}MLAL_553  */
 32'b01111000000????????????????????? : begin a64_to_t32 = {9'b110000010,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ST{U}RH_159  */
 32'b0?00111101??????1101?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1101,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQRDMULH_737  */
 32'b0?001110011?????110100?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1101,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQDMULL_564  */
 32'b0?101110??100001001110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b10,raw_encoding_i[2:0],raw_encoding_i[4],6'b001100,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SHLL_605  */
 32'b0??01110011?????001000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0010,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}SUBL_534  */
 32'b0??01110??1?????101011?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1010,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}MINP_490  */
 32'b11111000001?????????10?????????? : begin a64_to_t32 = {9'b110000110,raw_encoding_i[8:5],raw_encoding_i[3:0],2'b00,raw_encoding_i[15:13],1'b0,raw_encoding_i[12],raw_encoding_i[12],raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STR (64-bit)_215  */
 32'b0?001110011?????100100?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1001,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQDMLAL_557  */
 32'b0?001110??100000011110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b00,raw_encoding_i[2:0],raw_encoding_i[4],5'b01110,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQABS_591  */
 32'b0??01110001?????010100?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0101,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}ABAL_542  */
 32'b?0011010110?????000011?????????? : begin a64_to_t32 = {9'b110111001,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b1111,raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* SDIV_70  */
 32'b00111100001?????????10?????????? : begin a64_to_t32 = {6'b111000,raw_encoding_i[3],2'b00,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],1'b0,raw_encoding_i[12],raw_encoding_i[15:13],3'b000,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* STR (8-bit FP reg)_226  */
 32'b0??01110001?????100000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1000,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}MLAL_551  */
 32'b0??01110001?????001100?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0011,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}SUBW_536  */
 32'b0??01110101?????101000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1010,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}MLSL_556  */
 32'b0101111101??????0111?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0111,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQDMLSL_748  */
 32'b01001000000?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],8'b11111101,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STLXRH_136  */
 32'b00001000000?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],8'b11111100,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STLXRB_135  */
 32'b0011110100?????????????????????? : begin a64_to_t32 = {6'b110100,raw_encoding_i[3],2'b00,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* STR (8-bit FP reg)_199  */
 32'b00111100101?????????10?????????? : begin a64_to_t32 = {6'b111010,raw_encoding_i[3],2'b00,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],2'b00,raw_encoding_i[15:13],raw_encoding_i[12],2'b00,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* STR (128-bit FP reg)_234  */
 32'b01?11110??100000001110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b00,raw_encoding_i[2:0],raw_encoding_i[4],4'b0011,raw_encoding_i[29],1'b0,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {SU|US}QADD_631  */
 32'b01?11110??1?????000011?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0000,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}QADD_506  */
 32'b0?00111110??????1100?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1100,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQDMULH_736  */
 32'b0110110??0?????????????????????? : begin a64_to_t32 = {4'b0011,raw_encoding_i[24],1'b1,raw_encoding_i[3],raw_encoding_i[23],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[20:15],raw_encoding_i[13],1'b0,raw_encoding_i[12:10],raw_encoding_i[14]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[21]; end /* STP (64-bit FP regs)_246  */
 32'b01011110011?????101100?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQDMLSL_573  */
 32'b0?00111110??????0111?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0111,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQDMLSL_724  */
 32'b01?111110001????100??1?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[19:16],raw_encoding_i[2:0],raw_encoding_i[4],3'b100,raw_encoding_i[12],1'b0,raw_encoding_i[11],raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SHRN; SQSHRUN; RSHRN; SQRSHRUN; {S|U}QSHRN; {S|U}QRSHRN_683  */
 32'b0?101110??100000011110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b00,raw_encoding_i[2:0],raw_encoding_i[4],5'b01111,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQNEG_592  */
 32'b0??01110??100000001110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b00,raw_encoding_i[2:0],raw_encoding_i[4],4'b0011,raw_encoding_i[29],raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {SU|US}QADD_584  */
 32'b0010100??0?????????????????????? : begin a64_to_t32 = {4'b0010,raw_encoding_i[24],2'b01,raw_encoding_i[23],1'b0,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],1'b0,raw_encoding_i[21:15]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STP (32-bit regs)_239  */
 32'b00111000001?????????10?????????? : begin a64_to_t32 = {9'b110000000,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b0,raw_encoding_i[12],raw_encoding_i[15:13],3'b000,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STRB_212  */
 32'b0?001110101?????100100?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1001,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQDMLAL_558  */
 32'b?00100110??????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b110100,raw_encoding_i[8:5],1'b0,raw_encoding_i[20:18],raw_encoding_i[3:0],raw_encoding_i[17:16],raw_encoding_i[15:10]}; ccbit_sf = raw_encoding_i[22]; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* SBFM_30  */
 32'b01001000100?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111110011111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STLRH_148  */
 32'b0??01110101?????001100?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0011,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}SUBW_538  */
 32'b0??01111001?????111001?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],1'b1,raw_encoding_i[20:16],raw_encoding_i[2:0],raw_encoding_i[4],5'b11100,raw_encoding_i[30],raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}CVTF_671  */
 32'b11001000001?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],4'b1111,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STLXP (64-bit)_144  */
 32'b0??011100?100001110110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b11,raw_encoding_i[2:0],raw_encoding_i[4],4'b0110,raw_encoding_i[29],raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}CVTF_625  */
 32'b01?11110??1?????010101?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[18:16],raw_encoding_i[20],raw_encoding_i[2:0],raw_encoding_i[4],4'b0101,raw_encoding_i[19],1'b0,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}RSHL_512  */
 32'b0??01110??1?????010111?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[18:16],raw_encoding_i[20],raw_encoding_i[2:0],raw_encoding_i[4],4'b0101,raw_encoding_i[19],raw_encoding_i[30],raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}QRSHL_480  */
 32'b0??011110001????0???01?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[19:16],raw_encoding_i[2:0],raw_encoding_i[4],1'b0,raw_encoding_i[14:12],1'b0,raw_encoding_i[30],raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {|S|U}SHR; {S|U}SRA; {S|U}RSHR; {S|U}RSRA; SRI; SHL; SLI; SQSHLU; {S|U}QSHL_665  */
 32'b0??01110??1?????001011?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0010,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}QSUB_474  */
 32'b10001000001?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],4'b1111,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STLXP_143  */
 32'b10011011001?????0??????????????? : begin a64_to_t32 = {9'b110111100,raw_encoding_i[8:5],raw_encoding_i[13:10],raw_encoding_i[3:0],4'b0001,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* SMADDL_88  */
 32'b01011110011?????110100?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1101,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQDMULL_575  */
 32'b0?00111110??????1011?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQDMULL_734  */
 32'b10111000001?????????10?????????? : begin a64_to_t32 = {9'b110000100,raw_encoding_i[8:5],raw_encoding_i[3:0],2'b00,raw_encoding_i[15:13],1'b0,raw_encoding_i[12],1'b0,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STR (32-bit)_214  */
 32'b0101111110??????1011?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQDMULL_755  */
 32'b10001000001?????0??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],4'b0111,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STXP_131  */
 32'b?111000101?????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b101011,raw_encoding_i[8:5],1'b0,raw_encoding_i[20:18],raw_encoding_i[3:0],raw_encoding_i[17:10]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* SUB (immediate)_16  */
 32'b11001000000?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],8'b11111110,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STLXR (64-bit)_138  */
 32'b0??01110??1?????001001?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0010,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}HSUB_473  */
 32'b0??01110101?????001000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0010,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}SUBL_535  */
 32'b01111110??100001001010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b10,raw_encoding_i[2:0],raw_encoding_i[4],6'b001001,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQXTUN_642  */
 32'b01011110000?????010000?????????? : begin a64_to_t32 = {6'b111110,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1100,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SHA256H_783  */
 32'b0??01110011?????000100?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0001,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}ADDW_531  */
 32'b0111110100?????????????????????? : begin a64_to_t32 = {6'b110100,raw_encoding_i[3],2'b10,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* STR (16-bit FP reg)_200  */
 32'b0??01110??1?????011001?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0110,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}MAX_481  */
 32'b0?001110101?????101100?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQDMLSL_560  */
 32'b0??01110??1?????000101?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0001,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}RHADD_471  */
 32'b0??01110??1?????010101?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[18:16],raw_encoding_i[20],raw_encoding_i[2:0],raw_encoding_i[4],4'b0101,raw_encoding_i[19],raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}RSHL_479  */
 32'b11010100000????????????????00001 : begin a64_to_t32 = {5'b00000,raw_encoding_i[20:13],8'b11011111,raw_encoding_i[12:5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SVC_97  */
 32'b01111100001?????????10?????????? : begin a64_to_t32 = {6'b111000,raw_encoding_i[3],2'b10,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],2'b00,raw_encoding_i[15:13],2'b00,raw_encoding_i[12],raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* STR (16-bit FP reg)_227  */
 32'b0??01110001?????101000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1010,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}MLSL_554  */
 32'b0??0111110??????0110?0?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0110,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* {S|U}MLSL_722  */
 32'b?001111000000010???????????????? : begin a64_to_t32 = {9'b011101100,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],raw_encoding_i[15],raw_encoding_i[10],1'b1,raw_encoding_i[14:11]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* SCVTF_408  */
 32'b01?11110??1?????101101?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQ{R}DMULH_516  */
 32'b0??0111110??????0010?0?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0010,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* {S|U}MLAL_714  */
 32'b0??01110??100000011010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b00,raw_encoding_i[2:0],raw_encoding_i[4],4'b0110,raw_encoding_i[29],raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}ADALP_590  */
 32'b11111100001?????????10?????????? : begin a64_to_t32 = {6'b111001,raw_encoding_i[3],2'b10,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],2'b00,raw_encoding_i[15:13],1'b0,raw_encoding_i[12],raw_encoding_i[12],raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* STR (64-bit FP reg)_229  */
 32'b0101111101??????0011?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0011,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQDMLAL_744  */
 32'b?001111001000010???????????????? : begin a64_to_t32 = {9'b011101100,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],raw_encoding_i[15],raw_encoding_i[10],1'b1,raw_encoding_i[14:11]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* SCVTF_412  */
 32'b01?11110??1?????010011?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[18:16],raw_encoding_i[20],raw_encoding_i[2:0],raw_encoding_i[4],4'b0100,raw_encoding_i[19],1'b0,raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}QSHL_511  */
 32'b0101111110??????0011?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0011,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQDMLAL_745  */
 32'b00111100000????????????????????? : begin a64_to_t32 = {6'b110000,raw_encoding_i[3],2'b00,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],1'b1,raw_encoding_i[11],1'b0,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* ST{U}R (8-bit FP reg)_172  */
 32'b0??0111101??????0010?0?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0010,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* {S|U}MLAL_713  */
 32'b01?1111101??????0???01?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],raw_encoding_i[21:16],raw_encoding_i[2:0],raw_encoding_i[4],1'b0,raw_encoding_i[14:12],2'b10,raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {|S|U}SHR; {S|U}SRA; {S|U}RSHR; {S|U}RSRA; SRI; SHL; SLI; SQSHLU; {S|U}QSHL_681  */
 32'b10001000100?????1??????????????? : begin a64_to_t32 = {9'b010001100,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111110101111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STLR_149  */
 32'b0??01110101?????010100?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0101,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}ABAL_544  */
 32'b0??01111001?????10???1?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],1'b1,raw_encoding_i[20:16],raw_encoding_i[2:0],raw_encoding_i[4],2'b10,raw_encoding_i[13:12],1'b0,raw_encoding_i[11],raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SHRN; SQSHRUN; RSHRN; SQRSHRUN; {S|U}QSHRN; {S|U}QRSHRN; {S|U}SHLL_670  */
 32'b0??01110??100000001010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b00,raw_encoding_i[2:0],raw_encoding_i[4],4'b0010,raw_encoding_i[29],raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}ADDLP_583  */
 32'b01?11110??1?????001011?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0010,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}QSUB_507  */
 32'b0??0111110??????1010?0?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1010,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* {S|U}MULL_732  */
 32'b0?001110011?????101100?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQDMLSL_559  */
 32'b10111100001?????????10?????????? : begin a64_to_t32 = {6'b111001,raw_encoding_i[3],2'b00,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],2'b00,raw_encoding_i[15:13],1'b0,raw_encoding_i[12],1'b0,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* STR (32-bit FP reg)_228  */
 32'b01111100000????????????????????? : begin a64_to_t32 = {6'b110000,raw_encoding_i[3],2'b10,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],1'b1,raw_encoding_i[11],1'b0,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* ST{U}R (16-bit FP reg)_173  */
 32'b01?11110??100001010010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b10,raw_encoding_i[2:0],raw_encoding_i[4],5'b00101,raw_encoding_i[29],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}QXTN_643  */
 32'b?101000100?????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b101010,raw_encoding_i[8:5],1'b0,raw_encoding_i[20:18],raw_encoding_i[3:0],raw_encoding_i[17:10]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* SUB (immediate)_11  */
 32'b?001111000100010000000?????????? : begin a64_to_t32 = {9'b011100100,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],7'b0010000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* SCVTF_419  */
 32'b0??01110??1?????101101?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQ{R}DMULH_491  */
 32'b0101111101??????1011?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQDMULL_754  */
 32'b01?1111100001???0???01?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],3'b001,raw_encoding_i[18:16],raw_encoding_i[2:0],raw_encoding_i[4],1'b0,raw_encoding_i[14:12],2'b00,raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {|S|U}SHR; {S|U}SRA; {S|U}RSHR; {S|U}RSRA; SRI; SHL; SLI; SQSHLU; {S|U}QSHL_678  */
 32'b0??01110??1?????000011?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0000,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}QADD_470  */
 32'b0??01110011?????000000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0000,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}ADDL_528  */
 32'b0??01110001?????110000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1100,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}MULL_561  */
 32'b0??01110??1?????010011?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[18:16],raw_encoding_i[20],raw_encoding_i[2:0],raw_encoding_i[4],4'b0100,raw_encoding_i[19],raw_encoding_i[30],raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}QSHL_478  */
 32'b0101111101??????1100?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1100,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQDMULH_756  */
 32'b0101111000101000000010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],6'b111001,raw_encoding_i[2:0],raw_encoding_i[4],6'b001011,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SHA1H_789  */
 32'b1111100100?????????????????????? : begin a64_to_t32 = {9'b110001110,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[21:10]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STR (64-bit)_188  */
 32'b0?00111101??????0111?0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0111,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQDMLSL_723  */
 32'b0??01110011?????010100?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0101,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}ABAL_543  */
 32'b1101010100101??????????????????? : begin a64_to_t32 = {5'b01110,raw_encoding_i[18:16],1'b1,raw_encoding_i[15:12],raw_encoding_i[3:0],4'b1101,raw_encoding_i[7:5],1'b1,raw_encoding_i[11:8]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* SYSL_292  */
 32'b1011110100?????????????????????? : begin a64_to_t32 = {6'b110101,raw_encoding_i[3],2'b00,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* STR (32-bit FP reg)_201  */
 32'b0?001110000???10001011?????????? : begin a64_to_t32 = {7'b0111000,raw_encoding_i[19],1'b1,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1011,raw_encoding_i[8],raw_encoding_i[18],6'b110000}; ccbit_sf = raw_encoding_i[30]; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* SMOV (hword)_459  */
 32'b00111100100????????????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],2'b00,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],1'b1,raw_encoding_i[11],1'b0,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* ST{U}R (128-bit FP reg)_180  */
 32'b0??01110101?????110000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1100,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}MULL_563  */
 32'b0111100100?????????????????????? : begin a64_to_t32 = {9'b110001010,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STRH_186  */
 32'b0??01110101?????011100?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0111,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}ABDL_550  */
 32'b01011110000?????001000?????????? : begin a64_to_t32 = {6'b011110,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1100,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SHA1M_781  */
 32'b01011110??100000011110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b00,raw_encoding_i[2:0],raw_encoding_i[4],6'b011100,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQABS_632  */
 32'b11111000000????????????????????? : begin a64_to_t32 = {9'b110000110,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ST{U}R (64-bit)_161  */
 32'b0??01110??1?????000001?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0000,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}HADD_469  */
 32'b01011110000?????001100?????????? : begin a64_to_t32 = {6'b011110,raw_encoding_i[3],2'b11,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1100,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SHA1SU0_782  */
 32'b0?00111110??????1101?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1101,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* SQRDMULH_738  */
 32'b10111100000????????????????????? : begin a64_to_t32 = {6'b110001,raw_encoding_i[3],2'b00,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],1'b1,raw_encoding_i[11],1'b0,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* ST{U}R (32-bit FP reg)_174  */
 32'b0101111000101000000110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],6'b111010,raw_encoding_i[2:0],raw_encoding_i[4],6'b001110,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SHA1SU1_790  */
 32'b0??01110001?????001000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0010,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}SUBL_533  */
 32'b010111100?100001110110?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b111000,raw_encoding_i[2:0],raw_encoding_i[4],3'b101,raw_encoding_i[22],2'b11,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SCVTF_655  */
 32'b0010110??0?????????????????????? : begin a64_to_t32 = {4'b0011,raw_encoding_i[24],1'b0,raw_encoding_i[3],raw_encoding_i[23],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[20:15],raw_encoding_i[13],1'b0,raw_encoding_i[12:10],raw_encoding_i[14]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[21]; end /* STP (32-bit FP regs)_244  */
 32'b0??01110011?????100000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1000,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {S|U}MLAL_552  */
 32'b0??011110001????10???1?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[19:16],raw_encoding_i[2:0],raw_encoding_i[4],2'b10,raw_encoding_i[13:12],1'b0,raw_encoding_i[11],raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SHRN; SQSHRUN; RSHRN; SQRSHRUN; {S|U}QSHRN; {S|U}QRSHRN; {S|U}SHLL_669  */
 32'b10011011001?????1??????????????? : begin a64_to_t32 = {9'b110111101,raw_encoding_i[8:5],raw_encoding_i[13:10],raw_encoding_i[3:0],4'b0001,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* SMSUBL_89  */
 32'b01011110101?????101100?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQDMLSL_574  */
 32'b0?101110??100001001010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b10,raw_encoding_i[2:0],raw_encoding_i[4],6'b001001,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQXTUN_604  */
 32'b01011110101?????100100?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1001,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* SQDMLAL_572  */
 32'b1011100100?????????????????????? : begin a64_to_t32 = {9'b110001100,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* STR (32-bit)_187  */
 32'b01?111110001????0???01?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[19:16],raw_encoding_i[2:0],raw_encoding_i[4],1'b0,raw_encoding_i[14:12],2'b00,raw_encoding_i[8],1'b1,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {|S|U}SHR; {S|U}SRA; {S|U}RSHR; {S|U}RSRA; SRI; SHL; SLI; SQSHLU; {S|U}QSHL_679  */
 32'b?0110110???????????????????????? : begin a64_to_t32 = {5'b10100,raw_encoding_i[31],raw_encoding_i[23:19],raw_encoding_i[18:17],raw_encoding_i[3:0],raw_encoding_i[16:5]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* TBZ_296  */
 32'b0?001110000?????0???00?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],2'b10,raw_encoding_i[14:13],raw_encoding_i[8],raw_encoding_i[12],raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* Table (TBL/TBX)_439  */
 32'b?0110111???????????????????????? : begin a64_to_t32 = {5'b10101,raw_encoding_i[31],raw_encoding_i[23:19],raw_encoding_i[18:17],raw_encoding_i[3:0],raw_encoding_i[16:5]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* TBNZ_297  */
 32'b01111110??100000101110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],6'b001110,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* NEG_638  */
 32'b0?10111000100000010110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],6'b110000,raw_encoding_i[2:0],raw_encoding_i[4],5'b01011,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* NOT_588  */
 32'b0?101110??100000101110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],5'b00111,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* NEG_597  */
 32'b10010011110????????????????????? : begin a64_to_t32 = {9'b110100111,raw_encoding_i[8:5],2'b00,raw_encoding_i[15:14],raw_encoding_i[3:0],raw_encoding_i[13:10],raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* EXTR (64-bit)_109  */
 32'b?1001010??0????????????????????? : begin a64_to_t32 = {9'b010101000,raw_encoding_i[8:5],raw_encoding_i[15:12],raw_encoding_i[3:0],raw_encoding_i[11:10],raw_encoding_i[23:22],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* EOR_264  */
 32'b00010011100????????????????????? : begin a64_to_t32 = {9'b110100111,raw_encoding_i[8:5],2'b00,raw_encoding_i[15:14],raw_encoding_i[3:0],raw_encoding_i[13:10],raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* EXTR (32-bit)_108  */
 32'b11010110100111110000001111100000 : begin a64_to_t32 = {29'b10011110111101000111100000000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* ERET_309  */
 32'b0?101110000?????0????0?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b11,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[14:11],raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* Extract_445  */
 32'b?1001010??1????????????????????? : begin a64_to_t32 = {9'b010101010,raw_encoding_i[8:5],raw_encoding_i[15:12],raw_encoding_i[3:0],raw_encoding_i[11:10],raw_encoding_i[23:22],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* EON_265  */
 32'b?10100100??????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b001000,raw_encoding_i[8:5],1'b0,raw_encoding_i[18:16],raw_encoding_i[3:0],raw_encoding_i[20:19],raw_encoding_i[15:10]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[22]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* EOR_255  */
 32'b?0011011000?????1??????????????? : begin a64_to_t32 = {9'b110110000,raw_encoding_i[8:5],raw_encoding_i[13:10],raw_encoding_i[3:0],4'b0001,raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* MSUB_87  */
 32'b?10100101??????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[16],6'b100100,raw_encoding_i[20:17],1'b0,raw_encoding_i[15:13],raw_encoding_i[3:0],raw_encoding_i[12:5]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[22]; ccbit_n = raw_encoding_i[21]; ccbit_d = raw_encoding_i[4]; end /* MOVZ_272  */
 32'b110101010001???????????????????? : begin a64_to_t32 = {5'b01110,raw_encoding_i[18:16],1'b0,raw_encoding_i[15:12],raw_encoding_i[3:0],3'b111,raw_encoding_i[19],raw_encoding_i[7:5],1'b1,raw_encoding_i[11:8]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* MSR (system register)_291  */
 32'b0??01110??1?????100101?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1001,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* ML{A|S}_487  */
 32'b110101010011???????????????????? : begin a64_to_t32 = {5'b01110,raw_encoding_i[18:16],1'b1,raw_encoding_i[15:12],raw_encoding_i[3:0],3'b111,raw_encoding_i[19],raw_encoding_i[7:5],1'b1,raw_encoding_i[11:8]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* MRS_293  */
 32'b0?00111100000???10?001?????????? : begin a64_to_t32 = {raw_encoding_i[18],5'b11111,raw_encoding_i[3],3'b000,raw_encoding_i[17],raw_encoding_i[16],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],2'b10,raw_encoding_i[13],2'b00,raw_encoding_i[30],2'b01,raw_encoding_i[8],raw_encoding_i[7],raw_encoding_i[6],raw_encoding_i[5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* MOVI (hl)_694  */
 32'b0?10111110??????0000?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0000,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* MLA_710  */
 32'b0?10111100000???10?001?????????? : begin a64_to_t32 = {raw_encoding_i[18],5'b11111,raw_encoding_i[3],3'b000,raw_encoding_i[17],raw_encoding_i[16],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],2'b10,raw_encoding_i[13],2'b00,raw_encoding_i[30],2'b11,raw_encoding_i[8],raw_encoding_i[7],raw_encoding_i[6],raw_encoding_i[5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* MVNI (hl)_700  */
 32'b0?10111100000???0??001?????????? : begin a64_to_t32 = {raw_encoding_i[18],5'b11111,raw_encoding_i[3],3'b000,raw_encoding_i[17],raw_encoding_i[16],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],1'b0,raw_encoding_i[14:13],2'b00,raw_encoding_i[30],2'b11,raw_encoding_i[8],raw_encoding_i[7],raw_encoding_i[6],raw_encoding_i[5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* MVNI (sl)_698  */
 32'b0?10111100000???111001?????????? : begin a64_to_t32 = {raw_encoding_i[18],5'b11111,raw_encoding_i[3],3'b000,raw_encoding_i[17],raw_encoding_i[16],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],5'b11100,raw_encoding_i[30],2'b11,raw_encoding_i[8],raw_encoding_i[7],raw_encoding_i[6],raw_encoding_i[5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* MOVI (d)_703  */
 32'b0?10111100000???110?01?????????? : begin a64_to_t32 = {raw_encoding_i[18],5'b11111,raw_encoding_i[3],3'b000,raw_encoding_i[17],raw_encoding_i[16],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],3'b110,raw_encoding_i[12],1'b0,raw_encoding_i[30],2'b11,raw_encoding_i[8],raw_encoding_i[7],raw_encoding_i[6],raw_encoding_i[5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* MVNI (sm)_702  */
 32'b11010101000000000100????10111111 : begin a64_to_t32 = {25'b1001110101111100000010000,raw_encoding_i[11:8]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* MSR SPSel_282  */
 32'b?00100101??????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[16],6'b100101,raw_encoding_i[20:17],1'b0,raw_encoding_i[15:13],raw_encoding_i[3:0],raw_encoding_i[12:5]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[22]; ccbit_n = raw_encoding_i[21]; ccbit_d = raw_encoding_i[4]; end /* MOVN_271  */
 32'b0?00111100000???0??001?????????? : begin a64_to_t32 = {raw_encoding_i[18],5'b11111,raw_encoding_i[3],3'b000,raw_encoding_i[17],raw_encoding_i[16],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],1'b0,raw_encoding_i[14:13],2'b00,raw_encoding_i[30],2'b01,raw_encoding_i[8],raw_encoding_i[7],raw_encoding_i[6],raw_encoding_i[5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* MOVI (sl)_692  */
 32'b0?00111100000???111001?????????? : begin a64_to_t32 = {raw_encoding_i[18],5'b11111,raw_encoding_i[3],3'b000,raw_encoding_i[17],raw_encoding_i[16],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],5'b11100,raw_encoding_i[30],2'b01,raw_encoding_i[8],raw_encoding_i[7],raw_encoding_i[6],raw_encoding_i[5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* MOVI (b)_697  */
 32'b0?10111110??????0100?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0100,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* MLS_718  */
 32'b0?00111101??????1000?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1000,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* MUL_725  */
 32'b11010101000000110100????11011111 : begin a64_to_t32 = {20'b10011101011111000011,raw_encoding_i[11:8],5'b00000}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* MSR DAIFSet_283  */
 32'b?11100101??????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[16],6'b101100,raw_encoding_i[20:17],1'b0,raw_encoding_i[15:13],raw_encoding_i[3:0],raw_encoding_i[12:5]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[22]; ccbit_n = raw_encoding_i[21]; ccbit_d = raw_encoding_i[4]; end /* MOVK_273  */
 32'b0?00111100000???110?01?????????? : begin a64_to_t32 = {raw_encoding_i[18],5'b11111,raw_encoding_i[3],3'b000,raw_encoding_i[17],raw_encoding_i[16],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],3'b110,raw_encoding_i[12],1'b0,raw_encoding_i[30],2'b01,raw_encoding_i[8],raw_encoding_i[7],raw_encoding_i[6],raw_encoding_i[5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* MOVI (sm)_696  */
 32'b?0011011000?????0??????????????? : begin a64_to_t32 = {9'b110110000,raw_encoding_i[8:5],raw_encoding_i[13:10],raw_encoding_i[3:0],4'b0000,raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* MADD_86  */
 32'b11010101000000110100????11111111 : begin a64_to_t32 = {20'b10011101011111000010,raw_encoding_i[11:8],5'b00000}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* MSR DAIFClr_284  */
 32'b0?00111110??????1000?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1000,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* MUL_726  */
 32'b0?10111101??????0100?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0100,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* MLS_717  */
 32'b0?10111101??????0000?0?????????? : begin a64_to_t32 = {raw_encoding_i[30],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0000,raw_encoding_i[8],1'b1,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[11]; ccbit_d = raw_encoding_i[21]; end /* MLA_709  */
 32'b01?11110??1?????100011?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1000,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* CM{TST|EQ}_515  */
 32'b0??01110??100000100110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],4'b0001,raw_encoding_i[29],raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* CM{EQ|LE}_594  */
 32'b10011010110?????010111?????????? : begin a64_to_t32 = {9'b110101101,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b1011,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* CRC32CX_82  */
 32'b00011010110?????010010?????????? : begin a64_to_t32 = {9'b110101100,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b1010,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* CRC32W_77  */
 32'b00011010110?????010000?????????? : begin a64_to_t32 = {9'b110101100,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b1000,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* CRC32B_75  */
 32'b0?001110??100000010110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b00,raw_encoding_i[2:0],raw_encoding_i[4],5'b01010,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* CNT_587  */
 32'b00011010110?????010110?????????? : begin a64_to_t32 = {9'b110101101,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b1010,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* CRC32CW_81  */
 32'b?1011010100?????????00?????????? : begin a64_to_t32 = {9'b110100010,raw_encoding_i[8:5],4'b0010,raw_encoding_i[3:0],raw_encoding_i[15:12],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* CSINV_44  */
 32'b00011010110?????010001?????????? : begin a64_to_t32 = {9'b110101100,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b1001,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* CRC32H_76  */
 32'b0??01110??1?????001101?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0011,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* CM{GT|HI}_475  */
 32'b00011010110?????010100?????????? : begin a64_to_t32 = {9'b110101101,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b1000,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* CRC32CB_79  */
 32'b0?101110??100000010010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b00,raw_encoding_i[2:0],raw_encoding_i[4],5'b01001,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* CLZ_586  */
 32'b?101101011000000000100?????????? : begin a64_to_t32 = {9'b110101011,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b1000,raw_encoding_i[8:5]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[9]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* CLZ_64  */
 32'b0??01110??100000100010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],4'b0000,raw_encoding_i[29],raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* CM{GT|GE}_593  */
 32'b0?001110??100000010010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b00,raw_encoding_i[2:0],raw_encoding_i[4],5'b01000,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* CLS_585  */
 32'b?0011010100?????????01?????????? : begin a64_to_t32 = {9'b110100010,raw_encoding_i[8:5],4'b0001,raw_encoding_i[3:0],raw_encoding_i[15:12],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* CSINC_43  */
 32'b00011010110?????010101?????????? : begin a64_to_t32 = {9'b110101101,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b1001,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* CRC32CH_80  */
 32'b01?11110??1?????001111?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0011,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* CM{GE|HS}_509  */
 32'b?0011010100?????????00?????????? : begin a64_to_t32 = {9'b110100010,raw_encoding_i[8:5],4'b0000,raw_encoding_i[3:0],raw_encoding_i[15:12],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* CSEL_42  */
 32'b?1111010010?????????10?????0???? : begin a64_to_t32 = {9'b110100010,raw_encoding_i[8:5],4'b0111,raw_encoding_i[3:0],raw_encoding_i[15:12],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* CCMP_55  */
 32'b0?001110??100000101010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],5'b00100,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* CMLT_595  */
 32'b01011110??100000101010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],6'b001000,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* CMLT_636  */
 32'b?1111010010?????????00?????0???? : begin a64_to_t32 = {9'b110100010,raw_encoding_i[8:5],4'b0101,raw_encoding_i[3:0],raw_encoding_i[15:12],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* CCMP_50  */
 32'b?101101011000000000101?????????? : begin a64_to_t32 = {9'b110101011,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b1001,raw_encoding_i[8:5]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[9]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* CLS_65  */
 32'b10011010110?????010011?????????? : begin a64_to_t32 = {9'b110101100,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b1011,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* CRC32X_78  */
 32'b01?11110??100000100010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],4'b0000,raw_encoding_i[29],1'b0,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* CM{GT|GE}_634  */
 32'b11010101000000110011????01011111 : begin a64_to_t32 = {25'b1001110111111100011110010,raw_encoding_i[11:8]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* CLREX_286  */
 32'b0??01110??1?????001111?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0011,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* CM{GE|HS}_476  */
 32'b?0111010010?????????10?????0???? : begin a64_to_t32 = {9'b110100010,raw_encoding_i[8:5],4'b0110,raw_encoding_i[3:0],raw_encoding_i[15:12],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* CCMN_54  */
 32'b?0111010010?????????00?????0???? : begin a64_to_t32 = {9'b110100010,raw_encoding_i[8:5],4'b0100,raw_encoding_i[3:0],raw_encoding_i[15:12],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* CCMN_49  */
 32'b01?11110??1?????001101?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0011,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* CM{GT|HI}_508  */
 32'b?011010????????????????????????? : begin a64_to_t32 = {5'b10111,raw_encoding_i[24],raw_encoding_i[23:17],raw_encoding_i[3:0],raw_encoding_i[16:5]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* CB{N}Z_35  */
 32'b?1011010100?????????01?????????? : begin a64_to_t32 = {9'b110100010,raw_encoding_i[8:5],4'b0011,raw_encoding_i[3:0],raw_encoding_i[15:12],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* CSNEG_45  */
 32'b0??01110??1?????100011?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1000,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* CM{TST|EQ}_486  */
 32'b01?11110??100000100110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],4'b0001,raw_encoding_i[29],1'b0,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* CM{EQ|LE}_635  */
 32'b01011110000?????000001?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[19:16],raw_encoding_i[2:0],raw_encoding_i[4],6'b110000,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[20]; ccbit_d = 1'b0; end /* Copy (Scalar)_765  */
 32'b1011100101?????????????????????? : begin a64_to_t32 = {9'b110001101,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDR (32-bit)_191  */
 32'b10011000???????????????????????? : begin a64_to_t32 = {6'b000100,raw_encoding_i[23:17],raw_encoding_i[3:0],raw_encoding_i[16:5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* LDRSW_115  */
 32'b00111000111?????????10?????????? : begin a64_to_t32 = {9'b110010001,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b0,raw_encoding_i[12],raw_encoding_i[15:13],3'b000,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDRSB (into 32-bit)_224  */
 32'b00001000010?????0??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111101001111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDXRB_127  */
 32'b00111100110????????????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],2'b01,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],1'b1,raw_encoding_i[11],1'b0,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* LD{U}R (128-bit FP reg)_181  */
 32'b01111000110????????????????????? : begin a64_to_t32 = {9'b110010011,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LD{U}RSH (32-bit)_171  */
 32'b010011000?000000010????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],6'b001111}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* Load/store multiple (elem)_795_10  */
 32'b10001000011?????0??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],8'b01111111}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[14]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDXP_133  */
 32'b000011000?000000010????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],6'b001111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* Load/store multiple (elem)_795  */
 32'b01111000011?????????10?????????? : begin a64_to_t32 = {9'b110000011,raw_encoding_i[8:5],raw_encoding_i[3:0],2'b00,raw_encoding_i[15:13],2'b00,raw_encoding_i[12],raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDRH_217  */
 32'b0110100??1?????????????????????? : begin a64_to_t32 = {4'b0010,raw_encoding_i[24],2'b01,raw_encoding_i[23],1'b1,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],1'b1,raw_encoding_i[21:15]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[14]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDPSW_241  */
 32'b00111000010????????????????????? : begin a64_to_t32 = {9'b110000001,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LD{U}RB_162  */
 32'b01001000110?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111110011111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDARH_152  */
 32'b010011000?000000001????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],6'b001111}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* Load/store multiple (elem)_795_14  */
 32'b1011110101?????????????????????? : begin a64_to_t32 = {6'b110101,raw_encoding_i[3],2'b01,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* LDR (32-bit FP reg)_205  */
 32'b11001000011?????0??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],8'b01111111}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[14]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDXP (64-bit)_134  */
 32'b10111000011?????????10?????????? : begin a64_to_t32 = {9'b110000101,raw_encoding_i[8:5],raw_encoding_i[3:0],2'b00,raw_encoding_i[15:13],1'b0,raw_encoding_i[12],1'b0,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDR (32-bit)_218  */
 32'b010011000?0000001??????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],6'b001111}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* Load/store multiple (elem)_795_13  */
 32'b11111100010????????????????????? : begin a64_to_t32 = {6'b110001,raw_encoding_i[3],2'b11,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],1'b1,raw_encoding_i[11],1'b0,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* LD{U}R (64-bit FP reg)_179  */
 32'b00111000011?????????10?????????? : begin a64_to_t32 = {9'b110000001,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b0,raw_encoding_i[12],raw_encoding_i[15:13],3'b000,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDRB_216  */
 32'b01111000010????????????????????? : begin a64_to_t32 = {9'b110000011,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LD{U}RH_163  */
 32'b010011000?0000000111???????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],6'b001111}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* Load/store multiple (elem)_795_12  */
 32'b000011000?000000000????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],6'b001111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* Load/store multiple (elem)_795_01  */
 32'b11001000010?????0??????????????? : begin a64_to_t32 = {9'b010000101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111100000000}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDXR (64-bit)_130  */
 32'b0111110101?????????????????????? : begin a64_to_t32 = {6'b110100,raw_encoding_i[3],2'b11,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* LDR (16-bit FP reg)_204  */
 32'b10001000010?????0??????????????? : begin a64_to_t32 = {9'b010000101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111100000000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDXR_129  */
 32'b01111100010????????????????????? : begin a64_to_t32 = {6'b110000,raw_encoding_i[3],2'b11,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],1'b1,raw_encoding_i[11],1'b0,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* LD{U}R (16-bit FP reg)_177  */
 32'b0011110101?????????????????????? : begin a64_to_t32 = {6'b110100,raw_encoding_i[3],2'b01,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* LDR (8-bit FP reg)_203  */
 32'b01011000???????????????????????? : begin a64_to_t32 = {6'b000010,raw_encoding_i[23:17],raw_encoding_i[3:0],raw_encoding_i[16:5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* LDR 64-bit reg_114  */
 32'b10111000100????????????????????? : begin a64_to_t32 = {9'b110010101,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LD{U}RSW_168  */
 32'b010011000?000000000????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],6'b001111}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* Load/store multiple (elem)_795_11  */
 32'b00111000100????????????????????? : begin a64_to_t32 = {9'b110010001,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LD{U}RSB_166  */
 32'b?0011010110?????001001?????????? : begin a64_to_t32 = {9'b110100010,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b0000,raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LSRV_72  */
 32'b00111100011?????????10?????????? : begin a64_to_t32 = {6'b111000,raw_encoding_i[3],2'b01,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],1'b0,raw_encoding_i[12],raw_encoding_i[15:13],3'b000,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* LDR (8-bit FP reg)_230  */
 32'b10001000110?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111110101111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDAR_153  */
 32'b0011110111?????????????????????? : begin a64_to_t32 = {6'b110110,raw_encoding_i[3],2'b01,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* LDR (128-bit FP reg)_208  */
 32'b00001000110?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111110001111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDARB_151  */
 32'b10111100010????????????????????? : begin a64_to_t32 = {6'b110001,raw_encoding_i[3],2'b01,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],1'b1,raw_encoding_i[11],1'b0,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* LD{U}R (32-bit FP reg)_178  */
 32'b0110110??1?????????????????????? : begin a64_to_t32 = {4'b0011,raw_encoding_i[24],1'b1,raw_encoding_i[3],raw_encoding_i[23],1'b1,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[20:15],raw_encoding_i[13],1'b0,raw_encoding_i[12:10],raw_encoding_i[14]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[21]; end /* LDP (64-bit FP regs)_247  */
 32'b01111000100????????????????????? : begin a64_to_t32 = {9'b110010011,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LD{U}RSH_167  */
 32'b10111100011?????????10?????????? : begin a64_to_t32 = {6'b111001,raw_encoding_i[3],2'b01,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],2'b00,raw_encoding_i[15:13],1'b0,raw_encoding_i[12],1'b0,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* LDR (32-bit FP reg)_232  */
 32'b000011000?000000001????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],6'b001111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* Load/store multiple (elem)_795_04  */
 32'b00011100???????????????????????? : begin a64_to_t32 = {6'b000001,raw_encoding_i[3],raw_encoding_i[22:17],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[16:5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[23]; end /* LDR to FP S reg_117  */
 32'b01011100???????????????????????? : begin a64_to_t32 = {6'b000011,raw_encoding_i[3],raw_encoding_i[22:17],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[16:5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[23]; end /* LDR to FP D reg_118  */
 32'b10111000010????????????????????? : begin a64_to_t32 = {9'b110000101,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LD{U}R_164  */
 32'b01111100011?????????10?????????? : begin a64_to_t32 = {6'b111000,raw_encoding_i[3],2'b11,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],2'b00,raw_encoding_i[15:13],2'b00,raw_encoding_i[12],raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* LDR (16-bit FP reg)_231  */
 32'b0010110??1?????????????????????? : begin a64_to_t32 = {4'b0011,raw_encoding_i[24],1'b0,raw_encoding_i[3],raw_encoding_i[23],1'b1,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[20:15],raw_encoding_i[13],1'b0,raw_encoding_i[12:10],raw_encoding_i[14]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[21]; end /* LDP (32-bit FP regs)_245  */
 32'b00111100111?????????10?????????? : begin a64_to_t32 = {6'b111010,raw_encoding_i[3],2'b01,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],2'b00,raw_encoding_i[15:13],raw_encoding_i[12],2'b00,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* LDR (128-bit FP reg)_235  */
 32'b00011000???????????????????????? : begin a64_to_t32 = {6'b000000,raw_encoding_i[23:17],raw_encoding_i[3:0],raw_encoding_i[16:5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* LDR 32-bit reg_113  */
 32'b01111000101?????????10?????????? : begin a64_to_t32 = {9'b110010011,raw_encoding_i[8:5],raw_encoding_i[3:0],2'b00,raw_encoding_i[15:13],2'b00,raw_encoding_i[12],raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDRSH_221  */
 32'b000011000?0000000110???????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],6'b001111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* Load/store multiple (elem)_795_05  */
 32'b00111000110????????????????????? : begin a64_to_t32 = {9'b110010001,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LD{U}RSB (32-bit)_170  */
 32'b11001000010?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111111101111}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDAXR (64-bit)_142  */
 32'b11111000011?????????10?????????? : begin a64_to_t32 = {9'b110000111,raw_encoding_i[8:5],raw_encoding_i[3:0],2'b00,raw_encoding_i[15:13],1'b0,raw_encoding_i[12],raw_encoding_i[12],raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDR (64-bit)_219  */
 32'b0010100??1?????????????????????? : begin a64_to_t32 = {4'b0010,raw_encoding_i[24],2'b01,raw_encoding_i[23],1'b1,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],1'b0,raw_encoding_i[21:15]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[14]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDP (32-bit regs)_240  */
 32'b10001000011?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],8'b11111111}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[14]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDAXP_145  */
 32'b1010100??1?????????????????????? : begin a64_to_t32 = {4'b0010,raw_encoding_i[24],2'b11,raw_encoding_i[23],1'b1,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],1'b0,raw_encoding_i[21:15]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[14]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDP (64-bit regs)_243  */
 32'b?0011010110?????001000?????????? : begin a64_to_t32 = {9'b110100000,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b0000,raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LSLV_71  */
 32'b00111100010????????????????????? : begin a64_to_t32 = {6'b110000,raw_encoding_i[3],2'b01,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],1'b1,raw_encoding_i[11],1'b0,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* LD{U}R (8-bit FP reg)_176  */
 32'b1111100101?????????????????????? : begin a64_to_t32 = {9'b110001111,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[21:10]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDR (64-bit)_192  */
 32'b11111100011?????????10?????????? : begin a64_to_t32 = {6'b111001,raw_encoding_i[3],2'b11,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],2'b00,raw_encoding_i[15:13],1'b0,raw_encoding_i[12],raw_encoding_i[12],raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* LDR (64-bit FP reg)_233  */
 32'b000011000?0000001??????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],6'b001111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* Load/store multiple (elem)_795_03  */
 32'b0111100101?????????????????????? : begin a64_to_t32 = {9'b110001011,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDRH_190  */
 32'b000011000?0000000111???????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],6'b001111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* Load/store multiple (elem)_795_02  */
 32'b1010110??1?????????????????????? : begin a64_to_t32 = {4'b0011,raw_encoding_i[24],1'b0,raw_encoding_i[3],raw_encoding_i[23],1'b1,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[20:15],raw_encoding_i[13],1'b1,raw_encoding_i[12:10],raw_encoding_i[14]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[21]; end /* LDP (128-bit FP regs)_249  */
 32'b01001000010?????0??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111101011111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDXRH_128  */
 32'b0011100111?????????????????????? : begin a64_to_t32 = {9'b110011001,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDRSB (into 32-bit)_197  */
 32'b0011100101?????????????????????? : begin a64_to_t32 = {9'b110001001,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDRB_189  */
 32'b0111100110?????????????????????? : begin a64_to_t32 = {9'b110011011,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[21:10]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDRSH_194  */
 32'b10111000101?????????10?????????? : begin a64_to_t32 = {9'b110010101,raw_encoding_i[8:5],raw_encoding_i[3:0],2'b00,raw_encoding_i[15:13],1'b0,raw_encoding_i[12],1'b0,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDRSW_222  */
 32'b0111100111?????????????????????? : begin a64_to_t32 = {9'b110011011,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDRSH (into 32-bit)_198  */
 32'b10011100???????????????????????? : begin a64_to_t32 = {6'b000101,raw_encoding_i[3],raw_encoding_i[22:17],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[16:5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[23]; end /* LDR to FP Q reg_119  */
 32'b1111110101?????????????????????? : begin a64_to_t32 = {6'b110101,raw_encoding_i[3],2'b11,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* LDR (64-bit FP reg)_206  */
 32'b11001000110?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111110101111}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDAR (64-bit)_154  */
 32'b10001000010?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111111101111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDAXR_141  */
 32'b00111000101?????????10?????????? : begin a64_to_t32 = {9'b110010001,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b0,raw_encoding_i[12],raw_encoding_i[15:13],3'b000,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDRSB_220  */
 32'b010011000?0000000110???????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],6'b001111}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* Load/store multiple (elem)_795_15  */
 32'b01001000010?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111111011111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDAXRH_140  */
 32'b0011100110?????????????????????? : begin a64_to_t32 = {9'b110011001,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[21:10]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDRSB_193  */
 32'b01111000111?????????10?????????? : begin a64_to_t32 = {9'b110010011,raw_encoding_i[8:5],raw_encoding_i[3:0],2'b00,raw_encoding_i[15:13],2'b00,raw_encoding_i[12],raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDRSH (into 32-bit)_225  */
 32'b11111000010????????????????????? : begin a64_to_t32 = {9'b110000111,raw_encoding_i[8:5],raw_encoding_i[3:0],1'b1,raw_encoding_i[11],1'b1,raw_encoding_i[10],raw_encoding_i[19:12]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LD{U}R (64-bit)_165  */
 32'b00001000010?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],12'b111111001111}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDAXRB_139  */
 32'b1011100110?????????????????????? : begin a64_to_t32 = {9'b110011101,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[21:10]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDRSW_195  */
 32'b11001000011?????1??????????????? : begin a64_to_t32 = {9'b010001101,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[13:10],8'b11111111}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[14]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* LDAXP (64-bit)_146  */
 32'b?0001010??0????????????????????? : begin a64_to_t32 = {9'b010100000,raw_encoding_i[8:5],raw_encoding_i[15:12],raw_encoding_i[3:0],raw_encoding_i[11:10],raw_encoding_i[23:22],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* AND_260  */
 32'b0?001110??1?????101111?????????? : begin a64_to_t32 = {6'b011110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1011,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* ADDP_492  */
 32'b0100111000101000011110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],6'b110000,raw_encoding_i[2:0],raw_encoding_i[4],6'b001111,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* AESIMC_775  */
 32'b1??10000???????????????????????? : begin a64_to_t32 = {4'b1001,raw_encoding_i[30:29],raw_encoding_i[23:13],raw_encoding_i[3:0],raw_encoding_i[12:5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* ADRP_278  */
 32'b?0011010110?????001011?????????? : begin a64_to_t32 = {9'b110100110,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b0000,raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ASRV_74  */
 32'b01?11110??1?????100001?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1000,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* ADD/SUB_514  */
 32'b?0011010110?????001010?????????? : begin a64_to_t32 = {9'b110100100,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b0000,raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ASRV_73  */
 32'b?0?11010000?????000000?????????? : begin a64_to_t32 = {8'b01011010,raw_encoding_i[29],raw_encoding_i[8:5],4'b0000,raw_encoding_i[3:0],4'b0000,raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ADC (register)_25  */
 32'b0??01110??11000?????10?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],1'b1,raw_encoding_i[16],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],1'b0,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* Accross all elements_762  */
 32'b?1101010??0????????????????????? : begin a64_to_t32 = {9'b010100001,raw_encoding_i[8:5],raw_encoding_i[15:12],raw_encoding_i[3:0],raw_encoding_i[11:10],raw_encoding_i[23:22],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ANDS_266  */
 32'b?00100100??????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b000000,raw_encoding_i[8:5],1'b0,raw_encoding_i[18:16],raw_encoding_i[3:0],raw_encoding_i[20:19],raw_encoding_i[15:10]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[22]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* AND_253  */
 32'b0100111000101000010110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],6'b110000,raw_encoding_i[2:0],raw_encoding_i[4],6'b001101,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* AESD_773  */
 32'b?011000100?????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b100001,raw_encoding_i[8:5],1'b0,raw_encoding_i[20:18],raw_encoding_i[3:0],raw_encoding_i[17:10]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ADD (immediate)_13  */
 32'b?001000101?????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b100000,raw_encoding_i[8:5],1'b0,raw_encoding_i[20:18],raw_encoding_i[3:0],raw_encoding_i[17:10]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ADD (immediate)_10  */
 32'b?0?01011??0????????????????????? : begin a64_to_t32 = {8'b01011000,raw_encoding_i[29],raw_encoding_i[8:5],raw_encoding_i[15:12],raw_encoding_i[3:0],raw_encoding_i[11:10],raw_encoding_i[23:22],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ADD (register)_20  */
 32'b?0?01011001????????????????????? : begin a64_to_t32 = {8'b01011100,raw_encoding_i[29],raw_encoding_i[8:5],1'b0,raw_encoding_i[15:13],raw_encoding_i[3:0],1'b0,raw_encoding_i[12:10],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ADD (register)_4  */
 32'b0??01110??1?????000111?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0001,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* AND/BIC/ORR/ORN/EOR/BSL/BIT/BIF_472  */
 32'b0100111000101000010010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],6'b110000,raw_encoding_i[2:0],raw_encoding_i[4],6'b001100,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* AESE_772  */
 32'b?001000100?????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b100000,raw_encoding_i[8:5],1'b0,raw_encoding_i[20:18],raw_encoding_i[3:0],raw_encoding_i[17:10]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ADD (immediate)_9  */
 32'b01011110??100000101110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],6'b001100,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* ABS_637  */
 32'b0100111000101000011010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],6'b110000,raw_encoding_i[2:0],raw_encoding_i[4],6'b001110,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* AESMC_774  */
 32'b0?001110??100000101110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b01,raw_encoding_i[2:0],raw_encoding_i[4],5'b00110,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* ABS_596  */
 32'b?011000101?????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b100001,raw_encoding_i[8:5],1'b0,raw_encoding_i[20:18],raw_encoding_i[3:0],raw_encoding_i[17:10]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ADD (immediate)_14  */
 32'b0??01110??1?????100001?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1000,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* ADD/SUB_485  */
 32'b?11100100??????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b000001,raw_encoding_i[8:5],1'b0,raw_encoding_i[18:16],raw_encoding_i[3:0],raw_encoding_i[20:19],raw_encoding_i[15:10]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[22]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ANDS_256  */
 32'b0??10000???????????????????????? : begin a64_to_t32 = {4'b1000,raw_encoding_i[30:29],raw_encoding_i[23:13],raw_encoding_i[3:0],raw_encoding_i[12:5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* ADR_277  */
 32'b0?00111100000???0??101?????????? : begin a64_to_t32 = {raw_encoding_i[18],5'b11111,raw_encoding_i[3],3'b000,raw_encoding_i[17],raw_encoding_i[16],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],1'b0,raw_encoding_i[14:13],2'b10,raw_encoding_i[30],2'b01,raw_encoding_i[8],raw_encoding_i[7],raw_encoding_i[6],raw_encoding_i[5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* ORR (sl)_693  */
 32'b?0101010??0????????????????????? : begin a64_to_t32 = {9'b010100100,raw_encoding_i[8:5],raw_encoding_i[15:12],raw_encoding_i[3:0],raw_encoding_i[11:10],raw_encoding_i[23:22],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ORR_262  */
 32'b?01100100??????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b000100,raw_encoding_i[8:5],1'b0,raw_encoding_i[18:16],raw_encoding_i[3:0],raw_encoding_i[20:19],raw_encoding_i[15:10]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[22]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ORR_254  */
 32'b0?00111100000???10?101?????????? : begin a64_to_t32 = {raw_encoding_i[18],5'b11111,raw_encoding_i[3],3'b000,raw_encoding_i[17],raw_encoding_i[16],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],2'b10,raw_encoding_i[13],2'b10,raw_encoding_i[30],2'b01,raw_encoding_i[8],raw_encoding_i[7],raw_encoding_i[6],raw_encoding_i[5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* ORR (hl)_695  */
 32'b?0101010??1????????????????????? : begin a64_to_t32 = {9'b010100110,raw_encoding_i[8:5],raw_encoding_i[15:12],raw_encoding_i[3:0],raw_encoding_i[11:10],raw_encoding_i[23:22],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* ORN_263  */
 32'b0?001110??100001001010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b10,raw_encoding_i[2:0],raw_encoding_i[4],6'b001000,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* XTN_603  */
 32'b11011000???????????????????????? : begin a64_to_t32 = {6'b000110,raw_encoding_i[23:17],raw_encoding_i[3:0],raw_encoding_i[16:5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* PRFM_116  */
 32'b11111000100?????????00?????????? : begin a64_to_t32 = {9'b110010111,raw_encoding_i[8:5],raw_encoding_i[3:0],4'b1010,raw_encoding_i[19:12]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* PRFUM_169  */
 32'b0??01110??1?????100111?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1001,raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b1,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {P}MUL_488  */
 32'b0?001110111?????111000?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1110,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* PMULL_567  */
 32'b01?11110??11000?????10?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],1'b1,raw_encoding_i[16],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],2'b00,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* Pairwise_768  */
 32'b1111100110?????????????????????? : begin a64_to_t32 = {9'b110011111,raw_encoding_i[8:5],raw_encoding_i[3:0],raw_encoding_i[21:10]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* PRFM_196  */
 32'b0?001110001?????111000?????????? : begin a64_to_t32 = {6'b011111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b1110,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* PMULL_566  */
 32'b0?001110??0?????0???10?????????? : begin a64_to_t32 = {6'b011110,raw_encoding_i[3],raw_encoding_i[23:22],raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],1'b0,raw_encoding_i[14:12],raw_encoding_i[8],raw_encoding_i[30],raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* Permute_442  */
 32'b11111000101?????????10?????????? : begin a64_to_t32 = {9'b110010111,raw_encoding_i[8:5],raw_encoding_i[3:0],2'b00,raw_encoding_i[15:13],1'b0,raw_encoding_i[12],raw_encoding_i[12],raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* PRFM_223  */
 32'b?1101010??1????????????????????? : begin a64_to_t32 = {9'b010100011,raw_encoding_i[8:5],raw_encoding_i[15:12],raw_encoding_i[3:0],raw_encoding_i[11:10],raw_encoding_i[23:22],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* BICS_267  */
 32'b1101011000111111000000?????00000 : begin a64_to_t32 = {9'b101111000,raw_encoding_i[8:5],16'b1000111100000010}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* BLR_307  */
 32'b1101011000011111000000?????00000 : begin a64_to_t32 = {9'b101111000,raw_encoding_i[8:5],16'b1000111100000001}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* BR_306  */
 32'b000101?????????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[23],raw_encoding_i[20:11],2'b10,raw_encoding_i[22],1'b1,raw_encoding_i[21],raw_encoding_i[10:0]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[25]; ccbit_n = raw_encoding_i[24]; ccbit_d = 1'b0; end /* B_301  */
 32'b100101?????????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[23],raw_encoding_i[20:11],2'b11,raw_encoding_i[22],1'b1,raw_encoding_i[21],raw_encoding_i[10:0]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[25]; ccbit_n = raw_encoding_i[24]; ccbit_d = 1'b0; end /* BL_302  */
 32'b0?10111100000???0??101?????????? : begin a64_to_t32 = {raw_encoding_i[18],5'b11111,raw_encoding_i[3],3'b000,raw_encoding_i[17],raw_encoding_i[16],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],1'b0,raw_encoding_i[14:13],2'b10,raw_encoding_i[30],2'b11,raw_encoding_i[8],raw_encoding_i[7],raw_encoding_i[6],raw_encoding_i[5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* BIC (sl)_699  */
 32'b11010100001????????????????00000 : begin a64_to_t32 = {5'b00000,raw_encoding_i[20:13],8'b10111110,raw_encoding_i[12:5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* BRK_100  */
 32'b0?10111100000???10?101?????????? : begin a64_to_t32 = {raw_encoding_i[18],5'b11111,raw_encoding_i[3],3'b000,raw_encoding_i[17],raw_encoding_i[16],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],2'b10,raw_encoding_i[13],2'b10,raw_encoding_i[30],2'b11,raw_encoding_i[8],raw_encoding_i[7],raw_encoding_i[6],raw_encoding_i[5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* BIC (hl)_701  */
 32'b01010100???????????????????0???? : begin a64_to_t32 = {6'b101100,raw_encoding_i[23:17],raw_encoding_i[3:0],raw_encoding_i[16:5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* B (cond)_38  */
 32'b?0001010??1????????????????????? : begin a64_to_t32 = {9'b010100010,raw_encoding_i[8:5],raw_encoding_i[15:12],raw_encoding_i[3:0],raw_encoding_i[11:10],raw_encoding_i[23:22],raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* BIC_261  */
 32'b?01100110??????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b110110,raw_encoding_i[8:5],1'b0,raw_encoding_i[20:18],raw_encoding_i[3:0],raw_encoding_i[17:16],raw_encoding_i[15:10]}; ccbit_sf = raw_encoding_i[22]; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* BFM_31  */
 32'b000011001?0?????1??????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],2'b00,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b1; end /* load/store (elem-post)_796_03  */
 32'b010011001?0?????0111???????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],2'b00,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b1; end /* load/store (elem-post)_796_12  */
 32'b010011001?0?????001????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],2'b00,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b1; end /* load/store (elem-post)_796_14  */
 32'b000011001?0?????001????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],2'b00,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b1; end /* load/store (elem-post)_796_04  */
 32'b000011001?0?????0110???????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],2'b00,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b1; end /* load/store (elem-post)_796_05  */
 32'b0?0011011??????????????????????? : begin a64_to_t32 = {6'b110011,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:13],raw_encoding_i[21],raw_encoding_i[11:10],raw_encoding_i[12],1'b0,raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[30]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b1; end /* load/store (one-post)_798  */
 32'b0?0011010??00000???????????????? : begin a64_to_t32 = {6'b110011,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:13],raw_encoding_i[21],raw_encoding_i[11:10],raw_encoding_i[12],5'b01111}; ccbit_sf = raw_encoding_i[30]; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* load/store (one)_797  */
 32'b010011001?0?????0110???????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],2'b00,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b1; end /* load/store (elem-post)_796_15  */
 32'b000011001?0?????0111???????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],2'b00,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b1; end /* load/store (elem-post)_796_02  */
 32'b010011001?0?????000????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],2'b00,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b1; end /* load/store (elem-post)_796_11  */
 32'b000011001?0?????000????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],2'b00,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b1; end /* load/store (elem-post)_796_01  */
 32'b010011001?0?????1??????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],2'b00,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b1; end /* load/store (elem-post)_796_13  */
 32'b010011001?0?????010????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],2'b00,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b1; end /* load/store (elem-post)_796_10  */
 32'b000011001?0?????010????????????? : begin a64_to_t32 = {6'b110010,raw_encoding_i[3],raw_encoding_i[22],1'b0,raw_encoding_i[8:5],raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[15:12],raw_encoding_i[11:10],2'b00,raw_encoding_i[19:16]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b1; end /* load/store (elem-post)_796  */
 32'b11010100010????????????????00000 : begin a64_to_t32 = {3'b000,raw_encoding_i[20:11],10'b1011101010,raw_encoding_i[10:5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* HLT_101  */
 32'b11010100000????????????????00010 : begin a64_to_t32 = {9'b101111110,raw_encoding_i[20:17],4'b1000,raw_encoding_i[16:5]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* HVC_98  */
 32'b11010101000000110010???????11111 : begin a64_to_t32 = {22'b1001110101111100000000,raw_encoding_i[11:8],raw_encoding_i[7:5]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* HINT_285  */
 32'b11010100101????????????????00001 : begin a64_to_t32 = {29'b10111100011111000000000000001}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* DCPS1_102  */
 32'b0?001110000?1000000011?????????? : begin a64_to_t32 = {7'b0111011,raw_encoding_i[30],1'b0,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1011,raw_encoding_i[3],7'b0110000}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* DUP (dword from ARM)_453  */
 32'b0?001110000???10000011?????????? : begin a64_to_t32 = {7'b0111010,raw_encoding_i[30],1'b0,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1011,raw_encoding_i[3],7'b0110000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* DUP (hword from ARM)_451  */
 32'b11010100101????????????????00011 : begin a64_to_t32 = {29'b10111100011111000000000000011}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* DCPS3_104  */
 32'b11010101000000110011????10111111 : begin a64_to_t32 = {25'b1001110111111100011110101,raw_encoding_i[11:8]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* DMB_288  */
 32'b0?001110000????1000011?????????? : begin a64_to_t32 = {7'b0111011,raw_encoding_i[30],1'b0,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1011,raw_encoding_i[3],7'b0010000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* DUP (byte from ARM)_450  */
 32'b0?001110000??100000011?????????? : begin a64_to_t32 = {7'b0111010,raw_encoding_i[30],1'b0,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1011,raw_encoding_i[3],7'b0010000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* DUP (word from ARM)_452  */
 32'b11010100101????????????????00010 : begin a64_to_t32 = {29'b10111100011111000000000000010}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* DCPS2_103  */
 32'b11010110101111110000001111100000 : begin a64_to_t32 = {29'b10011110111111000111100000000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* DRPS_310  */
 32'b11010101000000110011????10011111 : begin a64_to_t32 = {25'b1001110111111100011110100,raw_encoding_i[11:8]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* DSB_287  */
 32'b0?001110000?????000001?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[19:16],raw_encoding_i[2:0],raw_encoding_i[4],5'b11000,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[20]; ccbit_d = 1'b0; end /* DUP_449  */
 32'b0?10111001100000010110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],6'b110100,raw_encoding_i[2:0],raw_encoding_i[4],5'b01011,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* RBIT_589  */
 32'b0?001110??100000000110?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b00,raw_encoding_i[2:0],raw_encoding_i[4],5'b00010,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* REV16_582  */
 32'b1101011001011111000000?????00000 : begin a64_to_t32 = {9'b101111000,raw_encoding_i[8:5],16'b1000111100000000}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = 1'b0; end /* RET_308  */
 32'b0??01110101?????011000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0110,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {R}SUBHN_547  */
 32'b1101101011000000000011?????????? : begin a64_to_t32 = {9'b110101001,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b1011,raw_encoding_i[8:5]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[9]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* REV (64-bit regs)_63  */
 32'b0??01110011?????011000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0110,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {R}SUBHN_546  */
 32'b0??01110011?????010000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b01,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0100,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {R}ADDHN_540  */
 32'b?101101011000000000001?????????? : begin a64_to_t32 = {9'b110101001,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b1001,raw_encoding_i[8:5]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[9]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* REV16_60  */
 32'b0?001110??100000000010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b00,raw_encoding_i[2:0],raw_encoding_i[4],5'b00000,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* REV64_580  */
 32'b?101101011000000000000?????????? : begin a64_to_t32 = {9'b110101001,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b1010,raw_encoding_i[8:5]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[9]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* RBIT_59  */
 32'b0101101011000000000010?????????? : begin a64_to_t32 = {9'b110101001,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b1000,raw_encoding_i[8:5]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[9]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* REV (32-bit regs)_61  */
 32'b0??01110001?????010000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0100,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {R}ADDHN_539  */
 32'b1101101011000000000010?????????? : begin a64_to_t32 = {9'b110101001,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b1000,raw_encoding_i[8:5]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[9]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* REV32_62  */
 32'b0?101110??100000000010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],2'b11,raw_encoding_i[23:22],2'b00,raw_encoding_i[2:0],raw_encoding_i[4],5'b00001,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* REV32_581  */
 32'b0??01110001?????011000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b00,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0110,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {R}SUBHN_545  */
 32'b0??01110101?????010000?????????? : begin a64_to_t32 = {raw_encoding_i[29],5'b11111,raw_encoding_i[3],2'b10,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[2:0],raw_encoding_i[4],4'b0100,raw_encoding_i[8],1'b0,raw_encoding_i[19],1'b0,raw_encoding_i[18:16],raw_encoding_i[20]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[30]; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* {R}ADDHN_541  */
 32'b01001110000???10000111?????????? : begin a64_to_t32 = {7'b0111000,raw_encoding_i[19],1'b0,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1011,raw_encoding_i[3],raw_encoding_i[18],6'b110000}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* INS (hword from ARM)_455  */
 32'b01001110000??100000111?????????? : begin a64_to_t32 = {7'b0111000,raw_encoding_i[19],1'b0,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1011,raw_encoding_i[3],7'b0010000}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* INS (word from ARM)_456  */
 32'b01001110000????1000111?????????? : begin a64_to_t32 = {7'b0111001,raw_encoding_i[19],1'b0,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1011,raw_encoding_i[3],raw_encoding_i[18],raw_encoding_i[17],5'b10000}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* INS (byte from ARM)_454  */
 32'b01101110000?????0????1?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[13],2'b11,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[19:16],3'b111,raw_encoding_i[12],raw_encoding_i[3],raw_encoding_i[11],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[14]; ccbit_d = 1'b0; end /* INS (from vector)_465  */
 32'b11010101000000110011????11011111 : begin a64_to_t32 = {25'b1001110111111100011110110,raw_encoding_i[11:8]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* ISB_289  */
 32'b01001110000?1000000111?????????? : begin a64_to_t32 = {9'b011100010,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1011,raw_encoding_i[3],7'b1010000}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* INS (dword from ARM)_457  */
 32'b00001110000??100001111?????????? : begin a64_to_t32 = {7'b0111010,raw_encoding_i[19],1'b1,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1011,raw_encoding_i[8],7'b0010000}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* UMOV (word)_463  */
 32'b10011011101?????0??????????????? : begin a64_to_t32 = {9'b110111110,raw_encoding_i[8:5],raw_encoding_i[13:10],raw_encoding_i[3:0],4'b0001,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* UMADDL_91  */
 32'b0?0011101?100001110010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b11,raw_encoding_i[2:0],raw_encoding_i[4],5'b01000,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* URECPE_623  */
 32'b?001111001000011???????????????? : begin a64_to_t32 = {9'b011100010,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],raw_encoding_i[15],raw_encoding_i[10],1'b1,raw_encoding_i[14:11]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* UCVTF_413  */
 32'b0?1011101?100001110010?????????? : begin a64_to_t32 = {6'b111111,raw_encoding_i[3],3'b111,raw_encoding_i[22],2'b11,raw_encoding_i[2:0],raw_encoding_i[4],5'b01001,raw_encoding_i[30],raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* URSQRTE_624  */
 32'b01001110000?1000001111?????????? : begin a64_to_t32 = {9'b011101011,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1011,raw_encoding_i[8],7'b1010000}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* UMOV (dword)_464  */
 32'b00001110000???10001111?????????? : begin a64_to_t32 = {7'b0111010,raw_encoding_i[19],1'b1,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1011,raw_encoding_i[8],raw_encoding_i[18],6'b110000}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* UMOV (hword)_462  */
 32'b?001111000000011???????????????? : begin a64_to_t32 = {9'b011100010,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],raw_encoding_i[15],raw_encoding_i[10],1'b1,raw_encoding_i[14:11]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* UCVTF_409  */
 32'b?001111001100011000000?????????? : begin a64_to_t32 = {9'b011100110,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],7'b0010000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b1; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* UCVTF_428  */
 32'b?10100110??????????????????????? : begin a64_to_t32 = {2'b10,raw_encoding_i[21],6'b111100,raw_encoding_i[8:5],1'b0,raw_encoding_i[20:18],raw_encoding_i[3:0],raw_encoding_i[17:16],raw_encoding_i[15:10]}; ccbit_sf = raw_encoding_i[22]; ccbit_m = 1'b0; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* UBFM_32  */
 32'b00001110000????1001111?????????? : begin a64_to_t32 = {7'b0111011,raw_encoding_i[19],1'b1,raw_encoding_i[7:5],raw_encoding_i[9],raw_encoding_i[3:0],4'b1011,raw_encoding_i[8],raw_encoding_i[18],raw_encoding_i[17],5'b10000}; ccbit_sf = 1'b0; ccbit_m = raw_encoding_i[20]; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[4]; end /* UMOV (byte)_461  */
 32'b?0011010110?????000010?????????? : begin a64_to_t32 = {9'b110111011,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b1111,raw_encoding_i[19:16]}; ccbit_sf = raw_encoding_i[31]; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* UDIV_69  */
 32'b10011011101?????1??????????????? : begin a64_to_t32 = {9'b110111111,raw_encoding_i[8:5],raw_encoding_i[13:10],raw_encoding_i[3:0],4'b0001,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* UMSUBL_92  */
 32'b10011011110?????0??????????????? : begin a64_to_t32 = {9'b110111110,raw_encoding_i[8:5],4'b1111,raw_encoding_i[3:0],4'b0010,raw_encoding_i[19:16]}; ccbit_sf = 1'b1; ccbit_m = raw_encoding_i[20]; ccbit_n = raw_encoding_i[9]; ccbit_d = raw_encoding_i[4]; end /* UMULH_93  */
 32'b?001111000100011000000?????????? : begin a64_to_t32 = {9'b011100110,raw_encoding_i[2:0],raw_encoding_i[4],raw_encoding_i[8:5],4'b1010,raw_encoding_i[3],7'b0010000}; ccbit_sf = raw_encoding_i[31]; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = raw_encoding_i[9]; end /* UCVTF_420  */
 32'b011111100?100001110110?????????? : begin a64_to_t32 = {6'b011101,raw_encoding_i[3],6'b111000,raw_encoding_i[2:0],raw_encoding_i[4],3'b101,raw_encoding_i[22],2'b01,raw_encoding_i[8],1'b0,raw_encoding_i[7:5],raw_encoding_i[9]}; ccbit_sf = 1'b1; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end /* UCVTF_656  */
      default : begin a64_to_t32 = {29{1'b0}}; ccbit_sf = 1'b0; ccbit_m = 1'b0; ccbit_n = 1'b0; ccbit_d = 1'b0; end
    endcase

  wire   net_0_1, net_0_2, net_0_3, net_0_4, net_0_6, net_0_7, net_0_8, net_0_9, net_0_10,
         net_0_11, net_0_12, net_0_13, net_0_14, net_0_15, net_0_16, net_0_17, net_0_18,
         net_0_19, net_0_20, net_0_21, net_0_22, net_0_23, net_0_24, net_0_25, net_0_26,
         net_0_27, net_0_28, net_0_29, net_0_30, net_0_31, net_0_32, net_0_33, net_0_34,
         net_0_35, net_0_36, net_0_37, net_0_38, net_0_39, net_0_40, net_0_41, net_0_42,
         net_0_43, net_0_44, net_0_45, net_0_46, net_0_47, net_0_48, net_0_49, net_0_50,
         net_0_56, net_0_57, net_0_58, net_0_59, net_0_60, net_0_61, net_0_62, net_0_63,
         net_0_64, net_0_65, net_0_66, net_0_67, net_0_68, net_0_69, net_0_70, net_0_71,
         net_0_72, net_0_73, net_0_74, net_0_75, net_0_76, net_0_77, net_0_78, net_0_79,
         net_0_80, net_0_81, net_0_82, net_0_83, net_0_84, net_0_85, net_0_86, net_0_87,
         net_0_88, net_0_89, net_0_90, net_0_91, net_0_92, net_0_93, net_0_94;

  assign net_0_1 = ~raw_encoding_i[31];
  assign net_0_2 = ~raw_encoding_i[30];
  assign net_0_3 = ~raw_encoding_i[28];
  assign net_0_4 = ~raw_encoding_i[24];
  assign net_0_6 = ~raw_encoding_i[11];
  assign a64_only = ~(net_0_7 & net_0_8);
  assign net_0_8 = ~(raw_encoding_i[26] & net_0_9);
  assign net_0_9 = ~(net_0_10 & net_0_11);
  assign net_0_11 = (raw_encoding_i[27] | net_0_12);
  assign net_0_12 = ~(raw_encoding_i[29] & net_0_13);
  assign net_0_10 = ~(net_0_14 & net_0_15);
  assign net_0_15 = (net_0_1 & raw_encoding_i[27]);
  assign net_0_14 = ~(net_0_16 & net_0_17);
  assign net_0_17 = (raw_encoding_i[24] | net_0_18);
  assign net_0_18 = (net_0_19 | net_0_20);
  assign net_0_20 = (net_0_21 & net_0_22);
  assign net_0_22 = ~(net_0_23 & net_0_24);
  assign net_0_24 = ~(net_0_25 | raw_encoding_i[19]);
  assign net_0_25 = ~(raw_encoding_i[21] & net_0_26);
  assign net_0_26 = ~(raw_encoding_i[17] | raw_encoding_i[18]);
  assign net_0_23 = ~(net_0_27 & net_0_28);
  assign net_0_28 = (net_0_29 | net_0_13);
  assign net_0_29 = ~(raw_encoding_i[25] & net_0_30);
  assign net_0_30 = (raw_encoding_i[20] | net_0_31);
  assign net_0_31 = ~(raw_encoding_i[15] | net_0_32);
  assign net_0_32 = ~(net_0_33 & net_0_34);
  assign net_0_34 = ~(raw_encoding_i[14] | raw_encoding_i[16]);
  assign net_0_33 = (raw_encoding_i[12] & raw_encoding_i[13]);
  assign net_0_27 = ~(raw_encoding_i[15] & net_0_35);
  assign net_0_35 = (net_0_36 & net_0_37);
  assign net_0_37 = (raw_encoding_i[16] & raw_encoding_i[12]);
  assign net_0_36 = (raw_encoding_i[23] & net_0_38);
  assign net_0_38 = ~(net_0_39 & net_0_40);
  assign net_0_40 = ~(net_0_41 & net_0_42);
  assign net_0_42 = ~(raw_encoding_i[14] ^ raw_encoding_i[13]);
  assign net_0_39 = ~(raw_encoding_i[14] & net_0_43);
  assign net_0_43 = ~(raw_encoding_i[29] | net_0_44);
  assign net_0_44 = ~(raw_encoding_i[13] & net_0_45);
  assign net_0_45 = ~(net_0_3 | net_0_2);
  assign net_0_21 = (raw_encoding_i[29] | net_0_46);
  assign net_0_46 = (net_0_47 | raw_encoding_i[15]);
  assign net_0_47 = ~(raw_encoding_i[25] & net_0_48);
  assign net_0_48 = ~(raw_encoding_i[21] | raw_encoding_i[28]);
  assign net_0_16 = (net_0_49 & net_0_50);
  assign net_0_13 = (net_0_2 & raw_encoding_i[28]);
  assign net_0_49 = ~(net_0_41 & net_0_57);
  assign net_0_57 = ~(raw_encoding_i[25] & net_0_58);
  assign net_0_58 = (net_0_59 | net_0_56);
  assign net_0_56 = ~(raw_encoding_i[10] & net_0_60);
  assign net_0_59 = ~(net_0_61 & net_0_62);
  assign net_0_62 = (raw_encoding_i[14] & raw_encoding_i[15]);
  assign net_0_61 = (net_0_63 & net_0_64);
  assign net_0_64 = ~(raw_encoding_i[13] ^ raw_encoding_i[12]);
  assign net_0_63 = (net_0_65 & net_0_66);
  assign net_0_66 = ~(raw_encoding_i[13] & raw_encoding_i[23]);
  assign net_0_65 = ~(raw_encoding_i[13] ^ raw_encoding_i[11]);
  assign net_0_41 = (raw_encoding_i[29] & net_0_3);
  assign net_0_7 = (raw_encoding_i[25] | net_0_67);
  assign net_0_67 = (net_0_68 & net_0_69);
  assign net_0_69 = ~(net_0_70 & raw_encoding_i[29]);
  assign net_0_70 = (raw_encoding_i[27] & net_0_71);
  assign net_0_71 = ~(net_0_72 & net_0_73);
  assign net_0_73 = ~(net_0_74 & net_0_75);
  assign net_0_75 = (raw_encoding_i[26] & net_0_76);
  assign net_0_76 = ~(net_0_60 & net_0_19);
  assign net_0_19 = (raw_encoding_i[10] | net_0_6);
  assign net_0_60 = (raw_encoding_i[21] & net_0_4);
  assign net_0_74 = ~(net_0_77 & net_0_78);
  assign net_0_78 = ~(net_0_2 & net_0_1);
  assign net_0_77 = (raw_encoding_i[23] | net_0_3);
  assign net_0_72 = (raw_encoding_i[28] | net_0_79);
  assign net_0_79 = (raw_encoding_i[30] & net_0_80);
  assign net_0_80 = ~(raw_encoding_i[22] & net_0_1);
  assign net_0_68 = ~(raw_encoding_i[28] & net_0_81);
  assign net_0_81 = ~(raw_encoding_i[24] | net_0_82);
  assign net_0_82 = ~(net_0_83 & net_0_84);
  assign net_0_84 = ~(raw_encoding_i[26] & net_0_85);
  assign net_0_85 = (net_0_86 | raw_encoding_i[29]);
  assign net_0_86 = ~(net_0_87 & net_0_88);
  assign net_0_88 = (net_0_89 | raw_encoding_i[27]);
  assign net_0_89 = ~(net_0_2 | raw_encoding_i[4]);
  assign net_0_87 = (net_0_1 | net_0_2);
  assign net_0_83 = ~(raw_encoding_i[29] & raw_encoding_i[27]);
  assign net_0_90 = (raw_encoding_i[11] | net_0_56);
  assign net_0_91 = ~(raw_encoding_i[24] & raw_encoding_i[25]);
  assign net_0_92 = (net_0_90 & net_0_91);
  assign net_0_93 = ~(net_0_92 | raw_encoding_i[23]);
  assign net_0_94 = ~(net_0_13 & net_0_93);
  assign net_0_50 = (raw_encoding_i[29] | net_0_94);

  wire   net_1_1, net_1_2, net_1_3, net_1_4, net_1_5, net_1_6, net_1_8, net_1_9, net_1_10,
         net_1_11, net_1_12, net_1_13, net_1_14, net_1_15, net_1_16, net_1_17, net_1_18,
         net_1_19, net_1_21, net_1_22, net_1_23, net_1_24, net_1_25, net_1_27, net_1_28,
         net_1_29, net_1_30, net_1_31, net_1_32, net_1_33, net_1_34, net_1_35, net_1_36,
         net_1_37, net_1_38, net_1_39, net_1_40, net_1_41, net_1_42, net_1_43, net_1_44,
         net_1_45, net_1_46, net_1_47, net_1_48, net_1_49, net_1_50, net_1_51, net_1_52,
         net_1_53, net_1_54, net_1_55, net_1_56, net_1_57, net_1_58, net_1_59, net_1_60,
         net_1_61, net_1_62, net_1_63, net_1_64, net_1_65, net_1_66, net_1_67, net_1_68,
         net_1_69, net_1_70, net_1_71, net_1_72, net_1_73, net_1_74, net_1_75, net_1_76,
         net_1_77, net_1_78, net_1_79, net_1_80, net_1_81, net_1_82, net_1_83, net_1_84,
         net_1_85, net_1_86, net_1_87, net_1_88, net_1_89, net_1_90, net_1_91, net_1_92,
         net_1_93, net_1_94, net_1_95, net_1_96, net_1_97, net_1_98, net_1_99, net_1_100,
         net_1_101, net_1_102, net_1_103, net_1_104, net_1_105, net_1_106, net_1_107,
         net_1_108, net_1_109, net_1_110, net_1_111, net_1_112, net_1_113, net_1_114,
         net_1_115, net_1_116, net_1_117, net_1_118, net_1_119, net_1_120, net_1_121,
         net_1_122, net_1_123, net_1_124, net_1_125, net_1_126, net_1_127, net_1_128,
         net_1_129, net_1_130, net_1_131, net_1_132, net_1_133, net_1_134, net_1_135,
         net_1_136, net_1_137, net_1_138, net_1_139, net_1_140, net_1_141, net_1_142,
         net_1_143, net_1_144, net_1_145, net_1_146, net_1_147, net_1_148, net_1_149,
         net_1_150, net_1_151, net_1_152, net_1_153, net_1_154, net_1_155, net_1_156,
         net_1_157, net_1_158, net_1_159, net_1_160, net_1_161, net_1_162, net_1_163,
         net_1_164, net_1_165, net_1_166, net_1_167, net_1_168, net_1_169, net_1_170,
         net_1_171, net_1_172, net_1_173, net_1_174, net_1_175, net_1_176, net_1_177,
         net_1_178, net_1_179, net_1_180, net_1_181, net_1_182, net_1_183, net_1_184,
         net_1_185, net_1_186, net_1_187, net_1_188, net_1_189, net_1_190, net_1_191,
         net_1_192, net_1_193, net_1_194, net_1_195, net_1_196, net_1_197, net_1_198,
         net_1_199, net_1_200, net_1_201, net_1_202, net_1_203, net_1_204, net_1_205,
         net_1_206, net_1_207, net_1_208, net_1_209, net_1_210, net_1_211, net_1_212,
         net_1_213, net_1_214, net_1_215, net_1_216, net_1_217, net_1_218, net_1_219,
         net_1_220, net_1_221, net_1_222, net_1_223, net_1_224, net_1_225, net_1_226,
         net_1_227, net_1_228, net_1_229, net_1_230, net_1_231, net_1_232, net_1_233,
         net_1_234, net_1_235, net_1_236, net_1_237, net_1_238, net_1_239, net_1_240,
         net_1_241, net_1_242, net_1_243, net_1_244, net_1_245, net_1_246, net_1_247,
         net_1_248, net_1_249, net_1_250, net_1_251, net_1_252, net_1_253, net_1_254,
         net_1_255, net_1_256, net_1_257, net_1_258, net_1_259, net_1_260, net_1_261,
         net_1_262, net_1_263, net_1_264, net_1_265, net_1_266, net_1_267, net_1_268,
         net_1_269, net_1_270, net_1_271, net_1_272, net_1_273, net_1_274, net_1_275,
         net_1_276, net_1_277, net_1_278, net_1_279, net_1_280, net_1_281, net_1_282,
         net_1_283, net_1_284, net_1_285, net_1_286, net_1_287, net_1_288, net_1_289,
         net_1_290, net_1_291, net_1_292, net_1_293, net_1_294, net_1_295, net_1_296,
         net_1_297, net_1_298, net_1_299, net_1_300, net_1_301, net_1_302, net_1_303,
         net_1_304, net_1_305, net_1_306, net_1_307, net_1_308, net_1_309, net_1_310,
         net_1_311, net_1_312, net_1_313, net_1_314, net_1_315, net_1_316, net_1_317,
         net_1_318, net_1_319, net_1_320, net_1_321, net_1_322, net_1_323, net_1_324,
         net_1_325, net_1_326, net_1_327, net_1_328, net_1_329, net_1_330, net_1_331,
         net_1_332, net_1_333, net_1_334, net_1_335, net_1_336, net_1_337, net_1_338,
         net_1_339, net_1_340, net_1_341, net_1_342, net_1_343, net_1_344, net_1_345,
         net_1_346, net_1_347, net_1_348, net_1_349, net_1_350, net_1_351, net_1_352,
         net_1_353, net_1_354, net_1_355, net_1_356, net_1_357, net_1_358, net_1_359,
         net_1_360, net_1_361, net_1_362, net_1_363, net_1_364, net_1_365, net_1_366,
         net_1_367, net_1_368, net_1_369, net_1_370, net_1_371, net_1_372, net_1_374,
         net_1_393, net_1_394, net_1_395, net_1_396, net_1_397, net_1_398, net_1_399,
         net_1_400, net_1_401, net_1_402, net_1_403, net_1_404, net_1_405, net_1_406,
         net_1_407, net_1_408, net_1_409, net_1_410, net_1_411, net_1_412, net_1_413,
         net_1_414, net_1_415, net_1_416, net_1_417, net_1_418, net_1_419, net_1_420,
         net_1_421, net_1_422, net_1_423, net_1_424, net_1_425, net_1_426, net_1_427,
         net_1_428, net_1_429, net_1_430, net_1_431, net_1_432, net_1_433, net_1_434,
         net_1_435, net_1_436, net_1_437, net_1_438, net_1_439, net_1_440, net_1_441,
         net_1_442, net_1_443, net_1_444, net_1_445, net_1_446, net_1_447, net_1_448,
         net_1_449, net_1_450, net_1_451, net_1_452, net_1_453, net_1_454, net_1_455,
         net_1_456, net_1_457, net_1_458, net_1_459, net_1_460, net_1_461, net_1_462,
         net_1_463, net_1_464, net_1_465, net_1_466, net_1_467, net_1_468, net_1_469,
         net_1_470, net_1_471, net_1_472, net_1_473, net_1_474, net_1_475, net_1_476,
         net_1_477, net_1_478, net_1_479, net_1_480, net_1_481, net_1_482, net_1_483,
         net_1_484, net_1_485, net_1_486, net_1_487, net_1_488, net_1_489, net_1_490,
         net_1_491, net_1_492, net_1_493, net_1_494, net_1_495, net_1_496, net_1_497,
         net_1_498, net_1_499, net_1_500, net_1_501, net_1_502, net_1_503, net_1_504,
         net_1_505, net_1_506, net_1_507, net_1_508, net_1_509, net_1_510, net_1_511,
         net_1_512, net_1_513, net_1_514, net_1_515, net_1_516, net_1_517, net_1_518,
         net_1_519, net_1_520, net_1_521, net_1_522, net_1_523, net_1_524, net_1_525,
         net_1_526, net_1_527, net_1_528, net_1_529, net_1_530, net_1_531, net_1_532,
         net_1_533, net_1_534, net_1_535, net_1_536, net_1_537, net_1_538, net_1_539,
         net_1_540, net_1_541, net_1_542, net_1_543, net_1_544, net_1_545, net_1_546,
         net_1_547, net_1_548, net_1_549, net_1_550, net_1_551, net_1_552, net_1_553,
         net_1_554, net_1_555, net_1_556, net_1_557, net_1_558, net_1_559, net_1_560,
         net_1_561, net_1_562, net_1_563, net_1_564, net_1_565, net_1_566, net_1_567,
         net_1_568, net_1_569, net_1_570, net_1_571, net_1_572, net_1_573, net_1_574,
         net_1_575, net_1_576, net_1_577, net_1_578, net_1_579, net_1_580, net_1_581,
         net_1_582, net_1_583, net_1_584, net_1_585, net_1_586, net_1_587, net_1_588,
         net_1_589, net_1_590, net_1_591, net_1_592, net_1_593, net_1_594, net_1_606,
         net_1_610, net_1_611, net_1_612, net_1_613, net_1_614, net_1_615, net_1_616,
         net_1_617, net_1_618, net_1_619, net_1_620, net_1_621, net_1_622, net_1_623,
         net_1_624, net_1_625, net_1_626, net_1_627, net_1_628, net_1_629, net_1_630,
         net_1_631, net_1_632, net_1_633, net_1_634, net_1_635, net_1_636, net_1_637,
         net_1_638, net_1_639, net_1_640, net_1_641, net_1_642, net_1_643, net_1_644,
         net_1_645, net_1_646, net_1_647, net_1_648, net_1_649, net_1_650, net_1_651,
         net_1_652, net_1_653, net_1_654, net_1_655, net_1_656, net_1_657, net_1_658,
         net_1_659, net_1_660, net_1_661, net_1_662, net_1_663, net_1_664, net_1_665,
         net_1_666, net_1_667, net_1_668, net_1_669, net_1_670, net_1_671, net_1_672,
         net_1_673, net_1_674, net_1_675, net_1_676, net_1_690, net_1_693, net_1_694,
         net_1_695, net_1_696, net_1_697, net_1_698, net_1_699, net_1_700, net_1_701,
         net_1_702, net_1_703, net_1_704, net_1_705, net_1_706, net_1_707, net_1_708,
         net_1_709, net_1_710, net_1_711, net_1_712, net_1_713, net_1_714, net_1_715,
         net_1_716, net_1_717, net_1_718, net_1_719, net_1_720, net_1_721, net_1_722,
         net_1_723, net_1_724, net_1_725, net_1_726, net_1_727, net_1_728, net_1_729,
         net_1_730, net_1_731, net_1_732, net_1_733, net_1_734, net_1_735, net_1_736,
         net_1_737, net_1_738, net_1_739, net_1_740, net_1_741, net_1_742, net_1_743,
         net_1_744, net_1_745, net_1_746, net_1_747, net_1_748, net_1_749, net_1_750,
         net_1_751, net_1_752, net_1_753, net_1_754, net_1_755, net_1_756, net_1_757,
         net_1_758, net_1_759, net_1_760, net_1_761, net_1_775, net_1_776, net_1_777,
         net_1_778, net_1_779, net_1_780, net_1_781, net_1_782, net_1_783, net_1_784,
         net_1_785, net_1_786, net_1_787, net_1_788, net_1_789, net_1_790, net_1_791,
         net_1_792, net_1_793, net_1_794, net_1_795, net_1_796, net_1_797, net_1_798,
         net_1_799, net_1_800, net_1_801, net_1_802, net_1_803, net_1_804, net_1_805,
         net_1_806, net_1_807, net_1_808, net_1_809, net_1_810, net_1_811, net_1_812,
         net_1_813, net_1_814, net_1_815, net_1_816, net_1_817, net_1_818, net_1_819,
         net_1_820, net_1_821, net_1_822, net_1_823, net_1_824, net_1_825, net_1_826,
         net_1_827, net_1_828, net_1_829, net_1_830, net_1_831, net_1_832, net_1_833,
         net_1_834, net_1_835, net_1_836, net_1_837, net_1_838, net_1_839, net_1_840,
         net_1_841, net_1_842, net_1_843, net_1_844, net_1_845, net_1_846, net_1_847,
         net_1_848, net_1_849, net_1_850, net_1_851, net_1_852, net_1_853, net_1_854,
         net_1_855, net_1_856, net_1_857, net_1_858, net_1_859, net_1_860, net_1_861,
         net_1_862, net_1_863, net_1_864, net_1_865, net_1_866, net_1_867, net_1_868,
         net_1_869, net_1_870, net_1_871, net_1_872, net_1_873, net_1_874, net_1_875,
         net_1_876, net_1_877, net_1_878, net_1_879, net_1_880, net_1_881, net_1_882,
         net_1_883, net_1_884, net_1_885, net_1_886, net_1_887, net_1_888, net_1_889,
         net_1_890, net_1_891, net_1_892, net_1_893, net_1_894, net_1_895, net_1_896,
         net_1_897, net_1_898, net_1_899, net_1_900, net_1_901, net_1_902, net_1_903,
         net_1_904, net_1_905, net_1_906, net_1_907, net_1_908, net_1_909;

  assign net_1_1 = ~raw_encoding_i[31];
  assign net_1_2 = ~raw_encoding_i[29];
  assign net_1_3 = ~raw_encoding_i[26];
  assign net_1_4 = ~net_1_431;
  assign net_1_5 = ~net_1_117;
  assign net_1_6 = ~net_1_144;
  assign net_1_8 = ~raw_encoding_i[23];
  assign net_1_9 = ~net_1_216;
  assign net_1_10 = ~raw_encoding_i[22];
  assign net_1_11 = ~raw_encoding_i[21];
  assign net_1_12 = ~net_1_286;
  assign net_1_13 = ~raw_encoding_i[20];
  assign net_1_14 = ~raw_encoding_i[18];
  assign net_1_15 = ~raw_encoding_i[17];
  assign net_1_16 = ~raw_encoding_i[16];
  assign net_1_17 = ~net_1_61;
  assign net_1_18 = ~net_1_293;
  assign net_1_19 = ~net_1_197;
  assign net_1_21 = ~net_1_150;
  assign net_1_22 = ~raw_encoding_i[14];
  assign net_1_23 = ~net_1_105;
  assign net_1_24 = ~raw_encoding_i[13];
  assign net_1_25 = ~raw_encoding_i[12];
  assign net_1_27 = ~net_1_249;
  assign net_1_28 = ~raw_encoding_i[10];
  assign undef = ~(net_1_29 & net_1_30);
  assign net_1_30 = (net_1_31 & net_1_32);
  assign net_1_32 = (raw_encoding_i[26] | net_1_33);
  assign net_1_33 = (raw_encoding_i[27] | net_1_34);
  assign net_1_34 = (net_1_35 & net_1_36);
  assign net_1_36 = ~(raw_encoding_i[25] & net_1_37);
  assign net_1_37 = ~(net_1_38 & net_1_39);
  assign net_1_39 = (net_1_40 & net_1_41);
  assign net_1_41 = (net_1_42 & net_1_43);
  assign net_1_43 = ~(raw_encoding_i[24] & net_1_44);
  assign net_1_44 = ~(raw_encoding_i[22] | net_1_45);
  assign net_1_40 = (net_1_46 & net_1_47);
  assign net_1_47 = (net_1_48 | raw_encoding_i[30]);
  assign net_1_48 = (net_1_8 | net_1_2);
  assign net_1_46 = ~(net_1_49 & net_1_50);
  assign net_1_49 = ~(net_1_51 & net_1_52);
  assign net_1_52 = (net_1_9 | net_1_53);
  assign net_1_51 = ~(net_1_27 & net_1_54);
  assign net_1_38 = ~(net_1_27 & net_1_55);
  assign net_1_55 = ~(net_1_9 | net_1_56);
  assign net_1_56 = (net_1_57 & net_1_18);
  assign net_1_57 = (net_1_58 & net_1_59);
  assign net_1_59 = ~(net_1_909 & net_1_60);
  assign net_1_58 = ~(net_1_21 & net_1_61);
  assign net_1_35 = ~(raw_encoding_i[24] & net_1_62);
  assign net_1_31 = (net_1_63 & net_1_64);
  assign net_1_64 = (net_1_65 & net_1_66);
  assign net_1_66 = ~(raw_encoding_i[28] & net_1_67);
  assign net_1_67 = ~(net_1_68 & net_1_69);
  assign net_1_69 = ~(raw_encoding_i[27] & net_1_70);
  assign net_1_70 = ~(net_1_71 & net_1_72);
  assign net_1_72 = (net_1_73 & net_1_74);
  assign net_1_74 = ~(net_1_75 & raw_encoding_i[23]);
  assign net_1_75 = ~(raw_encoding_i[12] | net_1_76);
  assign net_1_76 = ~(net_1_77 & net_1_78);
  assign net_1_78 = ~(net_1_19 | net_1_16);
  assign net_1_73 = ~(raw_encoding_i[29] & net_1_79);
  assign net_1_79 = ~(net_1_80 & net_1_81);
  assign net_1_81 = (net_1_82 & net_1_83);
  assign net_1_83 = ~(net_1_84 | net_1_85);
  assign net_1_85 = (net_1_86 & net_1_87);
  assign net_1_87 = ~(net_1_3 & net_1_10);
  assign net_1_82 = (net_1_88 & net_1_89);
  assign net_1_89 = (raw_encoding_i[12] | net_1_90);
  assign net_1_90 = (net_1_4 | net_1_91);
  assign net_1_91 = (raw_encoding_i[10] & net_1_92);
  assign net_1_92 = ~(raw_encoding_i[11] & raw_encoding_i[14]);
  assign net_1_88 = (net_1_93 & net_1_94);
  assign net_1_94 = (raw_encoding_i[25] | net_1_95);
  assign net_1_95 = ~(net_1_96 & net_1_97);
  assign net_1_97 = (net_1_22 | raw_encoding_i[10]);
  assign net_1_93 = ~(raw_encoding_i[25] & net_1_98);
  assign net_1_98 = ~(net_1_99 & net_1_100);
  assign net_1_100 = ~(net_1_101 & net_1_102);
  assign net_1_102 = ~(net_1_103 & net_1_104);
  assign net_1_104 = ~(net_1_105 & net_1_16);
  assign net_1_103 = ~(raw_encoding_i[16] & net_1_60);
  assign net_1_99 = (net_1_106 & net_1_107);
  assign net_1_107 = ~(raw_encoding_i[4] & net_1_108);
  assign net_1_106 = (net_1_109 & net_1_110);
  assign net_1_110 = (net_1_111 & net_1_112);
  assign net_1_112 = (net_1_113 | raw_encoding_i[24]);
  assign net_1_113 = ~(net_1_114 | net_1_115);
  assign net_1_80 = (raw_encoding_i[21] | net_1_116);
  assign net_1_116 = (net_1_117 | net_1_3);
  assign net_1_71 = ~(raw_encoding_i[25] & net_1_118);
  assign net_1_118 = ~(net_1_119 & net_1_120);
  assign net_1_120 = ~(net_1_121 & raw_encoding_i[15]);
  assign net_1_121 = (net_1_2 & net_1_108);
  assign net_1_108 = ~(raw_encoding_i[26] | net_1_10);
  assign net_1_119 = (raw_encoding_i[30] | net_1_122);
  assign net_1_122 = (net_1_123 & net_1_124);
  assign net_1_124 = (net_1_111 | net_1_125);
  assign net_1_125 = ~(net_1_45 | net_1_126);
  assign net_1_126 = (raw_encoding_i[18] | net_1_127);
  assign net_1_127 = ~(net_1_128 & net_1_129);
  assign net_1_129 = ~(net_1_15 ^ raw_encoding_i[19]);
  assign net_1_128 = ~(net_1_15 ^ raw_encoding_i[20]);
  assign net_1_111 = (net_1_6 | net_1_3);
  assign net_1_123 = (net_1_130 & net_1_131);
  assign net_1_131 = (net_1_132 & net_1_133);
  assign net_1_133 = ~(net_1_134 & raw_encoding_i[26]);
  assign net_1_134 = (raw_encoding_i[23] & net_1_135);
  assign net_1_135 = ~(net_1_136 & net_1_137);
  assign net_1_136 = (net_1_138 & net_1_139);
  assign net_1_139 = ~(net_1_1 & net_1_22);
  assign net_1_138 = (net_1_14 | raw_encoding_i[19]);
  assign net_1_132 = ~(net_1_21 & net_1_140);
  assign net_1_140 = (net_1_141 & raw_encoding_i[15]);
  assign net_1_130 = (net_1_142 & net_1_143);
  assign net_1_143 = (net_1_2 | net_1_144);
  assign net_1_142 = (net_1_145 & net_1_146);
  assign net_1_146 = (net_1_147 | raw_encoding_i[24]);
  assign net_1_147 = (net_1_148 | raw_encoding_i[11]);
  assign net_1_148 = ~(net_1_149 & net_1_150);
  assign net_1_145 = ~(raw_encoding_i[12] & net_1_151);
  assign net_1_151 = ~(net_1_152 & net_1_153);
  assign net_1_153 = ~(net_1_141 & raw_encoding_i[15]);
  assign net_1_152 = ~(net_1_84 & net_1_154);
  assign net_1_154 = (net_1_155 | raw_encoding_i[6]);
  assign net_1_155 = (net_1_156 | raw_encoding_i[8]);
  assign net_1_156 = (net_1_157 | raw_encoding_i[9]);
  assign net_1_157 = (raw_encoding_i[5] | raw_encoding_i[7]);
  assign net_1_84 = (net_1_53 & net_1_96);
  assign net_1_68 = ~(net_1_158 & net_1_159);
  assign net_1_159 = ~(net_1_160 & net_1_161);
  assign net_1_161 = (net_1_162 & net_1_163);
  assign net_1_163 = (net_1_164 & net_1_165);
  assign net_1_165 = ~(raw_encoding_i[14] & net_1_166);
  assign net_1_166 = ~(net_1_167 & net_1_168);
  assign net_1_168 = (net_1_117 | net_1_1);
  assign net_1_167 = (net_1_169 & net_1_170);
  assign net_1_170 = ~(net_1_144 & net_1_171);
  assign net_1_171 = ~(net_1_24 | net_1_10);
  assign net_1_169 = ~(net_1_172 & net_1_1);
  assign net_1_164 = (net_1_173 & net_1_174);
  assign net_1_174 = ~(net_1_175 & net_1_176);
  assign net_1_173 = (raw_encoding_i[26] | net_1_177);
  assign net_1_177 = ~(raw_encoding_i[24] & net_1_178);
  assign net_1_162 = (raw_encoding_i[24] | net_1_179);
  assign net_1_179 = (net_1_180 & net_1_181);
  assign net_1_181 = ~(raw_encoding_i[22] & net_1_182);
  assign net_1_182 = ~(net_1_183 & net_1_184);
  assign net_1_184 = ~(net_1_185 & net_1_3);
  assign net_1_183 = (raw_encoding_i[11] | net_1_186);
  assign net_1_186 = (net_1_22 | net_1_1);
  assign net_1_180 = ~(net_1_187 & raw_encoding_i[11]);
  assign net_1_187 = ~(raw_encoding_i[14] | net_1_188);
  assign net_1_188 = (net_1_189 & net_1_190);
  assign net_1_189 = (net_1_908 | net_1_191);
  assign net_1_160 = (raw_encoding_i[11] | net_1_192);
  assign net_1_192 = ~(raw_encoding_i[26] & net_1_193);
  assign net_1_193 = (raw_encoding_i[10] & net_1_194);
  assign net_1_194 = ~(net_1_195 & net_1_196);
  assign net_1_196 = ~(net_1_2 & net_1_197);
  assign net_1_195 = ~(net_1_10 & net_1_908);
  assign net_1_65 = ~(net_1_198 & net_1_199);
  assign net_1_199 = ~(net_1_200 & net_1_201);
  assign net_1_201 = (net_1_202 & net_1_203);
  assign net_1_203 = (net_1_204 & net_1_205);
  assign net_1_205 = (net_1_206 & net_1_207);
  assign net_1_207 = (net_1_208 & net_1_209);
  assign net_1_209 = ~(net_1_210 | raw_encoding_i[31]);
  assign net_1_210 = ~(net_1_211 & net_1_212);
  assign net_1_212 = ~(net_1_213 & net_1_214);
  assign net_1_214 = (net_1_215 & net_1_216);
  assign net_1_213 = (net_1_217 & raw_encoding_i[21]);
  assign net_1_211 = (net_1_6 | net_1_908);
  assign net_1_208 = ~(net_1_218 & net_1_219);
  assign net_1_219 = ~(net_1_220 & net_1_221);
  assign net_1_221 = ~(net_1_222 & net_1_223);
  assign net_1_220 = (raw_encoding_i[16] | net_1_224);
  assign net_1_224 = (net_1_19 | net_1_2);
  assign net_1_218 = (raw_encoding_i[12] & net_1_225);
  assign net_1_206 = ~(net_1_226 & net_1_227);
  assign net_1_227 = (net_1_228 & net_1_5);
  assign net_1_226 = (raw_encoding_i[15] & net_1_229);
  assign net_1_229 = ~(net_1_230 & net_1_231);
  assign net_1_231 = (net_1_22 | raw_encoding_i[23]);
  assign net_1_230 = (net_1_23 | net_1_2);
  assign net_1_204 = ~(raw_encoding_i[24] & net_1_232);
  assign net_1_232 = ~(net_1_233 & net_1_234);
  assign net_1_234 = (net_1_235 & net_1_236);
  assign net_1_236 = ~(raw_encoding_i[12] & net_1_237);
  assign net_1_237 = ~(raw_encoding_i[13] | net_1_238);
  assign net_1_238 = (net_1_197 | net_1_239);
  assign net_1_235 = ~(raw_encoding_i[10] & net_1_240);
  assign net_1_240 = (net_1_241 & raw_encoding_i[21]);
  assign net_1_241 = (net_1_24 & net_1_197);
  assign net_1_233 = ~(net_1_242 | net_1_243);
  assign net_1_243 = ~(net_1_244 & net_1_245);
  assign net_1_245 = (net_1_12 | net_1_246);
  assign net_1_244 = (net_1_247 & net_1_248);
  assign net_1_248 = (net_1_249 | net_1_23);
  assign net_1_247 = (net_1_250 | raw_encoding_i[14]);
  assign net_1_250 = (net_1_251 & net_1_252);
  assign net_1_252 = (net_1_24 | net_1_249);
  assign net_1_202 = (raw_encoding_i[30] | net_1_253);
  assign net_1_253 = ~(net_1_254 | net_1_255);
  assign net_1_254 = ~(net_1_256 & net_1_257);
  assign net_1_257 = (net_1_258 & net_1_259);
  assign net_1_259 = (net_1_260 & net_1_261);
  assign net_1_261 = ~(net_1_262 & net_1_5);
  assign net_1_262 = (raw_encoding_i[22] & net_1_263);
  assign net_1_263 = (net_1_264 & net_1_13);
  assign net_1_260 = ~(net_1_265 & net_1_266);
  assign net_1_266 = (net_1_16 & net_1_15);
  assign net_1_258 = ~(raw_encoding_i[10] & net_1_267);
  assign net_1_267 = ~(net_1_268 & net_1_269);
  assign net_1_269 = ~(net_1_144 & net_1_270);
  assign net_1_270 = ~(net_1_271 & net_1_272);
  assign net_1_268 = ~(raw_encoding_i[22] & net_1_273);
  assign net_1_273 = ~(net_1_19 & net_1_909);
  assign net_1_256 = ~(net_1_197 & net_1_274);
  assign net_1_274 = ~(net_1_275 & net_1_276);
  assign net_1_276 = ~(net_1_185 & net_1_277);
  assign net_1_277 = ~(net_1_2 | raw_encoding_i[21]);
  assign net_1_275 = ~(net_1_5 & net_1_278);
  assign net_1_200 = (net_1_279 & net_1_280);
  assign net_1_280 = ~(net_1_178 & net_1_281);
  assign net_1_281 = ~(net_1_282 & net_1_283);
  assign net_1_283 = ~(net_1_12 & net_1_284);
  assign net_1_284 = ~(net_1_908 | net_1_249);
  assign net_1_282 = ~(net_1_285 & net_1_286);
  assign net_1_285 = ~(net_1_28 | net_1_19);
  assign net_1_279 = ~(net_1_53 & net_1_287);
  assign net_1_287 = (net_1_288 | net_1_289);
  assign net_1_289 = ~(net_1_290 & net_1_291);
  assign net_1_291 = ~(net_1_292 & raw_encoding_i[29]);
  assign net_1_292 = (net_1_909 & net_1_61);
  assign net_1_290 = ~(net_1_293 & net_1_294);
  assign net_1_63 = (net_1_295 & net_1_296);
  assign net_1_296 = (net_1_297 | raw_encoding_i[28]);
  assign net_1_297 = (net_1_298 & net_1_299);
  assign net_1_299 = (raw_encoding_i[29] | net_1_300);
  assign net_1_300 = ~(raw_encoding_i[26] & net_1_301);
  assign net_1_301 = ~(net_1_302 & net_1_303);
  assign net_1_303 = ~(net_1_197 & net_1_304);
  assign net_1_304 = ~(net_1_305 & net_1_306);
  assign net_1_306 = (net_1_117 | net_1_307);
  assign net_1_305 = (net_1_6 & net_1_308);
  assign net_1_308 = ~(net_1_309 & net_1_105);
  assign net_1_309 = ~(net_1_310 & net_1_311);
  assign net_1_311 = ~(net_1_27 & net_1_909);
  assign net_1_310 = ~(raw_encoding_i[10] & net_1_312);
  assign net_1_302 = (net_1_313 & net_1_314);
  assign net_1_314 = (net_1_315 & net_1_316);
  assign net_1_316 = (net_1_317 & net_1_318);
  assign net_1_318 = ~(net_1_319 & net_1_320);
  assign net_1_319 = (net_1_321 & raw_encoding_i[25]);
  assign net_1_317 = (raw_encoding_i[24] | net_1_322);
  assign net_1_322 = (raw_encoding_i[25] | net_1_323);
  assign net_1_323 = (net_1_324 & net_1_325);
  assign net_1_325 = ~(raw_encoding_i[12] & net_1_326);
  assign net_1_324 = (net_1_327 | raw_encoding_i[30]);
  assign net_1_315 = ~(net_1_328 & net_1_329);
  assign net_1_329 = ~(net_1_330 & net_1_331);
  assign net_1_331 = (net_1_10 | raw_encoding_i[13]);
  assign net_1_330 = (net_1_16 | raw_encoding_i[14]);
  assign net_1_328 = (net_1_141 & net_1_332);
  assign net_1_313 = ~(net_1_333 | raw_encoding_i[31]);
  assign net_1_333 = ~(net_1_334 & net_1_335);
  assign net_1_335 = (net_1_336 & net_1_337);
  assign net_1_337 = ~(net_1_338 & net_1_339);
  assign net_1_339 = (net_1_340 & net_1_341);
  assign net_1_336 = ~(net_1_342 & net_1_343);
  assign net_1_343 = ~(raw_encoding_i[23] | raw_encoding_i[25]);
  assign net_1_334 = (net_1_344 & net_1_345);
  assign net_1_345 = (raw_encoding_i[10] | net_1_346);
  assign net_1_346 = (net_1_347 | raw_encoding_i[15]);
  assign net_1_347 = ~(net_1_348 & net_1_349);
  assign net_1_349 = (raw_encoding_i[25] & net_1_350);
  assign net_1_350 = (net_1_351 | raw_encoding_i[24]);
  assign net_1_351 = (raw_encoding_i[11] & net_1_11);
  assign net_1_344 = (net_1_271 | net_1_352);
  assign net_1_352 = ~(net_1_265 & raw_encoding_i[25]);
  assign net_1_265 = (net_1_105 & net_1_172);
  assign net_1_298 = (net_1_353 & net_1_354);
  assign net_1_354 = ~(net_1_355 & net_1_356);
  assign net_1_356 = ~(net_1_357 & net_1_358);
  assign net_1_358 = ~(raw_encoding_i[20] & net_1_359);
  assign net_1_359 = ~(net_1_360 & net_1_361);
  assign net_1_361 = (net_1_362 & net_1_21);
  assign net_1_357 = ~(net_1_363 | net_1_364);
  assign net_1_364 = ~(raw_encoding_i[14] | net_1_365);
  assign net_1_365 = ~(raw_encoding_i[19] | net_1_366);
  assign net_1_366 = (net_1_222 & net_1_24);
  assign net_1_222 = ~(net_1_16 | raw_encoding_i[15]);
  assign net_1_353 = (net_1_367 & net_1_368);
  assign net_1_368 = ~(net_1_369 & net_1_370);
  assign net_1_370 = ~(raw_encoding_i[11] ^ raw_encoding_i[1]);
  assign net_1_369 = (net_1_371 & net_1_372);
  assign net_1_372 = (net_1_24 ^ raw_encoding_i[3]);
  assign net_1_367 = (net_1_393 & net_1_394);
  assign net_1_394 = (net_1_395 | net_1_4);
  assign net_1_395 = (net_1_396 & net_1_397);
  assign net_1_397 = ~(raw_encoding_i[23] & net_1_398);
  assign net_1_398 = ~(net_1_399 & net_1_400);
  assign net_1_400 = (raw_encoding_i[26] | net_1_178);
  assign net_1_399 = ~(raw_encoding_i[22] & net_1_272);
  assign net_1_272 = ~(net_1_24 & raw_encoding_i[12]);
  assign net_1_396 = ~(raw_encoding_i[21] & net_1_401);
  assign net_1_401 = ~(net_1_246 & net_1_402);
  assign net_1_402 = (net_1_53 | net_1_190);
  assign net_1_190 = ~(net_1_3 & raw_encoding_i[12]);
  assign net_1_246 = ~(net_1_217 & net_1_403);
  assign net_1_393 = (raw_encoding_i[27] & net_1_404);
  assign net_1_404 = (net_1_405 | net_1_406);
  assign net_1_405 = (net_1_407 | net_1_408);
  assign net_1_408 = ~(raw_encoding_i[15] & raw_encoding_i[25]);
  assign net_1_295 = (net_1_409 & net_1_410);
  assign net_1_410 = ~(raw_encoding_i[30] & net_1_411);
  assign net_1_411 = ~(net_1_412 & net_1_413);
  assign net_1_413 = (net_1_414 & net_1_415);
  assign net_1_415 = ~(net_1_355 & net_1_416);
  assign net_1_416 = (net_1_417 | net_1_363);
  assign net_1_417 = (raw_encoding_i[19] & net_1_191);
  assign net_1_191 = ~(net_1_16 & net_1_10);
  assign net_1_414 = (raw_encoding_i[27] | net_1_418);
  assign net_1_418 = (net_1_419 & net_1_420);
  assign net_1_420 = (net_1_2 | net_1_4);
  assign net_1_419 = (net_1_909 | net_1_8);
  assign net_1_412 = (net_1_421 & net_1_422);
  assign net_1_422 = (net_1_423 & net_1_424);
  assign net_1_424 = ~(raw_encoding_i[28] & net_1_425);
  assign net_1_425 = ~(net_1_426 & net_1_427);
  assign net_1_427 = ~(raw_encoding_i[27] & net_1_428);
  assign net_1_428 = ~(net_1_429 & net_1_430);
  assign net_1_430 = ~(net_1_3 & net_1_431);
  assign net_1_429 = (net_1_432 & net_1_433);
  assign net_1_433 = (raw_encoding_i[29] | net_1_434);
  assign net_1_434 = ~(net_1_338 & net_1_435);
  assign net_1_435 = ~(net_1_22 ^ raw_encoding_i[15]);
  assign net_1_338 = (net_1_25 & raw_encoding_i[24]);
  assign net_1_432 = ~(net_1_436 & net_1_437);
  assign net_1_437 = (net_1_8 | net_1_28);
  assign net_1_436 = (net_1_438 & net_1_439);
  assign net_1_426 = ~(raw_encoding_i[22] & net_1_440);
  assign net_1_440 = ~(net_1_441 & net_1_442);
  assign net_1_442 = (net_1_443 | raw_encoding_i[31]);
  assign net_1_443 = ~(net_1_312 & net_1_172);
  assign net_1_172 = (net_1_11 & net_1_27);
  assign net_1_441 = ~(net_1_158 & net_1_444);
  assign net_1_444 = ~(net_1_445 & net_1_446);
  assign net_1_446 = ~(net_1_342 & net_1_3);
  assign net_1_342 = (net_1_271 | net_1_286);
  assign net_1_445 = (raw_encoding_i[21] | net_1_447);
  assign net_1_447 = ~(raw_encoding_i[13] | net_1_448);
  assign net_1_448 = ~(net_1_22 | raw_encoding_i[24]);
  assign net_1_423 = (raw_encoding_i[25] | net_1_449);
  assign net_1_449 = ~(net_1_450 & raw_encoding_i[29]);
  assign net_1_450 = ~(net_1_451 & net_1_452);
  assign net_1_452 = ~(net_1_453 & raw_encoding_i[27]);
  assign net_1_453 = (net_1_86 & net_1_454);
  assign net_1_454 = ~(net_1_455 & net_1_456);
  assign net_1_456 = (net_1_28 | raw_encoding_i[24]);
  assign net_1_455 = ~(raw_encoding_i[11] & net_1_144);
  assign net_1_86 = ~(net_1_8 | net_1_1);
  assign net_1_451 = (net_1_457 | raw_encoding_i[28]);
  assign net_1_457 = ~(raw_encoding_i[31] | net_1_458);
  assign net_1_458 = ~(raw_encoding_i[26] | net_1_459);
  assign net_1_459 = ~(net_1_10 | net_1_54);
  assign net_1_421 = ~(raw_encoding_i[26] & net_1_460);
  assign net_1_460 = ~(net_1_461 & net_1_462);
  assign net_1_462 = (raw_encoding_i[27] | net_1_463);
  assign net_1_463 = (net_1_464 & net_1_465);
  assign net_1_465 = (net_1_466 & net_1_467);
  assign net_1_467 = ~(raw_encoding_i[24] & net_1_468);
  assign net_1_468 = ~(raw_encoding_i[31] & net_1_469);
  assign net_1_469 = ~(net_1_470 & net_1_12);
  assign net_1_470 = ~(net_1_471 & net_1_472);
  assign net_1_472 = (net_1_473 & net_1_474);
  assign net_1_474 = (net_1_475 & net_1_476);
  assign net_1_476 = (net_1_477 | raw_encoding_i[17]);
  assign net_1_477 = ~(raw_encoding_i[13] | raw_encoding_i[6]);
  assign net_1_475 = ~(net_1_24 ^ raw_encoding_i[14]);
  assign net_1_473 = ~(raw_encoding_i[12] & net_1_478);
  assign net_1_478 = (net_1_479 | net_1_480);
  assign net_1_479 = ~(raw_encoding_i[7] | raw_encoding_i[6]);
  assign net_1_471 = (net_1_481 & net_1_482);
  assign net_1_482 = (net_1_483 & net_1_484);
  assign net_1_484 = ~(net_1_485 | raw_encoding_i[15]);
  assign net_1_485 = ~(raw_encoding_i[4] & net_1_486);
  assign net_1_486 = (net_1_14 & net_1_11);
  assign net_1_483 = (raw_encoding_i[16] | net_1_487);
  assign net_1_487 = (raw_encoding_i[5] & net_1_15);
  assign net_1_481 = (net_1_488 & net_1_489);
  assign net_1_489 = (net_1_490 | raw_encoding_i[13]);
  assign net_1_490 = ~(raw_encoding_i[12] | net_1_491);
  assign net_1_491 = ~(raw_encoding_i[7] & net_1_492);
  assign net_1_492 = (net_1_16 | raw_encoding_i[6]);
  assign net_1_488 = (net_1_493 & net_1_494);
  assign net_1_494 = (raw_encoding_i[0] & raw_encoding_i[3]);
  assign net_1_493 = (raw_encoding_i[2] & raw_encoding_i[1]);
  assign net_1_466 = ~(raw_encoding_i[29] | net_1_495);
  assign net_1_495 = (raw_encoding_i[4] & net_1_909);
  assign net_1_464 = ~(raw_encoding_i[25] & net_1_496);
  assign net_1_496 = ~(net_1_497 & net_1_498);
  assign net_1_498 = (raw_encoding_i[18] & net_1_499);
  assign net_1_499 = (raw_encoding_i[20] & net_1_500);
  assign net_1_497 = (net_1_501 & net_1_502);
  assign net_1_501 = (raw_encoding_i[31] & net_1_503);
  assign net_1_503 = (net_1_504 & net_1_505);
  assign net_1_504 = (raw_encoding_i[19] & raw_encoding_i[17]);
  assign net_1_461 = (net_1_506 & net_1_507);
  assign net_1_507 = (net_1_508 & net_1_509);
  assign net_1_509 = (net_1_510 & net_1_511);
  assign net_1_511 = ~(net_1_431 & net_1_512);
  assign net_1_512 = (net_1_513 | net_1_242);
  assign net_1_242 = ~(net_1_514 & net_1_515);
  assign net_1_515 = ~(net_1_216 & net_1_28);
  assign net_1_514 = ~(net_1_27 & net_1_908);
  assign net_1_513 = ~(net_1_251 | raw_encoding_i[13]);
  assign net_1_251 = ~(raw_encoding_i[10] & net_1_516);
  assign net_1_516 = ~(net_1_908 | net_1_10);
  assign net_1_510 = (raw_encoding_i[29] | net_1_517);
  assign net_1_517 = (net_1_518 & net_1_519);
  assign net_1_519 = ~(raw_encoding_i[24] & net_1_520);
  assign net_1_520 = ~(net_1_521 & net_1_522);
  assign net_1_522 = ~(raw_encoding_i[25] & net_1_523);
  assign net_1_523 = (net_1_908 & net_1_225);
  assign net_1_225 = ~(raw_encoding_i[13] | net_1_239);
  assign net_1_239 = ~(net_1_28 & net_1_8);
  assign net_1_521 = ~(raw_encoding_i[28] & net_1_374);
  assign net_1_374 = ~(raw_encoding_i[25] | net_1_10);
  assign net_1_518 = ~(raw_encoding_i[25] & net_1_524);
  assign net_1_524 = (net_1_525 | net_1_526);
  assign net_1_525 = (net_1_185 & net_1_527);
  assign net_1_527 = (net_1_321 & net_1_271);
  assign net_1_508 = ~(raw_encoding_i[28] & net_1_528);
  assign net_1_528 = ~(net_1_529 & net_1_530);
  assign net_1_530 = ~(raw_encoding_i[29] & net_1_62);
  assign net_1_529 = ~(raw_encoding_i[25] & net_1_531);
  assign net_1_531 = ~(net_1_532 & net_1_533);
  assign net_1_533 = (net_1_534 & net_1_535);
  assign net_1_535 = (net_1_536 & net_1_537);
  assign net_1_537 = (net_1_538 | raw_encoding_i[24]);
  assign net_1_538 = (net_1_539 & net_1_540);
  assign net_1_540 = (raw_encoding_i[11] | net_1_541);
  assign net_1_541 = ~(net_1_60 | net_1_288);
  assign net_1_288 = ~(net_1_17 | net_1_9);
  assign net_1_60 = (raw_encoding_i[14] & net_1_185);
  assign net_1_539 = ~(raw_encoding_i[15] & net_1_542);
  assign net_1_542 = (net_1_53 & net_1_25);
  assign net_1_536 = (net_1_543 & net_1_544);
  assign net_1_544 = ~(raw_encoding_i[10] & net_1_545);
  assign net_1_545 = ~(net_1_546 & net_1_547);
  assign net_1_547 = ~(raw_encoding_i[24] & net_1_548);
  assign net_1_548 = ~(net_1_549 & net_1_550);
  assign net_1_550 = ~(net_1_908 & net_1_176);
  assign net_1_176 = ~(raw_encoding_i[14] | raw_encoding_i[22]);
  assign net_1_549 = (net_1_341 & net_1_551);
  assign net_1_551 = (net_1_137 | raw_encoding_i[13]);
  assign net_1_137 = (net_1_22 | raw_encoding_i[22]);
  assign net_1_341 = ~(net_1_12 & net_1_178);
  assign net_1_546 = (net_1_552 & net_1_553);
  assign net_1_553 = (net_1_554 & net_1_555);
  assign net_1_555 = (net_1_556 & net_1_557);
  assign net_1_557 = ~(raw_encoding_i[14] & net_1_558);
  assign net_1_556 = (raw_encoding_i[24] | net_1_559);
  assign net_1_554 = ~(net_1_560 & net_1_561);
  assign net_1_561 = ~(net_1_562 & net_1_563);
  assign net_1_563 = (raw_encoding_i[12] | net_1_564);
  assign net_1_564 = ~(net_1_54 | net_1_294);
  assign net_1_54 = (net_1_909 & net_1_8);
  assign net_1_562 = ~(raw_encoding_i[13] & net_1_565);
  assign net_1_565 = (raw_encoding_i[11] | raw_encoding_i[24]);
  assign net_1_552 = (net_1_566 & net_1_567);
  assign net_1_567 = ~(net_1_197 & net_1_568);
  assign net_1_568 = ~(net_1_569 & net_1_570);
  assign net_1_570 = ~(net_1_320 & net_1_8);
  assign net_1_320 = ~(raw_encoding_i[11] | net_1_25);
  assign net_1_569 = ~(net_1_178 | net_1_348);
  assign net_1_566 = (raw_encoding_i[15] | net_1_571);
  assign net_1_571 = ~(net_1_572 & net_1_185);
  assign net_1_572 = (net_1_294 | net_1_573);
  assign net_1_573 = (raw_encoding_i[11] & net_1_8);
  assign net_1_294 = ~(net_1_8 | raw_encoding_i[22]);
  assign net_1_543 = ~(net_1_144 & net_1_574);
  assign net_1_574 = (net_1_575 | raw_encoding_i[11]);
  assign net_1_575 = (raw_encoding_i[22] & raw_encoding_i[27]);
  assign net_1_534 = (raw_encoding_i[10] | net_1_576);
  assign net_1_576 = (net_1_577 & net_1_578);
  assign net_1_578 = (net_1_579 & net_1_580);
  assign net_1_580 = ~(net_1_228 & net_1_50);
  assign net_1_50 = (net_1_185 & net_1_197);
  assign net_1_228 = (net_1_16 & net_1_13);
  assign net_1_579 = (raw_encoding_i[23] | net_1_581);
  assign net_1_581 = (net_1_21 | net_1_909);
  assign net_1_577 = (net_1_582 & net_1_583);
  assign net_1_583 = (net_1_584 & net_1_585);
  assign net_1_585 = (raw_encoding_i[14] | net_1_586);
  assign net_1_586 = (raw_encoding_i[12] | net_1_587);
  assign net_1_587 = ~(raw_encoding_i[24] | net_1_588);
  assign net_1_588 = (net_1_149 & raw_encoding_i[20]);
  assign net_1_149 = ~(net_1_8 | net_1_10);
  assign net_1_584 = (raw_encoding_i[29] | net_1_589);
  assign net_1_582 = ~(net_1_558 & net_1_590);
  assign net_1_590 = ~(raw_encoding_i[15] | raw_encoding_i[19]);
  assign net_1_558 = (raw_encoding_i[11] & net_1_591);
  assign net_1_591 = (net_1_2 & net_1_105);
  assign net_1_532 = ~(net_1_5 & net_1_592);
  assign net_1_592 = ~(net_1_593 & net_1_594);
  assign net_1_185 = ~(net_1_24 | net_1_25);
  assign net_1_593 = (net_1_21 | net_1_16);
  assign net_1_506 = ~(raw_encoding_i[31] & net_1_610);
  assign net_1_610 = ~(net_1_611 & net_1_612);
  assign net_1_612 = (net_1_613 & net_1_614);
  assign net_1_614 = ~(raw_encoding_i[27] & net_1_2);
  assign net_1_613 = ~(net_1_62 & net_1_615);
  assign net_1_615 = (net_1_11 | net_1_502);
  assign net_1_62 = ~(raw_encoding_i[25] | net_1_8);
  assign net_1_611 = (net_1_616 & net_1_617);
  assign net_1_617 = ~(net_1_312 & net_1_618);
  assign net_1_618 = ~(net_1_619 & net_1_620);
  assign net_1_620 = (raw_encoding_i[8] & net_1_480);
  assign net_1_480 = (raw_encoding_i[6] & raw_encoding_i[5]);
  assign net_1_619 = (raw_encoding_i[9] & raw_encoding_i[7]);
  assign net_1_616 = (net_1_621 | raw_encoding_i[27]);
  assign net_1_621 = (net_1_622 & net_1_623);
  assign net_1_623 = ~(net_1_624 & net_1_625);
  assign net_1_625 = (net_1_626 | raw_encoding_i[22]);
  assign net_1_626 = (net_1_8 & net_1_96);
  assign net_1_624 = ~(net_1_502 & net_1_627);
  assign net_1_627 = (net_1_11 | net_1_10);
  assign net_1_622 = (net_1_628 | raw_encoding_i[24]);
  assign net_1_628 = ~(net_1_629 | raw_encoding_i[3]);
  assign net_1_629 = (raw_encoding_i[2] | net_1_630);
  assign net_1_630 = ~(raw_encoding_i[25] | net_1_631);
  assign net_1_631 = ~(net_1_502 & net_1_178);
  assign net_1_409 = (net_1_632 & net_1_633);
  assign net_1_633 = (net_1_634 & net_1_635);
  assign net_1_635 = (raw_encoding_i[29] | net_1_636);
  assign net_1_636 = (raw_encoding_i[25] | net_1_637);
  assign net_1_637 = (net_1_638 & net_1_639);
  assign net_1_639 = ~(net_1_640 & raw_encoding_i[27]);
  assign net_1_640 = (raw_encoding_i[24] & net_1_641);
  assign net_1_641 = (net_1_340 | net_1_642);
  assign net_1_642 = ~(net_1_643 & net_1_644);
  assign net_1_644 = ~(net_1_560 & raw_encoding_i[11]);
  assign net_1_638 = (net_1_645 | raw_encoding_i[28]);
  assign net_1_645 = (net_1_646 & net_1_647);
  assign net_1_647 = ~(net_1_96 & net_1_648);
  assign net_1_648 = (net_1_1 | raw_encoding_i[23]);
  assign net_1_646 = (net_1_649 & net_1_650);
  assign net_1_650 = (raw_encoding_i[15] | net_1_109);
  assign net_1_649 = ~(raw_encoding_i[24] & net_1_651);
  assign net_1_651 = (net_1_403 | net_1_652);
  assign net_1_652 = (net_1_197 & net_1_653);
  assign net_1_653 = (net_1_10 | raw_encoding_i[12]);
  assign net_1_634 = (net_1_654 & net_1_655);
  assign net_1_655 = ~(raw_encoding_i[22] & net_1_656);
  assign net_1_656 = ~(net_1_657 & net_1_658);
  assign net_1_658 = (net_1_659 & net_1_660);
  assign net_1_660 = (net_1_661 & net_1_662);
  assign net_1_662 = (net_1_109 | net_1_663);
  assign net_1_663 = (net_1_11 | net_1_4);
  assign net_1_109 = ~(net_1_3 & raw_encoding_i[23]);
  assign net_1_661 = ~(net_1_158 & net_1_664);
  assign net_1_664 = ~(net_1_665 & net_1_666);
  assign net_1_666 = ~(raw_encoding_i[10] & net_1_667);
  assign net_1_667 = ~(raw_encoding_i[31] | net_1_668);
  assign net_1_668 = (net_1_669 | raw_encoding_i[14]);
  assign net_1_669 = ~(raw_encoding_i[15] & net_1_670);
  assign net_1_670 = ~(net_1_24 ^ raw_encoding_i[12]);
  assign net_1_665 = ~(raw_encoding_i[24] & net_1_671);
  assign net_1_671 = ~(net_1_19 & net_1_11);
  assign net_1_659 = ~(net_1_672 & net_1_673);
  assign net_1_673 = (net_1_606 | net_1_674);
  assign net_1_674 = ~(raw_encoding_i[31] | net_1_675);
  assign net_1_675 = (net_1_14 | net_1_21);
  assign net_1_606 = (raw_encoding_i[15] & net_1_278);
  assign net_1_278 = (net_1_16 & net_1_8);
  assign net_1_672 = (net_1_676 & raw_encoding_i[17]);
  assign net_1_589 = ~(net_1_8 & net_1_293);
  assign net_1_526 = (net_1_197 & net_1_175);
  assign net_1_362 = ~(net_1_908 & net_1_25);
  assign net_1_101 = ~(net_1_11 | raw_encoding_i[10]);
  assign net_1_403 = ~(net_1_28 | net_1_17);
  assign net_1_198 = (raw_encoding_i[25] & net_1_643);
  assign net_1_643 = ~(raw_encoding_i[28] | net_1_3);
  assign net_1_654 = (net_1_693 & net_1_694);
  assign net_1_694 = (net_1_695 & net_1_696);
  assign net_1_696 = ~(net_1_676 & net_1_697);
  assign net_1_697 = ~(net_1_698 & net_1_699);
  assign net_1_699 = (net_1_700 & net_1_701);
  assign net_1_701 = (net_1_702 & net_1_703);
  assign net_1_703 = (net_1_360 | net_1_704);
  assign net_1_704 = (net_1_705 | raw_encoding_i[18]);
  assign net_1_705 = ~(raw_encoding_i[17] & net_1_706);
  assign net_1_706 = ~(net_1_16 & raw_encoding_i[22]);
  assign net_1_702 = ~(net_1_560 | net_1_707);
  assign net_1_707 = ~(net_1_708 | raw_encoding_i[13]);
  assign net_1_708 = (net_1_709 & net_1_710);
  assign net_1_710 = ~(raw_encoding_i[20] & net_1_363);
  assign net_1_709 = ~(raw_encoding_i[19] & net_1_711);
  assign net_1_711 = ~(net_1_712 & net_1_713);
  assign net_1_713 = (net_1_15 | raw_encoding_i[23]);
  assign net_1_712 = (net_1_14 | raw_encoding_i[17]);
  assign net_1_700 = ~(raw_encoding_i[13] & net_1_714);
  assign net_1_714 = (net_1_715 | raw_encoding_i[2]);
  assign net_1_715 = ~(net_1_22 & net_1_502);
  assign net_1_502 = ~(raw_encoding_i[1] | raw_encoding_i[0]);
  assign net_1_698 = (net_1_716 & net_1_717);
  assign net_1_717 = (net_1_22 | net_1_12);
  assign net_1_286 = (raw_encoding_i[20] | raw_encoding_i[19]);
  assign net_1_716 = ~(raw_encoding_i[15] & net_1_718);
  assign net_1_718 = (net_1_719 & net_1_16);
  assign net_1_676 = ~(raw_encoding_i[11] | net_1_720);
  assign net_1_720 = (raw_encoding_i[12] | net_1_721);
  assign net_1_721 = ~(net_1_722 & net_1_77);
  assign net_1_722 = (raw_encoding_i[28] & raw_encoding_i[27]);
  assign net_1_695 = ~(raw_encoding_i[27] & net_1_723);
  assign net_1_723 = (net_1_355 & net_1_724);
  assign net_1_724 = ~(net_1_725 & net_1_726);
  assign net_1_726 = ~(raw_encoding_i[23] & net_1_727);
  assign net_1_727 = ~(net_1_728 & net_1_729);
  assign net_1_729 = ~(net_1_332 & net_1_24);
  assign net_1_728 = ~(raw_encoding_i[19] | net_1_730);
  assign net_1_730 = ~(net_1_731 & net_1_732);
  assign net_1_732 = (net_1_307 | net_1_360);
  assign net_1_307 = (net_1_24 | net_1_16);
  assign net_1_731 = (net_1_13 | raw_encoding_i[30]);
  assign net_1_725 = ~(raw_encoding_i[20] & net_1_733);
  assign net_1_733 = ~(net_1_734 & net_1_735);
  assign net_1_735 = ~(net_1_16 & net_1_215);
  assign net_1_734 = (net_1_16 | net_1_19);
  assign net_1_355 = (raw_encoding_i[11] & net_1_736);
  assign net_1_736 = (raw_encoding_i[26] & net_1_77);
  assign net_1_77 = (net_1_28 & net_1_439);
  assign net_1_439 = (raw_encoding_i[25] & net_1_96);
  assign net_1_693 = ~(net_1_737 & net_1_738);
  assign net_1_738 = (net_1_431 & raw_encoding_i[28]);
  assign net_1_431 = (raw_encoding_i[24] & raw_encoding_i[25]);
  assign net_1_737 = ~(net_1_407 | net_1_178);
  assign net_1_178 = (net_1_11 & net_1_10);
  assign net_1_407 = ~(net_1_1 & net_1_3);
  assign net_1_632 = ~(net_1_739 & net_1_740);
  assign net_1_740 = ~(net_1_741 & net_1_742);
  assign net_1_742 = (net_1_743 & net_1_744);
  assign net_1_744 = ~(net_1_745 | net_1_690);
  assign net_1_690 = ~(raw_encoding_i[11] | net_1_6);
  assign net_1_745 = ~(net_1_746 & net_1_747);
  assign net_1_747 = (net_1_748 & net_1_749);
  assign net_1_749 = (net_1_28 | net_1_96);
  assign net_1_96 = ~(net_1_11 | raw_encoding_i[24]);
  assign net_1_748 = (net_1_909 | net_1_18);
  assign net_1_293 = ~(net_1_24 | net_1_19);
  assign net_1_746 = (net_1_750 & net_1_751);
  assign net_1_751 = ~(raw_encoding_i[12] & net_1_752);
  assign net_1_750 = (net_1_1 | raw_encoding_i[18]);
  assign net_1_743 = ~(raw_encoding_i[22] & net_1_753);
  assign net_1_753 = ~(net_1_754 & net_1_755);
  assign net_1_755 = (raw_encoding_i[30] | net_1_756);
  assign net_1_756 = (net_1_757 & net_1_758);
  assign net_1_758 = ~(raw_encoding_i[10] & net_1_559);
  assign net_1_559 = (net_1_21 | net_1_25);
  assign net_1_757 = (raw_encoding_i[21] & net_1_759);
  assign net_1_759 = (net_1_760 | raw_encoding_i[10]);
  assign net_1_760 = ~(raw_encoding_i[11] | net_1_761);
  assign net_1_761 = (net_1_24 & net_1_15);
  assign net_1_114 = (raw_encoding_i[13] & net_1_340);
  assign net_1_340 = ~(net_1_28 | net_1_360);
  assign net_1_348 = (net_1_24 & net_1_25);
  assign net_1_505 = ~(net_1_16 | raw_encoding_i[10]);
  assign net_1_560 = (net_1_22 & raw_encoding_i[15]);
  assign net_1_438 = ~(raw_encoding_i[11] | raw_encoding_i[15]);
  assign net_1_741 = (raw_encoding_i[13] | net_1_775);
  assign net_1_775 = ~(net_1_61 & net_1_175);
  assign net_1_175 = ~(net_1_117 | net_1_13);
  assign net_1_739 = (net_1_158 & raw_encoding_i[26]);
  assign net_1_158 = (raw_encoding_i[27] & net_1_312);
  assign net_1_312 = (raw_encoding_i[23] & raw_encoding_i[25]);
  assign net_1_29 = ~(net_1_776 & net_1_777);
  assign net_1_777 = ~(net_1_778 & net_1_779);
  assign net_1_779 = ~(raw_encoding_i[26] & net_1_780);
  assign net_1_780 = ~(net_1_781 & net_1_782);
  assign net_1_782 = ~(raw_encoding_i[31] & net_1_783);
  assign net_1_783 = ~(net_1_784 & net_1_785);
  assign net_1_785 = ~(net_1_719 & net_1_216);
  assign net_1_719 = ~(net_1_15 | net_1_14);
  assign net_1_784 = ~(raw_encoding_i[24] | net_1_786);
  assign net_1_786 = (raw_encoding_i[21] & net_1_787);
  assign net_1_787 = ~(net_1_500 & net_1_53);
  assign net_1_53 = ~(raw_encoding_i[10] | raw_encoding_i[11]);
  assign net_1_781 = (net_1_788 & net_1_789);
  assign net_1_789 = ~(net_1_321 & net_1_790);
  assign net_1_790 = ~(net_1_791 & net_1_792);
  assign net_1_792 = (net_1_271 | raw_encoding_i[19]);
  assign net_1_271 = (raw_encoding_i[16] | net_1_363);
  assign net_1_363 = ~(net_1_15 & net_1_14);
  assign net_1_791 = (raw_encoding_i[29] | net_1_793);
  assign net_1_793 = ~(net_1_45 & net_1_794);
  assign net_1_794 = (net_1_217 | raw_encoding_i[14]);
  assign net_1_217 = ~(raw_encoding_i[11] | net_1_24);
  assign net_1_45 = (net_1_908 & net_1_1);
  assign net_1_321 = ~(net_1_28 | net_1_6);
  assign net_1_788 = ~(raw_encoding_i[29] & net_1_795);
  assign net_1_795 = ~(net_1_796 & net_1_797);
  assign net_1_797 = (net_1_798 & net_1_799);
  assign net_1_799 = (net_1_800 & net_1_801);
  assign net_1_801 = ~(net_1_255 | net_1_802);
  assign net_1_802 = (net_1_144 & net_1_803);
  assign net_1_803 = (net_1_804 | net_1_9);
  assign net_1_804 = ~(raw_encoding_i[30] | net_1_805);
  assign net_1_805 = (net_1_28 & net_1_22);
  assign net_1_144 = (net_1_909 & net_1_11);
  assign net_1_255 = (net_1_141 & raw_encoding_i[19]);
  assign net_1_141 = ~(net_1_117 | net_1_11);
  assign net_1_117 = (raw_encoding_i[24] | net_1_806);
  assign net_1_800 = (raw_encoding_i[10] | net_1_807);
  assign net_1_807 = (net_1_808 & net_1_809);
  assign net_1_809 = (net_1_810 & net_1_811);
  assign net_1_811 = ~(raw_encoding_i[24] & net_1_812);
  assign net_1_812 = ~(net_1_813 & net_1_814);
  assign net_1_814 = (net_1_25 | net_1_22);
  assign net_1_813 = ~(net_1_25 ^ net_1_815);
  assign net_1_815 = ~(net_1_24 & raw_encoding_i[15]);
  assign net_1_810 = (net_1_19 | net_1_23);
  assign net_1_105 = ~(net_1_24 | raw_encoding_i[12]);
  assign net_1_808 = ~(net_1_223 & net_1_816);
  assign net_1_816 = ~(net_1_817 & net_1_818);
  assign net_1_818 = ~(net_1_332 & net_1_150);
  assign net_1_332 = ~(net_1_25 | raw_encoding_i[15]);
  assign net_1_817 = ~(raw_encoding_i[16] & net_1_819);
  assign net_1_819 = ~(net_1_820 & net_1_821);
  assign net_1_821 = (net_1_326 | net_1_9);
  assign net_1_326 = (net_1_24 | net_1_22);
  assign net_1_820 = ~(raw_encoding_i[12] & net_1_822);
  assign net_1_822 = ~(net_1_360 & net_1_823);
  assign net_1_823 = (net_1_13 | net_1_24);
  assign net_1_360 = (net_1_22 | raw_encoding_i[15]);
  assign net_1_223 = (raw_encoding_i[11] & raw_encoding_i[21]);
  assign net_1_798 = ~(raw_encoding_i[23] & net_1_824);
  assign net_1_824 = (net_1_115 | net_1_825);
  assign net_1_825 = ~(net_1_806 | net_1_826);
  assign net_1_826 = (net_1_827 & net_1_828);
  assign net_1_828 = (net_1_829 | raw_encoding_i[24]);
  assign net_1_829 = ~(net_1_150 & net_1_908);
  assign net_1_827 = ~(net_1_500 & net_1_264);
  assign net_1_264 = ~(net_1_908 | net_1_16);
  assign net_1_806 = ~(raw_encoding_i[11] & net_1_28);
  assign net_1_115 = ~(net_1_249 | net_1_17);
  assign net_1_796 = (net_1_830 & net_1_831);
  assign net_1_831 = ~(raw_encoding_i[13] & net_1_832);
  assign net_1_830 = ~(net_1_25 & net_1_752);
  assign net_1_752 = ~(net_1_19 | net_1_327);
  assign net_1_327 = ~(net_1_24 & net_1_27);
  assign net_1_197 = ~(net_1_22 | net_1_908);
  assign net_1_778 = (net_1_833 & net_1_834);
  assign net_1_834 = (raw_encoding_i[26] | net_1_835);
  assign net_1_835 = (net_1_836 & net_1_837);
  assign net_1_837 = (net_1_838 | raw_encoding_i[24]);
  assign net_1_838 = ~(raw_encoding_i[28] & net_1_839);
  assign net_1_839 = ~(net_1_840 & net_1_841);
  assign net_1_841 = ~(raw_encoding_i[21] | net_1_842);
  assign net_1_842 = (raw_encoding_i[11] & net_1_10);
  assign net_1_840 = (net_1_843 & net_1_844);
  assign net_1_844 = ~(raw_encoding_i[22] & net_1_845);
  assign net_1_845 = (net_1_8 & net_1_2);
  assign net_1_843 = (net_1_846 & net_1_847);
  assign net_1_847 = ~(raw_encoding_i[10] & net_1_8);
  assign net_1_846 = (net_1_848 | net_1_9);
  assign net_1_216 = ~(raw_encoding_i[23] | raw_encoding_i[22]);
  assign net_1_848 = (net_1_500 & net_1_908);
  assign net_1_500 = ~(raw_encoding_i[12] | net_1_21);
  assign net_1_150 = ~(raw_encoding_i[13] | raw_encoding_i[14]);
  assign net_1_836 = ~(raw_encoding_i[22] & net_1_406);
  assign net_1_406 = ~(net_1_909 | net_1_11);
  assign net_1_833 = (net_1_849 | net_1_42);
  assign net_1_42 = ~(net_1_1 & raw_encoding_i[22]);
  assign net_1_849 = ~(net_1_832 & raw_encoding_i[29]);
  assign net_1_832 = (net_1_27 & net_1_215);
  assign net_1_215 = (net_1_22 & net_1_61);
  assign net_1_61 = ~(net_1_908 | net_1_25);
  assign net_1_249 = ~(raw_encoding_i[10] & raw_encoding_i[11]);
  assign net_1_776 = (raw_encoding_i[25] & raw_encoding_i[27]);
  assign net_1_850 = ~(net_1_24 & net_1_16);
  assign net_1_851 = ~(raw_encoding_i[19] | net_1_850);
  assign net_1_852 = ~(raw_encoding_i[20] | net_1_851);
  assign net_1_853 = (net_1_25 | net_1_16);
  assign net_1_854 = (net_1_852 & net_1_853);
  assign net_1_855 = (net_1_854 | raw_encoding_i[15]);
  assign net_1_856 = (raw_encoding_i[14] | net_1_185);
  assign net_1_857 = (raw_encoding_i[19] & net_1_856);
  assign net_1_858 = (net_1_8 & raw_encoding_i[20]);
  assign net_1_859 = (net_1_22 & net_1_858);
  assign net_1_860 = ~(net_1_857 | net_1_859);
  assign net_1_861 = (net_1_855 & net_1_860);
  assign net_1_862 = ~(net_1_13 & net_1_606);
  assign net_1_594 = (net_1_861 & net_1_862);
  assign net_1_863 = (raw_encoding_i[10] & raw_encoding_i[0]);
  assign net_1_864 = ~(net_1_96 & net_1_863);
  assign net_1_865 = (net_1_96 & net_1_28);
  assign net_1_866 = ~(raw_encoding_i[29] | net_1_865);
  assign net_1_867 = ~(raw_encoding_i[0] ^ net_1_28);
  assign net_1_868 = (net_1_866 | net_1_867);
  assign net_1_869 = (net_1_25 ^ raw_encoding_i[2]);
  assign net_1_870 = (raw_encoding_i[2] | net_1_864);
  assign net_1_871 = ~(net_1_868 & net_1_870);
  assign net_1_872 = ~(net_1_869 & net_1_871);
  assign net_1_873 = (net_1_909 | raw_encoding_i[4]);
  assign net_1_874 = (raw_encoding_i[21] & net_1_873);
  assign net_1_875 = (net_1_874 & raw_encoding_i[12]);
  assign net_1_876 = (net_1_863 & raw_encoding_i[2]);
  assign net_1_877 = ~(net_1_875 & net_1_876);
  assign net_1_878 = (net_1_22 ^ raw_encoding_i[4]);
  assign net_1_879 = (net_1_878 & net_1_374);
  assign net_1_880 = ~(net_1_872 & net_1_877);
  assign net_1_371 = (net_1_879 & net_1_880);
  assign net_1_881 = (raw_encoding_i[15] | net_1_11);
  assign net_1_882 = ~(net_1_348 & raw_encoding_i[14]);
  assign net_1_883 = ~(net_1_881 & net_1_882);
  assign net_1_884 = (net_1_217 & net_1_560);
  assign net_1_885 = ~(raw_encoding_i[21] & net_1_53);
  assign net_1_886 = ~(net_1_25 | net_1_885);
  assign net_1_887 = (net_1_886 | net_1_884);
  assign net_1_888 = ~(net_1_28 | net_1_21);
  assign net_1_889 = (net_1_105 | net_1_888);
  assign net_1_890 = (net_1_438 & net_1_889);
  assign net_1_891 = (net_1_505 & net_1_883);
  assign net_1_892 = (net_1_891 | net_1_890);
  assign net_1_893 = (net_1_887 | net_1_892);
  assign net_1_754 = ~(net_1_114 | net_1_893);
  assign net_1_894 = ~(raw_encoding_i[11] & raw_encoding_i[20]);
  assign net_1_895 = ~(net_1_362 & net_1_894);
  assign net_1_896 = ~(net_1_101 & net_1_895);
  assign net_1_897 = ~(net_1_348 & net_1_53);
  assign net_1_898 = ~(net_1_896 & net_1_897);
  assign net_1_899 = ~(raw_encoding_i[23] & net_1_898);
  assign net_1_900 = ~(net_1_11 & net_1_403);
  assign net_1_901 = (raw_encoding_i[11] | net_1_900);
  assign net_1_902 = (net_1_899 & net_1_901);
  assign net_1_903 = ~(net_1_526 | net_1_690);
  assign net_1_904 = ~(net_1_902 & net_1_903);
  assign net_1_905 = ~(net_1_321 | net_1_904);
  assign net_1_906 = (raw_encoding_i[10] | net_1_589);
  assign net_1_907 = ~(net_1_905 & net_1_906);
  assign net_1_657 = ~(net_1_198 & net_1_907);
  assign net_1_908 = ~raw_encoding_i[15];
  assign net_1_909 = ~raw_encoding_i[24];

  wire   net_2_2, net_2_4, net_2_6, net_2_7, net_2_8, net_2_9, net_2_10, net_2_11, net_2_13,
         net_2_14, net_2_15, net_2_17, net_2_18, net_2_19, net_2_20, net_2_22, net_2_24,
         net_2_25, net_2_27, net_2_29, net_2_30, net_2_31, net_2_32, net_2_33, net_2_34,
         net_2_37, net_2_38, net_2_39, net_2_40, net_2_43, net_2_46, net_2_47, net_2_48,
         net_2_49, net_2_50, net_2_51, net_2_52, net_2_53, net_2_54, net_2_55, net_2_56,
         net_2_57, net_2_58, net_2_59, net_2_60, net_2_61, net_2_62, net_2_63, net_2_64,
         net_2_65, net_2_66, net_2_67, net_2_68, net_2_69, net_2_70, net_2_71, net_2_72,
         net_2_73, net_2_74, net_2_75, net_2_76, net_2_77, net_2_78, net_2_79, net_2_80,
         net_2_81, net_2_82, net_2_83, net_2_84, net_2_85, net_2_86, net_2_87, net_2_88,
         net_2_89, net_2_90, net_2_91, net_2_92, net_2_93, net_2_94, net_2_95, net_2_96,
         net_2_97, net_2_98, net_2_99, net_2_100, net_2_101, net_2_102, net_2_103, net_2_104,
         net_2_105, net_2_106, net_2_107, net_2_108, net_2_109, net_2_110, net_2_111,
         net_2_112, net_2_113, net_2_114, net_2_115, net_2_116, net_2_117, net_2_118,
         net_2_119, net_2_120, net_2_121, net_2_122, net_2_123, net_2_124, net_2_125,
         net_2_126, net_2_127, net_2_128, net_2_129, net_2_130, net_2_131, net_2_132,
         net_2_133, net_2_134, net_2_135, net_2_136, net_2_137, net_2_138, net_2_139,
         net_2_140, net_2_141, net_2_142, net_2_143, net_2_144, net_2_145, net_2_146,
         net_2_147, net_2_148, net_2_149, net_2_150, net_2_151, net_2_152, net_2_153,
         net_2_154, net_2_155, net_2_156, net_2_157, net_2_158, net_2_159, net_2_160,
         net_2_161, net_2_162, net_2_163, net_2_164, net_2_165, net_2_166, net_2_167,
         net_2_168, net_2_169, net_2_170, net_2_171, net_2_172, net_2_173, net_2_174,
         net_2_175, net_2_176, net_2_177, net_2_178, net_2_179, net_2_180, net_2_181,
         net_2_182, net_2_183, net_2_184, net_2_185, net_2_186, net_2_187, net_2_188,
         net_2_189, net_2_190, net_2_191, net_2_192, net_2_193, net_2_194, net_2_195,
         net_2_196, net_2_197, net_2_198, net_2_199, net_2_200, net_2_201, net_2_202,
         net_2_203, net_2_204, net_2_205, net_2_206, net_2_207, net_2_208, net_2_209,
         net_2_210, net_2_211, net_2_212, net_2_213, net_2_214, net_2_215, net_2_216,
         net_2_217, net_2_218, net_2_219, net_2_220, net_2_221, net_2_222, net_2_223,
         net_2_224, net_2_225, net_2_226, net_2_227, net_2_228, net_2_229, net_2_230,
         net_2_231, net_2_232, net_2_233, net_2_234, net_2_235, net_2_236, net_2_237,
         net_2_238, net_2_239, net_2_240, net_2_241, net_2_242, net_2_243, net_2_244,
         net_2_245, net_2_246, net_2_247, net_2_248, net_2_249, net_2_250, net_2_251,
         net_2_252, net_2_253, net_2_254, net_2_255, net_2_256, net_2_257, net_2_263,
         net_2_264, net_2_265, net_2_266, net_2_270, net_2_273, net_2_274, net_2_275,
         net_2_276, net_2_277, net_2_278, net_2_279, net_2_280, net_2_281, net_2_282,
         net_2_283, net_2_284, net_2_285, net_2_286, net_2_287, net_2_288, net_2_289,
         net_2_290, net_2_291, net_2_292, net_2_293, net_2_294, net_2_295, net_2_296,
         net_2_297, net_2_298, net_2_299, net_2_300, net_2_301, net_2_302, net_2_303,
         net_2_304, net_2_305, net_2_306, net_2_307, net_2_308, net_2_309, net_2_310,
         net_2_311, net_2_312, net_2_313, net_2_314, net_2_315, net_2_316, net_2_317,
         net_2_318, net_2_319, net_2_320, net_2_321, net_2_322, net_2_323, net_2_324,
         net_2_325, net_2_326, net_2_327, net_2_328, net_2_329, net_2_330, net_2_331,
         net_2_332, net_2_333, net_2_334, net_2_335, net_2_336, net_2_337, net_2_338,
         net_2_339, net_2_340, net_2_341, net_2_342, net_2_343, net_2_344, net_2_345,
         net_2_346, net_2_347, net_2_348, net_2_349, net_2_350, net_2_351, net_2_352,
         net_2_353, net_2_354, net_2_355, net_2_356, net_2_357, net_2_358, net_2_359,
         net_2_360, net_2_361, net_2_362, net_2_363, net_2_364, net_2_365, net_2_366,
         net_2_367, net_2_368, net_2_369, net_2_370, net_2_371, net_2_372, net_2_373,
         net_2_374, net_2_375, net_2_376, net_2_377, net_2_378, net_2_379, net_2_380,
         net_2_381, net_2_382, net_2_383, net_2_384, net_2_385, net_2_386, net_2_387,
         net_2_388, net_2_389, net_2_390, net_2_391, net_2_392, net_2_393, net_2_394,
         net_2_395, net_2_396, net_2_397, net_2_398, net_2_399, net_2_400, net_2_401,
         net_2_402, net_2_403, net_2_404, net_2_405, net_2_406, net_2_407, net_2_408,
         net_2_409, net_2_410, net_2_411, net_2_412, net_2_413, net_2_414, net_2_415,
         net_2_416, net_2_417, net_2_418, net_2_419, net_2_420, net_2_421, net_2_422,
         net_2_423, net_2_424, net_2_425, net_2_426, net_2_427, net_2_428, net_2_429,
         net_2_430, net_2_431, net_2_432, net_2_433, net_2_434, net_2_435, net_2_436,
         net_2_437, net_2_438, net_2_439, net_2_440, net_2_441, net_2_442, net_2_443,
         net_2_444, net_2_445, net_2_447, net_2_448, net_2_449, net_2_450, net_2_451,
         net_2_452, net_2_453, net_2_454, net_2_455, net_2_456, net_2_457, net_2_458,
         net_2_459, net_2_460, net_2_461, net_2_462, net_2_463, net_2_464, net_2_465,
         net_2_466, net_2_467, net_2_468, net_2_469, net_2_470, net_2_471, net_2_472,
         net_2_473, net_2_474, net_2_475, net_2_476, net_2_477, net_2_478, net_2_479,
         net_2_480, net_2_481, net_2_482, net_2_483, net_2_484, net_2_485, net_2_486,
         net_2_487, net_2_488, net_2_489, net_2_490, net_2_491, net_2_492, net_2_493,
         net_2_494, net_2_495, net_2_496, net_2_497, net_2_498, net_2_499, net_2_500,
         net_2_501, net_2_502, net_2_503, net_2_504, net_2_505, net_2_506, net_2_507,
         net_2_508, net_2_509, net_2_510, net_2_511, net_2_512, net_2_513, net_2_514,
         net_2_515, net_2_516, net_2_517, net_2_518, net_2_519, net_2_520, net_2_521,
         net_2_522, net_2_523, net_2_524, net_2_525, net_2_526, net_2_527, net_2_528,
         net_2_529, net_2_530, net_2_531, net_2_532, net_2_533, net_2_534, net_2_535,
         net_2_536, net_2_537, net_2_538, net_2_539, net_2_540, net_2_541, net_2_542,
         net_2_543, net_2_544, net_2_545, net_2_546, net_2_547, net_2_548, net_2_549,
         net_2_550, net_2_551, net_2_552, net_2_553, net_2_554, net_2_555, net_2_556,
         net_2_557, net_2_558, net_2_559, net_2_560, net_2_561, net_2_562, net_2_563,
         net_2_564, net_2_565, net_2_566, net_2_567, net_2_568, net_2_569, net_2_570,
         net_2_571, net_2_572, net_2_573, net_2_574, net_2_575, net_2_576, net_2_577,
         net_2_578, net_2_579, net_2_580, net_2_581, net_2_582, net_2_583, net_2_584,
         net_2_585, net_2_586, net_2_587, net_2_588, net_2_589, net_2_590, net_2_591,
         net_2_592, net_2_593, net_2_594, net_2_595, net_2_596, net_2_597, net_2_598,
         net_2_599, net_2_600, net_2_601, net_2_602, net_2_603, net_2_604, net_2_605,
         net_2_606, net_2_607, net_2_608, net_2_609, net_2_610, net_2_611, net_2_612,
         net_2_613, net_2_614, net_2_615, net_2_616, net_2_617, net_2_618, net_2_619,
         net_2_620, net_2_621, net_2_622, net_2_623, net_2_624, net_2_625, net_2_626,
         net_2_627, net_2_628, net_2_629, net_2_630, net_2_631, net_2_632, net_2_633,
         net_2_634, net_2_635, net_2_636, net_2_637, net_2_638, net_2_639, net_2_640,
         net_2_641, net_2_642, net_2_643, net_2_644, net_2_645, net_2_646, net_2_647,
         net_2_648, net_2_649, net_2_650, net_2_651, net_2_652, net_2_653, net_2_654,
         net_2_655, net_2_656, net_2_657, net_2_658, net_2_659, net_2_660, net_2_661,
         net_2_662, net_2_663, net_2_664, net_2_665, net_2_666, net_2_667, net_2_668,
         net_2_669, net_2_670, net_2_671, net_2_672, net_2_673, net_2_674, net_2_675,
         net_2_676, net_2_677, net_2_678, net_2_679, net_2_680, net_2_681, net_2_682,
         net_2_683, net_2_684, net_2_685, net_2_686, net_2_687, net_2_688, net_2_689,
         net_2_690, net_2_691, net_2_692, net_2_693, net_2_694, net_2_695, net_2_696,
         net_2_697, net_2_698, net_2_699, net_2_700, net_2_701, net_2_702, net_2_703,
         net_2_704, net_2_705, net_2_706, net_2_707, net_2_708, net_2_709, net_2_710,
         net_2_711, net_2_712, net_2_713, net_2_714, net_2_715, net_2_716, net_2_717,
         net_2_718, net_2_719, net_2_720, net_2_721, net_2_722, net_2_723, net_2_724,
         net_2_725, net_2_726, net_2_727, net_2_728, net_2_729, net_2_730, net_2_731,
         net_2_732, net_2_733, net_2_734, net_2_735, net_2_736, net_2_737, net_2_738,
         net_2_739, net_2_740, net_2_741, net_2_742, net_2_743, net_2_744, net_2_745,
         net_2_746, net_2_747, net_2_748, net_2_749, net_2_750, net_2_751, net_2_752,
         net_2_753, net_2_754, net_2_755, net_2_756, net_2_757, net_2_758, net_2_759,
         net_2_760, net_2_761, net_2_762, net_2_763, net_2_764, net_2_765, net_2_766,
         net_2_767, net_2_768, net_2_769, net_2_770, net_2_771, net_2_772, net_2_773,
         net_2_774, net_2_775, net_2_776, net_2_777, net_2_778, net_2_779, net_2_780,
         net_2_781, net_2_782, net_2_783, net_2_784, net_2_785, net_2_786, net_2_787,
         net_2_788, net_2_789, net_2_790, net_2_791, net_2_792, net_2_793, net_2_794,
         net_2_795, net_2_796, net_2_797, net_2_798, net_2_799, net_2_800, net_2_801,
         net_2_802, net_2_803, net_2_804, net_2_805, net_2_806, net_2_807, net_2_808,
         net_2_809, net_2_810, net_2_811, net_2_812, net_2_813, net_2_814, net_2_815,
         net_2_816, net_2_817, net_2_818, net_2_819, net_2_820, net_2_821, net_2_822,
         net_2_823, net_2_824, net_2_825, net_2_826, net_2_827, net_2_828, net_2_829,
         net_2_830, net_2_831, net_2_832, net_2_833, net_2_834, net_2_835, net_2_836,
         net_2_837, net_2_838, net_2_839, net_2_840, net_2_841, net_2_842, net_2_843,
         net_2_844, net_2_845, net_2_846, net_2_847, net_2_848, net_2_849, net_2_850,
         net_2_851, net_2_852, net_2_853, net_2_854, net_2_855, net_2_856, net_2_857,
         net_2_858, net_2_859, net_2_860, net_2_861, net_2_862, net_2_863, net_2_864,
         net_2_865, net_2_866, net_2_867, net_2_868, net_2_869, net_2_870, net_2_871,
         net_2_872, net_2_873, net_2_874, net_2_875, net_2_876, net_2_877, net_2_878,
         net_2_879, net_2_880, net_2_881, net_2_882, net_2_883, net_2_884, net_2_885,
         net_2_886, net_2_887, net_2_888, net_2_889, net_2_890, net_2_891, net_2_892,
         net_2_893, net_2_894, net_2_895, net_2_896, net_2_897, net_2_898, net_2_899,
         net_2_900, net_2_901, net_2_902, net_2_903, net_2_904, net_2_905, net_2_906,
         net_2_907, net_2_908, net_2_909, net_2_910, net_2_911, net_2_912, net_2_913,
         net_2_914, net_2_915, net_2_916, net_2_917, net_2_918, net_2_919, net_2_920,
         net_2_921, net_2_922, net_2_923, net_2_924, net_2_925, net_2_926, net_2_927,
         net_2_928, net_2_929, net_2_930, net_2_931, net_2_932, net_2_933, net_2_934,
         net_2_935, net_2_936, net_2_937, net_2_938, net_2_939, net_2_940, net_2_941,
         net_2_942, net_2_943, net_2_944, net_2_945, net_2_946, net_2_947, net_2_948,
         net_2_949, net_2_950, net_2_951, net_2_952, net_2_953, net_2_954, net_2_955,
         net_2_956, net_2_957, net_2_958, net_2_959, net_2_960, net_2_961, net_2_962,
         net_2_963, net_2_964, net_2_965, net_2_966, net_2_967, net_2_968, net_2_969,
         net_2_970, net_2_971, net_2_972, net_2_973, net_2_974, net_2_975, net_2_976,
         net_2_977, net_2_978, net_2_979, net_2_980, net_2_981, net_2_982, net_2_983,
         net_2_984, net_2_985, net_2_986, net_2_987, net_2_988, net_2_989, net_2_990,
         net_2_991, net_2_992, net_2_993, net_2_994, net_2_995, net_2_996, net_2_997,
         net_2_998, net_2_999, net_2_1000, net_2_1001, net_2_1002, net_2_1003, net_2_1004,
         net_2_1005, net_2_1006, net_2_1007, net_2_1008, net_2_1009, net_2_1010, net_2_1011,
         net_2_1012, net_2_1013, net_2_1014, net_2_1015, net_2_1016, net_2_1017, net_2_1018,
         net_2_1019, net_2_1020, net_2_1021, net_2_1022, net_2_1023, net_2_1024, net_2_1025,
         net_2_1026, net_2_1027, net_2_1028, net_2_1029, net_2_1030, net_2_1031, net_2_1032,
         net_2_1033, net_2_1034, net_2_1035, net_2_1036, net_2_1037, net_2_1038, net_2_1039,
         net_2_1040, net_2_1041, net_2_1042, net_2_1043, net_2_1044, net_2_1045, net_2_1046,
         net_2_1047, net_2_1048, net_2_1049, net_2_1050, net_2_1051, net_2_1052, net_2_1053,
         net_2_1054, net_2_1055, net_2_1056, net_2_1057, net_2_1058, net_2_1059, net_2_1060,
         net_2_1061, net_2_1062, net_2_1063, net_2_1064, net_2_1065, net_2_1066, net_2_1067,
         net_2_1068, net_2_1069, net_2_1070, net_2_1071, net_2_1072, net_2_1073, net_2_1074,
         net_2_1075, net_2_1076, net_2_1077, net_2_1078, net_2_1079, net_2_1080, net_2_1081,
         net_2_1082, net_2_1083, net_2_1084, net_2_1085, net_2_1086, net_2_1087, net_2_1088,
         net_2_1089, net_2_1090, net_2_1091, net_2_1092, net_2_1093, net_2_1094, net_2_1095,
         net_2_1096, net_2_1097, net_2_1098, net_2_1099, net_2_1100, net_2_1101, net_2_1102,
         net_2_1103, net_2_1104, net_2_1105, net_2_1106, net_2_1107, net_2_1108, net_2_1109,
         net_2_1110, net_2_1111, net_2_1112, net_2_1113, net_2_1114, net_2_1115, net_2_1116,
         net_2_1117, net_2_1118, net_2_1119, net_2_1120, net_2_1121, net_2_1122, net_2_1123,
         net_2_1124, net_2_1125, net_2_1126, net_2_1127, net_2_1128, net_2_1129, net_2_1130,
         net_2_1131, net_2_1132, net_2_1133, net_2_1134, net_2_1135, net_2_1136, net_2_1137,
         net_2_1138, net_2_1139, net_2_1140, net_2_1141, net_2_1142, net_2_1143, net_2_1144,
         net_2_1145, net_2_1146, net_2_1147, net_2_1148, net_2_1149, net_2_1150, net_2_1151,
         net_2_1152, net_2_1153, net_2_1154, net_2_1155, net_2_1156, net_2_1157, net_2_1158,
         net_2_1159, net_2_1160, net_2_1161, net_2_1162, net_2_1163, net_2_1164, net_2_1165,
         net_2_1166, net_2_1167, net_2_1168, net_2_1169, net_2_1170, net_2_1171, net_2_1172,
         net_2_1173, net_2_1174, net_2_1175, net_2_1176, net_2_1177, net_2_1178, net_2_1179,
         net_2_1180, net_2_1181, net_2_1182, net_2_1183, net_2_1184, net_2_1185, net_2_1186,
         net_2_1187, net_2_1188, net_2_1189, net_2_1190, net_2_1191, net_2_1192, net_2_1193,
         net_2_1194, net_2_1195, net_2_1196, net_2_1197, net_2_1198, net_2_1199, net_2_1200,
         net_2_1201, net_2_1202, net_2_1203, net_2_1204;

  assign net_2_2 = ~net_2_851;
  assign net_2_4 = ~net_2_182;
  assign net_2_6 = ~net_2_838;
  assign net_2_7 = ~raw_encoding_i[27];
  assign net_2_8 = ~net_2_81;
  assign net_2_9 = ~net_2_335;
  assign net_2_10 = ~net_2_96;
  assign net_2_11 = ~net_2_333;
  assign net_2_13 = ~net_2_73;
  assign net_2_14 = ~net_2_180;
  assign net_2_15 = ~net_2_841;
  assign net_2_17 = ~net_2_189;
  assign net_2_18 = ~net_2_325;
  assign net_2_19 = ~net_2_354;
  assign net_2_20 = ~net_2_74;
  assign net_2_22 = ~net_2_159;
  assign net_2_24 = ~net_2_702;
  assign net_2_25 = ~net_2_432;
  assign net_2_27 = ~net_2_673;
  assign net_2_29 = ~net_2_342;
  assign net_2_30 = ~raw_encoding_i[17];
  assign net_2_31 = ~raw_encoding_i[16];
  assign net_2_32 = ~net_2_484;
  assign net_2_33 = ~net_2_276;
  assign net_2_34 = ~net_2_539;
  assign net_2_37 = ~net_2_387;
  assign net_2_38 = ~net_2_377;
  assign net_2_39 = ~net_2_952;
  assign net_2_40 = ~raw_encoding_i[14];
  assign net_2_43 = ~net_2_364;
  assign net_2_46 = ~raw_encoding_i[6];
  assign defined_sideband[5] = ~(net_2_47 & net_2_48);
  assign net_2_48 = ~(raw_encoding_i[26] & net_2_49);
  assign net_2_49 = ~(net_2_50 & net_2_51);
  assign net_2_51 = (raw_encoding_i[31] | net_2_52);
  assign net_2_52 = (net_2_53 & net_2_54);
  assign net_2_54 = (net_2_55 & net_2_56);
  assign net_2_56 = (raw_encoding_i[29] | net_2_57);
  assign net_2_57 = (net_2_58 & net_2_59);
  assign net_2_59 = ~(net_2_60 & net_2_61);
  assign net_2_58 = (net_2_62 & net_2_63);
  assign net_2_63 = ~(raw_encoding_i[27] & net_2_64);
  assign net_2_64 = ~(net_2_65 & net_2_66);
  assign net_2_66 = (net_2_67 & net_2_68);
  assign net_2_68 = (raw_encoding_i[28] | net_2_69);
  assign net_2_69 = (net_2_70 & net_2_71);
  assign net_2_71 = ~(net_2_72 & net_2_73);
  assign net_2_72 = (net_2_74 & net_2_75);
  assign net_2_75 = (raw_encoding_i[10] & net_2_76);
  assign net_2_76 = ~(raw_encoding_i[14] | net_2_1201);
  assign net_2_70 = (net_2_77 & net_2_78);
  assign net_2_78 = (net_2_79 | net_2_80);
  assign net_2_77 = ~(net_2_81 & net_2_82);
  assign net_2_67 = (net_2_83 | net_2_84);
  assign net_2_83 = ~(raw_encoding_i[15] & raw_encoding_i[13]);
  assign net_2_62 = (net_2_85 & net_2_86);
  assign net_2_86 = (net_2_87 | raw_encoding_i[11]);
  assign net_2_87 = ~(net_2_88 & net_2_89);
  assign net_2_55 = (net_2_90 & net_2_91);
  assign net_2_91 = (net_2_92 | net_2_93);
  assign net_2_93 = ~(net_2_94 | net_2_95);
  assign net_2_95 = (raw_encoding_i[27] & net_2_96);
  assign net_2_90 = (net_2_97 & net_2_98);
  assign net_2_98 = (net_2_99 | net_2_100);
  assign net_2_97 = ~(net_2_101 & raw_encoding_i[27]);
  assign net_2_101 = (net_2_102 | net_2_103);
  assign net_2_103 = ~(net_2_104 | raw_encoding_i[28]);
  assign net_2_104 = (net_2_105 & net_2_106);
  assign net_2_106 = (net_2_107 | raw_encoding_i[12]);
  assign net_2_107 = (net_2_108 & net_2_109);
  assign net_2_109 = (net_2_110 | net_2_111);
  assign net_2_111 = (net_2_112 & net_2_113);
  assign net_2_113 = (net_2_114 | net_2_115);
  assign net_2_114 = ~(net_2_116 & net_2_117);
  assign net_2_117 = (raw_encoding_i[24] & raw_encoding_i[13]);
  assign net_2_112 = ~(raw_encoding_i[10] & net_2_73);
  assign net_2_108 = (net_2_118 & net_2_119);
  assign net_2_119 = (raw_encoding_i[23] | net_2_120);
  assign net_2_118 = (raw_encoding_i[22] | net_2_121);
  assign net_2_121 = (net_2_122 | net_2_80);
  assign net_2_105 = ~(net_2_123 | net_2_124);
  assign net_2_124 = (net_2_125 & net_2_126);
  assign net_2_126 = (net_2_127 | net_2_128);
  assign net_2_53 = ~(net_2_129 & raw_encoding_i[27]);
  assign net_2_50 = ~(raw_encoding_i[28] & net_2_130);
  assign net_2_130 = ~(net_2_131 & net_2_132);
  assign net_2_132 = (raw_encoding_i[27] | raw_encoding_i[30]);
  assign net_2_131 = ~(net_2_1203 & net_2_133);
  assign net_2_133 = ~(net_2_134 & net_2_135);
  assign net_2_135 = ~(net_2_136 & net_2_137);
  assign net_2_134 = ~(net_2_7 & net_2_138);
  assign net_2_138 = (net_2_139 | net_2_140);
  assign net_2_139 = (raw_encoding_i[31] & net_2_141);
  assign net_2_141 = ~(net_2_142 & net_2_143);
  assign net_2_143 = (net_2_144 | raw_encoding_i[18]);
  assign net_2_144 = ~(net_2_145 & net_2_146);
  assign net_2_145 = (net_2_147 | net_2_148);
  assign net_2_148 = (net_2_149 & net_2_150);
  assign net_2_150 = ~(net_2_151 & raw_encoding_i[12]);
  assign net_2_142 = (net_2_152 & net_2_153);
  assign net_2_153 = ~(net_2_154 & net_2_155);
  assign net_2_155 = ~(raw_encoding_i[11] | net_2_156);
  assign net_2_154 = ~(net_2_157 & net_2_158);
  assign net_2_158 = ~(raw_encoding_i[21] & net_2_159);
  assign net_2_157 = ~(raw_encoding_i[25] & net_2_160);
  assign net_2_160 = ~(net_2_161 & net_2_17);
  assign net_2_47 = (net_2_162 | net_2_163);
  assign net_2_163 = ~(raw_encoding_i[29] & net_2_164);
  assign defined_sideband[4] = ~(net_2_165 & net_2_166);
  assign net_2_166 = ~(raw_encoding_i[27] & net_2_167);
  assign net_2_167 = (net_2_168 | net_2_169);
  assign net_2_169 = ~(net_2_170 & net_2_171);
  assign net_2_171 = ~(raw_encoding_i[29] & net_2_172);
  assign net_2_172 = ~(raw_encoding_i[25] | net_2_173);
  assign net_2_173 = (net_2_174 & net_2_175);
  assign net_2_175 = (net_2_176 & net_2_162);
  assign net_2_162 = (net_2_177 & net_2_178);
  assign net_2_178 = ~(net_2_179 & net_2_180);
  assign net_2_177 = (raw_encoding_i[28] | raw_encoding_i[30]);
  assign net_2_176 = (net_2_181 | net_2_182);
  assign net_2_181 = (net_2_17 & net_2_183);
  assign net_2_183 = (net_2_184 | raw_encoding_i[22]);
  assign net_2_184 = ~(net_2_185 & net_2_186);
  assign net_2_186 = (net_2_187 | raw_encoding_i[24]);
  assign net_2_187 = ~(raw_encoding_i[10] | net_2_188);
  assign net_2_188 = (raw_encoding_i[21] ^ raw_encoding_i[11]);
  assign net_2_174 = (net_2_190 | net_2_191);
  assign net_2_191 = (net_2_192 | raw_encoding_i[26]);
  assign net_2_192 = (net_2_73 & net_2_43);
  assign net_2_170 = (raw_encoding_i[31] | net_2_193);
  assign net_2_193 = (net_2_194 & net_2_195);
  assign net_2_195 = ~(raw_encoding_i[26] & net_2_196);
  assign net_2_196 = (net_2_197 | net_2_102);
  assign net_2_102 = ~(net_2_198 & net_2_199);
  assign net_2_199 = (net_2_200 | net_2_201);
  assign net_2_200 = ~(net_2_1196 & net_2_1193);
  assign net_2_198 = (net_2_202 & net_2_203);
  assign net_2_203 = (raw_encoding_i[28] | net_2_204);
  assign net_2_204 = (net_2_205 & net_2_206);
  assign net_2_206 = (net_2_207 & net_2_208);
  assign net_2_208 = (net_2_209 & net_2_210);
  assign net_2_210 = ~(net_2_211 & net_2_212);
  assign net_2_212 = ~(net_2_213 & net_2_214);
  assign net_2_214 = ~(raw_encoding_i[13] & net_2_215);
  assign net_2_215 = (net_2_32 & net_2_216);
  assign net_2_213 = (net_2_217 & net_2_218);
  assign net_2_218 = ~(net_2_219 & net_2_34);
  assign net_2_217 = ~(net_2_74 & net_2_128);
  assign net_2_209 = ~(net_2_73 & net_2_220);
  assign net_2_220 = ~(net_2_221 | net_2_92);
  assign net_2_221 = ~(raw_encoding_i[20] & net_2_222);
  assign net_2_222 = (net_2_223 & net_2_224);
  assign net_2_224 = ~(net_2_225 & net_2_226);
  assign net_2_226 = (net_2_227 | raw_encoding_i[23]);
  assign net_2_227 = ~(net_2_228 & net_2_229);
  assign net_2_225 = ~(raw_encoding_i[23] & net_2_230);
  assign net_2_230 = (net_2_231 & net_2_232);
  assign net_2_207 = (net_2_233 & net_2_234);
  assign net_2_234 = ~(raw_encoding_i[25] & net_2_235);
  assign net_2_235 = (net_2_236 | net_2_237);
  assign net_2_237 = (raw_encoding_i[21] & net_2_238);
  assign net_2_238 = (net_2_239 | net_2_240);
  assign net_2_239 = ~(net_2_241 | raw_encoding_i[24]);
  assign net_2_241 = (net_2_242 & net_2_243);
  assign net_2_243 = ~(net_2_244 & net_2_245);
  assign net_2_245 = (net_2_74 & net_2_246);
  assign net_2_242 = (net_2_247 & net_2_248);
  assign net_2_248 = ~(net_2_249 & raw_encoding_i[11]);
  assign net_2_249 = (net_2_232 & net_2_250);
  assign net_2_250 = ~(net_2_251 & net_2_252);
  assign net_2_252 = (net_2_253 | raw_encoding_i[16]);
  assign net_2_253 = ~(net_2_1196 & net_2_254);
  assign net_2_251 = (net_2_255 & net_2_256);
  assign net_2_256 = (raw_encoding_i[20] | net_2_257);
  assign net_2_255 = ~(raw_encoding_i[15] & net_2_277);
  assign net_2_277 = (raw_encoding_i[20] & net_2_128);
  assign net_2_128 = (net_2_1194 & net_2_278);
  assign net_2_247 = ~(raw_encoding_i[10] & net_2_279);
  assign net_2_279 = ~(net_2_39 & net_2_280);
  assign net_2_280 = (raw_encoding_i[15] & net_2_281);
  assign net_2_281 = ~(net_2_282 & raw_encoding_i[12]);
  assign net_2_233 = ~(raw_encoding_i[29] & net_2_283);
  assign net_2_283 = ~(raw_encoding_i[25] & net_2_284);
  assign net_2_284 = (net_2_285 & net_2_286);
  assign net_2_286 = ~(net_2_1192 & net_2_287);
  assign net_2_285 = (net_2_288 & net_2_289);
  assign net_2_289 = ~(net_2_290 & net_2_73);
  assign net_2_290 = ~(net_2_291 & net_2_292);
  assign net_2_292 = ~(net_2_293 & net_2_1194);
  assign net_2_291 = (net_2_294 & net_2_295);
  assign net_2_295 = (net_2_296 | net_2_20);
  assign net_2_294 = (net_2_297 & net_2_298);
  assign net_2_298 = ~(net_2_299 & net_2_246);
  assign net_2_299 = ~(net_2_300 & net_2_301);
  assign net_2_301 = ~(net_2_302 & net_2_266);
  assign net_2_300 = (net_2_303 & net_2_304);
  assign net_2_304 = ~(net_2_219 & net_2_305);
  assign net_2_303 = ~(net_2_306 & net_2_278);
  assign net_2_297 = (net_2_307 | raw_encoding_i[15]);
  assign net_2_307 = ~(net_2_308 & net_2_282);
  assign net_2_288 = ~(raw_encoding_i[24] & net_2_309);
  assign net_2_309 = ~(raw_encoding_i[15] | net_2_310);
  assign net_2_310 = (net_2_311 & net_2_312);
  assign net_2_312 = (net_2_296 | raw_encoding_i[23]);
  assign net_2_296 = ~(raw_encoding_i[10] & net_2_1193);
  assign net_2_311 = (net_2_313 | net_2_314);
  assign net_2_313 = (raw_encoding_i[10] | raw_encoding_i[12]);
  assign net_2_205 = (net_2_315 & net_2_316);
  assign net_2_316 = (net_2_39 | net_2_317);
  assign net_2_315 = (net_2_318 & net_2_319);
  assign net_2_319 = (net_2_80 | net_2_320);
  assign net_2_320 = (net_2_321 & net_2_322);
  assign net_2_322 = ~(raw_encoding_i[10] & net_2_323);
  assign net_2_323 = ~(net_2_19 & net_2_324);
  assign net_2_324 = ~(raw_encoding_i[14] & raw_encoding_i[12]);
  assign net_2_321 = (net_2_325 | raw_encoding_i[15]);
  assign net_2_318 = (raw_encoding_i[15] | net_2_326);
  assign net_2_326 = (net_2_327 & net_2_328);
  assign net_2_328 = (net_2_329 | raw_encoding_i[10]);
  assign net_2_329 = (net_2_330 & net_2_331);
  assign net_2_331 = ~(net_2_332 & net_2_333);
  assign net_2_332 = ~(raw_encoding_i[24] | net_2_22);
  assign net_2_330 = ~(raw_encoding_i[13] & net_2_334);
  assign net_2_334 = (net_2_308 & net_2_335);
  assign net_2_327 = ~(net_2_336 & net_2_278);
  assign net_2_336 = ~(net_2_337 | raw_encoding_i[30]);
  assign net_2_337 = ~(net_2_338 & net_2_339);
  assign net_2_339 = (net_2_340 & net_2_341);
  assign net_2_340 = (raw_encoding_i[11] & net_2_116);
  assign net_2_338 = ~(net_2_342 & net_2_343);
  assign net_2_343 = ~(raw_encoding_i[12] & raw_encoding_i[18]);
  assign net_2_202 = (net_2_344 & net_2_345);
  assign net_2_345 = (net_2_346 | raw_encoding_i[23]);
  assign net_2_346 = ~(net_2_115 & net_2_347);
  assign net_2_347 = (raw_encoding_i[30] & net_2_348);
  assign net_2_344 = (net_2_349 | raw_encoding_i[10]);
  assign net_2_349 = (raw_encoding_i[29] | net_2_350);
  assign net_2_350 = ~(net_2_351 & net_2_352);
  assign net_2_352 = (net_2_32 & net_2_353);
  assign net_2_353 = (net_2_354 & net_2_355);
  assign net_2_197 = ~(net_2_356 & net_2_357);
  assign net_2_357 = (raw_encoding_i[29] | net_2_358);
  assign net_2_358 = (net_2_359 & net_2_360);
  assign net_2_360 = (net_2_32 | net_2_84);
  assign net_2_84 = ~(net_2_246 & net_2_361);
  assign net_2_361 = (net_2_362 & net_2_363);
  assign net_2_363 = (net_2_219 & net_2_306);
  assign net_2_306 = (raw_encoding_i[16] & net_2_364);
  assign net_2_362 = (net_2_365 & net_2_73);
  assign net_2_359 = (net_2_65 & net_2_366);
  assign net_2_366 = (net_2_85 & net_2_367);
  assign net_2_367 = (raw_encoding_i[30] | net_2_368);
  assign net_2_368 = ~(net_2_88 & net_2_333);
  assign net_2_88 = (net_2_369 & net_2_370);
  assign net_2_370 = ~(raw_encoding_i[17] & net_2_371);
  assign net_2_371 = ~(raw_encoding_i[15] & net_2_372);
  assign net_2_372 = (raw_encoding_i[16] | net_2_373);
  assign net_2_373 = ~(raw_encoding_i[18] | raw_encoding_i[22]);
  assign net_2_369 = (net_2_73 & net_2_374);
  assign net_2_374 = ~(net_2_115 | net_2_375);
  assign net_2_375 = (raw_encoding_i[13] | net_2_376);
  assign net_2_376 = ~(net_2_377 & net_2_1199);
  assign net_2_85 = ~(net_2_378 & net_2_89);
  assign net_2_378 = ~(net_2_379 & net_2_380);
  assign net_2_380 = ~(net_2_381 & net_2_73);
  assign net_2_381 = ~(net_2_382 & net_2_383);
  assign net_2_383 = (net_2_115 | net_2_384);
  assign net_2_384 = (net_2_385 & net_2_386);
  assign net_2_386 = ~(net_2_387 & net_2_388);
  assign net_2_385 = (raw_encoding_i[18] | net_2_389);
  assign net_2_389 = (raw_encoding_i[16] | net_2_390);
  assign net_2_390 = (net_2_391 & net_2_392);
  assign net_2_392 = (net_2_393 | net_2_18);
  assign net_2_393 = (net_2_394 | raw_encoding_i[11]);
  assign net_2_394 = ~(raw_encoding_i[17] & net_2_244);
  assign net_2_244 = (net_2_263 & net_2_377);
  assign net_2_391 = ~(net_2_302 & net_2_395);
  assign net_2_382 = (net_2_396 | raw_encoding_i[23]);
  assign net_2_396 = (net_2_397 & net_2_398);
  assign net_2_398 = (net_2_399 | net_2_400);
  assign net_2_399 = (net_2_401 | net_2_402);
  assign net_2_402 = (net_2_1194 | raw_encoding_i[11]);
  assign net_2_397 = (net_2_403 & net_2_404);
  assign net_2_404 = (net_2_405 | raw_encoding_i[2]);
  assign net_2_405 = (net_2_406 | net_2_275);
  assign net_2_403 = (net_2_407 & net_2_408);
  assign net_2_408 = ~(raw_encoding_i[11] & net_2_409);
  assign net_2_409 = ~(raw_encoding_i[15] & net_2_265);
  assign net_2_265 = (raw_encoding_i[13] | net_2_39);
  assign net_2_407 = ~(raw_encoding_i[10] | net_2_410);
  assign net_2_410 = (raw_encoding_i[18] & net_2_411);
  assign net_2_411 = ~(net_2_276 | net_2_115);
  assign net_2_379 = ~(net_2_1199 & net_2_355);
  assign net_2_65 = (net_2_412 & net_2_413);
  assign net_2_413 = (raw_encoding_i[28] | net_2_414);
  assign net_2_414 = (net_2_415 & net_2_416);
  assign net_2_416 = ~(raw_encoding_i[24] & net_2_417);
  assign net_2_417 = (net_2_418 | net_2_419);
  assign net_2_419 = (net_2_263 & net_2_420);
  assign net_2_420 = (net_2_421 | net_2_422);
  assign net_2_422 = (net_2_219 & net_2_1196);
  assign net_2_421 = (raw_encoding_i[15] & net_2_216);
  assign net_2_216 = (raw_encoding_i[25] & net_2_302);
  assign net_2_302 = ~(raw_encoding_i[12] | net_2_19);
  assign net_2_418 = ~(raw_encoding_i[10] | net_2_423);
  assign net_2_423 = ~(net_2_424 & net_2_74);
  assign net_2_424 = ~(net_2_425 & net_2_426);
  assign net_2_426 = (net_2_427 | raw_encoding_i[13]);
  assign net_2_427 = ~(raw_encoding_i[25] & raw_encoding_i[15]);
  assign net_2_425 = ~(net_2_273 | net_2_266);
  assign net_2_273 = ~(raw_encoding_i[14] | net_2_1194);
  assign net_2_415 = (net_2_428 & net_2_429);
  assign net_2_429 = (net_2_430 & net_2_431);
  assign net_2_431 = (net_2_20 | net_2_432);
  assign net_2_430 = (net_2_433 | net_2_434);
  assign net_2_412 = (net_2_435 & net_2_436);
  assign net_2_436 = (net_2_437 & net_2_438);
  assign net_2_438 = ~(net_2_61 & net_2_1200);
  assign net_2_437 = (net_2_439 & net_2_440);
  assign net_2_440 = (net_2_441 & net_2_442);
  assign net_2_442 = (net_2_443 | net_2_444);
  assign net_2_444 = ~(net_2_354 & net_2_355);
  assign net_2_441 = (raw_encoding_i[23] | net_2_445);
  assign net_2_439 = (net_2_448 | raw_encoding_i[15]);
  assign net_2_448 = (net_2_449 & net_2_450);
  assign net_2_450 = ~(raw_encoding_i[12] & net_2_451);
  assign net_2_449 = (net_2_452 & net_2_453);
  assign net_2_453 = (net_2_19 | net_2_447);
  assign net_2_447 = ~(net_2_454 & net_2_38);
  assign net_2_452 = (net_2_455 | net_2_456);
  assign net_2_456 = (net_2_457 | net_2_458);
  assign net_2_458 = (raw_encoding_i[14] | net_2_459);
  assign net_2_459 = ~(raw_encoding_i[19] & net_2_460);
  assign net_2_457 = (net_2_22 | net_2_461);
  assign net_2_461 = (net_2_462 | net_2_13);
  assign net_2_462 = ~(net_2_1194 | net_2_263);
  assign net_2_435 = (raw_encoding_i[10] | net_2_463);
  assign net_2_463 = (net_2_122 | net_2_464);
  assign net_2_464 = ~(raw_encoding_i[30] & net_2_465);
  assign net_2_465 = (net_2_333 & net_2_466);
  assign net_2_466 = (net_2_287 | net_2_467);
  assign net_2_467 = (net_2_468 & raw_encoding_i[15]);
  assign net_2_468 = (raw_encoding_i[12] & net_2_469);
  assign net_2_469 = (net_2_470 | net_2_471);
  assign net_2_471 = (net_2_354 & net_2_73);
  assign net_2_470 = (raw_encoding_i[21] & net_2_74);
  assign net_2_287 = ~(raw_encoding_i[24] | net_2_472);
  assign net_2_356 = ~(net_2_473 | net_2_129);
  assign net_2_129 = (raw_encoding_i[30] & net_2_474);
  assign net_2_474 = ~(net_2_475 & net_2_476);
  assign net_2_476 = (net_2_477 & net_2_478);
  assign net_2_478 = ~(raw_encoding_i[25] & net_2_479);
  assign net_2_479 = (net_2_480 | net_2_236);
  assign net_2_236 = (net_2_481 & net_2_482);
  assign net_2_482 = ~(raw_encoding_i[11] ^ raw_encoding_i[12]);
  assign net_2_481 = (net_2_483 & net_2_484);
  assign net_2_483 = (net_2_293 & net_2_485);
  assign net_2_485 = (net_2_486 | net_2_487);
  assign net_2_487 = (net_2_354 & raw_encoding_i[24]);
  assign net_2_293 = (raw_encoding_i[13] & raw_encoding_i[10]);
  assign net_2_480 = ~(net_2_488 & net_2_489);
  assign net_2_489 = (raw_encoding_i[24] | net_2_490);
  assign net_2_490 = (net_2_491 & net_2_492);
  assign net_2_492 = ~(net_2_159 & net_2_493);
  assign net_2_493 = ~(net_2_494 & net_2_495);
  assign net_2_495 = ~(raw_encoding_i[10] & net_2_496);
  assign net_2_496 = (net_2_497 & net_2_498);
  assign net_2_498 = ~(net_2_499 & net_2_500);
  assign net_2_500 = ~(net_2_501 & net_2_502);
  assign net_2_501 = ~(net_2_503 & net_2_504);
  assign net_2_504 = (raw_encoding_i[13] | net_2_505);
  assign net_2_505 = ~(raw_encoding_i[18] | net_2_29);
  assign net_2_503 = ~(raw_encoding_i[19] & net_2_506);
  assign net_2_506 = ~(net_2_1194 | net_2_507);
  assign net_2_499 = ~(raw_encoding_i[18] & net_2_387);
  assign net_2_494 = (raw_encoding_i[29] | net_2_508);
  assign net_2_508 = (net_2_509 & net_2_510);
  assign net_2_510 = (raw_encoding_i[28] | net_2_511);
  assign net_2_511 = ~(net_2_512 & net_2_513);
  assign net_2_513 = ~(net_2_1197 | net_2_455);
  assign net_2_455 = (raw_encoding_i[20] | net_2_507);
  assign net_2_507 = (raw_encoding_i[18] | net_2_29);
  assign net_2_509 = (raw_encoding_i[11] | net_2_514);
  assign net_2_514 = (net_2_515 & net_2_516);
  assign net_2_516 = (raw_encoding_i[13] | net_2_517);
  assign net_2_515 = (net_2_518 | raw_encoding_i[10]);
  assign net_2_518 = (net_2_24 | raw_encoding_i[12]);
  assign net_2_491 = ~(raw_encoding_i[21] & net_2_519);
  assign net_2_519 = ~(net_2_520 & net_2_521);
  assign net_2_521 = (net_2_522 & net_2_523);
  assign net_2_523 = ~(raw_encoding_i[10] & net_2_524);
  assign net_2_524 = ~(net_2_525 & net_2_526);
  assign net_2_526 = ~(raw_encoding_i[13] & net_2_527);
  assign net_2_527 = (net_2_484 & net_2_528);
  assign net_2_528 = ~(net_2_529 & net_2_530);
  assign net_2_530 = ~(net_2_223 & raw_encoding_i[28]);
  assign net_2_223 = (raw_encoding_i[11] & raw_encoding_i[12]);
  assign net_2_525 = (net_2_531 & net_2_532);
  assign net_2_532 = (net_2_533 & net_2_534);
  assign net_2_534 = ~(net_2_254 & net_2_535);
  assign net_2_535 = ~(raw_encoding_i[15] & net_2_536);
  assign net_2_536 = (net_2_314 | raw_encoding_i[11]);
  assign net_2_254 = (raw_encoding_i[12] & net_2_278);
  assign net_2_533 = (net_2_537 & net_2_538);
  assign net_2_538 = (net_2_539 | raw_encoding_i[12]);
  assign net_2_531 = ~(net_2_540 & net_2_541);
  assign net_2_541 = ~(net_2_542 & raw_encoding_i[15]);
  assign net_2_542 = ~(net_2_543 & net_2_544);
  assign net_2_544 = (raw_encoding_i[12] & net_2_545);
  assign net_2_545 = (raw_encoding_i[29] | raw_encoding_i[11]);
  assign net_2_543 = (raw_encoding_i[11] ^ raw_encoding_i[23]);
  assign net_2_522 = (raw_encoding_i[29] | net_2_546);
  assign net_2_546 = ~(net_2_547 & net_2_548);
  assign net_2_548 = (raw_encoding_i[12] & net_2_364);
  assign net_2_520 = ~(net_2_549 & net_2_550);
  assign net_2_550 = ~(net_2_551 & net_2_552);
  assign net_2_552 = (net_2_553 & net_2_554);
  assign net_2_554 = (net_2_443 | net_2_555);
  assign net_2_555 = ~(net_2_556 | net_2_219);
  assign net_2_556 = (raw_encoding_i[16] & net_2_1199);
  assign net_2_443 = ~(net_2_263 & net_2_484);
  assign net_2_553 = ~(raw_encoding_i[16] & net_2_33);
  assign net_2_276 = ~(net_2_377 & net_2_395);
  assign net_2_551 = (raw_encoding_i[10] | net_2_557);
  assign net_2_557 = (net_2_558 & net_2_559);
  assign net_2_559 = (raw_encoding_i[16] | net_2_560);
  assign net_2_560 = (net_2_561 & net_2_562);
  assign net_2_562 = (net_2_563 & net_2_539);
  assign net_2_563 = (raw_encoding_i[29] | net_2_564);
  assign net_2_564 = ~(raw_encoding_i[15] & net_2_264);
  assign net_2_264 = ~(raw_encoding_i[12] | net_2_1199);
  assign net_2_561 = ~(net_2_266 & raw_encoding_i[12]);
  assign net_2_558 = ~(net_2_565 & raw_encoding_i[15]);
  assign net_2_565 = (net_2_278 & net_2_529);
  assign net_2_529 = ~(raw_encoding_i[29] & net_2_1194);
  assign net_2_549 = (net_2_246 & raw_encoding_i[11]);
  assign net_2_246 = ~(raw_encoding_i[17] | net_2_27);
  assign net_2_488 = ~(net_2_211 & net_2_566);
  assign net_2_566 = (raw_encoding_i[23] & net_2_567);
  assign net_2_567 = ~(net_2_568 & net_2_569);
  assign net_2_569 = ~(raw_encoding_i[12] & net_2_34);
  assign net_2_568 = (raw_encoding_i[29] | net_2_570);
  assign net_2_570 = (net_2_571 & net_2_572);
  assign net_2_572 = (raw_encoding_i[22] | net_2_573);
  assign net_2_573 = ~(net_2_228 | net_2_574);
  assign net_2_574 = (raw_encoding_i[12] & net_2_32);
  assign net_2_571 = ~(net_2_395 & raw_encoding_i[12]);
  assign net_2_211 = ~(raw_encoding_i[10] | net_2_1200);
  assign net_2_477 = ~(raw_encoding_i[29] & net_2_575);
  assign net_2_575 = ~(net_2_576 & net_2_577);
  assign net_2_577 = (raw_encoding_i[15] | net_2_578);
  assign net_2_578 = (net_2_579 & net_2_580);
  assign net_2_580 = (raw_encoding_i[24] | net_2_581);
  assign net_2_581 = ~(net_2_116 & net_2_1202);
  assign net_2_579 = (net_2_582 | raw_encoding_i[11]);
  assign net_2_582 = ~(net_2_354 & net_2_583);
  assign net_2_576 = ~(net_2_584 & net_2_585);
  assign net_2_585 = ~(net_2_586 & net_2_587);
  assign net_2_587 = ~(net_2_364 & net_2_588);
  assign net_2_588 = ~(net_2_589 & net_2_590);
  assign net_2_590 = ~(raw_encoding_i[16] & net_2_591);
  assign net_2_591 = ~(raw_encoding_i[20] | net_2_592);
  assign net_2_592 = (raw_encoding_i[12] | net_2_593);
  assign net_2_593 = (net_2_594 & net_2_595);
  assign net_2_595 = ~(net_2_266 & net_2_354);
  assign net_2_594 = ~(net_2_278 & raw_encoding_i[25]);
  assign net_2_589 = ~(net_2_596 & net_2_597);
  assign net_2_597 = (raw_encoding_i[28] & raw_encoding_i[23]);
  assign net_2_596 = (raw_encoding_i[25] & net_2_598);
  assign net_2_598 = ~(net_2_599 & net_2_600);
  assign net_2_600 = (raw_encoding_i[12] | net_2_601);
  assign net_2_601 = ~(net_2_31 & net_2_228);
  assign net_2_228 = ~(raw_encoding_i[13] | net_2_32);
  assign net_2_599 = ~(raw_encoding_i[20] & net_2_602);
  assign net_2_602 = (net_2_231 & raw_encoding_i[12]);
  assign net_2_231 = (raw_encoding_i[16] & net_2_603);
  assign net_2_586 = (raw_encoding_i[16] | net_2_604);
  assign net_2_604 = ~(raw_encoding_i[20] & net_2_605);
  assign net_2_605 = (net_2_484 & net_2_606);
  assign net_2_606 = ~(net_2_607 & net_2_608);
  assign net_2_608 = ~(raw_encoding_i[25] & net_2_609);
  assign net_2_609 = (net_2_351 & net_2_610);
  assign net_2_610 = (net_2_611 | net_2_460);
  assign net_2_460 = (raw_encoding_i[28] & raw_encoding_i[11]);
  assign net_2_611 = ~(raw_encoding_i[22] | net_2_43);
  assign net_2_607 = (raw_encoding_i[13] | net_2_612);
  assign net_2_612 = (net_2_613 & net_2_614);
  assign net_2_614 = ~(net_2_364 & net_2_179);
  assign net_2_613 = (net_2_615 | raw_encoding_i[10]);
  assign net_2_615 = (net_2_616 | raw_encoding_i[28]);
  assign net_2_616 = (raw_encoding_i[22] | raw_encoding_i[12]);
  assign net_2_584 = (net_2_232 & net_2_73);
  assign net_2_475 = (net_2_617 & net_2_618);
  assign net_2_618 = ~(net_2_451 & net_2_502);
  assign net_2_502 = (net_2_1196 & net_2_40);
  assign net_2_451 = (net_2_486 & net_2_454);
  assign net_2_617 = (net_2_619 & net_2_620);
  assign net_2_620 = ~(net_2_621 & net_2_622);
  assign net_2_622 = ~(net_2_623 | raw_encoding_i[28]);
  assign net_2_623 = ~(raw_encoding_i[23] & net_2_25);
  assign net_2_432 = ~(raw_encoding_i[13] & net_2_624);
  assign net_2_619 = (net_2_625 & net_2_626);
  assign net_2_626 = (raw_encoding_i[28] | net_2_428);
  assign net_2_625 = ~(net_2_348 & net_2_486);
  assign net_2_486 = (raw_encoding_i[21] & net_2_1199);
  assign net_2_348 = (net_2_583 & net_2_627);
  assign net_2_627 = ~(net_2_628 & net_2_629);
  assign net_2_629 = ~(raw_encoding_i[25] & net_2_630);
  assign net_2_630 = ~(raw_encoding_i[22] | net_2_539);
  assign net_2_628 = (net_2_110 | raw_encoding_i[15]);
  assign net_2_473 = ~(raw_encoding_i[28] | net_2_631);
  assign net_2_631 = ~(net_2_632 | net_2_633);
  assign net_2_633 = ~(raw_encoding_i[12] | net_2_634);
  assign net_2_634 = (net_2_635 & net_2_636);
  assign net_2_636 = (net_2_120 | raw_encoding_i[22]);
  assign net_2_120 = (net_2_637 | net_2_13);
  assign net_2_637 = (net_2_434 & net_2_638);
  assign net_2_638 = (raw_encoding_i[14] | net_2_110);
  assign net_2_110 = ~(raw_encoding_i[29] & net_2_1193);
  assign net_2_434 = (raw_encoding_i[13] | net_2_11);
  assign net_2_635 = (net_2_639 & net_2_640);
  assign net_2_640 = (net_2_428 & net_2_641);
  assign net_2_641 = (net_2_9 | net_2_642);
  assign net_2_642 = (net_2_643 & net_2_644);
  assign net_2_643 = ~(raw_encoding_i[23] & net_2_266);
  assign net_2_266 = (raw_encoding_i[13] & net_2_1196);
  assign net_2_639 = (net_2_645 | net_2_80);
  assign net_2_80 = ~(net_2_73 & net_2_333);
  assign net_2_73 = ~(raw_encoding_i[24] | net_2_1197);
  assign net_2_645 = (net_2_646 & net_2_647);
  assign net_2_647 = (raw_encoding_i[23] | net_2_122);
  assign net_2_632 = (net_2_648 | net_2_123);
  assign net_2_123 = ~(net_2_649 & net_2_650);
  assign net_2_650 = ~(net_2_115 & net_2_651);
  assign net_2_651 = (net_2_355 & net_2_240);
  assign net_2_240 = (net_2_116 & net_2_34);
  assign net_2_355 = (raw_encoding_i[24] & raw_encoding_i[25]);
  assign net_2_649 = (net_2_652 & net_2_653);
  assign net_2_653 = (net_2_122 | net_2_428);
  assign net_2_428 = (raw_encoding_i[21] | net_2_654);
  assign net_2_654 = (net_2_115 | net_2_317);
  assign net_2_317 = ~(net_2_159 & net_2_454);
  assign net_2_454 = (net_2_333 & net_2_583);
  assign net_2_583 = (raw_encoding_i[24] & raw_encoding_i[10]);
  assign net_2_652 = (net_2_655 | net_2_656);
  assign net_2_655 = (net_2_657 & net_2_658);
  assign net_2_658 = ~(net_2_335 & net_2_659);
  assign net_2_659 = ~(raw_encoding_i[15] | net_2_660);
  assign net_2_660 = ~(net_2_661 | net_2_662);
  assign net_2_661 = ~(net_2_663 & net_2_664);
  assign net_2_664 = (net_2_1195 | raw_encoding_i[11]);
  assign net_2_663 = (raw_encoding_i[10] | raw_encoding_i[30]);
  assign net_2_657 = (raw_encoding_i[25] | net_2_665);
  assign net_2_648 = (net_2_341 & net_2_666);
  assign net_2_666 = (net_2_667 | net_2_82);
  assign net_2_82 = ~(net_2_668 & net_2_669);
  assign net_2_669 = ~(raw_encoding_i[21] & net_2_670);
  assign net_2_670 = ~(net_2_671 & net_2_672);
  assign net_2_672 = ~(net_2_673 & net_2_674);
  assign net_2_674 = ~(net_2_675 & net_2_676);
  assign net_2_676 = ~(net_2_305 & net_2_677);
  assign net_2_677 = ~(raw_encoding_i[17] | net_2_678);
  assign net_2_678 = (raw_encoding_i[14] & net_2_679);
  assign net_2_679 = (raw_encoding_i[16] | net_2_1199);
  assign net_2_305 = (raw_encoding_i[15] & net_2_364);
  assign net_2_675 = (net_2_680 & net_2_681);
  assign net_2_681 = ~(net_2_342 & net_2_682);
  assign net_2_682 = ~(net_2_683 & net_2_684);
  assign net_2_684 = (net_2_22 | raw_encoding_i[15]);
  assign net_2_683 = (raw_encoding_i[14] | net_2_43);
  assign net_2_680 = ~(net_2_603 & net_2_685);
  assign net_2_685 = ~(raw_encoding_i[23] | raw_encoding_i[17]);
  assign net_2_671 = (net_2_686 & net_2_687);
  assign net_2_687 = ~(raw_encoding_i[11] & net_2_547);
  assign net_2_547 = (net_2_232 & net_2_688);
  assign net_2_688 = (net_2_270 & net_2_278);
  assign net_2_270 = (raw_encoding_i[15] & raw_encoding_i[16]);
  assign net_2_232 = (net_2_30 & net_2_689);
  assign net_2_686 = (net_2_690 & net_2_691);
  assign net_2_691 = ~(net_2_692 & net_2_314);
  assign net_2_314 = ~(raw_encoding_i[23] ^ raw_encoding_i[22]);
  assign net_2_692 = (net_2_693 & net_2_694);
  assign net_2_694 = ~(raw_encoding_i[12] | raw_encoding_i[11]);
  assign net_2_693 = ~(raw_encoding_i[23] & net_2_695);
  assign net_2_695 = ~(net_2_274 & net_2_122);
  assign net_2_274 = ~(raw_encoding_i[10] | net_2_1196);
  assign net_2_690 = (net_2_696 & net_2_697);
  assign net_2_697 = (net_2_219 | net_2_646);
  assign net_2_646 = ~(raw_encoding_i[10] & net_2_1195);
  assign net_2_219 = (raw_encoding_i[23] & raw_encoding_i[12]);
  assign net_2_696 = ~(net_2_698 & net_2_351);
  assign net_2_351 = (raw_encoding_i[13] & raw_encoding_i[12]);
  assign net_2_668 = (net_2_699 & net_2_700);
  assign net_2_700 = ~(net_2_701 & net_2_624);
  assign net_2_624 = (net_2_702 & net_2_364);
  assign net_2_701 = (raw_encoding_i[12] | net_2_703);
  assign net_2_703 = (raw_encoding_i[13] & net_2_1199);
  assign net_2_699 = (net_2_433 | net_2_704);
  assign net_2_704 = (net_2_705 & net_2_706);
  assign net_2_706 = (raw_encoding_i[13] | net_2_689);
  assign net_2_705 = ~(raw_encoding_i[11] & net_2_29);
  assign net_2_433 = ~(net_2_387 & net_2_116);
  assign net_2_116 = (raw_encoding_i[10] & net_2_159);
  assign net_2_667 = (raw_encoding_i[21] & net_2_707);
  assign net_2_707 = (net_2_708 | net_2_709);
  assign net_2_709 = ~(net_2_79 | raw_encoding_i[11]);
  assign net_2_79 = (net_2_710 | net_2_122);
  assign net_2_710 = (net_2_1199 ^ raw_encoding_i[22]);
  assign net_2_708 = (net_2_698 & net_2_711);
  assign net_2_194 = (net_2_712 & net_2_713);
  assign net_2_713 = (raw_encoding_i[28] | net_2_714);
  assign net_2_714 = (net_2_201 | net_2_539);
  assign net_2_201 = ~(net_2_125 & net_2_136);
  assign net_2_136 = ~(raw_encoding_i[24] | raw_encoding_i[30]);
  assign net_2_125 = ~(net_2_9 | net_2_656);
  assign net_2_712 = ~(raw_encoding_i[29] & net_2_715);
  assign net_2_715 = ~(net_2_716 & net_2_717);
  assign net_2_717 = (raw_encoding_i[25] | net_2_718);
  assign net_2_718 = (net_2_719 & net_2_720);
  assign net_2_720 = (raw_encoding_i[30] | net_2_14);
  assign net_2_719 = (net_2_721 & net_2_722);
  assign net_2_722 = (net_2_182 | net_2_43);
  assign net_2_721 = (net_2_18 | raw_encoding_i[28]);
  assign net_2_716 = ~(net_2_723 & net_2_724);
  assign net_2_724 = (net_2_96 | net_2_335);
  assign net_2_723 = ~(net_2_182 & net_2_725);
  assign net_2_725 = ~(net_2_354 & net_2_96);
  assign net_2_168 = (net_2_137 & net_2_726);
  assign net_2_726 = (net_2_727 & net_2_621);
  assign net_2_621 = ~(raw_encoding_i[29] | raw_encoding_i[24]);
  assign net_2_137 = (net_2_728 | net_2_729);
  assign net_2_729 = ~(raw_encoding_i[25] & net_2_730);
  assign net_2_730 = (raw_encoding_i[11] | net_2_731);
  assign net_2_731 = ~(net_2_732 & net_2_733);
  assign net_2_732 = (net_2_734 | net_2_735);
  assign net_2_735 = ~(raw_encoding_i[23] | net_2_736);
  assign net_2_736 = ~(net_2_737 | net_2_738);
  assign net_2_738 = (net_2_739 & raw_encoding_i[21]);
  assign net_2_739 = ~(raw_encoding_i[17] | net_2_740);
  assign net_2_740 = (raw_encoding_i[18] & net_2_115);
  assign net_2_734 = (net_2_741 & net_2_742);
  assign net_2_742 = ~(raw_encoding_i[20] | net_2_743);
  assign net_2_743 = (net_2_744 & net_2_745);
  assign net_2_745 = ~(raw_encoding_i[17] & net_2_746);
  assign net_2_744 = (raw_encoding_i[19] | net_2_19);
  assign net_2_728 = (net_2_189 & net_2_747);
  assign net_2_747 = (net_2_737 | net_2_748);
  assign net_2_748 = ~(raw_encoding_i[17] | net_2_749);
  assign net_2_749 = (raw_encoding_i[18] | net_2_750);
  assign net_2_750 = ~(raw_encoding_i[20] & raw_encoding_i[19]);
  assign net_2_165 = (net_2_751 | raw_encoding_i[28]);
  assign net_2_751 = (net_2_752 | net_2_2);
  assign net_2_752 = ~(net_2_753 | net_2_754);
  assign net_2_754 = ~(raw_encoding_i[23] | net_2_755);
  assign defined_sideband[3] = ~(net_2_756 & net_2_757);
  assign net_2_757 = (net_2_758 & net_2_759);
  assign net_2_759 = (net_2_760 | raw_encoding_i[31]);
  assign net_2_760 = ~(net_2_164 & net_2_761);
  assign net_2_761 = ~(net_2_762 & net_2_763);
  assign net_2_763 = (net_2_92 | net_2_14);
  assign net_2_180 = (raw_encoding_i[24] | net_2_764);
  assign net_2_764 = ~(raw_encoding_i[21] ^ net_2_364);
  assign net_2_762 = (net_2_765 | raw_encoding_i[28]);
  assign net_2_765 = (net_2_766 & net_2_767);
  assign net_2_767 = (net_2_768 | raw_encoding_i[21]);
  assign net_2_768 = (net_2_769 | raw_encoding_i[12]);
  assign net_2_769 = (net_2_644 & net_2_770);
  assign net_2_770 = (net_2_18 | raw_encoding_i[14]);
  assign net_2_644 = ~(net_2_278 & net_2_308);
  assign net_2_766 = (net_2_1203 & net_2_771);
  assign net_2_771 = (net_2_656 | net_2_772);
  assign net_2_772 = (net_2_773 & net_2_774);
  assign net_2_774 = ~(net_2_127 & net_2_1197);
  assign net_2_127 = (net_2_1204 & net_2_34);
  assign net_2_773 = (net_2_665 & net_2_775);
  assign net_2_775 = (net_2_776 | net_2_24);
  assign net_2_776 = (net_2_777 & net_2_778);
  assign net_2_778 = (net_2_1198 | net_2_698);
  assign net_2_777 = ~(net_2_662 & net_2_698);
  assign net_2_662 = (raw_encoding_i[30] & net_2_1194);
  assign net_2_665 = (net_2_779 & net_2_780);
  assign net_2_780 = ~(net_2_781 & net_2_782);
  assign net_2_782 = (raw_encoding_i[24] | net_2_783);
  assign net_2_783 = (raw_encoding_i[22] & net_2_784);
  assign net_2_784 = ~(raw_encoding_i[21] | net_2_785);
  assign net_2_785 = ~(net_2_786 | net_2_512);
  assign net_2_781 = (raw_encoding_i[22] | net_2_32);
  assign net_2_484 = (raw_encoding_i[15] & raw_encoding_i[14]);
  assign net_2_779 = (net_2_787 & net_2_788);
  assign net_2_788 = (net_2_789 | raw_encoding_i[22]);
  assign net_2_789 = ~(raw_encoding_i[13] & net_2_702);
  assign net_2_787 = (net_2_790 | raw_encoding_i[21]);
  assign net_2_164 = (raw_encoding_i[27] & net_2_791);
  assign net_2_791 = (raw_encoding_i[26] & net_2_1201);
  assign net_2_758 = (net_2_792 & net_2_793);
  assign net_2_793 = (net_2_794 & net_2_795);
  assign net_2_795 = (net_2_1203 | net_2_796);
  assign net_2_796 = (net_2_797 & net_2_798);
  assign net_2_798 = (net_2_799 | net_2_7);
  assign net_2_799 = (net_2_800 & net_2_801);
  assign net_2_801 = (raw_encoding_i[28] | net_2_802);
  assign net_2_802 = (net_2_803 & net_2_804);
  assign net_2_804 = (raw_encoding_i[25] | net_2_805);
  assign net_2_805 = (net_2_806 & net_2_807);
  assign net_2_800 = ~(net_2_808 | net_2_809);
  assign net_2_809 = ~(raw_encoding_i[23] | net_2_810);
  assign net_2_808 = (net_2_811 & net_2_812);
  assign net_2_812 = ~(net_2_10 & net_2_100);
  assign net_2_100 = ~(net_2_335 & net_2_43);
  assign net_2_811 = (net_2_179 & raw_encoding_i[26]);
  assign net_2_179 = (raw_encoding_i[28] & net_2_1199);
  assign net_2_794 = (net_2_813 | net_2_814);
  assign net_2_814 = (net_2_815 | net_2_816);
  assign net_2_816 = (net_2_817 | net_2_818);
  assign net_2_792 = (net_2_819 & net_2_820);
  assign net_2_820 = (net_2_821 | net_2_822);
  assign net_2_822 = (net_2_823 & net_2_824);
  assign net_2_824 = (net_2_182 | net_2_825);
  assign net_2_825 = ~(net_2_1200 ^ net_2_1201);
  assign net_2_823 = (net_2_1200 | net_2_99);
  assign net_2_99 = ~(raw_encoding_i[29] & net_2_89);
  assign net_2_819 = (net_2_826 & net_2_827);
  assign net_2_827 = (net_2_828 & net_2_829);
  assign net_2_829 = (net_2_830 | net_2_831);
  assign net_2_831 = ~(net_2_832 & net_2_833);
  assign net_2_833 = (raw_encoding_i[27] & raw_encoding_i[30]);
  assign net_2_828 = ~(net_2_834 & net_2_835);
  assign net_2_835 = ~(net_2_836 & net_2_837);
  assign net_2_837 = (net_2_838 | net_2_1202);
  assign net_2_836 = (net_2_839 & net_2_840);
  assign net_2_840 = (net_2_818 | net_2_15);
  assign net_2_839 = (net_2_2 | raw_encoding_i[15]);
  assign net_2_826 = (net_2_1197 | net_2_842);
  assign net_2_842 = (net_2_19 | net_2_843);
  assign net_2_843 = (net_2_2 | net_2_755);
  assign defined_sideband[2] = ~(net_2_844 & net_2_756);
  assign net_2_756 = (net_2_845 & net_2_846);
  assign net_2_846 = (net_2_847 | net_2_848);
  assign net_2_845 = (net_2_849 & net_2_850);
  assign net_2_850 = ~(net_2_851 & net_2_61);
  assign net_2_849 = (net_2_852 & net_2_853);
  assign net_2_852 = (net_2_854 | net_2_855);
  assign net_2_855 = (net_2_856 | net_2_857);
  assign net_2_856 = (net_2_858 & net_2_859);
  assign net_2_859 = (raw_encoding_i[24] | net_2_860);
  assign net_2_860 = (net_2_861 | net_2_862);
  assign net_2_862 = (net_2_7 | raw_encoding_i[13]);
  assign net_2_861 = (net_2_863 & net_2_864);
  assign net_2_864 = ~(net_2_512 & net_2_865);
  assign net_2_865 = ~(raw_encoding_i[31] | net_2_866);
  assign net_2_512 = (raw_encoding_i[14] & net_2_1196);
  assign net_2_863 = (net_2_1198 | net_2_537);
  assign net_2_537 = ~(raw_encoding_i[11] & net_2_387);
  assign net_2_858 = (raw_encoding_i[27] | net_2_867);
  assign net_2_867 = (net_2_868 | net_2_869);
  assign net_2_869 = (net_2_1202 | net_2_1200);
  assign net_2_844 = (net_2_870 & net_2_871);
  assign net_2_871 = ~(net_2_872 & raw_encoding_i[26]);
  assign net_2_872 = ~(net_2_818 | net_2_873);
  assign net_2_873 = (net_2_874 & net_2_875);
  assign net_2_875 = (net_2_813 | net_2_876);
  assign net_2_876 = ~(net_2_159 | net_2_189);
  assign net_2_874 = ~(net_2_834 & net_2_841);
  assign net_2_841 = (raw_encoding_i[24] & net_2_115);
  assign net_2_870 = (net_2_877 & net_2_878);
  assign net_2_878 = ~(net_2_879 & net_2_880);
  assign net_2_880 = (raw_encoding_i[27] & net_2_341);
  assign net_2_341 = ~(raw_encoding_i[29] | net_2_8);
  assign net_2_879 = ~(net_2_881 & net_2_882);
  assign net_2_882 = ~(net_2_727 & net_2_883);
  assign net_2_883 = (net_2_189 & net_2_737);
  assign net_2_737 = ~(net_2_30 | net_2_27);
  assign net_2_189 = ~(raw_encoding_i[23] | raw_encoding_i[21]);
  assign net_2_881 = (net_2_884 & net_2_885);
  assign net_2_885 = (net_2_886 | raw_encoding_i[20]);
  assign net_2_886 = ~(net_2_887 & net_2_888);
  assign net_2_888 = (net_2_395 & net_2_40);
  assign net_2_395 = ~(raw_encoding_i[15] | raw_encoding_i[13]);
  assign net_2_887 = ~(net_2_889 & net_2_890);
  assign net_2_890 = (net_2_891 | net_2_892);
  assign net_2_892 = (net_2_893 | raw_encoding_i[12]);
  assign net_2_893 = ~(net_2_894 & net_2_895);
  assign net_2_895 = (raw_encoding_i[17] & net_2_727);
  assign net_2_894 = ~(net_2_896 & net_2_897);
  assign net_2_897 = ~(raw_encoding_i[16] & net_2_898);
  assign net_2_898 = (net_2_746 & net_2_741);
  assign net_2_746 = (net_2_74 & net_2_899);
  assign net_2_896 = ~(net_2_900 & net_2_901);
  assign net_2_901 = ~(raw_encoding_i[19] | raw_encoding_i[23]);
  assign net_2_900 = ~(raw_encoding_i[18] & net_2_902);
  assign net_2_902 = (net_2_903 | net_2_868);
  assign net_2_903 = ~(raw_encoding_i[21] & raw_encoding_i[16]);
  assign net_2_889 = ~(net_2_904 & net_2_229);
  assign net_2_904 = ~(net_2_905 | net_2_857);
  assign net_2_905 = (net_2_906 & net_2_907);
  assign net_2_907 = ~(net_2_908 & net_2_909);
  assign net_2_909 = ~(raw_encoding_i[12] | net_2_910);
  assign net_2_906 = (net_2_911 | raw_encoding_i[11]);
  assign net_2_911 = ~(raw_encoding_i[30] & raw_encoding_i[23]);
  assign net_2_884 = ~(net_2_912 & net_2_913);
  assign net_2_913 = ~(net_2_914 | net_2_229);
  assign net_2_229 = (net_2_689 & net_2_342);
  assign net_2_689 = ~(raw_encoding_i[18] | raw_encoding_i[19]);
  assign net_2_914 = ~(net_2_497 & net_2_910);
  assign net_2_497 = ~(raw_encoding_i[28] | net_2_1193);
  assign net_2_912 = (net_2_388 & net_2_915);
  assign net_2_915 = ~(net_2_517 & net_2_916);
  assign net_2_916 = (net_2_917 | net_2_1204);
  assign net_2_388 = ~(raw_encoding_i[13] | net_2_22);
  assign net_2_877 = (net_2_918 & net_2_919);
  assign net_2_919 = (net_2_848 | raw_encoding_i[23]);
  assign net_2_918 = (net_2_920 & net_2_921);
  assign net_2_921 = (net_2_922 | net_2_923);
  assign net_2_922 = ~(raw_encoding_i[29] & net_2_333);
  assign net_2_920 = ~(net_2_924 | net_2_925);
  assign net_2_925 = (net_2_926 & net_2_927);
  assign net_2_927 = ~(net_2_928 & net_2_929);
  assign net_2_929 = ~(raw_encoding_i[27] & net_2_930);
  assign net_2_930 = ~(net_2_830 | net_2_20);
  assign net_2_830 = (net_2_931 | net_2_755);
  assign net_2_755 = ~(raw_encoding_i[31] & net_2_1201);
  assign net_2_931 = (net_2_932 | net_2_185);
  assign net_2_932 = (net_2_933 & net_2_934);
  assign net_2_934 = (net_2_935 | raw_encoding_i[24]);
  assign net_2_935 = (raw_encoding_i[21] | net_2_891);
  assign net_2_933 = ~(raw_encoding_i[29] & raw_encoding_i[24]);
  assign net_2_928 = ~(raw_encoding_i[29] & net_2_936);
  assign net_2_936 = (raw_encoding_i[23] & net_2_937);
  assign net_2_937 = (net_2_81 & net_2_7);
  assign net_2_926 = ~(net_2_1204 | net_2_182);
  assign defined_sideband[1] = ~(net_2_938 & net_2_939);
  assign net_2_939 = (net_2_940 | raw_encoding_i[29]);
  assign net_2_940 = ~(net_2_941 & net_2_942);
  assign net_2_942 = ~(raw_encoding_i[31] | net_2_943);
  assign net_2_941 = ~(net_2_944 & net_2_945);
  assign net_2_945 = (raw_encoding_i[24] | net_2_946);
  assign net_2_946 = ~(net_2_947 & net_2_335);
  assign net_2_947 = ~(net_2_948 & net_2_949);
  assign net_2_949 = (net_2_950 | net_2_190);
  assign net_2_950 = (net_2_656 | net_2_951);
  assign net_2_951 = (net_2_790 & net_2_539);
  assign net_2_539 = ~(raw_encoding_i[15] & net_2_786);
  assign net_2_786 = ~(raw_encoding_i[13] | raw_encoding_i[14]);
  assign net_2_790 = ~(raw_encoding_i[15] & net_2_952);
  assign net_2_948 = ~(net_2_953 & net_2_954);
  assign net_2_954 = ~(net_2_955 & net_2_956);
  assign net_2_956 = (net_2_1199 | net_2_806);
  assign net_2_806 = ~(raw_encoding_i[26] & net_2_1204);
  assign net_2_955 = (net_2_815 & net_2_957);
  assign net_2_957 = ~(net_2_308 & net_2_958);
  assign net_2_958 = ~(raw_encoding_i[23] | net_2_959);
  assign net_2_959 = (raw_encoding_i[22] & raw_encoding_i[30]);
  assign net_2_815 = ~(raw_encoding_i[26] & net_2_74);
  assign net_2_953 = (raw_encoding_i[12] & net_2_603);
  assign net_2_603 = (net_2_1196 & net_2_122);
  assign net_2_122 = (raw_encoding_i[13] & raw_encoding_i[14]);
  assign net_2_944 = (net_2_656 | net_2_960);
  assign net_2_960 = (net_2_961 | raw_encoding_i[13]);
  assign net_2_961 = ~(net_2_962 & net_2_963);
  assign net_2_963 = (raw_encoding_i[26] & net_2_96);
  assign net_2_962 = (net_2_711 | net_2_964);
  assign net_2_964 = ~(raw_encoding_i[15] & net_2_965);
  assign net_2_965 = ~(raw_encoding_i[22] & net_2_966);
  assign net_2_966 = ~(net_2_967 & net_2_968);
  assign net_2_968 = ~(raw_encoding_i[14] & net_2_1193);
  assign net_2_967 = (raw_encoding_i[21] & raw_encoding_i[10]);
  assign net_2_711 = ~(raw_encoding_i[14] | raw_encoding_i[22]);
  assign net_2_656 = ~(raw_encoding_i[23] | net_2_308);
  assign net_2_938 = (net_2_969 & net_2_970);
  assign net_2_970 = ~(raw_encoding_i[31] & net_2_971);
  assign net_2_971 = ~(net_2_972 & net_2_973);
  assign net_2_973 = (net_2_974 | raw_encoding_i[22]);
  assign net_2_974 = (net_2_975 | net_2_185);
  assign net_2_975 = (net_2_1204 | net_2_848);
  assign net_2_848 = ~(net_2_6 & net_2_94);
  assign net_2_972 = (raw_encoding_i[25] | net_2_976);
  assign net_2_976 = (net_2_977 & net_2_978);
  assign net_2_978 = (net_2_979 | net_2_2);
  assign net_2_979 = ~(raw_encoding_i[15] & net_2_159);
  assign net_2_977 = (raw_encoding_i[26] | net_2_980);
  assign net_2_980 = ~(raw_encoding_i[22] & net_2_981);
  assign net_2_981 = ~(net_2_92 | net_2_943);
  assign net_2_969 = (net_2_982 & net_2_983);
  assign net_2_983 = ~(raw_encoding_i[28] & net_2_984);
  assign net_2_984 = ~(net_2_985 & net_2_986);
  assign net_2_986 = (net_2_838 | net_2_987);
  assign net_2_987 = (net_2_988 & net_2_989);
  assign net_2_989 = ~(net_2_990 & net_2_335);
  assign net_2_990 = ~(raw_encoding_i[23] & net_2_991);
  assign net_2_991 = (net_2_992 & raw_encoding_i[31]);
  assign net_2_992 = (net_2_190 & net_2_993);
  assign net_2_993 = (net_2_891 | raw_encoding_i[22]);
  assign net_2_988 = ~(net_2_994 & net_2_364);
  assign net_2_994 = (net_2_159 & net_2_1201);
  assign net_2_985 = (net_2_995 & net_2_996);
  assign net_2_996 = (net_2_997 | net_2_2);
  assign net_2_997 = (raw_encoding_i[25] & net_2_998);
  assign net_2_998 = (net_2_18 | net_2_999);
  assign net_2_999 = (net_2_1000 & net_2_1001);
  assign net_2_1001 = (net_2_1002 | raw_encoding_i[13]);
  assign net_2_1002 = ~(net_2_1003 & net_2_1004);
  assign net_2_1004 = (raw_encoding_i[30] & net_2_308);
  assign net_2_308 = (net_2_673 & net_2_342);
  assign net_2_342 = (net_2_30 & net_2_31);
  assign net_2_1003 = ~(net_2_1005 & net_2_1006);
  assign net_2_1006 = (raw_encoding_i[11] | net_2_917);
  assign net_2_917 = (raw_encoding_i[14] | net_2_24);
  assign net_2_1005 = (net_2_910 | net_2_517);
  assign net_2_910 = ~(raw_encoding_i[31] | net_2_1192);
  assign net_2_1000 = ~(raw_encoding_i[13] & net_2_1007);
  assign net_2_995 = (net_2_1008 & net_2_1009);
  assign net_2_1009 = ~(raw_encoding_i[26] & net_2_1010);
  assign net_2_1010 = ~(raw_encoding_i[27] | net_2_92);
  assign net_2_1008 = (net_2_1011 | raw_encoding_i[26]);
  assign net_2_1011 = (net_2_1012 & net_2_1013);
  assign net_2_1013 = ~(raw_encoding_i[29] & net_2_1014);
  assign net_2_1014 = ~(net_2_1015 & net_2_1016);
  assign net_2_1016 = ~(net_2_81 & net_2_1017);
  assign net_2_1017 = ~(net_2_1018 & net_2_1019);
  assign net_2_1019 = ~(raw_encoding_i[30] & net_2_7);
  assign net_2_1018 = (net_2_43 | net_2_1020);
  assign net_2_1015 = ~(net_2_96 & net_2_1021);
  assign net_2_1021 = ~(raw_encoding_i[23] & net_2_1022);
  assign net_2_1022 = (net_2_7 | net_2_847);
  assign net_2_847 = (raw_encoding_i[31] & raw_encoding_i[22]);
  assign net_2_1012 = (net_2_821 | net_2_1023);
  assign net_2_1023 = (net_2_1024 & net_2_8);
  assign net_2_81 = (net_2_1200 & raw_encoding_i[25]);
  assign net_2_1024 = ~(net_2_1203 & raw_encoding_i[24]);
  assign net_2_821 = ~(net_2_7 & net_2_1199);
  assign net_2_982 = (net_2_1025 & net_2_1026);
  assign net_2_1026 = (net_2_1027 | net_2_1028);
  assign net_2_1028 = ~(net_2_1029 & net_2_1030);
  assign net_2_1030 = ~(net_2_275 | net_2_818);
  assign net_2_275 = ~(raw_encoding_i[13] & net_2_387);
  assign net_2_1029 = ~(net_2_401 | net_2_1031);
  assign net_2_1031 = ~(net_2_673 & net_2_1032);
  assign net_2_1032 = (net_2_1033 & net_2_1034);
  assign net_2_401 = (raw_encoding_i[7] | raw_encoding_i[6]);
  assign net_2_1025 = (net_2_1035 & net_2_1036);
  assign net_2_1036 = ~(net_2_851 & net_2_753);
  assign net_2_753 = (net_2_335 & net_2_1037);
  assign net_2_1037 = (raw_encoding_i[15] | net_2_1199);
  assign net_2_1035 = (net_2_1038 | net_2_810);
  assign net_2_1038 = ~(net_2_1039 & net_2_1040);
  assign net_2_1040 = (raw_encoding_i[26] & raw_encoding_i[29]);
  assign net_2_1039 = ~(net_2_1041 & net_2_1042);
  assign net_2_1042 = (raw_encoding_i[30] | raw_encoding_i[31]);
  assign net_2_1041 = (raw_encoding_i[23] | net_2_7);
  assign defined_sideband[0] = ~(net_2_1043 & net_2_1044);
  assign net_2_1044 = (net_2_1045 & net_2_1046);
  assign net_2_1046 = (net_2_1047 | net_2_818);
  assign net_2_818 = ~(net_2_1048 & net_2_1203);
  assign net_2_1048 = (net_2_365 & net_2_1049);
  assign net_2_1049 = (raw_encoding_i[31] & net_2_7);
  assign net_2_365 = (raw_encoding_i[28] & raw_encoding_i[30]);
  assign net_2_1047 = (net_2_1050 & net_2_1051);
  assign net_2_1051 = (net_2_1052 | net_2_813);
  assign net_2_813 = (net_2_11 | net_2_156);
  assign net_2_156 = ~(net_2_1053 & net_2_1054);
  assign net_2_1054 = (net_2_60 & net_2_733);
  assign net_2_1053 = (net_2_1055 & raw_encoding_i[20]);
  assign net_2_1055 = ~(net_2_406 | net_2_1056);
  assign net_2_1056 = ~(net_2_1034 & net_2_1057);
  assign net_2_1057 = (net_2_185 & net_2_899);
  assign net_2_899 = (raw_encoding_i[18] & raw_encoding_i[19]);
  assign net_2_1052 = (net_2_161 & net_2_22);
  assign net_2_161 = (raw_encoding_i[22] | net_2_817);
  assign net_2_817 = ~(net_2_1058 & net_2_1059);
  assign net_2_1059 = (raw_encoding_i[7] & net_2_1060);
  assign net_2_1060 = (raw_encoding_i[6] & raw_encoding_i[5]);
  assign net_2_1058 = (raw_encoding_i[9] & raw_encoding_i[8]);
  assign net_2_1050 = ~(net_2_140 | net_2_1061);
  assign net_2_1061 = ~(net_2_1062 & net_2_1063);
  assign net_2_1063 = (net_2_1197 | net_2_152);
  assign net_2_152 = ~(net_2_1064 & net_2_115);
  assign net_2_1064 = (net_2_159 & net_2_96);
  assign net_2_1062 = ~(net_2_673 & net_2_1065);
  assign net_2_1065 = (net_2_146 & net_2_1066);
  assign net_2_1066 = (net_2_1067 | net_2_147);
  assign net_2_147 = ~(raw_encoding_i[13] | net_2_1068);
  assign net_2_1068 = (net_2_1069 | net_2_1070);
  assign net_2_1070 = ~(raw_encoding_i[7] & net_2_377);
  assign net_2_377 = (raw_encoding_i[14] & net_2_1194);
  assign net_2_1069 = ~(net_2_1071 & net_2_1072);
  assign net_2_1072 = ~(raw_encoding_i[16] ^ raw_encoding_i[6]);
  assign net_2_1071 = (net_2_1073 & net_2_1074);
  assign net_2_1074 = ~(raw_encoding_i[16] ^ raw_encoding_i[17]);
  assign net_2_1073 = (raw_encoding_i[17] | raw_encoding_i[5]);
  assign net_2_1067 = (net_2_149 & net_2_1075);
  assign net_2_1075 = ~(net_2_151 & net_2_1076);
  assign net_2_1076 = ~(net_2_1027 & net_2_1194);
  assign net_2_1027 = (net_2_891 | net_2_400);
  assign net_2_400 = (raw_encoding_i[5] | net_2_1077);
  assign net_2_1077 = (raw_encoding_i[9] | raw_encoding_i[8]);
  assign net_2_891 = (raw_encoding_i[11] | raw_encoding_i[10]);
  assign net_2_151 = (net_2_1078 & net_2_1079);
  assign net_2_1079 = ~(raw_encoding_i[7] & net_2_46);
  assign net_2_1078 = (raw_encoding_i[5] | net_2_46);
  assign net_2_149 = (net_2_278 & net_2_1034);
  assign net_2_1034 = ~(net_2_30 | net_2_31);
  assign net_2_278 = ~(raw_encoding_i[14] | net_2_1195);
  assign net_2_146 = (net_2_1033 & net_2_1196);
  assign net_2_1033 = (net_2_1080 & net_2_1081);
  assign net_2_1081 = (net_2_834 & raw_encoding_i[4]);
  assign net_2_1080 = (net_2_1082 & raw_encoding_i[24]);
  assign net_2_1082 = (net_2_1083 & net_2_1084);
  assign net_2_1084 = (raw_encoding_i[1] & raw_encoding_i[0]);
  assign net_2_1083 = (raw_encoding_i[3] & raw_encoding_i[2]);
  assign net_2_673 = ~(raw_encoding_i[18] | net_2_115);
  assign net_2_115 = (raw_encoding_i[19] | raw_encoding_i[20]);
  assign net_2_140 = ~(raw_encoding_i[25] | net_2_1085);
  assign net_2_1085 = (net_2_1086 | net_2_1087);
  assign net_2_1087 = ~(net_2_60 & net_2_185);
  assign net_2_60 = ~(raw_encoding_i[24] | raw_encoding_i[4]);
  assign net_2_1086 = ~(net_2_1088 & net_2_1089);
  assign net_2_1089 = ~(net_2_1199 ^ net_2_1090);
  assign net_2_1090 = ~(net_2_406 & raw_encoding_i[21]);
  assign net_2_1088 = ~(raw_encoding_i[22] ^ net_2_1091);
  assign net_2_1091 = ~(net_2_406 | raw_encoding_i[21]);
  assign net_2_406 = (raw_encoding_i[0] | raw_encoding_i[1]);
  assign net_2_1045 = (net_2_1092 & net_2_1093);
  assign net_2_1093 = (net_2_1094 & net_2_1095);
  assign net_2_1095 = ~(net_2_1096 & net_2_7);
  assign net_2_1096 = (net_2_4 & net_2_1097);
  assign net_2_1097 = ~(net_2_1098 & net_2_1099);
  assign net_2_1099 = (net_2_1100 & net_2_1101);
  assign net_2_1101 = ~(net_2_1201 & net_2_1102);
  assign net_2_1102 = ~(raw_encoding_i[23] & raw_encoding_i[24]);
  assign net_2_1100 = ~(net_2_1200 & net_2_1103);
  assign net_2_1103 = (net_2_1199 | net_2_92);
  assign net_2_92 = (raw_encoding_i[30] | net_2_1203);
  assign net_2_1098 = (net_2_868 | net_2_1104);
  assign net_2_1104 = (raw_encoding_i[21] | net_2_854);
  assign net_2_854 = ~(raw_encoding_i[23] & net_2_1105);
  assign net_2_868 = (raw_encoding_i[31] ^ raw_encoding_i[22]);
  assign net_2_1094 = ~(net_2_924 & raw_encoding_i[14]);
  assign net_2_924 = (net_2_1106 & net_2_1107);
  assign net_2_1107 = (raw_encoding_i[24] & raw_encoding_i[27]);
  assign net_2_1106 = (net_2_1105 & net_2_1108);
  assign net_2_1108 = ~(net_2_1109 & net_2_1110);
  assign net_2_1110 = ~(net_2_741 & net_2_832);
  assign net_2_832 = (net_2_1198 & net_2_4);
  assign net_2_1109 = (net_2_857 | net_2_22);
  assign net_2_857 = (raw_encoding_i[26] | raw_encoding_i[21]);
  assign net_2_1105 = (net_2_1111 & net_2_1203);
  assign net_2_1092 = (net_2_853 & net_2_1112);
  assign net_2_1112 = (net_2_1113 | net_2_2);
  assign net_2_851 = (net_2_1203 & net_2_6);
  assign net_2_1113 = (net_2_1114 & net_2_1115);
  assign net_2_1115 = ~(net_2_1202 & net_2_1116);
  assign net_2_1116 = ~(net_2_472 & net_2_1117);
  assign net_2_1117 = ~(net_2_741 & net_2_1118);
  assign net_2_1118 = (net_2_282 | net_2_354);
  assign net_2_282 = (raw_encoding_i[14] & net_2_1199);
  assign net_2_741 = (raw_encoding_i[31] & raw_encoding_i[21]);
  assign net_2_472 = ~(net_2_159 & net_2_702);
  assign net_2_1114 = (net_2_1119 & net_2_1120);
  assign net_2_1120 = ~(net_2_1007 & net_2_1121);
  assign net_2_1121 = ~(net_2_1122 & net_2_1123);
  assign net_2_1123 = ~(net_2_1124 & raw_encoding_i[23]);
  assign net_2_1124 = (raw_encoding_i[13] & net_2_333);
  assign net_2_1122 = ~(net_2_908 & raw_encoding_i[25]);
  assign net_2_908 = (raw_encoding_i[11] & net_2_325);
  assign net_2_1007 = ~(raw_encoding_i[30] | net_2_517);
  assign net_2_517 = (raw_encoding_i[21] | net_2_37);
  assign net_2_1119 = ~(net_2_1111 & net_2_1125);
  assign net_2_1125 = ~(net_2_866 | net_2_1126);
  assign net_2_1126 = (net_2_1127 | net_2_1128);
  assign net_2_1127 = ~(net_2_702 & net_2_540);
  assign net_2_866 = (raw_encoding_i[11] & net_2_1129);
  assign net_2_1129 = ~(raw_encoding_i[22] & net_2_1192);
  assign net_2_1111 = ~(raw_encoding_i[30] | net_2_1201);
  assign net_2_853 = (net_2_1130 & net_2_1131);
  assign net_2_1131 = (raw_encoding_i[22] | net_2_1132);
  assign net_2_1132 = (raw_encoding_i[21] | net_2_1133);
  assign net_2_1133 = (net_2_1134 | net_2_838);
  assign net_2_1134 = (net_2_1135 | net_2_11);
  assign net_2_333 = ~(raw_encoding_i[11] | net_2_1201);
  assign net_2_1135 = (net_2_1136 & net_2_1137);
  assign net_2_1137 = (net_2_1199 | raw_encoding_i[29]);
  assign net_2_1136 = ~(net_2_733 & net_2_1199);
  assign net_2_733 = (net_2_387 & net_2_263);
  assign net_2_263 = ~(raw_encoding_i[13] | raw_encoding_i[10]);
  assign net_2_387 = ~(raw_encoding_i[15] | net_2_39);
  assign net_2_952 = (net_2_40 & net_2_1194);
  assign net_2_1130 = (net_2_1138 | net_2_1201);
  assign net_2_1138 = (net_2_1139 & net_2_1140);
  assign net_2_1140 = (net_2_1141 | raw_encoding_i[30]);
  assign net_2_1141 = (net_2_1142 | net_2_1143);
  assign net_2_1143 = (net_2_1144 | net_2_1145);
  assign net_2_1145 = (net_2_1146 | net_2_24);
  assign net_2_702 = ~(raw_encoding_i[15] | raw_encoding_i[21]);
  assign net_2_1144 = ~(raw_encoding_i[22] & net_2_1147);
  assign net_2_1147 = ~(net_2_1200 & net_2_1148);
  assign net_2_1148 = (net_2_1199 | net_2_1149);
  assign net_2_1149 = ~(net_2_540 & net_2_698);
  assign net_2_698 = (raw_encoding_i[11] & raw_encoding_i[10]);
  assign net_2_540 = (raw_encoding_i[14] & net_2_1195);
  assign net_2_1142 = ~(raw_encoding_i[31] & net_2_1203);
  assign net_2_1139 = ~(net_2_1202 & net_2_1150);
  assign net_2_1150 = ~(net_2_1146 | net_2_1151);
  assign net_2_1151 = ~(net_2_159 | net_2_1152);
  assign net_2_1152 = (net_2_1200 | net_2_1197);
  assign net_2_1043 = ~(raw_encoding_i[29] & net_2_1153);
  assign net_2_1153 = ~(net_2_797 & net_2_1154);
  assign net_2_1154 = (net_2_1155 & net_2_1156);
  assign net_2_1156 = (raw_encoding_i[26] | net_2_1157);
  assign net_2_1157 = (net_2_1158 & net_2_1159);
  assign net_2_1159 = ~(raw_encoding_i[28] & net_2_834);
  assign net_2_834 = (net_2_335 & net_2_159);
  assign net_2_335 = ~(raw_encoding_i[25] | raw_encoding_i[21]);
  assign net_2_1158 = (net_2_1160 & net_2_1161);
  assign net_2_1161 = (net_2_943 | net_2_1162);
  assign net_2_1162 = (net_2_803 & net_2_1163);
  assign net_2_1163 = ~(raw_encoding_i[14] & net_2_1164);
  assign net_2_1164 = ~(raw_encoding_i[25] | net_2_190);
  assign net_2_190 = (raw_encoding_i[22] | raw_encoding_i[30]);
  assign net_2_803 = (raw_encoding_i[31] | net_2_1165);
  assign net_2_1165 = ~(raw_encoding_i[22] & net_2_96);
  assign net_2_943 = ~(raw_encoding_i[27] & net_2_1202);
  assign net_2_1160 = (net_2_1166 | net_2_810);
  assign net_2_810 = ~(net_2_94 & net_2_1200);
  assign net_2_94 = (net_2_61 & net_2_1167);
  assign net_2_1167 = ~(net_2_1197 | net_2_43);
  assign net_2_364 = ~(raw_encoding_i[10] | net_2_1193);
  assign net_2_61 = (raw_encoding_i[28] & net_2_1201);
  assign net_2_1166 = (net_2_1168 & net_2_19);
  assign net_2_1168 = (net_2_1128 & net_2_1169);
  assign net_2_1169 = ~(net_2_74 & net_2_1170);
  assign net_2_1170 = (net_2_1204 | net_2_185);
  assign net_2_185 = ~(raw_encoding_i[2] | raw_encoding_i[3]);
  assign net_2_74 = ~(raw_encoding_i[22] | net_2_1199);
  assign net_2_1128 = (raw_encoding_i[31] | net_2_1199);
  assign net_2_1155 = (net_2_1171 | raw_encoding_i[28]);
  assign net_2_1171 = (net_2_838 | net_2_807);
  assign net_2_807 = (raw_encoding_i[31] | net_2_1172);
  assign net_2_1172 = (net_2_18 & net_2_1173);
  assign net_2_1173 = ~(raw_encoding_i[22] & net_2_1204);
  assign net_2_325 = (raw_encoding_i[23] & raw_encoding_i[22]);
  assign net_2_797 = (net_2_1174 & net_2_1175);
  assign net_2_1175 = (net_2_1201 | net_2_923);
  assign net_2_923 = (net_2_838 | net_2_1176);
  assign net_2_1176 = (raw_encoding_i[10] | net_2_1020);
  assign net_2_1020 = (raw_encoding_i[4] | net_2_1177);
  assign net_2_1177 = ~(net_2_354 & net_2_1197);
  assign net_2_354 = (raw_encoding_i[22] & net_2_1199);
  assign net_2_838 = (raw_encoding_i[24] | net_2_1146);
  assign net_2_1146 = (raw_encoding_i[26] | net_2_7);
  assign net_2_1174 = (net_2_1178 & net_2_1179);
  assign net_2_1179 = ~(net_2_727 & net_2_7);
  assign net_2_727 = (raw_encoding_i[26] & net_2_89);
  assign net_2_89 = ~(raw_encoding_i[30] | net_2_1202);
  assign net_2_1178 = (net_2_22 | net_2_1180);
  assign net_2_1180 = ~(net_2_96 & net_2_4);
  assign net_2_182 = (raw_encoding_i[26] | net_2_1202);
  assign net_2_96 = (raw_encoding_i[24] & net_2_1201);
  assign net_2_159 = ~(raw_encoding_i[23] | raw_encoding_i[22]);
  assign net_2_1181 = ~(net_2_264 & net_2_263);
  assign net_2_1182 = ~(net_2_265 & net_2_1181);
  assign net_2_1183 = ~(net_2_266 | net_2_1182);
  assign net_2_1184 = (net_2_276 & net_2_275);
  assign net_2_1185 = ~(net_2_274 & net_2_273);
  assign net_2_1186 = (net_2_1184 & net_2_1185);
  assign net_2_1187 = ~(net_2_263 & net_2_270);
  assign net_2_1188 = (net_2_264 | net_2_1187);
  assign net_2_1189 = (net_2_1186 & net_2_1188);
  assign net_2_1190 = (raw_encoding_i[16] | net_2_1183);
  assign net_2_257 = (net_2_1189 & net_2_1190);
  assign net_2_1191 = ~(raw_encoding_i[15] | net_2_447);
  assign net_2_445 = ~(net_2_115 & net_2_1191);
  assign net_2_1192 = ~raw_encoding_i[10];
  assign net_2_1193 = ~raw_encoding_i[11];
  assign net_2_1194 = ~raw_encoding_i[12];
  assign net_2_1195 = ~raw_encoding_i[13];
  assign net_2_1196 = ~raw_encoding_i[15];
  assign net_2_1197 = ~raw_encoding_i[21];
  assign net_2_1198 = ~raw_encoding_i[22];
  assign net_2_1199 = ~raw_encoding_i[23];
  assign net_2_1200 = ~raw_encoding_i[24];
  assign net_2_1201 = ~raw_encoding_i[25];
  assign net_2_1202 = ~raw_encoding_i[28];
  assign net_2_1203 = ~raw_encoding_i[29];
  assign net_2_1204 = ~raw_encoding_i[30];

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53ifu_defs.v"
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
