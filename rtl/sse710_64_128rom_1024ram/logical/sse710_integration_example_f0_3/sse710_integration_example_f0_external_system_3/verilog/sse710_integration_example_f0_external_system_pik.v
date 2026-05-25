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

module sse710_integration_example_f0_external_system_pik (
    
    input  wire           extsys_aonclk,
    
    input  wire           extsys_poresetn_s,
    
    output wire           ppu_devporesetn,    
    output wire           ppu_devwarmresetn,    
        
    input  wire           mhupwrreq_qactive,    
    
    output wire           mhupwr_qreqn,        
    input  wire           mhupwr_qacceptn,    
    input  wire           mhupwr_qdeny, 
    
    output wire           mempwr_qreqn,        
    input  wire           mempwr_qacceptn,    
    input  wire           mempwr_qdeny,     
    input  wire           mempwr_qactive,
    
    output wire           traceexppwr_qreqn,        
    input  wire           traceexppwr_qacceptn,    
    input  wire           traceexppwr_qdeny,     
    input  wire           traceexppwr_qactive,    
    
    output wire           dbgpwr_qreqn,        
    input  wire           dbgpwr_qacceptn,    
    input  wire           dbgpwr_qdeny,     
    input  wire           dbgpwr_qactive,    
    
    output wire           extdbgpwr_qreqn,        
    input  wire           extdbgpwr_qacceptn,    
    input  wire           extdbgpwr_qdeny,     
    input  wire           extdbgpwr_qactive,    
    
    output wire           ctiinpwr_qreqn,        
    input  wire           ctiinpwr_qacceptn,    
    input  wire           ctiinpwr_qdeny,     
    input  wire           ctiinpwr_qactive,    
    
    output wire           ctioutpwr_qreqn,        
    input  wire           ctioutpwr_qacceptn,    
    input  wire           ctioutpwr_qdeny,     
    input  wire           ctioutpwr_qactive,       
    
    output wire           tspwr_qreqn,        
    input  wire           tspwr_qacceptn,    
    input  wire           tspwr_qdeny,     
    input  wire           tspwr_qactive,    
    
    output wire           axi_pwr_qreqn,        
    input  wire           axi_pwr_qacceptn,    
    input  wire           axi_pwr_qdeny,     
    input  wire           axi_pwr_qactive,  

    output wire           apb_pwr_qreqn,        
    input  wire           apb_pwr_qacceptn,    
    input  wire           apb_pwr_qdeny,     
    input  wire           apb_pwr_qactive,
    
    input  wire           dbgtop_qreqn,        
    output wire           dbgtop_qacceptn,    
    output wire           dbgtop_qdeny,      
    output wire           dbgtop_qactive,    
    
    input  wire           systop_qreqn,        
    output wire           systop_qacceptn,    
    output wire           systop_qdeny,      
    output wire           systop_qactive,     
    
    input  wire           aontop_qreqn,        
    output wire           aontop_qacceptn,    
    output wire           aontop_qdeny,      
    output wire           aontop_qactive,     
    
    input  wire           extdbgrom_cdbgpwrupreq,
    output wire           extdbgrom_cdbgpwrupack,
    input  wire           axiaprom_csyspwrupreq,
    output wire           axiaprom_csyspwrupack,
    
    output wire           ppu_irq, 
    
    input  wire [11:0]    ppu_paddr,
    input  wire           ppu_penable,
    input  wire           ppu_pwrite,
    input  wire [31:0]    ppu_pwdata,
    input  wire           ppu_psel,
    input  wire           ppu_pwakeup,       
    output wire           ppu_pready,
    output wire [31:0]    ppu_prdata,
    output wire           ppu_pslverr,
    
    input  wire           ppuclk_qreqn,        
    output wire           ppuclk_qacceptn,    
    output wire           ppuclk_qdeny,     
    output wire           ppuclk_qactive,     
    
    output wire           lpdp_clk_qactive,
    output wire           p2q_core_clk_qactive,
    output wire           p2q_dbg_clk_qactive,
    output wire           lpdq_core_clk_qactive,
    output wire           lpdq_dbg_clk_qactive,
    output wire           lpdq_systop_clk_qactive,
    output wire           lpcq_systop_clk_qactive,
    output wire           lpcq_dbgtop_clk_qactive,
    output wire           lpcq_aontop_clk_qactive,    
    output wire           extdbgrom_reqack_clk_qactive,
    output wire           axiaprom_reqack_clk_qactive,
    output wire           cpu_pwrctrl_qactive,

    
    output wire           ppu_devclken, 
    
    input  wire           sleeping_ss,
    input  wire           sleep_hold_ackn_ss,
    input  wire           sysreset_req_ss,
    input  wire           pwrdown_en,    
    output wire           sleep_hold_reqn, 
    output wire           warm_rst_state,
    
    input  wire           dftcgen,
    input  wire           dftpwrup,   
    input  wire           dftisodisable,
    input  wire           dftrstdisable,
    input  wire           dftretdisable

  );

  
  wire [4:0]     lpcq_dbgtop_dev_qreqn;
  wire [4:0]     lpcq_dbgtop_dev_qacceptn;
  wire [4:0]     lpcq_dbgtop_dev_qdeny;
  wire [4:0]     lpcq_dbgtop_dev_qactive;
  
  wire [1:0]     lpcq_dbgtop_ctrl_qreqn;
  wire [1:0]     lpcq_dbgtop_ctrl_qacceptn;
  wire [1:0]     lpcq_dbgtop_ctrl_qdeny;
  wire [1:0]     lpcq_dbgtop_ctrl_qactive;   
  
  
  wire [1:0]     lpcq_systop_dev_qreqn;
  wire [1:0]     lpcq_systop_dev_qacceptn;
  wire [1:0]     lpcq_systop_dev_qdeny;
  wire [1:0]     lpcq_systop_dev_qactive;
  
  wire [1:0]     lpcq_systop_ctrl_qreqn;
  wire [1:0]     lpcq_systop_ctrl_qacceptn;
  wire [1:0]     lpcq_systop_ctrl_qdeny;
  wire [1:0]     lpcq_systop_ctrl_qactive;  
  
  wire [1:0]     lpcq_aontop_ctrl_qreqn;
  wire [1:0]     lpcq_aontop_ctrl_qacceptn;
  wire [1:0]     lpcq_aontop_ctrl_qdeny;
  wire [1:0]     lpcq_aontop_ctrl_qactive;    
  
  
  wire [2:0]     lpdq_core_dev_qreqn;
  wire [2:0]     lpdq_core_dev_qacceptn;
  wire [2:0]     lpdq_core_dev_qdeny;
  wire [2:0]     lpdq_core_dev_qactive;
  
  wire           lpdq_core_ctrl_qreqn;
  wire           lpdq_core_ctrl_qacceptn;
  wire           lpdq_core_ctrl_qdeny;
  wire           lpdq_core_ctrl_qactive;
    
  
  wire [2:0]     lpdq_dbg_dev_qreqn;
  wire [2:0]     lpdq_dbg_dev_qacceptn;
  wire [2:0]     lpdq_dbg_dev_qdeny;
  wire [2:0]     lpdq_dbg_dev_qactive;  
  
  wire           lpdq_dbg_ctrl_qreqn;
  wire           lpdq_dbg_ctrl_qacceptn;
  wire           lpdq_dbg_ctrl_qdeny;
  wire           lpdq_dbg_ctrl_qactive;      

  wire [1:0]     lpdq_systop_dev_qreqn;
  wire [1:0]     lpdq_systop_dev_qacceptn;
  wire [1:0]     lpdq_systop_dev_qdeny;
  wire [1:0]     lpdq_systop_dev_qactive;  

  wire           extdbgrom_reqack_qreqn;
  wire           extdbgrom_reqack_qacceptn;
  wire           extdbgrom_reqack_qdeny;
  wire           extdbgrom_reqack_qactive; 
  
  wire           axiaprom_reqack_qreqn;
  wire           axiaprom_reqack_qacceptn;
  wire           axiaprom_reqack_qdeny;
  wire           axiaprom_reqack_qactive;   
  
  wire           p2q_core_ctrl_preq;
  wire [3:0]     p2q_core_ctrl_pstate;
  wire [31:0]    p2q_core_ctrl_pactive;
  wire           p2q_core_ctrl_paccept;
  wire           p2q_core_ctrl_pdeny;
  
  wire           p2q_dbg_ctrl_preq;
  wire [3:0]     p2q_dbg_ctrl_pstate;
  wire [31:0]    p2q_dbg_ctrl_pactive;
  wire           p2q_dbg_ctrl_paccept;
  wire           p2q_dbg_ctrl_pdeny;  

  wire           lpdp_ctrl_preq;
  wire [3:0]     lpdp_ctrl_pstate;
  wire [10:0]    lpdp_ctrl_pactive;
  wire           lpdp_ctrl_paccept;
  wire           lpdp_ctrl_pdeny;
  
  wire           ppu_dev_preq;
  wire [3:0]     ppu_dev_pstate;
  wire [10:0]    ppu_dev_pactive;
  wire           ppu_dev_paccept;
  wire           ppu_dev_pdeny;  

  wire           cpupwr_preq;
  wire [3:0]     cpupwr_pstate;
  wire [10:0]    cpupwr_pactive;
  wire           cpupwr_paccept;
  wire           cpupwr_pdeny;   

  wire           pcsm_preq;
  wire [3:0]     pcsm_pstate;
  wire           pcsm_paccept;
  
  wire [3:0]     ppu_eco;
  
  wire           extdbgrom_cdbgpwrupack_reqack;
  wire           axiaprom_csyspwrupack_reqack;
  wire           dbgtop_qacceptn_int;
  
  wire           unused;
  
  sse710_integration_example_f0_external_system_cpu_pwrctrl u_sse710_integration_example_f0_external_system_cpu_pwrctrl
  (
    .extsys_aonclk          (extsys_aonclk),
    .extsys_poresetn_s      (extsys_poresetn_s),

    .cpupwr_preq            (cpupwr_preq),
    .cpupwr_pstate          (cpupwr_pstate),
    .cpupwr_paccept         (cpupwr_paccept),
    .cpupwr_pdeny           (cpupwr_pdeny),
    .cpupwr_pactive         (cpupwr_pactive),

    .sleeping_ss            (sleeping_ss),
    .sleep_hold_ackn_ss     (sleep_hold_ackn_ss),
    .sysreset_req_ss        (sysreset_req_ss),
    .pwrdown_en             (pwrdown_en),

    .sleep_hold_reqn        (sleep_hold_reqn),
    .clk_qactive            (cpu_pwrctrl_qactive)
  );


  pck600_ppu_sse710_extsys u_pck600_ppu_sse710_extsys
  (
    .clk                   (extsys_aonclk),
    .reset_n               (extsys_poresetn_s),

    .dftcgen               (dftcgen),
    .dftisodisable         (dftisodisable),
    .dftrstdisable         (dftrstdisable),

    .psel_i                (ppu_psel),
    .penable_i             (ppu_penable),
    .paddr_i               ({20'h0_0000, ppu_paddr}),
    .pwrite_i              (ppu_pwrite),
    .pwdata_i              (ppu_pwdata),
    .prdata_o              (ppu_prdata),
    .pready_o              (ppu_pready),
    .pslverr_o             (ppu_pslverr),
    .pwakeup_i             (ppu_pwakeup),

    .irq_o                 (ppu_irq),

    .dev_preq_o            (ppu_dev_preq),
    .dev_pstate_o          (ppu_dev_pstate),
    .dev_paccept_i         (ppu_dev_paccept),
    .dev_pdeny_i           (ppu_dev_pdeny),
    .dev_pactive_i         (ppu_dev_pactive),

    .ppuhwstat_o           (),
    .devclken_o            (ppu_devclken),
    .devemuclken_o         (),
    .devisolaten_o         (),
    .devemuisolaten_o      (),
    .devwarmresetn_o       (ppu_devwarmresetn),
    .devretresetn_o        (),
    .devporesetn_o         (ppu_devporesetn),

    .pcsm_preq_o           (pcsm_preq),
    .pcsm_pstate_o         (pcsm_pstate),
    .pcsm_paccept_i        (pcsm_paccept),

    .ppuclk_qreqn_i        (ppuclk_qreqn),
    .ppuclk_qacceptn_o     (ppuclk_qacceptn),
    .ppuclk_qdeny_o        (ppuclk_qdeny),
    .ppuclk_qactive_o      (ppuclk_qactive),

    .ecorevnum_i           (ppu_eco)
    );
  
  assign lpdp_ctrl_preq   = ppu_dev_preq;   
  assign lpdp_ctrl_pstate = ppu_dev_pstate; 
  assign ppu_dev_pactive  = lpdp_ctrl_pactive;
  assign ppu_dev_paccept  = lpdp_ctrl_paccept;
  assign ppu_dev_pdeny    = lpdp_ctrl_pdeny;  
  
  assign warm_rst_state = ((ppu_dev_pstate == 4'h9) && ~ppu_dev_paccept && ~ppu_dev_preq) ? 1'b1 : 1'b0;

  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_arm_element_ecorevnum (
    .ecorevnum (ppu_eco)
  );  
  

  pck600_ppu_pcsm_sse710_extsys u_pck600_ppu_pcsm_sse710_extsys
  (
    .clk               (extsys_aonclk),
    .reset_n           (extsys_poresetn_s),

    .dftpwrup          (dftpwrup),
    .dftretdisable     (dftretdisable),
    
    .pcsm_preq_i       (pcsm_preq),
    .pcsm_pstate_i     (pcsm_pstate),
    .pcsm_paccept_o    (pcsm_paccept),

    .lgcpwrn_o         (),
    .lgcretn_o         (),
    .rampwrn_o         (),
    .ramretn_o         () 
  );


  pck600_lpd_p_sse710_extsys #(
    .SEQUENCER              (0),
    .DEV_P_CH_0_SAME_EN     (0),
    .DEV_P_CH_1_SAME_EN     (0),
    .DEV_P_CH_2_SAME_EN     (0),
    .CTRL_P_CH_SYNC         (0),
    .DEV_P_CH_SYNC          (0),
    .DEV_P_CH_PREQ_DLY      (1)
  ) u_pck600_lpd_p_sse710_extsys (
    .clk               (extsys_aonclk),
    .reset_n           (extsys_poresetn_s),

    .ctrl_preq_i       (lpdp_ctrl_preq),
    .ctrl_pstate_i     (lpdp_ctrl_pstate),
    .ctrl_pactive_o    (lpdp_ctrl_pactive),
    .ctrl_paccept_o    (lpdp_ctrl_paccept),
    .ctrl_pdeny_o      (lpdp_ctrl_pdeny),

    .dev0_preq_o       (cpupwr_preq),
    .dev0_pstate_o     (cpupwr_pstate),
    .dev0_pactive_i    (cpupwr_pactive),
    .dev0_paccept_i    (cpupwr_paccept),
    .dev0_pdeny_i      (cpupwr_pdeny),

    .dev1_preq_o       (p2q_core_ctrl_preq),
    .dev1_pstate_o     (p2q_core_ctrl_pstate),
    .dev1_pactive_i    (p2q_core_ctrl_pactive[10:0]),
    .dev1_paccept_i    (p2q_core_ctrl_paccept),
    .dev1_pdeny_i      (p2q_core_ctrl_pdeny),

    .dev2_preq_o       (p2q_dbg_ctrl_preq),
    .dev2_pstate_o     (p2q_dbg_ctrl_pstate),
    .dev2_pactive_i    (p2q_dbg_ctrl_pactive[10:0]),
    .dev2_paccept_i    (p2q_dbg_ctrl_paccept),
    .dev2_pdeny_i      (p2q_dbg_ctrl_pdeny),

    .clk_qactive_o     (lpdp_clk_qactive),

    .dftcgen           (dftcgen)
  );

  
  pck600_p2q #(
    .CTRL_P_CH_SYNC           (0),
    .DEV_Q_CH_SYNC            (0),
    .CTRL_P_CH_PWR_PSTATE_MAP (16'b0000_0011_0000_0000),                      
    .CTRL_P_CH_OP_PSTATE_MAP  (16'b1111_1111_1111_1111),                      
    .CTRL_P_CH_PACTIVE        (32'b0000_0000_0000_0000_0000_0001_0000_0000)   
  ) u_pck600_p2q_dbg (
    .clk                 (extsys_aonclk),
    .reset_n             (extsys_poresetn_s),
    
    .ctrl_pstate_i       ({4'h0, p2q_dbg_ctrl_pstate}),
    .ctrl_preq_i         (p2q_dbg_ctrl_preq),
    .ctrl_paccept_o      (p2q_dbg_ctrl_paccept),
    .ctrl_pdeny_o        (p2q_dbg_ctrl_pdeny),
    .ctrl_pactive_o      (p2q_dbg_ctrl_pactive),
    
    .dev_qreqn_o         (lpdq_dbg_ctrl_qreqn),
    .dev_qacceptn_i      (lpdq_dbg_ctrl_qacceptn),
    .dev_qdeny_i         (lpdq_dbg_ctrl_qdeny),
    .dev_qactive_i       (lpdq_dbg_ctrl_qactive),
    
    .clk_qactive_o       (p2q_dbg_clk_qactive),
    
    .dftcgen             (dftcgen)
  );
  



  pck600_p2q #(
    .CTRL_P_CH_SYNC           (0),
    .DEV_Q_CH_SYNC            (0),
    .CTRL_P_CH_PWR_PSTATE_MAP (16'b0000_0001_0000_0000),                      
    .CTRL_P_CH_OP_PSTATE_MAP  (16'b1111_1111_1111_1111),                      
    .CTRL_P_CH_PACTIVE        (32'b0000_0000_0000_0000_0000_0001_0000_0000)   
  ) u_pck600_p2q_core (
    .clk                 (extsys_aonclk),
    .reset_n             (extsys_poresetn_s),
    
    .ctrl_pstate_i       ({4'h0, p2q_core_ctrl_pstate}),
    .ctrl_preq_i         (p2q_core_ctrl_preq),
    .ctrl_paccept_o      (p2q_core_ctrl_paccept),
    .ctrl_pdeny_o        (p2q_core_ctrl_pdeny),
    .ctrl_pactive_o      (p2q_core_ctrl_pactive),
    
    .dev_qreqn_o         (lpdq_core_ctrl_qreqn),
    .dev_qacceptn_i      (lpdq_core_ctrl_qacceptn),
    .dev_qdeny_i         (lpdq_core_ctrl_qdeny),
    .dev_qactive_i       (lpdq_core_ctrl_qactive),
    
    .clk_qactive_o       (p2q_core_clk_qactive),
    
    .dftcgen             (dftcgen)
  );


  pck600_lpd_q #(
    .SEQUENCER        (0),
    .NUM_QCHL         (3),
    .CTRL_Q_CH_SYNC   (0),
    .DEV_Q_CH_SYNC    (1),
    .DEV_QACTIVE_SYNC (0),
    .ACTIVE_DENY      (0)
  ) u_pck600_lpd_q_core (
    .clk               (extsys_aonclk),
    .reset_n           (extsys_poresetn_s),

    .ctrl_qreqn_i      (lpdq_core_ctrl_qreqn),
    .ctrl_qacceptn_o   (lpdq_core_ctrl_qacceptn),
    .ctrl_qdeny_o      (lpdq_core_ctrl_qdeny),
    .ctrl_qactive_o    (lpdq_core_ctrl_qactive),

    .dev_qreqn_o       (lpdq_core_dev_qreqn),
    .dev_qacceptn_i    (lpdq_core_dev_qacceptn),
    .dev_qdeny_i       (lpdq_core_dev_qdeny),
    .dev_qactive_i     (lpdq_core_dev_qactive),

    .clk_qactive_o     (lpdq_core_clk_qactive),

    .dftcgen           (dftcgen)
  );

  assign mhupwr_qreqn              = lpdq_core_dev_qreqn[1];
  assign lpdq_core_dev_qacceptn[1] = mhupwr_qacceptn;
  assign lpdq_core_dev_qdeny[1]    = mhupwr_qdeny;
  assign lpdq_core_dev_qactive[1]  = mhupwrreq_qactive;


  pck600_lpd_q #(
    .SEQUENCER        (1), 
    .NUM_QCHL         (3),
    .CTRL_Q_CH_SYNC   (0),
    .DEV_Q_CH_SYNC    (0),
    .DEV_QACTIVE_SYNC (0),
    .ACTIVE_DENY      (0)
  ) u_pck600_lpd_q_dbg (
    .clk               (extsys_aonclk),
    .reset_n           (extsys_poresetn_s),

    .ctrl_qreqn_i      (lpdq_dbg_ctrl_qreqn),
    .ctrl_qacceptn_o   (lpdq_dbg_ctrl_qacceptn),
    .ctrl_qdeny_o      (lpdq_dbg_ctrl_qdeny),
    .ctrl_qactive_o    (lpdq_dbg_ctrl_qactive),

    .dev_qreqn_o       (lpdq_dbg_dev_qreqn),
    .dev_qacceptn_i    (lpdq_dbg_dev_qacceptn),
    .dev_qdeny_i       (lpdq_dbg_dev_qdeny),
    .dev_qactive_i     (lpdq_dbg_dev_qactive),

    .clk_qactive_o     (lpdq_dbg_clk_qactive),

    .dftcgen           (dftcgen)
  );
  
  assign extdbgrom_reqack_qreqn   = lpdq_dbg_dev_qreqn[1];
  assign lpdq_dbg_dev_qacceptn[1] = extdbgrom_reqack_qacceptn;
  assign lpdq_dbg_dev_qdeny[1]    = extdbgrom_reqack_qdeny;
  assign lpdq_dbg_dev_qactive[1]  = extdbgrom_reqack_qactive;
  
  assign axiaprom_reqack_qreqn    = lpdq_dbg_dev_qreqn[2];
  assign lpdq_dbg_dev_qacceptn[2] = axiaprom_reqack_qacceptn;
  assign lpdq_dbg_dev_qdeny[2]    = axiaprom_reqack_qdeny;
  assign lpdq_dbg_dev_qactive[2]  = axiaprom_reqack_qactive;  
  

  pck600_lpd_q #(
    .SEQUENCER        (0),
    .NUM_QCHL         (2),
    .CTRL_Q_CH_SYNC   (1),
    .DEV_Q_CH_SYNC    (1),
    .DEV_QACTIVE_SYNC (0),
    .ACTIVE_DENY      (0)
  ) u_pck600_lpd_q_systop (
    .clk               (extsys_aonclk),
    .reset_n           (extsys_poresetn_s),

    .ctrl_qreqn_i      (systop_qreqn),
    .ctrl_qacceptn_o   (systop_qacceptn),
    .ctrl_qdeny_o      (systop_qdeny),
    .ctrl_qactive_o    (systop_qactive),

    .dev_qreqn_o       (lpdq_systop_dev_qreqn),
    .dev_qacceptn_i    (lpdq_systop_dev_qacceptn),
    .dev_qdeny_i       (lpdq_systop_dev_qdeny),
    .dev_qactive_i     (lpdq_systop_dev_qactive),

    .clk_qactive_o     (lpdq_systop_clk_qactive),

    .dftcgen           (dftcgen)
  );
  
  assign apb_pwr_qreqn               = lpdq_systop_dev_qreqn[1];
  assign lpdq_systop_dev_qacceptn[1] = apb_pwr_qacceptn;
  assign lpdq_systop_dev_qdeny[1]    = apb_pwr_qdeny;
  assign lpdq_systop_dev_qactive[1]  = apb_pwr_qactive; 


  pck600_lpc_q #(
    .NUM_CTRL_Q_CHL    (2),
    .NUM_DEV_Q_CHL     (5),
    .CTRL_Q_CH_SYNC    (1),
    .DEV_Q_CH_SYNC     (1)
  ) u_pck600_lpc_q_dbg (
    .clk               (extsys_aonclk),
    .reset_n           (extsys_poresetn_s),

    .dftcgen           (dftcgen),

    .ctrl_qreqn_i      (lpcq_dbgtop_ctrl_qreqn),
    .ctrl_qacceptn_o   (lpcq_dbgtop_ctrl_qacceptn),
    .ctrl_qdeny_o      (lpcq_dbgtop_ctrl_qdeny),
    .ctrl_qactive_o    (lpcq_dbgtop_ctrl_qactive),

    .dev_qreqn_o       (lpcq_dbgtop_dev_qreqn),
    .dev_qacceptn_i    (lpcq_dbgtop_dev_qacceptn),
    .dev_qdeny_i       (lpcq_dbgtop_dev_qdeny),
    .dev_qactive_i     (lpcq_dbgtop_dev_qactive),

    .clk_qactive_o     (lpcq_dbgtop_clk_qactive)
  );     
    
  assign {traceexppwr_qreqn, dbgpwr_qreqn, ctiinpwr_qreqn, ctioutpwr_qreqn, tspwr_qreqn} = lpcq_dbgtop_dev_qreqn;
  
  assign lpcq_dbgtop_dev_qacceptn = {traceexppwr_qacceptn, 
                                  dbgpwr_qacceptn,
                                  ctiinpwr_qacceptn,
                                  ctioutpwr_qacceptn,
                                  tspwr_qacceptn};      
                                  
  assign lpcq_dbgtop_dev_qdeny = {traceexppwr_qdeny, 
                               dbgpwr_qdeny,
                               ctiinpwr_qdeny,
                               ctioutpwr_qdeny,
                               tspwr_qdeny};
                                  
  assign lpcq_dbgtop_dev_qactive = {traceexppwr_qactive, 
                                 dbgpwr_qactive,
                                 ctiinpwr_qactive,
                                 ctioutpwr_qactive,
                                 tspwr_qactive};                                                                                             
  
  assign lpcq_dbgtop_ctrl_qreqn = {lpdq_dbg_dev_qreqn[0], dbgtop_qreqn};
  
  assign {lpdq_dbg_dev_qacceptn[0], dbgtop_qacceptn_int} = lpcq_dbgtop_ctrl_qacceptn;
  assign {lpdq_dbg_dev_qdeny[0]   , dbgtop_qdeny   }     = lpcq_dbgtop_ctrl_qdeny;
  assign {lpdq_dbg_dev_qactive[0] , dbgtop_qactive }     = lpcq_dbgtop_ctrl_qactive;
  
  assign dbgtop_qacceptn = dbgtop_qacceptn_int;


  pck600_lpc_q #(
    .NUM_CTRL_Q_CHL    (2),
    .NUM_DEV_Q_CHL     (2),
    .CTRL_Q_CH_SYNC    (0),
    .DEV_Q_CH_SYNC     (1)
  ) u_pck600_lpc_q_systop (
    .clk               (extsys_aonclk),
    .reset_n           (extsys_poresetn_s),

    .dftcgen           (dftcgen),

    .ctrl_qreqn_i      (lpcq_systop_ctrl_qreqn),
    .ctrl_qacceptn_o   (lpcq_systop_ctrl_qacceptn),
    .ctrl_qdeny_o      (lpcq_systop_ctrl_qdeny),
    .ctrl_qactive_o    (lpcq_systop_ctrl_qactive),

    .dev_qreqn_o       (lpcq_systop_dev_qreqn),
    .dev_qacceptn_i    (lpcq_systop_dev_qacceptn),
    .dev_qdeny_i       (lpcq_systop_dev_qdeny),
    .dev_qactive_i     (lpcq_systop_dev_qactive),

    .clk_qactive_o     (lpcq_systop_clk_qactive)
  );     
  
  assign {axi_pwr_qreqn, mempwr_qreqn} = lpcq_systop_dev_qreqn;

  assign lpcq_systop_dev_qacceptn = {axi_pwr_qacceptn, mempwr_qacceptn};      
  assign lpcq_systop_dev_qdeny    = {axi_pwr_qdeny   , mempwr_qdeny   };
  assign lpcq_systop_dev_qactive  = {axi_pwr_qactive , mempwr_qactive };                                                                                            
  
  assign lpcq_systop_ctrl_qreqn = {lpdq_systop_dev_qreqn[0], lpdq_core_dev_qreqn[2]};
  
  assign {lpdq_systop_dev_qacceptn[0], lpdq_core_dev_qacceptn[2]} = lpcq_systop_ctrl_qacceptn;
  assign {lpdq_systop_dev_qdeny[0],    lpdq_core_dev_qdeny[2]   } = lpcq_systop_ctrl_qdeny;
  assign {lpdq_systop_dev_qactive[0],  lpdq_core_dev_qactive[2] } = lpcq_systop_ctrl_qactive;


  pck600_lpc_q #(
    .NUM_CTRL_Q_CHL    (2),
    .NUM_DEV_Q_CHL     (1),
    .CTRL_Q_CH_SYNC    (1),
    .DEV_Q_CH_SYNC     (1)
  ) u_pck600_lpc_q_aontop (
    .clk               (extsys_aonclk),
    .reset_n           (extsys_poresetn_s),

    .dftcgen           (dftcgen),

    .ctrl_qreqn_i      (lpcq_aontop_ctrl_qreqn),
    .ctrl_qacceptn_o   (lpcq_aontop_ctrl_qacceptn),
    .ctrl_qdeny_o      (lpcq_aontop_ctrl_qdeny),
    .ctrl_qactive_o    (lpcq_aontop_ctrl_qactive),

    .dev_qreqn_o       (extdbgpwr_qreqn),
    .dev_qacceptn_i    (extdbgpwr_qacceptn),
    .dev_qdeny_i       (extdbgpwr_qdeny),
    .dev_qactive_i     (extdbgpwr_qactive),

    .clk_qactive_o     (lpcq_aontop_clk_qactive)
  );     
  
  assign lpcq_aontop_ctrl_qreqn = {aontop_qreqn, lpdq_core_dev_qreqn[0]};
  
  assign {aontop_qacceptn, lpdq_core_dev_qacceptn[0]} = lpcq_aontop_ctrl_qacceptn;
  assign {aontop_qdeny,    lpdq_core_dev_qdeny[0]   } = lpcq_aontop_ctrl_qdeny;
  assign {aontop_qactive,  lpdq_core_dev_qactive[0] } = lpcq_aontop_ctrl_qactive;


  p_reqack_to_qchan_f0_top u_p_reqack_to_qchan_f0_top_extdbgrom(
    .CLK          (extsys_aonclk),
    .RESETn       (extsys_poresetn_s),

    .PWRUPREQ     (extdbgrom_cdbgpwrupreq),
    .PWRUPACK     (extdbgrom_cdbgpwrupack_reqack),

    .PWRQREQn     (extdbgrom_reqack_qreqn),
    .PWRQACCEPTn  (extdbgrom_reqack_qacceptn),
    .PWRQDENY     (extdbgrom_reqack_qdeny),
    .PWRQACTIVE   (extdbgrom_reqack_qactive),
    
    .CLKQACTIVE   (extdbgrom_reqack_clk_qactive)
  );
  
  arm_element_cdc_comb_and2 u_arm_element_cdc_comb_and2_0 (
    .din1_async (extdbgrom_cdbgpwrupack_reqack),
    .din2_async (dbgtop_qacceptn_int),
    .dout_async (extdbgrom_cdbgpwrupack)
  );
  

  p_reqack_to_qchan_f0_top u_p_reqack_to_qchan_f0_top_axiaprom(
    .CLK          (extsys_aonclk),
    .RESETn       (extsys_poresetn_s),

    .PWRUPREQ     (axiaprom_csyspwrupreq),
    .PWRUPACK     (axiaprom_csyspwrupack_reqack),

    .PWRQREQn     (axiaprom_reqack_qreqn),
    .PWRQACCEPTn  (axiaprom_reqack_qacceptn),
    .PWRQDENY     (axiaprom_reqack_qdeny),
    .PWRQACTIVE   (axiaprom_reqack_qactive),
    
    .CLKQACTIVE   (axiaprom_reqack_clk_qactive)
  );  

  arm_element_cdc_comb_and2 u_arm_element_cdc_comb_and2_1 (
    .din1_async (axiaprom_csyspwrupack_reqack),
    .din2_async (dbgtop_qacceptn_int),
    .dout_async (axiaprom_csyspwrupack)
  );  
  
  assign unused = (|p2q_dbg_ctrl_pactive[31:11]) |
                  (|p2q_core_ctrl_pactive[31:11]);

endmodule
