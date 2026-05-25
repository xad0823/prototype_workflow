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


module secenc_f1_sepd #(

  parameter                  [15:0] SEC_ENC_ROM_SIZE   = 16'd32,  
  parameter                  [15:0] SEC_ENC_RAM_SIZE   = 16'd128, 

  parameter                         MHU_HSE0_NUM_CH    = 7'd1,    
  parameter                         MHU_SEH0_NUM_CH    = 7'd1,    
  parameter                         MHU_HSE1_NUM_CH    = 7'd1,    
  parameter                         MHU_SEH1_NUM_CH    = 7'd1,    


  parameter                         MHU_SEES00_NUM_CH         = 7'd1,     
  parameter                         MHU_ES0SE0_NUM_CH         = 7'd1,     
    parameter                         MHU_SEES01_NUM_CH         = 7'd1,     
  parameter                         MHU_ES0SE1_NUM_CH         = 7'd1,     
  
  
  parameter                         MHU_SEES10_NUM_CH         = 7'd1,     
  parameter                         MHU_ES1SE0_NUM_CH         = 7'd1,     
    parameter                         MHU_SEES11_NUM_CH         = 7'd1,     
  parameter                         MHU_ES1SE1_NUM_CH         = 7'd1,     
  
  
  parameter                         AW_FIFO_DEPTH      = 2,       
  parameter                         W_FIFO_DEPTH       = 2,       
  parameter                         B_FIFO_DEPTH       = 2,       
  parameter                         AR_FIFO_DEPTH      = 2,       
  parameter                         R_FIFO_DEPTH       = 2,       
  parameter                         AW_PAYLOAD_WIDTH   = 124,     
  parameter                         W_PAYLOAD_WIDTH    = 74,      
  parameter                         B_PAYLOAD_WIDTH    = 8,       
  parameter                         AR_PAYLOAD_WIDTH   = 124,     
  parameter                         R_PAYLOAD_WIDTH    = 74,      

  parameter                         CAAON2CA_WIDTH     = 289,     
  parameter                         CA2CAAON_WIDTH     = 300,     

  parameter                         AHB_SYNC_BRIDGE    = 1        

) (
  input  wire                       SECENCCLK,
  input  wire                       SECENCDIVCLK,
  input  wire                       SECENCHINTCLK,
  input  wire                       S32KCLK_SECENC,
  input  wire                       SECENCPORESETn,
  input  wire                       SECENCWARMRESETn,
  input  wire                       SECENCCPUWAIT,

  output wire                       M0_HALTED,
  input  wire                       CDBGPWRUPREQ0,

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

    
  input  wire                       SOC_WD_IRQ,
  input  wire                       UART_IRQ,
  input  wire                       PPU_IRQ,
  input  wire                       CO_IRQ,
  input  wire                       HOST_FWT_IRQ, 
  input  wire                       INT_RTT_IRQ,  
  input  wire                       SWD_WS1_IRQ,  

  output wire                       MHU2R_CIRQ,
  output wire                       MHU2S_CIRQ,
    output wire                       MHU3R_CIRQ,
  output wire                       MHU3S_CIRQ,
    output wire                       MHU4R_CIRQ,
  output wire                       MHU4S_CIRQ,
    output wire                       MHU5R_CIRQ,
  output wire                       MHU5S_CIRQ,
    
  output wire                       AON_APB_ASYNC_REQ,
  output wire                [55:0] AON_APB_ASYNC_REQ_PAYLOAD,
  input  wire                [32:0] AON_APB_ASYNC_RESP_PAYLOAD,
  input  wire                       AON_APB_ASYNC_ACK,

  output wire                       SOCWD_APB_ASYNC_REQ,
  output wire                [47:0] SOCWD_APB_ASYNC_REQ_PAYLOAD,
  input  wire                [32:0] SOCWD_APB_ASYNC_RESP_PAYLOAD,
  input  wire                       SOCWD_APB_ASYNC_ACK,

  input  wire                       MHU0_QREQn,
  output wire                       MHU0_QACCEPTn,
  output wire                       MHU0_QDENY,
  input  wire                       MHU1_QREQn,
  output wire                       MHU1_QACCEPTn,
  output wire                       MHU1_QDENY,
  
  input  wire                       MHU2_QREQn,
  output wire                       MHU2_QACCEPTn,
  output wire                       MHU2_QDENY,
    input  wire                       MHU3_QREQn,
  output wire                       MHU3_QACCEPTn,
  output wire                       MHU3_QDENY,
    
  input  wire                       MHU4_QREQn,
  output wire                       MHU4_QACCEPTn,
  output wire                       MHU4_QDENY,
    input  wire                       MHU5_QREQn,
  output wire                       MHU5_QACCEPTn,
  output wire                       MHU5_QDENY,
    input  wire                       CTI_QREQn,
  output wire                       CTI_QACCEPTn,
  output wire                       CTI_QDENY,
  output wire                       CTI_QACTIVE,
  input  wire                       CM0_QREQn,
  output wire                       CM0_QACCEPTn,
  output wire                       CM0_QDENY,
  output wire                       CM0_QACTIVE,
  input  wire                       AXIB_QREQn,
  output wire                       AXIB_QACCEPTn,
  output wire                       AXIB_QDENY,
  output wire                       AXIB_QACTIVE,

  input  wire                       SOCWD_ADB_QREQn,
  output wire                       SOCWD_ADB_QACCEPTn,
  output wire                       SOCWD_ADB_QDENY,
  output wire                       SOCWD_ADB_QACTIVE,

  input  wire                       AON_ADB_QREQn,
  output wire                       AON_ADB_QACCEPTn,
  output wire                       AON_ADB_QDENY,
  output wire                       AON_ADB_QACTIVE,

  output wire                       WDOG_RST_REQ, 
  output wire                       SW_RST_REQ,   

  input  wire                       DBGEN,
  input  wire                       NIDEN,
  input  wire                       CHEN,
  input  wire                       FIREWALL_BYPASS,

  input  wire  [CAAON2CA_WIDTH-1:0] CAAON2CA,
  output wire  [CA2CAAON_WIDTH-1:0] CA2CAAON,

  output wire                       CAE,
  input  wire                       CA_ERR_MSK,
  

  
  input  wire                       CLKFORCE,
  input  wire  [7:0]                ENTRY_DELAY,

  input  wire  [1:0]                DFTRSTDISABLE,
  input  wire                       DFTRAMHOLD,
  input  wire                       DFTCGEN,
  input  wire                       DFTMCPHOLD,
  input  wire                       MBISTREQ,
  input  wire                       DFTSE,
  input  wire                       DFTTESTMODE
);


  wire        dbg_psel;
  wire        dbg_penable;
  wire [12:0] dbg_paddr;
  wire        dbg_pwrite;
  wire [31:0] dbg_pwdata;
  wire        dbg_pwakeup;
  wire [31:0] dbg_prdata;
  wire        dbg_pready;
  wire        dbg_pslverr;

  wire [31:0] slv_haddr;     
  wire  [6:0] slv_hprot;     
  wire  [2:0] slv_hsize;     
  wire  [2:0] slv_hburst;    
  wire  [1:0] slv_htrans;    
  wire [31:0] slv_hwdata;    
  wire        slv_hwrite;    
  wire [31:0] slv_hrdata;    
  wire        slv_hready;    
  wire        slv_hresp;     

  wire        dp_abort;

  wire        ahbap_en;

  wire [3:0] cti_cha_to_secenc;
  wire [3:0] cti_secenc_to_cha;

  wire        awakeup;          
  wire        awid;             
  wire [31:0] awaddr;           
  wire  [7:0] awlen;            
  wire  [2:0] awsize;           
  wire  [1:0] awburst;          
  wire        awlock;           
  wire  [3:0] awcache;          
  wire  [2:0] awprot;           
  wire  [3:0] awqos;            
  wire  [3:0] awregion;         
  wire        awvalid;          
  wire        awready;          
  wire        awuser;
  wire [31:0] wdata;            
  wire  [3:0] wstrb;            
  wire        wlast;            
  wire        wvalid;           
  wire        wready;           
  wire        wuser;
  wire        bid;              
  wire  [1:0] bresp;            
  wire        bvalid;           
  wire        bready;           
  wire        buser;
  wire        arid;             
  wire [31:0] araddr;           
  wire  [7:0] arlen;            
  wire  [2:0] arsize;           
  wire  [1:0] arburst;          
  wire        arlock;           
  wire  [3:0] arcache;          
  wire  [2:0] arprot;           
  wire  [3:0] arqos;            
  wire  [3:0] arregion;         
  wire        arvalid;          
  wire        arready;          
  wire        aruser;
  wire        rid;              
  wire [31:0] rdata;            
  wire  [1:0] rresp;            
  wire        rlast;            
  wire        rvalid;           
  wire        rready;           
  wire        ruser;

  wire        aon_psel;         
  wire        aon_penable;      
  wire [19:0] aon_paddr;        
  wire        aon_pwrite;       
  wire [31:0] aon_pwdata;       
  wire        aon_pready;       
  wire [31:0] aon_prdata;       
  wire        aon_pslverr;      

  wire        socwd_psel;       
  wire        socwd_penable;    
  wire [11:0] socwd_paddr;      
  wire        socwd_pwrite;     
  wire [31:0] socwd_pwdata;     
  wire        socwd_pready;     
  wire [31:0] socwd_prdata;     
  wire        socwd_pslverr;    

  wire        porst_n;
  wire        wrst_secencclk_n;
  wire        wrst_secencdivclk_n;
  wire        k32rst_n;

  wire        dbgen_ss;
  wire        niden_ss;
  wire        chen_ss;
  wire        firewall_bypass_ss;

  wire        secenccpuwait_ss;


  reg mhu2r_cirq_r;
  reg mhu2s_cirq_r;
  wire mhu2r_cirq_int;
  wire mhu2s_cirq_int;
  
     
  reg mhu3r_cirq_r;
  reg mhu3s_cirq_r;
  wire mhu3r_cirq_int;
  wire mhu3s_cirq_int;
 
  
  reg mhu4r_cirq_r;
  reg mhu4s_cirq_r;
  wire mhu4r_cirq_int;
  wire mhu4s_cirq_int;
  
     
  reg mhu5r_cirq_r;
  reg mhu5s_cirq_r;
  wire mhu5r_cirq_int;
  wire mhu5s_cirq_int;
 
  
  wire       dclk;
  wire       dclk_en;
  wire [3:0] dclk_qreqn;
  wire [3:0] dclk_qacceptn;
  wire [3:0] dclk_qdeny;
  wire [5:0] dclk_qactive;


  wire        unused;

  assign unused =   (&slv_hprot) |
                    (&slv_hsize) |
                      awuser     |
                      aruser     |
                      wuser;


  sec_reset_sync u_sec_reset_sync_0 (
    .clk            (SECENCDIVCLK),
    .resetn_async   (SECENCPORESETn),
    .resetn_sync    (porst_n),
    .dftrstdisable  (DFTRSTDISABLE[0])
  );

  sec_reset_sync u_sec_reset_sync_1 (
    .clk            (SECENCDIVCLK),
    .resetn_async   (SECENCWARMRESETn),
    .resetn_sync    (wrst_secencdivclk_n),
    .dftrstdisable  (DFTRSTDISABLE[0])
  );

  sec_reset_sync u_sec_reset_sync_2 (
    .clk            (SECENCCLK),
    .resetn_async   (SECENCWARMRESETn),
    .resetn_sync    (wrst_secencclk_n),
    .dftrstdisable  (DFTRSTDISABLE[0])
  );

  sec_reset_sync u_sec_reset_sync_3 (
    .clk            (S32KCLK_SECENC),
    .resetn_async   (SECENCWARMRESETn),
    .resetn_sync    (k32rst_n),
    .dftrstdisable  (DFTRSTDISABLE[0])
  );


  sec_cdc_capt_sync u_sec_cdc_capt_sync_0 (
    .clk        (SECENCDIVCLK),
    .nreset     (porst_n),
    .d_async    (DBGEN),
    .q          (dbgen_ss)
  );

  sec_cdc_capt_sync u_sec_cdc_capt_sync_1 (
    .clk        (SECENCDIVCLK),
    .nreset     (porst_n),
    .d_async    (NIDEN),
    .q          (niden_ss)
  );

  sec_cdc_capt_sync u_sec_cdc_capt_sync_2 (
    .clk        (SECENCDIVCLK),
    .nreset     (porst_n),
    .d_async    (CHEN),
    .q          (chen_ss)
  );

  sec_cdc_capt_sync u_sec_cdc_capt_sync_3 (
    .clk        (SECENCCLK),
    .nreset     (porst_n),
    .d_async    (FIREWALL_BYPASS),
    .q          (firewall_bypass_ss)
  );

  sec_cdc_capt_sync_set u_sec_cdc_capt_sync_set (
    .clk        (SECENCDIVCLK),
    .nset       (porst_n),
    .d_async    (SECENCCPUWAIT),
    .q          (secenccpuwait_ss)
  );


  secenc_f1_core #(
    .SEC_ENC_ROM_SIZE                (SEC_ENC_ROM_SIZE),
    .SEC_ENC_RAM_SIZE                (SEC_ENC_RAM_SIZE),
    .MHU_HSE0_NUM_CH                 (MHU_HSE0_NUM_CH),
    .MHU_SEH0_NUM_CH                 (MHU_SEH0_NUM_CH),
    .MHU_HSE1_NUM_CH                 (MHU_HSE1_NUM_CH),
    .MHU_SEH1_NUM_CH                 (MHU_SEH1_NUM_CH),
    .MHU_SEES00_NUM_CH  (MHU_SEES00_NUM_CH),
    .MHU_ES0SE0_NUM_CH  (MHU_ES0SE0_NUM_CH),
      .MHU_SEES01_NUM_CH  (MHU_SEES01_NUM_CH),
    .MHU_ES0SE1_NUM_CH  (MHU_ES0SE1_NUM_CH),
      .MHU_SEES10_NUM_CH  (MHU_SEES10_NUM_CH),
    .MHU_ES1SE0_NUM_CH  (MHU_ES1SE0_NUM_CH),
      .MHU_SEES11_NUM_CH  (MHU_SEES11_NUM_CH),
    .MHU_ES1SE1_NUM_CH  (MHU_ES1SE1_NUM_CH),
      .CAAON2CA_WIDTH                  (CAAON2CA_WIDTH),
    .CA2CAAON_WIDTH                  (CA2CAAON_WIDTH),
    .AHB_SYNC_BRIDGE                 (AHB_SYNC_BRIDGE)
  ) u_secenc_f1_core (
    .SECENCCLK                       (SECENCCLK),
    .SECENCDIVCLK                    (SECENCDIVCLK),
    .SECENCHINTCLK                   (SECENCHINTCLK),
    .S32KCLK_SECENC                  (S32KCLK_SECENC),
    .DCLK                            (dclk),                  
    .DCLKEN                          (dclk_en),               
    .SECENCPORESETn                  (porst_n),               
    .SECENCWARMRESETn                (SECENCWARMRESETn),      
    .SECENCWARMRESETn_SECENCCLK      (wrst_secencclk_n),      
    .SECENCWARMRESETn_SECENCDIVCLK   (wrst_secencdivclk_n),   
    .K32WARMRESETn                   (k32rst_n),              
    .AP_HADDR                        (slv_haddr),
    .AP_HPROT                        (slv_hprot[3:0]),
    .AP_HBURST                       (slv_hburst),
    .AP_HSIZE                        (slv_hsize[1:0]),
    .AP_HTRANS                       (slv_htrans),
    .AP_HWDATA                       (slv_hwdata),
    .AP_HWRITE                       (slv_hwrite),
    .AP_HRDATA                       (slv_hrdata),
    .AP_HREADY                       (slv_hready),
    .AP_HRESP                        (slv_hresp),
    .CTI_SECENC_TO_CHA               (cti_secenc_to_cha),
    .CTI_CHA_TO_SECENC               (cti_cha_to_secenc),
    .CPUWAIT                         (secenccpuwait_ss),
    .HALTED                          (M0_HALTED),
    .AWAKEUPM                        (awakeup),
    .AWIDM                           (awid),
    .AWADDRM                         (awaddr),
    .AWLENM                          (awlen),
    .AWSIZEM                         (awsize),
    .AWBURSTM                        (awburst),
    .AWLOCKM                         (awlock),
    .AWCACHEM                        (awcache),
    .AWPROTM                         (awprot),
    .AWQOSM                          (awqos),
    .AWREGIONM                       (awregion),
    .AWVALIDM                        (awvalid),
    .AWREADYM                        (awready),
    .AWUSERM                         (awuser),
    .WDATAM                          (wdata),
    .WSTRBM                          (wstrb),
    .WLASTM                          (wlast),
    .WVALIDM                         (wvalid),
    .WREADYM                         (wready),
    .WUSERM                          (wuser),
    .BIDM                            (bid),
    .BRESPM                          (bresp),
    .BVALIDM                         (bvalid),
    .BUSERM                          (buser),
    .BREADYM                         (bready),
    .ARIDM                           (arid),
    .ARADDRM                         (araddr),
    .ARLENM                          (arlen),
    .ARSIZEM                         (arsize),
    .ARBURSTM                        (arburst),
    .ARLOCKM                         (arlock),
    .ARCACHEM                        (arcache),
    .ARPROTM                         (arprot),
    .ARQOSM                          (arqos),
    .ARREGIONM                       (arregion),
    .ARVALIDM                        (arvalid),
    .ARREADYM                        (arready),
    .ARUSERM                         (aruser),
    .RIDM                            (rid),
    .RDATAM                          (rdata),
    .RRESPM                          (rresp),
    .RLASTM                          (rlast),
    .RVALIDM                         (rvalid),
    .RREADYM                         (rready),
    .RUSERM                          (ruser),
    .MHU0R_ASYNC_REQ                 (MHU_HSE0_APB_ASYNC_REQ),
    .MHU0R_ASYNC_REQ_PAYLOAD         (MHU_HSE0_APB_ASYNC_REQ_PAYLOAD),
    .MHU0R_ASYNC_RESP_PAYLOAD        (MHU_HSE0_APB_ASYNC_RESP_PAYLOAD),
    .MHU0R_ASYNC_ACK                 (MHU_HSE0_APB_ASYNC_ACK),
    .MHU0R_RECAWAKE_ASYNC            (MHU_HSE0_RECAWAKE_ASYNC),
    .MHU0R_RECWAKEUP_ASYNC           (MHU_HSE0_RECWAKEUP_ASYNC),
    .MHU0R_EDGE_ASYNC_REQ            (MHU_HSE0_EDGE_ASYNC_REQ),
    .MHU0R_EDGE_ASYNC_ACK            (MHU_HSE0_EDGE_ASYNC_ACK),
    .MHU0S_ASYNC_REQ                 (MHU_SEH0_APB_ASYNC_REQ),
    .MHU0S_ASYNC_REQ_PAYLOAD         (MHU_SEH0_APB_ASYNC_REQ_PAYLOAD),
    .MHU0S_ASYNC_RESP_PAYLOAD        (MHU_SEH0_APB_ASYNC_RESP_PAYLOAD),
    .MHU0S_ASYNC_ACK                 (MHU_SEH0_APB_ASYNC_ACK),
    .MHU0S_RECAWAKE_ASYNC            (MHU_SEH0_RECAWAKE_ASYNC),
    .MHU0S_RECWAKEUP_ASYNC           (MHU_SEH0_RECWAKEUP_ASYNC),
    .MHU0S_EDGE_ASYNC_REQ            (MHU_SEH0_EDGE_ASYNC_REQ),
    .MHU0S_EDGE_ASYNC_ACK            (MHU_SEH0_EDGE_ASYNC_ACK),
    .MHU1R_ASYNC_REQ                 (MHU_HSE1_APB_ASYNC_REQ),
    .MHU1R_ASYNC_REQ_PAYLOAD         (MHU_HSE1_APB_ASYNC_REQ_PAYLOAD),
    .MHU1R_ASYNC_RESP_PAYLOAD        (MHU_HSE1_APB_ASYNC_RESP_PAYLOAD),
    .MHU1R_ASYNC_ACK                 (MHU_HSE1_APB_ASYNC_ACK),
    .MHU1R_RECAWAKE_ASYNC            (MHU_HSE1_RECAWAKE_ASYNC),
    .MHU1R_RECWAKEUP_ASYNC           (MHU_HSE1_RECWAKEUP_ASYNC),
    .MHU1R_EDGE_ASYNC_REQ            (MHU_HSE1_EDGE_ASYNC_REQ),
    .MHU1R_EDGE_ASYNC_ACK            (MHU_HSE1_EDGE_ASYNC_ACK),
    .MHU1S_ASYNC_REQ                 (MHU_SEH1_APB_ASYNC_REQ),
    .MHU1S_ASYNC_REQ_PAYLOAD         (MHU_SEH1_APB_ASYNC_REQ_PAYLOAD),
    .MHU1S_ASYNC_RESP_PAYLOAD        (MHU_SEH1_APB_ASYNC_RESP_PAYLOAD),
    .MHU1S_ASYNC_ACK                 (MHU_SEH1_APB_ASYNC_ACK),
    .MHU1S_RECAWAKE_ASYNC            (MHU_SEH1_RECAWAKE_ASYNC),
    .MHU1S_RECWAKEUP_ASYNC           (MHU_SEH1_RECWAKEUP_ASYNC),
    .MHU1S_EDGE_ASYNC_REQ            (MHU_SEH1_EDGE_ASYNC_REQ),
    .MHU1S_EDGE_ASYNC_ACK            (MHU_SEH1_EDGE_ASYNC_ACK),
   
    .MHU2R_ASYNC_REQ                 (MHU_ES0SE0_APB_ASYNC_REQ),
    .MHU2R_ASYNC_REQ_PAYLOAD         (MHU_ES0SE0_APB_ASYNC_REQ_PAYLOAD),
    .MHU2R_ASYNC_RESP_PAYLOAD        (MHU_ES0SE0_APB_ASYNC_RESP_PAYLOAD),
    .MHU2R_ASYNC_ACK                 (MHU_ES0SE0_APB_ASYNC_ACK),
    .MHU2R_RECAWAKE_ASYNC            (MHU_ES0SE0_RECAWAKE_ASYNC),
    .MHU2R_RECWAKEUP_ASYNC           (MHU_ES0SE0_RECWAKEUP_ASYNC),
    .MHU2R_EDGE_ASYNC_REQ            (MHU_ES0SE0_EDGE_ASYNC_REQ),
    .MHU2R_EDGE_ASYNC_ACK            (MHU_ES0SE0_EDGE_ASYNC_ACK),
    .MHU2S_ASYNC_REQ                 (MHU_SEES00_APB_ASYNC_REQ),
    .MHU2S_ASYNC_REQ_PAYLOAD         (MHU_SEES00_APB_ASYNC_REQ_PAYLOAD),
    .MHU2S_ASYNC_RESP_PAYLOAD        (MHU_SEES00_APB_ASYNC_RESP_PAYLOAD),
    .MHU2S_ASYNC_ACK                 (MHU_SEES00_APB_ASYNC_ACK),
    .MHU2S_RECAWAKE_ASYNC            (MHU_SEES00_RECAWAKE_ASYNC),
    .MHU2S_RECWAKEUP_ASYNC           (MHU_SEES00_RECWAKEUP_ASYNC),
    .MHU2S_EDGE_ASYNC_REQ            (MHU_SEES00_EDGE_ASYNC_REQ),
    .MHU2S_EDGE_ASYNC_ACK            (MHU_SEES00_EDGE_ASYNC_ACK),
      .MHU3R_ASYNC_REQ                 (MHU_ES0SE1_APB_ASYNC_REQ),
    .MHU3R_ASYNC_REQ_PAYLOAD         (MHU_ES0SE1_APB_ASYNC_REQ_PAYLOAD),
    .MHU3R_ASYNC_RESP_PAYLOAD        (MHU_ES0SE1_APB_ASYNC_RESP_PAYLOAD),
    .MHU3R_ASYNC_ACK                 (MHU_ES0SE1_APB_ASYNC_ACK),
    .MHU3R_RECAWAKE_ASYNC            (MHU_ES0SE1_RECAWAKE_ASYNC),
    .MHU3R_RECWAKEUP_ASYNC           (MHU_ES0SE1_RECWAKEUP_ASYNC),
    .MHU3R_EDGE_ASYNC_REQ            (MHU_ES0SE1_EDGE_ASYNC_REQ),
    .MHU3R_EDGE_ASYNC_ACK            (MHU_ES0SE1_EDGE_ASYNC_ACK),
    .MHU3S_ASYNC_REQ                 (MHU_SEES01_APB_ASYNC_REQ),
    .MHU3S_ASYNC_REQ_PAYLOAD         (MHU_SEES01_APB_ASYNC_REQ_PAYLOAD),
    .MHU3S_ASYNC_RESP_PAYLOAD        (MHU_SEES01_APB_ASYNC_RESP_PAYLOAD),
    .MHU3S_ASYNC_ACK                 (MHU_SEES01_APB_ASYNC_ACK),
    .MHU3S_RECAWAKE_ASYNC            (MHU_SEES01_RECAWAKE_ASYNC),
    .MHU3S_RECWAKEUP_ASYNC           (MHU_SEES01_RECWAKEUP_ASYNC),
    .MHU3S_EDGE_ASYNC_REQ            (MHU_SEES01_EDGE_ASYNC_REQ),
    .MHU3S_EDGE_ASYNC_ACK            (MHU_SEES01_EDGE_ASYNC_ACK),
     
   
    .MHU4R_ASYNC_REQ                 (MHU_ES1SE0_APB_ASYNC_REQ),
    .MHU4R_ASYNC_REQ_PAYLOAD         (MHU_ES1SE0_APB_ASYNC_REQ_PAYLOAD),
    .MHU4R_ASYNC_RESP_PAYLOAD        (MHU_ES1SE0_APB_ASYNC_RESP_PAYLOAD),
    .MHU4R_ASYNC_ACK                 (MHU_ES1SE0_APB_ASYNC_ACK),
    .MHU4R_RECAWAKE_ASYNC            (MHU_ES1SE0_RECAWAKE_ASYNC),
    .MHU4R_RECWAKEUP_ASYNC           (MHU_ES1SE0_RECWAKEUP_ASYNC),
    .MHU4R_EDGE_ASYNC_REQ            (MHU_ES1SE0_EDGE_ASYNC_REQ),
    .MHU4R_EDGE_ASYNC_ACK            (MHU_ES1SE0_EDGE_ASYNC_ACK),
    .MHU4S_ASYNC_REQ                 (MHU_SEES10_APB_ASYNC_REQ),
    .MHU4S_ASYNC_REQ_PAYLOAD         (MHU_SEES10_APB_ASYNC_REQ_PAYLOAD),
    .MHU4S_ASYNC_RESP_PAYLOAD        (MHU_SEES10_APB_ASYNC_RESP_PAYLOAD),
    .MHU4S_ASYNC_ACK                 (MHU_SEES10_APB_ASYNC_ACK),
    .MHU4S_RECAWAKE_ASYNC            (MHU_SEES10_RECAWAKE_ASYNC),
    .MHU4S_RECWAKEUP_ASYNC           (MHU_SEES10_RECWAKEUP_ASYNC),
    .MHU4S_EDGE_ASYNC_REQ            (MHU_SEES10_EDGE_ASYNC_REQ),
    .MHU4S_EDGE_ASYNC_ACK            (MHU_SEES10_EDGE_ASYNC_ACK),
      .MHU5R_ASYNC_REQ                 (MHU_ES1SE1_APB_ASYNC_REQ),
    .MHU5R_ASYNC_REQ_PAYLOAD         (MHU_ES1SE1_APB_ASYNC_REQ_PAYLOAD),
    .MHU5R_ASYNC_RESP_PAYLOAD        (MHU_ES1SE1_APB_ASYNC_RESP_PAYLOAD),
    .MHU5R_ASYNC_ACK                 (MHU_ES1SE1_APB_ASYNC_ACK),
    .MHU5R_RECAWAKE_ASYNC            (MHU_ES1SE1_RECAWAKE_ASYNC),
    .MHU5R_RECWAKEUP_ASYNC           (MHU_ES1SE1_RECWAKEUP_ASYNC),
    .MHU5R_EDGE_ASYNC_REQ            (MHU_ES1SE1_EDGE_ASYNC_REQ),
    .MHU5R_EDGE_ASYNC_ACK            (MHU_ES1SE1_EDGE_ASYNC_ACK),
    .MHU5S_ASYNC_REQ                 (MHU_SEES11_APB_ASYNC_REQ),
    .MHU5S_ASYNC_REQ_PAYLOAD         (MHU_SEES11_APB_ASYNC_REQ_PAYLOAD),
    .MHU5S_ASYNC_RESP_PAYLOAD        (MHU_SEES11_APB_ASYNC_RESP_PAYLOAD),
    .MHU5S_ASYNC_ACK                 (MHU_SEES11_APB_ASYNC_ACK),
    .MHU5S_RECAWAKE_ASYNC            (MHU_SEES11_RECAWAKE_ASYNC),
    .MHU5S_RECWAKEUP_ASYNC           (MHU_SEES11_RECWAKEUP_ASYNC),
    .MHU5S_EDGE_ASYNC_REQ            (MHU_SEES11_EDGE_ASYNC_REQ),
    .MHU5S_EDGE_ASYNC_ACK            (MHU_SEES11_EDGE_ASYNC_ACK),
     
   
    .SOC_WD_IRQ                      (SOC_WD_IRQ),
    .UART_IRQ                        (UART_IRQ),
    .PPU_IRQ                         (PPU_IRQ),
    .CO_IRQ                          (CO_IRQ),
    .HOST_FWT_IRQ                    (HOST_FWT_IRQ),
    .INT_RTT_IRQ                     (INT_RTT_IRQ),
    .SWD_WS1_IRQ                     (SWD_WS1_IRQ),
       
    .MHU2R_CIRQ    (mhu2r_cirq_int),
    .MHU2S_CIRQ    (mhu2s_cirq_int),
      .MHU3R_CIRQ    (mhu3r_cirq_int),
    .MHU3S_CIRQ    (mhu3s_cirq_int),
         
    .MHU4R_CIRQ    (mhu4r_cirq_int),
    .MHU4S_CIRQ    (mhu4s_cirq_int),
      .MHU5R_CIRQ    (mhu5r_cirq_int),
    .MHU5S_CIRQ    (mhu5s_cirq_int),
      .AON_PSEL                        (aon_psel),
    .AON_PENABLE                     (aon_penable),
    .AON_PADDR                       (aon_paddr),
    .AON_PWRITE                      (aon_pwrite),
    .AON_PWDATA                      (aon_pwdata),
    .AON_PREADY                      (aon_pready),
    .AON_PRDATA                      (aon_prdata),
    .AON_PSLVERR                     (aon_pslverr),
    .SOCWD_PSEL                      (socwd_psel),
    .SOCWD_PENABLE                   (socwd_penable),
    .SOCWD_PADDR                     (socwd_paddr),
    .SOCWD_PWRITE                    (socwd_pwrite),
    .SOCWD_PWDATA                    (socwd_pwdata),
    .SOCWD_PREADY                    (socwd_pready),
    .SOCWD_PRDATA                    (socwd_prdata),
    .SOCWD_PSLVERR                   (socwd_pslverr),
    .MHU0_QREQn                      (MHU0_QREQn),
    .MHU0_QACCEPTn                   (MHU0_QACCEPTn),
    .MHU0_QDENY                      (MHU0_QDENY),
    .MHU1_QREQn                      (MHU1_QREQn),
    .MHU1_QACCEPTn                   (MHU1_QACCEPTn),
    .MHU1_QDENY                      (MHU1_QDENY),
   
    .MHU2_QREQn    (MHU2_QREQn),
    .MHU2_QACCEPTn (MHU2_QACCEPTn),
    .MHU2_QDENY    (MHU2_QDENY),
      .MHU3_QREQn    (MHU3_QREQn),
    .MHU3_QACCEPTn (MHU3_QACCEPTn),
    .MHU3_QDENY    (MHU3_QDENY),
     
    .MHU4_QREQn    (MHU4_QREQn),
    .MHU4_QACCEPTn (MHU4_QACCEPTn),
    .MHU4_QDENY    (MHU4_QDENY),
      .MHU5_QREQn    (MHU5_QREQn),
    .MHU5_QACCEPTn (MHU5_QACCEPTn),
    .MHU5_QDENY    (MHU5_QDENY),
      .CM0_QREQn                       (CM0_QREQn),
    .CM0_QACCEPTn                    (CM0_QACCEPTn),
    .CM0_QDENY                       (CM0_QDENY),
    .CM0_QACTIVE                     (CM0_QACTIVE),
    .WDOG_RST_REQ                    (WDOG_RST_REQ),
    .M0_SRST_REQ                     (SW_RST_REQ),
    .DBGEN                           (dbgen_ss),
    .NIDEN                           (niden_ss),
    .CHEN                            (chen_ss),
    .FIREWALL_BYPASS                 (firewall_bypass_ss),
    .CAAON2CA                        (CAAON2CA),
    .CA2CAAON                        (CA2CAAON),
    .CAE                             (CAE),
    .CA_ERR_MSK                      (CA_ERR_MSK),

    .DFTRAMHOLD                      (DFTRAMHOLD),
    .DFTCGEN                         (DFTCGEN),
    .DFTRSTDISABLE                   (DFTRSTDISABLE),
    .DFTSE                           (DFTSE),
    .DFTTESTMODE                     (DFTTESTMODE),
    .DFTMCPHOLD                      (DFTMCPHOLD),
    .MBISTREQ                        (MBISTREQ)
  );


  pck600_clk_ctrl #(
    .NUM_Q_CHL (4),
    .NUM_QACTIVE_ONLY (2),
    .HC_Q_CH_SYNC (0),
    .PWR_Q_CH_SYNC (0),
    .CLK_Q_CH_SYNC (1),
    .ACTIVE_DENY_EN (0),
    .CLK_QACTIVE_SYNC (1)
  ) u_pck600_clk_ctrl_0 (
    .clk (SECENCDIVCLK),
    .reset_n (porst_n),
    .dftcgen (DFTCGEN),
    .hc_qreqn_i(1'b1), 
    .hc_qacceptn_o(),
    .hc_qdeny_o(),
    .hc_qactive_o(),
    .pwr_qreqn_i(1'b1),
    .pwr_qacceptn_o(),
    .pwr_qdeny_o(),
    .pwr_qactive_o(),
    .clk_qreqn_o(dclk_qreqn),
    .clk_qacceptn_i(dclk_qacceptn),
    .clk_qactive_i(dclk_qactive),
    .clk_qdeny_i(dclk_qdeny),
    .clk_force_i(CLKFORCE),
    .entry_delay_i(ENTRY_DELAY),
    .clken_o(dclk_en)
  );

  sec_clock_gate u_dclk_clk_gate (
    .clk_in  (SECENCDIVCLK),
    .enable  (dclk_en),
    .dftcgen (DFTCGEN),
    .clk_out (dclk)
  );

  css600_apbasyncbridgemstr #(
    .APB_ADDR_WIDTH           (13),
    .FF_SYNC_DEPTH            (2)
  ) u_css600_apbasyncbridgemstr (
    .clk_m                    (dclk),
    .reset_m_n                (porst_n),
    .dftcgen                  (DFTCGEN),
    .psel_m                   (dbg_psel),
    .penable_m                (dbg_penable),
    .paddr_m                  (dbg_paddr),
    .pwrite_m                 (dbg_pwrite),
    .pwdata_m                 (dbg_pwdata),
    .pprot_m                  (),
    .prdata_m                 (dbg_prdata),
    .pready_m                 (dbg_pready),
    .pslverr_m                (dbg_pslverr),
    .pwakeup_m                (dbg_pwakeup),
    .clk_m_qreq_n             (dclk_qreqn[0]),
    .clk_m_qaccept_n          (dclk_qacceptn[0]),
    .clk_m_qdeny              (dclk_qdeny[0]),
    .clk_m_qactive            (dclk_qactive[0]),
    .apb_async_req            (DEBUG_APB_ASYNC_REQ),
    .apb_async_req_payload    (DEBUG_APB_ASYNC_REQ_PAYLOAD),
    .apb_async_resp_payload   (DEBUG_APB_ASYNC_RESP_PAYLOAD),
    .apb_async_ack            (DEBUG_APB_ASYNC_ACK)
  );

  assign ahbap_en = dbgen_ss | niden_ss;

  css600_ahbap #(
    .FF_SYNC_DEPTH            (2),
    .REVAND                   (4'h0)
  ) u_css600_ahbap (
    .clk                      (dclk),
    .reset_n                  (porst_n),
    .dftcgen                  (DFTCGEN),
    .pwakeup_s                (dbg_pwakeup),
    .psel_s                   (dbg_psel),
    .penable_s                (dbg_penable),
    .pwrite_s                 (dbg_pwrite),
    .paddr_s                  (dbg_paddr),
    .pwdata_s                 (dbg_pwdata),
    .prdata_s                 (dbg_prdata),
    .pready_s                 (dbg_pready),
    .pslverr_s                (dbg_pslverr),
    .clk_qreq_n               (dclk_qreqn[1]),
    .clk_qaccept_n            (dclk_qacceptn[1]),
    .clk_qactive              (dclk_qactive[1]),
    .clk_qdeny                (dclk_qdeny[1]),
    .ap_en                    (ahbap_en),
    .ap_secure_en             (ahbap_en),
    .baseaddr_valid           (1'b1),
    .baseaddr                 (32'hF000_0000),  
    .dp_abort                 (dp_abort),
    .haddr_m                  (slv_haddr),
    .hwrite_m                 (slv_hwrite),
    .htrans_m                 (slv_htrans),
    .hsize_m                  (slv_hsize),
    .hburst_m                 (slv_hburst),
    .hprot_m                  (slv_hprot),
    .hnonsec_m                (),
    .hlock_m                  (),
    .hwdata_m                 (slv_hwdata),
    .hready_m                 (slv_hready),
    .hresp_m                  (slv_hresp),
    .hrdata_m                 (slv_hrdata)
  );

  css600_pulseasyncbridgemstr #(
    .WIDTH         (1),
    .FF_SYNC_DEPTH (2)
  ) u_css600_pulseasyncbridgemstr_0 (
    .clk_m             (dclk),
    .reset_m_n         (porst_n),
    .pulse_out         (dp_abort),
    .pulse_req         (DP_ABORT_PULSE_REQ),
    .pulse_ack         (DP_ABORT_PULSE_ACK),
    .clk_m_qreq_n      (dclk_qreqn[2]),
    .clk_m_qaccept_n   (dclk_qacceptn[2]),
    .clk_m_qactive     (dclk_qactive[2])
    );

  assign dclk_qdeny[2] = 1'b0; 

  css600_pulseasyncbridgemstr #(
    .WIDTH         (4),
    .FF_SYNC_DEPTH (2)
  ) u_css600_pulseasyncbridgemstr_1 (
    .clk_m             (dclk),
    .reset_m_n         (porst_n),
    .pulse_out         (cti_cha_to_secenc),
    .pulse_req         (CTI_CHA_TO_SECENC_PULSE_REQ),
    .pulse_ack         (CTI_CHA_TO_SECENC_PULSE_ACK),
    .clk_m_qreq_n      (dclk_qreqn[3]),
    .clk_m_qaccept_n   (dclk_qacceptn[3]),
    .clk_m_qactive     (dclk_qactive[3])
    );

  assign dclk_qdeny[3] = 1'b0; 

  css600_pulseasyncbridgeslv #(
    .WIDTH            (4),
    .WAKE_ON_PULSE    (0), 
    .FF_SYNC_DEPTH    (2)
  ) u_css600_pulseasyncbridgeslv  (
    .clk_s            (dclk),
    .reset_s_n        (porst_n),
    .pulse_in         (cti_secenc_to_cha),
    .pulse_req        (CTI_SECENC_TO_CHA_PULSE_REQ),
    .pulse_ack        (CTI_SECENC_TO_CHA_PULSE_ACK),
    .clk_s_qactive    (dclk_qactive[4]), 
    .pwr_qreq_n       (CTI_QREQn),
    .pwr_qaccept_n    (CTI_QACCEPTn),
    .pwr_qactive      (CTI_QACTIVE)
    );

  assign CTI_QDENY = 1'b0;

  assign dclk_qactive[5] = CDBGPWRUPREQ0;


  sse710_adb400_r3_axi4_slv_wrapper #(
    .ADDR_WIDTH               (32),
    .DATA_WIDTH               (32),
    .AWID_WIDTH               (1),
    .ARID_WIDTH               (1),
    .AWUSER_WIDTH             (0),
    .WUSER_WIDTH              (0),
    .BUSER_WIDTH              (1), 
    .ARUSER_WIDTH             (0),
    .RUSER_WIDTH              (1), 
    .AW_FIFO_DEPTH            (AW_FIFO_DEPTH),
    .W_FIFO_DEPTH             (W_FIFO_DEPTH),
    .B_FIFO_DEPTH             (B_FIFO_DEPTH),
    .AR_FIFO_DEPTH            (AR_FIFO_DEPTH),
    .R_FIFO_DEPTH             (R_FIFO_DEPTH),
    .B_OPREG                  (1),
    .R_OPREG                  (1),
    .SI_SYNC_LEVELS           (2),
    .AW_PAYLOAD_WIDTH         (AW_PAYLOAD_WIDTH),
    .W_PAYLOAD_WIDTH          (W_PAYLOAD_WIDTH),
    .B_PAYLOAD_WIDTH          (B_PAYLOAD_WIDTH),
    .AR_PAYLOAD_WIDTH         (AR_PAYLOAD_WIDTH),
    .R_PAYLOAD_WIDTH          (R_PAYLOAD_WIDTH)
  ) u_sse710_adb400_r3_axi4_slv_wrapper (
    .pwrq_permit_deny_sar_i   (1'b1), 
    .aclks                    (SECENCCLK),
    .aresetns                 (wrst_secencclk_n),
    .pwrqreqns_i              (AXIB_QREQn),
    .pwrqacceptns_o           (AXIB_QACCEPTn),
    .pwrqdenys_o              (AXIB_QDENY),
    .clkqreqns_i              (1'b1),
    .clkqacceptns_o           (),
    .clkqdenys_o              (),
    .clkqactives_o            (),
    .pwrqactives_o            (AXIB_QACTIVE),
    .wakeups_i                (awakeup),
    .awvalids                 (awvalid),
    .awreadys                 (awready),
    .awusers                  (1'b0),
    .awids                    (awid),
    .awaddrs                  (awaddr),
    .awregions                (awregion),
    .awlens                   (awlen),
    .awsizes                  (awsize),
    .awbursts                 (awburst),
    .awlocks                  (awlock),
    .awcaches                 (awcache),
    .awprots                  (awprot),
    .awqoss                   (awqos),
    .wvalids                  (wvalid),
    .wreadys                  (wready),
    .wusers                   (1'b0),
    .wdatas                   (wdata),
    .wstrbs                   (wstrb),
    .wlasts                   (wlast),
    .bvalids                  (bvalid),
    .breadys                  (bready),
    .busers                   (buser),
    .bids                     (bid),
    .bresps                   (bresp),
    .arvalids                 (arvalid),
    .arreadys                 (arready),
    .arusers                  (1'b0),
    .arids                    (arid),
    .araddrs                  (araddr),
    .arregions                (arregion),
    .arlens                   (arlen),
    .arsizes                  (arsize),
    .arbursts                 (arburst),
    .arlocks                  (arlock),
    .arcaches                 (arcache),
    .arprots                  (arprot),
    .arqoss                   (arqos),
    .rvalids                  (rvalid),
    .rreadys                  (rready),
    .rusers                   (ruser),
    .rids                     (rid),
    .rdatas                   (rdata),
    .rresps                   (rresp),
    .rlasts                   (rlast),
    .slvmustacceptreqn_async  (SLVMUSTACCEPTREQN_ASYNC),
    .slvcandenyreqn_async     (SLVCANDENYREQN_ASYNC),
    .slvacceptn_async         (SLVACCEPTN_ASYNC),
    .slvdeny_async            (SLVDENY_ASYNC),
    .si_to_mi_wakeup_async    (SI_TO_MI_WAKEUP_ASYNC),
    .mi_to_si_wakeup_async    (MI_TO_SI_WAKEUP_ASYNC),
    .aw_wr_ptr_async          (AW_WR_PTR_ASYNC),
    .aw_rd_ptr_async          (AW_RD_PTR_ASYNC),
    .aw_payld_async           (AW_PAYLD_ASYNC),
    .w_wr_ptr_async           (W_WR_PTR_ASYNC),
    .w_rd_ptr_async           (W_RD_PTR_ASYNC),
    .w_payld_async            (W_PAYLD_ASYNC),
    .b_wr_ptr_async           (B_WR_PTR_ASYNC),
    .b_rd_ptr_async           (B_RD_PTR_ASYNC),
    .b_payld_async            (B_PAYLD_ASYNC),
    .ar_wr_ptr_async          (AR_WR_PTR_ASYNC),
    .ar_rd_ptr_async          (AR_RD_PTR_ASYNC),
    .ar_payld_async           (AR_PAYLD_ASYNC),
    .r_wr_ptr_async           (R_WR_PTR_ASYNC),
    .r_rd_ptr_async           (R_RD_PTR_ASYNC),
    .r_payld_async            (R_PAYLD_ASYNC),
    .dftrstdisables           (DFTRSTDISABLE[1])
  );

  css600_apbasyncbridgeslv #(
    .WAKE_ON_TRANSACTION      (0),
    .APB_ADDR_WIDTH           (20),
    .FF_SYNC_DEPTH            (2)
  ) u_css600_apbasyncbridgeslv_0 (
    .clk_s                    (SECENCDIVCLK),
    .reset_s_n                (wrst_secencdivclk_n),
    .dftcgen                  (DFTCGEN),
    .psel_s                   (aon_psel),
    .penable_s                (aon_penable),
    .paddr_s                  (aon_paddr),
    .pwrite_s                 (aon_pwrite),
    .pwdata_s                 (aon_pwdata),
    .pprot_s                  (3'b0),
    .prdata_s                 (aon_prdata),
    .pready_s                 (aon_pready),
    .pslverr_s                (aon_pslverr),
    .pwakeup_s                (1'b1),
    .clk_s_qreq_n             (1'b1),
    .clk_s_qaccept_n          (),
    .clk_s_qdeny              (),
    .clk_s_qactive            (),
    .pwr_qreq_n               (AON_ADB_QREQn),
    .pwr_qaccept_n            (AON_ADB_QACCEPTn),
    .pwr_qdeny                (AON_ADB_QDENY),
    .pwr_qactive              (AON_ADB_QACTIVE),
    .apb_async_req            (AON_APB_ASYNC_REQ),
    .apb_async_req_payload    (AON_APB_ASYNC_REQ_PAYLOAD),
    .apb_async_resp_payload   (AON_APB_ASYNC_RESP_PAYLOAD),
    .apb_async_ack            (AON_APB_ASYNC_ACK)
  );

  css600_apbasyncbridgeslv #(
    .WAKE_ON_TRANSACTION      (0),
    .APB_ADDR_WIDTH           (12),
    .FF_SYNC_DEPTH            (2)
  ) u_css600_apbasyncbridgeslv_1 (
    .clk_s                    (SECENCDIVCLK),
    .reset_s_n                (wrst_secencdivclk_n),
    .dftcgen                  (DFTCGEN),
    .psel_s                   (socwd_psel),
    .penable_s                (socwd_penable),
    .paddr_s                  (socwd_paddr),
    .pwrite_s                 (socwd_pwrite),
    .pwdata_s                 (socwd_pwdata),
    .pprot_s                  (3'b0),
    .prdata_s                 (socwd_prdata),
    .pready_s                 (socwd_pready),
    .pslverr_s                (socwd_pslverr),
    .pwakeup_s                (1'b1),
    .clk_s_qreq_n             (1'b1),
    .clk_s_qaccept_n          (),
    .clk_s_qdeny              (),
    .clk_s_qactive            (),
    .pwr_qreq_n               (SOCWD_ADB_QREQn),
    .pwr_qaccept_n            (SOCWD_ADB_QACCEPTn),
    .pwr_qdeny                (SOCWD_ADB_QDENY),
    .pwr_qactive              (SOCWD_ADB_QACTIVE),
    .apb_async_req            (SOCWD_APB_ASYNC_REQ),
    .apb_async_req_payload    (SOCWD_APB_ASYNC_REQ_PAYLOAD),
    .apb_async_resp_payload   (SOCWD_APB_ASYNC_RESP_PAYLOAD),
    .apb_async_ack            (SOCWD_APB_ASYNC_ACK)
  );


  
  always @(posedge SECENCDIVCLK or negedge wrst_secencdivclk_n)
  begin
    if(!wrst_secencdivclk_n)
    begin
      mhu2r_cirq_r <= 1'b0;
      mhu2s_cirq_r <= 1'b0;
        mhu3r_cirq_r <= 1'b0;
      mhu3s_cirq_r <= 1'b0;
      end
    else
    begin
      mhu2r_cirq_r <= mhu2r_cirq_int;
      mhu2s_cirq_r <= mhu2s_cirq_int;
        mhu3r_cirq_r <= mhu3r_cirq_int;
      mhu3s_cirq_r <= mhu3s_cirq_int;
      end
  end

  assign MHU2R_CIRQ = mhu2r_cirq_r;
  assign MHU2S_CIRQ = mhu2s_cirq_r;
    assign MHU3R_CIRQ = mhu3r_cirq_r;
  assign MHU3S_CIRQ = mhu3s_cirq_r;
    
  always @(posedge SECENCDIVCLK or negedge wrst_secencdivclk_n)
  begin
    if(!wrst_secencdivclk_n)
    begin
      mhu4r_cirq_r <= 1'b0;
      mhu4s_cirq_r <= 1'b0;
        mhu5r_cirq_r <= 1'b0;
      mhu5s_cirq_r <= 1'b0;
      end
    else
    begin
      mhu4r_cirq_r <= mhu4r_cirq_int;
      mhu4s_cirq_r <= mhu4s_cirq_int;
        mhu5r_cirq_r <= mhu5r_cirq_int;
      mhu5s_cirq_r <= mhu5s_cirq_int;
      end
  end

  assign MHU4R_CIRQ = mhu4r_cirq_r;
  assign MHU4S_CIRQ = mhu4s_cirq_r;
    assign MHU5R_CIRQ = mhu5r_cirq_r;
  assign MHU5S_CIRQ = mhu5s_cirq_r;
  
  
  

endmodule
