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


module sec_clk_ctrl (
  input  wire       secenc_refclk,
  input  wire       sys_pll,
  input  wire       rst_n,
  input  wire       s32k_clk,

  output wire       hintclken_clk,
  output wire       secenc_divclkaon,
  output wire       secenc_divclk,
  output wire       secenc_clkaon,
  output wire       secenc_clk,

  output wire       s32k_clk_secenc,
  output wire       s32k_clk_aon,

  input  wire [1:0] clkselect,      
  output wire [1:0] clkselect_cur,  
  input  wire [4:0] pll_clkdiv,     
  output wire [4:0] pll_clkdiv_cur, 
  input  wire [4:0] cm0_clkdiv,     
  output wire [4:0] cm0_clkdiv_cur, 
  input  wire       ppu_clken,      

  input  wire       dftdivsel,
  input  wire       dftclkselen,
  input  wire [1:0] dftclksel,
  input  wire       dftdivbypass,
  input  wire       dftcgen,
  input  wire       dftrstdisable,
  input  wire       nmbistreset,
  input  wire       mbistreq
);

  wire dftcgen_or_mbistreq;
  wire resetn_secencclk_gen;
  wire resetn_secenc32kclk_gen;
  
  sec_or_tree #(
    .NUM_OR_TREE_INPUTS (2)
  ) u_sec_or_tree (
    .or_tree_i  ({dftcgen, mbistreq}),
    .or_tree_o  (dftcgen_or_mbistreq)
  );  

  arm_element_cdc_comb_mux2 u_clkgen_reset_nmbistreset_mux (
   .din1_async(rst_n),
   .din2_async(nmbistreset),
   .sel       (dftdivsel),
   .dout_async(resetn_secencclk_gen)
  );

  e_clk_f1_top_secenc_clk u_e_clk_f1_top_secenc_clk (
    .SYSTOP_RESETn                        (resetn_secencclk_gen),
    .SECENCREFCLK                         (secenc_refclk),
    .SYSPLL                               (sys_pll),
    .SECENCDIVCLK                         (secenc_divclk),
    .SECENCDIVCLK_DCT_CG                  (ppu_clken),
    .SECENCCLK_AON_ON_SYSPLL_DIVRATIO     (pll_clkdiv),
    .SECENCCLK_AON_ON_SYSPLL_DIVRATIO_CUR (pll_clkdiv_cur),
    .SECENCCLK_AON_CLKSEL                 (clkselect),
    .SECENCCLK_AON_CLKSEL_CUR             (clkselect_cur),
    .DFTSECENCCLK_AONSEL                  (dftclksel),
    .DFTSECENCCLK_AONSELEN                (dftclkselen),
    .DFTSECENCCLK_AONDIVBYPASS_ON_SYSPLL  (dftdivbypass),
    .SECENCCLK_AON                        (secenc_clkaon),
    .SECENCDIVCLK_AON                     (secenc_divclkaon),
    .HINTCLKEN_CLK                        (hintclken_clk),
    .HINTCLKEN_CLK_DCT_CG                 (ppu_clken),
    .SECENCDIVCLK_I_DIVRATIO              (cm0_clkdiv),
    .SECENCDIVCLK_I_DIVRATIO_CUR          (cm0_clkdiv_cur),
    .DFTSECENCDIVCLK_IDIVBYPASS           (dftdivbypass),
    .SECENCCLK                            (secenc_clk),
    .SECENCCLK_DCT_CG                     (ppu_clken),
    .DFTCGEN                              (dftcgen_or_mbistreq),
    .DFTRSTDISABLE                        (dftrstdisable)
  );

  arm_element_cdc_comb_mux2 u_clkgen32k_reset_nmbistreset_mux (
   .din1_async(rst_n),
   .din2_async(nmbistreset),
   .sel       (dftdivsel),
   .dout_async(resetn_secenc32kclk_gen)
  );
 
  e_clk_f1_top_secenc_32k u_e_clk_f1_top_secenc_32k (
    .RESETn                 (resetn_secenc32kclk_gen),
    .S32KCLK                (s32k_clk),
    .S32KCLK_SECENC         (s32k_clk_secenc),
    .S32KCLK_SECENC_DCT_CG  (ppu_clken),
    .S32KCLK_AON            (s32k_clk_aon),
    .DFTCGEN                (dftcgen),
    .DFTRSTDISABLE          (dftrstdisable)
  );

endmodule
