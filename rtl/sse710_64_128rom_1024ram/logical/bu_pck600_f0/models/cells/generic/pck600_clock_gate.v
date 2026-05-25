// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2014-2019  Arm Limited or its affiliates.
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
// Purpose : Generic clock gate cell
//
// -----------------------------------------------------------------------------

module pck600_clock_gate (
  input   wire                          clk_in,
  input   wire                          enable,
  output  wire                          clk_out,
  input   wire                          dftcgen

);

  // -----------------------------------------------------------------------------
  // Implement clock gate logic
  // -----------------------------------------------------------------------------

  reg clk_enable_lat;

  always @ (clk_in or enable or dftcgen)
    begin
      if (~clk_in)
        clk_enable_lat <= enable | dftcgen;
    end

  assign clk_out = clk_in & clk_enable_lat;

  // -----------------------------------------------------------------------------
  // End of module
  // -----------------------------------------------------------------------------

endmodule
