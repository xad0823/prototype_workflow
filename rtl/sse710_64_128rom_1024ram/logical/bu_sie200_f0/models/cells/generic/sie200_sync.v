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
// This cell provides a discrete instance of a 2-stage synchroniser.
// The contents of this module can be replaced with an equivalent
// technology cell.
//----------------------------------------------------------------------------

module sie200_sync (
      input  wire clk,
      input  wire reset_n,
      input  wire d,
      output wire q
   );


  wire meta;

  sie200_flop  u_flop_meta (.clk(clk), .reset_n(reset_n), .d(d),     .q(meta));
  sie200_flop  u_flop_sync (.clk(clk), .reset_n(reset_n), .d(meta),  .q(q));




endmodule
