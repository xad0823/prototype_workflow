//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2013-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

module ca53cti_clkgate
 (
  input  clk,
  input  reset_n,

  input  DFTSE,

  input  glben_i,
  input  bus_act_early_i,
  input  ctitrigout_act_i,

  output cti_active_o,
  output clk_cti_o
);

  wire   clk_gate_en_nxt;
  reg    clk_gate_en_r;
  reg    en_hold_r;
  wire   en_hold_nxt;


//------------------------------------------------------------------
// Clock gate delayed enable term
//------------------------------------------------------------------
  assign en_hold_nxt  = glben_i | bus_act_early_i | ctitrigout_act_i;

  always @(posedge clk, negedge reset_n)
    if (~reset_n)
      en_hold_r <= 1'b0;
    else
      en_hold_r <= en_hold_nxt;



//------------------------------------------------------------------
// Clock gate enable term generation
//      The enable term also contains a delayed version of the
//      enables so that the clock is always active for at least 2
//      cycles, allowing changes to flush through the trigger
//      outputs.
//------------------------------------------------------------------
  assign clk_gate_en_nxt  = en_hold_r | glben_i | bus_act_early_i | ctitrigout_act_i;

  always @(posedge clk, negedge reset_n)
    if (~reset_n)
      clk_gate_en_r <= 1'b0;
    else
      clk_gate_en_r <= clk_gate_en_nxt;

  assign cti_active_o = clk_gate_en_r;

//------------------------------------------------------------------
// Clock gate
//------------------------------------------------------------------
  ca53_cell_inter_clkgate u_cti_clkgate_cell
    (
     .clk_i        (clk),
     .clk_enable_i (clk_gate_en_r),
     .clk_senable_i(DFTSE),
     .clk_gated_o  (clk_cti_o)
     );

endmodule // ca53cti_clkgate
