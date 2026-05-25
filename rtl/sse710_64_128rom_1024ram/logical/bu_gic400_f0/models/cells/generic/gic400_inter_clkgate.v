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
//      Checked In          : $Date: 2011-10-12 17:01:47 +0100 (Wed, 12 Oct 2011) $
//
//      Revision            : $Revision: 188475 $
//
//      Release Information : GIC-400-r0p1-00rel0
//
//------------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Abstract : Intermediate clock gating cell model for GIC400
// -----------------------------------------------------------------------------

//
// Overview
// --------
// This block is used to instantiate the intermediate (or mid-level) clock gates
// used in the design.  These live between the architectural clock gate at the
// top of the tree and the local clock gates at the registers.
//
// A functional clock enable <clk_enable_i> is combined with a scanenable/global
// disable signal to provide the gating term. This is then latched prior to gating
// with the main clock.
//
// It is recommended that this logic is used only for simulation purposes.
// Implementations should substitute a clock gating cell from the target library.

module gic400_inter_clkgate (
  input  wire clk_i,
  input  wire clk_enable_i,
  input  wire clk_senable_i,
  output wire clk_gated_o
);

  wire clk_en;
  reg  clk_en_reg;

  assign clk_en = clk_enable_i | clk_senable_i;

  always @(clk_i or clk_en) 
    begin
      if (clk_i == 1'b0)
        clk_en_reg <= clk_en;
    end

  assign clk_gated_o = clk_i & clk_en_reg;

endmodule // gic400_inter_clkgate
