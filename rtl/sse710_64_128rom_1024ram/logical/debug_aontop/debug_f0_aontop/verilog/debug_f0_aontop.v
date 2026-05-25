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

module debug_f0_aontop    
 (
    input  wire                 dbgclk,
    input  wire                 dbgclk_reset_n,
    input  wire                 porst_n,    
    input  wire                 dftcgen,

    input  wire [6:0]           dbgclk_qreqn,
    output wire [6:0]           dbgclk_qacceptn,
    output wire [6:0]           dbgclk_qdeny,
    output wire [6:0]           dbgclk_qactive,
    output wire [14:0]          dbgclk_qactive_only,
    
    
    input  wire                 swclktck,
    input  wire                 ntrst,
    input  wire                 swditms,
    output wire                 swdo,
    output wire                 swdo_en,
    input  wire                 tdi,
    output wire                 tdo,
    output wire                 tdo_en_n,
    output wire                 swactive,
    output wire                 jtagactive,
    output wire [3:0]           jtagir,
    output wire [3:0]           jtagstate,
    output wire                 dormantstate,

    output wire                 dpslv_cdbgpwrupreq,
    input  wire                 dpslv_cdbgpwrupack,
    output wire                 dpslv_csyspwrupreq,
    input  wire                 dpslv_csyspwrupack,
    output wire                 dpslv_cdbgrstreq,
    input  wire                 dpslv_cdbgrstack,

    input  wire [31:0]          targetid,
    input  wire [3:0]           instanceid,
    input  wire [31:0]          baseaddr,
    input  wire                 baseaddr_valid,

    input  wire                 hostext_async_req_i,
    input  wire [67:0]          hostext_async_req_payload_i,
    output wire [32:0]          hostext_async_resp_payload_o,
    output wire                 hostext_async_ack_o,

    input  wire                 extsys0_psel_s,
    input  wire [2:0]           extsys0_pprot_s,
    input  wire [31:0]          extsys0_paddr_s,
    input  wire                 extsys0_penable_s,
    input  wire                 extsys0_pwrite_s,
    input  wire [31:0]          extsys0_pwdata_s,
    input  wire [3:0]           extsys0_pstrb_s,
    input  wire                 extsys0_pwakeup_s,
    output wire                 extsys0_pready_s,
    output wire [31:0]          extsys0_prdata_s,
    output wire                 extsys0_pslverr_s,

    input  wire                 acg_extsys0_dbgen,

    input  wire                 extsys1_psel_s,
    input  wire [2:0]           extsys1_pprot_s,
    input  wire [31:0]          extsys1_paddr_s,
    input  wire                 extsys1_penable_s,
    input  wire                 extsys1_pwrite_s,
    input  wire [31:0]          extsys1_pwdata_s,
    input  wire [3:0]           extsys1_pstrb_s,
    input  wire                 extsys1_pwakeup_s,
    output wire                 extsys1_pready_s,
    output wire [31:0]          extsys1_prdata_s,
    output wire                 extsys1_pslverr_s,

    input  wire                 acg_extsys1_dbgen,

    output wire                 dprom_cdbgpwrupreq,
    input  wire                 dprom_cdbgpwrupack,
    output wire                 dprom_csyspwrupreq,
    input  wire                 dprom_csyspwrupack,
    output wire                 dprom_cdbgrstreq,
    input  wire                 dprom_cdbgrstack,
    output wire                 dprom_csysrstreq,
    input  wire                 dprom_csysrstack,

    input  wire                 pwrdbg_apb_pwrqreqn_i,
    output wire                 pwrdbg_apb_pwrqacceptn_o,
    output wire                 pwrdbg_apb_pwrqdeny_o,
    output wire                 pwrdbg_apb_pwrqactive_o,    
        
    
    output wire                 apb_async_req_o,
    output wire [67:0]          apb_async_req_payload_o,
    input  wire [32:0]          apb_async_resp_payload_i,
    input  wire                 apb_async_ack_i,


    input  wire                 acg_hostext_dbgen,
    input  wire                 acg_dp_dbgen,


    input  wire                 dbgen_dpauth,
    input  wire                 niden_dpauth,
    input  wire                 spiden_dpauth,
    input  wire                 spniden_dpauth,

    input  wire                 u_soc_cti_event_out_6_to_u_dp_eventstat,

    output wire                 dp_abort_pulse_req,
    input  wire                 dp_abort_pulse_ack,
    input  wire                 dp_abort_pwr_qreq_n,
    output wire                 dp_abort_pwr_qaccept_n,
    output wire                 dp_abort_pwr_qactive,
    

    output wire   [7:0]         ei_data_sdc600,
    output wire                 ei_req_sdc600,
    input  wire                 ei_ack_sdc600,
    input  wire                 ei_linkup_sdc600,
    output wire                 ei_linkest_sdc600,
    input  wire   [7:0]         ie_data_sdc600,
    input  wire                 ie_req_sdc600,
    output wire                 ie_ack_sdc600,
    output wire                 ie_linkup_sdc600,
    input  wire                 ie_linkest_sdc600,

    input   wire                dbgen_comauth,
    input   wire                niden_comauth,
    input   wire                sdc600_ext_rempua,
    input   wire                sdc600_ext_remra,
    output  wire                sdc600_ext_rempur,
    output  wire                sdc600_ext_remrr,
    output  wire                calc,
    input   wire [3:0]          dprom_revision,   
    input   wire [11:0]         dprom_part_number,
    input   wire [10:0]         dprom_jep106_id,  
    input   wire [3:0]          dprom_eco_rev_and    


);


    localparam                         U_DP_ARBITER_SLAVE_CNT        = 4;
    localparam                         U_HOSTEXT_ARBITER_SLAVE_CNT   = 2;
    localparam                         U_EXTSYS_ARBITER_SLAVE_CNT   = 2;
    localparam                         U_DECODER_SDC_NUM_APB_SLAVES  = 1+1+2; 
    localparam                         U_DECODER_SDC_NUM_APB_MASTERS = 1;
    localparam                         U_DECODER_ACG_NUM_APB_SLAVES  = 1+1+2; 
    localparam                         U_DECODER_ACG_NUM_APB_MASTERS = 1;

    localparam                         DPROM_NUM_ENTRIES     = 3;
    localparam [DPROM_NUM_ENTRIES-1:0] U_DPROM_ENTRY_PRESENT = {DPROM_NUM_ENTRIES {1'b1}};

    wire  [7:0]         sdc600_ext_rx_data;
    wire                sdc600_ext_rx_valid;
    wire                sdc600_ext_rx_linkest;
    wire                sdc600_ext_rx_ready;
    wire                sdc600_ext_rx_linkup;
    wire                sdc600_ext_tx_ready;
    wire                sdc600_ext_tx_linkup;
    wire  [7:0]         sdc600_ext_tx_data;
    wire                sdc600_ext_tx_valid;
    wire                sdc600_ext_tx_linkest;


    wire                                   bus_req;
    wire [62:0]                            bus_req_payload;
    wire                                   bus_ack;
    wire [33:0]                            bus_ack_payload;
    wire                                   dp_abort_req;
    wire                                   dp_abort_ack;


    wire                                   u_dpmstr_psel_m_to_u_dp_arbiter_psel_s;
    wire [31:0]                            u_dpmstr_paddr_m_to_u_dp_arbiter_paddr_s;
    wire                                   u_dpmstr_penable_m;
    wire                                   u_pmstr_pready_m_to_u_dp_arbiter_pready_s;
    wire [31:0]                            u_dpmstr_prdata_m_to_u_dp_arbiter_prdata_s;
    wire                                   u_dpmstr_pslverr_m_to_u_dp_arbiter_pslverr_s;
    wire                                   u_dpmstr_dp_abort;

    wire                                   u_dp_arbiter_psel_m_to_u_dprom_psel_s;
    wire                                   u_dp_arbiter_pready_m_to_u_dprom_pready_s;
    wire [31:0]                            u_dp_arbiter_prdata_m_to_u_dprom_prdata_s;
    wire                                   u_dp_arbiter_pslverr_m_to_u_dprom_pslverr_s;


    wire                                   u_dp_arbiter_psel_m_to_u_decoder_sdc_psel_s;
    wire                                   u_dp_arbiter_pready_m_to_u_decoder_sdc_pready_s;
    wire                                   u_dp_arbiter_pslverr_m_to_u_decoder_sdc_pslverr_s;


    wire [31:0]                            i_addr_arb_dp;
    wire [U_DP_ARBITER_SLAVE_CNT-1:0]      i_sel_arb_dp;

    wire [31:0]                            u_apbhostext_mst_paddr_o_to_u_hostext_arbiter_paddr_s;
    wire                                   u_apbhostext_mst_psel_o_to_u_hostext_arbiter_psel_s;
    wire                                   u_apbhostext_mst_penable_o;
    wire                                   u_apbhostext_mst_pready_i_to_u_hostext_arbiter_pready_s;
    wire [31:0]                            u_apbhostext_mst_prdata_i_to_u_hostext_arbiter_prdata_s;
    wire                                   u_apbhostext_mst_pslverr_i_to_u_hostext_arbiter_pslverr_s;
    wire                                   u_hostext_arbiter_psel_m_to_u_decoder_sdc_psel_s;
    wire                                   u_hostext_arbiter_pready_m_to_u_decoder_sdc_pready_s;
    wire                                   u_hostext_arbiter_pslverr_m_to_u_decoder_sdc_pslverr_s;
    wire                                   u_hostext_arbiter_psel_m_to_u_acg_hostext_psel_s;
    wire                                   u_hostext_arbiter_pready_m_to_acg_hostext_pready_s;
    wire [31:0]                            u_hostext_arbiter_prdata_m_to_acg_hostext_prdata_s;
    wire                                   u_hostext_arbiter_pslverr_m_to_acg_hostext_slverr_s;
    wire [2:0]                             u_apbhostext_mst_pprot_o;
    wire                                   u_apbhostext_mst_pwrite_o;
    wire [31:0]                            u_apbhostext_mst_pwdata_o;
    wire [3:0]                             u_apbhostext_mst_pstrb_o;
    wire                                   u_apbhostext_mst_pwakeup_o;

    wire                                   u_dp_arbiter_psel_m_to_u_acg_dp_psel_s;
    wire [31:0]                            u_dp_arbiter_prdata_m_to_u_acg_dp_prdata_s;
    wire                                   u_dp_arbiter_pready_m_to_u_acg_dp_pready_s;
    wire                                   u_dp_arbiter_pslverr_m_to_u_acg_dp_slverr_s;

    wire                                   u_dp_arbiter_psel_m_to_u_gpio_apb_psel_s;
    wire [31:0]                            u_dp_arbiter_prdata_m_to_u_gpio_apb_prdata_s;
    wire                                   u_dp_arbiter_pready_m_to_u_gpio_apb_pready_s;
    wire                                   u_dp_arbiter_pslverr_m_to_u_gpio_apb_slverr_s;

    wire [31:0]                            i_addr_arb_hostext;
    wire [U_HOSTEXT_ARBITER_SLAVE_CNT-1:0] i_sel_arb_hostext;


    wire [31:0]                            u_acg_dp_paddr_m_to_u_decoder_acg_paddr_s;
    wire [31:0]                            u_acg_dp_pwdata_m_to_u_decoder_acg_pwdata_s;
    wire                                   u_acg_dp_pwrite_m_to_u_decoder_acg_pwrite_s;
    wire [2:0]                             u_acg_dp_pprot_m_to_u_decoder_acg_pprot_s;
    wire                                   u_acg_dp_psel_m_to_u_decoder_acg_psel_s;
    wire                                   u_acg_dp_penable_m_to_u_decoder_acg_penable_s;
    wire                                   u_acg_dp_pready_m_to_u_decoder_acg_pready_s;
    wire                                   u_acg_dp_pslverr_m_to_u_decoder_acg_pslverr_s;



    wire [31:0]                            u_acg_hostext_paddr_m_to_u_decoder_acg_paddr_s;
    wire [31:0]                            u_acg_hostext_pwdata_m_to_u_decoder_acg_pwdata_s;
    wire                                   u_acg_hostext_pwrite_m_to_u_decoder_acg_pwrite_s;
    wire [2:0]                             u_acg_hostext_pprot_m_to_u_decoder_acg_pprot_s;
    wire                                   u_acg_hostext_psel_m_to_u_decoder_acg_psel_s;
    wire                                   u_acg_hostext_penable_m_to_u_decoder_acg_penable_s;
    wire                                   u_acg_hostext_pready_m_to_u_decoder_acg_pready_s;
    wire                                   u_acg_hostext_pslverr_m_to_u_decoder_acg_pslverr_s;

    wire [31:0]                            u_acg_extsys0_paddr_m_to_u_decoder_acg_paddr_s;
    wire [31:0]                            u_acg_extsys0_pwdata_m_to_u_decoder_acg_pwdata_s;
    wire                                   u_acg_extsys0_pwrite_m_to_u_decoder_acg_pwrite_s;
    wire [2:0]                             u_acg_extsys0_pprot_m_to_u_decoder_acg_pprot_s;
    wire                                   u_acg_extsys0_psel_m_to_u_decoder_acg_psel_s;
    wire                                   u_acg_extsys0_penable_m_to_u_decoder_acg_penable_s;
    wire                                   u_acg_extsys0_pready_m_to_u_decoder_acg_pready_s;
    wire                                   u_acg_extsys0_pslverr_m_to_u_decoder_acg_pslverr_s;

    wire [31:0]                            u_acg_extsys1_paddr_m_to_u_decoder_acg_paddr_s;
    wire [31:0]                            u_acg_extsys1_pwdata_m_to_u_decoder_acg_pwdata_s;
    wire                                   u_acg_extsys1_pwrite_m_to_u_decoder_acg_pwrite_s;
    wire [2:0]                             u_acg_extsys1_pprot_m_to_u_decoder_acg_pprot_s;
    wire                                   u_acg_extsys1_psel_m_to_u_decoder_acg_psel_s;
    wire                                   u_acg_extsys1_penable_m_to_u_decoder_acg_penable_s;
    wire                                   u_acg_extsys1_pready_m_to_u_decoder_acg_pready_s;
    wire                                   u_acg_extsys1_pslverr_m_to_u_decoder_acg_pslverr_s;

    wire                                   u_extsys0_arbiter_psel_m_to_u_decoder_sdc_psel_s;
    wire                                   u_extsys0_arbiter_pready_m_to_u_decoder_sdc_pready_s;
    wire                                   u_extsys0_arbiter_pslverr_m_to_u_decoder_sdc_pslverr_s;
    wire                                   u_extsys0_arbiter_psel_m_to_psel_s;
    wire                                   u_extsys0_arbiter_pready_m_to_pready_s;
    wire [31:0]                            u_extsys0_arbiter_prdata_m_to_prdata_s;
    wire                                   u_extsys0_arbiter_pslverr_m_to_slverr_s;

    wire [31:0]                            i_addr_arb_extsys0;
    wire [U_EXTSYS_ARBITER_SLAVE_CNT-1:0]  i_sel_arb_extsys0;

    wire                                   u_extsys1_arbiter_psel_m_to_u_decoder_sdc_psel_s;
    wire                                   u_extsys1_arbiter_pready_m_to_u_decoder_sdc_pready_s;
    wire                                   u_extsys1_arbiter_pslverr_m_to_u_decoder_sdc_pslverr_s;
    wire                                   u_extsys1_arbiter_psel_m_to_psel_s;
    wire                                   u_extsys1_arbiter_pready_m_to_pready_s;
    wire [31:0]                            u_extsys1_arbiter_prdata_m_to_prdata_s;
    wire                                   u_extsys1_arbiter_pslverr_m_to_slverr_s;

    wire [31:0]                            i_addr_arb_extsys1;
    wire [U_EXTSYS_ARBITER_SLAVE_CNT-1:0]  i_sel_arb_extsys1;

    wire [31:0]                            u_decoder_sdc_prdata_s;
    wire [31:0]                            u_decoder_acg_prdata_s;

    wire                                   u_extsys0_arbiter_psel_m_to_u_acg_extsys0_psel_s;
    wire [31:0]                            u_extsys0_arbiter_prdata_m_to_u_acg_extsys0_prdata_s;
    wire                                   u_extsys0_arbiter_pready_m_to_u_acg_extsys0_pready_s;
    wire                                   u_extsys0_arbiter_pslverr_m_to_u_acg_extsys0_slverr_s;

    wire                                   u_extsys1_arbiter_psel_m_to_u_acg_extsys1_psel_s;
    wire [31:0]                            u_extsys1_arbiter_prdata_m_to_u_acg_extsys1_prdata_s;
    wire                                   u_extsys1_arbiter_pready_m_to_u_acg_extsys1_pready_s;
    wire                                   u_extsys1_arbiter_pslverr_m_to_u_acg_extsys1_slverr_s;

    wire                                   u_decoder_acg_pwakeup_e_to_u_expander_acg_pwakeup_e;
    wire                                   u_decoder_acg_psel_e_to_u_expander_acg_psel_e;
    wire                                   u_decoder_acg_penable_e_to_u_expander_acg_penable_e;
    wire                                   u_decoder_acg_pwrite_e_to_u_expander_acg_pwrite_e;
    wire [2:0]                             u_decoder_acg_pprot_e_to_u_expander_acg_pprot_e;
    wire [31:0]                            u_decoder_acg_paddr_e_to_u_expander_acg_paddr_e;
    wire [31:0]                            u_decoder_acg_pwdata_e_to_u_expander_acg_pwdata_e;
    wire                                   u_decoder_acg_pready_e_to_u_expander_acg_pready_e;
    wire                                   u_decoder_acg_pslverr_e_to_u_expander_acg_pslverr_e;
    wire [31:0]                            u_decoder_acg_prdata_e_to_u_expander_acg_prdata_e;



    wire                                   u_expander_acg_pwakeup_e_to_u_apb_slv_pwakeup_i;
    wire                                   u_expander_acg_psel_e_to_u_apb_slv_psel_i;
    wire                                   u_expander_acg_penable_e_to_u_apb_slv_penable_i;
    wire                                   u_expander_acg_pwrite_e_to_u_apb_slv_pwrite_i;
    wire [2:0]                             u_expander_acg_pprot_e_to_u_apb_slv_pprot_i;
    wire [31:0]                            u_expander_acg_paddr_e_to_u_apb_slv_paddr_i;
    wire [31:0]                            u_expander_acg_pwdata_e_to_u_apb_slv_pwdata_i;
    wire                                   u_expander_acg_pready_e_to_u_apb_slv_pready_o;
    wire                                   u_expander_acg_pslverr_e_to_u_apb_slv_pslverr_o;
    wire [31:0]                            u_expander_acg_prdata_e_to_u_apb_slv_prdata_o;


    wire                                   u_dpmstr_pwrite_m;
    wire                                   u_dpmstr_pwakeup_m;
    wire [31:0]                            u_dpmstr_pwdata_m;


    wire                                   u_decoder_sdc_pwakeup_e_to_u_expander_sdc_pwakeup_e;
    wire                                   u_decoder_sdc_psel_e_to_u_expander_sdc_psel_e;
    wire                                   u_decoder_sdc_penable_e_to_u_expander_sdc_penable_e;
    wire                                   u_decoder_sdc_pwrite_e_to_u_expander_sdc_pwrite_e;
    wire [2:0]                             u_decoder_sdc_pprot_e_to_u_expander_sdc_pprot_e;
    wire [11:0]                            u_decoder_sdc_paddr_e_to_u_expander_sdc_paddr_e;
    wire [31:0]                            u_decoder_sdc_pwdata_e_to_u_expander_sdc_pwdata_e;
    wire                                   u_decoder_sdc_pready_e_to_u_expander_sdc_pready_e;
    wire                                   u_decoder_sdc_pslverr_e_to_u_expander_sdc_pslverr_e;
    wire [31:0]                            u_decoder_sdc_prdata_e_to_u_expander_sdc_prdata_e;


    wire                                   u_expander_sdc_pwakeup_e_to_u_sdc600_ext_pwakeup_s;
    wire                                   u_expander_sdc_psel_e_to_u_sdc600_ext_psel_s;
    wire                                   u_expander_sdc_penable_e_to_u_sdc600_ext_penable_s;
    wire                                   u_expander_sdc_pwrite_e_to_u_sdc600_ext_pwrite_s;
    wire [11:0]                            u_expander_sdc_paddr_e_to_u_sdc600_ext_paddr_s;
    wire [31:0]                            u_expander_sdc_pwdata_e_to_u_sdc600_ext_pwdata_s;
    wire [31:0]                            u_expander_sdc_prdata_e_to_u_sdc600_ext_prdata_s;
    wire                                   u_expander_sdc_pready_e_to_u_sdc600_ext_pready_s;
    wire                                   u_expander_sdc_pslverr_e_to_u_sdc600_ext_pslverr_s;


    wire [2:0]                             pprot_s_default;    
    

    wire                                   dbgen_dpauth_ss;
    wire                                   niden_dpauth_ss;
    wire                                   spiden_dpauth_ss;
    wire                                   spniden_dpauth_ss;

    wire                                   dbgen_comauth_ss;
    wire                                   niden_comauth_ss;

    wire                                   acg_dp_dbgen_ss;
    wire                                   acg_hostext_dbgen_ss;
    wire                                   acg_extsys0_dbgen_ss;
    wire                                   acg_extsys1_dbgen_ss;
    
    wire                                   unused;
    wire                                   ntrst_and_porst;
    
    
    
    
    arm_element_cdc_comb_and2 u_ntrst_and_porst (
        .din1_async(porst_n),
        .din2_async(ntrst),
        .dout_async(ntrst_and_porst)
    );
    
    
    
    assign pprot_s_default   = 3'b000;    
    
    css600_dpslv u_dpslv (
      .swclktck       (swclktck),
      .porst_n        (porst_n),

      .ntrst          (ntrst_and_porst),
      .swditms        (swditms),
      .tdi            (tdi),
      .swdo           (swdo),
      .swdo_en        (swdo_en),
      .tdo            (tdo),
      .tdo_en_n       (tdo_en_n),

      .swactive       (swactive),
      .jtagactive     (jtagactive),
      .jtagir         (jtagir),
      .jtagstate      (jtagstate),
      .dormantstate   (dormantstate),

      .dp_eventstatus (u_soc_cti_event_out_6_to_u_dp_eventstat),

      .cdbgpwrupreq   (dpslv_cdbgpwrupreq),
      .cdbgpwrupack   (dpslv_cdbgpwrupack),
      .csyspwrupreq   (dpslv_csyspwrupreq),
      .csyspwrupack   (dpslv_csyspwrupack),
      .cdbgrstreq     (dpslv_cdbgrstreq),
      .cdbgrstack     (dpslv_cdbgrstack),

      .targetid       (targetid),
      .instanceid     (instanceid),
      .baseaddr       (baseaddr),
      .baseaddr_valid (baseaddr_valid),

      .bus_req        (bus_req),
      .bus_req_payload(bus_req_payload),
      .bus_ack        (bus_ack),
      .bus_ack_payload(bus_ack_payload),
      .dp_abort_req   (dp_abort_req),
      .dp_abort_ack   (dp_abort_ack)
    );


     css600_dpmstr u_dpmstr (
      .clk            (dbgclk),
      .reset_n        (dbgclk_reset_n),
      .psel_m         (u_dpmstr_psel_m_to_u_dp_arbiter_psel_s),
      .pwakeup_m      (u_dpmstr_pwakeup_m),
      .penable_m      (u_dpmstr_penable_m),
      .pwrite_m       (u_dpmstr_pwrite_m),
      .paddr_m        (u_dpmstr_paddr_m_to_u_dp_arbiter_paddr_s),
      .pwdata_m       (u_dpmstr_pwdata_m),
      .prdata_m       (u_dpmstr_prdata_m_to_u_dp_arbiter_prdata_s),
      .pready_m       (u_pmstr_pready_m_to_u_dp_arbiter_pready_s),
      .pslverr_m      (u_dpmstr_pslverr_m_to_u_dp_arbiter_pslverr_s),


      .clk_qreq_n     (dbgclk_qreqn   [0]),
      .clk_qaccept_n  (dbgclk_qacceptn[0]),
      .clk_qactive    (dbgclk_qactive [0]),
      .clk_qdeny      (dbgclk_qdeny   [0]),
      .bus_req        (bus_req),
      .bus_req_payload(bus_req_payload),
      .bus_ack        (bus_ack),
      .bus_ack_payload(bus_ack_payload),
      .dp_abort_req   (dp_abort_req),
      .dp_abort_ack   (dp_abort_ack),

      .dp_abort       (u_dpmstr_dp_abort)

    );


      css600_pulseasyncbridgeslv u_dp_abort (
        .clk_s          (dbgclk),
        .reset_s_n      (dbgclk_reset_n),
        .pulse_in       (u_dpmstr_dp_abort),
        .pulse_req      (dp_abort_pulse_req),
        .pulse_ack      (dp_abort_pulse_ack),
        .pwr_qreq_n     (dp_abort_pwr_qreq_n),
        .pwr_qaccept_n  (dp_abort_pwr_qaccept_n),
        .pwr_qactive    (),
        .clk_s_qactive  (dbgclk_qactive_only[0])
    );

    assign dp_abort_pwr_qactive = 1'b0;

    apb4_arbiter #(
        .SLAVE_CNT(U_DP_ARBITER_SLAVE_CNT)
    ) u_dp_arbiter (
        .clk      (dbgclk),
        .resetn   (dbgclk_reset_n),
        .paddr_s  (u_dpmstr_paddr_m_to_u_dp_arbiter_paddr_s),
        .psel_s   (u_dpmstr_psel_m_to_u_dp_arbiter_psel_s),
        .pprot_s  (pprot_s_default),
        .penable_s(u_dpmstr_penable_m),
        .pready_s (u_pmstr_pready_m_to_u_dp_arbiter_pready_s),
        .prdata_s (u_dpmstr_prdata_m_to_u_dp_arbiter_prdata_s),
        .pslverr_s(u_dpmstr_pslverr_m_to_u_dp_arbiter_pslverr_s),
        
        .psel_m   ({u_dp_arbiter_psel_m_to_u_acg_dp_psel_s,      
                    u_dp_arbiter_psel_m_to_u_decoder_sdc_psel_s, 
                    u_dp_arbiter_psel_m_to_u_gpio_apb_psel_s,     
                    u_dp_arbiter_psel_m_to_u_dprom_psel_s}),     
        .pready_m ({u_dp_arbiter_pready_m_to_u_acg_dp_pready_s,        
                    u_dp_arbiter_pready_m_to_u_decoder_sdc_pready_s,   
                    u_dp_arbiter_pready_m_to_u_gpio_apb_pready_s,       
                    u_dp_arbiter_pready_m_to_u_dprom_pready_s}),       
                    
        .prdata_m ({u_dp_arbiter_prdata_m_to_u_acg_dp_prdata_s,        
                    u_decoder_sdc_prdata_s,                            
                    u_dp_arbiter_prdata_m_to_u_gpio_apb_prdata_s,       
                    u_dp_arbiter_prdata_m_to_u_dprom_prdata_s}),       
                    
        .pslverr_m({u_dp_arbiter_pslverr_m_to_u_acg_dp_slverr_s,       
                    u_dp_arbiter_pslverr_m_to_u_decoder_sdc_pslverr_s,  
                    u_dp_arbiter_pslverr_m_to_u_gpio_apb_slverr_s,      
                    u_dp_arbiter_pslverr_m_to_u_dprom_pslverr_s}),     
        .addr_arb (i_addr_arb_dp),
        .sel_arb  (i_sel_arb_dp),
        .slv_sec  (4'd0),
        .qactive  (dbgclk_qactive_only[1])
    );

    assign i_sel_arb_dp[0] = i_addr_arb_dp[31:12] == 20'h000; 
    assign i_sel_arb_dp[1] = i_addr_arb_dp[31:12] == 20'h010; 
    assign i_sel_arb_dp[2] = i_addr_arb_dp[31:12] == 20'h020; 
    assign i_sel_arb_dp[3] = i_addr_arb_dp[31:16] >= 16'h03;  

    assign u_apbhostext_mst_pstrb_o = {4{u_apbhostext_mst_pwrite_o}};
    
    css600_apbasyncbridgemstr #(
    .APB_ADDR_WIDTH      (32),
    .FF_SYNC_DEPTH       (2)
    
    ) u_apbhostext_mst (
        .clk_m                    (dbgclk),
        .reset_m_n                 (dbgclk_reset_n),
        .dftcgen                 (dftcgen),
         .psel_m                 (u_apbhostext_mst_psel_o_to_u_hostext_arbiter_psel_s),
         .penable_m              (u_apbhostext_mst_penable_o),
         .paddr_m                (u_apbhostext_mst_paddr_o_to_u_hostext_arbiter_paddr_s),
         .pwrite_m               (u_apbhostext_mst_pwrite_o),
         .pwdata_m               (u_apbhostext_mst_pwdata_o),
         .pprot_m                (u_apbhostext_mst_pprot_o),
         .prdata_m               (u_apbhostext_mst_prdata_i_to_u_hostext_arbiter_prdata_s),
         .pready_m               (u_apbhostext_mst_pready_i_to_u_hostext_arbiter_pready_s),
         .pslverr_m              (u_apbhostext_mst_pslverr_i_to_u_hostext_arbiter_pslverr_s),
        .pwakeup_m               (u_apbhostext_mst_pwakeup_o),
        .clk_m_qreq_n           (dbgclk_qreqn   [1]),
        .clk_m_qaccept_n        (dbgclk_qacceptn[1]),
        .clk_m_qdeny            (dbgclk_qdeny   [1]),
        .clk_m_qactive          (dbgclk_qactive [1]),
        .apb_async_req         (hostext_async_req_i),
        .apb_async_req_payload (hostext_async_req_payload_i),
        .apb_async_resp_payload (hostext_async_resp_payload_o),
        .apb_async_ack         (hostext_async_ack_o)
    );

    apb4_arbiter #(
        .SLAVE_CNT(U_HOSTEXT_ARBITER_SLAVE_CNT)
    ) u_hostext_arbiter (
        .clk      (dbgclk),
        .resetn   (dbgclk_reset_n),
        .paddr_s  ({7'd0, u_apbhostext_mst_paddr_o_to_u_hostext_arbiter_paddr_s[24:0]}), 
        .psel_s   (u_apbhostext_mst_psel_o_to_u_hostext_arbiter_psel_s),
        .pprot_s  (u_apbhostext_mst_pprot_o),
        .penable_s(u_apbhostext_mst_penable_o),
        .pready_s (u_apbhostext_mst_pready_i_to_u_hostext_arbiter_pready_s),
        .prdata_s (u_apbhostext_mst_prdata_i_to_u_hostext_arbiter_prdata_s),
        .pslverr_s(u_apbhostext_mst_pslverr_i_to_u_hostext_arbiter_pslverr_s),
        .psel_m   ({u_hostext_arbiter_psel_m_to_u_acg_hostext_psel_s,   
                    u_hostext_arbiter_psel_m_to_u_decoder_sdc_psel_s}), 
        .pready_m ({u_hostext_arbiter_pready_m_to_acg_hostext_pready_s,     
                    u_hostext_arbiter_pready_m_to_u_decoder_sdc_pready_s}), 
        .prdata_m ({u_hostext_arbiter_prdata_m_to_acg_hostext_prdata_s,   
                    u_decoder_sdc_prdata_s}),                             
        .pslverr_m({u_hostext_arbiter_pslverr_m_to_acg_hostext_slverr_s,      
                    u_hostext_arbiter_pslverr_m_to_u_decoder_sdc_pslverr_s}), 
        .addr_arb (i_addr_arb_hostext),
        .sel_arb  (i_sel_arb_hostext),
        .slv_sec  (2'd0),
        .qactive  (dbgclk_qactive_only[2])
    );

    assign i_sel_arb_hostext[0]  = i_addr_arb_hostext[31:12] == 20'h20;
    assign i_sel_arb_hostext[1]  = i_addr_arb_hostext[31:16] >= 16'd3;


    apb4_arbiter #(
        .SLAVE_CNT(U_EXTSYS_ARBITER_SLAVE_CNT)
    ) u_extsys0_arbiter (
        .clk      (dbgclk),
        .resetn   (dbgclk_reset_n),
        .paddr_s  (extsys0_paddr_s),
        .psel_s   (extsys0_psel_s),
        .pprot_s  (extsys0_pprot_s),
        .penable_s(extsys0_penable_s),
        .pready_s (extsys0_pready_s),
        .prdata_s (extsys0_prdata_s),
        .pslverr_s(extsys0_pslverr_s),
        .psel_m   ({u_extsys0_arbiter_psel_m_to_u_acg_extsys0_psel_s,   
                    u_extsys0_arbiter_psel_m_to_u_decoder_sdc_psel_s}), 
        .pready_m ({u_extsys0_arbiter_pready_m_to_u_acg_extsys0_pready_s,   
                    u_extsys0_arbiter_pready_m_to_u_decoder_sdc_pready_s}), 
        .prdata_m ({u_extsys0_arbiter_prdata_m_to_u_acg_extsys0_prdata_s,   
                    u_decoder_sdc_prdata_s}),                               // m0 
        .pslverr_m({u_extsys0_arbiter_pslverr_m_to_u_acg_extsys0_slverr_s,    
                    u_extsys0_arbiter_pslverr_m_to_u_decoder_sdc_pslverr_s}), 
        .addr_arb (i_addr_arb_extsys0),
        .sel_arb  (i_sel_arb_extsys0),
        .slv_sec  (2'd0),
        .qactive  (dbgclk_qactive_only[3])
    );

    assign i_sel_arb_extsys0[0] = i_addr_arb_extsys0[31:12] == 20'h20;
    assign i_sel_arb_extsys0[1] = i_addr_arb_extsys0[31:16] >= 16'd3;

    apb4_arbiter #(
        .SLAVE_CNT(U_EXTSYS_ARBITER_SLAVE_CNT)
    ) u_extsys1_arbiter (
        .clk      (dbgclk),
        .resetn   (dbgclk_reset_n),
        .paddr_s  (extsys1_paddr_s),
        .psel_s   (extsys1_psel_s),
        .pprot_s  (extsys1_pprot_s),
        .penable_s(extsys1_penable_s),
        .pready_s (extsys1_pready_s),
        .prdata_s (extsys1_prdata_s),
        .pslverr_s(extsys1_pslverr_s),
        .psel_m   ({u_extsys1_arbiter_psel_m_to_u_acg_extsys1_psel_s,   
                    u_extsys1_arbiter_psel_m_to_u_decoder_sdc_psel_s}), 
        .pready_m ({u_extsys1_arbiter_pready_m_to_u_acg_extsys1_pready_s,   
                    u_extsys1_arbiter_pready_m_to_u_decoder_sdc_pready_s}), 
        .prdata_m ({u_extsys1_arbiter_prdata_m_to_u_acg_extsys1_prdata_s,   
                    u_decoder_sdc_prdata_s}),                               // m1 
        .pslverr_m({u_extsys1_arbiter_pslverr_m_to_u_acg_extsys1_slverr_s,    
                    u_extsys1_arbiter_pslverr_m_to_u_decoder_sdc_pslverr_s}), 
        .addr_arb (i_addr_arb_extsys1),
        .sel_arb  (i_sel_arb_extsys1),
        .slv_sec  (2'd0),
        .qactive  (dbgclk_qactive_only[4])
    );

    assign i_sel_arb_extsys1[0] = i_addr_arb_extsys1[31:12] == 20'h20;
    assign i_sel_arb_extsys1[1] = i_addr_arb_extsys1[31:16] >= 16'd3;


    sdc600_comasyncbridge_indirect_half_ext u_sdc600_comasyncbridge_indirect_half_ext (
       .resetn_ext            (dbgclk_reset_n),
       .clk_ext               (dbgclk),
       .ext_rx_data           (sdc600_ext_tx_data),
       .ext_rx_valid          (sdc600_ext_tx_valid),
       .ext_rx_ready          (sdc600_ext_tx_ready),
       .ext_rx_linkup         (sdc600_ext_tx_linkup),
       .ext_rx_linkest        (sdc600_ext_tx_linkest),
       .ext_async_ie_data     (ie_data_sdc600   ),
       .ext_async_ie_req      (ie_req_sdc600    ),
       .ext_async_ie_ack      (ie_ack_sdc600    ),
       .ext_async_ie_linkup   (ie_linkup_sdc600 ),
       .ext_async_ie_linkest  (ie_linkest_sdc600),
       .ext_async_ei_data     (ei_data_sdc600   ),
       .ext_async_ei_req      (ei_req_sdc600    ),
       .ext_async_ei_ack      (ei_ack_sdc600    ),
       .ext_async_ei_linkup   (ei_linkup_sdc600 ),
       .ext_async_ei_linkest  (ei_linkest_sdc600),
       .ext_tx_data           (sdc600_ext_rx_data),
       .ext_tx_valid          (sdc600_ext_rx_valid),
       .ext_tx_ready          (sdc600_ext_rx_ready),
       .ext_tx_linkup         (sdc600_ext_rx_linkup),
       .ext_tx_linkest        (sdc600_ext_rx_linkest),

       .ext_clk_qreq_n        (dbgclk_qreqn   [2]),
       .ext_clk_qaccept_n     (dbgclk_qacceptn[2]),
       .ext_clk_qdeny         (dbgclk_qdeny   [2]),
       .ext_clk_qactive       (dbgclk_qactive [2]),

       .ext_pwr_qreq_n        (1'b1),
       .ext_pwr_qaccept_n     (),
       .ext_pwr_qdeny         (),
       .ext_pwr_qactive       (),
       .ext_pwr_wake          ()
       
       
      );


    sdc600_apbcom_ext u_sdc600_ext (

        .pclk          (dbgclk),
        .preset_n      (dbgclk_reset_n),

        .cfg_rrdis     (niden_comauth_ss),
        .cfg_pen       (dbgen_comauth_ss),

        .paddr_s       (u_expander_sdc_paddr_e_to_u_sdc600_ext_paddr_s),
        .pwrite_s      (u_expander_sdc_pwrite_e_to_u_sdc600_ext_pwrite_s),
        .psel_s        (u_expander_sdc_psel_e_to_u_sdc600_ext_psel_s),
        .pwakeup_s     (u_expander_sdc_pwakeup_e_to_u_sdc600_ext_pwakeup_s),
        .penable_s     (u_expander_sdc_penable_e_to_u_sdc600_ext_penable_s),
        .pwdata_s      (u_expander_sdc_pwdata_e_to_u_sdc600_ext_pwdata_s),
        .prdata_s      (u_expander_sdc_prdata_e_to_u_sdc600_ext_prdata_s),
        .pready_s      (u_expander_sdc_pready_e_to_u_sdc600_ext_pready_s),
        .pslverr_s     (u_expander_sdc_pslverr_e_to_u_sdc600_ext_pslverr_s),

        .dp_abort      (u_dpmstr_dp_abort),

        .rx_data       (sdc600_ext_rx_data),
        .rx_valid      (sdc600_ext_rx_valid),
        .rx_linkest    (sdc600_ext_rx_linkest),
        .rx_ready      (sdc600_ext_rx_ready),
        .rx_linkup     (sdc600_ext_rx_linkup),

        .tx_ready      (sdc600_ext_tx_ready),
        .tx_linkup     (sdc600_ext_tx_linkup),
        .tx_data       (sdc600_ext_tx_data),
        .tx_valid      (sdc600_ext_tx_valid),
        .tx_linkest    (sdc600_ext_tx_linkest),

        .rempua        (sdc600_ext_rempua),
        .remra         (sdc600_ext_remra),
        .rempur        (sdc600_ext_rempur),
        .remrr         (sdc600_ext_remrr),


        .clk_qreq_n    (dbgclk_qreqn   [3]),
        .clk_qaccept_n (dbgclk_qacceptn[3]),
        .clk_qdeny     (dbgclk_qdeny   [3]),
        .clk_qactive   (dbgclk_qactive [3])
    );



    css600_apbrom_gpr
    #(
        .NUM_ENTRIES(DPROM_NUM_ENTRIES),
        .ROM_ENTRY0 (32'h0001_0003), 
        .ROM_ENTRY1 (32'h0002_0003),  
        .ROM_ENTRY2 (32'h0003_0007)  
    )
     u_dprom (
        .clk          (dbgclk),
        .reset_n      (dbgclk_reset_n),
        .psel_s       (u_dp_arbiter_psel_m_to_u_dprom_psel_s),
        .penable_s    (u_dpmstr_penable_m),
        .pwrite_s     (u_dpmstr_pwrite_m),
        .paddr_s      (i_addr_arb_dp[11:0]),
        .pwdata_s     (u_dpmstr_pwdata_m),
        .pready_s     (u_dp_arbiter_pready_m_to_u_dprom_pready_s),
        .pslverr_s    (u_dp_arbiter_pslverr_m_to_u_dprom_pslverr_s),
        .prdata_s     (u_dp_arbiter_prdata_m_to_u_dprom_prdata_s),
        .cdbgpwrupreq (dprom_cdbgpwrupreq),
        .cdbgpwrupack (dprom_cdbgpwrupack),
        .csyspwrupreq (dprom_csyspwrupreq),
        .csyspwrupack (dprom_csyspwrupack),
        .cdbgrstreq   (dprom_cdbgrstreq),
        .cdbgrstack   (dprom_cdbgrstack),
        .csysrstreq   (dprom_csysrstreq),
        .csysrstack   (dprom_csysrstack),
        .dbgen        (dbgen_dpauth_ss),
        .niden        (niden_dpauth_ss),
        .spiden       (spiden_dpauth_ss),
        .spniden      (spniden_dpauth_ss),
        .revision     (dprom_revision),
        .part_number  (dprom_part_number),
        .jep106_id    (dprom_jep106_id),
        .eco_rev_and  (dprom_eco_rev_and),
        .entry_present(U_DPROM_ENTRY_PRESENT)
    );


    gpio_apb  #(
        .GPIO_INPUT(0),
        .GPIO_OUTPUT(1)
       )
       u_gpio_apb (
        .clk      (dbgclk),
        .resetn   (dbgclk_reset_n),
        .paddr    (i_addr_arb_dp[11:0]),
        .pwdata   (u_dpmstr_pwdata_m),
        .pwrite   (u_dpmstr_pwrite_m),
        .psel     (u_dp_arbiter_psel_m_to_u_gpio_apb_psel_s  ),
        .penable  (u_dpmstr_penable_m),
        .prdata   (u_dp_arbiter_prdata_m_to_u_gpio_apb_prdata_s  ),
        .pready   (u_dp_arbiter_pready_m_to_u_gpio_apb_pready_s  ),
        .pslverr  (u_dp_arbiter_pslverr_m_to_u_gpio_apb_slverr_s  ),
        .dbgen    (1'b1),
        .gpio_out (calc),
        .gpio_in  (1'b0) 
    );
    
    daacg_f0 u_acg_dp(
        .pclk     (dbgclk),
        .presetn  (dbgclk_reset_n),
        .paddr_s  (i_addr_arb_dp),
        .pwdata_s (u_dpmstr_pwdata_m),
        .pwrite_s (u_dpmstr_pwrite_m),
        .pstrb_s  ({4{u_dpmstr_pwrite_m}}),
        .pprot_s  (pprot_s_default),
        .psel_s   (u_dp_arbiter_psel_m_to_u_acg_dp_psel_s),
        .penable_s(u_dpmstr_penable_m),
        .prdata_s (u_dp_arbiter_prdata_m_to_u_acg_dp_prdata_s),
        .pready_s (u_dp_arbiter_pready_m_to_u_acg_dp_pready_s),
        .pslverr_s(u_dp_arbiter_pslverr_m_to_u_acg_dp_slverr_s),
        .paddr_m  (u_acg_dp_paddr_m_to_u_decoder_acg_paddr_s),
        .pwdata_m (u_acg_dp_pwdata_m_to_u_decoder_acg_pwdata_s),
        .pwrite_m (u_acg_dp_pwrite_m_to_u_decoder_acg_pwrite_s),
        .pstrb_m  (),
        .pprot_m  (u_acg_dp_pprot_m_to_u_decoder_acg_pprot_s),
        .psel_m   (u_acg_dp_psel_m_to_u_decoder_acg_psel_s),
        .penable_m(u_acg_dp_penable_m_to_u_decoder_acg_penable_s),
        .prdata_m (u_decoder_acg_prdata_s),
        .pready_m (u_acg_dp_pready_m_to_u_decoder_acg_pready_s),
        .pslverr_m(u_acg_dp_pslverr_m_to_u_decoder_acg_pslverr_s),
        .dbgen    (acg_dp_dbgen_ss)
    );



    daacg_f0 u_acg_hostext(
        .pclk     (dbgclk),
        .presetn  (dbgclk_reset_n),
        .paddr_s  (i_addr_arb_hostext),
        .pwdata_s (u_apbhostext_mst_pwdata_o),
        .pwrite_s (u_apbhostext_mst_pwrite_o),
        .pstrb_s  (u_apbhostext_mst_pstrb_o),
        .pprot_s  (u_apbhostext_mst_pprot_o),
        .psel_s   (u_hostext_arbiter_psel_m_to_u_acg_hostext_psel_s),
        .penable_s(u_apbhostext_mst_penable_o),
        .prdata_s (u_hostext_arbiter_prdata_m_to_acg_hostext_prdata_s),
        .pready_s (u_hostext_arbiter_pready_m_to_acg_hostext_pready_s),
        .pslverr_s(u_hostext_arbiter_pslverr_m_to_acg_hostext_slverr_s),
        .paddr_m  (u_acg_hostext_paddr_m_to_u_decoder_acg_paddr_s),
        .pwdata_m (u_acg_hostext_pwdata_m_to_u_decoder_acg_pwdata_s),
        .pwrite_m (u_acg_hostext_pwrite_m_to_u_decoder_acg_pwrite_s),
        .pstrb_m  (),
        .pprot_m  (u_acg_hostext_pprot_m_to_u_decoder_acg_pprot_s),
        .psel_m   (u_acg_hostext_psel_m_to_u_decoder_acg_psel_s),
        .penable_m(u_acg_hostext_penable_m_to_u_decoder_acg_penable_s),
        .prdata_m (u_decoder_acg_prdata_s),
        .pready_m (u_acg_hostext_pready_m_to_u_decoder_acg_pready_s),
        .pslverr_m(u_acg_hostext_pslverr_m_to_u_decoder_acg_pslverr_s),
        .dbgen    (acg_hostext_dbgen_ss)
    );



    daacg_f0 u_acg_extsys0(
        .pclk     (dbgclk),
        .presetn  (dbgclk_reset_n),
        .paddr_s  (i_addr_arb_extsys0),
        .pwdata_s (extsys0_pwdata_s),
        .pwrite_s (extsys0_pwrite_s),
        .pstrb_s  (extsys0_pstrb_s),
        .pprot_s  (extsys0_pprot_s),
        .psel_s   (u_extsys0_arbiter_psel_m_to_u_acg_extsys0_psel_s),
        .penable_s(extsys0_penable_s),
        .prdata_s (u_extsys0_arbiter_prdata_m_to_u_acg_extsys0_prdata_s),
        .pready_s (u_extsys0_arbiter_pready_m_to_u_acg_extsys0_pready_s),
        .pslverr_s(u_extsys0_arbiter_pslverr_m_to_u_acg_extsys0_slverr_s),
        .paddr_m  (u_acg_extsys0_paddr_m_to_u_decoder_acg_paddr_s),
        .pwdata_m (u_acg_extsys0_pwdata_m_to_u_decoder_acg_pwdata_s),
        .pwrite_m (u_acg_extsys0_pwrite_m_to_u_decoder_acg_pwrite_s),
        .pstrb_m  (),
        .pprot_m  (u_acg_extsys0_pprot_m_to_u_decoder_acg_pprot_s),
        .psel_m   (u_acg_extsys0_psel_m_to_u_decoder_acg_psel_s),
        .penable_m(u_acg_extsys0_penable_m_to_u_decoder_acg_penable_s),
        .prdata_m (u_decoder_acg_prdata_s),
        .pready_m (u_acg_extsys0_pready_m_to_u_decoder_acg_pready_s),
        .pslverr_m(u_acg_extsys0_pslverr_m_to_u_decoder_acg_pslverr_s),
        .dbgen    (acg_extsys0_dbgen_ss)
    );

    daacg_f0 u_acg_extsys1(
        .pclk     (dbgclk),
        .presetn  (dbgclk_reset_n),
        .paddr_s  (i_addr_arb_extsys1),
        .pwdata_s (extsys1_pwdata_s),
        .pwrite_s (extsys1_pwrite_s),
        .pstrb_s  (extsys1_pstrb_s),
        .pprot_s  (extsys1_pprot_s),
        .psel_s   (u_extsys1_arbiter_psel_m_to_u_acg_extsys1_psel_s),
        .penable_s(extsys1_penable_s),
        .prdata_s (u_extsys1_arbiter_prdata_m_to_u_acg_extsys1_prdata_s),
        .pready_s (u_extsys1_arbiter_pready_m_to_u_acg_extsys1_pready_s),
        .pslverr_s(u_extsys1_arbiter_pslverr_m_to_u_acg_extsys1_slverr_s),
        .paddr_m  (u_acg_extsys1_paddr_m_to_u_decoder_acg_paddr_s),
        .pwdata_m (u_acg_extsys1_pwdata_m_to_u_decoder_acg_pwdata_s),
        .pwrite_m (u_acg_extsys1_pwrite_m_to_u_decoder_acg_pwrite_s),
        .pstrb_m  (),
        .pprot_m  (u_acg_extsys1_pprot_m_to_u_decoder_acg_pprot_s),
        .psel_m   (u_acg_extsys1_psel_m_to_u_decoder_acg_psel_s),
        .penable_m(u_acg_extsys1_penable_m_to_u_decoder_acg_penable_s),
        .prdata_m (u_decoder_acg_prdata_s),
        .pready_m (u_acg_extsys1_pready_m_to_u_decoder_acg_pready_s),
        .pslverr_m(u_acg_extsys1_pslverr_m_to_u_decoder_acg_pslverr_s),
        .dbgen    (acg_extsys1_dbgen_ss)
    );



    css600_apbicdecoder #(
        .APB_SLAVE_ADDR_WIDTH   (32),
        .NUM_APB_SLAVES         (U_DECODER_SDC_NUM_APB_SLAVES),
        .NUM_APB_MASTERS        (U_DECODER_SDC_NUM_APB_MASTERS),
        .NUM_EXPANDERS          (1),
        .M0_BASE_ADDR           ('h20000),
        .M0_ADDR_WIDTH          (12),
        .M0_GROUP               (0)
    ) u_decoder_sdc_0 (
        .clk          (dbgclk),
        .reset_n      (dbgclk_reset_n),
        .pwakeup_s    ({
                        extsys1_pwakeup_s,
                        extsys0_pwakeup_s,
                        u_apbhostext_mst_pwakeup_o,
                        u_dpmstr_pwakeup_m}),
        .psel_s       ({
                        u_extsys1_arbiter_psel_m_to_u_decoder_sdc_psel_s, 
                        u_extsys0_arbiter_psel_m_to_u_decoder_sdc_psel_s, 
                        u_hostext_arbiter_psel_m_to_u_decoder_sdc_psel_s, 
                        u_dp_arbiter_psel_m_to_u_decoder_sdc_psel_s}),    
        .penable_s    ({
                        extsys1_penable_s,
                        extsys0_penable_s,
                        u_apbhostext_mst_penable_o,
                        u_dpmstr_penable_m}),
        .pwrite_s     ({
                        extsys1_pwrite_s,
                        extsys0_pwrite_s,
                        u_apbhostext_mst_pwrite_o,
                        u_dpmstr_pwrite_m}),
        .pprot_s      ({
                        extsys1_pprot_s,
                        extsys0_pprot_s,
                        u_apbhostext_mst_pprot_o,
                        pprot_s_default}),
        .paddr_s      ({
                        i_addr_arb_extsys1,
                        i_addr_arb_extsys0,
                        i_addr_arb_hostext,
                        i_addr_arb_dp}),
        .pwdata_s     ({
                        extsys1_pwdata_s,
                        extsys0_pwdata_s,
                        u_apbhostext_mst_pwdata_o,
                        u_dpmstr_pwdata_m}),
        .pready_s     ({
                        u_extsys1_arbiter_pready_m_to_u_decoder_sdc_pready_s, 
                        u_extsys0_arbiter_pready_m_to_u_decoder_sdc_pready_s, 
                        u_hostext_arbiter_pready_m_to_u_decoder_sdc_pready_s, 
                        u_dp_arbiter_pready_m_to_u_decoder_sdc_pready_s}),    
        .pslverr_s    ({
                        u_extsys1_arbiter_pslverr_m_to_u_decoder_sdc_pslverr_s, 
                        u_extsys0_arbiter_pslverr_m_to_u_decoder_sdc_pslverr_s, 
                        u_hostext_arbiter_pslverr_m_to_u_decoder_sdc_pslverr_s, 
                        u_dp_arbiter_pslverr_m_to_u_decoder_sdc_pslverr_s}),    
        .prdata_s     (u_decoder_sdc_prdata_s),

        .pwakeup_e    (u_decoder_sdc_pwakeup_e_to_u_expander_sdc_pwakeup_e),
        .psel_e       (u_decoder_sdc_psel_e_to_u_expander_sdc_psel_e),
        .penable_e    (u_decoder_sdc_penable_e_to_u_expander_sdc_penable_e),
        .pwrite_e     (u_decoder_sdc_pwrite_e_to_u_expander_sdc_pwrite_e),
        .pprot_e      (u_decoder_sdc_pprot_e_to_u_expander_sdc_pprot_e),
        .paddr_e      (u_decoder_sdc_paddr_e_to_u_expander_sdc_paddr_e),
        .pwdata_e     (u_decoder_sdc_pwdata_e_to_u_expander_sdc_pwdata_e),
        .pready_e     (u_decoder_sdc_pready_e_to_u_expander_sdc_pready_e),
        .pslverr_e    (u_decoder_sdc_pslverr_e_to_u_expander_sdc_pslverr_e),
        .prdata_e     (u_decoder_sdc_prdata_e_to_u_expander_sdc_prdata_e),

        .clk_qreq_n   (dbgclk_qreqn   [4]),
        .clk_qaccept_n(dbgclk_qacceptn[4]),
        .clk_qdeny    (dbgclk_qdeny   [4]),
        .clk_qactive  (dbgclk_qactive [4])
    );



    css600_apbicexpander #(
        .APB_SLAVE_ADDR_WIDTH   (32),
        .NUM_APB_SLAVES         (U_DECODER_SDC_NUM_APB_SLAVES),
        .NUM_APB_MASTERS        (U_DECODER_SDC_NUM_APB_MASTERS),
        .M0_BASE_ADDR           ('h20000),
        .M0_ADDR_WIDTH          (12),
        .M0_GROUP               (0)
    ) u_expander_sdc (
        .clk          (dbgclk),
        .reset_n      (dbgclk_reset_n),

        .pwakeup_e    (u_decoder_sdc_pwakeup_e_to_u_expander_sdc_pwakeup_e),
        .psel_e       (u_decoder_sdc_psel_e_to_u_expander_sdc_psel_e),
        .penable_e    (u_decoder_sdc_penable_e_to_u_expander_sdc_penable_e),
        .pwrite_e     (u_decoder_sdc_pwrite_e_to_u_expander_sdc_pwrite_e),
        .pprot_e      (u_decoder_sdc_pprot_e_to_u_expander_sdc_pprot_e),
        .paddr_e      (u_decoder_sdc_paddr_e_to_u_expander_sdc_paddr_e),
        .pwdata_e     (u_decoder_sdc_pwdata_e_to_u_expander_sdc_pwdata_e),
        .pready_e     (u_decoder_sdc_pready_e_to_u_expander_sdc_pready_e),
        .pslverr_e    (u_decoder_sdc_pslverr_e_to_u_expander_sdc_pslverr_e),
        .prdata_e     (u_decoder_sdc_prdata_e_to_u_expander_sdc_prdata_e),

        .pwakeup_m    (u_expander_sdc_pwakeup_e_to_u_sdc600_ext_pwakeup_s),
        .psel_m       (u_expander_sdc_psel_e_to_u_sdc600_ext_psel_s),
        .penable_m    (u_expander_sdc_penable_e_to_u_sdc600_ext_penable_s),
        .pwrite_m     (u_expander_sdc_pwrite_e_to_u_sdc600_ext_pwrite_s),
        .pprot_m      (),
        .paddr_m      (u_expander_sdc_paddr_e_to_u_sdc600_ext_paddr_s),
        .pwdata_m     (u_expander_sdc_pwdata_e_to_u_sdc600_ext_pwdata_s),
        .pready_m     (u_expander_sdc_pready_e_to_u_sdc600_ext_pready_s),
        .prdata_m     (u_expander_sdc_prdata_e_to_u_sdc600_ext_prdata_s),
        .pslverr_m    (u_expander_sdc_pslverr_e_to_u_sdc600_ext_pslverr_s)

    );

    css600_apbicdecoder #(
        .APB_SLAVE_ADDR_WIDTH   (32),
        .NUM_APB_SLAVES         (U_DECODER_ACG_NUM_APB_SLAVES),
        .NUM_APB_MASTERS        (U_DECODER_ACG_NUM_APB_MASTERS),
        .NUM_EXPANDERS          (1),
        .M0_BASE_ADDR           ('h0),
        .M0_ADDR_WIDTH          (31), 
        .M0_GROUP               (0)
    ) u_decoder_acg (
        .clk          (dbgclk),
        .reset_n      (dbgclk_reset_n),
        .pwakeup_s    ({
                        extsys1_pwakeup_s,
                        extsys0_pwakeup_s,
                        u_apbhostext_mst_pwakeup_o,
                        u_dpmstr_pwakeup_m}),
        .psel_s       ({
                        u_acg_extsys1_psel_m_to_u_decoder_acg_psel_s, 
                        u_acg_extsys0_psel_m_to_u_decoder_acg_psel_s, 
                        u_acg_hostext_psel_m_to_u_decoder_acg_psel_s, 
                        u_acg_dp_psel_m_to_u_decoder_acg_psel_s     }),    
        .penable_s    ({
                        u_acg_extsys1_penable_m_to_u_decoder_acg_penable_s, 
                        u_acg_extsys0_penable_m_to_u_decoder_acg_penable_s, 
                        u_acg_hostext_penable_m_to_u_decoder_acg_penable_s, 
                        u_acg_dp_penable_m_to_u_decoder_acg_penable_s}),    
        .pwrite_s     ({
                        u_acg_extsys1_pwrite_m_to_u_decoder_acg_pwrite_s, 
                        u_acg_extsys0_pwrite_m_to_u_decoder_acg_pwrite_s, 
                        u_acg_hostext_pwrite_m_to_u_decoder_acg_pwrite_s, 
                        u_acg_dp_pwrite_m_to_u_decoder_acg_pwrite_s}),    
        .pprot_s      ({
                        u_acg_extsys1_pprot_m_to_u_decoder_acg_pprot_s, 
                        u_acg_extsys0_pprot_m_to_u_decoder_acg_pprot_s, 
                        u_acg_hostext_pprot_m_to_u_decoder_acg_pprot_s, 
                        u_acg_dp_pprot_m_to_u_decoder_acg_pprot_s}),    
        .paddr_s      ({
                        u_acg_extsys1_paddr_m_to_u_decoder_acg_paddr_s, 
                        u_acg_extsys0_paddr_m_to_u_decoder_acg_paddr_s, 
                        u_acg_hostext_paddr_m_to_u_decoder_acg_paddr_s, 
                        u_acg_dp_paddr_m_to_u_decoder_acg_paddr_s}),    
        .pwdata_s     ({
                        u_acg_extsys1_pwdata_m_to_u_decoder_acg_pwdata_s, 
                        u_acg_extsys0_pwdata_m_to_u_decoder_acg_pwdata_s, 
                        u_acg_hostext_pwdata_m_to_u_decoder_acg_pwdata_s, 
                        u_acg_dp_pwdata_m_to_u_decoder_acg_pwdata_s}),    
        .pready_s     ({
                        u_acg_extsys1_pready_m_to_u_decoder_acg_pready_s, 
                        u_acg_extsys0_pready_m_to_u_decoder_acg_pready_s, 
                        u_acg_hostext_pready_m_to_u_decoder_acg_pready_s, 
                        u_acg_dp_pready_m_to_u_decoder_acg_pready_s}),    
        .pslverr_s    ({
                        u_acg_extsys1_pslverr_m_to_u_decoder_acg_pslverr_s, 
                        u_acg_extsys0_pslverr_m_to_u_decoder_acg_pslverr_s, 
                        u_acg_hostext_pslverr_m_to_u_decoder_acg_pslverr_s, 
                        u_acg_dp_pslverr_m_to_u_decoder_acg_pslverr_s}),    
        .prdata_s     (u_decoder_acg_prdata_s),
        .pwakeup_e    (u_decoder_acg_pwakeup_e_to_u_expander_acg_pwakeup_e),
        .psel_e       (u_decoder_acg_psel_e_to_u_expander_acg_psel_e),
        .penable_e    (u_decoder_acg_penable_e_to_u_expander_acg_penable_e),
        .pwrite_e     (u_decoder_acg_pwrite_e_to_u_expander_acg_pwrite_e),
        .pprot_e      (u_decoder_acg_pprot_e_to_u_expander_acg_pprot_e),
        .paddr_e      (u_decoder_acg_paddr_e_to_u_expander_acg_paddr_e[30:0]),
        .pwdata_e     (u_decoder_acg_pwdata_e_to_u_expander_acg_pwdata_e),
        .pready_e     (u_decoder_acg_pready_e_to_u_expander_acg_pready_e),
        .pslverr_e    (u_decoder_acg_pslverr_e_to_u_expander_acg_pslverr_e),
        .prdata_e     (u_decoder_acg_prdata_e_to_u_expander_acg_prdata_e),


        .clk_qreq_n   (dbgclk_qreqn   [5]),
        .clk_qaccept_n(dbgclk_qacceptn[5]),
        .clk_qdeny    (dbgclk_qdeny   [5]),
        .clk_qactive  (dbgclk_qactive [5])
    );



    css600_apbicexpander #(
        .APB_SLAVE_ADDR_WIDTH   (32),
        .NUM_APB_SLAVES         (U_DECODER_ACG_NUM_APB_SLAVES),
        .NUM_APB_MASTERS        (U_DECODER_ACG_NUM_APB_MASTERS),
        .NUM_EXPANDERS          (1),
        .M0_BASE_ADDR           (32'h0),
        .M0_ADDR_WIDTH          (31),
        .M0_GROUP               (0)
    ) u_expander_acg (
        .clk          (dbgclk),
        .reset_n      (dbgclk_reset_n),

        .pwakeup_e    (u_decoder_acg_pwakeup_e_to_u_expander_acg_pwakeup_e),
        .psel_e       (u_decoder_acg_psel_e_to_u_expander_acg_psel_e),
        .penable_e    (u_decoder_acg_penable_e_to_u_expander_acg_penable_e),
        .pwrite_e     (u_decoder_acg_pwrite_e_to_u_expander_acg_pwrite_e),
        .pprot_e      (u_decoder_acg_pprot_e_to_u_expander_acg_pprot_e),
        .paddr_e      (u_decoder_acg_paddr_e_to_u_expander_acg_paddr_e[30:0]),
        .pwdata_e     (u_decoder_acg_pwdata_e_to_u_expander_acg_pwdata_e),
        .pready_e     (u_decoder_acg_pready_e_to_u_expander_acg_pready_e),
        .pslverr_e    (u_decoder_acg_pslverr_e_to_u_expander_acg_pslverr_e),
        .prdata_e     (u_decoder_acg_prdata_e_to_u_expander_acg_prdata_e),

        .pwakeup_m    (u_expander_acg_pwakeup_e_to_u_apb_slv_pwakeup_i),
        .psel_m       (u_expander_acg_psel_e_to_u_apb_slv_psel_i),
        .penable_m    (u_expander_acg_penable_e_to_u_apb_slv_penable_i),
        .pwrite_m     (u_expander_acg_pwrite_e_to_u_apb_slv_pwrite_i),
        .pprot_m      (u_expander_acg_pprot_e_to_u_apb_slv_pprot_i),
        .paddr_m      (u_expander_acg_paddr_e_to_u_apb_slv_paddr_i[30:0]),
        .pwdata_m     (u_expander_acg_pwdata_e_to_u_apb_slv_pwdata_i),
        .pready_m     (u_expander_acg_pready_e_to_u_apb_slv_pready_o),
        .pslverr_m    (u_expander_acg_pslverr_e_to_u_apb_slv_pslverr_o),
        .prdata_m     (u_expander_acg_prdata_e_to_u_apb_slv_prdata_o)
    );
    assign u_expander_acg_paddr_e_to_u_apb_slv_paddr_i[31] = 1'b0;

    css600_apbasyncbridgeslv #(
    .APB_ADDR_WIDTH      (32),
    .WAKE_ON_TRANSACTION (0)
    ) u_apb_slv(
        .clk_s                    (dbgclk),
        .reset_s_n                 (dbgclk_reset_n),
        .dftcgen                 (dftcgen),
        .psel_s                  (u_expander_acg_psel_e_to_u_apb_slv_psel_i),
        .penable_s               (u_expander_acg_penable_e_to_u_apb_slv_penable_i),
        .paddr_s                 (u_expander_acg_paddr_e_to_u_apb_slv_paddr_i),
        .pwrite_s                (u_expander_acg_pwrite_e_to_u_apb_slv_pwrite_i),
        .pwdata_s                (u_expander_acg_pwdata_e_to_u_apb_slv_pwdata_i),
        .prdata_s                (u_expander_acg_prdata_e_to_u_apb_slv_prdata_o),
        .pready_s                (u_expander_acg_pready_e_to_u_apb_slv_pready_o),
        .pslverr_s               (u_expander_acg_pslverr_e_to_u_apb_slv_pslverr_o),
        .pwakeup_s               (u_expander_acg_pwakeup_e_to_u_apb_slv_pwakeup_i),
        .pprot_s                 (u_expander_acg_pprot_e_to_u_apb_slv_pprot_i),
        
        .clk_s_qreq_n           (dbgclk_qreqn   [6]),
        .clk_s_qaccept_n        (dbgclk_qacceptn[6]),
        .clk_s_qdeny            (dbgclk_qdeny   [6]),
        .clk_s_qactive          (dbgclk_qactive [6]),
        .pwr_qreq_n             (pwrdbg_apb_pwrqreqn_i),
        .pwr_qaccept_n          (pwrdbg_apb_pwrqacceptn_o),
        .pwr_qdeny              (pwrdbg_apb_pwrqdeny_o),
        .pwr_qactive            (pwrdbg_apb_pwrqactive_o),
       
        .apb_async_req         (apb_async_req_o),
        .apb_async_req_payload (apb_async_req_payload_o),
        .apb_async_resp_payload(apb_async_resp_payload_i),
        .apb_async_ack         (apb_async_ack_i)
    );

       
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_0 (
    .clk     (dbgclk),
    .nreset  (dbgclk_reset_n),
    .d_async (dbgen_dpauth),
    .q       (dbgen_dpauth_ss)
  );
  arm_element_std_xor2 u_dbgen_dpauth (  .A (dbgen_dpauth),  .B (dbgen_dpauth_ss), .Y (dbgclk_qactive_only[5]) );  


  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_1 (
    .clk     (dbgclk),
    .nreset  (dbgclk_reset_n),
    .d_async (niden_dpauth),
    .q       (niden_dpauth_ss)
  );
  arm_element_std_xor2 u_niden_dpauth (  .A (niden_dpauth),  .B (niden_dpauth_ss), .Y (dbgclk_qactive_only[6]) );  

    arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_2 (
    .clk     (dbgclk),
    .nreset  (dbgclk_reset_n),
    .d_async (spiden_dpauth),
    .q       (spiden_dpauth_ss)
  );
  arm_element_std_xor2 u_spiden_dpauth (  .A (spiden_dpauth),  .B (spiden_dpauth_ss), .Y (dbgclk_qactive_only[7]) ); 

  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_3 (
    .clk     (dbgclk),
    .nreset  (dbgclk_reset_n),
    .d_async (spniden_dpauth),
    .q       (spniden_dpauth_ss)
  );
  arm_element_std_xor2 u_spniden_dpauth (  .A (spniden_dpauth),  .B (spniden_dpauth_ss), .Y (dbgclk_qactive_only[8]) );

  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_4 (
    .clk     (dbgclk),
    .nreset  (dbgclk_reset_n),
    .d_async (dbgen_comauth),
    .q       (dbgen_comauth_ss)
  );
  arm_element_std_xor2 u_dbgen_comauth (  .A (dbgen_comauth),  .B (dbgen_comauth_ss), .Y (dbgclk_qactive_only[9]) );   

  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_5 (
    .clk     (dbgclk),
    .nreset  (dbgclk_reset_n),
    .d_async (niden_comauth),
    .q       (niden_comauth_ss)
  );
  arm_element_std_xor2 u_niden_comauth (  .A (niden_comauth),  .B (niden_comauth_ss), .Y (dbgclk_qactive_only[10]) );

  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_6 (
    .clk     (dbgclk),
    .nreset  (dbgclk_reset_n),
    .d_async (acg_dp_dbgen),
    .q       (acg_dp_dbgen_ss)
  );
  arm_element_std_xor2 u_acg_dp_dbgen (  .A (acg_dp_dbgen),  .B (acg_dp_dbgen_ss), .Y (dbgclk_qactive_only[11]) );


  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_7 (
    .clk     (dbgclk),
    .nreset  (dbgclk_reset_n),
    .d_async (acg_hostext_dbgen),
    .q       (acg_hostext_dbgen_ss)
  );
  arm_element_std_xor2 u_acg_hostext_dbgen (  .A (acg_hostext_dbgen),  .B (acg_hostext_dbgen_ss), .Y (dbgclk_qactive_only[12]) );
 
     arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_8 (
    .clk     (dbgclk),
    .nreset  (dbgclk_reset_n),
    .d_async (acg_extsys0_dbgen),
    .q       (acg_extsys0_dbgen_ss)
  );
  arm_element_std_xor2 u_acg_extsys0_dbgen (  .A (acg_extsys0_dbgen),  .B (acg_extsys0_dbgen_ss), .Y (dbgclk_qactive_only[13]) );

    arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync_9 (
    .clk     (dbgclk),
    .nreset  (dbgclk_reset_n),
    .d_async (acg_extsys1_dbgen),
    .q       (acg_extsys1_dbgen_ss)
  );
  arm_element_std_xor2 u_acg_extsys1_dbgen (  .A (acg_extsys1_dbgen),  .B (acg_extsys1_dbgen_ss), .Y (dbgclk_qactive_only[14]) );


  assign unused = (|u_apbhostext_mst_paddr_o_to_u_hostext_arbiter_paddr_s[31:25]);
                  
endmodule
