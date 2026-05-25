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


module gcounter_asyncapb_counter_core (
  input  wire         clk,                     
  input  wire         resetn,                  
  
  input  wire         enable_counter,          
  input  wire         preload_cntcvl,          
  input  wire         preload_cntcvu,          
  input  wire [31:0]  preload_cntcvl_data,     
  input  wire [31:0]  preload_cntcvu_data,     

  output wire [63:0]  tsvalueb,                
  output reg          tsforcesync              
  );
  
  parameter P  = 5;                            
  
  parameter PW = P - 1;                        
  parameter M  = 64 - P;                       
  parameter MW = M - 1;                        
  
  reg [PW:0] precount;                         
  reg [MW:0] maincount;                        
  reg [PW:0] next_precount;
  reg [MW:0] next_maincount;
  
  reg  enincr_maincount;
  wire next_enincr_maincount;

  reg  first_enable;
  wire next_first_enable;
  reg  preloadlp;
  reg  preloadlm;
  reg  preloadu;
  wire preload;
  wire rollover;
  wire next_tsforcesync;
  wire first_enable_pulse;


  wire [31:0]  preload_cntcvl_data_glitchless;
  wire [31:0]  preload_cntcvu_data_glitchless;

  
  gtimer_counter_glitch_gate 
    #(
        .WIDTH(32)
     )
     u_preload_cntcvu_data_glitchless 
     (
        .async_in    (preload_cntcvu_data),
        .async_out   (preload_cntcvu_data_glitchless),
        .input_valid (preload_cntcvu)
     );

  gtimer_counter_glitch_gate 
    #(
        .WIDTH(32)
     )
     u_preload_cntcvl_data_glitchless 
     (
        .async_in    (preload_cntcvl_data),
        .async_out   (preload_cntcvl_data_glitchless),
        .input_valid (preload_cntcvl)
     );
     
  always @*
    begin
      preloadlp = 1'b0;
      case ({enable_counter, preload_cntcvl})
         2'b01 : begin
                   next_precount = preload_cntcvl_data_glitchless[PW:0];
                   preloadlp = 1'b1;
                 end
         2'b10 : next_precount = precount + 1'b1;
         2'b11 : next_precount = precount + 1'b1;
       default : next_precount = precount;
      endcase
    end

  assign next_enincr_maincount = &next_precount;



  always @*
    begin
      preloadlm = 1'b0;
      preloadu = 1'b0;
      case ({enincr_maincount, enable_counter, preload_cntcvu, preload_cntcvl})
        4'b0001 : begin
                    next_maincount = {maincount[63-P:32-P], preload_cntcvl_data_glitchless[31:P]};
                    preloadlm = 1'b1;
                  end
        4'b0010 : begin
                    next_maincount = {preload_cntcvu_data_glitchless,  maincount[31-P:0]};
                    preloadu = 1'b1;
                  end
        4'b0011 : begin
                    next_maincount = {preload_cntcvu_data_glitchless,  preload_cntcvl_data_glitchless[31:P]};
                    preloadlm = 1'b1;
                    preloadu = 1'b1;
                  end
        4'b1001 : begin
                    next_maincount = {maincount[63-P:32-P], preload_cntcvl_data_glitchless[31:P]};
                    preloadlm = 1'b1;
                  end
        4'b1010 : begin
                    next_maincount = {preload_cntcvu_data_glitchless,  maincount[31-P:0]};
                    preloadu = 1'b1;
                  end
        4'b1011 : begin
                    next_maincount = {preload_cntcvu_data_glitchless,  preload_cntcvl_data_glitchless[31:P]};
                    preloadlm = 1'b1;
                    preloadu = 1'b1;
                  end
        4'b1100 : next_maincount = maincount + 1'b1;
        4'b1101 : next_maincount = maincount + 1'b1;
        4'b1110 : next_maincount = maincount + 1'b1;
        4'b1111 : next_maincount = maincount + 1'b1;
        default : next_maincount = maincount;
      endcase
    end


  always @( posedge clk or negedge resetn )
    if ( ~resetn )
      begin
        precount         <= {P{1'b0}};
        maincount        <= {M{1'b0}};
        enincr_maincount <= 1'b0;
      end
    else
      begin
        precount         <= next_precount;
        maincount        <= next_maincount;
        enincr_maincount <= next_enincr_maincount;
      end  


  assign tsvalueb = { maincount, precount };



  assign next_first_enable = (enable_counter | preload | rollover) ? 1'b0 : first_enable;

  always @( posedge clk or negedge resetn)
    if ( ~resetn )
      first_enable <= 1'b1;
    else
      first_enable <= next_first_enable;
  
  assign first_enable_pulse = enable_counter & first_enable;


  assign preload  = preloadu | preloadlp | preloadlm;
  
  
  assign rollover = ( tsvalueb == 64'hFFFF_FFFF_FFFF_FFFF );
  

  assign next_tsforcesync = first_enable_pulse | preload | rollover;

  always @( posedge clk or negedge resetn )
    if ( ~resetn )
      tsforcesync  <=  1'b0;
    else
      tsforcesync  <=  next_tsforcesync;

endmodule
