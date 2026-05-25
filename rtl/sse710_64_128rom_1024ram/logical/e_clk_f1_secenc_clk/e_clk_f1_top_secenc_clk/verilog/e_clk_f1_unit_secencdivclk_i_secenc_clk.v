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



 

module e_clk_f1_unit_secencdivclk_i_secenc_clk (
    input   wire                        SYSTOP_RESETn,  
    
    input   wire                        SECENCCLK_AON,
 
    output  wire                        SECENCDIVCLK_I,
    output  wire                        SECENCDIVCLK_I_PREDIV,
    output  wire                        SECENCDIVCLK_I_HINTCLKEN_CLK,

    input   wire  [4:0]                 SECENCDIVCLK_I_DIVRATIO,
    output  wire  [4:0]                 SECENCDIVCLK_I_DIVRATIO_CUR,

 

    input   wire                        DFTSECENCDIVCLK_IDIVBYPASS,
    input   wire                        DFTCGEN,
    input   wire                        DFTRSTDISABLE
);


 

wire            secencdivclk_i_pre_div_clk_buf;

e_clk_f1_clock_buffer_secenc_clk 
#(
    .CLOCK_DELAY    (0)
)
u_e_clk_f1_clock_buffer_secencdivclk_i_pre_div_clk  
(
    .clk_in                 (SECENCCLK_AON), 
    .clk_out                (secencdivclk_i_pre_div_clk_buf) 
);
 
assign SECENCDIVCLK_I_PREDIV = secencdivclk_i_pre_div_clk_buf;
 

wire            clk_div; 
wire            hintclken_clk_i; 

clkrst_f1_clkdiv_modulate_top
#(
    .PIPELINE_DEPTH(0)
) 
u_clkrst_f1_clkdiv_modulate_top_secencdivclk_i(
    .clkin                  (SECENCCLK_AON), 
    .divratio               (SECENCDIVCLK_I_DIVRATIO), 
        
    .numerator              (8'h01), 
    .denominator            (8'h01), 

    .stop_divider           (1'b0), 
        
    .resetn                 (SYSTOP_RESETn), 
    
    
    .dftdivsel              (1'b0), 

    .dftdivratio            (5'b00000), 
    .dftnumerator           (8'h00), 
    .dftdenominator         (8'h00), 
            
    .dftdivbypass           (DFTSECENCDIVCLK_IDIVBYPASS), 
    .dftcgen                (DFTCGEN), 
    .dftrstdisable          (DFTRSTDISABLE), 
        
    .divratio_cur           (SECENCDIVCLK_I_DIVRATIO_CUR), 
        
    .numerator_cur          (/*unused*/), 
    .denominator_cur        (/*unused*/), 
        
    .divclk                 (clk_div), 
    .hintclken_clk          (hintclken_clk_i) 
);



wire            c_clk_buf;  

e_clk_f1_clock_buffer_secenc_clk 
#(
    .CLOCK_DELAY    (0)
)
u_e_clk_f1_clock_buffer_secencdivclk_i 
(
    .clk_in                 (clk_div), 
    .clk_out                (c_clk_buf) 
);
  
  
assign SECENCDIVCLK_I = c_clk_buf;



wire            hintclken_clk_i_buf;

e_clk_f1_clock_buffer_secenc_clk 
#(
    .CLOCK_DELAY    (0)
)
u_e_clk_f1_clock_buffer_hintclken_clk
(
    .clk_in                 (hintclken_clk_i), 
    .clk_out                (hintclken_clk_i_buf) 
);

assign SECENCDIVCLK_I_HINTCLKEN_CLK = hintclken_clk_i_buf;
 
endmodule

 

