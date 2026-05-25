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


module e_clk_f1_top_clustop (
    input   wire                        CLUSTOP_RESETN,    


    input   wire                        REFCLK,    
    input   wire                        SYSPLL,    
    input   wire                        CPUPLL,    

    output  wire                        HOSTCPUCLK,   

    input   wire  [4:0]                 HOSTCPUCLK_ON_CPUPLL_DIVRATIO,
    output  wire  [4:0]                 HOSTCPUCLK_ON_CPUPLL_DIVRATIO_CUR,
    input   wire  [4:0]                 HOSTCPUCLK_ON_SYSPLL_DIVRATIO,
    output  wire  [4:0]                 HOSTCPUCLK_ON_SYSPLL_DIVRATIO_CUR,

    input   wire  [2:0]                 HOSTCPUCLK_CLKSEL,
    output  wire  [2:0]                 HOSTCPUCLK_CLKSEL_CUR,

    input   wire  [2:0]                 DFTHOSTCPUCLKSEL,
    input   wire                        DFTHOSTCPUCLKSELEN,
    input   wire                        DFTHOSTCPUCLKDIVBYPASS_ON_CPUPLL,
    input   wire                        DFTHOSTCPUCLKDIVBYPASS_ON_SYSPLL,
    output  wire                        GICCLK,   

    input   wire  [4:0]                 GICCLK_ON_SYSPLL_DIVRATIO,
    output  wire  [4:0]                 GICCLK_ON_SYSPLL_DIVRATIO_CUR,

    input   wire  [1:0]                 GICCLK_CLKSEL,
    output  wire  [1:0]                 GICCLK_CLKSEL_CUR,

    input   wire  [1:0]                 DFTGICCLKSEL,
    input   wire                        DFTGICCLKSELEN,
    input   wire                        DFTGICCLKDIVBYPASS_ON_SYSPLL,

    input   wire                        DFTCGEN,
    input   wire                        DFTRSTDISABLE
    
);


        
 
     
e_clk_f1_unit_hostcpuclk_clustop u_e_clk_f1_unit_hostcpuclk_clustop(
    .CLUSTOP_RESETN                          (CLUSTOP_RESETN),
    
    .REFCLK                                  (REFCLK),
    .SYSPLL                                  (SYSPLL),
    .CPUPLL                                  (CPUPLL),
 
    
    .HOSTCPUCLK                              (HOSTCPUCLK),

    .HOSTCPUCLK_ON_CPUPLL_DIVRATIO           (HOSTCPUCLK_ON_CPUPLL_DIVRATIO),
    .HOSTCPUCLK_ON_CPUPLL_DIVRATIO_CUR       (HOSTCPUCLK_ON_CPUPLL_DIVRATIO_CUR),
    .HOSTCPUCLK_ON_SYSPLL_DIVRATIO           (HOSTCPUCLK_ON_SYSPLL_DIVRATIO),
    .HOSTCPUCLK_ON_SYSPLL_DIVRATIO_CUR       (HOSTCPUCLK_ON_SYSPLL_DIVRATIO_CUR),

    .HOSTCPUCLK_CLKSEL                       (HOSTCPUCLK_CLKSEL),
    .HOSTCPUCLK_CLKSEL_CUR                   (HOSTCPUCLK_CLKSEL_CUR),

    .DFTHOSTCPUCLKSEL                        (DFTHOSTCPUCLKSEL),
    .DFTHOSTCPUCLKSELEN                      (DFTHOSTCPUCLKSELEN),
    .DFTHOSTCPUCLKDIVBYPASS_ON_CPUPLL        (DFTHOSTCPUCLKDIVBYPASS_ON_CPUPLL),
    .DFTHOSTCPUCLKDIVBYPASS_ON_SYSPLL        (DFTHOSTCPUCLKDIVBYPASS_ON_SYSPLL),
    .DFTCGEN                                 (DFTCGEN),
    .DFTRSTDISABLE                           (DFTRSTDISABLE)
);


        
 
     
e_clk_f1_unit_gicclk_clustop u_e_clk_f1_unit_gicclk_clustop(
    .CLUSTOP_RESETN                          (CLUSTOP_RESETN),
    
    .REFCLK                                  (REFCLK),
    .SYSPLL                                  (SYSPLL),
 
    
    .GICCLK                                  (GICCLK),

    .GICCLK_ON_SYSPLL_DIVRATIO               (GICCLK_ON_SYSPLL_DIVRATIO),
    .GICCLK_ON_SYSPLL_DIVRATIO_CUR           (GICCLK_ON_SYSPLL_DIVRATIO_CUR),

    .GICCLK_CLKSEL                           (GICCLK_CLKSEL),
    .GICCLK_CLKSEL_CUR                       (GICCLK_CLKSEL_CUR),

    .DFTGICCLKSEL                            (DFTGICCLKSEL),
    .DFTGICCLKSELEN                          (DFTGICCLKSELEN),
    .DFTGICCLKDIVBYPASS_ON_SYSPLL            (DFTGICCLKDIVBYPASS_ON_SYSPLL),
    .DFTCGEN                                 (DFTCGEN),
    .DFTRSTDISABLE                           (DFTRSTDISABLE)
);


      

endmodule
