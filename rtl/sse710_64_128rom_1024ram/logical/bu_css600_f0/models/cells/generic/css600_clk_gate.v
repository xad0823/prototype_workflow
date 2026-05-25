//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Top level of css600_clk_gate
//
//----------------------------------------------------------------------------

module css600_clk_gate (
  input  wire  clk_i,         // Input clock
  input  wire  clk_enable_i,  // Clock enable
  output wire  clk_o,         // Gated output clock

  input  wire  dftcgen        // Test mode override for clock gate
);

  //----------------------------------------------------------------------------
  // Wires and regs
  //----------------------------------------------------------------------------
  wire clk_enable_dft;
/* verilator lint_off UNOPTFLAT */
  reg  clk_en_lat;
/* verilator lint_on UNOPTFLAT */

  // DFT override
  assign clk_enable_dft = clk_enable_i | dftcgen;

  // Behavioural latch
  always @ (clk_i or clk_enable_dft)
  begin
    if (!clk_i)
/* verilator lint_off COMBDLY */
      clk_en_lat <= clk_enable_dft;
/* verilator lint_on COMBDLY */
  end

  //--------------------------------------------------------------------------
  // Output assignment
  //--------------------------------------------------------------------------
  assign clk_o = clk_i & clk_en_lat;

endmodule
