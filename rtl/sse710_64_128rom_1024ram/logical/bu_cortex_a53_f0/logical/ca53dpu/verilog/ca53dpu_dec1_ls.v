//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2012-10-11 09:50:44 +0100 (Thu, 11 Oct 2012) $
//
//      Revision            : $Revision: 225013 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Dual issue decoder
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// This block decodes IQ slot1 instructions that can be dual issued in
// parallel with IQ slot0 instructions.
//
//-----------------------------------------------------------------------------


`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_dec1_ls (
  // Inputs
  input  wire                      [32:0] iq_instr_dec1_ls_i,
  input  wire                       [5:0] iq_instr_sideband_i,
  input  wire                             aarch64_state_i,
  input  wire                       [1:0] pdtype_i,
  // Outputs
  output wire                             rf_rd_en_r0_dec1_ls_o,
  output wire                             rf_rd_en_r1_dec1_ls_o,
  output wire                             rf_rd_en_r2_dec1_ls_o,
  output wire    [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_dec1_ls_o,
  output wire    [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_dec1_ls_o,
  output wire    [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r2_dec1_ls_o,
  output wire                       [4:0] rf_wr_vaddr_w0_dec1_ls_o,
  output wire                       [4:0] rf_wr_vaddr_w1_dec1_ls_o,
  output wire                             rf_wr_en_w0_dec1_ls_o,
  output wire                             rf_wr_en_w1_dec1_ls_o,
  output wire                             rf_wr_64b_w0_dec1_ls_o,
  output wire                             rf_wr_64b_w1_dec1_ls_o,
  output wire  [`CA53_RF_WR_SRC_W0_W-1:0] rf_wr_src_w0_dec1_ls_o,
  output wire  [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_dec1_ls_o,
  output wire    [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w0_dec1_ls_o,
  output wire    [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_dec1_ls_o,
  output wire     [`CA53_SEL_SHF_A_W-1:0] dp_data_a_sel_dec1_ls_o,
  output wire     [`CA53_SEL_SHF_B_W-1:0] dp_data_b_sel_dec1_ls_o,
  output wire     [`CA53_SEL_SHF_C_W-1:0] dp_data_c_sel_dec1_ls_o,
  output wire     [`CA53_SEL_STR_A_W-1:0] str_data_a_sel_dec1_ls_o,
  output wire     [`CA53_SEL_STR_B_W-1:0] str_data_b_sel_dec1_ls_o,
  output wire                             str1_sel_dec1_ls_o,
  output wire     [`CA53_SEL_STR_A_W-1:0] str1_data_a_sel_dec1_ls_o,
  output wire     [`CA53_SEL_STR_B_W-1:0] str1_data_b_sel_dec1_ls_o,
  output wire                             str_b_valid_dec1_ls_o,
  output wire                             ctl_64bit_op_str_dec1_ls_o,
  output wire     [`CA53_SEL_DCU_A_W-1:0] agu_data_a_sel_dec1_ls_o,
  output wire     [`CA53_SEL_DCU_B_W-1:0] agu_data_b_sel_dec1_ls_o,
  output wire                             req_strict_algn_dec1_ls_o,
  output wire                             check_x64_dec1_ls_o,
  output wire                       [2:0] algn_size_dec1_ls_o,
  output wire                             ls_store_dec1_ls_o,
  output wire                       [1:0] ls_elem_size_dec1_ls_o,
  output wire                       [2:0] ls_size_dec1_ls_o,
  output wire                       [4:0] ls_length_dec1_ls_o,
  output wire                             force_usr_priv_mem_dec1_ls_o,
  output wire                       [1:0] agu_shf_value_dec1_ls_o,
  output wire                             agu_sub_b_dec1_ls_o,
  output wire [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_dec1_ls_o,
  output wire                       [4:0] ls_synd_srt_dec1_ls_o,
  output wire                             ls_isv_set_dec1_ls_o,
  output wire                             ls_synd_sf_dec1_ls_o,
  output wire       [`CA53_EX_PIPE_W-1:0] ex_pipe_dec1_ls_o,
  output wire      [`CA53_IMM_DATA_W-1:0] imm_data_dec1_ls_o,
  output wire     [`CA53_IMM_SHIFT_W-1:0] imm_shift_dec1_ls_o,
  output wire   [`CA53_ALU_PIPECTL_W-1:0] alu_pipectl_dec1_ls_o,
  output wire                             word_align_pc_dec1_ls_o,
  output wire                             head_instr_dec1_ls_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg     [`CA53_ALU_EX1_CTL_W-1:0] alu_ex1_ctl;
  reg     [`CA53_ALU_EX2_CTL_W-1:0] alu_ex2_ctl;
  reg     [`CA53_ALU_GEN_CTL_W-1:0] dp_gen_ctl;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                              thumb_execution;
  wire                              arm_execution;
  wire                              set_19_16_i;
  wire                              set_15_12_i;
  wire                              set_11_8_i;
  wire                              set_3_0_i;
  wire                              top_11_8;
  wire                              set_19_16_as_r31;
  wire                              set_15_12_as_r31;
  wire                              set_11_8_as_r31;
  wire                              set_3_0_as_r31;
  wire                              a64_only;
  wire                              a32_only;
  wire                              cc_never;
  wire                              sf_bit;
  wire                              d_bit;
  wire                              top_19_16;
  wire                              top_15_12;
  wire                              reg_access_64bit_dec1_ls;
  wire                        [3:0] rf_rd_ctl_r0_dec1_ls;
  wire                        [3:0] rf_rd_ctl_r1_dec1_ls;
  wire                        [3:0] rf_rd_ctl_r2_dec1_ls;
  wire     [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_dec1_ls;
  wire     [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_dec1_ls;
  wire     [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r2_dec1_ls;
  wire                       [12:0] rf_wr_ctl_w0_dec1_ls;
  wire                       [12:0] rf_wr_ctl_w1_dec1_ls;
  wire   [`CA53_RF_WR_SRC_W0_W-1:0] rf_wr_src_w0_dec1_ls;
  wire   [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_dec1_ls;
  wire     [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w0_dec1_ls;
  wire     [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_dec1_ls;
  wire      [`CA53_SEL_SHF_A_W-1:0] dp_data_a_sel_dec1_ls;
  wire      [`CA53_SEL_SHF_B_W-1:0] dp_data_b_sel_dec1_ls;
  wire      [`CA53_SEL_SHF_C_W-1:0] dp_data_c_sel_dec1_ls;
  wire      [`CA53_SEL_STR_A_W-1:0] str_data_a_sel_dec1_ls;
  wire      [`CA53_SEL_STR_B_W-1:0] str_data_b_sel_dec1_ls;
  wire                        [9:0] imm_sel_ls_dec1_ls;
  wire                        [2:0] ex1_ctl_shift_op_dec1_ls;
  wire                        [1:0] ex2_ctl_op_comp_dec1_ls;
  wire                        [3:0] ex2_ctl_au_carry_lu_dec1_ls;
  wire                              word_align_pc_dec1_ls;
  wire                              head_instr_dec1_ls;

  wire      [`CA53_SEL_DCU_A_W-1:0] agu_data_a_sel_dec1_ls;
  wire      [`CA53_SEL_DCU_B_W-1:0] agu_data_b_sel_dec1_ls;
  wire                              req_strict_algn_dec1_ls;
  wire                              check_x64_dec1_ls;
  wire                        [2:0] algn_size_dec1_ls;
  wire                              ls_store_dec1_ls;
  wire                        [1:0] ls_elem_size_dec1_ls;
  wire                        [2:0] ls_size_dec1_ls;
  wire                        [4:0] ls_length_dec1_ls;
  wire                              force_usr_priv_mem_dec1_ls;
  wire                        [1:0] agu_shf_value_dec1_ls;
  wire                              agu_sub_b_dec1_ls;
  wire                              isv_set_dec1_ls;
  wire  [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_dec1_ls;
  wire                              str1_sel_dec1_ls;
  wire                              alu_valid_dec1_ls;
  wire                              mac_valid_dec1_ls;
  wire                              br_valid_dec1_ls;
  wire                              dcu_valid_dec1_ls;
  wire                              div_valid_dec1_ls;
  wire                              str_valid_dec1_ls;
  wire                              suppress_writeback;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Input signals for espresso equations (non-registered)
  // ------------------------------------------------------

  assign thumb_execution  = pdtype_i[1];
  assign arm_execution    = ~aarch64_state_i & ~thumb_execution;
  assign set_19_16_i      = (iq_instr_dec1_ls_i[19:16] == 4'b1111) & ~aarch64_state_i;
  assign set_15_12_i      = (iq_instr_dec1_ls_i[15:12] == 4'b1111) & ~aarch64_state_i;
  assign set_11_8_i       = (iq_instr_dec1_ls_i[11:8]  == 4'b1111) & ~aarch64_state_i;
  assign set_3_0_i        = (iq_instr_dec1_ls_i[3:0]   == 4'b1111) & ~aarch64_state_i;
  assign top_11_8         = `CA53_R11_8_TOP(iq_instr_sideband_i, iq_instr_dec1_ls_i) & aarch64_state_i;
  assign set_19_16_as_r31 = ({iq_instr_dec1_ls_i[30], iq_instr_dec1_ls_i[19:16]} == 5'b11111) & aarch64_state_i;
  assign set_15_12_as_r31 = ({iq_instr_dec1_ls_i[29], iq_instr_dec1_ls_i[15:12]} == 5'b11111) & aarch64_state_i;
  assign set_11_8_as_r31  = ({top_11_8,               iq_instr_dec1_ls_i[11:8]}  == 5'b11111) & aarch64_state_i;
  assign set_3_0_as_r31   = ({iq_instr_dec1_ls_i[31], iq_instr_dec1_ls_i[3:0]}   == 5'b11111) & aarch64_state_i;
  assign cc_never         = (iq_instr_dec1_ls_i[32:29] == 4'b1111) & ~aarch64_state_i & ~thumb_execution;
  assign sf_bit           = iq_instr_dec1_ls_i[32] & aarch64_state_i;
  assign d_bit            = iq_instr_dec1_ls_i[29] & aarch64_state_i;
  assign a64_only         = (pdtype_i == 2'b01) &  aarch64_state_i;
  assign a32_only         = (pdtype_i == 2'b01) & ~aarch64_state_i;

  // ------------------------------------------------------
  // Start automatically generated logic
  // ------------------------------------------------------

  wire    net_1, net_2,
         net_3, net_4, net_5, net_6, net_7, net_8, net_10, net_11, net_12,
         net_13, net_14, net_15, net_16, net_17, net_18, net_19, net_20,
         net_21, net_22, net_23, net_25, net_26, net_27, net_28, net_29,
         net_30, net_31, net_32, net_33, net_34, net_35, net_36, net_37,
         net_38, net_39, net_40, net_42, net_43, net_44, net_45, net_47,
         net_48, net_49, net_50, net_51, net_53, net_56, net_57, net_58,
         net_61, net_62, net_63, net_64, net_65, net_66, net_67, net_68,
         net_69, net_70, net_71, net_72, net_73, net_74, net_75, net_76,
         net_77, net_78, net_79, net_80, net_81, net_82, net_83, net_84,
         net_85, net_86, net_87, net_88, net_89, net_90, net_91, net_92,
         net_93, net_94, net_95, net_96, net_97, net_98, net_99, net_100,
         net_101, net_102, net_103, net_104, net_105, net_106, net_107,
         net_108, net_109, net_110, net_111, net_112, net_113, net_114,
         net_115, net_116, net_117, net_118, net_119, net_120, net_121,
         net_122, net_123, net_124, net_125, net_126, net_127, net_128,
         net_129, net_130, net_131, net_132, net_133, net_134, net_135,
         net_136, net_137, net_138, net_139, net_140, net_141, net_142,
         net_143, net_144, net_145, net_146, net_147, net_148, net_149,
         net_150, net_151, net_152, net_153, net_154, net_155, net_156,
         net_157, net_158, net_159, net_160, net_161, net_162, net_163,
         net_164, net_165, net_166, net_167, net_168, net_169, net_170,
         net_171, net_172, net_173, net_174, net_175, net_176, net_177,
         net_178, net_179, net_180, net_181, net_182, net_183, net_184,
         net_185, net_186, net_187, net_188, net_189, net_190, net_191,
         net_192, net_193, net_194, net_195, net_196, net_197, net_198,
         net_199, net_200, net_201, net_202, net_203, net_204, net_205,
         net_206, net_207, net_208, net_209, net_210, net_211, net_212,
         net_213, net_214, net_215, net_216, net_217, net_218, net_219,
         net_220, net_221, net_222, net_223, net_224, net_225, net_226,
         net_227, net_228, net_229, net_230, net_231, net_232, net_233,
         net_234, net_235, net_236, net_237, net_238, net_239, net_240,
         net_241, net_242, net_243, net_244, net_245, net_246, net_247,
         net_248, net_249, net_250, net_251, net_252, net_253, net_254,
         net_255, net_256, net_257, net_258, net_259, net_260, net_261,
         net_262, net_263, net_264, net_265, net_266, net_267, net_268,
         net_269, net_270, net_271, net_272, net_273, net_274, net_275,
         net_276, net_277, net_278, net_279, net_280, net_281, net_282,
         net_283, net_284, net_285, net_286, net_287, net_288, net_289,
         net_290, net_291, net_292, net_293, net_294, net_295, net_296,
         net_297, net_298, net_299, net_300, net_301, net_302, net_303,
         net_304, net_305, net_306, net_307, net_308, net_309, net_310,
         net_311, net_312, net_313, net_314, net_315, net_316, net_317,
         net_318, net_319, net_320, net_321, net_322, net_323, net_324,
         net_325, net_326, net_327, net_328, net_329, net_330, net_331,
         net_332, net_333, net_334, net_335, net_336, net_337, net_338,
         net_339, net_340, net_341, net_342, net_343, net_344, net_345,
         net_346, net_347, net_348, net_349, net_350, net_351, net_352,
         net_353, net_354, net_355, net_356, net_357, net_358, net_359,
         net_360, net_361, net_362, net_363, net_364, net_365, net_366,
         net_367, net_368, net_369, net_370, net_371, net_372, net_373,
         net_374, net_375, net_376, net_377, net_378, net_379, net_380,
         net_381, net_382, net_383, net_384, net_385, net_386, net_387,
         net_388, net_389, net_390, net_391, net_392, net_393, net_394,
         net_395, net_396, net_397, net_398, net_399, net_400, net_401,
         net_402, net_403, net_404, net_405, net_406, net_407, net_408,
         net_409, net_410, net_411, net_412, net_413, net_414, net_415,
         net_416, net_417, net_418, net_419, net_420, net_421, net_422,
         net_423, net_424, net_425, net_426, net_427, net_428, net_429,
         net_430, net_431, net_432, net_433, net_434, net_435, net_436,
         net_437, net_438, net_439, net_440, net_441, net_442, net_443,
         net_444, net_445, net_446, net_447, net_448, net_449, net_450,
         net_451, net_452, net_453, net_454, net_455, net_456, net_457,
         net_458, net_459, net_460, net_461, net_462, net_463, net_464,
         net_465, net_466, net_467, net_468, net_469, net_470, net_471,
         net_472, net_473, net_474, net_475, net_476, net_477, net_478,
         net_479, net_480, net_481, net_482, net_483, net_484, net_485,
         net_486, net_487, net_488, net_489, net_490, net_491, net_492,
         net_493, net_494, net_495, net_496, net_497, net_498, net_499,
         net_500, net_501, net_502, net_503, net_504, net_505, net_506,
         net_507, net_508, net_509, net_510, net_511, net_512, net_513,
         net_514, net_515, net_516, net_517, net_518, net_519, net_520,
         net_521, net_522, net_523, net_524, net_525, net_526, net_527,
         net_528, net_529, net_530, net_531, net_532, net_533, net_534,
         net_535, net_536, net_537, net_538, net_539, net_540, net_541,
         net_542, net_543, net_544, net_545, net_546, net_547, net_548,
         net_549, net_550, net_551, net_552, net_553, net_554, net_555,
         net_556, net_557, net_558, net_559, net_560, net_561, net_562,
         net_563, net_564, net_565, net_566, net_567, net_568, net_569,
         net_570, net_571, net_572, net_573, net_574, net_575, net_576,
         net_577, net_578, net_579, net_580, net_581, net_582, net_583,
         net_584, net_585, net_586, net_587, net_588, net_589, net_590,
         net_591, net_592, net_593, net_594, net_595, net_596, net_597,
         net_598, net_599, net_600, net_601, net_602, net_603, net_604,
         net_605, net_606, net_607, net_608, net_609, net_610, net_611,
         net_612, net_613, net_614, net_615, net_616, net_617, net_618,
         net_619, net_620, net_621, net_622, net_623, net_624, net_625,
         net_626, net_627, net_628, net_629, net_630, net_631, net_632,
         net_633, net_634, net_635, net_636, net_637, net_638, net_639,
         net_640, net_641, net_642, net_643, net_644, net_645, net_646,
         net_647, net_648, net_649, net_650, net_651, net_652, net_653,
         net_654, net_655, net_656, net_657, net_658, net_659, net_660,
         net_661, net_662, net_663, net_664, net_665, net_666, net_667,
         net_668, net_669, net_670, net_671, net_672, net_673, net_674,
         net_675, net_676, net_677, net_678, net_679, net_680, net_681,
         net_682, net_683, net_684, net_685, net_686, net_687, net_688,
         net_689, net_690, net_691, net_692, net_693, net_694, net_695,
         net_696, net_697, net_698, net_699, net_700, net_701, net_702,
         net_703, net_704, net_705, net_706, net_707, net_708, net_709,
         net_710, net_711, net_712, net_713, net_714, net_715, net_716,
         net_717, net_718, net_719, net_720, net_721, net_722, net_723,
         net_724, net_725, net_726, net_727, net_728, net_729, net_730,
         net_731, net_732, net_733, net_734, net_735, net_736, net_737,
         net_738, net_739, net_740, net_741, net_742, net_743, net_744,
         net_745, net_746, net_747, net_748, net_749, net_750, net_751,
         net_752, net_753, net_754, net_755, net_756, net_757, net_758,
         net_759, net_760, net_761, net_762, net_763, net_764, net_765,
         net_766, net_767, net_768, net_769, net_770, net_771, net_772,
         net_773, net_774, net_775, net_776, net_777, net_778, net_779,
         net_780, net_781, net_782, net_783, net_784, net_785, net_786,
         net_787, net_788, net_789, net_790, net_791, net_792, net_793,
         net_794, net_795, net_796, net_797, net_798, net_799, net_800,
         net_801, net_802, net_803, net_804, net_805, net_806, net_807,
         net_808, net_809, net_810, net_811, net_812, net_813, net_814,
         net_815, net_816, net_817, net_818, net_819, net_820, net_821,
         net_822, net_823, net_824, net_825, net_826, net_827, net_828,
         net_829, net_830, net_831, net_832, net_833, net_834, net_835,
         net_836, net_837, net_838, net_839, net_840, net_841, net_842,
         net_843, net_844, net_845, net_846, net_847, net_848, net_849,
         net_850, net_851, net_852, net_853, net_854, net_855, net_856,
         net_857, net_858, net_859, net_860, net_861, net_862, net_863,
         net_864, net_865, net_866, net_867, net_868, net_869, net_870,
         net_871, net_872, net_873, net_874, net_875, net_876, net_877,
         net_878, net_879, net_880, net_881, net_882, net_883, net_884,
         net_885, net_889, net_892, net_901, net_902, net_905, net_908,
         net_909, net_910, net_911, net_912, net_913, net_914, net_915,
         net_916, net_917, net_918, net_919, net_920, net_921, net_922,
         net_923, net_924, net_925, net_926, net_927, net_928, net_929,
         net_930, net_931, net_932, net_933, net_934, net_935, net_936,
         net_937, net_938, net_939, net_940, net_941, net_942, net_943,
         net_944, net_945, net_946, net_947, net_948, net_949, net_950,
         net_951, net_952, net_953, net_954, net_955, net_956, net_957,
         net_958, net_959, net_960, net_961, net_962, net_963, net_964,
         net_965, net_966, net_967, net_968, net_969, net_970, net_971,
         net_972, net_973, net_974, net_975, net_976, net_977, net_978,
         net_979, net_980, net_981, net_982, net_983, net_984, net_985,
         net_986, net_987, net_988, net_989, net_990, net_991, net_992,
         net_993, net_994, net_995, net_996, net_997, net_998, net_999,
         net_1000, net_1001, net_1002, net_1003, net_1004, net_1005, net_1006,
         net_1007, net_1008, net_1009, net_1010, net_1011, net_1012, net_1013,
         net_1014, net_1015, net_1016, net_1017, net_1018, net_1019, net_1020,
         net_1021, net_1022, net_1023, net_1024, net_1025, net_1026, net_1027,
         net_1028, net_1029, net_1030, net_1031, net_1032, net_1033, net_1034,
         net_1035, net_1036, net_1037, net_1038, net_1039, net_1040, net_1041,
         net_1042, net_1043, net_1044, net_1045, net_1046, net_1047, net_1048,
         net_1049, net_1050, net_1051, net_1052, net_1053, net_1054, net_1055,
         net_1056, net_1057, net_1058, net_1059, net_1060, net_1061, net_1062,
         net_1063, net_1064, net_1065, net_1066, net_1067, net_1068, net_1069,
         net_1070, net_1071, net_1072, net_1073, net_1074, net_1075, net_1076,
         net_1077, net_1078, net_1079, net_1080, net_1081, net_1082, net_1083,
         net_1084, net_1085, net_1086, net_1087, net_1088, net_1089, net_1090,
         net_1091, net_1092, net_1093, net_1094, net_1095, net_1096, net_1097,
         net_1098, net_1099, net_1100, net_1101, net_1102, net_1103, net_1104,
         net_1105, net_1106, net_1107, net_1108, net_1109, net_1110, net_1111,
         net_1112, net_1113, net_1114, net_1115, net_1116, net_1117, net_1118,
         net_1119, net_1120, net_1121, net_1122, net_1123, net_1124, net_1125,
         net_1126, net_1127, net_1128, net_1129, net_1130, net_1131, net_1132,
         net_1133, net_1134, net_1135, net_1136, net_1137, net_1138, net_1139,
         net_1140, net_1141, net_1142, net_1143, net_1144, net_1145, net_1146,
         net_1147, net_1148, net_1149, net_1150, net_1151, net_1152, net_1153,
         net_1154, net_1155, net_1156, net_1157, net_1158, net_1159, net_1160,
         net_1161, net_1162, net_1163, net_1164, net_1165, net_1166, net_1167,
         net_1168, net_1169, net_1170, net_1171, net_1172, net_1173, net_1174,
         net_1175, net_1176, net_1177, net_1178, net_1179, net_1180, net_1181,
         net_1182, net_1183, net_1184, net_1185, net_1186, net_1187, net_1188,
         net_1189, net_1190, net_1191, net_1192, net_1193, net_1194, net_1195,
         net_1196, net_1197, net_1198, net_1199, net_1200, net_1201, net_1202,
         net_1203, net_1204, net_1205, net_1206, net_1207, net_1208, net_1209,
         net_1210, net_1211, net_1212, net_1213, net_1214, net_1215, net_1216,
         net_1217, net_1218, net_1219, net_1220, net_1221, net_1222, net_1223,
         net_1224, net_1225, net_1226, net_1227, net_1228, net_1229, net_1230,
         net_1231, net_1232, net_1233, net_1234, net_1235, net_1236, net_1237,
         net_1238, net_1239, net_1240, net_1241, net_1242, net_1243, net_1244,
         net_1245, net_1246, net_1247, net_1248, net_1249, net_1250, net_1251,
         net_1252, net_1253, net_1254, net_1255, net_1256, net_1257, net_1258,
         net_1259, net_1260, net_1261, net_1262, net_1263, net_1264, net_1265,
         net_1266, net_1267, net_1268, net_1269, net_1270, net_1271, net_1272,
         net_1273, net_1274, net_1275, net_1276, net_1277, net_1278, net_1279,
         net_1280, net_1281, net_1282, net_1283, net_1284, net_1285, net_1286,
         net_1287, net_1288, net_1289, net_1290, net_1291, net_1292, net_1293,
         net_1294, net_1295, net_1296, net_1297, net_1298, net_1299, net_1300,
         net_1301, net_1302, net_1303, net_1304, net_1305, net_1306, net_1307,
         net_1308, net_1309, net_1310, net_1311, net_1312, net_1313, net_1314,
         net_1315, net_1316, net_1317, net_1318, net_1319, net_1320, net_1321,
         net_1322, net_1323, net_1324, net_1325, net_1326, net_1327, net_1328,
         net_1329, net_1330, net_1331, net_1332, net_1333, net_1334, net_1335,
         net_1336, net_1337, net_1338, net_1339, net_1340, net_1341, net_1342,
         net_1343, net_1344, net_1345, net_1346, net_1347, net_1348, net_1349,
         net_1350, net_1351, net_1352, net_1353, net_1354, net_1355, net_1356,
         net_1357, net_1358, net_1359, net_1360, net_1361, net_1362, net_1363,
         net_1364, net_1365, net_1366, net_1367, net_1368, net_1369, net_1370,
         net_1371, net_1372, net_1373, net_1374, net_1375, net_1376, net_1377,
         net_1378, net_1379, net_1380, net_1381, net_1382, net_1383, net_1384,
         net_1385, net_1386, net_1387, net_1388, net_1389, net_1390, net_1391,
         net_1392, net_1393, net_1394, net_1395, net_1396, net_1397, net_1398,
         net_1399, net_1400, net_1401, net_1402, net_1403, net_1404, net_1405,
         net_1406, net_1407, net_1408, net_1409, net_1410, net_1411, net_1412,
         net_1413, net_1414, net_1415, net_1416, net_1417, net_1418, net_1419,
         net_1420, net_1421, net_1422, net_1423, net_1424, net_1425, net_1426,
         net_1427, net_1428, net_1429, net_1430, net_1431, net_1432, net_1433,
         net_1434, net_1435, net_1436, net_1437, net_1438, net_1439, net_1440,
         net_1441, net_1442, net_1443, net_1444, net_1445, net_1446, net_1447,
         net_1448, net_1449, net_1450, net_1451, net_1452, net_1453, net_1454,
         net_1455, net_1456, net_1457, net_1458, net_1459, net_1460, net_1461,
         net_1462, net_1463, net_1464, net_1465, net_1466, net_1467, net_1468,
         net_1469, net_1470, net_1471, net_1472, net_1473, net_1474, net_1475,
         net_1476, net_1477, net_1478, net_1479, net_1480, net_1481, net_1482,
         net_1483, net_1484, net_1485, net_1486, net_1487, net_1488, net_1489,
         net_1490, net_1491, net_1492, net_1493, net_1494, net_1495, net_1496,
         net_1497, net_1498, net_1499, net_1500, net_1501, net_1502, net_1503,
         net_1504, net_1505, net_1506, net_1507, net_1508, net_1509, net_1510,
         net_1511, net_1512, net_1513, net_1514, net_1515, net_1516, net_1517,
         net_1518, net_1519, net_1520, net_1521, net_1522, net_1523, net_1524,
         net_1525, net_1526, net_1527, net_1528, net_1529, net_1530, net_1531,
         net_1532, net_1533, net_1534, net_1535, net_1536, net_1537, net_1538,
         net_1539, net_1540, net_1541, net_1542, net_1543, net_1544, net_1545,
         net_1546, net_1547, net_1548, net_1549, net_1550, net_1551, net_1552,
         net_1553, net_1554, net_1555, net_1556, net_1557, net_1558, net_1559,
         net_1560, net_1561, net_1562, net_1563, net_1564, net_1565, net_1566,
         net_1567, net_1568, net_1569, net_1570, net_1571, net_1572, net_1573,
         net_1574, net_1575, net_1576, net_1577, net_1578, net_1579, net_1580,
         net_1581, net_1582, net_1583, net_1584, net_1585, net_1586, net_1587,
         net_1588, net_1589, net_1590, net_1591, net_1592, net_1593, net_1594,
         net_1595, net_1596, net_1597, net_1598, net_1599, net_1600, net_1601,
         net_1602, net_1603, net_1604, net_1605, net_1606, net_1607, net_1608,
         net_1609, net_1610, net_1611, net_1612, net_1613, net_1614, net_1615,
         net_1616, net_1617, net_1618, net_1619, net_1620, net_1621, net_1622,
         net_1623, net_1624, net_1625, net_1626, net_1627, net_1628, net_1629,
         net_1630, net_1631, net_1632, net_1633, net_1634, net_1635, net_1636,
         net_1637, net_1638, net_1639, net_1640, net_1641;

  assign rf_rd_need_r0_dec1_ls[1] = rf_rd_need_r0_dec1_ls[2];
  assign agu_data_a_sel_dec1_ls[0] = rf_rd_need_r0_dec1_ls[2];
  assign rf_rd_need_r0_dec1_ls[0] = rf_rd_need_r0_dec1_ls[2];
  assign rf_wr_ctl_w0_dec1_ls[0] = rf_wr_ctl_w0_dec1_ls[2];
  assign rf_wr_when_w0_dec1_ls[0] = rf_wr_when_w0_dec1_ls[1];
  assign rf_wr_src_w0_dec1_ls[0] = rf_wr_when_w0_dec1_ls[1];
  assign rf_wr_ctl_w1_dec1_ls[0] = rf_wr_ctl_w1_dec1_ls[1];
  assign rf_wr_src_w1_dec1_ls[0] = rf_wr_when_w1_dec1_ls[0];
  assign ls_size_dec1_ls[2] = str_data_b_sel_dec1_ls[0];
  assign ls_length_dec1_ls[2] = str_data_b_sel_dec1_ls[0];
  assign algn_size_dec1_ls[0] = ls_elem_size_dec1_ls[0];
  assign ex2_ctl_au_carry_lu_dec1_ls[0] = ex2_ctl_op_comp_dec1_ls[1];
  assign str_data_a_sel_dec1_ls[1] = 1'b0;
  assign rf_wr_when_w1_dec1_ls[2] = 1'b0;
  assign rf_wr_when_w1_dec1_ls[1] = 1'b0;
  assign rf_wr_src_w1_dec1_ls[2] = 1'b0;
  assign rf_wr_src_w1_dec1_ls[1] = 1'b0;
  assign rf_wr_src_w0_dec1_ls[2] = 1'b0;
  assign rf_wr_src_w0_dec1_ls[1] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ls[9] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ls[8] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ls[7] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ls[6] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ls[5] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ls[4] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ls[3] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ls[2] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ls[12] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ls[10] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ls[9] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ls[8] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ls[7] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ls[6] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ls[5] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ls[4] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ls[3] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ls[1] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ls[10] = 1'b0;
  assign rf_rd_need_r2_dec1_ls[2] = 1'b0;
  assign rf_rd_need_r2_dec1_ls[1] = 1'b0;
  assign rf_rd_need_r2_dec1_ls[0] = 1'b0;
  assign rf_rd_ctl_r2_dec1_ls[3] = 1'b0;
  assign rf_rd_ctl_r1_dec1_ls[3] = 1'b0;
  assign rf_rd_ctl_r0_dec1_ls[3] = 1'b0;
  assign mac_valid_dec1_ls = 1'b0;
  assign ls_length_dec1_ls[4] = 1'b0;
  assign ls_length_dec1_ls[3] = 1'b0;
  assign imm_sel_ls_dec1_ls[9] = 1'b0;
  assign imm_sel_ls_dec1_ls[7] = 1'b0;
  assign imm_sel_ls_dec1_ls[6] = 1'b0;
  assign imm_sel_ls_dec1_ls[0] = 1'b0;
  assign ex2_ctl_op_comp_dec1_ls[0] = 1'b0;
  assign ex2_ctl_au_carry_lu_dec1_ls[3] = 1'b0;
  assign ex2_ctl_au_carry_lu_dec1_ls[2] = 1'b0;
  assign ex2_ctl_au_carry_lu_dec1_ls[1] = 1'b0;
  assign dp_data_c_sel_dec1_ls[0] = 1'b0;
  assign dp_data_b_sel_dec1_ls[2] = 1'b0;
  assign dp_data_a_sel_dec1_ls[1] = 1'b0;
  assign div_valid_dec1_ls = 1'b0;
  assign br_valid_dec1_ls = 1'b0;
  assign algn_size_dec1_ls[2] = 1'b0;
  assign agu_data_b_sel_dec1_ls[6] = 1'b0;
  assign agu_data_b_sel_dec1_ls[3] = 1'b0;
  assign agu_data_b_sel_dec1_ls[2] = 1'b0;
  assign head_instr_dec1_ls = 1'b1;
  assign net_1 = ~net_348;
  assign net_2 = ~net_464;
  assign net_3 = ~net_732;
  assign net_4 = ~set_19_16_i;
  assign net_5 = ~net_302;
  assign net_6 = ~net_1066;
  assign net_7 = ~set_15_12_i;
  assign net_8 = ~net_1198;
  assign net_10 = ~net_344;
  assign net_11 = ~set_3_0_as_r31;
  assign net_12 = ~a64_only;
  assign net_13 = ~net_369;
  assign net_14 = ~a32_only;
  assign net_15 = ~net_110;
  assign net_16 = ~net_293;
  assign net_17 = ~aarch64_state_i;
  assign net_18 = ~net_210;
  assign net_19 = ~cc_never;
  assign net_20 = ~net_437;
  assign net_21 = ~net_545;
  assign net_22 = ~net_105;
  assign net_23 = ~net_809;
  assign net_25 = ~net_238;
  assign net_26 = ~net_1191;
  assign net_27 = ~net_149;
  assign net_28 = ~net_707;
  assign net_29 = ~net_277;
  assign net_30 = ~net_460;
  assign net_31 = ~net_675;
  assign net_32 = ~iq_instr_dec1_ls_i[26];
  assign net_33 = ~net_1158;
  assign net_34 = ~net_1057;
  assign net_35 = ~net_446;
  assign net_36 = ~net_459;
  assign net_37 = ~net_1221;
  assign net_38 = ~net_701;
  assign net_39 = ~net_959;
  assign net_40 = ~net_813;
  assign net_42 = ~net_715;
  assign net_43 = ~net_148;
  assign net_44 = ~net_214;
  assign net_45 = ~net_164;
  assign net_47 = ~net_92;
  assign net_48 = ~net_299;
  assign net_49 = ~net_892;
  assign net_50 = ~net_769;
  assign net_51 = ~net_109;
  assign net_53 = ~net_179;
  assign net_56 = ~iq_instr_dec1_ls_i[11];
  assign net_57 = ~iq_instr_dec1_ls_i[10];
  assign net_58 = ~iq_instr_dec1_ls_i[9];
  assign word_align_pc_dec1_ls = (thumb_execution & net_61);
  assign net_61 = ~(net_62 & net_63);
  assign net_63 = (net_64 | net_25);
  assign net_64 = (net_65 & net_66);
  assign net_66 = ~(net_67 & net_47);
  assign net_65 = (net_5 | net_68);
  assign net_68 = (net_69 | iq_instr_dec1_ls_i[22]);
  assign net_69 = (net_57 & net_1638);
  assign str_data_b_sel_dec1_ls[2] = (net_70 | net_71);
  assign net_71 = (net_72 | req_strict_algn_dec1_ls);
  assign str_data_b_sel_dec1_ls[1] = (net_73 | req_strict_algn_dec1_ls);
  assign str_data_a_sel_dec1_ls[2] = ~(net_74 & net_75);
  assign net_75 = (net_23 | net_76);
  assign net_76 = (net_77 & net_78);
  assign net_78 = ~(net_79 & net_1636);
  assign net_77 = (net_80 | net_56);
  assign net_80 = (net_81 & net_82);
  assign net_82 = (net_83 & net_84);
  assign net_84 = ~(net_85 | net_86);
  assign net_86 = (iq_instr_dec1_ls_i[28] & iq_instr_dec1_ls_i[8]);
  assign net_83 = ~(net_87 & net_88);
  assign net_88 = ~(net_58 & net_89);
  assign net_89 = ~(net_90 & net_1637);
  assign net_87 = (iq_instr_dec1_ls_i[28] | net_1637);
  assign net_81 = (net_91 | set_15_12_as_r31);
  assign net_91 = (net_92 & net_93);
  assign net_93 = (iq_instr_dec1_ls_i[10] & set_15_12_i);
  assign net_74 = ~(net_94 | net_95);
  assign net_95 = (net_96 | net_97);
  assign net_97 = (net_98 | net_99);
  assign net_99 = ~(net_100 & net_101);
  assign net_96 = (net_102 | net_103);
  assign net_103 = (iq_instr_dec1_ls_i[23] & net_104);
  assign net_104 = (net_105 | net_106);
  assign net_106 = ~(net_107 | iq_instr_dec1_ls_i[25]);
  assign net_102 = (net_39 & net_108);
  assign net_108 = (net_109 & net_110);
  assign net_94 = ~(net_111 & net_112);
  assign net_111 = ~(net_113 | net_114);
  assign net_114 = ~(net_115 & net_116);
  assign str_data_a_sel_dec1_ls[0] = ~(net_117 & net_118);
  assign net_118 = (net_119 | net_120);
  assign net_120 = ~(iq_instr_dec1_ls_i[24] & net_105);
  assign net_117 = (net_121 & net_122);
  assign net_122 = ~(net_123 & net_124);
  assign net_121 = ~(net_125 | net_126);
  assign net_126 = ~(net_127 & net_128);
  assign net_128 = (iq_instr_dec1_ls_i[20] | net_129);
  assign net_129 = (net_130 & net_131);
  assign net_131 = (net_34 | net_1636);
  assign net_130 = ~(net_132 | net_133);
  assign rf_wr_when_w0_dec1_ls[2] = (net_134 | net_135);
  assign net_135 = (net_136 | net_137);
  assign net_137 = (net_138 | net_139);
  assign net_139 = ~(net_140 & net_141);
  assign net_141 = ~(net_142 & net_143);
  assign net_140 = (net_144 | net_145);
  assign net_144 = ~(net_146 | net_147);
  assign net_147 = ~(net_8 | net_148);
  assign net_136 = (net_149 & net_150);
  assign net_150 = (net_151 | net_152);
  assign net_152 = (net_153 | net_154);
  assign net_154 = ~(net_155 & net_156);
  assign net_155 = (net_157 & net_158);
  assign net_158 = (net_8 | net_159);
  assign net_157 = (net_160 & net_161);
  assign net_153 = ~(net_162 & net_163);
  assign net_163 = ~(net_146 & net_17);
  assign net_162 = ~(net_164 & net_165);
  assign net_134 = (net_166 | net_167);
  assign net_167 = ~(net_168 & net_169);
  assign net_169 = ~(net_170 | net_171);
  assign net_171 = (net_172 & net_173);
  assign net_170 = (net_19 & net_174);
  assign net_174 = (net_175 | net_176);
  assign net_176 = (net_177 & net_178);
  assign net_175 = (net_179 & net_180);
  assign rf_wr_when_w0_dec1_ls[1] = (net_181 | net_182);
  assign net_182 = (net_183 | net_184);
  assign net_184 = ~(net_185 & net_186);
  assign net_186 = (net_187 & net_188);
  assign net_188 = (net_16 | net_189);
  assign net_187 = ~(net_190 | net_191);
  assign net_191 = ~(net_192 & net_193);
  assign net_193 = (net_62 & net_194);
  assign net_192 = (net_195 & net_196);
  assign net_196 = (net_197 | net_27);
  assign net_195 = (net_198 | net_199);
  assign net_181 = (net_200 | net_201);
  assign net_201 = (net_202 | net_203);
  assign net_203 = ~(net_204 & net_205);
  assign net_205 = ~(net_206 | net_207);
  assign net_207 = ~(net_208 & net_209);
  assign net_209 = (net_18 | net_30);
  assign net_208 = (net_211 & net_212);
  assign net_212 = ~(net_213 & net_214);
  assign net_211 = ~(net_215 & net_216);
  assign net_202 = (set_15_12_as_r31 & net_217);
  assign net_217 = (net_218 | net_219);
  assign net_219 = ~(net_220 | net_221);
  assign net_220 = (net_222 & net_223);
  assign net_223 = (set_19_16_i | net_58);
  assign net_218 = ~(net_145 | net_224);
  assign net_224 = ~(net_225 | net_226);
  assign net_226 = (net_47 & net_227);
  assign net_200 = (net_228 | net_229);
  assign net_229 = (net_138 | net_230);
  assign net_230 = (net_231 | net_232);
  assign net_232 = ~(net_233 & net_234);
  assign net_228 = (net_235 & net_236);
  assign net_236 = (net_237 & net_227);
  assign net_235 = (net_238 & net_239);
  assign net_239 = ~(net_240 & net_241);
  assign net_241 = ~(iq_instr_dec1_ls_i[22] & set_19_16_as_r31);
  assign rf_wr_ctl_w1_dec1_ls[11] = (net_242 | net_243);
  assign net_242 = (set_19_16_i & net_190);
  assign rf_wr_ctl_w1_dec1_ls[1] = ~(net_244 & net_245);
  assign net_244 = (net_246 & net_247);
  assign net_247 = ~(iq_instr_dec1_ls_i[21] & net_248);
  assign net_248 = (net_249 | net_250);
  assign net_250 = (net_251 | net_252);
  assign net_251 = (net_253 & set_15_12_i);
  assign net_249 = ~(net_254 & net_255);
  assign net_255 = ~(net_31 & net_256);
  assign net_256 = (net_1635 | net_4);
  assign net_246 = (net_257 & net_258);
  assign net_258 = (net_32 | net_259);
  assign net_257 = (net_260 & net_261);
  assign net_261 = (net_262 & net_263);
  assign net_263 = (net_264 | set_19_16_i);
  assign net_262 = ~(net_166 | net_265);
  assign net_166 = (iq_instr_dec1_ls_i[26] & net_210);
  assign net_260 = (net_266 & net_267);
  assign net_267 = (net_268 | net_269);
  assign net_266 = (net_270 & net_271);
  assign rf_wr_ctl_w0_dec1_ls[12] = (set_15_12_as_r31 & net_272);
  assign net_272 = (net_273 | net_274);
  assign net_274 = ~(net_159 | net_221);
  assign net_221 = (net_275 & net_276);
  assign net_276 = ~(net_277 & net_278);
  assign net_275 = (net_27 | iq_instr_dec1_ls_i[22]);
  assign net_273 = (net_279 | net_280);
  assign net_280 = ~(net_281 & net_282);
  assign net_282 = ~(net_283 & net_4);
  assign net_281 = (net_284 & net_285);
  assign net_284 = (net_286 & net_287);
  assign net_287 = (iq_instr_dec1_ls_i[22] | net_288);
  assign net_288 = (net_148 | net_145);
  assign net_286 = (net_289 & net_290);
  assign net_290 = (net_291 | iq_instr_dec1_ls_i[21]);
  assign net_289 = (net_13 & net_26);
  assign net_279 = (net_149 & net_292);
  assign net_292 = (net_293 & net_47);
  assign rf_wr_ctl_w0_dec1_ls[11] = (net_294 | net_295);
  assign net_295 = ~(net_296 | net_297);
  assign net_297 = (net_189 & net_298);
  assign net_298 = ~(net_149 & net_299);
  assign net_294 = ~(net_300 | net_301);
  assign net_301 = ~(net_302 & net_303);
  assign rf_wr_ctl_w0_dec1_ls[2] = ~(net_185 & net_304);
  assign net_304 = (net_305 & net_306);
  assign net_306 = (net_27 | net_307);
  assign net_307 = (net_308 & net_309);
  assign net_309 = (iq_instr_dec1_ls_i[24] | net_310);
  assign net_310 = ~(net_311 | net_312);
  assign net_311 = (net_313 | net_314);
  assign net_314 = (net_2 & net_315);
  assign net_315 = (net_316 | net_317);
  assign net_317 = (net_318 & net_92);
  assign net_316 = (net_319 | net_320);
  assign net_319 = (net_299 & net_321);
  assign net_321 = ~(aarch64_state_i & net_1638);
  assign net_313 = (net_1641 & net_322);
  assign net_322 = ~(net_323 & net_16);
  assign net_323 = ~(net_320 | net_324);
  assign net_324 = ~(net_325 & net_326);
  assign net_326 = ~(net_327 & set_19_16_as_r31);
  assign net_327 = (iq_instr_dec1_ls_i[22] & net_43);
  assign net_325 = (net_328 | iq_instr_dec1_ls_i[11]);
  assign net_328 = (net_6 & net_329);
  assign net_329 = (net_240 | iq_instr_dec1_ls_i[23]);
  assign net_308 = ~(net_330 | net_331);
  assign net_331 = ~(net_332 & net_333);
  assign net_333 = (net_156 | set_15_12_as_r31);
  assign net_332 = (net_334 & net_335);
  assign net_335 = (net_336 | net_39);
  assign net_336 = ~(net_337 & net_338);
  assign net_338 = (net_237 | net_339);
  assign net_339 = (net_340 & iq_instr_dec1_ls_i[22]);
  assign net_334 = (net_197 & net_341);
  assign net_197 = (net_342 | net_343);
  assign net_343 = ~(net_344 & net_1641);
  assign net_330 = ~(net_345 & net_346);
  assign net_346 = ~(net_347 & net_348);
  assign net_345 = (net_349 | net_350);
  assign net_305 = (net_351 & net_352);
  assign net_352 = ~(net_138 | net_353);
  assign net_353 = ~(net_354 & net_355);
  assign net_355 = (net_356 | net_357);
  assign net_357 = (net_1636 & net_358);
  assign net_358 = (cc_never | net_359);
  assign net_359 = (net_360 & net_4);
  assign net_354 = (net_361 & net_362);
  assign net_362 = (net_363 | net_364);
  assign net_364 = ~(a32_only & iq_instr_dec1_ls_i[5]);
  assign net_361 = (net_365 | set_15_12_as_r31);
  assign net_365 = (net_366 & net_367);
  assign net_367 = (net_10 | net_368);
  assign net_366 = ~(net_369 | net_370);
  assign net_370 = (net_320 & net_371);
  assign net_371 = ~(net_372 | iq_instr_dec1_ls_i[26]);
  assign net_351 = (net_373 & net_374);
  assign net_374 = (net_32 | net_363);
  assign net_373 = (net_375 & net_168);
  assign net_185 = (net_376 & net_377);
  assign net_377 = (net_378 | net_379);
  assign net_378 = (net_380 & net_381);
  assign net_381 = (net_300 | net_382);
  assign net_382 = (net_29 | set_15_12_as_r31);
  assign net_300 = (net_44 & net_45);
  assign net_380 = (net_383 | net_1640);
  assign net_383 = ~(net_384 | net_385);
  assign net_385 = (net_225 & net_2);
  assign net_384 = (net_1637 & net_386);
  assign net_386 = (net_387 | net_1641);
  assign rf_rd_need_r1_dec1_ls[2] = (net_388 | net_389);
  assign net_389 = ~(net_390 & net_391);
  assign net_390 = (net_392 & net_393);
  assign net_393 = ~(net_110 & net_394);
  assign net_394 = ~(net_395 & net_396);
  assign net_396 = (net_397 | net_269);
  assign net_395 = (net_259 & net_50);
  assign net_392 = (net_398 & net_399);
  assign net_399 = (net_400 | net_401);
  assign net_401 = (net_48 | net_7);
  assign net_398 = ~(net_165 & net_402);
  assign rf_rd_need_r1_dec1_ls[1] = (net_388 | rf_rd_need_r1_dec1_ls[0]);
  assign net_388 = (net_403 | net_404);
  assign net_404 = ~(net_405 & net_406);
  assign net_405 = ~(net_125 | net_407);
  assign rf_rd_need_r1_dec1_ls[0] = ~(net_391 & net_408);
  assign net_408 = (net_409 & net_410);
  assign net_410 = (net_271 | net_411);
  assign net_411 = (iq_instr_dec1_ls_i[5] & iq_instr_dec1_ls_i[6]);
  assign net_391 = (net_412 & net_413);
  assign net_413 = ~(net_138 & net_414);
  assign net_412 = (net_415 & net_416);
  assign rf_rd_ctl_r2_dec1_ls[2] = ~(net_417 & net_418);
  assign net_418 = ~(set_11_8_as_r31 & net_72);
  assign net_417 = ~(set_15_12_as_r31 & net_123);
  assign rf_rd_ctl_r2_dec1_ls[1] = ~(net_419 & net_420);
  assign net_420 = (net_7 | net_421);
  assign net_421 = ~(net_422 | net_423);
  assign net_423 = ~(net_424 & net_425);
  assign net_425 = (net_259 | net_30);
  assign net_419 = (net_127 & net_426);
  assign net_426 = ~(net_427 | net_428);
  assign net_428 = (set_11_8_i & net_20);
  assign rf_rd_ctl_r2_dec1_ls[0] = (net_429 | net_430);
  assign net_430 = (net_431 | net_432);
  assign net_432 = ~(net_433 & net_434);
  assign net_434 = ~(net_435 & net_436);
  assign net_433 = (net_437 | set_11_8_i);
  assign net_431 = (net_132 & net_1635);
  assign net_132 = ~(net_438 & net_198);
  assign net_198 = (net_15 | net_40);
  assign net_438 = ~(net_439 | net_440);
  assign net_440 = (net_441 & net_442);
  assign net_442 = (net_443 | net_444);
  assign net_444 = ~(net_445 | iq_instr_dec1_ls_i[22]);
  assign net_443 = (net_446 & net_237);
  assign net_429 = (net_447 | net_448);
  assign net_448 = (net_449 | net_450);
  assign net_450 = ~(net_451 & net_452);
  assign net_452 = ~(net_123 & net_453);
  assign net_453 = ~(net_454 & net_455);
  assign net_454 = (net_456 & net_457);
  assign net_457 = ~(set_3_0_as_r31 & net_1641);
  assign net_456 = ~(net_458 & net_7);
  assign net_451 = (net_112 | set_11_8_as_r31);
  assign net_449 = (net_146 & net_125);
  assign net_125 = (net_459 & net_460);
  assign net_447 = ~(net_461 & net_462);
  assign net_462 = ~(net_123 & net_463);
  assign net_463 = ~(net_119 | net_445);
  assign net_445 = (net_464 & net_465);
  assign rf_rd_ctl_r1_dec1_ls[2] = (net_466 | net_467);
  assign net_467 = ~(net_468 & net_469);
  assign net_469 = ~(set_15_12_as_r31 & net_470);
  assign net_470 = ~(net_471 & net_112);
  assign net_471 = (net_472 & net_473);
  assign net_473 = ~(net_474 & net_475);
  assign net_475 = ~(net_476 & net_22);
  assign net_472 = (net_477 | net_22);
  assign net_466 = (set_3_0_as_r31 & net_478);
  assign net_478 = (net_479 | net_123);
  assign net_479 = ~(net_480 & net_481);
  assign net_481 = (net_27 | net_482);
  assign net_480 = (net_400 | net_483);
  assign rf_rd_ctl_r1_dec1_ls[1] = (net_422 | net_484);
  assign net_484 = (net_485 | net_486);
  assign net_486 = ~(net_487 & net_116);
  assign net_487 = (net_488 & net_489);
  assign net_489 = ~(net_490 & set_3_0_i);
  assign net_490 = ~(net_400 | net_491);
  assign net_491 = ~(net_492 | net_493);
  assign net_493 = ~(net_464 | net_494);
  assign net_492 = (net_495 | net_496);
  assign net_495 = (net_11 & net_497);
  assign net_497 = (iq_instr_dec1_ls_i[22] & net_498);
  assign net_400 = ~(net_149 & net_227);
  assign net_488 = (net_499 & net_500);
  assign net_500 = ~(net_402 & net_92);
  assign net_402 = (net_148 & net_501);
  assign net_501 = (net_149 & net_58);
  assign net_499 = (net_7 | net_101);
  assign net_485 = (net_302 & net_502);
  assign net_502 = (net_503 | net_504);
  assign net_504 = ~(net_189 | net_10);
  assign net_503 = (net_70 & net_505);
  assign net_505 = ~(net_477 & net_57);
  assign net_70 = ~(net_47 | net_23);
  assign rf_rd_ctl_r1_dec1_ls[0] = ~(net_506 & net_507);
  assign net_507 = (net_508 & net_509);
  assign net_509 = ~(net_510 & net_511);
  assign net_511 = ~(net_512 & net_513);
  assign net_512 = (net_514 & net_515);
  assign net_515 = (net_516 | net_464);
  assign net_514 = (net_517 & net_518);
  assign net_518 = (set_3_0_as_r31 | net_519);
  assign net_519 = (net_520 & net_521);
  assign net_521 = ~(set_19_16_as_r31 & net_522);
  assign net_520 = (set_15_12_as_r31 | net_523);
  assign net_523 = ~(net_318 & net_178);
  assign net_517 = (net_524 & net_525);
  assign net_525 = (net_526 | iq_instr_dec1_ls_i[11]);
  assign net_526 = (net_527 & net_528);
  assign net_528 = (net_21 | net_455);
  assign net_455 = ~(set_19_16_as_r31 & net_237);
  assign net_527 = (net_529 & net_530);
  assign net_530 = (net_531 & net_532);
  assign net_532 = (net_465 | net_35);
  assign net_465 = ~(net_237 & net_4);
  assign net_531 = (net_533 & net_534);
  assign net_534 = ~(net_464 & net_535);
  assign net_535 = ~(net_536 | set_3_0_as_r31);
  assign net_536 = (net_1641 | net_372);
  assign net_533 = (net_537 & net_538);
  assign net_538 = ~(net_539 & net_4);
  assign net_537 = ~(net_540 & net_541);
  assign net_541 = (net_542 | net_543);
  assign net_542 = (net_278 | net_544);
  assign net_544 = (net_92 & net_545);
  assign net_524 = (net_546 & net_547);
  assign net_547 = ~(net_522 & net_548);
  assign net_548 = ~(set_3_0_i | net_549);
  assign net_549 = (set_3_0_as_r31 & net_464);
  assign net_522 = ~(net_474 | net_550);
  assign net_546 = ~(net_551 & net_552);
  assign net_552 = ~(net_553 & net_554);
  assign net_554 = (net_529 | net_57);
  assign net_553 = (net_555 | net_556);
  assign net_508 = ~(net_557 | net_558);
  assign net_558 = ~(net_559 & net_560);
  assign net_560 = ~(net_133 | net_561);
  assign net_559 = (net_562 & net_563);
  assign net_563 = (set_15_12_i | net_564);
  assign net_562 = (net_565 & net_566);
  assign net_566 = (net_567 & net_568);
  assign net_568 = (set_15_12_i | net_437);
  assign net_567 = (net_415 & net_569);
  assign net_569 = (set_15_12_as_r31 | net_570);
  assign net_570 = (net_571 & net_572);
  assign net_572 = ~(net_320 & net_1635);
  assign net_571 = (net_112 & net_573);
  assign net_573 = (net_574 | net_23);
  assign net_574 = ~(net_225 | net_575);
  assign net_575 = (iq_instr_dec1_ls_i[11] & net_576);
  assign net_576 = (net_577 | net_7);
  assign net_415 = (net_578 & net_579);
  assign rf_rd_ctl_r0_dec1_ls[2] = (set_19_16_as_r31 & net_580);
  assign net_580 = (arm_execution & net_581);
  assign net_581 = ~(net_582 | net_583);
  assign rf_rd_ctl_r0_dec1_ls[1] = (net_584 | net_585);
  assign net_585 = (set_19_16_i & net_586);
  assign net_586 = (net_587 | net_588);
  assign net_588 = (net_589 | net_190);
  assign net_190 = ~(net_397 | net_590);
  assign net_590 = ~(net_31 & net_39);
  assign net_589 = (net_427 | net_591);
  assign net_591 = (net_592 | net_422);
  assign net_422 = (net_123 & net_458);
  assign net_592 = (net_238 & net_312);
  assign net_312 = (net_458 & net_337);
  assign net_337 = (net_227 & net_7);
  assign net_458 = (net_92 & net_340);
  assign net_340 = (set_3_0_i & net_11);
  assign net_427 = (net_92 & net_593);
  assign net_593 = (net_123 & net_540);
  assign net_540 = ~(set_3_0_i | net_5);
  assign net_587 = ~(net_189 | net_296);
  assign net_584 = (net_2 & net_594);
  assign net_594 = (net_595 | net_596);
  assign net_596 = (iq_instr_dec1_ls_i[27] & net_597);
  assign net_597 = (net_598 | net_599);
  assign net_599 = (net_600 | net_601);
  assign net_601 = (net_56 & net_602);
  assign net_602 = (net_603 | net_604);
  assign net_604 = ~(net_49 | iq_instr_dec1_ls_i[23]);
  assign net_600 = ~(net_605 & net_606);
  assign net_606 = ~(net_58 & net_607);
  assign net_607 = (net_178 | net_608);
  assign net_608 = (net_179 & net_609);
  assign net_605 = ~(net_178 & iq_instr_dec1_ls_i[10]);
  assign net_598 = ~(net_610 & net_611);
  assign net_611 = (net_21 | net_477);
  assign net_610 = ~(net_612 | net_613);
  assign net_613 = ~(net_614 & net_516);
  assign net_516 = ~(net_318 & net_615);
  assign net_614 = (net_616 & net_617);
  assign net_617 = ~(net_618 & net_619);
  assign net_616 = (net_620 | net_47);
  assign net_620 = (net_621 & net_622);
  assign net_622 = ~(iq_instr_dec1_ls_i[20] & net_214);
  assign net_621 = (net_623 & net_624);
  assign net_624 = ~(net_320 & net_143);
  assign net_320 = ~(set_15_12_i | net_1638);
  assign net_623 = ~(iq_instr_dec1_ls_i[28] & net_619);
  assign net_612 = (iq_instr_dec1_ls_i[8] & net_178);
  assign net_595 = (net_43 & net_625);
  assign net_625 = (net_172 | net_626);
  assign net_626 = (net_609 & net_303);
  assign net_303 = (iq_instr_dec1_ls_i[22] & net_149);
  assign rf_rd_ctl_r0_dec1_ls[0] = ~(net_627 & net_628);
  assign net_628 = ~(iq_instr_dec1_ls_i[27] & net_629);
  assign net_629 = ~(net_630 & net_631);
  assign net_631 = (net_1638 | net_632);
  assign net_630 = (net_342 & net_633);
  assign net_633 = (iq_instr_dec1_ls_i[23] | net_513);
  assign net_513 = (set_3_0_as_r31 | net_634);
  assign net_634 = (net_635 & net_636);
  assign net_636 = (set_19_16_i | net_637);
  assign net_637 = (net_638 | set_15_12_as_r31);
  assign net_638 = ~(net_639 | net_640);
  assign net_640 = ~(iq_instr_dec1_ls_i[11] | net_49);
  assign net_639 = (net_318 & net_641);
  assign net_641 = (net_143 | net_545);
  assign net_635 = (net_642 | iq_instr_dec1_ls_i[11]);
  assign net_642 = (net_643 & net_644);
  assign net_644 = ~(set_19_16_as_r31 & net_543);
  assign net_643 = (net_632 & net_645);
  assign net_645 = ~(set_15_12_as_r31 & net_615);
  assign net_615 = ~(net_21 & net_368);
  assign net_627 = (net_646 & net_647);
  assign net_647 = (set_19_16_i | net_648);
  assign net_648 = (net_649 & net_650);
  assign net_650 = ~(net_510 & net_651);
  assign net_651 = (net_652 | net_653);
  assign net_653 = (net_654 | net_655);
  assign net_655 = ~(iq_instr_dec1_ls_i[11] | net_656);
  assign net_656 = ~(net_539 | net_657);
  assign net_657 = (net_545 | net_543);
  assign net_539 = (iq_instr_dec1_ls_i[20] & net_658);
  assign net_654 = ~(iq_instr_dec1_ls_i[9] | net_659);
  assign net_659 = ~(net_660 | net_661);
  assign net_661 = (net_662 & iq_instr_dec1_ls_i[10]);
  assign net_662 = (net_143 & net_302);
  assign net_660 = (net_551 & net_663);
  assign net_663 = (net_545 | net_664);
  assign net_652 = ~(set_19_16_as_r31 | net_665);
  assign net_665 = ~(net_474 & net_666);
  assign net_666 = (iq_instr_dec1_ls_i[10] & iq_instr_dec1_ls_i[28]);
  assign net_649 = (net_667 & net_668);
  assign net_668 = ~(iq_instr_dec1_ls_i[23] & net_669);
  assign net_669 = ~(iq_instr_dec1_ls_i[20] & net_189);
  assign net_667 = (net_670 & net_671);
  assign net_671 = (net_15 | net_672);
  assign net_672 = (net_38 & net_48);
  assign net_670 = (net_673 & net_674);
  assign net_674 = (net_675 | net_676);
  assign net_676 = (net_39 & net_397);
  assign net_646 = (net_677 & net_678);
  assign net_678 = ~(set_19_16_as_r31 & net_679);
  assign net_679 = (net_680 | net_681);
  assign net_681 = (net_238 & net_682);
  assign net_682 = (net_683 | net_684);
  assign net_684 = (iq_instr_dec1_ls_i[22] & net_685);
  assign net_680 = (iq_instr_dec1_ls_i[27] & net_686);
  assign net_686 = (net_1635 | net_687);
  assign net_677 = (net_688 & net_689);
  assign net_689 = (net_690 & net_691);
  assign net_691 = ~(net_692 & set_15_12_as_r31);
  assign net_690 = (net_693 & net_694);
  assign net_694 = (net_695 & net_696);
  assign net_696 = (net_697 & net_204);
  assign net_204 = (net_698 & net_270);
  assign net_698 = (net_375 & net_699);
  assign net_699 = (net_675 | net_700);
  assign net_700 = ~(net_215 | net_210);
  assign net_375 = ~(net_177 & net_215);
  assign net_215 = (net_19 & net_701);
  assign net_695 = (net_702 & net_468);
  assign net_468 = ~(set_3_0_as_r31 & net_703);
  assign net_703 = (net_441 & net_704);
  assign net_702 = (net_705 & net_706);
  assign net_706 = (net_27 | net_156);
  assign net_705 = (net_707 | net_708);
  assign net_708 = (net_2 & net_709);
  assign net_709 = (iq_instr_dec1_ls_i[23] | net_710);
  assign net_710 = ~(set_3_0_as_r31 | iq_instr_dec1_ls_i[11]);
  assign net_693 = (net_711 & net_712);
  assign net_712 = (net_713 | net_145);
  assign net_711 = (net_285 & net_714);
  assign net_285 = ~(net_715 & net_172);
  assign reg_access_64bit_dec1_ls = (net_716 | net_717);
  assign net_717 = (net_718 | net_719);
  assign net_719 = (net_720 | net_721);
  assign net_721 = ~(net_233 & net_722);
  assign net_722 = ~(sf_bit & net_723);
  assign net_723 = (net_724 | net_725);
  assign net_725 = ~(net_726 | net_727);
  assign net_727 = (net_728 & net_729);
  assign net_729 = (net_730 | net_731);
  assign net_731 = ~(set_19_16_as_r31 & iq_instr_dec1_ls_i[8]);
  assign net_728 = ~(net_225 & net_732);
  assign net_724 = ~(net_29 | net_733);
  assign net_733 = ~(net_178 | net_734);
  assign net_734 = (net_735 | net_736);
  assign net_736 = (net_737 & net_738);
  assign net_738 = (net_739 | net_740);
  assign net_740 = (net_214 & net_4);
  assign net_735 = (net_1637 & net_741);
  assign net_741 = (iq_instr_dec1_ls_i[24] & net_742);
  assign net_742 = (net_1638 & net_743);
  assign net_743 = (net_744 | net_745);
  assign net_745 = (net_732 & net_56);
  assign net_277 = ~(iq_instr_dec1_ls_i[26] | iq_instr_dec1_ls_i[25]);
  assign net_716 = (net_172 & net_746);
  assign net_746 = (net_57 | net_173);
  assign ls_store_dec1_ls = (str_valid_dec1_ls | net_747);
  assign net_747 = ~(net_748 & net_749);
  assign net_749 = (net_750 & net_751);
  assign net_751 = (net_1640 | net_752);
  assign net_752 = (net_753 & net_754);
  assign net_754 = ~(net_755 & net_756);
  assign net_756 = (net_619 & net_348);
  assign net_755 = (iq_instr_dec1_ls_i[21] & set_15_12_i);
  assign net_753 = ~(net_757 & d_bit);
  assign net_750 = (net_758 | net_759);
  assign net_758 = ~(net_760 | net_761);
  assign net_761 = ~(net_762 | iq_instr_dec1_ls_i[22]);
  assign net_762 = ~(net_31 & net_4);
  assign net_748 = (net_763 & net_764);
  assign net_764 = ~(net_765 & net_302);
  assign net_765 = ~(net_145 | net_766);
  assign net_766 = (net_767 & net_768);
  assign net_768 = ~(net_227 & net_769);
  assign net_763 = ~(net_770 & d_bit);
  assign str_valid_dec1_ls = (net_557 | net_771);
  assign net_771 = ~(net_772 & net_773);
  assign net_773 = ~(set_15_12_as_r31 & net_774);
  assign net_774 = (net_775 | net_123);
  assign net_775 = (net_105 & net_776);
  assign net_776 = ~(net_477 & net_777);
  assign net_777 = ~(iq_instr_dec1_ls_i[22] & iq_instr_dec1_ls_i[9]);
  assign net_477 = (net_1638 & net_778);
  assign net_778 = ~(iq_instr_dec1_ls_i[8] & iq_instr_dec1_ls_i[11]);
  assign net_772 = ~(net_718 | net_779);
  assign net_779 = ~(net_780 & net_781);
  assign net_781 = (net_697 & net_437);
  assign net_697 = (net_112 & net_782);
  assign net_782 = ~(net_123 & set_3_0_as_r31);
  assign net_123 = (net_545 & net_441);
  assign net_780 = (net_783 & net_784);
  assign net_784 = (net_461 & net_785);
  assign net_461 = (net_786 & net_787);
  assign net_787 = (net_30 | net_37);
  assign net_786 = (net_34 | net_788);
  assign net_788 = ~(net_109 & net_436);
  assign net_436 = ~(net_1636 & net_1639);
  assign net_783 = (net_789 & net_100);
  assign net_789 = ~(net_790 | net_791);
  assign net_791 = ~(set_15_12_as_r31 | net_792);
  assign net_792 = ~(iq_instr_dec1_ls_i[11] & net_793);
  assign net_557 = (net_794 | net_795);
  assign net_795 = (net_796 | net_797);
  assign net_797 = (net_793 & net_798);
  assign net_798 = (net_237 | net_799);
  assign net_799 = (net_685 | net_79);
  assign net_793 = (iq_instr_dec1_ls_i[27] & net_603);
  assign net_796 = (net_105 & net_387);
  assign net_387 = ~(net_173 | net_1);
  assign ls_size_dec1_ls[1] = ~(net_800 & net_13);
  assign ls_size_dec1_ls[0] = ~(net_801 & net_802);
  assign net_802 = (net_803 & net_804);
  assign net_803 = (net_805 & net_806);
  assign net_806 = ~(net_807 & net_808);
  assign net_805 = ~(net_809 & iq_instr_dec1_ls_i[21]);
  assign net_801 = (net_810 & net_811);
  assign net_810 = (net_100 & net_812);
  assign net_812 = ~(net_813 & net_142);
  assign net_100 = (net_814 & net_815);
  assign net_815 = (net_4 | net_816);
  assign net_816 = ~(net_109 & net_817);
  assign net_814 = (net_15 | net_240);
  assign net_240 = ~(net_299 & net_4);
  assign ls_length_dec1_ls[1] = (net_818 | net_819);
  assign net_819 = ~(net_804 & net_820);
  assign net_820 = ~(net_92 & net_807);
  assign net_804 = ~(net_73 | net_20);
  assign ls_length_dec1_ls[0] = (net_821 | net_822);
  assign net_822 = (net_360 | net_823);
  assign net_823 = ~(net_824 & net_825);
  assign net_825 = (net_826 & net_827);
  assign net_827 = ~(net_414 & iq_instr_dec1_ls_i[28]);
  assign net_826 = (net_828 | net_159);
  assign net_159 = (net_222 & net_829);
  assign net_829 = (set_19_16_i | net_830);
  assign net_830 = ~(iq_instr_dec1_ls_i[8] | iq_instr_dec1_ls_i[9]);
  assign net_821 = (net_113 | net_831);
  assign net_831 = (net_832 | net_833);
  assign net_833 = (net_794 | net_561);
  assign net_794 = ~(net_675 | net_107);
  assign ls_instr_type_dec1_ls[3] = ~(net_834 & net_835);
  assign net_834 = ~(net_836 | net_837);
  assign net_837 = ~(net_838 & net_707);
  assign net_838 = ~(ls_instr_type_dec1_ls[2] | net_839);
  assign net_839 = ~(net_840 & net_841);
  assign net_841 = (net_842 | net_5);
  assign net_842 = (net_843 & net_844);
  assign net_844 = (net_291 | net_50);
  assign net_291 = (iq_instr_dec1_ls_i[11] | net_145);
  assign net_843 = (net_845 & net_846);
  assign net_846 = (net_847 | net_27);
  assign net_845 = (set_19_16_i | net_848);
  assign net_848 = (net_148 | net_849);
  assign net_849 = (net_25 | iq_instr_dec1_ls_i[21]);
  assign net_840 = (net_850 & net_673);
  assign net_673 = ~(net_701 & net_851);
  assign net_850 = (net_852 | net_675);
  assign net_852 = (net_853 & net_854);
  assign net_854 = (net_38 | net_4);
  assign net_853 = ~(cc_never & net_855);
  assign net_855 = (net_737 & net_4);
  assign ls_instr_type_dec1_ls[1] = ~(net_856 & net_857);
  assign net_857 = (net_1639 | net_858);
  assign net_858 = ~(net_859 | net_860);
  assign net_860 = ~(net_302 | net_583);
  assign net_859 = ~(net_861 & net_862);
  assign net_862 = ~(net_149 & net_863);
  assign net_863 = (net_864 | net_865);
  assign net_856 = ~(net_866 | net_867);
  assign net_867 = (ls_instr_type_dec1_ls[2] | net_868);
  assign net_868 = (net_720 | net_869);
  assign net_869 = (net_172 | net_138);
  assign net_720 = (net_870 & net_1639);
  assign net_866 = ~(net_871 & net_872);
  assign net_872 = ~(net_865 & net_870);
  assign net_870 = (iq_instr_dec1_ls_i[25] & net_32);
  assign net_865 = (net_873 & iq_instr_dec1_ls_i[13]);
  assign net_871 = (net_160 | net_27);
  assign ls_instr_type_dec1_ls[0] = (iq_instr_dec1_ls_i[12] & net_874);
  assign net_874 = (net_28 | net_770);
  assign ls_elem_size_dec1_ls[1] = ~(net_875 & net_800);
  assign net_800 = ~(net_73 | net_876);
  assign net_876 = ~(net_877 & net_878);
  assign net_878 = ~(iq_instr_dec1_ls_i[27] & net_347);
  assign net_875 = ~(net_231 | net_818);
  assign isv_set_dec1_ls = ~(net_879 & net_880);
  assign net_880 = (net_881 & net_882);
  assign net_882 = (iq_instr_dec1_ls_i[8] | net_883);
  assign net_883 = (net_884 & net_885);
  assign net_510 = (iq_instr_dec1_ls_i[27] & net_1638);
  assign net_881 = ~(net_908 | net_909);
  assign net_909 = (net_441 & net_910);
  assign net_910 = (net_911 | net_178);
  assign net_911 = (net_912 | net_913);
  assign net_912 = (net_47 & net_914);
  assign net_914 = (net_237 & net_459);
  assign net_908 = ~(net_915 & net_916);
  assign net_916 = ~(net_151 & net_149);
  assign net_915 = (net_564 | net_39);
  assign net_879 = (net_917 & net_918);
  assign net_918 = (net_22 | net_919);
  assign net_919 = ~(iq_instr_dec1_ls_i[23] | net_920);
  assign net_920 = (net_318 | net_921);
  assign net_921 = ~(net_922 & net_923);
  assign net_923 = (net_924 | iq_instr_dec1_ls_i[8]);
  assign net_924 = ~(net_474 | net_925);
  assign net_925 = (net_926 & iq_instr_dec1_ls_i[22]);
  assign net_922 = (net_927 & net_928);
  assign net_928 = ~(net_56 & net_124);
  assign net_927 = ~(net_551 & net_929);
  assign net_318 = ~(iq_instr_dec1_ls_i[11] | net_119);
  assign net_917 = (net_930 & net_931);
  assign net_931 = (net_234 & net_932);
  assign net_932 = ~(net_704 & net_933);
  assign net_933 = (iq_instr_dec1_ls_i[27] & net_43);
  assign net_704 = ~(net_632 & net_368);
  assign net_368 = ~(net_143 & net_92);
  assign net_632 = (net_934 & net_935);
  assign net_935 = ~(set_15_12_as_r31 & net_936);
  assign net_936 = ~(net_397 | set_19_16_i);
  assign net_234 = ~(net_283 | net_937);
  assign net_930 = (net_938 & net_939);
  assign net_939 = (net_189 | net_940);
  assign net_940 = (net_296 & net_941);
  assign net_941 = (net_2 | net_942);
  assign net_942 = ~(net_685 | net_227);
  assign net_685 = ~(set_15_12_as_r31 | net_1638);
  assign net_296 = ~(net_302 & net_43);
  assign net_189 = ~(iq_instr_dec1_ls_i[22] & net_238);
  assign net_938 = (net_943 & net_944);
  assign net_944 = (net_945 & net_946);
  assign net_946 = (net_947 & net_62);
  assign net_947 = (net_39 | net_948);
  assign net_948 = (net_949 | iq_instr_dec1_ls_i[20]);
  assign net_949 = (net_950 & net_951);
  assign net_945 = (net_952 & net_578);
  assign net_578 = ~(net_110 & net_701);
  assign net_952 = (net_953 & net_954);
  assign net_954 = ~(net_955 & net_56);
  assign net_953 = ~(net_369 | net_561);
  assign net_943 = (net_956 | cc_never);
  assign net_956 = ~(net_957 | net_958);
  assign net_958 = (net_177 & net_959);
  assign net_177 = ~(set_19_16_i | net_34);
  assign net_957 = (net_701 & net_180);
  assign net_180 = (net_31 | net_216);
  assign net_216 = ~(net_4 | net_32);
  assign imm_sel_ls_dec1_ls[8] = (net_369 | net_770);
  assign imm_sel_ls_dec1_ls[5] = ~(net_960 & net_961);
  assign net_961 = ~(net_962 & net_12);
  assign imm_sel_ls_dec1_ls[4] = (net_963 | net_964);
  assign net_964 = (net_965 | net_966);
  assign net_965 = (iq_instr_dec1_ls_i[27] & net_967);
  assign net_967 = (net_968 | net_969);
  assign net_969 = ~(net_970 & net_971);
  assign net_971 = ~(net_79 & net_603);
  assign net_79 = (net_2 & net_347);
  assign net_970 = (thumb_execution | net_972);
  assign net_968 = (net_148 & net_973);
  assign net_973 = (net_974 | net_975);
  assign net_975 = ~(iq_instr_dec1_ls_i[8] | net_976);
  assign net_976 = (net_977 & net_889);
  assign net_889 = (net_529 & net_978);
  assign net_978 = (iq_instr_dec1_ls_i[10] | net_979);
  assign net_979 = (net_49 & net_980);
  assign net_980 = ~(aarch64_state_i & net_981);
  assign net_981 = (net_1637 | net_143);
  assign net_529 = (net_464 | net_49);
  assign net_977 = (net_982 & net_983);
  assign net_983 = ~(net_901 & net_926);
  assign net_901 = (set_19_16_as_r31 & iq_instr_dec1_ls_i[20]);
  assign net_982 = ~(net_984 | net_178);
  assign net_984 = ~(net_985 & net_986);
  assign net_986 = ~(net_348 & net_664);
  assign net_664 = ~(set_15_12_i | net_397);
  assign net_985 = (net_58 | net_49);
  assign net_974 = ~(net_987 & net_988);
  assign net_988 = ~(net_545 & net_989);
  assign net_989 = (net_990 | net_929);
  assign net_929 = ~(set_19_16_i & net_555);
  assign net_987 = (net_991 & net_992);
  assign net_992 = ~(net_926 & net_85);
  assign net_85 = (iq_instr_dec1_ls_i[28] & net_4);
  assign net_991 = (net_550 & net_993);
  assign net_993 = (net_994 | net_995);
  assign net_995 = ~(net_2 & iq_instr_dec1_ls_i[8]);
  assign net_550 = ~(iq_instr_dec1_ls_i[20] & net_757);
  assign net_963 = (net_265 | net_996);
  assign net_996 = (net_206 | net_997);
  assign net_997 = (net_998 | net_999);
  assign net_998 = (net_1000 | net_836);
  assign net_836 = (net_1001 & net_1002);
  assign net_1001 = ~(net_45 | net_1);
  assign net_348 = ~(set_19_16_i | iq_instr_dec1_ls_i[9]);
  assign net_1000 = (set_19_16_as_r31 & net_1003);
  assign net_1003 = (net_683 & net_149);
  assign net_206 = (net_347 & net_213);
  assign imm_sel_ls_dec1_ls[3] = (net_72 | net_1004);
  assign net_1004 = (thumb_execution & req_strict_algn_dec1_ls);
  assign req_strict_algn_dec1_ls = (net_1005 | net_1006);
  assign net_1006 = ~(net_1639 | net_23);
  assign net_72 = (net_1007 | str_data_b_sel_dec1_ls[0]);
  assign imm_sel_ls_dec1_ls[2] = (net_1008 | net_1009);
  assign net_1009 = (net_1010 | net_1011);
  assign net_1010 = (net_31 & net_1012);
  assign net_1012 = ~(net_1013 & net_1014);
  assign net_1014 = ~(iq_instr_dec1_ls_i[20] & net_1015);
  assign net_1015 = (net_759 | iq_instr_dec1_ls_i[24]);
  assign net_759 = ~(cc_never & net_1636);
  assign net_1008 = (net_1016 | net_1017);
  assign net_1017 = (net_1018 | net_1019);
  assign net_1019 = ~(net_145 | net_847);
  assign net_847 = ~(net_225 & net_39);
  assign net_1018 = (net_464 & net_1020);
  assign net_1020 = (net_151 & iq_instr_dec1_ls_i[27]);
  assign net_1016 = (iq_instr_dec1_ls_i[23] & net_1021);
  assign net_1021 = ~(net_26 & net_707);
  assign imm_sel_ls_dec1_ls[1] = (net_1022 | net_1023);
  assign net_1022 = (iq_instr_dec1_ls_i[21] & net_133);
  assign force_usr_priv_mem_dec1_ls = (net_1024 | net_1025);
  assign net_1025 = (net_999 | net_1026);
  assign net_1026 = (net_1027 | net_966);
  assign net_1027 = (net_1028 | net_1029);
  assign net_1029 = ~(net_582 | net_476);
  assign net_1028 = (net_1030 & net_1031);
  assign net_1031 = (net_683 | net_687);
  assign net_687 = ~(arm_execution | net_582);
  assign ex2_ctl_op_comp_dec1_ls[1] = (net_1032 | net_1033);
  assign net_1033 = (net_58 & net_1034);
  assign net_1034 = (net_1035 | net_1036);
  assign net_1036 = (net_459 & net_1037);
  assign net_1032 = (net_1638 & net_1038);
  assign net_1038 = (net_1039 | net_1040);
  assign net_1039 = ~(net_1041 & net_1042);
  assign net_1042 = (net_1043 & net_1044);
  assign net_1044 = (net_1045 & net_1046);
  assign net_1046 = (net_14 | net_1636);
  assign net_1041 = (net_406 & net_268);
  assign net_268 = ~(net_110 & net_1639);
  assign ex1_ctl_shift_op_dec1_ls[2] = (net_1047 | net_1048);
  assign net_1048 = ~(net_1049 & net_1050);
  assign net_1050 = ~(net_1051 & net_1639);
  assign net_1049 = ~(net_1052 & a32_only);
  assign net_1052 = (iq_instr_dec1_ls_i[25] & net_1053);
  assign net_1053 = (net_1054 | net_1055);
  assign net_1055 = ~(net_36 & net_730);
  assign net_1047 = (net_14 & net_1056);
  assign net_1056 = (net_460 | net_1057);
  assign ex1_ctl_shift_op_dec1_ls[1] = (iq_instr_dec1_ls_i[6] & net_1058);
  assign ex1_ctl_shift_op_dec1_ls[0] = (iq_instr_dec1_ls_i[5] & net_1058);
  assign net_1058 = (net_460 & net_1059);
  assign net_1059 = ~(net_1060 & net_40);
  assign net_1060 = ~(net_19 | net_372);
  assign dp_data_c_sel_dec1_ls[1] = (net_1061 | net_1023);
  assign net_1023 = ~(net_1062 & net_1063);
  assign net_1062 = ~(net_407 | net_1064);
  assign net_1064 = (net_1065 & net_1066);
  assign net_407 = (net_460 & net_1067);
  assign net_1067 = (net_1068 | net_1069);
  assign dp_data_b_sel_dec1_ls[1] = (net_1070 | net_1071);
  assign net_1071 = (net_1072 | net_1073);
  assign net_1072 = (net_31 & net_1074);
  assign net_1074 = ~(net_1075 & net_1076);
  assign net_1076 = ~(iq_instr_dec1_ls_i[20] & net_1054);
  assign net_1075 = (net_959 | net_1013);
  assign net_1013 = (iq_instr_dec1_ls_i[22] & net_1077);
  assign net_1077 = ~(a32_only & net_1635);
  assign net_1070 = ~(net_1078 & net_1079);
  assign net_1079 = (net_767 | net_23);
  assign net_1078 = (net_1080 & net_785);
  assign net_785 = ~(net_113 | net_1081);
  assign net_1081 = ~(net_37 | net_15);
  assign net_1080 = ~(net_265 | net_1082);
  assign net_1082 = ~(net_270 & net_1083);
  assign net_1083 = ~(net_1005 & iq_instr_dec1_ls_i[21]);
  assign net_270 = (net_199 | net_960);
  assign dp_data_b_sel_dec1_ls[0] = (net_1084 | net_1085);
  assign net_1085 = ~(net_1086 & net_1087);
  assign net_1087 = ~(net_265 | net_1088);
  assign net_1084 = ~(net_1089 & net_1090);
  assign net_1090 = ~(net_92 & net_1037);
  assign net_1089 = (net_1091 & net_1063);
  assign net_1091 = (net_1092 & net_1093);
  assign net_1093 = (net_1094 | net_1095);
  assign net_1095 = ~(net_769 & net_43);
  assign net_1092 = (net_1096 & net_1097);
  assign net_1097 = (iq_instr_dec1_ls_i[23] | net_1098);
  assign net_1098 = ~(iq_instr_dec1_ls_i[8] & net_1099);
  assign net_1096 = (net_1043 & net_1100);
  assign net_1100 = (net_360 | net_1101);
  assign net_1101 = (net_1636 | net_32);
  assign dp_data_a_sel_dec1_ls[0] = ~(net_688 & net_1102);
  assign net_1102 = ~(net_1103 | net_1104);
  assign net_1104 = (net_1105 | net_1106);
  assign net_1106 = (net_1073 | net_1088);
  assign net_1088 = (net_1107 | net_1108);
  assign net_1108 = (net_955 & net_43);
  assign net_1107 = (net_441 & net_1109);
  assign net_1109 = (net_178 | net_1110);
  assign net_1110 = ~(net_3 | net_50);
  assign net_1073 = ~(net_1111 & net_1112);
  assign net_1112 = (net_767 | net_1094);
  assign net_1094 = ~(net_807 & net_732);
  assign net_1111 = ~(net_1113 | net_243);
  assign net_243 = (net_1114 & net_1115);
  assign net_1115 = ~(net_994 & net_21);
  assign net_994 = (net_902 & net_1116);
  assign net_1116 = (net_47 | net_1635);
  assign net_902 = ~(iq_instr_dec1_ls_i[24] & net_179);
  assign net_1114 = (net_2 & net_1037);
  assign net_1105 = (net_683 & net_1117);
  assign net_1103 = (net_1118 | net_1119);
  assign net_1119 = (net_98 | net_1120);
  assign net_1120 = (net_966 | net_1121);
  assign net_1121 = (net_1122 | net_1123);
  assign net_1123 = (net_1124 | str_data_b_sel_dec1_ls[0]);
  assign net_1124 = (net_225 & net_1125);
  assign net_1125 = (net_959 & net_1126);
  assign net_1126 = ~(net_222 & net_1127);
  assign net_1127 = ~(net_1128 & net_5);
  assign net_1122 = (net_1129 | net_1024);
  assign net_1129 = (net_31 & net_1130);
  assign net_1130 = ~(net_1131 & net_1132);
  assign net_966 = (iq_instr_dec1_ls_i[27] & net_1133);
  assign net_1133 = (net_1134 | net_1135);
  assign net_1135 = (net_545 & net_683);
  assign net_683 = (iq_instr_dec1_ls_i[9] & net_347);
  assign net_1134 = (net_905 & net_90);
  assign net_90 = (net_2 & net_619);
  assign net_905 = (iq_instr_dec1_ls_i[28] & net_92);
  assign net_98 = (iq_instr_dec1_ls_i[9] & net_1136);
  assign net_1136 = (net_809 & net_864);
  assign net_864 = ~(net_1636 | net_45);
  assign net_1118 = (net_807 & net_1137);
  assign net_1137 = (net_1138 | net_1139);
  assign net_1139 = (iq_instr_dec1_ls_i[21] & net_739);
  assign net_739 = ~(net_45 | net_1140);
  assign net_1140 = (arm_execution | net_1141);
  assign net_1141 = (net_58 | net_2);
  assign net_1138 = (net_769 & net_744);
  assign net_688 = (net_1142 & net_1143);
  assign net_1143 = (net_1144 & net_506);
  assign net_506 = (net_1145 & net_1146);
  assign net_1146 = (net_1147 | net_15);
  assign net_1147 = (net_1148 & net_1149);
  assign net_1149 = ~(net_92 & iq_instr_dec1_ls_i[24]);
  assign net_1148 = (net_36 & net_1150);
  assign net_1145 = ~(iq_instr_dec1_ls_i[26] & net_1151);
  assign net_1151 = ~(net_1152 & net_1153);
  assign net_1153 = ~(iq_instr_dec1_ls_i[25] & net_1154);
  assign net_1154 = ~(net_1155 & net_1156);
  assign net_1155 = ~(net_210 | net_459);
  assign net_210 = (net_179 & net_1054);
  assign net_1054 = (iq_instr_dec1_ls_i[21] | net_1068);
  assign net_1152 = ~(net_769 & net_1157);
  assign net_1157 = (net_1158 & net_1159);
  assign net_1144 = (net_1160 & net_1161);
  assign net_1161 = ~(net_435 & iq_instr_dec1_ls_i[21]);
  assign net_435 = (net_1159 & net_1051);
  assign net_1159 = ~(iq_instr_dec1_ls_i[20] | set_15_12_i);
  assign net_1160 = (net_1162 | net_675);
  assign net_1162 = (net_259 & net_1163);
  assign net_1163 = (net_107 | net_959);
  assign net_259 = (iq_instr_dec1_ls_i[22] | net_36);
  assign net_1142 = (net_1164 & net_1165);
  assign net_1164 = (net_1166 & net_1167);
  assign net_1167 = ~(iq_instr_dec1_ls_i[27] & net_1168);
  assign net_1168 = ~(net_1169 & net_1170);
  assign net_1169 = (net_1171 & net_1172);
  assign net_1172 = ~(net_293 & net_543);
  assign net_543 = ~(iq_instr_dec1_ls_i[24] | net_53);
  assign net_1171 = (net_1173 & net_1174);
  assign net_1174 = (net_1175 | net_556);
  assign net_556 = ~(iq_instr_dec1_ls_i[22] & net_545);
  assign net_1175 = (net_350 & net_1176);
  assign net_1176 = (net_1177 | net_173);
  assign net_350 = (set_15_12_as_r31 | net_42);
  assign net_1166 = (net_1178 & net_1179);
  assign net_1179 = (net_1180 | net_34);
  assign net_1178 = (net_116 & net_127);
  assign net_127 = ~(set_15_12_i & net_1061);
  assign net_1061 = (iq_instr_dec1_ls_i[21] & net_760);
  assign net_116 = ~(net_1181 & net_253);
  assign dcu_valid_dec1_ls = ~(net_824 & net_1182);
  assign net_1182 = ~(net_1183 | net_1184);
  assign net_1184 = ~(net_1185 & net_1186);
  assign net_1186 = ~(net_718 | net_1113);
  assign net_1113 = (iq_instr_dec1_ls_i[21] & net_1007);
  assign net_718 = (net_92 & net_105);
  assign net_1185 = ~(net_1187 | net_1188);
  assign net_1188 = (net_1040 | net_1189);
  assign net_1189 = ~(net_1190 & net_233);
  assign net_233 = ~(net_1191 | net_818);
  assign net_1190 = ~(net_133 | net_1192);
  assign net_1192 = ~(net_707 & net_1193);
  assign net_1193 = ~(net_1194 & net_4);
  assign net_1040 = ~(net_1640 | net_1170);
  assign net_1187 = ~(net_1195 & net_1196);
  assign net_1196 = ~(iq_instr_dec1_ls_i[10] & net_1197);
  assign net_1195 = (net_828 | net_222);
  assign net_828 = ~(net_149 & net_1198);
  assign net_824 = (net_1199 & net_1200);
  assign net_1200 = (iq_instr_dec1_ls_i[26] | net_1201);
  assign net_1201 = (net_1202 & net_1203);
  assign net_1203 = ~(a32_only & net_1204);
  assign net_1204 = ~(net_1205 & net_1150);
  assign net_1150 = (net_1206 & net_50);
  assign net_1206 = (net_1207 & net_1208);
  assign net_1208 = ~(net_414 & iq_instr_dec1_ls_i[6]);
  assign net_414 = (iq_instr_dec1_ls_i[21] & iq_instr_dec1_ls_i[24]);
  assign net_1207 = (net_40 | net_199);
  assign net_199 = ~(iq_instr_dec1_ls_i[6] | net_1209);
  assign net_1209 = (iq_instr_dec1_ls_i[5] & iq_instr_dec1_ls_i[20]);
  assign net_1205 = (net_37 & net_38);
  assign net_1202 = (net_1210 & net_1211);
  assign net_1211 = ~(net_962 & net_1639);
  assign net_1210 = ~(iq_instr_dec1_ls_i[23] & net_278);
  assign net_1199 = ~(net_183 | net_1212);
  assign net_1212 = ~(net_1213 & net_1214);
  assign net_1214 = (net_1215 & net_1216);
  assign net_1216 = (net_1217 | net_32);
  assign net_1217 = (net_1218 & net_1219);
  assign net_1219 = ~(iq_instr_dec1_ls_i[25] & net_1220);
  assign net_1220 = ~(net_37 & net_1156);
  assign net_1218 = (net_1132 & net_1222);
  assign net_1222 = (iq_instr_dec1_ls_i[25] | net_1223);
  assign net_1223 = (net_1131 & net_1224);
  assign net_1224 = (net_38 & net_1225);
  assign net_1225 = ~(a32_only & net_1221);
  assign net_1221 = (iq_instr_dec1_ls_i[22] & net_459);
  assign net_1131 = (net_363 & net_1226);
  assign net_1132 = ~(net_179 & net_1068);
  assign net_1068 = ~(iq_instr_dec1_ls_i[24] | cc_never);
  assign net_1215 = ~(net_1227 | net_1228);
  assign net_1228 = (net_807 & net_299);
  assign net_1227 = ~(net_1229 & net_1230);
  assign net_1230 = (net_8 | net_726);
  assign net_726 = ~(iq_instr_dec1_ls_i[27] & iq_instr_dec1_ls_i[24]);
  assign net_1229 = ~(net_1024 | net_790);
  assign net_790 = ~(a64_only | net_49);
  assign net_1024 = (a32_only & net_1231);
  assign net_1231 = (iq_instr_dec1_ls_i[21] & net_1639);
  assign net_1213 = (net_1232 & net_1233);
  assign net_1233 = (net_161 | net_27);
  assign net_161 = ~(net_146 & net_1641);
  assign net_1232 = (net_565 & net_1234);
  assign net_1234 = (net_1235 & net_1236);
  assign net_1236 = ~(net_1237 & net_1238);
  assign net_1238 = (net_1239 | net_1240);
  assign net_1240 = (iq_instr_dec1_ls_i[27] & net_1241);
  assign net_1241 = ~(net_713 & net_1242);
  assign net_1242 = ~(set_15_12_as_r31 & net_225);
  assign net_713 = ~(iq_instr_dec1_ls_i[23] & net_658);
  assign net_1239 = (net_441 & net_1243);
  assign net_1243 = (net_658 | net_1198);
  assign net_1198 = (set_15_12_as_r31 & net_1637);
  assign net_658 = (net_302 & net_577);
  assign net_577 = ~(net_50 & net_35);
  assign net_1235 = (net_1244 & net_1245);
  assign net_565 = ~(net_143 & net_1051);
  assign net_183 = (net_149 & net_1246);
  assign net_1246 = (net_1247 | net_1248);
  assign net_1248 = ~(net_156 & net_1249);
  assign net_1249 = (net_160 & net_1250);
  assign net_1250 = (net_349 | net_1251);
  assign net_1251 = ~(iq_instr_dec1_ls_i[8] | net_227);
  assign net_349 = ~(iq_instr_dec1_ls_i[22] & net_959);
  assign net_160 = ~(aarch64_state_i & net_959);
  assign check_x64_dec1_ls = ~(net_1252 & net_1253);
  assign net_1253 = (iq_instr_dec1_ls_i[27] | iq_instr_dec1_ls_i[25]);
  assign net_1252 = (net_583 & net_1254);
  assign net_1254 = (net_1255 & net_1256);
  assign net_1256 = ~(a64_only & iq_instr_dec1_ls_i[27]);
  assign net_1255 = (net_1257 & net_1258);
  assign net_1258 = ~(net_1057 | net_1259);
  assign net_1259 = (net_1005 | net_1260);
  assign net_1260 = ~(net_1261 & iq_instr_dec1_ls_i[24]);
  assign net_1257 = (a64_only | net_1069);
  assign net_1069 = (iq_instr_dec1_ls_i[21] & iq_instr_dec1_ls_i[20]);
  assign net_583 = ~(iq_instr_dec1_ls_i[27] & net_1637);
  assign alu_valid_dec1_ls = (str_data_b_sel_dec1_ls[0] | rf_wr_when_w1_dec1_ls[0]);
  assign rf_wr_when_w1_dec1_ls[0] = (net_265 | net_1262);
  assign net_1262 = ~(net_1086 & net_1263);
  assign net_1263 = (net_245 & net_1264);
  assign net_1264 = (net_1265 & net_1266);
  assign net_1266 = (net_1267 | net_1268);
  assign net_1268 = (net_1269 & net_47);
  assign net_1269 = ~(net_2 & net_165);
  assign net_165 = (iq_instr_dec1_ls_i[22] & iq_instr_dec1_ls_i[24]);
  assign net_1267 = ~(net_214 & net_149);
  assign net_1265 = ~(iq_instr_dec1_ls_i[21] & net_31);
  assign net_245 = (net_1043 & net_1063);
  assign net_1063 = ~(iq_instr_dec1_ls_i[25] & net_1270);
  assign net_1270 = ~(net_1271 & net_1272);
  assign net_1272 = (net_1638 | net_1180);
  assign net_1180 = (iq_instr_dec1_ls_i[20] | net_47);
  assign net_1271 = (net_1273 & net_1274);
  assign net_1274 = ~(net_225 & net_143);
  assign net_1273 = (net_1275 | net_32);
  assign net_1275 = (net_36 & net_1156);
  assign net_1156 = (iq_instr_dec1_ls_i[23] | net_397);
  assign net_1043 = ~(a32_only & net_459);
  assign net_1086 = (net_1276 & net_1277);
  assign net_1277 = (net_1278 & net_1279);
  assign net_1279 = (net_1636 | net_1280);
  assign net_1280 = (net_254 & net_15);
  assign net_254 = ~(net_760 | net_1281);
  assign net_1281 = (net_1005 | net_1282);
  assign net_1282 = (net_1007 | net_1283);
  assign net_1283 = (net_7 & net_1051);
  assign net_1005 = ~(iq_instr_dec1_ls_i[28] | net_1640);
  assign net_1278 = (net_1284 & net_1285);
  assign net_1285 = (net_1261 | net_1286);
  assign net_1286 = ~(net_808 & iq_instr_dec1_ls_i[20]);
  assign net_1284 = ~(a32_only & net_1287);
  assign net_1287 = ~(net_269 | net_40);
  assign net_1276 = (net_1288 & net_1289);
  assign net_1289 = ~(net_1037 & net_545);
  assign net_1288 = (net_264 & net_1045);
  assign net_1045 = ~(net_143 & net_1290);
  assign net_1290 = ~(cc_never | net_32);
  assign net_265 = (net_1194 & net_464);
  assign net_1194 = (iq_instr_dec1_ls_i[28] & net_1037);
  assign net_1037 = (iq_instr_dec1_ls_i[27] & net_214);
  assign algn_size_dec1_ls[1] = ~(net_1291 & net_1292);
  assign net_1292 = (net_877 & net_1293);
  assign net_1293 = (net_45 | net_1294);
  assign net_1294 = (net_1640 | net_1637);
  assign net_877 = (net_376 & net_1295);
  assign net_1295 = (net_1296 & net_1297);
  assign net_1297 = ~(net_807 & iq_instr_dec1_ls_i[22]);
  assign net_1296 = (net_1298 & net_1299);
  assign net_1299 = ~(net_283 | net_1300);
  assign net_1300 = ~(net_1301 & net_1302);
  assign net_1302 = (net_101 & net_424);
  assign net_424 = ~(net_760 & net_1635);
  assign net_760 = (net_225 & net_360);
  assign net_101 = (net_564 & net_437);
  assign net_437 = (net_972 | net_1640);
  assign net_972 = (net_1170 & net_1303);
  assign net_1303 = (iq_instr_dec1_ls_i[20] | net_1639);
  assign net_564 = ~(net_892 & net_31);
  assign net_1301 = (net_1304 & net_1305);
  assign net_1305 = (net_1306 | cc_never);
  assign net_1306 = (net_397 | net_32);
  assign net_1304 = (net_1307 & net_1308);
  assign net_1308 = ~(net_1051 & net_1309);
  assign net_1309 = ~(net_6 & net_1310);
  assign net_1310 = ~(net_1237 & net_19);
  assign net_1307 = ~(net_1311 & net_1312);
  assign net_1312 = (net_1638 | iq_instr_dec1_ls_i[8]);
  assign net_1311 = ~(net_48 | net_1640);
  assign net_1298 = ~(str_data_b_sel_dec1_ls[0] | net_1313);
  assign net_1313 = ~(net_264 & net_1314);
  assign net_1314 = (net_50 | net_356);
  assign net_264 = (net_32 | net_40);
  assign net_1291 = ~(net_73 | net_369);
  assign net_369 = ~(net_360 | net_1315);
  assign ls_elem_size_dec1_ls[0] = ~(net_811 & net_1316);
  assign net_1316 = ~(net_561 | net_1317);
  assign net_1317 = ~(net_1318 & net_1319);
  assign net_1319 = (net_22 | net_1636);
  assign net_1318 = ~(net_955 | net_1320);
  assign net_1320 = ~(net_26 & net_1321);
  assign net_1321 = ~(net_142 & net_1639);
  assign net_955 = (net_769 & net_809);
  assign net_561 = ~(iq_instr_dec1_ls_i[27] | net_1322);
  assign net_1322 = ~(iq_instr_dec1_ls_i[22] & net_817);
  assign net_817 = (net_12 & net_1323);
  assign net_811 = ~(net_113 | net_1324);
  assign net_1324 = (net_818 | net_1325);
  assign net_1325 = ~(net_1326 & net_168);
  assign net_168 = (net_194 & net_1327);
  assign net_1327 = ~(net_142 & net_179);
  assign net_142 = (net_110 & iq_instr_dec1_ls_i[5]);
  assign net_194 = ~(iq_instr_dec1_ls_i[5] & net_1328);
  assign net_1326 = (net_1329 & net_1330);
  assign net_1330 = (net_15 | net_36);
  assign net_1329 = (net_1331 & net_1332);
  assign net_1332 = ~(str_data_b_sel_dec1_ls[0] | net_1333);
  assign net_1333 = ~(net_861 | net_1334);
  assign net_1334 = ~(net_1335 | net_744);
  assign net_744 = (aarch64_state_i & net_57);
  assign net_861 = ~(iq_instr_dec1_ls_i[27] & net_769);
  assign net_1331 = (net_579 & net_1336);
  assign net_1336 = (iq_instr_dec1_ls_i[6] | net_271);
  assign net_271 = ~(net_110 & net_769);
  assign net_579 = ~(net_1323 & net_1337);
  assign net_1323 = (net_959 & net_32);
  assign net_818 = ~(net_33 | net_1315);
  assign net_113 = (net_92 & net_252);
  assign net_252 = (iq_instr_dec1_ls_i[24] & net_110);
  assign agu_sub_b_dec1_ls = (net_937 | net_1338);
  assign net_1338 = ~(net_1339 & net_1340);
  assign net_1340 = ~(net_1035 & net_1341);
  assign net_1035 = (net_214 & net_1030);
  assign net_1339 = (net_1342 & net_1245);
  assign net_1245 = ~(net_149 & net_1343);
  assign net_1343 = ~(net_1344 | net_730);
  assign net_730 = ~(net_1637 & net_1638);
  assign net_1342 = ~(net_832 | net_1345);
  assign net_1345 = ~(net_1346 & net_1347);
  assign net_1347 = (net_885 | net_173);
  assign net_1346 = (net_1639 | net_1348);
  assign net_1348 = (net_1349 | iq_instr_dec1_ls_i[23]);
  assign net_1349 = ~(net_809 | a32_only);
  assign net_832 = (net_148 & net_1350);
  assign net_1350 = (net_1341 & net_1351);
  assign net_937 = (net_1352 & net_1638);
  assign agu_shf_value_dec1_ls[1] = ~(net_1353 & net_1354);
  assign net_1354 = ~(net_1355 & iq_instr_dec1_ls_i[5]);
  assign net_1353 = ~(net_133 & iq_instr_dec1_ls_i[8]);
  assign agu_shf_value_dec1_ls[0] = ~(net_1356 & net_1357);
  assign net_1357 = ~(iq_instr_dec1_ls_i[7] & net_133);
  assign net_1356 = ~(net_1355 & iq_instr_dec1_ls_i[4]);
  assign net_1355 = (net_441 & net_1358);
  assign net_1358 = (net_1359 | net_1360);
  assign net_1360 = (net_1361 | net_1362);
  assign net_1361 = (set_19_16_as_r31 & net_278);
  assign net_1359 = ~(net_1363 & net_1364);
  assign net_1364 = ~(net_143 & net_4);
  assign net_1363 = ~(net_732 & net_1637);
  assign net_732 = ~(net_1365 & net_1366);
  assign net_1366 = ~(set_15_12_as_r31 & set_15_12_i);
  assign net_1365 = ~(net_464 & net_7);
  assign agu_data_b_sel_dec1_ls[5] = (iq_instr_dec1_ls_i[9] & net_1367);
  assign agu_data_b_sel_dec1_ls[4] = (iq_instr_dec1_ls_i[7] & net_1367);
  assign net_1367 = (net_1368 | net_1369);
  assign net_1369 = (net_441 & net_1370);
  assign net_1370 = (net_1362 | net_1371);
  assign net_1371 = (net_1637 & net_464);
  assign net_1362 = ~(net_21 & net_1372);
  assign net_1368 = (net_1636 & net_1373);
  assign net_1373 = (net_1030 & net_227);
  assign net_1030 = (net_149 & net_464);
  assign agu_data_b_sel_dec1_ls[1] = ~(net_1374 & net_1375);
  assign net_1375 = (iq_instr_dec1_ls_i[8] | net_1376);
  assign net_1376 = (net_1377 & net_1378);
  assign net_1378 = ~(net_172 & net_148);
  assign net_1377 = (net_1379 & net_1380);
  assign net_1380 = ~(net_1381 & net_1382);
  assign net_1382 = (net_474 & iq_instr_dec1_ls_i[27]);
  assign net_474 = (iq_instr_dec1_ls_i[11] & iq_instr_dec1_ls_i[9]);
  assign net_1381 = ~(net_1383 & net_1384);
  assign net_1384 = (net_45 | net_1385);
  assign net_1385 = ~(iq_instr_dec1_ls_i[28] & net_1237);
  assign net_1383 = (net_1386 & net_1387);
  assign net_1387 = ~(set_19_16_as_r31 & net_1388);
  assign net_1388 = (net_1389 | net_1390);
  assign net_1390 = (net_1391 & net_1392);
  assign net_1392 = ~(iq_instr_dec1_ls_i[22] & arm_execution);
  assign net_1391 = ~(net_45 | net_1635);
  assign net_1389 = (net_1638 & net_1393);
  assign net_1393 = (arm_execution & net_892);
  assign net_1386 = (net_21 | net_1394);
  assign net_1394 = (net_1395 & net_1396);
  assign net_1396 = (net_1641 | net_1637);
  assign net_1395 = (set_19_16_as_r31 | set_19_16_i);
  assign net_1379 = (net_1397 | net_56);
  assign net_1397 = (net_885 & net_1398);
  assign net_1398 = (net_22 | net_555);
  assign net_555 = (set_15_12_as_r31 | iq_instr_dec1_ls_i[10]);
  assign net_105 = (iq_instr_dec1_ls_i[27] & net_545);
  assign net_885 = ~(net_146 & net_213);
  assign net_213 = ~(iq_instr_dec1_ls_i[9] | net_145);
  assign net_1374 = ~(net_1011 | net_1399);
  assign net_1399 = ~(net_1400 & net_1401);
  assign net_1401 = (net_56 | net_707);
  assign net_707 = ~(net_149 & net_757);
  assign net_1400 = ~(net_1402 | net_1403);
  assign net_1403 = ~(net_1404 & net_1405);
  assign net_1405 = (net_1640 | net_156);
  assign net_1404 = ~(net_1406 | net_1407);
  assign net_1407 = (net_1183 | net_1408);
  assign net_1408 = (net_1409 | net_999);
  assign net_999 = (net_149 & net_1247);
  assign net_1247 = (iq_instr_dec1_ls_i[24] & net_347);
  assign net_1409 = (iq_instr_dec1_ls_i[10] & net_1410);
  assign net_1410 = (net_1197 | net_1411);
  assign net_1411 = (net_1412 | net_1099);
  assign net_1099 = (net_2 & net_172);
  assign net_172 = (iq_instr_dec1_ls_i[27] & net_178);
  assign net_1412 = (net_1413 & net_1158);
  assign net_1197 = (iq_instr_dec1_ls_i[11] & net_1351);
  assign net_1351 = (iq_instr_dec1_ls_i[28] & net_807);
  assign net_807 = (iq_instr_dec1_ls_i[27] & net_1639);
  assign net_1183 = (net_770 | net_1414);
  assign net_1414 = (net_1415 | ls_instr_type_dec1_ls[2]);
  assign ls_instr_type_dec1_ls[2] = (net_446 & net_1007);
  assign net_1415 = (net_109 & net_1158);
  assign net_1406 = ~(net_1416 & net_1417);
  assign net_1417 = (net_145 | net_767);
  assign net_767 = ~(iq_instr_dec1_ls_i[21] & net_225);
  assign net_145 = (set_19_16_i | net_27);
  assign net_1416 = ~(net_692 | net_231);
  assign net_231 = ~(iq_instr_dec1_ls_i[24] | net_1315);
  assign net_692 = (iq_instr_dec1_ls_i[23] & net_1191);
  assign net_1191 = (net_92 & net_238);
  assign net_1402 = ~(net_1418 & net_1419);
  assign net_1419 = (net_16 | net_25);
  assign net_1418 = ~(net_1420 | net_1421);
  assign net_1421 = (net_253 | net_1422);
  assign net_1422 = ~(net_714 & net_1423);
  assign net_1423 = ~(net_962 & net_1158);
  assign net_1158 = ~(iq_instr_dec1_ls_i[25] | net_1639);
  assign net_962 = ~(iq_instr_dec1_ls_i[27] | a32_only);
  assign net_714 = (net_42 | net_476);
  assign net_476 = ~(net_1637 & net_809);
  assign net_809 = (iq_instr_dec1_ls_i[27] & net_1635);
  assign net_253 = (iq_instr_dec1_ls_i[24] & net_31);
  assign net_1420 = (net_1424 | net_1425);
  assign net_1425 = (net_151 & net_1128);
  assign net_1128 = (iq_instr_dec1_ls_i[27] & net_4);
  assign net_151 = (net_225 & net_7);
  assign net_1424 = ~(net_1638 | net_1426);
  assign net_1426 = (net_494 | net_27);
  assign net_1011 = (net_1427 | net_283);
  assign net_283 = (net_278 & net_1428);
  assign net_278 = (net_179 & net_1636);
  assign net_1427 = (iq_instr_dec1_ls_i[27] & net_1429);
  assign net_1429 = (net_1430 | net_1431);
  assign net_1431 = ~(net_35 | net_1432);
  assign net_1432 = ~(net_67 & net_1433);
  assign net_1433 = ~(iq_instr_dec1_ls_i[23] | net_53);
  assign net_446 = ~(iq_instr_dec1_ls_i[21] | iq_instr_dec1_ls_i[24]);
  assign net_1430 = ~(net_1434 & net_1435);
  assign net_1435 = (net_1344 | net_397);
  assign net_1344 = ~(net_1436 & net_1437);
  assign net_1434 = ~(net_1438 | net_1439);
  assign net_1439 = (iq_instr_dec1_ls_i[23] & net_1440);
  assign net_1440 = (net_545 | net_1441);
  assign net_1441 = (net_1442 & net_1443);
  assign net_1443 = (net_464 | set_15_12_i);
  assign net_1442 = (net_1641 & net_143);
  assign net_143 = ~(iq_instr_dec1_ls_i[24] | net_1635);
  assign net_1438 = (net_225 & net_1444);
  assign net_1444 = ~(net_379 & net_1445);
  assign net_1445 = (net_222 & net_1446);
  assign net_379 = ~(iq_instr_dec1_ls_i[20] & net_7);
  assign agu_data_b_sel_dec1_ls[0] = ~(net_1447 & net_1448);
  assign net_1448 = ~(net_439 & net_1635);
  assign net_439 = (iq_instr_dec1_ls_i[24] & net_1449);
  assign net_1449 = (net_225 & net_32);
  assign net_1447 = (net_1450 & net_409);
  assign net_409 = (net_1451 | net_27);
  assign net_1451 = (net_482 & net_1452);
  assign net_1452 = ~(net_496 & net_227);
  assign net_496 = (net_299 & net_302);
  assign net_482 = ~(net_1453 & net_1638);
  assign net_1453 = (net_757 & net_58);
  assign net_757 = (net_92 & net_609);
  assign net_609 = (iq_instr_dec1_ls_i[24] & net_873);
  assign net_1450 = ~(net_1328 | net_1454);
  assign net_1454 = ~(net_416 & net_1455);
  assign net_1455 = ~(net_138 & iq_instr_dec1_ls_i[24]);
  assign net_138 = (net_110 & iq_instr_dec1_ls_i[6]);
  assign net_416 = (net_1456 & net_1457);
  assign net_1457 = ~(net_1117 & net_227);
  assign net_1117 = (net_238 & net_464);
  assign net_1456 = ~(net_133 | net_1458);
  assign net_1458 = (net_441 & net_1459);
  assign net_1459 = (net_1460 | net_1461);
  assign net_1461 = (net_913 | net_1462);
  assign net_1462 = ~(net_1463 & net_1464);
  assign net_1464 = ~(net_1237 & net_769);
  assign net_913 = (set_15_12_as_r31 & net_1181);
  assign net_1181 = (set_15_12_i & net_769);
  assign net_1460 = ~(net_1465 & net_934);
  assign net_934 = (net_1466 | iq_instr_dec1_ls_i[22]);
  assign net_1466 = (net_222 & net_1467);
  assign net_1467 = (set_19_16_i | set_15_12_i);
  assign net_222 = ~(set_19_16_as_r31 & set_19_16_i);
  assign net_1465 = (net_1468 & net_1469);
  assign net_1469 = ~(net_545 & net_124);
  assign net_124 = (set_19_16_as_r31 | net_1470);
  assign net_1470 = ~(net_237 & net_1636);
  assign net_1468 = (net_1471 & net_1472);
  assign net_1472 = ~(net_237 & net_618);
  assign net_618 = (net_892 | net_603);
  assign net_1471 = (net_1372 & net_1473);
  assign net_1473 = (net_1474 & net_1475);
  assign net_1475 = (net_21 | net_119);
  assign net_119 = (set_15_12_i | set_3_0_i);
  assign net_1474 = (net_1446 | iq_instr_dec1_ls_i[21]);
  assign net_1446 = ~(set_15_12_as_r31 & net_1237);
  assign net_1237 = (iq_instr_dec1_ls_i[20] & net_4);
  assign net_1372 = ~(net_179 & net_498);
  assign net_498 = (net_1476 | net_1477);
  assign net_1477 = (iq_instr_dec1_ls_i[24] ^ iq_instr_dec1_ls_i[21]);
  assign net_1476 = (iq_instr_dec1_ls_i[21] & net_873);
  assign net_441 = (iq_instr_dec1_ls_i[27] & net_227);
  assign net_1328 = (net_1478 & net_1640);
  assign net_1478 = (net_737 & net_1428);
  assign net_1428 = (iq_instr_dec1_ls_i[23] & net_32);
  assign agu_data_a_sel_dec1_ls[1] = ~(net_1479 & net_1480);
  assign net_1480 = (net_1481 | net_1482);
  assign net_1482 = ~(set_19_16_i & net_959);
  assign net_1481 = (net_1483 & net_1484);
  assign net_1484 = (iq_instr_dec1_ls_i[20] | net_950);
  assign net_950 = ~(net_225 | net_1057);
  assign net_1483 = ~(net_851 | net_1485);
  assign net_1485 = ~(net_1486 & net_1487);
  assign net_1487 = (net_1488 & net_951);
  assign net_951 = ~(a32_only & net_31);
  assign net_1488 = (net_1489 & net_1490);
  assign net_1490 = (net_356 | cc_never);
  assign net_356 = ~(iq_instr_dec1_ls_i[20] & iq_instr_dec1_ls_i[26]);
  assign net_1489 = (net_1491 | iq_instr_dec1_ls_i[26]);
  assign net_1491 = (a64_only | net_51);
  assign net_1486 = (net_1492 & net_1493);
  assign net_1493 = (net_1635 | net_15);
  assign net_1492 = (net_675 | net_109);
  assign net_851 = (cc_never & net_1057);
  assign net_1479 = ~(net_1352 | net_1494);
  assign net_1494 = ~(net_1495 & net_1496);
  assign net_1496 = (net_1497 & net_62);
  assign net_62 = (net_27 | net_341);
  assign net_341 = ~(net_146 & net_67);
  assign net_146 = ~(iq_instr_dec1_ls_i[22] | set_15_12_i);
  assign net_1497 = (net_1244 & net_1498);
  assign net_1498 = (net_1499 | net_1500);
  assign net_1500 = (net_464 | net_25);
  assign net_1499 = ~(net_299 & iq_instr_dec1_ls_i[23]);
  assign net_1244 = ~(set_19_16_i & net_1501);
  assign net_1501 = (net_225 & net_1502);
  assign net_1502 = (net_149 & net_1437);
  assign net_1437 = ~(net_1335 & net_1503);
  assign net_1503 = (set_19_16_as_r31 | set_15_12_i);
  assign net_1335 = ~(net_302 & net_1639);
  assign net_1495 = (net_835 & net_1504);
  assign net_1504 = (net_1315 | net_360);
  assign net_1315 = ~(net_1261 & net_1640);
  assign net_1261 = ~(iq_instr_dec1_ls_i[26] | a32_only);
  assign net_835 = ~(net_770 | net_1505);
  assign net_1505 = ~(iq_instr_dec1_ls_i[22] | net_1506);
  assign net_1506 = ~(net_1002 & net_1436);
  assign net_1436 = ~(aarch64_state_i | net_4);
  assign net_1002 = (net_238 & net_302);
  assign net_770 = (net_1507 & net_1638);
  assign net_1507 = (net_360 & net_873);
  assign net_1352 = (net_299 & net_1508);
  assign net_1508 = (net_238 & net_67);
  assign net_67 = ~(aarch64_state_i | net_464);
  assign net_238 = ~(iq_instr_dec1_ls_i[24] | net_27);
  assign net_149 = (iq_instr_dec1_ls_i[27] & iq_instr_dec1_ls_i[20]);
  assign rf_rd_need_r0_dec1_ls[2] = (net_1509 | net_1510);
  assign net_1510 = (net_1511 | net_1512);
  assign net_1512 = (net_1513 | net_1514);
  assign net_1514 = (net_1515 | net_1516);
  assign net_1516 = (net_1517 | net_1518);
  assign net_1518 = (iq_instr_dec1_ls_i[21] & net_1519);
  assign net_1519 = ~(net_1520 & net_1521);
  assign net_1521 = ~(net_460 & iq_instr_dec1_ls_i[20]);
  assign net_1520 = (net_15 & net_1522);
  assign net_1522 = ~(net_133 & net_1635);
  assign net_133 = (iq_instr_dec1_ls_i[23] & net_360);
  assign net_1517 = (a32_only & net_1523);
  assign net_1523 = (net_1524 | net_459);
  assign net_1524 = ~(net_1525 & net_1526);
  assign net_1526 = (net_363 | net_269);
  assign net_269 = ~(iq_instr_dec1_ls_i[6] | iq_instr_dec1_ls_i[5]);
  assign net_363 = (iq_instr_dec1_ls_i[24] | net_397);
  assign net_1525 = (net_47 | iq_instr_dec1_ls_i[25]);
  assign net_1515 = (iq_instr_dec1_ls_i[26] & net_1527);
  assign net_1527 = ~(net_1528 & net_1529);
  assign net_1529 = ~(net_39 & net_1530);
  assign net_1528 = (net_1226 & net_40);
  assign net_813 = (net_1637 & net_1639);
  assign net_1226 = ~(iq_instr_dec1_ls_i[21] & net_737);
  assign net_1513 = (net_1531 | net_1532);
  assign net_1532 = (net_1533 | net_1534);
  assign net_1534 = (net_31 & net_1535);
  assign net_1535 = (net_769 | net_1530);
  assign net_1530 = ~(cc_never | net_1635);
  assign net_1533 = (net_460 & net_603);
  assign net_603 = (net_459 & net_1636);
  assign net_1531 = ~(net_1536 & net_376);
  assign net_376 = (net_1165 & net_1537);
  assign net_1537 = (iq_instr_dec1_ls_i[23] | net_406);
  assign net_406 = (net_397 | net_30);
  assign net_460 = (iq_instr_dec1_ls_i[26] & iq_instr_dec1_ls_i[25]);
  assign net_1165 = ~(net_403 & net_39);
  assign net_403 = (iq_instr_dec1_ls_i[20] & net_1051);
  assign net_1051 = (iq_instr_dec1_ls_i[25] & net_225);
  assign net_1536 = (net_112 & net_1538);
  assign net_1538 = ~(net_1065 & net_808);
  assign net_808 = ~(net_47 & net_6);
  assign net_1066 = (iq_instr_dec1_ls_i[21] & net_7);
  assign net_1065 = (net_1057 & net_1635);
  assign net_1057 = (iq_instr_dec1_ls_i[23] & iq_instr_dec1_ls_i[25]);
  assign net_112 = ~(net_73 | str_data_b_sel_dec1_ls[0]);
  assign str_data_b_sel_dec1_ls[0] = (iq_instr_dec1_ls_i[23] & a64_only);
  assign net_73 = (net_1638 & net_1007);
  assign net_1007 = (net_14 & iq_instr_dec1_ls_i[26]);
  assign net_1511 = (net_4 & net_1539);
  assign net_1539 = ~(net_1540 & net_1541);
  assign net_1541 = (net_1542 & net_1543);
  assign net_1543 = (net_1638 | net_1544);
  assign net_1544 = (net_107 & net_1545);
  assign net_1545 = ~(net_360 & net_1546);
  assign net_1546 = ~(net_372 & net_51);
  assign net_360 = (iq_instr_dec1_ls_i[25] & iq_instr_dec1_ls_i[24]);
  assign net_107 = ~(a32_only & net_109);
  assign net_109 = ~(iq_instr_dec1_ls_i[20] | net_1637);
  assign net_1542 = (net_960 & net_115);
  assign net_115 = ~(net_1547 & net_1638);
  assign net_1547 = (net_31 & net_1635);
  assign net_960 = ~(iq_instr_dec1_ls_i[22] & net_110);
  assign net_110 = (a32_only & net_32);
  assign net_1540 = ~(net_1548 | net_1549);
  assign net_1549 = (net_1337 & net_959);
  assign net_1548 = (net_1550 | net_1551);
  assign net_1551 = (net_31 & net_737);
  assign net_675 = (iq_instr_dec1_ls_i[25] | net_32);
  assign net_1550 = (a32_only & net_1552);
  assign net_1552 = ~(net_397 | net_1639);
  assign net_1509 = (iq_instr_dec1_ls_i[27] & net_1553);
  assign net_1553 = (net_1554 | net_1555);
  assign net_1555 = ~(net_1556 & net_1557);
  assign net_1557 = ~(set_19_16_as_r31 & net_1558);
  assign net_1558 = ~(net_1559 & net_1560);
  assign net_1560 = (net_1561 | arm_execution);
  assign net_1561 = (net_1637 | net_1562);
  assign net_1559 = ~(net_1635 | net_1563);
  assign net_1563 = (net_1637 & net_1564);
  assign net_1564 = ~(net_582 & net_1565);
  assign net_1565 = ~(set_19_16_i & net_43);
  assign net_582 = (iq_instr_dec1_ls_i[8] | net_1562);
  assign net_1556 = (net_1566 & net_1173);
  assign net_1173 = ~(iq_instr_dec1_ls_i[28] & net_1413);
  assign net_1413 = (net_214 & net_464);
  assign net_214 = (iq_instr_dec1_ls_i[8] & net_148);
  assign net_1566 = (net_1567 & net_1568);
  assign net_1568 = (net_47 | net_737);
  assign net_737 = (iq_instr_dec1_ls_i[24] & iq_instr_dec1_ls_i[20]);
  assign net_1567 = (net_156 & net_1170);
  assign net_1170 = (iq_instr_dec1_ls_i[28] | net_1636);
  assign net_156 = ~(net_1637 & net_293);
  assign net_1554 = (net_1569 | net_1570);
  assign net_1570 = (net_1571 | net_1572);
  assign net_1572 = (net_1573 | net_1574);
  assign net_1574 = ~(net_1575 & net_1576);
  assign net_1576 = (net_483 & net_1577);
  assign net_1577 = ~(net_701 & aarch64_state_i);
  assign net_701 = (iq_instr_dec1_ls_i[20] & net_959);
  assign net_483 = (net_342 & net_494);
  assign net_494 = ~(net_92 & net_873);
  assign net_873 = ~(iq_instr_dec1_ls_i[15] | iq_instr_dec1_ls_i[14]);
  assign net_92 = (iq_instr_dec1_ls_i[21] & iq_instr_dec1_ls_i[22]);
  assign net_342 = ~(net_299 & net_464);
  assign net_299 = (net_1636 & iq_instr_dec1_ls_i[22]);
  assign net_1575 = (net_1578 & net_1579);
  assign net_1579 = ~(net_178 & net_42);
  assign net_178 = (net_179 & net_959);
  assign net_959 = ~(iq_instr_dec1_ls_i[21] | net_1639);
  assign net_1578 = (net_1580 & net_1581);
  assign net_1581 = ~(net_173 & net_1582);
  assign net_1582 = (net_769 & net_464);
  assign net_464 = (set_19_16_as_r31 | net_4);
  assign net_769 = (iq_instr_dec1_ls_i[21] & net_1637);
  assign net_1580 = (net_173 | net_1463);
  assign net_1463 = ~(set_19_16_i & net_892);
  assign net_1573 = (net_892 & net_715);
  assign net_892 = (net_1637 & net_1635);
  assign net_1571 = ~(net_1583 & net_1584);
  assign net_1584 = (net_372 | net_16);
  assign net_293 = ~(net_17 | net_42);
  assign net_715 = ~(iq_instr_dec1_ls_i[10] | net_173);
  assign net_173 = (iq_instr_dec1_ls_i[8] | net_43);
  assign net_372 = ~(iq_instr_dec1_ls_i[20] & net_1636);
  assign net_1583 = ~(net_1585 | net_1586);
  assign net_1586 = (net_1587 | net_1588);
  assign net_1588 = (net_459 & net_1589);
  assign net_1589 = (net_347 | net_1590);
  assign net_1590 = (set_19_16_i & net_56);
  assign net_347 = (iq_instr_dec1_ls_i[22] & net_619);
  assign net_619 = ~(iq_instr_dec1_ls_i[8] | net_45);
  assign net_164 = (iq_instr_dec1_ls_i[10] & net_1638);
  assign net_459 = (net_1639 & net_1635);
  assign net_1587 = (net_1641 & net_1591);
  assign net_1591 = (net_1592 | net_1337);
  assign net_1337 = (net_225 & net_1635);
  assign net_225 = (iq_instr_dec1_ls_i[23] & net_1637);
  assign net_1592 = (net_1635 & net_1593);
  assign net_1593 = (iq_instr_dec1_ls_i[21] | net_1594);
  assign net_1594 = (iq_instr_dec1_ls_i[11] & net_1639);
  assign net_1585 = (net_545 & net_1595);
  assign net_1595 = (net_1596 | net_1597);
  assign net_1597 = (net_551 & net_1637);
  assign net_551 = ~(iq_instr_dec1_ls_i[8] | net_56);
  assign net_1596 = ~(net_1598 & net_1599);
  assign net_1599 = (net_1177 | iq_instr_dec1_ls_i[8]);
  assign net_1177 = ~(set_15_12_as_r31 & iq_instr_dec1_ls_i[9]);
  assign net_1598 = ~(net_344 | net_1600);
  assign net_344 = (set_3_0_as_r31 & net_227);
  assign net_227 = ~(iq_instr_dec1_ls_i[23] | iq_instr_dec1_ls_i[11]);
  assign net_545 = (iq_instr_dec1_ls_i[28] & net_1635);
  assign net_1569 = (net_4 & net_1601);
  assign net_1601 = (net_1602 | net_1603);
  assign net_1603 = ~(net_397 | net_1604);
  assign net_1604 = ~(net_1605 | net_1606);
  assign net_1606 = ~(set_15_12_i | net_990);
  assign net_990 = (iq_instr_dec1_ls_i[8] | iq_instr_dec1_ls_i[9]);
  assign net_1605 = (net_1607 | net_1600);
  assign net_1600 = (set_15_12_as_r31 & net_43);
  assign net_1607 = (net_1639 & net_1608);
  assign net_1608 = (net_43 | net_1609);
  assign net_1609 = (net_302 & net_1341);
  assign net_1341 = (iq_instr_dec1_ls_i[10] & net_58);
  assign net_302 = (set_15_12_i & net_1641);
  assign net_397 = ~(iq_instr_dec1_ls_i[20] & net_1637);
  assign net_1602 = (net_1610 | net_1611);
  assign net_1611 = (net_1612 | net_1613);
  assign net_1613 = (net_1614 & net_1635);
  assign net_1614 = (net_237 & net_56);
  assign net_237 = (net_11 & net_1641);
  assign net_1612 = ~(net_1562 | net_1615);
  assign net_1615 = ~(net_1616 | net_1617);
  assign net_1617 = ~(set_19_16_as_r31 | net_1637);
  assign net_1616 = (iq_instr_dec1_ls_i[28] & net_1637);
  assign net_1562 = ~(net_148 & net_926);
  assign net_926 = (iq_instr_dec1_ls_i[10] & iq_instr_dec1_ls_i[9]);
  assign net_1610 = (net_53 & net_1618);
  assign net_1618 = (net_43 & net_7);
  assign net_148 = (iq_instr_dec1_ls_i[11] & net_1638);
  assign net_179 = (iq_instr_dec1_ls_i[22] & iq_instr_dec1_ls_i[20]);
  assign net_1619 = ~(net_459 & net_299);
  assign net_1620 = ~(net_4 | net_1619);
  assign net_1621 = ~(net_905 | net_1620);
  assign net_1622 = (set_19_16_as_r31 | net_1621);
  assign net_1623 = (net_902 & net_1622);
  assign net_1624 = (net_85 | net_901);
  assign net_1625 = ~(net_474 & net_1624);
  assign net_1626 = (net_1623 & net_1625);
  assign net_1627 = ~(net_179 & net_348);
  assign net_1628 = (net_1626 & net_1627);
  assign net_1629 = (net_1628 | net_57);
  assign net_1630 = ~(net_474 & net_892);
  assign net_1631 = ~(net_1629 & net_1630);
  assign net_1632 = ~(net_178 | net_1631);
  assign net_1633 = (net_56 | net_889);
  assign net_1634 = ~(net_1632 & net_1633);
  assign net_884 = ~(net_510 & net_1634);
  assign net_1635 = ~iq_instr_dec1_ls_i[20];
  assign net_1636 = ~iq_instr_dec1_ls_i[21];
  assign net_1637 = ~iq_instr_dec1_ls_i[22];
  assign net_1638 = ~iq_instr_dec1_ls_i[23];
  assign net_1639 = ~iq_instr_dec1_ls_i[24];
  assign net_1640 = ~iq_instr_dec1_ls_i[27];
  assign net_1641 = ~set_15_12_as_r31;

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Create the ALU pipe control bus
  // ------------------------------------------------------

  always @*
  begin
    alu_ex2_ctl = {`CA53_ALU_EX2_CTL_W{1'b0}};
    alu_ex1_ctl = {`CA53_ALU_EX1_CTL_W{1'b0}};
    dp_gen_ctl  = {`CA53_ALU_GEN_CTL_W{1'b0}};

    alu_ex2_ctl[`CA53_ALU_EX2_CTL_OP_COMP_SHF_B_BIT]    = ex2_ctl_op_comp_dec1_ls[1];
    alu_ex2_ctl[`CA53_ALU_EX2_CTL_OP_COMP_SHF_A_BIT]    = ex2_ctl_op_comp_dec1_ls[0];
    alu_ex2_ctl[`CA53_ALU_EX2_CTL_LU_CTL_BITS]          = ex2_ctl_au_carry_lu_dec1_ls[3:0];

    alu_ex1_ctl[`CA53_ALU_EX1_CTL_SHIFT_OP_BITS]        = ex1_ctl_shift_op_dec1_ls[2:0];
    alu_ex1_ctl[`CA53_ALU_EX1_CTL_SHIFT_RRX_FOR_0_BITS] = (ex1_ctl_shift_op_dec1_ls == 3'b111) & (iq_instr_dec1_ls_i[11:7] == 5'b00000);

    dp_gen_ctl[`CA53_ALU_CTL_64BIT_OP_BITS]             = aarch64_state_i & alu_valid_dec1_ls; // Writeback is always 64-bit in AArch64
  end

  assign alu_pipectl_dec1_ls_o = {1'b0,
                                  alu_ex2_ctl,
                                  alu_ex1_ctl,
                                  dp_gen_ctl};

  assign ex_pipe_dec1_ls_o[`CA53_EX_PIPE_ALU_BIT]  = alu_valid_dec1_ls;
  assign ex_pipe_dec1_ls_o[`CA53_EX_PIPE_MAC_BIT]  = mac_valid_dec1_ls;
  assign ex_pipe_dec1_ls_o[`CA53_EX_PIPE_BR_BIT]   = br_valid_dec1_ls;
  assign ex_pipe_dec1_ls_o[`CA53_EX_PIPE_DCU_BIT]  = dcu_valid_dec1_ls;
  assign ex_pipe_dec1_ls_o[`CA53_EX_PIPE_DIV_BIT]  = div_valid_dec1_ls;
  assign ex_pipe_dec1_ls_o[`CA53_EX_PIPE_STR_BIT]  = str_valid_dec1_ls;

  // ------------------------------------------------------
  // Data selection mux adjustment to select the PC
  // ------------------------------------------------------
  assign dp_data_a_sel_dec1_ls_o  = ({`CA53_SEL_SHF_A_W{rf_rd_ctl_r0_dec1_ls[`CA53_RD_CTL_PC]}}    & `CA53_SEL_SHF_A_PC)   |
                                    ({`CA53_SEL_SHF_A_W{rf_rd_ctl_r0_dec1_ls[`CA53_RD_CTL_ZR]}}    & `CA53_SEL_SHF_A_ZERO) |
                                    ({`CA53_SEL_SHF_A_W{~(rf_rd_ctl_r0_dec1_ls[`CA53_RD_CTL_PC] |
                                                          rf_rd_ctl_r0_dec1_ls[`CA53_RD_CTL_ZR])}} & dp_data_a_sel_dec1_ls[`CA53_SEL_SHF_A_W-1:0]);

  assign dp_data_b_sel_dec1_ls_o  = (dp_data_b_sel_dec1_ls == `CA53_SEL_SHF_B_R1) ? (rf_rd_ctl_r1_dec1_ls[`CA53_RD_CTL_PC] ? `CA53_SEL_SHF_B_PC   :
                                                                                     rf_rd_ctl_r1_dec1_ls[`CA53_RD_CTL_ZR] ? `CA53_SEL_SHF_B_ZERO :
                                                                                                                             `CA53_SEL_SHF_B_R1)    :
                                                                                    dp_data_b_sel_dec1_ls;

  assign dp_data_c_sel_dec1_ls_o  = rf_rd_ctl_r2_dec1_ls[`CA53_RD_CTL_ZR] ? `CA53_SEL_SHF_C_ZERO : dp_data_c_sel_dec1_ls; // C input Never selects PC

  assign agu_data_b_sel_dec1_ls_o = (agu_data_b_sel_dec1_ls[`CA53_SEL_DCU_B_BIT_R1]) ? (rf_rd_ctl_r1_dec1_ls[`CA53_RD_CTL_ZR] ? `CA53_SEL_DCU_B_ZERO :
                                                                                                                                agu_data_b_sel_dec1_ls) :
                                                                                       agu_data_b_sel_dec1_ls;

  // A store pair of X registers can use both store pipes to store 128-bits
  // in a single memory transaction. The decoder indicates this by setting
  // str_data_b_sel to a special value.
  assign str1_sel_dec1_ls = (str_data_b_sel_dec1_ls == `CA53_SEL_STR_B_STR1);
  assign str1_sel_dec1_ls_o = str1_sel_dec1_ls; // Indicate this case to decoder top level for muxing

  assign str_data_a_sel_dec1_ls_o = (str_data_a_sel_dec1_ls == `CA53_SEL_STR_A_R1) ? (rf_rd_ctl_r1_dec1_ls[`CA53_RD_CTL_ZR]  ? `CA53_SEL_STR_A_ZERO :
                                                                                      rf_rd_ctl_r1_dec1_ls[`CA53_RD_CTL_PC]  ? `CA53_SEL_STR_A_PC   :
                                                                                                                               `CA53_SEL_STR_A_R1)    :
                                    (str_data_a_sel_dec1_ls == `CA53_SEL_STR_A_R2) ? (rf_rd_ctl_r2_dec1_ls[`CA53_RD_CTL_ZR]  ? `CA53_SEL_STR_A_ZERO :
                                                                                      rf_rd_ctl_r2_dec1_ls[`CA53_RD_CTL_PC]  ? `CA53_SEL_STR_A_PC   :
                                                                                                                               `CA53_SEL_STR_A_R2)    :
                                                                                     str_data_a_sel_dec1_ls;

  assign str_data_b_sel_dec1_ls_o = (str_data_b_sel_dec1_ls == `CA53_SEL_STR_B_R2)   ? (rf_rd_ctl_r2_dec1_ls[`CA53_RD_CTL_ZR]  ? `CA53_SEL_STR_B_ZERO :
                                                                                        rf_rd_ctl_r2_dec1_ls[`CA53_RD_CTL_PC]  ? `CA53_SEL_STR_B_PC   :
                                                                                                                                 `CA53_SEL_STR_B_R2)    :
                                    (((str_data_b_sel_dec1_ls == `CA53_SEL_STR_B_A_H) |
                                      str1_sel_dec1_ls) &
                                     (str_data_a_sel_dec1_ls == `CA53_SEL_STR_A_R1)) ? (rf_rd_ctl_r1_dec1_ls[`CA53_RD_CTL_ZR]  ? `CA53_SEL_STR_B_ZERO :
                                                                                                                                 `CA53_SEL_STR_B_A_H)   :
                                    ((str_data_b_sel_dec1_ls == `CA53_SEL_STR_B_A_H) &
                                     (str_data_a_sel_dec1_ls == `CA53_SEL_STR_A_R2)) ? (rf_rd_ctl_r2_dec1_ls[`CA53_RD_CTL_ZR]  ? `CA53_SEL_STR_B_ZERO :
                                                                                                                                 `CA53_SEL_STR_B_A_H)   :
                                                                                                                                 str_data_b_sel_dec1_ls;

  assign str_b_valid_dec1_ls_o    = (str_data_b_sel_dec1_ls != `CA53_SEL_STR_B_ZERO);

  // Indicate when store pipe used for 64-bit, even if selecting ZR (required to ensure correct forwarding)
  assign ctl_64bit_op_str_dec1_ls_o = (str_data_b_sel_dec1_ls == `CA53_SEL_STR_B_A_H) | str1_sel_dec1_ls;

  // Second store pipe control signals come from R2
  assign str1_data_a_sel_dec1_ls_o = rf_rd_ctl_r2_dec1_ls[`CA53_RD_CTL_ZR] ? `CA53_SEL_STR_A_ZERO :
                                                                             `CA53_SEL_STR_A_R2;

  assign str1_data_b_sel_dec1_ls_o = rf_rd_ctl_r2_dec1_ls[`CA53_RD_CTL_ZR] ? `CA53_SEL_STR_B_ZERO :
                                                                             `CA53_SEL_STR_B_A_H;

  // ------------------------------------------------------
  // Register file address and enable generation
  // ------------------------------------------------------

  // Read enables (address muxing done at De top level)
  assign rf_rd_en_r0_dec1_ls_o = rf_rd_ctl_r0_dec1_ls[`CA53_RD_CTL_EN];
  assign rf_rd_en_r1_dec1_ls_o = rf_rd_ctl_r1_dec1_ls[`CA53_RD_CTL_EN];
  assign rf_rd_en_r2_dec1_ls_o = rf_rd_ctl_r2_dec1_ls[`CA53_RD_CTL_EN];

  // Write addresses
  assign top_19_16 = iq_instr_dec1_ls_i[30] & aarch64_state_i;
  assign top_15_12 = iq_instr_dec1_ls_i[29] & aarch64_state_i;

  assign rf_wr_vaddr_w0_dec1_ls_o = ({5{rf_wr_ctl_w0_dec1_ls[`CA53_WR_CTL_15_12]}} & {top_15_12, iq_instr_dec1_ls_i[15:12]});
  assign rf_wr_vaddr_w1_dec1_ls_o = ({5{rf_wr_ctl_w1_dec1_ls[`CA53_WR_CTL_19_16]}} & {top_19_16, iq_instr_dec1_ls_i[19:16]});

  // If writeback is specified, but the writeback register is also a transfer
  // register, then suppress the writeback
  assign suppress_writeback = rf_wr_ctl_w1_dec1_ls[`CA53_WR_CTL_19_16] &
                              (({top_19_16, iq_instr_dec1_ls_i[19:16]} == {top_15_12, iq_instr_dec1_ls_i[15:12]}) & rf_wr_ctl_w0_dec1_ls[`CA53_WR_CTL_15_12]);

  // Write enables
  assign rf_wr_en_w0_dec1_ls_o = rf_wr_ctl_w0_dec1_ls[`CA53_WR_CTL_EN];
  assign rf_wr_en_w1_dec1_ls_o = rf_wr_ctl_w1_dec1_ls[`CA53_WR_CTL_EN] & ~suppress_writeback;

  assign rf_wr_64b_w0_dec1_ls_o = reg_access_64bit_dec1_ls;
  assign rf_wr_64b_w1_dec1_ls_o = aarch64_state_i; // Write-back is always 64-bit

  // ------------------------------------------------------
  // Immediate generation
  // ------------------------------------------------------

  ca53dpu_dec_imm_ls u_dec_imm_ls (
    // Inputs
    .imm_sel_ls_i         (imm_sel_ls_dec1_ls[9:0]),
    .instr_i              (iq_instr_dec1_ls_i[32:0]),
    .ex1_ctl_shift_op_i   (ex1_ctl_shift_op_dec1_ls[`CA53_SHIFT_OP_W-1:0]),
    .aarch64_state_i      (aarch64_state_i),
    .ls_elem_size_i       (ls_elem_size_dec1_ls[1:0]),
    .num_lsm_registers_i  (5'b00000),
    // Outputs
    .imm_data_ls_o        (imm_data_dec1_ls_o[`CA53_IMM_DATA_W-1:0]),
    .imm_shift_ls_o       (imm_shift_dec1_ls_o[`CA53_IMM_SHIFT_W-1:0]),
    .imm_data_sel_ls_o    ()  // Only used by TBB which is not D1
  );

  // ------------------------------------------------------
  // Output aliases
  // ------------------------------------------------------

  assign rf_rd_need_r0_dec1_ls_o       = rf_rd_need_r0_dec1_ls;
  assign rf_rd_need_r1_dec1_ls_o       = rf_rd_need_r1_dec1_ls;
  assign rf_rd_need_r2_dec1_ls_o       = rf_rd_need_r2_dec1_ls;
  assign rf_wr_src_w0_dec1_ls_o        = rf_wr_src_w0_dec1_ls;
  assign rf_wr_src_w1_dec1_ls_o        = rf_wr_src_w1_dec1_ls;
  assign rf_wr_when_w0_dec1_ls_o       = rf_wr_when_w0_dec1_ls;
  assign rf_wr_when_w1_dec1_ls_o       = rf_wr_when_w1_dec1_ls;
  assign word_align_pc_dec1_ls_o       = word_align_pc_dec1_ls;
  assign head_instr_dec1_ls_o          = head_instr_dec1_ls;
  assign agu_data_a_sel_dec1_ls_o      = agu_data_a_sel_dec1_ls;
  assign req_strict_algn_dec1_ls_o     = req_strict_algn_dec1_ls;
  assign check_x64_dec1_ls_o           = check_x64_dec1_ls;
  assign algn_size_dec1_ls_o           = algn_size_dec1_ls;
  assign ls_store_dec1_ls_o            = ls_store_dec1_ls;
  assign ls_elem_size_dec1_ls_o        = ls_elem_size_dec1_ls;
  assign ls_size_dec1_ls_o             = ls_size_dec1_ls;
  assign ls_length_dec1_ls_o           = ls_length_dec1_ls;
  assign force_usr_priv_mem_dec1_ls_o  = force_usr_priv_mem_dec1_ls;
  assign agu_shf_value_dec1_ls_o       = agu_shf_value_dec1_ls;
  assign agu_sub_b_dec1_ls_o           = agu_sub_b_dec1_ls;
  assign ls_instr_type_dec1_ls_o       = ls_instr_type_dec1_ls;

  // The register number of the Rt operand of the faulting instruction for syndrome information
  assign ls_synd_srt_dec1_ls_o = {top_15_12, iq_instr_dec1_ls_i[15:12]};

  // Indicate ISV set if Rt is not R15 (in AA32)
  assign ls_isv_set_dec1_ls_o = isv_set_dec1_ls & ~((iq_instr_dec1_ls_i[15:12] == 4'b1111) & ~aarch64_state_i);

  assign ls_synd_sf_dec1_ls_o = reg_access_64bit_dec1_ls;

endmodule // ca53dpu_dec1_ls

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
