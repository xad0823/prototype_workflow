//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------





`define STATE_ADN   4'b0000
`define STATE_MID   4'b0001
`define STATE_CTL   4'b0010
`define STATE_ADR1  4'b0011
`define STATE_ADR2  4'b0100
`define STATE_DAT0  4'b0101
`define STATE_DAT1  4'b0110
`define STATE_DAT2  4'b0111
`define STATE_DAT3  4'b1000
`define STATE_WAIT  4'b1001
`define STATE_IDLE  4'b1010

`define STATE_PSEL     4'b1001
`define STATE_PENABLE  4'b1010

`define STATE_U4_B  4'b1011
`define STATE_U4_C  4'b1100
`define STATE_U4_D  4'b1101
`define STATE_U4_E  4'b1110
`define STATE_U4_F  4'b1111

`define STATE_U4_X  4'bXXXX

`define STATE_RB_IDLE   2'b00
`define STATE_RB_RWAIT  2'b10
`define STATE_RB_RVALID 2'b11
`define STATE_RB_BVALID 2'b01

`define STATE_U2_X  2'bXX


`define PL301_RSB_FIFO_0_0 3'd0
`define PL301_RSB_FIFO_0_1 3'd1
`define PL301_RSB_FIFO_0_2 3'd3
`define PL301_RSB_FIFO_0_3 3'd2
`define PL301_RSB_FIFO_1_0 3'd6
`define PL301_RSB_FIFO_1_1 3'd7
`define PL301_RSB_FIFO_1_2 3'd5
`define PL301_RSB_FIFO_1_3 3'd4
`define PL301_RSB_FIFO_X_X {3{1'bx}}

