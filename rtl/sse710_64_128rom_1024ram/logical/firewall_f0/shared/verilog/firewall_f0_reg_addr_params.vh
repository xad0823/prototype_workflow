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

parameter LD_CTRL_ADDR   = 12'h010,
parameter PE_CTRL_ADDR   = 12'h100,
parameter PE_ST_ADDR     = 12'h104,
parameter PE_BPS_ADDR    = 12'h108,
parameter RWE_CTRL_ADDR  = 12'h10C,
parameter RGN_CTRL0_ADDR = 12'h110,
parameter RGN_CTRL1_ADDR = 12'h114,
parameter RGN_LCTRL_ADDR = 12'h118,
parameter RGN_ST_ADDR    = 12'h11C,
parameter RGN_CFG0_ADDR  = 12'h120,
parameter RGN_CFG1_ADDR  = 12'h124,
parameter RGN_SIZE_ADDR  = 12'h128,
parameter RGN_TCFG0_ADDR = 12'h130,
parameter RGN_TCFG1_ADDR = 12'h134,
parameter RGN_TCFG2_ADDR = 12'h138,
parameter RGN_MID0_ADDR  = 12'h140,
parameter RGN_MPL0_ADDR  = 12'h144,
parameter RGN_MID1_ADDR  = 12'h148,
parameter RGN_MPL1_ADDR  = 12'h14C,
parameter RGN_MID2_ADDR  = 12'h150,
parameter RGN_MPL2_ADDR  = 12'h154,
parameter RGN_MID3_ADDR  = 12'h158,
parameter RGN_MPL3_ADDR  = 12'h15C,
parameter FE_TAL_ADDR    = 12'h180,
parameter FE_TAU_ADDR    = 12'h184,
parameter FE_TP_ADDR     = 12'h188,
parameter FE_MID_ADDR    = 12'h18C,
parameter FE_CTRL_ADDR   = 12'h190,
parameter ME_CTRL_ADDR   = 12'h200,
parameter ME_ST_ADDR     = 12'h204,
parameter EDR_TAL_ADDR   = 12'h260,
parameter EDR_TAU_ADDR   = 12'h264,
parameter EDR_TP_ADDR    = 12'h268,
parameter EDR_MID_ADDR   = 12'h26C,
parameter EDR_CTRL_ADDR  = 12'h270,
parameter FC_CAP0_ADDR   = 12'hFA0,
parameter FC_CAP1_ADDR   = 12'hFA4,
parameter FC_CAP2_ADDR   = 12'hFA8,
parameter FC_CAP3_ADDR   = 12'hFAC,
parameter FC_CFG0_ADDR   = 12'hFB0,
parameter FC_CFG1_ADDR   = 12'hFB4,
parameter FC_CFG2_ADDR   = 12'hFB8,
parameter FC_CFG3_ADDR   = 12'hFBC,
