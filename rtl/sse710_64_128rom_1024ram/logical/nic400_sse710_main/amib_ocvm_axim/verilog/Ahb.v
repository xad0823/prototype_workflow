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


`define AHB_HTRANS_IDLE       2'b00
`define AHB_HTRANS_BUSY       2'b01
`define AHB_HTRANS_NONSEQ     2'b10
`define AHB_HTRANS_SEQ        2'b11

`define AHB_HSIZE_8           3'b000
`define AHB_HSIZE_16          3'b001
`define AHB_HSIZE_32          3'b010
`define AHB_HSIZE_64          3'b011
`define AHB_HSIZE_128         3'b100
`define AHB_HSIZE_256         3'b101
`define AHB_HSIZE_512         3'b110
`define AHB_HSIZE_1024        3'b111

`define AHB_HBURST_SINGLE     3'b000
`define AHB_HBURST_INCR       3'b001
`define AHB_HBURST_WRAP4      3'b010
`define AHB_HBURST_INCR4      3'b011
`define AHB_HBURST_WRAP8      3'b100
`define AHB_HBURST_INCR8      3'b101
`define AHB_HBURST_WRAP16     3'b110
`define AHB_HBURST_INCR16     3'b111

`define AHB_HPROT_OPCODE      1'b0
`define AHB_HPROT_DATA        1'b1
`define AHB_HPROT_USER        1'b0
`define AHB_HPROT_PRIVILEGED  1'b1

`define AHB_HRESP_OKAY        2'b00
`define AHB_HRESP_ERROR       2'b01
`define AHB_HRESP_RETRY       2'b10
`define AHB_HRESP_SPLIT       2'b11

