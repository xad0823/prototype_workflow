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

`define AHB_TRANS_IDLE   2'b00
`define AHB_TRANS_BUSY   2'b01
`define AHB_TRANS_NONSEQ 2'b10
`define AHB_TRANS_SEQ    2'b11
`define AHB_BURST_SINGLE 3'b000
`define AHB_BURST_INCR   3'b001
`define AHB_BURST_WRAP4  3'b010
`define AHB_BURST_INCR4  3'b011
`define AHB_BURST_WRAP8  3'b100
`define AHB_BURST_INCR8  3'b101
`define AHB_BURST_WRAP16 3'b110
`define AHB_BURST_INCR16 3'b111
`define AHB_RESP_OKAY    2'b00
`define AHB_RESP_ERROR   2'b01
`define AHB_RESP_RETRY   2'b10
`define AHB_RESP_SPLIT   2'b11
`define AHB_SIZE_8       3'b000
`define AHB_SIZE_16      3'b001
`define AHB_SIZE_32      3'b010
`define AHB_SIZE_64      3'b011
`define AHB_SIZE_128     3'b100
`define AHB_SIZE_256     3'b101
`define AHB_SIZE_512     3'b110
`define AHB_SIZE_1024    3'b111


`define AHB_TRANS_NSEQ     `AHB_TRANS_NONSEQ
`define AHB_RESP_OK        `AHB_RESP_OKAY
`define AHB_RESP_ERR       `AHB_RESP_ERROR
`define AHB_SIZE_BYTE      `AHB_SIZE_8
`define AHB_SIZE_HALFWORD  `AHB_SIZE_16
`define AHB_SIZE_HALF_WORD `AHB_SIZE_16
`define AHB_SIZE_WORD      `AHB_SIZE_32

