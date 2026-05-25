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
//      Checked In          : $Date: 2012-10-14 11:32:27 +0100 (Sun, 14 Oct 2012) $
//
//      Revision            : $Revision: 225335 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : IT undef decoder
//-----------------------------------------------------------------------------

module ca53ifu_pf_it_undef (
  // Inputs
  input wire [39:0] pfb_instr_i,
  input wire        in_it_i,
  input wire        last_in_it_i,
  // Output
  output wire       undef_in_it_o);


  // ------------------------------------------------------
  // Start automatically generated logic
  // ------------------------------------------------------

  wire   net_1, net_3, net_4, net_5, net_6, net_7, net_8, net_9, net_10,
         net_11, net_12, net_13, net_14, net_15, net_16, net_17, net_18,
         net_19, net_22, net_25, net_26, net_27, net_28, net_29, net_30,
         net_31, net_32, net_33, net_34, net_35, net_36, net_37, net_38,
         net_39, net_40, net_41, net_42, net_43, net_44, net_45, net_46,
         net_47, net_48, net_49, net_50, net_51, net_52, net_53, net_54,
         net_55, net_56, net_57, net_58, net_59, net_60, net_61, net_62,
         net_63, net_64, net_65, net_66, net_67, net_68, net_69, net_70,
         net_71, net_72, net_73, net_74, net_75, net_76, net_77, net_78,
         net_79, net_80, net_81, net_82, net_83;

  assign net_1 = ~pfb_instr_i[37];
  assign undef_in_it_o = (in_it_i & net_3);
  assign net_3 = (net_4 | net_5);
  assign net_5 = (net_6 | net_7);
  assign net_7 = (net_8 | net_9);
  assign net_9 = ~(pfb_instr_i[4] | net_10);
  assign net_10 = (pfb_instr_i[28] | net_11);
  assign net_11 = ~(net_12 & pfb_instr_i[39]);
  assign net_12 = (net_13 & net_14);
  assign net_14 = (pfb_instr_i[32] & pfb_instr_i[30]);
  assign net_13 = (pfb_instr_i[31] & pfb_instr_i[29]);
  assign net_8 = (net_15 & net_16);
  assign net_16 = ~(pfb_instr_i[39] | net_17);
  assign net_17 = (pfb_instr_i[28] | net_18);
  assign net_18 = ~(pfb_instr_i[27] & pfb_instr_i[34]);
  assign net_15 = ~(pfb_instr_i[31] | net_19);
  assign net_6 = ~(net_26 & net_27);
  assign net_27 = ~(net_28 & net_29);
  assign net_29 = (net_30 | net_31);
  assign net_31 = ~(last_in_it_i | net_32);
  assign net_32 = (net_33 & net_34);
  assign net_34 = (net_35 | pfb_instr_i[36]);
  assign net_33 = (net_36 & pfb_instr_i[39]);
  assign net_36 = (pfb_instr_i[34] | net_37);
  assign net_37 = ~(pfb_instr_i[36] & net_38);
  assign net_38 = ~(pfb_instr_i[33] & net_39);
  assign net_39 = ~(net_40 & net_41);
  assign net_41 = ~(pfb_instr_i[28] ^ pfb_instr_i[27]);
  assign net_40 = ~(net_42 | net_22);
  assign net_22 = (pfb_instr_i[32] | pfb_instr_i[35]);
  assign net_28 = ~(pfb_instr_i[38] | net_1);
  assign net_26 = ~(net_30 & net_43);
  assign net_43 = (pfb_instr_i[29] & net_44);
  assign net_44 = ~(pfb_instr_i[31] | pfb_instr_i[37]);
  assign net_30 = (pfb_instr_i[32] & net_45);
  assign net_45 = ~(pfb_instr_i[36] | pfb_instr_i[39]);
  assign net_4 = (pfb_instr_i[38] & net_46);
  assign net_46 = ~(net_47 | pfb_instr_i[37]);
  assign net_47 = (net_48 & net_49);
  assign net_49 = (net_50 | last_in_it_i);
  assign net_50 = (pfb_instr_i[34] | net_51);
  assign net_51 = ~(pfb_instr_i[39] & net_52);
  assign net_52 = (pfb_instr_i[36] & pfb_instr_i[33]);
  assign net_48 = (pfb_instr_i[36] | net_53);
  assign net_53 = (net_54 & net_55);
  assign net_55 = ~(pfb_instr_i[32] & net_56);
  assign net_56 = (net_57 & net_58);
  assign net_58 = (net_25 | net_59);
  assign net_59 = ~(net_60 | pfb_instr_i[14]);
  assign net_60 = (net_61 | pfb_instr_i[12]);
  assign net_61 = (pfb_instr_i[33] & net_62);
  assign net_62 = ~(pfb_instr_i[29] & net_63);
  assign net_63 = (net_64 & net_65);
  assign net_65 = (pfb_instr_i[28] & pfb_instr_i[27]);
  assign net_64 = (pfb_instr_i[25] & net_66);
  assign net_66 = ~(net_67 & net_68);
  assign net_68 = (net_69 | pfb_instr_i[13]);
  assign net_69 = ~(net_70 & pfb_instr_i[30]);
  assign net_70 = (pfb_instr_i[26] & net_71);
  assign net_71 = ~(pfb_instr_i[24] & last_in_it_i);
  assign net_67 = (net_72 | pfb_instr_i[24]);
  assign net_72 = (net_73 | net_42);
  assign net_42 = (pfb_instr_i[30] | pfb_instr_i[26]);
  assign net_73 = ~(pfb_instr_i[8] | net_74);
  assign net_74 = (pfb_instr_i[9] | pfb_instr_i[10]);
  assign net_25 = ~(last_in_it_i | pfb_instr_i[33]);
  assign net_57 = ~(pfb_instr_i[34] | net_75);
  assign net_75 = ~(pfb_instr_i[15] & net_76);
  assign net_76 = ~(pfb_instr_i[31] | pfb_instr_i[35]);
  assign net_54 = (net_77 & pfb_instr_i[39]);
  assign net_77 = (net_35 | net_78);
  assign net_78 = (last_in_it_i | net_79);
  assign net_79 = ~(pfb_instr_i[34] & pfb_instr_i[26]);
  assign net_35 = ~(pfb_instr_i[33] & pfb_instr_i[35]);
  assign net_80 = (pfb_instr_i[21] & pfb_instr_i[22]);
  assign net_81 = (net_25 & pfb_instr_i[20]);
  assign net_82 = ~(net_80 & net_81);
  assign net_83 = ~(net_22 | net_82);
  assign net_19 = ~(pfb_instr_i[30] & net_83);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

endmodule

/*ARMAUTO_UNDEF*/
/*END*/
