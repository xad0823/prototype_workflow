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


module e_clk_f1_top_systop (
    input   wire                        RESETN,    


    input   wire                        REFCLK,    
    input   wire                        SYSPLL,    

    output  wire                        CTRLCLK,   

    input   wire  [4:0]                 CTRLCLK_ON_SYSPLL_DIVRATIO,
    output  wire  [4:0]                 CTRLCLK_ON_SYSPLL_DIVRATIO_CUR,

    input   wire  [1:0]                 CTRLCLK_CLKSEL,
    output  wire  [1:0]                 CTRLCLK_CLKSEL_CUR,

    input   wire  [1:0]                 DFTCTRLCLKSEL,
    input   wire                        DFTCTRLCLKSELEN,
    input   wire                        DFTCTRLCLKDIVBYPASS_ON_SYSPLL,
    output  wire                        ACLK,   

    input   wire  [4:0]                 ACLK_ON_SYSPLL_DIVRATIO,
    output  wire  [4:0]                 ACLK_ON_SYSPLL_DIVRATIO_CUR,

    input   wire  [1:0]                 ACLK_CLKSEL,
    output  wire  [1:0]                 ACLK_CLKSEL_CUR,

    input   wire  [1:0]                 DFTACLKSEL,
    input   wire                        DFTACLKSELEN,
    input   wire                        DFTACLKDIVBYPASS_ON_SYSPLL,

    input   wire                        DFTCGEN,
    input   wire                        DFTRSTDISABLE
    
);


        
 
     
e_clk_f1_unit_ctrlclk_systop u_e_clk_f1_unit_ctrlclk_systop(
    .RESETN                                  (RESETN),
    
    .REFCLK                                  (REFCLK),
    .SYSPLL                                  (SYSPLL),
 
    
    .CTRLCLK                                 (CTRLCLK),

    .CTRLCLK_ON_SYSPLL_DIVRATIO              (CTRLCLK_ON_SYSPLL_DIVRATIO),
    .CTRLCLK_ON_SYSPLL_DIVRATIO_CUR          (CTRLCLK_ON_SYSPLL_DIVRATIO_CUR),

    .CTRLCLK_CLKSEL                          (CTRLCLK_CLKSEL),
    .CTRLCLK_CLKSEL_CUR                      (CTRLCLK_CLKSEL_CUR),

    .DFTCTRLCLKSEL                           (DFTCTRLCLKSEL),
    .DFTCTRLCLKSELEN                         (DFTCTRLCLKSELEN),
    .DFTCTRLCLKDIVBYPASS_ON_SYSPLL           (DFTCTRLCLKDIVBYPASS_ON_SYSPLL),
    .DFTCGEN                                 (DFTCGEN),
    .DFTRSTDISABLE                           (DFTRSTDISABLE)
);


        
 
     
e_clk_f1_unit_aclk_systop u_e_clk_f1_unit_aclk_systop(
    .RESETN                                  (RESETN),
    
    .REFCLK                                  (REFCLK),
    .SYSPLL                                  (SYSPLL),
 
    
    .ACLK                                    (ACLK),

    .ACLK_ON_SYSPLL_DIVRATIO                 (ACLK_ON_SYSPLL_DIVRATIO),
    .ACLK_ON_SYSPLL_DIVRATIO_CUR             (ACLK_ON_SYSPLL_DIVRATIO_CUR),

    .ACLK_CLKSEL                             (ACLK_CLKSEL),
    .ACLK_CLKSEL_CUR                         (ACLK_CLKSEL_CUR),

    .DFTACLKSEL                              (DFTACLKSEL),
    .DFTACLKSELEN                            (DFTACLKSELEN),
    .DFTACLKDIVBYPASS_ON_SYSPLL              (DFTACLKDIVBYPASS_ON_SYSPLL),
    .DFTCGEN                                 (DFTCGEN),
    .DFTRSTDISABLE                           (DFTRSTDISABLE)
);


      

endmodule
