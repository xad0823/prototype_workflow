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

parameter FC_PE_LVL            = 1 , 
parameter FC_TE_LVL            = 0 , 
parameter FC_RSE_LVL           = 1 , 
parameter FC_ME_LVL            = 0 , 
parameter FC_NUM_RGN           = 4 , 
parameter FC_MNRS              = 7'h02 , 
parameter FC_MXRS              = 7'h08 , 
parameter FC_NUM_MPE           = 4 , 
parameter FC_ID                = 1 , 
parameter FC_SINGLE_MST        = 1 , 
parameter FC_ADDR_WIDTH        = 64, 
parameter FW_NUM_FC            = 13, 
parameter LOG2_FW_NUM_FC       = 4,  
parameter FC_AXIDATA_WIDTH     = 64, 
parameter FC_AXIID_WIDTH       = 9 , 
parameter FC_MST_ID_WIDTH      = 8,  
parameter FC_MST_ID_SINGLE_MST = 0 ,  
parameter FC_AXI_READ_RESP_INTRLV = 1, 

parameter FW_SRE_LVL          = 1 , 
parameter FW_LDE_LVL          = 0 , 
parameter FW_MAX_MST_ID_WIDTH = 8 , 


parameter [FC_MXRS*FC_NUM_RGN-1:0] FC_RGN_BASE_ADDR = {FC_NUM_RGN*FC_MXRS{1'b0}},
parameter [FC_MXRS*FC_NUM_RGN-1:0] FC_RGN_UPR_ADDR  = {FC_NUM_RGN*FC_MXRS{1'b1}},
parameter [8*FC_NUM_RGN-1:0] FC_RGN_SIZE      = {FC_NUM_RGN{8'h05}} ,
parameter [1*FC_NUM_RGN-1:0] FC_RGN_MULNPO2   = {FC_NUM_RGN{1'b0}},



parameter FW_SE_LVL           = 1              , 
parameter FC_NUM_FE           = 1              , 
parameter FC_NUM_EDR          = 1              , 
parameter FC_SEC_SPT          = 1              , 
parameter FC_MA_SPT           = 1              , 
parameter FC_SH_SPT           = 0              , 
parameter FC_INST_SPT         = 1              , 
parameter FC_PRIV_SPT         = 1              , 
parameter FC_CFG_DATA_W       = 32             , 


parameter FC_NUM_READ_OS      = 16, 
parameter FC_NUM_WRITE_OS     = 16, 

parameter FC_AW_REG_SLC_S  = 0 , 
parameter FC_W_REG_SLC_S   = 0 , 
parameter FC_B_REG_SLC_S   = 0 , 
parameter FC_AR_REG_SLC_S  = 0 , 
parameter FC_R_REG_SLC_S   = 0 , 
parameter FC_AW_REG_SLC_M  = 0 , 
parameter FC_W_REG_SLC_M   = 0 , 
parameter FC_B_REG_SLC_M   = 0 , 
parameter FC_AR_REG_SLC_M  = 0 , 
parameter FC_R_REG_SLC_M   = 0 , 

parameter FC_AXIUSER_AR_WIDTH = 1, 
parameter FC_AXIUSER_AW_WIDTH = 1, 
parameter FC_AXIUSER_W_WIDTH  = 1, 
parameter FC_AXIUSER_R_WIDTH  = 1, 
parameter FC_AXIUSER_B_WIDTH  = 1, 

parameter FC_BAS_REG_SLC = 3,  

parameter FC_NUM_MST_ID = 4, 
parameter [FC_MST_ID_WIDTH*FC_NUM_MST_ID-1:0] FC_MST_ID_VAL = {FC_NUM_MST_ID*FC_MST_ID_WIDTH{1'h0}},           
parameter [FC_AXIDATA_WIDTH*FC_NUM_MST_ID-1:0] FC_ERR_RESP_PER_MST_ID = {FC_NUM_MST_ID*FC_AXIDATA_WIDTH{1'h0}}, 
parameter [FC_AXIDATA_WIDTH-1:0] FC_ERR_RESP_DEF = {FC_AXIDATA_WIDTH{1'h0}}  
