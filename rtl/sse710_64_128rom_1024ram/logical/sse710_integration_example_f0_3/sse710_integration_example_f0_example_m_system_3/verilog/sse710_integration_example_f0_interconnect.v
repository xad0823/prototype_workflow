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

module sse710_integration_example_f0_interconnect (
  MTXHCLK, MTXHRESETn, AHB2APBHCLK,                                                          
  MTXREMAP, APBQACTIVE,                                                                      
  HADDRI, HTRANSI, HSIZEI, HWRITEI,HBURSTI, HPROTI, MEMATTRI, HWDATAI,                       
  HRDATAI, HREADYI, HRESPI,                                                                  
  HADDRD, HTRANSD, HMASTERD, HSIZED, HBURSTD, HPROTD, MEMATTRD, HWDATAD, HWRITED, EXREQD,    
  HRDATAD, HREADYD, HRESPD, EXRESPD,                                                         
  HAUSERINITCM3DI, HWUSERINITCM3DI, HRUSERINITCM3DI,                                         
  HADDRS, HTRANSS, HMASTERS, HWRITES, HSIZES, HMASTLOCKS, HWDATAS, HBURSTS, HPROTS,          
  MEMATTRS, EXREQS,                                                                          
  HAUSERINITCM3S, HWUSERINITCM3S, HRUSERINITCM3S,                                            
  HREADYS, HRDATAS, HRESPS, EXRESPS,                                                         
  INITEXP0HSEL, INITEXP0HADDR, INITEXP0HTRANS, INITEXP0HMASTER, INITEXP0HWRITE,              
  INITEXP0HSIZE, INITEXP0HMASTLOCK, INITEXP0HWDATA, INITEXP0HBURST, INITEXP0HPROT,           
  INITEXP0MEMATTR, INITEXP0EXREQ,                                                            
  INITEXP0HREADY, INITEXP0HRDATA, INITEXP0HRESP, INITEXP0EXRESP,                             
  INITEXP0HAUSER, INITEXP0HWUSER, INITEXP0HRUSER,                                            
  INITEXP1HSEL, INITEXP1HADDR, INITEXP1HTRANS, INITEXP1HMASTER, INITEXP1HWRITE,              
  INITEXP1HSIZE, INITEXP1HMASTLOCK, INITEXP1HWDATA, INITEXP1HBURST, INITEXP1HPROT,           
  INITEXP1MEMATTR, INITEXP1EXREQ,                                                            
  INITEXP1HREADY, INITEXP1HRDATA, INITEXP1HRESP, INITEXP1EXRESP,                             
  INITEXP1HAUSER, INITEXP1HWUSER, INITEXP1HRUSER,                                            
  TARGEXP0HSEL, TARGEXP0HADDR, TARGEXP0HTRANS, TARGEXP0HMASTER, TARGEXP0HWRITE,              
  TARGEXP0HSIZE, TARGEXP0HMASTLOCK, TARGEXP0HWDATA, TARGEXP0HBURST, TARGEXP0HPROT,           
  TARGEXP0MEMATTR, TARGEXP0EXREQ, TARGEXP0HREADYMUX,                                         
  TARGEXP0HREADYOUT, TARGEXP0HRDATA, TARGEXP0HRESP, TARGEXP0EXRESP,                          
  TARGEXP0HAUSER, TARGEXP0HWUSER, TARGEXP0HRUSER,                                            
  TARGEXP1HSEL, TARGEXP1HADDR, TARGEXP1HTRANS, TARGEXP1HMASTER, TARGEXP1HWRITE,              
  TARGEXP1HSIZE, TARGEXP1HMASTLOCK, TARGEXP1HWDATA, TARGEXP1HBURST, TARGEXP1HPROT,           
  TARGEXP1MEMATTR, TARGEXP1EXREQ, TARGEXP1HREADYMUX,                                         
  TARGEXP1HREADYOUT, TARGEXP1HRDATA, TARGEXP1HRESP, TARGEXP1EXRESP,                          
  TARGEXP1HAUSER, TARGEXP1HWUSER, TARGEXP1HRUSER,                                            
  TARGFLASH0HSEL, TARGFLASH0HADDR, TARGFLASH0HTRANS, TARGFLASH0HMASTER, TARGFLASH0HWRITE,    
  TARGFLASH0HSIZE, TARGFLASH0HMASTLOCK, TARGFLASH0HWDATA, TARGFLASH0HBURST, TARGFLASH0HPROT, 
  TARGFLASH0MEMATTR, TARGFLASH0EXREQ, TARGFLASH0HREADYMUX,                                   
  TARGFLASH0HREADYOUT, TARGFLASH0HRDATA, TARGFLASH0HRESP, TARGFLASH0EXRESP,                  
  TARGFLASH0HAUSER, TARGFLASH0HWUSER, TARGFLASH0HRUSER,                                      
  TARGSRAM0HSEL, TARGSRAM0HADDR, TARGSRAM0HTRANS, TARGSRAM0HMASTER, TARGSRAM0HWRITE,         
  TARGSRAM0HSIZE, TARGSRAM0HMASTLOCK, TARGSRAM0HWDATA, TARGSRAM0HBURST, TARGSRAM0HPROT,      
  TARGSRAM0MEMATTR, TARGSRAM0EXREQ, TARGSRAM0HREADYMUX,                                      
  TARGSRAM0HREADYOUT, TARGSRAM0HRDATA, TARGSRAM0HRESP, TARGSRAM0EXRESP,                      
  TARGSRAM0HAUSER, TARGSRAM0HWUSER, TARGSRAM0HRUSER,                                         
  TARGSRAM1HSEL, TARGSRAM1HADDR, TARGSRAM1HTRANS, TARGSRAM1HMASTER, TARGSRAM1HWRITE,         
  TARGSRAM1HSIZE, TARGSRAM1HMASTLOCK, TARGSRAM1HWDATA, TARGSRAM1HBURST, TARGSRAM1HPROT,      
  TARGSRAM1MEMATTR, TARGSRAM1EXREQ, TARGSRAM1HREADYMUX,                                      
  TARGSRAM1HREADYOUT, TARGSRAM1HRDATA, TARGSRAM1HRESP, TARGSRAM1EXRESP,                      
  TARGSRAM1HAUSER, TARGSRAM1HWUSER, TARGSRAM1HRUSER,                                         
  TARGSRAM2HSEL, TARGSRAM2HADDR, TARGSRAM2HTRANS, TARGSRAM2HMASTER, TARGSRAM2HWRITE,         
  TARGSRAM2HSIZE, TARGSRAM2HMASTLOCK, TARGSRAM2HWDATA, TARGSRAM2HBURST, TARGSRAM2HPROT,      
  TARGSRAM2MEMATTR, TARGSRAM2EXREQ, TARGSRAM2HREADYMUX,                                      
  TARGSRAM2HREADYOUT, TARGSRAM2HRDATA, TARGSRAM2HRESP, TARGSRAM2EXRESP,                      
  TARGSRAM2HAUSER, TARGSRAM2HWUSER, TARGSRAM2HRUSER,                                         
  TARGSRAM3HSEL, TARGSRAM3HADDR, TARGSRAM3HTRANS, TARGSRAM3HMASTER, TARGSRAM3HWRITE,         
  TARGSRAM3HSIZE, TARGSRAM3HMASTLOCK, TARGSRAM3HWDATA, TARGSRAM3HBURST, TARGSRAM3HPROT,      
  TARGSRAM3MEMATTR, TARGSRAM3EXREQ, TARGSRAM3HREADYMUX,                                      
  TARGSRAM3HREADYOUT, TARGSRAM3HRDATA, TARGSRAM3HRESP, TARGSRAM3EXRESP,                      
  TARGSRAM3HAUSER, TARGSRAM3HWUSER, TARGSRAM3HRUSER,                                         
  SCANENABLE, SCANINHCLK, SCANOUTHCLK,                                                       
  APBTARGEXP0PADDR, APBTARGEXP0PENABLE, APBTARGEXP0PWRITE, APBTARGEXP0PSTRB,                 
  APBTARGEXP0PPROT, APBTARGEXP0PWDATA, APBTARGEXP0PSEL,                                      
  APBTARGEXP0PRDATA, APBTARGEXP0PREADY, APBTARGEXP0PSLVERR,                                  
  APBTARGEXP1PADDR, APBTARGEXP1PENABLE, APBTARGEXP1PWRITE, APBTARGEXP1PSTRB,                 
  APBTARGEXP1PPROT, APBTARGEXP1PWDATA, APBTARGEXP1PSEL,                                      
  APBTARGEXP1PRDATA, APBTARGEXP1PREADY, APBTARGEXP1PSLVERR,                                  
  APBTARGEXP2PADDR, APBTARGEXP2PENABLE, APBTARGEXP2PWRITE, APBTARGEXP2PSTRB,                 
  APBTARGEXP2PPROT, APBTARGEXP2PWDATA, APBTARGEXP2PSEL,                                      
  APBTARGEXP2PRDATA, APBTARGEXP2PREADY, APBTARGEXP2PSLVERR,                                  
  APBTARGEXP3PADDR, APBTARGEXP3PENABLE, APBTARGEXP3PWRITE, APBTARGEXP3PSTRB,                 
  APBTARGEXP3PPROT, APBTARGEXP3PWDATA, APBTARGEXP3PSEL,                                      
  APBTARGEXP3PRDATA, APBTARGEXP3PREADY, APBTARGEXP3PSLVERR,                                  
  APBTARGEXP4PADDR, APBTARGEXP4PENABLE, APBTARGEXP4PWRITE, APBTARGEXP4PSTRB,                 
  APBTARGEXP4PPROT, APBTARGEXP4PWDATA, APBTARGEXP4PSEL,                                      
  APBTARGEXP4PRDATA, APBTARGEXP4PREADY, APBTARGEXP4PSLVERR,                                  
  APBTARGEXP5PADDR, APBTARGEXP5PENABLE, APBTARGEXP5PWRITE, APBTARGEXP5PSTRB,                 
  APBTARGEXP5PPROT, APBTARGEXP5PWDATA, APBTARGEXP5PSEL,                                      
  APBTARGEXP5PRDATA, APBTARGEXP5PREADY, APBTARGEXP5PSLVERR,                                  
  APBTARGEXP6PADDR, APBTARGEXP6PENABLE, APBTARGEXP6PWRITE, APBTARGEXP6PSTRB,                 
  APBTARGEXP6PPROT, APBTARGEXP6PWDATA, APBTARGEXP6PSEL,                                      
  APBTARGEXP6PRDATA, APBTARGEXP6PREADY, APBTARGEXP6PSLVERR,                                  
  APBTARGEXP7PADDR, APBTARGEXP7PENABLE, APBTARGEXP7PWRITE, APBTARGEXP7PSTRB,                 
  APBTARGEXP7PPROT, APBTARGEXP7PWDATA, APBTARGEXP7PSEL,                                      
  APBTARGEXP7PRDATA, APBTARGEXP7PREADY, APBTARGEXP7PSLVERR,                                  
  APBTARGEXP8PADDR, APBTARGEXP8PENABLE, APBTARGEXP8PWRITE, APBTARGEXP8PSTRB,                 
  APBTARGEXP8PPROT, APBTARGEXP8PWDATA, APBTARGEXP8PSEL,                                      
  APBTARGEXP8PRDATA, APBTARGEXP8PREADY, APBTARGEXP8PSLVERR,                                  
  APBTARGEXP9PADDR, APBTARGEXP9PENABLE, APBTARGEXP9PWRITE, APBTARGEXP9PSTRB,                 
  APBTARGEXP9PPROT, APBTARGEXP9PWDATA, APBTARGEXP9PSEL,                                      
  APBTARGEXP9PRDATA, APBTARGEXP9PREADY, APBTARGEXP9PSLVERR,                                  
  APBTARGEXP10PADDR, APBTARGEXP10PENABLE, APBTARGEXP10PWRITE, APBTARGEXP10PSTRB,             
  APBTARGEXP10PPROT, APBTARGEXP10PWDATA, APBTARGEXP10PSEL,                                   
  APBTARGEXP10PRDATA, APBTARGEXP10PREADY, APBTARGEXP10PSLVERR,                               
  APBTARGEXP11PADDR, APBTARGEXP11PENABLE, APBTARGEXP11PWRITE, APBTARGEXP11PSTRB,             
  APBTARGEXP11PPROT, APBTARGEXP11PWDATA, APBTARGEXP11PSEL,                                   
  APBTARGEXP11PRDATA, APBTARGEXP11PREADY, APBTARGEXP11PSLVERR,                               
  APBTARGEXP12PADDR, APBTARGEXP12PENABLE, APBTARGEXP12PWRITE, APBTARGEXP12PSTRB,             
  APBTARGEXP12PPROT, APBTARGEXP12PWDATA, APBTARGEXP12PSEL,                                   
  APBTARGEXP12PRDATA, APBTARGEXP12PREADY, APBTARGEXP12PSLVERR,                               
  APBTARGEXP13PADDR, APBTARGEXP13PENABLE, APBTARGEXP13PWRITE, APBTARGEXP13PSTRB,             
  APBTARGEXP13PPROT, APBTARGEXP13PWDATA, APBTARGEXP13PSEL,                                   
  APBTARGEXP13PRDATA, APBTARGEXP13PREADY, APBTARGEXP13PSLVERR,                               
  APBTARGEXP14PADDR, APBTARGEXP14PENABLE, APBTARGEXP14PWRITE, APBTARGEXP14PSTRB,             
  APBTARGEXP14PPROT, APBTARGEXP14PWDATA, APBTARGEXP14PSEL,                                   
  APBTARGEXP14PRDATA, APBTARGEXP14PREADY, APBTARGEXP14PSLVERR,                               
  APBTARGEXP15PADDR, APBTARGEXP15PENABLE, APBTARGEXP15PWRITE, APBTARGEXP15PSTRB,             
  APBTARGEXP15PPROT, APBTARGEXP15PWDATA, APBTARGEXP15PSEL,                                   
  APBTARGEXP15PRDATA, APBTARGEXP15PREADY, APBTARGEXP15PSLVERR                                
);

  input         MTXHCLK;            
  input         MTXHRESETn;         
  input         AHB2APBHCLK;        

  input   [3:0] MTXREMAP;           
  output        APBQACTIVE;         

  input  [31:0] HADDRI;             
  input   [1:0] HTRANSI;            
  input   [2:0] HSIZEI;             
  input         HWRITEI;            
  input   [2:0] HBURSTI;            
  input   [3:0] HPROTI;             
  input   [1:0] MEMATTRI;           
  input  [31:0] HWDATAI;            
  output [31:0] HRDATAI;            
  output        HREADYI;            
  output  [1:0] HRESPI;             

  input  [31:0] HADDRD;             
  input   [1:0] HTRANSD;            
  input   [1:0] HMASTERD;           
  input   [2:0] HSIZED;             
  input   [2:0] HBURSTD;            
  input   [3:0] HPROTD;             
  input   [1:0] MEMATTRD;           
  input  [31:0] HWDATAD;            
  input         HWRITED;            
  input         EXREQD;             
  output [31:0] HRDATAD;            
  output        HREADYD;            
  output  [1:0] HRESPD;             
  output        EXRESPD;            

  input         HAUSERINITCM3DI;    
  input   [3:0] HWUSERINITCM3DI;    
  output  [2:0] HRUSERINITCM3DI;    

  input  [31:0] HADDRS;             
  input   [1:0] HTRANSS;            
  input   [1:0] HMASTERS;           
  input         HWRITES;            
  input   [2:0] HSIZES;             
  input         HMASTLOCKS;         
  input  [31:0] HWDATAS;            
  input   [2:0] HBURSTS;            
  input   [3:0] HPROTS;             
  input   [1:0] MEMATTRS;           
  input         EXREQS;             
  output        HREADYS;            
  output [31:0] HRDATAS;            
  output  [1:0] HRESPS;             
  output        EXRESPS;            

  input         HAUSERINITCM3S;     
  input   [3:0] HWUSERINITCM3S;     
  output  [2:0] HRUSERINITCM3S;     

  input         INITEXP0HSEL;       
  input  [31:0] INITEXP0HADDR;      
  input   [1:0] INITEXP0HTRANS;     
  input   [3:0] INITEXP0HMASTER;    
  input         INITEXP0HWRITE;     
  input   [2:0] INITEXP0HSIZE;      
  input         INITEXP0HMASTLOCK;  
  input  [31:0] INITEXP0HWDATA;     
  input   [2:0] INITEXP0HBURST;     
  input   [3:0] INITEXP0HPROT;      
  input   [1:0] INITEXP0MEMATTR;    
  input         INITEXP0EXREQ;      
  output        INITEXP0HREADY;     
  output [31:0] INITEXP0HRDATA;     
  output        INITEXP0HRESP;      
  output        INITEXP0EXRESP;     

  input         INITEXP0HAUSER;     
  input   [3:0] INITEXP0HWUSER;     
  output  [2:0] INITEXP0HRUSER;     

  input         INITEXP1HSEL;       
  input  [31:0] INITEXP1HADDR;      
  input   [1:0] INITEXP1HTRANS;     
  input   [3:0] INITEXP1HMASTER;    
  input         INITEXP1HWRITE;     
  input   [2:0] INITEXP1HSIZE;      
  input         INITEXP1HMASTLOCK;  
  input  [31:0] INITEXP1HWDATA;     
  input   [2:0] INITEXP1HBURST;     
  input   [3:0] INITEXP1HPROT;      
  input   [1:0] INITEXP1MEMATTR;    
  input         INITEXP1EXREQ;      
  output        INITEXP1HREADY;     
  output [31:0] INITEXP1HRDATA;     
  output        INITEXP1HRESP;      
  output        INITEXP1EXRESP;     

  input         INITEXP1HAUSER;     
  input   [3:0] INITEXP1HWUSER;     
  output  [2:0] INITEXP1HRUSER;     

  output        TARGEXP0HSEL;       
  output [31:0] TARGEXP0HADDR;      
  output  [1:0] TARGEXP0HTRANS;     
  output  [3:0] TARGEXP0HMASTER;    
  output        TARGEXP0HWRITE;     
  output  [2:0] TARGEXP0HSIZE;      
  output        TARGEXP0HMASTLOCK;  
  output [31:0] TARGEXP0HWDATA;     
  output  [2:0] TARGEXP0HBURST;     
  output  [3:0] TARGEXP0HPROT;      
  output  [1:0] TARGEXP0MEMATTR;    
  output        TARGEXP0EXREQ;      
  output        TARGEXP0HREADYMUX;  

  input         TARGEXP0HREADYOUT;  
  input  [31:0] TARGEXP0HRDATA;     
  input         TARGEXP0HRESP;      
  input         TARGEXP0EXRESP;     

  output        TARGEXP0HAUSER;     
  output  [3:0] TARGEXP0HWUSER;     
  input   [2:0] TARGEXP0HRUSER;     

  output        TARGEXP1HSEL;       
  output [31:0] TARGEXP1HADDR;      
  output  [1:0] TARGEXP1HTRANS;     
  output  [3:0] TARGEXP1HMASTER;    
  output        TARGEXP1HWRITE;     
  output  [2:0] TARGEXP1HSIZE;      
  output        TARGEXP1HMASTLOCK;  
  output [31:0] TARGEXP1HWDATA;     
  output  [2:0] TARGEXP1HBURST;     
  output  [3:0] TARGEXP1HPROT;      
  output  [1:0] TARGEXP1MEMATTR;    
  output        TARGEXP1EXREQ;      
  output        TARGEXP1HREADYMUX;  

  input         TARGEXP1HREADYOUT;  
  input  [31:0] TARGEXP1HRDATA;     
  input         TARGEXP1HRESP;      
  input         TARGEXP1EXRESP;     

  output        TARGEXP1HAUSER;     
  output  [3:0] TARGEXP1HWUSER;     
  input   [2:0] TARGEXP1HRUSER;     

  output        TARGFLASH0HSEL;      
  output [31:0] TARGFLASH0HADDR;     
  output  [1:0] TARGFLASH0HTRANS;    
  output  [3:0] TARGFLASH0HMASTER;   
  output        TARGFLASH0HWRITE;    
  output  [2:0] TARGFLASH0HSIZE;     
  output        TARGFLASH0HMASTLOCK; 
  output [31:0] TARGFLASH0HWDATA;    
  output  [2:0] TARGFLASH0HBURST;    
  output  [3:0] TARGFLASH0HPROT;     
  output  [1:0] TARGFLASH0MEMATTR;   
  output        TARGFLASH0EXREQ;     
  output        TARGFLASH0HREADYMUX; 

  input         TARGFLASH0HREADYOUT; 
  input  [31:0] TARGFLASH0HRDATA;    
  input         TARGFLASH0HRESP;     
  input         TARGFLASH0EXRESP;    

  output        TARGFLASH0HAUSER;    
  output  [3:0] TARGFLASH0HWUSER;    
  input   [2:0] TARGFLASH0HRUSER;    

  output        TARGSRAM0HSEL;      
  output [31:0] TARGSRAM0HADDR;     
  output  [1:0] TARGSRAM0HTRANS;    
  output  [3:0] TARGSRAM0HMASTER;   
  output        TARGSRAM0HWRITE;    
  output  [2:0] TARGSRAM0HSIZE;     
  output        TARGSRAM0HMASTLOCK; 
  output [31:0] TARGSRAM0HWDATA;    
  output  [2:0] TARGSRAM0HBURST;    
  output  [3:0] TARGSRAM0HPROT;     
  output  [1:0] TARGSRAM0MEMATTR;   
  output        TARGSRAM0EXREQ;     
  output        TARGSRAM0HREADYMUX; 

  input         TARGSRAM0HREADYOUT; 
  input  [31:0] TARGSRAM0HRDATA;    
  input         TARGSRAM0HRESP;     
  input         TARGSRAM0EXRESP;    

  output        TARGSRAM0HAUSER;    
  output  [3:0] TARGSRAM0HWUSER;    
  input   [2:0] TARGSRAM0HRUSER;    

  output        TARGSRAM1HSEL;      
  output [31:0] TARGSRAM1HADDR;     
  output  [1:0] TARGSRAM1HTRANS;    
  output  [3:0] TARGSRAM1HMASTER;   
  output        TARGSRAM1HWRITE;    
  output  [2:0] TARGSRAM1HSIZE;     
  output        TARGSRAM1HMASTLOCK; 
  output [31:0] TARGSRAM1HWDATA;    
  output  [2:0] TARGSRAM1HBURST;    
  output  [3:0] TARGSRAM1HPROT;     
  output  [1:0] TARGSRAM1MEMATTR;   
  output        TARGSRAM1EXREQ;     
  output        TARGSRAM1HREADYMUX; 

  input         TARGSRAM1HREADYOUT; 
  input  [31:0] TARGSRAM1HRDATA;    
  input         TARGSRAM1HRESP;     
  input         TARGSRAM1EXRESP;    

  output        TARGSRAM1HAUSER;    
  output  [3:0] TARGSRAM1HWUSER;    
  input   [2:0] TARGSRAM1HRUSER;    

  output        TARGSRAM2HSEL;      
  output [31:0] TARGSRAM2HADDR;     
  output  [1:0] TARGSRAM2HTRANS;    
  output  [3:0] TARGSRAM2HMASTER;   
  output        TARGSRAM2HWRITE;    
  output  [2:0] TARGSRAM2HSIZE;     
  output        TARGSRAM2HMASTLOCK; 
  output [31:0] TARGSRAM2HWDATA;    
  output  [2:0] TARGSRAM2HBURST;    
  output  [3:0] TARGSRAM2HPROT;     
  output  [1:0] TARGSRAM2MEMATTR;   
  output        TARGSRAM2EXREQ;     
  output        TARGSRAM2HREADYMUX; 

  input         TARGSRAM2HREADYOUT; 
  input  [31:0] TARGSRAM2HRDATA;    
  input         TARGSRAM2HRESP;     
  input         TARGSRAM2EXRESP;    

  output        TARGSRAM2HAUSER;    
  output  [3:0] TARGSRAM2HWUSER;    
  input   [2:0] TARGSRAM2HRUSER;    

  output        TARGSRAM3HSEL;      
  output [31:0] TARGSRAM3HADDR;     
  output  [1:0] TARGSRAM3HTRANS;    
  output  [3:0] TARGSRAM3HMASTER;   
  output        TARGSRAM3HWRITE;    
  output  [2:0] TARGSRAM3HSIZE;     
  output        TARGSRAM3HMASTLOCK; 
  output [31:0] TARGSRAM3HWDATA;    
  output  [2:0] TARGSRAM3HBURST;    
  output  [3:0] TARGSRAM3HPROT;     
  output  [1:0] TARGSRAM3MEMATTR;   
  output        TARGSRAM3EXREQ;     
  output        TARGSRAM3HREADYMUX; 

  input         TARGSRAM3HREADYOUT; 
  input  [31:0] TARGSRAM3HRDATA;    
  input         TARGSRAM3HRESP;     
  input         TARGSRAM3EXRESP;    

  output        TARGSRAM3HAUSER;    
  output  [3:0] TARGSRAM3HWUSER;    
  input   [2:0] TARGSRAM3HRUSER;    

  input         SCANENABLE;         
  input         SCANINHCLK;         
  output        SCANOUTHCLK;        

  output [11:0] APBTARGEXP0PADDR;   
  output        APBTARGEXP0PENABLE; 
  output        APBTARGEXP0PWRITE;  
  output  [3:0] APBTARGEXP0PSTRB;   
  output  [2:0] APBTARGEXP0PPROT;   
  output [31:0] APBTARGEXP0PWDATA;  
  output        APBTARGEXP0PSEL;    
  input  [31:0] APBTARGEXP0PRDATA;  
  input         APBTARGEXP0PREADY;  
  input         APBTARGEXP0PSLVERR; 

  output [11:0] APBTARGEXP1PADDR;   
  output        APBTARGEXP1PENABLE; 
  output        APBTARGEXP1PWRITE;  
  output  [3:0] APBTARGEXP1PSTRB;   
  output  [2:0] APBTARGEXP1PPROT;   
  output [31:0] APBTARGEXP1PWDATA;  
  output        APBTARGEXP1PSEL;    
  input  [31:0] APBTARGEXP1PRDATA;  
  input         APBTARGEXP1PREADY;  
  input         APBTARGEXP1PSLVERR; 

  output [11:0] APBTARGEXP2PADDR;   
  output        APBTARGEXP2PENABLE; 
  output        APBTARGEXP2PWRITE;  
  output  [3:0] APBTARGEXP2PSTRB;   
  output  [2:0] APBTARGEXP2PPROT;   
  output [31:0] APBTARGEXP2PWDATA;  
  output        APBTARGEXP2PSEL;    
  input  [31:0] APBTARGEXP2PRDATA;  
  input         APBTARGEXP2PREADY;  
  input         APBTARGEXP2PSLVERR; 

  output [11:0] APBTARGEXP3PADDR;   
  output        APBTARGEXP3PENABLE; 
  output        APBTARGEXP3PWRITE;  
  output  [3:0] APBTARGEXP3PSTRB;   
  output  [2:0] APBTARGEXP3PPROT;   
  output [31:0] APBTARGEXP3PWDATA;  
  output        APBTARGEXP3PSEL;    
  input  [31:0] APBTARGEXP3PRDATA;  
  input         APBTARGEXP3PREADY;  
  input         APBTARGEXP3PSLVERR; 

  output [11:0] APBTARGEXP4PADDR;   
  output        APBTARGEXP4PENABLE; 
  output        APBTARGEXP4PWRITE;  
  output  [3:0] APBTARGEXP4PSTRB;   
  output  [2:0] APBTARGEXP4PPROT;   
  output [31:0] APBTARGEXP4PWDATA;  
  output        APBTARGEXP4PSEL;    
  input  [31:0] APBTARGEXP4PRDATA;  
  input         APBTARGEXP4PREADY;  
  input         APBTARGEXP4PSLVERR; 

  output [11:0] APBTARGEXP5PADDR;   
  output        APBTARGEXP5PENABLE; 
  output        APBTARGEXP5PWRITE;  
  output  [3:0] APBTARGEXP5PSTRB;   
  output  [2:0] APBTARGEXP5PPROT;   
  output [31:0] APBTARGEXP5PWDATA;  
  output        APBTARGEXP5PSEL;    
  input  [31:0] APBTARGEXP5PRDATA;  
  input         APBTARGEXP5PREADY;  
  input         APBTARGEXP5PSLVERR; 

  output [11:0] APBTARGEXP6PADDR;   
  output        APBTARGEXP6PENABLE; 
  output        APBTARGEXP6PWRITE;  
  output  [3:0] APBTARGEXP6PSTRB;   
  output  [2:0] APBTARGEXP6PPROT;   
  output [31:0] APBTARGEXP6PWDATA;  
  output        APBTARGEXP6PSEL;    
  input  [31:0] APBTARGEXP6PRDATA;  
  input         APBTARGEXP6PREADY;  
  input         APBTARGEXP6PSLVERR; 

  output [11:0] APBTARGEXP7PADDR;   
  output        APBTARGEXP7PENABLE; 
  output        APBTARGEXP7PWRITE;  
  output  [3:0] APBTARGEXP7PSTRB;   
  output  [2:0] APBTARGEXP7PPROT;   
  output [31:0] APBTARGEXP7PWDATA;  
  output        APBTARGEXP7PSEL;    
  input  [31:0] APBTARGEXP7PRDATA;  
  input         APBTARGEXP7PREADY;  
  input         APBTARGEXP7PSLVERR; 

  output [11:0] APBTARGEXP8PADDR;   
  output        APBTARGEXP8PENABLE; 
  output        APBTARGEXP8PWRITE;  
  output  [3:0] APBTARGEXP8PSTRB;   
  output  [2:0] APBTARGEXP8PPROT;   
  output [31:0] APBTARGEXP8PWDATA;  
  output        APBTARGEXP8PSEL;    
  input  [31:0] APBTARGEXP8PRDATA;  
  input         APBTARGEXP8PREADY;  
  input         APBTARGEXP8PSLVERR; 

  output [11:0] APBTARGEXP9PADDR;   
  output        APBTARGEXP9PENABLE; 
  output        APBTARGEXP9PWRITE;  
  output  [3:0] APBTARGEXP9PSTRB;   
  output  [2:0] APBTARGEXP9PPROT;   
  output [31:0] APBTARGEXP9PWDATA;  
  output        APBTARGEXP9PSEL;    
  input  [31:0] APBTARGEXP9PRDATA;  
  input         APBTARGEXP9PREADY;  
  input         APBTARGEXP9PSLVERR; 

  output [11:0] APBTARGEXP10PADDR;   
  output        APBTARGEXP10PENABLE; 
  output        APBTARGEXP10PWRITE;  
  output  [3:0] APBTARGEXP10PSTRB;   
  output  [2:0] APBTARGEXP10PPROT;   
  output [31:0] APBTARGEXP10PWDATA;  
  output        APBTARGEXP10PSEL;    
  input  [31:0] APBTARGEXP10PRDATA;  
  input         APBTARGEXP10PREADY;  
  input         APBTARGEXP10PSLVERR; 

  output [11:0] APBTARGEXP11PADDR;   
  output        APBTARGEXP11PENABLE; 
  output        APBTARGEXP11PWRITE;  
  output  [3:0] APBTARGEXP11PSTRB;   
  output  [2:0] APBTARGEXP11PPROT;   
  output [31:0] APBTARGEXP11PWDATA;  
  output        APBTARGEXP11PSEL;    
  input  [31:0] APBTARGEXP11PRDATA;  
  input         APBTARGEXP11PREADY;  
  input         APBTARGEXP11PSLVERR; 

  output [11:0] APBTARGEXP12PADDR;   
  output        APBTARGEXP12PENABLE; 
  output        APBTARGEXP12PWRITE;  
  output  [3:0] APBTARGEXP12PSTRB;   
  output  [2:0] APBTARGEXP12PPROT;   
  output [31:0] APBTARGEXP12PWDATA;  
  output        APBTARGEXP12PSEL;    
  input  [31:0] APBTARGEXP12PRDATA;  
  input         APBTARGEXP12PREADY;  
  input         APBTARGEXP12PSLVERR; 

  output [11:0] APBTARGEXP13PADDR;   
  output        APBTARGEXP13PENABLE; 
  output        APBTARGEXP13PWRITE;  
  output  [3:0] APBTARGEXP13PSTRB;   
  output  [2:0] APBTARGEXP13PPROT;   
  output [31:0] APBTARGEXP13PWDATA;  
  output        APBTARGEXP13PSEL;    
  input  [31:0] APBTARGEXP13PRDATA;  
  input         APBTARGEXP13PREADY;  
  input         APBTARGEXP13PSLVERR; 

  output [11:0] APBTARGEXP14PADDR;   
  output        APBTARGEXP14PENABLE; 
  output        APBTARGEXP14PWRITE;  
  output  [3:0] APBTARGEXP14PSTRB;   
  output  [2:0] APBTARGEXP14PPROT;   
  output [31:0] APBTARGEXP14PWDATA;  
  output        APBTARGEXP14PSEL;    
  input  [31:0] APBTARGEXP14PRDATA;  
  input         APBTARGEXP14PREADY;  
  input         APBTARGEXP14PSLVERR; 

  output [11:0] APBTARGEXP15PADDR;   
  output        APBTARGEXP15PENABLE; 
  output        APBTARGEXP15PWRITE;  
  output  [3:0] APBTARGEXP15PSTRB;   
  output  [2:0] APBTARGEXP15PPROT;   
  output [31:0] APBTARGEXP15PWDATA;  
  output        APBTARGEXP15PSEL;    
  input  [31:0] APBTARGEXP15PRDATA;  
  input         APBTARGEXP15PREADY;  
  input         APBTARGEXP15PSLVERR; 


  wire          MTXHCLK;           
  wire          MTXHRESETn;        
  wire          AHB2APBHCLK;       

  wire    [3:0] MTXREMAP;          

  wire   [31:0] HADDRI;            
  wire    [1:0] HTRANSI;           
  wire    [2:0] HSIZEI;            
  wire          HWRITEI;           
  wire    [2:0] HBURSTI;           
  wire    [3:0] HPROTI;            
  wire    [1:0] MEMATTRI;          
  wire   [31:0] HWDATAI;           
  wire   [31:0] HRDATAI;           
  wire          HREADYI;           
  wire    [1:0] HRESPI;            

  wire   [31:0] HADDRD;            
  wire    [1:0] HTRANSD;           
  wire    [1:0] HMASTERD;          
  wire    [2:0] HSIZED;            
  wire    [2:0] HBURSTD;           
  wire    [3:0] HPROTD;            
  wire    [1:0] MEMATTRD;          
  wire   [31:0] HWDATAD;           
  wire          HWRITED;           
  wire          EXREQD;            
  wire   [31:0] HRDATAD;           
  wire          HREADYD;           
  wire    [1:0] HRESPD;            
  wire          EXRESPD;           

  wire   [31:0] HADDRS;            
  wire    [1:0] HTRANSS;           
  wire    [1:0] HMASTERS;          
  wire          HWRITES;           
  wire    [2:0] HSIZES;            
  wire          HMASTLOCKS;        
  wire   [31:0] HWDATAS;           
  wire    [2:0] HBURSTS;           
  wire    [3:0] HPROTS;            
  wire    [1:0] MEMATTRS;          
  wire          EXREQS;            
  wire          HREADYS;           
  wire   [31:0] HRDATAS;           
  wire    [1:0] HRESPS;            
  wire          EXRESPS;           

  wire          HAUSERINITCM3S;     
  wire    [3:0] HWUSERINITCM3S;     
  wire    [2:0] HRUSERINITCM3S;     


  wire          INITEXP0HSEL;      
  wire   [31:0] INITEXP0HADDR;     
  wire    [1:0] INITEXP0HTRANS;    
  wire    [3:0] INITEXP0HMASTER;   
  wire          INITEXP0HWRITE;    
  wire    [2:0] INITEXP0HSIZE;     
  wire          INITEXP0HMASTLOCK; 
  wire   [31:0] INITEXP0HWDATA;    
  wire    [2:0] INITEXP0HBURST;    
  wire    [3:0] INITEXP0HPROT;     
  wire    [1:0] INITEXP0MEMATTR;   
  wire          INITEXP0EXREQ;     
  wire          INITEXP0HREADY;    
  wire   [31:0] INITEXP0HRDATA;    
  wire          INITEXP0HRESP;     
  wire          INITEXP0EXRESP;    

  wire          INITEXP0HAUSER;    
  wire    [3:0] INITEXP0HWUSER;    
  wire    [2:0] INITEXP0HRUSER;    

  wire          INITEXP1HSEL;      
  wire   [31:0] INITEXP1HADDR;     
  wire    [1:0] INITEXP1HTRANS;    
  wire    [3:0] INITEXP1HMASTER;   
  wire          INITEXP1HWRITE;    
  wire    [2:0] INITEXP1HSIZE;     
  wire          INITEXP1HMASTLOCK; 
  wire   [31:0] INITEXP1HWDATA;    
  wire    [2:0] INITEXP1HBURST;    
  wire    [3:0] INITEXP1HPROT;     
  wire    [1:0] INITEXP1MEMATTR;   
  wire          INITEXP1EXREQ;     
  wire          INITEXP1HREADY;    
  wire   [31:0] INITEXP1HRDATA;    
  wire          INITEXP1HRESP;     
  wire          INITEXP1EXRESP;    

  wire          INITEXP1HAUSER;    
  wire    [3:0] INITEXP1HWUSER;    
  wire    [2:0] INITEXP1HRUSER;    

  wire          TARGEXP0HSEL;      
  wire   [31:0] TARGEXP0HADDR;     
  wire    [1:0] TARGEXP0HTRANS;    
  wire    [3:0] TARGEXP0HMASTER;   
  wire          TARGEXP0HWRITE;    
  wire    [2:0] TARGEXP0HSIZE;     
  wire          TARGEXP0HMASTLOCK; 
  wire   [31:0] TARGEXP0HWDATA;    
  wire    [2:0] TARGEXP0HBURST;    
  wire    [3:0] TARGEXP0HPROT;     
  wire    [1:0] TARGEXP0MEMATTR;   
  wire          TARGEXP0EXREQ;     
  wire          TARGEXP0HREADYMUX; 
  wire          TARGEXP0HREADYOUT; 
  wire   [31:0] TARGEXP0HRDATA;    
  wire          TARGEXP0HRESP;     
  wire          TARGEXP0EXRESP;    

  wire          TARGEXP0HAUSER;    
  wire    [3:0] TARGEXP0HWUSER;    
  wire    [2:0] TARGEXP0HRUSER;    

  wire          TARGEXP1HSEL;      
  wire   [31:0] TARGEXP1HADDR;     
  wire    [1:0] TARGEXP1HTRANS;    
  wire    [3:0] TARGEXP1HMASTER;   
  wire          TARGEXP1HWRITE;    
  wire    [2:0] TARGEXP1HSIZE;     
  wire          TARGEXP1HMASTLOCK; 
  wire   [31:0] TARGEXP1HWDATA;    
  wire    [2:0] TARGEXP1HBURST;    
  wire    [3:0] TARGEXP1HPROT;     
  wire    [1:0] TARGEXP1MEMATTR;   
  wire          TARGEXP1EXREQ;     
  wire          TARGEXP1HREADYMUX; 
  wire          TARGEXP1HREADYOUT; 
  wire   [31:0] TARGEXP1HRDATA;    
  wire          TARGEXP1HRESP;     
  wire          TARGEXP1EXRESP;    

  wire          TARGEXP1HAUSER;    
  wire    [3:0] TARGEXP1HWUSER;    
  wire    [2:0] TARGEXP1HRUSER;    

  wire          TARGFLASH0HSEL;      
  wire   [31:0] TARGFLASH0HADDR;     
  wire    [1:0] TARGFLASH0HTRANS;    
  wire    [3:0] TARGFLASH0HMASTER;   
  wire          TARGFLASH0HWRITE;    
  wire    [2:0] TARGFLASH0HSIZE;     
  wire          TARGFLASH0HMASTLOCK; 
  wire   [31:0] TARGFLASH0HWDATA;    
  wire    [2:0] TARGFLASH0HBURST;    
  wire    [3:0] TARGFLASH0HPROT;     
  wire    [1:0] TARGFLASH0MEMATTR;   
  wire          TARGFLASH0EXREQ;     
  wire          TARGFLASH0HREADYMUX; 
  wire          TARGFLASH0HREADYOUT; 
  wire   [31:0] TARGFLASH0HRDATA;    
  wire          TARGFLASH0HRESP;     
  wire          TARGFLASH0EXRESP;    

  wire          TARGFLASH0HAUSER;    
  wire    [3:0] TARGFLASH0HWUSER;    
  wire    [2:0] TARGFLASH0HRUSER;    

  wire          TARGSRAM0HSEL;      
  wire   [31:0] TARGSRAM0HADDR;     
  wire    [1:0] TARGSRAM0HTRANS;    
  wire    [3:0] TARGSRAM0HMASTER;   
  wire          TARGSRAM0HWRITE;    
  wire    [2:0] TARGSRAM0HSIZE;     
  wire          TARGSRAM0HMASTLOCK; 
  wire   [31:0] TARGSRAM0HWDATA;    
  wire    [2:0] TARGSRAM0HBURST;    
  wire    [3:0] TARGSRAM0HPROT;     
  wire    [1:0] TARGSRAM0MEMATTR;   
  wire          TARGSRAM0EXREQ;     
  wire          TARGSRAM0HREADYMUX; 
  wire          TARGSRAM0HREADYOUT; 
  wire   [31:0] TARGSRAM0HRDATA;    
  wire          TARGSRAM0HRESP;     
  wire          TARGSRAM0EXRESP;    

  wire          TARGSRAM0HAUSER;    
  wire    [3:0] TARGSRAM0HWUSER;    
  wire    [2:0] TARGSRAM0HRUSER;    

  wire          TARGSRAM1HSEL;      
  wire   [31:0] TARGSRAM1HADDR;     
  wire    [1:0] TARGSRAM1HTRANS;    
  wire    [3:0] TARGSRAM1HMASTER;   
  wire          TARGSRAM1HWRITE;    
  wire    [2:0] TARGSRAM1HSIZE;     
  wire          TARGSRAM1HMASTLOCK; 
  wire   [31:0] TARGSRAM1HWDATA;    
  wire    [2:0] TARGSRAM1HBURST;    
  wire    [3:0] TARGSRAM1HPROT;     
  wire    [1:0] TARGSRAM1MEMATTR;   
  wire          TARGSRAM1EXREQ;     
  wire          TARGSRAM1HREADYMUX; 
  wire          TARGSRAM1HREADYOUT; 
  wire   [31:0] TARGSRAM1HRDATA;    
  wire          TARGSRAM1HRESP;     
  wire          TARGSRAM1EXRESP;    

  wire          TARGSRAM1HAUSER;    
  wire    [3:0] TARGSRAM1HWUSER;    
  wire    [2:0] TARGSRAM1HRUSER;    

  wire          TARGSRAM2HSEL;      
  wire   [31:0] TARGSRAM2HADDR;     
  wire    [1:0] TARGSRAM2HTRANS;    
  wire    [3:0] TARGSRAM2HMASTER;   
  wire          TARGSRAM2HWRITE;    
  wire    [2:0] TARGSRAM2HSIZE;     
  wire          TARGSRAM2HMASTLOCK; 
  wire   [31:0] TARGSRAM2HWDATA;    
  wire    [2:0] TARGSRAM2HBURST;    
  wire    [3:0] TARGSRAM2HPROT;     
  wire    [1:0] TARGSRAM2MEMATTR;   
  wire          TARGSRAM2EXREQ;     
  wire          TARGSRAM2HREADYMUX; 
  wire          TARGSRAM2HREADYOUT; 
  wire   [31:0] TARGSRAM2HRDATA;    
  wire          TARGSRAM2HRESP;     
  wire          TARGSRAM2EXRESP;    

  wire          TARGSRAM2HAUSER;    
  wire    [3:0] TARGSRAM2HWUSER;    
  wire    [2:0] TARGSRAM2HRUSER;    

  wire          TARGSRAM3HSEL;      
  wire   [31:0] TARGSRAM3HADDR;     
  wire    [1:0] TARGSRAM3HTRANS;    
  wire    [3:0] TARGSRAM3HMASTER;   
  wire          TARGSRAM3HWRITE;    
  wire    [2:0] TARGSRAM3HSIZE;     
  wire          TARGSRAM3HMASTLOCK; 
  wire   [31:0] TARGSRAM3HWDATA;    
  wire    [2:0] TARGSRAM3HBURST;    
  wire    [3:0] TARGSRAM3HPROT;     
  wire    [1:0] TARGSRAM3MEMATTR;   
  wire          TARGSRAM3EXREQ;     
  wire          TARGSRAM3HREADYMUX; 
  wire          TARGSRAM3HREADYOUT; 
  wire   [31:0] TARGSRAM3HRDATA;    
  wire          TARGSRAM3HRESP;     
  wire          TARGSRAM3EXRESP;    

  wire          TARGSRAM3HAUSER;    
  wire    [3:0] TARGSRAM3HWUSER;    
  wire    [2:0] TARGSRAM3HRUSER;    

  wire          targapb0hsel;       
  wire   [31:0] targapb0haddr;      
  wire    [1:0] targapb0htrans;     
  wire          targapb0hwrite;     
  wire    [2:0] targapb0hsize;      
  wire   [31:0] targapb0hwdata;     
  wire    [3:0] targapb0hprot;      
  wire          targapb0hreadymux;  
  wire          targapb0hreadyout;  
  wire   [31:0] targapb0hrdata;     
  wire          targapb0hresp;      

  wire          SCANENABLE;         
  wire          SCANINHCLK;         
  wire          SCANOUTHCLK;        

  wire   [11:0] APBTARGEXP0PADDR;   
  wire          APBTARGEXP0PENABLE; 
  wire          APBTARGEXP0PWRITE;  
  wire    [3:0] APBTARGEXP0PSTRB;   
  wire    [2:0] APBTARGEXP0PPROT;   
  wire   [31:0] APBTARGEXP0PWDATA;  
  wire          APBTARGEXP0PSEL;    
  wire   [31:0] APBTARGEXP0PRDATA;  
  wire          APBTARGEXP0PREADY;  
  wire          APBTARGEXP0PSLVERR; 

  wire   [11:0] APBTARGEXP1PADDR;   
  wire          APBTARGEXP1PENABLE; 
  wire          APBTARGEXP1PWRITE;  
  wire    [3:0] APBTARGEXP1PSTRB;   
  wire    [2:0] APBTARGEXP1PPROT;   
  wire   [31:0] APBTARGEXP1PWDATA;  
  wire          APBTARGEXP1PSEL;    
  wire   [31:0] APBTARGEXP1PRDATA;  
  wire          APBTARGEXP1PREADY;  
  wire          APBTARGEXP1PSLVERR; 

  wire   [11:0] APBTARGEXP2PADDR;   
  wire          APBTARGEXP2PENABLE; 
  wire          APBTARGEXP2PWRITE;  
  wire    [3:0] APBTARGEXP2PSTRB;   
  wire    [2:0] APBTARGEXP2PPROT;   
  wire   [31:0] APBTARGEXP2PWDATA;  
  wire          APBTARGEXP2PSEL;    
  wire   [31:0] APBTARGEXP2PRDATA;  
  wire          APBTARGEXP2PREADY;  
  wire          APBTARGEXP2PSLVERR; 

  wire   [11:0] APBTARGEXP3PADDR;   
  wire          APBTARGEXP3PENABLE; 
  wire          APBTARGEXP3PWRITE;  
  wire    [3:0] APBTARGEXP3PSTRB;   
  wire    [2:0] APBTARGEXP3PPROT;   
  wire   [31:0] APBTARGEXP3PWDATA;  
  wire          APBTARGEXP3PSEL;    
  wire   [31:0] APBTARGEXP3PRDATA;  
  wire          APBTARGEXP3PREADY;  
  wire          APBTARGEXP3PSLVERR; 

  wire   [11:0] APBTARGEXP4PADDR;   
  wire          APBTARGEXP4PENABLE; 
  wire          APBTARGEXP4PWRITE;  
  wire    [3:0] APBTARGEXP4PSTRB;   
  wire    [2:0] APBTARGEXP4PPROT;   
  wire   [31:0] APBTARGEXP4PWDATA;  
  wire          APBTARGEXP4PSEL;    
  wire   [31:0] APBTARGEXP4PRDATA;  
  wire          APBTARGEXP4PREADY;  
  wire          APBTARGEXP4PSLVERR; 

  wire   [11:0] APBTARGEXP5PADDR;   
  wire          APBTARGEXP5PENABLE; 
  wire          APBTARGEXP5PWRITE;  
  wire    [3:0] APBTARGEXP5PSTRB;   
  wire    [2:0] APBTARGEXP5PPROT;   
  wire   [31:0] APBTARGEXP5PWDATA;  
  wire          APBTARGEXP5PSEL;    
  wire   [31:0] APBTARGEXP5PRDATA;  
  wire          APBTARGEXP5PREADY;  
  wire          APBTARGEXP5PSLVERR; 

  wire   [11:0] APBTARGEXP6PADDR;   
  wire          APBTARGEXP6PENABLE; 
  wire          APBTARGEXP6PWRITE;  
  wire    [3:0] APBTARGEXP6PSTRB;   
  wire    [2:0] APBTARGEXP6PPROT;   
  wire   [31:0] APBTARGEXP6PWDATA;  
  wire          APBTARGEXP6PSEL;    
  wire   [31:0] APBTARGEXP6PRDATA;  
  wire          APBTARGEXP6PREADY;  
  wire          APBTARGEXP6PSLVERR; 

  wire   [11:0] APBTARGEXP7PADDR;   
  wire          APBTARGEXP7PENABLE; 
  wire          APBTARGEXP7PWRITE;  
  wire    [3:0] APBTARGEXP7PSTRB;   
  wire    [2:0] APBTARGEXP7PPROT;   
  wire   [31:0] APBTARGEXP7PWDATA;  
  wire          APBTARGEXP7PSEL;    
  wire   [31:0] APBTARGEXP7PRDATA;  
  wire          APBTARGEXP7PREADY;  
  wire          APBTARGEXP7PSLVERR; 

  wire   [11:0] APBTARGEXP8PADDR;   
  wire          APBTARGEXP8PENABLE; 
  wire          APBTARGEXP8PWRITE;  
  wire    [3:0] APBTARGEXP8PSTRB;   
  wire    [2:0] APBTARGEXP8PPROT;   
  wire   [31:0] APBTARGEXP8PWDATA;  
  wire          APBTARGEXP8PSEL;    
  wire   [31:0] APBTARGEXP8PRDATA;  
  wire          APBTARGEXP8PREADY;  
  wire          APBTARGEXP8PSLVERR; 

  wire   [11:0] APBTARGEXP9PADDR;   
  wire          APBTARGEXP9PENABLE; 
  wire          APBTARGEXP9PWRITE;  
  wire    [3:0] APBTARGEXP9PSTRB;   
  wire    [2:0] APBTARGEXP9PPROT;   
  wire   [31:0] APBTARGEXP9PWDATA;  
  wire          APBTARGEXP9PSEL;    
  wire   [31:0] APBTARGEXP9PRDATA;  
  wire          APBTARGEXP9PREADY;  
  wire          APBTARGEXP9PSLVERR; 

  wire   [11:0] APBTARGEXP10PADDR;   
  wire          APBTARGEXP10PENABLE; 
  wire          APBTARGEXP10PWRITE;  
  wire    [3:0] APBTARGEXP10PSTRB;   
  wire    [2:0] APBTARGEXP10PPROT;   
  wire   [31:0] APBTARGEXP10PWDATA;  
  wire          APBTARGEXP10PSEL;    
  wire   [31:0] APBTARGEXP10PRDATA;  
  wire          APBTARGEXP10PREADY;  
  wire          APBTARGEXP10PSLVERR; 

  wire   [11:0] APBTARGEXP11PADDR;   
  wire          APBTARGEXP11PENABLE; 
  wire          APBTARGEXP11PWRITE;  
  wire    [3:0] APBTARGEXP11PSTRB;   
  wire    [2:0] APBTARGEXP11PPROT;   
  wire   [31:0] APBTARGEXP11PWDATA;  
  wire          APBTARGEXP11PSEL;    
  wire   [31:0] APBTARGEXP11PRDATA;  
  wire          APBTARGEXP11PREADY;  
  wire          APBTARGEXP11PSLVERR; 

  wire   [11:0] APBTARGEXP12PADDR;   
  wire          APBTARGEXP12PENABLE; 
  wire          APBTARGEXP12PWRITE;  
  wire    [3:0] APBTARGEXP12PSTRB;   
  wire    [2:0] APBTARGEXP12PPROT;   
  wire   [31:0] APBTARGEXP12PWDATA;  
  wire          APBTARGEXP12PSEL;    
  wire   [31:0] APBTARGEXP12PRDATA;  
  wire          APBTARGEXP12PREADY;  
  wire          APBTARGEXP12PSLVERR; 

  wire   [11:0] APBTARGEXP13PADDR;   
  wire          APBTARGEXP13PENABLE; 
  wire          APBTARGEXP13PWRITE;  
  wire    [3:0] APBTARGEXP13PSTRB;   
  wire    [2:0] APBTARGEXP13PPROT;   
  wire   [31:0] APBTARGEXP13PWDATA;  
  wire          APBTARGEXP13PSEL;    
  wire   [31:0] APBTARGEXP13PRDATA;  
  wire          APBTARGEXP13PREADY;  
  wire          APBTARGEXP13PSLVERR; 

  wire   [11:0] APBTARGEXP14PADDR;   
  wire          APBTARGEXP14PENABLE; 
  wire          APBTARGEXP14PWRITE;  
  wire    [3:0] APBTARGEXP14PSTRB;   
  wire    [2:0] APBTARGEXP14PPROT;   
  wire   [31:0] APBTARGEXP14PWDATA;  
  wire          APBTARGEXP14PSEL;    
  wire   [31:0] APBTARGEXP14PRDATA;  
  wire          APBTARGEXP14PREADY;  
  wire          APBTARGEXP14PSLVERR; 

  wire   [11:0] APBTARGEXP15PADDR;   
  wire          APBTARGEXP15PENABLE; 
  wire          APBTARGEXP15PWRITE;  
  wire    [3:0] APBTARGEXP15PSTRB;   
  wire    [2:0] APBTARGEXP15PPROT;   
  wire   [31:0] APBTARGEXP15PWDATA;  
  wire          APBTARGEXP15PSEL;    
  wire   [31:0] APBTARGEXP15PRDATA;  
  wire          APBTARGEXP15PREADY;  
  wire          APBTARGEXP15PSLVERR; 


  wire   [31:0] hrdatac;           
  wire          hreadyc;           
  wire    [1:0] hrespc;            
  wire          exrespc;           

  wire   [31:0] haddrc;            
  wire   [31:0] hwdatac;           
  wire    [1:0] htransc;           
  wire          hwritec;           
  wire    [2:0] hsizec;            
  wire    [2:0] hburstc;           
  wire    [3:0] hprotc;            
  wire          exreqc;            
  wire    [1:0] memattrc;          

  wire    [1:0] i_initexp0hresp;   
  wire    [1:0] i_initexp1hresp;   
  wire    [1:0] i_targexp0hresp;   
  wire    [1:0] i_targexp1hresp;   
  wire    [1:0] i_targflash0hresp; 
  wire    [1:0] i_targsram0hresp;  
  wire    [1:0] i_targsram1hresp;  
  wire    [1:0] i_targsram2hresp;  
  wire    [1:0] i_targsram3hresp;  
  wire    [1:0] i_targapb0hresp;   

  wire   [15:0] ahb2apb_paddr;     
  wire          ahb2apb_penable;   
  wire          ahb2apb_pwrite;    
  wire    [3:0] ahb2apb_pstrb;     
  wire    [2:0] ahb2apb_pprot;     
  wire   [31:0] ahb2apb_pwdata;    
  wire          ahb2apb_psel;      
  wire   [31:0] ahb2apb_prdata;    
  wire          ahb2apb_pready;    
  wire          ahb2apb_pslverr;   


  wire          hreadyoutinitcm3s;  
  wire          hreadyoutinitexp0;  
  wire          hreadyoutinitexp1;  


  assign HREADYS           = hreadyoutinitcm3s;     
  assign INITEXP0HREADY    = hreadyoutinitexp0;     
  assign INITEXP1HREADY    = hreadyoutinitexp1;     

  assign memattrc          = HTRANSD[1] ? MEMATTRD  : MEMATTRI;

  assign INITEXP0HRESP     = i_initexp0hresp[0];
  assign INITEXP1HRESP     = i_initexp1hresp[0];

  assign i_targexp0hresp   = {1'b0,TARGEXP0HRESP};
  assign i_targexp1hresp   = {1'b0,TARGEXP1HRESP};
  assign i_targflash0hresp = {1'b0,TARGFLASH0HRESP};
  assign i_targsram0hresp  = {1'b0,TARGSRAM0HRESP};
  assign i_targsram1hresp  = {1'b0,TARGSRAM1HRESP};
  assign i_targsram2hresp  = {1'b0,TARGSRAM2HRESP};
  assign i_targsram3hresp  = {1'b0,TARGSRAM3HRESP};
  assign i_targapb0hresp   = {1'b0,targapb0hresp};

  assign APBTARGEXP0PADDR   = ahb2apb_paddr[11:0];
  assign APBTARGEXP0PENABLE = ahb2apb_penable;
  assign APBTARGEXP0PWRITE  = ahb2apb_pwrite;
  assign APBTARGEXP0PSTRB   = ahb2apb_pstrb;
  assign APBTARGEXP0PPROT   = ahb2apb_pprot;
  assign APBTARGEXP0PWDATA  = ahb2apb_pwdata;

  assign APBTARGEXP1PADDR   = ahb2apb_paddr[11:0];
  assign APBTARGEXP1PENABLE = ahb2apb_penable;
  assign APBTARGEXP1PWRITE  = ahb2apb_pwrite;
  assign APBTARGEXP1PSTRB   = ahb2apb_pstrb;
  assign APBTARGEXP1PPROT   = ahb2apb_pprot;
  assign APBTARGEXP1PWDATA  = ahb2apb_pwdata;

  assign APBTARGEXP2PADDR   = ahb2apb_paddr[11:0];
  assign APBTARGEXP2PENABLE = ahb2apb_penable;
  assign APBTARGEXP2PWRITE  = ahb2apb_pwrite;
  assign APBTARGEXP2PSTRB   = ahb2apb_pstrb;
  assign APBTARGEXP2PPROT   = ahb2apb_pprot;
  assign APBTARGEXP2PWDATA  = ahb2apb_pwdata;

  assign APBTARGEXP3PADDR   = ahb2apb_paddr[11:0];
  assign APBTARGEXP3PENABLE = ahb2apb_penable;
  assign APBTARGEXP3PWRITE  = ahb2apb_pwrite;
  assign APBTARGEXP3PSTRB   = ahb2apb_pstrb;
  assign APBTARGEXP3PPROT   = ahb2apb_pprot;
  assign APBTARGEXP3PWDATA  = ahb2apb_pwdata;

  assign APBTARGEXP4PADDR   = ahb2apb_paddr[11:0];
  assign APBTARGEXP4PENABLE = ahb2apb_penable;
  assign APBTARGEXP4PWRITE  = ahb2apb_pwrite;
  assign APBTARGEXP4PSTRB   = ahb2apb_pstrb;
  assign APBTARGEXP4PPROT   = ahb2apb_pprot;
  assign APBTARGEXP4PWDATA  = ahb2apb_pwdata;

  assign APBTARGEXP5PADDR   = ahb2apb_paddr[11:0];
  assign APBTARGEXP5PENABLE = ahb2apb_penable;
  assign APBTARGEXP5PWRITE  = ahb2apb_pwrite;
  assign APBTARGEXP5PSTRB   = ahb2apb_pstrb;
  assign APBTARGEXP5PPROT   = ahb2apb_pprot;
  assign APBTARGEXP5PWDATA  = ahb2apb_pwdata;

  assign APBTARGEXP6PADDR   = ahb2apb_paddr[11:0];
  assign APBTARGEXP6PENABLE = ahb2apb_penable;
  assign APBTARGEXP6PWRITE  = ahb2apb_pwrite;
  assign APBTARGEXP6PSTRB   = ahb2apb_pstrb;
  assign APBTARGEXP6PPROT   = ahb2apb_pprot;
  assign APBTARGEXP6PWDATA  = ahb2apb_pwdata;

  assign APBTARGEXP7PADDR   = ahb2apb_paddr[11:0];
  assign APBTARGEXP7PENABLE = ahb2apb_penable;
  assign APBTARGEXP7PWRITE  = ahb2apb_pwrite;
  assign APBTARGEXP7PSTRB   = ahb2apb_pstrb;
  assign APBTARGEXP7PPROT   = ahb2apb_pprot;
  assign APBTARGEXP7PWDATA  = ahb2apb_pwdata;

  assign APBTARGEXP8PADDR   = ahb2apb_paddr[11:0];
  assign APBTARGEXP8PENABLE = ahb2apb_penable;
  assign APBTARGEXP8PWRITE  = ahb2apb_pwrite;
  assign APBTARGEXP8PSTRB   = ahb2apb_pstrb;
  assign APBTARGEXP8PPROT   = ahb2apb_pprot;
  assign APBTARGEXP8PWDATA  = ahb2apb_pwdata;

  assign APBTARGEXP9PADDR   = ahb2apb_paddr[11:0];
  assign APBTARGEXP9PENABLE = ahb2apb_penable;
  assign APBTARGEXP9PWRITE  = ahb2apb_pwrite;
  assign APBTARGEXP9PSTRB   = ahb2apb_pstrb;
  assign APBTARGEXP9PPROT   = ahb2apb_pprot;
  assign APBTARGEXP9PWDATA  = ahb2apb_pwdata;

  assign APBTARGEXP10PADDR   = ahb2apb_paddr[11:0];
  assign APBTARGEXP10PENABLE = ahb2apb_penable;
  assign APBTARGEXP10PWRITE  = ahb2apb_pwrite;
  assign APBTARGEXP10PSTRB   = ahb2apb_pstrb;
  assign APBTARGEXP10PPROT   = ahb2apb_pprot;
  assign APBTARGEXP10PWDATA  = ahb2apb_pwdata;

  assign APBTARGEXP11PADDR   = ahb2apb_paddr[11:0];
  assign APBTARGEXP11PENABLE = ahb2apb_penable;
  assign APBTARGEXP11PWRITE  = ahb2apb_pwrite;
  assign APBTARGEXP11PSTRB   = ahb2apb_pstrb;
  assign APBTARGEXP11PPROT   = ahb2apb_pprot;
  assign APBTARGEXP11PWDATA  = ahb2apb_pwdata;

  assign APBTARGEXP12PADDR   = ahb2apb_paddr[11:0];
  assign APBTARGEXP12PENABLE = ahb2apb_penable;
  assign APBTARGEXP12PWRITE  = ahb2apb_pwrite;
  assign APBTARGEXP12PSTRB   = ahb2apb_pstrb;
  assign APBTARGEXP12PPROT   = ahb2apb_pprot;
  assign APBTARGEXP12PWDATA  = ahb2apb_pwdata;

  assign APBTARGEXP13PADDR   = ahb2apb_paddr[11:0];
  assign APBTARGEXP13PENABLE = ahb2apb_penable;
  assign APBTARGEXP13PWRITE  = ahb2apb_pwrite;
  assign APBTARGEXP13PSTRB   = ahb2apb_pstrb;
  assign APBTARGEXP13PPROT   = ahb2apb_pprot;
  assign APBTARGEXP13PWDATA  = ahb2apb_pwdata;

  assign APBTARGEXP14PADDR   = ahb2apb_paddr[11:0];
  assign APBTARGEXP14PENABLE = ahb2apb_penable;
  assign APBTARGEXP14PWRITE  = ahb2apb_pwrite;
  assign APBTARGEXP14PSTRB   = ahb2apb_pstrb;
  assign APBTARGEXP14PPROT   = ahb2apb_pprot;
  assign APBTARGEXP14PWDATA  = ahb2apb_pwdata;

  assign APBTARGEXP15PADDR   = ahb2apb_paddr[11:0];
  assign APBTARGEXP15PENABLE = ahb2apb_penable;
  assign APBTARGEXP15PWRITE  = ahb2apb_pwrite;
  assign APBTARGEXP15PSTRB   = ahb2apb_pstrb;
  assign APBTARGEXP15PPROT   = ahb2apb_pprot;
  assign APBTARGEXP15PWDATA  = ahb2apb_pwdata;


  sse710_integration_example_f0_ahb_code_mux u_sse710_integration_example_f0_ahb_code_mux (
     .HCLK(       MTXHCLK          ),   
     .HRESETn(    MTXHRESETn       ),   

     .HADDRI(     HADDRI           ),   
     .HTRANSI(    HTRANSI          ),   
     .HSIZEI(     HSIZEI           ),   
     .HBURSTI(    HBURSTI          ),   
     .HPROTI(     HPROTI           ),   
     .HADDRD(     HADDRD           ),   
     .HTRANSD(    HTRANSD          ),   
     .HSIZED(     HSIZED           ),   
     .HBURSTD(    HBURSTD          ),   
     .HPROTD(     HPROTD           ),   
     .HWDATAD(    HWDATAD          ),   
     .HWRITED(    HWRITED          ),   
     .EXREQD(     EXREQD           ),   

     .HRDATAC(    hrdatac          ),   
     .HREADYC(    hreadyc          ),   
     .HRESPC(     hrespc           ),   
     .EXRESPC(    exrespc          ),   

     .HRDATAI(    HRDATAI          ),   
     .HREADYI(    HREADYI          ),   
     .HRESPI(     HRESPI           ),   
     .HRDATAD(    HRDATAD          ),   
     .HREADYD(    HREADYD          ),   
     .HRESPD(     HRESPD           ),   
     .EXRESPD(    EXRESPD          ),   

     .HADDRC(     haddrc           ),   
     .HWDATAC(    hwdatac          ),   
     .HTRANSC(    htransc          ),   
     .HWRITEC(    hwritec          ),   
     .HSIZEC(     hsizec           ),   
     .HBURSTC(    hburstc          ),   
     .HPROTC(     hprotc           ),   
     .EXREQC(     exreqc           )    
  );


  sse710_integration_example_f0_ahb_mtx u_sse710_integration_example_f0_ahb_mtx (
     .HCLK(                 MTXHCLK                  ),      
     .HRESETn(              MTXHRESETn               ),      

     .REMAP(                MTXREMAP                 ),

     .HSELINITCM3DI(        1'b1                     ),
     .HADDRINITCM3DI(       haddrc                   ),
     .HTRANSINITCM3DI(      htransc                  ),
     .HWRITEINITCM3DI(      hwritec                  ),
     .HSIZEINITCM3DI(       hsizec                   ),
     .HBURSTINITCM3DI(      hburstc                  ),
     .HPROTINITCM3DI(       hprotc                   ),
     .HMASTERINITCM3DI(     {2'b00,HMASTERD}         ),
     .HWDATAINITCM3DI(      hwdatac                  ),
     .HMASTLOCKINITCM3DI(   1'b0                     ),
     .HREADYINITCM3DI(       hreadyc                 ),
     .HAUSERINITCM3DI(      {HAUSERINITCM3DI,memattrc,exreqc} ),
     .HWUSERINITCM3DI(      {HWUSERINITCM3DI}        ),

     .HRDATAINITCM3DI(      hrdatac                  ),
     .HREADYOUTINITCM3DI(   hreadyc                  ),
     .HRESPINITCM3DI(       hrespc                   ),
     .HRUSERINITCM3DI(      {HRUSERINITCM3DI,exrespc}),

     .HSELINITCM3S(         1'b1                     ),
     .HADDRINITCM3S(        HADDRS                   ),
     .HTRANSINITCM3S(       HTRANSS                  ),
     .HWRITEINITCM3S(       HWRITES                  ),
     .HSIZEINITCM3S(        HSIZES                   ),
     .HBURSTINITCM3S(       HBURSTS                  ),
     .HPROTINITCM3S(        HPROTS                   ),
     .HMASTERINITCM3S(      {2'b00,HMASTERS}         ),
     .HWDATAINITCM3S(       HWDATAS                  ),
     .HMASTLOCKINITCM3S(    HMASTLOCKS               ),
     .HREADYINITCM3S(       hreadyoutinitcm3s        ),
     .HAUSERINITCM3S(       {HAUSERINITCM3S,MEMATTRS,EXREQS}),
     .HWUSERINITCM3S(       HWUSERINITCM3S           ),

     .HRDATAINITCM3S(       HRDATAS                  ),
     .HREADYOUTINITCM3S(    hreadyoutinitcm3s        ),
     .HRESPINITCM3S(        HRESPS                   ),
     .HRUSERINITCM3S(       {HRUSERINITCM3S,EXRESPS} ),

     .HSELINITEXP0(         INITEXP0HSEL             ),
     .HADDRINITEXP0(        INITEXP0HADDR            ),
     .HTRANSINITEXP0(       INITEXP0HTRANS           ),
     .HWRITEINITEXP0(       INITEXP0HWRITE           ),
     .HSIZEINITEXP0(        INITEXP0HSIZE            ),
     .HBURSTINITEXP0(       INITEXP0HBURST           ),
     .HPROTINITEXP0(        INITEXP0HPROT            ),
     .HMASTERINITEXP0(      INITEXP0HMASTER          ),
     .HWDATAINITEXP0(       INITEXP0HWDATA           ),
     .HMASTLOCKINITEXP0(    INITEXP0HMASTLOCK        ),
     .HREADYINITEXP0(       hreadyoutinitexp0        ),
     .HAUSERINITEXP0(       {INITEXP0HAUSER,INITEXP0MEMATTR,INITEXP0EXREQ} ),
     .HWUSERINITEXP0(       INITEXP0HWUSER           ),

     .HRDATAINITEXP0(       INITEXP0HRDATA           ),
     .HREADYOUTINITEXP0(    hreadyoutinitexp0        ),
     .HRESPINITEXP0(        i_initexp0hresp          ),
     .HRUSERINITEXP0(       {INITEXP0HRUSER,INITEXP0EXRESP} ),

     .HSELINITEXP1(         INITEXP1HSEL             ),
     .HADDRINITEXP1(        INITEXP1HADDR            ),
     .HTRANSINITEXP1(       INITEXP1HTRANS           ),
     .HWRITEINITEXP1(       INITEXP1HWRITE           ),
     .HSIZEINITEXP1(        INITEXP1HSIZE            ),
     .HBURSTINITEXP1(       INITEXP1HBURST           ),
     .HPROTINITEXP1(        INITEXP1HPROT            ),
     .HMASTERINITEXP1(      INITEXP1HMASTER          ),
     .HWDATAINITEXP1(       INITEXP1HWDATA           ),
     .HMASTLOCKINITEXP1(    INITEXP1HMASTLOCK        ),
     .HREADYINITEXP1(       hreadyoutinitexp1        ),
     .HAUSERINITEXP1(       {INITEXP1HAUSER,INITEXP1MEMATTR,INITEXP1EXREQ} ),
     .HWUSERINITEXP1(       INITEXP1HWUSER           ),

     .HRDATAINITEXP1(       INITEXP1HRDATA           ),
     .HREADYOUTINITEXP1(    hreadyoutinitexp1        ),
     .HRESPINITEXP1(        i_initexp1hresp          ),
     .HRUSERINITEXP1(       {INITEXP1HRUSER,INITEXP1EXRESP} ),

     .HSELTARGFLASH0(       TARGFLASH0HSEL             ),
     .HADDRTARGFLASH0(      TARGFLASH0HADDR            ),
     .HTRANSTARGFLASH0(     TARGFLASH0HTRANS           ),
     .HWRITETARGFLASH0(     TARGFLASH0HWRITE           ),
     .HSIZETARGFLASH0(      TARGFLASH0HSIZE            ),
     .HBURSTTARGFLASH0(     TARGFLASH0HBURST           ),
     .HPROTTARGFLASH0(      TARGFLASH0HPROT            ),
     .HMASTERTARGFLASH0(    TARGFLASH0HMASTER          ),
     .HWDATATARGFLASH0(     TARGFLASH0HWDATA           ),
     .HMASTLOCKTARGFLASH0(  TARGFLASH0HMASTLOCK        ),
     .HREADYMUXTARGFLASH0(  TARGFLASH0HREADYMUX        ),
     .HAUSERTARGFLASH0(     {TARGFLASH0HAUSER,TARGFLASH0MEMATTR,TARGFLASH0EXREQ} ),
     .HWUSERTARGFLASH0(     TARGFLASH0HWUSER           ),

     .HRDATATARGFLASH0(     TARGFLASH0HRDATA           ),
     .HREADYOUTTARGFLASH0(  TARGFLASH0HREADYOUT        ),
     .HRESPTARGFLASH0(      i_targflash0hresp          ),
     .HRUSERTARGFLASH0(     {TARGFLASH0HRUSER,TARGFLASH0EXRESP} ),

     .HSELTARGSRAM0(        TARGSRAM0HSEL             ),
     .HADDRTARGSRAM0(       TARGSRAM0HADDR            ),
     .HTRANSTARGSRAM0(      TARGSRAM0HTRANS           ),
     .HWRITETARGSRAM0(      TARGSRAM0HWRITE           ),
     .HSIZETARGSRAM0(       TARGSRAM0HSIZE            ),
     .HBURSTTARGSRAM0(      TARGSRAM0HBURST           ),
     .HPROTTARGSRAM0(       TARGSRAM0HPROT            ),
     .HMASTERTARGSRAM0(     TARGSRAM0HMASTER          ),
     .HWDATATARGSRAM0(      TARGSRAM0HWDATA           ),
     .HMASTLOCKTARGSRAM0(   TARGSRAM0HMASTLOCK        ),
     .HREADYMUXTARGSRAM0(   TARGSRAM0HREADYMUX        ),
     .HAUSERTARGSRAM0(      {TARGSRAM0HAUSER,TARGSRAM0MEMATTR,TARGSRAM0EXREQ} ),
     .HWUSERTARGSRAM0(      TARGSRAM0HWUSER           ),

     .HRDATATARGSRAM0(      TARGSRAM0HRDATA           ),
     .HREADYOUTTARGSRAM0(   TARGSRAM0HREADYOUT        ),
     .HRESPTARGSRAM0(       i_targsram0hresp          ),
     .HRUSERTARGSRAM0(      {TARGSRAM0HRUSER,TARGSRAM0EXRESP} ),

     .HSELTARGSRAM1(        TARGSRAM1HSEL             ),
     .HADDRTARGSRAM1(       TARGSRAM1HADDR            ),
     .HTRANSTARGSRAM1(      TARGSRAM1HTRANS           ),
     .HWRITETARGSRAM1(      TARGSRAM1HWRITE           ),
     .HSIZETARGSRAM1(       TARGSRAM1HSIZE            ),
     .HBURSTTARGSRAM1(      TARGSRAM1HBURST           ),
     .HPROTTARGSRAM1(       TARGSRAM1HPROT            ),
     .HMASTERTARGSRAM1(     TARGSRAM1HMASTER          ),
     .HWDATATARGSRAM1(      TARGSRAM1HWDATA           ),
     .HMASTLOCKTARGSRAM1(   TARGSRAM1HMASTLOCK        ),
     .HREADYMUXTARGSRAM1(   TARGSRAM1HREADYMUX        ),
     .HAUSERTARGSRAM1(      {TARGSRAM1HAUSER,TARGSRAM1MEMATTR,TARGSRAM1EXREQ} ),
     .HWUSERTARGSRAM1(      TARGSRAM1HWUSER           ),

     .HRDATATARGSRAM1(      TARGSRAM1HRDATA           ),
     .HREADYOUTTARGSRAM1(   TARGSRAM1HREADYOUT        ),
     .HRESPTARGSRAM1(       i_targsram1hresp          ),
     .HRUSERTARGSRAM1(      {TARGSRAM1HRUSER,TARGSRAM1EXRESP} ),

     .HSELTARGSRAM2(        TARGSRAM2HSEL             ),
     .HADDRTARGSRAM2(       TARGSRAM2HADDR            ),
     .HTRANSTARGSRAM2(      TARGSRAM2HTRANS           ),
     .HWRITETARGSRAM2(      TARGSRAM2HWRITE           ),
     .HSIZETARGSRAM2(       TARGSRAM2HSIZE            ),
     .HBURSTTARGSRAM2(      TARGSRAM2HBURST           ),
     .HPROTTARGSRAM2(       TARGSRAM2HPROT            ),
     .HMASTERTARGSRAM2(     TARGSRAM2HMASTER          ),
     .HWDATATARGSRAM2(      TARGSRAM2HWDATA           ),
     .HMASTLOCKTARGSRAM2(   TARGSRAM2HMASTLOCK        ),
     .HREADYMUXTARGSRAM2(   TARGSRAM2HREADYMUX        ),
     .HAUSERTARGSRAM2(      {TARGSRAM2HAUSER,TARGSRAM2MEMATTR,TARGSRAM2EXREQ} ),
     .HWUSERTARGSRAM2(      TARGSRAM2HWUSER           ),

     .HRDATATARGSRAM2(      TARGSRAM2HRDATA           ),
     .HREADYOUTTARGSRAM2(   TARGSRAM2HREADYOUT        ),
     .HRESPTARGSRAM2(       i_targsram2hresp          ),
     .HRUSERTARGSRAM2(      {TARGSRAM2HRUSER,TARGSRAM2EXRESP} ),

     .HSELTARGSRAM3(        TARGSRAM3HSEL             ),
     .HADDRTARGSRAM3(       TARGSRAM3HADDR            ),
     .HTRANSTARGSRAM3(      TARGSRAM3HTRANS           ),
     .HWRITETARGSRAM3(      TARGSRAM3HWRITE           ),
     .HSIZETARGSRAM3(       TARGSRAM3HSIZE            ),
     .HBURSTTARGSRAM3(      TARGSRAM3HBURST           ),
     .HPROTTARGSRAM3(       TARGSRAM3HPROT            ),
     .HMASTERTARGSRAM3(     TARGSRAM3HMASTER          ),
     .HWDATATARGSRAM3(      TARGSRAM3HWDATA           ),
     .HMASTLOCKTARGSRAM3(   TARGSRAM3HMASTLOCK        ),
     .HREADYMUXTARGSRAM3(   TARGSRAM3HREADYMUX        ),
     .HAUSERTARGSRAM3(      {TARGSRAM3HAUSER,TARGSRAM3MEMATTR,TARGSRAM3EXREQ} ),
     .HWUSERTARGSRAM3(      TARGSRAM3HWUSER           ),

     .HRDATATARGSRAM3(      TARGSRAM3HRDATA           ),
     .HREADYOUTTARGSRAM3(   TARGSRAM3HREADYOUT        ),
     .HRESPTARGSRAM3(       i_targsram3hresp          ),
     .HRUSERTARGSRAM3(      {TARGSRAM3HRUSER,TARGSRAM3EXRESP} ),

     .HSELTARGAPB0(         targapb0hsel             ),
     .HADDRTARGAPB0(        targapb0haddr            ),
     .HTRANSTARGAPB0(       targapb0htrans           ),
     .HWRITETARGAPB0(       targapb0hwrite           ),
     .HSIZETARGAPB0(        targapb0hsize            ),
     .HBURSTTARGAPB0(         ),
     .HPROTTARGAPB0(        targapb0hprot            ),
     .HMASTERTARGAPB0(        ),
     .HWDATATARGAPB0(       targapb0hwdata           ),
     .HMASTLOCKTARGAPB0(      ),
     .HREADYMUXTARGAPB0(    targapb0hreadymux        ),
     .HAUSERTARGAPB0(         ),
     .HWUSERTARGAPB0(         ),

     .HRDATATARGAPB0(       targapb0hrdata           ),
     .HREADYOUTTARGAPB0(    targapb0hreadyout        ),
     .HRESPTARGAPB0(        i_targapb0hresp          ),
     .HRUSERTARGAPB0(       4'b0000                  ), 

     .HSELTARGEXP0(         TARGEXP0HSEL             ),
     .HADDRTARGEXP0(        TARGEXP0HADDR            ),
     .HTRANSTARGEXP0(       TARGEXP0HTRANS           ),
     .HWRITETARGEXP0(       TARGEXP0HWRITE           ),
     .HSIZETARGEXP0(        TARGEXP0HSIZE            ),
     .HBURSTTARGEXP0(       TARGEXP0HBURST           ),
     .HPROTTARGEXP0(        TARGEXP0HPROT            ),
     .HMASTERTARGEXP0(      TARGEXP0HMASTER          ),
     .HWDATATARGEXP0(       TARGEXP0HWDATA           ),
     .HMASTLOCKTARGEXP0(    TARGEXP0HMASTLOCK        ),
     .HREADYMUXTARGEXP0(    TARGEXP0HREADYMUX        ),
     .HAUSERTARGEXP0(       {TARGEXP0HAUSER,TARGEXP0MEMATTR,TARGEXP0EXREQ} ),
     .HWUSERTARGEXP0(       TARGEXP0HWUSER           ),

     .HRDATATARGEXP0(       TARGEXP0HRDATA           ),
     .HREADYOUTTARGEXP0(    TARGEXP0HREADYOUT        ),
     .HRESPTARGEXP0(        i_targexp0hresp          ),
     .HRUSERTARGEXP0(       {TARGEXP0HRUSER,TARGEXP0EXRESP} ),

     .HSELTARGEXP1(         TARGEXP1HSEL             ),
     .HADDRTARGEXP1(        TARGEXP1HADDR            ),
     .HTRANSTARGEXP1(       TARGEXP1HTRANS           ),
     .HWRITETARGEXP1(       TARGEXP1HWRITE           ),
     .HSIZETARGEXP1(        TARGEXP1HSIZE            ),
     .HBURSTTARGEXP1(       TARGEXP1HBURST           ),
     .HPROTTARGEXP1(        TARGEXP1HPROT            ),
     .HMASTERTARGEXP1(      TARGEXP1HMASTER          ),
     .HWDATATARGEXP1(       TARGEXP1HWDATA           ),
     .HMASTLOCKTARGEXP1(    TARGEXP1HMASTLOCK        ),
     .HREADYMUXTARGEXP1(    TARGEXP1HREADYMUX        ),
     .HAUSERTARGEXP1(       {TARGEXP1HAUSER,TARGEXP1MEMATTR,TARGEXP1EXREQ} ),
     .HWUSERTARGEXP1(       TARGEXP1HWUSER           ),

     .HRDATATARGEXP1(       TARGEXP1HRDATA           ),
     .HREADYOUTTARGEXP1(    TARGEXP1HREADYOUT        ),
     .HRESPTARGEXP1(        i_targexp1hresp          ),
     .HRUSERTARGEXP1(       {TARGEXP1HRUSER,TARGEXP1EXRESP} ),

     .SCANENABLE(           SCANENABLE               ),   
     .SCANINHCLK(           SCANINHCLK               ),   

     .SCANOUTHCLK(          SCANOUTHCLK              )    

     );

  sse710_integration_example_f0_ahb_to_apb #(16,1,1)
  u_sse710_integration_example_f0_ahb_to_apb (
     .HCLK(       AHB2APBHCLK       ),
     .HRESETn(    MTXHRESETn        ),
     .PCLKEN(     1'b1              ),

     .HSEL(       targapb0hsel      ),
     .HADDR(      targapb0haddr[15:0]),
     .HTRANS(     targapb0htrans    ),
     .HSIZE(      targapb0hsize     ),
     .HPROT(      targapb0hprot     ),
     .HWRITE(     targapb0hwrite    ),
     .HREADY(     targapb0hreadymux ),
     .HWDATA(     targapb0hwdata    ),

     .HREADYOUT(  targapb0hreadyout ),
     .HRDATA(     targapb0hrdata    ),
     .HRESP(      targapb0hresp     ),

     .PADDR(      ahb2apb_paddr     ),
     .PENABLE(    ahb2apb_penable   ),
     .PWRITE(     ahb2apb_pwrite    ),
     .PSTRB(      ahb2apb_pstrb     ),
     .PPROT(      ahb2apb_pprot     ),
     .PWDATA(     ahb2apb_pwdata    ),
     .PSEL(       ahb2apb_psel      ),

     .APBACTIVE(  APBQACTIVE        ),

     .PRDATA(     ahb2apb_prdata    ),
     .PREADY(     ahb2apb_pready    ),
     .PSLVERR(    ahb2apb_pslverr   )
  );

  sse710_integration_example_f0_apb_slave_mux #(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)
  u_sse710_integration_example_f0_apb_slave_mux (
     .DECODE4BIT( ahb2apb_paddr[15:12] ),
     .PSEL(       ahb2apb_psel         ),

     .PSEL0(      APBTARGEXP0PSEL      ),
     .PREADY0(    APBTARGEXP0PREADY    ),
     .PRDATA0(    APBTARGEXP0PRDATA    ),
     .PSLVERR0(   APBTARGEXP0PSLVERR   ),

     .PSEL1(      APBTARGEXP1PSEL      ),
     .PREADY1(    APBTARGEXP1PREADY    ),
     .PRDATA1(    APBTARGEXP1PRDATA    ),
     .PSLVERR1(   APBTARGEXP1PSLVERR   ),

     .PSEL2(      APBTARGEXP2PSEL      ),
     .PREADY2(    APBTARGEXP2PREADY    ),
     .PRDATA2(    APBTARGEXP2PRDATA    ),
     .PSLVERR2(   APBTARGEXP2PSLVERR   ),

     .PSEL3(      APBTARGEXP3PSEL      ),
     .PREADY3(    APBTARGEXP3PREADY    ),
     .PRDATA3(    APBTARGEXP3PRDATA    ),
     .PSLVERR3(   APBTARGEXP3PSLVERR   ),

     .PSEL4(      APBTARGEXP4PSEL      ),
     .PREADY4(    APBTARGEXP4PREADY    ),
     .PRDATA4(    APBTARGEXP4PRDATA    ),
     .PSLVERR4(   APBTARGEXP4PSLVERR   ),

     .PSEL5(      APBTARGEXP5PSEL      ),
     .PREADY5(    APBTARGEXP5PREADY    ),
     .PRDATA5(    APBTARGEXP5PRDATA    ),
     .PSLVERR5(   APBTARGEXP5PSLVERR   ),

     .PSEL6(      APBTARGEXP6PSEL      ),
     .PREADY6(    APBTARGEXP6PREADY    ),
     .PRDATA6(    APBTARGEXP6PRDATA    ),
     .PSLVERR6(   APBTARGEXP6PSLVERR   ),

     .PSEL7(      APBTARGEXP7PSEL      ),
     .PREADY7(    APBTARGEXP7PREADY    ),
     .PRDATA7(    APBTARGEXP7PRDATA    ),
     .PSLVERR7(   APBTARGEXP7PSLVERR   ),

     .PSEL8(      APBTARGEXP8PSEL      ),
     .PREADY8(    APBTARGEXP8PREADY    ),
     .PRDATA8(    APBTARGEXP8PRDATA    ),
     .PSLVERR8(   APBTARGEXP8PSLVERR   ),

     .PSEL9(      APBTARGEXP9PSEL      ),
     .PREADY9(    APBTARGEXP9PREADY    ),
     .PRDATA9(    APBTARGEXP9PRDATA    ),
     .PSLVERR9(   APBTARGEXP9PSLVERR   ),

     .PSEL10(     APBTARGEXP10PSEL      ),
     .PREADY10(   APBTARGEXP10PREADY    ),
     .PRDATA10(   APBTARGEXP10PRDATA    ),
     .PSLVERR10(  APBTARGEXP10PSLVERR   ),

     .PSEL11(     APBTARGEXP11PSEL      ),
     .PREADY11(   APBTARGEXP11PREADY    ),
     .PRDATA11(   APBTARGEXP11PRDATA    ),
     .PSLVERR11(  APBTARGEXP11PSLVERR   ),

     .PSEL12(     APBTARGEXP12PSEL      ),
     .PREADY12(   APBTARGEXP12PREADY    ),
     .PRDATA12(   APBTARGEXP12PRDATA    ),
     .PSLVERR12(  APBTARGEXP12PSLVERR   ),

     .PSEL13(     APBTARGEXP13PSEL      ),
     .PREADY13(   APBTARGEXP13PREADY    ),
     .PRDATA13(   APBTARGEXP13PRDATA    ),
     .PSLVERR13(  APBTARGEXP13PSLVERR   ),

     .PSEL14(     APBTARGEXP14PSEL      ),
     .PREADY14(   APBTARGEXP14PREADY    ),
     .PRDATA14(   APBTARGEXP14PRDATA    ),
     .PSLVERR14(  APBTARGEXP14PSLVERR   ),

     .PSEL15(     APBTARGEXP15PSEL      ),
     .PREADY15(   APBTARGEXP15PREADY    ),
     .PRDATA15(   APBTARGEXP15PRDATA    ),
     .PSLVERR15(  APBTARGEXP15PSLVERR   ),

     .PREADY(     ahb2apb_pready        ),
     .PRDATA(     ahb2apb_prdata        ),
     .PSLVERR(    ahb2apb_pslverr       )
  );

endmodule
