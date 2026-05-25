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

parameter FW_CTRL_ADDR      = 12'h000,
parameter FW_ST_ADDR        = 12'h004,
parameter FW_SR_CTRL_ADDR   = 12'h00C,
parameter FC0_INT_ST_ADDR   = 12'hD00,
parameter FC1_INT_ST_ADDR   = 12'hD04,
parameter FC2_INT_ST_ADDR   = 12'hD08,
parameter FC3_INT_ST_ADDR   = 12'hD0C,
parameter FC4_INT_ST_ADDR   = 12'hD10,
parameter FC5_INT_ST_ADDR   = 12'hD14,
parameter FC6_INT_ST_ADDR   = 12'hD18,
parameter FC7_INT_ST_ADDR   = 12'hD1C,
parameter FC8_INT_ST_ADDR   = 12'hD20,
parameter FC9_INT_ST_ADDR   = 12'hD24,
parameter FC10_INT_ST_ADDR  = 12'hD28,
parameter FC11_INT_ST_ADDR  = 12'hD2C,
parameter FC12_INT_ST_ADDR  = 12'hD30,
parameter FC13_INT_ST_ADDR  = 12'hD34,
parameter FC14_INT_ST_ADDR  = 12'hD38,
parameter FC15_INT_ST_ADDR  = 12'hD3C,
parameter FC16_INT_ST_ADDR  = 12'hD40,
parameter FC17_INT_ST_ADDR  = 12'hD44,
parameter FC18_INT_ST_ADDR  = 12'hD48,
parameter FC19_INT_ST_ADDR  = 12'hD4C,
parameter FC20_INT_ST_ADDR  = 12'hD50,
parameter FC21_INT_ST_ADDR  = 12'hD54,
parameter FC22_INT_ST_ADDR  = 12'hD58,
parameter FC23_INT_ST_ADDR  = 12'hD5C,
parameter FC24_INT_ST_ADDR  = 12'hD60,
parameter FC25_INT_ST_ADDR  = 12'hD64,
parameter FC26_INT_ST_ADDR  = 12'hD68,
parameter FC27_INT_ST_ADDR  = 12'hD6C,
parameter FC28_INT_ST_ADDR  = 12'hD70,
parameter FC29_INT_ST_ADDR  = 12'hD74,
parameter FC30_INT_ST_ADDR  = 12'hD78,
parameter FC31_INT_ST_ADDR  = 12'hD7C,
parameter FW_INT_ST_ADDR    = 12'hD90,
parameter FC0_INT_MSK_ADDR  = 12'hE00,
parameter FC1_INT_MSK_ADDR  = 12'hE04,
parameter FC2_INT_MSK_ADDR  = 12'hE08,
parameter FC3_INT_MSK_ADDR  = 12'hE0C,
parameter FC4_INT_MSK_ADDR  = 12'hE10,
parameter FC5_INT_MSK_ADDR  = 12'hE14,
parameter FC6_INT_MSK_ADDR  = 12'hE18,
parameter FC7_INT_MSK_ADDR  = 12'hE1C,
parameter FC8_INT_MSK_ADDR  = 12'hE20,
parameter FC9_INT_MSK_ADDR  = 12'hE24,
parameter FC10_INT_MSK_ADDR = 12'hE28,
parameter FC11_INT_MSK_ADDR = 12'hE2C,
parameter FC12_INT_MSK_ADDR = 12'hE30,
parameter FC13_INT_MSK_ADDR = 12'hE34,
parameter FC14_INT_MSK_ADDR = 12'hE38,
parameter FC15_INT_MSK_ADDR = 12'hE3C,
parameter FC16_INT_MSK_ADDR = 12'hE40,
parameter FC17_INT_MSK_ADDR = 12'hE44,
parameter FC18_INT_MSK_ADDR = 12'hE48,
parameter FC19_INT_MSK_ADDR = 12'hE4C,
parameter FC20_INT_MSK_ADDR = 12'hE50,
parameter FC21_INT_MSK_ADDR = 12'hE54,
parameter FC22_INT_MSK_ADDR = 12'hE58,
parameter FC23_INT_MSK_ADDR = 12'hE5C,
parameter FC24_INT_MSK_ADDR = 12'hE60,
parameter FC25_INT_MSK_ADDR = 12'hE64,
parameter FC26_INT_MSK_ADDR = 12'hE68,
parameter FC27_INT_MSK_ADDR = 12'hE6C,
parameter FC28_INT_MSK_ADDR = 12'hE70,
parameter FC29_INT_MSK_ADDR = 12'hE74,
parameter FC30_INT_MSK_ADDR = 12'hE78,
parameter FC31_INT_MSK_ADDR = 12'hE7C,
parameter FW_TMP_TA_ADDR    = 12'hE90,
parameter FW_TMP_TP_ADDR    = 12'hE98,
parameter FW_TMP_MID_ADDR   = 12'hE9C,
parameter FW_TMP_CTRL_ADDR  = 12'hEA0,
parameter IIDR_ADDR         = 12'hFC8,
parameter AIDR_ADDR         = 12'hFCC,
parameter PID4_ADDR         = 12'hFD0,
parameter PID0_ADDR         = 12'hFE0,
parameter PID1_ADDR         = 12'hFE4,
parameter PID2_ADDR         = 12'hFE8,
parameter PID3_ADDR         = 12'hFEC,
parameter CID0_ADDR         = 12'hFF0,
parameter CID1_ADDR         = 12'hFF4,
parameter CID2_ADDR         = 12'hFF8,
parameter CID3_ADDR         = 12'hFFC
