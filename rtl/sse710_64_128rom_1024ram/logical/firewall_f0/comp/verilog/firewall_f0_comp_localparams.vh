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

localparam LOG2_FC_NUM_RGN = firewall_f0_log2(FC_NUM_RGN);

localparam REG_ADDR_WIDTH      = 10;
localparam REG_DATA_WIDTH      = 32;
localparam LOG2_REG_DATA_WIDTH = firewall_f0_log2(REG_DATA_WIDTH);

localparam SRAM_WIDTH = 32;

localparam READ_DATA_SIZE = LOG2_REG_DATA_WIDTH + 1;

localparam IRQ_TYPE_WIDTH = 5;

localparam MSG_TYPE_WIDTH      = 3;
localparam MSG_TYPE_READ       = 3'b000;
localparam MSG_TYPE_WRITE      = 3'b001;
localparam MSG_TYPE_CONNECT    = 3'b010;
localparam MSG_TYPE_DISCONNECT = 3'b011;
localparam MSG_TYPE_IRQ        = 3'b100;

localparam MSG_NOFRMT_SIZE = 32;

localparam MSG_SIZE = 35;

localparam MAX_NUM_OF_PKTS = firewall_f0_ceil_divide(MSG_SIZE, FC_CFG_DATA_W);

localparam MSG_SIZE_WIDTH = firewall_f0_log2(MAX_NUM_OF_PKTS);

localparam READ_MSG_HDR_SIZE = 3;

localparam ME1_TRK_W = FC_MST_ID_WIDTH + 3; 
localparam ME2_TRK_W = FC_MST_ID_WIDTH + FC_ADDR_WIDTH + 3; 
localparam ME1_TRK_W_SM = 3 ;  
localparam ME2_TRK_W_SM = FC_ADDR_WIDTH + 3;

localparam TRACKER_PAYLOAD_WIDTH_AR = (FC_ME_LVL==0) ? 1 : 
                                                     ((FC_SINGLE_MST == 1) ? ((FC_ME_LVL==1) ? ME1_TRK_W_SM : ME2_TRK_W_SM) :  
                                                                             ((FC_ME_LVL==1) ? ME1_TRK_W : ME2_TRK_W));


localparam TRACKER_PAYLOAD_WIDTH_AW = (FC_ME_LVL==0) ? 1 : 
                                                     ((FC_SINGLE_MST == 1) ? ((FC_ME_LVL==1) ? ME1_TRK_W_SM : ME2_TRK_W_SM) :  
                                                                             ((FC_ME_LVL==1) ? ME1_TRK_W : ME2_TRK_W));
