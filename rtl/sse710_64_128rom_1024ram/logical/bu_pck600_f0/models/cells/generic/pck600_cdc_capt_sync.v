// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2008-2019  Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//  Release Information : PCK600-r0p4-00eac0
//
// -----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
// -----------------------------------------------------------------------------
// Purpose : CDC Capture
//
// Clock domain crossing synchronizer.  This module should be used wherever
// an unsafe asynchronous input must be used.
//
// This module only comes in a single-bit, non-enabled form to simplify flows
// as much as possible.
//
// -----------------------------------------------------------------------------

module pck600_cdc_capt_sync (
  // ------------------------------------------------------
  // Port Declaration
  // ------------------------------------------------------
  input   wire  clk,
  input   wire  reset_n,
  input   wire  async,     // May be connected to an asynchronous input
  output  reg   sync
);

  // ------------------------------------------------------
  // reg/wire declarations
  // ------------------------------------------------------
  wire      d_noz;
  reg       d_sync1;


  assign d_noz = async;


  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      begin
        d_sync1 <= 1'b0;
        sync    <= 1'b0;
      end
    else
      begin
        d_sync1 <= d_noz;
        sync    <= d_sync1;
      end


endmodule
