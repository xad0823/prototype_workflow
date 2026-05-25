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

module nic400_sync_flop_sse710_integration_example_f0_host_exp
(
  input  wire clk,
  input  wire resetn,
  input  wire din,
  output reg  dout
);

  always @(posedge clk or negedge resetn)
  begin : sse710_integration_example_f0_host_exp_sync_flop_cell
    if (!resetn)
      dout <= 1'b0;
    else
      dout <= din;
  end

endmodule

