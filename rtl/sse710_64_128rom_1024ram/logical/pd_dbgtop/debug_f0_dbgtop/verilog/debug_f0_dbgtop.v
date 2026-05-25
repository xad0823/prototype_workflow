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

module debug_f0_dbgtop #(parameter
    ATB_DATA_WIDTH               = 32,
    AXI_ADDR_WIDTH               = 32,
    FC_AXIID_WIDTH               = 4 , 
    FC_AXIUSER_AR_WIDTH          = 1,  
    FC_ADDR_WIDTH                = 32, 
    FC_MST_ID_WIDTH              = 8,  
    FC_AXIUSER_AW_WIDTH          = 1,  
    FC_AXIDATA_WIDTH             = 64, 
    FC_AXIUSER_W_WIDTH           = 1,  
    FC_AXIUSER_R_WIDTH           = 1,  
    FC_AXIUSER_B_WIDTH           = 1,  
    EXT_SYS0_ROM_ENTRY           = 0,
    EXT_SYS1_ROM_ENTRY           = 0,
    STM_ADDR_WIDTH               = 32,
    STM_AXI_ID_WIDTH             = 4,
    STM_AWUSER_WIDTH             = 10,    
    DBG_FC_ID                    = 4'hd,
    HOST_EXP_ROM_ENTRY           = 0
) (
    
    input  wire                             dbgclk_gated,
    input  wire                             dbgclk_resetn,  
    input  wire                             refclk,
    input  wire                             refclk_resetn,

    input  wire                             fctrl_bypass,

    input  wire [16:0]                      dbgclk_qreqn,
    output wire [16:0]                      dbgclk_qacceptn,
    output wire [16:0]                      dbgclk_qdeny,
    output wire [16:0]                      dbgclk_qactive,
    output wire [4:0]                       dbgclk_qactive_only,


    input  wire                             dftcgen,

    input  wire                             dp_abort,

    input  wire  [3:0]                      extsys0_channel_in,
    output wire  [3:0]                      extsys0_channel_out,
    input  wire  [3:0]                      extsys1_channel_in,
    output wire  [3:0]                      extsys1_channel_out,

    input  wire  [3:0]                      secenc_channel_in,
    output wire  [3:0]                      secenc_channel_out,    

    input  wire [63:0]                      tsvalueb_refclk,

    output wire  [3:0]                      hostcpuctichin,
    input  wire  [3:0]                      hostcpuctichout,
    input  wire  [3:0]                      hostctiexpin,
    output wire  [3:0]                      hostctiexpout,



    input  wire                             hostcputrace_atwakeup_s,
    input  wire  [6:0]                      hostcputrace_atid_s,
    input  wire  [1:0]                      hostcputrace_atbytes_s,
    input  wire [31:0]                      hostcputrace_atdata_s,
    input  wire                             hostcputrace_atvalid_s,
    output wire                             hostcputrace_atready_s,
    output wire                             hostcputrace_afvalid_s,
    input  wire                             hostcputrace_afready_s,
    output wire                             hostcputrace_syncreq_s,

    input  wire                             hostdbgtraceexp_atwakeup_s,
    input  wire  [6:0]                      hostdbgtraceexp_atid_s,
    input  wire  [1:0]                      hostdbgtraceexp_atbytes_s,
    input  wire [31:0]                      hostdbgtraceexp_atdata_s,
    input  wire                             hostdbgtraceexp_atvalid_s,
    output wire                             hostdbgtraceexp_atready_s,
    output wire                             hostdbgtraceexp_afvalid_s,
    input  wire                             hostdbgtraceexp_afready_s,
    output wire                             hostdbgtraceexp_syncreq_s,

    input  wire                             extsys0_atwakeup_s,
    input  wire  [6:0]                      extsys0_atid_s,
    input  wire  [1:0]                      extsys0_atbytes_s,
    input  wire [31:0]                      extsys0_atdata_s,
    input  wire                             extsys0_atvalid_s,
    output wire                             extsys0_atready_s,
    output wire                             extsys0_afvalid_s,
    input  wire                             extsys0_afready_s,
    output wire                             extsys0_syncreq_s,

    input  wire                             extsys1_atwakeup_s,
    input  wire  [6:0]                      extsys1_atid_s,
    input  wire  [1:0]                      extsys1_atbytes_s,
    input  wire [31:0]                      extsys1_atdata_s,
    input  wire                             extsys1_atvalid_s,
    output wire                             extsys1_atready_s,
    output wire                             extsys1_afvalid_s,
    input  wire                             extsys1_afready_s,
    output wire                             extsys1_syncreq_s,

    output wire                             secure_enclave_pwakeup_m,
    output wire                             secure_enclave_psel_m,
    output wire                             secure_enclave_penable_m,
    output wire                             secure_enclave_pwrite_m,
    output wire  [2:0]                      secure_enclave_pprot_m,
    output wire [15:0]                      secure_enclave_paddr_m,
    output wire [31:0]                      secure_enclave_pwdata_m,
    input  wire                             secure_enclave_pready_m,
    input  wire                             secure_enclave_pslverr_m,
    input  wire [31:0]                      secure_enclave_prdata_m,
    
    output wire                             extsys0_dbgapb_pwakeup_m,
    output wire                             extsys0_dbgapb_psel_m,
    output wire                             extsys0_dbgapb_penable_m,
    output wire                             extsys0_dbgapb_pwrite_m,
    output wire  [2:0]                      extsys0_dbgapb_pprot_m,
    output wire [19:0]                      extsys0_dbgapb_paddr_m,
    output wire [31:0]                      extsys0_dbgapb_pwdata_m,
    input  wire                             extsys0_dbgapb_pready_m,
    input  wire                             extsys0_dbgapb_pslverr_m,
    input  wire [31:0]                      extsys0_dbgapb_prdata_m,

    output wire                             extsys1_dbgapb_pwakeup_m,
    output wire                             extsys1_dbgapb_psel_m,
    output wire                             extsys1_dbgapb_penable_m,
    output wire                             extsys1_dbgapb_pwrite_m,
    output wire  [2:0]                      extsys1_dbgapb_pprot_m,
    output wire [19:0]                      extsys1_dbgapb_paddr_m,
    output wire [31:0]                      extsys1_dbgapb_pwdata_m,
    input  wire                             extsys1_dbgapb_pready_m,
    input  wire                             extsys1_dbgapb_pslverr_m,
    input  wire [31:0]                      extsys1_dbgapb_prdata_m,

    output wire                             hostdbgexp_pwakeup_m,
    output wire                             hostdbgexp_psel_m,
    output wire                             hostdbgexp_penable_m,
    output wire                             hostdbgexp_pwrite_m,
    output wire  [2:0]                      hostdbgexp_pprot_m,
    output wire [31:0]                      hostdbgexp_paddr_m,
    output wire [31:0]                      hostdbgexp_pwdata_m,
    input  wire                             hostdbgexp_pready_m,
    input  wire                             hostdbgexp_pslverr_m,
    input  wire [31:0]                      hostdbgexp_prdata_m,


    output wire                             u_soc_cti_event_out_6_to_u_dp_eventstat,

    input  wire                             apbdbg_pwakeup_s,
    input  wire                             apbdbg_psel_s,
    input  wire                             apbdbg_penable_s,
    input  wire                             apbdbg_pwrite_s,
    input  wire  [2:0]                      apbdbg_pprot_s,
    input  wire [31:0]                      apbdbg_paddr_s,
    input  wire [31:0]                      apbdbg_pwdata_s,
    output wire                             apbdbg_pready_s,
    output wire                             apbdbg_pslverr_s,
    output wire [31:0]                      apbdbg_prdata_s,


    input  wire                             hostdbg_pwakeup_m_to_u_decoder_host_pwakeup_s,
    input  wire                             hostdbg_psel_m_to_u_decoder_host_psel_s,
    input  wire                             hostdbg_penable_m_to_u_decoder_host_penable_s,
    input  wire                             hostdbg_pwrite_m_to_u_decoder_host_pwrite_s,
    input  wire  [2:0]                      hostdbg_pprot_m_to_u_decoder_host_pprot_s,
    input  wire [26:0]                      hostdbg_paddr_m_to_u_decoder_host_paddr_s,
    input  wire [31:0]                      hostdbg_pwdata_m_to_u_decoder_host_pwdata_s,
    output wire                             hostdbg_pready_m_to_u_decoder_host_pready_s,
    output wire                             hostdbg_pslverr_m_to_u_decoder_host_pslverr_s,
    output wire [31:0]                      hostdbg_prdata_m_to_u_decoder_host_prdata_s,

    output wire                             cluster_debug_adb_pwakeup_m,
    output wire                             cluster_debug_adb_psel_m,
    output wire                             cluster_debug_adb_penable_m,
    output wire                             cluster_debug_adb_pwrite_m,
    output wire  [2:0]                      cluster_debug_adb_pprot_m,
    output wire [31:0]                      cluster_debug_adb_paddr_m,
    output wire [31:0]                      cluster_debug_adb_pwdata_m,
    input  wire                             cluster_debug_adb_pready_m,
    input  wire                             cluster_debug_adb_pslverr_m,
    input  wire [31:0]                      cluster_debug_adb_prdata_m,

    output wire [15:0]                      axiap_csyspwrupreq_hostdbgpwr,
    input  wire [15:0]                      axiap_csyspwrupack_hostdbgpwr,
    output wire [3:0]                      axiap_csyspwrupreq_internal,
    input  wire [3:0]                      axiap_csyspwrupack_internal,
    output wire [2:0]                       extdbg_cdbgpwrupreq,
    input  wire [2:0]                       extdbg_cdbgpwrupack,
    output wire                             host_cdbgpwrupreq,
    input  wire                             host_cdbgpwrupack,

    input  wire [STM_AXI_ID_WIDTH-1:0]      stm_axi_arids,        
    input  wire [STM_ADDR_WIDTH-1:0]        stm_axi_araddrs,      
    input  wire [7:0]                       stm_axi_arlens,       
    input  wire [2:0]                       stm_axi_arsizes,      
    input  wire [1:0]                       stm_axi_arbursts,     
    input  wire                             stm_axi_arlocks,      
    input  wire [3:0]                       stm_axi_arcaches,     
    input  wire [2:0]                       stm_axi_arprots,      
    input  wire                             stm_axi_arvalids,     
    output wire                             stm_axi_arreadys,     

    input  wire                             stm_axi_rreadys,      
    output wire [STM_AXI_ID_WIDTH-1:0]      stm_axi_rids,         
    output wire [63:0]                      stm_axi_rdatas,       
    output wire [1:0]                       stm_axi_rresps,       
    output wire                             stm_axi_rlasts,       
    output wire                             stm_axi_rvalids,      

    input  wire [STM_AXI_ID_WIDTH-1:0]      stm_axi_awids,        
    input  wire [STM_ADDR_WIDTH-1:0]        stm_axi_awaddrs,      
    input  wire [7:0]                       stm_axi_awlens,       
    input  wire [2:0]                       stm_axi_awsizes,      
    input  wire [1:0]                       stm_axi_awbursts,     
    input  wire [STM_AWUSER_WIDTH-1:0]      stm_axi_awusers,      
    input  wire                             stm_axi_awlocks,      
    input  wire [3:0]                       stm_axi_awcaches,     
    input  wire [2:0]                       stm_axi_awprots,      
    input  wire                             stm_axi_awvalids,     
    output wire                             stm_axi_awreadys,     

    input  wire [63:0]                      stm_axi_wdatas,       
    input  wire [7:0]                       stm_axi_wstrbs,       
    input  wire                             stm_axi_wlasts,       
    input  wire                             stm_axi_wvalids,      
    output wire                             stm_axi_wreadys,      

    input  wire                             stm_axi_breadys,      
    output wire [STM_AXI_ID_WIDTH-1:0]      stm_axi_bids,         
    output wire [1:0]                       stm_axi_bresps,       
    output wire                             stm_axi_bvalids,      

    input wire                              stm_drready,          
    input wire                              stm_davalid,          
    input wire [1:0]                        stm_datype,           
    output wire                             stm_drvalid,          
    output wire [1:0]                       stm_drtype,           
    output wire                             stm_drlast,           
    output wire                             stm_daready,          

    input  wire                             dbgen_tpiuauth_ss,
    input  wire                             niden_tpiuauth_ss,
    input  wire                             spiden_tpiuauth_ss,
    input  wire                             chen_tpiuauth_ss, 
    input  wire                             ap_en_hostextauth_ss,
    input  wire                             ap_secure_en_hostextauth_ss,
    input  wire                             dbgen_hostaxiauth_ss,
    input  wire                             niden_hostaxiauth_ss,
    input  wire                             spiden_hostaxiauth_ss,
    input  wire                             spniden_hostaxiauth_ss,
    input  wire                             dbgen_dpauth_ss,
    input  wire                             niden_dpauth_ss,
    input  wire                             spiden_dpauth_ss,
    input  wire                             spniden_dpauth_ss,
    input  wire                             dbgen_hostauth_ss,
    input  wire                             niden_hostauth_ss,
    input  wire                             spiden_hostauth_ss,
    input  wire                             spniden_hostauth_ss,
    input  wire                             chen_hostauth_ss, 
    input  wire                             dbgen_counterauth_ss,
    input  wire                             niden_counterauth_ss,
    input  wire                             chen_counterauth_ss, 



    input  wire                             traceclk_in,
    input  wire                             treset_n,
    output wire                             traceclk,
    output wire [31:0]                      tracedata,
    output wire                             tracectl,
    input  wire                             tpctl_valid,
    input  wire [4:0]                       tp_maxdatasize,

    output wire [FC_AXIID_WIDTH-1:0]        fc_arid_m_o,
    output wire [FC_ADDR_WIDTH-1:0]         fc_araddr_m_o,
    output wire [7:0]                       fc_arlen_m_o,
    output wire [2:0]                       fc_arsize_m_o,
    output wire [1:0]                       fc_arburst_m_o,
    output wire                             fc_arlock_m_o,
    output wire [3:0]                       fc_arcache_m_o,
    output wire [2:0]                       fc_arprot_m_o,
    output wire [3:0]                       fc_arqos_m_o,
    output wire [3:0]                       fc_arregion_m_o,
    output wire [FC_AXIUSER_AR_WIDTH-1:0]   fc_aruser_m_o,
    output wire                             fc_arvalid_m_o,
    input  wire                             fc_arready_m_i,
    output wire [FC_MST_ID_WIDTH-1:0]       fc_armmusid_m_o,

    output wire [FC_AXIID_WIDTH-1:0]        fc_awid_m_o,
    output wire [FC_ADDR_WIDTH-1:0]         fc_awaddr_m_o,
    output wire [7:0]                       fc_awlen_m_o,
    output wire [2:0]                       fc_awsize_m_o,
    output wire [1:0]                       fc_awburst_m_o,
    output wire                             fc_awlock_m_o,
    output wire [3:0]                       fc_awcache_m_o,
    output wire [2:0]                       fc_awprot_m_o,
    output wire [3:0]                       fc_awqos_m_o,
    output wire [3:0]                       fc_awregion_m_o,
    output wire [FC_AXIUSER_AW_WIDTH-1:0]   fc_awuser_m_o,
    output wire                             fc_awvalid_m_o,
    input  wire                             fc_awready_m_i,
    output wire [FC_MST_ID_WIDTH-1:0]       fc_awmmusid_m_o,

    output wire [FC_AXIDATA_WIDTH-1:0]      fc_wdata_m_o,
    output wire [FC_AXIDATA_WIDTH/8-1:0]    fc_wstrb_m_o,
    output wire                             fc_wlast_m_o,
    output wire [FC_AXIUSER_W_WIDTH-1:0]    fc_wuser_m_o,
    output wire                             fc_wvalid_m_o,
    input  wire                             fc_wready_m_i,

    input  wire [FC_AXIID_WIDTH-1:0]        fc_bid_m_i,
    input  wire [1:0]                       fc_bresp_m_i,
    input  wire [FC_AXIUSER_B_WIDTH-1:0]    fc_buser_m_i,
    input  wire                             fc_bvalid_m_i,
    output wire                             fc_bready_m_o,

    input  wire [FC_AXIID_WIDTH-1:0]        fc_rid_m_i,
    input  wire [FC_AXIDATA_WIDTH-1:0]      fc_rdata_m_i,
    input  wire [1:0]                       fc_rresp_m_i,
    input  wire                             fc_rlast_m_i,
    input  wire [FC_AXIUSER_R_WIDTH-1:0]    fc_ruser_m_i,
    input  wire                             fc_rvalid_m_i,
    output wire                             fc_rready_m_o,

    output wire                             fc_awakeup_m_o,




    output wire                             fc_tvalid_ds_o,
    input  wire                             fc_tready_ds_i,
    output wire [31:0]                      fc_tdata_ds_o,
    output wire [3:0]                       fc_tkeep_ds_o,
    output wire                             fc_tlast_ds_o,
    output wire                             fc_twakeup_ds_o,

    input  wire                             fc_tvalid_us_i,
    output wire                             fc_tready_us_o,
    input  wire [31:0]                      fc_tdata_us_i,
    input  wire [3:0]                       fc_tkeep_us_i,
    input  wire                             fc_tlast_us_i,
    input  wire                             fc_twakeup_us_i,


    input  wire                             qreqn_dbgtop,
    output wire                             qacceptn_dbgtop,
    output wire                             qdeny_dbgtop,
    output wire                             qactive_dbgtop,



    input  wire [63:0]                      host_cti_devaff,
    input  wire [63:0]                      soc_cti_devaff,
    input  wire [63:0]                      counter_cti_devaff,

    output wire                             irq_gic73,
    output wire                             irq_gic72,

    output wire                             irq_soc_etr,
    output wire                             irq_soc_catu,
    output wire                             irq_host_stm,
    output wire                             irq_host_etr,
    output wire                             irq_host_catu,

    output wire                             s32k_cnt_restart,
    output wire                             s32k_cnt_halt,
    output wire                             refclk_cnt_restart,
    output wire                             refclk_cnt_halt,
    
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
    input wire  [11:0]                      host_rom_part_number      


  );


    localparam        HOST_CTI_NUM_EVENT_SLAVES        = 7;
    localparam        HOST_CTI_NUM_EVENT_MASTERS       = 6;
    localparam        HOST_CTI_SW_HANDSHAKE            = 0;
    localparam        HOST_CTI_EXT_MUX_NUM             = 0;
    localparam        HOST_CTI_FF_SYNC_DEPTH           = 2;
    localparam        HOST_CTI_REVAND                  = 0;
    localparam        HOST_CTI_EVENT_IN_LEVEL          = 7'b0110000;

    localparam        SOC_CTI_NUM_EVENT_SLAVES         = 4;
    localparam        SOC_CTI_NUM_EVENT_MASTERS        = 5;
    localparam        SOC_CTI_SW_HANDSHAKE             = 5'b00100;
    localparam        SOC_CTI_EXT_MUX_NUM              = 0;
    localparam        SOC_CTI_FF_SYNC_DEPTH            = 2;
    localparam        SOC_CTI_REVAND                   = 0;
    localparam        SOC_CTI_EVENT_IN_LEVEL           = 4'b0110;

    localparam        COUNTER_CTI_NUM_EVENT_SLAVES     = 1;
    localparam        COUNTER_CTI_NUM_EVENT_MASTERS    = 4;
    localparam        COUNTER_CTI_SW_HANDSHAKE         = 0;
    localparam        COUNTER_CTI_EXT_MUX_NUM          = 0;
    localparam        COUNTER_CTI_FF_SYNC_DEPTH        = 2;
    localparam        COUNTER_CTI_REVAND               = 0;
    localparam        COUNTER_CTI_EVENT_IN_LEVEL       = 0;

    localparam        SOC_CTM_NUM_INTERFACES           = 6; 
    localparam        HOST_CTM_NUM_INTERFACES          = 4;

    localparam        HOST_ETR_WBUFFER_DEPTH           = 16;
    localparam        HOST_ETR_ATB_DATA_WIDTH          = ATB_DATA_WIDTH;
    localparam        HOST_ETR_AXI_ADDR_WIDTH          = AXI_ADDR_WIDTH;




    localparam        HOST_FUNNEL_NUM_ATB_SLAVES       = 3;
    localparam        SOC_FUNNEL_NUM_ATB_SLAVES        = 3; 

    localparam        SOC_ETR_WBUFFER_DEPTH            = 16;
    localparam        SOC_ETR_ATB_DATA_WIDTH           = ATB_DATA_WIDTH;
    localparam        SOC_ETR_AXI_ADDR_WIDTH           = AXI_ADDR_WIDTH;

    localparam        EXTDBGBUS_MASTERS                = 14;
    localparam        HOST_MASTERS                     = 9;



    localparam                          HOST_AXIAP_ROM_ENTRY_PRESENT = 1'b1;

    localparam                          EXTDBG_ROM_ENTRIES       = 12;
    localparam [EXTDBG_ROM_ENTRIES-1:0] EXTDBG_ROM_ENTRY_PRESENT = {EXTDBG_ROM_ENTRIES {1'b1}};

    localparam                          HOST_ROM_ENTRIES         = 8;
    localparam [HOST_ROM_ENTRIES-1:0]   HOST_ROM_ENTRY_PRESENT   = {HOST_ROM_ENTRIES {1'b1}};

    wire                             u_host_etr_flushcomp_to_u_host_cti_event_in_10;
    wire                             u_host_etr_acqcomp_to_u_host_cti_event_in_9;
    wire                             u_host_etr_full_to_u_host_cti_event_in_8;
    wire                             u_host_stm_trigoutspte_to_u_host_cti_event_in_7;
    wire                             u_host_stm_trigoutsw_to_u_host_cti_event_in_6;
    wire                             u_host_stm_trigouthete_to_u_host_cti_event_in_5;
    wire                             u_host_stm_asyncout_to_u_host_cti_event_in_4;
    wire                             u_soc_ctm_channel_out_3_to_u_host_cti_event_in_3;
    wire                             u_soc_ctm_channel_out_2_to_u_host_cti_event_in_2;
    wire                             u_soc_ctm_channel_out_1_to_u_host_cti_event_in_1;
    wire                             u_soc_ctm_channel_out_0_to_u_host_cti_event_in_0;
    wire                             u_host_cti_event_out_7_to_u_host_etr_flushin;
    wire                             u_host_cti_event_out_6_to_u_host_etr_trigin;
    wire                             u_host_cti_event_out_5_to_u_host_stm_hwevents2;
    wire                             u_host_cti_event_out_4_to_u_host_stm_hwevents0;
    
    
    
    wire [3:0]                        u_host_cti_out_to_host_ctm_in;    
    wire [3:0]                        u_host_ctm_out_to_host_gate_in;
    wire [3:0]                        u_host_gate_out_to_soc_ctm_in_3;    
    wire [3:0]                        u_soc_ctm_out_3_to_host_gate_in;
    wire [3:0]                        u_host_gate_out_to_host_ctm_in;
    wire [3:0]                        u_host_ctm_out_to_host_cti_in;
                                 
    
    wire [3:0]                         u_counter_cti_out_to_counter_gate_in;    
    wire [3:0]                         u_counter_gate_out_to_soc_ctm_in_4;  
    wire [3:0]                         u_soc_ctm_out_4_to_counter_gate_in;    
    wire [3:0]                         u_counter_gate_out_to_counter_cti_in;
    
    wire [3:0]                         u_soc_cti_out_to_tpiu_gate_in;    
    wire [3:0]                         u_tpiu_gate_out_to_soc_ctm_in_0;    
    wire [3:0]                         u_soc_ctm_out_0_to_tpiu_gate_in;    
    wire [3:0]                         u_tpiu_gate_out_to_soc_cti_in;
        
    wire                             u_soc_etr_flushcomp_to_u_soc_cti_event_in_7;
    wire                             u_soc_etr_acqcomp_to_u_soc_cti_event_in_6;
    wire                             u_soc_etr_full_to_u_soc_cti_event_in_5;
    wire                             u_soc_tpiu_flushcomp_to_u_soc_cti_event_in_4;
    wire                             u_soc_ctm_channel_out_7_to_u_soc_cti_event_in_3;
    wire                             u_soc_ctm_channel_out_6_to_u_soc_cti_event_in_2;
    wire                             u_soc_ctm_channel_out_5_to_u_soc_cti_event_in_1;
    wire                             u_soc_ctm_channel_out_4_to_u_soc_cti_event_in_0;

    wire                             u_soc_cti_event_out_8_to_u_soc_etr_trigin;
    wire                             u_soc_cti_event_out_7_to_u_soc_etr_flushin;
    wire                             u_soc_cti_event_out_5_to_u_soc_tpiu_flushin;
    wire                             u_soc_cti_event_out_4_to_u_soc_tpiu_trigin;
    wire                             u_soc_cti_event_out_3_to_u_soc_ctm_channel_in_7;
    wire                             u_soc_cti_event_out_2_to_u_soc_ctm_channel_in_6;
    wire                             u_soc_cti_event_out_1_to_u_soc_ctm_channel_in_5;
    wire                             u_soc_cti_event_out_0_to_u_soc_ctm_channel_in_4;

    wire                             u_soc_ctm_channel_out_11_to_u_counter_cti_event_in_3;
    wire                             u_soc_ctm_channel_out_10_to_u_counter_cti_event_in_2;
    wire                             u_soc_ctm_channel_out_9_to_u_counter_cti_event_in_1;
    wire                             u_soc_ctm_channel_out_8_to_u_counter_cti_event_in_0;

    wire                             u_host_cti_channel_out_3_to_u_host_ctm_channel_in_7;
    wire                             u_host_cti_channel_out_2_to_u_host_ctm_channel_in_6;
    wire                             u_host_cti_channel_out_1_to_u_host_ctm_channel_in_5;
    wire                             u_host_cti_channel_out_0_to_u_host_ctm_channel_in_4;
    wire                             u_host_ctm_channel_out_7_to_u_host_cti_channel_in_3;
    wire                             u_host_ctm_channel_out_6_to_u_host_cti_channel_in_2;
    wire                             u_host_ctm_channel_out_5_to_u_host_cti_channel_in_1;
    wire                             u_host_ctm_channel_out_4_to_u_host_cti_channel_in_0;

    wire                             u_host_replicator_atwakeup_m_to_u_host_etr_atwakeup_s;
    wire [6:0]                       u_host_replicator_atid_m_to_u_host_etr_atid_s;
    wire [1:0]                       u_host_replicator_atbytes_m_to_u_host_etr_atbytes_s;
    wire [HOST_ETR_ATB_DATA_WIDTH-1:0]   u_host_replicator_atdata_m_to_u_host_etr_atdata_s;
    wire                             u_host_replicator_atvalid_m_to_u_host_etr_atvalid_s;
    wire                             u_host_replicator_atready_m_to_u_host_etr_atready_s;
    wire                             u_host_replicator_afvalid_m_to_u_host_etr_afvalid_s;
    wire                             u_host_replicator_afready_m_to_u_host_etr_afready_s;
    wire                             u_host_replicator_syncreq_m_to_u_host_etr_syncreq_s;

    wire                             u_host_replicator_atwakeup_m_to_u_soc_funnel_atwakeup_s;
    wire [6:0]                       u_host_replicator_atid_m_to_u_soc_funnel_atid_s;
    wire [1:0]                       u_host_replicator_atbytes_m_to_u_soc_funnel_atbytes_s;
    wire [HOST_ETR_ATB_DATA_WIDTH-1:0]   u_host_replicator_atdata_m_to_u_soc_funnel_atdata_s;
    wire                             u_host_replicator_atvalid_m_to_u_soc_funnel_atvalid_s;
    wire                             u_host_replicator_atready_m_to_u_soc_funnel_atready_s;
    wire                             u_host_replicator_afvalid_m_to_u_soc_funnel_afvalid_s;
    wire                             u_host_replicator_afready_m_to_u_soc_funnel_afready_s;
    wire                             u_host_replicator_syncreq_m_to_u_soc_funnel_syncreq_s;

    wire                             u_host_funnel_atwakeup_m_to_u_host_atbbuffer_atwakeup_s;
    wire [6:0]                       u_host_funnel_atid_m_to_u_host_atbbuffer_atid_s;
    wire [1:0]                       u_host_funnel_atbytes_m_to_u_host_atbbuffer_atbytes_s;
    wire [31:0]                      u_host_funnel_atdata_m_to_u_host_atbbuffer_atdata_s;
    wire                             u_host_funnel_atvalid_m_to_u_host_atbbuffer_atvalid_s;
    wire                             u_host_funnel_atready_m_to_u_host_atbbuffer_atready_s;
    wire                             u_host_funnel_afready_m_to_u_host_atbbuffer_afready_s;
    wire                             u_host_funnel_afvalid_m_to_u_host_atbbuffer_afvalid_s;
    wire                             u_host_funnel_syncreq_m_to_u_host_atbbuffer_syncreq_s;
    wire                             u_host_atbbuffer_atwakeup_m_to_u_host_replicator_atwakeup_s;
    wire [6:0]                       u_host_atbbuffer_atid_m_to_u_host_replicator_atid_s;
    wire [1:0]                       u_host_atbbuffer_atbytes_m_to_u_host_replicator_atbytes_s;
    wire [31:0]                      u_host_atbbuffer_atdata_m_to_u_host_replicator_atdata_s;
    wire                             u_host_atbbuffer_atvalid_m_to_u_host_replicator_atvalid_s;
    wire                             u_host_atbbuffer_atready_m_to_u_host_replicator_atready_s;
    wire                             u_host_atbbuffer_afready_m_to_u_host_replicator_afready_s;
    wire                             u_host_atbbuffer_afvalid_m_to_u_host_replicator_afvalid_s;
    wire                             u_host_atbbuffer_syncreq_m_to_u_host_replicator_syncreq_s;

    wire                             u_soc_funnel_atwakeup_m_to_u_soc_replicator_atwakeup_s;
    wire [6:0]                       u_soc_funnel_atid_m_to_u_soc_replicator_atid_s;
    wire [1:0]                       u_soc_funnel_atbytes_m_to_u_soc_replicator_atbytes_s;
    wire [31:0]                      u_soc_funnel_atdata_m_to_u_soc_replicator_atdata_s;
    wire                             u_soc_funnel_atvalid_m_to_u_soc_replicator_atvalid_s;
    wire                             u_soc_funnel_atready_m_to_u_soc_replicator_atready_s;
    wire                             u_soc_funnel_afvalid_m_to_u_soc_replicator_afvalid_s;
    wire                             u_soc_funnel_afready_m_to_u_soc_replicator_afready_s;
    wire                             u_soc_funnel_syncreq_m_to_u_soc_replicator_syncreq_s;

    wire                             u_expander_extdbgbus_pwakeup_m_to_u_extdbg_rom_not_used;
    wire                             u_expander_extdbgbus_psel_m_to_u_extdbg_rom_psel_s;
    wire                             u_expander_extdbgbus_penable_m_to_u_extdbg_rom_penable_s;
    wire                             u_expander_extdbgbus_pwrite_m_to_u_extdbg_rom_pwrite_s;
    wire [11:0]                      u_expander_extdbgbus_paddr_m_to_u_extdbg_rom_paddr_s;
    wire [31:0]                      u_expander_extdbgbus_pwdata_m_to_u_extdbg_rom_pwdata_s;
    wire                             u_expander_extdbgbus_pready_m_to_u_extdbg_rom_pready_s;
    wire                             u_expander_extdbgbus_pslverr_m_to_u_extdbg_rom_pslverr_s;
    wire [31:0]                      u_expander_extdbgbus_prdata_m_to_u_extdbg_rom_prdata_s;


    wire                             u_expander_extdbgbus_pwakeup_m_to_u_host_apbap_pwakeup_s;
    wire                             u_expander_extdbgbus_psel_m_to_u_host_apbap_psel_s;
    wire                             u_expander_extdbgbus_penable_m_to_u_host_apbap_penable_s;
    wire                             u_expander_extdbgbus_pwrite_m_to_u_host_apbap_pwrite_s;
    wire [12:0]                      u_expander_extdbgbus_paddr_m_to_u_host_apbap_paddr_s;
    wire [31:0]                      u_expander_extdbgbus_pwdata_m_to_u_host_apbap_pwdata_s;
    wire                             u_expander_extdbgbus_pready_m_to_u_host_apbap_pready_s;
    wire                             u_expander_extdbgbus_pslverr_m_to_u_host_apbap_pslverr_s;
    wire [31:0]                      u_expander_extdbgbus_prdata_m_to_u_host_apbap_prdata_s;

    wire                             u_decoder_extdbgbus_pwakeup_e_to_u_expander_extdbgbus_pwakeup_e;
    wire                             u_decoder_extdbgbus_psel_e_to_u_expander_extdbgbus_psel_e;
    wire                             u_decoder_extdbgbus_penable_e_to_u_expander_extdbgbus_penable_e;
    wire                             u_decoder_extdbgbus_pwrite_e_to_u_expander_extdbgbus_pwrite_e;
    wire [2:0]                       u_decoder_extdbgbus_pprot_e_to_u_expander_extdbgbus_pprot_e;
    wire [23:0]                      u_decoder_extdbgbus_paddr_e_to_u_expander_extdbgbus_paddr_e;
    wire [31:0]                      u_decoder_extdbgbus_pwdata_e_to_u_expander_extdbgbus_pwdata_e;
    wire                             u_decoder_extdbgbus_pready_e_to_u_expander_extdbgbus_pready_e;
    wire                             u_decoder_extdbgbus_pslverr_e_to_u_expander_extdbgbus_pslverr_e;
    wire [31:0]                      u_decoder_extdbgbus_prdata_e_to_u_expander_extdbgbus_prdata_e;


    wire                             u_expander_host_pwakeup_m_to_u_host_catu_pwakeup_s;
    wire                             u_expander_host_psel_m_to_u_host_catu_psel_s;
    wire                             u_expander_host_penable_m_to_u_host_catu_penable_s;
    wire                             u_expander_host_pwrite_m_to_u_host_catu_pwrite_s;
    wire [11:0]                      u_expander_host_paddr_m_to_u_host_catu_paddr_s;
    wire [31:0]                      u_expander_host_pwdata_m_to_u_host_catu_pwdata_s;
    wire                             u_expander_host_pready_m_to_u_host_catu_pready_s;
    wire                             u_expander_host_pslverr_m_to_u_host_catu_pslverr_s;
    wire [31:0]                      u_expander_host_prdata_m_to_u_host_catu_prdata_s;

    wire                             u_expander_host_pwakeup_m_to_u_host_etr_pwakeup_s;
    wire                             u_expander_host_psel_m_to_u_host_etr_psel_s;
    wire                             u_expander_host_penable_m_to_u_host_etr_penable_s;
    wire                             u_expander_host_pwrite_m_to_u_host_etr_pwrite_s;
    wire [11:0]                      u_expander_host_paddr_m_to_u_host_etr_paddr_s;
    wire [31:0]                      u_expander_host_pwdata_m_to_u_host_etr_pwdata_s;
    wire                             u_expander_host_pready_m_to_u_host_etr_pready_s;
    wire                             u_expander_host_pslverr_m_to_u_host_etr_pslverr_s;
    wire [31:0]                      u_expander_host_prdata_m_to_u_host_etr_prdata_s;

    wire                             u_expander_host_pwakeup_m_to_u_host_cti_pwakeup_s;
    wire                             u_expander_host_psel_m_to_u_host_cti_psel_s;
    wire                             u_expander_host_penable_m_to_u_host_cti_penable_s;
    wire                             u_expander_host_pwrite_m_to_u_host_cti_pwrite_s;
    wire [11:0]                      u_expander_host_paddr_m_to_u_host_cti_paddr_s;
    wire [31:0]                      u_expander_host_pwdata_m_to_u_host_cti_pwdata_s;
    wire                             u_expander_host_pready_m_to_u_host_cti_pready_s;
    wire                             u_expander_host_pslverr_m_to_u_host_cti_pslverr_s;
    wire [31:0]                      u_expander_host_prdata_m_to_u_host_cti_prdata_s;



    wire                             u_expander_extdbgbus_pwakeup_m_to_u_soc_cti_pwakeup_s;
    wire                             u_expander_extdbgbus_psel_m_to_u_soc_cti_psel_s;
    wire                             u_expander_extdbgbus_penable_m_to_u_soc_cti_penable_s;
    wire                             u_expander_extdbgbus_pwrite_m_to_u_soc_cti_pwrite_s;
    wire [11:0]                      u_expander_extdbgbus_paddr_m_to_u_soc_cti_paddr_s;
    wire [31:0]                      u_expander_extdbgbus_pwdata_m_to_u_soc_cti_pwdata_s;
    wire                             u_expander_extdbgbus_pready_m_to_u_soc_cti_pready_s;
    wire                             u_expander_extdbgbus_pslverr_m_to_u_soc_cti_pslverr_s;
    wire [31:0]                      u_expander_extdbgbus_prdata_m_to_u_soc_cti_prdata_s;


    wire                             u_soc_replicator_atwakeup_m_to_u_soc_etr_atwakeup_s;
    wire [6:0]                       u_soc_replicator_atid_m_to_u_soc_etr_atid_s;
    wire [1:0]                       u_soc_replicator_atbytes_m_to_u_soc_etr_atbytes_s;
    wire [31:0]                      u_soc_replicator_atdata_m_to_u_soc_etr_atdata_s;
    wire                             u_soc_replicator_atvalid_m_to_u_soc_etr_atvalid_s;
    wire                             u_soc_replicator_atready_m_to_u_soc_etr_atready_s;
    wire                             u_soc_replicator_afvalid_m_to_u_soc_etr_afvalid_s;
    wire                             u_soc_replicator_afready_m_to_u_soc_etr_afready_s;
    wire                             u_soc_replicator_syncreq_m_to_u_soc_etr_syncreq_s;

    wire                             u_expander_extdbgbus_pwakeup_m_to_u_soc_etr_pwakeup_s;
    wire                             u_expander_extdbgbus_psel_m_to_u_soc_etr_psel_s;
    wire                             u_expander_extdbgbus_penable_m_to_u_soc_etr_penable_s;
    wire                             u_expander_extdbgbus_pwrite_m_to_u_soc_etr_pwrite_s;
    wire [11:0]                      u_expander_extdbgbus_paddr_m_to_u_soc_etr_paddr_s;
    wire [31:0]                      u_expander_extdbgbus_pwdata_m_to_u_soc_etr_pwdata_s;
    wire                             u_expander_extdbgbus_pready_m_to_u_soc_etr_pready_s;
    wire                             u_expander_extdbgbus_pslverr_m_to_u_soc_etr_pslverr_s;
    wire [31:0]                      u_expander_extdbgbus_prdata_m_to_u_soc_etr_prdata_s;

    wire                             u_expander_extdbgbus_pwakeup_m_to_u_soc_catu_pwakeup_s;
    wire                             u_expander_extdbgbus_psel_m_to_u_soc_catu_psel_s;
    wire                             u_expander_extdbgbus_penable_m_to_u_soc_catu_penable_s;
    wire                             u_expander_extdbgbus_pwrite_m_to_u_soc_catu_pwrite_s;
    wire [11:0]                      u_expander_extdbgbus_paddr_m_to_u_soc_catu_paddr_s;
    wire [31:0]                      u_expander_extdbgbus_pwdata_m_to_u_soc_catu_pwdata_s;
    wire                             u_expander_extdbgbus_pready_m_to_u_soc_catu_pready_s;
    wire                             u_expander_extdbgbus_pslverr_m_to_u_soc_catu_pslverr_s;
    wire [31:0]                      u_expander_extdbgbus_prdata_m_to_u_soc_catu_prdata_s;



    wire                             u_expander_extdbgbus_pwakeup_m_to_u_soc_tpiu_pwakeup_s;
    wire                             u_expander_extdbgbus_psel_m_to_u_soc_tpiu_psel_s;
    wire                             u_expander_extdbgbus_penable_m_to_u_soc_tpiu_penable_s;
    wire                             u_expander_extdbgbus_pwrite_m_to_u_soc_tpiu_pwrite_s;
    wire [11:0]                      u_expander_extdbgbus_paddr_m_to_u_soc_tpiu_paddr_s;
    wire [31:0]                      u_expander_extdbgbus_pwdata_m_to_u_soc_tpiu_pwdata_s;
    wire                             u_expander_extdbgbus_pready_m_to_u_soc_tpiu_pready_s;
    wire                             u_expander_extdbgbus_pslverr_m_to_u_soc_tpiu_pslverr_s;
    wire [31:0]                      u_expander_extdbgbus_prdata_m_to_u_soc_tpiu_prdata_s;


    wire                             u_soc_replicator_atwakeup_m_to_u_soc_tpiu_atwakeup_s;
    wire [6:0]                       u_soc_replicator_atid_m_to_u_soc_tpiu_atid_s;
    wire [1:0]                       u_soc_replicator_atbytes_m_to_u_soc_tpiu_atbytes_s;
    wire [31:0]                      u_soc_replicator_atdata_m_to_u_soc_tpiu_atdata_s;
    wire                             u_soc_replicator_atvalid_m_to_u_soc_tpiu_atvalid_s;
    wire                             u_soc_replicator_atready_m_to_u_soc_tpiu_atready_s;
    wire                             u_soc_replicator_afready_m_to_u_soc_tpiu_afready_s;
    wire                             u_soc_replicator_afvalid_m_to_u_soc_tpiu_afvalid_s;
    wire                             u_soc_replicator_syncreq_m_to_u_soc_tpiu_syncreq_s;

    wire                             u_expander_extdbgbus_pwakeup_m_to_u_counter_cti_pwakeup_s;
    wire                             u_expander_extdbgbus_psel_m_to_u_counter_cti_psel_s;
    wire                             u_expander_extdbgbus_penable_m_to_u_counter_cti_penable_s;
    wire                             u_expander_extdbgbus_pwrite_m_to_u_counter_cti_pwrite_s;
    wire [11:0]                      u_expander_extdbgbus_paddr_m_to_u_counter_cti_paddr_s;
    wire [31:0]                      u_expander_extdbgbus_pwdata_m_to_u_counter_cti_pwdata_s;
    wire                             u_expander_extdbgbus_pready_m_to_u_counter_cti_pready_s;
    wire                             u_expander_extdbgbus_pslverr_m_to_u_counter_cti_pslverr_s;
    wire [31:0]                      u_expander_extdbgbus_prdata_m_to_u_counter_cti_prdata_s;

    wire                             u_expander_extdbgbus_pwakeup_m;
    wire                             u_expander_extdbgbus_psel_m;
    wire                             u_expander_extdbgbus_penable_m;
    wire                             u_expander_extdbgbus_pwrite_m;
    wire  [2:0]                      u_expander_extdbgbus_pprot_m;
    wire [19:0]                      u_expander_extdbgbus_paddr_m;
    wire [31:0]                      u_expander_extdbgbus_pwdata_m;
    wire                             u_expander_extdbgbus_pready_m;
    wire                             u_expander_extdbgbus_pslverr_m;
    wire [31:0]                      u_expander_extdbgbus_prdata_m;

    wire                             u_decoder_host_pwakeup_e_to_u_expander_host_pwakeup_e;
    wire                             u_decoder_host_psel_e_to_u_expander_host_psel_e;
    wire                             u_decoder_host_penable_e_to_u_expander_host_penable_e;
    wire                             u_decoder_host_pwrite_e_to_u_expander_host_pwrite_e;
    wire [2:0]                       u_decoder_host_pprot_e_to_u_expander_host_pprot_e;
    wire [28:0]                      u_decoder_host_paddr_e_to_u_expander_host_paddr_e;
    wire [31:0]                      u_decoder_host_pwdata_e_to_u_expander_host_pwdata_e;
    wire                             u_decoder_host_pready_e_to_u_expander_host_pready_e;
    wire                             u_decoder_host_pslverr_e_to_u_expander_host_pslverr_e;
    wire [31:0]                      u_decoder_host_prdata_e_to_u_expander_host_prdata_e;


    wire                             u_expander_extdbgbus_pwakeup_m_to_u_host_axiap_rom_not_used;
    wire                             u_expander_extdbgbus_psel_m_to_u_host_axiap_rom_psel_s;
    wire                             u_expander_extdbgbus_penable_m_to_u_host_axiap_rom_penable_s;
    wire                             u_expander_extdbgbus_pwrite_m_to_u_host_axiap_rom_pwrite_s;
    wire [11:0]                      u_expander_extdbgbus_paddr_m_to_u_host_axiap_rom_paddr_s;
    wire [31:0]                      u_expander_extdbgbus_pwdata_m_to_u_host_axiap_rom_pwdata_s;
    wire                             u_expander_extdbgbus_pready_m_to_u_host_axiap_rom_pready_s;
    wire                             u_expander_extdbgbus_pslverr_m_to_u_host_axiap_rom_pslverr_s;
    wire [31:0]                      u_expander_extdbgbus_prdata_m_to_u_host_axiap_rom_prdata_s;

    wire                             u_host_apbap_pwakeup_m_to_u_decoder_host_pwakeup_s;
    wire                             u_host_apbap_psel_m_to_u_decoder_host_psel_s;
    wire                             u_host_apbap_penable_m_to_u_decoder_host_penable_s;
    wire                             u_host_apbap_pwrite_m_to_u_decoder_host_pwrite_s;
    wire [31:0]                      u_host_apbap_paddr_m_to_u_decoder_host_paddr_s;
    wire [31:0]                      u_host_apbap_pwdata_m_to_u_decoder_host_pwdata_s;
    wire [2:0]                       u_host_apbap_pprot_m_to_u_decoder_host_pprot_s;
    wire                             u_host_apbap_pready_m_to_u_decoder_host_pready_s;
    wire                             u_host_apbap_pslverr_m_to_u_decoder_host_pslverr_s;
    wire [31:0]                      u_host_apbap_prdata_m_to_u_decoder_host_prdata_s;
    wire [31:0]                      u_decoder_host_prdata_s;

    wire                             u_expander_extdbgbus_pwakeup_m_to_u_host_axiap_pwakeup_s;
    wire                             u_expander_extdbgbus_psel_m_to_u_host_axiap_psel_s;
    wire                             u_expander_extdbgbus_penable_m_to_u_host_axiap_penable_s;
    wire                             u_expander_extdbgbus_pwrite_m_to_u_host_axiap_pwrite_s;
    wire [12:0]                      u_expander_extdbgbus_paddr_m_to_u_host_axiap_paddr_s;
    wire [31:0]                      u_expander_extdbgbus_pwdata_m_to_u_host_axiap_pwdata_s;
    wire                             u_expander_extdbgbus_pready_m_to_u_host_axiap_pready_s;
    wire                             u_expander_extdbgbus_pslverr_m_to_u_host_axiap_pslverr_s;
    wire [31:0]                      u_expander_extdbgbus_prdata_m_to_u_host_axiap_prdata_s;



    wire                             u_expander_host_pwakeup_m_to_u_host_rom_not_used;
    wire                             u_expander_host_psel_m_to_u_host_rom_psel_s;
    wire                             u_expander_host_penable_m_to_u_host_rom_penable_s;
    wire                             u_expander_host_pwrite_m_to_u_host_rom_pwrite_s;
    wire [11:0]                      u_expander_host_paddr_m_to_u_host_rom_paddr_s;
    wire [31:0]                      u_expander_host_pwdata_m_to_u_host_rom_pwdata_s;
    wire                             u_expander_host_pready_m_to_u_host_rom_pready_s;
    wire                             u_expander_host_pslverr_m_to_u_host_rom_pslverr_s;
    wire [31:0]                      u_expander_host_prdata_m_to_u_host_rom_prdata_s;

    wire                             u_expander_host_pwakeup_m;
    wire                             u_expander_host_psel_m;
    wire                             u_expander_host_penable_m;
    wire                             u_expander_host_pwrite_m;
    wire [2:0]                       u_expander_host_pprot_m;
    wire [24:0]                      u_expander_host_paddr_m;
    wire [31:0]                      u_expander_host_pwdata_m;
    wire                             u_expander_host_pready_m;
    wire                             u_expander_host_pslverr_m;
    wire [31:0]                      u_expander_host_prdata_m;

    wire [6:0]                       u_host_stm_atidm_to_u_host_downsizer_atid_s;
    wire [2:0]                       u_host_stm_atbytesm_to_u_host_downsizer_atbytes_s;
    wire [63:0]                      u_host_stm_atdatam_to_u_host_downsizer_atdata_s;
    wire                             u_host_stm_atvalidm_to_u_host_downsizer_atvalid_s;
    wire                             u_host_stm_atreadym_to_u_host_downsizer_atready_s;
    wire                             u_host_stm_afvalidm_to_u_host_downsizer_afvalid_s;
    wire                             u_host_stm_afreadym_to_u_host_downsizer_afready_s;
    wire                             u_host_stm_syncreqm_to_u_host_downsizer_syncreq_s;

    wire                             u_host_downsizer_atwakeup_m_to_u_host_funnel_atwakeup_s;
    wire [6:0]                       u_host_downsizer_atid_m_to_u_host_funnel_atid_s;
    wire [1:0]                       u_host_downsizer_atbytes_m_to_u_host_funnel_atbytes_s;
    wire [31:0]                      u_host_downsizer_atdata_m_to_u_host_funnel_atdata_s;
    wire                             u_host_downsizer_atvalid_m_to_u_host_funnel_atvalid_s;
    wire                             u_host_downsizer_atready_m_to_u_host_funnel_atready_s;
    wire                             u_host_downsizer_afvalid_m_to_u_host_funnel_afvalid_s;
    wire                             u_host_downsizer_afready_m_to_u_host_funnel_afready_s;
    wire                             u_host_downsizer_syncreq_m_to_u_host_funnel_syncreq_s;


    wire [63:0]                      tsvalueb_gray;
    wire [63:0]                      tsvalueb_binary;
    wire [63:0]                      tsvalueb_binary_tsintp;

    wire [31:0]                      u_soc_etr_awaddr_m_to_u_nic_awaddr_p0_axis;
    wire  [7:0]                      u_soc_etr_awlen_m_to_u_nic_awlen_p0_axis;
    wire  [2:0]                      u_soc_etr_awsize_m_to_u_nic_awsize_p0_axis;
    wire  [1:0]                      u_soc_etr_awburst_m_to_u_nic_awburst_p0_axis;
    wire                             u_soc_etr_awlock_m_to_u_nic_awlock_p0_axis;
    wire  [3:0]                      u_soc_etr_awcache_m_to_u_nic_awcache_p0_axis;
    wire  [2:0]                      u_soc_etr_awprot_m_to_u_nic_awprot_p0_axis;
    wire                             u_soc_etr_awvalid_m_to_u_nic_awvalid_p0_axis;
    wire                             u_soc_etr_awready_m_to_u_nic_awready_p0_axis;
    wire [31:0]                      u_soc_etr_wdata_m_to_u_nic_wdata_p0_axis;
    wire  [3:0]                      u_soc_etr_wstrb_m_to_u_nic_wstrb_p0_axis;
    wire                             u_soc_etr_wlast_m_to_u_nic_wlast_p0_axis;
    wire                             u_soc_etr_wvalid_m_to_u_nic_wvalid_p0_axis;
    wire                             u_soc_etr_wready_m_to_u_nic_wready_p0_axis;
    wire  [1:0]                      u_soc_etr_bresp_m_to_u_nic_bresp_p0_axis;
    wire                             u_soc_etr_bvalid_m_to_u_nic_bvalid_p0_axis;
    wire                             u_soc_etr_bready_m_to_u_nic_bready_p0_axis;
    wire [31:0]                      u_soc_etr_araddr_m_to_u_nic_araddr_p0_axis;
    wire  [7:0]                      u_soc_etr_arlen_m_to_u_nic_arlen_p0_axis;
    wire  [2:0]                      u_soc_etr_arsize_m_to_u_nic_arsize_p0_axis;
    wire  [1:0]                      u_soc_etr_arburst_m_to_u_nic_arburst_p0_axis;
    wire                             u_soc_etr_arlock_m_to_u_nic_arlock_p0_axis;
    wire  [3:0]                      u_soc_etr_arcache_m_to_u_nic_arcache_p0_axis;
    wire  [2:0]                      u_soc_etr_arprot_m_to_u_nic_arprot_p0_axis;
    wire                             u_soc_etr_arvalid_m_to_u_nic_arvalid_p0_axis;
    wire                             u_soc_etr_arready_m_to_u_nic_arready_p0_axis;
    wire [31:0]                      u_soc_etr_rdata_m_to_u_nic_rdata_p0_axis;
    wire  [1:0]                      u_soc_etr_rresp_m_to_u_nic_rresp_p0_axis;
    wire                             u_soc_etr_rlast_m_to_u_nic_rlast_p0_axis;
    wire                             u_soc_etr_rvalid_m_to_u_nic_rvalid_p0_axis;
    wire                             u_soc_etr_rready_m_to_u_nic_rready_p0_axis;

    wire [31:0]                      u_soc_catu_awaddr_m_to_u_nic_awaddr_p0_axis;
    wire  [7:0]                      u_soc_catu_awlen_m_to_u_nic_awlen_p0_axis;
    wire  [2:0]                      u_soc_catu_awsize_m_to_u_nic_awsize_p0_axis;
    wire  [1:0]                      u_soc_catu_awburst_m_to_u_nic_awburst_p0_axis;
    wire                             u_soc_catu_awlock_m_to_u_nic_awlock_p0_axis;
    wire  [3:0]                      u_soc_catu_awcache_m_to_u_nic_awcache_p0_axis;
    wire  [2:0]                      u_soc_catu_awprot_m_to_u_nic_awprot_p0_axis;
    wire                             u_soc_catu_awvalid_m_to_u_nic_awvalid_p0_axis;
    wire                             u_soc_catu_awready_m_to_u_nic_awready_p0_axis;
    wire [31:0]                      u_soc_catu_wdata_m_to_u_nic_wdata_p0_axis;
    wire  [3:0]                      u_soc_catu_wstrb_m_to_u_nic_wstrb_p0_axis;
    wire                             u_soc_catu_wlast_m_to_u_nic_wlast_p0_axis;
    wire                             u_soc_catu_wvalid_m_to_u_nic_wvalid_p0_axis;
    wire                             u_soc_catu_wready_m_to_u_nic_wready_p0_axis;
    wire  [1:0]                      u_soc_catu_bresp_m_to_u_nic_bresp_p0_axis;
    wire                             u_soc_catu_bvalid_m_to_u_nic_bvalid_p0_axis;
    wire                             u_soc_catu_bready_m_to_u_nic_bready_p0_axis;
    wire  [1:0]                      u_soc_catu_arid_m_to_u_nic_arid_p0_axis;
    wire [31:0]                      u_soc_catu_araddr_m_to_u_nic_araddr_p0_axis;
    wire  [7:0]                      u_soc_catu_arlen_m_to_u_nic_arlen_p0_axis;
    wire  [2:0]                      u_soc_catu_arsize_m_to_u_nic_arsize_p0_axis;
    wire  [1:0]                      u_soc_catu_arburst_m_to_u_nic_arburst_p0_axis;
    wire                             u_soc_catu_arlock_m_to_u_nic_arlock_p0_axis;
    wire  [3:0]                      u_soc_catu_arcache_m_to_u_nic_arcache_p0_axis;
    wire  [2:0]                      u_soc_catu_arprot_m_to_u_nic_arprot_p0_axis;
    wire                             u_soc_catu_arvalid_m_to_u_nic_arvalid_p0_axis;
    wire                             u_soc_catu_arready_m_to_u_nic_arready_p0_axis;
    wire [31:0]                      u_soc_catu_rdata_m_to_u_nic_rdata_p0_axis;
    wire  [1:0]                      u_soc_catu_rresp_m_to_u_nic_rresp_p0_axis;
    wire                             u_soc_catu_rlast_m_to_u_nic_rlast_p0_axis;
    wire  [1:0]                      u_soc_catu_rid_m_to_u_nic_rid_p0_axis;
    wire                             u_soc_catu_rvalid_m_to_u_nic_rvalid_p0_axis;
    wire                             u_soc_catu_rready_m_to_u_nic_rready_p0_axis;

    wire [31:0]                      u_soc_etr_awaddr_m_to_u_soc_catu_awaddr_s;
    wire  [7:0]                      u_soc_etr_awlen_m_to_u_soc_catu_awlen_s;
    wire  [2:0]                      u_soc_etr_awsize_m_to_u_soc_catu_awsize_s;
    wire  [1:0]                      u_soc_etr_awburst_m_to_u_soc_catu_awburst_s;
    wire                             u_soc_etr_awlock_m_to_u_soc_catu_awlock_s;
    wire  [3:0]                      u_soc_etr_awcache_m_to_u_soc_catu_awcache_s;
    wire  [2:0]                      u_soc_etr_awprot_m_to_u_soc_catu_awprot_s;
    wire                             u_soc_etr_awvalid_m_to_u_soc_catu_awvalid_s;
    wire                             u_soc_etr_awready_m_to_u_soc_catu_awready_s;
    wire [31:0]                      u_soc_etr_wdata_m_to_u_soc_catu_wdata_s;
    wire  [3:0]                      u_soc_etr_wstrb_m_to_u_soc_catu_wstrb_s;
    wire                             u_soc_etr_wlast_m_to_u_soc_catu_wlast_s;
    wire                             u_soc_etr_wvalid_m_to_u_soc_catu_wvalid_s;
    wire                             u_soc_etr_wready_m_to_u_soc_catu_wready_s;
    wire  [1:0]                      u_soc_etr_bresp_m_to_u_soc_catu_bresp_s;
    wire                             u_soc_etr_bvalid_m_to_u_soc_catu_bvalid_s;
    wire                             u_soc_etr_bready_m_to_u_soc_catu_bready_s;
    wire [31:0]                      u_soc_etr_araddr_m_to_u_soc_catu_araddr_s;
    wire  [7:0]                      u_soc_etr_arlen_m_to_u_soc_catu_arlen_s;
    wire  [2:0]                      u_soc_etr_arsize_m_to_u_soc_catu_arsize_s;
    wire  [1:0]                      u_soc_etr_arburst_m_to_u_soc_catu_arburst_s;
    wire                             u_soc_etr_arlock_m_to_u_soc_catu_arlock_s;
    wire  [3:0]                      u_soc_etr_arcache_m_to_u_soc_catu_arcache_s;
    wire  [2:0]                      u_soc_etr_arprot_m_to_u_soc_catu_arprot_s;
    wire                             u_soc_etr_arvalid_m_to_u_soc_catu_arvalid_s;
    wire                             u_soc_etr_arready_m_to_u_soc_catu_arready_s;
    wire [31:0]                      u_soc_etr_rdata_m_to_u_soc_catu_rdata_s;
    wire  [1:0]                      u_soc_etr_rresp_m_to_u_soc_catu_rresp_s;
    wire                             u_soc_etr_rlast_m_to_u_soc_catu_rlast_s;
    wire                             u_soc_etr_rvalid_m_to_u_soc_catu_rvalid_s;
    wire                             u_soc_etr_rready_m_to_u_soc_catu_rready_s;

    wire [31:0]                      u_host_etr_awaddr_m_to_u_host_catu_awaddr_s;
    wire  [7:0]                      u_host_etr_awlen_m_to_u_host_catu_awlen_s;
    wire  [2:0]                      u_host_etr_awsize_m_to_u_host_catu_awsize_s;
    wire  [1:0]                      u_host_etr_awburst_m_to_u_host_catu_awburst_s;
    wire                             u_host_etr_awlock_m_to_u_host_catu_awlock_s;
    wire  [3:0]                      u_host_etr_awcache_m_to_u_host_catu_awcache_s;
    wire  [2:0]                      u_host_etr_awprot_m_to_u_host_catu_awprot_s;
    wire                             u_host_etr_awvalid_m_to_u_host_catu_awvalid_s;
    wire                             u_host_etr_awready_m_to_u_host_catu_awready_s;
    wire [31:0]                      u_host_etr_wdata_m_to_u_host_catu_wdata_s;
    wire  [3:0]                      u_host_etr_wstrb_m_to_u_host_catu_wstrb_s;
    wire                             u_host_etr_wlast_m_to_u_host_catu_wlast_s;
    wire                             u_host_etr_wvalid_m_to_u_host_catu_wvalid_s;
    wire                             u_host_etr_wready_m_to_u_host_catu_wready_s;
    wire  [1:0]                      u_host_etr_bresp_m_to_u_host_catu_bresp_s;
    wire                             u_host_etr_bvalid_m_to_u_host_catu_bvalid_s;
    wire                             u_host_etr_bready_m_to_u_host_catu_bready_s;
    wire [31:0]                      u_host_etr_araddr_m_to_u_host_catu_araddr_s;
    wire  [7:0]                      u_host_etr_arlen_m_to_u_host_catu_arlen_s;
    wire  [2:0]                      u_host_etr_arsize_m_to_u_host_catu_arsize_s;
    wire  [1:0]                      u_host_etr_arburst_m_to_u_host_catu_arburst_s;
    wire                             u_host_etr_arlock_m_to_u_host_catu_arlock_s;
    wire  [3:0]                      u_host_etr_arcache_m_to_u_host_catu_arcache_s;
    wire  [2:0]                      u_host_etr_arprot_m_to_u_host_catu_arprot_s;
    wire                             u_host_etr_arvalid_m_to_u_host_catu_arvalid_s;
    wire                             u_host_etr_arready_m_to_u_host_catu_arready_s;
    wire [31:0]                      u_host_etr_rdata_m_to_u_host_catu_rdata_s;
    wire  [1:0]                      u_host_etr_rresp_m_to_u_host_catu_rresp_s;
    wire                             u_host_etr_rlast_m_to_u_host_catu_rlast_s;
    wire                             u_host_etr_rvalid_m_to_u_host_catu_rvalid_s;
    wire                             u_host_etr_rready_m_to_u_host_catu_rready_s;

    wire [31:0]                      u_host_etr_awaddr_m_to_u_nic_awaddr_p1_axis;
    wire  [7:0]                      u_host_etr_awlen_m_to_u_nic_awlen_p1_axis;
    wire  [2:0]                      u_host_etr_awsize_m_to_u_nic_awsize_p1_axis;
    wire  [1:0]                      u_host_etr_awburst_m_to_u_nic_awburst_p1_axis;
    wire                             u_host_etr_awlock_m_to_u_nic_awlock_p1_axis;
    wire  [3:0]                      u_host_etr_awcache_m_to_u_nic_awcache_p1_axis;
    wire  [2:0]                      u_host_etr_awprot_m_to_u_nic_awprot_p1_axis;
    wire                             u_host_etr_awvalid_m_to_u_nic_awvalid_p1_axis;
    wire                             u_host_etr_awready_m_to_u_nic_awready_p1_axis;
    wire [31:0]                      u_host_etr_wdata_m_to_u_nic_wdata_p1_axis;
    wire  [3:0]                      u_host_etr_wstrb_m_to_u_nic_wstrb_p1_axis;
    wire                             u_host_etr_wlast_m_to_u_nic_wlast_p1_axis;
    wire                             u_host_etr_wvalid_m_to_u_nic_wvalid_p1_axis;
    wire                             u_host_etr_wready_m_to_u_nic_wready_p1_axis;
    wire  [1:0]                      u_host_etr_bresp_m_to_u_nic_bresp_p1_axis;
    wire                             u_host_etr_bvalid_m_to_u_nic_bvalid_p1_axis;
    wire                             u_host_etr_bready_m_to_u_nic_bready_p1_axis;
    wire [31:0]                      u_host_etr_araddr_m_to_u_nic_araddr_p1_axis;
    wire  [7:0]                      u_host_etr_arlen_m_to_u_nic_arlen_p1_axis;
    wire  [2:0]                      u_host_etr_arsize_m_to_u_nic_arsize_p1_axis;
    wire  [1:0]                      u_host_etr_arburst_m_to_u_nic_arburst_p1_axis;
    wire                             u_host_etr_arlock_m_to_u_nic_arlock_p1_axis;
    wire  [3:0]                      u_host_etr_arcache_m_to_u_nic_arcache_p1_axis;
    wire  [2:0]                      u_host_etr_arprot_m_to_u_nic_arprot_p1_axis;
    wire                             u_host_etr_arvalid_m_to_u_nic_arvalid_p1_axis;
    wire                             u_host_etr_arready_m_to_u_nic_arready_p1_axis;
    wire [31:0]                      u_host_etr_rdata_m_to_u_nic_rdata_p1_axis;
    wire  [1:0]                      u_host_etr_rresp_m_to_u_nic_rresp_p1_axis;
    wire                             u_host_etr_rlast_m_to_u_nic_rlast_p1_axis;
    wire                             u_host_etr_rvalid_m_to_u_nic_rvalid_p1_axis;
    wire                             u_host_etr_rready_m_to_u_nic_rready_p1_axis;

    wire [31:0]                      u_host_catu_awaddr_m_to_u_nic_awaddr_p1_axis;
    wire  [7:0]                      u_host_catu_awlen_m_to_u_nic_awlen_p1_axis;
    wire  [2:0]                      u_host_catu_awsize_m_to_u_nic_awsize_p1_axis;
    wire  [1:0]                      u_host_catu_awburst_m_to_u_nic_awburst_p1_axis;
    wire                             u_host_catu_awlock_m_to_u_nic_awlock_p1_axis;
    wire  [3:0]                      u_host_catu_awcache_m_to_u_nic_awcache_p1_axis;
    wire  [2:0]                      u_host_catu_awprot_m_to_u_nic_awprot_p1_axis;
    wire                             u_host_catu_awvalid_m_to_u_nic_awvalid_p1_axis;
    wire                             u_host_catu_awready_m_to_u_nic_awready_p1_axis;
    wire [31:0]                      u_host_catu_wdata_m_to_u_nic_wdata_p1_axis;
    wire  [3:0]                      u_host_catu_wstrb_m_to_u_nic_wstrb_p1_axis;
    wire                             u_host_catu_wlast_m_to_u_nic_wlast_p1_axis;
    wire                             u_host_catu_wvalid_m_to_u_nic_wvalid_p1_axis;
    wire                             u_host_catu_wready_m_to_u_nic_wready_p1_axis;
    wire  [1:0]                      u_host_catu_bresp_m_to_u_nic_bresp_p1_axis;
    wire                             u_host_catu_bvalid_m_to_u_nic_bvalid_p1_axis;
    wire                             u_host_catu_bready_m_to_u_nic_bready_p1_axis;
    wire [31:0]                      u_host_catu_araddr_m_to_u_nic_araddr_p1_axis;
    wire  [7:0]                      u_host_catu_arlen_m_to_u_nic_arlen_p1_axis;
    wire  [2:0]                      u_host_catu_arsize_m_to_u_nic_arsize_p1_axis;
    wire  [1:0]                      u_host_catu_arburst_m_to_u_nic_arburst_p1_axis;
    wire                             u_host_catu_arlock_m_to_u_nic_arlock_p1_axis;
    wire  [3:0]                      u_host_catu_arcache_m_to_u_nic_arcache_p1_axis;
    wire  [2:0]                      u_host_catu_arprot_m_to_u_nic_arprot_p1_axis;
    wire  [1:0]                      u_host_catu_arprot_m_to_u_nic_arid_p1_axis;
    wire  [1:0]                      u_host_catu_arid_m_to_u_nic_arid_p1_axis;
    wire                             u_host_catu_arvalid_m_to_u_nic_arvalid_p1_axis;
    wire                             u_host_catu_arready_m_to_u_nic_arready_p1_axis;
    wire  [1:0]                      u_host_catu_rid_m_to_u_nic_rid_p1_axis;
    wire [31:0]                      u_host_catu_rdata_m_to_u_nic_rdata_p1_axis;
    wire  [1:0]                      u_host_catu_rresp_m_to_u_nic_rresp_p1_axis;
    wire                             u_host_catu_rlast_m_to_u_nic_rlast_p1_axis;
    wire                             u_host_catu_rvalid_m_to_u_nic_rvalid_p1_axis;
    wire                             u_host_catu_rready_m_to_u_nic_rready_p1_axis;

    wire [31:0]                      u_host_axiap_awaddr_m_to_u_nic_awaddr_p2_axis;
    wire  [7:0]                      u_host_axiap_awlen_m_to_u_nic_awlen_p2_axis;
    wire  [2:0]                      u_host_axiap_awsize_m_to_u_nic_awsize_p2_axis;
    wire  [1:0]                      u_host_axiap_awburst_m_to_u_nic_awburst_p2_axis;
    wire                             u_host_axiap_awlock_m_to_u_nic_awlock_p2_axis;
    wire  [3:0]                      u_host_axiap_awcache_m_to_u_nic_awcache_p2_axis;
    wire  [2:0]                      u_host_axiap_awprot_m_to_u_nic_awprot_p2_axis;
    wire                             u_host_axiap_awvalid_m_to_u_nic_awvalid_p2_axis;
    wire                             u_host_axiap_awready_m_to_u_nic_awready_p2_axis;
    wire [31:0]                      u_host_axiap_wdata_m_to_u_nic_wdata_p2_axis;
    wire  [3:0]                      u_host_axiap_wstrb_m_to_u_nic_wstrb_p2_axis;
    wire                             u_host_axiap_wlast_m_to_u_nic_wlast_p2_axis;
    wire                             u_host_axiap_wvalid_m_to_u_nic_wvalid_p2_axis;
    wire                             u_host_axiap_wready_m_to_u_nic_wready_p2_axis;
    wire  [1:0]                      u_host_axiap_bresp_m_to_u_nic_bresp_p2_axis;
    wire                             u_host_axiap_bvalid_m_to_u_nic_bvalid_p2_axis;
    wire                             u_host_axiap_bready_m_to_u_nic_bready_p2_axis;
    wire [31:0]                      u_host_axiap_araddr_m_to_u_nic_araddr_p2_axis;
    wire  [7:0]                      u_host_axiap_arlen_m_to_u_nic_arlen_p2_axis;
    wire  [2:0]                      u_host_axiap_arsize_m_to_u_nic_arsize_p2_axis;
    wire  [1:0]                      u_host_axiap_arburst_m_to_u_nic_arburst_p2_axis;
    wire                             u_host_axiap_arlock_m_to_u_nic_arlock_p2_axis;
    wire  [3:0]                      u_host_axiap_arcache_m_to_u_nic_arcache_p2_axis;
    wire  [2:0]                      u_host_axiap_arprot_m_to_u_nic_arprot_p2_axis;
    wire                             u_host_axiap_arvalid_m_to_u_nic_arvalid_p2_axis;
    wire                             u_host_axiap_arready_m_to_u_nic_arready_p2_axis;
    wire [31:0]                      u_host_axiap_rdata_m_to_u_nic_rdata_p2_axis;
    wire  [1:0]                      u_host_axiap_rresp_m_to_u_nic_rresp_p2_axis;
    wire                             u_host_axiap_rlast_m_to_u_nic_rlast_p2_axis;
    wire                             u_host_axiap_rvalid_m_to_u_nic_rvalid_p2_axis;
    wire                             u_host_axiap_rready_m_to_u_nic_rready_p2_axis;

    wire  [3:0]                      u_nic_awid_dbg_axim_to_u_fc_awid_s_i;
    wire [31:0]                      u_nic_awaddr_dbg_axim_to_u_fc_awaddr_s_i;
    wire  [7:0]                      u_nic_awlen_dbg_axim_to_u_fc_awlen_s_i;
    wire  [2:0]                      u_nic_awsize_dbg_axim_to_u_fc_awsize_s_i;
    wire  [1:0]                      u_nic_awburst_dbg_axim_to_u_fc_awburst_s_i;
    wire                             u_nic_awlock_dbg_axim_to_u_fc_awlock_s_i;
    wire  [3:0]                      u_nic_awcache_dbg_axim_to_u_fc_awcache_s_i;
    wire  [2:0]                      u_nic_awprot_dbg_axim_to_u_fc_awprot_s_i;
    wire                             u_nic_awvalid_dbg_axim_to_u_fc_awvalid_s_i;
    wire                             u_nic_awready_dbg_axim_to_u_fc_awready_s_o;
    wire [FC_AXIDATA_WIDTH-1:0]      u_nic_wdata_dbg_axim_to_u_fc_wdata_s_i;
    wire [FC_AXIDATA_WIDTH/8-1:0]    u_nic_wstrb_dbg_axim_to_u_fc_wstrb_s_i;
    wire                             u_nic_wlast_dbg_axim_to_u_fc_wlast_s_i;
    wire                             u_nic_wvalid_dbg_axim_to_u_fc_wvalid_s_i;
    wire                             u_nic_wready_dbg_axim_to_u_fc_wready_s_o;
    wire  [FC_AXIID_WIDTH-1:0]       u_nic_bid_dbg_axim_to_u_fc_bid_s_o;
    wire  [1:0]                      u_nic_bresp_dbg_axim_to_u_fc_bresp_s_o;
    wire                             u_nic_bvalid_dbg_axim_to_u_fc_bvalid_s_o;
    wire                             u_nic_bready_dbg_axim_to_u_fc_bready_s_i;
    wire  [3:0]                      u_nic_arid_dbg_axim_to_u_fc_arid_s_i;
    wire [31:0]                      u_nic_araddr_dbg_axim_to_u_fc_araddr_s_i;
    wire  [7:0]                      u_nic_arlen_dbg_axim_to_u_fc_arlen_s_i;
    wire  [2:0]                      u_nic_arsize_dbg_axim_to_u_fc_arsize_s_i;
    wire  [1:0]                      u_nic_arburst_dbg_axim_to_u_fc_arburst_s_i;
    wire                             u_nic_arlock_dbg_axim_to_u_fc_arlock_s_i;
    wire  [3:0]                      u_nic_arcache_dbg_axim_to_u_fc_arcache_s_i;
    wire  [2:0]                      u_nic_arprot_dbg_axim_to_u_fc_arprot_s_i;
    wire                             u_nic_arvalid_dbg_axim_to_u_fc_arvalid_s_i;
    wire                             u_nic_arready_dbg_axim_to_u_fc_arready_s_o;
    wire  [FC_AXIID_WIDTH-1:0]       u_nic_rid_dbg_axim_to_u_fc_rid_s_o;
    wire [FC_AXIDATA_WIDTH-1:0]      u_nic_rdata_dbg_axim_to_u_fc_rdata_s_o;
    wire  [1:0]                      u_nic_rresp_dbg_axim_to_u_fc_rresp_s_o;
    wire                             u_nic_rlast_dbg_axim_to_u_fc_rlast_s_o;
    wire                             u_nic_rvalid_dbg_axim_to_u_fc_rvalid_s_o;
    wire                             u_nic_rready_dbg_axim_to_u_fc_rready_s_i;
    wire  [2:0]                      u_nic_awuser_dbg_axim_to_u_fc_awmmusid_s_i;
    wire  [2:0]                      u_nic_aruser_dbg_axim_to_u_fc_armmusid_s_i;


    wire                             u_expander_host_pwakeup_m_to_u_host_stm_not_used;
    wire                             u_expander_host_psel_m_to_u_host_stm_pseldbg;
    wire                             u_expander_host_penable_m_to_u_host_stm_penabledbg;
    wire                             u_expander_host_pwrite_m_to_u_host_stm_pwritedbg;
    wire [11:0]                      u_expander_host_paddr_m_to_u_host_stm_paddrdbg;
    wire [31:0]                      u_expander_host_pwdata_m_to_u_host_stm_pwdatadbg;
    wire                             u_expander_host_pready_m_to_u_host_stm_preadydbg;
    wire                             u_expander_host_pslverr_m_to_u_host_stm_pslverrdbg;
    wire [31:0]                      u_expander_host_prdata_m_to_u_host_stm_prdatadbg;


    wire                             u_expander_host_pwakeup_m_to_u_host_replicator_pwakeup_s;
    wire                             u_expander_host_psel_m_to_u_host_replicator_psel_s;
    wire                             u_expander_host_penable_m_to_u_host_replicator_penable_s;
    wire                             u_expander_host_pwrite_m_to_u_host_replicator_pwrite_s;
    wire [11:0]                      u_expander_host_paddr_m_to_u_host_replicator_paddr_s;
    wire [31:0]                      u_expander_host_pwdata_m_to_u_host_replicator_pwdata_s;
    wire                             u_expander_host_pready_m_to_u_host_replicator_pready_s;
    wire                             u_expander_host_pslverr_m_to_u_host_replicator_pslverr_s;
    wire [31:0]                      u_expander_host_prdata_m_to_u_host_replicator_prdata_s;


    wire                             u_expander_host_pwakeup_m_to_u_host_funnel_pwakeup_s;
    wire                             u_expander_host_psel_m_to_u_host_funnel_psel_s;
    wire                             u_expander_host_penable_m_to_u_host_funnel_penable_s;
    wire                             u_expander_host_pwrite_m_to_u_host_funnel_pwrite_s;
    wire [11:0]                      u_expander_host_paddr_m_to_u_host_funnel_paddr_s;
    wire [31:0]                      u_expander_host_pwdata_m_to_u_host_funnel_pwdata_s;
    wire                             u_expander_host_pready_m_to_u_host_funnel_pready_s;
    wire                             u_expander_host_pslverr_m_to_u_host_funnel_pslverr_s;
    wire [31:0]                      u_expander_host_prdata_m_to_u_host_funnel_prdata_s;

    wire                             u_expander_soc_pwakeup_m_to_u_soc_replicator_pwakeup_s;
    wire                             u_expander_soc_psel_m_to_u_soc_replicator_psel_s;
    wire                             u_expander_soc_penable_m_to_u_soc_replicator_penable_s;
    wire                             u_expander_soc_pwrite_m_to_u_soc_replicator_pwrite_s;
    wire [11:0]                      u_expander_soc_paddr_m_to_u_soc_replicator_paddr_s;
    wire [31:0]                      u_expander_soc_pwdata_m_to_u_soc_replicator_pwdata_s;
    wire                             u_expander_soc_pready_m_to_u_soc_replicator_pready_s;
    wire                             u_expander_soc_pslverr_m_to_u_soc_replicator_pslverr_s;
    wire [31:0]                      u_expander_soc_prdata_m_to_u_soc_replicator_prdata_s;


    wire                             u_expander_soc_pwakeup_m_to_u_soc_funnel_pwakeup_s;
    wire                             u_expander_soc_psel_m_to_u_soc_funnel_psel_s;
    wire                             u_expander_soc_penable_m_to_u_soc_funnel_penable_s;
    wire                             u_expander_soc_pwrite_m_to_u_soc_funnel_pwrite_s;
    wire [11:0]                      u_expander_soc_paddr_m_to_u_soc_funnel_paddr_s;
    wire [31:0]                      u_expander_soc_pwdata_m_to_u_soc_funnel_pwdata_s;
    wire                             u_expander_soc_pready_m_to_u_soc_funnel_pready_s;
    wire                             u_expander_soc_pslverr_m_to_u_soc_funnel_pslverr_s;
    wire [31:0]                      u_expander_soc_prdata_m_to_u_soc_funnel_prdata_s;

    
    
    wire                             host_csyspwrupreq_loop ;
    wire                             host_cdbgrstreq_loop   ;
    wire                             host_csysrstreq_loop   ;
    wire                             axiap_cdbgpwrupreq_loop;
    wire                             axiap_cdbgrstreq_loop;
    wire                             axiap_csysrstreq_loop;
    wire                             extdbg_cdbgpwrupreq_loop;
    wire                             extdbg_csyspwrupreq_loop;
    wire                             extdbg_cdbgrstreq_loop;
    wire                             extdbg_csysrstreq_loop;


    wire                             is_reserved_master_id;
    wire [31:0]                      stm_axi_awaddrs_mapped_id;
    
    wire [11:0]                       axiap_csyspwrupreq_loopback;

    wire unused;
    
    assign unused = (u_expander_extdbgbus_pwakeup_m_to_u_extdbg_rom_not_used    )  |
                    (u_expander_extdbgbus_pwakeup_m_to_u_host_axiap_rom_not_used)  |
                    (u_expander_host_pwakeup_m_to_u_host_rom_not_used           )  |
                    (u_expander_host_pwakeup_m_to_u_host_stm_not_used           )  |
                    (|u_expander_host_paddr_m_to_u_host_stm_paddrdbg[1:0]       )  |
                    (|stm_axi_awaddrs[29:24]                                    )  | 
                    (|stm_axi_awusers[9:8]                                      )  |
                    (|stm_axi_awusers[1:0] );


  channel_gate_f0 u_tpiu_gate_f0 (
  
    .channel_pulse_slave_0  (u_soc_cti_out_to_tpiu_gate_in),    
    .channel_pulse_master_1 (u_tpiu_gate_out_to_soc_ctm_in_0),
    
    .channel_pulse_slave_1  (u_soc_ctm_out_0_to_tpiu_gate_in),
    .channel_pulse_master_0 (u_tpiu_gate_out_to_soc_cti_in),    

    .chen                   (chen_tpiuauth_ss)
  );
  
  channel_gate_f0 u_host_gate_f0 (
  
    .channel_pulse_slave_0  (u_host_ctm_out_to_host_gate_in),
    .channel_pulse_master_1 (u_host_gate_out_to_soc_ctm_in_3),
    
    .channel_pulse_slave_1  (u_soc_ctm_out_3_to_host_gate_in),
    .channel_pulse_master_0 (u_host_gate_out_to_host_ctm_in),
    

    .chen                   (chen_hostauth_ss)
  );
  channel_gate_f0 u_counter_gate_f0 (
  
    .channel_pulse_slave_0  (u_counter_cti_out_to_counter_gate_in),
    .channel_pulse_master_1 (u_counter_gate_out_to_soc_ctm_in_4),
                             
    .channel_pulse_slave_1  (u_soc_ctm_out_4_to_counter_gate_in),
    .channel_pulse_master_0 (u_counter_gate_out_to_counter_cti_in),

    .chen                   (chen_counterauth_ss)
  );  
                    
                    
                                        
    css600_cti #(
      .NUM_EVENT_SLAVES  (HOST_CTI_NUM_EVENT_SLAVES),
      .NUM_EVENT_MASTERS (HOST_CTI_NUM_EVENT_MASTERS),
      .SW_HANDSHAKE      (HOST_CTI_SW_HANDSHAKE),
      .EXT_MUX_NUM       (HOST_CTI_EXT_MUX_NUM),
      .FF_SYNC_DEPTH     (HOST_CTI_FF_SYNC_DEPTH),
      .REVAND            (HOST_CTI_REVAND),
      .EVENT_IN_LEVEL    (HOST_CTI_EVENT_IN_LEVEL)
    ) u_host_cti (
      .clk          (dbgclk_gated),
      .reset_n      (dbgclk_resetn),
      .clk_qreq_n   (dbgclk_qreqn   [0]),
      .clk_qaccept_n(dbgclk_qacceptn[0]),
      .clk_qdeny    (dbgclk_qdeny   [0]),
      .clk_qactive  (dbgclk_qactive[0]),
      .pwakeup_s    (u_expander_host_pwakeup_m_to_u_host_cti_pwakeup_s),
      .psel_s       (u_expander_host_psel_m_to_u_host_cti_psel_s),
      .penable_s    (u_expander_host_penable_m_to_u_host_cti_penable_s),
      .pwrite_s     (u_expander_host_pwrite_m_to_u_host_cti_pwrite_s),
      .paddr_s      (u_expander_host_paddr_m_to_u_host_cti_paddr_s),
      .pwdata_s     (u_expander_host_pwdata_m_to_u_host_cti_pwdata_s),
      .prdata_s     (u_expander_host_prdata_m_to_u_host_cti_prdata_s),
      .pready_s     (u_expander_host_pready_m_to_u_host_cti_pready_s),
      .pslverr_s    (u_expander_host_pslverr_m_to_u_host_cti_pslverr_s),
      .event_in     ({u_host_etr_flushcomp_to_u_host_cti_event_in_10,
                      u_host_etr_acqcomp_to_u_host_cti_event_in_9,
                      u_host_etr_full_to_u_host_cti_event_in_8,
                      u_host_stm_asyncout_to_u_host_cti_event_in_4,
                      u_host_stm_trigouthete_to_u_host_cti_event_in_5,
                      u_host_stm_trigoutsw_to_u_host_cti_event_in_6,
                      u_host_stm_trigoutspte_to_u_host_cti_event_in_7                      
                      }),
      .event_out    ({irq_gic73,
                      irq_gic72,
                      u_host_cti_event_out_7_to_u_host_etr_flushin,
                      u_host_cti_event_out_6_to_u_host_etr_trigin,
                      u_host_cti_event_out_5_to_u_host_stm_hwevents2,
                      u_host_cti_event_out_4_to_u_host_stm_hwevents0
                      }),
      .channel_in   (u_host_ctm_out_to_host_cti_in),                                          
      .channel_out  (u_host_cti_out_to_host_ctm_in),
      
      .dbgen        (dbgen_hostauth_ss),
      .niden        (niden_hostauth_ss),
      .asicctrl     (), 
      .tinidensel   ({HOST_CTI_NUM_EVENT_SLAVES {1'b1}}),
      .todbgensel   ({HOST_CTI_NUM_EVENT_MASTERS {1'b1}}),
      .devaff       (host_cti_devaff) 
    );



    css600_cti #(
      .NUM_EVENT_SLAVES  (SOC_CTI_NUM_EVENT_SLAVES),
      .NUM_EVENT_MASTERS (SOC_CTI_NUM_EVENT_MASTERS),
      .SW_HANDSHAKE      (SOC_CTI_SW_HANDSHAKE),
      .EXT_MUX_NUM       (SOC_CTI_EXT_MUX_NUM),
      .FF_SYNC_DEPTH     (SOC_CTI_FF_SYNC_DEPTH),
      .REVAND            (SOC_CTI_REVAND),
      .EVENT_IN_LEVEL    (SOC_CTI_EVENT_IN_LEVEL)
    ) u_soc_cti (
      .clk          (dbgclk_gated),
      .reset_n      (dbgclk_resetn),
      .clk_qreq_n   (dbgclk_qreqn   [1]),
      .clk_qaccept_n(dbgclk_qacceptn[1]),
      .clk_qdeny    (dbgclk_qdeny   [1]),
      .clk_qactive  (dbgclk_qactive[1]),
      .pwakeup_s    (u_expander_extdbgbus_pwakeup_m_to_u_soc_cti_pwakeup_s),
      .psel_s       (u_expander_extdbgbus_psel_m_to_u_soc_cti_psel_s),
      .penable_s    (u_expander_extdbgbus_penable_m_to_u_soc_cti_penable_s),
      .pwrite_s     (u_expander_extdbgbus_pwrite_m_to_u_soc_cti_pwrite_s),
      .paddr_s      (u_expander_extdbgbus_paddr_m_to_u_soc_cti_paddr_s),
      .pwdata_s     (u_expander_extdbgbus_pwdata_m_to_u_soc_cti_pwdata_s),
      .prdata_s     (u_expander_extdbgbus_prdata_m_to_u_soc_cti_prdata_s),
      .pready_s     (u_expander_extdbgbus_pready_m_to_u_soc_cti_pready_s),
      .pslverr_s    (u_expander_extdbgbus_pslverr_m_to_u_soc_cti_pslverr_s),
      .event_in     ({u_soc_etr_flushcomp_to_u_soc_cti_event_in_7,
                      u_soc_etr_acqcomp_to_u_soc_cti_event_in_6,
                      u_soc_etr_full_to_u_soc_cti_event_in_5,
                      u_soc_tpiu_flushcomp_to_u_soc_cti_event_in_4                      
                      }),
      .event_out    ({u_soc_cti_event_out_7_to_u_soc_etr_flushin,
                      u_soc_cti_event_out_8_to_u_soc_etr_trigin,
                      u_soc_cti_event_out_6_to_u_dp_eventstat,
                      u_soc_cti_event_out_5_to_u_soc_tpiu_flushin,
                      u_soc_cti_event_out_4_to_u_soc_tpiu_trigin                      
                      }),
      .channel_in   (u_tpiu_gate_out_to_soc_cti_in), 
      .channel_out  (u_soc_cti_out_to_tpiu_gate_in),
      .dbgen        (dbgen_tpiuauth_ss),
      .niden        (niden_tpiuauth_ss),
      .asicctrl     (),
      .tinidensel   ({SOC_CTI_NUM_EVENT_SLAVES {1'b1}}),
      .todbgensel   ({SOC_CTI_NUM_EVENT_MASTERS {1'b1}}),
      .devaff       (soc_cti_devaff) 
    );











    css600_cti #(
      .NUM_EVENT_SLAVES  (COUNTER_CTI_NUM_EVENT_SLAVES),
      .NUM_EVENT_MASTERS (COUNTER_CTI_NUM_EVENT_MASTERS),
      .SW_HANDSHAKE      (COUNTER_CTI_SW_HANDSHAKE),
      .EXT_MUX_NUM       (COUNTER_CTI_EXT_MUX_NUM),
      .FF_SYNC_DEPTH     (COUNTER_CTI_FF_SYNC_DEPTH),
      .REVAND            (COUNTER_CTI_REVAND),
      .EVENT_IN_LEVEL    (COUNTER_CTI_EVENT_IN_LEVEL)
    ) u_counter_cti (
      .clk          (dbgclk_gated),
      .reset_n      (dbgclk_resetn),
      .clk_qreq_n   (dbgclk_qreqn   [2]),
      .clk_qaccept_n(dbgclk_qacceptn[2]),
      .clk_qdeny    (dbgclk_qdeny   [2]),
      .clk_qactive  (dbgclk_qactive[2]),
      .pwakeup_s    (u_expander_extdbgbus_pwakeup_m_to_u_counter_cti_pwakeup_s),
      .psel_s       (u_expander_extdbgbus_psel_m_to_u_counter_cti_psel_s),
      .penable_s    (u_expander_extdbgbus_penable_m_to_u_counter_cti_penable_s),
      .pwrite_s     (u_expander_extdbgbus_pwrite_m_to_u_counter_cti_pwrite_s),
      .paddr_s      (u_expander_extdbgbus_paddr_m_to_u_counter_cti_paddr_s),
      .pwdata_s     (u_expander_extdbgbus_pwdata_m_to_u_counter_cti_pwdata_s),
      .prdata_s     (u_expander_extdbgbus_prdata_m_to_u_counter_cti_prdata_s),
      .pready_s     (u_expander_extdbgbus_pready_m_to_u_counter_cti_pready_s),
      .pslverr_s    (u_expander_extdbgbus_pslverr_m_to_u_counter_cti_pslverr_s),
      .event_in     (1'b0),
      .event_out    ({s32k_cnt_restart,
                      s32k_cnt_halt,
                      refclk_cnt_restart,
                      refclk_cnt_halt}),                      
      .channel_in   (u_counter_gate_out_to_counter_cti_in), 
      .channel_out  (u_counter_cti_out_to_counter_gate_in),
      .dbgen        (dbgen_counterauth_ss),
      .niden        (niden_counterauth_ss),
      .asicctrl     (), 
      .tinidensel   ({COUNTER_CTI_NUM_EVENT_SLAVES {1'b1}}),
      .todbgensel   ({COUNTER_CTI_NUM_EVENT_MASTERS {1'b1}}),
      .devaff       (counter_cti_devaff) 
    );








    css600_ctm #(
      .NUM_INTERFACES(SOC_CTM_NUM_INTERFACES)
      ) u_soc_ctm (
      .clk        (dbgclk_gated),
      .reset_n    (dbgclk_resetn),
      .channel_in ({                   
                    u_tpiu_gate_out_to_soc_ctm_in_0,
                    extsys1_channel_in,
                    extsys0_channel_in,
                    secenc_channel_in,
                    u_host_gate_out_to_soc_ctm_in_3,
                    u_counter_gate_out_to_soc_ctm_in_4
                    }),
      .channel_out({
                    u_soc_ctm_out_0_to_tpiu_gate_in,
                    extsys1_channel_out,
                    extsys0_channel_out,
                    secenc_channel_out,
                    u_soc_ctm_out_3_to_host_gate_in,
                    u_soc_ctm_out_4_to_counter_gate_in
                    })
      );







    css600_ctm #(
      .NUM_INTERFACES(HOST_CTM_NUM_INTERFACES)
      ) u_host_ctm (
      .clk        (dbgclk_gated),
      .reset_n    (dbgclk_resetn),
      .channel_in ({hostcpuctichout[3],
                    hostcpuctichout[2],
                    hostcpuctichout[1],
                    hostcpuctichout[0],
                    hostctiexpin[3],
                    hostctiexpin[2],
                    hostctiexpin[1],
                    hostctiexpin[0],                    
                    u_host_cti_out_to_host_ctm_in,
                    u_host_gate_out_to_host_ctm_in
                    }),
      .channel_out({hostcpuctichin[3],
                    hostcpuctichin[2],
                    hostcpuctichin[1],
                    hostcpuctichin[0],                    
                    hostctiexpout[3],
                    hostctiexpout[2],
                    hostctiexpout[1],
                    hostctiexpout[0],
                    u_host_ctm_out_to_host_cti_in,
                    u_host_ctm_out_to_host_gate_in
                    })
      );


    css600_tmc_etr #(
      .WBUFFER_DEPTH  (HOST_ETR_WBUFFER_DEPTH),
      .ATB_DATA_WIDTH (HOST_ETR_ATB_DATA_WIDTH),
      .AXI_ADDR_WIDTH (HOST_ETR_AXI_ADDR_WIDTH)
    ) u_host_etr (
      .clk          (dbgclk_gated),
      .reset_n      (dbgclk_resetn),

      .atwakeup_s   (u_host_replicator_atwakeup_m_to_u_host_etr_atwakeup_s),
      .atid_s       (u_host_replicator_atid_m_to_u_host_etr_atid_s),
      .atbytes_s    (u_host_replicator_atbytes_m_to_u_host_etr_atbytes_s),
      .atdata_s     (u_host_replicator_atdata_m_to_u_host_etr_atdata_s),
      .atvalid_s    (u_host_replicator_atvalid_m_to_u_host_etr_atvalid_s),
      .atready_s    (u_host_replicator_atready_m_to_u_host_etr_atready_s),
      .afvalid_s    (u_host_replicator_afvalid_m_to_u_host_etr_afvalid_s),
      .afready_s    (u_host_replicator_afready_m_to_u_host_etr_afready_s),
      .syncreq_s    (u_host_replicator_syncreq_m_to_u_host_etr_syncreq_s),

      .pwakeup_s    (u_expander_host_pwakeup_m_to_u_host_etr_pwakeup_s),
      .psel_s       (u_expander_host_psel_m_to_u_host_etr_psel_s),
      .penable_s    (u_expander_host_penable_m_to_u_host_etr_penable_s),
      .pwrite_s     (u_expander_host_pwrite_m_to_u_host_etr_pwrite_s),
      .paddr_s      (u_expander_host_paddr_m_to_u_host_etr_paddr_s),
      .pwdata_s     (u_expander_host_pwdata_m_to_u_host_etr_pwdata_s),
      .pready_s     (u_expander_host_pready_m_to_u_host_etr_pready_s),
      .pslverr_s    (u_expander_host_pslverr_m_to_u_host_etr_pslverr_s),
      .prdata_s     (u_expander_host_prdata_m_to_u_host_etr_prdata_s),

      .awakeup_m    (),
      .araddr_m     (u_host_etr_araddr_m_to_u_host_catu_araddr_s),
      .arlen_m      (u_host_etr_arlen_m_to_u_host_catu_arlen_s),
      .arsize_m     (u_host_etr_arsize_m_to_u_host_catu_arsize_s),
      .arburst_m    (u_host_etr_arburst_m_to_u_host_catu_arburst_s),
      .arlock_m     (u_host_etr_arlock_m_to_u_host_catu_arlock_s),
      .arcache_m    (u_host_etr_arcache_m_to_u_host_catu_arcache_s),
      .arprot_m     (u_host_etr_arprot_m_to_u_host_catu_arprot_s),
      .arvalid_m    (u_host_etr_arvalid_m_to_u_host_catu_arvalid_s),
      .arready_m    (u_host_etr_arready_m_to_u_host_catu_arready_s),
      .rdata_m      (u_host_etr_rdata_m_to_u_host_catu_rdata_s),
      .rresp_m      (u_host_etr_rresp_m_to_u_host_catu_rresp_s),
      .rlast_m      (u_host_etr_rlast_m_to_u_host_catu_rlast_s),
      .rvalid_m     (u_host_etr_rvalid_m_to_u_host_catu_rvalid_s),
      .rready_m     (u_host_etr_rready_m_to_u_host_catu_rready_s),
      .awaddr_m     (u_host_etr_awaddr_m_to_u_host_catu_awaddr_s),
      .awlen_m      (u_host_etr_awlen_m_to_u_host_catu_awlen_s),
      .awsize_m     (u_host_etr_awsize_m_to_u_host_catu_awsize_s),
      .awburst_m    (u_host_etr_awburst_m_to_u_host_catu_awburst_s),
      .awlock_m     (u_host_etr_awlock_m_to_u_host_catu_awlock_s),
      .awcache_m    (u_host_etr_awcache_m_to_u_host_catu_awcache_s),
      .awprot_m     (u_host_etr_awprot_m_to_u_host_catu_awprot_s),
      .awvalid_m    (u_host_etr_awvalid_m_to_u_host_catu_awvalid_s),
      .awready_m    (u_host_etr_awready_m_to_u_host_catu_awready_s),
      .wdata_m      (u_host_etr_wdata_m_to_u_host_catu_wdata_s),
      .wstrb_m      (u_host_etr_wstrb_m_to_u_host_catu_wstrb_s),
      .wlast_m      (u_host_etr_wlast_m_to_u_host_catu_wlast_s),
      .wvalid_m     (u_host_etr_wvalid_m_to_u_host_catu_wvalid_s),
      .wready_m     (u_host_etr_wready_m_to_u_host_catu_wready_s),
      .bresp_m      (u_host_etr_bresp_m_to_u_host_catu_bresp_s),
      .bvalid_m     (u_host_etr_bvalid_m_to_u_host_catu_bvalid_s),
      .bready_m     (u_host_etr_bready_m_to_u_host_catu_bready_s),

      .dbgen        (dbgen_hostauth_ss),
      .spiden       (spiden_hostauth_ss),

      .clk_qreq_n   (dbgclk_qreqn   [3]),
      .clk_qaccept_n(dbgclk_qacceptn[3]),
      .clk_qdeny    (dbgclk_qdeny   [3]),
      .clk_qactive  (dbgclk_qactive[3]),

      .trigin       (u_host_cti_event_out_6_to_u_host_etr_trigin),
      .flushin      (u_host_cti_event_out_7_to_u_host_etr_flushin),
      .full         (u_host_etr_full_to_u_host_cti_event_in_8),
      .acqcomp      (u_host_etr_acqcomp_to_u_host_cti_event_in_9),
      .flushcomp    (u_host_etr_flushcomp_to_u_host_cti_event_in_10),

      .bufintr      (irq_host_etr),

      .dftcgen      (dftcgen)
    );



    css600_atbreplicator_prog u_host_replicator (
        .clk        (dbgclk_gated),
        .reset_n    (dbgclk_resetn),

        .pwakeup_s  (u_expander_host_pwakeup_m_to_u_host_replicator_pwakeup_s),
        .psel_s     (u_expander_host_psel_m_to_u_host_replicator_psel_s),
        .penable_s  (u_expander_host_penable_m_to_u_host_replicator_penable_s),
        .pwrite_s   (u_expander_host_pwrite_m_to_u_host_replicator_pwrite_s),
        .paddr_s    (u_expander_host_paddr_m_to_u_host_replicator_paddr_s),
        .pwdata_s   (u_expander_host_pwdata_m_to_u_host_replicator_pwdata_s),
        .pready_s   (u_expander_host_pready_m_to_u_host_replicator_pready_s),
        .pslverr_s  (u_expander_host_pslverr_m_to_u_host_replicator_pslverr_s),
        .prdata_s   (u_expander_host_prdata_m_to_u_host_replicator_prdata_s),

        .atwakeup_s (u_host_atbbuffer_atwakeup_m_to_u_host_replicator_atwakeup_s),
        .atid_s     (u_host_atbbuffer_atid_m_to_u_host_replicator_atid_s),
        .atbytes_s  (u_host_atbbuffer_atbytes_m_to_u_host_replicator_atbytes_s),
        .atdata_s   (u_host_atbbuffer_atdata_m_to_u_host_replicator_atdata_s),
        .atvalid_s  (u_host_atbbuffer_atvalid_m_to_u_host_replicator_atvalid_s),
        .atready_s  (u_host_atbbuffer_atready_m_to_u_host_replicator_atready_s),
        .afready_s  (u_host_atbbuffer_afready_m_to_u_host_replicator_afready_s),
        .afvalid_s  (u_host_atbbuffer_afvalid_m_to_u_host_replicator_afvalid_s),
        .syncreq_s  (u_host_atbbuffer_syncreq_m_to_u_host_replicator_syncreq_s),

        .atwakeup_m ({u_host_replicator_atwakeup_m_to_u_host_etr_atwakeup_s,     
                      u_host_replicator_atwakeup_m_to_u_soc_funnel_atwakeup_s}), 
        .atid_m     ({u_host_replicator_atid_m_to_u_host_etr_atid_s,
                      u_host_replicator_atid_m_to_u_soc_funnel_atid_s}),
        .atbytes_m  ({u_host_replicator_atbytes_m_to_u_host_etr_atbytes_s,
                      u_host_replicator_atbytes_m_to_u_soc_funnel_atbytes_s}),
        .atdata_m   ({u_host_replicator_atdata_m_to_u_host_etr_atdata_s,
                      u_host_replicator_atdata_m_to_u_soc_funnel_atdata_s}),
        .atvalid_m  ({u_host_replicator_atvalid_m_to_u_host_etr_atvalid_s,
                      u_host_replicator_atvalid_m_to_u_soc_funnel_atvalid_s}),
        .atready_m  ({u_host_replicator_atready_m_to_u_host_etr_atready_s,
                      u_host_replicator_atready_m_to_u_soc_funnel_atready_s}),
        .afvalid_m  ({u_host_replicator_afvalid_m_to_u_host_etr_afvalid_s,
                      u_host_replicator_afvalid_m_to_u_soc_funnel_afvalid_s}),
        .afready_m  ({u_host_replicator_afready_m_to_u_host_etr_afready_s,
                      u_host_replicator_afready_m_to_u_soc_funnel_afready_s}),
        .syncreq_m  ({u_host_replicator_syncreq_m_to_u_host_etr_syncreq_s,
                      u_host_replicator_syncreq_m_to_u_soc_funnel_syncreq_s}),

        .clk_qactive(dbgclk_qactive_only[0])
    );

    gray_encode u_gray_encode(
        .clk         (refclk),
        .nreset      (refclk_resetn), 

        .binary_count(tsvalueb_refclk),
        .gray_count  (tsvalueb_gray)

    );

    gray_decode_async u_gray_decode(
        .clk         (dbgclk_gated),
        .nreset      (dbgclk_resetn), 

        .gray_count  (tsvalueb_gray),
        .binary_count(tsvalueb_binary)
    );

    css600_tsintp u_css600_tsintp(
        .clk          (dbgclk_gated),
        .reset_n      (dbgclk_resetn), 

        .tsvalue_b_s  (tsvalueb_binary),
        .tsvalue_b_m  (tsvalueb_binary_tsintp),

        .clk_qreq_n   (dbgclk_qreqn[4]),
        .clk_qaccept_n(dbgclk_qacceptn[4])
    );
    assign dbgclk_qdeny[4] = 1'b0;
    assign dbgclk_qactive[4] = 1'b0;



    assign is_reserved_master_id = (stm_axi_awusers[7:2] >= 2 && stm_axi_awusers[7:2] <= 3) ||
                                   (stm_axi_awusers[7:2] >= 5 && stm_axi_awusers[7:2] <= 31);


    assign stm_axi_awaddrs_mapped_id[31:30] = stm_axi_awaddrs[31:30];
    assign stm_axi_awaddrs_mapped_id[29:24] = is_reserved_master_id ? 6'd3 : stm_axi_awusers[7:2];
    assign stm_axi_awaddrs_mapped_id[23: 0] = stm_axi_awaddrs[23:0];

    CXSTM500  #(
        .AXI_ID_WIDTH(STM_AXI_ID_WIDTH)
    ) u_host_stm (
        .CLK        (dbgclk_gated),        
        .ARESETn    (dbgclk_resetn), 
        .STMRESETn  (dbgclk_resetn), 

        .ARIDS   (stm_axi_arids),    
        .ARADDRS (stm_axi_araddrs),  
        .ARLENS  (stm_axi_arlens),   
        .ARSIZES (stm_axi_arsizes),  
        .ARBURSTS(stm_axi_arbursts), 
        .ARLOCKS (stm_axi_arlocks),  
        .ARCACHES(stm_axi_arcaches), 
        .ARPROTS (stm_axi_arprots),  
        .ARVALIDS(stm_axi_arvalids), 
        .ARREADYS(stm_axi_arreadys), 

        .RREADYS (stm_axi_rreadys),  
        .RIDS    (stm_axi_rids),     
        .RDATAS  (stm_axi_rdatas),   
        .RRESPS  (stm_axi_rresps),   
        .RLASTS  (stm_axi_rlasts),   
        .RVALIDS (stm_axi_rvalids),  

        .AWADDRS (stm_axi_awaddrs_mapped_id),  
        .AWIDS   (stm_axi_awids),    
        .AWLENS  (stm_axi_awlens),   
        .AWSIZES (stm_axi_awsizes),  
        .AWBURSTS(stm_axi_awbursts), 
        .AWLOCKS (stm_axi_awlocks),  
        .AWCACHES(stm_axi_awcaches), 
        .AWPROTS (stm_axi_awprots),  
        .AWVALIDS(stm_axi_awvalids), 
        .AWREADYS(stm_axi_awreadys), 

        .WDATAS  (stm_axi_wdatas),   
        .WSTRBS  (stm_axi_wstrbs),   
        .WLASTS  (stm_axi_wlasts),   
        .WVALIDS (stm_axi_wvalids),  
        .WREADYS (stm_axi_wreadys),  

        .BREADYS (stm_axi_breadys),  
        .BIDS    (stm_axi_bids),     
        .BRESPS  (stm_axi_bresps),   
        .BVALIDS (stm_axi_bvalids),  

        .PSELDBG   (u_expander_host_psel_m_to_u_host_stm_pseldbg),       
        .PENABLEDBG(u_expander_host_penable_m_to_u_host_stm_penabledbg), 
        .PWRITEDBG (u_expander_host_pwrite_m_to_u_host_stm_pwritedbg),   
        .PADDRDBG31(1'b1),                                               
        .PADDRDBG  (u_expander_host_paddr_m_to_u_host_stm_paddrdbg[11:2]),     
        .PWDATADBG (u_expander_host_pwdata_m_to_u_host_stm_pwdatadbg),   
        .PREADYDBG (u_expander_host_pready_m_to_u_host_stm_preadydbg),   
        .PSLVERRDBG(u_expander_host_pslverr_m_to_u_host_stm_pslverrdbg), 
        .PRDATADBG (u_expander_host_prdata_m_to_u_host_stm_prdatadbg),   

        .ATVALIDM (u_host_stm_atvalidm_to_u_host_downsizer_atvalid_s),    
        .ATREADYM (u_host_stm_atreadym_to_u_host_downsizer_atready_s),    
        .AFVALIDM (u_host_stm_afvalidm_to_u_host_downsizer_afvalid_s),    
        .AFREADYM (u_host_stm_afreadym_to_u_host_downsizer_afready_s),    
        .SYNCREQM (u_host_stm_syncreqm_to_u_host_downsizer_syncreq_s),    
        .ATBYTESM (u_host_stm_atbytesm_to_u_host_downsizer_atbytes_s),    
        .ATDATAM  (u_host_stm_atdatam_to_u_host_downsizer_atdata_s),      
        .ATIDM    (u_host_stm_atidm_to_u_host_downsizer_atid_s),          

        .HWEVENTS({60'd0,
                   ~u_host_cti_event_out_5_to_u_host_stm_hwevents2,
                    u_host_cti_event_out_5_to_u_host_stm_hwevents2,
                   ~u_host_cti_event_out_4_to_u_host_stm_hwevents0,
                    u_host_cti_event_out_4_to_u_host_stm_hwevents0}),     
        .HEEXTMUX(),     

        .DRREADY(stm_drready),           
        .DAVALID(stm_davalid),           
        .DATYPE (stm_datype ),          
        .DRVALID(stm_drvalid),          
        .DRTYPE (stm_drtype ),          
        .DRLAST (stm_drlast ),          
        .DAREADY(stm_daready),          

        .TSVALUE(tsvalueb_binary_tsintp),      

        .DBGEN  (dbgen_hostauth_ss),        
        .NIDEN  (niden_hostauth_ss),        
        .SPIDEN (spiden_hostauth_ss),       
        .SPNIDEN(spniden_hostauth_ss),      

        .NSGUAREN(1'b1),

        .TRIGOUTSPTE(u_host_stm_trigoutspte_to_u_host_cti_event_in_7), 
        .TRIGOUTSW  (u_host_stm_trigoutsw_to_u_host_cti_event_in_6),   
        .TRIGOUTHETE(u_host_stm_trigouthete_to_u_host_cti_event_in_5), 
        .ASYNCOUT   (u_host_stm_asyncout_to_u_host_cti_event_in_4),    

        .DFTCLKCGEN(dftcgen),   

        .AXIQREQn   (dbgclk_qreqn   [5]),  
        .AXIQACCEPTn(dbgclk_qacceptn[5]),      
        .AXIQDENY   (dbgclk_qdeny   [5]),      
        .AXIQACTIVE (dbgclk_qactive[5]),      
        .AWAKEUP    (1'b0),  

        .STMQREQn   (dbgclk_qreqn   [6]),  
        .STMQACCEPTn(dbgclk_qacceptn[6]),      
        .STMQDENY   (dbgclk_qdeny   [6]),      
        .STMQACTIVE (dbgclk_qactive[6]),      
        .PWAKEUP    (1'b0)   
    );


    css600_atbdownsizer #(
      .ATB_SLAVE_DATA_WIDTH (64),
      .ATB_MASTER_DATA_WIDTH(32)
    ) u_host_downsizer (
        .clk        (dbgclk_gated),
        .reset_n    (dbgclk_resetn),
        .atwakeup_s (1'b0),
        .atvalid_s  (u_host_stm_atvalidm_to_u_host_downsizer_atvalid_s),
        .atready_s  (u_host_stm_atreadym_to_u_host_downsizer_atready_s),
        .afvalid_s  (u_host_stm_afvalidm_to_u_host_downsizer_afvalid_s),
        .afready_s  (u_host_stm_afreadym_to_u_host_downsizer_afready_s),
        .syncreq_s  (u_host_stm_syncreqm_to_u_host_downsizer_syncreq_s),
        .atid_s     (u_host_stm_atidm_to_u_host_downsizer_atid_s),
        .atdata_s   (u_host_stm_atdatam_to_u_host_downsizer_atdata_s),
        .atbytes_s  (u_host_stm_atbytesm_to_u_host_downsizer_atbytes_s),
        .atwakeup_m (u_host_downsizer_atwakeup_m_to_u_host_funnel_atwakeup_s),
        .atvalid_m  (u_host_downsizer_atvalid_m_to_u_host_funnel_atvalid_s),
        .atready_m  (u_host_downsizer_atready_m_to_u_host_funnel_atready_s),
        .afvalid_m  (u_host_downsizer_afvalid_m_to_u_host_funnel_afvalid_s),
        .afready_m  (u_host_downsizer_afready_m_to_u_host_funnel_afready_s),
        .syncreq_m  (u_host_downsizer_syncreq_m_to_u_host_funnel_syncreq_s),
        .atid_m     (u_host_downsizer_atid_m_to_u_host_funnel_atid_s),
        .atdata_m   (u_host_downsizer_atdata_m_to_u_host_funnel_atdata_s),
        .atbytes_m  (u_host_downsizer_atbytes_m_to_u_host_funnel_atbytes_s),
        .clk_qactive(dbgclk_qactive_only[4])
    );
    assign irq_host_stm = u_host_stm_asyncout_to_u_host_cti_event_in_4; 




    css600_atbfunnel_prog #(
        .NUM_ATB_SLAVES (HOST_FUNNEL_NUM_ATB_SLAVES)
    ) u_host_funnel (
        .clk        (dbgclk_gated),
        .reset_n    (dbgclk_resetn),

        .pwakeup_s  (u_expander_host_pwakeup_m_to_u_host_funnel_pwakeup_s),
        .psel_s     (u_expander_host_psel_m_to_u_host_funnel_psel_s),
        .penable_s  (u_expander_host_penable_m_to_u_host_funnel_penable_s),
        .pwrite_s   (u_expander_host_pwrite_m_to_u_host_funnel_pwrite_s),
        .paddr_s    (u_expander_host_paddr_m_to_u_host_funnel_paddr_s),
        .pwdata_s   (u_expander_host_pwdata_m_to_u_host_funnel_pwdata_s),
        .pready_s   (u_expander_host_pready_m_to_u_host_funnel_pready_s),
        .pslverr_s  (u_expander_host_pslverr_m_to_u_host_funnel_pslverr_s),
        .prdata_s   (u_expander_host_prdata_m_to_u_host_funnel_prdata_s),

        .atwakeup_s ({hostdbgtraceexp_atwakeup_s,
                      hostcputrace_atwakeup_s,
                      u_host_downsizer_atwakeup_m_to_u_host_funnel_atwakeup_s}),
        .atid_s     ({hostdbgtraceexp_atid_s,
                      hostcputrace_atid_s,
                      u_host_downsizer_atid_m_to_u_host_funnel_atid_s}),
        .atbytes_s  ({hostdbgtraceexp_atbytes_s,
                      hostcputrace_atbytes_s,
                      u_host_downsizer_atbytes_m_to_u_host_funnel_atbytes_s}),
        .atdata_s   ({hostdbgtraceexp_atdata_s,
                      hostcputrace_atdata_s,
                      u_host_downsizer_atdata_m_to_u_host_funnel_atdata_s}),
        .atvalid_s  ({hostdbgtraceexp_atvalid_s,
                      hostcputrace_atvalid_s,
                      u_host_downsizer_atvalid_m_to_u_host_funnel_atvalid_s}),
        .atready_s  ({hostdbgtraceexp_atready_s,
                      hostcputrace_atready_s,
                      u_host_downsizer_atready_m_to_u_host_funnel_atready_s}),
        .afvalid_s  ({hostdbgtraceexp_afvalid_s,
                      hostcputrace_afvalid_s,
                      u_host_downsizer_afvalid_m_to_u_host_funnel_afvalid_s}),
        .afready_s  ({hostdbgtraceexp_afready_s,
                      hostcputrace_afready_s,
                      u_host_downsizer_afready_m_to_u_host_funnel_afready_s}),
        .syncreq_s  ({hostdbgtraceexp_syncreq_s,
                      hostcputrace_syncreq_s,
                      u_host_downsizer_syncreq_m_to_u_host_funnel_syncreq_s}),


        .atwakeup_m (u_host_funnel_atwakeup_m_to_u_host_atbbuffer_atwakeup_s),
        .atid_m     (u_host_funnel_atid_m_to_u_host_atbbuffer_atid_s),
        .atbytes_m  (u_host_funnel_atbytes_m_to_u_host_atbbuffer_atbytes_s),
        .atdata_m   (u_host_funnel_atdata_m_to_u_host_atbbuffer_atdata_s),
        .atvalid_m  (u_host_funnel_atvalid_m_to_u_host_atbbuffer_atvalid_s),
        .atready_m  (u_host_funnel_atready_m_to_u_host_atbbuffer_atready_s),
        .afvalid_m  (u_host_funnel_afvalid_m_to_u_host_atbbuffer_afvalid_s),
        .afready_m  (u_host_funnel_afready_m_to_u_host_atbbuffer_afready_s),
        .syncreq_m  (u_host_funnel_syncreq_m_to_u_host_atbbuffer_syncreq_s),


        .clk_qactive(dbgclk_qactive_only[1])

    );

    css600_atbbuffer #(
        .ATB_DATA_WIDTH (32),
        .BUFFER_DEPTH   (4),
        .MIN_HOLD_TIME  (1)
    ) u_host_atbbuffer (
        .clk        (dbgclk_gated),
        .reset_n    (dbgclk_resetn),
        .atwakeup_s (u_host_funnel_atwakeup_m_to_u_host_atbbuffer_atwakeup_s),
        .atvalid_s  (u_host_funnel_atvalid_m_to_u_host_atbbuffer_atvalid_s),
        .atready_s  (u_host_funnel_atready_m_to_u_host_atbbuffer_atready_s),
        .atid_s     (u_host_funnel_atid_m_to_u_host_atbbuffer_atid_s),
        .atdata_s   (u_host_funnel_atdata_m_to_u_host_atbbuffer_atdata_s),
        .atbytes_s  (u_host_funnel_atbytes_m_to_u_host_atbbuffer_atbytes_s),
        .afready_s  (u_host_funnel_afready_m_to_u_host_atbbuffer_afready_s),
        .afvalid_s  (u_host_funnel_afvalid_m_to_u_host_atbbuffer_afvalid_s),
        .syncreq_s  (u_host_funnel_syncreq_m_to_u_host_atbbuffer_syncreq_s),
        .afready_m  (u_host_atbbuffer_afready_m_to_u_host_replicator_afready_s),
        .afvalid_m  (u_host_atbbuffer_afvalid_m_to_u_host_replicator_afvalid_s),
        .atwakeup_m (u_host_atbbuffer_atwakeup_m_to_u_host_replicator_atwakeup_s),
        .atvalid_m  (u_host_atbbuffer_atvalid_m_to_u_host_replicator_atvalid_s),
        .atready_m  (u_host_atbbuffer_atready_m_to_u_host_replicator_atready_s),
        .atid_m     (u_host_atbbuffer_atid_m_to_u_host_replicator_atid_s),
        .atdata_m   (u_host_atbbuffer_atdata_m_to_u_host_replicator_atdata_s),
        .atbytes_m  (u_host_atbbuffer_atbytes_m_to_u_host_replicator_atbytes_s),
        .syncreq_m  (u_host_atbbuffer_syncreq_m_to_u_host_replicator_syncreq_s),
        .clk_qactive()
    );

    css600_atbfunnel_prog #(
        .NUM_ATB_SLAVES (SOC_FUNNEL_NUM_ATB_SLAVES)
    ) u_soc_funnel (
        .clk        (dbgclk_gated),
        .reset_n    (dbgclk_resetn),

        .pwakeup_s  (u_expander_soc_pwakeup_m_to_u_soc_funnel_pwakeup_s),
        .psel_s     (u_expander_soc_psel_m_to_u_soc_funnel_psel_s),
        .penable_s  (u_expander_soc_penable_m_to_u_soc_funnel_penable_s),
        .pwrite_s   (u_expander_soc_pwrite_m_to_u_soc_funnel_pwrite_s),
        .paddr_s    (u_expander_soc_paddr_m_to_u_soc_funnel_paddr_s),
        .pwdata_s   (u_expander_soc_pwdata_m_to_u_soc_funnel_pwdata_s),
        .pready_s   (u_expander_soc_pready_m_to_u_soc_funnel_pready_s),
        .pslverr_s  (u_expander_soc_pslverr_m_to_u_soc_funnel_pslverr_s),
        .prdata_s   (u_expander_soc_prdata_m_to_u_soc_funnel_prdata_s),

        .atwakeup_s ({
                      extsys1_atwakeup_s,
                      extsys0_atwakeup_s,
                      u_host_replicator_atwakeup_m_to_u_soc_funnel_atwakeup_s}),
        .atid_s     ({
                      extsys1_atid_s,
                      extsys0_atid_s,
                      u_host_replicator_atid_m_to_u_soc_funnel_atid_s}),
        .atbytes_s  ({
                      extsys1_atbytes_s,
                      extsys0_atbytes_s,
                      u_host_replicator_atbytes_m_to_u_soc_funnel_atbytes_s}),
        .atdata_s   ({
                      extsys1_atdata_s,
                      extsys0_atdata_s,
                      u_host_replicator_atdata_m_to_u_soc_funnel_atdata_s}),
        .atvalid_s  ({
                      extsys1_atvalid_s,
                      extsys0_atvalid_s,
                      u_host_replicator_atvalid_m_to_u_soc_funnel_atvalid_s}),
        .atready_s  ({
                      extsys1_atready_s,
                      extsys0_atready_s,
                      u_host_replicator_atready_m_to_u_soc_funnel_atready_s}),
        .afvalid_s  ({
                      extsys1_afvalid_s,
                      extsys0_afvalid_s,
                      u_host_replicator_afvalid_m_to_u_soc_funnel_afvalid_s}),
        .afready_s  ({
                      extsys1_afready_s,
                      extsys0_afready_s,
                      u_host_replicator_afready_m_to_u_soc_funnel_afready_s}),
        .syncreq_s  ({
                      extsys1_syncreq_s,
                      extsys0_syncreq_s,
                      u_host_replicator_syncreq_m_to_u_soc_funnel_syncreq_s}),


        .atwakeup_m (u_soc_funnel_atwakeup_m_to_u_soc_replicator_atwakeup_s),
        .atid_m     (u_soc_funnel_atid_m_to_u_soc_replicator_atid_s),
        .atbytes_m  (u_soc_funnel_atbytes_m_to_u_soc_replicator_atbytes_s),
        .atdata_m   (u_soc_funnel_atdata_m_to_u_soc_replicator_atdata_s),
        .atvalid_m  (u_soc_funnel_atvalid_m_to_u_soc_replicator_atvalid_s),
        .atready_m  (u_soc_funnel_atready_m_to_u_soc_replicator_atready_s),
        .afvalid_m  (u_soc_funnel_afvalid_m_to_u_soc_replicator_afvalid_s),
        .afready_m  (u_soc_funnel_afready_m_to_u_soc_replicator_afready_s),
        .syncreq_m  (u_soc_funnel_syncreq_m_to_u_soc_replicator_syncreq_s),


        .clk_qactive(dbgclk_qactive_only[2])

    );

    css600_atbreplicator_prog u_soc_replicator (
        .clk        (dbgclk_gated),
        .reset_n    (dbgclk_resetn),

        .pwakeup_s  (u_expander_soc_pwakeup_m_to_u_soc_replicator_pwakeup_s),
        .psel_s     (u_expander_soc_psel_m_to_u_soc_replicator_psel_s),
        .penable_s  (u_expander_soc_penable_m_to_u_soc_replicator_penable_s),
        .pwrite_s   (u_expander_soc_pwrite_m_to_u_soc_replicator_pwrite_s),
        .paddr_s    (u_expander_soc_paddr_m_to_u_soc_replicator_paddr_s),
        .pwdata_s   (u_expander_soc_pwdata_m_to_u_soc_replicator_pwdata_s),
        .pready_s   (u_expander_soc_pready_m_to_u_soc_replicator_pready_s),
        .pslverr_s  (u_expander_soc_pslverr_m_to_u_soc_replicator_pslverr_s),
        .prdata_s   (u_expander_soc_prdata_m_to_u_soc_replicator_prdata_s),

        .atwakeup_s (u_soc_funnel_atwakeup_m_to_u_soc_replicator_atwakeup_s),
        .atid_s     (u_soc_funnel_atid_m_to_u_soc_replicator_atid_s),
        .atbytes_s  (u_soc_funnel_atbytes_m_to_u_soc_replicator_atbytes_s),
        .atdata_s   (u_soc_funnel_atdata_m_to_u_soc_replicator_atdata_s),
        .atvalid_s  (u_soc_funnel_atvalid_m_to_u_soc_replicator_atvalid_s),
        .atready_s  (u_soc_funnel_atready_m_to_u_soc_replicator_atready_s),
        .afvalid_s  (u_soc_funnel_afvalid_m_to_u_soc_replicator_afvalid_s),
        .afready_s  (u_soc_funnel_afready_m_to_u_soc_replicator_afready_s),
        .syncreq_s  (u_soc_funnel_syncreq_m_to_u_soc_replicator_syncreq_s),

        .atwakeup_m ({u_soc_replicator_atwakeup_m_to_u_soc_etr_atwakeup_s,
                      u_soc_replicator_atwakeup_m_to_u_soc_tpiu_atwakeup_s}),
        .atid_m     ({u_soc_replicator_atid_m_to_u_soc_etr_atid_s,
                      u_soc_replicator_atid_m_to_u_soc_tpiu_atid_s}),
        .atbytes_m  ({u_soc_replicator_atbytes_m_to_u_soc_etr_atbytes_s,
                      u_soc_replicator_atbytes_m_to_u_soc_tpiu_atbytes_s}),
        .atdata_m   ({u_soc_replicator_atdata_m_to_u_soc_etr_atdata_s,
                      u_soc_replicator_atdata_m_to_u_soc_tpiu_atdata_s}),
        .atvalid_m  ({u_soc_replicator_atvalid_m_to_u_soc_etr_atvalid_s,
                      u_soc_replicator_atvalid_m_to_u_soc_tpiu_atvalid_s}),
        .atready_m  ({u_soc_replicator_atready_m_to_u_soc_etr_atready_s,
                      u_soc_replicator_atready_m_to_u_soc_tpiu_atready_s}),
        .afvalid_m  ({u_soc_replicator_afvalid_m_to_u_soc_etr_afvalid_s,
                      u_soc_replicator_afvalid_m_to_u_soc_tpiu_afvalid_s}),
        .afready_m  ({u_soc_replicator_afready_m_to_u_soc_etr_afready_s,
                      u_soc_replicator_afready_m_to_u_soc_tpiu_afready_s}),
        .syncreq_m  ({u_soc_replicator_syncreq_m_to_u_soc_etr_syncreq_s,
                      u_soc_replicator_syncreq_m_to_u_soc_tpiu_syncreq_s}),

        .clk_qactive(dbgclk_qactive_only[3])
    );









    css600_tmc_etr #(
        .WBUFFER_DEPTH  (SOC_ETR_WBUFFER_DEPTH),
        .ATB_DATA_WIDTH (SOC_ETR_ATB_DATA_WIDTH),
        .AXI_ADDR_WIDTH (SOC_ETR_AXI_ADDR_WIDTH)
    ) u_soc_etr (
        .clk          (dbgclk_gated),
        .reset_n      (dbgclk_resetn),

        .atwakeup_s   (u_soc_replicator_atwakeup_m_to_u_soc_etr_atwakeup_s),
        .atid_s       (u_soc_replicator_atid_m_to_u_soc_etr_atid_s),
        .atbytes_s    (u_soc_replicator_atbytes_m_to_u_soc_etr_atbytes_s),
        .atdata_s     (u_soc_replicator_atdata_m_to_u_soc_etr_atdata_s),
        .atvalid_s    (u_soc_replicator_atvalid_m_to_u_soc_etr_atvalid_s),
        .atready_s    (u_soc_replicator_atready_m_to_u_soc_etr_atready_s),
        .afvalid_s    (u_soc_replicator_afvalid_m_to_u_soc_etr_afvalid_s),
        .afready_s    (u_soc_replicator_afready_m_to_u_soc_etr_afready_s),
        .syncreq_s    (u_soc_replicator_syncreq_m_to_u_soc_etr_syncreq_s),

        .pwakeup_s    (u_expander_extdbgbus_pwakeup_m_to_u_soc_etr_pwakeup_s),
        .psel_s       (u_expander_extdbgbus_psel_m_to_u_soc_etr_psel_s),
        .penable_s    (u_expander_extdbgbus_penable_m_to_u_soc_etr_penable_s),
        .pwrite_s     (u_expander_extdbgbus_pwrite_m_to_u_soc_etr_pwrite_s),
        .paddr_s      (u_expander_extdbgbus_paddr_m_to_u_soc_etr_paddr_s),
        .pwdata_s     (u_expander_extdbgbus_pwdata_m_to_u_soc_etr_pwdata_s),
        .pready_s     (u_expander_extdbgbus_pready_m_to_u_soc_etr_pready_s),
        .pslverr_s    (u_expander_extdbgbus_pslverr_m_to_u_soc_etr_pslverr_s),
        .prdata_s     (u_expander_extdbgbus_prdata_m_to_u_soc_etr_prdata_s),

        .awakeup_m    (), 
        .araddr_m     (u_soc_etr_araddr_m_to_u_soc_catu_araddr_s),
        .arlen_m      (u_soc_etr_arlen_m_to_u_soc_catu_arlen_s),
        .arsize_m     (u_soc_etr_arsize_m_to_u_soc_catu_arsize_s),
        .arburst_m    (u_soc_etr_arburst_m_to_u_soc_catu_arburst_s),
        .arlock_m     (u_soc_etr_arlock_m_to_u_soc_catu_arlock_s),
        .arcache_m    (u_soc_etr_arcache_m_to_u_soc_catu_arcache_s),
        .arprot_m     (u_soc_etr_arprot_m_to_u_soc_catu_arprot_s),
        .arvalid_m    (u_soc_etr_arvalid_m_to_u_soc_catu_arvalid_s),
        .arready_m    (u_soc_etr_arready_m_to_u_soc_catu_arready_s),
        .rdata_m      (u_soc_etr_rdata_m_to_u_soc_catu_rdata_s),
        .rresp_m      (u_soc_etr_rresp_m_to_u_soc_catu_rresp_s),
        .rlast_m      (u_soc_etr_rlast_m_to_u_soc_catu_rlast_s),
        .rvalid_m     (u_soc_etr_rvalid_m_to_u_soc_catu_rvalid_s),
        .rready_m     (u_soc_etr_rready_m_to_u_soc_catu_rready_s),
        .awaddr_m     (u_soc_etr_awaddr_m_to_u_soc_catu_awaddr_s),
        .awlen_m      (u_soc_etr_awlen_m_to_u_soc_catu_awlen_s),
        .awsize_m     (u_soc_etr_awsize_m_to_u_soc_catu_awsize_s),
        .awburst_m    (u_soc_etr_awburst_m_to_u_soc_catu_awburst_s),
        .awlock_m     (u_soc_etr_awlock_m_to_u_soc_catu_awlock_s),
        .awcache_m    (u_soc_etr_awcache_m_to_u_soc_catu_awcache_s),
        .awprot_m     (u_soc_etr_awprot_m_to_u_soc_catu_awprot_s),
        .awvalid_m    (u_soc_etr_awvalid_m_to_u_soc_catu_awvalid_s),
        .awready_m    (u_soc_etr_awready_m_to_u_soc_catu_awready_s),
        .wdata_m      (u_soc_etr_wdata_m_to_u_soc_catu_wdata_s),
        .wstrb_m      (u_soc_etr_wstrb_m_to_u_soc_catu_wstrb_s),
        .wlast_m      (u_soc_etr_wlast_m_to_u_soc_catu_wlast_s),
        .wvalid_m     (u_soc_etr_wvalid_m_to_u_soc_catu_wvalid_s),
        .wready_m     (u_soc_etr_wready_m_to_u_soc_catu_wready_s),
        .bresp_m      (u_soc_etr_bresp_m_to_u_soc_catu_bresp_s),
        .bvalid_m     (u_soc_etr_bvalid_m_to_u_soc_catu_bvalid_s),
        .bready_m     (u_soc_etr_bready_m_to_u_soc_catu_bready_s),

        .dbgen        (dbgen_tpiuauth_ss),
        .spiden       (spiden_tpiuauth_ss),

        .clk_qreq_n   (dbgclk_qreqn   [7]),
        .clk_qaccept_n(dbgclk_qacceptn[7]),
        .clk_qdeny    (dbgclk_qdeny   [7]),
        .clk_qactive  (dbgclk_qactive[7]),

        .trigin       (u_soc_cti_event_out_8_to_u_soc_etr_trigin),
        .flushin      (u_soc_cti_event_out_7_to_u_soc_etr_flushin),
        .full         (u_soc_etr_full_to_u_soc_cti_event_in_5),
        .acqcomp      (u_soc_etr_acqcomp_to_u_soc_cti_event_in_6),
        .flushcomp    (u_soc_etr_flushcomp_to_u_soc_cti_event_in_7),

        .bufintr      (irq_soc_etr), 

        .dftcgen      (dftcgen)
    );








    css600_tpiu u_soc_tpiu (
        .clk           (dbgclk_gated),
        .reset_n       (dbgclk_resetn),
        .pwakeup_s     (u_expander_extdbgbus_pwakeup_m_to_u_soc_tpiu_pwakeup_s),
        .psel_s        (u_expander_extdbgbus_psel_m_to_u_soc_tpiu_psel_s),
        .penable_s     (u_expander_extdbgbus_penable_m_to_u_soc_tpiu_penable_s),
        .pwrite_s      (u_expander_extdbgbus_pwrite_m_to_u_soc_tpiu_pwrite_s),
        .paddr_s       (u_expander_extdbgbus_paddr_m_to_u_soc_tpiu_paddr_s),
        .pwdata_s      (u_expander_extdbgbus_pwdata_m_to_u_soc_tpiu_pwdata_s),
        .pready_s      (u_expander_extdbgbus_pready_m_to_u_soc_tpiu_pready_s),
        .pslverr_s     (u_expander_extdbgbus_pslverr_m_to_u_soc_tpiu_pslverr_s),
        .prdata_s      (u_expander_extdbgbus_prdata_m_to_u_soc_tpiu_prdata_s),

        .atwakeup_s    (u_soc_replicator_atwakeup_m_to_u_soc_tpiu_atwakeup_s),
        .atid_s        (u_soc_replicator_atid_m_to_u_soc_tpiu_atid_s),
        .atdata_s      (u_soc_replicator_atdata_m_to_u_soc_tpiu_atdata_s),
        .atbytes_s     (u_soc_replicator_atbytes_m_to_u_soc_tpiu_atbytes_s),
        .atvalid_s     (u_soc_replicator_atvalid_m_to_u_soc_tpiu_atvalid_s),
        .atready_s     (u_soc_replicator_atready_m_to_u_soc_tpiu_atready_s),
        .afvalid_s     (u_soc_replicator_afvalid_m_to_u_soc_tpiu_afvalid_s),
        .afready_s     (u_soc_replicator_afready_m_to_u_soc_tpiu_afready_s),
        .syncreq_s     (u_soc_replicator_syncreq_m_to_u_soc_tpiu_syncreq_s),
        .traceclk_in   (traceclk_in),
        .treset_n      (treset_n),
        .traceclk      (traceclk),
        .tracedata     (tracedata),
        .tracectl      (tracectl),
        .tpctl_valid   (tpctl_valid),
        .traceclk_in_qactive(),
        .tp_maxdatasize(tp_maxdatasize),
        .trigin        (u_soc_cti_event_out_4_to_u_soc_tpiu_trigin),
        .flushin       (u_soc_cti_event_out_5_to_u_soc_tpiu_flushin),
        .flushcomp     (u_soc_tpiu_flushcomp_to_u_soc_cti_event_in_4),
        .clk_qreq_n    (dbgclk_qreqn   [8]),
        .clk_qaccept_n (dbgclk_qacceptn[8]),
        .clk_qdeny     (dbgclk_qdeny   [8]),
        .clk_qactive   (dbgclk_qactive[8]),
        .extctl_in     (8'd0),
        .extctl_out    (),
        .dftcgen       (dftcgen)
    );




    css600_apbicdecoder #(
        .APB_SLAVE_ADDR_WIDTH   (32),
        .NUM_APB_SLAVES         (1),
        .NUM_APB_MASTERS        (EXTDBGBUS_MASTERS),
        .NUM_EXPANDERS          (1),
        .M0_BASE_ADDR           (32'h0003_0000), 
        .M1_BASE_ADDR           (32'h0005_0000), 
        .M2_BASE_ADDR           (32'h0006_0000), 
        .M3_BASE_ADDR           (32'h0007_0000), 
        .M4_BASE_ADDR           (32'h0020_0000), 
        .M5_BASE_ADDR           (32'h0030_0000), 
        .M6_BASE_ADDR           (32'h0010_0000), 
        .M7_BASE_ADDR           (32'h0011_0000), 
        .M8_BASE_ADDR           (32'h0012_0000), 
        .M9_BASE_ADDR           (32'h0013_0000), 
        .M10_BASE_ADDR          (32'h0014_0000), 
        .M11_BASE_ADDR          (32'h0015_0000), 
        .M12_BASE_ADDR          (32'h0016_0000), 
        .M13_BASE_ADDR          (32'h0004_0000), 
        .M0_ADDR_WIDTH          (12),
        .M1_ADDR_WIDTH          (13),
        .M2_ADDR_WIDTH          (12),
        .M3_ADDR_WIDTH          (13),
        .M4_ADDR_WIDTH          (20),
        .M5_ADDR_WIDTH          (20),
        .M6_ADDR_WIDTH          (12),
        .M7_ADDR_WIDTH          (12),
        .M8_ADDR_WIDTH          (12),
        .M9_ADDR_WIDTH          (12),
        .M10_ADDR_WIDTH         (12),
        .M11_ADDR_WIDTH         (12),
        .M12_ADDR_WIDTH         (12),
        .M13_ADDR_WIDTH         (12)
    ) u_decoder_extdbgbus (
        .clk          (dbgclk_gated),
        .reset_n      (dbgclk_resetn),

        .pwakeup_s    (apbdbg_pwakeup_s),
        .psel_s       (apbdbg_psel_s),
        .penable_s    (apbdbg_penable_s),
        .pwrite_s     (apbdbg_pwrite_s),
        .pprot_s      (apbdbg_pprot_s),
        .paddr_s      (apbdbg_paddr_s ),
        .pwdata_s     (apbdbg_pwdata_s),
        .pready_s     (apbdbg_pready_s),
        .pslverr_s    (apbdbg_pslverr_s),
        .prdata_s     (apbdbg_prdata_s),


        .pwakeup_e    (u_decoder_extdbgbus_pwakeup_e_to_u_expander_extdbgbus_pwakeup_e),
        .psel_e       (u_decoder_extdbgbus_psel_e_to_u_expander_extdbgbus_psel_e),
        .penable_e    (u_decoder_extdbgbus_penable_e_to_u_expander_extdbgbus_penable_e),
        .pwrite_e     (u_decoder_extdbgbus_pwrite_e_to_u_expander_extdbgbus_pwrite_e),
        .pprot_e      (u_decoder_extdbgbus_pprot_e_to_u_expander_extdbgbus_pprot_e),
        .paddr_e      (u_decoder_extdbgbus_paddr_e_to_u_expander_extdbgbus_paddr_e),
        .pwdata_e     (u_decoder_extdbgbus_pwdata_e_to_u_expander_extdbgbus_pwdata_e),
        .pready_e     (u_decoder_extdbgbus_pready_e_to_u_expander_extdbgbus_pready_e),
        .pslverr_e    (u_decoder_extdbgbus_pslverr_e_to_u_expander_extdbgbus_pslverr_e),
        .prdata_e     (u_decoder_extdbgbus_prdata_e_to_u_expander_extdbgbus_prdata_e),

        .clk_qreq_n   (dbgclk_qreqn   [15]),
        .clk_qaccept_n(dbgclk_qacceptn[15]),
        .clk_qdeny    (dbgclk_qdeny   [15]),
        .clk_qactive  (dbgclk_qactive[15])
    );



    css600_apbicexpander #(
        .APB_SLAVE_ADDR_WIDTH   (32),
        .NUM_APB_SLAVES         (1),
        .NUM_APB_MASTERS        (EXTDBGBUS_MASTERS),
        .NUM_EXPANDERS          (1),
        .M0_BASE_ADDR           (32'h0002_0000), 
        .M1_BASE_ADDR           (32'h0004_0000), 
        .M2_BASE_ADDR           (32'h0005_0000), 
        .M3_BASE_ADDR           (32'h0006_0000), 
        .M4_BASE_ADDR           (32'h0020_0000), 
        .M5_BASE_ADDR           (32'h0030_0000), 
        .M6_BASE_ADDR           (32'h0010_0000), 
        .M7_BASE_ADDR           (32'h0011_0000), 
        .M8_BASE_ADDR           (32'h0012_0000), 
        .M9_BASE_ADDR           (32'h0013_0000), 
        .M10_BASE_ADDR          (32'h0014_0000), 
        .M11_BASE_ADDR          (32'h0015_0000), 
        .M12_BASE_ADDR          (32'h0016_0000), 
        .M13_BASE_ADDR          (32'h0003_0000), 
        .M0_ADDR_WIDTH          (12),
        .M1_ADDR_WIDTH          (13),
        .M2_ADDR_WIDTH          (12),
        .M3_ADDR_WIDTH          (13),
        .M4_ADDR_WIDTH          (20),
        .M5_ADDR_WIDTH          (20),
        .M6_ADDR_WIDTH          (12),
        .M7_ADDR_WIDTH          (12),
        .M8_ADDR_WIDTH          (12),
        .M9_ADDR_WIDTH          (12),
        .M10_ADDR_WIDTH         (12),
        .M11_ADDR_WIDTH         (12),
        .M12_ADDR_WIDTH         (12),
        .M13_ADDR_WIDTH         (16)
    ) u_expander_extdbgbus (
        .clk          (dbgclk_gated),
        .reset_n      (dbgclk_resetn),
        .pwakeup_e    (u_decoder_extdbgbus_pwakeup_e_to_u_expander_extdbgbus_pwakeup_e),
        .psel_e       (u_decoder_extdbgbus_psel_e_to_u_expander_extdbgbus_psel_e),
        .penable_e    (u_decoder_extdbgbus_penable_e_to_u_expander_extdbgbus_penable_e),
        .pwrite_e     (u_decoder_extdbgbus_pwrite_e_to_u_expander_extdbgbus_pwrite_e),
        .pprot_e      (u_decoder_extdbgbus_pprot_e_to_u_expander_extdbgbus_pprot_e),
        .paddr_e      (u_decoder_extdbgbus_paddr_e_to_u_expander_extdbgbus_paddr_e),
        .pwdata_e     (u_decoder_extdbgbus_pwdata_e_to_u_expander_extdbgbus_pwdata_e),
        .pready_e     (u_decoder_extdbgbus_pready_e_to_u_expander_extdbgbus_pready_e),
        .pslverr_e    (u_decoder_extdbgbus_pslverr_e_to_u_expander_extdbgbus_pslverr_e),
        .prdata_e     (u_decoder_extdbgbus_prdata_e_to_u_expander_extdbgbus_prdata_e),

        .pwakeup_m    ({secure_enclave_pwakeup_m,                                         // m13 
                        u_expander_extdbgbus_pwakeup_m_to_u_counter_cti_pwakeup_s,        // m12 
                        u_expander_extdbgbus_pwakeup_m_to_u_soc_catu_pwakeup_s,           // m11 
                        u_expander_extdbgbus_pwakeup_m_to_u_soc_etr_pwakeup_s,            // m10 
                        u_expander_extdbgbus_pwakeup_m_to_u_soc_cti_pwakeup_s,            // m9 
                        u_expander_extdbgbus_pwakeup_m_to_u_soc_tpiu_pwakeup_s,           // m8 
                        u_expander_soc_pwakeup_m_to_u_soc_replicator_pwakeup_s,           // m7 
                        u_expander_soc_pwakeup_m_to_u_soc_funnel_pwakeup_s,               // m6 
                        extsys1_dbgapb_pwakeup_m,                                         
                        extsys0_dbgapb_pwakeup_m,                                         
                        u_expander_extdbgbus_pwakeup_m_to_u_host_axiap_pwakeup_s,         
                        u_expander_extdbgbus_pwakeup_m_to_u_host_axiap_rom_not_used,      
                        u_expander_extdbgbus_pwakeup_m_to_u_host_apbap_pwakeup_s,         
                        u_expander_extdbgbus_pwakeup_m_to_u_extdbg_rom_not_used}),        
        .psel_m       ({secure_enclave_psel_m,                                            // m13 
                        u_expander_extdbgbus_psel_m_to_u_counter_cti_psel_s,              // m12 
                        u_expander_extdbgbus_psel_m_to_u_soc_catu_psel_s,                 // m11 
                        u_expander_extdbgbus_psel_m_to_u_soc_etr_psel_s,                  // m10 
                        u_expander_extdbgbus_psel_m_to_u_soc_cti_psel_s,                  // m9 
                        u_expander_extdbgbus_psel_m_to_u_soc_tpiu_psel_s,                 // m8 
                        u_expander_soc_psel_m_to_u_soc_replicator_psel_s,                 // m7 
                        u_expander_soc_psel_m_to_u_soc_funnel_psel_s,                     // m6 
                        extsys1_dbgapb_psel_m,                                            
                        extsys0_dbgapb_psel_m,                                            
                        u_expander_extdbgbus_psel_m_to_u_host_axiap_psel_s,               
                        u_expander_extdbgbus_psel_m_to_u_host_axiap_rom_psel_s,           
                        u_expander_extdbgbus_psel_m_to_u_host_apbap_psel_s,               
                        u_expander_extdbgbus_psel_m_to_u_extdbg_rom_psel_s}),             
       .penable_m     ({secure_enclave_penable_m,                                         // m13 
                        u_expander_extdbgbus_penable_m_to_u_counter_cti_penable_s,        // m12 
                        u_expander_extdbgbus_penable_m_to_u_soc_catu_penable_s,           // m11 
                        u_expander_extdbgbus_penable_m_to_u_soc_etr_penable_s,            // m10 
                        u_expander_extdbgbus_penable_m_to_u_soc_cti_penable_s,            // m9 
                        u_expander_extdbgbus_penable_m_to_u_soc_tpiu_penable_s,           // m8 
                        u_expander_soc_penable_m_to_u_soc_replicator_penable_s,           // m7 
                        u_expander_soc_penable_m_to_u_soc_funnel_penable_s,               // m6 
                        extsys1_dbgapb_penable_m,                                         
                        extsys0_dbgapb_penable_m,                                         
                        u_expander_extdbgbus_penable_m_to_u_host_axiap_penable_s,         
                        u_expander_extdbgbus_penable_m_to_u_host_axiap_rom_penable_s,     
                        u_expander_extdbgbus_penable_m_to_u_host_apbap_penable_s,         
                        u_expander_extdbgbus_penable_m_to_u_extdbg_rom_penable_s}),       
        .pwrite_m      (u_expander_extdbgbus_pwrite_m),
        .pprot_m       (u_expander_extdbgbus_pprot_m),
        .paddr_m       (u_expander_extdbgbus_paddr_m),
        .pwdata_m      (u_expander_extdbgbus_pwdata_m),
        .prdata_m     ({secure_enclave_prdata_m,                                          // m13 
                        u_expander_extdbgbus_prdata_m_to_u_counter_cti_prdata_s,          // m12 
                        u_expander_extdbgbus_prdata_m_to_u_soc_catu_prdata_s,             // m11 
                        u_expander_extdbgbus_prdata_m_to_u_soc_etr_prdata_s,              // m10 
                        u_expander_extdbgbus_prdata_m_to_u_soc_cti_prdata_s,              // m9 
                        u_expander_extdbgbus_prdata_m_to_u_soc_tpiu_prdata_s,             // m8 
                        u_expander_soc_prdata_m_to_u_soc_replicator_prdata_s,             // m7 
                        u_expander_soc_prdata_m_to_u_soc_funnel_prdata_s,                 // m6 
                        extsys1_dbgapb_prdata_m,                                          
                        extsys0_dbgapb_prdata_m,                                          
                        u_expander_extdbgbus_prdata_m_to_u_host_axiap_prdata_s,           
                        u_expander_extdbgbus_prdata_m_to_u_host_axiap_rom_prdata_s,       
                        u_expander_extdbgbus_prdata_m_to_u_host_apbap_prdata_s,           
                        u_expander_extdbgbus_prdata_m_to_u_extdbg_rom_prdata_s}),         
        .pready_m     ({secure_enclave_pready_m,                                          // m13 
                        u_expander_extdbgbus_pready_m_to_u_counter_cti_pready_s,          // m12 
                        u_expander_extdbgbus_pready_m_to_u_soc_catu_pready_s,             // m11 
                        u_expander_extdbgbus_pready_m_to_u_soc_etr_pready_s,              // m10 
                        u_expander_extdbgbus_pready_m_to_u_soc_cti_pready_s,              // m9 
                        u_expander_extdbgbus_pready_m_to_u_soc_tpiu_pready_s,             // m8 
                        u_expander_soc_pready_m_to_u_soc_replicator_pready_s,             // m7 
                        u_expander_soc_pready_m_to_u_soc_funnel_pready_s,                 // m6 
                        extsys1_dbgapb_pready_m,                                          
                        extsys0_dbgapb_pready_m,                                          
                        u_expander_extdbgbus_pready_m_to_u_host_axiap_pready_s,           
                        u_expander_extdbgbus_pready_m_to_u_host_axiap_rom_pready_s,       
                        u_expander_extdbgbus_pready_m_to_u_host_apbap_pready_s,           
                        u_expander_extdbgbus_pready_m_to_u_extdbg_rom_pready_s}),         
        .pslverr_m    ({secure_enclave_pslverr_m,                                         // m13 
                        u_expander_extdbgbus_pslverr_m_to_u_counter_cti_pslverr_s,        // m12 
                        u_expander_extdbgbus_pslverr_m_to_u_soc_catu_pslverr_s,           // m11 
                        u_expander_extdbgbus_pslverr_m_to_u_soc_etr_pslverr_s,            // m10 
                        u_expander_extdbgbus_pslverr_m_to_u_soc_cti_pslverr_s,            // m9 
                        u_expander_extdbgbus_pslverr_m_to_u_soc_tpiu_pslverr_s,           // m8 
                        u_expander_soc_pslverr_m_to_u_soc_replicator_pslverr_s,           // m7 
                        u_expander_soc_pslverr_m_to_u_soc_funnel_pslverr_s,               // m6 
                        extsys1_dbgapb_pslverr_m,                                         
                        extsys0_dbgapb_pslverr_m,                                         
                        u_expander_extdbgbus_pslverr_m_to_u_host_axiap_pslverr_s,         
                        u_expander_extdbgbus_pslverr_m_to_u_host_axiap_rom_pslverr_s,     
                        u_expander_extdbgbus_pslverr_m_to_u_host_apbap_pslverr_s,         
                        u_expander_extdbgbus_pslverr_m_to_u_extdbg_rom_pslverr_s})        
);



    assign secure_enclave_pwrite_m                                    = u_expander_extdbgbus_pwrite_m;
    assign u_expander_extdbgbus_pwrite_m_to_u_counter_cti_pwrite_s    = u_expander_extdbgbus_pwrite_m;
    assign u_expander_extdbgbus_pwrite_m_to_u_soc_catu_pwrite_s       = u_expander_extdbgbus_pwrite_m;
    assign u_expander_extdbgbus_pwrite_m_to_u_soc_etr_pwrite_s        = u_expander_extdbgbus_pwrite_m;
    assign u_expander_extdbgbus_pwrite_m_to_u_soc_cti_pwrite_s        = u_expander_extdbgbus_pwrite_m;
    assign u_expander_extdbgbus_pwrite_m_to_u_soc_tpiu_pwrite_s       = u_expander_extdbgbus_pwrite_m;
    assign u_expander_soc_pwrite_m_to_u_soc_replicator_pwrite_s       = u_expander_extdbgbus_pwrite_m;
    assign u_expander_soc_pwrite_m_to_u_soc_funnel_pwrite_s           = u_expander_extdbgbus_pwrite_m;
    assign extsys1_dbgapb_pwrite_m                                    = u_expander_extdbgbus_pwrite_m;
    assign extsys0_dbgapb_pwrite_m                                    = u_expander_extdbgbus_pwrite_m;
    assign u_expander_extdbgbus_pwrite_m_to_u_host_axiap_pwrite_s     = u_expander_extdbgbus_pwrite_m;
    assign u_expander_extdbgbus_pwrite_m_to_u_host_axiap_rom_pwrite_s = u_expander_extdbgbus_pwrite_m;
    assign u_expander_extdbgbus_pwrite_m_to_u_host_apbap_pwrite_s     = u_expander_extdbgbus_pwrite_m;
    assign u_expander_extdbgbus_pwrite_m_to_u_extdbg_rom_pwrite_s     = u_expander_extdbgbus_pwrite_m;

    assign secure_enclave_paddr_m                                     = u_expander_extdbgbus_paddr_m[15:0];
    assign u_expander_extdbgbus_paddr_m_to_u_counter_cti_paddr_s      = u_expander_extdbgbus_paddr_m[11:0];
    assign u_expander_extdbgbus_paddr_m_to_u_soc_catu_paddr_s         = u_expander_extdbgbus_paddr_m[11:0];
    assign u_expander_extdbgbus_paddr_m_to_u_soc_etr_paddr_s          = u_expander_extdbgbus_paddr_m[11:0];
    assign u_expander_extdbgbus_paddr_m_to_u_soc_cti_paddr_s          = u_expander_extdbgbus_paddr_m[11:0];
    assign u_expander_extdbgbus_paddr_m_to_u_soc_tpiu_paddr_s         = u_expander_extdbgbus_paddr_m[11:0];
    assign u_expander_soc_paddr_m_to_u_soc_replicator_paddr_s         = u_expander_extdbgbus_paddr_m[11:0];
    assign u_expander_soc_paddr_m_to_u_soc_funnel_paddr_s             = u_expander_extdbgbus_paddr_m[11:0];
    assign extsys1_dbgapb_paddr_m                                     = u_expander_extdbgbus_paddr_m;
    assign extsys0_dbgapb_paddr_m                                     = u_expander_extdbgbus_paddr_m;
    assign u_expander_extdbgbus_paddr_m_to_u_host_axiap_paddr_s       = u_expander_extdbgbus_paddr_m[12:0];
    assign u_expander_extdbgbus_paddr_m_to_u_host_axiap_rom_paddr_s   = u_expander_extdbgbus_paddr_m[11:0];
    assign u_expander_extdbgbus_paddr_m_to_u_host_apbap_paddr_s       = u_expander_extdbgbus_paddr_m[12:0];
    assign u_expander_extdbgbus_paddr_m_to_u_extdbg_rom_paddr_s       = u_expander_extdbgbus_paddr_m[11:0];

    assign secure_enclave_pprot_m                                     = u_expander_extdbgbus_pprot_m;
    assign extsys1_dbgapb_pprot_m                                     = u_expander_extdbgbus_pprot_m;
    assign extsys0_dbgapb_pprot_m                                     = u_expander_extdbgbus_pprot_m;

    assign secure_enclave_pwdata_m                                    = u_expander_extdbgbus_pwdata_m;
    assign u_expander_extdbgbus_pwdata_m_to_u_counter_cti_pwdata_s    = u_expander_extdbgbus_pwdata_m;
    assign u_expander_extdbgbus_pwdata_m_to_u_soc_catu_pwdata_s       = u_expander_extdbgbus_pwdata_m;
    assign u_expander_extdbgbus_pwdata_m_to_u_soc_etr_pwdata_s        = u_expander_extdbgbus_pwdata_m;
    assign u_expander_extdbgbus_pwdata_m_to_u_soc_cti_pwdata_s        = u_expander_extdbgbus_pwdata_m;
    assign u_expander_extdbgbus_pwdata_m_to_u_soc_tpiu_pwdata_s       = u_expander_extdbgbus_pwdata_m;
    assign u_expander_soc_pwdata_m_to_u_soc_replicator_pwdata_s       = u_expander_extdbgbus_pwdata_m;
    assign u_expander_soc_pwdata_m_to_u_soc_funnel_pwdata_s           = u_expander_extdbgbus_pwdata_m;
    assign extsys1_dbgapb_pwdata_m                                    = u_expander_extdbgbus_pwdata_m;
    assign extsys0_dbgapb_pwdata_m                                    = u_expander_extdbgbus_pwdata_m;
    assign u_expander_extdbgbus_pwdata_m_to_u_host_axiap_pwdata_s     = u_expander_extdbgbus_pwdata_m;
    assign u_expander_extdbgbus_pwdata_m_to_u_host_axiap_rom_pwdata_s = u_expander_extdbgbus_pwdata_m;
    assign u_expander_extdbgbus_pwdata_m_to_u_host_apbap_pwdata_s     = u_expander_extdbgbus_pwdata_m;
    assign u_expander_extdbgbus_pwdata_m_to_u_extdbg_rom_pwdata_s     = u_expander_extdbgbus_pwdata_m;


    
    css600_apbap u_host_apbap (
        .clk            (dbgclk_gated),
        .reset_n        (dbgclk_resetn),

        .pwakeup_s      (u_expander_extdbgbus_pwakeup_m_to_u_host_apbap_pwakeup_s),
        .psel_s         (u_expander_extdbgbus_psel_m_to_u_host_apbap_psel_s),
        .penable_s      (u_expander_extdbgbus_penable_m_to_u_host_apbap_penable_s),
        .pwrite_s       (u_expander_extdbgbus_pwrite_m_to_u_host_apbap_pwrite_s),
        .paddr_s        (u_expander_extdbgbus_paddr_m_to_u_host_apbap_paddr_s),
        .pwdata_s       (u_expander_extdbgbus_pwdata_m_to_u_host_apbap_pwdata_s),
        .pready_s       (u_expander_extdbgbus_pready_m_to_u_host_apbap_pready_s),
        .pslverr_s      (u_expander_extdbgbus_pslverr_m_to_u_host_apbap_pslverr_s),
        .prdata_s       (u_expander_extdbgbus_prdata_m_to_u_host_apbap_prdata_s),

        .pwakeup_m      (u_host_apbap_pwakeup_m_to_u_decoder_host_pwakeup_s),
        .psel_m         (u_host_apbap_psel_m_to_u_decoder_host_psel_s),
        .penable_m      (u_host_apbap_penable_m_to_u_decoder_host_penable_s),
        .pwrite_m       (u_host_apbap_pwrite_m_to_u_decoder_host_pwrite_s),
        .paddr_m        (u_host_apbap_paddr_m_to_u_decoder_host_paddr_s),
        .pwdata_m       (u_host_apbap_pwdata_m_to_u_decoder_host_pwdata_s),
        .pprot_m        (u_host_apbap_pprot_m_to_u_decoder_host_pprot_s),
        .pready_m       (u_host_apbap_pready_m_to_u_decoder_host_pready_s),
        .pslverr_m      (u_host_apbap_pslverr_m_to_u_decoder_host_pslverr_s),
        .prdata_m       (u_host_apbap_prdata_m_to_u_decoder_host_prdata_s),

        .clk_qreq_n     (dbgclk_qreqn   [9]),
        .clk_qaccept_n  (dbgclk_qacceptn[9]),
        .clk_qdeny      (dbgclk_qdeny   [9]),
        .clk_qactive    (dbgclk_qactive[9]),

        .ap_en          (ap_en_hostextauth_ss),
        .ap_secure_en   (ap_secure_en_hostextauth_ss),        
        .dp_abort       (dp_abort),
        .dftcgen        (dftcgen),
        .baseaddr       (32'd0),
        .baseaddr_valid (1'b1)
    );

    css600_apbicdecoder #(
        .APB_SLAVE_ADDR_WIDTH   (32),
        .NUM_APB_SLAVES         (2),
        .NUM_APB_MASTERS        (HOST_MASTERS),
        .NUM_EXPANDERS          (1),
        .M0_BASE_ADDR           (32'h0000_0000), 
        .M1_BASE_ADDR           (32'h000a_0000), 
        .M2_BASE_ADDR           (32'h0011_0000), 
        .M3_BASE_ADDR           (32'h0012_0000), 
        .M4_BASE_ADDR           (32'h0013_0000), 
        .M5_BASE_ADDR           (32'h0014_0000), 
        .M6_BASE_ADDR           (32'h0017_0000), 
        .M7_BASE_ADDR           (32'h0100_0000), 
        .M8_BASE_ADDR           (32'h0200_0000), 
        .M0_ADDR_WIDTH          (12),
        .M1_ADDR_WIDTH          (12),
        .M2_ADDR_WIDTH          (12),
        .M3_ADDR_WIDTH          (12),
        .M4_ADDR_WIDTH          (12),
        .M5_ADDR_WIDTH          (12),
        .M6_ADDR_WIDTH          (12),
        .M7_ADDR_WIDTH          (24),
        .M8_ADDR_WIDTH          (25)
    ) u_decoder_host (
        .clk          (dbgclk_gated),
        .reset_n      (dbgclk_resetn),

        .pwakeup_s    ({hostdbg_pwakeup_m_to_u_decoder_host_pwakeup_s,
                        u_host_apbap_pwakeup_m_to_u_decoder_host_pwakeup_s}),
        .psel_s       ({hostdbg_psel_m_to_u_decoder_host_psel_s,
                        u_host_apbap_psel_m_to_u_decoder_host_psel_s}),
        .penable_s    ({hostdbg_penable_m_to_u_decoder_host_penable_s,
                        u_host_apbap_penable_m_to_u_decoder_host_penable_s}),
        .pwrite_s     ({hostdbg_pwrite_m_to_u_decoder_host_pwrite_s,
                        u_host_apbap_pwrite_m_to_u_decoder_host_pwrite_s}),
        .pprot_s      ({{hostdbg_pprot_m_to_u_decoder_host_pprot_s},
                        {u_host_apbap_pprot_m_to_u_decoder_host_pprot_s}
                       }),
        .paddr_s      ({{5'd0, hostdbg_paddr_m_to_u_decoder_host_paddr_s}, 
                        u_host_apbap_paddr_m_to_u_decoder_host_paddr_s}),
        .pwdata_s     ({hostdbg_pwdata_m_to_u_decoder_host_pwdata_s,
                        u_host_apbap_pwdata_m_to_u_decoder_host_pwdata_s}),
        .pready_s     ({hostdbg_pready_m_to_u_decoder_host_pready_s,
                        u_host_apbap_pready_m_to_u_decoder_host_pready_s}),
        .pslverr_s    ({hostdbg_pslverr_m_to_u_decoder_host_pslverr_s,
                        u_host_apbap_pslverr_m_to_u_decoder_host_pslverr_s}),
        .prdata_s     (u_decoder_host_prdata_s),


        .pwakeup_e    (u_decoder_host_pwakeup_e_to_u_expander_host_pwakeup_e),
        .psel_e       (u_decoder_host_psel_e_to_u_expander_host_psel_e),
        .penable_e    (u_decoder_host_penable_e_to_u_expander_host_penable_e),
        .pwrite_e     (u_decoder_host_pwrite_e_to_u_expander_host_pwrite_e),
        .pprot_e      (u_decoder_host_pprot_e_to_u_expander_host_pprot_e),
        .paddr_e      (u_decoder_host_paddr_e_to_u_expander_host_paddr_e),
        .pwdata_e     (u_decoder_host_pwdata_e_to_u_expander_host_pwdata_e),
        .pready_e     (u_decoder_host_pready_e_to_u_expander_host_pready_e),
        .pslverr_e    (u_decoder_host_pslverr_e_to_u_expander_host_pslverr_e),
        .prdata_e     (u_decoder_host_prdata_e_to_u_expander_host_prdata_e),

        .clk_qreq_n   (dbgclk_qreqn   [10]),
        .clk_qaccept_n(dbgclk_qacceptn[10]),
        .clk_qdeny    (dbgclk_qdeny   [10]),
        .clk_qactive  (dbgclk_qactive[10])
    );


    assign hostdbg_prdata_m_to_u_decoder_host_prdata_s      = u_decoder_host_prdata_s;
    assign u_host_apbap_prdata_m_to_u_decoder_host_prdata_s = u_decoder_host_prdata_s;


    css600_apbicexpander #(
        .APB_SLAVE_ADDR_WIDTH   (32),
        .NUM_APB_SLAVES         (2),
        .NUM_APB_MASTERS        (HOST_MASTERS),
        .NUM_EXPANDERS          (1),
        .M0_BASE_ADDR           (32'h0000_0000), 
        .M1_BASE_ADDR           (32'h000a_0000), 
        .M2_BASE_ADDR           (32'h0011_0000), 
        .M3_BASE_ADDR           (32'h0012_0000), 
        .M4_BASE_ADDR           (32'h0013_0000), 
        .M5_BASE_ADDR           (32'h0014_0000), 
        .M6_BASE_ADDR           (32'h0017_0000), 
        .M7_BASE_ADDR           (32'h0100_0000), 
        .M8_BASE_ADDR           (32'h0200_0000), 
        .M0_ADDR_WIDTH          (12),
        .M1_ADDR_WIDTH          (12),
        .M2_ADDR_WIDTH          (12),
        .M3_ADDR_WIDTH          (12),
        .M4_ADDR_WIDTH          (12),
        .M5_ADDR_WIDTH          (12),
        .M6_ADDR_WIDTH          (12),
        .M7_ADDR_WIDTH          (24),
        .M8_ADDR_WIDTH          (25)
    ) u_expander_host (
        .clk          (dbgclk_gated),
        .reset_n      (dbgclk_resetn),

        .pwakeup_e    (u_decoder_host_pwakeup_e_to_u_expander_host_pwakeup_e),
        .psel_e       (u_decoder_host_psel_e_to_u_expander_host_psel_e),
        .penable_e    (u_decoder_host_penable_e_to_u_expander_host_penable_e),
        .pwrite_e     (u_decoder_host_pwrite_e_to_u_expander_host_pwrite_e),
        .pprot_e      (u_decoder_host_pprot_e_to_u_expander_host_pprot_e),
        .paddr_e      (u_decoder_host_paddr_e_to_u_expander_host_paddr_e),
        .pwdata_e     (u_decoder_host_pwdata_e_to_u_expander_host_pwdata_e),
        .pready_e     (u_decoder_host_pready_e_to_u_expander_host_pready_e),
        .pslverr_e    (u_decoder_host_pslverr_e_to_u_expander_host_pslverr_e),
        .prdata_e     (u_decoder_host_prdata_e_to_u_expander_host_prdata_e),

        .pwakeup_m    ({cluster_debug_adb_pwakeup_m,                              
                        hostdbgexp_pwakeup_m,                                     
                        u_expander_host_pwakeup_m_to_u_host_stm_not_used,          
                        u_expander_host_pwakeup_m_to_u_host_cti_pwakeup_s,        
                        u_expander_host_pwakeup_m_to_u_host_catu_pwakeup_s,       
                        u_expander_host_pwakeup_m_to_u_host_etr_pwakeup_s,        
                        u_expander_host_pwakeup_m_to_u_host_replicator_pwakeup_s, 
                        u_expander_host_pwakeup_m_to_u_host_funnel_pwakeup_s,     
                        u_expander_host_pwakeup_m_to_u_host_rom_not_used}),       
        .psel_m       ({cluster_debug_adb_psel_m,
                        hostdbgexp_psel_m,
                        u_expander_host_psel_m_to_u_host_stm_pseldbg,
                        u_expander_host_psel_m_to_u_host_cti_psel_s,
                        u_expander_host_psel_m_to_u_host_catu_psel_s,
                        u_expander_host_psel_m_to_u_host_etr_psel_s,
                        u_expander_host_psel_m_to_u_host_replicator_psel_s,
                        u_expander_host_psel_m_to_u_host_funnel_psel_s,
                        u_expander_host_psel_m_to_u_host_rom_psel_s}),
        .penable_m    ({cluster_debug_adb_penable_m,
                        hostdbgexp_penable_m,
                        u_expander_host_penable_m_to_u_host_stm_penabledbg,
                        u_expander_host_penable_m_to_u_host_cti_penable_s,
                        u_expander_host_penable_m_to_u_host_catu_penable_s,
                        u_expander_host_penable_m_to_u_host_etr_penable_s,
                        u_expander_host_penable_m_to_u_host_replicator_penable_s,
                        u_expander_host_penable_m_to_u_host_funnel_penable_s,
                        u_expander_host_penable_m_to_u_host_rom_penable_s}),
        .pwrite_m     (u_expander_host_pwrite_m),
        .pprot_m      (u_expander_host_pprot_m),
        .paddr_m      (u_expander_host_paddr_m),
        .pwdata_m     (u_expander_host_pwdata_m),
        .prdata_m     ({cluster_debug_adb_prdata_m,
                        hostdbgexp_prdata_m,
                        u_expander_host_prdata_m_to_u_host_stm_prdatadbg,
                        u_expander_host_prdata_m_to_u_host_cti_prdata_s,
                        u_expander_host_prdata_m_to_u_host_catu_prdata_s,
                        u_expander_host_prdata_m_to_u_host_etr_prdata_s,
                        u_expander_host_prdata_m_to_u_host_replicator_prdata_s,
                        u_expander_host_prdata_m_to_u_host_funnel_prdata_s,
                        u_expander_host_prdata_m_to_u_host_rom_prdata_s}),
        .pready_m     ({cluster_debug_adb_pready_m,
                        hostdbgexp_pready_m,
                        u_expander_host_pready_m_to_u_host_stm_preadydbg,
                        u_expander_host_pready_m_to_u_host_cti_pready_s,
                        u_expander_host_pready_m_to_u_host_catu_pready_s,
                        u_expander_host_pready_m_to_u_host_etr_pready_s,
                        u_expander_host_pready_m_to_u_host_replicator_pready_s,
                        u_expander_host_pready_m_to_u_host_funnel_pready_s,
                        u_expander_host_pready_m_to_u_host_rom_pready_s}),
        .pslverr_m    ({cluster_debug_adb_pslverr_m,
                        hostdbgexp_pslverr_m,
                        u_expander_host_pslverr_m_to_u_host_stm_pslverrdbg,
                        u_expander_host_pslverr_m_to_u_host_cti_pslverr_s,
                        u_expander_host_pslverr_m_to_u_host_catu_pslverr_s,
                        u_expander_host_pslverr_m_to_u_host_etr_pslverr_s,
                        u_expander_host_pslverr_m_to_u_host_replicator_pslverr_s,
                        u_expander_host_pslverr_m_to_u_host_funnel_pslverr_s,
                        u_expander_host_pslverr_m_to_u_host_rom_pslverr_s})
);



    assign cluster_debug_adb_pwrite_m                             = u_expander_host_pwrite_m;
    assign hostdbgexp_pwrite_m                                    = u_expander_host_pwrite_m;
    assign u_expander_host_pwrite_m_to_u_host_stm_pwritedbg       = u_expander_host_pwrite_m;
    assign u_expander_host_pwrite_m_to_u_host_cti_pwrite_s        = u_expander_host_pwrite_m;
    assign u_expander_host_pwrite_m_to_u_host_catu_pwrite_s       = u_expander_host_pwrite_m;
    assign u_expander_host_pwrite_m_to_u_host_etr_pwrite_s        = u_expander_host_pwrite_m;
    assign u_expander_host_pwrite_m_to_u_host_replicator_pwrite_s = u_expander_host_pwrite_m;
    assign u_expander_host_pwrite_m_to_u_host_funnel_pwrite_s     = u_expander_host_pwrite_m;
    assign u_expander_host_pwrite_m_to_u_host_rom_pwrite_s        = u_expander_host_pwrite_m;
    
    assign cluster_debug_adb_paddr_m                              = {7'b0000001,u_expander_host_paddr_m};        
    assign hostdbgexp_paddr_m                                     = {8'h01     ,u_expander_host_paddr_m[23:0]};  
    assign u_expander_host_paddr_m_to_u_host_stm_paddrdbg         = u_expander_host_paddr_m[11:0]; 
    assign u_expander_host_paddr_m_to_u_host_cti_paddr_s          = u_expander_host_paddr_m[11:0];
    assign u_expander_host_paddr_m_to_u_host_catu_paddr_s         = u_expander_host_paddr_m[11:0];
    assign u_expander_host_paddr_m_to_u_host_etr_paddr_s          = u_expander_host_paddr_m[11:0];
    assign u_expander_host_paddr_m_to_u_host_replicator_paddr_s   = u_expander_host_paddr_m[11:0];
    assign u_expander_host_paddr_m_to_u_host_funnel_paddr_s       = u_expander_host_paddr_m[11:0];
    assign u_expander_host_paddr_m_to_u_host_rom_paddr_s          = u_expander_host_paddr_m[11:0];

    assign cluster_debug_adb_pprot_m                              = u_expander_host_pprot_m;
    assign hostdbgexp_pprot_m                                     = u_expander_host_pprot_m;

    assign cluster_debug_adb_pwdata_m                             = u_expander_host_pwdata_m;
    assign hostdbgexp_pwdata_m                                    = u_expander_host_pwdata_m;
    assign u_expander_host_pwdata_m_to_u_host_stm_pwdatadbg       = u_expander_host_pwdata_m;
    assign u_expander_host_pwdata_m_to_u_host_cti_pwdata_s        = u_expander_host_pwdata_m;
    assign u_expander_host_pwdata_m_to_u_host_catu_pwdata_s       = u_expander_host_pwdata_m;
    assign u_expander_host_pwdata_m_to_u_host_etr_pwdata_s        = u_expander_host_pwdata_m;
    assign u_expander_host_pwdata_m_to_u_host_funnel_pwdata_s     = u_expander_host_pwdata_m;
    assign u_expander_host_pwdata_m_to_u_host_replicator_pwdata_s = u_expander_host_pwdata_m;
    assign u_expander_host_pwdata_m_to_u_host_rom_pwdata_s        = u_expander_host_pwdata_m;

    wire ap_en_hostaxiauth_ss;
    wire ap_secure_en_hostaxiauth_ss;

    assign ap_en_hostaxiauth_ss = dbgen_hostaxiauth_ss | niden_hostaxiauth_ss;
    assign ap_secure_en_hostaxiauth_ss = spiden_hostaxiauth_ss | spniden_hostaxiauth_ss;
    
    
    css600_axiap u_host_axiap (
        .clk           (dbgclk_gated),
        .reset_n       (dbgclk_resetn),

        .dftcgen       (dftcgen),

        .pwakeup_s     (u_expander_extdbgbus_pwakeup_m_to_u_host_axiap_pwakeup_s),
        .psel_s        (u_expander_extdbgbus_psel_m_to_u_host_axiap_psel_s),
        .penable_s     (u_expander_extdbgbus_penable_m_to_u_host_axiap_penable_s),
        .pwrite_s      (u_expander_extdbgbus_pwrite_m_to_u_host_axiap_pwrite_s),
        .paddr_s       (u_expander_extdbgbus_paddr_m_to_u_host_axiap_paddr_s),
        .pwdata_s      (u_expander_extdbgbus_pwdata_m_to_u_host_axiap_pwdata_s),
        .pready_s      (u_expander_extdbgbus_pready_m_to_u_host_axiap_pready_s),
        .pslverr_s     (u_expander_extdbgbus_pslverr_m_to_u_host_axiap_pslverr_s),
        .prdata_s      (u_expander_extdbgbus_prdata_m_to_u_host_axiap_prdata_s),

        .clk_qreq_n    (dbgclk_qreqn   [11]),
        .clk_qaccept_n (dbgclk_qacceptn[11]),
        .clk_qactive   (dbgclk_qactive[11]),
        .clk_qdeny     (dbgclk_qdeny[11]),
        
        .ap_en         (ap_en_hostaxiauth_ss),
        .ap_secure_en  (ap_secure_en_hostaxiauth_ss),
        .baseaddr_valid(1'b0),
        .baseaddr      (32'd0),
        .dp_abort      (dp_abort),


        .arlock_m      (u_host_axiap_arlock_m_to_u_nic_arlock_p2_axis),
        .arvalid_m     (u_host_axiap_arvalid_m_to_u_nic_arvalid_p2_axis),
        .arready_m     (u_host_axiap_arready_m_to_u_nic_arready_p2_axis),
        .rlast_m       (u_host_axiap_rlast_m_to_u_nic_rlast_p2_axis),
        .rvalid_m      (u_host_axiap_rvalid_m_to_u_nic_rvalid_p2_axis),
        .rready_m      (u_host_axiap_rready_m_to_u_nic_rready_p2_axis),
        .awlock_m      (u_host_axiap_awlock_m_to_u_nic_awlock_p2_axis),
        .awvalid_m     (u_host_axiap_awvalid_m_to_u_nic_awvalid_p2_axis),
        .awready_m     (u_host_axiap_awready_m_to_u_nic_awready_p2_axis),
        .wlast_m       (u_host_axiap_wlast_m_to_u_nic_wlast_p2_axis),
        .wvalid_m      (u_host_axiap_wvalid_m_to_u_nic_wvalid_p2_axis),
        .wready_m      (u_host_axiap_wready_m_to_u_nic_wready_p2_axis),
        .bvalid_m      (u_host_axiap_bvalid_m_to_u_nic_bvalid_p2_axis),
        .bready_m      (u_host_axiap_bready_m_to_u_nic_bready_p2_axis),
        .arlen_m       (u_host_axiap_arlen_m_to_u_nic_arlen_p2_axis),
        .arburst_m     (u_host_axiap_arburst_m_to_u_nic_arburst_p2_axis),
        .arcache_m     (u_host_axiap_arcache_m_to_u_nic_arcache_p2_axis),
        .arprot_m      (u_host_axiap_arprot_m_to_u_nic_arprot_p2_axis),
        .rresp_m       (u_host_axiap_rresp_m_to_u_nic_rresp_p2_axis),
        .awlen_m       (u_host_axiap_awlen_m_to_u_nic_awlen_p2_axis),
        .awburst_m     (u_host_axiap_awburst_m_to_u_nic_awburst_p2_axis),
        .awcache_m     (u_host_axiap_awcache_m_to_u_nic_awcache_p2_axis),
        .awprot_m      (u_host_axiap_awprot_m_to_u_nic_awprot_p2_axis),
        .bresp_m       (u_host_axiap_bresp_m_to_u_nic_bresp_p2_axis),
        .awdomain_m    (), 
        .awsnoop_m     (), 
        .ardomain_m    (), 
        .arsnoop_m     (), 
        .araddr_m      (u_host_axiap_araddr_m_to_u_nic_araddr_p2_axis),
        .arsize_m      (u_host_axiap_arsize_m_to_u_nic_arsize_p2_axis), 
        .rdata_m       (u_host_axiap_rdata_m_to_u_nic_rdata_p2_axis),
        .awaddr_m      (u_host_axiap_awaddr_m_to_u_nic_awaddr_p2_axis),
        .awsize_m      (u_host_axiap_awsize_m_to_u_nic_awsize_p2_axis), 
        .wdata_m       (u_host_axiap_wdata_m_to_u_nic_wdata_p2_axis),
        .wstrb_m       (u_host_axiap_wstrb_m_to_u_nic_wstrb_p2_axis),
        .awakeup_m     ()
    );

    css600_apbrom_gpr #(
        .NUM_ENTRIES(1),
        .ROM_ENTRY0 (32'h0001_0003), 
        .NUM_DBGPWRUP_MASTERS   (1),
        .NUM_SYSPWRUP_MASTERS   (32)
    ) u_host_axiap_rom (
        .clk          (dbgclk_gated),
        .reset_n      (dbgclk_resetn),
        .psel_s       (u_expander_extdbgbus_psel_m_to_u_host_axiap_rom_psel_s),
        .penable_s    (u_expander_extdbgbus_penable_m_to_u_host_axiap_rom_penable_s),
        .pwrite_s     (u_expander_extdbgbus_pwrite_m_to_u_host_axiap_rom_pwrite_s),
        .paddr_s      (u_expander_extdbgbus_paddr_m_to_u_host_axiap_rom_paddr_s),
        .pwdata_s     (u_expander_extdbgbus_pwdata_m_to_u_host_axiap_rom_pwdata_s),
        .pready_s     (u_expander_extdbgbus_pready_m_to_u_host_axiap_rom_pready_s),
        .pslverr_s    (u_expander_extdbgbus_pslverr_m_to_u_host_axiap_rom_pslverr_s),
        .prdata_s     (u_expander_extdbgbus_prdata_m_to_u_host_axiap_rom_prdata_s),
        .cdbgpwrupreq (axiap_cdbgpwrupreq_loop),
        .cdbgpwrupack (axiap_cdbgpwrupreq_loop),
        .csyspwrupreq ({axiap_csyspwrupreq_hostdbgpwr,axiap_csyspwrupreq_loopback,axiap_csyspwrupreq_internal}),
        .csyspwrupack ({axiap_csyspwrupack_hostdbgpwr,axiap_csyspwrupreq_loopback,axiap_csyspwrupack_internal}),
        .cdbgrstreq   (axiap_cdbgrstreq_loop),
        .cdbgrstack   (axiap_cdbgrstreq_loop),
        .csysrstreq   (axiap_csysrstreq_loop),
        .csysrstack   (axiap_csysrstreq_loop),
        .dbgen        (dbgen_hostaxiauth_ss),
        .niden        (niden_hostaxiauth_ss),
        .spiden       (spiden_hostaxiauth_ss),
        .spniden      (spniden_hostaxiauth_ss),
        .revision     (host_axiap_rom_revision),
        .part_number  (host_axiap_rom_part_number),
        .jep106_id    (host_axiap_rom_jep106_id),
        .eco_rev_and  (host_axiap_rom_eco_rev_and),
        .entry_present(HOST_AXIAP_ROM_ENTRY_PRESENT)
    );

    
    css600_apbrom_gpr #(
        .NUM_ENTRIES(EXTDBG_ROM_ENTRIES),
        .ROM_ENTRY0 (32'h0001_0007), 
        .ROM_ENTRY1 (32'h0002_0003), 
        .ROM_ENTRY2 (32'h0003_0003), 
        .ROM_ENTRY3 (32'h000d_0003), 
        .ROM_ENTRY4 (32'h000e_0003), 
        .ROM_ENTRY5 (32'h000f_0003), 
        .ROM_ENTRY6 (32'h0010_0003), 
        .ROM_ENTRY7 (32'h0011_0003), 
        .ROM_ENTRY8 (32'h0012_0003), 
        .ROM_ENTRY9 (32'h0013_0003), 
        .ROM_ENTRY10(EXT_SYS0_ROM_ENTRY), 
        .ROM_ENTRY11(EXT_SYS1_ROM_ENTRY), 
        .NUM_DBGPWRUP_MASTERS   (3)
    ) u_extdbg_rom (
        .clk          (dbgclk_gated),
        .reset_n      (dbgclk_resetn),
        .psel_s       (u_expander_extdbgbus_psel_m_to_u_extdbg_rom_psel_s),
        .penable_s    (u_expander_extdbgbus_penable_m_to_u_extdbg_rom_penable_s),
        .pwrite_s     (u_expander_extdbgbus_pwrite_m_to_u_extdbg_rom_pwrite_s),
        .paddr_s      (u_expander_extdbgbus_paddr_m_to_u_extdbg_rom_paddr_s),
        .pwdata_s     (u_expander_extdbgbus_pwdata_m_to_u_extdbg_rom_pwdata_s),
        .pready_s     (u_expander_extdbgbus_pready_m_to_u_extdbg_rom_pready_s),
        .pslverr_s    (u_expander_extdbgbus_pslverr_m_to_u_extdbg_rom_pslverr_s),
        .prdata_s     (u_expander_extdbgbus_prdata_m_to_u_extdbg_rom_prdata_s),
        .cdbgpwrupreq (extdbg_cdbgpwrupreq),
        .cdbgpwrupack (extdbg_cdbgpwrupack),
        .csyspwrupreq (extdbg_csyspwrupreq_loop),
        .csyspwrupack (extdbg_csyspwrupreq_loop),
        .cdbgrstreq   (extdbg_cdbgrstreq_loop),
        .cdbgrstack   (extdbg_cdbgrstreq_loop),
        .csysrstreq   (extdbg_csysrstreq_loop),
        .csysrstack   (extdbg_csysrstreq_loop),
        .dbgen        (dbgen_dpauth_ss),
        .niden        (niden_dpauth_ss),
        .spiden       (spiden_dpauth_ss),
        .spniden      (spniden_dpauth_ss),
        .revision     (extdbg_rom_revision),
        .part_number  (extdbg_rom_part_number),
        .jep106_id    (extdbg_rom_jep106_id),
        .eco_rev_and  (extdbg_rom_eco_rev_and),
        .entry_present(EXTDBG_ROM_ENTRY_PRESENT)
    );



    css600_apbrom_gpr #(
        .NUM_ENTRIES(HOST_ROM_ENTRIES),
        .ROM_ENTRY0 (32'h000a_0003), 
        .ROM_ENTRY1 (32'h0011_0003), 
        .ROM_ENTRY2 (32'h0012_0003), 
        .ROM_ENTRY3 (32'h0013_0003), 
        .ROM_ENTRY4 (32'h0014_0003), 
        .ROM_ENTRY5 (32'h0017_0003), 
        .ROM_ENTRY6 (32'h0200_0007),      
        .ROM_ENTRY7 (HOST_EXP_ROM_ENTRY) 
    ) u_host_rom (
        .clk          (dbgclk_gated),
        .reset_n      (dbgclk_resetn),
        .psel_s       (u_expander_host_psel_m_to_u_host_rom_psel_s),
        .penable_s    (u_expander_host_penable_m_to_u_host_rom_penable_s),
        .pwrite_s     (u_expander_host_pwrite_m_to_u_host_rom_pwrite_s),
        .paddr_s      (u_expander_host_paddr_m_to_u_host_rom_paddr_s),
        .pwdata_s     (u_expander_host_pwdata_m_to_u_host_rom_pwdata_s),
        .pready_s     (u_expander_host_pready_m_to_u_host_rom_pready_s),
        .pslverr_s    (u_expander_host_pslverr_m_to_u_host_rom_pslverr_s),
        .prdata_s     (u_expander_host_prdata_m_to_u_host_rom_prdata_s),
        .cdbgpwrupreq (host_cdbgpwrupreq),
        .cdbgpwrupack (host_cdbgpwrupack),
        .csyspwrupreq (host_csyspwrupreq_loop),
        .csyspwrupack (host_csyspwrupreq_loop),
        .cdbgrstreq   (host_cdbgrstreq_loop  ),
        .cdbgrstack   (host_cdbgrstreq_loop  ),
        .csysrstreq   (host_csysrstreq_loop  ),
        .csysrstack   (host_csysrstreq_loop  ),
        .dbgen        (dbgen_hostauth_ss),
        .niden        (niden_hostauth_ss),
        .spiden       (spiden_hostauth_ss),
        .spniden      (spniden_hostauth_ss),
        .revision     (host_rom_revision),
        .part_number  (host_rom_part_number),
        .jep106_id    (host_rom_jep106_id),
        .eco_rev_and  (host_rom_eco_rev_and),
        .entry_present(HOST_ROM_ENTRY_PRESENT)
    );



    css600_catu #(
        .AXI_ADDR_WIDTH (32),
        .AXI_DATA_WIDTH (32),
        .FF_SYNC_DEPTH  (2),
        .REVAND         (4'h0)
    ) u_host_catu (
        .clk          (dbgclk_gated),
        .reset_n      (dbgclk_resetn),

        .clk_qreq_n   (dbgclk_qreqn   [12]),
        .clk_qaccept_n(dbgclk_qacceptn[12]),
        .clk_qdeny    (dbgclk_qdeny   [12]),
        .clk_qactive  (dbgclk_qactive[12]),

        .pwakeup_s    (u_expander_host_pwakeup_m_to_u_host_catu_pwakeup_s),
        .psel_s       (u_expander_host_psel_m_to_u_host_catu_psel_s),
        .penable_s    (u_expander_host_penable_m_to_u_host_catu_penable_s),
        .pwrite_s     (u_expander_host_pwrite_m_to_u_host_catu_pwrite_s),
        .paddr_s      (u_expander_host_paddr_m_to_u_host_catu_paddr_s),
        .pwdata_s     (u_expander_host_pwdata_m_to_u_host_catu_pwdata_s),
        .pready_s     (u_expander_host_pready_m_to_u_host_catu_pready_s),
        .pslverr_s    (u_expander_host_pslverr_m_to_u_host_catu_pslverr_s),
        .prdata_s     (u_expander_host_prdata_m_to_u_host_catu_prdata_s),

        .awakeup_m    (),
        .araddr_m     (u_host_catu_araddr_m_to_u_nic_araddr_p1_axis),
        .arlen_m      (u_host_catu_arlen_m_to_u_nic_arlen_p1_axis),
        .arsize_m     (u_host_catu_arsize_m_to_u_nic_arsize_p1_axis),
        .arburst_m    (u_host_catu_arburst_m_to_u_nic_arburst_p1_axis),
        .arlock_m     (u_host_catu_arlock_m_to_u_nic_arlock_p1_axis),
        .arcache_m    (u_host_catu_arcache_m_to_u_nic_arcache_p1_axis),
        .arprot_m     (u_host_catu_arprot_m_to_u_nic_arprot_p1_axis),
        .arid_m       (u_host_catu_arid_m_to_u_nic_arid_p1_axis),
        .arvalid_m    (u_host_catu_arvalid_m_to_u_nic_arvalid_p1_axis),
        .arready_m    (u_host_catu_arready_m_to_u_nic_arready_p1_axis),
        .rdata_m      (u_host_catu_rdata_m_to_u_nic_rdata_p1_axis),
        .rresp_m      (u_host_catu_rresp_m_to_u_nic_rresp_p1_axis),
        .rlast_m      (u_host_catu_rlast_m_to_u_nic_rlast_p1_axis),
        .rid_m        (u_host_catu_rid_m_to_u_nic_rid_p1_axis),
        .rvalid_m     (u_host_catu_rvalid_m_to_u_nic_rvalid_p1_axis),
        .rready_m     (u_host_catu_rready_m_to_u_nic_rready_p1_axis),
        .awaddr_m     (u_host_catu_awaddr_m_to_u_nic_awaddr_p1_axis),
        .awlen_m      (u_host_catu_awlen_m_to_u_nic_awlen_p1_axis),
        .awsize_m     (u_host_catu_awsize_m_to_u_nic_awsize_p1_axis),
        .awburst_m    (u_host_catu_awburst_m_to_u_nic_awburst_p1_axis),
        .awlock_m     (u_host_catu_awlock_m_to_u_nic_awlock_p1_axis),
        .awcache_m    (u_host_catu_awcache_m_to_u_nic_awcache_p1_axis),
        .awprot_m     (u_host_catu_awprot_m_to_u_nic_awprot_p1_axis),
        .awvalid_m    (u_host_catu_awvalid_m_to_u_nic_awvalid_p1_axis),
        .awready_m    (u_host_catu_awready_m_to_u_nic_awready_p1_axis),
        .wdata_m      (u_host_catu_wdata_m_to_u_nic_wdata_p1_axis),
        .wstrb_m      (u_host_catu_wstrb_m_to_u_nic_wstrb_p1_axis),
        .wlast_m      (u_host_catu_wlast_m_to_u_nic_wlast_p1_axis),
        .wvalid_m     (u_host_catu_wvalid_m_to_u_nic_wvalid_p1_axis),
        .wready_m     (u_host_catu_wready_m_to_u_nic_wready_p1_axis),
        .bresp_m      (u_host_catu_bresp_m_to_u_nic_bresp_p1_axis),
        .bvalid_m     (u_host_catu_bvalid_m_to_u_nic_bvalid_p1_axis),
        .bready_m     (u_host_catu_bready_m_to_u_nic_bready_p1_axis),


        .awakeup_s    (1'b0),
        .araddr_s     (u_host_etr_araddr_m_to_u_host_catu_araddr_s),
        .arlen_s      (u_host_etr_arlen_m_to_u_host_catu_arlen_s),
        .arsize_s     (u_host_etr_arsize_m_to_u_host_catu_arsize_s),
        .arburst_s    (u_host_etr_arburst_m_to_u_host_catu_arburst_s),
        .arlock_s     (u_host_etr_arlock_m_to_u_host_catu_arlock_s),
        .arcache_s    (u_host_etr_arcache_m_to_u_host_catu_arcache_s),
        .arprot_s     (u_host_etr_arprot_m_to_u_host_catu_arprot_s),
        .arvalid_s    (u_host_etr_arvalid_m_to_u_host_catu_arvalid_s),
        .arready_s    (u_host_etr_arready_m_to_u_host_catu_arready_s),
        .rdata_s      (u_host_etr_rdata_m_to_u_host_catu_rdata_s),
        .rresp_s      (u_host_etr_rresp_m_to_u_host_catu_rresp_s),
        .rlast_s      (u_host_etr_rlast_m_to_u_host_catu_rlast_s),
        .rvalid_s     (u_host_etr_rvalid_m_to_u_host_catu_rvalid_s),
        .rready_s     (u_host_etr_rready_m_to_u_host_catu_rready_s),
        .awaddr_s     (u_host_etr_awaddr_m_to_u_host_catu_awaddr_s),
        .awlen_s      (u_host_etr_awlen_m_to_u_host_catu_awlen_s),
        .awsize_s     (u_host_etr_awsize_m_to_u_host_catu_awsize_s),
        .awburst_s    (u_host_etr_awburst_m_to_u_host_catu_awburst_s),
        .awlock_s     (u_host_etr_awlock_m_to_u_host_catu_awlock_s),
        .awcache_s    (u_host_etr_awcache_m_to_u_host_catu_awcache_s),
        .awprot_s     (u_host_etr_awprot_m_to_u_host_catu_awprot_s),
        .awvalid_s    (u_host_etr_awvalid_m_to_u_host_catu_awvalid_s),
        .awready_s    (u_host_etr_awready_m_to_u_host_catu_awready_s),
        .wdata_s      (u_host_etr_wdata_m_to_u_host_catu_wdata_s),
        .wstrb_s      (u_host_etr_wstrb_m_to_u_host_catu_wstrb_s),
        .wlast_s      (u_host_etr_wlast_m_to_u_host_catu_wlast_s),
        .wvalid_s     (u_host_etr_wvalid_m_to_u_host_catu_wvalid_s),
        .wready_s     (u_host_etr_wready_m_to_u_host_catu_wready_s),
        .bresp_s      (u_host_etr_bresp_m_to_u_host_catu_bresp_s),
        .bvalid_s     (u_host_etr_bvalid_m_to_u_host_catu_bvalid_s),
        .bready_s     (u_host_etr_bready_m_to_u_host_catu_bready_s),



        .dbgen        (dbgen_hostauth_ss),
        .spiden       (spiden_hostauth_ss),

        .addrerr      (irq_host_catu),
        .dftcgen      (dftcgen)
    );



    css600_catu #(
        .AXI_ADDR_WIDTH (32),
        .AXI_DATA_WIDTH (32),
        .FF_SYNC_DEPTH  (2),
        .REVAND         (4'h0)
    ) u_soc_catu (
        .clk          (dbgclk_gated),
        .reset_n      (dbgclk_resetn),

        .clk_qreq_n   (dbgclk_qreqn   [13]),
        .clk_qaccept_n(dbgclk_qacceptn[13]),
        .clk_qdeny    (dbgclk_qdeny   [13]),
        .clk_qactive  (dbgclk_qactive[13]),

        .pwakeup_s    (u_expander_extdbgbus_pwakeup_m_to_u_soc_catu_pwakeup_s),
        .psel_s       (u_expander_extdbgbus_psel_m_to_u_soc_catu_psel_s),
        .penable_s    (u_expander_extdbgbus_penable_m_to_u_soc_catu_penable_s),
        .pwrite_s     (u_expander_extdbgbus_pwrite_m_to_u_soc_catu_pwrite_s),
        .paddr_s      (u_expander_extdbgbus_paddr_m_to_u_soc_catu_paddr_s),
        .pwdata_s     (u_expander_extdbgbus_pwdata_m_to_u_soc_catu_pwdata_s),
        .pready_s     (u_expander_extdbgbus_pready_m_to_u_soc_catu_pready_s),
        .pslverr_s    (u_expander_extdbgbus_pslverr_m_to_u_soc_catu_pslverr_s),
        .prdata_s     (u_expander_extdbgbus_prdata_m_to_u_soc_catu_prdata_s),


        .awakeup_m    (),
        .araddr_m     (u_soc_catu_araddr_m_to_u_nic_araddr_p0_axis),
        .arlen_m      (u_soc_catu_arlen_m_to_u_nic_arlen_p0_axis),
        .arsize_m     (u_soc_catu_arsize_m_to_u_nic_arsize_p0_axis),
        .arburst_m    (u_soc_catu_arburst_m_to_u_nic_arburst_p0_axis),
        .arlock_m     (u_soc_catu_arlock_m_to_u_nic_arlock_p0_axis),
        .arcache_m    (u_soc_catu_arcache_m_to_u_nic_arcache_p0_axis),
        .arprot_m     (u_soc_catu_arprot_m_to_u_nic_arprot_p0_axis),
        .arid_m       (u_soc_catu_arid_m_to_u_nic_arid_p0_axis),
        .arvalid_m    (u_soc_catu_arvalid_m_to_u_nic_arvalid_p0_axis),
        .arready_m    (u_soc_catu_arready_m_to_u_nic_arready_p0_axis),
        .rdata_m      (u_soc_catu_rdata_m_to_u_nic_rdata_p0_axis),
        .rresp_m      (u_soc_catu_rresp_m_to_u_nic_rresp_p0_axis),
        .rlast_m      (u_soc_catu_rlast_m_to_u_nic_rlast_p0_axis),
        .rid_m        (u_soc_catu_rid_m_to_u_nic_rid_p0_axis),
        .rvalid_m     (u_soc_catu_rvalid_m_to_u_nic_rvalid_p0_axis),
        .rready_m     (u_soc_catu_rready_m_to_u_nic_rready_p0_axis),
        .awaddr_m     (u_soc_catu_awaddr_m_to_u_nic_awaddr_p0_axis),
        .awlen_m      (u_soc_catu_awlen_m_to_u_nic_awlen_p0_axis),
        .awsize_m     (u_soc_catu_awsize_m_to_u_nic_awsize_p0_axis),
        .awburst_m    (u_soc_catu_awburst_m_to_u_nic_awburst_p0_axis),
        .awlock_m     (u_soc_catu_awlock_m_to_u_nic_awlock_p0_axis),
        .awcache_m    (u_soc_catu_awcache_m_to_u_nic_awcache_p0_axis),
        .awprot_m     (u_soc_catu_awprot_m_to_u_nic_awprot_p0_axis),
        .awvalid_m    (u_soc_catu_awvalid_m_to_u_nic_awvalid_p0_axis),
        .awready_m    (u_soc_catu_awready_m_to_u_nic_awready_p0_axis),
        .wdata_m      (u_soc_catu_wdata_m_to_u_nic_wdata_p0_axis),
        .wstrb_m      (u_soc_catu_wstrb_m_to_u_nic_wstrb_p0_axis),
        .wlast_m      (u_soc_catu_wlast_m_to_u_nic_wlast_p0_axis),
        .wvalid_m     (u_soc_catu_wvalid_m_to_u_nic_wvalid_p0_axis),
        .wready_m     (u_soc_catu_wready_m_to_u_nic_wready_p0_axis),
        .bresp_m      (u_soc_catu_bresp_m_to_u_nic_bresp_p0_axis  ),
        .bvalid_m     (u_soc_catu_bvalid_m_to_u_nic_bvalid_p0_axis),
        .bready_m     (u_soc_catu_bready_m_to_u_nic_bready_p0_axis),

        .awakeup_s    (1'b0),
        .araddr_s     (u_soc_etr_araddr_m_to_u_soc_catu_araddr_s),
        .arlen_s      (u_soc_etr_arlen_m_to_u_soc_catu_arlen_s),
        .arsize_s     (u_soc_etr_arsize_m_to_u_soc_catu_arsize_s),
        .arburst_s    (u_soc_etr_arburst_m_to_u_soc_catu_arburst_s),
        .arlock_s     (u_soc_etr_arlock_m_to_u_soc_catu_arlock_s),
        .arcache_s    (u_soc_etr_arcache_m_to_u_soc_catu_arcache_s),
        .arprot_s     (u_soc_etr_arprot_m_to_u_soc_catu_arprot_s),
        .arvalid_s    (u_soc_etr_arvalid_m_to_u_soc_catu_arvalid_s),
        .arready_s    (u_soc_etr_arready_m_to_u_soc_catu_arready_s),
        .rdata_s      (u_soc_etr_rdata_m_to_u_soc_catu_rdata_s),
        .rresp_s      (u_soc_etr_rresp_m_to_u_soc_catu_rresp_s),
        .rlast_s      (u_soc_etr_rlast_m_to_u_soc_catu_rlast_s),
        .rvalid_s     (u_soc_etr_rvalid_m_to_u_soc_catu_rvalid_s),
        .rready_s     (u_soc_etr_rready_m_to_u_soc_catu_rready_s),
        .awaddr_s     (u_soc_etr_awaddr_m_to_u_soc_catu_awaddr_s),
        .awlen_s      (u_soc_etr_awlen_m_to_u_soc_catu_awlen_s),
        .awsize_s     (u_soc_etr_awsize_m_to_u_soc_catu_awsize_s),
        .awburst_s    (u_soc_etr_awburst_m_to_u_soc_catu_awburst_s),
        .awlock_s     (u_soc_etr_awlock_m_to_u_soc_catu_awlock_s),
        .awcache_s    (u_soc_etr_awcache_m_to_u_soc_catu_awcache_s),
        .awprot_s     (u_soc_etr_awprot_m_to_u_soc_catu_awprot_s),
        .awvalid_s    (u_soc_etr_awvalid_m_to_u_soc_catu_awvalid_s),
        .awready_s    (u_soc_etr_awready_m_to_u_soc_catu_awready_s),
        .wdata_s      (u_soc_etr_wdata_m_to_u_soc_catu_wdata_s),
        .wstrb_s      (u_soc_etr_wstrb_m_to_u_soc_catu_wstrb_s),
        .wlast_s      (u_soc_etr_wlast_m_to_u_soc_catu_wlast_s),
        .wvalid_s     (u_soc_etr_wvalid_m_to_u_soc_catu_wvalid_s),
        .wready_s     (u_soc_etr_wready_m_to_u_soc_catu_wready_s),
        .bresp_s      (u_soc_etr_bresp_m_to_u_soc_catu_bresp_s),
        .bvalid_s     (u_soc_etr_bvalid_m_to_u_soc_catu_bvalid_s),
        .bready_s     (u_soc_etr_bready_m_to_u_soc_catu_bready_s),

        .dbgen        (dbgen_tpiuauth_ss),
        .spiden       (spiden_tpiuauth_ss),

        .addrerr      (irq_soc_catu),
        .dftcgen      (dftcgen)
    );


    nic400_sse710_dbg3s1m u_nic (

        .mainclk         (dbgclk_gated),
        .mainresetn      (dbgclk_resetn),

        .awid_dbg_axim   (u_nic_awid_dbg_axim_to_u_fc_awid_s_i),
        .awaddr_dbg_axim (u_nic_awaddr_dbg_axim_to_u_fc_awaddr_s_i),
        .awlen_dbg_axim  (u_nic_awlen_dbg_axim_to_u_fc_awlen_s_i),
        .awsize_dbg_axim (u_nic_awsize_dbg_axim_to_u_fc_awsize_s_i),
        .awburst_dbg_axim(u_nic_awburst_dbg_axim_to_u_fc_awburst_s_i),
        .awlock_dbg_axim (u_nic_awlock_dbg_axim_to_u_fc_awlock_s_i),
        .awcache_dbg_axim(u_nic_awcache_dbg_axim_to_u_fc_awcache_s_i),
        .awprot_dbg_axim (u_nic_awprot_dbg_axim_to_u_fc_awprot_s_i),
        .awvalid_dbg_axim(u_nic_awvalid_dbg_axim_to_u_fc_awvalid_s_i),
        .awready_dbg_axim(u_nic_awready_dbg_axim_to_u_fc_awready_s_o),
        .wdata_dbg_axim  (u_nic_wdata_dbg_axim_to_u_fc_wdata_s_i),
        .wstrb_dbg_axim  (u_nic_wstrb_dbg_axim_to_u_fc_wstrb_s_i),
        .wlast_dbg_axim  (u_nic_wlast_dbg_axim_to_u_fc_wlast_s_i),
        .wvalid_dbg_axim (u_nic_wvalid_dbg_axim_to_u_fc_wvalid_s_i),
        .wready_dbg_axim (u_nic_wready_dbg_axim_to_u_fc_wready_s_o),
        .bid_dbg_axim    (u_nic_bid_dbg_axim_to_u_fc_bid_s_o),
        .bresp_dbg_axim  (u_nic_bresp_dbg_axim_to_u_fc_bresp_s_o),
        .bvalid_dbg_axim (u_nic_bvalid_dbg_axim_to_u_fc_bvalid_s_o),
        .bready_dbg_axim (u_nic_bready_dbg_axim_to_u_fc_bready_s_i),
        .arid_dbg_axim   (u_nic_arid_dbg_axim_to_u_fc_arid_s_i),
        .araddr_dbg_axim (u_nic_araddr_dbg_axim_to_u_fc_araddr_s_i),
        .arlen_dbg_axim  (u_nic_arlen_dbg_axim_to_u_fc_arlen_s_i),
        .arsize_dbg_axim (u_nic_arsize_dbg_axim_to_u_fc_arsize_s_i),
        .arburst_dbg_axim(u_nic_arburst_dbg_axim_to_u_fc_arburst_s_i),
        .arlock_dbg_axim (u_nic_arlock_dbg_axim_to_u_fc_arlock_s_i),
        .arcache_dbg_axim(u_nic_arcache_dbg_axim_to_u_fc_arcache_s_i),
        .arprot_dbg_axim (u_nic_arprot_dbg_axim_to_u_fc_arprot_s_i),
        .arvalid_dbg_axim(u_nic_arvalid_dbg_axim_to_u_fc_arvalid_s_i),
        .arready_dbg_axim(u_nic_arready_dbg_axim_to_u_fc_arready_s_o),

        .rid_dbg_axim    (u_nic_rid_dbg_axim_to_u_fc_rid_s_o),
        .rdata_dbg_axim  (u_nic_rdata_dbg_axim_to_u_fc_rdata_s_o),
        .rresp_dbg_axim  (u_nic_rresp_dbg_axim_to_u_fc_rresp_s_o),
        .rlast_dbg_axim  (u_nic_rlast_dbg_axim_to_u_fc_rlast_s_o),
        .rvalid_dbg_axim (u_nic_rvalid_dbg_axim_to_u_fc_rvalid_s_o),
        .rready_dbg_axim (u_nic_rready_dbg_axim_to_u_fc_rready_s_i),
        .awuser_dbg_axim (u_nic_awuser_dbg_axim_to_u_fc_awmmusid_s_i),
        .aruser_dbg_axim (u_nic_aruser_dbg_axim_to_u_fc_armmusid_s_i),

        .awid_p0_axis    (2'b0), 
        .awaddr_p0_axis  (u_soc_catu_awaddr_m_to_u_nic_awaddr_p0_axis),
        .awlen_p0_axis   (u_soc_catu_awlen_m_to_u_nic_awlen_p0_axis),
        .awsize_p0_axis  (u_soc_catu_awsize_m_to_u_nic_awsize_p0_axis),
        .awburst_p0_axis (u_soc_catu_awburst_m_to_u_nic_awburst_p0_axis),
        .awlock_p0_axis  (u_soc_catu_awlock_m_to_u_nic_awlock_p0_axis),
        .awcache_p0_axis (u_soc_catu_awcache_m_to_u_nic_awcache_p0_axis),
        .awprot_p0_axis  (u_soc_catu_awprot_m_to_u_nic_awprot_p0_axis),
        .awvalid_p0_axis (u_soc_catu_awvalid_m_to_u_nic_awvalid_p0_axis),
        .awready_p0_axis (u_soc_catu_awready_m_to_u_nic_awready_p0_axis),
        .wdata_p0_axis   (u_soc_catu_wdata_m_to_u_nic_wdata_p0_axis),
        .wstrb_p0_axis   (u_soc_catu_wstrb_m_to_u_nic_wstrb_p0_axis),
        .wlast_p0_axis   (u_soc_catu_wlast_m_to_u_nic_wlast_p0_axis),
        .wvalid_p0_axis  (u_soc_catu_wvalid_m_to_u_nic_wvalid_p0_axis),
        .wready_p0_axis  (u_soc_catu_wready_m_to_u_nic_wready_p0_axis),
        .bid_p0_axis     (),
        .bresp_p0_axis   (u_soc_catu_bresp_m_to_u_nic_bresp_p0_axis),
        .bvalid_p0_axis  (u_soc_catu_bvalid_m_to_u_nic_bvalid_p0_axis),
        .bready_p0_axis  (u_soc_catu_bready_m_to_u_nic_bready_p0_axis),
        .arid_p0_axis    (u_soc_catu_arid_m_to_u_nic_arid_p0_axis),
        .araddr_p0_axis  (u_soc_catu_araddr_m_to_u_nic_araddr_p0_axis),
        .arlen_p0_axis   (u_soc_catu_arlen_m_to_u_nic_arlen_p0_axis),
        .arsize_p0_axis  (u_soc_catu_arsize_m_to_u_nic_arsize_p0_axis),
        .arburst_p0_axis (u_soc_catu_arburst_m_to_u_nic_arburst_p0_axis),
        .arlock_p0_axis  (u_soc_catu_arlock_m_to_u_nic_arlock_p0_axis),
        .arcache_p0_axis (u_soc_catu_arcache_m_to_u_nic_arcache_p0_axis),
        .arprot_p0_axis  (u_soc_catu_arprot_m_to_u_nic_arprot_p0_axis),
        .arvalid_p0_axis (u_soc_catu_arvalid_m_to_u_nic_arvalid_p0_axis),
        .arready_p0_axis (u_soc_catu_arready_m_to_u_nic_arready_p0_axis),
        .rid_p0_axis     (u_soc_catu_rid_m_to_u_nic_rid_p0_axis),
        .rdata_p0_axis   (u_soc_catu_rdata_m_to_u_nic_rdata_p0_axis),
        .rresp_p0_axis   (u_soc_catu_rresp_m_to_u_nic_rresp_p0_axis),
        .rlast_p0_axis   (u_soc_catu_rlast_m_to_u_nic_rlast_p0_axis),
        .rvalid_p0_axis  (u_soc_catu_rvalid_m_to_u_nic_rvalid_p0_axis),
        .rready_p0_axis  (u_soc_catu_rready_m_to_u_nic_rready_p0_axis),
        .awuser_p0_axis  (3'd5),
        .aruser_p0_axis  (3'd5),

        .awid_p1_axis    (2'd1), 
        .awaddr_p1_axis  (u_host_catu_awaddr_m_to_u_nic_awaddr_p1_axis),
        .awlen_p1_axis   (u_host_catu_awlen_m_to_u_nic_awlen_p1_axis),
        .awsize_p1_axis  (u_host_catu_awsize_m_to_u_nic_awsize_p1_axis),
        .awburst_p1_axis (u_host_catu_awburst_m_to_u_nic_awburst_p1_axis),
        .awlock_p1_axis  (u_host_catu_awlock_m_to_u_nic_awlock_p1_axis),
        .awcache_p1_axis (u_host_catu_awcache_m_to_u_nic_awcache_p1_axis),
        .awprot_p1_axis  (u_host_catu_awprot_m_to_u_nic_awprot_p1_axis),
        .awvalid_p1_axis (u_host_catu_awvalid_m_to_u_nic_awvalid_p1_axis),
        .awready_p1_axis (u_host_catu_awready_m_to_u_nic_awready_p1_axis),
        .wdata_p1_axis   (u_host_catu_wdata_m_to_u_nic_wdata_p1_axis),
        .wstrb_p1_axis   (u_host_catu_wstrb_m_to_u_nic_wstrb_p1_axis),
        .wlast_p1_axis   (u_host_catu_wlast_m_to_u_nic_wlast_p1_axis),
        .wvalid_p1_axis  (u_host_catu_wvalid_m_to_u_nic_wvalid_p1_axis),
        .wready_p1_axis  (u_host_catu_wready_m_to_u_nic_wready_p1_axis),
        .bid_p1_axis     (),
        .bresp_p1_axis   (u_host_catu_bresp_m_to_u_nic_bresp_p1_axis),
        .bvalid_p1_axis  (u_host_catu_bvalid_m_to_u_nic_bvalid_p1_axis),
        .bready_p1_axis  (u_host_catu_bready_m_to_u_nic_bready_p1_axis),
        .arid_p1_axis    (u_host_catu_arid_m_to_u_nic_arid_p1_axis),
        .araddr_p1_axis  (u_host_catu_araddr_m_to_u_nic_araddr_p1_axis),
        .arlen_p1_axis   (u_host_catu_arlen_m_to_u_nic_arlen_p1_axis),
        .arsize_p1_axis  (u_host_catu_arsize_m_to_u_nic_arsize_p1_axis),
        .arburst_p1_axis (u_host_catu_arburst_m_to_u_nic_arburst_p1_axis),
        .arlock_p1_axis  (u_host_catu_arlock_m_to_u_nic_arlock_p1_axis),
        .arcache_p1_axis (u_host_catu_arcache_m_to_u_nic_arcache_p1_axis),
        .arprot_p1_axis  (u_host_catu_arprot_m_to_u_nic_arprot_p1_axis),
        .arvalid_p1_axis (u_host_catu_arvalid_m_to_u_nic_arvalid_p1_axis),
        .arready_p1_axis (u_host_catu_arready_m_to_u_nic_arready_p1_axis),
        .rid_p1_axis     (u_host_catu_rid_m_to_u_nic_rid_p1_axis),
        .rdata_p1_axis   (u_host_catu_rdata_m_to_u_nic_rdata_p1_axis),
        .rresp_p1_axis   (u_host_catu_rresp_m_to_u_nic_rresp_p1_axis),
        .rlast_p1_axis   (u_host_catu_rlast_m_to_u_nic_rlast_p1_axis),
        .rvalid_p1_axis  (u_host_catu_rvalid_m_to_u_nic_rvalid_p1_axis),
        .rready_p1_axis  (u_host_catu_rready_m_to_u_nic_rready_p1_axis),
        .awuser_p1_axis  (3'd3),
        .aruser_p1_axis  (3'd3),



        .awid_p2_axis    (2'd0), 
        .awaddr_p2_axis  (u_host_axiap_awaddr_m_to_u_nic_awaddr_p2_axis),
        .awlen_p2_axis   (u_host_axiap_awlen_m_to_u_nic_awlen_p2_axis),
        .awsize_p2_axis  (u_host_axiap_awsize_m_to_u_nic_awsize_p2_axis),
        .awburst_p2_axis (u_host_axiap_awburst_m_to_u_nic_awburst_p2_axis),
        .awlock_p2_axis  (u_host_axiap_awlock_m_to_u_nic_awlock_p2_axis),
        .awcache_p2_axis (u_host_axiap_awcache_m_to_u_nic_awcache_p2_axis),
        .awprot_p2_axis  (u_host_axiap_awprot_m_to_u_nic_awprot_p2_axis),
        .awvalid_p2_axis (u_host_axiap_awvalid_m_to_u_nic_awvalid_p2_axis),
        .awready_p2_axis (u_host_axiap_awready_m_to_u_nic_awready_p2_axis),
        .wdata_p2_axis   (u_host_axiap_wdata_m_to_u_nic_wdata_p2_axis),
        .wstrb_p2_axis   (u_host_axiap_wstrb_m_to_u_nic_wstrb_p2_axis),
        .wlast_p2_axis   (u_host_axiap_wlast_m_to_u_nic_wlast_p2_axis),
        .wvalid_p2_axis  (u_host_axiap_wvalid_m_to_u_nic_wvalid_p2_axis),
        .wready_p2_axis  (u_host_axiap_wready_m_to_u_nic_wready_p2_axis),
        .bid_p2_axis     (),
        .bresp_p2_axis   (u_host_axiap_bresp_m_to_u_nic_bresp_p2_axis),
        .bvalid_p2_axis  (u_host_axiap_bvalid_m_to_u_nic_bvalid_p2_axis),
        .bready_p2_axis  (u_host_axiap_bready_m_to_u_nic_bready_p2_axis),
        .arid_p2_axis    (2'd0),
        .araddr_p2_axis  (u_host_axiap_araddr_m_to_u_nic_araddr_p2_axis),
        .arlen_p2_axis   (u_host_axiap_arlen_m_to_u_nic_arlen_p2_axis),
        .arsize_p2_axis  (u_host_axiap_arsize_m_to_u_nic_arsize_p2_axis),
        .arburst_p2_axis (u_host_axiap_arburst_m_to_u_nic_arburst_p2_axis),
        .arlock_p2_axis  (u_host_axiap_arlock_m_to_u_nic_arlock_p2_axis),
        .arcache_p2_axis (u_host_axiap_arcache_m_to_u_nic_arcache_p2_axis),
        .arprot_p2_axis  (u_host_axiap_arprot_m_to_u_nic_arprot_p2_axis),
        .arvalid_p2_axis (u_host_axiap_arvalid_m_to_u_nic_arvalid_p2_axis),
        .arready_p2_axis (u_host_axiap_arready_m_to_u_nic_arready_p2_axis),
        .rid_p2_axis     (),
        .rdata_p2_axis   (u_host_axiap_rdata_m_to_u_nic_rdata_p2_axis),
        .rresp_p2_axis   (u_host_axiap_rresp_m_to_u_nic_rresp_p2_axis),
        .rlast_p2_axis   (u_host_axiap_rlast_m_to_u_nic_rlast_p2_axis),
        .rvalid_p2_axis  (u_host_axiap_rvalid_m_to_u_nic_rvalid_p2_axis),
        .rready_p2_axis  (u_host_axiap_rready_m_to_u_nic_rready_p2_axis),
        .awuser_p2_axis  (3'd4),
        .aruser_p2_axis  (3'd4),

        .cactive_cd_main (dbgclk_qactive   [14]),     
        .csysreq_cd_main (dbgclk_qreqn      [14]), 
        .csysack_cd_main (dbgclk_qacceptn   [14])      


    );
    assign dbgclk_qdeny[14] = 1'b0;
    
`include "firewall_f0_global_masterid_cfg_sse710.vh"
`include "firewall_f0_comp_global_cfg_sse710_dbg.vh" 
    firewall_f0_comp #(
 `include "firewall_f0_comp_cfg_sse710_dbg.vh"
    ) u_fc (
        .clk          (dbgclk_gated),
        .reset_n      (dbgclk_resetn),

        .arid_s_i    (u_nic_arid_dbg_axim_to_u_fc_arid_s_i),
        .araddr_s_i  (u_nic_araddr_dbg_axim_to_u_fc_araddr_s_i),
        .arlen_s_i   (u_nic_arlen_dbg_axim_to_u_fc_arlen_s_i),
        .arsize_s_i  (u_nic_arsize_dbg_axim_to_u_fc_arsize_s_i),
        .arburst_s_i (u_nic_arburst_dbg_axim_to_u_fc_arburst_s_i),
        .arlock_s_i  (u_nic_arlock_dbg_axim_to_u_fc_arlock_s_i),
        .arcache_s_i (u_nic_arcache_dbg_axim_to_u_fc_arcache_s_i),
        .arprot_s_i  (u_nic_arprot_dbg_axim_to_u_fc_arprot_s_i),
        .arqos_s_i   (4'd0), 
        .arregion_s_i(4'd0), 
        .aruser_s_i  (10'd0), 
        .arvalid_s_i (u_nic_arvalid_dbg_axim_to_u_fc_arvalid_s_i),
        .arready_s_o (u_nic_arready_dbg_axim_to_u_fc_arready_s_o),
        .armmusid_s_i({5'b00000, u_nic_aruser_dbg_axim_to_u_fc_armmusid_s_i}),

        .awid_s_i    (u_nic_awid_dbg_axim_to_u_fc_awid_s_i),
        .awaddr_s_i  (u_nic_awaddr_dbg_axim_to_u_fc_awaddr_s_i),
        .awlen_s_i   (u_nic_awlen_dbg_axim_to_u_fc_awlen_s_i),
        .awsize_s_i  (u_nic_awsize_dbg_axim_to_u_fc_awsize_s_i),
        .awburst_s_i (u_nic_awburst_dbg_axim_to_u_fc_awburst_s_i),
        .awlock_s_i  (u_nic_awlock_dbg_axim_to_u_fc_awlock_s_i),
        .awcache_s_i (u_nic_awcache_dbg_axim_to_u_fc_awcache_s_i),
        .awprot_s_i  (u_nic_awprot_dbg_axim_to_u_fc_awprot_s_i),
        .awqos_s_i   (4'd0), 
        .awregion_s_i(4'd0), 
        .awuser_s_i  (10'd0), 
        .awvalid_s_i (u_nic_awvalid_dbg_axim_to_u_fc_awvalid_s_i),
        .awready_s_o (u_nic_awready_dbg_axim_to_u_fc_awready_s_o),
        .awmmusid_s_i({5'b00000, u_nic_awuser_dbg_axim_to_u_fc_awmmusid_s_i}),

        .wdata_s_i   (u_nic_wdata_dbg_axim_to_u_fc_wdata_s_i),
        .wstrb_s_i   (u_nic_wstrb_dbg_axim_to_u_fc_wstrb_s_i),
        .wlast_s_i   (u_nic_wlast_dbg_axim_to_u_fc_wlast_s_i),
        .wuser_s_i   (1'd0), 
        .wvalid_s_i  (u_nic_wvalid_dbg_axim_to_u_fc_wvalid_s_i),
        .wready_s_o  (u_nic_wready_dbg_axim_to_u_fc_wready_s_o),

        .bid_s_o     (u_nic_bid_dbg_axim_to_u_fc_bid_s_o),
        .bresp_s_o   (u_nic_bresp_dbg_axim_to_u_fc_bresp_s_o),
        .buser_s_o   (), 
        .bvalid_s_o  (u_nic_bvalid_dbg_axim_to_u_fc_bvalid_s_o),
        .bready_s_i  (u_nic_bready_dbg_axim_to_u_fc_bready_s_i),

        .rid_s_o     (u_nic_rid_dbg_axim_to_u_fc_rid_s_o),
        .rdata_s_o   (u_nic_rdata_dbg_axim_to_u_fc_rdata_s_o),
        .rresp_s_o   (u_nic_rresp_dbg_axim_to_u_fc_rresp_s_o),
        .rlast_s_o   (u_nic_rlast_dbg_axim_to_u_fc_rlast_s_o),
        .ruser_s_o   (), 
        .rvalid_s_o  (u_nic_rvalid_dbg_axim_to_u_fc_rvalid_s_o),
        .rready_s_i  (u_nic_rready_dbg_axim_to_u_fc_rready_s_i),

        .awakeup_s_i (1'b0), 


        .arid_m_o    (fc_arid_m_o),
        .araddr_m_o  (fc_araddr_m_o),
        .arlen_m_o   (fc_arlen_m_o),
        .arsize_m_o  (fc_arsize_m_o),
        .arburst_m_o (fc_arburst_m_o),
        .arlock_m_o  (fc_arlock_m_o),
        .arcache_m_o (fc_arcache_m_o),
        .arprot_m_o  (fc_arprot_m_o),
        .arqos_m_o   (fc_arqos_m_o),
        .arregion_m_o(fc_arregion_m_o),
        .aruser_m_o  (fc_aruser_m_o),
        .arvalid_m_o (fc_arvalid_m_o),
        .arready_m_i (fc_arready_m_i),
        .armmusid_m_o(fc_armmusid_m_o),

        .awid_m_o    (fc_awid_m_o),
        .awaddr_m_o  (fc_awaddr_m_o),
        .awlen_m_o   (fc_awlen_m_o),
        .awsize_m_o  (fc_awsize_m_o),
        .awburst_m_o (fc_awburst_m_o),
        .awlock_m_o  (fc_awlock_m_o),
        .awcache_m_o (fc_awcache_m_o),
        .awprot_m_o  (fc_awprot_m_o),
        .awqos_m_o   (fc_awqos_m_o),
        .awregion_m_o(fc_awregion_m_o),
        .awuser_m_o  (fc_awuser_m_o),
        .awvalid_m_o (fc_awvalid_m_o),
        .awready_m_i (fc_awready_m_i),
        .awmmusid_m_o(fc_awmmusid_m_o),

        .wdata_m_o   (fc_wdata_m_o),
        .wstrb_m_o   (fc_wstrb_m_o),
        .wlast_m_o   (fc_wlast_m_o),
        .wuser_m_o   (fc_wuser_m_o),
        .wvalid_m_o  (fc_wvalid_m_o),
        .wready_m_i  (fc_wready_m_i),

        .bid_m_i     (fc_bid_m_i),
        .bresp_m_i   (fc_bresp_m_i),
        .buser_m_i   (fc_buser_m_i),
        .bvalid_m_i  (fc_bvalid_m_i),
        .bready_m_o  (fc_bready_m_o),

        .rid_m_i     (fc_rid_m_i),
        .rdata_m_i   (fc_rdata_m_i),
        .rresp_m_i   (fc_rresp_m_i),
        .rlast_m_i   (fc_rlast_m_i),
        .ruser_m_i   (fc_ruser_m_i),
        .rvalid_m_i  (fc_rvalid_m_i),
        .rready_m_o  (fc_rready_m_o),

        .awakeup_m_o (fc_awakeup_m_o),



        .tvalid_ds_o (fc_tvalid_ds_o),
        .tready_ds_i (fc_tready_ds_i),
        .tdata_ds_o  (fc_tdata_ds_o),
        .tkeep_ds_o  (fc_tkeep_ds_o),
        .tlast_ds_o  (fc_tlast_ds_o),
        .tid_ds_o    (), 
        .twakeup_ds_o(fc_twakeup_ds_o),


        .tvalid_us_i (fc_tvalid_us_i),
        .tready_us_o (fc_tready_us_o),
        .tdata_us_i  (fc_tdata_us_i),
        .tkeep_us_i  (fc_tkeep_us_i),
        .tlast_us_i  (fc_tlast_us_i),
        .tdest_us_i  (DBG_FC_ID), 
        .twakeup_us_i(fc_twakeup_us_i),

        .clk_qreqn_i   (dbgclk_qreqn   [16]),
        .clk_qacceptn_o(dbgclk_qacceptn[16]),
        .clk_qdeny_o   (dbgclk_qdeny   [16]),
        .clk_qactive_o (dbgclk_qactive [16]),

        .pwr_qreqn_i   (qreqn_dbgtop),
        .pwr_qacceptn_o(qacceptn_dbgtop),
        .pwr_qdeny_o   (qdeny_dbgtop   ),
        .pwr_qactive_o (qactive_dbgtop ),
        .dftcgen       (dftcgen),

        .bypass_i      (fctrl_bypass)
    );

endmodule

