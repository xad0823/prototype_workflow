//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2007-2015 ARM Limited.
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

//-----------------------------------------------------------------------------
// Abstract : Create IQ return packets.  This module also creates Instr-0 and
// Instr-1 BTAC and return control signals.
//-----------------------------------------------------------------------------

`include "ca53ifu_defs.v"
`include "cortexa53params.v"

module ca53ifu_pf_iq_format_ret (
  // Inputs
  input wire [48:0]  crs_hit_addr_i,
  input wire [48:0]  btac_hit_addr_i,
  input wire [39:0]  instr0_i,
  input wire [39:0]  instr1_i,
  input wire [ 1:0]  instr_is_t16_i,
  input wire [ 1:0]  instr_valid_if3_i,
  input wire         instr_abt_if3_i,
  input wire         instr_vcr_if3_i,
  input wire         instr_hw_bkpt_if3_i,
  input wire         branch_never_taken_i,
  input wire         instr_is_a32_if3_i,
  input wire         instr_is_a64_if3_i,
  input wire         instr_is_thumb_if3_i,
  input wire         taken_i0_if3_i,
  input wire         taken_i1_if3_i,
  input wire [ 1:0]  it_block_i,
  input wire [ 3:1]  it_cc_0_i,
  input wire [ 3:1]  it_cc_1_i,
  input wire [ 1:0]  s32_btac_if3_i,
  input wire [ 1:0]  s32_return_if3_i,
  input wire [ 1:0]  t16_btac_if3_i,
  input wire [ 1:0]  t16_return_if3_i,
  input wire         return_hit_if4_i,
  input wire         aarch64_state_i,
  // Outputs
  output wire [ 1:0] spec_crs_btac_valid_o,
  output wire [48:0] iq_pred_addr_if4_o,
  output wire [ 1:0] brn_return_if3_o,
  output wire [ 1:0] brn_btac_if3_o
);


  // -----------------------------
  // Reg declarations
  // -----------------------------

  wire [48:0] call_ip;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire        instr0_a32_taken;
  wire        instr0_a64_taken;
  wire        instr0_thumb_taken;
  wire        instr0_spec_crs_btac_valid;
  wire        instr0_brn_btac_if3;
  wire        instr0_brn_return_if3;
  wire        instr0_spec_btac;
  wire        instr0_spec_return;
  wire        instr1_a32_taken;
  wire        instr1_a64_taken;
  wire        instr1_thumb_taken;
  wire        instr1_spec_crs_btac_valid;
  wire        instr1_brn_btac_if3;
  wire        instr1_brn_return_if3;
  wire        instr1_spec_btac;
  wire        instr1_spec_return;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  //----------------------------------------------------------------------------
  // Instr-0 control signals
  //----------------------------------------------------------------------------

  assign instr0_a32_taken   = (~branch_never_taken_i & instr_is_a32_if3_i &
                               ((instr0_i[39:37] == 3'b111) | taken_i0_if3_i));
  assign instr0_a64_taken   = ~branch_never_taken_i & instr_is_a64_if3_i &
                              (~instr0_i[19] | taken_i0_if3_i);
  assign instr0_thumb_taken = (~branch_never_taken_i & instr_is_thumb_if3_i &
                               ((it_block_i[0] & (it_cc_0_i[3:1] == 3'b111)) | ~it_block_i[0] | taken_i0_if3_i));


  //----------------------------------------------------------------------------
  // Instr-0 BTAC/Return branch decode
  //----------------------------------------------------------------------------

  // BTAC and Return control signals
  assign instr0_spec_btac   = s32_btac_if3_i[0]   & ~instr_is_t16_i[0];
  assign instr0_spec_return = s32_return_if3_i[0] & ~instr_is_t16_i[0];

  assign instr0_spec_crs_btac_valid = instr_valid_if3_i[0] & ~instr_abt_if3_i & ~instr_vcr_if3_i & ~instr_hw_bkpt_if3_i;

  assign instr0_brn_btac_if3   = (instr0_spec_crs_btac_valid &
                                  (instr0_a32_taken | instr0_a64_taken | instr0_thumb_taken) &
                                  (instr0_spec_btac | t16_btac_if3_i[0]));

  assign instr0_brn_return_if3 = (instr0_spec_crs_btac_valid &
                                  (instr0_a32_taken | instr0_a64_taken | instr0_thumb_taken) &
                                  (instr0_spec_return | t16_return_if3_i[0]));


  //----------------------------------------------------------------------------
  // Instr-1 control signals
  //----------------------------------------------------------------------------

  assign instr1_a32_taken   = (~branch_never_taken_i & instr_is_a32_if3_i &
                               ((instr1_i[39:37] == 3'b111) | taken_i1_if3_i));
  assign instr1_a64_taken   = ~branch_never_taken_i & instr_is_a64_if3_i &
                              (~instr1_i[19] | taken_i1_if3_i);
  assign instr1_thumb_taken = (~branch_never_taken_i & instr_is_thumb_if3_i &
                               ((it_block_i[1] & (it_cc_1_i[3:1] == 3'b111)) | ~it_block_i[1] | taken_i1_if3_i));


  //----------------------------------------------------------------------------
  // Instr-1 BTAC/Return branch decode
  //----------------------------------------------------------------------------

  // BTAC and Return control signals
  assign instr1_spec_btac   = s32_btac_if3_i[1]   & ~instr_is_t16_i[1];
  assign instr1_spec_return = s32_return_if3_i[1] & ~instr_is_t16_i[1];

  assign instr1_spec_crs_btac_valid = instr_valid_if3_i[1];

  assign instr1_brn_btac_if3   = (instr1_spec_crs_btac_valid &
                                  (instr1_a32_taken | instr1_a64_taken | instr1_thumb_taken) &
                                  (instr1_spec_btac | t16_btac_if3_i[1]));

  assign instr1_brn_return_if3 = (instr1_spec_crs_btac_valid &
                                  (instr1_a32_taken | instr1_a64_taken | instr1_thumb_taken) &
                                  (instr1_spec_return | t16_return_if3_i[1]));


  //----------------------------------------------------------------------------
  // Return pointer generation
  //----------------------------------------------------------------------------

  // Send the predicted return/indirect address to the DPU
  assign call_ip = return_hit_if4_i ? crs_hit_addr_i[48:0] : btac_hit_addr_i[48:0];


  //----------------------------------------------------------------------------
  // Outputs
  //----------------------------------------------------------------------------

  assign iq_pred_addr_if4_o    = { ({17{aarch64_state_i}} & call_ip[48:32]), call_ip[31:0] };
  assign spec_crs_btac_valid_o = {instr1_spec_crs_btac_valid, instr0_spec_crs_btac_valid};
  assign brn_return_if3_o      = {instr1_brn_return_if3,      instr0_brn_return_if3};
  assign brn_btac_if3_o        = {instr1_brn_btac_if3,        instr0_brn_btac_if3};

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53ifu_defs.v"
`undef CA53_UNDEFINE
/*END*/
