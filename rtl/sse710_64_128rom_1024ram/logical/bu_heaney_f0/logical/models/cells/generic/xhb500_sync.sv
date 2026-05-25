// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2018 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Mon Jun 18 12:26:53 2018 +0100
//
//      Revision            : 42b0335
//
//      Release Information : CoreLink XHB-500 Generic Global Bundle r0p0-00rel0
//
//-----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// This cell provides a discrete instance of a 2-stage synchroniser.
// The contents of this module can be replaced with an equivalent
// technology cell.
//----------------------------------------------------------------------------

module xhb500_sync (
      input  wire clk,
      input  wire reset_n,
      input  wire d,
      output wire q
   );


  wire meta;

  xhb500_flop  u_flop_meta (.clk(clk), .reset_n(reset_n), .d(d),     .q(meta));
  xhb500_flop  u_flop_sync (.clk(clk), .reset_n(reset_n), .d(meta),  .q(q));




endmodule
