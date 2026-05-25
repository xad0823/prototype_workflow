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

module sse710_integration_example_f0_external_system_peripherals (
    
    input  wire           extsys_clk,
    input  wire           extsys_hclk,
    input  wire           wdog_clken,
                          
    input  wire           extsys_mtx_resetn,
                          
    input  wire           apbtargexp8_psel,   
    input  wire           apbtargexp8_penable,
    input  wire [11:0]    apbtargexp8_paddr,  
    input  wire           apbtargexp8_pwrite, 
    input  wire [31:0]    apbtargexp8_pwdata, 
    output wire [31:0]    apbtargexp8_prdata, 
    output wire           apbtargexp8_pready, 
    output wire           apbtargexp8_pslverr,
    input  wire [3:0]     apbtargexp8_pstrb,  
    input  wire [2:0]     apbtargexp8_pprot,  
                          
    input  wire           targexp0hsel,       
    input  wire [31:0]    targexp0haddr,      
    input  wire  [1:0]    targexp0htrans,     
    input  wire           targexp0hwrite,     
    input  wire  [2:0]    targexp0hsize,      
    input  wire  [2:0]    targexp0hburst,     
    input  wire  [3:0]    targexp0hprot,      
    input  wire  [1:0]    targexp0memattr,
    input  wire           targexp0exreq,
    input  wire  [3:0]    targexp0hmaster,
    input  wire [31:0]    targexp0hwdata,     
    input  wire           targexp0hmastlock,  
    input  wire           targexp0hreadymux,  
    input  wire           targexp0hauser,     
    input  wire  [3:0]    targexp0hwuser,     
    output wire [31:0]    targexp0hrdata,     
    output wire           targexp0hreadyout,  
    output wire           targexp0hresp,      
    output wire           targexp0exresp,
    output wire  [2:0]    targexp0hruser,
                          
    output wire           wdog_int,
    output wire           wdog_res 
                          
  );

  
  wire [3:0]   wdog_eco;
  
  wire         unused;


 cmsdk_apb_watchdog u_apb_watchdog (
    .PCLK              (extsys_hclk),
    .PRESETn           (extsys_mtx_resetn),
    .PENABLE           (apbtargexp8_penable),
    .PSEL              (apbtargexp8_psel),
    .PADDR             (apbtargexp8_paddr[11:2]),
    .PWRITE            (apbtargexp8_pwrite),
    .PWDATA            (apbtargexp8_pwdata),

    .WDOGCLK           (extsys_clk),
    .WDOGCLKEN         (wdog_clken),
    .WDOGRESn          (extsys_mtx_resetn),

    .ECOREVNUM         (wdog_eco),

    .PRDATA            (apbtargexp8_prdata),

    .WDOGINT           (wdog_int),  
    .WDOGRES           (wdog_res)   
  );
  
  assign apbtargexp8_pready     = 1'b1;
  assign apbtargexp8_pslverr    = 1'b0;

  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_arm_element_ecorevnum (
    .ecorevnum (wdog_eco)
  );    
  

  cmsdk_ahb_default_slave u_cmsdk_ahb_default_slave (
   .HCLK        (extsys_hclk),      
   .HRESETn     (extsys_mtx_resetn),   
   .HSEL        (targexp0hsel),      
   .HTRANS      (targexp0htrans),    
   .HREADY      (targexp0hreadymux),    

   .HREADYOUT   (targexp0hreadyout),
  . HRESP       (targexp0hresp)
 );    

  assign targexp0hrdata = 32'h0000_0000;
  assign targexp0exresp = 1'b0;
  assign targexp0hruser = 3'b0;

  assign unused = (|apbtargexp8_pstrb)      |
                  (|apbtargexp8_pprot)      |
                  (|apbtargexp8_paddr[1:0]) |
                  (|targexp0haddr)          |
                  (|targexp0hwrite)         |
                  (|targexp0hsize)          |
                  (|targexp0hburst)         |
                  (|targexp0hprot)          |
                  (|targexp0memattr)        |
                  (|targexp0exreq)          |
                  (|targexp0hmaster)        |
                  (|targexp0hwdata)         |
                  (|targexp0hmastlock)      |
                  (|targexp0hauser)         |
                  (|targexp0hwuser);  
  
endmodule
