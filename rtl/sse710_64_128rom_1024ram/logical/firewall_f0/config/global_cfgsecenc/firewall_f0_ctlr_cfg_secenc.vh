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



 .FW_LDE_LVL               (FIREWALL_F0_CFG_SECENC_FW_LDE_LVL          ),  
 .FW_SRE_LVL               (FIREWALL_F0_CFG_SECENC_FW_SRE_LVL          ),  
 .FW_CFG_AGENT_MST_ID      (FIREWALL_F0_CFG_SECENC_FW_CFG_AGENT_MST_ID ),  
 .FW_NUM_FC                (FIREWALL_F0_CFG_SECENC_FW_NUM_FC           ),  
 .FW_MAX_MST_ID_WIDTH      (FIREWALL_F0_CFG_SECENC_FW_MAX_MST_ID_WIDTH ),  
 .LOG2_FW_NUM_FC           (FIREWALL_F0_CFG_SECENC_LOG2_FW_NUM_FC      ),  
 .FC_AXIID_WIDTH           (FIREWALL_F0_CFG_SECENC_FC_AXIID_WIDTH      ),  
 .FC_MST_ID_WIDTH          (FIREWALL_F0_CFG_SECENC_FC_MST_ID_WIDTH     ),  
 .FC_ADDR_WIDTH            (FIREWALL_F0_CFG_SECENC_FC_ADDR_WIDTH       ),  
 .FC_RSE_LVL               (FIREWALL_F0_CFG_SECENC_FC_RSE_LVL          ),  
 .FC_SINGLE_MST            (FIREWALL_F0_CFG_SECENC_FC_SINGLE_MST       ),  
 .FC_MXRS                  (FIREWALL_F0_CFG_SECENC_FC_MXRS             ),  
 .FC_MST_ID_SINGLE_MST     (FIREWALL_F0_CFG_SECENC_FC_MST_ID_SINGLE_MST),  

 .FC_PE_LVL                (FIREWALL_F0_CFG_SECENC_FC_PE_LVL          )  , 
 .FC_TE_LVL                (FIREWALL_F0_CFG_SECENC_FC_TE_LVL          )  , 
 .FC_ME_LVL                (FIREWALL_F0_CFG_SECENC_FC_ME_LVL          )  , 
 .FW_SE_LVL                (FIREWALL_F0_CFG_SECENC_FW_SE_LVL          )  , 
 .FC_NUM_FE                (FIREWALL_F0_CFG_SECENC_FC_NUM_FE          )  , 
 .FC_NUM_EDR               (FIREWALL_F0_CFG_SECENC_FC_NUM_EDR         )  , 
 .FC_ID                    (FIREWALL_F0_CFG_SECENC_FC_ID              )  , 
 .FC_NUM_READ_OS           (FIREWALL_F0_CFG_SECENC_FC_NUM_READ_OS     )  , 
 .FC_NUM_WRITE_OS          (FIREWALL_F0_CFG_SECENC_FC_NUM_WRITE_OS    )  , 
 .FC_AXIDATA_WIDTH         (FIREWALL_F0_CFG_SECENC_FC_AXIDATA_WIDTH   )  , 
 .FC_AXIUSER_R_WIDTH       (FIREWALL_F0_CFG_SECENC_FC_AXIUSER_R_WIDTH )  , 
 .FC_AXIUSER_B_WIDTH       (FIREWALL_F0_CFG_SECENC_FC_AXIUSER_B_WIDTH )  , 
 .FC_CFG_DATA_W            (FIREWALL_F0_CFG_SECENC_FC_CFG_DATA_W      )  , 
 .FC_NUM_RGN               (FIREWALL_F0_CFG_SECENC_FC_NUM_RGN         )  , 
 .FC_NUM_MPE               (FIREWALL_F0_CFG_SECENC_FC_NUM_MPE         )  , 
 .FC_MNRS                  (FIREWALL_F0_CFG_SECENC_FC_MNRS            )  , 
 .FC_SEC_SPT               (FIREWALL_F0_CFG_SECENC_FC_SEC_SPT         )  , 
 .FC_MA_SPT                (FIREWALL_F0_CFG_SECENC_FC_MA_SPT          )  , 
 .FC_SH_SPT                (FIREWALL_F0_CFG_SECENC_FC_SH_SPT          )  , 
 .FC_INST_SPT              (FIREWALL_F0_CFG_SECENC_FC_INST_SPT        )  , 
 .FC_PRIV_SPT              (FIREWALL_F0_CFG_SECENC_FC_PRIV_SPT        )  , 


   .FC_RGN_BASE_ADDR       (FIREWALL_F0_CFG_SECENC_FC_RGN_BASE_ADDR ),
   .FC_RGN_UPR_ADDR        (FIREWALL_F0_CFG_SECENC_FC_RGN_UPR_ADDR  ),
   .FC_RGN_SIZE            (FIREWALL_F0_CFG_SECENC_FC_RGN_SIZE      ),
   .FC_RGN_MULNPO2         (FIREWALL_F0_CFG_SECENC_FC_RGN_MULNPO2   ),

   .FC_AW_REG_SLC_S       (FIREWALL_F0_CFG_SECENC_FC_AW_REG_SLC_S), 
   .FC_W_REG_SLC_S        (FIREWALL_F0_CFG_SECENC_FC_W_REG_SLC_S ), 
   .FC_B_REG_SLC_S        (FIREWALL_F0_CFG_SECENC_FC_B_REG_SLC_S ), 
   .FC_AR_REG_SLC_S       (FIREWALL_F0_CFG_SECENC_FC_AR_REG_SLC_S), 
   .FC_R_REG_SLC_S        (FIREWALL_F0_CFG_SECENC_FC_R_REG_SLC_S ), 
   .FC_BAS_REG_SLC        (FIREWALL_F0_CFG_SECENC_FC_BAS_REG_SLC ), 
   .FW_RAM_ROWS           (FIREWALL_F0_CFG_SECENC_FW_RAM_ROWS ),

   .FC_MST_ID_WIDTH_EXT       (FIREWALL_F0_CFG_SECENC_FC_MST_ID_WIDTH_EXT     ), 
   .FC_ID_EXT                 (FIREWALL_F0_CFG_SECENC_FC_ID_EXT               ), 
   .FC_SINGLE_MST_EXT         (FIREWALL_F0_CFG_SECENC_FC_SINGLE_MST_EXT       ), 
   .FC_PE_LVL_EXT             (FIREWALL_F0_CFG_SECENC_FC_PE_LVL_EXT           ), 
   .FC_TE_LVL_EXT             (FIREWALL_F0_CFG_SECENC_FC_TE_LVL_EXT           ), 
   .FC_RSE_LVL_EXT            (FIREWALL_F0_CFG_SECENC_FC_RSE_LVL_EXT          ), 
   .FC_ME_LVL_EXT             (FIREWALL_F0_CFG_SECENC_FC_ME_LVL_EXT           ), 
   .FC_NUM_RGN_EXT            (FIREWALL_F0_CFG_SECENC_FC_NUM_RGN_EXT          ), 
   .FC_MNRS_EXT               (FIREWALL_F0_CFG_SECENC_FC_MNRS_EXT             ), 
   .FC_MXRS_EXT               (FIREWALL_F0_CFG_SECENC_FC_MXRS_EXT             ), 
   .FC_NUM_MPE_EXT            (FIREWALL_F0_CFG_SECENC_FC_NUM_MPE_EXT          ), 
   .FC_SEC_SPT_EXT            (FIREWALL_F0_CFG_SECENC_FC_SEC_SPT_EXT          ), 
   .FC_MA_SPT_EXT             (FIREWALL_F0_CFG_SECENC_FC_MA_SPT_EXT           ), 
   .FC_SH_SPT_EXT             (FIREWALL_F0_CFG_SECENC_FC_SH_SPT_EXT           ), 
   .FC_INST_SPT_EXT           (FIREWALL_F0_CFG_SECENC_FC_INST_SPT_EXT         ), 
   .FC_PRIV_SPT_EXT           (FIREWALL_F0_CFG_SECENC_FC_PRIV_SPT_EXT         ), 
   .FC_MST_ID_SINGLE_MST_EXT  (FIREWALL_F0_CFG_SECENC_FC_MST_ID_SINGLE_MST_EXT), // 

   .FC_RGN_BASE_ADDR_EXT   (FIREWALL_F0_CFG_SECENC_FC_RGN_BASE_ADDR_EXT),
   .FC_RGN_UPR_ADDR_EXT    (FIREWALL_F0_CFG_SECENC_FC_RGN_UPR_ADDR_EXT ),
   .FC_RGN_SIZE_EXT        (FIREWALL_F0_CFG_SECENC_FC_RGN_SIZE_EXT     ),
   .FC_RGN_MULNPO2_EXT     (FIREWALL_F0_CFG_SECENC_FC_RGN_MULNPO2_EXT  ),

  .FC_NUM_MST_ID           (FIREWALL_F0_CFG_SECENC_FC_NUM_MST_ID         ), 
  .FC_MST_ID_VAL           (FIREWALL_F0_CFG_SECENC_FC_MST_ID_VAL         ), 
  .FC_ERR_RESP_PER_MST_ID  (FIREWALL_F0_CFG_SECENC_FC_ERR_RESP_PER_MST_ID), 
  .FC_ERR_RESP_DEF         (FIREWALL_F0_CFG_SECENC_FC_ERR_RESP_DEF       )  
