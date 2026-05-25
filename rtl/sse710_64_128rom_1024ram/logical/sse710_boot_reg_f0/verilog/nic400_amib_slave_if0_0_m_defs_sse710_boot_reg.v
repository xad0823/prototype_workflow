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



`define ID_WIDTH 10
`define ADDR_BUS_MAX 31
`define AWUSER_WIDTH 0
`define WUSER_WIDTH 0
`define BUSER_WIDTH 0
`define ARUSER_WIDTH 0
`define RUSER_WIDTH 0
`define AXVALID_WIDTH 1
`define DATA_WIDTH_SLAVE  32
`define DATA_WIDTH_MASTER 32

`define RS_REGD            0            
`define RS_FWD_REG         1            
`define RS_REV_REG         2            
`define RS_STATIC_BYPASS   3            


`define    AMIB_S0_REGION        4'b0000
`define    AMIB_S1_REGION        4'b0001
`define    AMIB_S2_REGION        4'b0010
`define    AMIB_S3_REGION        4'b0011
`define    AMIB_S4_REGION        4'b0100
`define    AMIB_S5_REGION        4'b0101
`define    AMIB_S6_REGION        4'b0110
`define    AMIB_S7_REGION        4'b0111
`define    AMIB_S8_REGION        4'b1000
`define    AMIB_S9_REGION        4'b1001
`define    AMIB_S10_REGION       4'b1010
`define    AMIB_S11_REGION       4'b1011
`define    AMIB_S12_REGION       4'b1100
`define    AMIB_S13_REGION       4'b1101
`define    AMIB_S14_REGION       4'b1110
`define    AMIB_S15_REGION       4'b1111

`define    AMIB_AXI_ST_IDLE                   2'b00
`define    AMIB_AXI_ST_APB_TRANSFER           2'b01
`define    AMIB_AXI_ST_WAIT_DREADY            2'b10
`define    AMIB_AXI_ST_WAIT_WVALID_OR_DREADY  2'b11
`define    AMIB_AXI_ST_X                      2'bXX

`define    AMIB_APB_ST_IDLE       2'b00
`define    AMIB_APB_ST_PSEL       2'b01
`define    AMIB_APB_ST_PENABLE    2'b10
`define    AMIB_APB_ST_UNKNOWN_3  2'b11
`define    AMIB_APB_ST_X          2'bXX

`define    APBAS_ST_IDLE         2'b00
`define    APBAS_ST_SETUP        2'b01
`define    APBAS_ST_ACCESS       2'b10
`define    APBAS_ST_ACK          2'b11
`define    APBAS_ST_X            2'bXX




