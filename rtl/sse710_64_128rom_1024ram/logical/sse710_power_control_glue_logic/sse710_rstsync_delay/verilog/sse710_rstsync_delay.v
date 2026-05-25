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
module sse710_rstsync_delay
#(
    parameter RESET_DELAY_CYCLES = 0 
) 

(
  input   wire                          clk,              
  input   wire                          resetn_async,     

  output  wire                          resetn_syncdelay, 
  input   wire  [1:0]                   dftrstdisable     


);


  wire                                  ireset_sync;

  reg  [5:0]                            reset_delay_counter; 
  reg                                   iresetn_syncdelay;



  arm_element_reset_sync u_rstsync_rstdelay(
    .clk                                (clk),            
    .resetn_async                       (resetn_async),   
    .resetn_sync                        (ireset_sync),    
 
    .dftrstdisable                      (dftrstdisable[1])
  );



  always @(posedge clk or negedge ireset_sync)
  begin
    if (!ireset_sync)
     begin
        reset_delay_counter <= RESET_DELAY_CYCLES;
     end
     else if (reset_delay_counter != 6'b000000)
     begin
      reset_delay_counter <= reset_delay_counter - 6'b000001;
     end
     else
     begin
      reset_delay_counter <= 6'b000000;
     end
  end



  always @(posedge clk or negedge ireset_sync)
  begin
    if (!ireset_sync)
     begin
       iresetn_syncdelay <= 1'b0;
     end
     else
     begin
       if (reset_delay_counter == 6'b000000)
         iresetn_syncdelay <= 1'b1;
       else
         iresetn_syncdelay <= 1'b0;
     end
   end
       
  
  arm_element_std_or2 u_resetn_syncdelay_dftrstdisable_or2 ( .A (iresetn_syncdelay), .B (dftrstdisable[0]), .Y (resetn_syncdelay));

  
endmodule
