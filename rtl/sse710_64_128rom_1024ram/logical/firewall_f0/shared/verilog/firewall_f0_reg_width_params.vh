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

parameter LD_CTRL_WIDTH   = 3,
parameter PE_CTRL_WIDTH   = 7,
parameter PE_ST_WIDTH     = 7,
parameter RWE_CTRL_WIDTH  = 8,
parameter RGN_CTRL0_WIDTH = 1,
parameter RGN_CTRL1_WIDTH = 4,
parameter RGN_LCTRL_WIDTH = 1,
parameter RGN_ST_WIDTH    = 5,
parameter RGN_CFG0_WIDTH  = 27,
parameter RGN_CFG1_WIDTH  = 32,
parameter RGN_SIZE_WIDTH  = 16,  
parameter RGN_TCFG0_WIDTH = 27,
parameter RGN_TCFG1_WIDTH = 32,
parameter RGN_TCFG2_WIDTH = 18,  
parameter RGN_MPL0_WIDTH  = 13,
parameter RGN_MPL1_WIDTH  = 13,
parameter RGN_MPL2_WIDTH  = 13,
parameter RGN_MPL3_WIDTH  = 13,
parameter FE_TAL_WIDTH    = 32,
parameter FE_TAU_WIDTH    = 32,
parameter FE_TP_WIDTH     = 4,
parameter FE_CTRL_WIDTH   = 6,
parameter ME_CTRL_WIDTH   = 3,
parameter ME_ST_WIDTH     = 3,
parameter EDR_TAL_WIDTH   = 32,
parameter EDR_TAU_WIDTH   = 32,
parameter EDR_TP_WIDTH    = 4,
parameter EDR_CTRL_WIDTH  = 3,
parameter FC_CAP0_WIDTH   = 32,
parameter FC_CAP1_WIDTH   = 1,
parameter FC_CAP2_WIDTH   = 1,
parameter FC_CAP3_WIDTH   = 1,
parameter FC_CFG0_WIDTH   = 5,
parameter FC_CFG1_WIDTH   = 18,
parameter FC_CFG2_WIDTH   = 21,
parameter FC_CFG3_WIDTH   = 6,
parameter PROT_SIZE_WIDTH = 8,
parameter BYPASS_WIDTH    = 1,
parameter PE_BPS_WIDTH    = 3
