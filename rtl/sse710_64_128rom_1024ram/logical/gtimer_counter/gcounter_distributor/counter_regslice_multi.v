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

module counter_regslice_multi
  #(
    parameter  COUNTER_WIDTH = 64,
    parameter  STAGES = 4

  )
  (
  input   wire                      nreset,
  input   wire                      clk,
  input   wire  [COUNTER_WIDTH-1:0] count_in,
  output  wire  [COUNTER_WIDTH-1:0] count_out

  );
 
  wire  [COUNTER_WIDTH-1:0] count_stages[STAGES:0];

  assign count_stages[0] = count_in;

  genvar i;
    generate
     for (i=0; i<STAGES; i=i+1)
     begin : DEPTH
     counter_regslice #(
       .COUNTER_WIDTH  (COUNTER_WIDTH)
     ) u_counter_regslice (
       .clk            (clk),
       .nreset         (nreset),
       .count_in       (count_stages[i]),
       .count_out      (count_stages[i+1]));
     end
    endgenerate

  assign count_out = count_stages[STAGES];

  
endmodule
