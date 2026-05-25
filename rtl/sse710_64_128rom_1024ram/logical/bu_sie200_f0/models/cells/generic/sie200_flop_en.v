// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Tue Oct 11 14:47:15 2016 +0100
//
//      Revision            : 9dbdc26
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Cell implementing a D-type enabled flop with guaranteed electrically stable
// output when clocked but not enabled (i.e. an actual implementation may want
// to use a clock gate feeding a D-type here) or clocked and enabled but not
// changing logic value.
//----------------------------------------------------------------------------

module sie200_flop_en #(
  parameter DATA_WIDTH = 1
  )(
  input  wire                   clk,
  input  wire                   reset_n,
  input  wire                   en,
  input  wire [DATA_WIDTH-1:0]  d,
  output wire [DATA_WIDTH-1:0]  q
);


   reg [DATA_WIDTH-1:0] q_q;

   always @(posedge clk or negedge reset_n)
      if(~reset_n)
         q_q <= {DATA_WIDTH{1'b0}};
      else if(en)
         q_q <= d;

   assign q = q_q;

endmodule
