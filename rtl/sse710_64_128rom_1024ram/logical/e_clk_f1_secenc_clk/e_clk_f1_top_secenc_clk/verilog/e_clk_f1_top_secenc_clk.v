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


module e_clk_f1_top_secenc_clk (
    input   wire                        SYSTOP_RESETn,    


    input   wire                        SECENCREFCLK,    
    input   wire                        SYSPLL,    


    input   wire  [4:0]                 SECENCDIVCLK_I_DIVRATIO,
    output  wire  [4:0]                 SECENCDIVCLK_I_DIVRATIO_CUR,

    input   wire                        DFTSECENCDIVCLK_IDIVBYPASS,
    output  wire                        SECENCCLK,   

    input   wire                        SECENCCLK_DCT_CG,

    output  wire                        HINTCLKEN_CLK,   

    input   wire                        HINTCLKEN_CLK_DCT_CG,

    output  wire                        SECENCDIVCLK,   

    input   wire                        SECENCDIVCLK_DCT_CG,

    output  wire                        SECENCCLK_AON,   

    input   wire  [4:0]                 SECENCCLK_AON_ON_SYSPLL_DIVRATIO,
    output  wire  [4:0]                 SECENCCLK_AON_ON_SYSPLL_DIVRATIO_CUR,

    input   wire  [1:0]                 SECENCCLK_AON_CLKSEL,
    output  wire  [1:0]                 SECENCCLK_AON_CLKSEL_CUR,

    input   wire  [1:0]                 DFTSECENCCLK_AONSEL,
    input   wire                        DFTSECENCCLK_AONSELEN,
    input   wire                        DFTSECENCCLK_AONDIVBYPASS_ON_SYSPLL,
    output  wire                        SECENCDIVCLK_AON,   


    input   wire                        DFTCGEN,
    input   wire                        DFTRSTDISABLE
    
);

wire                secencdivclk_i;
wire                secencdivclk_i_prediv;
wire                secencdivclk_i_hintclken_clk;

        
 
     
e_clk_f1_unit_secencdivclk_i_secenc_clk u_e_clk_f1_unit_secencdivclk_i_secenc_clk(
    .SYSTOP_RESETn                           (SYSTOP_RESETn),
    
    .SECENCCLK_AON                           (SECENCCLK_AON),
 
    
    .SECENCDIVCLK_I                          (secencdivclk_i),
    .SECENCDIVCLK_I_PREDIV                   (secencdivclk_i_prediv),
    .SECENCDIVCLK_I_HINTCLKEN_CLK            (secencdivclk_i_hintclken_clk),

    .SECENCDIVCLK_I_DIVRATIO                 (SECENCDIVCLK_I_DIVRATIO),
    .SECENCDIVCLK_I_DIVRATIO_CUR             (SECENCDIVCLK_I_DIVRATIO_CUR),

    .DFTSECENCDIVCLK_IDIVBYPASS              (DFTSECENCDIVCLK_IDIVBYPASS),
    .DFTCGEN                                 (DFTCGEN),
    .DFTRSTDISABLE                           (DFTRSTDISABLE)
);


        
 
     
e_clk_f1_unit_secencclk_secenc_clk u_e_clk_f1_unit_secencclk_secenc_clk(
    .SYSTOP_RESETn                           (SYSTOP_RESETn),
    
    .SECENCCLK_AON                           (SECENCCLK_AON),
 
    
    .SECENCCLK                               (SECENCCLK),

    .SECENCCLK_DCT_CG                        (SECENCCLK_DCT_CG),

    .DFTCGEN                                 (DFTCGEN),
    .DFTRSTDISABLE                           (DFTRSTDISABLE)
);


        
 
     
e_clk_f1_unit_hintclken_clk_secenc_clk u_e_clk_f1_unit_hintclken_clk_secenc_clk(
    .SYSTOP_RESETn                           (SYSTOP_RESETn),
    
    .SECENCDIVCLK_I_HINTCLKEN_CLK            (secencdivclk_i_hintclken_clk),
 
    
    .HINTCLKEN_CLK                           (HINTCLKEN_CLK),

    .HINTCLKEN_CLK_DCT_CG                    (HINTCLKEN_CLK_DCT_CG),

    .DFTCGEN                                 (DFTCGEN),
    .DFTRSTDISABLE                           (DFTRSTDISABLE)
);


        
 
     
e_clk_f1_unit_secencdivclk_secenc_clk u_e_clk_f1_unit_secencdivclk_secenc_clk(
    .SYSTOP_RESETn                           (SYSTOP_RESETn),
    
    .SECENCDIVCLK_I                          (secencdivclk_i),
 
    
    .SECENCDIVCLK                            (SECENCDIVCLK),

    .SECENCDIVCLK_DCT_CG                     (SECENCDIVCLK_DCT_CG),

    .DFTCGEN                                 (DFTCGEN),
    .DFTRSTDISABLE                           (DFTRSTDISABLE)
);


        
 
     
e_clk_f1_unit_secencclk_aon_secenc_clk u_e_clk_f1_unit_secencclk_aon_secenc_clk(
    .SYSTOP_RESETn                           (SYSTOP_RESETn),
    
    .SECENCREFCLK                            (SECENCREFCLK),
    .SYSPLL                                  (SYSPLL),
 
    
    .SECENCCLK_AON                           (SECENCCLK_AON),

    .SECENCCLK_AON_ON_SYSPLL_DIVRATIO        (SECENCCLK_AON_ON_SYSPLL_DIVRATIO),
    .SECENCCLK_AON_ON_SYSPLL_DIVRATIO_CUR    (SECENCCLK_AON_ON_SYSPLL_DIVRATIO_CUR),

    .SECENCCLK_AON_CLKSEL                    (SECENCCLK_AON_CLKSEL),
    .SECENCCLK_AON_CLKSEL_CUR                (SECENCCLK_AON_CLKSEL_CUR),

    .DFTSECENCCLK_AONSEL                     (DFTSECENCCLK_AONSEL),
    .DFTSECENCCLK_AONSELEN                   (DFTSECENCCLK_AONSELEN),
    .DFTSECENCCLK_AONDIVBYPASS_ON_SYSPLL     (DFTSECENCCLK_AONDIVBYPASS_ON_SYSPLL),
    .DFTCGEN                                 (DFTCGEN),
    .DFTRSTDISABLE                           (DFTRSTDISABLE)
);


        

e_clk_f1_unit_secencdivclk_aon_secenc_clk u_e_clk_f1_unit_secencdivclk_aon_secenc_clk(
    .SECENCDIVCLK_I                          (secencdivclk_i),
    .SECENCDIVCLK_AON                        (SECENCDIVCLK_AON)
);
  

      

endmodule
