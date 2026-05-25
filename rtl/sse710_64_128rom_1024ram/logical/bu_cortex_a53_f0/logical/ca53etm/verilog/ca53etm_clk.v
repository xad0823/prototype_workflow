//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2012-09-01 17:59:30 +0100 (Sat, 01 Sep 2012) $
//
//      Revision            : $Revision: 220870 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Description:
// ETM clock gating block
//-----------------------------------------------------------------------------
//
`include "cortexa53params.v"

module ca53etm_clk (
  // Inputs
  input  wire                     clk,
  input  wire                     po_reset_n,
  input  wire                     DFTSE,
  input  wire                     gov_pseldbg_etm_i,
  input  wire                     gov_penabledbg_i,
  input  wire                     etm_if_en_i,
  input  wire                     trcstatr_idle_i,
  // Outputs
  output wire                     clk_gated_o,
  output wire                     clk_reg_req_o
);

  // -----------------------------
  // Wire declarations
  // -----------------------------
  reg                 clken_reg;
  reg                 gov_penabledbg_q;
  reg                 gov_pseldbg_etm_q;

  wire                clken;

  //-----------------------------------------------------------------------------
  //  Main code
  //-----------------------------------------------------------------------------

  // Gate ETM clock once trace is drained
  // Enable is registered by clock gate cell
  assign clken = etm_if_en_i | gov_pseldbg_etm_i | ~trcstatr_idle_i;

  always @(posedge clk or negedge po_reset_n)
    if(!po_reset_n) begin
      clken_reg         <= 1'b1;
      gov_penabledbg_q  <= 1'b0;
      gov_pseldbg_etm_q <= 1'b0;
    end
    else begin
      clken_reg         <= clken;
      gov_penabledbg_q  <= gov_penabledbg_i;
      gov_pseldbg_etm_q <= gov_pseldbg_etm_i;
    end

  assign clk_reg_req_o  = gov_pseldbg_etm_q & ~gov_penabledbg_q;

  ca53_cell_inter_clkgate u_clkgate (
    .clk_i         (clk),
    .clk_enable_i  (clken_reg),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_gated_o)
  );

  //----------------------------------------------------------------------------
  // Assertions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Clock enable unknown")
  u_ovl_clken_unknown
  (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (clken)
  );

`endif //  `ifdef ARM_ASSERT_ON
  
endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
