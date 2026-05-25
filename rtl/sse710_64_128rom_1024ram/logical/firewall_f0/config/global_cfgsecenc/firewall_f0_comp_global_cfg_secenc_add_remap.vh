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


`include "firewall_f0_comp_user_cfg_secenc_add_remap.vh"
localparam [0:0] FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_MST_ID0_VAL = FIREWALL_F0_CFG_GLOBAL_SECENC_FC_MST_ID0_VAL;

localparam [31:0] FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_ERR_RESP_PER_MST_ID0 = FIREWALL_F0_CFG_GLOBAL_SECENC_ERR_RESP_PER_MST_ID0_VAL; 

localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_PE_LVL            = 2; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_TE_LVL            = 2; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_RSE_LVL           = 0; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_ME_LVL            = 2; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_NUM_RGN           = 8; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_MNRS              = 7; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_MXRS              = 32; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_NUM_MPE           = 1; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_ID                = 1; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_SINGLE_MST        = 1; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_ADDR_WIDTH        = 32; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FW_NUM_FC            = 1; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_LOG2_FW_NUM_FC       = 1; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_AXIDATA_WIDTH     = 32; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_AXIID_WIDTH       = 1; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_MST_ID_WIDTH      = 1; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_MST_ID_SINGLE_MST = 0; 

localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FW_SRE_LVL       =  0;     
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FW_LDE_LVL       =  0;     
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FW_MAX_MST_ID_WIDTH  =  1 ;     


localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FW_SE_LVL           = 1;            
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_NUM_FE           = 1;            
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_NUM_EDR          = 1;            
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_SEC_SPT          = 1;            
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_MA_SPT           = 1;            
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_SH_SPT           = 0;            
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_INST_SPT         = 1;            
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_PRIV_SPT         = 1;            
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_CFG_DATA_W       = 32;           




localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_NUM_READ_OS      = 4; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_NUM_WRITE_OS     = 4; 

localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_AW_REG_SLC_S  = 0; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_W_REG_SLC_S   = 0; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_B_REG_SLC_S   = 0; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_AR_REG_SLC_S  = 0; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_R_REG_SLC_S   = 0; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_AW_REG_SLC_M  = 3; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_W_REG_SLC_M   = 3; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_B_REG_SLC_M   = 3; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_AR_REG_SLC_M  = 3; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_R_REG_SLC_M   = 3; 
localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_BAS_REG_SLC   = 3; 

localparam   FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_AXIUSER_AR_WIDTH = 1; 
localparam   FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_AXIUSER_AW_WIDTH = 1; 
localparam   FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_AXIUSER_W_WIDTH  = 1; 
localparam   FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_AXIUSER_R_WIDTH  = 1; 
localparam   FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_AXIUSER_B_WIDTH  = 1; 

localparam FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_NUM_MST_ID = 1; 

localparam [0:0] FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_MST_ID_VAL  = {
    FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_MST_ID0_VAL
};

localparam [31:0] FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_ERR_RESP_PER_MST_ID  = {
    FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_ERR_RESP_PER_MST_ID0
};

localparam [31:0] FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_ERR_RESP_DEF = 32'hdeaddead;  
