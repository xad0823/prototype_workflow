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


module gcounter_syncapb_counter_core_ts (
  input  wire         clk,                     
  input  wire         resetn,                  
  
  input  wire         counter_start_stopn,     
  input  wire         counter_preload_enable,  
  input  wire         preload_cnt_l,           
  input  wire         preload_cnt_u,           
  input  wire [31:0]  preload_cnt_data,        
  input  wire [63:0]  preload_sync_data,        
  input  wire         counter_start_forcesync, 

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


  always @*
    begin
      preloadlp = 1'b0;
      case ({counter_start_stopn, counter_preload_enable, preload_cnt_l})
         3'b011 : begin
                    next_precount = preload_cnt_data[PW:0];
                    preloadlp = 1'b1;
                  end
         3'b100 : next_precount = precount + 1'b1;
         3'b101 : next_precount = precount + 1'b1;
         3'b110 : next_precount = precount + 1'b1;
         3'b111 : next_precount = precount + 1'b1;
       default : next_precount = precount;
      endcase
    end

  assign next_enincr_maincount = &next_precount;


  always @*
    begin
      preloadlm = 1'b0;
      preloadu = 1'b0;
      case ({enincr_maincount, counter_start_stopn, counter_preload_enable, preload_cnt_u, preload_cnt_l})
        5'b00101 : begin
                     next_maincount = {maincount[63-P:32-P], preload_cnt_data[31:P]};
                     preloadlm = 1'b1;
                   end
        5'b00110 : begin
                     next_maincount = {preload_cnt_data, maincount[31-P:0]};
                     preloadu = 1'b1;
                   end
        5'b10101 : begin
                     next_maincount = {maincount[63-P:32-P], preload_cnt_data[31:P]};
                     preloadlm = 1'b1;
                   end
        5'b10110 : begin
                     next_maincount = {preload_cnt_data, maincount[31-P:0]};
                     preloadu = 1'b1;
                   end
        5'b00111, 5'b10111 : begin
                     next_maincount = {preload_sync_data[63:P]};
                     preloadu = 1'b1;
                   end
        5'b11000 : next_maincount = maincount + 1'b1;
        5'b11001 : next_maincount = maincount + 1'b1;
        5'b11010 : next_maincount = maincount + 1'b1;
        5'b11011 : next_maincount = maincount + 1'b1;
        5'b11100 : next_maincount = maincount + 1'b1;
        5'b11101 : next_maincount = maincount + 1'b1;
        5'b11110 : next_maincount = maincount + 1'b1;
        5'b11111 : next_maincount = maincount + 1'b1;
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



  assign next_first_enable = (counter_start_forcesync | preload | rollover) ? 1'b0 : first_enable;

  always @( posedge clk or negedge resetn)
    if ( ~resetn )
      first_enable <= 1'b1;
    else
      first_enable <= next_first_enable;
  
  assign first_enable_pulse = counter_start_forcesync & first_enable;


  assign preload  = preloadu | preloadlp | preloadlm;
  
  
  assign rollover = ( tsvalueb == 64'hFFFF_FFFF_FFFF_FFFF );
  

  assign next_tsforcesync = first_enable_pulse | preload | rollover;

  always @( posedge clk or negedge resetn )
    if ( ~resetn )
      tsforcesync  <=  1'b0;
    else
      tsforcesync  <=  next_tsforcesync;
      

endmodule
