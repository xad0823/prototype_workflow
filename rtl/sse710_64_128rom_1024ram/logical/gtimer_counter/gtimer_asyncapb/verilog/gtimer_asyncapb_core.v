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



module gtimer_asyncapb_core (
                    input  wire         clk,                              
                    input  wire         resetn,                           

                    input  wire [63:0]  tsvalueb,                         
                    
                    output reg          cntvoff_sync,                     
                    input  wire [63:0]  int_cntvoff,                      
                    
                    input  wire         lcval_write_in_progress_toggle,   
                    output wire         lcval_write_complete,             
                    input  wire [31:0]  lcval_write_val,                  
                    input  wire         ucval_write_in_progress_toggle,   
                    output wire         ucval_write_complete,             
                    input  wire [31:0]  ucval_write_val,                  
                    input  wire         tval_write_in_progress_toggle,    
                    output wire         tval_write_complete,              
                    input  wire [31:0]  tval_write_val,                   
                    input  wire         ctl_write_in_progress_toggle,     
                    output wire         ctl_write_complete,               
                    input  wire [1:0]   ctl_write_val,                    

                    output reg  [63:0]  timer_count,                      
                    output reg  [31:0]  timer_value,                      
                    output reg  [63:0]  compare_value,                    
                    output reg   [2:0]  timer_control,                    
                    output reg          update_timer_regs,                

                    output reg          interrupt_out                     
                    );

reg  [63:0]  int_tsvalueb;

wire         lcval_latch_data;
wire         ucval_latch_data;
wire         tval_latch_data;
wire         ctl_latch_data;

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


always @(posedge clk or negedge resetn)
  if (~resetn)
    int_tsvalueb <= 64'h0000_0000_0000_0000;
  else
    int_tsvalueb <= tsvalueb;

always @(posedge clk or negedge resetn)
  if (~resetn)
    cntvoff_sync  <=  1'b0;
  else
    cntvoff_sync  <= ~cntvoff_sync;

gct_syncpulse u_gct_syncpulse_lcval (
                    .clk     ( clk                            ),
                    .reset_n ( resetn                         ),
                    .data_i  ( lcval_write_in_progress_toggle ),
                    .pulse_o ( lcval_latch_data               ),
                    .ack_o   ( lcval_write_complete           )
                    );

gct_syncpulse u_gct_syncpulse_ucval (
                    .clk     ( clk                            ),
                    .reset_n ( resetn                         ),
                    .data_i  ( ucval_write_in_progress_toggle ),
                    .pulse_o ( ucval_latch_data               ),
                    .ack_o   ( ucval_write_complete           )
                    );

gct_syncpulse u_gct_syncpulse_tval (
                    .clk     ( clk                            ),
                    .reset_n ( resetn                         ),
                    .data_i  ( tval_write_in_progress_toggle  ),
                    .pulse_o ( tval_latch_data                ),
                    .ack_o   ( tval_write_complete            )
                    );

gct_syncpulse u_gct_syncpulse_ctl (
                    .clk     ( clk                            ),
                    .reset_n ( resetn                         ),
                    .data_i  ( ctl_write_in_progress_toggle   ),
                    .pulse_o ( ctl_latch_data                 ),
                    .ack_o   ( ctl_write_complete             )
                    );



assign next_count_minus_offset = {1'b0,int_tsvalueb} - {1'b0,int_cntvoff};

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



  wire [31:0]  ucval_write_val_glitch_gated;
  wire [31:0]  tval_write_val_glitch_gated;
  wire [31:0]  lcval_write_val_glitch_gated;
                      
  
  gtimer_counter_glitch_gate #( 
  .WIDTH(32) 
  )
  u_ucval_write_val_glitch_gated (         
      .async_in (ucval_write_val),
      .async_out(ucval_write_val_glitch_gated),
      .input_valid(ucval_latch_data)        
  );
  
  gtimer_counter_glitch_gate #( 
  .WIDTH(32) 
  )
  u_tval_write_val_glitch_gated (         
      .async_in (tval_write_val),
      .async_out(tval_write_val_glitch_gated),
      .input_valid(tval_latch_data)        
  );
  gtimer_counter_glitch_gate #( 
  .WIDTH(32) 
  )
  u_lcval_write_val_glitch_gated (         
      .async_in (lcval_write_val),
      .async_out(lcval_write_val_glitch_gated),
      .input_valid(lcval_latch_data)        
  );
 
  
  
  
  
always @*
  case ({lcval_latch_data, ucval_latch_data})
      2'b01 :  assembled_compare_value = {ucval_write_val_glitch_gated, compare_value[31:0]};
      2'b10 :  assembled_compare_value = {compare_value[63:32], lcval_write_val_glitch_gated};
      2'b11 :  assembled_compare_value = {ucval_write_val_glitch_gated, lcval_write_val_glitch_gated};
    default :  assembled_compare_value = compare_value;
  endcase


assign  calc_timer_value = {1'b0,assembled_compare_value} - {1'b0,count_minus_offset};

always @*
  if (tval_latch_data)
    new_timer_value = tval_write_val_glitch_gated;
  else
    new_timer_value = timer_value;

assign  sx_timer_value = (new_timer_value[31]) ? {{33{1'b1}}, new_timer_value}
                                               : {{33{1'b0}}, new_timer_value};

assign  calc_compare_value = {1'b0,count_minus_offset} + sx_timer_value;


always @*
  case ({tval_latch_data, lcval_latch_data, ucval_latch_data})
    3'b001  :  begin 
                 next_compare_value[63:32] = ucval_write_val_glitch_gated;
                 next_compare_value[31:0]  = compare_value[31:0];
                 next_timer_value          = calc_timer_value[31:0];
               end
    3'b010  :  begin 
                 next_compare_value[63:32] = compare_value[63:32];
                 next_compare_value[31:0]  = lcval_write_val_glitch_gated;
                 next_timer_value          = calc_timer_value[31:0];
               end
    3'b011  :  begin 
                 next_compare_value[63:32] = ucval_write_val_glitch_gated;
                 next_compare_value[31:0]  = lcval_write_val_glitch_gated;
                 next_timer_value          = calc_timer_value[31:0];
               end
    3'b100  :  begin 
                 next_compare_value[63:32] = calc_compare_value[63:32];
                 next_compare_value[31:0]  = calc_compare_value[31:0];
                 next_timer_value          = tval_write_val_glitch_gated;
               end
    3'b101  :  begin 
                 next_compare_value[63:32] = ucval_write_val_glitch_gated;
                 next_compare_value[31:0]  = calc_compare_value[31:0];
                 next_timer_value          = tval_write_val_glitch_gated;
               end
    3'b110  :  begin 
                 next_compare_value[63:32] = calc_compare_value[63:32];
                 next_compare_value[31:0]  = lcval_write_val_glitch_gated;
                 next_timer_value          = tval_write_val_glitch_gated;
               end
    3'b111  :  begin 
                 next_compare_value[63:32] = ucval_write_val_glitch_gated;
                 next_compare_value[31:0]  = lcval_write_val_glitch_gated;
                 next_timer_value          = tval_write_val_glitch_gated;
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



 wire [1:0] ctl_write_val_glitch_gated;
 gtimer_counter_glitch_gate #( 
  .WIDTH(2) 
  )
  u_ctl_write_val_glitch_gated (         
      .async_in (ctl_write_val),
      .async_out(ctl_write_val_glitch_gated),
      .input_valid(ctl_latch_data)        
  );
 
 
always @*
  if (ctl_latch_data)
    next_timer_control = {interrupt_premask, ctl_write_val_glitch_gated[1:0]};
  else
    next_timer_control = {interrupt_premask, timer_control[1:0]};

    
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




always @(posedge clk or negedge resetn)
  if (~resetn)
     update_timer_regs <= 1'b0;
  else
     update_timer_regs <= ~update_timer_regs;




endmodule
