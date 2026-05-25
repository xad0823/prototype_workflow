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

///////////////////////////////////////////////////////////////////////////////
// FIXED FOR SSE710, NOT CUSTOMER MODIFIABLE SECTION
///////////////////////////////////////////////////////////////////////////////

// ********************************************************************
// REGION CONFIGURATION PARAMETERS - valid when FC_PE_LVL = 1 only
// ********************************************************************

// External Debug
localparam [24:0] FIREWALL_F0_CFG_SSE710_DBGPERIPH_FC_RGN0_BASE_ADDR = 25'h0000000;
localparam [24:0] FIREWALL_F0_CFG_SSE710_DBGPERIPH_FC_RGN0_UPR_ADDR  = {25{1'b1}};
localparam [7:0]  FIREWALL_F0_CFG_SSE710_DBGPERIPH_FC_RGN0_SIZE      = 8'h19; 
localparam        FIREWALL_F0_CFG_SSE710_DBGPERIPH_FC_RGN0_MULNPO2   = 1'b0; 


