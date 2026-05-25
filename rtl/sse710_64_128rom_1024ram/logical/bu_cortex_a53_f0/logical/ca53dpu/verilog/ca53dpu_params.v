//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2014 ARM Limited.
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
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : DPU parameters (define statements)
//-----------------------------------------------------------------------------

`ifndef CA53_UNDEFINE

//-----------------------------------------------------------------------------
// Decoded read port control signals
//----------------------------------------------------------------------------

// Address muxing
// - Common encodings
`define CA53_RP_RD_3_0          0
`define CA53_RP_RD_11_8         1
`define CA53_RP_RD_15_12        2
`define CA53_RP_RD_19_16        3
`define CA53_RP_RD_STM          4
`define CA53_RP_RD_MCR          5
`define CA53_RP_RD_ERET         6

// - RP specific encodings
`define CA53_RP0_RD_2_0         4
`define CA53_RP0_RD_R13         7

`define CA53_RP2_RD_R14         7
`define CA53_RP2_RD_RMOD        8

// RF Rd Ctl bits
`define CA53_RD_CTL_EN          0
`define CA53_RD_CTL_PC          1
`define CA53_RD_CTL_ZR          2
`define CA53_RD_CTL_STM         3

// RF Wr Ctl bits
`define CA53_WR_CTL_EN          0
`define CA53_WR_CTL_19_16       1
`define CA53_WR_CTL_15_12       2
`define CA53_WR_CTL_11_8        3
`define CA53_WR_CTL_3_0         4
`define CA53_WR_CTL_LDM         5
`define CA53_WR_CTL_ART         6
`define CA53_WR_CTL_R30         7
`define CA53_WR_CTL_RMOD        8
`define CA53_WR_CTL_R13         9
`define CA53_WR_CTL_R14         10
`define CA53_WR_CTL_R15         11
`define CA53_WR_CTL_ZR          12

// Decode of top bit for 11:8 register field is complicated and done in multiple
// places, so use macro
`define CA53_R11_8_TOP(sb, instr) (( (sb[5:1] == 5'b01000) | \
                                    ((sb[5:1] == 5'b01001) & (instr[20] != 1'b1))) ? sb[0] : instr[31])

//-----------------------------------------------------------------------------
// Expansion of the OpCode decode
//----------------------------------------------------------------------------

`define ca53dpu_sel_0x 2'b00, 2'b01
`define ca53dpu_sel_1x 2'b10, 2'b11

`define ca53dpu_sel_0x0 3'b000, 3'b010
`define ca53dpu_sel_0x1 3'b001, 3'b011
`define ca53dpu_sel_0xx 3'b000, 3'b001, 3'b010, 3'b011
`define ca53dpu_sel_00x 3'b000, 3'b001
`define ca53dpu_sel_10x 3'b100, 3'b101
`define ca53dpu_sel_1x0 3'b100, 3'b110
`define ca53dpu_sel_1x1 3'b101, 3'b111
`define ca53dpu_sel_11x 3'b110, 3'b111

`define ca53dpu_sel_000 3'b000
`define ca53dpu_sel_001 3'b001
`define ca53dpu_sel_01x 3'b010, 3'b011
`define ca53dpu_sel_1xx 3'b100, 3'b101, 3'b110, 3'b111

`define ca53dpu_sel_100 3'b100
`define ca53dpu_sel_x10 3'b010, 3'b110
`define ca53dpu_sel_xx1 3'b001, 3'b011, 3'b101, 3'b111

`define ca53dpu_sel_1n00 3'b101, 3'b110, 3'b111

`define ca53dpu_sel_1xxx 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111
`define ca53dpu_sel_01xx 4'b0100, 4'b0101, 4'b0110, 4'b0111
`define ca53dpu_sel_001x 4'b0010, 4'b0011

`define ca53dpu_sel_0xxx 4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111
`define ca53dpu_sel_00xx 4'b0000, 4'b0001, 4'b0010, 4'b0011
`define ca53dpu_sel_xx00 4'b0000, 4'b0100, 4'b1000, 4'b1100
`define ca53dpu_sel_000x 4'b0000, 4'b0001
`define ca53dpu_sel_010x 4'b0100, 4'b0101
`define ca53dpu_sel_10xx 4'b1000, 4'b1001, 4'b1010, 4'b1011
`define ca53dpu_sel_100x 4'b1000, 4'b1001
`define ca53dpu_sel_101x 4'b1010, 4'b1011

`define ca53dpu_sel_1000 4'b1000
`define ca53dpu_sel_x100 4'b0100, 4'b1100
`define ca53dpu_sel_xx10 4'b0010, 4'b0110, 4'b1010, 4'b1110
`define ca53dpu_sel_xx11 4'b0011, 4'b0111, 4'b1011, 4'b1111
`define ca53dpu_sel_xx01 4'b0001, 4'b0101, 4'b1001, 4'b1101
`define ca53dpu_sel_xxx1 `ca53dpu_sel_xx01, `ca53dpu_sel_xx11

`define ca53dpu_sel_0x00 4'b0000, 4'b0100
`define ca53dpu_sel_0x01 4'b0001, 4'b0101
`define ca53dpu_sel_0x1x 4'b0010, 4'b0011, 4'b0110, 4'b0111
`define ca53dpu_sel_10x0 4'b1000, 4'b1010
`define ca53dpu_sel_10x1 4'b1001, 4'b1011
`define ca53dpu_sel_11xx 4'b1100, 4'b1101, 4'b1110, 4'b1111

`define ca53dpu_sel_000xx 5'b0_0000, 5'b0_0001, 5'b0_0010, 5'b0_0011
`define ca53dpu_sel_001xx 5'b0_0100, 5'b0_0101, 5'b0_0110, 5'b0_0111
`define ca53dpu_sel_100xx 5'b1_0000, 5'b1_0001, 5'b1_0010, 5'b1_0011
`define ca53dpu_sel_101xx 5'b1_0100, 5'b1_0101, 5'b1_0110, 5'b1_0111
`define ca53dpu_sel_x000x 5'b0_0000, 5'b0_0001, 5'b1_0000, 5'b1_0001
`define ca53dpu_sel_x001x 5'b0_0010, 5'b0_0011, 5'b1_0010, 5'b1_0011
`define ca53dpu_sel_x010x 5'b0_0100, 5'b0_0101, 5'b1_0100, 5'b1_0101
`define ca53dpu_sel_x011x 5'b0_0110, 5'b0_0111, 5'b1_0110, 5'b1_0111
`define ca53dpu_sel_x100x 5'b0_1000, 5'b0_1001, 5'b1_1000, 5'b1_1001
`define ca53dpu_sel_x101x 5'b0_1010, 5'b0_1011, 5'b1_1010, 5'b1_1011
`define ca53dpu_sel_x1100 5'b01100, 5'b11100
`define ca53dpu_sel_x1101 5'b01101, 5'b11101
`define ca53dpu_sel_x1110 5'b01110, 5'b11110
`define ca53dpu_sel_x1111 5'b01111, 5'b11111
`define ca53dpu_sel_00xxx  5'b0_0000, 5'b0_0001, 5'b0_0010, 5'b0_0011, 5'b0_0100, 5'b0_0101, 5'b0_0110, 5'b0_0111
`define ca53dpu_sel_1xxxx  5'b1_0000, 5'b1_0001, 5'b1_0010, 5'b1_0011, 5'b1_0100, 5'b1_0101, 5'b1_0110, 5'b1_0111, 5'b1_1000, 5'b1_1001, 5'b1_1010, 5'b1_1011, 5'b1_1100, 5'b1_1101, 5'b1_1110, 5'b1_1111
`define ca53dpu_sel_01xxx  5'b0_1000, 5'b0_1001, 5'b0_1010, 5'b0_1011, 5'b0_1100, 5'b0_1101, 5'b0_1110, 5'b0_1111
`define ca53dpu_sel_0001x  5'b0_0010, 5'b0_0011

// 6bit case
`define ca53dpu_sel_1x_xxxx__p0 6'b10_0000, 6'b10_0001, 6'b10_0010, 6'b10_0011, 6'b10_0100, 6'b10_0101
`define ca53dpu_sel_1x_xxxx__p1 6'b10_0110, 6'b10_0111, 6'b10_1000, 6'b10_1001, 6'b10_1010, 6'b10_1011
`define ca53dpu_sel_1x_xxxx__p2 6'b10_1100, 6'b10_1101, 6'b10_1110, 6'b10_1111, 6'b11_0000, 6'b11_0001
`define ca53dpu_sel_1x_xxxx__p3 6'b11_0010, 6'b11_0011, 6'b11_0100, 6'b11_0101, 6'b11_0110, 6'b11_0111
`define ca53dpu_sel_1x_xxxx__p4 6'b11_1000, 6'b11_1001, 6'b11_1010, 6'b11_1011, 6'b11_1100, 6'b11_1101
`define ca53dpu_sel_1x_xxxx__p5 6'b11_1110, 6'b11_1111
`define ca53dpu_sel_1x_xxxx `ca53dpu_sel_1x_xxxx__p0, `ca53dpu_sel_1x_xxxx__p1, `ca53dpu_sel_1x_xxxx__p2, `ca53dpu_sel_1x_xxxx__p3, `ca53dpu_sel_1x_xxxx__p4, `ca53dpu_sel_1x_xxxx__p5

`define ca53dpu_sel_01_xxxx_p0 6'b01_0000, 6'b01_0001, 6'b01_0010, 6'b01_0011, 6'b01_0100, 6'b01_0101
`define ca53dpu_sel_01_xxxx_p1 6'b01_0110, 6'b01_0111, 6'b01_1000, 6'b01_1001, 6'b01_1010, 6'b01_1011
`define ca53dpu_sel_01_xxxx_p2 6'b01_1100, 6'b01_1101, 6'b01_1110, 6'b01_1111
`define ca53dpu_sel_01_xxxx `ca53dpu_sel_01_xxxx_p0, `ca53dpu_sel_01_xxxx_p1, `ca53dpu_sel_01_xxxx_p2

`define ca53dpu_sel_00_1xxx 6'b00_1000, 6'b00_1001, 6'b00_1010, 6'b00_1011, 6'b00_1100, 6'b00_1101, 6'b00_1110, 6'b00_1111
`define ca53dpu_sel_00_01xx 6'b00_0100, 6'b00_0101, 6'b00_0110, 6'b00_0111
`define ca53dpu_sel_00_001x 6'b00_0010, 6'b00_0011

// 7bit case
`define ca53dpu_sel_1xx_xxxx_p0 7'b100_0000, 7'b100_0001, 7'b100_0010, 7'b100_0011, 7'b100_0100, 7'b100_0101
`define ca53dpu_sel_1xx_xxxx_p1 7'b100_0110, 7'b100_0111, 7'b100_1000, 7'b100_1001, 7'b100_1010, 7'b100_1011
`define ca53dpu_sel_1xx_xxxx_p2 7'b100_1100, 7'b100_1101, 7'b100_1110, 7'b100_1111, 7'b101_0000, 7'b101_0001
`define ca53dpu_sel_1xx_xxxx_p3 7'b101_0010, 7'b101_0011, 7'b101_0100, 7'b101_0101, 7'b101_0110, 7'b101_0111
`define ca53dpu_sel_1xx_xxxx_p4 7'b101_1000, 7'b101_1001, 7'b101_1010, 7'b101_1011, 7'b101_1100, 7'b101_1101
`define ca53dpu_sel_1xx_xxxx_p5 7'b101_1110, 7'b101_1111, 7'b110_0000, 7'b110_0001, 7'b110_0010, 7'b110_0011
`define ca53dpu_sel_1xx_xxxx_p6 7'b110_0100, 7'b110_0101, 7'b110_0110, 7'b110_0111, 7'b110_1000, 7'b110_1001
`define ca53dpu_sel_1xx_xxxx_p7 7'b110_1010, 7'b110_1011, 7'b110_1100, 7'b110_1101, 7'b110_1110, 7'b110_1111
`define ca53dpu_sel_1xx_xxxx_p8 7'b111_0000, 7'b111_0001, 7'b111_0010, 7'b111_0011, 7'b111_0100, 7'b111_0101
`define ca53dpu_sel_1xx_xxxx_p9 7'b111_0110, 7'b111_0111, 7'b111_1000, 7'b111_1001, 7'b111_1010, 7'b111_1011
`define ca53dpu_sel_1xx_xxxx_p10 7'b111_1100, 7'b111_1101, 7'b111_1110, 7'b111_1111
`define ca53dpu_sel_1xx_xxxx `ca53dpu_sel_1xx_xxxx_p0, `ca53dpu_sel_1xx_xxxx_p1, `ca53dpu_sel_1xx_xxxx_p2, `ca53dpu_sel_1xx_xxxx_p3, `ca53dpu_sel_1xx_xxxx_p4, `ca53dpu_sel_1xx_xxxx_p5, \
`ca53dpu_sel_1xx_xxxx_p6, `ca53dpu_sel_1xx_xxxx_p7, `ca53dpu_sel_1xx_xxxx_p8, `ca53dpu_sel_1xx_xxxx_p9, `ca53dpu_sel_1xx_xxxx_p10


`define ca53dpu_sel_01x_xxxx_p0 7'b010_0000, 7'b010_0001, 7'b010_0010, 7'b010_0011, 7'b010_0100, 7'b010_0101
`define ca53dpu_sel_01x_xxxx_p1 7'b010_0110, 7'b010_0111, 7'b010_1000, 7'b010_1001, 7'b010_1010, 7'b010_1011
`define ca53dpu_sel_01x_xxxx_p2 7'b010_1100, 7'b010_1101, 7'b010_1110, 7'b010_1111, 7'b011_0000, 7'b011_0001
`define ca53dpu_sel_01x_xxxx_p3 7'b011_0010, 7'b011_0011, 7'b011_0100, 7'b011_0101, 7'b011_0110, 7'b011_0111
`define ca53dpu_sel_01x_xxxx_p4 7'b011_1000, 7'b011_1001, 7'b011_1010, 7'b011_1011, 7'b011_1100, 7'b011_1101
`define ca53dpu_sel_01x_xxxx_p5 7'b011_1110, 7'b011_1111
`define ca53dpu_sel_01x_xxxx `ca53dpu_sel_01x_xxxx_p0, `ca53dpu_sel_01x_xxxx_p1, `ca53dpu_sel_01x_xxxx_p2, `ca53dpu_sel_01x_xxxx_p3, `ca53dpu_sel_01x_xxxx_p4, `ca53dpu_sel_01x_xxxx_p5

`define ca53dpu_sel_001_xxxx_p0 7'b001_0000, 7'b001_0001, 7'b001_0010, 7'b001_0011, 7'b001_0100, 7'b001_0101
`define ca53dpu_sel_001_xxxx_p1 7'b001_0110, 7'b001_0111, 7'b001_1000, 7'b001_1001, 7'b001_1010, 7'b001_1011
`define ca53dpu_sel_001_xxxx_p2 7'b001_1100, 7'b001_1101, 7'b001_1110, 7'b001_1111
`define ca53dpu_sel_001_xxxx `ca53dpu_sel_001_xxxx_p0, `ca53dpu_sel_001_xxxx_p1, `ca53dpu_sel_001_xxxx_p2

`define ca53dpu_sel_000_1xxx 7'b000_1000, 7'b000_1001, 7'b000_1010, 7'b000_1011, 7'b000_1100, 7'b000_1101, 7'b000_1110, 7'b000_1111
`define ca53dpu_sel_000_01xx 7'b000_0100, 7'b000_0101, 7'b000_0110, 7'b000_0111
`define ca53dpu_sel_000_001x 7'b000_0010, 7'b000_0011

// 8bit case
`define ca53dpu_sel_0000_01xx 8'b0000_0100, 8'b0000_0101, 8'b0000_0110, 8'b0000_0111
`define ca53dpu_sel_0000_001x 8'b0000_0010, 8'b0000_0011
`define ca53dpu_sel_0000_1xx0 8'b0000_1000, 8'b0000_1010, 8'b0000_1100, 8'b0000_1110
`define ca53dpu_sel_0000_1xx1 8'b0000_1001, 8'b0000_1011, 8'b0000_1101, 8'b0000_1111

`define ca53dpu_sel_0000_1xxx `ca53dpu_sel_0000_1xx0, `ca53dpu_sel_0000_1xx1

`define ca53dpu_sel_0001_00xx 8'b0001_0000, 8'b0001_0001, 8'b0001_0010, 8'b0001_0011
`define ca53dpu_sel_0001_01xx 8'b0001_0100, 8'b0001_0101, 8'b0001_0110, 8'b0001_0111
`define ca53dpu_sel_0001_10xx 8'b0001_1000, 8'b0001_1001, 8'b0001_1010, 8'b0001_1011
`define ca53dpu_sel_0001_11xx 8'b0001_1100, 8'b0001_1101, 8'b0001_1110, 8'b0001_1111

`define ca53dpu_sel_0010_00xx 8'b0010_0000, 8'b0010_0001, 8'b0010_0010, 8'b0010_0011
`define ca53dpu_sel_0010_01xx 8'b0010_0100, 8'b0010_0101, 8'b0010_0110, 8'b0010_0111
`define ca53dpu_sel_0010_10xx 8'b0010_1000, 8'b0010_1001, 8'b0010_1010, 8'b0010_1011
`define ca53dpu_sel_0010_11xx 8'b0010_1100, 8'b0010_1101, 8'b0010_1110, 8'b0010_1111

`define ca53dpu_sel_0011_00xx 8'b0011_0000, 8'b0011_0001, 8'b0011_0010, 8'b0011_0011
`define ca53dpu_sel_0011_01xx 8'b0011_0100, 8'b0011_0101, 8'b0011_0110, 8'b0011_0111
`define ca53dpu_sel_0011_10xx 8'b0011_1000, 8'b0011_1001, 8'b0011_1010, 8'b0011_1011
`define ca53dpu_sel_0011_11xx 8'b0011_1100, 8'b0011_1101, 8'b0011_1110, 8'b0011_1111

`define ca53dpu_sel_0100_00xx 8'b0100_0000, 8'b0100_0001, 8'b0100_0010, 8'b0100_0011
`define ca53dpu_sel_0100_01xx 8'b0100_0100, 8'b0100_0101, 8'b0100_0110, 8'b0100_0111
`define ca53dpu_sel_0100_10xx 8'b0100_1000, 8'b0100_1001, 8'b0100_1010, 8'b0100_1011
`define ca53dpu_sel_0100_11xx 8'b0100_1100, 8'b0100_1101, 8'b0100_1110, 8'b0100_1111

`define ca53dpu_sel_0101_00xx 8'b0101_0000, 8'b0101_0001, 8'b0101_0010, 8'b0101_0011
`define ca53dpu_sel_0101_01xx 8'b0101_0100, 8'b0101_0101, 8'b0101_0110, 8'b0101_0111
`define ca53dpu_sel_0101_10xx 8'b0101_1000, 8'b0101_1001, 8'b0101_1010, 8'b0101_1011
`define ca53dpu_sel_0101_11xx 8'b0101_1100, 8'b0101_1101, 8'b0101_1110, 8'b0101_1111

`define ca53dpu_sel_0110_00xx 8'b0110_0000, 8'b0110_0001, 8'b0110_0010, 8'b0110_0011
`define ca53dpu_sel_0110_01xx 8'b0110_0100, 8'b0110_0101, 8'b0110_0110, 8'b0110_0111
`define ca53dpu_sel_0110_10xx 8'b0110_1000, 8'b0110_1001, 8'b0110_1010, 8'b0110_1011
`define ca53dpu_sel_0110_11xx 8'b0110_1100, 8'b0110_1101, 8'b0110_1110, 8'b0110_1111

`define ca53dpu_sel_0111_00xx 8'b0111_0000, 8'b0111_0001, 8'b0111_0010, 8'b0111_0011
`define ca53dpu_sel_0111_01xx 8'b0111_0100, 8'b0111_0101, 8'b0111_0110, 8'b0111_0111
`define ca53dpu_sel_0111_10xx 8'b0111_1000, 8'b0111_1001, 8'b0111_1010, 8'b0111_1011
`define ca53dpu_sel_0111_11xx 8'b0111_1100, 8'b0111_1101, 8'b0111_1110, 8'b0111_1111

`define ca53dpu_sel_1000_00xx 8'b1000_0000, 8'b1000_0001, 8'b1000_0010, 8'b1000_0011
`define ca53dpu_sel_1000_01xx 8'b1000_0100, 8'b1000_0101, 8'b1000_0110, 8'b1000_0111
`define ca53dpu_sel_1000_10xx 8'b1000_1000, 8'b1000_1001, 8'b1000_1010, 8'b1000_1011
`define ca53dpu_sel_1000_11xx 8'b1000_1100, 8'b1000_1101, 8'b1000_1110, 8'b1000_1111

`define ca53dpu_sel_1001_00xx 8'b1001_0000, 8'b1001_0001, 8'b1001_0010, 8'b1001_0011
`define ca53dpu_sel_1001_01xx 8'b1001_0100, 8'b1001_0101, 8'b1001_0110, 8'b1001_0111
`define ca53dpu_sel_1001_10xx 8'b1001_1000, 8'b1001_1001, 8'b1001_1010, 8'b1001_1011
`define ca53dpu_sel_1001_11xx 8'b1001_1100, 8'b1001_1101, 8'b1001_1110, 8'b1001_1111

`define ca53dpu_sel_1010_00xx 8'b1010_0000, 8'b1010_0001, 8'b1010_0010, 8'b1010_0011
`define ca53dpu_sel_1010_01xx 8'b1010_0100, 8'b1010_0101, 8'b1010_0110, 8'b1010_0111
`define ca53dpu_sel_1010_10xx 8'b1010_1000, 8'b1010_1001, 8'b1010_1010, 8'b1010_1011
`define ca53dpu_sel_1010_11xx 8'b1010_1100, 8'b1010_1101, 8'b1010_1110, 8'b1010_1111

`define ca53dpu_sel_1011_00xx 8'b1011_0000, 8'b1011_0001, 8'b1011_0010, 8'b1011_0011
`define ca53dpu_sel_1011_01xx 8'b1011_0100, 8'b1011_0101, 8'b1011_0110, 8'b1011_0111
`define ca53dpu_sel_1011_10xx 8'b1011_1000, 8'b1011_1001, 8'b1011_1010, 8'b1011_1011
`define ca53dpu_sel_1011_11xx 8'b1011_1100, 8'b1011_1101, 8'b1011_1110, 8'b1011_1111

`define ca53dpu_sel_1100_00xx 8'b1100_0000, 8'b1100_0001, 8'b1100_0010, 8'b1100_0011
`define ca53dpu_sel_1100_01xx 8'b1100_0100, 8'b1100_0101, 8'b1100_0110, 8'b1100_0111
`define ca53dpu_sel_1100_10xx 8'b1100_1000, 8'b1100_1001, 8'b1100_1010, 8'b1100_1011
`define ca53dpu_sel_1100_11xx 8'b1100_1100, 8'b1100_1101, 8'b1100_1110, 8'b1100_1111

`define ca53dpu_sel_1101_00xx 8'b1101_0000, 8'b1101_0001, 8'b1101_0010, 8'b1101_0011
`define ca53dpu_sel_1101_01xx 8'b1101_0100, 8'b1101_0101, 8'b1101_0110, 8'b1101_0111
`define ca53dpu_sel_1101_10xx 8'b1101_1000, 8'b1101_1001, 8'b1101_1010, 8'b1101_1011
`define ca53dpu_sel_1101_11xx 8'b1101_1100, 8'b1101_1101, 8'b1101_1110, 8'b1101_1111

`define ca53dpu_sel_1110_00xx 8'b1110_0000, 8'b1110_0001, 8'b1110_0010, 8'b1110_0011
`define ca53dpu_sel_1110_01xx 8'b1110_0100, 8'b1110_0101, 8'b1110_0110, 8'b1110_0111
`define ca53dpu_sel_1110_10xx 8'b1110_1000, 8'b1110_1001, 8'b1110_1010, 8'b1110_1011
`define ca53dpu_sel_1110_11xx 8'b1110_1100, 8'b1110_1101, 8'b1110_1110, 8'b1110_1111

`define ca53dpu_sel_1111_00xx 8'b1111_0000, 8'b1111_0001, 8'b1111_0010, 8'b1111_0011
`define ca53dpu_sel_1111_01xx 8'b1111_0100, 8'b1111_0101, 8'b1111_0110, 8'b1111_0111
`define ca53dpu_sel_1111_10xx 8'b1111_1000, 8'b1111_1001, 8'b1111_1010, 8'b1111_1011
`define ca53dpu_sel_1111_11xx 8'b1111_1100, 8'b1111_1101, 8'b1111_1110, 8'b1111_1111

`define ca53dpu_sel_0001_xxxx `ca53dpu_sel_0001_00xx, `ca53dpu_sel_0001_01xx, `ca53dpu_sel_0001_10xx, `ca53dpu_sel_0001_11xx
`define ca53dpu_sel_0010_xxxx `ca53dpu_sel_0010_00xx, `ca53dpu_sel_0010_01xx, `ca53dpu_sel_0010_10xx, `ca53dpu_sel_0010_11xx
`define ca53dpu_sel_0011_xxxx `ca53dpu_sel_0011_00xx, `ca53dpu_sel_0011_01xx, `ca53dpu_sel_0011_10xx, `ca53dpu_sel_0011_11xx
`define ca53dpu_sel_0100_xxxx `ca53dpu_sel_0100_00xx, `ca53dpu_sel_0100_01xx, `ca53dpu_sel_0100_10xx, `ca53dpu_sel_0100_11xx
`define ca53dpu_sel_0101_xxxx `ca53dpu_sel_0101_00xx, `ca53dpu_sel_0101_01xx, `ca53dpu_sel_0101_10xx, `ca53dpu_sel_0101_11xx
`define ca53dpu_sel_0110_xxxx `ca53dpu_sel_0110_00xx, `ca53dpu_sel_0110_01xx, `ca53dpu_sel_0110_10xx, `ca53dpu_sel_0110_11xx
`define ca53dpu_sel_0111_xxxx `ca53dpu_sel_0111_00xx, `ca53dpu_sel_0111_01xx, `ca53dpu_sel_0111_10xx, `ca53dpu_sel_0111_11xx

`define ca53dpu_sel_1000_xxxx `ca53dpu_sel_1000_00xx, `ca53dpu_sel_1000_01xx, `ca53dpu_sel_1000_10xx, `ca53dpu_sel_1000_11xx
`define ca53dpu_sel_1001_xxxx `ca53dpu_sel_1001_00xx, `ca53dpu_sel_1001_01xx, `ca53dpu_sel_1001_10xx, `ca53dpu_sel_1001_11xx
`define ca53dpu_sel_1010_xxxx `ca53dpu_sel_1010_00xx, `ca53dpu_sel_1010_01xx, `ca53dpu_sel_1010_10xx, `ca53dpu_sel_1010_11xx
`define ca53dpu_sel_1011_xxxx `ca53dpu_sel_1011_00xx, `ca53dpu_sel_1011_01xx, `ca53dpu_sel_1011_10xx, `ca53dpu_sel_1011_11xx
`define ca53dpu_sel_1100_xxxx `ca53dpu_sel_1100_00xx, `ca53dpu_sel_1100_01xx, `ca53dpu_sel_1100_10xx, `ca53dpu_sel_1100_11xx
`define ca53dpu_sel_1101_xxxx `ca53dpu_sel_1101_00xx, `ca53dpu_sel_1101_01xx, `ca53dpu_sel_1101_10xx, `ca53dpu_sel_1101_11xx
`define ca53dpu_sel_1110_xxxx `ca53dpu_sel_1110_00xx, `ca53dpu_sel_1110_01xx, `ca53dpu_sel_1110_10xx, `ca53dpu_sel_1110_11xx
`define ca53dpu_sel_1111_xxxx `ca53dpu_sel_1111_00xx, `ca53dpu_sel_1111_01xx, `ca53dpu_sel_1111_10xx, `ca53dpu_sel_1111_11xx

`define ca53dpu_sel_1xxx_xxxx `ca53dpu_sel_1000_xxxx, `ca53dpu_sel_1001_xxxx, `ca53dpu_sel_1010_xxxx, `ca53dpu_sel_1011_xxxx, \
                              `ca53dpu_sel_1100_xxxx, `ca53dpu_sel_1101_xxxx, `ca53dpu_sel_1110_xxxx, `ca53dpu_sel_1111_xxxx
`define ca53dpu_sel_01xx_xxxx `ca53dpu_sel_0100_xxxx, `ca53dpu_sel_0101_xxxx, `ca53dpu_sel_0110_xxxx, `ca53dpu_sel_0111_xxxx
`define ca53dpu_sel_001x_xxxx `ca53dpu_sel_0010_xxxx, `ca53dpu_sel_0011_xxxx

//-----------------------------------------------------------------------------
// Register number defines
//-----------------------------------------------------------------------------

// Programmer's model (virtual) addresses:
`define CA53_VADDR_R00 5'b00000
`define CA53_VADDR_R01 5'b00001
`define CA53_VADDR_R02 5'b00010
`define CA53_VADDR_R03 5'b00011
`define CA53_VADDR_R04 5'b00100
`define CA53_VADDR_R05 5'b00101
`define CA53_VADDR_R06 5'b00110
`define CA53_VADDR_R07 5'b00111
`define CA53_VADDR_R08 5'b01000
`define CA53_VADDR_R09 5'b01001
`define CA53_VADDR_R10 5'b01010
`define CA53_VADDR_R11 5'b01011
`define CA53_VADDR_R12 5'b01100
`define CA53_VADDR_R13 5'b01101
`define CA53_VADDR_R14 5'b01110
`define CA53_VADDR_R15 5'b01111
`define CA53_VADDR_R16 5'b10000
`define CA53_VADDR_R17 5'b10001
`define CA53_VADDR_R18 5'b10010
`define CA53_VADDR_R19 5'b10011
`define CA53_VADDR_R20 5'b10100
`define CA53_VADDR_R21 5'b10101
`define CA53_VADDR_R22 5'b10110
`define CA53_VADDR_R23 5'b10111
`define CA53_VADDR_R24 5'b11000
`define CA53_VADDR_R25 5'b11001
`define CA53_VADDR_R26 5'b11010
`define CA53_VADDR_R27 5'b11011
`define CA53_VADDR_R28 5'b11100
`define CA53_VADDR_R29 5'b11101
`define CA53_VADDR_R30 5'b11110
`define CA53_VADDR_R31 5'b11111

// Physical register addresses
`define CA53_ADDR_X0      6'b00_0000
`define CA53_ADDR_X1      6'b00_0001
`define CA53_ADDR_X2      6'b00_0010
`define CA53_ADDR_X3      6'b00_0011
`define CA53_ADDR_X4      6'b00_0100
`define CA53_ADDR_X5      6'b00_0101
`define CA53_ADDR_X6      6'b00_0110
`define CA53_ADDR_X7      6'b00_0111
`define CA53_ADDR_X8      6'b10_0000
`define CA53_ADDR_X9      6'b10_0001
`define CA53_ADDR_X10     6'b10_0010
`define CA53_ADDR_X11     6'b10_0011
`define CA53_ADDR_X12     6'b10_0100
`define CA53_ADDR_X13     6'b10_0101
`define CA53_ADDR_X14     6'b10_0110
`define CA53_ADDR_X15     6'b11_1111
`define CA53_ADDR_X16     6'b11_0000
`define CA53_ADDR_X17     6'b11_0001
`define CA53_ADDR_X18     6'b11_0010
`define CA53_ADDR_X19     6'b11_0011
`define CA53_ADDR_X20     6'b11_0100
`define CA53_ADDR_X21     6'b11_0101
`define CA53_ADDR_X22     6'b11_0110
`define CA53_ADDR_X23     6'b11_0111
`define CA53_ADDR_X24     6'b10_1000
`define CA53_ADDR_X25     6'b10_1001
`define CA53_ADDR_X26     6'b10_1010
`define CA53_ADDR_X27     6'b10_1011
`define CA53_ADDR_X28     6'b10_1100
`define CA53_ADDR_X29     6'b10_1101
`define CA53_ADDR_X30     6'b10_1110

`define CA53_ADDR_SP_EL0  6'b01_0000
`define CA53_ADDR_SP_EL1  6'b01_0001
`define CA53_ADDR_SP_EL2  6'b01_0010
`define CA53_ADDR_SP_EL3  6'b11_1101
`define CA53_ADDR_ELR_EL1 6'b01_0101
`define CA53_ADDR_ELR_EL2 6'b11_1110
`define CA53_ADDR_ELR_EL3 6'b11_1100

// Architectural AArch32 -> AArch64 register mappings
`define CA53_ADDR_R00     `CA53_ADDR_X0       // All modes
`define CA53_ADDR_R01     `CA53_ADDR_X1       // All modes
`define CA53_ADDR_R02     `CA53_ADDR_X2       // All modes
`define CA53_ADDR_R03     `CA53_ADDR_X3       // All modes
`define CA53_ADDR_R04     `CA53_ADDR_X4       // All modes
`define CA53_ADDR_R05     `CA53_ADDR_X5       // All modes
`define CA53_ADDR_R06     `CA53_ADDR_X6       // All modes
`define CA53_ADDR_R07     `CA53_ADDR_X7       // All modes
`define CA53_ADDR_R08     `CA53_ADDR_X8       // All modes other than FIQ
`define CA53_ADDR_R09     `CA53_ADDR_X9       // All modes other than FIQ
`define CA53_ADDR_R10     `CA53_ADDR_X10      // All modes other than FIQ
`define CA53_ADDR_R11     `CA53_ADDR_X11      // All modes other than FIQ
`define CA53_ADDR_R12     `CA53_ADDR_X12      // All modes other than FIQ
`define CA53_ADDR_R13     `CA53_ADDR_X13      // User or System mode
`define CA53_ADDR_R14     `CA53_ADDR_X14      // User, System or Hyp mode
`define CA53_ADDR_R13_HYP `CA53_ADDR_X15      // Hyp mode
`define CA53_ADDR_R14_IRQ `CA53_ADDR_X16      // IRQ mode
`define CA53_ADDR_R13_IRQ `CA53_ADDR_X17      // IRQ mode
`define CA53_ADDR_R14_SVC `CA53_ADDR_X18      // Supervisor mode
`define CA53_ADDR_R13_SVC `CA53_ADDR_X19      // Supervisor mode
`define CA53_ADDR_R14_ABT `CA53_ADDR_X20      // Abort mode
`define CA53_ADDR_R13_ABT `CA53_ADDR_X21      // Abort mode
`define CA53_ADDR_R14_UND `CA53_ADDR_X22      // Undef mode
`define CA53_ADDR_R13_UND `CA53_ADDR_X23      // Undef mode
`define CA53_ADDR_R08_FIQ `CA53_ADDR_X24      // FIQ mode
`define CA53_ADDR_R09_FIQ `CA53_ADDR_X25      // FIQ mode
`define CA53_ADDR_R10_FIQ `CA53_ADDR_X26      // FIQ mode
`define CA53_ADDR_R11_FIQ `CA53_ADDR_X27      // FIQ mode
`define CA53_ADDR_R12_FIQ `CA53_ADDR_X28      // FIQ mode
`define CA53_ADDR_R13_FIQ `CA53_ADDR_X29      // FIQ mode
`define CA53_ADDR_R14_FIQ `CA53_ADDR_X30      // FIQ mode
`define CA53_ADDR_ELR_HYP `CA53_ADDR_ELR_EL2  // Hyp mode

// The following mappings are not defined by the architecture,
// but are used by CortexA53 to save registers
`define CA53_ADDR_R14_MON `CA53_ADDR_ELR_EL3  // Monitor mode
`define CA53_ADDR_R13_MON `CA53_ADDR_SP_EL3   // Monitor mode

// Bit positions for one-hot encodings
`define CA53_LONG_RF_ADDR_W   38

`define CA53_ADDR_BIT_X0      0
`define CA53_ADDR_BIT_X1      1
`define CA53_ADDR_BIT_X2      2
`define CA53_ADDR_BIT_X3      3
`define CA53_ADDR_BIT_X4      4
`define CA53_ADDR_BIT_X5      5
`define CA53_ADDR_BIT_X6      6
`define CA53_ADDR_BIT_X7      7
`define CA53_ADDR_BIT_X8      8
`define CA53_ADDR_BIT_X9      9
`define CA53_ADDR_BIT_X10     10
`define CA53_ADDR_BIT_X11     11
`define CA53_ADDR_BIT_X12     12
`define CA53_ADDR_BIT_X13     13
`define CA53_ADDR_BIT_X14     14
`define CA53_ADDR_BIT_X15     15
`define CA53_ADDR_BIT_X16     16
`define CA53_ADDR_BIT_X17     17
`define CA53_ADDR_BIT_X18     18
`define CA53_ADDR_BIT_X19     19
`define CA53_ADDR_BIT_X20     20
`define CA53_ADDR_BIT_X21     21
`define CA53_ADDR_BIT_X22     22
`define CA53_ADDR_BIT_X23     23
`define CA53_ADDR_BIT_X24     24
`define CA53_ADDR_BIT_X25     25
`define CA53_ADDR_BIT_X26     26
`define CA53_ADDR_BIT_X27     27
`define CA53_ADDR_BIT_X28     28
`define CA53_ADDR_BIT_X29     29
`define CA53_ADDR_BIT_X30     30

`define CA53_ADDR_BIT_SP_EL0  31
`define CA53_ADDR_BIT_SP_EL1  32
`define CA53_ADDR_BIT_SP_EL2  33
`define CA53_ADDR_BIT_SP_EL3  34
`define CA53_ADDR_BIT_ELR_EL1 35
`define CA53_ADDR_BIT_ELR_EL2 36
`define CA53_ADDR_BIT_ELR_EL3 37

`define CA53_ADDR_BIT_R00     `CA53_ADDR_BIT_X0
`define CA53_ADDR_BIT_R01     `CA53_ADDR_BIT_X1
`define CA53_ADDR_BIT_R02     `CA53_ADDR_BIT_X2
`define CA53_ADDR_BIT_R03     `CA53_ADDR_BIT_X3
`define CA53_ADDR_BIT_R04     `CA53_ADDR_BIT_X4
`define CA53_ADDR_BIT_R05     `CA53_ADDR_BIT_X5
`define CA53_ADDR_BIT_R06     `CA53_ADDR_BIT_X6
`define CA53_ADDR_BIT_R07     `CA53_ADDR_BIT_X7
`define CA53_ADDR_BIT_R08     `CA53_ADDR_BIT_X8
`define CA53_ADDR_BIT_R09     `CA53_ADDR_BIT_X9
`define CA53_ADDR_BIT_R10     `CA53_ADDR_BIT_X10
`define CA53_ADDR_BIT_R11     `CA53_ADDR_BIT_X11
`define CA53_ADDR_BIT_R12     `CA53_ADDR_BIT_X12
`define CA53_ADDR_BIT_R13     `CA53_ADDR_BIT_X13
`define CA53_ADDR_BIT_R14     `CA53_ADDR_BIT_X14
`define CA53_ADDR_BIT_R13_HYP `CA53_ADDR_BIT_X15
`define CA53_ADDR_BIT_R14_IRQ `CA53_ADDR_BIT_X16
`define CA53_ADDR_BIT_R13_IRQ `CA53_ADDR_BIT_X17
`define CA53_ADDR_BIT_R14_SVC `CA53_ADDR_BIT_X18
`define CA53_ADDR_BIT_R13_SVC `CA53_ADDR_BIT_X19
`define CA53_ADDR_BIT_R14_ABT `CA53_ADDR_BIT_X20
`define CA53_ADDR_BIT_R13_ABT `CA53_ADDR_BIT_X21
`define CA53_ADDR_BIT_R14_UND `CA53_ADDR_BIT_X22
`define CA53_ADDR_BIT_R13_UND `CA53_ADDR_BIT_X23
`define CA53_ADDR_BIT_R08_FIQ `CA53_ADDR_BIT_X24
`define CA53_ADDR_BIT_R09_FIQ `CA53_ADDR_BIT_X25
`define CA53_ADDR_BIT_R10_FIQ `CA53_ADDR_BIT_X26
`define CA53_ADDR_BIT_R11_FIQ `CA53_ADDR_BIT_X27
`define CA53_ADDR_BIT_R12_FIQ `CA53_ADDR_BIT_X28
`define CA53_ADDR_BIT_R13_FIQ `CA53_ADDR_BIT_X29
`define CA53_ADDR_BIT_R14_FIQ `CA53_ADDR_BIT_X30
`define CA53_ADDR_BIT_R13_MON `CA53_ADDR_BIT_SP_EL3
`define CA53_ADDR_BIT_R14_MON `CA53_ADDR_BIT_ELR_EL3
`define CA53_ADDR_BIT_ELR_HYP `CA53_ADDR_BIT_ELR_EL2

// SPSR encodings for MSR/MRS Instructions
`define CA53_SPSR_CRNT 3'b000
`define CA53_SPSR_FIQ  3'b001
`define CA53_SPSR_IRQ  3'b010
`define CA53_SPSR_SVC  3'b011
`define CA53_SPSR_ABT  3'b100
`define CA53_SPSR_UND  3'b101
`define CA53_SPSR_MON  3'b110
`define CA53_SPSR_HYP  3'b111

//-----------------------------------------------------------------------------
// Define which execution pipline the micro instruction should be sent to.
// Need to define one bit per execution pipeline to allow for faster decoding
// in the decode stage when mapping the micro instruction packet from the
// decoders to the target execution pipeline.
//-----------------------------------------------------------------------------
`define CA53_EX_PIPE_W           6
`define CA53_EX_PIPE_NULL        6'b000000 // If no valid instruction
`define CA53_EX_PIPE_ALU         6'b000001
`define CA53_EX_PIPE_BR          6'b000100
`define CA53_EX_PIPE_DCU         6'b001000
`define CA53_EX_PIPE_DIV         6'b010000
`define CA53_EX_PIPE_STR         6'b100000

`define CA53_EX_PIPE_ALU_BIT     0
`define CA53_EX_PIPE_MAC_BIT     1
`define CA53_EX_PIPE_BR_BIT      2
`define CA53_EX_PIPE_DCU_BIT     3
`define CA53_EX_PIPE_DIV_BIT     4
`define CA53_EX_PIPE_STR_BIT     5

//-----------------------------------------------------------------------------
// Define instruction type
//-----------------------------------------------------------------------------

`define CA53_EXPT_INSTR_TYPE_W               7
`define CA53_EXPT_INSTR_TYPE_NULL            7'b0000000
`define CA53_EXPT_INSTR_TYPE_UNDEF           7'b0000001
`define CA53_EXPT_INSTR_TYPE_PD_UNDEF        7'b0000010
`define CA53_EXPT_INSTR_TYPE_FABORT          7'b0000011
`define CA53_EXPT_INSTR_TYPE_SVC             7'b0000100
`define CA53_EXPT_INSTR_TYPE_HVC             7'b0000101
`define CA53_EXPT_INSTR_TYPE_SMC             7'b0000110
`define CA53_EXPT_INSTR_TYPE_WFI             7'b0000111
`define CA53_EXPT_INSTR_TYPE_WFE             7'b0001000
`define CA53_EXPT_INSTR_TYPE_BKPT            7'b0001001
`define CA53_EXPT_INSTR_TYPE_HW_BKPT         7'b0001010
`define CA53_EXPT_INSTR_TYPE_MON_ACCESS      7'b0001011
`define CA53_EXPT_INSTR_TYPE_VIRTUAL_MEM_CTL 7'b0001100
`define CA53_EXPT_INSTR_TYPE_DCZVA           7'b0001101
`define CA53_EXPT_INSTR_TYPE_TLB             7'b0001110
`define CA53_EXPT_INSTR_TYPE_CACHE_POU       7'b0001111
`define CA53_EXPT_INSTR_TYPE_DCACHE_POC      7'b0010000
`define CA53_EXPT_INSTR_TYPE_DCACHE_SETWAY   7'b0010001
`define CA53_EXPT_INSTR_TYPE_ACTLR           7'b0010010
`define CA53_EXPT_INSTR_TYPE_ID_GROUP0       7'b0010011
`define CA53_EXPT_INSTR_TYPE_ID_GROUP1       7'b0010100
`define CA53_EXPT_INSTR_TYPE_ID_GROUP2       7'b0010101
`define CA53_EXPT_INSTR_TYPE_ID_GROUP3       7'b0010110
`define CA53_EXPT_INSTR_TYPE_CPACR           7'b0010111
`define CA53_EXPT_INSTR_TYPE_CNTPS           7'b0011000
`define CA53_EXPT_INSTR_TYPE_FP              7'b0011001
`define CA53_EXPT_INSTR_TYPE_FP_ID           7'b0011010
`define CA53_EXPT_INSTR_TYPE_FP_ID0          7'b0011011
`define CA53_EXPT_INSTR_TYPE_FP_ID3          7'b0011100
`define CA53_EXPT_INSTR_TYPE_NEON            7'b0011101
`define CA53_EXPT_INSTR_TYPE_CRYPTO          7'b0011110
`define CA53_EXPT_INSTR_TYPE_DBG_ROM         7'b0011111
`define CA53_EXPT_INSTR_TYPE_DBG_OS          7'b0100000
`define CA53_EXPT_INSTR_TYPE_DBG_ACCESS      7'b0100001
`define CA53_EXPT_INSTR_TYPE_DBG_SHARED      7'b0100010
`define CA53_EXPT_INSTR_TYPE_DBG_DTR         7'b0100011
`define CA53_EXPT_INSTR_TYPE_PMU_PMCR        7'b0100100
`define CA53_EXPT_INSTR_TYPE_PMU_REG         7'b0100101
`define CA53_EXPT_INSTR_TYPE_CNTPCT          7'b0100110
`define CA53_EXPT_INSTR_TYPE_CNTP            7'b0100111
`define CA53_EXPT_INSTR_TYPE_CNTV            7'b0101000
`define CA53_EXPT_INSTR_TYPE_CNTVCT          7'b0101001
`define CA53_EXPT_INSTR_TYPE_CNTFRQ          7'b0101010
`define CA53_EXPT_INSTR_TYPE_MCR_MRC_MISC    7'b0101011
`define CA53_EXPT_INSTR_TYPE_CPUACTLR        7'b0101100
`define CA53_EXPT_INSTR_TYPE_CPUECTLR        7'b0101101
`define CA53_EXPT_INSTR_TYPE_HLT             7'b0101110
`define CA53_EXPT_INSTR_TYPE_VECT_CATCH      7'b0101111
`define CA53_EXPT_INSTR_TYPE_DCPS1           7'b0110000
`define CA53_EXPT_INSTR_TYPE_DCPS2           7'b0110001
`define CA53_EXPT_INSTR_TYPE_DCPS3           7'b0110010
`define CA53_EXPT_INSTR_TYPE_L2CTLR          7'b0110011
`define CA53_EXPT_INSTR_TYPE_L2ECTLR         7'b0110100
`define CA53_EXPT_INSTR_TYPE_L2ACTLR         7'b0110101
`define CA53_EXPT_INSTR_TYPE_PMU_SWINC       7'b0110110
`define CA53_EXPT_INSTR_TYPE_PMU_EVREG       7'b0110111
`define CA53_EXPT_INSTR_TYPE_PMU_CCNT_RD     7'b0111000
`define CA53_EXPT_INSTR_TYPE_PMU_USERENR     7'b0111001
`define CA53_EXPT_INSTR_TYPE_DAIF            7'b0111010
`define CA53_EXPT_INSTR_TYPE_CP15BAR         7'b0111011
`define CA53_EXPT_INSTR_TYPE_SETEND          7'b0111100
`define CA53_EXPT_INSTR_TYPE_RESET_CATCH     7'b0111101
`define CA53_EXPT_INSTR_TYPE_EXPT_CATCH      7'b0111110
`define CA53_EXPT_INSTR_TYPE_IFU_PARITY      7'b0111111
`define CA53_EXPT_INSTR_TYPE_GIC_GROUP0      7'b1000000
`define CA53_EXPT_INSTR_TYPE_GIC_GROUP1      7'b1000001
`define CA53_EXPT_INSTR_TYPE_GIC_COMMON      7'b1000011
`define CA53_EXPT_INSTR_TYPE_GIC_SRE         7'b1000100
`define CA53_EXPT_INSTR_TYPE_GIC_SGI         7'b1000101
`define CA53_EXPT_INSTR_TYPE_GIC_MISC        7'b1000110
`define CA53_EXPT_INSTR_TYPE_MON_MCR_MRC     7'b1000111

// For Ex1, always qualified with syndrome_type, so can have overlapping entries
`define CA53_EXPT_INSTR_TYPE_EX1_W           2
`define CA53_EXPT_INSTR_TYPE_EX1_WFE         2'b00
`define CA53_EXPT_INSTR_TYPE_EX1_FP          2'b00
`define CA53_EXPT_INSTR_TYPE_EX1_NEON        2'b11
`define CA53_EXPT_INSTR_TYPE_EX1_SVC         2'b00
`define CA53_EXPT_INSTR_TYPE_EX1_HVC         2'b01
`define CA53_EXPT_INSTR_TYPE_EX1_SMC         2'b10
`define CA53_EXPT_INSTR_TYPE_EX1_HW_BKPT     2'b10
`define CA53_EXPT_INSTR_TYPE_EX1_BKPT        2'b01
`define CA53_EXPT_INSTR_TYPE_EX1_VECT_CATCH  2'b11

`define CA53_INSTR_TYPE_W                    3
`define CA53_INSTR_TYPE_NULL                 3'b000
`define CA53_INSTR_TYPE_SYNC_EXPT            3'b001
`define CA53_INSTR_TYPE_WFI                  3'b010
`define CA53_INSTR_TYPE_WFE                  3'b011
`define CA53_INSTR_TYPE_SEV                  3'b100
`define CA53_INSTR_TYPE_ISB                  3'b101
`define CA53_INSTR_TYPE_SEVL                 3'b110

//-----------------------------------------------------------------------------
// Define slot1 instruction type
//-----------------------------------------------------------------------------
`define CA53_SLOT1_INSTR_TYPE_W        3
`define CA53_SLOT1_INSTR_TYPE_NULL     3'b000
`define CA53_SLOT1_INSTR_TYPE_LS       3'b001
`define CA53_SLOT1_INSTR_TYPE_FP       3'b010
`define CA53_SLOT1_INSTR_TYPE_FP_LS    3'b011
`define CA53_SLOT1_INSTR_TYPE_MUL      3'b100
`define CA53_SLOT1_INSTR_TYPE_BRANCH   3'b101
`define CA53_SLOT1_INSTR_TYPE_BX       3'b110
`define CA53_SLOT1_INSTR_TYPE_BLX      3'b111

//-----------------------------------------------------------------------------
// Encoding for LU operations
//-----------------------------------------------------------------------------

`define CA53_LU_CTL_ADD          4'b0000  // Add
`define CA53_LU_CTL_SUB          4'b0001  // Subtract, reverse subtract
`define CA53_LU_CTL_ADC          4'b0010  // Add with carry
`define CA53_LU_CTL_SBC          4'b0011  // Subtract, reverse subtract with carry

`define CA53_LU_CTL_BIC          4'b0100  // A AND NOT(B)
`define CA53_LU_CTL_EOR          4'b0110  // A EOR B      "Exclusive OR"
`define CA53_LU_CTL_AND          4'b1000  // A AND B
`define CA53_LU_CTL_EON          4'b1001  // A EOR NOT B  "Exclusive NOR"
`define CA53_LU_CTL_ORR          4'b1110  // A ORR B
`define CA53_LU_CTL_ORN          4'b1101  // A ORR ~B

`define CA53_LU_CTL_CSEL         4'b1010  // Conditional select

`define CA53_LU_CTL_CRC32        4'b0101  // CRC32 instructions

`define CA53_LU_CTL_CLZ          4'b0111  // Used to choose the output from the CLZ
                                          // logic.
`define CA53_LU_CTL_GEN_SAT      4'b1100  // Used to choose the output from the
                                          // saturation logic
`define CA53_LU_CTL_EXTRACT      4'b1011  // Used to choose the output from the
                                          // extract/extend logic
`define CA53_LU_CTL_MASKSEL      4'b1111  // Used to choose the output from the
                                          // masking/selection logic.

`define CA53_LU_CTL_MOVB         4'b1010  // Select B operand - overloads CSEL
                                          // as never directly used by an
                                          // instruction, but is used on skewing

// Mask generation information used within the LU for SEL, PKHBT, PKHTB,
// MOVT, MOVW instructions
`define CA53_ALU_LU_MASK_SEL       3'b001


//-----------------------------------------------------------------------------
// Encoding for integer multiplier
//-----------------------------------------------------------------------------

`define CA53_MULT_TYPE_W        4

`define CA53_MULT_TYPE_ACCONLY  4'b0000

`define CA53_MULT_TYPE_USAD     4'b0001

`define CA53_MULT_TYPE_16x16    4'b0100
`define CA53_MULT_TYPE_32x32    4'b0101
`define CA53_MULT_TYPE_2x16x16  4'b0110
`define CA53_MULT_TYPE_32x16    4'b0111

`define CA53_MULT_TYPE_64x64    4'b1100
`define CA53_MULT_TYPE_64x64_LH 4'b1101
`define CA53_MULT_TYPE_64x64_HL 4'b1110
`define CA53_MULT_TYPE_64x64_HH 4'b1111

// ==========================================================================
// We need control signals for defining the Mux select for {SHF_A, SHF_B,
// SHF_C}  in the Ex1 stage of the ALU pipeline. This is because these muxes
// have multiple inputs from the RF read ports or the immediate values.
//
// SHF_A : Non-forwarding inputs are {RF_READ_R0}
// SHF_B : Non-forwarding inputs are {RF_READ_R1, Immediates}
// SHF_C : Non-forwarding inputs are {RF_READ_R2, Immediates, Cond/NZCV} (latter for CSEL)
//

`define CA53_SEL_SHF_A_W 2
`define CA53_SEL_SHF_B_W 3
`define CA53_SEL_SHF_C_W 2

// dp_data_a_sel
`define CA53_SEL_SHF_A_ZERO      2'b00
`define CA53_SEL_SHF_A_R0        2'b01
`define CA53_SEL_SHF_A_PC        2'b10
`define CA53_SEL_SHF_A_R3        2'b11

// dp_data_b_sel
`define CA53_SEL_SHF_B_ZERO      3'b000
`define CA53_SEL_SHF_B_R1        3'b001
`define CA53_SEL_SHF_B_PC        3'b010
`define CA53_SEL_SHF_B_IMM_DATA  3'b011
`define CA53_SEL_SHF_B_R4        3'b111

// dp_data_c_sel
`define CA53_SEL_SHF_C_ZERO      2'b00
`define CA53_SEL_SHF_C_R2        2'b01
`define CA53_SEL_SHF_C_IMM_SHIFT 2'b10

`define CA53_SEL_MSK_B_W         1
`define CA53_SEL_MSK_B_IMM_DATA  1'b1

// ex1_ctl_mask_sel
`define CA53_MASK_W              3
`define CA53_MASK_ZERO           3'b000
`define CA53_MASK_COMB           3'b001
`define CA53_MASK_SNGL           3'b010
`define CA53_MASK_TOP            3'b011
`define CA53_MASK_BOT            3'b100
`define CA53_MASK_MOVW           3'b101
`define CA53_MASK_C              3'b110

//ex1_ctl_rev_type
`define CA53_REV_MUX_W           3
`define CA53_REV_MUX_NORMAL      3'b000
`define CA53_REV_MUX_REV         3'b001
`define CA53_REV_MUX_REVSH       3'b010
`define CA53_REV_MUX_REV16       3'b011
`define CA53_REV_MUX_RBIT        3'b100
`define CA53_REV_MUX_SAT_DBL     3'b101
`define CA53_REV_MUX_ZERO        3'b110

`define CA53_SEL_MAC_A_W         2
`define CA53_SEL_MAC_A_ZERO      2'b00
`define CA53_SEL_MAC_A_R0        2'b01
`define CA53_SEL_MAC_A_R3        2'b10

`define CA53_SEL_MAC_B_W         2
`define CA53_SEL_MAC_B_ZERO      2'b00
`define CA53_SEL_MAC_B_R1        2'b01
`define CA53_SEL_MAC_B_R4        2'b10

`define CA53_SEL_DIV_A_W         2
`define CA53_SEL_DIV_A_ZERO      2'b00
`define CA53_SEL_DIV_A_R0        2'b01
`define CA53_SEL_DIV_A_R3        2'b11

`define CA53_SEL_DIV_B_W         2
`define CA53_SEL_DIV_B_ZERO      2'b00
`define CA53_SEL_DIV_B_R1        2'b01
`define CA53_SEL_DIV_B_R4        2'b11

`define CA53_SEL_STR_A_ZERO      3'b000
`define CA53_SEL_STR_A_R2        3'b001
`define CA53_SEL_STR_A_PC        3'b010
`define CA53_SEL_STR_A_FR0       3'b011
`define CA53_SEL_STR_A_R1        3'b100
`define CA53_SEL_STR_A_FR1       3'b101
`define CA53_SEL_STR_A_R4        3'b110
`define CA53_SEL_STR_A_W         3

`define CA53_SEL_STR_B_ZERO      3'b000
`define CA53_SEL_STR_B_R3        3'b001
`define CA53_SEL_STR_B_PC        3'b010
`define CA53_SEL_STR_B_FR1       3'b011
`define CA53_SEL_STR_B_A_H       3'b100
`define CA53_SEL_STR_B_STR1      3'b101
`define CA53_SEL_STR_B_R2        3'b110
`define CA53_SEL_STR_B_W         3

`define CA53_ALU_OP_COMP_NULL    2'b00
`define CA53_ALU_OP_COMP_SHF_B   2'b10
`define CA53_ALU_OP_COMP_W       2

`define CA53_NULL                1'b0

`define CA53_STR0_FP_SEL_NONE    2'b00
`define CA53_STR0_FP_SEL_FR0     2'b01
`define CA53_STR0_FP_SEL_FR0_FR1 2'b11
`define CA53_STR0_FP_SEL_FR4     2'b10

`define CA53_STR1_FP_SEL_NONE    2'b00
`define CA53_STR1_FP_SEL_FR3     2'b01
`define CA53_STR1_FP_SEL_FR3_FR4 2'b11
`define CA53_STR1_FP_SEL_FR1     2'b10

//---------------------------------
// Shift operations in the ALU
// pipeline
//---------------------------------

`define CA53_SHIFT_OP_NOP     3'b000
`define CA53_SHIFT_OP_EXTR    3'b001
`define CA53_SHIFT_OP_SP1     3'b010  // Spare 1
`define CA53_SHIFT_OP_SP2     3'b011  // Spare 2
`define CA53_SHIFT_OP_ASR     3'b110
`define CA53_SHIFT_OP_LSL     3'b100
`define CA53_SHIFT_OP_LSR     3'b101
`define CA53_SHIFT_OP_ROR     3'b111
`define CA53_SHIFT_OP_W 3

`define CA53_SHIFT_MOD_W 1

//------------------------------------------------------------------------------------
// DPU Branch Pipeline Control
//------------------------------------------------------------------------------------
// =========================
// Basic control information
// =========================
//

//Branch pipeline control
`define CA53_BR_PIPECTL_W 4

`define CA53_BR_NO_BRANCH                   3'b000
`define CA53_BR_DIRECT                      3'b001
`define CA53_BR_PREFETCH_FLUSH              3'b010
`define CA53_BR_WFX_RESTART                 3'b100
`define CA53_BR_INDIRECT_TBB                3'b011
`define CA53_BR_INDIRECT_DP                 3'b101
`define CA53_BR_INDIRECT_ST                 3'b110
`define CA53_BR_INDIRECT_LD                 3'b111

//Types of branches used during decode of direct branches
`define CA53_STANDARD_BRANCH                2'b00
`define CA53_ILLEGAL_BX_IMM                 2'b01
`define CA53_BRANCH_AND_LINK                2'b10
`define CA53_BRANCH_AND_LINK_WITH_EXCHANGE  2'b11

//Branch predictability - used in both direct and indirect branch decode
`define CA53_IS_NOT_PREDICTABLE             1'b0
`define CA53_IS_PREDICTABLE                 1'b1

//Miscellaneous signals for direct branch decode
`define CA53_RF_RD_EN_IMMED_BR              4'b0000
`define CA53_BR_OFFSET_BITS                 23:0
`define CA53_H_BIT                          24
`define CA53_TAKEN_PRED_BIT                 25
`define CA53_EXCHANGE_BIT                   26

//Some defines used to signal the type of branch.
`define CA53_IS_NOT_RETURN                  1'b0
`define CA53_IS_RETURN                      1'b1
`define CA53_IS_NOT_CALL                    1'b0
`define CA53_IS_CALL                        1'b1
`define CA53_IS_DIRECT                      1'b1
`define CA53_IS_NOT_DIRECT                  1'b0

//Return address valid encodings.
`define CA53_RETURN_ADDR_VALID              1'b1
`define CA53_RETURN_ADDR_INVALID            1'b0

//may be depricated. Valids are now set in the arbiter based on ex_pipe encodings
`define CA53_RF_RD_SPECIAL_BR               4'b0000
`define CA53_BR_IS_NOT_VALID                1'b0
`define CA53_BR_IS_VALID                    1'b1

`define CA53_BR_X_BIT_W                     2
`define CA53_BX_RM_VALID                    2'b10
`define CA53_BX_IMM_VALID_FROM_ARM          2'b01   //going into thumb
`define CA53_BX_IMM_VALID_FROM_THUMB        2'b11   //going into ARM

`define CA53_LDR_U_BIT 23
`define CA53_LDR_SHIFT_LSL 2'b00
`define CA53_LDR_SHIFT_BITS 6:5
`define CA53_LDR_SHIFT_IMM_BITS 11:7
`define CA53_LDR_OFFSET_12_BITS 11:0
`define CA53_LDR_RD_BITS 15:12
`define CA53_LDR_RN_BITS 19:16
`define CA53_LDR_RM_BITS 3:0

// Other defines
`define CA53_REG_UNUSED 4'b0000

//---------------------------------------------------------------------------

// Defines for the architectural condition codes:
`define CA53_CC_EQ 4'b0000
`define CA53_CC_NE 4'b0001
`define CA53_CC_CS 4'b0010
`define CA53_CC_CC 4'b0011
`define CA53_CC_MI 4'b0100
`define CA53_CC_PL 4'b0101
`define CA53_CC_VS 4'b0110
`define CA53_CC_VC 4'b0111
`define CA53_CC_HI 4'b1000
`define CA53_CC_LS 4'b1001
`define CA53_CC_GE 4'b1010
`define CA53_CC_LT 4'b1011
`define CA53_CC_GT 4'b1100
`define CA53_CC_LE 4'b1101
`define CA53_CC_AL 4'b1110
`define CA53_CC_NV 4'b1111
`define CA53_CC_AL_or_NV 3'b111

`define CA53_CC_FLAGS_N    3
`define CA53_CC_FLAGS_Z    2
`define CA53_CC_FLAGS_C    1
`define CA53_CC_FLAGS_V    0

// AGU control params

// Defines for DCU_A mux selection
`define CA53_SEL_DCU_A_ZERO    2'b00 // Read a zero
`define CA53_SEL_DCU_A_R0      2'b01 // RF source data
`define CA53_SEL_DCU_A_PC      2'b10 // PC for current instruction
`define CA53_SEL_DCU_A_MUL     2'b11 // Use previous address, load/store multiple
`define CA53_SEL_DCU_A_W 2

// Defines for DCU_B mux selection.
`define CA53_SEL_DCU_B_ZERO    7'b000_0000 // B op = Zero
`define CA53_SEL_DCU_B_1       7'b100_0000 // +1 for Neon load/stores
`define CA53_SEL_DCU_B_2       7'b101_0000 // +2 for Neon load/stores
`define CA53_SEL_DCU_B_4       7'b110_0000 // +/- 4
`define CA53_SEL_DCU_B_8       7'b000_1000 // +/- 8

`define CA53_SEL_DCU_B_BIT_R1      0 // RF source data
`define CA53_SEL_DCU_B_BIT_IMM_LS  1 // 32-bit immediate
`define CA53_SEL_DCU_B_BIT_SH      2 // Fwd path: SH
`define CA53_SEL_DCU_B_BIT_PM_8    3 // +/- 8
`define CA53_SEL_DCU_B_W 7

// Compressed defines for DCU_A / DCU_B forwarding mux selection
`define CA53_SEL_FWD_DCU_W            6
`define CA53_SEL_FWD_DCU_BIT_W0F_WR   0 // Fwd from W0
`define CA53_SEL_FWD_DCU_BIT_W1F_WR   1 // Fwd from W1
`define CA53_SEL_FWD_DCU_BIT_W2F_WR   2 // Fwd from W2
`define CA53_SEL_FWD_DCU_BIT_NOF      3 // No Fwd
`define CA53_SEL_FWD_DCU_BIT_W1F_EX2  4 // Fwd from ALU0 Ex2
`define CA53_SEL_FWD_DCU_BIT_W2F_EX2  5 // Fwd from ALU1 Ex2


// DP immediate value selection
// - Note encoded to make generation efficient by bit-slicing opcode in certain cases
`define CA53_IMM_SEL_W            3
`define CA53_IMM_SEL_NULL         3'b000
`define CA53_IMM_SEL_T32_1        3'b001
`define CA53_IMM_SEL_T32_2        3'b010
`define CA53_IMM_SEL_T32_3        3'b011
`define CA53_IMM_SEL_A64_LOG_IMM  3'b100
`define CA53_IMM_SEL_TBB          3'b101
`define CA53_IMM_SEL_ROR          3'b110
`define CA53_IMM_SEL_LSL          3'b111
`define CA53_IMM_SEL_X            3'bxxx

// Immediate LSL types
`define CA53_IMM_LSL_0            6'b000001
`define CA53_IMM_LSL_16           6'b000010
`define CA53_IMM_LSL_32           6'b000100
`define CA53_IMM_LSL_48           6'b001000
`define CA53_IMM_LSL_ADRP         6'b010000
`define CA53_IMM_LSL_12           6'b100000

// Encodings to indicate where data is generated by an instruction.
// Used for the forwarding logic and the mux to the write port.
`define CA53_RF_WR_SRC_W0_W       3
`define CA53_RF_WR_SRC_W0_0       3'b000
`define CA53_RF_WR_SRC_W0_STREX   3'b000
`define CA53_RF_WR_SRC_W0_DCU_0   3'b001
`define CA53_RF_WR_SRC_W0_CPSR    3'b010
`define CA53_RF_WR_SRC_W0_MAC_HI  3'b011
`define CA53_RF_WR_SRC_W0_STR     3'b100
`define CA53_RF_WR_SRC_W0_CP      3'b101
`define CA53_RF_WR_SRC_W0_SPSR    3'b110
`define CA53_RF_WR_SRC_W0_BASE    3'b111

// Encodings for W1 and W2 must be equivalent
`define CA53_RF_WR_SRC_W1_W       3
`define CA53_RF_WR_SRC_W1_0       3'b000
`define CA53_RF_WR_SRC_W1_ALU     3'b001
`define CA53_RF_WR_SRC_W1_MAC_LO  3'b010
`define CA53_RF_WR_SRC_W1_DIV     3'b011
`define CA53_RF_WR_SRC_W1_CP      3'b100
`define CA53_RF_WR_SRC_W1_FP_ALU  3'b101
`define CA53_RF_WR_SRC_W1_STR     3'b110

`define CA53_RF_WR_SRC_W2_W       3
`define CA53_RF_WR_SRC_W2_0       3'b000
`define CA53_RF_WR_SRC_W2_ALU     3'b001
`define CA53_RF_WR_SRC_W2_MAC_LO  3'b010
`define CA53_RF_WR_SRC_W2_FP_ALU  3'b101
`define CA53_RF_WR_SRC_W2_STR     3'b110
`define CA53_RF_WR_SRC_W2_DCU_1   3'b111

// When write data becomes available for forwarding - rf_wr_when_w*
`define CA53_RF_WR_WHEN_W         3
`define CA53_RF_WR_WHEN_LATE_WR   3'b111
`define CA53_RF_WR_WHEN_EARLY_WR  3'b011
`define CA53_RF_WR_WHEN_EX2       3'b001
`define CA53_RF_WR_WHEN_EX1       3'b000

// When read data is needed in the data path - rf_rd_need_r*
`define CA53_RF_RD_NEED_W         3
`define CA53_RF_RD_NEED_EARLY_ISS 3'b111
`define CA53_RF_RD_NEED_LATE_ISS  3'b110
`define CA53_RF_RD_NEED_EX1       3'b100
`define CA53_RF_RD_NEED_EX2       3'b000

// Floating point write controls
`define CA53_RF_FWR_WHEN_W     3
`define CA53_RF_FWR_WHEN_0     3'b000
`define CA53_RF_FWR_WHEN_F3    3'b000
`define CA53_RF_FWR_WHEN_F4    3'b001
`define CA53_RF_FWR_WHEN_F5    3'b011
`define CA53_RF_FWR_WHEN_L_F5  3'b111

`define CA53_RF_FRD_NEED_W     1
`define CA53_RF_FRD_NEED_F1    1'b1
`define CA53_RF_FRD_NEED_F2    1'b0

`define CA53_RF_FWR_SRC_W           4
`define CA53_RF_FWR_SRC_0           4'b0000
`define CA53_RF_FWR_SRC_NONE        4'b0000
`define CA53_RF_FWR_SRC_DCU_DUP     4'b0101
`define CA53_RF_FWR_SRC_DCU_DUP2    4'b1101
`define CA53_RF_FWR_SRC_FAD_Q       4'b0010
`define CA53_RF_FWR_SRC_FAD_NARROW  4'b1011
`define CA53_RF_FWR_SRC_FML_Q       4'b0011
`define CA53_RF_FWR_SRC_DCU_PERM    4'b0100
`define CA53_RF_FWR_SRC_DCU_SGL     4'b1100
`define CA53_RF_FWR_SRC_DCU_SGL2    4'b1010
`define CA53_RF_FWR_SRC_STR         4'b0001
`define CA53_RF_FWR_SRC_DCU_DBL     4'b1000
`define CA53_RF_FWR_SRC_STR_SP      4'b0110
`define CA53_RF_FWR_SRC_STR_2SP     4'b1110
`define CA53_RF_FWR_SRC_CRYPTO_F3   4'b1111
`define CA53_RF_FWR_SRC_CRYPTO_F5   4'b1001

// Where to forward from
`define CA53_FWD_W        4
`define CA53_FWD_W0       4'b0000
`define CA53_FWD_W1       4'b0001
`define CA53_FWD_W2       4'b0010
`define CA53_FWD_ALU0_EX2 4'b0011
`define CA53_FWD_NULL     4'b0100
`define CA53_FWD_ALU1_EX2 4'b0101
`define CA53_FWD_ALU0_EX1 4'b0110
`define CA53_FWD_ALU1_EX1 4'b0111
`define CA53_FWD_FP       4'b1011
`define CA53_FWD_FP_LO    4'b1001
`define CA53_FWD_FP_HI    4'b1010

//------------------------------------------
//       LS related defines
//------------------------------------------

`define CA53_LS_INSTR_TYPE_W             4

`define CA53_LS_INSTR_SINGLE             4'b0000
`define CA53_LS_INSTR_MULTIPLE           4'b0001
`define CA53_LS_INSTR_SIGN_EXT           4'b0010
`define CA53_LS_INSTR_LDC_STC            4'b0011
`define CA53_LS_INSTR_SRS                4'b0100
`define CA53_LS_INSTR_EXCL_SGL           4'b0110
`define CA53_LS_INSTR_PLD_L1KEEP         4'b1000
`define CA53_LS_INSTR_PLD_L1STRM         4'b1001
`define CA53_LS_INSTR_PLD_L2KEEP         4'b1010
`define CA53_LS_INSTR_PLD_L2STRM         4'b1011
`define CA53_LS_INSTR_ORDERED            4'b1100
`define CA53_LS_INSTR_ORD_EXCL_SGL       4'b1101
`define CA53_LS_INSTR_NON_TEMPORAL       4'b1110
`define CA53_LS_INSTR_DCZVA              4'b1111

`define CA53_LS_ELEM_SIZE_8BIT           3'b000
`define CA53_LS_ELEM_SIZE_16BIT          3'b001
`define CA53_LS_ELEM_SIZE_32BIT          3'b010
`define CA53_LS_ELEM_SIZE_64BIT          3'b011
`define CA53_LS_ELEM_SIZE_128BIT         3'b100

//------------------------------------------
//       CP related defines
//------------------------------------------

//defines for the performance monitor event counter to make the case assignment complete.
`define CA53_PMN_SEL_OTHERS \
                                                                        8'h1A, 8'h1B, 8'h1C,        8'h1E, 8'h1F, \
  8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h26, 8'h27, 8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2E, 8'h2F, \
  8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h36, 8'h37, 8'h38, 8'h39, 8'h3A, 8'h3B, 8'h3C, 8'h3D, 8'h3E, 8'h3F, \
  8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h46, 8'h47, 8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4E, 8'h4F, \
  8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h56, 8'h57, 8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5E, 8'h5F, \
                8'h62, 8'h63, 8'h64, 8'h65, 8'h66, 8'h67, 8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6E, 8'h6F, \
  8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h76, 8'h77, 8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7E, 8'h7F, \
  8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85,               8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8E, 8'h8F, \
  8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h96, 8'h97, 8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9E, 8'h9F, \
  8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA6, 8'hA7, 8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAE, 8'hAF, \
  8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB6, 8'hB7, 8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBE, 8'hBF, \
                                                                               8'hCB, 8'hCC, 8'hCD, 8'hCE, 8'hCF, \
  8'hD0, 8'hD1, 8'hD2, 8'hD3, 8'hD4, 8'hD5, 8'hD6, 8'hD7, 8'hD8, 8'hD9, 8'hDA, 8'hDB, 8'hDC, 8'hDD, 8'hDE, 8'hDF, \
  8'hE0, 8'hE1, 8'hE2, 8'hE3, 8'hE4, 8'hE5, 8'hE6, 8'hE7, 8'hE8, 8'hE9, 8'hEA, 8'hEB, 8'hEC, 8'hED, 8'hEE, 8'hEF, \
  8'hF0, 8'hF1, 8'hF2, 8'hF3, 8'hF4, 8'hF5, 8'hF6, 8'hF7, 8'hF8, 8'hF9, 8'hFA, 8'hFB, 8'hFC, 8'hFD, 8'hFE, 8'hFF

//defines for the CP register encoding
`define CA53_CRN0_MIDR              8'b00000001
`define CA53_CRN0_CTR               8'b00000010
`define CA53_CRN0_TLBTR             8'b00000011
`define CA53_CRN0_MPIDR             8'b00000100
`define CA53_CRN0_REVIDR            8'b01101100
`define CA53_CRN0_DCZID_EL0         8'b10010100
`define CA53_CRN0_ID_PFR0           8'b00000101
`define CA53_CRN0_ID_PFR1           8'b00000110
`define CA53_CRN0_ID_DFR0           8'b00000111
`define CA53_CRN0_ID_MMFR0          8'b00001000
`define CA53_CRN0_ID_MMFR1          8'b00001001
`define CA53_CRN0_ID_MMFR2          8'b00001010
`define CA53_CRN0_ID_MMFR3          8'b00001011
`define CA53_CRN0_ID_ISAR0          8'b00001100
`define CA53_CRN0_ID_ISAR1          8'b00001101
`define CA53_CRN0_ID_ISAR2          8'b00001110
`define CA53_CRN0_ID_ISAR3          8'b00001111
`define CA53_CRN0_ID_ISAR4          8'b00010000
`define CA53_CRN0_ID_ISAR5          8'b10111010
`define CA53_CRN0_ID_CCSIDR         8'b00010001
`define CA53_CRN0_ID_CLIDR          8'b00010010
`define CA53_CRN0_CSSELR            8'b00010011
`define CA53_CRN0_VPIDR             8'b01101001
`define CA53_CRN0_VMPIDR            8'b01101010
`define CA53_CRN1_SCTLR             8'b00010100
`define CA53_CRN1_SCTLR_EL1         8'b10101001
`define CA53_CRN1_SCTLR_EL3         8'b10101000
`define CA53_CRN1_CPUACTLR          8'b00010101
`define CA53_CRN1_CPUECTLR          8'b10111011
`define CA53_CRN1_ACTLR_EL3         8'b10011000
`define CA53_CRN1_ACTLR_EL2         8'b10010110
`define CA53_CRN1_CPACR             8'b00010110
`define CA53_CRN1_SCR               8'b00010111
`define CA53_CRN1_SDER              8'b00011000
`define CA53_CRN5_FPEXC             8'b10110100
`define CA53_CRN1_NSACR             8'b00011001
`define CA53_CRN1_VCR               8'b01001100
`define CA53_CRN1_HCR               8'b01010000
`define CA53_CRN1_HCR2              8'b10101011
`define CA53_CRN1_HDCR              8'b01010001
`define CA53_CRN1_MDCR_EL3          8'b10101100
`define CA53_CRN1_HCPTR             8'b01010010
`define CA53_CRN1_CPTR_EL3          8'b10101010
`define CA53_CRN1_HSTR              8'b01010011
`define CA53_CRN1_HSCTLR            8'b01011000
`define CA53_CRN3_DACR              8'b01101000
`define CA53_CRN4_SPSEL             8'b10010000
`define CA53_CRN4_DAIF              8'b10010001
`define CA53_CRN4_CURRENTEL         8'b10010010
`define CA53_CRN4_NZCV              8'b10010011
`define CA53_CRN4_FPCR              8'b10110101
`define CA53_CRN4_FPSR              8'b10110110
`define CA53_CRN5_DFSR              8'b00011010
`define CA53_CRN5_IFSR              8'b00011011
`define CA53_CRN5_ESR_EL2           8'b01010100
`define CA53_CRN5_ESR_EL3           8'b10010101
`define CA53_CRN6_DFAR              8'b00011100
`define CA53_CRN6_IFAR              8'b00011101
`define CA53_CRN6_FAR_EL2           8'b10101101
`define CA53_CRN6_FAR_EL3           8'b10101110
`define CA53_CRN6_HDFAR             8'b01101101
`define CA53_CRN6_HIFAR             8'b01101110
`define CA53_CRN6_HPFAR             8'b01010101
`define CA53_CRN7_WFI               8'b00011110
`define CA53_CRN7_ICIMVAU           8'b01011110
`define CA53_CRN7_ISB               8'b00011111
`define CA53_CRN9_PMCR              8'b00100000
`define CA53_CRN9_PMNCNTENSET       8'b00100001
`define CA53_CRN9_PMNCNTENCLR       8'b00100010
`define CA53_CRN9_PMOVSR            8'b00100011
`define CA53_CRN9_PMOVSSET          8'b01110011
`define CA53_CRN9_PMSWINC           8'b00100100
`define CA53_CRN9_PMSELR            8'b00100101
`define CA53_CRN9_PMCCNTR           8'b00100110
`define CA53_CRN9_PMCCNTR_64        8'b01110110
`define CA53_CRN9_PMXEVTYPER        8'b00100111
`define CA53_CRN9_PMXEVCNTR         8'b00101000
`define CA53_CRN9_PMUSERENR         8'b00101001
`define CA53_CRN9_PMINTENSET        8'b00101010
`define CA53_CRN9_PMINTENCLR        8'b00101011
`define CA53_CRN14_PMEVCNTRn(n)     {5'b10000, n[2:0]}
`define CA53_CRN14_PMEVCNTR0        8'b10000000
`define CA53_CRN14_PMEVCNTR1        8'b10000001
`define CA53_CRN14_PMEVCNTR2        8'b10000010
`define CA53_CRN14_PMEVCNTR3        8'b10000011
`define CA53_CRN14_PMEVCNTR4        8'b10000100
`define CA53_CRN14_PMEVCNTR5        8'b10000101
`define CA53_CRN14_PMEVTYPERn(n)    {5'b10001, n[2:0]}
`define CA53_CRN14_PMEVTYPER0       8'b10001000
`define CA53_CRN14_PMEVTYPER1       8'b10001001
`define CA53_CRN14_PMEVTYPER2       8'b10001010
`define CA53_CRN14_PMEVTYPER3       8'b10001011
`define CA53_CRN14_PMEVTYPER4       8'b10001100
`define CA53_CRN14_PMEVTYPER5       8'b10001101
`define CA53_CRN14_PMCCFILTR        8'b01110111
`define CA53_CRN9_PMCEID0           8'b01001101
`define CA53_CRN12_VBAR             8'b00101100
`define CA53_CRN12_VBAR_EL3         8'b10011010
`define CA53_CRN12_MVBAR            8'b00101101
`define CA53_CRN12_ISR              8'b00101110
`define CA53_CRN12_VIR              8'b01001011
`define CA53_CRN12_HVBAR            8'b01010110
`define CA53_CRN13_HTPIDR           8'b01010111
`define CA53_CRN13_CID              8'b00111111
`define CA53_CRN13_TPIDRURW         8'b00101111
`define CA53_CRN13_TPIDRURO         8'b00110000
`define CA53_CRN13_TPIDRPRW         8'b00110001
`define CA53_CRN15_CSOR             8'b00110010
`define CA53_CRM2_VTTBR             8'b01101111
`define CA53_CP14_DBG_DIDR          8'b00110011
`define CA53_CP14_DBG_DRAR          8'b00110100
`define CA53_CP14_DBG_DSAR          8'b00110101
`define CA53_CP14_DBG_DSCR_INT      8'b00110110
`define CA53_CP14_DBG_DTR_INT       8'b00110111
`define CA53_CP14_DBG_DSCR_FLAGS    8'b01000000
`define CA53_CP14_DBG_WFAR          8'b01000001
`define CA53_CP14_DBG_DTRRX_EXT     8'b01000010
`define CA53_CP14_DBG_DSCR_EXT      8'b01000011
`define CA53_CP14_DBG_DTRTX_EXT     8'b01000100
`define CA53_CP14_DBG_PRCR          8'b01000101
`define CA53_CP14_DBG_OSLAR         8'b01110001
`define CA53_CP14_DBG_OSDLR         8'b01110010
`define CA53_CP14_DBG_OSLSR         8'b01001111
`define CA53_CP14_DBG_CLAIMSET      8'b01000111
`define CA53_CP14_DBG_CLAIMCLR      8'b01001000
`define CA53_CP14_DBG_AUTHSTATUS    8'b01001001
`define CA53_CP14_DBG_DEVID         8'b01001010
`define CA53_CP14_DBG_DEVID1        8'b01110100
`define CA53_CP14_MDCCINT_EL1       8'b10110010
`define CA53_CP14_DBG_MDSCR_EL1     8'b10111001
`define CA53_CP14_DBG_DTR_EL0       8'b10110011
`define CA53_CP14_DBG_OSECCR_EL1    8'b10111100
`define CA53_CP15_CBAR              8'b01001110
`define CA53_CP15_MRC_EXTERNAL      8'b01111111
`define CA53_CRN0_ID_AA64PFR0_EL1   8'b10010111
`define CA53_CRN0_ID_AA64PFR1_EL1   8'b10011001
`define CA53_CRN0_MVFR0_EL1         8'b10011011
`define CA53_CRN0_MVFR1_EL1         8'b10011100
`define CA53_CRN0_MVFR2_EL1         8'b10011101
`define CA53_CRN0_AA64PFR0_EL1      8'b10100110
`define CA53_CRN0_AA64PFR1_EL1      8'b10100111
`define CA53_CRN0_AA64DFR0_EL1      8'b10011110
`define CA53_CRN0_AA64DFR1_EL1      8'b10011111
`define CA53_CRN0_AA64AFR0_EL1      8'b10100000
`define CA53_CRN0_AA64AFR1_EL1      8'b10100001
`define CA53_CRN0_AA64ISAR0_EL1     8'b10100010
`define CA53_CRN0_AA64ISAR1_EL1     8'b10100011
`define CA53_CRN0_AA64MMFR0_EL1     8'b10100100
`define CA53_CRN0_AA64MMFR1_EL1     8'b10100101
`define CA53_CRN12_RVBAR_EL3        8'b10101111
`define CA53_CRN12_RMR_EL3          8'b10110000
`define CA53_CRN13_TPIDR_EL3        8'b10110001
`define CA53_VFP_FPSID              8'b10110111
`define CA53_VFP_FPSCR              8'b10111000
`define CA53_CP15_DBG_DSPSR_EL0     8'b10111101
`define CA53_CRN15_CPUMERRSR        8'b10111110

// CP15 encoding macro
`define CA53_DPU_CP15_DSIZE(cp_encoding) ((cp_encoding[7:2] == 6'b011001)   | \
                                        (cp_encoding[7:1] == 7'b0110001)  | \
                                        (cp_encoding      == `CA53_CRN9_PMCCNTR_64))

`define CA53_DPU_CP14_DSIZE(cp_encoding) ((cp_encoding == `CA53_CP14_DBG_DRAR) | \
                                        (cp_encoding == `CA53_CP14_DBG_DSAR))



//----------------------------------------------------------------------------
// Pipeline Control Signals
//----------------------------------------------------------------------------

`define CA53_ALU_CTL_64BIT_OP_W               1
`define CA53_ALU_CTL_64BIT_OP_BITS            0

`define CA53_ALU_FLAG_SET_W                   2
`define CA53_ALU_RD_IS_R15_W                  1

`define CA53_ALU_EX1_CTL_SHIFT_OP_BITS        2:0
`define CA53_ALU_EX1_CTL_SHIFT_RRX_FOR_0_BITS 3
`define CA53_ALU_EX1_XTRACT_TYP_W             3
`define CA53_ALU_EX1_XTRACT_TYP_BITS          6:4
`define CA53_ALU_EX1_SIGN_XTEND_W             1
`define CA53_ALU_EX1_SIGN_XTEND_BITS          7
`define CA53_ALU_EX1_XTRCT_VAL_W              1
`define CA53_ALU_EX1_XTRCT_VAL_BITS           8
`define CA53_ALU_EX1_MASK_SEL_W               3
`define CA53_ALU_EX1_MASK_SEL_BITS            11:9
`define CA53_ALU_EX1_REV_TYPE_W               3
`define CA53_ALU_EX1_REV_TYPE_BITS            14:12

`define CA53_LU_CTL_W                         4
`define CA53_ALU_AU_CARRY_LU_OPCODE_W         `CA53_LU_CTL_W

`define CA53_ALU_EX2_CTL_LU_CTL_BITS          3:0
`define CA53_ALU_EX2_CTL_OP_COMP_SHF_A_BIT    4
`define CA53_ALU_EX2_CTL_OP_COMP_SHF_B_BIT    5
`define CA53_ALU_EX2_CTL_FLAG_ID_BITS         7:6
`define CA53_ALU_EX2_CTL_CCMP_BIT             7 // Overloads flagid[1]
`define CA53_SIMD_ADDSUBX_W                   1
`define CA53_ALU_EX2_CTL_SIMD_ADD_SUB_X_BITS  8
`define CA53_ALU_EX2_VALID_SIMD_W             1
`define CA53_ALU_EX2_CTL_VALID_SIMD_BITS      9
`define CA53_ALU_EX2_SIMD_SIZE_W              1
`define CA53_ALU_EX2_CTL_SIMD_SIZE_BITS       10
`define CA53_ALU_EX2_SIMD_HALVING_W           1
`define CA53_ALU_EX2_CTL_HALVING_BITS         11
`define CA53_ALU_EX2_SIMD_SIGN_ARTH_W         1
`define CA53_ALU_EX2_SIMD_SIGN_ARTH_BITS      12
`define CA53_ALU_EX2_SEL_VALID_W              1
`define CA53_ALU_EX2_SEL_VALID_BITS           13
`define CA53_ALU_EX2_CBZ_BYPASS_W             1
`define CA53_ALU_EX2_CBZ_BYPASS_BITS          14
`define CA53_ALU_EX2_SIGN_REPLICATE_W         1
`define CA53_ALU_EX2_SIGN_REPLICATE_BITS      15

`define CA53_SIMD_SAT_VALID_W                 1
`define CA53_ALU_WR_CTL_SAT_VALID_BITS        0

// Define widths for the ALU control bus
`define CA53_ALU_GEN_CTL_W    (`CA53_ALU_CTL_64BIT_OP_W)

`define CA53_ALU_WR_CTL_W     (`CA53_SIMD_SAT_VALID_W)

`define CA53_ALU_EX2_CTL_W    (`CA53_ALU_EX2_SIGN_REPLICATE_W + `CA53_ALU_EX2_CBZ_BYPASS_W +                                          \
                               `CA53_ALU_EX2_SEL_VALID_W + `CA53_ALU_EX2_SIMD_SIGN_ARTH_W + `CA53_ALU_EX2_SIMD_HALVING_W +            \
                               `CA53_ALU_EX2_SIMD_SIZE_W + `CA53_ALU_EX2_VALID_SIMD_W + `CA53_SIMD_ADDSUBX_W + `CA53_ALU_FLAG_SET_W + \
                               `CA53_ALU_OP_COMP_W + `CA53_ALU_AU_CARRY_LU_OPCODE_W)
`define CA53_ALU_EX2_CTL_LOW  (`CA53_ALU_OP_COMP_W + `CA53_ALU_AU_CARRY_LU_OPCODE_W)
`define CA53_ALU_EX2_CTL_HIGH (`CA53_ALU_EX2_CTL_W - `CA53_ALU_EX2_CTL_LOW)

`define CA53_ALU_EX1_CTL_W    (`CA53_ALU_EX1_REV_TYPE_W + `CA53_ALU_EX1_MASK_SEL_W + `CA53_ALU_EX1_XTRCT_VAL_W + \
                               `CA53_ALU_EX1_SIGN_XTEND_W + `CA53_ALU_EX1_XTRACT_TYP_W + `CA53_SHIFT_MOD_W + `CA53_SHIFT_OP_W)

// Define the width of the overall datapath control bus
`define CA53_ALU_PIPECTL_W    (`CA53_ALU_GEN_CTL_W + `CA53_ALU_WR_CTL_W + `CA53_ALU_EX2_CTL_W + `CA53_ALU_EX1_CTL_W)

// Define how the various control busses are contained within the overall
// datapath control bus
`define CA53_ALU_PIPECTL_ALU_WR_CTL_BITS  (`CA53_ALU_PIPECTL_W-1):(`CA53_ALU_EX2_CTL_W+`CA53_ALU_EX1_CTL_W+`CA53_ALU_GEN_CTL_W)
`define CA53_ALU_PIPECTL_ALU_EX2_CTL_BITS (`CA53_ALU_EX2_CTL_W+`CA53_ALU_EX1_CTL_W+`CA53_ALU_GEN_CTL_W-1):(`CA53_ALU_EX1_CTL_W+`CA53_ALU_GEN_CTL_W)
`define CA53_ALU_PIPECTL_ALU_EX1_CTL_BITS (`CA53_ALU_EX1_CTL_W+`CA53_ALU_GEN_CTL_W-1):(`CA53_ALU_GEN_CTL_W)
`define CA53_ALU_PIPECTL_ALU_GEN_CTL_BITS (`CA53_ALU_GEN_CTL_W-1):0

// Define widths for the MAC control bus
`define CA53_MAC_ISS_CTL_W                13

`define CA53_MAC_CTL_64BIT_OP_W           1
`define CA53_MAC_CTL_64BIT_OP_BITS        (`CA53_MAC_GEN_CTL_W-1):0

`define CA53_MAC_GEN_CTL_W                (`CA53_MAC_CTL_64BIT_OP_W)

`define CA53_MAC_PIPECTL_W                (`CA53_MAC_ISS_CTL_W + `CA53_MAC_CTL_64BIT_OP_W)

`define CA53_MAC_PIPECTL_MAC_ISS_CTL_BITS (`CA53_MAC_PIPECTL_W-1):(`CA53_MAC_GEN_CTL_W)
`define CA53_MAC_PIPECTL_MAC_GEN_CTL_BITS (`CA53_MAC_GEN_CTL_W-1):0

//------------------------------------------------------------------------------
// Immediate generator control signals
//------------------------------------------------------------------------------

// ============================================
// CA53_IMM_SHIFT_W: shift value to shifter in ex1. Also used to carry cond and
//                   NZCV bits on conditional select/compare
// CA53_IMM_DATA_W : immediate data,
//                   the maximum valid bit width is 24bit(Branch instruction)
//                   the minimun valid bit width is 8bit(ARM immediate).
//
`define CA53_IMM_SHIFT_W 8
`define CA53_IMM_DATA_W 21

`define CA53_IMM_OT_W               2
`define CA53_IMM_OT_0               2'b00
`define CA53_IMM_OT_B_1             2'b01
`define CA53_IMM_OT_B_4             2'b10

`define CA53_IMM_DP_W               14
`define CA53_IMM_DP_0               14'b00000000000000
`define CA53_IMM_DP_A32_SHIFT       14'b00000000000001
`define CA53_IMM_DP_T32_SHIFT       14'b00000000000010
`define CA53_IMM_DP_ADDW            14'b00000000000100
`define CA53_IMM_DP_T32_IMM         14'b00000000001000
`define CA53_IMM_DP_MOVW            14'b00000000010000
`define CA53_IMM_DP_EXTEND          14'b00000000100000
`define CA53_IMM_DP_A32_IMM         14'b00000001000000
`define CA53_IMM_DP_BFM             14'b00000010000000
`define CA53_IMM_DP_A64_ADR         14'b00000100000000
`define CA53_IMM_DP_EXT_REG         14'b00001000000000
`define CA53_IMM_DP_LOG_IMM         14'b00010000000000
`define CA53_IMM_DP_EXTR            14'b00100000000000
`define CA53_IMM_DP_CSEL            14'b01000000000000
`define CA53_IMM_DP_CRC32           14'b10000000000000

`define CA53_IMM_LS_W               10
`define CA53_IMM_LS_0               10'b0000000000
`define CA53_IMM_LS_8               10'b0000000001
`define CA53_IMM_LS_A32_SHIFT       10'b0000000010
`define CA53_IMM_LS_SCALED          10'b0000000100
`define CA53_IMM_LS_LDP_STP         10'b0000001000
`define CA53_IMM_LS_SIGNED          10'b0000010000
`define CA53_IMM_LS_IMM4HL          10'b0000100000
`define CA53_IMM_LS_LSM1            10'b0001000000
`define CA53_IMM_LS_LSM2            10'b0010000000
`define CA53_IMM_LS_A64_LIT         10'b0100000000
`define CA53_IMM_LS_TBB             10'b1000000000

`define CA53_IMM_NEON_W             22
`define CA53_IMM_NEON_0             22'b0000000000000000000000
`define CA53_IMM_NEON_32            22'b0000000000000000000001
`define CA53_IMM_NEON_64            22'b0000000000000000000010
`define CA53_IMM_NEON_LDC_STC       22'b0000000000000000000100
`define CA53_IMM_NEON_VFP_IMM       22'b0000000000000000001000
`define CA53_IMM_NEON_VCVT_16       22'b0000000000000000010000
`define CA53_IMM_NEON_VCVT_32       22'b0000000000000000100000
`define CA53_IMM_NEON_VCVT_64       22'b0000000000000001000000
`define CA53_IMM_NEON_VEXT          22'b0000000000000010000000
`define CA53_IMM_NEON_VDUP_VCVT     22'b0000000000000100000000
`define CA53_IMM_NEON_NEON_VCVT_64  22'b0000000000001000000000
`define CA53_IMM_NEON_VSHL          22'b0000000000010000000000
`define CA53_IMM_NEON_VSHR          22'b0000000000100000000000
`define CA53_IMM_NEON_VMOV_SCAL     22'b0000000001000000000000
`define CA53_IMM_NEON_NEON_IMM      22'b0000000010000000000000
`define CA53_IMM_NEON_NEON_LSM      22'b0000000100000000000000
`define CA53_IMM_NEON_LDR_LITERAL   22'b0000001000000000000000
`define CA53_IMM_NEON_LS_PAIR       22'b0000010000000000000000
`define CA53_IMM_NEON_LS_UNSCALED   22'b0000100000000000000000
`define CA53_IMM_NEON_LS_IMM12      22'b0001000000000000000000
`define CA53_IMM_NEON_CCMP_CSEL     22'b0010000000000000000000
`define CA53_IMM_NEON_INS_VECTOR    22'b0100000000000000000000
`define CA53_IMM_NEON_VDUP_SCAL     22'b1000000000000000000000

//----------------------------------------------------------------------------
// Params for Exception logic: type and status
//----------------------------------------------------------------------------

`define CA53_FORCEOP_TYPE_W     2
`define CA53_FORCEOP_TYPE_NULL  2'b00
`define CA53_FORCEOP_TYPE_EL2   2'b01
`define CA53_FORCEOP_TYPE_SUB   2'b10
`define CA53_FORCEOP_TYPE_ADD   2'b11

`define CA53_FORCEOP_OFFSET_W   2
`define CA53_FORCEOP_OFFSET_0   2'b00
`define CA53_FORCEOP_OFFSET_2   2'b01
`define CA53_FORCEOP_OFFSET_4   2'b10
`define CA53_FORCEOP_OFFSET_8   2'b11

`define CA53_FORCEOP_OFFSET_TYPE_W    2
`define CA53_FORCEOP_OFFSET_TYPE_0_4  2'b00
`define CA53_FORCEOP_OFFSET_TYPE_2_4  2'b01
`define CA53_FORCEOP_OFFSET_TYPE_4_8  2'b10
`define CA53_FORCEOP_OFFSET_TYPE_4_0  2'b11

`define CA53_FAULT_REG_EN_W         14
`define CA53_FAULT_REG_EN_DFSR      13
`define CA53_FAULT_REG_EN_DFAR      12
`define CA53_FAULT_REG_EN_IFSR      11
`define CA53_FAULT_REG_EN_IFAR      10
`define CA53_FAULT_REG_EN_HSR        9
`define CA53_FAULT_REG_EN_HIFAR      8
`define CA53_FAULT_REG_EN_HDFAR      7
`define CA53_FAULT_REG_EN_HPFAR      6
`define CA53_FAULT_REG_EN_ESR_EL1    5
`define CA53_FAULT_REG_EN_FAR_EL1    4
`define CA53_FAULT_REG_EN_ESR_EL2    3
`define CA53_FAULT_REG_EN_FAR_EL2    2
`define CA53_FAULT_REG_EN_ESR_EL3    1
`define CA53_FAULT_REG_EN_FAR_EL3    0

`define CA53_CPSR_WR_EN_EARLY_W     2
`define CA53_CPSR_WR_EN_EARLY_NULL  2'b00
`define CA53_CPSR_WR_EN_EARLY_IM    2'b01
`define CA53_CPSR_WR_EN_EARLY_AIM   2'b10
`define CA53_CPSR_WR_EN_EARLY_AIFM  2'b11

`define CA53_SEL_CPSR_SRC_TYPE_W      1
`define CA53_SEL_CPSR_SRC_TYPE_FORCE  1'b0
`define CA53_SEL_CPSR_SRC_TYPE_DSPSR  1'b1

`define CA53_SYND_TYPE_W            3
`define CA53_SYND_TYPE_UNSPEC       3'b000
`define CA53_SYND_TYPE_DEBUG        3'b001
`define CA53_SYND_TYPE_FABORT       3'b010
`define CA53_SYND_TYPE_CALL         3'b011
`define CA53_SYND_TYPE_WFX          3'b100
`define CA53_SYND_TYPE_SYS_REG      3'b101
`define CA53_SYND_TYPE_FP_NEON      3'b110
`define CA53_SYND_TYPE_IL_BIT       3'b111

`define CA53_EXPT_TYPE_W                5
`define CA53_EXPT_TYPE_RESET            5'b00001
`define CA53_EXPT_TYPE_WPT              5'b00010
`define CA53_EXPT_TYPE_DATA             5'b00011
`define CA53_EXPT_TYPE_FIQ              5'b00100
`define CA53_EXPT_TYPE_IRQ              5'b00101
`define CA53_EXPT_TYPE_IMPRECISE        5'b00110
`define CA53_EXPT_TYPE_DEBUG_HLT        5'b00111
`define CA53_EXPT_TYPE_DEBUG_EXPT       5'b01000
`define CA53_EXPT_TYPE_INSTR_FAULT      5'b01001
`define CA53_EXPT_TYPE_TRAP             5'b01010
`define CA53_EXPT_TYPE_CALL             5'b01011
`define CA53_EXPT_TYPE_WFI              5'b01100
`define CA53_EXPT_TYPE_WFE              5'b01101
`define CA53_EXPT_TYPE_COND_TRAP        5'b01110
`define CA53_EXPT_TYPE_DEBUG_EXIT       5'b01111
`define CA53_EXPT_TYPE_SP_ALIGNMENT     5'b10000
`define CA53_EXPT_TYPE_ECC_REEXEC       5'b10001
`define CA53_EXPT_TYPE_COND_TRAP_OR_UND 5'b10010
`define CA53_EXPT_TYPE_PC_ALIGNMENT     5'b10011

// Used for both the EDSCR.STATUS field and the DBDSCR.MOE field
`define CA53_DBG_STATUS_W               4
`define CA53_DBG_STATUS_NULL            4'b0000
`define CA53_DBG_STATUS_BKPT            4'b0001
`define CA53_DBG_STATUS_BKPT_INSTR      4'b0011
`define CA53_DBG_STATUS_EXT_DBG_REQ     4'b0100
`define CA53_DBG_STATUS_VECTOR_CATCH    4'b0101
`define CA53_DBG_STATUS_HLT_STEP_NORM   4'b0110
`define CA53_DBG_STATUS_HLT_STEP_EXCL   4'b0111
`define CA53_DBG_STATUS_OS_UNLOCK       4'b1000
`define CA53_DBG_STATUS_RESET_CATCH     4'b1001
`define CA53_DBG_STATUS_WPT             4'b1010
`define CA53_DBG_STATUS_HLT             4'b1011
`define CA53_DBG_STATUS_DEBUG_REG       4'b1100
`define CA53_DBG_STATUS_EXPT_CATCH      4'b1101
`define CA53_DBG_STATUS_HLT_STEP_MISC   4'b1110

`define CA53_EXPT_INSTR_BUS_W             32
`define CA53_EXPT_INSTR_BUS_MISC_BIT      31
`define CA53_EXPT_INSTR_BUS_IS_OTHER_BIT  30
`define CA53_EXPT_INSTR_BUS_IS_LS_BIT     29
`define CA53_EXPT_INSTR_BUS_INSTR_D_BIT   28
`define CA53_EXPT_INSTR_BUS_INSTR_BITS    27:0

`define CA53_EXPT_BUS_W                 58
`define CA53_EXPT_BUS_ESR_BITS          25:0
`define CA53_EXPT_BUS_EC_BITS           31:26
`define CA53_EXPT_BUS_TARGET_MODE_BITS  36:32
`define CA53_EXPT_BUS_TARGET_EL_BITS    38:37
`define CA53_EXPT_BUS_QUASH_BIT         39
`define CA53_EXPT_BUS_CPSR_BITS         41:40
`define CA53_EXPT_BUS_VEC_OFFSET_BITS   44:42
`define CA53_EXPT_BUS_ENTER_HALT_BIT    45
`define CA53_EXPT_BUS_HIGH_PRI_BIT      46
`define CA53_EXPT_BUS_EXPT_TYPE_BITS    51:47
`define CA53_EXPT_BUS_FORCEOP_BITS      53:52
`define CA53_EXPT_BUS_DBG_STATUS_BITS   57:54

`define CA53_ETM_EXPT_TYPE_W               4
`define CA53_ETM_EXPT_TYPE_NULL            4'b0000
`define CA53_ETM_EXPT_TYPE_DATA_ABORT      4'b1100
`define CA53_ETM_EXPT_TYPE_FIQ             4'b1111
`define CA53_ETM_EXPT_TYPE_IRQ             4'b1110
`define CA53_ETM_EXPT_TYPE_IMPRECISE_ABORT 4'b0100
`define CA53_ETM_EXPT_TYPE_PREFETCH_ABORT  4'b1011
`define CA53_ETM_EXPT_TYPE_SVC             4'b1010
`define CA53_ETM_EXPT_TYPE_SMC             4'b0010
`define CA53_ETM_EXPT_TYPE_HVC             4'b0011
`define CA53_ETM_EXPT_TYPE_UNDEF           4'b1001
`define CA53_ETM_EXPT_TYPE_IBKPT           4'b1011
`define CA53_ETM_EXPT_TYPE_HALT            4'b0001
`define CA53_ETM_EXPT_TYPE_GENERIC         4'b1101
`define CA53_ETM_EXPT_TYPE_RESET           4'b1000
`define CA53_ETM_EXPT_TYPE_X               4'bxxxx

//-----------------------------------------------------------------------------
// CPSR Params
//-----------------------------------------------------------------------------
// Definitions of the bits within the stored PSR registers

`define CA53_CPSR_RET_W 29

`define CA53_CPSR_RET_N_BITS        28
`define CA53_CPSR_RET_Z_BITS        27
`define CA53_CPSR_RET_C_BITS        26
`define CA53_CPSR_RET_V_BITS        25
`define CA53_CPSR_RET_Q_BITS        24
`define CA53_CPSR_RET_NZCV_BITS     28:25
`define CA53_CPSR_RET_CV_BITS       26:25
`define CA53_CPSR_RET_NZCVQ_BITS    28:24
`define CA53_CPSR_RET_IT_LOW_BITS   23:22  // Bottom two mask bits
`define CA53_CPSR_RET_SS_BITS       21
`define CA53_CPSR_RET_IL_BITS       20
`define CA53_CPSR_RET_GE_BITS       19:16
`define CA53_CPSR_RET_IT_COND_BITS  15:12  // All four condition bits
`define CA53_CPSR_RET_IT_HIGH_BITS  11:10  // Top two mask bits
`define CA53_CPSR_RET_IT_HICM_BITS  15:10  // Condition and top two mask bits
`define CA53_CPSR_RET_DAIF_BITS     9:6
`define CA53_CPSR_RET_EAIF_BITS     9:6
`define CA53_CPSR_RET_D_BITS        9
`define CA53_CPSR_RET_E_BITS        9
`define CA53_CPSR_RET_A_BITS        8
`define CA53_CPSR_RET_I_BITS        7
`define CA53_CPSR_RET_F_BITS        6
`define CA53_CPSR_RET_T_BITS        5
`define CA53_CPSR_RET_MODE_BITS     4:0

`define CA53_CPSR_RET_T_BYTE `CA53_CPSR_RET_N_BITS:22
`define CA53_CPSR_RET_H_BYTE `CA53_CPSR_RET_SS_BITS:16
`define CA53_CPSR_RET_L_BYTE 15:`CA53_CPSR_RET_A_BITS
`define CA53_CPSR_RET_B_BYTE `CA53_CPSR_RET_I_BITS:0

`define CA53_SPSR_RET_W 29

`define CA53_SPSR_RET_N_BITS        28
`define CA53_SPSR_RET_Z_BITS        27
`define CA53_SPSR_RET_C_BITS        26
`define CA53_SPSR_RET_V_BITS        25
`define CA53_SPSR_RET_Q_BITS        24
`define CA53_SPSR_RET_NZCV_BITS     28:25
`define CA53_SPSR_RET_CVQ_BITS      26:24
`define CA53_SPSR_RET_NZCVQ_BITS    28:24
`define CA53_SPSR_RET_IT_LOW_BITS   23:22
`define CA53_SPSR_RET_SS_BITS       21
`define CA53_SPSR_RET_IL_BITS       20
`define CA53_SPSR_RET_GE_BITS       19:16
`define CA53_SPSR_RET_IT_COND_BITS  15:12
`define CA53_SPSR_RET_IT_HIGH_BITS  11:10
`define CA53_SPSR_RET_IT_HICM_BITS  15:10
`define CA53_SPSR_RET_DAIF_BITS     9:6
`define CA53_SPSR_RET_EAIF_BITS     9:6
`define CA53_SPSR_RET_D_BITS        9
`define CA53_SPSR_RET_E_BITS        9
`define CA53_SPSR_RET_A_BITS        8
`define CA53_SPSR_RET_I_BITS        7
`define CA53_SPSR_RET_F_BITS        6
`define CA53_SPSR_RET_T_BITS        5
`define CA53_SPSR_RET_AARCH_BITS    4
`define CA53_SPSR_RET_MODE_BITS     4:0

`define CA53_SPSR_RET_T_BYTE `CA53_SPSR_RET_N_BITS:22
`define CA53_SPSR_RET_H_BYTE `CA53_SPSR_RET_SS_BITS:16
`define CA53_SPSR_RET_L_BYTE 15:`CA53_SPSR_RET_A_BITS
`define CA53_SPSR_RET_B_BYTE `CA53_SPSR_RET_I_BITS:0

// Definitions of the bits within the architectural PSR registers
`define CA53_PSR_ARCH_N_BITS        31
`define CA53_PSR_ARCH_Z_BITS        30
`define CA53_PSR_ARCH_C_BITS        29
`define CA53_PSR_ARCH_V_BITS        28
`define CA53_PSR_ARCH_Q_BITS        27
`define CA53_PSR_ARCH_NZ_BITS       31:30
`define CA53_PSR_ARCH_NZCV_BITS     31:28
`define CA53_PSR_ARCH_NZCVQ_BITS    31:27
`define CA53_PSR_ARCH_IT_LOW_BITS   26:25
`define CA53_PSR_ARCH_J_BITS        24
`define CA53_PSR_ARCH_SS_BITS       21
`define CA53_PSR_ARCH_IL_BITS       20
`define CA53_PSR_ARCH_GE_BITS       19:16
`define CA53_PSR_ARCH_IT_COND_BITS  15:12
`define CA53_PSR_ARCH_IT_HIGH_BITS  11:10
`define CA53_PSR_ARCH_IT_HICM_BITS  15:10
`define CA53_PSR_ARCH_DAIF_BITS     9:6
`define CA53_PSR_ARCH_EAIF_BITS     9:6
`define CA53_PSR_ARCH_D_BITS        9
`define CA53_PSR_ARCH_E_BITS        9
`define CA53_PSR_ARCH_A_BITS        8
`define CA53_PSR_ARCH_I_BITS        7
`define CA53_PSR_ARCH_F_BITS        6
`define CA53_PSR_ARCH_T_BITS        5
`define CA53_PSR_ARCH_MODE_BITS     4:0

// Definitions for the CPSR control signals
// Separate definitions for each section of the CPSR, because they do not all
// need all the possible values (thus the widths of the signals can be
// reduced compared to using the same defines for all)
`define CA53_SEL_CPSR_SRC_W            4
`define CA53_SEL_CPSR_SRC_CPSR         4'b0000
`define CA53_SEL_CPSR_SRC_FORCE        4'b0001
`define CA53_SEL_CPSR_SRC_DP           4'b0010
`define CA53_SEL_CPSR_SRC_MUL          4'b0011
`define CA53_SEL_CPSR_SRC_LOAD_DATA    4'b0100
`define CA53_SEL_CPSR_SRC_SPSR         4'b0101
`define CA53_SEL_CPSR_SRC_CCFLAGS      4'b0110
`define CA53_SEL_CPSR_SRC_DSCR         4'b0111
`define CA53_SEL_CPSR_SRC_QFLAG        4'b1000
`define CA53_SEL_CPSR_SRC_DSPSR        4'b1001
`define CA53_SEL_CPSR_SRC_RFE          4'b1010
`define CA53_SEL_CPSR_SRC_BLX          4'b1011
`define CA53_SEL_CPSR_SRC_CPS          4'b1100
`define CA53_SEL_CPSR_SRC_INSTR1       4'b1111

`define CA53_SEL_CPSR_EN_W             6
`define CA53_SEL_CPSR_EN_NULL          6'b00_0000
`define CA53_SEL_CPSR_EN_IT            6'b00_0001
`define CA53_SEL_CPSR_EN_T             6'b00_0010
`define CA53_SEL_CPSR_EN_E             6'b00_0011
`define CA53_SEL_CPSR_EN_M0            6'b00_0100
`define CA53_SEL_CPSR_EN_ETIM          6'b00_0101
`define CA53_SEL_CPSR_EN_ETAIM         6'b00_0110
`define CA53_SEL_CPSR_EN_ETAIFM        6'b00_0111
`define CA53_SEL_CPSR_EN_GE            6'b00_1000
`define CA53_SEL_CPSR_EN_Q             6'b00_1010
`define CA53_SEL_CPSR_EN_CC            6'b00_1011
`define CA53_SEL_CPSR_EN_SPSR          6'b00_1100

`define CA53_SEL_MRS_CPSR_RET          1'b0
`define CA53_SEL_MRS_SPSR_RET          1'b1

// - Slot 1 flag setting control signal
`define CA53_FLAGEN_INSTR1_W           2
`define CA53_FLAGEN_INSTR1_NONE        2'b00
`define CA53_FLAGEN_INSTR1_CC          2'b01
`define CA53_FLAGEN_INSTR1_GE          2'b10
`define CA53_FLAGEN_INSTR1_Q           2'b11

//---------------------------------------------------------------------
//  SIMD specific defines
//---------------------------------------------------------------------
`define CA53_SIMD_SIGNED_SAT_ARITH    3'b001
`define CA53_SIMD_SIGNED_ARITH        3'b000
`define CA53_SIMD_SIGNED_HALF_ARITH   3'b010
`define CA53_SIMD_UNSIGNED_ARITH      3'b100
`define CA53_SIMD_UNSIGNED_HALF_ARITH 3'b110
`define CA53_SIMD_UNSIGNED_SAT_ARITH  3'b101
`define CA53_SIMD_X                   3'b000, 3'b100
`define CA53_SIMD_SIZE_16              1'b1
`define CA53_SIMD_SIZE_8               1'b0

`define CA53_MEDIA_SIGNED_SAT_ARITH    3'b010
`define CA53_MEDIA_SIGNED_ARITH        3'b001
`define CA53_MEDIA_SIGNED_HALF_ARITH   3'b011
`define CA53_MEDIA_UNSIGNED_ARITH      3'b101
`define CA53_MEDIA_UNSIGNED_HALF_ARITH 3'b111
`define CA53_MEDIA_UNSIGNED_SAT_ARITH  3'b110
`define CA53_MEDIA_X                   3'b000, 3'b100

`define CA53_EXTRACT_LS_BYTE     3'b011
`define CA53_EXTRACT_LS_HWORD    3'b001
`define CA53_EXTRACT_TWO_BYTES   3'b010
`define CA53_EXTRACT_SH_BYTE     3'b100
`define CA53_EXTRACT_SH_HWORD    3'b101
`define CA53_EXTRACT_SH_WORD     3'b110
`define CA53_EXTRACT_SH_XWORD    3'b111

//---------------------------------------------------------------------
// Sat defines
//---------------------------------------------------------------------
`define CA53_SAT_POS_32_VALUE 64'h0000_0000_7fff_ffff
`define CA53_SAT_NEG_32_VALUE 64'h0000_0000_8000_0000
`define CA53_SAT_POS_64_VALUE 64'h7fff_ffff_ffff_ffff
`define CA53_SAT_NEG_64_VALUE 64'h8000_0000_0000_0000

//---------------------------------------------------------------------
// FPU defines
//---------------------------------------------------------------------

`define CA53_FP_RF_RD_ADDR_W  6
`define CA53_FP_RF_WR_ADDR_W  6
`define CA53_FP_RF_ADDR_L_W  64

// FPU Register Bank Doulble Precision Register Identifiers used by the read port
`define CA53_FPU_ADDR_D00 5'b0_0000
`define CA53_FPU_ADDR_D01 5'b0_0001
`define CA53_FPU_ADDR_D02 5'b0_0010
`define CA53_FPU_ADDR_D03 5'b0_0011
`define CA53_FPU_ADDR_D04 5'b0_0100
`define CA53_FPU_ADDR_D05 5'b0_0101
`define CA53_FPU_ADDR_D06 5'b0_0110
`define CA53_FPU_ADDR_D07 5'b0_0111
`define CA53_FPU_ADDR_D08 5'b0_1000
`define CA53_FPU_ADDR_D09 5'b0_1001
`define CA53_FPU_ADDR_D10 5'b0_1010
`define CA53_FPU_ADDR_D11 5'b0_1011
`define CA53_FPU_ADDR_D12 5'b0_1100
`define CA53_FPU_ADDR_D13 5'b0_1101
`define CA53_FPU_ADDR_D14 5'b0_1110
`define CA53_FPU_ADDR_D15 5'b0_1111
`define CA53_FPU_ADDR_D16 5'b1_0000
`define CA53_FPU_ADDR_D17 5'b1_0001
`define CA53_FPU_ADDR_D18 5'b1_0010
`define CA53_FPU_ADDR_D19 5'b1_0011
`define CA53_FPU_ADDR_D20 5'b1_0100
`define CA53_FPU_ADDR_D21 5'b1_0101
`define CA53_FPU_ADDR_D22 5'b1_0110
`define CA53_FPU_ADDR_D23 5'b1_0111
`define CA53_FPU_ADDR_D24 5'b1_1000
`define CA53_FPU_ADDR_D25 5'b1_1001
`define CA53_FPU_ADDR_D26 5'b1_1010
`define CA53_FPU_ADDR_D27 5'b1_1011
`define CA53_FPU_ADDR_D28 5'b1_1100
`define CA53_FPU_ADDR_D29 5'b1_1101
`define CA53_FPU_ADDR_D30 5'b1_1110
`define CA53_FPU_ADDR_D31 5'b1_1111

// FPU Register Bank Single Precision Register Identifiers used by the write port
`define CA53_FPU_ADDR_S00 5'b0_0000
`define CA53_FPU_ADDR_S01 5'b0_0001
`define CA53_FPU_ADDR_S02 5'b0_0010
`define CA53_FPU_ADDR_S03 5'b0_0011
`define CA53_FPU_ADDR_S04 5'b0_0100
`define CA53_FPU_ADDR_S05 5'b0_0101
`define CA53_FPU_ADDR_S06 5'b0_0110
`define CA53_FPU_ADDR_S07 5'b0_0111
`define CA53_FPU_ADDR_S08 5'b0_1000
`define CA53_FPU_ADDR_S09 5'b0_1001
`define CA53_FPU_ADDR_S10 5'b0_1010
`define CA53_FPU_ADDR_S11 5'b0_1011
`define CA53_FPU_ADDR_S12 5'b0_1100
`define CA53_FPU_ADDR_S13 5'b0_1101
`define CA53_FPU_ADDR_S14 5'b0_1110
`define CA53_FPU_ADDR_S15 5'b0_1111
`define CA53_FPU_ADDR_S16 5'b1_0000
`define CA53_FPU_ADDR_S17 5'b1_0001
`define CA53_FPU_ADDR_S18 5'b1_0010
`define CA53_FPU_ADDR_S19 5'b1_0011
`define CA53_FPU_ADDR_S20 5'b1_0100
`define CA53_FPU_ADDR_S21 5'b1_0101
`define CA53_FPU_ADDR_S22 5'b1_0110
`define CA53_FPU_ADDR_S23 5'b1_0111
`define CA53_FPU_ADDR_S24 5'b1_1000
`define CA53_FPU_ADDR_S25 5'b1_1001
`define CA53_FPU_ADDR_S26 5'b1_1010
`define CA53_FPU_ADDR_S27 5'b1_1011
`define CA53_FPU_ADDR_S28 5'b1_1100
`define CA53_FPU_ADDR_S29 5'b1_1101
`define CA53_FPU_ADDR_S30 5'b1_1110
`define CA53_FPU_ADDR_S31 5'b1_1111

// FPU Register Bank Single Precision Register Identifiers used by the write port
`define CA53_NEON_ADDR_S00 6'b00_0000
`define CA53_NEON_ADDR_S01 6'b00_0001
`define CA53_NEON_ADDR_S02 6'b00_0010
`define CA53_NEON_ADDR_S03 6'b00_0011
`define CA53_NEON_ADDR_S04 6'b00_0100
`define CA53_NEON_ADDR_S05 6'b00_0101
`define CA53_NEON_ADDR_S06 6'b00_0110
`define CA53_NEON_ADDR_S07 6'b00_0111
`define CA53_NEON_ADDR_S08 6'b00_1000
`define CA53_NEON_ADDR_S09 6'b00_1001
`define CA53_NEON_ADDR_S10 6'b00_1010
`define CA53_NEON_ADDR_S11 6'b00_1011
`define CA53_NEON_ADDR_S12 6'b00_1100
`define CA53_NEON_ADDR_S13 6'b00_1101
`define CA53_NEON_ADDR_S14 6'b00_1110
`define CA53_NEON_ADDR_S15 6'b00_1111
`define CA53_NEON_ADDR_S16 6'b01_0000
`define CA53_NEON_ADDR_S17 6'b01_0001
`define CA53_NEON_ADDR_S18 6'b01_0010
`define CA53_NEON_ADDR_S19 6'b01_0011
`define CA53_NEON_ADDR_S20 6'b01_0100
`define CA53_NEON_ADDR_S21 6'b01_0101
`define CA53_NEON_ADDR_S22 6'b01_0110
`define CA53_NEON_ADDR_S23 6'b01_0111
`define CA53_NEON_ADDR_S24 6'b01_1000
`define CA53_NEON_ADDR_S25 6'b01_1001
`define CA53_NEON_ADDR_S26 6'b01_1010
`define CA53_NEON_ADDR_S27 6'b01_1011
`define CA53_NEON_ADDR_S28 6'b01_1100
`define CA53_NEON_ADDR_S29 6'b01_1101
`define CA53_NEON_ADDR_S30 6'b01_1110
`define CA53_NEON_ADDR_S31 6'b01_1111
`define CA53_NEON_ADDR_S32 6'b10_0000
`define CA53_NEON_ADDR_S33 6'b10_0001
`define CA53_NEON_ADDR_S34 6'b10_0010
`define CA53_NEON_ADDR_S35 6'b10_0011
`define CA53_NEON_ADDR_S36 6'b10_0100
`define CA53_NEON_ADDR_S37 6'b10_0101
`define CA53_NEON_ADDR_S38 6'b10_0110
`define CA53_NEON_ADDR_S39 6'b10_0111
`define CA53_NEON_ADDR_S40 6'b10_1000
`define CA53_NEON_ADDR_S41 6'b10_1001
`define CA53_NEON_ADDR_S42 6'b10_1010
`define CA53_NEON_ADDR_S43 6'b10_1011
`define CA53_NEON_ADDR_S44 6'b10_1100
`define CA53_NEON_ADDR_S45 6'b10_1101
`define CA53_NEON_ADDR_S46 6'b10_1110
`define CA53_NEON_ADDR_S47 6'b10_1111
`define CA53_NEON_ADDR_S48 6'b11_0000
`define CA53_NEON_ADDR_S49 6'b11_0001
`define CA53_NEON_ADDR_S50 6'b11_0010
`define CA53_NEON_ADDR_S51 6'b11_0011
`define CA53_NEON_ADDR_S52 6'b11_0100
`define CA53_NEON_ADDR_S53 6'b11_0101
`define CA53_NEON_ADDR_S54 6'b11_0110
`define CA53_NEON_ADDR_S55 6'b11_0111
`define CA53_NEON_ADDR_S56 6'b11_1000
`define CA53_NEON_ADDR_S57 6'b11_1001
`define CA53_NEON_ADDR_S58 6'b11_1010
`define CA53_NEON_ADDR_S59 6'b11_1011
`define CA53_NEON_ADDR_S60 6'b11_1100
`define CA53_NEON_ADDR_S61 6'b11_1101
`define CA53_NEON_ADDR_S62 6'b11_1110
`define CA53_NEON_ADDR_S63 6'b11_1111

// FPU read mux defines
`define CA53_SEL_FML_A_W 1
`define CA53_SEL_FML_A_ZERO 1'b0
`define CA53_SEL_FML_A_FR0  1'b1

`define CA53_SEL_FML_B_W 1
`define CA53_SEL_FML_B_ZERO 1'b0
`define CA53_SEL_FML_B_FR1  1'b1

`define CA53_SEL_FML_C_W 1
`define CA53_SEL_FML_C_ZERO 1'b0
`define CA53_SEL_FML_C_FR2  1'b1

`define CA53_SEL_FAD_A_W 3
`define CA53_SEL_FAD_A_ZERO  3'b000
`define CA53_SEL_FAD_A_FR2   3'b001
`define CA53_SEL_FAD_A_TWO   3'b010
`define CA53_SEL_FAD_A_THREE 3'b011
`define CA53_SEL_FAD_A_TRN32 3'b100

`define CA53_SEL_FAD_B_W 3
`define CA53_SEL_FAD_B_ZERO  3'b000
`define CA53_SEL_FAD_B_FR1   3'b001
`define CA53_SEL_FAD_B_IMM   3'b010
`define CA53_SEL_FAD_B_FML_Q 3'b011
`define CA53_SEL_FAD_B_TRN32 3'b100
`define CA53_SEL_FAD_B_STR   3'b110

`define CA53_SEL_FAD_C_W 2
`define CA53_SEL_FAD_C_ZERO  2'b00
`define CA53_SEL_FAD_C_FR0   2'b01
`define CA53_SEL_FAD_C_IMM   2'b10

// FPU forwarding mux defines
`define CA53_FWD_FNULL       3'b000
`define CA53_FWD_ZERO        3'b001
`define CA53_FWD_FW0_F3      3'b010
`define CA53_FWD_FW1_F3      3'b011
`define CA53_FWD_FW0_F4      3'b100
`define CA53_FWD_FW1_F4      3'b101
`define CA53_FWD_FW0_F5      3'b110
`define CA53_FWD_FW1_F5      3'b111

// FP operand unpack types
`define CA53_FP_FORMAT_F32   3'b000
`define CA53_FP_FORMAT_F64   3'b001
`define CA53_FP_FORMAT_F16_B 3'b010
`define CA53_FP_FORMAT_F16_T 3'b011
`define CA53_FP_FORMAT_S16   3'b110
`define CA53_FP_FORMAT_U16   3'b111
`define CA53_FP_FORMAT_S32   3'b100
`define CA53_FP_FORMAT_U32   3'b101

// Floating point system register defines
`define CA53_FPEXC_W 1
`define CA53_FPEXC_EN_BITS  0

`define CA53_FPEXC_ST_EN_BITS  13

`define CA53_FPSCR_ARCH_NZCV_BITS    31:28
`define CA53_FPSCR_ARCH_QC_BITS      27
`define CA53_FPSCR_ARCH_AHP_BITS     26
`define CA53_FPSCR_ARCH_DN_BITS      25
`define CA53_FPSCR_ARCH_FZ_BITS      24
`define CA53_FPSCR_ARCH_RMODE_BITS   23:22
`define CA53_FPSCR_ARCH_STRIDE_BITS  21:20
`define CA53_FPSCR_ARCH_LEN_BITS     18:16
`define CA53_FPSCR_ARCH_IDC_BITS     7
`define CA53_FPSCR_ARCH_IXC_BITS     4
`define CA53_FPSCR_ARCH_UFC_BITS     3
`define CA53_FPSCR_ARCH_OFC_BITS     2
`define CA53_FPSCR_ARCH_DZC_BITS     1
`define CA53_FPSCR_ARCH_IOC_BITS     0

`define CA53_FPEXC_ARCH_EN_BITS  30

`define CA53_FPSCR_W               16
`define CA53_FPSCR_FP_BITS         14:0
`define CA53_FPSCR_QC_BITS         15    // Put on end to make configurability easier
`define CA53_FPSCR_NZCV_BITS       14:11
`define CA53_FPSCR_AHP_BITS        10
`define CA53_FPSCR_DN_BITS         9
`define CA53_FPSCR_FZ_BITS         8
`define CA53_FPSCR_RMODE_BITS      7:6
`define CA53_FPSCR_CONFIG_BITS     10:6
`define CA53_FPSCR_FP_XFLAGS_BITS  5:0

`define CA53_FPSCR_IDC_BITS 5
`define CA53_FPSCR_IXC_BITS 4
`define CA53_FPSCR_UFC_BITS 3
`define CA53_FPSCR_OFC_BITS 2
`define CA53_FPSCR_DZC_BITS 1
`define CA53_FPSCR_IOC_BITS 0

`define CA53_XFLAGS_W        7
`define CA53_XFLAGS_QC_BITS  6
`define CA53_XFLAGS_IDC_BITS `CA53_FPSCR_IDC_BITS
`define CA53_XFLAGS_IXC_BITS `CA53_FPSCR_IXC_BITS
`define CA53_XFLAGS_UFC_BITS `CA53_FPSCR_UFC_BITS
`define CA53_XFLAGS_OFC_BITS `CA53_FPSCR_OFC_BITS
`define CA53_XFLAGS_DZC_BITS `CA53_FPSCR_DZC_BITS
`define CA53_XFLAGS_IOC_BITS `CA53_FPSCR_IOC_BITS

`define CA53_XFLAGS_FP_BITS  `CA53_FPSCR_FP_XFLAGS_BITS

`define CA53_FP_CFLAG_SRC_W 1
`define CA53_FP_CFLAG_SRC_FPSCR   2'b0
`define CA53_FP_CFLAG_SRC_ALU     2'b1

`define CA53_FP_XFLAG_SRC_W 2
`define CA53_FP_XFLAG_SRC_FPSCR   2'b00
`define CA53_FP_XFLAG_SRC_MUL     2'b01
`define CA53_FP_XFLAG_SRC_ALU     2'b10

`define CA53_FP_RMODE_W           3
`define CA53_FP_RMODE_0           3'b000
`define CA53_FP_RMODE_RN          3'b000 // Round to nearest, ties even
`define CA53_FP_RMODE_RP          3'b001 // Round to +infinity
`define CA53_FP_RMODE_RM          3'b010 // Round to -infinity
`define CA53_FP_RMODE_RZ          3'b011 // Round to zero
`define CA53_FP_RMODE_RA          3'b100 // Round to nearest, ties away
`define CA53_FP_RMODE_RX          3'b101 // "Narrowable" rounding for D->H conversion
`define CA53_FP_RMODE_NEON        3'b110 // RN in AArch32, FPCR in AArch64
`define CA53_FP_RMODE_FPCR        3'b111

`define CA53_FP_OP_W              5
`define CA53_FP_OP_0              5'b00000
`define CA53_FP_OP_ADD            5'b00001
`define CA53_FP_OP_SUB            5'b00010
`define CA53_FP_OP_ABD            5'b00011
`define CA53_FP_OP_CMP            5'b00100
`define CA53_FP_OP_CMPE           5'b00101
`define CA53_FP_OP_ACMPE          5'b00110
`define CA53_FP_OP_MOV            5'b00111
`define CA53_FP_OP_ABS            5'b01000
`define CA53_FP_OP_NEG            5'b01001
`define CA53_FP_OP_RINT           5'b01010
`define CA53_FP_OP_RINTX          5'b01011
`define CA53_FP_OP_MAX            5'b01100
`define CA53_FP_OP_MAXNM          5'b01101
`define CA53_FP_OP_MIN            5'b01110
`define CA53_FP_OP_MINNM          5'b01111
`define CA53_FP_OP_F2H_B          5'b10000
`define CA53_FP_OP_F2H_T          5'b10001
`define CA53_FP_OP_H2F_B          5'b10010
`define CA53_FP_OP_H2F_T          5'b10011
`define CA53_FP_OP_I2S            5'b10100
`define CA53_FP_OP_I2D            5'b10101
`define CA53_FP_OP_S2I            5'b10110
`define CA53_FP_OP_D2I            5'b10111
`define CA53_FP_OP_D2FP           5'b11111
`define CA53_FP_OP_S2D            5'b11000
`define CA53_FP_OP_D2S            5'b11001
`define CA53_FP_OP_RSB            5'b11010
`define CA53_FP_OP_HADD           5'b11011
`define CA53_FP_OP_RECPX          5'b11100

`define CA53_NEON_FCTN_W          5
`define CA53_NEON_FCTN_0          5'b00000
`define CA53_NEON_FCTN_FP         5'b00000
`define CA53_NEON_FCTN_PERM       5'b00001
`define CA53_NEON_FCTN_ADDSUBHN   5'b00010
`define CA53_NEON_FCTN_TBL_TBX    5'b00011
`define CA53_NEON_FCTN_TBX_FINAL  5'b00100
`define CA53_NEON_FCTN_SWAP_MAX   5'b00101
`define CA53_NEON_FCTN_CMP        5'b00110
`define CA53_NEON_FCTN_SHIFT      5'b00111
`define CA53_NEON_FCTN_NONE       5'b01000
`define CA53_NEON_FCTN_CLS        5'b01001
`define CA53_NEON_FCTN_CNT        5'b01010
`define CA53_NEON_FCTN_ACCUM      5'b01011
`define CA53_NEON_FCTN_PERM_FB    5'b01100
`define CA53_NEON_FCTN_RND_SHIFT  5'b01101
`define CA53_NEON_FCTN_INS_SHIFT  5'b01110
`define CA53_NEON_FCTN_SHA256SU0  5'b01111
`define CA53_NEON_FCTN_RBIT       5'b10000
`define CA53_NEON_FCTN_SHA1H      5'b10001
`define CA53_NEON_FCTN_SHA1SU0    5'b10010
`define CA53_NEON_FCTN_ADDV       5'b10011
`define CA53_NEON_FCTN_MAXV       5'b10100
`define CA53_NEON_FCTN_MINV       5'b10101

`define CA53_NEON_MUX_SEL_W       3
`define CA53_NEON_MUX_SEL_0       3'b000
`define CA53_NEON_MUX_SEL_AU      3'b001
`define CA53_NEON_MUX_SEL_LU      3'b010
`define CA53_NEON_MUX_SEL_CLZ     3'b011
`define CA53_NEON_MUX_SEL_PMUL    3'b100
`define CA53_NEON_MUX_SEL_MAXMIN  3'b101
`define CA53_NEON_MUX_SEL_FMAXMIN 3'b110

`define CA53_CRYPTO_OP_W            4
`define CA53_CRYPTO_OP_0            4'b0000
`define CA53_CRYPTO_OP_AESD         4'b0001
`define CA53_CRYPTO_OP_AESE         4'b0010
`define CA53_CRYPTO_OP_AESMC        4'b0011
`define CA53_CRYPTO_OP_AESIMC       4'b0100
`define CA53_CRYPTO_OP_AESD_AESIMC  4'b0101
`define CA53_CRYPTO_OP_AESE_AESMC   4'b0110
`define CA53_CRYPTO_OP_PMULL64      4'b0111
`define CA53_CRYPTO_OP_SHA1C        4'b1000
`define CA53_CRYPTO_OP_SHA1P        4'b1001
`define CA53_CRYPTO_OP_SHA1M        4'b1010
`define CA53_CRYPTO_OP_SHA1SU1      4'b1011
`define CA53_CRYPTO_OP_SHA256H      4'b1100
`define CA53_CRYPTO_OP_SHA256H2     4'b1101
`define CA53_CRYPTO_OP_SHA256SU1    4'b1110

//----------------------------------------------------------------------------
// FPU Pipeline Control Signals
//----------------------------------------------------------------------------

`define CA53_FP_EX_PIPE_ADD0                   0
`define CA53_FP_EX_PIPE_ADD1                   1
`define CA53_FP_EX_PIPE_MUL0                   2
`define CA53_FP_EX_PIPE_MUL1                   3

`define CA53_FP_EX_PIPE_W                      4

`define CA53_FP_ADD_VECTOR_FP_OP_W             1
`define CA53_FP_ADD_VECTOR_FP_OP_BITS          0
`define CA53_FP_ADD_FP_OP_W                    `CA53_FP_OP_W
`define CA53_FP_ADD_FP_OP_BITS                 5:1

`define CA53_FP_NEON_ADD_NEON_INT_SEL_W        1
`define CA53_FP_NEON_ADD_NEON_INT_SEL_BITS     6
`define CA53_FP_NEON_ADD_NEON_MUX_SEL_W        `CA53_NEON_MUX_SEL_W
`define CA53_FP_NEON_ADD_NEON_MUX_SEL_BITS     9:7
`define CA53_FP_NEON_ADD_LU_CTL_W              4
`define CA53_FP_NEON_ADD_LU_CTL_BITS           13:10
`define CA53_FP_NEON_ADD_SIZE_SEL_W            2
`define CA53_FP_NEON_ADD_SIZE_SEL_BITS         15:14
`define CA53_FP_NEON_ADD_PERM_SEL_W            4
`define CA53_FP_NEON_ADD_PERM_SEL_BITS         19:16
`define CA53_FP_NEON_ADD_VTB_CYCLE_W           1
`define CA53_FP_NEON_ADD_VTB_CYCLE_BITS        20
`define CA53_FP_NEON_ADD_UNSIGNED_OP_W         1
`define CA53_FP_NEON_ADD_UNSIGNED_OP_BITS      21
`define CA53_FP_NEON_ADD_FCTN_SEL_W            `CA53_NEON_FCTN_W
`define CA53_FP_NEON_ADD_FCTN_SEL_BITS         26:22
`define CA53_FP_NEON_ADD_WIDTH_OP_SEL_W        3
`define CA53_FP_NEON_ADD_WIDTH_OP_SEL_BITS     29:27
`define CA53_FP_NEON_ADD_SAT_OP_SEL_W          3
`define CA53_FP_NEON_ADD_SAT_OP_SEL_BITS       32:30
`define CA53_FP_NEON_ADD_VTST_OP_SEL_W         1
`define CA53_FP_NEON_ADD_VTST_OP_SEL_BITS      33
`define CA53_FP_NEON_ADD_MASK_SEL_W            1
`define CA53_FP_NEON_ADD_MASK_SEL_BITS         34

`define CA53_FP_MUL_NEG_SQRT_W                 1
`define CA53_FP_MUL_NEG_SQRT_BITS              0
`define CA53_FP_MUL_DIVIDE_W                   1
`define CA53_FP_MUL_DIVIDE_BITS                1
`define CA53_FP_MUL_PRECISION_W                1
`define CA53_FP_MUL_PRECISION_BITS             2
`define CA53_FP_MUL_FUSED_MAC_W                1
`define CA53_FP_MUL_FUSED_MAC_BITS             3

`define CA53_FP_MUL_NEON_VECTOR_OP_W           1
`define CA53_FP_MUL_NEON_VECTOR_OP_BITS        4
`define CA53_FP_MUL_NEON_INT_OP_W              1
`define CA53_FP_MUL_NEON_INT_OP_BITS           5
`define CA53_FP_MUL_NEON_FIXUP_W               1
`define CA53_FP_MUL_NEON_FIXUP_BITS            6
`define CA53_FP_MUL_NEON_SAT_DBL_W             1
`define CA53_FP_MUL_NEON_SAT_DBL_BITS          7
`define CA53_FP_MUL_NEON_ROUND_W               1
`define CA53_FP_MUL_NEON_ROUND_BITS            8
`define CA53_FP_MUL_NEON_TYPE_W                3
`define CA53_FP_MUL_NEON_TYPE_BITS             11:9
`define CA53_FP_MUL_NEON_OUT_FMT_W             3
`define CA53_FP_MUL_NEON_OUT_FMT_BITS          14:12
`define CA53_FP_MUL_NEON_INV_IS_ZERO_W         1
`define CA53_FP_MUL_NEON_INV_IS_ZERO_BITS      15

`define CA53_NEON_VLD_PERM_EN_W                1
`define CA53_NEON_VLD_PERM_EN_BITS             0
`define CA53_NEON_VLD_DUP_W                    1
`define CA53_NEON_VLD_DUP_BITS                 1
`define CA53_NEON_VLD_PERM_SELECT_LO_W         2
`define CA53_NEON_VLD_PERM_SELECT_LO_BITS      3:2
`define CA53_NEON_VLD_PERM_SELECT_HI_W         2
`define CA53_NEON_VLD_PERM_SELECT_HI_BITS      5:4

// Define widths for the datapath control busses
`define CA53_FP_NEON_ADD_CTL_W (`CA53_FP_NEON_ADD_NEON_INT_SEL_W + `CA53_FP_NEON_ADD_NEON_MUX_SEL_W + `CA53_FP_NEON_ADD_LU_CTL_W       + \
                              `CA53_FP_NEON_ADD_SIZE_SEL_W     + `CA53_FP_NEON_ADD_PERM_SEL_W     + `CA53_FP_NEON_ADD_VTB_CYCLE_W    + \
                              `CA53_FP_NEON_ADD_UNSIGNED_OP_W  + `CA53_FP_NEON_ADD_FCTN_SEL_W     + `CA53_FP_NEON_ADD_WIDTH_OP_SEL_W + \
                              `CA53_FP_NEON_ADD_SAT_OP_SEL_W   + `CA53_FP_NEON_ADD_VTST_OP_SEL_W  + `CA53_FP_NEON_ADD_MASK_SEL_W)

`define CA53_FP_ADD_CTL_W  (`CA53_FP_NEON_ADD_CTL_W + `CA53_FP_ADD_VECTOR_FP_OP_W + `CA53_FP_ADD_FP_OP_W)

`define CA53_FP_NEON_MUL_CTL_W (`CA53_FP_MUL_NEON_INV_IS_ZERO_W + `CA53_FP_MUL_NEON_OUT_FMT_W + `CA53_FP_MUL_NEON_TYPE_W  + \
                              `CA53_FP_MUL_NEON_ROUND_W       + `CA53_FP_MUL_NEON_SAT_DBL_W + `CA53_FP_MUL_NEON_FIXUP_W + \
                              `CA53_FP_MUL_NEON_INT_OP_W      + `CA53_FP_MUL_NEON_VECTOR_OP_W)
`define CA53_FP_MUL_CTL_W  (`CA53_FP_NEON_MUL_CTL_W + `CA53_FP_MUL_FUSED_MAC_W + `CA53_FP_MUL_PRECISION_W + `CA53_FP_MUL_DIVIDE_W + `CA53_FP_MUL_NEG_SQRT_W)

`define CA53_NEON_VLD_CTL_W (`CA53_NEON_VLD_PERM_SELECT_HI_W + `CA53_NEON_VLD_PERM_SELECT_LO_W + `CA53_NEON_VLD_DUP_W + `CA53_NEON_VLD_PERM_EN_W)

`define CA53_FP_PIPECTL_RMODE_W                `CA53_FP_RMODE_W
`define CA53_FP_PIPECTL_RMODE_BITS             (`CA53_FP_MUL_CTL_W + `CA53_FP_ADD_CTL_W + `CA53_FP_PIPECTL_RMODE_W - 1):(`CA53_FP_MUL_CTL_W + `CA53_FP_ADD_CTL_W)
`define CA53_FP_PIPECTL_FORCE_DN_FZ_W          1
`define CA53_FP_PIPECTL_FORCE_DN_FZ_BITS       (`CA53_FP_MUL_CTL_W + `CA53_FP_ADD_CTL_W + `CA53_FP_PIPECTL_RMODE_W)

// Define the width of the overall FP datapath control bus
`define CA53_FP_PIPECTL_TOP_W (`CA53_FP_PIPECTL_FORCE_DN_FZ_W + `CA53_FP_PIPECTL_RMODE_W + \
                              `CA53_FP_MUL_CTL_W)
`define CA53_FP_PIPECTL_W     (`CA53_FP_PIPECTL_TOP_W + `CA53_FP_ADD_CTL_W)

// Define how the various control busses are contained within the overall
// datapath control bus
`define CA53_FP_PIPECTL_TOP_BITS     (`CA53_FP_PIPECTL_W-1):(`CA53_FP_ADD_CTL_W)
`define CA53_FP_PIPECTL_MUL_CTL_BITS (`CA53_FP_MUL_CTL_W+`CA53_FP_ADD_CTL_W-1):(`CA53_FP_ADD_CTL_W)
`define CA53_FP_PIPECTL_ADD_CTL_BITS (`CA53_FP_ADD_CTL_W-1):0

//----------------------------------------------------------------------------
// Neon defines
//----------------------------------------------------------------------------

`define CA53_NEON_LD_PERM_8_0        4'b0000
`define CA53_NEON_LD_PERM_8_1        4'b0001
`define CA53_NEON_LD_PERM_8_2        4'b0010
`define CA53_NEON_LD_PERM_8_3        4'b0011

`define CA53_NEON_LD_PERM_16_0       4'b0100
`define CA53_NEON_LD_PERM_16_1       4'b0101
`define CA53_NEON_LD_PERM_16_2       4'b0110
`define CA53_NEON_LD_PERM_16_3       4'b0111

`define CA53_NEON_LD_PERM_32_0       4'b1000
`define CA53_NEON_LD_PERM_32_1       4'b1001
`define CA53_NEON_LD_PERM_32_2       4'b1010
`define CA53_NEON_LD_PERM_32_3       4'b1011

`define CA53_NEON_LD_PERM_64         4'b1100

`define CA53_NEON_MUL_TYPE_I8        3'b000
`define CA53_NEON_MUL_TYPE_I16       3'b010
`define CA53_NEON_MUL_TYPE_I16_LO    3'b100
`define CA53_NEON_MUL_TYPE_I16_HI    3'b101
`define CA53_NEON_MUL_TYPE_I32       3'b011
`define CA53_NEON_MUL_TYPE_I32_LO    3'b110

`define CA53_NEON_MUL_OUT_FMT_64     3'b000
`define CA53_NEON_MUL_OUT_FMT_32_L   3'b001
`define CA53_NEON_MUL_OUT_FMT_32_H   3'b010
`define CA53_NEON_MUL_OUT_FMT_4_8    3'b011
`define CA53_NEON_MUL_OUT_FMT_4_16   3'b100
`define CA53_NEON_MUL_OUT_FMT_2_32   3'b101
`define CA53_NEON_MUL_OUT_FMT_2_16_H 3'b110
`define CA53_NEON_MUL_OUT_FMT_VREC   3'b111


//----------------------------------------------------------------------------
// Neon LU defines
//----------------------------------------------------------------------------

`define CA53_NEON_SAT_NONE           3'b000
`define CA53_NEON_SAT_ADD            3'b001
`define CA53_NEON_SAT_SHF_SIGNED     3'b010
`define CA53_NEON_SAT_SHF_UNSIGNED   3'b011
`define CA53_NEON_SAT_SUQADD         3'b100
`define CA53_NEON_SAT_USQADD         3'b101
`define CA53_NEON_SAT_MAXV           3'b110
`define CA53_NEON_SAT_MINV           3'b111

`define CA53_NEON_LU_AND   4'b0001
`define CA53_NEON_LU_BIC   4'b0010
`define CA53_NEON_LU_BIF   4'b0011
`define CA53_NEON_LU_BIT   4'b0100
`define CA53_NEON_LU_BSL   4'b0101
`define CA53_NEON_LU_EOR   4'b0110
`define CA53_NEON_LU_MOV   4'b0111
`define CA53_NEON_LU_MVN   4'b1000
`define CA53_NEON_LU_ORN   4'b1001
`define CA53_NEON_LU_ORR   4'b1010
`define CA53_NEON_LU_VCGT  4'b1100
`define CA53_NEON_LU_VCEQ  4'b1101

//----------------------------------------------------------------------------
// Undefines
//----------------------------------------------------------------------------
`else

/*ARMAUTO_UNDEF*/
`undef CA53_RP_RD_3_0
`undef CA53_RP_RD_11_8
`undef CA53_RP_RD_15_12
`undef CA53_RP_RD_19_16
`undef CA53_RP_RD_STM
`undef CA53_RP_RD_MCR
`undef CA53_RP_RD_ERET
`undef CA53_RP0_RD_2_0
`undef CA53_RP0_RD_R13
`undef CA53_RP2_RD_R14
`undef CA53_RP2_RD_RMOD
`undef CA53_RD_CTL_EN
`undef CA53_RD_CTL_PC
`undef CA53_RD_CTL_ZR
`undef CA53_RD_CTL_STM
`undef CA53_WR_CTL_EN
`undef CA53_WR_CTL_19_16
`undef CA53_WR_CTL_15_12
`undef CA53_WR_CTL_11_8
`undef CA53_WR_CTL_3_0
`undef CA53_WR_CTL_LDM
`undef CA53_WR_CTL_ART
`undef CA53_WR_CTL_R30
`undef CA53_WR_CTL_RMOD
`undef CA53_WR_CTL_R13
`undef CA53_WR_CTL_R14
`undef CA53_WR_CTL_R15
`undef CA53_WR_CTL_ZR
`undef CA53_R11_8_TOP
`undef ca53dpu_sel_0x
`undef ca53dpu_sel_1x
`undef ca53dpu_sel_0x0
`undef ca53dpu_sel_0x1
`undef ca53dpu_sel_0xx
`undef ca53dpu_sel_00x
`undef ca53dpu_sel_10x
`undef ca53dpu_sel_1x0
`undef ca53dpu_sel_1x1
`undef ca53dpu_sel_11x
`undef ca53dpu_sel_000
`undef ca53dpu_sel_001
`undef ca53dpu_sel_01x
`undef ca53dpu_sel_1xx
`undef ca53dpu_sel_100
`undef ca53dpu_sel_x10
`undef ca53dpu_sel_xx1
`undef ca53dpu_sel_1n00
`undef ca53dpu_sel_1xxx
`undef ca53dpu_sel_01xx
`undef ca53dpu_sel_001x
`undef ca53dpu_sel_0xxx
`undef ca53dpu_sel_00xx
`undef ca53dpu_sel_xx00
`undef ca53dpu_sel_000x
`undef ca53dpu_sel_010x
`undef ca53dpu_sel_10xx
`undef ca53dpu_sel_100x
`undef ca53dpu_sel_101x
`undef ca53dpu_sel_1000
`undef ca53dpu_sel_x100
`undef ca53dpu_sel_xx10
`undef ca53dpu_sel_xx11
`undef ca53dpu_sel_xx01
`undef ca53dpu_sel_xxx1
`undef ca53dpu_sel_0x00
`undef ca53dpu_sel_0x01
`undef ca53dpu_sel_0x1x
`undef ca53dpu_sel_10x0
`undef ca53dpu_sel_10x1
`undef ca53dpu_sel_11xx
`undef ca53dpu_sel_000xx
`undef ca53dpu_sel_001xx
`undef ca53dpu_sel_100xx
`undef ca53dpu_sel_101xx
`undef ca53dpu_sel_x000x
`undef ca53dpu_sel_x001x
`undef ca53dpu_sel_x010x
`undef ca53dpu_sel_x011x
`undef ca53dpu_sel_x100x
`undef ca53dpu_sel_x101x
`undef ca53dpu_sel_x1100
`undef ca53dpu_sel_x1101
`undef ca53dpu_sel_x1110
`undef ca53dpu_sel_x1111
`undef ca53dpu_sel_00xxx
`undef ca53dpu_sel_1xxxx
`undef ca53dpu_sel_01xxx
`undef ca53dpu_sel_0001x
`undef ca53dpu_sel_1x_xxxx__p0
`undef ca53dpu_sel_1x_xxxx__p1
`undef ca53dpu_sel_1x_xxxx__p2
`undef ca53dpu_sel_1x_xxxx__p3
`undef ca53dpu_sel_1x_xxxx__p4
`undef ca53dpu_sel_1x_xxxx__p5
`undef ca53dpu_sel_1x_xxxx
`undef ca53dpu_sel_01_xxxx_p0
`undef ca53dpu_sel_01_xxxx_p1
`undef ca53dpu_sel_01_xxxx_p2
`undef ca53dpu_sel_01_xxxx
`undef ca53dpu_sel_00_1xxx
`undef ca53dpu_sel_00_01xx
`undef ca53dpu_sel_00_001x
`undef ca53dpu_sel_1xx_xxxx_p0
`undef ca53dpu_sel_1xx_xxxx_p1
`undef ca53dpu_sel_1xx_xxxx_p2
`undef ca53dpu_sel_1xx_xxxx_p3
`undef ca53dpu_sel_1xx_xxxx_p4
`undef ca53dpu_sel_1xx_xxxx_p5
`undef ca53dpu_sel_1xx_xxxx_p6
`undef ca53dpu_sel_1xx_xxxx_p7
`undef ca53dpu_sel_1xx_xxxx_p8
`undef ca53dpu_sel_1xx_xxxx_p9
`undef ca53dpu_sel_1xx_xxxx_p10
`undef ca53dpu_sel_1xx_xxxx
`undef ca53dpu_sel_01x_xxxx_p0
`undef ca53dpu_sel_01x_xxxx_p1
`undef ca53dpu_sel_01x_xxxx_p2
`undef ca53dpu_sel_01x_xxxx_p3
`undef ca53dpu_sel_01x_xxxx_p4
`undef ca53dpu_sel_01x_xxxx_p5
`undef ca53dpu_sel_01x_xxxx
`undef ca53dpu_sel_001_xxxx_p0
`undef ca53dpu_sel_001_xxxx_p1
`undef ca53dpu_sel_001_xxxx_p2
`undef ca53dpu_sel_001_xxxx
`undef ca53dpu_sel_000_1xxx
`undef ca53dpu_sel_000_01xx
`undef ca53dpu_sel_000_001x
`undef ca53dpu_sel_0000_01xx
`undef ca53dpu_sel_0000_001x
`undef ca53dpu_sel_0000_1xx0
`undef ca53dpu_sel_0000_1xx1
`undef ca53dpu_sel_0000_1xxx
`undef ca53dpu_sel_0001_00xx
`undef ca53dpu_sel_0001_01xx
`undef ca53dpu_sel_0001_10xx
`undef ca53dpu_sel_0001_11xx
`undef ca53dpu_sel_0010_00xx
`undef ca53dpu_sel_0010_01xx
`undef ca53dpu_sel_0010_10xx
`undef ca53dpu_sel_0010_11xx
`undef ca53dpu_sel_0011_00xx
`undef ca53dpu_sel_0011_01xx
`undef ca53dpu_sel_0011_10xx
`undef ca53dpu_sel_0011_11xx
`undef ca53dpu_sel_0100_00xx
`undef ca53dpu_sel_0100_01xx
`undef ca53dpu_sel_0100_10xx
`undef ca53dpu_sel_0100_11xx
`undef ca53dpu_sel_0101_00xx
`undef ca53dpu_sel_0101_01xx
`undef ca53dpu_sel_0101_10xx
`undef ca53dpu_sel_0101_11xx
`undef ca53dpu_sel_0110_00xx
`undef ca53dpu_sel_0110_01xx
`undef ca53dpu_sel_0110_10xx
`undef ca53dpu_sel_0110_11xx
`undef ca53dpu_sel_0111_00xx
`undef ca53dpu_sel_0111_01xx
`undef ca53dpu_sel_0111_10xx
`undef ca53dpu_sel_0111_11xx
`undef ca53dpu_sel_1000_00xx
`undef ca53dpu_sel_1000_01xx
`undef ca53dpu_sel_1000_10xx
`undef ca53dpu_sel_1000_11xx
`undef ca53dpu_sel_1001_00xx
`undef ca53dpu_sel_1001_01xx
`undef ca53dpu_sel_1001_10xx
`undef ca53dpu_sel_1001_11xx
`undef ca53dpu_sel_1010_00xx
`undef ca53dpu_sel_1010_01xx
`undef ca53dpu_sel_1010_10xx
`undef ca53dpu_sel_1010_11xx
`undef ca53dpu_sel_1011_00xx
`undef ca53dpu_sel_1011_01xx
`undef ca53dpu_sel_1011_10xx
`undef ca53dpu_sel_1011_11xx
`undef ca53dpu_sel_1100_00xx
`undef ca53dpu_sel_1100_01xx
`undef ca53dpu_sel_1100_10xx
`undef ca53dpu_sel_1100_11xx
`undef ca53dpu_sel_1101_00xx
`undef ca53dpu_sel_1101_01xx
`undef ca53dpu_sel_1101_10xx
`undef ca53dpu_sel_1101_11xx
`undef ca53dpu_sel_1110_00xx
`undef ca53dpu_sel_1110_01xx
`undef ca53dpu_sel_1110_10xx
`undef ca53dpu_sel_1110_11xx
`undef ca53dpu_sel_1111_00xx
`undef ca53dpu_sel_1111_01xx
`undef ca53dpu_sel_1111_10xx
`undef ca53dpu_sel_1111_11xx
`undef ca53dpu_sel_0001_xxxx
`undef ca53dpu_sel_0010_xxxx
`undef ca53dpu_sel_0011_xxxx
`undef ca53dpu_sel_0100_xxxx
`undef ca53dpu_sel_0101_xxxx
`undef ca53dpu_sel_0110_xxxx
`undef ca53dpu_sel_0111_xxxx
`undef ca53dpu_sel_1000_xxxx
`undef ca53dpu_sel_1001_xxxx
`undef ca53dpu_sel_1010_xxxx
`undef ca53dpu_sel_1011_xxxx
`undef ca53dpu_sel_1100_xxxx
`undef ca53dpu_sel_1101_xxxx
`undef ca53dpu_sel_1110_xxxx
`undef ca53dpu_sel_1111_xxxx
`undef ca53dpu_sel_1xxx_xxxx
`undef ca53dpu_sel_01xx_xxxx
`undef ca53dpu_sel_001x_xxxx
`undef CA53_VADDR_R00
`undef CA53_VADDR_R01
`undef CA53_VADDR_R02
`undef CA53_VADDR_R03
`undef CA53_VADDR_R04
`undef CA53_VADDR_R05
`undef CA53_VADDR_R06
`undef CA53_VADDR_R07
`undef CA53_VADDR_R08
`undef CA53_VADDR_R09
`undef CA53_VADDR_R10
`undef CA53_VADDR_R11
`undef CA53_VADDR_R12
`undef CA53_VADDR_R13
`undef CA53_VADDR_R14
`undef CA53_VADDR_R15
`undef CA53_VADDR_R16
`undef CA53_VADDR_R17
`undef CA53_VADDR_R18
`undef CA53_VADDR_R19
`undef CA53_VADDR_R20
`undef CA53_VADDR_R21
`undef CA53_VADDR_R22
`undef CA53_VADDR_R23
`undef CA53_VADDR_R24
`undef CA53_VADDR_R25
`undef CA53_VADDR_R26
`undef CA53_VADDR_R27
`undef CA53_VADDR_R28
`undef CA53_VADDR_R29
`undef CA53_VADDR_R30
`undef CA53_VADDR_R31
`undef CA53_ADDR_X0
`undef CA53_ADDR_X1
`undef CA53_ADDR_X2
`undef CA53_ADDR_X3
`undef CA53_ADDR_X4
`undef CA53_ADDR_X5
`undef CA53_ADDR_X6
`undef CA53_ADDR_X7
`undef CA53_ADDR_X8
`undef CA53_ADDR_X9
`undef CA53_ADDR_X10
`undef CA53_ADDR_X11
`undef CA53_ADDR_X12
`undef CA53_ADDR_X13
`undef CA53_ADDR_X14
`undef CA53_ADDR_X15
`undef CA53_ADDR_X16
`undef CA53_ADDR_X17
`undef CA53_ADDR_X18
`undef CA53_ADDR_X19
`undef CA53_ADDR_X20
`undef CA53_ADDR_X21
`undef CA53_ADDR_X22
`undef CA53_ADDR_X23
`undef CA53_ADDR_X24
`undef CA53_ADDR_X25
`undef CA53_ADDR_X26
`undef CA53_ADDR_X27
`undef CA53_ADDR_X28
`undef CA53_ADDR_X29
`undef CA53_ADDR_X30
`undef CA53_ADDR_SP_EL0
`undef CA53_ADDR_SP_EL1
`undef CA53_ADDR_SP_EL2
`undef CA53_ADDR_SP_EL3
`undef CA53_ADDR_ELR_EL1
`undef CA53_ADDR_ELR_EL2
`undef CA53_ADDR_ELR_EL3
`undef CA53_ADDR_R00
`undef CA53_ADDR_R01
`undef CA53_ADDR_R02
`undef CA53_ADDR_R03
`undef CA53_ADDR_R04
`undef CA53_ADDR_R05
`undef CA53_ADDR_R06
`undef CA53_ADDR_R07
`undef CA53_ADDR_R08
`undef CA53_ADDR_R09
`undef CA53_ADDR_R10
`undef CA53_ADDR_R11
`undef CA53_ADDR_R12
`undef CA53_ADDR_R13
`undef CA53_ADDR_R14
`undef CA53_ADDR_R13_HYP
`undef CA53_ADDR_R14_IRQ
`undef CA53_ADDR_R13_IRQ
`undef CA53_ADDR_R14_SVC
`undef CA53_ADDR_R13_SVC
`undef CA53_ADDR_R14_ABT
`undef CA53_ADDR_R13_ABT
`undef CA53_ADDR_R14_UND
`undef CA53_ADDR_R13_UND
`undef CA53_ADDR_R08_FIQ
`undef CA53_ADDR_R09_FIQ
`undef CA53_ADDR_R10_FIQ
`undef CA53_ADDR_R11_FIQ
`undef CA53_ADDR_R12_FIQ
`undef CA53_ADDR_R13_FIQ
`undef CA53_ADDR_R14_FIQ
`undef CA53_ADDR_ELR_HYP
`undef CA53_ADDR_R14_MON
`undef CA53_ADDR_R13_MON
`undef CA53_LONG_RF_ADDR_W
`undef CA53_ADDR_BIT_X0
`undef CA53_ADDR_BIT_X1
`undef CA53_ADDR_BIT_X2
`undef CA53_ADDR_BIT_X3
`undef CA53_ADDR_BIT_X4
`undef CA53_ADDR_BIT_X5
`undef CA53_ADDR_BIT_X6
`undef CA53_ADDR_BIT_X7
`undef CA53_ADDR_BIT_X8
`undef CA53_ADDR_BIT_X9
`undef CA53_ADDR_BIT_X10
`undef CA53_ADDR_BIT_X11
`undef CA53_ADDR_BIT_X12
`undef CA53_ADDR_BIT_X13
`undef CA53_ADDR_BIT_X14
`undef CA53_ADDR_BIT_X15
`undef CA53_ADDR_BIT_X16
`undef CA53_ADDR_BIT_X17
`undef CA53_ADDR_BIT_X18
`undef CA53_ADDR_BIT_X19
`undef CA53_ADDR_BIT_X20
`undef CA53_ADDR_BIT_X21
`undef CA53_ADDR_BIT_X22
`undef CA53_ADDR_BIT_X23
`undef CA53_ADDR_BIT_X24
`undef CA53_ADDR_BIT_X25
`undef CA53_ADDR_BIT_X26
`undef CA53_ADDR_BIT_X27
`undef CA53_ADDR_BIT_X28
`undef CA53_ADDR_BIT_X29
`undef CA53_ADDR_BIT_X30
`undef CA53_ADDR_BIT_SP_EL0
`undef CA53_ADDR_BIT_SP_EL1
`undef CA53_ADDR_BIT_SP_EL2
`undef CA53_ADDR_BIT_SP_EL3
`undef CA53_ADDR_BIT_ELR_EL1
`undef CA53_ADDR_BIT_ELR_EL2
`undef CA53_ADDR_BIT_ELR_EL3
`undef CA53_ADDR_BIT_R00
`undef CA53_ADDR_BIT_R01
`undef CA53_ADDR_BIT_R02
`undef CA53_ADDR_BIT_R03
`undef CA53_ADDR_BIT_R04
`undef CA53_ADDR_BIT_R05
`undef CA53_ADDR_BIT_R06
`undef CA53_ADDR_BIT_R07
`undef CA53_ADDR_BIT_R08
`undef CA53_ADDR_BIT_R09
`undef CA53_ADDR_BIT_R10
`undef CA53_ADDR_BIT_R11
`undef CA53_ADDR_BIT_R12
`undef CA53_ADDR_BIT_R13
`undef CA53_ADDR_BIT_R14
`undef CA53_ADDR_BIT_R13_HYP
`undef CA53_ADDR_BIT_R14_IRQ
`undef CA53_ADDR_BIT_R13_IRQ
`undef CA53_ADDR_BIT_R14_SVC
`undef CA53_ADDR_BIT_R13_SVC
`undef CA53_ADDR_BIT_R14_ABT
`undef CA53_ADDR_BIT_R13_ABT
`undef CA53_ADDR_BIT_R14_UND
`undef CA53_ADDR_BIT_R13_UND
`undef CA53_ADDR_BIT_R08_FIQ
`undef CA53_ADDR_BIT_R09_FIQ
`undef CA53_ADDR_BIT_R10_FIQ
`undef CA53_ADDR_BIT_R11_FIQ
`undef CA53_ADDR_BIT_R12_FIQ
`undef CA53_ADDR_BIT_R13_FIQ
`undef CA53_ADDR_BIT_R14_FIQ
`undef CA53_ADDR_BIT_R13_MON
`undef CA53_ADDR_BIT_R14_MON
`undef CA53_ADDR_BIT_ELR_HYP
`undef CA53_SPSR_CRNT
`undef CA53_SPSR_FIQ
`undef CA53_SPSR_IRQ
`undef CA53_SPSR_SVC
`undef CA53_SPSR_ABT
`undef CA53_SPSR_UND
`undef CA53_SPSR_MON
`undef CA53_SPSR_HYP
`undef CA53_EX_PIPE_W
`undef CA53_EX_PIPE_NULL
`undef CA53_EX_PIPE_ALU
`undef CA53_EX_PIPE_BR
`undef CA53_EX_PIPE_DCU
`undef CA53_EX_PIPE_DIV
`undef CA53_EX_PIPE_STR
`undef CA53_EX_PIPE_ALU_BIT
`undef CA53_EX_PIPE_MAC_BIT
`undef CA53_EX_PIPE_BR_BIT
`undef CA53_EX_PIPE_DCU_BIT
`undef CA53_EX_PIPE_DIV_BIT
`undef CA53_EX_PIPE_STR_BIT
`undef CA53_EXPT_INSTR_TYPE_W
`undef CA53_EXPT_INSTR_TYPE_NULL
`undef CA53_EXPT_INSTR_TYPE_UNDEF
`undef CA53_EXPT_INSTR_TYPE_PD_UNDEF
`undef CA53_EXPT_INSTR_TYPE_FABORT
`undef CA53_EXPT_INSTR_TYPE_SVC
`undef CA53_EXPT_INSTR_TYPE_HVC
`undef CA53_EXPT_INSTR_TYPE_SMC
`undef CA53_EXPT_INSTR_TYPE_WFI
`undef CA53_EXPT_INSTR_TYPE_WFE
`undef CA53_EXPT_INSTR_TYPE_BKPT
`undef CA53_EXPT_INSTR_TYPE_HW_BKPT
`undef CA53_EXPT_INSTR_TYPE_MON_ACCESS
`undef CA53_EXPT_INSTR_TYPE_VIRTUAL_MEM_CTL
`undef CA53_EXPT_INSTR_TYPE_DCZVA
`undef CA53_EXPT_INSTR_TYPE_TLB
`undef CA53_EXPT_INSTR_TYPE_CACHE_POU
`undef CA53_EXPT_INSTR_TYPE_DCACHE_POC
`undef CA53_EXPT_INSTR_TYPE_DCACHE_SETWAY
`undef CA53_EXPT_INSTR_TYPE_ACTLR
`undef CA53_EXPT_INSTR_TYPE_ID_GROUP0
`undef CA53_EXPT_INSTR_TYPE_ID_GROUP1
`undef CA53_EXPT_INSTR_TYPE_ID_GROUP2
`undef CA53_EXPT_INSTR_TYPE_ID_GROUP3
`undef CA53_EXPT_INSTR_TYPE_CPACR
`undef CA53_EXPT_INSTR_TYPE_CNTPS
`undef CA53_EXPT_INSTR_TYPE_FP
`undef CA53_EXPT_INSTR_TYPE_FP_ID
`undef CA53_EXPT_INSTR_TYPE_FP_ID0
`undef CA53_EXPT_INSTR_TYPE_FP_ID3
`undef CA53_EXPT_INSTR_TYPE_NEON
`undef CA53_EXPT_INSTR_TYPE_CRYPTO
`undef CA53_EXPT_INSTR_TYPE_DBG_ROM
`undef CA53_EXPT_INSTR_TYPE_DBG_OS
`undef CA53_EXPT_INSTR_TYPE_DBG_ACCESS
`undef CA53_EXPT_INSTR_TYPE_DBG_SHARED
`undef CA53_EXPT_INSTR_TYPE_DBG_DTR
`undef CA53_EXPT_INSTR_TYPE_PMU_PMCR
`undef CA53_EXPT_INSTR_TYPE_PMU_REG
`undef CA53_EXPT_INSTR_TYPE_CNTPCT
`undef CA53_EXPT_INSTR_TYPE_CNTP
`undef CA53_EXPT_INSTR_TYPE_CNTV
`undef CA53_EXPT_INSTR_TYPE_CNTVCT
`undef CA53_EXPT_INSTR_TYPE_CNTFRQ
`undef CA53_EXPT_INSTR_TYPE_MCR_MRC_MISC
`undef CA53_EXPT_INSTR_TYPE_CPUACTLR
`undef CA53_EXPT_INSTR_TYPE_CPUECTLR
`undef CA53_EXPT_INSTR_TYPE_HLT
`undef CA53_EXPT_INSTR_TYPE_VECT_CATCH
`undef CA53_EXPT_INSTR_TYPE_DCPS1
`undef CA53_EXPT_INSTR_TYPE_DCPS2
`undef CA53_EXPT_INSTR_TYPE_DCPS3
`undef CA53_EXPT_INSTR_TYPE_L2CTLR
`undef CA53_EXPT_INSTR_TYPE_L2ECTLR
`undef CA53_EXPT_INSTR_TYPE_L2ACTLR
`undef CA53_EXPT_INSTR_TYPE_PMU_SWINC
`undef CA53_EXPT_INSTR_TYPE_PMU_EVREG
`undef CA53_EXPT_INSTR_TYPE_PMU_CCNT_RD
`undef CA53_EXPT_INSTR_TYPE_PMU_USERENR
`undef CA53_EXPT_INSTR_TYPE_DAIF
`undef CA53_EXPT_INSTR_TYPE_CP15BAR
`undef CA53_EXPT_INSTR_TYPE_SETEND
`undef CA53_EXPT_INSTR_TYPE_RESET_CATCH
`undef CA53_EXPT_INSTR_TYPE_EXPT_CATCH
`undef CA53_EXPT_INSTR_TYPE_IFU_PARITY
`undef CA53_EXPT_INSTR_TYPE_GIC_GROUP0
`undef CA53_EXPT_INSTR_TYPE_GIC_GROUP1
`undef CA53_EXPT_INSTR_TYPE_GIC_COMMON
`undef CA53_EXPT_INSTR_TYPE_GIC_SRE
`undef CA53_EXPT_INSTR_TYPE_GIC_SGI
`undef CA53_EXPT_INSTR_TYPE_GIC_MISC
`undef CA53_EXPT_INSTR_TYPE_MON_MCR_MRC
`undef CA53_EXPT_INSTR_TYPE_EX1_W
`undef CA53_EXPT_INSTR_TYPE_EX1_WFE
`undef CA53_EXPT_INSTR_TYPE_EX1_FP
`undef CA53_EXPT_INSTR_TYPE_EX1_NEON
`undef CA53_EXPT_INSTR_TYPE_EX1_SVC
`undef CA53_EXPT_INSTR_TYPE_EX1_HVC
`undef CA53_EXPT_INSTR_TYPE_EX1_SMC
`undef CA53_EXPT_INSTR_TYPE_EX1_HW_BKPT
`undef CA53_EXPT_INSTR_TYPE_EX1_BKPT
`undef CA53_EXPT_INSTR_TYPE_EX1_VECT_CATCH
`undef CA53_INSTR_TYPE_W
`undef CA53_INSTR_TYPE_NULL
`undef CA53_INSTR_TYPE_SYNC_EXPT
`undef CA53_INSTR_TYPE_WFI
`undef CA53_INSTR_TYPE_WFE
`undef CA53_INSTR_TYPE_SEV
`undef CA53_INSTR_TYPE_ISB
`undef CA53_INSTR_TYPE_SEVL
`undef CA53_SLOT1_INSTR_TYPE_W
`undef CA53_SLOT1_INSTR_TYPE_NULL
`undef CA53_SLOT1_INSTR_TYPE_LS
`undef CA53_SLOT1_INSTR_TYPE_FP
`undef CA53_SLOT1_INSTR_TYPE_FP_LS
`undef CA53_SLOT1_INSTR_TYPE_MUL
`undef CA53_SLOT1_INSTR_TYPE_BRANCH
`undef CA53_SLOT1_INSTR_TYPE_BX
`undef CA53_SLOT1_INSTR_TYPE_BLX
`undef CA53_LU_CTL_ADD
`undef CA53_LU_CTL_SUB
`undef CA53_LU_CTL_ADC
`undef CA53_LU_CTL_SBC
`undef CA53_LU_CTL_BIC
`undef CA53_LU_CTL_EOR
`undef CA53_LU_CTL_AND
`undef CA53_LU_CTL_EON
`undef CA53_LU_CTL_ORR
`undef CA53_LU_CTL_ORN
`undef CA53_LU_CTL_CSEL
`undef CA53_LU_CTL_CRC32
`undef CA53_LU_CTL_CLZ
`undef CA53_LU_CTL_GEN_SAT
`undef CA53_LU_CTL_EXTRACT
`undef CA53_LU_CTL_MASKSEL
`undef CA53_LU_CTL_MOVB
`undef CA53_ALU_LU_MASK_SEL
`undef CA53_MULT_TYPE_W
`undef CA53_MULT_TYPE_ACCONLY
`undef CA53_MULT_TYPE_USAD
`undef CA53_MULT_TYPE_16x16
`undef CA53_MULT_TYPE_32x32
`undef CA53_MULT_TYPE_2x16x16
`undef CA53_MULT_TYPE_32x16
`undef CA53_MULT_TYPE_64x64
`undef CA53_MULT_TYPE_64x64_LH
`undef CA53_MULT_TYPE_64x64_HL
`undef CA53_MULT_TYPE_64x64_HH
`undef CA53_SEL_SHF_A_W
`undef CA53_SEL_SHF_B_W
`undef CA53_SEL_SHF_C_W
`undef CA53_SEL_SHF_A_ZERO
`undef CA53_SEL_SHF_A_R0
`undef CA53_SEL_SHF_A_PC
`undef CA53_SEL_SHF_A_R3
`undef CA53_SEL_SHF_B_ZERO
`undef CA53_SEL_SHF_B_R1
`undef CA53_SEL_SHF_B_PC
`undef CA53_SEL_SHF_B_IMM_DATA
`undef CA53_SEL_SHF_B_R4
`undef CA53_SEL_SHF_C_ZERO
`undef CA53_SEL_SHF_C_R2
`undef CA53_SEL_SHF_C_IMM_SHIFT
`undef CA53_SEL_MSK_B_W
`undef CA53_SEL_MSK_B_IMM_DATA
`undef CA53_MASK_W
`undef CA53_MASK_ZERO
`undef CA53_MASK_COMB
`undef CA53_MASK_SNGL
`undef CA53_MASK_TOP
`undef CA53_MASK_BOT
`undef CA53_MASK_MOVW
`undef CA53_MASK_C
`undef CA53_REV_MUX_W
`undef CA53_REV_MUX_NORMAL
`undef CA53_REV_MUX_REV
`undef CA53_REV_MUX_REVSH
`undef CA53_REV_MUX_REV16
`undef CA53_REV_MUX_RBIT
`undef CA53_REV_MUX_SAT_DBL
`undef CA53_REV_MUX_ZERO
`undef CA53_SEL_MAC_A_W
`undef CA53_SEL_MAC_A_ZERO
`undef CA53_SEL_MAC_A_R0
`undef CA53_SEL_MAC_A_R3
`undef CA53_SEL_MAC_B_W
`undef CA53_SEL_MAC_B_ZERO
`undef CA53_SEL_MAC_B_R1
`undef CA53_SEL_MAC_B_R4
`undef CA53_SEL_DIV_A_W
`undef CA53_SEL_DIV_A_ZERO
`undef CA53_SEL_DIV_A_R0
`undef CA53_SEL_DIV_A_R3
`undef CA53_SEL_DIV_B_W
`undef CA53_SEL_DIV_B_ZERO
`undef CA53_SEL_DIV_B_R1
`undef CA53_SEL_DIV_B_R4
`undef CA53_SEL_STR_A_ZERO
`undef CA53_SEL_STR_A_R2
`undef CA53_SEL_STR_A_PC
`undef CA53_SEL_STR_A_FR0
`undef CA53_SEL_STR_A_R1
`undef CA53_SEL_STR_A_FR1
`undef CA53_SEL_STR_A_R4
`undef CA53_SEL_STR_A_W
`undef CA53_SEL_STR_B_ZERO
`undef CA53_SEL_STR_B_R3
`undef CA53_SEL_STR_B_PC
`undef CA53_SEL_STR_B_FR1
`undef CA53_SEL_STR_B_A_H
`undef CA53_SEL_STR_B_STR1
`undef CA53_SEL_STR_B_R2
`undef CA53_SEL_STR_B_W
`undef CA53_ALU_OP_COMP_NULL
`undef CA53_ALU_OP_COMP_SHF_B
`undef CA53_ALU_OP_COMP_W
`undef CA53_NULL
`undef CA53_STR0_FP_SEL_NONE
`undef CA53_STR0_FP_SEL_FR0
`undef CA53_STR0_FP_SEL_FR0_FR1
`undef CA53_STR0_FP_SEL_FR4
`undef CA53_STR1_FP_SEL_NONE
`undef CA53_STR1_FP_SEL_FR3
`undef CA53_STR1_FP_SEL_FR3_FR4
`undef CA53_STR1_FP_SEL_FR1
`undef CA53_SHIFT_OP_NOP
`undef CA53_SHIFT_OP_EXTR
`undef CA53_SHIFT_OP_SP1
`undef CA53_SHIFT_OP_SP2
`undef CA53_SHIFT_OP_ASR
`undef CA53_SHIFT_OP_LSL
`undef CA53_SHIFT_OP_LSR
`undef CA53_SHIFT_OP_ROR
`undef CA53_SHIFT_OP_W
`undef CA53_SHIFT_MOD_W
`undef CA53_BR_PIPECTL_W
`undef CA53_BR_NO_BRANCH
`undef CA53_BR_DIRECT
`undef CA53_BR_PREFETCH_FLUSH
`undef CA53_BR_WFX_RESTART
`undef CA53_BR_INDIRECT_TBB
`undef CA53_BR_INDIRECT_DP
`undef CA53_BR_INDIRECT_ST
`undef CA53_BR_INDIRECT_LD
`undef CA53_STANDARD_BRANCH
`undef CA53_ILLEGAL_BX_IMM
`undef CA53_BRANCH_AND_LINK
`undef CA53_BRANCH_AND_LINK_WITH_EXCHANGE
`undef CA53_IS_NOT_PREDICTABLE
`undef CA53_IS_PREDICTABLE
`undef CA53_RF_RD_EN_IMMED_BR
`undef CA53_BR_OFFSET_BITS
`undef CA53_H_BIT
`undef CA53_TAKEN_PRED_BIT
`undef CA53_EXCHANGE_BIT
`undef CA53_IS_NOT_RETURN
`undef CA53_IS_RETURN
`undef CA53_IS_NOT_CALL
`undef CA53_IS_CALL
`undef CA53_IS_DIRECT
`undef CA53_IS_NOT_DIRECT
`undef CA53_RETURN_ADDR_VALID
`undef CA53_RETURN_ADDR_INVALID
`undef CA53_RF_RD_SPECIAL_BR
`undef CA53_BR_IS_NOT_VALID
`undef CA53_BR_IS_VALID
`undef CA53_BR_X_BIT_W
`undef CA53_BX_RM_VALID
`undef CA53_BX_IMM_VALID_FROM_ARM
`undef CA53_BX_IMM_VALID_FROM_THUMB
`undef CA53_LDR_U_BIT
`undef CA53_LDR_SHIFT_LSL
`undef CA53_LDR_SHIFT_BITS
`undef CA53_LDR_SHIFT_IMM_BITS
`undef CA53_LDR_OFFSET_12_BITS
`undef CA53_LDR_RD_BITS
`undef CA53_LDR_RN_BITS
`undef CA53_LDR_RM_BITS
`undef CA53_REG_UNUSED
`undef CA53_CC_EQ
`undef CA53_CC_NE
`undef CA53_CC_CS
`undef CA53_CC_CC
`undef CA53_CC_MI
`undef CA53_CC_PL
`undef CA53_CC_VS
`undef CA53_CC_VC
`undef CA53_CC_HI
`undef CA53_CC_LS
`undef CA53_CC_GE
`undef CA53_CC_LT
`undef CA53_CC_GT
`undef CA53_CC_LE
`undef CA53_CC_AL
`undef CA53_CC_NV
`undef CA53_CC_AL_or_NV
`undef CA53_CC_FLAGS_N
`undef CA53_CC_FLAGS_Z
`undef CA53_CC_FLAGS_C
`undef CA53_CC_FLAGS_V
`undef CA53_SEL_DCU_A_ZERO
`undef CA53_SEL_DCU_A_R0
`undef CA53_SEL_DCU_A_PC
`undef CA53_SEL_DCU_A_MUL
`undef CA53_SEL_DCU_A_W
`undef CA53_SEL_DCU_B_ZERO
`undef CA53_SEL_DCU_B_1
`undef CA53_SEL_DCU_B_2
`undef CA53_SEL_DCU_B_4
`undef CA53_SEL_DCU_B_8
`undef CA53_SEL_DCU_B_BIT_R1
`undef CA53_SEL_DCU_B_BIT_IMM_LS
`undef CA53_SEL_DCU_B_BIT_SH
`undef CA53_SEL_DCU_B_BIT_PM_8
`undef CA53_SEL_DCU_B_W
`undef CA53_SEL_FWD_DCU_W
`undef CA53_SEL_FWD_DCU_BIT_W0F_WR
`undef CA53_SEL_FWD_DCU_BIT_W1F_WR
`undef CA53_SEL_FWD_DCU_BIT_W2F_WR
`undef CA53_SEL_FWD_DCU_BIT_NOF
`undef CA53_SEL_FWD_DCU_BIT_W1F_EX2
`undef CA53_SEL_FWD_DCU_BIT_W2F_EX2
`undef CA53_IMM_SEL_W
`undef CA53_IMM_SEL_NULL
`undef CA53_IMM_SEL_T32_1
`undef CA53_IMM_SEL_T32_2
`undef CA53_IMM_SEL_T32_3
`undef CA53_IMM_SEL_A64_LOG_IMM
`undef CA53_IMM_SEL_TBB
`undef CA53_IMM_SEL_ROR
`undef CA53_IMM_SEL_LSL
`undef CA53_IMM_SEL_X
`undef CA53_IMM_LSL_0
`undef CA53_IMM_LSL_16
`undef CA53_IMM_LSL_32
`undef CA53_IMM_LSL_48
`undef CA53_IMM_LSL_ADRP
`undef CA53_IMM_LSL_12
`undef CA53_RF_WR_SRC_W0_W
`undef CA53_RF_WR_SRC_W0_0
`undef CA53_RF_WR_SRC_W0_STREX
`undef CA53_RF_WR_SRC_W0_DCU_0
`undef CA53_RF_WR_SRC_W0_CPSR
`undef CA53_RF_WR_SRC_W0_MAC_HI
`undef CA53_RF_WR_SRC_W0_STR
`undef CA53_RF_WR_SRC_W0_CP
`undef CA53_RF_WR_SRC_W0_SPSR
`undef CA53_RF_WR_SRC_W0_BASE
`undef CA53_RF_WR_SRC_W1_W
`undef CA53_RF_WR_SRC_W1_0
`undef CA53_RF_WR_SRC_W1_ALU
`undef CA53_RF_WR_SRC_W1_MAC_LO
`undef CA53_RF_WR_SRC_W1_DIV
`undef CA53_RF_WR_SRC_W1_CP
`undef CA53_RF_WR_SRC_W1_FP_ALU
`undef CA53_RF_WR_SRC_W1_STR
`undef CA53_RF_WR_SRC_W2_W
`undef CA53_RF_WR_SRC_W2_0
`undef CA53_RF_WR_SRC_W2_ALU
`undef CA53_RF_WR_SRC_W2_MAC_LO
`undef CA53_RF_WR_SRC_W2_FP_ALU
`undef CA53_RF_WR_SRC_W2_STR
`undef CA53_RF_WR_SRC_W2_DCU_1
`undef CA53_RF_WR_WHEN_W
`undef CA53_RF_WR_WHEN_LATE_WR
`undef CA53_RF_WR_WHEN_EARLY_WR
`undef CA53_RF_WR_WHEN_EX2
`undef CA53_RF_WR_WHEN_EX1
`undef CA53_RF_RD_NEED_W
`undef CA53_RF_RD_NEED_EARLY_ISS
`undef CA53_RF_RD_NEED_LATE_ISS
`undef CA53_RF_RD_NEED_EX1
`undef CA53_RF_RD_NEED_EX2
`undef CA53_RF_FWR_WHEN_W
`undef CA53_RF_FWR_WHEN_0
`undef CA53_RF_FWR_WHEN_F3
`undef CA53_RF_FWR_WHEN_F4
`undef CA53_RF_FWR_WHEN_F5
`undef CA53_RF_FWR_WHEN_L_F5
`undef CA53_RF_FRD_NEED_W
`undef CA53_RF_FRD_NEED_F1
`undef CA53_RF_FRD_NEED_F2
`undef CA53_RF_FWR_SRC_W
`undef CA53_RF_FWR_SRC_0
`undef CA53_RF_FWR_SRC_NONE
`undef CA53_RF_FWR_SRC_DCU_DUP
`undef CA53_RF_FWR_SRC_DCU_DUP2
`undef CA53_RF_FWR_SRC_FAD_Q
`undef CA53_RF_FWR_SRC_FAD_NARROW
`undef CA53_RF_FWR_SRC_FML_Q
`undef CA53_RF_FWR_SRC_DCU_PERM
`undef CA53_RF_FWR_SRC_DCU_SGL
`undef CA53_RF_FWR_SRC_DCU_SGL2
`undef CA53_RF_FWR_SRC_STR
`undef CA53_RF_FWR_SRC_DCU_DBL
`undef CA53_RF_FWR_SRC_STR_SP
`undef CA53_RF_FWR_SRC_STR_2SP
`undef CA53_RF_FWR_SRC_CRYPTO_F3
`undef CA53_RF_FWR_SRC_CRYPTO_F5
`undef CA53_FWD_W
`undef CA53_FWD_W0
`undef CA53_FWD_W1
`undef CA53_FWD_W2
`undef CA53_FWD_ALU0_EX2
`undef CA53_FWD_NULL
`undef CA53_FWD_ALU1_EX2
`undef CA53_FWD_ALU0_EX1
`undef CA53_FWD_ALU1_EX1
`undef CA53_FWD_FP
`undef CA53_FWD_FP_LO
`undef CA53_FWD_FP_HI
`undef CA53_LS_INSTR_TYPE_W
`undef CA53_LS_INSTR_SINGLE
`undef CA53_LS_INSTR_MULTIPLE
`undef CA53_LS_INSTR_SIGN_EXT
`undef CA53_LS_INSTR_LDC_STC
`undef CA53_LS_INSTR_SRS
`undef CA53_LS_INSTR_EXCL_SGL
`undef CA53_LS_INSTR_PLD_L1KEEP
`undef CA53_LS_INSTR_PLD_L1STRM
`undef CA53_LS_INSTR_PLD_L2KEEP
`undef CA53_LS_INSTR_PLD_L2STRM
`undef CA53_LS_INSTR_ORDERED
`undef CA53_LS_INSTR_ORD_EXCL_SGL
`undef CA53_LS_INSTR_NON_TEMPORAL
`undef CA53_LS_INSTR_DCZVA
`undef CA53_LS_ELEM_SIZE_8BIT
`undef CA53_LS_ELEM_SIZE_16BIT
`undef CA53_LS_ELEM_SIZE_32BIT
`undef CA53_LS_ELEM_SIZE_64BIT
`undef CA53_LS_ELEM_SIZE_128BIT
`undef CA53_PMN_SEL_OTHERS
`undef CA53_CRN0_MIDR
`undef CA53_CRN0_CTR
`undef CA53_CRN0_TLBTR
`undef CA53_CRN0_MPIDR
`undef CA53_CRN0_REVIDR
`undef CA53_CRN0_DCZID_EL0
`undef CA53_CRN0_ID_PFR0
`undef CA53_CRN0_ID_PFR1
`undef CA53_CRN0_ID_DFR0
`undef CA53_CRN0_ID_MMFR0
`undef CA53_CRN0_ID_MMFR1
`undef CA53_CRN0_ID_MMFR2
`undef CA53_CRN0_ID_MMFR3
`undef CA53_CRN0_ID_ISAR0
`undef CA53_CRN0_ID_ISAR1
`undef CA53_CRN0_ID_ISAR2
`undef CA53_CRN0_ID_ISAR3
`undef CA53_CRN0_ID_ISAR4
`undef CA53_CRN0_ID_ISAR5
`undef CA53_CRN0_ID_CCSIDR
`undef CA53_CRN0_ID_CLIDR
`undef CA53_CRN0_CSSELR
`undef CA53_CRN0_VPIDR
`undef CA53_CRN0_VMPIDR
`undef CA53_CRN1_SCTLR
`undef CA53_CRN1_SCTLR_EL1
`undef CA53_CRN1_SCTLR_EL3
`undef CA53_CRN1_CPUACTLR
`undef CA53_CRN1_CPUECTLR
`undef CA53_CRN1_ACTLR_EL3
`undef CA53_CRN1_ACTLR_EL2
`undef CA53_CRN1_CPACR
`undef CA53_CRN1_SCR
`undef CA53_CRN1_SDER
`undef CA53_CRN5_FPEXC
`undef CA53_CRN1_NSACR
`undef CA53_CRN1_VCR
`undef CA53_CRN1_HCR
`undef CA53_CRN1_HCR2
`undef CA53_CRN1_HDCR
`undef CA53_CRN1_MDCR_EL3
`undef CA53_CRN1_HCPTR
`undef CA53_CRN1_CPTR_EL3
`undef CA53_CRN1_HSTR
`undef CA53_CRN1_HSCTLR
`undef CA53_CRN3_DACR
`undef CA53_CRN4_SPSEL
`undef CA53_CRN4_DAIF
`undef CA53_CRN4_CURRENTEL
`undef CA53_CRN4_NZCV
`undef CA53_CRN4_FPCR
`undef CA53_CRN4_FPSR
`undef CA53_CRN5_DFSR
`undef CA53_CRN5_IFSR
`undef CA53_CRN5_ESR_EL2
`undef CA53_CRN5_ESR_EL3
`undef CA53_CRN6_DFAR
`undef CA53_CRN6_IFAR
`undef CA53_CRN6_FAR_EL2
`undef CA53_CRN6_FAR_EL3
`undef CA53_CRN6_HDFAR
`undef CA53_CRN6_HIFAR
`undef CA53_CRN6_HPFAR
`undef CA53_CRN7_WFI
`undef CA53_CRN7_ICIMVAU
`undef CA53_CRN7_ISB
`undef CA53_CRN9_PMCR
`undef CA53_CRN9_PMNCNTENSET
`undef CA53_CRN9_PMNCNTENCLR
`undef CA53_CRN9_PMOVSR
`undef CA53_CRN9_PMOVSSET
`undef CA53_CRN9_PMSWINC
`undef CA53_CRN9_PMSELR
`undef CA53_CRN9_PMCCNTR
`undef CA53_CRN9_PMCCNTR_64
`undef CA53_CRN9_PMXEVTYPER
`undef CA53_CRN9_PMXEVCNTR
`undef CA53_CRN9_PMUSERENR
`undef CA53_CRN9_PMINTENSET
`undef CA53_CRN9_PMINTENCLR
`undef CA53_CRN14_PMEVCNTRn
`undef CA53_CRN14_PMEVCNTR0
`undef CA53_CRN14_PMEVCNTR1
`undef CA53_CRN14_PMEVCNTR2
`undef CA53_CRN14_PMEVCNTR3
`undef CA53_CRN14_PMEVCNTR4
`undef CA53_CRN14_PMEVCNTR5
`undef CA53_CRN14_PMEVTYPERn
`undef CA53_CRN14_PMEVTYPER0
`undef CA53_CRN14_PMEVTYPER1
`undef CA53_CRN14_PMEVTYPER2
`undef CA53_CRN14_PMEVTYPER3
`undef CA53_CRN14_PMEVTYPER4
`undef CA53_CRN14_PMEVTYPER5
`undef CA53_CRN14_PMCCFILTR
`undef CA53_CRN9_PMCEID0
`undef CA53_CRN12_VBAR
`undef CA53_CRN12_VBAR_EL3
`undef CA53_CRN12_MVBAR
`undef CA53_CRN12_ISR
`undef CA53_CRN12_VIR
`undef CA53_CRN12_HVBAR
`undef CA53_CRN13_HTPIDR
`undef CA53_CRN13_CID
`undef CA53_CRN13_TPIDRURW
`undef CA53_CRN13_TPIDRURO
`undef CA53_CRN13_TPIDRPRW
`undef CA53_CRN15_CSOR
`undef CA53_CRM2_VTTBR
`undef CA53_CP14_DBG_DIDR
`undef CA53_CP14_DBG_DRAR
`undef CA53_CP14_DBG_DSAR
`undef CA53_CP14_DBG_DSCR_INT
`undef CA53_CP14_DBG_DTR_INT
`undef CA53_CP14_DBG_DSCR_FLAGS
`undef CA53_CP14_DBG_WFAR
`undef CA53_CP14_DBG_DTRRX_EXT
`undef CA53_CP14_DBG_DSCR_EXT
`undef CA53_CP14_DBG_DTRTX_EXT
`undef CA53_CP14_DBG_PRCR
`undef CA53_CP14_DBG_OSLAR
`undef CA53_CP14_DBG_OSDLR
`undef CA53_CP14_DBG_OSLSR
`undef CA53_CP14_DBG_CLAIMSET
`undef CA53_CP14_DBG_CLAIMCLR
`undef CA53_CP14_DBG_AUTHSTATUS
`undef CA53_CP14_DBG_DEVID
`undef CA53_CP14_DBG_DEVID1
`undef CA53_CP14_MDCCINT_EL1
`undef CA53_CP14_DBG_MDSCR_EL1
`undef CA53_CP14_DBG_DTR_EL0
`undef CA53_CP14_DBG_OSECCR_EL1
`undef CA53_CP15_CBAR
`undef CA53_CP15_MRC_EXTERNAL
`undef CA53_CRN0_ID_AA64PFR0_EL1
`undef CA53_CRN0_ID_AA64PFR1_EL1
`undef CA53_CRN0_MVFR0_EL1
`undef CA53_CRN0_MVFR1_EL1
`undef CA53_CRN0_MVFR2_EL1
`undef CA53_CRN0_AA64PFR0_EL1
`undef CA53_CRN0_AA64PFR1_EL1
`undef CA53_CRN0_AA64DFR0_EL1
`undef CA53_CRN0_AA64DFR1_EL1
`undef CA53_CRN0_AA64AFR0_EL1
`undef CA53_CRN0_AA64AFR1_EL1
`undef CA53_CRN0_AA64ISAR0_EL1
`undef CA53_CRN0_AA64ISAR1_EL1
`undef CA53_CRN0_AA64MMFR0_EL1
`undef CA53_CRN0_AA64MMFR1_EL1
`undef CA53_CRN12_RVBAR_EL3
`undef CA53_CRN12_RMR_EL3
`undef CA53_CRN13_TPIDR_EL3
`undef CA53_VFP_FPSID
`undef CA53_VFP_FPSCR
`undef CA53_CP15_DBG_DSPSR_EL0
`undef CA53_CRN15_CPUMERRSR
`undef CA53_DPU_CP15_DSIZE
`undef CA53_DPU_CP14_DSIZE
`undef CA53_ALU_CTL_64BIT_OP_W
`undef CA53_ALU_CTL_64BIT_OP_BITS
`undef CA53_ALU_FLAG_SET_W
`undef CA53_ALU_RD_IS_R15_W
`undef CA53_ALU_EX1_CTL_SHIFT_OP_BITS
`undef CA53_ALU_EX1_CTL_SHIFT_RRX_FOR_0_BITS
`undef CA53_ALU_EX1_XTRACT_TYP_W
`undef CA53_ALU_EX1_XTRACT_TYP_BITS
`undef CA53_ALU_EX1_SIGN_XTEND_W
`undef CA53_ALU_EX1_SIGN_XTEND_BITS
`undef CA53_ALU_EX1_XTRCT_VAL_W
`undef CA53_ALU_EX1_XTRCT_VAL_BITS
`undef CA53_ALU_EX1_MASK_SEL_W
`undef CA53_ALU_EX1_MASK_SEL_BITS
`undef CA53_ALU_EX1_REV_TYPE_W
`undef CA53_ALU_EX1_REV_TYPE_BITS
`undef CA53_LU_CTL_W
`undef CA53_ALU_AU_CARRY_LU_OPCODE_W
`undef CA53_ALU_EX2_CTL_LU_CTL_BITS
`undef CA53_ALU_EX2_CTL_OP_COMP_SHF_A_BIT
`undef CA53_ALU_EX2_CTL_OP_COMP_SHF_B_BIT
`undef CA53_ALU_EX2_CTL_FLAG_ID_BITS
`undef CA53_ALU_EX2_CTL_CCMP_BIT
`undef CA53_SIMD_ADDSUBX_W
`undef CA53_ALU_EX2_CTL_SIMD_ADD_SUB_X_BITS
`undef CA53_ALU_EX2_VALID_SIMD_W
`undef CA53_ALU_EX2_CTL_VALID_SIMD_BITS
`undef CA53_ALU_EX2_SIMD_SIZE_W
`undef CA53_ALU_EX2_CTL_SIMD_SIZE_BITS
`undef CA53_ALU_EX2_SIMD_HALVING_W
`undef CA53_ALU_EX2_CTL_HALVING_BITS
`undef CA53_ALU_EX2_SIMD_SIGN_ARTH_W
`undef CA53_ALU_EX2_SIMD_SIGN_ARTH_BITS
`undef CA53_ALU_EX2_SEL_VALID_W
`undef CA53_ALU_EX2_SEL_VALID_BITS
`undef CA53_ALU_EX2_CBZ_BYPASS_W
`undef CA53_ALU_EX2_CBZ_BYPASS_BITS
`undef CA53_ALU_EX2_SIGN_REPLICATE_W
`undef CA53_ALU_EX2_SIGN_REPLICATE_BITS
`undef CA53_SIMD_SAT_VALID_W
`undef CA53_ALU_WR_CTL_SAT_VALID_BITS
`undef CA53_ALU_GEN_CTL_W
`undef CA53_ALU_WR_CTL_W
`undef CA53_ALU_EX2_CTL_W
`undef CA53_ALU_EX2_CTL_LOW
`undef CA53_ALU_EX2_CTL_HIGH
`undef CA53_ALU_EX1_CTL_W
`undef CA53_ALU_PIPECTL_W
`undef CA53_ALU_PIPECTL_ALU_WR_CTL_BITS
`undef CA53_ALU_PIPECTL_ALU_EX2_CTL_BITS
`undef CA53_ALU_PIPECTL_ALU_EX1_CTL_BITS
`undef CA53_ALU_PIPECTL_ALU_GEN_CTL_BITS
`undef CA53_MAC_ISS_CTL_W
`undef CA53_MAC_CTL_64BIT_OP_W
`undef CA53_MAC_CTL_64BIT_OP_BITS
`undef CA53_MAC_GEN_CTL_W
`undef CA53_MAC_PIPECTL_W
`undef CA53_MAC_PIPECTL_MAC_ISS_CTL_BITS
`undef CA53_MAC_PIPECTL_MAC_GEN_CTL_BITS
`undef CA53_IMM_SHIFT_W
`undef CA53_IMM_DATA_W
`undef CA53_IMM_OT_W
`undef CA53_IMM_OT_0
`undef CA53_IMM_OT_B_1
`undef CA53_IMM_OT_B_4
`undef CA53_IMM_DP_W
`undef CA53_IMM_DP_0
`undef CA53_IMM_DP_A32_SHIFT
`undef CA53_IMM_DP_T32_SHIFT
`undef CA53_IMM_DP_ADDW
`undef CA53_IMM_DP_T32_IMM
`undef CA53_IMM_DP_MOVW
`undef CA53_IMM_DP_EXTEND
`undef CA53_IMM_DP_A32_IMM
`undef CA53_IMM_DP_BFM
`undef CA53_IMM_DP_A64_ADR
`undef CA53_IMM_DP_EXT_REG
`undef CA53_IMM_DP_LOG_IMM
`undef CA53_IMM_DP_EXTR
`undef CA53_IMM_DP_CSEL
`undef CA53_IMM_DP_CRC32
`undef CA53_IMM_LS_W
`undef CA53_IMM_LS_0
`undef CA53_IMM_LS_8
`undef CA53_IMM_LS_A32_SHIFT
`undef CA53_IMM_LS_SCALED
`undef CA53_IMM_LS_LDP_STP
`undef CA53_IMM_LS_SIGNED
`undef CA53_IMM_LS_IMM4HL
`undef CA53_IMM_LS_LSM1
`undef CA53_IMM_LS_LSM2
`undef CA53_IMM_LS_A64_LIT
`undef CA53_IMM_LS_TBB
`undef CA53_IMM_NEON_W
`undef CA53_IMM_NEON_0
`undef CA53_IMM_NEON_32
`undef CA53_IMM_NEON_64
`undef CA53_IMM_NEON_LDC_STC
`undef CA53_IMM_NEON_VFP_IMM
`undef CA53_IMM_NEON_VCVT_16
`undef CA53_IMM_NEON_VCVT_32
`undef CA53_IMM_NEON_VCVT_64
`undef CA53_IMM_NEON_VEXT
`undef CA53_IMM_NEON_VDUP_VCVT
`undef CA53_IMM_NEON_NEON_VCVT_64
`undef CA53_IMM_NEON_VSHL
`undef CA53_IMM_NEON_VSHR
`undef CA53_IMM_NEON_VMOV_SCAL
`undef CA53_IMM_NEON_NEON_IMM
`undef CA53_IMM_NEON_NEON_LSM
`undef CA53_IMM_NEON_LDR_LITERAL
`undef CA53_IMM_NEON_LS_PAIR
`undef CA53_IMM_NEON_LS_UNSCALED
`undef CA53_IMM_NEON_LS_IMM12
`undef CA53_IMM_NEON_CCMP_CSEL
`undef CA53_IMM_NEON_INS_VECTOR
`undef CA53_IMM_NEON_VDUP_SCAL
`undef CA53_FORCEOP_TYPE_W
`undef CA53_FORCEOP_TYPE_NULL
`undef CA53_FORCEOP_TYPE_EL2
`undef CA53_FORCEOP_TYPE_SUB
`undef CA53_FORCEOP_TYPE_ADD
`undef CA53_FORCEOP_OFFSET_W
`undef CA53_FORCEOP_OFFSET_0
`undef CA53_FORCEOP_OFFSET_2
`undef CA53_FORCEOP_OFFSET_4
`undef CA53_FORCEOP_OFFSET_8
`undef CA53_FORCEOP_OFFSET_TYPE_W
`undef CA53_FORCEOP_OFFSET_TYPE_0_4
`undef CA53_FORCEOP_OFFSET_TYPE_2_4
`undef CA53_FORCEOP_OFFSET_TYPE_4_8
`undef CA53_FORCEOP_OFFSET_TYPE_4_0
`undef CA53_FAULT_REG_EN_W
`undef CA53_FAULT_REG_EN_DFSR
`undef CA53_FAULT_REG_EN_DFAR
`undef CA53_FAULT_REG_EN_IFSR
`undef CA53_FAULT_REG_EN_IFAR
`undef CA53_FAULT_REG_EN_HSR
`undef CA53_FAULT_REG_EN_HIFAR
`undef CA53_FAULT_REG_EN_HDFAR
`undef CA53_FAULT_REG_EN_HPFAR
`undef CA53_FAULT_REG_EN_ESR_EL1
`undef CA53_FAULT_REG_EN_FAR_EL1
`undef CA53_FAULT_REG_EN_ESR_EL2
`undef CA53_FAULT_REG_EN_FAR_EL2
`undef CA53_FAULT_REG_EN_ESR_EL3
`undef CA53_FAULT_REG_EN_FAR_EL3
`undef CA53_CPSR_WR_EN_EARLY_W
`undef CA53_CPSR_WR_EN_EARLY_NULL
`undef CA53_CPSR_WR_EN_EARLY_IM
`undef CA53_CPSR_WR_EN_EARLY_AIM
`undef CA53_CPSR_WR_EN_EARLY_AIFM
`undef CA53_SEL_CPSR_SRC_TYPE_W
`undef CA53_SEL_CPSR_SRC_TYPE_FORCE
`undef CA53_SEL_CPSR_SRC_TYPE_DSPSR
`undef CA53_SYND_TYPE_W
`undef CA53_SYND_TYPE_UNSPEC
`undef CA53_SYND_TYPE_DEBUG
`undef CA53_SYND_TYPE_FABORT
`undef CA53_SYND_TYPE_CALL
`undef CA53_SYND_TYPE_WFX
`undef CA53_SYND_TYPE_SYS_REG
`undef CA53_SYND_TYPE_FP_NEON
`undef CA53_SYND_TYPE_IL_BIT
`undef CA53_EXPT_TYPE_W
`undef CA53_EXPT_TYPE_RESET
`undef CA53_EXPT_TYPE_WPT
`undef CA53_EXPT_TYPE_DATA
`undef CA53_EXPT_TYPE_FIQ
`undef CA53_EXPT_TYPE_IRQ
`undef CA53_EXPT_TYPE_IMPRECISE
`undef CA53_EXPT_TYPE_DEBUG_HLT
`undef CA53_EXPT_TYPE_DEBUG_EXPT
`undef CA53_EXPT_TYPE_INSTR_FAULT
`undef CA53_EXPT_TYPE_TRAP
`undef CA53_EXPT_TYPE_CALL
`undef CA53_EXPT_TYPE_WFI
`undef CA53_EXPT_TYPE_WFE
`undef CA53_EXPT_TYPE_COND_TRAP
`undef CA53_EXPT_TYPE_DEBUG_EXIT
`undef CA53_EXPT_TYPE_SP_ALIGNMENT
`undef CA53_EXPT_TYPE_ECC_REEXEC
`undef CA53_EXPT_TYPE_COND_TRAP_OR_UND
`undef CA53_EXPT_TYPE_PC_ALIGNMENT
`undef CA53_DBG_STATUS_W
`undef CA53_DBG_STATUS_NULL
`undef CA53_DBG_STATUS_BKPT
`undef CA53_DBG_STATUS_BKPT_INSTR
`undef CA53_DBG_STATUS_EXT_DBG_REQ
`undef CA53_DBG_STATUS_VECTOR_CATCH
`undef CA53_DBG_STATUS_HLT_STEP_NORM
`undef CA53_DBG_STATUS_HLT_STEP_EXCL
`undef CA53_DBG_STATUS_OS_UNLOCK
`undef CA53_DBG_STATUS_RESET_CATCH
`undef CA53_DBG_STATUS_WPT
`undef CA53_DBG_STATUS_HLT
`undef CA53_DBG_STATUS_DEBUG_REG
`undef CA53_DBG_STATUS_EXPT_CATCH
`undef CA53_DBG_STATUS_HLT_STEP_MISC
`undef CA53_EXPT_INSTR_BUS_W
`undef CA53_EXPT_INSTR_BUS_MISC_BIT
`undef CA53_EXPT_INSTR_BUS_IS_OTHER_BIT
`undef CA53_EXPT_INSTR_BUS_IS_LS_BIT
`undef CA53_EXPT_INSTR_BUS_INSTR_D_BIT
`undef CA53_EXPT_INSTR_BUS_INSTR_BITS
`undef CA53_EXPT_BUS_W
`undef CA53_EXPT_BUS_ESR_BITS
`undef CA53_EXPT_BUS_EC_BITS
`undef CA53_EXPT_BUS_TARGET_MODE_BITS
`undef CA53_EXPT_BUS_TARGET_EL_BITS
`undef CA53_EXPT_BUS_QUASH_BIT
`undef CA53_EXPT_BUS_CPSR_BITS
`undef CA53_EXPT_BUS_VEC_OFFSET_BITS
`undef CA53_EXPT_BUS_ENTER_HALT_BIT
`undef CA53_EXPT_BUS_HIGH_PRI_BIT
`undef CA53_EXPT_BUS_EXPT_TYPE_BITS
`undef CA53_EXPT_BUS_FORCEOP_BITS
`undef CA53_EXPT_BUS_DBG_STATUS_BITS
`undef CA53_ETM_EXPT_TYPE_W
`undef CA53_ETM_EXPT_TYPE_NULL
`undef CA53_ETM_EXPT_TYPE_DATA_ABORT
`undef CA53_ETM_EXPT_TYPE_FIQ
`undef CA53_ETM_EXPT_TYPE_IRQ
`undef CA53_ETM_EXPT_TYPE_IMPRECISE_ABORT
`undef CA53_ETM_EXPT_TYPE_PREFETCH_ABORT
`undef CA53_ETM_EXPT_TYPE_SVC
`undef CA53_ETM_EXPT_TYPE_SMC
`undef CA53_ETM_EXPT_TYPE_HVC
`undef CA53_ETM_EXPT_TYPE_UNDEF
`undef CA53_ETM_EXPT_TYPE_IBKPT
`undef CA53_ETM_EXPT_TYPE_HALT
`undef CA53_ETM_EXPT_TYPE_GENERIC
`undef CA53_ETM_EXPT_TYPE_RESET
`undef CA53_ETM_EXPT_TYPE_X
`undef CA53_CPSR_RET_W
`undef CA53_CPSR_RET_N_BITS
`undef CA53_CPSR_RET_Z_BITS
`undef CA53_CPSR_RET_C_BITS
`undef CA53_CPSR_RET_V_BITS
`undef CA53_CPSR_RET_Q_BITS
`undef CA53_CPSR_RET_NZCV_BITS
`undef CA53_CPSR_RET_CV_BITS
`undef CA53_CPSR_RET_NZCVQ_BITS
`undef CA53_CPSR_RET_IT_LOW_BITS
`undef CA53_CPSR_RET_SS_BITS
`undef CA53_CPSR_RET_IL_BITS
`undef CA53_CPSR_RET_GE_BITS
`undef CA53_CPSR_RET_IT_COND_BITS
`undef CA53_CPSR_RET_IT_HIGH_BITS
`undef CA53_CPSR_RET_IT_HICM_BITS
`undef CA53_CPSR_RET_DAIF_BITS
`undef CA53_CPSR_RET_EAIF_BITS
`undef CA53_CPSR_RET_D_BITS
`undef CA53_CPSR_RET_E_BITS
`undef CA53_CPSR_RET_A_BITS
`undef CA53_CPSR_RET_I_BITS
`undef CA53_CPSR_RET_F_BITS
`undef CA53_CPSR_RET_T_BITS
`undef CA53_CPSR_RET_MODE_BITS
`undef CA53_CPSR_RET_T_BYTE
`undef CA53_CPSR_RET_H_BYTE
`undef CA53_CPSR_RET_L_BYTE
`undef CA53_CPSR_RET_B_BYTE
`undef CA53_SPSR_RET_W
`undef CA53_SPSR_RET_N_BITS
`undef CA53_SPSR_RET_Z_BITS
`undef CA53_SPSR_RET_C_BITS
`undef CA53_SPSR_RET_V_BITS
`undef CA53_SPSR_RET_Q_BITS
`undef CA53_SPSR_RET_NZCV_BITS
`undef CA53_SPSR_RET_CVQ_BITS
`undef CA53_SPSR_RET_NZCVQ_BITS
`undef CA53_SPSR_RET_IT_LOW_BITS
`undef CA53_SPSR_RET_SS_BITS
`undef CA53_SPSR_RET_IL_BITS
`undef CA53_SPSR_RET_GE_BITS
`undef CA53_SPSR_RET_IT_COND_BITS
`undef CA53_SPSR_RET_IT_HIGH_BITS
`undef CA53_SPSR_RET_IT_HICM_BITS
`undef CA53_SPSR_RET_DAIF_BITS
`undef CA53_SPSR_RET_EAIF_BITS
`undef CA53_SPSR_RET_D_BITS
`undef CA53_SPSR_RET_E_BITS
`undef CA53_SPSR_RET_A_BITS
`undef CA53_SPSR_RET_I_BITS
`undef CA53_SPSR_RET_F_BITS
`undef CA53_SPSR_RET_T_BITS
`undef CA53_SPSR_RET_AARCH_BITS
`undef CA53_SPSR_RET_MODE_BITS
`undef CA53_SPSR_RET_T_BYTE
`undef CA53_SPSR_RET_H_BYTE
`undef CA53_SPSR_RET_L_BYTE
`undef CA53_SPSR_RET_B_BYTE
`undef CA53_PSR_ARCH_N_BITS
`undef CA53_PSR_ARCH_Z_BITS
`undef CA53_PSR_ARCH_C_BITS
`undef CA53_PSR_ARCH_V_BITS
`undef CA53_PSR_ARCH_Q_BITS
`undef CA53_PSR_ARCH_NZ_BITS
`undef CA53_PSR_ARCH_NZCV_BITS
`undef CA53_PSR_ARCH_NZCVQ_BITS
`undef CA53_PSR_ARCH_IT_LOW_BITS
`undef CA53_PSR_ARCH_J_BITS
`undef CA53_PSR_ARCH_SS_BITS
`undef CA53_PSR_ARCH_IL_BITS
`undef CA53_PSR_ARCH_GE_BITS
`undef CA53_PSR_ARCH_IT_COND_BITS
`undef CA53_PSR_ARCH_IT_HIGH_BITS
`undef CA53_PSR_ARCH_IT_HICM_BITS
`undef CA53_PSR_ARCH_DAIF_BITS
`undef CA53_PSR_ARCH_EAIF_BITS
`undef CA53_PSR_ARCH_D_BITS
`undef CA53_PSR_ARCH_E_BITS
`undef CA53_PSR_ARCH_A_BITS
`undef CA53_PSR_ARCH_I_BITS
`undef CA53_PSR_ARCH_F_BITS
`undef CA53_PSR_ARCH_T_BITS
`undef CA53_PSR_ARCH_MODE_BITS
`undef CA53_SEL_CPSR_SRC_W
`undef CA53_SEL_CPSR_SRC_CPSR
`undef CA53_SEL_CPSR_SRC_FORCE
`undef CA53_SEL_CPSR_SRC_DP
`undef CA53_SEL_CPSR_SRC_MUL
`undef CA53_SEL_CPSR_SRC_LOAD_DATA
`undef CA53_SEL_CPSR_SRC_SPSR
`undef CA53_SEL_CPSR_SRC_CCFLAGS
`undef CA53_SEL_CPSR_SRC_DSCR
`undef CA53_SEL_CPSR_SRC_QFLAG
`undef CA53_SEL_CPSR_SRC_DSPSR
`undef CA53_SEL_CPSR_SRC_RFE
`undef CA53_SEL_CPSR_SRC_BLX
`undef CA53_SEL_CPSR_SRC_CPS
`undef CA53_SEL_CPSR_SRC_INSTR1
`undef CA53_SEL_CPSR_EN_W
`undef CA53_SEL_CPSR_EN_NULL
`undef CA53_SEL_CPSR_EN_IT
`undef CA53_SEL_CPSR_EN_T
`undef CA53_SEL_CPSR_EN_E
`undef CA53_SEL_CPSR_EN_M0
`undef CA53_SEL_CPSR_EN_ETIM
`undef CA53_SEL_CPSR_EN_ETAIM
`undef CA53_SEL_CPSR_EN_ETAIFM
`undef CA53_SEL_CPSR_EN_GE
`undef CA53_SEL_CPSR_EN_Q
`undef CA53_SEL_CPSR_EN_CC
`undef CA53_SEL_CPSR_EN_SPSR
`undef CA53_SEL_MRS_CPSR_RET
`undef CA53_SEL_MRS_SPSR_RET
`undef CA53_FLAGEN_INSTR1_W
`undef CA53_FLAGEN_INSTR1_NONE
`undef CA53_FLAGEN_INSTR1_CC
`undef CA53_FLAGEN_INSTR1_GE
`undef CA53_FLAGEN_INSTR1_Q
`undef CA53_SIMD_SIGNED_SAT_ARITH
`undef CA53_SIMD_SIGNED_ARITH
`undef CA53_SIMD_SIGNED_HALF_ARITH
`undef CA53_SIMD_UNSIGNED_ARITH
`undef CA53_SIMD_UNSIGNED_HALF_ARITH
`undef CA53_SIMD_UNSIGNED_SAT_ARITH
`undef CA53_SIMD_X
`undef CA53_SIMD_SIZE_16
`undef CA53_SIMD_SIZE_8
`undef CA53_MEDIA_SIGNED_SAT_ARITH
`undef CA53_MEDIA_SIGNED_ARITH
`undef CA53_MEDIA_SIGNED_HALF_ARITH
`undef CA53_MEDIA_UNSIGNED_ARITH
`undef CA53_MEDIA_UNSIGNED_HALF_ARITH
`undef CA53_MEDIA_UNSIGNED_SAT_ARITH
`undef CA53_MEDIA_X
`undef CA53_EXTRACT_LS_BYTE
`undef CA53_EXTRACT_LS_HWORD
`undef CA53_EXTRACT_TWO_BYTES
`undef CA53_EXTRACT_SH_BYTE
`undef CA53_EXTRACT_SH_HWORD
`undef CA53_EXTRACT_SH_WORD
`undef CA53_EXTRACT_SH_XWORD
`undef CA53_SAT_POS_32_VALUE
`undef CA53_SAT_NEG_32_VALUE
`undef CA53_SAT_POS_64_VALUE
`undef CA53_SAT_NEG_64_VALUE
`undef CA53_FP_RF_RD_ADDR_W
`undef CA53_FP_RF_WR_ADDR_W
`undef CA53_FP_RF_ADDR_L_W
`undef CA53_FPU_ADDR_D00
`undef CA53_FPU_ADDR_D01
`undef CA53_FPU_ADDR_D02
`undef CA53_FPU_ADDR_D03
`undef CA53_FPU_ADDR_D04
`undef CA53_FPU_ADDR_D05
`undef CA53_FPU_ADDR_D06
`undef CA53_FPU_ADDR_D07
`undef CA53_FPU_ADDR_D08
`undef CA53_FPU_ADDR_D09
`undef CA53_FPU_ADDR_D10
`undef CA53_FPU_ADDR_D11
`undef CA53_FPU_ADDR_D12
`undef CA53_FPU_ADDR_D13
`undef CA53_FPU_ADDR_D14
`undef CA53_FPU_ADDR_D15
`undef CA53_FPU_ADDR_D16
`undef CA53_FPU_ADDR_D17
`undef CA53_FPU_ADDR_D18
`undef CA53_FPU_ADDR_D19
`undef CA53_FPU_ADDR_D20
`undef CA53_FPU_ADDR_D21
`undef CA53_FPU_ADDR_D22
`undef CA53_FPU_ADDR_D23
`undef CA53_FPU_ADDR_D24
`undef CA53_FPU_ADDR_D25
`undef CA53_FPU_ADDR_D26
`undef CA53_FPU_ADDR_D27
`undef CA53_FPU_ADDR_D28
`undef CA53_FPU_ADDR_D29
`undef CA53_FPU_ADDR_D30
`undef CA53_FPU_ADDR_D31
`undef CA53_FPU_ADDR_S00
`undef CA53_FPU_ADDR_S01
`undef CA53_FPU_ADDR_S02
`undef CA53_FPU_ADDR_S03
`undef CA53_FPU_ADDR_S04
`undef CA53_FPU_ADDR_S05
`undef CA53_FPU_ADDR_S06
`undef CA53_FPU_ADDR_S07
`undef CA53_FPU_ADDR_S08
`undef CA53_FPU_ADDR_S09
`undef CA53_FPU_ADDR_S10
`undef CA53_FPU_ADDR_S11
`undef CA53_FPU_ADDR_S12
`undef CA53_FPU_ADDR_S13
`undef CA53_FPU_ADDR_S14
`undef CA53_FPU_ADDR_S15
`undef CA53_FPU_ADDR_S16
`undef CA53_FPU_ADDR_S17
`undef CA53_FPU_ADDR_S18
`undef CA53_FPU_ADDR_S19
`undef CA53_FPU_ADDR_S20
`undef CA53_FPU_ADDR_S21
`undef CA53_FPU_ADDR_S22
`undef CA53_FPU_ADDR_S23
`undef CA53_FPU_ADDR_S24
`undef CA53_FPU_ADDR_S25
`undef CA53_FPU_ADDR_S26
`undef CA53_FPU_ADDR_S27
`undef CA53_FPU_ADDR_S28
`undef CA53_FPU_ADDR_S29
`undef CA53_FPU_ADDR_S30
`undef CA53_FPU_ADDR_S31
`undef CA53_NEON_ADDR_S00
`undef CA53_NEON_ADDR_S01
`undef CA53_NEON_ADDR_S02
`undef CA53_NEON_ADDR_S03
`undef CA53_NEON_ADDR_S04
`undef CA53_NEON_ADDR_S05
`undef CA53_NEON_ADDR_S06
`undef CA53_NEON_ADDR_S07
`undef CA53_NEON_ADDR_S08
`undef CA53_NEON_ADDR_S09
`undef CA53_NEON_ADDR_S10
`undef CA53_NEON_ADDR_S11
`undef CA53_NEON_ADDR_S12
`undef CA53_NEON_ADDR_S13
`undef CA53_NEON_ADDR_S14
`undef CA53_NEON_ADDR_S15
`undef CA53_NEON_ADDR_S16
`undef CA53_NEON_ADDR_S17
`undef CA53_NEON_ADDR_S18
`undef CA53_NEON_ADDR_S19
`undef CA53_NEON_ADDR_S20
`undef CA53_NEON_ADDR_S21
`undef CA53_NEON_ADDR_S22
`undef CA53_NEON_ADDR_S23
`undef CA53_NEON_ADDR_S24
`undef CA53_NEON_ADDR_S25
`undef CA53_NEON_ADDR_S26
`undef CA53_NEON_ADDR_S27
`undef CA53_NEON_ADDR_S28
`undef CA53_NEON_ADDR_S29
`undef CA53_NEON_ADDR_S30
`undef CA53_NEON_ADDR_S31
`undef CA53_NEON_ADDR_S32
`undef CA53_NEON_ADDR_S33
`undef CA53_NEON_ADDR_S34
`undef CA53_NEON_ADDR_S35
`undef CA53_NEON_ADDR_S36
`undef CA53_NEON_ADDR_S37
`undef CA53_NEON_ADDR_S38
`undef CA53_NEON_ADDR_S39
`undef CA53_NEON_ADDR_S40
`undef CA53_NEON_ADDR_S41
`undef CA53_NEON_ADDR_S42
`undef CA53_NEON_ADDR_S43
`undef CA53_NEON_ADDR_S44
`undef CA53_NEON_ADDR_S45
`undef CA53_NEON_ADDR_S46
`undef CA53_NEON_ADDR_S47
`undef CA53_NEON_ADDR_S48
`undef CA53_NEON_ADDR_S49
`undef CA53_NEON_ADDR_S50
`undef CA53_NEON_ADDR_S51
`undef CA53_NEON_ADDR_S52
`undef CA53_NEON_ADDR_S53
`undef CA53_NEON_ADDR_S54
`undef CA53_NEON_ADDR_S55
`undef CA53_NEON_ADDR_S56
`undef CA53_NEON_ADDR_S57
`undef CA53_NEON_ADDR_S58
`undef CA53_NEON_ADDR_S59
`undef CA53_NEON_ADDR_S60
`undef CA53_NEON_ADDR_S61
`undef CA53_NEON_ADDR_S62
`undef CA53_NEON_ADDR_S63
`undef CA53_SEL_FML_A_W
`undef CA53_SEL_FML_A_ZERO
`undef CA53_SEL_FML_A_FR0
`undef CA53_SEL_FML_B_W
`undef CA53_SEL_FML_B_ZERO
`undef CA53_SEL_FML_B_FR1
`undef CA53_SEL_FML_C_W
`undef CA53_SEL_FML_C_ZERO
`undef CA53_SEL_FML_C_FR2
`undef CA53_SEL_FAD_A_W
`undef CA53_SEL_FAD_A_ZERO
`undef CA53_SEL_FAD_A_FR2
`undef CA53_SEL_FAD_A_TWO
`undef CA53_SEL_FAD_A_THREE
`undef CA53_SEL_FAD_A_TRN32
`undef CA53_SEL_FAD_B_W
`undef CA53_SEL_FAD_B_ZERO
`undef CA53_SEL_FAD_B_FR1
`undef CA53_SEL_FAD_B_IMM
`undef CA53_SEL_FAD_B_FML_Q
`undef CA53_SEL_FAD_B_TRN32
`undef CA53_SEL_FAD_B_STR
`undef CA53_SEL_FAD_C_W
`undef CA53_SEL_FAD_C_ZERO
`undef CA53_SEL_FAD_C_FR0
`undef CA53_SEL_FAD_C_IMM
`undef CA53_FWD_FNULL
`undef CA53_FWD_ZERO
`undef CA53_FWD_FW0_F3
`undef CA53_FWD_FW1_F3
`undef CA53_FWD_FW0_F4
`undef CA53_FWD_FW1_F4
`undef CA53_FWD_FW0_F5
`undef CA53_FWD_FW1_F5
`undef CA53_FP_FORMAT_F32
`undef CA53_FP_FORMAT_F64
`undef CA53_FP_FORMAT_F16_B
`undef CA53_FP_FORMAT_F16_T
`undef CA53_FP_FORMAT_S16
`undef CA53_FP_FORMAT_U16
`undef CA53_FP_FORMAT_S32
`undef CA53_FP_FORMAT_U32
`undef CA53_FPEXC_W
`undef CA53_FPEXC_EN_BITS
`undef CA53_FPEXC_ST_EN_BITS
`undef CA53_FPSCR_ARCH_NZCV_BITS
`undef CA53_FPSCR_ARCH_QC_BITS
`undef CA53_FPSCR_ARCH_AHP_BITS
`undef CA53_FPSCR_ARCH_DN_BITS
`undef CA53_FPSCR_ARCH_FZ_BITS
`undef CA53_FPSCR_ARCH_RMODE_BITS
`undef CA53_FPSCR_ARCH_STRIDE_BITS
`undef CA53_FPSCR_ARCH_LEN_BITS
`undef CA53_FPSCR_ARCH_IDC_BITS
`undef CA53_FPSCR_ARCH_IXC_BITS
`undef CA53_FPSCR_ARCH_UFC_BITS
`undef CA53_FPSCR_ARCH_OFC_BITS
`undef CA53_FPSCR_ARCH_DZC_BITS
`undef CA53_FPSCR_ARCH_IOC_BITS
`undef CA53_FPEXC_ARCH_EN_BITS
`undef CA53_FPSCR_W
`undef CA53_FPSCR_FP_BITS
`undef CA53_FPSCR_QC_BITS
`undef CA53_FPSCR_NZCV_BITS
`undef CA53_FPSCR_AHP_BITS
`undef CA53_FPSCR_DN_BITS
`undef CA53_FPSCR_FZ_BITS
`undef CA53_FPSCR_RMODE_BITS
`undef CA53_FPSCR_CONFIG_BITS
`undef CA53_FPSCR_FP_XFLAGS_BITS
`undef CA53_FPSCR_IDC_BITS
`undef CA53_FPSCR_IXC_BITS
`undef CA53_FPSCR_UFC_BITS
`undef CA53_FPSCR_OFC_BITS
`undef CA53_FPSCR_DZC_BITS
`undef CA53_FPSCR_IOC_BITS
`undef CA53_XFLAGS_W
`undef CA53_XFLAGS_QC_BITS
`undef CA53_XFLAGS_IDC_BITS
`undef CA53_XFLAGS_IXC_BITS
`undef CA53_XFLAGS_UFC_BITS
`undef CA53_XFLAGS_OFC_BITS
`undef CA53_XFLAGS_DZC_BITS
`undef CA53_XFLAGS_IOC_BITS
`undef CA53_XFLAGS_FP_BITS
`undef CA53_FP_CFLAG_SRC_W
`undef CA53_FP_CFLAG_SRC_FPSCR
`undef CA53_FP_CFLAG_SRC_ALU
`undef CA53_FP_XFLAG_SRC_W
`undef CA53_FP_XFLAG_SRC_FPSCR
`undef CA53_FP_XFLAG_SRC_MUL
`undef CA53_FP_XFLAG_SRC_ALU
`undef CA53_FP_RMODE_W
`undef CA53_FP_RMODE_0
`undef CA53_FP_RMODE_RN
`undef CA53_FP_RMODE_RP
`undef CA53_FP_RMODE_RM
`undef CA53_FP_RMODE_RZ
`undef CA53_FP_RMODE_RA
`undef CA53_FP_RMODE_RX
`undef CA53_FP_RMODE_NEON
`undef CA53_FP_RMODE_FPCR
`undef CA53_FP_OP_W
`undef CA53_FP_OP_0
`undef CA53_FP_OP_ADD
`undef CA53_FP_OP_SUB
`undef CA53_FP_OP_ABD
`undef CA53_FP_OP_CMP
`undef CA53_FP_OP_CMPE
`undef CA53_FP_OP_ACMPE
`undef CA53_FP_OP_MOV
`undef CA53_FP_OP_ABS
`undef CA53_FP_OP_NEG
`undef CA53_FP_OP_RINT
`undef CA53_FP_OP_RINTX
`undef CA53_FP_OP_MAX
`undef CA53_FP_OP_MAXNM
`undef CA53_FP_OP_MIN
`undef CA53_FP_OP_MINNM
`undef CA53_FP_OP_F2H_B
`undef CA53_FP_OP_F2H_T
`undef CA53_FP_OP_H2F_B
`undef CA53_FP_OP_H2F_T
`undef CA53_FP_OP_I2S
`undef CA53_FP_OP_I2D
`undef CA53_FP_OP_S2I
`undef CA53_FP_OP_D2I
`undef CA53_FP_OP_D2FP
`undef CA53_FP_OP_S2D
`undef CA53_FP_OP_D2S
`undef CA53_FP_OP_RSB
`undef CA53_FP_OP_HADD
`undef CA53_FP_OP_RECPX
`undef CA53_NEON_FCTN_W
`undef CA53_NEON_FCTN_0
`undef CA53_NEON_FCTN_FP
`undef CA53_NEON_FCTN_PERM
`undef CA53_NEON_FCTN_ADDSUBHN
`undef CA53_NEON_FCTN_TBL_TBX
`undef CA53_NEON_FCTN_TBX_FINAL
`undef CA53_NEON_FCTN_SWAP_MAX
`undef CA53_NEON_FCTN_CMP
`undef CA53_NEON_FCTN_SHIFT
`undef CA53_NEON_FCTN_NONE
`undef CA53_NEON_FCTN_CLS
`undef CA53_NEON_FCTN_CNT
`undef CA53_NEON_FCTN_ACCUM
`undef CA53_NEON_FCTN_PERM_FB
`undef CA53_NEON_FCTN_RND_SHIFT
`undef CA53_NEON_FCTN_INS_SHIFT
`undef CA53_NEON_FCTN_SHA256SU0
`undef CA53_NEON_FCTN_RBIT
`undef CA53_NEON_FCTN_SHA1H
`undef CA53_NEON_FCTN_SHA1SU0
`undef CA53_NEON_FCTN_ADDV
`undef CA53_NEON_FCTN_MAXV
`undef CA53_NEON_FCTN_MINV
`undef CA53_NEON_MUX_SEL_W
`undef CA53_NEON_MUX_SEL_0
`undef CA53_NEON_MUX_SEL_AU
`undef CA53_NEON_MUX_SEL_LU
`undef CA53_NEON_MUX_SEL_CLZ
`undef CA53_NEON_MUX_SEL_PMUL
`undef CA53_NEON_MUX_SEL_MAXMIN
`undef CA53_NEON_MUX_SEL_FMAXMIN
`undef CA53_CRYPTO_OP_W
`undef CA53_CRYPTO_OP_0
`undef CA53_CRYPTO_OP_AESD
`undef CA53_CRYPTO_OP_AESE
`undef CA53_CRYPTO_OP_AESMC
`undef CA53_CRYPTO_OP_AESIMC
`undef CA53_CRYPTO_OP_AESD_AESIMC
`undef CA53_CRYPTO_OP_AESE_AESMC
`undef CA53_CRYPTO_OP_PMULL64
`undef CA53_CRYPTO_OP_SHA1C
`undef CA53_CRYPTO_OP_SHA1P
`undef CA53_CRYPTO_OP_SHA1M
`undef CA53_CRYPTO_OP_SHA1SU1
`undef CA53_CRYPTO_OP_SHA256H
`undef CA53_CRYPTO_OP_SHA256H2
`undef CA53_CRYPTO_OP_SHA256SU1
`undef CA53_FP_EX_PIPE_ADD0
`undef CA53_FP_EX_PIPE_ADD1
`undef CA53_FP_EX_PIPE_MUL0
`undef CA53_FP_EX_PIPE_MUL1
`undef CA53_FP_EX_PIPE_W
`undef CA53_FP_ADD_VECTOR_FP_OP_W
`undef CA53_FP_ADD_VECTOR_FP_OP_BITS
`undef CA53_FP_ADD_FP_OP_W
`undef CA53_FP_ADD_FP_OP_BITS
`undef CA53_FP_NEON_ADD_NEON_INT_SEL_W
`undef CA53_FP_NEON_ADD_NEON_INT_SEL_BITS
`undef CA53_FP_NEON_ADD_NEON_MUX_SEL_W
`undef CA53_FP_NEON_ADD_NEON_MUX_SEL_BITS
`undef CA53_FP_NEON_ADD_LU_CTL_W
`undef CA53_FP_NEON_ADD_LU_CTL_BITS
`undef CA53_FP_NEON_ADD_SIZE_SEL_W
`undef CA53_FP_NEON_ADD_SIZE_SEL_BITS
`undef CA53_FP_NEON_ADD_PERM_SEL_W
`undef CA53_FP_NEON_ADD_PERM_SEL_BITS
`undef CA53_FP_NEON_ADD_VTB_CYCLE_W
`undef CA53_FP_NEON_ADD_VTB_CYCLE_BITS
`undef CA53_FP_NEON_ADD_UNSIGNED_OP_W
`undef CA53_FP_NEON_ADD_UNSIGNED_OP_BITS
`undef CA53_FP_NEON_ADD_FCTN_SEL_W
`undef CA53_FP_NEON_ADD_FCTN_SEL_BITS
`undef CA53_FP_NEON_ADD_WIDTH_OP_SEL_W
`undef CA53_FP_NEON_ADD_WIDTH_OP_SEL_BITS
`undef CA53_FP_NEON_ADD_SAT_OP_SEL_W
`undef CA53_FP_NEON_ADD_SAT_OP_SEL_BITS
`undef CA53_FP_NEON_ADD_VTST_OP_SEL_W
`undef CA53_FP_NEON_ADD_VTST_OP_SEL_BITS
`undef CA53_FP_NEON_ADD_MASK_SEL_W
`undef CA53_FP_NEON_ADD_MASK_SEL_BITS
`undef CA53_FP_MUL_NEG_SQRT_W
`undef CA53_FP_MUL_NEG_SQRT_BITS
`undef CA53_FP_MUL_DIVIDE_W
`undef CA53_FP_MUL_DIVIDE_BITS
`undef CA53_FP_MUL_PRECISION_W
`undef CA53_FP_MUL_PRECISION_BITS
`undef CA53_FP_MUL_FUSED_MAC_W
`undef CA53_FP_MUL_FUSED_MAC_BITS
`undef CA53_FP_MUL_NEON_VECTOR_OP_W
`undef CA53_FP_MUL_NEON_VECTOR_OP_BITS
`undef CA53_FP_MUL_NEON_INT_OP_W
`undef CA53_FP_MUL_NEON_INT_OP_BITS
`undef CA53_FP_MUL_NEON_FIXUP_W
`undef CA53_FP_MUL_NEON_FIXUP_BITS
`undef CA53_FP_MUL_NEON_SAT_DBL_W
`undef CA53_FP_MUL_NEON_SAT_DBL_BITS
`undef CA53_FP_MUL_NEON_ROUND_W
`undef CA53_FP_MUL_NEON_ROUND_BITS
`undef CA53_FP_MUL_NEON_TYPE_W
`undef CA53_FP_MUL_NEON_TYPE_BITS
`undef CA53_FP_MUL_NEON_OUT_FMT_W
`undef CA53_FP_MUL_NEON_OUT_FMT_BITS
`undef CA53_FP_MUL_NEON_INV_IS_ZERO_W
`undef CA53_FP_MUL_NEON_INV_IS_ZERO_BITS
`undef CA53_NEON_VLD_PERM_EN_W
`undef CA53_NEON_VLD_PERM_EN_BITS
`undef CA53_NEON_VLD_DUP_W
`undef CA53_NEON_VLD_DUP_BITS
`undef CA53_NEON_VLD_PERM_SELECT_LO_W
`undef CA53_NEON_VLD_PERM_SELECT_LO_BITS
`undef CA53_NEON_VLD_PERM_SELECT_HI_W
`undef CA53_NEON_VLD_PERM_SELECT_HI_BITS
`undef CA53_FP_NEON_ADD_CTL_W
`undef CA53_FP_ADD_CTL_W
`undef CA53_FP_NEON_MUL_CTL_W
`undef CA53_FP_MUL_CTL_W
`undef CA53_NEON_VLD_CTL_W
`undef CA53_FP_PIPECTL_RMODE_W
`undef CA53_FP_PIPECTL_RMODE_BITS
`undef CA53_FP_PIPECTL_FORCE_DN_FZ_W
`undef CA53_FP_PIPECTL_FORCE_DN_FZ_BITS
`undef CA53_FP_PIPECTL_TOP_W
`undef CA53_FP_PIPECTL_W
`undef CA53_FP_PIPECTL_TOP_BITS
`undef CA53_FP_PIPECTL_MUL_CTL_BITS
`undef CA53_FP_PIPECTL_ADD_CTL_BITS
`undef CA53_NEON_LD_PERM_8_0
`undef CA53_NEON_LD_PERM_8_1
`undef CA53_NEON_LD_PERM_8_2
`undef CA53_NEON_LD_PERM_8_3
`undef CA53_NEON_LD_PERM_16_0
`undef CA53_NEON_LD_PERM_16_1
`undef CA53_NEON_LD_PERM_16_2
`undef CA53_NEON_LD_PERM_16_3
`undef CA53_NEON_LD_PERM_32_0
`undef CA53_NEON_LD_PERM_32_1
`undef CA53_NEON_LD_PERM_32_2
`undef CA53_NEON_LD_PERM_32_3
`undef CA53_NEON_LD_PERM_64
`undef CA53_NEON_MUL_TYPE_I8
`undef CA53_NEON_MUL_TYPE_I16
`undef CA53_NEON_MUL_TYPE_I16_LO
`undef CA53_NEON_MUL_TYPE_I16_HI
`undef CA53_NEON_MUL_TYPE_I32
`undef CA53_NEON_MUL_TYPE_I32_LO
`undef CA53_NEON_MUL_OUT_FMT_64
`undef CA53_NEON_MUL_OUT_FMT_32_L
`undef CA53_NEON_MUL_OUT_FMT_32_H
`undef CA53_NEON_MUL_OUT_FMT_4_8
`undef CA53_NEON_MUL_OUT_FMT_4_16
`undef CA53_NEON_MUL_OUT_FMT_2_32
`undef CA53_NEON_MUL_OUT_FMT_2_16_H
`undef CA53_NEON_MUL_OUT_FMT_VREC
`undef CA53_NEON_SAT_NONE
`undef CA53_NEON_SAT_ADD
`undef CA53_NEON_SAT_SHF_SIGNED
`undef CA53_NEON_SAT_SHF_UNSIGNED
`undef CA53_NEON_SAT_SUQADD
`undef CA53_NEON_SAT_USQADD
`undef CA53_NEON_SAT_MAXV
`undef CA53_NEON_SAT_MINV
`undef CA53_NEON_LU_AND
`undef CA53_NEON_LU_BIC
`undef CA53_NEON_LU_BIF
`undef CA53_NEON_LU_BIT
`undef CA53_NEON_LU_BSL
`undef CA53_NEON_LU_EOR
`undef CA53_NEON_LU_MOV
`undef CA53_NEON_LU_MVN
`undef CA53_NEON_LU_ORN
`undef CA53_NEON_LU_ORR
`undef CA53_NEON_LU_VCGT
`undef CA53_NEON_LU_VCEQ
/*END*/

`endif
