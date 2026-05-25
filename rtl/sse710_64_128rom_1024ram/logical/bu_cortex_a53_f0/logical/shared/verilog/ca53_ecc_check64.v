//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Abstract : Check ECC bits for 64-bits of data
//------------------------------------------------------------------------------
//
// Overview
// --------
//
// Generates masks to determine which bits of data are used to generate which
// syndrome bit.  The syndrome should be zero if no errors are present.

`include "cortexa53params.v"

module ca53_ecc_check64 (
  input [63:0] data_i,
  input [7:0]  ecc_i,

  output [7:0] syndrome_o
);

  wire [71:0] s0_mask;   // Mask for syndrome bit 0
  wire [71:0] s1_mask;   // Mask for syndrome bit 1
  wire [71:0] s2_mask;   // Mask for syndrome bit 2
  wire [71:0] s3_mask;   // Mask for syndrome bit 3
  wire [71:0] s4_mask;   // Mask for syndrome bit 4
  wire [71:0] s5_mask;   // Mask for syndrome bit 5
  wire [71:0] s6_mask;   // Mask for syndrome bit 6
  wire [71:0] s7_mask;   // Mask for syndrome bit 7

  assign s0_mask = 72'b00000001_1011010011010001_1011010011010001_0100101100101110_0100101100101110;
  assign s1_mask = 72'b00000010_0001010101010111_0001010101010111_0001010101010111_0001010101010111;
  assign s2_mask = 72'b00000100_1010011010011001_1010011010011001_1010011010011001_1010011010011001;
  assign s3_mask = 72'b00001000_0011100011100011_0011100011100011_0011100011100011_0011100011100011;
  assign s4_mask = 72'b00010000_1100000011111100_1100000011111100_1100000011111100_1100000011111100;
  assign s5_mask = 72'b00100000_1111111100000000_1111111100000000_1111111100000000_1111111100000000;
  assign s6_mask = 72'b01000000_1111111100000000_0000000011111111_1111111100000000_0000000011111111;
  assign s7_mask = 72'b10000000_0000000011111111_1111111100000000_1111111100000000_0000000011111111;

  assign syndrome_o[0] = ^({ecc_i, data_i} & s0_mask) ^ `CA53_ECC_EVEN;
  assign syndrome_o[1] = ^({ecc_i, data_i} & s1_mask) ^ `CA53_ECC_EVEN;
  assign syndrome_o[2] = ^({ecc_i, data_i} & s2_mask) ^ `CA53_ECC_ODD;
  assign syndrome_o[3] = ^({ecc_i, data_i} & s3_mask) ^ `CA53_ECC_ODD;
  assign syndrome_o[4] = ^({ecc_i, data_i} & s4_mask) ^ `CA53_ECC_EVEN;
  assign syndrome_o[5] = ^({ecc_i, data_i} & s5_mask) ^ `CA53_ECC_EVEN;
  assign syndrome_o[6] = ^({ecc_i, data_i} & s6_mask) ^ `CA53_ECC_EVEN;
  assign syndrome_o[7] = ^({ecc_i, data_i} & s7_mask) ^ `CA53_ECC_EVEN;


endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
