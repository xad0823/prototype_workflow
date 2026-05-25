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

module ppu_aon  
#(
    parameter DEV_PREQ_DLY_DBG         = 0,
    parameter PCSM_PREQ_DLY_DBG        = 0,
    parameter ISO_CLKEN_DLY_CFG_DBG    = 0,
    parameter CLKEN_RST_DLY_CFG_DBG    = 0,
    parameter RST_HWSTAT_DLY_CFG_DBG   = 0,
    parameter CLKEN_ISO_DLY_CFG_DBG    = 0,
    parameter ISO_RST_DLY_CFG_DBG      = 0,
    parameter DEV_PREQ_DLY_SYS         = 0,
    parameter PCSM_PREQ_DLY_SYS        = 0,
    parameter ISO_CLKEN_DLY_CFG_SYS    = 0,
    parameter CLKEN_RST_DLY_CFG_SYS    = 0,
    parameter RST_HWSTAT_DLY_CFG_SYS   = 0,
    parameter CLKEN_ISO_DLY_CFG_SYS    = 0,
    parameter ISO_RST_DLY_CFG_SYS      = 0,
    parameter DEV_PREQ_DLY_FWRAM       = 0,
    parameter PCSM_PREQ_DLY_FWRAM      = 0,
    parameter ISO_CLKEN_DLY_CFG_FWRAM  = 0,
    parameter CLKEN_RST_DLY_CFG_FWRAM  = 0,
    parameter RST_HWSTAT_DLY_CFG_FWRAM = 0,
    parameter CLKEN_ISO_DLY_CFG_FWRAM  = 0,
    parameter ISO_RST_DLY_CFG_FWRAM    = 0,

    parameter ES_CNT                   = 2,
    parameter SYS_EGRESS_2_DBG         = 2,
    parameter SYS_INGRESS_2_DBG        = 2,
    parameter DBG_INTERNAL_CNT         = 1,
    parameter DBG_EGRESS_CNT           = 1
)
(
  input wire                refclk_gated,
  input wire                refclk_resetn,

  input  wire  [2:0]        qreqn_refclk,
  output  wire [2:0]        qacceptn_refclk,
  output  wire [2:0]        qdeny_refclk,
  output  wire [2:0]        qactive_refclk,
  output  wire [16:0]       qactive_only_refclk,

  input wire                pwakeup,
  input wire                psel_systop_ppu,   
  output wire               pready_systop_ppu, 
  output wire [31:0]        prdata_systop_ppu, 
  output wire               pslverr_systop_ppu,
  
  input wire                penable_systop_ppu,
  input wire [31:0]         paddr_systop_ppu,
  input wire                pwrite_systop_ppu,
  input wire [31:0]         pwdata_systop_ppu,
  
    
  input wire                psel_dbgtop_ppu,   
  output wire               pready_dbgtop_ppu, 
  output wire [31:0]        prdata_dbgtop_ppu, 
  output wire               pslverr_dbgtop_ppu,
  input wire                penable_dbgtop_ppu,
  input wire [31:0]         paddr_dbgtop_ppu,
  input wire                pwrite_dbgtop_ppu,
  input wire [31:0]         pwdata_dbgtop_ppu,
  
  
  input wire                psel_fwram_ppu,   
  output wire               pready_fwram_ppu, 
  output wire [31:0]        prdata_fwram_ppu, 
  output wire               pslverr_fwram_ppu,
  
  input wire                penable_fwram_ppu,
  input wire [31:0]         paddr_fwram_ppu,
  input wire                pwrite_fwram_ppu,
  input wire [31:0]         pwdata_fwram_ppu,
  
  
  
  output wire  [1:0]        systop_wakeup_qreqn,
  input  wire  [1:0]        systop_wakeup_qacceptn,
  input  wire  [1:0]        systop_wakeup_qdeny,
  input  wire  [1:0]        systop_wakeup_qactive,
  
  
  output wire               qreqn_dbgtop_dpromreqack,
  input  wire               qacceptn_dbgtop_dpromreqack,
  input  wire               qdeny_dbgtop_dpromreqack,
  input  wire               qactive_dbgtop_dpromreqack,
  
  
  output wire               qreqn_secenc_dbgtopq,
  input  wire               qacceptn_secenc_dbgtopq,
  input  wire               qdeny_secenc_dbgtopq,
  input  wire               qactive_secenc_dbgtopq,
  
  

  output wire               qreqn_dbgtop_ingress_aon,
  input  wire               qacceptn_dbgtop_ingress_aon,
  input  wire               qdeny_dbgtop_ingress_aon,
  input  wire               qactive_dbgtop_ingress_aon,
  
  output wire               qreqn_secenc_systopq,
  input  wire               qacceptn_secenc_systopq,
  input  wire               qdeny_secenc_systopq,
  input  wire               qactive_secenc_systopq,
  
  
  
  
  
  output wire [ES_CNT-1:0]  qreqn_extsys_systopq,
  input  wire [ES_CNT-1:0]  qacceptn_extsys_systopq,
  input  wire [ES_CNT-1:0]  qdeny_extsys_systopq,
  input  wire [ES_CNT-1:0]  qactive_extsys_systopq,
    
            
  
  output wire [ES_CNT-1:0]  qreqn_extsys_dbgtopq,
  input  wire [ES_CNT-1:0]  qacceptn_extsys_dbgtopq,
  input  wire [ES_CNT-1:0]  qdeny_extsys_dbgtopq,
  input  wire [ES_CNT-1:0]  qactive_extsys_dbgtopq,
  
  
  output wire [SYS_EGRESS_2_DBG-1:0]  qreqn_systop_egress_dbgtop,
  input  wire [SYS_EGRESS_2_DBG-1:0]  qacceptn_systop_egress_dbgtop,
  input  wire [SYS_EGRESS_2_DBG-1:0]  qdeny_systop_egress_dbgtop,
  input  wire [SYS_EGRESS_2_DBG-1:0]  qactive_systop_egress_dbgtop,
  
  output wire [SYS_INGRESS_2_DBG-1:0]  qreqn_systop_ingress_dbgtop,
  input  wire [SYS_INGRESS_2_DBG-1:0]  qacceptn_systop_ingress_dbgtop,
  input  wire [SYS_INGRESS_2_DBG-1:0]  qdeny_systop_ingress_dbgtop,
  input  wire [SYS_INGRESS_2_DBG-1:0]  qactive_systop_ingress_dbgtop,
  
         
  output wire [2:0]         qreqn_systop,
  input  wire [2:0]         qacceptn_systop,
  input  wire [2:0]         qdeny_systop,
  input  wire [2:0]         qactive_systop,
  
  
  output wire [2:0]         qreqn_systop_exp,
  input  wire [2:0]         qacceptn_systop_exp,
  input  wire [2:0]         qdeny_systop_exp,
  input  wire [2:0]         qactive_systop_exp,
  
  
  output wire               qreqn_systop_acg,
  input  wire               qacceptn_systop_acg,
  input  wire               qdeny_systop_acg,
  input  wire               qactive_systop_acg,
  
  output wire [2:0]         qreqn_dbgtop_exp,
  input  wire [2:0]         qacceptn_dbgtop_exp,
  input  wire [2:0]         qdeny_dbgtop_exp,
  input  wire [2:0]         qactive_dbgtop_exp,

  output wire               qreqn_clustop_egress_dbgtop,
  input  wire               qacceptn_clustop_egress_dbgtop,
  input  wire               qdeny_clustop_egress_dbgtop,  
  input  wire               qactive_clustop_egress_dbgtop,

  output wire               qreqn_clustop_ingress_dbgtop,
  input  wire               qacceptn_clustop_ingress_dbgtop,
  input  wire               qdeny_clustop_ingress_dbgtop,  
  input  wire               qactive_clustop_ingress_dbgtop,
  
  output wire  [DBG_INTERNAL_CNT-1:0]  qreqn_dbgtop_internal,
  input  wire  [DBG_INTERNAL_CNT-1:0]  qacceptn_dbgtop_internal,
  input  wire  [DBG_INTERNAL_CNT-1:0]  qdeny_dbgtop_internal,
  input  wire  [DBG_INTERNAL_CNT-1:0]  qactive_dbgtop_internal,
  
  output wire  [DBG_EGRESS_CNT-1:0]  qreqn_dbgtop_egress,
  input  wire  [DBG_EGRESS_CNT-1:0]  qacceptn_dbgtop_egress,
  input  wire  [DBG_EGRESS_CNT-1:0]  qdeny_dbgtop_egress,
  input  wire  [DBG_EGRESS_CNT-1:0]  qactive_dbgtop_egress,
  
  output wire               fctrlcfg_dbgtop_pwrqreqn,
  input  wire               fctrlcfg_dbgtop_pwrqacceptn,
  input  wire               fctrlcfg_dbgtop_pwrqdeny,
  input  wire               fctrlcfg_dbgtop_pwrqactive,     
  
  output wire               fctrlcfg_systop_pwrqreqn,
  input  wire               fctrlcfg_systop_pwrqacceptn,
  input  wire               fctrlcfg_systop_pwrqdeny,     
  input  wire               fctrlcfg_systop_pwrqactive,     
  
  output wire               clustop_dependency_qreqn,
  input  wire               clustop_dependency_qacceptn,
  input  wire               clustop_dependency_qdeny,     
  input  wire               clustop_dependency_qactive,     
  
  input  wire [10:0]        pactive_fwctrl,
  output wire [3:0]         pstate_fwctrl,
  output wire               preq_fwctrl,
  input  wire               paccept_fwctrl,
  input  wire               pdeny_fwctrl,
  
  input  wire [10:0]       pactive_systop_force,

  output wire              systop_devwarmresetn,
  output wire [15:0]       systop_ppuhwstat,
  
  output wire              fwram_devwarmresetn,
  output wire [15:0]       fwram_ppuhwstat,
  
  input  wire [10:0]       pactive_dbgtop_force,
  output wire [15:0]       dbgtop_ppuhwstat,
  output wire              dbgtop_devwarmresetn,
  
  output wire              systop_devclken,
  output wire              dbgtop_devclken,
  output wire              fwram_devclken,
  
  
  output wire              systop_int,  
  output wire              dbgtop_int,  
  output wire              fw_int,
  
  
  input wire               dftcgen,
  input wire               dftpwrup,
  input wire               dftisodisable,  
  input wire               dftrstdisable,
  input wire               dftretdisable
  
  
 );

    
    
    
    wire [10:0] pactive_systop_ppu;

    
    wire        preq_systop_p_sequencer_ctrl;
    wire [3:0]  pstate_systop_p_sequencer_ctrl;
    wire        paccept_systop_p_sequencer_ctrl;
    wire        pdeny_systop_p_sequencer_ctrl;
    wire [10:0] pactive_systop_p_sequencer_ctrl;

    
    
    wire        preq_dbgtop_p_sequencer_ctrl;
    wire [3:0]  pstate_dbgtop_p_sequencer_ctrl;
    wire        paccept_dbgtop_p_sequencer_ctrl;
    wire        pdeny_dbgtop_p_sequencer_ctrl;
    wire [10:0] pactive_dbgtop_p_sequencer_ctrl;

    
    wire        preq_systop_egress_p2q_ctrl;
    wire [3:0]  pstate_systop_egress_p2q_ctrl;
    wire        paccept_systop_egress_p2q_ctrl;
    wire        pdeny_systop_egress_p2q_ctrl;
    wire [10:0] pactive_systop_egress_p2q_ctrl;


    wire        preq_systop_internal_acg_p2q_ctrl;
    wire [3:0]  pstate_systop_internal_acg_p2q_ctrl;
    wire        paccept_systop_internal_acg_p2q_ctrl;
    wire        pdeny_systop_internal_acg_p2q_ctrl;
    wire [10:0] pactive_systop_internal_acg_p2q_ctrl;

    wire        preq_systop_clkctrl_p2q_ctrl;
    wire [3:0]  pstate_systop_clkctrl_p2q_ctrl;
    wire        paccept_systop_clkctrl_p2q_ctrl;
    wire        pdeny_systop_clkctrl_p2q_ctrl;
    wire [10:0] pactive_systop_clkctrl_p2q_ctrl;

    wire        preq_systop_internal_p2q_ctrl;
    wire [3:0]  pstate_systop_internal_p2q_ctrl;
    wire        paccept_systop_internal_p2q_ctrl;
    wire        pdeny_systop_internal_p2q_ctrl;
    wire [10:0] pactive_systop_internal_p2q_ctrl;

    wire        preq_systop_ingress_p2q_ctrl;
    wire [3:0]  pstate_systop_ingress_p2q_ctrl;
    wire        paccept_systop_ingress_p2q_ctrl;
    wire        pdeny_systop_ingress_p2q_ctrl;
    wire [10:0] pactive_systop_ingress_p2q_ctrl;
    
    wire        qreqn_systop_ingress_expander_ctrl;
    wire        qacceptn_systop_ingress_expander_ctrl;
    wire        qdeny_systop_ingress_expander_ctrl;
    wire        qactive_systop_ingress_expander_ctrl;
   
    wire        qreqn_systop_egress_expander_ctrl;
    wire        qacceptn_systop_egress_expander_ctrl;
    wire        qdeny_systop_egress_expander_ctrl;
    wire        qactive_systop_egress_expander_ctrl;
      
      
    wire        qreqn_systop_internal_expander_ctrl;
    wire        qacceptn_systop_internal_expander_ctrl;
    wire        qdeny_systop_internal_expander_ctrl;
    wire        qactive_systop_internal_expander_ctrl;
      
      
    wire        preq_dbgtop_p2q_ctrl;
    wire [3:0]  pstate_dbgtop_p2q_ctrl;
    wire        paccept_dbgtop_p2q_ctrl;
    wire        pdeny_dbgtop_p2q_ctrl;
    wire [10:0] pactive_dbgtop_p2q_ctrl;
    wire [10:0] pactive_dbgtop_ppu;
    
    wire        preq_dbgtop_dpromreqack;
    wire [3:0]  pstate_dbgtop_dpromreqack;
    wire        paccept_dbgtop_dpromreqack;
    wire        pdeny_dbgtop_dpromreqack;
    wire [10:0] pactive_dbgtop_dpromreqack;    
    
    
    wire        preq_systop_pcsm;             
    wire [3:0]  pstate_systop_pcsm;
    wire        paccept_systop_pcsm;
    wire [3:0]  mode_stat_systop_pcsm;
        
    wire        preq_dbgtop_pcsm;             
    wire [3:0]  pstate_dbgtop_pcsm;
    wire        paccept_dbgtop_pcsm;

    
    wire        preq_fwram_pcsm;             
    wire [3:0]  pstate_fwram_pcsm;
    wire        paccept_fwram_pcsm;
    
    wire        systop_ppuclk_qreqn;
    wire        systop_ppuclk_qacceptn;
    wire        systop_ppuclk_qdeny;
    wire        systop_ppuclk_qactive;
    
    
    wire        fwram_ppuclk_qreqn;
    wire        fwram_ppuclk_qacceptn;
    wire        fwram_ppuclk_qdeny;
    wire        fwram_ppuclk_qactive;
    
    wire        preq_systop_egress;
    wire [3:0]  pstate_systop_egress;
    wire        paccept_systop_egress;
    wire        pdeny_systop_egress;
    wire [10:0] pactive_systop_egress;

        
    wire        preq_systop_int_acg;
    wire [3:0]  pstate_systop_int_acg;
    wire        paccept_systop_int_acg;
    wire        pdeny_systop_int_acg;
    wire [10:0] pactive_systop_int_acg;
    
    wire        preq_systop_internal;
    wire [3:0]  pstate_systop_internal;
    wire        paccept_systop_internal;
    wire        pdeny_systop_internal;
    wire [10:0] pactive_systop_internal;
    
    wire        preq_systop_ingress;
    wire [3:0]  pstate_systop_ingress;
    wire        paccept_systop_ingress;
    wire        pdeny_systop_ingress;
    wire [10:0] pactive_systop_ingress;


        
   wire qreqn_systop_egress_dbgtop_comb0;
   wire qacceptn_systop_egress_dbgtop_comb0;
   wire qdeny_systop_egress_dbgtop_comb0;
   wire qactive_systop_egress_dbgtop_comb0;
   
    wire qreqn_systop_egress_dbgtop_comb1;
    wire qacceptn_systop_egress_dbgtop_comb1;
    wire qdeny_systop_egress_dbgtop_comb1;
    wire qactive_systop_egress_dbgtop_comb1;
  
    wire qreqn_systop_ingress_dbgtop_comb1;
    wire qacceptn_systop_ingress_dbgtop_comb1;
    wire qdeny_systop_ingress_dbgtop_comb1;
    wire qactive_systop_ingress_dbgtop_comb1;
  
    wire qreqn_systop_ingress_dbgtop_comb0;
    wire qacceptn_systop_ingress_dbgtop_comb0;
    wire qdeny_systop_ingress_dbgtop_comb0;
    wire qactive_systop_ingress_dbgtop_comb0;
    
    
    wire qactive_extsys_dbgtopq_comb;
    
    
    
    
    wire        qreqn_se_axi;
    wire        qacceptn_se_axi;
    wire        qdeny_se_axi;
    wire        qactive_se_axi;
    
    wire        qreqn_se_axi_comb1;
    wire        qacceptn_se_axi_comb1;
    wire        qdeny_se_axi_comb1;
    wire        qactive_se_axi_comb1;
    
    
    
    wire        qactive_dbgtop_ppu;
    
    wire        qreqn_dbgtop_q_sequencer_ctrl;
    wire        qacceptn_dbgtop_q_sequencer_ctrl;
    wire        qdeny_dbgtop_q_sequencer_ctrl;
    wire        qactive_dbgtop_q_sequencer_ctrl;
    
    
    wire        qreqn_dbgtop_egress_expander_ctrl;
    wire        qacceptn_dbgtop_egress_expander_ctrl;
    wire        qdeny_dbgtop_egress_expander_ctrl;
    wire        qactive_dbgtop_egress_expander_ctrl;
    
    
    wire        qreqn_dbgtop_internal_expander_ctrl;
    wire        qacceptn_dbgtop_internal_expander_ctrl;
    wire        qdeny_dbgtop_internal_expander_ctrl;
    wire        qactive_dbgtop_internal_expander_ctrl;
    
    wire        qreqn_dbgtop_ingress_expander_ctrl;
    wire        qacceptn_dbgtop_ingress_expander_ctrl;
    wire        qdeny_dbgtop_ingress_expander_ctrl;
    wire        qactive_dbgtop_ingress_expander_ctrl;
    
    wire        qactive_dbgtop_p2q;
    wire        qactive_systop_p_sequencer;
    wire        qactive_dbgtop_p_sequencer;
    wire        qactive_systop_egress_p2q;
    wire        qactive_p2q_int_acg;
    wire        qactive_p2q_internal;
    wire        qactive_p2q_ingress;
    wire        qactive_systop_internal_expander;
    wire        qactive_systop_egress_expander;
    wire        qactive_lpd_system_ingress;
    wire        qactive_q_extsys_egress_systop_comb;
    wire        qactive_lpc_q_dbg_aphost;
    wire        qactive_lpc_q_dbg_axi;
    wire        qactive_lpc_q_se_axi;
    wire        qactive_lpc_q_systop_atb;
    wire        qactive_dbgtop_p2q_reqack;
    wire        pwakeup_dbgtop_ppu;
    wire        pwakeup_fwram_ppu;
    
    wire        qactive_systop_ingress_expander;
    wire        qactive_systop_internal_acg_p2q;
    wire        qactive_systop_ingress_p2q;
    wire        qactive_systop_internal_p2q;
    wire        qactive_systop_ingress_dbgtop_comb;
    wire        qactive_systop_egress_dbgtop_comb;   
    wire        qactive_dbgtop_q_sequencer_clk;
    wire        dbgtop_ppuclk_qreqn;
    wire        dbgtop_ppuclk_qacceptn;
    wire        dbgtop_ppuclk_qdeny;
    wire        dbgtop_ppuclk_qactive;
    wire        qactive_dbgtop_egress_expander;
    wire        qactive_dbgtop_internal_expander;
    wire        qactive_lpd_q_dbgtop_ingress;
    
    wire        pwakeup_systop_ppu;
    
    wire        mhu_recwakeups_systop_qactive_ored;
    wire [5:0]  mhu_recwakeups;
  
    
    
                                    
    assign      pwakeup_systop_ppu = pwakeup;
    assign      pwakeup_dbgtop_ppu = pwakeup;
    assign      pwakeup_fwram_ppu  = pwakeup;
    
    pck600_ppu_sse710_sys 
    #(
        .DEV_PREQ_DLY       (DEV_PREQ_DLY_SYS      ),
        .PCSM_PREQ_DLY      (PCSM_PREQ_DLY_SYS     ),
        .ISO_CLKEN_DLY_CFG  (ISO_CLKEN_DLY_CFG_SYS ),
        .CLKEN_RST_DLY_CFG  (CLKEN_RST_DLY_CFG_SYS ),
        .RST_HWSTAT_DLY_CFG (RST_HWSTAT_DLY_CFG_SYS),
        .CLKEN_ISO_DLY_CFG  (CLKEN_ISO_DLY_CFG_SYS ),
        .ISO_RST_DLY_CFG    (ISO_RST_DLY_CFG_SYS   )                    
    ) u_systop_ppu 
    (
       
    .clk             (refclk_gated),
    .reset_n         (refclk_resetn),
       
    .dftcgen         (dftcgen      ),
    .dftisodisable   (dftisodisable),
    .dftrstdisable   (dftrstdisable),
    
    
    .psel_i          (psel_systop_ppu),
    .penable_i       (penable_systop_ppu),
    .paddr_i         (paddr_systop_ppu),
    .pwrite_i        (pwrite_systop_ppu),
    .pwdata_i        (pwdata_systop_ppu),
    .prdata_o        (prdata_systop_ppu),
    .pready_o        (pready_systop_ppu),
    .pslverr_o       (pslverr_systop_ppu),
    .pwakeup_i       (pwakeup_systop_ppu),
        
    .irq_o           (systop_int),
    
    .dev_preq_o      (preq_systop_p_sequencer_ctrl),
    .dev_pstate_o    (pstate_systop_p_sequencer_ctrl),
    .dev_paccept_i   (paccept_systop_p_sequencer_ctrl),
    .dev_pdeny_i     (pdeny_systop_p_sequencer_ctrl),
    .dev_pactive_i   (pactive_systop_ppu),
    
    
    .ppuhwstat_o       (systop_ppuhwstat),   
    .devclken_o        (systop_devclken),
    .devemuclken_o     (),
    .devisolaten_o     (),
    .devemuisolaten_o  (),
    .devwarmresetn_o   (systop_devwarmresetn),
    .devretresetn_o    (),
    .devporesetn_o     (),
    
    
    .pcsm_preq_o     (preq_systop_pcsm),
    .pcsm_pstate_o   (pstate_systop_pcsm),
    .pcsm_paccept_i  (paccept_systop_pcsm),
    .pcsm_mode_stat_i (mode_stat_systop_pcsm),
        
    
    .ppuclk_qreqn_i     (systop_ppuclk_qreqn),
    .ppuclk_qacceptn_o  (systop_ppuclk_qacceptn),
    .ppuclk_qdeny_o     (systop_ppuclk_qdeny),
    .ppuclk_qactive_o   (systop_ppuclk_qactive),
    
    
    .ecorevnum_i    (4'd0)
    
);
  genvar i;
  for(i=0;i<11;i=i+1)
  begin : pactive_or_gate
    arm_element_std_or2 u_or(.A(pactive_systop_p_sequencer_ctrl[i]),
                             .B(pactive_systop_force[i]),
                             .Y(pactive_systop_ppu[i])
    );
  end
  
  pck600_lpd_p_sse710_systop u_systop_p_sequencer (
  
  
  .clk             (refclk_gated),
  .reset_n         (refclk_resetn),
       
  .ctrl_preq_i     (preq_systop_p_sequencer_ctrl),  
  .ctrl_pstate_i   (pstate_systop_p_sequencer_ctrl),
  .ctrl_pactive_o  (pactive_systop_p_sequencer_ctrl),
  .ctrl_paccept_o  (paccept_systop_p_sequencer_ctrl),
  .ctrl_pdeny_o    (pdeny_systop_p_sequencer_ctrl),

  
  .dev0_preq_o    (preq_systop_egress_p2q_ctrl),
  .dev0_pstate_o  (pstate_systop_egress_p2q_ctrl),
  .dev0_pactive_i (pactive_systop_egress_p2q_ctrl),
  .dev0_paccept_i (paccept_systop_egress_p2q_ctrl),
  .dev0_pdeny_i   (pdeny_systop_egress_p2q_ctrl),

  
  .dev1_preq_o    (preq_systop_internal_acg_p2q_ctrl),
  .dev1_pstate_o  (pstate_systop_internal_acg_p2q_ctrl),
  .dev1_pactive_i (pactive_systop_internal_acg_p2q_ctrl),
  .dev1_paccept_i (paccept_systop_internal_acg_p2q_ctrl),
  .dev1_pdeny_i   (pdeny_systop_internal_acg_p2q_ctrl),

  
  .dev2_preq_o    (preq_systop_internal_p2q_ctrl),
  .dev2_pstate_o  (pstate_systop_internal_p2q_ctrl),
  .dev2_pactive_i (pactive_systop_internal_p2q_ctrl),
  .dev2_paccept_i (paccept_systop_internal_p2q_ctrl),
  .dev2_pdeny_i   (pdeny_systop_internal_p2q_ctrl),

  
  .dev3_preq_o    (preq_systop_ingress_p2q_ctrl),
  .dev3_pstate_o  (pstate_systop_ingress_p2q_ctrl),
  .dev3_pactive_i (pactive_systop_ingress_p2q_ctrl),
  .dev3_paccept_i (paccept_systop_ingress_p2q_ctrl),
  .dev3_pdeny_i   (pdeny_systop_ingress_p2q_ctrl),

  
  .clk_qactive_o (qactive_systop_p_sequencer),

  .dftcgen       (dftcgen)
);
  
  wire [31:0] unused1;
  wire [31:0] unused2;
  wire [31:0] unused3;
  wire [31:0] unused4;
  wire [31:0] unused5;
  wire [31:0] unused6;
  
  
  pck600_p2q #(
                      .CTRL_P_CH_OP_PSTATE_MAP  (16'b1111111111111111),
                      .CTRL_P_CH_SYNC (0),
                      .DEV_Q_CH_SYNC  (0)

  ) u_systop_egress_p2q                    
    (
    .clk              (refclk_gated),
    .reset_n          (refclk_resetn),
  
  
    .ctrl_preq_i    (preq_systop_egress_p2q_ctrl),
    .ctrl_pstate_i  ({4'b0000,pstate_systop_egress_p2q_ctrl}),
    .ctrl_pactive_o ({unused1[31:11],pactive_systop_egress_p2q_ctrl}),
    .ctrl_paccept_o (paccept_systop_egress_p2q_ctrl),
    .ctrl_pdeny_o   (pdeny_systop_egress_p2q_ctrl),

    .dev_qreqn_o      (qreqn_systop_egress_expander_ctrl),  
    .dev_qacceptn_i   (qacceptn_systop_egress_expander_ctrl),
    .dev_qdeny_i      (qdeny_systop_egress_expander_ctrl),
    .dev_qactive_i    (qactive_systop_egress_expander_ctrl),
    
    .clk_qactive_o    (qactive_systop_egress_p2q),
  
    .dftcgen          (dftcgen)
  );
  
  
  pck600_p2q #(
                      .CTRL_P_CH_OP_PSTATE_MAP  (16'b1111111111111111),  
                      .CTRL_P_CH_SYNC (0),
                      .DEV_Q_CH_SYNC  (1)
  ) u_systop_internal_acg_p2q                    
    (
    .clk              (refclk_gated),
    .reset_n          (refclk_resetn),
  
  
    .ctrl_preq_i    (preq_systop_internal_acg_p2q_ctrl),
    .ctrl_pstate_i  ({4'b0000,pstate_systop_internal_acg_p2q_ctrl}),
    .ctrl_pactive_o ({unused2[31:11],pactive_systop_internal_acg_p2q_ctrl}),
    .ctrl_paccept_o (paccept_systop_internal_acg_p2q_ctrl),
    .ctrl_pdeny_o   (pdeny_systop_internal_acg_p2q_ctrl),

    .dev_qreqn_o      (qreqn_systop_acg),  
    .dev_qacceptn_i   (qacceptn_systop_acg),
    .dev_qdeny_i      (qdeny_systop_acg),
    .dev_qactive_i    (qactive_systop_acg),
  
    .clk_qactive_o    (qactive_systop_internal_acg_p2q),
  
    .dftcgen          (dftcgen)
  );
      
  
  pck600_p2q #(
                      .CTRL_P_CH_OP_PSTATE_MAP  (16'b1111111111111111),
                      .CTRL_P_CH_SYNC (0),
                      .DEV_Q_CH_SYNC  (1)

  ) u_systop_internal_p2q                    
    (
    .clk              (refclk_gated),
    .reset_n          (refclk_resetn),
  
  
    .ctrl_preq_i    (preq_systop_internal_p2q_ctrl),
    .ctrl_pstate_i  ({4'b0000,pstate_systop_internal_p2q_ctrl}),
    .ctrl_pactive_o ({unused3[31:11],pactive_systop_internal_p2q_ctrl}),
    .ctrl_paccept_o (paccept_systop_internal_p2q_ctrl),
    .ctrl_pdeny_o   (pdeny_systop_internal_p2q_ctrl),

    .dev_qreqn_o      (qreqn_systop_internal_expander_ctrl),  
    .dev_qacceptn_i   (qacceptn_systop_internal_expander_ctrl),
    .dev_qdeny_i      (qdeny_systop_internal_expander_ctrl),
    .dev_qactive_i    (qactive_systop_internal_expander_ctrl),
  
    .clk_qactive_o    (qactive_systop_internal_p2q),
  
    .dftcgen          (dftcgen)
  );
      
  
  
  
  
  
  pck600_p2q #(
                      .CTRL_P_CH_OP_PSTATE_MAP  (16'b1111111111111111),
                      .CTRL_P_CH_SYNC (0),
                      .DEV_Q_CH_SYNC  (0)

  ) u_systop_ingress_p2q                    
    (
    .clk              (refclk_gated),
    .reset_n          (refclk_resetn),
  
  
    .ctrl_preq_i    (preq_systop_ingress_p2q_ctrl),
    .ctrl_pstate_i  ({4'b0000,pstate_systop_ingress_p2q_ctrl}),
    .ctrl_pactive_o ({unused4[31:11],pactive_systop_ingress_p2q_ctrl}),
    .ctrl_paccept_o (paccept_systop_ingress_p2q_ctrl),
    .ctrl_pdeny_o   (pdeny_systop_ingress_p2q_ctrl),

    .dev_qreqn_o      (qreqn_systop_ingress_expander_ctrl),  
    .dev_qacceptn_i   (qacceptn_systop_ingress_expander_ctrl),
    .dev_qdeny_i      (qdeny_systop_ingress_expander_ctrl),
    .dev_qactive_i    (qactive_systop_ingress_expander_ctrl),
  
    .clk_qactive_o    (qactive_systop_ingress_p2q),
  
    .dftcgen          (dftcgen)
  );
  
  
  pck600_lpd_q #(
                      .NUM_QCHL(5),
                      .CTRL_Q_CH_SYNC(0),
                      .ACTIVE_DENY(0),
                      .DEV_Q_CH_SYNC(1),
                      .SEQUENCER(1))
  u_systop_egress_expander                 
  (
    .clk            (refclk_gated),
    .reset_n        (refclk_resetn),
    
    
    .ctrl_qreqn_i      (qreqn_systop_egress_expander_ctrl),  
    .ctrl_qacceptn_o   (qacceptn_systop_egress_expander_ctrl),
    .ctrl_qdeny_o      (qdeny_systop_egress_expander_ctrl),
    .ctrl_qactive_o    (qactive_systop_egress_expander_ctrl),
                                           
    .dev_qreqn_o      ({qreqn_systop_exp[0]   ,qreqn_systop[0]   ,qreqn_systop_egress_dbgtop_comb0   ,fctrlcfg_systop_pwrqreqn   ,clustop_dependency_qreqn    }),
    .dev_qacceptn_i   ({qacceptn_systop_exp[0],qacceptn_systop[0],qacceptn_systop_egress_dbgtop_comb0,fctrlcfg_systop_pwrqacceptn,clustop_dependency_qacceptn }),
    .dev_qdeny_i      ({qdeny_systop_exp[0]   ,qdeny_systop[0]   ,qdeny_systop_egress_dbgtop_comb0   ,fctrlcfg_systop_pwrqdeny   ,clustop_dependency_qdeny    }),
    .dev_qactive_i    ({qactive_systop_exp[0] ,qactive_systop[0] ,qactive_systop_egress_dbgtop_comb0 ,fctrlcfg_systop_pwrqactive ,clustop_dependency_qactive  }),
  
    .clk_qactive_o    (qactive_systop_egress_expander),
    
    .dftcgen          (dftcgen)
  );
  
  pck600_lpd_q #(
                      .NUM_QCHL(2),
                      .CTRL_Q_CH_SYNC(0),
                      .ACTIVE_DENY(0),
                      .DEV_Q_CH_SYNC(1),
                      .SEQUENCER(0))
  u_systop_internal_expander                 
  (
    .clk            (refclk_gated),
    .reset_n        (refclk_resetn),
    
    
    .ctrl_qreqn_i      (qreqn_systop_internal_expander_ctrl),  
    .ctrl_qacceptn_o   (qacceptn_systop_internal_expander_ctrl),
    .ctrl_qdeny_o      (qdeny_systop_internal_expander_ctrl),
    .ctrl_qactive_o    (qactive_systop_internal_expander_ctrl),
                                           
    .dev_qreqn_o      ({qreqn_systop_exp[1]   ,qreqn_systop[1]   }),
    .dev_qacceptn_i   ({qacceptn_systop_exp[1],qacceptn_systop[1]}),
    .dev_qdeny_i      ({qdeny_systop_exp[1]   ,qdeny_systop[1]   }),
    .dev_qactive_i    ({qactive_systop_exp[1] ,qactive_systop[1] }),
  
    .clk_qactive_o    (qactive_systop_internal_expander),
    
    .dftcgen          (dftcgen)
  );
  
  pck600_lpd_q #(
                      .NUM_QCHL(6+ES_CNT), 
                      .CTRL_Q_CH_SYNC(0),
                      .ACTIVE_DENY(0),
                      .DEV_Q_CH_SYNC(1),
                      .SEQUENCER(0))
  u_systop_ingress_expander                 
  (
    .clk            (refclk_gated),
    .reset_n        (refclk_resetn),
    
    
    .ctrl_qreqn_i      (qreqn_systop_ingress_expander_ctrl),  
    .ctrl_qacceptn_o   (qacceptn_systop_ingress_expander_ctrl),
    .ctrl_qdeny_o      (qdeny_systop_ingress_expander_ctrl),
    .ctrl_qactive_o    (qactive_systop_ingress_expander_ctrl),
                                                                                                                                                         
    .dev_qreqn_o      ({qreqn_systop_exp[2]   ,systop_wakeup_qreqn    , qreqn_systop[2]   ,qreqn_systop_ingress_dbgtop_comb0    , qreqn_extsys_systopq,    qreqn_secenc_systopq      }),
    .dev_qacceptn_i   ({qacceptn_systop_exp[2],systop_wakeup_qacceptn , qacceptn_systop[2],qacceptn_systop_ingress_dbgtop_comb0 , qacceptn_extsys_systopq, qacceptn_secenc_systopq}),
    .dev_qdeny_i      ({qdeny_systop_exp[2]   ,systop_wakeup_qdeny    , qdeny_systop[2]   ,qdeny_systop_ingress_dbgtop_comb0    , qdeny_extsys_systopq,    qdeny_secenc_systopq      }),
    .dev_qactive_i    ({qactive_systop_exp[2] ,systop_wakeup_qactive  , qactive_systop[2] ,qactive_systop_ingress_dbgtop_comb0  , qactive_extsys_systopq,  qactive_secenc_systopq  }),
  
    .clk_qactive_o    (qactive_systop_ingress_expander),
    
    .dftcgen          (dftcgen)
  );
  
  pck600_lpc_q 
  #(
      .NUM_CTRL_Q_CHL (2),
      .NUM_DEV_Q_CHL  (SYS_EGRESS_2_DBG),
      .CTRL_Q_CH_SYNC (1),
      .DEV_Q_CH_SYNC  (1)
  )
  u_systop_egress_dbgtop_comb
  (
    .clk            (refclk_gated),
    .reset_n       (refclk_resetn),
    
    
    .ctrl_qreqn_i     ({qreqn_systop_egress_dbgtop_comb0,     qreqn_systop_egress_dbgtop_comb1    }), 
    .ctrl_qacceptn_o  ({qacceptn_systop_egress_dbgtop_comb0,  qacceptn_systop_egress_dbgtop_comb1 }),
    .ctrl_qdeny_o     ({qdeny_systop_egress_dbgtop_comb0,     qdeny_systop_egress_dbgtop_comb1    }),
    .ctrl_qactive_o   ({qactive_systop_egress_dbgtop_comb0,   qactive_systop_egress_dbgtop_comb1  }),
  
    .dev_qreqn_o      (qreqn_systop_egress_dbgtop   ),
    .dev_qacceptn_i   (qacceptn_systop_egress_dbgtop),
    .dev_qdeny_i      (qdeny_systop_egress_dbgtop   ),
    .dev_qactive_i    (qactive_systop_egress_dbgtop ),
  
    .clk_qactive_o    (qactive_systop_egress_dbgtop_comb),
    
    .dftcgen          (dftcgen)
  );
  
  
  
  pck600_lpc_q #(
                      .NUM_CTRL_Q_CHL (2),
                      .NUM_DEV_Q_CHL  (SYS_INGRESS_2_DBG),
                      .CTRL_Q_CH_SYNC(0),
                      .DEV_Q_CH_SYNC(1))
  u_systop_ingress_dbgtop_comb              
  (
    .clk            (refclk_gated),
    .reset_n       (refclk_resetn),
    
    .ctrl_qreqn_i     ({qreqn_systop_ingress_dbgtop_comb0,     qreqn_systop_ingress_dbgtop_comb1    }), 
    .ctrl_qacceptn_o  ({qacceptn_systop_ingress_dbgtop_comb0,  qacceptn_systop_ingress_dbgtop_comb1 }),
    .ctrl_qdeny_o     ({qdeny_systop_ingress_dbgtop_comb0,     qdeny_systop_ingress_dbgtop_comb1    }),
    .ctrl_qactive_o   ({qactive_systop_ingress_dbgtop_comb0,   qactive_systop_ingress_dbgtop_comb1  }),
    
    .dev_qreqn_o      (qreqn_systop_ingress_dbgtop   ),
    .dev_qacceptn_i   (qacceptn_systop_ingress_dbgtop),
    .dev_qdeny_i      (qdeny_systop_ingress_dbgtop   ),
    .dev_qactive_i    (qactive_systop_ingress_dbgtop ),
  
    .clk_qactive_o    (qactive_systop_ingress_dbgtop_comb),
    
    .dftcgen          (dftcgen)
  );
  
  
  

    pck600_ppu_sse710_dbg 
    #(
        .DEV_PREQ_DLY       (DEV_PREQ_DLY_DBG      ),
        .PCSM_PREQ_DLY      (PCSM_PREQ_DLY_DBG     ),
        .ISO_CLKEN_DLY_CFG  (ISO_CLKEN_DLY_CFG_DBG ),
        .CLKEN_RST_DLY_CFG  (CLKEN_RST_DLY_CFG_DBG ),
        .RST_HWSTAT_DLY_CFG (RST_HWSTAT_DLY_CFG_DBG),
        .CLKEN_ISO_DLY_CFG  (CLKEN_ISO_DLY_CFG_DBG ),
        .ISO_RST_DLY_CFG    (ISO_RST_DLY_CFG_DBG   )
    ) u_dbgtop_ppu 
    (
          
     .clk             (refclk_gated),
     .reset_n         (refclk_resetn),
        
     .dftcgen         (dftcgen      ),
     .dftisodisable   (dftisodisable),
     .dftrstdisable   (dftrstdisable),
     
     
     .psel_i          (psel_dbgtop_ppu),
     .penable_i       (penable_dbgtop_ppu),
     .paddr_i         (paddr_dbgtop_ppu),
     .pwrite_i        (pwrite_dbgtop_ppu),
     .pwdata_i        (pwdata_dbgtop_ppu),
     .prdata_o        (prdata_dbgtop_ppu),
     .pready_o        (pready_dbgtop_ppu),
     .pslverr_o       (pslverr_dbgtop_ppu),
     .pwakeup_i       (pwakeup_dbgtop_ppu),
         
     .irq_o           (dbgtop_int),
     
     .dev_preq_o        (preq_dbgtop_p_sequencer_ctrl),  
     .dev_pstate_o      (pstate_dbgtop_p_sequencer_ctrl),
     .dev_paccept_i     (paccept_dbgtop_p_sequencer_ctrl), 
     .dev_pdeny_i       (pdeny_dbgtop_p_sequencer_ctrl),
     .dev_pactive_i     (pactive_dbgtop_ppu),     

     .ppuhwstat_o       (dbgtop_ppuhwstat),   
     .devclken_o        (dbgtop_devclken),
     .devemuclken_o     (),
     .devisolaten_o     (),
     .devemuisolaten_o  (),
     .devwarmresetn_o   (dbgtop_devwarmresetn),
     .devretresetn_o    (),
     .devporesetn_o     (),
     
     .pcsm_preq_o     (preq_dbgtop_pcsm),
     .pcsm_pstate_o   (pstate_dbgtop_pcsm),
     .pcsm_paccept_i  (paccept_dbgtop_pcsm),
     
     
     .ppuclk_qreqn_i     (dbgtop_ppuclk_qreqn),
     .ppuclk_qacceptn_o  (dbgtop_ppuclk_qacceptn),
     .ppuclk_qdeny_o     (dbgtop_ppuclk_qdeny),
     .ppuclk_qactive_o   (dbgtop_ppuclk_qactive),
     
     
     .ecorevnum_i    (4'd0)
     
    );
    
    genvar j;
    for(j=0;j<11;j=j+1)
    begin : pactive_dbgtop_ppu_or_gate
    arm_element_std_or2 u_or(.A(pactive_dbgtop_force[j]),
                             .B(pactive_dbgtop_p_sequencer_ctrl[j]),
                             .Y(pactive_dbgtop_ppu[j])
    );
    end
    
    wire temp;
    
    
      pck600_p2q #(
                      .CTRL_P_CH_SYNC (0),
                      .DEV_Q_CH_SYNC  (0),
                      .CTRL_P_CH_PWR_PSTATE_MAP (16'b0000001100000000),
                      .CTRL_P_CH_OP_PSTATE_MAP  (16'b1111111111111111),
                      .CTRL_P_CH_PACTIVE        ({16'd0,16'b0000000100000000})
  ) u_dbgtop_p2q_reqack                    
    (
    .clk              (refclk_gated),
    .reset_n          (refclk_resetn),
  
    .ctrl_preq_i    (preq_dbgtop_dpromreqack),
    .ctrl_pstate_i  ({4'b0000,pstate_dbgtop_dpromreqack}),
    .ctrl_pactive_o ({unused6[31:11],pactive_dbgtop_dpromreqack}),
    .ctrl_paccept_o (paccept_dbgtop_dpromreqack),
    .ctrl_pdeny_o   (pdeny_dbgtop_dpromreqack),


    .dev_qreqn_o     (qreqn_dbgtop_dpromreqack),  
    .dev_qacceptn_i  (qacceptn_dbgtop_dpromreqack),
    .dev_qdeny_i     (qdeny_dbgtop_dpromreqack),
    .dev_qactive_i   (qactive_dbgtop_dpromreqack),
              
    .clk_qactive_o    (qactive_dbgtop_p2q_reqack),
  
    .dftcgen          (dftcgen)
  );
  
    
    
    
    pck600_lpd_p_sse710_dbgtop u_pck600_lpd_p_sse710_dbgtop
    (
        .clk             (refclk_gated),
        .reset_n         (refclk_resetn),
            
        .ctrl_preq_i     (preq_dbgtop_p_sequencer_ctrl),  
        .ctrl_pstate_i   (pstate_dbgtop_p_sequencer_ctrl),
        .ctrl_pactive_o  (pactive_dbgtop_p_sequencer_ctrl),
        .ctrl_paccept_o  (paccept_dbgtop_p_sequencer_ctrl),
        .ctrl_pdeny_o    (pdeny_dbgtop_p_sequencer_ctrl),
        
        
        .dev0_preq_o    (preq_dbgtop_p2q_ctrl),
        .dev0_pstate_o  (pstate_dbgtop_p2q_ctrl),
        .dev0_pactive_i (pactive_dbgtop_p2q_ctrl),
        .dev0_paccept_i (paccept_dbgtop_p2q_ctrl),
        .dev0_pdeny_i   (pdeny_dbgtop_p2q_ctrl),
        
        .dev1_preq_o    (preq_dbgtop_dpromreqack),
        .dev1_pstate_o  (pstate_dbgtop_dpromreqack),
        .dev1_pactive_i (pactive_dbgtop_dpromreqack),
        .dev1_paccept_i (paccept_dbgtop_dpromreqack),
        .dev1_pdeny_i   (pdeny_dbgtop_dpromreqack),
        
        
        .clk_qactive_o (qactive_dbgtop_p_sequencer),

        .dftcgen       (dftcgen)

  );
    
    pck600_p2q #(
                      .CTRL_P_CH_SYNC (0),
                      .DEV_Q_CH_SYNC  (0),
                      .CTRL_P_CH_PWR_PSTATE_MAP (16'b0000000100000000),
                      .CTRL_P_CH_OP_PSTATE_MAP  (16'b1111111111111111),
                      .CTRL_P_CH_PACTIVE        ({16'd0,16'b0000000100000000})
  ) u_dbgtop_p2q                    
    (
    .clk              (refclk_gated),
    .reset_n          (refclk_resetn),
  
    .ctrl_preq_i    (preq_dbgtop_p2q_ctrl),
    .ctrl_pstate_i  ({4'b0000,pstate_dbgtop_p2q_ctrl}),
    .ctrl_pactive_o ({unused5[31:11],pactive_dbgtop_p2q_ctrl}),
    .ctrl_paccept_o (paccept_dbgtop_p2q_ctrl),
    .ctrl_pdeny_o   (pdeny_dbgtop_p2q_ctrl),


    .dev_qreqn_o      (qreqn_dbgtop_q_sequencer_ctrl),  
    .dev_qacceptn_i   (qacceptn_dbgtop_q_sequencer_ctrl),
    .dev_qdeny_i     (qdeny_dbgtop_q_sequencer_ctrl),
    .dev_qactive_i   (qactive_dbgtop_q_sequencer_ctrl),
              
    .clk_qactive_o    (qactive_dbgtop_p2q),
  
    .dftcgen          (dftcgen)
  );
        
    
    
    pck600_lpd_q #(
                      .SEQUENCER(1),
                      .NUM_QCHL(3),
                      .CTRL_Q_CH_SYNC(0),
                      .ACTIVE_DENY(0),
                      .DEV_Q_CH_SYNC(0))
    u_dbgtop_q_sequencer               
    (
        .clk               (refclk_gated),
        .reset_n            (refclk_resetn),
        
        
        .ctrl_qreqn_i     (qreqn_dbgtop_q_sequencer_ctrl),  
        .ctrl_qacceptn_o  (qacceptn_dbgtop_q_sequencer_ctrl),
        .ctrl_qdeny_o     (qdeny_dbgtop_q_sequencer_ctrl),
        .ctrl_qactive_o   (qactive_dbgtop_q_sequencer_ctrl),
    
        .dev_qreqn_o      ({ qreqn_dbgtop_ingress_expander_ctrl   , qreqn_dbgtop_internal_expander_ctrl    , qreqn_dbgtop_egress_expander_ctrl    }),
        .dev_qacceptn_i   ({ qacceptn_dbgtop_ingress_expander_ctrl, qacceptn_dbgtop_internal_expander_ctrl , qacceptn_dbgtop_egress_expander_ctrl }),
        .dev_qdeny_i      ({ qdeny_dbgtop_ingress_expander_ctrl   , qdeny_dbgtop_internal_expander_ctrl    , qdeny_dbgtop_egress_expander_ctrl    }),
        .dev_qactive_i    ({ qactive_dbgtop_ingress_expander_ctrl , qactive_dbgtop_internal_expander_ctrl  , qactive_dbgtop_egress_expander_ctrl  }),
    
        .clk_qactive_o    (qactive_dbgtop_q_sequencer_clk),
        
        .dftcgen          (dftcgen)
    );
  
    pck600_lpd_q #(
                      .NUM_QCHL(5+DBG_EGRESS_CNT),
                      .CTRL_Q_CH_SYNC(0),
                      .ACTIVE_DENY(0),
                      .DEV_Q_CH_SYNC(1))
    u_dbgtop_egress_expander
    (
        .clk               (refclk_gated),
        .reset_n          (refclk_resetn),
        
        
        .ctrl_qreqn_i     (qreqn_dbgtop_egress_expander_ctrl),  
        .ctrl_qacceptn_o  (qacceptn_dbgtop_egress_expander_ctrl),
        .ctrl_qdeny_o     (qdeny_dbgtop_egress_expander_ctrl),
        .ctrl_qactive_o   (qactive_dbgtop_egress_expander_ctrl),
    
        .dev_qreqn_o      ({qreqn_secenc_dbgtopq,   qreqn_systop_ingress_dbgtop_comb1   , qreqn_dbgtop_exp[0]     ,qreqn_dbgtop_egress   , fctrlcfg_dbgtop_pwrqreqn    ,  qreqn_clustop_ingress_dbgtop}),
        .dev_qacceptn_i   ({qacceptn_secenc_dbgtopq,qacceptn_systop_ingress_dbgtop_comb1, qacceptn_dbgtop_exp[0],  qacceptn_dbgtop_egress, fctrlcfg_dbgtop_pwrqacceptn ,  qacceptn_clustop_ingress_dbgtop   }),
        .dev_qdeny_i      ({qdeny_secenc_dbgtopq,   qdeny_systop_ingress_dbgtop_comb1   , qdeny_dbgtop_exp[0]     ,qdeny_dbgtop_egress   , fctrlcfg_dbgtop_pwrqdeny    ,  qdeny_clustop_ingress_dbgtop   }),
        .dev_qactive_i    ({qactive_secenc_dbgtopq, qactive_systop_ingress_dbgtop_comb1 , qactive_dbgtop_exp[0] ,  qactive_dbgtop_egress , fctrlcfg_dbgtop_pwrqactive  ,  qactive_clustop_ingress_dbgtop }),
    
        .clk_qactive_o    (qactive_dbgtop_egress_expander),
        
        .dftcgen          (dftcgen)
    );
   
   
    pck600_lpd_q #(
                      .NUM_QCHL(1+DBG_INTERNAL_CNT),
                      .CTRL_Q_CH_SYNC(0),
                      .ACTIVE_DENY(0),
                      .DEV_Q_CH_SYNC(1))
    u_dbgtop_internal_expander
    (
        .clk               (refclk_gated),
        .reset_n          (refclk_resetn),
        
        
        .ctrl_qreqn_i     (qreqn_dbgtop_internal_expander_ctrl),  
        .ctrl_qacceptn_o  (qacceptn_dbgtop_internal_expander_ctrl),
        .ctrl_qdeny_o     (qdeny_dbgtop_internal_expander_ctrl),
        .ctrl_qactive_o   (qactive_dbgtop_internal_expander_ctrl),
    
        .dev_qreqn_o      ({qreqn_dbgtop_exp[1]   ,qreqn_dbgtop_internal   }),
        .dev_qacceptn_i   ({qacceptn_dbgtop_exp[1],qacceptn_dbgtop_internal}),
        .dev_qdeny_i      ({qdeny_dbgtop_exp[1]   ,qdeny_dbgtop_internal   }),
        .dev_qactive_i    ({qactive_dbgtop_exp[1] ,qactive_dbgtop_internal }),
    
        .clk_qactive_o    (qactive_dbgtop_internal_expander),
        
        .dftcgen          (dftcgen)
    );
   
    pck600_lpd_q #(
                      .NUM_QCHL(4+ES_CNT),
                      .CTRL_Q_CH_SYNC(0),
                      .ACTIVE_DENY(0),
                      .DEV_Q_CH_SYNC(1))
    u_dbgtop_ingress_expander
    (
        .clk               (refclk_gated),
        .reset_n          (refclk_resetn),
        
        
        .ctrl_qreqn_i     (qreqn_dbgtop_ingress_expander_ctrl),  
        .ctrl_qacceptn_o  (qacceptn_dbgtop_ingress_expander_ctrl),
        .ctrl_qdeny_o     (qdeny_dbgtop_ingress_expander_ctrl),
        .ctrl_qactive_o   (qactive_dbgtop_ingress_expander_ctrl),
         
        
        .dev_qacceptn_i   ({qacceptn_systop_egress_dbgtop_comb1,  qacceptn_extsys_dbgtopq     ,qacceptn_dbgtop_exp[2],  qacceptn_dbgtop_ingress_aon, qacceptn_clustop_egress_dbgtop  }),
        .dev_qdeny_i      ({qdeny_systop_egress_dbgtop_comb1,     qdeny_extsys_dbgtopq        ,qdeny_dbgtop_exp[2]   ,  qdeny_dbgtop_ingress_aon   , qdeny_clustop_egress_dbgtop     }),
        .dev_qreqn_o      ({qreqn_systop_egress_dbgtop_comb1,     qreqn_extsys_dbgtopq        ,qreqn_dbgtop_exp[2]   ,  qreqn_dbgtop_ingress_aon   , qreqn_clustop_egress_dbgtop     }),
        .dev_qactive_i    ({qactive_systop_egress_dbgtop_comb1,   qactive_extsys_dbgtopq      ,qactive_dbgtop_exp[2] ,  qactive_dbgtop_ingress_aon , qactive_clustop_egress_dbgtop   }),
    
        .clk_qactive_o    (qactive_lpd_q_dbgtop_ingress ),
        
        .dftcgen          (dftcgen)
    );

    pck600_ppu_pcsm_sse710_sys u_systop_pcsm (
        .clk             (refclk_gated),
        .reset_n         (refclk_resetn),
        
        .dftpwrup        (dftpwrup),
        .dftretdisable   (dftretdisable),
        
        .pcsm_preq_i     (preq_systop_pcsm),
        .pcsm_pstate_i   (pstate_systop_pcsm),
        .pcsm_paccept_o  (paccept_systop_pcsm),
        .pcsm_mode_stat_o (mode_stat_systop_pcsm),
        
        .lgcpwrn_o(),
        .lgcretn_o(),
        .rampwrn_o(),
        .ramretn_o()
    );
    
    pck600_ppu_pcsm_sse710_dbg u_dbgtop_pcsm (
        .clk             (refclk_gated),
        .reset_n         (refclk_resetn),
                         
        .dftpwrup        (dftpwrup),
        .dftretdisable   (dftretdisable),
        
        .pcsm_preq_i     (preq_dbgtop_pcsm),
        .pcsm_pstate_i   (pstate_dbgtop_pcsm),
        .pcsm_paccept_o  (paccept_dbgtop_pcsm),

        
        .lgcpwrn_o(),
        .lgcretn_o(),
        .rampwrn_o(),
        .ramretn_o()
    );
    
    
    assign {systop_ppuclk_qreqn, dbgtop_ppuclk_qreqn, fwram_ppuclk_qreqn  } = qreqn_refclk;
    
    assign qacceptn_refclk = { systop_ppuclk_qacceptn,dbgtop_ppuclk_qacceptn,fwram_ppuclk_qacceptn };
    assign qdeny_refclk    = { systop_ppuclk_qdeny,   dbgtop_ppuclk_qdeny   ,fwram_ppuclk_qdeny    };
    assign qactive_refclk  = { systop_ppuclk_qactive, dbgtop_ppuclk_qactive ,fwram_ppuclk_qactive  };

    assign qactive_only_refclk = { 
                                   qactive_dbgtop_p2q,
                                   qactive_systop_egress_p2q,  
                                   qactive_systop_egress_expander,
                                   qactive_systop_internal_expander,                                   
                                   qactive_dbgtop_egress_expander,
                                   qactive_dbgtop_internal_expander,
                                   qactive_lpd_q_dbgtop_ingress, 
                                   qactive_systop_p_sequencer,
                                   qactive_dbgtop_p_sequencer,
                                   qactive_systop_internal_acg_p2q,                                                                      
                                   qactive_systop_egress_dbgtop_comb,
                                   qactive_systop_ingress_expander,
                                   qactive_systop_ingress_p2q,
                                   qactive_systop_internal_p2q,
                                   qactive_dbgtop_q_sequencer_clk,
                                   qactive_systop_ingress_dbgtop_comb,
                                   qactive_dbgtop_p2q_reqack};
 
    
    
    wire unused_fwram;
    assign unused_fwram = |({pactive_fwctrl[10:9],pactive_fwctrl[7:0]});
    
    pck600_ppu_sse710_fwram 
    #(
        .DEV_PREQ_DLY       (DEV_PREQ_DLY_FWRAM      ),
        .PCSM_PREQ_DLY      (PCSM_PREQ_DLY_FWRAM     ),
        .ISO_CLKEN_DLY_CFG  (ISO_CLKEN_DLY_CFG_FWRAM ),
        .CLKEN_RST_DLY_CFG  (CLKEN_RST_DLY_CFG_FWRAM ),
        .RST_HWSTAT_DLY_CFG (RST_HWSTAT_DLY_CFG_FWRAM),
        .CLKEN_ISO_DLY_CFG  (CLKEN_ISO_DLY_CFG_FWRAM ),
        .ISO_RST_DLY_CFG    (ISO_RST_DLY_CFG_FWRAM   )
    ) u_fwram_ppu 
    (
       
    .clk             (refclk_gated),
    .reset_n         (refclk_resetn),
       
    .dftcgen         (dftcgen      ),
    .dftisodisable   (dftisodisable),
    .dftrstdisable   (dftrstdisable),
    
    
    .psel_i          (psel_fwram_ppu),
    .penable_i       (penable_fwram_ppu),
    .paddr_i         (paddr_fwram_ppu),
    .pwrite_i        (pwrite_fwram_ppu),
    .pwdata_i        (pwdata_fwram_ppu),
    .prdata_o        (prdata_fwram_ppu),
    .pready_o        (pready_fwram_ppu),
    .pslverr_o       (pslverr_fwram_ppu),
    .pwakeup_i       (pwakeup_fwram_ppu),
        
    .irq_o           (fw_int),
    
    .dev_preq_o      (preq_fwctrl),   
    .dev_pstate_o    (pstate_fwctrl),   
    .dev_paccept_i   (paccept_fwctrl),   
    .dev_pdeny_i     (pdeny_fwctrl),   
    .dev_pactive_i   ({2'b00,pactive_fwctrl[8],8'b10000001}),   
    
    
    .ppuhwstat_o       (fwram_ppuhwstat),   
    .devclken_o        (fwram_devclken),
    .devemuclken_o     (),
    .devisolaten_o     (),
    .devemuisolaten_o  (),
    .devwarmresetn_o   (fwram_devwarmresetn),
    .devretresetn_o    (),
    .devporesetn_o     (),
    
    
    .pcsm_preq_o     (preq_fwram_pcsm),
    .pcsm_pstate_o   (pstate_fwram_pcsm),
    .pcsm_paccept_i  (paccept_fwram_pcsm),
    
    
    .ppuclk_qreqn_i     (fwram_ppuclk_qreqn),
    .ppuclk_qacceptn_o  (fwram_ppuclk_qacceptn),
    .ppuclk_qdeny_o     (fwram_ppuclk_qdeny),
    .ppuclk_qactive_o   (fwram_ppuclk_qactive),
    
    
    .ecorevnum_i    (4'd0)
    
);
    
    pck600_ppu_pcsm_sse710_fwram u_fwram_pcsm (
        .clk             (refclk_gated),
        .reset_n         (refclk_resetn),
                         
        .dftpwrup        (dftpwrup),
        .dftretdisable   (dftretdisable),
        
        .pcsm_preq_i     (preq_fwram_pcsm),
        .pcsm_pstate_i   (pstate_fwram_pcsm),
        .pcsm_paccept_o  (paccept_fwram_pcsm),

        
        .lgcpwrn_o(),
        .lgcretn_o(),
        .rampwrn_o(),
        .ramretn_o()
    );
    wire unused;
    
    assign unused = (|(unused1 | unused2 | unused3 | unused4 | unused5 | unused6)) | unused_fwram ;
endmodule
