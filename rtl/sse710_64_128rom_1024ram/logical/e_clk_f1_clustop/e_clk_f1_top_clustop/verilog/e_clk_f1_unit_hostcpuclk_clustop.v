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



 

module e_clk_f1_unit_hostcpuclk_clustop (
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
    input   wire                        DFTCGEN,
    input   wire                        DFTRSTDISABLE
);

wire            syspll_div; 

clkrst_f1_clkdiv_modulate_top
#(
    .PIPELINE_DEPTH(0)
) 
u_clkrst_f1_clkdiv_modulate_top_syspll(
    .clkin                  (SYSPLL), 
    .divratio               (HOSTCPUCLK_ON_SYSPLL_DIVRATIO), 
        
    .numerator              (8'h01), 
    .denominator            (8'h01), 

    .stop_divider           (1'b0), 
        
    .resetn                 (CLUSTOP_RESETN), 
    
    
    .dftdivsel              (1'b0), 

    .dftdivratio            (5'b00000), 
    .dftnumerator           (8'h00), 
    .dftdenominator         (8'h00), 
    
    .dftdivbypass           (DFTHOSTCPUCLKDIVBYPASS_ON_SYSPLL), 
    .dftcgen                (DFTCGEN), 
    .dftrstdisable          (DFTRSTDISABLE), 
        
    .divratio_cur           (HOSTCPUCLK_ON_SYSPLL_DIVRATIO_CUR), 
        
    .numerator_cur          (/*unused*/), 
    .denominator_cur        (/*unused*/), 
        
    .divclk                 (syspll_div), 
    .hintclken_clk          () 

);

wire            cpupll_div; 

clkrst_f1_clkdiv_modulate_top
#(
    .PIPELINE_DEPTH(0)
) 
u_clkrst_f1_clkdiv_modulate_top_cpupll(
    .clkin                  (CPUPLL), 
    .divratio               (HOSTCPUCLK_ON_CPUPLL_DIVRATIO), 
        
    .numerator              (8'h01), 
    .denominator            (8'h01), 

    .stop_divider           (1'b0), 
        
    .resetn                 (CLUSTOP_RESETN), 
    
    
    .dftdivsel              (1'b0), 

    .dftdivratio            (5'b00000), 
    .dftnumerator           (8'h00), 
    .dftdenominator         (8'h00), 
    
    .dftdivbypass           (DFTHOSTCPUCLKDIVBYPASS_ON_CPUPLL), 
    .dftcgen                (DFTCGEN), 
    .dftrstdisable          (DFTRSTDISABLE), 
        
    .divratio_cur           (HOSTCPUCLK_ON_CPUPLL_DIVRATIO_CUR), 
        
    .numerator_cur          (/*unused*/), 
    .denominator_cur        (/*unused*/), 
        
    .divclk                 (cpupll_div), 
    .hintclken_clk          () 

);


wire            clk_sel;

clkselNway_f0_3 u_clkselnway_f0_3(
    .clk0                   (REFCLK), 
    .clk1                   (syspll_div), 
    .clk2                   (cpupll_div), 
 

    .clksel                 (HOSTCPUCLK_CLKSEL), 
    .select_cur             (HOSTCPUCLK_CLKSEL_CUR), 
    .dftclksel              (DFTHOSTCPUCLKSEL), 
    
    .resetn                 (CLUSTOP_RESETN), 
    
    .dftclkselen            (DFTHOSTCPUCLKSELEN), 
    .dftrstdisable          (DFTRSTDISABLE), 
    
    .selected_clk           (clk_sel)
);


 

 
 



wire            c_clk_buf;  

e_clk_f1_clock_buffer_clustop 
#(
    .CLOCK_DELAY    (0)
)
u_e_clk_f1_clock_buffer_hostcpuclk 
(
    .clk_in                 (clk_sel), 
    .clk_out                (c_clk_buf) 
);
  
  
assign HOSTCPUCLK = c_clk_buf;



 
endmodule

 

