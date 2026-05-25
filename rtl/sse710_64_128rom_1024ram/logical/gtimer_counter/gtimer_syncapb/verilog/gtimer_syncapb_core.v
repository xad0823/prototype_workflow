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


module gtimer_syncapb_core (
                    input  wire         clk,                              
                    input  wire         resetn,                           

                    input  wire [63:0]  tsvalueb,                         
                    
                    input  wire [63:0]  virtual_offset,                   
                    input  wire         compare_value_u_we_cntbasen,      
                    input  wire         compare_value_l_we_cntbasen,      
                    input  wire         timer_value_we_cntbasen,          
                    input  wire         timer_control_we_cntbasen,        
                    input  wire [31:0]  pwdata_enabled_cntbasen,          

                    input  wire         compare_value_u_we_cntpl0basen,   
                    input  wire         compare_value_l_we_cntpl0basen,   
                    input  wire         timer_value_we_cntpl0basen,       
                    input  wire         timer_control_we_cntpl0basen,     
                    input  wire [31:0]  pwdata_enabled_cntpl0basen,       

                    output reg  [63:0]  timer_count,                      
                    output reg  [63:0]  compare_value,                    
                    output reg  [31:0]  timer_value,                      
                    output reg   [2:0]  timer_control,                    

                    output reg          interrupt_out                     
                    );


wire [64:0]  next_count_minus_offset;
reg  [63:0]  count_minus_offset;
reg  [63:0]  next_compare_value;
reg  [31:0]  next_timer_value;
reg  [63:0]  assembled_compare_value;
wire [65:0]  calc_compare_value;
reg  [31:0]  new_timer_value;
wire [64:0]  sx_timer_value;
wire [64:0]  calc_timer_value;
wire         next_interrupt;
wire         interrupt_premask;
wire         interrupt_masked;
reg   [2:0]  next_timer_control;




assign next_count_minus_offset = {1'b0,tsvalueb} - {1'b0,virtual_offset};

always @(posedge clk or negedge resetn)
  if (~resetn)
    begin
      count_minus_offset <= 64'h0000_0000_0000_0000;
      timer_count        <= 64'h0000_0000_0000_0000;
    end
  else
    begin
      count_minus_offset <= next_count_minus_offset[63:0];
      timer_count        <= count_minus_offset;
    end


always @*
  case ({compare_value_l_we_cntbasen, compare_value_u_we_cntbasen, compare_value_l_we_cntpl0basen, compare_value_u_we_cntpl0basen})
      4'b0001 :  assembled_compare_value = {pwdata_enabled_cntpl0basen, compare_value[31:0]};
      4'b0010 :  assembled_compare_value = {compare_value[63:32], pwdata_enabled_cntpl0basen};
      4'b0100 :  assembled_compare_value = {pwdata_enabled_cntbasen, compare_value[31:0]};
      4'b1000 :  assembled_compare_value = {compare_value[63:32], pwdata_enabled_cntbasen};
    default :  assembled_compare_value = compare_value;
  endcase


assign  calc_timer_value = {1'b0,assembled_compare_value} - {1'b0,count_minus_offset};

always @*
  case ({timer_value_we_cntbasen, timer_value_we_cntpl0basen})
      2'b01 :  new_timer_value = pwdata_enabled_cntpl0basen;
      2'b10 :  new_timer_value = pwdata_enabled_cntbasen;
    default :  new_timer_value = timer_value;
  endcase

assign  sx_timer_value = (new_timer_value[31]) ? {{33{1'b1}}, new_timer_value}
                                           : {{33{1'b0}}, new_timer_value};

assign  calc_compare_value = {1'b0,count_minus_offset} + sx_timer_value;


always @*
  case ({timer_value_we_cntbasen, compare_value_l_we_cntbasen, compare_value_u_we_cntbasen,
         timer_value_we_cntpl0basen, compare_value_l_we_cntpl0basen, compare_value_u_we_cntpl0basen})
    6'b000001  :  begin 
                    next_compare_value[63:32] = pwdata_enabled_cntpl0basen;
                    next_compare_value[31:0]  = compare_value[31:0];
                    next_timer_value          = calc_timer_value[31:0];
                  end
    6'b000010  :  begin 
                    next_compare_value[63:32] = compare_value[63:32];
                    next_compare_value[31:0]  = pwdata_enabled_cntpl0basen;
                    next_timer_value          = calc_timer_value[31:0];
                  end
    6'b000100  :  begin 
                    next_compare_value[63:32] = calc_compare_value[63:32];
                    next_compare_value[31:0]  = calc_compare_value[31:0];
                    next_timer_value          = pwdata_enabled_cntpl0basen;
                  end
    6'b001000  :  begin 
                    next_compare_value[63:32] = pwdata_enabled_cntbasen;
                    next_compare_value[31:0]  = compare_value[31:0];
                    next_timer_value          = calc_timer_value[31:0];
                  end
    6'b010000  :  begin 
                    next_compare_value[63:32] = compare_value[63:32];
                    next_compare_value[31:0]  = pwdata_enabled_cntbasen;
                    next_timer_value          = calc_timer_value[31:0];
                  end
    6'b100000  :  begin 
                    next_compare_value[63:32] = calc_compare_value[63:32];
                    next_compare_value[31:0]  = calc_compare_value[31:0];
                    next_timer_value          = pwdata_enabled_cntbasen;
                  end
      default  :  begin 
                    next_compare_value[63:32] = compare_value[63:32];
                    next_compare_value[31:0]  = compare_value[31:0];
                    next_timer_value          = calc_timer_value[31:0];
                  end
endcase

always @(posedge clk or negedge resetn)
  if (~resetn)
    begin
      compare_value <= 64'h0000_0000_0000_0000;
      timer_value   <= 32'h0000_0000;
    end
  else
    begin
      compare_value <= next_compare_value;
      timer_value   <= next_timer_value;
    end

  
assign  next_interrupt = ((calc_timer_value[64:0] == 65'h0_0000_0000_0000_0000) | calc_timer_value[64]);


assign  interrupt_premask = next_interrupt & timer_control[0];
assign  interrupt_masked  = next_interrupt & ~timer_control[1] & timer_control[0];


always @*
  case ({timer_control_we_cntbasen, timer_control_we_cntpl0basen})
      2'b01 :  next_timer_control = {interrupt_premask, pwdata_enabled_cntpl0basen[1:0]};
      2'b10 :  next_timer_control = {interrupt_premask, pwdata_enabled_cntbasen[1:0]};
    default :  next_timer_control = {interrupt_premask, timer_control[1:0]};
  endcase
    
always @(posedge clk or negedge resetn)
  if (~resetn)
    begin
      timer_control <= 3'b000;
      interrupt_out <= 1'b0;
    end
  else
    begin
      timer_control <= next_timer_control;
      interrupt_out <= interrupt_masked;
    end


endmodule
