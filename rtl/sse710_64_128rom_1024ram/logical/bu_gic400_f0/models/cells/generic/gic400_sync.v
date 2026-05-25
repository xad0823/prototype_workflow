//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2011-2012 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2011-03-18 22:40:52 +0000 (Fri, 18 Mar 2011) $
//
//      Revision            : $Revision: 165199 $
//
//      Release Information : GIC-400-r0p1-00rel0
//
//------------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Abstract: discrete synchroniser cell - resets to 0
// ----------------------------------------------------------------------------

module gic400_sync (
  input  wire clk_i,
  input  wire inp_i,
  input  wire resetn_i,
  output wire out_o
);

  reg r0,r1;

  always @(posedge clk_i or negedge resetn_i)
    if (!resetn_i) begin
      r0 <= 1'b0;
      r1 <= 1'b0;
    end
    else begin
      r0 <= inp_i;
      r1 <= r0;
    end

   assign out_o = r1;

endmodule
