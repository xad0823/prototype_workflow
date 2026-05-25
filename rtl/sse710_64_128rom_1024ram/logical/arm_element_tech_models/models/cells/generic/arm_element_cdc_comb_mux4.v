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

module arm_element_cdc_comb_mux4 (din1_async, din2_async, din3_async, 
                      din4_async, sel, dout_async);

  parameter WIDTH = 1; 

  input   wire  [WIDTH-1:0] din1_async; 
  input   wire  [WIDTH-1:0] din2_async; 
  input   wire  [WIDTH-1:0] din3_async; 
  input   wire  [WIDTH-1:0] din4_async; 
  input   wire  [1:0]       sel;
  output  wire  [WIDTH-1:0] dout_async;

  wire [WIDTH-1:0] muxout;
  wire [WIDTH-1:0] muxout_int0;
  wire [WIDTH-1:0] muxout_int1;

  generate
      genvar i;
      for(i=0 ; i<=WIDTH-1 ; i=i+1) begin : MUX0
      arm_mux2 u_inst_mux2_0(
         .a_i (din1_async[i]),
         .b_i (din2_async[i]),
         .sel_i (sel[0]), 
         .y_o (muxout_int0[i]));
      end
  endgenerate

  generate
      genvar j;
      for(j=0 ; j<=WIDTH-1 ; j=j+1) begin : MUX1
      arm_mux2 u_inst_mux2_1(
         .a_i (din3_async[j]),
         .b_i (din4_async[j]),
         .sel_i (sel[0]), 
         .y_o (muxout_int1[j]));
      end
  endgenerate

  generate
      genvar k;
      for(k=0 ; k<=WIDTH-1 ; k=k+1) begin : MUX2
      arm_mux2 u_inst_mux2_2(
         .a_i (muxout_int0[k]),
         .b_i (muxout_int1[k]),
         .sel_i (sel[1]), 
         .y_o (muxout[k]));
      end
  endgenerate

`ifdef ARM_CDC_CHECK
  assign dout_async = ((sel[0] === 1'bz) || (sel[1] === 1'bz)) ? 
                      {WIDTH{1'bz}} : muxout;
`else 
  assign dout_async = muxout;
`endif 
  
endmodule
