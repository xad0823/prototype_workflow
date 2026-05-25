// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2017 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Thu Sep 14 16:10:10 2017 +0100
//
//      Revision            : 9cb8cee
//
//      Release Information : Vultan Generic Flash Controller - Global Bundle r0p0-00rel0
//
//-----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Implementations should replace this with a cell that is known to be
// glitch-free while switching inputs are at same level.
//----------------------------------------------------------------------------

module vultan_mux (in_a, in_b, sel, out_y);

  parameter DATA_WIDTH = 1;

  input  [DATA_WIDTH-1:0] in_a;
  input  [DATA_WIDTH-1:0] in_b;
  input                   sel;
  output [DATA_WIDTH-1:0] out_y;

  reg [DATA_WIDTH-1:0] w_out;


  always @(in_a or in_b or sel)
    case (sel)
      1'b0 : w_out = in_a;
      1'b1 : w_out = in_b;
      default : w_out = {DATA_WIDTH{1'bx}};
    endcase


  assign out_y = w_out;

endmodule
