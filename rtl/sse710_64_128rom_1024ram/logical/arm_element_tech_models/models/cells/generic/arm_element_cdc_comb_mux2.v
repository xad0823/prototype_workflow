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

module arm_element_cdc_comb_mux2 (din1_async, din2_async, sel, dout_async);

  parameter WIDTH = 1; 

  input   wire  [WIDTH-1:0] din1_async; 
  input   wire  [WIDTH-1:0] din2_async; 
  input   wire              sel;
  output  wire  [WIDTH-1:0] dout_async;

  wire [WIDTH-1:0] muxout;

  generate
    genvar i;
    for(i=0 ; i<WIDTH ; i=i+1) begin : BK_COMB_MUX
      arm_mux2 u_mux2 (
              .a_i   (din1_async[i]),
              .b_i   (din2_async[i]),
              .sel_i (sel),
              .y_o   (muxout[i])
      );
    end
  endgenerate

`ifdef ARM_CDC_CHECK
  assign dout_async = (sel === 1'bz) ? {WIDTH{1'bz}} : muxout;
`else 
  assign dout_async = muxout;
`endif 
  

endmodule
