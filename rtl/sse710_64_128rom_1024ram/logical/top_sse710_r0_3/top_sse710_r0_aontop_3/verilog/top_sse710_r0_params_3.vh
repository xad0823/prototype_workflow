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

  parameter         SOC_RST_DLY               = 1,
  parameter         CLUSTOP_CORE_RST_DLY      = 0,
  
  parameter         HOST_EXP_ROM_ENTRY        = 32'h00000000,
 
  parameter         EXT_SYS0_ROM_ENTRY        = 32'h001D0017,
 
  parameter         EXT_SYS1_ROM_ENTRY        = 32'h002D0027,
 

 
  parameter         MHU_HES00_NUM_CH          = 7'd2,
  parameter         MHU_ES0H0_NUM_CH          = 7'd2,
    parameter         MHU_HES01_NUM_CH          = 7'd2,
  parameter         MHU_ES0H1_NUM_CH          = 7'd2,
   
  parameter         MHU_HES10_NUM_CH          = 7'd2,
  parameter         MHU_ES1H0_NUM_CH          = 7'd2,
    parameter         MHU_HES11_NUM_CH          = 7'd2,
  parameter         MHU_ES1H1_NUM_CH          = 7'd2,
   
  parameter         MHU_HSE0_NUM_CH           = 7'd2,
  parameter         MHU_SEH0_NUM_CH           = 7'd2,

  parameter         MHU_HSE1_NUM_CH           = 7'd2,
  parameter         MHU_SEH1_NUM_CH           = 7'd2,
  
 
  parameter         MHU_SEES00_NUM_CH         = 7'd2,
  parameter         MHU_ES0SE0_NUM_CH         = 7'd2,
    parameter         MHU_SEES01_NUM_CH         = 7'd2,
  parameter         MHU_ES0SE1_NUM_CH         = 7'd2,
   
  parameter         MHU_SEES10_NUM_CH         = 7'd2,
  parameter         MHU_ES1SE0_NUM_CH         = 7'd2,
    parameter         MHU_SEES11_NUM_CH         = 7'd2,
  parameter         MHU_ES1SE1_NUM_CH         = 7'd2,
   
  parameter         DEV_PREQ_DLY_DBG          = 0, 
  parameter         PCSM_PREQ_DLY_DBG         = 0, 
  parameter         ISO_CLKEN_DLY_CFG_DBG     = 0, 
  parameter         CLKEN_RST_DLY_CFG_DBG     = 0, 
  parameter         RST_HWSTAT_DLY_CFG_DBG    = 0, 
  parameter         CLKEN_ISO_DLY_CFG_DBG     = 0, 
  parameter         ISO_RST_DLY_CFG_DBG       = 0, 
                                                                 
  parameter         DEV_PREQ_DLY_SYS          = 0, 
  parameter         PCSM_PREQ_DLY_SYS         = 0, 
  parameter         ISO_CLKEN_DLY_CFG_SYS     = 0, 
  parameter         CLKEN_RST_DLY_CFG_SYS     = 0, 
  parameter         RST_HWSTAT_DLY_CFG_SYS    = 0, 
  parameter         CLKEN_ISO_DLY_CFG_SYS     = 0, 
  parameter         ISO_RST_DLY_CFG_SYS       = 0, 
                                                                 
  parameter         DEV_PREQ_DLY_SECENC       = 0, 
  parameter         PCSM_PREQ_DLY_SECENC      = 0, 
  parameter         ISO_CLKEN_DLY_CFG_SECENC  = 0, 
  parameter         CLKEN_RST_DLY_CFG_SECENC  = 0, 
  parameter         RST_HWSTAT_DLY_CFG_SECENC = 0, 
  parameter         CLKEN_ISO_DLY_CFG_SECENC  = 0, 
  parameter         ISO_RST_DLY_CFG_SECENC    = 0, 
                                                                 
  parameter         DEV_PREQ_DLY_FWRAM        = 0, 
  parameter         PCSM_PREQ_DLY_FWRAM       = 0, 
  parameter         ISO_CLKEN_DLY_CFG_FWRAM   = 0, 
  parameter         CLKEN_RST_DLY_CFG_FWRAM   = 0, 
  parameter         RST_HWSTAT_DLY_CFG_FWRAM  = 0, 
  parameter         CLKEN_ISO_DLY_CFG_FWRAM   = 0, 
  parameter         ISO_RST_DLY_CFG_FWRAM     = 0, 
                                                                 
  parameter         DEV_PREQ_DLY_CLUS         = 1, 
  parameter         PCSM_PREQ_DLY_CLUS        = 1, 
  parameter         ISO_CLKEN_DLY_CFG_CLUS    = 0, 
  parameter         CLKEN_RST_DLY_CFG_CLUS    = 0, 
  parameter         RST_HWSTAT_DLY_CFG_CLUS   = 0, 
  parameter         CLKEN_ISO_DLY_CFG_CLUS    = 0, 
  parameter         ISO_RST_DLY_CFG_CLUS      = 0, 

  parameter         DEV_PREQ_DLY_CPU0         = 1,     
  parameter         PCSM_PREQ_DLY_CPU0        = 1,
  parameter         ISO_CLKEN_DLY_CFG_CPU0    = 0,
  parameter         CLKEN_RST_DLY_CFG_CPU0    = 0,
  parameter         RST_HWSTAT_DLY_CFG_CPU0   = 0,
  parameter         CLKEN_ISO_DLY_CFG_CPU0    = 0,
  parameter         ISO_RST_DLY_CFG_CPU0      = 0,   


  parameter         DEV_PREQ_DLY_CPU1         = 1,      
  parameter         PCSM_PREQ_DLY_CPU1        = 1,     
  parameter         ISO_CLKEN_DLY_CFG_CPU1    = 0, 
  parameter         CLKEN_RST_DLY_CFG_CPU1    = 0, 
  parameter         RST_HWSTAT_DLY_CFG_CPU1   = 0,
  parameter         CLKEN_ISO_DLY_CFG_CPU1    = 0, 
  parameter         ISO_RST_DLY_CFG_CPU1      = 0,   


  parameter         DEV_PREQ_DLY_CPU2         = 1,      
  parameter         PCSM_PREQ_DLY_CPU2        = 1,     
  parameter         ISO_CLKEN_DLY_CFG_CPU2    = 0, 
  parameter         CLKEN_RST_DLY_CFG_CPU2    = 0, 
  parameter         RST_HWSTAT_DLY_CFG_CPU2   = 0,
  parameter         CLKEN_ISO_DLY_CFG_CPU2    = 0, 
  parameter         ISO_RST_DLY_CFG_CPU2      = 0,   


  parameter         DEV_PREQ_DLY_CPU3         = 1,      
  parameter         PCSM_PREQ_DLY_CPU3        = 1,     
  parameter         ISO_CLKEN_DLY_CFG_CPU3    = 0, 
  parameter         CLKEN_RST_DLY_CFG_CPU3    = 0, 
  parameter         RST_HWSTAT_DLY_CFG_CPU3   = 0,
  parameter         CLKEN_ISO_DLY_CFG_CPU3    = 0, 
  parameter         ISO_RST_DLY_CFG_CPU3      = 0,   

 
  
  parameter         FW2SYSTOP_FIFO_DEPTH      = 4,
  parameter         FW2DBGTOP_FIFO_DEPTH      = 4,
                                                                 
  parameter         CPU_AW_FIFO_DEPTH         = 4,
  parameter         CPU_W_FIFO_DEPTH          = 6,
  parameter         CPU_B_FIFO_DEPTH          = 2,
  parameter         CPU_AR_FIFO_DEPTH         = 4,
  parameter         CPU_R_FIFO_DEPTH          = 6,
                                                                 
  parameter         GIC_AW_FIFO_DEPTH         = 4,
  parameter         GIC_W_FIFO_DEPTH          = 6,
  parameter         GIC_B_FIFO_DEPTH          = 2,
  parameter         GIC_AR_FIFO_DEPTH         = 4,
  parameter         GIC_R_FIFO_DEPTH          = 6,


  parameter         EXT_SYS0_MEM_AW_FIFO_DEPTH = 4,
  parameter         EXT_SYS0_MEM_W_FIFO_DEPTH  = 6,
  parameter         EXT_SYS0_MEM_B_FIFO_DEPTH  = 2,
  parameter         EXT_SYS0_MEM_AR_FIFO_DEPTH = 4,
  parameter         EXT_SYS0_MEM_R_FIFO_DEPTH  = 6,


  parameter         EXT_SYS1_MEM_AW_FIFO_DEPTH = 4,
  parameter         EXT_SYS1_MEM_W_FIFO_DEPTH  = 6,
  parameter         EXT_SYS1_MEM_B_FIFO_DEPTH  = 2,
  parameter         EXT_SYS1_MEM_AR_FIFO_DEPTH = 4,
  parameter         EXT_SYS1_MEM_R_FIFO_DEPTH  = 6,

  
  parameter         SECENC_AW_FIFO_DEPTH      = 2,
  parameter         SECENC_W_FIFO_DEPTH       = 2,
  parameter         SECENC_B_FIFO_DEPTH       = 2,
  parameter         SECENC_AR_FIFO_DEPTH      = 2,
  parameter         SECENC_R_FIFO_DEPTH       = 2,
                                                                 
  parameter         FW_AXI_AW_FIFO_DEPTH      = 2,
  parameter         FW_AXI_W_FIFO_DEPTH       = 2,
  parameter         FW_AXI_B_FIFO_DEPTH       = 2,
  parameter         FW_AXI_AR_FIFO_DEPTH      = 2,
  parameter         FW_AXI_R_FIFO_DEPTH       = 2,
                                                                 
  parameter         DBG_AW_FIFO_DEPTH         = 2,
  parameter         DBG_W_FIFO_DEPTH          = 6,
  parameter         DBG_B_FIFO_DEPTH          = 2,
  parameter         DBG_AR_FIFO_DEPTH         = 2,
  parameter         DBG_R_FIFO_DEPTH          = 2,
                                                                 
  parameter         STM_AW_FIFO_DEPTH         = 2,
  parameter         STM_W_FIFO_DEPTH          = 2,
  parameter         STM_B_FIFO_DEPTH          = 2,
  parameter         STM_AR_FIFO_DEPTH         = 2,
  parameter         STM_R_FIFO_DEPTH          = 2,
                                                                 
  parameter         IIDR_PRODUCT_ID           = 12'h762,
  parameter         IIDR_VARIANT_ID           = 4'h0,
  parameter         IIDR_REVISION             = 4'h0,
  parameter         IIDR_IMPLEMENTER          = 12'h43b,
                                                                 
  parameter         CAAON2CA_WIDTH            = 289, 
  parameter         CA2CAAON_WIDTH            = 300  
