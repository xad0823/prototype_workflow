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

module sse710_integration_example_f0_external_system_core #(
  
    parameter             MEM_DATA_WIDTH = 64 
  
  )(

    input  wire           extsys_clk,
    output wire           extsys_dbgclks,
    output wire           extsys_dbgclkm,
    output wire           extsys_atclk,
    output wire           extsys_cticlk,
    output wire           extsys_aclk,
    output wire           extsys_mhuclk,

    input  wire           extsys_mtx_resetn,
    input  wire           extsys_core_resetn,
    input  wire           extsys_dbg_resetn,  

    output wire           aclk_qreqn,
    input  wire           aclk_qacceptn,
    input  wire           aclk_qdeny,
    input  wire           aclk_qactive,

    output wire           mhuclk_qreqn,
    input  wire           mhuclk_qacceptn,
    input  wire           mhuclk_qdeny,
    input  wire           mhuclk_qactive,

    output wire           atclk_qreqn,
    input  wire           atclk_qacceptn,
    input  wire           atclk_qdeny,
    input  wire           atclk_qactive,

    output wire           dbgclkm_qreqn,
    input  wire           dbgclkm_qacceptn,
    input  wire           dbgclkm_qdeny,
    input  wire           dbgclkm_qactive,

    output wire           dbgclks_qreqn,
    input  wire           dbgclks_qacceptn,
    input  wire           dbgclks_qdeny,
    input  wire           dbgclks_qactive,

    output wire           cticlk_qreqn,
    input  wire           cticlk_qacceptn,
    input  wire           cticlk_qdeny,
    input  wire           cticlk_qactive,

    output wire           mem_awakeup,
    output wire           mem_awid,
    output wire [31:0]    mem_awaddr,
    output wire [7:0]     mem_awlen,
    output wire [2:0]     mem_awsize,
    output wire [1:0]     mem_awburst,
    output wire           mem_awlock,
    output wire [3:0]     mem_awcache,
    output wire [2:0]     mem_awprot,    
    output wire           mem_awvalid,
    input  wire           mem_awready,

    output wire [(MEM_DATA_WIDTH/8)-1:0]     mem_wstrb,
    output wire           mem_wlast,
    output wire           mem_wvalid,
    output wire [MEM_DATA_WIDTH-1:0]    mem_wdata,
    input  wire           mem_wready,

    input  wire           mem_bid,
    input  wire [1:0]     mem_bresp,
    input  wire           mem_bvalid,
    output wire           mem_bready,

    output wire           mem_arid,
    output wire [31:0]    mem_araddr,
    output wire [7:0]     mem_arlen,
    output wire [2:0]     mem_arsize,
    output wire [1:0]     mem_arburst,
    output wire           mem_arlock,
    output wire [3:0]     mem_arcache,
    output wire [2:0]     mem_arprot,     
    output wire           mem_arvalid,
    input  wire           mem_arready,

    input  wire           mem_rid,
    input  wire [1:0]     mem_rresp,
    input  wire           mem_rlast,
    input  wire           mem_rvalid,
    input  wire [MEM_DATA_WIDTH-1:0]    mem_rdata,
    output wire           mem_rready,

    output wire           sysreg_apb_async_req,
    output wire [47:0]    sysreg_apb_async_req_payload,
    input  wire [32:0]    sysreg_apb_async_resp_payload,
    input  wire           sysreg_apb_async_ack,
    
    output wire           uart_apb_async_req,
    output wire [47:0]    uart_apb_async_req_payload,
    input  wire [32:0]    uart_apb_async_resp_payload,
    input  wire           uart_apb_async_ack,    

    output wire           mhu_psel,
    output wire           mhu_pwakeup,
    output wire           mhu_penable,
    output wire [18:0]    mhu_paddr,
    output wire           mhu_pwrite,
    output wire [31:0]    mhu_pwdata,
    output wire [3:0]     mhu_pstrb,
    output wire [2:0]     mhu_pprot,
    input  wire [31:0]    mhu_prdata,
    input  wire           mhu_pready,
    input  wire           mhu_pslverr,

    input  wire           dbg_dpabort,
    input  wire           dbg_psel,    
    input  wire           dbg_penable, 
    input  wire           dbg_pwrite,  
    input  wire [31:0]    dbg_paddr,   
    input  wire [31:0]    dbg_pwdata,  
    output wire           dbg_pready,  
    output wire           dbg_pslverr, 
    output wire  [31:0]   dbg_prdata,   

    output wire           extdbg_psel,
    output wire           extdbg_pwakeup,
    output wire           extdbg_penable,
    output wire [31:0]    extdbg_paddr,
    output wire           extdbg_pwrite,
    output wire [31:0]    extdbg_pwdata,
    output wire [3:0]     extdbg_pstrb,
    output wire [2:0]     extdbg_pprot,
    input  wire [31:0]    extdbg_prdata,
    input  wire           extdbg_pready,
    input  wire           extdbg_pslverr,

    input  wire           slvmustacceptreqn_async,
    input  wire           slvcandenyreqn_async,
    output wire           slvacceptn_async,
    output wire           slvdeny_async,

    input  wire           si_to_mi_wakeup_async,
    output wire           mi_to_si_wakeup_async,

    input  wire [3:0]     aw_wr_ptr_async,
    output wire [3:0]     aw_rd_ptr_async,
    input  wire [315:0]   aw_payld_async,
                       
    input  wire [5:0]     w_wr_ptr_async,
    output wire [5:0]     w_rd_ptr_async,
    input  wire [221:0]   w_payld_async,
                       
    output wire [1:0]     b_wr_ptr_async,
    input  wire [1:0]     b_rd_ptr_async,
    output wire [39:0]    b_payld_async,
                       
    input  wire [3:0]     ar_wr_ptr_async,
    output wire [3:0]     ar_rd_ptr_async,
    input  wire [315:0]   ar_payld_async,
                       
    output wire [3:0]     r_wr_ptr_async,
    input  wire [3:0]     r_rd_ptr_async,
    output wire [211:0]   r_payld_async,

    input  wire           extdbgrom_cdbgpwrupack_ss,
    input  wire           axiaprom_csyspwrupack_ss,

    input  wire           hes_mhu0_comb_int,
    input  wire           esh_mhu0_comb_int,
    input  wire           hes_mhu1_comb_int,
    input  wire           esh_mhu1_comb_int,
    input  wire           sees_mhu0_comb_int,
    input  wire           esse_mhu0_comb_int,
    input  wire           sees_mhu1_comb_int,
    input  wire           esse_mhu1_comb_int,    
    input  wire [42:0]    extsys_shdint,    

    output wire           wdog_lockup_irq,

    output wire           sleeping,
    output wire           sleep_hold_ackn,
    output wire           sysreset_req,

    input  wire           sleep_hold_reqn,

    input  wire [8:0]     clock_override_extsystop,
    
    input  wire           traceexp_atready,
    input  wire           traceexp_afvalid,
    input  wire           traceexp_syncreq,
    output wire [6:0]     traceexp_atid,
    output wire           traceexp_atvalid,
    output wire [31:0]    traceexp_atdata,
    output wire [1:0]     traceexp_atbytes,
    output wire           traceexp_afready,
    output wire           traceexp_atwakeup,
    
    input  wire           dbgen,
    input  wire           niden,
    input  wire           chen,
    input  wire           dapen,
    
    input  wire [3:0]     ctichin,
    output wire [3:0]     ctichout,
    
    input  wire           uart_irq,
    
    input  wire [3:0]     nts_wr_ptr_encd_gry,
    output wire [3:0]     nts_rd_ptr_encd_gry,
    input  wire [3:0]     nts_wr_ptr_sync_gry,
    output wire [3:0]     nts_rd_ptr_sync_gry,
    input  wire [53:0]    nts_fw_data,
    input  wire           nts_s_lp,
    output wire           nts_s_lp_return,
    output wire           nts_m_lp,    
    
    input  wire           mbistreq,
    input  wire           dftcgen,
    input  wire [1:0]     dftrstdisable,
    input  wire           dftse,
    input  wire           dftramhold
  );


  wire            extsys_hclk;
  wire            extsys_dclk;
  wire            extsys_timer0pclkg;
  wire            extsys_timer1pclkg;
  
  wire            extsys_mtx_resetn_s;
  wire            extsys_core_resetn_s;
  wire            extsys_dbg_resetn_s; 

  wire            targflash0_hsel;
  wire [31:0]     targflash0_haddr;
  wire [1:0]      targflash0_htrans;
  wire            targflash0_hwrite;
  wire [2:0]      targflash0_hsize;
  wire [2:0]      targflash0_hburst;
  wire [3:0]      targflash0_hprot;
  wire [1:0]      targflash0_memattr;
  wire            targflash0_exreq;
  wire [3:0]      targflash0_hmaster;
  wire [31:0]     targflash0_hwdata;
  wire            targflash0_hmastlock;
  wire            targflash0_hreadymux;
  wire            targflash0_hauser;
  wire [3:0]      targflash0_hwuser;
  wire [31:0]     targflash0_hrdata;
  wire            targflash0_hreadyout;
  wire            targflash0_hresp;
  wire            targflash0_exresp;
  wire [2:0]      targflash0_hruser;

  wire            targexp0_hsel;
  wire [31:0]     targexp0_haddr;
  wire  [1:0]     targexp0_htrans;
  wire            targexp0_hwrite;
  wire  [2:0]     targexp0_hsize;
  wire  [2:0]     targexp0_hburst;
  wire  [3:0]     targexp0_hprot;
  wire  [1:0]     targexp0_memattr;
  wire            targexp0_exreq;
  wire  [3:0]     targexp0_hmaster;
  wire [31:0]     targexp0_hwdata;
  wire            targexp0_hmastlock;
  wire            targexp0_hreadymux;
  wire            targexp0_hauser;
  wire  [3:0]     targexp0_hwuser;
  wire [31:0]     targexp0_hrdata;
  wire            targexp0_hreadyout;
  wire            targexp0_hresp;
  wire            targexp0_exresp;
  wire  [2:0]     targexp0_hruser;

  wire            targexp1_hsel;
  wire [31:0]     targexp1_haddr;
  wire  [1:0]     targexp1_htrans;
  wire            targexp1_hwrite;
  wire  [2:0]     targexp1_hsize;
  wire  [2:0]     targexp1_hburst;
  wire  [3:0]     targexp1_hprot;
  wire  [1:0]     targexp1_memattr;
  wire            targexp1_exreq;
  wire  [3:0]     targexp1_hmaster;
  wire [31:0]     targexp1_hwdata;
  wire            targexp1_hmastlock;
  wire            targexp1_hreadymux;
  wire            targexp1_hauser;
  wire  [3:0]     targexp1_hwuser;
  wire [31:0]     targexp1_hrdata;
  wire            targexp1_hreadyout;
  wire            targexp1_hresp;
  wire            targexp1_exresp;
  wire  [2:0]     targexp1_hruser;

  wire            initexp0_hsel;
  wire [31:0]     initexp0_haddr;
  wire  [1:0]     initexp0_htrans;
  wire            initexp0_hwrite;
  wire  [2:0]     initexp0_hsize;
  wire  [2:0]     initexp0_hburst;
  wire  [3:0]     initexp0_hprot;
  wire  [1:0]     initexp0_memattr;
  wire            initexp0_exreq;
  wire  [3:0]     initexp0_hmaster;
  wire [31:0]     initexp0_hwdata;
  wire            initexp0_hmastlock;
  wire            initexp0_hauser;
  wire  [3:0]     initexp0_hwuser;
  wire [31:0]     initexp0_hrdata;
  wire            initexp0_hready;
  wire            initexp0_hresp;
  wire            initexp0_exresp;
  wire  [2:0]     initexp0_hruser;

  wire            apbtargexp2_psel;
  wire            apbtargexp2_penable;
  wire [11:0]     apbtargexp2_paddr;
  wire            apbtargexp2_pwrite;
  wire [31:0]     apbtargexp2_pwdata;
  wire [31:0]     apbtargexp2_prdata;
  wire            apbtargexp2_pready;
  wire            apbtargexp2_pslverr;
  wire [3:0]      apbtargexp2_pstrb;
  wire [2:0]      apbtargexp2_pprot;  

  wire            apbtargexp3_psel;
  wire            apbtargexp3_penable;
  wire [11:0]     apbtargexp3_paddr;
  wire            apbtargexp3_pwrite;
  wire [31:0]     apbtargexp3_pwdata;
  wire [31:0]     apbtargexp3_prdata;
  wire            apbtargexp3_pready;
  wire            apbtargexp3_pslverr;
  wire [3:0]      apbtargexp3_pstrb;
  wire [2:0]      apbtargexp3_pprot;

  wire            apbtargexp9_psel;
  wire            apbtargexp9_penable;
  wire [11:0]     apbtargexp9_paddr;
  wire            apbtargexp9_pwrite;
  wire [31:0]     apbtargexp9_pwdata;
  wire [31:0]     apbtargexp9_prdata;
  wire            apbtargexp9_pready;
  wire            apbtargexp9_pslverr;
  wire [3:0]      apbtargexp9_pstrb;
  wire [2:0]      apbtargexp9_pprot;
  
  wire            apbtargexp10_psel;
  wire            apbtargexp10_penable;
  wire [11:0]     apbtargexp10_paddr;
  wire            apbtargexp10_pwrite;
  wire [31:0]     apbtargexp10_pwdata;
  wire [31:0]     apbtargexp10_prdata;
  wire            apbtargexp10_pready;
  wire            apbtargexp10_pslverr;
  wire [3:0]      apbtargexp10_pstrb;
  wire [2:0]      apbtargexp10_pprot;
  
  wire            apbtargexp8_psel;
  wire            apbtargexp8_penable;
  wire [11:0]     apbtargexp8_paddr;
  wire            apbtargexp8_pwrite;
  wire [31:0]     apbtargexp8_pwdata;
  wire [31:0]     apbtargexp8_prdata;
  wire            apbtargexp8_pready;
  wire            apbtargexp8_pslverr;
  wire [3:0]      apbtargexp8_pstrb;
  wire [2:0]      apbtargexp8_pprot;

  wire            apbtargexp11_psel;
  wire            apbtargexp11_penable;
  wire [11:0]     apbtargexp11_paddr;
  wire            apbtargexp11_pwrite;
  wire [31:0]     apbtargexp11_pwdata;
  wire [31:0]     apbtargexp11_prdata;
  wire            apbtargexp11_pready;
  wire            apbtargexp11_pslverr;
  wire [3:0]      apbtargexp11_pstrb;
  wire [2:0]      apbtargexp11_pprot;

  wire [31:0]     sram0_rdata;
  wire [12:0]     sram0_addr;
  wire [3:0]      sram0_wren;
  wire [31:0]     sram0_wdata;
  wire            sram0_cs;

  wire            wdog_clken;
  wire            halted;
  wire            timer0pclk_qactive;
  wire            timer1pclk_qactive;
  wire            timer1_extin;
  wire            timer0_extin;

  wire            expclk_qreqn;
  wire            expclk_qacceptn;
  wire            expclk_qdeny;
  wire            expclk_qactive;
  
  wire            hxb_clk_qreqn;
  wire            hxb_clk_qacceptn;
  wire            hxb_clk_qdeny;
  wire            hxb_clk_qactive;  

  wire            cpu_dbg_psel;   
  wire            cpu_dbg_pready;  
  wire            cpu_dbg_pslverr; 
  wire [31:0]     cpu_dbg_prdata;  
    
  wire            etm_atready;
  wire [6:0]      etm_atid;
  wire            etm_atvalid;
  wire [7:0]      etm_atdata;
  wire            etm_atbytes;
  wire            etm_afready;

  wire            itm_atready;
  wire [6:0]      itm_atid;
  wire            itm_atvalid;
  wire [7:0]      itm_atdata;
  wire            itm_atbytes;
  wire            itm_afready;
  
  wire [3:0]      ctichin_int;
  wire [3:0]      ctichout_int;  
 
  wire [47:0]     tsvalueb;
  
  wire            intnmi;
  wire  [239:0]   intisr;
  wire            timer0_timerint;
  wire            timer1_timerint; 
  wire            wdog_int;
  wire            wdog_res;
  reg             wdog_res_r;
  wire            lockup;
  wire  [42:0]    extsys_shdint_ss;
  wire            hxb_err_irq;
  
  wire           dbgen_ss;
  wire           niden_ss;
  wire           chen_ss;
  wire           dapen_ss;


  sse710_integration_example_f0_example_m_system_top #(
  .NUM_IRQ         (52),
  .LVL_WIDTH       (3),
  .WIC_LINES       (55),
  .WIC_PRESENT     (1),
  .BB_PRESENT      (1),
  .MPU_PRESENT     (1),
  .TRACE_LVL       (2),
  .DEBUG_LVL       (3),
  .CLKGATE_PRESENT (0),
  .RESET_ALL_REGS  (0),
  .OBSERVATION     (0),
  .ETM_PRESENT     (1),
  .EXTRA_ROM_ENTRY (32'h0000_0000)
)
  u_sse710_integration_example_f0_example_m_system_top (
    .CPU0FCLK                       (extsys_clk),
    .CPU0HCLK                       (extsys_hclk),

    .CPU0DAPCLK                     (extsys_dclk),
    .CPU0DAPRESETn                  (extsys_dbg_resetn_s),

    .CPU0CTICLK                     (extsys_dclk),
    .CPU0CTIRESETn                  (extsys_dbg_resetn_s),

    .CPU0PORESETn                   (extsys_dbg_resetn_s),
    .CPU0SYSRESETn                  (extsys_core_resetn_s),

    .CPU0STCLK                      (1'b0),
    .CPU0STCALIB                    (26'h21E_8480), 

    .SRAM0HCLK                      (extsys_hclk),
    .SRAM1HCLK                      (1'b0),
    .SRAM2HCLK                      (1'b0),
    .SRAM3HCLK                      (1'b0),

    .MTXHCLK                        (extsys_hclk),
    .MTXHRESETn                     (extsys_mtx_resetn_s),

    .AHB2APBHCLK                    (extsys_hclk),
    .TIMER0PCLK                     (extsys_clk),
    .TIMER0PCLKG                    (extsys_timer0pclkg),
    .TIMER0PRESETn                  (extsys_mtx_resetn_s),
    .TIMER1PCLK                     (extsys_clk),
    .TIMER1PCLKG                    (extsys_timer1pclkg),
    .TIMER1PRESETn                  (extsys_mtx_resetn_s),

    .SRAM0RDATA                     (sram0_rdata),
    .SRAM0ADDR                      (sram0_addr),
    .SRAM0WREN                      (sram0_wren),
    .SRAM0WDATA                     (sram0_wdata),
    .SRAM0CS                        (sram0_cs),

    .SRAM1RDATA                     (32'h0000_0000),
    .SRAM1ADDR                      (),
    .SRAM1WREN                      (),
    .SRAM1WDATA                     (),
    .SRAM1CS                        (),

    .SRAM2RDATA                     (32'h0000_0000),
    .SRAM2ADDR                      (),
    .SRAM2WREN                      (),
    .SRAM2WDATA                     (),
    .SRAM2CS                        (),

    .SRAM3RDATA                     (32'h0000_0000),
    .SRAM3ADDR                      (),
    .SRAM3WREN                      (),
    .SRAM3WDATA                     (),
    .SRAM3CS                        (),

    .TIMER0EXTIN                    (timer0_extin),
    .TIMER0PRIVMODEN                (1'b1), 

    .TIMER1EXTIN                    (timer1_extin),
    .TIMER1PRIVMODEN                (1'b1), 

    .TIMER0TIMERINT                 (timer0_timerint),
    .TIMER1TIMERINT                 (timer1_timerint),

    .TARGFLASH0HSEL                 (targflash0_hsel),
    .TARGFLASH0HADDR                (targflash0_haddr),
    .TARGFLASH0HTRANS               (targflash0_htrans),
    .TARGFLASH0HWRITE               (targflash0_hwrite),
    .TARGFLASH0HSIZE                (targflash0_hsize),
    .TARGFLASH0HBURST               (targflash0_hburst),
    .TARGFLASH0HPROT                (targflash0_hprot),
    .TARGFLASH0MEMATTR              (targflash0_memattr),
    .TARGFLASH0EXREQ                (targflash0_exreq),
    .TARGFLASH0HMASTER              (targflash0_hmaster),
    .TARGFLASH0HWDATA               (targflash0_hwdata),
    .TARGFLASH0HMASTLOCK            (targflash0_hmastlock),
    .TARGFLASH0HREADYMUX            (targflash0_hreadymux),
    .TARGFLASH0HAUSER               (targflash0_hauser),
    .TARGFLASH0HWUSER               (targflash0_hwuser),
    .TARGFLASH0HRDATA               (targflash0_hrdata),
    .TARGFLASH0HREADYOUT            (targflash0_hreadyout),
    .TARGFLASH0HRESP                (targflash0_hresp),
    .TARGFLASH0EXRESP               (targflash0_exresp),
    .TARGFLASH0HRUSER               (targflash0_hruser),

    .TARGEXP0HSEL                   (targexp0_hsel),
    .TARGEXP0HADDR                  (targexp0_haddr),
    .TARGEXP0HTRANS                 (targexp0_htrans),
    .TARGEXP0HWRITE                 (targexp0_hwrite),
    .TARGEXP0HSIZE                  (targexp0_hsize),
    .TARGEXP0HBURST                 (targexp0_hburst),
    .TARGEXP0HPROT                  (targexp0_hprot),
    .TARGEXP0MEMATTR                (targexp0_memattr),
    .TARGEXP0EXREQ                  (targexp0_exreq),
    .TARGEXP0HMASTER                (targexp0_hmaster),
    .TARGEXP0HWDATA                 (targexp0_hwdata),
    .TARGEXP0HMASTLOCK              (targexp0_hmastlock),
    .TARGEXP0HREADYMUX              (targexp0_hreadymux),
    .TARGEXP0HAUSER                 (targexp0_hauser),
    .TARGEXP0HWUSER                 (targexp0_hwuser),
    .TARGEXP0HRDATA                 (targexp0_hrdata),
    .TARGEXP0HREADYOUT              (targexp0_hreadyout),
    .TARGEXP0HRESP                  (targexp0_hresp),
    .TARGEXP0EXRESP                 (targexp0_exresp),
    .TARGEXP0HRUSER                 (targexp0_hruser),

    .TARGEXP1HSEL                   (targexp1_hsel),
    .TARGEXP1HADDR                  (targexp1_haddr),
    .TARGEXP1HTRANS                 (targexp1_htrans),
    .TARGEXP1HWRITE                 (targexp1_hwrite),
    .TARGEXP1HSIZE                  (targexp1_hsize),
    .TARGEXP1HBURST                 (targexp1_hburst),
    .TARGEXP1HPROT                  (targexp1_hprot),
    .TARGEXP1MEMATTR                (targexp1_memattr),
    .TARGEXP1EXREQ                  (targexp1_exreq),
    .TARGEXP1HMASTER                (targexp1_hmaster),
    .TARGEXP1HWDATA                 (targexp1_hwdata),
    .TARGEXP1HMASTLOCK              (targexp1_hmastlock),
    .TARGEXP1HREADYMUX              (targexp1_hreadymux),
    .TARGEXP1HAUSER                 (targexp1_hauser),
    .TARGEXP1HWUSER                 (targexp1_hwuser),
    .TARGEXP1HRDATA                 (targexp1_hrdata),
    .TARGEXP1HREADYOUT              (targexp1_hreadyout),
    .TARGEXP1HRESP                  (targexp1_hresp),
    .TARGEXP1EXRESP                 (targexp1_exresp),
    .TARGEXP1HRUSER                 (targexp1_hruser),

    .INITEXP0HSEL                   (initexp0_hsel),
    .INITEXP0HADDR                  (initexp0_haddr),
    .INITEXP0HTRANS                 (initexp0_htrans),
    .INITEXP0HWRITE                 (initexp0_hwrite),
    .INITEXP0HSIZE                  (initexp0_hsize),
    .INITEXP0HBURST                 (initexp0_hburst),
    .INITEXP0HPROT                  (initexp0_hprot),
    .INITEXP0MEMATTR                (initexp0_memattr),
    .INITEXP0EXREQ                  (initexp0_exreq),
    .INITEXP0HMASTER                (initexp0_hmaster),
    .INITEXP0HWDATA                 (initexp0_hwdata),
    .INITEXP0HMASTLOCK              (initexp0_hmastlock),
    .INITEXP0HAUSER                 (initexp0_hauser),
    .INITEXP0HWUSER                 (initexp0_hwuser),
    .INITEXP0HRDATA                 (initexp0_hrdata),
    .INITEXP0HREADY                 (initexp0_hready),
    .INITEXP0HRESP                  (initexp0_hresp),
    .INITEXP0EXRESP                 (initexp0_exresp),
    .INITEXP0HRUSER                 (initexp0_hruser),

    .INITEXP1HSEL                   (1'b0),
    .INITEXP1HADDR                  (32'h0000_0000),
    .INITEXP1HTRANS                 (2'b00),
    .INITEXP1HWRITE                 (1'b0),
    .INITEXP1HSIZE                  (3'b000),
    .INITEXP1HBURST                 (3'b000),
    .INITEXP1HPROT                  (4'h0),
    .INITEXP1MEMATTR                (2'b00),
    .INITEXP1EXREQ                  (1'b0),
    .INITEXP1HMASTER                (4'h0),
    .INITEXP1HWDATA                 (32'h0000_0000),
    .INITEXP1HMASTLOCK              (1'b0),
    .INITEXP1HAUSER                 (1'b0),
    .INITEXP1HWUSER                 (4'b0000),
    .INITEXP1HRDATA                 (),
    .INITEXP1HREADY                 (),
    .INITEXP1HRESP                  (),
    .INITEXP1EXRESP                 (),
    .INITEXP1HRUSER                 (),

    .APBTARGEXP2PSEL                (apbtargexp2_psel),
    .APBTARGEXP2PENABLE             (apbtargexp2_penable),
    .APBTARGEXP2PADDR               (apbtargexp2_paddr),
    .APBTARGEXP2PWRITE              (apbtargexp2_pwrite),
    .APBTARGEXP2PWDATA              (apbtargexp2_pwdata),
    .APBTARGEXP2PRDATA              (apbtargexp2_prdata),
    .APBTARGEXP2PREADY              (apbtargexp2_pready),
    .APBTARGEXP2PSLVERR             (apbtargexp2_pslverr),
    .APBTARGEXP2PSTRB               (apbtargexp2_pstrb),
    .APBTARGEXP2PPROT               (apbtargexp2_pprot),

    .APBTARGEXP3PSEL                (apbtargexp3_psel),
    .APBTARGEXP3PENABLE             (apbtargexp3_penable),
    .APBTARGEXP3PADDR               (apbtargexp3_paddr),
    .APBTARGEXP3PWRITE              (apbtargexp3_pwrite),
    .APBTARGEXP3PWDATA              (apbtargexp3_pwdata),
    .APBTARGEXP3PRDATA              (apbtargexp3_prdata),
    .APBTARGEXP3PREADY              (apbtargexp3_pready),
    .APBTARGEXP3PSLVERR             (apbtargexp3_pslverr),
    .APBTARGEXP3PSTRB               (apbtargexp3_pstrb),
    .APBTARGEXP3PPROT               (apbtargexp3_pprot),

    .APBTARGEXP4PSEL                (),
    .APBTARGEXP4PENABLE             (),
    .APBTARGEXP4PADDR               (),
    .APBTARGEXP4PWRITE              (),
    .APBTARGEXP4PWDATA              (),
    .APBTARGEXP4PRDATA              (32'h0000_0000),
    .APBTARGEXP4PREADY              (1'b1),
    .APBTARGEXP4PSLVERR             (1'b0),
    .APBTARGEXP4PSTRB               (),
    .APBTARGEXP4PPROT               (),

    .APBTARGEXP5PSEL                (),
    .APBTARGEXP5PENABLE             (),
    .APBTARGEXP5PADDR               (),
    .APBTARGEXP5PWRITE              (),
    .APBTARGEXP5PWDATA              (),
    .APBTARGEXP5PRDATA              (32'h0000_0000),
    .APBTARGEXP5PREADY              (1'b1),
    .APBTARGEXP5PSLVERR             (1'b0),
    .APBTARGEXP5PSTRB               (),
    .APBTARGEXP5PPROT               (),

    .APBTARGEXP6PSEL                (),
    .APBTARGEXP6PENABLE             (),
    .APBTARGEXP6PADDR               (),
    .APBTARGEXP6PWRITE              (),
    .APBTARGEXP6PWDATA              (),
    .APBTARGEXP6PRDATA              (32'h0000_0000),
    .APBTARGEXP6PREADY              (1'b1),
    .APBTARGEXP6PSLVERR             (1'b0),
    .APBTARGEXP6PSTRB               (),
    .APBTARGEXP6PPROT               (),

    .APBTARGEXP7PSEL                (),
    .APBTARGEXP7PENABLE             (),
    .APBTARGEXP7PADDR               (),
    .APBTARGEXP7PWRITE              (),
    .APBTARGEXP7PWDATA              (),
    .APBTARGEXP7PRDATA              (32'h0000_0000),
    .APBTARGEXP7PREADY              (1'b1),
    .APBTARGEXP7PSLVERR             (1'b0),
    .APBTARGEXP7PSTRB               (),
    .APBTARGEXP7PPROT               (),

    .APBTARGEXP8PSEL                (apbtargexp8_psel),
    .APBTARGEXP8PENABLE             (apbtargexp8_penable),
    .APBTARGEXP8PADDR               (apbtargexp8_paddr),
    .APBTARGEXP8PWRITE              (apbtargexp8_pwrite),
    .APBTARGEXP8PWDATA              (apbtargexp8_pwdata),
    .APBTARGEXP8PRDATA              (apbtargexp8_prdata),
    .APBTARGEXP8PREADY              (apbtargexp8_pready),
    .APBTARGEXP8PSLVERR             (apbtargexp8_pslverr),
    .APBTARGEXP8PSTRB               (apbtargexp8_pstrb),
    .APBTARGEXP8PPROT               (apbtargexp8_pprot),

    .APBTARGEXP9PSEL                (apbtargexp9_psel),
    .APBTARGEXP9PENABLE             (apbtargexp9_penable),
    .APBTARGEXP9PADDR               (apbtargexp9_paddr),
    .APBTARGEXP9PWRITE              (apbtargexp9_pwrite),
    .APBTARGEXP9PWDATA              (apbtargexp9_pwdata),
    .APBTARGEXP9PRDATA              (apbtargexp9_prdata),
    .APBTARGEXP9PREADY              (apbtargexp9_pready),
    .APBTARGEXP9PSLVERR             (apbtargexp9_pslverr),
    .APBTARGEXP9PSTRB               (apbtargexp9_pstrb),
    .APBTARGEXP9PPROT               (apbtargexp9_pprot),

    .APBTARGEXP10PSEL               (apbtargexp10_psel),
    .APBTARGEXP10PENABLE            (apbtargexp10_penable),
    .APBTARGEXP10PADDR              (apbtargexp10_paddr),
    .APBTARGEXP10PWRITE             (apbtargexp10_pwrite),
    .APBTARGEXP10PWDATA             (apbtargexp10_pwdata),
    .APBTARGEXP10PRDATA             (apbtargexp10_prdata),
    .APBTARGEXP10PREADY             (apbtargexp10_pready),
    .APBTARGEXP10PSLVERR            (apbtargexp10_pslverr),
    .APBTARGEXP10PSTRB              (apbtargexp10_pstrb),
    .APBTARGEXP10PPROT              (apbtargexp10_pprot),

    .APBTARGEXP11PSEL               (apbtargexp11_psel),
    .APBTARGEXP11PENABLE            (apbtargexp11_penable),
    .APBTARGEXP11PADDR              (apbtargexp11_paddr),
    .APBTARGEXP11PWRITE             (apbtargexp11_pwrite),
    .APBTARGEXP11PWDATA             (apbtargexp11_pwdata),
    .APBTARGEXP11PRDATA             (apbtargexp11_prdata),
    .APBTARGEXP11PREADY             (apbtargexp11_pready),
    .APBTARGEXP11PSLVERR            (apbtargexp11_pslverr),
    .APBTARGEXP11PSTRB              (apbtargexp11_pstrb),
    .APBTARGEXP11PPROT              (apbtargexp11_pprot),

    .APBTARGEXP12PSEL               (),
    .APBTARGEXP12PENABLE            (),
    .APBTARGEXP12PADDR              (),
    .APBTARGEXP12PWRITE             (),
    .APBTARGEXP12PWDATA             (),
    .APBTARGEXP12PRDATA             (32'h0000_0000),
    .APBTARGEXP12PREADY             (1'b1),
    .APBTARGEXP12PSLVERR            (1'b0),
    .APBTARGEXP12PSTRB              (),
    .APBTARGEXP12PPROT              (),

    .APBTARGEXP13PSEL               (),
    .APBTARGEXP13PENABLE            (),
    .APBTARGEXP13PADDR              (),
    .APBTARGEXP13PWRITE             (),
    .APBTARGEXP13PWDATA             (),
    .APBTARGEXP13PRDATA             (32'h0000_0000),
    .APBTARGEXP13PREADY             (1'b1),
    .APBTARGEXP13PSLVERR            (1'b0),
    .APBTARGEXP13PSTRB              (),
    .APBTARGEXP13PPROT              (),

    .APBTARGEXP14PSEL               (),
    .APBTARGEXP14PENABLE            (),
    .APBTARGEXP14PADDR              (),
    .APBTARGEXP14PWRITE             (),
    .APBTARGEXP14PWDATA             (),
    .APBTARGEXP14PRDATA             (32'h0000_0000),
    .APBTARGEXP14PREADY             (1'b1),
    .APBTARGEXP14PSLVERR            (1'b0),
    .APBTARGEXP14PSTRB              (),
    .APBTARGEXP14PPROT              (),

    .APBTARGEXP15PSEL               (),
    .APBTARGEXP15PENABLE            (),
    .APBTARGEXP15PADDR              (),
    .APBTARGEXP15PWRITE             (),
    .APBTARGEXP15PWDATA             (),
    .APBTARGEXP15PRDATA             (32'h0000_0000),
    .APBTARGEXP15PREADY             (1'b1),
    .APBTARGEXP15PSLVERR            (1'b0),
    .APBTARGEXP15PSTRB              (),
    .APBTARGEXP15PPROT              (),

    .CPU0EDBGRQ                     (1'b0), 
    .CPU0DBGRESTART                 (1'b0), 
    .CPU0DBGRESTARTED               (),
    .CPU0HTMDHADDR                  (),
    .CPU0HTMDHTRANS                 (),
    .CPU0HTMDHSIZE                  (),
    .CPU0HTMDHBURST                 (),
    .CPU0HTMDHPROT                  (),
    .CPU0HTMDHWDATA                 (),
    .CPU0HTMDHWRITE                 (),
    .CPU0HTMDHRDATA                 (),
    .CPU0HTMDHREADY                 (),
    .CPU0HTMDHRESP                  (),
    .CPU0INTERNALSTATE              (),

    .CPU0PREADY                     (1'b1),
    .CPU0PSLVERR                    (1'b1),
    .CPU0PRDATA                     (32'h0000_0000),
    .CPU0PSEL                       (),
    .CPU0PADDR                      (),
    .CPU0PADDR31                    (),
    .CPU0PWRITE                     (),
    .CPU0PENABLE                    (),
    .CPU0PWDATA                     (),

    .CPU0DPABORT_DP                 (dbg_dpabort),
    .CPU0PSEL_DP                    (cpu_dbg_psel),
    .CPU0PENABLE_DP                 (dbg_penable),
    .CPU0PWRITE_DP                  (dbg_pwrite),
    .CPU0PADDR_DP                   (dbg_paddr[11:0]),
    .CPU0PWDATA_DP                  (dbg_pwdata),
    .CPU0PREADY_DP                  (cpu_dbg_pready),
    .CPU0PSLVERR_DP                 (cpu_dbg_pslverr),
    .CPU0PRDATA_DP                  (cpu_dbg_prdata),

    .CPU0CTICHIN                    (ctichin_int),
    .CPU0CTICHOUT                   (ctichout_int),
    .CPU0CTIINT                     (),
    .CPU0CTIASICCTRL                (),

    .CPU0TSVALUEB                   (tsvalueb),
    .CPU0TSCLKCHANGE                (1'b0),
    .CPU0ETMINTNUM                  (),
    .CPU0ETMINTSTAT                 (),
    .CPU0ETMFIFOFULL                (),
    .CPU0TRCENA                     (),
    .CPU0ETMEN                      (),

    .CPU0ETMATREADY                 (etm_atready),
    .CPU0ETMATID                    (etm_atid),
    .CPU0ETMATVALID                 (etm_atvalid),
    .CPU0ETMATDATA                  (etm_atdata),
    .CPU0ETMATBYTES                 (etm_atbytes),
    .CPU0ETMAFREADY                 (etm_afready),

    .CPU0ETMTRIGOUT                 (),
    .CPU0ETMDBGREQ                  (),

    .CPU0ITMATREADY                 (itm_atready),
    .CPU0ITMATID                    (itm_atid),
    .CPU0ITMATVALID                 (itm_atvalid),
    .CPU0ITMATDATA                  (itm_atdata),
    .CPU0ITMATBYTES                 (itm_atbytes),
    .CPU0ITMAFREADY                 (itm_afready),

    .CPU0HALTED                     (halted),
    .CPU0MPUDISABLE                 (1'b0),
    .CPU0SLEEPING                   (sleeping),
    .CPU0SLEEPDEEP                  (),
    .CPU0SLEEPHOLDREQn              (sleep_hold_reqn),
    .CPU0SLEEPHOLDACKn              (sleep_hold_ackn),
    .CPU0WAKEUP                     (),
    .CPU0WICENACK                   (),
    .CPU0WICSENSE                   (),
    .CPU0WICENREQ                   (1'b1),
    .CPU0SYSRESETREQ                (sysreset_req),
    .CPU0LOCKUP                     (lockup),
    .CPU0BRCHSTAT                   (),

    .MTXREMAP                       (4'b1111),

    .CPU0RXEV                       (1'b0),
    .CPU0TXEV                       (),

    .CPU0INTISR                     (intisr),
    .CPU0INTNMI                     (intnmi),
    .CPU0CURRPRI                    (),
    .CPU0AUXFAULT                   (32'h0000_0000),

    .APBQACTIVE                     (), 
    .TIMER0PCLKQACTIVE              (timer0pclk_qactive),
    .TIMER1PCLKQACTIVE              (timer1pclk_qactive),

    .CPU0DBGEN                      (dbgen_ss),
    .CPU0NIDEN                      (niden_ss),
    .CPU0DAPEN                      (dapen_ss),
    .CPU0FIXMASTERTYPE              (1'b0),
    .CPU0ETMFIFOFULLEN              (1'b0),

    .DFTRSTDISABLE                  (dftrstdisable[0]),
    .DFTCGEN                        (dftcgen),
    .DFTSE                          (dftse)
  );


  channel_gate_f0 u_channel_gate_f0 (
  
    .channel_pulse_slave_0  (ctichin),
    .channel_pulse_master_0 (ctichout),
    
    .channel_pulse_slave_1  (ctichout_int),
    .channel_pulse_master_1 (ctichin_int),

    .chen                   (chen_ss)
  );
    
  
  generate
  genvar I;
    for (I=0; I<43; I=I+1) begin : gen_arm_element_cdc_capt_sync
      
      arm_element_cdc_capt_sync   u_arm_element_cdc_capt_sync   (
        .clk     (extsys_clk),
        .nreset  (extsys_mtx_resetn_s),
        .d_async (extsys_shdint[I]),
        .q       (extsys_shdint_ss[I])
      ); 
    end
  endgenerate
  
  assign intisr[0]        = timer0_timerint;
  assign intisr[1]        = timer1_timerint;
  assign intisr[2]        = hes_mhu0_comb_int;
  assign intisr[3]        = esh_mhu0_comb_int;
  assign intisr[4]        = hes_mhu1_comb_int;
  assign intisr[5]        = esh_mhu1_comb_int;  
  assign intisr[6]        = sees_mhu0_comb_int;
  assign intisr[7]        = esse_mhu0_comb_int;
  assign intisr[8]        = sees_mhu1_comb_int;
  assign intisr[9]        = esse_mhu1_comb_int;  
  assign intisr[10]       = hxb_err_irq;
  assign intisr[11]       = uart_irq;
  assign intisr[12]       = 1'b0;
  assign intisr[55:13]    = extsys_shdint_ss;
  assign intisr[239:56]   = 184'h0;

  assign intnmi = wdog_int;
  
  always @(posedge extsys_clk or negedge extsys_mtx_resetn_s)
  begin
    if (~extsys_mtx_resetn_s)
      wdog_res_r <= 1'b0;
    else
      wdog_res_r <= wdog_res;
   end
  
  arm_element_std_or2 u_arm_element_std_or2 (
    .A  (wdog_res_r),
    .B  (lockup),
    .Y  (wdog_lockup_irq)
  );    


  sse710_integration_example_f0_external_system_interconnect #( 
    .MEM_DATA_WIDTH (MEM_DATA_WIDTH)
  ) u_sse710_integration_example_f0_external_system_interconnect (
    .extsys_hclk                           (extsys_hclk),

    .extsys_mtx_resetn                     (extsys_mtx_resetn_s),

    .expclk_qreqn                          (expclk_qreqn),
    .expclk_qacceptn                       (expclk_qacceptn),
    .expclk_qdeny                          (expclk_qdeny),
    .expclk_qactive                        (expclk_qactive),
                                           
    .targexp1_hsel                         (targexp1_hsel),
    .targexp1_haddr                        (targexp1_haddr),
    .targexp1_htrans                       (targexp1_htrans),
    .targexp1_hwrite                       (targexp1_hwrite),
    .targexp1_hsize                        (targexp1_hsize),
    .targexp1_hburst                       (targexp1_hburst),
    .targexp1_hprot                        (targexp1_hprot),
    .targexp1_memattr                      (targexp1_memattr),
    .targexp1_exreq                        (targexp1_exreq),
    .targexp1_hmaster                      (targexp1_hmaster),
    .targexp1_hwdata                       (targexp1_hwdata),
    .targexp1_hmastlock                    (targexp1_hmastlock),
    .targexp1_hreadymux                    (targexp1_hreadymux),
    .targexp1_hauser                       (targexp1_hauser),
    .targexp1_hwuser                       (targexp1_hwuser),
    .targexp1_hrdata                       (targexp1_hrdata),
    .targexp1_hreadyout                    (targexp1_hreadyout),
    .targexp1_hresp                        (targexp1_hresp),
    .targexp1_exresp                       (targexp1_exresp),
    .targexp1_hruser                       (targexp1_hruser),
                                           
    .initexp0_hsel                         (initexp0_hsel),
    .initexp0_haddr                        (initexp0_haddr),
    .initexp0_htrans                       (initexp0_htrans),
    .initexp0_hwrite                       (initexp0_hwrite),
    .initexp0_hsize                        (initexp0_hsize),
    .initexp0_hburst                       (initexp0_hburst),
    .initexp0_hprot                        (initexp0_hprot),
    .initexp0_memattr                      (initexp0_memattr),
    .initexp0_exreq                        (initexp0_exreq),
    .initexp0_hmaster                      (initexp0_hmaster),
    .initexp0_hwdata                       (initexp0_hwdata),
    .initexp0_hmastlock                    (initexp0_hmastlock),
    .initexp0_hready                       (initexp0_hready),
    .initexp0_hauser                       (initexp0_hauser),
    .initexp0_hwuser                       (initexp0_hwuser),
    .initexp0_hrdata                       (initexp0_hrdata),
    .initexp0_hresp                        (initexp0_hresp),
    .initexp0_exresp                       (initexp0_exresp),
    .initexp0_hruser                       (initexp0_hruser),

    .apbtargexp2_psel                      (apbtargexp2_psel),
    .apbtargexp2_penable                   (apbtargexp2_penable),
    .apbtargexp2_paddr                     (apbtargexp2_paddr),
    .apbtargexp2_pwrite                    (apbtargexp2_pwrite),
    .apbtargexp2_pwdata                    (apbtargexp2_pwdata),
    .apbtargexp2_pstrb                     (apbtargexp2_pstrb),
    .apbtargexp2_pprot                     (apbtargexp2_pprot),
    .apbtargexp2_prdata                    (apbtargexp2_prdata),
    .apbtargexp2_pready                    (apbtargexp2_pready),
    .apbtargexp2_pslverr                   (apbtargexp2_pslverr),

    .apbtargexp11_psel                     (apbtargexp11_psel),
    .apbtargexp11_penable                  (apbtargexp11_penable),
    .apbtargexp11_paddr                    (apbtargexp11_paddr),
    .apbtargexp11_pwrite                   (apbtargexp11_pwrite),
    .apbtargexp11_pwdata                   (apbtargexp11_pwdata),
    .apbtargexp11_pstrb                    (apbtargexp11_pstrb),
    .apbtargexp11_pprot                    (apbtargexp11_pprot),
    .apbtargexp11_prdata                   (apbtargexp11_prdata),
    .apbtargexp11_pready                   (apbtargexp11_pready),
    .apbtargexp11_pslverr                  (apbtargexp11_pslverr),
    
    .mem_awakeup                           (mem_awakeup),
    .mem_awid                              (mem_awid),
    .mem_awaddr                            (mem_awaddr),
    .mem_awlen                             (mem_awlen),
    .mem_awsize                            (mem_awsize),
    .mem_awburst                           (mem_awburst),
    .mem_awlock                            (mem_awlock),
    .mem_awcache                           (mem_awcache),
    .mem_awprot                            (mem_awprot),
    .mem_awvalid                           (mem_awvalid),
    .mem_awready                           (mem_awready),

    .mem_wstrb                             (mem_wstrb),
    .mem_wlast                             (mem_wlast),
    .mem_wvalid                            (mem_wvalid),
    .mem_wdata                             (mem_wdata),
    .mem_wready                            (mem_wready),

    .mem_bid                               (mem_bid),
    .mem_bresp                             (mem_bresp),
    .mem_bvalid                            (mem_bvalid),
    .mem_bready                            (mem_bready),

    .mem_arid                              (mem_arid),
    .mem_araddr                            (mem_araddr),
    .mem_arlen                             (mem_arlen),
    .mem_arsize                            (mem_arsize),
    .mem_arburst                           (mem_arburst),
    .mem_arlock                            (mem_arlock),
    .mem_arcache                           (mem_arcache),
    .mem_arprot                            (mem_arprot),    
    .mem_arvalid                           (mem_arvalid),
    .mem_arready                           (mem_arready),

    .mem_rid                               (mem_rid),
    .mem_rresp                             (mem_rresp),
    .mem_rlast                             (mem_rlast),
    .mem_rvalid                            (mem_rvalid),
    .mem_rdata                             (mem_rdata),
    .mem_rready                            (mem_rready),

    .slvmustacceptreqn_async               (slvmustacceptreqn_async),
    .slvcandenyreqn_async                  (slvcandenyreqn_async),
    .slvacceptn_async                      (slvacceptn_async),
    .slvdeny_async                         (slvdeny_async),

    .si_to_mi_wakeup_async                 (si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async                 (mi_to_si_wakeup_async),

    .aw_wr_ptr_async                       (aw_wr_ptr_async),
    .aw_rd_ptr_async                       (aw_rd_ptr_async),
    .aw_payld_async                        (aw_payld_async),

    .w_wr_ptr_async                        (w_wr_ptr_async),
    .w_rd_ptr_async                        (w_rd_ptr_async),
    .w_payld_async                         (w_payld_async),

    .b_wr_ptr_async                        (b_wr_ptr_async),
    .b_rd_ptr_async                        (b_rd_ptr_async),
    .b_payld_async                         (b_payld_async),

    .ar_wr_ptr_async                       (ar_wr_ptr_async),
    .ar_rd_ptr_async                       (ar_rd_ptr_async),
    .ar_payld_async                        (ar_payld_async),

    .r_wr_ptr_async                        (r_wr_ptr_async),
    .r_rd_ptr_async                        (r_rd_ptr_async),
    .r_payld_async                         (r_payld_async),

    .mhu_psel                              (mhu_psel),
    .mhu_pwakeup                           (mhu_pwakeup),
    .mhu_penable                           (mhu_penable),
    .mhu_paddr                             (mhu_paddr),
    .mhu_pwrite                            (mhu_pwrite),
    .mhu_pwdata                            (mhu_pwdata),
    .mhu_pstrb                             (mhu_pstrb),
    .mhu_pprot                             (mhu_pprot),
    .mhu_prdata                            (mhu_prdata),
    .mhu_pready                            (mhu_pready),
    .mhu_pslverr                           (mhu_pslverr),
                                           
    .extdbg_psel                           (extdbg_psel),
    .extdbg_pwakeup                        (extdbg_pwakeup),
    .extdbg_penable                        (extdbg_penable),
    .extdbg_paddr                          (extdbg_paddr),
    .extdbg_pwrite                         (extdbg_pwrite),
    .extdbg_pwdata                         (extdbg_pwdata),
    .extdbg_pstrb                          (extdbg_pstrb),
    .extdbg_pprot                          (extdbg_pprot),
    .extdbg_prdata                         (extdbg_prdata),
    .extdbg_pready                         (extdbg_pready),
    .extdbg_pslverr                        (extdbg_pslverr),

    .sysreg_apb_async_req                  (sysreg_apb_async_req),
    .sysreg_apb_async_req_payload          (sysreg_apb_async_req_payload),
    .sysreg_apb_async_resp_payload         (sysreg_apb_async_resp_payload),
    .sysreg_apb_async_ack                  (sysreg_apb_async_ack),
    
    .uart_apb_async_req                    (uart_apb_async_req),
    .uart_apb_async_req_payload            (uart_apb_async_req_payload),
    .uart_apb_async_resp_payload           (uart_apb_async_resp_payload),
    .uart_apb_async_ack                    (uart_apb_async_ack),    
    
    .hxb_err_irq                           (hxb_err_irq),

    .hxb_clk_qreqn                         (hxb_clk_qreqn),
    .hxb_clk_qacceptn                      (hxb_clk_qacceptn),
    .hxb_clk_qdeny                         (hxb_clk_qdeny),
    .hxb_clk_qactive                       (hxb_clk_qactive),    
    
    .dftcgen                               (dftcgen),
    .dftrstdisable                         (dftrstdisable[1])
);


  sse710_integration_example_f0_external_system_dbg u_sse710_integration_example_f0_external_system_dbg (
    .extsys_dclk            (extsys_dclk),
    .extsys_dbg_resetn      (extsys_dbg_resetn_s),

    .dbg_psel               (dbg_psel),
    .dbg_penable            (dbg_penable),
    .dbg_pwrite             (dbg_pwrite),
    .dbg_paddr              (dbg_paddr),
    .dbg_pwdata             (dbg_pwdata),
    .dbg_pready             (dbg_pready),
    .dbg_pslverr            (dbg_pslverr),
    .dbg_prdata             (dbg_prdata ),
    
    .cpu_dbg_psel           (cpu_dbg_psel),
    .cpu_dbg_pready         (cpu_dbg_pready),
    .cpu_dbg_pslverr        (cpu_dbg_pslverr),
    .cpu_dbg_prdata         (cpu_dbg_prdata),

    .etm_afready            (etm_afready),
    .etm_atbytes            (etm_atbytes),
    .etm_atdata             (etm_atdata),
    .etm_atid               (etm_atid),
    .etm_atready            (etm_atready),
    .etm_atvalid            (etm_atvalid),
                            
    .itm_afready            (itm_afready),
    .itm_atbytes            (itm_atbytes),
    .itm_atdata             (itm_atdata),
    .itm_atid               (itm_atid),
    .itm_atready            (itm_atready),
    .itm_atvalid            (itm_atvalid),
                            
    .nts_fw_data            (nts_fw_data),
    .nts_m_lp               (nts_m_lp),
    .nts_rd_ptr_encd_gry    (nts_rd_ptr_encd_gry),
    .nts_rd_ptr_sync_gry    (nts_rd_ptr_sync_gry),
    .nts_s_lp               (nts_s_lp),
    .nts_s_lp_return        (nts_s_lp_return),
    .nts_wr_ptr_encd_gry    (nts_wr_ptr_encd_gry),
    .nts_wr_ptr_sync_gry    (nts_wr_ptr_sync_gry),
                            
    .traceexp_afready       (traceexp_afready),
    .traceexp_afvalid       (traceexp_afvalid),
    .traceexp_atbytes       (traceexp_atbytes),
    .traceexp_atdata        (traceexp_atdata),
    .traceexp_atid          (traceexp_atid),
                            
    .traceexp_atready       (traceexp_atready),
    .traceexp_atvalid       (traceexp_atvalid),
    .traceexp_atwakeup      (traceexp_atwakeup),
    .traceexp_syncreq       (traceexp_syncreq),
                            
    .tsvalueb               (tsvalueb)
  );


  sse710_integration_example_f0_external_system_memories u_sse710_integration_example_f0_external_system_memories (
    .extsys_hclk               (extsys_hclk),
    .extsys_mtx_resetn         (extsys_mtx_resetn_s),

    .targflash0_hsel           (targflash0_hsel),
    .targflash0_haddr          (targflash0_haddr),
    .targflash0_htrans         (targflash0_htrans),
    .targflash0_hwrite         (targflash0_hwrite),
    .targflash0_hsize          (targflash0_hsize),
    .targflash0_hburst         (targflash0_hburst),
    .targflash0_hprot          (targflash0_hprot),
    .targflash0_memattr        (targflash0_memattr),
    .targflash0_exreq          (targflash0_exreq),
    .targflash0_hmaster        (targflash0_hmaster),
    .targflash0_hwdata         (targflash0_hwdata),
    .targflash0_hmastlock      (targflash0_hmastlock),
    .targflash0_hreadymux      (targflash0_hreadymux),
    .targflash0_hauser         (targflash0_hauser),
    .targflash0_hwuser         (targflash0_hwuser),
                               
    .targflash0_hrdata         (targflash0_hrdata),
    .targflash0_hreadyout      (targflash0_hreadyout),
    .targflash0_hresp          (targflash0_hresp),
    .targflash0_exresp         (targflash0_exresp),
    .targflash0_hruser         (targflash0_hruser),

    .flash_err                 (),
    .flash_int                 (),

    .apbtargexp3_psel          (apbtargexp3_psel),
    .apbtargexp3_penable       (apbtargexp3_penable),
    .apbtargexp3_paddr         (apbtargexp3_paddr),
    .apbtargexp3_pwrite        (apbtargexp3_pwrite),
    .apbtargexp3_pwdata        (apbtargexp3_pwdata),
    .apbtargexp3_prdata        (apbtargexp3_prdata),
    .apbtargexp3_pready        (apbtargexp3_pready),
    .apbtargexp3_pslverr       (apbtargexp3_pslverr),
    .apbtargexp3_pstrb         (apbtargexp3_pstrb),
    .apbtargexp3_pprot         (apbtargexp3_pprot),
                               
    .apbtargexp9_psel          (apbtargexp9_psel),
    .apbtargexp9_penable       (apbtargexp9_penable),
    .apbtargexp9_paddr         (apbtargexp9_paddr),
    .apbtargexp9_pwrite        (apbtargexp9_pwrite),
    .apbtargexp9_pwdata        (apbtargexp9_pwdata),
    .apbtargexp9_prdata        (apbtargexp9_prdata),
    .apbtargexp9_pready        (apbtargexp9_pready),
    .apbtargexp9_pslverr       (apbtargexp9_pslverr),
    .apbtargexp9_pstrb         (apbtargexp9_pstrb),
    .apbtargexp9_pprot         (apbtargexp9_pprot),
                               
    .apbtargexp10_psel         (apbtargexp10_psel),
    .apbtargexp10_penable      (apbtargexp10_penable),
    .apbtargexp10_paddr        (apbtargexp10_paddr),
    .apbtargexp10_pwrite       (apbtargexp10_pwrite),
    .apbtargexp10_pwdata       (apbtargexp10_pwdata),
    .apbtargexp10_prdata       (apbtargexp10_prdata),
    .apbtargexp10_pready       (apbtargexp10_pready),
    .apbtargexp10_pslverr      (apbtargexp10_pslverr),
    .apbtargexp10_pstrb        (apbtargexp10_pstrb),
    .apbtargexp10_pprot        (apbtargexp10_pprot),
                               
    .sram0_rdata               (sram0_rdata),
    .sram0_addr                (sram0_addr),
    .sram0_wren                (sram0_wren),
    .sram0_wdata               (sram0_wdata),
    .sram0_cs                  (sram0_cs),
    
    .dftramhold                (dftramhold)
);


  sse710_integration_example_f0_external_system_crg u_sse710_integration_example_f0_external_system_crg(
    .extsys_clk                (extsys_clk),
    .extsys_hclk               (extsys_hclk),
    .extsys_dclk               (extsys_dclk),
    .extsys_timer0pclkg        (extsys_timer0pclkg),
    .extsys_timer1pclkg        (extsys_timer1pclkg),
                               
    .mtx_resetn                (extsys_mtx_resetn),
    .dbg_resetn                (extsys_dbg_resetn),
    .core_resetn               (extsys_core_resetn),
    
    .mtx_resetn_s              (extsys_mtx_resetn_s),
    .dbg_resetn_s              (extsys_dbg_resetn_s),
    .core_resetn_s             (extsys_core_resetn_s),    
                               
    .aclk_qreqn                (aclk_qreqn),
    .aclk_qacceptn             (aclk_qacceptn),
    .aclk_qdeny                (aclk_qdeny),
    .aclk_qactive              (aclk_qactive),
                               
    .mhuclk_qreqn              (mhuclk_qreqn),
    .mhuclk_qacceptn           (mhuclk_qacceptn),
    .mhuclk_qdeny              (mhuclk_qdeny),
    .mhuclk_qactive            (mhuclk_qactive),
                               
    .atclk_qreqn               (atclk_qreqn),
    .atclk_qacceptn            (atclk_qacceptn),
    .atclk_qdeny               (atclk_qdeny),
    .atclk_qactive             (atclk_qactive),
                               
    .dbgclkm_qreqn             (dbgclkm_qreqn),
    .dbgclkm_qacceptn          (dbgclkm_qacceptn),
    .dbgclkm_qdeny             (dbgclkm_qdeny),
    .dbgclkm_qactive           (dbgclkm_qactive),
                               
    .dbgclks_qreqn             (dbgclks_qreqn),
    .dbgclks_qacceptn          (dbgclks_qacceptn),
    .dbgclks_qdeny             (dbgclks_qdeny),
    .dbgclks_qactive           (dbgclks_qactive),
                               
    .cticlk_qreqn              (cticlk_qreqn),
    .cticlk_qacceptn           (cticlk_qacceptn),
    .cticlk_qdeny              (cticlk_qdeny),
    .cticlk_qactive            (cticlk_qactive),
                               
    .expclk_qreqn              (expclk_qreqn),
    .expclk_qacceptn           (expclk_qacceptn),
    .expclk_qdeny              (expclk_qdeny),
    .expclk_qactive            (expclk_qactive),
    
    .hxb_clk_qreqn             (hxb_clk_qreqn),
    .hxb_clk_qacceptn          (hxb_clk_qacceptn),
    .hxb_clk_qdeny             (hxb_clk_qdeny),
    .hxb_clk_qactive           (hxb_clk_qactive),    
                               
    .extdbgrom_cdbgpwrupack_ss (extdbgrom_cdbgpwrupack_ss),
    .axiaprom_csyspwrupack_ss  (axiaprom_csyspwrupack_ss),
    .sleeping                  (sleeping),
    .timer0pclk_qactive        (timer0pclk_qactive),
    .timer1pclk_qactive        (timer1pclk_qactive),

    .clock_override_extsystop  (clock_override_extsystop),

    .mbistreq                  (mbistreq),
    .dftcgen                   (dftcgen),
    .dftrstdisable             (dftrstdisable)
    
);

  
  assign wdog_clken   = ~halted;
  assign timer0_extin = ~halted;
  assign timer1_extin = ~halted;

  sse710_integration_example_f0_external_system_peripherals u_sse710_integration_example_f0_external_system_peripherals (
    .extsys_clk                   (extsys_clk),
    .extsys_hclk                  (extsys_hclk),
    .wdog_clken                   (wdog_clken),

    .extsys_mtx_resetn            (extsys_mtx_resetn_s),

    .apbtargexp8_psel             (apbtargexp8_psel),
    .apbtargexp8_penable          (apbtargexp8_penable),
    .apbtargexp8_paddr            (apbtargexp8_paddr),
    .apbtargexp8_pwrite           (apbtargexp8_pwrite),
    .apbtargexp8_pwdata           (apbtargexp8_pwdata),
    .apbtargexp8_prdata           (apbtargexp8_prdata),
    .apbtargexp8_pready           (apbtargexp8_pready),
    .apbtargexp8_pslverr          (apbtargexp8_pslverr),
    .apbtargexp8_pstrb            (apbtargexp8_pstrb),
    .apbtargexp8_pprot            (apbtargexp8_pprot),

    .targexp0hsel                 (targexp0_hsel),
    .targexp0haddr                (targexp0_haddr),
    .targexp0htrans               (targexp0_htrans),
    .targexp0hwrite               (targexp0_hwrite),
    .targexp0hsize                (targexp0_hsize),
    .targexp0hburst               (targexp0_hburst),
    .targexp0hprot                (targexp0_hprot),
    .targexp0memattr              (targexp0_memattr),
    .targexp0exreq                (targexp0_exreq),
    .targexp0hmaster              (targexp0_hmaster),
    .targexp0hwdata               (targexp0_hwdata),
    .targexp0hmastlock            (targexp0_hmastlock),
    .targexp0hreadymux            (targexp0_hreadymux),
    .targexp0hauser               (targexp0_hauser),
    .targexp0hwuser               (targexp0_hwuser),
    .targexp0hrdata               (targexp0_hrdata),
    .targexp0hreadyout            (targexp0_hreadyout),
    .targexp0hresp                (targexp0_hresp),
    .targexp0exresp               (targexp0_exresp),
    .targexp0hruser               (targexp0_hruser),

    .wdog_int                     (wdog_int),
    .wdog_res                     (wdog_res)
);

  assign extsys_dbgclks = extsys_hclk;
  assign extsys_dbgclkm = extsys_dclk;
  assign extsys_atclk   = extsys_dclk;
  assign extsys_cticlk  = extsys_dclk;
  assign extsys_aclk    = extsys_hclk;
  assign extsys_mhuclk  = extsys_hclk;
 

  arm_element_cdc_capt_sync   u_arm_element_cdc_capt_sync_0   (
    .clk     (extsys_clk),
    .nreset  (extsys_dbg_resetn_s),
    .d_async (dbgen),
    .q       (dbgen_ss)
    ); 
  
  arm_element_cdc_capt_sync   u_arm_element_cdc_capt_sync_1   (
    .clk     (extsys_clk),
    .nreset  (extsys_dbg_resetn_s),
    .d_async (niden),
    .q       (niden_ss)
    ); 
  
  arm_element_cdc_capt_sync   u_arm_element_cdc_capt_sync_2   (
    .clk     (extsys_clk),
    .nreset  (extsys_dbg_resetn_s),
    .d_async (dapen),
    .q       (dapen_ss)
  );   
  
  arm_element_cdc_capt_sync   u_arm_element_cdc_capt_sync_3   (
    .clk     (extsys_clk),
    .nreset  (extsys_dbg_resetn_s),
    .d_async (chen),
    .q       (chen_ss)
  );     
 
endmodule
