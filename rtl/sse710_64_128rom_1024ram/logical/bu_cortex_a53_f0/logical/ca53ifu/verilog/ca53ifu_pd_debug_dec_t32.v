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
//      Checked In          : $Date: 2012-01-11 11:42:53 +0000 (Wed, 11 Jan 2012) $
//
//      Revision            : $Revision: 197498 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53ifu_pd_debug_dec_t32
  (input  [28:0]  raw_encoding_i,
   input          fifth_bit_i,
   input          sf_bit_i,
   input          a64_state_i,
   output  [5:0]  sideband_o,
   output         undef_o
  );

  // The sideband output is formed by combining an encoder for defined
  // instructions into defined sideband values, and a separate undef decoder
  // which forces the output to be the undef sideband encoding on undefined
  // instructions.
  // This gives better synthesis results than having a single encoder to deal
  // with both defined and undefined instructions.

  wire        undef;
  wire [5:0]  defined_sideband;

  // Form output here, so that all the netlist logic is together and there is
  // no further logic after it.
  assign sideband_o = defined_sideband;
  assign undef_o    = undef;

  // ------------------------------------------------------
  // Undef instruction decoder
  // ------------------------------------------------------

  wire   net_0_1, net_0_2, net_0_3, net_0_4, net_0_5, net_0_6, net_0_7, net_0_8, net_0_9, net_0_10,
         net_0_11, net_0_12, net_0_14, net_0_16, net_0_17, net_0_19, net_0_20, net_0_21,
         net_0_22, net_0_23, net_0_24, net_0_25, net_0_26, net_0_27, net_0_28, net_0_29,
         net_0_30, net_0_31, net_0_32, net_0_33, net_0_34, net_0_35, net_0_36, net_0_37,
         net_0_38, net_0_39, net_0_40, net_0_41, net_0_42, net_0_43, net_0_44, net_0_45,
         net_0_46, net_0_47, net_0_48, net_0_49, net_0_50, net_0_51, net_0_52, net_0_53,
         net_0_54, net_0_55, net_0_56, net_0_57, net_0_58, net_0_59, net_0_60, net_0_61,
         net_0_62, net_0_63, net_0_64, net_0_65, net_0_66, net_0_67, net_0_68, net_0_69,
         net_0_70, net_0_71, net_0_72, net_0_73, net_0_74, net_0_75, net_0_76, net_0_77,
         net_0_78, net_0_79, net_0_80, net_0_81, net_0_82, net_0_83, net_0_84, net_0_85,
         net_0_86, net_0_87, net_0_88, net_0_89, net_0_90, net_0_91, net_0_92, net_0_93,
         net_0_94, net_0_95, net_0_96, net_0_97, net_0_98, net_0_99, net_0_100, net_0_101,
         net_0_102, net_0_103, net_0_104, net_0_105, net_0_106, net_0_107, net_0_108,
         net_0_114, net_0_115, net_0_118, net_0_119, net_0_120, net_0_121, net_0_122,
         net_0_123, net_0_124, net_0_125, net_0_126, net_0_127, net_0_128, net_0_129,
         net_0_130, net_0_131, net_0_132, net_0_133, net_0_134, net_0_135, net_0_136,
         net_0_137, net_0_138, net_0_139, net_0_140, net_0_141, net_0_142, net_0_143,
         net_0_144, net_0_145, net_0_146, net_0_147, net_0_153, net_0_155, net_0_159,
         net_0_162, net_0_163, net_0_164, net_0_165, net_0_166, net_0_167, net_0_168,
         net_0_169, net_0_170, net_0_171, net_0_172, net_0_173, net_0_174, net_0_175,
         net_0_176, net_0_177, net_0_178, net_0_179, net_0_180, net_0_181, net_0_182,
         net_0_183, net_0_184, net_0_185, net_0_186, net_0_187, net_0_188, net_0_189,
         net_0_190, net_0_191, net_0_192, net_0_193, net_0_194, net_0_195, net_0_196,
         net_0_197, net_0_198, net_0_199, net_0_200, net_0_201, net_0_202, net_0_203,
         net_0_204, net_0_205, net_0_206, net_0_207, net_0_208, net_0_217, net_0_218,
         net_0_232, net_0_238, net_0_239, net_0_240, net_0_241, net_0_242, net_0_243,
         net_0_244, net_0_251, net_0_252, net_0_253, net_0_256, net_0_257, net_0_258,
         net_0_259, net_0_260, net_0_261, net_0_262, net_0_263, net_0_264, net_0_265,
         net_0_266, net_0_267, net_0_268, net_0_269, net_0_270, net_0_271, net_0_272,
         net_0_273, net_0_274, net_0_275, net_0_276, net_0_277, net_0_278, net_0_279,
         net_0_280, net_0_281, net_0_282, net_0_283, net_0_284, net_0_285, net_0_286,
         net_0_287, net_0_288, net_0_289, net_0_290, net_0_291, net_0_292, net_0_293,
         net_0_294, net_0_295, net_0_296, net_0_297, net_0_298, net_0_299, net_0_300,
         net_0_301, net_0_302, net_0_303, net_0_304, net_0_305, net_0_306, net_0_307,
         net_0_308, net_0_309, net_0_310, net_0_311, net_0_312, net_0_313, net_0_314,
         net_0_315, net_0_316, net_0_317, net_0_318, net_0_319, net_0_320, net_0_321,
         net_0_322, net_0_323, net_0_324, net_0_325, net_0_326, net_0_327, net_0_328,
         net_0_329, net_0_330, net_0_331, net_0_332, net_0_333, net_0_334, net_0_335,
         net_0_336, net_0_337, net_0_338, net_0_339, net_0_340, net_0_341, net_0_342,
         net_0_343, net_0_344, net_0_345, net_0_346, net_0_347, net_0_348, net_0_349,
         net_0_350, net_0_351, net_0_352, net_0_353, net_0_354, net_0_355, net_0_356,
         net_0_357, net_0_358, net_0_359, net_0_360, net_0_361, net_0_362, net_0_363,
         net_0_364, net_0_365, net_0_366, net_0_367, net_0_368, net_0_369, net_0_370,
         net_0_371, net_0_372, net_0_373, net_0_374, net_0_375, net_0_376, net_0_377,
         net_0_378, net_0_379, net_0_380, net_0_381, net_0_382, net_0_383, net_0_384,
         net_0_385, net_0_386, net_0_387, net_0_388, net_0_389, net_0_390, net_0_391,
         net_0_392, net_0_393, net_0_394, net_0_395, net_0_396, net_0_397, net_0_398,
         net_0_399, net_0_400, net_0_401, net_0_402, net_0_403, net_0_404, net_0_405,
         net_0_406, net_0_407, net_0_408, net_0_409, net_0_410, net_0_411, net_0_412,
         net_0_413, net_0_414, net_0_415, net_0_416, net_0_417, net_0_418, net_0_419,
         net_0_420, net_0_421, net_0_422, net_0_423, net_0_424, net_0_425, net_0_426,
         net_0_427, net_0_428, net_0_429, net_0_430, net_0_431, net_0_432, net_0_433,
         net_0_434, net_0_435, net_0_436, net_0_437, net_0_438, net_0_439, net_0_440,
         net_0_441, net_0_442, net_0_443, net_0_444, net_0_445, net_0_446, net_0_447,
         net_0_448, net_0_449, net_0_450, net_0_451, net_0_452, net_0_453, net_0_454,
         net_0_455, net_0_456, net_0_457, net_0_458, net_0_459, net_0_460, net_0_461,
         net_0_462, net_0_463, net_0_464, net_0_465, net_0_466, net_0_467;

  assign net_0_1 = ~raw_encoding_i[28];
  assign net_0_2 = ~net_0_87;
  assign net_0_3 = ~net_0_50;
  assign net_0_4 = ~net_0_44;
  assign net_0_5 = ~raw_encoding_i[27];
  assign net_0_6 = ~raw_encoding_i[26];
  assign net_0_7 = ~raw_encoding_i[24];
  assign net_0_8 = ~net_0_253;
  assign net_0_9 = ~raw_encoding_i[22];
  assign net_0_10 = ~raw_encoding_i[21];
  assign net_0_11 = ~raw_encoding_i[20];
  assign net_0_12 = ~raw_encoding_i[19];
  assign net_0_14 = ~raw_encoding_i[15];
  assign net_0_16 = ~net_0_200;
  assign net_0_17 = ~raw_encoding_i[13];
  assign net_0_19 = ~raw_encoding_i[11];
  assign net_0_20 = ~raw_encoding_i[10];
  assign net_0_21 = ~raw_encoding_i[5];
  assign undef = ~(net_0_22 & net_0_23);
  assign net_0_23 = (net_0_24 & net_0_25);
  assign net_0_25 = (net_0_26 & net_0_27);
  assign net_0_27 = (net_0_28 & net_0_29);
  assign net_0_29 = (net_0_30 & net_0_31);
  assign net_0_31 = (net_0_32 & net_0_33);
  assign net_0_33 = ~(raw_encoding_i[25] & net_0_34);
  assign net_0_34 = ~(net_0_35 & net_0_36);
  assign net_0_36 = ~(raw_encoding_i[27] & net_0_6);
  assign net_0_35 = ~(net_0_37 & net_0_38);
  assign net_0_38 = (net_0_9 | raw_encoding_i[24]);
  assign net_0_32 = (raw_encoding_i[24] | net_0_39);
  assign net_0_39 = (net_0_40 & net_0_41);
  assign net_0_40 = (net_0_42 & net_0_43);
  assign net_0_43 = (raw_encoding_i[4] | net_0_2);
  assign net_0_42 = ~(net_0_44 & raw_encoding_i[21]);
  assign net_0_30 = ~(net_0_45 & net_0_46);
  assign net_0_28 = (net_0_47 & net_0_48);
  assign net_0_48 = (net_0_49 | net_0_50);
  assign net_0_47 = (net_0_51 | raw_encoding_i[7]);
  assign net_0_51 = (net_0_52 & net_0_53);
  assign net_0_53 = ~(net_0_54 | net_0_55);
  assign net_0_55 = ~(raw_encoding_i[6] | net_0_56);
  assign net_0_56 = ~(net_0_57 | net_0_58);
  assign net_0_57 = ~(net_0_59 & net_0_60);
  assign net_0_60 = ~(net_0_61 & net_0_62);
  assign net_0_61 = (net_0_63 & net_0_3);
  assign net_0_59 = ~(net_0_64 & net_0_65);
  assign net_0_65 = ~(raw_encoding_i[11] | net_0_20);
  assign net_0_64 = (net_0_66 & net_0_37);
  assign net_0_52 = ~(net_0_67 & net_0_68);
  assign net_0_67 = ~(net_0_50 | net_0_69);
  assign net_0_26 = (raw_encoding_i[22] | net_0_70);
  assign net_0_70 = ~(net_0_71 | net_0_44);
  assign net_0_71 = ~(net_0_72 & net_0_73);
  assign net_0_73 = ~(net_0_74 & net_0_75);
  assign net_0_75 = (raw_encoding_i[21] & raw_encoding_i[24]);
  assign net_0_72 = (raw_encoding_i[28] | net_0_50);
  assign net_0_24 = ~(raw_encoding_i[9] & net_0_76);
  assign net_0_76 = ~(net_0_77 & net_0_78);
  assign net_0_78 = (net_0_79 & net_0_80);
  assign net_0_80 = (net_0_81 & net_0_82);
  assign net_0_82 = (net_0_83 & net_0_84);
  assign net_0_84 = (net_0_85 & net_0_86);
  assign net_0_86 = ~(net_0_87 & net_0_88);
  assign net_0_88 = (raw_encoding_i[24] | net_0_89);
  assign net_0_89 = ~(raw_encoding_i[20] | net_0_90);
  assign net_0_85 = (net_0_91 & net_0_92);
  assign net_0_92 = (raw_encoding_i[11] | net_0_93);
  assign net_0_93 = ~(raw_encoding_i[20] & net_0_37);
  assign net_0_91 = ~(net_0_94 & net_0_95);
  assign net_0_95 = (net_0_44 & net_0_96);
  assign net_0_96 = ~(raw_encoding_i[4] & net_0_97);
  assign net_0_97 = ~(raw_encoding_i[7] | raw_encoding_i[6]);
  assign net_0_83 = (net_0_98 & net_0_99);
  assign net_0_81 = ~(net_0_44 & net_0_100);
  assign net_0_100 = ~(net_0_49 & net_0_101);
  assign net_0_101 = ~(net_0_62 & net_0_102);
  assign net_0_102 = ~(net_0_103 & net_0_104);
  assign net_0_104 = ~(net_0_105 & net_0_106);
  assign net_0_106 = ~(raw_encoding_i[15] ^ raw_encoding_i[19]);
  assign net_0_105 = ~(net_0_107 & net_0_108);
  assign net_0_107 = ~(net_0_118 & net_0_119);
  assign net_0_119 = ~(raw_encoding_i[14] | raw_encoding_i[18]);
  assign net_0_118 = (net_0_120 & net_0_121);
  assign net_0_121 = ~(raw_encoding_i[16] ^ raw_encoding_i[12]);
  assign net_0_120 = ~(raw_encoding_i[17] ^ raw_encoding_i[13]);
  assign net_0_103 = ~(net_0_122 & net_0_123);
  assign net_0_49 = (net_0_90 & net_0_124);
  assign net_0_124 = ~(net_0_125 & raw_encoding_i[19]);
  assign net_0_79 = ~(raw_encoding_i[8] & net_0_126);
  assign net_0_126 = ~(net_0_127 & net_0_128);
  assign net_0_128 = ~(net_0_129 & net_0_130);
  assign net_0_130 = (net_0_131 | net_0_132);
  assign net_0_132 = (raw_encoding_i[20] & net_0_133);
  assign net_0_133 = (net_0_134 & net_0_135);
  assign net_0_135 = (raw_encoding_i[13] & raw_encoding_i[12]);
  assign net_0_134 = (net_0_136 & net_0_137);
  assign net_0_136 = (raw_encoding_i[10] ^ net_0_138);
  assign net_0_138 = ~(raw_encoding_i[14] & net_0_14);
  assign net_0_129 = (net_0_3 & net_0_139);
  assign net_0_139 = (net_0_140 | net_0_141);
  assign net_0_127 = (net_0_142 & net_0_143);
  assign net_0_143 = (net_0_144 & net_0_145);
  assign net_0_145 = ~(net_0_87 & net_0_146);
  assign net_0_146 = ~(net_0_90 & net_0_147);
  assign net_0_144 = ~(net_0_131 & net_0_162);
  assign net_0_162 = (raw_encoding_i[28] & net_0_163);
  assign net_0_163 = ~(net_0_164 & net_0_165);
  assign net_0_165 = ~(raw_encoding_i[25] & net_0_166);
  assign net_0_166 = (raw_encoding_i[21] & net_0_167);
  assign net_0_164 = (raw_encoding_i[15] | raw_encoding_i[27]);
  assign net_0_142 = (net_0_168 & net_0_169);
  assign net_0_169 = ~(net_0_66 & net_0_170);
  assign net_0_170 = (net_0_171 | net_0_172);
  assign net_0_172 = (net_0_131 & net_0_173);
  assign net_0_173 = ~(raw_encoding_i[23] | raw_encoding_i[28]);
  assign net_0_168 = (raw_encoding_i[4] | net_0_174);
  assign net_0_174 = ~(net_0_175 & net_0_176);
  assign net_0_176 = (raw_encoding_i[10] & net_0_177);
  assign net_0_77 = (raw_encoding_i[8] | net_0_178);
  assign net_0_178 = (net_0_179 & net_0_180);
  assign net_0_180 = ~(net_0_3 & net_0_181);
  assign net_0_181 = ~(net_0_182 & net_0_183);
  assign net_0_183 = (net_0_184 | raw_encoding_i[20]);
  assign net_0_184 = ~(raw_encoding_i[28] & net_0_185);
  assign net_0_185 = (net_0_186 | raw_encoding_i[24]);
  assign net_0_186 = ~(raw_encoding_i[23] | raw_encoding_i[10]);
  assign net_0_182 = (raw_encoding_i[12] | net_0_187);
  assign net_0_187 = ~(net_0_188 & net_0_189);
  assign net_0_189 = ~(net_0_8 | net_0_190);
  assign net_0_179 = ~(raw_encoding_i[27] & net_0_191);
  assign net_0_191 = ~(net_0_192 & net_0_193);
  assign net_0_193 = ~(raw_encoding_i[6] & net_0_194);
  assign net_0_194 = ~(net_0_195 & net_0_196);
  assign net_0_196 = ~(raw_encoding_i[26] & net_0_197);
  assign net_0_195 = (raw_encoding_i[12] | net_0_198);
  assign net_0_198 = ~(net_0_199 & net_0_188);
  assign net_0_188 = (raw_encoding_i[13] & net_0_200);
  assign net_0_192 = ~(raw_encoding_i[26] & net_0_201);
  assign net_0_201 = ~(net_0_202 & net_0_203);
  assign net_0_203 = (net_0_204 & net_0_205);
  assign net_0_205 = ~(net_0_206 & net_0_207);
  assign net_0_207 = ~(raw_encoding_i[1] ^ raw_encoding_i[0]);
  assign net_0_206 = ~(net_0_208 | net_0_8);
  assign net_0_217 = (net_0_9 | raw_encoding_i[23]);
  assign net_0_238 = (net_0_239 | raw_encoding_i[23]);
  assign net_0_239 = ~(net_0_240 & net_0_241);
  assign net_0_241 = ~(raw_encoding_i[19] | raw_encoding_i[18]);
  assign net_0_240 = ~(raw_encoding_i[21] | net_0_242);
  assign net_0_242 = (net_0_243 | raw_encoding_i[1]);
  assign net_0_243 = ~(raw_encoding_i[0] & net_0_244);
  assign net_0_244 = ~(raw_encoding_i[17] | raw_encoding_i[16]);
  assign net_0_251 = (net_0_252 | raw_encoding_i[15]);
  assign net_0_252 = ~(net_0_115 & raw_encoding_i[12]);
  assign net_0_115 = (raw_encoding_i[14] & net_0_17);
  assign net_0_197 = (raw_encoding_i[20] & net_0_257);
  assign net_0_257 = ~(raw_encoding_i[25] & net_0_90);
  assign net_0_90 = ~(net_0_122 & raw_encoding_i[15]);
  assign net_0_122 = (net_0_114 & raw_encoding_i[12]);
  assign net_0_114 = (raw_encoding_i[14] & raw_encoding_i[13]);
  assign net_0_202 = ~(net_0_258 & net_0_259);
  assign net_0_259 = (net_0_94 & net_0_260);
  assign net_0_258 = (net_0_261 & raw_encoding_i[5]);
  assign net_0_22 = (net_0_262 & net_0_263);
  assign net_0_263 = (net_0_264 | raw_encoding_i[9]);
  assign net_0_264 = (net_0_265 & net_0_266);
  assign net_0_266 = (net_0_267 & net_0_268);
  assign net_0_267 = (net_0_269 & net_0_270);
  assign net_0_270 = (net_0_271 | net_0_69);
  assign net_0_69 = (raw_encoding_i[4] | net_0_21);
  assign net_0_269 = ~(net_0_3 & net_0_272);
  assign net_0_272 = (net_0_273 & net_0_274);
  assign net_0_274 = (net_0_261 | raw_encoding_i[10]);
  assign net_0_273 = (net_0_37 & net_0_19);
  assign net_0_265 = (net_0_275 & net_0_276);
  assign net_0_276 = ~(raw_encoding_i[8] & net_0_277);
  assign net_0_277 = ~(net_0_278 & net_0_279);
  assign net_0_279 = ~(net_0_280 & raw_encoding_i[12]);
  assign net_0_280 = (net_0_199 & net_0_281);
  assign net_0_281 = (raw_encoding_i[27] & net_0_282);
  assign net_0_199 = ~(raw_encoding_i[25] | net_0_283);
  assign net_0_278 = (net_0_284 & net_0_285);
  assign net_0_285 = ~(net_0_286 & net_0_287);
  assign net_0_284 = (net_0_98 & net_0_288);
  assign net_0_288 = ~(net_0_140 & net_0_289);
  assign net_0_289 = (raw_encoding_i[12] & net_0_290);
  assign net_0_290 = ~(net_0_291 | net_0_8);
  assign net_0_275 = (raw_encoding_i[8] | net_0_292);
  assign net_0_292 = (net_0_293 & net_0_294);
  assign net_0_294 = (net_0_295 | net_0_291);
  assign net_0_291 = ~(net_0_3 & net_0_282);
  assign net_0_282 = ~(raw_encoding_i[13] | net_0_16);
  assign net_0_200 = (net_0_296 & net_0_137);
  assign net_0_137 = ~(raw_encoding_i[15] ^ raw_encoding_i[11]);
  assign net_0_296 = ~(raw_encoding_i[14] ^ raw_encoding_i[10]);
  assign net_0_295 = (raw_encoding_i[12] | net_0_297);
  assign net_0_297 = (net_0_283 & net_0_298);
  assign net_0_298 = ~(net_0_253 & net_0_140);
  assign net_0_140 = ~(net_0_190 | raw_encoding_i[28]);
  assign net_0_283 = ~(net_0_62 & net_0_141);
  assign net_0_62 = (net_0_253 & net_0_190);
  assign net_0_293 = ~(net_0_171 & net_0_66);
  assign net_0_171 = (raw_encoding_i[24] & raw_encoding_i[28]);
  assign net_0_262 = (net_0_299 & net_0_300);
  assign net_0_300 = ~(raw_encoding_i[24] & net_0_301);
  assign net_0_301 = ~(net_0_302 & net_0_303);
  assign net_0_303 = ~(net_0_44 | net_0_304);
  assign net_0_304 = (net_0_305 & net_0_306);
  assign net_0_306 = (net_0_307 | raw_encoding_i[13]);
  assign net_0_307 = ~(raw_encoding_i[6] | net_0_308);
  assign net_0_308 = ~(net_0_153 & net_0_309);
  assign net_0_153 = ~(raw_encoding_i[22] | raw_encoding_i[5]);
  assign net_0_302 = (net_0_310 & net_0_311);
  assign net_0_311 = ~(raw_encoding_i[5] & net_0_312);
  assign net_0_312 = (net_0_305 & net_0_313);
  assign net_0_313 = ~(net_0_314 & net_0_315);
  assign net_0_315 = (raw_encoding_i[4] | net_0_316);
  assign net_0_316 = (net_0_317 & net_0_318);
  assign net_0_318 = ~(raw_encoding_i[22] & net_0_319);
  assign net_0_319 = (net_0_320 | net_0_125);
  assign net_0_125 = (raw_encoding_i[18] & net_0_321);
  assign net_0_321 = (raw_encoding_i[17] & raw_encoding_i[16]);
  assign net_0_320 = (raw_encoding_i[20] & net_0_322);
  assign net_0_322 = ~(raw_encoding_i[17] & net_0_323);
  assign net_0_323 = (raw_encoding_i[19] & raw_encoding_i[18]);
  assign net_0_317 = ~(net_0_324 & net_0_325);
  assign net_0_325 = ~(raw_encoding_i[11] & raw_encoding_i[10]);
  assign net_0_324 = ~(net_0_11 | raw_encoding_i[21]);
  assign net_0_314 = ~(raw_encoding_i[4] & net_0_326);
  assign net_0_326 = ~(net_0_327 & net_0_328);
  assign net_0_328 = (net_0_329 & net_0_330);
  assign net_0_330 = ~(net_0_309 & net_0_331);
  assign net_0_331 = (raw_encoding_i[16] | net_0_9);
  assign net_0_329 = (net_0_9 | net_0_232);
  assign net_0_232 = (net_0_12 | raw_encoding_i[18]);
  assign net_0_327 = ~(net_0_94 & net_0_10);
  assign net_0_310 = (net_0_20 | net_0_98);
  assign net_0_98 = ~(net_0_159 & net_0_177);
  assign net_0_159 = (raw_encoding_i[21] & net_0_11);
  assign net_0_299 = (net_0_332 & net_0_333);
  assign net_0_333 = (net_0_334 & net_0_335);
  assign net_0_335 = (net_0_336 & net_0_337);
  assign net_0_337 = (net_0_338 & net_0_339);
  assign net_0_339 = (net_0_340 & net_0_341);
  assign net_0_341 = (raw_encoding_i[8] | net_0_342);
  assign net_0_342 = ~(net_0_343 & net_0_344);
  assign net_0_344 = (net_0_3 | raw_encoding_i[20]);
  assign net_0_343 = (net_0_94 & net_0_37);
  assign net_0_37 = ~(raw_encoding_i[23] | net_0_1);
  assign net_0_94 = (raw_encoding_i[11] & net_0_20);
  assign net_0_340 = ~(raw_encoding_i[8] & net_0_345);
  assign net_0_345 = ~(net_0_346 & net_0_99);
  assign net_0_99 = ~(net_0_347 & net_0_74);
  assign net_0_346 = (net_0_348 & net_0_349);
  assign net_0_349 = (net_0_271 | net_0_21);
  assign net_0_271 = ~(raw_encoding_i[20] & net_0_45);
  assign net_0_45 = (net_0_347 & net_0_177);
  assign net_0_177 = ~(raw_encoding_i[26] | net_0_41);
  assign net_0_41 = ~(net_0_9 & net_0_305);
  assign net_0_348 = ~(net_0_350 & net_0_287);
  assign net_0_287 = (raw_encoding_i[28] & net_0_3);
  assign net_0_338 = (net_0_351 & net_0_352);
  assign net_0_352 = (net_0_353 & net_0_354);
  assign net_0_354 = ~(raw_encoding_i[23] & net_0_44);
  assign net_0_353 = (net_0_268 | raw_encoding_i[11]);
  assign net_0_351 = ~(net_0_167 & net_0_355);
  assign net_0_355 = (net_0_74 | net_0_356);
  assign net_0_356 = ~(raw_encoding_i[21] | net_0_357);
  assign net_0_357 = (net_0_358 & net_0_359);
  assign net_0_359 = ~(raw_encoding_i[28] & net_0_11);
  assign net_0_358 = ~(net_0_360 & raw_encoding_i[20]);
  assign net_0_360 = (net_0_305 & net_0_361);
  assign net_0_74 = (raw_encoding_i[26] & net_0_305);
  assign net_0_336 = ~(net_0_362 & net_0_363);
  assign net_0_363 = ~(net_0_364 & net_0_365);
  assign net_0_365 = ~(raw_encoding_i[26] & net_0_366);
  assign net_0_366 = (net_0_367 | raw_encoding_i[20]);
  assign net_0_367 = ~(net_0_361 & net_0_368);
  assign net_0_368 = (net_0_369 & net_0_46);
  assign net_0_46 = (raw_encoding_i[19] & net_0_123);
  assign net_0_123 = (raw_encoding_i[16] & net_0_370);
  assign net_0_370 = (raw_encoding_i[18] & raw_encoding_i[17]);
  assign net_0_369 = (net_0_19 & net_0_20);
  assign net_0_361 = (raw_encoding_i[1] | raw_encoding_i[0]);
  assign net_0_364 = ~(net_0_371 & net_0_372);
  assign net_0_372 = (net_0_373 | raw_encoding_i[6]);
  assign net_0_373 = (net_0_208 | raw_encoding_i[2]);
  assign net_0_208 = (raw_encoding_i[4] | net_0_256);
  assign net_0_256 = (raw_encoding_i[5] | raw_encoding_i[3]);
  assign net_0_362 = (net_0_347 & net_0_305);
  assign net_0_334 = ~(raw_encoding_i[28] & net_0_374);
  assign net_0_374 = ~(net_0_375 & net_0_376);
  assign net_0_376 = (net_0_377 & net_0_378);
  assign net_0_378 = (net_0_379 & net_0_380);
  assign net_0_380 = (net_0_381 & net_0_268);
  assign net_0_268 = (net_0_4 & net_0_2);
  assign net_0_87 = (raw_encoding_i[25] & raw_encoding_i[27]);
  assign net_0_44 = (raw_encoding_i[26] & net_0_382);
  assign net_0_381 = ~(raw_encoding_i[20] & net_0_383);
  assign net_0_383 = (net_0_167 & net_0_3);
  assign net_0_167 = (raw_encoding_i[22] & raw_encoding_i[24]);
  assign net_0_379 = ~(net_0_66 & net_0_384);
  assign net_0_384 = (net_0_131 & net_0_347);
  assign net_0_377 = (net_0_385 & net_0_386);
  assign net_0_386 = ~(raw_encoding_i[27] & net_0_387);
  assign net_0_387 = (net_0_350 & raw_encoding_i[6]);
  assign net_0_385 = ~(raw_encoding_i[22] & net_0_388);
  assign net_0_388 = (raw_encoding_i[21] & net_0_7);
  assign net_0_375 = (raw_encoding_i[27] | net_0_389);
  assign net_0_389 = (net_0_390 & net_0_391);
  assign net_0_391 = ~(raw_encoding_i[15] & net_0_392);
  assign net_0_392 = ~(raw_encoding_i[24] & net_0_393);
  assign net_0_393 = ~(raw_encoding_i[14] | raw_encoding_i[12]);
  assign net_0_390 = (net_0_394 & net_0_395);
  assign net_0_395 = ~(net_0_396 & net_0_397);
  assign net_0_397 = ~(raw_encoding_i[26] | raw_encoding_i[5]);
  assign net_0_396 = (net_0_175 | net_0_398);
  assign net_0_398 = (raw_encoding_i[22] & net_0_286);
  assign net_0_175 = (net_0_11 & net_0_347);
  assign net_0_394 = (raw_encoding_i[25] & net_0_399);
  assign net_0_399 = (net_0_400 | raw_encoding_i[15]);
  assign net_0_400 = ~(raw_encoding_i[20] | raw_encoding_i[24]);
  assign net_0_332 = ~(raw_encoding_i[7] & net_0_401);
  assign net_0_401 = (net_0_54 | net_0_402);
  assign net_0_402 = ~(net_0_403 & net_0_404);
  assign net_0_404 = (net_0_405 & net_0_406);
  assign net_0_406 = (raw_encoding_i[6] | net_0_407);
  assign net_0_407 = ~(net_0_408 & net_0_141);
  assign net_0_141 = (raw_encoding_i[5] & net_0_155);
  assign net_0_155 = (raw_encoding_i[4] & net_0_63);
  assign net_0_408 = (net_0_260 & net_0_3);
  assign net_0_405 = ~(raw_encoding_i[28] & net_0_409);
  assign net_0_409 = (raw_encoding_i[27] & net_0_410);
  assign net_0_410 = (net_0_411 | net_0_350);
  assign net_0_350 = ~(raw_encoding_i[23] | raw_encoding_i[11]);
  assign net_0_411 = (net_0_131 & net_0_286);
  assign net_0_286 = (raw_encoding_i[24] & net_0_11);
  assign net_0_131 = (raw_encoding_i[10] & raw_encoding_i[11]);
  assign net_0_403 = ~(net_0_305 & net_0_412);
  assign net_0_412 = ~(net_0_413 & net_0_414);
  assign net_0_414 = ~(net_0_347 & net_0_371);
  assign net_0_371 = (net_0_253 | raw_encoding_i[26]);
  assign net_0_253 = (raw_encoding_i[22] & raw_encoding_i[20]);
  assign net_0_347 = (raw_encoding_i[24] & net_0_10);
  assign net_0_413 = ~(net_0_9 & net_0_309);
  assign net_0_309 = (raw_encoding_i[21] & raw_encoding_i[20]);
  assign net_0_305 = (raw_encoding_i[25] & raw_encoding_i[28]);
  assign net_0_54 = (net_0_261 & net_0_415);
  assign net_0_415 = (raw_encoding_i[6] & net_0_58);
  assign net_0_58 = (net_0_66 & net_0_68);
  assign net_0_68 = (net_0_260 & net_0_63);
  assign net_0_63 = (raw_encoding_i[23] & net_0_1);
  assign net_0_260 = (raw_encoding_i[22] & net_0_190);
  assign net_0_190 = (net_0_10 & net_0_7);
  assign net_0_66 = ~(raw_encoding_i[20] | net_0_50);
  assign net_0_50 = ~(net_0_6 & net_0_382);
  assign net_0_382 = ~(net_0_5 | raw_encoding_i[25]);
  assign net_0_261 = (raw_encoding_i[3] & net_0_416);
  assign net_0_416 = (raw_encoding_i[2] & net_0_417);
  assign net_0_417 = (raw_encoding_i[1] & raw_encoding_i[0]);
  assign net_0_418 = (raw_encoding_i[16] ^ raw_encoding_i[18]);
  assign net_0_419 = (raw_encoding_i[16] & net_0_12);
  assign net_0_420 = ~(raw_encoding_i[17] | net_0_419);
  assign net_0_421 = ~(net_0_418 & net_0_420);
  assign net_0_422 = (raw_encoding_i[18] | raw_encoding_i[17]);
  assign net_0_423 = ~(net_0_10 | net_0_422);
  assign net_0_424 = (raw_encoding_i[19] ^ raw_encoding_i[18]);
  assign net_0_425 = (raw_encoding_i[21] & net_0_424);
  assign net_0_426 = (net_0_425 | net_0_423);
  assign net_0_427 = ~(net_0_159 & net_0_422);
  assign net_0_428 = ~(raw_encoding_i[16] | net_0_232);
  assign net_0_429 = ~(raw_encoding_i[17] & net_0_428);
  assign net_0_430 = (net_0_427 & net_0_429);
  assign net_0_431 = (net_0_430 & net_0_426);
  assign net_0_432 = ~(net_0_421 & net_0_431);
  assign net_0_218 = ~(raw_encoding_i[23] & net_0_432);
  assign net_0_433 = (raw_encoding_i[12] ^ raw_encoding_i[16]);
  assign net_0_434 = ~(raw_encoding_i[17] | net_0_433);
  assign net_0_435 = ~(raw_encoding_i[17] & net_0_114);
  assign net_0_436 = (raw_encoding_i[16] | net_0_435);
  assign net_0_437 = (raw_encoding_i[12] | net_0_436);
  assign net_0_438 = ~(net_0_115 & net_0_434);
  assign net_0_439 = ~(net_0_437 & net_0_438);
  assign net_0_108 = ~(raw_encoding_i[18] & net_0_439);
  assign net_0_440 = (net_0_11 & net_0_63);
  assign net_0_441 = (net_0_153 | net_0_440);
  assign net_0_442 = (raw_encoding_i[20] ^ raw_encoding_i[22]);
  assign net_0_443 = (raw_encoding_i[20] ^ raw_encoding_i[5]);
  assign net_0_444 = ~(net_0_442 & net_0_443);
  assign net_0_445 = ~(net_0_159 & raw_encoding_i[16]);
  assign net_0_446 = ~(net_0_444 & net_0_445);
  assign net_0_447 = ~(net_0_155 & net_0_446);
  assign net_0_448 = ~(raw_encoding_i[6] & net_0_441);
  assign net_0_449 = ~(net_0_447 & net_0_448);
  assign net_0_147 = ~(net_0_94 & net_0_449);
  assign net_0_450 = ~(raw_encoding_i[22] | net_0_238);
  assign net_0_451 = (net_0_218 & net_0_217);
  assign net_0_452 = ~(raw_encoding_i[21] & net_0_9);
  assign net_0_453 = (net_0_451 & net_0_452);
  assign net_0_454 = (net_0_90 | net_0_450);
  assign net_0_455 = (net_0_90 & net_0_453);
  assign net_0_456 = (raw_encoding_i[10] | net_0_455);
  assign net_0_457 = ~(net_0_454 & net_0_456);
  assign net_0_458 = ~(net_0_251 & net_0_8);
  assign net_0_459 = ~(raw_encoding_i[4] & net_0_253);
  assign net_0_460 = (net_0_458 & net_0_459);
  assign net_0_461 = (raw_encoding_i[2] | raw_encoding_i[7]);
  assign net_0_462 = (net_0_256 | net_0_461);
  assign net_0_463 = ~(net_0_197 & net_0_462);
  assign net_0_464 = (net_0_460 | raw_encoding_i[25]);
  assign net_0_465 = ~(net_0_463 & net_0_464);
  assign net_0_466 = ~(raw_encoding_i[10] & net_0_465);
  assign net_0_467 = ~(raw_encoding_i[25] & net_0_457);
  assign net_0_204 = (net_0_466 & net_0_467);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Defined instruction sideband encoder
  // ------------------------------------------------------

  wire   net_1_1, net_1_2, net_1_3, net_1_4, net_1_5, net_1_6, net_1_7, net_1_8, net_1_9, net_1_10,
         net_1_11, net_1_12, net_1_13, net_1_14, net_1_15, net_1_16, net_1_17, net_1_18,
         net_1_19, net_1_20, net_1_21, net_1_22, net_1_23, net_1_24, net_1_25, net_1_26,
         net_1_27, net_1_28, net_1_29, net_1_30, net_1_31, net_1_32, net_1_33, net_1_34,
         net_1_35, net_1_36, net_1_37, net_1_38, net_1_39, net_1_40, net_1_41, net_1_42,
         net_1_43, net_1_44, net_1_45, net_1_46, net_1_47, net_1_48, net_1_49, net_1_50,
         net_1_51, net_1_52, net_1_53, net_1_54, net_1_55, net_1_56, net_1_57, net_1_58,
         net_1_59, net_1_60, net_1_61, net_1_62, net_1_63, net_1_64, net_1_65, net_1_66,
         net_1_67, net_1_68, net_1_69, net_1_70, net_1_71, net_1_72, net_1_73, net_1_74,
         net_1_75, net_1_76, net_1_77, net_1_78, net_1_79, net_1_80, net_1_81, net_1_82,
         net_1_83, net_1_84, net_1_85, net_1_86, net_1_87, net_1_88, net_1_89, net_1_90,
         net_1_91, net_1_92, net_1_93, net_1_94, net_1_95, net_1_96, net_1_97, net_1_98,
         net_1_99, net_1_100, net_1_101, net_1_102, net_1_103, net_1_104, net_1_105, net_1_106,
         net_1_107, net_1_108, net_1_109, net_1_110, net_1_111, net_1_112, net_1_113,
         net_1_114, net_1_115, net_1_116, net_1_117, net_1_118, net_1_119, net_1_120,
         net_1_121, net_1_122, net_1_123, net_1_124, net_1_125, net_1_126, net_1_127,
         net_1_128, net_1_129, net_1_130, net_1_131, net_1_132, net_1_133, net_1_134,
         net_1_135, net_1_136, net_1_137, net_1_138, net_1_139, net_1_140, net_1_141,
         net_1_142, net_1_143, net_1_144, net_1_145, net_1_146, net_1_147, net_1_148,
         net_1_149, net_1_150, net_1_151, net_1_152, net_1_153, net_1_154, net_1_155,
         net_1_156, net_1_157, net_1_158, net_1_159, net_1_160, net_1_161, net_1_162,
         net_1_163, net_1_164, net_1_165, net_1_166, net_1_167, net_1_168, net_1_169,
         net_1_170, net_1_171, net_1_172, net_1_173, net_1_174, net_1_175, net_1_176,
         net_1_177, net_1_178, net_1_179, net_1_180, net_1_181, net_1_182, net_1_183,
         net_1_184, net_1_185, net_1_186, net_1_187, net_1_188, net_1_189, net_1_190,
         net_1_191, net_1_192, net_1_193, net_1_194, net_1_195, net_1_196, net_1_197,
         net_1_198, net_1_199, net_1_200, net_1_201, net_1_202, net_1_203, net_1_204,
         net_1_205, net_1_206, net_1_207, net_1_208, net_1_209, net_1_210, net_1_211,
         net_1_212, net_1_213, net_1_214, net_1_215, net_1_216, net_1_217, net_1_218,
         net_1_219, net_1_220, net_1_221, net_1_222, net_1_223, net_1_224, net_1_225,
         net_1_226, net_1_227, net_1_228, net_1_229, net_1_230, net_1_231, net_1_232,
         net_1_233, net_1_234, net_1_235, net_1_236, net_1_237, net_1_238, net_1_239,
         net_1_240, net_1_241, net_1_242, net_1_243, net_1_244, net_1_245, net_1_246,
         net_1_247, net_1_248, net_1_249, net_1_250, net_1_251, net_1_252, net_1_253,
         net_1_254, net_1_255, net_1_256, net_1_257, net_1_258, net_1_259, net_1_260,
         net_1_261, net_1_262, net_1_263, net_1_264, net_1_265, net_1_266, net_1_267,
         net_1_268, net_1_269, net_1_270, net_1_271, net_1_272, net_1_273, net_1_274,
         net_1_275, net_1_276, net_1_277, net_1_278, net_1_279, net_1_280, net_1_281,
         net_1_282, net_1_283, net_1_284, net_1_285, net_1_286, net_1_287, net_1_288,
         net_1_289, net_1_290, net_1_291, net_1_292, net_1_293, net_1_294, net_1_295,
         net_1_296, net_1_297, net_1_298, net_1_299, net_1_300, net_1_301, net_1_302,
         net_1_303, net_1_304, net_1_305, net_1_306, net_1_307, net_1_308, net_1_309,
         net_1_310, net_1_311, net_1_312, net_1_313, net_1_314, net_1_315, net_1_316,
         net_1_317, net_1_318, net_1_319, net_1_320, net_1_321, net_1_322, net_1_323,
         net_1_324, net_1_325, net_1_326, net_1_327, net_1_328, net_1_329, net_1_330,
         net_1_331, net_1_332, net_1_333, net_1_334, net_1_335, net_1_336, net_1_337,
         net_1_338, net_1_339, net_1_340, net_1_341, net_1_342, net_1_343, net_1_344,
         net_1_345, net_1_346, net_1_347, net_1_348, net_1_349, net_1_350, net_1_351,
         net_1_352, net_1_353, net_1_354, net_1_355, net_1_356, net_1_357, net_1_358,
         net_1_359, net_1_360, net_1_361, net_1_362, net_1_363, net_1_364, net_1_365,
         net_1_366, net_1_367, net_1_368, net_1_369, net_1_370, net_1_371, net_1_372,
         net_1_373, net_1_374, net_1_375, net_1_376, net_1_377, net_1_378, net_1_379,
         net_1_380, net_1_381, net_1_382, net_1_383, net_1_384, net_1_385, net_1_386,
         net_1_387, net_1_388, net_1_389, net_1_390, net_1_391, net_1_392, net_1_393,
         net_1_394, net_1_395, net_1_396, net_1_397, net_1_398, net_1_399, net_1_400,
         net_1_401, net_1_402, net_1_403, net_1_404, net_1_405, net_1_406, net_1_407,
         net_1_408, net_1_409, net_1_410;

  assign net_1_1 = ~net_1_243;
  assign net_1_2 = ~raw_encoding_i[28];
  assign net_1_3 = ~net_1_320;
  assign net_1_4 = ~net_1_92;
  assign net_1_5 = ~raw_encoding_i[24];
  assign net_1_6 = ~raw_encoding_i[23];
  assign net_1_7 = ~net_1_144;
  assign net_1_8 = ~net_1_381;
  assign net_1_9 = ~raw_encoding_i[22];
  assign net_1_10 = ~raw_encoding_i[21];
  assign net_1_11 = ~raw_encoding_i[20];
  assign net_1_12 = ~raw_encoding_i[19];
  assign net_1_13 = ~raw_encoding_i[16];
  assign net_1_14 = ~net_1_110;
  assign net_1_15 = ~net_1_69;
  assign net_1_16 = ~raw_encoding_i[8];
  assign net_1_17 = ~raw_encoding_i[6];
  assign net_1_18 = ~raw_encoding_i[5];
  assign net_1_19 = ~raw_encoding_i[4];
  assign net_1_20 = ~net_1_345;
  assign net_1_21 = ~a64_state_i;
  assign defined_sideband[5] = ~(net_1_22 & net_1_23);
  assign net_1_23 = (net_1_24 | raw_encoding_i[28]);
  assign net_1_22 = ~(net_1_25 | net_1_26);
  assign net_1_26 = (net_1_27 | net_1_28);
  assign net_1_28 = (net_1_29 | net_1_30);
  assign net_1_30 = ~(net_1_31 & net_1_32);
  assign net_1_32 = ~(net_1_33 & net_1_34);
  assign net_1_31 = (net_1_35 & net_1_36);
  assign net_1_36 = (net_1_37 | net_1_38);
  assign net_1_38 = ~(raw_encoding_i[27] & net_1_39);
  assign net_1_27 = (net_1_40 & net_1_41);
  assign net_1_41 = ~(raw_encoding_i[19] & raw_encoding_i[16]);
  assign net_1_25 = (net_1_42 & net_1_43);
  assign net_1_43 = (net_1_44 | net_1_45);
  assign net_1_44 = (net_1_46 | net_1_47);
  assign net_1_47 = (net_1_48 | net_1_49);
  assign net_1_49 = (net_1_50 & net_1_51);
  assign net_1_51 = ~(net_1_52 & net_1_53);
  assign net_1_53 = ~(net_1_54 & net_1_55);
  assign net_1_54 = (net_1_56 & net_1_57);
  assign net_1_57 = ~(net_1_20 | raw_encoding_i[6]);
  assign net_1_56 = (net_1_58 & net_1_11);
  assign net_1_50 = ~(raw_encoding_i[22] | raw_encoding_i[7]);
  assign net_1_48 = (net_1_59 & net_1_60);
  assign net_1_60 = ~(net_1_61 & net_1_62);
  assign net_1_62 = ~(net_1_9 & net_1_63);
  assign net_1_61 = (net_1_64 & net_1_65);
  assign net_1_46 = (net_1_66 & net_1_67);
  assign net_1_67 = (net_1_68 & net_1_15);
  assign net_1_66 = (net_1_70 & net_1_11);
  assign net_1_42 = (net_1_71 & raw_encoding_i[28]);
  assign defined_sideband[4] = ~(net_1_72 & net_1_35);
  assign net_1_35 = (net_1_73 | net_1_74);
  assign net_1_74 = (net_1_75 | net_1_76);
  assign net_1_76 = ~(net_1_77 & raw_encoding_i[11]);
  assign net_1_75 = (net_1_78 & net_1_79);
  assign net_1_79 = ~(a64_state_i & raw_encoding_i[9]);
  assign net_1_78 = (net_1_80 | raw_encoding_i[8]);
  assign net_1_80 = (raw_encoding_i[7] | net_1_81);
  assign net_1_81 = (net_1_82 & net_1_83);
  assign net_1_83 = ~(a64_state_i & net_1_17);
  assign net_1_82 = (raw_encoding_i[9] | sf_bit_i);
  assign net_1_73 = (net_1_84 | net_1_85);
  assign net_1_85 = (net_1_86 | net_1_87);
  assign net_1_87 = ~(raw_encoding_i[28] & raw_encoding_i[23]);
  assign net_1_86 = (raw_encoding_i[4] | net_1_88);
  assign net_1_88 = ~(raw_encoding_i[27] & net_1_89);
  assign net_1_89 = ~(net_1_5 | net_1_11);
  assign net_1_72 = (net_1_90 & net_1_91);
  assign net_1_91 = (net_1_92 | net_1_93);
  assign net_1_93 = (net_1_94 & net_1_95);
  assign net_1_95 = (net_1_96 & net_1_97);
  assign net_1_97 = (net_1_98 | net_1_99);
  assign net_1_99 = ~(net_1_5 | raw_encoding_i[20]);
  assign net_1_96 = (net_1_100 & net_1_101);
  assign net_1_101 = ~(net_1_102 & net_1_103);
  assign net_1_103 = (net_1_104 | net_1_105);
  assign net_1_105 = (net_1_106 & net_1_10);
  assign net_1_100 = (net_1_8 | raw_encoding_i[28]);
  assign net_1_90 = (net_1_107 & net_1_108);
  assign net_1_108 = ~(raw_encoding_i[28] & net_1_109);
  assign net_1_107 = (net_1_110 | net_1_111);
  assign net_1_111 = (net_1_112 | raw_encoding_i[28]);
  assign net_1_112 = (net_1_24 & net_1_113);
  assign net_1_113 = (net_1_114 | net_1_19);
  assign net_1_114 = ~(net_1_115 & net_1_116);
  assign net_1_24 = ~(net_1_117 & net_1_118);
  assign net_1_117 = ~(net_1_119 & net_1_120);
  assign net_1_120 = (net_1_121 | raw_encoding_i[20]);
  assign net_1_119 = (net_1_122 & net_1_123);
  assign net_1_123 = (net_1_11 | net_1_124);
  assign net_1_124 = (net_1_125 & net_1_126);
  assign net_1_125 = (net_1_127 | net_1_21);
  assign net_1_127 = (net_1_128 & net_1_129);
  assign net_1_129 = ~(raw_encoding_i[22] & net_1_6);
  assign net_1_128 = (net_1_130 | net_1_6);
  assign net_1_130 = ~(net_1_131 | net_1_132);
  assign net_1_132 = ~(net_1_133 | raw_encoding_i[6]);
  assign defined_sideband[3] = (net_1_134 | net_1_135);
  assign net_1_135 = (net_1_136 | net_1_137);
  assign net_1_136 = (raw_encoding_i[28] & net_1_138);
  assign net_1_138 = ~(net_1_139 & net_1_140);
  assign net_1_140 = (net_1_141 | net_1_65);
  assign net_1_65 = (net_1_11 | a64_state_i);
  assign net_1_139 = ~(net_1_142 | net_1_143);
  assign net_1_142 = (net_1_144 & net_1_145);
  assign net_1_134 = (net_1_146 | net_1_147);
  assign net_1_147 = ~(net_1_148 & net_1_149);
  assign net_1_149 = ~(net_1_150 & net_1_151);
  assign defined_sideband[2] = ~(net_1_152 & net_1_148);
  assign net_1_148 = ~(raw_encoding_i[27] & net_1_153);
  assign net_1_153 = (net_1_154 | net_1_155);
  assign net_1_155 = ~(net_1_156 & net_1_157);
  assign net_1_157 = (net_1_158 | raw_encoding_i[20]);
  assign net_1_158 = ~(net_1_159 & net_1_110);
  assign net_1_156 = (net_1_160 | raw_encoding_i[11]);
  assign net_1_160 = ~(net_1_161 & net_1_162);
  assign net_1_162 = (net_1_163 | net_1_164);
  assign net_1_164 = ~(raw_encoding_i[10] | net_1_165);
  assign net_1_165 = ~(net_1_102 & net_1_166);
  assign net_1_166 = ~(net_1_7 | raw_encoding_i[6]);
  assign net_1_102 = (net_1_5 & raw_encoding_i[28]);
  assign net_1_163 = (net_1_6 & net_1_167);
  assign net_1_167 = (net_1_168 & raw_encoding_i[20]);
  assign net_1_154 = (net_1_16 & net_1_169);
  assign net_1_169 = (net_1_39 & net_1_170);
  assign net_1_170 = ~(net_1_171 & net_1_172);
  assign net_1_172 = (net_1_173 | raw_encoding_i[20]);
  assign net_1_171 = (net_1_110 | net_1_174);
  assign net_1_152 = (net_1_175 & net_1_176);
  assign net_1_176 = ~(raw_encoding_i[26] & net_1_177);
  assign net_1_177 = ~(raw_encoding_i[20] | net_1_178);
  assign net_1_178 = ~(net_1_179 & net_1_180);
  assign net_1_180 = ~(net_1_181 & net_1_182);
  assign net_1_182 = ~(net_1_183 & net_1_110);
  assign net_1_181 = (net_1_184 | net_1_1);
  assign net_1_184 = ~(net_1_185 | net_1_186);
  assign net_1_186 = (net_1_144 & net_1_187);
  assign net_1_185 = (raw_encoding_i[25] & net_1_188);
  assign net_1_188 = ~(net_1_122 & net_1_121);
  assign net_1_121 = ~(net_1_189 & net_1_131);
  assign net_1_131 = ~(net_1_10 | net_1_16);
  assign net_1_122 = (net_1_190 & net_1_191);
  assign net_1_191 = (raw_encoding_i[23] | net_1_126);
  assign net_1_126 = ~(raw_encoding_i[8] & net_1_133);
  assign net_1_133 = (raw_encoding_i[22] | raw_encoding_i[5]);
  assign net_1_190 = (net_1_192 & net_1_193);
  assign net_1_193 = ~(net_1_16 & net_1_194);
  assign net_1_194 = ~(net_1_7 | raw_encoding_i[22]);
  assign net_1_192 = (raw_encoding_i[6] | net_1_195);
  assign net_1_195 = (net_1_196 & net_1_16);
  assign net_1_196 = ~(raw_encoding_i[22] & net_1_197);
  assign net_1_197 = (net_1_189 & net_1_18);
  assign net_1_175 = (net_1_198 & net_1_199);
  assign net_1_199 = (net_1_2 | net_1_200);
  assign net_1_200 = ~(net_1_201 | net_1_146);
  assign net_1_146 = ~(net_1_202 | net_1_203);
  assign net_1_203 = ~(net_1_204 & net_1_205);
  assign net_1_205 = ~(net_1_5 | net_1_8);
  assign net_1_198 = ~(net_1_206 & net_1_5);
  assign defined_sideband[1] = ~(net_1_207 & net_1_208);
  assign net_1_208 = (net_1_209 & net_1_210);
  assign net_1_210 = ~(raw_encoding_i[28] & net_1_211);
  assign net_1_211 = (net_1_212 | net_1_213);
  assign net_1_213 = (net_1_201 | net_1_214);
  assign net_1_214 = (net_1_215 | net_1_109);
  assign net_1_215 = (net_1_216 | net_1_204);
  assign net_1_204 = (net_1_14 & net_1_217);
  assign net_1_217 = (net_1_218 & net_1_219);
  assign net_1_219 = ~(net_1_92 | net_1_11);
  assign net_1_218 = (net_1_189 & net_1_16);
  assign net_1_189 = ~(net_1_21 | raw_encoding_i[23]);
  assign net_1_216 = (net_1_145 & net_1_220);
  assign net_1_220 = ~(raw_encoding_i[23] ^ raw_encoding_i[21]);
  assign net_1_201 = (net_1_221 & net_1_222);
  assign net_1_222 = ~(net_1_223 & net_1_224);
  assign net_1_224 = ~(net_1_225 & raw_encoding_i[23]);
  assign net_1_223 = ~(net_1_226 & net_1_71);
  assign net_1_226 = (net_1_63 & net_1_70);
  assign net_1_70 = ~(raw_encoding_i[26] | raw_encoding_i[22]);
  assign net_1_212 = ~(raw_encoding_i[20] | net_1_227);
  assign net_1_227 = ~(net_1_228 & net_1_229);
  assign net_1_229 = (net_1_71 & net_1_230);
  assign net_1_230 = ~(net_1_231 & net_1_232);
  assign net_1_232 = ~(net_1_63 & raw_encoding_i[22]);
  assign net_1_231 = ~(net_1_233 & net_1_234);
  assign net_1_233 = ~(raw_encoding_i[22] | net_1_235);
  assign net_1_209 = (net_1_236 | raw_encoding_i[20]);
  assign net_1_236 = ~(net_1_116 & net_1_237);
  assign net_1_237 = ~(net_1_238 & net_1_239);
  assign net_1_239 = ~(raw_encoding_i[10] & raw_encoding_i[11]);
  assign net_1_238 = (net_1_240 & net_1_241);
  assign net_1_241 = ~(raw_encoding_i[26] & net_1_242);
  assign net_1_240 = ~(net_1_33 | net_1_106);
  assign net_1_33 = (net_1_115 & net_1_243);
  assign net_1_207 = (net_1_244 | raw_encoding_i[24]);
  assign net_1_244 = (net_1_245 & net_1_246);
  assign net_1_246 = (net_1_247 | net_1_1);
  assign net_1_243 = ~(raw_encoding_i[28] | net_1_19);
  assign net_1_247 = ~(net_1_14 & net_1_248);
  assign net_1_248 = (net_1_249 & net_1_250);
  assign net_1_250 = ~(net_1_251 & net_1_252);
  assign net_1_252 = ~(net_1_253 & net_1_254);
  assign net_1_254 = ~(net_1_7 | a64_state_i);
  assign net_1_253 = (net_1_255 | net_1_187);
  assign net_1_187 = (net_1_115 & net_1_256);
  assign net_1_255 = ~(sf_bit_i | net_1_257);
  assign net_1_257 = ~(net_1_77 & net_1_258);
  assign net_1_258 = (net_1_9 & raw_encoding_i[20]);
  assign net_1_251 = (net_1_259 | net_1_260);
  assign net_1_260 = ~(net_1_77 & net_1_261);
  assign net_1_261 = ~(net_1_174 & net_1_173);
  assign net_1_173 = ~(net_1_262 & net_1_12);
  assign net_1_174 = (net_1_37 & net_1_263);
  assign net_1_263 = ~(net_1_262 & net_1_13);
  assign net_1_37 = (net_1_264 | net_1_265);
  assign net_1_265 = ~(net_1_12 & raw_encoding_i[20]);
  assign net_1_264 = ~(net_1_266 | net_1_267);
  assign net_1_267 = ~(raw_encoding_i[17] | net_1_13);
  assign net_1_245 = (net_1_268 | net_1_92);
  assign net_1_268 = (net_1_269 & net_1_270);
  assign net_1_270 = (net_1_98 | raw_encoding_i[20]);
  assign net_1_98 = ~(net_1_271 & net_1_272);
  assign net_1_272 = ~(net_1_273 & net_1_274);
  assign net_1_274 = ~(raw_encoding_i[10] & net_1_10);
  assign net_1_269 = (net_1_275 & net_1_276);
  assign net_1_276 = (net_1_277 | net_1_2);
  assign net_1_275 = (net_1_278 | net_1_9);
  assign net_1_278 = ~(net_1_279 | net_1_280);
  assign net_1_280 = (net_1_281 & net_1_282);
  assign net_1_282 = ~(net_1_283 & net_1_284);
  assign net_1_284 = (raw_encoding_i[20] | net_1_285);
  assign net_1_285 = ~(raw_encoding_i[6] & raw_encoding_i[7]);
  assign defined_sideband[0] = (net_1_286 | net_1_287);
  assign net_1_287 = (net_1_288 | net_1_289);
  assign net_1_289 = (net_1_290 | net_1_291);
  assign net_1_291 = (raw_encoding_i[28] & net_1_292);
  assign net_1_292 = (net_1_293 | net_1_294);
  assign net_1_294 = (fifth_bit_i & net_1_109);
  assign net_1_109 = (net_1_4 & net_1_295);
  assign net_1_295 = (net_1_296 | net_1_297);
  assign net_1_297 = (raw_encoding_i[23] & net_1_298);
  assign net_1_296 = ~(net_1_299 | net_1_300);
  assign net_1_300 = (net_1_301 & net_1_302);
  assign net_1_302 = (raw_encoding_i[24] | net_1_68);
  assign net_1_301 = ~(raw_encoding_i[20] & net_1_303);
  assign net_1_303 = ~(raw_encoding_i[22] & net_1_304);
  assign net_1_304 = ~(raw_encoding_i[9] & net_1_10);
  assign net_1_293 = (net_1_305 | net_1_306);
  assign net_1_306 = (net_1_307 | net_1_308);
  assign net_1_308 = (net_1_309 | net_1_143);
  assign net_1_143 = ~(net_1_310 & net_1_311);
  assign net_1_311 = ~(net_1_151 & net_1_312);
  assign net_1_312 = ~(net_1_92 | net_1_313);
  assign net_1_313 = (net_1_277 & net_1_314);
  assign net_1_314 = (net_1_68 | net_1_299);
  assign net_1_68 = ~(raw_encoding_i[9] | net_1_10);
  assign net_1_277 = ~(net_1_104 | net_1_315);
  assign net_1_104 = (raw_encoding_i[23] | net_1_316);
  assign net_1_316 = ~(raw_encoding_i[22] | net_1_299);
  assign net_1_299 = ~(raw_encoding_i[11] & net_1_69);
  assign net_1_310 = (net_1_317 & net_1_318);
  assign net_1_318 = (net_1_64 | net_1_141);
  assign net_1_141 = ~(net_1_59 & net_1_71);
  assign net_1_317 = ~(raw_encoding_i[23] & net_1_319);
  assign net_1_319 = (raw_encoding_i[21] & net_1_145);
  assign net_1_145 = (net_1_9 & net_1_3);
  assign net_1_309 = (net_1_225 & net_1_221);
  assign net_1_221 = (net_1_11 & net_1_10);
  assign net_1_225 = ~(net_1_9 | net_1_320);
  assign net_1_307 = (net_1_321 | net_1_322);
  assign net_1_322 = ~(net_1_7 | net_1_320);
  assign net_1_320 = (raw_encoding_i[27] | net_1_323);
  assign net_1_323 = ~(raw_encoding_i[25] & net_1_324);
  assign net_1_324 = ~(raw_encoding_i[24] | raw_encoding_i[15]);
  assign net_1_321 = (net_1_116 & net_1_325);
  assign net_1_325 = (net_1_106 & raw_encoding_i[20]);
  assign net_1_106 = ~(raw_encoding_i[6] | net_1_273);
  assign net_1_273 = (raw_encoding_i[10] | raw_encoding_i[11]);
  assign net_1_305 = (net_1_71 & net_1_326);
  assign net_1_326 = (net_1_327 | net_1_45);
  assign net_1_45 = ~(raw_encoding_i[26] | net_1_328);
  assign net_1_328 = (net_1_329 | a64_state_i);
  assign net_1_329 = (net_1_64 & net_1_330);
  assign net_1_330 = (net_1_8 | net_1_18);
  assign net_1_327 = ~(raw_encoding_i[22] | net_1_331);
  assign net_1_331 = ~(net_1_332 | net_1_333);
  assign net_1_333 = ~(net_1_52 | raw_encoding_i[7]);
  assign net_1_52 = ~(net_1_334 & net_1_335);
  assign net_1_335 = (raw_encoding_i[20] & net_1_228);
  assign net_1_334 = (net_1_336 | net_1_337);
  assign net_1_337 = (raw_encoding_i[5] & net_1_19);
  assign net_1_332 = ~(raw_encoding_i[20] | net_1_338);
  assign net_1_338 = ~(net_1_339 | net_1_340);
  assign net_1_340 = (net_1_63 & net_1_59);
  assign net_1_59 = ~(raw_encoding_i[26] | raw_encoding_i[21]);
  assign net_1_63 = ~(net_1_18 | a64_state_i);
  assign net_1_339 = (net_1_341 | net_1_342);
  assign net_1_342 = (net_1_343 & net_1_344);
  assign net_1_344 = (net_1_55 & net_1_115);
  assign net_1_343 = (net_1_58 & net_1_345);
  assign net_1_58 = (net_1_346 & net_1_234);
  assign net_1_346 = (net_1_347 & net_1_348);
  assign net_1_348 = ~(raw_encoding_i[11] | net_1_349);
  assign net_1_349 = (raw_encoding_i[4] | net_1_350);
  assign net_1_350 = ~(raw_encoding_i[16] & raw_encoding_i[26]);
  assign net_1_347 = ~(raw_encoding_i[21] | net_1_351);
  assign net_1_351 = (raw_encoding_i[5] | net_1_352);
  assign net_1_352 = ~(net_1_266 & raw_encoding_i[19]);
  assign net_1_266 = (raw_encoding_i[17] & raw_encoding_i[18]);
  assign net_1_341 = (net_1_235 & net_1_353);
  assign net_1_353 = (net_1_228 & net_1_234);
  assign net_1_234 = ~(raw_encoding_i[9] | net_1_69);
  assign net_1_228 = ~(raw_encoding_i[26] | net_1_10);
  assign net_1_235 = ~(net_1_115 & net_1_354);
  assign net_1_354 = ~(raw_encoding_i[4] | net_1_355);
  assign net_1_355 = (raw_encoding_i[5] | net_1_356);
  assign net_1_356 = ~(net_1_55 & net_1_20);
  assign net_1_345 = (raw_encoding_i[0] | raw_encoding_i[1]);
  assign net_1_55 = ~(raw_encoding_i[3] | raw_encoding_i[2]);
  assign net_1_71 = (net_1_357 & net_1_358);
  assign net_1_358 = ~(raw_encoding_i[27] | net_1_359);
  assign net_1_359 = ~(raw_encoding_i[23] & net_1_360);
  assign net_1_360 = (raw_encoding_i[25] & raw_encoding_i[24]);
  assign net_1_357 = ~(raw_encoding_i[14] | net_1_361);
  assign net_1_361 = ~(raw_encoding_i[15] & net_1_362);
  assign net_1_362 = ~(raw_encoding_i[13] | raw_encoding_i[12]);
  assign net_1_290 = (net_1_363 & net_1_4);
  assign net_1_363 = (fifth_bit_i & net_1_364);
  assign net_1_364 = ~(net_1_94 & net_1_365);
  assign net_1_365 = (net_1_259 | raw_encoding_i[24]);
  assign net_1_94 = (net_1_366 & net_1_367);
  assign net_1_367 = ~(raw_encoding_i[22] & net_1_368);
  assign net_1_368 = ~(raw_encoding_i[28] | net_1_369);
  assign net_1_369 = ~(raw_encoding_i[24] | net_1_370);
  assign net_1_370 = ~(net_1_283 & net_1_371);
  assign net_1_371 = ~(net_1_6 | net_1_372);
  assign net_1_283 = (net_1_373 & net_1_374);
  assign net_1_374 = ~(raw_encoding_i[7] & net_1_19);
  assign net_1_373 = (raw_encoding_i[5] | net_1_115);
  assign net_1_115 = ~(raw_encoding_i[6] | raw_encoding_i[7]);
  assign net_1_366 = ~(net_1_315 & net_1_375);
  assign net_1_375 = (net_1_376 | net_1_377);
  assign net_1_377 = ~(raw_encoding_i[23] | net_1_378);
  assign net_1_378 = ~(net_1_202 & net_1_379);
  assign net_1_379 = ~(net_1_64 | net_1_69);
  assign net_1_69 = (raw_encoding_i[10] | raw_encoding_i[8]);
  assign net_1_64 = (net_1_11 | net_1_9);
  assign net_1_202 = ~(raw_encoding_i[14] | raw_encoding_i[15]);
  assign net_1_376 = (raw_encoding_i[28] & net_1_380);
  assign net_1_380 = (net_1_5 | net_1_298);
  assign net_1_298 = ~(net_1_11 | net_1_381);
  assign net_1_315 = ~(net_1_242 | net_1_21);
  assign net_1_288 = (net_1_382 | net_1_137);
  assign net_1_137 = (net_1_383 & net_1_384);
  assign net_1_384 = (net_1_385 | net_1_386);
  assign net_1_386 = ~(raw_encoding_i[28] | net_1_387);
  assign net_1_387 = ~(raw_encoding_i[20] & net_1_388);
  assign net_1_388 = (net_1_389 | raw_encoding_i[24]);
  assign net_1_389 = (net_1_390 | raw_encoding_i[21]);
  assign net_1_390 = (raw_encoding_i[5] & net_1_391);
  assign net_1_391 = (net_1_372 & raw_encoding_i[23]);
  assign net_1_372 = ~(net_1_19 | net_1_17);
  assign net_1_385 = (net_1_151 & net_1_392);
  assign net_1_392 = (net_1_279 | net_1_393);
  assign net_1_393 = ~(net_1_394 | raw_encoding_i[7]);
  assign net_1_394 = ~(net_1_336 & net_1_281);
  assign net_1_281 = (net_1_10 & raw_encoding_i[23]);
  assign net_1_336 = (net_1_18 & raw_encoding_i[6]);
  assign net_1_151 = (net_1_11 & net_1_5);
  assign net_1_383 = ~(net_1_92 | net_1_9);
  assign net_1_382 = (raw_encoding_i[20] & net_1_395);
  assign net_1_395 = (net_1_29 | net_1_206);
  assign net_1_206 = (net_1_6 & net_1_150);
  assign net_1_150 = ~(raw_encoding_i[11] | net_1_396);
  assign net_1_396 = ~(net_1_4 & net_1_168);
  assign net_1_168 = (net_1_271 & net_1_84);
  assign net_1_84 = ~(raw_encoding_i[10] & raw_encoding_i[21]);
  assign net_1_271 = (raw_encoding_i[28] & net_1_397);
  assign net_1_397 = (net_1_9 & net_1_17);
  assign net_1_92 = ~(raw_encoding_i[27] & net_1_161);
  assign net_1_161 = ~(raw_encoding_i[25] | raw_encoding_i[26]);
  assign net_1_29 = (net_1_110 & net_1_398);
  assign net_1_398 = (net_1_118 | net_1_34);
  assign net_1_34 = (raw_encoding_i[26] & net_1_116);
  assign net_1_116 = (net_1_179 & net_1_183);
  assign net_1_183 = (net_1_144 & net_1_256);
  assign net_1_256 = ~(raw_encoding_i[25] | net_1_9);
  assign net_1_179 = (raw_encoding_i[27] & net_1_5);
  assign net_1_118 = (net_1_159 & raw_encoding_i[27]);
  assign net_1_286 = ~(raw_encoding_i[20] | net_1_399);
  assign net_1_399 = ~(net_1_400 & net_1_14);
  assign net_1_110 = (raw_encoding_i[10] | net_1_242);
  assign net_1_242 = ~(raw_encoding_i[9] & raw_encoding_i[11]);
  assign net_1_400 = (net_1_401 | net_1_402);
  assign net_1_402 = (net_1_40 & net_1_403);
  assign net_1_403 = ~(net_1_13 ^ raw_encoding_i[19]);
  assign net_1_40 = (net_1_249 & net_1_404);
  assign net_1_404 = (net_1_39 & net_1_262);
  assign net_1_262 = ~(raw_encoding_i[17] | raw_encoding_i[18]);
  assign net_1_39 = (net_1_159 & net_1_405);
  assign net_1_405 = ~(raw_encoding_i[28] | net_1_259);
  assign net_1_259 = (net_1_6 | net_1_8);
  assign net_1_381 = ~(net_1_10 | net_1_9);
  assign net_1_401 = (net_1_159 & net_1_406);
  assign net_1_406 = (net_1_407 & net_1_279);
  assign net_1_279 = (net_1_2 & net_1_144);
  assign net_1_144 = ~(raw_encoding_i[23] | raw_encoding_i[21]);
  assign net_1_407 = ~(raw_encoding_i[22] | net_1_408);
  assign net_1_408 = ~(net_1_249 & net_1_409);
  assign net_1_409 = ~(a64_state_i | sf_bit_i);
  assign net_1_249 = (raw_encoding_i[27] & net_1_16);
  assign net_1_159 = ~(raw_encoding_i[24] | net_1_410);
  assign net_1_410 = ~(net_1_77 & raw_encoding_i[4]);
  assign net_1_77 = (raw_encoding_i[25] & raw_encoding_i[26]);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
