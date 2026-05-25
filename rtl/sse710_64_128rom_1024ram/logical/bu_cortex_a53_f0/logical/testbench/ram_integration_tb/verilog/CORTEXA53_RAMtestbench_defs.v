//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2013-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2012-07-30 17:16:48 +0100 (Mon, 30 Jul 2012) $
//
//      Revision            : $Revision: 216970 $
//
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Global defines for CortexA53
//-----------------------------------------------------------------------------

`define DDATARAM_RAM_ID           4'b0000
`define DDATARAM_ADDR_WIDTH       11
`define DDATARAM_RAM_TYPE         2'b00
`define DDATARAM_NUM_BANKS        8
`define DDATARAM_BYTE_WIDTH       8
`define DDATARAM_CHECK_LATENCY    1

`define DTAGRAM_RAM_ID            4'b0001
`define DTAGRAM_ADDR_WIDTH        8
`define DTAGRAM_RAM_TYPE          2'b00
`define DTAGRAM_NUM_BANKS         4
`define DTAGRAM_BYTE_WIDTH        1
`define DTAGRAM_CHECK_LATENCY     1

`define DDIRTYRAM_RAM_ID          4'b0010
`define DDIRTYRAM_ADDR_WIDTH      9
`define DDIRTYRAM_RAM_TYPE        2'b00
`define DDIRTYRAM_NUM_BANKS       1
`define DDIRTYRAM_BYTE_WIDTH      1
`define DDIRTYRAM_CHECK_LATENCY   1

`define IDATARAM_RAM_ID           4'b0011
`define IDATARAM_ADDR_WIDTH       12
`define IDATARAM_RAM_TYPE         2'b00
`define IDATARAM_NUM_BANKS        2
`define IDATARAM_BYTE_WIDTH_ECC   21
`define IDATARAM_BYTE_WIDTH_NOECC 20
`define IDATARAM_CHECK_LATENCY    1

`define ITAGRAM_RAM_ID            4'b0100
`define ITAGRAM_ADDR_WIDTH        9
`define ITAGRAM_RAM_TYPE          2'b00
`define ITAGRAM_NUM_BANKS         2
`define ITAGRAM_BYTE_WIDTH        1
`define ITAGRAM_CHECK_LATENCY     1

`define TLBRAM_RAM_ID             4'b0101
`define TLBRAM_ADDR_WIDTH         8
`define TLBRAM_RAM_TYPE           2'b00
`define TLBRAM_NUM_BANKS          4
`define TLBRAM_BYTE_WIDTH         1
`define TLBRAM_CHECK_LATENCY      1

`define L1DTAGRAM_RAM_ID          4'b0110
`define L1DTAGRAM_ADDR_WIDTH      8
`define L1DTAGRAM_RAM_TYPE        2'b00
`define L1DTAGRAM_NUM_BANKS       4
`define L1DTAGRAM_BYTE_WIDTH      1
`define L1DTAGRAM_CHECK_LATENCY   1

`define L2TAGRAM_RAM_ID           4'b0111
`define L2TAGRAM_ADDR_WIDTH       11
`define L2TAGRAM_RAM_TYPE         2'b00
`define L2TAGRAM_NUM_BANKS        16
`define L2TAGRAM_BYTE_WIDTH       1
`define L2TAGRAM_CHECK_LATENCY    1

`define L2DATARAM_RAM_ID          4'b1000
`define L2DATARAM_ADDR_WIDTH      12
`define L2DATARAM_RAM_TYPE        2'b00
`define L2DATARAM_NUM_BANKS       8
`define L2DATARAM_BYTE_WIDTH      1
`define L2DATARAM_CHECK_LATENCY   1
`define L2_DATARAM_WAYS           8

`define BTACRAM_RAM_STG0_ID       4'b1001
`define BTACRAM_ADDR_WIDTH        7
`define BTACRAM_RAM_TYPE          2'b00
`define BTACRAM_NUM_BANKS         1
`define BTACRAM_BYTE_WIDTH        1
`define BTACRAM_CHECK_LATENCY     1

`define BTACRAM_RAM_STG1_ID       4'b1010

`define L2VICTIMRAM_RAM_ID        4'b1011
`define L2VICTIMRAM_ADDR_WIDTH    11
`define L2VICTIMRAM_RAM_TYPE      2'b00
`define L2VICTIMRAM_NUM_BANKS     1
`define L2VICTIMRAM_BYTE_WIDTH    2
`define L2VICTIMRAM_CHECK_LATENCY 1

