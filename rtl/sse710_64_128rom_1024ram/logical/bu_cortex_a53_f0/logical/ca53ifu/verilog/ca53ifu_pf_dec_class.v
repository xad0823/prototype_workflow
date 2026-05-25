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
// Abstract : Class decoder
//-----------------------------------------------------------------------------

`include "ca53ifu_defs.v"
`include "cortexa53params.v"

module ca53ifu_pf_dec_class (
  // Inputs
  input wire [39:0] instr_if3_i,
  input wire        instr_is_t16_if3_i,
  // Output
  output wire       instr_is_dp_o,
  output wire       instr_is_ls_o,
  output wire       instr_is_fn_o);

  wire [39:0] pfb_instr;
  wire        instr_is_dp;
  wire        instr_is_ls;
  wire        instr_is_fn;
  wire        t16_instr_is_dp;
  wire        t16_instr_is_ls;

  // Memory view -> ARM ARM view
  assign pfb_instr[39:0] = {instr_if3_i[19:0], instr_if3_i[39:20]};

  // ------------------------------------------------------
  // Start sideband decoder automatically generated logic
  // ------------------------------------------------------

  wire   net_0_1, net_0_2, net_0_3, net_0_4, net_0_5, net_0_6, net_0_7, net_0_8, net_0_9, net_0_10,
         net_0_11, net_0_12, net_0_13, net_0_14, net_0_15, net_0_16, net_0_17, net_0_18,
         net_0_19, net_0_20, net_0_21, net_0_22;

  assign net_0_1 = ~pfb_instr[38];
  assign net_0_2 = ~pfb_instr[33];
  assign instr_is_ls = ~(net_0_3 & net_0_4);
  assign net_0_4 = ~(pfb_instr[37] & net_0_1);
  assign net_0_3 = ~(net_0_5 & net_0_6);
  assign net_0_6 = (net_0_7 & net_0_8);
  assign net_0_8 = (pfb_instr[34] | net_0_9);
  assign net_0_9 = ~(net_0_2 | pfb_instr[37]);
  assign net_0_5 = (pfb_instr[34] ^ pfb_instr[38]);
  assign instr_is_fn = (pfb_instr[38] & net_0_10);
  assign net_0_10 = (net_0_11 | net_0_12);
  assign net_0_12 = ~(net_0_13 | pfb_instr[37]);
  assign net_0_13 = ~(pfb_instr[34] & net_0_7);
  assign net_0_7 = (pfb_instr[36] & pfb_instr[35]);
  assign net_0_11 = (pfb_instr[37] & net_0_14);
  assign net_0_14 = ~(pfb_instr[36] & net_0_15);
  assign net_0_15 = (pfb_instr[35] | net_0_16);
  assign net_0_16 = (pfb_instr[33] & pfb_instr[34]);
  assign instr_is_dp = (net_0_17 & net_0_18);
  assign net_0_18 = (net_0_19 | net_0_20);
  assign net_0_20 = ~(net_0_2 | pfb_instr[34]);
  assign net_0_19 = ~(net_0_21 & net_0_22);
  assign net_0_22 = ~(pfb_instr[34] ^ pfb_instr[36]);
  assign net_0_21 = ~(pfb_instr[35] ^ pfb_instr[34]);
  assign net_0_17 = ~(pfb_instr[37] | pfb_instr[38]);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Start T16 class decoder automatically generated logic
  // ------------------------------------------------------

  wire   net_1_1, net_1_2, net_1_3, net_1_4, net_1_5, net_1_6, net_1_7, net_1_8, net_1_9, net_1_10,
         net_1_11, net_1_12, net_1_13, net_1_14, net_1_15, net_1_16, net_1_17, net_1_18,
         net_1_19, net_1_20, net_1_21, net_1_22, net_1_23, net_1_24;

  assign net_1_1 = ~pfb_instr[26];
  assign t16_instr_is_ls = (net_1_2 | net_1_3);
  assign net_1_3 = ~(pfb_instr[35] | net_1_4);
  assign net_1_4 = ~(pfb_instr[34] & net_1_5);
  assign net_1_2 = (pfb_instr[35] & net_1_6);
  assign net_1_6 = ~(net_1_7 & net_1_8);
  assign net_1_7 = (net_1_9 | pfb_instr[34]);
  assign net_1_9 = (pfb_instr[33] & net_1_10);
  assign net_1_10 = (net_1_11 | pfb_instr[29]);
  assign net_1_11 = ~(pfb_instr[32] & pfb_instr[30]);
  assign t16_instr_is_dp = ~(net_1_12 & net_1_13);
  assign net_1_13 = (pfb_instr[34] | net_1_14);
  assign net_1_14 = (pfb_instr[35] & net_1_15);
  assign net_1_15 = ~(pfb_instr[33] & net_1_16);
  assign net_1_16 = ~(pfb_instr[32] & net_1_17);
  assign net_1_17 = (net_1_18 | pfb_instr[30]);
  assign net_1_18 = (pfb_instr[28] | net_1_19);
  assign net_1_19 = (pfb_instr[31] & net_1_20);
  assign net_1_20 = ~(pfb_instr[29] & net_1_21);
  assign net_1_21 = ~(pfb_instr[27] & net_1_1);
  assign net_1_12 = (pfb_instr[35] | net_1_22);
  assign net_1_22 = (net_1_23 | net_1_5);
  assign net_1_5 = (pfb_instr[31] | net_1_8);
  assign net_1_8 = (pfb_instr[33] | pfb_instr[32]);
  assign net_1_23 = (pfb_instr[30] & net_1_24);
  assign net_1_24 = (pfb_instr[28] & pfb_instr[29]);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  assign instr_is_dp_o = instr_is_t16_if3_i ? t16_instr_is_dp : instr_is_dp;
  assign instr_is_ls_o = instr_is_t16_if3_i ? t16_instr_is_ls : instr_is_ls;
  assign instr_is_fn_o = instr_is_t16_if3_i ? 1'b0            : instr_is_fn;  // T16 never FP

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53ifu_defs.v"
`undef CA53_UNDEFINE
/*END*/
