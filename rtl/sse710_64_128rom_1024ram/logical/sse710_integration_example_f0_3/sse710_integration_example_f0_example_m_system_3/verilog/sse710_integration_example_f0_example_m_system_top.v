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

module sse710_integration_example_f0_example_m_system_top #(
  `include "sse710_integration_example_f0_example_m_system_top_defs.v"
  ) (

  input  wire                                 CPU0FCLK,              

  input  wire                                 CPU0HCLK,              

  input  wire                                 CPU0DAPCLK,
  input  wire                                 CPU0DAPRESETn,         

  input  wire                                 CPU0CTICLK,            
  input  wire                                 CPU0CTIRESETn,         

  input  wire                                 CPU0PORESETn,          

  input  wire                                 CPU0SYSRESETn,         

  input  wire                                 CPU0STCLK,             

  input  wire  [25:0]                         CPU0STCALIB,           

  input  wire                                 SRAM0HCLK,             
  input  wire                                 SRAM1HCLK,             
  input  wire                                 SRAM2HCLK,             
  input  wire                                 SRAM3HCLK,             

  input  wire                                 MTXHCLK,               
  input  wire                                 MTXHRESETn,            

  input  wire                                 AHB2APBHCLK,           
  input  wire                                 TIMER0PCLK,            
  input  wire                                 TIMER0PCLKG,           
  input  wire                                 TIMER0PRESETn,         
  input  wire                                 TIMER1PCLK,            
  input  wire                                 TIMER1PCLKG,           
  input  wire                                 TIMER1PRESETn,         




  input  wire [31:0]                          SRAM0RDATA,            
  output wire [12:0]                          SRAM0ADDR,             
  output wire [3:0]                           SRAM0WREN,             
  output wire [31:0]                          SRAM0WDATA,            
  output wire                                 SRAM0CS,               

  input  wire [31:0]                          SRAM1RDATA,            
  output wire [12:0]                          SRAM1ADDR,             
  output wire [3:0]                           SRAM1WREN,             
  output wire [31:0]                          SRAM1WDATA,            
  output wire                                 SRAM1CS,               

  input  wire [31:0]                          SRAM2RDATA,            
  output wire [12:0]                          SRAM2ADDR,             
  output wire [3:0]                           SRAM2WREN,             
  output wire [31:0]                          SRAM2WDATA,            
  output wire                                 SRAM2CS,               

  input  wire [31:0]                          SRAM3RDATA,            
  output wire [12:0]                          SRAM3ADDR,             
  output wire [3:0]                           SRAM3WREN,             
  output wire [31:0]                          SRAM3WDATA,            
  output wire                                 SRAM3CS,               


  input  wire                                 TIMER0EXTIN,            
  input  wire                                 TIMER0PRIVMODEN,        

  input  wire                                 TIMER1EXTIN,            
  input  wire                                 TIMER1PRIVMODEN,        

  output wire                                 TIMER0TIMERINT,         
  output wire                                 TIMER1TIMERINT,         

  output wire                                 TARGFLASH0HSEL,         
  output wire [31:0]                          TARGFLASH0HADDR,        
  output wire  [1:0]                          TARGFLASH0HTRANS,       
  output wire                                 TARGFLASH0HWRITE,       
  output wire  [2:0]                          TARGFLASH0HSIZE,        
  output wire  [2:0]                          TARGFLASH0HBURST,       
  output wire  [3:0]                          TARGFLASH0HPROT,        
  output wire  [1:0]                          TARGFLASH0MEMATTR,
  output wire                                 TARGFLASH0EXREQ,
  output wire  [3:0]                          TARGFLASH0HMASTER,
  output wire [31:0]                          TARGFLASH0HWDATA,       
  output wire                                 TARGFLASH0HMASTLOCK,    
  output wire                                 TARGFLASH0HREADYMUX,    
  output wire                                 TARGFLASH0HAUSER,       
  output wire  [3:0]                          TARGFLASH0HWUSER,       
  input  wire [31:0]                          TARGFLASH0HRDATA,       
  input  wire                                 TARGFLASH0HREADYOUT,    
  input  wire                                 TARGFLASH0HRESP,        
  input  wire                                 TARGFLASH0EXRESP,
  input  wire  [2:0]                          TARGFLASH0HRUSER,       

  output wire                                 TARGEXP0HSEL,           
  output wire [31:0]                          TARGEXP0HADDR,          
  output wire  [1:0]                          TARGEXP0HTRANS,         
  output wire                                 TARGEXP0HWRITE,         
  output wire  [2:0]                          TARGEXP0HSIZE,          
  output wire  [2:0]                          TARGEXP0HBURST,         
  output wire  [3:0]                          TARGEXP0HPROT,          
  output wire  [1:0]                          TARGEXP0MEMATTR,
  output wire                                 TARGEXP0EXREQ,
  output wire  [3:0]                          TARGEXP0HMASTER,
  output wire [31:0]                          TARGEXP0HWDATA,         
  output wire                                 TARGEXP0HMASTLOCK,      
  output wire                                 TARGEXP0HREADYMUX,      
  output wire                                 TARGEXP0HAUSER,         
  output wire  [3:0]                          TARGEXP0HWUSER,         
  input  wire [31:0]                          TARGEXP0HRDATA,         
  input  wire                                 TARGEXP0HREADYOUT,      
  input  wire                                 TARGEXP0HRESP,          
  input  wire                                 TARGEXP0EXRESP,
  input  wire  [2:0]                          TARGEXP0HRUSER,         

  output wire                                 TARGEXP1HSEL,           
  output wire [31:0]                          TARGEXP1HADDR,          
  output wire  [1:0]                          TARGEXP1HTRANS,         
  output wire                                 TARGEXP1HWRITE,         
  output wire  [2:0]                          TARGEXP1HSIZE,          
  output wire  [2:0]                          TARGEXP1HBURST,         
  output wire  [3:0]                          TARGEXP1HPROT,          
  output wire  [1:0]                          TARGEXP1MEMATTR,
  output wire                                 TARGEXP1EXREQ,
  output wire  [3:0]                          TARGEXP1HMASTER,
  output wire [31:0]                          TARGEXP1HWDATA,         
  output wire                                 TARGEXP1HMASTLOCK,      
  output wire                                 TARGEXP1HREADYMUX,      
  output wire                                 TARGEXP1HAUSER,         
  output wire  [3:0]                          TARGEXP1HWUSER,         
  input  wire [31:0]                          TARGEXP1HRDATA,         
  input  wire                                 TARGEXP1HREADYOUT,      
  input  wire                                 TARGEXP1HRESP,          
  input  wire                                 TARGEXP1EXRESP,
  input  wire  [2:0]                          TARGEXP1HRUSER,         

  input  wire                                 INITEXP0HSEL,           
  input  wire [31:0]                          INITEXP0HADDR,          
  input  wire  [1:0]                          INITEXP0HTRANS,         
  input  wire                                 INITEXP0HWRITE,         
  input  wire  [2:0]                          INITEXP0HSIZE,          
  input  wire  [2:0]                          INITEXP0HBURST,         
  input  wire  [3:0]                          INITEXP0HPROT,          
  input  wire  [1:0]                          INITEXP0MEMATTR,
  input  wire                                 INITEXP0EXREQ,
  input  wire  [3:0]                          INITEXP0HMASTER,
  input  wire [31:0]                          INITEXP0HWDATA,         
  input  wire                                 INITEXP0HMASTLOCK,      
  input  wire                                 INITEXP0HAUSER,         
  input  wire  [3:0]                          INITEXP0HWUSER,         
  output wire [31:0]                          INITEXP0HRDATA,         
  output wire                                 INITEXP0HREADY,         
  output wire                                 INITEXP0HRESP,          
  output wire                                 INITEXP0EXRESP,
  output wire [2:0]                           INITEXP0HRUSER,         

  input  wire                                 INITEXP1HSEL,           
  input  wire [31:0]                          INITEXP1HADDR,          
  input  wire  [1:0]                          INITEXP1HTRANS,         
  input  wire                                 INITEXP1HWRITE,         
  input  wire  [2:0]                          INITEXP1HSIZE,          
  input  wire  [2:0]                          INITEXP1HBURST,         
  input  wire  [3:0]                          INITEXP1HPROT,          
  input  wire  [1:0]                          INITEXP1MEMATTR,
  input  wire                                 INITEXP1EXREQ,
  input  wire  [3:0]                          INITEXP1HMASTER,
  input  wire [31:0]                          INITEXP1HWDATA,         
  input  wire                                 INITEXP1HMASTLOCK,      
  input  wire                                 INITEXP1HAUSER,         
  input  wire  [3:0]                          INITEXP1HWUSER,         
  output wire [31:0]                          INITEXP1HRDATA,         
  output wire                                 INITEXP1HREADY,         
  output wire                                 INITEXP1HRESP,          
  output wire                                 INITEXP1EXRESP,
  output wire  [2:0]                          INITEXP1HRUSER,         

  output wire                                 APBTARGEXP2PSEL,        
  output wire                                 APBTARGEXP2PENABLE,     
  output wire [11:0]                          APBTARGEXP2PADDR,       
  output wire                                 APBTARGEXP2PWRITE,      
  output wire [31:0]                          APBTARGEXP2PWDATA,      
  input  wire  [31:0]                         APBTARGEXP2PRDATA,      
  input  wire                                 APBTARGEXP2PREADY,      
  input  wire                                 APBTARGEXP2PSLVERR,     
  output wire [3:0]                           APBTARGEXP2PSTRB,       
  output wire [2:0]                           APBTARGEXP2PPROT,       

  output wire                                 APBTARGEXP3PSEL,        
  output wire                                 APBTARGEXP3PENABLE,     
  output wire [11:0]                          APBTARGEXP3PADDR,       
  output wire                                 APBTARGEXP3PWRITE,      
  output wire [31:0]                          APBTARGEXP3PWDATA,      
  input  wire  [31:0]                         APBTARGEXP3PRDATA,      
  input  wire                                 APBTARGEXP3PREADY,      
  input  wire                                 APBTARGEXP3PSLVERR,     
  output wire [3:0]                           APBTARGEXP3PSTRB,       
  output wire [2:0]                           APBTARGEXP3PPROT,       

  output wire                                 APBTARGEXP4PSEL,        
  output wire                                 APBTARGEXP4PENABLE,     
  output wire [11:0]                          APBTARGEXP4PADDR,       
  output wire                                 APBTARGEXP4PWRITE,      
  output wire [31:0]                          APBTARGEXP4PWDATA,      
  input  wire  [31:0]                         APBTARGEXP4PRDATA,      
  input  wire                                 APBTARGEXP4PREADY,      
  input  wire                                 APBTARGEXP4PSLVERR,     
  output wire [3:0]                           APBTARGEXP4PSTRB,       
  output wire [2:0]                           APBTARGEXP4PPROT,       

  output wire                                 APBTARGEXP5PSEL,        
  output wire                                 APBTARGEXP5PENABLE,     
  output wire [11:0]                          APBTARGEXP5PADDR,       
  output wire                                 APBTARGEXP5PWRITE,      
  output wire [31:0]                          APBTARGEXP5PWDATA,      
  input  wire  [31:0]                         APBTARGEXP5PRDATA,      
  input  wire                                 APBTARGEXP5PREADY,      
  input  wire                                 APBTARGEXP5PSLVERR,     
  output wire [3:0]                           APBTARGEXP5PSTRB,       
  output wire [2:0]                           APBTARGEXP5PPROT,       

  output wire                                 APBTARGEXP6PSEL,        
  output wire                                 APBTARGEXP6PENABLE,     
  output wire [11:0]                          APBTARGEXP6PADDR,       
  output wire                                 APBTARGEXP6PWRITE,      
  output wire [31:0]                          APBTARGEXP6PWDATA,      
  input  wire  [31:0]                         APBTARGEXP6PRDATA,      
  input  wire                                 APBTARGEXP6PREADY,      
  input  wire                                 APBTARGEXP6PSLVERR,     
  output wire [3:0]                           APBTARGEXP6PSTRB,       
  output wire [2:0]                           APBTARGEXP6PPROT,       

  output wire                                 APBTARGEXP7PSEL,        
  output wire                                 APBTARGEXP7PENABLE,     
  output wire [11:0]                          APBTARGEXP7PADDR,       
  output wire                                 APBTARGEXP7PWRITE,      
  output wire [31:0]                          APBTARGEXP7PWDATA,      
  input  wire  [31:0]                         APBTARGEXP7PRDATA,      
  input  wire                                 APBTARGEXP7PREADY,      
  input  wire                                 APBTARGEXP7PSLVERR,     
  output wire [3:0]                           APBTARGEXP7PSTRB,       
  output wire [2:0]                           APBTARGEXP7PPROT,       

  output wire                                 APBTARGEXP8PSEL,        
  output wire                                 APBTARGEXP8PENABLE,     
  output wire [11:0]                          APBTARGEXP8PADDR,       
  output wire                                 APBTARGEXP8PWRITE,      
  output wire [31:0]                          APBTARGEXP8PWDATA,      
  input  wire  [31:0]                         APBTARGEXP8PRDATA,      
  input  wire                                 APBTARGEXP8PREADY,      
  input  wire                                 APBTARGEXP8PSLVERR,     
  output wire [3:0]                           APBTARGEXP8PSTRB,       
  output wire [2:0]                           APBTARGEXP8PPROT,       

  output wire                                 APBTARGEXP9PSEL,        
  output wire                                 APBTARGEXP9PENABLE,     
  output wire [11:0]                          APBTARGEXP9PADDR,       
  output wire                                 APBTARGEXP9PWRITE,      
  output wire [31:0]                          APBTARGEXP9PWDATA,      
  input  wire  [31:0]                         APBTARGEXP9PRDATA,      
  input  wire                                 APBTARGEXP9PREADY,      
  input  wire                                 APBTARGEXP9PSLVERR,     
  output wire [3:0]                           APBTARGEXP9PSTRB,       
  output wire [2:0]                           APBTARGEXP9PPROT,       

  output wire                                 APBTARGEXP10PSEL,       
  output wire                                 APBTARGEXP10PENABLE,    
  output wire [11:0]                          APBTARGEXP10PADDR,      
  output wire                                 APBTARGEXP10PWRITE,     
  output wire [31:0]                          APBTARGEXP10PWDATA,     
  input  wire  [31:0]                         APBTARGEXP10PRDATA,     
  input  wire                                 APBTARGEXP10PREADY,     
  input  wire                                 APBTARGEXP10PSLVERR,    
  output wire [3:0]                           APBTARGEXP10PSTRB,      
  output wire [2:0]                           APBTARGEXP10PPROT,      

  output wire                                 APBTARGEXP11PSEL,       
  output wire                                 APBTARGEXP11PENABLE,    
  output wire [11:0]                          APBTARGEXP11PADDR,      
  output wire                                 APBTARGEXP11PWRITE,     
  output wire [31:0]                          APBTARGEXP11PWDATA,     
  input  wire  [31:0]                         APBTARGEXP11PRDATA,     
  input  wire                                 APBTARGEXP11PREADY,     
  input  wire                                 APBTARGEXP11PSLVERR,    
  output wire [3:0]                           APBTARGEXP11PSTRB,      
  output wire [2:0]                           APBTARGEXP11PPROT,      

  output wire                                 APBTARGEXP12PSEL,       
  output wire                                 APBTARGEXP12PENABLE,    
  output wire [11:0]                          APBTARGEXP12PADDR,      
  output wire                                 APBTARGEXP12PWRITE,     
  output wire [31:0]                          APBTARGEXP12PWDATA,     
  input  wire  [31:0]                         APBTARGEXP12PRDATA,     
  input  wire                                 APBTARGEXP12PREADY,     
  input  wire                                 APBTARGEXP12PSLVERR,    
  output wire [3:0]                           APBTARGEXP12PSTRB,      
  output wire [2:0]                           APBTARGEXP12PPROT,      

  output wire                                 APBTARGEXP13PSEL,       
  output wire                                 APBTARGEXP13PENABLE,    
  output wire [11:0]                          APBTARGEXP13PADDR,      
  output wire                                 APBTARGEXP13PWRITE,     
  output wire [31:0]                          APBTARGEXP13PWDATA,     
  input  wire  [31:0]                         APBTARGEXP13PRDATA,     
  input  wire                                 APBTARGEXP13PREADY,     
  input  wire                                 APBTARGEXP13PSLVERR,    
  output wire [3:0]                           APBTARGEXP13PSTRB,      
  output wire [2:0]                           APBTARGEXP13PPROT,      

  output wire                                 APBTARGEXP14PSEL,       
  output wire                                 APBTARGEXP14PENABLE,    
  output wire [11:0]                          APBTARGEXP14PADDR,      
  output wire                                 APBTARGEXP14PWRITE,     
  output wire [31:0]                          APBTARGEXP14PWDATA,     
  input  wire  [31:0]                         APBTARGEXP14PRDATA,     
  input  wire                                 APBTARGEXP14PREADY,     
  input  wire                                 APBTARGEXP14PSLVERR,    
  output wire [3:0]                           APBTARGEXP14PSTRB,      
  output wire [2:0]                           APBTARGEXP14PPROT,      

  output wire                                 APBTARGEXP15PSEL,       
  output wire                                 APBTARGEXP15PENABLE,    
  output wire [11:0]                          APBTARGEXP15PADDR,      
  output wire                                 APBTARGEXP15PWRITE,     
  output wire [31:0]                          APBTARGEXP15PWDATA,     
  input  wire  [31:0]                         APBTARGEXP15PRDATA,     
  input  wire                                 APBTARGEXP15PREADY,     
  input  wire                                 APBTARGEXP15PSLVERR,    
  output wire [3:0]                           APBTARGEXP15PSTRB,      
  output wire [2:0]                           APBTARGEXP15PPROT,      


  input  wire                                 CPU0EDBGRQ,             
  input  wire                                 CPU0DBGRESTART,         
  output wire                                 CPU0DBGRESTARTED,       
  output wire [31:0]                          CPU0HTMDHADDR,          
  output wire [1:0]                           CPU0HTMDHTRANS,         
  output wire [2:0]                           CPU0HTMDHSIZE,          
  output wire [2:0]                           CPU0HTMDHBURST,         
  output wire [3:0]                           CPU0HTMDHPROT,          
  output wire [31:0]                          CPU0HTMDHWDATA,         
  output wire                                 CPU0HTMDHWRITE,         
  output wire [31:0]                          CPU0HTMDHRDATA,         
  output wire                                 CPU0HTMDHREADY,         
  output wire                                 CPU0HTMDHRESP,          
  output wire [148:0]                         CPU0INTERNALSTATE,      

  input  wire                                 CPU0PREADY,             
  input  wire                                 CPU0PSLVERR,            
  input  wire [31:0]                          CPU0PRDATA,             
  output wire                                 CPU0PSEL,               
  output wire [30:0]                          CPU0PADDR,              
  output wire                                 CPU0PADDR31,            
  output wire                                 CPU0PWRITE,             
  output wire                                 CPU0PENABLE,            
  output wire [31:0]                          CPU0PWDATA,             
  
  input  wire                                 CPU0DPABORT_DP,         
  input  wire                                 CPU0PSEL_DP,            
  input  wire                                 CPU0PENABLE_DP,         
  input  wire                                 CPU0PWRITE_DP,          
  input  wire [11:0]                          CPU0PADDR_DP,           
  input  wire [31:0]                          CPU0PWDATA_DP,          
  output wire                                 CPU0PREADY_DP,          
  output wire                                 CPU0PSLVERR_DP,         
  output wire [31:0]                          CPU0PRDATA_DP,          

  input  wire [3:0]                           CPU0CTICHIN,            
  output wire [3:0]                           CPU0CTICHOUT,           
  output wire [1:0]                           CPU0CTIINT,             
  output wire [7:0]                           CPU0CTIASICCTRL,        

  input  wire [47:0]                          CPU0TSVALUEB,           
  input  wire                                 CPU0TSCLKCHANGE,        
  output wire [8:0]                           CPU0ETMINTNUM,          
  output wire [2:0]                           CPU0ETMINTSTAT,         
  output wire                                 CPU0ETMFIFOFULL,        
                                                                      
  output wire                                 CPU0TRCENA,             
  output wire                                 CPU0ETMEN,              
  
  input  wire                                 CPU0ETMATREADY,         
  output wire [6:0]                           CPU0ETMATID,            
  output wire                                 CPU0ETMATVALID,         
  output wire [7:0]                           CPU0ETMATDATA,          
  output wire                                 CPU0ETMATBYTES,         
  output wire                                 CPU0ETMAFREADY,         
  
  output wire                                 CPU0ETMTRIGOUT,         
  output wire                                 CPU0ETMDBGREQ,           
  
  input  wire                                 CPU0ITMATREADY,         
  output wire [6:0]                           CPU0ITMATID,            
  output wire                                 CPU0ITMATVALID,         
  output wire [7:0]                           CPU0ITMATDATA,          
  output wire                                 CPU0ITMATBYTES,         
  output wire                                 CPU0ITMAFREADY,         

  output wire                                 CPU0HALTED,             
  input  wire                                 CPU0MPUDISABLE,         
  output wire                                 CPU0SLEEPING,           
  output wire                                 CPU0SLEEPDEEP,          
  input  wire                                 CPU0SLEEPHOLDREQn,      
  output wire                                 CPU0SLEEPHOLDACKn,      
  output wire                                 CPU0WAKEUP,             
  output wire                                 CPU0WICENACK,           
  output wire [WIC_LINES-1:0]                 CPU0WICSENSE,           
  input  wire                                 CPU0WICENREQ,           
  output wire                                 CPU0SYSRESETREQ,        
  output wire                                 CPU0LOCKUP,             
  output wire [3:0]                           CPU0BRCHSTAT,           

  input  wire [3:0]                           MTXREMAP,               

  input  wire                                 CPU0RXEV,               
  output wire                                 CPU0TXEV,               

  input  wire  [239:0]                         CPU0INTISR,            
  input  wire                                  CPU0INTNMI,            
  output wire  [7:0]                           CPU0CURRPRI,           
  input  wire  [31:0]                          CPU0AUXFAULT,          

  output wire                                  APBQACTIVE,            
  output wire                                  TIMER0PCLKQACTIVE,     
  output wire                                  TIMER1PCLKQACTIVE,     


  input  wire                                  CPU0DBGEN,             
  input  wire                                  CPU0NIDEN,             
  input  wire                                  CPU0DAPEN,             
  input  wire                                  CPU0FIXMASTERTYPE,     
                                                                      
  input  wire                                  CPU0ETMFIFOFULLEN,     


  input  wire                                  DFTRSTDISABLE,         
  input  wire                                  DFTCGEN,               
  input  wire                                  DFTSE);

  localparam CONST_AHB_CTRL    = 1'b1;     
  localparam DOUT_MASK         = 1'b1;     
  localparam BIGEND            = 1'b0;     
  localparam DNOTITRANS        = 1'b1;     



  wire   [31:0] haddri_i;
  wire    [1:0] htransi_i;
  wire    [2:0] hsizei_i;
  wire          hwritei_i;
  wire    [2:0] hbursti_i;
  wire    [3:0] hproti_i;
  wire    [1:0] memattri_i;
  wire   [31:0] hwdatai_i;
  wire   [31:0] hrdatai_i;
  wire          hreadyi_i;
  wire    [1:0] hrespi_i;

  wire   [31:0] haddrd_i;
  wire    [1:0] htransd_i;
  wire    [1:0] hmasterd_i;
  wire    [2:0] hsized_i;
  wire    [2:0] hburstd_i;
  wire    [3:0] hprotd_i;
  wire    [1:0] memattrd_i;
  wire   [31:0] hwdatad_i;
  wire          hwrited_i;
  wire          exreqd_i;
  wire   [31:0] hrdatad_i;
  wire          hreadyd_i;
  wire    [1:0] hrespd_i;
  wire          exrespd_i;

  wire          hauserinitcm3di_i;
  wire   [3:0]  hwuserinitcm3di_i;

  wire   [31:0] haddrs_i;
  wire    [1:0] htranss_i;
  wire    [1:0] hmasters_i;
  wire          hwrites_i;
  wire    [2:0] hsizes_i;
  wire          hmastlocks_i;
  wire   [31:0] hwdatas_i;
  wire    [2:0] hbursts_i;
  wire    [3:0] hprots_i;
  wire    [1:0] memattrs_i;
  wire          exreqs_i;

  wire          hauserinitcm3s_i;
  wire   [3:0]  hwuserinitcm3s_i;

  wire          hreadys_i;
  wire   [31:0] hrdatas_i;
  wire    [1:0] hresps_i;
  wire          exresps_i;

  wire          targsram0hsel_i;
  wire   [31:0] targsram0haddr_i;
  wire    [1:0] targsram0htrans_i;
  wire          targsram0hwrite_i;
  wire    [2:0] targsram0hsize_i;
  wire   [31:0] targsram0hwdata_i;
  wire          targsram0hreadymux_i;
  wire          targsram0hreadyout_i;
  wire   [31:0] targsram0hrdata_i;
  wire          targsram0hresp_i;
  wire          targsram0exresp_i;

  wire    [2:0] targsram0hruser_i;

  wire          targsram1hsel_i;
  wire   [31:0] targsram1haddr_i;
  wire    [1:0] targsram1htrans_i;
  wire          targsram1hwrite_i;
  wire    [2:0] targsram1hsize_i;
  wire   [31:0] targsram1hwdata_i;
  wire          targsram1hreadymux_i;
  wire          targsram1hreadyout_i;
  wire   [31:0] targsram1hrdata_i;
  wire          targsram1hresp_i;
  wire          targsram1exresp_i;

  wire    [2:0] targsram1hruser_i;

  wire          targsram2hsel_i;
  wire   [31:0] targsram2haddr_i;
  wire    [1:0] targsram2htrans_i;
  wire          targsram2hwrite_i;
  wire    [2:0] targsram2hsize_i;
  wire   [31:0] targsram2hwdata_i;
  wire          targsram2hreadymux_i;
  wire          targsram2hreadyout_i;
  wire   [31:0] targsram2hrdata_i;
  wire          targsram2hresp_i;
  wire          targsram2exresp_i;

  wire    [2:0] targsram2hruser_i;

  wire          targsram3hsel_i;
  wire   [31:0] targsram3haddr_i;
  wire    [1:0] targsram3htrans_i;
  wire          targsram3hwrite_i;
  wire    [2:0] targsram3hsize_i;
  wire   [31:0] targsram3hwdata_i;
  wire          targsram3hreadymux_i;
  wire          targsram3hreadyout_i;
  wire   [31:0] targsram3hrdata_i;
  wire          targsram3hresp_i;
  wire          targsram3exresp_i;

  wire    [2:0] targsram3hruser_i;

  wire          mtxscanenable_i;
  wire          mtxscaninhclk_i;

  wire   [11:0] apbtargexp0paddr_i;
  wire          apbtargexp0penable_i;
  wire          apbtargexp0pwrite_i;
  wire    [3:0] apbtargexp0pstrb_i;
  wire    [2:0] apbtargexp0pprot_i;
  wire   [31:0] apbtargexp0pwdata_i;
  wire          apbtargexp0psel_i;
  wire   [31:0] apbtargexp0prdata_i;
  wire          apbtargexp0pready_i;
  wire          apbtargexp0pslverr_i;

  wire   [11:0] apbtargexp1paddr_i;
  wire          apbtargexp1penable_i;
  wire          apbtargexp1pwrite_i;
  wire    [3:0] apbtargexp1pstrb_i;
  wire    [2:0] apbtargexp1pprot_i;
  wire   [31:0] apbtargexp1pwdata_i;
  wire          apbtargexp1psel_i;
  wire   [31:0] apbtargexp1prdata_i;
  wire          apbtargexp1pready_i;
  wire          apbtargexp1pslverr_i;
  
  wire          unused;

  assign hauserinitcm3di_i = 1'b0;
  assign hwuserinitcm3di_i = 4'b0;
  assign hauserinitcm3s_i  = 1'b0;
  assign hwuserinitcm3s_i  = 4'b0;

  assign TIMER0PCLKQACTIVE = apbtargexp0psel_i;
  assign TIMER1PCLKQACTIVE = apbtargexp1psel_i;

  assign mtxscanenable_i = 1'b0;
  assign mtxscaninhclk_i = 1'b0;

 sse710_integration_example_f0_interconnect u_sse710_integration_example_f0_interconnect (
    .MTXHCLK              (MTXHCLK),
    .MTXHRESETn           (MTXHRESETn),
    .AHB2APBHCLK          (AHB2APBHCLK),
    .MTXREMAP             (MTXREMAP),
    .APBQACTIVE           (APBQACTIVE),
    .HADDRI               (haddri_i),
    .HTRANSI              (htransi_i),
    .HSIZEI               (hsizei_i),
    .HWRITEI              (hwritei_i),
    .HBURSTI              (hbursti_i),
    .HPROTI               (hproti_i),
    .MEMATTRI             (memattri_i),
    .HWDATAI              (hwdatai_i),
    .HRDATAI              (hrdatai_i),
    .HREADYI              (hreadyi_i),
    .HRESPI               (hrespi_i),
    .HADDRD               (haddrd_i),
    .HTRANSD              (htransd_i),
    .HMASTERD             (hmasterd_i),
    .HSIZED               (hsized_i),
    .HBURSTD              (hburstd_i),
    .HPROTD               (hprotd_i),
    .MEMATTRD             (memattrd_i),
    .HWDATAD              (hwdatad_i),
    .HWRITED              (hwrited_i),
    .EXREQD               (exreqd_i),
    .HRDATAD              (hrdatad_i),
    .HREADYD              (hreadyd_i),
    .HRESPD               (hrespd_i),
    .EXRESPD              (exrespd_i),
    .HAUSERINITCM3DI      (hauserinitcm3di_i),
    .HWUSERINITCM3DI      (hwuserinitcm3di_i),
    .HRUSERINITCM3DI      (),
    .HADDRS               (haddrs_i),
    .HTRANSS              (htranss_i),
    .HMASTERS             (hmasters_i),
    .HWRITES              (hwrites_i),
    .HSIZES               (hsizes_i),
    .HMASTLOCKS           (hmastlocks_i),
    .HWDATAS              (hwdatas_i),
    .HBURSTS              (hbursts_i),
    .HPROTS               (hprots_i),
    .MEMATTRS             (memattrs_i),
    .EXREQS               (exreqs_i),
    .HAUSERINITCM3S       (hauserinitcm3s_i),
    .HWUSERINITCM3S       (hwuserinitcm3s_i),
    .HRUSERINITCM3S       (),
    .HREADYS              (hreadys_i),
    .HRDATAS              (hrdatas_i),
    .HRESPS               (hresps_i),
    .EXRESPS              (exresps_i),
    .INITEXP0HSEL         (INITEXP0HSEL),
    .INITEXP0HADDR        (INITEXP0HADDR),
    .INITEXP0HTRANS       (INITEXP0HTRANS),
    .INITEXP0HMASTER      (INITEXP0HMASTER),
    .INITEXP0HWRITE       (INITEXP0HWRITE),
    .INITEXP0HSIZE        (INITEXP0HSIZE),
    .INITEXP0HMASTLOCK    (INITEXP0HMASTLOCK),
    .INITEXP0HWDATA       (INITEXP0HWDATA),
    .INITEXP0HBURST       (INITEXP0HBURST),
    .INITEXP0HPROT        (INITEXP0HPROT),
    .INITEXP0MEMATTR      (INITEXP0MEMATTR),
    .INITEXP0EXREQ        (INITEXP0EXREQ),
    .INITEXP0HREADY       (INITEXP0HREADY),
    .INITEXP0HRDATA       (INITEXP0HRDATA),
    .INITEXP0HRESP        (INITEXP0HRESP),
    .INITEXP0EXRESP       (INITEXP0EXRESP),
    .INITEXP0HAUSER       (INITEXP0HAUSER),
    .INITEXP0HWUSER       (INITEXP0HWUSER),
    .INITEXP0HRUSER       (INITEXP0HRUSER),
    .INITEXP1HSEL         (INITEXP1HSEL),
    .INITEXP1HADDR        (INITEXP1HADDR),
    .INITEXP1HTRANS       (INITEXP1HTRANS),
    .INITEXP1HMASTER      (INITEXP1HMASTER),
    .INITEXP1HWRITE       (INITEXP1HWRITE),
    .INITEXP1HSIZE        (INITEXP1HSIZE),
    .INITEXP1HMASTLOCK    (INITEXP1HMASTLOCK),
    .INITEXP1HWDATA       (INITEXP1HWDATA),
    .INITEXP1HBURST       (INITEXP1HBURST),
    .INITEXP1HPROT        (INITEXP1HPROT),
    .INITEXP1MEMATTR      (INITEXP1MEMATTR),
    .INITEXP1EXREQ        (INITEXP1EXREQ),
    .INITEXP1HREADY       (INITEXP1HREADY),
    .INITEXP1HRDATA       (INITEXP1HRDATA),
    .INITEXP1HRESP        (INITEXP1HRESP),
    .INITEXP1EXRESP       (INITEXP1EXRESP),
    .INITEXP1HAUSER       (INITEXP1HAUSER),
    .INITEXP1HWUSER       (INITEXP1HWUSER),
    .INITEXP1HRUSER       (INITEXP1HRUSER),
    .TARGEXP0HSEL         (TARGEXP0HSEL),
    .TARGEXP0HADDR        (TARGEXP0HADDR),
    .TARGEXP0HTRANS       (TARGEXP0HTRANS),
    .TARGEXP0HMASTER      (TARGEXP0HMASTER),
    .TARGEXP0HWRITE       (TARGEXP0HWRITE),
    .TARGEXP0HSIZE        (TARGEXP0HSIZE),
    .TARGEXP0HMASTLOCK    (TARGEXP0HMASTLOCK),
    .TARGEXP0HWDATA       (TARGEXP0HWDATA),
    .TARGEXP0HBURST       (TARGEXP0HBURST),
    .TARGEXP0HPROT        (TARGEXP0HPROT),
    .TARGEXP0MEMATTR      (TARGEXP0MEMATTR),
    .TARGEXP0EXREQ        (TARGEXP0EXREQ),
    .TARGEXP0HREADYMUX    (TARGEXP0HREADYMUX),
    .TARGEXP0HREADYOUT    (TARGEXP0HREADYOUT),
    .TARGEXP0HRDATA       (TARGEXP0HRDATA),
    .TARGEXP0HRESP        (TARGEXP0HRESP),
    .TARGEXP0EXRESP       (TARGEXP0EXRESP),
    .TARGEXP0HAUSER       (TARGEXP0HAUSER),
    .TARGEXP0HWUSER       (TARGEXP0HWUSER),
    .TARGEXP0HRUSER       (TARGEXP0HRUSER),
    .TARGEXP1HSEL         (TARGEXP1HSEL),
    .TARGEXP1HADDR        (TARGEXP1HADDR),
    .TARGEXP1HTRANS       (TARGEXP1HTRANS),
    .TARGEXP1HMASTER      (TARGEXP1HMASTER),
    .TARGEXP1HWRITE       (TARGEXP1HWRITE),
    .TARGEXP1HSIZE        (TARGEXP1HSIZE),
    .TARGEXP1HMASTLOCK    (TARGEXP1HMASTLOCK),
    .TARGEXP1HWDATA       (TARGEXP1HWDATA),
    .TARGEXP1HBURST       (TARGEXP1HBURST),
    .TARGEXP1HPROT        (TARGEXP1HPROT),
    .TARGEXP1MEMATTR      (TARGEXP1MEMATTR),
    .TARGEXP1EXREQ        (TARGEXP1EXREQ),
    .TARGEXP1HREADYMUX    (TARGEXP1HREADYMUX),
    .TARGEXP1HREADYOUT    (TARGEXP1HREADYOUT),
    .TARGEXP1HRDATA       (TARGEXP1HRDATA),
    .TARGEXP1HRESP        (TARGEXP1HRESP),
    .TARGEXP1EXRESP       (TARGEXP1EXRESP),
    .TARGEXP1HAUSER       (TARGEXP1HAUSER),
    .TARGEXP1HWUSER       (TARGEXP1HWUSER),
    .TARGEXP1HRUSER       (TARGEXP1HRUSER),
    .TARGFLASH0HSEL       (TARGFLASH0HSEL),
    .TARGFLASH0HADDR      (TARGFLASH0HADDR),
    .TARGFLASH0HTRANS     (TARGFLASH0HTRANS),
    .TARGFLASH0HMASTER    (TARGFLASH0HMASTER),
    .TARGFLASH0HWRITE     (TARGFLASH0HWRITE),
    .TARGFLASH0HSIZE      (TARGFLASH0HSIZE),
    .TARGFLASH0HMASTLOCK  (TARGFLASH0HMASTLOCK),
    .TARGFLASH0HWDATA     (TARGFLASH0HWDATA),
    .TARGFLASH0HBURST     (TARGFLASH0HBURST),
    .TARGFLASH0HPROT      (TARGFLASH0HPROT),
    .TARGFLASH0MEMATTR    (TARGFLASH0MEMATTR),
    .TARGFLASH0EXREQ      (TARGFLASH0EXREQ),
    .TARGFLASH0HREADYMUX  (TARGFLASH0HREADYMUX),
    .TARGFLASH0HREADYOUT  (TARGFLASH0HREADYOUT),
    .TARGFLASH0HRDATA     (TARGFLASH0HRDATA),
    .TARGFLASH0HRESP      (TARGFLASH0HRESP),
    .TARGFLASH0EXRESP     (TARGFLASH0EXRESP),
    .TARGFLASH0HAUSER     (TARGFLASH0HAUSER),
    .TARGFLASH0HWUSER     (TARGFLASH0HWUSER),
    .TARGFLASH0HRUSER     (TARGFLASH0HRUSER),
    .TARGSRAM0HSEL        (targsram0hsel_i),
    .TARGSRAM0HADDR       (targsram0haddr_i),
    .TARGSRAM0HTRANS      (targsram0htrans_i),
    .TARGSRAM0HMASTER     (),
    .TARGSRAM0HWRITE      (targsram0hwrite_i),
    .TARGSRAM0HSIZE       (targsram0hsize_i),
    .TARGSRAM0HMASTLOCK   (),
    .TARGSRAM0HWDATA      (targsram0hwdata_i),
    .TARGSRAM0HBURST      (),
    .TARGSRAM0HPROT       (),
    .TARGSRAM0MEMATTR     (),
    .TARGSRAM0EXREQ       (),
    .TARGSRAM0HREADYMUX   (targsram0hreadymux_i),
    .TARGSRAM0HREADYOUT   (targsram0hreadyout_i),
    .TARGSRAM0HRDATA      (targsram0hrdata_i),
    .TARGSRAM0HRESP       (targsram0hresp_i),
    .TARGSRAM0EXRESP      (targsram0exresp_i),
    .TARGSRAM0HAUSER      (),
    .TARGSRAM0HWUSER      (),
    .TARGSRAM0HRUSER      (targsram0hruser_i),
    .TARGSRAM1HSEL        (targsram1hsel_i),
    .TARGSRAM1HADDR       (targsram1haddr_i),
    .TARGSRAM1HTRANS      (targsram1htrans_i),
    .TARGSRAM1HMASTER     (),
    .TARGSRAM1HWRITE      (targsram1hwrite_i),
    .TARGSRAM1HSIZE       (targsram1hsize_i),
    .TARGSRAM1HMASTLOCK   (),
    .TARGSRAM1HWDATA      (targsram1hwdata_i),
    .TARGSRAM1HBURST      (),
    .TARGSRAM1HPROT       (),
    .TARGSRAM1MEMATTR     (),
    .TARGSRAM1EXREQ       (),
    .TARGSRAM1HREADYMUX   (targsram1hreadymux_i),
    .TARGSRAM1HREADYOUT   (targsram1hreadyout_i),
    .TARGSRAM1HRDATA      (targsram1hrdata_i),
    .TARGSRAM1HRESP       (targsram1hresp_i),
    .TARGSRAM1EXRESP      (targsram1exresp_i),
    .TARGSRAM1HAUSER      (),
    .TARGSRAM1HWUSER      (),
    .TARGSRAM1HRUSER      (targsram1hruser_i),
    .TARGSRAM2HSEL        (targsram2hsel_i),
    .TARGSRAM2HADDR       (targsram2haddr_i),
    .TARGSRAM2HTRANS      (targsram2htrans_i),
    .TARGSRAM2HMASTER     (),
    .TARGSRAM2HWRITE      (targsram2hwrite_i),
    .TARGSRAM2HSIZE       (targsram2hsize_i),
    .TARGSRAM2HMASTLOCK   (),
    .TARGSRAM2HWDATA      (targsram2hwdata_i),
    .TARGSRAM2HBURST      (),
    .TARGSRAM2HPROT       (),
    .TARGSRAM2MEMATTR     (),
    .TARGSRAM2EXREQ       (),
    .TARGSRAM2HREADYMUX   (targsram2hreadymux_i),
    .TARGSRAM2HREADYOUT   (targsram2hreadyout_i),
    .TARGSRAM2HRDATA      (targsram2hrdata_i),
    .TARGSRAM2HRESP       (targsram2hresp_i),
    .TARGSRAM2EXRESP      (targsram2exresp_i),
    .TARGSRAM2HAUSER      (),
    .TARGSRAM2HWUSER      (),
    .TARGSRAM2HRUSER      (targsram2hruser_i),
    .TARGSRAM3HSEL        (targsram3hsel_i),
    .TARGSRAM3HADDR       (targsram3haddr_i),
    .TARGSRAM3HTRANS      (targsram3htrans_i),
    .TARGSRAM3HMASTER     (),
    .TARGSRAM3HWRITE      (targsram3hwrite_i),
    .TARGSRAM3HSIZE       (targsram3hsize_i),
    .TARGSRAM3HMASTLOCK   (),
    .TARGSRAM3HWDATA      (targsram3hwdata_i),
    .TARGSRAM3HBURST      (),
    .TARGSRAM3HPROT       (),
    .TARGSRAM3MEMATTR     (),
    .TARGSRAM3EXREQ       (),
    .TARGSRAM3HREADYMUX   (targsram3hreadymux_i),
    .TARGSRAM3HREADYOUT   (targsram3hreadyout_i),
    .TARGSRAM3HRDATA      (targsram3hrdata_i),
    .TARGSRAM3HRESP       (targsram3hresp_i),
    .TARGSRAM3EXRESP      (targsram3exresp_i),
    .TARGSRAM3HAUSER      (),
    .TARGSRAM3HWUSER      (),
    .TARGSRAM3HRUSER      (targsram3hruser_i),
    .SCANENABLE           (mtxscanenable_i),
    .SCANINHCLK           (mtxscaninhclk_i),
    .SCANOUTHCLK          (),
    .APBTARGEXP0PADDR     (apbtargexp0paddr_i),
    .APBTARGEXP0PENABLE   (apbtargexp0penable_i),
    .APBTARGEXP0PWRITE    (apbtargexp0pwrite_i),
    .APBTARGEXP0PSTRB     (apbtargexp0pstrb_i),
    .APBTARGEXP0PPROT     (apbtargexp0pprot_i),
    .APBTARGEXP0PWDATA    (apbtargexp0pwdata_i),
    .APBTARGEXP0PSEL      (apbtargexp0psel_i),
    .APBTARGEXP0PRDATA    (apbtargexp0prdata_i),
    .APBTARGEXP0PREADY    (apbtargexp0pready_i),
    .APBTARGEXP0PSLVERR   (apbtargexp0pslverr_i),
    .APBTARGEXP1PADDR     (apbtargexp1paddr_i),
    .APBTARGEXP1PENABLE   (apbtargexp1penable_i),
    .APBTARGEXP1PWRITE    (apbtargexp1pwrite_i),
    .APBTARGEXP1PSTRB     (apbtargexp1pstrb_i),
    .APBTARGEXP1PPROT     (apbtargexp1pprot_i),
    .APBTARGEXP1PWDATA    (apbtargexp1pwdata_i),
    .APBTARGEXP1PSEL      (apbtargexp1psel_i),
    .APBTARGEXP1PRDATA    (apbtargexp1prdata_i),
    .APBTARGEXP1PREADY    (apbtargexp1pready_i),
    .APBTARGEXP1PSLVERR   (apbtargexp1pslverr_i),
    .APBTARGEXP2PADDR     (APBTARGEXP2PADDR),
    .APBTARGEXP2PENABLE   (APBTARGEXP2PENABLE),
    .APBTARGEXP2PWRITE    (APBTARGEXP2PWRITE),
    .APBTARGEXP2PSTRB     (APBTARGEXP2PSTRB),
    .APBTARGEXP2PPROT     (APBTARGEXP2PPROT),
    .APBTARGEXP2PWDATA    (APBTARGEXP2PWDATA),
    .APBTARGEXP2PSEL      (APBTARGEXP2PSEL),
    .APBTARGEXP2PRDATA    (APBTARGEXP2PRDATA),
    .APBTARGEXP2PREADY    (APBTARGEXP2PREADY),
    .APBTARGEXP2PSLVERR   (APBTARGEXP2PSLVERR),
    .APBTARGEXP3PADDR     (APBTARGEXP3PADDR),
    .APBTARGEXP3PENABLE   (APBTARGEXP3PENABLE),
    .APBTARGEXP3PWRITE    (APBTARGEXP3PWRITE),
    .APBTARGEXP3PSTRB     (APBTARGEXP3PSTRB),
    .APBTARGEXP3PPROT     (APBTARGEXP3PPROT),
    .APBTARGEXP3PWDATA    (APBTARGEXP3PWDATA),
    .APBTARGEXP3PSEL      (APBTARGEXP3PSEL),
    .APBTARGEXP3PRDATA    (APBTARGEXP3PRDATA),
    .APBTARGEXP3PREADY    (APBTARGEXP3PREADY),
    .APBTARGEXP3PSLVERR   (APBTARGEXP3PSLVERR),
    .APBTARGEXP4PADDR     (APBTARGEXP4PADDR),
    .APBTARGEXP4PENABLE   (APBTARGEXP4PENABLE),
    .APBTARGEXP4PWRITE    (APBTARGEXP4PWRITE),
    .APBTARGEXP4PSTRB     (APBTARGEXP4PSTRB),
    .APBTARGEXP4PPROT     (APBTARGEXP4PPROT),
    .APBTARGEXP4PWDATA    (APBTARGEXP4PWDATA),
    .APBTARGEXP4PSEL      (APBTARGEXP4PSEL),
    .APBTARGEXP4PRDATA    (APBTARGEXP4PRDATA),
    .APBTARGEXP4PREADY    (APBTARGEXP4PREADY),
    .APBTARGEXP4PSLVERR   (APBTARGEXP4PSLVERR),
    .APBTARGEXP5PADDR     (APBTARGEXP5PADDR),
    .APBTARGEXP5PENABLE   (APBTARGEXP5PENABLE),
    .APBTARGEXP5PWRITE    (APBTARGEXP5PWRITE),
    .APBTARGEXP5PSTRB     (APBTARGEXP5PSTRB),
    .APBTARGEXP5PPROT     (APBTARGEXP5PPROT),
    .APBTARGEXP5PWDATA    (APBTARGEXP5PWDATA),
    .APBTARGEXP5PSEL      (APBTARGEXP5PSEL),
    .APBTARGEXP5PRDATA    (APBTARGEXP5PRDATA),
    .APBTARGEXP5PREADY    (APBTARGEXP5PREADY),
    .APBTARGEXP5PSLVERR   (APBTARGEXP5PSLVERR),
    .APBTARGEXP6PADDR     (APBTARGEXP6PADDR),
    .APBTARGEXP6PENABLE   (APBTARGEXP6PENABLE),
    .APBTARGEXP6PWRITE    (APBTARGEXP6PWRITE),
    .APBTARGEXP6PSTRB     (APBTARGEXP6PSTRB),
    .APBTARGEXP6PPROT     (APBTARGEXP6PPROT),
    .APBTARGEXP6PWDATA    (APBTARGEXP6PWDATA),
    .APBTARGEXP6PSEL      (APBTARGEXP6PSEL),
    .APBTARGEXP6PRDATA    (APBTARGEXP6PRDATA),
    .APBTARGEXP6PREADY    (APBTARGEXP6PREADY),
    .APBTARGEXP6PSLVERR   (APBTARGEXP6PSLVERR),
    .APBTARGEXP7PADDR     (APBTARGEXP7PADDR),
    .APBTARGEXP7PENABLE   (APBTARGEXP7PENABLE),
    .APBTARGEXP7PWRITE    (APBTARGEXP7PWRITE),
    .APBTARGEXP7PSTRB     (APBTARGEXP7PSTRB),
    .APBTARGEXP7PPROT     (APBTARGEXP7PPROT),
    .APBTARGEXP7PWDATA    (APBTARGEXP7PWDATA),
    .APBTARGEXP7PSEL      (APBTARGEXP7PSEL),
    .APBTARGEXP7PRDATA    (APBTARGEXP7PRDATA),
    .APBTARGEXP7PREADY    (APBTARGEXP7PREADY),
    .APBTARGEXP7PSLVERR   (APBTARGEXP7PSLVERR),
    .APBTARGEXP8PADDR     (APBTARGEXP8PADDR),
    .APBTARGEXP8PENABLE   (APBTARGEXP8PENABLE),
    .APBTARGEXP8PWRITE    (APBTARGEXP8PWRITE),
    .APBTARGEXP8PSTRB     (APBTARGEXP8PSTRB),
    .APBTARGEXP8PPROT     (APBTARGEXP8PPROT),
    .APBTARGEXP8PWDATA    (APBTARGEXP8PWDATA),
    .APBTARGEXP8PSEL      (APBTARGEXP8PSEL),
    .APBTARGEXP8PRDATA    (APBTARGEXP8PRDATA),
    .APBTARGEXP8PREADY    (APBTARGEXP8PREADY),
    .APBTARGEXP8PSLVERR   (APBTARGEXP8PSLVERR),
    .APBTARGEXP9PADDR     (APBTARGEXP9PADDR),
    .APBTARGEXP9PENABLE   (APBTARGEXP9PENABLE),
    .APBTARGEXP9PWRITE    (APBTARGEXP9PWRITE),
    .APBTARGEXP9PSTRB     (APBTARGEXP9PSTRB),
    .APBTARGEXP9PPROT     (APBTARGEXP9PPROT),
    .APBTARGEXP9PWDATA    (APBTARGEXP9PWDATA),
    .APBTARGEXP9PSEL      (APBTARGEXP9PSEL),
    .APBTARGEXP9PRDATA    (APBTARGEXP9PRDATA),
    .APBTARGEXP9PREADY    (APBTARGEXP9PREADY),
    .APBTARGEXP9PSLVERR   (APBTARGEXP9PSLVERR),
    .APBTARGEXP10PADDR    (APBTARGEXP10PADDR),
    .APBTARGEXP10PENABLE  (APBTARGEXP10PENABLE),
    .APBTARGEXP10PWRITE   (APBTARGEXP10PWRITE),
    .APBTARGEXP10PSTRB    (APBTARGEXP10PSTRB),
    .APBTARGEXP10PPROT    (APBTARGEXP10PPROT),
    .APBTARGEXP10PWDATA   (APBTARGEXP10PWDATA),
    .APBTARGEXP10PSEL     (APBTARGEXP10PSEL),
    .APBTARGEXP10PRDATA   (APBTARGEXP10PRDATA),
    .APBTARGEXP10PREADY   (APBTARGEXP10PREADY),
    .APBTARGEXP10PSLVERR  (APBTARGEXP10PSLVERR),
    .APBTARGEXP11PADDR    (APBTARGEXP11PADDR),
    .APBTARGEXP11PENABLE  (APBTARGEXP11PENABLE),
    .APBTARGEXP11PWRITE   (APBTARGEXP11PWRITE),
    .APBTARGEXP11PSTRB    (APBTARGEXP11PSTRB),
    .APBTARGEXP11PPROT    (APBTARGEXP11PPROT),
    .APBTARGEXP11PWDATA   (APBTARGEXP11PWDATA),
    .APBTARGEXP11PSEL     (APBTARGEXP11PSEL),
    .APBTARGEXP11PRDATA   (APBTARGEXP11PRDATA),
    .APBTARGEXP11PREADY   (APBTARGEXP11PREADY),
    .APBTARGEXP11PSLVERR  (APBTARGEXP11PSLVERR),
    .APBTARGEXP12PADDR    (APBTARGEXP12PADDR),
    .APBTARGEXP12PENABLE  (APBTARGEXP12PENABLE),
    .APBTARGEXP12PWRITE   (APBTARGEXP12PWRITE),
    .APBTARGEXP12PSTRB    (APBTARGEXP12PSTRB),
    .APBTARGEXP12PPROT    (APBTARGEXP12PPROT),
    .APBTARGEXP12PWDATA   (APBTARGEXP12PWDATA),
    .APBTARGEXP12PSEL     (APBTARGEXP12PSEL),
    .APBTARGEXP12PRDATA   (APBTARGEXP12PRDATA),
    .APBTARGEXP12PREADY   (APBTARGEXP12PREADY),
    .APBTARGEXP12PSLVERR  (APBTARGEXP12PSLVERR),
    .APBTARGEXP13PADDR    (APBTARGEXP13PADDR),
    .APBTARGEXP13PENABLE  (APBTARGEXP13PENABLE),
    .APBTARGEXP13PWRITE   (APBTARGEXP13PWRITE),
    .APBTARGEXP13PSTRB    (APBTARGEXP13PSTRB),
    .APBTARGEXP13PPROT    (APBTARGEXP13PPROT),
    .APBTARGEXP13PWDATA   (APBTARGEXP13PWDATA),
    .APBTARGEXP13PSEL     (APBTARGEXP13PSEL),
    .APBTARGEXP13PRDATA   (APBTARGEXP13PRDATA),
    .APBTARGEXP13PREADY   (APBTARGEXP13PREADY),
    .APBTARGEXP13PSLVERR  (APBTARGEXP13PSLVERR),
    .APBTARGEXP14PADDR    (APBTARGEXP14PADDR),
    .APBTARGEXP14PENABLE  (APBTARGEXP14PENABLE),
    .APBTARGEXP14PWRITE   (APBTARGEXP14PWRITE),
    .APBTARGEXP14PSTRB    (APBTARGEXP14PSTRB),
    .APBTARGEXP14PPROT    (APBTARGEXP14PPROT),
    .APBTARGEXP14PWDATA   (APBTARGEXP14PWDATA),
    .APBTARGEXP14PSEL     (APBTARGEXP14PSEL),
    .APBTARGEXP14PRDATA   (APBTARGEXP14PRDATA),
    .APBTARGEXP14PREADY   (APBTARGEXP14PREADY),
    .APBTARGEXP14PSLVERR  (APBTARGEXP14PSLVERR),
    .APBTARGEXP15PADDR    (APBTARGEXP15PADDR),
    .APBTARGEXP15PENABLE  (APBTARGEXP15PENABLE),
    .APBTARGEXP15PWRITE   (APBTARGEXP15PWRITE),
    .APBTARGEXP15PSTRB    (APBTARGEXP15PSTRB),
    .APBTARGEXP15PPROT    (APBTARGEXP15PPROT),
    .APBTARGEXP15PWDATA   (APBTARGEXP15PWDATA),
    .APBTARGEXP15PSEL     (APBTARGEXP15PSEL),
    .APBTARGEXP15PRDATA   (APBTARGEXP15PRDATA),
    .APBTARGEXP15PREADY   (APBTARGEXP15PREADY),
    .APBTARGEXP15PSLVERR  (APBTARGEXP15PSLVERR)
  );



  css600_cortexm3integrationcs #(
    .MPU_PRESENT      (MPU_PRESENT),
    .NUM_IRQ          (NUM_IRQ),
    .LVL_WIDTH        (LVL_WIDTH),
    .TRACE_LVL        (TRACE_LVL),
    .DEBUG_LVL        (DEBUG_LVL),
    .CLKGATE_PRESENT  (CLKGATE_PRESENT),
    .RESET_ALL_REGS   (RESET_ALL_REGS),
    .WIC_PRESENT      (WIC_PRESENT),
    .WIC_LINES        (WIC_LINES),
    .BB_PRESENT       (BB_PRESENT),
    .CONST_AHB_CTRL   (CONST_AHB_CTRL),
    .OBSERVATION      (OBSERVATION),
    .ETM_PRESENT      (ETM_PRESENT),
    .EXTRA_ROM_ENTRY  (EXTRA_ROM_ENTRY))
    u_css600_cortexm3integrationcs (
    .po_reset_n           (CPU0PORESETn),     
    .sys_reset_n          (CPU0SYSRESETn),    
    .dap_reset_n          (CPU0DAPRESETn),
    .cti_reset_n          (CPU0CTIRESETn),    
    
    .big_end              (BIGEND),           
    .mpu_disable          (CPU0MPUDISABLE),   
    .d_not_i_trans        (DNOTITRANS),       
    .dbgen                (CPU0DBGEN),        
    .niden                (CPU0NIDEN),        
    .fix_master_type      (CPU0FIXMASTERTYPE),
    .etm_fifo_full_en     (CPU0ETMFIFOFULLEN),
    
    .dftrstdisable        (DFTRSTDISABLE),    
    .dftcgen              (DFTCGEN),          
    .dftse                (DFTSE),            

    .f_clk                (CPU0FCLK),         
    .h_clk                (CPU0HCLK),         
    .dap_clk              (CPU0DAPCLK),       
    .cti_clk              (CPU0CTICLK),       

    .hready_i             (hreadyi_i),        
    .hrdata_i             (hrdatai_i),        
    .hresp_i              (hrespi_i[0]),      
    .flush_i              (1'b0),             

    .hready_d             (hreadyd_i),        
    .hrdata_d             (hrdatad_i),        
    .hresp_d              (hrespd_i[0]),      
    .ex_resp_d            (exrespd_i),        

    .hready_sys           (hreadys_i),        
    .hrdata_sys           (hrdatas_i),        
    .hresp_sys            (hresps_i[0]),      
    .ex_resp_sys          (exresps_i),        

    .pready_extppb        (CPU0PREADY),       
    .pslverr_extppb       (CPU0PSLVERR),      
    .prdata_extppb        (CPU0PRDATA),       
    
    .dp_abort             (CPU0DPABORT_DP),  
    .psel_dp              (CPU0PSEL_DP),     
    .penable_dp           (CPU0PENABLE_DP),  
    .pwrite_dp            (CPU0PWRITE_DP),   
    .paddr_dp             (CPU0PADDR_DP),    
    .pwdata_dp            (CPU0PWDATA_DP),   


    .atready_etm          (CPU0ETMATREADY),   
    .atready_itm          (CPU0ITMATREADY),   

    .channel_in           (CPU0CTICHIN),      

    .irq                  (CPU0INTISR),       
    .int_nmi              (CPU0INTNMI),       
    .rxev                 (CPU0RXEV),         

    .st_clk               (CPU0STCLK),        
    .st_calib             (CPU0STCALIB),      

    .sleep_hold_req_n     (CPU0SLEEPHOLDREQn),
    .wic_en_req           (CPU0WICENREQ),     
    .aux_fault            (CPU0AUXFAULT),     

    .ext_dbg_req          (CPU0EDBGRQ),       
    .dbg_restart          (CPU0DBGRESTART),   

    .ts_valueb            (CPU0TSVALUEB),     
    .ts_clk_change        (CPU0TSCLKCHANGE),  
    .dbgen_ap             (CPU0DAPEN),        



    .haddr_i              (haddri_i),         
    .htrans_i             (htransi_i),        
    .hsize_i              (hsizei_i),         
    .hwrite_i             (hwritei_i),        
    .hburst_i             (hbursti_i),        
    .hprot_i              (hproti_i),         
    .mem_attr_i           (memattri_i),       
    .hwdata_i             (hwdatai_i),        

    .haddr_d              (haddrd_i),         
    .htrans_d             (htransd_i),        
    .hsize_d              (hsized_i),         
    .hwrite_d             (hwrited_i),        
    .hburst_d             (hburstd_i),        
    .hprot_d              (hprotd_i),         
    .mem_attr_d           (memattrd_i),       
    .hmaster_d            (hmasterd_i),       
    .hwdata_d             (hwdatad_i),        
    .ex_req_d             (exreqd_i),         

    .haddr_sys            (haddrs_i),         
    .htrans_sys           (htranss_i),        
    .hsize_sys            (hsizes_i),         
    .hwrite_sys           (hwrites_i),        
    .hburst_sys           (hbursts_i),        
    .hprot_sys            (hprots_i),         
    .hmast_lock_sys       (hmastlocks_i),     
    .mem_attr_sys         (memattrs_i),       
    .hmaster_sys          (hmasters_i),       
    .hwdata_sys           (hwdatas_i),        
    .ex_req_sys           (exreqs_i),         

    .psel_extppb          (CPU0PSEL),         
    .paddr_extppb         (CPU0PADDR),        
    .paddr31_extppb       (CPU0PADDR31),      
    .pwrite_extppb        (CPU0PWRITE),       
    .penable_extppb       (CPU0PENABLE),      
    .pwdata_extppb        (CPU0PWDATA),       
      
    .pready_dp            (CPU0PREADY_DP),    
    .pslverr_dp           (CPU0PSLVERR_DP),   
    .prdata_dp            (CPU0PRDATA_DP),    

    .channel_out          (CPU0CTICHOUT),     
    .cti_int              (CPU0CTIINT),       
    .cti_asicctrl         (CPU0CTIASICCTRL),  

    .sys_reset_req        (CPU0SYSRESETREQ),  
    .txev                 (CPU0TXEV),         
    .sleep_hold_ack_n     (CPU0SLEEPHOLDACKn),

    .wic_wakeup           (CPU0WAKEUP),       
    .wic_en_ack           (CPU0WICENACK),     
    .wic_sense            (CPU0WICSENSE),     

    .halted               (CPU0HALTED),       
    .lockup               (CPU0LOCKUP),       
    .sleeping             (CPU0SLEEPING),     
    .sleepdeep            (CPU0SLEEPDEEP),    
    .curr_pri             (CPU0CURRPRI),      

    .etm_int_num          (CPU0ETMINTNUM),    
    .etm_int_stat         (CPU0ETMINTSTAT),   
    .etm_fifo_full        (CPU0ETMFIFOFULL),  
    
    .trc_ena              (CPU0TRCENA),       
    .etm_en               (CPU0ETMEN),        
    
    .brch_stat            (CPU0BRCHSTAT),     
    .dbg_restarted        (CPU0DBGRESTARTED), 
    
    .atid_etm             (CPU0ETMATID),      
    .atvalid_etm          (CPU0ETMATVALID),   
    .atdata_etm           (CPU0ETMATDATA),    
    .atbytes_etm          (CPU0ETMATBYTES),   

    .afready_etm          (CPU0ETMAFREADY),   

    .atid_itm             (CPU0ITMATID),      
    .atvalid_itm          (CPU0ITMATVALID),   
    .atdata_itm           (CPU0ITMATDATA),    
    .atbytes_itm          (CPU0ITMATBYTES),   
   
    .afready_itm          (CPU0ITMAFREADY),   

    .etm_trigger_out      (CPU0ETMTRIGOUT),   
    .etm_dbg_req          (CPU0ETMDBGREQ),    

    .internal_state       (CPU0INTERNALSTATE),

    .haddr_htm            (CPU0HTMDHADDR),    
    .htrans_htm           (CPU0HTMDHTRANS),   
    .hsize_htm            (CPU0HTMDHSIZE),    
    .hburst_htm           (CPU0HTMDHBURST),   
    .hprot_htm            (CPU0HTMDHPROT),    
    .hwdata_htm           (CPU0HTMDHWDATA),   
    .hwrite_htm           (CPU0HTMDHWRITE),   
    .hrdata_htm           (CPU0HTMDHRDATA),   
    .hready_htm           (CPU0HTMDHREADY),   
    .hresp_htm            (CPU0HTMDHRESP)     

   );




  sse710_integration_example_f0_peripheral u_sse710_integration_example_f0_peripheral(
    .TIMER0PCLK           (TIMER0PCLK),
    .TIMER0PCLKG          (TIMER0PCLKG),
    .TIMER0PRESETn        (TIMER0PRESETn),
    .TIMER0PSEL           (apbtargexp0psel_i),
    .TIMER0PADDR          (apbtargexp0paddr_i[11:2]),
    .TIMER0PENABLE        (apbtargexp0penable_i),
    .TIMER0PWRITE         (apbtargexp0pwrite_i),
    .TIMER0PWDATA         (apbtargexp0pwdata_i),
    .TIMER0PPROT          (apbtargexp0pprot_i),
    .TIMER0PSTRB          (apbtargexp0pstrb_i),
    .TIMER0PRDATA         (apbtargexp0prdata_i),
    .TIMER0PREADY         (apbtargexp0pready_i),
    .TIMER0PSLVERR        (apbtargexp0pslverr_i),
    .TIMER0EXTIN          (TIMER0EXTIN),
    .TIMER0PRIVMODEN      (TIMER0PRIVMODEN),
    .TIMER0TIMERINT       (TIMER0TIMERINT),
    .TIMER1PCLK           (TIMER1PCLK),
    .TIMER1PCLKG          (TIMER1PCLKG),
    .TIMER1PRESETn        (TIMER1PRESETn),
    .TIMER1PSEL           (apbtargexp1psel_i),
    .TIMER1PADDR          (apbtargexp1paddr_i[11:2]),
    .TIMER1PENABLE        (apbtargexp1penable_i),
    .TIMER1PWRITE         (apbtargexp1pwrite_i),
    .TIMER1PWDATA         (apbtargexp1pwdata_i),
    .TIMER1PPROT          (apbtargexp1pprot_i),
    .TIMER1PSTRB          (apbtargexp1pstrb_i),
    .TIMER1PRDATA         (apbtargexp1prdata_i),
    .TIMER1PREADY         (apbtargexp1pready_i),
    .TIMER1PSLVERR        (apbtargexp1pslverr_i),
    .TIMER1EXTIN          (TIMER1EXTIN),
    .TIMER1PRIVMODEN      (TIMER1PRIVMODEN),
    .TIMER1TIMERINT       (TIMER1TIMERINT)
  );


  assign targsram0exresp_i = 1'b0;
  assign targsram0hruser_i = 3'b000;

  sse710_integration_example_f0_ahb_to_sram #(.AW (15)) u_sse710_integration_example_f0_ahb_to_sram0 (
    .HCLK                 (SRAM0HCLK),
    .HRESETn              (MTXHRESETn),
    .HSEL                 (targsram0hsel_i),
    .HREADY               (targsram0hreadymux_i),
    .HTRANS               (targsram0htrans_i),
    .HSIZE                (targsram0hsize_i),
    .HWRITE               (targsram0hwrite_i),
    .HADDR                (targsram0haddr_i[14:0]),
    .HWDATA               (targsram0hwdata_i),
    .HREADYOUT            (targsram0hreadyout_i),
    .HRESP                (targsram0hresp_i),
    .HRDATA               (targsram0hrdata_i),

    .SRAMRDATA            (SRAM0RDATA),
    .SRAMADDR             (SRAM0ADDR),
    .SRAMWEN              (SRAM0WREN),
    .SRAMWDATA            (SRAM0WDATA),
    .SRAMCS               (SRAM0CS)
  );



  assign targsram1exresp_i = 1'b0;
  assign targsram1hruser_i = 3'b000;

  sse710_integration_example_f0_ahb_to_sram #(.AW (15)) u_sse710_integration_example_f0_ahb_to_sram1 (
    .HCLK                 (SRAM1HCLK),
    .HRESETn              (MTXHRESETn),
    .HSEL                 (targsram1hsel_i),
    .HREADY               (targsram1hreadymux_i),
    .HTRANS               (targsram1htrans_i),
    .HSIZE                (targsram1hsize_i),
    .HWRITE               (targsram1hwrite_i),
    .HADDR                (targsram1haddr_i[14:0]),
    .HWDATA               (targsram1hwdata_i),
    .HREADYOUT            (targsram1hreadyout_i),
    .HRESP                (targsram1hresp_i),
    .HRDATA               (targsram1hrdata_i),

    .SRAMRDATA            (SRAM1RDATA),
    .SRAMADDR             (SRAM1ADDR),
    .SRAMWEN              (SRAM1WREN),
    .SRAMWDATA            (SRAM1WDATA),
    .SRAMCS               (SRAM1CS)
  );


  assign targsram2exresp_i = 1'b0;
  assign targsram2hruser_i = 3'b000;

  sse710_integration_example_f0_ahb_to_sram #(.AW (15)) u_sse710_integration_example_f0_ahb_to_sram2 (
    .HCLK                 (SRAM2HCLK),
    .HRESETn              (MTXHRESETn),
    .HSEL                 (targsram2hsel_i),
    .HREADY               (targsram2hreadymux_i),
    .HTRANS               (targsram2htrans_i),
    .HSIZE                (targsram2hsize_i),
    .HWRITE               (targsram2hwrite_i),
    .HADDR                (targsram2haddr_i[14:0]),
    .HWDATA               (targsram2hwdata_i),
    .HREADYOUT            (targsram2hreadyout_i),
    .HRESP                (targsram2hresp_i),
    .HRDATA               (targsram2hrdata_i),

    .SRAMRDATA            (SRAM2RDATA),
    .SRAMADDR             (SRAM2ADDR),
    .SRAMWEN              (SRAM2WREN),
    .SRAMWDATA            (SRAM2WDATA),
    .SRAMCS               (SRAM2CS)
  );


  assign targsram3exresp_i = 1'b0;
  assign targsram3hruser_i = 3'b000;

  sse710_integration_example_f0_ahb_to_sram #(.AW (15)) u_sse710_integration_example_f0_ahb_to_sram3 (
    .HCLK                 (SRAM3HCLK),
    .HRESETn              (MTXHRESETn),
    .HSEL                 (targsram3hsel_i),
    .HREADY               (targsram3hreadymux_i),
    .HTRANS               (targsram3htrans_i),
    .HSIZE                (targsram3hsize_i),
    .HWRITE               (targsram3hwrite_i),
    .HADDR                (targsram3haddr_i[14:0]),
    .HWDATA               (targsram3hwdata_i),
    .HREADYOUT            (targsram3hreadyout_i),
    .HRESP                (targsram3hresp_i),
    .HRDATA               (targsram3hrdata_i),

    .SRAMRDATA            (SRAM3RDATA),
    .SRAMADDR             (SRAM3ADDR),
    .SRAMWEN              (SRAM3WREN),
    .SRAMWDATA            (SRAM3WDATA),
    .SRAMCS               (SRAM3CS)
  );


  wire     [1:1] config_check_0;  
  wire     [1:1] config_check_1;  
  wire     [1:1] config_check_2;  
  wire     [1:1] config_check_3;  

  assign config_check_0[((DNOTITRANS == 1))] = 1'b1;

  assign config_check_1[((BIGEND == 0))] = 1'b1;

  assign config_check_2[((DOUT_MASK == 1'b1))] = 1'b1;

  assign config_check_3[((CONST_AHB_CTRL == 1))] = 1'b1;

  assign        unused = (|config_check_0) |
                         (|config_check_1) |
                         (|config_check_2) |
                         (|config_check_3) |
                         (|targsram0haddr_i[31:15]) |
                         (|targsram1haddr_i[31:15]) |
                         (|targsram2haddr_i[31:15]) |
                         (|targsram3haddr_i[31:15]) |
                         (|apbtargexp0paddr_i[1:0]) |
                         (|apbtargexp1paddr_i[1:0]) |
                         (hresps_i[1])              |
                         (hrespd_i[1])              |
                         (hrespi_i[1]);

endmodule
