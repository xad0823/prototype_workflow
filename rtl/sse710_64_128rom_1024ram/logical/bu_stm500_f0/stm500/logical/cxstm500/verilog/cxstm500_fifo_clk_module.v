//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2009-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Revision            : $Revision: 38583 $
//
//      Release Information : CoreSight STM-500 Global Bundle-r0p1-00rel0
//-----------------------------------------------------------------------------
//      Purpose:
//      CXSTM500 clock generation
//-----------------------------------------------------------------------------

module cxstm500_fifo_clk_module (
  // Inputs
  input  wire  clk_gated,      // STM gated clock
  input  wire  fifo_empty_i,   // fifo empty flag
  input  wire  data_valid_i,   // new transaction at entry to FIFOs
  input  wire  DFTCLKCGEN,     // DFT Clock Gate enable

  // Outputs
  output wire  fifo_clk_gated       // gated clock
);

  //----------------------------------------------------------------------------
  // Wires
  //----------------------------------------------------------------------------
  wire  clk_gate_enable;
  wire  clk_gate_enable_dft;

  // CLK enable
  assign clk_gate_enable = ~fifo_empty_i | data_valid_i;

  // DFT controls
  assign clk_gate_enable_dft = clk_gate_enable | DFTCLKCGEN;

  // CLK gate
  cxstm500_fifo_clk_gate u_cxstm500_fifo_clk_gate (
    .CLK          (clk_gated),
    .clk_enable_i (clk_gate_enable_dft),
    .clk_o        (fifo_clk_gated)
  );

endmodule
