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
//      Revision            : $Revision: 205234 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Generate Parity Check bits for 32-bits data
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Generates masks to determine which bits of data are used to generate which
// check bits.

`include "cortexa53params.v"

module ca53_ecc_generate32 (
   // Inputs
   input wire  [31:0]    data_i,
   // Outputs
   output wire [6:0]     ecc_o
);

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire  [31:0]  cb0_mask; // Mask for check bit 0
  wire  [31:0]  cb1_mask; // Mask for check bit 1
  wire  [31:0]  cb2_mask; // Mask for check bit 2
  wire  [31:0]  cb3_mask; // Mask for check bit 3
  wire  [31:0]  cb4_mask; // Mask for check bit 4
  wire  [31:0]  cb5_mask; // Mask for check bit 5
  wire  [31:0]  cb6_mask; // Mask for check bit 6

  assign cb0_mask = 32'b10110100_11010001_00101110_01001011;
  assign cb1_mask = 32'b00010101_01010111_01010111_00010101;
  assign cb2_mask = 32'b10100110_10011001_10011001_10100110;
  assign cb3_mask = 32'b00111000_11100011_11100011_00111000;
  assign cb4_mask = 32'b11000000_11111100_11111100_11000000;
  assign cb5_mask = 32'b11111111_00000000_00000000_11111111;
  assign cb6_mask = 32'b11111111_11111111_00000000_00000000;

  assign ecc_o[0] = ^(data_i & cb0_mask) ^ `CA53_ECC_EVEN;
  assign ecc_o[1] = ^(data_i & cb1_mask) ^ `CA53_ECC_EVEN;
  assign ecc_o[2] = ^(data_i & cb2_mask) ^ `CA53_ECC_ODD;
  assign ecc_o[3] = ^(data_i & cb3_mask) ^ `CA53_ECC_ODD;
  assign ecc_o[4] = ^(data_i & cb4_mask) ^ `CA53_ECC_EVEN;
  assign ecc_o[5] = ^(data_i & cb5_mask) ^ `CA53_ECC_EVEN;
  assign ecc_o[6] = ^(data_i & cb6_mask) ^ `CA53_ECC_EVEN;


endmodule // ca53_ecc_generate32

`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
