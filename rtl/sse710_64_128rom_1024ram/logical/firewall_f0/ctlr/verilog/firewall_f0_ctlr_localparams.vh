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

`include "firewall_f0_log2.vh"
`include "firewall_f0_ceil_divide.vh"

localparam REG_ADDR_WIDTH = 10;
localparam REG_DATA_WIDTH = 32;

localparam MSG_SIZE = 45;
localparam LOG2_MSG_SIZE = firewall_f0_log2(MSG_SIZE);
localparam MAX_NUM_OF_PKTS = firewall_f0_ceil_divide(MSG_SIZE, FC_CFG_DATA_W);
localparam MSG_SIZE_WIDTH = firewall_f0_log2(MAX_NUM_OF_PKTS);

localparam LOG2_REG_DATA_WIDTH = firewall_f0_log2(REG_DATA_WIDTH);

localparam READ_DATA_SIZE = LOG2_REG_DATA_WIDTH+1;

localparam IRQ_TYPE_WIDTH = 5;

localparam LOG2_FC_NUM_RGN = firewall_f0_log2(FC_NUM_RGN);

localparam REG_ENUM_WIDTH = 126;

localparam CHECK_TYPE_WIDTH = 3;

localparam TOTAL_FC = FW_NUM_FC+1;

localparam SRAM_WIDTH = 32;
localparam LOG2_SRAM_WIDTH = firewall_f0_log2(SRAM_WIDTH);

localparam TRACKER_PAYLOAD_WIDTH_AR = 1;
localparam TRACKER_PAYLOAD_WIDTH_AW = 1;
