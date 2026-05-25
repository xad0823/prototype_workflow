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

module arm_element_static_reg
#(
  parameter WIDTH=1
)
(
  input wire              clk,
  input wire              reset_n,
  input wire [WIDTH-1:0]  static_i,

  output wire [WIDTH-1:0] static_o
);

  reg [WIDTH-1:0]   static_r;
  reg               static_up;
  wire              static_en;


  always@(posedge clk)
  begin
    if(static_en)
    begin
      static_r[WIDTH-1:0] <= static_i[WIDTH-1:0];
    end
  end

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      static_up <= 1'b1;
    end
    else if(static_en)
    begin
      static_up <= 1'b0;
    end
  end

  assign static_en = static_up;

  assign static_o[WIDTH-1:0] = static_r[WIDTH-1:0];

endmodule



