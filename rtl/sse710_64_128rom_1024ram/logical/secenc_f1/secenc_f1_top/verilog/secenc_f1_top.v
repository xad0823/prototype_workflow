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


module secenc_f1_top #(

  parameter                         MHU_HSE0_NUM_CH           = 7'd1,     
  parameter                         MHU_SEH0_NUM_CH           = 7'd1,     
  parameter                         MHU_HSE1_NUM_CH           = 7'd1,     
  parameter                         MHU_SEH1_NUM_CH           = 7'd1,     


  parameter                         MHU_SEES00_NUM_CH         = 7'd1,     
  parameter                         MHU_ES0SE0_NUM_CH         = 7'd1,     
    parameter                         MHU_SEES01_NUM_CH         = 7'd1,     
  parameter                         MHU_ES0SE1_NUM_CH         = 7'd1,     

  
  parameter                         MHU_SEES10_NUM_CH         = 7'd1,     
  parameter                         MHU_ES1SE0_NUM_CH         = 7'd1,     
    parameter                         MHU_SEES11_NUM_CH         = 7'd1,     
  parameter                         MHU_ES1SE1_NUM_CH         = 7'd1,     

  
  parameter                         AW_FIFO_DEPTH             = 2,        
  parameter                         W_FIFO_DEPTH              = 2,        
  parameter                         B_FIFO_DEPTH              = 2,        
  parameter                         AR_FIFO_DEPTH             = 2,        
  parameter                         R_FIFO_DEPTH              = 2,        
  parameter                         AW_PAYLOAD_WIDTH          = 124,      
  parameter                         W_PAYLOAD_WIDTH           = 74,       
  parameter                         B_PAYLOAD_WIDTH           = 8,        
  parameter                         AR_PAYLOAD_WIDTH          = 124,      
  parameter                         R_PAYLOAD_WIDTH           = 74,       


  parameter                         DEV_PREQ_DLY_SECENC       = 0,        
  parameter                         PCSM_PREQ_DLY_SECENC      = 0,        
  parameter                         ISO_CLKEN_DLY_CFG_SECENC  = 0,        
  parameter                         CLKEN_RST_DLY_CFG_SECENC  = 0,        
  parameter                         RST_HWSTAT_DLY_CFG_SECENC = 0,        
  parameter                         CLKEN_ISO_DLY_CFG_SECENC  = 0,        
  parameter                         ISO_RST_DLY_CFG_SECENC    = 0,        
                                                                          
  parameter                         CAAON2CA_WIDTH            = 289,      
  parameter                         CA2CAAON_WIDTH            = 300       
  
) (
  input  wire                       SECENCREFCLK,
  input  wire                       SYSPLL,
  input  wire                       SYSPLLLOCK,
  input  wire                       S32KCLK,
  input  wire                       SEPORESETn,
  input  wire                       SECENCCPUWAIT,

  input  wire                       DEBUG_APB_ASYNC_REQ,
  input  wire                [48:0] DEBUG_APB_ASYNC_REQ_PAYLOAD,
  output wire                [32:0] DEBUG_APB_ASYNC_RESP_PAYLOAD,
  output wire                       DEBUG_APB_ASYNC_ACK,

  input  wire                       DP_ABORT_PULSE_REQ,
  output wire                       DP_ABORT_PULSE_ACK,

  input  wire [3:0]                 CTI_CHA_TO_SECENC_PULSE_REQ,
  output wire [3:0]                 CTI_CHA_TO_SECENC_PULSE_ACK,
  input  wire [3:0]                 CTI_SECENC_TO_CHA_PULSE_ACK,
  output wire [3:0]                 CTI_SECENC_TO_CHA_PULSE_REQ,

  output wire                       DBGD_QREQn,
  input  wire                       DBGD_QACCEPTn,
  input  wire                       DBGD_QDENY,
  input  wire                       DBGD_QACTIVE,

  input  wire                       CDBGPWRUPREQ0,
  output wire                       CDBGPWRUPACK0,

  output wire                       SLVMUSTACCEPTREQN_ASYNC,
  output wire                       SLVCANDENYREQN_ASYNC,
  input  wire                       SLVACCEPTN_ASYNC,
  input  wire                       SLVDENY_ASYNC,
  output wire                       SI_TO_MI_WAKEUP_ASYNC,
  input  wire                       MI_TO_SI_WAKEUP_ASYNC,

  output wire                 [AW_FIFO_DEPTH-1:0]    AW_WR_PTR_ASYNC,
  input  wire                 [AW_FIFO_DEPTH-1:0]    AW_RD_PTR_ASYNC,
  output wire                 [AW_PAYLOAD_WIDTH-1:0] AW_PAYLD_ASYNC,
  output wire                 [W_FIFO_DEPTH-1:0]     W_WR_PTR_ASYNC,
  input  wire                 [W_FIFO_DEPTH-1:0]     W_RD_PTR_ASYNC,
  output wire                 [W_PAYLOAD_WIDTH-1:0]  W_PAYLD_ASYNC,
  input  wire                 [B_FIFO_DEPTH-1:0]     B_WR_PTR_ASYNC,
  output wire                 [B_FIFO_DEPTH-1:0]     B_RD_PTR_ASYNC,
  input  wire                 [B_PAYLOAD_WIDTH-1:0]  B_PAYLD_ASYNC,
  output wire                 [AR_FIFO_DEPTH-1:0]    AR_WR_PTR_ASYNC,
  input  wire                 [AR_FIFO_DEPTH-1:0]    AR_RD_PTR_ASYNC,
  output wire                 [AR_PAYLOAD_WIDTH-1:0] AR_PAYLD_ASYNC,
  input  wire                 [R_FIFO_DEPTH-1:0]     R_WR_PTR_ASYNC,
  output wire                 [R_FIFO_DEPTH-1:0]     R_RD_PTR_ASYNC,
  input  wire                 [R_PAYLOAD_WIDTH-1:0]  R_PAYLD_ASYNC,

  input  wire                       SYSC_QREQn,
  output wire                       SYSC_QACCEPTn,
  output wire                       SYSC_QDENY,
  output wire                       SYSC_QACTIVE,

  input  wire                       DBGC_QREQn,
  output wire                       DBGC_QACCEPTn,
  output wire                       DBGC_QDENY,
  output wire                       DBGC_QACTIVE,

  input  wire                       MHU_HSE0_APB_ASYNC_REQ,
  input  wire                [48:0] MHU_HSE0_APB_ASYNC_REQ_PAYLOAD,
  output wire                [32:0] MHU_HSE0_APB_ASYNC_RESP_PAYLOAD,
  output wire                       MHU_HSE0_APB_ASYNC_ACK,
  output wire [MHU_HSE0_NUM_CH-1:0] MHU_HSE0_EDGE_ASYNC_REQ,
  input  wire [MHU_HSE0_NUM_CH-1:0] MHU_HSE0_EDGE_ASYNC_ACK,
  output wire                       MHU_HSE0_RECAWAKE_ASYNC,
  input  wire                       MHU_HSE0_RECWAKEUP_ASYNC,

  output wire                       MHU_SEH0_APB_ASYNC_REQ,
  output wire                [48:0] MHU_SEH0_APB_ASYNC_REQ_PAYLOAD,
  input  wire                [32:0] MHU_SEH0_APB_ASYNC_RESP_PAYLOAD,
  input  wire                       MHU_SEH0_APB_ASYNC_ACK,
  input  wire [MHU_SEH0_NUM_CH-1:0] MHU_SEH0_EDGE_ASYNC_REQ,
  output wire [MHU_SEH0_NUM_CH-1:0] MHU_SEH0_EDGE_ASYNC_ACK,
  input  wire                       MHU_SEH0_RECAWAKE_ASYNC,
  output wire                       MHU_SEH0_RECWAKEUP_ASYNC,

  input  wire                       MHU_HSE1_APB_ASYNC_REQ,
  input  wire                [48:0] MHU_HSE1_APB_ASYNC_REQ_PAYLOAD,
  output wire                [32:0] MHU_HSE1_APB_ASYNC_RESP_PAYLOAD,
  output wire                       MHU_HSE1_APB_ASYNC_ACK,
  output wire [MHU_HSE1_NUM_CH-1:0] MHU_HSE1_EDGE_ASYNC_REQ,
  input  wire [MHU_HSE1_NUM_CH-1:0] MHU_HSE1_EDGE_ASYNC_ACK,
  output wire                       MHU_HSE1_RECAWAKE_ASYNC,
  input  wire                       MHU_HSE1_RECWAKEUP_ASYNC,

  output wire                       MHU_SEH1_APB_ASYNC_REQ,
  output wire                [48:0] MHU_SEH1_APB_ASYNC_REQ_PAYLOAD,
  input  wire                [32:0] MHU_SEH1_APB_ASYNC_RESP_PAYLOAD,
  input  wire                       MHU_SEH1_APB_ASYNC_ACK,
  input  wire [MHU_SEH1_NUM_CH-1:0] MHU_SEH1_EDGE_ASYNC_REQ,
  output wire [MHU_SEH1_NUM_CH-1:0] MHU_SEH1_EDGE_ASYNC_ACK,
  input  wire                       MHU_SEH1_RECAWAKE_ASYNC,
  output wire                       MHU_SEH1_RECWAKEUP_ASYNC,


  input  wire                                       MHU_ES0SE0_APB_ASYNC_REQ,
  input  wire                                [48:0] MHU_ES0SE0_APB_ASYNC_REQ_PAYLOAD,
  output wire                                [32:0] MHU_ES0SE0_APB_ASYNC_RESP_PAYLOAD,
  output wire                                       MHU_ES0SE0_APB_ASYNC_ACK,
  output wire [MHU_ES0SE0_NUM_CH-1:0] MHU_ES0SE0_EDGE_ASYNC_REQ,
  input  wire [MHU_ES0SE0_NUM_CH-1:0] MHU_ES0SE0_EDGE_ASYNC_ACK,
  output wire                                       MHU_ES0SE0_RECAWAKE_ASYNC,
  input  wire                                       MHU_ES0SE0_RECWAKEUP_ASYNC,

  output wire                                       MHU_SEES00_APB_ASYNC_REQ,
  output wire                                [48:0] MHU_SEES00_APB_ASYNC_REQ_PAYLOAD,
  input  wire                                [32:0] MHU_SEES00_APB_ASYNC_RESP_PAYLOAD,
  input  wire                                       MHU_SEES00_APB_ASYNC_ACK,
  input  wire [MHU_SEES00_NUM_CH-1:0] MHU_SEES00_EDGE_ASYNC_REQ,
  output wire [MHU_SEES00_NUM_CH-1:0] MHU_SEES00_EDGE_ASYNC_ACK,
  input  wire                                       MHU_SEES00_RECAWAKE_ASYNC,
  output wire                                       MHU_SEES00_RECWAKEUP_ASYNC,
   
     
  input  wire                                       MHU_ES0SE1_APB_ASYNC_REQ,
  input  wire                              [48:0]   MHU_ES0SE1_APB_ASYNC_REQ_PAYLOAD,
  output wire                              [32:0]   MHU_ES0SE1_APB_ASYNC_RESP_PAYLOAD,
  output wire                                       MHU_ES0SE1_APB_ASYNC_ACK,
  output wire [MHU_ES0SE1_NUM_CH-1:0] MHU_ES0SE1_EDGE_ASYNC_REQ,
  input  wire [MHU_ES0SE1_NUM_CH-1:0] MHU_ES0SE1_EDGE_ASYNC_ACK,
  output wire                                       MHU_ES0SE1_RECAWAKE_ASYNC,
  input  wire                                       MHU_ES0SE1_RECWAKEUP_ASYNC,

  output wire                                       MHU_SEES01_APB_ASYNC_REQ,
  output wire                [48:0]                 MHU_SEES01_APB_ASYNC_REQ_PAYLOAD,
  input  wire                [32:0]                 MHU_SEES01_APB_ASYNC_RESP_PAYLOAD,
  input  wire                                       MHU_SEES01_APB_ASYNC_ACK,
  input  wire [MHU_SEES01_NUM_CH-1:0] MHU_SEES01_EDGE_ASYNC_REQ,
  output wire [MHU_SEES01_NUM_CH-1:0] MHU_SEES01_EDGE_ASYNC_ACK,
  input  wire                                       MHU_SEES01_RECAWAKE_ASYNC,
  output wire                                       MHU_SEES01_RECWAKEUP_ASYNC,

  
  input  wire                                       MHU_ES1SE0_APB_ASYNC_REQ,
  input  wire                                [48:0] MHU_ES1SE0_APB_ASYNC_REQ_PAYLOAD,
  output wire                                [32:0] MHU_ES1SE0_APB_ASYNC_RESP_PAYLOAD,
  output wire                                       MHU_ES1SE0_APB_ASYNC_ACK,
  output wire [MHU_ES1SE0_NUM_CH-1:0] MHU_ES1SE0_EDGE_ASYNC_REQ,
  input  wire [MHU_ES1SE0_NUM_CH-1:0] MHU_ES1SE0_EDGE_ASYNC_ACK,
  output wire                                       MHU_ES1SE0_RECAWAKE_ASYNC,
  input  wire                                       MHU_ES1SE0_RECWAKEUP_ASYNC,

  output wire                                       MHU_SEES10_APB_ASYNC_REQ,
  output wire                                [48:0] MHU_SEES10_APB_ASYNC_REQ_PAYLOAD,
  input  wire                                [32:0] MHU_SEES10_APB_ASYNC_RESP_PAYLOAD,
  input  wire                                       MHU_SEES10_APB_ASYNC_ACK,
  input  wire [MHU_SEES10_NUM_CH-1:0] MHU_SEES10_EDGE_ASYNC_REQ,
  output wire [MHU_SEES10_NUM_CH-1:0] MHU_SEES10_EDGE_ASYNC_ACK,
  input  wire                                       MHU_SEES10_RECAWAKE_ASYNC,
  output wire                                       MHU_SEES10_RECWAKEUP_ASYNC,
   
     
  input  wire                                       MHU_ES1SE1_APB_ASYNC_REQ,
  input  wire                              [48:0]   MHU_ES1SE1_APB_ASYNC_REQ_PAYLOAD,
  output wire                              [32:0]   MHU_ES1SE1_APB_ASYNC_RESP_PAYLOAD,
  output wire                                       MHU_ES1SE1_APB_ASYNC_ACK,
  output wire [MHU_ES1SE1_NUM_CH-1:0] MHU_ES1SE1_EDGE_ASYNC_REQ,
  input  wire [MHU_ES1SE1_NUM_CH-1:0] MHU_ES1SE1_EDGE_ASYNC_ACK,
  output wire                                       MHU_ES1SE1_RECAWAKE_ASYNC,
  input  wire                                       MHU_ES1SE1_RECWAKEUP_ASYNC,

  output wire                                       MHU_SEES11_APB_ASYNC_REQ,
  output wire                [48:0]                 MHU_SEES11_APB_ASYNC_REQ_PAYLOAD,
  input  wire                [32:0]                 MHU_SEES11_APB_ASYNC_RESP_PAYLOAD,
  input  wire                                       MHU_SEES11_APB_ASYNC_ACK,
  input  wire [MHU_SEES11_NUM_CH-1:0] MHU_SEES11_EDGE_ASYNC_REQ,
  output wire [MHU_SEES11_NUM_CH-1:0] MHU_SEES11_EDGE_ASYNC_ACK,
  input  wire                                       MHU_SEES11_RECAWAKE_ASYNC,
  output wire                                       MHU_SEES11_RECWAKEUP_ASYNC,

  
  input  wire                       CALC,
  
  output wire               [127:0] SCB,

  input  wire                       nUARTCTS,  
  input  wire                       nUARTDCD,  
  input  wire                       nUARTDSR,  
  input  wire                       nUARTRI,   
  input  wire                       UARTRXD,   
  output wire                       UARTTXD,   
  output wire                       nUARTDTR,  
  output wire                       nUARTRTS,  
  output wire                       nUARTOut1, 
  output wire                       nUARTOut2, 

  input  wire                [63:0] EXTIRQ,       
  input  wire                       HOST_FWT_IRQ, 
  input  wire                       INT_RTT_IRQ,  
  input  wire                       SWD_WS1_IRQ,  

  input  wire                 [1:0] HOST_RST_ACK,         
  output wire                       HOST_CPUWAIT,         
  input  wire                 [5:0] CHS_PWR_ST,           
  output wire                 [5:0] CHS_PWR_REQ,          
  input  wire                 [4:0] SOC_RST_SYN,          
  input  wire                 [2:0] SE_RST_SYN,           
                              
  output wire                       SEC_WDOG_RST_REQ,  
  output wire                       S32_WDOG_RST_REQ,  
  output wire                       SW_RST_REQ,        
  output wire                       SOC_RST_REQ,       
  output wire                       HOST_RST_REQ,      
  output wire                       CAE_RST_REQ,       


  
  input  wire                       DFTDIVSEL,
  input  wire                       DFTCLKSELEN,
  input  wire                 [1:0] DFTCLKSEL,
  input  wire                       DFTDIVBYPASS,
  input  wire                 [1:0] DFTRSTDISABLE,
  input  wire                       DFTRETDISABLE,
  input  wire                       DFTISODISABLE,
  input  wire                       DFTPWRUP,
  input  wire                       DFTRAMHOLD,
  input  wire                       DFTCGEN,
  input  wire                       DFTMCPHOLD,
  input  wire                       nMBISTRESET,
  input  wire                       MBISTREQ,
  input  wire                       DFTSE,
  input  wire                       DFTTESTMODE
);

  
  localparam  [15:0] SEC_ENC_ROM_SIZE = 16'd128;
  localparam  [15:0] SEC_ENC_RAM_SIZE = 16'd1024; 

  localparam         AHB_SYNC_BRIDGE  = 1;   


  wire         soc_wd_irq;
  wire         uart_irq;
  wire         ppu_irq;
  wire         co_irq;
  wire         m0_halted;
  wire [127:0] scb_int;

  wire         aon_apb_async_req;
  wire  [55:0] aon_apb_async_req_payload;
  wire  [32:0] aon_apb_async_resp_payload;
  wire         aon_apb_async_ack;

  wire         socwd_apb_async_req;
  wire  [47:0] socwd_apb_async_req_payload;
  wire  [32:0] socwd_apb_async_resp_payload;
  wire         socwd_apb_async_ack;

  wire         mhu0_qreqn;
  wire         mhu0_qacceptn;
  wire         mhu0_qdeny;
  wire         mhu1_qreqn;
  wire         mhu1_qacceptn;
  wire         mhu1_qdeny;  
  wire         mhu2_qreqn;
  wire         mhu2_qacceptn;
  wire         mhu2_qdeny;
  wire         mhu3_qreqn;
  wire         mhu3_qacceptn;
  wire         mhu3_qdeny;
  wire         mhu4_qreqn;
  wire         mhu4_qacceptn;
  wire         mhu4_qdeny;
  wire         mhu5_qreqn;
  wire         mhu5_qacceptn;
  wire         mhu5_qdeny;
  wire         cm0_qreqn;
  wire         cm0_qacceptn;
  wire         cm0_qdeny;
  wire         cm0_qactive;
  wire         axib_qreqn;
  wire         axib_qacceptn;
  wire         axib_qdeny;
  wire         axib_qactive;
  wire         cti_qreqn;
  wire         cti_qacceptn;
  wire         cti_qdeny;
  wire         cti_qactive;

  wire         socwd_adb_qreqn;
  wire         socwd_adb_qacceptn;
  wire         socwd_adb_qdeny;
  wire         socwd_adb_qactive;
  
  wire         aon_adb_qreqn;
  wire         aon_adb_qacceptn;
  wire         aon_adb_qdeny;
  wire         aon_adb_qactive;  

  wire         secenc_clk;
  wire         secencdiv_clk;
  wire         secenchint_clk;
  wire         s32kclk_secenc;

  wire         secenc_poresetn;
  wire         secenc_warmresetn;

  wire  [CAAON2CA_WIDTH-1:0] caaon2ca;
  wire  [CA2CAAON_WIDTH-1:0] ca2caaon;

  wire         host_fwt_irq_ss;
  wire         int_rtt_irq_ss;
  wire         swd_ws1_irq_ss;

  wire         mhu2r_cirq;
  wire         mhu2s_cirq;
  wire         mhu3r_cirq;
  wire         mhu3s_cirq;
  wire         mhu4r_cirq;
  wire         mhu4s_cirq;
  wire         mhu5r_cirq;
  wire         mhu5s_cirq;

  wire         cae;
  wire         ca_err_msk;

  wire         clkforce;
  wire [7:0]   entry_delay;

  
  secenc_f1_sepd #(
    .SEC_ENC_ROM_SIZE                 (SEC_ENC_ROM_SIZE),
    .SEC_ENC_RAM_SIZE                 (SEC_ENC_RAM_SIZE),
    .MHU_HSE0_NUM_CH                  (MHU_HSE0_NUM_CH),
    .MHU_SEH0_NUM_CH                  (MHU_SEH0_NUM_CH),
    .MHU_HSE1_NUM_CH                  (MHU_HSE1_NUM_CH),
    .MHU_SEH1_NUM_CH                  (MHU_SEH1_NUM_CH),
    .MHU_SEES00_NUM_CH  (MHU_SEES00_NUM_CH),
    .MHU_ES0SE0_NUM_CH  (MHU_ES0SE0_NUM_CH),
      .MHU_SEES01_NUM_CH  (MHU_SEES01_NUM_CH),
    .MHU_ES0SE1_NUM_CH  (MHU_ES0SE1_NUM_CH),
      .MHU_SEES10_NUM_CH  (MHU_SEES10_NUM_CH),
    .MHU_ES1SE0_NUM_CH  (MHU_ES1SE0_NUM_CH),
      .MHU_SEES11_NUM_CH  (MHU_SEES11_NUM_CH),
    .MHU_ES1SE1_NUM_CH  (MHU_ES1SE1_NUM_CH),
      .AW_FIFO_DEPTH                    (AW_FIFO_DEPTH),
    .W_FIFO_DEPTH                     (W_FIFO_DEPTH),
    .B_FIFO_DEPTH                     (B_FIFO_DEPTH),
    .AR_FIFO_DEPTH                    (AR_FIFO_DEPTH),
    .R_FIFO_DEPTH                     (R_FIFO_DEPTH),
    .AW_PAYLOAD_WIDTH                 (AW_PAYLOAD_WIDTH),
    .W_PAYLOAD_WIDTH                  (W_PAYLOAD_WIDTH),
    .B_PAYLOAD_WIDTH                  (B_PAYLOAD_WIDTH),
    .AR_PAYLOAD_WIDTH                 (AR_PAYLOAD_WIDTH),
    .R_PAYLOAD_WIDTH                  (R_PAYLOAD_WIDTH),
    .CAAON2CA_WIDTH                   (CAAON2CA_WIDTH),
    .CA2CAAON_WIDTH                   (CA2CAAON_WIDTH),
    .AHB_SYNC_BRIDGE                  (AHB_SYNC_BRIDGE)
  ) u_secenc_f1_sepd (
    .SECENCCLK                           (secenc_clk),
    .SECENCDIVCLK                        (secencdiv_clk),
    .SECENCHINTCLK                       (secenchint_clk),
    .S32KCLK_SECENC                      (s32kclk_secenc),
    .SECENCPORESETn                      (secenc_poresetn),
    .SECENCWARMRESETn                    (secenc_warmresetn),
    .SECENCCPUWAIT                       (SECENCCPUWAIT),
    .M0_HALTED                           (m0_halted),
    .CDBGPWRUPREQ0                       (CDBGPWRUPREQ0),
    .DEBUG_APB_ASYNC_REQ                 (DEBUG_APB_ASYNC_REQ),
    .DEBUG_APB_ASYNC_REQ_PAYLOAD         (DEBUG_APB_ASYNC_REQ_PAYLOAD),
    .DEBUG_APB_ASYNC_RESP_PAYLOAD        (DEBUG_APB_ASYNC_RESP_PAYLOAD),
    .DEBUG_APB_ASYNC_ACK                 (DEBUG_APB_ASYNC_ACK),
    .DP_ABORT_PULSE_REQ                  (DP_ABORT_PULSE_REQ),
    .DP_ABORT_PULSE_ACK                  (DP_ABORT_PULSE_ACK),
    .CTI_CHA_TO_SECENC_PULSE_REQ         (CTI_CHA_TO_SECENC_PULSE_REQ),
    .CTI_CHA_TO_SECENC_PULSE_ACK         (CTI_CHA_TO_SECENC_PULSE_ACK),
    .CTI_SECENC_TO_CHA_PULSE_ACK         (CTI_SECENC_TO_CHA_PULSE_ACK),
    .CTI_SECENC_TO_CHA_PULSE_REQ         (CTI_SECENC_TO_CHA_PULSE_REQ),
    .SLVMUSTACCEPTREQN_ASYNC             (SLVMUSTACCEPTREQN_ASYNC),
    .SLVCANDENYREQN_ASYNC                (SLVCANDENYREQN_ASYNC),
    .SLVACCEPTN_ASYNC                    (SLVACCEPTN_ASYNC),
    .SLVDENY_ASYNC                       (SLVDENY_ASYNC),
    .SI_TO_MI_WAKEUP_ASYNC               (SI_TO_MI_WAKEUP_ASYNC),
    .MI_TO_SI_WAKEUP_ASYNC               (MI_TO_SI_WAKEUP_ASYNC),
    .AW_WR_PTR_ASYNC                     (AW_WR_PTR_ASYNC),
    .AW_RD_PTR_ASYNC                     (AW_RD_PTR_ASYNC),
    .AW_PAYLD_ASYNC                      (AW_PAYLD_ASYNC),
    .W_WR_PTR_ASYNC                      (W_WR_PTR_ASYNC),
    .W_RD_PTR_ASYNC                      (W_RD_PTR_ASYNC),
    .W_PAYLD_ASYNC                       (W_PAYLD_ASYNC),
    .B_WR_PTR_ASYNC                      (B_WR_PTR_ASYNC),
    .B_RD_PTR_ASYNC                      (B_RD_PTR_ASYNC),
    .B_PAYLD_ASYNC                       (B_PAYLD_ASYNC),
    .AR_WR_PTR_ASYNC                     (AR_WR_PTR_ASYNC),
    .AR_RD_PTR_ASYNC                     (AR_RD_PTR_ASYNC),
    .AR_PAYLD_ASYNC                      (AR_PAYLD_ASYNC),
    .R_WR_PTR_ASYNC                      (R_WR_PTR_ASYNC),
    .R_RD_PTR_ASYNC                      (R_RD_PTR_ASYNC),
    .R_PAYLD_ASYNC                       (R_PAYLD_ASYNC),  
    .MHU_HSE0_APB_ASYNC_REQ              (MHU_HSE0_APB_ASYNC_REQ),
    .MHU_HSE0_APB_ASYNC_REQ_PAYLOAD      (MHU_HSE0_APB_ASYNC_REQ_PAYLOAD),
    .MHU_HSE0_APB_ASYNC_RESP_PAYLOAD     (MHU_HSE0_APB_ASYNC_RESP_PAYLOAD),
    .MHU_HSE0_APB_ASYNC_ACK              (MHU_HSE0_APB_ASYNC_ACK),
    .MHU_HSE0_RECAWAKE_ASYNC             (MHU_HSE0_RECAWAKE_ASYNC),
    .MHU_HSE0_RECWAKEUP_ASYNC            (MHU_HSE0_RECWAKEUP_ASYNC),
    .MHU_HSE0_EDGE_ASYNC_REQ             (MHU_HSE0_EDGE_ASYNC_REQ),
    .MHU_HSE0_EDGE_ASYNC_ACK             (MHU_HSE0_EDGE_ASYNC_ACK),
    .MHU_SEH0_APB_ASYNC_REQ              (MHU_SEH0_APB_ASYNC_REQ),
    .MHU_SEH0_APB_ASYNC_REQ_PAYLOAD      (MHU_SEH0_APB_ASYNC_REQ_PAYLOAD),
    .MHU_SEH0_APB_ASYNC_RESP_PAYLOAD     (MHU_SEH0_APB_ASYNC_RESP_PAYLOAD),
    .MHU_SEH0_APB_ASYNC_ACK              (MHU_SEH0_APB_ASYNC_ACK),
    .MHU_SEH0_RECAWAKE_ASYNC             (MHU_SEH0_RECAWAKE_ASYNC),
    .MHU_SEH0_RECWAKEUP_ASYNC            (MHU_SEH0_RECWAKEUP_ASYNC),
    .MHU_SEH0_EDGE_ASYNC_REQ             (MHU_SEH0_EDGE_ASYNC_REQ),
    .MHU_SEH0_EDGE_ASYNC_ACK             (MHU_SEH0_EDGE_ASYNC_ACK),
    .MHU_HSE1_APB_ASYNC_REQ              (MHU_HSE1_APB_ASYNC_REQ),
    .MHU_HSE1_APB_ASYNC_REQ_PAYLOAD      (MHU_HSE1_APB_ASYNC_REQ_PAYLOAD),
    .MHU_HSE1_APB_ASYNC_RESP_PAYLOAD     (MHU_HSE1_APB_ASYNC_RESP_PAYLOAD),
    .MHU_HSE1_APB_ASYNC_ACK              (MHU_HSE1_APB_ASYNC_ACK),
    .MHU_HSE1_RECAWAKE_ASYNC             (MHU_HSE1_RECAWAKE_ASYNC),
    .MHU_HSE1_RECWAKEUP_ASYNC            (MHU_HSE1_RECWAKEUP_ASYNC),
    .MHU_HSE1_EDGE_ASYNC_REQ             (MHU_HSE1_EDGE_ASYNC_REQ),
    .MHU_HSE1_EDGE_ASYNC_ACK             (MHU_HSE1_EDGE_ASYNC_ACK),
    .MHU_SEH1_APB_ASYNC_REQ              (MHU_SEH1_APB_ASYNC_REQ),
    .MHU_SEH1_APB_ASYNC_REQ_PAYLOAD      (MHU_SEH1_APB_ASYNC_REQ_PAYLOAD),
    .MHU_SEH1_APB_ASYNC_RESP_PAYLOAD     (MHU_SEH1_APB_ASYNC_RESP_PAYLOAD),
    .MHU_SEH1_APB_ASYNC_ACK              (MHU_SEH1_APB_ASYNC_ACK),
    .MHU_SEH1_RECAWAKE_ASYNC             (MHU_SEH1_RECAWAKE_ASYNC),
    .MHU_SEH1_RECWAKEUP_ASYNC            (MHU_SEH1_RECWAKEUP_ASYNC),
    .MHU_SEH1_EDGE_ASYNC_REQ             (MHU_SEH1_EDGE_ASYNC_REQ),
    .MHU_SEH1_EDGE_ASYNC_ACK             (MHU_SEH1_EDGE_ASYNC_ACK),
    .MHU_ES0SE0_APB_ASYNC_REQ            (MHU_ES0SE0_APB_ASYNC_REQ),
    .MHU_ES0SE0_APB_ASYNC_REQ_PAYLOAD    (MHU_ES0SE0_APB_ASYNC_REQ_PAYLOAD),
    .MHU_ES0SE0_APB_ASYNC_RESP_PAYLOAD   (MHU_ES0SE0_APB_ASYNC_RESP_PAYLOAD),
    .MHU_ES0SE0_APB_ASYNC_ACK            (MHU_ES0SE0_APB_ASYNC_ACK),
    .MHU_ES0SE0_RECAWAKE_ASYNC           (MHU_ES0SE0_RECAWAKE_ASYNC),
    .MHU_ES0SE0_RECWAKEUP_ASYNC          (MHU_ES0SE0_RECWAKEUP_ASYNC),
    .MHU_ES0SE0_EDGE_ASYNC_REQ           (MHU_ES0SE0_EDGE_ASYNC_REQ),
    .MHU_ES0SE0_EDGE_ASYNC_ACK           (MHU_ES0SE0_EDGE_ASYNC_ACK),
    .MHU_SEES00_APB_ASYNC_REQ            (MHU_SEES00_APB_ASYNC_REQ),
    .MHU_SEES00_APB_ASYNC_REQ_PAYLOAD    (MHU_SEES00_APB_ASYNC_REQ_PAYLOAD),
    .MHU_SEES00_APB_ASYNC_RESP_PAYLOAD   (MHU_SEES00_APB_ASYNC_RESP_PAYLOAD),
    .MHU_SEES00_APB_ASYNC_ACK            (MHU_SEES00_APB_ASYNC_ACK),
    .MHU_SEES00_RECAWAKE_ASYNC           (MHU_SEES00_RECAWAKE_ASYNC),
    .MHU_SEES00_RECWAKEUP_ASYNC          (MHU_SEES00_RECWAKEUP_ASYNC),
    .MHU_SEES00_EDGE_ASYNC_REQ           (MHU_SEES00_EDGE_ASYNC_REQ),
    .MHU_SEES00_EDGE_ASYNC_ACK           (MHU_SEES00_EDGE_ASYNC_ACK),
      .MHU_ES0SE1_APB_ASYNC_REQ            (MHU_ES0SE1_APB_ASYNC_REQ),
    .MHU_ES0SE1_APB_ASYNC_REQ_PAYLOAD    (MHU_ES0SE1_APB_ASYNC_REQ_PAYLOAD),
    .MHU_ES0SE1_APB_ASYNC_RESP_PAYLOAD   (MHU_ES0SE1_APB_ASYNC_RESP_PAYLOAD),
    .MHU_ES0SE1_APB_ASYNC_ACK            (MHU_ES0SE1_APB_ASYNC_ACK),
    .MHU_ES0SE1_RECAWAKE_ASYNC           (MHU_ES0SE1_RECAWAKE_ASYNC),
    .MHU_ES0SE1_RECWAKEUP_ASYNC          (MHU_ES0SE1_RECWAKEUP_ASYNC),
    .MHU_ES0SE1_EDGE_ASYNC_REQ           (MHU_ES0SE1_EDGE_ASYNC_REQ),
    .MHU_ES0SE1_EDGE_ASYNC_ACK           (MHU_ES0SE1_EDGE_ASYNC_ACK),
    .MHU_SEES01_APB_ASYNC_REQ            (MHU_SEES01_APB_ASYNC_REQ),
    .MHU_SEES01_APB_ASYNC_REQ_PAYLOAD    (MHU_SEES01_APB_ASYNC_REQ_PAYLOAD),
    .MHU_SEES01_APB_ASYNC_RESP_PAYLOAD   (MHU_SEES01_APB_ASYNC_RESP_PAYLOAD),
    .MHU_SEES01_APB_ASYNC_ACK            (MHU_SEES01_APB_ASYNC_ACK),
    .MHU_SEES01_RECAWAKE_ASYNC           (MHU_SEES01_RECAWAKE_ASYNC),
    .MHU_SEES01_RECWAKEUP_ASYNC          (MHU_SEES01_RECWAKEUP_ASYNC),
    .MHU_SEES01_EDGE_ASYNC_REQ           (MHU_SEES01_EDGE_ASYNC_REQ),
    .MHU_SEES01_EDGE_ASYNC_ACK           (MHU_SEES01_EDGE_ASYNC_ACK),
      .MHU_ES1SE0_APB_ASYNC_REQ            (MHU_ES1SE0_APB_ASYNC_REQ),
    .MHU_ES1SE0_APB_ASYNC_REQ_PAYLOAD    (MHU_ES1SE0_APB_ASYNC_REQ_PAYLOAD),
    .MHU_ES1SE0_APB_ASYNC_RESP_PAYLOAD   (MHU_ES1SE0_APB_ASYNC_RESP_PAYLOAD),
    .MHU_ES1SE0_APB_ASYNC_ACK            (MHU_ES1SE0_APB_ASYNC_ACK),
    .MHU_ES1SE0_RECAWAKE_ASYNC           (MHU_ES1SE0_RECAWAKE_ASYNC),
    .MHU_ES1SE0_RECWAKEUP_ASYNC          (MHU_ES1SE0_RECWAKEUP_ASYNC),
    .MHU_ES1SE0_EDGE_ASYNC_REQ           (MHU_ES1SE0_EDGE_ASYNC_REQ),
    .MHU_ES1SE0_EDGE_ASYNC_ACK           (MHU_ES1SE0_EDGE_ASYNC_ACK),
    .MHU_SEES10_APB_ASYNC_REQ            (MHU_SEES10_APB_ASYNC_REQ),
    .MHU_SEES10_APB_ASYNC_REQ_PAYLOAD    (MHU_SEES10_APB_ASYNC_REQ_PAYLOAD),
    .MHU_SEES10_APB_ASYNC_RESP_PAYLOAD   (MHU_SEES10_APB_ASYNC_RESP_PAYLOAD),
    .MHU_SEES10_APB_ASYNC_ACK            (MHU_SEES10_APB_ASYNC_ACK),
    .MHU_SEES10_RECAWAKE_ASYNC           (MHU_SEES10_RECAWAKE_ASYNC),
    .MHU_SEES10_RECWAKEUP_ASYNC          (MHU_SEES10_RECWAKEUP_ASYNC),
    .MHU_SEES10_EDGE_ASYNC_REQ           (MHU_SEES10_EDGE_ASYNC_REQ),
    .MHU_SEES10_EDGE_ASYNC_ACK           (MHU_SEES10_EDGE_ASYNC_ACK),
      .MHU_ES1SE1_APB_ASYNC_REQ            (MHU_ES1SE1_APB_ASYNC_REQ),
    .MHU_ES1SE1_APB_ASYNC_REQ_PAYLOAD    (MHU_ES1SE1_APB_ASYNC_REQ_PAYLOAD),
    .MHU_ES1SE1_APB_ASYNC_RESP_PAYLOAD   (MHU_ES1SE1_APB_ASYNC_RESP_PAYLOAD),
    .MHU_ES1SE1_APB_ASYNC_ACK            (MHU_ES1SE1_APB_ASYNC_ACK),
    .MHU_ES1SE1_RECAWAKE_ASYNC           (MHU_ES1SE1_RECAWAKE_ASYNC),
    .MHU_ES1SE1_RECWAKEUP_ASYNC          (MHU_ES1SE1_RECWAKEUP_ASYNC),
    .MHU_ES1SE1_EDGE_ASYNC_REQ           (MHU_ES1SE1_EDGE_ASYNC_REQ),
    .MHU_ES1SE1_EDGE_ASYNC_ACK           (MHU_ES1SE1_EDGE_ASYNC_ACK),
    .MHU_SEES11_APB_ASYNC_REQ            (MHU_SEES11_APB_ASYNC_REQ),
    .MHU_SEES11_APB_ASYNC_REQ_PAYLOAD    (MHU_SEES11_APB_ASYNC_REQ_PAYLOAD),
    .MHU_SEES11_APB_ASYNC_RESP_PAYLOAD   (MHU_SEES11_APB_ASYNC_RESP_PAYLOAD),
    .MHU_SEES11_APB_ASYNC_ACK            (MHU_SEES11_APB_ASYNC_ACK),
    .MHU_SEES11_RECAWAKE_ASYNC           (MHU_SEES11_RECAWAKE_ASYNC),
    .MHU_SEES11_RECWAKEUP_ASYNC          (MHU_SEES11_RECWAKEUP_ASYNC),
    .MHU_SEES11_EDGE_ASYNC_REQ           (MHU_SEES11_EDGE_ASYNC_REQ),
    .MHU_SEES11_EDGE_ASYNC_ACK           (MHU_SEES11_EDGE_ASYNC_ACK),
      .SOC_WD_IRQ                          (soc_wd_irq),
    .UART_IRQ                            (uart_irq),
    .PPU_IRQ                             (ppu_irq),
    .CO_IRQ                              (co_irq),
    .HOST_FWT_IRQ                        (host_fwt_irq_ss),
    .INT_RTT_IRQ                         (int_rtt_irq_ss),
    .SWD_WS1_IRQ                         (swd_ws1_irq_ss),
    
    .MHU2R_CIRQ        (mhu2r_cirq),
    .MHU2S_CIRQ        (mhu2s_cirq),
      .MHU3R_CIRQ        (mhu3r_cirq),
    .MHU3S_CIRQ        (mhu3s_cirq),
      
    .MHU4R_CIRQ        (mhu4r_cirq),
    .MHU4S_CIRQ        (mhu4s_cirq),
      .MHU5R_CIRQ        (mhu5r_cirq),
    .MHU5S_CIRQ        (mhu5s_cirq),
      .AON_APB_ASYNC_REQ                   (aon_apb_async_req),
    .AON_APB_ASYNC_REQ_PAYLOAD           (aon_apb_async_req_payload),
    .AON_APB_ASYNC_RESP_PAYLOAD          (aon_apb_async_resp_payload),
    .AON_APB_ASYNC_ACK                   (aon_apb_async_ack),
    .SOCWD_APB_ASYNC_REQ                 (socwd_apb_async_req),
    .SOCWD_APB_ASYNC_REQ_PAYLOAD         (socwd_apb_async_req_payload),
    .SOCWD_APB_ASYNC_RESP_PAYLOAD        (socwd_apb_async_resp_payload),
    .SOCWD_APB_ASYNC_ACK                 (socwd_apb_async_ack),
    .MHU0_QREQn                          (mhu0_qreqn),
    .MHU0_QACCEPTn                       (mhu0_qacceptn),
    .MHU0_QDENY                          (mhu0_qdeny),
    .MHU1_QREQn                          (mhu1_qreqn),
    .MHU1_QACCEPTn                       (mhu1_qacceptn),
    .MHU1_QDENY                          (mhu1_qdeny),
 
    .MHU2_QREQn        (mhu2_qreqn),
    .MHU2_QACCEPTn     (mhu2_qacceptn),
    .MHU2_QDENY        (mhu2_qdeny),
      .MHU3_QREQn        (mhu3_qreqn),
    .MHU3_QACCEPTn     (mhu3_qacceptn),
    .MHU3_QDENY        (mhu3_qdeny),
   
    .MHU4_QREQn        (mhu4_qreqn),
    .MHU4_QACCEPTn     (mhu4_qacceptn),
    .MHU4_QDENY        (mhu4_qdeny),
      .MHU5_QREQn        (mhu5_qreqn),
    .MHU5_QACCEPTn     (mhu5_qacceptn),
    .MHU5_QDENY        (mhu5_qdeny),
      .CTI_QREQn                           (cti_qreqn),
    .CTI_QACCEPTn                        (cti_qacceptn),
    .CTI_QDENY                           (cti_qdeny),
    .CTI_QACTIVE                         (cti_qactive),
    .CM0_QREQn                           (cm0_qreqn),
    .CM0_QACCEPTn                        (cm0_qacceptn),
    .CM0_QDENY                           (cm0_qdeny),
    .CM0_QACTIVE                         (cm0_qactive),
    .AXIB_QREQn                          (axib_qreqn),
    .AXIB_QACCEPTn                       (axib_qacceptn),
    .AXIB_QDENY                          (axib_qdeny),
    .AXIB_QACTIVE                        (axib_qactive),
    .SOCWD_ADB_QREQn                     (socwd_adb_qreqn),
    .SOCWD_ADB_QACCEPTn                  (socwd_adb_qacceptn),
    .SOCWD_ADB_QDENY                     (socwd_adb_qdeny),
    .SOCWD_ADB_QACTIVE                   (socwd_adb_qactive),
    .AON_ADB_QREQn                       (aon_adb_qreqn),
    .AON_ADB_QACCEPTn                    (aon_adb_qacceptn),
    .AON_ADB_QDENY                       (aon_adb_qdeny),
    .AON_ADB_QACTIVE                     (aon_adb_qactive),
    .WDOG_RST_REQ                        (SEC_WDOG_RST_REQ),
    .SW_RST_REQ                          (SW_RST_REQ),
    .DBGEN                               (scb_int[2]), 
    .NIDEN                               (scb_int[3]), 
    .CHEN                                (scb_int[4]),
    .FIREWALL_BYPASS                     (scb_int[36]),
    .CAAON2CA                            (caaon2ca),
    .CA2CAAON                            (ca2caaon),
    .CAE                                 (cae),
    .CA_ERR_MSK                          (ca_err_msk),
    .CLKFORCE                            (clkforce),
    .ENTRY_DELAY                         (entry_delay),
    .DFTRSTDISABLE                       (DFTRSTDISABLE),
    .DFTSE                               (DFTSE),
    .DFTTESTMODE                         (DFTTESTMODE),
    .DFTRAMHOLD                          (DFTRAMHOLD),
    .DFTCGEN                             (DFTCGEN),
    .DFTMCPHOLD                          (DFTMCPHOLD),
    .MBISTREQ                            (MBISTREQ)
  );

  
  secenc_f1_aon #(
    .SEC_ENC_ROM_SIZE             (SEC_ENC_ROM_SIZE),
    .SEC_ENC_RAM_SIZE             (SEC_ENC_RAM_SIZE),
    .CAAON2CA_WIDTH               (CAAON2CA_WIDTH),
    .CA2CAAON_WIDTH               (CA2CAAON_WIDTH),
    .DEV_PREQ_DLY_SECENC          (DEV_PREQ_DLY_SECENC),
    .PCSM_PREQ_DLY_SECENC         (PCSM_PREQ_DLY_SECENC),
    .ISO_CLKEN_DLY_CFG_SECENC     (ISO_CLKEN_DLY_CFG_SECENC),
    .CLKEN_RST_DLY_CFG_SECENC     (CLKEN_RST_DLY_CFG_SECENC),
    .RST_HWSTAT_DLY_CFG_SECENC    (RST_HWSTAT_DLY_CFG_SECENC),
    .CLKEN_ISO_DLY_CFG_SECENC     (CLKEN_ISO_DLY_CFG_SECENC),
    .ISO_RST_DLY_CFG_SECENC       (ISO_RST_DLY_CFG_SECENC)
  ) u_secenc_f1_aon (
    .SECENCREFCLK                 (SECENCREFCLK),
    .SYSPLL                       (SYSPLL),
    .SYSPLLLOCK                   (SYSPLLLOCK),
    .S32KCLK                      (S32KCLK),
    .SEPORESETn                   (SEPORESETn),
    .SECENCCLK                    (secenc_clk),
    .SECENCDIVCLK                 (secencdiv_clk),
    .SECENCHINTCLK                (secenchint_clk),
    .S32KCLK_SECENC               (s32kclk_secenc),
    .SECENCPORESETn               (secenc_poresetn),
    .SECENCWARMRESETn             (secenc_warmresetn),
    .nUARTCTS                     (nUARTCTS),
    .nUARTDCD                     (nUARTDCD),
    .nUARTDSR                     (nUARTDSR),
    .nUARTRI                      (nUARTRI),
    .UARTRXD                      (UARTRXD),
    .UARTTXD                      (UARTTXD),
    .nUARTDTR                     (nUARTDTR),
    .nUARTRTS                     (nUARTRTS),
    .nUARTOut1                    (nUARTOut1),
    .nUARTOut2                    (nUARTOut2),
    .EXTIRQ                       (EXTIRQ),
    .SOC_WD_IRQ                   (soc_wd_irq),
    .UART_IRQ                     (uart_irq),
    .PPU_IRQ                      (ppu_irq),
    .CO_IRQ                       (co_irq),
 
    .MHU2R_CIRQ (mhu2r_cirq),
    .MHU2S_CIRQ (mhu2s_cirq),
      .MHU3R_CIRQ (mhu3r_cirq),
    .MHU3S_CIRQ (mhu3s_cirq),
   
    .MHU4R_CIRQ (mhu4r_cirq),
    .MHU4S_CIRQ (mhu4s_cirq),
      .MHU5R_CIRQ (mhu5r_cirq),
    .MHU5S_CIRQ (mhu5s_cirq),
      .CALC                         (CALC),
    .SCB                          (scb_int),
    .HOST_RST_ACK                 (HOST_RST_ACK),
    .HOST_CPUWAIT                 (HOST_CPUWAIT),
    .CHS_PWR_ST                   (CHS_PWR_ST),
    .CHS_PWR_REQ                  (CHS_PWR_REQ),
    .SOC_RST_SYN                  (SOC_RST_SYN),
    .SE_RST_SYN                   (SE_RST_SYN),
    .S32_WDOG_RST_REQ             (S32_WDOG_RST_REQ),
    .SOC_RST_REQ                  (SOC_RST_REQ),
    .HOST_RST_REQ                 (HOST_RST_REQ),
    .CAE_RST_REQ                  (CAE_RST_REQ),
    .HOST_FWT_IRQ                 (HOST_FWT_IRQ),
    .INT_RTT_IRQ                  (INT_RTT_IRQ),
    .SWD_WS1_IRQ                  (SWD_WS1_IRQ),
    .HOST_FWT_IRQ_SS              (host_fwt_irq_ss),
    .INT_RTT_IRQ_SS               (int_rtt_irq_ss),
    .SWD_WS1_IRQ_SS               (swd_ws1_irq_ss),
    .AON_APB_ASYNC_REQ            (aon_apb_async_req),
    .AON_APB_ASYNC_REQ_PAYLOAD    (aon_apb_async_req_payload),
    .AON_APB_ASYNC_RESP_PAYLOAD   (aon_apb_async_resp_payload),
    .AON_APB_ASYNC_ACK            (aon_apb_async_ack),
    .SOCWD_APB_ASYNC_REQ          (socwd_apb_async_req),
    .SOCWD_APB_ASYNC_REQ_PAYLOAD  (socwd_apb_async_req_payload),
    .SOCWD_APB_ASYNC_RESP_PAYLOAD (socwd_apb_async_resp_payload),
    .SOCWD_APB_ASYNC_ACK          (socwd_apb_async_ack),
    .DBGD_QREQn                   (DBGD_QREQn),
    .DBGD_QACCEPTn                (DBGD_QACCEPTn),
    .DBGD_QDENY                   (DBGD_QDENY),
    .DBGD_QACTIVE                 (DBGD_QACTIVE),
    .MHU0_QREQn                   (mhu0_qreqn),
    .MHU0_QACCEPTn                (mhu0_qacceptn),
    .MHU0_QDENY                   (mhu0_qdeny),
    .MHU1_QREQn                   (mhu1_qreqn),
    .MHU1_QACCEPTn                (mhu1_qacceptn),
    .MHU1_QDENY                   (mhu1_qdeny),
 
    .MHU2_QREQn    (mhu2_qreqn),
    .MHU2_QACCEPTn (mhu2_qacceptn),
    .MHU2_QDENY    (mhu2_qdeny),
      .MHU3_QREQn    (mhu3_qreqn),
    .MHU3_QACCEPTn (mhu3_qacceptn),
    .MHU3_QDENY    (mhu3_qdeny),
   
    .MHU4_QREQn    (mhu4_qreqn),
    .MHU4_QACCEPTn (mhu4_qacceptn),
    .MHU4_QDENY    (mhu4_qdeny),
      .MHU5_QREQn    (mhu5_qreqn),
    .MHU5_QACCEPTn (mhu5_qacceptn),
    .MHU5_QDENY    (mhu5_qdeny),
      .CM0_QREQn                    (cm0_qreqn),
    .CM0_QACCEPTn                 (cm0_qacceptn),
    .CM0_QDENY                    (cm0_qdeny),
    .CM0_QACTIVE                  (cm0_qactive),
    .AXIB_QREQn                   (axib_qreqn),
    .AXIB_QACCEPTn                (axib_qacceptn),
    .AXIB_QDENY                   (axib_qdeny),
    .AXIB_QACTIVE                 (axib_qactive),
    .SOCWD_ADB_QREQn              (socwd_adb_qreqn),
    .SOCWD_ADB_QACCEPTn           (socwd_adb_qacceptn),
    .SOCWD_ADB_QDENY              (socwd_adb_qdeny),
    .SOCWD_ADB_QACTIVE            (socwd_adb_qactive),
    .AON_ADB_QREQn                (aon_adb_qreqn),
    .AON_ADB_QACCEPTn             (aon_adb_qacceptn),
    .AON_ADB_QDENY                (aon_adb_qdeny),
    .AON_ADB_QACTIVE              (aon_adb_qactive),
    .SYSC_QREQn                   (SYSC_QREQn),
    .SYSC_QACCEPTn                (SYSC_QACCEPTn),
    .SYSC_QDENY                   (SYSC_QDENY),
    .SYSC_QACTIVE                 (SYSC_QACTIVE),
    .DBGC_QREQn                   (DBGC_QREQn),
    .DBGC_QACCEPTn                (DBGC_QACCEPTn),
    .DBGC_QDENY                   (DBGC_QDENY),
    .DBGC_QACTIVE                 (DBGC_QACTIVE),
    .CTI_QREQn                    (cti_qreqn),
    .CTI_QACCEPTn                 (cti_qacceptn),
    .CTI_QDENY                    (cti_qdeny),
    .CTI_QACTIVE                  (cti_qactive),
    .MHU_HSE0_RECWAKEUP_ASYNC     (MHU_HSE0_RECWAKEUP_ASYNC),
    .MHU_HSE1_RECWAKEUP_ASYNC     (MHU_HSE1_RECWAKEUP_ASYNC),
 
    .MHU_ES0SE0_RECWAKEUP_ASYNC   (MHU_ES0SE0_RECWAKEUP_ASYNC),
      .MHU_ES0SE1_RECWAKEUP_ASYNC   (MHU_ES0SE1_RECWAKEUP_ASYNC),
   
    .MHU_ES1SE0_RECWAKEUP_ASYNC   (MHU_ES1SE0_RECWAKEUP_ASYNC),
      .MHU_ES1SE1_RECWAKEUP_ASYNC   (MHU_ES1SE1_RECWAKEUP_ASYNC),
      .CDBGPWRUPREQ0                (CDBGPWRUPREQ0),
    .CDBGPWRUPACK0                (CDBGPWRUPACK0),
    .CLKFORCE                     (clkforce),
    .ENTRY_DELAY                  (entry_delay),
    .M0_HALTED                    (m0_halted),
    .CAAON2CA                     (caaon2ca),
    .CA2CAAON                     (ca2caaon),
    .CAE                          (cae),
    .CA_ERR_MSK                   (ca_err_msk),
    .DFTDIVSEL                    (DFTDIVSEL),
    .DFTCLKSELEN                  (DFTCLKSELEN),
    .DFTCLKSEL                    (DFTCLKSEL),
    .DFTDIVBYPASS                 (DFTDIVBYPASS),
    .DFTRSTDISABLE                (DFTRSTDISABLE),
    .DFTISODISABLE                (DFTISODISABLE),
    .DFTPWRUP                     (DFTPWRUP),
    .DFTRETDISABLE                (DFTRETDISABLE),
    .DFTCGEN                      (DFTCGEN),
    .nMBISTRESET                  (nMBISTRESET),
    .MBISTREQ                     (MBISTREQ),
    .DFTSE                        (DFTSE),
    .DFTTESTMODE                  (DFTTESTMODE)
  );

  assign SCB           = scb_int;
endmodule
