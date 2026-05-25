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

module cxstm500_clk_module (
  // Inputs
  input  wire  CLK,            // free running clock
  input  wire  apb_clk_req_i,  // clock request from APB interface
  input  wire  stm_clk_req_i,  // clock requets on STM enabled
  input  wire  DFTCLKCGEN,     // Test mode

  // Outputs
  output wire  clk_gated       // gated clock
);

  //----------------------------------------------------------------------------
  // Wires
  //----------------------------------------------------------------------------
  wire  clk_gate_enable;
  wire  clk_gate_enable_dft;

  // CLK enable
  assign clk_gate_enable = apb_clk_req_i | stm_clk_req_i;

  // DFT controls
  assign clk_gate_enable_dft = clk_gate_enable | DFTCLKCGEN;

  // CLK gate
  cxstm500_clk_gate u_cxstm500_clk_gate (
    .CLK          (CLK),
    .clk_enable_i (clk_gate_enable_dft),
    .clk_o        (clk_gated)
  );

endmodule
