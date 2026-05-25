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


module pd_dbgtop_f0  #(parameter
      CLUS_INGRESS_2_DBG           = 3,
      SYS_INGRESS_2_DBG            = 1,
      DBG_INTERNAL_CNT             = 1,
      DBG_EGRESS_CNT               = 1,
      DBG_ADDR_WIDTH               = 32,
      DBG_DATA_WIDTH               = 64,
      DBG_AWID_WIDTH               = 4,
      DBG_ARID_WIDTH               = 4,
      DBG_AWUSER_WIDTH             = 10,
      DBG_WUSER_WIDTH              = 0,
      DBG_BUSER_WIDTH              = 0,
      DBG_ARUSER_WIDTH             = 10,
      DBG_RUSER_WIDTH              = 0,
      DBG_AW_FIFO_DEPTH            = 4,
      DBG_W_FIFO_DEPTH             = 6,
      DBG_B_FIFO_DEPTH             = 2,
      DBG_AR_FIFO_DEPTH            = 4,
      DBG_R_FIFO_DEPTH             = 6,
      DBG_AW_PAYLOAD_WIDTH         = 316,
      DBG_W_PAYLOAD_WIDTH          = 870,
      DBG_B_PAYLOAD_WIDTH          = 20,
      DBG_AR_PAYLOAD_WIDTH         = 316,
      DBG_R_PAYLOAD_WIDTH          = 834,
      STM_AW_FIFO_DEPTH            = 2,
      STM_W_FIFO_DEPTH             = 2,
      STM_B_FIFO_DEPTH             = 2,
      STM_AR_FIFO_DEPTH            = 2,
      STM_R_FIFO_DEPTH             = 2,
      STM_AW_PAYLOAD_WIDTH         = 236,
      STM_W_PAYLOAD_WIDTH          = 222,
      STM_B_PAYLOAD_WIDTH          = 24,
      STM_AR_PAYLOAD_WIDTH         = 236,
      STM_R_PAYLOAD_WIDTH          = 264,
      STM_ADDR_WIDTH               = 32,      
      STM_AXI_ID_WIDTH             = 12,
      STM_AWUSER_WIDTH             = 10,
      STM_WUSER_WIDTH              = 0,
      STM_BUSER_WIDTH              = 0,
      STM_ARUSER_WIDTH             = 0,
      STM_RUSER_WIDTH              = 0,
      A4S_ID_WIDTH                 = 4,
      A4S_FIFO_WIDTH               = 180,
      A4S_PAYLOAD_WIDTH            = 4,
      EXT_SYS0_ROM_ENTRY           = 0,
      EXT_SYS1_ROM_ENTRY           = 0,
      NUM_DBGCLK_QCH               = 2,
      DBG_FC_ID                    = 4'hd,
      HOST_EXP_ROM_ENTRY           = 0
)
(
    input  wire                            sys_pll,
    input  wire                            refclk,
    output wire                            dbgclkout,
    
    input  wire                            dbgtopwarmresetn,    

    input  wire                            flush_done_eh0,
    input  wire                            sync_clear_eh0,
    input  wire [3:0]                      wr_pointer_gray_eh0,
    input  wire [245:0]                    atb_fwd_data_eh0,
    input  wire                            syncreq_async_ack_eh0,
    output wire [3:0]                      rd_pointer_gray_eh0,
    output wire                            flush_req_eh0,
    output wire                            sync_done_eh0,
    output wire                            syncreq_async_req_eh0,
                                           
    output wire                            apb_async_req_eh0_dbg,
    output wire [67:0]                     apb_async_req_payload_eh0_dbg,
    input  wire [32:0]                     apb_async_resp_payload_eh0_dbg,
    input  wire                            apb_async_ack_eh0_dbg,
                                           
    output wire [3:0]                      pulse_req_eh0_cti_out,
    input  wire [3:0]                      pulse_ack_eh0_cti_out,

    output wire [3:0]                      pulse_ack_eh0_cti_in,
    input  wire [3:0]                      pulse_req_eh0_cti_in,

    output wire                            dpabort_pulse_req_eh0,
    input  wire                            dpabort_pulse_ack_eh0,

    input  wire                            qreqn_extsys0_ctioutpwr,
    output wire                            qacceptn_extsys0_ctioutpwr,
    output wire                            qdeny_extsys0_ctioutpwr,
    output wire                            qactive_extsys0_ctioutpwr,

    input  wire                            qreqn_extsys0_dbgpwr,
    output wire                            qacceptn_extsys0_dbgpwr,
    output wire                            qdeny_extsys0_dbgpwr,
    output wire                            qactive_extsys0_dbgpwr,

    input  wire                            flush_done_eh1,
    input  wire                            sync_clear_eh1,
    input  wire [3:0]                      wr_pointer_gray_eh1,
    input  wire [245:0]                    atb_fwd_data_eh1,
    input  wire                            syncreq_async_ack_eh1,
    output wire [3:0]                      rd_pointer_gray_eh1,
    output wire                            flush_req_eh1,
    output wire                            sync_done_eh1,
    output wire                            syncreq_async_req_eh1,
                                           
    output wire                            apb_async_req_eh1_dbg,
    output wire [67:0]                     apb_async_req_payload_eh1_dbg,
    input  wire [32:0]                     apb_async_resp_payload_eh1_dbg,
    input  wire                            apb_async_ack_eh1_dbg,
                                           
    output wire [3:0]                      pulse_req_eh1_cti_out,
    input  wire [3:0]                      pulse_ack_eh1_cti_out,

    output wire [3:0]                      pulse_ack_eh1_cti_in,
    input  wire [3:0]                      pulse_req_eh1_cti_in,

    output wire                            dpabort_pulse_req_eh1,
    input  wire                            dpabort_pulse_ack_eh1,

    input  wire                            qreqn_extsys1_ctioutpwr,
    output wire                            qacceptn_extsys1_ctioutpwr,
    output wire                            qdeny_extsys1_ctioutpwr,
    output wire                            qactive_extsys1_ctioutpwr,

    input  wire                            qreqn_extsys1_dbgpwr,
    output wire                            qacceptn_extsys1_dbgpwr,
    output wire                            qdeny_extsys1_dbgpwr,
    output wire                            qactive_extsys1_dbgpwr,

    output wire                            apb_async_req_secenc_dbg,
    output wire [48:0]                     apb_async_req_payload_secenc_dbg,
    input  wire [32:0]                     apb_async_resp_payload_secenc_dbg,
    input  wire                            apb_async_ack_secenc_dbg,

    output wire                            dp_abort_secenc_pulse_req,          
    input  wire                            dp_abort_secenc_pulse_ack,

    output wire [3:0]                      cti_cha_to_secenc_pulse_req,      
    input  wire [3:0]                      cti_cha_to_secenc_pulse_ack,
    output wire [3:0]                      cti_secenc_to_cha_pulse_ack,
    input  wire [3:0]                      cti_secenc_to_cha_pulse_req,

    input  wire                            qreqn_secenc_dbg_pwr,         
    output wire                            qacceptn_secenc_dbg_pwr,     
    output wire                            qdeny_secenc_dbg_pwr,      
    output wire                            qactive_secenc_dbg_pwr, 
    
    input   wire                           apb_async_req_aontop_dbg,
    input   wire [67:0]                    apb_async_req_payload_aontop_dbg,
    output  wire [32:0]                    apb_async_resp_payload_aontop_dbg,
    output  wire                           apb_async_ack_aontop_dbg,

    output  wire                           apb_async_req_hostcpu,
    output  wire [67:0]                    apb_async_req_payload_hostcpu,
    input   wire [32:0]                    apb_async_resp_payload_hostcpu,
    input   wire                           apb_async_ack_hostcpu,

    
    
    input  wire                            flush_done_hostcpu,
    input  wire                            sync_clear_hostcpu,
    input  wire [3:0]                      wr_pointer_gray_hostcpu,
    input  wire [245:0]                    atb_fwd_data_hostcpu,
    input  wire                            syncreq_async_ack_hostcpu,
    output wire [3:0]                      rd_pointer_gray_hostcpu,
    output wire                            flush_req_hostcpu,
    output wire                            sync_done_hostcpu,
    output wire                            syncreq_async_req_hostcpu,

    
    input wire [63:0]                      tsvalueb_refclk,

    output wire [15:0]                      axiap_csyspwrupreq_hostdbgpwr,
    input  wire [15:0]                      axiap_csyspwrupack_hostdbgpwr,
    output wire [3:0]                      axiap_csyspwrupreq_internal,
    input  wire [3:0]                      axiap_csyspwrupack_internal,
    output wire  [2:0]                     extdbg_cdbgpwrupreq,
    input  wire  [2:0]                     extdbg_cdbgpwrupack,
    output wire                            host_cdbgpwrupreq,
    input  wire                            host_cdbgpwrupack,


    output wire                            debug_axis_slvmustacceptreqn_async,
    output wire                            debug_axis_slvcandenyreqn_async,
    input  wire                            debug_axis_slvacceptn_async,
    input  wire                            debug_axis_slvdeny_async,

    output wire                            debug_axis_si_to_mi_wakeup_async,
    input  wire                            debug_axis_mi_to_si_wakeup_async,

    output wire [DBG_AW_FIFO_DEPTH-1:0]    debug_axis_aw_wr_ptr_async,
    input  wire [DBG_AW_FIFO_DEPTH-1:0]    debug_axis_aw_rd_ptr_async,
    output wire [DBG_AW_PAYLOAD_WIDTH-1:0] debug_axis_aw_payld_async,

    output wire [ DBG_W_FIFO_DEPTH-1:0]    debug_axis_w_wr_ptr_async,
    input  wire [ DBG_W_FIFO_DEPTH-1:0]    debug_axis_w_rd_ptr_async,
    output wire [DBG_W_PAYLOAD_WIDTH-1:0]  debug_axis_w_payld_async,

    input  wire [ DBG_B_FIFO_DEPTH-1:0]    debug_axis_b_wr_ptr_async,
    output wire [ DBG_B_FIFO_DEPTH-1:0]    debug_axis_b_rd_ptr_async,
    input  wire [DBG_B_PAYLOAD_WIDTH-1:0]  debug_axis_b_payld_async,

    output wire [DBG_AR_FIFO_DEPTH-1:0]    debug_axis_ar_wr_ptr_async,
    input  wire [DBG_AR_FIFO_DEPTH-1:0]    debug_axis_ar_rd_ptr_async,
    output wire [DBG_AR_PAYLOAD_WIDTH-1:0] debug_axis_ar_payld_async,

    input  wire [ DBG_R_FIFO_DEPTH-1:0]    debug_axis_r_wr_ptr_async,
    output wire [ DBG_R_FIFO_DEPTH-1:0]    debug_axis_r_rd_ptr_async,
    input  wire [DBG_R_PAYLOAD_WIDTH-1:0]  debug_axis_r_payld_async,

    input  wire                            fctrl_bypass,
    
    input  wire                             stm_slvmustacceptreqn_async,
    input  wire                             stm_slvcandenyreqn_async,
    output wire                             stm_slvacceptn_async,
    output wire                             stm_slvdeny_async,

    input  wire                             stm_si_to_mi_wakeup_async,
    output wire                             stm_mi_to_si_wakeup_async,

    input  wire [STM_AW_FIFO_DEPTH-1:0]     stm_aw_wr_ptr_async,
    output wire [STM_AW_FIFO_DEPTH-1:0]     stm_aw_rd_ptr_async,
    input  wire [STM_AW_PAYLOAD_WIDTH-1:0]  stm_aw_payld_async,

    input  wire [ STM_W_FIFO_DEPTH-1:0]     stm_w_wr_ptr_async,
    output wire [ STM_W_FIFO_DEPTH-1:0]     stm_w_rd_ptr_async,
    input  wire [STM_W_PAYLOAD_WIDTH-1:0]   stm_w_payld_async,

    output wire [ STM_B_FIFO_DEPTH-1:0]     stm_b_wr_ptr_async,
    input  wire [ STM_B_FIFO_DEPTH-1:0]     stm_b_rd_ptr_async,
    output wire [STM_B_PAYLOAD_WIDTH-1:0]   stm_b_payld_async,

    input  wire [STM_AR_FIFO_DEPTH-1:0]     stm_ar_wr_ptr_async,
    output wire [STM_AR_FIFO_DEPTH-1:0]     stm_ar_rd_ptr_async,
    input  wire [STM_AR_PAYLOAD_WIDTH-1:0]  stm_ar_payld_async,

    output wire [ STM_R_FIFO_DEPTH-1:0]     stm_r_wr_ptr_async,
    input  wire [ STM_R_FIFO_DEPTH-1:0]     stm_r_rd_ptr_async,
    output wire [STM_R_PAYLOAD_WIDTH-1:0]   stm_r_payld_async,

    
    input  [4:0]                            dbgclk_on_syspll_divratio,
    input  [1:0]                            dbgclk_clksel,

    output [4:0]                            dbgclk_on_syspll_divratio_cur,
    output [1:0]                            dbgclk_clksel_cur,
    input                                   clkforce_st_dbgclk_force_st,
     
    input  [7:0]                            dbgclk_entrydelay,

    input  wire                             dbgen_tpiuauth,
    input  wire                             niden_tpiuauth,
    input  wire                             spiden_tpiuauth,
    input  wire                             chen_tpiuauth,
    input  wire                             ap_en_hostextauth,   
    input  wire                             ap_secure_en_hostextauth, 
    input  wire                             dbgen_hostaxiauth,  
    input  wire                             niden_hostaxiauth,  
    input  wire                             spiden_hostaxiauth, 
    input  wire                             spniden_hostaxiauth,
    input  wire                             dbgen_dpauth,
    input  wire                             niden_dpauth,
    input  wire                             spiden_dpauth,
    input  wire                             spniden_dpauth,
    input  wire                             dbgen_hostauth,  
    input  wire                             niden_hostauth,  
    input  wire                             spiden_hostauth, 
    input  wire                             spniden_hostauth,
    input  wire                             chen_hostauth,
    input  wire                             dbgen_counterauth,
    input  wire                             niden_counterauth,
    input  wire                             chen_counterauth,
    
    input  wire                             traceclk_in,
    output wire                             traceclk,
    output wire [31:0]                      tracedata,
    output wire                             tracectl,
    input  wire [4:0]                       trace_max_datasize,
    input  wire                             tpctl_valid,
    
    output wire                             u_soc_cti_event_out_6_to_u_dp_eventstat,


    
    input  wire  [DBG_EGRESS_CNT-1:0]     qreqn_egress_dbgtop,
    output wire  [DBG_EGRESS_CNT-1:0]     qacceptn_egress_dbgtop,
    output wire  [DBG_EGRESS_CNT-1:0]     qdeny_egress_dbgtop,
    output wire  [DBG_EGRESS_CNT-1:0]     qactive_egress_dbgtop,
        
    input  wire  [DBG_INTERNAL_CNT-1:0]     qreqn_internal_dbgtop,
    output wire  [DBG_INTERNAL_CNT-1:0]     qacceptn_internal_dbgtop,
    output wire  [DBG_INTERNAL_CNT-1:0]     qdeny_internal_dbgtop,
    output wire  [DBG_INTERNAL_CNT-1:0]     qactive_internal_dbgtop,
    
    input  wire [SYS_INGRESS_2_DBG-1:0]     qreqn_systop_ingress_dbgtop,
    output wire [SYS_INGRESS_2_DBG-1:0]     qacceptn_systop_ingress_dbgtop,
    output wire [SYS_INGRESS_2_DBG-1:0]     qdeny_systop_ingress_dbgtop,
    output wire [SYS_INGRESS_2_DBG-1:0]     qactive_systop_ingress_dbgtop,
    
    input  wire [CLUS_INGRESS_2_DBG-1:0]     qreqn_clustop_ingress_dbgtop,
    output wire [CLUS_INGRESS_2_DBG-1:0]     qacceptn_clustop_ingress_dbgtop,
    output wire [CLUS_INGRESS_2_DBG-1:0]     qdeny_clustop_ingress_dbgtop,
    output wire [CLUS_INGRESS_2_DBG-1:0]     qactive_clustop_ingress_dbgtop,
    
   
    output wire                             pc_aontop_slvmustacceptreqn_async_slv,
    output wire                             pc_aontop_slvcandenyreqn_async_slv,
    input  wire                             pc_aontop_slvacceptn_async_slv,
    input  wire                             pc_aontop_slvdeny_async_slv,

    output wire                             pc_aontop_si_to_mi_wakeup_async_slv,
    input  wire                             pc_aontop_mi_to_si_wakeup_async_slv,

    output wire [A4S_FIFO_WIDTH-1:0]        pc_aontop_wr_ptr_async_slv,
    input  wire [A4S_FIFO_WIDTH-1:0]        pc_aontop_rd_ptr_async_slv,
    output wire [A4S_PAYLOAD_WIDTH-1:0]     pc_aontop_payld_async_slv,

    input  wire                             pc_aontop_slvmustacceptreqn_async_mst,
    input  wire                             pc_aontop_slvcandenyreqn_async_mst,
    output wire                             pc_aontop_slvacceptn_async_mst,
    output wire                             pc_aontop_slvdeny_async_mst,

    input  wire                             pc_aontop_si_to_mi_wakeup_async_mst,
    output wire                             pc_aontop_mi_to_si_wakeup_async_mst,

    input  wire [A4S_FIFO_WIDTH-1:0]        pc_aontop_wr_ptr_async_mst,
    output wire [A4S_FIFO_WIDTH-1:0]        pc_aontop_rd_ptr_async_mst,
    input  wire [A4S_PAYLOAD_WIDTH-1:0]     pc_aontop_payld_async_mst,

    
    input  wire                            hostsysdbg_async_req,
    input  wire [67:0]                     hostsysdbg_async_req_payload,
    output wire [32:0]                     hostsysdbg_async_resp_payload,
    output wire                            hostsysdbg_async_ack,
    
    
    input  wire                            dp_abort_pulse_req,
    output wire                            dp_abort_pulse_ack,
    
    
        
    output wire [3:0]                       hostcpuctichin_pulse_req,  
    input  wire [3:0]                       hostcpuctichin_pulse_ack,  
                        
    input  wire [3:0]                       hostcpuctichout_pulse_req,
    output wire [3:0]                       hostcpuctichout_pulse_ack,

    
    output wire                             irq_gic73_req,
    input  wire                             irq_gic73_ack,
    output wire                             irq_gic72_req,
    input  wire                             irq_gic72_ack,
    output wire                             irq_host_stm_req,
    input  wire                             irq_host_stm_ack,
    
    output wire                             irq_soc_etr,
    output wire                             irq_soc_catu,    
    output wire                             irq_host_etr,
    output wire                             irq_host_catu,
 
    input wire  [3:0]                       host_axiap_rom_revision   ,
    input wire  [11:0]                      host_axiap_rom_part_number, 
    input wire  [10:0]                      host_axiap_rom_jep106_id  ,
    input wire  [3:0]                       host_axiap_rom_eco_rev_and,
    input wire  [3:0]                       extdbg_rom_revision       ,
    input wire  [10:0]                      extdbg_rom_jep106_id      ,
    input wire  [3:0]                       extdbg_rom_eco_rev_and    ,
    input wire  [11:0]                      extdbg_rom_part_number    ,
    input wire  [3:0]                       host_rom_revision         ,
    input wire  [10:0]                      host_rom_jep106_id        ,
    input wire  [3:0]                       host_rom_eco_rev_and      ,
    input wire  [11:0]                      host_rom_part_number      ,
                        
    output wire                             s32k_counter_haltreqreq,                         
    input  wire                             s32k_counter_haltreqack,                         
    output wire                             s32k_counter_restartreq,                      
    input  wire                             s32k_counter_restartack,                     

    output wire                             refclk_counter_haltreqreq,                       
    input  wire                             refclk_counter_haltreqack,                       
    output wire                             refclk_counter_restartreq,                    
    input  wire                             refclk_counter_restartack,                   

    input wire                              stm_drready,          
    input wire                              stm_davalid,          
    input wire [1:0]                        stm_datype,           
    output wire                             stm_drvalid,          
    output wire [1:0]                       stm_drtype,           
    output wire                             stm_drlast,           
    output wire                             stm_daready,          
    
        
    input  wire                             traceexp_atwakeup_mst,
    input  wire [6:0]                       traceexp_atid_mst,
    input  wire [1:0]                       traceexp_atbytes_mst,
    input  wire [31:0]                      traceexp_atdata_mst,
    input  wire                             traceexp_atvalid_mst,
    output wire                             traceexp_atready_mst,
    output wire                             traceexp_afvalid_mst,
    input  wire                             traceexp_afready_mst,
    output wire                             traceexp_syncreq_mst,

    output wire                             dbgexp_apb4_mst_pwakeup,
    output wire                             dbgexp_apb4_mst_psel,
    output wire                             dbgexp_apb4_mst_penable,
    output wire                             dbgexp_apb4_mst_pwrite,
    output wire  [2:0]                      dbgexp_apb4_mst_pprot,
    output wire  [3:0]                      dbgexp_apb4_mst_pstrb,
    output wire [31:0]                      dbgexp_apb4_mst_paddr,
    output wire [31:0]                      dbgexp_apb4_mst_pwdata,
    input  wire                             dbgexp_apb4_mst_pready,
    input  wire                             dbgexp_apb4_mst_pslverr,
    input  wire [31:0]                      dbgexp_apb4_mst_prdata,
    
    output wire [NUM_DBGCLK_QCH-1:0]        dbgclk_qreqn,
    input  wire [NUM_DBGCLK_QCH-1:0]        dbgclk_qacceptn,
    input  wire [NUM_DBGCLK_QCH-1:0]        dbgclk_qdeny,
    input  wire [NUM_DBGCLK_QCH-1:0]        dbgclk_qactive,

    input  wire [3:0]                      ctiexp_ctichin,
    output wire [3:0]                      ctiexp_ctichout,
 

    input wire [1:0]                        dftdbgclksel,
    input wire                              dftdbgclkselen,
    input wire                              dftdbgclkdivbypass,
    input wire                              dftcgen,
    input wire [1:0]                        dftrstdisable,
    input wire                              dftdivsel,
    input wire                              nmbistreset
    
);

 
    
 localparam QCNT_PC_EH_F0_DBGTOP      =  3;
    
 localparam QCNT_PC_EH_F1_DBGTOP      =  3;
 localparam QCNT_PC_SECENC_F0_DBGTOP  =  2;
 localparam QCNT_PC_AON_F0_DBGTOP     =  4;
 localparam QCNT_PC_CPU_F0_DBGTOP     =  3;
 localparam QCNT_PC_SYSTOP_F0_DBGTOP  =  3;
 localparam QCNT_DEBUG_F0_DBGTOP      = 17;

    
 localparam QONLYCNT_PC_EH_F0_DBGTOP     = 3;
    
 localparam QONLYCNT_PC_EH_F1_DBGTOP     = 3;
 localparam QONLYCNT_PC_SECENC_F0_DBGTOP = 3;
 localparam QONLYCNT_PC_AON_F0_DBGTOP    = 1;
 localparam QONLYCNT_PC_CPU_F0_DBGTOP    = 0;
 localparam QONLYCNT_PC_SYSTOP_F0_DBGTOP = 0;
 localparam QONLYCNT_DEBUG_F0_DBGTOP     = 5; 
 localparam QONLYCNT_AXIAP_SYNC          = 16;
 localparam QONLYCNT_AUTH_SYNC           = 22;
 
 localparam QIDX_PC_EH_F0_DBGTOP     = 0; 
  
 localparam QIDX_PC_EH_F1_DBGTOP     = QIDX_PC_EH_F0_DBGTOP     + QCNT_PC_EH_F0_DBGTOP;

 localparam QIDX_PC_SECENC_F0_DBGTOP = QIDX_PC_EH_F1_DBGTOP     + QCNT_PC_EH_F1_DBGTOP;
 localparam QIDX_PC_AON_F0_DBGTOP    = QIDX_PC_SECENC_F0_DBGTOP + QCNT_PC_SECENC_F0_DBGTOP;
 localparam QIDX_PC_CPU_F0_DBGTOP    = QIDX_PC_AON_F0_DBGTOP    + QCNT_PC_AON_F0_DBGTOP;
 localparam QIDX_PC_SYSTOP_F0_DBGTOP = QIDX_PC_CPU_F0_DBGTOP    + QCNT_PC_CPU_F0_DBGTOP;
 localparam QIDX_DEBUG_F0_DBGTOP     = QIDX_PC_SYSTOP_F0_DBGTOP + QCNT_PC_SYSTOP_F0_DBGTOP;
 
 localparam QONLYIDX_PC_EH_F0_DBGTOP     = 0;
  
 localparam QONLYIDX_PC_EH_F1_DBGTOP     = QONLYIDX_PC_EH_F0_DBGTOP     + QONLYCNT_PC_EH_F0_DBGTOP;
 localparam QONLYIDX_PC_SECENC_F0_DBGTOP = QONLYIDX_PC_EH_F1_DBGTOP     + QONLYCNT_PC_EH_F1_DBGTOP;
 localparam QONLYIDX_PC_AON_F0_DBGTOP    = QONLYIDX_PC_SECENC_F0_DBGTOP + QONLYCNT_PC_SECENC_F0_DBGTOP;
 localparam QONLYIDX_PC_CPU_F0_DBGTOP    = QONLYIDX_PC_AON_F0_DBGTOP    + QONLYCNT_PC_AON_F0_DBGTOP;
 localparam QONLYIDX_PC_SYSTOP_F0_DBGTOP = QONLYIDX_PC_CPU_F0_DBGTOP    + QONLYCNT_PC_CPU_F0_DBGTOP;
 localparam QONLYIDX_DEBUG_F0_DBGTOP     = QONLYIDX_PC_SYSTOP_F0_DBGTOP + QONLYCNT_PC_SYSTOP_F0_DBGTOP;
 localparam QONLYIDX_AXIAP_SYNC          = QONLYIDX_DEBUG_F0_DBGTOP     + QONLYCNT_DEBUG_F0_DBGTOP;
 localparam QONLYIDX_AUTH_SYNC           = QONLYIDX_AXIAP_SYNC          + QONLYCNT_AXIAP_SYNC;

 
 localparam INT_NUM_DBGCLK_QCH = 
                                 QCNT_PC_EH_F0_DBGTOP     +
                                 QCNT_PC_EH_F1_DBGTOP     +
                                 QCNT_PC_SECENC_F0_DBGTOP +
                                 QCNT_PC_AON_F0_DBGTOP    +
                                 QCNT_PC_CPU_F0_DBGTOP    +
                                 QCNT_PC_SYSTOP_F0_DBGTOP +
                                 QCNT_DEBUG_F0_DBGTOP;

 localparam INT_NUM_DBGCLK_QONLYCH = 
                                      QONLYCNT_PC_EH_F0_DBGTOP     +
                                     QONLYCNT_PC_EH_F1_DBGTOP     +
                                     QONLYCNT_PC_SECENC_F0_DBGTOP +
                                     QONLYCNT_PC_AON_F0_DBGTOP    +
                                     QONLYCNT_PC_CPU_F0_DBGTOP    +
                                     QONLYCNT_PC_SYSTOP_F0_DBGTOP +
                                     QONLYCNT_DEBUG_F0_DBGTOP     +
                                     QONLYCNT_AUTH_SYNC           +
                                     QONLYCNT_AXIAP_SYNC;
             
 
  wire           s32k_counter_restart;
  wire           s32k_counter_haltreq;
  
  wire           refclk_counter_restart;
  wire           refclk_counter_haltreq;
  
  wire           treset_n;
  wire           psel_secenc_dbg;
  wire           pwakeup_secenc_dbg;
  wire           penable_secenc_dbg;
  wire [12:0]    paddr_secenc_dbg;
  wire [2:0]     paddr_secenc_dbg_not_used; 
  wire           pwrite_secenc_dbg;
  wire [31:0]    pwdata_secenc_dbg;
  wire [2:0]     pprot_secenc_dbg;
  wire [31:0]    prdata_secenc_dbg;
  wire           pready_secenc_dbg;
  wire           pslverr_secenc_dbg;

  wire           psel_aontop_dbg;
  wire           pwakeup_aontop_dbg;
  wire           penable_aontop_dbg;
  wire [31:0]    paddr_aontop_dbg;
  wire           pwrite_aontop_dbg;
  wire [31:0]    pwdata_aontop_dbg;
  wire [2:0]     pprot_aontop_dbg;
  wire [31:0]    prdata_aontop_dbg;
  wire           pready_aontop_dbg;
  wire           pslverr_aontop_dbg;

  wire           atready_extsys0;
  wire           afvalid_extsys0;
  wire           syncreq_extsys0;
  wire [6:0]     atid_extsys0;
  wire           atvalid_extsys0;
  wire [31:0]    atdata_extsys0;
  wire [1:0]     atbytes_extsys0;
  wire           afready_extsys0;
  wire           atwakeup_extsys0;

  wire           atready_extsys1;
  wire           afvalid_extsys1;
  wire           syncreq_extsys1;
  wire [6:0]     atid_extsys1;
  wire           atvalid_extsys1;
  wire [31:0]    atdata_extsys1;
  wire [1:0]     atbytes_extsys1;
  wire           afready_extsys1;
  wire           atwakeup_extsys1;

  wire           atready_hostcpu;
  wire           afvalid_hostcpu;
  wire           syncreq_hostcpu;
  wire [6:0]     atid_hostcpu;
  wire           atvalid_hostcpu;
  wire [31:0]    atdata_hostcpu;
  wire [1:0]     atbytes_hostcpu;
  wire           afready_hostcpu;
  wire           atwakeup_hostcpu;

  wire           psel_hostcpu;
  wire           penable_hostcpu;
  wire [31:0]    paddr_hostcpu;
  wire           pwrite_hostcpu;
  wire [31:0]    pwdata_hostcpu;
  wire [2:0]     pprot_hostcpu;
  wire [31:0]    prdata_hostcpu;
  wire           pready_hostcpu;
  wire           pslverr_hostcpu;
  wire           pwakeup_hostcpu;

  wire           psel_hostdbg;
  wire           penable_hostdbg;
  wire [31:0]    paddr_hostdbg;
  wire           pwrite_hostdbg;
  wire [31:0]    pwdata_hostdbg;
  wire [2:0]      pprot_hostdbg;
  wire [31:0]    prdata_hostdbg;
  wire           pready_hostdbg;
  wire           pslverr_hostdbg;
  wire           pwakeup_hostdbg;

  wire           psel_extsys0;
  wire           penable_extsys0;
  wire [31:0]    paddr_extsys0;
  wire           pwrite_extsys0;
  wire [31:0]    pwdata_extsys0;
  wire [2:0]     pprot_extsys0;
  wire [31:0]    prdata_extsys0;
  wire           pready_extsys0;
  wire           pslverr_extsys0;
  wire           pwakeup_extsys0;

  wire           psel_extsys1;
  wire           penable_extsys1;
  wire [31:0]    paddr_extsys1;
  wire           pwrite_extsys1;
  wire [31:0]    pwdata_extsys1;
  wire [2:0]     pprot_extsys1;
  wire [31:0]    prdata_extsys1;
  wire           pready_extsys1;
  wire           pslverr_extsys1;
  wire           pwakeup_extsys1;

  wire [STM_AXI_ID_WIDTH-1:0]      stm_axi_arids;
  wire [31:0]                      stm_axi_araddrs;
  wire [7:0]                       stm_axi_arlens;
  wire [2:0]                       stm_axi_arsizes;
  wire [1:0]                       stm_axi_arbursts;
  wire                             stm_axi_arlocks;
  wire [3:0]                       stm_axi_arcaches;
  wire [2:0]                       stm_axi_arprots;
  wire                             stm_axi_arvalids;
  wire                             stm_axi_arreadys;
  wire                             stm_axi_rreadys;
  wire [STM_AXI_ID_WIDTH-1:0]      stm_axi_rids;
  wire [63:0]                      stm_axi_rdatas;
  wire [1:0]                       stm_axi_rresps;
  wire                             stm_axi_rlasts;
  wire                             stm_axi_rvalids;
  wire [STM_AXI_ID_WIDTH-1:0]      stm_axi_awids;
  wire [31:0]                      stm_axi_awaddrs;
  wire [7:0]                       stm_axi_awlens;
  wire [2:0]                       stm_axi_awsizes;
  wire [1:0]                       stm_axi_awbursts;  
  wire                             stm_axi_awlocks;
  wire [3:0]                       stm_axi_awcaches;
  wire [2:0]                       stm_axi_awprots;
  wire [STM_AWUSER_WIDTH-1:0]      stm_axi_awusers;
  wire                             stm_axi_awvalids;
  wire                             stm_axi_awreadys;
  wire [63:0]                      stm_axi_wdatas;
  wire [7:0]                       stm_axi_wstrbs;
  wire                             stm_axi_wlasts;
  wire                             stm_axi_wvalids;
  wire                             stm_axi_wreadys;
  wire                             stm_axi_breadys;
  wire [STM_AXI_ID_WIDTH-1:0]      stm_axi_bids;
  wire [1:0]                       stm_axi_bresps;
  wire                             stm_axi_bvalids;


  
  wire [DBG_AWID_WIDTH-1:0]        debug_axis_bids;
  wire [DBG_ARID_WIDTH-1:0]        debug_axis_rids;
  wire [DBG_ARID_WIDTH-1:0]        debug_axis_arids;
  wire [31:0]                      debug_axis_araddrs;
  wire [7:0]                       debug_axis_arlens;
  wire [2:0]                       debug_axis_arsizes;
  wire [1:0]                       debug_axis_arbursts;
  wire                             debug_axis_arlocks;
  wire [3:0]                       debug_axis_arcaches;
  wire [2:0]                       debug_axis_arprots;
  wire [9:0]                       debug_axis_arusers;
  wire                             debug_axis_arvalids;
  wire                             debug_axis_arreadys;
  wire                             debug_axis_rreadys;
  wire [DBG_DATA_WIDTH-1:0]        debug_axis_rdatas;
  wire [1:0]                       debug_axis_rresps;
  wire                             debug_axis_rlasts;
  wire                             debug_axis_rvalids;
  wire [DBG_AWID_WIDTH-1:0]        debug_axis_awids;
  wire [31:0]                      debug_axis_awaddrs;
  wire [7:0]                       debug_axis_awlens;
  wire [2:0]                       debug_axis_awsizes;
  wire [1:0]                       debug_axis_awbursts;
  wire                             debug_axis_awlocks;
  wire [3:0]                       debug_axis_awcaches;
  wire [2:0]                       debug_axis_awprots;
  wire [9:0]                       debug_axis_awusers;
  wire                             debug_axis_awvalids;
  wire                             debug_axis_awreadys;
  wire [DBG_DATA_WIDTH-1:0]        debug_axis_wdatas;
  wire [(DBG_DATA_WIDTH/8)-1:0]    debug_axis_wstrbs;
  wire                             debug_axis_wlasts;  
  wire                             debug_axis_wvalids;
  wire                             debug_axis_wreadys;
  wire                             debug_axis_breadys;
  wire [1:0]                       debug_axis_bresps;
  wire                             debug_axis_bvalids;

  wire [3:0]                       extsys0_channel_out;
  wire [3:0]                       extsys0_channel_in;
  wire [3:0]                       extsys1_channel_out;
  wire [3:0]                       extsys1_channel_in;
  wire [3:0]                       hostcpuctichin;
  wire [3:0]                       hostcpuctichout;

  wire                             dbgclk_gated;
  wire                             dbgclk_free;
  wire [15:0]                      axiap_csyspwrupack_hostdbgpwr_ss;
  
  wire                             fc_tvalid_ds;
  wire                             fc_tready_ds;
  wire [31:0]                      fc_tdata_ds;
  wire  [3:0]                      fc_tkeep_ds;
  wire                             fc_tlast_ds;
  wire  [3:0]                      fc_tdest_ds;
  wire                             fc_tuser_ds;
  wire                             fc_twakeup_ds;

  wire                             fc_tvalid_us;
  wire                             fc_tready_us;
  wire [31:0]                      fc_tdata_us;
  wire                             fc_tstrb_us;
  wire  [3:0]                      fc_tkeep_us;
  wire                             fc_tlast_us;
  wire  [3:0]                      fc_tid_us;
  wire                             fc_tuser_us;
  wire                             fc_twakeup_us;

  wire                             dbgclk_resetn;
  wire                             refclk_resetn;
  
  wire                             dp_abort;
  
  wire  [3:0]                      cti_cha_to_secenc;
  wire  [3:0]                      cti_secenc_to_cha;
  
  wire  [INT_NUM_DBGCLK_QCH-1:0]    int_dbgclk_qreqn;
  wire  [INT_NUM_DBGCLK_QCH-1:0]    int_dbgclk_qacceptn; 
  wire  [INT_NUM_DBGCLK_QCH-1:0]    int_dbgclk_qactive;
  wire  [INT_NUM_DBGCLK_QCH-1:0]    int_dbgclk_qdeny;
  wire  [INT_NUM_DBGCLK_QONLYCH-1:0] int_dbgclk_qactive_only;
  
  wire                              dbgclk_clken;
  
  wire                              dbgen_dpauth_ss;
  wire                              niden_dpauth_ss;
  wire                              spiden_dpauth_ss;
  wire                              spniden_dpauth_ss;
  
  wire                              dbgen_tpiuauth_ss;
  wire                              niden_tpiuauth_ss;
  wire                              spiden_tpiuauth_ss; 
  wire                              chen_tpiuauth_ss; 
  
  wire                              dbgen_counterauth_ss;
  wire                              niden_counterauth_ss;
  wire                              chen_counterauth_ss;

  wire                              dbgen_hostaxiauth_ss;
  wire                              niden_hostaxiauth_ss;
  wire                              spiden_hostaxiauth_ss;
  wire                              spniden_hostaxiauth_ss;
  
  wire                              ap_en_hostextauth_ss;    
  wire                              ap_secure_en_hostextauth_ss; 

  wire                              dbgen_hostauth_ss;  
  wire                              niden_hostauth_ss;    
  wire                              spiden_hostauth_ss;   
  wire                              spniden_hostauth_ss;  
  wire                              chen_hostauth_ss;     
  
    
  wire                              unused;

  wire                              irq_gic73;
  wire                              irq_gic72;
  wire                              irq_host_stm;
  wire                              traceclk_dft;
  wire                              extdbg_cdbgpwrupack0_ss;
  wire                              resetn_clk_gen;  
  wire                              extdbg_cdbgpwrupack_secenc;
  
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_extdbg_cdbgpwrupack     ( .clk(dbgclk_gated), .nreset(dbgclk_resetn), .d_async (extdbg_cdbgpwrupack[0]),   .q (extdbg_cdbgpwrupack0_ss)  );  
  
  
  
  
  
  
  
  
  assign extdbg_cdbgpwrupack_secenc = extdbg_cdbgpwrupack0_ss & qacceptn_secenc_dbg_pwr;
  
  
  assign unused = |{paddr_hostdbg[31:27],paddr_secenc_dbg_not_used};
  
  arm_element_reset_sync u_trace_reset_sync(
    .clk          (traceclk_in),    
    .resetn_async (dbgtopwarmresetn), 
    .resetn_sync  (treset_n),       

    .dftrstdisable(dftrstdisable[1])   
   
  );
  

  
  pc_eh_f0_dbgtop u_pc_eh0_f0_dbgtop (
    .dbgclk                            (dbgclk_gated),
    .dbgtopwarmresetn                  (dbgclk_resetn),
    .atready_ehx                       (atready_extsys0),
    .afvalid_ehx                       (afvalid_extsys0),
    .syncreq_ehx                       (syncreq_extsys0),
    .atid_ehx                          (atid_extsys0),
    .atvalid_ehx                       (atvalid_extsys0),
    .atdata_ehx                        (atdata_extsys0),
    .atbytes_ehx                       (atbytes_extsys0),
    .afready_ehx                       (afready_extsys0),
    .atwakeup_ehx                      (atwakeup_extsys0),
    .psel_ehx_dbg                      (psel_extsys0),
    .penable_ehx_dbg                   (penable_extsys0),
    .paddr_ehx_dbg                     (paddr_extsys0),
    .pwrite_ehx_dbg                    (pwrite_extsys0),
    .pwdata_ehx_dbg                    (pwdata_extsys0),
    .pprot_ehx_dbg                     (pprot_extsys0),
    .prdata_ehx_dbg                    (prdata_extsys0),
    .pready_ehx_dbg                    (pready_extsys0),
    .pslverr_ehx_dbg                   (pslverr_extsys0),
    .pwakeup_ehx_dbg                   (pwakeup_extsys0),
    .channel_out_ehx_cti               (extsys0_channel_out),
    .channel_in_ehx_cti                (extsys0_channel_in),
    .dpabort_ehx                       (dp_abort),
    .flush_done_ehx                    (flush_done_eh0),
    .sync_clear_ehx                    (sync_clear_eh0),
    .wr_pointer_gray_ehx               (wr_pointer_gray_eh0),
    .atb_fwd_data_ehx                  (atb_fwd_data_eh0),
    .syncreq_async_ack_ehx             (syncreq_async_ack_eh0),
    .rd_pointer_gray_ehx               (rd_pointer_gray_eh0),
    .flush_req_ehx                     (flush_req_eh0),
    .sync_done_ehx                     (sync_done_eh0),
    .syncreq_async_req_ehx             (syncreq_async_req_eh0),
    .apb_async_req_ehx_dbg             (apb_async_req_eh0_dbg),
    .apb_async_req_payload_ehx_dbg     (apb_async_req_payload_eh0_dbg),
    .apb_async_resp_payload_ehx_dbg    (apb_async_resp_payload_eh0_dbg),
    .apb_async_ack_ehx_dbg             (apb_async_ack_eh0_dbg),
    .pulse_req_ehx_cti_out             (pulse_req_eh0_cti_out),
    .pulse_ack_ehx_cti_out             (pulse_ack_eh0_cti_out),
    .pulse_ack_ehx_cti_in              (pulse_ack_eh0_cti_in),
    .pulse_req_ehx_cti_in              (pulse_req_eh0_cti_in),
    .dpabort_pulse_req_ehx             (dpabort_pulse_req_eh0),
    .dpabort_pulse_ack_ehx             (dpabort_pulse_ack_eh0),
    .qreqn_extsysx_ctioutpwr           (qreqn_extsys0_ctioutpwr),
    .qacceptn_extsysx_ctioutpwr        (qacceptn_extsys0_ctioutpwr),
    .qdeny_extsysx_ctioutpwr           (qdeny_extsys0_ctioutpwr),
    .qactive_extsysx_ctioutpwr         (qactive_extsys0_ctioutpwr),
    .qreqn_extsysx_dbgpwr              (qreqn_extsys0_dbgpwr),
    .qacceptn_extsysx_dbgpwr           (qacceptn_extsys0_dbgpwr),
    .qdeny_extsysx_dbgpwr              (qdeny_extsys0_dbgpwr),
    .qactive_extsysx_dbgpwr            (qactive_extsys0_dbgpwr),
    .qreqn_ehx_dbgclk                  (int_dbgclk_qreqn   [QIDX_PC_EH_F0_DBGTOP +: QCNT_PC_EH_F0_DBGTOP]),
    .qacceptn_ehx_dbgclk               (int_dbgclk_qacceptn[QIDX_PC_EH_F0_DBGTOP +: QCNT_PC_EH_F0_DBGTOP]),
    .qdeny_ehx_dbgclk                  (int_dbgclk_qdeny   [QIDX_PC_EH_F0_DBGTOP +: QCNT_PC_EH_F0_DBGTOP]),
    .qactive_ehx_dbgclk                (int_dbgclk_qactive [QIDX_PC_EH_F0_DBGTOP +: QCNT_PC_EH_F0_DBGTOP]),
    .qactive_only_ehx_dbgclk           (int_dbgclk_qactive_only [QONLYIDX_PC_EH_F0_DBGTOP +: QONLYCNT_PC_EH_F0_DBGTOP]),
    .dftcgen                           (dftcgen)
  );

  
  pc_eh_f0_dbgtop u_pc_eh1_f0_dbgtop (
    .dbgclk                            (dbgclk_gated),
    .dbgtopwarmresetn                  (dbgclk_resetn),
    .atready_ehx                       (atready_extsys1),
    .afvalid_ehx                       (afvalid_extsys1),
    .syncreq_ehx                       (syncreq_extsys1),
    .atid_ehx                          (atid_extsys1),
    .atvalid_ehx                       (atvalid_extsys1),
    .atdata_ehx                        (atdata_extsys1),
    .atbytes_ehx                       (atbytes_extsys1),
    .afready_ehx                       (afready_extsys1),
    .atwakeup_ehx                      (atwakeup_extsys1),
    .psel_ehx_dbg                      (psel_extsys1),
    .penable_ehx_dbg                   (penable_extsys1),
    .paddr_ehx_dbg                     (paddr_extsys1),
    .pwrite_ehx_dbg                    (pwrite_extsys1),
    .pwdata_ehx_dbg                    (pwdata_extsys1),
    .pprot_ehx_dbg                     (pprot_extsys1),
    .prdata_ehx_dbg                    (prdata_extsys1),
    .pready_ehx_dbg                    (pready_extsys1),
    .pslverr_ehx_dbg                   (pslverr_extsys1),
    .pwakeup_ehx_dbg                   (pwakeup_extsys1),
    .channel_out_ehx_cti               (extsys1_channel_out),
    .channel_in_ehx_cti                (extsys1_channel_in),
    .dpabort_ehx                       (dp_abort),
    .flush_done_ehx                    (flush_done_eh1),
    .sync_clear_ehx                    (sync_clear_eh1),
    .wr_pointer_gray_ehx               (wr_pointer_gray_eh1),
    .atb_fwd_data_ehx                  (atb_fwd_data_eh1),
    .syncreq_async_ack_ehx             (syncreq_async_ack_eh1),
    .rd_pointer_gray_ehx               (rd_pointer_gray_eh1),
    .flush_req_ehx                     (flush_req_eh1),
    .sync_done_ehx                     (sync_done_eh1),
    .syncreq_async_req_ehx             (syncreq_async_req_eh1),
    .apb_async_req_ehx_dbg             (apb_async_req_eh1_dbg),
    .apb_async_req_payload_ehx_dbg     (apb_async_req_payload_eh1_dbg),
    .apb_async_resp_payload_ehx_dbg    (apb_async_resp_payload_eh1_dbg),
    .apb_async_ack_ehx_dbg             (apb_async_ack_eh1_dbg),
    .pulse_req_ehx_cti_out             (pulse_req_eh1_cti_out),
    .pulse_ack_ehx_cti_out             (pulse_ack_eh1_cti_out),
    .pulse_ack_ehx_cti_in              (pulse_ack_eh1_cti_in),
    .pulse_req_ehx_cti_in              (pulse_req_eh1_cti_in),
    .dpabort_pulse_req_ehx             (dpabort_pulse_req_eh1),
    .dpabort_pulse_ack_ehx             (dpabort_pulse_ack_eh1),
    .qreqn_extsysx_ctioutpwr           (qreqn_extsys1_ctioutpwr),
    .qacceptn_extsysx_ctioutpwr        (qacceptn_extsys1_ctioutpwr),
    .qdeny_extsysx_ctioutpwr           (qdeny_extsys1_ctioutpwr),
    .qactive_extsysx_ctioutpwr         (qactive_extsys1_ctioutpwr),
    .qreqn_extsysx_dbgpwr              (qreqn_extsys1_dbgpwr),
    .qacceptn_extsysx_dbgpwr           (qacceptn_extsys1_dbgpwr),
    .qdeny_extsysx_dbgpwr              (qdeny_extsys1_dbgpwr),
    .qactive_extsysx_dbgpwr            (qactive_extsys1_dbgpwr),
    .qreqn_ehx_dbgclk                  (int_dbgclk_qreqn   [QIDX_PC_EH_F1_DBGTOP +: QCNT_PC_EH_F1_DBGTOP]),
    .qacceptn_ehx_dbgclk               (int_dbgclk_qacceptn[QIDX_PC_EH_F1_DBGTOP +: QCNT_PC_EH_F1_DBGTOP]),
    .qdeny_ehx_dbgclk                  (int_dbgclk_qdeny   [QIDX_PC_EH_F1_DBGTOP +: QCNT_PC_EH_F1_DBGTOP]),
    .qactive_ehx_dbgclk                (int_dbgclk_qactive [QIDX_PC_EH_F1_DBGTOP +: QCNT_PC_EH_F1_DBGTOP]),
    .qactive_only_ehx_dbgclk           (int_dbgclk_qactive_only [QONLYIDX_PC_EH_F1_DBGTOP +: QONLYCNT_PC_EH_F1_DBGTOP]),
    .dftcgen                           (dftcgen)
  );

  pc_secenc_f0_dbgtop u_pc_secenc_f0_dbgtop (
    .dbgclk                              (dbgclk_gated),
    .dbgtopwarmresetn                    (dbgclk_resetn),
    .psel_secenc_dbg                     (psel_secenc_dbg),
    .pwakeup_secenc_dbg                  (pwakeup_secenc_dbg),
    .penable_secenc_dbg                  (penable_secenc_dbg),
    .paddr_secenc_dbg                    (paddr_secenc_dbg),
    .pwrite_secenc_dbg                   (pwrite_secenc_dbg),
    .pwdata_secenc_dbg                   (pwdata_secenc_dbg),
    .pprot_secenc_dbg                    (pprot_secenc_dbg),
    .prdata_secenc_dbg                   (prdata_secenc_dbg),
    .pready_secenc_dbg                   (pready_secenc_dbg),
    .pslverr_secenc_dbg                  (pslverr_secenc_dbg),
    .dp_abort_secenc                     (dp_abort),
    .cti_cha_to_secenc                   (cti_cha_to_secenc),
    .cti_secenc_to_cha                   (cti_secenc_to_cha),
    .qreqn_secenc_dbgclk                 (int_dbgclk_qreqn   [QIDX_PC_SECENC_F0_DBGTOP +: QCNT_PC_SECENC_F0_DBGTOP]),
    .qacceptn_secenc_dbgclk              (int_dbgclk_qacceptn[QIDX_PC_SECENC_F0_DBGTOP +: QCNT_PC_SECENC_F0_DBGTOP]),
    .qdeny_secenc_dbgclk                 (int_dbgclk_qdeny   [QIDX_PC_SECENC_F0_DBGTOP +: QCNT_PC_SECENC_F0_DBGTOP]),
    .qactive_secenc_dbgclk               (int_dbgclk_qactive [QIDX_PC_SECENC_F0_DBGTOP +: QCNT_PC_SECENC_F0_DBGTOP]),
    .qactive_only_secenc_dbgclk          (int_dbgclk_qactive_only [QONLYIDX_PC_SECENC_F0_DBGTOP +: QONLYCNT_PC_SECENC_F0_DBGTOP]),
    .qreqn_secenc_pwr                    (qreqn_secenc_dbg_pwr),
    .qacceptn_secenc_pwr                 (qacceptn_secenc_dbg_pwr),
    .qdeny_secenc_pwr                    (qdeny_secenc_dbg_pwr),
    .qactive_secenc_pwr                  (qactive_secenc_dbg_pwr),
    .apb_async_req_secenc_dbg            (apb_async_req_secenc_dbg),
    .apb_async_req_payload_secenc_dbg    (apb_async_req_payload_secenc_dbg),
    .apb_async_resp_payload_secenc_dbg   (apb_async_resp_payload_secenc_dbg),
    .apb_async_ack_secenc_dbg            (apb_async_ack_secenc_dbg),
    .dp_abort_secenc_pulse_req           (dp_abort_secenc_pulse_req),
    .dp_abort_secenc_pulse_ack           (dp_abort_secenc_pulse_ack),
    .cti_cha_to_secenc_pulse_req         (cti_cha_to_secenc_pulse_req),
    .cti_cha_to_secenc_pulse_ack         (cti_cha_to_secenc_pulse_ack),
    .cti_secenc_to_cha_pulse_ack         (cti_secenc_to_cha_pulse_ack),
    .cti_secenc_to_cha_pulse_req         (cti_secenc_to_cha_pulse_req),
    .dftcgen                             (dftcgen)
  );

   pc_aon_f0_dbgtop 
   #(
    .ID_WIDTH          (A4S_ID_WIDTH),
    .A4S_FIFO_WIDTH    (A4S_FIFO_WIDTH   ),
    .A4S_PAYLOAD_WIDTH (A4S_PAYLOAD_WIDTH),
    .CTI_PULSE_CNT     (4)    
   ) u_pc_aontop_f0_dbgtop (
    .dbgclk                                (dbgclk_gated),
    .reset_n                               (dbgclk_resetn),
    .dftcgen                               (dftcgen),
    .dftrstdisable                         (dftrstdisable[0]),
    
    .dbgclk_qreqn                          (int_dbgclk_qreqn   [QIDX_PC_AON_F0_DBGTOP +: QCNT_PC_AON_F0_DBGTOP]), 
    .dbgclk_qacceptn                       (int_dbgclk_qacceptn[QIDX_PC_AON_F0_DBGTOP +: QCNT_PC_AON_F0_DBGTOP]),
    .dbgclk_qdeny                          (int_dbgclk_qdeny   [QIDX_PC_AON_F0_DBGTOP +: QCNT_PC_AON_F0_DBGTOP]),
    .dbgclk_qactive                        (int_dbgclk_qactive [QIDX_PC_AON_F0_DBGTOP +: QCNT_PC_AON_F0_DBGTOP]),
    .dbgclk_qactive_only                   (int_dbgclk_qactive_only[QONLYIDX_PC_AON_F0_DBGTOP +: QONLYCNT_PC_AON_F0_DBGTOP]),
    
    .dbgtop_internal_qreqn                 (qreqn_internal_dbgtop[DBG_INTERNAL_CNT-1:1]),
    .dbgtop_internal_qacceptn              (qacceptn_internal_dbgtop[DBG_INTERNAL_CNT-1:1]),
    .dbgtop_internal_qdeny                 (qdeny_internal_dbgtop[DBG_INTERNAL_CNT-1:1]),
    .dbgtop_internal_qactive               (qactive_internal_dbgtop[DBG_INTERNAL_CNT-1:1]),
    
    .dbgtop_egress_qreqn                   (qreqn_egress_dbgtop[0]),
    .dbgtop_egress_qacceptn                (qacceptn_egress_dbgtop[0]),
    .dbgtop_egress_qdeny                   (qdeny_egress_dbgtop[0]),
    .dbgtop_egress_qactive                 (qactive_egress_dbgtop[0]),
            
    .apbdbg_mst_psel_o                     (psel_aontop_dbg),
    .apbdbg_mst_pwakeup_o                  (pwakeup_aontop_dbg),
    .apbdbg_mst_penable_o                  (penable_aontop_dbg),
    .apbdbg_mst_paddr_o                    (paddr_aontop_dbg),
    .apbdbg_mst_pwrite_o                   (pwrite_aontop_dbg),
    .apbdbg_mst_pwdata_o                   (pwdata_aontop_dbg),
    .apbdbg_mst_pprot_o                    (pprot_aontop_dbg),
    .apbdbg_mst_prdata_i                   (prdata_aontop_dbg),
    .apbdbg_mst_pready_i                   (pready_aontop_dbg),
    .apbdbg_mst_pslverr_i                  (pslverr_aontop_dbg),

    .apb_async_req_i_aon                   (apb_async_req_aontop_dbg),
    .apb_async_req_payload_i_aon           (apb_async_req_payload_aontop_dbg),
    .apb_async_resp_payload_o_aon          (apb_async_resp_payload_aontop_dbg),
    .apb_async_ack_o_aon                   (apb_async_ack_aontop_dbg),

    .cti_pulse_in       ({s32k_counter_haltreq,   refclk_counter_haltreq   ,s32k_counter_restart   ,refclk_counter_restart   }),
    .cti_pulse_req      ({s32k_counter_haltreqreq,refclk_counter_haltreqreq,s32k_counter_restartreq,refclk_counter_restartreq}),
    .cti_pulse_ack      ({s32k_counter_haltreqack,refclk_counter_haltreqack,s32k_counter_restartack,refclk_counter_restartack}),
      

    .wakeups_i                             (fc_twakeup_ds),
    .tvalids                               (fc_tvalid_ds),
    .treadys                               (fc_tready_ds),
    .tdatas                                (fc_tdata_ds),
    .tstrbs                                (1'b1),
    .tkeeps                                (fc_tkeep_ds),
    .tlasts                                (fc_tlast_ds),
    .tids                                  ({A4S_ID_WIDTH{1'b0}}), 
    .tdests                                (4'hf),
    .tusers                                (1'b0),
    .wakeupm_o                             (fc_twakeup_us),
    .tvalidm                               (fc_tvalid_us),
    .treadym                               (fc_tready_us),
    .tdatam                                (fc_tdata_us),
    .tstrbm                                (),
    .tkeepm                                (fc_tkeep_us),
    .tlastm                                (fc_tlast_us),
    .tidm                                  (),
    .tdestm                                (), 
    .tuserm                                (),

    .slvmustacceptreqn_async_slv           (pc_aontop_slvmustacceptreqn_async_slv),
    .slvcandenyreqn_async_slv              (pc_aontop_slvcandenyreqn_async_slv),
    .slvacceptn_async_slv                  (pc_aontop_slvacceptn_async_slv),
    .slvdeny_async_slv                     (pc_aontop_slvdeny_async_slv),

    .si_to_mi_wakeup_async_slv             (pc_aontop_si_to_mi_wakeup_async_slv), 
    .mi_to_si_wakeup_async_slv             (pc_aontop_mi_to_si_wakeup_async_slv), 
                                            
    .wr_ptr_async_slv                      (pc_aontop_wr_ptr_async_slv), 
    .rd_ptr_async_slv                      (pc_aontop_rd_ptr_async_slv), 
    .payld_async_slv                       (pc_aontop_payld_async_slv), 

    .slvmustacceptreqn_async_mst           (pc_aontop_slvmustacceptreqn_async_mst), 
    .slvcandenyreqn_async_mst              (pc_aontop_slvcandenyreqn_async_mst), 
    .slvacceptn_async_mst                  (pc_aontop_slvacceptn_async_mst), 
    .slvdeny_async_mst                     (pc_aontop_slvdeny_async_mst), 

    .si_to_mi_wakeup_async_mst             (pc_aontop_si_to_mi_wakeup_async_mst), 
    .mi_to_si_wakeup_async_mst             (pc_aontop_mi_to_si_wakeup_async_mst), 

    .dp_abort_pulse_req                    (dp_abort_pulse_req),
    .dp_abort_pulse_ack                    (dp_abort_pulse_ack),
    .dp_abort                              (dp_abort),
    

    .wr_ptr_async_mst                      (pc_aontop_wr_ptr_async_mst), 
    .rd_ptr_async_mst                      (pc_aontop_rd_ptr_async_mst),        
    .payld_async_mst                       (pc_aontop_payld_async_mst)  
    
    
  ); 




  pc_cpu_f0_dbgtop u_pc_cpu_f0_dbgtop (

    .dbgclk                     (dbgclk_gated),
    .dbgclk_resetn              (dbgclk_resetn),


    .atready_hostcpu            (atready_hostcpu ),
    .afvalid_hostcpu            (afvalid_hostcpu ),
    .syncreq_hostcpu            (syncreq_hostcpu ),
    .atid_hostcpu               (atid_hostcpu    ),
    .atvalid_hostcpu            (atvalid_hostcpu ),
    .atdata_hostcpu             (atdata_hostcpu  ),
    .atbytes_hostcpu            (atbytes_hostcpu ),
    .afready_hostcpu            (afready_hostcpu ),
    .atwakeup_hostcpu           (atwakeup_hostcpu),

    .psel_hostcpu               (psel_hostcpu   ),
    .penable_hostcpu            (penable_hostcpu),
    .paddr_hostcpu              (paddr_hostcpu  ),
    .pwrite_hostcpu             (pwrite_hostcpu ),
    .pwdata_hostcpu             (pwdata_hostcpu ),
    .pprot_hostcpu              (pprot_hostcpu  ),
    .prdata_hostcpu             (prdata_hostcpu ),
    .pready_hostcpu             (pready_hostcpu ),
    .pslverr_hostcpu            (pslverr_hostcpu),
    .pwakeup_hostcpu            (pwakeup_hostcpu),

    .hostcpuctichin             (hostcpuctichin),
    .hostcpuctichout            (hostcpuctichout),

    .hostcpuctichin_pulse_req   (hostcpuctichin_pulse_req),
    .hostcpuctichin_pulse_ack   (hostcpuctichin_pulse_ack),
                                
    .hostcpuctichout_pulse_req  (hostcpuctichout_pulse_req),
    .hostcpuctichout_pulse_ack  (hostcpuctichout_pulse_ack),

    .irq_pulse_in       ({irq_gic73    ,irq_gic72    ,irq_host_stm    }),
    .irq_pulse_req      ({irq_gic73_req,irq_gic72_req,irq_host_stm_req}),
    .irq_pulse_ack      ({irq_gic73_ack,irq_gic72_ack,irq_host_stm_ack}),
      
    
    .flush_done_hostcpu          (flush_done_hostcpu),
    .sync_clear_hostcpu          (sync_clear_hostcpu),
    .wr_pointer_gray_hostcpu     (wr_pointer_gray_hostcpu),
    .atb_fwd_data_hostcpu        (atb_fwd_data_hostcpu),
    .syncreq_async_ack_hostcpu   (syncreq_async_ack_hostcpu),
    .rd_pointer_gray_hostcpu     (rd_pointer_gray_hostcpu),
    .flush_req_hostcpu           (flush_req_hostcpu),
    .sync_done_hostcpu           (sync_done_hostcpu),
    .syncreq_async_req_hostcpu   (syncreq_async_req_hostcpu),

    .apb_async_req_hostcpu          (apb_async_req_hostcpu),
    .apb_async_req_payload_hostcpu  (apb_async_req_payload_hostcpu),
    .apb_async_resp_payload_hostcpu (apb_async_resp_payload_hostcpu),
    .apb_async_ack_hostcpu          (apb_async_ack_hostcpu),

    .qreqn_clustop_ingress_dbgtop    (qreqn_clustop_ingress_dbgtop),
    .qacceptn_clustop_ingress_dbgtop (qacceptn_clustop_ingress_dbgtop),
    .qdeny_clustop_ingress_dbgtop    (qdeny_clustop_ingress_dbgtop),
    .qactive_clustop_ingress_dbgtop  (qactive_clustop_ingress_dbgtop),

 
    
    .qreqn_clk      ( int_dbgclk_qreqn   [QIDX_PC_CPU_F0_DBGTOP +: QCNT_PC_CPU_F0_DBGTOP]), 
    .qacceptn_clk   ( int_dbgclk_qacceptn[QIDX_PC_CPU_F0_DBGTOP +: QCNT_PC_CPU_F0_DBGTOP]),
    .qdeny_clk      ( int_dbgclk_qdeny   [QIDX_PC_CPU_F0_DBGTOP +: QCNT_PC_CPU_F0_DBGTOP]),
    .qactive_clk    ( int_dbgclk_qactive [QIDX_PC_CPU_F0_DBGTOP +: QCNT_PC_CPU_F0_DBGTOP]),

    .dftcgen        (dftcgen)
);



  pc_systop_f0_dbgtop  #(
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
    .STM_AW_FIFO_DEPTH    (STM_AW_FIFO_DEPTH    ),
    .STM_W_FIFO_DEPTH     (STM_W_FIFO_DEPTH     ),
    .STM_B_FIFO_DEPTH     (STM_B_FIFO_DEPTH     ),
    .STM_AR_FIFO_DEPTH    (STM_AR_FIFO_DEPTH    ),
    .STM_R_FIFO_DEPTH     (STM_R_FIFO_DEPTH     ),
    .STM_AW_PAYLOAD_WIDTH (STM_AW_PAYLOAD_WIDTH ),
    .STM_W_PAYLOAD_WIDTH  (STM_W_PAYLOAD_WIDTH  ),
    .STM_B_PAYLOAD_WIDTH  (STM_B_PAYLOAD_WIDTH  ),
    .STM_AR_PAYLOAD_WIDTH (STM_AR_PAYLOAD_WIDTH ),
    .STM_R_PAYLOAD_WIDTH  (STM_R_PAYLOAD_WIDTH  ),
    .STM_AXI_ID_WIDTH     (STM_AXI_ID_WIDTH     ),
    .STM_AWUSER_WIDTH     (STM_AWUSER_WIDTH),
    .STM_WUSER_WIDTH      (STM_WUSER_WIDTH ),
    .STM_BUSER_WIDTH      (STM_BUSER_WIDTH ),
    .STM_ARUSER_WIDTH     (STM_ARUSER_WIDTH),
    .STM_RUSER_WIDTH      (STM_RUSER_WIDTH )
  ) u_systop_f0_dbgtop
  (
     .dbgclk           (dbgclk_gated  ),
     .reset_n          (dbgclk_resetn ),
     .dftcgen          (dftcgen),
     
     .dbgclk_qreqn     (int_dbgclk_qreqn   [QIDX_PC_SYSTOP_F0_DBGTOP +: QCNT_PC_SYSTOP_F0_DBGTOP]), 
     .dbgclk_qacceptn  (int_dbgclk_qacceptn[QIDX_PC_SYSTOP_F0_DBGTOP +: QCNT_PC_SYSTOP_F0_DBGTOP]),
     .dbgclk_qdeny     (int_dbgclk_qdeny   [QIDX_PC_SYSTOP_F0_DBGTOP +: QCNT_PC_SYSTOP_F0_DBGTOP]),
     .dbgclk_qactive   (int_dbgclk_qactive [QIDX_PC_SYSTOP_F0_DBGTOP +: QCNT_PC_SYSTOP_F0_DBGTOP]),
     
     .stm_axi_arid     (stm_axi_arids  ),
     .stm_axi_araddr   (stm_axi_araddrs),
     .stm_axi_arlen    (stm_axi_arlens ),
     .stm_axi_arsize   (stm_axi_arsizes),
     .stm_axi_arburst  (stm_axi_arbursts),
     .stm_axi_arlock   (stm_axi_arlocks),
     .stm_axi_arcache  (stm_axi_arcaches),
     .stm_axi_arprot   (stm_axi_arprots),
     .stm_axi_arvalid  (stm_axi_arvalids),
     .stm_axi_arready  (stm_axi_arreadys),
     .stm_axi_rready   (stm_axi_rreadys),
     .stm_axi_rid      (stm_axi_rids   ),
     .stm_axi_rdata    (stm_axi_rdatas ),
     .stm_axi_rresp    (stm_axi_rresps ),
     .stm_axi_rlast    (stm_axi_rlasts ),
     .stm_axi_rvalid   (stm_axi_rvalids),
     .stm_axi_awid     (stm_axi_awids  ),
     .stm_axi_awaddr   (stm_axi_awaddrs),
     .stm_axi_awlen    (stm_axi_awlens ),
     .stm_axi_awsize   (stm_axi_awsizes),
     .stm_axi_awburst  (stm_axi_awbursts),
     .stm_axi_awuser   (stm_axi_awusers),
     .stm_axi_awlock   (stm_axi_awlocks),
     .stm_axi_awcache  (stm_axi_awcaches),
     .stm_axi_awprot   (stm_axi_awprots),
     .stm_axi_awvalid  (stm_axi_awvalids),
     .stm_axi_awready  (stm_axi_awreadys),
     .stm_axi_wdata    (stm_axi_wdatas ),
     .stm_axi_wstrb    (stm_axi_wstrbs),
     .stm_axi_wlast    (stm_axi_wlasts ),
     .stm_axi_wvalid   (stm_axi_wvalids),
     .stm_axi_wready   (stm_axi_wreadys),
     .stm_axi_bready   (stm_axi_breadys),
     .stm_axi_bid      (stm_axi_bids   ),
     .stm_axi_bresp    (stm_axi_bresps ),
     .stm_axi_bvalid   (stm_axi_bvalids ),     


     .debug_axis_rid             (debug_axis_rids),
     .debug_axis_bid             (debug_axis_bids),
     .debug_axis_arid            (debug_axis_arids), 
     .debug_axis_awid            (debug_axis_awids),
     
     .debug_axis_awaddr          (debug_axis_awaddrs ),
     .debug_axis_awlen           (debug_axis_awlens  ),
     .debug_axis_awsize          (debug_axis_awsizes ),
     .debug_axis_awburst         (debug_axis_awbursts),
     .debug_axis_awlock          (debug_axis_awlocks ),
     .debug_axis_awcache         (debug_axis_awcaches),
     .debug_axis_awprot          (debug_axis_awprots ),
     .debug_axis_awvalid         (debug_axis_awvalids),
     .debug_axis_awready         (debug_axis_awreadys),
     .debug_axis_wdata           (debug_axis_wdatas  ),
     .debug_axis_wstrb           (debug_axis_wstrbs  ),
     .debug_axis_wlast           (debug_axis_wlasts  ),
     .debug_axis_wvalid          (debug_axis_wvalids ),
     .debug_axis_wready          (debug_axis_wreadys ),
     .debug_axis_bresp           (debug_axis_bresps  ),
     .debug_axis_bvalid          (debug_axis_bvalids ),
     .debug_axis_bready          (debug_axis_breadys ),
     .debug_axis_araddr          (debug_axis_araddrs ), 
     .debug_axis_arlen           (debug_axis_arlens  ),
     .debug_axis_arsize          (debug_axis_arsizes ),
     .debug_axis_arburst         (debug_axis_arbursts),
     .debug_axis_arlock          (debug_axis_arlocks ),
     .debug_axis_arcache         (debug_axis_arcaches),
     .debug_axis_arprot          (debug_axis_arprots ),
     .debug_axis_arvalid         (debug_axis_arvalids),
     .debug_axis_arready         (debug_axis_arreadys),
     .debug_axis_rdata           (debug_axis_rdatas  ),
     .debug_axis_rresp           (debug_axis_rresps  ),
     .debug_axis_rlast           (debug_axis_rlasts  ),
     .debug_axis_rvalid          (debug_axis_rvalids ),
     .debug_axis_rready          (debug_axis_rreadys ),
      
     .debug_axis_awuser          (debug_axis_awusers ),
     .debug_axis_aruser          (debug_axis_arusers ),

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


     
     .hostdbg_psel        (psel_hostdbg),  
     .hostdbg_penable     (penable_hostdbg),
     .hostdbg_paddr       (paddr_hostdbg),  
     .hostdbg_pwrite      (pwrite_hostdbg), 
     .hostdbg_pwdata      (pwdata_hostdbg), 
     .hostdbg_pstrb       (), 
     .hostdbg_pprot       (pprot_hostdbg),  
     .hostdbg_prdata      (prdata_hostdbg), 
     .hostdbg_pready      (pready_hostdbg), 
     .hostdbg_pslverr     (pslverr_hostdbg),
     .hostdbg_pwakeup     (pwakeup_hostdbg),
     
     .hostsysdbg_async_req          (hostsysdbg_async_req),
     .hostsysdbg_async_req_payload  (hostsysdbg_async_req_payload),     
     .hostsysdbg_async_resp_payload (hostsysdbg_async_resp_payload),     
     .hostsysdbg_async_ack          (hostsysdbg_async_ack),     
     
     .qreqn_axi_adb    (qreqn_systop_ingress_dbgtop[0]),
     .qacceptn_axi_adb (qacceptn_systop_ingress_dbgtop[0]),
     .qdeny_axi_adb    (qdeny_systop_ingress_dbgtop[0]),
     .qactive_axi_adb  (qactive_systop_ingress_dbgtop[0]),
     
     
     .dftrstdisable (dftrstdisable[0])

  );

  assign paddr_extsys0[31:20] = 12'd0;
  assign paddr_extsys1[31:20] = 12'd0;

  assign dbgexp_apb4_mst_pstrb = {4{dbgexp_apb4_mst_pwrite}};

  
  arm_element_clock_mux2 u_traceclk_bypass 
    (
        .clk0_in(traceclk_dft),
        .clk1_in(traceclk_in),
        .sel_clk1_not_clk0(dftdbgclkdivbypass),
        .clk_out(traceclk)
    );

  assign debug_axis_awusers[1:0] = 2'd0;
  assign debug_axis_arusers[1:0] = 2'd0;
  
  
  debug_f0_dbgtop #(
    .STM_AXI_ID_WIDTH            (STM_AXI_ID_WIDTH),
    .STM_AWUSER_WIDTH            (STM_AWUSER_WIDTH),
    .STM_ADDR_WIDTH              (STM_ADDR_WIDTH),    
    .FC_AXIDATA_WIDTH            (DBG_DATA_WIDTH),
    .FC_AXIID_WIDTH              (DBG_ARID_WIDTH),
    .FC_AXIUSER_AR_WIDTH         (DBG_AWUSER_WIDTH),
    .FC_AXIUSER_AW_WIDTH         (DBG_ARUSER_WIDTH),
    .FC_ADDR_WIDTH               (DBG_ADDR_WIDTH),
    .EXT_SYS0_ROM_ENTRY          (EXT_SYS0_ROM_ENTRY),
    .EXT_SYS1_ROM_ENTRY          (EXT_SYS1_ROM_ENTRY),
    .DBG_FC_ID                   (DBG_FC_ID),
    .HOST_EXP_ROM_ENTRY          (HOST_EXP_ROM_ENTRY)
    
  ) u_debug_f0_dbgtop (

    .dbgclk_gated    (dbgclk_gated),                         
    .dbgclk_resetn   (dbgclk_resetn),
    .refclk          (refclk),
    .refclk_resetn   (refclk_resetn),
                     
                     
   .dbgclk_qreqn     (int_dbgclk_qreqn   [QIDX_DEBUG_F0_DBGTOP +: QCNT_DEBUG_F0_DBGTOP]), 
   .dbgclk_qacceptn  (int_dbgclk_qacceptn[QIDX_DEBUG_F0_DBGTOP +: QCNT_DEBUG_F0_DBGTOP]),
   .dbgclk_qdeny     (int_dbgclk_qdeny   [QIDX_DEBUG_F0_DBGTOP +: QCNT_DEBUG_F0_DBGTOP]),
   .dbgclk_qactive   (int_dbgclk_qactive [QIDX_DEBUG_F0_DBGTOP +: QCNT_DEBUG_F0_DBGTOP]),
   .dbgclk_qactive_only   (int_dbgclk_qactive_only[QONLYIDX_DEBUG_F0_DBGTOP +: QONLYCNT_DEBUG_F0_DBGTOP]),
     
    .dftcgen                                      (dftcgen),

    .dp_abort                                     (dp_abort),

    .extsys0_channel_in                           (extsys0_channel_in),
    .extsys0_channel_out                          (extsys0_channel_out),

    .extsys1_channel_in                           (extsys1_channel_in),
    .extsys1_channel_out                          (extsys1_channel_out),


    .secenc_channel_in                            (cti_secenc_to_cha),
    .secenc_channel_out                           (cti_cha_to_secenc),    

    .hostcpuctichin                               (hostcpuctichin),
    .hostcpuctichout                              (hostcpuctichout),
    .hostctiexpin                                 (ctiexp_ctichin),
    .hostctiexpout                                (ctiexp_ctichout),

    .hostcputrace_atwakeup_s                      (atwakeup_hostcpu),
    .hostcputrace_atid_s                          (atid_hostcpu),
    .hostcputrace_atbytes_s                       (atbytes_hostcpu),
    .hostcputrace_atdata_s                        (atdata_hostcpu),
    .hostcputrace_atvalid_s                       (atvalid_hostcpu),
    .hostcputrace_atready_s                       (atready_hostcpu),
    .hostcputrace_afvalid_s                       (afvalid_hostcpu),
    .hostcputrace_afready_s                       (afready_hostcpu),
    .hostcputrace_syncreq_s                       (syncreq_hostcpu),

    .hostdbgtraceexp_atwakeup_s                   (traceexp_atwakeup_mst),
    .hostdbgtraceexp_atid_s                       (traceexp_atid_mst),
    .hostdbgtraceexp_atbytes_s                    (traceexp_atbytes_mst),
    .hostdbgtraceexp_atdata_s                     (traceexp_atdata_mst),
    .hostdbgtraceexp_atvalid_s                    (traceexp_atvalid_mst),
    .hostdbgtraceexp_atready_s                    (traceexp_atready_mst),
    .hostdbgtraceexp_afvalid_s                    (traceexp_afvalid_mst),
    .hostdbgtraceexp_afready_s                    (traceexp_afready_mst),
    .hostdbgtraceexp_syncreq_s                    (traceexp_syncreq_mst),

    .extsys0_atwakeup_s                           (atwakeup_extsys0),
    .extsys0_atid_s                               (atid_extsys0),
    .extsys0_atbytes_s                            (atbytes_extsys0),
    .extsys0_atdata_s                             (atdata_extsys0),
    .extsys0_atvalid_s                            (atvalid_extsys0),
    .extsys0_atready_s                            (atready_extsys0),
    .extsys0_afvalid_s                            (afvalid_extsys0),
    .extsys0_afready_s                            (afready_extsys0),
    .extsys0_syncreq_s                            (syncreq_extsys0),

    .extsys1_atwakeup_s                           (atwakeup_extsys1),
    .extsys1_atid_s                               (atid_extsys1),
    .extsys1_atbytes_s                            (atbytes_extsys1),
    .extsys1_atdata_s                             (atdata_extsys1),
    .extsys1_atvalid_s                            (atvalid_extsys1),
    .extsys1_atready_s                            (atready_extsys1),
    .extsys1_afvalid_s                            (afvalid_extsys1),
    .extsys1_afready_s                            (afready_extsys1),
    .extsys1_syncreq_s                            (syncreq_extsys1),


    .secure_enclave_pwakeup_m                     (pwakeup_secenc_dbg),
    .secure_enclave_psel_m                        (psel_secenc_dbg),
    .secure_enclave_penable_m                     (penable_secenc_dbg),
    .secure_enclave_pwrite_m                      (pwrite_secenc_dbg),
    .secure_enclave_pprot_m                       (pprot_secenc_dbg),
    .secure_enclave_paddr_m                       ({paddr_secenc_dbg_not_used, paddr_secenc_dbg}), 
    .secure_enclave_pwdata_m                      (pwdata_secenc_dbg),
    .secure_enclave_pready_m                      (pready_secenc_dbg),
    .secure_enclave_pslverr_m                     (pslverr_secenc_dbg),
    .secure_enclave_prdata_m                      (prdata_secenc_dbg),

    .extsys0_dbgapb_pwakeup_m                     (pwakeup_extsys0),
    .extsys0_dbgapb_psel_m                        (psel_extsys0),
    .extsys0_dbgapb_penable_m                     (penable_extsys0),
    .extsys0_dbgapb_pwrite_m                      (pwrite_extsys0),
    .extsys0_dbgapb_pprot_m                       (pprot_extsys0),
    .extsys0_dbgapb_paddr_m                       (paddr_extsys0[19:0]),
    .extsys0_dbgapb_pwdata_m                      (pwdata_extsys0),
    .extsys0_dbgapb_pready_m                      (pready_extsys0),
    .extsys0_dbgapb_pslverr_m                     (pslverr_extsys0),
    .extsys0_dbgapb_prdata_m                      (prdata_extsys0),

    .extsys1_dbgapb_pwakeup_m                     (pwakeup_extsys1),
    .extsys1_dbgapb_psel_m                        (psel_extsys1),
    .extsys1_dbgapb_penable_m                     (penable_extsys1),
    .extsys1_dbgapb_pwrite_m                      (pwrite_extsys1),
    .extsys1_dbgapb_pprot_m                       (pprot_extsys1),
    .extsys1_dbgapb_paddr_m                       (paddr_extsys1[19:0]),
    .extsys1_dbgapb_pwdata_m                      (pwdata_extsys1),
    .extsys1_dbgapb_pready_m                      (pready_extsys1),
    .extsys1_dbgapb_pslverr_m                     (pslverr_extsys1),
    .extsys1_dbgapb_prdata_m                      (prdata_extsys1),

    .hostdbgexp_pwakeup_m                         (dbgexp_apb4_mst_pwakeup ),
    .hostdbgexp_psel_m                            (dbgexp_apb4_mst_psel    ),
    .hostdbgexp_penable_m                         (dbgexp_apb4_mst_penable ),
    .hostdbgexp_pwrite_m                          (dbgexp_apb4_mst_pwrite  ),
    .hostdbgexp_pprot_m                           (dbgexp_apb4_mst_pprot   ),
    .hostdbgexp_paddr_m                           (dbgexp_apb4_mst_paddr   ),
    .hostdbgexp_pwdata_m                          (dbgexp_apb4_mst_pwdata  ),
    .hostdbgexp_pready_m                          (dbgexp_apb4_mst_pready  ),
    .hostdbgexp_pslverr_m                         (dbgexp_apb4_mst_pslverr ),
    .hostdbgexp_prdata_m                          (dbgexp_apb4_mst_prdata  ),

    .stm_drready(stm_drready),  
    .stm_davalid(stm_davalid),      
    .stm_datype (stm_datype ),      
    .stm_drvalid(stm_drvalid),      
    .stm_drtype (stm_drtype ),      
    .stm_drlast (stm_drlast ),      
    .stm_daready(stm_daready),      
    
    .s32k_cnt_restart                             (s32k_counter_restart),
    .s32k_cnt_halt                                (s32k_counter_haltreq),
    
    
    
    .refclk_cnt_restart                           (refclk_counter_restart),
    .refclk_cnt_halt                              (refclk_counter_haltreq   ),

    .host_cti_devaff                              (64'd0), 
    .soc_cti_devaff                               (64'd0), 
    .counter_cti_devaff                           (64'd0), 

    .tsvalueb_refclk                              (tsvalueb_refclk),
    
    
    .u_soc_cti_event_out_6_to_u_dp_eventstat      (u_soc_cti_event_out_6_to_u_dp_eventstat),


    .apbdbg_pwakeup_s                             (pwakeup_aontop_dbg),
    .apbdbg_psel_s                                (psel_aontop_dbg),
    .apbdbg_penable_s                             (penable_aontop_dbg),
    .apbdbg_pwrite_s                              (pwrite_aontop_dbg),
    .apbdbg_pprot_s                               (pprot_aontop_dbg),
    .apbdbg_paddr_s                               (paddr_aontop_dbg),
    .apbdbg_pwdata_s                              (pwdata_aontop_dbg),
    .apbdbg_pready_s                              (pready_aontop_dbg),
    .apbdbg_pslverr_s                             (pslverr_aontop_dbg),
    .apbdbg_prdata_s                              (prdata_aontop_dbg),


    .hostdbg_pwakeup_m_to_u_decoder_host_pwakeup_s(pwakeup_hostdbg),
    .hostdbg_psel_m_to_u_decoder_host_psel_s      (psel_hostdbg),
    .hostdbg_penable_m_to_u_decoder_host_penable_s(penable_hostdbg),
    .hostdbg_pwrite_m_to_u_decoder_host_pwrite_s  (pwrite_hostdbg),
    .hostdbg_pprot_m_to_u_decoder_host_pprot_s    (pprot_hostdbg),
    .hostdbg_paddr_m_to_u_decoder_host_paddr_s    (paddr_hostdbg[26:0]),
    .hostdbg_pwdata_m_to_u_decoder_host_pwdata_s  (pwdata_hostdbg),
    .hostdbg_pready_m_to_u_decoder_host_pready_s  (pready_hostdbg),
    .hostdbg_pslverr_m_to_u_decoder_host_pslverr_s(pslverr_hostdbg),
    .hostdbg_prdata_m_to_u_decoder_host_prdata_s  (prdata_hostdbg),

    .cluster_debug_adb_pwakeup_m                  (pwakeup_hostcpu),
    .cluster_debug_adb_psel_m                     (psel_hostcpu),
    .cluster_debug_adb_penable_m                  (penable_hostcpu),
    .cluster_debug_adb_pwrite_m                   (pwrite_hostcpu),
    .cluster_debug_adb_pprot_m                    (pprot_hostcpu),
    .cluster_debug_adb_paddr_m                    (paddr_hostcpu),
    .cluster_debug_adb_pwdata_m                   (pwdata_hostcpu),
    .cluster_debug_adb_pready_m                   (pready_hostcpu),
    .cluster_debug_adb_pslverr_m                  (pslverr_hostcpu),
    .cluster_debug_adb_prdata_m                   (prdata_hostcpu),

    .axiap_csyspwrupreq_hostdbgpwr                (axiap_csyspwrupreq_hostdbgpwr),
    .axiap_csyspwrupack_hostdbgpwr                (axiap_csyspwrupack_hostdbgpwr_ss),    
    .axiap_csyspwrupreq_internal                  (axiap_csyspwrupreq_internal),
    .axiap_csyspwrupack_internal                  (axiap_csyspwrupack_internal),
    .extdbg_cdbgpwrupreq                          (extdbg_cdbgpwrupreq),
    .extdbg_cdbgpwrupack                          ({extdbg_cdbgpwrupack[2:1],extdbg_cdbgpwrupack_secenc}),
    .host_cdbgpwrupreq                            (host_cdbgpwrupreq),
    .host_cdbgpwrupack                            (host_cdbgpwrupack),

    .stm_axi_arids                                (stm_axi_arids),
    .stm_axi_araddrs                              (stm_axi_araddrs),
    .stm_axi_arlens                               (stm_axi_arlens),
    .stm_axi_arsizes                              (stm_axi_arsizes),
    .stm_axi_arbursts                             (stm_axi_arbursts),
    .stm_axi_arlocks                              (stm_axi_arlocks),
    .stm_axi_arcaches                             (stm_axi_arcaches),
    .stm_axi_arprots                              (stm_axi_arprots),
    .stm_axi_arvalids                             (stm_axi_arvalids),
    .stm_axi_arreadys                             (stm_axi_arreadys),
    .stm_axi_rreadys                              (stm_axi_rreadys),
    .stm_axi_rids                                 (stm_axi_rids),
    .stm_axi_rdatas                               (stm_axi_rdatas),
    .stm_axi_rresps                               (stm_axi_rresps),
    .stm_axi_rlasts                               (stm_axi_rlasts),
    .stm_axi_rvalids                              (stm_axi_rvalids),
    .stm_axi_awids                                (stm_axi_awids),
    .stm_axi_awaddrs                              (stm_axi_awaddrs),
    .stm_axi_awlens                               (stm_axi_awlens),
    .stm_axi_awsizes                              (stm_axi_awsizes),
    .stm_axi_awbursts                             (stm_axi_awbursts),
    .stm_axi_awusers                              (stm_axi_awusers),
    .stm_axi_awlocks                              (stm_axi_awlocks),
    .stm_axi_awcaches                             (stm_axi_awcaches),
    .stm_axi_awprots                              (stm_axi_awprots),
    .stm_axi_awvalids                             (stm_axi_awvalids),
    .stm_axi_awreadys                             (stm_axi_awreadys),
    .stm_axi_wdatas                               (stm_axi_wdatas),
    .stm_axi_wstrbs                               (stm_axi_wstrbs),
    .stm_axi_wlasts                               (stm_axi_wlasts),
    .stm_axi_wvalids                              (stm_axi_wvalids),
    .stm_axi_wreadys                              (stm_axi_wreadys),
    .stm_axi_breadys                              (stm_axi_breadys),
    .stm_axi_bids                                 (stm_axi_bids),
    .stm_axi_bresps                               (stm_axi_bresps),
    .stm_axi_bvalids                              (stm_axi_bvalids),

    .dbgen_tpiuauth_ss                            (dbgen_tpiuauth_ss),
    .niden_tpiuauth_ss                            (niden_tpiuauth_ss),
    .spiden_tpiuauth_ss                           (spiden_tpiuauth_ss),
    .chen_tpiuauth_ss                             (chen_tpiuauth_ss),
    .ap_en_hostextauth_ss                         (ap_en_hostextauth_ss),      
    .ap_secure_en_hostextauth_ss                  (ap_secure_en_hostextauth_ss), 
    .dbgen_hostaxiauth_ss                         (dbgen_hostaxiauth_ss), 
    .niden_hostaxiauth_ss                         (niden_hostaxiauth_ss),  
    .spiden_hostaxiauth_ss                        (spiden_hostaxiauth_ss), 
    .spniden_hostaxiauth_ss                       (spniden_hostaxiauth_ss),
    .dbgen_dpauth_ss                              (dbgen_dpauth_ss),
    .niden_dpauth_ss                              (niden_dpauth_ss),
    .spiden_dpauth_ss                             (spiden_dpauth_ss),
    .spniden_dpauth_ss                            (spniden_dpauth_ss),
    .dbgen_hostauth_ss                            (dbgen_hostauth_ss),  
    .niden_hostauth_ss                            (niden_hostauth_ss),  
    .spiden_hostauth_ss                           (spiden_hostauth_ss), 
    .spniden_hostauth_ss                          (spniden_hostauth_ss),
    .chen_hostauth_ss                             (chen_hostauth_ss),
    .dbgen_counterauth_ss                         (dbgen_counterauth_ss),
    .niden_counterauth_ss                         (niden_counterauth_ss),
    .chen_counterauth_ss                          (chen_counterauth_ss),
    

    .traceclk_in                                  (traceclk_in),
    .treset_n                                     (treset_n),
    .traceclk                                     (traceclk_dft),
    .tracedata                                    (tracedata),
    .tracectl                                     (tracectl),
    .tpctl_valid                                  (tpctl_valid),
    .tp_maxdatasize                               (trace_max_datasize),

    .fc_arid_m_o                                  (debug_axis_arids),
    .fc_araddr_m_o                                (debug_axis_araddrs),
    .fc_arlen_m_o                                 (debug_axis_arlens),
    .fc_arsize_m_o                                (debug_axis_arsizes),
    .fc_arburst_m_o                               (debug_axis_arbursts),
    .fc_arlock_m_o                                (debug_axis_arlocks),
    .fc_arcache_m_o                               (debug_axis_arcaches),
    .fc_arprot_m_o                                (debug_axis_arprots),
    .fc_arqos_m_o                                 (),
    .fc_arregion_m_o                              (),
    .fc_aruser_m_o                                (),
    .fc_arvalid_m_o                               (debug_axis_arvalids),
    .fc_arready_m_i                               (debug_axis_arreadys),
    .fc_armmusid_m_o                              (debug_axis_arusers[9:2]),
    .fc_awid_m_o                                  (debug_axis_awids),
    .fc_awaddr_m_o                                (debug_axis_awaddrs),
    .fc_awlen_m_o                                 (debug_axis_awlens),
    .fc_awsize_m_o                                (debug_axis_awsizes),
    .fc_awburst_m_o                               (debug_axis_awbursts),
    .fc_awlock_m_o                                (debug_axis_awlocks),
    .fc_awcache_m_o                               (debug_axis_awcaches),
    .fc_awprot_m_o                                (debug_axis_awprots),
    .fc_awqos_m_o                                 (),
    .fc_awregion_m_o                              (),
    .fc_awuser_m_o                                (),
    .fc_awvalid_m_o                               (debug_axis_awvalids),
    .fc_awready_m_i                               (debug_axis_awreadys),
    .fc_awmmusid_m_o                              (debug_axis_awusers[9:2]),
    .fc_wdata_m_o                                 (debug_axis_wdatas), 
    .fc_wstrb_m_o                                 (debug_axis_wstrbs), 
    .fc_wlast_m_o                                 (debug_axis_wlasts),
    .fc_wuser_m_o                                 (),
    .fc_wvalid_m_o                                (debug_axis_wvalids),
    .fc_wready_m_i                                (debug_axis_wreadys),
    .fc_bid_m_i                                   (debug_axis_bids),
    .fc_bresp_m_i                                 (debug_axis_bresps),
    .fc_buser_m_i                                 (1'b0),
    .fc_bvalid_m_i                                (debug_axis_bvalids),
    .fc_bready_m_o                                (debug_axis_breadys),
    .fc_rid_m_i                                   (debug_axis_rids),
    .fc_rdata_m_i                                 (debug_axis_rdatas), 
    .fc_rresp_m_i                                 (debug_axis_rresps),
    .fc_rlast_m_i                                 (debug_axis_rlasts),
    .fc_ruser_m_i                                 (1'b0),
    .fc_rvalid_m_i                                (debug_axis_rvalids),
    .fc_rready_m_o                                (debug_axis_rreadys),
    .fc_awakeup_m_o                               (),

    .fctrl_bypass                                 (fctrl_bypass),

    .fc_tvalid_ds_o                               (fc_tvalid_ds),
    .fc_tready_ds_i                               (fc_tready_ds),
    .fc_tdata_ds_o                                (fc_tdata_ds),
    .fc_tkeep_ds_o                                (fc_tkeep_ds),
    .fc_tlast_ds_o                                (fc_tlast_ds),
    .fc_twakeup_ds_o                              (fc_twakeup_ds),
    .fc_tvalid_us_i                               (fc_tvalid_us),
    .fc_tready_us_o                               (fc_tready_us),
    .fc_tdata_us_i                                (fc_tdata_us),
    .fc_tkeep_us_i                                (fc_tkeep_us),
    .fc_tlast_us_i                                (fc_tlast_us),
    .fc_twakeup_us_i                              (fc_twakeup_us),
    
    .qreqn_dbgtop                                 (qreqn_internal_dbgtop[0]),
    .qacceptn_dbgtop                              (qacceptn_internal_dbgtop[0]),
    .qdeny_dbgtop                                 (qdeny_internal_dbgtop[0]),
    .qactive_dbgtop                               (qactive_internal_dbgtop[0]),
    
    .irq_gic73      (irq_gic73),
    .irq_gic72      (irq_gic72),
    
    .irq_soc_etr    (irq_soc_etr),
    .irq_soc_catu   (irq_soc_catu),
    .irq_host_stm   (irq_host_stm),
    .irq_host_etr   (irq_host_etr),
    .irq_host_catu  (irq_host_catu),
    
    .host_axiap_rom_revision     (host_axiap_rom_revision),
    .host_axiap_rom_part_number  (host_axiap_rom_part_number),
    .host_axiap_rom_jep106_id    (host_axiap_rom_jep106_id),
    .host_axiap_rom_eco_rev_and  (host_axiap_rom_eco_rev_and),
    .extdbg_rom_revision         (extdbg_rom_revision), 
    .extdbg_rom_part_number      (extdbg_rom_part_number),
    .extdbg_rom_jep106_id        (extdbg_rom_jep106_id),
    .extdbg_rom_eco_rev_and      (extdbg_rom_eco_rev_and), 
    .host_rom_revision           (host_rom_revision), 
    .host_rom_part_number        (host_rom_part_number),
    .host_rom_jep106_id          (host_rom_jep106_id),
    .host_rom_eco_rev_and        (host_rom_eco_rev_and)
  ); 
  
  
  
  
  pck600_clk_ctrl
 #(
  .NUM_Q_CHL        (INT_NUM_DBGCLK_QCH+NUM_DBGCLK_QCH),
  .NUM_QACTIVE_ONLY (INT_NUM_DBGCLK_QONLYCH),
  .HC_Q_CH_SYNC     (0),
  .PWR_Q_CH_SYNC    (0),
  .CLK_Q_CH_SYNC    (1),
  .ACTIVE_DENY_EN   (1)
 )
 u_clk_ctrl_dbgclk
 (
   .clk          (dbgclk_free),
   .reset_n      (dbgclk_resetn),
                 
   .dftcgen      (dftcgen),
 
   .hc_qreqn_i       (1'b1),
   .hc_qacceptn_o    (),
   .hc_qdeny_o       (),
   .hc_qactive_o     (),
 
   .pwr_qreqn_i      (1'b1),
   .pwr_qacceptn_o   (),
   .pwr_qdeny_o      (),
   .pwr_qactive_o    (),
 
   .clk_qreqn_o      ( {int_dbgclk_qreqn   ,dbgclk_qreqn    }),  
   .clk_qacceptn_i   ( {int_dbgclk_qacceptn,dbgclk_qacceptn }),
   .clk_qdeny_i      ( {int_dbgclk_qdeny   ,dbgclk_qdeny    }),
   .clk_qactive_i    ( {int_dbgclk_qactive_only, int_dbgclk_qactive ,dbgclk_qactive  }),
   
 
   .clk_force_i      (clkforce_st_dbgclk_force_st),
 
   .entry_delay_i    (dbgclk_entrydelay),
 
   .clken_o          (dbgclk_clken)
 
 );
  arm_element_clock_gate u_dbgclk_gate (
   .clk_in  (dbgclk_free),
   .enable  (dbgclk_clken),
   .clk_out (dbgclk_gated),
   .dftcgen (dftcgen)
 );

  arm_element_cdc_comb_mux2 u_clkgen_reset_nmbistreset_mux (
   .din1_async(dbgtopwarmresetn),
   .din2_async(nmbistreset),
   .sel       (dftdivsel),
   .dout_async(resetn_clk_gen)
  );

  e_clk_f1_top_dbgtop u_clk_gen_dbgclk (
   .RESETN                        (resetn_clk_gen),
   .REFCLK                        (refclk ),    
   .SYSPLL                        (sys_pll),    
   .DBGCLK                        (dbgclk_free),
   
   .DBGCLK_ON_SYSPLL_DIVRATIO     (dbgclk_on_syspll_divratio),
   .DBGCLK_ON_SYSPLL_DIVRATIO_CUR (dbgclk_on_syspll_divratio_cur),

   .DBGCLK_CLKSEL                 (dbgclk_clksel),
   .DBGCLK_CLKSEL_CUR             (dbgclk_clksel_cur),

   .DFTDBGCLKSEL                  (dftdbgclksel),
   .DFTDBGCLKSELEN                (dftdbgclkselen),
   .DFTDBGCLKDIVBYPASS_ON_SYSPLL  (dftdbgclkdivbypass),
   .DFTCGEN                       (dftcgen), 
   .DFTRSTDISABLE                 (dftrstdisable[1])  

  );
  assign dbgclkout = dbgclk_gated;
  
  arm_element_reset_sync u_dbgclkreset_sync (
  .clk             (dbgclk_free),         
  .resetn_async    (dbgtopwarmresetn),
  .resetn_sync     (dbgclk_resetn),   

  .dftrstdisable   (dftrstdisable[1])  
  );

  arm_element_reset_sync u_refclkreset_sync (
  .clk             (refclk),         
  .resetn_async    (dbgtopwarmresetn),
  .resetn_sync     (refclk_resetn),   

  .dftrstdisable   (dftrstdisable[1])  
  );
  
  
  genvar i;
  generate 
  for(i=0;i<16;i=i+1)
  begin : axiap_csyspwrupack_hostdbgpwr_sync
 
   arm_element_cdc_capt_sync u_axiap_csyspwrupack_hostdbgpwr_sync     ( 
        .clk(dbgclk_gated),   
        .nreset(dbgclk_resetn), 
        .d_async(axiap_csyspwrupack_hostdbgpwr[i]),     
        .q(axiap_csyspwrupack_hostdbgpwr_ss[i]) );
        
    arm_element_std_xor2 u_axiap_csyspwrupack_sync_qactive (   .A (axiap_csyspwrupack_hostdbgpwr[i]), 
                                                               .B (axiap_csyspwrupack_hostdbgpwr_ss[i]), 
                                                               .Y (int_dbgclk_qactive_only[QONLYIDX_AXIAP_SYNC + i]) 
                                                             );    
  
  end
  endgenerate
  
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_0 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (dbgen_dpauth),
    .q       (dbgen_dpauth_ss)
  );
  
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_1 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (niden_dpauth),
    .q       (niden_dpauth_ss)
  );

    arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_2 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (spiden_dpauth),
    .q       (spiden_dpauth_ss)
  );
  
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_3 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (spniden_dpauth),
    .q       (spniden_dpauth_ss)
  );  

  
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_4 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (dbgen_tpiuauth),
    .q       (dbgen_tpiuauth_ss)
  );

    arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_5 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (niden_tpiuauth),
    .q       (niden_tpiuauth_ss)
  );
  
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_6 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (spiden_tpiuauth),
    .q       (spiden_tpiuauth_ss)
  );

  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_7 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (chen_tpiuauth),
    .q       (chen_tpiuauth_ss)
  );  

  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_8 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (dbgen_counterauth),
    .q       (dbgen_counterauth_ss)
  );

  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_9 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (niden_counterauth),
    .q       (niden_counterauth_ss)
  );
  
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_10 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (chen_counterauth),
    .q       (chen_counterauth_ss)
  );  
  
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_11 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (dbgen_hostaxiauth),
    .q       (dbgen_hostaxiauth_ss)
  );

    arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_12 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (niden_hostaxiauth),
    .q       (niden_hostaxiauth_ss)
  );     
  
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_13 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (spiden_hostaxiauth),
    .q       (spiden_hostaxiauth_ss)
  );     
  
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_14 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (spniden_hostaxiauth),
    .q       (spniden_hostaxiauth_ss)
  );  
  
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_15 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (ap_en_hostextauth),
    .q       (ap_en_hostextauth_ss)
  );

  
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_17 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (ap_secure_en_hostextauth),
    .q       (ap_secure_en_hostextauth_ss)
  );     
  
   
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_19 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (dbgen_hostauth),
    .q       (dbgen_hostauth_ss)
  );

    arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_20 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (niden_hostauth),
    .q       (niden_hostauth_ss)
  );     
  
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_21 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (spiden_hostauth),
    .q       (spiden_hostauth_ss)
  );     
  
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_22 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (spniden_hostauth),
    .q       (spniden_hostauth_ss)
  );

  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_23 (
    .clk     (dbgclk_gated),
    .nreset  (dbgclk_resetn),
    .d_async (chen_hostauth),
    .q       (chen_hostauth_ss)
  );   
  
  arm_element_std_xor2 u_qactive_dbgen_dpauth             (  .A (dbgen_dpauth),       .B (dbgen_dpauth_ss),                    .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC +  0]) );    
  arm_element_std_xor2 u_qactive_niden_dpauth             (  .A (niden_dpauth),       .B (niden_dpauth_ss),                    .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC +  1]) );    
  arm_element_std_xor2 u_qactive_spiden_dpauth            (  .A (spiden_dpauth),      .B (spiden_dpauth_ss),                   .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC +  2]) );    
  arm_element_std_xor2 u_qactive_spniden_dpauth           (  .A (spniden_dpauth),     .B (spniden_dpauth_ss),                  .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC +  3]) );    
  arm_element_std_xor2 u_qactive_dbgen_tpiuauth           (  .A (dbgen_tpiuauth),     .B (dbgen_tpiuauth_ss),                  .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC +  4]) );    
  arm_element_std_xor2 u_qactive_niden_tpiuauth           (  .A (niden_tpiuauth),     .B (niden_tpiuauth_ss),                  .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC +  5]) );    
  arm_element_std_xor2 u_qactive_spiden_tpiuauth          (  .A (spiden_tpiuauth),    .B (spiden_tpiuauth_ss),                 .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC +  6]) );    
  arm_element_std_xor2 u_qactive_chen_tpiuauth            (  .A (chen_tpiuauth),      .B (chen_tpiuauth_ss),                   .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC +  7]) );    
  arm_element_std_xor2 u_qactive_dbgen_counterauth        (  .A (dbgen_counterauth),  .B (dbgen_counterauth_ss),               .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC +  8]) );    
  arm_element_std_xor2 u_qactive_niden_counterauth        (  .A (niden_counterauth),  .B (niden_counterauth_ss),               .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC +  9]) );    
  arm_element_std_xor2 u_qactive_chen_counterauth         (  .A (chen_counterauth),   .B (chen_counterauth_ss),                .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC + 10]) );    
  arm_element_std_xor2 u_qactive_dbgen_hostaxiauth        (  .A (dbgen_hostaxiauth),  .B (dbgen_hostaxiauth_ss),               .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC + 11]) );    
  arm_element_std_xor2 u_qactive_niden_hostaxiauth        (  .A (niden_hostaxiauth),  .B (niden_hostaxiauth_ss),               .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC + 12]) );    
  arm_element_std_xor2 u_qactive_spiden_hostaxiauth       (  .A (spiden_hostaxiauth), .B (spiden_hostaxiauth_ss),              .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC + 13]) );    
  arm_element_std_xor2 u_qactive_spniden_hostaxiauth      (  .A (spniden_hostaxiauth),.B (spniden_hostaxiauth_ss),             .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC + 14]) );    
  arm_element_std_xor2 u_qactive_ap_en_hostextauth        (  .A (ap_en_hostextauth),  .B (ap_en_hostextauth_ss),               .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC + 15]) );    
  arm_element_std_xor2 u_qactive_ap_secure_en_hostextauth (  .A (ap_secure_en_hostextauth),  .B (ap_secure_en_hostextauth_ss), .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC + 16]) );    
  arm_element_std_xor2 u_qactive_dbgen_hostauth           (  .A (dbgen_hostauth),     .B (dbgen_hostauth_ss),                  .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC + 17]) );    
  arm_element_std_xor2 u_qactive_niden_hostauth           (  .A (niden_hostauth),     .B (niden_hostauth_ss),                  .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC + 18]) );    
  arm_element_std_xor2 u_qactive_spiden_hostauth          (  .A (spiden_hostauth),    .B (spiden_hostauth_ss),                 .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC + 19]) );    
  arm_element_std_xor2 u_qactive_spniden_hostauth         (  .A (spniden_hostauth),   .B (spniden_hostauth_ss),                .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC + 20]) );    
  arm_element_std_xor2 u_qactive_chen_hostauth            (  .A (chen_hostauth),      .B (chen_hostauth_ss),                   .Y (int_dbgclk_qactive_only[QONLYIDX_AUTH_SYNC + 21]) );    

endmodule
