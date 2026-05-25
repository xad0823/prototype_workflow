//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2015 ARM Limited.
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
// Abstract : Branch decoder based on sideband bits for 32-bit instructions
//-----------------------------------------------------------------------------

module ca53ifu_pf_dec_branch_s32 (
  // Inputs
  input  wire [38:33] pfb_instr_i,

  // Outputs
  output wire         s32_branch_o,
  output wire         s32_br_direct_o,
  output wire         s32_br_btac_o,
  output wire         s32_br_return_o,
  output wire         s32_dual_slot0_o
);


  // ------------------------------------------------------
  // Start automatically generated logic
  // ------------------------------------------------------

  wire   net_1, net_2, net_3, net_4, net_5, net_6, net_7, net_8, net_9, net_10,
         net_11, net_12, net_13, net_14, net_15, net_16, net_17, net_18,
         net_19, net_20, net_21, net_22, net_23, net_24, net_25, net_26,
         net_27, net_28, net_29, net_30, net_31, net_32, net_33, net_34,
         net_35, net_36, net_37, net_38, net_39, net_40, net_41, net_42,
         net_43, net_44, net_45, net_46, net_47, net_48, net_49, net_50,
         net_51, net_52, net_53, net_54, net_55, net_56, net_57;

  assign net_1 = ~net_47;
  assign net_2 = ~pfb_instr_i[38];
  assign net_3 = ~pfb_instr_i[36];
  assign net_4 = ~pfb_instr_i[34];
  assign net_5 = ~pfb_instr_i[33];
  assign s32_dual_slot0_o = ~(net_6 & net_7);
  assign net_7 = (net_8 | pfb_instr_i[35]);
  assign net_8 = (net_9 & net_10);
  assign net_10 = (net_11 | pfb_instr_i[37]);
  assign net_11 = ~(net_12 & net_13);
  assign net_13 = (net_2 ^ pfb_instr_i[34]);
  assign net_12 = (pfb_instr_i[36] & net_14);
  assign net_14 = ~(net_2 & pfb_instr_i[33]);
  assign net_9 = (net_15 & net_16);
  assign net_16 = (net_17 | net_18);
  assign net_18 = (net_2 ^ pfb_instr_i[33]);
  assign net_15 = ~(net_19 & net_20);
  assign net_20 = (pfb_instr_i[37] | net_21);
  assign net_19 = ~(pfb_instr_i[36] & net_22);
  assign net_22 = ~(net_23 & pfb_instr_i[37]);
  assign net_6 = ~(net_24 | net_25);
  assign net_25 = ~(net_26 | net_27);
  assign net_27 = ~(net_21 | net_23);
  assign net_23 = ~(net_2 | pfb_instr_i[34]);
  assign net_26 = ~(pfb_instr_i[37] & net_3);
  assign net_24 = ~(pfb_instr_i[38] | net_28);
  assign net_28 = ~(pfb_instr_i[35] & net_29);
  assign net_29 = (net_30 | net_21);
  assign net_21 = (net_5 & pfb_instr_i[34]);
  assign net_30 = ~(net_31 & net_32);
  assign net_32 = ~(pfb_instr_i[33] & net_17);
  assign net_17 = ~(net_3 | pfb_instr_i[34]);
  assign net_31 = (pfb_instr_i[37] | pfb_instr_i[36]);
  assign s32_branch_o = ~(net_33 & net_34);
  assign net_33 = ~(net_35 | net_36);
  assign net_36 = (net_1 & net_37);
  assign net_37 = (net_38 | net_39);
  assign net_38 = (pfb_instr_i[34] & net_40);
  assign s32_br_return_o = (net_41 & net_42);
  assign net_42 = (net_43 | net_44);
  assign net_44 = (pfb_instr_i[34] & net_45);
  assign net_43 = (net_46 & net_1);
  assign s32_br_direct_o = (net_48 & net_49);
  assign net_49 = (net_50 | net_39);
  assign net_39 = (net_46 & net_3);
  assign net_46 = (net_4 & net_5);
  assign net_50 = ~(net_4 | net_3);
  assign net_48 = ~(net_47 | pfb_instr_i[35]);
  assign s32_br_btac_o = ~(net_34 & net_51);
  assign net_51 = ~(net_35 & net_4);
  assign net_35 = (net_41 & net_45);
  assign net_45 = (pfb_instr_i[33] & net_52);
  assign net_41 = (pfb_instr_i[35] & net_3);
  assign net_34 = ~(net_4 & net_53);
  assign net_53 = ~(net_54 & net_55);
  assign net_55 = ~(net_56 & net_5);
  assign net_56 = (net_52 & net_40);
  assign net_40 = ~(pfb_instr_i[35] | net_3);
  assign net_52 = (pfb_instr_i[37] & net_2);
  assign net_54 = ~(pfb_instr_i[35] & net_57);
  assign net_57 = ~(net_5 | net_47);
  assign net_47 = (pfb_instr_i[37] | net_2);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

endmodule

