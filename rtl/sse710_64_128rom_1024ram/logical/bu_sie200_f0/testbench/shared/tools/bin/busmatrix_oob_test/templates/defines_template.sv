// *********************************************************************
//  The confidential and proprietary information contained in this file may
//  only be used by a person authorised under and to the extent permitted
//  by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//             (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
//                 ALL RIGHTS RESERVED
//
//  This entire notice must be reproduced on all copies of this file
//  and copies of this file may only be made by a person if such person is
//  permitted to do so under the terms of a subsisting license agreement
//  from ARM Limited or its affiliates.
//
//   Revision            : 3ed9556
//   Checked In          : Mon Sep 12 15:21:46 2016 +0100
//
//   Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
// *********************************************************************

`define NUM_AHB5_MASTERS <master_num>
`define NUM_AHB5_SLAVES <slave_num>

localparam ADDR_WIDTH = <address_width>;
localparam DATA_WIDTH = <data_width>;
localparam REMAP_WIDTH = <remap_width>;
localparam MASTER_WIDTH = <master_width>;
localparam USER_WIDTH = <user_width>;
localparam HSEL_WIDTH = 1;
localparam EXCL_THREAD_ID_WIDTH = 4;
localparam DATA_BYTES = 4;



