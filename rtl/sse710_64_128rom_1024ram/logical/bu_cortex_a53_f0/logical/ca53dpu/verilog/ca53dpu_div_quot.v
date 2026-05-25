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
//      Checked In          : $Date: 2012-09-03 09:54:05 +0100 (Mon, 03 Sep 2012) $
//
//      Revision            : $Revision: 220916 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Integer SRT Radix-2 quotient selection logic
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Selects the next result digit for a div operation
//

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_div_quot (
  input  wire [2:0] rem_sum_msb_i,
  input  wire [2:0] rem_carry_msb_i,

  output wire [1:0] quot_dig_o
);

  reg   [1:0] quot_sel;

 // quot_sel case statement replicates behaviour of carry propogate adding the
 // top 3 bits of the carry and save representations of remainder and then
 // selecting correct quotient - done for quicker timing.
 // q = +1 when sum >=  0
 // q = -1 when sum <  -1
 // q = 0  when sum == -1
  always @*
    case ({rem_sum_msb_i[2:0], rem_carry_msb_i[2:0]})
      6'b000000 : quot_sel = 2'b01;
      6'b000001 : quot_sel = 2'b01;
      6'b000010 : quot_sel = 2'b01;
      6'b000011 : quot_sel = 2'b01;
      6'b000100 : quot_sel = 2'b10;
      6'b000101 : quot_sel = 2'b10;
      6'b000110 : quot_sel = 2'b10;
      6'b000111 : quot_sel = 2'b00;
      6'b001000 : quot_sel = 2'b01;
      6'b001001 : quot_sel = 2'b01;
      6'b001010 : quot_sel = 2'b01;
      6'b001011 : quot_sel = 2'b01;
      6'b001100 : quot_sel = 2'b10;
      6'b001101 : quot_sel = 2'b10;
      6'b001110 : quot_sel = 2'b00;
      6'b001111 : quot_sel = 2'b01;
      6'b010000 : quot_sel = 2'b01;
      6'b010001 : quot_sel = 2'b01;
      6'b010010 : quot_sel = 2'b01;
      6'b010011 : quot_sel = 2'b01;
      6'b010100 : quot_sel = 2'b10;
      6'b010101 : quot_sel = 2'b00;
      6'b010110 : quot_sel = 2'b01;
      6'b010111 : quot_sel = 2'b01;
      6'b011000 : quot_sel = 2'b01;
      6'b011001 : quot_sel = 2'b01;
      6'b011010 : quot_sel = 2'b01;
      6'b011011 : quot_sel = 2'b01;
      6'b011100 : quot_sel = 2'b00;
      6'b011101 : quot_sel = 2'b01;
      6'b011110 : quot_sel = 2'b01;
      6'b011111 : quot_sel = 2'b01;
      6'b100000 : quot_sel = 2'b10;
      6'b100001 : quot_sel = 2'b10;
      6'b100010 : quot_sel = 2'b10;
      6'b100011 : quot_sel = 2'b00;
      6'b100100 : quot_sel = 2'b10;
      6'b100101 : quot_sel = 2'b10;
      6'b100110 : quot_sel = 2'b10;
      6'b100111 : quot_sel = 2'b10;
      6'b101000 : quot_sel = 2'b10;
      6'b101001 : quot_sel = 2'b10;
      6'b101010 : quot_sel = 2'b00;
      6'b101011 : quot_sel = 2'b01;
      6'b101100 : quot_sel = 2'b10;
      6'b101101 : quot_sel = 2'b10;
      6'b101110 : quot_sel = 2'b10;
      6'b101111 : quot_sel = 2'b10;
      6'b110000 : quot_sel = 2'b10;
      6'b110001 : quot_sel = 2'b00;
      6'b110010 : quot_sel = 2'b01;
      6'b110011 : quot_sel = 2'b01;
      6'b110100 : quot_sel = 2'b10;
      6'b110101 : quot_sel = 2'b10;
      6'b110110 : quot_sel = 2'b10;
      6'b110111 : quot_sel = 2'b10;
      6'b111000 : quot_sel = 2'b00;
      6'b111001 : quot_sel = 2'b01;
      6'b111010 : quot_sel = 2'b01;
      6'b111011 : quot_sel = 2'b01;
      6'b111100 : quot_sel = 2'b10;
      6'b111101 : quot_sel = 2'b10;
      6'b111110 : quot_sel = 2'b10;
      6'b111111 : quot_sel = 2'b10;
      default   : quot_sel = 2'bxx;
    endcase

  assign quot_dig_o  = quot_sel;
endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
