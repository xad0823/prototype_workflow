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


parameter FW_LDE_LVL           = 0  , 
parameter FW_SRE_LVL           = 1  , 
parameter FW_MAX_MST_ID_WIDTH  = 8 , 
parameter FW_CFG_AGENT_MST_ID  = 0     , 
parameter FW_NUM_FC            = 13  , 
parameter LOG2_FW_NUM_FC       = 4     , 
parameter FC_AXIID_WIDTH       = 8     , 
parameter FC_MST_ID_WIDTH      = 8  , 
parameter FC_ADDR_WIDTH        = 21    , 
parameter FC_RSE_LVL           = 1  , 
parameter FC_SINGLE_MST        = 1  , 
parameter FC_MXRS              = 21 , 
parameter FC_MST_ID_SINGLE_MST = 0 ,  

parameter FC_PE_LVL           = 1           , 
parameter FC_TE_LVL           = 0           , 
parameter FC_ME_LVL           = 0           , 
parameter FW_SE_LVL           = 1           , 
parameter FC_NUM_FE           = 1              , 
parameter FC_NUM_EDR          = 0              , 
parameter FC_ID               = 0           , 
parameter FC_NUM_READ_OS      = 1              , 
parameter FC_NUM_WRITE_OS     = 1              , 
parameter FC_AXIDATA_WIDTH    = 32             , 
parameter FC_AXIUSER_R_WIDTH  = 1              , 
parameter FC_AXIUSER_B_WIDTH  = 1              , 
parameter FC_CFG_DATA_W       = 32             , 
parameter FC_NUM_RGN          = 3           , 
parameter FC_NUM_MPE          = 1         , 
parameter FC_MNRS             = 7          , 
parameter FC_SEC_SPT          = 1           , 
parameter FC_MA_SPT           = 1           , 
parameter FC_SH_SPT           = 0           , 
parameter FC_INST_SPT         = 1           , 
parameter FC_PRIV_SPT         = 1           , 



parameter [FC_MXRS*FC_NUM_RGN-1:0] FC_RGN_BASE_ADDR = {FC_NUM_RGN*FC_MXRS{1'b0}},
parameter [FC_MXRS*FC_NUM_RGN-1:0] FC_RGN_UPR_ADDR  = {FC_NUM_RGN*FC_MXRS{1'b1}},
parameter [8*FC_NUM_RGN-1:0] FC_RGN_SIZE      = {FC_NUM_RGN{8'h15}} ,
parameter [1*FC_NUM_RGN-1:0] FC_RGN_MULNPO2   = {FC_NUM_RGN{1'b1}},


parameter [(32*FW_NUM_FC)-1:0] FC_MST_ID_WIDTH_EXT = {32'd8, 32'd8, 32'd8, 32'd8, 32'd8, 32'd8, 32'd8, 32'd8, 32'd8, 32'd8, 32'd8, 32'd8, 32'd8}, 
parameter [FW_NUM_FC*5-1:0] FC_ID_EXT        = {5'hD, 5'hC, 5'hB, 5'hA, 5'h9, 5'h8, 5'h7, 5'h6, 5'h5, 5'h4, 5'h3, 5'h2, 5'h1}  , 
parameter [FW_NUM_FC-1:0] FC_SINGLE_MST_EXT  = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0}  , 
parameter [(2*FW_NUM_FC)-1:0] FC_PE_LVL_EXT   = {2'h2, 2'h1, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h0, 2'h2, 2'h2, 2'h1, 2'h1} , 
parameter [(2*FW_NUM_FC)-1:0] FC_TE_LVL_EXT   = {2'h0, 2'h0, 2'h0, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0} , 
parameter [FW_NUM_FC-1:0] FC_RSE_LVL_EXT      = {1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0} , 
parameter [(2*FW_NUM_FC)-1:0] FC_ME_LVL_EXT   = {2'h0, 2'h0, 2'h0, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h0, 2'h0, 2'h0, 2'h0} , 
parameter [(7*FW_NUM_FC)-1:0] FC_NUM_RGN_EXT  = {7'h40, 7'h40, 7'h20, 7'h20, 7'h20, 7'h10, 7'h10, 7'h8, 7'h1, 7'h40, 7'h40, 7'h28, 7'h1E} , 
parameter [(7*FW_NUM_FC)-1:0] FC_MNRS_EXT     = {7'h7, 7'h3, 7'h7, 7'h7, 7'h7, 7'h7, 7'h7, 7'h7, 7'h3, 7'h3, 7'h7, 7'h7, 7'h7}, 
parameter [(7*FW_NUM_FC)-1:0] FC_MXRS_EXT     = {7'h1F, 7'h20, 7'h20, 7'h20, 7'h20, 7'h20, 7'h20, 7'h20, 7'h20, 7'h19, 7'h1C, 7'h17, 7'h1D} , 
parameter [(3*FW_NUM_FC)-1:0] FC_NUM_MPE_EXT  = {3'h4, 3'h4, 3'h4, 3'h4, 3'h4, 3'h1, 3'h1, 3'h2, 3'h1, 3'h4, 3'h4, 3'h1, 3'h1} , 
parameter [FW_NUM_FC-1:0] FC_SEC_SPT_EXT      = {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1} , 
parameter [FW_NUM_FC-1:0] FC_MA_SPT_EXT       = {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1} , 
parameter [FW_NUM_FC-1:0] FC_SH_SPT_EXT       = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0} , 
parameter [FW_NUM_FC-1:0] FC_INST_SPT_EXT     = {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1} , 
parameter [FW_NUM_FC-1:0] FC_PRIV_SPT_EXT     = {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1} , 
parameter [(32*FW_NUM_FC)-1:0] FC_MST_ID_SINGLE_MST_EXT = {32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0}, 

parameter [64*FW_NUM_FC*64-1:0] FC_RGN_BASE_ADDR_EXT = {FW_NUM_FC*64*64{1'b0}},
parameter [64*FW_NUM_FC*64-1:0] FC_RGN_UPR_ADDR_EXT  = {FW_NUM_FC*64*64{1'b1}},
parameter [8*FW_NUM_FC*64-1:0] FC_RGN_SIZE_EXT      = {FW_NUM_FC*64*8{1'b1}} ,
parameter [1*FW_NUM_FC*64-1:0] FC_RGN_MULNPO2_EXT   = {FW_NUM_FC*64{1'b0}},



parameter FC_AW_REG_SLC_S  = 3 , 
parameter FC_W_REG_SLC_S   = 3 , 
parameter FC_B_REG_SLC_S   = 3 , 
parameter FC_AR_REG_SLC_S  = 3 , 
parameter FC_R_REG_SLC_S   = 3 , 

parameter FC_BAS_REG_SLC = 3,  

parameter FC_NUM_MST_ID = 4, 
parameter [FC_MST_ID_WIDTH*FC_NUM_MST_ID-1:0] FC_MST_ID_VAL = {FC_NUM_MST_ID*FC_MST_ID_WIDTH{1'h0}},           
parameter [FC_AXIDATA_WIDTH*FC_NUM_MST_ID-1:0] FC_ERR_RESP_PER_MST_ID = {FC_NUM_MST_ID*FC_AXIDATA_WIDTH{1'h0}}, 
parameter [FC_AXIDATA_WIDTH-1:0] FC_ERR_RESP_DEF = {FC_AXIDATA_WIDTH{1'h0}},  

parameter FW_RAM_ROWS  = 0
