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


module sse710_integration_example_f0_peripheral (

  input  wire          TIMER0PCLK,      
  input  wire          TIMER0PCLKG,     
  input  wire          TIMER0PRESETn,   

  input  wire          TIMER0PSEL,      
  input  wire [11:2]   TIMER0PADDR,     
  input  wire          TIMER0PENABLE,   
  input  wire          TIMER0PWRITE,    
  input  wire [31:0]   TIMER0PWDATA,    
  input  wire [2:0]    TIMER0PPROT,     
  input  wire [3:0]    TIMER0PSTRB,     

  output wire [31:0]   TIMER0PRDATA,    
  output wire          TIMER0PREADY,    
  output wire          TIMER0PSLVERR,   

  input  wire          TIMER0EXTIN,     
  input  wire          TIMER0PRIVMODEN, 
  output wire          TIMER0TIMERINT,  

  input  wire          TIMER1PCLK,      
  input  wire          TIMER1PCLKG,     
  input  wire          TIMER1PRESETn,   

  input  wire          TIMER1PSEL,      
  input  wire [11:2]   TIMER1PADDR,     
  input  wire          TIMER1PENABLE,   
  input  wire          TIMER1PWRITE,    
  input  wire [31:0]   TIMER1PWDATA,    
  input  wire [2:0]    TIMER1PPROT,     
  input  wire [3:0]    TIMER1PSTRB,     

  output wire [31:0]   TIMER1PRDATA,    
  output wire          TIMER1PREADY,    
  output wire          TIMER1PSLVERR,   

  input  wire          TIMER1EXTIN,     
  input  wire          TIMER1PRIVMODEN, 
  output wire          TIMER1TIMERINT); 

  
  wire [3:0]  timer_0_eco;
  wire [3:0]  timer_1_eco;
  
  
  sse710_integration_example_f0_timer u_sse710_integration_example_f0_timer0(
    .PCLK       (TIMER0PCLK),
    .PCLKG      (TIMER0PCLKG),
    .PRESETn    (TIMER0PRESETn),

    .PSEL       (TIMER0PSEL),
    .PADDR      (TIMER0PADDR),
    .PENABLE    (TIMER0PENABLE),
    .PWRITE     (TIMER0PWRITE),
    .PWDATA     (TIMER0PWDATA),
    .PPROT      (TIMER0PPROT),
    .PSTRB      (TIMER0PSTRB),

    .ECOREVNUM  (timer_0_eco),

    .PRDATA     (TIMER0PRDATA),
    .PREADY     (TIMER0PREADY),
    .PSLVERR    (TIMER0PSLVERR),
    .EXTIN      (TIMER0EXTIN),
    .PRIVMODEN  (TIMER0PRIVMODEN),
    .TIMERINT   (TIMER0TIMERINT)
  );

  sse710_integration_example_f0_timer u_sse710_integration_example_f0_timer1(
    .PCLK       (TIMER1PCLK),
    .PCLKG      (TIMER1PCLKG),
    .PRESETn    (TIMER1PRESETn),

    .PSEL       (TIMER1PSEL),
    .PADDR      (TIMER1PADDR),
    .PENABLE    (TIMER1PENABLE),
    .PWRITE     (TIMER1PWRITE),
    .PWDATA     (TIMER1PWDATA),
    .PPROT      (TIMER1PPROT),
    .PSTRB      (TIMER1PSTRB),

    .ECOREVNUM  (timer_1_eco),

    .PRDATA     (TIMER1PRDATA),
    .PREADY     (TIMER1PREADY),
    .PSLVERR    (TIMER1PSLVERR),

    .EXTIN      (TIMER1EXTIN),
    .PRIVMODEN  (TIMER1PRIVMODEN),
    .TIMERINT   (TIMER1TIMERINT)
  );

  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_arm_element_ecorevnum_0 (
    .ecorevnum (timer_0_eco)
  ); 

  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_arm_element_ecorevnum_1 (
    .ecorevnum (timer_1_eco)
  );  
  
  
endmodule
