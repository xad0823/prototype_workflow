// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2014-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Thu Aug 11 15:30:11 2016 +0100
//
//      Revision            : acfcb47
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//
// -----------------------------------------------------------------------------

module sie200_static_reg
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
