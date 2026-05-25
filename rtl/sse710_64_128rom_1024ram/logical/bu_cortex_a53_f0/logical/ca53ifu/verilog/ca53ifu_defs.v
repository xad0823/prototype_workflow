//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2007-2015 ARM Limited.
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
// Abstract : IFetch internal definitions
//-----------------------------------------------------------------------------

`ifndef CA53_UNDEFINE

`define ca53ifu_sel_111xxx 6'b111000, 6'b111001, 6'b111010, 6'b111011, 6'b111100, 6'b111101, 6'b111110, 6'b111111
`define ca53ifu_sel_110xxx 6'b110000, 6'b110001, 6'b110010, 6'b110011, 6'b110100, 6'b110101, 6'b110110, 6'b110111
`define ca53ifu_sel_101xxx 6'b101000, 6'b101001, 6'b101010, 6'b101011, 6'b101100, 6'b101101, 6'b101110, 6'b101111
`define ca53ifu_sel_100xxx 6'b100000, 6'b100001, 6'b100010, 6'b100011, 6'b100100, 6'b100101, 6'b100110, 6'b100111
`define ca53ifu_sel_1xxxxx `ca53ifu_sel_100xxx, `ca53ifu_sel_101xxx, `ca53ifu_sel_110xxx,`ca53ifu_sel_111xxx
`define ca53ifu_sel_011xxx 6'b011000, 6'b011001, 6'b011010, 6'b011011, 6'b011100, 6'b011101, 6'b011110, 6'b011111
`define ca53ifu_sel_010xxx 6'b010000, 6'b010001, 6'b010010, 6'b010011, 6'b010100, 6'b010101, 6'b010110, 6'b010111
`define ca53ifu_sel_01xxxx `ca53ifu_sel_010xxx, `ca53ifu_sel_011xxx
`define ca53ifu_sel_001xxx 6'b001000, 6'b001001, 6'b001010, 6'b001011, 6'b001100, 6'b001101, 6'b001110, 6'b001111
`define ca53ifu_sel_0001xx 6'b000100, 6'b000101, 6'b000110, 6'b000111
`define ca53ifu_sel_00001x 6'b000010, 6'b000011
`define ca53ifu_sel_000001 6'b000001
`define ca53ifu_sel_000000 6'b000000

`define ca53ifu_sel_11xxx 5'b11000, 5'b11001, 5'b11010, 5'b11011, 5'b11100, 5'b11101, 5'b11110, 5'b11111
`define ca53ifu_sel_10xxx 5'b10000, 5'b10001, 5'b10010, 5'b10011, 5'b10100, 5'b10101, 5'b10110, 5'b10111
`define ca53ifu_sel_1xxxx `ca53ifu_sel_10xxx, `ca53ifu_sel_11xxx
`define ca53ifu_sel_01xxx 5'b01000, 5'b01001, 5'b01010, 5'b01011, 5'b01100, 5'b01101, 5'b01110, 5'b01111
`define ca53ifu_sel_001xx 5'b00100, 5'b00101, 5'b00110, 5'b00111
`define ca53ifu_sel_0001x 5'b00010, 5'b00011
`define ca53ifu_sel_00001 5'b00001
`define ca53ifu_sel_00000 5'b00000

`define ca53ifu_sel_1xxx 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111
`define ca53ifu_sel_01xx 4'b0100, 4'b0101, 4'b0110, 4'b0111
`define ca53ifu_sel_001x 4'b0010, 4'b0011
`define ca53ifu_sel_0001 4'b0001
`define ca53ifu_sel_0000 4'b0000

`define ca53ifu_sel_1xx 3'b100, 3'b101, 3'b110, 3'b111
`define ca53ifu_sel_01x 3'b010, 3'b011
`define ca53ifu_sel_001 3'b001
`define ca53ifu_sel_000 3'b000

`define ca53ifu_pd_undef 6'b000000

// Undefs
`else

/*ARMAUTO_UNDEF*/
`undef ca53ifu_sel_111xxx
`undef ca53ifu_sel_110xxx
`undef ca53ifu_sel_101xxx
`undef ca53ifu_sel_100xxx
`undef ca53ifu_sel_1xxxxx
`undef ca53ifu_sel_011xxx
`undef ca53ifu_sel_010xxx
`undef ca53ifu_sel_01xxxx
`undef ca53ifu_sel_001xxx
`undef ca53ifu_sel_0001xx
`undef ca53ifu_sel_00001x
`undef ca53ifu_sel_000001
`undef ca53ifu_sel_000000
`undef ca53ifu_sel_11xxx
`undef ca53ifu_sel_10xxx
`undef ca53ifu_sel_1xxxx
`undef ca53ifu_sel_01xxx
`undef ca53ifu_sel_001xx
`undef ca53ifu_sel_0001x
`undef ca53ifu_sel_00001
`undef ca53ifu_sel_00000
`undef ca53ifu_sel_1xxx
`undef ca53ifu_sel_01xx
`undef ca53ifu_sel_001x
`undef ca53ifu_sel_0001
`undef ca53ifu_sel_0000
`undef ca53ifu_sel_1xx
`undef ca53ifu_sel_01x
`undef ca53ifu_sel_001
`undef ca53ifu_sel_000
`undef ca53ifu_pd_undef
/*END*/

`endif
