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

module nic400_cdc_comb_or2_sse710_integration_example_f0_upsizer (din1_async, din2_async, dout_async);

  input  din1_async; 
  input  din2_async; 
  output dout_async;

  reg    dout_async;
  always @(din1_async or din2_async)
    begin
`ifdef ARM_CDC_CHECK
      case ({din1_async, din2_async})
        2'b00 : dout_async = 1'b0;
        2'b01 : dout_async = 1'b1;
        2'b0x : dout_async = 1'b0;
        2'b0z : dout_async = 1'b0;
        2'b10 : dout_async = 1'b1;
        2'bx0 : dout_async = 1'b0;
        2'bz0 : dout_async = 1'b0;
        2'b11 : dout_async = 1'b1;
        2'b1z : dout_async = 1'bz;
        2'bxz : dout_async = 1'bz;
        2'bz1 : dout_async = 1'bz;
        2'bzx : dout_async = 1'bz;
        default : dout_async = 1'bx;
      endcase
`else
      dout_async = din1_async | din2_async;
`endif
    end
  
endmodule
