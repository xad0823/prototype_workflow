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

module secenc_f1_aon #(
  parameter    [15:0] SEC_ENC_ROM_SIZE          = 16'd32,  
  parameter    [15:0] SEC_ENC_RAM_SIZE          = 16'd128, 
  parameter           CAAON2CA_WIDTH            = 289,     
  parameter           CA2CAAON_WIDTH            = 300,     
  parameter           DEV_PREQ_DLY_SECENC       = 0,       
  parameter           PCSM_PREQ_DLY_SECENC      = 0,       
  parameter           ISO_CLKEN_DLY_CFG_SECENC  = 0,       
  parameter           CLKEN_RST_DLY_CFG_SECENC  = 0,       
  parameter           RST_HWSTAT_DLY_CFG_SECENC = 0,       
  parameter           CLKEN_ISO_DLY_CFG_SECENC  = 0,       
  parameter           ISO_RST_DLY_CFG_SECENC    = 0        
) (
  input  wire         SECENCREFCLK,
  input  wire         SYSPLL,
  input  wire         SYSPLLLOCK,
  input  wire         S32KCLK,

  input  wire         SEPORESETn,

  output wire         SECENCCLK,
  output wire         SECENCDIVCLK,
  output wire         SECENCHINTCLK,
  output wire         S32KCLK_SECENC,
  output wire         SECENCPORESETn,
  output wire         SECENCWARMRESETn,

  input  wire         nUARTCTS,  
  input  wire         nUARTDCD,  
  input  wire         nUARTDSR,  
  input  wire         nUARTRI,   
  input  wire         UARTRXD,   
  output wire         UARTTXD,   
  output wire         nUARTDTR,  
  output wire         nUARTRTS,  
  output wire         nUARTOut1, 
  output wire         nUARTOut2, 

  input  wire  [63:0] EXTIRQ, 
  output wire         SOC_WD_IRQ,
  output wire         UART_IRQ,
  output wire         PPU_IRQ,
  output wire         CO_IRQ,
  input wire          MHU2R_CIRQ,
  input wire          MHU2S_CIRQ,
    input wire          MHU3R_CIRQ,
  input wire          MHU3S_CIRQ,
    input wire          MHU4R_CIRQ,
  input wire          MHU4S_CIRQ,
    input wire          MHU5R_CIRQ,
  input wire          MHU5S_CIRQ,
    input  wire         HOST_FWT_IRQ, 
  input  wire         INT_RTT_IRQ,  
  input  wire         SWD_WS1_IRQ,  
  output wire         HOST_FWT_IRQ_SS, 
  output wire         INT_RTT_IRQ_SS,  
  output wire         SWD_WS1_IRQ_SS,  

  input  wire         CALC,
  
  output wire  [127:0] SCB,

  input  wire   [1:0] HOST_RST_ACK,         
  output wire         HOST_CPUWAIT,         
  input  wire   [5:0] CHS_PWR_ST,           
  output wire   [5:0] CHS_PWR_REQ,          
  input  wire   [4:0] SOC_RST_SYN,          
  input  wire   [2:0] SE_RST_SYN,           
                                            
  output wire         S32_WDOG_RST_REQ,  
  output wire         SOC_RST_REQ,       
  output wire         HOST_RST_REQ,      
  output wire         CAE_RST_REQ,       

  input  wire         AON_APB_ASYNC_REQ,
  input  wire  [55:0] AON_APB_ASYNC_REQ_PAYLOAD,
  output wire  [32:0] AON_APB_ASYNC_RESP_PAYLOAD,
  output wire         AON_APB_ASYNC_ACK,

  input  wire         SOCWD_APB_ASYNC_REQ,
  input  wire  [47:0] SOCWD_APB_ASYNC_REQ_PAYLOAD,
  output wire  [32:0] SOCWD_APB_ASYNC_RESP_PAYLOAD,
  output wire         SOCWD_APB_ASYNC_ACK,

  output wire         DBGD_QREQn,
  input  wire         DBGD_QACCEPTn,
  input  wire         DBGD_QDENY,
  input  wire         DBGD_QACTIVE,
  output wire         MHU0_QREQn,
  input  wire         MHU0_QACCEPTn,
  input  wire         MHU0_QDENY,
  output wire         MHU1_QREQn,
  input  wire         MHU1_QACCEPTn,
  input  wire         MHU1_QDENY,
  output wire         MHU2_QREQn,
  input  wire         MHU2_QACCEPTn,
  input  wire         MHU2_QDENY,
    output wire         MHU3_QREQn,
  input  wire         MHU3_QACCEPTn,
  input  wire         MHU3_QDENY,
    output wire         MHU4_QREQn,
  input  wire         MHU4_QACCEPTn,
  input  wire         MHU4_QDENY,
    output wire         MHU5_QREQn,
  input  wire         MHU5_QACCEPTn,
  input  wire         MHU5_QDENY,
    output wire         CTI_QREQn,
  input  wire         CTI_QACCEPTn,
  input  wire         CTI_QDENY,
  input  wire         CTI_QACTIVE,

  output wire         CM0_QREQn,
  input  wire         CM0_QACCEPTn,
  input  wire         CM0_QDENY,
  input  wire         CM0_QACTIVE,

  output wire         AXIB_QREQn,
  input  wire         AXIB_QACCEPTn,
  input  wire         AXIB_QDENY,
  input  wire         AXIB_QACTIVE,

  output wire         SOCWD_ADB_QREQn,
  input  wire         SOCWD_ADB_QACCEPTn,
  input  wire         SOCWD_ADB_QDENY,
  input  wire         SOCWD_ADB_QACTIVE,

  output wire         AON_ADB_QREQn,
  input  wire         AON_ADB_QACCEPTn,
  input  wire         AON_ADB_QDENY,
  input  wire         AON_ADB_QACTIVE,
  
  input  wire         SYSC_QREQn,
  output wire         SYSC_QACCEPTn,
  output wire         SYSC_QDENY,
  output wire         SYSC_QACTIVE,

  input  wire         DBGC_QREQn,
  output wire         DBGC_QACCEPTn,
  output wire         DBGC_QDENY,
  output wire         DBGC_QACTIVE,

  input  wire         MHU_HSE0_RECWAKEUP_ASYNC,
  input  wire         MHU_HSE1_RECWAKEUP_ASYNC,
  input  wire         MHU_ES0SE0_RECWAKEUP_ASYNC,
    input  wire         MHU_ES0SE1_RECWAKEUP_ASYNC,
    input  wire         MHU_ES1SE0_RECWAKEUP_ASYNC,
    input  wire         MHU_ES1SE1_RECWAKEUP_ASYNC,
    input  wire         CDBGPWRUPREQ0,
  output wire         CDBGPWRUPACK0,

  output wire         CLKFORCE,
  output wire [7:0]   ENTRY_DELAY,

  input wire          M0_HALTED,

  output wire   [CAAON2CA_WIDTH-1:0] CAAON2CA,
  input  wire   [CA2CAAON_WIDTH-1:0] CA2CAAON,
  
  input  wire         CAE,
  output wire         CA_ERR_MSK,
  

  input  wire         DFTDIVSEL,
  input  wire         DFTCLKSELEN,
  input  wire   [1:0] DFTCLKSEL,
  input  wire         DFTDIVBYPASS,
  input  wire   [1:0] DFTRSTDISABLE,
  input  wire         DFTISODISABLE,
  input  wire         DFTPWRUP,
  input  wire         DFTRETDISABLE,
  input  wire         DFTCGEN,
  input  wire         nMBISTRESET,
  input  wire         MBISTREQ,
  input  wire         DFTSE,
  input  wire         DFTTESTMODE
);



  localparam LP_IRQCOL0   = 32'h0000_01FF;
  localparam LP_IRQCOL1   = 32'hFFFF_FFFF;
 
   
     
  localparam LP_IRQCOL2_0 = 4'hF;
     
   
 
   
     
  localparam LP_IRQCOL2_1 = 4'hF;
     
   
 
   
  localparam LP_IRQCOL2_2 = 4'h0;
   
 
   
  localparam LP_IRQCOL2_3 = 4'h0;
   
 
  localparam LP_IRQCOL2   = {16'h0000, LP_IRQCOL2_3, LP_IRQCOL2_2, LP_IRQCOL2_1, LP_IRQCOL2_0};
  localparam LP_IRQCOL3   = 32'h0000_0000;

  localparam LP_IRQCOL = {LP_IRQCOL3, LP_IRQCOL2, LP_IRQCOL1, LP_IRQCOL0};

  
  wire [127:0] int_i;  
  wire [127:0] int_st; 
  wire [127:0] int_mask;
  wire  [31:0] int_msk0;
  wire  [31:0] int_msk1;
  wire  [31:0] int_msk2;

  wire         aon_clk;  
  wire         aon_rstn; 

  wire         s32k_clk;
  wire         s32k_rstn; 

  wire         caaon_clk;
  wire         caaon_rstn;

  wire         core_psel;
  wire         core_penable;
  wire [19:0]  core_paddr;
  wire         core_pwrite;
  wire [31:0]  core_pwdata;
  wire         core_pready;
  wire [31:0]  core_prdata;
  wire         core_pslverr;

  wire         uart_psel;
  wire         uart_penable;
  wire  [9:0]  uart_paddr;
  wire         uart_pwrite;
  wire [31:0]  uart_pwdata;
  wire [31:0]  uart_prdata;

  wire         ppu_psel;
  wire         ppu_penable;
  wire [31:0]  ppu_paddr;
  wire         ppu_pwrite;
  wire [31:0]  ppu_pwdata;
  wire         ppu_pready;
  wire [31:0]  ppu_prdata;
  wire         ppu_pslverr;

  wire         wd_psel;
  wire         wd_penable;
  wire [11:0]  wd_paddr;
  wire         wd_pwrite;
  wire [31:0]  wd_pwdata;
  wire [31:0]  wd_prdata;
  wire         wd_pready;
  wire         wd_pslverr;
  wire  [3:0]  wd_ecorevnum;
  wire         wd_rst_req_32k;
  reg          wd_rst_req_32k_s;
  wire         wd_clken;
  wire         wdogint;
  reg          wdogint_s;
  wire         wdogint_ss_int;

  wire         ctrl_psel;
  wire         ctrl_penable;
  wire [11:0]  ctrl_paddr;
  wire         ctrl_pwrite;
  wire [31:0]  ctrl_pwdata;
  wire [31:0]  ctrl_prdata;

  wire         chac_psel;
  wire         chac_penable;
  wire [11:0]  chac_paddr;
  wire         chac_pwrite;
  wire [31:0]  chac_pwdata;
  wire [31:0]  chac_prdata;

  wire  [3:0]  remap_select;

  wire  [1:0]  clkselect;
  wire  [1:0]  clkselect_cur;
  wire  [4:0]  pll_clkdiv;
  wire  [4:0]  pll_clkdiv_cur;
  wire  [4:0]  cm0_clkdiv;  
  wire  [4:0]  cm0_clkdiv_cur;
  wire         ppu_clken;
  wire         pwr_gate_en;
  wire         irq_wakeup;   
  reg          irq_wakeup_s; 
  wire         comb_int;
  wire  [6:0]  chs_pwr_req_i; 
  wire         ppu_irq_int;
  wire         uart_irq_int;

  wire         pcsm_preq;
  wire  [3:0]  pcsm_pstate;
  wire         pcsm_paccept;

  wire         m0_halted_ss;
  wire         host_fwt_irq_ss_int;
  wire         int_rtt_irq_ss_int;
  wire         swd_ws1_irq_ss_int;

  wire [127:0] ca_scb;
  wire         ppu_dbgen;
  wire         ppu_dbgen_ss;
  wire         host_cpuwait_wen;
  wire         host_cpuwait_wen_ss;
  wire         cae_ss;

  wire         syspll_lock_ss;

  wire         nuartcts_ss;
  wire         nuartdcd_ss;
  wire         nuartdsr_ss;
  wire         nuartri_ss;
  wire         uartrxd_ss;
  
  wire         capwrq_qreqn;
  wire         capwrq_qacceptn;
  wire         capwrq_qdeny;
  wire         capwrq_qactive;
  
  reg  [127:0] ca_scb_masked;
  wire [127:0] ca_scb_masked_nxt;
  reg          cae_rst_req_r;
  wire         cae_rst_req_en;
  wire         ca_err_msk_int;

  wire         unused; 


  sec_reset_sync u_sec_reset_sync_0 (
    .clk            (aon_clk),
    .resetn_async   (SEPORESETn),
    .resetn_sync    (aon_rstn),
    .dftrstdisable  (DFTRSTDISABLE[0])
  );

  sec_reset_sync u_sec_reset_sync_1 (
    .clk            (s32k_clk),
    .resetn_async   (SEPORESETn),
    .resetn_sync    (s32k_rstn),
    .dftrstdisable  (DFTRSTDISABLE[0])
  );

  sec_reset_sync u_sec_reset_sync_2 (
    .clk            (caaon_clk),
    .resetn_async   (SEPORESETn),
    .resetn_sync    (caaon_rstn),
    .dftrstdisable  (DFTRSTDISABLE[0])
  );


  sec_cdc_capt_sync u_sec_cdc_capt_sync_0 (
    .clk        (s32k_clk),
    .nreset     (s32k_rstn),
    .d_async    (M0_HALTED),
    .q          (m0_halted_ss)
  );

  sec_cdc_capt_sync u_sec_cdc_capt_sync_1 (
    .clk        (aon_clk),
    .nreset     (aon_rstn),
    .d_async    (HOST_FWT_IRQ),
    .q          (host_fwt_irq_ss_int)
  );

  sec_cdc_capt_sync u_sec_cdc_capt_sync_2 (
    .clk        (aon_clk),
    .nreset     (aon_rstn),
    .d_async    (INT_RTT_IRQ),
    .q          (int_rtt_irq_ss_int)
  );

  sec_cdc_capt_sync u_sec_cdc_capt_sync_3 (
    .clk        (aon_clk),
    .nreset     (aon_rstn),
    .d_async    (SWD_WS1_IRQ),
    .q          (swd_ws1_irq_ss_int)
  );

  sec_cdc_capt_sync u_sec_cdc_capt_sync_4 (
    .clk        (aon_clk),
    .nreset     (aon_rstn),
    .d_async    (wdogint_s),
    .q          (wdogint_ss_int)
  );

  sec_cdc_capt_sync u_sec_cdc_capt_sync_5 (
    .clk        (aon_clk),
    .nreset     (aon_rstn),
    .d_async    (ppu_dbgen),
    .q          (ppu_dbgen_ss)
  );

  sec_cdc_capt_sync u_sec_cdc_capt_sync_6 (
    .clk        (aon_clk),
    .nreset     (aon_rstn),
    .d_async    (SYSPLLLOCK),
    .q          (syspll_lock_ss)
  );
  
  sec_cdc_capt_sync u_sec_cdc_capt_sync_7 (
    .clk        (aon_clk),
    .nreset     (aon_rstn),
    .d_async    (host_cpuwait_wen),
    .q          (host_cpuwait_wen_ss)
  );  

  sec_cdc_capt_sync u_sec_cdc_capt_sync_8 (
    .clk        (aon_clk),
    .nreset     (aon_rstn),
    .d_async    (nUARTCTS),
    .q          (nuartcts_ss)
  );  

  sec_cdc_capt_sync u_sec_cdc_capt_sync_9 (
    .clk        (aon_clk),
    .nreset     (aon_rstn),
    .d_async    (nUARTDCD),
    .q          (nuartdcd_ss)
  );  

  sec_cdc_capt_sync u_sec_cdc_capt_sync_10 (
    .clk        (aon_clk),
    .nreset     (aon_rstn),
    .d_async    (nUARTDSR),
    .q          (nuartdsr_ss)
  );  

  sec_cdc_capt_sync u_sec_cdc_capt_sync_11 (
    .clk        (aon_clk),
    .nreset     (aon_rstn),
    .d_async    (nUARTRI),
    .q          (nuartri_ss)
  );  

  sec_cdc_capt_sync u_sec_cdc_capt_sync_12 (
    .clk        (aon_clk),
    .nreset     (aon_rstn),
    .d_async    (UARTRXD),
    .q          (uartrxd_ss)
  );
  
  sec_cdc_capt_sync u_sec_cdc_capt_sync_13 (
    .clk        (caaon_clk),
    .nreset     (aon_rstn),
    .d_async    (CAE),
    .q          (cae_ss)
  );

  
  css600_apbasyncbridgemstr #(
    .APB_ADDR_WIDTH           (20),
    .FF_SYNC_DEPTH            (2)
  ) u_css600_apbasyncbridgemstr_0 (
    .clk_m                    (aon_clk),
    .reset_m_n                (aon_rstn),
    .dftcgen                  (DFTCGEN),
    .psel_m                   (core_psel),
    .penable_m                (core_penable),
    .paddr_m                  (core_paddr),
    .pwrite_m                 (core_pwrite),
    .pwdata_m                 (core_pwdata),
    .pprot_m                  (),
    .prdata_m                 (core_prdata),
    .pready_m                 (core_pready),
    .pslverr_m                (core_pslverr),
    .pwakeup_m                (),
    .clk_m_qreq_n             (1'b1),
    .clk_m_qaccept_n          (),
    .clk_m_qdeny              (),
    .clk_m_qactive            (),
    .apb_async_req            (AON_APB_ASYNC_REQ),
    .apb_async_req_payload    (AON_APB_ASYNC_REQ_PAYLOAD),
    .apb_async_resp_payload   (AON_APB_ASYNC_RESP_PAYLOAD),
    .apb_async_ack            (AON_APB_ASYNC_ACK)
  );

  css600_apbasyncbridgemstr #(
    .APB_ADDR_WIDTH           (12),
    .FF_SYNC_DEPTH            (2)
  ) u_css600_apbasyncbridgemstr_1 (
    .clk_m                    (s32k_clk),
    .reset_m_n                (s32k_rstn),
    .dftcgen                  (DFTCGEN),
    .psel_m                   (wd_psel),
    .penable_m                (wd_penable),
    .paddr_m                  (wd_paddr),
    .pwrite_m                 (wd_pwrite),
    .pwdata_m                 (wd_pwdata),
    .pprot_m                  (),
    .prdata_m                 (wd_prdata),
    .pready_m                 (wd_pready),
    .pslverr_m                (wd_pslverr),
    .pwakeup_m                (),
    .clk_m_qreq_n             (1'b1),
    .clk_m_qaccept_n          (),
    .clk_m_qdeny              (),
    .clk_m_qactive            (),
    .apb_async_req            (SOCWD_APB_ASYNC_REQ),
    .apb_async_req_payload    (SOCWD_APB_ASYNC_REQ_PAYLOAD),
    .apb_async_resp_payload   (SOCWD_APB_ASYNC_RESP_PAYLOAD),
    .apb_async_ack            (SOCWD_APB_ASYNC_ACK)
  );


  assign remap_select = (core_paddr[19:12] == 8'h90) ? 4'b0001                                                                          : 
                        (core_paddr[19:12] == 8'h8d) ? ((core_paddr[11:3] == 9'h004 & core_pwrite & ~ppu_dbgen_ss) ? 4'b0000 : 4'b0010) : 
                        (core_paddr[19:12] == 8'h80) ? 4'b0011                                                                          : 
                        (core_paddr[19:12] == 8'h8e) ? 4'b0100                                                                          : 
                                                       4'b0000;                                                                           

  cmsdk_apb_slave_mux #(
    .PORT0_ENABLE   (1), 
    .PORT1_ENABLE   (1), 
    .PORT2_ENABLE   (1), 
    .PORT3_ENABLE   (1), 
    .PORT4_ENABLE   (1), 
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
    .DECODE4BIT     (remap_select),
    .PSEL           (core_psel),
    .PSEL0          (),
    .PREADY0        (1'b1),
    .PRDATA0        (32'h0),
    .PSLVERR0       (1'b1),
    .PSEL1          (uart_psel),
    .PREADY1        (1'b1),
    .PRDATA1        (uart_prdata),
    .PSLVERR1       (1'b0),
    .PSEL2          (ppu_psel),
    .PREADY2        (ppu_pready),
    .PRDATA2        (ppu_prdata),
    .PSLVERR2       (ppu_pslverr),
    .PSEL3          (ctrl_psel),
    .PREADY3        (1'b1),
    .PRDATA3        (ctrl_prdata),
    .PSLVERR3       (1'b0),
    .PSEL4          (chac_psel),
    .PREADY4        (1'b1),
    .PRDATA4        (chac_prdata),
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
    .PREADY         (core_pready),
    .PRDATA         (core_prdata),
    .PSLVERR        (core_pslverr)
  );

  assign uart_paddr   = core_paddr[11:2];
  assign uart_pwdata  = core_pwdata;
  assign uart_penable = core_penable;
  assign uart_pwrite  = core_pwrite;

  assign ppu_paddr    = {20'b0, core_paddr[11:0]};
  assign ppu_pwdata   = core_pwdata;
  assign ppu_penable  = core_penable;
  assign ppu_pwrite   = core_pwrite;

  assign ctrl_paddr   = core_paddr[11:0];
  assign ctrl_pwdata  = core_pwdata;
  assign ctrl_penable = core_penable;
  assign ctrl_pwrite  = core_pwrite;

  assign chac_paddr   = core_paddr[11:0];
  assign chac_pwdata  = core_pwdata;
  assign chac_penable = core_penable;
  assign chac_pwrite  = core_pwrite;

  assign uart_prdata[31:16]  = 16'b0;

  
  crypto_accelerator_aon #(
     .CAAON2CA_WIDTH    (CAAON2CA_WIDTH),
     .CA2CAAON_WIDTH    (CA2CAAON_WIDTH)
  ) u_crypto_accelerator_aon (
    .CRYPTOAONCLKOUT    (caaon_clk),
    .CRYPTOAONRESETn    (caaon_rstn),
    .CAAON2CA           (CAAON2CA),
    .CA2CAAON           (CA2CAAON),
    .CALC               (CALC),
    .SCB                (ca_scb),
    .CAPWRQREQn         (capwrq_qreqn),
    .CAPWRQACCEPTn      (capwrq_qacceptn),
    .CAPWRQDENY         (capwrq_qdeny),
    .CAPWRQACTIVE       (capwrq_qactive),
    .MBISTREQ           (MBISTREQ),
    .DFTCGEN            (DFTCGEN),
    .DFTSE              (DFTSE),
    .DFTTESTMODE        (DFTTESTMODE)
  );
  

  
  assign cae_rst_req_en = cae_ss & ~ca_err_msk_int;
  
  always @(posedge caaon_clk or negedge aon_rstn)
  begin
    if(~aon_rstn)
      cae_rst_req_r <= 1'b0;
    else if (cae_rst_req_en)
      cae_rst_req_r <= 1'b1;
  end
  
  always @(posedge caaon_clk or negedge aon_rstn)
  begin
    if(~aon_rstn)
      ca_scb_masked <= 128'b0;
    else
      ca_scb_masked <= ca_scb_masked_nxt;
  end  
  
  assign ca_scb_masked_nxt = cae_rst_req_r ? 128'b0 : ca_scb;
  
  assign CAE_RST_REQ      = cae_rst_req_r;
  assign CA_ERR_MSK       = ca_err_msk_int;
  assign SCB              = ca_scb_masked;
  assign ppu_dbgen        = ca_scb_masked[35];
  assign host_cpuwait_wen = ca_scb_masked[48];
    
  
  Uart u_Uart (
    .PCLK              (aon_clk),            
    .PRESETn           (aon_rstn),           
    .PADDR             (uart_paddr),         
    .PWDATA            (uart_pwdata[15:0]),  
    .PENABLE           (uart_penable),       
    .PWRITE            (uart_pwrite),        
    .PSEL              (uart_psel),          
    .PRDATA            (uart_prdata[15:0]),  
    .UARTCLK           (aon_clk),            
    .nUARTRST          (aon_rstn),           
    .UARTMSINTR        (),                   
    .UARTRXINTR        (),                   
    .UARTTXINTR        (),                   
    .UARTRTINTR        (),                   
    .UARTEINTR         (),                   
    .UARTINTR          (uart_irq_int),       
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
    .UARTTXD           (UARTTXD),            
    .nSIROUT           (),                   
    .nUARTDTR          (nUARTDTR),           
    .nUARTRTS          (nUARTRTS),           
    .nUARTOut1         (nUARTOut1),          
    .nUARTOut2         (nUARTOut2)           
  );


  sec_pwr_ctrl #(
    .DEV_PREQ_DLY_SECENC       (DEV_PREQ_DLY_SECENC),
    .PCSM_PREQ_DLY_SECENC      (PCSM_PREQ_DLY_SECENC),
    .ISO_CLKEN_DLY_CFG_SECENC  (ISO_CLKEN_DLY_CFG_SECENC),
    .CLKEN_RST_DLY_CFG_SECENC  (CLKEN_RST_DLY_CFG_SECENC),
    .RST_HWSTAT_DLY_CFG_SECENC (RST_HWSTAT_DLY_CFG_SECENC),
    .CLKEN_ISO_DLY_CFG_SECENC  (CLKEN_ISO_DLY_CFG_SECENC),
    .ISO_RST_DLY_CFG_SECENC    (ISO_RST_DLY_CFG_SECENC)
  ) u_sec_pwr_ctrl (
    .clk              (aon_clk),
    .rst_n            (aon_rstn),
    .ppu_psel         (ppu_psel),
    .ppu_penable      (ppu_penable),
    .ppu_paddr        (ppu_paddr),
    .ppu_pwrite       (ppu_pwrite),
    .ppu_pwdata       (ppu_pwdata),
    .ppu_prdata       (ppu_prdata),
    .ppu_pready       (ppu_pready),
    .ppu_pslverr      (ppu_pslverr),
    .ppu_irq          (ppu_irq_int),
    .ppu_clken        (ppu_clken),
    .devwarmresetn    (SECENCWARMRESETn),
    .devporesetn      (SECENCPORESETn),
    .pcsm_preq        (pcsm_preq),
    .pcsm_pstate      (pcsm_pstate),
    .pcsm_paccept     (pcsm_paccept),
    .dev0_qreqn       ({capwrq_qreqn   , AON_ADB_QREQn   , SOCWD_ADB_QREQn   ,AXIB_QREQn   }),
    .dev0_qacceptn    ({capwrq_qacceptn, AON_ADB_QACCEPTn, SOCWD_ADB_QACCEPTn,AXIB_QACCEPTn}),
    .dev0_qdeny       ({capwrq_qdeny   , AON_ADB_QDENY   , SOCWD_ADB_QDENY   ,AXIB_QDENY   }),
    .dev0_qactive     ({capwrq_qactive , AON_ADB_QACTIVE , SOCWD_ADB_QACTIVE ,AXIB_QACTIVE }),
    .dev1_qreqn       (CM0_QREQn),
    .dev1_qacceptn    (CM0_QACCEPTn),
    .dev1_qdeny       (CM0_QDENY),
    .dev1_qactive     (CM0_QACTIVE),
    .dev2_qreqn       ({CTI_QREQn    ,MHU1_QREQn    ,MHU0_QREQn    ,DBGD_QREQn}),
    .dev2_qacceptn    ({CTI_QACCEPTn ,MHU1_QACCEPTn ,MHU0_QACCEPTn ,DBGD_QACCEPTn}),
    .dev2_qdeny       ({CTI_QDENY    ,MHU1_QDENY    ,MHU0_QDENY    ,DBGD_QDENY}),
    .dev2_qactive     ({CTI_QACTIVE  ,1'b0          ,1'b0          ,DBGD_QACTIVE}),
    .dev2_es00_qreqn       (MHU2_QREQn   ),
    .dev2_es00_qacceptn    (MHU2_QACCEPTn),
    .dev2_es00_qdeny       (MHU2_QDENY   ),
    .dev2_es00_qactive     (1'b0         ),
      .dev2_es01_qreqn       (MHU3_QREQn   ),
    .dev2_es01_qacceptn    (MHU3_QACCEPTn),
    .dev2_es01_qdeny       (MHU3_QDENY   ),
    .dev2_es01_qactive     (1'b0         ),
      .dev2_es10_qreqn       (MHU4_QREQn   ),
    .dev2_es10_qacceptn    (MHU4_QACCEPTn),
    .dev2_es10_qdeny       (MHU4_QDENY   ),
    .dev2_es10_qactive     (1'b0         ),
      .dev2_es11_qreqn       (MHU5_QREQn   ),
    .dev2_es11_qacceptn    (MHU5_QACCEPTn),
    .dev2_es11_qdeny       (MHU5_QDENY   ),
    .dev2_es11_qactive     (1'b0         ),
      .ctrl0_qreqn      (SYSC_QREQn),
    .ctrl0_qacceptn   (SYSC_QACCEPTn),
    .ctrl0_qdeny      (SYSC_QDENY),
    .ctrl0_qactive    (SYSC_QACTIVE),
    .ctrl1_qreqn      (DBGC_QREQn),
    .ctrl1_qacceptn   (DBGC_QACCEPTn),
    .ctrl1_qdeny      (DBGC_QDENY),
    .ctrl1_qactive    (DBGC_QACTIVE),
    .pwr_gate_en      (pwr_gate_en),
    .mhu1_recwakeup   (MHU_HSE1_RECWAKEUP_ASYNC),
    .mhu0_recwakeup   (MHU_HSE0_RECWAKEUP_ASYNC),
    .mhu2_recwakeup   (MHU_ES0SE0_RECWAKEUP_ASYNC),
      .mhu3_recwakeup   (MHU_ES0SE1_RECWAKEUP_ASYNC),
      .mhu4_recwakeup   (MHU_ES1SE0_RECWAKEUP_ASYNC),
      .mhu5_recwakeup   (MHU_ES1SE1_RECWAKEUP_ASYNC),
      .irq_wakeup       (irq_wakeup_s),
    .cdbg_pwrup_req0  (CDBGPWRUPREQ0),
    .cdbg_pwrup_ack0  (CDBGPWRUPACK0),
    .dftrstdisable    (DFTRSTDISABLE[1]),
    .dftisodisable    (DFTISODISABLE),
    .dftcgen          (DFTCGEN)
  );

  pck600_ppu_pcsm_sse710_secenc #(
    .LGC_OFF_ON_DLY       (8'h08),
    .LGC_ON_OFF_DLY       (8'h08),
    .LGC_ON_ONRET_DLY     (8'h08),
    .LGC_ONRET_RET_DLY    (8'h08),
    .LGC_ONRET_ON_DLY     (8'h08),
    .LGC_RET_ONRET_DLY    (8'h08),
    .RAM_OFF_ON_DLY       (8'h08),
    .RAM_ON_OFF_DLY       (8'h08),
    .RAM_ON_ONRET_DLY     (8'h08),
    .RAM_ONRET_RET_DLY    (8'h08),
    .RAM_ONRET_ON_DLY     (8'h08),
    .RAM_RET_ONRET_DLY    (8'h08),
    .RAM_OFF_RET_DLY      (8'h08)
  ) u_pck600_ppu_pcsm_sse710_secenc (
    .clk                  (aon_clk),
    .reset_n              (aon_rstn),
    .dftpwrup             (DFTPWRUP),
    .dftretdisable        (DFTRETDISABLE),
    .pcsm_preq_i          (pcsm_preq),
    .pcsm_pstate_i        (pcsm_pstate),
    .pcsm_paccept_o       (pcsm_paccept),
    .lgcpwrn_o            (),
    .lgcretn_o            (),
    .rampwrn_o            (),
    .ramretn_o            ()
  );

  assign irq_wakeup = (uart_irq_int | ppu_irq_int | wdogint_ss_int | comb_int | host_fwt_irq_ss_int | int_rtt_irq_ss_int | swd_ws1_irq_ss_int) & chs_pwr_req_i[0];

  always @(posedge aon_clk or negedge aon_rstn)
  begin
    if(!aon_rstn)
      irq_wakeup_s <= 1'b0;
    else
      irq_wakeup_s <= irq_wakeup;
  end


  assign wd_clken = ~m0_halted_ss;

  cmsdk_apb_watchdog u_cmsdk_apb_watchdog (
    .PCLK             (s32k_clk),
    .PRESETn          (s32k_rstn),
    .PENABLE          (wd_penable),
    .PSEL             (wd_psel),
    .PADDR            (wd_paddr[11:2]),
    .PWRITE           (wd_pwrite),
    .PWDATA           (wd_pwdata),
    .WDOGCLK          (s32k_clk),
    .WDOGCLKEN        (wd_clken),
    .WDOGRESn         (s32k_rstn),
    .ECOREVNUM        (wd_ecorevnum),
    .PRDATA           (wd_prdata),
    .WDOGINT          (wdogint),
    .WDOGRES          (wd_rst_req_32k)
  );

  assign wd_pslverr = 1'b0;
  assign wd_pready  = 1'b1;

  always @(posedge s32k_clk or negedge s32k_rstn)
  begin
    if(!s32k_rstn)
      wdogint_s <= 1'b0;
    else
      wdogint_s <= wdogint;
  end

  always @(posedge s32k_clk or negedge s32k_rstn)
  begin
    if(!s32k_rstn)
      wd_rst_req_32k_s <= 1'b0;
    else
      wd_rst_req_32k_s <= wd_rst_req_32k;
  end

  sec_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_sec_ecorevnum_0 (
    .ecorevnum (wd_ecorevnum)
  );

  
  sec_ctrl_reg #(
    .SEC_ENC_ROM_SIZE   (SEC_ENC_ROM_SIZE),
    .SEC_ENC_RAM_SIZE   (SEC_ENC_RAM_SIZE)
  ) u_sec_ctrl_reg (
    .clk                (aon_clk),
    .rst_n              (aon_rstn),
    .penable            (ctrl_penable),
    .psel               (ctrl_psel),
    .paddr              (ctrl_paddr),
    .pwrite             (ctrl_pwrite),
    .pwdata             (ctrl_pwdata),
    .prdata             (ctrl_prdata),
    .se_rst_syn         (SE_RST_SYN), 
    .cm0_clkdiv_cur        (cm0_clkdiv_cur),
    .pwr_gate_en           (pwr_gate_en),
    .clk_divider           (cm0_clkdiv),
    .se_rst_msk_ca_err_msk (ca_err_msk_int)
  );

  
  sec_chac_reg u_sec_chac_reg (
    .clk                    (aon_clk),
    .rst_n                  (aon_rstn),
    .penable                (chac_penable),
    .psel                   (chac_psel),
    .paddr                  (chac_paddr),
    .pwrite                 (chac_pwrite),
    .pwdata                 (chac_pwdata),
    .prdata                 (chac_prdata),
    .host_rst_ack           (HOST_RST_ACK),
    .soc_rst_synd           (SOC_RST_SYN), 
    .int_st0                (int_st[31:0]),
    .int_st1                (int_st[63:32]),
    .int_st2                (int_st[71:64]),
    .chs_pwr_st             (CHS_PWR_ST),
    .host_cpuwait_wen       (host_cpuwait_wen_ss),
    .entry_delay            (ENTRY_DELAY),
    .clkselect_cur          (clkselect_cur),
    .clkdiv_cur             (pll_clkdiv_cur),
    .sysplllock_st          (syspll_lock_ss),
    .host_rst_req           (HOST_RST_REQ),
    .host_cpuwait           (HOST_CPUWAIT),
    .soc_rst_req            (SOC_RST_REQ),
    .int_msk0               (int_msk0),
    .int_msk1               (int_msk1),
    .int_msk2               (int_msk2),
    .chs_pwr_req            (chs_pwr_req_i),
    .clkselect              (clkselect),
    .clkdiv                 (pll_clkdiv),
    .clkforce               (CLKFORCE)
  );


  sec_int_col #(
    .IRQCOL               (LP_IRQCOL)
  ) u_sec_int_col (
    .clk                  (aon_clk),
    .rst_n                (aon_rstn),
    .int_i                (int_i),
    .mask                 (int_mask),
    .int_st               (int_st),
    .comb_int_o           (comb_int)
  );
  
  assign int_i = {56'b0,
                            MHU5R_CIRQ,
                  MHU5S_CIRQ,
                      MHU4R_CIRQ,
                  MHU4S_CIRQ,
                          MHU3R_CIRQ,
                  MHU3S_CIRQ,
                      MHU2R_CIRQ,
                  MHU2S_CIRQ,
                    EXTIRQ};
  assign int_mask = {32'b0, int_msk2, int_msk1, int_msk0};

  
  sec_clk_ctrl u_sec_clk_ctrl (
    .secenc_refclk    (SECENCREFCLK),
    .sys_pll          (SYSPLL),
    .s32k_clk         (S32KCLK),
    .rst_n            (SEPORESETn), 
    .hintclken_clk    (SECENCHINTCLK),
    .secenc_divclkaon (aon_clk),
    .secenc_divclk    (SECENCDIVCLK),
    .secenc_clkaon    (caaon_clk),
    .secenc_clk       (SECENCCLK),
    .s32k_clk_secenc  (S32KCLK_SECENC),
    .s32k_clk_aon     (s32k_clk),
    .clkselect        (clkselect),
    .clkselect_cur    (clkselect_cur),
    .pll_clkdiv       (pll_clkdiv),
    .pll_clkdiv_cur   (pll_clkdiv_cur),
    .cm0_clkdiv       (cm0_clkdiv),
    .cm0_clkdiv_cur   (cm0_clkdiv_cur),
    .ppu_clken        (ppu_clken),
    .dftdivsel        (DFTDIVSEL),
    .dftclkselen      (DFTCLKSELEN),
    .dftclksel        (DFTCLKSEL),
    .dftdivbypass     (DFTDIVBYPASS),
    .dftcgen          (DFTCGEN),
    .dftrstdisable    (DFTRSTDISABLE[0]),
    .mbistreq         (MBISTREQ),
    .nmbistreset      (nMBISTRESET)
  );

  
  assign S32_WDOG_RST_REQ = wd_rst_req_32k_s;
  assign SOC_WD_IRQ       = wdogint_ss_int;
  assign CHS_PWR_REQ      = chs_pwr_req_i[6:1];
  assign CO_IRQ           = comb_int;
  assign PPU_IRQ          = ppu_irq_int;
  assign UART_IRQ         = uart_irq_int;
  assign HOST_FWT_IRQ_SS  = host_fwt_irq_ss_int;
  assign INT_RTT_IRQ_SS   = int_rtt_irq_ss_int;
  assign SWD_WS1_IRQ_SS   = swd_ws1_irq_ss_int;

  
  assign unused = (&uart_pwdata[31:16]) | 
                  (&int_st[127:72])     | 
                  (&wd_paddr[1:0]);
  
endmodule
