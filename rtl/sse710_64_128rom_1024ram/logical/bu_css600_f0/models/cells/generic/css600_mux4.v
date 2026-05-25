//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Top level of css600_mux4
//
//----------------------------------------------------------------------------

module css600_mux4 (din1_async, din2_async, din3_async,
                      din4_async, sel, dout_async);

  parameter WIDTH = 1; // input width

  // ------------------------------------------------------
  // port declaration
  // ------------------------------------------------------
  input  [WIDTH-1:0] din1_async; // May be connected to an asynchronous input
  input  [WIDTH-1:0] din2_async; // May be connected to an asynchronous input
  input  [WIDTH-1:0] din3_async; // May be connected to an asynchronous input
  input  [WIDTH-1:0] din4_async; // May be connected to an asynchronous input
  input  [1:0]       sel;
  output [WIDTH-1:0] dout_async;

  // ------------------------------------------------------
  // reg/wire declarations
  // ------------------------------------------------------
  reg [WIDTH-1:0] muxout;
  wire [WIDTH-1:0] dout_async;

  always @(din1_async or din2_async or din3_async or din4_async or sel)
    case (sel)
      2'b00 : muxout = din1_async;
      2'b01 : muxout = din2_async;
      2'b10 : muxout = din3_async;
      2'b11 : muxout = din4_async;
      default : muxout = {WIDTH{1'bx}};
    endcase

  assign dout_async = muxout;

endmodule
