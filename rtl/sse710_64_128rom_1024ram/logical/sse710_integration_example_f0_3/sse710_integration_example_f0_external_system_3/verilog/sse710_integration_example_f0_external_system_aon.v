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

module sse710_integration_example_f0_external_system_aon (
    
    input  wire           extsys_fclk,
    output wire           extsys_clk,
    
    input  wire           extsys_poresetn,
    input  wire           extsys_cpuwait,
    output wire           extsys_mtx_resetn, 
    output wire           extsys_dbg_resetn,
    output wire           extsys_core_resetn,
    output wire           extsys_dbgpresetsn,
    output wire           extsys_dbgpresetmn,
    output wire           extsys_atresetn,
    output wire           extsys_ctiresetn,
    output wire           extsys_aresetn,
    output wire           extsys_mhuresetn,  
    
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
    
    input  wire [4:0]     extsys_rstsyn,
    
    input  wire           sysreg_apb_async_req,
    input  wire [47:0]    sysreg_apb_async_req_payload,
    output wire [32:0]    sysreg_apb_async_resp_payload,
    output wire           sysreg_apb_async_ack,
    
    input  wire           uart_apb_async_req,
    input  wire [47:0]    uart_apb_async_req_payload,
    output wire [32:0]    uart_apb_async_resp_payload,
    output wire           uart_apb_async_ack,
    
    input   wire          ppu_apb_async_req,
    input   wire [47:0]   ppu_apb_async_req_payload,
    output  wire [32:0]   ppu_apb_async_resp_payload,
    output  wire          ppu_apb_async_ack,  
        
    input  wire           sleeping,
    input  wire           sleep_hold_ackn,
    input  wire           sysreset_req,
    
    output wire           sleep_hold_reqn,
    
    output wire           ppu_irq,
    
    output wire           uart_irq,
    
    output wire [8:0]     clock_override_extsystop,
    
    input  wire           ppu_dbgen,
    
    input  wire           nuartcts, 
    input  wire           nuartdcd, 
    input  wire           nuartdsr, 
    input  wire           nuartri,  
    input  wire           uartrxd,  
    output wire           uarttxd,  
    output wire           nuartdtr, 
    output wire           nuartrts, 
    output wire           nuartout1,
    output wire           nuartout2,
    
    input  wire           mbistreq,
    input  wire           dftcgen,
    input  wire [1:0]     dftrstdisable,
    input  wire           dftpwrup,
    input  wire           dftisodisable,
    input  wire           dftretdisable
  );


  wire           extsys_aonclk;

  wire           extsys_poresetn_s;
  
  wire           sysreg_pready;
  wire [31:0]    sysreg_prdata;
  wire           sysreg_pslverr;
  wire [11:0]    sysreg_paddr;
  wire           sysreg_penable;
  wire           sysreg_pwrite;
  wire [31:0]    sysreg_pwdata;
  wire           sysreg_psel;

  wire           uart_pready;
  wire [31:0]    uart_prdata;
  wire           uart_pslverr;
  wire [11:0]    uart_paddr;
  wire           uart_penable;
  wire           uart_pwrite;
  wire [31:0]    uart_pwdata;
  wire           uart_psel;   

  wire [11:0]    ppu_paddr;
  wire           ppu_penable;
  wire           ppu_pwrite;
  wire [31:0]    ppu_pwdata;
  wire           ppu_psel;
  wire           ppu_pwakeup;       
  wire           ppu_pready;
  wire [31:0]    ppu_prdata;
  wire           ppu_pslverr;
  
  wire [11:0]    ppu_adb_paddr;
  wire           ppu_adb_penable;
  wire           ppu_adb_pwrite;
  wire [31:0]    ppu_adb_pwdata;
  wire           ppu_adb_psel;
  wire           ppu_adb_pwakeup;       
  wire           ppu_adb_pready;
  wire [31:0]    ppu_adb_prdata;
  wire           ppu_adb_pslverr;

  wire           ppu_dbgen_ss;

  wire [3:0]     decode4bit;  
    
  wire           sysreg_adb_clk_qreqn;        
  wire           sysreg_adb_clk_qacceptn;    
  wire           sysreg_adb_clk_qdeny;     
  wire           sysreg_adb_clk_qactive;
  
  wire           uart_adb_clk_qreqn;        
  wire           uart_adb_clk_qacceptn;    
  wire           uart_adb_clk_qdeny;     
  wire           uart_adb_clk_qactive;   
    
  wire           ppu_adb_clk_qreqn;        
  wire           ppu_adb_clk_qacceptn;    
  wire           ppu_adb_clk_qdeny;     
  wire           ppu_adb_clk_qactive; 
  
  wire           resetsyndrome_log_en; 

  wire           pwrdown_en;

  wire [8:0]     clock_override_aon;
    
  wire           ppuclk_qreqn;        
  wire           ppuclk_qacceptn;    
  wire           ppuclk_qdeny;      
  wire           ppuclk_qactive; 
    
  wire           lpdp_clk_qactive;     
  wire           p2q_core_clk_qactive; 
  wire           p2q_dbg_clk_qactive; 
  wire           lpdq_core_clk_qactive;
  wire           lpdq_dbg_clk_qactive;
  wire           lpdq_systop_clk_qactive;
  wire           lpcq_systop_clk_qactive;
  wire           lpcq_dbgtop_clk_qactive;
  wire           lpcq_aontop_clk_qactive;  
  wire           extdbgrom_reqack_clk_qactive;
  wire           axiaprom_reqack_clk_qactive;
  wire           cpu_pwrctrl_qactive;
  wire           ppu_devclken;     
  
  wire           ppu_devporesetn;
  wire           ppu_devwarmresetn;  
  
  wire           sleeping_ss;
  wire           sleep_hold_ackn_ss;
  wire           sysreset_req_ss;
  
  wire           warm_rst_state;
  wire           extsys_mtx_resetn_i;
  wire           extsys_dbg_resetn_i;
  
  wire           nuartcts_ss; 
  wire           nuartdcd_ss; 
  wire           nuartdsr_ss;
  wire           nuartri_ss;
  wire           uartrxd_ss;
  
  wire           unused;

  sse710_integration_example_f0_external_system_pik u_sse710_integration_example_f0_external_system_pik (
    .extsys_aonclk             (extsys_aonclk),
    .extsys_poresetn_s         (extsys_poresetn_s),
    .ppu_devporesetn           (ppu_devporesetn),
    .ppu_devwarmresetn         (ppu_devwarmresetn),
                               
    .mhupwrreq_qactive         (mhupwrreq_qactive),
                               
    .mhupwr_qreqn              (mhupwr_qreqn),
    .mhupwr_qacceptn           (mhupwr_qacceptn),
    .mhupwr_qdeny              (mhupwr_qdeny),
                               
    .mempwr_qreqn              (mempwr_qreqn),
    .mempwr_qacceptn           (mempwr_qacceptn),
    .mempwr_qdeny              (mempwr_qdeny),
    .mempwr_qactive            (mempwr_qactive),
                               
    .traceexppwr_qreqn         (traceexppwr_qreqn),   
    .traceexppwr_qacceptn      (traceexppwr_qacceptn),  
    .traceexppwr_qdeny         (traceexppwr_qdeny),
    .traceexppwr_qactive       (traceexppwr_qactive), 
                               
    .dbgpwr_qreqn              (dbgpwr_qreqn),
    .dbgpwr_qacceptn           (dbgpwr_qacceptn),
    .dbgpwr_qdeny              (dbgpwr_qdeny),
    .dbgpwr_qactive            (dbgpwr_qactive),
                               
    .extdbgpwr_qreqn           (extdbgpwr_qreqn), 
    .extdbgpwr_qacceptn        (extdbgpwr_qacceptn),
    .extdbgpwr_qdeny           (extdbgpwr_qdeny),
    .extdbgpwr_qactive         (extdbgpwr_qactive),
                               
    .ctiinpwr_qreqn            (ctiinpwr_qreqn),
    .ctiinpwr_qacceptn         (ctiinpwr_qacceptn),
    .ctiinpwr_qdeny            (ctiinpwr_qdeny),
    .ctiinpwr_qactive          (ctiinpwr_qactive),
    
    .ctioutpwr_qreqn           (ctioutpwr_qreqn),    
    .ctioutpwr_qacceptn        (ctioutpwr_qacceptn), 
    .ctioutpwr_qdeny           (ctioutpwr_qdeny),    
    .ctioutpwr_qactive         (ctioutpwr_qactive),      
    
    .tspwr_qreqn               (tspwr_qreqn),
    .tspwr_qacceptn            (tspwr_qacceptn),
    .tspwr_qdeny               (tspwr_qdeny),
    .tspwr_qactive             (tspwr_qactive),
                               
    .axi_pwr_qreqn             (axi_pwr_qreqn),        
    .axi_pwr_qacceptn          (axi_pwr_qacceptn),    
    .axi_pwr_qdeny             (axi_pwr_qdeny),     
    .axi_pwr_qactive           (axi_pwr_qactive),

    .apb_pwr_qreqn             (apb_pwr_qreqn),        
    .apb_pwr_qacceptn          (apb_pwr_qacceptn),    
    .apb_pwr_qdeny             (apb_pwr_qdeny),     
    .apb_pwr_qactive           (apb_pwr_qactive), 
                               
    .dbgtop_qreqn              (dbgtop_qreqn),
    .dbgtop_qacceptn           (dbgtop_qacceptn),
    .dbgtop_qdeny              (dbgtop_qdeny),
    .dbgtop_qactive            (dbgtop_qactive),
                               
    .systop_qreqn              (systop_qreqn),
    .systop_qacceptn           (systop_qacceptn),
    .systop_qdeny              (systop_qdeny),
    .systop_qactive            (systop_qactive),
                               
    .aontop_qreqn              (aontop_qreqn),
    .aontop_qacceptn           (aontop_qacceptn),
    .aontop_qdeny              (aontop_qdeny),
    .aontop_qactive            (aontop_qactive),    
                               
    .extdbgrom_cdbgpwrupreq    (extdbgrom_cdbgpwrupreq),
    .extdbgrom_cdbgpwrupack    (extdbgrom_cdbgpwrupack),
    .axiaprom_csyspwrupreq     (axiaprom_csyspwrupreq),
    .axiaprom_csyspwrupack     (axiaprom_csyspwrupack),    
                               
    .ppu_irq                   (ppu_irq),
                               
    .ppu_paddr                 (ppu_paddr),
    .ppu_penable               (ppu_penable),
    .ppu_pwrite                (ppu_pwrite),
    .ppu_pwdata                (ppu_pwdata),
    .ppu_psel                  (ppu_psel),
    .ppu_pwakeup               (ppu_pwakeup),
    .ppu_pready                (ppu_pready),
    .ppu_prdata                (ppu_prdata),
    .ppu_pslverr               (ppu_pslverr),
                               
    .ppuclk_qreqn              (ppuclk_qreqn),
    .ppuclk_qacceptn           (ppuclk_qacceptn),
    .ppuclk_qdeny              (ppuclk_qdeny),
    .ppuclk_qactive            (ppuclk_qactive),
    
    .lpdp_clk_qactive              (lpdp_clk_qactive),
    .p2q_core_clk_qactive          (p2q_core_clk_qactive),
    .p2q_dbg_clk_qactive           (p2q_dbg_clk_qactive),
    .lpdq_core_clk_qactive         (lpdq_core_clk_qactive),
    .lpdq_dbg_clk_qactive          (lpdq_dbg_clk_qactive),
    .lpdq_systop_clk_qactive       (lpdq_systop_clk_qactive),
    .lpcq_systop_clk_qactive       (lpcq_systop_clk_qactive),
    .lpcq_dbgtop_clk_qactive       (lpcq_dbgtop_clk_qactive),
    .lpcq_aontop_clk_qactive       (lpcq_aontop_clk_qactive),
    .extdbgrom_reqack_clk_qactive  (extdbgrom_reqack_clk_qactive),
    .axiaprom_reqack_clk_qactive   (axiaprom_reqack_clk_qactive),        
    .cpu_pwrctrl_qactive           (cpu_pwrctrl_qactive),
    
    .ppu_devclken              (ppu_devclken),
                               
                               
    .sleeping_ss               (sleeping_ss),
    .sleep_hold_ackn_ss        (sleep_hold_ackn_ss),
    .sysreset_req_ss           (sysreset_req_ss),
    .pwrdown_en                (pwrdown_en),    
    .sleep_hold_reqn           (sleep_hold_reqn),
    .warm_rst_state            (warm_rst_state),
                               
    .dftcgen                   (dftcgen),
    .dftpwrup                  (dftpwrup),
    .dftisodisable             (dftisodisable),
    .dftrstdisable             (dftrstdisable[1]),
    .dftretdisable             (dftretdisable)
  );
  
  sse710_integration_example_f0_external_system_aoncrg u_sse710_integration_example_f0_external_system_aoncrg (
    .extsys_fclk                  (extsys_fclk),
    .extsys_aonclk                (extsys_aonclk),
    .extsys_clk                   (extsys_clk),

    .extsys_poresetn              (extsys_poresetn),
    .extsys_cpuwait               (extsys_cpuwait),
    .ppu_devwarmresetn            (ppu_devwarmresetn),

    .extsys_poresetn_s            (extsys_poresetn_s),
    .extsys_core_resetn           (extsys_core_resetn),

    .ppuclk_qreqn                 (ppuclk_qreqn),
    .ppuclk_qacceptn              (ppuclk_qacceptn),
    .ppuclk_qdeny                 (ppuclk_qdeny),
    .ppuclk_qactive               (ppuclk_qactive),

    .sysreg_adb_clk_qreqn         (sysreg_adb_clk_qreqn),
    .sysreg_adb_clk_qacceptn      (sysreg_adb_clk_qacceptn),
    .sysreg_adb_clk_qdeny         (sysreg_adb_clk_qdeny),
    .sysreg_adb_clk_qactive       (sysreg_adb_clk_qactive),
    
    .uart_adb_clk_qreqn           (uart_adb_clk_qreqn),
    .uart_adb_clk_qacceptn        (uart_adb_clk_qacceptn),
    .uart_adb_clk_qdeny           (uart_adb_clk_qdeny),
    .uart_adb_clk_qactive         (uart_adb_clk_qactive),    

    .ppu_adb_clk_qreqn            (ppu_adb_clk_qreqn),
    .ppu_adb_clk_qacceptn         (ppu_adb_clk_qacceptn),
    .ppu_adb_clk_qdeny            (ppu_adb_clk_qdeny),
    .ppu_adb_clk_qactive          (ppu_adb_clk_qactive),

    .lpdp_clk_qactive             (lpdp_clk_qactive),
    .p2q_core_clk_qactive         (p2q_core_clk_qactive),
    .p2q_dbg_clk_qactive          (p2q_dbg_clk_qactive),
    .lpdq_core_clk_qactive        (lpdq_core_clk_qactive),
    .lpdq_dbg_clk_qactive         (lpdq_dbg_clk_qactive),
    .lpdq_systop_clk_qactive      (lpdq_systop_clk_qactive),
    .lpcq_systop_clk_qactive      (lpcq_systop_clk_qactive),
    .lpcq_dbgtop_clk_qactive      (lpcq_dbgtop_clk_qactive),
    .lpcq_aontop_clk_qactive      (lpcq_aontop_clk_qactive),
    .extdbgrom_reqack_clk_qactive (extdbgrom_reqack_clk_qactive),
    .axiaprom_reqack_clk_qactive  (axiaprom_reqack_clk_qactive),
    .cpu_pwrctrl_qactive          (cpu_pwrctrl_qactive),    
    .ppu_devclken                 (ppu_devclken),
    
    .clock_override               (clock_override_aon),
    .resetsyndrome_log_en         (resetsyndrome_log_en),
    .warm_rst_state               (warm_rst_state),

    .mbistreq                      (mbistreq),
    .dftcgen                      (dftcgen),
    .dftrstdisable                (dftrstdisable[0])
  );
  
  assign extsys_dbg_resetn_i  = ppu_devporesetn;
  assign extsys_dbg_resetn    = extsys_dbg_resetn_i;

  assign extsys_mtx_resetn_i  = ppu_devwarmresetn;
  assign extsys_mtx_resetn    = extsys_mtx_resetn_i;
  

  sse710_integration_example_f0_external_system_sysreg u_sse710_integration_example_f0_external_system_sysreg (
    .extsys_aonclk              (extsys_aonclk),
    .extsys_fclk                (extsys_fclk),

    .extsys_poresetn_s          (extsys_poresetn_s),

    .sysreg_pready              (sysreg_pready),
    .sysreg_prdata              (sysreg_prdata),
    .sysreg_pslverr             (sysreg_pslverr),
    .sysreg_paddr               (sysreg_paddr),
    .sysreg_penable             (sysreg_penable),
    .sysreg_pwrite              (sysreg_pwrite),
    .sysreg_pwdata              (sysreg_pwdata),
    .sysreg_psel                (sysreg_psel),

    .sysreset_req_ss            (sysreset_req_ss),
    .resetsyndrome_log_en       (resetsyndrome_log_en),
    .extsys_rstsyn              (extsys_rstsyn),

    .pwrdown_en                 (pwrdown_en),

    .clock_override_extsystop   (clock_override_extsystop),
    .clock_override_aon         (clock_override_aon)
  );


  Uart u_Uart (
    .PCLK              (extsys_fclk),        
    .PRESETn           (extsys_poresetn_s),  
    .PADDR             (uart_paddr[11:2]),   
    .PWDATA            (uart_pwdata[15:0]),  
    .PENABLE           (uart_penable),       
    .PWRITE            (uart_pwrite),        
    .PSEL              (uart_psel),          
    .PRDATA            (uart_prdata[15:0]),  
    .UARTCLK           (extsys_fclk),        
    .nUARTRST          (extsys_poresetn_s),  
    .UARTMSINTR        (),                   
    .UARTRXINTR        (),                   
    .UARTTXINTR        (),                   
    .UARTRTINTR        (),                   
    .UARTEINTR         (),                   
    .UARTINTR          (uart_irq),           
    .UARTTXDMASREQ     (),                   
    .UARTRXDMASREQ     (),                   
    .UARTTXDMABREQ     (),                   
    .UARTRXDMABREQ     (),                   
    .UARTTXDMACLR      (1'b0),               
    .UARTRXDMACLR      (1'b0),               
    .SCANENABLE        (1'b0),               
    .SCANINPCLK        (1'b0),               
    .SCANINUCLK        (1'b0),               
    .SCANOUTPCLK       (),                   
    .SCANOUTUCLK       (),                   
    .nUARTCTS          (nuartcts_ss),        
    .nUARTDCD          (nuartdcd_ss),        
    .nUARTDSR          (nuartdsr_ss),        
    .nUARTRI           (nuartri_ss),         
    .UARTRXD           (uartrxd_ss),         
    .SIRIN             (1'b0),               
    .UARTTXD           (uarttxd),            
    .nSIROUT           (),                   
    .nUARTDTR          (nuartdtr),           
    .nUARTRTS          (nuartrts),           
    .nUARTOut1         (nuartout1),          
    .nUARTOut2         (nuartout2)           
  );
  
  assign uart_prdata[31:16] = 16'h0000;
  
  
  assign uart_pready  = 1'b1;
  assign uart_pslverr = 1'b0;
  


  css600_apbasyncbridgemstr #(
    .APB_ADDR_WIDTH(12),
    .FF_SYNC_DEPTH(2)
  ) u_css600_apbasyncbridgemstr_sysreg (
    .clk_m                      (extsys_aonclk),
    .reset_m_n                  (extsys_poresetn_s),
    .dftcgen                    (dftcgen),
    .psel_m                     (sysreg_psel),
    .penable_m                  (sysreg_penable),
    .paddr_m                    (sysreg_paddr),
    .pwrite_m                   (sysreg_pwrite),
    .pwdata_m                   (sysreg_pwdata),
    .pprot_m                    (),
    .prdata_m                   (sysreg_prdata),
    .pready_m                   (sysreg_pready),
    .pslverr_m                  (sysreg_pslverr),
    .pwakeup_m                  (),
    .clk_m_qreq_n               (sysreg_adb_clk_qreqn),
    .clk_m_qaccept_n            (sysreg_adb_clk_qacceptn),
    .clk_m_qdeny                (sysreg_adb_clk_qdeny),
    .clk_m_qactive              (sysreg_adb_clk_qactive),
    .apb_async_req              (sysreg_apb_async_req),
    .apb_async_req_payload      (sysreg_apb_async_req_payload),
    .apb_async_resp_payload     (sysreg_apb_async_resp_payload),
    .apb_async_ack              (sysreg_apb_async_ack)
  );
  
  css600_apbasyncbridgemstr #(
    .APB_ADDR_WIDTH(12),
    .FF_SYNC_DEPTH(2)
  ) u_css600_apbasyncbridgemstr_uart (
    .clk_m                      (extsys_aonclk),
    .reset_m_n                  (extsys_poresetn_s),
    .dftcgen                    (dftcgen),
    .psel_m                     (uart_psel),
    .penable_m                  (uart_penable),
    .paddr_m                    (uart_paddr),
    .pwrite_m                   (uart_pwrite),
    .pwdata_m                   (uart_pwdata),
    .pprot_m                    (),
    .prdata_m                   (uart_prdata),
    .pready_m                   (uart_pready),
    .pslverr_m                  (uart_pslverr),
    .pwakeup_m                  (),
    .clk_m_qreq_n               (uart_adb_clk_qreqn),
    .clk_m_qaccept_n            (uart_adb_clk_qacceptn),
    .clk_m_qdeny                (uart_adb_clk_qdeny),
    .clk_m_qactive              (uart_adb_clk_qactive),
    .apb_async_req              (uart_apb_async_req),
    .apb_async_req_payload      (uart_apb_async_req_payload),
    .apb_async_resp_payload     (uart_apb_async_resp_payload),
    .apb_async_ack              (uart_apb_async_ack)
  );  
  
  css600_apbasyncbridgemstr #(
    .APB_ADDR_WIDTH(12),
    .FF_SYNC_DEPTH(2)
  ) u_css600_apbasyncbridgemstr_ppu (
    .clk_m                      (extsys_aonclk),
    .reset_m_n                  (extsys_poresetn_s),
    .dftcgen                    (dftcgen),
    .psel_m                     (ppu_adb_psel),
    .penable_m                  (ppu_adb_penable),
    .paddr_m                    (ppu_adb_paddr),
    .pwrite_m                   (ppu_adb_pwrite),
    .pwdata_m                   (ppu_adb_pwdata),
    .pprot_m                    (),
    .prdata_m                   (ppu_adb_prdata),
    .pready_m                   (ppu_adb_pready),
    .pslverr_m                  (ppu_adb_pslverr),
    .pwakeup_m                  (ppu_adb_pwakeup),
    .clk_m_qreq_n               (ppu_adb_clk_qreqn),
    .clk_m_qaccept_n            (ppu_adb_clk_qacceptn),
    .clk_m_qdeny                (ppu_adb_clk_qdeny),
    .clk_m_qactive              (ppu_adb_clk_qactive),
    .apb_async_req              (ppu_apb_async_req),
    .apb_async_req_payload      (ppu_apb_async_req_payload),
    .apb_async_resp_payload     (ppu_apb_async_resp_payload),
    .apb_async_ack              (ppu_apb_async_ack)
  );
  
  
  
  assign decode4bit = (ppu_pwrite & ~ppu_dbgen_ss & (ppu_adb_paddr[11:3] == 9'h004)) ? 4'b0000 : 4'b0001;

  cmsdk_apb_slave_mux #(
    .PORT0_ENABLE   (1), 
    .PORT1_ENABLE   (1), 
    .PORT2_ENABLE   (0),
    .PORT3_ENABLE   (0),
    .PORT4_ENABLE   (0),
    .PORT5_ENABLE   (0), 
    .PORT6_ENABLE   (0),
    .PORT7_ENABLE   (0),
    .PORT8_ENABLE   (0),
    .PORT9_ENABLE   (0),
    .PORT10_ENABLE  (0),
    .PORT11_ENABLE  (0),
    .PORT12_ENABLE  (0),
    .PORT13_ENABLE  (0),
    .PORT14_ENABLE  (0),
    .PORT15_ENABLE  (0)
  ) u_cmsdk_apb_slave_mux (
    .DECODE4BIT     (decode4bit),
    .PSEL           (ppu_adb_psel),
    .PSEL0          (),
    .PREADY0        (1'b1),  
    .PRDATA0        (32'h0),
    .PSLVERR0       (1'b1),
    .PSEL1          (ppu_psel),
    .PREADY1        (ppu_pready),
    .PRDATA1        (ppu_prdata),
    .PSLVERR1       (ppu_pslverr),
    .PSEL2          (),
    .PREADY2        (1'b0),
    .PRDATA2        (32'h0),
    .PSLVERR2       (1'b0),
    .PSEL3          (),
    .PREADY3        (1'b0),
    .PRDATA3        (32'h0),
    .PSLVERR3       (1'b0),
    .PSEL4          (),
    .PREADY4        (1'b0),
    .PRDATA4        (32'h0),
    .PSLVERR4       (1'b0),
    .PSEL5          (),
    .PREADY5        (1'b0),
    .PRDATA5        (32'h0),
    .PSLVERR5       (1'b0),
    .PSEL6          (),
    .PREADY6        (1'b0),
    .PRDATA6        (32'h0),
    .PSLVERR6       (1'b0),
    .PSEL7          (),
    .PREADY7        (1'b0),
    .PRDATA7        (32'h0),
    .PSLVERR7       (1'b0),
    .PSEL8          (),
    .PREADY8        (1'b0),
    .PRDATA8        (32'h0),
    .PSLVERR8       (1'b0),
    .PSEL9          (),
    .PREADY9        (1'b0),
    .PRDATA9        (32'h0),
    .PSLVERR9       (1'b0),
    .PSEL10         (),
    .PREADY10       (1'b0),
    .PRDATA10       (32'h0),
    .PSLVERR10      (1'b0),
    .PSEL11         (),
    .PREADY11       (1'b0),
    .PRDATA11       (32'h0),
    .PSLVERR11      (1'b0),
    .PSEL12         (),
    .PREADY12       (1'b0),
    .PRDATA12       (32'h0),
    .PSLVERR12      (1'b0),
    .PSEL13         (),
    .PREADY13       (1'b0),
    .PRDATA13       (32'h0),
    .PSLVERR13      (1'b0),
    .PSEL14         (),
    .PREADY14       (1'b0),
    .PRDATA14       (32'h0),
    .PSLVERR14      (1'b0),
    .PSEL15         (),
    .PREADY15       (1'b0),
    .PRDATA15       (32'h0),
    .PSLVERR15      (1'b0),
    .PREADY         (ppu_adb_pready),
    .PRDATA         (ppu_adb_prdata),
    .PSLVERR        (ppu_adb_pslverr)
  );
  
  assign ppu_paddr   = ppu_adb_paddr;
  assign ppu_pwdata  = ppu_adb_pwdata;
  assign ppu_penable = ppu_adb_penable;
  assign ppu_pwrite  = ppu_adb_pwrite;  
  assign ppu_pwakeup = ppu_adb_pwakeup;  


  arm_element_cdc_capt_sync   u_arm_element_cdc_capt_sync_0   (
    .clk     (extsys_fclk),
    .nreset  (extsys_poresetn_s),
    .d_async (sleeping),
    .q       (sleeping_ss)
  );
  
  arm_element_cdc_capt_sync   u_arm_element_cdc_capt_sync_1   (
    .clk     (extsys_fclk),
    .nreset  (extsys_poresetn_s),
    .d_async (sleep_hold_ackn),
    .q       (sleep_hold_ackn_ss)
  );  
  
  arm_element_cdc_capt_sync   u_arm_element_cdc_capt_sync_2   (
    .clk     (extsys_fclk),
    .nreset  (extsys_poresetn_s),
    .d_async (sysreset_req),
    .q       (sysreset_req_ss)
  ); 
  
  arm_element_cdc_capt_sync   u_arm_element_cdc_capt_sync_3   (
    .clk     (extsys_fclk),
    .nreset  (extsys_poresetn_s),
    .d_async (ppu_dbgen),
    .q       (ppu_dbgen_ss)
  );  
  
  arm_element_cdc_capt_sync   u_arm_element_cdc_capt_sync_4   (
    .clk     (extsys_fclk),
    .nreset  (extsys_poresetn_s),
    .d_async (nuartcts),
    .q       (nuartcts_ss)
  );   

  arm_element_cdc_capt_sync   u_arm_element_cdc_capt_sync_5   (
    .clk     (extsys_fclk),
    .nreset  (extsys_poresetn_s),
    .d_async (nuartdcd),
    .q       (nuartdcd_ss)
  );
  
  arm_element_cdc_capt_sync   u_arm_element_cdc_capt_sync_6   (
    .clk     (extsys_fclk),
    .nreset  (extsys_poresetn_s),
    .d_async (nuartdsr),
    .q       (nuartdsr_ss)
  );

  arm_element_cdc_capt_sync   u_arm_element_cdc_capt_sync_7   (
    .clk     (extsys_fclk),
    .nreset  (extsys_poresetn_s),
    .d_async (nuartri),
    .q       (nuartri_ss)
  );

  arm_element_cdc_capt_sync   u_arm_element_cdc_capt_sync_8   (
    .clk     (extsys_fclk),
    .nreset  (extsys_poresetn_s),
    .d_async (uartrxd),
    .q       (uartrxd_ss)
  );  


  assign extsys_dbgpresetsn = extsys_mtx_resetn_i;
  assign extsys_dbgpresetmn = extsys_dbg_resetn_i;
  assign extsys_atresetn    = extsys_dbg_resetn_i;
  assign extsys_ctiresetn   = extsys_dbg_resetn_i;
  assign extsys_aresetn     = extsys_mtx_resetn_i;
  assign extsys_mhuresetn   = extsys_mtx_resetn_i;

  
  assign unused = |{uart_paddr[1:0],
                   uart_pwdata[31:16]};

endmodule
