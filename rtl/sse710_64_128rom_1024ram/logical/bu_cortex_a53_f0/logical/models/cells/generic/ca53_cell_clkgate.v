//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2007-06-18 17:23:11 +0100 (Mon, 18 Jun 2007) $
//
//      Revision            : $Revision: 58766 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//------------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Abstract : Clock gating cell model for CORTEXA53
// -----------------------------------------------------------------------------

//
// Overview
// --------
// This block is used to abstract the
// high level clock gating function used for the primary
// clocks in the macrocell.
//
// A functional clock enable <clk_enable_i> is combined with
// a scanenable/global disable signal to provide the gating term.
// This is then latched prior to gating with the main clock.
//

`include "cortexa53params.v"

module ca53_cell_clkgate (
  input  wire clk_i,
  input  wire clk_enable_i,
  input  wire clk_senable_i,
  output wire clk_gated_o
);

  wire clk_en;
  reg  clk_en_reg /*verilator clock_enable*/;

  assign clk_en = clk_enable_i | clk_senable_i;

  always @(clk_i or clk_en) 
    begin
      if (clk_i == 1'b0)
        clk_en_reg <= clk_en;
    end

  assign clk_gated_o = clk_i & clk_en_reg;

endmodule // ca53_cell_clkgate

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
