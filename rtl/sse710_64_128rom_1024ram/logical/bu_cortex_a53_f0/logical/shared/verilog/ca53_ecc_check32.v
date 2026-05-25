//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2012-05-03 16:52:24 +0100 (Thu, 03 May 2012) $
//
//      Revision            : $Revision: 192060 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Generate syndrome information from Check bits for 32-bits data
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Generates masks to determine which bits of data are used to generate which
// syndrome bit.  The syndrome should be zero if no errors are present.

`include "cortexa53params.v"

module ca53_ecc_check32 (
   // Inputs
   input wire  [31:0]   data_i,
   input wire  [6:0]    ecc_i,
   // Outputs
   output wire [6:0]    syndrome_o
);

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire  [38:0]  s0_mask;   // Mask for syndrome bit 0
  wire  [38:0]  s1_mask;   // Mask for syndrome bit 1
  wire  [38:0]  s2_mask;   // Mask for syndrome bit 2
  wire  [38:0]  s3_mask;   // Mask for syndrome bit 3
  wire  [38:0]  s4_mask;   // Mask for syndrome bit 4
  wire  [38:0]  s5_mask;   // Mask for syndrome bit 5
  wire  [38:0]  s6_mask;   // Mask for syndrome bit 6

  assign s0_mask = 39'b0000001_10110100_11010001_00101110_01001011;
  assign s1_mask = 39'b0000010_00010101_01010111_01010111_00010101;
  assign s2_mask = 39'b0000100_10100110_10011001_10011001_10100110;
  assign s3_mask = 39'b0001000_00111000_11100011_11100011_00111000;
  assign s4_mask = 39'b0010000_11000000_11111100_11111100_11000000;
  assign s5_mask = 39'b0100000_11111111_00000000_00000000_11111111;
  assign s6_mask = 39'b1000000_11111111_11111111_00000000_00000000;

  assign syndrome_o[0] = ^({ecc_i, data_i} & s0_mask) ^ `CA53_ECC_EVEN;
  assign syndrome_o[1] = ^({ecc_i, data_i} & s1_mask) ^ `CA53_ECC_EVEN;
  assign syndrome_o[2] = ^({ecc_i, data_i} & s2_mask) ^ `CA53_ECC_ODD;
  assign syndrome_o[3] = ^({ecc_i, data_i} & s3_mask) ^ `CA53_ECC_ODD;
  assign syndrome_o[4] = ^({ecc_i, data_i} & s4_mask) ^ `CA53_ECC_EVEN;
  assign syndrome_o[5] = ^({ecc_i, data_i} & s5_mask) ^ `CA53_ECC_EVEN;
  assign syndrome_o[6] = ^({ecc_i, data_i} & s6_mask) ^ `CA53_ECC_EVEN;


endmodule // ca53_ecc_check32

`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
