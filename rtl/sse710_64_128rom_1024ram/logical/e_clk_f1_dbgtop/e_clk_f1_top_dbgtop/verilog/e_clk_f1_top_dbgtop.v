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


module e_clk_f1_top_dbgtop (
    input   wire                        RESETN,    


    input   wire                        REFCLK,    
    input   wire                        SYSPLL,    

    output  wire                        DBGCLK,   

    input   wire  [4:0]                 DBGCLK_ON_SYSPLL_DIVRATIO,
    output  wire  [4:0]                 DBGCLK_ON_SYSPLL_DIVRATIO_CUR,

    input   wire  [1:0]                 DBGCLK_CLKSEL,
    output  wire  [1:0]                 DBGCLK_CLKSEL_CUR,

    input   wire  [1:0]                 DFTDBGCLKSEL,
    input   wire                        DFTDBGCLKSELEN,
    input   wire                        DFTDBGCLKDIVBYPASS_ON_SYSPLL,

    input   wire                        DFTCGEN,
    input   wire                        DFTRSTDISABLE
    
);


        
 
     
e_clk_f1_unit_dbgclk_dbgtop u_e_clk_f1_unit_dbgclk_dbgtop(
    .RESETN                                  (RESETN),
    
    .REFCLK                                  (REFCLK),
    .SYSPLL                                  (SYSPLL),
 
    
    .DBGCLK                                  (DBGCLK),

    .DBGCLK_ON_SYSPLL_DIVRATIO               (DBGCLK_ON_SYSPLL_DIVRATIO),
    .DBGCLK_ON_SYSPLL_DIVRATIO_CUR           (DBGCLK_ON_SYSPLL_DIVRATIO_CUR),

    .DBGCLK_CLKSEL                           (DBGCLK_CLKSEL),
    .DBGCLK_CLKSEL_CUR                       (DBGCLK_CLKSEL_CUR),

    .DFTDBGCLKSEL                            (DFTDBGCLKSEL),
    .DFTDBGCLKSELEN                          (DFTDBGCLKSELEN),
    .DFTDBGCLKDIVBYPASS_ON_SYSPLL            (DFTDBGCLKDIVBYPASS_ON_SYSPLL),
    .DFTCGEN                                 (DFTCGEN),
    .DFTRSTDISABLE                           (DFTRSTDISABLE)
);


      

endmodule
