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
// Abstract : Class decoder
//-----------------------------------------------------------------------------

module ca53ifu_pf_dec_d1 (
  // Inputs
  input wire [39:0] instr_if3_i,
  input wire [1:0]  cpsr_state_i,
  // Output
  output wire       instr_is_d1_o);


  wire              dual_issue_slot_1;
  wire              a32_only;
  wire              a64_only;
  wire              agu_can_shift;


  assign a32_only = instr_if3_i[19] & (cpsr_state_i == 2'b00);
  assign a64_only = instr_if3_i[19] & (cpsr_state_i == 2'b10);
  assign agu_can_shift = instr_if3_i[7] & instr_if3_i[31:29] == 3'b000 & instr_if3_i[26:25]== 2'b00;

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
         net_191, net_192, net_193, net_194, net_195, net_196, net_197,
         net_198, net_199, net_200, net_201, net_202, net_203, net_204,
         net_205, net_206, net_207, net_208, net_209, net_210, net_211,
         net_212, net_213, net_214, net_215, net_216, net_217, net_218,
         net_219, net_220, net_221, net_222, net_223, net_224, net_225,
         net_226, net_227, net_228, net_229, net_230, net_231, net_232,
         net_233, net_234;

  assign net_1 = ~net_94;
  assign net_2 = ~instr_if3_i[11];
  assign net_3 = ~net_66;
  assign net_4 = ~instr_if3_i[1];
  assign net_5 = ~instr_if3_i[29];
  assign net_6 = ~instr_if3_i[28];
  assign net_7 = ~instr_if3_i[24];
  assign net_8 = ~net_81;
  assign net_9 = ~instr_if3_i[18];
  assign net_10 = ~instr_if3_i[17];
  assign net_11 = ~instr_if3_i[16];
  assign net_12 = ~instr_if3_i[13];
  assign dual_issue_slot_1 = ~(net_13 & net_14);
  assign net_14 = (net_15 & net_16);
  assign net_16 = ~(instr_if3_i[7] & net_17);
  assign net_17 = ~(net_18 & net_19);
  assign net_19 = (net_20 & net_21);
  assign net_21 = ~(net_22 & net_23);
  assign net_23 = (agu_can_shift | instr_if3_i[24]);
  assign net_22 = ~(net_24 | net_25);
  assign net_20 = ~(net_26 & net_27);
  assign net_27 = (instr_if3_i[24] & instr_if3_i[31]);
  assign net_26 = ~(instr_if3_i[29] | net_28);
  assign net_28 = (net_29 & net_30);
  assign net_30 = (net_8 | net_31);
  assign net_31 = (net_32 & net_33);
  assign net_33 = ~(instr_if3_i[10] & instr_if3_i[3]);
  assign net_32 = ~(instr_if3_i[8] & instr_if3_i[4]);
  assign net_29 = (instr_if3_i[16] | net_34);
  assign net_18 = (net_35 & net_36);
  assign net_36 = ~(instr_if3_i[11] & net_37);
  assign net_37 = ~(instr_if3_i[26] | net_38);
  assign net_38 = (net_39 & net_40);
  assign net_40 = ~(instr_if3_i[24] & net_41);
  assign net_41 = ~(net_42 | instr_if3_i[27]);
  assign net_42 = (net_43 | instr_if3_i[4]);
  assign net_43 = (net_44 | instr_if3_i[3]);
  assign net_44 = (instr_if3_i[5] | net_24);
  assign net_24 = ~(net_12 & net_11);
  assign net_39 = (net_45 & net_46);
  assign net_46 = ~(net_4 & a64_only);
  assign net_45 = ~(net_47 & instr_if3_i[27]);
  assign net_47 = (net_48 & net_49);
  assign net_49 = (net_50 & instr_if3_i[1]);
  assign net_48 = (instr_if3_i[10] & instr_if3_i[30]);
  assign net_35 = (net_51 & net_52);
  assign net_52 = ~(net_53 & instr_if3_i[18]);
  assign net_53 = (instr_if3_i[12] & net_54);
  assign net_54 = ~(net_55 & net_56);
  assign net_56 = (net_10 | instr_if3_i[8]);
  assign net_55 = (instr_if3_i[24] | net_57);
  assign net_57 = ~(net_58 & net_59);
  assign net_59 = (net_50 & net_60);
  assign net_50 = ~(instr_if3_i[13] | net_61);
  assign net_61 = (instr_if3_i[0] | net_62);
  assign net_58 = ~(net_63 & net_64);
  assign net_64 = ~(net_65 & net_66);
  assign net_63 = ~(net_67 & instr_if3_i[1]);
  assign net_51 = ~(instr_if3_i[30] & net_68);
  assign net_68 = ~(net_69 & net_70);
  assign net_70 = (net_71 & net_72);
  assign net_72 = ~(net_73 & net_74);
  assign net_74 = ~(instr_if3_i[24] | net_75);
  assign net_75 = ~(instr_if3_i[29] & net_76);
  assign net_76 = (instr_if3_i[31] & instr_if3_i[12]);
  assign net_73 = ~(a64_only | net_77);
  assign net_77 = (net_78 | instr_if3_i[16]);
  assign net_78 = ~(instr_if3_i[11] & instr_if3_i[4]);
  assign net_71 = ~(net_79 & net_80);
  assign net_80 = (instr_if3_i[10] & net_81);
  assign net_69 = (instr_if3_i[16] | net_82);
  assign net_82 = ~(instr_if3_i[18] & net_83);
  assign net_83 = ~(instr_if3_i[27] | net_84);
  assign net_84 = ~(instr_if3_i[8] & net_85);
  assign net_85 = (instr_if3_i[0] & a64_only);
  assign net_15 = (net_86 & net_87);
  assign net_87 = ~(net_88 & instr_if3_i[18]);
  assign net_88 = ~(instr_if3_i[26] | net_89);
  assign net_89 = (net_90 | net_62);
  assign net_62 = ~(instr_if3_i[4] & instr_if3_i[5]);
  assign net_90 = (net_91 & net_92);
  assign net_92 = (instr_if3_i[31] | net_93);
  assign net_93 = ~(net_94 & net_95);
  assign net_95 = ~(instr_if3_i[1] | instr_if3_i[29]);
  assign net_91 = (a64_only | net_96);
  assign net_96 = (net_97 & net_98);
  assign net_98 = (instr_if3_i[24] | net_99);
  assign net_99 = (net_100 & net_101);
  assign net_101 = (net_102 & net_103);
  assign net_103 = (instr_if3_i[1] | net_104);
  assign net_104 = ~(instr_if3_i[11] & net_105);
  assign net_105 = (instr_if3_i[28] & instr_if3_i[30]);
  assign net_102 = (instr_if3_i[31] | net_106);
  assign net_106 = ~(instr_if3_i[0] & instr_if3_i[17]);
  assign net_100 = ~(net_12 & net_107);
  assign net_97 = (instr_if3_i[13] | net_108);
  assign net_108 = (net_109 & net_110);
  assign net_110 = ~(net_60 & net_67);
  assign net_67 = (net_6 & instr_if3_i[29]);
  assign net_60 = ~(instr_if3_i[30] | instr_if3_i[31]);
  assign net_109 = ~(instr_if3_i[30] & net_5);
  assign net_86 = (net_111 & net_112);
  assign net_112 = (net_113 & net_114);
  assign net_114 = (instr_if3_i[4] | net_115);
  assign net_115 = (net_116 & net_117);
  assign net_117 = ~(instr_if3_i[30] & net_118);
  assign net_118 = ~(instr_if3_i[5] | net_119);
  assign net_119 = ~(instr_if3_i[14] & net_120);
  assign net_120 = ~(net_8 | net_5);
  assign net_81 = ~(net_9 | net_10);
  assign net_116 = (net_121 & net_122);
  assign net_122 = ~(net_123 & a64_only);
  assign net_123 = (instr_if3_i[16] & net_124);
  assign net_124 = ~(instr_if3_i[24] & net_2);
  assign net_121 = (net_125 | instr_if3_i[14]);
  assign net_125 = (instr_if3_i[18] | net_126);
  assign net_113 = ~(instr_if3_i[17] & net_127);
  assign net_127 = ~(net_25 | net_126);
  assign net_126 = (instr_if3_i[11] | instr_if3_i[15]);
  assign net_25 = ~(a32_only & instr_if3_i[14]);
  assign net_111 = (net_128 & net_129);
  assign net_129 = (net_130 | instr_if3_i[16]);
  assign net_130 = (net_131 & net_132);
  assign net_132 = (net_133 | instr_if3_i[26]);
  assign net_133 = (net_134 & net_135);
  assign net_135 = (net_136 | instr_if3_i[7]);
  assign net_136 = ~(instr_if3_i[9] & net_137);
  assign net_137 = ~(instr_if3_i[24] | net_1);
  assign net_134 = (net_138 & net_139);
  assign net_139 = (instr_if3_i[14] | net_140);
  assign net_140 = (net_141 & net_142);
  assign net_142 = ~(instr_if3_i[15] & net_10);
  assign net_141 = ~(net_143 & instr_if3_i[8]);
  assign net_143 = ~(instr_if3_i[29] | net_144);
  assign net_144 = ~(a64_only & instr_if3_i[28]);
  assign net_138 = ~(instr_if3_i[24] & net_145);
  assign net_145 = (net_65 & net_146);
  assign net_146 = ~(net_147 | instr_if3_i[13]);
  assign net_147 = ~(instr_if3_i[10] & net_148);
  assign net_148 = (instr_if3_i[31] & instr_if3_i[17]);
  assign net_131 = (net_149 & net_150);
  assign net_150 = (instr_if3_i[15] | net_151);
  assign net_151 = (net_152 & net_153);
  assign net_153 = ~(net_10 & net_12);
  assign net_152 = (net_154 & net_155);
  assign net_155 = (net_156 | instr_if3_i[8]);
  assign net_156 = (instr_if3_i[12] | net_34);
  assign net_34 = (instr_if3_i[4] | net_157);
  assign net_157 = ~(instr_if3_i[5] & instr_if3_i[11]);
  assign net_154 = (net_158 & net_159);
  assign net_159 = (net_1 | net_12);
  assign net_158 = ~(instr_if3_i[12] & net_9);
  assign net_149 = ~(a64_only & net_160);
  assign net_160 = ~(instr_if3_i[7] | instr_if3_i[8]);
  assign net_128 = ~(net_161 & instr_if3_i[17]);
  assign net_161 = (instr_if3_i[9] & net_162);
  assign net_162 = ~(net_163 & net_164);
  assign net_164 = ~(net_79 & net_165);
  assign net_165 = ~(net_166 & net_167);
  assign net_167 = (instr_if3_i[16] | net_168);
  assign net_168 = (net_169 & net_170);
  assign net_170 = ~(instr_if3_i[11] & net_171);
  assign net_171 = ~(instr_if3_i[29] & net_172);
  assign net_172 = (instr_if3_i[28] | instr_if3_i[31]);
  assign net_169 = (instr_if3_i[7] | instr_if3_i[30]);
  assign net_166 = ~(instr_if3_i[30] & net_173);
  assign net_173 = ~(a64_only | instr_if3_i[28]);
  assign net_79 = ~(instr_if3_i[26] | net_7);
  assign net_163 = (instr_if3_i[8] | net_174);
  assign net_174 = (net_175 & net_176);
  assign net_176 = (net_177 & net_178);
  assign net_178 = (a64_only | net_179);
  assign net_179 = ~(instr_if3_i[24] | net_180);
  assign net_180 = ~(instr_if3_i[16] | net_181);
  assign net_181 = ~(instr_if3_i[26] & net_182);
  assign net_182 = (net_3 | instr_if3_i[2]);
  assign net_66 = (instr_if3_i[27] & net_4);
  assign net_177 = (instr_if3_i[16] | net_183);
  assign net_183 = (instr_if3_i[7] | instr_if3_i[12]);
  assign net_175 = ~(net_184 & instr_if3_i[7]);
  assign net_184 = (net_185 & net_186);
  assign net_186 = ~(instr_if3_i[5] & instr_if3_i[0]);
  assign net_185 = (instr_if3_i[4] & instr_if3_i[11]);
  assign net_13 = (net_187 & net_188);
  assign net_188 = ~(instr_if3_i[13] & net_189);
  assign net_189 = ~(net_190 & net_191);
  assign net_191 = (net_192 | instr_if3_i[14]);
  assign net_192 = (net_193 & net_194);
  assign net_194 = ~(net_195 & net_196);
  assign net_196 = (net_197 | instr_if3_i[17]);
  assign net_197 = ~(instr_if3_i[18] | instr_if3_i[27]);
  assign net_195 = (instr_if3_i[18] | net_198);
  assign net_198 = (instr_if3_i[16] & instr_if3_i[15]);
  assign net_193 = (net_199 | instr_if3_i[17]);
  assign net_199 = (instr_if3_i[12] | instr_if3_i[18]);
  assign net_190 = (net_200 & net_201);
  assign net_201 = ~(instr_if3_i[15] & net_202);
  assign net_202 = (instr_if3_i[9] & net_203);
  assign net_203 = ~(instr_if3_i[7] & net_204);
  assign net_204 = (instr_if3_i[8] | instr_if3_i[5]);
  assign net_200 = (net_205 & net_206);
  assign net_206 = (net_207 | a32_only);
  assign net_207 = ~(instr_if3_i[33] & net_208);
  assign net_208 = (net_2 & net_65);
  assign net_65 = ~(net_6 | a64_only);
  assign net_205 = (net_209 | instr_if3_i[15]);
  assign net_209 = ~(instr_if3_i[14] & net_210);
  assign net_210 = (instr_if3_i[16] & instr_if3_i[12]);
  assign net_187 = (net_211 | instr_if3_i[13]);
  assign net_211 = (net_212 & net_213);
  assign net_213 = (instr_if3_i[9] | net_214);
  assign net_214 = (net_215 & net_216);
  assign net_216 = (net_217 | instr_if3_i[18]);
  assign net_217 = ~(instr_if3_i[6] & net_218);
  assign net_218 = ~(a32_only | net_1);
  assign net_215 = ~(instr_if3_i[18] & net_107);
  assign net_107 = ~(instr_if3_i[12] | instr_if3_i[14]);
  assign net_212 = ~(instr_if3_i[14] & net_219);
  assign net_219 = ~(net_220 & net_221);
  assign net_221 = ~(net_222 & instr_if3_i[4]);
  assign net_222 = ~(a64_only | net_223);
  assign net_223 = (net_1 | instr_if3_i[5]);
  assign net_94 = (instr_if3_i[8] & instr_if3_i[11]);
  assign net_220 = ~(instr_if3_i[15] & net_224);
  assign net_224 = ~(net_225 & net_226);
  assign net_226 = ~(net_2 & instr_if3_i[16]);
  assign net_225 = (net_227 & net_228);
  assign net_228 = (instr_if3_i[18] | net_229);
  assign net_229 = (net_230 & net_231);
  assign net_231 = (instr_if3_i[35] | net_11);
  assign net_230 = (instr_if3_i[8] & net_232);
  assign net_232 = (net_233 | instr_if3_i[17]);
  assign net_233 = (instr_if3_i[34] & instr_if3_i[33]);
  assign net_227 = (net_234 | instr_if3_i[32]);
  assign net_234 = (a32_only | instr_if3_i[10]);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  assign instr_is_d1_o = dual_issue_slot_1;

endmodule
