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
//      Checked In          : Mon Sep 18 16:19:37 2017 +0100
//
//      Revision            : e9f2264
//
//      Release Information : Vultan Generic Flash Controller - Global Bundle r0p0-00rel0
//
//-----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// This cell provides a discrete instance of a 2-stage synchroniser.
// The contents of this module can be replaced with an equivalent
// technology cell.
//----------------------------------------------------------------------------

module vultan_sync (
      input  wire clk,
      input  wire reset_n,
      input  wire d,
      output wire q
   );


  wire meta;

  vultan_flop  u_flop_meta (.clk(clk), .reset_n(reset_n), .d(d),     .q(meta));
  vultan_flop  u_flop_sync (.clk(clk), .reset_n(reset_n), .d(meta),  .q(q));




endmodule
