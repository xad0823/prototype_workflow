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
// Abstract : Predecode checker
//-----------------------------------------------------------------------------
//
// The predecode checker determines if the opcode that spans a cache line boundary
// can be trusted.  It checks a subset of the possible instructions since this decoder
// will be toggling all of the time.  If the instruction does not fall into this
// subset, can not be trusted and the instruction is marked as 'incomplete' then the
// instruction must be put back through the process.
//
// Since only the lower 16-bits can be altered, the check only needs to be performed
// on these bits.

`include "ca53ifu_defs.v"
`include "cortexa53params.v"

module ca53ifu_pf_pdc_checker (
  // Inputs
  input wire [34:0] instr_pdc_i,
  // Output
  output wire       instr_pdc_pass_o);

  // -----------------------------
  // Wire declarations
  // -----------------------------
  wire        not_base_eq_src1;
  wire        not_base_eq_src2;
  wire        not_src1_eq_src2;
  wire        not_r15_19to16;
  wire        not_r15_15to12;
  wire        not_r15_11to8;
  wire        not_r15_3to0;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // Create common decode signals
  assign not_base_eq_src1 = instr_pdc_i[19:16] != instr_pdc_i[15:12];
  assign not_base_eq_src2 = instr_pdc_i[19:16] != instr_pdc_i[11:8];
  assign not_src1_eq_src2 = instr_pdc_i[15:12] != instr_pdc_i[11:8];
  assign not_r15_19to16   = instr_pdc_i[19:16] != 4'b1111;
  assign not_r15_15to12   = instr_pdc_i[15:12] != 4'b1111;
  assign not_r15_11to8    = instr_pdc_i[11:8]  != 4'b1111;
  assign not_r15_3to0     = instr_pdc_i[3:0]   != 4'b1111;

  // ------------------------------------------------------
  // Start automatically generated logic
  // ------------------------------------------------------

  wire   net_1, net_2, net_3, net_4, net_5, net_6, net_7, net_8, net_9, net_10,
         net_11, net_12, net_13, net_14, net_15, net_16, net_17, net_18,
         net_19, net_20, net_21, net_22, net_23, net_24, net_25, net_26,
         net_27, net_28, net_29, net_30, net_31, net_32, net_33, net_34,
         net_35, net_36, net_37, net_38, net_39, net_40, net_41, net_42,
         net_43, net_44, net_45, net_46, net_47, net_48, net_49, net_50,
         net_51, net_52, net_53, net_54, net_55, net_56, net_57, net_58,
         net_59, net_60, net_61, net_62, net_63, net_64, net_65, net_66,
         net_67, net_68, net_69, net_70, net_71, net_72, net_73, net_74,
         net_75, net_76, net_77, net_78, net_79, net_80, net_81, net_82,
         net_83, net_84, net_85, net_86, net_87, net_88, net_89, net_90,
         net_91, net_92, net_93, net_94, net_95, net_96, net_97, net_98,
         net_99, net_100, net_101, net_102, net_103, net_104, net_105, net_106,
         net_107, net_108, net_109, net_110, net_111, net_112, net_113,
         net_114, net_115, net_116, net_117, net_118, net_119, net_120,
         net_121, net_122, net_123, net_124, net_125, net_126, net_127,
         net_128, net_129, net_130, net_131, net_132, net_133, net_134,
         net_135, net_136, net_137, net_138, net_139, net_140, net_141,
         net_142, net_143, net_144, net_145, net_146, net_147, net_148,
         net_149, net_150, net_151, net_152, net_153, net_154, net_155,
         net_156, net_157, net_158, net_159, net_160, net_161, net_162,
         net_163, net_164, net_165, net_166, net_167, net_168, net_169,
         net_170, net_171, net_172, net_173, net_174, net_175, net_176,
         net_177, net_178, net_179, net_180, net_181, net_182, net_183,
         net_184, net_185, net_186, net_187, net_188, net_189, net_190,
         net_191, net_192, net_193;

  assign net_1 = ~net_49;
  assign net_2 = ~instr_pdc_i[30];
  assign net_3 = ~instr_pdc_i[28];
  assign net_4 = ~instr_pdc_i[22];
  assign net_5 = ~net_63;
  assign net_6 = ~instr_pdc_i[21];
  assign instr_pdc_pass_o = ~(instr_pdc_i[34] | net_7);
  assign net_7 = (net_8 & net_9);
  assign net_9 = (instr_pdc_i[33] | net_10);
  assign net_10 = (net_11 & net_12);
  assign net_12 = ~(not_r15_11to8 & net_13);
  assign net_13 = ~(net_14 & net_15);
  assign net_15 = (net_16 | net_17);
  assign net_17 = (net_18 & net_19);
  assign net_19 = ~(net_20 & net_21);
  assign net_21 = ~(net_22 & net_23);
  assign net_23 = (instr_pdc_i[7] | net_24);
  assign net_24 = (net_25 & net_26);
  assign net_26 = ~(net_27 & net_28);
  assign net_28 = ~(net_29 & net_30);
  assign net_30 = (instr_pdc_i[31] | net_31);
  assign net_31 = ~(net_32 & net_33);
  assign net_33 = (net_34 & instr_pdc_i[29]);
  assign net_29 = ~(net_35 & net_36);
  assign net_36 = (instr_pdc_i[22] ^ instr_pdc_i[31]);
  assign net_35 = (net_37 & net_38);
  assign net_38 = ~(instr_pdc_i[20] | net_39);
  assign net_39 = ~(not_src1_eq_src2 & net_40);
  assign net_40 = (not_r15_15to12 & net_41);
  assign net_41 = (instr_pdc_i[24] & instr_pdc_i[23]);
  assign net_27 = ~(instr_pdc_i[5] | instr_pdc_i[4]);
  assign net_25 = (net_42 | net_43);
  assign net_43 = ~(net_44 & net_45);
  assign net_45 = ~(net_46 & net_47);
  assign net_47 = (net_48 | net_49);
  assign net_48 = (not_r15_15to12 | net_50);
  assign net_50 = (net_51 & net_52);
  assign net_52 = (instr_pdc_i[5] | net_53);
  assign net_53 = (net_54 & net_55);
  assign net_55 = (instr_pdc_i[4] | net_56);
  assign net_56 = ~(instr_pdc_i[20] | net_6);
  assign net_54 = ~(instr_pdc_i[22] ^ instr_pdc_i[21]);
  assign net_46 = ~(net_57 & not_r15_15to12);
  assign net_57 = ~(net_58 | net_59);
  assign net_59 = (net_51 & net_60);
  assign net_60 = (instr_pdc_i[5] | net_61);
  assign net_61 = (instr_pdc_i[20] & net_62);
  assign net_62 = (instr_pdc_i[4] & net_63);
  assign net_51 = (instr_pdc_i[21] | net_64);
  assign net_44 = (instr_pdc_i[31] & instr_pdc_i[24]);
  assign net_22 = ~(instr_pdc_i[31] & net_65);
  assign net_65 = (net_66 & instr_pdc_i[7]);
  assign net_66 = (net_32 & net_67);
  assign net_67 = ~(net_68 & net_69);
  assign net_69 = (net_70 | instr_pdc_i[29]);
  assign net_70 = ~(net_34 & net_5);
  assign net_68 = ~(net_37 & net_71);
  assign net_71 = ~(instr_pdc_i[21] & net_72);
  assign net_72 = (net_73 | instr_pdc_i[22]);
  assign net_73 = ~(instr_pdc_i[20] | net_74);
  assign net_74 = (net_75 & net_76);
  assign net_76 = (instr_pdc_i[13] & instr_pdc_i[12]);
  assign net_75 = (instr_pdc_i[14] & instr_pdc_i[15]);
  assign net_32 = ~(instr_pdc_i[24] | net_77);
  assign net_77 = (instr_pdc_i[23] | not_r15_15to12);
  assign net_18 = (instr_pdc_i[15] | net_78);
  assign net_78 = ~(net_79 & net_37);
  assign net_79 = ~(net_80 | net_81);
  assign net_14 = ~(net_82 & net_83);
  assign net_83 = ~(net_84 & net_85);
  assign net_85 = (instr_pdc_i[31] | net_86);
  assign net_86 = (net_87 & net_88);
  assign net_88 = ~(instr_pdc_i[30] & net_89);
  assign net_89 = (net_1 & net_90);
  assign net_90 = ~(net_91 & net_92);
  assign net_92 = (instr_pdc_i[22] | net_93);
  assign net_93 = ~(net_94 & net_95);
  assign net_95 = (net_96 & net_97);
  assign net_97 = (instr_pdc_i[25] | net_6);
  assign net_94 = (net_6 ^ instr_pdc_i[23]);
  assign net_91 = (instr_pdc_i[25] | net_81);
  assign net_81 = (net_98 & net_99);
  assign net_99 = ~(net_6 & net_100);
  assign net_100 = ~(instr_pdc_i[22] ^ instr_pdc_i[24]);
  assign net_98 = ~(instr_pdc_i[23] ^ net_101);
  assign net_101 = ~(instr_pdc_i[24] & net_102);
  assign net_102 = ~(net_6 | instr_pdc_i[22]);
  assign net_87 = (net_103 & net_104);
  assign net_104 = (net_105 | net_42);
  assign net_42 = (instr_pdc_i[30] | instr_pdc_i[23]);
  assign net_105 = ~(net_106 & net_107);
  assign net_107 = ~(net_108 | instr_pdc_i[32]);
  assign net_108 = (net_109 | instr_pdc_i[24]);
  assign net_109 = ~(instr_pdc_i[22] & instr_pdc_i[29]);
  assign net_106 = ~(instr_pdc_i[25] & net_110);
  assign net_110 = (instr_pdc_i[20] | instr_pdc_i[21]);
  assign net_103 = (net_111 | net_112);
  assign net_111 = (net_113 | instr_pdc_i[20]);
  assign net_113 = ~(instr_pdc_i[25] & net_114);
  assign net_114 = ~(net_115 | instr_pdc_i[29]);
  assign net_115 = ~(net_116 & net_117);
  assign net_117 = (net_118 & net_119);
  assign net_119 = (instr_pdc_i[30] ^ instr_pdc_i[32]);
  assign net_118 = ~(net_2 & instr_pdc_i[23]);
  assign net_116 = (instr_pdc_i[30] ^ net_63);
  assign net_84 = ~(net_120 & net_121);
  assign net_121 = (net_34 & net_122);
  assign net_122 = ~(net_123 | instr_pdc_i[20]);
  assign net_123 = ~(instr_pdc_i[31] & net_124);
  assign net_124 = (instr_pdc_i[29] & instr_pdc_i[25]);
  assign net_34 = ~(instr_pdc_i[32] | net_2);
  assign net_120 = (instr_pdc_i[22] & net_125);
  assign net_125 = ~(net_126 & net_127);
  assign net_127 = ~(net_128 & instr_pdc_i[21]);
  assign net_128 = ~(instr_pdc_i[23] | net_112);
  assign net_112 = ~(instr_pdc_i[24] & net_129);
  assign net_129 = ~(instr_pdc_i[5] | instr_pdc_i[26]);
  assign net_126 = ~(net_130 & instr_pdc_i[23]);
  assign net_82 = (instr_pdc_i[28] & net_131);
  assign net_131 = ~(instr_pdc_i[27] | instr_pdc_i[15]);
  assign net_11 = (net_132 | instr_pdc_i[15]);
  assign net_132 = ~(net_133 & net_134);
  assign net_134 = (net_135 & net_136);
  assign net_136 = ~(net_64 | net_49);
  assign net_64 = ~(instr_pdc_i[20] & net_4);
  assign net_135 = (instr_pdc_i[21] ^ net_137);
  assign net_137 = ~(instr_pdc_i[23] & instr_pdc_i[24]);
  assign net_133 = ~(net_138 & net_139);
  assign net_139 = (instr_pdc_i[30] | net_140);
  assign net_140 = (net_16 | net_80);
  assign net_80 = ~(net_3 & instr_pdc_i[31]);
  assign net_16 = (instr_pdc_i[26] | net_141);
  assign net_141 = ~(not_r15_3to0 & net_142);
  assign net_142 = (instr_pdc_i[27] & instr_pdc_i[25]);
  assign net_138 = (instr_pdc_i[25] | net_143);
  assign net_143 = (instr_pdc_i[27] | net_144);
  assign net_8 = (net_145 | instr_pdc_i[25]);
  assign net_145 = (instr_pdc_i[26] | net_146);
  assign net_146 = ~(net_147 & net_148);
  assign net_148 = (instr_pdc_i[33] & net_149);
  assign net_149 = (not_r15_15to12 & instr_pdc_i[27]);
  assign net_147 = ~(net_150 & net_151);
  assign net_151 = (net_152 | instr_pdc_i[11]);
  assign net_152 = (instr_pdc_i[9] | net_153);
  assign net_153 = ~(net_154 & net_155);
  assign net_155 = ~(net_156 | instr_pdc_i[23]);
  assign net_156 = ~(instr_pdc_i[31] & net_157);
  assign net_154 = ~(net_158 | instr_pdc_i[7]);
  assign net_158 = ~(net_159 & net_160);
  assign net_160 = (not_r15_3to0 & net_20);
  assign net_20 = ~(instr_pdc_i[6] | net_3);
  assign net_159 = ~(net_161 & net_162);
  assign net_162 = (net_163 | net_164);
  assign net_161 = ~(net_165 & instr_pdc_i[30]);
  assign net_165 = ~(instr_pdc_i[29] | net_166);
  assign net_166 = ~(net_96 & net_167);
  assign net_167 = (instr_pdc_i[32] & net_5);
  assign net_150 = (net_168 & net_169);
  assign net_169 = (net_144 | net_170);
  assign net_170 = (net_171 & net_172);
  assign net_172 = (net_58 | net_173);
  assign net_173 = ~(instr_pdc_i[20] & net_174);
  assign net_174 = ~(net_175 | net_163);
  assign net_163 = ~(net_4 | net_130);
  assign net_130 = ~(instr_pdc_i[24] | instr_pdc_i[21]);
  assign net_175 = ~(instr_pdc_i[23] | net_176);
  assign net_176 = ~(net_157 | net_177);
  assign net_177 = ~(instr_pdc_i[11] & not_base_eq_src1);
  assign net_157 = ~(instr_pdc_i[10] | instr_pdc_i[8]);
  assign net_171 = ~(net_178 & net_179);
  assign net_179 = (net_96 & instr_pdc_i[23]);
  assign net_96 = ~(instr_pdc_i[24] | instr_pdc_i[20]);
  assign net_178 = (net_1 & net_5);
  assign net_63 = (instr_pdc_i[21] & instr_pdc_i[22]);
  assign net_144 = (instr_pdc_i[31] | net_180);
  assign net_180 = ~(instr_pdc_i[30] & instr_pdc_i[28]);
  assign net_168 = ~(instr_pdc_i[22] & net_181);
  assign net_181 = ~(net_182 | instr_pdc_i[31]);
  assign net_182 = (net_183 | instr_pdc_i[28]);
  assign net_183 = ~(not_r15_11to8 & net_184);
  assign net_184 = (net_185 & net_186);
  assign net_186 = ~(net_187 & net_188);
  assign net_188 = ~(instr_pdc_i[24] & net_6);
  assign net_187 = ~(not_base_eq_src2 & net_189);
  assign net_189 = (not_base_eq_src1 & instr_pdc_i[21]);
  assign net_185 = ~(net_190 & net_191);
  assign net_191 = (net_192 | net_164);
  assign net_164 = ~(instr_pdc_i[20] & net_37);
  assign net_37 = ~(instr_pdc_i[30] | net_49);
  assign net_49 = ~(instr_pdc_i[32] & instr_pdc_i[29]);
  assign net_192 = ~(not_src1_eq_src2 & not_r15_19to16);
  assign net_190 = (net_193 | instr_pdc_i[20]);
  assign net_193 = (instr_pdc_i[30] | net_58);
  assign net_58 = (instr_pdc_i[32] | instr_pdc_i[29]);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------


endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53ifu_defs.v"
`undef CA53_UNDEFINE
/*END*/
