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


module e_clk_f1_top_uartclk (
    input   wire                        RESETN,    


    input   wire                        REFCLK,    
    input   wire                        UARTCLK,    
    input   wire                        S32KCLK,    

    output  wire                        HOSTUARTCLK,   

    input   wire  [4:0]                 HOSTUARTCLK_ON_UARTCLK_DIVRATIO,
    output  wire  [4:0]                 HOSTUARTCLK_ON_UARTCLK_DIVRATIO_CUR,

    input   wire  [2:0]                 HOSTUARTCLK_CLKSEL,
    output  wire  [2:0]                 HOSTUARTCLK_CLKSEL_CUR,

    input   wire  [2:0]                 DFTHOSTUARTCLKSEL,
    input   wire                        DFTHOSTUARTCLKSELEN,
    input   wire                        DFTHOSTUARTCLKDIVBYPASS_ON_UARTCLK,

    input   wire                        DFTCGEN,
    input   wire                        DFTRSTDISABLE
    
);


        
 
     
e_clk_f1_unit_hostuartclk_uartclk u_e_clk_f1_unit_hostuartclk_uartclk(
    .RESETN                                  (RESETN),
    
    .REFCLK                                  (REFCLK),
    .UARTCLK                                 (UARTCLK),
    .S32KCLK                                 (S32KCLK),
 
    
    .HOSTUARTCLK                             (HOSTUARTCLK),

    .HOSTUARTCLK_ON_UARTCLK_DIVRATIO         (HOSTUARTCLK_ON_UARTCLK_DIVRATIO),
    .HOSTUARTCLK_ON_UARTCLK_DIVRATIO_CUR     (HOSTUARTCLK_ON_UARTCLK_DIVRATIO_CUR),

    .HOSTUARTCLK_CLKSEL                      (HOSTUARTCLK_CLKSEL),
    .HOSTUARTCLK_CLKSEL_CUR                  (HOSTUARTCLK_CLKSEL_CUR),

    .DFTHOSTUARTCLKSEL                       (DFTHOSTUARTCLKSEL),
    .DFTHOSTUARTCLKSELEN                     (DFTHOSTUARTCLKSELEN),
    .DFTHOSTUARTCLKDIVBYPASS_ON_UARTCLK      (DFTHOSTUARTCLKDIVBYPASS_ON_UARTCLK),
    .DFTCGEN                                 (DFTCGEN),
    .DFTRSTDISABLE                           (DFTRSTDISABLE)
);


      

endmodule
