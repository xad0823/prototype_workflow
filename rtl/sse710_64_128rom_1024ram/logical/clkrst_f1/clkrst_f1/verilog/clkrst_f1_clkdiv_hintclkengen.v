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

module clkrst_f1_clkdiv_hintclkengen
#(
    parameter PIPELINE_CORRECTION      = 0 
) 

(

  input   wire                          fastclk,        
  input   wire                          hintclken_clk,  

  input   wire                          resetn,         
  input   wire                          dftrstdisable,  
  input   wire                          dftmcphold,     

  output  wire                          clken           

);

  wire        resetn_sync;
  reg         hint_toggle;
  reg         hint_toggle_delay;
  wire        hint_toggle_xor;
  reg         iclken;


  clkrst_f1_rstsync u_clkrst_f1_rstsync_hintclkengen(
    .clk                                (fastclk),           
    .resetn_async                       (resetn),            
    .resetn_sync                        (resetn_sync),       
 
    .dftrstdisable                      (dftrstdisable)      
  );


  always @ (posedge hintclken_clk or negedge resetn_sync)
  begin                                   
    if (!resetn_sync)
    begin                     
      hint_toggle        <= 1'b0;         
    end
    else
    begin
      hint_toggle       <= ~hint_toggle;
    end      
  end                                     

  always @ (posedge fastclk or negedge resetn_sync)
  begin                                  
    if (!resetn_sync)                    
      hint_toggle_delay  <= 1'b0;         
    else                                 
      hint_toggle_delay <= hint_toggle;
  end                                    

  assign hint_toggle_xor = hint_toggle ^ hint_toggle_delay;

  always @ (posedge fastclk or negedge resetn_sync)
  begin                                  
    if (!resetn_sync)                    
      iclken <= 1'b0;         
    else                                 
      iclken <= hint_toggle_xor;
  end                                    



  reg   clken_correction_pipe[PIPELINE_CORRECTION:0];
  always @ (iclken) clken_correction_pipe[0] = iclken;  
    generate
      genvar i;
      if (PIPELINE_CORRECTION > 0)
        for (i=0; i<PIPELINE_CORRECTION; i=i+1)
        begin : gatecounter_pipeline
         always @ (posedge fastclk or negedge resetn_sync)
           if (!resetn_sync)                    
             clken_correction_pipe[i+1] <= 1'b0;         
           else                                 
             clken_correction_pipe[i+1] <= clken_correction_pipe[i];
        end
    endgenerate





  assign clken = (~dftmcphold) & clken_correction_pipe[PIPELINE_CORRECTION];


endmodule
 
