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

module nic400_cdc_comb_mux2_sse710_integration_example_f0_host_exp
(
  din1_async,
  din2_async,
  sel,
  dout_async
);


  input     din1_async; 
  input     din2_async; 
  input     sel;
  output    dout_async;

  reg       muxout;
  wire      dout_async;

  always @(din1_async or din2_async or sel)
    case (sel)
      1'b0 : muxout = din1_async;
      1'b1 : muxout = din2_async;
      default : muxout = 1'bx;
    endcase
  
`ifdef ARM_CDC_CHECK
  assign dout_async = (sel === 1'bz) ? 1'bz : muxout;
`else
  assign dout_async = muxout;
`endif
  
endmodule

