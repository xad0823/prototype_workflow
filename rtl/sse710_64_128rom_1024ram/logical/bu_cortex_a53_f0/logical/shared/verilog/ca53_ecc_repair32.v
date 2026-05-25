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
//      Revision            : $Revision: 186832 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Repair single bit errors in 32-bits data
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Repair a single bit error using the syndrome information to identify which bit
// must be inverted. All two bit errors, and some multi-bit error, are identified
// as fatal errors.

module ca53_ecc_repair32 (
  // Inputs
  input wire [6:0]    syndrome_i,
  // Outputs
  output wire [31:0]  repair_bit_o
);

  reg [31:0]   repair_bit;

  always @(syndrome_i)
    case (syndrome_i)
      7'b000_0000 : repair_bit = 32'b00000000_00000000_00000000_00000000; //  No errors
      7'b010_0011 : repair_bit = 32'b00000000_00000000_00000000_00000001; //  0
      7'b010_0101 : repair_bit = 32'b00000000_00000000_00000000_00000010; //  1
      7'b010_0110 : repair_bit = 32'b00000000_00000000_00000000_00000100; //  2
      7'b010_1001 : repair_bit = 32'b00000000_00000000_00000000_00001000; //  3
      7'b010_1010 : repair_bit = 32'b00000000_00000000_00000000_00010000; //  4
      7'b010_1100 : repair_bit = 32'b00000000_00000000_00000000_00100000; //  5
      7'b011_0001 : repair_bit = 32'b00000000_00000000_00000000_01000000; //  6
      7'b011_0100 : repair_bit = 32'b00000000_00000000_00000000_10000000; //  7
      7'b000_1110 : repair_bit = 32'b00000000_00000000_00000001_00000000; //  8
      7'b000_1011 : repair_bit = 32'b00000000_00000000_00000010_00000000; //  9
      7'b001_0011 : repair_bit = 32'b00000000_00000000_00000100_00000000; // 10
      7'b001_0101 : repair_bit = 32'b00000000_00000000_00001000_00000000; // 11
      7'b001_0110 : repair_bit = 32'b00000000_00000000_00010000_00000000; // 12
      7'b001_1001 : repair_bit = 32'b00000000_00000000_00100000_00000000; // 13
      7'b001_1010 : repair_bit = 32'b00000000_00000000_01000000_00000000; // 14
      7'b001_1100 : repair_bit = 32'b00000000_00000000_10000000_00000000; // 15
      7'b100_1111 : repair_bit = 32'b00000000_00000001_00000000_00000000; // 16
      7'b100_1010 : repair_bit = 32'b00000000_00000010_00000000_00000000; // 17
      7'b101_0010 : repair_bit = 32'b00000000_00000100_00000000_00000000; // 18
      7'b101_0100 : repair_bit = 32'b00000000_00001000_00000000_00000000; // 19
      7'b101_0111 : repair_bit = 32'b00000000_00010000_00000000_00000000; // 20
      7'b101_1000 : repair_bit = 32'b00000000_00100000_00000000_00000000; // 21
      7'b101_1011 : repair_bit = 32'b00000000_01000000_00000000_00000000; // 22
      7'b101_1101 : repair_bit = 32'b00000000_10000000_00000000_00000000; // 23
      7'b110_0010 : repair_bit = 32'b00000001_00000000_00000000_00000000; // 24
      7'b110_0100 : repair_bit = 32'b00000010_00000000_00000000_00000000; // 25
      7'b110_0111 : repair_bit = 32'b00000100_00000000_00000000_00000000; // 26
      7'b110_1000 : repair_bit = 32'b00001000_00000000_00000000_00000000; // 27
      7'b110_1011 : repair_bit = 32'b00010000_00000000_00000000_00000000; // 28
      7'b110_1101 : repair_bit = 32'b00100000_00000000_00000000_00000000; // 29
      7'b111_0000 : repair_bit = 32'b01000000_00000000_00000000_00000000; // 30
      7'b111_0101 : repair_bit = 32'b10000000_00000000_00000000_00000000; // 31
      7'b000_0001 : repair_bit = 32'b00000000_00000000_00000000_00000000; // C0
      7'b000_0010 : repair_bit = 32'b00000000_00000000_00000000_00000000; // C1
      7'b000_0100 : repair_bit = 32'b00000000_00000000_00000000_00000000; // C2
      7'b000_1000 : repair_bit = 32'b00000000_00000000_00000000_00000000; // C3
      7'b001_0000 : repair_bit = 32'b00000000_00000000_00000000_00000000; // C4
      7'b010_0000 : repair_bit = 32'b00000000_00000000_00000000_00000000; // C5
      7'b100_0000 : repair_bit = 32'b00000000_00000000_00000000_00000000; // C6
      default     : repair_bit = 32'b00000000_00000000_00000000_00000000; // Uncorrectable
    endcase

  assign repair_bit_o = repair_bit[31:0];


endmodule // ca53_ecc_repair32
