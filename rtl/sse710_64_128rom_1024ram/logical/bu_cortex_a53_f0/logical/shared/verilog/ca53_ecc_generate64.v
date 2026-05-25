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
// Abstract : Generate ECC bits for 64-bits of data
//------------------------------------------------------------------------------
//
// Overview
// --------
//
// Generates masks to determine which bits of data are used to generate which
// ECC bit.

`include "cortexa53params.v"

module ca53_ecc_generate64 (
  input [63:0] data_i,
  output [7:0] ecc_o
);

  wire [63:0] cb0_mask;   // Mask for check bit 0
  wire [63:0] cb1_mask;   // Mask for check bit 1
  wire [63:0] cb2_mask;   // Mask for check bit 2
  wire [63:0] cb3_mask;   // Mask for check bit 3
  wire [63:0] cb4_mask;   // Mask for check bit 4
  wire [63:0] cb5_mask;   // Mask for check bit 5
  wire [63:0] cb6_mask;   // Mask for check bit 6
  wire [63:0] cb7_mask;   // Mask for check bit 7

  assign cb0_mask = 64'b1011010011010001_1011010011010001_0100101100101110_0100101100101110;
  assign cb1_mask = 64'b0001010101010111_0001010101010111_0001010101010111_0001010101010111;
  assign cb2_mask = 64'b1010011010011001_1010011010011001_1010011010011001_1010011010011001;
  assign cb3_mask = 64'b0011100011100011_0011100011100011_0011100011100011_0011100011100011;
  assign cb4_mask = 64'b1100000011111100_1100000011111100_1100000011111100_1100000011111100;
  assign cb5_mask = 64'b1111111100000000_1111111100000000_1111111100000000_1111111100000000;
  assign cb6_mask = 64'b1111111100000000_0000000011111111_1111111100000000_0000000011111111;
  assign cb7_mask = 64'b0000000011111111_1111111100000000_1111111100000000_0000000011111111;

  assign ecc_o[0] = ^(data_i & cb0_mask) ^ `CA53_ECC_EVEN;
  assign ecc_o[1] = ^(data_i & cb1_mask) ^ `CA53_ECC_EVEN;
  assign ecc_o[2] = ^(data_i & cb2_mask) ^ `CA53_ECC_ODD;
  assign ecc_o[3] = ^(data_i & cb3_mask) ^ `CA53_ECC_ODD;
  assign ecc_o[4] = ^(data_i & cb4_mask) ^ `CA53_ECC_EVEN;
  assign ecc_o[5] = ^(data_i & cb5_mask) ^ `CA53_ECC_EVEN;
  assign ecc_o[6] = ^(data_i & cb6_mask) ^ `CA53_ECC_EVEN;
  assign ecc_o[7] = ^(data_i & cb7_mask) ^ `CA53_ECC_EVEN;


endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
