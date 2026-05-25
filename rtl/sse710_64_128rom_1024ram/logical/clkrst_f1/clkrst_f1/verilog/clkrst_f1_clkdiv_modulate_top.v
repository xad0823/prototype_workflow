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

module clkrst_f1_clkdiv_modulate_top
#(
    parameter DISABLE_NEGEDGE_5050MARK = 0, 
    parameter ENABLE_DIVSEL_CDC_LOGIC  = 1, 
    parameter PIPELINE_DEPTH           = 0, 
    parameter DISABLE_COMBO_GATELOGIC  = 0, 
    parameter ASYNC_SIGNAL_SKEWDEPTH   = 4  
) 

(
  input   wire                          clkin,          
  input   wire  [4:0]                   divratio,       
  input   wire  [7:0]                   numerator,      
  input   wire  [7:0]                   denominator,    
  input   wire                          stop_divider,   

  input   wire                          resetn,         


  input   wire                          dftdivsel,      
  input   wire  [4:0]                   dftdivratio,    
  input   wire  [7:0]                   dftnumerator,   
  input   wire  [7:0]                   dftdenominator, 

  input   wire                          dftdivbypass,   
  input   wire                          dftcgen,        
  input   wire                          dftrstdisable,  

  output  wire  [4:0]                   divratio_cur,   

  output  wire  [7:0]                   numerator_cur,  
  output  wire  [7:0]                   denominator_cur,

  output  wire                          divclk,         
  output  wire                          hintclken_clk   

);


  wire                                  clkin_buf;         
  wire                                  clkin_buf_n;       
  wire                                  clkin_divctrl_buf; 

  wire                                  resetn_sync;       
  wire                                  resetn_sync_n;     
  wire  [4:0]                           divratio_stable;   
  wire  [7:0]                           numerator_stable;  
  wire  [7:0]                           denominator_stable;

  wire  [4:0]                           sel_divratio;
  wire  [7:0]                           sel_numerator;
  wire  [7:0]                           sel_denominator;


  reg  [7:0]                            isel_numerator;
  reg  [7:0]                            isel_denominator;


  clkrst_f1_clkbuf u_clkrst_f1_clkbuf_top (
    .clk_in                             (clkin),                                
    .clk_out                            (clkin_buf)
  );

  clkrst_f1_clkbuf u_clkrst_f1_clkbuf_divctrl (
    .clk_in                             (clkin),                                
    .clk_out                            (clkin_divctrl_buf)
  );

  clkrst_f1_clkinv u_clkrst_f1_clkinv_top (
    .clk_in                             (clkin_buf),                                
    .clk_out                            (clkin_buf_n)
  );


  clkrst_f1_rstsync u_clkrst_f1_rstsync_clkin_buf(
    .clk                                (clkin_divctrl_buf),
    .resetn_async                       (resetn),           
    .resetn_sync                        (resetn_sync),      
 
    .dftrstdisable                      (dftrstdisable)     
  );


  clkrst_f1_rstsync u_clkrst_f1_rstsync_clkin_buf_n(
    .clk                                (clkin_buf_n),      
    .resetn_async                       (resetn),           
    .resetn_sync                        (resetn_sync_n),    
 
    .dftrstdisable                      (dftrstdisable)     
  );




  clkrst_f1_cdc_comb_mux2 # (
    .WIDTH       (5)
  ) u_clkrst_f1_cdc_comb_mux2_divratio (
  .din1_async                     (divratio),
  .din2_async                     (dftdivratio),
  .sel                            (dftdivsel),
  .dout_async                     (sel_divratio)
);


  clkrst_f1_cdc_comb_mux2 # (
    .WIDTH       (8)
  ) u_clkrst_f1_cdc_comb_mux2_dftnumerator (
  .din1_async                     (numerator),
  .din2_async                     (dftnumerator),
  .sel                            (dftdivsel),
  .dout_async                     (sel_numerator)
);


  clkrst_f1_cdc_comb_mux2 # (
    .WIDTH       (8)
  ) u_clkrst_f1_cdc_comb_mux2_dftdenominator (
  .din1_async                     (denominator),
  .din2_async                     (dftdenominator),
  .sel                            (dftdivsel),
  .dout_async                     (sel_denominator)
);

  always @(sel_numerator)
  begin
    if (sel_numerator == 8'b00000000)
      isel_numerator = 8'b00000001;
    else
      isel_numerator = sel_numerator;
  end      

  always @(sel_denominator)
  begin
    if (sel_denominator == 8'b00000000)
      isel_denominator = 8'b00000001;
    else
      isel_denominator = sel_denominator;
  end      

generate
if (ENABLE_DIVSEL_CDC_LOGIC==1)
begin : enable_cdc_logic


  clkrst_f1_clkdiv_cdc #(
    .CLKRST_ASYNC_SIGNAL_WIDTH  (5),
    .ASYNC_SIGNAL_SKEWDEPTH     (ASYNC_SIGNAL_SKEWDEPTH),
    .RESET_VALUE                (1)
  ) u_clkrst_f1_clkdiv_cdc_divratio(
    .clkin                              (clkin_divctrl_buf),
    .resetn_sync                        (resetn_sync),

    .asyncbus                           (sel_divratio),
    .current_setting                    (divratio_cur),
    .asyncbus_stable                    (divratio_stable)
  );



  clkrst_f1_clkdiv_cdc   #(
    .CLKRST_ASYNC_SIGNAL_WIDTH  (8),
    .ASYNC_SIGNAL_SKEWDEPTH     (ASYNC_SIGNAL_SKEWDEPTH),
    .RESET_VALUE                (0)
  ) u_clkrst_f1_clkdiv_cdc_numerator(
    .clkin                              (clkin_divctrl_buf),
    .resetn_sync                        (resetn_sync),

    .asyncbus                           (isel_numerator),
    .current_setting                    (numerator_cur),
    .asyncbus_stable                    (numerator_stable)

  );


  clkrst_f1_clkdiv_cdc   #(
    .CLKRST_ASYNC_SIGNAL_WIDTH  (8),
    .ASYNC_SIGNAL_SKEWDEPTH     (ASYNC_SIGNAL_SKEWDEPTH),
    .RESET_VALUE                (0)
  ) u_clkrst_f1_clkdiv_denominator(
    .clkin                              (clkin_divctrl_buf),
    .resetn_sync                        (resetn_sync),

    .asyncbus                           (isel_denominator),
    .current_setting                    (denominator_cur),
    .asyncbus_stable                    (denominator_stable)

  );
end
else
begin : no_cdc_logic

  assign divratio_stable = sel_divratio;
  assign numerator_stable   = isel_numerator;
  assign denominator_stable = isel_denominator;

end
endgenerate


clkrst_f1_clkdiv_modulate  #(
    .DISABLE_NEGEDGE_5050MARK (DISABLE_NEGEDGE_5050MARK),
    .PIPELINE_DEPTH           (PIPELINE_DEPTH),
    .DISABLE_COMBO_GATELOGIC  (DISABLE_COMBO_GATELOGIC)

  ) u_clkrst_f1_clkdiv_modulate(
    .clkin                              (clkin_buf),        
    .clkin_divctrl                      (clkin_divctrl_buf),
    .clkin_n                            (clkin_buf_n),      
    .divratio                           (divratio_stable),  

    .numerator                          (numerator_stable),
    .denominator                        (denominator_stable),
    .stop_divider                       (stop_divider),

    .resetn_sync                        (resetn_sync),    
    .resetn_sync_n                      (resetn_sync_n),  

    .dftdivbypass                       (dftdivbypass),   
    .dftcgen                            (dftcgen),        

    .divratio_cur                       (divratio_cur),   

    .numerator_cur                      (numerator_cur),  
    .denominator_cur                    (denominator_cur),

    .divclk                             (divclk),         
    .hintclken_clk                      (hintclken_clk)   
);



endmodule
 
