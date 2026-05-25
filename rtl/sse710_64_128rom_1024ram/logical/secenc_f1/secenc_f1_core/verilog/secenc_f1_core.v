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

module secenc_f1_core #(

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

  
  parameter                         CAAON2CA_WIDTH     = 289,     
  parameter                         CA2CAAON_WIDTH     = 300,     

  parameter                         AHB_SYNC_BRIDGE    = 1        

) (
  input  wire                       SECENCCLK,
  input  wire                       SECENCDIVCLK,
  input  wire                       SECENCHINTCLK,
  input  wire                       S32KCLK_SECENC,
  input  wire                       DCLK,
  input  wire                       DCLKEN,
  input  wire                       SECENCPORESETn,
  input  wire                       SECENCWARMRESETn,            
  input  wire                       SECENCWARMRESETn_SECENCCLK,
  input  wire                       SECENCWARMRESETn_SECENCDIVCLK,
  input  wire                       K32WARMRESETn,

  input  wire                [31:0] AP_HADDR,
  input  wire                 [3:0] AP_HPROT,
  input  wire                 [2:0] AP_HBURST,
  input  wire                 [1:0] AP_HSIZE,
  input  wire                 [1:0] AP_HTRANS,
  input  wire                [31:0] AP_HWDATA,
  input  wire                       AP_HWRITE,
  output wire                [31:0] AP_HRDATA,
  output wire                       AP_HREADY,
  output wire                       AP_HRESP,

  output wire                 [3:0] CTI_SECENC_TO_CHA,
  input  wire                 [3:0] CTI_CHA_TO_SECENC,

  input  wire                       CPUWAIT,
  output wire                       HALTED, 

  output wire                       AWAKEUPM,         
  output wire                       AWIDM,            
  output wire                [31:0] AWADDRM,          
  output wire                 [7:0] AWLENM,           
  output wire                 [2:0] AWSIZEM,          
  output wire                 [1:0] AWBURSTM,         
  output wire                       AWLOCKM,          
  output wire                 [3:0] AWCACHEM,         
  output wire                 [2:0] AWPROTM,          
  output wire                 [3:0] AWQOSM,           
  output wire                 [3:0] AWREGIONM,        
  output wire                       AWVALIDM,         
  input  wire                       AWREADYM,         
  output wire                       AWUSERM,

  output wire                [31:0] WDATAM,           
  output wire                 [3:0] WSTRBM,           
  output wire                       WLASTM,           
  output wire                       WVALIDM,          
  input  wire                       WREADYM,          
  output wire                       WUSERM,

  input  wire                       BIDM,             
  input  wire                 [1:0] BRESPM,           
  input  wire                       BVALIDM,          
  input  wire                       BUSERM,
  output wire                       BREADYM,          

  output wire                       ARIDM,            
  output wire                [31:0] ARADDRM,          
  output wire                 [7:0] ARLENM,           
  output wire                 [2:0] ARSIZEM,          
  output wire                 [1:0] ARBURSTM,         
  output wire                       ARLOCKM,          
  output wire                 [3:0] ARCACHEM,         
  output wire                 [2:0] ARPROTM,          
  output wire                 [3:0] ARQOSM,           
  output wire                 [3:0] ARREGIONM,        
  output wire                       ARVALIDM,         
  input  wire                       ARREADYM,         
  output wire                       ARUSERM,

  input  wire                       RIDM,             
  input  wire                [31:0] RDATAM,           
  input  wire                 [1:0] RRESPM,           
  input  wire                       RLASTM,           
  input  wire                       RVALIDM,          
  output wire                       RREADYM,          
  input  wire                       RUSERM,

  input  wire                       MHU0R_ASYNC_REQ,
  input  wire                [48:0] MHU0R_ASYNC_REQ_PAYLOAD,
  output wire                [32:0] MHU0R_ASYNC_RESP_PAYLOAD,
  output wire                       MHU0R_ASYNC_ACK,
  output wire                       MHU0R_RECAWAKE_ASYNC,
  input  wire                       MHU0R_RECWAKEUP_ASYNC,
  output wire [MHU_HSE0_NUM_CH-1:0] MHU0R_EDGE_ASYNC_REQ,
  input  wire [MHU_HSE0_NUM_CH-1:0] MHU0R_EDGE_ASYNC_ACK,

  output wire                       MHU0S_ASYNC_REQ,
  output wire                [48:0] MHU0S_ASYNC_REQ_PAYLOAD,
  input  wire                [32:0] MHU0S_ASYNC_RESP_PAYLOAD,
  input  wire                       MHU0S_ASYNC_ACK,
  input  wire                       MHU0S_RECAWAKE_ASYNC,
  output wire                       MHU0S_RECWAKEUP_ASYNC,
  input  wire [MHU_SEH0_NUM_CH-1:0] MHU0S_EDGE_ASYNC_REQ,
  output wire [MHU_SEH0_NUM_CH-1:0] MHU0S_EDGE_ASYNC_ACK,

  input  wire                       MHU1R_ASYNC_REQ,
  input  wire                [48:0] MHU1R_ASYNC_REQ_PAYLOAD,
  output wire                [32:0] MHU1R_ASYNC_RESP_PAYLOAD,
  output wire                       MHU1R_ASYNC_ACK,
  output wire                       MHU1R_RECAWAKE_ASYNC,
  input  wire                       MHU1R_RECWAKEUP_ASYNC,
  output wire [MHU_HSE1_NUM_CH-1:0] MHU1R_EDGE_ASYNC_REQ,
  input  wire [MHU_HSE1_NUM_CH-1:0] MHU1R_EDGE_ASYNC_ACK,

  output wire                       MHU1S_ASYNC_REQ,
  output wire                [48:0] MHU1S_ASYNC_REQ_PAYLOAD,
  input  wire                [32:0] MHU1S_ASYNC_RESP_PAYLOAD,
  input  wire                       MHU1S_ASYNC_ACK,
  input  wire                       MHU1S_RECAWAKE_ASYNC,
  output wire                       MHU1S_RECWAKEUP_ASYNC,
  input  wire [MHU_SEH1_NUM_CH-1:0] MHU1S_EDGE_ASYNC_REQ,
  output wire [MHU_SEH1_NUM_CH-1:0] MHU1S_EDGE_ASYNC_ACK,


  input  wire                                       MHU2R_ASYNC_REQ,
  input  wire                [48:0]                 MHU2R_ASYNC_REQ_PAYLOAD,
  output wire                [32:0]                 MHU2R_ASYNC_RESP_PAYLOAD,
  output wire                                       MHU2R_ASYNC_ACK,
  output wire                                       MHU2R_RECAWAKE_ASYNC,
  input  wire                                       MHU2R_RECWAKEUP_ASYNC,
  output wire [MHU_ES0SE0_NUM_CH-1:0] MHU2R_EDGE_ASYNC_REQ,
  input  wire [MHU_ES0SE0_NUM_CH-1:0] MHU2R_EDGE_ASYNC_ACK,

  output wire                                       MHU2S_ASYNC_REQ,
  output wire                [48:0]                 MHU2S_ASYNC_REQ_PAYLOAD,
  input  wire                [32:0]                 MHU2S_ASYNC_RESP_PAYLOAD,
  input  wire                                       MHU2S_ASYNC_ACK,
  input  wire                                       MHU2S_RECAWAKE_ASYNC,
  output wire                                       MHU2S_RECWAKEUP_ASYNC,
  input  wire [MHU_SEES00_NUM_CH-1:0] MHU2S_EDGE_ASYNC_REQ,
  output wire [MHU_SEES00_NUM_CH-1:0] MHU2S_EDGE_ASYNC_ACK,

    
  input  wire                                       MHU3R_ASYNC_REQ,
  input  wire                [48:0]                 MHU3R_ASYNC_REQ_PAYLOAD,
  output wire                [32:0]                 MHU3R_ASYNC_RESP_PAYLOAD,
  output wire                                       MHU3R_ASYNC_ACK,
  output wire                                       MHU3R_RECAWAKE_ASYNC,
  input  wire                                       MHU3R_RECWAKEUP_ASYNC,
  output wire [MHU_ES0SE1_NUM_CH-1:0] MHU3R_EDGE_ASYNC_REQ,
  input  wire [MHU_ES0SE1_NUM_CH-1:0] MHU3R_EDGE_ASYNC_ACK,

  output wire                                       MHU3S_ASYNC_REQ,
  output wire                [48:0]                 MHU3S_ASYNC_REQ_PAYLOAD,
  input  wire                [32:0]                 MHU3S_ASYNC_RESP_PAYLOAD,
  input  wire                                       MHU3S_ASYNC_ACK,
  input  wire                                       MHU3S_RECAWAKE_ASYNC,
  output wire                                       MHU3S_RECWAKEUP_ASYNC,
  input  wire [MHU_SEES01_NUM_CH-1:0] MHU3S_EDGE_ASYNC_REQ,
  output wire [MHU_SEES01_NUM_CH-1:0] MHU3S_EDGE_ASYNC_ACK,
  
  input  wire                                       MHU4R_ASYNC_REQ,
  input  wire                [48:0]                 MHU4R_ASYNC_REQ_PAYLOAD,
  output wire                [32:0]                 MHU4R_ASYNC_RESP_PAYLOAD,
  output wire                                       MHU4R_ASYNC_ACK,
  output wire                                       MHU4R_RECAWAKE_ASYNC,
  input  wire                                       MHU4R_RECWAKEUP_ASYNC,
  output wire [MHU_ES1SE0_NUM_CH-1:0] MHU4R_EDGE_ASYNC_REQ,
  input  wire [MHU_ES1SE0_NUM_CH-1:0] MHU4R_EDGE_ASYNC_ACK,

  output wire                                       MHU4S_ASYNC_REQ,
  output wire                [48:0]                 MHU4S_ASYNC_REQ_PAYLOAD,
  input  wire                [32:0]                 MHU4S_ASYNC_RESP_PAYLOAD,
  input  wire                                       MHU4S_ASYNC_ACK,
  input  wire                                       MHU4S_RECAWAKE_ASYNC,
  output wire                                       MHU4S_RECWAKEUP_ASYNC,
  input  wire [MHU_SEES10_NUM_CH-1:0] MHU4S_EDGE_ASYNC_REQ,
  output wire [MHU_SEES10_NUM_CH-1:0] MHU4S_EDGE_ASYNC_ACK,

    
  input  wire                                       MHU5R_ASYNC_REQ,
  input  wire                [48:0]                 MHU5R_ASYNC_REQ_PAYLOAD,
  output wire                [32:0]                 MHU5R_ASYNC_RESP_PAYLOAD,
  output wire                                       MHU5R_ASYNC_ACK,
  output wire                                       MHU5R_RECAWAKE_ASYNC,
  input  wire                                       MHU5R_RECWAKEUP_ASYNC,
  output wire [MHU_ES1SE1_NUM_CH-1:0] MHU5R_EDGE_ASYNC_REQ,
  input  wire [MHU_ES1SE1_NUM_CH-1:0] MHU5R_EDGE_ASYNC_ACK,

  output wire                                       MHU5S_ASYNC_REQ,
  output wire                [48:0]                 MHU5S_ASYNC_REQ_PAYLOAD,
  input  wire                [32:0]                 MHU5S_ASYNC_RESP_PAYLOAD,
  input  wire                                       MHU5S_ASYNC_ACK,
  input  wire                                       MHU5S_RECAWAKE_ASYNC,
  output wire                                       MHU5S_RECWAKEUP_ASYNC,
  input  wire [MHU_SEES11_NUM_CH-1:0] MHU5S_EDGE_ASYNC_REQ,
  output wire [MHU_SEES11_NUM_CH-1:0] MHU5S_EDGE_ASYNC_ACK,
  

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
  
  output wire                       AON_PSEL,         
  output wire                       AON_PENABLE,      
  output wire                [19:0] AON_PADDR,        
  output wire                       AON_PWRITE,       
  output wire                [31:0] AON_PWDATA,       
  input  wire                       AON_PREADY,       
  input  wire                [31:0] AON_PRDATA,       
  input  wire                       AON_PSLVERR,      

  output wire                       SOCWD_PSEL,         
  output wire                       SOCWD_PENABLE,      
  output wire                [11:0] SOCWD_PADDR,        
  output wire                       SOCWD_PWRITE,       
  output wire                [31:0] SOCWD_PWDATA,       
  input  wire                       SOCWD_PREADY,       
  input  wire                [31:0] SOCWD_PRDATA,       
  input  wire                       SOCWD_PSLVERR,      

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
    input  wire                       CM0_QREQn,
  output wire                       CM0_QACCEPTn,
  output wire                       CM0_QDENY,
  output wire                       CM0_QACTIVE,

  output wire                       M0_SRST_REQ,  
  output wire                       WDOG_RST_REQ, 

  input  wire                       DBGEN,
  input  wire                       NIDEN,
  input  wire                       CHEN,
  input  wire                       FIREWALL_BYPASS,

  input  wire  [CAAON2CA_WIDTH-1:0] CAAON2CA,
  output wire  [CA2CAAON_WIDTH-1:0] CA2CAAON,
  
  output wire                       CAE,
  input  wire                       CA_ERR_MSK,
  

  input  wire                       DFTRAMHOLD,
  input  wire                       DFTCGEN,
  input  wire                [1:0]  DFTRSTDISABLE,
  input  wire                       DFTMCPHOLD,
  input  wire                       MBISTREQ,
  input  wire                       DFTSE,
  input  wire                       DFTTESTMODE
);


  function integer secenc_f1_clog2 (input integer num);
    integer i;
    begin
      secenc_f1_clog2 = 0;
      for(i=num; i>1; i=i>>1)
        secenc_f1_clog2 = secenc_f1_clog2 + 1;
    end
  endfunction


  localparam ROM_AW = secenc_f1_clog2({16'd0,SEC_ENC_ROM_SIZE}<<10);
  localparam RAM_AW = secenc_f1_clog2({16'd0,SEC_ENC_RAM_SIZE}<<10);


  wire [31:0] m0_haddr;         
  wire  [2:0] m0_hburst;        
  wire        m0_hmastlock;     
  wire  [3:0] m0_hprot;         
  wire  [2:0] m0_hsize;         
  wire  [1:0] m0_htrans;        
  wire [31:0] m0_hwdata;        
  wire        m0_hwrite;        
  wire [31:0] m0_hrdata;        
  wire        m0_hready;        
  wire  [1:0] m0_hresp;         
  wire        m0_hmaster;       

  wire        crypto_int;
  
  wire        ca_idle;
  
  wire [31:0] m0_irq;

  wire        rom_hsel;
  wire [31:0] rom_haddr;
  wire  [1:0] rom_htrans;
  wire        rom_hwrite;
  wire  [2:0] rom_hsize;
  wire [31:0] rom_hwdata;
  wire        rom_hready;
  wire [31:0] rom_hrdata;
  wire        rom_hreadyout;
  wire  [1:0] rom_hresp;

  wire        ram_hsel;
  wire [31:0] ram_haddr;
  wire  [1:0] ram_htrans;
  wire        ram_hwrite;
  wire  [2:0] ram_hsize;
  wire [31:0] ram_hwdata;
  wire        ram_hready;
  wire [31:0] ram_hrdata;
  wire        ram_hreadyout;
  wire  [1:0] ram_hresp;

  wire        mtx2_hsel;
  wire [31:0] mtx2_haddr;
  wire  [1:0] mtx2_htrans;
  wire        mtx2_hwrite;
  wire  [2:0] mtx2_hsize;
  wire  [2:0] mtx2_hburst;
  wire  [3:0] mtx2_hprot;
  wire [31:0] mtx2_hwdata;
  wire        mtx2_hready;
  wire [31:0] mtx2_hrdata;
  wire        mtx2_hreadyout;
  wire  [1:0] mtx2_hresp;

  wire        syncup_hsel;
  wire [31:0] syncup_haddr;
  wire  [1:0] syncup_htrans;
  wire        syncup_hwrite;
  wire  [2:0] syncup_hsize;
  wire  [2:0] syncup_hburst;
  wire  [3:0] syncup_hprot;
  wire [31:0] syncup_hwdata;
  wire [31:0] syncup_hrdata;
  wire        syncup_hreadyout;
  wire        syncup_hready;
  wire        syncup_hresp;

  wire [31:0] syncup_nic_haddr;
  wire  [1:0] syncup_nic_htrans;
  wire        syncup_nic_hwrite;
  wire  [2:0] syncup_nic_hsize;
  wire  [2:0] syncup_nic_hburst;
  wire  [3:0] syncup_nic_hprot;
  wire [31:0] syncup_nic_hwdata;
  wire [31:0] syncup_nic_hrdata;
  wire        syncup_nic_hready;
  wire        syncup_nic_hresp;

  wire        cad_hsel;
  wire [31:0] cad_haddr;
  wire  [1:0] cad_htrans;
  wire        cad_hwrite;
  wire  [2:0] cad_hsize;
  wire        cad_hnonsec;
  wire        cad_hmastlock;
  wire  [2:0] cad_hburst;
  wire  [3:0] cad_hprot;
  wire  [3:0] cad_hmaster;
  wire [31:0] cad_hwdata;
  wire [31:0] cad_hrdata;
  wire        cad_hreadyout;
  wire        cad_hready;
  wire        cad_hresp;
  
  wire [31:0] cac_haddr;
  wire  [1:0] cac_htrans;
  wire        cac_hwrite;
  wire  [2:0] cac_hsize;
  wire  [2:0] cac_hburst;
  wire  [3:0] cac_hprot;
  wire  [3:0] cac_hmaster;
  wire [31:0] cac_hwdata;
  wire [31:0] cac_hrdata;
  wire        cac_hready;
  wire        cac_hresp;  
  
  wire        syncdown_hsel;
  wire [31:0] syncdown_haddr;
  wire  [1:0] syncdown_htrans;
  wire        syncdown_hwrite;
  wire  [2:0] syncdown_hsize;
  wire  [2:0] syncdown_hburst;
  wire  [3:0] syncdown_hprot;
  wire [31:0] syncdown_hwdata;
  wire        syncdown_hready;
  wire [31:0] syncdown_hrdata;
  wire        syncdown_hreadyout;
  wire        syncdown_hresp;
  wire  [1:0] syncdown_hauser;

  wire [31:0] initca_haddr;
  wire  [2:0] initca_hburst;
  wire        initca_hmastlock;
  wire  [3:0] initca_hprot;
  wire  [2:0] initca_hsize;
  wire  [1:0] initca_htrans;
  wire [31:0] initca_hwdata;
  wire        initca_hwrite;
  wire [31:0] initca_hrdata;
  wire        initca_hready;
  wire  [1:0] initca_hresp;

  wire        periph_hsel;
  wire [31:0] periph_haddr;
  wire  [1:0] periph_htrans;
  wire        periph_hwrite;
  wire  [2:0] periph_hsize;
  wire  [3:0] periph_hprot;
  wire [31:0] periph_hwdata;
  wire        periph_hready;
  wire [31:0] periph_hrdata;
  wire        periph_hreadyout;
  wire  [1:0] periph_hresp;

  wire        debug_hsel;
  wire [31:0] debug_haddr;
  wire  [1:0] debug_htrans;
  wire        debug_hwrite;
  wire        debug_hmastlock;
  wire  [2:0] debug_hsize;
  wire  [2:0] debug_hburst;
  wire  [3:0] debug_hprot;
  wire [31:0] debug_hwdata;
  wire        debug_hready;
  wire [31:0] debug_hrdata;
  wire        debug_hreadyout;
  wire  [1:0] debug_hresp;

  wire         fctlr_arid;
  wire  [31:0] fctlr_araddr;
  wire  [7:0]  fctlr_arlen;
  wire  [2:0]  fctlr_arsize;
  wire  [1:0]  fctlr_arburst;
  wire         fctlr_arlock;
  wire  [3:0]  fctlr_arcache;
  wire  [2:0]  fctlr_arprot;
  wire  [3:0]  fctlr_arqos;
  wire  [3:0]  fctlr_arregion;
  wire         fctlr_arvalid;
  wire         fctlr_arready;
  wire         fctlr_awid;
  wire [31:0]  fctlr_awaddr;
  wire  [7:0]  fctlr_awlen;
  wire  [2:0]  fctlr_awsize;
  wire  [1:0]  fctlr_awburst;
  wire         fctlr_awlock;
  wire  [3:0]  fctlr_awcache;
  wire  [2:0]  fctlr_awprot;
  wire  [3:0]  fctlr_awqos;
  wire  [3:0]  fctlr_awregion;
  wire         fctlr_awvalid;
  wire         fctlr_awready;
  wire [31:0]  fctlr_wdata;
  wire  [3:0]  fctlr_wstrb;
  wire         fctlr_wlast;
  wire         fctlr_wvalid;
  wire         fctlr_wready;
  wire         fctlr_bid;
  wire  [1:0]  fctlr_bresp;
  wire  [1:0]  fctlr_buser;
  wire         fctlr_bvalid;
  wire         fctlr_bready;
  wire         fctlr_rid;
  wire [31:0]  fctlr_rdata;
  wire  [1:0]  fctlr_rresp;
  wire         fctlr_rlast;
  wire         fctlr_rvalid;
  wire         fctlr_rready;

  wire         fcomp_arid;
  wire [31:0]  fcomp_araddr;
  wire  [7:0]  fcomp_arlen;
  wire  [2:0]  fcomp_arsize;
  wire  [1:0]  fcomp_arburst;
  wire         fcomp_arlock;
  wire  [3:0]  fcomp_arcache;
  wire  [2:0]  fcomp_arprot;
  wire  [2:0]  fcomp_arprot_int;
  wire  [3:0]  fcomp_arqos;
  wire  [3:0]  fcomp_arregion;
  wire         fcomp_arvalid;
  wire         fcomp_arready;
  wire  [1:0]  fcomp_aruser;
  wire         fcomp_awid;
  wire [31:0]  fcomp_awaddr;
  wire  [7:0]  fcomp_awlen;
  wire  [2:0]  fcomp_awsize;
  wire  [1:0]  fcomp_awburst;
  wire         fcomp_awlock;
  wire  [3:0]  fcomp_awcache;
  wire  [2:0]  fcomp_awprot;
  wire  [2:0]  fcomp_awprot_int;
  wire  [3:0]  fcomp_awqos;
  wire  [3:0]  fcomp_awregion;
  wire         fcomp_awvalid;
  wire         fcomp_awready;
  wire  [1:0]  fcomp_awuser;
  wire [31:0]  fcomp_wdata;
  wire  [3:0]  fcomp_wstrb;
  wire         fcomp_wlast;
  wire         fcomp_wvalid;
  wire         fcomp_wready;
  wire         fcomp_bid;
  wire  [1:0]  fcomp_bresp;
  wire  [1:0]  fcomp_buser;
  wire         fcomp_bvalid;
  wire         fcomp_bready;
  wire         fcomp_rid;
  wire [31:0]  fcomp_rdata;
  wire  [1:0]  fcomp_rresp;
  wire         fcomp_rlast;
  wire         fcomp_rvalid;
  wire         fcomp_rready;

  wire        clk;          
  wire        fclk;         
  wire        cryptoclkout;
  wire        cryptoresetn;
  wire        fclken;       

  wire        hclk;
  wire        hclk_en;
  wire        gate_hclk;

  wire        k32_clk;   
  wire        k32_rst_n; 

  wire        m0_dbgrstn;

  wire        timer0_irq;
  wire        timer1_irq;
  wire        wdog_irq;
  wire        mhu0r_cirq;
  wire        mhu0s_cirq;
  wire        mhu1r_cirq;
  wire        mhu1s_cirq;
  wire        se_fw_irq;

  wire [25:0] st_calib;
  wire        st_clken;

  wire [27:0] ecorevnum;

  wire        sleep_deep;
  wire        sleep_hold_reqn;
  wire        sleep_hold_ackn;

  wire        m0_halted;
  reg         m0_halted_s;

  wire        wdog_rst_req_int;
  reg         wdog_rst_req_int_s;

  reg         dbgen_cm0;
  reg         niden_cm0;

  wire [1:0]  cti_int;

  wire [3:0]  cti_cha_to_secenc_int;
  wire [3:0]  cti_secenc_to_cha_int;

  wire dftcgen_or_mbistreq;

  wire        unused;


  assign clk            = SECENCDIVCLK;               
  assign fclk           = SECENCCLK;                  
  assign cryptoclkout   = SECENCCLK;                  
  assign m0_dbgrstn     = SECENCPORESETn;             
  assign cryptoresetn   = SECENCWARMRESETn_SECENCCLK; 

  assign hclk_en = ~(gate_hclk) | DCLKEN | ~ca_idle;
  
  sec_or_tree #(
    .NUM_OR_TREE_INPUTS (2)
  ) u_sec_or_tree (
    .or_tree_i  ({DFTCGEN, MBISTREQ}),
    .or_tree_o  (dftcgen_or_mbistreq)
  );

  sec_clock_gate u_sec_clock_gate_0 (
      .clk_in  (clk),
      .enable  (hclk_en),
      .dftcgen (dftcgen_or_mbistreq),
      .clk_out (hclk)
      );

  assign k32_clk   = S32KCLK_SECENC; 
  assign k32_rst_n = K32WARMRESETn;  


  sec_cm0p_pwrq u_sec_cm0p_pwrq (
    .clk                (clk),
    .rst_n              (SECENCWARMRESETn_SECENCDIVCLK),
    .cm0_qreqn          (CM0_QREQn),
    .cm0_qacceptn       (CM0_QACCEPTn),
    .cm0_qdeny          (CM0_QDENY),
    .cm0_qactive        (CM0_QACTIVE),
    .sleep_deep         (sleep_deep),
    .sleep_hold_reqn    (sleep_hold_reqn),
    .sleep_hold_ackn    (sleep_hold_ackn)
  );


  assign m0_irq[31:29] = 3'b0;          
  assign m0_irq[28]    = mhu1r_cirq;    
  assign m0_irq[27]    = 1'b0;          
  assign m0_irq[26]    = mhu1s_cirq;    
  assign m0_irq[25:24] = 2'b0;          
  assign m0_irq[23]    = mhu0r_cirq;    
  assign m0_irq[22]    = 1'b0;          
  assign m0_irq[21]    = mhu0s_cirq;    
  assign m0_irq[20:15] = 6'b0;          
  assign m0_irq[14:13] = cti_int;       
  assign m0_irq[12]    = se_fw_irq;     
  assign m0_irq[11]    = UART_IRQ;      
  assign m0_irq[10]    = PPU_IRQ;       
  assign m0_irq[9]     = SWD_WS1_IRQ;   
  assign m0_irq[8]     = INT_RTT_IRQ;   
  assign m0_irq[7]     = HOST_FWT_IRQ;  
  assign m0_irq[6]     = timer1_irq;    
  assign m0_irq[5]     = timer0_irq;    
  assign m0_irq[4]     = 1'b0;          
  assign m0_irq[3]     = wdog_irq;      
  assign m0_irq[2]     = 1'b0;          
  assign m0_irq[1]     = crypto_int;    
  assign m0_irq[0]     = CO_IRQ;        


  sec_systick u_sec_systick (
    .s32k_clk           (k32_clk),
    .s32k_rstn          (k32_rst_n),
    .st_clk             (clk),
    .st_rstn            (SECENCWARMRESETn_SECENCDIVCLK),
    .st_clken           (st_clken)
  );

  assign st_calib[25]   = 1'b0;
  assign st_calib[24]   = 1'b1;
  assign st_calib[23:0] = 24'h147;


 CORTEXM0PLUSINTEGRATIONCS #(
    .ACG                (1),
    .BE                 (0),
    .BKPT               (4),
    .HWF                (0),
    .IOP                (0),
    .IRQDIS             (32'hEB5F_8014), 
    .MPU                (8),
    .NUMIRQ             (32),
    .RAR                (1),
    .SMUL               (1),
    .SYST               (1),
    .USER               (1),
    .VTOR               (1),
    .WIC                (0), 
    .WICLINES           (2),
    .WPT                (2),
    .CTI                (1),
    .AWIDTH             (32),
    .MTB                (0)
  ) u_CORTEXM0PLUSINTEGRATIONCS (
    .FCLK               (clk),
    .SCLK               (clk), 
    .HCLK               (hclk),
    .DCLK               (DCLK),
    .DBGRESETn          (m0_dbgrstn),
    .HRESETn            (SECENCWARMRESETn_SECENCDIVCLK),
    .HADDR              (m0_haddr),
    .HBURST             (m0_hburst),
    .HMASTLOCK          (m0_hmastlock),
    .HPROT              (m0_hprot),
    .HSIZE              (m0_hsize),
    .HTRANS             (m0_htrans),
    .HWDATA             (m0_hwdata),
    .HWRITE             (m0_hwrite),
    .HRDATA             (m0_hrdata),
    .HREADY             (m0_hready),
    .HRESP              (m0_hresp[0]),
    .HMASTER            (m0_hmaster),
    .SHAREABLE          (),
    .HADDRDCS           (debug_haddr),
    .HBURSTDCS          (debug_hburst),
    .HMASTLOCKDCS       (debug_hmastlock),
    .HPROTDCS           (debug_hprot),
    .HSIZEDCS           (debug_hsize),
    .HTRANSDCS          (debug_htrans),
    .HWDATADCS          (debug_hwdata),
    .HWRITEDCS          (debug_hwrite),
    .HRDATADCS          (debug_hrdata),
    .HREADYDCS          (debug_hready),
    .HRESPDCS           (debug_hresp[0]),
    .HREADYOUTDCS       (debug_hreadyout),
    .HSELDCS            (debug_hsel),
    .CTICHIN            (cti_cha_to_secenc_int),
    .CTICHOUT           (cti_secenc_to_cha_int),
    .CTIIRQ             (cti_int),
    .MTBSRAMBASE        (32'b0),
    .RAMHCLK            (),
    .RAMRD              (32'h0),
    .RAMAD              (),
    .RAMWD              (),
    .RAMCS              (),
    .RAMWE              (),
    .TSTART             (1'b0),
    .TSTOP              (1'b0),
    .CODENSEQ           (),
    .CODEHINT           (),
    .SPECHTRANS         (),
    .DATAHINT           (),
    .HADDREDS           (AP_HADDR),
    .HPROTEDS           (AP_HPROT),
    .HBURSTEDS          (AP_HBURST),
    .HSIZEEDS           ({1'b0, AP_HSIZE}),
    .HTRANSEDS          (AP_HTRANS),
    .HWDATAEDS          (AP_HWDATA),
    .HWRITEEDS          (AP_HWRITE),
    .HRDATAEDS          (AP_HRDATA),
    .HREADYEDS          (AP_HREADY),
    .HMASTLOCKEDS       (1'b0),
    .HRESPEDS           (AP_HRESP),
    .EDBGRQ             (1'b0),
    .HALTED             (m0_halted),
    .NIDEN              (niden_cm0),
    .DBGEN              (dbgen_cm0),
    .NMI                (SOC_WD_IRQ),
    .IRQ                (m0_irq),
    .TXEV               (),
    .RXEV               (1'b0),
    .LOCKUP             (),
    .SYSRESETREQ        (M0_SRST_REQ),
    .STCALIB            (st_calib),
    .STCLKEN            (st_clken),
    .IRQLATENCY         (8'b0),
    .ECOREVNUM          ({4'h0, ecorevnum}), 
    .CPUWAIT            (CPUWAIT),
    .SLVSTALL           (1'b0),
    .GATEHCLK           (gate_hclk),
    .SLEEPING           (),
    .SLEEPDEEP          (sleep_deep),
    .WAKEUP             (),
    .WICSENSE           (),
    .SLEEPHOLDREQn      (sleep_hold_reqn),
    .SLEEPHOLDACKn      (sleep_hold_ackn),
    .WICENREQ           (1'b0), 
    .WICENACK           (),
    .IOMATCH            (1'b0),
    .IORDATA            (32'h00000000),
    .IOTRANS            (),
    .IOWRITE            (),
    .IOCHECK            (),
    .IOADDR             (),
    .IOSIZE             (),
    .IOMASTER           (),
    .IOPRIV             (),
    .IOWDATA            (),
    .DFTSE              (DFTCGEN),
    .SYSRETAINn         (1'b0),
    .SYSISOLATEn        (1'b0),
    .SYSPWRDOWN         (1'b0),
    .SYSPWRDOWNACK      (),
    .DBGISOLATEn        (1'b0),
    .DBGPWRDOWN         (1'b0),
    .DBGPWRDOWNACK      ()
  );

  always @(posedge clk or negedge m0_dbgrstn)
  begin
    if(!m0_dbgrstn)
      begin
        dbgen_cm0 <= 1'b0;
        niden_cm0 <= 1'b0;
      end
    else if (m0_hready)
      begin
        dbgen_cm0 <= DBGEN;
        niden_cm0 <= NIDEN;
      end
  end

  sec_ecorevnum #(
    .WIDTH     (28),
    .ECOREVVAL (28'b0)
  ) u_sec_ecorevnum_0 (
    .ecorevnum (ecorevnum)
  );


  always @(posedge clk or negedge m0_dbgrstn)
  begin
    if(!m0_dbgrstn)
      m0_halted_s <= 1'b0;
    else
      m0_halted_s <= m0_halted;
  end

  assign HALTED = m0_halted_s;


  cm0p_mtx u_cm0p_mtx (
    .HCLK                   (hclk),
    .HRESETn                (SECENCWARMRESETn_SECENCDIVCLK),

    .REMAP                  (4'b0000),

    .HSELINITCM0            (1'b1),
    .HADDRINITCM0           (m0_haddr),
    .HTRANSINITCM0          (m0_htrans),
    .HWRITEINITCM0          (m0_hwrite),
    .HSIZEINITCM0           (m0_hsize),
    .HBURSTINITCM0          (m0_hburst),
    .HPROTINITCM0           (m0_hprot),
    .HMASTERINITCM0         ({3'b000, m0_hmaster}),
    .HWDATAINITCM0          (m0_hwdata),
    .HMASTLOCKINITCM0       (m0_hmastlock),
    .HREADYINITCM0          (m0_hready),
    .HAUSERINITCM0          (2'b00),
    .HWUSERINITCM0          (2'b00),

    .HSELINITCA             (1'b1),
    .HADDRINITCA            (initca_haddr),
    .HTRANSINITCA           (initca_htrans),
    .HWRITEINITCA           (initca_hwrite),
    .HSIZEINITCA            (initca_hsize),
    .HBURSTINITCA           (initca_hburst),
    .HPROTINITCA            (initca_hprot),
    .HMASTERINITCA          (4'b000),
    .HWDATAINITCA           (initca_hwdata),
    .HMASTLOCKINITCA        (initca_hmastlock),
    .HREADYINITCA           (initca_hready),
    .HAUSERINITCA           (2'b00),
    .HWUSERINITCA           (2'b00),

    .HRDATATARGROM          (rom_hrdata),
    .HREADYOUTTARGROM       (rom_hreadyout),
    .HRESPTARGROM           (rom_hresp),
    .HRUSERTARGROM          (2'b00),

    .HRDATATARGRAM          (ram_hrdata),
    .HREADYOUTTARGRAM       (ram_hreadyout),
    .HRESPTARGRAM           (ram_hresp),
    .HRUSERTARGRAM          (2'b00),

    .HRDATATARGCRYPTO       (mtx2_hrdata),
    .HREADYOUTTARGCRYPTO    (mtx2_hreadyout),
    .HRESPTARGCRYPTO        (mtx2_hresp),
    .HRUSERTARGCRYPTO       (2'b00),

    .HRDATATARGPERIPH       (periph_hrdata),
    .HREADYOUTTARGPERIPH    (periph_hreadyout),
    .HRESPTARGPERIPH        (periph_hresp),
    .HRUSERTARGPERIPH       (2'b00),

    .HRDATATARGDEBUG         (debug_hrdata),
    .HREADYOUTTARGDEBUG      (debug_hreadyout),
    .HRESPTARGDEBUG          (debug_hresp),
    .HRUSERTARGDEBUG         (2'b00),

    .SCANENABLE             (1'b0), 
    .SCANINHCLK             (1'b0), 

    .HSELTARGROM            (rom_hsel),
    .HADDRTARGROM           (rom_haddr),
    .HTRANSTARGROM          (rom_htrans),
    .HWRITETARGROM          (rom_hwrite),
    .HSIZETARGROM           (rom_hsize),
    .HBURSTTARGROM          (),
    .HPROTTARGROM           (),
    .HMASTERTARGROM         (),
    .HWDATATARGROM          (rom_hwdata),
    .HMASTLOCKTARGROM       (),
    .HREADYMUXTARGROM       (rom_hready),
    .HAUSERTARGROM          (),
    .HWUSERTARGROM          (),

    .HSELTARGRAM            (ram_hsel),
    .HADDRTARGRAM           (ram_haddr),
    .HTRANSTARGRAM          (ram_htrans),
    .HWRITETARGRAM          (ram_hwrite),
    .HSIZETARGRAM           (ram_hsize),
    .HBURSTTARGRAM          (),
    .HPROTTARGRAM           (),
    .HMASTERTARGRAM         (),
    .HWDATATARGRAM          (ram_hwdata),
    .HMASTLOCKTARGRAM       (),
    .HREADYMUXTARGRAM       (ram_hready),
    .HAUSERTARGRAM          (),
    .HWUSERTARGRAM          (),

    .HSELTARGCRYPTO         (mtx2_hsel),
    .HADDRTARGCRYPTO        (mtx2_haddr),
    .HTRANSTARGCRYPTO       (mtx2_htrans),
    .HWRITETARGCRYPTO       (mtx2_hwrite),
    .HSIZETARGCRYPTO        (mtx2_hsize),
    .HBURSTTARGCRYPTO       (mtx2_hburst),
    .HPROTTARGCRYPTO        (mtx2_hprot),
    .HMASTERTARGCRYPTO      (),
    .HWDATATARGCRYPTO       (mtx2_hwdata),
    .HMASTLOCKTARGCRYPTO    (),
    .HREADYMUXTARGCRYPTO    (mtx2_hready),
    .HAUSERTARGCRYPTO       (),
    .HWUSERTARGCRYPTO       (),

    .HSELTARGPERIPH         (periph_hsel),
    .HADDRTARGPERIPH        (periph_haddr),
    .HTRANSTARGPERIPH       (periph_htrans),
    .HWRITETARGPERIPH       (periph_hwrite),
    .HSIZETARGPERIPH        (periph_hsize),
    .HBURSTTARGPERIPH       (),
    .HPROTTARGPERIPH        (periph_hprot),
    .HMASTERTARGPERIPH      (),
    .HWDATATARGPERIPH       (periph_hwdata),
    .HMASTLOCKTARGPERIPH    (),
    .HREADYMUXTARGPERIPH    (periph_hready),
    .HAUSERTARGPERIPH       (),
    .HWUSERTARGPERIPH       (),

    .HSELTARGDEBUG           (debug_hsel),
    .HADDRTARGDEBUG          (debug_haddr),
    .HTRANSTARGDEBUG         (debug_htrans),
    .HWRITETARGDEBUG         (debug_hwrite),
    .HSIZETARGDEBUG          (debug_hsize),
    .HBURSTTARGDEBUG         (debug_hburst),
    .HPROTTARGDEBUG          (debug_hprot),
    .HMASTERTARGDEBUG        (),
    .HWDATATARGDEBUG         (debug_hwdata),
    .HMASTLOCKTARGDEBUG      (debug_hmastlock),
    .HREADYMUXTARGDEBUG      (debug_hready),
    .HAUSERTARGDEBUG         (),
    .HWUSERTARGDEBUG         (),

    .HRDATAINITCM0          (m0_hrdata),
    .HREADYOUTINITCM0       (m0_hready),
    .HRESPINITCM0           (m0_hresp),
    .HRUSERINITCM0          (),

    .HRDATAINITCA           (initca_hrdata),
    .HREADYOUTINITCA        (initca_hready),
    .HRESPINITCA            (initca_hresp),
    .HRUSERINITCA           (),

    .SCANOUTHCLK            ()
  );

  assign debug_hresp[1] = 1'b0;
  assign rom_hresp[1]   = 1'b0;
  assign mtx2_hresp[1]  = 1'b0;


  nic400_secenc_f1 u_nic400_secenc_f1 (

    .haddr_master_if3             (cac_haddr),
    .htrans_master_if3            (cac_htrans),
    .hwrite_master_if3            (cac_hwrite),
    .hsize_master_if3             (cac_hsize),
    .hburst_master_if3            (cac_hburst),
    .hprot_master_if3             (cac_hprot),
    .hwdata_master_if3            (cac_hwdata),
    .hrdata_master_if3            (cac_hrdata),
    .hready_master_if3            (cac_hready),
    .hresp_master_if3             (cac_hresp),

    .awid_master_if0             (fcomp_awid),
    .awaddr_master_if0           (fcomp_awaddr),
    .awlen_master_if0            (fcomp_awlen),
    .awsize_master_if0           (fcomp_awsize),
    .awburst_master_if0          (fcomp_awburst),
    .awlock_master_if0           (fcomp_awlock),
    .awcache_master_if0          (fcomp_awcache),
    .awprot_master_if0           (fcomp_awprot_int),
    .awvalid_master_if0          (fcomp_awvalid),
    .awready_master_if0          (fcomp_awready),
    .awuser_master_if0           (fcomp_awuser),
    .wdata_master_if0            (fcomp_wdata),
    .wstrb_master_if0            (fcomp_wstrb),
    .wlast_master_if0            (fcomp_wlast),
    .wvalid_master_if0           (fcomp_wvalid),
    .wready_master_if0           (fcomp_wready),
    .bid_master_if0              (fcomp_bid),
    .bresp_master_if0            (fcomp_bresp),
    .bvalid_master_if0           (fcomp_bvalid),
    .bready_master_if0           (fcomp_bready),
    .arid_master_if0             (fcomp_arid),
    .araddr_master_if0           (fcomp_araddr),
    .arlen_master_if0            (fcomp_arlen),
    .arsize_master_if0           (fcomp_arsize),
    .arburst_master_if0          (fcomp_arburst),
    .arlock_master_if0           (fcomp_arlock),
    .arcache_master_if0          (fcomp_arcache),
    .arprot_master_if0           (fcomp_arprot_int),
    .arvalid_master_if0          (fcomp_arvalid),
    .arready_master_if0          (fcomp_arready),
    .aruser_master_if0           (fcomp_aruser),
    .rid_master_if0              (fcomp_rid),
    .rdata_master_if0            (fcomp_rdata),
    .rresp_master_if0            (fcomp_rresp),
    .rlast_master_if0            (fcomp_rlast),
    .rvalid_master_if0           (fcomp_rvalid),
    .rready_master_if0           (fcomp_rready),
    
    .awaddr_master_if1           (fctlr_awaddr),
    .awlen_master_if1            (fctlr_awlen),
    .awsize_master_if1           (fctlr_awsize),
    .awburst_master_if1          (fctlr_awburst),
    .awlock_master_if1           (fctlr_awlock),
    .awcache_master_if1          (fctlr_awcache),
    .awprot_master_if1           (fctlr_awprot),
    .awvalid_master_if1          (fctlr_awvalid),
    .awready_master_if1          (fctlr_awready),
    .wdata_master_if1            (fctlr_wdata),
    .wstrb_master_if1            (fctlr_wstrb),
    .wlast_master_if1            (fctlr_wlast),
    .wvalid_master_if1           (fctlr_wvalid),
    .wready_master_if1           (fctlr_wready),
    .bresp_master_if1            (fctlr_bresp),
    .bvalid_master_if1           (fctlr_bvalid),
    .bready_master_if1           (fctlr_bready),
    .araddr_master_if1           (fctlr_araddr),
    .arlen_master_if1            (fctlr_arlen),
    .arsize_master_if1           (fctlr_arsize),
    .arburst_master_if1          (fctlr_arburst),
    .arlock_master_if1           (fctlr_arlock),
    .arcache_master_if1          (fctlr_arcache),
    .arprot_master_if1           (fctlr_arprot),
    .arvalid_master_if1          (fctlr_arvalid),
    .arready_master_if1          (fctlr_arready),
    .rdata_master_if1            (fctlr_rdata),
    .rresp_master_if1            (fctlr_rresp),
    .rlast_master_if1            (fctlr_rlast),
    .rvalid_master_if1           (fctlr_rvalid),
    .rready_master_if1           (fctlr_rready),

    .hselx_master_if2            (syncdown_hsel),
    .haddr_master_if2            (syncdown_haddr),
    .htrans_master_if2           (syncdown_htrans),
    .hwrite_master_if2           (syncdown_hwrite),
    .hsize_master_if2            (syncdown_hsize),
    .hburst_master_if2           (syncdown_hburst),
    .hprot_master_if2            (syncdown_hprot),
    .hwdata_master_if2           (syncdown_hwdata),
    .hrdata_master_if2           (syncdown_hrdata),
    .hreadyout_master_if2        (syncdown_hreadyout),
    .hready_master_if2           (syncdown_hready),
    .hresp_master_if2            (syncdown_hresp),
    .hauser_master_if2           (syncdown_hauser),

    .haddr_slave_if0             (syncup_nic_haddr),
    .htrans_slave_if0            (syncup_nic_htrans),
    .hwrite_slave_if0            (syncup_nic_hwrite),
    .hsize_slave_if0             (syncup_nic_hsize),
    .hburst_slave_if0            (syncup_nic_hburst),
    .hprot_slave_if0             (syncup_nic_hprot),
    .hwdata_slave_if0            (syncup_nic_hwdata),
    .hrdata_slave_if0            (syncup_nic_hrdata),
    .hready_slave_if0            (syncup_nic_hready),
    .hresp_slave_if0             (syncup_nic_hresp),

    .hselx_slave_if1             (cad_hsel),
    .haddr_slave_if1             (cad_haddr),
    .htrans_slave_if1            (cad_htrans),
    .hwrite_slave_if1            (cad_hwrite),
    .hsize_slave_if1             (cad_hsize),
    .hburst_slave_if1            (cad_hburst),
    .hprot_slave_if1             (cad_hprot),
    .hwdata_slave_if1            (cad_hwdata),
    .hreadyout_slave_if1         (cad_hreadyout),
    .hrdata_slave_if1            (cad_hrdata),
    .hready_slave_if1            (cad_hready),
    .hresp_slave_if1             (cad_hresp),
    .hauser_slave_if1            ({cad_hmastlock, cad_hnonsec}),

    .clk0clk                     (fclk),
    .clk0resetn                  (SECENCWARMRESETn_SECENCCLK)

  );

  assign fctlr_awid     = 1'b0;
  assign fctlr_awqos    = 4'b0000;
  assign fctlr_awregion = 4'b0000;
  assign fctlr_arid     = 1'b0;
  assign fctlr_arqos    = 4'b0000;
  assign fctlr_arregion = 4'b0000;

  assign fcomp_awqos    = 4'b0000;
  assign fcomp_awregion = 4'b0000;
  assign fcomp_arqos    = 4'b0000;
  assign fcomp_arregion = 4'b0000;
  
  assign fcomp_awprot[2] = fcomp_awprot_int[2];
  assign fcomp_awprot[1] = fcomp_awprot_int[1] | fcomp_awuser[0];
  assign fcomp_awprot[0] = fcomp_awprot_int[0];

  assign fcomp_arprot[2] = fcomp_arprot_int[2];
  assign fcomp_arprot[1] = fcomp_arprot_int[1] | fcomp_aruser[0];
  assign fcomp_arprot[0] = fcomp_arprot_int[0];
  

  channel_gate_f0 u_channel_gate_f0 (

    .channel_pulse_slave_0  (CTI_CHA_TO_SECENC),
    .channel_pulse_master_0 (CTI_SECENC_TO_CHA),

    .channel_pulse_slave_1  (cti_secenc_to_cha_int),
    .channel_pulse_master_1 (cti_cha_to_secenc_int),

    .chen                   (CHEN)
  );


  sec_mem_integration #(
    .RAM_AW          (RAM_AW),
    .ROM_AW          (ROM_AW)
  ) u_sec_mem_integration (
    .HCLK            (hclk),
    .HRESETn         (SECENCWARMRESETn_SECENCDIVCLK),
    .RAM_HSEL        (ram_hsel),
    .RAM_HREADY      (ram_hready),
    .RAM_HTRANS      (ram_htrans),
    .RAM_HSIZE       (ram_hsize),
    .RAM_HWRITE      (ram_hwrite),
    .RAM_HADDR       (ram_haddr[RAM_AW-1:0]),
    .RAM_HWDATA      (ram_hwdata),
    .RAM_HREADYOUT   (ram_hreadyout),
    .RAM_HRESP       (ram_hresp[0]),
    .RAM_HRDATA      (ram_hrdata),

    .ROM_HSEL        (rom_hsel),
    .ROM_HREADY      (rom_hready),
    .ROM_HTRANS      (rom_htrans),
    .ROM_HSIZE       (rom_hsize),
    .ROM_HWRITE      (rom_hwrite),
    .ROM_HADDR       (rom_haddr[ROM_AW-1:0]),
    .ROM_HWDATA      (rom_hwdata),
    .ROM_HREADYOUT   (rom_hreadyout),
    .ROM_HRESP       (rom_hresp[0]),
    .ROM_HRDATA      (rom_hrdata),
    .DFTRAMHOLD      (DFTRAMHOLD)
  );

  assign ram_hresp[1] = 1'b0;


  sec_periph_integration #(
    .MHU_SEES00_NUM_CH  (MHU_SEES00_NUM_CH),
    .MHU_ES0SE0_NUM_CH  (MHU_ES0SE0_NUM_CH),
      .MHU_SEES01_NUM_CH  (MHU_SEES01_NUM_CH),
    .MHU_ES0SE1_NUM_CH  (MHU_ES0SE1_NUM_CH),
      .MHU_SEES10_NUM_CH  (MHU_SEES10_NUM_CH),
    .MHU_ES1SE0_NUM_CH  (MHU_ES1SE0_NUM_CH),
      .MHU_SEES11_NUM_CH  (MHU_SEES11_NUM_CH),
    .MHU_ES1SE1_NUM_CH  (MHU_ES1SE1_NUM_CH),
      .MHU_HSE0_NUM_CH            (MHU_HSE0_NUM_CH),
    .MHU_SEH0_NUM_CH            (MHU_SEH0_NUM_CH),
    .MHU_HSE1_NUM_CH            (MHU_HSE1_NUM_CH),
    .MHU_SEH1_NUM_CH            (MHU_SEH1_NUM_CH)
  ) u_sec_periph_integration (
    .clk                        (clk),
    .rst_n                      (SECENCWARMRESETn_SECENCDIVCLK),
    .m0_halted                  (m0_halted),
    .periph_hsel                (periph_hsel),
    .periph_haddr               (periph_haddr),
    .periph_hprot               (periph_hprot),
    .periph_hsize               (periph_hsize),
    .periph_htrans              (periph_htrans),
    .periph_hwdata              (periph_hwdata),
    .periph_hready              (periph_hready),
    .periph_hwrite              (periph_hwrite),
    .periph_hrdata              (periph_hrdata),
    .periph_hreadyout           (periph_hreadyout),
    .periph_hresp               (periph_hresp),
    .aon_psel                   (AON_PSEL),
    .aon_penable                (AON_PENABLE),
    .aon_paddr                  (AON_PADDR),
    .aon_pwrite                 (AON_PWRITE),
    .aon_pwdata                 (AON_PWDATA),
    .aon_pready                 (AON_PREADY),
    .aon_prdata                 (AON_PRDATA),
    .aon_pslverr                (AON_PSLVERR),
    .socwd_psel                 (SOCWD_PSEL),
    .socwd_penable              (SOCWD_PENABLE),
    .socwd_paddr                (SOCWD_PADDR),
    .socwd_pwrite               (SOCWD_PWRITE),
    .socwd_pwdata               (SOCWD_PWDATA),
    .socwd_pready               (SOCWD_PREADY),
    .socwd_prdata               (SOCWD_PRDATA),
    .socwd_pslverr              (SOCWD_PSLVERR),
    .mhu0r_async_req            (MHU0R_ASYNC_REQ),
    .mhu0r_async_req_payload    (MHU0R_ASYNC_REQ_PAYLOAD),
    .mhu0r_async_resp_payload   (MHU0R_ASYNC_RESP_PAYLOAD),
    .mhu0r_async_ack            (MHU0R_ASYNC_ACK),
    .mhu0r_recawake_async       (MHU0R_RECAWAKE_ASYNC),
    .mhu0r_recwakeup_async      (MHU0R_RECWAKEUP_ASYNC),
    .mhu0r_edge_async_req       (MHU0R_EDGE_ASYNC_REQ),
    .mhu0r_edge_async_ack       (MHU0R_EDGE_ASYNC_ACK),
    .mhu0s_async_req            (MHU0S_ASYNC_REQ),
    .mhu0s_async_req_payload    (MHU0S_ASYNC_REQ_PAYLOAD),
    .mhu0s_async_resp_payload   (MHU0S_ASYNC_RESP_PAYLOAD),
    .mhu0s_async_ack            (MHU0S_ASYNC_ACK),
    .mhu0s_recawake_async       (MHU0S_RECAWAKE_ASYNC),
    .mhu0s_recwakeup_async      (MHU0S_RECWAKEUP_ASYNC),
    .mhu0s_edge_async_req       (MHU0S_EDGE_ASYNC_REQ),
    .mhu0s_edge_async_ack       (MHU0S_EDGE_ASYNC_ACK),
    .mhu1r_async_req            (MHU1R_ASYNC_REQ),
    .mhu1r_async_req_payload    (MHU1R_ASYNC_REQ_PAYLOAD),
    .mhu1r_async_resp_payload   (MHU1R_ASYNC_RESP_PAYLOAD),
    .mhu1r_async_ack            (MHU1R_ASYNC_ACK),
    .mhu1r_recawake_async       (MHU1R_RECAWAKE_ASYNC),
    .mhu1r_recwakeup_async      (MHU1R_RECWAKEUP_ASYNC),
    .mhu1r_edge_async_req       (MHU1R_EDGE_ASYNC_REQ),
    .mhu1r_edge_async_ack       (MHU1R_EDGE_ASYNC_ACK),
    .mhu1s_async_req            (MHU1S_ASYNC_REQ),
    .mhu1s_async_req_payload    (MHU1S_ASYNC_REQ_PAYLOAD),
    .mhu1s_async_resp_payload   (MHU1S_ASYNC_RESP_PAYLOAD),
    .mhu1s_async_ack            (MHU1S_ASYNC_ACK),
    .mhu1s_recawake_async       (MHU1S_RECAWAKE_ASYNC),
    .mhu1s_recwakeup_async      (MHU1S_RECWAKEUP_ASYNC),
    .mhu1s_edge_async_req       (MHU1S_EDGE_ASYNC_REQ),
    .mhu1s_edge_async_ack       (MHU1S_EDGE_ASYNC_ACK),
    .mhu2r_async_req            (MHU2R_ASYNC_REQ),
    .mhu2r_async_req_payload    (MHU2R_ASYNC_REQ_PAYLOAD),
    .mhu2r_async_resp_payload   (MHU2R_ASYNC_RESP_PAYLOAD),
    .mhu2r_async_ack            (MHU2R_ASYNC_ACK),
    .mhu2r_recawake_async       (MHU2R_RECAWAKE_ASYNC),
    .mhu2r_recwakeup_async      (MHU2R_RECWAKEUP_ASYNC),
    .mhu2r_edge_async_req       (MHU2R_EDGE_ASYNC_REQ),
    .mhu2r_edge_async_ack       (MHU2R_EDGE_ASYNC_ACK),
    .mhu2s_async_req            (MHU2S_ASYNC_REQ),
    .mhu2s_async_req_payload    (MHU2S_ASYNC_REQ_PAYLOAD),
    .mhu2s_async_resp_payload   (MHU2S_ASYNC_RESP_PAYLOAD),
    .mhu2s_async_ack            (MHU2S_ASYNC_ACK),
    .mhu2s_recawake_async       (MHU2S_RECAWAKE_ASYNC),
    .mhu2s_recwakeup_async      (MHU2S_RECWAKEUP_ASYNC),
    .mhu2s_edge_async_req       (MHU2S_EDGE_ASYNC_REQ),
    .mhu2s_edge_async_ack       (MHU2S_EDGE_ASYNC_ACK),
      .mhu3r_async_req            (MHU3R_ASYNC_REQ),
    .mhu3r_async_req_payload    (MHU3R_ASYNC_REQ_PAYLOAD),
    .mhu3r_async_resp_payload   (MHU3R_ASYNC_RESP_PAYLOAD),
    .mhu3r_async_ack            (MHU3R_ASYNC_ACK),
    .mhu3r_recawake_async       (MHU3R_RECAWAKE_ASYNC),
    .mhu3r_recwakeup_async      (MHU3R_RECWAKEUP_ASYNC),
    .mhu3r_edge_async_req       (MHU3R_EDGE_ASYNC_REQ),
    .mhu3r_edge_async_ack       (MHU3R_EDGE_ASYNC_ACK),
    .mhu3s_async_req            (MHU3S_ASYNC_REQ),
    .mhu3s_async_req_payload    (MHU3S_ASYNC_REQ_PAYLOAD),
    .mhu3s_async_resp_payload   (MHU3S_ASYNC_RESP_PAYLOAD),
    .mhu3s_async_ack            (MHU3S_ASYNC_ACK),
    .mhu3s_recawake_async       (MHU3S_RECAWAKE_ASYNC),
    .mhu3s_recwakeup_async      (MHU3S_RECWAKEUP_ASYNC),
    .mhu3s_edge_async_req       (MHU3S_EDGE_ASYNC_REQ),
    .mhu3s_edge_async_ack       (MHU3S_EDGE_ASYNC_ACK),
      .mhu4r_async_req            (MHU4R_ASYNC_REQ),
    .mhu4r_async_req_payload    (MHU4R_ASYNC_REQ_PAYLOAD),
    .mhu4r_async_resp_payload   (MHU4R_ASYNC_RESP_PAYLOAD),
    .mhu4r_async_ack            (MHU4R_ASYNC_ACK),
    .mhu4r_recawake_async       (MHU4R_RECAWAKE_ASYNC),
    .mhu4r_recwakeup_async      (MHU4R_RECWAKEUP_ASYNC),
    .mhu4r_edge_async_req       (MHU4R_EDGE_ASYNC_REQ),
    .mhu4r_edge_async_ack       (MHU4R_EDGE_ASYNC_ACK),
    .mhu4s_async_req            (MHU4S_ASYNC_REQ),
    .mhu4s_async_req_payload    (MHU4S_ASYNC_REQ_PAYLOAD),
    .mhu4s_async_resp_payload   (MHU4S_ASYNC_RESP_PAYLOAD),
    .mhu4s_async_ack            (MHU4S_ASYNC_ACK),
    .mhu4s_recawake_async       (MHU4S_RECAWAKE_ASYNC),
    .mhu4s_recwakeup_async      (MHU4S_RECWAKEUP_ASYNC),
    .mhu4s_edge_async_req       (MHU4S_EDGE_ASYNC_REQ),
    .mhu4s_edge_async_ack       (MHU4S_EDGE_ASYNC_ACK),
      .mhu5r_async_req            (MHU5R_ASYNC_REQ),
    .mhu5r_async_req_payload    (MHU5R_ASYNC_REQ_PAYLOAD),
    .mhu5r_async_resp_payload   (MHU5R_ASYNC_RESP_PAYLOAD),
    .mhu5r_async_ack            (MHU5R_ASYNC_ACK),
    .mhu5r_recawake_async       (MHU5R_RECAWAKE_ASYNC),
    .mhu5r_recwakeup_async      (MHU5R_RECWAKEUP_ASYNC),
    .mhu5r_edge_async_req       (MHU5R_EDGE_ASYNC_REQ),
    .mhu5r_edge_async_ack       (MHU5R_EDGE_ASYNC_ACK),
    .mhu5s_async_req            (MHU5S_ASYNC_REQ),
    .mhu5s_async_req_payload    (MHU5S_ASYNC_REQ_PAYLOAD),
    .mhu5s_async_resp_payload   (MHU5S_ASYNC_RESP_PAYLOAD),
    .mhu5s_async_ack            (MHU5S_ASYNC_ACK),
    .mhu5s_recawake_async       (MHU5S_RECAWAKE_ASYNC),
    .mhu5s_recwakeup_async      (MHU5S_RECWAKEUP_ASYNC),
    .mhu5s_edge_async_req       (MHU5S_EDGE_ASYNC_REQ),
    .mhu5s_edge_async_ack       (MHU5S_EDGE_ASYNC_ACK),
      .mhu0_qreqn                 (MHU0_QREQn),
    .mhu0_qacceptn              (MHU0_QACCEPTn),
    .mhu0_qdeny                 (MHU0_QDENY),
    .mhu1_qreqn                 (MHU1_QREQn),
    .mhu1_qacceptn              (MHU1_QACCEPTn),
    .mhu1_qdeny                 (MHU1_QDENY),
    .mhu2_qreqn    (MHU2_QREQn),
    .mhu2_qacceptn (MHU2_QACCEPTn),
    .mhu2_qdeny    (MHU2_QDENY),
      .mhu3_qreqn    (MHU3_QREQn),
    .mhu3_qacceptn (MHU3_QACCEPTn),
    .mhu3_qdeny    (MHU3_QDENY),
      .mhu4_qreqn    (MHU4_QREQn),
    .mhu4_qacceptn (MHU4_QACCEPTn),
    .mhu4_qdeny    (MHU4_QDENY),
      .mhu5_qreqn    (MHU5_QREQn),
    .mhu5_qacceptn (MHU5_QACCEPTn),
    .mhu5_qdeny    (MHU5_QDENY),
      .timer0_irq                 (timer0_irq),
    .timer1_irq                 (timer1_irq),
    .wdog_irq                   (wdog_irq),
    .mhu0r_cirq                 (mhu0r_cirq),
    .mhu0s_cirq                 (mhu0s_cirq),
    .mhu1r_cirq                 (mhu1r_cirq),
    .mhu1s_cirq                 (mhu1s_cirq),
    
    .mhu2r_cirq                 (MHU2R_CIRQ),
    .mhu2s_cirq                 (MHU2S_CIRQ),
      .mhu3r_cirq                 (MHU3R_CIRQ),
    .mhu3s_cirq                 (MHU3S_CIRQ),
      
    .mhu4r_cirq                 (MHU4R_CIRQ),
    .mhu4s_cirq                 (MHU4S_CIRQ),
      .mhu5r_cirq                 (MHU5R_CIRQ),
    .mhu5s_cirq                 (MHU5S_CIRQ),
      .wdog_rst_req               (wdog_rst_req_int),
    .dft_cgen                   (DFTCGEN)
  );


  always @(posedge clk or negedge SECENCWARMRESETn_SECENCDIVCLK)
  begin
    if(!SECENCWARMRESETn_SECENCDIVCLK)
      wdog_rst_req_int_s <= 1'b0;
    else
      wdog_rst_req_int_s <= wdog_rst_req_int;
  end

  assign WDOG_RST_REQ = wdog_rst_req_int_s;


  generate
    if (AHB_SYNC_BRIDGE == 1) begin: gen_ahb_sync_1

      cmsdk_ahb_to_ahb_sync #(
        .AW    (32),  
        .DW    (32),  
        .MW    (1),   
        .BURST (0)    
      ) u_cmsdk_ahb_to_ahb_sync (
        .HCLK         (hclk),
        .HRESETn      (SECENCWARMRESETn_SECENCDIVCLK),
        .HSELS        (mtx2_hsel),
        .HADDRS       (mtx2_haddr),
        .HTRANSS      (mtx2_htrans),
        .HSIZES       (mtx2_hsize),
        .HWRITES      (mtx2_hwrite),
        .HREADYS      (mtx2_hready),
        .HPROTS       (mtx2_hprot),
        .HMASTERS     (1'b0),
        .HMASTLOCKS   (1'b0),
        .HWDATAS      (mtx2_hwdata),
        .HBURSTS      (mtx2_hburst),
        .HREADYOUTS   (mtx2_hreadyout),
        .HRESPS       (mtx2_hresp[0]),
        .HRDATAS      (mtx2_hrdata),
        .HADDRM       (syncup_haddr),
        .HTRANSM      (syncup_htrans),
        .HSIZEM       (syncup_hsize),
        .HWRITEM      (syncup_hwrite),
        .HPROTM       (syncup_hprot),
        .HMASTERM     (),
        .HMASTLOCKM   (),
        .HWDATAM      (syncup_hwdata),
        .HBURSTM      (syncup_hburst),
        .HREADYM      (syncup_hreadyout),
        .HRESPM       (syncup_hresp),
        .HRDATAM      (syncup_hrdata)
      );

      assign syncup_hready = syncup_hreadyout;
      assign syncup_hsel   = 1'b1;

    end else begin: gen_ahb_sync_0

       assign syncup_hsel    = mtx2_hsel;
       assign syncup_haddr   = mtx2_haddr;
       assign syncup_htrans  = mtx2_htrans;
       assign syncup_hsize   = mtx2_hsize;
       assign syncup_hwrite  = mtx2_hwrite;
       assign syncup_hprot   = mtx2_hprot;
       assign syncup_hwdata  = mtx2_hwdata;
       assign syncup_hburst  = mtx2_hburst;
       assign syncup_hready  = mtx2_hready;

       assign mtx2_hreadyout = syncup_hreadyout;
       assign mtx2_hresp[0]  = syncup_hresp;
       assign mtx2_hrdata    = syncup_hrdata;

    end
  endgenerate


  clkrst_f1_clkdiv_hintclkengen #(
    .PIPELINE_CORRECTION     (0) 
  ) u_clkrst_f1_clkdiv_hintclkengen (
    .fastclk        (fclk),
    .hintclken_clk  (SECENCHINTCLK),
    .resetn         (SECENCWARMRESETn), 
    .dftrstdisable  (DFTRSTDISABLE[0]),
    .dftmcphold     (DFTMCPHOLD),
    .clken          (fclken)
  );

  cmsdk_ahb_to_ahb_sync_up #(
    .AW                 (32),
    .DW                 (32),
    .MW                 (1), 
    .BURST              (0),
    .WB                 (0)  
  ) u_cmsdk_ahb_to_ahb_sync_up (
    .HCLK               (fclk),
    .HRESETn            (SECENCWARMRESETn_SECENCCLK),
    .HCLKEN             (fclken),
    .HSELS              (syncup_hsel),
    .HADDRS             (syncup_haddr),
    .HTRANSS            (syncup_htrans),
    .HSIZES             (syncup_hsize),
    .HWRITES            (syncup_hwrite),
    .HREADYS            (syncup_hready),
    .HPROTS             (syncup_hprot),
    .HMASTERS           (1'b0),
    .HMASTLOCKS         (1'b0),
    .HWDATAS            (syncup_hwdata),
    .HBURSTS            (syncup_hburst),
    .HREADYOUTS         (syncup_hreadyout),
    .HRESPS             (syncup_hresp),
    .HRDATAS            (syncup_hrdata),
    .BWERR              (),
    .HADDRM             (syncup_nic_haddr),
    .HTRANSM            (syncup_nic_htrans),
    .HSIZEM             (syncup_nic_hsize),
    .HWRITEM            (syncup_nic_hwrite),
    .HPROTM             (syncup_nic_hprot),
    .HMASTERM           (),
    .HMASTLOCKM         (),
    .HWDATAM            (syncup_nic_hwdata),
    .HBURSTM            (syncup_nic_hburst),
    .HREADYM            (syncup_nic_hready),
    .HRESPM             (syncup_nic_hresp),
    .HRDATAM            (syncup_nic_hrdata)
  );

  cmsdk_ahb_to_ahb_sync_down #(
    .AW    (32),
    .DW    (32),
    .MW    (1),  
    .BURST (1),  
    .WB    (0)   
  ) u_cmsdk_ahb_to_ahb_sync_down (
    .HCLK       (fclk),
    .HRESETn    (SECENCWARMRESETn_SECENCCLK),
    .HCLKEN     (fclken),
    .HSELS      (syncdown_hsel),
    .HADDRS     (syncdown_haddr),
    .HTRANSS    (syncdown_htrans),
    .HSIZES     (syncdown_hsize),
    .HWRITES    (syncdown_hwrite),
    .HREADYS    (syncdown_hready),
    .HPROTS     (syncdown_hprot),
    .HMASTERS   (1'b0),
    .HMASTLOCKS (syncdown_hauser[1]),
    .HWDATAS    (syncdown_hwdata),
    .HBURSTS    (syncdown_hburst),
    .HREADYOUTS (syncdown_hreadyout),
    .HRESPS     (syncdown_hresp),
    .HRDATAS    (syncdown_hrdata),
    .BWERR      (),
    .HADDRM     (initca_haddr),
    .HTRANSM    (initca_htrans),
    .HSIZEM     (initca_hsize),
    .HWRITEM    (initca_hwrite),
    .HPROTM     (initca_hprot),
    .HMASTERM   (),
    .HMASTLOCKM (initca_hmastlock),
    .HWDATAM    (initca_hwdata),
    .HBURSTM    (initca_hburst),
    .HREADYM    (initca_hready),
    .HRESPM     (initca_hresp[0]),
    .HRDATAM    (initca_hrdata)
  );


  crypto_accelerator #(
     .CAAON2CA_WIDTH    (CAAON2CA_WIDTH),
     .CA2CAAON_WIDTH    (CA2CAAON_WIDTH)
  ) u_crypto_accelerator (
    .CRYPTOCLKOUT       (cryptoclkout),
    .CRYPTORESETn       (cryptoresetn),
    
    .HSELCAD            (cad_hsel),
    .HADDRCAD           (cad_haddr),
    .HBURSTCAD          (cad_hburst),
    .HMASTLOCKCAD       (cad_hmastlock),
    .HPROTCAD           (cad_hprot),
    .HSIZECAD           (cad_hsize),
    .HNONSECCAD         (cad_hnonsec),
    .HTRANSCAD          (cad_htrans),
    .HWDATACAD          (cad_hwdata),
    .HWRITECAD          (cad_hwrite),
    .HREADYCAD          (cad_hready),
    .HRDATACAD          (cad_hrdata),
    .HREADYOUTCAD       (cad_hreadyout),
    .HRESPCAD           (cad_hresp),
    
    .HADDRCAC           (cac_haddr),
    .HBURSTCAC          (cac_hburst),
    .HMASTLOCKCAC       (1'b0),  
    .HPROTCAC           (cac_hprot),
    .HSIZECAC           (cac_hsize),
    .HTRANSCAC          (cac_htrans),
    .HWDATACAC          (cac_hwdata),
    .HWRITECAC          (cac_hwrite),
    .HREADYCAC          (cac_hready),
    .HRDATACAC          (cac_hrdata),
    .HRESPCAC           (cac_hresp),

    .CAAON2CA           (CAAON2CA),
    .CA2CAAON           (CA2CAAON),

    .CAINT              (crypto_int),
    
    .CAE                (CAE),

    .MBISTREQ           (MBISTREQ),
    .DFTCGEN            (DFTCGEN),
    .DFTRAMHOLD         (DFTRAMHOLD),
    .DFTRSTDISABLE      (DFTRSTDISABLE[1]),
    .DFTSE              (DFTSE),
    .DFTTESTMODE        (DFTTESTMODE)
  );
  
  assign ca_idle = 1'b1;


  sec_firewall u_secenc_f1_fw (
    .clk               (fclk),
    .rstn              (SECENCWARMRESETn_SECENCCLK),

    .fctlr_arid_s_i    (fctlr_arid),
    .fctlr_araddr_s_i  (fctlr_araddr),
    .fctlr_arlen_s_i   (fctlr_arlen),
    .fctlr_arsize_s_i  (fctlr_arsize),
    .fctlr_arburst_s_i (fctlr_arburst),
    .fctlr_arlock_s_i  (fctlr_arlock),
    .fctlr_arcache_s_i (fctlr_arcache),
    .fctlr_arprot_s_i  (fctlr_arprot),
    .fctlr_arqos_s_i   (fctlr_arqos),
    .fctlr_arregion_s_i(fctlr_arregion),
    .fctlr_aruser_s_i  (1'b0),
    .fctlr_arvalid_s_i (fctlr_arvalid),
    .fctlr_arready_s_o (fctlr_arready),
    .fctlr_awid_s_i    (fctlr_awid),
    .fctlr_awaddr_s_i  (fctlr_awaddr),
    .fctlr_awlen_s_i   (fctlr_awlen),
    .fctlr_awsize_s_i  (fctlr_awsize),
    .fctlr_awburst_s_i (fctlr_awburst),
    .fctlr_awlock_s_i  (fctlr_awlock),
    .fctlr_awcache_s_i (fctlr_awcache),
    .fctlr_awprot_s_i  (fctlr_awprot),
    .fctlr_awqos_s_i   (fctlr_awqos),
    .fctlr_awregion_s_i(fctlr_awregion),
    .fctlr_awuser_s_i  (1'b0),
    .fctlr_awvalid_s_i (fctlr_awvalid),
    .fctlr_awready_s_o (fctlr_awready),
    .fctlr_wdata_s_i   (fctlr_wdata),
    .fctlr_wstrb_s_i   (fctlr_wstrb),
    .fctlr_wlast_s_i   (fctlr_wlast),
    .fctlr_wuser_s_i   (1'b0),
    .fctlr_wvalid_s_i  (fctlr_wvalid),
    .fctlr_wready_s_o  (fctlr_wready),
    .fctlr_bid_s_o     (fctlr_bid),
    .fctlr_bresp_s_o   (fctlr_bresp),
    .fctlr_buser_s_o   (),
    .fctlr_bvalid_s_o  (fctlr_bvalid),
    .fctlr_bready_s_i  (fctlr_bready),
    .fctlr_rid_s_o     (fctlr_rid),
    .fctlr_rdata_s_o   (fctlr_rdata),
    .fctlr_rresp_s_o   (fctlr_rresp),
    .fctlr_rlast_s_o   (fctlr_rlast),
    .fctlr_ruser_s_o   (),
    .fctlr_rvalid_s_o  (fctlr_rvalid),
    .fctlr_rready_s_i  (fctlr_rready),

    .arid_s_i       (fcomp_arid),
    .araddr_s_i     (fcomp_araddr),
    .arlen_s_i      (fcomp_arlen),
    .arsize_s_i     (fcomp_arsize),
    .arburst_s_i    (fcomp_arburst),
    .arlock_s_i     (fcomp_arlock),
    .arcache_s_i    (fcomp_arcache),
    .arprot_s_i     (fcomp_arprot),
    .arqos_s_i      (fcomp_arqos),
    .arregion_s_i   (fcomp_arregion),
    .aruser_s_i     (1'b0),
    .arvalid_s_i    (fcomp_arvalid),
    .arready_s_o    (fcomp_arready),
    .awid_s_i       (fcomp_awid),
    .awaddr_s_i     (fcomp_awaddr),
    .awlen_s_i      (fcomp_awlen),
    .awsize_s_i     (fcomp_awsize),
    .awburst_s_i    (fcomp_awburst),
    .awlock_s_i     (fcomp_awlock),
    .awcache_s_i    (fcomp_awcache),
    .awprot_s_i     (fcomp_awprot),
    .awqos_s_i      (fcomp_awqos),
    .awregion_s_i   (fcomp_awregion),
    .awuser_s_i     (1'b0),
    .awvalid_s_i    (fcomp_awvalid),
    .awready_s_o    (fcomp_awready),
    .wdata_s_i      (fcomp_wdata),
    .wstrb_s_i      (fcomp_wstrb),
    .wlast_s_i      (fcomp_wlast),
    .wuser_s_i      (1'b0),
    .wvalid_s_i     (fcomp_wvalid),
    .wready_s_o     (fcomp_wready),
    .bid_s_o        (fcomp_bid),
    .bresp_s_o      (fcomp_bresp),
    .buser_s_o      (),
    .bvalid_s_o     (fcomp_bvalid),
    .bready_s_i     (fcomp_bready),
    .rid_s_o        (fcomp_rid),
    .rdata_s_o      (fcomp_rdata),
    .rresp_s_o      (fcomp_rresp),
    .rlast_s_o      (fcomp_rlast),
    .ruser_s_o      (),
    .rvalid_s_o     (fcomp_rvalid),
    .rready_s_i     (fcomp_rready),

    .arid_m_o       (ARIDM),
    .araddr_m_o     (ARADDRM),
    .arlen_m_o      (ARLENM),
    .arsize_m_o     (ARSIZEM),
    .arburst_m_o    (ARBURSTM),
    .arlock_m_o     (ARLOCKM),
    .arcache_m_o    (ARCACHEM),
    .arprot_m_o     (ARPROTM),
    .arqos_m_o      (ARQOSM),
    .arregion_m_o   (ARREGIONM),
    .aruser_m_o     (ARUSERM),
    .arvalid_m_o    (ARVALIDM),
    .arready_m_i    (ARREADYM),
    .awid_m_o       (AWIDM),
    .awaddr_m_o     (AWADDRM),
    .awlen_m_o      (AWLENM),
    .awsize_m_o     (AWSIZEM),
    .awburst_m_o    (AWBURSTM),
    .awlock_m_o     (AWLOCKM),
    .awcache_m_o    (AWCACHEM),
    .awprot_m_o     (AWPROTM),
    .awqos_m_o      (AWQOSM),
    .awregion_m_o   (AWREGIONM),
    .awuser_m_o     (AWUSERM),
    .awvalid_m_o    (AWVALIDM),
    .awready_m_i    (AWREADYM),
    .wdata_m_o      (WDATAM),
    .wstrb_m_o      (WSTRBM),
    .wlast_m_o      (WLASTM),
    .wuser_m_o      (WUSERM),
    .wvalid_m_o     (WVALIDM),
    .wready_m_i     (WREADYM),
    .bid_m_i        (BIDM),
    .bresp_m_i      (BRESPM),
    .buser_m_i      (BUSERM),
    .bvalid_m_i     (BVALIDM),
    .bready_m_o     (BREADYM),
    .rid_m_i        (RIDM),
    .rdata_m_i      (RDATAM),
    .rresp_m_i      (RRESPM),
    .rlast_m_i      (RLASTM),
    .ruser_m_i      (RUSERM),
    .rvalid_m_i     (RVALIDM),
    .rready_m_o     (RREADYM),
    .awakeup_m_o    (AWAKEUPM),

    .interrupt      (se_fw_irq),
    .bypass_i       (FIREWALL_BYPASS),

    .dftcgen        (DFTCGEN)
  );


  assign unused =       |{rom_haddr[31:ROM_AW] ,
                          ram_haddr[31:RAM_AW] ,
                          m0_hresp[1]          ,
                          initca_hresp[1]      ,
                          fctlr_bid            ,
                          fctlr_rid            ,
                          fcomp_aruser         ,
                          fcomp_awuser         ,
                          CA_ERR_MSK           ,
                          syncdown_hauser[0]};

endmodule
