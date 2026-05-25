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
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract: Decoder for Neon instructions
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"
`include "ca53_dpu_dcu_defs.v"

module ca53dpu_dec1_neon (
  // Inputs
  input  wire                          [32:0] iq_instr_dec1_ne_i,     // Instruction input
  input  wire                                 aarch64_state_i,
  input  wire                           [1:0] pdtype_i,
  // Outputs
  output wire                                 rf_rd_en_r0_dec1_ne_o,
  output wire                                 rf_rd_en_r1_dec1_ne_o,
  output wire                                 rf_rd_en_r2_dec1_ne_o,
  output wire        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_dec1_ne_o,
  output wire        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_dec1_ne_o,
  output wire                                 rf_wr_en_w0_dec1_ne_o,
  output wire                           [4:0] rf_wr_vaddr_w0_dec1_ne_o,
  output wire                                 rf_wr_en_w1_dec1_ne_o,
  output wire                                 rf_wr_64b_w1_dec1_ne_o,
  output wire                           [4:0] rf_wr_vaddr_w1_dec1_ne_o,
  output wire      [`CA53_RF_WR_SRC_W0_W-1:0] rf_wr_src_w0_dec1_ne_o,
  output wire      [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_dec1_ne_o,
  output wire        [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w0_dec1_ne_o,
  output wire        [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_dec1_ne_o,
  output wire                           [1:0] rf_rd_en_fr0_dec1_ne_o,
  output wire                           [1:0] rf_rd_en_fr1_dec1_ne_o,
  output wire                           [1:0] rf_rd_en_fr2_dec1_ne_o,
  output wire     [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr0_dec1_ne_o,
  output wire     [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr1_dec1_ne_o,
  output wire     [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr2_dec1_ne_o,
  output wire       [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr0_dec1_ne_o,
  output wire       [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr1_dec1_ne_o,
  output wire       [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr2_dec1_ne_o,
  output wire                           [3:0] rf_wr_en_fw0_dec1_ne_o,
  output wire     [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw0_dec1_ne_o,
  output wire        [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_dec1_ne_o,
  output wire       [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw0_dec1_ne_o,
  output wire         [`CA53_SEL_SHF_A_W-1:0] dp_data_a_sel_dec1_ne_o,
  output wire         [`CA53_SEL_SHF_B_W-1:0] dp_data_b_sel_dec1_ne_o,
  output wire         [`CA53_SEL_SHF_C_W-1:0] dp_data_c_sel_dec1_ne_o,
  output wire         [`CA53_SEL_DCU_A_W-1:0] agu_data_a_sel_dec1_ne_o,
  output wire         [`CA53_SEL_DCU_B_W-1:0] agu_data_b_sel_dec1_ne_o,
  output wire         [`CA53_SEL_STR_A_W-1:0] str_data_a_sel_dec1_ne_o,
  output wire         [`CA53_SEL_STR_B_W-1:0] str_data_b_sel_dec1_ne_o,
  output wire                                 str1_sel_dec1_ne_o,
  output wire         [`CA53_SEL_STR_A_W-1:0] str1_data_a_sel_dec1_ne_o,
  output wire         [`CA53_SEL_STR_B_W-1:0] str1_data_b_sel_dec1_ne_o,
  output wire                                 str_b_valid_dec1_ne_o,
  output wire                                 ctl_64bit_op_str_dec1_ne_o,
  output wire           [`CA53_EX_PIPE_W-1:0] ex_pipe_dec1_ne_o,
  output reg           [`CA53_IMM_DATA_W-1:0] imm_data_dec1_ne_o,
  output reg          [`CA53_IMM_SHIFT_W-1:0] imm_shift_dec1_ne_o,
  output wire       [`CA53_ALU_PIPECTL_W-1:0] alu_pipectl_dec1_ne_o,
  output reg                                  req_strict_algn_dec1_ne_o,
  output wire                                 check_x64_dec1_ne_o,
  output reg                            [2:0] algn_size_dec1_ne_o,
  output wire                                 wd_align_pc_dec1_ne_o,
  output wire                                 ls_store_dec1_ne_o,
  output wire     [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_dec1_ne_o,
  output wire                           [2:0] ls_size_dec1_ne_o,
  output wire                           [2:0] ls_elem_size_dec1_ne_o,
  output wire                           [5:0] ls_length_dec1_ne_o,
  output wire                           [2:0] agu_shf_value_dec1_ne_o,
  output wire                                 agu_sub_b_dec1_ne_o,
  output wire                                 fmac_valid_sp_dec1_ne_o,
  output wire                                 neon_can_fwd_acc_dec1_ne_o,
  output wire                           [2:0] mul_neon_out_fmt_dec1_ne_o,
  output wire        [`CA53_FP_EX_PIPE_W-1:0] fp_ex_pipe_dec1_ne_o,
  output wire     [`CA53_FLAGEN_INSTR1_W-1:0] flag_en_dec1_ne_o,
  output wire                                 instr_fmstat_dec1_ne_o,
  output wire  [`CA53_SLOT1_INSTR_TYPE_W-1:0] slot1_instr_type_dec1_ne_o
);

  // -----------------------------
  // Constant declarations
  // -----------------------------

  localparam NEON_REG_CTL_W = 21;

  localparam [2:0] ALIGN_TYPE_DEFAULT       = 3'b000;
  localparam [2:0] ALIGN_TYPE_MUL           = 3'b001;
  localparam [2:0] ALIGN_TYPE_VLD1_SGL      = 3'b010;
  localparam [2:0] ALIGN_TYPE_VLD2_SGL      = 3'b011;
  localparam [2:0] ALIGN_TYPE_VLD4_SGL_ONE  = 3'b100;
  localparam [2:0] ALIGN_TYPE_VLD4_SGL_ALL  = 3'b101;
  localparam [2:0] ALIGN_TYPE_VFP           = 3'b110;
  localparam [2:0] ALIGN_TYPE_AARCH64       = 3'b111;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg         [`CA53_ALU_GEN_CTL_W-1:0] dp_gen_ctl;
  reg         [`CA53_ALU_EX1_CTL_W-1:0] alu_ex1_ctl;
  reg         [`CA53_ALU_EX2_CTL_W-1:0] dp_ex2_ctl;
  reg                                   dp_wr_ctl;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire         [`CA53_FP_EX_PIPE_W-1:0] fp_ex_pipe_dec1_ne;
  wire                                  wd_align_pc_dec1_ne;
  wire                                  ls_store_dec1_ne;
  wire                            [5:0] ls_length_dec1_ne;
  wire                            [2:0] agu_shf_value_dec1_ne;
  wire                            [4:0] sm_plus1;
  wire                            [5:0] psr_wr_en_dec1_ne;
  wire          [`CA53_SEL_SHF_A_W-1:0] dp_data_a_sel_dec1_ne;
  wire          [`CA53_SEL_SHF_B_W-1:0] dp_data_b_sel_dec1_ne;
  wire          [`CA53_SEL_SHF_C_W-1:0] dp_data_c_sel_dec1_ne;
  wire          [`CA53_SEL_DCU_A_W-1:0] agu_data_a_sel_dec1_ne;
  wire          [`CA53_SEL_DCU_B_W-1:0] agu_data_b_sel_dec1_ne;
  wire          [`CA53_SEL_STR_A_W-1:0] str_data_a_sel_dec1_ne;
  wire          [`CA53_SEL_STR_B_W-1:0] str_data_b_sel_dec1_ne;
  wire                                  ctl_64bit_op_dec1_ne;
  wire                            [1:0] ex2_ctl_flag_set_dec1_ne;
  wire             [`CA53_LU_CTL_W-1:0] ex2_ctl_au_carry_lu_dec1_ne;
  wire                            [2:0] ex1_ctl_mask_sel_dec1_ne;
  wire           [`CA53_IMM_NEON_W-1:0] imm_sel_neon_dec1_ne;
  wire                                  set_19_16_i;
  wire                                  set_3_0_i;
  wire                                  set_19_16_as_r31;
  wire                                  set_15_12_as_r31;
  wire                                  set_3_0_as_r31;
  wire                                  set_3_0_as_r13_i;
  wire                            [2:0] rf_rd_ctl_r0_dec1_ne;
  wire                            [2:0] rf_rd_ctl_r1_dec1_ne;
  wire                            [2:0] rf_rd_ctl_r2_dec1_ne;
  wire         [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_dec1_ne;
  wire         [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_dec1_ne;
  wire                           [12:0] rf_wr_ctl_w0_dec1_ne;
  wire                           [12:0] rf_wr_ctl_w1_dec1_ne;
  wire                                  rf_wr_64b_w1_dec1_ne;
  wire       [`CA53_RF_WR_SRC_W0_W-1:0] rf_wr_src_w0_dec1_ne;
  wire       [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_dec1_ne;
  wire         [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w0_dec1_ne;
  wire         [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_dec1_ne;
  wire      [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_dec1_ne;
  wire                            [2:0] ls_size_dec1_ne;
  wire                            [3:0] raw_lsm_immed_dec1_ne;
  wire                            [2:0] neon_elem_size_dec1_ne;
  wire                            [2:0] neon_lsm_aligntype_dec1_ne;
  wire             [NEON_REG_CTL_W-1:0] rf_rd_ctl_fr0_dec1_ne;
  wire             [NEON_REG_CTL_W-1:0] rf_rd_ctl_fr1_dec1_ne;
  wire             [NEON_REG_CTL_W-1:0] rf_rd_ctl_fr2_dec1_ne;
  wire        [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr0_dec1_ne;
  wire        [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr1_dec1_ne;
  wire        [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr2_dec1_ne;
  wire             [NEON_REG_CTL_W-1:0] rf_wr_ctl_fw0_dec1_ne;
  wire         [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_dec1_ne;
  wire        [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw0_dec1_ne;
  wire      [`CA53_FP_RF_WR_ADDR_W-2:0] rf_wr_addr_fw0_aa32;
  wire      [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw0_aa64;
  wire                            [3:0] raw_rf_wr_en_fw0_aa32;
  wire                            [3:0] raw_rf_wr_en_fw0_aa64;
  wire                            [3:0] raw_rf_wr_en_fw0_dec1_ne;
  wire                                  select_high_64bits_dec1_ne;
  wire                                  a64_only;
  wire                                  sf_bit;
  wire                                  m_bit;
  wire                                  alu_valid_dec1_ne;
  wire                                  dcu_valid_dec1_ne;
  wire                                  str_valid_dec1_ne;
  wire                                  str1_sel_dec1_ne;
  wire                                  check_x64_dec1_ne;
  wire                                  agu_sub_b_dec1_ne;
  wire                                  fmac_valid_sp_dec1_ne;
  wire                                  neon_can_fwd_acc_dec1_ne;
  wire                            [2:0] mul_neon_out_fmt_dec1_ne;
  wire                                  instr_fmstat_dec1_ne;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Input signals for espresso equations (non-registered)
  // ------------------------------------------------------

  assign set_19_16_i = (iq_instr_dec1_ne_i[19:16] == 4'b1111) & ~aarch64_state_i;
  assign set_3_0_i   = aarch64_state_i ? ~iq_instr_dec1_ne_i[29] : (iq_instr_dec1_ne_i[ 3: 0] == 4'b1111);

  assign set_19_16_as_r31 = ({iq_instr_dec1_ne_i[30], iq_instr_dec1_ne_i[19:16]} == 5'b11111) & aarch64_state_i;
  assign set_15_12_as_r31 = ({iq_instr_dec1_ne_i[29], iq_instr_dec1_ne_i[15:12]} == 5'b11111) & aarch64_state_i;
  assign set_3_0_as_r31   = ({iq_instr_dec1_ne_i[31], iq_instr_dec1_ne_i[3:0]}   == 5'b11111) & aarch64_state_i;

  assign set_3_0_as_r13_i = aarch64_state_i ? (iq_instr_dec1_ne_i[29] & set_3_0_as_r31) : (iq_instr_dec1_ne_i[ 3: 0] == 4'b1101);

  assign a64_only = pdtype_i[0] & aarch64_state_i;

  assign sf_bit = iq_instr_dec1_ne_i[32] & aarch64_state_i;
  assign m_bit  = iq_instr_dec1_ne_i[31] & aarch64_state_i;

  // ------------------------------------------------------
  // Start automatically generated logic
  // ------------------------------------------------------

  wire    net_1, net_2, net_3, net_4, net_5, net_6,
         net_7, net_8, net_9, net_10, net_11, net_12, net_13, net_14, net_17,
         net_18, net_19, net_20, net_21, net_22, net_24, net_25, net_26,
         net_28, net_29, net_30, net_31, net_32, net_33, net_34, net_35,
         net_36, net_37, net_39, net_40, net_41,
         net_42, net_43, net_44, net_45, net_47, net_48, net_49, net_50,
         net_52, net_54, net_55, net_56, net_57, net_58, net_59, net_60,
         net_61, net_62, net_63, net_64, net_66, net_67, net_68, net_69,
         net_72, net_73, net_74, net_75, net_77, net_78, net_79, net_80,
         net_81, net_82, net_83, net_84, net_85, net_86, net_87, net_88,
         net_89, net_90, net_91, net_92, net_93, net_94, net_95, net_96,
         net_97, net_98, net_99, net_100, net_101, net_102, net_103, net_104,
         net_105, net_106, net_107, net_108, net_109, net_110, net_111,
         net_112, net_113, net_114, net_115, net_116, net_117, net_118,
         net_119, net_120, net_121, net_122, net_123, net_124, net_125,
         net_126, net_127, net_128, net_129, net_130, net_131, net_132,
         net_133, net_134, net_135, net_136, net_137, net_138, net_139,
         net_140, net_141, net_142, net_146, net_154, net_155, net_156,
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
         net_500, net_501, net_502, net_503, net_507, net_508, net_509,
         net_510, net_511, net_512, net_513, net_514, net_515, net_516,
         net_517, net_518, net_519, net_520, net_521, net_522, net_523,
         net_524, net_525, net_526, net_527, net_528, net_529, net_530,
         net_531, net_532, net_533, net_534, net_535, net_536, net_537,
         net_538, net_539, net_540, net_541, net_542, net_543, net_544,
         net_545, net_546, net_547, net_548, net_549, net_550, net_551,
         net_552, net_553, net_554, net_555, net_556, net_557, net_558,
         net_559, net_560, net_561, net_562, net_563, net_564, net_565,
         net_566, net_567, net_568, net_569, net_570, net_571, net_572,
         net_573, net_574, net_575, net_576, net_577, net_578, net_579,
         net_580, net_581, net_582, net_583, net_584, net_585, net_586,
         net_587, net_588, net_589, net_590, net_591, net_592, net_593,
         net_594, net_595, net_596, net_597, net_598, net_599, net_600,
         net_601, net_602, net_603, net_604, net_605, net_606, net_607,
         net_608, net_609, net_610, net_611, net_612, net_613, net_614,
         net_615, net_616, net_617, net_618, net_619, net_620, net_621,
         net_622, net_623, net_624, net_625, net_626, net_627, net_628,
         net_629, net_630, net_631, net_632, net_633, net_634, net_635,
         net_636, net_637, net_638, net_639, net_640, net_641, net_642,
         net_643, net_644, net_645, net_646, net_647, net_648, net_649,
         net_650, net_651, net_652, net_653, net_654, net_655, net_656,
         net_657, net_658, net_659, net_660, net_661, net_662, net_663,
         net_664, net_665, net_666, net_667, net_668, net_669, net_670,
         net_671, net_672, net_673, net_674, net_675, net_676, net_677,
         net_678, net_679, net_680, net_681, net_682, net_683, net_684,
         net_685, net_686, net_687, net_688, net_689, net_690, net_691,
         net_692, net_693, net_694, net_695, net_696, net_697, net_698,
         net_699, net_700, net_701, net_702, net_703, net_704, net_705,
         net_706, net_707, net_708, net_709, net_710, net_711, net_712,
         net_713, net_714, net_715, net_716, net_717, net_718, net_719,
         net_720, net_721, net_722, net_723, net_724, net_725, net_726,
         net_727, net_728, net_729, net_730, net_731, net_732, net_733,
         net_734, net_735, net_736, net_737, net_738, net_739, net_740,
         net_741, net_742, net_743, net_744, net_745, net_746, net_747,
         net_748, net_749, net_750, net_751, net_752, net_753, net_754,
         net_755, net_756, net_757, net_758, net_759, net_760, net_761,
         net_762, net_763, net_764, net_765, net_766, net_767, net_768,
         net_769, net_770, net_771, net_772, net_773, net_774, net_775,
         net_776, net_777, net_778, net_779, net_780, net_781, net_782,
         net_783, net_784, net_785, net_786, net_787, net_788, net_789,
         net_790, net_791, net_792, net_793, net_794, net_795, net_796,
         net_797, net_798, net_799, net_800, net_801, net_802, net_803,
         net_804, net_805, net_806, net_807, net_808, net_809, net_810,
         net_811, net_812, net_813, net_814, net_815, net_816, net_817,
         net_818, net_819, net_820, net_821, net_822, net_823, net_824,
         net_825, net_826, net_827, net_828, net_829, net_830, net_831,
         net_832, net_833, net_834, net_835, net_836, net_837, net_838,
         net_839, net_840, net_841, net_842, net_843, net_844, net_845,
         net_846, net_847, net_848, net_849, net_850, net_851, net_852,
         net_853, net_854, net_855, net_856, net_857, net_858, net_859,
         net_860, net_861, net_862, net_863, net_864, net_865, net_866,
         net_867, net_868, net_869, net_870, net_871, net_872, net_873,
         net_874, net_875, net_876, net_877, net_878, net_879, net_880,
         net_881, net_882, net_883, net_884, net_885, net_886, net_887,
         net_888, net_889, net_890, net_891, net_892, net_893, net_894,
         net_895, net_896, net_897, net_898, net_899, net_900, net_901,
         net_902, net_903, net_904, net_905, net_906, net_907, net_908,
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
         net_1574, net_1575, net_1576, net_1577, net_1578, net_1580, net_1581,
         net_1582, net_1583, net_1584, net_1585, net_1586, net_1587, net_1588,
         net_1589, net_1590, net_1591, net_1592, net_1593, net_1594, net_1595,
         net_1596, net_1597, net_1598, net_1599, net_1600, net_1601, net_1602,
         net_1603, net_1604, net_1605, net_1606, net_1607, net_1608, net_1609,
         net_1610, net_1611, net_1612, net_1613, net_1614, net_1615, net_1616,
         net_1617, net_1618, net_1619, net_1620, net_1621, net_1622, net_1623,
         net_1624, net_1625, net_1626, net_1627, net_1628, net_1629, net_1630,
         net_1631, net_1632, net_1633, net_1634, net_1635, net_1636, net_1637,
         net_1638, net_1639, net_1640, net_1641, net_1642, net_1643, net_1644,
         net_1645, net_1646, net_1647, net_1648, net_1649, net_1650, net_1651,
         net_1652, net_1653, net_1654, net_1655, net_1656, net_1657, net_1658,
         net_1659, net_1660, net_1661, net_1662, net_1663, net_1664, net_1665,
         net_1666, net_1667, net_1668, net_1669, net_1670, net_1671, net_1672,
         net_1673, net_1674, net_1675, net_1676, net_1677, net_1678, net_1679,
         net_1680, net_1681, net_1682, net_1683, net_1684, net_1685, net_1686,
         net_1687, net_1688, net_1689, net_1690, net_1691, net_1692, net_1693,
         net_1694, net_1695, net_1696, net_1697, net_1698, net_1699, net_1700,
         net_1701, net_1702, net_1703, net_1704, net_1705, net_1706, net_1707,
         net_1708, net_1709, net_1710, net_1711, net_1712, net_1713, net_1714,
         net_1715, net_1716, net_1717, net_1718, net_1719, net_1730, net_1735,
         net_1738, net_1739, net_1740, net_1741, net_1742, net_1743, net_1744,
         net_1745, net_1746, net_1747, net_1748, net_1749, net_1750, net_1751,
         net_1752, net_1753, net_1754, net_1755, net_1756, net_1757, net_1758,
         net_1759, net_1760, net_1761, net_1762, net_1763, net_1764, net_1765,
         net_1766, net_1767, net_1768, net_1769, net_1770, net_1771, net_1772,
         net_1773, net_1774, net_1775, net_1776, net_1777, net_1778, net_1779,
         net_1780, net_1781, net_1782, net_1783, net_1784, net_1785, net_1786,
         net_1787, net_1788, net_1789, net_1790, net_1791, net_1792, net_1793,
         net_1794, net_1795, net_1796, net_1797, net_1798, net_1799, net_1800,
         net_1801, net_1802, net_1803, net_1804, net_1805, net_1806, net_1807,
         net_1808, net_1809, net_1810, net_1811, net_1812, net_1813, net_1814,
         net_1815, net_1816, net_1817, net_1818, net_1819, net_1820, net_1821,
         net_1822, net_1823, net_1824, net_1825, net_1826, net_1827, net_1828,
         net_1829, net_1830, net_1831, net_1832, net_1833, net_1834, net_1835,
         net_1836, net_1837, net_1838, net_1839, net_1840, net_1841, net_1842,
         net_1843, net_1844, net_1845, net_1846, net_1847, net_1848, net_1849,
         net_1850, net_1851, net_1852, net_1853, net_1854, net_1855, net_1856,
         net_1857, net_1858, net_1859, net_1860, net_1861, net_1862, net_1863,
         net_1864, net_1865, net_1866, net_1867, net_1868, net_1869, net_1870,
         net_1871, net_1872, net_1873, net_1874, net_1875, net_1876, net_1877,
         net_1878, net_1879, net_1880, net_1881, net_1882, net_1883, net_1884,
         net_1885, net_1886, net_1887, net_1888, net_1889, net_1890, net_1891,
         net_1892, net_1893, net_1894, net_1895, net_1896, net_1897, net_1898,
         net_1899, net_1900, net_1901, net_1902, net_1903, net_1904, net_1905,
         net_1906, net_1907, net_1908, net_1909, net_1910, net_1911, net_1912,
         net_1913, net_1914, net_1915, net_1916, net_1917, net_1918, net_1919,
         net_1920, net_1921, net_1922, net_1923, net_1924, net_1925, net_1926,
         net_1927, net_1928, net_1929, net_1930, net_1931, net_1932, net_1933,
         net_1934, net_1935, net_1936, net_1937, net_1938, net_1939, net_1940,
         net_1941, net_1942, net_1943, net_1944, net_1945, net_1946, net_1947,
         net_1948, net_1949, net_1950, net_1951, net_1952, net_1953, net_1954,
         net_1955, net_1956, net_1957, net_1958, net_1959, net_1960, net_1961,
         net_1962, net_1963, net_1964, net_1965, net_1966, net_1967, net_1968,
         net_1969, net_1970, net_1971, net_1972, net_1973, net_1974, net_1975,
         net_1976, net_1977, net_1978, net_1979, net_1980, net_1981, net_1982,
         net_1983, net_1984, net_1985, net_1986, net_1987, net_1988, net_1989,
         net_1990, net_1991, net_1992, net_1993, net_1994, net_1995, net_1996,
         net_1997, net_1998, net_1999, net_2000, net_2001, net_2002, net_2003,
         net_2004, net_2005, net_2006, net_2007, net_2008, net_2009, net_2010,
         net_2011, net_2012, net_2013, net_2014, net_2015, net_2016, net_2017,
         net_2018, net_2019, net_2020, net_2021, net_2022, net_2023, net_2024,
         net_2025, net_2026, net_2027, net_2028, net_2029, net_2030, net_2031,
         net_2032, net_2033, net_2034, net_2035, net_2036, net_2037, net_2038,
         net_2039, net_2040, net_2041, net_2042, net_2043, net_2044, net_2045,
         net_2046, net_2047, net_2048, net_2049, net_2050, net_2051, net_2052,
         net_2053, net_2054, net_2055, net_2056, net_2057, net_2058, net_2059,
         net_2060, net_2061, net_2062, net_2063, net_2064, net_2065, net_2066,
         net_2067, net_2068, net_2069, net_2070, net_2071, net_2072, net_2073,
         net_2074, net_2075, net_2076, net_2077, net_2078, net_2079, net_2080,
         net_2081, net_2082, net_2083, net_2084, net_2085, net_2086, net_2087,
         net_2088, net_2089, net_2090, net_2091, net_2092, net_2093, net_2094,
         net_2095, net_2096, net_2097, net_2098, net_2099, net_2100, net_2101,
         net_2102, net_2103, net_2104, net_2105, net_2106, net_2107, net_2108,
         net_2109, net_2110, net_2111, net_2112, net_2113, net_2114, net_2115,
         net_2116, net_2117, net_2118, net_2119, net_2120, net_2121, net_2122,
         net_2123, net_2124, net_2125, net_2126, net_2127, net_2128, net_2129,
         net_2130, net_2131, net_2132, net_2133, net_2134, net_2135, net_2136,
         net_2137, net_2138, net_2139, net_2140, net_2141, net_2142, net_2143,
         net_2144, net_2145, net_2146, net_2147, net_2148, net_2149, net_2150,
         net_2151, net_2152, net_2153, net_2154, net_2155, net_2156, net_2157,
         net_2158, net_2159, net_2160, net_2161, net_2162, net_2163, net_2164,
         net_2165, net_2166, net_2167, net_2168, net_2169, net_2170;

  assign rf_rd_need_r0_dec1_ne[1] = rf_rd_need_r0_dec1_ne[2];
  assign agu_data_a_sel_dec1_ne[0] = rf_rd_need_r0_dec1_ne[2];
  assign rf_wr_ctl_w0_dec1_ne[0] = rf_wr_ctl_w0_dec1_ne[1];
  assign dp_data_b_sel_dec1_ne[0] = rf_wr_ctl_w1_dec1_ne[1];
  assign dp_data_a_sel_dec1_ne[0] = rf_wr_ctl_w1_dec1_ne[1];
  assign rf_wr_when_w1_dec1_ne[1] = rf_wr_when_w1_dec1_ne[2];
  assign rf_wr_src_w1_dec1_ne[2] = rf_wr_when_w1_dec1_ne[2];
  assign str_data_a_sel_dec1_ne[0] = str_data_a_sel_dec1_ne[1];
  assign check_x64_dec1_ne = dcu_valid_dec1_ne;
  assign rf_rd_ctl_fr1_dec1_ne[10] = rf_rd_ctl_fr1_dec1_ne[5];
  assign rf_rd_ctl_fr2_dec1_ne[10] = rf_rd_ctl_fr2_dec1_ne[5];
  assign rf_wr_ctl_fw0_dec1_ne[0] = rf_wr_ctl_fw0_dec1_ne[1];
  assign ex2_ctl_au_carry_lu_dec1_ne[3] = imm_sel_neon_dec1_ne[19];
  assign ex1_ctl_mask_sel_dec1_ne[2] = imm_sel_neon_dec1_ne[19];
  assign dp_data_c_sel_dec1_ne[1] = imm_sel_neon_dec1_ne[19];
  assign ex1_ctl_mask_sel_dec1_ne[1] = imm_sel_neon_dec1_ne[19];
  assign ex2_ctl_au_carry_lu_dec1_ne[1] = imm_sel_neon_dec1_ne[19];
  assign imm_sel_neon_dec1_ne[2] = wd_align_pc_dec1_ne;
  assign ls_instr_type_dec1_ne[2] = ls_instr_type_dec1_ne[3];
  assign ls_instr_type_dec1_ne[1] = ls_instr_type_dec1_ne[3];
  assign ls_length_dec1_ne[2] = ls_size_dec1_ne[2];
  assign neon_lsm_aligntype_dec1_ne[1] = neon_lsm_aligntype_dec1_ne[2];
  assign ex2_ctl_flag_set_dec1_ne[1] = instr_fmstat_dec1_ne;
  assign psr_wr_en_dec1_ne[1] = psr_wr_en_dec1_ne[3];
  assign psr_wr_en_dec1_ne[0] = psr_wr_en_dec1_ne[3];
  assign rf_wr_when_w0_dec1_ne[2] = rf_wr_when_w0_dec1_ne[1];
  assign rf_wr_when_w0_dec1_ne[0] = rf_wr_when_w0_dec1_ne[1];
  assign rf_wr_src_w0_dec1_ne[2] = rf_wr_when_w0_dec1_ne[1];
  assign rf_wr_when_fw0_dec1_ne[2] = 1'b0;
  assign rf_wr_src_w0_dec1_ne[1] = 1'b0;
  assign rf_wr_src_w0_dec1_ne[0] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ne[9] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ne[8] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ne[7] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ne[6] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ne[5] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ne[4] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ne[3] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ne[11] = 1'b0;
  assign rf_wr_ctl_w1_dec1_ne[10] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ne[9] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ne[8] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ne[7] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ne[6] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ne[5] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ne[4] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ne[3] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ne[2] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ne[11] = 1'b0;
  assign rf_wr_ctl_w0_dec1_ne[10] = 1'b0;
  assign rf_wr_ctl_fw0_dec1_ne[9] = 1'b0;
  assign rf_wr_ctl_fw0_dec1_ne[5] = 1'b0;
  assign rf_wr_ctl_fw0_dec1_ne[19] = 1'b0;
  assign rf_wr_ctl_fw0_dec1_ne[18] = 1'b0;
  assign rf_wr_ctl_fw0_dec1_ne[15] = 1'b0;
  assign rf_wr_ctl_fw0_dec1_ne[14] = 1'b0;
  assign rf_wr_ctl_fw0_dec1_ne[13] = 1'b0;
  assign rf_wr_ctl_fw0_dec1_ne[12] = 1'b0;
  assign rf_wr_ctl_fw0_dec1_ne[11] = 1'b0;
  assign rf_wr_ctl_fw0_dec1_ne[10] = 1'b0;
  assign rf_rd_ctl_r2_dec1_ne[1] = 1'b0;
  assign rf_rd_ctl_r1_dec1_ne[1] = 1'b0;
  assign rf_rd_ctl_r0_dec1_ne[1] = 1'b0;
  assign rf_rd_ctl_fr2_dec1_ne[3] = 1'b0;
  assign rf_rd_ctl_fr2_dec1_ne[2] = 1'b0;
  assign rf_rd_ctl_fr2_dec1_ne[19] = 1'b0;
  assign rf_rd_ctl_fr2_dec1_ne[14] = 1'b0;
  assign rf_rd_ctl_fr2_dec1_ne[13] = 1'b0;
  assign rf_rd_ctl_fr2_dec1_ne[12] = 1'b0;
  assign rf_rd_ctl_fr2_dec1_ne[11] = 1'b0;
  assign rf_rd_ctl_fr1_dec1_ne[9] = 1'b0;
  assign rf_rd_ctl_fr1_dec1_ne[3] = 1'b0;
  assign rf_rd_ctl_fr1_dec1_ne[20] = 1'b0;
  assign rf_rd_ctl_fr1_dec1_ne[19] = 1'b0;
  assign rf_rd_ctl_fr1_dec1_ne[18] = 1'b0;
  assign rf_rd_ctl_fr1_dec1_ne[14] = 1'b0;
  assign rf_rd_ctl_fr1_dec1_ne[13] = 1'b0;
  assign rf_rd_ctl_fr1_dec1_ne[12] = 1'b0;
  assign rf_rd_ctl_fr1_dec1_ne[11] = 1'b0;
  assign rf_rd_ctl_fr0_dec1_ne[9] = 1'b0;
  assign rf_rd_ctl_fr0_dec1_ne[5] = 1'b0;
  assign rf_rd_ctl_fr0_dec1_ne[3] = 1'b0;
  assign rf_rd_ctl_fr0_dec1_ne[20] = 1'b0;
  assign rf_rd_ctl_fr0_dec1_ne[19] = 1'b0;
  assign rf_rd_ctl_fr0_dec1_ne[18] = 1'b0;
  assign rf_rd_ctl_fr0_dec1_ne[14] = 1'b0;
  assign rf_rd_ctl_fr0_dec1_ne[13] = 1'b0;
  assign rf_rd_ctl_fr0_dec1_ne[12] = 1'b0;
  assign rf_rd_ctl_fr0_dec1_ne[11] = 1'b0;
  assign rf_rd_ctl_fr0_dec1_ne[10] = 1'b0;
  assign raw_lsm_immed_dec1_ne[3] = 1'b0;
  assign raw_lsm_immed_dec1_ne[2] = 1'b0;
  assign psr_wr_en_dec1_ne[5] = 1'b0;
  assign psr_wr_en_dec1_ne[4] = 1'b0;
  assign psr_wr_en_dec1_ne[2] = 1'b0;
  assign ls_length_dec1_ne[5] = 1'b0;
  assign ls_length_dec1_ne[4] = 1'b0;
  assign ls_length_dec1_ne[3] = 1'b0;
  assign ls_instr_type_dec1_ne[0] = 1'b0;
  assign ex2_ctl_au_carry_lu_dec1_ne[2] = 1'b0;
  assign ex2_ctl_au_carry_lu_dec1_ne[0] = 1'b0;
  assign ex1_ctl_mask_sel_dec1_ne[0] = 1'b0;
  assign dp_data_c_sel_dec1_ne[0] = 1'b0;
  assign dp_data_b_sel_dec1_ne[2] = 1'b0;
  assign dp_data_a_sel_dec1_ne[1] = 1'b0;
  assign agu_data_b_sel_dec1_ne[6] = 1'b0;
  assign agu_data_b_sel_dec1_ne[3] = 1'b0;
  assign agu_data_b_sel_dec1_ne[2] = 1'b0;
  assign net_1 = ~set_19_16_as_r31;
  assign net_2 = ~set_15_12_as_r31;
  assign net_3 = ~net_1273;
  assign net_4 = ~net_729;
  assign net_5 = ~net_1202;
  assign net_6 = ~net_233;
  assign net_7 = ~net_169;
  assign net_8 = ~net_603;
  assign net_9 = ~net_297;
  assign net_10 = ~net_1013;
  assign net_11 = ~net_273;
  assign net_12 = ~net_906;
  assign net_13 = ~a64_only;
  assign net_14 = ~aarch64_state_i;
  assign net_17 = ~net_418;
  assign net_18 = ~net_845;
  assign net_19 = ~net_266;
  assign net_20 = ~net_1454;
  assign net_21 = ~net_964;
  assign net_22 = ~net_1421;
  assign net_24 = ~iq_instr_dec1_ne_i[28];
  assign net_25 = ~net_1003;
  assign net_26 = ~net_100;
  assign net_28 = ~net_1785;
  assign net_29 = ~net_1094;
  assign net_30 = ~net_1781;
  assign net_31 = ~net_348;
  assign net_32 = ~iq_instr_dec1_ne_i[26];
  assign net_33 = ~net_1533;
  assign net_34 = ~net_2006;
  assign net_35 = ~net_1088;
  assign net_36 = ~net_689;
  assign net_37 = ~iq_instr_dec1_ne_i[25];
  assign rf_wr_when_w0_dec1_ne[1] = ~net_139;
  assign net_39 = ~net_1739;
  assign net_40 = ~net_318;
  assign net_41 = ~net_95;
  assign net_42 = ~iq_instr_dec1_ne_i[24];
  assign net_43 = ~net_606;
  assign net_44 = ~net_435;
  assign net_45 = ~net_1450;
  assign net_47 = ~iq_instr_dec1_ne_i[22];
  assign net_48 = ~net_1287;
  assign net_49 = ~net_1793;
  assign net_50 = ~net_1947;
  assign net_52 = ~net_480;
  assign net_54 = ~net_1087;
  assign net_55 = ~iq_instr_dec1_ne_i[19];
  assign net_56 = ~net_1346;
  assign net_57 = ~iq_instr_dec1_ne_i[18];
  assign net_58 = ~net_799;
  assign net_59 = ~iq_instr_dec1_ne_i[17];
  assign net_60 = ~iq_instr_dec1_ne_i[16];
  assign net_61 = ~net_1068;
  assign net_62 = ~net_280;
  assign net_63 = ~iq_instr_dec1_ne_i[11];
  assign net_64 = ~net_1012;
  assign net_66 = ~net_846;
  assign net_67 = ~net_227;
  assign net_68 = ~net_1164;
  assign net_69 = ~net_891;
  assign net_72 = ~iq_instr_dec1_ne_i[7];
  assign net_73 = ~iq_instr_dec1_ne_i[6];
  assign net_74 = ~iq_instr_dec1_ne_i[5];
  assign net_75 = ~iq_instr_dec1_ne_i[4];
  assign str_valid_dec1_ne = (net_77 | net_78);
  assign net_78 = (net_79 | net_80);
  assign net_80 = (net_81 | net_82);
  assign net_82 = ~(net_83 & net_84);
  assign net_84 = (net_85 & net_86);
  assign net_86 = ~(imm_sel_neon_dec1_ne[18] & net_2167);
  assign net_85 = (iq_instr_dec1_ne_i[25] | net_87);
  assign net_87 = ~(net_88 | net_89);
  assign net_89 = ~(net_44 & net_90);
  assign net_90 = ~(iq_instr_dec1_ne_i[27] & net_2167);
  assign net_83 = (net_91 & net_92);
  assign net_92 = (net_93 | net_94);
  assign net_94 = (net_95 | iq_instr_dec1_ne_i[22]);
  assign net_79 = (net_96 | net_97);
  assign net_97 = (net_98 | net_99);
  assign net_99 = (net_100 | net_101);
  assign net_98 = ~(iq_instr_dec1_ne_i[27] | net_102);
  assign net_102 = (net_32 & net_103);
  assign net_77 = (net_42 & net_104);
  assign net_104 = (iq_instr_dec1_ne_i[4] & net_105);
  assign net_105 = ~(net_106 & net_107);
  assign net_107 = (net_37 | iq_instr_dec1_ne_i[20]);
  assign net_106 = ~(iq_instr_dec1_ne_i[8] & net_108);
  assign str_data_b_sel_dec1_ne[2] = ~(net_109 & net_110);
  assign net_110 = (net_111 & net_112);
  assign net_112 = (net_2170 | net_113);
  assign net_113 = ~(net_114 | net_115);
  assign net_111 = (net_116 & net_117);
  assign net_117 = (net_31 | net_118);
  assign net_118 = (net_74 | net_119);
  assign net_119 = (net_120 | net_121);
  assign net_121 = ~(net_122 & iq_instr_dec1_ne_i[22]);
  assign net_116 = ~(rf_wr_ctl_fw0_dec1_ne[6] | net_123);
  assign str_data_b_sel_dec1_ne[1] = ~(net_124 & net_125);
  assign net_125 = (net_126 | net_13);
  assign net_124 = (net_127 & net_128);
  assign net_128 = ~(net_129 | net_130);
  assign net_130 = (net_131 & net_37);
  assign str_data_b_sel_dec1_ne[0] = ~(net_132 & net_133);
  assign net_133 = (net_134 & net_135);
  assign net_135 = ~(net_101 | net_136);
  assign net_136 = ~(net_137 & net_138);
  assign net_138 = (net_139 & net_127);
  assign str_data_a_sel_dec1_ne[1] = (rf_wr_src_w1_dec1_ne[1] | net_140);
  assign net_140 = (net_141 | net_142);
  assign rf_wr_when_w1_dec1_ne[0] = (rf_wr_ctl_w1_dec1_ne[1] | rf_wr_when_w1_dec1_ne[2]);
  assign rf_wr_when_fw0_dec1_ne[1] = (net_158 | net_159);
  assign net_159 = (net_160 | net_161);
  assign net_161 = ~(net_162 & net_163);
  assign net_160 = (iq_instr_dec1_ne_i[8] & net_164);
  assign net_164 = ~(net_165 & net_166);
  assign net_165 = ~(net_167 | net_168);
  assign net_168 = ~(net_169 | net_170);
  assign net_158 = ~(net_171 & net_172);
  assign net_172 = (net_173 & net_174);
  assign net_174 = (net_175 & net_176);
  assign net_176 = ~(net_177 & net_178);
  assign net_175 = (net_179 & net_180);
  assign net_180 = (net_181 & net_182);
  assign net_182 = (iq_instr_dec1_ne_i[9] | net_183);
  assign net_183 = (net_184 | net_59);
  assign net_173 = ~(net_185 | net_186);
  assign net_186 = (net_187 | net_188);
  assign net_188 = ~(net_189 & net_190);
  assign net_190 = (net_191 & net_192);
  assign net_192 = ~(net_193 & net_194);
  assign net_191 = ~(net_195 & net_196);
  assign net_189 = (net_197 & net_198);
  assign net_198 = ~(net_199 & net_200);
  assign net_197 = ~(net_201 & net_202);
  assign net_185 = ~(net_203 & net_204);
  assign net_204 = (net_58 | net_169);
  assign net_203 = (net_205 | net_75);
  assign net_171 = (net_206 & net_207);
  assign net_207 = (net_208 & net_209);
  assign net_209 = (net_3 | net_210);
  assign net_210 = (net_62 | net_67);
  assign net_208 = (net_211 & net_212);
  assign net_206 = ~(net_213 | net_214);
  assign net_214 = ~(net_215 & net_216);
  assign net_216 = (net_217 & net_218);
  assign net_215 = ~(net_219 | net_220);
  assign net_220 = ~(net_221 & net_222);
  assign net_222 = ~(net_223 & net_56);
  assign net_221 = (net_224 | sf_bit);
  assign net_224 = (net_225 & net_226);
  assign net_226 = ~(net_227 & net_228);
  assign net_225 = (net_229 & net_230);
  assign net_230 = ~(iq_instr_dec1_ne_i[20] & net_231);
  assign net_231 = (net_232 & net_233);
  assign rf_wr_when_fw0_dec1_ne[0] = ~(net_234 & net_235);
  assign net_235 = (net_236 | net_24);
  assign net_236 = (net_237 & net_238);
  assign net_238 = (net_239 | net_11);
  assign net_237 = (net_240 & net_241);
  assign net_241 = ~(iq_instr_dec1_ne_i[7] & net_195);
  assign net_240 = (net_8 | net_242);
  assign net_242 = (net_243 & net_244);
  assign net_244 = ~(net_245 & iq_instr_dec1_ne_i[7]);
  assign net_243 = (net_246 & net_247);
  assign net_247 = ~(net_248 | net_249);
  assign net_249 = ~(net_61 | net_250);
  assign net_250 = (net_251 & net_59);
  assign net_251 = ~(net_252 | net_253);
  assign net_253 = ~(net_69 & net_254);
  assign net_254 = ~(net_2164 & net_60);
  assign net_234 = ~(net_255 | net_256);
  assign net_256 = ~(net_257 & net_258);
  assign net_258 = (net_259 & net_260);
  assign net_260 = (net_261 & net_262);
  assign net_262 = (net_263 & net_264);
  assign net_264 = ~(net_265 & net_266);
  assign net_265 = ~(net_267 | net_6);
  assign net_263 = (net_205 & net_268);
  assign net_268 = (net_269 | net_67);
  assign net_269 = ~(net_270 | net_271);
  assign net_271 = (net_272 & net_13);
  assign net_270 = (net_273 & net_274);
  assign net_274 = ~(net_19 & iq_instr_dec1_ne_i[23]);
  assign net_205 = (iq_instr_dec1_ne_i[8] | net_275);
  assign net_261 = (net_276 & net_277);
  assign net_277 = (net_278 | net_279);
  assign net_279 = ~(iq_instr_dec1_ne_i[19] & net_280);
  assign net_259 = (net_281 & net_217);
  assign net_217 = (net_282 & net_283);
  assign net_283 = (net_284 & net_285);
  assign net_284 = (net_286 & net_287);
  assign net_281 = (net_288 & net_289);
  assign net_289 = (iq_instr_dec1_ne_i[10] | net_290);
  assign net_290 = ~(net_291 & net_292);
  assign net_288 = ~(net_293 | net_294);
  assign net_294 = ~(net_295 & net_296);
  assign net_296 = ~(net_297 & net_2165);
  assign net_257 = (net_298 & net_299);
  assign net_298 = (net_300 & net_301);
  assign net_301 = (net_302 & net_303);
  assign net_300 = (net_304 & net_305);
  assign net_304 = (net_306 & net_307);
  assign net_307 = (net_73 | net_308);
  assign net_308 = (net_309 & net_310);
  assign net_310 = (iq_instr_dec1_ne_i[28] | net_311);
  assign net_311 = (net_2168 | net_312);
  assign net_312 = (net_8 | net_313);
  assign net_313 = (net_314 | iq_instr_dec1_ne_i[19]);
  assign net_314 = (net_170 & net_58);
  assign net_170 = (net_59 | net_72);
  assign net_309 = (net_315 & net_316);
  assign net_316 = ~(net_317 & net_318);
  assign net_315 = ~(net_319 & net_245);
  assign net_306 = (net_320 & net_321);
  assign net_321 = ~(net_322 & net_323);
  assign net_323 = ~(net_324 & net_325);
  assign net_325 = (net_2165 | net_326);
  assign net_326 = (net_327 & net_328);
  assign net_328 = ~(net_233 & net_49);
  assign net_327 = (net_329 & net_330);
  assign net_329 = ~(iq_instr_dec1_ne_i[19] & net_331);
  assign net_324 = (net_332 & net_333);
  assign net_333 = (iq_instr_dec1_ne_i[10] | net_334);
  assign net_334 = (net_68 | net_335);
  assign net_332 = (net_336 | net_64);
  assign net_336 = (net_330 & net_337);
  assign net_337 = (net_6 | net_338);
  assign net_338 = ~(iq_instr_dec1_ne_i[21] | iq_instr_dec1_ne_i[19]);
  assign net_330 = (net_2169 | net_2167);
  assign net_320 = (net_339 | net_2169);
  assign net_339 = ~(net_340 | net_341);
  assign net_341 = ~(net_342 & net_343);
  assign net_343 = (net_344 & net_345);
  assign net_345 = ~(iq_instr_dec1_ne_i[21] & net_346);
  assign net_346 = (net_347 & net_348);
  assign net_344 = (net_349 | net_55);
  assign net_349 = ~(net_350 | net_351);
  assign net_351 = (net_352 & net_353);
  assign net_353 = (net_354 | net_355);
  assign net_355 = ~(net_356 & net_357);
  assign net_357 = ~(net_14 & net_358);
  assign net_358 = ~(net_56 | iq_instr_dec1_ne_i[26]);
  assign net_354 = ~(iq_instr_dec1_ne_i[25] | net_359);
  assign net_359 = (net_360 | iq_instr_dec1_ne_i[17]);
  assign net_342 = ~(net_361 & net_362);
  assign net_362 = (net_227 | net_347);
  assign net_361 = (net_280 & iq_instr_dec1_ne_i[20]);
  assign net_255 = (net_363 | net_364);
  assign net_364 = ~(net_365 & net_366);
  assign net_366 = (net_19 | net_367);
  assign rf_wr_when_w1_dec1_ne[2] = ~(net_368 & net_139);
  assign rf_wr_src_w1_dec1_ne[1] = (net_369 | rf_wr_when_w0_dec1_ne[1]);
  assign rf_wr_src_w1_dec1_ne[0] = ~(net_370 & net_371);
  assign net_370 = ~(rf_wr_ctl_w1_dec1_ne[1] | net_372);
  assign net_372 = ~(net_373 | net_95);
  assign rf_wr_src_fw0_dec1_ne[3] = ~(net_302 & net_374);
  assign net_302 = (net_375 & net_376);
  assign net_376 = (net_377 | net_2167);
  assign net_377 = ~(net_378 | net_379);
  assign net_379 = (net_380 | net_381);
  assign net_381 = ~(net_382 & net_383);
  assign rf_wr_src_fw0_dec1_ne[2] = (net_384 | net_385);
  assign net_385 = ~(net_386 & net_374);
  assign rf_wr_src_fw0_dec1_ne[1] = ~(net_162 & net_387);
  assign net_387 = ~(net_388 | net_389);
  assign net_389 = ~(net_390 & net_391);
  assign net_391 = (net_392 & net_393);
  assign net_393 = (net_394 & net_395);
  assign net_395 = (net_59 | net_396);
  assign net_396 = (net_397 & net_398);
  assign net_397 = (net_399 & net_400);
  assign net_400 = ~(net_401 & net_402);
  assign net_399 = ~(net_223 | net_403);
  assign net_394 = (net_404 & net_405);
  assign net_405 = (net_367 | iq_instr_dec1_ne_i[16]);
  assign net_367 = ~(net_406 & net_407);
  assign net_404 = (net_408 & net_409);
  assign net_409 = ~(net_410 | net_411);
  assign net_411 = ~(net_412 & net_413);
  assign net_413 = ~(iq_instr_dec1_ne_i[8] & net_414);
  assign net_412 = (net_415 & net_416);
  assign net_416 = (net_184 | net_13);
  assign net_184 = (net_417 | net_418);
  assign net_415 = (net_419 | iq_instr_dec1_ne_i[11]);
  assign net_419 = ~(net_340 & net_420);
  assign net_392 = (net_421 & net_422);
  assign net_422 = (net_423 & net_424);
  assign net_424 = (net_425 & net_426);
  assign net_426 = (iq_instr_dec1_ne_i[18] | net_427);
  assign net_427 = ~(iq_instr_dec1_ne_i[21] & net_273);
  assign net_425 = (net_428 & net_429);
  assign net_429 = (net_5 | net_66);
  assign net_428 = (net_430 | net_431);
  assign net_423 = (net_432 | net_68);
  assign net_432 = ~(net_433 | net_434);
  assign net_434 = (net_435 & iq_instr_dec1_ne_i[20]);
  assign net_421 = (net_436 & net_305);
  assign net_305 = ~(iq_instr_dec1_ne_i[8] & net_437);
  assign net_437 = ~(net_438 & net_439);
  assign net_439 = (net_440 | net_63);
  assign net_438 = (net_441 & net_442);
  assign net_442 = (net_443 & net_444);
  assign net_444 = ~(net_445 & net_446);
  assign net_443 = (net_447 & net_448);
  assign net_436 = (net_449 & net_450);
  assign net_450 = (net_451 | net_57);
  assign net_449 = (net_452 | iq_instr_dec1_ne_i[8]);
  assign net_390 = (net_453 & net_454);
  assign net_454 = (iq_instr_dec1_ne_i[9] | net_455);
  assign net_455 = (net_456 & net_441);
  assign net_456 = (net_457 & net_458);
  assign net_458 = (net_11 | net_459);
  assign net_459 = ~(net_2169 | net_460);
  assign net_457 = (net_461 & net_462);
  assign net_462 = ~(net_435 & net_13);
  assign net_461 = (net_154 & net_4);
  assign net_154 = ~(net_463 & net_52);
  assign net_453 = (net_464 & net_465);
  assign net_465 = (net_72 | net_466);
  assign net_464 = (net_467 & net_468);
  assign net_468 = (net_469 & net_470);
  assign net_470 = (net_466 | aarch64_state_i);
  assign net_469 = (net_471 & net_472);
  assign net_472 = (net_473 | net_2165);
  assign net_473 = (net_474 & net_475);
  assign net_475 = ~(net_476 | net_477);
  assign net_474 = ~(net_478 | net_479);
  assign net_479 = ~(net_480 | net_481);
  assign net_481 = (net_61 | net_482);
  assign net_471 = (net_483 | net_8);
  assign net_483 = (net_484 & net_485);
  assign net_485 = ~(net_318 & net_73);
  assign net_484 = (net_486 | net_24);
  assign net_486 = (net_63 & net_487);
  assign net_487 = (net_488 & net_58);
  assign net_488 = (net_489 & net_490);
  assign net_490 = ~(net_2164 & net_59);
  assign net_489 = ~(net_491 | net_492);
  assign net_467 = (net_493 | net_67);
  assign net_493 = (net_494 & net_495);
  assign net_495 = (net_496 & net_497);
  assign net_497 = (net_3 | net_75);
  assign net_496 = (net_498 | net_11);
  assign net_498 = ~(net_499 | net_500);
  assign net_500 = (net_501 & net_502);
  assign net_501 = (iq_instr_dec1_ne_i[24] & iq_instr_dec1_ne_i[27]);
  assign net_303 = ~(imm_sel_neon_dec1_ne[9] | net_508);
  assign net_508 = ~(net_509 & net_510);
  assign net_510 = ~(net_511 | net_512);
  assign net_509 = (net_513 & net_514);
  assign net_514 = ~(net_515 & net_446);
  assign net_446 = ~(net_45 | iq_instr_dec1_ne_i[9]);
  assign net_513 = (net_516 & net_517);
  assign net_516 = (net_518 | iq_instr_dec1_ne_i[8]);
  assign net_518 = (net_519 & net_520);
  assign net_520 = (net_521 | a64_only);
  assign net_519 = ~(net_522 | net_523);
  assign net_523 = (iq_instr_dec1_ne_i[22] & net_524);
  assign net_524 = ~(net_525 | iq_instr_dec1_ne_i[24]);
  assign rf_wr_src_fw0_dec1_ne[0] = ~(net_527 & net_374);
  assign net_527 = (net_528 & net_529);
  assign net_529 = ~(net_530 & net_115);
  assign net_528 = ~(fp_ex_pipe_dec1_ne[2] | rf_wr_ctl_fw0_dec1_ne[6]);
  assign rf_wr_ctl_w1_dec1_ne[12] = ~(net_531 & net_532);
  assign net_532 = ~(set_15_12_as_r31 & net_533);
  assign rf_wr_ctl_w1_dec1_ne[0] = (rf_wr_ctl_w1_dec1_ne[1] | rf_wr_ctl_w1_dec1_ne[2]);
  assign rf_wr_ctl_w1_dec1_ne[2] = (net_2 & net_534);
  assign net_534 = (net_535 | net_533);
  assign net_533 = ~(net_536 & net_139);
  assign rf_wr_ctl_w0_dec1_ne[12] = ~(net_139 | net_1);
  assign rf_wr_ctl_w0_dec1_ne[1] = (net_1 & rf_wr_when_w0_dec1_ne[1]);
  assign rf_wr_ctl_fw0_dec1_ne[8] = (net_537 | net_538);
  assign net_538 = ~(net_539 & net_540);
  assign net_540 = (iq_instr_dec1_ne_i[9] | net_541);
  assign net_539 = ~(net_542 | net_543);
  assign net_543 = ~(net_544 & net_545);
  assign net_545 = (net_546 | net_66);
  assign net_544 = (net_547 & net_548);
  assign net_548 = ~(net_549 | net_550);
  assign net_550 = (net_491 & net_551);
  assign net_491 = ~(net_57 | net_60);
  assign net_549 = (net_552 | net_553);
  assign net_553 = ~(net_554 | net_555);
  assign net_555 = (sf_bit | net_556);
  assign net_556 = ~(net_557 & net_227);
  assign net_552 = (net_463 & net_558);
  assign net_558 = ~(net_559 | net_13);
  assign net_542 = (net_560 | net_561);
  assign net_561 = (net_562 | net_563);
  assign net_562 = (net_17 & net_564);
  assign net_564 = (net_565 | net_566);
  assign net_566 = ~(net_567 & net_568);
  assign net_568 = ~(net_569 & iq_instr_dec1_ne_i[16]);
  assign net_567 = ~(net_570 & net_571);
  assign net_565 = (net_2165 & net_572);
  assign net_572 = ~(iq_instr_dec1_ne_i[10] & iq_instr_dec1_ne_i[8]);
  assign net_560 = ~(net_573 & net_574);
  assign net_574 = (net_575 | net_576);
  assign net_576 = (net_61 | net_577);
  assign rf_wr_ctl_fw0_dec1_ne[7] = (net_578 | net_579);
  assign net_579 = ~(net_580 | net_581);
  assign rf_wr_ctl_fw0_dec1_ne[4] = (net_582 | net_583);
  assign net_583 = ~(net_584 & net_585);
  assign net_585 = (net_278 | net_586);
  assign net_586 = (net_587 & net_588);
  assign net_588 = (iq_instr_dec1_ne_i[4] | net_589);
  assign net_589 = ~(iq_instr_dec1_ne_i[25] & iq_instr_dec1_ne_i[20]);
  assign net_587 = ~(iq_instr_dec1_ne_i[17] & net_590);
  assign net_278 = ~(net_331 & net_347);
  assign net_584 = ~(net_591 | net_592);
  assign net_592 = (rf_wr_ctl_fw0_dec1_ne[3] | net_593);
  assign net_593 = (net_594 | rf_wr_ctl_fw0_dec1_ne[2]);
  assign net_594 = (iq_instr_dec1_ne_i[6] & net_595);
  assign net_591 = ~(net_374 & net_596);
  assign net_596 = ~(net_597 & net_598);
  assign net_598 = (net_347 & net_599);
  assign rf_wr_ctl_fw0_dec1_ne[3] = ~(net_600 & net_601);
  assign net_601 = (net_521 | net_5);
  assign net_600 = (net_602 | net_63);
  assign net_602 = ~(net_603 & net_347);
  assign rf_wr_ctl_fw0_dec1_ne[2] = (net_604 & net_605);
  assign net_605 = (net_530 & net_606);
  assign net_604 = ~(net_431 | net_74);
  assign rf_wr_ctl_fw0_dec1_ne[17] = (net_607 | net_608);
  assign net_608 = (net_609 | net_610);
  assign net_610 = ~(net_611 & net_612);
  assign net_611 = (net_613 & net_614);
  assign net_614 = (net_615 & net_616);
  assign net_616 = ~(net_599 & net_617);
  assign net_615 = (net_386 & net_618);
  assign net_618 = ~(iq_instr_dec1_ne_i[8] & net_619);
  assign net_619 = (net_620 & net_621);
  assign net_386 = ~(net_622 | net_623);
  assign net_623 = ~(net_2167 | net_624);
  assign net_622 = ~(net_267 | net_625);
  assign net_625 = ~(net_626 | net_378);
  assign net_613 = (net_627 & net_628);
  assign net_627 = (net_629 & net_630);
  assign net_630 = ~(net_631 & net_352);
  assign net_631 = (net_632 & net_633);
  assign net_633 = ~(net_56 | net_55);
  assign net_632 = (net_634 & net_14);
  assign net_607 = (net_635 | net_636);
  assign net_636 = (net_637 | rf_rd_ctl_fr0_dec1_ne[15]);
  assign net_637 = (sf_bit & net_213);
  assign net_213 = (net_638 | net_639);
  assign net_639 = ~(net_640 & net_365);
  assign net_365 = ~(iq_instr_dec1_ne_i[19] & net_641);
  assign net_635 = ~(net_642 & net_643);
  assign net_643 = (net_2170 | net_644);
  assign net_642 = (net_645 & net_646);
  assign net_646 = (net_647 & net_648);
  assign net_648 = (net_649 | net_40);
  assign net_649 = ~(net_650 & net_651);
  assign net_651 = (net_652 | net_653);
  assign net_653 = (net_73 | net_57);
  assign net_647 = (net_526 & net_218);
  assign net_218 = (net_654 & net_655);
  assign net_655 = (net_656 | net_657);
  assign net_657 = ~(net_658 & net_659);
  assign net_659 = ~(net_2170 | net_575);
  assign rf_wr_ctl_fw0_dec1_ne[16] = (net_660 | net_384);
  assign net_384 = (net_661 & net_2168);
  assign net_661 = (net_115 & net_2170);
  assign net_660 = ~(iq_instr_dec1_ne_i[31] | net_662);
  assign net_662 = ~(net_114 | net_663);
  assign net_114 = ~(net_286 & net_664);
  assign net_286 = ~(net_41 & net_665);
  assign rf_wr_ctl_fw0_dec1_ne[1] = (net_666 | net_667);
  assign net_667 = (net_668 | net_669);
  assign net_669 = (net_670 | net_671);
  assign net_671 = (net_672 | net_673);
  assign net_673 = (net_478 | net_674);
  assign net_674 = (rf_wr_ctl_fw0_dec1_ne[20] | net_578);
  assign net_578 = (iq_instr_dec1_ne_i[4] & net_675);
  assign net_675 = (net_676 & net_677);
  assign net_677 = (net_678 | net_679);
  assign net_679 = ~(net_6 | net_2164);
  assign net_678 = (net_680 | net_681);
  assign net_681 = (iq_instr_dec1_ne_i[31] & net_682);
  assign net_682 = (net_233 | net_683);
  assign net_683 = ~(net_684 | net_685);
  assign net_680 = ~(iq_instr_dec1_ne_i[22] | net_686);
  assign net_686 = ~(net_687 & net_530);
  assign net_530 = ~(net_2170 | iq_instr_dec1_ne_i[21]);
  assign rf_wr_ctl_fw0_dec1_ne[20] = (imm_sel_neon_dec1_ne[20] | net_410);
  assign net_478 = (net_688 & net_689);
  assign net_670 = (iq_instr_dec1_ne_i[31] & net_663);
  assign net_668 = (net_690 | net_691);
  assign net_691 = (net_692 | net_537);
  assign net_537 = (net_693 | net_694);
  assign net_694 = (net_695 | net_696);
  assign net_696 = ~(net_697 & net_698);
  assign net_697 = (net_699 & net_700);
  assign net_700 = (iq_instr_dec1_ne_i[9] | net_701);
  assign net_701 = (net_702 & net_703);
  assign net_703 = (net_2166 | net_704);
  assign net_704 = ~(net_705 | net_706);
  assign net_706 = ~(net_707 | net_2164);
  assign net_707 = (net_708 & net_709);
  assign net_709 = (net_482 | net_55);
  assign net_708 = ~(net_710 | net_711);
  assign net_711 = ~(net_5 | net_2168);
  assign net_702 = ~(net_712 | net_713);
  assign net_713 = (net_714 | net_715);
  assign net_715 = ~(net_716 & net_717);
  assign net_717 = (net_718 | net_3);
  assign net_718 = (net_719 & net_720);
  assign net_720 = ~(iq_instr_dec1_ne_i[4] & net_721);
  assign net_719 = (net_2164 | net_45);
  assign net_716 = (net_722 & net_723);
  assign net_723 = (iq_instr_dec1_ne_i[8] | net_724);
  assign net_722 = ~(net_725 | net_726);
  assign net_726 = ~(net_727 & net_728);
  assign net_728 = ~(net_729 | net_730);
  assign net_699 = (net_731 & net_732);
  assign net_732 = (net_733 & net_734);
  assign net_734 = (net_2169 | net_735);
  assign net_735 = ~(net_736 & net_571);
  assign net_736 = ~(net_737 & net_738);
  assign net_738 = ~(iq_instr_dec1_ne_i[10] & net_710);
  assign net_737 = (net_739 & net_740);
  assign net_740 = (iq_instr_dec1_ne_i[7] | net_741);
  assign net_741 = ~(iq_instr_dec1_ne_i[8] & net_291);
  assign net_739 = (net_742 | net_75);
  assign net_742 = (net_3 & net_743);
  assign net_743 = ~(iq_instr_dec1_ne_i[19] & iq_instr_dec1_ne_i[24]);
  assign net_733 = (net_744 & net_745);
  assign net_745 = (net_746 & net_747);
  assign net_747 = (net_748 & net_749);
  assign net_746 = (net_750 & net_751);
  assign net_750 = (net_752 & net_753);
  assign net_753 = (net_2167 | net_754);
  assign net_752 = ~(net_755 | net_756);
  assign net_744 = (net_757 & net_758);
  assign net_758 = (net_759 | iq_instr_dec1_ne_i[10]);
  assign net_757 = ~(net_729 & net_63);
  assign net_693 = (iq_instr_dec1_ne_i[8] & net_760);
  assign net_760 = (net_761 | net_762);
  assign net_762 = (net_363 & net_56);
  assign net_761 = (net_763 | net_764);
  assign net_764 = ~(net_765 & net_766);
  assign net_766 = ~(net_767 & net_200);
  assign net_765 = (net_768 & net_769);
  assign net_769 = (net_770 & net_771);
  assign net_771 = ~(iq_instr_dec1_ne_i[20] & net_772);
  assign net_770 = (net_773 & net_12);
  assign net_763 = (net_634 & net_774);
  assign net_774 = (net_775 | net_73);
  assign net_775 = ~(net_776 & net_777);
  assign net_777 = (net_58 | iq_instr_dec1_ne_i[19]);
  assign net_776 = (net_778 | net_360);
  assign net_692 = (net_17 & net_779);
  assign net_779 = (net_780 | net_781);
  assign net_781 = (net_782 | net_783);
  assign net_783 = ~(net_784 & net_785);
  assign net_785 = (net_786 & net_787);
  assign net_787 = ~(net_788 & iq_instr_dec1_ne_i[18]);
  assign net_788 = (iq_instr_dec1_ne_i[10] & net_789);
  assign net_789 = ~(net_59 & net_2165);
  assign net_786 = ~(net_790 | net_791);
  assign net_790 = ~(net_792 & net_793);
  assign net_793 = ~(net_569 & net_599);
  assign net_792 = ~(net_157 & net_794);
  assign net_784 = (net_795 & net_796);
  assign net_796 = ~(net_797 & iq_instr_dec1_ne_i[10]);
  assign net_795 = ~(net_798 & net_799);
  assign net_690 = ~(net_800 & net_801);
  assign net_800 = ~(rf_wr_ctl_fw0_dec1_ne[6] | net_802);
  assign net_802 = ~(net_803 & net_181);
  assign rf_wr_64b_w1_dec1_ne = ~(net_804 & net_805);
  assign net_804 = ~(net_806 | net_807);
  assign net_807 = ~(net_808 & net_809);
  assign net_808 = (net_810 & net_811);
  assign net_811 = (net_368 | net_2170);
  assign net_368 = ~(net_535 | net_812);
  assign net_812 = ~(net_536 & net_531);
  assign net_531 = (net_813 | net_431);
  assign net_536 = ~(net_814 | net_815);
  assign net_815 = ~(net_371 & net_816);
  assign net_816 = (net_95 | net_817);
  assign net_371 = (net_2167 | net_28);
  assign net_535 = ~(net_267 | net_431);
  assign net_810 = (net_818 | net_2164);
  assign net_818 = ~(net_25 | net_819);
  assign net_819 = ~(net_820 | iq_instr_dec1_ne_i[25]);
  assign net_806 = (net_821 & net_822);
  assign net_822 = (net_823 & net_824);
  assign net_821 = (net_420 & net_348);
  assign rf_rd_need_r1_dec1_ne[2] = (net_825 | rf_rd_need_r1_dec1_ne[1]);
  assign rf_rd_need_r1_dec1_ne[1] = (net_663 | net_826);
  assign net_826 = (net_827 | rf_rd_need_r1_dec1_ne[0]);
  assign net_663 = (iq_instr_dec1_ne_i[21] & net_115);
  assign rf_rd_need_r0_dec1_ne[0] = (net_828 | net_829);
  assign rf_rd_need_fr2_dec1_ne = ~(net_830 & net_831);
  assign net_831 = ~(net_832 | net_833);
  assign net_833 = (net_834 | net_835);
  assign net_835 = ~(net_836 & net_837);
  assign net_837 = (net_838 & net_839);
  assign net_839 = (net_2164 | net_840);
  assign net_838 = (net_841 & net_842);
  assign net_842 = (net_843 & net_844);
  assign net_844 = ~(net_845 & net_846);
  assign net_843 = (net_847 & net_848);
  assign net_836 = ~(net_849 | net_850);
  assign net_850 = ~(net_851 & net_852);
  assign net_852 = (net_853 & net_854);
  assign net_851 = ~(rf_rd_ctl_fr2_dec1_ne[5] | net_855);
  assign net_855 = (net_856 | net_857);
  assign net_857 = (net_193 & net_858);
  assign rf_rd_need_fr1_dec1_ne = ~(net_859 & net_860);
  assign net_860 = (net_861 & net_862);
  assign net_862 = (iq_instr_dec1_ne_i[9] | net_863);
  assign net_861 = (net_864 & net_865);
  assign net_865 = (net_866 & net_867);
  assign net_867 = (net_868 & net_869);
  assign net_868 = (net_870 & net_871);
  assign net_871 = (net_872 & net_873);
  assign net_870 = (net_874 & net_875);
  assign net_874 = (net_876 & net_877);
  assign net_877 = ~(net_348 & net_878);
  assign net_876 = (net_879 & net_880);
  assign net_880 = ~(rf_rd_ctl_fr1_dec1_ne[5] | net_881);
  assign net_881 = ~(net_882 & net_883);
  assign net_882 = (net_884 & net_885);
  assign net_884 = (net_886 & net_887);
  assign net_887 = (net_888 | net_63);
  assign net_888 = (iq_instr_dec1_ne_i[23] | net_889);
  assign net_889 = (a64_only | net_890);
  assign net_890 = ~(net_891 & net_689);
  assign net_886 = (net_211 & net_892);
  assign net_211 = ~(net_799 & net_551);
  assign net_879 = (net_893 & net_894);
  assign net_894 = ~(net_891 & net_895);
  assign net_893 = ~(net_896 | net_856);
  assign net_856 = ~(net_645 & net_897);
  assign net_866 = (net_898 & net_899);
  assign net_899 = (net_900 | net_2164);
  assign net_900 = (net_901 & net_902);
  assign net_902 = (net_903 & net_773);
  assign net_903 = ~(net_904 | net_905);
  assign net_905 = (net_906 | net_907);
  assign net_907 = (imm_sel_neon_dec1_ne[19] | net_908);
  assign net_908 = (net_909 & net_910);
  assign net_910 = (net_911 | net_912);
  assign net_912 = ~(net_913 | net_914);
  assign net_914 = ~(iq_instr_dec1_ne_i[17] | net_915);
  assign net_915 = ~(iq_instr_dec1_ne_i[7] & iq_instr_dec1_ne_i[18]);
  assign net_911 = (net_131 & net_916);
  assign net_916 = (net_917 | net_918);
  assign net_918 = ~(net_778 | net_919);
  assign net_778 = (net_55 | iq_instr_dec1_ne_i[17]);
  assign net_917 = (net_55 & net_920);
  assign net_920 = (net_621 | net_921);
  assign net_921 = ~(net_58 & net_56);
  assign net_909 = (net_922 & net_824);
  assign net_898 = ~(rf_wr_when_w0_dec1_ne[1] | net_923);
  assign net_923 = (rf_rd_ctl_fr2_dec1_ne[9] | net_924);
  assign net_924 = ~(net_925 & net_803);
  assign net_925 = ~(net_926 | net_927);
  assign net_927 = ~(net_928 & net_929);
  assign net_929 = (net_285 & net_526);
  assign net_285 = (net_930 | net_931);
  assign net_931 = (net_932 | net_933);
  assign net_933 = ~(iq_instr_dec1_ne_i[26] & iq_instr_dec1_ne_i[20]);
  assign net_930 = (iq_instr_dec1_ne_i[24] | net_934);
  assign net_934 = ~(net_922 & net_935);
  assign net_935 = (net_57 & iq_instr_dec1_ne_i[6]);
  assign net_859 = (net_936 & net_937);
  assign net_937 = (net_748 & net_938);
  assign net_748 = ~(imm_sel_neon_dec1_ne[9] | net_939);
  assign net_936 = (net_940 & net_941);
  assign net_941 = ~(net_41 & net_942);
  assign net_942 = ~(net_943 & net_944);
  assign net_944 = ~(iq_instr_dec1_ne_i[22] & net_945);
  assign net_945 = (net_946 | net_947);
  assign net_946 = (net_233 & net_948);
  assign net_948 = ~(net_267 & net_813);
  assign net_940 = (net_949 & net_950);
  assign net_950 = ~(net_951 & net_63);
  assign net_949 = (net_952 & net_953);
  assign net_953 = (net_954 & net_955);
  assign net_955 = ~(net_956 & net_2165);
  assign net_954 = ~(net_201 & net_652);
  assign rf_rd_need_fr0_dec1_ne = (neon_can_fwd_acc_dec1_ne | net_957);
  assign net_957 = (net_958 | net_959);
  assign net_959 = ~(net_960 & net_961);
  assign net_961 = (net_962 & net_963);
  assign net_963 = ~(net_964 & net_2170);
  assign net_962 = (net_965 & net_966);
  assign net_966 = (net_967 & net_968);
  assign net_968 = (net_969 & net_970);
  assign net_967 = (net_287 & net_751);
  assign net_287 = ~(net_971 & net_13);
  assign net_971 = (iq_instr_dec1_ne_i[4] & net_972);
  assign rf_rd_ctl_r2_dec1_ne[2] = (set_19_16_as_r31 & rf_wr_ctl_fw0_dec1_ne[6]);
  assign rf_rd_ctl_r2_dec1_ne[0] = (rf_wr_ctl_fw0_dec1_ne[6] & net_1);
  assign rf_rd_ctl_r1_dec1_ne[2] = ~(net_973 & net_974);
  assign net_974 = ~(set_3_0_as_r31 & rf_rd_need_r1_dec1_ne[0]);
  assign net_973 = ~(set_15_12_as_r31 & str_data_a_sel_dec1_ne[2]);
  assign rf_rd_ctl_r1_dec1_ne[0] = (net_975 | net_976);
  assign net_976 = (net_977 | net_825);
  assign net_977 = (str_data_a_sel_dec1_ne[2] & net_2);
  assign str_data_a_sel_dec1_ne[2] = (net_115 | net_978);
  assign net_978 = (rf_wr_ctl_fw0_dec1_ne[6] | net_827);
  assign net_827 = ~(net_979 & net_664);
  assign net_664 = ~(net_980 & net_24);
  assign net_980 = (net_606 & net_981);
  assign net_979 = ~(net_982 | net_410);
  assign net_410 = ~(net_983 | net_29);
  assign net_983 = ~(net_108 | net_984);
  assign net_984 = ~(net_985 & net_986);
  assign net_986 = (net_43 | net_37);
  assign rf_wr_ctl_fw0_dec1_ne[6] = (net_987 & net_13);
  assign net_987 = (net_676 & net_37);
  assign net_115 = ~(iq_instr_dec1_ne_i[22] | net_988);
  assign net_988 = (net_431 | iq_instr_dec1_ne_i[20]);
  assign net_431 = (net_95 | a64_only);
  assign net_975 = (net_989 | net_990);
  assign net_990 = ~(net_2168 | net_126);
  assign net_989 = ~(set_3_0_as_r31 | net_991);
  assign net_991 = ~(net_992 | net_993);
  assign net_993 = (iq_instr_dec1_ne_i[23] & net_994);
  assign rf_rd_ctl_r0_dec1_ne[2] = ~(net_995 | net_1);
  assign rf_rd_ctl_r0_dec1_ne[0] = (net_996 | net_829);
  assign net_829 = (net_25 | net_997);
  assign net_997 = (net_998 | net_999);
  assign net_999 = ~(net_1000 & net_809);
  assign net_1000 = ~(net_378 | net_1001);
  assign net_1001 = ~(net_32 | net_1002);
  assign net_996 = ~(set_19_16_i | net_1004);
  assign net_1004 = (net_382 | set_19_16_as_r31);
  assign rf_rd_ctl_fr2_dec1_ne[8] = (net_1005 | net_1006);
  assign net_1006 = ~(net_1007 & net_1008);
  assign net_1008 = ~(iq_instr_dec1_ne_i[8] & net_1009);
  assign net_1007 = ~(net_293 | net_1010);
  assign net_1010 = ~(net_897 & net_1011);
  assign net_1011 = ~(net_1012 & imm_sel_neon_dec1_ne[13]);
  assign net_897 = ~(net_1013 & net_177);
  assign net_1005 = ~(net_1014 & net_1015);
  assign net_1015 = ~(net_1016 & net_1017);
  assign net_1017 = (net_1018 & net_233);
  assign net_1018 = ~(net_2164 | iq_instr_dec1_ne_i[11]);
  assign rf_rd_ctl_fr2_dec1_ne[7] = ~(net_1019 & net_1020);
  assign net_1020 = (net_864 & net_1021);
  assign net_1021 = (net_1022 & net_1023);
  assign net_1023 = (net_2164 | net_1024);
  assign net_1024 = (net_1025 & net_1026);
  assign net_1022 = ~(net_511 | net_1027);
  assign net_1027 = ~(net_275 & net_1028);
  assign net_511 = ~(iq_instr_dec1_ne_i[9] | net_1029);
  assign net_864 = ~(imm_sel_neon_dec1_ne[7] | net_1030);
  assign net_1030 = ~(net_1031 & net_1032);
  assign net_1032 = (net_1033 | sf_bit);
  assign net_1031 = ~(net_834 | net_672);
  assign net_834 = (net_2164 & net_1034);
  assign net_1034 = (net_1035 | net_1036);
  assign net_1036 = ~(net_2165 | net_408);
  assign net_1035 = ~(net_452 & net_1037);
  assign net_1037 = (iq_instr_dec1_ne_i[9] | net_1038);
  assign net_1038 = (net_24 | net_546);
  assign rf_rd_ctl_fr2_dec1_ne[6] = (net_1039 | net_1040);
  assign net_1040 = ~(net_1041 & net_1042);
  assign net_1042 = (net_1043 & net_1044);
  assign net_1044 = ~(net_551 & net_1045);
  assign net_1045 = ~(net_66 | net_1046);
  assign net_1041 = (net_1047 & net_1048);
  assign net_1048 = ~(net_292 & net_17);
  assign net_292 = (net_780 & net_63);
  assign net_1047 = (net_1049 & net_1050);
  assign net_1050 = (net_2164 | net_841);
  assign net_841 = ~(net_1051 & net_60);
  assign net_1049 = (net_654 & net_848);
  assign net_848 = (net_1052 & net_1053);
  assign net_1053 = (net_1054 | iq_instr_dec1_ne_i[11]);
  assign net_1052 = (net_640 & net_969);
  assign net_640 = ~(net_245 & net_1055);
  assign net_1055 = (net_922 & net_1056);
  assign net_1056 = ~(net_1057 & net_1058);
  assign net_1058 = ~(net_1059 & iq_instr_dec1_ne_i[6]);
  assign net_1057 = ~(net_88 & iq_instr_dec1_ne_i[7]);
  assign net_654 = (net_67 | net_840);
  assign rf_rd_ctl_fr2_dec1_ne[4] = (net_1060 | net_1061);
  assign net_1061 = (net_219 | net_1062);
  assign net_1062 = (net_1063 | net_1064);
  assign net_1063 = (net_347 & net_1065);
  assign net_1065 = ~(net_1066 & net_1067);
  assign net_1067 = ~(net_1068 & net_1069);
  assign net_1069 = ~(net_1070 & net_1071);
  assign net_1071 = ~(net_650 & net_599);
  assign net_1070 = ~(net_1072 & net_932);
  assign net_932 = ~(iq_instr_dec1_ne_i[16] | iq_instr_dec1_ne_i[7]);
  assign net_1060 = (iq_instr_dec1_ne_i[6] & net_1073);
  assign net_1073 = (net_1074 | net_1075);
  assign net_1075 = (net_1076 | net_1077);
  assign net_1074 = (net_1078 | net_1079);
  assign net_1079 = (net_1080 | net_1081);
  assign net_1081 = (net_1082 & net_1083);
  assign net_1083 = (net_1084 | net_1085);
  assign net_1085 = ~(net_64 | net_48);
  assign net_1084 = (net_63 & net_1086);
  assign net_1086 = ~(net_2164 & net_1087);
  assign net_1080 = (net_322 & net_1088);
  assign net_1078 = (net_1089 | net_964);
  assign net_1089 = (net_2170 & net_1090);
  assign net_1090 = (net_597 & net_245);
  assign rf_rd_ctl_fr2_dec1_ne[20] = ~(net_1091 & net_847);
  assign net_847 = (net_1092 | net_28);
  assign net_1091 = ~(imm_sel_neon_dec1_ne[20] | net_1093);
  assign net_1093 = (net_1094 & net_1095);
  assign rf_rd_ctl_fr2_dec1_ne[1] = ~(net_1096 & net_181);
  assign net_181 = (net_18 | net_69);
  assign net_1096 = ~(net_672 | net_1097);
  assign net_1097 = ~(net_1098 & net_885);
  assign net_885 = (net_1099 | net_1100);
  assign rf_rd_ctl_fr2_dec1_ne[17] = ~(net_854 & net_1101);
  assign net_1101 = ~(net_1102 | net_1103);
  assign net_1102 = (net_1009 & net_2164);
  assign net_854 = ~(net_617 & net_1104);
  assign net_1104 = ~(net_402 & net_1105);
  assign net_1105 = ~(net_599 & net_14);
  assign rf_rd_ctl_fr2_dec1_ne[16] = ~(net_1106 & net_1107);
  assign net_1107 = (net_1026 | iq_instr_dec1_ne_i[8]);
  assign net_1106 = (net_645 & net_1108);
  assign net_645 = ~(net_522 & net_2164);
  assign net_522 = (net_318 & net_1109);
  assign rf_rd_ctl_fr2_dec1_ne[15] = ~(net_873 & net_853);
  assign net_853 = (iq_instr_dec1_ne_i[16] | net_952);
  assign rf_rd_ctl_fr2_dec1_ne[0] = ~(net_1110 & net_179);
  assign net_1110 = (net_1098 & net_547);
  assign net_1098 = (net_830 & net_1111);
  assign net_1111 = (net_1112 & net_1113);
  assign net_1113 = ~(iq_instr_dec1_ne_i[7] & net_156);
  assign net_1112 = (net_1114 & net_1115);
  assign net_1115 = (net_1116 & net_1117);
  assign net_1117 = (net_1118 | iq_instr_dec1_ne_i[8]);
  assign net_1118 = (sf_bit | net_1119);
  assign net_1116 = (net_1120 & net_1121);
  assign net_1121 = (net_1014 & net_1122);
  assign net_1122 = (iq_instr_dec1_ne_i[9] | net_1123);
  assign net_1123 = (net_1029 & net_1124);
  assign net_1124 = ~(net_725 | net_1125);
  assign net_1125 = ~(net_1126 & net_1127);
  assign net_1127 = (net_546 | iq_instr_dec1_ne_i[8]);
  assign net_546 = (net_31 | iq_instr_dec1_ne_i[23]);
  assign net_1126 = (net_452 & net_1128);
  assign net_1128 = (net_11 | net_1129);
  assign net_1129 = (net_1130 & net_45);
  assign net_1130 = (net_19 | sf_bit);
  assign net_1120 = (net_1131 | net_2164);
  assign net_1131 = (net_1132 & net_1133);
  assign net_1133 = (net_1025 & net_1134);
  assign net_1134 = (net_1135 & net_1136);
  assign net_1136 = ~(imm_sel_neon_dec1_ne[13] & net_2166);
  assign net_1135 = (net_840 & net_1137);
  assign net_1137 = ~(imm_sel_neon_dec1_ne[19] | net_1138);
  assign net_1138 = ~(net_1139 & net_1140);
  assign net_1140 = (net_1141 & net_1142);
  assign net_1139 = (net_1143 & net_1144);
  assign net_1144 = (iq_instr_dec1_ne_i[16] | net_1145);
  assign net_1145 = (net_56 | net_169);
  assign net_1143 = (iq_instr_dec1_ne_i[11] | net_1146);
  assign net_1146 = (iq_instr_dec1_ne_i[7] | net_1147);
  assign net_1147 = ~(net_480 & net_233);
  assign net_1025 = (net_166 & net_441);
  assign net_1132 = (net_1148 | net_1149);
  assign net_1148 = (net_985 & net_1150);
  assign net_1150 = (net_37 | net_1092);
  assign net_1092 = (net_2167 & net_1151);
  assign net_1151 = (iq_instr_dec1_ne_i[23] | net_1152);
  assign net_1152 = (iq_instr_dec1_ne_i[6] & net_74);
  assign net_1114 = (net_1153 & net_1154);
  assign net_1154 = ~(net_1059 & net_1155);
  assign net_1153 = (net_1156 & net_731);
  assign net_731 = (net_1157 & net_1158);
  assign net_1158 = ~(net_293 | rf_rd_ctl_fr2_dec1_ne[9]);
  assign net_830 = ~(imm_sel_neon_dec1_ne[20] | net_1159);
  assign net_1159 = (net_1160 | net_1161);
  assign net_1161 = (net_1039 | net_1162);
  assign net_1162 = (net_1163 | imm_sel_neon_dec1_ne[7]);
  assign net_1163 = (net_17 & net_780);
  assign net_780 = (net_570 & net_1164);
  assign net_1039 = ~(net_1165 & net_1166);
  assign net_1166 = ~(iq_instr_dec1_ne_i[23] & net_1167);
  assign net_1167 = ~(net_1168 & net_1169);
  assign net_1169 = (net_1170 & net_1171);
  assign net_1171 = (net_1172 | net_494);
  assign net_494 = (net_1173 | net_554);
  assign net_1170 = (net_1174 & net_1175);
  assign net_1175 = (net_554 | net_1176);
  assign net_1176 = ~(iq_instr_dec1_ne_i[4] & net_846);
  assign net_554 = ~(net_13 & net_52);
  assign net_1168 = (net_1177 & net_1178);
  assign net_1178 = ~(net_1059 & net_1179);
  assign net_1177 = (iq_instr_dec1_ne_i[4] | net_1180);
  assign net_1180 = (iq_instr_dec1_ne_i[6] | net_1181);
  assign net_1181 = ~(net_245 & net_88);
  assign net_1165 = ~(net_1182 & net_2165);
  assign net_1182 = ~(net_1183 & net_1184);
  assign net_1184 = (net_1185 | net_54);
  assign net_1183 = ~(net_1186 | net_1187);
  assign net_1187 = (net_1188 | net_714);
  assign net_714 = (net_1068 & net_1189);
  assign net_1189 = (net_1087 & net_291);
  assign net_1188 = (net_2164 & net_1190);
  assign net_1190 = (iq_instr_dec1_ne_i[16] & net_1191);
  assign net_1191 = (net_1192 & net_1193);
  assign net_1193 = ~(iq_instr_dec1_ne_i[17] & net_2166);
  assign net_1192 = ~(iq_instr_dec1_ne_i[11] | net_418);
  assign net_1160 = (net_551 & net_1194);
  assign net_1194 = (net_797 & net_570);
  assign net_570 = ~(iq_instr_dec1_ne_i[17] | iq_instr_dec1_ne_i[16]);
  assign net_797 = ~(iq_instr_dec1_ne_i[8] | iq_instr_dec1_ne_i[7]);
  assign rf_rd_ctl_fr1_dec1_ne[8] = ~(net_1195 & net_1196);
  assign net_1196 = (net_1197 & net_1198);
  assign net_1198 = (net_1199 & net_1200);
  assign net_1200 = (iq_instr_dec1_ne_i[11] | net_1201);
  assign net_1201 = ~(net_1202 & net_1203);
  assign net_1197 = (net_1204 & net_1205);
  assign net_1205 = ~(net_705 & net_406);
  assign net_705 = ~(net_1206 & net_1207);
  assign net_1207 = ~(net_1208 & net_52);
  assign net_1206 = ~(net_1209 & net_1202);
  assign net_1204 = (net_1210 & net_1211);
  assign net_1211 = (net_4 | net_1212);
  assign net_1212 = ~(iq_instr_dec1_ne_i[10] & net_846);
  assign net_729 = ~(net_72 | net_5);
  assign net_1210 = (net_1213 | net_2164);
  assign net_1213 = ~(net_1051 | net_1214);
  assign net_1214 = (net_1215 & net_2165);
  assign net_1195 = (net_299 & net_1216);
  assign rf_rd_ctl_fr1_dec1_ne[6] = ~(net_1217 & net_1218);
  assign net_1218 = (net_1219 & net_1220);
  assign net_1220 = (net_163 & net_573);
  assign net_573 = (net_1221 | iq_instr_dec1_ne_i[4]);
  assign net_1221 = (net_1222 & net_1223);
  assign net_1223 = ~(net_1224 & net_1225);
  assign net_1224 = (net_233 & net_571);
  assign net_1222 = (net_1226 & net_1227);
  assign net_1227 = ~(net_1228 & net_1229);
  assign net_1229 = (net_1230 & iq_instr_dec1_ne_i[10]);
  assign net_1226 = (net_1231 | net_575);
  assign net_1231 = ~(net_791 | net_1232);
  assign net_1232 = (net_245 & net_1233);
  assign net_163 = (net_1234 & net_1235);
  assign net_1235 = (net_919 | net_1236);
  assign net_1236 = (net_73 | net_466);
  assign net_1234 = (net_1237 & net_1238);
  assign net_1238 = (net_1239 | net_69);
  assign net_1237 = (net_751 & net_1240);
  assign net_1240 = ~(net_756 | net_1241);
  assign net_1241 = (net_551 & net_1242);
  assign net_1242 = ~(net_1243 & net_577);
  assign net_1243 = (net_57 | net_69);
  assign net_1219 = (net_1244 & net_1245);
  assign net_1245 = (net_1246 | net_2164);
  assign net_1246 = (net_282 & net_1247);
  assign net_1247 = ~(net_599 & net_7);
  assign net_282 = ~(net_906 | net_1248);
  assign net_1244 = ~(net_1249 | net_1250);
  assign net_1250 = ~(net_1251 & net_1252);
  assign net_1252 = (net_1019 & net_612);
  assign net_1019 = (net_547 & net_1253);
  assign net_1253 = ~(net_846 & net_297);
  assign net_1251 = (net_1254 & net_1255);
  assign net_1255 = (net_1256 & net_1257);
  assign net_1257 = (net_1258 & net_1259);
  assign net_1259 = (iq_instr_dec1_ne_i[9] | net_727);
  assign net_727 = (net_1260 & net_1261);
  assign net_1261 = (net_93 | net_31);
  assign net_1260 = (net_11 | net_45);
  assign net_1258 = ~(net_293 | rf_wr_when_w0_dec1_ne[1]);
  assign net_1256 = (net_1262 & net_1263);
  assign net_1263 = (net_644 | sf_bit);
  assign net_644 = (net_155 | net_67);
  assign net_1262 = (net_1264 | iq_instr_dec1_ne_i[9]);
  assign net_1254 = (net_1265 & net_698);
  assign net_698 = ~(net_2170 & net_1266);
  assign net_1266 = (net_1267 | net_1268);
  assign net_1268 = ~(net_1269 & net_1270);
  assign net_1270 = ~(net_641 & net_52);
  assign net_1265 = (net_1271 & net_1272);
  assign net_1272 = ~(net_177 & net_1273);
  assign net_1271 = ~(net_248 & net_17);
  assign net_248 = (iq_instr_dec1_ne_i[16] & net_420);
  assign rf_rd_ctl_fr1_dec1_ne[4] = (net_1274 | net_1275);
  assign net_1275 = (net_1276 | rf_rd_ctl_fr1_dec1_ne[2]);
  assign net_1276 = (iq_instr_dec1_ne_i[6] & net_1277);
  assign net_1277 = (net_595 | net_1278);
  assign net_1278 = (net_1279 | net_1280);
  assign net_1280 = (net_1281 | net_1282);
  assign net_1279 = ~(net_1283 & net_1284);
  assign net_1284 = ~(net_407 & net_1285);
  assign net_407 = ~(net_72 | a64_only);
  assign net_1283 = ~(net_1203 & net_1286);
  assign net_1203 = ~(net_64 | net_1287);
  assign net_595 = ~(net_1288 & net_1289);
  assign net_1289 = (net_1290 & net_1291);
  assign net_1291 = (net_440 & net_1292);
  assign net_1292 = (iq_instr_dec1_ne_i[9] | net_1293);
  assign net_1293 = (net_1294 & net_1066);
  assign net_1066 = ~(net_1295 & net_1296);
  assign net_1296 = (iq_instr_dec1_ne_i[11] & net_590);
  assign net_1295 = ~(net_32 | iq_instr_dec1_ne_i[23]);
  assign net_1294 = ~(net_1297 & net_1298);
  assign net_440 = ~(net_1299 & net_13);
  assign net_1299 = ~(net_36 | net_1100);
  assign net_1290 = ~(net_597 & net_1300);
  assign net_1300 = ~(net_239 & net_1301);
  assign net_1301 = ~(net_492 & iq_instr_dec1_ne_i[20]);
  assign net_239 = ~(net_794 & net_2165);
  assign net_1274 = (net_1302 | net_1303);
  assign net_1303 = (iq_instr_dec1_ne_i[16] & net_1304);
  assign net_1302 = (net_347 & net_1305);
  assign net_1305 = (net_1306 | net_1307);
  assign net_1307 = (net_1208 & net_1308);
  assign net_1308 = ~(net_1016 | net_2166);
  assign net_1306 = (net_63 & net_1309);
  assign net_1309 = ~(net_1310 & net_1311);
  assign net_1311 = ~(net_799 & net_1297);
  assign net_1310 = ~(net_1312 & net_460);
  assign rf_rd_ctl_fr1_dec1_ne[2] = (net_219 | net_1313);
  assign net_1313 = (rf_rd_ctl_fr0_dec1_ne[2] | net_1314);
  assign net_1314 = ~(net_869 & net_1199);
  assign net_1199 = (net_1315 & net_1316);
  assign net_1316 = ~(net_772 & net_63);
  assign net_1315 = (net_1317 & net_1318);
  assign net_1318 = (net_1319 & net_1320);
  assign net_1320 = ~(imm_sel_neon_dec1_ne[18] & iq_instr_dec1_ne_i[24]);
  assign net_1319 = (net_809 & net_1321);
  assign net_869 = ~(net_1064 | net_1322);
  assign net_1322 = ~(sf_bit | net_1323);
  assign net_1323 = ~(net_1324 & net_319);
  assign net_1064 = ~(net_1325 & net_1326);
  assign net_1326 = (net_1327 | net_1328);
  assign net_1328 = ~(iq_instr_dec1_ne_i[23] & net_658);
  assign net_658 = ~(net_62 | iq_instr_dec1_ne_i[9]);
  assign net_1327 = (net_1329 & net_1330);
  assign net_1330 = (net_146 | net_685);
  assign net_685 = (iq_instr_dec1_ne_i[8] | iq_instr_dec1_ne_i[28]);
  assign net_146 = ~(net_1331 | net_1332);
  assign net_1329 = (net_1333 | net_559);
  assign net_1333 = (net_3 & net_1334);
  assign net_1334 = ~(iq_instr_dec1_ne_i[26] & net_52);
  assign net_1325 = (net_1335 & net_1336);
  assign net_1336 = ~(net_156 & net_1233);
  assign net_156 = (net_17 & net_245);
  assign net_1335 = (net_1337 | sf_bit);
  assign net_1337 = ~(net_641 & net_48);
  assign net_641 = (net_331 & net_232);
  assign net_232 = ~(net_19 | iq_instr_dec1_ne_i[10]);
  assign net_219 = (net_1338 & net_252);
  assign net_252 = ~(net_57 | net_54);
  assign rf_rd_ctl_fr1_dec1_ne[1] = ~(net_1339 & net_1340);
  assign net_1340 = ~(rf_rd_ctl_fr1_dec1_ne[7] | net_1341);
  assign net_1341 = (net_1249 | net_1342);
  assign net_1342 = (rf_wr_when_w0_dec1_ne[1] | net_672);
  assign rf_rd_ctl_fr1_dec1_ne[7] = ~(net_1343 & net_127);
  assign rf_rd_ctl_fr1_dec1_ne[17] = ~(net_952 & net_1344);
  assign net_1344 = (net_59 | net_526);
  assign net_952 = ~(iq_instr_dec1_ne_i[20] & net_1345);
  assign net_1345 = (net_1346 & net_403);
  assign net_403 = (net_1347 & net_1348);
  assign rf_rd_ctl_fr1_dec1_ne[16] = (net_1349 | net_1350);
  assign net_1350 = ~(net_873 & net_1351);
  assign net_1351 = ~(net_947 & net_1352);
  assign net_1352 = ~(net_75 | net_13);
  assign net_873 = ~(imm_sel_neon_dec1_ne[19] & net_2164);
  assign net_1349 = (net_41 & net_1353);
  assign net_1353 = ~(iq_instr_dec1_ne_i[31] | net_1354);
  assign net_1354 = (net_1355 & net_1356);
  assign net_1356 = ~(net_1357 & set_15_12_as_r31);
  assign rf_rd_ctl_fr1_dec1_ne[15] = (net_1358 | net_1359);
  assign net_1359 = (net_1360 | net_609);
  assign net_609 = ~(net_938 & net_1361);
  assign net_1361 = (net_1362 & net_1363);
  assign net_1363 = ~(sf_bit & net_896);
  assign net_1362 = (net_212 & net_1364);
  assign net_212 = (net_1365 | net_276);
  assign net_276 = (net_13 | net_575);
  assign net_938 = ~(net_1366 | net_1367);
  assign net_1367 = ~(net_1368 & net_1108);
  assign net_1108 = ~(net_1369 & net_1370);
  assign net_1370 = (net_417 & net_1371);
  assign net_1371 = ~(net_1372 & net_1373);
  assign net_1373 = ~(net_1374 & net_2169);
  assign net_1372 = ~(net_1375 & iq_instr_dec1_ne_i[21]);
  assign net_1375 = (net_291 & net_2165);
  assign net_291 = ~(net_24 | net_11);
  assign net_1360 = (net_799 & net_617);
  assign net_617 = (net_620 & net_57);
  assign net_1358 = (net_1376 | net_1377);
  assign net_1377 = (net_1378 | net_1379);
  assign net_1379 = ~(net_1380 & net_1381);
  assign net_1381 = ~(net_1382 & net_1383);
  assign net_1383 = (net_363 & net_14);
  assign net_1378 = (net_1384 & net_1109);
  assign net_1109 = ~(iq_instr_dec1_ne_i[4] | net_1385);
  assign net_1376 = (net_939 | net_1386);
  assign net_1386 = (net_1387 | net_129);
  assign net_1387 = (net_201 & net_56);
  assign net_201 = (net_1347 & net_650);
  assign net_939 = (iq_instr_dec1_ne_i[20] & net_187);
  assign net_187 = (net_1347 & net_317);
  assign net_317 = (iq_instr_dec1_ne_i[18] & net_1388);
  assign net_1388 = (net_1348 & net_621);
  assign net_621 = ~(net_59 | net_402);
  assign net_1348 = ~(net_6 | iq_instr_dec1_ne_i[8]);
  assign rf_rd_ctl_fr1_dec1_ne[0] = ~(net_1389 & net_1390);
  assign net_1390 = ~(net_1391 & net_57);
  assign net_1389 = (net_1392 & net_1343);
  assign net_1343 = (net_1043 & net_1393);
  assign net_1393 = (net_580 | net_373);
  assign net_373 = (net_1355 & net_1394);
  assign net_1394 = (net_1395 & net_1396);
  assign net_1396 = ~(net_947 & iq_instr_dec1_ne_i[22]);
  assign net_1395 = (net_813 | net_3);
  assign net_813 = (net_2167 | net_2);
  assign net_1355 = (net_943 & net_1397);
  assign net_1397 = ~(net_710 & iq_instr_dec1_ne_i[22]);
  assign net_710 = ~(a64_only | net_267);
  assign net_943 = (net_817 & net_1398);
  assign net_580 = ~(net_41 & iq_instr_dec1_ne_i[31]);
  assign net_1043 = ~(iq_instr_dec1_ne_i[8] & imm_sel_neon_dec1_ne[19]);
  assign net_1392 = (net_1399 & net_1400);
  assign net_1400 = (net_1216 & net_179);
  assign net_179 = ~(net_272 & net_477);
  assign net_1216 = ~(iq_instr_dec1_ne_i[17] & net_223);
  assign net_1399 = (net_1339 & net_803);
  assign net_803 = ~(net_891 & net_1401);
  assign net_1339 = (net_1402 & net_1403);
  assign net_1403 = (net_1217 & net_801);
  assign net_801 = ~(iq_instr_dec1_ne_i[9] & net_1404);
  assign net_1404 = (net_1405 | net_1406);
  assign net_1406 = (net_1407 | net_1408);
  assign net_1407 = (net_319 & net_1225);
  assign net_1225 = (iq_instr_dec1_ne_i[16] & net_1409);
  assign net_1409 = ~(iq_instr_dec1_ne_i[7] & net_1410);
  assign net_1410 = (net_24 | net_59);
  assign net_319 = (net_63 & net_603);
  assign net_1405 = (net_1411 | net_563);
  assign net_1411 = (net_435 & net_1412);
  assign net_1412 = ~(net_1413 & net_1414);
  assign net_1414 = (iq_instr_dec1_ne_i[8] | net_1415);
  assign net_1217 = ~(net_695 | net_1416);
  assign net_1416 = (imm_sel_neon_dec1_ne[7] | net_1417);
  assign net_1417 = ~(net_1418 & net_1419);
  assign net_1419 = (net_1157 & net_1420);
  assign net_1420 = (net_66 | net_724);
  assign net_724 = ~(net_1421 & net_1332);
  assign net_1332 = ~(net_37 | net_480);
  assign net_1157 = (net_275 & net_1422);
  assign net_1422 = (iq_instr_dec1_ne_i[8] | net_1423);
  assign net_1418 = ~(net_666 | net_1424);
  assign net_1424 = (imm_sel_neon_dec1_ne[9] | net_1425);
  assign net_1425 = ~(net_1426 & net_1427);
  assign net_666 = ~(iq_instr_dec1_ne_i[9] | net_1428);
  assign net_1428 = (net_1429 & net_1430);
  assign net_1430 = (net_1431 & net_1432);
  assign net_1431 = ~(net_1433 & net_1434);
  assign net_1434 = (iq_instr_dec1_ne_i[20] | net_1435);
  assign net_1433 = ~(net_31 | net_559);
  assign net_1429 = (net_541 & net_441);
  assign net_541 = (net_1436 & net_1437);
  assign net_1437 = ~(net_1331 & net_1438);
  assign net_1438 = (net_2164 & net_1421);
  assign net_1331 = (iq_instr_dec1_ne_i[21] & iq_instr_dec1_ne_i[27]);
  assign net_1436 = (net_1439 & net_1440);
  assign net_1440 = ~(net_767 | net_1441);
  assign net_767 = (net_273 & net_460);
  assign net_1439 = (net_863 & net_1442);
  assign net_863 = (net_1443 & net_1444);
  assign net_1444 = ~(iq_instr_dec1_ne_i[8] & net_1445);
  assign net_1445 = (net_1446 | net_1447);
  assign net_1447 = (net_1448 | net_1449);
  assign net_1448 = (net_1450 & net_445);
  assign net_1443 = (net_1451 & net_1452);
  assign net_1452 = (net_452 & net_1453);
  assign net_1453 = (net_1454 | net_1455);
  assign net_1455 = ~(net_280 & net_435);
  assign net_695 = (iq_instr_dec1_ne_i[8] & net_1456);
  assign net_1456 = (net_904 | net_1457);
  assign net_904 = ~(net_1458 & net_517);
  assign net_517 = (net_1141 & net_1459);
  assign net_1459 = (net_11 | net_521);
  assign net_521 = ~(net_2167 & net_318);
  assign net_1141 = (net_39 | net_1460);
  assign net_1460 = ~(net_1461 | net_1462);
  assign net_1462 = (net_13 & iq_instr_dec1_ne_i[28]);
  assign net_1402 = (net_1463 & net_1464);
  assign net_1464 = ~(iq_instr_dec1_ne_i[9] & net_1465);
  assign net_1465 = ~(net_1466 & net_1467);
  assign net_1467 = ~(iq_instr_dec1_ne_i[8] & net_1468);
  assign net_1468 = (net_895 | net_1469);
  assign net_1469 = (net_1470 | net_1471);
  assign net_1471 = (net_1472 & net_1473);
  assign net_1473 = ~(net_57 | net_32);
  assign net_1472 = (net_824 & net_75);
  assign net_1470 = (net_1474 & iq_instr_dec1_ne_i[24]);
  assign net_1474 = ~(net_19 | net_44);
  assign net_895 = ~(iq_instr_dec1_ne_i[7] | net_1239);
  assign net_1239 = ~(iq_instr_dec1_ne_i[28] & net_1475);
  assign net_1475 = ~(net_8 | net_61);
  assign net_1466 = (net_1185 & net_1476);
  assign net_1476 = ~(net_280 & net_1477);
  assign net_1477 = (net_1450 & net_689);
  assign net_1185 = ~(iq_instr_dec1_ne_i[8] & net_1478);
  assign net_1478 = (iq_instr_dec1_ne_i[18] & net_476);
  assign net_1463 = (net_1479 & net_1480);
  assign net_1480 = (sf_bit | net_1269);
  assign net_1269 = (net_1481 & net_1156);
  assign net_1156 = ~(net_1324 & net_597);
  assign net_1481 = (net_1482 & net_1483);
  assign net_1483 = ~(iq_instr_dec1_ne_i[8] & net_1484);
  assign net_1484 = ~(iq_instr_dec1_ne_i[20] | net_1485);
  assign net_1482 = (net_1119 & net_1486);
  assign net_1486 = (net_1487 & net_1488);
  assign net_1488 = ~(net_348 & net_1489);
  assign net_1487 = (net_1490 & net_229);
  assign net_229 = (net_295 & net_21);
  assign net_295 = (iq_instr_dec1_ne_i[10] | net_1491);
  assign net_1491 = (net_50 | net_575);
  assign net_1490 = ~(net_1492 & net_891);
  assign net_1479 = (net_1493 & net_1494);
  assign net_1494 = ~(rf_rd_ctl_fr1_dec1_ne[5] | net_1495);
  assign net_1495 = (net_101 | net_1496);
  assign net_1496 = ~(net_1497 & net_1498);
  assign net_1498 = (net_1317 & net_1499);
  assign net_1499 = (net_1365 | net_1500);
  assign net_1500 = (net_169 | net_2164);
  assign net_1365 = ~(net_57 & iq_instr_dec1_ne_i[16]);
  assign net_1497 = (net_1501 & net_1502);
  assign net_1502 = (net_759 | net_64);
  assign net_759 = ~(iq_instr_dec1_ne_i[4] & net_1503);
  assign net_1503 = (net_1059 & net_48);
  assign net_1501 = (net_751 & net_1504);
  assign net_1504 = (net_299 & net_1505);
  assign net_1505 = ~(net_1506 & net_1507);
  assign net_1507 = ~(net_35 | net_559);
  assign net_299 = ~(iq_instr_dec1_ne_i[7] & net_1508);
  assign net_1508 = (net_1012 & net_1082);
  assign net_751 = (net_2167 | net_21);
  assign rf_rd_ctl_fr1_dec1_ne[5] = (imm_sel_neon_dec1_ne[20] | imm_sel_neon_dec1_ne[21]);
  assign net_1493 = (net_1509 & net_1510);
  assign net_1510 = ~(iq_instr_dec1_ne_i[28] & net_1511);
  assign net_1511 = (net_1512 | net_1513);
  assign net_1513 = (net_1514 | net_1515);
  assign net_1515 = (net_331 & net_1516);
  assign net_1516 = (net_1517 | net_1518);
  assign net_1518 = (net_406 & net_1519);
  assign net_1519 = ~(net_75 | net_480);
  assign net_1517 = (net_1520 | net_1521);
  assign net_1521 = (net_75 & net_1522);
  assign net_1522 = (net_791 | net_1523);
  assign net_1523 = (net_794 & net_1233);
  assign net_1233 = (net_157 | net_798);
  assign net_798 = ~(net_72 | sf_bit);
  assign net_157 = ~(iq_instr_dec1_ne_i[6] | iq_instr_dec1_ne_i[7]);
  assign net_791 = ~(net_61 | net_58);
  assign net_1520 = ~(sf_bit | net_1524);
  assign net_1524 = ~(iq_instr_dec1_ne_i[11] & net_1525);
  assign net_1514 = (net_1526 & net_1527);
  assign net_1512 = (net_1528 | net_1529);
  assign net_1529 = ~(net_1530 & net_1531);
  assign net_1531 = ~(net_1532 & iq_instr_dec1_ne_i[11]);
  assign net_1530 = ~(net_1533 & net_2164);
  assign net_1528 = (net_122 & net_1534);
  assign net_1534 = (net_13 & net_57);
  assign net_1509 = (iq_instr_dec1_ne_i[9] | net_1535);
  assign net_1535 = (net_1536 & net_1537);
  assign net_1537 = ~(iq_instr_dec1_ne_i[8] & net_1538);
  assign net_1538 = ~(net_1539 & net_1540);
  assign net_1540 = (net_155 | sf_bit);
  assign net_155 = ~(net_280 & net_1357);
  assign net_1539 = ~(net_1215 | net_1541);
  assign net_1215 = (iq_instr_dec1_ne_i[7] & net_1208);
  assign net_1208 = ~(net_75 | net_575);
  assign net_1536 = (net_1542 & net_1543);
  assign net_1543 = (net_1544 & net_1545);
  assign net_1545 = ~(iq_instr_dec1_ne_i[10] & net_1546);
  assign net_1546 = (net_1202 & net_1547);
  assign net_1547 = (net_1209 | net_1548);
  assign net_1548 = ~(net_72 | iq_instr_dec1_ne_i[8]);
  assign net_1209 = ~(net_24 | net_2168);
  assign net_1544 = ~(net_297 & net_2164);
  assign net_1542 = (net_1264 & net_1549);
  assign net_1549 = (net_93 | net_1550);
  assign net_1550 = (net_42 | net_62);
  assign net_1264 = ~(net_603 & net_1298);
  assign rf_rd_ctl_fr0_dec1_ne[7] = ~(net_1551 & net_1552);
  assign net_1551 = ~(rf_rd_ctl_fr2_dec1_ne[9] | net_1553);
  assign net_1553 = ~(net_1554 & net_127);
  assign net_1554 = (net_872 & net_1555);
  assign net_1555 = (sf_bit | net_1556);
  assign rf_rd_ctl_fr2_dec1_ne[9] = (net_1557 & net_340);
  assign rf_rd_ctl_fr0_dec1_ne[4] = (rf_rd_ctl_fr0_dec1_ne[2] | net_1558);
  assign net_1558 = ~(net_1559 & net_1560);
  assign net_1559 = ~(net_1561 | net_1562);
  assign net_1562 = ~(net_374 & net_1317);
  assign net_1561 = (iq_instr_dec1_ne_i[6] & net_1563);
  assign net_1563 = (net_1564 | net_1565);
  assign net_1565 = ~(net_969 & net_1566);
  assign net_1564 = (net_1567 & net_1568);
  assign net_1568 = ~(net_67 | net_24);
  assign net_1567 = (net_1569 & net_2169);
  assign rf_rd_ctl_fr0_dec1_ne[2] = ~(net_127 | net_74);
  assign rf_rd_ctl_fr0_dec1_ne[1] = (net_1570 | net_1571);
  assign net_1571 = ~(net_1572 & net_1573);
  assign net_1573 = ~(net_721 & net_1492);
  assign net_721 = ~(net_64 | sf_bit);
  assign rf_rd_ctl_fr0_dec1_ne[17] = ~(net_1574 & net_1575);
  assign net_1575 = (net_1576 & net_1577);
  assign net_1577 = ~(net_1578 | net_2163);
  assign net_1580 = (net_656 & iq_instr_dec1_ne_i[23]);
  assign rf_rd_ctl_fr0_dec1_ne[16] = ~(net_1581 & net_1582);
  assign net_1582 = ~(net_369 & net_2170);
  assign net_1581 = (net_1368 & net_1364);
  assign net_1364 = (net_1583 | net_2170);
  assign net_1583 = (net_1584 & net_1585);
  assign net_1585 = ~(net_1586 & net_1587);
  assign net_1584 = (net_1556 & net_1588);
  assign net_1588 = (net_525 | net_1589);
  assign net_1589 = ~(iq_instr_dec1_ne_i[10] & net_891);
  assign net_525 = ~(net_1590 & net_606);
  assign net_1368 = ~(rf_rd_ctl_fr2_dec1_ne[18] | net_1591);
  assign net_1591 = (net_1384 & net_1592);
  assign rf_rd_ctl_fr0_dec1_ne[15] = (net_1593 & net_57);
  assign net_1593 = (sf_bit & net_958);
  assign rf_rd_ctl_fr0_dec1_ne[0] = ~(net_1594 & net_127);
  assign net_127 = ~(sf_bit & net_369);
  assign net_369 = ~(iq_instr_dec1_ne_i[22] | net_1595);
  assign net_1595 = ~(net_814 & net_2168);
  assign net_814 = (net_947 & net_41);
  assign net_1594 = ~(rf_rd_ctl_fr0_dec1_ne[6] | net_1596);
  assign net_1596 = ~(net_1572 & net_1597);
  assign net_1597 = ~(net_2170 & net_1598);
  assign net_1598 = (net_420 & net_1492);
  assign net_420 = ~(net_69 | iq_instr_dec1_ne_i[10]);
  assign net_1572 = (net_1599 & net_1600);
  assign net_1600 = (net_559 | net_1601);
  assign net_1599 = ~(rf_rd_ctl_fr0_dec1_ne[8] | net_1602);
  assign net_1602 = (net_1603 | net_1604);
  assign net_1604 = ~(net_1552 & net_1427);
  assign net_1427 = ~(a64_only & net_1605);
  assign net_1605 = (net_1606 & net_1557);
  assign net_1557 = ~(net_2169 | net_40);
  assign net_1552 = (net_1607 & net_1608);
  assign net_1608 = ~(net_122 & net_1592);
  assign net_1607 = (net_969 & net_1609);
  assign net_969 = ~(net_1059 & net_972);
  assign rf_rd_ctl_fr0_dec1_ne[8] = ~(net_109 & net_970);
  assign net_970 = ~(iq_instr_dec1_ne_i[28] & net_1610);
  assign net_1610 = (net_177 & net_1569);
  assign net_1569 = (iq_instr_dec1_ne_i[4] & net_1611);
  assign net_1611 = ~(net_2167 & net_335);
  assign net_109 = (net_1612 & net_1613);
  assign net_1612 = (net_1614 & net_1615);
  assign net_1615 = (net_1616 | net_120);
  assign net_1614 = (net_1617 & net_1618);
  assign rf_rd_ctl_fr0_dec1_ne[6] = (rf_wr_when_w0_dec1_ne[1] | net_1570);
  assign net_1570 = ~(net_960 & net_1619);
  assign net_1619 = ~(net_958 & net_2170);
  assign net_958 = (net_599 & net_1338);
  assign net_960 = (net_374 & net_1620);
  assign net_1620 = (net_57 | net_1621);
  assign net_374 = ~(net_891 & net_1622);
  assign net_1622 = (net_956 & net_200);
  assign net_139 = ~(iq_instr_dec1_ne_i[20] & net_81);
  assign raw_lsm_immed_dec1_ne[1] = (sf_bit & imm_sel_neon_dec1_ne[14]);
  assign neon_lsm_aligntype_dec1_ne[0] = (rf_rd_need_r1_dec1_ne[0] | net_1623);
  assign net_1623 = ~(net_1624 & net_1625);
  assign net_1625 = (net_1626 & net_1627);
  assign net_1627 = ~(net_96 & net_1628);
  assign net_1626 = (net_1317 & net_1629);
  assign net_1629 = ~(imm_sel_neon_dec1_ne[18] | net_1630);
  assign net_1630 = ~(net_1002 & net_1631);
  assign net_1631 = (net_137 & net_1632);
  assign net_137 = (net_24 | net_1633);
  assign net_1002 = (iq_instr_dec1_ne_i[27] | net_2168);
  assign rf_rd_need_r1_dec1_ne[0] = (net_1634 | net_992);
  assign neon_elem_size_dec1_ne[1] = ~(net_1635 & net_1636);
  assign net_1635 = ~(net_1637 | net_1638);
  assign net_1638 = ~(net_995 & net_1639);
  assign net_1637 = ~(net_1640 & net_1641);
  assign net_1641 = (iq_instr_dec1_ne_i[25] | net_1642);
  assign net_1642 = (iq_instr_dec1_ne_i[26] | net_577);
  assign net_577 = (net_2165 | net_72);
  assign neon_elem_size_dec1_ne[0] = ~(net_1426 & net_1643);
  assign net_1643 = (net_1644 & net_1645);
  assign net_1645 = ~(net_1646 & iq_instr_dec1_ne_i[6]);
  assign net_1644 = (net_1647 & net_1648);
  assign net_1426 = (net_91 & net_1613);
  assign net_1613 = ~(iq_instr_dec1_ne_i[23] & net_1649);
  assign neon_can_fwd_acc_dec1_ne = (net_177 & net_1650);
  assign net_1650 = (net_194 | net_1651);
  assign net_1651 = (net_178 | net_515);
  assign net_178 = (net_1013 | net_445);
  assign mul_neon_out_fmt_dec1_ne[2] = (net_1267 | net_1652);
  assign net_1652 = ~(net_1653 & net_1654);
  assign net_1654 = ~(net_445 & net_177);
  assign net_445 = ~(net_63 | net_2167);
  assign net_1267 = ~(net_2164 | net_1601);
  assign mul_neon_out_fmt_dec1_ne[1] = ~(net_1556 & net_1655);
  assign net_1655 = (net_1653 & net_1656);
  assign net_1653 = (net_1621 & net_1657);
  assign net_1657 = ~(iq_instr_dec1_ne_i[11] & net_1658);
  assign net_1658 = (net_1338 & iq_instr_dec1_ne_i[16]);
  assign net_1338 = (net_476 & net_227);
  assign net_1621 = ~(net_1659 & net_2165);
  assign net_1659 = (net_599 & net_551);
  assign net_1556 = (net_1660 | net_69);
  assign net_891 = ~(net_2164 | net_2165);
  assign net_1660 = (net_1601 & net_1661);
  assign net_1661 = ~(net_1492 & net_1526);
  assign mul_neon_out_fmt_dec1_ne[0] = ~(net_1662 & net_892);
  assign net_892 = ~(net_177 & net_194);
  assign net_194 = ~(net_50 | a64_only);
  assign net_1662 = (net_1656 & net_1663);
  assign net_1656 = (net_872 & net_1664);
  assign net_1664 = ~(net_1013 & net_1665);
  assign net_1665 = (net_656 & net_1285);
  assign net_656 = ~(iq_instr_dec1_ne_i[20] | iq_instr_dec1_ne_i[21]);
  assign net_872 = ~(net_606 & net_1666);
  assign net_1666 = (net_515 & net_1285);
  assign net_1285 = ~(net_67 | iq_instr_dec1_ne_i[10]);
  assign net_515 = ~(net_22 | iq_instr_dec1_ne_i[21]);
  assign ls_store_dec1_ne = (net_141 | net_1578);
  assign net_1578 = (net_142 | net_1667);
  assign net_142 = ~(iq_instr_dec1_ne_i[20] | net_624);
  assign net_141 = ~(net_1668 & net_1669);
  assign net_1669 = ~(net_2167 & net_378);
  assign net_1668 = (net_1670 & net_1671);
  assign net_1671 = (net_1672 & net_1618);
  assign net_1618 = (net_1560 & net_1673);
  assign net_1673 = (net_1674 & net_1675);
  assign net_1675 = (net_1676 | iq_instr_dec1_ne_i[20]);
  assign net_1676 = (net_1633 & net_1677);
  assign net_1677 = (net_383 | net_2169);
  assign net_1560 = ~(net_101 | net_1678);
  assign net_1678 = ~(net_809 & net_1321);
  assign net_1670 = (net_1576 & net_1640);
  assign net_1576 = ~(net_129 | net_1679);
  assign net_1679 = (net_1680 & net_32);
  assign net_1680 = (net_1454 & net_1681);
  assign ls_size_dec1_ne[1] = ~(net_1682 & net_1683);
  assign net_1683 = ~(net_101 | net_1684);
  assign net_1684 = ~(net_1685 & net_1686);
  assign net_1686 = (net_1687 & net_1688);
  assign net_1685 = (net_1689 & net_1690);
  assign net_1690 = (iq_instr_dec1_ne_i[24] | iq_instr_dec1_ne_i[27]);
  assign net_1689 = (net_749 & net_1691);
  assign net_1691 = (net_1639 & net_1692);
  assign net_1692 = (net_33 | net_1693);
  assign net_1693 = (net_63 | net_20);
  assign net_1639 = ~(net_378 & net_43);
  assign ls_size_dec1_ne[0] = ~(net_132 & net_1694);
  assign net_1694 = ~(net_101 | net_1695);
  assign net_1695 = ~(net_1687 & net_1696);
  assign net_1696 = (net_1648 & net_1633);
  assign net_1648 = ~(net_1697 | net_1698);
  assign net_1698 = ~(iq_instr_dec1_ne_i[23] | net_1699);
  assign net_1699 = ~(net_200 & net_318);
  assign net_200 = ~(net_24 | iq_instr_dec1_ne_i[11]);
  assign net_1697 = ~(net_1700 & net_1701);
  assign net_1701 = (net_1702 | iq_instr_dec1_ne_i[26]);
  assign net_1702 = (net_1703 & net_1704);
  assign net_1704 = ~(iq_instr_dec1_ne_i[21] & net_2169);
  assign net_1700 = ~(net_1634 | net_1705);
  assign net_1705 = ~(net_749 & net_1616);
  assign net_1616 = ~(iq_instr_dec1_ne_i[21] & imm_sel_neon_dec1_ne[18]);
  assign net_1634 = (net_994 & net_43);
  assign net_1687 = (net_134 & net_1617);
  assign net_132 = ~(net_1649 | net_1706);
  assign net_1706 = (net_266 & net_1533);
  assign net_1649 = ~(net_1707 & net_1640);
  assign ls_size_dec1_ne[2] = ~(net_1674 & net_1708);
  assign net_1708 = ~(neon_elem_size_dec1_ne[2] | net_1709);
  assign net_1709 = (iq_instr_dec1_ne_i[23] & net_100);
  assign neon_elem_size_dec1_ne[2] = (net_101 | net_1710);
  assign net_1710 = (net_1711 & net_1628);
  assign net_1628 = ~(net_19 & net_1712);
  assign net_101 = (iq_instr_dec1_ne_i[24] & net_378);
  assign ls_length_dec1_ne[1] = ~(net_1713 & net_1714);
  assign net_1714 = (net_1647 & net_1715);
  assign net_1715 = (net_606 | net_754);
  assign net_754 = ~(iq_instr_dec1_ne_i[21] & net_1716);
  assign net_1716 = (imm_sel_neon_dec1_ne[18] | net_1717);
  assign net_1713 = ~(net_129 | net_1718);
  assign net_1718 = ~(net_749 & net_1617);
  assign net_1617 = ~(net_1719 & net_30);
  assign net_103 = (a64_only & net_24);
  assign ls_instr_type_dec1_ne[3] = ~(net_1738 | net_39);
  assign imm_sel_neon_dec1_ne[8] = (net_896 | rf_rd_ctl_fr2_dec1_ne[5]);
  assign rf_rd_ctl_fr2_dec1_ne[5] = (net_712 & net_569);
  assign net_569 = ~(iq_instr_dec1_ne_i[9] | sf_bit);
  assign net_896 = (net_512 & net_72);
  assign imm_sel_neon_dec1_ne[6] = ~(net_1740 & net_1741);
  assign net_1741 = ~(set_15_12_as_r31 & instr_fmstat_dec1_ne);
  assign net_1740 = (net_1742 | net_1743);
  assign imm_sel_neon_dec1_ne[5] = ~(net_1744 & net_1745);
  assign net_1745 = ~(iq_instr_dec1_ne_i[17] & net_1746);
  assign net_1746 = (net_1747 & net_1748);
  assign net_1748 = (net_41 | net_1749);
  assign net_1749 = ~(net_72 | iq_instr_dec1_ne_i[4]);
  assign net_1744 = (net_1750 | net_1751);
  assign net_1751 = (net_1743 & net_1752);
  assign net_1752 = ~(iq_instr_dec1_ne_i[22] & net_1753);
  assign net_1753 = (net_233 & set_15_12_as_r31);
  assign net_1743 = (net_1754 & net_1755);
  assign net_1755 = ~(net_47 & net_1756);
  assign net_1754 = ~(net_1757 | net_665);
  assign net_1757 = ~(net_47 | net_482);
  assign net_482 = (net_6 | iq_instr_dec1_ne_i[21]);
  assign imm_sel_neon_dec1_ne[4] = (net_1758 & net_1759);
  assign net_1759 = (net_75 | net_1384);
  assign net_1758 = (net_1747 & net_202);
  assign net_202 = ~(net_59 | iq_instr_dec1_ne_i[7]);
  assign wd_align_pc_dec1_ne = ~(net_624 & net_1760);
  assign net_1760 = ~(net_772 & net_20);
  assign imm_sel_neon_dec1_ne[21] = ~(iq_instr_dec1_ne_i[9] | net_1761);
  assign net_1761 = ~(sf_bit & net_712);
  assign net_712 = ~(net_19 | net_8);
  assign imm_sel_neon_dec1_ne[1] = (net_1249 | net_1762);
  assign net_1762 = ~(net_1763 & net_1764);
  assign net_1764 = (net_1742 | net_1765);
  assign net_1742 = (net_95 | net_2170);
  assign net_1763 = (net_875 & net_1766);
  assign net_1766 = ~(net_352 & net_1767);
  assign net_1767 = ~(net_360 | net_466);
  assign net_466 = (net_55 | net_1768);
  assign net_875 = (net_1769 | net_57);
  assign net_1769 = (net_1770 & net_1771);
  assign net_1771 = (net_1772 | net_768);
  assign net_768 = ~(aarch64_state_i & net_1773);
  assign net_1249 = (net_1382 & net_1391);
  assign net_1391 = (aarch64_state_i & net_223);
  assign imm_sel_neon_dec1_ne[17] = ~(net_1774 & net_1775);
  assign net_1775 = (iq_instr_dec1_ne_i[25] | net_1776);
  assign net_1774 = (net_1777 & net_1778);
  assign net_1778 = (net_1779 & net_1780);
  assign net_1780 = (net_1781 | net_1782);
  assign net_1782 = ~(net_42 | net_2164);
  assign imm_sel_neon_dec1_ne[16] = ~(net_1738 & net_91);
  assign imm_sel_neon_dec1_ne[12] = ~(net_1783 & net_1784);
  assign net_1784 = ~(net_1785 & net_120);
  assign net_120 = (net_2169 | iq_instr_dec1_ne_i[20]);
  assign net_1783 = (net_73 | net_29);
  assign imm_sel_neon_dec1_ne[11] = ~(net_1786 & net_1787);
  assign net_1787 = ~(net_2165 & net_1788);
  assign net_1788 = (net_233 & net_1789);
  assign net_1789 = (net_1790 | net_1791);
  assign net_1791 = ~(net_62 | net_480);
  assign net_1790 = (net_2167 & net_1792);
  assign net_1792 = ~(net_63 | net_1793);
  assign net_1786 = (net_1794 & net_1795);
  assign net_1795 = ~(a64_only & net_348);
  assign net_1794 = (net_1796 | net_1797);
  assign net_1797 = (net_66 & net_1798);
  assign net_1798 = ~(net_63 & net_2166);
  assign net_1796 = (net_1054 & net_1799);
  assign net_1799 = ~(net_665 & net_49);
  assign net_665 = ~(net_6 | iq_instr_dec1_ne_i[20]);
  assign net_1054 = (net_5 | net_480);
  assign imm_sel_neon_dec1_ne[10] = (net_1800 & net_196);
  assign net_196 = (net_1179 | net_1801);
  assign net_1801 = (net_2168 & net_52);
  assign net_1179 = ~(net_75 | net_1793);
  assign imm_sel_neon_dec1_ne[0] = ~(net_1802 & net_612);
  assign net_612 = ~(net_1346 & net_503);
  assign net_503 = (net_223 & net_72);
  assign net_1802 = (net_883 & net_1803);
  assign net_1803 = (net_1804 & net_1805);
  assign net_1805 = ~(net_223 & net_1806);
  assign net_1806 = (net_59 & net_14);
  assign net_223 = (iq_instr_dec1_ne_i[8] & net_363);
  assign net_363 = (net_1747 & net_75);
  assign net_1804 = (net_1807 & net_1808);
  assign net_1808 = ~(net_233 & net_1809);
  assign net_1809 = (net_1810 & net_318);
  assign net_1807 = (net_1811 & net_1812);
  assign net_1812 = ~(iq_instr_dec1_ne_i[21] & net_1813);
  assign net_1813 = (net_1366 & iq_instr_dec1_ne_i[18]);
  assign net_1811 = (net_1765 | net_1750);
  assign net_1750 = (net_95 | sf_bit);
  assign net_883 = (net_1814 & net_1380);
  assign net_1380 = (net_526 | iq_instr_dec1_ne_i[17]);
  assign net_526 = ~(net_1384 & net_1747);
  assign net_1747 = (net_1435 & net_1815);
  assign net_1815 = (net_824 & net_1816);
  assign net_824 = (iq_instr_dec1_ne_i[21] & net_352);
  assign net_1435 = ~(net_2169 | net_55);
  assign net_1814 = (net_1817 & net_1818);
  assign net_1818 = (net_2164 | net_628);
  assign net_628 = ~(net_1773 & net_1819);
  assign net_1819 = ~(net_2167 | net_1820);
  assign net_1817 = (net_1770 | iq_instr_dec1_ne_i[18]);
  assign net_1770 = ~(net_1821 & net_1822);
  assign net_1822 = ~(net_1823 & net_1824);
  assign net_1824 = ~(net_1526 & net_2165);
  assign net_1526 = ~(net_42 | iq_instr_dec1_ne_i[10]);
  assign net_1823 = ~(net_492 & net_1059);
  assign net_1821 = (iq_instr_dec1_ne_i[28] & net_1825);
  assign net_1825 = (iq_instr_dec1_ne_i[17] & net_922);
  assign fp_ex_pipe_dec1_ne[3] = ~(net_1826 & net_1827);
  assign net_1827 = ~(net_199 & net_1828);
  assign net_1828 = (net_1068 & net_347);
  assign net_1826 = (net_73 | net_1566);
  assign net_1566 = (net_1829 & net_21);
  assign net_1829 = (net_1830 & net_1831);
  assign net_1831 = ~(iq_instr_dec1_ne_i[10] & net_1832);
  assign net_1832 = (net_199 & net_227);
  assign net_199 = (net_603 & net_599);
  assign net_1830 = (net_1288 & net_1833);
  assign net_1833 = (net_64 | net_1834);
  assign net_1834 = ~(net_1013 & net_689);
  assign net_1288 = (net_1835 & net_1836);
  assign net_1836 = (net_1119 | iq_instr_dec1_ne_i[9]);
  assign net_1835 = (net_1837 | iq_instr_dec1_ne_i[23]);
  assign net_1837 = (net_22 | net_67);
  assign fp_ex_pipe_dec1_ne[2] = ~(net_1838 & net_1609);
  assign net_1609 = (net_1839 | net_63);
  assign net_1839 = (net_1840 & net_1841);
  assign net_1841 = ~(net_557 & net_878);
  assign net_878 = (net_1842 | net_1843);
  assign net_1843 = (net_972 & net_2168);
  assign net_972 = ~(net_44 | iq_instr_dec1_ne_i[9]);
  assign net_1842 = (net_2170 & net_1844);
  assign net_1844 = (net_406 & iq_instr_dec1_ne_i[21]);
  assign net_1840 = (net_1845 & net_1846);
  assign net_1846 = (net_1847 | net_1848);
  assign net_1848 = ~(iq_instr_dec1_ne_i[4] & net_435);
  assign net_1847 = (net_1849 & net_1850);
  assign net_1850 = ~(net_24 & net_1851);
  assign net_1849 = (net_2167 | iq_instr_dec1_ne_i[9]);
  assign net_1845 = ~(net_177 & net_1852);
  assign net_1852 = ~(net_3 & net_1853);
  assign net_1853 = ~(net_273 | iq_instr_dec1_ne_i[20]);
  assign net_177 = ~(net_45 | net_67);
  assign net_1838 = ~(net_1603 | net_1854);
  assign net_1854 = ~(net_965 & net_1855);
  assign net_1855 = (net_1663 & net_928);
  assign net_928 = ~(net_193 & net_1587);
  assign net_1587 = ~(net_62 | net_335);
  assign net_335 = (net_42 | net_2168);
  assign net_193 = (sf_bit & net_1586);
  assign net_1586 = (net_1454 & net_406);
  assign net_1663 = ~(net_1856 & net_406);
  assign net_406 = ~(net_2166 | iq_instr_dec1_ne_i[9]);
  assign net_1856 = (net_228 & net_1857);
  assign net_1857 = ~(net_1858 & iq_instr_dec1_ne_i[11]);
  assign net_1858 = (net_559 & net_1859);
  assign net_1859 = ~(net_57 & iq_instr_dec1_ne_i[8]);
  assign net_559 = ~(net_2170 & iq_instr_dec1_ne_i[8]);
  assign net_228 = (net_17 & net_599);
  assign net_965 = (net_507 & net_1860);
  assign net_1860 = (net_1861 & net_1862);
  assign net_1862 = ~(net_42 & net_1592);
  assign net_1592 = (net_75 & net_1863);
  assign net_1863 = ~(net_581 & net_1864);
  assign net_1864 = ~(net_1230 & net_2168);
  assign net_1861 = ~(iq_instr_dec1_ne_i[8] & net_167);
  assign net_167 = ~(net_1865 & net_1601);
  assign net_1601 = ~(net_1506 & net_1312);
  assign net_1506 = (iq_instr_dec1_ne_i[11] & net_1450);
  assign net_1865 = (net_1866 & net_1867);
  assign net_1867 = ~(net_1492 & net_1868);
  assign net_1868 = (iq_instr_dec1_ne_i[9] & net_2166);
  assign net_1492 = (net_273 & net_272);
  assign net_1603 = (net_1441 & net_227);
  assign net_1441 = ~(net_22 | net_93);
  assign net_93 = ~(net_2169 & net_2168);
  assign fp_ex_pipe_dec1_ne[1] = (net_1869 | net_1870);
  assign net_1870 = (net_1871 | net_582);
  assign net_582 = (iq_instr_dec1_ne_i[6] & net_1872);
  assign net_1872 = (net_1281 | net_1873);
  assign net_1873 = (net_1874 | net_1875);
  assign net_1875 = (net_1876 | net_1077);
  assign net_1077 = (net_1877 | net_1878);
  assign net_1878 = (net_1879 | net_1282);
  assign net_1282 = ~(net_1880 & net_275);
  assign net_275 = ~(net_1450 & net_1059);
  assign net_1880 = (net_1881 & net_1882);
  assign net_1882 = ~(iq_instr_dec1_ne_i[24] & net_1883);
  assign net_1883 = (net_340 & iq_instr_dec1_ne_i[9]);
  assign net_1881 = (net_1884 | net_45);
  assign net_1884 = (net_1885 & net_1886);
  assign net_1886 = ~(net_846 & net_13);
  assign net_1879 = (iq_instr_dec1_ne_i[21] & net_1286);
  assign net_1877 = ~(net_1887 & net_1888);
  assign net_1888 = ~(net_1889 & net_2165);
  assign net_1889 = (net_1059 & net_2169);
  assign net_1887 = ~(net_1072 & net_1890);
  assign net_1890 = ~(net_1891 & net_1892);
  assign net_1892 = ~(net_782 & net_63);
  assign net_782 = (iq_instr_dec1_ne_i[16] & net_846);
  assign net_846 = ~(iq_instr_dec1_ne_i[8] | iq_instr_dec1_ne_i[9]);
  assign net_1891 = ~(net_1164 & net_460);
  assign net_1072 = (net_59 & net_1088);
  assign net_1876 = (net_1893 & net_2165);
  assign net_1893 = ~(net_35 | net_1894);
  assign net_1894 = ~(net_1895 & net_1896);
  assign net_1896 = ~(iq_instr_dec1_ne_i[10] & net_1046);
  assign net_1046 = (iq_instr_dec1_ne_i[17] | iq_instr_dec1_ne_i[7]);
  assign net_1874 = ~(net_1897 & net_1898);
  assign net_1898 = ~(net_1286 & net_43);
  assign net_1286 = (net_689 & net_322);
  assign net_322 = ~(net_75 | iq_instr_dec1_ne_i[11]);
  assign net_1897 = ~(net_1082 & net_1287);
  assign net_1287 = ~(iq_instr_dec1_ne_i[21] | net_52);
  assign net_1281 = (net_1899 | net_1900);
  assign net_1900 = (net_1901 | net_512);
  assign net_1901 = (iq_instr_dec1_ne_i[20] & net_1902);
  assign net_1902 = (net_1903 & net_273);
  assign net_1899 = (net_280 & net_1904);
  assign net_1904 = ~(net_1905 | net_72);
  assign net_1871 = (iq_instr_dec1_ne_i[6] & net_1076);
  assign net_1076 = ~(net_1906 & net_448);
  assign net_448 = ~(net_435 & net_1907);
  assign net_1906 = (net_1908 & net_1909);
  assign net_1909 = ~(net_1374 & net_435);
  assign net_1374 = (net_1164 & net_557);
  assign net_1908 = (net_1100 | net_1885);
  assign net_1885 = ~(iq_instr_dec1_ne_i[28] & net_557);
  assign net_1100 = (net_2165 | iq_instr_dec1_ne_i[23]);
  assign net_1869 = (net_1910 | net_1911);
  assign net_1911 = (net_1912 | net_1304);
  assign net_1304 = (net_34 & net_1913);
  assign net_1913 = (net_1914 & net_1915);
  assign net_1915 = (net_352 & net_59);
  assign net_1914 = ~(net_67 | iq_instr_dec1_ne_i[4]);
  assign net_1912 = (net_1297 & net_1916);
  assign net_1916 = (net_347 & net_1917);
  assign net_1917 = (net_1895 | net_1918);
  assign net_1918 = ~(net_72 | net_63);
  assign net_1895 = ~(iq_instr_dec1_ne_i[11] | iq_instr_dec1_ne_i[16]);
  assign net_1910 = (net_2166 & net_1919);
  assign net_1919 = (net_1920 | net_1921);
  assign net_1921 = (iq_instr_dec1_ne_i[16] & net_1922);
  assign net_1922 = (net_352 & net_597);
  assign net_597 = ~(net_11 | iq_instr_dec1_ne_i[11]);
  assign net_352 = ~(net_2167 | net_73);
  assign net_1920 = (net_1059 & net_347);
  assign net_347 = ~(net_73 | iq_instr_dec1_ne_i[9]);
  assign fp_ex_pipe_dec1_ne[0] = (net_1923 | net_1924);
  assign net_1924 = (net_1925 | net_1926);
  assign net_1926 = (net_1927 | net_832);
  assign net_832 = ~(net_1928 & net_547);
  assign net_547 = (net_1929 | net_2165);
  assign net_1929 = ~(net_1930 | net_1931);
  assign net_1931 = ~(net_1099 | iq_instr_dec1_ne_i[23]);
  assign net_1099 = (net_1932 & net_1933);
  assign net_1933 = (net_1413 | net_2166);
  assign net_1413 = (net_1934 & net_1935);
  assign net_1935 = (net_2167 | iq_instr_dec1_ne_i[8]);
  assign net_1934 = ~(iq_instr_dec1_ne_i[8] & net_1907);
  assign net_1907 = ~(net_11 | net_37);
  assign net_1932 = (net_1936 & net_1937);
  assign net_1937 = (iq_instr_dec1_ne_i[10] | net_1938);
  assign net_1938 = ~(net_689 & net_348);
  assign net_1936 = ~(net_433 & net_2164);
  assign net_433 = ~(net_1939 | net_61);
  assign net_1930 = (iq_instr_dec1_ne_i[8] & net_1940);
  assign net_1940 = (net_845 | net_1401);
  assign net_1401 = ~(net_45 | net_1415);
  assign net_1415 = (iq_instr_dec1_ne_i[11] | net_1939);
  assign net_1928 = ~(net_672 | net_1941);
  assign net_1941 = ~(net_1942 & net_1943);
  assign net_1943 = (net_985 | net_29);
  assign net_985 = ~(net_1095 & net_2167);
  assign net_1095 = ~(net_47 | net_73);
  assign net_1942 = ~(imm_sel_neon_dec1_ne[19] | net_1944);
  assign net_1944 = ~(net_1026 & net_1945);
  assign net_1945 = (net_2164 | net_166);
  assign net_166 = (net_1458 & net_901);
  assign net_901 = (net_1485 | net_430);
  assign net_430 = (iq_instr_dec1_ne_i[20] | sf_bit);
  assign net_1485 = (net_10 | net_2166);
  assign net_1458 = (net_447 & net_1946);
  assign net_1946 = (net_1173 | net_10);
  assign net_1173 = (net_2166 | iq_instr_dec1_ne_i[21]);
  assign net_447 = ~(net_947 & net_858);
  assign net_858 = ~(net_11 | net_50);
  assign net_1026 = ~(net_1773 & net_2168);
  assign net_672 = (net_477 & net_1228);
  assign net_1228 = (iq_instr_dec1_ne_i[9] | net_272);
  assign net_272 = (net_2167 & net_1947);
  assign net_477 = (iq_instr_dec1_ne_i[10] & net_1461);
  assign net_1927 = (net_1948 | net_1949);
  assign net_1949 = (net_1950 | imm_sel_neon_dec1_ne[20]);
  assign imm_sel_neon_dec1_ne[20] = (iq_instr_dec1_ne_i[9] & net_414);
  assign net_1950 = (net_551 & net_60);
  assign net_551 = ~(net_418 | net_61);
  assign net_1948 = (net_1951 | net_1952);
  assign net_1952 = (imm_sel_neon_dec1_ne[9] | net_1953);
  assign net_1953 = (net_1954 | net_1248);
  assign net_1248 = ~(net_451 & net_773);
  assign net_773 = ~(net_1773 & net_57);
  assign net_451 = ~(net_1773 & net_1955);
  assign net_1955 = ~(net_2167 & net_14);
  assign net_1954 = (net_1956 | net_638);
  assign net_638 = ~(net_2169 | net_1174);
  assign net_1174 = ~(net_350 & net_52);
  assign net_350 = ~(net_31 | net_67);
  assign net_1956 = ~(net_267 | net_1957);
  assign net_1957 = (net_67 | net_1905);
  assign net_267 = ~(net_2168 & iq_instr_dec1_ne_i[20]);
  assign imm_sel_neon_dec1_ne[9] = (iq_instr_dec1_ne_i[10] & net_1958);
  assign net_1958 = (net_463 & iq_instr_dec1_ne_i[7]);
  assign net_1951 = (net_756 | net_1959);
  assign net_1959 = ~(net_840 & net_1960);
  assign net_1960 = ~(iq_instr_dec1_ne_i[9] & net_1408);
  assign net_1408 = (iq_instr_dec1_ne_i[7] & net_476);
  assign net_476 = ~(net_2166 | net_418);
  assign net_840 = ~(net_414 & net_57);
  assign net_414 = ~(net_63 | net_418);
  assign net_756 = ~(net_2164 | net_441);
  assign net_441 = ~(iq_instr_dec1_ne_i[28] & net_688);
  assign net_1925 = (net_2165 & net_1961);
  assign net_1961 = (net_1446 | net_1962);
  assign net_1962 = (net_1963 | net_1964);
  assign net_1964 = (net_1965 | net_1966);
  assign net_1966 = (net_1967 | net_1186);
  assign net_1967 = (iq_instr_dec1_ne_i[28] & net_1968);
  assign net_1968 = ~(net_50 | net_6);
  assign net_1965 = (iq_instr_dec1_ne_i[24] & net_1969);
  assign net_1969 = ~(net_5 | net_2167);
  assign net_1963 = (net_1970 | net_1971);
  assign net_1971 = ~(net_1029 & net_1972);
  assign net_1972 = ~(net_1973 | net_1974);
  assign net_1974 = ~(net_1975 & net_1976);
  assign net_1976 = ~(net_688 & net_2164);
  assign net_688 = ~(net_31 | net_45);
  assign net_1975 = ~(net_17 & net_499);
  assign net_1973 = (net_1977 | net_725);
  assign net_725 = (net_2169 & net_1978);
  assign net_1978 = (net_1059 | net_650);
  assign net_650 = ~(net_11 | iq_instr_dec1_ne_i[8]);
  assign net_1059 = (net_63 & net_13);
  assign net_1977 = (net_2167 & net_1979);
  assign net_1979 = ~(net_5 | net_55);
  assign net_1029 = (net_1451 & net_1442);
  assign net_1442 = (iq_instr_dec1_ne_i[8] | net_1980);
  assign net_1980 = ~(net_1450 & net_1590);
  assign net_1451 = ~(net_2164 & net_845);
  assign net_845 = ~(net_1981 | net_44);
  assign net_1970 = (net_730 | net_1982);
  assign net_1982 = (net_1983 | net_956);
  assign net_956 = (net_603 & net_460);
  assign net_460 = (net_2166 & net_60);
  assign net_1983 = (net_273 & net_1984);
  assign net_1984 = (net_1985 & net_1986);
  assign net_1986 = ~(net_63 & net_54);
  assign net_1087 = ~(iq_instr_dec1_ne_i[19] | iq_instr_dec1_ne_i[7]);
  assign net_1985 = ~(net_24 | net_2166);
  assign net_730 = (net_233 & net_1298);
  assign net_1298 = (net_60 & iq_instr_dec1_ne_i[7]);
  assign net_1446 = (net_1297 & net_502);
  assign net_502 = ~(net_57 | iq_instr_dec1_ne_i[16]);
  assign net_1297 = (net_590 & net_331);
  assign net_1923 = (net_1987 | net_1988);
  assign net_1988 = (net_1989 | net_1990);
  assign net_1990 = (net_388 | net_1991);
  assign net_1991 = ~(net_1992 & net_1993);
  assign net_1993 = (net_28 | iq_instr_dec1_ne_i[23]);
  assign net_1992 = ~(net_41 & net_1756);
  assign net_1756 = ~(net_1398 & net_581);
  assign net_581 = ~(net_2167 & net_1273);
  assign net_1398 = ~(iq_instr_dec1_ne_i[21] & net_947);
  assign net_388 = (net_1994 | net_1995);
  assign net_1995 = (net_1996 | net_849);
  assign net_849 = ~(net_1033 & net_1028);
  assign net_1028 = (iq_instr_dec1_ne_i[9] | net_452);
  assign net_1033 = (net_1119 | net_68);
  assign net_1164 = ~(net_2165 | iq_instr_dec1_ne_i[8]);
  assign net_1119 = (net_31 | net_44);
  assign net_1996 = (net_1997 & net_63);
  assign net_1997 = (net_1998 | net_1999);
  assign net_1999 = (net_2000 | net_951);
  assign net_951 = (net_603 & net_2001);
  assign net_2001 = (net_492 & net_72);
  assign net_2000 = (net_1155 & net_13);
  assign net_1155 = (iq_instr_dec1_ne_i[4] & net_1525);
  assign net_1525 = (net_2166 & net_52);
  assign net_1998 = (net_1541 | net_2002);
  assign net_2002 = (net_2003 | net_1186);
  assign net_1186 = ~(net_5 | net_1793);
  assign net_2003 = (net_273 & net_1324);
  assign net_1324 = (iq_instr_dec1_ne_i[6] & net_245);
  assign net_245 = (net_2166 & net_799);
  assign net_799 = ~(iq_instr_dec1_ne_i[16] | net_59);
  assign net_1541 = (net_13 & net_1450);
  assign net_1450 = (net_2169 & net_2166);
  assign net_1994 = (net_1366 | net_2004);
  assign net_2004 = (net_926 | net_2005);
  assign net_2005 = (net_755 | net_982);
  assign net_982 = (net_1202 & net_676);
  assign net_676 = ~(iq_instr_dec1_ne_i[24] | iq_instr_dec1_ne_i[20]);
  assign net_1202 = ~(net_6 | net_75);
  assign net_755 = (imm_sel_neon_dec1_ne[7] | imm_sel_neon_dec1_ne[13]);
  assign imm_sel_neon_dec1_ne[13] = (net_1082 & net_1016);
  assign net_1016 = ~(net_52 | net_49);
  assign net_1793 = ~(iq_instr_dec1_ne_i[21] | iq_instr_dec1_ne_i[7]);
  assign net_480 = ~(iq_instr_dec1_ne_i[20] | iq_instr_dec1_ne_i[19]);
  assign net_1082 = ~(net_75 | net_2006);
  assign imm_sel_neon_dec1_ne[7] = (net_1461 & net_34);
  assign net_926 = (iq_instr_dec1_ne_i[10] & net_2007);
  assign net_2007 = (net_492 & net_1312);
  assign net_1312 = (net_75 & net_1088);
  assign net_1088 = ~(net_2167 | net_36);
  assign net_492 = ~(net_2165 | net_60);
  assign net_1366 = (net_1773 & net_2164);
  assign net_1773 = (iq_instr_dec1_ne_i[28] & net_131);
  assign net_131 = ~(iq_instr_dec1_ne_i[24] | a64_only);
  assign net_1989 = (net_2008 | net_2009);
  assign net_2009 = (net_2010 | net_2011);
  assign net_2011 = (net_2012 | net_2013);
  assign net_2013 = (net_2014 | net_293);
  assign net_293 = (net_1527 & net_2015);
  assign net_2015 = (net_88 & net_2166);
  assign net_88 = ~(net_42 | net_24);
  assign net_1527 = ~(net_13 | net_2167);
  assign net_2014 = (net_41 & net_2016);
  assign net_2016 = (net_2017 | net_2018);
  assign net_2018 = ~(net_1765 & net_2019);
  assign net_2019 = ~(net_13 & net_2020);
  assign net_2020 = ~(net_47 | iq_instr_dec1_ne_i[21]);
  assign net_1765 = (net_817 & net_2021);
  assign net_2021 = (net_1454 | net_684);
  assign net_684 = (net_47 | iq_instr_dec1_ne_i[23]);
  assign net_817 = ~(net_47 & net_233);
  assign net_2017 = ~(net_3 | net_2022);
  assign net_2022 = (net_57 & net_2);
  assign net_1273 = ~(a64_only | net_2168);
  assign net_2012 = (net_2023 | net_123);
  assign net_123 = (net_1094 & net_108);
  assign net_108 = (net_2024 & net_2169);
  assign net_2024 = (iq_instr_dec1_ne_i[6] & net_823);
  assign net_823 = (net_47 & net_74);
  assign net_2023 = (net_2168 & net_2025);
  assign net_2025 = (net_1800 & iq_instr_dec1_ne_i[19]);
  assign net_1800 = ~(net_1172 | net_1905);
  assign net_1905 = (net_6 | net_2166);
  assign net_1172 = ~(net_227 | net_571);
  assign net_571 = ~(net_2165 | iq_instr_dec1_ne_i[11]);
  assign net_2010 = (net_2164 & net_2026);
  assign net_2026 = ~(net_1423 & net_2027);
  assign net_2027 = (net_2028 & net_2029);
  assign net_2029 = (net_418 | iq_instr_dec1_ne_i[16]);
  assign net_2028 = (net_1385 | net_40);
  assign net_1385 = ~(net_947 & net_24);
  assign net_947 = (net_2169 & iq_instr_dec1_ne_i[20]);
  assign net_1423 = (net_452 & net_408);
  assign net_408 = (net_36 | net_9);
  assign net_297 = (net_2169 & net_1013);
  assign net_1013 = ~(net_63 | net_11);
  assign net_689 = ~(net_42 | net_37);
  assign net_452 = ~(a64_only & net_1230);
  assign net_1230 = (iq_instr_dec1_ne_i[27] & net_24);
  assign net_2008 = (iq_instr_dec1_ne_i[20] & net_2030);
  assign net_2030 = ~(net_2031 & net_2032);
  assign net_2032 = (net_2033 & net_2034);
  assign net_2034 = ~(net_195 & net_55);
  assign net_195 = (net_233 & net_1903);
  assign net_1903 = ~(net_2165 | net_61);
  assign net_2033 = (net_2035 & net_2036);
  assign net_2036 = ~(net_1457 | net_2037);
  assign net_2037 = ~(net_398 & net_2038);
  assign net_2038 = (net_1768 | net_919);
  assign net_919 = (net_1820 & net_360);
  assign net_360 = (net_72 | net_14);
  assign net_1820 = ~(net_14 & iq_instr_dec1_ne_i[18]);
  assign net_1768 = ~(iq_instr_dec1_ne_i[8] & net_2039);
  assign net_2039 = (net_634 & net_59);
  assign net_398 = ~(net_634 & net_55);
  assign net_1457 = (net_401 & net_1382);
  assign net_1382 = (net_59 & net_57);
  assign net_2035 = (net_28 & net_2040);
  assign net_2040 = (net_1772 | net_2041);
  assign net_2041 = ~(net_922 & net_1816);
  assign net_922 = ~(net_2169 | iq_instr_dec1_ne_i[4]);
  assign net_1772 = (net_2164 | net_2168);
  assign net_1785 = ~(net_37 | net_29);
  assign net_1094 = (net_122 & net_557);
  assign net_2031 = (net_12 & net_2042);
  assign net_2042 = (net_356 | net_913);
  assign net_913 = ~(iq_instr_dec1_ne_i[19] & net_1816);
  assign net_1816 = (net_24 & iq_instr_dec1_ne_i[25]);
  assign net_356 = (net_40 | iq_instr_dec1_ne_i[8]);
  assign net_906 = (net_401 & net_2043);
  assign net_2043 = (iq_instr_dec1_ne_i[18] & net_652);
  assign net_652 = (iq_instr_dec1_ne_i[17] & net_402);
  assign net_402 = (net_60 | net_72);
  assign net_401 = (net_1347 & net_273);
  assign net_1987 = (net_2044 | net_2045);
  assign net_2045 = (net_2046 | net_2047);
  assign net_2047 = ~(net_2048 | net_2049);
  assign net_2049 = ~(net_1357 & net_2050);
  assign net_2050 = ~(net_24 | net_2165);
  assign net_2048 = (net_246 & net_2051);
  assign net_2051 = ~(net_72 & net_1068);
  assign net_1068 = ~(net_2166 | iq_instr_dec1_ne_i[11]);
  assign net_246 = ~(net_599 & net_63);
  assign net_599 = ~(net_59 | net_60);
  assign net_2046 = (net_227 & net_1449);
  assign net_1449 = (net_603 & net_499);
  assign net_499 = ~(net_60 | iq_instr_dec1_ne_i[17]);
  assign net_227 = ~(net_2164 | iq_instr_dec1_ne_i[9]);
  assign net_2044 = (net_512 | net_2052);
  assign net_2052 = ~(net_1432 & net_2053);
  assign net_2053 = ~(imm_sel_neon_dec1_ne[3] | net_563);
  assign net_563 = (iq_instr_dec1_ne_i[16] & net_2054);
  assign net_2054 = ~(net_418 | net_64);
  assign net_1012 = (net_2166 & iq_instr_dec1_ne_i[8]);
  assign imm_sel_neon_dec1_ne[3] = (iq_instr_dec1_ne_i[20] & net_2055);
  assign net_2055 = (net_634 & net_73);
  assign net_634 = ~(net_40 | net_8);
  assign net_1432 = ~(net_17 & net_794);
  assign net_794 = ~(net_59 | iq_instr_dec1_ne_i[10]);
  assign net_418 = (iq_instr_dec1_ne_i[4] | net_575);
  assign net_575 = ~(iq_instr_dec1_ne_i[28] & net_331);
  assign net_512 = (net_463 & net_1489);
  assign net_1489 = ~(net_2168 | net_2166);
  assign net_463 = ~(net_2169 | net_31);
  assign net_348 = ~(net_32 | net_62);
  assign fmac_valid_sp_dec1_ne = ~(net_2056 & net_1014);
  assign net_1014 = ~(net_964 & net_1851);
  assign net_964 = ~(net_44 | net_22);
  assign net_1421 = (net_24 & net_280);
  assign net_280 = ~(net_63 | net_75);
  assign net_2056 = (net_507 & net_2057);
  assign net_2057 = ~(net_1103 | net_1009);
  assign net_1009 = ~(net_2058 & net_1142);
  assign net_1142 = ~(net_2059 & net_2167);
  assign net_2059 = ~(net_2168 | net_8);
  assign net_2058 = ~(net_1739 & net_1461);
  assign net_1461 = (net_24 & net_590);
  assign net_590 = (iq_instr_dec1_ne_i[27] & net_75);
  assign net_1739 = ~(iq_instr_dec1_ne_i[24] | iq_instr_dec1_ne_i[21]);
  assign net_1103 = ~(net_2164 | net_1866);
  assign net_1866 = ~(net_1590 & net_2060);
  assign net_2060 = ~(net_44 | net_1851);
  assign net_1851 = ~(iq_instr_dec1_ne_i[9] & net_1369);
  assign net_1369 = ~(net_2170 | iq_instr_dec1_ne_i[20]);
  assign net_1590 = ~(net_75 | iq_instr_dec1_ne_i[28]);
  assign net_507 = ~(rf_rd_ctl_fr2_dec1_ne[18] | net_2061);
  assign net_2061 = ~(iq_instr_dec1_ne_i[24] | net_2062);
  assign net_2062 = ~(iq_instr_dec1_ne_i[23] & net_340);
  assign rf_rd_ctl_fr2_dec1_ne[18] = (net_340 & net_1681);
  assign net_1681 = ~(net_2169 | iq_instr_dec1_ne_i[21]);
  assign net_340 = ~(net_13 | net_1939);
  assign net_1939 = ~(iq_instr_dec1_ne_i[27] & net_1606);
  assign net_1606 = ~(net_32 | net_37);
  assign dp_data_b_sel_dec1_ne[1] = ~(net_2063 & net_2064);
  assign net_2064 = ~(imm_sel_neon_dec1_ne[14] | net_2065);
  assign ctl_64bit_op_dec1_ne = ~(net_805 & net_2066);
  assign net_2066 = (net_2164 | net_2067);
  assign net_2067 = (net_2068 | iq_instr_dec1_ne_i[25]);
  assign net_2068 = (net_1776 & net_1703);
  assign net_1703 = ~(net_1947 & iq_instr_dec1_ne_i[27]);
  assign net_1776 = (net_19 & net_2069);
  assign net_2069 = ~(net_626 & net_43);
  assign net_805 = (net_2070 & net_2071);
  assign net_2071 = (net_14 | net_2072);
  assign dcu_valid_dec1_ne = ~(net_2073 & net_1317);
  assign net_2073 = ~(neon_lsm_aligntype_dec1_ne[2] | net_2074);
  assign net_2074 = (net_1719 & net_1533);
  assign neon_lsm_aligntype_dec1_ne[2] = ~(net_2075 & net_809);
  assign net_2075 = ~(net_378 | net_2076);
  assign net_2076 = ~(net_2077 & net_1624);
  assign net_1624 = (net_1574 & net_1636);
  assign net_1636 = (net_2078 & net_91);
  assign net_2078 = (net_2079 & net_2080);
  assign net_2080 = (iq_instr_dec1_ne_i[27] | net_331);
  assign net_2079 = (net_749 & net_1688);
  assign net_1688 = (net_820 & net_2081);
  assign net_2081 = ~(net_2082 & net_43);
  assign net_2077 = (net_1682 & net_1321);
  assign net_1682 = (net_382 & net_1640);
  assign alu_valid_dec1_ne = (rf_wr_ctl_w1_dec1_ne[1] | psr_wr_en_dec1_ne[3]);
  assign psr_wr_en_dec1_ne[3] = (instr_fmstat_dec1_ne | ex2_ctl_flag_set_dec1_ne[0]);
  assign ex2_ctl_flag_set_dec1_ne[0] = (imm_sel_neon_dec1_ne[19] | net_2083);
  assign net_2083 = (aarch64_state_i & net_1051);
  assign net_1051 = (net_1346 & net_620);
  assign net_620 = ~(net_2167 | net_169);
  assign net_169 = ~(net_1347 & net_603);
  assign net_603 = ~(net_2169 | net_11);
  assign net_273 = (net_13 & net_75);
  assign net_1347 = (iq_instr_dec1_ne_i[6] & net_2084);
  assign net_2084 = (net_55 & net_318);
  assign net_318 = ~(iq_instr_dec1_ne_i[24] | net_2168);
  assign net_1346 = ~(net_57 | iq_instr_dec1_ne_i[17]);
  assign imm_sel_neon_dec1_ne[19] = ~(iq_instr_dec1_ne_i[24] | net_2085);
  assign net_2085 = (iq_instr_dec1_ne_i[23] | net_1981);
  assign net_1981 = (net_32 | net_19);
  assign instr_fmstat_dec1_ne = (net_1357 & net_981);
  assign net_981 = ~(net_47 | net_95);
  assign net_95 = ~(iq_instr_dec1_ne_i[4] & net_1384);
  assign net_1357 = ~(net_2168 | net_6);
  assign net_233 = (net_13 & iq_instr_dec1_ne_i[23]);
  assign rf_wr_ctl_w1_dec1_ne[1] = (net_825 | net_2086);
  assign net_2086 = ~(net_2070 & net_2087);
  assign net_2087 = ~(raw_lsm_immed_dec1_ne[0] | net_2065);
  assign net_2065 = ~(net_809 & net_2088);
  assign net_2088 = (net_2089 | net_2164);
  assign net_2089 = (net_2090 & net_2091);
  assign net_2091 = (net_1779 | net_2169);
  assign net_2090 = (net_2092 & net_2093);
  assign net_2093 = (net_50 | net_126);
  assign net_126 = ~(iq_instr_dec1_ne_i[20] & net_2094);
  assign net_2092 = (net_820 | iq_instr_dec1_ne_i[25]);
  assign raw_lsm_immed_dec1_ne[0] = (imm_sel_neon_dec1_ne[14] & net_2170);
  assign imm_sel_neon_dec1_ne[14] = (set_3_0_as_r13_i & net_1646);
  assign net_1646 = ~(net_2165 | net_1781);
  assign net_2070 = (net_2063 & net_2095);
  assign net_2095 = (net_2170 | net_2072);
  assign net_2072 = (net_2164 | net_2096);
  assign net_2063 = (net_2097 & net_2098);
  assign net_2098 = ~(net_30 & net_122);
  assign net_122 = (net_42 & iq_instr_dec1_ne_i[8]);
  assign net_2097 = (net_2168 | net_1738);
  assign net_1738 = ~(net_100 | net_129);
  assign net_825 = (iq_instr_dec1_ne_i[9] & net_2099);
  assign net_2099 = ~(set_3_0_as_r13_i | net_2096);
  assign net_2096 = (set_3_0_i | net_1781);
  assign net_1781 = ~(net_2094 & net_32);
  assign agu_sub_b_dec1_ne = (iq_instr_dec1_ne_i[24] & net_2100);
  assign net_2100 = (net_2094 & net_24);
  assign agu_shf_value_dec1_ne[2] = (iq_instr_dec1_ne_i[6] & net_2101);
  assign agu_shf_value_dec1_ne[1] = (net_2101 & iq_instr_dec1_ne_i[5]);
  assign agu_shf_value_dec1_ne[0] = ~(iq_instr_dec1_ne_i[11] | net_1149);
  assign net_1149 = ~(net_557 & net_42);
  assign net_557 = ~(net_32 | net_75);
  assign agu_data_b_sel_dec1_ne[5] = (iq_instr_dec1_ne_i[9] & net_2102);
  assign net_2102 = (a64_only & net_1735);
  assign agu_data_b_sel_dec1_ne[4] = (iq_instr_dec1_ne_i[7] & net_2101);
  assign agu_data_b_sel_dec1_ne[1] = (net_2103 | net_2104);
  assign net_2104 = ~(net_2105 & net_2106);
  assign net_2106 = (iq_instr_dec1_ne_i[27] | net_2107);
  assign net_2107 = (net_2108 & net_2109);
  assign net_2109 = ~(iq_instr_dec1_ne_i[24] & net_2169);
  assign net_2108 = (iq_instr_dec1_ne_i[21] | net_331);
  assign net_2105 = (net_2110 & net_375);
  assign net_375 = (net_749 & net_629);
  assign net_629 = (net_2111 | iq_instr_dec1_ne_i[24]);
  assign net_2110 = (net_2112 & net_2113);
  assign net_2113 = ~(net_417 & net_37);
  assign net_417 = ~(net_63 | net_2166);
  assign net_2112 = (net_995 & net_2114);
  assign net_2114 = ~(imm_sel_neon_dec1_ne[18] | net_2115);
  assign net_2115 = ~(net_2116 & net_1321);
  assign net_2116 = (net_1777 & net_91);
  assign net_1777 = (net_63 | net_2117);
  assign net_995 = (net_624 & net_1647);
  assign net_1647 = (net_1454 | net_1633);
  assign net_2103 = (net_2164 & net_2118);
  assign net_2118 = ~(net_820 & net_1003);
  assign net_1003 = (net_606 | net_1779);
  assign net_1779 = ~(iq_instr_dec1_ne_i[27] & net_2082);
  assign net_2082 = ~(net_50 | iq_instr_dec1_ne_i[25]);
  assign net_1947 = ~(net_63 | net_2168);
  assign agu_data_b_sel_dec1_ne[0] = (net_994 | net_992);
  assign net_992 = (net_2101 | net_1667);
  assign net_1667 = (net_81 & net_63);
  assign net_81 = (net_2094 & net_42);
  assign net_994 = (iq_instr_dec1_ne_i[21] & net_1735);
  assign agu_data_a_sel_dec1_ne[1] = (imm_sel_neon_dec1_ne[15] | net_2119);
  assign net_2119 = (net_2120 & net_2121);
  assign net_2121 = ~(net_624 & net_2122);
  assign net_2122 = ~(net_1711 & net_20);
  assign net_1454 = ~(net_24 | iq_instr_dec1_ne_i[20]);
  assign imm_sel_neon_dec1_ne[15] = ~(net_749 & net_2111);
  assign net_2111 = (iq_instr_dec1_ne_i[27] | iq_instr_dec1_ne_i[25]);
  assign net_749 = ~(net_331 & net_32);
  assign rf_rd_need_r0_dec1_ne[2] = (net_998 | net_2123);
  assign net_2123 = (net_828 | net_2124);
  assign net_2124 = (net_378 | net_2125);
  assign net_2125 = ~(net_2126 & net_1640);
  assign net_1640 = (net_2168 | net_26);
  assign net_2126 = (net_809 & net_2127);
  assign net_2127 = (net_606 | net_383);
  assign net_383 = ~(iq_instr_dec1_ne_i[21] & net_1717);
  assign net_1717 = ~(iq_instr_dec1_ne_i[25] | net_2128);
  assign net_2128 = ~(iq_instr_dec1_ne_i[26] | net_2129);
  assign net_2129 = (iq_instr_dec1_ne_i[27] & iq_instr_dec1_ne_i[11]);
  assign net_809 = ~(net_266 & net_1532);
  assign net_1532 = (iq_instr_dec1_ne_i[24] & net_1810);
  assign net_1810 = (net_37 & iq_instr_dec1_ne_i[8]);
  assign net_266 = ~(net_24 | net_63);
  assign net_378 = (imm_sel_neon_dec1_ne[18] | net_2101);
  assign net_2101 = (net_63 & net_1735);
  assign imm_sel_neon_dec1_ne[18] = (net_32 & iq_instr_dec1_ne_i[25]);
  assign net_828 = ~(net_382 | net_2120);
  assign net_2120 = (set_19_16_i & net_1);
  assign net_382 = (net_1633 & net_624);
  assign net_624 = ~(net_687 & net_37);
  assign net_687 = ~(iq_instr_dec1_ne_i[8] | a64_only);
  assign net_1633 = ~(iq_instr_dec1_ne_i[8] & net_772);
  assign net_772 = (iq_instr_dec1_ne_i[24] & net_1735);
  assign net_1735 = ~(net_32 | iq_instr_dec1_ne_i[25]);
  assign net_998 = ~(net_2130 & net_820);
  assign net_820 = ~(net_380 & net_43);
  assign net_606 = ~(iq_instr_dec1_ne_i[23] | iq_instr_dec1_ne_i[20]);
  assign net_380 = (net_626 & net_2168);
  assign net_626 = ~(net_24 | iq_instr_dec1_ne_i[26]);
  assign net_2130 = (net_1672 & net_134);
  assign net_134 = ~(net_129 | net_2131);
  assign net_2131 = ~(net_1674 & net_1321);
  assign net_1321 = (net_33 | net_1712);
  assign net_1712 = (net_24 | iq_instr_dec1_ne_i[8]);
  assign net_1533 = ~(iq_instr_dec1_ne_i[26] | net_42);
  assign net_1674 = (net_91 & net_1317);
  assign net_1317 = ~(net_435 & net_2132);
  assign net_2132 = (sf_bit & net_1711);
  assign net_1711 = ~(net_42 | iq_instr_dec1_ne_i[25]);
  assign net_435 = ~(net_2166 | iq_instr_dec1_ne_i[23]);
  assign net_91 = (iq_instr_dec1_ne_i[20] | net_2133);
  assign net_2133 = ~(net_75 & net_34);
  assign net_2006 = ~(net_331 & iq_instr_dec1_ne_i[25]);
  assign net_331 = ~(net_42 | net_2169);
  assign net_129 = ~(iq_instr_dec1_ne_i[23] | iq_instr_dec1_ne_i[27]);
  assign net_1672 = (net_2134 & net_1707);
  assign net_1707 = ~(net_42 & net_100);
  assign net_100 = ~(iq_instr_dec1_ne_i[27] | net_37);
  assign net_2134 = (net_1574 & net_1632);
  assign net_1632 = ~(net_1719 & net_96);
  assign net_1719 = ~(net_2165 | sf_bit);
  assign net_1574 = (net_1730 & net_2117);
  assign net_2117 = ~(net_1384 & net_2094);
  assign net_2094 = ~(iq_instr_dec1_ne_i[23] | iq_instr_dec1_ne_i[25]);
  assign net_1384 = (net_2164 & net_42);
  assign net_1730 = ~(net_96 & net_42);
  assign net_96 = ~(iq_instr_dec1_ne_i[26] | iq_instr_dec1_ne_i[23]);
  assign net_2135 = (net_526 & net_507);
  assign net_2136 = ~(net_303 & net_2135);
  assign net_2137 = (net_293 | net_2136);
  assign net_162 = ~(net_503 | net_2137);
  assign net_2138 = (net_32 & net_947);
  assign net_2139 = (net_1059 | net_103);
  assign net_2140 = (net_1735 & net_2139);
  assign net_2141 = (net_2140 | net_2138);
  assign net_2142 = (iq_instr_dec1_ne_i[11] | net_126);
  assign net_2143 = ~(a64_only & net_81);
  assign net_2144 = ~(net_2142 & net_2143);
  assign net_2145 = (net_1681 & net_37);
  assign net_2146 = ~(iq_instr_dec1_ne_i[28] & net_2145);
  assign net_2147 = ~(net_1730 & net_2146);
  assign net_2148 = ~(net_629 & net_624);
  assign net_2149 = (net_2147 | net_2148);
  assign net_2150 = (net_2144 | net_2149);
  assign net_2151 = (imm_sel_neon_dec1_ne[18] & net_1681);
  assign net_2152 = (net_2151 | net_2150);
  assign ls_length_dec1_ne[0] = (net_2141 | net_2152);
  assign net_2153 = ~(net_66 | net_146);
  assign net_2154 = ~(iq_instr_dec1_ne_i[23] & net_2153);
  assign net_2155 = ~(net_22 | net_2154);
  assign net_2156 = ~(sf_bit | iq_instr_dec1_ne_i[9]);
  assign net_2157 = ~(net_154 & net_155);
  assign net_2158 = (net_2156 & net_2157);
  assign net_2159 = (net_156 | net_2158);
  assign net_2160 = (net_2170 | net_157);
  assign net_2161 = (net_2159 & net_2160);
  assign net_2162 = (net_2155 | net_2161);
  assign select_high_64bits_dec1_ne = (m_bit & net_2162);
  assign net_2163 = (net_378 & net_1580);
  assign net_2164 = ~iq_instr_dec1_ne_i[8];
  assign net_2165 = ~iq_instr_dec1_ne_i[9];
  assign net_2166 = ~iq_instr_dec1_ne_i[10];
  assign net_2167 = ~iq_instr_dec1_ne_i[20];
  assign net_2168 = ~iq_instr_dec1_ne_i[21];
  assign net_2169 = ~iq_instr_dec1_ne_i[23];
  assign net_2170 = ~sf_bit;

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Bundle up the alu_pipectl bus
  // ------------------------------------------------------

  always @* begin
    dp_wr_ctl   = {`CA53_ALU_WR_CTL_W{1'b0}};
    dp_ex2_ctl  = {`CA53_ALU_EX2_CTL_W{1'b0}};
    alu_ex1_ctl = {`CA53_ALU_EX1_CTL_W{1'b0}};
    dp_gen_ctl  = 1'b0;

    dp_ex2_ctl[`CA53_ALU_EX2_CTL_FLAG_ID_BITS]       = ex2_ctl_flag_set_dec1_ne; // alu_flag_set - 2'b10 = CC flag setting
                                                                                 //                2'b00 = not flag setting
    dp_ex2_ctl[`CA53_ALU_EX2_CTL_LU_CTL_BITS]        = ex2_ctl_au_carry_lu_dec1_ne;

    alu_ex1_ctl[`CA53_ALU_EX1_MASK_SEL_BITS]         = ex1_ctl_mask_sel_dec1_ne;

    dp_gen_ctl[`CA53_ALU_CTL_64BIT_OP_BITS]          = ctl_64bit_op_dec1_ne;
  end

  assign alu_pipectl_dec1_ne_o = {dp_wr_ctl,
                                  dp_ex2_ctl,
                                  alu_ex1_ctl,
                                  dp_gen_ctl};

  assign ex_pipe_dec1_ne_o[`CA53_EX_PIPE_ALU_BIT]  = alu_valid_dec1_ne;
  assign ex_pipe_dec1_ne_o[`CA53_EX_PIPE_MAC_BIT]  = 1'b0;
  assign ex_pipe_dec1_ne_o[`CA53_EX_PIPE_BR_BIT]   = 1'b0;
  assign ex_pipe_dec1_ne_o[`CA53_EX_PIPE_DCU_BIT]  = dcu_valid_dec1_ne;
  assign ex_pipe_dec1_ne_o[`CA53_EX_PIPE_DIV_BIT]  = 1'b0;
  assign ex_pipe_dec1_ne_o[`CA53_EX_PIPE_STR_BIT]  = str_valid_dec1_ne;

  //
  // Alignment
  //
  always @*
    case (neon_lsm_aligntype_dec1_ne)
      ALIGN_TYPE_DEFAULT: begin
        algn_size_dec1_ne_o        = {3{1'b0}};
        req_strict_algn_dec1_ne_o  = 1'b0;
      end

      ALIGN_TYPE_MUL:
        case (iq_instr_dec1_ne_i[5:4])
          2'b00: begin // Default alignment
            algn_size_dec1_ne_o        = neon_elem_size_dec1_ne;
            req_strict_algn_dec1_ne_o  = 1'b0;
          end

          2'b01: begin // 64-bit alignment
            algn_size_dec1_ne_o        = `CA53_ALIGN_64BIT;
            req_strict_algn_dec1_ne_o  = 1'b1;
          end

          2'b10: begin // 128-bit alignment
            algn_size_dec1_ne_o        = `CA53_ALIGN_128BIT;
            req_strict_algn_dec1_ne_o  = 1'b1;
          end

          2'b11: begin // 256-bit alignment
            algn_size_dec1_ne_o        = `CA53_ALIGN_256BIT;
            req_strict_algn_dec1_ne_o  = 1'b1;
          end

          default: begin
            algn_size_dec1_ne_o        = {3{1'bx}};
            req_strict_algn_dec1_ne_o  = 1'bx;
          end
        endcase

      ALIGN_TYPE_VLD1_SGL:
        case ({neon_elem_size_dec1_ne[1:0], iq_instr_dec1_ne_i[4]})
          3'b00_0,
          3'b00_1,
          3'b01_0,
          3'b10_0,
          3'b11_0: begin // Default alignment
            algn_size_dec1_ne_o        = neon_elem_size_dec1_ne;
            req_strict_algn_dec1_ne_o  = 1'b0;
          end

          3'b01_1: begin // 16-bit alignment
            algn_size_dec1_ne_o        = `CA53_ALIGN_16BIT;
            req_strict_algn_dec1_ne_o  = 1'b1;
          end

          3'b10_1: begin // 32-bit alignment
            algn_size_dec1_ne_o        = `CA53_ALIGN_32BIT;
            req_strict_algn_dec1_ne_o  = 1'b1;
          end

          default: begin
            algn_size_dec1_ne_o        = {3{1'bx}};
            req_strict_algn_dec1_ne_o  = 1'bx;
          end
        endcase

      ALIGN_TYPE_VLD2_SGL:
        case ({neon_elem_size_dec1_ne[1:0], iq_instr_dec1_ne_i[4]})
          3'b00_0,
          3'b01_0,
          3'b10_0,
          3'b11_0: begin // Default alignment
            algn_size_dec1_ne_o        = neon_elem_size_dec1_ne;
            req_strict_algn_dec1_ne_o  = 1'b0;
          end

          3'b00_1: begin // 16-bit alignment
            algn_size_dec1_ne_o        = `CA53_ALIGN_16BIT;
            req_strict_algn_dec1_ne_o  = 1'b1;
          end

          3'b01_1: begin // 32-bit alignment
            algn_size_dec1_ne_o        = `CA53_ALIGN_32BIT;
            req_strict_algn_dec1_ne_o  = 1'b1;
          end

          3'b10_1: begin // 64-bit alignment
            algn_size_dec1_ne_o        = `CA53_ALIGN_64BIT;
            req_strict_algn_dec1_ne_o  = 1'b1;
          end

          default: begin
            algn_size_dec1_ne_o        = {3{1'bx}};
            req_strict_algn_dec1_ne_o  = 1'bx;
          end
        endcase

      ALIGN_TYPE_VLD4_SGL_ONE:
        case (neon_elem_size_dec1_ne[1:0])
          2'b00: // VLD4.8
            case (iq_instr_dec1_ne_i[4])
              1'b0: begin // Default alignment
                algn_size_dec1_ne_o        = `CA53_ALIGN_NONE;
                req_strict_algn_dec1_ne_o  = 1'b0;
              end

              1'b1: begin // 32-bit alignment
                algn_size_dec1_ne_o        = `CA53_ALIGN_32BIT;
                req_strict_algn_dec1_ne_o  = 1'b1;
              end

              default: begin
                algn_size_dec1_ne_o        = {3{1'bx}};
                req_strict_algn_dec1_ne_o  = 1'bx;
              end
            endcase

          2'b01:
            case (iq_instr_dec1_ne_i[4])
              1'b0: begin // Default alignment
                algn_size_dec1_ne_o        = `CA53_ALIGN_16BIT;
                req_strict_algn_dec1_ne_o  = 1'b0;
              end

              1'b1: begin // 64-bit alignment
                algn_size_dec1_ne_o        = `CA53_ALIGN_64BIT;
                req_strict_algn_dec1_ne_o  = 1'b1;
              end

              default: begin
                algn_size_dec1_ne_o        = {3{1'bx}};
                req_strict_algn_dec1_ne_o  = 1'bx;
              end
            endcase

          2'b10:
            case (iq_instr_dec1_ne_i[5:4] & {2{~aarch64_state_i}})
              2'b00: begin // Default alignment
                algn_size_dec1_ne_o        = `CA53_ALIGN_32BIT;
                req_strict_algn_dec1_ne_o  = 1'b0;
              end

              2'b01: begin // 64-bit alignment
                algn_size_dec1_ne_o        = `CA53_ALIGN_64BIT;
                req_strict_algn_dec1_ne_o  = 1'b1;
              end

              2'b10: begin // 128-bit alignment
                algn_size_dec1_ne_o        = `CA53_ALIGN_128BIT;
                req_strict_algn_dec1_ne_o  = 1'b1;
              end

              default: begin
                algn_size_dec1_ne_o        = {3{1'bx}};
                req_strict_algn_dec1_ne_o  = 1'bx;
              end
            endcase

          2'b11: begin // Default alignment
            algn_size_dec1_ne_o        = `CA53_ALIGN_64BIT;
            req_strict_algn_dec1_ne_o  = 1'b0;
          end

          default: begin
            algn_size_dec1_ne_o        = {3{1'bx}};
            req_strict_algn_dec1_ne_o  = 1'bx;
          end
        endcase

      ALIGN_TYPE_VLD4_SGL_ALL:
        case ({iq_instr_dec1_ne_i[7:6], iq_instr_dec1_ne_i[4]})
          3'b00_0,
          3'b01_0,
          3'b10_0,
          3'b11_0: begin // Default alignment
            algn_size_dec1_ne_o        = {1'b0, iq_instr_dec1_ne_i[7:6]};
            req_strict_algn_dec1_ne_o  = 1'b0;
          end

          3'b00_1: begin // 32-bit alignment
            algn_size_dec1_ne_o        = `CA53_ALIGN_32BIT;
            req_strict_algn_dec1_ne_o  = 1'b1;
          end

          3'b01_1,
          3'b10_1: begin // 64-bit alignment
            algn_size_dec1_ne_o        = `CA53_ALIGN_64BIT;
            req_strict_algn_dec1_ne_o  = 1'b1;
          end

          3'b11_1: begin // 128-bit alignment
            algn_size_dec1_ne_o        = `CA53_ALIGN_128BIT;
            req_strict_algn_dec1_ne_o  = 1'b1;
          end

          default: begin
            algn_size_dec1_ne_o        = {3{1'bx}};
            req_strict_algn_dec1_ne_o  = 1'bx;
          end
        endcase

      ALIGN_TYPE_VFP: begin
        algn_size_dec1_ne_o        = `CA53_ALIGN_32BIT;
        req_strict_algn_dec1_ne_o  = 1'b1;
      end

      ALIGN_TYPE_AARCH64: begin
        algn_size_dec1_ne_o        = neon_elem_size_dec1_ne;
        req_strict_algn_dec1_ne_o  = 1'b0;
      end

      default: begin
        algn_size_dec1_ne_o        = {3{1'bx}};
        req_strict_algn_dec1_ne_o  = 1'bx;
      end
    endcase

  // ------------------------------------------------------
  // Data selection mux adjustment to select the PC or
  // zero register
  // ------------------------------------------------------

  assign dp_data_a_sel_dec1_ne_o  = dp_data_a_sel_dec1_ne;
  assign dp_data_b_sel_dec1_ne_o  = dp_data_b_sel_dec1_ne;
  assign dp_data_c_sel_dec1_ne_o  = dp_data_c_sel_dec1_ne;

  assign agu_data_a_sel_dec1_ne_o = agu_data_a_sel_dec1_ne;

  assign agu_data_b_sel_dec1_ne_o = rf_rd_ctl_r1_dec1_ne[`CA53_RD_CTL_ZR] ? `CA53_SEL_DCU_B_ZERO :
                                                                            agu_data_b_sel_dec1_ne;

  // A store of a pair of D registers or a single Q register can use both store
  // pipes to store 128-bits in a single memory transaction. The decoder
  // indicates this by setting str_data_b_sel to a special value.
  assign str1_sel_dec1_ne = (str_data_b_sel_dec1_ne == `CA53_SEL_STR_B_STR1);
  assign str1_sel_dec1_ne_o = str1_sel_dec1_ne; // Indicate this case to decoder top level for muxing

  assign str_data_a_sel_dec1_ne_o = (str_data_a_sel_dec1_ne == `CA53_SEL_STR_A_R1)   ? (rf_rd_ctl_r1_dec1_ne[`CA53_RD_CTL_ZR]  ? `CA53_SEL_STR_A_ZERO :
                                                                                        rf_rd_ctl_r1_dec1_ne[`CA53_RD_CTL_PC]  ? `CA53_SEL_STR_A_PC   :
                                                                                                                                 `CA53_SEL_STR_A_R1)    :
                                                                                       str_data_a_sel_dec1_ne;

  assign str_data_b_sel_dec1_ne_o = (str_data_b_sel_dec1_ne == `CA53_SEL_STR_B_R2)   ? (rf_rd_ctl_r2_dec1_ne[`CA53_RD_CTL_ZR] ? `CA53_SEL_STR_B_ZERO :
                                                                                        rf_rd_ctl_r2_dec1_ne[`CA53_RD_CTL_PC] ? `CA53_SEL_STR_B_PC   :
                                                                                                                                `CA53_SEL_STR_B_R2)    :
                                    (((str_data_b_sel_dec1_ne == `CA53_SEL_STR_B_A_H) |
                                      str1_sel_dec1_ne) &
                                     (str_data_a_sel_dec1_ne == `CA53_SEL_STR_A_R1)) ? (rf_rd_ctl_r1_dec1_ne[`CA53_RD_CTL_ZR] ? `CA53_SEL_STR_B_ZERO :
                                                                                                                                `CA53_SEL_STR_B_A_H)   :
                                                                                       str_data_b_sel_dec1_ne;

  assign str_b_valid_dec1_ne_o    = (str_data_b_sel_dec1_ne != `CA53_SEL_STR_B_ZERO);

  // Indicate when store pipe used for 64-bit, even if selecting ZR (required to ensure correct forwarding)
  assign ctl_64bit_op_str_dec1_ne_o = (str_data_b_sel_dec1_ne == `CA53_SEL_STR_B_A_H)  |
                                      str1_sel_dec1_ne;

  // Second store pipe control signals come from FR1
  assign str1_data_a_sel_dec1_ne_o = `CA53_SEL_STR_A_FR1;
  assign str1_data_b_sel_dec1_ne_o = `CA53_SEL_STR_B_A_H;

  // ------------------------------------------------------
  // Register file address and enable generation
  // ------------------------------------------------------

  // Integer read enables
  assign rf_rd_en_r0_dec1_ne_o = rf_rd_ctl_r0_dec1_ne[`CA53_RD_CTL_EN];
  assign rf_rd_en_r1_dec1_ne_o = rf_rd_ctl_r1_dec1_ne[`CA53_RD_CTL_EN];
  assign rf_rd_en_r2_dec1_ne_o = rf_rd_ctl_r2_dec1_ne[`CA53_RD_CTL_EN];

  assign rf_rd_need_r0_dec1_ne_o = rf_rd_need_r0_dec1_ne;
  assign rf_rd_need_r1_dec1_ne_o = rf_rd_need_r1_dec1_ne;

  // Integer write addresses and enable
  assign rf_wr_vaddr_w0_dec1_ne_o = ({5{rf_wr_ctl_w0_dec1_ne[`CA53_WR_CTL_19_16]}} & {iq_instr_dec1_ne_i[30] & aarch64_state_i, iq_instr_dec1_ne_i[19:16]});
  assign rf_wr_vaddr_w1_dec1_ne_o = ({5{rf_wr_ctl_w1_dec1_ne[`CA53_WR_CTL_19_16]}} & {iq_instr_dec1_ne_i[30] & aarch64_state_i, iq_instr_dec1_ne_i[19:16]}) |
                                    ({5{rf_wr_ctl_w1_dec1_ne[`CA53_WR_CTL_15_12]}} & {iq_instr_dec1_ne_i[29] & aarch64_state_i, iq_instr_dec1_ne_i[15:12]});

  assign rf_wr_en_w0_dec1_ne_o = rf_wr_ctl_w0_dec1_ne[`CA53_WR_CTL_EN];
  assign rf_wr_en_w1_dec1_ne_o = rf_wr_ctl_w1_dec1_ne[`CA53_WR_CTL_EN];

  assign rf_wr_64b_w1_dec1_ne_o = rf_wr_64b_w1_dec1_ne;

  assign rf_wr_src_w0_dec1_ne_o = rf_wr_src_w0_dec1_ne;
  assign rf_wr_src_w1_dec1_ne_o = rf_wr_src_w1_dec1_ne;

  assign rf_wr_when_w0_dec1_ne_o = rf_wr_when_w0_dec1_ne;
  assign rf_wr_when_w1_dec1_ne_o = rf_wr_when_w1_dec1_ne;

  function [7:0] read_decode_regnum;
    input [NEON_REG_CTL_W-1:0]  ctl;
    input [32:0]                iq_instr_dec1_ne_i;
    input                       aarch64;
    input                       select_high_64bits;
    input [ 4:0]                sm_p1;
    input [ 6:0]                lsm_rn;

    reg [4:0] regnum32;
    reg [1:0] en32;

    reg [5:0] regnum64;
    reg [1:0] en64;

    begin
      // AArch32
      regnum32 =
           ({5{ctl[ 6]}} & {iq_instr_dec1_ne_i[5],  iq_instr_dec1_ne_i[3:0]  })             | // [QD]m
           ({5{ctl[ 7]}} & {iq_instr_dec1_ne_i[7],  iq_instr_dec1_ne_i[19:16]})             | // [QD]n
           ({5{ctl[ 8]}} & {iq_instr_dec1_ne_i[22], iq_instr_dec1_ne_i[15:12]})             | // [QD]d
           ({5{ctl[10]}} & {iq_instr_dec1_ne_i[5] & ctl[1], iq_instr_dec1_ne_i[3] & ctl[5],
                            iq_instr_dec1_ne_i[2:0]})                                   | // Dm[x]
           ({5{ctl[20]}} & {iq_instr_dec1_ne_i[7],  iq_instr_dec1_ne_i[19:16]})             | // Dn[x]
           ({5{ctl[15]}} & {1'b0, iq_instr_dec1_ne_i[ 3: 0]})                           | // Sm
           ({5{ctl[16]}} & {1'b0, iq_instr_dec1_ne_i[19:16]})                           | // Sn
           ({5{ctl[17]}} & {1'b0, iq_instr_dec1_ne_i[15:12]})                           | // Sd
           ({5{ctl[19]}} & {1'b0, sm_p1[4:1]})                                      | // Sm+1
           ({5{ctl[11]}} & lsm_rn[5:1])                                             |
                           {4'b0000, ctl[2]};

      en32 =
                           ctl[1:0]                                   |
           ({2{ctl[15] | 
               ctl[10]}} & {iq_instr_dec1_ne_i[5], ~iq_instr_dec1_ne_i[5]})   |
           ({2{ctl[16]}} & {iq_instr_dec1_ne_i[7], ~iq_instr_dec1_ne_i[7]})   |
           ({2{ctl[17]}} & {iq_instr_dec1_ne_i[22], ~iq_instr_dec1_ne_i[22]}) |
           ({2{ctl[19]}} & {sm_p1[0], ~sm_p1[0]})                     |
           ({2{ctl[11]}} & {lsm_rn[0], ~lsm_rn[0]});

      // AArch64
      regnum64 = ({6{ctl[6] | ctl[15]}} & {iq_instr_dec1_ne_i[ 0], iq_instr_dec1_ne_i[ 5], iq_instr_dec1_ne_i[ 3: 1], 1'b0})                            |
                 ({6{ctl[7] | ctl[16]}} & {iq_instr_dec1_ne_i[16], iq_instr_dec1_ne_i[ 7], iq_instr_dec1_ne_i[19:17], 1'b0})                            |
                 ({6{ctl[8] | ctl[17]}} & {iq_instr_dec1_ne_i[12], iq_instr_dec1_ne_i[22], iq_instr_dec1_ne_i[15:13], 1'b0})                            |
                 ({6{ctl[9] | ctl[18]}} & {iq_instr_dec1_ne_i[ 8], iq_instr_dec1_ne_i[29], iq_instr_dec1_ne_i[11: 9], 1'b0})                            |
                 ({6{ctl[20]}}          & {iq_instr_dec1_ne_i[16],          iq_instr_dec1_ne_i[ 7], iq_instr_dec1_ne_i[19:17], iq_instr_dec1_ne_i[31]}) |
                 ({6{ctl[10]}}          & {iq_instr_dec1_ne_i[ 0] & ctl[5], iq_instr_dec1_ne_i[ 5], iq_instr_dec1_ne_i[ 3: 1], iq_instr_dec1_ne_i[30]}) |
                 ({6{ctl[11]}}          & lsm_rn[6:1])                                                              |
                                           {5'b00000, ctl[2] | (~ctl[4] & ~ctl[10] & select_high_64bits)};

      en64     =                          ctl[1:0]                                   |
                 ({2{ ctl[10]}}         & {iq_instr_dec1_ne_i[29], ~iq_instr_dec1_ne_i[29]}) |
                 ({2{|ctl[18:15]}}      & 2'b01)                                     |
                 ({2{ ctl[11]}}         & {lsm_rn[0], ~lsm_rn[0]});

      read_decode_regnum = aarch64 ? {      regnum64, en64}
                                   : {1'b0, regnum32, en32};
    end
  endfunction

  assign sm_plus1 = {iq_instr_dec1_ne_i[ 3: 0], iq_instr_dec1_ne_i[5]} + 1'b1;

  // Read addresses and enable
  assign {rf_rd_addr_fr0_dec1_ne_o, rf_rd_en_fr0_dec1_ne_o} = read_decode_regnum(rf_rd_ctl_fr0_dec1_ne, iq_instr_dec1_ne_i, aarch64_state_i, select_high_64bits_dec1_ne, sm_plus1, 6'b00_0000);
  assign {rf_rd_addr_fr1_dec1_ne_o, rf_rd_en_fr1_dec1_ne_o} = read_decode_regnum(rf_rd_ctl_fr1_dec1_ne, iq_instr_dec1_ne_i, aarch64_state_i, select_high_64bits_dec1_ne, sm_plus1, 6'b00_0000);
  assign {rf_rd_addr_fr2_dec1_ne_o, rf_rd_en_fr2_dec1_ne_o} = read_decode_regnum(rf_rd_ctl_fr2_dec1_ne, iq_instr_dec1_ne_i, aarch64_state_i, select_high_64bits_dec1_ne, sm_plus1, 6'b00_0000);

  assign rf_rd_need_fr0_dec1_ne_o = rf_rd_need_fr0_dec1_ne;
  assign rf_rd_need_fr1_dec1_ne_o = rf_rd_need_fr1_dec1_ne;
  assign rf_rd_need_fr2_dec1_ne_o = rf_rd_need_fr2_dec1_ne;

  // Write addresses and enable
  // AArch32
  assign rf_wr_addr_fw0_aa32 = // Single precision
                               ({5{rf_wr_ctl_fw0_dec1_ne[15]}} & {1'b0, iq_instr_dec1_ne_i[ 3: 0]})               | // Sm
                               ({5{rf_wr_ctl_fw0_dec1_ne[16]}} & {1'b0, iq_instr_dec1_ne_i[19:16]})               | // Sn
                               ({5{rf_wr_ctl_fw0_dec1_ne[17]}} & {1'b0, iq_instr_dec1_ne_i[15:12]})               | // Sd
                               // Double precision
                               ({5{rf_wr_ctl_fw0_dec1_ne[ 6]}} & {iq_instr_dec1_ne_i[ 5], iq_instr_dec1_ne_i[ 3: 0]}) | // [QD]m*
                               ({5{rf_wr_ctl_fw0_dec1_ne[ 7]}} & {iq_instr_dec1_ne_i[ 7], iq_instr_dec1_ne_i[19:16]}) | // [QD]n*
                               ({5{rf_wr_ctl_fw0_dec1_ne[ 8]}} & {iq_instr_dec1_ne_i[22], iq_instr_dec1_ne_i[15:12]}) | // [QD]d*
                               ({5{rf_wr_ctl_fw0_dec1_ne[20]}} & {iq_instr_dec1_ne_i[ 7], iq_instr_dec1_ne_i[19:16]}) | // Dn[x]
                               // Upper half of Q register
                               {4'b0000, rf_wr_ctl_fw0_dec1_ne[2]};


  assign raw_rf_wr_en_fw0_aa32[1:0] = rf_wr_ctl_fw0_dec1_ne[1:0]                                                   |
                                      ({2{rf_wr_ctl_fw0_dec1_ne[15]}} & {iq_instr_dec1_ne_i[ 5], ~iq_instr_dec1_ne_i[ 5]}) |
                                      ({2{rf_wr_ctl_fw0_dec1_ne[16]}} & {iq_instr_dec1_ne_i[ 7], ~iq_instr_dec1_ne_i[ 7]}) |
                                      ({2{rf_wr_ctl_fw0_dec1_ne[17]}} & {iq_instr_dec1_ne_i[22], ~iq_instr_dec1_ne_i[22]});
  assign raw_rf_wr_en_fw0_aa32[2]   = rf_wr_ctl_fw0_dec1_ne[3];
  assign raw_rf_wr_en_fw0_aa32[3]   = 1'b0;

  // AArch64
  assign rf_wr_addr_fw0_aa64 = ({6{rf_wr_ctl_fw0_dec1_ne[ 6] |
                                   rf_wr_ctl_fw0_dec1_ne[15]}} & {iq_instr_dec1_ne_i[ 0], iq_instr_dec1_ne_i[ 5], iq_instr_dec1_ne_i[ 3: 1], 1'b0})               | // Vm*
                               ({6{rf_wr_ctl_fw0_dec1_ne[ 7] |
                                   rf_wr_ctl_fw0_dec1_ne[16]}} & {iq_instr_dec1_ne_i[16], iq_instr_dec1_ne_i[ 7], iq_instr_dec1_ne_i[19:17], 1'b0})               | // Vn*
                               ({6{rf_wr_ctl_fw0_dec1_ne[ 8] |
                                   rf_wr_ctl_fw0_dec1_ne[17]}} & {iq_instr_dec1_ne_i[12], iq_instr_dec1_ne_i[22], iq_instr_dec1_ne_i[15:13], 1'b0})               | // Vd*
                               ({6{rf_wr_ctl_fw0_dec1_ne[20]}} & {iq_instr_dec1_ne_i[16], iq_instr_dec1_ne_i[ 7], iq_instr_dec1_ne_i[19:17], iq_instr_dec1_ne_i[31]}) | // Vn[x]
                               // Upper half of Q register
                               {5'b00000, rf_wr_ctl_fw0_dec1_ne[2]} |
                               // Upper half of vector for narrowing operations
                               {5'b00000, ~rf_wr_ctl_fw0_dec1_ne[4] & select_high_64bits_dec1_ne};


  assign raw_rf_wr_en_fw0_aa64[1:0] = rf_wr_ctl_fw0_dec1_ne[1:0] |
                                      ({2{|rf_wr_ctl_fw0_dec1_ne[19:15]}} & 2'b01);
  assign raw_rf_wr_en_fw0_aa64[2]   = rf_wr_ctl_fw0_dec1_ne[3];
  assign raw_rf_wr_en_fw0_aa64[3]   = ((|raw_rf_wr_en_fw0_aa64[1:0]) | (|rf_wr_ctl_fw0_dec1_ne[18:15])) &
                                      ~rf_wr_ctl_fw0_dec1_ne[4] & ~rf_wr_ctl_fw0_dec1_ne[20] & ~select_high_64bits_dec1_ne;

  assign rf_wr_addr_fw0_dec1_ne_o = aarch64_state_i ? rf_wr_addr_fw0_aa64 : {1'b0, rf_wr_addr_fw0_aa32};

  assign raw_rf_wr_en_fw0_dec1_ne = aarch64_state_i ? raw_rf_wr_en_fw0_aa64 : raw_rf_wr_en_fw0_aa32;

  assign rf_wr_src_fw0_dec1_ne_o  = rf_wr_src_fw0_dec1_ne;
  assign rf_wr_when_fw0_dec1_ne_o = rf_wr_when_fw0_dec1_ne;

  // ------------------------------------------------------
  // Immediate generation
  // ------------------------------------------------------

  always @* begin
    imm_data_dec1_ne_o       = {`CA53_IMM_DATA_W{1'b0}};
    imm_shift_dec1_ne_o      = {`CA53_IMM_SHIFT_W{1'b0}};

    case (imm_sel_neon_dec1_ne)
      `CA53_IMM_NEON_0: begin
        // Do nothing
      end

      `CA53_IMM_NEON_32:
        imm_data_dec1_ne_o[5:0]  = 6'd32;

      `CA53_IMM_NEON_64:
        imm_data_dec1_ne_o[6:0]  = 7'd64;

      `CA53_IMM_NEON_LDC_STC: // LDC and STC from ARMv4
        imm_data_dec1_ne_o[9:0] = {iq_instr_dec1_ne_i[7:0], 2'b00};

      `CA53_IMM_NEON_VFP_IMM: // Floating point FCONST instruction
        imm_data_dec1_ne_o[12:0] = {iq_instr_dec1_ne_i[8], 4'b1111, iq_instr_dec1_ne_i[19:16], iq_instr_dec1_ne_i[3:0]}; // abcdefgh

      `CA53_IMM_NEON_VCVT_16: // Floating point/16-bit fixed point conversion
        imm_data_dec1_ne_o[5:0] = ({iq_instr_dec1_ne_i[3:0], iq_instr_dec1_ne_i[5]} == 5'd16) ? 6'd32 : {2'b01, iq_instr_dec1_ne_i[2:0], iq_instr_dec1_ne_i[5]};

      `CA53_IMM_NEON_VCVT_32: // Floating point/32-bit fixed point conversion
        imm_data_dec1_ne_o[4:0] = {iq_instr_dec1_ne_i[3:0], iq_instr_dec1_ne_i[5]};

      `CA53_IMM_NEON_VCVT_64: // Floating point/64-bit fixed point conversion
        imm_data_dec1_ne_o[5:0] = {iq_instr_dec1_ne_i[6], iq_instr_dec1_ne_i[3:0], iq_instr_dec1_ne_i[5]};

      `CA53_IMM_NEON_VEXT: // VEXT
        imm_data_dec1_ne_o[2:0]  = iq_instr_dec1_ne_i[10:8];

      `CA53_IMM_NEON_VDUP_VCVT: // Floating point/32 bit fixed point conversion, VDUP (scalar)
        imm_data_dec1_ne_o[4:0]  = iq_instr_dec1_ne_i[20:16];

      `CA53_IMM_NEON_NEON_VCVT_64: // Floating point/64 bit fixed point conversion
        imm_data_dec1_ne_o[5:0]  = iq_instr_dec1_ne_i[21:16];

      `CA53_IMM_NEON_VSHL: // Neon immediate left shift
        case ({iq_instr_dec1_ne_i[7], iq_instr_dec1_ne_i[21:20]})
          3'b000          : imm_data_dec1_ne_o[7:0] = { {5{1'b0}}, iq_instr_dec1_ne_i[18:16]};
          3'b001          : imm_data_dec1_ne_o[7:0] = { {4{1'b0}}, iq_instr_dec1_ne_i[19:16]};
          `ca53dpu_sel_01x: imm_data_dec1_ne_o[7:0] = { {3{1'b0}}, iq_instr_dec1_ne_i[20:16]};
          `ca53dpu_sel_1xx: imm_data_dec1_ne_o[7:0] = { {2{1'b0}}, iq_instr_dec1_ne_i[21:16]};
          default         : imm_data_dec1_ne_o      = {`CA53_IMM_DATA_W{1'bx}};
        endcase

      `CA53_IMM_NEON_VSHR: // Neon immediate right shift
        case ({iq_instr_dec1_ne_i[7], iq_instr_dec1_ne_i[21:20]})
          3'b000          : imm_data_dec1_ne_o[7:0] = { {5{1'b1}}, iq_instr_dec1_ne_i[18:16]};
          3'b001          : imm_data_dec1_ne_o[7:0] = { {4{1'b1}}, iq_instr_dec1_ne_i[19:16]};
          `ca53dpu_sel_01x: imm_data_dec1_ne_o[7:0] = { {3{1'b1}}, iq_instr_dec1_ne_i[20:16]};
          `ca53dpu_sel_1xx: imm_data_dec1_ne_o[7:0] = { {2{1'b1}}, iq_instr_dec1_ne_i[21:16]};
          default         : imm_data_dec1_ne_o      = {`CA53_IMM_DATA_W{1'bx}};
        endcase

      `CA53_IMM_NEON_VMOV_SCAL: begin // VMOV ARM to scalar
        imm_data_dec1_ne_o[3:0] = ({iq_instr_dec1_ne_i[5], iq_instr_dec1_ne_i[22]} == 2'b00)
                                 ? {iq_instr_dec1_ne_i[21], ~iq_instr_dec1_ne_i[6], 2'b00}
                                 : {iq_instr_dec1_ne_i[21], iq_instr_dec1_ne_i[6:5], iq_instr_dec1_ne_i[22]};
      end

      `CA53_IMM_NEON_NEON_IMM: // Neon modified immediate
        imm_data_dec1_ne_o[12:0] = {iq_instr_dec1_ne_i[5], iq_instr_dec1_ne_i[11:8], iq_instr_dec1_ne_i[28], iq_instr_dec1_ne_i[18:16], iq_instr_dec1_ne_i[3:0]};

      `CA53_IMM_NEON_NEON_LSM: // LSM immediate
        imm_data_dec1_ne_o[6:0] = {raw_lsm_immed_dec1_ne, 3'b000};

      `CA53_IMM_NEON_LDR_LITERAL: // AArch64 load literal
        imm_data_dec1_ne_o       = { {`CA53_IMM_DATA_W-20{iq_instr_dec1_ne_i[29]}}, iq_instr_dec1_ne_i[21:16], iq_instr_dec1_ne_i[11:0], 2'b00};

      `CA53_IMM_NEON_LS_PAIR: // AArch64 load/store pair
        case (neon_elem_size_dec1_ne)
          3'b010: imm_data_dec1_ne_o = { {`CA53_IMM_DATA_W- 8{iq_instr_dec1_ne_i[29]}}, iq_instr_dec1_ne_i[11:6],   2'b00};
          3'b011: imm_data_dec1_ne_o = { {`CA53_IMM_DATA_W- 9{iq_instr_dec1_ne_i[29]}}, iq_instr_dec1_ne_i[11:6],  3'b000};
          3'b100: imm_data_dec1_ne_o = { {`CA53_IMM_DATA_W-10{iq_instr_dec1_ne_i[29]}}, iq_instr_dec1_ne_i[11:6], 4'b0000};
          default: begin
            imm_shift_dec1_ne_o      = {`CA53_IMM_SHIFT_W{1'bx}};
            imm_data_dec1_ne_o       = {`CA53_IMM_DATA_W{1'bx}};
          end
        endcase

      `CA53_IMM_NEON_LS_UNSCALED: // AArch64 load/store unscaled immediate
        imm_data_dec1_ne_o       = { {`CA53_IMM_DATA_W-8{iq_instr_dec1_ne_i[31]}}, iq_instr_dec1_ne_i[7:0]};

      `CA53_IMM_NEON_LS_IMM12: // AArch64 load/store unsigned immedate
        case (neon_elem_size_dec1_ne)
          3'b000: imm_data_dec1_ne_o[11: 0] =  iq_instr_dec1_ne_i[11:0];
          3'b001: imm_data_dec1_ne_o[12: 0] = {iq_instr_dec1_ne_i[11:0], 1'b0};
          3'b010: imm_data_dec1_ne_o[13: 0] = {iq_instr_dec1_ne_i[11:0], 2'b00};
          3'b011: imm_data_dec1_ne_o[14: 0] = {iq_instr_dec1_ne_i[11:0], 3'b000};
          3'b100: imm_data_dec1_ne_o[15: 0] = {iq_instr_dec1_ne_i[11:0], 4'b0000};
          default: begin
            imm_shift_dec1_ne_o      = {`CA53_IMM_SHIFT_W{1'bx}};
            imm_data_dec1_ne_o       = {`CA53_IMM_DATA_W{1'bx}};
          end
        endcase

      `CA53_IMM_NEON_CCMP_CSEL: begin // AArch64 conditional compare/select and AArch32 VSEL
        imm_shift_dec1_ne_o[7:4] = iq_instr_dec1_ne_i[15:12];
        imm_shift_dec1_ne_o[3:0] = aarch64_state_i ? { iq_instr_dec1_ne_i[21:20], iq_instr_dec1_ne_i[31:30] }
                                                   : { iq_instr_dec1_ne_i[21:20], ^iq_instr_dec1_ne_i[21:20], 1'b0 };
      end

      `CA53_IMM_NEON_INS_VECTOR: begin // A64 INS (vector)
        imm_data_dec1_ne_o[6:0]  = {iq_instr_dec1_ne_i[22], iq_instr_dec1_ne_i[8], iq_instr_dec1_ne_i[6], iq_instr_dec1_ne_i[15:12]};
      end

      `CA53_IMM_NEON_VDUP_SCAL: begin // A64 DUP (scalar)
        imm_data_dec1_ne_o[6:0]  = iq_instr_dec1_ne_i[16] ? {iq_instr_dec1_ne_i[19:17], 4'b0001} :
                                   iq_instr_dec1_ne_i[17] ? {iq_instr_dec1_ne_i[19:17], 4'b0010} :
                                   iq_instr_dec1_ne_i[18] ? {iq_instr_dec1_ne_i[19:17], 4'b0100} :
                                                            {iq_instr_dec1_ne_i[19:17], 4'b1000};
      end

      default: begin
        imm_data_dec1_ne_o       = {`CA53_IMM_DATA_W{1'bx}};
        imm_shift_dec1_ne_o      = {`CA53_IMM_SHIFT_W{1'bx}};
      end
    endcase
  end

  // ------------------------------------------------------
  // Output aliasing
  // ------------------------------------------------------

  // Indicate which flags (if any) operation sets. This is encoded
  // differently than for slot 0 instructions, as the PSR pipeline is mostly
  // driven only by slot 0, having the slot 1 signals muxed in at the end.
  assign flag_en_dec1_ne_o = ({`CA53_FLAGEN_INSTR1_W{psr_wr_en_dec1_ne == `CA53_SEL_CPSR_EN_CC}} & `CA53_FLAGEN_INSTR1_CC);

  assign rf_wr_en_fw0_dec1_ne_o       = raw_rf_wr_en_fw0_dec1_ne;
  assign check_x64_dec1_ne_o          = check_x64_dec1_ne;
  assign wd_align_pc_dec1_ne_o        = wd_align_pc_dec1_ne;
  assign ls_store_dec1_ne_o           = ls_store_dec1_ne;
  assign ls_instr_type_dec1_ne_o      = ls_instr_type_dec1_ne;
  assign ls_size_dec1_ne_o            = ls_size_dec1_ne;
  assign ls_elem_size_dec1_ne_o       = neon_elem_size_dec1_ne;
  assign ls_length_dec1_ne_o          = ls_length_dec1_ne[5:0];
  assign agu_shf_value_dec1_ne_o      = agu_shf_value_dec1_ne;
  assign agu_sub_b_dec1_ne_o          = agu_sub_b_dec1_ne;
  assign fmac_valid_sp_dec1_ne_o      = fmac_valid_sp_dec1_ne;
  assign neon_can_fwd_acc_dec1_ne_o   = neon_can_fwd_acc_dec1_ne;
  assign mul_neon_out_fmt_dec1_ne_o   = mul_neon_out_fmt_dec1_ne;
  assign fp_ex_pipe_dec1_ne_o         = fp_ex_pipe_dec1_ne;
  assign instr_fmstat_dec1_ne_o       = instr_fmstat_dec1_ne;

  // Form instruction type
  assign slot1_instr_type_dec1_ne_o   = dcu_valid_dec1_ne ? `CA53_SLOT1_INSTR_TYPE_FP_LS :
                                                            `CA53_SLOT1_INSTR_TYPE_FP;

endmodule // ca53dpu_dec1_neon

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53_dpu_dcu_defs.v"
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
