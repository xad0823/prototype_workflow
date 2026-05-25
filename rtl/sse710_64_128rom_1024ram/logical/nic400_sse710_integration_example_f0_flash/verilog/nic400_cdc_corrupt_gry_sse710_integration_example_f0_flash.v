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

module nic400_cdc_corrupt_gry_sse710_integration_example_f0_flash (
  clk, 
  resetn, 
  sync,
  d_async,
  q_async
  );

  parameter WIDTH = 1;
  
  input               clk; 
  input               resetn; 
  input               sync;
  input  [WIDTH-1:0]  d_async;
  output [WIDTH-1:0]  q_async;


`ifdef ARM_CDC_CHECK

  reg      [WIDTH-1:0]  d_latch;
  reg      [WIDTH-1:0]  out_async;
  reg      [WIDTH-1:0]  corrupt;
  wire     [WIDTH-1:0]  change_vector;
  wire                  change;

  integer            i;

  assign q_async = (sync) ? d_async : out_async;

  always @(d_async)
     d_latch <= d_async; 

  assign change_vector = (d_async ^ d_latch);

  assign change = |change_vector;
  
  always @(posedge clk or posedge change)
    begin 
       if (change) begin
          corrupt <= change_vector;
       end else begin
          corrupt <= {WIDTH{1'b0}};
       end
    end

  always @(corrupt or d_async)
    for (i = 0; i < WIDTH; i=i+1) begin
       out_async[i] = corrupt[i] ? 1'bz : d_async[i];
    end   
  
`else

  assign q_async = d_async;

`endif
  
endmodule
