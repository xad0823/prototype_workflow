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

module sse710_integration_example_f0_top_3 #(

 
  parameter             EXTSYS0_SECURITY = 1'b0, // Security of the External System 0 (0 - Secure, 1 - Non-Secure)
 
  parameter             EXTSYS1_SECURITY = 1'b0 // Security of the External System 1 (0 - Secure, 1 - Non-Secure)
 

) (
  // Clocks
  input  wire           REFCLK,
  input  wire           S32KCLK,
  input  wire           SECENCREFCLK,
  input  wire           SYSPLL,
  input  wire           CPUPLL,
  input  wire           SWCLKTCK,
  input  wire           TRACECLKIN,
 
  input  wire           EXTSYS0FCLK,
 
  input  wire           EXTSYS1FCLK,
 
  input  wire           UARTCLK,

  input  wire           SYSPLLLOCK,
  input  wire           CPUPLLLOCK,

  output wire           TRACECLKOUT,
  output wire           ACLKOUT,

  // Resets
  input  wire           PORESETn,
  input  wire           nSRST,

  output wire           SYSTOPWARMRESETn,

 
  // OCVM AXI Master interface
  output wire           AWAKEUPOCVM,
  output wire [11:0]    AWIDOCVM,
  output wire [31:0]    AWADDROCVM,
  output wire [7:0]     AWLENOCVM,
  output wire [2:0]     AWSIZEOCVM,
  output wire [1:0]     AWBURSTOCVM,
  output wire           AWLOCKOCVM,
  output wire [3:0]     AWCACHEOCVM,
  output wire [2:0]     AWPROTOCVM,
  output wire [3:0]     AWQOSOCVM,
  output wire           AWVALIDOCVM,
  input  wire           AWREADYOCVM,
  output wire [1:0]     AWUSEROCVM,
  output wire [7:0]     AWMMUSIDOCVM,

  output wire [63:0]    WDATAOCVM,
  output wire [7:0]     WSTRBOCVM,
  output wire           WLASTOCVM,
  output wire           WVALIDOCVM,
  input  wire           WREADYOCVM,

  input  wire [11:0]    BIDOCVM,
  input  wire [1:0]     BRESPOCVM,
  input  wire           BVALIDOCVM,
  output wire           BREADYOCVM,

  output wire [11:0]    ARIDOCVM,
  output wire [31:0]    ARADDROCVM,
  output wire [7:0]     ARLENOCVM,
  output wire [2:0]     ARSIZEOCVM,
  output wire [1:0]     ARBURSTOCVM,
  output wire           ARLOCKOCVM,
  output wire [3:0]     ARCACHEOCVM,
  output wire [2:0]     ARPROTOCVM,
  output wire [3:0]     ARQOSOCVM,
  output wire           ARVALIDOCVM,
  input  wire           ARREADYOCVM,
  output wire [1:0]     ARUSEROCVM,
  output wire [7:0]     ARMMUSIDOCVM,

  input  wire [11:0]    RIDOCVM,
  input  wire [63:0]    RDATAOCVM,
  input  wire [1:0]     RRESPOCVM,
  input  wire           RLASTOCVM,
  input  wire           RVALIDOCVM,
  output wire           RREADYOCVM,
 

  // GPIO
  input  wire [15:0]    GPIO_PORT_IN,
  output wire [15:0]    GPIO_PORT_OUT,
  output wire [15:0]    GPIO_PORT_EN,
  output wire [15:0]    GPIO_PORT_FUNC,

  // Host UART 0
  output wire           HOSTUART0TX,
  input  wire           HOSTUART0RX,
  output wire           HOSTUART0RTSn,
  input  wire           HOSTUART0CTSn,
  output wire           HOSTUART0DTRn,
  input  wire           HOSTUART0RIn,
  input  wire           HOSTUART0DCDn,
  input  wire           HOSTUART0DSRn,
  output wire           HOSTUART0OUT1n,
  output wire           HOSTUART0OUT2n,

  // Host UART 1
  output wire           HOSTUART1TX,
  input  wire           HOSTUART1RX,
  output wire           HOSTUART1RTSn,
  output wire           HOSTUART1DTRn,
  input  wire           HOSTUART1CTSn,
  input  wire           HOSTUART1RIn,
  input  wire           HOSTUART1DCDn,
  input  wire           HOSTUART1DSRn,
  output wire           HOSTUART1OUT1n,
  output wire           HOSTUART1OUT2n,

  // Secure Enclave UART
  output wire           SECENCUARTTX,
  input  wire           SECENCUARTRX,
  output wire           SECENCUARTRTSn,
  output wire           SECENCUARTDTRn,
  input  wire           SECENCUARTCTSn,
  input  wire           SECENCUARTRIn,
  input  wire           SECENCUARTDCDn,
  input  wire           SECENCUARTDSRn,
  output wire           SECENCUARTOUT1n,
  output wire           SECENCUARTOUT2n,
  
 
  // External System 0 UART
  output wire           EXTSYS0UARTTX,
  input  wire           EXTSYS0UARTRX,
  output wire           EXTSYS0UARTRTSn,
  output wire           EXTSYS0UARTDTRn,
  input  wire           EXTSYS0UARTCTSn,
  input  wire           EXTSYS0UARTRIn,
  input  wire           EXTSYS0UARTDCDn,
  input  wire           EXTSYS0UARTDSRn,
  output wire           EXTSYS0UARTOUT1n,
  output wire           EXTSYS0UARTOUT2n,  
 
  // External System 1 UART
  output wire           EXTSYS1UARTTX,
  input  wire           EXTSYS1UARTRX,
  output wire           EXTSYS1UARTRTSn,
  output wire           EXTSYS1UARTDTRn,
  input  wire           EXTSYS1UARTCTSn,
  input  wire           EXTSYS1UARTRIn,
  input  wire           EXTSYS1UARTDCDn,
  input  wire           EXTSYS1UARTDSRn,
  output wire           EXTSYS1UARTOUT1n,
  output wire           EXTSYS1UARTOUT2n,  
 

  // JTAG/SW
  input  wire           nTRST,
  input  wire           TDI,
  input  wire           SWDITMS,
  output wire           TDO,
  output wire           TDOENn,
  output wire           SWDO,
  output wire           SWDOEN,
  output wire           SWACTIVE,
  output wire           JTAGACTIVE,
  output wire [3:0]     JTAGIR,
  output wire [3:0]     JTAGSTATE,
  output wire           DORMANTSTATE,

  // TPIU
  input  wire [4:0]     TPIUTRACEMAXDATASIZE,
  input  wire           TPIUTPCTLVALID,
  output wire           TPIUTRACECTL,
  output wire [31:0]    TPIUTRACEDATA,

  // Flash GFB Master
  output wire [21:0]    FADDR,
  output wire [2:0]     FCMD,
  output wire           FABORT,
  output wire [31:0]    FWDATA,
  input  wire [127:0]   FRDATA,
  input  wire           FREADY,
  input  wire           FRESP,

  // Flash APB Master
  output wire           PSEL_M,
  output wire           PENABLE_M,
  output wire [11:0]    PADDR_M,
  output wire           PWRITE_M,
  output wire [3:0]     PSTRB_M,
  output wire [31:0]    PWDATA_M,
  input  wire [31:0]    PRDATA_M,
  input  wire           PREADY_M,
  input  wire           PSLVERR_M,

  // Flash P-Channel Control
  output wire           PREQ,
  output wire           PSTATE,
  input  wire           PACCEPT,
  input  wire           PDENY,
  input  wire           PACTIVE,

  output wire           FLASH_PWR_RDY,

  // DFT
  input  wire           MBISTREQ,
  input  wire           nMBISTRESET,
  input  wire           DFTCGEN,
  input  wire [1:0]     DFTRSTDISABLE,
  input  wire           DFTPWRUP,
  input  wire           DFTISODISABLE,
  input  wire           DFTRAMHOLD,
  input  wire           DFTMCPHOLD,
  
  input  wire           DFTDIVSEL,
  input  wire [2:0]     DFTHOSTUARTCLKSEL,
  input  wire [1:0]     DFTCTRLCLKSEL,
  input  wire [1:0]     DFTGICCLKSEL,
  input  wire [1:0]     DFTACLKSEL,
  input  wire [1:0]     DFTDBGCLKSEL,
  input  wire [1:0]     DFTSECCLKSEL,
  input  wire           DFTCLKSELEN,
  input  wire [2:0]     DFTHOSTCPUCLKSEL,
  input  wire           DFTDIVBYPASS,
  input  wire           DFTRETDISABLE,
  input  wire           DFTSE,
  input  wire           DFTTESTMODE,
  
  output wire [1:0]     DFTENABLE
);

// -----------------------------------------------------------------------------
// Internal Signals

  // SSE710 Top clock outputs
  wire           aclkout_i;
  wire           hostaonexpclk;
  
  // Gated REFCLK 
  wire           refclk_systop;

  // SSE710 Top reset outputs
  wire           systop_warmresetn;
  wire           dbgtop_warmresetn;
  wire           aontop_warmresetn;
  wire           aontop_poresetn;

  // Synchronized resets signals
  wire           systop_warmresetn_s_aclkout;
  wire           systop_warmresetn_s_refclk;
  wire           dbgtop_warmresetn_s;
  wire           aontop_warmresetn_s_s32kclk;
  wire           aontop_warmresetn_s_hostcntclkout;
  wire           aontop_warmresetn_s_hosts32kcntclkout;
  wire           aontop_warmresetn_s_hostaonexpclk;
  
  // ECO registers
  wire [3:0]     eco_socvar;
  wire [3:0]     eco_socrev;
  wire [3:0]     eco_dpromvar;
  wire [3:0]     eco_dpromrev;
  wire [3:0]     eco_extdbgromvar;
  wire [3:0]     eco_extdbgromrev;
  wire [3:0]     eco_hostromvar;
  wire [3:0]     eco_hostromrev;
  wire [3:0]     eco_hostaxiapromvar;
  wire [3:0]     eco_hostaxiapromrev;  

  // eXecute-in-place Volatile Memory AXI interface signal
  wire           cvm_awakeup;
  wire [11:0]    cvm_awid;
  wire [31:0]    cvm_awaddr;
  wire [7:0]     cvm_awlen;
  wire [2:0]     cvm_awsize;
  wire [1:0]     cvm_awburst;
  wire           cvm_awlock;
  wire [3:0]     cvm_awcache;
  wire [2:0]     cvm_awprot;
  wire           cvm_awvalid;
  wire           cvm_awready;
  wire [1:0]     cvm_awuser;
  wire [7:0]     cvm_awmmusid;
  wire [3:0]     cvm_awqos;

  wire [63:0]    cvm_wdata;
  wire [7:0]     cvm_wstrb;
  wire           cvm_wlast;
  wire           cvm_wvalid;
  wire           cvm_wready;

  wire [11:0]    cvm_bid;
  wire [1:0]     cvm_bresp;
  wire           cvm_bvalid;
  wire           cvm_bready;

  wire [11:0]    cvm_arid;
  wire [31:0]    cvm_araddr;
  wire [7:0]     cvm_arlen;
  wire [2:0]     cvm_arsize;
  wire [1:0]     cvm_arburst;
  wire           cvm_arlock;
  wire [3:0]     cvm_arcache;
  wire [2:0]     cvm_arprot;
  wire           cvm_arvalid;
  wire           cvm_arready;
  wire [1:0]     cvm_aruser;
  wire [7:0]     cvm_armmusid;
  wire [3:0]     cvm_arqos;

  wire [11:0]    cvm_rid;
  wire [63:0]    cvm_rdata;
  wire [1:0]     cvm_rresp;
  wire           cvm_rlast;
  wire           cvm_rvalid;
  wire           cvm_rready;

  // On-Chip Non-Volatile Memory AXI interface signal
  wire           xnvm_awakeup;
  wire [11:0]    xnvm_awid;
  wire [31:0]    xnvm_awaddr;
  wire [7:0]     xnvm_awlen;
  wire [2:0]     xnvm_awsize;
  wire [1:0]     xnvm_awburst;
  wire           xnvm_awlock;
  wire [3:0]     xnvm_awcache;
  wire [2:0]     xnvm_awprot;
  wire           xnvm_awvalid;
  wire [1:0]     xnvm_awuser;
  wire [7:0]     xnvm_awmmusid;
  wire           xnvm_awready;
  wire [3:0]     xnvm_awqos;  

  wire [63:0]    xnvm_wdata;
  wire [7:0]     xnvm_wstrb;
  wire           xnvm_wlast;
  wire           xnvm_wvalid;
  wire           xnvm_wready;

  wire [11:0]    xnvm_bid;
  wire [1:0]     xnvm_bresp;
  wire           xnvm_bvalid;
  wire           xnvm_bready;

  wire [11:0]    xnvm_arid;
  wire [31:0]    xnvm_araddr;
  wire [7:0]     xnvm_arlen;
  wire [2:0]     xnvm_arsize;
  wire [1:0]     xnvm_arburst;
  wire           xnvm_arlock;
  wire [3:0]     xnvm_arcache;
  wire [2:0]     xnvm_arprot;
  wire           xnvm_arvalid;
  wire [1:0]     xnvm_aruser;
  wire [7:0]     xnvm_armmusid;
  wire           xnvm_arready;
  wire [3:0]     xnvm_arqos; 

  wire [11:0]    xnvm_rid;
  wire [63:0]    xnvm_rdata;
  wire [1:0]     xnvm_rresp;
  wire           xnvm_rlast;
  wire           xnvm_rvalid;
  wire           xnvm_rready;

  // Generic Timestamp signals
  wire [63:0]    hosts32kcntvalueg;
  wire [63:0]    hosts32kcntvalueb;
  wire [63:0]    hostcntvalueg;
  wire [63:0]    hostcntvalueb;
  wire           hostcntclkout;
  wire           hosts32kcntclkout;

  // CoreSight Timestamp
  wire [63:0]    host_tsvalueb;
  

 

  // NTS async signals
  wire [3:0]     extsys0_nts_wr_ptr_encd_gry;
  wire [3:0]     extsys0_nts_rd_ptr_encd_gry;
  wire [3:0]     extsys0_nts_wr_ptr_sync_gry;
  wire [3:0]     extsys0_nts_rd_ptr_sync_gry;
  wire [53:0]    extsys0_nts_fw_data;
  wire           extsys0_nts_s_lp;
  wire           extsys0_nts_s_lp_return;
  wire           extsys0_nts_m_lp;

  // NTS async bridge power Q-Channels
  wire           extsys0_nts_qreqn;
  wire           extsys0_nts_qacceptn;
  wire           extsys0_nts_qdeny;
  wire           extsys0_nts_qactive;

 

  // NTS async signals
  wire [3:0]     extsys1_nts_wr_ptr_encd_gry;
  wire [3:0]     extsys1_nts_rd_ptr_encd_gry;
  wire [3:0]     extsys1_nts_wr_ptr_sync_gry;
  wire [3:0]     extsys1_nts_rd_ptr_sync_gry;
  wire [53:0]    extsys1_nts_fw_data;
  wire           extsys1_nts_s_lp;
  wire           extsys1_nts_s_lp_return;
  wire           extsys1_nts_m_lp;

  // NTS async bridge power Q-Channels
  wire           extsys1_nts_qreqn;
  wire           extsys1_nts_qacceptn;
  wire           extsys1_nts_qdeny;
  wire           extsys1_nts_qactive;

 



 

  // HOSTEXPMST 0 AXI interface signals
  wire           hostexpmst0_awakeup;
  wire [11:0]    hostexpmst0_awid;
  wire [31:0]    hostexpmst0_awaddr;
  wire [7:0]     hostexpmst0_awlen;
  wire [2:0]     hostexpmst0_awsize;
  wire [1:0]     hostexpmst0_awburst;
  wire           hostexpmst0_awlock;
  wire [3:0]     hostexpmst0_awcache;
  wire [2:0]     hostexpmst0_awprot;
  wire           hostexpmst0_awvalid;
  wire           hostexpmst0_awready;
  wire [1:0]     hostexpmst0_awuser;
  wire [7:0]     hostexpmst0_awmmusid;
  wire [3:0]     hostexpmst0_awqos; 

  wire [63:0]    hostexpmst0_wdata;
  wire [7:0]     hostexpmst0_wstrb;
  wire           hostexpmst0_wlast;
  wire           hostexpmst0_wvalid;
  wire           hostexpmst0_wready;

  wire [11:0]    hostexpmst0_bid;
  wire [1:0]     hostexpmst0_bresp;
  wire           hostexpmst0_bvalid;
  wire           hostexpmst0_bready;

  wire [11:0]    hostexpmst0_arid;
  wire [31:0]    hostexpmst0_araddr;
  wire [7:0]     hostexpmst0_arlen;
  wire [2:0]     hostexpmst0_arsize;
  wire [1:0]     hostexpmst0_arburst;
  wire           hostexpmst0_arlock;
  wire [3:0]     hostexpmst0_arcache;
  wire [2:0]     hostexpmst0_arprot;
  wire           hostexpmst0_arvalid;
  wire           hostexpmst0_arready;
  wire [1:0]     hostexpmst0_aruser;
  wire [7:0]     hostexpmst0_armmusid;
  wire [3:0]     hostexpmst0_arqos; 
                              
  wire [11:0]    hostexpmst0_rid;
  wire [63:0]    hostexpmst0_rdata;
  wire [1:0]     hostexpmst0_rresp;
  wire           hostexpmst0_rlast;
  wire           hostexpmst0_rvalid;
  wire           hostexpmst0_rready;

 

  // HOSTEXPMST 1 AXI interface signals
  wire           hostexpmst1_awakeup;
  wire [11:0]    hostexpmst1_awid;
  wire [31:0]    hostexpmst1_awaddr;
  wire [7:0]     hostexpmst1_awlen;
  wire [2:0]     hostexpmst1_awsize;
  wire [1:0]     hostexpmst1_awburst;
  wire           hostexpmst1_awlock;
  wire [3:0]     hostexpmst1_awcache;
  wire [2:0]     hostexpmst1_awprot;
  wire           hostexpmst1_awvalid;
  wire           hostexpmst1_awready;
  wire [1:0]     hostexpmst1_awuser;
  wire [7:0]     hostexpmst1_awmmusid;
  wire [3:0]     hostexpmst1_awqos; 

  wire [63:0]    hostexpmst1_wdata;
  wire [7:0]     hostexpmst1_wstrb;
  wire           hostexpmst1_wlast;
  wire           hostexpmst1_wvalid;
  wire           hostexpmst1_wready;

  wire [11:0]    hostexpmst1_bid;
  wire [1:0]     hostexpmst1_bresp;
  wire           hostexpmst1_bvalid;
  wire           hostexpmst1_bready;

  wire [11:0]    hostexpmst1_arid;
  wire [31:0]    hostexpmst1_araddr;
  wire [7:0]     hostexpmst1_arlen;
  wire [2:0]     hostexpmst1_arsize;
  wire [1:0]     hostexpmst1_arburst;
  wire           hostexpmst1_arlock;
  wire [3:0]     hostexpmst1_arcache;
  wire [2:0]     hostexpmst1_arprot;
  wire           hostexpmst1_arvalid;
  wire           hostexpmst1_arready;
  wire [1:0]     hostexpmst1_aruser;
  wire [7:0]     hostexpmst1_armmusid;
  wire [3:0]     hostexpmst1_arqos; 
                              
  wire [11:0]    hostexpmst1_rid;
  wire [63:0]    hostexpmst1_rdata;
  wire [1:0]     hostexpmst1_rresp;
  wire           hostexpmst1_rlast;
  wire           hostexpmst1_rvalid;
  wire           hostexpmst1_rready;

 
  
  // Interrupt signals
  wire           rtc_irq;
  wire           gpio_irq;
 
  wire           extsys0_ppu_irq;
  wire           extsys0_wdog_lockup_irq;
  wire           extsys0_uart_irq;
 
  wire           extsys1_ppu_irq;
  wire           extsys1_wdog_lockup_irq;
  wire           extsys1_uart_irq;
 
  wire           vultan_irq;

 
  wire [63:0]    exp_shd_int;
 
  wire           gic_wakeup;

 
  // External System 0 AXI asynchronous signals
  wire           extsys0_slvmustacceptreqn_async;
  wire           extsys0_slvcandenyreqn_async;
  wire           extsys0_slvacceptn_async;
  wire           extsys0_slvdeny_async;
  wire           extsys0_si_to_mi_wakeup_async;
  wire           extsys0_mi_to_si_wakeup_async;
  wire [3:0]     extsys0_aw_wr_ptr_async;
  wire [3:0]     extsys0_aw_rd_ptr_async;
  wire [315:0]   extsys0_aw_payld_async;
  wire [5:0]     extsys0_w_wr_ptr_async;
  wire [5:0]     extsys0_w_rd_ptr_async;
  wire [221:0]   extsys0_w_payld_async;
  wire [1:0]     extsys0_b_wr_ptr_async;
  wire [1:0]     extsys0_b_rd_ptr_async;
  wire [39:0]    extsys0_b_payld_async;
  wire [3:0]     extsys0_ar_wr_ptr_async;
  wire [3:0]     extsys0_ar_rd_ptr_async;
  wire [315:0]   extsys0_ar_payld_async;
  wire [3:0]     extsys0_r_wr_ptr_async;
  wire [3:0]     extsys0_r_rd_ptr_async;
  wire [211:0]   extsys0_r_payld_async;

  // External System 0 AXI Power Q-Channel signals
  wire           extsys0_axi_pwr_qreqn;
  wire           extsys0_axi_pwr_qacceptn;
  wire           extsys0_axi_pwr_qdeny;
  wire           extsys0_axi_pwr_qactive;

  // External System 0 APB Power Q-Channel signals
  wire           extsys0_apb_pwr_qreqn;
  wire           extsys0_apb_pwr_qacceptn;
  wire           extsys0_apb_pwr_qdeny;
  wire           extsys0_apb_pwr_qactive;
 
  // External System 1 AXI asynchronous signals
  wire           extsys1_slvmustacceptreqn_async;
  wire           extsys1_slvcandenyreqn_async;
  wire           extsys1_slvacceptn_async;
  wire           extsys1_slvdeny_async;
  wire           extsys1_si_to_mi_wakeup_async;
  wire           extsys1_mi_to_si_wakeup_async;
  wire [3:0]     extsys1_aw_wr_ptr_async;
  wire [3:0]     extsys1_aw_rd_ptr_async;
  wire [315:0]   extsys1_aw_payld_async;
  wire [5:0]     extsys1_w_wr_ptr_async;
  wire [5:0]     extsys1_w_rd_ptr_async;
  wire [221:0]   extsys1_w_payld_async;
  wire [1:0]     extsys1_b_wr_ptr_async;
  wire [1:0]     extsys1_b_rd_ptr_async;
  wire [39:0]    extsys1_b_payld_async;
  wire [3:0]     extsys1_ar_wr_ptr_async;
  wire [3:0]     extsys1_ar_rd_ptr_async;
  wire [315:0]   extsys1_ar_payld_async;
  wire [3:0]     extsys1_r_wr_ptr_async;
  wire [3:0]     extsys1_r_rd_ptr_async;
  wire [211:0]   extsys1_r_payld_async;

  // External System 1 AXI Power Q-Channel signals
  wire           extsys1_axi_pwr_qreqn;
  wire           extsys1_axi_pwr_qacceptn;
  wire           extsys1_axi_pwr_qdeny;
  wire           extsys1_axi_pwr_qactive;

  // External System 1 APB Power Q-Channel signals
  wire           extsys1_apb_pwr_qreqn;
  wire           extsys1_apb_pwr_qacceptn;
  wire           extsys1_apb_pwr_qdeny;
  wire           extsys1_apb_pwr_qactive;
 

  // Vultan APB signals
  wire           vultan_psel_s;
  wire           vultan_penable_s;
  wire [31:0]    vultan_paddr_s;
  wire           vultan_pwrite_s;
  wire [3:0]     vultan_pstrb_s;
  wire [31:0]    vultan_pwdata_s;
  wire [2:0]     vultan_pprot_s;
  wire [31:0]    vultan_prdata_s;
  wire           vultan_pready_s;
  wire           vultan_pslverr_s;

  // Vultan Q-Channels
  wire           vultan_clk_qreqn;
  wire           vultan_clk_qacceptn;
  wire           vultan_clk_qdeny;
  wire           vultan_clk_qactive;

  // HOSTAONEXPMST APB signals
  wire           aonexp_psel;
  wire           aonexp_penable;
  wire           aonexp_pwrite;
  wire [2:0]     aonexp_pprot;
  wire [3:0]     aonexp_pstrb;
  wire [31:0]    aonexp_paddr;
  wire [31:0]    aonexp_pwdata;
  wire [31:0]    aonexp_prdata;
  wire           aonexp_pready;
  wire           aonexp_pslverr;

 
  // External System 0 PPU APB Asynchronous signals
  wire           extsys0_ppu_apb_async_req;
  wire [47:0]    extsys0_ppu_apb_async_req_payload;
  wire [32:0]    extsys0_ppu_apb_async_resp_payload;
  wire           extsys0_ppu_apb_async_ack;

  // Signal between SSE710 top and External System 0 
  wire           extsys0_poresetn;
  wire           extsys0_cpuwait;

  wire           extsys0_dbgpresetsn;
  wire           extsys0_dbgpresetmn;
  wire           extsys0_atresetn;
  wire           extsys0_ctiresetn;
  wire           extsys0_aresetn;
  wire           extsys0_mhuresetn;

  wire           extsys0_dbgclks;
  wire           extsys0_dbgclkm;
  wire           extsys0_atclk;
  wire           extsys0_cticlk;
  wire           extsys0_aclk;
  wire           extsys0_mhuclk;

  wire           extsys0_mhupwrreq_qactive;
  wire           extsys0_mhupwr_qreqn;
  wire           extsys0_mhupwr_qacceptn;
  wire           extsys0_mhupwr_qdeny;

  wire           extsys0_mempwr_qreqn;
  wire           extsys0_mempwr_qacceptn;
  wire           extsys0_mempwr_qdeny;
  wire           extsys0_mempwr_qactive;

  wire           extsys0_traceexppwr_qreqn;
  wire           extsys0_traceexppwr_qacceptn;
  wire           extsys0_traceexppwr_qdeny;
  wire           extsys0_traceexppwr_qactive;

  wire           extsys0_dbgpwr_qreqn;
  wire           extsys0_dbgpwr_qacceptn;
  wire           extsys0_dbgpwr_qdeny;
  wire           extsys0_dbgpwr_qactive;

  wire           extsys0_extdbgpwr_qreqn;
  wire           extsys0_extdbgpwr_qacceptn;
  wire           extsys0_extdbgpwr_qdeny;
  wire           extsys0_extdbgpwr_qactive;

  wire           extsys0_ctiinpwr_qreqn;
  wire           extsys0_ctiinpwr_qacceptn;
  wire           extsys0_ctiinpwr_qdeny;
  wire           extsys0_ctiinpwr_qactive;

  wire           extsys0_ctioutpwr_qreqn;
  wire           extsys0_ctioutpwr_qacceptn;
  wire           extsys0_ctioutpwr_qdeny;
  wire           extsys0_ctioutpwr_qactive;

  wire           extsys0_dbgtop_qreqn;
  wire           extsys0_dbgtop_qacceptn;
  wire           extsys0_dbgtop_qdeny;
  wire           extsys0_dbgtop_qactive;

  wire           extsys0_systop_qreqn;
  wire           extsys0_systop_qacceptn;
  wire           extsys0_systop_qdeny;
  wire           extsys0_systop_qactive;

  wire           extsys0_aontop_qreqn;
  wire           extsys0_aontop_qacceptn;
  wire           extsys0_aontop_qdeny;
  wire           extsys0_aontop_qactive;

  wire           extsys0_extdbgrom_cdbgpwrupreq;
  wire           extsys0_axiaprom_csyspwrupreq;
  wire           extsys0_extdbgrom_cdbgpwrupack;
  wire           extsys0_axiaprom_csyspwrupack;

  wire [4:0]     extsys0_rstsyn;

  wire           extsys0_dbg_psel;
  wire           extsys0_dbg_pwakeup;
  wire           extsys0_dbg_penable;
  wire [31:0]    extsys0_dbg_paddr;
  wire           extsys0_dbg_pwrite;
  wire [31:0]    extsys0_dbg_pwdata;
  wire [3:0]     extsys0_dbg_pstrb;
  wire [2:0]     extsys0_dbg_pprot;
  wire [31:0]    extsys0_dbg_prdata;
  wire           extsys0_dbg_pready;
  wire           extsys0_dbg_pslverr;
  wire           extsys0_dbg_dpabort;

  wire           extsys0_aclk_qreqn;
  wire           extsys0_aclk_qacceptn;
  wire           extsys0_aclk_qdeny;
  wire           extsys0_aclk_qactive;

  wire           extsys0_mhuclk_qreqn;
  wire           extsys0_mhuclk_qacceptn;
  wire           extsys0_mhuclk_qdeny;
  wire           extsys0_mhuclk_qactive;

  wire           extsys0_atclk_qreqn;
  wire           extsys0_atclk_qacceptn;
  wire           extsys0_atclk_qdeny;
  wire           extsys0_atclk_qactive;

  wire           extsys0_dbgclkm_qreqn;
  wire           extsys0_dbgclkm_qacceptn;
  wire           extsys0_dbgclkm_qdeny;
  wire           extsys0_dbgclkm_qactive;

  wire           extsys0_dbgclks_qreqn;
  wire           extsys0_dbgclks_qacceptn;
  wire           extsys0_dbgclks_qdeny;
  wire           extsys0_dbgclks_qactive;

  wire           extsys0_cticlk_qreqn;
  wire           extsys0_cticlk_qacceptn;
  wire           extsys0_cticlk_qdeny;
  wire           extsys0_cticlk_qactive;

  wire           extsys0_mem_awakeup;
  wire           extsys0_mem_awid;
  wire [31:0]    extsys0_mem_awaddr;
  wire [7:0]     extsys0_mem_awlen;
  wire [2:0]     extsys0_mem_awsize;
  wire [1:0]     extsys0_mem_awburst;
  wire           extsys0_mem_awlock;
  wire [3:0]     extsys0_mem_awcache;
  wire [2:0]     extsys0_mem_awprot;
  wire           extsys0_mem_awvalid;
  wire           extsys0_mem_awready;
  wire [7:0]     extsys0_mem_wstrb;
  wire           extsys0_mem_wlast;
  wire           extsys0_mem_wvalid;
  wire [63:0]    extsys0_mem_wdata;
  wire           extsys0_mem_wready;
  wire           extsys0_mem_bid;
   
  wire [6:0]     extsys0_mem_bid_unused;
   
  wire [1:0]     extsys0_mem_bresp;
  wire           extsys0_mem_bvalid;
  wire           extsys0_mem_bready;
  wire           extsys0_mem_arid;
  wire [31:0]    extsys0_mem_araddr;
  wire [7:0]     extsys0_mem_arlen;
  wire [2:0]     extsys0_mem_arsize;
  wire [1:0]     extsys0_mem_arburst;
  wire           extsys0_mem_arlock;
  wire [3:0]     extsys0_mem_arcache;
  wire [2:0]     extsys0_mem_arprot;
  wire           extsys0_mem_arvalid;
  wire           extsys0_mem_arready;
  wire           extsys0_mem_rid;
   
  wire [6:0]     extsys0_mem_rid_unused;
   
  wire [1:0]     extsys0_mem_rresp;
  wire           extsys0_mem_rlast;
  wire           extsys0_mem_rvalid;
  wire [63:0]    extsys0_mem_rdata;
  wire           extsys0_mem_rready;

  wire           extsys0_mhu_psel;
  wire           extsys0_mhu_pwakeup;
  wire           extsys0_mhu_penable;
  wire [18:0]    extsys0_mhu_paddr;
  wire           extsys0_mhu_pwrite;
  wire [31:0]    extsys0_mhu_pwdata;
  wire [3:0]     extsys0_mhu_pstrb;
  wire [2:0]     extsys0_mhu_pprot;
  wire [31:0]    extsys0_mhu_prdata;
  wire           extsys0_mhu_pready;
  wire           extsys0_mhu_pslverr;

  wire           extsys0_extdbg_psel;
  wire           extsys0_extdbg_pwakeup;
  wire           extsys0_extdbg_penable;
  wire [31:0]    extsys0_extdbg_paddr;
  wire           extsys0_extdbg_pwrite;
  wire [31:0]    extsys0_extdbg_pwdata;
  wire [3:0]     extsys0_extdbg_pstrb;
  wire [2:0]     extsys0_extdbg_pprot;
  wire [31:0]    extsys0_extdbg_prdata;
  wire           extsys0_extdbg_pready;
  wire           extsys0_extdbg_pslverr;

  wire           extsys0_hes_mhu0_comb_int;
  wire           extsys0_esh_mhu0_comb_int;
  wire           extsys0_sees_mhu0_comb_int;
  wire           extsys0_esse_mhu0_comb_int;
   
  wire           extsys0_hes_mhu1_comb_int;
  wire           extsys0_esh_mhu1_comb_int;  
  wire           extsys0_sees_mhu1_comb_int;
  wire           extsys0_esse_mhu1_comb_int;  
   
  wire [95:0]    extsys0_shdint;

  wire           extsys0_traceexp_atready;
  wire           extsys0_traceexp_afvalid;
  wire           extsys0_traceexp_syncreq;
  wire [6:0]     extsys0_traceexp_atid;
  wire           extsys0_traceexp_atvalid;
  wire [31:0]    extsys0_traceexp_atdata;
  wire [1:0]     extsys0_traceexp_atbytes;
  wire           extsys0_traceexp_afready;
  wire           extsys0_traceexp_atwakeup;

  wire           extsys0_dbgen;
  wire           extsys0_niden;
  wire           extsys0_dapen;

  wire [3:0]     extsys0_ctichin;
  wire [3:0]     extsys0_ctichout;

  // Signals between the EXYSYS 0 TOP and CORE domains
  wire           extsys0_clk;

  wire           extsys0_mtx_resetn;
  wire           extsys0_core_resetn;
  wire           extsys0_dbg_resetn;

  wire           extsys0_sysreg_apb_async_req;
  wire [47:0]    extsys0_sysreg_apb_async_req_payload;
  wire [32:0]    extsys0_sysreg_apb_async_resp_payload;
  wire           extsys0_sysreg_apb_async_ack;
  
  wire           extsys0_uart_apb_async_req;
  wire [47:0]    extsys0_uart_apb_async_req_payload;
  wire [32:0]    extsys0_uart_apb_async_resp_payload;
  wire           extsys0_uart_apb_async_ack;  

  wire [8:0]     extsys0_clock_override_extsystop;
  wire           extsys0_sleeping;
  wire           extsys0_sleep_hold_ackn;
  wire           extsys0_sysreset_req;
  wire           extsys0_sleep_hold_reqn;  
 
  // External System 1 PPU APB Asynchronous signals
  wire           extsys1_ppu_apb_async_req;
  wire [47:0]    extsys1_ppu_apb_async_req_payload;
  wire [32:0]    extsys1_ppu_apb_async_resp_payload;
  wire           extsys1_ppu_apb_async_ack;

  // Signal between SSE710 top and External System 1 
  wire           extsys1_poresetn;
  wire           extsys1_cpuwait;

  wire           extsys1_dbgpresetsn;
  wire           extsys1_dbgpresetmn;
  wire           extsys1_atresetn;
  wire           extsys1_ctiresetn;
  wire           extsys1_aresetn;
  wire           extsys1_mhuresetn;

  wire           extsys1_dbgclks;
  wire           extsys1_dbgclkm;
  wire           extsys1_atclk;
  wire           extsys1_cticlk;
  wire           extsys1_aclk;
  wire           extsys1_mhuclk;

  wire           extsys1_mhupwrreq_qactive;
  wire           extsys1_mhupwr_qreqn;
  wire           extsys1_mhupwr_qacceptn;
  wire           extsys1_mhupwr_qdeny;

  wire           extsys1_mempwr_qreqn;
  wire           extsys1_mempwr_qacceptn;
  wire           extsys1_mempwr_qdeny;
  wire           extsys1_mempwr_qactive;

  wire           extsys1_traceexppwr_qreqn;
  wire           extsys1_traceexppwr_qacceptn;
  wire           extsys1_traceexppwr_qdeny;
  wire           extsys1_traceexppwr_qactive;

  wire           extsys1_dbgpwr_qreqn;
  wire           extsys1_dbgpwr_qacceptn;
  wire           extsys1_dbgpwr_qdeny;
  wire           extsys1_dbgpwr_qactive;

  wire           extsys1_extdbgpwr_qreqn;
  wire           extsys1_extdbgpwr_qacceptn;
  wire           extsys1_extdbgpwr_qdeny;
  wire           extsys1_extdbgpwr_qactive;

  wire           extsys1_ctiinpwr_qreqn;
  wire           extsys1_ctiinpwr_qacceptn;
  wire           extsys1_ctiinpwr_qdeny;
  wire           extsys1_ctiinpwr_qactive;

  wire           extsys1_ctioutpwr_qreqn;
  wire           extsys1_ctioutpwr_qacceptn;
  wire           extsys1_ctioutpwr_qdeny;
  wire           extsys1_ctioutpwr_qactive;

  wire           extsys1_dbgtop_qreqn;
  wire           extsys1_dbgtop_qacceptn;
  wire           extsys1_dbgtop_qdeny;
  wire           extsys1_dbgtop_qactive;

  wire           extsys1_systop_qreqn;
  wire           extsys1_systop_qacceptn;
  wire           extsys1_systop_qdeny;
  wire           extsys1_systop_qactive;

  wire           extsys1_aontop_qreqn;
  wire           extsys1_aontop_qacceptn;
  wire           extsys1_aontop_qdeny;
  wire           extsys1_aontop_qactive;

  wire           extsys1_extdbgrom_cdbgpwrupreq;
  wire           extsys1_axiaprom_csyspwrupreq;
  wire           extsys1_extdbgrom_cdbgpwrupack;
  wire           extsys1_axiaprom_csyspwrupack;

  wire [4:0]     extsys1_rstsyn;

  wire           extsys1_dbg_psel;
  wire           extsys1_dbg_pwakeup;
  wire           extsys1_dbg_penable;
  wire [31:0]    extsys1_dbg_paddr;
  wire           extsys1_dbg_pwrite;
  wire [31:0]    extsys1_dbg_pwdata;
  wire [3:0]     extsys1_dbg_pstrb;
  wire [2:0]     extsys1_dbg_pprot;
  wire [31:0]    extsys1_dbg_prdata;
  wire           extsys1_dbg_pready;
  wire           extsys1_dbg_pslverr;
  wire           extsys1_dbg_dpabort;

  wire           extsys1_aclk_qreqn;
  wire           extsys1_aclk_qacceptn;
  wire           extsys1_aclk_qdeny;
  wire           extsys1_aclk_qactive;

  wire           extsys1_mhuclk_qreqn;
  wire           extsys1_mhuclk_qacceptn;
  wire           extsys1_mhuclk_qdeny;
  wire           extsys1_mhuclk_qactive;

  wire           extsys1_atclk_qreqn;
  wire           extsys1_atclk_qacceptn;
  wire           extsys1_atclk_qdeny;
  wire           extsys1_atclk_qactive;

  wire           extsys1_dbgclkm_qreqn;
  wire           extsys1_dbgclkm_qacceptn;
  wire           extsys1_dbgclkm_qdeny;
  wire           extsys1_dbgclkm_qactive;

  wire           extsys1_dbgclks_qreqn;
  wire           extsys1_dbgclks_qacceptn;
  wire           extsys1_dbgclks_qdeny;
  wire           extsys1_dbgclks_qactive;

  wire           extsys1_cticlk_qreqn;
  wire           extsys1_cticlk_qacceptn;
  wire           extsys1_cticlk_qdeny;
  wire           extsys1_cticlk_qactive;

  wire           extsys1_mem_awakeup;
  wire           extsys1_mem_awid;
  wire [31:0]    extsys1_mem_awaddr;
  wire [7:0]     extsys1_mem_awlen;
  wire [2:0]     extsys1_mem_awsize;
  wire [1:0]     extsys1_mem_awburst;
  wire           extsys1_mem_awlock;
  wire [3:0]     extsys1_mem_awcache;
  wire [2:0]     extsys1_mem_awprot;
  wire           extsys1_mem_awvalid;
  wire           extsys1_mem_awready;
  wire [7:0]     extsys1_mem_wstrb;
  wire           extsys1_mem_wlast;
  wire           extsys1_mem_wvalid;
  wire [63:0]    extsys1_mem_wdata;
  wire           extsys1_mem_wready;
  wire           extsys1_mem_bid;
   
  wire [6:0]     extsys1_mem_bid_unused;
   
  wire [1:0]     extsys1_mem_bresp;
  wire           extsys1_mem_bvalid;
  wire           extsys1_mem_bready;
  wire           extsys1_mem_arid;
  wire [31:0]    extsys1_mem_araddr;
  wire [7:0]     extsys1_mem_arlen;
  wire [2:0]     extsys1_mem_arsize;
  wire [1:0]     extsys1_mem_arburst;
  wire           extsys1_mem_arlock;
  wire [3:0]     extsys1_mem_arcache;
  wire [2:0]     extsys1_mem_arprot;
  wire           extsys1_mem_arvalid;
  wire           extsys1_mem_arready;
  wire           extsys1_mem_rid;
   
  wire [6:0]     extsys1_mem_rid_unused;
   
  wire [1:0]     extsys1_mem_rresp;
  wire           extsys1_mem_rlast;
  wire           extsys1_mem_rvalid;
  wire [63:0]    extsys1_mem_rdata;
  wire           extsys1_mem_rready;

  wire           extsys1_mhu_psel;
  wire           extsys1_mhu_pwakeup;
  wire           extsys1_mhu_penable;
  wire [18:0]    extsys1_mhu_paddr;
  wire           extsys1_mhu_pwrite;
  wire [31:0]    extsys1_mhu_pwdata;
  wire [3:0]     extsys1_mhu_pstrb;
  wire [2:0]     extsys1_mhu_pprot;
  wire [31:0]    extsys1_mhu_prdata;
  wire           extsys1_mhu_pready;
  wire           extsys1_mhu_pslverr;

  wire           extsys1_extdbg_psel;
  wire           extsys1_extdbg_pwakeup;
  wire           extsys1_extdbg_penable;
  wire [31:0]    extsys1_extdbg_paddr;
  wire           extsys1_extdbg_pwrite;
  wire [31:0]    extsys1_extdbg_pwdata;
  wire [3:0]     extsys1_extdbg_pstrb;
  wire [2:0]     extsys1_extdbg_pprot;
  wire [31:0]    extsys1_extdbg_prdata;
  wire           extsys1_extdbg_pready;
  wire           extsys1_extdbg_pslverr;

  wire           extsys1_hes_mhu0_comb_int;
  wire           extsys1_esh_mhu0_comb_int;
  wire           extsys1_sees_mhu0_comb_int;
  wire           extsys1_esse_mhu0_comb_int;
   
  wire           extsys1_hes_mhu1_comb_int;
  wire           extsys1_esh_mhu1_comb_int;  
  wire           extsys1_sees_mhu1_comb_int;
  wire           extsys1_esse_mhu1_comb_int;  
   
  wire [95:0]    extsys1_shdint;

  wire           extsys1_traceexp_atready;
  wire           extsys1_traceexp_afvalid;
  wire           extsys1_traceexp_syncreq;
  wire [6:0]     extsys1_traceexp_atid;
  wire           extsys1_traceexp_atvalid;
  wire [31:0]    extsys1_traceexp_atdata;
  wire [1:0]     extsys1_traceexp_atbytes;
  wire           extsys1_traceexp_afready;
  wire           extsys1_traceexp_atwakeup;

  wire           extsys1_dbgen;
  wire           extsys1_niden;
  wire           extsys1_dapen;

  wire [3:0]     extsys1_ctichin;
  wire [3:0]     extsys1_ctichout;

  // Signals between the EXYSYS 1 TOP and CORE domains
  wire           extsys1_clk;

  wire           extsys1_mtx_resetn;
  wire           extsys1_core_resetn;
  wire           extsys1_dbg_resetn;

  wire           extsys1_sysreg_apb_async_req;
  wire [47:0]    extsys1_sysreg_apb_async_req_payload;
  wire [32:0]    extsys1_sysreg_apb_async_resp_payload;
  wire           extsys1_sysreg_apb_async_ack;
  
  wire           extsys1_uart_apb_async_req;
  wire [47:0]    extsys1_uart_apb_async_req_payload;
  wire [32:0]    extsys1_uart_apb_async_resp_payload;
  wire           extsys1_uart_apb_async_ack;  

  wire [8:0]     extsys1_clock_override_extsystop;
  wire           extsys1_sleeping;
  wire           extsys1_sleep_hold_ackn;
  wire           extsys1_sysreset_req;
  wire           extsys1_sleep_hold_reqn;  
 

 
 

 
  // Host Expansion ACLK Q-Channel
  wire [3:0]     hostexp_aclk_qreqn;
  wire [3:0]     hostexp_aclk_qacceptn;
  wire [3:0]     hostexp_aclk_qdeny;
  wire [3:0]     hostexp_aclk_qactive;
 

  wire           sram_ctrl_clk_qreqn;
  wire           sram_ctrl_clk_qacceptn;  
  wire           sram_ctrl_clk_qdeny;  
  wire           sram_ctrl_clk_qactive;  
  
 
   
  wire [8:0]     aclk_qreq_unused;
   
 
  
  // DBGTOP Expansion Q-Channels
  wire [2:0]     dbgtop_qreqn;
    
  wire [7:0]     dbgclk_qreqn;
 

  // SYSTOP Expansion
  wire           systop_qreqn_egress;
  wire           systop_qacceptn_egress;
  wire           systop_qreqn_internal;
  wire           systop_qreqn_ingress;
  wire           systop_qacceptn_internal;
  wire           systop_qdeny_internal;
  wire           systop_qactive_internal;

  // SCB bits
  wire [63:0]    scb_soc_expansion;
  
  // Debug System power up request loop back
  wire [15:0]    hostdbgpwrreq;

  // Debug Trace Expansion loop back
  wire           afvalidhostdbgtraceexp;
  
 
  
  // unused signals for LINTing
  wire           unused;

// -----------------------------------------------------------------------------
// SSE710 top

  top_sse710_r0_aontop_3 u_top_sse710_r0_aontop (

    .S32KCLK                                (S32KCLK),
    .REFCLK                                 (REFCLK),
    .SECENCREFCLK                           (SECENCREFCLK),
    .TRACECLKIN                             (TRACECLKIN),
    .UARTCLK                                (UARTCLK),
    .SYSPLL                                 (SYSPLL),
    .SYSPLLLOCK                             (SYSPLLLOCK),
    .CPUPLL                                 (CPUPLL),
    .CPUPLLLOCK                             (CPUPLLLOCK),
    
    .ACLKOUT                                (aclkout_i),
    .DBGCLKOUT                              (), // Not used because no additional debug component in the Inegration Layer
    .HOSTAONEXPCLK                          (hostaonexpclk),
    .TRACECLKOUT                            (TRACECLKOUT),
    .HOSTCNTCLKOUT                          (hostcntclkout),
    .HOSTS32KCNTCLKOUT                      (hosts32kcntclkout),
    
 

    .PORESETn                               (PORESETn),
    .nSRST                                  (nSRST),
    .AONTOPPORESETn                         (),
    .AONTOPWARMRESETn                       (aontop_warmresetn),
    .SYSTOPWARMRESETn                       (systop_warmresetn),
    .DBGTOPWARMRESETn                       (dbgtop_warmresetn),
 
    
    .SOCPRTID                               (12'h763), // SSE710 Subsystem Integration Layer - SoC ID
    .SOCVAR                                 (eco_socvar), 
    .SOCREV                                 (eco_socrev), 
    .SOCIMPLID                              (11'h23B), // Implementer of this Example Integration Layer is Arm
    
    .DPROMPRTID                             (12'h764), // SSE710 Subsystem Integration Layer - DP ROM table ID
    .DPROMVAR                               (eco_dpromvar), 
    .DPROMREV                               (eco_dpromrev), 
    .DPROMIMPLID                            (11'h23B), // Implementer of this Example Integration Layer is Arm
    
    .EXTDBGROMPRTID                         (12'h765), // SSE710 Subsystem Integration Layer - EXTDBG ROM table ID
    .EXTDBGROMVAR                           (eco_extdbgromvar), 
    .EXTDBGROMREV                           (eco_extdbgromrev), 
    .EXTDBGROMIMPLID                        (11'h23B), // Implementer of this Example Integration Layer is Arm
    
    .HOSTROMPRTID                           (12'h766), // SSE710 Subsystem Integration Layer - HOST ROM table ID
    .HOSTROMVAR                             (eco_hostromvar), 
    .HOSTROMREV                             (eco_hostromrev), 
    .HOSTROMIMPLID                          (11'h23B), // Implementer of this Example Integration Layer is Arm
    
    .HOSTAXIAPROMPRTID                      (12'h767), // SSE710 Subsystem Integration Layer - HOSTAXIAP ROM table ID
    .HOSTAXIAPROMVAR                        (eco_hostaxiapromvar), 
    .HOSTAXIAPROMREV                        (eco_hostaxiapromrev), 
    .HOSTAXIAPROMIMPLID                     (11'h23B), // Implementer of this Example Integration Layer is Arm

 
    .OCVMSIZE                               (8'h1F), // 2GB Off-Chip Volatile Memory
 
    .XNVMSIZE                               (8'h16), // 4MB eXecute in place Non-Volatile Memory
    .CVMSIZE                                (8'h16), // 4MB On-Chip Volatile Memory

 
    .EXPSHDINT                              (exp_shd_int),    
 

    .GICWAKEUP                              (gic_wakeup),

    .SWCLKTCK                               (SWCLKTCK),
    .nTRST                                  (nTRST),
    
    .HOSTDBGPWRREQ                          (hostdbgpwrreq), // Looped back as the interface is not used
    .HOSTDBGPWRACK                          (hostdbgpwrreq),
    
    .SWDITMS                                (SWDITMS),
    .SWDO                                   (SWDO),
    .SWDOEN                                 (SWDOEN),
    .TDI                                    (TDI),
    .TDO                                    (TDO),
    .TDOENn                                 (TDOENn),
    .SWACTIVE                               (SWACTIVE),
    .JTAGACTIVE                             (JTAGACTIVE),
    .JTAGIR                                 (JTAGIR),
    .JTAGSTATE                              (JTAGSTATE),
    .DORMANTSTATE                           (DORMANTSTATE),

    .DFTRAMHOLD                             (DFTRAMHOLD),
    .DFTMCPHOLD                             (DFTMCPHOLD),
    .DFTCGEN                                (DFTCGEN),
    .DFTRSTDISABLE                          (DFTRSTDISABLE),
    .DFTPWRUP                               (DFTPWRUP),
    .DFTISODISABLE                          (DFTISODISABLE),
    .DFTENABLE                              (DFTENABLE),
    .MBISTREQ                               (MBISTREQ),
    .nMBISTRESET                            (nMBISTRESET),
    
    .DFTDIVSEL                              (DFTDIVSEL),
    .DFTHOSTUARTCLKSEL                      (DFTHOSTUARTCLKSEL),
    .DFTCTRLCLKSEL                          (DFTCTRLCLKSEL),
    .DFTGICCLKSEL                           (DFTGICCLKSEL),
    .DFTACLKSEL                             (DFTACLKSEL),
    .DFTDBGCLKSEL                           (DFTDBGCLKSEL),
    .DFTSECCLKSEL                           (DFTSECCLKSEL),
    .DFTCLKSELEN                            (DFTCLKSELEN),
    .DFTHOSTCPUCLKSEL                       (DFTHOSTCPUCLKSEL),
    .DFTDIVBYPASS                           (DFTDIVBYPASS),
    .DFTRETDISABLE                          (DFTRETDISABLE),
    .DFTSE                                  (DFTSE),
    
    .ATWAKEUPHOSTDBGTRACEEXP                (1'b0), // No trace source in the Integration Layer
    .ATIDHOSTDBGTRACEEXP                    (7'h00),
    .ATBYTESHOSTDBGTRACEEXP                 (2'h0),
    .ATDATAHOSTDBGTRACEEXP                  (32'h0000_0000),
    .ATVALIDHOSTDBGTRACEEXP                 (1'b0),
    .ATREADYHOSTDBGTRACEEXP                 (),
    .AFVALIDHOSTDBGTRACEEXP                 (afvalidhostdbgtraceexp),
    .AFREADYHOSTDBGTRACEEXP                 (afvalidhostdbgtraceexp),
    .SYNCREQHOSTDBGTRACEEXP                 (),
    
    .HOSTCTICHINEXP                         (4'h0), // No CTI or CTM in the Integration Layer
    .HOSTCTICHOUTEXP                        (),
    
    .PWAKEUPHOSTDBGEXP                      (), // No additiional debug components in the Integration Layer
    .PSELHOSTDBGEXP                         (),
    .PENABLEHOSTDBGEXP                      (),
    .PWRITEHOSTDBGEXP                       (),
    .PPROTHOSTDBGEXP                        (),
    .PSTRBHOSTDBGEXP                        (),
    .PADDRHOSTDBGEXP                        (),
    .PWDATAHOSTDBGEXP                       (),
    .PREADYHOSTDBGEXP                       (1'b1),
    .PSLVERRHOSTDBGEXP                      (1'b1),
    .PRDATAHOSTDBGEXP                       (32'h0000_0000),
    
    .HOSTSTMDPRDRREADY                      (1'b0), // No DMA in the Intergration Layer
    .HOSTSTMDPRDAVALID                      (1'b0),
    .HOSTSTMDPRDATYPE                       (2'b00),
    .HOSTSTMDPRDRVALID                      (),
    .HOSTSTMDPRDRTYPE                       (),
    .HOSTSTMDPRDRLAST                       (),
    .HOSTSTMDPRDAREADY                      (),
    
    .SCBEXP                                 (scb_soc_expansion),
    
    .SOCLCC                                 (1'b0), 

    .TPIUTRACEDATA                          (TPIUTRACEDATA),
    .TPIUTRACECTL                           (TPIUTRACECTL),
    .TPIUTRACEMAXDATASIZE                   (TPIUTRACEMAXDATASIZE),
    .TPIUTPCTLVALID                         (TPIUTPCTLVALID),

    .REFCLKQREQn                            (1'b1), 
    .REFCLKQACCEPTn                         (),
    .REFCLKQDENY                            (),
    .REFCLKQACTIVE                          (),
    
 
    .ACLKQREQn                              ({aclk_qreq_unused                            ,sram_ctrl_clk_qreqn   ,hostexp_aclk_qreqn   , vultan_clk_qreqn}),
    .ACLKQACCEPTn                           ({aclk_qreq_unused                            ,sram_ctrl_clk_qacceptn,hostexp_aclk_qacceptn, vultan_clk_qacceptn}),
    .ACLKQDENY                              ({{9{1'b0}} ,sram_ctrl_clk_qdeny   ,hostexp_aclk_qdeny   , vultan_clk_qdeny}),
    .ACLKQACTIVE                            ({{9{1'b0}} ,sram_ctrl_clk_qactive ,hostexp_aclk_qactive , vultan_clk_qactive}),
 
    
    .DBGCLKQREQn                            (dbgclk_qreqn),
    .DBGCLKQACCEPTn                         (dbgclk_qreqn),
    .DBGCLKQDENY                            ({8{1'b0}}), 
    .DBGCLKQACTIVE                          ({8{1'b0}}),        

    .SYSTOPQREQn                            ({systop_qreqn_egress   , systop_qreqn_internal   , systop_qreqn_ingress }),
    .SYSTOPQACCEPTn                         ({systop_qacceptn_egress, systop_qacceptn_internal, systop_qreqn_ingress }),
    .SYSTOPQDENY                            ({1'b0                  , systop_qdeny_internal   , 1'b0                 }),
    .SYSTOPQACTIVE                          ({1'b0                  , systop_qactive_internal , 1'b0                 }),

    .DBGTOPQREQn                            (dbgtop_qreqn),
    .DBGTOPQACCEPTn                         (dbgtop_qreqn),
    .DBGTOPQDENY                            (3'b000),
    .DBGTOPQACTIVE                          (3'b000),

    .AWAKEUPCVM                             (cvm_awakeup),
    .AWIDCVM                                (cvm_awid),
    .AWADDRCVM                              (cvm_awaddr),
    .AWLENCVM                               (cvm_awlen),
    .AWSIZECVM                              (cvm_awsize),
    .AWBURSTCVM                             (cvm_awburst),
    .AWLOCKCVM                              (cvm_awlock),
    .AWCACHECVM                             (cvm_awcache),
    .AWPROTCVM                              (cvm_awprot),
    .AWVALIDCVM                             (cvm_awvalid),
    .AWREADYCVM                             (cvm_awready),
    .WDATACVM                               (cvm_wdata),
    .WSTRBCVM                               (cvm_wstrb),
    .WLASTCVM                               (cvm_wlast),
    .WVALIDCVM                              (cvm_wvalid),
    .WREADYCVM                              (cvm_wready),
    .BIDCVM                                 (cvm_bid),
    .BRESPCVM                               (cvm_bresp),
    .BVALIDCVM                              (cvm_bvalid),
    .BREADYCVM                              (cvm_bready),
    .ARIDCVM                                (cvm_arid),
    .ARADDRCVM                              (cvm_araddr),
    .ARLENCVM                               (cvm_arlen),
    .ARSIZECVM                              (cvm_arsize),
    .ARBURSTCVM                             (cvm_arburst),
    .ARLOCKCVM                              (cvm_arlock),
    .ARCACHECVM                             (cvm_arcache),
    .ARPROTCVM                              (cvm_arprot),
    .ARVALIDCVM                             (cvm_arvalid),
    .ARREADYCVM                             (cvm_arready),
    .RIDCVM                                 (cvm_rid),
    .RDATACVM                               (cvm_rdata),
    .RRESPCVM                               (cvm_rresp),
    .RLASTCVM                               (cvm_rlast),
    .RVALIDCVM                              (cvm_rvalid),
    .RREADYCVM                              (cvm_rready),
    .AWMMUSIDCVM                            (cvm_awmmusid),
    .AWUSERCVM                              (cvm_awuser),
    .ARMMUSIDCVM                            (cvm_armmusid),
    .ARUSERCVM                              (cvm_aruser),
    .AWQOSCVM                               (cvm_awqos),
    .ARQOSCVM                               (cvm_arqos),
    
    .AWAKEUPXNVM                            (xnvm_awakeup),
    .AWIDXNVM                               (xnvm_awid),
    .AWADDRXNVM                             (xnvm_awaddr),
    .AWLENXNVM                              (xnvm_awlen),
    .AWSIZEXNVM                             (xnvm_awsize),
    .AWBURSTXNVM                            (xnvm_awburst),
    .AWLOCKXNVM                             (xnvm_awlock),
    .AWCACHEXNVM                            (xnvm_awcache),
    .AWPROTXNVM                             (xnvm_awprot),
    .AWVALIDXNVM                            (xnvm_awvalid),
    .AWREADYXNVM                            (xnvm_awready),
    .WDATAXNVM                              (xnvm_wdata),
    .WSTRBXNVM                              (xnvm_wstrb),
    .WLASTXNVM                              (xnvm_wlast),
    .WVALIDXNVM                             (xnvm_wvalid),
    .WREADYXNVM                             (xnvm_wready),
    .BIDXNVM                                (xnvm_bid),
    .BRESPXNVM                              (xnvm_bresp),
    .BVALIDXNVM                             (xnvm_bvalid),
    .BREADYXNVM                             (xnvm_bready),
    .ARIDXNVM                               (xnvm_arid),
    .ARADDRXNVM                             (xnvm_araddr),
    .ARLENXNVM                              (xnvm_arlen),
    .ARSIZEXNVM                             (xnvm_arsize),
    .ARBURSTXNVM                            (xnvm_arburst),
    .ARLOCKXNVM                             (xnvm_arlock),
    .ARCACHEXNVM                            (xnvm_arcache),
    .ARPROTXNVM                             (xnvm_arprot),
    .ARVALIDXNVM                            (xnvm_arvalid),
    .ARREADYXNVM                            (xnvm_arready),
    .RIDXNVM                                (xnvm_rid),
    .RDATAXNVM                              (xnvm_rdata),
    .RRESPXNVM                              (xnvm_rresp),
    .RLASTXNVM                              (xnvm_rlast),
    .RVALIDXNVM                             (xnvm_rvalid),
    .RREADYXNVM                             (xnvm_rready),
    .AWUSERXNVM                             (xnvm_awuser),
    .AWMMUSIDXNVM                           (xnvm_awmmusid),
    .ARUSERXNVM                             (xnvm_aruser),
    .ARMMUSIDXNVM                           (xnvm_armmusid),
    .AWQOSXNVM                              (xnvm_awqos),
    .ARQOSXNVM                              (xnvm_arqos),

 
    .AWAKEUPOCVM                            (AWAKEUPOCVM),
    .AWIDOCVM                               (AWIDOCVM),
    .AWADDROCVM                             (AWADDROCVM),
    .AWLENOCVM                              (AWLENOCVM),
    .AWSIZEOCVM                             (AWSIZEOCVM),
    .AWBURSTOCVM                            (AWBURSTOCVM),
    .AWLOCKOCVM                             (AWLOCKOCVM),
    .AWCACHEOCVM                            (AWCACHEOCVM),
    .AWPROTOCVM                             (AWPROTOCVM),
    .AWVALIDOCVM                            (AWVALIDOCVM),
    .AWREADYOCVM                            (AWREADYOCVM),
    .WDATAOCVM                              (WDATAOCVM),
    .WSTRBOCVM                              (WSTRBOCVM),
    .WLASTOCVM                              (WLASTOCVM),
    .WVALIDOCVM                             (WVALIDOCVM),
    .WREADYOCVM                             (WREADYOCVM),
    .BIDOCVM                                (BIDOCVM),
    .BRESPOCVM                              (BRESPOCVM),
    .BVALIDOCVM                             (BVALIDOCVM),
    .BREADYOCVM                             (BREADYOCVM),
    .ARIDOCVM                               (ARIDOCVM),
    .ARADDROCVM                             (ARADDROCVM),
    .ARLENOCVM                              (ARLENOCVM),
    .ARSIZEOCVM                             (ARSIZEOCVM),
    .ARBURSTOCVM                            (ARBURSTOCVM),
    .ARLOCKOCVM                             (ARLOCKOCVM),
    .ARCACHEOCVM                            (ARCACHEOCVM),
    .ARPROTOCVM                             (ARPROTOCVM),
    .ARVALIDOCVM                            (ARVALIDOCVM),
    .ARREADYOCVM                            (ARREADYOCVM),
    .RIDOCVM                                (RIDOCVM),
    .RDATAOCVM                              (RDATAOCVM),
    .RRESPOCVM                              (RRESPOCVM),
    .RLASTOCVM                              (RLASTOCVM),
    .RVALIDOCVM                             (RVALIDOCVM),
    .RREADYOCVM                             (RREADYOCVM),
    .AWUSEROCVM                             (AWUSEROCVM),
    .ARUSEROCVM                             (ARUSEROCVM),
    .ARMMUSIDOCVM                           (ARMMUSIDOCVM),
    .AWMMUSIDOCVM                           (AWMMUSIDOCVM),
    .AWQOSOCVM                              (AWQOSOCVM),
    .ARQOSOCVM                              (ARQOSOCVM),
 

 

    .AWAKEUPEXPSLV0                         (1'b0),
    .AWIDEXPSLV0                            (8'h0),
    .AWADDREXPSLV0                          (32'h0000_0000),
    .AWLENEXPSLV0                           (8'h00),
    .AWSIZEEXPSLV0                          (3'h0),
    .AWBURSTEXPSLV0                         (2'h0),
    .AWLOCKEXPSLV0                          (1'h0),
    .AWCACHEEXPSLV0                         (4'h0),
    .AWPROTEXPSLV0                          (3'h0),
    .AWVALIDEXPSLV0                         (1'h0),
    .AWREADYEXPSLV0                         (),
    .WDATAEXPSLV0                           (64'h0),
    .WSTRBEXPSLV0                           (8'h0),
    .WLASTEXPSLV0                           (1'h0),
    .WVALIDEXPSLV0                          (1'h0),
    .WREADYEXPSLV0                          (),
    .BIDEXPSLV0                             (),
    .BRESPEXPSLV0                           (),
    .BVALIDEXPSLV0                          (),
    .BREADYEXPSLV0                          (1'h0),
    .ARIDEXPSLV0                            (8'h0),
    .ARADDREXPSLV0                          (32'h0000_0000),
    .ARLENEXPSLV0                           (8'h00),
    .ARSIZEEXPSLV0                          (3'h0),
    .ARBURSTEXPSLV0                         (2'h0),
    .ARLOCKEXPSLV0                          (1'h0),
    .ARCACHEEXPSLV0                         (4'h0),
    .ARPROTEXPSLV0                          (3'h0),
    .ARVALIDEXPSLV0                         (1'h0),
    .ARREADYEXPSLV0                         (),
    .RIDEXPSLV0                             (),
    .RDATAEXPSLV0                           (),
    .RRESPEXPSLV0                           (),
    .RLASTEXPSLV0                           (),
    .RVALIDEXPSLV0                          (),
    .RREADYEXPSLV0                          (1'h0),
    .AWUSEREXPSLV0                          (2'h0),
    .ARUSEREXPSLV0                          (2'h0),
    .ARMMUSIDEXPSLV0                        (8'h00),
    .AWMMUSIDEXPSLV0                        (8'h00),
    .AWQOSEXPSLV0                           (4'h0),
    .ARQOSEXPSLV0                           (4'h0),

 

    .AWAKEUPEXPSLV1                         (1'b0),
    .AWIDEXPSLV1                            (8'h0),
    .AWADDREXPSLV1                          (32'h0000_0000),
    .AWLENEXPSLV1                           (8'h00),
    .AWSIZEEXPSLV1                          (3'h0),
    .AWBURSTEXPSLV1                         (2'h0),
    .AWLOCKEXPSLV1                          (1'h0),
    .AWCACHEEXPSLV1                         (4'h0),
    .AWPROTEXPSLV1                          (3'h0),
    .AWVALIDEXPSLV1                         (1'h0),
    .AWREADYEXPSLV1                         (),
    .WDATAEXPSLV1                           (64'h0),
    .WSTRBEXPSLV1                           (8'h0),
    .WLASTEXPSLV1                           (1'h0),
    .WVALIDEXPSLV1                          (1'h0),
    .WREADYEXPSLV1                          (),
    .BIDEXPSLV1                             (),
    .BRESPEXPSLV1                           (),
    .BVALIDEXPSLV1                          (),
    .BREADYEXPSLV1                          (1'h0),
    .ARIDEXPSLV1                            (8'h0),
    .ARADDREXPSLV1                          (32'h0000_0000),
    .ARLENEXPSLV1                           (8'h00),
    .ARSIZEEXPSLV1                          (3'h0),
    .ARBURSTEXPSLV1                         (2'h0),
    .ARLOCKEXPSLV1                          (1'h0),
    .ARCACHEEXPSLV1                         (4'h0),
    .ARPROTEXPSLV1                          (3'h0),
    .ARVALIDEXPSLV1                         (1'h0),
    .ARREADYEXPSLV1                         (),
    .RIDEXPSLV1                             (),
    .RDATAEXPSLV1                           (),
    .RRESPEXPSLV1                           (),
    .RLASTEXPSLV1                           (),
    .RVALIDEXPSLV1                          (),
    .RREADYEXPSLV1                          (1'h0),
    .AWUSEREXPSLV1                          (2'h0),
    .ARUSEREXPSLV1                          (2'h0),
    .ARMMUSIDEXPSLV1                        (8'h00),
    .AWMMUSIDEXPSLV1                        (8'h00),
    .AWQOSEXPSLV1                           (4'h0),
    .ARQOSEXPSLV1                           (4'h0),

 

 
    .AWAKEUPEXPMST0                         (hostexpmst0_awakeup),
    .AWIDEXPMST0                            (hostexpmst0_awid),
    .AWADDREXPMST0                          (hostexpmst0_awaddr),
    .AWLENEXPMST0                           (hostexpmst0_awlen),
    .AWSIZEEXPMST0                          (hostexpmst0_awsize),
    .AWBURSTEXPMST0                         (hostexpmst0_awburst),
    .AWLOCKEXPMST0                          (hostexpmst0_awlock),
    .AWCACHEEXPMST0                         (hostexpmst0_awcache),
    .AWPROTEXPMST0                          (hostexpmst0_awprot),
    .AWVALIDEXPMST0                         (hostexpmst0_awvalid),
    .AWREADYEXPMST0                         (hostexpmst0_awready),
    .WDATAEXPMST0                           (hostexpmst0_wdata),
    .WSTRBEXPMST0                           (hostexpmst0_wstrb),
    .WLASTEXPMST0                           (hostexpmst0_wlast),
    .WVALIDEXPMST0                          (hostexpmst0_wvalid),
    .WREADYEXPMST0                          (hostexpmst0_wready),
    .BIDEXPMST0                             (hostexpmst0_bid),
    .BRESPEXPMST0                           (hostexpmst0_bresp),
    .BVALIDEXPMST0                          (hostexpmst0_bvalid),
    .BREADYEXPMST0                          (hostexpmst0_bready),
    .ARIDEXPMST0                            (hostexpmst0_arid),
    .ARADDREXPMST0                          (hostexpmst0_araddr),
    .ARLENEXPMST0                           (hostexpmst0_arlen),
    .ARSIZEEXPMST0                          (hostexpmst0_arsize),
    .ARBURSTEXPMST0                         (hostexpmst0_arburst),
    .ARLOCKEXPMST0                          (hostexpmst0_arlock),
    .ARCACHEEXPMST0                         (hostexpmst0_arcache),
    .ARPROTEXPMST0                          (hostexpmst0_arprot),
    .ARVALIDEXPMST0                         (hostexpmst0_arvalid),
    .ARREADYEXPMST0                         (hostexpmst0_arready),
    .RIDEXPMST0                             (hostexpmst0_rid),
    .RDATAEXPMST0                           (hostexpmst0_rdata),
    .RRESPEXPMST0                           (hostexpmst0_rresp),
    .RLASTEXPMST0                           (hostexpmst0_rlast),
    .RVALIDEXPMST0                          (hostexpmst0_rvalid),
    .RREADYEXPMST0                          (hostexpmst0_rready),
    .AWUSEREXPMST0                          (hostexpmst0_awuser),
    .ARUSEREXPMST0                          (hostexpmst0_aruser),
    .AWMMUSIDEXPMST0                        (hostexpmst0_awmmusid),
    .ARMMUSIDEXPMST0                        (hostexpmst0_armmusid),
    .AWQOSEXPMST0                           (hostexpmst0_awqos),
    .ARQOSEXPMST0                           (hostexpmst0_arqos),  
 
    .AWAKEUPEXPMST1                         (hostexpmst1_awakeup),
    .AWIDEXPMST1                            (hostexpmst1_awid),
    .AWADDREXPMST1                          (hostexpmst1_awaddr),
    .AWLENEXPMST1                           (hostexpmst1_awlen),
    .AWSIZEEXPMST1                          (hostexpmst1_awsize),
    .AWBURSTEXPMST1                         (hostexpmst1_awburst),
    .AWLOCKEXPMST1                          (hostexpmst1_awlock),
    .AWCACHEEXPMST1                         (hostexpmst1_awcache),
    .AWPROTEXPMST1                          (hostexpmst1_awprot),
    .AWVALIDEXPMST1                         (hostexpmst1_awvalid),
    .AWREADYEXPMST1                         (hostexpmst1_awready),
    .WDATAEXPMST1                           (hostexpmst1_wdata),
    .WSTRBEXPMST1                           (hostexpmst1_wstrb),
    .WLASTEXPMST1                           (hostexpmst1_wlast),
    .WVALIDEXPMST1                          (hostexpmst1_wvalid),
    .WREADYEXPMST1                          (hostexpmst1_wready),
    .BIDEXPMST1                             (hostexpmst1_bid),
    .BRESPEXPMST1                           (hostexpmst1_bresp),
    .BVALIDEXPMST1                          (hostexpmst1_bvalid),
    .BREADYEXPMST1                          (hostexpmst1_bready),
    .ARIDEXPMST1                            (hostexpmst1_arid),
    .ARADDREXPMST1                          (hostexpmst1_araddr),
    .ARLENEXPMST1                           (hostexpmst1_arlen),
    .ARSIZEEXPMST1                          (hostexpmst1_arsize),
    .ARBURSTEXPMST1                         (hostexpmst1_arburst),
    .ARLOCKEXPMST1                          (hostexpmst1_arlock),
    .ARCACHEEXPMST1                         (hostexpmst1_arcache),
    .ARPROTEXPMST1                          (hostexpmst1_arprot),
    .ARVALIDEXPMST1                         (hostexpmst1_arvalid),
    .ARREADYEXPMST1                         (hostexpmst1_arready),
    .RIDEXPMST1                             (hostexpmst1_rid),
    .RDATAEXPMST1                           (hostexpmst1_rdata),
    .RRESPEXPMST1                           (hostexpmst1_rresp),
    .RLASTEXPMST1                           (hostexpmst1_rlast),
    .RVALIDEXPMST1                          (hostexpmst1_rvalid),
    .RREADYEXPMST1                          (hostexpmst1_rready),
    .AWUSEREXPMST1                          (hostexpmst1_awuser),
    .ARUSEREXPMST1                          (hostexpmst1_aruser),
    .AWMMUSIDEXPMST1                        (hostexpmst1_awmmusid),
    .ARMMUSIDEXPMST1                        (hostexpmst1_armmusid),
    .AWQOSEXPMST1                           (hostexpmst1_awqos),
    .ARQOSEXPMST1                           (hostexpmst1_arqos),  
 
    
    .HOSTDBGAUTHDBGEN                       (),
    .HOSTDBGAUTHNIDEN                       (),
    .HOSTDBGAUTHSPIDEN                      (),
    .HOSTDBGAUTHSPNIDEN                     (),
    
    .HOSTTSVALUEB                           (host_tsvalueb),

    .HOSTCNTVALUEG                          (hostcntvalueg),
    .HOSTCNTVALUEB                          (hostcntvalueb),

    .HOSTS32KCNTVALUEG                      (hosts32kcntvalueg),
    .HOSTS32KCNTVALUEB                      (hosts32kcntvalueb),

    .HOSTUART0OUT2n                         (HOSTUART0OUT2n),
    .HOSTUART0OUT1n                         (HOSTUART0OUT1n),
    .HOSTUART0RTSn                          (HOSTUART0RTSn),
    .HOSTUART0DTRn                          (HOSTUART0DTRn),
    .HOSTUART0TX                            (HOSTUART0TX),  
    .HOSTUART0CTSn                          (HOSTUART0CTSn),
    .HOSTUART0DCDn                          (HOSTUART0DCDn),
    .HOSTUART0DSRn                          (HOSTUART0DSRn),
    .HOSTUART0RIn                           (HOSTUART0RIn),
    .HOSTUART0RX                            (HOSTUART0RX),

    .HOSTUART1OUT2n                         (HOSTUART1OUT2n),
    .HOSTUART1OUT1n                         (HOSTUART1OUT1n),
    .HOSTUART1RTSn                          (HOSTUART1RTSn),
    .HOSTUART1DTRn                          (HOSTUART1DTRn),
    .HOSTUART1TX                            (HOSTUART1TX),  
    .HOSTUART1CTSn                          (HOSTUART1CTSn),
    .HOSTUART1DCDn                          (HOSTUART1DCDn),
    .HOSTUART1DSRn                          (HOSTUART1DSRn),
    .HOSTUART1RIn                           (HOSTUART1RIn),
    .HOSTUART1RX                            (HOSTUART1RX),

    .SECENCUARTOUT2n                        (SECENCUARTOUT2n),
    .SECENCUARTOUT1n                        (SECENCUARTOUT1n),
    .SECENCUARTRTSn                         (SECENCUARTRTSn),
    .SECENCUARTDTRn                         (SECENCUARTDTRn),
    .SECENCUARTTX                           (SECENCUARTTX),
    .SECENCUARTCTSn                         (SECENCUARTCTSn),
    .SECENCUARTDCDn                         (SECENCUARTDCDn),
    .SECENCUARTDSRn                         (SECENCUARTDSRn),
    .SECENCUARTRIn                          (SECENCUARTRIn),
    .SECENCUARTRX                           (SECENCUARTRX),

    .PSELHOSTAONEXPMST                      (aonexp_psel),
    .PENABLEHOSTAONEXPMST                   (aonexp_penable),
    .PADDRHOSTAONEXPMST                     (aonexp_paddr),
    .PWRITEHOSTAONEXPMST                    (aonexp_pwrite),
    .PWDATAHOSTAONEXPMST                    (aonexp_pwdata),
    .PSTRBHOSTAONEXPMST                     (aonexp_pstrb),
    .PPROTHOSTAONEXPMST                     (aonexp_pprot),
    .PWAKEUPHOSTAONEXPMST                   (),
    .PREADYHOSTAONEXPMST                    (aonexp_pready),
    .PRDATAHOSTAONEXPMST                    (aonexp_prdata),
    .PSLVERRHOSTAONEXPMST                   (aonexp_pslverr),

 
    .EXTSYS0DBGCLKS                         (extsys0_dbgclks),
    .EXTSYS0DBGCLKM                         (extsys0_dbgclkm),
    .EXTSYS0MHUCLK                          (extsys0_mhuclk),
    .EXTSYS0ATCLK                           (extsys0_atclk),
    .EXTSYS0CTICLK                          (extsys0_cticlk),
    .EXTSYS0ACLK                            (extsys0_aclk),

    .EXTSYS0DBGPRESETSn                     (extsys0_dbgpresetsn),
    .EXTSYS0DBGPRESETMn                     (extsys0_dbgpresetmn),
    .EXTSYS0MHURESETn                       (extsys0_mhuresetn),
    .EXTSYS0ATRESETn                        (extsys0_atresetn),
    .EXTSYS0CTIRESETn                       (extsys0_ctiresetn),
    .EXTSYS0ARESETn                         (extsys0_aresetn),
    .EXTSYS0PORESETn                        (extsys0_poresetn),
    
    .EXTSYS0CPUWAIT                         (extsys0_cpuwait),

    .AWAKEUPEXTSYS0MEM                      (extsys0_mem_awakeup),
   
    .AWIDEXTSYS0MEM                         ({7'b0, extsys0_mem_awid}),
   
    .AWADDREXTSYS0MEM                       (extsys0_mem_awaddr),
    .AWLENEXTSYS0MEM                        (extsys0_mem_awlen),
    .AWSIZEEXTSYS0MEM                       (extsys0_mem_awsize),
    .AWBURSTEXTSYS0MEM                      (extsys0_mem_awburst),
    .AWLOCKEXTSYS0MEM                       (extsys0_mem_awlock),
    .AWCACHEEXTSYS0MEM                      (extsys0_mem_awcache),
    .AWPROTEXTSYS0MEM                       ({extsys0_mem_awprot[2], EXTSYS0_SECURITY, extsys0_mem_awprot[0]}),
    .AWVALIDEXTSYS0MEM                      (extsys0_mem_awvalid),
    .AWREADYEXTSYS0MEM                      (extsys0_mem_awready),
    .WDATAEXTSYS0MEM                        (extsys0_mem_wdata),
    .WSTRBEXTSYS0MEM                        (extsys0_mem_wstrb),
    .WLASTEXTSYS0MEM                        (extsys0_mem_wlast),
    .WVALIDEXTSYS0MEM                       (extsys0_mem_wvalid),
    .WREADYEXTSYS0MEM                       (extsys0_mem_wready),
   
    .BIDEXTSYS0MEM                          ({extsys0_mem_bid_unused, extsys0_mem_bid}),
   
    .BRESPEXTSYS0MEM                        (extsys0_mem_bresp),
    .BVALIDEXTSYS0MEM                       (extsys0_mem_bvalid),
    .BREADYEXTSYS0MEM                       (extsys0_mem_bready),
   
    .ARIDEXTSYS0MEM                         ({7'b0, extsys0_mem_arid}),
   
    .ARADDREXTSYS0MEM                       (extsys0_mem_araddr),
    .ARLENEXTSYS0MEM                        (extsys0_mem_arlen),
    .ARSIZEEXTSYS0MEM                       (extsys0_mem_arsize),
    .ARBURSTEXTSYS0MEM                      (extsys0_mem_arburst),
    .ARLOCKEXTSYS0MEM                       (extsys0_mem_arlock),
    .ARCACHEEXTSYS0MEM                      (extsys0_mem_arcache),
    .ARPROTEXTSYS0MEM                       ({extsys0_mem_arprot[2], EXTSYS0_SECURITY, extsys0_mem_arprot[0]}),
    .ARVALIDEXTSYS0MEM                      (extsys0_mem_arvalid),
    .ARREADYEXTSYS0MEM                      (extsys0_mem_arready),
   
    .RIDEXTSYS0MEM                          ({extsys0_mem_rid_unused, extsys0_mem_rid}),
   
    .RDATAEXTSYS0MEM                        (extsys0_mem_rdata),
    .RRESPEXTSYS0MEM                        (extsys0_mem_rresp),
    .RLASTEXTSYS0MEM                        (extsys0_mem_rlast),
    .RVALIDEXTSYS0MEM                       (extsys0_mem_rvalid),
    .RREADYEXTSYS0MEM                       (extsys0_mem_rready),
    .AWREGIONEXTSYS0MEM                     (4'h0),
    .ARREGIONEXTSYS0MEM                     (4'h0),

    .PSELEXTSYS0MHU                         (extsys0_mhu_psel),
    .PWAKEUPEXTSYS0MHU                      (extsys0_mhu_pwakeup),
    .PENABLEEXTSYS0MHU                      (extsys0_mhu_penable),
    .PADDREXTSYS0MHU                        (extsys0_mhu_paddr),
    .PWRITEEXTSYS0MHU                       (extsys0_mhu_pwrite),
    .PWDATAEXTSYS0MHU                       (extsys0_mhu_pwdata),
    .PSTRBEXTSYS0MHU                        (extsys0_mhu_pstrb),
    .PPROTEXTSYS0MHU                        ({extsys0_mhu_pprot[2], EXTSYS0_SECURITY, extsys0_mhu_pprot[0]}),
    .PRDATAEXTSYS0MHU                       (extsys0_mhu_prdata),
    .PREADYEXTSYS0MHU                       (extsys0_mhu_pready),
    .PSLVERREXTSYS0MHU                      (extsys0_mhu_pslverr),
                                            
    .ESH0EXTSYS0MHUINT                      (extsys0_esh_mhu0_comb_int),
    .HES0EXTSYS0MHUINT                      (extsys0_hes_mhu0_comb_int),
    .ESSE0EXTSYS0MHUINT                     (extsys0_esse_mhu0_comb_int),
    .SEES0EXTSYS0MHUINT                     (extsys0_sees_mhu0_comb_int),
   
    .ESH1EXTSYS0MHUINT                      (extsys0_esh_mhu1_comb_int),
    .HES1EXTSYS0MHUINT                      (extsys0_hes_mhu1_comb_int),
    .ESSE1EXTSYS0MHUINT                     (extsys0_esse_mhu1_comb_int),
    .SEES1EXTSYS0MHUINT                     (extsys0_sees_mhu1_comb_int),    
   
                                            
    .ATREADYEXTSYS0TRACEEXP                 (extsys0_traceexp_atready),
    .AFVALIDEXTSYS0TRACEEXP                 (extsys0_traceexp_afvalid),
    .SYNCREQEXTSYS0TRACEEXP                 (extsys0_traceexp_syncreq),
    .ATIDEXTSYS0TRACEEXP                    (extsys0_traceexp_atid),
    .ATVALIDEXTSYS0TRACEEXP                 (extsys0_traceexp_atvalid),
    .ATDATAEXTSYS0TRACEEXP                  (extsys0_traceexp_atdata),
    .ATBYTESEXTSYS0TRACEEXP                 (extsys0_traceexp_atbytes),
    .AFREADYEXTSYS0TRACEEXP                 (extsys0_traceexp_afready),
    .ATWAKEUPEXTSYS0TRACEEXP                (extsys0_traceexp_atwakeup),
                                            
    .PSELEXTSYS0DBG                         (extsys0_dbg_psel),
    .PWAKEUPEXTSYS0DBG                      (extsys0_dbg_pwakeup),
    .PENABLEEXTSYS0DBG                      (extsys0_dbg_penable),
    .PADDREXTSYS0DBG                        (extsys0_dbg_paddr),
    .PWRITEEXTSYS0DBG                       (extsys0_dbg_pwrite),
    .PWDATAEXTSYS0DBG                       (extsys0_dbg_pwdata),
    .PSTRBEXTSYS0DBG                        (extsys0_dbg_pstrb),
    .PPROTEXTSYS0DBG                        (extsys0_dbg_pprot),
    .PRDATAEXTSYS0DBG                       (extsys0_dbg_prdata),
    .PREADYEXTSYS0DBG                       (extsys0_dbg_pready),
    .PSLVERREXTSYS0DBG                      (extsys0_dbg_pslverr),
                                            
    .DPABORTEXTSYS0DBG                      (extsys0_dbg_dpabort),
                                            
    .PSELEXTSYS0EXTDBG                      (extsys0_extdbg_psel),
    .PWAKEUPEXTSYS0EXTDBG                   (extsys0_extdbg_pwakeup),
    .PENABLEEXTSYS0EXTDBG                   (extsys0_extdbg_penable),
    .PADDREXTSYS0EXTDBG                     (extsys0_extdbg_paddr),
    .PWRITEEXTSYS0EXTDBG                    (extsys0_extdbg_pwrite),
    .PWDATAEXTSYS0EXTDBG                    (extsys0_extdbg_pwdata),
    .PSTRBEXTSYS0EXTDBG                     (extsys0_extdbg_pstrb),
    .PPROTEXTSYS0EXTDBG                     ({extsys0_extdbg_pprot[2], EXTSYS0_SECURITY, extsys0_extdbg_pprot[0]}),
    .PRDATAEXTSYS0EXTDBG                    (extsys0_extdbg_prdata),
    .PREADYEXTSYS0EXTDBG                    (extsys0_extdbg_pready),
    .PSLVERREXTSYS0EXTDBG                   (extsys0_extdbg_pslverr),

    .EXTSYS0CTICHIN                         (extsys0_ctichin),
                                           
    .EXTSYS0CTICHOUT                        (extsys0_ctichout),
                                           
    .EXTSYS0SHDINT                          (extsys0_shdint),

    .EXTSYS0ACLKQREQn                       (extsys0_aclk_qreqn),
    .EXTSYS0ACLKQACCEPTn                    (extsys0_aclk_qacceptn),
    .EXTSYS0ACLKQDENY                       (extsys0_aclk_qdeny),
    .EXTSYS0ACLKQACTIVE                     (extsys0_aclk_qactive),

    .EXTSYS0MHUCLKQREQn                     (extsys0_mhuclk_qreqn),
    .EXTSYS0MHUCLKQACCEPTn                  (extsys0_mhuclk_qacceptn),
    .EXTSYS0MHUCLKQDENY                     (extsys0_mhuclk_qdeny),
    .EXTSYS0MHUCLKQACTIVE                   (extsys0_mhuclk_qactive),
                                            
    .EXTSYS0ATCLKQREQn                      (extsys0_atclk_qreqn),
    .EXTSYS0ATCLKQACCEPTn                   (extsys0_atclk_qacceptn),
    .EXTSYS0ATCLKQDENY                      (extsys0_atclk_qdeny),
    .EXTSYS0ATCLKQACTIVE                    (extsys0_atclk_qactive),
                                            
    .EXTSYS0DBGCLKMQREQn                    (extsys0_dbgclkm_qreqn),
    .EXTSYS0DBGCLKMQACCEPTn                 (extsys0_dbgclkm_qacceptn),
    .EXTSYS0DBGCLKMQDENY                    (extsys0_dbgclkm_qdeny),
    .EXTSYS0DBGCLKMQACTIVE                  (extsys0_dbgclkm_qactive),
                                            
    .EXTSYS0DBGCLKSQREQn                    (extsys0_dbgclks_qreqn),
    .EXTSYS0DBGCLKSQACCEPTn                 (extsys0_dbgclks_qacceptn),
    .EXTSYS0DBGCLKSQDENY                    (extsys0_dbgclks_qdeny),
    .EXTSYS0DBGCLKSQACTIVE                  (extsys0_dbgclks_qactive),
                                            
    .EXTSYS0CTICLKQREQn                     (extsys0_cticlk_qreqn),
    .EXTSYS0CTICLKQACCEPTn                  (extsys0_cticlk_qacceptn),
    .EXTSYS0CTICLKQDENY                     (extsys0_cticlk_qdeny),
    .EXTSYS0CTICLKQACTIVE                   (extsys0_cticlk_qactive),
                                            
    .EXTSYS0MEMPWRQREQn                     (extsys0_mempwr_qreqn),
    .EXTSYS0MEMPWRQACCEPTn                  (extsys0_mempwr_qacceptn),
    .EXTSYS0MEMPWRQDENY                     (extsys0_mempwr_qdeny),
    .EXTSYS0MEMPWRQACTIVE                   (extsys0_mempwr_qactive),
                                            
    .EXTSYS0MHUPWRQREQn                     (extsys0_mhupwr_qreqn),
    .EXTSYS0MHUPWRQACCEPTn                  (extsys0_mhupwr_qacceptn),
    .EXTSYS0MHUPWRQDENY                     (extsys0_mhupwr_qdeny),
    .EXTSYS0MHUPWRREQACTIVE                 (extsys0_mhupwrreq_qactive),
                                            
    .EXTSYS0TRACEEXPPWRQREQn                (extsys0_traceexppwr_qreqn),
    .EXTSYS0TRACEEXPPWRQACCEPTn             (extsys0_traceexppwr_qacceptn),
    .EXTSYS0TRACEEXPPWRQDENY                (extsys0_traceexppwr_qdeny),
    .EXTSYS0TRACEEXPPWRQACTIVE              (extsys0_traceexppwr_qactive),
                                            
    .EXTSYS0DBGPWRQREQn                     (extsys0_dbgpwr_qreqn),
    .EXTSYS0DBGPWRQACCEPTn                  (extsys0_dbgpwr_qacceptn),
    .EXTSYS0DBGPWRQDENY                     (extsys0_dbgpwr_qdeny),
    .EXTSYS0DBGPWRQACTIVE                   (extsys0_dbgpwr_qactive),
                                            
    .EXTSYS0EXTDBGPWRQREQn                  (extsys0_extdbgpwr_qreqn),
    .EXTSYS0EXTDBGPWRQACCEPTn               (extsys0_extdbgpwr_qacceptn),
    .EXTSYS0EXTDBGPWRQDENY                  (extsys0_extdbgpwr_qdeny),
    .EXTSYS0EXTDBGPWRQACTIVE                (extsys0_extdbgpwr_qactive),
                                            
    .EXTSYS0CTIINPWRQREQn                   (extsys0_ctiinpwr_qreqn),
    .EXTSYS0CTIINPWRQACCEPTn                (extsys0_ctiinpwr_qacceptn),
    .EXTSYS0CTIINPWRQDENY                   (extsys0_ctiinpwr_qdeny),
    .EXTSYS0CTIINPWRQACTIVE                 (extsys0_ctiinpwr_qactive),
                                            
    .EXTSYS0CTIOUTPWRQREQn                  (extsys0_ctioutpwr_qreqn),
    .EXTSYS0CTIOUTPWRQACCEPTn               (extsys0_ctioutpwr_qacceptn),
    .EXTSYS0CTIOUTPWRQDENY                  (extsys0_ctioutpwr_qdeny),
    .EXTSYS0CTIOUTPWRQACTIVE                (extsys0_ctioutpwr_qactive),

    .EXTSYS0DBGTOPQREQn                     (extsys0_dbgtop_qreqn),
    .EXTSYS0DBGTOPQACCEPTn                  (extsys0_dbgtop_qacceptn),
    .EXTSYS0DBGTOPQDENY                     (extsys0_dbgtop_qdeny),
    .EXTSYS0DBGTOPQACTIVE                   (extsys0_dbgtop_qactive),
                                            
    .EXTSYS0SYSTOPQREQn                     (extsys0_systop_qreqn),
    .EXTSYS0SYSTOPQACCEPTn                  (extsys0_systop_qacceptn),
    .EXTSYS0SYSTOPQDENY                     (extsys0_systop_qdeny),
    .EXTSYS0SYSTOPQACTIVE                   (extsys0_systop_qactive),
                                            
    .EXTSYS0AONTOPQREQn                     (extsys0_aontop_qreqn),
    .EXTSYS0AONTOPQACCEPTn                  (extsys0_aontop_qacceptn),
    .EXTSYS0AONTOPQDENY                     (extsys0_aontop_qdeny),
    .EXTSYS0AONTOPQACTIVE                   (extsys0_aontop_qactive),

    .EXTSYS0EXTDBGROMCDBGPWRUPREQ           (extsys0_extdbgrom_cdbgpwrupreq),
    .EXTSYS0EXTDBGROMCDBGPWRUPACK           (extsys0_extdbgrom_cdbgpwrupack),
    .EXTSYS0AXIAPROMCSYSPWRUPREQ            (extsys0_axiaprom_csyspwrupreq),
    .EXTSYS0AXIAPROMCSYSPWRUPACK            (extsys0_axiaprom_csyspwrupack),

    .EXTSYS0RSTSYN                          (extsys0_rstsyn),
 
    .EXTSYS1DBGCLKS                         (extsys1_dbgclks),
    .EXTSYS1DBGCLKM                         (extsys1_dbgclkm),
    .EXTSYS1MHUCLK                          (extsys1_mhuclk),
    .EXTSYS1ATCLK                           (extsys1_atclk),
    .EXTSYS1CTICLK                          (extsys1_cticlk),
    .EXTSYS1ACLK                            (extsys1_aclk),

    .EXTSYS1DBGPRESETSn                     (extsys1_dbgpresetsn),
    .EXTSYS1DBGPRESETMn                     (extsys1_dbgpresetmn),
    .EXTSYS1MHURESETn                       (extsys1_mhuresetn),
    .EXTSYS1ATRESETn                        (extsys1_atresetn),
    .EXTSYS1CTIRESETn                       (extsys1_ctiresetn),
    .EXTSYS1ARESETn                         (extsys1_aresetn),
    .EXTSYS1PORESETn                        (extsys1_poresetn),
    
    .EXTSYS1CPUWAIT                         (extsys1_cpuwait),

    .AWAKEUPEXTSYS1MEM                      (extsys1_mem_awakeup),
   
    .AWIDEXTSYS1MEM                         ({7'b0, extsys1_mem_awid}),
   
    .AWADDREXTSYS1MEM                       (extsys1_mem_awaddr),
    .AWLENEXTSYS1MEM                        (extsys1_mem_awlen),
    .AWSIZEEXTSYS1MEM                       (extsys1_mem_awsize),
    .AWBURSTEXTSYS1MEM                      (extsys1_mem_awburst),
    .AWLOCKEXTSYS1MEM                       (extsys1_mem_awlock),
    .AWCACHEEXTSYS1MEM                      (extsys1_mem_awcache),
    .AWPROTEXTSYS1MEM                       ({extsys1_mem_awprot[2], EXTSYS1_SECURITY, extsys1_mem_awprot[0]}),
    .AWVALIDEXTSYS1MEM                      (extsys1_mem_awvalid),
    .AWREADYEXTSYS1MEM                      (extsys1_mem_awready),
    .WDATAEXTSYS1MEM                        (extsys1_mem_wdata),
    .WSTRBEXTSYS1MEM                        (extsys1_mem_wstrb),
    .WLASTEXTSYS1MEM                        (extsys1_mem_wlast),
    .WVALIDEXTSYS1MEM                       (extsys1_mem_wvalid),
    .WREADYEXTSYS1MEM                       (extsys1_mem_wready),
   
    .BIDEXTSYS1MEM                          ({extsys1_mem_bid_unused, extsys1_mem_bid}),
   
    .BRESPEXTSYS1MEM                        (extsys1_mem_bresp),
    .BVALIDEXTSYS1MEM                       (extsys1_mem_bvalid),
    .BREADYEXTSYS1MEM                       (extsys1_mem_bready),
   
    .ARIDEXTSYS1MEM                         ({7'b0, extsys1_mem_arid}),
   
    .ARADDREXTSYS1MEM                       (extsys1_mem_araddr),
    .ARLENEXTSYS1MEM                        (extsys1_mem_arlen),
    .ARSIZEEXTSYS1MEM                       (extsys1_mem_arsize),
    .ARBURSTEXTSYS1MEM                      (extsys1_mem_arburst),
    .ARLOCKEXTSYS1MEM                       (extsys1_mem_arlock),
    .ARCACHEEXTSYS1MEM                      (extsys1_mem_arcache),
    .ARPROTEXTSYS1MEM                       ({extsys1_mem_arprot[2], EXTSYS1_SECURITY, extsys1_mem_arprot[0]}),
    .ARVALIDEXTSYS1MEM                      (extsys1_mem_arvalid),
    .ARREADYEXTSYS1MEM                      (extsys1_mem_arready),
   
    .RIDEXTSYS1MEM                          ({extsys1_mem_rid_unused, extsys1_mem_rid}),
   
    .RDATAEXTSYS1MEM                        (extsys1_mem_rdata),
    .RRESPEXTSYS1MEM                        (extsys1_mem_rresp),
    .RLASTEXTSYS1MEM                        (extsys1_mem_rlast),
    .RVALIDEXTSYS1MEM                       (extsys1_mem_rvalid),
    .RREADYEXTSYS1MEM                       (extsys1_mem_rready),
    .AWREGIONEXTSYS1MEM                     (4'h0),
    .ARREGIONEXTSYS1MEM                     (4'h0),

    .PSELEXTSYS1MHU                         (extsys1_mhu_psel),
    .PWAKEUPEXTSYS1MHU                      (extsys1_mhu_pwakeup),
    .PENABLEEXTSYS1MHU                      (extsys1_mhu_penable),
    .PADDREXTSYS1MHU                        (extsys1_mhu_paddr),
    .PWRITEEXTSYS1MHU                       (extsys1_mhu_pwrite),
    .PWDATAEXTSYS1MHU                       (extsys1_mhu_pwdata),
    .PSTRBEXTSYS1MHU                        (extsys1_mhu_pstrb),
    .PPROTEXTSYS1MHU                        ({extsys1_mhu_pprot[2], EXTSYS1_SECURITY, extsys1_mhu_pprot[0]}),
    .PRDATAEXTSYS1MHU                       (extsys1_mhu_prdata),
    .PREADYEXTSYS1MHU                       (extsys1_mhu_pready),
    .PSLVERREXTSYS1MHU                      (extsys1_mhu_pslverr),
                                            
    .ESH0EXTSYS1MHUINT                      (extsys1_esh_mhu0_comb_int),
    .HES0EXTSYS1MHUINT                      (extsys1_hes_mhu0_comb_int),
    .ESSE0EXTSYS1MHUINT                     (extsys1_esse_mhu0_comb_int),
    .SEES0EXTSYS1MHUINT                     (extsys1_sees_mhu0_comb_int),
   
    .ESH1EXTSYS1MHUINT                      (extsys1_esh_mhu1_comb_int),
    .HES1EXTSYS1MHUINT                      (extsys1_hes_mhu1_comb_int),
    .ESSE1EXTSYS1MHUINT                     (extsys1_esse_mhu1_comb_int),
    .SEES1EXTSYS1MHUINT                     (extsys1_sees_mhu1_comb_int),    
   
                                            
    .ATREADYEXTSYS1TRACEEXP                 (extsys1_traceexp_atready),
    .AFVALIDEXTSYS1TRACEEXP                 (extsys1_traceexp_afvalid),
    .SYNCREQEXTSYS1TRACEEXP                 (extsys1_traceexp_syncreq),
    .ATIDEXTSYS1TRACEEXP                    (extsys1_traceexp_atid),
    .ATVALIDEXTSYS1TRACEEXP                 (extsys1_traceexp_atvalid),
    .ATDATAEXTSYS1TRACEEXP                  (extsys1_traceexp_atdata),
    .ATBYTESEXTSYS1TRACEEXP                 (extsys1_traceexp_atbytes),
    .AFREADYEXTSYS1TRACEEXP                 (extsys1_traceexp_afready),
    .ATWAKEUPEXTSYS1TRACEEXP                (extsys1_traceexp_atwakeup),
                                            
    .PSELEXTSYS1DBG                         (extsys1_dbg_psel),
    .PWAKEUPEXTSYS1DBG                      (extsys1_dbg_pwakeup),
    .PENABLEEXTSYS1DBG                      (extsys1_dbg_penable),
    .PADDREXTSYS1DBG                        (extsys1_dbg_paddr),
    .PWRITEEXTSYS1DBG                       (extsys1_dbg_pwrite),
    .PWDATAEXTSYS1DBG                       (extsys1_dbg_pwdata),
    .PSTRBEXTSYS1DBG                        (extsys1_dbg_pstrb),
    .PPROTEXTSYS1DBG                        (extsys1_dbg_pprot),
    .PRDATAEXTSYS1DBG                       (extsys1_dbg_prdata),
    .PREADYEXTSYS1DBG                       (extsys1_dbg_pready),
    .PSLVERREXTSYS1DBG                      (extsys1_dbg_pslverr),
                                            
    .DPABORTEXTSYS1DBG                      (extsys1_dbg_dpabort),
                                            
    .PSELEXTSYS1EXTDBG                      (extsys1_extdbg_psel),
    .PWAKEUPEXTSYS1EXTDBG                   (extsys1_extdbg_pwakeup),
    .PENABLEEXTSYS1EXTDBG                   (extsys1_extdbg_penable),
    .PADDREXTSYS1EXTDBG                     (extsys1_extdbg_paddr),
    .PWRITEEXTSYS1EXTDBG                    (extsys1_extdbg_pwrite),
    .PWDATAEXTSYS1EXTDBG                    (extsys1_extdbg_pwdata),
    .PSTRBEXTSYS1EXTDBG                     (extsys1_extdbg_pstrb),
    .PPROTEXTSYS1EXTDBG                     ({extsys1_extdbg_pprot[2], EXTSYS1_SECURITY, extsys1_extdbg_pprot[0]}),
    .PRDATAEXTSYS1EXTDBG                    (extsys1_extdbg_prdata),
    .PREADYEXTSYS1EXTDBG                    (extsys1_extdbg_pready),
    .PSLVERREXTSYS1EXTDBG                   (extsys1_extdbg_pslverr),

    .EXTSYS1CTICHIN                         (extsys1_ctichin),
                                           
    .EXTSYS1CTICHOUT                        (extsys1_ctichout),
                                           
    .EXTSYS1SHDINT                          (extsys1_shdint),

    .EXTSYS1ACLKQREQn                       (extsys1_aclk_qreqn),
    .EXTSYS1ACLKQACCEPTn                    (extsys1_aclk_qacceptn),
    .EXTSYS1ACLKQDENY                       (extsys1_aclk_qdeny),
    .EXTSYS1ACLKQACTIVE                     (extsys1_aclk_qactive),

    .EXTSYS1MHUCLKQREQn                     (extsys1_mhuclk_qreqn),
    .EXTSYS1MHUCLKQACCEPTn                  (extsys1_mhuclk_qacceptn),
    .EXTSYS1MHUCLKQDENY                     (extsys1_mhuclk_qdeny),
    .EXTSYS1MHUCLKQACTIVE                   (extsys1_mhuclk_qactive),
                                            
    .EXTSYS1ATCLKQREQn                      (extsys1_atclk_qreqn),
    .EXTSYS1ATCLKQACCEPTn                   (extsys1_atclk_qacceptn),
    .EXTSYS1ATCLKQDENY                      (extsys1_atclk_qdeny),
    .EXTSYS1ATCLKQACTIVE                    (extsys1_atclk_qactive),
                                            
    .EXTSYS1DBGCLKMQREQn                    (extsys1_dbgclkm_qreqn),
    .EXTSYS1DBGCLKMQACCEPTn                 (extsys1_dbgclkm_qacceptn),
    .EXTSYS1DBGCLKMQDENY                    (extsys1_dbgclkm_qdeny),
    .EXTSYS1DBGCLKMQACTIVE                  (extsys1_dbgclkm_qactive),
                                            
    .EXTSYS1DBGCLKSQREQn                    (extsys1_dbgclks_qreqn),
    .EXTSYS1DBGCLKSQACCEPTn                 (extsys1_dbgclks_qacceptn),
    .EXTSYS1DBGCLKSQDENY                    (extsys1_dbgclks_qdeny),
    .EXTSYS1DBGCLKSQACTIVE                  (extsys1_dbgclks_qactive),
                                            
    .EXTSYS1CTICLKQREQn                     (extsys1_cticlk_qreqn),
    .EXTSYS1CTICLKQACCEPTn                  (extsys1_cticlk_qacceptn),
    .EXTSYS1CTICLKQDENY                     (extsys1_cticlk_qdeny),
    .EXTSYS1CTICLKQACTIVE                   (extsys1_cticlk_qactive),
                                            
    .EXTSYS1MEMPWRQREQn                     (extsys1_mempwr_qreqn),
    .EXTSYS1MEMPWRQACCEPTn                  (extsys1_mempwr_qacceptn),
    .EXTSYS1MEMPWRQDENY                     (extsys1_mempwr_qdeny),
    .EXTSYS1MEMPWRQACTIVE                   (extsys1_mempwr_qactive),
                                            
    .EXTSYS1MHUPWRQREQn                     (extsys1_mhupwr_qreqn),
    .EXTSYS1MHUPWRQACCEPTn                  (extsys1_mhupwr_qacceptn),
    .EXTSYS1MHUPWRQDENY                     (extsys1_mhupwr_qdeny),
    .EXTSYS1MHUPWRREQACTIVE                 (extsys1_mhupwrreq_qactive),
                                            
    .EXTSYS1TRACEEXPPWRQREQn                (extsys1_traceexppwr_qreqn),
    .EXTSYS1TRACEEXPPWRQACCEPTn             (extsys1_traceexppwr_qacceptn),
    .EXTSYS1TRACEEXPPWRQDENY                (extsys1_traceexppwr_qdeny),
    .EXTSYS1TRACEEXPPWRQACTIVE              (extsys1_traceexppwr_qactive),
                                            
    .EXTSYS1DBGPWRQREQn                     (extsys1_dbgpwr_qreqn),
    .EXTSYS1DBGPWRQACCEPTn                  (extsys1_dbgpwr_qacceptn),
    .EXTSYS1DBGPWRQDENY                     (extsys1_dbgpwr_qdeny),
    .EXTSYS1DBGPWRQACTIVE                   (extsys1_dbgpwr_qactive),
                                            
    .EXTSYS1EXTDBGPWRQREQn                  (extsys1_extdbgpwr_qreqn),
    .EXTSYS1EXTDBGPWRQACCEPTn               (extsys1_extdbgpwr_qacceptn),
    .EXTSYS1EXTDBGPWRQDENY                  (extsys1_extdbgpwr_qdeny),
    .EXTSYS1EXTDBGPWRQACTIVE                (extsys1_extdbgpwr_qactive),
                                            
    .EXTSYS1CTIINPWRQREQn                   (extsys1_ctiinpwr_qreqn),
    .EXTSYS1CTIINPWRQACCEPTn                (extsys1_ctiinpwr_qacceptn),
    .EXTSYS1CTIINPWRQDENY                   (extsys1_ctiinpwr_qdeny),
    .EXTSYS1CTIINPWRQACTIVE                 (extsys1_ctiinpwr_qactive),
                                            
    .EXTSYS1CTIOUTPWRQREQn                  (extsys1_ctioutpwr_qreqn),
    .EXTSYS1CTIOUTPWRQACCEPTn               (extsys1_ctioutpwr_qacceptn),
    .EXTSYS1CTIOUTPWRQDENY                  (extsys1_ctioutpwr_qdeny),
    .EXTSYS1CTIOUTPWRQACTIVE                (extsys1_ctioutpwr_qactive),

    .EXTSYS1DBGTOPQREQn                     (extsys1_dbgtop_qreqn),
    .EXTSYS1DBGTOPQACCEPTn                  (extsys1_dbgtop_qacceptn),
    .EXTSYS1DBGTOPQDENY                     (extsys1_dbgtop_qdeny),
    .EXTSYS1DBGTOPQACTIVE                   (extsys1_dbgtop_qactive),
                                            
    .EXTSYS1SYSTOPQREQn                     (extsys1_systop_qreqn),
    .EXTSYS1SYSTOPQACCEPTn                  (extsys1_systop_qacceptn),
    .EXTSYS1SYSTOPQDENY                     (extsys1_systop_qdeny),
    .EXTSYS1SYSTOPQACTIVE                   (extsys1_systop_qactive),
                                            
    .EXTSYS1AONTOPQREQn                     (extsys1_aontop_qreqn),
    .EXTSYS1AONTOPQACCEPTn                  (extsys1_aontop_qacceptn),
    .EXTSYS1AONTOPQDENY                     (extsys1_aontop_qdeny),
    .EXTSYS1AONTOPQACTIVE                   (extsys1_aontop_qactive),

    .EXTSYS1EXTDBGROMCDBGPWRUPREQ           (extsys1_extdbgrom_cdbgpwrupreq),
    .EXTSYS1EXTDBGROMCDBGPWRUPACK           (extsys1_extdbgrom_cdbgpwrupack),
    .EXTSYS1AXIAPROMCSYSPWRUPREQ            (extsys1_axiaprom_csyspwrupreq),
    .EXTSYS1AXIAPROMCSYSPWRUPACK            (extsys1_axiaprom_csyspwrupack),

    .EXTSYS1RSTSYN                          (extsys1_rstsyn),
 

 

    .DFTTESTMODE                          (DFTTESTMODE)
  );
  
  
 

// -----------------------------------------------------------------------------
// AON expansion
  sse710_integration_example_f0_aon_exp u_sse710_integration_example_f0_aon_exp (
    .s32kclk                             (S32KCLK),
    .hostaonexpclk                       (hostaonexpclk),
    .refclk                              (REFCLK),

    .aontop_warmresetn_s_s32kclk         (aontop_warmresetn_s_s32kclk),
    .aontop_warmresetn_s_hostaonexpclk   (aontop_warmresetn_s_hostaonexpclk),
    .aonexp_psel                         (aonexp_psel),
    .aonexp_penable                      (aonexp_penable),
    .aonexp_pwrite                       (aonexp_pwrite),
    .aonexp_pprot                        (aonexp_pprot),
    .aonexp_pstrb                        (aonexp_pstrb),
    .aonexp_paddr                        (aonexp_paddr),
    .aonexp_pwdata                       (aonexp_pwdata),
    .aonexp_prdata                       (aonexp_prdata),
    .aonexp_pready                       (aonexp_pready),
    .aonexp_pslverr                      (aonexp_pslverr),

    .rtc_irq                             (rtc_irq),
    .dftcgen                             (DFTCGEN)
);

// -----------------------------------------------------------------------------
// CoreSight Timestamp generation

  sse710_integration_example_f0_cs_timestamp_gen u_sse710_integration_example_f0_cs_timestamp_gen (
    .refclk                           (REFCLK),
    .dbgtop_warmresetn_s              (dbgtop_warmresetn_s),
    
 
    .extsys0_nts_wr_ptr_encd_gry      (extsys0_nts_wr_ptr_encd_gry),
    .extsys0_nts_rd_ptr_encd_gry      (extsys0_nts_rd_ptr_encd_gry),
    .extsys0_nts_wr_ptr_sync_gry      (extsys0_nts_wr_ptr_sync_gry),
    .extsys0_nts_rd_ptr_sync_gry      (extsys0_nts_rd_ptr_sync_gry),
    .extsys0_nts_fw_data              (extsys0_nts_fw_data),
    .extsys0_nts_s_lp                 (extsys0_nts_s_lp),
    .extsys0_nts_s_lp_return          (extsys0_nts_s_lp_return),
    .extsys0_nts_m_lp                 (extsys0_nts_m_lp),

    .extsys0_nts_qreqn                (extsys0_nts_qreqn),
    .extsys0_nts_qacceptn             (extsys0_nts_qacceptn),
    .extsys0_nts_qdeny                (extsys0_nts_qdeny),
    .extsys0_nts_qactive              (extsys0_nts_qactive),
 
    .extsys1_nts_wr_ptr_encd_gry      (extsys1_nts_wr_ptr_encd_gry),
    .extsys1_nts_rd_ptr_encd_gry      (extsys1_nts_rd_ptr_encd_gry),
    .extsys1_nts_wr_ptr_sync_gry      (extsys1_nts_wr_ptr_sync_gry),
    .extsys1_nts_rd_ptr_sync_gry      (extsys1_nts_rd_ptr_sync_gry),
    .extsys1_nts_fw_data              (extsys1_nts_fw_data),
    .extsys1_nts_s_lp                 (extsys1_nts_s_lp),
    .extsys1_nts_s_lp_return          (extsys1_nts_s_lp_return),
    .extsys1_nts_m_lp                 (extsys1_nts_m_lp),

    .extsys1_nts_qreqn                (extsys1_nts_qreqn),
    .extsys1_nts_qacceptn             (extsys1_nts_qacceptn),
    .extsys1_nts_qdeny                (extsys1_nts_qdeny),
    .extsys1_nts_qactive              (extsys1_nts_qactive),
 
    
    .host_tsvalueb                    (host_tsvalueb)
);

// -----------------------------------------------------------------------------
// Generic Timestamp generation

  sse710_integration_example_f0_gen_timestamp u_sse710_integration_example_f0_gen_timestamp (
    .aontop_warmresetn_s_hostcntclkout     (aontop_warmresetn_s_hostcntclkout),
    .aontop_warmresetn_s_hosts32kcntclkout (aontop_warmresetn_s_hosts32kcntclkout),
    .hosts32kcntvalueb                     (hosts32kcntvalueb),
    .hosts32kcntvalueg                     (hosts32kcntvalueg),
    .hostcntvalueb                         (hostcntvalueb),
    .hostcntvalueg                         (hostcntvalueg),
    .hostcntclkout                         (hostcntclkout),
    .hosts32kcntclkout                     (hosts32kcntclkout)
);

// -----------------------------------------------------------------------------
// Flash System

  sse710_integration_example_f0_flash_system u_sse710_integration_example_f0_flash_system (
    .aclkout                       (aclkout_i),

    .systop_warmresetn_s           (systop_warmresetn_s_aclkout),

    .xnvm_awakeup                  (xnvm_awakeup),
    .xnvm_awid                     (xnvm_awid),
    .xnvm_awaddr                   (xnvm_awaddr),
    .xnvm_awlen                    (xnvm_awlen),
    .xnvm_awsize                   (xnvm_awsize),
    .xnvm_awburst                  (xnvm_awburst),
    .xnvm_awlock                   (xnvm_awlock),
    .xnvm_awcache                  (xnvm_awcache),
    .xnvm_awprot                   (xnvm_awprot),
    .xnvm_awvalid                  (xnvm_awvalid),
    .xnvm_awuser                   (xnvm_awuser),
    .xnvm_awmmusid                 (xnvm_awmmusid),
    .xnvm_awqos                    (xnvm_awqos),
    .xnvm_awready                  (xnvm_awready),

    .xnvm_wstrb                    (xnvm_wstrb),
    .xnvm_wlast                    (xnvm_wlast),
    .xnvm_wvalid                   (xnvm_wvalid),
    .xnvm_wdata                    (xnvm_wdata),
    .xnvm_wready                   (xnvm_wready),

    .xnvm_bid                      (xnvm_bid),
    .xnvm_bresp                    (xnvm_bresp),
    .xnvm_bvalid                   (xnvm_bvalid),
    .xnvm_bready                   (xnvm_bready),

    .xnvm_arid                     (xnvm_arid),
    .xnvm_araddr                   (xnvm_araddr),
    .xnvm_arlen                    (xnvm_arlen),
    .xnvm_arsize                   (xnvm_arsize),
    .xnvm_arburst                  (xnvm_arburst),
    .xnvm_arlock                   (xnvm_arlock),
    .xnvm_arcache                  (xnvm_arcache),
    .xnvm_arprot                   (xnvm_arprot),
    .xnvm_arvalid                  (xnvm_arvalid),
    .xnvm_aruser                   (xnvm_aruser),
    .xnvm_armmusid                 (xnvm_armmusid),
    .xnvm_arqos                    (xnvm_arqos),    
    .xnvm_arready                  (xnvm_arready),

    .xnvm_rid                      (xnvm_rid),
    .xnvm_rresp                    (xnvm_rresp),
    .xnvm_rlast                    (xnvm_rlast),
    .xnvm_rvalid                   (xnvm_rvalid),
    .xnvm_rdata                    (xnvm_rdata),
    .xnvm_rready                   (xnvm_rready),

    .vultan_clk_qreqn              (vultan_clk_qreqn),
    .vultan_clk_qacceptn           (vultan_clk_qacceptn),
    .vultan_clk_qdeny              (vultan_clk_qdeny),
    .vultan_clk_qactive            (vultan_clk_qactive),

    .vultan_pwr_qreqn              (systop_qreqn_internal),
    .vultan_pwr_qacceptn           (systop_qacceptn_internal),
    .vultan_pwr_qdeny              (systop_qdeny_internal),
    .vultan_pwr_qactive            (systop_qactive_internal),

    .vultan_irq                    (vultan_irq),

    .vultan_psel_s                 (vultan_psel_s),
    .vultan_penable_s              (vultan_penable_s),
    .vultan_paddr_s                (vultan_paddr_s),
    .vultan_pwrite_s               (vultan_pwrite_s),
    .vultan_pstrb_s                (vultan_pstrb_s),
    .vultan_pwdata_s               (vultan_pwdata_s),
    .vultan_pprot_s                (vultan_pprot_s),
    .vultan_prdata_s               (vultan_prdata_s),
    .vultan_pready_s               (vultan_pready_s),
    .vultan_pslverr_s              (vultan_pslverr_s),

    .vultan_psel_m                 (PSEL_M),
    .vultan_penable_m              (PENABLE_M),
    .vultan_paddr_m                (PADDR_M),
    .vultan_pwrite_m               (PWRITE_M),
    .vultan_pstrb_m                (PSTRB_M),
    .vultan_pwdata_m               (PWDATA_M),
    .vultan_prdata_m               (PRDATA_M),
    .vultan_pready_m               (PREADY_M),
    .vultan_pslverr_m              (PSLVERR_M),

    .vultan_faddr                  (FADDR),
    .vultan_fcmd                   (FCMD),
    .vultan_fabort                 (FABORT),
    .vultan_fwdata                 (FWDATA),
    .vultan_frdata                 (FRDATA),
    .vultan_fready                 (FREADY),
    .vultan_fresp                  (FRESP),

    .vultan_preq                   (PREQ),
    .vultan_pstate                 (PSTATE),
    .vultan_paccept                (PACCEPT),
    .vultan_pdeny                  (PDENY),
    .vultan_pactive                (PACTIVE),

    .vultan_flash_pwr_rdy          (FLASH_PWR_RDY)
);

// -----------------------------------------------------------------------------
// SRAM system

  sse710_integration_example_f0_sram_system u_sse710_integration_example_f0_sram_system (
    .aclkout                   (aclkout_i),
    .systop_warmresetn_s       (systop_warmresetn_s_aclkout),

    .cvm_awakeup               (cvm_awakeup),
    .cvm_awid                  (cvm_awid),
    .cvm_awaddr                (cvm_awaddr),
    .cvm_awlen                 (cvm_awlen),
    .cvm_awsize                (cvm_awsize),
    .cvm_awburst               (cvm_awburst),
    .cvm_awlock                (cvm_awlock),
    .cvm_awcache               (cvm_awcache),
    .cvm_awprot                (cvm_awprot),
    .cvm_awvalid               (cvm_awvalid),
    .cvm_awuser                (cvm_awuser),
    .cvm_awmmusid              (cvm_awmmusid),
    .cvm_awqos                 (cvm_awqos),
    .cvm_awready               (cvm_awready),

    .cvm_wstrb                 (cvm_wstrb),
    .cvm_wlast                 (cvm_wlast),
    .cvm_wvalid                (cvm_wvalid),
    .cvm_wdata                 (cvm_wdata),
    .cvm_wready                (cvm_wready),

    .cvm_bid                   (cvm_bid),
    .cvm_bresp                 (cvm_bresp),
    .cvm_bvalid                (cvm_bvalid),
    .cvm_bready                (cvm_bready),

    .cvm_arid                  (cvm_arid),
    .cvm_araddr                (cvm_araddr),
    .cvm_arlen                 (cvm_arlen),
    .cvm_arsize                (cvm_arsize),
    .cvm_arburst               (cvm_arburst),
    .cvm_arlock                (cvm_arlock),
    .cvm_arcache               (cvm_arcache),
    .cvm_arprot                (cvm_arprot),
    .cvm_arvalid               (cvm_arvalid),
    .cvm_aruser                (cvm_aruser),
    .cvm_armmusid              (cvm_armmusid),
    .cvm_arqos                 (cvm_arqos),    
    .cvm_arready               (cvm_arready),

    .cvm_rid                   (cvm_rid),
    .cvm_rresp                 (cvm_rresp),
    .cvm_rlast                 (cvm_rlast),
    .cvm_rvalid                (cvm_rvalid),
    .cvm_rdata                 (cvm_rdata),
    .cvm_rready                (cvm_rready),

    .sram_ctrl_clk_qreqn       (sram_ctrl_clk_qreqn),
    .sram_ctrl_clk_qacceptn    (sram_ctrl_clk_qacceptn),
    .sram_ctrl_clk_qdeny       (sram_ctrl_clk_qdeny),
    .sram_ctrl_clk_qactive     (sram_ctrl_clk_qactive),
    
    .dftramhold                (DFTRAMHOLD)
);

// -----------------------------------------------------------------------------
// HOST Expansion

  sse710_integration_example_f0_host_exp u_sse710_integration_example_f0_host_exp (
    .aclkout                                  (aclkout_i),
    .refclk                                   (refclk_systop),

    .systop_warmresetn_s_aclkout              (systop_warmresetn_s_aclkout),
    .systop_warmresetn_s_refclk               (systop_warmresetn_s_refclk),

 

    .hostexpmst0_awakeup                      (hostexpmst0_awakeup),
    .hostexpmst0_awid                         (hostexpmst0_awid),
    .hostexpmst0_awaddr                       (hostexpmst0_awaddr),
    .hostexpmst0_awlen                        (hostexpmst0_awlen),
    .hostexpmst0_awsize                       (hostexpmst0_awsize),
    .hostexpmst0_awburst                      (hostexpmst0_awburst),
    .hostexpmst0_awlock                       (hostexpmst0_awlock),
    .hostexpmst0_awcache                      (hostexpmst0_awcache),
    .hostexpmst0_awprot                       (hostexpmst0_awprot),
    .hostexpmst0_awvalid                      (hostexpmst0_awvalid),
    .hostexpmst0_awready                      (hostexpmst0_awready),
    .hostexpmst0_awuser                       (hostexpmst0_awuser),
    .hostexpmst0_awmmusid                     (hostexpmst0_awmmusid),
    .hostexpmst0_awqos                        (hostexpmst0_awqos),
    .hostexpmst0_wstrb                        (hostexpmst0_wstrb),
    .hostexpmst0_wlast                        (hostexpmst0_wlast),
    .hostexpmst0_wvalid                       (hostexpmst0_wvalid),
    .hostexpmst0_wdata                        (hostexpmst0_wdata),
    .hostexpmst0_wready                       (hostexpmst0_wready),
    .hostexpmst0_bid                          (hostexpmst0_bid),
    .hostexpmst0_bresp                        (hostexpmst0_bresp),
    .hostexpmst0_bvalid                       (hostexpmst0_bvalid),
    .hostexpmst0_bready                       (hostexpmst0_bready),
    .hostexpmst0_arid                         (hostexpmst0_arid),
    .hostexpmst0_araddr                       (hostexpmst0_araddr),
    .hostexpmst0_arlen                        (hostexpmst0_arlen),
    .hostexpmst0_arsize                       (hostexpmst0_arsize),
    .hostexpmst0_arburst                      (hostexpmst0_arburst),
    .hostexpmst0_arlock                       (hostexpmst0_arlock),
    .hostexpmst0_arcache                      (hostexpmst0_arcache),
    .hostexpmst0_arprot                       (hostexpmst0_arprot),
    .hostexpmst0_arvalid                      (hostexpmst0_arvalid),
    .hostexpmst0_arready                      (hostexpmst0_arready),
    .hostexpmst0_aruser                       (hostexpmst0_aruser),
    .hostexpmst0_armmusid                     (hostexpmst0_armmusid),
    .hostexpmst0_arqos                        (hostexpmst0_arqos),
    .hostexpmst0_rid                          (hostexpmst0_rid),
    .hostexpmst0_rresp                        (hostexpmst0_rresp),
    .hostexpmst0_rlast                        (hostexpmst0_rlast),
    .hostexpmst0_rvalid                       (hostexpmst0_rvalid),
    .hostexpmst0_rdata                        (hostexpmst0_rdata),
    .hostexpmst0_rready                       (hostexpmst0_rready),
 

    .hostexpmst1_awakeup                      (hostexpmst1_awakeup),
    .hostexpmst1_awid                         (hostexpmst1_awid),
    .hostexpmst1_awaddr                       (hostexpmst1_awaddr),
    .hostexpmst1_awlen                        (hostexpmst1_awlen),
    .hostexpmst1_awsize                       (hostexpmst1_awsize),
    .hostexpmst1_awburst                      (hostexpmst1_awburst),
    .hostexpmst1_awlock                       (hostexpmst1_awlock),
    .hostexpmst1_awcache                      (hostexpmst1_awcache),
    .hostexpmst1_awprot                       (hostexpmst1_awprot),
    .hostexpmst1_awvalid                      (hostexpmst1_awvalid),
    .hostexpmst1_awready                      (hostexpmst1_awready),
    .hostexpmst1_awuser                       (hostexpmst1_awuser),
    .hostexpmst1_awmmusid                     (hostexpmst1_awmmusid),
    .hostexpmst1_awqos                        (hostexpmst1_awqos),
    .hostexpmst1_wstrb                        (hostexpmst1_wstrb),
    .hostexpmst1_wlast                        (hostexpmst1_wlast),
    .hostexpmst1_wvalid                       (hostexpmst1_wvalid),
    .hostexpmst1_wdata                        (hostexpmst1_wdata),
    .hostexpmst1_wready                       (hostexpmst1_wready),
    .hostexpmst1_bid                          (hostexpmst1_bid),
    .hostexpmst1_bresp                        (hostexpmst1_bresp),
    .hostexpmst1_bvalid                       (hostexpmst1_bvalid),
    .hostexpmst1_bready                       (hostexpmst1_bready),
    .hostexpmst1_arid                         (hostexpmst1_arid),
    .hostexpmst1_araddr                       (hostexpmst1_araddr),
    .hostexpmst1_arlen                        (hostexpmst1_arlen),
    .hostexpmst1_arsize                       (hostexpmst1_arsize),
    .hostexpmst1_arburst                      (hostexpmst1_arburst),
    .hostexpmst1_arlock                       (hostexpmst1_arlock),
    .hostexpmst1_arcache                      (hostexpmst1_arcache),
    .hostexpmst1_arprot                       (hostexpmst1_arprot),
    .hostexpmst1_arvalid                      (hostexpmst1_arvalid),
    .hostexpmst1_arready                      (hostexpmst1_arready),
    .hostexpmst1_aruser                       (hostexpmst1_aruser),
    .hostexpmst1_armmusid                     (hostexpmst1_armmusid),
    .hostexpmst1_arqos                        (hostexpmst1_arqos),
    .hostexpmst1_rid                          (hostexpmst1_rid),
    .hostexpmst1_rresp                        (hostexpmst1_rresp),
    .hostexpmst1_rlast                        (hostexpmst1_rlast),
    .hostexpmst1_rvalid                       (hostexpmst1_rvalid),
    .hostexpmst1_rdata                        (hostexpmst1_rdata),
    .hostexpmst1_rready                       (hostexpmst1_rready),
 
    
    .vultan_psel                              (vultan_psel_s),
    .vultan_penable                           (vultan_penable_s),
    .vultan_paddr                             (vultan_paddr_s),
    .vultan_pwrite                            (vultan_pwrite_s),
    .vultan_pstrb                             (vultan_pstrb_s),
    .vultan_pwdata                            (vultan_pwdata_s),
    .vultan_pprot                             (vultan_pprot_s),
    .vultan_prdata                            (vultan_prdata_s),
    .vultan_pready                            (vultan_pready_s),
    .vultan_pslverr                           (vultan_pslverr_s),
    
 
    .extsys0_slvmustacceptreqn_async          (extsys0_slvmustacceptreqn_async),
    .extsys0_slvcandenyreqn_async             (extsys0_slvcandenyreqn_async),
    .extsys0_slvacceptn_async                 (extsys0_slvacceptn_async),
    .extsys0_slvdeny_async                    (extsys0_slvdeny_async),

    .extsys0_si_to_mi_wakeup_async            (extsys0_si_to_mi_wakeup_async),
    .extsys0_mi_to_si_wakeup_async            (extsys0_mi_to_si_wakeup_async),

    .extsys0_aw_wr_ptr_async                  (extsys0_aw_wr_ptr_async),
    .extsys0_aw_rd_ptr_async                  (extsys0_aw_rd_ptr_async),
    .extsys0_aw_payld_async                   (extsys0_aw_payld_async),

    .extsys0_w_wr_ptr_async                   (extsys0_w_wr_ptr_async),
    .extsys0_w_rd_ptr_async                   (extsys0_w_rd_ptr_async),
    .extsys0_w_payld_async                    (extsys0_w_payld_async),

    .extsys0_b_wr_ptr_async                   (extsys0_b_wr_ptr_async),
    .extsys0_b_rd_ptr_async                   (extsys0_b_rd_ptr_async),
    .extsys0_b_payld_async                    (extsys0_b_payld_async),

    .extsys0_ar_wr_ptr_async                  (extsys0_ar_wr_ptr_async),
    .extsys0_ar_rd_ptr_async                  (extsys0_ar_rd_ptr_async),
    .extsys0_ar_payld_async                   (extsys0_ar_payld_async),

    .extsys0_r_wr_ptr_async                   (extsys0_r_wr_ptr_async),
    .extsys0_r_rd_ptr_async                   (extsys0_r_rd_ptr_async),
    .extsys0_r_payld_async                    (extsys0_r_payld_async),

    .extsys0_axi_pwr_qreqn                    (extsys0_axi_pwr_qreqn),
    .extsys0_axi_pwr_qacceptn                 (extsys0_axi_pwr_qacceptn),
    .extsys0_axi_pwr_qdeny                    (extsys0_axi_pwr_qdeny),
    .extsys0_axi_pwr_qactive                  (extsys0_axi_pwr_qactive),

    .extsys0_apb_pwr_qreqn                    (extsys0_apb_pwr_qreqn),
    .extsys0_apb_pwr_qacceptn                 (extsys0_apb_pwr_qacceptn),
    .extsys0_apb_pwr_qdeny                    (extsys0_apb_pwr_qdeny),
    .extsys0_apb_pwr_qactive                  (extsys0_apb_pwr_qactive),

    .extsys0_ppu_apb_async_req                (extsys0_ppu_apb_async_req),
    .extsys0_ppu_apb_async_req_payload        (extsys0_ppu_apb_async_req_payload),
    .extsys0_ppu_apb_async_resp_payload       (extsys0_ppu_apb_async_resp_payload),
    .extsys0_ppu_apb_async_ack                (extsys0_ppu_apb_async_ack),
 
    .extsys1_slvmustacceptreqn_async          (extsys1_slvmustacceptreqn_async),
    .extsys1_slvcandenyreqn_async             (extsys1_slvcandenyreqn_async),
    .extsys1_slvacceptn_async                 (extsys1_slvacceptn_async),
    .extsys1_slvdeny_async                    (extsys1_slvdeny_async),

    .extsys1_si_to_mi_wakeup_async            (extsys1_si_to_mi_wakeup_async),
    .extsys1_mi_to_si_wakeup_async            (extsys1_mi_to_si_wakeup_async),

    .extsys1_aw_wr_ptr_async                  (extsys1_aw_wr_ptr_async),
    .extsys1_aw_rd_ptr_async                  (extsys1_aw_rd_ptr_async),
    .extsys1_aw_payld_async                   (extsys1_aw_payld_async),

    .extsys1_w_wr_ptr_async                   (extsys1_w_wr_ptr_async),
    .extsys1_w_rd_ptr_async                   (extsys1_w_rd_ptr_async),
    .extsys1_w_payld_async                    (extsys1_w_payld_async),

    .extsys1_b_wr_ptr_async                   (extsys1_b_wr_ptr_async),
    .extsys1_b_rd_ptr_async                   (extsys1_b_rd_ptr_async),
    .extsys1_b_payld_async                    (extsys1_b_payld_async),

    .extsys1_ar_wr_ptr_async                  (extsys1_ar_wr_ptr_async),
    .extsys1_ar_rd_ptr_async                  (extsys1_ar_rd_ptr_async),
    .extsys1_ar_payld_async                   (extsys1_ar_payld_async),

    .extsys1_r_wr_ptr_async                   (extsys1_r_wr_ptr_async),
    .extsys1_r_rd_ptr_async                   (extsys1_r_rd_ptr_async),
    .extsys1_r_payld_async                    (extsys1_r_payld_async),

    .extsys1_axi_pwr_qreqn                    (extsys1_axi_pwr_qreqn),
    .extsys1_axi_pwr_qacceptn                 (extsys1_axi_pwr_qacceptn),
    .extsys1_axi_pwr_qdeny                    (extsys1_axi_pwr_qdeny),
    .extsys1_axi_pwr_qactive                  (extsys1_axi_pwr_qactive),

    .extsys1_apb_pwr_qreqn                    (extsys1_apb_pwr_qreqn),
    .extsys1_apb_pwr_qacceptn                 (extsys1_apb_pwr_qacceptn),
    .extsys1_apb_pwr_qdeny                    (extsys1_apb_pwr_qdeny),
    .extsys1_apb_pwr_qactive                  (extsys1_apb_pwr_qactive),

    .extsys1_ppu_apb_async_req                (extsys1_ppu_apb_async_req),
    .extsys1_ppu_apb_async_req_payload        (extsys1_ppu_apb_async_req_payload),
    .extsys1_ppu_apb_async_resp_payload       (extsys1_ppu_apb_async_resp_payload),
    .extsys1_ppu_apb_async_ack                (extsys1_ppu_apb_async_ack),
 
 
    .aclk_qreqn                               (hostexp_aclk_qreqn),
    .aclk_qacceptn                            (hostexp_aclk_qacceptn),
    .aclk_qdeny                               (hostexp_aclk_qdeny),
    .aclk_qactive                             (hostexp_aclk_qactive),
 
    .gpio_portin                              (GPIO_PORT_IN),
    .gpio_portout                             (GPIO_PORT_OUT),
    .gpio_porten                              (GPIO_PORT_EN),
    .gpio_portfunc                            (GPIO_PORT_FUNC),

    .gpio_combint                             (gpio_irq),

    .dftcgen                                  (DFTCGEN),
    .dftrstdisable                            (DFTRSTDISABLE[1])
  );
  
// -----------------------------------------------------------------------------
// SSE710 Top Shared Interrupts

 
   
    assign exp_shd_int[0] = extsys0_ppu_irq;
   
 
 
   
    assign exp_shd_int[1] = extsys1_ppu_irq;
   
 
 
   
    assign exp_shd_int[2] = extsys0_wdog_lockup_irq;
   
 
 
   
    assign exp_shd_int[3] = extsys1_wdog_lockup_irq;
   
 
 
  assign exp_shd_int[4] = vultan_irq;
 
 
  assign exp_shd_int[5] = rtc_irq;
 
 
  assign exp_shd_int[6] = gpio_irq;
 
 
   
    assign exp_shd_int[7] = 1'b0;
   
 
 
   
    assign exp_shd_int[8] = 1'b0;
   
 
 
   
    assign exp_shd_int[9] = 1'b0;
   
 
 
   
    assign exp_shd_int[10] = 1'b0;
   
 

 
 
  assign exp_shd_int[63:11] = {53{1'b0}};
 

  // Wakeup the GIC if any of the interrupt arrives. 

 
   
    arm_element_or_tree #(
      .NUM_OR_TREE_INPUTS (11)
    ) u_arm_element_or_tree (
      .or_tree_i  (exp_shd_int[10:0]),
      .or_tree_o  (gic_wakeup)
    );   
   
 


 
// -----------------------------------------------------------------------------
// External System 0 EXTSYSTOP

sse710_integration_example_f0_external_system_aon u_sse710_integration_example_f0_external_system_aon_0 (

  .extsys_fclk                          (EXTSYS0FCLK),
  .extsys_clk                           (extsys0_clk),

  .extsys_poresetn                      (extsys0_poresetn),
  .extsys_cpuwait                       (extsys0_cpuwait),
  .extsys_mtx_resetn                    (extsys0_mtx_resetn),
  .extsys_dbg_resetn                    (extsys0_dbg_resetn),
  .extsys_core_resetn                   (extsys0_core_resetn),
  .extsys_dbgpresetsn                   (extsys0_dbgpresetsn),
  .extsys_dbgpresetmn                   (extsys0_dbgpresetmn),
  .extsys_atresetn                      (extsys0_atresetn),
  .extsys_ctiresetn                     (extsys0_ctiresetn),
  .extsys_aresetn                       (extsys0_aresetn),
  .extsys_mhuresetn                     (extsys0_mhuresetn),

  .mhupwr_qreqn                         (extsys0_mhupwr_qreqn),
  .mhupwr_qacceptn                      (extsys0_mhupwr_qacceptn),
  .mhupwr_qdeny                         (extsys0_mhupwr_qdeny),
  .mhupwrreq_qactive                    (extsys0_mhupwrreq_qactive),

  .mempwr_qreqn                         (extsys0_mempwr_qreqn),
  .mempwr_qacceptn                      (extsys0_mempwr_qacceptn),
  .mempwr_qdeny                         (extsys0_mempwr_qdeny),
  .mempwr_qactive                       (extsys0_mempwr_qactive),

  .traceexppwr_qreqn                    (extsys0_traceexppwr_qreqn),
  .traceexppwr_qacceptn                 (extsys0_traceexppwr_qacceptn),
  .traceexppwr_qdeny                    (extsys0_traceexppwr_qdeny),
  .traceexppwr_qactive                  (extsys0_traceexppwr_qactive),

  .dbgpwr_qreqn                         (extsys0_dbgpwr_qreqn),
  .dbgpwr_qacceptn                      (extsys0_dbgpwr_qacceptn),
  .dbgpwr_qdeny                         (extsys0_dbgpwr_qdeny),
  .dbgpwr_qactive                       (extsys0_dbgpwr_qactive),

  .extdbgpwr_qreqn                      (extsys0_extdbgpwr_qreqn),
  .extdbgpwr_qacceptn                   (extsys0_extdbgpwr_qacceptn),
  .extdbgpwr_qdeny                      (extsys0_extdbgpwr_qdeny),
  .extdbgpwr_qactive                    (extsys0_extdbgpwr_qactive),

  .ctiinpwr_qreqn                       (extsys0_ctiinpwr_qreqn),
  .ctiinpwr_qacceptn                    (extsys0_ctiinpwr_qacceptn),
  .ctiinpwr_qdeny                       (extsys0_ctiinpwr_qdeny),
  .ctiinpwr_qactive                     (extsys0_ctiinpwr_qactive),

  .ctioutpwr_qreqn                      (extsys0_ctioutpwr_qreqn),
  .ctioutpwr_qacceptn                   (extsys0_ctioutpwr_qacceptn),
  .ctioutpwr_qdeny                      (extsys0_ctioutpwr_qdeny),
  .ctioutpwr_qactive                    (extsys0_ctioutpwr_qactive),

  .tspwr_qreqn                          (extsys0_nts_qreqn),
  .tspwr_qacceptn                       (extsys0_nts_qacceptn),
  .tspwr_qdeny                          (extsys0_nts_qdeny),
  .tspwr_qactive                        (extsys0_nts_qactive),

  .axi_pwr_qreqn                        (extsys0_axi_pwr_qreqn),
  .axi_pwr_qacceptn                     (extsys0_axi_pwr_qacceptn),
  .axi_pwr_qdeny                        (extsys0_axi_pwr_qdeny),
  .axi_pwr_qactive                      (extsys0_axi_pwr_qactive),
  
  .apb_pwr_qreqn                        (extsys0_apb_pwr_qreqn),
  .apb_pwr_qacceptn                     (extsys0_apb_pwr_qacceptn),
  .apb_pwr_qdeny                        (extsys0_apb_pwr_qdeny),
  .apb_pwr_qactive                      (extsys0_apb_pwr_qactive),  

  .dbgtop_qreqn                         (extsys0_dbgtop_qreqn),
  .dbgtop_qacceptn                      (extsys0_dbgtop_qacceptn),
  .dbgtop_qdeny                         (extsys0_dbgtop_qdeny),
  .dbgtop_qactive                       (extsys0_dbgtop_qactive),

  .systop_qreqn                         (extsys0_systop_qreqn),
  .systop_qacceptn                      (extsys0_systop_qacceptn),
  .systop_qdeny                         (extsys0_systop_qdeny),
  .systop_qactive                       (extsys0_systop_qactive),

  .aontop_qreqn                         (extsys0_aontop_qreqn),
  .aontop_qacceptn                      (extsys0_aontop_qacceptn),
  .aontop_qdeny                         (extsys0_aontop_qdeny),
  .aontop_qactive                       (extsys0_aontop_qactive),

  .extdbgrom_cdbgpwrupreq               (extsys0_extdbgrom_cdbgpwrupreq),
  .extdbgrom_cdbgpwrupack               (extsys0_extdbgrom_cdbgpwrupack),
  .axiaprom_csyspwrupreq                (extsys0_axiaprom_csyspwrupreq),
  .axiaprom_csyspwrupack                (extsys0_axiaprom_csyspwrupack),
  .extsys_rstsyn                        (extsys0_rstsyn),

  .sysreg_apb_async_req                 (extsys0_sysreg_apb_async_req),
  .sysreg_apb_async_req_payload         (extsys0_sysreg_apb_async_req_payload),
  .sysreg_apb_async_resp_payload        (extsys0_sysreg_apb_async_resp_payload),
  .sysreg_apb_async_ack                 (extsys0_sysreg_apb_async_ack),
  
  .uart_apb_async_req                   (extsys0_uart_apb_async_req),
  .uart_apb_async_req_payload           (extsys0_uart_apb_async_req_payload),
  .uart_apb_async_resp_payload          (extsys0_uart_apb_async_resp_payload),
  .uart_apb_async_ack                   (extsys0_uart_apb_async_ack),  

  .ppu_apb_async_req                    (extsys0_ppu_apb_async_req),
  .ppu_apb_async_req_payload            (extsys0_ppu_apb_async_req_payload),
  .ppu_apb_async_resp_payload           (extsys0_ppu_apb_async_resp_payload),
  .ppu_apb_async_ack                    (extsys0_ppu_apb_async_ack),

  .sleeping                             (extsys0_sleeping),
  .sleep_hold_ackn                      (extsys0_sleep_hold_ackn),
  .sysreset_req                         (extsys0_sysreset_req),
  .sleep_hold_reqn                      (extsys0_sleep_hold_reqn),
  .ppu_irq                              (extsys0_ppu_irq),
  .uart_irq                             (extsys0_uart_irq),
  .clock_override_extsystop             (extsys0_clock_override_extsystop),
  .ppu_dbgen                            (scb_soc_expansion[8]),

  .nuartcts                             (EXTSYS0UARTCTSn),
  .nuartdcd                             (EXTSYS0UARTDCDn),
  .nuartdsr                             (EXTSYS0UARTDSRn),
  .nuartri                              (EXTSYS0UARTRIn),
  .uartrxd                              (EXTSYS0UARTRX),
  .uarttxd                              (EXTSYS0UARTTX),
  .nuartdtr                             (EXTSYS0UARTDTRn),
  .nuartrts                             (EXTSYS0UARTRTSn),
  .nuartout1                            (EXTSYS0UARTOUT1n),
  .nuartout2                            (EXTSYS0UARTOUT2n),

  .mbistreq                             (MBISTREQ),
  .dftcgen                              (DFTCGEN),
  .dftrstdisable                        (DFTRSTDISABLE),
  .dftpwrup                             (DFTPWRUP),
  .dftisodisable                        (DFTISODISABLE),
  .dftretdisable                        (DFTRETDISABLE)
);

// -----------------------------------------------------------------------------
// External System 0 EXTSYSCORE

sse710_integration_example_f0_external_system_core #(
    .MEM_DATA_WIDTH (64)
) u_sse710_integration_example_f0_external_system_core_0 (
    .extsys_clk                    (extsys0_clk),
    .extsys_dbgclks                (extsys0_dbgclks),
    .extsys_dbgclkm                (extsys0_dbgclkm),
    .extsys_atclk                  (extsys0_atclk),
    .extsys_cticlk                 (extsys0_cticlk),
    .extsys_aclk                   (extsys0_aclk),
    .extsys_mhuclk                 (extsys0_mhuclk),

    .extsys_mtx_resetn             (extsys0_mtx_resetn),
    .extsys_core_resetn            (extsys0_core_resetn),
    .extsys_dbg_resetn             (extsys0_dbg_resetn),

    .aclk_qreqn                    (extsys0_aclk_qreqn),
    .aclk_qacceptn                 (extsys0_aclk_qacceptn),
    .aclk_qdeny                    (extsys0_aclk_qdeny),
    .aclk_qactive                  (extsys0_aclk_qactive),

    .mhuclk_qreqn                  (extsys0_mhuclk_qreqn),
    .mhuclk_qacceptn               (extsys0_mhuclk_qacceptn),
    .mhuclk_qdeny                  (extsys0_mhuclk_qdeny),
    .mhuclk_qactive                (extsys0_mhuclk_qactive),

    .atclk_qreqn                   (extsys0_atclk_qreqn),
    .atclk_qacceptn                (extsys0_atclk_qacceptn),
    .atclk_qdeny                   (extsys0_atclk_qdeny),
    .atclk_qactive                 (extsys0_atclk_qactive),

    .dbgclkm_qreqn                 (extsys0_dbgclkm_qreqn),
    .dbgclkm_qacceptn              (extsys0_dbgclkm_qacceptn),
    .dbgclkm_qdeny                 (extsys0_dbgclkm_qdeny),
    .dbgclkm_qactive               (extsys0_dbgclkm_qactive),

    .dbgclks_qreqn                 (extsys0_dbgclks_qreqn),
    .dbgclks_qacceptn              (extsys0_dbgclks_qacceptn),
    .dbgclks_qdeny                 (extsys0_dbgclks_qdeny),
    .dbgclks_qactive               (extsys0_dbgclks_qactive),

    .cticlk_qreqn                  (extsys0_cticlk_qreqn),
    .cticlk_qacceptn               (extsys0_cticlk_qacceptn),
    .cticlk_qdeny                  (extsys0_cticlk_qdeny),
    .cticlk_qactive                (extsys0_cticlk_qactive),

    .mem_awakeup                   (extsys0_mem_awakeup),
    .mem_awid                      (extsys0_mem_awid),
    .mem_awaddr                    (extsys0_mem_awaddr),
    .mem_awlen                     (extsys0_mem_awlen),
    .mem_awsize                    (extsys0_mem_awsize),
    .mem_awburst                   (extsys0_mem_awburst),
    .mem_awlock                    (extsys0_mem_awlock),
    .mem_awcache                   (extsys0_mem_awcache),
    .mem_awprot                    (extsys0_mem_awprot),
    .mem_awvalid                   (extsys0_mem_awvalid),
    .mem_awready                   (extsys0_mem_awready),

    .mem_wstrb                     (extsys0_mem_wstrb),
    .mem_wlast                     (extsys0_mem_wlast),
    .mem_wvalid                    (extsys0_mem_wvalid),
    .mem_wdata                     (extsys0_mem_wdata),
    .mem_wready                    (extsys0_mem_wready),

    .mem_bid                       (extsys0_mem_bid),
    .mem_bresp                     (extsys0_mem_bresp),
    .mem_bvalid                    (extsys0_mem_bvalid),
    .mem_bready                    (extsys0_mem_bready),

    .mem_arid                      (extsys0_mem_arid),
    .mem_araddr                    (extsys0_mem_araddr),
    .mem_arlen                     (extsys0_mem_arlen),
    .mem_arsize                    (extsys0_mem_arsize),
    .mem_arburst                   (extsys0_mem_arburst),
    .mem_arlock                    (extsys0_mem_arlock),
    .mem_arcache                   (extsys0_mem_arcache),
    .mem_arprot                    (extsys0_mem_arprot),
    .mem_arvalid                   (extsys0_mem_arvalid),
    .mem_arready                   (extsys0_mem_arready),

    .mem_rid                       (extsys0_mem_rid),
    .mem_rresp                     (extsys0_mem_rresp),
    .mem_rlast                     (extsys0_mem_rlast),
    .mem_rvalid                    (extsys0_mem_rvalid),
    .mem_rdata                     (extsys0_mem_rdata),
    .mem_rready                    (extsys0_mem_rready),

    .sysreg_apb_async_req          (extsys0_sysreg_apb_async_req),
    .sysreg_apb_async_req_payload  (extsys0_sysreg_apb_async_req_payload),
    .sysreg_apb_async_resp_payload (extsys0_sysreg_apb_async_resp_payload),
    .sysreg_apb_async_ack          (extsys0_sysreg_apb_async_ack),
    
    .uart_apb_async_req            (extsys0_uart_apb_async_req),
    .uart_apb_async_req_payload    (extsys0_uart_apb_async_req_payload),
    .uart_apb_async_resp_payload   (extsys0_uart_apb_async_resp_payload),
    .uart_apb_async_ack            (extsys0_uart_apb_async_ack),

    .mhu_psel                      (extsys0_mhu_psel),
    .mhu_pwakeup                   (extsys0_mhu_pwakeup),
    .mhu_penable                   (extsys0_mhu_penable),
    .mhu_paddr                     (extsys0_mhu_paddr),
    .mhu_pwrite                    (extsys0_mhu_pwrite),
    .mhu_pwdata                    (extsys0_mhu_pwdata),
    .mhu_pstrb                     (extsys0_mhu_pstrb),
    .mhu_pprot                     (extsys0_mhu_pprot),
    .mhu_prdata                    (extsys0_mhu_prdata),
    .mhu_pready                    (extsys0_mhu_pready),
    .mhu_pslverr                   (extsys0_mhu_pslverr),

    .dbg_dpabort                   (extsys0_dbg_dpabort),
    .dbg_psel                      (extsys0_dbg_psel),
    .dbg_penable                   (extsys0_dbg_penable),
    .dbg_pwrite                    (extsys0_dbg_pwrite),
    .dbg_paddr                     (extsys0_dbg_paddr),
    .dbg_pwdata                    (extsys0_dbg_pwdata),
    .dbg_pready                    (extsys0_dbg_pready),
    .dbg_pslverr                   (extsys0_dbg_pslverr),
    .dbg_prdata                    (extsys0_dbg_prdata),

    .extdbg_psel                   (extsys0_extdbg_psel),
    .extdbg_pwakeup                (extsys0_extdbg_pwakeup),
    .extdbg_penable                (extsys0_extdbg_penable),
    .extdbg_paddr                  (extsys0_extdbg_paddr),
    .extdbg_pwrite                 (extsys0_extdbg_pwrite),
    .extdbg_pwdata                 (extsys0_extdbg_pwdata),
    .extdbg_pstrb                  (extsys0_extdbg_pstrb),
    .extdbg_pprot                  (extsys0_extdbg_pprot),
    .extdbg_prdata                 (extsys0_extdbg_prdata),
    .extdbg_pready                 (extsys0_extdbg_pready),
    .extdbg_pslverr                (extsys0_extdbg_pslverr),

    .slvmustacceptreqn_async       (extsys0_slvmustacceptreqn_async),
    .slvcandenyreqn_async          (extsys0_slvcandenyreqn_async),
    .slvacceptn_async              (extsys0_slvacceptn_async),
    .slvdeny_async                 (extsys0_slvdeny_async),

    .si_to_mi_wakeup_async         (extsys0_si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async         (extsys0_mi_to_si_wakeup_async),

    .aw_wr_ptr_async               (extsys0_aw_wr_ptr_async),
    .aw_rd_ptr_async               (extsys0_aw_rd_ptr_async),
    .aw_payld_async                (extsys0_aw_payld_async),

    .w_wr_ptr_async                (extsys0_w_wr_ptr_async),
    .w_rd_ptr_async                (extsys0_w_rd_ptr_async),
    .w_payld_async                 (extsys0_w_payld_async),

    .b_wr_ptr_async                (extsys0_b_wr_ptr_async),
    .b_rd_ptr_async                (extsys0_b_rd_ptr_async),
    .b_payld_async                 (extsys0_b_payld_async),

    .ar_wr_ptr_async               (extsys0_ar_wr_ptr_async),
    .ar_rd_ptr_async               (extsys0_ar_rd_ptr_async),
    .ar_payld_async                (extsys0_ar_payld_async),

    .r_wr_ptr_async                (extsys0_r_wr_ptr_async),
    .r_rd_ptr_async                (extsys0_r_rd_ptr_async),
    .r_payld_async                 (extsys0_r_payld_async),

    .extdbgrom_cdbgpwrupack_ss     (extsys0_extdbgrom_cdbgpwrupack),
    .axiaprom_csyspwrupack_ss      (extsys0_axiaprom_csyspwrupack),

    .hes_mhu0_comb_int             (extsys0_hes_mhu0_comb_int),
    .esh_mhu0_comb_int             (extsys0_esh_mhu0_comb_int),
    .sees_mhu0_comb_int            (extsys0_sees_mhu0_comb_int),
    .esse_mhu0_comb_int            (extsys0_esse_mhu0_comb_int),
   
    .hes_mhu1_comb_int             (extsys0_hes_mhu1_comb_int),
    .esh_mhu1_comb_int             (extsys0_esh_mhu1_comb_int),
    .sees_mhu1_comb_int            (extsys0_sees_mhu1_comb_int),
    .esse_mhu1_comb_int            (extsys0_esse_mhu1_comb_int),
   

   
    .extsys_shdint                 (extsys0_shdint[42:0]),
   

    .wdog_lockup_irq               (extsys0_wdog_lockup_irq),

    .sleeping                      (extsys0_sleeping),
    .sleep_hold_ackn               (extsys0_sleep_hold_ackn),
    .sysreset_req                  (extsys0_sysreset_req),

    .sleep_hold_reqn               (extsys0_sleep_hold_reqn),

    .clock_override_extsystop      (extsys0_clock_override_extsystop),

    .traceexp_atready              (extsys0_traceexp_atready),
    .traceexp_afvalid              (extsys0_traceexp_afvalid),
    .traceexp_syncreq              (extsys0_traceexp_syncreq),
    .traceexp_atid                 (extsys0_traceexp_atid),
    .traceexp_atvalid              (extsys0_traceexp_atvalid),
    .traceexp_atdata               (extsys0_traceexp_atdata),
    .traceexp_atbytes              (extsys0_traceexp_atbytes),
    .traceexp_afready              (extsys0_traceexp_afready),
    .traceexp_atwakeup             (extsys0_traceexp_atwakeup),
      .dbgen                         (scb_soc_expansion[0]),
    .niden                         (scb_soc_expansion[1]),
    .chen                          (scb_soc_expansion[2]),
    .dapen                         (scb_soc_expansion[3]),
      .ctichin                       (extsys0_ctichout),
    .ctichout                      (extsys0_ctichin),
    
    .uart_irq                      (extsys0_uart_irq),

    .nts_wr_ptr_encd_gry           (extsys0_nts_wr_ptr_encd_gry),
    .nts_rd_ptr_encd_gry           (extsys0_nts_rd_ptr_encd_gry),
    .nts_wr_ptr_sync_gry           (extsys0_nts_wr_ptr_sync_gry),
    .nts_rd_ptr_sync_gry           (extsys0_nts_rd_ptr_sync_gry),
    .nts_fw_data                   (extsys0_nts_fw_data),
    .nts_s_lp                      (extsys0_nts_s_lp),
    .nts_s_lp_return               (extsys0_nts_s_lp_return),
    .nts_m_lp                      (extsys0_nts_m_lp),

    .mbistreq                      (MBISTREQ),
    .dftcgen                       (DFTCGEN),
    .dftrstdisable                 (DFTRSTDISABLE),
    .dftse                         (DFTCGEN),
    .dftramhold                    (DFTRAMHOLD)
);
 
// -----------------------------------------------------------------------------
// External System 1 EXTSYSTOP

sse710_integration_example_f0_external_system_aon u_sse710_integration_example_f0_external_system_aon_1 (

  .extsys_fclk                          (EXTSYS1FCLK),
  .extsys_clk                           (extsys1_clk),

  .extsys_poresetn                      (extsys1_poresetn),
  .extsys_cpuwait                       (extsys1_cpuwait),
  .extsys_mtx_resetn                    (extsys1_mtx_resetn),
  .extsys_dbg_resetn                    (extsys1_dbg_resetn),
  .extsys_core_resetn                   (extsys1_core_resetn),
  .extsys_dbgpresetsn                   (extsys1_dbgpresetsn),
  .extsys_dbgpresetmn                   (extsys1_dbgpresetmn),
  .extsys_atresetn                      (extsys1_atresetn),
  .extsys_ctiresetn                     (extsys1_ctiresetn),
  .extsys_aresetn                       (extsys1_aresetn),
  .extsys_mhuresetn                     (extsys1_mhuresetn),

  .mhupwr_qreqn                         (extsys1_mhupwr_qreqn),
  .mhupwr_qacceptn                      (extsys1_mhupwr_qacceptn),
  .mhupwr_qdeny                         (extsys1_mhupwr_qdeny),
  .mhupwrreq_qactive                    (extsys1_mhupwrreq_qactive),

  .mempwr_qreqn                         (extsys1_mempwr_qreqn),
  .mempwr_qacceptn                      (extsys1_mempwr_qacceptn),
  .mempwr_qdeny                         (extsys1_mempwr_qdeny),
  .mempwr_qactive                       (extsys1_mempwr_qactive),

  .traceexppwr_qreqn                    (extsys1_traceexppwr_qreqn),
  .traceexppwr_qacceptn                 (extsys1_traceexppwr_qacceptn),
  .traceexppwr_qdeny                    (extsys1_traceexppwr_qdeny),
  .traceexppwr_qactive                  (extsys1_traceexppwr_qactive),

  .dbgpwr_qreqn                         (extsys1_dbgpwr_qreqn),
  .dbgpwr_qacceptn                      (extsys1_dbgpwr_qacceptn),
  .dbgpwr_qdeny                         (extsys1_dbgpwr_qdeny),
  .dbgpwr_qactive                       (extsys1_dbgpwr_qactive),

  .extdbgpwr_qreqn                      (extsys1_extdbgpwr_qreqn),
  .extdbgpwr_qacceptn                   (extsys1_extdbgpwr_qacceptn),
  .extdbgpwr_qdeny                      (extsys1_extdbgpwr_qdeny),
  .extdbgpwr_qactive                    (extsys1_extdbgpwr_qactive),

  .ctiinpwr_qreqn                       (extsys1_ctiinpwr_qreqn),
  .ctiinpwr_qacceptn                    (extsys1_ctiinpwr_qacceptn),
  .ctiinpwr_qdeny                       (extsys1_ctiinpwr_qdeny),
  .ctiinpwr_qactive                     (extsys1_ctiinpwr_qactive),

  .ctioutpwr_qreqn                      (extsys1_ctioutpwr_qreqn),
  .ctioutpwr_qacceptn                   (extsys1_ctioutpwr_qacceptn),
  .ctioutpwr_qdeny                      (extsys1_ctioutpwr_qdeny),
  .ctioutpwr_qactive                    (extsys1_ctioutpwr_qactive),

  .tspwr_qreqn                          (extsys1_nts_qreqn),
  .tspwr_qacceptn                       (extsys1_nts_qacceptn),
  .tspwr_qdeny                          (extsys1_nts_qdeny),
  .tspwr_qactive                        (extsys1_nts_qactive),

  .axi_pwr_qreqn                        (extsys1_axi_pwr_qreqn),
  .axi_pwr_qacceptn                     (extsys1_axi_pwr_qacceptn),
  .axi_pwr_qdeny                        (extsys1_axi_pwr_qdeny),
  .axi_pwr_qactive                      (extsys1_axi_pwr_qactive),
  
  .apb_pwr_qreqn                        (extsys1_apb_pwr_qreqn),
  .apb_pwr_qacceptn                     (extsys1_apb_pwr_qacceptn),
  .apb_pwr_qdeny                        (extsys1_apb_pwr_qdeny),
  .apb_pwr_qactive                      (extsys1_apb_pwr_qactive),  

  .dbgtop_qreqn                         (extsys1_dbgtop_qreqn),
  .dbgtop_qacceptn                      (extsys1_dbgtop_qacceptn),
  .dbgtop_qdeny                         (extsys1_dbgtop_qdeny),
  .dbgtop_qactive                       (extsys1_dbgtop_qactive),

  .systop_qreqn                         (extsys1_systop_qreqn),
  .systop_qacceptn                      (extsys1_systop_qacceptn),
  .systop_qdeny                         (extsys1_systop_qdeny),
  .systop_qactive                       (extsys1_systop_qactive),

  .aontop_qreqn                         (extsys1_aontop_qreqn),
  .aontop_qacceptn                      (extsys1_aontop_qacceptn),
  .aontop_qdeny                         (extsys1_aontop_qdeny),
  .aontop_qactive                       (extsys1_aontop_qactive),

  .extdbgrom_cdbgpwrupreq               (extsys1_extdbgrom_cdbgpwrupreq),
  .extdbgrom_cdbgpwrupack               (extsys1_extdbgrom_cdbgpwrupack),
  .axiaprom_csyspwrupreq                (extsys1_axiaprom_csyspwrupreq),
  .axiaprom_csyspwrupack                (extsys1_axiaprom_csyspwrupack),
  .extsys_rstsyn                        (extsys1_rstsyn),

  .sysreg_apb_async_req                 (extsys1_sysreg_apb_async_req),
  .sysreg_apb_async_req_payload         (extsys1_sysreg_apb_async_req_payload),
  .sysreg_apb_async_resp_payload        (extsys1_sysreg_apb_async_resp_payload),
  .sysreg_apb_async_ack                 (extsys1_sysreg_apb_async_ack),
  
  .uart_apb_async_req                   (extsys1_uart_apb_async_req),
  .uart_apb_async_req_payload           (extsys1_uart_apb_async_req_payload),
  .uart_apb_async_resp_payload          (extsys1_uart_apb_async_resp_payload),
  .uart_apb_async_ack                   (extsys1_uart_apb_async_ack),  

  .ppu_apb_async_req                    (extsys1_ppu_apb_async_req),
  .ppu_apb_async_req_payload            (extsys1_ppu_apb_async_req_payload),
  .ppu_apb_async_resp_payload           (extsys1_ppu_apb_async_resp_payload),
  .ppu_apb_async_ack                    (extsys1_ppu_apb_async_ack),

  .sleeping                             (extsys1_sleeping),
  .sleep_hold_ackn                      (extsys1_sleep_hold_ackn),
  .sysreset_req                         (extsys1_sysreset_req),
  .sleep_hold_reqn                      (extsys1_sleep_hold_reqn),
  .ppu_irq                              (extsys1_ppu_irq),
  .uart_irq                             (extsys1_uart_irq),
  .clock_override_extsystop             (extsys1_clock_override_extsystop),
  .ppu_dbgen                            (scb_soc_expansion[8]),

  .nuartcts                             (EXTSYS1UARTCTSn),
  .nuartdcd                             (EXTSYS1UARTDCDn),
  .nuartdsr                             (EXTSYS1UARTDSRn),
  .nuartri                              (EXTSYS1UARTRIn),
  .uartrxd                              (EXTSYS1UARTRX),
  .uarttxd                              (EXTSYS1UARTTX),
  .nuartdtr                             (EXTSYS1UARTDTRn),
  .nuartrts                             (EXTSYS1UARTRTSn),
  .nuartout1                            (EXTSYS1UARTOUT1n),
  .nuartout2                            (EXTSYS1UARTOUT2n),

  .mbistreq                             (MBISTREQ),
  .dftcgen                              (DFTCGEN),
  .dftrstdisable                        (DFTRSTDISABLE),
  .dftpwrup                             (DFTPWRUP),
  .dftisodisable                        (DFTISODISABLE),
  .dftretdisable                        (DFTRETDISABLE)
);

// -----------------------------------------------------------------------------
// External System 1 EXTSYSCORE

sse710_integration_example_f0_external_system_core #(
    .MEM_DATA_WIDTH (64)
) u_sse710_integration_example_f0_external_system_core_1 (
    .extsys_clk                    (extsys1_clk),
    .extsys_dbgclks                (extsys1_dbgclks),
    .extsys_dbgclkm                (extsys1_dbgclkm),
    .extsys_atclk                  (extsys1_atclk),
    .extsys_cticlk                 (extsys1_cticlk),
    .extsys_aclk                   (extsys1_aclk),
    .extsys_mhuclk                 (extsys1_mhuclk),

    .extsys_mtx_resetn             (extsys1_mtx_resetn),
    .extsys_core_resetn            (extsys1_core_resetn),
    .extsys_dbg_resetn             (extsys1_dbg_resetn),

    .aclk_qreqn                    (extsys1_aclk_qreqn),
    .aclk_qacceptn                 (extsys1_aclk_qacceptn),
    .aclk_qdeny                    (extsys1_aclk_qdeny),
    .aclk_qactive                  (extsys1_aclk_qactive),

    .mhuclk_qreqn                  (extsys1_mhuclk_qreqn),
    .mhuclk_qacceptn               (extsys1_mhuclk_qacceptn),
    .mhuclk_qdeny                  (extsys1_mhuclk_qdeny),
    .mhuclk_qactive                (extsys1_mhuclk_qactive),

    .atclk_qreqn                   (extsys1_atclk_qreqn),
    .atclk_qacceptn                (extsys1_atclk_qacceptn),
    .atclk_qdeny                   (extsys1_atclk_qdeny),
    .atclk_qactive                 (extsys1_atclk_qactive),

    .dbgclkm_qreqn                 (extsys1_dbgclkm_qreqn),
    .dbgclkm_qacceptn              (extsys1_dbgclkm_qacceptn),
    .dbgclkm_qdeny                 (extsys1_dbgclkm_qdeny),
    .dbgclkm_qactive               (extsys1_dbgclkm_qactive),

    .dbgclks_qreqn                 (extsys1_dbgclks_qreqn),
    .dbgclks_qacceptn              (extsys1_dbgclks_qacceptn),
    .dbgclks_qdeny                 (extsys1_dbgclks_qdeny),
    .dbgclks_qactive               (extsys1_dbgclks_qactive),

    .cticlk_qreqn                  (extsys1_cticlk_qreqn),
    .cticlk_qacceptn               (extsys1_cticlk_qacceptn),
    .cticlk_qdeny                  (extsys1_cticlk_qdeny),
    .cticlk_qactive                (extsys1_cticlk_qactive),

    .mem_awakeup                   (extsys1_mem_awakeup),
    .mem_awid                      (extsys1_mem_awid),
    .mem_awaddr                    (extsys1_mem_awaddr),
    .mem_awlen                     (extsys1_mem_awlen),
    .mem_awsize                    (extsys1_mem_awsize),
    .mem_awburst                   (extsys1_mem_awburst),
    .mem_awlock                    (extsys1_mem_awlock),
    .mem_awcache                   (extsys1_mem_awcache),
    .mem_awprot                    (extsys1_mem_awprot),
    .mem_awvalid                   (extsys1_mem_awvalid),
    .mem_awready                   (extsys1_mem_awready),

    .mem_wstrb                     (extsys1_mem_wstrb),
    .mem_wlast                     (extsys1_mem_wlast),
    .mem_wvalid                    (extsys1_mem_wvalid),
    .mem_wdata                     (extsys1_mem_wdata),
    .mem_wready                    (extsys1_mem_wready),

    .mem_bid                       (extsys1_mem_bid),
    .mem_bresp                     (extsys1_mem_bresp),
    .mem_bvalid                    (extsys1_mem_bvalid),
    .mem_bready                    (extsys1_mem_bready),

    .mem_arid                      (extsys1_mem_arid),
    .mem_araddr                    (extsys1_mem_araddr),
    .mem_arlen                     (extsys1_mem_arlen),
    .mem_arsize                    (extsys1_mem_arsize),
    .mem_arburst                   (extsys1_mem_arburst),
    .mem_arlock                    (extsys1_mem_arlock),
    .mem_arcache                   (extsys1_mem_arcache),
    .mem_arprot                    (extsys1_mem_arprot),
    .mem_arvalid                   (extsys1_mem_arvalid),
    .mem_arready                   (extsys1_mem_arready),

    .mem_rid                       (extsys1_mem_rid),
    .mem_rresp                     (extsys1_mem_rresp),
    .mem_rlast                     (extsys1_mem_rlast),
    .mem_rvalid                    (extsys1_mem_rvalid),
    .mem_rdata                     (extsys1_mem_rdata),
    .mem_rready                    (extsys1_mem_rready),

    .sysreg_apb_async_req          (extsys1_sysreg_apb_async_req),
    .sysreg_apb_async_req_payload  (extsys1_sysreg_apb_async_req_payload),
    .sysreg_apb_async_resp_payload (extsys1_sysreg_apb_async_resp_payload),
    .sysreg_apb_async_ack          (extsys1_sysreg_apb_async_ack),
    
    .uart_apb_async_req            (extsys1_uart_apb_async_req),
    .uart_apb_async_req_payload    (extsys1_uart_apb_async_req_payload),
    .uart_apb_async_resp_payload   (extsys1_uart_apb_async_resp_payload),
    .uart_apb_async_ack            (extsys1_uart_apb_async_ack),

    .mhu_psel                      (extsys1_mhu_psel),
    .mhu_pwakeup                   (extsys1_mhu_pwakeup),
    .mhu_penable                   (extsys1_mhu_penable),
    .mhu_paddr                     (extsys1_mhu_paddr),
    .mhu_pwrite                    (extsys1_mhu_pwrite),
    .mhu_pwdata                    (extsys1_mhu_pwdata),
    .mhu_pstrb                     (extsys1_mhu_pstrb),
    .mhu_pprot                     (extsys1_mhu_pprot),
    .mhu_prdata                    (extsys1_mhu_prdata),
    .mhu_pready                    (extsys1_mhu_pready),
    .mhu_pslverr                   (extsys1_mhu_pslverr),

    .dbg_dpabort                   (extsys1_dbg_dpabort),
    .dbg_psel                      (extsys1_dbg_psel),
    .dbg_penable                   (extsys1_dbg_penable),
    .dbg_pwrite                    (extsys1_dbg_pwrite),
    .dbg_paddr                     (extsys1_dbg_paddr),
    .dbg_pwdata                    (extsys1_dbg_pwdata),
    .dbg_pready                    (extsys1_dbg_pready),
    .dbg_pslverr                   (extsys1_dbg_pslverr),
    .dbg_prdata                    (extsys1_dbg_prdata),

    .extdbg_psel                   (extsys1_extdbg_psel),
    .extdbg_pwakeup                (extsys1_extdbg_pwakeup),
    .extdbg_penable                (extsys1_extdbg_penable),
    .extdbg_paddr                  (extsys1_extdbg_paddr),
    .extdbg_pwrite                 (extsys1_extdbg_pwrite),
    .extdbg_pwdata                 (extsys1_extdbg_pwdata),
    .extdbg_pstrb                  (extsys1_extdbg_pstrb),
    .extdbg_pprot                  (extsys1_extdbg_pprot),
    .extdbg_prdata                 (extsys1_extdbg_prdata),
    .extdbg_pready                 (extsys1_extdbg_pready),
    .extdbg_pslverr                (extsys1_extdbg_pslverr),

    .slvmustacceptreqn_async       (extsys1_slvmustacceptreqn_async),
    .slvcandenyreqn_async          (extsys1_slvcandenyreqn_async),
    .slvacceptn_async              (extsys1_slvacceptn_async),
    .slvdeny_async                 (extsys1_slvdeny_async),

    .si_to_mi_wakeup_async         (extsys1_si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async         (extsys1_mi_to_si_wakeup_async),

    .aw_wr_ptr_async               (extsys1_aw_wr_ptr_async),
    .aw_rd_ptr_async               (extsys1_aw_rd_ptr_async),
    .aw_payld_async                (extsys1_aw_payld_async),

    .w_wr_ptr_async                (extsys1_w_wr_ptr_async),
    .w_rd_ptr_async                (extsys1_w_rd_ptr_async),
    .w_payld_async                 (extsys1_w_payld_async),

    .b_wr_ptr_async                (extsys1_b_wr_ptr_async),
    .b_rd_ptr_async                (extsys1_b_rd_ptr_async),
    .b_payld_async                 (extsys1_b_payld_async),

    .ar_wr_ptr_async               (extsys1_ar_wr_ptr_async),
    .ar_rd_ptr_async               (extsys1_ar_rd_ptr_async),
    .ar_payld_async                (extsys1_ar_payld_async),

    .r_wr_ptr_async                (extsys1_r_wr_ptr_async),
    .r_rd_ptr_async                (extsys1_r_rd_ptr_async),
    .r_payld_async                 (extsys1_r_payld_async),

    .extdbgrom_cdbgpwrupack_ss     (extsys1_extdbgrom_cdbgpwrupack),
    .axiaprom_csyspwrupack_ss      (extsys1_axiaprom_csyspwrupack),

    .hes_mhu0_comb_int             (extsys1_hes_mhu0_comb_int),
    .esh_mhu0_comb_int             (extsys1_esh_mhu0_comb_int),
    .sees_mhu0_comb_int            (extsys1_sees_mhu0_comb_int),
    .esse_mhu0_comb_int            (extsys1_esse_mhu0_comb_int),
   
    .hes_mhu1_comb_int             (extsys1_hes_mhu1_comb_int),
    .esh_mhu1_comb_int             (extsys1_esh_mhu1_comb_int),
    .sees_mhu1_comb_int            (extsys1_sees_mhu1_comb_int),
    .esse_mhu1_comb_int            (extsys1_esse_mhu1_comb_int),
   

   
    .extsys_shdint                 (extsys1_shdint[42:0]),
   

    .wdog_lockup_irq               (extsys1_wdog_lockup_irq),

    .sleeping                      (extsys1_sleeping),
    .sleep_hold_ackn               (extsys1_sleep_hold_ackn),
    .sysreset_req                  (extsys1_sysreset_req),

    .sleep_hold_reqn               (extsys1_sleep_hold_reqn),

    .clock_override_extsystop      (extsys1_clock_override_extsystop),

    .traceexp_atready              (extsys1_traceexp_atready),
    .traceexp_afvalid              (extsys1_traceexp_afvalid),
    .traceexp_syncreq              (extsys1_traceexp_syncreq),
    .traceexp_atid                 (extsys1_traceexp_atid),
    .traceexp_atvalid              (extsys1_traceexp_atvalid),
    .traceexp_atdata               (extsys1_traceexp_atdata),
    .traceexp_atbytes              (extsys1_traceexp_atbytes),
    .traceexp_afready              (extsys1_traceexp_afready),
    .traceexp_atwakeup             (extsys1_traceexp_atwakeup),
      .dbgen                         (scb_soc_expansion[4]),
    .niden                         (scb_soc_expansion[5]),
    .chen                          (scb_soc_expansion[6]),
    .dapen                         (scb_soc_expansion[7]),
      .ctichin                       (extsys1_ctichout),
    .ctichout                      (extsys1_ctichin),
    
    .uart_irq                      (extsys1_uart_irq),

    .nts_wr_ptr_encd_gry           (extsys1_nts_wr_ptr_encd_gry),
    .nts_rd_ptr_encd_gry           (extsys1_nts_rd_ptr_encd_gry),
    .nts_wr_ptr_sync_gry           (extsys1_nts_wr_ptr_sync_gry),
    .nts_rd_ptr_sync_gry           (extsys1_nts_rd_ptr_sync_gry),
    .nts_fw_data                   (extsys1_nts_fw_data),
    .nts_s_lp                      (extsys1_nts_s_lp),
    .nts_s_lp_return               (extsys1_nts_s_lp_return),
    .nts_m_lp                      (extsys1_nts_m_lp),

    .mbistreq                      (MBISTREQ),
    .dftcgen                       (DFTCGEN),
    .dftrstdisable                 (DFTRSTDISABLE),
    .dftse                         (DFTCGEN),
    .dftramhold                    (DFTRAMHOLD)
);
 


 

  arm_element_reset_sync u_arm_element_reset_sync_systop_warmresetn_aclkout (
    .clk                (aclkout_i),
    .resetn_async       (systop_warmresetn),
    .resetn_sync        (systop_warmresetn_s_aclkout),
    .dftrstdisable      (DFTRSTDISABLE[0])
);

  arm_element_reset_sync u_arm_element_reset_sync_systop_warmresetn_refclk (
    .clk                (REFCLK),
    .resetn_async       (systop_warmresetn),
    .resetn_sync        (systop_warmresetn_s_refclk),
    .dftrstdisable      (DFTRSTDISABLE[0])
);

  arm_element_reset_sync u_arm_element_reset_sync_dbgtop_warmresetn (
    .clk                (REFCLK),
    .resetn_async       (dbgtop_warmresetn),
    .resetn_sync        (dbgtop_warmresetn_s),
    .dftrstdisable      (DFTRSTDISABLE[1])
);

  arm_element_reset_sync u_arm_element_reset_sync_aontop_s32kclk (
    .clk                (S32KCLK),
    .resetn_async       (aontop_warmresetn),
    .resetn_sync        (aontop_warmresetn_s_s32kclk),
    .dftrstdisable      (DFTRSTDISABLE[0])
    );

  arm_element_reset_sync u_arm_element_reset_sync_aontop_hosts32kcntclkout (
    .clk                (hosts32kcntclkout),
    .resetn_async       (aontop_warmresetn),
    .resetn_sync        (aontop_warmresetn_s_hosts32kcntclkout),
    .dftrstdisable      (DFTRSTDISABLE[0])
  );

  arm_element_reset_sync u_arm_element_reset_sync_aontop_hostaonexpclk (
    .clk                (hostaonexpclk),
    .resetn_async       (aontop_warmresetn),
    .resetn_sync        (aontop_warmresetn_s_hostaonexpclk),
    .dftrstdisable      (DFTRSTDISABLE[0])
  );

  arm_element_reset_sync u_arm_element_reset_sync_aontop_hostcntclkout (
    .clk                (hostcntclkout),
    .resetn_async       (aontop_warmresetn),
    .resetn_sync        (aontop_warmresetn_s_hostcntclkout),
    .dftrstdisable      (DFTRSTDISABLE[0])
  );

  assign ACLKOUT          = aclkout_i;
  assign SYSTOPWARMRESETn = systop_warmresetn_s_aclkout;

// -----------------------------------------------------------------------------
// Gated clock generation for the switchable SYSTOP domain
  
  
  arm_element_cdc_capt_sync   u_arm_element_cdc_capt_sync   (
    .clk     (REFCLK),
    .nreset  (systop_warmresetn_s_refclk),
    .d_async (systop_qreqn_egress),
    .q       (systop_qacceptn_egress)
  );
  
  arm_element_clock_gate u_arm_element_clock_gate (
    .clk_in              (REFCLK),
    .enable              (systop_qacceptn_egress),
    .clk_out             (refclk_systop),
    .dftcgen             (DFTCGEN)
  );  

// -----------------------------------------------------------------------------
// ECO registers for product VERSION and REVISION

  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_arm_element_ecorevnum_0 (
    .ecorevnum (eco_socvar)
  );
  
  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_arm_element_ecorevnum_1 (
    .ecorevnum (eco_socrev)
  ); 

  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_arm_element_ecorevnum_2 (
    .ecorevnum (eco_dpromvar)
  );
  
  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_arm_element_ecorevnum_3 (
    .ecorevnum (eco_dpromrev)
  );
  
  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_arm_element_ecorevnum_4 (
    .ecorevnum (eco_extdbgromvar)
  );
  
  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_arm_element_ecorevnum_5 (
    .ecorevnum (eco_extdbgromrev)
  );

  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_arm_element_ecorevnum_6 (
    .ecorevnum (eco_hostromvar)
  );
  
  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_arm_element_ecorevnum_7 (
    .ecorevnum (eco_hostromrev)
  );

  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_arm_element_ecorevnum_8 (
    .ecorevnum (eco_hostaxiapromvar)
  );
  
  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_arm_element_ecorevnum_9 (
    .ecorevnum (eco_hostaxiapromrev)
  );
  
// -----------------------------------------------------------------------------
// Unused signals

  assign unused = |{
 
                    extsys0_mhu_pprot[1],
                    extsys0_extdbg_pprot[1],
                    extsys0_mem_arprot[1],
                    extsys0_mem_awprot[1],
                    extsys0_dbg_pwakeup,
                    extsys0_dbg_pstrb,
                    extsys0_dbg_pprot,
   
                    extsys0_mem_rid_unused,
                    extsys0_mem_bid_unused,
   
 
                    extsys1_mhu_pprot[1],
                    extsys1_extdbg_pprot[1],
                    extsys1_mem_arprot[1],
                    extsys1_mem_awprot[1],
                    extsys1_dbg_pwakeup,
                    extsys1_dbg_pstrb,
                    extsys1_dbg_pprot,
   
                    extsys1_mem_rid_unused,
                    extsys1_mem_bid_unused,
   
 
 
   
                    extsys0_shdint[95:43],
   
                    extsys1_shdint[95:43],
   
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                    scb_soc_expansion[12:9],
     
 
                    scb_soc_expansion[16:13],
                
                    scb_soc_expansion[63:17]};

endmodule

