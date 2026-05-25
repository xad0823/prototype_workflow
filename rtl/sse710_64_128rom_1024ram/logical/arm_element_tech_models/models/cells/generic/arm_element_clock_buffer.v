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

module arm_element_clock_buffer #(
  parameter CLOCK_DELAY = 0
)(
  input   wire                          clk_in,
  output  wire                          clk_out
  
);

  wire i_clk_delay; 
  
  generate
          if(CLOCK_DELAY == 0)
          begin : arm_element_clock_buffer_nodelay
            arm_buffer u_buffer (
                    .a_i (clk_in),
                    .y_o (clk_out)
            );
          end 
          else
          begin : arm_element_clock_buffer_delay
            buf #(CLOCK_DELAY) (i_clk_delay,clk_in);
            arm_buffer u_buffer (
                    .a_i (i_clk_delay),
                    .y_o (clk_out)
            );
          end 
  endgenerate

  
endmodule
