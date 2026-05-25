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

module nic400_ib_slave_9_ib_cdc_air_corrupt_sse710_sys_apb (
  d,
  q
  );

  parameter WIDTH = 1;
  parameter DIRECTION = "fwd";
  
  input  [WIDTH-1:0]  d;
  output [WIDTH-1:0]  q;


`ifdef ARM_CDC_CHECK

  wire                  change;
  reg      [WIDTH-1:0]  d_latch;
  wire     [WIDTH-1:0]  out;
  wire     clk;
  wire     async;
  reg      p1;
  reg      p2;

  `ifdef ARM_CDC_BLOCK_LEVEL
  
      assign async = 1'b1;

      assign clk   = (DIRECTION == "fwd") ? u_DUT.ctrlclk
                                          : u_DUT.aclk;

  `else

      assign async = 1'b1;


      assign clk   = (DIRECTION == "fwd") ? nic400_sse710_sys_apb.ctrlclk
                                          : nic400_sse710_sys_apb.aclk;

  `endif


  assign q = (async) ? out : d;

  always @(d)
     d_latch <= d;

  assign change = (d !== d_latch);   

  always @(posedge clk or posedge change)
    begin 
       if (change) begin
          p1 <= 1'b1;
          p2 <= 1'b1;
       end else begin
          p1 <= 1'b0;
          p2 <= p1;
       end
    end

  assign out = (p2) ? {WIDTH{1'bz}} : d;

`else

  assign q = d;

`endif
  
endmodule
