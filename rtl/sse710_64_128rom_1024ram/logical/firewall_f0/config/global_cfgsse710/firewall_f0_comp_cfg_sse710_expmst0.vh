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




 .FC_PE_LVL              (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_PE_LVL            ),  
 .FC_TE_LVL              (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_TE_LVL            ),  
 .FC_RSE_LVL             (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_RSE_LVL           ),  
 .FC_ME_LVL              (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_ME_LVL            ),  
 .FC_NUM_RGN             (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_NUM_RGN           ),  
 .FC_MNRS                (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_MNRS              ),  
 .FC_MXRS                (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_MXRS              ),  
 .FC_NUM_MPE             (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_NUM_MPE           ),  
 .FC_ID                  (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_ID                ),  
 .FC_SINGLE_MST          (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_SINGLE_MST        ),  
 .FC_ADDR_WIDTH          (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_ADDR_WIDTH        ),  
 .FW_NUM_FC              (FIREWALL_F0_CFG_SSE710_EXPMST0_FW_NUM_FC            ),  
 .LOG2_FW_NUM_FC         (FIREWALL_F0_CFG_SSE710_EXPMST0_LOG2_FW_NUM_FC       ),  
 .FC_AXIDATA_WIDTH       (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_AXIDATA_WIDTH     ),  
 .FC_AXIID_WIDTH         (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_AXIID_WIDTH       ),  
 .FC_MST_ID_WIDTH        (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_MST_ID_WIDTH      ),  
 .FC_MST_ID_SINGLE_MST   (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_MST_ID_SINGLE_MST ),  

 .FW_SRE_LVL             (FIREWALL_F0_CFG_SSE710_EXPMST0_FW_SRE_LVL),   
 .FW_LDE_LVL             (FIREWALL_F0_CFG_SSE710_EXPMST0_FW_LDE_LVL),   
 .FW_MAX_MST_ID_WIDTH    (FIREWALL_F0_CFG_SSE710_EXPMST0_FW_MAX_MST_ID_WIDTH), 

  .FW_SE_LVL             (FIREWALL_F0_CFG_SSE710_EXPMST0_FW_SE_LVL    ), 
  .FC_NUM_FE             (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_NUM_FE    ), 
  .FC_NUM_EDR            (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_NUM_EDR   ), 
  .FC_SEC_SPT            (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_SEC_SPT   ), 
  .FC_MA_SPT             (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_MA_SPT    ), 
  .FC_SH_SPT             (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_SH_SPT    ), 
  .FC_INST_SPT           (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_INST_SPT  ), 
  .FC_PRIV_SPT           (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_PRIV_SPT  ), 
  .FC_CFG_DATA_W         (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_CFG_DATA_W), 




   .FC_NUM_READ_OS   (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_NUM_READ_OS),  
   .FC_NUM_WRITE_OS  (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_NUM_WRITE_OS), 

   .FC_AW_REG_SLC_S       (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_AW_REG_SLC_S), 
   .FC_W_REG_SLC_S        (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_W_REG_SLC_S ), 
   .FC_B_REG_SLC_S        (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_B_REG_SLC_S ), 
   .FC_AR_REG_SLC_S       (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_AR_REG_SLC_S), 
   .FC_R_REG_SLC_S        (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_R_REG_SLC_S ), 
   .FC_AW_REG_SLC_M       (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_AW_REG_SLC_M), 
   .FC_W_REG_SLC_M        (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_W_REG_SLC_M ), 
   .FC_B_REG_SLC_M        (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_B_REG_SLC_M ), 
   .FC_AR_REG_SLC_M       (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_AR_REG_SLC_M), 
   .FC_R_REG_SLC_M        (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_R_REG_SLC_M ), 
   .FC_BAS_REG_SLC        (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_BAS_REG_SLC ), 

   .FC_AXIUSER_AR_WIDTH   (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_AXIUSER_AR_WIDTH), 
   .FC_AXIUSER_AW_WIDTH   (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_AXIUSER_AW_WIDTH), 
   .FC_AXIUSER_W_WIDTH    (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_AXIUSER_W_WIDTH ), 
   .FC_AXIUSER_R_WIDTH    (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_AXIUSER_R_WIDTH ), 
   .FC_AXIUSER_B_WIDTH    (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_AXIUSER_B_WIDTH ), 

  .FC_NUM_MST_ID          (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_NUM_MST_ID         ), 
  .FC_MST_ID_VAL          (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_MST_ID_VAL         ), 
  .FC_ERR_RESP_PER_MST_ID (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_ERR_RESP_PER_MST_ID), 
  .FC_ERR_RESP_DEF        (FIREWALL_F0_CFG_SSE710_EXPMST0_FC_ERR_RESP_DEF       )  
