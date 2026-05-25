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


module pd_systop_f0 #(
  parameter  GLOBAL_ID_WIDTH          = 12,
  parameter  SYS_EGRESS_2_DBG         = 2,
  parameter  HOST_CPU_NUM_CORES       = 4,
  parameter  NUM_EXP_SHD_INT          = 64,
  parameter  NUM_ACLK_QCH             = 1,
  parameter  ATB_DATA_WIDTH           = 32,
  parameter  HOST_CPU_TYPE            = 3,
  parameter  CLUSTOP_CORE_RST_DLY     = 0,

  parameter  EXT_SYS0_TZ_SPT          = 0,  
  parameter  MHU_HES00_NUM_CH         = 7'd2,  
  parameter  MHU_ES0H0_NUM_CH         = 7'd2,  
    parameter  MHU_HES01_NUM_CH         = 7'd2,  
  parameter  MHU_ES0H1_NUM_CH         = 7'd2,  
                                        
  parameter  EXT_SYS0_MEM_ADDR_WIDTH       = 32,
  parameter  EXT_SYS0_MEM_DATA_WIDTH       = 64,
  parameter  EXT_SYS0_MEM_AWID_WIDTH       = 8,
  parameter  EXT_SYS0_MEM_ARID_WIDTH       = 8,
  parameter  EXT_SYS0_MEM_AWUSER_WIDTH     = 0,
  parameter  EXT_SYS0_MEM_WUSER_WIDTH      = 0,
  parameter  EXT_SYS0_MEM_BUSER_WIDTH      = 0,
  parameter  EXT_SYS0_MEM_ARUSER_WIDTH     = 0,
  parameter  EXT_SYS0_MEM_RUSER_WIDTH      = 0,
  parameter  EXT_SYS0_MEM_AW_FIFO_DEPTH    = 4,
  parameter  EXT_SYS0_MEM_W_FIFO_DEPTH     = 6,
  parameter  EXT_SYS0_MEM_B_FIFO_DEPTH     = 2,
  parameter  EXT_SYS0_MEM_AR_FIFO_DEPTH    = 4,
  parameter  EXT_SYS0_MEM_R_FIFO_DEPTH     = 6,
  parameter  EXT_SYS0_MEM_AW_PAYLOAD_WIDTH = 236,
  parameter  EXT_SYS0_MEM_W_PAYLOAD_WIDTH  = 222,
  parameter  EXT_SYS0_MEM_B_PAYLOAD_WIDTH  = 24,
  parameter  EXT_SYS0_MEM_AR_PAYLOAD_WIDTH = 236,
  parameter  EXT_SYS0_MEM_R_PAYLOAD_WIDTH  = 264,

  parameter  EXT_SYS1_TZ_SPT          = 0,  
  parameter  MHU_HES10_NUM_CH         = 7'd2,  
  parameter  MHU_ES1H0_NUM_CH         = 7'd2,  
    parameter  MHU_HES11_NUM_CH         = 7'd2,  
  parameter  MHU_ES1H1_NUM_CH         = 7'd2,  
                                        
  parameter  EXT_SYS1_MEM_ADDR_WIDTH       = 32,
  parameter  EXT_SYS1_MEM_DATA_WIDTH       = 64,
  parameter  EXT_SYS1_MEM_AWID_WIDTH       = 8,
  parameter  EXT_SYS1_MEM_ARID_WIDTH       = 8,
  parameter  EXT_SYS1_MEM_AWUSER_WIDTH     = 0,
  parameter  EXT_SYS1_MEM_WUSER_WIDTH      = 0,
  parameter  EXT_SYS1_MEM_BUSER_WIDTH      = 0,
  parameter  EXT_SYS1_MEM_ARUSER_WIDTH     = 0,
  parameter  EXT_SYS1_MEM_RUSER_WIDTH      = 0,
  parameter  EXT_SYS1_MEM_AW_FIFO_DEPTH    = 4,
  parameter  EXT_SYS1_MEM_W_FIFO_DEPTH     = 6,
  parameter  EXT_SYS1_MEM_B_FIFO_DEPTH     = 2,
  parameter  EXT_SYS1_MEM_AR_FIFO_DEPTH    = 4,
  parameter  EXT_SYS1_MEM_R_FIFO_DEPTH     = 6,
  parameter  EXT_SYS1_MEM_AW_PAYLOAD_WIDTH = 236,
  parameter  EXT_SYS1_MEM_W_PAYLOAD_WIDTH  = 222,
  parameter  EXT_SYS1_MEM_B_PAYLOAD_WIDTH  = 24,
  parameter  EXT_SYS1_MEM_AR_PAYLOAD_WIDTH = 236,
  parameter  EXT_SYS1_MEM_R_PAYLOAD_WIDTH  = 264,


  parameter  XNVM_DATA_WIDTH          = 64, 
  parameter  CVM_DATA_WIDTH           = 64, 
  parameter  OCVM_DATA_WIDTH          = 64, 

  parameter  EXPSLV0_DATA_WIDTH       = 64, 
  parameter  EXPSLV0_ID_WIDTH         = 8, 
  parameter  EXPSLV1_DATA_WIDTH       = 64, 
  parameter  EXPSLV1_ID_WIDTH         = 8, 

  parameter  EXPMST0_DATA_WIDTH       = 64, 
  parameter  EXPMST1_DATA_WIDTH       = 64, 

  parameter  MHU_HSE0_NUM_CH         = 7'd2,    
  parameter  MHU_SEH0_NUM_CH         = 7'd2,    
  parameter  MHU_HSE1_NUM_CH         = 7'd2,    
  parameter  MHU_SEH1_NUM_CH         = 7'd2,    
  
  parameter  SECENC_ADDR_WIDTH       = 32,
  parameter  SECENC_DATA_WIDTH       = 32,
  parameter  SECENC_AWID_WIDTH       = 4,
  parameter  SECENC_ARID_WIDTH       = 4,
  parameter  SECENC_AWUSER_WIDTH     = 0,
  parameter  SECENC_WUSER_WIDTH      = 0,
  parameter  SECENC_BUSER_WIDTH      = 1,
  parameter  SECENC_ARUSER_WIDTH     = 0,
  parameter  SECENC_RUSER_WIDTH      = 1,
  parameter  SECENC_AW_FIFO_DEPTH    = 4,
  parameter  SECENC_W_FIFO_DEPTH     = 6,
  parameter  SECENC_B_FIFO_DEPTH     = 2,
  parameter  SECENC_AR_FIFO_DEPTH    = 4,
  parameter  SECENC_R_FIFO_DEPTH     = 6,
  parameter  SECENC_AW_PAYLOAD_WIDTH = 236,
  parameter  SECENC_W_PAYLOAD_WIDTH  = 222,
  parameter  SECENC_B_PAYLOAD_WIDTH  = 24,
  parameter  SECENC_AR_PAYLOAD_WIDTH = 236,
  parameter  SECENC_R_PAYLOAD_WIDTH  = 264,
  
  parameter DBG_ADDR_WIDTH    = 32,
  parameter DBG_DATA_WIDTH    = 64,
  parameter DBG_AWID_WIDTH    = 4,
  parameter DBG_ARID_WIDTH    = 4,
  parameter DBG_AWUSER_WIDTH  = 2,
  parameter DBG_WUSER_WIDTH   = 0,
  parameter DBG_BUSER_WIDTH   = 1,
  parameter DBG_ARUSER_WIDTH  = 2,
  parameter DBG_RUSER_WIDTH   = 1,
  parameter DBG_AW_FIFO_DEPTH = 4,
  parameter DBG_W_FIFO_DEPTH  = 6,
  parameter DBG_B_FIFO_DEPTH  = 2,
  parameter DBG_AR_FIFO_DEPTH = 4,
  parameter DBG_R_FIFO_DEPTH  = 6,
  parameter DBG_AW_PAYLOAD_WIDTH = 316,
  parameter DBG_W_PAYLOAD_WIDTH  = 870,
  parameter DBG_B_PAYLOAD_WIDTH  = 20,
  parameter DBG_AR_PAYLOAD_WIDTH = 316,
  parameter DBG_R_PAYLOAD_WIDTH  = 834,

  parameter STM_ADDR_WIDTH       = 32,
  parameter STM_DATA_WIDTH       = 32,
  parameter STM_WUSER_WIDTH      = 0,
  parameter STM_BUSER_WIDTH      = 0,
  parameter STM_ARUSER_WIDTH     = 10,
  parameter STM_RUSER_WIDTH      = 0,
  parameter STM_AXI_ID_WIDTH     = GLOBAL_ID_WIDTH,
  parameter STM_AW_FIFO_DEPTH    = 4,
  parameter STM_W_FIFO_DEPTH     = 6,
  parameter STM_B_FIFO_DEPTH     = 2,
  parameter STM_AR_FIFO_DEPTH    = 4,
  parameter STM_R_FIFO_DEPTH     = 6,
  parameter STM_AWUSER_WIDTH     = 10,
  parameter STM_AW_PAYLOAD_WIDTH = 236,
  parameter STM_W_PAYLOAD_WIDTH  = 222,
  parameter STM_B_PAYLOAD_WIDTH  = 24,
  parameter STM_AR_PAYLOAD_WIDTH = 236,
  parameter STM_R_PAYLOAD_WIDTH  = 264,
  
  parameter FW2SYSTOP_FIFO_DEPTH    = 4,
  
  parameter FW_AXI_ADDR_WIDTH       = 32,
  parameter FW_AXI_DATA_WIDTH       = 32,
  parameter FW_AXI_AWID_WIDTH       = 10,
  parameter FW_AXI_ARID_WIDTH       = 10,
  parameter FW_AXI_AWUSER_WIDTH     = 10,
  parameter FW_AXI_WUSER_WIDTH      = 0,
  parameter FW_AXI_BUSER_WIDTH      = 1,
  parameter FW_AXI_ARUSER_WIDTH     = 10,
  parameter FW_AXI_RUSER_WIDTH      = 1,
  parameter FW_AXI_AW_FIFO_DEPTH    = 2,
  parameter FW_AXI_W_FIFO_DEPTH     = 2,
  parameter FW_AXI_B_FIFO_DEPTH     = 2,
  parameter FW_AXI_AR_FIFO_DEPTH    = 2,
  parameter FW_AXI_R_FIFO_DEPTH     = 2,
  parameter FW_AXI_AW_PAYLOAD_WIDTH = 20,
  parameter FW_AXI_W_PAYLOAD_WIDTH  = 20,
  parameter FW_AXI_B_PAYLOAD_WIDTH  = 20,
  parameter FW_AXI_AR_PAYLOAD_WIDTH = 20,
  parameter FW_AXI_R_PAYLOAD_WIDTH  = 20, 
  
  parameter CPU_AW_FIFO_DEPTH       = 4,
  parameter CPU_W_FIFO_DEPTH        = 6,
  parameter CPU_B_FIFO_DEPTH        = 2,
  parameter CPU_AR_FIFO_DEPTH       = 4,
  parameter CPU_R_FIFO_DEPTH        = 6,
  
  parameter GIC_AW_FIFO_DEPTH       = 4,
  parameter GIC_W_FIFO_DEPTH        = 6,
  parameter GIC_B_FIFO_DEPTH        = 2,
  parameter GIC_AR_FIFO_DEPTH       = 4,
  parameter GIC_R_FIFO_DEPTH        = 6,
  
 
  parameter DEV_PREQ_DLY_CPU3        = 1,
  parameter PCSM_PREQ_DLY_CPU3       = 1,
  parameter ISO_CLKEN_DLY_CFG_CPU3   = 0,
  parameter CLKEN_RST_DLY_CFG_CPU3   = 0,
  parameter RST_HWSTAT_DLY_CFG_CPU3  = 0,
  parameter CLKEN_ISO_DLY_CFG_CPU3   = 0,
  parameter ISO_RST_DLY_CFG_CPU3     = 0,
 
  parameter DEV_PREQ_DLY_CPU2        = 1,
  parameter PCSM_PREQ_DLY_CPU2       = 1,
  parameter ISO_CLKEN_DLY_CFG_CPU2   = 0,
  parameter CLKEN_RST_DLY_CFG_CPU2   = 0,
  parameter RST_HWSTAT_DLY_CFG_CPU2  = 0,
  parameter CLKEN_ISO_DLY_CFG_CPU2   = 0,
  parameter ISO_RST_DLY_CFG_CPU2     = 0,
 
  parameter DEV_PREQ_DLY_CPU1        = 1,
  parameter PCSM_PREQ_DLY_CPU1       = 1,
  parameter ISO_CLKEN_DLY_CFG_CPU1   = 0,
  parameter CLKEN_RST_DLY_CFG_CPU1   = 0,
  parameter RST_HWSTAT_DLY_CFG_CPU1  = 0,
  parameter CLKEN_ISO_DLY_CFG_CPU1   = 0,
  parameter ISO_RST_DLY_CFG_CPU1     = 0,
 
  parameter DEV_PREQ_DLY_CPU0        = 1,
  parameter PCSM_PREQ_DLY_CPU0       = 1,
  parameter ISO_CLKEN_DLY_CFG_CPU0   = 0,
  parameter CLKEN_RST_DLY_CFG_CPU0   = 0,
  parameter RST_HWSTAT_DLY_CFG_CPU0  = 0,
  parameter CLKEN_ISO_DLY_CFG_CPU0   = 0,
  parameter ISO_RST_DLY_CFG_CPU0     = 0,

  parameter DEV_PREQ_DLY_CLUS         = 1,
  parameter PCSM_PREQ_DLY_CLUS        = 1,
  parameter ISO_CLKEN_DLY_CFG_CLUS    = 0,
  parameter CLKEN_RST_DLY_CFG_CLUS    = 0,
  parameter RST_HWSTAT_DLY_CFG_CLUS   = 0,
  parameter CLKEN_ISO_DLY_CFG_CLUS    = 0,
  parameter ISO_RST_DLY_CFG_CLUS      = 0

  )(
  
input  wire        refclk,
output wire        refclk_qactive_o,
input  wire        cpu_pll,
input  wire        sys_pll,
input  wire        systop_warmresetn,

output wire        aclkout,
input  wire  [7:0] aclk_ctrl_entrydelay,

input  wire  [4:0] aclk_on_syspll_divratio,
output wire  [4:0] aclk_on_syspll_divratio_cur,
input  wire  [1:0] aclk_clksel,
output wire  [1:0] aclk_clksel_cur,
input  wire        clkforce_st_aclk_force_st,


input  wire  [7:0] ctrlclk_ctrl_entrydelay,

input  wire  [4:0] ctrlclk_on_syspll_divratio,
output wire  [4:0] ctrlclk_on_syspll_divratio_cur,
input  wire  [1:0] ctrlclk_clksel,
output wire  [1:0] ctrlclk_clksel_cur,
input  wire        clkforce_st_ctrlclk_force_st,

input  wire         ppu_dbgen,
output wire  [15:0] clustop_ppuhwstat,

input  wire  [3:0]  hostcpu_corewakeup,
output wire [4:0]   host_lock,

input  wire [63:0] tsvalueb,
input  wire [63:0] host_cntvalueg,
input  wire        host_cntclkout,

input wire    [9:0]     modify_lock_req,
output  wire  [9:0]     modify_lock_ack,


output wire [NUM_ACLK_QCH + 6:0] aclk_qreqn,
input  wire [NUM_ACLK_QCH + 6:0] aclk_qacceptn,
input  wire [NUM_ACLK_QCH + 6:0] aclk_qdeny,
input  wire [NUM_ACLK_QCH + 6:0] aclk_qactive,
                 

input  wire [SYS_EGRESS_2_DBG-1:0] qreqn_systop_egress_dbgtop,
output wire [SYS_EGRESS_2_DBG-1:0] qacceptn_systop_egress_dbgtop,
output wire [SYS_EGRESS_2_DBG-1:0] qdeny_systop_egress_dbgtop,
output wire [SYS_EGRESS_2_DBG-1:0] qactive_systop_egress_dbgtop,

output wire  hostcpu_dbgtrace_egress_comb1_qreqn,
input  wire  hostcpu_dbgtrace_egress_comb1_qacceptn,
input  wire  hostcpu_dbgtrace_egress_comb1_qdeny,

input wire  [1:0] hostcpu_dbgtrace_egress_comb_qreqn,
output wire [1:0] hostcpu_dbgtrace_egress_comb_qacceptn,
output wire [1:0] hostcpu_dbgtrace_egress_comb_qdeny,
output wire [1:0] hostcpu_dbgtrace_egress_comb_qactive,

output wire  hostcpu_dbgtrace_ingress_qreqn,
input  wire  hostcpu_dbgtrace_ingress_qacceptn,
input  wire  hostcpu_dbgtrace_ingress_qdeny,
input  wire  hostcpu_dbgtrace_ingress_qactive,

output  wire  systop_egress_dbgaon_comb1_pwrqreqn,
input   wire  systop_egress_dbgaon_comb1_pwrqacceptn,
input   wire  systop_egress_dbgaon_comb1_pwrqdeny,
input   wire  systop_egress_dbgaon_comb1_pwrqactive,
  
input  wire  [1:0] systop_egress_dbgaon_comb_pwrqreqn,
output wire  [1:0] systop_egress_dbgaon_comb_pwrqacceptn,
output wire  [1:0] systop_egress_dbgaon_comb_pwrqdeny,
output wire  [1:0] systop_egress_dbgaon_comb_pwrqactive,

input  wire [2:0]  qreqn_systop,
output wire [2:0]  qacceptn_systop,
output wire [2:0]  qdeny_systop,
output wire [2:0]  qactive_systop,

input  wire        qreqn_systop_acg,
output wire        qacceptn_systop_acg,
output wire        qdeny_systop_acg,
output wire        qactive_systop_acg,

output wire         hostsysdbg_async_req,
output wire [67:0]  hostsysdbg_async_req_payload,
input  wire [32:0]  hostsysdbg_async_resp_payload,
input  wire         hostsysdbg_async_ack,

output wire         irq_sdc600,
output wire   [7:0] ie_data_sdc600,
output wire         ie_req_sdc600,
input  wire         ie_ack_sdc600,
input  wire         ie_linkup_sdc600,
output wire         ie_linkest_sdc600,
input  wire   [7:0] ei_data_sdc600,
input  wire         ei_req_sdc600,
output wire         ei_ack_sdc600,
output wire         ei_linkup_sdc600,
input  wire         ei_linkest_sdc600,

input  wire         pe0_config_vinithi,
input  wire         pe0_config_cfgte,
input  wire         pe0_config_cfgend,
input  wire         pe1_config_vinithi,
input  wire         pe1_config_cfgte,
input  wire         pe1_config_cfgend,
input  wire         pe2_config_vinithi,
input  wire         pe2_config_cfgte,
input  wire         pe2_config_cfgend,
input  wire         pe3_config_vinithi,
input  wire         pe3_config_cfgte,
input  wire         pe3_config_cfgend,
input  wire         cluster_config_cryptodisable,

input  wire         pe0_config_aa64naa32,
input  wire  [29:0] pe0_rvbaraddr_lw_rvbar31_2,
input  wire  [7:0]  pe0_rvbaraddr_up_rvbar43_32,
input  wire         pe1_config_aa64naa32,
input  wire  [29:0] pe1_rvbaraddr_lw_rvbar31_2,
input  wire  [7:0]  pe1_rvbaraddr_up_rvbar43_32,
input  wire         pe2_config_aa64naa32,
input  wire  [29:0] pe2_rvbaraddr_lw_rvbar31_2,
input  wire  [7:0]  pe2_rvbaraddr_up_rvbar43_32,
input  wire         pe3_config_aa64naa32,
input  wire  [29:0] pe3_rvbaraddr_lw_rvbar31_2,
input  wire  [7:0]  pe3_rvbaraddr_up_rvbar43_32,

input  wire  [3:0]  host_cpu_boot_msk_boot_msk,
input  wire         host_cpu_clus_pwr_req_pwr_req,
input  wire         bsys_pwr_req_wakeup_en,
input  wire         gic_wakeup,
input  wire         hostcpu_cpuwait,
input  wire         axiap_csyspwrupreq_1,
output wire         axiap_csyspwrupack_1,
input  wire         hostrom_cdbgpwrupreq,
output wire         hostrom_cdbgpwrupack,

output wire         host_ppu_int_st_core3_int_st,
output wire         host_ppu_int_st_core2_int_st,
output wire         host_ppu_int_st_core1_int_st,
output wire         host_ppu_int_st_core0_int_st,
output wire         host_ppu_int_st_clustop_int_st,
input  wire         host_cpu_clus_pwr_req_mem_ret_r,
  
   
input  wire [4:0]   hostcpuclk_div1_clkdiv,
output wire [4:0]   hostcpuclk_div1_clkdiv_cur,
input  wire [4:0]   hostcpuclk_div0_clkdiv,
output wire [4:0]   hostcpuclk_div0_clkdiv_cur,
input  wire [2:0]   hostcpuclk_ctrl_clkselect,
output wire [2:0]   hostcpuclk_ctrl_clkselect_cur,
input  wire [4:0]   gicclk_div0_clkdiv,
output wire [4:0]   gicclk_div0_clkdiv_cur,
input  wire [1:0]   gicclk_ctrl_clkselect,
output wire [1:0]   gicclk_ctrl_clkselect_cur,

input wire         mbistreq,
input wire         nmbistreset,
input wire         dftdivsel,
input wire  [1:0]  dftrstdisable,
input wire         dftcgen,
input wire         dftpwrup,
input wire         dftretdisable,
input wire         dftisodisable,

input wire [1:0]   dftgicclksel,
input wire         dftgicclkselen,
input wire         dftgicclkdivbypass,

input wire [2:0]   dfthostcpuclksel,
input wire         dfthostcpuclkselen,
input wire         dfthostcpuclkdivbypass,

input wire [1:0]   dftaclksel,
input wire         dftaclkselen,
input wire         dftaclkdivbypass,

input wire [1:0]   dftctrlclksel,
input wire         dftctrlclkselen,
input wire         dftctrlclkdivbypass,

output wire        clustop_pcsm_preq_o,
output wire [3:0]  clustop_pcsm_pstate_o,
input  wire        clustop_pcsm_paccept_i,
input  wire [3:0]  clustop_pcsm_mode_stat_i,


input  wire [4:0]                    hostcpu_gicintdbgtop, 
input  wire [1:0]                    hostcpu_gicintuart,   
input  wire [NUM_EXP_SHD_INT+32-1:0] hostcpu_gicshdint,    
input  wire [1:0]                    hostcpu_gicintwdogs,  
input  wire                          hostcpu_gicintwdogns, 

output wire [2:0]                    hostcpu_gicintdbgtop_pulse_ack,

input  wire [HOST_CPU_NUM_CORES-1:0] hostcpu_dbgen, 
input  wire [HOST_CPU_NUM_CORES-1:0] hostcpu_spiden, 
input  wire [HOST_CPU_NUM_CORES-1:0] hostcpu_niden, 
input  wire [HOST_CPU_NUM_CORES-1:0] hostcpu_spniden, 

input  wire                          hostcpu_dftramhold, 

input  wire [3:0]         hostcpu_ctichin, 
input  wire [3:0]         hostcpu_ctichoutack, 
output wire [3:0]         hostcpu_ctichout, 
output wire [3:0]         hostcpu_ctichinack, 

input  wire                  hostcpu_dftmcphold, 

input   wire          debug_hostcpu_async_req,
input   wire [67:0]   debug_hostcpu_async_req_payload,
output  wire [32:0]   debug_hostcpu_async_resp_payload,
output  wire          debug_hostcpu_async_ack,

output  wire          extdbg_async_req,
output  wire [67:0]   extdbg_async_req_payload,
input   wire [32:0]   extdbg_async_resp_payload,
input   wire          extdbg_async_ack,

output  wire          aonperiph_async_req,
output  wire [67:0]   aonperiph_async_req_payload,
input   wire [32:0]   aonperiph_async_resp_payload,
input   wire          aonperiph_async_ack,

output  wire          uart_async_req,
output  wire [52:0]   uart_async_req_payload,
input   wire [32:0]   uart_async_resp_payload,
input   wire          uart_async_ack,

output  wire          bootreg_async_req,
output  wire [61:0]   bootreg_async_req_payload,
input   wire [32:0]   bootreg_async_resp_payload,
input   wire          bootreg_async_ack,
  
input  wire            fctrl_bypass,

output wire firewall_slvmustacceptreqn_async,
output wire firewall_slvcandenyreqn_async,
input  wire firewall_slvacceptn_async,
input  wire firewall_slvdeny_async,

output wire firewall_si_to_mi_wakeup_async,
input  wire firewall_mi_to_si_wakeup_async,

output wire [FW_AXI_AW_FIFO_DEPTH-1:0]    firewall_aw_wr_ptr_async,
input  wire [FW_AXI_AW_FIFO_DEPTH-1:0]    firewall_aw_rd_ptr_async,
output wire [FW_AXI_AW_PAYLOAD_WIDTH-1:0] firewall_aw_payld_async,

output wire [FW_AXI_W_FIFO_DEPTH-1:0]     firewall_w_wr_ptr_async,
input  wire [FW_AXI_W_FIFO_DEPTH-1:0]     firewall_w_rd_ptr_async,
output wire [FW_AXI_W_PAYLOAD_WIDTH-1:0]  firewall_w_payld_async,

input  wire [FW_AXI_B_FIFO_DEPTH-1:0]     firewall_b_wr_ptr_async,
output wire [FW_AXI_B_FIFO_DEPTH-1:0]     firewall_b_rd_ptr_async,
input  wire [FW_AXI_B_PAYLOAD_WIDTH-1:0]  firewall_b_payld_async,

output wire [FW_AXI_AR_FIFO_DEPTH-1:0]    firewall_ar_wr_ptr_async,
input  wire [FW_AXI_AR_FIFO_DEPTH-1:0]    firewall_ar_rd_ptr_async,
output wire [FW_AXI_AR_PAYLOAD_WIDTH-1:0] firewall_ar_payld_async,

input  wire [FW_AXI_R_FIFO_DEPTH -1:0]    firewall_r_wr_ptr_async,
output wire [FW_AXI_R_FIFO_DEPTH -1:0]    firewall_r_rd_ptr_async,
input  wire [FW_AXI_R_PAYLOAD_WIDTH-1:0]  firewall_r_payld_async,


output wire        awakeup_xnvm_axim,
output wire [GLOBAL_ID_WIDTH-1:0] awid_xnvm_axim,
output wire [31:0] awaddr_xnvm_axim,
output wire [7:0]  awlen_xnvm_axim,
output wire [2:0]  awsize_xnvm_axim,
output wire [1:0]  awburst_xnvm_axim,
output wire        awlock_xnvm_axim,
output wire [3:0]  awcache_xnvm_axim,
output wire [2:0]  awprot_xnvm_axim,
output wire        awvalid_xnvm_axim,
input wire         awready_xnvm_axim,
output wire [XNVM_DATA_WIDTH-1:0] wdata_xnvm_axim,
output wire [(XNVM_DATA_WIDTH/8)-1:0]  wstrb_xnvm_axim,
output wire        wlast_xnvm_axim,
output wire        wvalid_xnvm_axim,
input wire         wready_xnvm_axim,
input wire  [GLOBAL_ID_WIDTH-1:0] bid_xnvm_axim,
input wire  [1:0]  bresp_xnvm_axim,
input wire         bvalid_xnvm_axim,
output wire        bready_xnvm_axim,
output wire [GLOBAL_ID_WIDTH-1:0] arid_xnvm_axim,
output wire [31:0] araddr_xnvm_axim,
output wire [7:0]  arlen_xnvm_axim,
output wire [2:0]  arsize_xnvm_axim,
output wire [1:0]  arburst_xnvm_axim,
output wire        arlock_xnvm_axim,
output wire [3:0]  arcache_xnvm_axim,
output wire [2:0]  arprot_xnvm_axim,
output wire        arvalid_xnvm_axim,
input wire         arready_xnvm_axim,
input wire  [GLOBAL_ID_WIDTH-1:0] rid_xnvm_axim,
input wire  [XNVM_DATA_WIDTH-1:0] rdata_xnvm_axim,
input wire  [1:0]  rresp_xnvm_axim,
input wire         rlast_xnvm_axim,
input wire         rvalid_xnvm_axim,
output wire        rready_xnvm_axim,
output wire [9:0]  awuser_xnvm_axim,
output wire [9:0]  aruser_xnvm_axim,
output wire [3:0]  awqos_xnvm_axim,
output wire [3:0]  arqos_xnvm_axim,


output wire        awakeup_cvm_axim,
output wire [GLOBAL_ID_WIDTH-1:0] awid_cvm_axim,
output wire [31:0] awaddr_cvm_axim,
output wire [7:0]  awlen_cvm_axim,
output wire [2:0]  awsize_cvm_axim,
output wire [1:0]  awburst_cvm_axim,
output wire        awlock_cvm_axim,
output wire [3:0]  awcache_cvm_axim,
output wire [2:0]  awprot_cvm_axim,
output wire        awvalid_cvm_axim,
input wire         awready_cvm_axim,
output wire [CVM_DATA_WIDTH-1:0] wdata_cvm_axim,
output wire [(CVM_DATA_WIDTH/8)-1:0]  wstrb_cvm_axim,
output wire        wlast_cvm_axim,
output wire        wvalid_cvm_axim,
input wire         wready_cvm_axim,
input wire  [GLOBAL_ID_WIDTH-1:0] bid_cvm_axim,
input wire  [1:0]  bresp_cvm_axim,
input wire         bvalid_cvm_axim,
output wire        bready_cvm_axim,
output wire [GLOBAL_ID_WIDTH-1:0] arid_cvm_axim,
output wire [31:0] araddr_cvm_axim,
output wire [7:0]  arlen_cvm_axim,
output wire [2:0]  arsize_cvm_axim,
output wire [1:0]  arburst_cvm_axim,
output wire        arlock_cvm_axim,
output wire [3:0]  arcache_cvm_axim,
output wire [2:0]  arprot_cvm_axim,
output wire        arvalid_cvm_axim,
input wire         arready_cvm_axim,
input wire  [GLOBAL_ID_WIDTH-1:0] rid_cvm_axim,
input wire  [CVM_DATA_WIDTH-1:0] rdata_cvm_axim,
input wire  [1:0]  rresp_cvm_axim,
input wire         rlast_cvm_axim,
input wire         rvalid_cvm_axim,
output wire        rready_cvm_axim,
output wire [9:0]  awuser_cvm_axim,
output wire [9:0]  aruser_cvm_axim,
output wire [3:0]  awqos_cvm_axim,
output wire [3:0]  arqos_cvm_axim,

 

output wire        awakeup_expmstr0_axim,
output wire [GLOBAL_ID_WIDTH-1:0] awid_expmstr0_axim,
output wire [31:0] awaddr_expmstr0_axim,
output wire [7:0]  awlen_expmstr0_axim,
output wire [2:0]  awsize_expmstr0_axim,
output wire [1:0]  awburst_expmstr0_axim,
output wire        awlock_expmstr0_axim,
output wire [3:0]  awcache_expmstr0_axim,
output wire [2:0]  awprot_expmstr0_axim,
output wire        awvalid_expmstr0_axim,
input wire         awready_expmstr0_axim,
output wire [EXPMST0_DATA_WIDTH-1:0] wdata_expmstr0_axim,
output wire [(EXPMST0_DATA_WIDTH/8)-1:0]  wstrb_expmstr0_axim,
output wire        wlast_expmstr0_axim,
output wire        wvalid_expmstr0_axim,
input wire         wready_expmstr0_axim,
input wire  [GLOBAL_ID_WIDTH-1:0] bid_expmstr0_axim,
input wire  [1:0]  bresp_expmstr0_axim,
input wire         bvalid_expmstr0_axim,
output wire        bready_expmstr0_axim,
output wire [GLOBAL_ID_WIDTH-1:0] arid_expmstr0_axim,
output wire [31:0] araddr_expmstr0_axim,
output wire [7:0]  arlen_expmstr0_axim,
output wire [2:0]  arsize_expmstr0_axim,
output wire [1:0]  arburst_expmstr0_axim,
output wire        arlock_expmstr0_axim,
output wire [3:0]  arcache_expmstr0_axim,
output wire [2:0]  arprot_expmstr0_axim,
output wire        arvalid_expmstr0_axim,
input wire         arready_expmstr0_axim,
input wire  [GLOBAL_ID_WIDTH-1:0] rid_expmstr0_axim,
input wire  [EXPMST0_DATA_WIDTH-1:0] rdata_expmstr0_axim,
input wire  [1:0]  rresp_expmstr0_axim,
input wire         rlast_expmstr0_axim,
input wire         rvalid_expmstr0_axim,
output wire        rready_expmstr0_axim,
output wire [9:0]  awuser_expmstr0_axim,
output wire [9:0]  aruser_expmstr0_axim,
output wire [3:0]  awqos_expmstr0_axim,
output wire [3:0]  arqos_expmstr0_axim,
 

output wire        awakeup_expmstr1_axim,
output wire [GLOBAL_ID_WIDTH-1:0] awid_expmstr1_axim,
output wire [31:0] awaddr_expmstr1_axim,
output wire [7:0]  awlen_expmstr1_axim,
output wire [2:0]  awsize_expmstr1_axim,
output wire [1:0]  awburst_expmstr1_axim,
output wire        awlock_expmstr1_axim,
output wire [3:0]  awcache_expmstr1_axim,
output wire [2:0]  awprot_expmstr1_axim,
output wire        awvalid_expmstr1_axim,
input wire         awready_expmstr1_axim,
output wire [EXPMST1_DATA_WIDTH-1:0] wdata_expmstr1_axim,
output wire [(EXPMST1_DATA_WIDTH/8)-1:0]  wstrb_expmstr1_axim,
output wire        wlast_expmstr1_axim,
output wire        wvalid_expmstr1_axim,
input wire         wready_expmstr1_axim,
input wire  [GLOBAL_ID_WIDTH-1:0] bid_expmstr1_axim,
input wire  [1:0]  bresp_expmstr1_axim,
input wire         bvalid_expmstr1_axim,
output wire        bready_expmstr1_axim,
output wire [GLOBAL_ID_WIDTH-1:0] arid_expmstr1_axim,
output wire [31:0] araddr_expmstr1_axim,
output wire [7:0]  arlen_expmstr1_axim,
output wire [2:0]  arsize_expmstr1_axim,
output wire [1:0]  arburst_expmstr1_axim,
output wire        arlock_expmstr1_axim,
output wire [3:0]  arcache_expmstr1_axim,
output wire [2:0]  arprot_expmstr1_axim,
output wire        arvalid_expmstr1_axim,
input wire         arready_expmstr1_axim,
input wire  [GLOBAL_ID_WIDTH-1:0] rid_expmstr1_axim,
input wire  [EXPMST1_DATA_WIDTH-1:0] rdata_expmstr1_axim,
input wire  [1:0]  rresp_expmstr1_axim,
input wire         rlast_expmstr1_axim,
input wire         rvalid_expmstr1_axim,
output wire        rready_expmstr1_axim,
output wire [9:0]  awuser_expmstr1_axim,
output wire [9:0]  aruser_expmstr1_axim,
output wire [3:0]  awqos_expmstr1_axim,
output wire [3:0]  arqos_expmstr1_axim,


output wire        awakeup_ocvm_axim,
output wire [GLOBAL_ID_WIDTH-1:0] awid_ocvm_axim,
output wire [31:0] awaddr_ocvm_axim,
output wire [7:0]  awlen_ocvm_axim,
output wire [2:0]  awsize_ocvm_axim,
output wire [1:0]  awburst_ocvm_axim,
output wire        awlock_ocvm_axim,
output wire [3:0]  awcache_ocvm_axim,
output wire [2:0]  awprot_ocvm_axim,
output wire        awvalid_ocvm_axim,
input wire         awready_ocvm_axim,
output wire [OCVM_DATA_WIDTH-1:0] wdata_ocvm_axim,
output wire [(OCVM_DATA_WIDTH/8)-1:0]  wstrb_ocvm_axim,
output wire        wlast_ocvm_axim,
output wire        wvalid_ocvm_axim,
input wire         wready_ocvm_axim,
input wire  [GLOBAL_ID_WIDTH-1:0] bid_ocvm_axim,
input wire  [1:0]  bresp_ocvm_axim,
input wire         bvalid_ocvm_axim,
output wire        bready_ocvm_axim,
output wire [GLOBAL_ID_WIDTH-1:0] arid_ocvm_axim,
output wire [31:0] araddr_ocvm_axim,
output wire [7:0]  arlen_ocvm_axim,
output wire [2:0]  arsize_ocvm_axim,
output wire [1:0]  arburst_ocvm_axim,
output wire        arlock_ocvm_axim,
output wire [3:0]  arcache_ocvm_axim,
output wire [2:0]  arprot_ocvm_axim,
output wire        arvalid_ocvm_axim,
input wire         arready_ocvm_axim,
input wire  [GLOBAL_ID_WIDTH-1:0] rid_ocvm_axim,
input wire  [OCVM_DATA_WIDTH-1:0] rdata_ocvm_axim,
input wire  [1:0]  rresp_ocvm_axim,
input wire         rlast_ocvm_axim,
input wire         rvalid_ocvm_axim,
output wire        rready_ocvm_axim,
output wire [9:0]  awuser_ocvm_axim,
output wire [9:0]  aruser_ocvm_axim,
output wire [3:0]  awqos_ocvm_axim,
output wire [3:0]  arqos_ocvm_axim,

 

input wire  [EXPSLV0_ID_WIDTH-1:0]  awid_expslv0_axis,
input wire  [31:0] awaddr_expslv0_axis,
input wire  [7:0]  awlen_expslv0_axis,
input wire  [2:0]  awsize_expslv0_axis,
input wire  [1:0]  awburst_expslv0_axis,
input wire         awlock_expslv0_axis,
input wire  [3:0]  awcache_expslv0_axis,
input wire  [2:0]  awprot_expslv0_axis,
input wire         awvalid_expslv0_axis,
input wire         awakeup_expslv0_axis,
output wire        awready_expslv0_axis,
input wire  [EXPSLV0_DATA_WIDTH-1:0] wdata_expslv0_axis,
input wire  [(EXPSLV0_DATA_WIDTH/8)-1:0]  wstrb_expslv0_axis,
input wire         wlast_expslv0_axis,
input wire         wvalid_expslv0_axis,
output wire        wready_expslv0_axis,
output wire [EXPSLV0_ID_WIDTH-1:0]  bid_expslv0_axis,
output wire [1:0]  bresp_expslv0_axis,
output wire        bvalid_expslv0_axis,
input wire         bready_expslv0_axis,
input wire  [EXPSLV0_ID_WIDTH-1:0]  arid_expslv0_axis,
input wire  [31:0] araddr_expslv0_axis,
input wire  [7:0]  arlen_expslv0_axis,
input wire  [2:0]  arsize_expslv0_axis,
input wire  [1:0]  arburst_expslv0_axis,
input wire         arlock_expslv0_axis,
input wire  [3:0]  arcache_expslv0_axis,
input wire  [2:0]  arprot_expslv0_axis,
input wire         arvalid_expslv0_axis,
output wire        arready_expslv0_axis,
output wire [EXPSLV0_ID_WIDTH-1:0]  rid_expslv0_axis,
output wire [EXPSLV0_DATA_WIDTH-1:0] rdata_expslv0_axis,
output wire [1:0]  rresp_expslv0_axis,
output wire        rlast_expslv0_axis,
output wire        rvalid_expslv0_axis,
input wire         rready_expslv0_axis,
input wire  [9:0]  awuser_expslv0_axis,
input wire  [9:0]  aruser_expslv0_axis,
input wire  [3:0]  awqos_expslv0_axis,
input wire  [3:0]  arqos_expslv0_axis,

 

input wire  [EXPSLV1_ID_WIDTH-1:0]  awid_expslv1_axis,
input wire  [31:0] awaddr_expslv1_axis,
input wire  [7:0]  awlen_expslv1_axis,
input wire  [2:0]  awsize_expslv1_axis,
input wire  [1:0]  awburst_expslv1_axis,
input wire         awlock_expslv1_axis,
input wire  [3:0]  awcache_expslv1_axis,
input wire  [2:0]  awprot_expslv1_axis,
input wire         awvalid_expslv1_axis,
input wire         awakeup_expslv1_axis,
output wire        awready_expslv1_axis,
input wire  [EXPSLV1_DATA_WIDTH-1:0] wdata_expslv1_axis,
input wire  [(EXPSLV1_DATA_WIDTH/8)-1:0]  wstrb_expslv1_axis,
input wire         wlast_expslv1_axis,
input wire         wvalid_expslv1_axis,
output wire        wready_expslv1_axis,
output wire [EXPSLV1_ID_WIDTH-1:0]  bid_expslv1_axis,
output wire [1:0]  bresp_expslv1_axis,
output wire        bvalid_expslv1_axis,
input wire         bready_expslv1_axis,
input wire  [EXPSLV1_ID_WIDTH-1:0]  arid_expslv1_axis,
input wire  [31:0] araddr_expslv1_axis,
input wire  [7:0]  arlen_expslv1_axis,
input wire  [2:0]  arsize_expslv1_axis,
input wire  [1:0]  arburst_expslv1_axis,
input wire         arlock_expslv1_axis,
input wire  [3:0]  arcache_expslv1_axis,
input wire  [2:0]  arprot_expslv1_axis,
input wire         arvalid_expslv1_axis,
output wire        arready_expslv1_axis,
output wire [EXPSLV1_ID_WIDTH-1:0]  rid_expslv1_axis,
output wire [EXPSLV1_DATA_WIDTH-1:0] rdata_expslv1_axis,
output wire [1:0]  rresp_expslv1_axis,
output wire        rlast_expslv1_axis,
output wire        rvalid_expslv1_axis,
input wire         rready_expslv1_axis,
input wire  [9:0]  awuser_expslv1_axis,
input wire  [9:0]  aruser_expslv1_axis,
input wire  [3:0]  awqos_expslv1_axis,
input wire  [3:0]  arqos_expslv1_axis,


output wire        qactive_extsys0_mhupwrreq,

input wire                                       slvmustacceptreqn_async_eh0,
input wire                                       slvcandenyreqn_async_eh0,
output wire                                      slvacceptn_async_eh0,
output wire                                      slvdeny_async_eh0,
input wire                                       si_to_mi_wakeup_async_eh0,
output wire                                      mi_to_si_wakeup_async_eh0,
input wire  [EXT_SYS0_MEM_AW_FIFO_DEPTH-1:0]      aw_wr_ptr_async_eh0,
output wire [EXT_SYS0_MEM_AW_FIFO_DEPTH-1:0]      aw_rd_ptr_async_eh0,
input wire  [EXT_SYS0_MEM_AW_PAYLOAD_WIDTH-1:0]   aw_payld_async_eh0,
input wire  [EXT_SYS0_MEM_W_FIFO_DEPTH-1:0]       w_wr_ptr_async_eh0,
output wire [EXT_SYS0_MEM_W_FIFO_DEPTH-1:0]       w_rd_ptr_async_eh0,
input wire  [EXT_SYS0_MEM_W_PAYLOAD_WIDTH-1:0]    w_payld_async_eh0,
output wire [EXT_SYS0_MEM_B_FIFO_DEPTH-1:0]       b_wr_ptr_async_eh0,
input wire  [EXT_SYS0_MEM_B_FIFO_DEPTH-1:0]       b_rd_ptr_async_eh0,
output wire [EXT_SYS0_MEM_B_PAYLOAD_WIDTH-1:0]    b_payld_async_eh0,
input wire  [EXT_SYS0_MEM_AR_FIFO_DEPTH-1:0]      ar_wr_ptr_async_eh0,
output wire [EXT_SYS0_MEM_AR_FIFO_DEPTH-1:0]      ar_rd_ptr_async_eh0,
input wire  [EXT_SYS0_MEM_AR_PAYLOAD_WIDTH-1:0]   ar_payld_async_eh0,
output wire [EXT_SYS0_MEM_R_FIFO_DEPTH-1:0]       r_wr_ptr_async_eh0,
input wire  [EXT_SYS0_MEM_R_FIFO_DEPTH-1:0]       r_rd_ptr_async_eh0,
output wire [EXT_SYS0_MEM_R_PAYLOAD_WIDTH-1:0]    r_payld_async_eh0,

input wire                           apb_async_req_eh0_mhu_esh_0,
input wire  [48:0]                   apb_async_req_payload_eh0_mhu_esh_0,
output wire [32:0]                   apb_async_resp_payload_eh0_mhu_esh_0,
output wire                          apb_async_ack_eh0_mhu_esh_0,
output wire                          recawake_async_eh0_mhu_esh_0,
input wire                           recwakeup_async_eh0_mhu_esh_0,
output wire [MHU_ES0H0_NUM_CH-1:0]   edge_async_req_eh0_mhu_esh_0,
input wire  [MHU_ES0H0_NUM_CH-1:0]   edge_async_ack_eh0_mhu_esh_0,

output wire                          apb_async_req_eh0_mhu_hes_0,
output wire [48:0]                   apb_async_req_payload_eh0_mhu_hes_0,
input wire  [32:0]                   apb_async_resp_payload_eh0_mhu_hes_0,
input wire                           apb_async_ack_eh0_mhu_hes_0,
input wire                           recawake_async_eh0_mhu_hes_0,
output wire                          recwakeup_async_eh0_mhu_hes_0,
input wire  [MHU_HES00_NUM_CH-1:0]   edge_async_req_eh0_mhu_hes_0,
output wire [MHU_HES00_NUM_CH-1:0]   edge_async_ack_eh0_mhu_hes_0,

  input wire                           apb_async_req_eh0_mhu_esh_1,
input wire  [48:0]                   apb_async_req_payload_eh0_mhu_esh_1,
output wire [32:0]                   apb_async_resp_payload_eh0_mhu_esh_1,
output wire                          apb_async_ack_eh0_mhu_esh_1,
output wire                          recawake_async_eh0_mhu_esh_1,
input wire                           recwakeup_async_eh0_mhu_esh_1,
output wire [MHU_ES0H1_NUM_CH-1:0]   edge_async_req_eh0_mhu_esh_1,
input wire  [MHU_ES0H1_NUM_CH-1:0]   edge_async_ack_eh0_mhu_esh_1,

output wire                          apb_async_req_eh0_mhu_hes_1,
output wire [48:0]                   apb_async_req_payload_eh0_mhu_hes_1,
input wire  [32:0]                   apb_async_resp_payload_eh0_mhu_hes_1,
input wire                           apb_async_ack_eh0_mhu_hes_1,
input wire                           recawake_async_eh0_mhu_hes_1,
output wire                          recwakeup_async_eh0_mhu_hes_1,
input wire  [MHU_HES01_NUM_CH-1:0]   edge_async_req_eh0_mhu_hes_1,
output wire [MHU_HES01_NUM_CH-1:0]   edge_async_ack_eh0_mhu_hes_1,
  
output wire                          hes_0_eh0_mhuint,
output wire                          esh_0_eh0_mhuint,
  output wire                          hes_1_eh0_mhuint,
output wire                          esh_1_eh0_mhuint,
  

output wire        qactive_extsys1_mhupwrreq,

input wire                                       slvmustacceptreqn_async_eh1,
input wire                                       slvcandenyreqn_async_eh1,
output wire                                      slvacceptn_async_eh1,
output wire                                      slvdeny_async_eh1,
input wire                                       si_to_mi_wakeup_async_eh1,
output wire                                      mi_to_si_wakeup_async_eh1,
input wire  [EXT_SYS1_MEM_AW_FIFO_DEPTH-1:0]      aw_wr_ptr_async_eh1,
output wire [EXT_SYS1_MEM_AW_FIFO_DEPTH-1:0]      aw_rd_ptr_async_eh1,
input wire  [EXT_SYS1_MEM_AW_PAYLOAD_WIDTH-1:0]   aw_payld_async_eh1,
input wire  [EXT_SYS1_MEM_W_FIFO_DEPTH-1:0]       w_wr_ptr_async_eh1,
output wire [EXT_SYS1_MEM_W_FIFO_DEPTH-1:0]       w_rd_ptr_async_eh1,
input wire  [EXT_SYS1_MEM_W_PAYLOAD_WIDTH-1:0]    w_payld_async_eh1,
output wire [EXT_SYS1_MEM_B_FIFO_DEPTH-1:0]       b_wr_ptr_async_eh1,
input wire  [EXT_SYS1_MEM_B_FIFO_DEPTH-1:0]       b_rd_ptr_async_eh1,
output wire [EXT_SYS1_MEM_B_PAYLOAD_WIDTH-1:0]    b_payld_async_eh1,
input wire  [EXT_SYS1_MEM_AR_FIFO_DEPTH-1:0]      ar_wr_ptr_async_eh1,
output wire [EXT_SYS1_MEM_AR_FIFO_DEPTH-1:0]      ar_rd_ptr_async_eh1,
input wire  [EXT_SYS1_MEM_AR_PAYLOAD_WIDTH-1:0]   ar_payld_async_eh1,
output wire [EXT_SYS1_MEM_R_FIFO_DEPTH-1:0]       r_wr_ptr_async_eh1,
input wire  [EXT_SYS1_MEM_R_FIFO_DEPTH-1:0]       r_rd_ptr_async_eh1,
output wire [EXT_SYS1_MEM_R_PAYLOAD_WIDTH-1:0]    r_payld_async_eh1,

input wire                           apb_async_req_eh1_mhu_esh_0,
input wire  [48:0]                   apb_async_req_payload_eh1_mhu_esh_0,
output wire [32:0]                   apb_async_resp_payload_eh1_mhu_esh_0,
output wire                          apb_async_ack_eh1_mhu_esh_0,
output wire                          recawake_async_eh1_mhu_esh_0,
input wire                           recwakeup_async_eh1_mhu_esh_0,
output wire [MHU_ES1H0_NUM_CH-1:0]   edge_async_req_eh1_mhu_esh_0,
input wire  [MHU_ES1H0_NUM_CH-1:0]   edge_async_ack_eh1_mhu_esh_0,

output wire                          apb_async_req_eh1_mhu_hes_0,
output wire [48:0]                   apb_async_req_payload_eh1_mhu_hes_0,
input wire  [32:0]                   apb_async_resp_payload_eh1_mhu_hes_0,
input wire                           apb_async_ack_eh1_mhu_hes_0,
input wire                           recawake_async_eh1_mhu_hes_0,
output wire                          recwakeup_async_eh1_mhu_hes_0,
input wire  [MHU_HES10_NUM_CH-1:0]   edge_async_req_eh1_mhu_hes_0,
output wire [MHU_HES10_NUM_CH-1:0]   edge_async_ack_eh1_mhu_hes_0,

  input wire                           apb_async_req_eh1_mhu_esh_1,
input wire  [48:0]                   apb_async_req_payload_eh1_mhu_esh_1,
output wire [32:0]                   apb_async_resp_payload_eh1_mhu_esh_1,
output wire                          apb_async_ack_eh1_mhu_esh_1,
output wire                          recawake_async_eh1_mhu_esh_1,
input wire                           recwakeup_async_eh1_mhu_esh_1,
output wire [MHU_ES1H1_NUM_CH-1:0]   edge_async_req_eh1_mhu_esh_1,
input wire  [MHU_ES1H1_NUM_CH-1:0]   edge_async_ack_eh1_mhu_esh_1,

output wire                          apb_async_req_eh1_mhu_hes_1,
output wire [48:0]                   apb_async_req_payload_eh1_mhu_hes_1,
input wire  [32:0]                   apb_async_resp_payload_eh1_mhu_hes_1,
input wire                           apb_async_ack_eh1_mhu_hes_1,
input wire                           recawake_async_eh1_mhu_hes_1,
output wire                          recwakeup_async_eh1_mhu_hes_1,
input wire  [MHU_HES11_NUM_CH-1:0]   edge_async_req_eh1_mhu_hes_1,
output wire [MHU_HES11_NUM_CH-1:0]   edge_async_ack_eh1_mhu_hes_1,
  
output wire                          hes_0_eh1_mhuint,
output wire                          esh_0_eh1_mhuint,
  output wire                          hes_1_eh1_mhuint,
output wire                          esh_1_eh1_mhuint,
  

input wire                                slvmustacceptreqn_async_secenc,
input wire                                slvcandenyreqn_async_secenc,
output wire                               slvacceptn_async_secenc,
output wire                               slvdeny_async_secenc,
input wire                                si_to_mi_wakeup_async_secenc,
output wire                               mi_to_si_wakeup_async_secenc,
input wire  [SECENC_AW_FIFO_DEPTH-1:0]    aw_wr_ptr_async_secenc,
output wire [SECENC_AW_FIFO_DEPTH-1:0]    aw_rd_ptr_async_secenc,
input wire  [SECENC_AW_PAYLOAD_WIDTH-1:0] aw_payld_async_secenc,
input wire  [SECENC_W_FIFO_DEPTH-1:0]     w_wr_ptr_async_secenc,
output wire [SECENC_W_FIFO_DEPTH-1:0]     w_rd_ptr_async_secenc,
input wire  [SECENC_W_PAYLOAD_WIDTH-1:0]  w_payld_async_secenc,
output wire [SECENC_B_FIFO_DEPTH-1:0]     b_wr_ptr_async_secenc,
input wire  [SECENC_B_FIFO_DEPTH-1:0]     b_rd_ptr_async_secenc,
output wire [SECENC_B_PAYLOAD_WIDTH-1:0]  b_payld_async_secenc,
input wire  [SECENC_AR_FIFO_DEPTH-1:0]    ar_wr_ptr_async_secenc,
output wire [SECENC_AR_FIFO_DEPTH-1:0]    ar_rd_ptr_async_secenc,
input wire  [SECENC_AR_PAYLOAD_WIDTH-1:0] ar_payld_async_secenc,
output wire [SECENC_R_FIFO_DEPTH-1:0]     r_wr_ptr_async_secenc,
input wire  [SECENC_R_FIFO_DEPTH-1:0]     r_rd_ptr_async_secenc,
output wire [SECENC_R_PAYLOAD_WIDTH-1:0]  r_payld_async_secenc,

input wire                           apb_async_req_seh0_mhu,
input wire  [48:0]                   apb_async_req_payload_seh0_mhu,
output wire [32:0]                   apb_async_resp_payload_seh0_mhu,
output wire                          apb_async_ack_seh0_mhu,
output wire                          recawake_async_seh0_mhu,
input wire                           recwakeup_async_seh0_mhu,
output wire [MHU_SEH0_NUM_CH-1:0]    edge_async_req_seh0_mhu,
input wire  [MHU_SEH0_NUM_CH-1:0]    edge_async_ack_seh0_mhu,

output wire                          apb_async_req_hse0_mhu,
output wire [48:0]                   apb_async_req_payload_hse0_mhu,
input wire  [32:0]                   apb_async_resp_payload_hse0_mhu,
input wire                           apb_async_ack_hse0_mhu,
input wire                           recawake_async_hse0_mhu,
output wire                          recwakeup_async_hse0_mhu,
input wire  [MHU_HSE0_NUM_CH-1:0]    edge_async_req_hse0_mhu,
output wire [MHU_HSE0_NUM_CH-1:0]    edge_async_ack_hse0_mhu,

input wire                           apb_async_req_seh1_mhu,
input wire  [48:0]                   apb_async_req_payload_seh1_mhu,
output wire [32:0]                   apb_async_resp_payload_seh1_mhu,
output wire                          apb_async_ack_seh1_mhu,
output wire                          recawake_async_seh1_mhu,
input wire                           recwakeup_async_seh1_mhu,
output wire [MHU_SEH1_NUM_CH-1:0]    edge_async_req_seh1_mhu,
input wire  [MHU_SEH1_NUM_CH-1:0]    edge_async_ack_seh1_mhu,

output wire                          apb_async_req_hse1_mhu,
output wire [48:0]                   apb_async_req_payload_hse1_mhu,
input wire  [32:0]                   apb_async_resp_payload_hse1_mhu,
input wire                           apb_async_ack_hse1_mhu,
input wire                           recawake_async_hse1_mhu,
output wire                          recwakeup_async_hse1_mhu,
input wire  [MHU_HSE1_NUM_CH-1:0]    edge_async_req_hse1_mhu,
output wire [MHU_HSE1_NUM_CH-1:0]    edge_async_ack_hse1_mhu,

output wire                          hse0_mhuint,
output wire                          seh0_mhuint,
output wire                          hse1_mhuint,
output wire                          seh1_mhuint,

output wire [6*41-1 : 0]        debug_hostcpu_atb_fwd_data,
output wire [3:0]               debug_hostcpu_wr_pointer_gray,
input  wire [3:0]               debug_hostcpu_rd_pointer_gray,
input wire                      debug_hostcpu_flush_req,
output wire                     debug_hostcpu_flush_done,
output wire                     debug_hostcpu_sync_clear,
input wire                      debug_hostcpu_sync_done,
input  wire                     debug_hostcpu_syncreq_async_req,
output wire                     debug_hostcpu_syncreq_async_ack,
 

input   wire                    clustop_dependency_qreqn,
output  wire                    clustop_dependency_qacceptn,
output  wire                    clustop_dependency_qdeny,     
output  wire                    clustop_dependency_qactive,    
 
 
 
input  wire debug_axis_slvmustacceptreqn_async,
input  wire debug_axis_slvcandenyreqn_async,
output wire debug_axis_slvacceptn_async,
output wire debug_axis_slvdeny_async,

input  wire debug_axis_si_to_mi_wakeup_async,
output wire debug_axis_mi_to_si_wakeup_async,

input  wire [DBG_AW_FIFO_DEPTH-1:0]    debug_axis_aw_wr_ptr_async,
output wire [DBG_AW_FIFO_DEPTH-1:0]    debug_axis_aw_rd_ptr_async,
input  wire [DBG_AW_PAYLOAD_WIDTH-1:0] debug_axis_aw_payld_async,

input  wire [ DBG_W_FIFO_DEPTH-1:0]    debug_axis_w_wr_ptr_async,
output wire [ DBG_W_FIFO_DEPTH-1:0]    debug_axis_w_rd_ptr_async,
input  wire [DBG_W_PAYLOAD_WIDTH-1:0]  debug_axis_w_payld_async,
                                       
output wire [ DBG_B_FIFO_DEPTH-1:0]    debug_axis_b_wr_ptr_async,
input  wire [ DBG_B_FIFO_DEPTH-1:0]    debug_axis_b_rd_ptr_async,
output wire [DBG_B_PAYLOAD_WIDTH-1:0]  debug_axis_b_payld_async,

input  wire [DBG_AR_FIFO_DEPTH-1:0]    debug_axis_ar_wr_ptr_async,
output wire [DBG_AR_FIFO_DEPTH-1:0]    debug_axis_ar_rd_ptr_async,
input  wire [DBG_AR_PAYLOAD_WIDTH-1:0] debug_axis_ar_payld_async,

output wire [ DBG_R_FIFO_DEPTH-1:0]    debug_axis_r_wr_ptr_async,
input  wire [ DBG_R_FIFO_DEPTH-1:0]    debug_axis_r_rd_ptr_async,
output wire [DBG_R_PAYLOAD_WIDTH-1:0]  debug_axis_r_payld_async,


output  wire                            stm_slvmustacceptreqn_async,
output  wire                            stm_slvcandenyreqn_async,
input   wire                            stm_slvacceptn_async,
input   wire                            stm_slvdeny_async,
    
output  wire                            stm_si_to_mi_wakeup_async,
input wire                              stm_mi_to_si_wakeup_async,

output  wire [STM_AW_FIFO_DEPTH-1:0]    stm_aw_wr_ptr_async,
input wire [STM_AW_FIFO_DEPTH-1:0]      stm_aw_rd_ptr_async,
output  wire [STM_AW_PAYLOAD_WIDTH-1:0] stm_aw_payld_async,

output  wire [ STM_W_FIFO_DEPTH-1:0]    stm_w_wr_ptr_async,
input wire [ STM_W_FIFO_DEPTH-1:0]      stm_w_rd_ptr_async,
output  wire [STM_W_PAYLOAD_WIDTH-1:0]  stm_w_payld_async,

input wire [ STM_B_FIFO_DEPTH-1:0]      stm_b_wr_ptr_async,
output  wire [ STM_B_FIFO_DEPTH-1:0]    stm_b_rd_ptr_async,
input wire [STM_B_PAYLOAD_WIDTH-1:0]    stm_b_payld_async,

output  wire [STM_AR_FIFO_DEPTH-1:0]    stm_ar_wr_ptr_async,
input wire [STM_AR_FIFO_DEPTH-1:0]      stm_ar_rd_ptr_async,
output  wire [STM_AR_PAYLOAD_WIDTH-1:0] stm_ar_payld_async,

input wire [ STM_R_FIFO_DEPTH-1:0]      stm_r_wr_ptr_async,
output  wire [ STM_R_FIFO_DEPTH-1:0]    stm_r_rd_ptr_async,
input wire [STM_R_PAYLOAD_WIDTH-1:0]    stm_r_payld_async,
  
output wire                             fw2systop_dn_slvmustacceptreqn_async,
output wire                             fw2systop_dn_slvcandenyreqn_async,
input  wire                             fw2systop_dn_slvacceptn_async,
input  wire                             fw2systop_dn_slvdeny_async,
output wire                             fw2systop_dn_si_to_mi_wakeup_async,
input  wire                             fw2systop_dn_mi_to_si_wakeup_async,
output wire [FW2SYSTOP_FIFO_DEPTH-1:0]  fw2systop_dn_wr_ptr_async,
input  wire [FW2SYSTOP_FIFO_DEPTH-1:0]  fw2systop_dn_rd_ptr_async,
output wire [((payload_width_fn(1,32,0,4,4,4,0)>0)?
             ((payload_width_fn(1,32,0,4,4,4,0)*FW2SYSTOP_FIFO_DEPTH)-1):
              0):0]                     fw2systop_dn_payld_async,
input  wire                             fw2systop_up_slvmustacceptreqn_async,
input  wire                             fw2systop_up_slvcandenyreqn_async,
output wire                             fw2systop_up_slvacceptn_async,
output wire                             fw2systop_up_slvdeny_async,
input  wire                             fw2systop_up_si_to_mi_wakeup_async,
output wire                             fw2systop_up_mi_to_si_wakeup_async,
input  wire [FW2SYSTOP_FIFO_DEPTH-1:0]  fw2systop_up_wr_ptr_async,
output wire [FW2SYSTOP_FIFO_DEPTH-1:0]  fw2systop_up_rd_ptr_async,
input  wire [((payload_width_fn(1,32,0,4,4,4,0)>0)?
             ((payload_width_fn(1,32,0,4,4,4,0)*FW2SYSTOP_FIFO_DEPTH)-1):
              0):0]                     fw2systop_up_payld_async

);



 
 

wire [21:0] qch_exp_aclk_devqreqn;
wire [21:0] qch_exp_aclk_devqacceptn;
wire [21:0] qch_exp_aclk_devqdeny;
wire [21:0] qch_exp_aclk_devqactive;


wire system_interrupt;
wire router_interrupt;


wire ctrlclk_devqreqn;
wire ctrlclk_devqacceptn;
wire ctrlclk_devqdeny;
wire ctrlclk_devqactive;
wire  [5:0] ctrlclk_qreqn;
wire  [5:0] ctrlclk_qacceptn;
wire  [5:0] ctrlclk_qdeny;
wire  [5:0] ctrlclk_qactive;


wire [6:0] qch_exp_systop_egress_devqreqn;
wire [6:0] qch_exp_systop_egress_devqacceptn;
wire [6:0] qch_exp_systop_egress_devqdeny;
wire [6:0] qch_exp_systop_egress_devqactive;


wire [12:0] qch_exp_systop_internal_devqreqn;
wire [12:0] qch_exp_systop_internal_devqacceptn;
wire [12:0] qch_exp_systop_internal_devqdeny;
wire [12:0] qch_exp_systop_internal_devqactive;

                

wire [5:0] qch_exp_systop_ingress_devqreqn;
wire [5:0] qch_exp_systop_ingress_devqacceptn;
wire [5:0] qch_exp_systop_ingress_devqdeny;
wire [5:0] qch_exp_systop_ingress_devqactive;

wire  hostcpu_axim_egress_qreqn;
wire  hostcpu_axim_egress_qacceptn;
wire  hostcpu_axim_egress_qdeny;
wire  hostcpu_axim_egress_qactive;

wire  clustop_ingress_cti_double_bridge_qreqn;
wire  clustop_ingress_cti_double_bridge_qacceptn;
wire  clustop_ingress_cti_double_bridge_qdeny;
wire  clustop_ingress_cti_double_bridge_qactive;

wire resetn_clk_gen;

localparam   CPU_ADDR_WIDTH    = 40;
localparam   CPU_DATA_WIDTH    = 128;
localparam   CPU_AWID_WIDTH    = 8;
localparam   CPU_ARID_WIDTH    = 8;
localparam   CPU_AWUSER_WIDTH  = 2;
localparam   CPU_WUSER_WIDTH   = 0;
localparam   CPU_BUSER_WIDTH   = 0;
localparam   CPU_ARUSER_WIDTH  = 2;
localparam   CPU_RUSER_WIDTH   = 0;

localparam   GIC_ADDR_WIDTH    = 19;
localparam   GIC_DATA_WIDTH    = 32;
localparam   GIC_AWID_WIDTH    = GLOBAL_ID_WIDTH;
localparam   GIC_ARID_WIDTH    = GLOBAL_ID_WIDTH;
localparam   GIC_AWUSER_WIDTH  = 3;
localparam   GIC_WUSER_WIDTH   = 0;
localparam   GIC_BUSER_WIDTH   = 0;
localparam   GIC_ARUSER_WIDTH  = 3;
localparam   GIC_RUSER_WIDTH   = 0;

localparam   CPU_AW_PAYLOAD_WIDTH = ((aw_payload_width_fn(CPU_AWUSER_WIDTH,CPU_AWID_WIDTH,CPU_ADDR_WIDTH)+0)*CPU_AW_FIFO_DEPTH); 
localparam   CPU_W_PAYLOAD_WIDTH = ((w_payload_width_fn(CPU_WUSER_WIDTH,CPU_AWID_WIDTH,CPU_DATA_WIDTH)+0)* CPU_W_FIFO_DEPTH);
localparam   CPU_B_PAYLOAD_WIDTH = (b_payload_width_fn(CPU_BUSER_WIDTH,CPU_AWID_WIDTH)* CPU_B_FIFO_DEPTH); 
localparam   CPU_AR_PAYLOAD_WIDTH = ((ar_payload_width_fn(CPU_ARUSER_WIDTH,CPU_ARID_WIDTH,CPU_ADDR_WIDTH)+0)*CPU_AR_FIFO_DEPTH);
localparam   CPU_R_PAYLOAD_WIDTH = (r_payload_width_fn(CPU_RUSER_WIDTH,CPU_ARID_WIDTH,CPU_DATA_WIDTH)* CPU_R_FIFO_DEPTH);

localparam   GIC_AW_PAYLOAD_WIDTH = ((aw_payload_width_fn(GIC_AWUSER_WIDTH,GIC_AWID_WIDTH,GIC_ADDR_WIDTH)+0)*GIC_AW_FIFO_DEPTH); 
localparam   GIC_W_PAYLOAD_WIDTH = ((w_payload_width_fn(GIC_WUSER_WIDTH,GIC_AWID_WIDTH,GIC_DATA_WIDTH)+0)* GIC_W_FIFO_DEPTH);
localparam   GIC_B_PAYLOAD_WIDTH = (b_payload_width_fn(GIC_BUSER_WIDTH,GIC_AWID_WIDTH)* GIC_B_FIFO_DEPTH); 
localparam   GIC_AR_PAYLOAD_WIDTH = ((ar_payload_width_fn(GIC_ARUSER_WIDTH,GIC_ARID_WIDTH,GIC_ADDR_WIDTH)+0)*GIC_AR_FIFO_DEPTH);
localparam   GIC_R_PAYLOAD_WIDTH = (r_payload_width_fn(GIC_RUSER_WIDTH,GIC_ARID_WIDTH,GIC_DATA_WIDTH)* GIC_R_FIFO_DEPTH);

  function automatic integer payload_width_fn
    (
      input integer last_width,
      input integer data_width,
      input integer strb_width,
      input integer keep_width,
      input integer id_width,
      input integer dest_width,
      input integer user_width
    );
    begin : fn_payload_width_fn
      payload_width_fn = 
               ((last_width>0)?1:0) +
               data_width +
               strb_width +
               keep_width +
               id_width +
               dest_width +
               user_width +
               0;
    end
  endfunction

  function automatic integer aw_payload_width_fn
    (
      input integer awuser_width,
      input integer awid_width,
      input integer awaddr_width
    ); 
    begin : fn_aw_payload_width_fn
      aw_payload_width_fn =
               awuser_width +
               awid_width +
               awaddr_width +
               4 +            
               8 +            
               3 +            
               2 +            
               1 +            
               4 +            
               3 +            
               4 +            
               0;
    end
  endfunction

  function automatic integer w_payload_width_fn
    (
      input integer wuser_width,
      input integer wid_width,
      input integer wdata_width
    ); 
    begin : fn_w_payload_width_fn
      w_payload_width_fn =
               wuser_width +
               wdata_width +
               (wdata_width/8) + 
               1 +            
               0;
    end
  endfunction

  function automatic integer b_payload_width_fn
    (
      input integer buser_width,
      input integer bid_width
    ); 
    begin : fn_b_payload_width_fn
      b_payload_width_fn =
               buser_width +
               bid_width +
               2 +            
               0;
    end
  endfunction

  function automatic integer ar_payload_width_fn
    (
      input integer aruser_width,
      input integer arid_width,
      input integer araddr_width
    ); 
    begin : fn_ar_payload_width_fn
      ar_payload_width_fn =
               aruser_width +
               arid_width +
               araddr_width +
               4 +            
               8 +            
               3 +            
               2 +            
               1 +            
               4 +            
               3 +            
               4 +            
               0;
    end
  endfunction

  function automatic integer r_payload_width_fn
    (
      input integer ruser_width,
      input integer rid_width,
      input integer rdata_width
    ); 
    begin : fn_r_payload_width_fn
      r_payload_width_fn =
               ruser_width +
               rid_width +
               rdata_width +
               2 +            
               1 +            
               0;
    end
  endfunction


wire                            hostcpu_slvmustacceptreqn_async;
wire                            hostcpu_slvcandenyreqn_async;
wire                            hostcpu_slvacceptn_async;
wire                            hostcpu_slvdeny_async;
wire                            hostcpu_si_to_mi_wakeup_async;
wire                            hostcpu_mi_to_si_wakeup_async;
wire [CPU_AW_FIFO_DEPTH-1:0]    hostcpu_aw_wr_ptr_async;
wire [CPU_AW_FIFO_DEPTH-1:0]    hostcpu_aw_rd_ptr_async;
wire [CPU_AW_PAYLOAD_WIDTH-1:0] hostcpu_aw_payld_async;
wire [CPU_W_FIFO_DEPTH-1:0]     hostcpu_w_wr_ptr_async;
wire [CPU_W_FIFO_DEPTH-1:0]     hostcpu_w_rd_ptr_async;
wire [CPU_W_PAYLOAD_WIDTH-1:0]  hostcpu_w_payld_async;
wire [CPU_B_FIFO_DEPTH-1:0]     hostcpu_b_wr_ptr_async;
wire [CPU_B_FIFO_DEPTH-1:0]     hostcpu_b_rd_ptr_async;
wire [CPU_B_PAYLOAD_WIDTH-1:0]  hostcpu_b_payld_async;
wire [CPU_AR_FIFO_DEPTH-1:0]    hostcpu_ar_wr_ptr_async;
wire [CPU_AR_FIFO_DEPTH-1:0]    hostcpu_ar_rd_ptr_async;
wire [CPU_AR_PAYLOAD_WIDTH-1:0] hostcpu_ar_payld_async;
wire [CPU_R_FIFO_DEPTH-1:0]     hostcpu_r_wr_ptr_async;
wire [CPU_R_FIFO_DEPTH-1:0]     hostcpu_r_rd_ptr_async;
wire [CPU_R_PAYLOAD_WIDTH-1:0]  hostcpu_r_payld_async;


wire         gic_slvmustacceptreqn_async;
wire         gic_slvcandenyreqn_async;
wire         gic_slvacceptn_async;
wire         gic_slvdeny_async;
                                
wire         gic_si_to_mi_wakeup_async;
wire         gic_mi_to_si_wakeup_async;
                                
wire [GIC_AW_FIFO_DEPTH-1:0]       gic_aw_wr_ptr_async;
wire [GIC_AW_FIFO_DEPTH-1:0]       gic_aw_rd_ptr_async;
wire [GIC_AW_PAYLOAD_WIDTH-1:0]    gic_aw_payld_async;
wire [GIC_W_FIFO_DEPTH-1:0]        gic_w_wr_ptr_async;
wire [GIC_W_FIFO_DEPTH-1:0]        gic_w_rd_ptr_async;
wire [GIC_W_PAYLOAD_WIDTH-1:0]     gic_w_payld_async;
wire [GIC_B_FIFO_DEPTH-1:0]        gic_b_wr_ptr_async;
wire [GIC_B_FIFO_DEPTH-1:0]        gic_b_rd_ptr_async;
wire [GIC_B_PAYLOAD_WIDTH-1:0]     gic_b_payld_async;
wire [GIC_AR_FIFO_DEPTH-1:0]       gic_ar_wr_ptr_async;
wire [GIC_AR_FIFO_DEPTH-1:0]       gic_ar_rd_ptr_async;
wire [GIC_AR_PAYLOAD_WIDTH-1:0]    gic_ar_payld_async;
wire [GIC_R_FIFO_DEPTH-1:0]        gic_r_wr_ptr_async;
wire [GIC_R_FIFO_DEPTH-1:0]        gic_r_rd_ptr_async;
wire [GIC_R_PAYLOAD_WIDTH-1:0]     gic_r_payld_async;

wire               hostcpu_l2rstdisable; 

wire [3:0]         hostcpu_dbgpwrdup; 
wire [3:0]         hostcpu_dbgnopwrdwn; 
wire [3:0]         hostcpu_dbgpwrupreq;

wire [3:0]         hostcpu_stanbywfi; 
wire               hostcpu_stanbywfil2; 

wire [31:0]        hostcpu_atdatas; 
wire [1:0]         hostcpu_atbytess; 

 

wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_smpen; 

wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_warmrstreq; 
wire                  hostcpu_l2flushreq; 
wire                  hostcpu_l2flushdone; 
wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_wakeupreq;
  
wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_cpuqactive; 

wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_preq_power_handshake;
wire [4*HOST_CPU_NUM_CORES-1:0] hostcpu_pstate_power_handshake;
wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_paccept_power_handshake;
wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_pdeny_power_handshake;

wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_preq_warmrst_check;
wire [4*HOST_CPU_NUM_CORES-1:0] hostcpu_pstate_warmrst_check;
wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_paccept_warmrst_check;
wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_pdeny_warmrst_check;

wire               hostcpu_l2qactive; 
wire               hostcpu_l2qreqn; 
wire               hostcpu_l2qdeny; 
wire               hostcpu_l2qacceptn; 
  
wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_dbgrstreq; 

wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_core_poresetn;
wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_core_warmresetn;

wire                  hostcpu_clustop_warmresetn;
wire                  hostcpu_clustop_poresetn;




wire [GLOBAL_ID_WIDTH-1:0] acg_awid_cvm_axim;
wire [31:0] acg_awaddr_cvm_axim;
wire [7:0]  acg_awlen_cvm_axim;
wire [2:0]  acg_awsize_cvm_axim;
wire [1:0]  acg_awburst_cvm_axim;
wire        acg_awlock_cvm_axim;
wire [3:0]  acg_awcache_cvm_axim;
wire [2:0]  acg_awprot_cvm_axim;
wire        acg_awvalid_cvm_axim;
wire        acg_awready_cvm_axim;
wire [CVM_DATA_WIDTH-1:0] acg_wdata_cvm_axim;
wire [(CVM_DATA_WIDTH/8)-1:0]  acg_wstrb_cvm_axim;
wire        acg_wlast_cvm_axim;
wire        acg_wvalid_cvm_axim;
wire        acg_wready_cvm_axim;
wire [GLOBAL_ID_WIDTH-1:0] acg_bid_cvm_axim;
wire [1:0]  acg_bresp_cvm_axim;
wire        acg_bvalid_cvm_axim;
wire        acg_bready_cvm_axim;
wire [GLOBAL_ID_WIDTH-1:0] acg_arid_cvm_axim;
wire [31:0] acg_araddr_cvm_axim;
wire [7:0]  acg_arlen_cvm_axim;
wire [2:0]  acg_arsize_cvm_axim;
wire [1:0]  acg_arburst_cvm_axim;
wire        acg_arlock_cvm_axim;
wire [3:0]  acg_arcache_cvm_axim;
wire [2:0]  acg_arprot_cvm_axim;
wire        acg_arvalid_cvm_axim;
wire        acg_arready_cvm_axim;
wire [GLOBAL_ID_WIDTH-1:0] acg_rid_cvm_axim;
wire [CVM_DATA_WIDTH-1:0] acg_rdata_cvm_axim;
wire [1:0]  acg_rresp_cvm_axim;
wire        acg_rlast_cvm_axim;
wire        acg_rvalid_cvm_axim;
wire        acg_rready_cvm_axim;
wire [9:0]  acg_awuser_cvm_axim;
wire [9:0]  acg_aruser_cvm_axim;
wire [3:0]  acg_awqos_cvm_axim;
wire [3:0]  acg_arqos_cvm_axim;


wire [7:0]  awid_hostcpu_axis;
wire [39:0] awaddr_hostcpu_axis;
wire [7:0]  awlen_hostcpu_axis;
wire [2:0]  awsize_hostcpu_axis;
wire [1:0]  awburst_hostcpu_axis;
wire        awlock_hostcpu_axis;
wire [3:0]  awcache_hostcpu_axis;
wire [2:0]  awprot_hostcpu_axis;
wire        awvalid_hostcpu_axis;
wire        awready_hostcpu_axis;
wire [127:0] wdata_hostcpu_axis;
wire [15:0] wstrb_hostcpu_axis;
wire        wlast_hostcpu_axis;
wire        wvalid_hostcpu_axis;
wire        wready_hostcpu_axis;
wire [7:0]  bid_hostcpu_axis;
wire [1:0]  bresp_hostcpu_axis;
wire        bvalid_hostcpu_axis;
wire        bready_hostcpu_axis;
wire [7:0]  arid_hostcpu_axis;
wire [39:0] araddr_hostcpu_axis;
wire [7:0]  arlen_hostcpu_axis;
wire [2:0]  arsize_hostcpu_axis;
wire [1:0]  arburst_hostcpu_axis;
wire        arlock_hostcpu_axis;
wire [3:0]  arcache_hostcpu_axis;
wire [2:0]  arprot_hostcpu_axis;
wire        arvalid_hostcpu_axis;
wire        arready_hostcpu_axis;
wire [7:0]  rid_hostcpu_axis;
wire [127:0] rdata_hostcpu_axis;
wire [1:0]  rresp_hostcpu_axis;
wire        rlast_hostcpu_axis;
wire        rvalid_hostcpu_axis;
wire        rready_hostcpu_axis;
wire [9:0]  awuser_hostcpu_axis;
wire [9:0]  aruser_hostcpu_axis;


wire        awid_secenc_axis;
wire [39:0] awaddr_secenc_axis;
wire [7:0]  awlen_secenc_axis;
wire [2:0]  awsize_secenc_axis;
wire [1:0]  awburst_secenc_axis;
wire        awlock_secenc_axis;
wire [3:0]  awcache_secenc_axis;
wire [2:0]  awprot_secenc_axis;
wire        awvalid_secenc_axis;
wire        awready_secenc_axis;
wire [31:0] wdata_secenc_axis;
wire [3:0]  wstrb_secenc_axis;
wire        wlast_secenc_axis;
wire        wvalid_secenc_axis;
wire        wready_secenc_axis;
wire        bid_secenc_axis;
wire [6:0]  unused_bid_secenc_axis;
wire [1:0]  bresp_secenc_axis;
wire        bvalid_secenc_axis;
wire        bready_secenc_axis;
wire        arid_secenc_axis;
wire [39:0] araddr_secenc_axis;
wire [7:0]  arlen_secenc_axis;
wire [2:0]  arsize_secenc_axis;
wire [1:0]  arburst_secenc_axis;
wire        arlock_secenc_axis;
wire [3:0]  arcache_secenc_axis;
wire [2:0]  arprot_secenc_axis;
wire        arvalid_secenc_axis;
wire        arready_secenc_axis;
wire        rid_secenc_axis;
wire [6:0]  unused_rid_secenc_axis;
wire [31:0] rdata_secenc_axis;
wire [1:0]  rresp_secenc_axis;
wire        rlast_secenc_axis;
wire        rvalid_secenc_axis;
wire        rready_secenc_axis;
wire [9:0]  awuser_secenc_axis;
wire [9:0]  aruser_secenc_axis;
wire        buser_secenc_axis;
wire        ruser_secenc_axis;


wire [9:0]  awid_firewall_axim;
wire [31:0] awaddr_firewall_axim;
wire [7:0]  awlen_firewall_axim;
wire [2:0]  awsize_firewall_axim;
wire [1:0]  awburst_firewall_axim;
wire        awlock_firewall_axim;
wire [3:0]  awcache_firewall_axim;
wire [2:0]  awprot_firewall_axim;
wire        awvalid_firewall_axim;
wire        awready_firewall_axim;
wire [31:0] wdata_firewall_axim;
wire [3:0]  wstrb_firewall_axim;
wire        wlast_firewall_axim;
wire        wvalid_firewall_axim;
wire        wready_firewall_axim;
wire [9:0]  bid_firewall_axim;
wire [1:0]  bresp_firewall_axim;
wire        bvalid_firewall_axim;
wire        bready_firewall_axim;
wire [9:0]  arid_firewall_axim;
wire [31:0] araddr_firewall_axim;
wire [7:0]  arlen_firewall_axim;
wire [2:0]  arsize_firewall_axim;
wire [1:0]  arburst_firewall_axim;
wire        arlock_firewall_axim;
wire [3:0]  arcache_firewall_axim;
wire [2:0]  arprot_firewall_axim;
wire        arvalid_firewall_axim;
wire        arready_firewall_axim;
wire [9:0]  rid_firewall_axim;
wire [31:0] rdata_firewall_axim;
wire [1:0]  rresp_firewall_axim;
wire        rlast_firewall_axim;
wire        rvalid_firewall_axim;
wire        rready_firewall_axim;
wire [9:0]  awuser_firewall_axim;
wire [9:0]  aruser_firewall_axim;
wire        buser_firewall_axim;
wire        ruser_firewall_axim;


wire [9:0]  awid_bootreg_axim;
wire [39:0] awaddr_bootreg_axim;
wire [7:0]  awlen_bootreg_axim;
wire [2:0]  awsize_bootreg_axim;
wire [1:0]  awburst_bootreg_axim;
wire        awlock_bootreg_axim;
wire [3:0]  awcache_bootreg_axim;
wire [2:0]  awprot_bootreg_axim;
wire        awvalid_bootreg_axim;
wire        awready_bootreg_axim;
wire [31:0] wdata_bootreg_axim;
wire [3:0]  wstrb_bootreg_axim;
wire        wlast_bootreg_axim;
wire        wvalid_bootreg_axim;
wire        wready_bootreg_axim;
wire [9:0]  bid_bootreg_axim;
wire [1:0]  bresp_bootreg_axim;
wire        bvalid_bootreg_axim;
wire        bready_bootreg_axim;
wire [9:0]  arid_bootreg_axim;
wire [39:0] araddr_bootreg_axim;
wire [7:0]  arlen_bootreg_axim;
wire [2:0]  arsize_bootreg_axim;
wire [1:0]  arburst_bootreg_axim;
wire        arlock_bootreg_axim;
wire [3:0]  arcache_bootreg_axim;
wire [2:0]  arprot_bootreg_axim;
wire        arvalid_bootreg_axim;
wire        arready_bootreg_axim;
wire [9:0]  rid_bootreg_axim;
wire [31:0] rdata_bootreg_axim;
wire [1:0]  rresp_bootreg_axim;
wire        rlast_bootreg_axim;
wire        rvalid_bootreg_axim;
wire        rready_bootreg_axim;
wire [9:0]  awuser_bootreg_axim;
wire [9:0]  aruser_bootreg_axim;



wire [3:0]  awid_debug_axis;
wire [3:0]  arid_debug_axis;
wire [3:0]  bid_debug_axis;
wire [3:0]  rid_debug_axis;
wire [31:0] awaddr_debug_axis;
wire [7:0]  awlen_debug_axis;
wire [2:0]  awsize_debug_axis;
wire [1:0]  awburst_debug_axis;
wire        awlock_debug_axis;
wire [3:0]  awcache_debug_axis;
wire [2:0]  awprot_debug_axis;
wire        awvalid_debug_axis;
wire        awready_debug_axis;
wire [63:0] wdata_debug_axis;
wire [7:0]  wstrb_debug_axis;
wire        wlast_debug_axis;
wire        wvalid_debug_axis;
wire        wready_debug_axis;
wire [1:0]  bresp_debug_axis;
wire        bvalid_debug_axis;
wire        bready_debug_axis;
wire [31:0] araddr_debug_axis;
wire [7:0]  arlen_debug_axis;
wire [2:0]  arsize_debug_axis;
wire [1:0]  arburst_debug_axis;
wire        arlock_debug_axis;
wire [3:0]  arcache_debug_axis;
wire [2:0]  arprot_debug_axis;
wire        arvalid_debug_axis;
wire        arready_debug_axis;
wire [63:0] rdata_debug_axis;
wire [1:0]  rresp_debug_axis;
wire        rlast_debug_axis;
wire        rvalid_debug_axis;
wire        rready_debug_axis;
wire [9:0]  awuser_debug_axis;
wire [9:0]  aruser_debug_axis;
wire        buser_debug_axis;
wire        ruser_debug_axis;






wire [31:0] paddr_extdbg_apb;
wire        pselx_extdbg_apb;
wire        penable_extdbg_apb;
wire        pwrite_extdbg_apb;
wire [31:0] prdata_extdbg_apb;
wire [31:0] pwdata_extdbg_apb;
wire [2:0]  pprot_extdbg_apb;
wire [3:0]  pstrb_extdbg_apb;
wire         pready_extdbg_apb;
wire         pslverr_extdbg_apb;


wire [GLOBAL_ID_WIDTH-1:0] awid_gic_axim;
wire [GIC_ADDR_WIDTH-1:0] awaddr_gic_axim;
wire [7:0]  awlen_gic_axim;
wire [2:0]  awsize_gic_axim;
wire [1:0]  awburst_gic_axim;
wire        awlock_gic_axim;
wire [3:0]  awcache_gic_axim;
wire [2:0]  awprot_gic_axim;
wire [3:0]  awqos_gic_axim;
wire        awvalid_gic_axim;
wire         awready_gic_axim;
wire [31:0] wdata_gic_axim;
wire [3:0]  wstrb_gic_axim;
wire        wlast_gic_axim;
wire        wvalid_gic_axim;
wire         wready_gic_axim;
wire  [GLOBAL_ID_WIDTH-1:0] bid_gic_axim;
wire  [1:0]  bresp_gic_axim;
wire         bvalid_gic_axim;
wire        bready_gic_axim;
wire [GLOBAL_ID_WIDTH-1:0] arid_gic_axim;
wire [31:0] araddr_gic_axim;
wire [7:0]  arlen_gic_axim;
wire [2:0]  arsize_gic_axim;
wire [1:0]  arburst_gic_axim;
wire        arlock_gic_axim;
wire [3:0]  arcache_gic_axim;
wire [2:0]  arprot_gic_axim;
wire [3:0]  arqos_gic_axim;
wire        arvalid_gic_axim;
wire         arready_gic_axim;
wire  [GLOBAL_ID_WIDTH-1:0] rid_gic_axim;
wire  [31:0] rdata_gic_axim;
wire  [1:0]  rresp_gic_axim;
wire         rlast_gic_axim;
wire         rvalid_gic_axim;
wire        rready_gic_axim;
wire [((GIC_AWUSER_WIDTH>0)?(GIC_AWUSER_WIDTH-1):0):0] awuser_gic_axim;
wire [((GIC_ARUSER_WIDTH>0)?(GIC_ARUSER_WIDTH-1):0):0] aruser_gic_axim;


wire [31:0] paddr_hostsysdbg_apb;
wire        pselx_hostsysdbg_apb;
wire        penable_hostsysdbg_apb;
wire        pwrite_hostsysdbg_apb;
wire  [31:0] prdata_hostsysdbg_apb;
wire [31:0] pwdata_hostsysdbg_apb;
wire [2:0]  pprot_hostsysdbg_apb;
wire [3:0]  pstrb_hostsysdbg_apb;
wire         pready_hostsysdbg_apb;
wire         pslverr_hostsysdbg_apb;


wire [31:0] paddr_hse_mhu0;
wire        pselx_hse_mhu0;
wire        penable_hse_mhu0;
wire        pwrite_hse_mhu0;
wire [31:0] prdata_hse_mhu0;
wire [31:0] pwdata_hse_mhu0;
wire [2:0]  pprot_hse_mhu0;
wire [3:0]  pstrb_hse_mhu0;
wire        pready_hse_mhu0;
wire        pslverr_hse_mhu0;


wire [31:0] paddr_hse_mhu1;
wire        pselx_hse_mhu1;
wire        penable_hse_mhu1;
wire        pwrite_hse_mhu1;
wire [31:0] prdata_hse_mhu1;
wire [31:0] pwdata_hse_mhu1;
wire [2:0]  pprot_hse_mhu1;
wire [3:0]  pstrb_hse_mhu1;
wire        pready_hse_mhu1;
wire        pslverr_hse_mhu1;


wire [31:0] paddr_sdc600_apb;
wire        pselx_sdc600_apb;
wire        penable_sdc600_apb;
wire        pwrite_sdc600_apb;
wire  [31:0] prdata_sdc600_apb;
wire [31:0] pwdata_sdc600_apb;
wire [2:0]  pprot_sdc600_apb;
wire [3:0]  pstrb_sdc600_apb;
wire         pready_sdc600_apb;
wire         pslverr_sdc600_apb;

wire [31:0] paddr_seh_mhu0;
wire        pselx_seh_mhu0;
wire        penable_seh_mhu0;
wire        pwrite_seh_mhu0;
wire  [31:0] prdata_seh_mhu0;
wire [31:0] pwdata_seh_mhu0;
wire [2:0]  pprot_seh_mhu0;
wire [3:0]  pstrb_seh_mhu0;
wire         pready_seh_mhu0;
wire         pslverr_seh_mhu0;


wire [31:0] paddr_seh_mhu1;
wire        pselx_seh_mhu1;
wire        penable_seh_mhu1;
wire        pwrite_seh_mhu1;
wire  [31:0] prdata_seh_mhu1;
wire [31:0] pwdata_seh_mhu1;
wire [2:0]  pprot_seh_mhu1;
wire [3:0]  pstrb_seh_mhu1;
wire         pready_seh_mhu1;
wire         pslverr_seh_mhu1;


wire [STM_AXI_ID_WIDTH-1:0] awid_stm_axim;
wire [31:0] awaddr_stm_axim;
wire [7:0]  awlen_stm_axim;
wire [2:0]  awsize_stm_axim;
wire [1:0]  awburst_stm_axim;
wire        awlock_stm_axim;
wire [3:0]  awcache_stm_axim;
wire [2:0]  awprot_stm_axim;
wire        awvalid_stm_axim;
wire        awready_stm_axim;
wire [63:0] wdata_stm_axim;
wire [7:0]  wstrb_stm_axim;
wire        wlast_stm_axim;
wire        wvalid_stm_axim;
wire        wready_stm_axim;
wire [STM_AXI_ID_WIDTH-1:0] bid_stm_axim;
wire [1:0]  bresp_stm_axim;
wire        bvalid_stm_axim;
wire        bready_stm_axim;
wire [STM_AXI_ID_WIDTH-1:0] arid_stm_axim;
wire [31:0] araddr_stm_axim;
wire [7:0]  arlen_stm_axim;
wire [2:0]  arsize_stm_axim;
wire [1:0]  arburst_stm_axim;
wire        arlock_stm_axim;
wire [3:0]  arcache_stm_axim;
wire [2:0]  arprot_stm_axim;
wire        arvalid_stm_axim;
wire        arready_stm_axim;
wire [STM_AXI_ID_WIDTH-1:0] rid_stm_axim;
wire [63:0] rdata_stm_axim;
wire [1:0]  rresp_stm_axim;
wire        rlast_stm_axim;
wire        rvalid_stm_axim;
wire        rready_stm_axim;
wire [9:0]  awuser_stm_axim;
wire [9:0]  aruser_stm_axim;



wire  [31:0] paddr_es0h_mhu0;
wire         pselx_es0h_mhu0;
wire         penable_es0h_mhu0;
wire         pwrite_es0h_mhu0;
wire  [31:0] prdata_es0h_mhu0;
wire  [31:0] pwdata_es0h_mhu0;
wire  [2:0]  pprot_es0h_mhu0;
wire  [3:0]  pstrb_es0h_mhu0;
wire         pready_es0h_mhu0;
wire         pslverr_es0h_mhu0;


wire  [31:0] paddr_hes0_mhu0;
wire         pselx_hes0_mhu0;
wire         penable_hes0_mhu0;
wire         pwrite_hes0_mhu0;
wire  [31:0] prdata_hes0_mhu0;
wire  [31:0] pwdata_hes0_mhu0;
wire  [2:0]  pprot_hes0_mhu0;
wire  [3:0]  pstrb_hes0_mhu0;
wire         pready_hes0_mhu0;
wire         pslverr_hes0_mhu0;

  

wire  [31:0] paddr_es0h_mhu1;
wire         pselx_es0h_mhu1;
wire         penable_es0h_mhu1;
wire         pwrite_es0h_mhu1;
wire  [31:0] prdata_es0h_mhu1;
wire  [31:0] pwdata_es0h_mhu1;
wire  [2:0]  pprot_es0h_mhu1;
wire  [3:0]  pstrb_es0h_mhu1;
wire         pready_es0h_mhu1;
wire         pslverr_es0h_mhu1;


wire  [31:0] paddr_hes0_mhu1;
wire         pselx_hes0_mhu1;
wire         penable_hes0_mhu1;
wire         pwrite_hes0_mhu1;
wire  [31:0] prdata_hes0_mhu1;
wire  [31:0] pwdata_hes0_mhu1;
wire  [2:0]  pprot_hes0_mhu1;
wire  [3:0]  pstrb_hes0_mhu1;
wire         pready_hes0_mhu1;
wire         pslverr_hes0_mhu1;
  
wire  [31:0] paddr_es1h_mhu0;
wire         pselx_es1h_mhu0;
wire         penable_es1h_mhu0;
wire         pwrite_es1h_mhu0;
wire  [31:0] prdata_es1h_mhu0;
wire  [31:0] pwdata_es1h_mhu0;
wire  [2:0]  pprot_es1h_mhu0;
wire  [3:0]  pstrb_es1h_mhu0;
wire         pready_es1h_mhu0;
wire         pslverr_es1h_mhu0;


wire  [31:0] paddr_hes1_mhu0;
wire         pselx_hes1_mhu0;
wire         penable_hes1_mhu0;
wire         pwrite_hes1_mhu0;
wire  [31:0] prdata_hes1_mhu0;
wire  [31:0] pwdata_hes1_mhu0;
wire  [2:0]  pprot_hes1_mhu0;
wire  [3:0]  pstrb_hes1_mhu0;
wire         pready_hes1_mhu0;
wire         pslverr_hes1_mhu0;

  

wire  [31:0] paddr_es1h_mhu1;
wire         pselx_es1h_mhu1;
wire         penable_es1h_mhu1;
wire         pwrite_es1h_mhu1;
wire  [31:0] prdata_es1h_mhu1;
wire  [31:0] pwdata_es1h_mhu1;
wire  [2:0]  pprot_es1h_mhu1;
wire  [3:0]  pstrb_es1h_mhu1;
wire         pready_es1h_mhu1;
wire         pslverr_es1h_mhu1;


wire  [31:0] paddr_hes1_mhu1;
wire         pselx_hes1_mhu1;
wire         penable_hes1_mhu1;
wire         pwrite_hes1_mhu1;
wire  [31:0] prdata_hes1_mhu1;
wire  [31:0] pwdata_hes1_mhu1;
wire  [2:0]  pprot_hes1_mhu1;
wire  [3:0]  pstrb_hes1_mhu1;
wire         pready_hes1_mhu1;
wire         pslverr_hes1_mhu1;
  

wire [31:0] paddr_ppu_cpu_apb;
wire        pselx_ppu_cpu_apb;
wire        penable_ppu_cpu_apb;
wire        pwrite_ppu_cpu_apb;
wire [31:0] prdata_ppu_cpu_apb;
wire [31:0] pwdata_ppu_cpu_apb;
wire [2:0]  pprot_ppu_cpu_apb;
wire        pready_ppu_cpu_apb;
wire        pslverr_ppu_cpu_apb;



wire [27:0] paddr_sysctrl_apb;
wire [31:0] pwdata_sysctrl_apb;
wire        pwrite_sysctrl_apb;
wire [2:0]  pprot_sysctrl_apb;
wire [3:0]  pstrb_sysctrl_apb;
wire        penable_sysctrl_apb;
wire        pselx_sysctrl_apb;
wire [31:0] prdata_sysctrl_apb;
wire        pslverr_sysctrl_apb;
wire        pready_sysctrl_apb;

wire [16:0] paddr_uart_apb;
wire [31:0] pwdata_uart_apb;
wire        pwrite_uart_apb;
wire [2:0]  pprot_uart_apb;
wire [3:0]  pstrb_uart_apb;
wire        penable_uart_apb;
wire        pselx_uart_apb;
wire [31:0] prdata_uart_apb;
wire        pslverr_uart_apb;
wire        pready_uart_apb;

wire        awakeup_extsys0_axis;
wire [EXT_SYS0_MEM_AWID_WIDTH-1:0]  awid_extsys0_axis;
wire [31:0] awaddr_extsys0_axis;
wire [7:0]  awlen_extsys0_axis;
wire [2:0]  awsize_extsys0_axis;
wire [1:0]  awburst_extsys0_axis;
wire        awlock_extsys0_axis;
wire [3:0]  awcache_extsys0_axis;
wire [2:0]  awprot_extsys0_axis;
wire        awvalid_extsys0_axis;
wire        awready_extsys0_axis;
wire [EXT_SYS0_MEM_DATA_WIDTH-1:0] wdata_extsys0_axis;
wire [(EXT_SYS0_MEM_DATA_WIDTH/8)-1:0]  wstrb_extsys0_axis;
wire        wlast_extsys0_axis;
wire        wvalid_extsys0_axis;
wire        wready_extsys0_axis;
wire [EXT_SYS0_MEM_AWID_WIDTH-1:0]  bid_extsys0_axis;
wire [1:0]  bresp_extsys0_axis;
wire        bvalid_extsys0_axis;
wire        bready_extsys0_axis;
wire [EXT_SYS0_MEM_ARID_WIDTH-1:0]  arid_extsys0_axis;
wire [31:0] araddr_extsys0_axis;
wire [7:0]  arlen_extsys0_axis;
wire [2:0]  arsize_extsys0_axis;
wire [1:0]  arburst_extsys0_axis;
wire        arlock_extsys0_axis;
wire [3:0]  arcache_extsys0_axis;
wire [2:0]  arprot_extsys0_axis;
wire        arvalid_extsys0_axis;
wire        arready_extsys0_axis;
wire [EXT_SYS0_MEM_ARID_WIDTH-1:0]  rid_extsys0_axis;
wire [EXT_SYS0_MEM_DATA_WIDTH-1:0] rdata_extsys0_axis;
wire [1:0]  rresp_extsys0_axis;
wire        rlast_extsys0_axis;
wire        rvalid_extsys0_axis;
wire        rready_extsys0_axis;
wire [9:0]  awuser_extsys0_axis;
wire [9:0]  aruser_extsys0_axis;

wire        awakeup_extsys1_axis;
wire [EXT_SYS1_MEM_AWID_WIDTH-1:0]  awid_extsys1_axis;
wire [31:0] awaddr_extsys1_axis;
wire [7:0]  awlen_extsys1_axis;
wire [2:0]  awsize_extsys1_axis;
wire [1:0]  awburst_extsys1_axis;
wire        awlock_extsys1_axis;
wire [3:0]  awcache_extsys1_axis;
wire [2:0]  awprot_extsys1_axis;
wire        awvalid_extsys1_axis;
wire        awready_extsys1_axis;
wire [EXT_SYS1_MEM_DATA_WIDTH-1:0] wdata_extsys1_axis;
wire [(EXT_SYS1_MEM_DATA_WIDTH/8)-1:0]  wstrb_extsys1_axis;
wire        wlast_extsys1_axis;
wire        wvalid_extsys1_axis;
wire        wready_extsys1_axis;
wire [EXT_SYS1_MEM_AWID_WIDTH-1:0]  bid_extsys1_axis;
wire [1:0]  bresp_extsys1_axis;
wire        bvalid_extsys1_axis;
wire        bready_extsys1_axis;
wire [EXT_SYS1_MEM_ARID_WIDTH-1:0]  arid_extsys1_axis;
wire [31:0] araddr_extsys1_axis;
wire [7:0]  arlen_extsys1_axis;
wire [2:0]  arsize_extsys1_axis;
wire [1:0]  arburst_extsys1_axis;
wire        arlock_extsys1_axis;
wire [3:0]  arcache_extsys1_axis;
wire [2:0]  arprot_extsys1_axis;
wire        arvalid_extsys1_axis;
wire        arready_extsys1_axis;
wire [EXT_SYS1_MEM_ARID_WIDTH-1:0]  rid_extsys1_axis;
wire [EXT_SYS1_MEM_DATA_WIDTH-1:0] rdata_extsys1_axis;
wire [1:0]  rresp_extsys1_axis;
wire        rlast_extsys1_axis;
wire        rvalid_extsys1_axis;
wire        rready_extsys1_axis;
wire [9:0]  awuser_extsys1_axis;
wire [9:0]  aruser_extsys1_axis;

wire        tvalid_dti_dn_m;
wire        tready_dti_dn_m;
wire [31:0] tdata_dti_dn_m;
wire [3:0]  tkeep_dti_dn_m;
wire [3:0]  tid_dti_dn_m;
wire        tlast_dti_dn_m;
wire        twakeup_dti_dn_m;
wire         tvalid_dti_up_m;
wire         tready_dti_up_m;
wire [31:0]  tdata_dti_up_m;
wire [3:0]   tkeep_dti_up_m;
wire [3:0]   tdest_dti_up_m;
wire         tlast_dti_up_m;
wire         twakeup_dti_up_m;

wire [9:0]   hostcpu_gicintmhus;                           
wire [9:0]   hostcpu_gicintmhuns;                          

wire aresetn;
wire ctrlresetn;
wire ctrlclk;
wire aclk;
wire cactive_cd_maingpv;
wire pc_cpu_ctrlclk_qactive;


wire [3:0] hostcpu_ctichout_buf;
wire [3:0] hostcpu_ctichinack_buf;
wire [4:0] gicclk_div0_clkdiv_cur_buf;
wire [1:0] gicclk_ctrl_clkselect_cur_buf;
wire [4:0] hostcpuclk_div1_clkdiv_cur_buf;
wire [4:0] hostcpuclk_div0_clkdiv_cur_buf;
wire [2:0] hostcpuclk_ctrl_clkselect_cur_buf;

wire dft_pcg_en;


arm_element_reset_sync u_aresetn_sync (
  .clk             (aclk ),            
  .resetn_async    (systop_warmresetn),
  .resetn_sync     (aresetn),          

  .dftrstdisable   (dftrstdisable[0])  
);

arm_element_reset_sync u_ctrlresetn_sync (
  .clk             (ctrlclk ),            
  .resetn_async    (systop_warmresetn),
  .resetn_sync     (ctrlresetn),          

  .dftrstdisable   (dftrstdisable[0])  
);


wire [6*41-1:0] debug_hostcpu_atb_fwd_data_buf;
wire [1:0]      hostcpu_dbgtrace_egress_comb_qacceptn_buf;
wire [1:0]      hostcpu_dbgtrace_egress_comb_qdeny_buf;
wire [1:0]      hostcpu_dbgtrace_egress_comb_qactive_buf;
wire            debug_hostcpu_async_ack_buf;
wire [32:0]     debug_hostcpu_async_resp_payload_buf;
wire            debug_hostcpu_flush_done_buf;
wire [2:0]      hostcpu_gicintdbgtop_pulse_ack_buf;
wire            debug_hostcpu_sync_clear_buf;
wire            debug_hostcpu_syncreq_async_ack_buf;
wire [3:0]      debug_hostcpu_wr_pointer_gray_buf;


arm_element_std_buffer u_hostcpu_ctichout_buf3 (
  .buf_in   (hostcpu_ctichout_buf[3]),
  .buf_out  (hostcpu_ctichout[3])
);
arm_element_std_buffer u_hostcpu_ctichout_buf2 (
  .buf_in   (hostcpu_ctichout_buf[2]),
  .buf_out  (hostcpu_ctichout[2])
);
arm_element_std_buffer u_hostcpu_ctichout_buf1 (
  .buf_in   (hostcpu_ctichout_buf[1]),
  .buf_out  (hostcpu_ctichout[1])
);
arm_element_std_buffer u_hostcpu_ctichout_buf0 (
  .buf_in   (hostcpu_ctichout_buf[0]),
  .buf_out  (hostcpu_ctichout[0])
);


arm_element_std_buffer u_hostcpu_ctichinack_buf3 (
  .buf_in   (hostcpu_ctichinack_buf[3]),
  .buf_out  (hostcpu_ctichinack[3])
);
arm_element_std_buffer u_hostcpu_ctichinack_buf2 (
  .buf_in   (hostcpu_ctichinack_buf[2]),
  .buf_out  (hostcpu_ctichinack[2])
);
arm_element_std_buffer u_hostcpu_ctichinack_buf1 (
  .buf_in   (hostcpu_ctichinack_buf[1]),
  .buf_out  (hostcpu_ctichinack[1])
);
arm_element_std_buffer u_hostcpu_ctichinack_buf0 (
  .buf_in   (hostcpu_ctichinack_buf[0]),
  .buf_out  (hostcpu_ctichinack[0])
);


arm_element_std_buffer u_gicclk_ctrl_clkselect_cur_buf1 (
  .buf_in   (gicclk_ctrl_clkselect_cur_buf[1]),
  .buf_out  (gicclk_ctrl_clkselect_cur[1])
);
arm_element_std_buffer u_gicclk_ctrl_clkselect_cur_buf0 (
  .buf_in   (gicclk_ctrl_clkselect_cur_buf[0]),
  .buf_out  (gicclk_ctrl_clkselect_cur[0])
);


arm_element_std_buffer u_gicclk_div0_clkdiv_cur_buf4 (
  .buf_in   (gicclk_div0_clkdiv_cur_buf[4]),
  .buf_out  (gicclk_div0_clkdiv_cur[4])
);
arm_element_std_buffer u_gicclk_div0_clkdiv_cur_buf3 (
  .buf_in   (gicclk_div0_clkdiv_cur_buf[3]),
  .buf_out  (gicclk_div0_clkdiv_cur[3])
);
arm_element_std_buffer u_gicclk_div0_clkdiv_cur_buf2 (
  .buf_in   (gicclk_div0_clkdiv_cur_buf[2]),
  .buf_out  (gicclk_div0_clkdiv_cur[2])
);
arm_element_std_buffer u_gicclk_div0_clkdiv_cur_buf1 (
  .buf_in   (gicclk_div0_clkdiv_cur_buf[1]),
  .buf_out  (gicclk_div0_clkdiv_cur[1])
);
arm_element_std_buffer u_gicclk_div0_clkdiv_cur_buf0 (
  .buf_in   (gicclk_div0_clkdiv_cur_buf[0]),
  .buf_out  (gicclk_div0_clkdiv_cur[0])
);


arm_element_std_buffer u_hostcpuclk_div0_clkdiv_cur_buf4 (
  .buf_in   (hostcpuclk_div0_clkdiv_cur_buf[4]),
  .buf_out  (hostcpuclk_div0_clkdiv_cur[4])
);
arm_element_std_buffer u_hostcpuclk_div0_clkdiv_cur_buf3 (
  .buf_in   (hostcpuclk_div0_clkdiv_cur_buf[3]),
  .buf_out  (hostcpuclk_div0_clkdiv_cur[3])
);
arm_element_std_buffer u_hostcpuclk_div0_clkdiv_cur_buf2 (
  .buf_in   (hostcpuclk_div0_clkdiv_cur_buf[2]),
  .buf_out  (hostcpuclk_div0_clkdiv_cur[2])
);
arm_element_std_buffer u_hostcpuclk_div0_clkdiv_cur_buf1 (
  .buf_in   (hostcpuclk_div0_clkdiv_cur_buf[1]),
  .buf_out  (hostcpuclk_div0_clkdiv_cur[1])
);
arm_element_std_buffer u_hostcpuclk_div0_clkdiv_cur_buf0 (
  .buf_in   (hostcpuclk_div0_clkdiv_cur_buf[0]),
  .buf_out  (hostcpuclk_div0_clkdiv_cur[0])
);


arm_element_std_buffer u_hostcpuclk_div1_clkdiv_cur_buf4 (
  .buf_in   (hostcpuclk_div1_clkdiv_cur_buf[4]),
  .buf_out  (hostcpuclk_div1_clkdiv_cur[4])
);
arm_element_std_buffer u_hostcpuclk_div1_clkdiv_cur_buf3 (
  .buf_in   (hostcpuclk_div1_clkdiv_cur_buf[3]),
  .buf_out  (hostcpuclk_div1_clkdiv_cur[3])
);
arm_element_std_buffer u_hostcpuclk_div1_clkdiv_cur_buf2 (
  .buf_in   (hostcpuclk_div1_clkdiv_cur_buf[2]),
  .buf_out  (hostcpuclk_div1_clkdiv_cur[2])
);
arm_element_std_buffer u_hostcpuclk_div1_clkdiv_cur_buf1 (
  .buf_in   (hostcpuclk_div1_clkdiv_cur_buf[1]),
  .buf_out  (hostcpuclk_div1_clkdiv_cur[1])
);
arm_element_std_buffer u_hostcpuclk_div1_clkdiv_cur_buf0 (
  .buf_in   (hostcpuclk_div1_clkdiv_cur_buf[0]),
  .buf_out  (hostcpuclk_div1_clkdiv_cur[0])
);


arm_element_std_buffer u_hostcpuclk_ctrl_clkselect_cur_buf2 (
  .buf_in   (hostcpuclk_ctrl_clkselect_cur_buf[2]),
  .buf_out  (hostcpuclk_ctrl_clkselect_cur[2])
);
arm_element_std_buffer u_hostcpuclk_ctrl_clkselect_cur_buf1 (
  .buf_in   (hostcpuclk_ctrl_clkselect_cur_buf[1]),
  .buf_out  (hostcpuclk_ctrl_clkselect_cur[1])
);
arm_element_std_buffer u_hostcpuclk_ctrl_clkselect_cur_buf0 (
  .buf_in   (hostcpuclk_ctrl_clkselect_cur_buf[0]),
  .buf_out  (hostcpuclk_ctrl_clkselect_cur[0])
);

arm_element_std_buffer u_debug_hostcpu_wr_pointer_gray_buf0 (
  .buf_in   (debug_hostcpu_wr_pointer_gray_buf[0]),
  .buf_out  (debug_hostcpu_wr_pointer_gray[0])
);

arm_element_std_buffer u_debug_hostcpu_wr_pointer_gray_buf1 (
  .buf_in   (debug_hostcpu_wr_pointer_gray_buf[1]),
  .buf_out  (debug_hostcpu_wr_pointer_gray[1])
);

arm_element_std_buffer u_debug_hostcpu_wr_pointer_gray_buf2 (
  .buf_in   (debug_hostcpu_wr_pointer_gray_buf[2]),
  .buf_out  (debug_hostcpu_wr_pointer_gray[2])
);

arm_element_std_buffer u_debug_hostcpu_wr_pointer_gray_buf3 (
  .buf_in   (debug_hostcpu_wr_pointer_gray_buf[3]),
  .buf_out  (debug_hostcpu_wr_pointer_gray[3])
);

arm_element_std_buffer u_debug_hostcpu_syncreq_async_ack_buf (
  .buf_in   (debug_hostcpu_syncreq_async_ack_buf),
  .buf_out  (debug_hostcpu_syncreq_async_ack)
);

arm_element_std_buffer u_debug_hostcpu_sync_clear_buf (
  .buf_in   (debug_hostcpu_sync_clear_buf),
  .buf_out  (debug_hostcpu_sync_clear)
);

arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf0 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[0]),
  .buf_out  (debug_hostcpu_atb_fwd_data[0])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf1 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[1]),
  .buf_out  (debug_hostcpu_atb_fwd_data[1])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf2 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[2]),
  .buf_out  (debug_hostcpu_atb_fwd_data[2])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf3 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[3]),
  .buf_out  (debug_hostcpu_atb_fwd_data[3])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf4 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[4]),
  .buf_out  (debug_hostcpu_atb_fwd_data[4])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf5 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[5]),
  .buf_out  (debug_hostcpu_atb_fwd_data[5])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf6 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[6]),
  .buf_out  (debug_hostcpu_atb_fwd_data[6])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf7 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[7]),
  .buf_out  (debug_hostcpu_atb_fwd_data[7])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf8 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[8]),
  .buf_out  (debug_hostcpu_atb_fwd_data[8])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf9 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[9]),
  .buf_out  (debug_hostcpu_atb_fwd_data[9])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf10 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[10]),
  .buf_out  (debug_hostcpu_atb_fwd_data[10])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf11 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[11]),
  .buf_out  (debug_hostcpu_atb_fwd_data[11])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf12 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[12]),
  .buf_out  (debug_hostcpu_atb_fwd_data[12])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf13 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[13]),
  .buf_out  (debug_hostcpu_atb_fwd_data[13])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf14 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[14]),
  .buf_out  (debug_hostcpu_atb_fwd_data[14])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf15 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[15]),
  .buf_out  (debug_hostcpu_atb_fwd_data[15])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf16 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[16]),
  .buf_out  (debug_hostcpu_atb_fwd_data[16])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf17 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[17]),
  .buf_out  (debug_hostcpu_atb_fwd_data[17])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf18 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[18]),
  .buf_out  (debug_hostcpu_atb_fwd_data[18])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf19 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[19]),
  .buf_out  (debug_hostcpu_atb_fwd_data[19])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf20 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[20]),
  .buf_out  (debug_hostcpu_atb_fwd_data[20])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf21 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[21]),
  .buf_out  (debug_hostcpu_atb_fwd_data[21])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf22 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[22]),
  .buf_out  (debug_hostcpu_atb_fwd_data[22])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf23 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[23]),
  .buf_out  (debug_hostcpu_atb_fwd_data[23])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf24 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[24]),
  .buf_out  (debug_hostcpu_atb_fwd_data[24])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf25 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[25]),
  .buf_out  (debug_hostcpu_atb_fwd_data[25])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf26 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[26]),
  .buf_out  (debug_hostcpu_atb_fwd_data[26])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf27 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[27]),
  .buf_out  (debug_hostcpu_atb_fwd_data[27])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf28 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[28]),
  .buf_out  (debug_hostcpu_atb_fwd_data[28])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf29 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[29]),
  .buf_out  (debug_hostcpu_atb_fwd_data[29])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf30 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[30]),
  .buf_out  (debug_hostcpu_atb_fwd_data[30])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf31 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[31]),
  .buf_out  (debug_hostcpu_atb_fwd_data[31])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf32 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[32]),
  .buf_out  (debug_hostcpu_atb_fwd_data[32])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf33 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[33]),
  .buf_out  (debug_hostcpu_atb_fwd_data[33])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf34 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[34]),
  .buf_out  (debug_hostcpu_atb_fwd_data[34])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf35 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[35]),
  .buf_out  (debug_hostcpu_atb_fwd_data[35])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf36 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[36]),
  .buf_out  (debug_hostcpu_atb_fwd_data[36])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf37 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[37]),
  .buf_out  (debug_hostcpu_atb_fwd_data[37])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf38 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[38]),
  .buf_out  (debug_hostcpu_atb_fwd_data[38])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf39 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[39]),
  .buf_out  (debug_hostcpu_atb_fwd_data[39])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf40 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[40]),
  .buf_out  (debug_hostcpu_atb_fwd_data[40])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf41 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[41]),
  .buf_out  (debug_hostcpu_atb_fwd_data[41])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf42 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[42]),
  .buf_out  (debug_hostcpu_atb_fwd_data[42])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf43 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[43]),
  .buf_out  (debug_hostcpu_atb_fwd_data[43])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf44 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[44]),
  .buf_out  (debug_hostcpu_atb_fwd_data[44])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf45 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[45]),
  .buf_out  (debug_hostcpu_atb_fwd_data[45])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf46 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[46]),
  .buf_out  (debug_hostcpu_atb_fwd_data[46])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf47 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[47]),
  .buf_out  (debug_hostcpu_atb_fwd_data[47])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf48 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[48]),
  .buf_out  (debug_hostcpu_atb_fwd_data[48])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf49 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[49]),
  .buf_out  (debug_hostcpu_atb_fwd_data[49])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf50 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[50]),
  .buf_out  (debug_hostcpu_atb_fwd_data[50])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf51 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[51]),
  .buf_out  (debug_hostcpu_atb_fwd_data[51])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf52 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[52]),
  .buf_out  (debug_hostcpu_atb_fwd_data[52])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf53 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[53]),
  .buf_out  (debug_hostcpu_atb_fwd_data[53])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf54 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[54]),
  .buf_out  (debug_hostcpu_atb_fwd_data[54])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf55 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[55]),
  .buf_out  (debug_hostcpu_atb_fwd_data[55])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf56 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[56]),
  .buf_out  (debug_hostcpu_atb_fwd_data[56])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf57 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[57]),
  .buf_out  (debug_hostcpu_atb_fwd_data[57])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf58 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[58]),
  .buf_out  (debug_hostcpu_atb_fwd_data[58])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf59 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[59]),
  .buf_out  (debug_hostcpu_atb_fwd_data[59])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf60 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[60]),
  .buf_out  (debug_hostcpu_atb_fwd_data[60])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf61 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[61]),
  .buf_out  (debug_hostcpu_atb_fwd_data[61])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf62 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[62]),
  .buf_out  (debug_hostcpu_atb_fwd_data[62])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf63 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[63]),
  .buf_out  (debug_hostcpu_atb_fwd_data[63])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf64 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[64]),
  .buf_out  (debug_hostcpu_atb_fwd_data[64])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf65 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[65]),
  .buf_out  (debug_hostcpu_atb_fwd_data[65])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf66 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[66]),
  .buf_out  (debug_hostcpu_atb_fwd_data[66])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf67 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[67]),
  .buf_out  (debug_hostcpu_atb_fwd_data[67])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf68 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[68]),
  .buf_out  (debug_hostcpu_atb_fwd_data[68])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf69 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[69]),
  .buf_out  (debug_hostcpu_atb_fwd_data[69])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf70 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[70]),
  .buf_out  (debug_hostcpu_atb_fwd_data[70])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf71 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[71]),
  .buf_out  (debug_hostcpu_atb_fwd_data[71])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf72 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[72]),
  .buf_out  (debug_hostcpu_atb_fwd_data[72])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf73 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[73]),
  .buf_out  (debug_hostcpu_atb_fwd_data[73])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf74 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[74]),
  .buf_out  (debug_hostcpu_atb_fwd_data[74])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf75 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[75]),
  .buf_out  (debug_hostcpu_atb_fwd_data[75])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf76 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[76]),
  .buf_out  (debug_hostcpu_atb_fwd_data[76])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf77 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[77]),
  .buf_out  (debug_hostcpu_atb_fwd_data[77])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf78 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[78]),
  .buf_out  (debug_hostcpu_atb_fwd_data[78])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf79 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[79]),
  .buf_out  (debug_hostcpu_atb_fwd_data[79])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf80 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[80]),
  .buf_out  (debug_hostcpu_atb_fwd_data[80])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf81 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[81]),
  .buf_out  (debug_hostcpu_atb_fwd_data[81])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf82 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[82]),
  .buf_out  (debug_hostcpu_atb_fwd_data[82])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf83 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[83]),
  .buf_out  (debug_hostcpu_atb_fwd_data[83])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf84 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[84]),
  .buf_out  (debug_hostcpu_atb_fwd_data[84])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf85 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[85]),
  .buf_out  (debug_hostcpu_atb_fwd_data[85])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf86 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[86]),
  .buf_out  (debug_hostcpu_atb_fwd_data[86])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf87 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[87]),
  .buf_out  (debug_hostcpu_atb_fwd_data[87])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf88 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[88]),
  .buf_out  (debug_hostcpu_atb_fwd_data[88])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf89 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[89]),
  .buf_out  (debug_hostcpu_atb_fwd_data[89])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf90 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[90]),
  .buf_out  (debug_hostcpu_atb_fwd_data[90])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf91 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[91]),
  .buf_out  (debug_hostcpu_atb_fwd_data[91])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf92 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[92]),
  .buf_out  (debug_hostcpu_atb_fwd_data[92])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf93 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[93]),
  .buf_out  (debug_hostcpu_atb_fwd_data[93])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf94 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[94]),
  .buf_out  (debug_hostcpu_atb_fwd_data[94])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf95 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[95]),
  .buf_out  (debug_hostcpu_atb_fwd_data[95])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf96 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[96]),
  .buf_out  (debug_hostcpu_atb_fwd_data[96])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf97 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[97]),
  .buf_out  (debug_hostcpu_atb_fwd_data[97])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf98 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[98]),
  .buf_out  (debug_hostcpu_atb_fwd_data[98])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf99 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[99]),
  .buf_out  (debug_hostcpu_atb_fwd_data[99])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf100 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[100]),
  .buf_out  (debug_hostcpu_atb_fwd_data[100])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf101 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[101]),
  .buf_out  (debug_hostcpu_atb_fwd_data[101])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf102 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[102]),
  .buf_out  (debug_hostcpu_atb_fwd_data[102])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf103 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[103]),
  .buf_out  (debug_hostcpu_atb_fwd_data[103])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf104 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[104]),
  .buf_out  (debug_hostcpu_atb_fwd_data[104])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf105 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[105]),
  .buf_out  (debug_hostcpu_atb_fwd_data[105])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf106 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[106]),
  .buf_out  (debug_hostcpu_atb_fwd_data[106])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf107 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[107]),
  .buf_out  (debug_hostcpu_atb_fwd_data[107])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf108 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[108]),
  .buf_out  (debug_hostcpu_atb_fwd_data[108])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf109 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[109]),
  .buf_out  (debug_hostcpu_atb_fwd_data[109])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf110 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[110]),
  .buf_out  (debug_hostcpu_atb_fwd_data[110])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf111 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[111]),
  .buf_out  (debug_hostcpu_atb_fwd_data[111])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf112 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[112]),
  .buf_out  (debug_hostcpu_atb_fwd_data[112])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf113 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[113]),
  .buf_out  (debug_hostcpu_atb_fwd_data[113])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf114 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[114]),
  .buf_out  (debug_hostcpu_atb_fwd_data[114])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf115 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[115]),
  .buf_out  (debug_hostcpu_atb_fwd_data[115])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf116 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[116]),
  .buf_out  (debug_hostcpu_atb_fwd_data[116])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf117 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[117]),
  .buf_out  (debug_hostcpu_atb_fwd_data[117])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf118 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[118]),
  .buf_out  (debug_hostcpu_atb_fwd_data[118])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf119 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[119]),
  .buf_out  (debug_hostcpu_atb_fwd_data[119])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf120 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[120]),
  .buf_out  (debug_hostcpu_atb_fwd_data[120])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf121 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[121]),
  .buf_out  (debug_hostcpu_atb_fwd_data[121])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf122 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[122]),
  .buf_out  (debug_hostcpu_atb_fwd_data[122])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf123 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[123]),
  .buf_out  (debug_hostcpu_atb_fwd_data[123])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf124 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[124]),
  .buf_out  (debug_hostcpu_atb_fwd_data[124])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf125 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[125]),
  .buf_out  (debug_hostcpu_atb_fwd_data[125])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf126 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[126]),
  .buf_out  (debug_hostcpu_atb_fwd_data[126])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf127 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[127]),
  .buf_out  (debug_hostcpu_atb_fwd_data[127])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf128 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[128]),
  .buf_out  (debug_hostcpu_atb_fwd_data[128])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf129 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[129]),
  .buf_out  (debug_hostcpu_atb_fwd_data[129])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf130 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[130]),
  .buf_out  (debug_hostcpu_atb_fwd_data[130])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf131 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[131]),
  .buf_out  (debug_hostcpu_atb_fwd_data[131])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf132 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[132]),
  .buf_out  (debug_hostcpu_atb_fwd_data[132])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf133 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[133]),
  .buf_out  (debug_hostcpu_atb_fwd_data[133])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf134 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[134]),
  .buf_out  (debug_hostcpu_atb_fwd_data[134])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf135 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[135]),
  .buf_out  (debug_hostcpu_atb_fwd_data[135])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf136 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[136]),
  .buf_out  (debug_hostcpu_atb_fwd_data[136])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf137 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[137]),
  .buf_out  (debug_hostcpu_atb_fwd_data[137])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf138 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[138]),
  .buf_out  (debug_hostcpu_atb_fwd_data[138])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf139 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[139]),
  .buf_out  (debug_hostcpu_atb_fwd_data[139])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf140 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[140]),
  .buf_out  (debug_hostcpu_atb_fwd_data[140])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf141 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[141]),
  .buf_out  (debug_hostcpu_atb_fwd_data[141])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf142 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[142]),
  .buf_out  (debug_hostcpu_atb_fwd_data[142])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf143 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[143]),
  .buf_out  (debug_hostcpu_atb_fwd_data[143])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf144 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[144]),
  .buf_out  (debug_hostcpu_atb_fwd_data[144])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf145 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[145]),
  .buf_out  (debug_hostcpu_atb_fwd_data[145])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf146 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[146]),
  .buf_out  (debug_hostcpu_atb_fwd_data[146])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf147 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[147]),
  .buf_out  (debug_hostcpu_atb_fwd_data[147])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf148 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[148]),
  .buf_out  (debug_hostcpu_atb_fwd_data[148])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf149 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[149]),
  .buf_out  (debug_hostcpu_atb_fwd_data[149])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf150 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[150]),
  .buf_out  (debug_hostcpu_atb_fwd_data[150])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf151 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[151]),
  .buf_out  (debug_hostcpu_atb_fwd_data[151])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf152 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[152]),
  .buf_out  (debug_hostcpu_atb_fwd_data[152])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf153 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[153]),
  .buf_out  (debug_hostcpu_atb_fwd_data[153])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf154 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[154]),
  .buf_out  (debug_hostcpu_atb_fwd_data[154])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf155 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[155]),
  .buf_out  (debug_hostcpu_atb_fwd_data[155])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf156 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[156]),
  .buf_out  (debug_hostcpu_atb_fwd_data[156])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf157 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[157]),
  .buf_out  (debug_hostcpu_atb_fwd_data[157])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf158 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[158]),
  .buf_out  (debug_hostcpu_atb_fwd_data[158])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf159 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[159]),
  .buf_out  (debug_hostcpu_atb_fwd_data[159])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf160 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[160]),
  .buf_out  (debug_hostcpu_atb_fwd_data[160])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf161 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[161]),
  .buf_out  (debug_hostcpu_atb_fwd_data[161])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf162 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[162]),
  .buf_out  (debug_hostcpu_atb_fwd_data[162])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf163 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[163]),
  .buf_out  (debug_hostcpu_atb_fwd_data[163])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf164 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[164]),
  .buf_out  (debug_hostcpu_atb_fwd_data[164])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf165 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[165]),
  .buf_out  (debug_hostcpu_atb_fwd_data[165])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf166 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[166]),
  .buf_out  (debug_hostcpu_atb_fwd_data[166])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf167 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[167]),
  .buf_out  (debug_hostcpu_atb_fwd_data[167])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf168 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[168]),
  .buf_out  (debug_hostcpu_atb_fwd_data[168])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf169 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[169]),
  .buf_out  (debug_hostcpu_atb_fwd_data[169])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf170 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[170]),
  .buf_out  (debug_hostcpu_atb_fwd_data[170])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf171 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[171]),
  .buf_out  (debug_hostcpu_atb_fwd_data[171])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf172 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[172]),
  .buf_out  (debug_hostcpu_atb_fwd_data[172])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf173 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[173]),
  .buf_out  (debug_hostcpu_atb_fwd_data[173])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf174 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[174]),
  .buf_out  (debug_hostcpu_atb_fwd_data[174])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf175 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[175]),
  .buf_out  (debug_hostcpu_atb_fwd_data[175])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf176 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[176]),
  .buf_out  (debug_hostcpu_atb_fwd_data[176])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf177 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[177]),
  .buf_out  (debug_hostcpu_atb_fwd_data[177])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf178 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[178]),
  .buf_out  (debug_hostcpu_atb_fwd_data[178])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf179 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[179]),
  .buf_out  (debug_hostcpu_atb_fwd_data[179])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf180 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[180]),
  .buf_out  (debug_hostcpu_atb_fwd_data[180])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf181 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[181]),
  .buf_out  (debug_hostcpu_atb_fwd_data[181])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf182 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[182]),
  .buf_out  (debug_hostcpu_atb_fwd_data[182])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf183 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[183]),
  .buf_out  (debug_hostcpu_atb_fwd_data[183])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf184 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[184]),
  .buf_out  (debug_hostcpu_atb_fwd_data[184])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf185 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[185]),
  .buf_out  (debug_hostcpu_atb_fwd_data[185])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf186 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[186]),
  .buf_out  (debug_hostcpu_atb_fwd_data[186])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf187 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[187]),
  .buf_out  (debug_hostcpu_atb_fwd_data[187])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf188 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[188]),
  .buf_out  (debug_hostcpu_atb_fwd_data[188])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf189 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[189]),
  .buf_out  (debug_hostcpu_atb_fwd_data[189])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf190 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[190]),
  .buf_out  (debug_hostcpu_atb_fwd_data[190])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf191 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[191]),
  .buf_out  (debug_hostcpu_atb_fwd_data[191])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf192 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[192]),
  .buf_out  (debug_hostcpu_atb_fwd_data[192])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf193 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[193]),
  .buf_out  (debug_hostcpu_atb_fwd_data[193])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf194 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[194]),
  .buf_out  (debug_hostcpu_atb_fwd_data[194])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf195 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[195]),
  .buf_out  (debug_hostcpu_atb_fwd_data[195])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf196 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[196]),
  .buf_out  (debug_hostcpu_atb_fwd_data[196])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf197 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[197]),
  .buf_out  (debug_hostcpu_atb_fwd_data[197])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf198 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[198]),
  .buf_out  (debug_hostcpu_atb_fwd_data[198])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf199 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[199]),
  .buf_out  (debug_hostcpu_atb_fwd_data[199])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf200 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[200]),
  .buf_out  (debug_hostcpu_atb_fwd_data[200])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf201 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[201]),
  .buf_out  (debug_hostcpu_atb_fwd_data[201])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf202 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[202]),
  .buf_out  (debug_hostcpu_atb_fwd_data[202])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf203 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[203]),
  .buf_out  (debug_hostcpu_atb_fwd_data[203])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf204 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[204]),
  .buf_out  (debug_hostcpu_atb_fwd_data[204])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf205 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[205]),
  .buf_out  (debug_hostcpu_atb_fwd_data[205])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf206 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[206]),
  .buf_out  (debug_hostcpu_atb_fwd_data[206])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf207 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[207]),
  .buf_out  (debug_hostcpu_atb_fwd_data[207])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf208 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[208]),
  .buf_out  (debug_hostcpu_atb_fwd_data[208])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf209 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[209]),
  .buf_out  (debug_hostcpu_atb_fwd_data[209])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf210 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[210]),
  .buf_out  (debug_hostcpu_atb_fwd_data[210])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf211 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[211]),
  .buf_out  (debug_hostcpu_atb_fwd_data[211])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf212 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[212]),
  .buf_out  (debug_hostcpu_atb_fwd_data[212])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf213 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[213]),
  .buf_out  (debug_hostcpu_atb_fwd_data[213])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf214 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[214]),
  .buf_out  (debug_hostcpu_atb_fwd_data[214])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf215 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[215]),
  .buf_out  (debug_hostcpu_atb_fwd_data[215])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf216 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[216]),
  .buf_out  (debug_hostcpu_atb_fwd_data[216])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf217 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[217]),
  .buf_out  (debug_hostcpu_atb_fwd_data[217])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf218 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[218]),
  .buf_out  (debug_hostcpu_atb_fwd_data[218])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf219 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[219]),
  .buf_out  (debug_hostcpu_atb_fwd_data[219])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf220 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[220]),
  .buf_out  (debug_hostcpu_atb_fwd_data[220])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf221 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[221]),
  .buf_out  (debug_hostcpu_atb_fwd_data[221])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf222 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[222]),
  .buf_out  (debug_hostcpu_atb_fwd_data[222])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf223 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[223]),
  .buf_out  (debug_hostcpu_atb_fwd_data[223])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf224 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[224]),
  .buf_out  (debug_hostcpu_atb_fwd_data[224])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf225 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[225]),
  .buf_out  (debug_hostcpu_atb_fwd_data[225])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf226 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[226]),
  .buf_out  (debug_hostcpu_atb_fwd_data[226])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf227 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[227]),
  .buf_out  (debug_hostcpu_atb_fwd_data[227])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf228 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[228]),
  .buf_out  (debug_hostcpu_atb_fwd_data[228])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf229 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[229]),
  .buf_out  (debug_hostcpu_atb_fwd_data[229])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf230 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[230]),
  .buf_out  (debug_hostcpu_atb_fwd_data[230])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf231 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[231]),
  .buf_out  (debug_hostcpu_atb_fwd_data[231])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf232 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[232]),
  .buf_out  (debug_hostcpu_atb_fwd_data[232])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf233 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[233]),
  .buf_out  (debug_hostcpu_atb_fwd_data[233])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf234 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[234]),
  .buf_out  (debug_hostcpu_atb_fwd_data[234])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf235 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[235]),
  .buf_out  (debug_hostcpu_atb_fwd_data[235])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf236 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[236]),
  .buf_out  (debug_hostcpu_atb_fwd_data[236])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf237 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[237]),
  .buf_out  (debug_hostcpu_atb_fwd_data[237])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf238 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[238]),
  .buf_out  (debug_hostcpu_atb_fwd_data[238])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf239 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[239]),
  .buf_out  (debug_hostcpu_atb_fwd_data[239])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf240 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[240]),
  .buf_out  (debug_hostcpu_atb_fwd_data[240])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf241 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[241]),
  .buf_out  (debug_hostcpu_atb_fwd_data[241])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf242 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[242]),
  .buf_out  (debug_hostcpu_atb_fwd_data[242])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf243 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[243]),
  .buf_out  (debug_hostcpu_atb_fwd_data[243])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf244 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[244]),
  .buf_out  (debug_hostcpu_atb_fwd_data[244])
);
arm_element_std_buffer u_debug_hostcpu_atb_fwd_data_buf245 (
  .buf_in   (debug_hostcpu_atb_fwd_data_buf[245]),
  .buf_out  (debug_hostcpu_atb_fwd_data[245])
);

arm_element_std_buffer u_hostcpu_dbgtrace_egress_comb_qacceptn_buf0 (
  .buf_in   (hostcpu_dbgtrace_egress_comb_qacceptn_buf[0]),
  .buf_out  (hostcpu_dbgtrace_egress_comb_qacceptn[0])
);

arm_element_std_buffer u_hostcpu_dbgtrace_egress_comb_qdeny_buf0 (
  .buf_in   (hostcpu_dbgtrace_egress_comb_qdeny_buf[0]),
  .buf_out  (hostcpu_dbgtrace_egress_comb_qdeny[0])
);

arm_element_std_buffer u_hostcpu_dbgtrace_egress_comb_qactive_buf0 (
  .buf_in   (hostcpu_dbgtrace_egress_comb_qactive_buf[0]),
  .buf_out  (hostcpu_dbgtrace_egress_comb_qactive[0])
);

arm_element_std_buffer u_hostcpu_dbgtrace_egress_comb_qacceptn_buf1 (
  .buf_in   (hostcpu_dbgtrace_egress_comb_qacceptn_buf[1]),
  .buf_out  (hostcpu_dbgtrace_egress_comb_qacceptn[1])
);

arm_element_std_buffer u_hostcpu_dbgtrace_egress_comb_qdeny_buf1 (
  .buf_in   (hostcpu_dbgtrace_egress_comb_qdeny_buf[1]),
  .buf_out  (hostcpu_dbgtrace_egress_comb_qdeny[1])
);

arm_element_std_buffer u_hostcpu_dbgtrace_egress_comb_qactive_buf1 (
  .buf_in   (hostcpu_dbgtrace_egress_comb_qactive_buf[1]),
  .buf_out  (hostcpu_dbgtrace_egress_comb_qactive[1])
);

arm_element_std_buffer u_debug_hostcpu_async_ack_buf (
  .buf_in   (debug_hostcpu_async_ack_buf),
  .buf_out  (debug_hostcpu_async_ack)
);


arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf0 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[0]),
  .buf_out  (debug_hostcpu_async_resp_payload[0])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf1 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[1]),
  .buf_out  (debug_hostcpu_async_resp_payload[1])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf2 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[2]),
  .buf_out  (debug_hostcpu_async_resp_payload[2])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf3 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[3]),
  .buf_out  (debug_hostcpu_async_resp_payload[3])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf4 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[4]),
  .buf_out  (debug_hostcpu_async_resp_payload[4])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf5 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[5]),
  .buf_out  (debug_hostcpu_async_resp_payload[5])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf6 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[6]),
  .buf_out  (debug_hostcpu_async_resp_payload[6])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf7 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[7]),
  .buf_out  (debug_hostcpu_async_resp_payload[7])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf8 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[8]),
  .buf_out  (debug_hostcpu_async_resp_payload[8])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf9 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[9]),
  .buf_out  (debug_hostcpu_async_resp_payload[9])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf10 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[10]),
  .buf_out  (debug_hostcpu_async_resp_payload[10])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf11 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[11]),
  .buf_out  (debug_hostcpu_async_resp_payload[11])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf12 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[12]),
  .buf_out  (debug_hostcpu_async_resp_payload[12])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf13 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[13]),
  .buf_out  (debug_hostcpu_async_resp_payload[13])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf14 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[14]),
  .buf_out  (debug_hostcpu_async_resp_payload[14])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf15 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[15]),
  .buf_out  (debug_hostcpu_async_resp_payload[15])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf16 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[16]),
  .buf_out  (debug_hostcpu_async_resp_payload[16])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf17 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[17]),
  .buf_out  (debug_hostcpu_async_resp_payload[17])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf18 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[18]),
  .buf_out  (debug_hostcpu_async_resp_payload[18])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf19 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[19]),
  .buf_out  (debug_hostcpu_async_resp_payload[19])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf20 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[20]),
  .buf_out  (debug_hostcpu_async_resp_payload[20])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf21 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[21]),
  .buf_out  (debug_hostcpu_async_resp_payload[21])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf22 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[22]),
  .buf_out  (debug_hostcpu_async_resp_payload[22])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf23 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[23]),
  .buf_out  (debug_hostcpu_async_resp_payload[23])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf24 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[24]),
  .buf_out  (debug_hostcpu_async_resp_payload[24])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf25 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[25]),
  .buf_out  (debug_hostcpu_async_resp_payload[25])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf26 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[26]),
  .buf_out  (debug_hostcpu_async_resp_payload[26])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf27 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[27]),
  .buf_out  (debug_hostcpu_async_resp_payload[27])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf28 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[28]),
  .buf_out  (debug_hostcpu_async_resp_payload[28])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf29 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[29]),
  .buf_out  (debug_hostcpu_async_resp_payload[29])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf30 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[30]),
  .buf_out  (debug_hostcpu_async_resp_payload[30])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf31 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[31]),
  .buf_out  (debug_hostcpu_async_resp_payload[31])
);
arm_element_std_buffer u_debug_hostcpu_async_resp_payload_buf32 (
  .buf_in   (debug_hostcpu_async_resp_payload_buf[32]),
  .buf_out  (debug_hostcpu_async_resp_payload[32])
);


arm_element_std_buffer u_debug_hostcpu_flush_done_buf (
  .buf_in   (debug_hostcpu_flush_done_buf),
  .buf_out  (debug_hostcpu_flush_done)
);

arm_element_std_buffer u_hostcpu_gicintdbgtop_pulse_ack_buf0 (
  .buf_in   (hostcpu_gicintdbgtop_pulse_ack_buf[0]),
  .buf_out  (hostcpu_gicintdbgtop_pulse_ack[0])
);

arm_element_std_buffer u_hostcpu_gicintdbgtop_pulse_ack_buf1 (
  .buf_in   (hostcpu_gicintdbgtop_pulse_ack_buf[1]),
  .buf_out  (hostcpu_gicintdbgtop_pulse_ack[1])
);

arm_element_std_buffer u_hostcpu_gicintdbgtop_pulse_ack_buf2 (
  .buf_in   (hostcpu_gicintdbgtop_pulse_ack_buf[2]),
  .buf_out  (hostcpu_gicintdbgtop_pulse_ack[2])
);

arm_element_cdc_comb_mux2 u_clkgen_reset_nmbistreset_mux (
 .din1_async(systop_warmresetn),
 .din2_async(nmbistreset),
 .sel       (dftdivsel),
 .dout_async(resetn_clk_gen)
);

e_clk_f1_top_systop u_clk_gen_systop (
    .RESETN                      (resetn_clk_gen),
    .REFCLK                      (refclk ),    
    .SYSPLL                      (sys_pll),    
    .ACLK                        (aclk),   

    .ACLK_ON_SYSPLL_DIVRATIO     (aclk_on_syspll_divratio),
    .ACLK_ON_SYSPLL_DIVRATIO_CUR (aclk_on_syspll_divratio_cur),

    .ACLK_CLKSEL                 (aclk_clksel),
    .ACLK_CLKSEL_CUR             (aclk_clksel_cur),

    .DFTACLKSEL                  (dftaclksel),
    .DFTACLKSELEN                (dftaclkselen),
    .DFTACLKDIVBYPASS_ON_SYSPLL  (dftaclkdivbypass),
    .CTRLCLK                        (ctrlclk),   

    .CTRLCLK_ON_SYSPLL_DIVRATIO     (ctrlclk_on_syspll_divratio),
    .CTRLCLK_ON_SYSPLL_DIVRATIO_CUR (ctrlclk_on_syspll_divratio_cur),

    .CTRLCLK_CLKSEL                 (ctrlclk_clksel),
    .CTRLCLK_CLKSEL_CUR             (ctrlclk_clksel_cur),

    .DFTCTRLCLKSEL                  (dftctrlclksel),
    .DFTCTRLCLKSELEN                (dftctrlclkselen),
    .DFTCTRLCLKDIVBYPASS_ON_SYSPLL  (dftctrlclkdivbypass),

    .DFTCGEN                        (dftcgen),
    .DFTRSTDISABLE                  (dftrstdisable[0])
    
);


  
wire aclk_gated;
wire aclk_enable;

pck600_clk_ctrl  #(
    .NUM_Q_CHL            (22 + NUM_ACLK_QCH + 6 + 1),
    .NUM_QACTIVE_ONLY     (1),
    .HC_Q_CH_SYNC         (0),
    .PWR_Q_CH_SYNC        (0),
    .CLK_Q_CH_SYNC        (1),
    .ACTIVE_DENY_EN       (1)
) u_aclk_ctrl (
  .clk            (aclk),
  .reset_n        (aresetn),
                       
  .dftcgen        (dftcgen),
                       
  .hc_qreqn_i     (1'b1),  
  .hc_qacceptn_o  (),
  .hc_qdeny_o     (),
  .hc_qactive_o   (),

  .pwr_qreqn_i    (1'b1),
  .pwr_qacceptn_o (),
  .pwr_qdeny_o    (),
  .pwr_qactive_o  (),


  .clk_qreqn_o    ({qch_exp_aclk_devqreqn   , aclk_qreqn   }),    
  .clk_qacceptn_i ({qch_exp_aclk_devqacceptn, aclk_qacceptn}),    
  .clk_qdeny_i    ({qch_exp_aclk_devqdeny   , aclk_qdeny   }),    
  .clk_qactive_i  ({cactive_cd_maingpv, qch_exp_aclk_devqactive , aclk_qactive }), 

  .clk_force_i    (clkforce_st_aclk_force_st),
                         
  .entry_delay_i  (aclk_ctrl_entrydelay),
            
  .clken_o        (aclk_enable)
);

arm_element_clock_gate u_clock_gate_aclk (
  .clk_in  (aclk),
  .enable  (aclk_enable),
  .clk_out (aclk_gated),
  .dftcgen (dft_pcg_en)
);
assign aclkout = aclk_gated;

wire ctrlclk_gated;
wire ctrlclk_enable;

pck600_clk_ctrl  #(
    .NUM_Q_CHL            (7),
    .NUM_QACTIVE_ONLY     (1),
    .HC_Q_CH_SYNC         (0),
    .PWR_Q_CH_SYNC        (0),
    .CLK_Q_CH_SYNC        (1),
    .ACTIVE_DENY_EN       (1)
) u_ctrlclk_ctrl (
  .clk            (ctrlclk),
  .reset_n        (ctrlresetn),
                       
  .dftcgen        (dftcgen),
                       
  .hc_qreqn_i     (1'b1),  
  .hc_qacceptn_o  (),  
  .hc_qdeny_o     (),  
  .hc_qactive_o   (),  
                       
  .pwr_qreqn_i    (1'b1),
  .pwr_qacceptn_o (),
  .pwr_qdeny_o    (),
  .pwr_qactive_o  (),


  .clk_qreqn_o    ({ctrlclk_devqreqn   ,ctrlclk_qreqn}),
  .clk_qacceptn_i ({ctrlclk_devqacceptn,ctrlclk_qacceptn}),
  .clk_qdeny_i    ({ctrlclk_devqdeny   ,ctrlclk_qdeny}),
  .clk_qactive_i  ({ctrlclk_devqactive ,ctrlclk_qactive, pc_cpu_ctrlclk_qactive}),
  
 

  
  
  .clk_force_i    (clkforce_st_ctrlclk_force_st),
                         
  .entry_delay_i  (ctrlclk_ctrl_entrydelay),
            
  .clken_o        (ctrlclk_enable)
);

arm_element_clock_gate u_clock_gate_ctrlclk (
  .clk_in  (ctrlclk),
  .enable  (ctrlclk_enable),
  .clk_out (ctrlclk_gated),
  .dftcgen (dftcgen)
);


wire clustop_devclken;
wire cpu_pll_clustop;
wire sys_pll_clustop;
wire refclk_clustop;
wire host_cntclkout_clustop;

assign dft_pcg_en = (dftcgen | mbistreq);

pcg 
#(
    .WIDTH(4)
)
 u_clustop_pcgs
(
  .clk_in  ({cpu_pll,
             sys_pll,
             refclk,
             host_cntclkout}),
  .resetn  ({4{systop_warmresetn}}),
  .enable  ({4{clustop_devclken}}),
  .clk_out ({cpu_pll_clustop,
             sys_pll_clustop,
             refclk_clustop,
             host_cntclkout_clustop}),
  .dftcgen (dft_pcg_en),
  .dftrstdisable(dftrstdisable[0])
);


assign awuser_hostcpu_axis[9:2] = 8'h01;
assign aruser_hostcpu_axis[9:2] = 8'h01;

wire acg_wakeup;

acg_axi #(
  .ADDR_WIDTH   (32),
  .DATA_WIDTH   (CVM_DATA_WIDTH),
  .AWID_WIDTH   (GLOBAL_ID_WIDTH),
  .ARID_WIDTH   (GLOBAL_ID_WIDTH),
  .AWUSER_WIDTH (10),
  .WUSER_WIDTH  (0),
  .BUSER_WIDTH  (0),
  .ARUSER_WIDTH (10),
  .RUSER_WIDTH  (0),
  .AW_CNTR_SIZE (8),
  .W_CNTR_SIZE  (8),
  .AR_CNTR_SIZE (8)
)
  u_acg_axi_cvm (
  .ACLK          (aclk_gated),
  .ARESETn       (aresetn),
  .PWRQREQn      (qreqn_systop_acg),
  .PWRQACCEPTn   (qacceptn_systop_acg),
  .PWRQDENY      (qdeny_systop_acg),
  .PWRQACTIVE    (qactive_systop_acg),

  .CLKQREQn      (qch_exp_aclk_devqreqn[0]   ),
  .CLKQACCEPTn   (qch_exp_aclk_devqacceptn[0]),
  .CLKQDENY      (qch_exp_aclk_devqdeny[0]   ),
  .CLKQACTIVE    (qch_exp_aclk_devqactive[0] ),
 
  
  .INACT         (),
  
  .AWVALIDS      (acg_awvalid_cvm_axim),
  .AWREADYS      (acg_awready_cvm_axim),
  .AWIDS         (acg_awid_cvm_axim),
  .AWADDRS       (acg_awaddr_cvm_axim),
  .AWREGIONS     (4'h0),
  .AWLENS        (acg_awlen_cvm_axim),
  .AWSIZES       (acg_awsize_cvm_axim),
  .AWBURSTS      (acg_awburst_cvm_axim),
  .AWLOCKS       (acg_awlock_cvm_axim),
  .AWCACHES      (acg_awcache_cvm_axim),
  .AWPROTS       (acg_awprot_cvm_axim),
  .AWQOSS        (acg_awqos_cvm_axim),
  .AWUSERS       (acg_awuser_cvm_axim),
  .WVALIDS       (acg_wvalid_cvm_axim),
  .WREADYS       (acg_wready_cvm_axim),
  .WDATAS        (acg_wdata_cvm_axim),
  .WSTRBS        (acg_wstrb_cvm_axim),
  .WLASTS        (acg_wlast_cvm_axim),
  .WUSERS        (1'b0),
  .BVALIDS       (acg_bvalid_cvm_axim),
  .BREADYS       (acg_bready_cvm_axim),
  .BIDS          (acg_bid_cvm_axim),
  .BRESPS        (acg_bresp_cvm_axim),
  .BUSERS        (),
  .ARVALIDS      (acg_arvalid_cvm_axim),
  .ARREADYS      (acg_arready_cvm_axim),
  .ARIDS         (acg_arid_cvm_axim),
  .ARADDRS       (acg_araddr_cvm_axim),
  .ARREGIONS     (4'h0),
  .ARLENS        (acg_arlen_cvm_axim),
  .ARSIZES       (acg_arsize_cvm_axim),
  .ARBURSTS      (acg_arburst_cvm_axim),
  .ARLOCKS       (acg_arlock_cvm_axim),
  .ARCACHES      (acg_arcache_cvm_axim),
  .ARPROTS       (acg_arprot_cvm_axim),
  .ARQOSS        (acg_arqos_cvm_axim),
  .ARUSERS       (acg_aruser_cvm_axim),
  .RVALIDS       (acg_rvalid_cvm_axim),
  .RREADYS       (acg_rready_cvm_axim),
  .RIDS          (acg_rid_cvm_axim),
  .RDATAS        (acg_rdata_cvm_axim),
  .RRESPS        (acg_rresp_cvm_axim),
  .RLASTS        (acg_rlast_cvm_axim),
  .RUSERS        (),
  .AWAKEUPS      (acg_wakeup),

  .AWVALIDM      (awvalid_cvm_axim),
  .AWREADYM      (awready_cvm_axim),
  .AWIDM         (awid_cvm_axim),
  .AWADDRM       (awaddr_cvm_axim),
  .AWREGIONM     (),
  .AWLENM        (awlen_cvm_axim),
  .AWSIZEM       (awsize_cvm_axim),
  .AWBURSTM      (awburst_cvm_axim),
  .AWLOCKM       (awlock_cvm_axim),
  .AWCACHEM      (awcache_cvm_axim),
  .AWPROTM       (awprot_cvm_axim),
  .AWQOSM        (awqos_cvm_axim),
  .AWUSERM       (awuser_cvm_axim),
  .WVALIDM       (wvalid_cvm_axim),
  .WREADYM       (wready_cvm_axim),
  .WDATAM        (wdata_cvm_axim),
  .WSTRBM        (wstrb_cvm_axim),
  .WLASTM        (wlast_cvm_axim),
  .WUSERM        (),
  .BVALIDM       (bvalid_cvm_axim),
  .BREADYM       (bready_cvm_axim),
  .BIDM          (bid_cvm_axim),
  .BRESPM        (bresp_cvm_axim),
  .BUSERM        (1'b0),
  .ARVALIDM      (arvalid_cvm_axim),
  .ARREADYM      (arready_cvm_axim),
  .ARIDM         (arid_cvm_axim),
  .ARADDRM       (araddr_cvm_axim),
  .ARREGIONM     (),
  .ARLENM        (arlen_cvm_axim),
  .ARSIZEM       (arsize_cvm_axim),
  .ARBURSTM      (arburst_cvm_axim),
  .ARLOCKM       (arlock_cvm_axim),
  .ARCACHEM      (arcache_cvm_axim),
  .ARPROTM       (arprot_cvm_axim),
  .ARQOSM        (arqos_cvm_axim),
  .ARUSERM       (aruser_cvm_axim),
  .RVALIDM       (rvalid_cvm_axim),
  .RREADYM       (rready_cvm_axim),
  .RIDM          (rid_cvm_axim),
  .RDATAM        (rdata_cvm_axim),
  .RRESPM        (rresp_cvm_axim),
  .RLASTM        (rlast_cvm_axim),
  .RUSERM        (1'b0),
  .AWAKEUPM      (awakeup_cvm_axim)
);

wire [6:0] unused_awuser_gic;  
wire [6:0] unused_aruser_gic;  
wire [12:0] unused_awaddr_gic;

base_f0_systop  #(
  
  .XNVM_DATA_WIDTH  (XNVM_DATA_WIDTH),
  .CVM_DATA_WIDTH   (CVM_DATA_WIDTH ),
  .OCVM_DATA_WIDTH  (OCVM_DATA_WIDTH),
  
  .EXPSLV0_DATA_WIDTH       (EXPSLV0_DATA_WIDTH), 
  .EXPSLV0_ID_WIDTH         (EXPSLV0_ID_WIDTH), 
  .EXPSLV1_DATA_WIDTH       (EXPSLV1_DATA_WIDTH), 
  .EXPSLV1_ID_WIDTH         (EXPSLV1_ID_WIDTH), 

 .EXPMST0_DATA_WIDTH        (EXPMST0_DATA_WIDTH), 
 .EXPMST1_DATA_WIDTH        (EXPMST1_DATA_WIDTH), 

  .EXT_SYS0_MEM_DATA_WIDTH   (EXT_SYS0_MEM_DATA_WIDTH), 
  .EXT_SYS0_MEM_AWID_WIDTH   (EXT_SYS0_MEM_AWID_WIDTH), 
  .EXT_SYS0_MEM_ARID_WIDTH   (EXT_SYS0_MEM_ARID_WIDTH), 
  .EXT_SYS1_MEM_DATA_WIDTH   (EXT_SYS1_MEM_DATA_WIDTH), 
  .EXT_SYS1_MEM_AWID_WIDTH   (EXT_SYS1_MEM_AWID_WIDTH), 
  .EXT_SYS1_MEM_ARID_WIDTH   (EXT_SYS1_MEM_ARID_WIDTH), 
  .GLOBAL_ID_WIDTH (GLOBAL_ID_WIDTH),
  .SYSTOP_BASE_INTERNAL_PWRQ  (13 )
) u_base_systop (
  .fctrl_bypass               (fctrl_bypass),
  .cactive_cd_maingpv         (cactive_cd_maingpv),
  
  .tvalid_dti_dn_m            (tvalid_dti_dn_m),
  .tready_dti_dn_m            (tready_dti_dn_m),
  .tdata_dti_dn_m             (tdata_dti_dn_m ),
  .tkeep_dti_dn_m             (tkeep_dti_dn_m ),
  .tid_dti_dn_m               (tid_dti_dn_m   ),
  .tlast_dti_dn_m             (tlast_dti_dn_m ),
  .twakeup_dti_dn_m           (twakeup_dti_dn_m),

  .tvalid_dti_up_m            (tvalid_dti_up_m),
  .tready_dti_up_m            (tready_dti_up_m),
  .tdata_dti_up_m             (tdata_dti_up_m ),
  .tkeep_dti_up_m             (tkeep_dti_up_m ),
  .tdest_dti_up_m             (tdest_dti_up_m ),
  .tlast_dti_up_m             (tlast_dti_up_m ),
  .twakeup_dti_up_m           (twakeup_dti_up_m),

  .paddr_uart_apb             (paddr_uart_apb),
  .pwdata_uart_apb            (pwdata_uart_apb),
  .pwrite_uart_apb            (pwrite_uart_apb),
  .pprot_uart_apb             (pprot_uart_apb),
  .pstrb_uart_apb             (pstrb_uart_apb),
  .penable_uart_apb           (penable_uart_apb),
  .pselx_uart_apb             (pselx_uart_apb),
  .prdata_uart_apb            (prdata_uart_apb),
  .pslverr_uart_apb           (pslverr_uart_apb),
  .pready_uart_apb            (pready_uart_apb),
  
  .paddr_sysctrl_apb          (paddr_sysctrl_apb),
  .pwdata_sysctrl_apb         (pwdata_sysctrl_apb),
  .pwrite_sysctrl_apb         (pwrite_sysctrl_apb),
  .pprot_sysctrl_apb          (pprot_sysctrl_apb),
  .pstrb_sysctrl_apb          (pstrb_sysctrl_apb),
  .penable_sysctrl_apb        (penable_sysctrl_apb),
  .pselx_sysctrl_apb          (pselx_sysctrl_apb),
  .prdata_sysctrl_apb         (prdata_sysctrl_apb),
  .pslverr_sysctrl_apb        (pslverr_sysctrl_apb),
  .pready_sysctrl_apb         (pready_sysctrl_apb),
  

  .awakeup_xnvm_axim          (awakeup_xnvm_axim),
  .awid_xnvm_axim             (awid_xnvm_axim   ),
  .awaddr_xnvm_axim           (awaddr_xnvm_axim ),
  .awlen_xnvm_axim            (awlen_xnvm_axim  ),
  .awsize_xnvm_axim           (awsize_xnvm_axim ),
  .awburst_xnvm_axim          (awburst_xnvm_axim),
  .awlock_xnvm_axim           (awlock_xnvm_axim ),
  .awcache_xnvm_axim          (awcache_xnvm_axim),
  .awprot_xnvm_axim           (awprot_xnvm_axim ),
  .awvalid_xnvm_axim          (awvalid_xnvm_axim),
  .awready_xnvm_axim          (awready_xnvm_axim),
  .wdata_xnvm_axim            (wdata_xnvm_axim  ),
  .wstrb_xnvm_axim            (wstrb_xnvm_axim  ),
  .wlast_xnvm_axim            (wlast_xnvm_axim  ),
  .wvalid_xnvm_axim           (wvalid_xnvm_axim ),
  .wready_xnvm_axim           (wready_xnvm_axim ),
  .bid_xnvm_axim              (bid_xnvm_axim    ),
  .bresp_xnvm_axim            (bresp_xnvm_axim  ),
  .bvalid_xnvm_axim           (bvalid_xnvm_axim ),
  .bready_xnvm_axim           (bready_xnvm_axim ),
  .arid_xnvm_axim             (arid_xnvm_axim   ),
  .araddr_xnvm_axim           (araddr_xnvm_axim ),
  .arlen_xnvm_axim            (arlen_xnvm_axim  ),
  .arsize_xnvm_axim           (arsize_xnvm_axim ),
  .arburst_xnvm_axim          (arburst_xnvm_axim),
  .arlock_xnvm_axim           (arlock_xnvm_axim ),
  .arcache_xnvm_axim          (arcache_xnvm_axim),
  .arprot_xnvm_axim           (arprot_xnvm_axim ),
  .arvalid_xnvm_axim          (arvalid_xnvm_axim),
  .arready_xnvm_axim          (arready_xnvm_axim),
  .rid_xnvm_axim              (rid_xnvm_axim    ),
  .rdata_xnvm_axim            (rdata_xnvm_axim  ),
  .rresp_xnvm_axim            (rresp_xnvm_axim  ),
  .rlast_xnvm_axim            (rlast_xnvm_axim  ),
  .rvalid_xnvm_axim           (rvalid_xnvm_axim ),
  .rready_xnvm_axim           (rready_xnvm_axim ),
  .awuser_xnvm_axim           (awuser_xnvm_axim ),
  .aruser_xnvm_axim           (aruser_xnvm_axim ),
  .awqos_xnvm_axim            (awqos_xnvm_axim  ),
  .arqos_xnvm_axim            (arqos_xnvm_axim  ),
  

  .awakeup_cvm_axim           (acg_wakeup),
  .awid_cvm_axim              (acg_awid_cvm_axim   ),
  .awaddr_cvm_axim            (acg_awaddr_cvm_axim ),
  .awlen_cvm_axim             (acg_awlen_cvm_axim  ),
  .awsize_cvm_axim            (acg_awsize_cvm_axim ),
  .awburst_cvm_axim           (acg_awburst_cvm_axim),
  .awlock_cvm_axim            (acg_awlock_cvm_axim ),
  .awcache_cvm_axim           (acg_awcache_cvm_axim),
  .awprot_cvm_axim            (acg_awprot_cvm_axim ),
  .awvalid_cvm_axim           (acg_awvalid_cvm_axim),
  .awready_cvm_axim           (acg_awready_cvm_axim),
  .wdata_cvm_axim             (acg_wdata_cvm_axim  ),
  .wstrb_cvm_axim             (acg_wstrb_cvm_axim  ),
  .wlast_cvm_axim             (acg_wlast_cvm_axim  ),
  .wvalid_cvm_axim            (acg_wvalid_cvm_axim ),
  .wready_cvm_axim            (acg_wready_cvm_axim ),
  .bid_cvm_axim               (acg_bid_cvm_axim    ),
  .bresp_cvm_axim             (acg_bresp_cvm_axim  ),
  .bvalid_cvm_axim            (acg_bvalid_cvm_axim ),
  .bready_cvm_axim            (acg_bready_cvm_axim ),
  .arid_cvm_axim              (acg_arid_cvm_axim   ),
  .araddr_cvm_axim            (acg_araddr_cvm_axim ),
  .arlen_cvm_axim             (acg_arlen_cvm_axim  ),
  .arsize_cvm_axim            (acg_arsize_cvm_axim ),
  .arburst_cvm_axim           (acg_arburst_cvm_axim),
  .arlock_cvm_axim            (acg_arlock_cvm_axim ),
  .arcache_cvm_axim           (acg_arcache_cvm_axim),
  .arprot_cvm_axim            (acg_arprot_cvm_axim ),
  .arvalid_cvm_axim           (acg_arvalid_cvm_axim),
  .arready_cvm_axim           (acg_arready_cvm_axim),
  .rid_cvm_axim               (acg_rid_cvm_axim    ),
  .rdata_cvm_axim             (acg_rdata_cvm_axim  ),
  .rresp_cvm_axim             (acg_rresp_cvm_axim  ),
  .rlast_cvm_axim             (acg_rlast_cvm_axim  ),
  .rvalid_cvm_axim            (acg_rvalid_cvm_axim ),
  .rready_cvm_axim            (acg_rready_cvm_axim ),
  .awuser_cvm_axim            (acg_awuser_cvm_axim ),
  .aruser_cvm_axim            (acg_aruser_cvm_axim ),
  .awqos_cvm_axim             (acg_awqos_cvm_axim  ),
  .arqos_cvm_axim             (acg_arqos_cvm_axim  ),

 

  .awakeup_expmstr0_axim      (awakeup_expmstr0_axim),
  .awid_expmstr0_axim         (awid_expmstr0_axim   ),
  .awaddr_expmstr0_axim       (awaddr_expmstr0_axim ),
  .awlen_expmstr0_axim        (awlen_expmstr0_axim  ),
  .awsize_expmstr0_axim       (awsize_expmstr0_axim ),
  .awburst_expmstr0_axim      (awburst_expmstr0_axim),
  .awlock_expmstr0_axim       (awlock_expmstr0_axim ),
  .awcache_expmstr0_axim      (awcache_expmstr0_axim),
  .awprot_expmstr0_axim       (awprot_expmstr0_axim ),
  .awvalid_expmstr0_axim      (awvalid_expmstr0_axim),
  .awready_expmstr0_axim      (awready_expmstr0_axim),
  .wdata_expmstr0_axim        (wdata_expmstr0_axim  ),
  .wstrb_expmstr0_axim        (wstrb_expmstr0_axim  ),
  .wlast_expmstr0_axim        (wlast_expmstr0_axim  ),
  .wvalid_expmstr0_axim       (wvalid_expmstr0_axim ),
  .wready_expmstr0_axim       (wready_expmstr0_axim ),
  .bid_expmstr0_axim          (bid_expmstr0_axim    ),
  .bresp_expmstr0_axim        (bresp_expmstr0_axim  ),
  .bvalid_expmstr0_axim       (bvalid_expmstr0_axim ),
  .bready_expmstr0_axim       (bready_expmstr0_axim ),
  .arid_expmstr0_axim         (arid_expmstr0_axim   ),
  .araddr_expmstr0_axim       (araddr_expmstr0_axim ),
  .arlen_expmstr0_axim        (arlen_expmstr0_axim  ),
  .arsize_expmstr0_axim       (arsize_expmstr0_axim ),
  .arburst_expmstr0_axim      (arburst_expmstr0_axim),
  .arlock_expmstr0_axim       (arlock_expmstr0_axim ),
  .arcache_expmstr0_axim      (arcache_expmstr0_axim),
  .arprot_expmstr0_axim       (arprot_expmstr0_axim ),
  .arvalid_expmstr0_axim      (arvalid_expmstr0_axim),
  .arready_expmstr0_axim      (arready_expmstr0_axim),
  .rid_expmstr0_axim          (rid_expmstr0_axim    ),
  .rdata_expmstr0_axim        (rdata_expmstr0_axim  ),
  .rresp_expmstr0_axim        (rresp_expmstr0_axim  ),
  .rlast_expmstr0_axim        (rlast_expmstr0_axim  ),
  .rvalid_expmstr0_axim       (rvalid_expmstr0_axim ),
  .rready_expmstr0_axim       (rready_expmstr0_axim ),
  .awuser_expmstr0_axim       (awuser_expmstr0_axim ),
  .aruser_expmstr0_axim       (aruser_expmstr0_axim ),
  .awqos_expmstr0_axim        (awqos_expmstr0_axim  ),
  .arqos_expmstr0_axim        (arqos_expmstr0_axim  ),
 

  .awakeup_expmstr1_axim      (awakeup_expmstr1_axim),
  .awid_expmstr1_axim         (awid_expmstr1_axim   ),
  .awaddr_expmstr1_axim       (awaddr_expmstr1_axim ),
  .awlen_expmstr1_axim        (awlen_expmstr1_axim  ),
  .awsize_expmstr1_axim       (awsize_expmstr1_axim ),
  .awburst_expmstr1_axim      (awburst_expmstr1_axim),
  .awlock_expmstr1_axim       (awlock_expmstr1_axim ),
  .awcache_expmstr1_axim      (awcache_expmstr1_axim),
  .awprot_expmstr1_axim       (awprot_expmstr1_axim ),
  .awvalid_expmstr1_axim      (awvalid_expmstr1_axim),
  .awready_expmstr1_axim      (awready_expmstr1_axim),
  .wdata_expmstr1_axim        (wdata_expmstr1_axim  ),
  .wstrb_expmstr1_axim        (wstrb_expmstr1_axim  ),
  .wlast_expmstr1_axim        (wlast_expmstr1_axim  ),
  .wvalid_expmstr1_axim       (wvalid_expmstr1_axim ),
  .wready_expmstr1_axim       (wready_expmstr1_axim ),
  .bid_expmstr1_axim          (bid_expmstr1_axim    ),
  .bresp_expmstr1_axim        (bresp_expmstr1_axim  ),
  .bvalid_expmstr1_axim       (bvalid_expmstr1_axim ),
  .bready_expmstr1_axim       (bready_expmstr1_axim ),
  .arid_expmstr1_axim         (arid_expmstr1_axim   ),
  .araddr_expmstr1_axim       (araddr_expmstr1_axim ),
  .arlen_expmstr1_axim        (arlen_expmstr1_axim  ),
  .arsize_expmstr1_axim       (arsize_expmstr1_axim ),
  .arburst_expmstr1_axim      (arburst_expmstr1_axim),
  .arlock_expmstr1_axim       (arlock_expmstr1_axim ),
  .arcache_expmstr1_axim      (arcache_expmstr1_axim),
  .arprot_expmstr1_axim       (arprot_expmstr1_axim ),
  .arvalid_expmstr1_axim      (arvalid_expmstr1_axim),
  .arready_expmstr1_axim      (arready_expmstr1_axim),
  .rid_expmstr1_axim          (rid_expmstr1_axim    ),
  .rdata_expmstr1_axim        (rdata_expmstr1_axim  ),
  .rresp_expmstr1_axim        (rresp_expmstr1_axim  ),
  .rlast_expmstr1_axim        (rlast_expmstr1_axim  ),
  .rvalid_expmstr1_axim       (rvalid_expmstr1_axim ),
  .rready_expmstr1_axim       (rready_expmstr1_axim ),
  .awuser_expmstr1_axim       (awuser_expmstr1_axim ),
  .aruser_expmstr1_axim       (aruser_expmstr1_axim ),
  .awqos_expmstr1_axim        (awqos_expmstr1_axim  ),
  .arqos_expmstr1_axim        (arqos_expmstr1_axim  ),
  
  
  .awid_firewall_axim         (awid_firewall_axim   ),
  .awaddr_firewall_axim       (awaddr_firewall_axim ),
  .awlen_firewall_axim        (awlen_firewall_axim  ),
  .awsize_firewall_axim       (awsize_firewall_axim ),
  .awburst_firewall_axim      (awburst_firewall_axim),
  .awlock_firewall_axim       (awlock_firewall_axim ),
  .awcache_firewall_axim      (awcache_firewall_axim),
  .awprot_firewall_axim       (awprot_firewall_axim ),
  .awvalid_firewall_axim      (awvalid_firewall_axim),
  .awready_firewall_axim      (awready_firewall_axim),
  .wdata_firewall_axim        (wdata_firewall_axim  ),
  .wstrb_firewall_axim        (wstrb_firewall_axim  ),
  .wlast_firewall_axim        (wlast_firewall_axim  ),
  .wvalid_firewall_axim       (wvalid_firewall_axim ),
  .wready_firewall_axim       (wready_firewall_axim ),
  .bid_firewall_axim          (bid_firewall_axim    ),
  .bresp_firewall_axim        (bresp_firewall_axim  ),
  .bvalid_firewall_axim       (bvalid_firewall_axim ),
  .bready_firewall_axim       (bready_firewall_axim ),
  .arid_firewall_axim         (arid_firewall_axim   ),
  .araddr_firewall_axim       (araddr_firewall_axim ),
  .arlen_firewall_axim        (arlen_firewall_axim  ),
  .arsize_firewall_axim       (arsize_firewall_axim ),
  .arburst_firewall_axim      (arburst_firewall_axim),
  .arlock_firewall_axim       (arlock_firewall_axim ),
  .arcache_firewall_axim      (arcache_firewall_axim),
  .arprot_firewall_axim       (arprot_firewall_axim ),
  .arvalid_firewall_axim      (arvalid_firewall_axim),
  .arready_firewall_axim      (arready_firewall_axim),
  .rid_firewall_axim          (rid_firewall_axim    ),
  .rdata_firewall_axim        (rdata_firewall_axim  ),
  .rresp_firewall_axim        (rresp_firewall_axim  ),
  .rlast_firewall_axim        (rlast_firewall_axim  ),
  .rvalid_firewall_axim       (rvalid_firewall_axim ),
  .rready_firewall_axim       (rready_firewall_axim ),
  .awuser_firewall_axim       (awuser_firewall_axim ),
  .aruser_firewall_axim       (aruser_firewall_axim ),
  .ruser_firewall_axim        (ruser_firewall_axim  ),
  .buser_firewall_axim        (buser_firewall_axim  ),
  
  
  .awakeup_ocvm_axim          (awakeup_ocvm_axim),
  .awid_ocvm_axim             (awid_ocvm_axim   ),
  .awaddr_ocvm_axim           (awaddr_ocvm_axim ),
  .awlen_ocvm_axim            (awlen_ocvm_axim  ),
  .awsize_ocvm_axim           (awsize_ocvm_axim ),
  .awburst_ocvm_axim          (awburst_ocvm_axim),
  .awlock_ocvm_axim           (awlock_ocvm_axim ),
  .awcache_ocvm_axim          (awcache_ocvm_axim),
  .awprot_ocvm_axim           (awprot_ocvm_axim ),
  .awvalid_ocvm_axim          (awvalid_ocvm_axim),
  .awready_ocvm_axim          (awready_ocvm_axim),
  .wdata_ocvm_axim            (wdata_ocvm_axim  ),
  .wstrb_ocvm_axim            (wstrb_ocvm_axim  ),
  .wlast_ocvm_axim            (wlast_ocvm_axim  ),
  .wvalid_ocvm_axim           (wvalid_ocvm_axim ),
  .wready_ocvm_axim           (wready_ocvm_axim ),
  .bid_ocvm_axim              (bid_ocvm_axim    ),
  .bresp_ocvm_axim            (bresp_ocvm_axim  ),
  .bvalid_ocvm_axim           (bvalid_ocvm_axim ),
  .bready_ocvm_axim           (bready_ocvm_axim ),
  .arid_ocvm_axim             (arid_ocvm_axim   ),
  .araddr_ocvm_axim           (araddr_ocvm_axim ),
  .arlen_ocvm_axim            (arlen_ocvm_axim  ),
  .arsize_ocvm_axim           (arsize_ocvm_axim ),
  .arburst_ocvm_axim          (arburst_ocvm_axim),
  .arlock_ocvm_axim           (arlock_ocvm_axim ),
  .arcache_ocvm_axim          (arcache_ocvm_axim),
  .arprot_ocvm_axim           (arprot_ocvm_axim ),
  .arvalid_ocvm_axim          (arvalid_ocvm_axim),
  .arready_ocvm_axim          (arready_ocvm_axim),
  .rid_ocvm_axim              (rid_ocvm_axim    ),
  .rdata_ocvm_axim            (rdata_ocvm_axim  ),
  .rresp_ocvm_axim            (rresp_ocvm_axim  ),
  .rlast_ocvm_axim            (rlast_ocvm_axim  ),
  .rvalid_ocvm_axim           (rvalid_ocvm_axim ),
  .rready_ocvm_axim           (rready_ocvm_axim ),
  .awuser_ocvm_axim           (awuser_ocvm_axim ),
  .aruser_ocvm_axim           (aruser_ocvm_axim ),
  .awqos_ocvm_axim            (awqos_ocvm_axim  ),
  .arqos_ocvm_axim            (arqos_ocvm_axim  ),
  

  .awid_bootreg_axim          (awid_bootreg_axim   ),
  .awaddr_bootreg_axim        (awaddr_bootreg_axim ),
  .awlen_bootreg_axim         (awlen_bootreg_axim  ),
  .awsize_bootreg_axim        (awsize_bootreg_axim ),
  .awburst_bootreg_axim       (awburst_bootreg_axim),
  .awlock_bootreg_axim        (awlock_bootreg_axim ),
  .awcache_bootreg_axim       (awcache_bootreg_axim),
  .awprot_bootreg_axim        (awprot_bootreg_axim ),
  .awvalid_bootreg_axim       (awvalid_bootreg_axim),
  .awready_bootreg_axim       (awready_bootreg_axim),
  .wdata_bootreg_axim         (wdata_bootreg_axim  ),
  .wstrb_bootreg_axim         (wstrb_bootreg_axim  ),
  .wlast_bootreg_axim         (wlast_bootreg_axim  ),
  .wvalid_bootreg_axim        (wvalid_bootreg_axim ),
  .wready_bootreg_axim        (wready_bootreg_axim ),
  .bid_bootreg_axim           (bid_bootreg_axim    ),
  .bresp_bootreg_axim         (bresp_bootreg_axim  ),
  .bvalid_bootreg_axim        (bvalid_bootreg_axim ),
  .bready_bootreg_axim        (bready_bootreg_axim ),
  .arid_bootreg_axim          (arid_bootreg_axim   ),
  .araddr_bootreg_axim        (araddr_bootreg_axim ),
  .arlen_bootreg_axim         (arlen_bootreg_axim  ),
  .arsize_bootreg_axim        (arsize_bootreg_axim ),
  .arburst_bootreg_axim       (arburst_bootreg_axim),
  .arlock_bootreg_axim        (arlock_bootreg_axim ),
  .arcache_bootreg_axim       (arcache_bootreg_axim),
  .arprot_bootreg_axim        (arprot_bootreg_axim ),
  .arvalid_bootreg_axim       (arvalid_bootreg_axim),
  .arready_bootreg_axim       (arready_bootreg_axim),
  .rid_bootreg_axim           (rid_bootreg_axim    ),
  .rdata_bootreg_axim         (rdata_bootreg_axim  ),
  .rresp_bootreg_axim         (rresp_bootreg_axim  ),
  .rlast_bootreg_axim         (rlast_bootreg_axim  ),
  .rvalid_bootreg_axim        (rvalid_bootreg_axim ),
  .rready_bootreg_axim        (rready_bootreg_axim ),
  .awuser_bootreg_axim        (awuser_bootreg_axim ),
  .aruser_bootreg_axim        (aruser_bootreg_axim ),
  

  .awid_debug_axis            (awid_debug_axis   ),
  .awaddr_debug_axis          (awaddr_debug_axis ),
  .awlen_debug_axis           (awlen_debug_axis  ),
  .awsize_debug_axis          (awsize_debug_axis ),
  .awburst_debug_axis         (awburst_debug_axis),
  .awlock_debug_axis          (awlock_debug_axis ),
  .awcache_debug_axis         (awcache_debug_axis),
  .awprot_debug_axis          (awprot_debug_axis ),
  .awvalid_debug_axis         (awvalid_debug_axis),
  .awready_debug_axis         (awready_debug_axis),
  .wdata_debug_axis           (wdata_debug_axis  ),
  .wstrb_debug_axis           (wstrb_debug_axis  ),
  .wlast_debug_axis           (wlast_debug_axis  ),
  .wvalid_debug_axis          (wvalid_debug_axis ),
  .wready_debug_axis          (wready_debug_axis ),
  .bid_debug_axis             (bid_debug_axis    ),
  .bresp_debug_axis           (bresp_debug_axis  ),
  .bvalid_debug_axis          (bvalid_debug_axis ),
  .bready_debug_axis          (bready_debug_axis ),
  .arid_debug_axis            (arid_debug_axis   ),
  .araddr_debug_axis          (araddr_debug_axis ),
  .arlen_debug_axis           (arlen_debug_axis  ),
  .arsize_debug_axis          (arsize_debug_axis ),
  .arburst_debug_axis         (arburst_debug_axis),
  .arlock_debug_axis          (arlock_debug_axis ),
  .arcache_debug_axis         (arcache_debug_axis),
  .arprot_debug_axis          (arprot_debug_axis ),
  .arvalid_debug_axis         (arvalid_debug_axis),
  .arready_debug_axis         (arready_debug_axis),
  .rid_debug_axis             (rid_debug_axis    ),
  .rdata_debug_axis           (rdata_debug_axis  ),
  .rresp_debug_axis           (rresp_debug_axis  ),
  .rlast_debug_axis           (rlast_debug_axis  ),
  .rvalid_debug_axis          (rvalid_debug_axis ),
  .rready_debug_axis          (rready_debug_axis ),
  .awuser_debug_axis          (awuser_debug_axis ),
  .aruser_debug_axis          (aruser_debug_axis ),
  .ruser_debug_axis           (ruser_debug_axis  ),
  .buser_debug_axis           (buser_debug_axis  ),

                              
  .awid_expslv0_axis          (awid_expslv0_axis    ),
  .awaddr_expslv0_axis        (awaddr_expslv0_axis  ),
  .awlen_expslv0_axis         (awlen_expslv0_axis   ),
  .awsize_expslv0_axis        (awsize_expslv0_axis  ),
  .awburst_expslv0_axis       (awburst_expslv0_axis ),
  .awlock_expslv0_axis        (awlock_expslv0_axis  ),
  .awcache_expslv0_axis       (awcache_expslv0_axis ),
  .awprot_expslv0_axis        (awprot_expslv0_axis  ),
  .awvalid_expslv0_axis       (awvalid_expslv0_axis ),
  .awakeup_expslv0_axis       (awakeup_expslv0_axis ),
  .awready_expslv0_axis       (awready_expslv0_axis ),
  .wdata_expslv0_axis         (wdata_expslv0_axis   ),
  .wstrb_expslv0_axis         (wstrb_expslv0_axis   ),
  .wlast_expslv0_axis         (wlast_expslv0_axis   ),
  .wvalid_expslv0_axis        (wvalid_expslv0_axis  ),
  .wready_expslv0_axis        (wready_expslv0_axis  ),
  .bid_expslv0_axis           (bid_expslv0_axis     ),
  .bresp_expslv0_axis         (bresp_expslv0_axis   ),
  .bvalid_expslv0_axis        (bvalid_expslv0_axis  ),
  .bready_expslv0_axis        (bready_expslv0_axis  ),
  .arid_expslv0_axis          (arid_expslv0_axis    ),
  .araddr_expslv0_axis        (araddr_expslv0_axis  ),
  .arlen_expslv0_axis         (arlen_expslv0_axis   ),
  .arsize_expslv0_axis        (arsize_expslv0_axis  ),
  .arburst_expslv0_axis       (arburst_expslv0_axis ),
  .arlock_expslv0_axis        (arlock_expslv0_axis  ),
  .arcache_expslv0_axis       (arcache_expslv0_axis ),
  .arprot_expslv0_axis        (arprot_expslv0_axis  ),
  .arvalid_expslv0_axis       (arvalid_expslv0_axis ),
  .arready_expslv0_axis       (arready_expslv0_axis ),
  .rid_expslv0_axis           (rid_expslv0_axis     ),
  .rdata_expslv0_axis         (rdata_expslv0_axis   ),
  .rresp_expslv0_axis         (rresp_expslv0_axis   ),
  .rlast_expslv0_axis         (rlast_expslv0_axis   ),
  .rvalid_expslv0_axis        (rvalid_expslv0_axis  ),
  .rready_expslv0_axis        (rready_expslv0_axis  ),
  .awuser_expslv0_axis        (awuser_expslv0_axis  ),
  .aruser_expslv0_axis        (aruser_expslv0_axis  ),
  .awqos_expslv0_axis         (awqos_expslv0_axis  ),
  .arqos_expslv0_axis         (arqos_expslv0_axis  ),

                              
  .awid_expslv1_axis          (awid_expslv1_axis    ),
  .awaddr_expslv1_axis        (awaddr_expslv1_axis  ),
  .awlen_expslv1_axis         (awlen_expslv1_axis   ),
  .awsize_expslv1_axis        (awsize_expslv1_axis  ),
  .awburst_expslv1_axis       (awburst_expslv1_axis ),
  .awlock_expslv1_axis        (awlock_expslv1_axis  ),
  .awcache_expslv1_axis       (awcache_expslv1_axis ),
  .awprot_expslv1_axis        (awprot_expslv1_axis  ),
  .awvalid_expslv1_axis       (awvalid_expslv1_axis ),
  .awakeup_expslv1_axis       (awakeup_expslv1_axis ),
  .awready_expslv1_axis       (awready_expslv1_axis ),
  .wdata_expslv1_axis         (wdata_expslv1_axis   ),
  .wstrb_expslv1_axis         (wstrb_expslv1_axis   ),
  .wlast_expslv1_axis         (wlast_expslv1_axis   ),
  .wvalid_expslv1_axis        (wvalid_expslv1_axis  ),
  .wready_expslv1_axis        (wready_expslv1_axis  ),
  .bid_expslv1_axis           (bid_expslv1_axis     ),
  .bresp_expslv1_axis         (bresp_expslv1_axis   ),
  .bvalid_expslv1_axis        (bvalid_expslv1_axis  ),
  .bready_expslv1_axis        (bready_expslv1_axis  ),
  .arid_expslv1_axis          (arid_expslv1_axis    ),
  .araddr_expslv1_axis        (araddr_expslv1_axis  ),
  .arlen_expslv1_axis         (arlen_expslv1_axis   ),
  .arsize_expslv1_axis        (arsize_expslv1_axis  ),
  .arburst_expslv1_axis       (arburst_expslv1_axis ),
  .arlock_expslv1_axis        (arlock_expslv1_axis  ),
  .arcache_expslv1_axis       (arcache_expslv1_axis ),
  .arprot_expslv1_axis        (arprot_expslv1_axis  ),
  .arvalid_expslv1_axis       (arvalid_expslv1_axis ),
  .arready_expslv1_axis       (arready_expslv1_axis ),
  .rid_expslv1_axis           (rid_expslv1_axis     ),
  .rdata_expslv1_axis         (rdata_expslv1_axis   ),
  .rresp_expslv1_axis         (rresp_expslv1_axis   ),
  .rlast_expslv1_axis         (rlast_expslv1_axis   ),
  .rvalid_expslv1_axis        (rvalid_expslv1_axis  ),
  .rready_expslv1_axis        (rready_expslv1_axis  ),
  .awuser_expslv1_axis        (awuser_expslv1_axis  ),
  .aruser_expslv1_axis        (aruser_expslv1_axis  ),
  .awqos_expslv1_axis         (awqos_expslv1_axis  ),
  .arqos_expslv1_axis         (arqos_expslv1_axis  ),


  .awakeup_extsys0_axis       (awakeup_extsys0_axis),
  .awid_extsys0_axis          (awid_extsys0_axis   ),
  .awaddr_extsys0_axis        (awaddr_extsys0_axis ),
  .awlen_extsys0_axis         (awlen_extsys0_axis  ),
  .awsize_extsys0_axis        (awsize_extsys0_axis ),
  .awburst_extsys0_axis       (awburst_extsys0_axis),
  .awlock_extsys0_axis        (awlock_extsys0_axis ),
  .awcache_extsys0_axis       (awcache_extsys0_axis),
  .awprot_extsys0_axis        (awprot_extsys0_axis ),
  .awvalid_extsys0_axis       (awvalid_extsys0_axis),
  .awready_extsys0_axis       (awready_extsys0_axis),
  .wdata_extsys0_axis         (wdata_extsys0_axis  ),
  .wstrb_extsys0_axis         (wstrb_extsys0_axis  ),
  .wlast_extsys0_axis         (wlast_extsys0_axis  ),
  .wvalid_extsys0_axis        (wvalid_extsys0_axis ),
  .wready_extsys0_axis        (wready_extsys0_axis ),
  .bid_extsys0_axis           (bid_extsys0_axis    ),
  .bresp_extsys0_axis         (bresp_extsys0_axis  ),
  .bvalid_extsys0_axis        (bvalid_extsys0_axis ),
  .bready_extsys0_axis        (bready_extsys0_axis ),
  .arid_extsys0_axis          (arid_extsys0_axis   ),
  .araddr_extsys0_axis        (araddr_extsys0_axis ),
  .arlen_extsys0_axis         (arlen_extsys0_axis  ),
  .arsize_extsys0_axis        (arsize_extsys0_axis ),
  .arburst_extsys0_axis       (arburst_extsys0_axis),
  .arlock_extsys0_axis        (arlock_extsys0_axis ),
  .arcache_extsys0_axis       (arcache_extsys0_axis),
  .arprot_extsys0_axis        (arprot_extsys0_axis ),
  .arvalid_extsys0_axis       (arvalid_extsys0_axis),
  .arready_extsys0_axis       (arready_extsys0_axis),
  .rid_extsys0_axis           (rid_extsys0_axis    ),
  .rdata_extsys0_axis         (rdata_extsys0_axis  ),
  .rresp_extsys0_axis         (rresp_extsys0_axis  ),
  .rlast_extsys0_axis         (rlast_extsys0_axis  ),
  .rvalid_extsys0_axis        (rvalid_extsys0_axis ),
  .rready_extsys0_axis        (rready_extsys0_axis ),
  .awuser_extsys0_axis        (awuser_extsys0_axis ),
  .aruser_extsys0_axis        (aruser_extsys0_axis ),


  .awakeup_extsys1_axis       (awakeup_extsys1_axis),
  .awid_extsys1_axis          (awid_extsys1_axis   ),
  .awaddr_extsys1_axis        (awaddr_extsys1_axis ),
  .awlen_extsys1_axis         (awlen_extsys1_axis  ),
  .awsize_extsys1_axis        (awsize_extsys1_axis ),
  .awburst_extsys1_axis       (awburst_extsys1_axis),
  .awlock_extsys1_axis        (awlock_extsys1_axis ),
  .awcache_extsys1_axis       (awcache_extsys1_axis),
  .awprot_extsys1_axis        (awprot_extsys1_axis ),
  .awvalid_extsys1_axis       (awvalid_extsys1_axis),
  .awready_extsys1_axis       (awready_extsys1_axis),
  .wdata_extsys1_axis         (wdata_extsys1_axis  ),
  .wstrb_extsys1_axis         (wstrb_extsys1_axis  ),
  .wlast_extsys1_axis         (wlast_extsys1_axis  ),
  .wvalid_extsys1_axis        (wvalid_extsys1_axis ),
  .wready_extsys1_axis        (wready_extsys1_axis ),
  .bid_extsys1_axis           (bid_extsys1_axis    ),
  .bresp_extsys1_axis         (bresp_extsys1_axis  ),
  .bvalid_extsys1_axis        (bvalid_extsys1_axis ),
  .bready_extsys1_axis        (bready_extsys1_axis ),
  .arid_extsys1_axis          (arid_extsys1_axis   ),
  .araddr_extsys1_axis        (araddr_extsys1_axis ),
  .arlen_extsys1_axis         (arlen_extsys1_axis  ),
  .arsize_extsys1_axis        (arsize_extsys1_axis ),
  .arburst_extsys1_axis       (arburst_extsys1_axis),
  .arlock_extsys1_axis        (arlock_extsys1_axis ),
  .arcache_extsys1_axis       (arcache_extsys1_axis),
  .arprot_extsys1_axis        (arprot_extsys1_axis ),
  .arvalid_extsys1_axis       (arvalid_extsys1_axis),
  .arready_extsys1_axis       (arready_extsys1_axis),
  .rid_extsys1_axis           (rid_extsys1_axis    ),
  .rdata_extsys1_axis         (rdata_extsys1_axis  ),
  .rresp_extsys1_axis         (rresp_extsys1_axis  ),
  .rlast_extsys1_axis         (rlast_extsys1_axis  ),
  .rvalid_extsys1_axis        (rvalid_extsys1_axis ),
  .rready_extsys1_axis        (rready_extsys1_axis ),
  .awuser_extsys1_axis        (awuser_extsys1_axis ),
  .aruser_extsys1_axis        (aruser_extsys1_axis ),


  .awid_hostcpu_axis          (awid_hostcpu_axis   ),
  .awaddr_hostcpu_axis        (awaddr_hostcpu_axis ),
  .awlen_hostcpu_axis         (awlen_hostcpu_axis  ),
  .awsize_hostcpu_axis        (awsize_hostcpu_axis ),
  .awburst_hostcpu_axis       (awburst_hostcpu_axis),
  .awlock_hostcpu_axis        (awlock_hostcpu_axis ),
  .awcache_hostcpu_axis       (awcache_hostcpu_axis),
  .awprot_hostcpu_axis        (awprot_hostcpu_axis ),
  .awvalid_hostcpu_axis       (awvalid_hostcpu_axis),
  .awready_hostcpu_axis       (awready_hostcpu_axis),
  .wdata_hostcpu_axis         (wdata_hostcpu_axis  ),
  .wstrb_hostcpu_axis         (wstrb_hostcpu_axis  ),
  .wlast_hostcpu_axis         (wlast_hostcpu_axis  ),
  .wvalid_hostcpu_axis        (wvalid_hostcpu_axis ),
  .wready_hostcpu_axis        (wready_hostcpu_axis ),
  .bid_hostcpu_axis           (bid_hostcpu_axis    ),
  .bresp_hostcpu_axis         (bresp_hostcpu_axis  ),
  .bvalid_hostcpu_axis        (bvalid_hostcpu_axis ),
  .bready_hostcpu_axis        (bready_hostcpu_axis ),
  .arid_hostcpu_axis          (arid_hostcpu_axis   ),
  .araddr_hostcpu_axis        (araddr_hostcpu_axis ),
  .arlen_hostcpu_axis         (arlen_hostcpu_axis  ),
  .arsize_hostcpu_axis        (arsize_hostcpu_axis ),
  .arburst_hostcpu_axis       (arburst_hostcpu_axis),
  .arlock_hostcpu_axis        (arlock_hostcpu_axis ),
  .arcache_hostcpu_axis       (arcache_hostcpu_axis),
  .arprot_hostcpu_axis        (arprot_hostcpu_axis ),
  .arvalid_hostcpu_axis       (arvalid_hostcpu_axis),
  .arready_hostcpu_axis       (arready_hostcpu_axis),
  .rid_hostcpu_axis           (rid_hostcpu_axis    ),
  .rdata_hostcpu_axis         (rdata_hostcpu_axis  ),
  .rresp_hostcpu_axis         (rresp_hostcpu_axis  ),
  .rlast_hostcpu_axis         (rlast_hostcpu_axis  ),
  .rvalid_hostcpu_axis        (rvalid_hostcpu_axis ),
  .rready_hostcpu_axis        (rready_hostcpu_axis ),
  .awuser_hostcpu_axis        (awuser_hostcpu_axis ),
  .aruser_hostcpu_axis        (aruser_hostcpu_axis ),
  

  .awid_secenc_axis           ({7'h0, awid_secenc_axis}),
  .awaddr_secenc_axis         (awaddr_secenc_axis ),
  .awlen_secenc_axis          (awlen_secenc_axis  ),
  .awsize_secenc_axis         (awsize_secenc_axis ),
  .awburst_secenc_axis        (awburst_secenc_axis),
  .awlock_secenc_axis         (awlock_secenc_axis ),
  .awcache_secenc_axis        (awcache_secenc_axis),
  .awprot_secenc_axis         (awprot_secenc_axis ),
  .awvalid_secenc_axis        (awvalid_secenc_axis),
  .awready_secenc_axis        (awready_secenc_axis),
  .wdata_secenc_axis          (wdata_secenc_axis  ),
  .wstrb_secenc_axis          (wstrb_secenc_axis  ),
  .wlast_secenc_axis          (wlast_secenc_axis  ),
  .wvalid_secenc_axis         (wvalid_secenc_axis ),
  .wready_secenc_axis         (wready_secenc_axis ),
  .bid_secenc_axis            ({unused_bid_secenc_axis, bid_secenc_axis}),
  .bresp_secenc_axis          (bresp_secenc_axis  ),
  .bvalid_secenc_axis         (bvalid_secenc_axis ),
  .bready_secenc_axis         (bready_secenc_axis ),
  .arid_secenc_axis           ({7'h0, arid_secenc_axis}),
  .araddr_secenc_axis         (araddr_secenc_axis ),
  .arlen_secenc_axis          (arlen_secenc_axis  ),
  .arsize_secenc_axis         (arsize_secenc_axis ),
  .arburst_secenc_axis        (arburst_secenc_axis),
  .arlock_secenc_axis         (arlock_secenc_axis ),
  .arcache_secenc_axis        (arcache_secenc_axis),
  .arprot_secenc_axis         (arprot_secenc_axis ),
  .arvalid_secenc_axis        (arvalid_secenc_axis),
  .arready_secenc_axis        (arready_secenc_axis),
  .rid_secenc_axis            ({unused_rid_secenc_axis, rid_secenc_axis}),
  .rdata_secenc_axis          (rdata_secenc_axis  ),
  .rresp_secenc_axis          (rresp_secenc_axis  ),
  .rlast_secenc_axis          (rlast_secenc_axis  ),
  .rvalid_secenc_axis         (rvalid_secenc_axis ),
  .rready_secenc_axis         (rready_secenc_axis ),
  .awuser_secenc_axis         (awuser_secenc_axis ),
  .aruser_secenc_axis         (aruser_secenc_axis ),
  .buser_secenc_axis          (buser_secenc_axis  ),  
  .ruser_secenc_axis          (ruser_secenc_axis  ),  
                              
                    
  .paddr_extdbg_apb          (paddr_extdbg_apb  ),
  .pselx_extdbg_apb          (pselx_extdbg_apb  ),
  .penable_extdbg_apb        (penable_extdbg_apb),
  .pwrite_extdbg_apb         (pwrite_extdbg_apb ),
  .prdata_extdbg_apb         (prdata_extdbg_apb ),
  .pwdata_extdbg_apb         (pwdata_extdbg_apb ),
  .pprot_extdbg_apb          (pprot_extdbg_apb  ),
  .pstrb_extdbg_apb          (pstrb_extdbg_apb  ),
  .pready_extdbg_apb         (pready_extdbg_apb ),
  .pslverr_extdbg_apb        (pslverr_extdbg_apb),
                    
                    
  .awid_gic_axim            (awid_gic_axim   ),
  .awaddr_gic_axim          ({unused_awaddr_gic,awaddr_gic_axim[18:0]}),
  .awlen_gic_axim           (awlen_gic_axim  ),
  .awsize_gic_axim          (awsize_gic_axim ),
  .awburst_gic_axim         (awburst_gic_axim),
  .awlock_gic_axim          (awlock_gic_axim ),
  .awcache_gic_axim         (awcache_gic_axim),
  .awprot_gic_axim          (awprot_gic_axim ),
  .awqos_gic_axim           (awqos_gic_axim  ),
  .awvalid_gic_axim         (awvalid_gic_axim),
  .awready_gic_axim         (awready_gic_axim),
  .wdata_gic_axim           (wdata_gic_axim  ),
  .wstrb_gic_axim           (wstrb_gic_axim  ),
  .wlast_gic_axim           (wlast_gic_axim  ),
  .wvalid_gic_axim          (wvalid_gic_axim ),
  .wready_gic_axim          (wready_gic_axim ),
  .bid_gic_axim             (bid_gic_axim    ),
  .bresp_gic_axim           (bresp_gic_axim  ),
  .bvalid_gic_axim          (bvalid_gic_axim ),
  .bready_gic_axim          (bready_gic_axim ),
  .arid_gic_axim            (arid_gic_axim   ),
  .araddr_gic_axim          (araddr_gic_axim ),
  .arlen_gic_axim           (arlen_gic_axim  ),
  .arsize_gic_axim          (arsize_gic_axim ),
  .arburst_gic_axim         (arburst_gic_axim),
  .arlock_gic_axim          (arlock_gic_axim ),
  .arcache_gic_axim         (arcache_gic_axim),
  .arprot_gic_axim          (arprot_gic_axim ),
  .arqos_gic_axim           (arqos_gic_axim  ),
  .arvalid_gic_axim         (arvalid_gic_axim),
  .arready_gic_axim         (arready_gic_axim),
  .rid_gic_axim             (rid_gic_axim    ),
  .rdata_gic_axim           (rdata_gic_axim  ),
  .rresp_gic_axim           (rresp_gic_axim  ),
  .rlast_gic_axim           (rlast_gic_axim  ),
  .rvalid_gic_axim          (rvalid_gic_axim ),
  .rready_gic_axim          (rready_gic_axim ),
  .awuser_gic_axim          ({unused_awuser_gic, awuser_gic_axim}),
  .aruser_gic_axim          ({unused_aruser_gic, aruser_gic_axim}),
                   

  .paddr_hostsysdbg_apb        (paddr_hostsysdbg_apb  ),
  .pselx_hostsysdbg_apb        (pselx_hostsysdbg_apb  ),
  .penable_hostsysdbg_apb      (penable_hostsysdbg_apb),
  .pwrite_hostsysdbg_apb       (pwrite_hostsysdbg_apb ),
  .prdata_hostsysdbg_apb       (prdata_hostsysdbg_apb ),
  .pwdata_hostsysdbg_apb       (pwdata_hostsysdbg_apb ),
  .pprot_hostsysdbg_apb        (pprot_hostsysdbg_apb  ),
  .pstrb_hostsysdbg_apb        (pstrb_hostsysdbg_apb  ),
  .pready_hostsysdbg_apb       (pready_hostsysdbg_apb ),
  .pslverr_hostsysdbg_apb      (pslverr_hostsysdbg_apb),


  .paddr_hse_mhu0          (paddr_hse_mhu0  ),
  .pselx_hse_mhu0          (pselx_hse_mhu0  ),
  .penable_hse_mhu0        (penable_hse_mhu0),
  .pwrite_hse_mhu0         (pwrite_hse_mhu0 ),
  .prdata_hse_mhu0         (prdata_hse_mhu0 ),
  .pwdata_hse_mhu0         (pwdata_hse_mhu0 ),
  .pprot_hse_mhu0          (pprot_hse_mhu0  ),
  .pstrb_hse_mhu0          (pstrb_hse_mhu0  ),
  .pready_hse_mhu0         (pready_hse_mhu0 ),
  .pslverr_hse_mhu0        (pslverr_hse_mhu0),


  .paddr_hse_mhu1          (paddr_hse_mhu1  ),
  .pselx_hse_mhu1          (pselx_hse_mhu1  ),
  .penable_hse_mhu1        (penable_hse_mhu1),
  .pwrite_hse_mhu1         (pwrite_hse_mhu1 ),
  .prdata_hse_mhu1         (prdata_hse_mhu1 ),
  .pwdata_hse_mhu1         (pwdata_hse_mhu1 ),
  .pprot_hse_mhu1          (pprot_hse_mhu1  ),
  .pstrb_hse_mhu1          (pstrb_hse_mhu1  ),
  .pready_hse_mhu1         (pready_hse_mhu1 ),
  .pslverr_hse_mhu1        (pslverr_hse_mhu1),


  .paddr_sdc600_apb          (paddr_sdc600_apb  ),
  .pselx_sdc600_apb          (pselx_sdc600_apb  ),
  .penable_sdc600_apb        (penable_sdc600_apb),
  .pwrite_sdc600_apb         (pwrite_sdc600_apb ),
  .prdata_sdc600_apb         (prdata_sdc600_apb ),
  .pwdata_sdc600_apb         (pwdata_sdc600_apb ),
  .pprot_sdc600_apb          (pprot_sdc600_apb  ),
  .pstrb_sdc600_apb          (pstrb_sdc600_apb  ),
  .pready_sdc600_apb         (pready_sdc600_apb ),
  .pslverr_sdc600_apb        (pslverr_sdc600_apb),

  
  .paddr_seh_mhu0          (paddr_seh_mhu0  ),
  .pselx_seh_mhu0          (pselx_seh_mhu0  ),
  .penable_seh_mhu0        (penable_seh_mhu0),
  .pwrite_seh_mhu0         (pwrite_seh_mhu0 ),
  .prdata_seh_mhu0         (prdata_seh_mhu0 ),
  .pwdata_seh_mhu0         (pwdata_seh_mhu0 ),
  .pprot_seh_mhu0          (pprot_seh_mhu0  ),
  .pstrb_seh_mhu0          (pstrb_seh_mhu0  ),
  .pready_seh_mhu0         (pready_seh_mhu0 ),
  .pslverr_seh_mhu0        (pslverr_seh_mhu0),


  .paddr_seh_mhu1          (paddr_seh_mhu1  ),
  .pselx_seh_mhu1          (pselx_seh_mhu1  ),
  .penable_seh_mhu1        (penable_seh_mhu1),
  .pwrite_seh_mhu1         (pwrite_seh_mhu1 ),
  .prdata_seh_mhu1         (prdata_seh_mhu1 ),
  .pwdata_seh_mhu1         (pwdata_seh_mhu1 ),
  .pprot_seh_mhu1          (pprot_seh_mhu1  ),
  .pstrb_seh_mhu1          (pstrb_seh_mhu1  ),
  .pready_seh_mhu1         (pready_seh_mhu1 ),
  .pslverr_seh_mhu1        (pslverr_seh_mhu1),


  .awid_stm_axim            (awid_stm_axim   ),
  .awaddr_stm_axim          (awaddr_stm_axim ),
  .awlen_stm_axim           (awlen_stm_axim  ),
  .awsize_stm_axim          (awsize_stm_axim ),
  .awburst_stm_axim         (awburst_stm_axim),
  .awlock_stm_axim          (awlock_stm_axim ),
  .awcache_stm_axim         (awcache_stm_axim),
  .awprot_stm_axim          (awprot_stm_axim ),
  .awvalid_stm_axim         (awvalid_stm_axim),
  .awready_stm_axim         (awready_stm_axim),
  .wdata_stm_axim           (wdata_stm_axim  ),
  .wstrb_stm_axim           (wstrb_stm_axim  ),
  .wlast_stm_axim           (wlast_stm_axim  ),
  .wvalid_stm_axim          (wvalid_stm_axim ),
  .wready_stm_axim          (wready_stm_axim ),
  .bid_stm_axim             (bid_stm_axim    ),
  .bresp_stm_axim           (bresp_stm_axim  ),
  .bvalid_stm_axim          (bvalid_stm_axim ),
  .bready_stm_axim          (bready_stm_axim ),
  .arid_stm_axim            (arid_stm_axim   ),
  .araddr_stm_axim          (araddr_stm_axim ),
  .arlen_stm_axim           (arlen_stm_axim  ),
  .arsize_stm_axim          (arsize_stm_axim ),
  .arburst_stm_axim         (arburst_stm_axim),
  .arlock_stm_axim          (arlock_stm_axim ),
  .arcache_stm_axim         (arcache_stm_axim),
  .arprot_stm_axim          (arprot_stm_axim ),
  .arvalid_stm_axim         (arvalid_stm_axim),
  .arready_stm_axim         (arready_stm_axim),
  .rid_stm_axim             (rid_stm_axim    ),
  .rdata_stm_axim           (rdata_stm_axim  ),
  .rresp_stm_axim           (rresp_stm_axim  ),
  .rlast_stm_axim           (rlast_stm_axim  ),
  .rvalid_stm_axim          (rvalid_stm_axim ),
  .rready_stm_axim          (rready_stm_axim ),
  .awuser_stm_axim          (awuser_stm_axim ),
  .aruser_stm_axim          (aruser_stm_axim ),
                    
  
  .paddr_es0h_mhu0          (paddr_es0h_mhu0  ),
  .pselx_es0h_mhu0          (pselx_es0h_mhu0  ),
  .penable_es0h_mhu0        (penable_es0h_mhu0),
  .pwrite_es0h_mhu0         (pwrite_es0h_mhu0 ),
  .prdata_es0h_mhu0         (prdata_es0h_mhu0 ),
  .pwdata_es0h_mhu0         (pwdata_es0h_mhu0 ),
  .pprot_es0h_mhu0          (pprot_es0h_mhu0  ),
  .pstrb_es0h_mhu0          (pstrb_es0h_mhu0  ),
  .pready_es0h_mhu0         (pready_es0h_mhu0 ),
  .pslverr_es0h_mhu0        (pslverr_es0h_mhu0),
  
  
  .paddr_hes0_mhu0          (paddr_hes0_mhu0  ),
  .pselx_hes0_mhu0          (pselx_hes0_mhu0  ),
  .penable_hes0_mhu0        (penable_hes0_mhu0),
  .pwrite_hes0_mhu0         (pwrite_hes0_mhu0 ),
  .prdata_hes0_mhu0         (prdata_hes0_mhu0 ),
  .pwdata_hes0_mhu0         (pwdata_hes0_mhu0 ),
  .pprot_hes0_mhu0          (pprot_hes0_mhu0  ),
  .pstrb_hes0_mhu0          (pstrb_hes0_mhu0  ),
  .pready_hes0_mhu0         (pready_hes0_mhu0 ),
  .pslverr_hes0_mhu0        (pslverr_hes0_mhu0),
  
  
  .paddr_es0h_mhu1          (paddr_es0h_mhu1  ),
  .pselx_es0h_mhu1          (pselx_es0h_mhu1  ),
  .penable_es0h_mhu1        (penable_es0h_mhu1),
  .pwrite_es0h_mhu1         (pwrite_es0h_mhu1 ),
  .prdata_es0h_mhu1         (prdata_es0h_mhu1 ),
  .pwdata_es0h_mhu1         (pwdata_es0h_mhu1 ),
  .pprot_es0h_mhu1          (pprot_es0h_mhu1  ),
  .pstrb_es0h_mhu1          (pstrb_es0h_mhu1  ),
  .pready_es0h_mhu1         (pready_es0h_mhu1 ),
  .pslverr_es0h_mhu1        (pslverr_es0h_mhu1),
  
  
  .paddr_hes0_mhu1          (paddr_hes0_mhu1  ),
  .pselx_hes0_mhu1          (pselx_hes0_mhu1  ),
  .penable_hes0_mhu1        (penable_hes0_mhu1),
  .pwrite_hes0_mhu1         (pwrite_hes0_mhu1 ),
  .prdata_hes0_mhu1         (prdata_hes0_mhu1 ),
  .pwdata_hes0_mhu1         (pwdata_hes0_mhu1 ),
  .pprot_hes0_mhu1          (pprot_hes0_mhu1  ),
  .pstrb_hes0_mhu1          (pstrb_hes0_mhu1  ),
  .pready_hes0_mhu1         (pready_hes0_mhu1 ),
  .pslverr_hes0_mhu1        (pslverr_hes0_mhu1),
    
  .paddr_es1h_mhu0          (paddr_es1h_mhu0  ),
  .pselx_es1h_mhu0          (pselx_es1h_mhu0  ),
  .penable_es1h_mhu0        (penable_es1h_mhu0),
  .pwrite_es1h_mhu0         (pwrite_es1h_mhu0 ),
  .prdata_es1h_mhu0         (prdata_es1h_mhu0 ),
  .pwdata_es1h_mhu0         (pwdata_es1h_mhu0 ),
  .pprot_es1h_mhu0          (pprot_es1h_mhu0  ),
  .pstrb_es1h_mhu0          (pstrb_es1h_mhu0  ),
  .pready_es1h_mhu0         (pready_es1h_mhu0 ),
  .pslverr_es1h_mhu0        (pslverr_es1h_mhu0),
  
  
  .paddr_hes1_mhu0          (paddr_hes1_mhu0  ),
  .pselx_hes1_mhu0          (pselx_hes1_mhu0  ),
  .penable_hes1_mhu0        (penable_hes1_mhu0),
  .pwrite_hes1_mhu0         (pwrite_hes1_mhu0 ),
  .prdata_hes1_mhu0         (prdata_hes1_mhu0 ),
  .pwdata_hes1_mhu0         (pwdata_hes1_mhu0 ),
  .pprot_hes1_mhu0          (pprot_hes1_mhu0  ),
  .pstrb_hes1_mhu0          (pstrb_hes1_mhu0  ),
  .pready_hes1_mhu0         (pready_hes1_mhu0 ),
  .pslverr_hes1_mhu0        (pslverr_hes1_mhu0),
  
  
  .paddr_es1h_mhu1          (paddr_es1h_mhu1  ),
  .pselx_es1h_mhu1          (pselx_es1h_mhu1  ),
  .penable_es1h_mhu1        (penable_es1h_mhu1),
  .pwrite_es1h_mhu1         (pwrite_es1h_mhu1 ),
  .prdata_es1h_mhu1         (prdata_es1h_mhu1 ),
  .pwdata_es1h_mhu1         (pwdata_es1h_mhu1 ),
  .pprot_es1h_mhu1          (pprot_es1h_mhu1  ),
  .pstrb_es1h_mhu1          (pstrb_es1h_mhu1  ),
  .pready_es1h_mhu1         (pready_es1h_mhu1 ),
  .pslverr_es1h_mhu1        (pslverr_es1h_mhu1),
  
  
  .paddr_hes1_mhu1          (paddr_hes1_mhu1  ),
  .pselx_hes1_mhu1          (pselx_hes1_mhu1  ),
  .penable_hes1_mhu1        (penable_hes1_mhu1),
  .pwrite_hes1_mhu1         (pwrite_hes1_mhu1 ),
  .prdata_hes1_mhu1         (prdata_hes1_mhu1 ),
  .pwdata_hes1_mhu1         (pwdata_hes1_mhu1 ),
  .pprot_hes1_mhu1          (pprot_hes1_mhu1  ),
  .pstrb_hes1_mhu1          (pstrb_hes1_mhu1  ),
  .pready_hes1_mhu1         (pready_hes1_mhu1 ),
  .pslverr_hes1_mhu1        (pslverr_hes1_mhu1),
    

  .paddr_ppu_cpu_apb        (paddr_ppu_cpu_apb  ),
  .pselx_ppu_cpu_apb        (pselx_ppu_cpu_apb  ),
  .penable_ppu_cpu_apb      (penable_ppu_cpu_apb),
  .pwrite_ppu_cpu_apb       (pwrite_ppu_cpu_apb ),
  .prdata_ppu_cpu_apb       (prdata_ppu_cpu_apb ),
  .pwdata_ppu_cpu_apb       (pwdata_ppu_cpu_apb ),
  .pprot_ppu_cpu_apb        (pprot_ppu_cpu_apb  ),
  .pstrb_ppu_cpu_apb        (                   ), 
  .pready_ppu_cpu_apb       (pready_ppu_cpu_apb ),
  .pslverr_ppu_cpu_apb      (pslverr_ppu_cpu_apb),



  .csysreq_cd_ctrl          (ctrlclk_devqreqn   ),
  .csysack_cd_ctrl          (ctrlclk_devqacceptn),
  .cactive_cd_ctrl          (ctrlclk_devqactive ),

  .ctrlclk                  (ctrlclk_gated),
  .ctrlresetn               (ctrlresetn),

  .aclk_qreqn                 (qch_exp_aclk_devqreqn[1]),
  .aclk_qacceptn              (qch_exp_aclk_devqacceptn[1]),
  .aclk_qdeny                 (qch_exp_aclk_devqdeny[1]),
  .aclk_qactive               (qch_exp_aclk_devqactive[1]),
 

  .aclk                     (aclk_gated),
  .aresetn                  (aresetn),

  .qreqn_systop_base_internal   (qch_exp_systop_internal_devqreqn),
  .qacceptn_systop_base_internal(qch_exp_systop_internal_devqacceptn),
  .qdeny_systop_base_internal   (qch_exp_systop_internal_devqdeny),
  .qactive_systop_base_internal (qch_exp_systop_internal_devqactive),

  .dftcgen                  (dftcgen)
);
assign ctrlclk_devqdeny = 1'b0; 

reg fw_axi_wakeup;
always @(posedge aclk or negedge aresetn)
begin
  if (~aresetn)
  begin
    fw_axi_wakeup <= 1'b0;
  end
  else 
  begin
    fw_axi_wakeup <= awvalid_firewall_axim | arvalid_firewall_axim | wvalid_firewall_axim;
  end
end

  pc_sysctrl_f0_systop #(
  .AXI4S_ID_WIDTH          (4),
  .FW2SYSTOP_FIFO_DEPTH    (FW2SYSTOP_FIFO_DEPTH   ),
  .FW_AXI_ADDR_WIDTH       (FW_AXI_ADDR_WIDTH  ),
  .FW_AXI_DATA_WIDTH       (FW_AXI_DATA_WIDTH  ),
  .FW_AXI_AWID_WIDTH       (FW_AXI_AWID_WIDTH  ),
  .FW_AXI_ARID_WIDTH       (FW_AXI_ARID_WIDTH  ),
  .FW_AXI_AWUSER_WIDTH     (FW_AXI_AWUSER_WIDTH),
  .FW_AXI_WUSER_WIDTH      (FW_AXI_WUSER_WIDTH ),
  .FW_AXI_BUSER_WIDTH      (FW_AXI_BUSER_WIDTH ),
  .FW_AXI_ARUSER_WIDTH     (FW_AXI_ARUSER_WIDTH),
  .FW_AXI_RUSER_WIDTH      (FW_AXI_RUSER_WIDTH ),
  .FW_AXI_AW_FIFO_DEPTH    (FW_AXI_AW_FIFO_DEPTH   ),
  .FW_AXI_W_FIFO_DEPTH     (FW_AXI_W_FIFO_DEPTH    ),
  .FW_AXI_B_FIFO_DEPTH     (FW_AXI_B_FIFO_DEPTH    ),
  .FW_AXI_AR_FIFO_DEPTH    (FW_AXI_AR_FIFO_DEPTH   ),
  .FW_AXI_R_FIFO_DEPTH     (FW_AXI_R_FIFO_DEPTH    ),
  .FW_AXI_AW_PAYLOAD_WIDTH (FW_AXI_AW_PAYLOAD_WIDTH),
  .FW_AXI_W_PAYLOAD_WIDTH  (FW_AXI_W_PAYLOAD_WIDTH ),
  .FW_AXI_B_PAYLOAD_WIDTH  (FW_AXI_B_PAYLOAD_WIDTH ),
  .FW_AXI_AR_PAYLOAD_WIDTH (FW_AXI_AR_PAYLOAD_WIDTH),
  .FW_AXI_R_PAYLOAD_WIDTH  (FW_AXI_R_PAYLOAD_WIDTH )
  )
  u_pc_sysctrl_f0_systop (
  
    .aclk    (aclk_gated),
    .aresetn (aresetn),
        
    .periph_async_req           (aonperiph_async_req),
    .periph_async_req_payload   (aonperiph_async_req_payload ),
    .periph_async_resp_payload  (aonperiph_async_resp_payload),
    .periph_async_ack           (aonperiph_async_ack),
    
    .uart_async_req             (uart_async_req),
    .uart_async_req_payload     (uart_async_req_payload ),
    .uart_async_resp_payload    (uart_async_resp_payload),
    .uart_async_ack             (uart_async_ack),
    
    .bootreg_async_req          (bootreg_async_req),
    .bootreg_async_req_payload  (bootreg_async_req_payload ),
    .bootreg_async_resp_payload (bootreg_async_resp_payload),
    .bootreg_async_ack          (bootreg_async_ack),
    
    .paddr_periph               (paddr_sysctrl_apb),
    .pwdata_periph              (pwdata_sysctrl_apb),
    .pwrite_periph              (pwrite_sysctrl_apb),
    .pprot_periph               (pprot_sysctrl_apb),
    .pstrb_periph               (pstrb_sysctrl_apb),
    .penable_periph             (penable_sysctrl_apb),
    .psel_periph                (pselx_sysctrl_apb),
    .prdata_periph              (prdata_sysctrl_apb),
    .pslverr_periph             (pslverr_sysctrl_apb),
    .pready_periph              (pready_sysctrl_apb),

    .paddr_uart                 (paddr_uart_apb),
    .pwdata_uart                (pwdata_uart_apb),
    .pwrite_uart                (pwrite_uart_apb),
    .pprot_uart                 (pprot_uart_apb),
    .pstrb_uart                 (pstrb_uart_apb),
    .penable_uart               (penable_uart_apb),
    .psel_uart                  (pselx_uart_apb),
    .prdata_uart                (prdata_uart_apb),
    .pslverr_uart               (pslverr_uart_apb),
    .pready_uart                (pready_uart_apb),

  
    .awid_firewall_axim         (awid_firewall_axim   ),
    .awaddr_firewall_axim       (awaddr_firewall_axim ),
    .awlen_firewall_axim        (awlen_firewall_axim  ),
    .awsize_firewall_axim       (awsize_firewall_axim ),
    .awburst_firewall_axim      (awburst_firewall_axim),
    .awlock_firewall_axim       (awlock_firewall_axim ),
    .awcache_firewall_axim      (awcache_firewall_axim),
    .awprot_firewall_axim       (awprot_firewall_axim ),
    .awvalid_firewall_axim      (awvalid_firewall_axim),
    .awready_firewall_axim      (awready_firewall_axim),
    .wdata_firewall_axim        (wdata_firewall_axim  ),
    .wstrb_firewall_axim        (wstrb_firewall_axim  ),
    .wlast_firewall_axim        (wlast_firewall_axim  ),
    .wvalid_firewall_axim       (wvalid_firewall_axim ),
    .wready_firewall_axim       (wready_firewall_axim ),
    .bid_firewall_axim          (bid_firewall_axim    ),
    .bresp_firewall_axim        (bresp_firewall_axim  ),
    .bvalid_firewall_axim       (bvalid_firewall_axim ),
    .bready_firewall_axim       (bready_firewall_axim ),
    .arid_firewall_axim         (arid_firewall_axim   ),
    .araddr_firewall_axim       (araddr_firewall_axim ),
    .arlen_firewall_axim        (arlen_firewall_axim  ),
    .arsize_firewall_axim       (arsize_firewall_axim ),
    .arburst_firewall_axim      (arburst_firewall_axim),
    .arlock_firewall_axim       (arlock_firewall_axim ),
    .arcache_firewall_axim      (arcache_firewall_axim),
    .arprot_firewall_axim       (arprot_firewall_axim ),
    .arvalid_firewall_axim      (arvalid_firewall_axim),
    .arready_firewall_axim      (arready_firewall_axim),
    .rid_firewall_axim          (rid_firewall_axim    ),
    .rdata_firewall_axim        (rdata_firewall_axim  ),
    .rresp_firewall_axim        (rresp_firewall_axim  ),
    .rlast_firewall_axim        (rlast_firewall_axim  ),
    .rvalid_firewall_axim       (rvalid_firewall_axim ),
    .rready_firewall_axim       (rready_firewall_axim ),
    .awuser_firewall_axim       (awuser_firewall_axim ),
    .aruser_firewall_axim       (aruser_firewall_axim ),
    .buser_firewall_axim        (buser_firewall_axim  ),
    .ruser_firewall_axim        (ruser_firewall_axim  ),

    .firewall_slvmustacceptreqn_async (firewall_slvmustacceptreqn_async),
    .firewall_slvcandenyreqn_async    (firewall_slvcandenyreqn_async),
    .firewall_slvacceptn_async        (firewall_slvacceptn_async),
    .firewall_slvdeny_async           (firewall_slvdeny_async),

    .firewall_si_to_mi_wakeup_async   (firewall_si_to_mi_wakeup_async),
    .firewall_mi_to_si_wakeup_async   (firewall_mi_to_si_wakeup_async),

    .firewall_aw_wr_ptr_async         (firewall_aw_wr_ptr_async),
    .firewall_aw_rd_ptr_async         (firewall_aw_rd_ptr_async),
    .firewall_aw_payld_async          (firewall_aw_payld_async ),
    .firewall_w_wr_ptr_async          (firewall_w_wr_ptr_async ),
    .firewall_w_rd_ptr_async          (firewall_w_rd_ptr_async ),
    .firewall_w_payld_async           (firewall_w_payld_async  ),
    .firewall_b_wr_ptr_async          (firewall_b_wr_ptr_async ),
    .firewall_b_rd_ptr_async          (firewall_b_rd_ptr_async ),
    .firewall_b_payld_async           (firewall_b_payld_async  ),
    .firewall_ar_wr_ptr_async         (firewall_ar_wr_ptr_async),
    .firewall_ar_rd_ptr_async         (firewall_ar_rd_ptr_async),
    .firewall_ar_payld_async          (firewall_ar_payld_async ),
    .firewall_r_wr_ptr_async          (firewall_r_wr_ptr_async ),
    .firewall_r_rd_ptr_async          (firewall_r_rd_ptr_async ),
    .firewall_r_payld_async           (firewall_r_payld_async  ),

    .firewall_adb_wakeups_i     (fw_axi_wakeup),
        
    .awid_bootreg_axim          (awid_bootreg_axim   ),
    .awaddr_bootreg_axim        (awaddr_bootreg_axim ),
    .awlen_bootreg_axim         (awlen_bootreg_axim  ),
    .awsize_bootreg_axim        (awsize_bootreg_axim ),
    .awburst_bootreg_axim       (awburst_bootreg_axim),
    .awlock_bootreg_axim        (awlock_bootreg_axim ),
    .awcache_bootreg_axim       (awcache_bootreg_axim),
    .awprot_bootreg_axim        (awprot_bootreg_axim ),
    .awvalid_bootreg_axim       (awvalid_bootreg_axim),
    .awready_bootreg_axim       (awready_bootreg_axim),
    .wdata_bootreg_axim         (wdata_bootreg_axim  ),
    .wstrb_bootreg_axim         (wstrb_bootreg_axim  ),
    .wlast_bootreg_axim         (wlast_bootreg_axim  ),
    .wvalid_bootreg_axim        (wvalid_bootreg_axim ),
    .wready_bootreg_axim        (wready_bootreg_axim ),
    .bid_bootreg_axim           (bid_bootreg_axim    ),
    .bresp_bootreg_axim         (bresp_bootreg_axim  ),
    .bvalid_bootreg_axim        (bvalid_bootreg_axim ),
    .bready_bootreg_axim        (bready_bootreg_axim ),
    .arid_bootreg_axim          (arid_bootreg_axim   ),
    .araddr_bootreg_axim        (araddr_bootreg_axim ),
    .arlen_bootreg_axim         (arlen_bootreg_axim  ),
    .arsize_bootreg_axim        (arsize_bootreg_axim ),
    .arburst_bootreg_axim       (arburst_bootreg_axim),
    .arlock_bootreg_axim        (arlock_bootreg_axim ),
    .arcache_bootreg_axim       (arcache_bootreg_axim),
    .arprot_bootreg_axim        (arprot_bootreg_axim ),
    .arvalid_bootreg_axim       (arvalid_bootreg_axim),
    .arready_bootreg_axim       (arready_bootreg_axim),
    .rid_bootreg_axim           (rid_bootreg_axim    ),
    .rdata_bootreg_axim         (rdata_bootreg_axim  ),
    .rresp_bootreg_axim         (rresp_bootreg_axim  ),
    .rlast_bootreg_axim         (rlast_bootreg_axim  ),
    .rvalid_bootreg_axim        (rvalid_bootreg_axim ),
    .rready_bootreg_axim        (rready_bootreg_axim ),
    .awuser_bootreg_axim        (awuser_bootreg_axim ),
    .aruser_bootreg_axim        (aruser_bootreg_axim ),
    
    .fw2systop_dn_slvmustacceptreqn_async  (fw2systop_dn_slvmustacceptreqn_async),
    .fw2systop_dn_slvcandenyreqn_async     (fw2systop_dn_slvcandenyreqn_async),
    .fw2systop_dn_slvacceptn_async         (fw2systop_dn_slvacceptn_async),
    .fw2systop_dn_slvdeny_async            (fw2systop_dn_slvdeny_async),
    .fw2systop_dn_si_to_mi_wakeup_async    (fw2systop_dn_si_to_mi_wakeup_async),
    .fw2systop_dn_mi_to_si_wakeup_async    (fw2systop_dn_mi_to_si_wakeup_async),
    .fw2systop_dn_wr_ptr_async             (fw2systop_dn_wr_ptr_async),
    .fw2systop_dn_rd_ptr_async             (fw2systop_dn_rd_ptr_async),
    .fw2systop_dn_payld_async              (fw2systop_dn_payld_async),
    
    .fw2systop_dn_wakeupm_o                (twakeup_dti_up_m),
    
    .tvalid_dti_up_m                       (tvalid_dti_up_m),
    .tready_dti_up_m                       (tready_dti_up_m),
    .tdata_dti_up_m                        (tdata_dti_up_m),
    .tkeep_dti_up_m                        (tkeep_dti_up_m),
    .tlast_dti_up_m                        (tlast_dti_up_m),
    .tdest_dti_up_m                        (tdest_dti_up_m),
    
    .fw2systop_up_slvmustacceptreqn_async  (fw2systop_up_slvmustacceptreqn_async),
    .fw2systop_up_slvcandenyreqn_async     (fw2systop_up_slvcandenyreqn_async),
    .fw2systop_up_slvacceptn_async         (fw2systop_up_slvacceptn_async),
    .fw2systop_up_slvdeny_async            (fw2systop_up_slvdeny_async),
    .fw2systop_up_si_to_mi_wakeup_async    (fw2systop_up_si_to_mi_wakeup_async),
    .fw2systop_up_mi_to_si_wakeup_async    (fw2systop_up_mi_to_si_wakeup_async),
    .fw2systop_up_wr_ptr_async             (fw2systop_up_wr_ptr_async),
    .fw2systop_up_rd_ptr_async             (fw2systop_up_rd_ptr_async),
    .fw2systop_up_payld_async              (fw2systop_up_payld_async),

    .fw2systop_up_pwrq_permit_deny_sar_i   (1'b1),
    .firewall_adb_pwrq_permit_deny_sar_i   (1'b1),
    
    .fw2systop_up_wakeups_i                (twakeup_dti_dn_m),
    
    .tvalid_dti_dn_m                       (tvalid_dti_dn_m),
    .tready_dti_dn_m                       (tready_dti_dn_m),
    .tdata_dti_dn_m                        (tdata_dti_dn_m ),
    .tkeep_dti_dn_m                        (tkeep_dti_dn_m ),
    .tlast_dti_dn_m                        (tlast_dti_dn_m ),
    .tid_dti_dn_m                          (tid_dti_dn_m   ),


    .dftrstdisable (dftrstdisable[1]),
    .aclk_qreqn    ({qch_exp_aclk_devqreqn[8],
                     qch_exp_aclk_devqreqn[7],
                     qch_exp_aclk_devqreqn[6],
                     qch_exp_aclk_devqreqn[5],
                     qch_exp_aclk_devqreqn[4],
                     qch_exp_aclk_devqreqn[3],
                     qch_exp_aclk_devqreqn[2]}),
                     
    .aclk_qacceptn ({qch_exp_aclk_devqacceptn[8],
                     qch_exp_aclk_devqacceptn[7],
                     qch_exp_aclk_devqacceptn[6],
                     qch_exp_aclk_devqacceptn[5],
                     qch_exp_aclk_devqacceptn[4],
                     qch_exp_aclk_devqacceptn[3],
                     qch_exp_aclk_devqacceptn[2]}),
                     
    .aclk_qdeny    ({qch_exp_aclk_devqdeny[8],
                     qch_exp_aclk_devqdeny[7],
                     qch_exp_aclk_devqdeny[6],
                     qch_exp_aclk_devqdeny[5],
                     qch_exp_aclk_devqdeny[4],
                     qch_exp_aclk_devqdeny[3],
                     qch_exp_aclk_devqdeny[2]}),
                     
    .aclk_qactive  ({qch_exp_aclk_devqactive[8],
                     qch_exp_aclk_devqactive[7],
                     qch_exp_aclk_devqactive[6],
                     qch_exp_aclk_devqactive[5],
                     qch_exp_aclk_devqactive[4],
                     qch_exp_aclk_devqactive[3],
                     qch_exp_aclk_devqactive[2]}),
    .pwrqreqn      ({qch_exp_systop_egress_devqreqn[4],
                     qch_exp_systop_egress_devqreqn[3],
                     qch_exp_systop_egress_devqreqn[2],
                     qch_exp_systop_egress_devqreqn[1],
                     qch_exp_systop_egress_devqreqn[0]}),
    .pwrqacceptn   ({qch_exp_systop_egress_devqacceptn[4],
                     qch_exp_systop_egress_devqacceptn[3],
                     qch_exp_systop_egress_devqacceptn[2],
                     qch_exp_systop_egress_devqacceptn[1],
                     qch_exp_systop_egress_devqacceptn[0]}),
    .pwrqdeny      ({qch_exp_systop_egress_devqdeny[4],
                     qch_exp_systop_egress_devqdeny[3],
                     qch_exp_systop_egress_devqdeny[2],
                     qch_exp_systop_egress_devqdeny[1],
                     qch_exp_systop_egress_devqdeny[0]}),
    .pwrqactive    ({qch_exp_systop_egress_devqactive[4],
                     qch_exp_systop_egress_devqactive[3],
                     qch_exp_systop_egress_devqactive[2],
                     qch_exp_systop_egress_devqactive[1],
                     qch_exp_systop_egress_devqactive[0]}),

    
    .dftcgen       (dftcgen)
  );


assign hostcpu_gicintmhus     = {
 
                                4'b0, 
 
                                 esh_0_eh1_mhuint,
                                 hes_0_eh1_mhuint, 
                                 esh_0_eh0_mhuint,
                                 hes_0_eh0_mhuint, 
                                 seh0_mhuint,
                                 hse0_mhuint}; 
assign hostcpu_gicintmhuns    = {
 
                                4'b0,
 
                                  esh_1_eh1_mhuint,
                                hes_1_eh1_mhuint, 
                                    esh_1_eh0_mhuint,
                                hes_1_eh0_mhuint, 
                                  seh1_mhuint, 
                                hse1_mhuint}; 


arm_element_or_tree #(
  .NUM_OR_TREE_INPUTS (25)
) u_arm_element_or_tree_system_interrupt (
  .or_tree_i ({hostcpu_gicintwdogns, hostcpu_gicintwdogs, hostcpu_gicintmhuns, hostcpu_gicintmhus, hostcpu_gicintuart}),
  .or_tree_o (system_interrupt)
);

arm_element_or_tree #(
  .NUM_OR_TREE_INPUTS (9)
) u_arm_element_or_tree_router_interrupt (
  .or_tree_i (hostcpu_gicshdint[8:0]),
  .or_tree_o (router_interrupt)
);

//--------------------------------------------------
//             CLUSTOP expansion
//--------------------------------------------------

wire  clustopingressqreqn_loopback;
wire  clustopingressqacceptn_loopback;
wire  clustopegressqreqn_loopback;
wire  clustopegressqacceptn_loopback;

assign  clustopingressqacceptn_loopback = clustopingressqreqn_loopback;
assign  clustopegressqacceptn_loopback  = clustopegressqreqn_loopback;

pc_cpu_f0_systop #(
  .HOST_CPU_NUM_CORES             (HOST_CPU_NUM_CORES),

  .DEV_PREQ_DLY_CLUS            (DEV_PREQ_DLY_CLUS      ),
  .PCSM_PREQ_DLY_CLUS           (PCSM_PREQ_DLY_CLUS     ),
  .ISO_CLKEN_DLY_CFG_CLUS       (ISO_CLKEN_DLY_CFG_CLUS ),
  .CLKEN_RST_DLY_CFG_CLUS       (CLKEN_RST_DLY_CFG_CLUS ),
  .RST_HWSTAT_DLY_CFG_CLUS      (RST_HWSTAT_DLY_CFG_CLUS),
  .CLKEN_ISO_DLY_CFG_CLUS       (CLKEN_ISO_DLY_CFG_CLUS ),
  .ISO_RST_DLY_CFG_CLUS         (ISO_RST_DLY_CFG_CLUS   ),

 
  .DEV_PREQ_DLY_CPU3            (DEV_PREQ_DLY_CPU3      ),
  .PCSM_PREQ_DLY_CPU3           (PCSM_PREQ_DLY_CPU3     ),
  .ISO_CLKEN_DLY_CFG_CPU3       (ISO_CLKEN_DLY_CFG_CPU3 ),
  .CLKEN_RST_DLY_CFG_CPU3       (CLKEN_RST_DLY_CFG_CPU3 ),
  .RST_HWSTAT_DLY_CFG_CPU3      (RST_HWSTAT_DLY_CFG_CPU3),
  .CLKEN_ISO_DLY_CFG_CPU3       (CLKEN_ISO_DLY_CFG_CPU3 ),
  .ISO_RST_DLY_CFG_CPU3         (ISO_RST_DLY_CFG_CPU3   ),
  
 
  .DEV_PREQ_DLY_CPU2            (DEV_PREQ_DLY_CPU2      ),
  .PCSM_PREQ_DLY_CPU2           (PCSM_PREQ_DLY_CPU2     ),
  .ISO_CLKEN_DLY_CFG_CPU2       (ISO_CLKEN_DLY_CFG_CPU2 ),
  .CLKEN_RST_DLY_CFG_CPU2       (CLKEN_RST_DLY_CFG_CPU2 ),
  .RST_HWSTAT_DLY_CFG_CPU2      (RST_HWSTAT_DLY_CFG_CPU2),
  .CLKEN_ISO_DLY_CFG_CPU2       (CLKEN_ISO_DLY_CFG_CPU2 ),
  .ISO_RST_DLY_CFG_CPU2         (ISO_RST_DLY_CFG_CPU2   ),
  
 
  .DEV_PREQ_DLY_CPU1            (DEV_PREQ_DLY_CPU1      ),
  .PCSM_PREQ_DLY_CPU1           (PCSM_PREQ_DLY_CPU1     ),
  .ISO_CLKEN_DLY_CFG_CPU1       (ISO_CLKEN_DLY_CFG_CPU1 ),
  .CLKEN_RST_DLY_CFG_CPU1       (CLKEN_RST_DLY_CFG_CPU1 ),
  .RST_HWSTAT_DLY_CFG_CPU1      (RST_HWSTAT_DLY_CFG_CPU1),
  .CLKEN_ISO_DLY_CFG_CPU1       (CLKEN_ISO_DLY_CFG_CPU1 ),
  .ISO_RST_DLY_CFG_CPU1         (ISO_RST_DLY_CFG_CPU1   ),
  
 
  .DEV_PREQ_DLY_CPU0            (DEV_PREQ_DLY_CPU0      ),
  .PCSM_PREQ_DLY_CPU0           (PCSM_PREQ_DLY_CPU0     ),
  .ISO_CLKEN_DLY_CFG_CPU0       (ISO_CLKEN_DLY_CFG_CPU0 ),
  .CLKEN_RST_DLY_CFG_CPU0       (CLKEN_RST_DLY_CFG_CPU0 ),
  .RST_HWSTAT_DLY_CFG_CPU0      (RST_HWSTAT_DLY_CFG_CPU0),
  .CLKEN_ISO_DLY_CFG_CPU0       (CLKEN_ISO_DLY_CFG_CPU0 ),
  .ISO_RST_DLY_CFG_CPU0         (ISO_RST_DLY_CFG_CPU0   ),
  
  .CPU_ADDR_WIDTH       (CPU_ADDR_WIDTH   ),
  .CPU_DATA_WIDTH       (CPU_DATA_WIDTH   ),
  .CPU_AWID_WIDTH       (CPU_AWID_WIDTH   ),
  .CPU_ARID_WIDTH       (CPU_ARID_WIDTH   ),
  .CPU_AWUSER_WIDTH     (CPU_AWUSER_WIDTH ),
  .CPU_WUSER_WIDTH      (CPU_WUSER_WIDTH  ),
  .CPU_BUSER_WIDTH      (CPU_BUSER_WIDTH  ),
  .CPU_ARUSER_WIDTH     (CPU_ARUSER_WIDTH ),
  .CPU_RUSER_WIDTH      (CPU_RUSER_WIDTH  ),
  .CPU_AW_FIFO_DEPTH    (CPU_AW_FIFO_DEPTH),
  .CPU_W_FIFO_DEPTH     (CPU_W_FIFO_DEPTH ),
  .CPU_B_FIFO_DEPTH     (CPU_B_FIFO_DEPTH ),
  .CPU_AR_FIFO_DEPTH    (CPU_AR_FIFO_DEPTH),
  .CPU_R_FIFO_DEPTH     (CPU_R_FIFO_DEPTH ),
  .CPU_AW_PAYLOAD_WIDTH (CPU_AW_PAYLOAD_WIDTH),
  .CPU_W_PAYLOAD_WIDTH  (CPU_W_PAYLOAD_WIDTH ),
  .CPU_B_PAYLOAD_WIDTH  (CPU_B_PAYLOAD_WIDTH ),
  .CPU_AR_PAYLOAD_WIDTH (CPU_AR_PAYLOAD_WIDTH),
  .CPU_R_PAYLOAD_WIDTH  (CPU_R_PAYLOAD_WIDTH ),
  .GIC_ADDR_WIDTH       (GIC_ADDR_WIDTH   ),
  .GIC_DATA_WIDTH       (GIC_DATA_WIDTH   ),
  .GIC_AWID_WIDTH       (GIC_AWID_WIDTH   ),
  .GIC_ARID_WIDTH       (GIC_ARID_WIDTH   ),
  .GIC_AWUSER_WIDTH     (GIC_AWUSER_WIDTH ),
  .GIC_WUSER_WIDTH      (GIC_WUSER_WIDTH  ),
  .GIC_BUSER_WIDTH      (GIC_BUSER_WIDTH  ),
  .GIC_ARUSER_WIDTH     (GIC_ARUSER_WIDTH ),
  .GIC_RUSER_WIDTH      (GIC_RUSER_WIDTH  ),
  .GIC_AW_FIFO_DEPTH    (GIC_AW_FIFO_DEPTH),
  .GIC_W_FIFO_DEPTH     (GIC_W_FIFO_DEPTH ),
  .GIC_B_FIFO_DEPTH     (GIC_B_FIFO_DEPTH ),
  .GIC_AR_FIFO_DEPTH    (GIC_AR_FIFO_DEPTH),
  .GIC_R_FIFO_DEPTH     (GIC_R_FIFO_DEPTH ),
  .GIC_AW_PAYLOAD_WIDTH (GIC_AW_PAYLOAD_WIDTH),
  .GIC_W_PAYLOAD_WIDTH  (GIC_W_PAYLOAD_WIDTH ),
  .GIC_B_PAYLOAD_WIDTH  (GIC_B_PAYLOAD_WIDTH ),
  .GIC_AR_PAYLOAD_WIDTH (GIC_AR_PAYLOAD_WIDTH),
  .GIC_R_PAYLOAD_WIDTH  (GIC_R_PAYLOAD_WIDTH )
) u_pc_cpu_systop (
  .aclk                       (aclk_gated),
  .aresetn                    (aresetn),

  .ctrlclk                    (ctrlclk_gated),
  .ctrlclk_free               (ctrlclk),
  .ctrlresetn                 (ctrlresetn),

  // CLUSTOP expansion
  .CLUSTOPINGRESSQREQn        (clustopingressqreqn_loopback),
  .CLUSTOPINGRESSQACCEPTn     (clustopingressqacceptn_loopback),
  .CLUSTOPINGRESSQDENY        (1'b0),
  .CLUSTOPINGRESSQACTIVE      (1'b0),

  .CLUSTOPEGRESSQREQn         (clustopegressqreqn_loopback),
  .CLUSTOPEGRESSQACCEPTn      (clustopegressqacceptn_loopback),
  .CLUSTOPEGRESSQDENY         (1'b0),
  .CLUSTOPEGRESSQACTIVE       (1'b0),

  .ppu_dbgen                  (ppu_dbgen),
  .ctrlclk_qreqn              (ctrlclk_qreqn   ),
  .ctrlclk_qacceptn_o         (ctrlclk_qacceptn),
  .ctrlclk_qdeny_o            (ctrlclk_qdeny   ),
  .ctrlclk_qactive_o          (ctrlclk_qactive ),

  .clustop_ppuhwstat_o          (clustop_ppuhwstat),
  
  
  .pc_cpu_ctrlclk_qactive     (pc_cpu_ctrlclk_qactive),

  .awid_hostcpu_axis          (awid_hostcpu_axis   ),
  .awaddr_hostcpu_axis        (awaddr_hostcpu_axis ),
  .awlen_hostcpu_axis         (awlen_hostcpu_axis  ),
  .awsize_hostcpu_axis        (awsize_hostcpu_axis ),
  .awburst_hostcpu_axis       (awburst_hostcpu_axis),
  .awlock_hostcpu_axis        (awlock_hostcpu_axis ),
  .awcache_hostcpu_axis       (awcache_hostcpu_axis),
  .awprot_hostcpu_axis        (awprot_hostcpu_axis ),
  .awvalid_hostcpu_axis       (awvalid_hostcpu_axis),
  .awready_hostcpu_axis       (awready_hostcpu_axis),
  .wdata_hostcpu_axis         (wdata_hostcpu_axis  ),
  .wstrb_hostcpu_axis         (wstrb_hostcpu_axis  ),
  .wlast_hostcpu_axis         (wlast_hostcpu_axis  ),
  .wvalid_hostcpu_axis        (wvalid_hostcpu_axis ),
  .wready_hostcpu_axis        (wready_hostcpu_axis ),
  .bid_hostcpu_axis           (bid_hostcpu_axis    ),
  .bresp_hostcpu_axis         (bresp_hostcpu_axis  ),
  .bvalid_hostcpu_axis        (bvalid_hostcpu_axis ),
  .bready_hostcpu_axis        (bready_hostcpu_axis ),
  .arid_hostcpu_axis          (arid_hostcpu_axis   ),
  .araddr_hostcpu_axis        (araddr_hostcpu_axis ),
  .arlen_hostcpu_axis         (arlen_hostcpu_axis  ),
  .arsize_hostcpu_axis        (arsize_hostcpu_axis ),
  .arburst_hostcpu_axis       (arburst_hostcpu_axis),
  .arlock_hostcpu_axis        (arlock_hostcpu_axis ),
  .arcache_hostcpu_axis       (arcache_hostcpu_axis),
  .arprot_hostcpu_axis        (arprot_hostcpu_axis ),
  .arvalid_hostcpu_axis       (arvalid_hostcpu_axis),
  .arready_hostcpu_axis       (arready_hostcpu_axis),
  .rid_hostcpu_axis           (rid_hostcpu_axis    ),
  .rdata_hostcpu_axis         (rdata_hostcpu_axis  ),
  .rresp_hostcpu_axis         (rresp_hostcpu_axis  ),
  .rlast_hostcpu_axis         (rlast_hostcpu_axis  ),
  .rvalid_hostcpu_axis        (rvalid_hostcpu_axis ),
  .rready_hostcpu_axis        (rready_hostcpu_axis ),
  .awuser_hostcpu_axis        (awuser_hostcpu_axis[1:0] ),
  .aruser_hostcpu_axis        (aruser_hostcpu_axis[1:0] ),
  .awqos_hostcpu_axis         (), 
  .arqos_hostcpu_axis         (), 
  
  .hostcpu_slvmustacceptreqn_async (hostcpu_slvmustacceptreqn_async),
  .hostcpu_slvcandenyreqn_async    (hostcpu_slvcandenyreqn_async   ),
  .hostcpu_slvacceptn_async        (hostcpu_slvacceptn_async       ),
  .hostcpu_slvdeny_async           (hostcpu_slvdeny_async          ),
  .hostcpu_si_to_mi_wakeup_async   (hostcpu_si_to_mi_wakeup_async  ),
  .hostcpu_mi_to_si_wakeup_async   (hostcpu_mi_to_si_wakeup_async  ),
  .hostcpu_aw_wr_ptr_async         (hostcpu_aw_wr_ptr_async        ),
  .hostcpu_aw_rd_ptr_async         (hostcpu_aw_rd_ptr_async        ),
  .hostcpu_aw_payld_async          (hostcpu_aw_payld_async         ),
  .hostcpu_w_wr_ptr_async          (hostcpu_w_wr_ptr_async         ),
  .hostcpu_w_rd_ptr_async          (hostcpu_w_rd_ptr_async         ),
  .hostcpu_w_payld_async           (hostcpu_w_payld_async          ),
  .hostcpu_b_wr_ptr_async          (hostcpu_b_wr_ptr_async         ),
  .hostcpu_b_rd_ptr_async          (hostcpu_b_rd_ptr_async         ),
  .hostcpu_b_payld_async           (hostcpu_b_payld_async          ),
  .hostcpu_ar_wr_ptr_async         (hostcpu_ar_wr_ptr_async        ),
  .hostcpu_ar_rd_ptr_async         (hostcpu_ar_rd_ptr_async        ),
  .hostcpu_ar_payld_async          (hostcpu_ar_payld_async         ),
  .hostcpu_r_wr_ptr_async          (hostcpu_r_wr_ptr_async         ),
  .hostcpu_r_rd_ptr_async          (hostcpu_r_rd_ptr_async         ),
  .hostcpu_r_payld_async           (hostcpu_r_payld_async          ),

  .gic_slvmustacceptreqn_async     (gic_slvmustacceptreqn_async),
  .gic_slvcandenyreqn_async        (gic_slvcandenyreqn_async),
  .gic_slvacceptn_async            (gic_slvacceptn_async),
  .gic_slvdeny_async               (gic_slvdeny_async),

  .gic_si_to_mi_wakeup_async       (gic_si_to_mi_wakeup_async),
  .gic_mi_to_si_wakeup_async       (gic_mi_to_si_wakeup_async),

  .gic_aw_wr_ptr_async             (gic_aw_wr_ptr_async),
  .gic_aw_rd_ptr_async             (gic_aw_rd_ptr_async),
  .gic_aw_payld_async              (gic_aw_payld_async ),
  .gic_w_wr_ptr_async              (gic_w_wr_ptr_async ),
  .gic_w_rd_ptr_async              (gic_w_rd_ptr_async ),
  .gic_w_payld_async               (gic_w_payld_async  ),
  .gic_b_wr_ptr_async              (gic_b_wr_ptr_async ),
  .gic_b_rd_ptr_async              (gic_b_rd_ptr_async ),
  .gic_b_payld_async               (gic_b_payld_async  ),
  .gic_ar_wr_ptr_async             (gic_ar_wr_ptr_async),
  .gic_ar_rd_ptr_async             (gic_ar_rd_ptr_async),
  .gic_ar_payld_async              (gic_ar_payld_async ),
  .gic_r_wr_ptr_async              (gic_r_wr_ptr_async ),
  .gic_r_rd_ptr_async              (gic_r_rd_ptr_async ),
  .gic_r_payld_async               (gic_r_payld_async  ),

  .awvalid_gic_axim       (awvalid_gic_axim ),
  .awready_gic_axim       (awready_gic_axim ),
  .awuser_gic_axim        (awuser_gic_axim[2:0]),
  .awid_gic_axim          (awid_gic_axim),
  .awaddr_gic_axim        (awaddr_gic_axim[18:0]),
  .awregion_gic_axim      (4'h0 ),
  .awlen_gic_axim         (awlen_gic_axim   ),
  .awsize_gic_axim        (awsize_gic_axim  ),
  .awburst_gic_axim       (awburst_gic_axim ),
  .awlock_gic_axim        (awlock_gic_axim  ),
  .awcache_gic_axim       (awcache_gic_axim ),
  .awprot_gic_axim        (awprot_gic_axim  ),
  .awqos_gic_axim         (awqos_gic_axim   ),

  .wvalid_gic_axim        (wvalid_gic_axim  ),
  .wready_gic_axim        (wready_gic_axim  ),
  .wdata_gic_axim         (wdata_gic_axim   ),
  .wstrb_gic_axim         (wstrb_gic_axim   ),
  .wlast_gic_axim         (wlast_gic_axim   ),

  .bvalid_gic_axim        (bvalid_gic_axim  ),
  .bready_gic_axim        (bready_gic_axim  ),
  .bid_gic_axim           (bid_gic_axim     ),
  .bresp_gic_axim         (bresp_gic_axim   ),

  .arvalid_gic_axim       (arvalid_gic_axim ),
  .arready_gic_axim       (arready_gic_axim ),
  .aruser_gic_axim        (aruser_gic_axim[2:0]),
  .arid_gic_axim          (arid_gic_axim),
  .araddr_gic_axim        (araddr_gic_axim[18:0]),
  .arregion_gic_axim      (4'h0),
  .arlen_gic_axim         (arlen_gic_axim   ),
  .arsize_gic_axim        (arsize_gic_axim  ),
  .arburst_gic_axim       (arburst_gic_axim ),
  .arlock_gic_axim        (arlock_gic_axim  ),
  .arcache_gic_axim       (arcache_gic_axim ),
  .arprot_gic_axim        (arprot_gic_axim  ),
  .arqos_gic_axim         (arqos_gic_axim   ),

  .rvalid_gic_axim        (rvalid_gic_axim  ),
  .rready_gic_axim        (rready_gic_axim  ),
  .rid_gic_axim           (rid_gic_axim     ),
  .rdata_gic_axim         (rdata_gic_axim   ),
  .rresp_gic_axim         (rresp_gic_axim   ),
  .rlast_gic_axim         (rlast_gic_axim   ),

  .gic_adb_pwrq_permit_deny_sar_i  (1'b1),

  .pc_cpu_ppu_psel_i               (pselx_ppu_cpu_apb),
  .pc_cpu_ppu_penable_i            (penable_ppu_cpu_apb),
  .pc_cpu_ppu_paddr_i              (paddr_ppu_cpu_apb),
  .pc_cpu_ppu_pwrite_i             (pwrite_ppu_cpu_apb),
  .pc_cpu_ppu_pwdata_i             (pwdata_ppu_cpu_apb),
  .pc_cpu_ppu_prdata_o             (prdata_ppu_cpu_apb),
  .pc_cpu_ppu_pready_o             (pready_ppu_cpu_apb),
  .pc_cpu_ppu_pslverr_o            (pslverr_ppu_cpu_apb),
  .pc_cpu_ppu_pprot_i              (pprot_ppu_cpu_apb),

  .clustop_pcsm_preq_o             (clustop_pcsm_preq_o),
  .clustop_pcsm_pstate_o           (clustop_pcsm_pstate_o),
  .clustop_pcsm_paccept_i          (clustop_pcsm_paccept_i),
  .clustop_pcsm_mode_stat_i        (clustop_pcsm_mode_stat_i),

    
  .host_cpu_boot_msk_boot_msk        (host_cpu_boot_msk_boot_msk[HOST_CPU_NUM_CORES-1:0]),
  .host_cpu_clus_pwr_req_pwr_req     (host_cpu_clus_pwr_req_pwr_req),
  .host_cpu_clus_pwr_req_mem_ret_r   (host_cpu_clus_pwr_req_mem_ret_r),
  .bsys_pwr_req_wakeup_en            (bsys_pwr_req_wakeup_en),
  .gic_wakeup                        (gic_wakeup),
  .system_interrupt_wakeup_clus      (system_interrupt),
  .router_interrupt_wakeup_clus      (router_interrupt),
  .hostcpu_corewakeup                (hostcpu_corewakeup),
  .axiap_csyspwrupreq_1              (axiap_csyspwrupreq_1),
  .axiap_csyspwrupack_1              (axiap_csyspwrupack_1),
  .hostrom_cdbgpwrupreq              (hostrom_cdbgpwrupreq),
  .hostrom_cdbgpwrupack              (hostrom_cdbgpwrupack),

  .hostcpu_dbgnopwrdwn               (hostcpu_dbgnopwrdwn),
  .hostcpu_smpen                     (hostcpu_smpen),
  .hostcpu_wakeupreq                 (hostcpu_wakeupreq),
  .hostcpu_dbgrstreq                 (hostcpu_dbgrstreq),
  .hostcpu_warmrstreq                (hostcpu_warmrstreq),
  .hostcpu_standbywfi                (hostcpu_stanbywfi[HOST_CPU_NUM_CORES-1:0]),
  .hostcpu_standbywfil2              (hostcpu_stanbywfil2),
  .hostcpu_dbgpwrupreq               (hostcpu_dbgpwrupreq[HOST_CPU_NUM_CORES-1:0]),
  .hostcpu_dbgpwrdup                 (hostcpu_dbgpwrdup[HOST_CPU_NUM_CORES-1:0]),
  .hostcpu_l2flushreq                (hostcpu_l2flushreq),
  .hostcpu_l2flushdone               (hostcpu_l2flushdone),
  .hostcpu_l2rstdisable              (hostcpu_l2rstdisable),

  .systop_ingress_qreqn              (clustop_dependency_qreqn),
  .systop_ingress_qacceptn           (clustop_dependency_qacceptn),      
  .systop_ingress_qdeny              (clustop_dependency_qdeny),         
  .systop_ingress_qactive            (clustop_dependency_qactive),       
  
  .hostcpu_cpuqactive                (hostcpu_cpuqactive ),

  .dev_preq_core_power_handshake     (hostcpu_preq_power_handshake),
  .dev_pstate_core_power_handshake   (hostcpu_pstate_power_handshake),
  .dev_paccept_core_power_handshake  (hostcpu_paccept_power_handshake),
  .dev_pdeny_core_power_handshake    (hostcpu_pdeny_power_handshake),

  .dev_preq_core_warmrst_check     (hostcpu_preq_warmrst_check),
  .dev_pstate_core_warmrst_check   (hostcpu_pstate_warmrst_check),
  .dev_paccept_core_warmrst_check  (hostcpu_paccept_warmrst_check),
  .dev_pdeny_core_warmrst_check    (hostcpu_pdeny_warmrst_check),

  .clustop_internal_l2_qreqn         (hostcpu_l2qreqn),
  .clustop_internal_l2_qacceptn      (hostcpu_l2qacceptn),
  .clustop_internal_l2_qdeny         (hostcpu_l2qdeny),
  .clustop_internal_l2_qactive       (hostcpu_l2qactive),

  .hostcpu_axim_egress_qreqn         (hostcpu_axim_egress_qreqn       ),
  .hostcpu_axim_egress_qacceptn      (hostcpu_axim_egress_qacceptn    ),
  .hostcpu_axim_egress_qdeny         (hostcpu_axim_egress_qdeny       ),
  .hostcpu_axim_egress_qactive       (hostcpu_axim_egress_qactive     ),
                                                                            
  .hostcpu_dbgtrace_egress_qreqn     (hostcpu_dbgtrace_egress_comb1_qreqn   ),
  .hostcpu_dbgtrace_egress_qacceptn  (hostcpu_dbgtrace_egress_comb1_qacceptn),
  .hostcpu_dbgtrace_egress_qdeny     (hostcpu_dbgtrace_egress_comb1_qdeny   ),

  .hostcpu_dbgtrace_ingress_qreqn     (hostcpu_dbgtrace_ingress_qreqn   ),
  .hostcpu_dbgtrace_ingress_qacceptn  (hostcpu_dbgtrace_ingress_qacceptn),
  .hostcpu_dbgtrace_ingress_qdeny     (hostcpu_dbgtrace_ingress_qdeny   ),
  .hostcpu_dbgtrace_ingress_qactive   (hostcpu_dbgtrace_ingress_qactive ),

  .clustop_ingress_cti_double_bridge_qreqn    (clustop_ingress_cti_double_bridge_qreqn),
  .clustop_ingress_cti_double_bridge_qacceptn (clustop_ingress_cti_double_bridge_qacceptn),
  .clustop_ingress_cti_double_bridge_qdeny    (clustop_ingress_cti_double_bridge_qdeny),
  .clustop_ingress_cti_double_bridge_qactive  (clustop_ingress_cti_double_bridge_qactive),

  .hostcpu_ctichout_active                    (hostcpu_dbgtrace_egress_comb_qactive_buf[0]),


  .core_poresetn                     (hostcpu_core_poresetn),
  .core_retresetn                    (hostcpu_core_warmresetn),

  .clustop_warmresetn                (hostcpu_clustop_warmresetn),
  .clustop_poresetn                  (hostcpu_clustop_poresetn),

  .clustop_ppu_interrupt_o           (host_ppu_int_st_clustop_int_st),
  .core_ppu_interrupt_o              ({ host_ppu_int_st_core3_int_st, host_ppu_int_st_core2_int_st, host_ppu_int_st_core1_int_st, host_ppu_int_st_core0_int_st}),
  .clustop_devclken_o                (clustop_devclken),

  .dftrstdisable                   (dftrstdisable[1]), 
  .dftpwrupcpu                     ({HOST_CPU_NUM_CORES{dftpwrup}}), 
  .dftretdisable                   ({HOST_CPU_NUM_CORES{dftretdisable}}), 
  .clustop_dftisodisable           (dftisodisable ), 
  .coreppu_dftisodisable           ({HOST_CPU_NUM_CORES{dftisodisable}}), 
  
  .aclk_qreqn    ({                                   
                   qch_exp_aclk_devqreqn[10],
                   qch_exp_aclk_devqreqn[9]}),
                   
  .aclk_qacceptn ({                                                         
                   qch_exp_aclk_devqacceptn[10],
                   qch_exp_aclk_devqacceptn[9]}),
  .aclk_qdeny    ({                                                         
                   qch_exp_aclk_devqdeny[10],
                   qch_exp_aclk_devqdeny[9]}),
  .aclk_qactive  ({                                                         
                   qch_exp_aclk_devqactive[10],
                   qch_exp_aclk_devqactive[9]}),    
  
  
  .host_lock                      (host_lock),
  .modify_lock_req                (modify_lock_req),
  .modify_lock_ack                (modify_lock_ack),
  
  .dftcgen                         (dftcgen)
);   


   


pd_clustop_f0 #(
  .HOST_CPU_NUM_CORES             (HOST_CPU_NUM_CORES),
  .NUM_EXP_SHD_INT      (NUM_EXP_SHD_INT),
  .HOST_CPU_TYPE        (HOST_CPU_TYPE),
  .ATB_DATA_WIDTH       (ATB_DATA_WIDTH),
  .CLUSTOP_CORE_RST_DLY (CLUSTOP_CORE_RST_DLY),
  .CPU_ADDR_WIDTH       (CPU_ADDR_WIDTH   ),
  .CPU_DATA_WIDTH       (CPU_DATA_WIDTH   ),
  .CPU_AWID_WIDTH       (CPU_AWID_WIDTH   ),
  .CPU_ARID_WIDTH       (CPU_ARID_WIDTH   ),
  .CPU_AWUSER_WIDTH     (CPU_AWUSER_WIDTH ),
  .CPU_WUSER_WIDTH      (CPU_WUSER_WIDTH  ),
  .CPU_BUSER_WIDTH      (CPU_BUSER_WIDTH  ),
  .CPU_ARUSER_WIDTH     (CPU_ARUSER_WIDTH ),
  .CPU_RUSER_WIDTH      (CPU_RUSER_WIDTH  ),
  .CPU_AW_FIFO_DEPTH    (CPU_AW_FIFO_DEPTH),
  .CPU_W_FIFO_DEPTH     (CPU_W_FIFO_DEPTH ),
  .CPU_B_FIFO_DEPTH     (CPU_B_FIFO_DEPTH ),
  .CPU_AR_FIFO_DEPTH    (CPU_AR_FIFO_DEPTH),
  .CPU_R_FIFO_DEPTH     (CPU_R_FIFO_DEPTH ),
  .CPU_AW_PAYLOAD_WIDTH (CPU_AW_PAYLOAD_WIDTH),
  .CPU_W_PAYLOAD_WIDTH  (CPU_W_PAYLOAD_WIDTH ),
  .CPU_B_PAYLOAD_WIDTH  (CPU_B_PAYLOAD_WIDTH ),
  .CPU_AR_PAYLOAD_WIDTH (CPU_AR_PAYLOAD_WIDTH),
  .CPU_R_PAYLOAD_WIDTH  (CPU_R_PAYLOAD_WIDTH ),
  .GIC_ADDR_WIDTH       (GIC_ADDR_WIDTH   ),
  .GIC_DATA_WIDTH       (GIC_DATA_WIDTH   ),
  .GIC_AWID_WIDTH       (GIC_AWID_WIDTH   ),
  .GIC_ARID_WIDTH       (GIC_ARID_WIDTH   ),
  .GIC_AWUSER_WIDTH     (GIC_AWUSER_WIDTH ),
  .GIC_WUSER_WIDTH      (GIC_WUSER_WIDTH  ),
  .GIC_BUSER_WIDTH      (GIC_BUSER_WIDTH  ),
  .GIC_ARUSER_WIDTH     (GIC_ARUSER_WIDTH ),
  .GIC_RUSER_WIDTH      (GIC_RUSER_WIDTH  ),
  .GIC_AW_FIFO_DEPTH    (GIC_AW_FIFO_DEPTH),
  .GIC_W_FIFO_DEPTH     (GIC_W_FIFO_DEPTH ),
  .GIC_B_FIFO_DEPTH     (GIC_B_FIFO_DEPTH ),
  .GIC_AR_FIFO_DEPTH    (GIC_AR_FIFO_DEPTH),
  .GIC_R_FIFO_DEPTH     (GIC_R_FIFO_DEPTH ),
  .GIC_AW_PAYLOAD_WIDTH (GIC_AW_PAYLOAD_WIDTH),
  .GIC_W_PAYLOAD_WIDTH  (GIC_W_PAYLOAD_WIDTH ),
  .GIC_B_PAYLOAD_WIDTH  (GIC_B_PAYLOAD_WIDTH ),
  .GIC_AR_PAYLOAD_WIDTH (GIC_AR_PAYLOAD_WIDTH),
  .GIC_R_PAYLOAD_WIDTH  (GIC_R_PAYLOAD_WIDTH )
) u_pd_clustop (

  .refclk                          (refclk_clustop),
  .cpu_pll                         (cpu_pll_clustop),
  .sys_pll                         (sys_pll_clustop),
  .hostcpu_core_poresetn           (hostcpu_core_poresetn),
  .hostcpu_core_warmresetn         (hostcpu_core_warmresetn),

  .hostcpu_clustop_poresetn        (hostcpu_clustop_poresetn),
  .hostcpu_clustop_warmresetn      (hostcpu_clustop_warmresetn),

  .hostcpu_gicintdbgtop            (hostcpu_gicintdbgtop),
  .hostcpu_gicintmhus              (hostcpu_gicintmhus),
  .hostcpu_gicintmhuns             (hostcpu_gicintmhuns),
  .hostcpu_gicintuart              (hostcpu_gicintuart),
  .hostcpu_gicintwdogs             (hostcpu_gicintwdogs),
  .hostcpu_gicintwdogns            (hostcpu_gicintwdogns),
  .hostcpu_gicshdint               (hostcpu_gicshdint),

  .hostcpu_gicintdbgtop_pulse_ack  (hostcpu_gicintdbgtop_pulse_ack_buf),

  .hostcpu_tsvalueb                (tsvalueb),

  .hostcpuclk_div1_clkdiv          (hostcpuclk_div1_clkdiv),
  .hostcpuclk_div1_clkdiv_cur      (hostcpuclk_div1_clkdiv_cur_buf),

  .hostcpuclk_div0_clkdiv          (hostcpuclk_div0_clkdiv),
  .hostcpuclk_div0_clkdiv_cur      (hostcpuclk_div0_clkdiv_cur_buf),

  .hostcpuclk_ctrl_clkselect       (hostcpuclk_ctrl_clkselect),
  .hostcpuclk_ctrl_clkselect_cur   (hostcpuclk_ctrl_clkselect_cur_buf),
 

  .gicclk_div0_clkdiv              (gicclk_div0_clkdiv),
  .gicclk_div0_clkdiv_cur          (gicclk_div0_clkdiv_cur_buf),

  .gicclk_ctrl_clkselect           (gicclk_ctrl_clkselect),
  .gicclk_ctrl_clkselect_cur       (gicclk_ctrl_clkselect_cur_buf),


  .cpu_pwrq_permit_deny_sar_i      (1'b1),

  .hostcpu_axim_egress_qreqn         (hostcpu_axim_egress_qreqn       ),
  .hostcpu_axim_egress_qacceptn      (hostcpu_axim_egress_qacceptn    ),
  .hostcpu_axim_egress_qdeny         (hostcpu_axim_egress_qdeny       ),
  .hostcpu_axim_egress_qactive       (hostcpu_axim_egress_qactive     ),
                                                               
  .hostcpu_dbgtrace_cti_egress_qreqn     (hostcpu_dbgtrace_egress_comb_qreqn       ),
  .hostcpu_dbgtrace_cti_egress_qacceptn  (hostcpu_dbgtrace_egress_comb_qacceptn_buf),
  .hostcpu_dbgtrace_cti_egress_qdeny     (hostcpu_dbgtrace_egress_comb_qdeny_buf   ),
  .hostcpu_dbgtrace_cti_egress_qactive   (hostcpu_dbgtrace_egress_comb_qactive_buf ),

  .clustop_ingress_cti_double_bridge_qreqn    (clustop_ingress_cti_double_bridge_qreqn   ),
  .clustop_ingress_cti_double_bridge_qacceptn (clustop_ingress_cti_double_bridge_qacceptn),
  .clustop_ingress_cti_double_bridge_qdeny    (clustop_ingress_cti_double_bridge_qdeny   ),
  .clustop_ingress_cti_double_bridge_qactive  (clustop_ingress_cti_double_bridge_qactive ),

                        
  .hostcpu_slvmustacceptreqn_async (hostcpu_slvmustacceptreqn_async),
  .hostcpu_slvcandenyreqn_async    (hostcpu_slvcandenyreqn_async   ),
  .hostcpu_slvacceptn_async        (hostcpu_slvacceptn_async       ),
  .hostcpu_slvdeny_async           (hostcpu_slvdeny_async          ),
  .hostcpu_si_to_mi_wakeup_async   (hostcpu_si_to_mi_wakeup_async  ),
  .hostcpu_mi_to_si_wakeup_async   (hostcpu_mi_to_si_wakeup_async  ),
  .hostcpu_aw_wr_ptr_async         (hostcpu_aw_wr_ptr_async        ),
  .hostcpu_aw_rd_ptr_async         (hostcpu_aw_rd_ptr_async        ),
  .hostcpu_aw_payld_async          (hostcpu_aw_payld_async         ),
  .hostcpu_w_wr_ptr_async          (hostcpu_w_wr_ptr_async         ),
  .hostcpu_w_rd_ptr_async          (hostcpu_w_rd_ptr_async         ),
  .hostcpu_w_payld_async           (hostcpu_w_payld_async          ),
  .hostcpu_b_wr_ptr_async          (hostcpu_b_wr_ptr_async         ),
  .hostcpu_b_rd_ptr_async          (hostcpu_b_rd_ptr_async         ),
  .hostcpu_b_payld_async           (hostcpu_b_payld_async          ),
  .hostcpu_ar_wr_ptr_async         (hostcpu_ar_wr_ptr_async        ),
  .hostcpu_ar_rd_ptr_async         (hostcpu_ar_rd_ptr_async        ),
  .hostcpu_ar_payld_async          (hostcpu_ar_payld_async         ),
  .hostcpu_r_wr_ptr_async          (hostcpu_r_wr_ptr_async         ),
  .hostcpu_r_rd_ptr_async          (hostcpu_r_rd_ptr_async         ),
  .hostcpu_r_payld_async           (hostcpu_r_payld_async          ),

  .gic_slvmustacceptreqn_async     (gic_slvmustacceptreqn_async),
  .gic_slvcandenyreqn_async        (gic_slvcandenyreqn_async),
  .gic_slvacceptn_async            (gic_slvacceptn_async),
  .gic_slvdeny_async               (gic_slvdeny_async),

  .gic_si_to_mi_wakeup_async       (gic_si_to_mi_wakeup_async),    
  .gic_mi_to_si_wakeup_async       (gic_mi_to_si_wakeup_async), 

  .gic_aw_wr_ptr_async             (gic_aw_wr_ptr_async),
  .gic_aw_rd_ptr_async             (gic_aw_rd_ptr_async),
  .gic_aw_payld_async              (gic_aw_payld_async ),
  .gic_w_wr_ptr_async              (gic_w_wr_ptr_async ),
  .gic_w_rd_ptr_async              (gic_w_rd_ptr_async ),
  .gic_w_payld_async               (gic_w_payld_async  ),
  .gic_b_wr_ptr_async              (gic_b_wr_ptr_async ),
  .gic_b_rd_ptr_async              (gic_b_rd_ptr_async ),
  .gic_b_payld_async               (gic_b_payld_async  ),
  .gic_ar_wr_ptr_async             (gic_ar_wr_ptr_async),
  .gic_ar_rd_ptr_async             (gic_ar_rd_ptr_async),
  .gic_ar_payld_async              (gic_ar_payld_async ),
  .gic_r_wr_ptr_async              (gic_r_wr_ptr_async ),
  .gic_r_rd_ptr_async              (gic_r_rd_ptr_async ),
  .gic_r_payld_async               (gic_r_payld_async  ),

  .hostcpu_l2rstdisable            (hostcpu_l2rstdisable ),
                               
  .hostcpu_debug_async_req          (debug_hostcpu_async_req             ),
  .hostcpu_debug_async_req_payload  (debug_hostcpu_async_req_payload     ),
  .hostcpu_debug_async_resp_payload (debug_hostcpu_async_resp_payload_buf),
  .hostcpu_debug_async_ack          (debug_hostcpu_async_ack_buf         ),
  
  
  .hostcpu_dbgen                   (hostcpu_dbgen    ), 
  .hostcpu_spiden                  (hostcpu_spiden   ),
  .hostcpu_niden                   (hostcpu_niden    ), 
  .hostcpu_spniden                 (hostcpu_spniden  ),
  .hostcpu_dbgpwrdup               (hostcpu_dbgpwrdup),
  .hostcpu_cp15sdisable            (host_lock[3:0]),
 

  .hostcpu_dbgnopwrdwn             (hostcpu_dbgnopwrdwn     ), 
  .hostcpu_dbgpwrupreq             (hostcpu_dbgpwrupreq     ), 
  .host_cntvalueg                  (host_cntvalueg),
  .host_cntclkout                  (host_cntclkout_clustop),

  .hostcpu_cfgend                  ({pe3_config_cfgend, pe2_config_cfgend, pe1_config_cfgend, pe0_config_cfgend}), 
  .hostcpu_vinithi                 ({pe3_config_vinithi, pe2_config_vinithi, pe1_config_vinithi, pe0_config_vinithi}), 
  .hostcpu_cfgte                   ({pe3_config_cfgte, pe2_config_cfgte, pe1_config_cfgte, pe0_config_cfgte}), 
  .hostcpu_cfgsdisable             (host_lock[4]  ),
  .hostcpu_stanbywfi               (hostcpu_stanbywfi    ), 
  .hostcpu_stanbywfil2             (hostcpu_stanbywfil2  ),
  .hostcpu_mbistreq                (mbistreq             ),
  .nmbistreset                     (nmbistreset          ),
  .hostcpu_dftrstdisable           ({dftrstdisable[0], dftrstdisable[1]}),
  .hostcpu_dftramhold              (hostcpu_dftramhold   ),

  .hostcpu_cryptodisable           (cluster_config_cryptodisable),
  .hostcpu_aa64naa32               ({pe3_config_aa64naa32, pe2_config_aa64naa32, pe1_config_aa64naa32, pe0_config_aa64naa32}),
  .hostcpu_rvbaraddr0              ({pe0_rvbaraddr_up_rvbar43_32[7:0], pe0_rvbaraddr_lw_rvbar31_2}),
  .hostcpu_rvbaraddr1              ({pe1_rvbaraddr_up_rvbar43_32[7:0], pe1_rvbaraddr_lw_rvbar31_2}),
  .hostcpu_rvbaraddr2              ({pe2_rvbaraddr_up_rvbar43_32[7:0], pe2_rvbaraddr_lw_rvbar31_2}),
  .hostcpu_rvbaraddr3              ({pe3_rvbaraddr_up_rvbar43_32[7:0], pe3_rvbaraddr_lw_rvbar31_2}),

  .hostcpu_ctichin                 (hostcpu_ctichin), 
  .hostcpu_ctichoutack             (hostcpu_ctichoutack), 
  .hostcpu_ctichout                (hostcpu_ctichout_buf), 
  .hostcpu_ctichinack              (hostcpu_ctichinack_buf), 

  .hostcpu_atb_fwd_data            (debug_hostcpu_atb_fwd_data_buf      ), 
  .hostcpu_wr_pointer_gray         (debug_hostcpu_wr_pointer_gray_buf   ),
  .hostcpu_rd_pointer_gray         (debug_hostcpu_rd_pointer_gray       ), 
  .hostcpu_flush_req               (debug_hostcpu_flush_req             ),
  .hostcpu_flush_done              (debug_hostcpu_flush_done_buf        ),
  .hostcpu_sync_clear              (debug_hostcpu_sync_clear_buf        ),
  .hostcpu_sync_done               (debug_hostcpu_sync_done             ),
  .hostcpu_syncreq_async_req       (debug_hostcpu_syncreq_async_req     ),
  .hostcpu_syncreq_async_ack       (debug_hostcpu_syncreq_async_ack_buf ),

  .hostcpu_warmrstreq              (hostcpu_warmrstreq          ),
  .hostcpu_l2flushreq              (hostcpu_l2flushreq          ),
  .hostcpu_l2flushdone             (hostcpu_l2flushdone         ),
  .hostcpu_wakeupreq               (hostcpu_wakeupreq           ),
                                                                
  .hostcpu_cpuqactive              (hostcpu_cpuqactive          ),

  .hostcpu_preq_power_handshake    (hostcpu_preq_power_handshake   ),
  .hostcpu_pstate_power_handshake  (hostcpu_pstate_power_handshake ),
  .hostcpu_paccept_power_handshake (hostcpu_paccept_power_handshake),
  .hostcpu_pdeny_power_handshake   (hostcpu_pdeny_power_handshake  ),

  .hostcpu_preq_warmrst_check      (hostcpu_preq_warmrst_check   ),
  .hostcpu_pstate_warmrst_check    (hostcpu_pstate_warmrst_check ),
  .hostcpu_paccept_warmrst_check   (hostcpu_paccept_warmrst_check),
  .hostcpu_pdeny_warmrst_check     (hostcpu_pdeny_warmrst_check  ),

  .hostcpu_l2qactive               (hostcpu_l2qactive           ),
  .hostcpu_l2qreqn                 (hostcpu_l2qreqn             ),
  .hostcpu_l2qdeny                 (hostcpu_l2qdeny             ),
  .hostcpu_l2qacceptn              (hostcpu_l2qacceptn          ),
                                                                
  .hostcpu_dbgrstreq               (hostcpu_dbgrstreq           ),
                                                                
  .hostcpu_dftcgen                 (dftcgen             ),
  .hostcpu_dftmcphold              (hostcpu_dftmcphold          ),
  .hostcpu_smpen                   (hostcpu_smpen               ),

  .hostcpu_cpuwait                 (hostcpu_cpuwait),

  .dftdivsel                       (dftdivsel),
  .dftgicclksel                    (dftgicclksel),
  .dftgicclkselen                  (dftgicclkselen),
  .dftgicclkdivbypass              (dftgicclkdivbypass),
  
  .dfthostcpuclksel                (dfthostcpuclksel),
  .dfthostcpuclkselen              (dfthostcpuclkselen),
  .dfthostcpuclkdivbypass          (dfthostcpuclkdivbypass)

  );

  pc_eh_f0_systop #(
    .EXT_SYSX_TZ_SPT              (EXT_SYS0_TZ_SPT),
    .MHU_HESX0_NUM_CH             (MHU_HES00_NUM_CH),
    .MHU_ESXH0_NUM_CH             (MHU_ES0H0_NUM_CH),
      .MHU_HESX1_NUM_CH             (MHU_HES01_NUM_CH),
    .MHU_ESXH1_NUM_CH             (MHU_ES0H1_NUM_CH),
      .EXT_SYS_NUM                  (8'h0),

    .EXT_SYSX_MEM_ADDR_WIDTH       (EXT_SYS0_MEM_ADDR_WIDTH),
    .EXT_SYSX_MEM_DATA_WIDTH       (EXT_SYS0_MEM_DATA_WIDTH),
    .EXT_SYSX_MEM_AWID_WIDTH       (EXT_SYS0_MEM_AWID_WIDTH),
    .EXT_SYSX_MEM_ARID_WIDTH       (EXT_SYS0_MEM_ARID_WIDTH),
    .EXT_SYSX_MEM_AWUSER_WIDTH     (EXT_SYS0_MEM_AWUSER_WIDTH),
    .EXT_SYSX_MEM_WUSER_WIDTH      (EXT_SYS0_MEM_WUSER_WIDTH),
    .EXT_SYSX_MEM_BUSER_WIDTH      (EXT_SYS0_MEM_BUSER_WIDTH),
    .EXT_SYSX_MEM_ARUSER_WIDTH     (EXT_SYS0_MEM_ARUSER_WIDTH),
    .EXT_SYSX_MEM_RUSER_WIDTH      (EXT_SYS0_MEM_RUSER_WIDTH),
    .EXT_SYSX_MEM_AW_FIFO_DEPTH    (EXT_SYS0_MEM_AW_FIFO_DEPTH),
    .EXT_SYSX_MEM_W_FIFO_DEPTH     (EXT_SYS0_MEM_W_FIFO_DEPTH),
    .EXT_SYSX_MEM_B_FIFO_DEPTH     (EXT_SYS0_MEM_B_FIFO_DEPTH),
    .EXT_SYSX_MEM_AR_FIFO_DEPTH    (EXT_SYS0_MEM_AR_FIFO_DEPTH),
    .EXT_SYSX_MEM_R_FIFO_DEPTH     (EXT_SYS0_MEM_R_FIFO_DEPTH),
    .EXT_SYSX_MEM_AW_PAYLOAD_WIDTH (EXT_SYS0_MEM_AW_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_W_PAYLOAD_WIDTH  (EXT_SYS0_MEM_W_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_B_PAYLOAD_WIDTH  (EXT_SYS0_MEM_B_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_AR_PAYLOAD_WIDTH (EXT_SYS0_MEM_AR_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_R_PAYLOAD_WIDTH  (EXT_SYS0_MEM_R_PAYLOAD_WIDTH)
  ) u_pc_eh0_f0_systop (
    .aclk                                         (aclk_gated),
    .systopwarmresetn                             (aresetn),
    .qactive_extsysx_mhupwrreq                    (qactive_extsys0_mhupwrreq),
    .awakeup_extsysx_axis                         (awakeup_extsys0_axis),
    .awid_extsysx_axis                            (awid_extsys0_axis),
    .awaddr_extsysx_axis                          (awaddr_extsys0_axis),
    .awregion_extsysx_axis                        (),
    .awlen_extsysx_axis                           (awlen_extsys0_axis),
    .awsize_extsysx_axis                          (awsize_extsys0_axis),
    .awburst_extsysx_axis                         (awburst_extsys0_axis),
    .awlock_extsysx_axis                          (awlock_extsys0_axis),
    .awcache_extsysx_axis                         (awcache_extsys0_axis),
    .awprot_extsysx_axis                          (awprot_extsys0_axis),
    .awvalid_extsysx_axis                         (awvalid_extsys0_axis),
    .awuser_extsysx_axis                          (awuser_extsys0_axis),
    .awready_extsysx_axis                         (awready_extsys0_axis),
    .wstrb_extsysx_axis                           (wstrb_extsys0_axis),
    .wlast_extsysx_axis                           (wlast_extsys0_axis),
    .wvalid_extsysx_axis                          (wvalid_extsys0_axis),
    .wdata_extsysx_axis                           (wdata_extsys0_axis),
    .wready_extsysx_axis                          (wready_extsys0_axis),
    .bid_extsysx_axis                             (bid_extsys0_axis),
    .bresp_extsysx_axis                           (bresp_extsys0_axis),
    .bvalid_extsysx_axis                          (bvalid_extsys0_axis),
    .bready_extsysx_axis                          (bready_extsys0_axis),
    .arid_extsysx_axis                            (arid_extsys0_axis),
    .araddr_extsysx_axis                          (araddr_extsys0_axis),
    .arregion_extsysx_axis                        (),
    .arlen_extsysx_axis                           (arlen_extsys0_axis),
    .arsize_extsysx_axis                          (arsize_extsys0_axis),
    .arburst_extsysx_axis                         (arburst_extsys0_axis),
    .arlock_extsysx_axis                          (arlock_extsys0_axis),
    .arcache_extsysx_axis                         (arcache_extsys0_axis),
    .arprot_extsysx_axis                          (arprot_extsys0_axis),
    .arvalid_extsysx_axis                         (arvalid_extsys0_axis),
    .aruser_extsysx_axis                          (aruser_extsys0_axis),
    .arready_extsysx_axis                         (arready_extsys0_axis),
    .rid_extsysx_axis                             (rid_extsys0_axis),
    .rresp_extsysx_axis                           (rresp_extsys0_axis),
    .rlast_extsysx_axis                           (rlast_extsys0_axis),
    .rvalid_extsysx_axis                          (rvalid_extsys0_axis),
    .rdata_extsysx_axis                           (rdata_extsys0_axis),
    .rready_extsysx_axis                          (rready_extsys0_axis),
    .slvmustacceptreqn_async_ehx                  (slvmustacceptreqn_async_eh0),
    .slvcandenyreqn_async_ehx                     (slvcandenyreqn_async_eh0),
    .slvacceptn_async_ehx                         (slvacceptn_async_eh0),
    .slvdeny_async_ehx                            (slvdeny_async_eh0),
    .si_to_mi_wakeup_async_ehx                    (si_to_mi_wakeup_async_eh0),
    .mi_to_si_wakeup_async_ehx                    (mi_to_si_wakeup_async_eh0),
    .aw_wr_ptr_async_ehx                          (aw_wr_ptr_async_eh0),
    .aw_rd_ptr_async_ehx                          (aw_rd_ptr_async_eh0),
    .aw_payld_async_ehx                           (aw_payld_async_eh0),
    .w_wr_ptr_async_ehx                           (w_wr_ptr_async_eh0),
    .w_rd_ptr_async_ehx                           (w_rd_ptr_async_eh0),
    .w_payld_async_ehx                            (w_payld_async_eh0),
    .b_wr_ptr_async_ehx                           (b_wr_ptr_async_eh0),
    .b_rd_ptr_async_ehx                           (b_rd_ptr_async_eh0),
    .b_payld_async_ehx                            (b_payld_async_eh0),
    .ar_wr_ptr_async_ehx                          (ar_wr_ptr_async_eh0),
    .ar_rd_ptr_async_ehx                          (ar_rd_ptr_async_eh0),
    .ar_payld_async_ehx                           (ar_payld_async_eh0),
    .r_wr_ptr_async_ehx                           (r_wr_ptr_async_eh0),
    .r_rd_ptr_async_ehx                           (r_rd_ptr_async_eh0),
    .r_payld_async_ehx                            (r_payld_async_eh0),
    .psel_esh_mhu0                                (pselx_es0h_mhu0),
    .penable_esh_mhu0                             (penable_es0h_mhu0),
    .paddr_esh_mhu0                               (paddr_es0h_mhu0),
    .pwrite_esh_mhu0                              (pwrite_es0h_mhu0),
    .pwdata_esh_mhu0                              (pwdata_es0h_mhu0),
    .pstrb_esh_mhu0                               (pstrb_es0h_mhu0),
    .pprot_esh_mhu0                               (pprot_es0h_mhu0),
    .prdata_esh_mhu0                              (prdata_es0h_mhu0),
    .pready_esh_mhu0                              (pready_es0h_mhu0),
    .pslverr_esh_mhu0                             (pslverr_es0h_mhu0),
      .psel_esh_mhu1                                (pselx_es0h_mhu1),
    .penable_esh_mhu1                             (penable_es0h_mhu1),
    .paddr_esh_mhu1                               (paddr_es0h_mhu1),
    .pwrite_esh_mhu1                              (pwrite_es0h_mhu1),
    .pwdata_esh_mhu1                              (pwdata_es0h_mhu1),
    .pstrb_esh_mhu1                               (pstrb_es0h_mhu1),
    .pprot_esh_mhu1                               (pprot_es0h_mhu1),
    .prdata_esh_mhu1                              (prdata_es0h_mhu1),
    .pready_esh_mhu1                              (pready_es0h_mhu1),
    .pslverr_esh_mhu1                             (pslverr_es0h_mhu1),
      .psel_hes_mhu0                                (pselx_hes0_mhu0),
    .penable_hes_mhu0                             (penable_hes0_mhu0),
    .paddr_hes_mhu0                               (paddr_hes0_mhu0),
    .pwrite_hes_mhu0                              (pwrite_hes0_mhu0),
    .pwdata_hes_mhu0                              (pwdata_hes0_mhu0),
    .pstrb_hes_mhu0                               (pstrb_hes0_mhu0),
    .pprot_hes_mhu0                               (pprot_hes0_mhu0),
    .prdata_hes_mhu0                              (prdata_hes0_mhu0),
    .pready_hes_mhu0                              (pready_hes0_mhu0),
    .pslverr_hes_mhu0                             (pslverr_hes0_mhu0),
      .psel_hes_mhu1                                (pselx_hes0_mhu1),
    .penable_hes_mhu1                             (penable_hes0_mhu1),
    .paddr_hes_mhu1                               (paddr_hes0_mhu1),
    .pwrite_hes_mhu1                              (pwrite_hes0_mhu1),
    .pwdata_hes_mhu1                              (pwdata_hes0_mhu1),
    .pstrb_hes_mhu1                               (pstrb_hes0_mhu1),
    .pprot_hes_mhu1                               (pprot_hes0_mhu1),
    .prdata_hes_mhu1                              (prdata_hes0_mhu1),
    .pready_hes_mhu1                              (pready_hes0_mhu1),
    .pslverr_hes_mhu1                             (pslverr_hes0_mhu1),
      .hes_0_ehx_mhuint                             (hes_0_eh0_mhuint),
    .esh_0_ehx_mhuint                             (esh_0_eh0_mhuint),
      .hes_1_ehx_mhuint                             (hes_1_eh0_mhuint),
    .esh_1_ehx_mhuint                             (esh_1_eh0_mhuint),
      .apb_async_req_ehx_mhu_esh_0                  (apb_async_req_eh0_mhu_esh_0),
    .apb_async_req_payload_ehx_mhu_esh_0          (apb_async_req_payload_eh0_mhu_esh_0),
    .apb_async_resp_payload_ehx_mhu_esh_0         (apb_async_resp_payload_eh0_mhu_esh_0),
    .apb_async_ack_ehx_mhu_esh_0                  (apb_async_ack_eh0_mhu_esh_0),
    .recawake_async_ehx_mhu_esh_0                 (recawake_async_eh0_mhu_esh_0),
    .recwakeup_async_ehx_mhu_esh_0                (recwakeup_async_eh0_mhu_esh_0),
    .edge_async_req_ehx_mhu_esh_0                 (edge_async_req_eh0_mhu_esh_0),
    .edge_async_ack_ehx_mhu_esh_0                 (edge_async_ack_eh0_mhu_esh_0),
    .apb_async_req_ehx_mhu_hes_0                  (apb_async_req_eh0_mhu_hes_0),
    .apb_async_req_payload_ehx_mhu_hes_0          (apb_async_req_payload_eh0_mhu_hes_0),
    .apb_async_resp_payload_ehx_mhu_hes_0         (apb_async_resp_payload_eh0_mhu_hes_0),
    .apb_async_ack_ehx_mhu_hes_0                  (apb_async_ack_eh0_mhu_hes_0),
    .recawake_async_ehx_mhu_hes_0                 (recawake_async_eh0_mhu_hes_0),
    .recwakeup_async_ehx_mhu_hes_0                (recwakeup_async_eh0_mhu_hes_0),
    .edge_async_req_ehx_mhu_hes_0                 (edge_async_req_eh0_mhu_hes_0),
    .edge_async_ack_ehx_mhu_hes_0                 (edge_async_ack_eh0_mhu_hes_0),
      .apb_async_req_ehx_mhu_esh_1                  (apb_async_req_eh0_mhu_esh_1),
    .apb_async_req_payload_ehx_mhu_esh_1          (apb_async_req_payload_eh0_mhu_esh_1),
    .apb_async_resp_payload_ehx_mhu_esh_1         (apb_async_resp_payload_eh0_mhu_esh_1),
    .apb_async_ack_ehx_mhu_esh_1                  (apb_async_ack_eh0_mhu_esh_1),
    .recawake_async_ehx_mhu_esh_1                 (recawake_async_eh0_mhu_esh_1),
    .recwakeup_async_ehx_mhu_esh_1                (recwakeup_async_eh0_mhu_esh_1),
    .edge_async_req_ehx_mhu_esh_1                 (edge_async_req_eh0_mhu_esh_1),
    .edge_async_ack_ehx_mhu_esh_1                 (edge_async_ack_eh0_mhu_esh_1),
    .apb_async_req_ehx_mhu_hes_1                  (apb_async_req_eh0_mhu_hes_1),
    .apb_async_req_payload_ehx_mhu_hes_1          (apb_async_req_payload_eh0_mhu_hes_1),
    .apb_async_resp_payload_ehx_mhu_hes_1         (apb_async_resp_payload_eh0_mhu_hes_1),
    .apb_async_ack_ehx_mhu_hes_1                  (apb_async_ack_eh0_mhu_hes_1),
    .recawake_async_ehx_mhu_hes_1                 (recawake_async_eh0_mhu_hes_1),
    .recwakeup_async_ehx_mhu_hes_1                (recwakeup_async_eh0_mhu_hes_1),
    .edge_async_req_ehx_mhu_hes_1                 (edge_async_req_eh0_mhu_hes_1),
    .edge_async_ack_ehx_mhu_hes_1                 (edge_async_ack_eh0_mhu_hes_1),
      .qreqn_ehx_aclk                               (qch_exp_aclk_devqreqn[11]  ),
    .qacceptn_ehx_aclk                            (qch_exp_aclk_devqacceptn[11]),
    .qdeny_ehx_aclk                               (qch_exp_aclk_devqdeny[11]   ),
    .qactive_ehx_aclk                             (qch_exp_aclk_devqactive[11] ),
 

    .qreqn_esh_mhu0_pwr                           (qch_exp_systop_ingress_devqreqn[0]), 
    .qacceptn_esh_mhu0_pwr                        (qch_exp_systop_ingress_devqacceptn[0]),
    .qdeny_esh_mhu0_pwr                           (qch_exp_systop_ingress_devqdeny[0]),
  
      .qreqn_esh_mhu1_pwr                           (qch_exp_systop_ingress_devqreqn[1]),
    .qacceptn_esh_mhu1_pwr                        (qch_exp_systop_ingress_devqacceptn[1]),
    .qdeny_esh_mhu1_pwr                           (qch_exp_systop_ingress_devqdeny[1]),    
      .dftcgen                                      (dftcgen),
    .dftrstdisable                                (dftrstdisable[1])
  );  

assign qch_exp_systop_ingress_devqactive[0] = 1'b0; 
    assign qch_exp_systop_ingress_devqactive[1] = 1'b0; 
        pc_eh_f0_systop #(
    .EXT_SYSX_TZ_SPT              (EXT_SYS1_TZ_SPT),
    .MHU_HESX0_NUM_CH             (MHU_HES10_NUM_CH),
    .MHU_ESXH0_NUM_CH             (MHU_ES1H0_NUM_CH),
      .MHU_HESX1_NUM_CH             (MHU_HES11_NUM_CH),
    .MHU_ESXH1_NUM_CH             (MHU_ES1H1_NUM_CH),
      .EXT_SYS_NUM                  (8'h1),

    .EXT_SYSX_MEM_ADDR_WIDTH       (EXT_SYS1_MEM_ADDR_WIDTH),
    .EXT_SYSX_MEM_DATA_WIDTH       (EXT_SYS1_MEM_DATA_WIDTH),
    .EXT_SYSX_MEM_AWID_WIDTH       (EXT_SYS1_MEM_AWID_WIDTH),
    .EXT_SYSX_MEM_ARID_WIDTH       (EXT_SYS1_MEM_ARID_WIDTH),
    .EXT_SYSX_MEM_AWUSER_WIDTH     (EXT_SYS1_MEM_AWUSER_WIDTH),
    .EXT_SYSX_MEM_WUSER_WIDTH      (EXT_SYS1_MEM_WUSER_WIDTH),
    .EXT_SYSX_MEM_BUSER_WIDTH      (EXT_SYS1_MEM_BUSER_WIDTH),
    .EXT_SYSX_MEM_ARUSER_WIDTH     (EXT_SYS1_MEM_ARUSER_WIDTH),
    .EXT_SYSX_MEM_RUSER_WIDTH      (EXT_SYS1_MEM_RUSER_WIDTH),
    .EXT_SYSX_MEM_AW_FIFO_DEPTH    (EXT_SYS1_MEM_AW_FIFO_DEPTH),
    .EXT_SYSX_MEM_W_FIFO_DEPTH     (EXT_SYS1_MEM_W_FIFO_DEPTH),
    .EXT_SYSX_MEM_B_FIFO_DEPTH     (EXT_SYS1_MEM_B_FIFO_DEPTH),
    .EXT_SYSX_MEM_AR_FIFO_DEPTH    (EXT_SYS1_MEM_AR_FIFO_DEPTH),
    .EXT_SYSX_MEM_R_FIFO_DEPTH     (EXT_SYS1_MEM_R_FIFO_DEPTH),
    .EXT_SYSX_MEM_AW_PAYLOAD_WIDTH (EXT_SYS1_MEM_AW_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_W_PAYLOAD_WIDTH  (EXT_SYS1_MEM_W_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_B_PAYLOAD_WIDTH  (EXT_SYS1_MEM_B_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_AR_PAYLOAD_WIDTH (EXT_SYS1_MEM_AR_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_R_PAYLOAD_WIDTH  (EXT_SYS1_MEM_R_PAYLOAD_WIDTH)
  ) u_pc_eh1_f0_systop (
    .aclk                                         (aclk_gated),
    .systopwarmresetn                             (aresetn),
    .qactive_extsysx_mhupwrreq                    (qactive_extsys1_mhupwrreq),
    .awakeup_extsysx_axis                         (awakeup_extsys1_axis),
    .awid_extsysx_axis                            (awid_extsys1_axis),
    .awaddr_extsysx_axis                          (awaddr_extsys1_axis),
    .awregion_extsysx_axis                        (),
    .awlen_extsysx_axis                           (awlen_extsys1_axis),
    .awsize_extsysx_axis                          (awsize_extsys1_axis),
    .awburst_extsysx_axis                         (awburst_extsys1_axis),
    .awlock_extsysx_axis                          (awlock_extsys1_axis),
    .awcache_extsysx_axis                         (awcache_extsys1_axis),
    .awprot_extsysx_axis                          (awprot_extsys1_axis),
    .awvalid_extsysx_axis                         (awvalid_extsys1_axis),
    .awuser_extsysx_axis                          (awuser_extsys1_axis),
    .awready_extsysx_axis                         (awready_extsys1_axis),
    .wstrb_extsysx_axis                           (wstrb_extsys1_axis),
    .wlast_extsysx_axis                           (wlast_extsys1_axis),
    .wvalid_extsysx_axis                          (wvalid_extsys1_axis),
    .wdata_extsysx_axis                           (wdata_extsys1_axis),
    .wready_extsysx_axis                          (wready_extsys1_axis),
    .bid_extsysx_axis                             (bid_extsys1_axis),
    .bresp_extsysx_axis                           (bresp_extsys1_axis),
    .bvalid_extsysx_axis                          (bvalid_extsys1_axis),
    .bready_extsysx_axis                          (bready_extsys1_axis),
    .arid_extsysx_axis                            (arid_extsys1_axis),
    .araddr_extsysx_axis                          (araddr_extsys1_axis),
    .arregion_extsysx_axis                        (),
    .arlen_extsysx_axis                           (arlen_extsys1_axis),
    .arsize_extsysx_axis                          (arsize_extsys1_axis),
    .arburst_extsysx_axis                         (arburst_extsys1_axis),
    .arlock_extsysx_axis                          (arlock_extsys1_axis),
    .arcache_extsysx_axis                         (arcache_extsys1_axis),
    .arprot_extsysx_axis                          (arprot_extsys1_axis),
    .arvalid_extsysx_axis                         (arvalid_extsys1_axis),
    .aruser_extsysx_axis                          (aruser_extsys1_axis),
    .arready_extsysx_axis                         (arready_extsys1_axis),
    .rid_extsysx_axis                             (rid_extsys1_axis),
    .rresp_extsysx_axis                           (rresp_extsys1_axis),
    .rlast_extsysx_axis                           (rlast_extsys1_axis),
    .rvalid_extsysx_axis                          (rvalid_extsys1_axis),
    .rdata_extsysx_axis                           (rdata_extsys1_axis),
    .rready_extsysx_axis                          (rready_extsys1_axis),
    .slvmustacceptreqn_async_ehx                  (slvmustacceptreqn_async_eh1),
    .slvcandenyreqn_async_ehx                     (slvcandenyreqn_async_eh1),
    .slvacceptn_async_ehx                         (slvacceptn_async_eh1),
    .slvdeny_async_ehx                            (slvdeny_async_eh1),
    .si_to_mi_wakeup_async_ehx                    (si_to_mi_wakeup_async_eh1),
    .mi_to_si_wakeup_async_ehx                    (mi_to_si_wakeup_async_eh1),
    .aw_wr_ptr_async_ehx                          (aw_wr_ptr_async_eh1),
    .aw_rd_ptr_async_ehx                          (aw_rd_ptr_async_eh1),
    .aw_payld_async_ehx                           (aw_payld_async_eh1),
    .w_wr_ptr_async_ehx                           (w_wr_ptr_async_eh1),
    .w_rd_ptr_async_ehx                           (w_rd_ptr_async_eh1),
    .w_payld_async_ehx                            (w_payld_async_eh1),
    .b_wr_ptr_async_ehx                           (b_wr_ptr_async_eh1),
    .b_rd_ptr_async_ehx                           (b_rd_ptr_async_eh1),
    .b_payld_async_ehx                            (b_payld_async_eh1),
    .ar_wr_ptr_async_ehx                          (ar_wr_ptr_async_eh1),
    .ar_rd_ptr_async_ehx                          (ar_rd_ptr_async_eh1),
    .ar_payld_async_ehx                           (ar_payld_async_eh1),
    .r_wr_ptr_async_ehx                           (r_wr_ptr_async_eh1),
    .r_rd_ptr_async_ehx                           (r_rd_ptr_async_eh1),
    .r_payld_async_ehx                            (r_payld_async_eh1),
    .psel_esh_mhu0                                (pselx_es1h_mhu0),
    .penable_esh_mhu0                             (penable_es1h_mhu0),
    .paddr_esh_mhu0                               (paddr_es1h_mhu0),
    .pwrite_esh_mhu0                              (pwrite_es1h_mhu0),
    .pwdata_esh_mhu0                              (pwdata_es1h_mhu0),
    .pstrb_esh_mhu0                               (pstrb_es1h_mhu0),
    .pprot_esh_mhu0                               (pprot_es1h_mhu0),
    .prdata_esh_mhu0                              (prdata_es1h_mhu0),
    .pready_esh_mhu0                              (pready_es1h_mhu0),
    .pslverr_esh_mhu0                             (pslverr_es1h_mhu0),
      .psel_esh_mhu1                                (pselx_es1h_mhu1),
    .penable_esh_mhu1                             (penable_es1h_mhu1),
    .paddr_esh_mhu1                               (paddr_es1h_mhu1),
    .pwrite_esh_mhu1                              (pwrite_es1h_mhu1),
    .pwdata_esh_mhu1                              (pwdata_es1h_mhu1),
    .pstrb_esh_mhu1                               (pstrb_es1h_mhu1),
    .pprot_esh_mhu1                               (pprot_es1h_mhu1),
    .prdata_esh_mhu1                              (prdata_es1h_mhu1),
    .pready_esh_mhu1                              (pready_es1h_mhu1),
    .pslverr_esh_mhu1                             (pslverr_es1h_mhu1),
      .psel_hes_mhu0                                (pselx_hes1_mhu0),
    .penable_hes_mhu0                             (penable_hes1_mhu0),
    .paddr_hes_mhu0                               (paddr_hes1_mhu0),
    .pwrite_hes_mhu0                              (pwrite_hes1_mhu0),
    .pwdata_hes_mhu0                              (pwdata_hes1_mhu0),
    .pstrb_hes_mhu0                               (pstrb_hes1_mhu0),
    .pprot_hes_mhu0                               (pprot_hes1_mhu0),
    .prdata_hes_mhu0                              (prdata_hes1_mhu0),
    .pready_hes_mhu0                              (pready_hes1_mhu0),
    .pslverr_hes_mhu0                             (pslverr_hes1_mhu0),
      .psel_hes_mhu1                                (pselx_hes1_mhu1),
    .penable_hes_mhu1                             (penable_hes1_mhu1),
    .paddr_hes_mhu1                               (paddr_hes1_mhu1),
    .pwrite_hes_mhu1                              (pwrite_hes1_mhu1),
    .pwdata_hes_mhu1                              (pwdata_hes1_mhu1),
    .pstrb_hes_mhu1                               (pstrb_hes1_mhu1),
    .pprot_hes_mhu1                               (pprot_hes1_mhu1),
    .prdata_hes_mhu1                              (prdata_hes1_mhu1),
    .pready_hes_mhu1                              (pready_hes1_mhu1),
    .pslverr_hes_mhu1                             (pslverr_hes1_mhu1),
      .hes_0_ehx_mhuint                             (hes_0_eh1_mhuint),
    .esh_0_ehx_mhuint                             (esh_0_eh1_mhuint),
      .hes_1_ehx_mhuint                             (hes_1_eh1_mhuint),
    .esh_1_ehx_mhuint                             (esh_1_eh1_mhuint),
      .apb_async_req_ehx_mhu_esh_0                  (apb_async_req_eh1_mhu_esh_0),
    .apb_async_req_payload_ehx_mhu_esh_0          (apb_async_req_payload_eh1_mhu_esh_0),
    .apb_async_resp_payload_ehx_mhu_esh_0         (apb_async_resp_payload_eh1_mhu_esh_0),
    .apb_async_ack_ehx_mhu_esh_0                  (apb_async_ack_eh1_mhu_esh_0),
    .recawake_async_ehx_mhu_esh_0                 (recawake_async_eh1_mhu_esh_0),
    .recwakeup_async_ehx_mhu_esh_0                (recwakeup_async_eh1_mhu_esh_0),
    .edge_async_req_ehx_mhu_esh_0                 (edge_async_req_eh1_mhu_esh_0),
    .edge_async_ack_ehx_mhu_esh_0                 (edge_async_ack_eh1_mhu_esh_0),
    .apb_async_req_ehx_mhu_hes_0                  (apb_async_req_eh1_mhu_hes_0),
    .apb_async_req_payload_ehx_mhu_hes_0          (apb_async_req_payload_eh1_mhu_hes_0),
    .apb_async_resp_payload_ehx_mhu_hes_0         (apb_async_resp_payload_eh1_mhu_hes_0),
    .apb_async_ack_ehx_mhu_hes_0                  (apb_async_ack_eh1_mhu_hes_0),
    .recawake_async_ehx_mhu_hes_0                 (recawake_async_eh1_mhu_hes_0),
    .recwakeup_async_ehx_mhu_hes_0                (recwakeup_async_eh1_mhu_hes_0),
    .edge_async_req_ehx_mhu_hes_0                 (edge_async_req_eh1_mhu_hes_0),
    .edge_async_ack_ehx_mhu_hes_0                 (edge_async_ack_eh1_mhu_hes_0),
      .apb_async_req_ehx_mhu_esh_1                  (apb_async_req_eh1_mhu_esh_1),
    .apb_async_req_payload_ehx_mhu_esh_1          (apb_async_req_payload_eh1_mhu_esh_1),
    .apb_async_resp_payload_ehx_mhu_esh_1         (apb_async_resp_payload_eh1_mhu_esh_1),
    .apb_async_ack_ehx_mhu_esh_1                  (apb_async_ack_eh1_mhu_esh_1),
    .recawake_async_ehx_mhu_esh_1                 (recawake_async_eh1_mhu_esh_1),
    .recwakeup_async_ehx_mhu_esh_1                (recwakeup_async_eh1_mhu_esh_1),
    .edge_async_req_ehx_mhu_esh_1                 (edge_async_req_eh1_mhu_esh_1),
    .edge_async_ack_ehx_mhu_esh_1                 (edge_async_ack_eh1_mhu_esh_1),
    .apb_async_req_ehx_mhu_hes_1                  (apb_async_req_eh1_mhu_hes_1),
    .apb_async_req_payload_ehx_mhu_hes_1          (apb_async_req_payload_eh1_mhu_hes_1),
    .apb_async_resp_payload_ehx_mhu_hes_1         (apb_async_resp_payload_eh1_mhu_hes_1),
    .apb_async_ack_ehx_mhu_hes_1                  (apb_async_ack_eh1_mhu_hes_1),
    .recawake_async_ehx_mhu_hes_1                 (recawake_async_eh1_mhu_hes_1),
    .recwakeup_async_ehx_mhu_hes_1                (recwakeup_async_eh1_mhu_hes_1),
    .edge_async_req_ehx_mhu_hes_1                 (edge_async_req_eh1_mhu_hes_1),
    .edge_async_ack_ehx_mhu_hes_1                 (edge_async_ack_eh1_mhu_hes_1),
      .qreqn_ehx_aclk                               (qch_exp_aclk_devqreqn[12]  ),
    .qacceptn_ehx_aclk                            (qch_exp_aclk_devqacceptn[12]),
    .qdeny_ehx_aclk                               (qch_exp_aclk_devqdeny[12]   ),
    .qactive_ehx_aclk                             (qch_exp_aclk_devqactive[12] ),
 

    .qreqn_esh_mhu0_pwr                           (qch_exp_systop_ingress_devqreqn[2]), 
    .qacceptn_esh_mhu0_pwr                        (qch_exp_systop_ingress_devqacceptn[2]),
    .qdeny_esh_mhu0_pwr                           (qch_exp_systop_ingress_devqdeny[2]),
  
      .qreqn_esh_mhu1_pwr                           (qch_exp_systop_ingress_devqreqn[3]),
    .qacceptn_esh_mhu1_pwr                        (qch_exp_systop_ingress_devqacceptn[3]),
    .qdeny_esh_mhu1_pwr                           (qch_exp_systop_ingress_devqdeny[3]),    
      .dftcgen                                      (dftcgen),
    .dftrstdisable                                (dftrstdisable[1])
  );  

assign qch_exp_systop_ingress_devqactive[2] = 1'b0; 
    assign qch_exp_systop_ingress_devqactive[3] = 1'b0; 
        
  pc_secenc_f0_systop #(
  .MHU_HSE0_NUM_CH         (MHU_HSE0_NUM_CH),
  .MHU_SEH0_NUM_CH         (MHU_SEH0_NUM_CH),
  .MHU_HSE1_NUM_CH         (MHU_HSE1_NUM_CH),
  .MHU_SEH1_NUM_CH         (MHU_SEH1_NUM_CH),
  
  .SECENC_ADDR_WIDTH       (SECENC_ADDR_WIDTH),
  .SECENC_DATA_WIDTH       (SECENC_DATA_WIDTH),
  .SECENC_AWID_WIDTH       (SECENC_AWID_WIDTH),
  .SECENC_ARID_WIDTH       (SECENC_ARID_WIDTH),
  .SECENC_AWUSER_WIDTH     (SECENC_AWUSER_WIDTH),
  .SECENC_WUSER_WIDTH      (SECENC_WUSER_WIDTH),
  .SECENC_BUSER_WIDTH      (SECENC_BUSER_WIDTH),
  .SECENC_ARUSER_WIDTH     (SECENC_ARUSER_WIDTH),
  .SECENC_RUSER_WIDTH      (SECENC_RUSER_WIDTH),
  .SECENC_AW_FIFO_DEPTH    (SECENC_AW_FIFO_DEPTH),
  .SECENC_W_FIFO_DEPTH     (SECENC_W_FIFO_DEPTH),
  .SECENC_B_FIFO_DEPTH     (SECENC_B_FIFO_DEPTH),
  .SECENC_AR_FIFO_DEPTH    (SECENC_AR_FIFO_DEPTH),
  .SECENC_R_FIFO_DEPTH     (SECENC_R_FIFO_DEPTH),
  .SECENC_AW_PAYLOAD_WIDTH (SECENC_AW_PAYLOAD_WIDTH),
  .SECENC_W_PAYLOAD_WIDTH  (SECENC_W_PAYLOAD_WIDTH),
  .SECENC_B_PAYLOAD_WIDTH  (SECENC_B_PAYLOAD_WIDTH),
  .SECENC_AR_PAYLOAD_WIDTH (SECENC_AR_PAYLOAD_WIDTH),
  .SECENC_R_PAYLOAD_WIDTH  (SECENC_R_PAYLOAD_WIDTH) 
  
  ) u_pc_secenc_f0_systop (
    .aclk                                    (aclk_gated),
    .systopwarmresetn                        (aresetn),

    .awakeup_secenc_axis                     (),
    .awid_secenc_axis                        (awid_secenc_axis),
    .awaddr_secenc_axis                      (awaddr_secenc_axis[31:0]),
    .awregion_secenc_axis                    (),
    .awlen_secenc_axis                       (awlen_secenc_axis),
    .awsize_secenc_axis                      (awsize_secenc_axis),
    .awburst_secenc_axis                     (awburst_secenc_axis),
    .awlock_secenc_axis                      (awlock_secenc_axis),
    .awcache_secenc_axis                     (awcache_secenc_axis),
    .awprot_secenc_axis                      (awprot_secenc_axis),
    .awvalid_secenc_axis                     (awvalid_secenc_axis),
    .awuser_secenc_axis                      (awuser_secenc_axis),
    .awqos_secenc_axis                       (),
    .awready_secenc_axis                     (awready_secenc_axis),
    .wstrb_secenc_axis                       (wstrb_secenc_axis),
    .wlast_secenc_axis                       (wlast_secenc_axis),
    .wvalid_secenc_axis                      (wvalid_secenc_axis),
    .wdata_secenc_axis                       (wdata_secenc_axis),
    .wready_secenc_axis                      (wready_secenc_axis),
    .bid_secenc_axis                         (bid_secenc_axis),
    .bresp_secenc_axis                       (bresp_secenc_axis),
    .bvalid_secenc_axis                      (bvalid_secenc_axis),
    .bready_secenc_axis                      (bready_secenc_axis),
    .buser_secenc_axis                       (buser_secenc_axis),
    .arid_secenc_axis                        (arid_secenc_axis),
    .araddr_secenc_axis                      (araddr_secenc_axis[31:0]),
    .arregion_secenc_axis                    (),
    .arlen_secenc_axis                       (arlen_secenc_axis),
    .arsize_secenc_axis                      (arsize_secenc_axis),
    .arburst_secenc_axis                     (arburst_secenc_axis),
    .arlock_secenc_axis                      (arlock_secenc_axis),
    .arcache_secenc_axis                     (arcache_secenc_axis),
    .arprot_secenc_axis                      (arprot_secenc_axis),
    .arvalid_secenc_axis                     (arvalid_secenc_axis),
    .aruser_secenc_axis                      (aruser_secenc_axis),
    .arqos_secenc_axis                       (),
    .arready_secenc_axis                     (arready_secenc_axis),
    .rid_secenc_axis                         (rid_secenc_axis),
    .rresp_secenc_axis                       (rresp_secenc_axis),
    .rlast_secenc_axis                       (rlast_secenc_axis),
    .rvalid_secenc_axis                      (rvalid_secenc_axis),
    .rdata_secenc_axis                       (rdata_secenc_axis),
    .rready_secenc_axis                      (rready_secenc_axis),
    .ruser_secenc_axis                       (ruser_secenc_axis),
    
    .slvmustacceptreqn_async_secenc          (slvmustacceptreqn_async_secenc),
    .slvcandenyreqn_async_secenc             (slvcandenyreqn_async_secenc),
    .slvacceptn_async_secenc                 (slvacceptn_async_secenc),
    .slvdeny_async_secenc                    (slvdeny_async_secenc),
    .si_to_mi_wakeup_async_secenc            (si_to_mi_wakeup_async_secenc),
    .mi_to_si_wakeup_async_secenc            (mi_to_si_wakeup_async_secenc),
    .aw_wr_ptr_async_secenc                  (aw_wr_ptr_async_secenc),
    .aw_rd_ptr_async_secenc                  (aw_rd_ptr_async_secenc),
    .aw_payld_async_secenc                   (aw_payld_async_secenc),
    .w_wr_ptr_async_secenc                   (w_wr_ptr_async_secenc),
    .w_rd_ptr_async_secenc                   (w_rd_ptr_async_secenc),
    .w_payld_async_secenc                    (w_payld_async_secenc),
    .b_wr_ptr_async_secenc                   (b_wr_ptr_async_secenc),
    .b_rd_ptr_async_secenc                   (b_rd_ptr_async_secenc),
    .b_payld_async_secenc                    (b_payld_async_secenc),
    .ar_wr_ptr_async_secenc                  (ar_wr_ptr_async_secenc),
    .ar_rd_ptr_async_secenc                  (ar_rd_ptr_async_secenc),
    .ar_payld_async_secenc                   (ar_payld_async_secenc),
    .r_wr_ptr_async_secenc                   (r_wr_ptr_async_secenc),
    .r_rd_ptr_async_secenc                   (r_rd_ptr_async_secenc),
    .r_payld_async_secenc                    (r_payld_async_secenc),

    .psel_hse0_mhu_apb                       (pselx_hse_mhu0),
    .penable_hse0_mhu_apb                    (penable_hse_mhu0),
    .paddr_hse0_mhu_apb                      (paddr_hse_mhu0),
    .pwrite_hse0_mhu_apb                     (pwrite_hse_mhu0),
    .pwdata_hse0_mhu_apb                     (pwdata_hse_mhu0),
    .pstrb_hse0_mhu_apb                      (pstrb_hse_mhu0),
    .pprot_hse0_mhu_apb                      (pprot_hse_mhu0),
    .prdata_hse0_mhu_apb                     (prdata_hse_mhu0),
    .pready_hse0_mhu_apb                     (pready_hse_mhu0),
    .pslverr_hse0_mhu_apb                    (pslverr_hse_mhu0),

    .psel_seh0_mhu_apb                       (pselx_seh_mhu0),
    .penable_seh0_mhu_apb                    (penable_seh_mhu0),
    .paddr_seh0_mhu_apb                      (paddr_seh_mhu0),
    .pwrite_seh0_mhu_apb                     (pwrite_seh_mhu0),
    .pwdata_seh0_mhu_apb                     (pwdata_seh_mhu0),
    .pstrb_seh0_mhu_apb                      (pstrb_seh_mhu0),
    .pprot_seh0_mhu_apb                      (pprot_seh_mhu0),
    .prdata_seh0_mhu_apb                     (prdata_seh_mhu0),
    .pready_seh0_mhu_apb                     (pready_seh_mhu0),
    .pslverr_seh0_mhu_apb                    (pslverr_seh_mhu0),

    .psel_hse1_mhu_apb                       (pselx_hse_mhu1),
    .penable_hse1_mhu_apb                    (penable_hse_mhu1),
    .paddr_hse1_mhu_apb                      (paddr_hse_mhu1),
    .pwrite_hse1_mhu_apb                     (pwrite_hse_mhu1),
    .pwdata_hse1_mhu_apb                     (pwdata_hse_mhu1),
    .pstrb_hse1_mhu_apb                      (pstrb_hse_mhu1),
    .pprot_hse1_mhu_apb                      (pprot_hse_mhu1),
    .prdata_hse1_mhu_apb                     (prdata_hse_mhu1),
    .pready_hse1_mhu_apb                     (pready_hse_mhu1),
    .pslverr_hse1_mhu_apb                    (pslverr_hse_mhu1),

    .psel_seh1_mhu_apb                       (pselx_seh_mhu1),
    .penable_seh1_mhu_apb                    (penable_seh_mhu1),
    .paddr_seh1_mhu_apb                      (paddr_seh_mhu1),
    .pwrite_seh1_mhu_apb                     (pwrite_seh_mhu1),
    .pwdata_seh1_mhu_apb                     (pwdata_seh_mhu1),
    .pstrb_seh1_mhu_apb                      (pstrb_seh_mhu1),
    .pprot_seh1_mhu_apb                      (pprot_seh_mhu1),
    .prdata_seh1_mhu_apb                     (prdata_seh_mhu1),
    .pready_seh1_mhu_apb                     (pready_seh_mhu1),
    .pslverr_seh1_mhu_apb                    (pslverr_seh_mhu1),

    .hse0_mhuint                             (hse0_mhuint),
    .seh0_mhuint                             (seh0_mhuint),
    .hse1_mhuint                             (hse1_mhuint),
    .seh1_mhuint                             (seh1_mhuint),

    .apb_async_req_seh0_mhu                  (apb_async_req_seh0_mhu),
    .apb_async_req_payload_seh0_mhu          (apb_async_req_payload_seh0_mhu),
    .apb_async_resp_payload_seh0_mhu         (apb_async_resp_payload_seh0_mhu),
    .apb_async_ack_seh0_mhu                  (apb_async_ack_seh0_mhu),
    .recawake_async_seh0_mhu                 (recawake_async_seh0_mhu),
    .recwakeup_async_seh0_mhu                (recwakeup_async_seh0_mhu),
    .edge_async_req_seh0_mhu                 (edge_async_req_seh0_mhu),
    .edge_async_ack_seh0_mhu                 (edge_async_ack_seh0_mhu),

    .apb_async_req_hse0_mhu                  (apb_async_req_hse0_mhu),
    .apb_async_req_payload_hse0_mhu          (apb_async_req_payload_hse0_mhu),
    .apb_async_resp_payload_hse0_mhu         (apb_async_resp_payload_hse0_mhu),
    .apb_async_ack_hse0_mhu                  (apb_async_ack_hse0_mhu),
    .recawake_async_hse0_mhu                 (recawake_async_hse0_mhu),
    .recwakeup_async_hse0_mhu                (recwakeup_async_hse0_mhu),
    .edge_async_req_hse0_mhu                 (edge_async_req_hse0_mhu),
    .edge_async_ack_hse0_mhu                 (edge_async_ack_hse0_mhu),

    .apb_async_req_seh1_mhu                  (apb_async_req_seh1_mhu),
    .apb_async_req_payload_seh1_mhu          (apb_async_req_payload_seh1_mhu),
    .apb_async_resp_payload_seh1_mhu         (apb_async_resp_payload_seh1_mhu),
    .apb_async_ack_seh1_mhu                  (apb_async_ack_seh1_mhu),
    .recawake_async_seh1_mhu                 (recawake_async_seh1_mhu),
    .recwakeup_async_seh1_mhu                (recwakeup_async_seh1_mhu),
    .edge_async_req_seh1_mhu                 (edge_async_req_seh1_mhu),
    .edge_async_ack_seh1_mhu                 (edge_async_ack_seh1_mhu),

    .apb_async_req_hse1_mhu                  (apb_async_req_hse1_mhu),
    .apb_async_req_payload_hse1_mhu          (apb_async_req_payload_hse1_mhu),
    .apb_async_resp_payload_hse1_mhu         (apb_async_resp_payload_hse1_mhu),
    .apb_async_ack_hse1_mhu                  (apb_async_ack_hse1_mhu),
    .recawake_async_hse1_mhu                 (recawake_async_hse1_mhu),
    .recwakeup_async_hse1_mhu                (recwakeup_async_hse1_mhu),
    .edge_async_req_hse1_mhu                 (edge_async_req_hse1_mhu),
    .edge_async_ack_hse1_mhu                 (edge_async_ack_hse1_mhu),

    .qreqn_se_aclk                           (qch_exp_aclk_devqreqn[13]   ),
    .qacceptn_se_aclk                        (qch_exp_aclk_devqacceptn[13]),
    .qdeny_se_aclk                           (qch_exp_aclk_devqdeny[13]   ),
    .qactive_se_aclk                         (qch_exp_aclk_devqactive[13] ),
 

    .qreqn_seh0_mhu_pwr                      (qch_exp_systop_ingress_devqreqn[4]),
    .qacceptn_seh0_mhu_pwr                   (qch_exp_systop_ingress_devqacceptn[4]),
    .qdeny_seh0_mhu_pwr                      (qch_exp_systop_ingress_devqdeny[4]),

    .qreqn_seh1_mhu_pwr                      (qch_exp_systop_ingress_devqreqn[5]),
    .qacceptn_seh1_mhu_pwr                   (qch_exp_systop_ingress_devqacceptn[5]),
    .qdeny_seh1_mhu_pwr                      (qch_exp_systop_ingress_devqdeny[5]),    

    .dftcgen                                 (dftcgen),
    .dftrstdisable                           (dftrstdisable[1])
  );  

assign qch_exp_systop_ingress_devqactive[4] = 1'b0; 
assign qch_exp_systop_ingress_devqactive[5] = 1'b0; 

  assign awaddr_secenc_axis[39:32] = 8'h00;
  assign araddr_secenc_axis[39:32] = 8'h00;


  pc_debug_aon_f0_systop u_pc_debug_aon_f0_systop (
  
    .aclk    (aclk_gated),
    .aresetn (aresetn),
        
    .extdbg_async_req           (extdbg_async_req),
    .extdbg_async_req_payload   (extdbg_async_req_payload ),
    .extdbg_async_resp_payload  (extdbg_async_resp_payload),
    .extdbg_async_ack           (extdbg_async_ack),
        
    .paddr_extdbg               (paddr_extdbg_apb),
    .pwdata_extdbg              (pwdata_extdbg_apb),
    .pwrite_extdbg              (pwrite_extdbg_apb),
    .pprot_extdbg               (pprot_extdbg_apb),
    .pstrb_extdbg               (pstrb_extdbg_apb),
    .penable_extdbg             (penable_extdbg_apb),
    .psel_extdbg                (pselx_extdbg_apb),
    .prdata_extdbg              (prdata_extdbg_apb),
    .pslverr_extdbg             (pslverr_extdbg_apb),
    .pready_extdbg              (pready_extdbg_apb),      

    .paddr_sdc600               (paddr_sdc600_apb  ),
    .psel_sdc600                (pselx_sdc600_apb  ),
    .penable_sdc600             (penable_sdc600_apb),
    .pwrite_sdc600              (pwrite_sdc600_apb ),
    .prdata_sdc600              (prdata_sdc600_apb ),
    .pwdata_sdc600              (pwdata_sdc600_apb ),
    .pprot_sdc600               (pprot_sdc600_apb  ),
    .pstrb_sdc600               (pstrb_sdc600_apb  ),
    .pready_sdc600              (pready_sdc600_apb ),
    .pslverr_sdc600             (pslverr_sdc600_apb),
    
    .irq_sdc600                 (irq_sdc600),
     
    .ie_data_sdc600             (ie_data_sdc600   ),
    .ie_req_sdc600              (ie_req_sdc600    ),
    .ie_ack_sdc600              (ie_ack_sdc600    ),
    .ie_linkup_sdc600           (ie_linkup_sdc600 ),
    .ie_linkest_sdc600          (ie_linkest_sdc600),
    .ei_data_sdc600             (ei_data_sdc600   ),
    .ei_req_sdc600              (ei_req_sdc600    ),
    .ei_ack_sdc600              (ei_ack_sdc600    ),
    .ei_linkup_sdc600           (ei_linkup_sdc600 ),
    .ei_linkest_sdc600          (ei_linkest_sdc600),
     
    .aclk_qreqn    ({qch_exp_aclk_devqreqn[16],
                     qch_exp_aclk_devqreqn[15],
                     qch_exp_aclk_devqreqn[14]}),
    .aclk_qacceptn ({qch_exp_aclk_devqacceptn[16],
                     qch_exp_aclk_devqacceptn[15],
                     qch_exp_aclk_devqacceptn[14]}),
    .aclk_qdeny    ({qch_exp_aclk_devqdeny[16],
                     qch_exp_aclk_devqdeny[15],
                     qch_exp_aclk_devqdeny[14]}),
    .aclk_qactive  ({qch_exp_aclk_devqactive[16],
                     qch_exp_aclk_devqactive[15],
                     qch_exp_aclk_devqactive[14]}),
 
 
 
    
    .pwrqreqn      (qch_exp_systop_egress_devqreqn[5]   ),
    .pwrqacceptn   (qch_exp_systop_egress_devqacceptn[5]),
    .pwrqdeny      (qch_exp_systop_egress_devqdeny[5]),
    .pwrqactive    (qch_exp_systop_egress_devqactive[5]),
    
    .pwr_toaon_qreqn      (systop_egress_dbgaon_comb_pwrqreqn   ),
    .pwr_toaon_qacceptn   (systop_egress_dbgaon_comb_pwrqacceptn),
    .pwr_toaon_qdeny      (systop_egress_dbgaon_comb_pwrqdeny   ),
    .pwr_toaon_qactive    (systop_egress_dbgaon_comb_pwrqactive ),
    
    .dftcgen       (dftcgen)
  );

  
assign systop_egress_dbgaon_comb1_pwrqreqn    = qch_exp_systop_egress_devqreqn[6];  
assign qch_exp_systop_egress_devqacceptn[6] = systop_egress_dbgaon_comb1_pwrqacceptn ;
assign qch_exp_systop_egress_devqdeny[6]    = systop_egress_dbgaon_comb1_pwrqdeny    ;
assign qch_exp_systop_egress_devqactive[6]  = systop_egress_dbgaon_comb1_pwrqactive  ;




  pc_debug_f0_systop  #(
    .SYS_EGRESS_2_DBG     (SYS_EGRESS_2_DBG     ),
    .DBG_ADDR_WIDTH       (DBG_ADDR_WIDTH       ),
    .DBG_DATA_WIDTH       (DBG_DATA_WIDTH       ),
    .DBG_AWID_WIDTH       (DBG_AWID_WIDTH       ),
    .DBG_ARID_WIDTH       (DBG_ARID_WIDTH       ),
    .DBG_AWUSER_WIDTH     (DBG_AWUSER_WIDTH     ),
    .DBG_WUSER_WIDTH      (DBG_WUSER_WIDTH      ),
    .DBG_BUSER_WIDTH      (DBG_BUSER_WIDTH      ),
    .DBG_ARUSER_WIDTH     (DBG_ARUSER_WIDTH     ),
    .DBG_RUSER_WIDTH      (DBG_RUSER_WIDTH      ),
    .DBG_AW_FIFO_DEPTH    (DBG_AW_FIFO_DEPTH    ),
    .DBG_W_FIFO_DEPTH     (DBG_W_FIFO_DEPTH     ),
    .DBG_B_FIFO_DEPTH     (DBG_B_FIFO_DEPTH     ),
    .DBG_AR_FIFO_DEPTH    (DBG_AR_FIFO_DEPTH    ),
    .DBG_R_FIFO_DEPTH     (DBG_R_FIFO_DEPTH     ),
    .DBG_AW_PAYLOAD_WIDTH (DBG_AW_PAYLOAD_WIDTH ),
    .DBG_W_PAYLOAD_WIDTH  (DBG_W_PAYLOAD_WIDTH  ),
    .DBG_B_PAYLOAD_WIDTH  (DBG_B_PAYLOAD_WIDTH  ),
    .DBG_AR_PAYLOAD_WIDTH (DBG_AR_PAYLOAD_WIDTH ),
    .DBG_R_PAYLOAD_WIDTH  (DBG_R_PAYLOAD_WIDTH  ),
    .STM_ADDR_WIDTH       (STM_ADDR_WIDTH       ),
    .STM_DATA_WIDTH       (STM_DATA_WIDTH       ),
    .STM_WUSER_WIDTH      (STM_WUSER_WIDTH      ),
    .STM_BUSER_WIDTH      (STM_BUSER_WIDTH      ),
    .STM_ARUSER_WIDTH     (STM_ARUSER_WIDTH     ),
    .STM_RUSER_WIDTH      (STM_RUSER_WIDTH      ),
    .STM_AW_PAYLOAD_WIDTH (STM_AW_PAYLOAD_WIDTH ),
    .STM_W_PAYLOAD_WIDTH  (STM_W_PAYLOAD_WIDTH  ),
    .STM_B_PAYLOAD_WIDTH  (STM_B_PAYLOAD_WIDTH  ),
    .STM_AR_PAYLOAD_WIDTH (STM_AR_PAYLOAD_WIDTH ),
    .STM_R_PAYLOAD_WIDTH  (STM_R_PAYLOAD_WIDTH  ),
    .STM_AXI_ID_WIDTH     (STM_AXI_ID_WIDTH     ),
    .STM_AW_FIFO_DEPTH    (STM_AW_FIFO_DEPTH    ),
    .STM_W_FIFO_DEPTH     (STM_W_FIFO_DEPTH     ),
    .STM_B_FIFO_DEPTH     (STM_B_FIFO_DEPTH     ),
    .STM_AR_FIFO_DEPTH    (STM_AR_FIFO_DEPTH    ),
    .STM_R_FIFO_DEPTH     (STM_R_FIFO_DEPTH     ),
    .STM_AWUSER_WIDTH     (STM_AWUSER_WIDTH     )    
    
  )
    u_pc_debug_f0_systop
  (
     .aclk                          (aclk_gated    ),
     .aresetn                       (aresetn ),
     
    .aclk_qreqn    ({                     
                     qch_exp_aclk_devqreqn[21],
                     qch_exp_aclk_devqreqn[20],
                     qch_exp_aclk_devqreqn[19],
                     qch_exp_aclk_devqreqn[18],
                     qch_exp_aclk_devqreqn[17]}),
    .aclk_qacceptn ({                     
                     qch_exp_aclk_devqacceptn[21],
                     qch_exp_aclk_devqacceptn[20],                     
                     qch_exp_aclk_devqacceptn[19],
                     qch_exp_aclk_devqacceptn[18],
                     qch_exp_aclk_devqacceptn[17]}),
    .aclk_qdeny    ({                     
                     qch_exp_aclk_devqdeny[21],    
                     qch_exp_aclk_devqdeny[20],                     
                     qch_exp_aclk_devqdeny[19],
                     qch_exp_aclk_devqdeny[18],
                     qch_exp_aclk_devqdeny[17]}),
    .aclk_qactive  ({                     
                     qch_exp_aclk_devqactive[21],
                     qch_exp_aclk_devqactive[20],
                     qch_exp_aclk_devqactive[19],
                     qch_exp_aclk_devqactive[18],
                     qch_exp_aclk_devqactive[17]}),
                     
    
 
 
 
 
 

     .debug_axis_wakeupm_o          (), 
     

     .qreqn_systop_egress_dbgtop    (qreqn_systop_egress_dbgtop   [SYS_EGRESS_2_DBG-1:0]),        
     .qacceptn_systop_egress_dbgtop (qacceptn_systop_egress_dbgtop[SYS_EGRESS_2_DBG-1:0]),        
     .qdeny_systop_egress_dbgtop    (qdeny_systop_egress_dbgtop   [SYS_EGRESS_2_DBG-1:0]),        
     .qactive_systop_egress_dbgtop  (qactive_systop_egress_dbgtop [SYS_EGRESS_2_DBG-1:0]),        
                                            
     .paddr_hostsysdbg_apb          (paddr_hostsysdbg_apb         ),
     .pselx_hostsysdbg_apb          (pselx_hostsysdbg_apb         ),
     .penable_hostsysdbg_apb        (penable_hostsysdbg_apb       ),
     .pwrite_hostsysdbg_apb         (pwrite_hostsysdbg_apb        ),
     .prdata_hostsysdbg_apb         (prdata_hostsysdbg_apb        ),
     .pwdata_hostsysdbg_apb         (pwdata_hostsysdbg_apb        ),
     .pprot_hostsysdbg_apb          (pprot_hostsysdbg_apb         ),
     .pstrb_hostsysdbg_apb          (pstrb_hostsysdbg_apb         ),
     .pready_hostsysdbg_apb         (pready_hostsysdbg_apb        ),
     .pslverr_hostsysdbg_apb        (pslverr_hostsysdbg_apb       ),
     .hostsysdbg_async_req          (hostsysdbg_async_req         ),
     .hostsysdbg_async_req_payload  (hostsysdbg_async_req_payload ),
     .hostsysdbg_async_resp_payload (hostsysdbg_async_resp_payload),
     .hostsysdbg_async_ack          (hostsysdbg_async_ack         ),
   
     .awid_stm_axim                 (awid_stm_axim   ),
     .awaddr_stm_axim               (awaddr_stm_axim ),
     .awlen_stm_axim                (awlen_stm_axim  ),
     .awsize_stm_axim               (awsize_stm_axim ),
     .awburst_stm_axim              (awburst_stm_axim),
     .awlock_stm_axim               (awlock_stm_axim ),
     .awcache_stm_axim              (awcache_stm_axim),
     .awprot_stm_axim               (awprot_stm_axim ),
     .awvalid_stm_axim              (awvalid_stm_axim),
     .awready_stm_axim              (awready_stm_axim),
     .wdata_stm_axim                (wdata_stm_axim  ),
     .wstrb_stm_axim                (wstrb_stm_axim  ),
     .wlast_stm_axim                (wlast_stm_axim  ),
     .wvalid_stm_axim               (wvalid_stm_axim ),
     .wready_stm_axim               (wready_stm_axim ),
     .bid_stm_axim                  (bid_stm_axim    ),
     .bresp_stm_axim                (bresp_stm_axim  ),
     .bvalid_stm_axim               (bvalid_stm_axim ),
     .bready_stm_axim               (bready_stm_axim ),
     .arid_stm_axim                 (arid_stm_axim   ),
     .araddr_stm_axim               (araddr_stm_axim ),
     .arlen_stm_axim                (arlen_stm_axim  ),
     .arsize_stm_axim               (arsize_stm_axim ),
     .arburst_stm_axim              (arburst_stm_axim),
     .arlock_stm_axim               (arlock_stm_axim ),
     .arcache_stm_axim              (arcache_stm_axim),
     .arprot_stm_axim               (arprot_stm_axim ),
     .arvalid_stm_axim              (arvalid_stm_axim),
     .arready_stm_axim              (arready_stm_axim),
     .rid_stm_axim                  (rid_stm_axim    ),
     .rdata_stm_axim                (rdata_stm_axim  ),
     .rresp_stm_axim                (rresp_stm_axim  ),
     .rlast_stm_axim                (rlast_stm_axim  ),
     .rvalid_stm_axim               (rvalid_stm_axim ),
     .rready_stm_axim               (rready_stm_axim ),
     .awuser_stm_axim               (awuser_stm_axim), 
     .aruser_stm_axim               (aruser_stm_axim),
     
     
     .awid_debug_axis               (awid_debug_axis   ),
     .awaddr_debug_axis             (awaddr_debug_axis ),
     .awlen_debug_axis              (awlen_debug_axis  ),
     .awsize_debug_axis             (awsize_debug_axis ),
     .awburst_debug_axis            (awburst_debug_axis),
     .awlock_debug_axis             (awlock_debug_axis ),
     .awcache_debug_axis            (awcache_debug_axis),
     .awprot_debug_axis             (awprot_debug_axis ),
     .awvalid_debug_axis            (awvalid_debug_axis),
     .awready_debug_axis            (awready_debug_axis),
     .wdata_debug_axis              (wdata_debug_axis  ),
     .wstrb_debug_axis              (wstrb_debug_axis  ),
     .wlast_debug_axis              (wlast_debug_axis  ),
     .wvalid_debug_axis             (wvalid_debug_axis ),
     .wready_debug_axis             (wready_debug_axis ),
     .bid_debug_axis                (bid_debug_axis    ),
     .bresp_debug_axis              (bresp_debug_axis  ),
     .bvalid_debug_axis             (bvalid_debug_axis ),
     .bready_debug_axis             (bready_debug_axis ),
     .arid_debug_axis               (arid_debug_axis   ),
     .araddr_debug_axis             (araddr_debug_axis ),
     .arlen_debug_axis              (arlen_debug_axis  ),
     .arsize_debug_axis             (arsize_debug_axis ),
     .arburst_debug_axis            (arburst_debug_axis),
     .arlock_debug_axis             (arlock_debug_axis ),
     .arcache_debug_axis            (arcache_debug_axis),
     .arprot_debug_axis             (arprot_debug_axis ),
     .arvalid_debug_axis            (arvalid_debug_axis),
     .arready_debug_axis            (arready_debug_axis),
     .rid_debug_axis                (rid_debug_axis    ),
     .rdata_debug_axis              (rdata_debug_axis  ),
     .rresp_debug_axis              (rresp_debug_axis  ),
     .rlast_debug_axis              (rlast_debug_axis  ),
     .rvalid_debug_axis             (rvalid_debug_axis ),
     .rready_debug_axis             (rready_debug_axis ),
     .awuser_debug_axis             (awuser_debug_axis ),
     .aruser_debug_axis             (aruser_debug_axis ),
     .ruser_debug_axis              (ruser_debug_axis  ),
     .buser_debug_axis              (buser_debug_axis  ),
     
     .debug_axis_slvmustacceptreqn_async  (debug_axis_slvmustacceptreqn_async),
     .debug_axis_slvcandenyreqn_async     (debug_axis_slvcandenyreqn_async   ),
     .debug_axis_slvacceptn_async         (debug_axis_slvacceptn_async       ),
     .debug_axis_slvdeny_async            (debug_axis_slvdeny_async          ),                                
     .debug_axis_si_to_mi_wakeup_async    (debug_axis_si_to_mi_wakeup_async  ),
     .debug_axis_mi_to_si_wakeup_async    (debug_axis_mi_to_si_wakeup_async  ),                                        
     .debug_axis_aw_wr_ptr_async          (debug_axis_aw_wr_ptr_async        ),
     .debug_axis_aw_rd_ptr_async          (debug_axis_aw_rd_ptr_async        ),
     .debug_axis_aw_payld_async           (debug_axis_aw_payld_async         ),                                     
     .debug_axis_w_wr_ptr_async           (debug_axis_w_wr_ptr_async         ),
     .debug_axis_w_rd_ptr_async           (debug_axis_w_rd_ptr_async         ),
     .debug_axis_w_payld_async            (debug_axis_w_payld_async          ),                                    
     .debug_axis_b_wr_ptr_async           (debug_axis_b_wr_ptr_async         ),
     .debug_axis_b_rd_ptr_async           (debug_axis_b_rd_ptr_async         ),
     .debug_axis_b_payld_async            (debug_axis_b_payld_async          ),                                    
     .debug_axis_ar_wr_ptr_async          (debug_axis_ar_wr_ptr_async        ),
     .debug_axis_ar_rd_ptr_async          (debug_axis_ar_rd_ptr_async        ),
     .debug_axis_ar_payld_async           (debug_axis_ar_payld_async         ),                                     
     .debug_axis_r_wr_ptr_async           (debug_axis_r_wr_ptr_async         ),
     .debug_axis_r_rd_ptr_async           (debug_axis_r_rd_ptr_async         ),
     .debug_axis_r_payld_async            (debug_axis_r_payld_async          ),
     
     .stm_slvmustacceptreqn_async         (stm_slvmustacceptreqn_async),
     .stm_slvcandenyreqn_async            (stm_slvcandenyreqn_async   ),
     .stm_slvacceptn_async                (stm_slvacceptn_async       ),
     .stm_slvdeny_async                   (stm_slvdeny_async          ),
     .stm_si_to_mi_wakeup_async           (stm_si_to_mi_wakeup_async  ),
     .stm_mi_to_si_wakeup_async           (stm_mi_to_si_wakeup_async  ),
     .stm_aw_wr_ptr_async                 (stm_aw_wr_ptr_async        ),
     .stm_aw_rd_ptr_async                 (stm_aw_rd_ptr_async        ),
     .stm_aw_payld_async                  (stm_aw_payld_async         ),
     .stm_w_wr_ptr_async                  (stm_w_wr_ptr_async         ),
     .stm_w_rd_ptr_async                  (stm_w_rd_ptr_async         ),
     .stm_w_payld_async                   (stm_w_payld_async          ),
     .stm_b_wr_ptr_async                  (stm_b_wr_ptr_async         ),
     .stm_b_rd_ptr_async                  (stm_b_rd_ptr_async         ),
     .stm_b_payld_async                   (stm_b_payld_async          ),
     .stm_ar_wr_ptr_async                 (stm_ar_wr_ptr_async        ),
     .stm_ar_rd_ptr_async                 (stm_ar_rd_ptr_async        ),
     .stm_ar_payld_async                  (stm_ar_payld_async         ),
     .stm_r_wr_ptr_async                  (stm_r_wr_ptr_async         ),
     .stm_r_rd_ptr_async                  (stm_r_rd_ptr_async         ),
     .stm_r_payld_async                   (stm_r_payld_async          ),
     
     .dftcgen                             (dftcgen),
     .dftrstdisable                       (dftrstdisable[1])
  );


wire qactive_systop_egress_expander;
wire qactive_systop_internal_expander;
wire qactive_systop_ingress_expander;


pck600_lpd_q #(
  .SEQUENCER      (0), 
  .NUM_QCHL       (7),
  .CTRL_Q_CH_SYNC (1), 
  .DEV_Q_CH_SYNC  (1), 
  .ACTIVE_DENY    (0)  
  )
u_systop_egress_lpd_q                 
  (
  .clk              (refclk),
  .reset_n          (systop_warmresetn),    
  
  .ctrl_qreqn_i     (qreqn_systop[0]),  
  .ctrl_qacceptn_o  (qacceptn_systop[0]),
  .ctrl_qdeny_o     (qdeny_systop[0]),
  .ctrl_qactive_o   (qactive_systop[0]),

  .dev_qreqn_o      (qch_exp_systop_egress_devqreqn   ),
  .dev_qacceptn_i   (qch_exp_systop_egress_devqacceptn),
  .dev_qdeny_i      (qch_exp_systop_egress_devqdeny   ),
  .dev_qactive_i    (qch_exp_systop_egress_devqactive ),

  .clk_qactive_o    (qactive_systop_egress_expander),
  
  .dftcgen          (dftcgen)
);
  

pck600_lpd_q #(
  .SEQUENCER        (0), 
  .NUM_QCHL         (13),
  .CTRL_Q_CH_SYNC   (1), 
  .DEV_Q_CH_SYNC    (1), 
  .DEV_QACTIVE_SYNC (0), 
  .ACTIVE_DENY      (0)  
  )
u_systop_internal_lpdq                 
  (
  .clk              (refclk),
  .reset_n          (systop_warmresetn),    
  
  .ctrl_qreqn_i     (qreqn_systop[1]),  
  .ctrl_qacceptn_o  (qacceptn_systop[1]),
  .ctrl_qdeny_o     (qdeny_systop[1]),
  .ctrl_qactive_o   (qactive_systop[1]),

  .dev_qreqn_o      (qch_exp_systop_internal_devqreqn   ),
  .dev_qacceptn_i   (qch_exp_systop_internal_devqacceptn),
  .dev_qdeny_i      (qch_exp_systop_internal_devqdeny   ),
  .dev_qactive_i    (qch_exp_systop_internal_devqactive ),

  .clk_qactive_o    (qactive_systop_internal_expander),
  
  .dftcgen          (dftcgen)
);



pck600_lpd_q #(
  .SEQUENCER      (0), 
  .NUM_QCHL       (6),
  .CTRL_Q_CH_SYNC (1), 
  .DEV_Q_CH_SYNC  (1), 
  .ACTIVE_DENY    (0)  
  )
u_systop_ingress_lpd_q                 
  (
  .clk              (refclk),
  .reset_n          (systop_warmresetn),    
  
  .ctrl_qreqn_i     (qreqn_systop[2]),  
  .ctrl_qacceptn_o  (qacceptn_systop[2]),
  .ctrl_qdeny_o     (qdeny_systop[2]),
  .ctrl_qactive_o   (qactive_systop[2]),

  .dev_qreqn_o      (qch_exp_systop_ingress_devqreqn   ),
  .dev_qacceptn_i   (qch_exp_systop_ingress_devqacceptn),
  .dev_qdeny_i      (qch_exp_systop_ingress_devqdeny   ),
  .dev_qactive_i    (qch_exp_systop_ingress_devqactive ),

  .clk_qactive_o    (qactive_systop_ingress_expander),
  
  .dftcgen          (dftcgen)
);

pck600_or_tree
#(
  .NUM_OR_TREE_INPUTS (3)
)
u_or_systop_refclk_qactive
(
  .or_tree_i ({qactive_systop_ingress_expander,qactive_systop_internal_expander,qactive_systop_egress_expander}),
  .or_tree_o (refclk_qactive_o)
);


wire unused = (|unused_bid_secenc_axis) | 
              (|unused_rid_secenc_axis) | 
              (|unused_awuser_gic)      | 
              (|unused_aruser_gic)      | 
              (|unused_awaddr_gic)      |
              (|araddr_gic_axim[31:19]);

endmodule

