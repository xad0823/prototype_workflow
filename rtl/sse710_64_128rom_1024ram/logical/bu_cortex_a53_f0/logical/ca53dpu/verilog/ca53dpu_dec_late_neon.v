//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2014 ARM Limited.
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
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract: Decoder for Neon instructions
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"
`include "ca53_dpu_dcu_defs.v"

module ca53dpu_dec_late_neon `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire                      [32:0] iq_instr_fn_i,             // Instruction input
  input  wire                             iq_instr0_fn_pdtype_iss_i,
  input  wire                             aarch64_state_i,
  input  wire                             aes_op_merged_iss_i,
  input  wire                       [2:0] decoder_fsm_i,              // Current FSM state
  input  wire                             exception_valid_iss_i,
  input  wire                       [2:0] mul_neon_out_fmt_iss_i,
  // Outputs
  output wire     [`CA53_SEL_FML_A_W-1:0] sel_fml_a_neon_o,
  output wire     [`CA53_SEL_FML_B_W-1:0] sel_fml_b_neon_o,
  output wire     [`CA53_SEL_FML_C_W-1:0] sel_fml_c_neon_o,
  output wire     [`CA53_SEL_FAD_A_W-1:0] sel_fad_a_neon_o,
  output wire     [`CA53_SEL_FAD_B_W-1:0] sel_fad_b_neon_o,
  output wire     [`CA53_SEL_FAD_C_W-1:0] sel_fad_c_neon_o,
  output reg     [`CA53_FP_PIPECTL_W-1:0] fp_pipectl_neon_o,
  output wire  [`CA53_FP_CFLAG_SRC_W-1:0] fp_cflag_src_neon_o,
  output wire  [`CA53_FP_XFLAG_SRC_W-1:0] fp_xflag_src_neon_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg    [`CA53_FP_MUL_CTL_W-1:0] fp_mul_ctl;
  reg    [`CA53_FP_ADD_CTL_W-1:0] fp_add_ctl;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                            a64_only;
  wire                            sf_bit;
  wire                            vd_eq_vm;
  wire [`CA53_FP_CFLAG_SRC_W-1:0] fp_cflag_src_neon;
  wire [`CA53_FP_XFLAG_SRC_W-1:0] fp_xflag_src_neon;
  wire                      [3:0] add_neon_perm_sel;
  wire                            add_neon_vtb_cycle;
  wire                            add_neon_unsigned_op;
  wire    [`CA53_NEON_FCTN_W-1:0] add_neon_fctn_sel;
  wire                      [2:0] add_neon_width_op_sel;
  wire                      [2:0] add_neon_sat_op_sel;
  wire                            add_neon_vtst_op_sel;
  wire                            add_neon_mask_sel;
  wire                      [1:0] add_neon_size_sel;
  wire                      [3:0] add_neon_lu_ctl;
  wire                      [2:0] add_neon_mux_sel;
  wire                            add_neon_int_sel;
  wire                            add_vector_fp_op;
  wire        [`CA53_FP_OP_W-1:0] add_fp_op;
  wire                            mul_fused_mac;
  wire                            mul_precision;
  wire                            mul_divide;
  wire                            mul_sqrt;
  wire                            mul_negate;
  wire                            mul_vector_op;
  wire                            mul_neon_int_op;
  wire                            mul_neon_inv_is_zero;
  wire                            mul_neon_fixup;
  wire                            mul_neon_sat_dbl;
  wire                            mul_neon_round;
  wire                      [2:0] mul_neon_mul_type;
  wire    [`CA53_CRYPTO_OP_W-1:0] crypto_op;
  wire     [`CA53_FP_RMODE_W-1:0] rounding_mode;
  wire                            force_dn_fz;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  assign a64_only = iq_instr0_fn_pdtype_iss_i & aarch64_state_i;
  assign sf_bit = iq_instr_fn_i[32] & aarch64_state_i;
  assign vd_eq_vm = {iq_instr_fn_i[22], iq_instr_fn_i[15:12]} == {iq_instr_fn_i[5], iq_instr_fn_i[3:0]};

  // ------------------------------------------------------
  // Start automatically generated logic
  // ------------------------------------------------------

  wire   net_1, net_2, net_3, net_4, net_5, net_6, net_7, net_8, net_9, net_10,
         net_11, net_12, net_13, net_14, net_15, net_16, net_17, net_18,
         net_19, net_20, net_21, net_22, net_23, net_24, net_25, net_26,
         net_27, net_28, net_29, net_30, net_31, net_32, net_33, net_34,
         net_35, net_36, net_37, net_38, net_40, net_41, net_42, net_43,
         net_44, net_45, net_46, net_47, net_48, net_49, net_50, net_51,
         net_52, net_53, net_54, net_55, net_56, net_57, net_58, net_59,
         net_60, net_61, net_62, net_63, net_64, net_65, net_66, net_67,
         net_68, net_71, net_72, net_73, net_74, net_75, net_76, net_77,
         net_78, net_79, net_80, net_81, net_82, net_83, net_84, net_85,
         net_86, net_87, net_91, net_92, net_93, net_95, net_98, net_99,
         net_100, net_101, net_102, net_103, net_104, net_105, net_106,
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
         net_233, net_234, net_235, net_236, net_237, net_238, net_239,
         net_240, net_241, net_242, net_243, net_244, net_245, net_246,
         net_247, net_248, net_249, net_250, net_251, net_252, net_253,
         net_254, net_255, net_256, net_257, net_258, net_259, net_260,
         net_261, net_262, net_263, net_264, net_265, net_266, net_267,
         net_268, net_269, net_270, net_271, net_272, net_273, net_274,
         net_275, net_276, net_277, net_278, net_279, net_280, net_281,
         net_282, net_283, net_284, net_285, net_286, net_287, net_288,
         net_289, net_290, net_291, net_292, net_293, net_294, net_295,
         net_296, net_297, net_298, net_299, net_300, net_301, net_302,
         net_303, net_304, net_305, net_306, net_307, net_308, net_309,
         net_310, net_311, net_312, net_313, net_314, net_315, net_316,
         net_317, net_318, net_319, net_320, net_321, net_322, net_323,
         net_324, net_325, net_326, net_327, net_328, net_329, net_330,
         net_331, net_332, net_333, net_334, net_335, net_336, net_337,
         net_338, net_339, net_340, net_341, net_342, net_343, net_344,
         net_345, net_346, net_347, net_348, net_349, net_350, net_351,
         net_352, net_353, net_354, net_355, net_356, net_357, net_358,
         net_359, net_360, net_361, net_362, net_363, net_364, net_365,
         net_366, net_367, net_368, net_369, net_370, net_371, net_372,
         net_373, net_374, net_375, net_376, net_377, net_378, net_379,
         net_380, net_381, net_382, net_383, net_384, net_385, net_386,
         net_387, net_388, net_389, net_390, net_391, net_392, net_393,
         net_394, net_395, net_396, net_397, net_398, net_399, net_400,
         net_401, net_402, net_403, net_404, net_405, net_406, net_407,
         net_408, net_409, net_410, net_411, net_412, net_413, net_414,
         net_415, net_416, net_417, net_418, net_419, net_420, net_421,
         net_422, net_423, net_424, net_425, net_426, net_427, net_428,
         net_429, net_430, net_431, net_432, net_433, net_434, net_435,
         net_436, net_437, net_438, net_439, net_440, net_441, net_442,
         net_443, net_444, net_445, net_446, net_447, net_448, net_449,
         net_450, net_451, net_452, net_453, net_454, net_455, net_456,
         net_457, net_458, net_459, net_460, net_461, net_462, net_463,
         net_464, net_465, net_466, net_467, net_468, net_469, net_470,
         net_471, net_472, net_473, net_474, net_475, net_476, net_477,
         net_478, net_479, net_480, net_481, net_482, net_483, net_484,
         net_485, net_486, net_487, net_488, net_489, net_490, net_491,
         net_492, net_493, net_494, net_495, net_496, net_497, net_498,
         net_499, net_500, net_501, net_502, net_503, net_504, net_505,
         net_506, net_507, net_508, net_509, net_510, net_511, net_512,
         net_513, net_514, net_515, net_516, net_517, net_518, net_519,
         net_520, net_521, net_522, net_523, net_524, net_525, net_526,
         net_527, net_528, net_529, net_530, net_531, net_532, net_533,
         net_534, net_535, net_536, net_537, net_538, net_539, net_540,
         net_541, net_542, net_543, net_544, net_545, net_546, net_547,
         net_548, net_549, net_550, net_551, net_552, net_553, net_554,
         net_555, net_556, net_557, net_558, net_559, net_560, net_561,
         net_562, net_563, net_564, net_565, net_566, net_567, net_568,
         net_569, net_570, net_571, net_572, net_573, net_574, net_575,
         net_576, net_577, net_578, net_579, net_580, net_581, net_582,
         net_583, net_584, net_585, net_586, net_587, net_588, net_589,
         net_590, net_591, net_592, net_593, net_594, net_595, net_596,
         net_597, net_598, net_599, net_600, net_601, net_602, net_603,
         net_604, net_605, net_606, net_607, net_608, net_609, net_610,
         net_611, net_612, net_613, net_614, net_615, net_616, net_617,
         net_618, net_619, net_620, net_621, net_622, net_623, net_624,
         net_625, net_626, net_627, net_628, net_629, net_630, net_631,
         net_632, net_633, net_634, net_635, net_636, net_637, net_638,
         net_639, net_640, net_641, net_642, net_643, net_644, net_645,
         net_646, net_647, net_648, net_649, net_650, net_651, net_652,
         net_653, net_654, net_655, net_656, net_657, net_658, net_659,
         net_660, net_661, net_662, net_663, net_664, net_665, net_666,
         net_667, net_668, net_669, net_670, net_671, net_672, net_673,
         net_674, net_675, net_676, net_677, net_678, net_679, net_680,
         net_681, net_682, net_683, net_684, net_685, net_686, net_687,
         net_688, net_689, net_690, net_691, net_692, net_693, net_694,
         net_695, net_696, net_697, net_698, net_699, net_700, net_701,
         net_702, net_703, net_704, net_705, net_706, net_707, net_708,
         net_709, net_710, net_711, net_712, net_713, net_714, net_715,
         net_716, net_717, net_718, net_719, net_720, net_721, net_722,
         net_723, net_724, net_725, net_726, net_727, net_728, net_729,
         net_730, net_731, net_732, net_733, net_734, net_735, net_736,
         net_737, net_738, net_739, net_740, net_741, net_742, net_743,
         net_744, net_745, net_746, net_747, net_748, net_749, net_750,
         net_751, net_752, net_753, net_754, net_755, net_756, net_757,
         net_758, net_759, net_760, net_761, net_762, net_763, net_764,
         net_765, net_766, net_767, net_768, net_769, net_770, net_771,
         net_772, net_773, net_774, net_775, net_776, net_777, net_778,
         net_779, net_780, net_781, net_782, net_783, net_784, net_785,
         net_786, net_787, net_788, net_789, net_790, net_791, net_792,
         net_793, net_794, net_795, net_796, net_797, net_798, net_799,
         net_800, net_801, net_802, net_803, net_804, net_805, net_806,
         net_807, net_808, net_809, net_810, net_811, net_812, net_813,
         net_814, net_815, net_816, net_817, net_818, net_819, net_820,
         net_821, net_822, net_823, net_824, net_825, net_826, net_827,
         net_828, net_829, net_830, net_831, net_832, net_833, net_834,
         net_835, net_836, net_837, net_838, net_839, net_840, net_841,
         net_842, net_843, net_844, net_845, net_846, net_847, net_848,
         net_849, net_850, net_851, net_852, net_853, net_854, net_855,
         net_856, net_857, net_858, net_859, net_860, net_861, net_862,
         net_863, net_864, net_865, net_866, net_867, net_868, net_869,
         net_870, net_871, net_872, net_873, net_874, net_875, net_876,
         net_877, net_878, net_879, net_880, net_881, net_882, net_883,
         net_884, net_885, net_886, net_887, net_888, net_889, net_890,
         net_891, net_892, net_893, net_894, net_895, net_896, net_897,
         net_898, net_899, net_900, net_901, net_902, net_903, net_904,
         net_905, net_906, net_907, net_908, net_909, net_910, net_911,
         net_912, net_913, net_914, net_915, net_916, net_917, net_918,
         net_919, net_920, net_921, net_922, net_923, net_924, net_925,
         net_926, net_927, net_928, net_929, net_930, net_931, net_932,
         net_933, net_934, net_935, net_936, net_937, net_938, net_939,
         net_940, net_941, net_942, net_943, net_944, net_945, net_946,
         net_947, net_948, net_949, net_950, net_951, net_952, net_953,
         net_954, net_955, net_956, net_957, net_958, net_959, net_960,
         net_961, net_962, net_963, net_964, net_965, net_966, net_967,
         net_968, net_969, net_970, net_971, net_972, net_973, net_974,
         net_975, net_976, net_977, net_978, net_979, net_980, net_981,
         net_982, net_983, net_984, net_985, net_986, net_987, net_988,
         net_989, net_990, net_991, net_992, net_993, net_994, net_995,
         net_996, net_997, net_998, net_999, net_1000, net_1001, net_1002,
         net_1003, net_1004, net_1005, net_1006, net_1007, net_1008, net_1009,
         net_1010, net_1011, net_1012, net_1013, net_1014, net_1015, net_1016,
         net_1017, net_1018, net_1019, net_1020, net_1021, net_1022, net_1023,
         net_1024, net_1025, net_1026, net_1027, net_1028, net_1029, net_1030,
         net_1031, net_1032, net_1033, net_1034, net_1035, net_1036, net_1037,
         net_1038, net_1039, net_1040, net_1041, net_1042, net_1043, net_1044,
         net_1045, net_1046, net_1047, net_1048, net_1049, net_1050, net_1051,
         net_1052, net_1053, net_1054, net_1055, net_1056, net_1057, net_1058,
         net_1059, net_1060, net_1061, net_1062, net_1063, net_1064, net_1065,
         net_1066, net_1067, net_1068, net_1069, net_1070, net_1071, net_1072,
         net_1073, net_1074, net_1075, net_1076, net_1077, net_1078, net_1079,
         net_1080, net_1081, net_1082, net_1083, net_1084, net_1085, net_1086,
         net_1087, net_1088, net_1089, net_1090, net_1091, net_1092, net_1093,
         net_1094, net_1095, net_1096, net_1097, net_1098, net_1099, net_1100,
         net_1101, net_1102, net_1103, net_1104, net_1105, net_1106, net_1107,
         net_1108, net_1109, net_1110, net_1111, net_1112, net_1113, net_1114,
         net_1115, net_1116, net_1117, net_1118, net_1119, net_1120, net_1121,
         net_1122, net_1123, net_1124, net_1125, net_1126, net_1127, net_1128,
         net_1129, net_1130, net_1131, net_1132, net_1133, net_1134, net_1135,
         net_1136, net_1137, net_1138, net_1139, net_1140, net_1141, net_1142,
         net_1143, net_1144, net_1145, net_1146, net_1147, net_1148, net_1149,
         net_1150, net_1151, net_1152, net_1153, net_1154, net_1155, net_1156,
         net_1157, net_1158, net_1159, net_1160, net_1161, net_1162, net_1163,
         net_1164, net_1165, net_1166, net_1167, net_1168, net_1169, net_1170,
         net_1171, net_1172, net_1173, net_1174, net_1175, net_1176, net_1177,
         net_1178, net_1179, net_1180, net_1181, net_1182, net_1183, net_1184,
         net_1185, net_1186, net_1187, net_1188, net_1189, net_1190, net_1191,
         net_1192, net_1193, net_1194, net_1195, net_1196, net_1197, net_1198,
         net_1199, net_1200, net_1201, net_1202, net_1203, net_1204, net_1205,
         net_1206, net_1207, net_1208, net_1209, net_1210, net_1211, net_1212,
         net_1213, net_1214, net_1215, net_1216, net_1217, net_1218, net_1219,
         net_1220, net_1221, net_1222, net_1223, net_1224, net_1225, net_1226,
         net_1227, net_1228, net_1229, net_1230, net_1231, net_1232, net_1233,
         net_1234, net_1235, net_1236, net_1237, net_1238, net_1239, net_1240,
         net_1241, net_1242, net_1243, net_1244, net_1245, net_1246, net_1247,
         net_1248, net_1249, net_1250, net_1251, net_1252, net_1253, net_1254,
         net_1255, net_1256, net_1257, net_1258, net_1259, net_1260, net_1261,
         net_1262, net_1263, net_1264, net_1265, net_1266, net_1267, net_1268,
         net_1269, net_1270, net_1271, net_1272, net_1273, net_1274, net_1275,
         net_1276, net_1277, net_1278, net_1279, net_1280, net_1281, net_1282,
         net_1283, net_1284, net_1285, net_1286, net_1287, net_1288, net_1289,
         net_1290, net_1291, net_1292, net_1293, net_1294, net_1295, net_1296,
         net_1297, net_1298, net_1299, net_1300, net_1301, net_1302, net_1303,
         net_1304, net_1305, net_1306, net_1307, net_1308, net_1309, net_1310,
         net_1311, net_1312, net_1313, net_1314, net_1315, net_1316, net_1317,
         net_1318, net_1319, net_1320, net_1321, net_1322, net_1323, net_1324,
         net_1325, net_1326, net_1327, net_1328, net_1329, net_1330, net_1331,
         net_1332, net_1333, net_1334, net_1335, net_1336, net_1337, net_1338,
         net_1339, net_1340, net_1341, net_1342, net_1343, net_1344, net_1345,
         net_1346, net_1347, net_1348, net_1349, net_1350, net_1351, net_1352,
         net_1353, net_1354, net_1355, net_1356, net_1357, net_1358, net_1359,
         net_1360, net_1361, net_1362, net_1363, net_1364, net_1365, net_1366,
         net_1367, net_1368, net_1369, net_1370, net_1371, net_1372, net_1373,
         net_1374, net_1375, net_1376, net_1377, net_1378, net_1379, net_1380,
         net_1381, net_1382, net_1383, net_1384, net_1385, net_1386, net_1387,
         net_1388, net_1389, net_1390, net_1391, net_1392, net_1393, net_1394,
         net_1395, net_1396, net_1397, net_1398, net_1399, net_1400, net_1401,
         net_1402, net_1403, net_1404, net_1405, net_1406, net_1407, net_1408,
         net_1409, net_1410, net_1411, net_1412, net_1413, net_1414, net_1415,
         net_1416, net_1417, net_1418, net_1419, net_1420, net_1421, net_1422,
         net_1423, net_1424, net_1425, net_1426, net_1427, net_1428, net_1429,
         net_1430, net_1431, net_1432, net_1433, net_1434, net_1435, net_1436,
         net_1437, net_1438, net_1439, net_1440, net_1441, net_1442, net_1443,
         net_1444, net_1445, net_1446, net_1447, net_1448, net_1449, net_1450,
         net_1451, net_1452, net_1453, net_1454, net_1455, net_1456, net_1457,
         net_1458, net_1459, net_1460, net_1461, net_1462, net_1463, net_1464,
         net_1465, net_1466, net_1467, net_1468, net_1469, net_1470, net_1471,
         net_1472, net_1473, net_1474, net_1475, net_1476, net_1477, net_1478,
         net_1479, net_1480, net_1481, net_1482, net_1483, net_1484, net_1485,
         net_1486, net_1487, net_1488, net_1489, net_1490, net_1491, net_1492,
         net_1493, net_1494, net_1495, net_1496, net_1497, net_1498, net_1499,
         net_1500, net_1501, net_1502, net_1503, net_1504, net_1505, net_1506,
         net_1507, net_1508, net_1509, net_1510, net_1511, net_1512, net_1513,
         net_1514, net_1515, net_1516, net_1517, net_1518, net_1519, net_1520,
         net_1521, net_1522, net_1523, net_1524, net_1525, net_1526, net_1527,
         net_1528, net_1529, net_1530, net_1531, net_1532, net_1533, net_1534,
         net_1535, net_1536, net_1537, net_1538, net_1539, net_1540, net_1541,
         net_1542, net_1543, net_1544, net_1545, net_1546, net_1547, net_1548,
         net_1549, net_1550, net_1551, net_1552, net_1553, net_1554, net_1555,
         net_1556, net_1557, net_1558, net_1559, net_1560, net_1561, net_1562,
         net_1563, net_1564, net_1565, net_1566, net_1567, net_1568, net_1569,
         net_1570, net_1571, net_1572, net_1573, net_1574, net_1575, net_1576,
         net_1577, net_1578, net_1579, net_1580, net_1581, net_1582, net_1583,
         net_1584, net_1585, net_1586, net_1587, net_1588, net_1589, net_1590,
         net_1591, net_1592, net_1593, net_1594, net_1595, net_1596, net_1597,
         net_1598, net_1599, net_1600, net_1601, net_1602, net_1603, net_1604,
         net_1605, net_1606, net_1607, net_1608, net_1609, net_1610, net_1611,
         net_1612, net_1613, net_1614, net_1615, net_1616, net_1617, net_1618,
         net_1619, net_1620, net_1621, net_1622, net_1623, net_1624, net_1625,
         net_1626, net_1627, net_1628, net_1629, net_1630, net_1631, net_1632,
         net_1633, net_1634, net_1635, net_1636, net_1637, net_1638, net_1639,
         net_1640, net_1641, net_1642, net_1643, net_1644, net_1645, net_1646,
         net_1647, net_1648, net_1649, net_1650, net_1651, net_1652, net_1653,
         net_1654, net_1655, net_1656, net_1657, net_1658, net_1659, net_1660,
         net_1661, net_1662, net_1663, net_1664, net_1665, net_1666, net_1667,
         net_1668, net_1669, net_1670, net_1671, net_1672, net_1673, net_1674,
         net_1675, net_1676, net_1677, net_1678, net_1679, net_1680, net_1681,
         net_1682, net_1683, net_1684, net_1685, net_1686, net_1687, net_1688,
         net_1689, net_1690, net_1691, net_1692, net_1693, net_1694, net_1695,
         net_1696, net_1697, net_1698, net_1699, net_1700, net_1701, net_1702,
         net_1703, net_1704, net_1705, net_1706, net_1707, net_1708, net_1709,
         net_1710, net_1711, net_1712, net_1713, net_1714, net_1715, net_1716,
         net_1717, net_1718, net_1719, net_1720, net_1721, net_1722, net_1723,
         net_1724, net_1725, net_1726, net_1727, net_1728, net_1729, net_1730,
         net_1731, net_1732, net_1733, net_1734, net_1735, net_1736, net_1737,
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
         net_2165, net_2166, net_2167, net_2168, net_2169, net_2170, net_2171,
         net_2172, net_2173, net_2174, net_2175, net_2176, net_2177, net_2178,
         net_2179, net_2180, net_2181, net_2182, net_2183, net_2184, net_2185,
         net_2186, net_2187, net_2188, net_2189, net_2190, net_2191, net_2192,
         net_2193, net_2194, net_2195, net_2196, net_2197, net_2198, net_2199,
         net_2200, net_2201, net_2202, net_2203, net_2204, net_2205, net_2206,
         net_2207, net_2208, net_2209, net_2210, net_2211, net_2212, net_2213,
         net_2214, net_2215, net_2216, net_2217, net_2218, net_2219, net_2220,
         net_2221, net_2222, net_2223, net_2224, net_2225, net_2226, net_2227,
         net_2228, net_2229, net_2230, net_2231, net_2232, net_2233, net_2234,
         net_2235, net_2236, net_2237, net_2238, net_2239, net_2240, net_2241,
         net_2242, net_2243, net_2244, net_2245, net_2246, net_2247, net_2248,
         net_2249, net_2250, net_2251, net_2252, net_2253, net_2254, net_2255,
         net_2256, net_2257, net_2258, net_2259, net_2260, net_2261, net_2262,
         net_2263, net_2264, net_2265, net_2266, net_2267, net_2268, net_2269,
         net_2270, net_2271, net_2272, net_2273, net_2274, net_2275, net_2276,
         net_2277, net_2278, net_2279, net_2280, net_2281, net_2282, net_2283,
         net_2284, net_2285, net_2286, net_2287, net_2288, net_2289, net_2290,
         net_2291, net_2292, net_2293, net_2294, net_2295, net_2296, net_2297,
         net_2298, net_2299, net_2300, net_2301, net_2302, net_2303, net_2304,
         net_2305, net_2306, net_2307, net_2308, net_2309, net_2310, net_2311,
         net_2312, net_2313, net_2314, net_2315, net_2316, net_2317, net_2318,
         net_2319, net_2320, net_2321, net_2322, net_2323, net_2324, net_2325,
         net_2326, net_2327, net_2328, net_2329, net_2330, net_2331, net_2332,
         net_2333, net_2334, net_2335, net_2336, net_2337, net_2338, net_2339,
         net_2340, net_2341, net_2342, net_2343, net_2344, net_2345, net_2346,
         net_2347, net_2348, net_2349, net_2350, net_2351, net_2352, net_2353,
         net_2354, net_2355, net_2356, net_2357, net_2358, net_2359, net_2360,
         net_2361, net_2362, net_2363, net_2364, net_2365, net_2366, net_2367,
         net_2368, net_2369, net_2370, net_2371, net_2372, net_2373, net_2374,
         net_2375, net_2376, net_2377, net_2378, net_2379, net_2380, net_2381,
         net_2382, net_2383, net_2384, net_2385, net_2386, net_2387, net_2388,
         net_2389, net_2390, net_2391, net_2392, net_2393, net_2394, net_2395,
         net_2396, net_2397, net_2398, net_2399, net_2400, net_2401, net_2402,
         net_2403, net_2404, net_2405, net_2406, net_2407, net_2408, net_2409,
         net_2410, net_2411, net_2412, net_2413, net_2414, net_2415, net_2416,
         net_2417, net_2418, net_2419, net_2420, net_2421, net_2422, net_2423,
         net_2424, net_2425, net_2426, net_2427, net_2428, net_2429, net_2430,
         net_2431, net_2432, net_2433, net_2434, net_2435, net_2436, net_2437,
         net_2438, net_2439, net_2440, net_2441, net_2442, net_2443, net_2444,
         net_2445, net_2446, net_2447, net_2448, net_2449, net_2450, net_2451,
         net_2452, net_2453, net_2454, net_2455, net_2456, net_2457, net_2458,
         net_2459, net_2460, net_2461, net_2462, net_2463, net_2464, net_2465,
         net_2466, net_2467, net_2468, net_2469, net_2470, net_2471, net_2472,
         net_2473, net_2474, net_2475, net_2476, net_2477, net_2478, net_2479,
         net_2480, net_2481, net_2482, net_2483, net_2484, net_2485, net_2486,
         net_2487, net_2488, net_2489, net_2490, net_2491, net_2492, net_2493,
         net_2494, net_2495, net_2496, net_2497, net_2498, net_2499, net_2500,
         net_2501, net_2502, net_2503, net_2504, net_2505, net_2506, net_2507,
         net_2508, net_2509, net_2510, net_2511, net_2512, net_2513, net_2514,
         net_2515, net_2516, net_2517, net_2518, net_2519, net_2520, net_2521,
         net_2522, net_2523, net_2524, net_2525, net_2526, net_2527, net_2528,
         net_2529, net_2530, net_2531, net_2532, net_2533, net_2534, net_2535,
         net_2536, net_2537, net_2538, net_2539, net_2540, net_2541, net_2542,
         net_2543, net_2544, net_2545, net_2546, net_2547, net_2548, net_2549,
         net_2550, net_2551, net_2552, net_2553, net_2554, net_2555, net_2556,
         net_2557, net_2558, net_2559, net_2560, net_2561, net_2562, net_2563,
         net_2564, net_2565, net_2566, net_2567, net_2568, net_2569, net_2570,
         net_2571, net_2572, net_2573, net_2574, net_2575, net_2576, net_2577,
         net_2578, net_2579, net_2580, net_2581, net_2582, net_2583, net_2584,
         net_2585, net_2586, net_2587, net_2588, net_2589, net_2590, net_2591,
         net_2592, net_2593, net_2594, net_2595, net_2596, net_2597, net_2598,
         net_2599, net_2600, net_2601, net_2602, net_2603, net_2604, net_2605,
         net_2606, net_2607, net_2608, net_2609, net_2610, net_2611, net_2612,
         net_2613, net_2614, net_2615, net_2616, net_2617, net_2618, net_2619,
         net_2620, net_2621, net_2622, net_2623, net_2624, net_2625, net_2626,
         net_2627, net_2628, net_2629, net_2630, net_2631, net_2632, net_2633,
         net_2634, net_2635, net_2636, net_2637, net_2638, net_2639, net_2640,
         net_2641, net_2642, net_2643, net_2644, net_2645, net_2646, net_2647,
         net_2648, net_2649, net_2650, net_2651, net_2652, net_2653, net_2654,
         net_2655, net_2656, net_2657, net_2658, net_2659, net_2660, net_2661,
         net_2662, net_2663, net_2664, net_2665, net_2666, net_2667, net_2668,
         net_2669, net_2670, net_2671, net_2672, net_2673, net_2674, net_2675,
         net_2676, net_2677, net_2678, net_2679, net_2680, net_2681, net_2682,
         net_2683, net_2684, net_2685, net_2686, net_2687, net_2688, net_2689,
         net_2690, net_2691, net_2692, net_2693, net_2694, net_2695, net_2696,
         net_2697, net_2698, net_2699, net_2700, net_2701, net_2702, net_2703,
         net_2704, net_2705, net_2706, net_2707, net_2708, net_2709, net_2710,
         net_2711, net_2712, net_2713, net_2714, net_2715, net_2716, net_2717,
         net_2718, net_2719, net_2720, net_2721, net_2722, net_2723, net_2724,
         net_2725, net_2726, net_2727, net_2728, net_2729, net_2730, net_2731,
         net_2732, net_2733, net_2734, net_2735, net_2736, net_2737, net_2738,
         net_2739, net_2740, net_2741, net_2742, net_2743, net_2744, net_2745,
         net_2746, net_2747, net_2748, net_2749, net_2750, net_2751, net_2752,
         net_2753, net_2754, net_2755, net_2756, net_2757, net_2758, net_2759,
         net_2760, net_2761, net_2762, net_2763, net_2764, net_2765, net_2766,
         net_2767, net_2768, net_2769, net_2770, net_2771, net_2772, net_2773,
         net_2774, net_2775, net_2776, net_2777, net_2778, net_2779, net_2780,
         net_2781, net_2782, net_2783, net_2784, net_2785, net_2786, net_2787,
         net_2788, net_2789, net_2790, net_2791, net_2792, net_2793, net_2794,
         net_2795, net_2796, net_2797, net_2798, net_2799, net_2800, net_2801,
         net_2802, net_2803, net_2804, net_2805, net_2806, net_2807, net_2808,
         net_2809, net_2810, net_2811, net_2812, net_2813, net_2814, net_2815,
         net_2816, net_2817, net_2818, net_2819, net_2820, net_2821, net_2822,
         net_2823, net_2824, net_2825, net_2826, net_2827, net_2828, net_2829,
         net_2830, net_2831, net_2832, net_2833, net_2834, net_2835, net_2836,
         net_2837, net_2838, net_2839, net_2840, net_2841, net_2842, net_2843,
         net_2844, net_2845, net_2846, net_2847, net_2848, net_2849, net_2850,
         net_2851, net_2852, net_2853, net_2854, net_2855, net_2856, net_2857,
         net_2858, net_2859, net_2860, net_2861, net_2862, net_2863, net_2864,
         net_2865, net_2866, net_2867, net_2868, net_2869, net_2870, net_2871,
         net_2872, net_2873, net_2874, net_2875, net_2876, net_2877, net_2878,
         net_2879, net_2880, net_2881, net_2882, net_2883, net_2884, net_2885,
         net_2886, net_2887, net_2888, net_2889, net_2890, net_2891, net_2892,
         net_2893, net_2894, net_2895, net_2896, net_2897, net_2898, net_2899,
         net_2900, net_2901, net_2902, net_2903, net_2904, net_2905, net_2906,
         net_2907, net_2908, net_2909, net_2910, net_2911, net_2912, net_2913,
         net_2914, net_2915, net_2916, net_2917, net_2918, net_2919, net_2920,
         net_2921, net_2922, net_2923, net_2924, net_2925, net_2926, net_2927,
         net_2928, net_2929, net_2930, net_2931, net_2932, net_2933, net_2934,
         net_2935, net_2936, net_2937, net_2938, net_2939, net_2940, net_2941,
         net_2942, net_2943, net_2944, net_2945, net_2946, net_2947, net_2948,
         net_2949, net_2950, net_2951, net_2952, net_2953, net_2954, net_2955,
         net_2956, net_2957, net_2958, net_2959, net_2960, net_2961, net_2962,
         net_2963, net_2964, net_2965, net_2966, net_2967, net_2968, net_2969,
         net_2970, net_2971, net_2972, net_2973, net_2974, net_2975, net_2976,
         net_2977, net_2978, net_2979, net_2980, net_2981, net_2982, net_2983,
         net_2984, net_2985, net_2986, net_2987, net_2988, net_2989, net_2990,
         net_2991, net_2992, net_2993, net_2994, net_2995, net_2996, net_2997,
         net_2998, net_2999, net_3000, net_3001, net_3002, net_3003, net_3004,
         net_3005, net_3006, net_3007, net_3008, net_3009, net_3010, net_3011,
         net_3012, net_3013, net_3014, net_3015, net_3016, net_3017, net_3018,
         net_3019, net_3020, net_3021, net_3022, net_3023, net_3024, net_3025,
         net_3026, net_3027, net_3028, net_3029, net_3030, net_3031, net_3032,
         net_3033, net_3034, net_3035, net_3036, net_3037, net_3038, net_3039,
         net_3040, net_3041, net_3042, net_3043, net_3044, net_3045, net_3046,
         net_3047, net_3048, net_3049, net_3050, net_3051, net_3052, net_3053,
         net_3054, net_3055, net_3056, net_3057, net_3058, net_3059, net_3060,
         net_3061, net_3062, net_3063, net_3064, net_3065, net_3066, net_3067,
         net_3068, net_3069, net_3070, net_3071, net_3072, net_3073, net_3074,
         net_3075, net_3076, net_3077, net_3078, net_3079, net_3080, net_3081,
         net_3082, net_3083, net_3084, net_3085, net_3086, net_3087, net_3088,
         net_3089, net_3090, net_3091, net_3092, net_3093, net_3094, net_3095,
         net_3096, net_3097, net_3098, net_3099, net_3100, net_3101, net_3102,
         net_3103, net_3104, net_3105, net_3106, net_3107, net_3108, net_3109,
         net_3110, net_3111, net_3112, net_3113, net_3114, net_3115, net_3116,
         net_3117, net_3118, net_3119, net_3120, net_3121, net_3122, net_3123,
         net_3124, net_3125, net_3126, net_3127, net_3128, net_3129, net_3130,
         net_3131, net_3132, net_3133, net_3134, net_3135, net_3136, net_3137,
         net_3138, net_3139, net_3140, net_3141, net_3142, net_3143, net_3144,
         net_3145, net_3146, net_3147, net_3148, net_3149, net_3150, net_3151,
         net_3152, net_3153, net_3154, net_3155, net_3156, net_3157, net_3158,
         net_3159, net_3160, net_3161, net_3162, net_3163, net_3164, net_3165,
         net_3166, net_3167, net_3168, net_3169, net_3170, net_3171, net_3172,
         net_3173, net_3174, net_3175, net_3176, net_3177, net_3178, net_3179,
         net_3180, net_3181, net_3182, net_3183, net_3184, net_3185, net_3186,
         net_3187, net_3188, net_3189, net_3190, net_3191, net_3192, net_3193,
         net_3194, net_3195, net_3196, net_3197, net_3198, net_3199, net_3200,
         net_3201, net_3202, net_3203, net_3204, net_3205, net_3206, net_3207,
         net_3208, net_3209, net_3210, net_3211, net_3212, net_3213, net_3214,
         net_3215, net_3216, net_3217, net_3218, net_3219, net_3220, net_3221,
         net_3222, net_3223, net_3224, net_3225, net_3226, net_3227, net_3228,
         net_3229, net_3230, net_3231, net_3232, net_3233, net_3234, net_3235,
         net_3236, net_3237, net_3238, net_3239, net_3240, net_3241, net_3242,
         net_3243, net_3244, net_3245, net_3246, net_3247, net_3248, net_3249,
         net_3250, net_3251, net_3252, net_3253, net_3254, net_3255, net_3256,
         net_3257, net_3258, net_3259, net_3260, net_3261, net_3262, net_3263,
         net_3264, net_3265, net_3266, net_3267, net_3268, net_3269, net_3270,
         net_3271, net_3272, net_3273, net_3274, net_3275, net_3276, net_3277,
         net_3278, net_3279, net_3280, net_3281, net_3282, net_3283, net_3284,
         net_3285, net_3286, net_3287, net_3288, net_3289, net_3290, net_3291,
         net_3292, net_3293, net_3294, net_3295, net_3296, net_3297, net_3298,
         net_3299, net_3300, net_3301, net_3302, net_3303, net_3304, net_3305,
         net_3306, net_3307, net_3308, net_3309, net_3310, net_3311, net_3312,
         net_3313, net_3314, net_3315, net_3316, net_3317, net_3318, net_3319,
         net_3320, net_3321, net_3322, net_3323, net_3324, net_3325, net_3326,
         net_3327, net_3328, net_3329, net_3330, net_3331, net_3332, net_3333,
         net_3334, net_3335, net_3336, net_3337, net_3338, net_3339, net_3340,
         net_3341, net_3342, net_3343, net_3344, net_3345, net_3346, net_3347,
         net_3348, net_3349, net_3350, net_3351, net_3352, net_3353, net_3354,
         net_3355, net_3356, net_3357, net_3358, net_3359, net_3360, net_3361,
         net_3362, net_3363, net_3364, net_3365, net_3366, net_3367, net_3368,
         net_3369, net_3370, net_3371, net_3372, net_3373, net_3374, net_3375,
         net_3376, net_3377, net_3378, net_3379, net_3380, net_3381, net_3382,
         net_3383, net_3384, net_3385, net_3386, net_3387, net_3388, net_3389,
         net_3390, net_3391, net_3392, net_3393, net_3394, net_3395, net_3396,
         net_3397, net_3398, net_3399, net_3400, net_3401, net_3402, net_3403,
         net_3404, net_3405, net_3406, net_3407, net_3408, net_3409, net_3410,
         net_3411, net_3412, net_3413, net_3414, net_3415, net_3416, net_3417,
         net_3418, net_3419, net_3420, net_3421, net_3422, net_3423, net_3424,
         net_3425, net_3426, net_3427, net_3428, net_3429, net_3430, net_3431,
         net_3432, net_3433, net_3434, net_3435, net_3436, net_3437, net_3438,
         net_3439, net_3440, net_3441, net_3442, net_3443, net_3444, net_3445,
         net_3446, net_3447, net_3448, net_3449, net_3450, net_3451, net_3452,
         net_3453, net_3454, net_3455, net_3456, net_3457, net_3458, net_3459,
         net_3460, net_3461, net_3462, net_3463, net_3464, net_3465, net_3466,
         net_3467, net_3468, net_3469, net_3470, net_3471;

  assign net_1 = ~net_1058;
  assign net_2 = ~net_2136;
  assign net_3 = ~net_494;
  assign net_4 = ~net_609;
  assign net_5 = ~net_2131;
  assign net_6 = ~net_435;
  assign net_7 = ~net_2547;
  assign net_8 = ~net_673;
  assign net_9 = ~net_894;
  assign net_10 = ~net_1140;
  assign net_11 = ~net_1312;
  assign net_12 = ~net_859;
  assign net_13 = ~net_373;
  assign net_14 = ~net_596;
  assign net_15 = ~net_420;
  assign net_16 = ~a64_only;
  assign net_17 = ~net_2574;
  assign net_18 = ~aarch64_state_i;
  assign net_19 = ~decoder_fsm_i[2];
  assign net_20 = ~net_2922;
  assign net_21 = ~decoder_fsm_i[0];
  assign net_22 = ~net_411;
  assign net_23 = ~sf_bit;
  assign net_24 = ~net_1893;
  assign net_25 = ~net_999;
  assign net_26 = ~net_2930;
  assign net_27 = ~net_1048;
  assign net_28 = ~net_2651;
  assign net_29 = ~net_835;
  assign net_30 = ~net_1363;
  assign net_31 = ~net_633;
  assign net_32 = ~net_3207;
  assign net_33 = ~net_336;
  assign net_34 = ~net_1455;
  assign net_35 = ~net_2317;
  assign net_36 = ~net_552;
  assign net_37 = ~net_127;
  assign net_38 = ~net_1900;
  assign net_40 = ~net_751;
  assign net_41 = ~net_1087;
  assign net_42 = ~iq_instr_fn_i[26];
  assign net_43 = ~net_531;
  assign net_44 = ~net_104;
  assign net_45 = ~net_1963;
  assign net_46 = ~net_1250;
  assign net_47 = ~iq_instr_fn_i[25];
  assign net_48 = ~net_958;
  assign net_49 = ~net_363;
  assign net_50 = ~iq_instr_fn_i[24];
  assign net_51 = ~net_637;
  assign net_52 = ~net_1633;
  assign net_53 = ~net_1317;
  assign net_54 = ~net_2991;
  assign net_55 = ~net_1340;
  assign net_56 = ~net_2268;
  assign net_57 = ~net_110;
  assign net_58 = ~net_1804;
  assign net_59 = ~iq_instr_fn_i[23];
  assign net_60 = ~net_1286;
  assign net_61 = ~net_147;
  assign net_62 = ~net_1820;
  assign net_63 = ~net_1029;
  assign net_64 = ~net_346;
  assign net_65 = ~net_203;
  assign net_66 = ~net_351;
  assign net_67 = ~net_663;
  assign net_68 = ~net_1548;
  assign net_71 = ~net_1579;
  assign net_72 = ~iq_instr_fn_i[19];
  assign net_73 = ~net_370;
  assign net_74 = ~iq_instr_fn_i[18];
  assign net_75 = ~iq_instr_fn_i[17];
  assign net_76 = ~net_1607;
  assign net_77 = ~net_2334;
  assign net_78 = ~iq_instr_fn_i[16];
  assign net_79 = ~net_549;
  assign net_80 = ~net_261;
  assign net_81 = ~net_1955;
  assign net_82 = ~net_269;
  assign net_83 = ~net_252;
  assign net_84 = ~net_556;
  assign net_85 = ~net_388;
  assign net_86 = ~net_2173;
  assign net_87 = ~net_431;
  assign net_91 = ~net_774;
  assign net_92 = ~net_1744;
  assign net_93 = ~net_1669;
  assign net_95 = ~iq_instr_fn_i[7];
  assign sel_fml_c_neon_o = (net_98 | net_99);
  assign net_99 = (net_100 | net_101);
  assign net_101 = (net_102 | net_103);
  assign net_103 = (net_104 & net_105);
  assign net_105 = (net_106 | net_107);
  assign net_107 = (iq_instr_fn_i[21] & net_108);
  assign net_106 = (net_109 & net_110);
  assign net_102 = (net_111 | net_112);
  assign net_112 = ~(net_113 & net_114);
  assign net_114 = ~(net_115 | net_116);
  assign net_115 = (net_117 & net_118);
  assign sel_fml_a_neon_o = (sel_fml_b_neon_o | net_119);
  assign net_119 = (net_120 | mul_sqrt);
  assign sel_fml_b_neon_o = ~(net_121 & net_122);
  assign net_122 = ~(net_123 | net_124);
  assign net_124 = (net_98 | net_125);
  assign net_125 = (net_126 | mul_neon_inv_is_zero);
  assign net_98 = (net_127 & net_128);
  assign net_123 = (net_129 | net_130);
  assign net_130 = ~(net_131 & net_132);
  assign net_132 = ~(net_3470 & net_133);
  assign sel_fad_c_neon_o[1] = ~(net_134 & net_135);
  assign net_134 = (net_136 & net_137);
  assign net_137 = ~(net_138 & net_3466);
  assign net_136 = (net_139 & net_140);
  assign net_140 = (net_141 & net_142);
  assign net_139 = (net_143 & net_144);
  assign net_143 = ~(net_145 | net_146);
  assign net_146 = ~(net_147 | net_148);
  assign sel_fad_c_neon_o[0] = (net_149 | net_150);
  assign net_150 = (net_151 | net_152);
  assign net_152 = ~(net_153 & net_154);
  assign net_154 = ~(net_155 | net_156);
  assign net_149 = ~(net_157 & net_158);
  assign net_158 = (iq_instr_fn_i[6] | net_159);
  assign net_157 = ~(net_160 | net_161);
  assign sel_fad_b_neon_o[2] = (net_162 | sel_fad_a_neon_o[2]);
  assign sel_fad_b_neon_o[1] = ~(net_163 & net_164);
  assign net_163 = ~(net_165 | net_166);
  assign net_166 = (net_162 | net_167);
  assign net_162 = ~(net_168 | iq_instr_fn_i[20]);
  assign net_168 = ~(net_169 | net_170);
  assign net_170 = ~(net_171 & net_2);
  assign net_165 = ~(net_172 | net_173);
  assign net_173 = ~(net_174 | net_175);
  assign net_175 = ~(net_176 | net_44);
  assign sel_fad_b_neon_o[0] = (net_177 | net_178);
  assign net_178 = (net_179 | net_180);
  assign net_180 = (net_181 | net_182);
  assign net_182 = (net_183 | net_184);
  assign net_181 = (net_185 | net_186);
  assign net_186 = (net_187 | net_188);
  assign net_187 = (decoder_fsm_i[0] & net_189);
  assign net_185 = (net_190 | net_191);
  assign net_191 = ~(net_192 & net_193);
  assign net_193 = ~(net_194 | net_195);
  assign net_195 = (net_196 | net_197);
  assign net_197 = ~(net_198 & net_199);
  assign net_199 = ~(net_200 & net_201);
  assign net_198 = ~(net_202 & net_203);
  assign net_196 = (net_3464 & net_204);
  assign net_204 = (net_205 & net_206);
  assign net_194 = (net_207 | net_208);
  assign net_208 = (net_209 | net_210);
  assign net_210 = (net_211 | net_212);
  assign net_209 = (net_213 & net_214);
  assign net_214 = (net_215 | net_216);
  assign net_216 = (net_217 & iq_instr_fn_i[6]);
  assign net_207 = ~(net_218 & net_219);
  assign net_219 = ~(iq_instr_fn_i[20] & net_220);
  assign net_220 = ~(net_221 & net_2);
  assign net_221 = ~(net_222 | net_223);
  assign net_223 = (net_224 & net_225);
  assign net_225 = (net_47 & net_59);
  assign net_222 = ~(net_226 & net_227);
  assign net_227 = ~(net_228 & net_23);
  assign net_226 = (net_229 | net_230);
  assign net_190 = (net_231 | net_232);
  assign net_232 = (net_233 | net_234);
  assign net_234 = (net_235 | net_236);
  assign net_235 = (net_10 & net_237);
  assign net_237 = ~(net_238 & net_239);
  assign net_239 = ~(net_240 & net_241);
  assign net_233 = (net_242 | net_243);
  assign net_243 = (net_244 | net_245);
  assign net_245 = (net_246 | net_247);
  assign net_247 = (net_248 & net_249);
  assign net_249 = (net_203 & decoder_fsm_i[0]);
  assign net_248 = (net_118 & net_250);
  assign net_246 = (net_251 & net_252);
  assign net_244 = (net_253 | net_254);
  assign net_254 = (net_255 | net_256);
  assign net_255 = (net_257 & net_23);
  assign net_242 = (net_258 & net_259);
  assign net_259 = (net_260 | net_261);
  assign net_258 = (net_262 & net_263);
  assign net_231 = (net_264 | net_265);
  assign net_265 = (net_266 | net_267);
  assign net_266 = (net_268 & net_269);
  assign net_264 = ~(net_270 & net_271);
  assign net_271 = (net_272 | iq_instr_fn_i[17]);
  assign net_270 = (net_3464 | net_273);
  assign sel_fad_a_neon_o[2] = ~(net_274 & net_275);
  assign net_275 = (iq_instr_fn_i[11] | net_276);
  assign net_276 = ~(net_277 & net_278);
  assign net_278 = (net_3467 | decoder_fsm_i[0]);
  assign net_274 = (net_279 & net_280);
  assign net_280 = ~(net_281 & net_269);
  assign net_279 = (net_282 & net_283);
  assign net_283 = ~(net_284 | net_285);
  assign net_285 = ~(net_286 & net_287);
  assign net_286 = (net_288 & net_289);
  assign sel_fad_a_neon_o[0] = ~(net_290 & net_291);
  assign net_291 = ~(iq_instr_fn_i[9] & net_292);
  assign net_292 = (net_293 | net_294);
  assign net_294 = ~(net_295 & net_296);
  assign net_290 = (net_297 & net_298);
  assign net_298 = (net_299 & net_300);
  assign net_300 = ~(net_301 | net_302);
  assign net_302 = ~(net_303 & net_304);
  assign net_304 = ~(add_neon_sat_op_sel[2] | net_305);
  assign net_305 = ~(net_306 & net_307);
  assign net_307 = (net_30 | net_308);
  assign net_306 = (net_131 & net_309);
  assign net_303 = (net_310 & net_311);
  assign net_311 = ~(net_312 & net_313);
  assign net_313 = ~(net_314 | iq_instr_fn_i[28]);
  assign net_310 = ~(net_315 | net_316);
  assign net_316 = ~(iq_instr_fn_i[20] | net_317);
  assign net_317 = ~(net_318 & iq_instr_fn_i[4]);
  assign net_315 = ~(net_319 & net_320);
  assign net_320 = ~(net_321 & iq_instr_fn_i[5]);
  assign net_319 = (net_322 | net_3465);
  assign net_301 = (net_323 | net_324);
  assign net_324 = (net_325 | net_326);
  assign net_326 = ~(net_327 & net_328);
  assign net_299 = ~(net_329 | net_330);
  assign net_330 = ~(iq_instr_fn_i[11] | net_331);
  assign net_331 = (net_332 & net_333);
  assign net_333 = (net_334 & net_335);
  assign net_335 = ~(net_336 & net_337);
  assign net_334 = (net_338 & net_339);
  assign net_339 = (net_340 | net_21);
  assign net_340 = ~(net_117 | net_341);
  assign net_341 = (net_342 & iq_instr_fn_i[19]);
  assign net_332 = (net_343 & net_344);
  assign net_344 = (net_57 | net_345);
  assign net_345 = ~(net_346 & net_336);
  assign net_343 = ~(net_347 & net_348);
  assign net_329 = ~(net_349 & net_350);
  assign net_350 = ~(net_351 & net_352);
  assign net_352 = (net_353 | net_354);
  assign net_354 = (net_355 | net_356);
  assign net_356 = (net_357 | net_358);
  assign net_358 = (net_359 | net_360);
  assign net_359 = (net_361 & net_362);
  assign net_362 = (net_363 | net_364);
  assign net_357 = (net_365 & net_366);
  assign net_366 = ~(net_367 | net_368);
  assign net_368 = (iq_instr_fn_i[7] | net_369);
  assign net_369 = ~(net_370 & net_3468);
  assign net_355 = ~(net_371 & net_372);
  assign net_372 = ~(net_373 & net_374);
  assign net_374 = (net_375 | net_376);
  assign net_376 = ~(net_377 | net_35);
  assign net_375 = (iq_instr_fn_i[24] & net_378);
  assign net_378 = (net_379 | net_380);
  assign net_380 = (net_381 | net_3471);
  assign net_381 = (net_382 | net_383);
  assign net_383 = (net_384 | net_385);
  assign net_385 = (net_386 & net_387);
  assign net_387 = (net_388 | net_389);
  assign net_386 = ~(net_95 | net_76);
  assign net_384 = (net_390 & net_391);
  assign net_391 = ~(net_392 | iq_instr_fn_i[9]);
  assign net_382 = (iq_instr_fn_i[9] & net_393);
  assign net_393 = (net_394 | net_395);
  assign net_394 = (net_396 | net_397);
  assign net_397 = ~(net_73 | net_92);
  assign net_396 = (net_21 & net_398);
  assign net_398 = (net_389 & net_241);
  assign net_371 = (net_399 & net_400);
  assign net_400 = ~(net_401 & net_23);
  assign net_353 = (net_402 | net_403);
  assign net_403 = (net_404 & net_405);
  assign net_405 = (net_406 | net_407);
  assign net_407 = (a64_only & net_408);
  assign net_408 = ~(net_71 | iq_instr_fn_i[16]);
  assign net_406 = (net_409 | net_379);
  assign net_379 = ~(net_410 | net_79);
  assign net_409 = (net_411 & net_412);
  assign net_412 = ~(iq_instr_fn_i[7] | net_413);
  assign net_402 = (iq_instr_fn_i[16] & net_414);
  assign net_414 = (net_415 & net_370);
  assign net_415 = (net_3463 & net_416);
  assign net_416 = (net_417 | net_418);
  assign net_418 = ~(net_419 | net_420);
  assign net_417 = ~(net_421 | net_422);
  assign net_422 = ~(net_423 & net_424);
  assign net_424 = (net_74 & net_18);
  assign net_297 = (net_425 & net_426);
  assign net_426 = ~(net_427 | net_428);
  assign net_428 = ~(net_429 & net_430);
  assign net_430 = ~(net_431 & net_432);
  assign net_429 = (net_433 & net_434);
  assign net_434 = ~(net_435 & net_436);
  assign net_433 = (net_7 | net_410);
  assign net_425 = (net_437 & net_438);
  assign net_438 = (iq_instr_fn_i[9] | net_439);
  assign net_439 = (net_440 & net_441);
  assign net_441 = (net_442 & net_443);
  assign net_442 = (net_444 & net_445);
  assign net_445 = (net_66 | net_446);
  assign net_446 = (net_447 & net_448);
  assign net_448 = (net_21 | net_449);
  assign net_449 = ~(net_450 & net_451);
  assign net_451 = ~(net_452 | net_13);
  assign net_447 = (net_453 & net_454);
  assign net_454 = ~(net_455 & net_336);
  assign net_453 = ~(net_456 & net_457);
  assign net_444 = (net_458 & net_459);
  assign net_459 = ~(net_460 & net_455);
  assign net_458 = (net_461 & net_462);
  assign net_461 = (net_22 | net_463);
  assign net_463 = (net_464 | net_465);
  assign net_465 = ~(net_466 & decoder_fsm_i[0]);
  assign net_440 = (net_467 & net_468);
  assign net_467 = ~(net_469 | net_470);
  assign net_470 = ~(net_471 & net_472);
  assign net_472 = ~(net_473 & net_3468);
  assign net_471 = (net_474 & net_475);
  assign net_475 = ~(net_476 & net_455);
  assign net_474 = (net_477 & net_478);
  assign net_478 = (net_479 | net_480);
  assign net_480 = ~(net_481 & net_482);
  assign net_482 = (net_483 & net_361);
  assign net_479 = (net_72 | iq_instr_fn_i[10]);
  assign net_437 = (net_484 & net_485);
  assign net_485 = (net_486 & net_487);
  assign net_487 = (iq_instr_fn_i[11] | net_488);
  assign net_486 = ~(net_489 | net_490);
  assign net_490 = (net_3464 & net_491);
  assign net_491 = (net_492 | net_493);
  assign net_493 = (net_494 & net_456);
  assign net_492 = (net_321 | net_495);
  assign net_495 = (net_496 | net_497);
  assign net_497 = ~(net_498 | net_499);
  assign net_499 = (iq_instr_fn_i[4] | net_500);
  assign net_500 = ~(net_104 & net_16);
  assign net_496 = (net_501 & net_502);
  assign net_321 = ~(iq_instr_fn_i[24] | net_503);
  assign net_489 = (net_504 | net_505);
  assign net_505 = ~(net_506 & net_507);
  assign net_507 = (net_508 & net_509);
  assign net_508 = (net_510 & net_511);
  assign net_511 = (net_3466 | net_512);
  assign net_510 = (net_513 & net_514);
  assign net_514 = (net_515 & net_516);
  assign net_516 = (net_517 | net_48);
  assign net_515 = (net_518 & net_519);
  assign net_513 = (net_520 | iq_instr_fn_i[4]);
  assign net_520 = (net_521 & net_522);
  assign net_522 = ~(net_241 & net_523);
  assign net_523 = ~(net_524 | net_525);
  assign net_525 = ~(net_526 & net_527);
  assign net_527 = ~(net_3469 | net_421);
  assign net_521 = (net_528 & net_529);
  assign net_529 = ~(iq_instr_fn_i[27] & net_530);
  assign net_530 = (net_531 & net_494);
  assign net_506 = (net_532 & net_533);
  assign net_533 = (net_367 | net_534);
  assign net_534 = ~(iq_instr_fn_i[20] & net_535);
  assign net_532 = ~(net_536 & net_537);
  assign net_537 = ~(net_538 & net_539);
  assign net_539 = (net_540 & net_27);
  assign net_538 = (net_87 | a64_only);
  assign net_504 = (net_541 | net_542);
  assign net_542 = ~(net_543 & net_544);
  assign net_544 = ~(net_545 | net_546);
  assign net_545 = (net_547 | net_548);
  assign net_547 = (net_549 & net_550);
  assign net_550 = (net_551 & net_552);
  assign net_541 = ~(net_553 & net_554);
  assign net_554 = ~(net_251 & net_269);
  assign net_251 = (net_336 & net_555);
  assign net_553 = ~(net_556 & net_557);
  assign rounding_mode[2] = (net_558 | net_559);
  assign net_559 = (net_560 | net_561);
  assign net_561 = (net_562 | net_563);
  assign net_563 = (net_564 | net_565);
  assign net_565 = (net_566 | net_567);
  assign net_567 = (net_568 | net_569);
  assign net_568 = (net_570 & net_3465);
  assign net_566 = ~(net_571 & net_572);
  assign net_571 = (net_573 & net_574);
  assign net_574 = ~(net_575 & net_241);
  assign net_573 = ~(net_576 | net_577);
  assign net_577 = (net_578 & net_579);
  assign net_579 = ~(net_392 | iq_instr_fn_i[4]);
  assign net_564 = (net_580 | net_581);
  assign net_581 = (net_582 | net_583);
  assign net_583 = ~(net_584 & net_585);
  assign net_584 = (net_586 & net_587);
  assign net_587 = (net_588 | net_78);
  assign net_586 = (net_589 & net_590);
  assign net_590 = ~(net_591 | net_592);
  assign net_592 = (net_593 & net_594);
  assign net_594 = ~(net_595 | iq_instr_fn_i[9]);
  assign net_591 = ~(net_596 | net_597);
  assign net_597 = (net_78 & iq_instr_fn_i[18]);
  assign net_560 = ~(net_3465 | net_598);
  assign rounding_mode[1] = ~(net_599 & net_600);
  assign net_599 = ~(net_601 | net_602);
  assign net_602 = ~(net_603 & net_604);
  assign net_603 = (net_605 & net_606);
  assign net_606 = (net_607 | net_608);
  assign net_608 = ~(net_609 & net_593);
  assign net_607 = (net_3466 | net_3465);
  assign net_605 = ~(net_610 | net_611);
  assign net_611 = ~(net_612 & net_613);
  assign net_613 = (net_75 | net_614);
  assign net_612 = (net_615 & net_616);
  assign net_616 = (net_32 | net_392);
  assign net_615 = (net_288 & net_617);
  assign net_601 = (net_618 | net_619);
  assign net_619 = ~(net_620 & net_621);
  assign net_621 = ~(net_622 | net_558);
  assign net_558 = (net_623 | net_624);
  assign net_624 = ~(net_625 & net_626);
  assign net_626 = ~(net_627 | net_628);
  assign net_627 = (net_3466 & net_629);
  assign net_629 = (net_11 | net_630);
  assign net_630 = (net_631 | net_632);
  assign net_631 = (net_633 & net_634);
  assign net_634 = (net_635 | net_636);
  assign net_636 = (net_637 & net_638);
  assign net_623 = (net_639 | net_640);
  assign net_640 = ~(net_282 & net_641);
  assign net_641 = ~(net_642 & net_643);
  assign net_618 = (net_644 | net_645);
  assign net_645 = (net_646 | net_647);
  assign net_646 = (net_318 & net_3465);
  assign net_318 = (iq_instr_fn_i[22] & net_648);
  assign net_648 = (iq_instr_fn_i[6] & net_649);
  assign net_644 = (net_325 | net_650);
  assign net_650 = ~(net_289 & net_651);
  assign net_651 = ~(net_575 & net_652);
  assign net_325 = (net_653 & net_654);
  assign rounding_mode[0] = (net_655 | net_656);
  assign net_656 = (net_657 | net_658);
  assign net_658 = ~(net_659 & net_660);
  assign net_660 = (net_661 & net_662);
  assign net_662 = ~(net_663 & net_664);
  assign net_661 = ~(net_665 | net_666);
  assign net_666 = (net_427 | net_667);
  assign net_667 = ~(net_668 & net_669);
  assign net_669 = (iq_instr_fn_i[24] | net_670);
  assign net_670 = ~(net_671 & net_672);
  assign net_672 = (net_673 & net_674);
  assign net_668 = ~(net_675 & net_676);
  assign net_676 = ~(net_74 & net_677);
  assign net_677 = ~(iq_instr_fn_i[20] & net_75);
  assign net_427 = (net_678 & net_679);
  assign net_679 = (iq_instr_fn_i[25] | net_466);
  assign net_655 = (net_680 | net_681);
  assign net_681 = (net_682 | net_683);
  assign net_683 = (net_684 | net_647);
  assign net_647 = ~(net_685 & net_686);
  assign net_686 = (iq_instr_fn_i[22] | net_687);
  assign net_687 = ~(iq_instr_fn_i[21] & net_688);
  assign net_685 = (net_572 & net_689);
  assign net_689 = ~(iq_instr_fn_i[22] & net_690);
  assign net_690 = ~(net_691 | iq_instr_fn_i[21]);
  assign net_572 = (net_692 & net_693);
  assign net_693 = (net_131 & net_694);
  assign net_694 = (net_695 | iq_instr_fn_i[4]);
  assign net_695 = (net_696 & net_697);
  assign net_697 = ~(net_526 & net_698);
  assign net_698 = ~(net_421 | net_699);
  assign net_699 = (iq_instr_fn_i[17] | net_700);
  assign net_700 = (net_419 | net_59);
  assign net_696 = (net_701 & net_702);
  assign net_702 = ~(net_703 & net_704);
  assign net_704 = (net_3469 | net_705);
  assign net_701 = (net_706 & net_707);
  assign net_707 = (iq_instr_fn_i[21] | net_708);
  assign net_708 = ~(net_709 & iq_instr_fn_i[23]);
  assign net_706 = ~(net_649 & net_466);
  assign net_692 = (net_710 & net_711);
  assign net_710 = (net_712 & net_713);
  assign net_713 = ~(net_714 & net_715);
  assign net_715 = ~(iq_instr_fn_i[21] | net_716);
  assign net_716 = (net_717 & net_718);
  assign net_718 = ~(net_104 & net_719);
  assign net_719 = (iq_instr_fn_i[22] & net_674);
  assign net_717 = (net_720 & net_721);
  assign net_721 = ~(iq_instr_fn_i[28] & iq_instr_fn_i[6]);
  assign net_720 = (net_722 | iq_instr_fn_i[23]);
  assign net_712 = (net_723 & net_724);
  assign net_724 = ~(net_725 & net_688);
  assign net_723 = (net_726 & net_727);
  assign net_684 = (net_728 | net_729);
  assign net_728 = (net_730 & net_731);
  assign net_731 = ~(net_67 | net_23);
  assign net_680 = (net_732 | net_733);
  assign net_733 = ~(net_734 & net_735);
  assign net_735 = ~(net_575 & net_736);
  assign net_734 = ~(net_737 & net_642);
  assign net_642 = (net_738 & net_3471);
  assign net_732 = (net_739 & net_740);
  assign net_740 = (net_593 & net_263);
  assign mul_vector_op = (net_126 | net_741);
  assign net_741 = (net_742 | net_743);
  assign net_743 = (net_744 | net_745);
  assign net_745 = (net_746 | net_100);
  assign net_746 = (net_108 & net_747);
  assign net_744 = ~(net_726 & net_748);
  assign net_748 = ~(net_749 & net_750);
  assign net_750 = (net_751 & net_752);
  assign net_752 = ~(net_753 & net_754);
  assign net_754 = (net_79 | iq_instr_fn_i[8]);
  assign net_753 = (net_3464 | aarch64_state_i);
  assign net_742 = (net_23 & net_755);
  assign net_755 = (net_756 | net_120);
  assign net_756 = (net_757 | net_758);
  assign net_758 = (net_759 | net_760);
  assign net_760 = (net_761 | net_762);
  assign net_762 = (iq_instr_fn_i[11] & net_763);
  assign net_763 = (net_764 | net_765);
  assign net_765 = ~(net_44 | net_464);
  assign net_764 = (iq_instr_fn_i[25] & net_766);
  assign net_761 = (net_767 | net_768);
  assign net_768 = ~(net_769 | net_40);
  assign net_767 = (net_3466 & net_770);
  assign net_770 = (net_637 & net_771);
  assign net_757 = (net_772 | net_111);
  assign net_111 = (net_773 & net_3468);
  assign net_772 = (net_774 & net_775);
  assign net_775 = (net_776 & net_777);
  assign net_777 = (iq_instr_fn_i[25] & net_250);
  assign net_126 = (net_778 | net_779);
  assign net_779 = ~(net_727 & net_780);
  assign net_780 = ~(net_781 | net_782);
  assign net_778 = (net_3466 & net_783);
  assign net_783 = (net_784 | net_785);
  assign net_785 = ~(net_786 & net_787);
  assign net_786 = (net_788 & net_789);
  assign net_789 = (net_790 | net_791);
  assign net_791 = ~(iq_instr_fn_i[11] & net_361);
  assign net_784 = (net_792 | net_793);
  assign net_793 = ~(net_794 & net_795);
  assign net_795 = ~(net_269 & net_796);
  assign net_794 = (net_797 | net_79);
  assign net_797 = ~(net_798 | net_799);
  assign net_799 = (iq_instr_fn_i[8] & net_800);
  assign mul_precision = (net_801 | net_802);
  assign net_802 = (net_803 | net_804);
  assign net_804 = (net_805 | net_806);
  assign net_806 = ~(net_807 & net_808);
  assign net_808 = ~(net_809 & net_373);
  assign net_809 = (net_810 & net_811);
  assign net_811 = (net_526 & iq_instr_fn_i[21]);
  assign net_810 = (net_812 & iq_instr_fn_i[8]);
  assign net_807 = ~(net_813 & net_774);
  assign net_813 = (net_709 & net_66);
  assign net_805 = (iq_instr_fn_i[16] & net_814);
  assign net_814 = (iq_instr_fn_i[18] & net_815);
  assign net_815 = (net_816 | net_817);
  assign net_803 = ~(net_818 & net_819);
  assign net_819 = ~(net_820 & iq_instr_fn_i[21]);
  assign net_818 = ~(net_796 & net_423);
  assign net_801 = (iq_instr_fn_i[20] & net_821);
  assign net_821 = (net_822 | net_759);
  assign net_822 = (iq_instr_fn_i[4] & net_823);
  assign net_823 = (net_824 | net_825);
  assign net_825 = ~(net_83 | a64_only);
  assign mul_neon_round = (net_826 | net_827);
  assign net_827 = (net_828 | net_829);
  assign net_828 = (net_269 & net_473);
  assign net_826 = (net_830 | net_831);
  assign net_831 = ~(net_832 & net_833);
  assign net_833 = ~(net_773 & net_834);
  assign net_832 = ~(net_776 & net_835);
  assign net_776 = (net_549 & net_836);
  assign net_830 = (net_837 & net_838);
  assign net_838 = (net_652 & net_839);
  assign mul_neon_mul_type[2] = (net_840 | net_841);
  assign net_841 = (net_842 | net_843);
  assign net_842 = (net_389 & net_773);
  assign net_840 = ~(net_844 & net_845);
  assign net_845 = ~(net_846 & net_847);
  assign net_846 = (net_3470 & net_848);
  assign net_848 = (iq_instr_fn_i[20] | net_739);
  assign net_844 = (net_849 & net_850);
  assign mul_neon_mul_type[1] = (net_851 | net_852);
  assign net_852 = (net_853 | net_854);
  assign net_854 = (net_855 | net_856);
  assign net_856 = (net_857 | net_116);
  assign net_116 = (net_782 | net_858);
  assign net_782 = ~(net_85 | net_859);
  assign net_855 = ~(net_860 & net_861);
  assign net_861 = ~(net_792 & net_3466);
  assign net_792 = (net_739 & net_12);
  assign net_860 = (net_862 & net_863);
  assign net_862 = (net_864 & net_865);
  assign net_865 = ~(net_866 & net_867);
  assign net_864 = ~(net_551 & net_868);
  assign net_853 = ~(net_869 & net_870);
  assign net_870 = (net_3 | net_871);
  assign net_869 = (net_872 | net_3469);
  assign mul_neon_mul_type[0] = (net_857 | net_873);
  assign net_873 = ~(net_874 & net_875);
  assign net_875 = ~(net_847 & net_876);
  assign net_876 = (net_3470 & net_877);
  assign net_877 = (net_878 | net_879);
  assign net_879 = (iq_instr_fn_i[20] & net_880);
  assign net_880 = (aarch64_state_i & iq_instr_fn_i[0]);
  assign net_878 = (iq_instr_fn_i[3] & net_18);
  assign net_847 = (net_423 & net_751);
  assign net_874 = ~(net_100 | net_881);
  assign net_881 = ~(net_882 & net_883);
  assign net_883 = ~(net_884 & net_12);
  assign net_100 = (net_885 & net_817);
  assign net_817 = ~(net_27 | net_53);
  assign net_857 = ~(net_886 & net_887);
  assign net_886 = (net_888 & net_889);
  assign net_889 = (net_540 | net_890);
  assign net_890 = ~(net_347 & net_502);
  assign net_540 = (net_3464 | net_30);
  assign net_888 = (net_891 | net_3470);
  assign net_891 = ~(net_892 | net_893);
  assign net_893 = ~(net_42 | net_872);
  assign net_872 = ~(net_894 & net_895);
  assign net_895 = (net_549 & net_834);
  assign net_892 = (net_502 & net_896);
  assign net_896 = (net_897 | net_898);
  assign net_898 = (net_250 & net_899);
  assign net_899 = (net_900 | net_901);
  assign net_901 = ~(net_47 | net_902);
  assign net_900 = (iq_instr_fn_i[9] & net_903);
  assign net_903 = (net_904 & net_3467);
  assign net_897 = (net_905 & net_906);
  assign net_906 = ~(net_84 | net_42);
  assign net_905 = (net_907 & net_3465);
  assign mul_neon_inv_is_zero = (sel_fad_a_neon_o[1] | net_829);
  assign mul_neon_int_op = (net_781 | net_908);
  assign net_908 = (net_909 | net_910);
  assign net_910 = (net_911 | net_912);
  assign net_912 = (net_129 | net_913);
  assign net_913 = (net_914 | net_843);
  assign net_843 = (net_915 & net_3466);
  assign net_915 = ~(net_859 | iq_instr_fn_i[8]);
  assign net_914 = (net_796 & net_252);
  assign net_796 = ~(net_63 | net_40);
  assign net_911 = (net_774 & net_916);
  assign net_909 = (net_917 | net_918);
  assign net_918 = (net_851 | net_919);
  assign net_919 = ~(net_920 & net_113);
  assign net_113 = (net_921 & net_922);
  assign net_922 = ~(net_118 & net_798);
  assign net_798 = (iq_instr_fn_i[26] & net_923);
  assign net_921 = (net_924 | net_859);
  assign net_851 = (net_3466 & net_925);
  assign net_925 = (net_926 | net_927);
  assign net_927 = ~(net_928 & net_929);
  assign net_929 = ~(net_930 & net_551);
  assign net_930 = ~(net_3468 | net_44);
  assign net_928 = (net_788 & net_931);
  assign net_788 = ~(net_932 & net_933);
  assign net_933 = (net_867 & net_934);
  assign net_917 = ~(net_935 & net_936);
  assign net_936 = ~(net_937 & net_834);
  assign net_937 = (net_549 & net_800);
  assign net_935 = (net_938 & net_939);
  assign net_938 = ~(net_128 | net_940);
  assign net_940 = ~(net_790 | net_941);
  assign net_941 = ~(net_556 & net_373);
  assign net_790 = ~(net_942 & net_943);
  assign net_781 = (net_867 & net_944);
  assign net_944 = (net_945 | net_946);
  assign net_946 = (net_947 | net_866);
  assign net_866 = (net_633 & net_934);
  assign net_947 = (net_948 & net_949);
  assign net_949 = ~(net_30 | net_44);
  assign net_945 = (net_3465 & net_950);
  assign net_950 = (net_951 | net_952);
  assign net_952 = (net_261 & net_953);
  assign net_953 = ~(net_64 | net_17);
  assign net_951 = (net_954 | net_955);
  assign net_955 = (net_956 & net_957);
  assign net_957 = (net_725 & net_958);
  assign net_956 = (net_959 & net_336);
  assign net_954 = (net_250 & net_960);
  assign net_960 = (net_423 & net_961);
  assign net_961 = (net_3467 & net_3470);
  assign mul_neon_fixup = ~(net_962 & net_963);
  assign net_963 = (net_964 & net_965);
  assign net_965 = (net_966 & net_967);
  assign net_967 = (iq_instr_fn_i[28] | net_968);
  assign net_968 = ~(net_128 | net_969);
  assign net_969 = (net_347 & net_970);
  assign net_128 = (net_749 & net_108);
  assign net_966 = ~(net_971 & net_972);
  assign net_972 = (net_747 & net_751);
  assign net_747 = (net_127 & net_725);
  assign net_971 = (net_3467 & net_948);
  assign net_948 = (net_973 | net_959);
  assign net_959 = ~(net_3466 | net_3464);
  assign net_964 = (net_974 & net_975);
  assign net_975 = ~(net_976 & net_725);
  assign net_976 = (net_977 & net_978);
  assign net_978 = (net_904 & iq_instr_fn_i[27]);
  assign net_977 = (net_884 & iq_instr_fn_i[23]);
  assign net_884 = ~(net_3466 | net_80);
  assign net_974 = (net_979 | net_84);
  assign net_979 = (net_980 | net_57);
  assign net_980 = (net_981 & net_982);
  assign net_982 = ~(net_932 & net_3470);
  assign mul_negate = ~(net_983 & net_984);
  assign net_984 = ~(net_129 | net_985);
  assign net_985 = ~(net_986 & net_987);
  assign net_987 = (net_988 | net_834);
  assign net_988 = (net_80 | net_859);
  assign net_986 = (net_989 & net_990);
  assign net_990 = (net_67 | net_991);
  assign net_989 = (net_992 & net_993);
  assign net_993 = (net_994 & net_995);
  assign net_995 = ~(net_820 & net_996);
  assign net_820 = (iq_instr_fn_i[25] & net_678);
  assign net_994 = (net_997 & net_998);
  assign net_998 = (net_871 | net_999);
  assign net_997 = (net_1000 | iq_instr_fn_i[4]);
  assign net_1000 = ~(net_1001 & net_66);
  assign net_992 = ~(sel_fad_a_neon_o[1] | net_1002);
  assign net_1002 = (net_858 | net_1003);
  assign net_1003 = ~(net_1004 & net_1005);
  assign net_1004 = ~(net_1006 & net_1007);
  assign net_1007 = (net_337 & iq_instr_fn_i[27]);
  assign net_1006 = (net_942 & iq_instr_fn_i[6]);
  assign net_858 = (net_347 & net_1008);
  assign net_1008 = (net_751 & net_934);
  assign net_934 = (net_346 & net_973);
  assign sel_fad_a_neon_o[1] = (net_1009 & net_1010);
  assign net_129 = (net_108 & net_1011);
  assign net_108 = ~(net_902 | net_40);
  assign net_983 = (net_1012 & net_1013);
  assign net_1013 = ~(net_970 & net_1014);
  assign net_970 = (iq_instr_fn_i[6] & net_766);
  assign net_766 = ~(net_64 | net_40);
  assign net_751 = (net_1015 & net_3463);
  assign net_1012 = ~(net_390 & net_773);
  assign net_773 = (net_346 & net_1016);
  assign mul_fused_mac = ~(net_1017 & net_1018);
  assign net_1018 = (net_1019 & net_1020);
  assign net_1020 = ~(net_639 | net_1021);
  assign net_1021 = ~(net_6 | net_1022);
  assign net_1022 = (net_82 | net_37);
  assign net_1019 = (net_1023 | net_18);
  assign net_1023 = ~(net_1009 | net_1024);
  assign net_1024 = ~(net_1025 | iq_instr_fn_i[11]);
  assign net_1009 = ~(net_81 | net_991);
  assign net_1017 = (net_131 & net_1026);
  assign mul_divide = ~(net_1027 & net_727);
  assign net_727 = ~(iq_instr_fn_i[4] & net_824);
  assign net_824 = ~(net_421 | net_5);
  assign net_1027 = ~(mul_sqrt | net_1028);
  assign net_1028 = (net_133 & net_1029);
  assign mul_sqrt = ~(net_726 & net_1030);
  assign net_1030 = ~(net_10 & net_812);
  assign net_812 = ~(net_419 | net_76);
  assign net_726 = ~(iq_instr_fn_i[16] & net_816);
  assign net_816 = (iq_instr_fn_i[7] & net_1031);
  assign fp_xflag_src_neon[1] = (net_1032 | net_1033);
  assign net_1033 = (net_1034 | net_1035);
  assign net_1035 = (net_1036 | net_1037);
  assign net_1037 = (net_1038 | net_1039);
  assign net_1039 = (net_183 | net_1040);
  assign net_183 = (net_1041 | net_1042);
  assign net_1042 = (net_1043 | net_1044);
  assign net_1044 = (net_1045 | net_1046);
  assign net_1045 = (iq_instr_fn_i[18] & net_610);
  assign net_610 = (iq_instr_fn_i[11] & net_1047);
  assign net_1047 = (net_1048 & net_337);
  assign net_1041 = (iq_instr_fn_i[9] & net_1049);
  assign net_1049 = ~(net_1050 & net_1051);
  assign net_1050 = (net_1052 & net_1053);
  assign net_1053 = (net_3464 | net_598);
  assign net_1052 = (net_1054 & net_1055);
  assign net_1038 = ~(net_1056 & net_1057);
  assign net_1057 = ~(net_1058 & net_1059);
  assign net_1056 = (net_1060 | net_1061);
  assign net_1061 = (net_1062 & net_1063);
  assign net_1063 = (net_1064 | a64_only);
  assign net_1064 = ~(net_203 & net_1065);
  assign net_1062 = (net_1066 | iq_instr_fn_i[8]);
  assign net_1036 = (net_1067 | net_1068);
  assign net_1068 = (net_1069 | net_1070);
  assign net_1070 = (net_1071 | net_1072);
  assign net_1071 = (net_1073 | net_1074);
  assign net_1074 = (net_1075 | net_1076);
  assign net_1076 = (net_1077 | net_1078);
  assign net_1078 = ~(net_1079 & net_142);
  assign net_1073 = (net_1080 & net_1081);
  assign net_1081 = (net_1082 & net_1083);
  assign net_1069 = (net_3464 & net_1084);
  assign net_1084 = ~(net_1085 & net_1086);
  assign net_1086 = ~(net_1087 & net_346);
  assign net_1085 = (net_144 & net_1088);
  assign net_1088 = ~(net_703 & net_1089);
  assign net_1034 = (iq_instr_fn_i[9] & net_1090);
  assign net_1090 = ~(net_1091 & net_1092);
  assign net_1091 = ~(net_1093 | net_1094);
  assign net_1094 = ~(iq_instr_fn_i[11] | net_1095);
  assign fp_xflag_src_neon[0] = (net_1096 | net_1097);
  assign net_1097 = ~(net_1098 & net_1099);
  assign net_1099 = ~(net_120 | net_829);
  assign net_829 = (net_1100 | net_1101);
  assign net_1101 = (net_1048 & net_1102);
  assign net_1102 = ~(net_3463 | net_51);
  assign net_120 = (net_1048 & net_635);
  assign net_635 = (net_1103 & net_652);
  assign net_1098 = (net_1026 & net_1104);
  assign net_1104 = ~(net_435 & net_1105);
  assign net_1026 = ~(net_346 & net_133);
  assign net_133 = (net_867 & net_709);
  assign net_1096 = (net_323 | net_1106);
  assign net_1106 = (net_1107 | net_1108);
  assign net_1108 = ~(net_121 & net_131);
  assign net_131 = ~(iq_instr_fn_i[23] & net_1109);
  assign net_1109 = (net_104 & net_1110);
  assign net_1110 = (net_1111 | net_1112);
  assign net_1112 = (net_1113 & net_714);
  assign net_1111 = (a64_only & net_1114);
  assign net_1114 = ~(net_42 | net_3471);
  assign net_121 = (net_1115 & net_1116);
  assign net_1116 = (iq_instr_fn_i[10] | net_1025);
  assign net_1025 = ~(net_834 & net_12);
  assign net_1115 = (net_1117 & net_1118);
  assign net_1118 = (net_722 | net_528);
  assign net_528 = ~(net_649 & net_3470);
  assign net_722 = (iq_instr_fn_i[28] | iq_instr_fn_i[4]);
  assign net_1117 = (net_1005 & net_1119);
  assign net_1119 = (net_1120 & net_1121);
  assign net_1121 = (net_1122 | iq_instr_fn_i[4]);
  assign net_1122 = ~(net_703 & net_3469);
  assign net_1120 = ~(mul_neon_sat_dbl | net_639);
  assign mul_neon_sat_dbl = ~(net_962 & net_1123);
  assign net_1123 = (net_939 & net_882);
  assign net_882 = ~(net_104 & net_1124);
  assign net_1124 = (net_551 & net_556);
  assign net_939 = (net_464 | net_1125);
  assign net_1125 = ~(net_346 & net_423);
  assign net_423 = ~(net_47 | net_3464);
  assign net_962 = (net_1126 & net_887);
  assign net_887 = ~(net_3463 & net_1127);
  assign net_1127 = (iq_instr_fn_i[8] & net_1128);
  assign net_1128 = (net_916 | net_1129);
  assign net_1129 = ~(net_924 | net_1130);
  assign net_916 = (net_1131 & net_3469);
  assign net_1126 = (net_920 & net_850);
  assign net_850 = ~(net_926 & net_3466);
  assign net_926 = ~(net_67 | net_1130);
  assign net_1130 = ~(net_942 & net_1132);
  assign net_920 = (net_1133 & net_849);
  assign net_849 = ~(net_1016 & net_1105);
  assign net_1105 = ~(net_83 | iq_instr_fn_i[21]);
  assign net_1133 = (net_863 & net_1134);
  assign net_1134 = (net_464 | net_1135);
  assign net_1135 = ~(net_973 & net_749);
  assign net_863 = ~(net_923 & net_436);
  assign net_1005 = ~(net_261 & net_1136);
  assign net_1136 = ~(net_464 | net_769);
  assign net_769 = (net_3464 | net_44);
  assign net_464 = ~(net_774 & net_1015);
  assign net_323 = ~(net_83 | net_991);
  assign fp_cflag_src_neon = (net_1137 & net_75);
  assign net_1137 = (net_1138 & net_1139);
  assign net_1138 = ~(net_1140 | iq_instr_fn_i[19]);
  assign force_dn_fz = (net_188 | net_1141);
  assign net_1141 = (net_1142 | net_1143);
  assign net_1143 = (net_622 | net_1144);
  assign net_1144 = (net_1145 | net_1146);
  assign net_1145 = (net_580 | net_1147);
  assign net_1147 = (net_628 | net_1148);
  assign net_1148 = ~(net_1149 & net_1150);
  assign net_1149 = ~(net_570 | net_1151);
  assign net_1151 = (net_653 & net_1152);
  assign net_1152 = ~(net_59 | net_1153);
  assign net_628 = (net_1100 | net_1154);
  assign net_1154 = (net_1155 | net_1107);
  assign net_1107 = (net_759 & net_1010);
  assign net_1010 = (net_23 | aarch64_state_i);
  assign net_1155 = (net_1156 & net_3466);
  assign net_1156 = (net_1157 | net_1158);
  assign net_1158 = ~(net_1159 & net_1160);
  assign net_1160 = ~(net_473 & net_82);
  assign net_473 = ~(net_3465 | net_859);
  assign net_1159 = (net_787 & net_1161);
  assign net_1161 = (net_3463 | net_1162);
  assign net_1162 = (net_31 | net_51);
  assign net_787 = ~(net_759 | net_1163);
  assign net_1163 = (net_868 & net_435);
  assign net_759 = ~(net_82 | net_991);
  assign net_1100 = ~(net_81 | net_859);
  assign net_859 = ~(net_1016 & net_942);
  assign net_580 = (net_774 & net_1164);
  assign net_1164 = ~(net_1165 & net_1166);
  assign net_1166 = ~(net_1167 & net_894);
  assign net_1165 = (net_1168 & net_322);
  assign net_1168 = (net_1169 & net_1170);
  assign net_1170 = ~(net_1171 & net_1029);
  assign net_1169 = ~(net_1172 & net_1173);
  assign net_1142 = ~(net_1174 & net_1175);
  assign net_1175 = ~(net_1176 & iq_instr_fn_i[16]);
  assign net_1176 = (net_1048 & net_1103);
  assign net_1174 = (net_1177 & net_1178);
  assign net_1177 = ~(net_1179 & net_1180);
  assign net_1179 = ~(net_3465 & net_1181);
  assign net_1181 = (a64_only | net_1182);
  assign net_188 = ~(net_1183 & net_1184);
  assign net_1183 = ~(net_1185 & net_3466);
  assign crypto_op[3] = ~(net_1186 & net_1187);
  assign net_1187 = ~(net_1188 & net_1189);
  assign net_1188 = (net_481 & net_1190);
  assign net_1186 = (net_1191 | net_351);
  assign crypto_op[2] = ~(net_1192 & net_1193);
  assign net_1193 = (net_1194 | net_1195);
  assign net_1194 = (net_9 | net_3471);
  assign net_1192 = (net_1196 & net_1197);
  assign net_1197 = (net_1198 & net_1199);
  assign net_1199 = ~(net_1200 & net_1201);
  assign net_1201 = ~(net_92 | net_1202);
  assign net_1198 = ~(net_1203 & net_1204);
  assign net_1204 = (net_1205 & net_1206);
  assign net_1203 = (aes_op_merged_iss_i & net_260);
  assign crypto_op[1] = (net_1207 | net_1208);
  assign net_1208 = ~(net_1209 & net_1210);
  assign net_1210 = (iq_instr_fn_i[20] | net_1211);
  assign net_1211 = (net_1051 | iq_instr_fn_i[9]);
  assign net_1207 = (net_260 & net_1212);
  assign net_1212 = (net_1190 & net_55);
  assign net_1190 = ~(net_3466 | net_1213);
  assign crypto_op[0] = ~(net_1214 & net_1215);
  assign net_1215 = ~(net_1216 & net_1217);
  assign net_1217 = ~(net_1218 | net_77);
  assign net_1216 = (net_260 & net_1016);
  assign net_1214 = (net_1209 & net_1219);
  assign net_1219 = (net_64 | net_1191);
  assign net_1191 = ~(net_252 & net_1220);
  assign net_1209 = (net_1196 & net_1221);
  assign net_1221 = (net_1222 | net_1223);
  assign net_1223 = ~(net_431 & net_481);
  assign net_1222 = ~(net_1205 & net_3464);
  assign net_1196 = ~(net_1224 & net_3471);
  assign net_1224 = (net_1225 & net_1226);
  assign net_1226 = (net_361 & iq_instr_fn_i[9]);
  assign net_1225 = ~(net_67 | iq_instr_fn_i[20]);
  assign add_vector_fp_op = ~(net_1227 & net_1228);
  assign net_1228 = ~(net_179 | net_1229);
  assign net_1229 = (net_1230 | net_1231);
  assign net_1231 = ~(net_1232 & net_1233);
  assign net_1232 = (net_1234 & net_1235);
  assign net_1235 = (sf_bit | net_1236);
  assign net_1236 = (net_1237 & net_1238);
  assign net_1238 = (net_1239 & net_1240);
  assign net_1240 = (net_1241 | net_1242);
  assign net_1239 = (net_1243 | net_81);
  assign net_1237 = (net_1244 & net_1245);
  assign net_1245 = ~(net_201 & net_75);
  assign net_1244 = (net_1246 & net_1247);
  assign net_1247 = (net_1248 & net_1249);
  assign net_1249 = ~(iq_instr_fn_i[24] & net_1250);
  assign net_1248 = (net_1251 & net_1252);
  assign net_1252 = (net_1253 | iq_instr_fn_i[9]);
  assign net_1253 = (net_1254 & net_1255);
  assign net_1255 = ~(iq_instr_fn_i[25] & net_1256);
  assign net_1254 = ~(net_206 & net_75);
  assign net_1251 = (net_1257 & net_1258);
  assign net_1258 = ~(net_1259 & net_1260);
  assign net_1260 = (net_351 & net_95);
  assign net_1257 = ~(net_1261 & net_78);
  assign net_1261 = (net_1014 & net_206);
  assign net_1246 = ~(net_1262 | net_1263);
  assign net_1263 = (iq_instr_fn_i[25] & net_1264);
  assign net_1264 = ~(net_1265 | iq_instr_fn_i[11]);
  assign net_1234 = (net_1266 & net_1267);
  assign net_1267 = (net_1268 | iq_instr_fn_i[9]);
  assign net_1266 = ~(net_1269 | net_1270);
  assign net_1270 = (net_1271 | net_1272);
  assign net_1272 = ~(net_1273 & net_1274);
  assign net_1274 = (net_625 & net_1275);
  assign net_1275 = ~(net_1276 | net_1277);
  assign net_1277 = (net_284 | net_1278);
  assign net_1278 = ~(net_1279 & net_1280);
  assign net_1279 = (net_1281 & net_1282);
  assign net_1282 = ~(net_1283 & net_261);
  assign net_1281 = ~(net_1284 & net_1285);
  assign net_1284 = ~(net_37 | net_1286);
  assign net_284 = (net_1048 & net_1287);
  assign net_1269 = (net_1288 | net_1289);
  assign net_1289 = (net_1290 | add_neon_mux_sel[2]);
  assign net_1290 = (net_277 & net_3468);
  assign net_277 = (net_55 & net_1259);
  assign net_1288 = ~(net_1291 & net_1292);
  assign net_1292 = ~(net_252 & net_1293);
  assign net_1291 = (net_1294 & net_1295);
  assign net_1294 = (net_1296 & net_1297);
  assign net_1297 = ~(net_1298 & net_1299);
  assign net_1299 = (net_1300 & net_1250);
  assign net_1230 = (net_3466 & net_1301);
  assign net_1301 = (net_1302 | net_1303);
  assign net_1303 = ~(net_1304 & net_1305);
  assign net_179 = ~(net_1306 & net_1307);
  assign net_1307 = (net_1308 & net_1309);
  assign net_1309 = (iq_instr_fn_i[9] | net_1310);
  assign net_1310 = (net_1311 & net_1312);
  assign net_1306 = (net_1313 & net_1314);
  assign net_1314 = ~(net_1315 & net_1316);
  assign net_1315 = (net_1058 & net_1317);
  assign net_1313 = (net_1318 | net_85);
  assign net_1318 = ~(net_206 & net_1319);
  assign net_1319 = ~(sf_bit | net_1320);
  assign net_1320 = ~(iq_instr_fn_i[9] & iq_instr_fn_i[17]);
  assign add_neon_width_op_sel[2] = ~(net_1321 & net_1322);
  assign net_1322 = (net_1323 & net_1324);
  assign net_1324 = ~(net_1325 & net_1326);
  assign net_1326 = ~(net_1327 | net_57);
  assign net_1323 = (net_1328 & net_1329);
  assign net_1329 = ~(net_256 & net_3465);
  assign net_1328 = ~(net_1330 | net_267);
  assign add_neon_width_op_sel[1] = ~(net_1331 & net_1332);
  assign net_1332 = (net_1333 & net_1334);
  assign net_1334 = (net_64 | net_1335);
  assign net_1333 = (net_1336 & net_1337);
  assign net_1337 = (net_1338 & net_1339);
  assign net_1339 = (net_1340 | net_1341);
  assign net_1338 = (net_1342 & net_1321);
  assign net_1321 = (net_1343 & net_1273);
  assign net_1273 = ~(net_1220 & net_1344);
  assign net_1342 = (net_328 & net_1345);
  assign net_1345 = ~(net_1346 & net_1347);
  assign net_1347 = (net_551 & net_3468);
  assign add_neon_width_op_sel[0] = ~(net_1348 & net_1349);
  assign net_1348 = ~(net_1350 | net_1351);
  assign net_1351 = ~(net_1352 & net_585);
  assign net_1352 = ~(net_256 | net_1353);
  assign net_1353 = ~(net_1354 & net_1355);
  assign net_1355 = (net_1356 & net_1357);
  assign net_1354 = (net_1331 & net_1358);
  assign net_1358 = (net_338 | net_86);
  assign net_338 = (net_8 | net_91);
  assign net_1331 = ~(net_1276 | net_1359);
  assign net_1359 = ~(net_1360 & net_1361);
  assign net_1361 = ~(net_1362 & net_1363);
  assign net_1360 = (net_1364 & net_1365);
  assign add_neon_vtb_cycle = (net_1366 | net_1367);
  assign net_1367 = (net_1368 | net_1369);
  assign net_1369 = (net_160 | net_1370);
  assign net_1370 = ~(net_1371 & net_1372);
  assign net_1372 = (net_1373 | net_1374);
  assign net_160 = (iq_instr_fn_i[11] & net_1375);
  assign net_1375 = (net_1376 & net_1377);
  assign net_1377 = ~(net_1378 & net_1379);
  assign net_1379 = ~(net_1380 & net_3467);
  assign net_1380 = (net_1381 & net_1382);
  assign net_1382 = ~(net_3466 | net_59);
  assign net_1381 = (net_907 & net_1383);
  assign net_1378 = ~(iq_instr_fn_i[8] & net_1384);
  assign net_1384 = ~(net_48 | net_1385);
  assign add_neon_unsigned_op = (net_1386 | net_1387);
  assign net_1387 = (net_1388 | net_1389);
  assign net_1389 = (net_1390 | net_1391);
  assign net_1391 = (net_1392 | net_1393);
  assign net_1393 = (net_1394 | net_1395);
  assign net_1395 = (net_263 & net_1396);
  assign net_1396 = ~(net_58 | net_1397);
  assign net_1394 = (iq_instr_fn_i[28] & net_1398);
  assign net_1398 = (net_1399 & net_1400);
  assign net_1400 = (iq_instr_fn_i[7] | net_1401);
  assign net_1401 = ~(net_3470 | net_3466);
  assign net_1392 = (net_3468 & net_1402);
  assign net_1402 = (net_1403 | net_1404);
  assign net_1404 = (net_1405 & net_62);
  assign net_1403 = ~(net_1406 & net_1407);
  assign net_1407 = (net_34 | net_1408);
  assign net_1406 = ~(net_1409 | net_1410);
  assign net_1410 = (net_1411 | net_1412);
  assign net_1412 = (net_1413 & net_1414);
  assign net_1414 = (net_1415 & net_1089);
  assign net_1413 = (net_1259 & net_75);
  assign net_1411 = (net_1376 & net_1416);
  assign net_1416 = ~(net_1417 | net_1418);
  assign net_1409 = (net_25 & net_1419);
  assign net_1419 = (net_1420 | net_347);
  assign net_1390 = (net_1421 & net_3464);
  assign net_1421 = (net_633 & net_1422);
  assign net_1422 = (net_1423 | net_1424);
  assign net_1424 = (net_346 & net_456);
  assign net_456 = ~(net_59 | net_87);
  assign net_1423 = ~(net_1425 & net_1426);
  assign net_1426 = ~(net_365 & net_1346);
  assign net_1425 = ~(net_867 & net_1427);
  assign net_1388 = (net_1428 | net_1429);
  assign net_1429 = (net_1430 | net_1431);
  assign net_1431 = (net_155 | net_1432);
  assign net_1432 = ~(net_1433 & net_1434);
  assign net_1434 = ~(net_1435 & net_1436);
  assign net_1435 = (net_578 & net_1437);
  assign net_1437 = (net_652 | net_1438);
  assign net_1438 = (net_241 & iq_instr_fn_i[18]);
  assign net_1433 = ~(net_1439 | net_1440);
  assign net_1440 = (net_261 & net_1441);
  assign net_155 = (net_1442 & net_1443);
  assign net_1443 = ~(net_79 | net_66);
  assign net_1442 = (net_1444 & net_1445);
  assign net_1445 = (iq_instr_fn_i[24] & net_1446);
  assign net_1446 = (net_1447 | net_1448);
  assign net_1448 = ~(net_59 | net_1449);
  assign net_1430 = (net_431 & net_1450);
  assign net_1450 = (net_1451 | net_1452);
  assign net_1452 = (net_1453 | net_1454);
  assign net_1454 = (net_536 & net_1455);
  assign net_1453 = (net_61 & net_1456);
  assign net_1456 = ~(net_46 | net_31);
  assign net_1451 = (iq_instr_fn_i[6] & net_1457);
  assign net_1457 = (net_1458 & net_1415);
  assign net_1428 = (net_1459 | net_1460);
  assign net_1460 = (net_1461 | net_1462);
  assign net_1462 = (net_1463 | net_1464);
  assign net_1463 = (net_169 & iq_instr_fn_i[20]);
  assign net_169 = (net_1465 & net_50);
  assign net_1461 = ~(net_1466 & net_1467);
  assign net_1467 = ~(iq_instr_fn_i[21] & net_1468);
  assign net_1468 = (net_576 | net_1469);
  assign net_1469 = (net_1470 | net_688);
  assign net_688 = (net_649 & net_674);
  assign net_1470 = (net_1455 & net_653);
  assign net_1466 = (net_36 | net_1471);
  assign net_1459 = (net_1363 & net_1472);
  assign net_1472 = (net_1473 | net_1474);
  assign net_1474 = (net_1475 | net_1362);
  assign net_1362 = ~(net_75 | net_308);
  assign net_1475 = (iq_instr_fn_i[7] & net_1476);
  assign net_1476 = (net_1250 | net_1477);
  assign net_1473 = ~(net_1478 & net_1479);
  assign net_1479 = ~(net_1480 & net_61);
  assign net_1478 = ~(net_347 & net_312);
  assign net_1386 = (net_549 & net_1481);
  assign net_1481 = (net_1482 | net_1483);
  assign net_1482 = (net_1484 | net_1485);
  assign net_1485 = ~(net_1486 & net_1487);
  assign net_1487 = ~(net_1205 & net_1488);
  assign net_1486 = ~(net_1259 & net_836);
  assign net_1484 = (iq_instr_fn_i[4] & net_1489);
  assign net_1489 = ~(net_1218 | net_42);
  assign add_neon_size_sel[1] = (net_1490 | net_1040);
  assign net_1040 = (net_1491 | net_1492);
  assign net_1492 = ~(net_1493 & net_1494);
  assign net_1494 = (net_585 & net_282);
  assign net_1493 = (net_218 & net_1184);
  assign net_1490 = ~(net_1495 & net_1496);
  assign net_1496 = (net_1497 & net_1498);
  assign net_1498 = ~(iq_instr_fn_i[8] & net_1499);
  assign net_1499 = ~(net_1500 & net_1501);
  assign net_1500 = (net_1502 & net_1503);
  assign net_1503 = ~(net_1504 & net_1505);
  assign net_1502 = ~(net_1506 & net_78);
  assign net_1497 = ~(iq_instr_fn_i[9] & net_1507);
  assign net_1507 = ~(net_1508 & net_1509);
  assign net_1509 = (net_1510 & net_1511);
  assign net_1510 = (net_1512 & net_1513);
  assign net_1513 = (net_1514 | net_1515);
  assign net_1514 = (net_1516 | net_79);
  assign net_1508 = (net_1517 & net_1051);
  assign net_1495 = (net_1518 & net_1519);
  assign net_1519 = (net_1520 & net_1521);
  assign net_1521 = (net_1522 & net_1523);
  assign net_1523 = ~(net_1524 | net_1525);
  assign net_1524 = ~(net_1526 & net_1527);
  assign net_1527 = (net_509 & net_1528);
  assign net_1528 = ~(net_1089 & net_1529);
  assign net_1529 = ~(net_1530 & net_8);
  assign net_1530 = (net_1531 | iq_instr_fn_i[11]);
  assign net_1531 = (net_1532 | iq_instr_fn_i[17]);
  assign net_1532 = (net_31 | net_72);
  assign net_509 = (net_1533 & net_1534);
  assign net_1534 = (net_1535 & net_1536);
  assign net_1533 = (net_1537 & net_1538);
  assign net_1537 = (net_1539 & net_1540);
  assign net_1540 = (net_1541 | net_1542);
  assign net_1542 = ~(net_3470 | net_3464);
  assign net_1522 = ~(net_3466 & net_1543);
  assign net_1543 = ~(net_1544 & net_1545);
  assign net_1545 = ~(net_206 & net_59);
  assign net_206 = (net_250 & net_1089);
  assign net_1544 = (net_1546 & net_1547);
  assign net_1547 = (net_1548 | net_1471);
  assign net_1546 = ~(net_1549 | net_469);
  assign net_469 = ~(net_1550 & net_1150);
  assign net_1150 = ~(net_637 & net_1551);
  assign net_1550 = (net_1552 & net_1553);
  assign net_1553 = ~(net_839 & net_1554);
  assign net_1552 = (net_1555 & net_1556);
  assign net_1556 = (net_1557 & net_1558);
  assign net_1558 = ~(net_1559 & iq_instr_fn_i[18]);
  assign net_1557 = ~(net_1560 & net_1561);
  assign net_1561 = ~(net_46 | net_28);
  assign net_1555 = ~(net_1157 | net_1562);
  assign net_1562 = (net_730 & net_1563);
  assign net_1563 = (iq_instr_fn_i[21] & net_127);
  assign net_1520 = ~(net_1564 & net_671);
  assign net_671 = (iq_instr_fn_i[5] & iq_instr_fn_i[22]);
  assign net_1518 = (net_1565 & net_1566);
  assign net_1566 = (iq_instr_fn_i[5] | net_1567);
  assign net_1567 = (iq_instr_fn_i[22] | net_1568);
  assign net_1568 = ~(net_1569 | net_1570);
  assign net_1570 = (iq_instr_fn_i[20] & net_1571);
  assign net_1565 = (net_1572 & net_1573);
  assign net_1573 = (net_1574 & net_1575);
  assign net_1575 = ~(net_1464 | net_1576);
  assign net_1576 = (net_1577 & net_1578);
  assign net_1578 = (net_1579 & net_837);
  assign net_1464 = (net_1580 & net_578);
  assign net_1574 = ~(iq_instr_fn_i[21] & net_1581);
  assign net_1581 = (net_228 | net_1582);
  assign net_1582 = ~(net_1583 & net_1584);
  assign net_1584 = ~(net_1585 & net_673);
  assign net_1583 = ~(net_1586 & net_250);
  assign net_1586 = ~(iq_instr_fn_i[11] | net_1587);
  assign net_1587 = ~(net_104 & net_1588);
  assign net_1588 = ~(iq_instr_fn_i[4] | net_1589);
  assign net_1572 = ~(net_1590 | net_1591);
  assign net_1590 = ~(net_1592 & net_1593);
  assign net_1593 = (net_1594 & net_1595);
  assign net_1595 = (net_1596 & net_1597);
  assign net_1597 = ~(net_109 & net_1598);
  assign net_1598 = ~(net_1385 | net_65);
  assign net_1596 = ~(net_643 & net_1599);
  assign net_1599 = (net_1415 | net_1600);
  assign net_1594 = (net_1601 & net_1602);
  assign net_1602 = ~(net_1366 | net_1603);
  assign net_1603 = (net_95 & net_1604);
  assign net_1604 = ~(net_1605 & net_1606);
  assign net_1606 = ~(net_643 & net_1607);
  assign net_1605 = (net_1541 & net_1608);
  assign net_1608 = ~(net_1609 & iq_instr_fn_i[19]);
  assign net_1609 = (net_1610 | net_1611);
  assign net_1611 = (net_1612 & net_431);
  assign net_1366 = (net_1613 | net_1614);
  assign net_1614 = (net_351 & net_1615);
  assign net_1613 = (net_161 & net_1616);
  assign net_1616 = ~(decoder_fsm_i[0] & net_1374);
  assign net_1601 = (net_1617 & net_1618);
  assign net_1618 = (iq_instr_fn_i[18] | net_1541);
  assign net_1617 = (net_287 & net_1619);
  assign net_1619 = (net_1620 & net_1621);
  assign net_1621 = ~(net_347 & net_1622);
  assign net_1620 = (net_2 & net_600);
  assign net_600 = ~(net_570 | net_1623);
  assign net_1623 = ~(net_596 & net_1624);
  assign net_1624 = (net_519 & net_1625);
  assign net_519 = ~(net_923 & net_1167);
  assign net_1167 = ~(net_64 | net_82);
  assign net_287 = (net_51 | net_1626);
  assign net_1626 = (iq_instr_fn_i[20] | net_1627);
  assign net_1627 = ~(net_774 & net_263);
  assign net_637 = ~(net_67 | iq_instr_fn_i[23]);
  assign net_1592 = ~(iq_instr_fn_i[7] & net_1628);
  assign net_1628 = ~(net_1629 & net_1630);
  assign net_1630 = ~(iq_instr_fn_i[10] & net_342);
  assign net_1629 = (net_1631 & net_1632);
  assign net_1632 = ~(net_1633 & net_1634);
  assign net_1634 = ~(net_34 | net_71);
  assign net_1631 = (net_1635 & net_1636);
  assign net_1636 = (net_48 | net_1637);
  assign net_1637 = (net_1638 & net_1639);
  assign net_1639 = (net_45 | net_410);
  assign net_1638 = ~(net_3465 & net_1250);
  assign net_1635 = ~(iq_instr_fn_i[19] & net_643);
  assign add_neon_size_sel[0] = (net_1640 | net_1641);
  assign net_1641 = (net_1642 | net_1643);
  assign net_1643 = (net_1644 | net_1645);
  assign net_1645 = (net_1646 | net_1647);
  assign net_1647 = (net_1648 | net_1649);
  assign net_1648 = (net_774 & net_1650);
  assign net_1650 = ~(net_81 | net_3);
  assign net_1646 = (iq_instr_fn_i[20] & net_1651);
  assign net_1651 = (net_1652 | net_1653);
  assign net_1653 = ~(net_1654 & net_1655);
  assign net_1655 = (net_924 | net_9);
  assign net_1654 = ~(net_1656 | net_1657);
  assign net_1657 = ~(net_1658 & net_1659);
  assign net_1659 = ~(net_836 & net_1660);
  assign net_1660 = (net_1661 | net_1662);
  assign net_1662 = (net_1663 | net_1664);
  assign net_1664 = (net_1665 & net_1666);
  assign net_1666 = (net_250 & iq_instr_fn_i[11]);
  assign net_1665 = (net_347 & net_3465);
  assign net_1663 = (net_771 & net_261);
  assign net_1661 = (net_1667 & net_1668);
  assign net_1668 = (iq_instr_fn_i[27] & net_3468);
  assign net_1667 = (net_1420 & net_3466);
  assign net_1658 = ~(net_1669 & net_1131);
  assign net_1131 = (net_16 & net_436);
  assign net_1656 = (net_1670 & net_3466);
  assign net_1670 = (iq_instr_fn_i[25] & net_1256);
  assign net_1652 = ~(iq_instr_fn_i[22] | net_1671);
  assign net_1671 = ~(net_1672 & net_549);
  assign net_1672 = ~(net_1673 & net_1674);
  assign net_1674 = ~(net_342 & iq_instr_fn_i[6]);
  assign net_1673 = ~(net_1675 & net_1669);
  assign net_1675 = ~(net_421 | net_1676);
  assign net_1676 = ~(iq_instr_fn_i[5] & net_347);
  assign net_1644 = (net_1677 | net_1678);
  assign net_1678 = (net_1679 | net_1680);
  assign net_1679 = (net_347 & net_1681);
  assign net_1677 = ~(net_1682 & net_1683);
  assign net_1683 = (net_1684 | net_1685);
  assign net_1685 = ~(net_109 & net_1686);
  assign net_1682 = ~(sf_bit & net_1687);
  assign net_1642 = (iq_instr_fn_i[9] & net_1688);
  assign net_1688 = (net_1689 | net_1690);
  assign net_1690 = ~(net_1691 & net_1692);
  assign net_1692 = (net_6 | net_36);
  assign net_1640 = (net_1693 | net_1694);
  assign net_1694 = (net_1695 | net_1696);
  assign net_1696 = (net_1697 | net_1698);
  assign net_1698 = ~(net_1699 & net_1700);
  assign net_1700 = ~(net_1701 | net_1702);
  assign net_1701 = (net_346 & net_1703);
  assign net_1703 = ~(net_1704 & net_1705);
  assign net_1705 = (net_1706 & net_1335);
  assign net_1706 = ~(net_1707 | net_1708);
  assign net_1708 = ~(net_1709 & net_1710);
  assign net_1710 = ~(net_252 & net_923);
  assign net_1709 = (net_1711 & net_1712);
  assign net_1712 = ~(net_361 & net_3468);
  assign net_1711 = (net_1713 & net_1714);
  assign net_1697 = (net_1715 | net_1716);
  assign net_1716 = (net_1717 | net_1718);
  assign net_1718 = (net_1719 | net_729);
  assign net_1719 = (net_1720 & net_1721);
  assign net_1717 = (net_1722 | net_1723);
  assign net_1723 = (net_1724 | net_1075);
  assign net_1724 = (iq_instr_fn_i[8] & net_1725);
  assign net_1722 = ~(net_1726 & net_1727);
  assign net_1727 = ~(net_1728 & net_351);
  assign net_1728 = (net_1729 & net_1730);
  assign net_1730 = ~(net_92 | net_74);
  assign net_1729 = (net_263 & net_3467);
  assign net_1726 = ~(net_205 & net_1731);
  assign net_205 = (aarch64_state_i & net_118);
  assign net_1715 = (net_72 & net_1732);
  assign net_1732 = (net_643 & net_481);
  assign net_1695 = (net_1089 & net_1733);
  assign net_1733 = (iq_instr_fn_i[18] & net_1734);
  assign net_1734 = (net_1735 | net_1736);
  assign net_1736 = ~(net_72 | net_1153);
  assign net_1153 = ~(net_1737 & net_78);
  assign net_1735 = (net_1738 | net_1739);
  assign net_1739 = (net_1740 | net_1741);
  assign net_1741 = ~(net_87 | net_34);
  assign net_1740 = (net_1001 & net_1742);
  assign net_1742 = (net_1743 & net_1744);
  assign net_1738 = (net_3468 & net_1745);
  assign net_1745 = (net_1746 | net_213);
  assign net_213 = ~(net_34 | iq_instr_fn_i[9]);
  assign net_1746 = (net_1747 & net_1748);
  assign net_1748 = ~(net_3466 & net_78);
  assign net_1747 = ~(iq_instr_fn_i[17] | net_31);
  assign net_1693 = ~(net_1749 & net_1526);
  assign net_1526 = ~(net_253 | net_1750);
  assign net_1750 = ~(iq_instr_fn_i[6] | net_1751);
  assign net_1749 = (net_1752 & net_1753);
  assign net_1753 = ~(net_1564 & iq_instr_fn_i[5]);
  assign net_1752 = ~(net_1754 | net_1755);
  assign net_1755 = ~(net_1756 & net_1757);
  assign net_1757 = (net_1758 & net_1759);
  assign net_1758 = ~(net_1760 | net_1761);
  assign net_1761 = ~(net_1762 & net_1763);
  assign net_1763 = (net_95 | net_148);
  assign net_148 = ~(net_261 & net_342);
  assign net_1762 = ~(net_203 & net_1764);
  assign net_1764 = ~(net_1765 & net_1766);
  assign net_1766 = (net_1767 & net_1768);
  assign net_1768 = ~(net_202 | net_1769);
  assign net_1769 = (net_1577 & net_1770);
  assign net_1770 = ~(net_30 | net_74);
  assign net_1577 = ~(iq_instr_fn_i[7] & vd_eq_vm);
  assign net_202 = ~(net_3468 | net_8);
  assign net_1767 = (net_4 | net_1771);
  assign net_1771 = (net_1772 | net_79);
  assign net_1772 = (iq_instr_fn_i[9] & net_1139);
  assign net_1139 = ~(net_74 | aarch64_state_i);
  assign net_1765 = (net_1773 | net_420);
  assign net_1773 = (net_1774 & net_1775);
  assign net_1775 = ~(net_1065 & iq_instr_fn_i[19]);
  assign net_1065 = (net_1743 & net_74);
  assign net_1743 = ~(net_18 | iq_instr_fn_i[17]);
  assign net_1774 = (net_1776 & net_1777);
  assign net_1777 = (net_1778 | iq_instr_fn_i[18]);
  assign net_1776 = (net_73 & net_524);
  assign net_203 = ~(net_66 | net_91);
  assign net_1756 = (net_1779 & net_1780);
  assign net_1780 = (net_1781 | iq_instr_fn_i[9]);
  assign net_1779 = (net_1296 & net_1782);
  assign net_1296 = ~(net_1783 | net_1784);
  assign net_1784 = ~(net_328 & net_1785);
  assign net_328 = (iq_instr_fn_i[9] | net_1786);
  assign add_neon_sat_op_sel[1] = ~(net_1356 & net_1787);
  assign net_1787 = (net_1788 & net_1789);
  assign net_1789 = (iq_instr_fn_i[8] | net_1790);
  assign net_1790 = ~(net_1791 & net_263);
  assign net_1788 = (net_1792 & net_1793);
  assign net_1793 = (net_1794 & net_1795);
  assign net_1794 = ~(net_1077 | add_neon_vtst_op_sel);
  assign net_1077 = (net_3466 & net_1796);
  assign net_1796 = (net_1797 | net_1798);
  assign net_1797 = ~(iq_instr_fn_i[28] | net_1799);
  assign net_1799 = ~(net_435 & net_261);
  assign net_1792 = (net_1800 & net_144);
  assign net_1800 = ~(net_1801 | net_1802);
  assign net_1802 = ~(net_314 | net_1803);
  assign net_1803 = ~(net_1804 & net_346);
  assign net_314 = (net_17 | net_84);
  assign net_1356 = (net_1805 & net_1806);
  assign net_1806 = ~(net_1087 & net_996);
  assign add_neon_sat_op_sel[0] = ~(net_1807 & net_1808);
  assign net_1808 = (net_3466 | net_1809);
  assign net_1807 = ~(net_1810 | net_1811);
  assign net_1811 = (net_1043 | net_1812);
  assign net_1812 = (add_neon_vtst_op_sel | net_1813);
  assign net_1813 = ~(net_1814 & net_1815);
  assign net_1815 = (net_1816 & net_1817);
  assign net_1817 = (net_80 | net_1818);
  assign net_1818 = (net_1819 | net_1820);
  assign net_1819 = ~(net_1405 | net_1821);
  assign net_1821 = (net_342 & net_3465);
  assign net_1405 = (net_633 & net_1822);
  assign net_1822 = (net_1804 & net_347);
  assign net_1816 = (net_1782 & net_1823);
  assign net_1823 = ~(net_1824 | net_1825);
  assign net_1825 = ~(net_1826 & net_1827);
  assign net_1827 = (net_54 | net_1828);
  assign net_1828 = ~(net_1829 & net_1830);
  assign net_1830 = (net_1415 & net_739);
  assign net_739 = (net_3465 & net_3467);
  assign net_1829 = (net_263 & iq_instr_fn_i[6]);
  assign net_1826 = (net_1831 & net_1832);
  assign net_1832 = ~(net_1798 & net_3466);
  assign net_1798 = (net_1833 & net_25);
  assign net_1831 = (net_30 | net_1834);
  assign net_1834 = ~(iq_instr_fn_i[7] & net_1477);
  assign net_1782 = (net_1835 | net_1397);
  assign net_1835 = (net_1836 & net_1837);
  assign net_1837 = ~(net_263 & net_1804);
  assign net_1836 = ~(net_1838 & net_1839);
  assign net_1814 = (net_1840 & net_1841);
  assign net_1841 = ~(iq_instr_fn_i[28] & net_257);
  assign add_neon_perm_sel[3] = ~(net_1842 & net_1843);
  assign net_1842 = ~(net_1262 | net_1844);
  assign net_1844 = ~(net_1845 & net_1846);
  assign net_1846 = (net_1847 & net_135);
  assign net_135 = (net_1848 & net_1849);
  assign net_1849 = (net_1850 | net_59);
  assign net_1850 = (net_1851 & net_1852);
  assign net_1852 = ~(net_674 & net_1853);
  assign net_1851 = (net_1854 & net_1855);
  assign net_1855 = (net_1856 & net_1857);
  assign net_1857 = (a64_only | net_1858);
  assign net_1858 = ~(net_1859 & net_1089);
  assign net_1856 = (net_1860 | net_3466);
  assign net_1860 = (net_1861 & net_1862);
  assign net_1862 = (net_1863 & net_1864);
  assign net_1864 = (net_1865 & net_1866);
  assign net_1866 = ~(net_1579 & net_1867);
  assign net_1867 = (net_674 & net_1868);
  assign net_1865 = ~(net_1869 & net_1833);
  assign net_1863 = (net_1870 | net_3463);
  assign net_1870 = ~(net_1871 | net_1872);
  assign net_1872 = ~(net_47 | net_1873);
  assign net_1861 = (net_1874 & net_1875);
  assign net_1875 = (net_82 | net_1876);
  assign net_1874 = (net_95 | net_1877);
  assign net_1877 = ~(iq_instr_fn_i[26] & net_1833);
  assign net_1854 = (net_1878 | net_3463);
  assign net_1878 = (net_1879 & net_1880);
  assign net_1880 = ~(iq_instr_fn_i[21] & net_1881);
  assign net_1879 = (net_1882 & net_1883);
  assign net_1883 = ~(net_1884 & net_346);
  assign net_1882 = (net_1885 & net_1886);
  assign net_1886 = (net_1887 & net_1888);
  assign net_1888 = (net_1397 | net_24);
  assign net_1887 = ~(net_436 & net_61);
  assign net_1885 = (net_1889 | net_147);
  assign net_1889 = (net_1890 & net_1891);
  assign net_1891 = (net_1892 | net_21);
  assign net_1892 = ~(iq_instr_fn_i[26] & net_1344);
  assign net_1890 = ~(net_1893 & net_1082);
  assign net_1848 = (net_1894 & net_1895);
  assign net_1895 = ~(net_3466 & net_1896);
  assign net_1896 = (net_1897 | net_1898);
  assign net_1898 = ~(net_1781 & net_1899);
  assign net_1899 = ~(net_839 & net_1900);
  assign net_1894 = ~(add_neon_mask_sel | net_1901);
  assign net_1847 = ~(net_1902 | net_1903);
  assign net_1903 = ~(net_1904 & net_1905);
  assign net_1905 = (net_41 | net_1906);
  assign net_1906 = ~(net_1907 & net_1908);
  assign net_1907 = ~(iq_instr_fn_i[24] | iq_instr_fn_i[6]);
  assign net_1845 = ~(net_1909 | net_1910);
  assign net_1910 = ~(net_1911 & net_1912);
  assign net_1912 = ~(net_3466 & net_1913);
  assign add_neon_perm_sel[2] = (net_1914 | net_1915);
  assign net_1915 = (net_1368 | net_1916);
  assign net_1916 = (net_1917 | net_1918);
  assign net_1917 = (net_161 | net_1919);
  assign net_1919 = (net_1920 | net_1921);
  assign net_1921 = ~(net_1922 & net_1923);
  assign net_1923 = ~(net_1924 | net_1925);
  assign net_1925 = ~(net_1926 | net_27);
  assign net_1924 = (net_1901 | net_1927);
  assign net_1927 = ~(net_153 & net_1928);
  assign net_1928 = ~(net_252 & net_1929);
  assign net_1901 = (net_1669 & net_1930);
  assign net_1930 = (net_714 & net_1931);
  assign net_1931 = (net_1932 & net_1933);
  assign net_1933 = (iq_instr_fn_i[20] | net_59);
  assign net_1932 = (iq_instr_fn_i[25] | net_1934);
  assign net_1934 = ~(net_3464 | iq_instr_fn_i[20]);
  assign net_1368 = ~(net_1935 | net_1218);
  assign net_1218 = (net_3466 | net_36);
  assign net_1914 = (net_1205 & net_1936);
  assign add_neon_perm_sel[1] = (net_1937 | net_1938);
  assign net_1938 = (net_1909 | net_1939);
  assign net_1939 = (net_1940 | net_1941);
  assign net_1940 = (net_253 | net_1942);
  assign net_1942 = (net_1801 | net_1943);
  assign net_1943 = (net_1944 | net_1945);
  assign net_1945 = ~(net_1946 & net_1947);
  assign net_1947 = ~(net_1948 & iq_instr_fn_i[9]);
  assign net_1946 = ~(net_1949 & net_1950);
  assign net_1944 = (net_1951 | net_1952);
  assign net_1952 = (net_1953 | net_1920);
  assign net_1920 = (net_1954 & net_1955);
  assign net_1953 = (net_1956 & iq_instr_fn_i[11]);
  assign net_1951 = ~(net_1957 & net_1958);
  assign net_1958 = ~(net_1707 & net_66);
  assign net_1707 = (net_336 & net_653);
  assign net_1957 = ~(net_1959 & net_342);
  assign net_1801 = (net_261 & net_1960);
  assign net_1960 = ~(net_1961 & net_1962);
  assign net_1962 = ~(net_342 & net_62);
  assign net_1961 = ~(net_1963 & net_1869);
  assign net_253 = (sf_bit & net_1262);
  assign net_1262 = (net_351 & net_401);
  assign net_1909 = ~(net_1964 | net_1965);
  assign net_1965 = ~(net_1189 & net_1259);
  assign net_1937 = (net_1966 | net_1967);
  assign net_1967 = ~(net_1968 & net_1969);
  assign net_1969 = (net_1970 | vd_eq_vm);
  assign net_1968 = (net_1971 & net_1972);
  assign net_1971 = (net_1973 & net_1974);
  assign net_1974 = (net_1975 & net_1308);
  assign net_1308 = ~(net_556 & net_1976);
  assign net_1973 = (net_1977 & net_1978);
  assign net_1977 = ~(net_1276 | net_1979);
  assign net_1979 = ~(net_351 | net_1704);
  assign net_1704 = ~(a64_only & net_932);
  assign net_1966 = (net_3466 & net_1980);
  assign net_1980 = ~(net_1981 & net_1982);
  assign net_1981 = (net_443 & net_1983);
  assign net_1983 = (net_595 | net_1984);
  assign net_1984 = ~(net_1436 & net_1206);
  assign net_595 = (net_34 | iq_instr_fn_i[10]);
  assign net_443 = (net_1985 & net_1986);
  assign net_1986 = (net_1471 | net_1820);
  assign net_1985 = (net_1987 & net_1988);
  assign net_1988 = (net_1989 & net_1990);
  assign net_1990 = ~(net_388 & net_1991);
  assign net_1989 = (net_1992 & net_1993);
  assign add_neon_perm_sel[0] = (net_1994 | net_1995);
  assign net_1995 = (net_1996 | net_1997);
  assign net_1997 = (net_1998 | net_1941);
  assign net_1941 = (net_1999 | net_2000);
  assign net_2000 = (net_2001 | net_2002);
  assign net_2002 = (net_1564 | net_2003);
  assign net_2003 = ~(net_2004 & net_2005);
  assign net_2004 = (net_153 & net_2006);
  assign net_2006 = (iq_instr_fn_i[6] | net_2007);
  assign net_153 = ~(iq_instr_fn_i[11] & net_2008);
  assign net_2008 = (net_1089 & net_2009);
  assign net_2009 = (net_2010 | net_2011);
  assign net_2011 = (net_2012 & iq_instr_fn_i[10]);
  assign net_2010 = ~(net_410 | net_2013);
  assign net_2013 = (net_653 | net_2014);
  assign net_2014 = (net_59 | net_30);
  assign net_2001 = (net_2015 & net_2016);
  assign net_2016 = (net_2017 | net_2018);
  assign net_2018 = ~(net_2019 | net_2020);
  assign net_1999 = (iq_instr_fn_i[9] & net_2021);
  assign net_2021 = ~(net_2022 & net_2023);
  assign net_2023 = (net_2024 & net_2025);
  assign net_2025 = (iq_instr_fn_i[10] | net_2026);
  assign net_2026 = (net_3465 | net_2027);
  assign net_2024 = ~(net_2028 | net_2029);
  assign net_2029 = ~(net_2030 & net_2031);
  assign net_2031 = (net_2032 | net_1213);
  assign net_1213 = (net_4 | iq_instr_fn_i[6]);
  assign net_2022 = (net_1809 & net_2033);
  assign net_2033 = (net_36 | net_1935);
  assign net_1935 = ~(iq_instr_fn_i[11] & net_2034);
  assign net_2034 = (iq_instr_fn_i[21] & net_2035);
  assign net_2035 = (net_2036 | net_2037);
  assign net_2037 = (net_2038 & net_2039);
  assign net_2036 = (net_1447 & net_958);
  assign net_1998 = (net_2040 | net_2041);
  assign net_2041 = ~(net_2042 & net_2043);
  assign net_2043 = ~(net_2044 & net_91);
  assign net_2042 = (net_1349 & net_309);
  assign net_1349 = ~(net_2045 | net_1902);
  assign net_1902 = (net_3466 & net_2046);
  assign net_2046 = ~(net_2047 & net_1993);
  assign net_1993 = ~(net_1399 & net_2048);
  assign net_2045 = ~(net_924 | net_2049);
  assign net_2049 = (net_2050 | net_2051);
  assign net_2051 = ~(iq_instr_fn_i[28] & net_1633);
  assign net_2050 = ~(net_2052 | net_2053);
  assign net_2053 = (net_2054 & net_2055);
  assign net_2055 = (net_241 & decoder_fsm_i[0]);
  assign net_2052 = (net_1585 & net_2056);
  assign net_2056 = ~(net_1964 & net_2057);
  assign net_2057 = ~(net_241 | net_2058);
  assign net_1585 = ~(net_48 | iq_instr_fn_i[8]);
  assign net_2040 = (net_1363 & net_2059);
  assign net_2059 = (net_2060 & net_55);
  assign net_1994 = (net_151 | net_2061);
  assign net_2061 = (net_189 | net_2062);
  assign net_2062 = ~(net_2063 & net_2064);
  assign net_2063 = (net_2065 & net_2066);
  assign net_2066 = (vd_eq_vm | net_2067);
  assign net_2067 = (net_92 | net_2027);
  assign net_2065 = ~(net_145 | net_2068);
  assign net_2068 = ~(net_1922 & net_2069);
  assign net_2069 = (net_3465 | net_2070);
  assign net_189 = ~(net_27 | net_2032);
  assign net_151 = (net_3466 & net_2071);
  assign net_2071 = ~(net_7 & net_1987);
  assign net_1987 = (net_1926 | net_31);
  assign net_1926 = (net_2072 & net_2073);
  assign net_2073 = (net_52 | net_902);
  assign add_neon_mux_sel[2] = ~(net_2074 & net_1795);
  assign net_2074 = ~(net_1330 | net_2075);
  assign net_2075 = ~(net_282 & net_2076);
  assign net_1330 = (net_549 & net_2077);
  assign net_2077 = ~(net_93 | net_999);
  assign add_neon_mux_sel[1] = ~(net_2078 & net_2079);
  assign net_2079 = (net_2080 & net_2081);
  assign net_2080 = ~(add_neon_mask_sel | net_2082);
  assign net_2082 = (net_2083 | net_2084);
  assign net_2084 = ~(net_2085 & net_518);
  assign net_2085 = (net_2086 & net_2087);
  assign net_2087 = (net_62 | net_2088);
  assign net_2086 = (net_2089 & net_2090);
  assign net_2090 = (iq_instr_fn_i[9] | net_1304);
  assign net_2089 = (net_282 & net_1538);
  assign net_2078 = (net_2091 & net_2092);
  assign net_2091 = (net_2093 & net_2094);
  assign net_2094 = (net_3466 | net_1691);
  assign net_1691 = (net_2095 & net_2096);
  assign net_2096 = (net_17 | net_2097);
  assign net_2097 = (net_2098 | net_2099);
  assign net_2099 = ~(net_2100 & decoder_fsm_i[2]);
  assign net_2093 = (net_2101 & net_2102);
  assign add_neon_mux_sel[0] = (net_2103 | net_2104);
  assign net_2104 = (net_2105 | net_2106);
  assign net_2106 = (net_1032 | net_2107);
  assign net_1032 = (net_2108 | net_2109);
  assign net_2109 = (net_2110 | net_177);
  assign net_177 = (net_576 | net_2111);
  assign net_2111 = (net_570 | net_2112);
  assign net_2112 = ~(net_1233 & net_2113);
  assign net_2113 = (net_2114 & net_2115);
  assign net_2115 = (net_2116 & net_1535);
  assign net_2114 = (net_711 & net_2117);
  assign net_1233 = (net_604 & net_2118);
  assign net_2118 = (net_1501 | net_3465);
  assign net_1501 = (net_2119 & net_2120);
  assign net_2120 = (iq_instr_fn_i[4] | net_322);
  assign net_604 = (net_2121 | net_3466);
  assign net_2121 = (net_931 & net_2122);
  assign net_2122 = (net_2123 & net_512);
  assign net_2123 = (net_2124 | net_598);
  assign net_2124 = (net_2125 & net_2126);
  assign net_2126 = ~(net_3464 & net_74);
  assign net_931 = ~(net_2127 & net_885);
  assign net_2110 = (net_1549 & net_3466);
  assign net_1549 = (net_11 | net_2128);
  assign net_2128 = (net_2129 | net_2130);
  assign net_2129 = (net_633 & net_1287);
  assign net_1287 = (net_2131 & net_942);
  assign net_2108 = (net_2132 | net_2133);
  assign net_2133 = (net_1824 | net_2134);
  assign net_2134 = (net_1271 | net_2135);
  assign net_2135 = ~(net_289 & net_2);
  assign net_289 = ~(iq_instr_fn_i[11] & net_2137);
  assign net_2137 = (net_653 & net_2138);
  assign net_1271 = (net_1955 & net_281);
  assign net_281 = (net_609 & net_555);
  assign net_2132 = (iq_instr_fn_i[6] & net_2139);
  assign net_2139 = ~(net_2140 & net_144);
  assign net_2140 = (net_273 & net_2141);
  assign net_2141 = (net_238 | net_2142);
  assign net_238 = ~(net_370 | net_1600);
  assign net_273 = (net_2143 & net_2144);
  assign net_2143 = (net_2145 | net_1541);
  assign net_2145 = (iq_instr_fn_i[21] & net_2146);
  assign net_2146 = ~(net_74 | net_95);
  assign net_2105 = (net_2147 | net_2148);
  assign net_2148 = (net_2149 | net_2150);
  assign net_2149 = (net_2151 & net_3466);
  assign net_2147 = (net_657 | net_2152);
  assign net_2152 = (net_622 | net_2153);
  assign net_2153 = (net_2154 | net_212);
  assign net_212 = (net_1754 | net_2155);
  assign net_2155 = (add_neon_sat_op_sel[2] | net_2156);
  assign net_2156 = ~(net_2157 & net_2158);
  assign net_2157 = (net_2159 & net_2160);
  assign net_2160 = (net_1060 | net_1066);
  assign net_1066 = ~(net_1633 & net_2161);
  assign net_2161 = ~(net_2162 & net_2163);
  assign net_2163 = (net_95 | a64_only);
  assign net_2162 = ~(net_1206 & net_336);
  assign net_1060 = ~(iq_instr_fn_i[19] & net_526);
  assign add_neon_sat_op_sel[2] = ~(net_1795 & net_1079);
  assign net_1754 = (net_2164 & net_93);
  assign net_2164 = (net_1173 & net_578);
  assign net_2154 = (net_145 | net_2165);
  assign net_2165 = (net_1760 | net_2166);
  assign net_2166 = ~(net_2167 & net_2168);
  assign net_2168 = ~(net_1783 | net_2169);
  assign net_2169 = ~(net_2170 & net_2171);
  assign net_2170 = (net_1978 & net_2172);
  assign net_1978 = ~(net_557 & net_2173);
  assign net_2167 = (net_2174 & net_2175);
  assign net_2175 = ~(net_2176 & net_436);
  assign net_2174 = (net_1876 | net_2177);
  assign net_2177 = ~(net_2173 & net_2178);
  assign net_2178 = (net_481 & vd_eq_vm);
  assign net_1876 = (net_4 | net_2179);
  assign net_1760 = (net_1610 & net_2180);
  assign net_145 = (iq_instr_fn_i[6] & net_2181);
  assign net_622 = (net_2182 & net_3465);
  assign net_2182 = (net_2183 & net_1316);
  assign net_1316 = (net_1415 | net_72);
  assign net_657 = (iq_instr_fn_i[6] & net_2184);
  assign net_2103 = (net_2185 | net_2186);
  assign net_2186 = ~(net_2187 & net_2188);
  assign net_2188 = ~(net_1302 & net_3466);
  assign net_1302 = ~(net_2189 & net_2190);
  assign net_2190 = (net_2191 & net_2192);
  assign net_2192 = ~(net_2193 & net_633);
  assign net_2191 = (net_1625 & net_2194);
  assign net_2194 = (net_2195 | net_2196);
  assign net_2196 = ~(net_2197 & iq_instr_fn_i[8]);
  assign net_1625 = ~(net_555 & net_1171);
  assign net_1171 = (net_269 & net_2198);
  assign net_2189 = ~(net_1185 | net_2199);
  assign net_2199 = ~(net_2200 & net_2201);
  assign add_neon_lu_ctl[3] = (net_2202 | net_2203);
  assign net_2203 = (net_1564 | net_2204);
  assign net_2204 = (net_2205 | net_2083);
  assign net_2083 = (net_2206 | net_2207);
  assign net_2207 = (net_2208 | net_2209);
  assign net_2209 = ~(net_2210 & net_2211);
  assign net_2211 = (net_2212 & net_2213);
  assign net_2213 = (net_1286 | net_1714);
  assign net_1714 = ~(net_1285 & net_35);
  assign net_1285 = (net_228 & net_3464);
  assign net_2206 = (net_2214 | net_2215);
  assign net_2215 = (net_2216 | net_2217);
  assign net_2217 = (net_2218 & net_1059);
  assign net_1059 = ~(net_2219 & net_2220);
  assign net_2220 = ~(net_2221 & net_59);
  assign net_2221 = ~(net_82 | net_3463);
  assign net_2219 = (net_2032 | net_3464);
  assign net_2216 = (net_3466 & net_2222);
  assign net_2222 = ~(net_2223 & net_2224);
  assign net_2224 = (net_2225 & net_2226);
  assign net_2226 = (net_31 | net_2227);
  assign net_2227 = (net_2228 & net_2229);
  assign net_2228 = (net_2230 & net_2231);
  assign net_2231 = ~(net_536 & net_2232);
  assign net_2230 = ~(net_2233 & net_262);
  assign net_2225 = (net_1268 & net_2234);
  assign net_2234 = (iq_instr_fn_i[11] | net_2235);
  assign net_2235 = (net_2236 | net_37);
  assign net_1268 = (net_2237 | net_2238);
  assign net_2214 = (iq_instr_fn_i[9] & net_2239);
  assign net_2239 = ~(net_2240 & net_2241);
  assign net_2241 = (net_2242 & net_2243);
  assign net_2243 = (net_2244 & net_2245);
  assign net_2242 = (net_2246 & net_2247);
  assign net_2246 = (net_2248 & net_2249);
  assign net_2249 = ~(net_1455 & net_2250);
  assign net_2250 = (net_1791 | net_2251);
  assign net_2251 = (net_2252 | net_2253);
  assign net_2252 = (net_2254 & net_431);
  assign net_2248 = (net_1970 & net_2255);
  assign net_2255 = ~(net_2256 | net_2257);
  assign net_2257 = (net_2258 & net_868);
  assign net_2205 = (net_2259 | net_2260);
  assign net_2259 = (net_556 & net_2261);
  assign net_2261 = (net_25 & net_674);
  assign net_2202 = (net_2262 | net_2263);
  assign net_2262 = (net_2264 & net_2265);
  assign net_2265 = (net_2266 & net_1820);
  assign net_2264 = (net_2267 & net_2268);
  assign net_2267 = ~(iq_instr_fn_i[5] ^ net_3465);
  assign add_neon_lu_ctl[2] = ~(net_2269 & net_2212);
  assign net_2269 = (net_2270 & net_2271);
  assign net_2271 = ~(net_351 & net_2272);
  assign net_2272 = (net_2273 | net_2274);
  assign net_2274 = (net_2275 | net_2276);
  assign net_2276 = (net_2277 | net_2278);
  assign net_2278 = (net_2279 | net_2280);
  assign net_2280 = ~(net_399 & net_2281);
  assign net_2281 = ~(net_1172 & net_2282);
  assign net_2282 = (net_365 & net_2283);
  assign net_399 = (net_2284 & net_2285);
  assign net_2285 = (net_229 | net_1385);
  assign net_2284 = ~(net_2286 & net_2287);
  assign net_2287 = (net_2288 & net_867);
  assign net_2286 = (net_1949 & iq_instr_fn_i[7]);
  assign net_1949 = ~(net_2289 | net_35);
  assign net_2289 = (net_2020 & net_2290);
  assign net_2290 = ~(net_16 & net_72);
  assign net_2279 = (net_269 & net_1220);
  assign net_2277 = (net_2291 | net_2292);
  assign net_2292 = (net_2293 | net_401);
  assign net_401 = ~(net_83 | net_1);
  assign net_2293 = (iq_instr_fn_i[28] & net_2294);
  assign net_2294 = (net_2295 | net_2296);
  assign net_2296 = (net_361 & net_2297);
  assign net_2297 = ~(net_377 & net_2298);
  assign net_2298 = ~(iq_instr_fn_i[9] & net_2299);
  assign net_2295 = (net_21 & net_2300);
  assign net_2300 = (net_411 & net_1016);
  assign net_2291 = (net_2301 | net_1615);
  assign net_1615 = (decoder_fsm_i[1] & net_2302);
  assign net_2302 = ~(net_2303 | net_229);
  assign net_229 = ~(net_774 & net_109);
  assign net_2303 = (net_18 | iq_instr_fn_i[6]);
  assign net_2301 = (net_867 & net_2304);
  assign net_2304 = (net_1259 & net_2305);
  assign net_2275 = (net_373 & net_2306);
  assign net_2306 = (net_2307 | net_2308);
  assign net_2308 = ~(net_2309 & net_2310);
  assign net_2310 = ~(net_2311 & iq_instr_fn_i[9]);
  assign net_2311 = (net_2312 & net_2313);
  assign net_2313 = ~(net_2314 & net_2315);
  assign net_2315 = ~(net_410 & net_18);
  assign net_2314 = (net_1374 | net_19);
  assign net_2309 = ~(net_2316 & net_1579);
  assign net_2316 = (net_736 & net_2317);
  assign net_2307 = (net_2318 | net_2319);
  assign net_2319 = (net_2320 | net_2321);
  assign net_2321 = ~(net_2238 | net_2322);
  assign net_2322 = (net_3467 | net_2323);
  assign net_2323 = ~(net_834 & iq_instr_fn_i[28]);
  assign net_2238 = ~(net_72 & net_419);
  assign net_2320 = (net_1444 & net_2324);
  assign net_2318 = ~(net_2325 & net_2326);
  assign net_2326 = (net_43 | net_2327);
  assign net_2325 = ~(net_1859 | net_364);
  assign net_364 = ~(net_2328 | net_22);
  assign net_2273 = (net_404 & net_2329);
  assign net_2329 = ~(net_2330 & net_2331);
  assign net_2331 = (net_2332 & net_2333);
  assign net_2333 = ~(net_1579 & net_2334);
  assign net_2332 = (net_1202 & net_2335);
  assign net_2335 = (net_22 | net_2336);
  assign net_2336 = ~(net_2337 | net_2338);
  assign net_411 = (net_370 & net_2339);
  assign net_1202 = ~(net_431 & net_241);
  assign net_2330 = (net_2340 & net_2341);
  assign net_2341 = ~(net_2342 & net_78);
  assign net_2340 = ~(net_2283 & net_3468);
  assign net_404 = (net_867 & net_1048);
  assign net_2270 = ~(net_2343 | net_2344);
  assign net_2344 = ~(net_2345 & net_2346);
  assign net_2346 = (net_2347 & net_1975);
  assign net_1975 = ~(add_neon_mask_sel | net_2348);
  assign net_2348 = ~(net_2349 & net_2350);
  assign net_2350 = ~(net_2208 | net_156);
  assign net_156 = ~(iq_instr_fn_i[9] | net_2351);
  assign net_2349 = (net_2352 & net_2353);
  assign net_2352 = ~(net_1205 & net_2354);
  assign net_2354 = (net_1936 | net_2355);
  assign net_2355 = (net_370 & net_839);
  assign net_1936 = (net_973 & net_1383);
  assign net_2347 = ~(net_2356 | net_2357);
  assign net_2357 = ~(net_2358 & net_2359);
  assign net_2359 = ~(net_1996 | net_2360);
  assign net_2360 = ~(net_2361 & net_2362);
  assign net_2362 = ~(net_2044 & net_3465);
  assign net_2044 = (net_894 & net_436);
  assign net_436 = (net_363 & net_347);
  assign net_2361 = ~(net_2363 & net_730);
  assign net_1996 = (net_3466 & net_2364);
  assign net_2364 = ~(net_1992 & net_2365);
  assign net_2365 = (net_2366 & net_517);
  assign net_2366 = (net_2367 | net_31);
  assign net_2367 = (net_2368 & net_2369);
  assign net_2369 = ~(net_536 & net_973);
  assign net_2358 = (net_2370 & net_2371);
  assign net_2371 = (net_2372 | net_1778);
  assign net_2372 = (net_86 | net_2373);
  assign net_2373 = ~(net_1455 & net_2374);
  assign net_2374 = ~(net_56 | net_3469);
  assign net_2370 = (net_2375 & net_2376);
  assign net_2376 = (net_2377 & net_2378);
  assign net_2378 = ~(net_663 & net_268);
  assign net_2377 = ~(net_2379 | net_2380);
  assign net_2380 = ~(net_1371 & net_2381);
  assign net_2381 = ~(net_104 & net_2382);
  assign net_2382 = (net_2383 & net_1048);
  assign net_1371 = ~(net_549 & net_1483);
  assign net_1483 = (decoder_fsm_i[2] & net_2384);
  assign net_2384 = ~(decoder_fsm_i[1] | net_2385);
  assign net_2385 = ~(net_996 & net_2386);
  assign net_2386 = ~(net_29 | net_59);
  assign net_2356 = ~(net_2387 & net_2388);
  assign net_2388 = ~(net_1344 & net_923);
  assign net_2387 = (net_2389 | net_84);
  assign net_2345 = (net_2390 & net_2391);
  assign net_2391 = ~(net_2015 & net_2017);
  assign net_2017 = (net_2392 & net_3468);
  assign net_2392 = (iq_instr_fn_i[6] & net_2393);
  assign net_2015 = ~(net_92 | net_2394);
  assign net_2390 = (net_349 & net_1911);
  assign net_1911 = (net_2395 & net_1538);
  assign net_2395 = ~(net_1564 | net_2396);
  assign net_2396 = (net_228 & net_2397);
  assign net_2397 = (net_996 & net_3471);
  assign net_996 = ~(net_3469 | iq_instr_fn_i[6]);
  assign net_1564 = (net_174 & net_50);
  assign net_174 = (net_1465 & net_3469);
  assign net_349 = (net_2398 & net_2399);
  assign net_2399 = (net_3466 | net_2400);
  assign net_2400 = (net_2401 & net_2402);
  assign net_2402 = ~(net_269 & net_1954);
  assign net_2401 = (net_2247 & net_2403);
  assign net_2398 = (net_2245 & net_2070);
  assign add_neon_lu_ctl[1] = (net_2404 | net_2405);
  assign net_2405 = ~(net_2406 & net_2407);
  assign net_2406 = ~(net_2408 | net_2409);
  assign net_2409 = ~(net_2410 & net_2375);
  assign net_2375 = ~(net_2411 & net_1441);
  assign net_1441 = ~(net_47 | net_999);
  assign net_2410 = (net_2412 & net_2413);
  assign net_2413 = ~(net_1344 & net_2176);
  assign net_1344 = (net_431 & net_347);
  assign net_2412 = (net_2414 & net_2415);
  assign net_2415 = ~(net_2260 | net_2416);
  assign net_2416 = ~(net_1280 & net_2417);
  assign net_2417 = (net_1539 | iq_instr_fn_i[21]);
  assign net_2260 = (net_725 & net_2418);
  assign net_725 = (net_3469 & iq_instr_fn_i[21]);
  assign net_2408 = (net_2419 | net_2420);
  assign net_2420 = (net_2421 | net_548);
  assign net_548 = (net_1480 & net_1300);
  assign net_1300 = (net_2422 & net_2423);
  assign net_2423 = ~(net_2424 | net_63);
  assign net_2421 = (net_2418 & net_346);
  assign net_2418 = (net_2173 & net_2425);
  assign net_2419 = (net_1048 & net_2426);
  assign net_2426 = (net_2253 | net_2427);
  assign net_2427 = ~(net_52 | net_2428);
  assign add_neon_lu_ctl[0] = ~(net_2407 & net_2429);
  assign net_2429 = ~(net_2430 | net_2431);
  assign net_2431 = ~(net_2432 & net_2433);
  assign net_2433 = (net_2434 & net_2435);
  assign net_2435 = (net_2436 | net_3467);
  assign net_2436 = (net_2437 & net_2438);
  assign net_2438 = (net_517 | iq_instr_fn_i[9]);
  assign net_2437 = ~(net_653 & net_2439);
  assign net_2439 = ~(net_47 | net_1243);
  assign net_2434 = (net_2440 & net_2441);
  assign net_2441 = ~(net_800 & net_2411);
  assign net_2440 = (net_518 & net_1922);
  assign net_1922 = (net_1538 & net_2442);
  assign net_2442 = ~(net_2443 & net_2444);
  assign net_2444 = (net_552 & net_3466);
  assign net_2432 = ~(net_2263 | net_2445);
  assign net_2445 = (net_2446 | net_2447);
  assign net_2447 = ~(net_2448 & net_2449);
  assign net_2449 = (net_2450 & net_2451);
  assign net_2451 = (net_2452 | net_2453);
  assign net_2453 = ~(net_351 & net_609);
  assign net_2452 = (net_2454 & net_2455);
  assign net_2455 = (net_1195 | sf_bit);
  assign net_1195 = (net_83 | iq_instr_fn_i[8]);
  assign net_2454 = (net_871 | aarch64_state_i);
  assign net_871 = ~(net_774 & net_118);
  assign net_2450 = (net_2456 & net_2457);
  assign net_2457 = (net_272 | net_392);
  assign net_392 = (iq_instr_fn_i[17] | iq_instr_fn_i[7]);
  assign net_272 = ~(net_260 & net_837);
  assign net_2456 = (net_2458 | net_2459);
  assign net_2459 = ~(net_2460 & net_2461);
  assign net_2461 = (decoder_fsm_i[0] | net_2462);
  assign net_2462 = ~(net_1374 | net_2463);
  assign net_2460 = ~(net_79 & net_2463);
  assign net_2463 = ~(iq_instr_fn_i[9] & net_395);
  assign net_2448 = ~(net_236 | net_2464);
  assign net_2464 = ~(net_2465 & net_2466);
  assign net_2466 = ~(net_1046 & net_95);
  assign net_2465 = (net_2467 & net_2468);
  assign net_2468 = ~(net_2469 & net_347);
  assign net_2469 = (net_435 & net_390);
  assign net_390 = ~(net_80 | iq_instr_fn_i[8]);
  assign net_2467 = ~(net_2470 & net_1955);
  assign net_236 = (net_2471 | add_neon_mask_sel);
  assign net_2471 = (net_2472 & net_2473);
  assign net_2473 = ~(net_517 | net_66);
  assign net_2263 = ~(net_2474 & net_2475);
  assign net_2475 = ~(net_2476 & net_351);
  assign net_2476 = (net_800 & net_2477);
  assign net_2477 = (net_455 & net_3466);
  assign net_2474 = ~(net_1859 & net_1686);
  assign net_1859 = ~(net_50 | iq_instr_fn_i[28]);
  assign net_2407 = (net_2478 & net_2479);
  assign net_2478 = ~(net_1680 | net_2480);
  assign net_2480 = ~(net_3463 | net_2481);
  assign net_2481 = (net_2482 & net_2483);
  assign net_2483 = (iq_instr_fn_i[23] | net_2484);
  assign net_2484 = ~(net_2485 & net_2486);
  assign net_2486 = ~(net_3465 | net_66);
  assign net_2482 = (net_2487 | net_59);
  assign net_2487 = ~(net_2488 | net_2489);
  assign net_2489 = (net_2363 & iq_instr_fn_i[26]);
  assign net_2363 = ~(net_68 | net_81);
  assign net_1680 = ~(net_1449 | net_2490);
  assign add_neon_int_sel = (net_2491 | net_2492);
  assign net_2492 = (net_211 | net_2493);
  assign net_2493 = ~(net_2494 & net_2495);
  assign net_2495 = (net_2496 | iq_instr_fn_i[9]);
  assign net_2496 = (net_468 & net_2497);
  assign net_2497 = (net_2223 & net_2498);
  assign net_2223 = (net_1311 & net_2499);
  assign net_2499 = (net_2500 & net_2501);
  assign net_2501 = (net_2502 & net_1305);
  assign net_1305 = (net_2503 & net_2504);
  assign net_2504 = ~(net_2505 & iq_instr_fn_i[5]);
  assign net_2503 = (net_2506 | net_31);
  assign net_2506 = (net_2368 & net_2507);
  assign net_2507 = (net_2508 & net_2032);
  assign net_2502 = (net_2509 & net_2510);
  assign net_2510 = (iq_instr_fn_i[17] | net_2511);
  assign net_2511 = (net_2512 | net_31);
  assign net_2512 = ~(net_260 & net_1633);
  assign net_2500 = (net_2513 & net_2514);
  assign net_2513 = (net_2515 & net_2516);
  assign net_2516 = ~(iq_instr_fn_i[23] & net_2517);
  assign net_2517 = (net_2518 & net_2519);
  assign net_2519 = (net_2520 | net_2521);
  assign net_2521 = (net_2305 & net_1376);
  assign net_2305 = (net_3468 & net_1607);
  assign net_2515 = (net_2245 & net_2522);
  assign net_2522 = (net_2523 & net_2524);
  assign net_2524 = (net_1 | net_2525);
  assign net_2525 = ~(net_351 & net_269);
  assign net_1311 = (net_2526 & net_2527);
  assign net_2527 = ~(net_55 & net_2528);
  assign net_2526 = (net_2529 & net_2530);
  assign net_2530 = (net_2531 & net_2532);
  assign net_2532 = (net_2533 | net_2534);
  assign net_2534 = ~(net_633 & net_1103);
  assign net_2531 = (net_517 & net_1982);
  assign net_1982 = (net_34 | net_2535);
  assign net_468 = ~(iq_instr_fn_i[10] & net_1991);
  assign net_1991 = (net_312 & net_2536);
  assign net_2494 = (net_2537 & net_2538);
  assign net_2538 = (net_2539 & net_2540);
  assign net_2539 = (net_2541 & net_2542);
  assign net_2542 = ~(net_263 & net_2543);
  assign net_2541 = (net_2101 & net_2544);
  assign net_2544 = (net_2545 & net_2546);
  assign net_2546 = ~(net_2547 & net_834);
  assign net_2545 = (net_2548 & net_2549);
  assign net_2549 = (net_2550 & net_2551);
  assign net_2551 = (net_2088 | net_172);
  assign net_172 = (net_68 | iq_instr_fn_i[19]);
  assign net_2088 = ~(net_2268 & net_2552);
  assign net_2552 = (net_2266 & net_1298);
  assign net_2266 = ~(net_2424 | net_44);
  assign net_2424 = (net_48 & net_2553);
  assign net_2553 = (net_42 | iq_instr_fn_i[11]);
  assign net_2550 = (net_1079 & net_1536);
  assign net_1536 = ~(net_250 & net_2554);
  assign net_2554 = (iq_instr_fn_i[21] & net_1833);
  assign net_1833 = (net_261 & net_2520);
  assign net_2520 = ~(net_47 | net_3463);
  assign net_2101 = ~(net_1048 & net_2193);
  assign net_2193 = (net_55 & net_2233);
  assign net_2233 = (net_389 & net_1080);
  assign net_1080 = ~(net_95 & iq_instr_fn_i[11]);
  assign net_389 = (net_3465 & iq_instr_fn_i[10]);
  assign net_2537 = (net_2555 & net_1227);
  assign net_1227 = (net_2556 & net_2557);
  assign net_2557 = (net_2081 & net_2558);
  assign net_2558 = (net_2559 & net_2560);
  assign net_2560 = (net_543 & net_1751);
  assign net_543 = (net_2158 & net_2561);
  assign net_2158 = ~(net_361 & net_1427);
  assign net_1427 = ~(net_87 | net_44);
  assign net_2559 = (net_2210 & net_2172);
  assign net_2172 = ~(net_2562 & net_2563);
  assign net_2563 = ~(iq_instr_fn_i[8] & net_21);
  assign net_2562 = ~(iq_instr_fn_i[11] | net_2564);
  assign net_2210 = (net_2353 & net_2565);
  assign net_2565 = (iq_instr_fn_i[11] | net_2566);
  assign net_2566 = (net_2567 | net_2394);
  assign net_2394 = ~(net_867 & net_483);
  assign net_483 = ~(vd_eq_vm | net_36);
  assign net_2567 = (net_2568 & net_2569);
  assign net_2569 = (net_73 | net_2570);
  assign net_2570 = (net_2571 | net_2019);
  assign net_2019 = (net_3470 | iq_instr_fn_i[9]);
  assign net_2571 = ~(net_2572 | net_2573);
  assign net_2573 = (net_21 & net_2574);
  assign net_2572 = (net_2054 & net_2575);
  assign net_2575 = (net_2337 | net_2338);
  assign net_2337 = ~(net_21 | iq_instr_fn_i[7]);
  assign net_2568 = (net_2576 | net_92);
  assign net_2576 = (net_2577 & net_2578);
  assign net_2578 = ~(net_2574 & net_370);
  assign net_2081 = (net_2579 & net_2580);
  assign net_2580 = ~(net_2379 | net_167);
  assign net_167 = ~(iq_instr_fn_i[6] | net_2142);
  assign net_2379 = (net_2268 & net_2488);
  assign net_2488 = ~(iq_instr_fn_i[5] | net_2581);
  assign net_2581 = (net_2582 & net_2583);
  assign net_2583 = (net_83 | net_42);
  assign net_2582 = ~(net_2584 & net_2054);
  assign net_2054 = ~(net_50 | iq_instr_fn_i[8]);
  assign net_2584 = ~(net_44 | net_62);
  assign net_2579 = (net_2585 & net_2586);
  assign net_2586 = ~(iq_instr_fn_i[9] & net_2587);
  assign net_2587 = ~(net_2588 & net_2589);
  assign net_2589 = (net_2590 & net_2030);
  assign net_2030 = ~(net_633 & net_2591);
  assign net_2590 = ~(net_1436 & net_2592);
  assign net_2592 = (iq_instr_fn_i[11] & net_2593);
  assign net_2593 = (net_2039 & net_609);
  assign net_2039 = ~(net_2594 & net_2595);
  assign net_2595 = (net_1374 | net_2596);
  assign net_2596 = ~(net_2597 & net_958);
  assign net_2594 = (net_2598 | net_2599);
  assign net_2585 = (net_2600 & net_2601);
  assign net_2601 = (net_2142 | net_2602);
  assign net_2600 = ~(net_2430 | net_2603);
  assign net_2430 = (net_26 & net_2604);
  assign net_2604 = ~(net_413 & net_1374);
  assign net_2555 = ~(add_neon_fctn_sel[4] | net_2605);
  assign net_2605 = ~(net_2606 & net_2607);
  assign net_2607 = ~(iq_instr_fn_i[9] & net_293);
  assign net_293 = ~(net_2608 & net_2609);
  assign net_2609 = ~(iq_instr_fn_i[25] & net_1622);
  assign net_1622 = (net_771 & net_2610);
  assign net_2610 = (net_3467 & iq_instr_fn_i[21]);
  assign net_771 = (net_250 & iq_instr_fn_i[4]);
  assign net_2608 = ~(iq_instr_fn_i[19] & net_2611);
  assign net_2611 = ~(net_2612 & net_2613);
  assign net_2613 = (net_48 | net_2614);
  assign net_2614 = ~(decoder_fsm_i[1] & net_1480);
  assign net_1480 = ~(net_47 | net_58);
  assign net_2606 = (net_2615 & net_2616);
  assign net_2616 = (net_2617 | net_41);
  assign net_1087 = (net_664 & net_556);
  assign net_2617 = ~(net_3464 & net_60);
  assign net_2615 = (net_1805 & net_2618);
  assign net_2618 = (net_2619 & net_2620);
  assign net_2620 = (net_2621 | net_71);
  assign net_2619 = (net_2171 & net_1699);
  assign net_1699 = (net_2622 & net_2623);
  assign net_2623 = ~(net_2624 & iq_instr_fn_i[10]);
  assign net_2624 = ~(net_2625 & net_2626);
  assign net_2626 = (iq_instr_fn_i[9] | net_2627);
  assign net_2627 = ~(iq_instr_fn_i[7] & net_1554);
  assign net_2625 = ~(net_1956 | net_2628);
  assign net_2628 = ~(net_38 | net_2629);
  assign net_2622 = (net_1873 | net_45);
  assign net_2171 = ~(net_556 & net_2630);
  assign net_1805 = ~(net_1810 | net_2631);
  assign net_2631 = (iq_instr_fn_i[9] & net_2632);
  assign net_2632 = ~(net_2027 | net_2338);
  assign net_1810 = ~(net_142 & net_2633);
  assign net_142 = ~(net_973 & net_1956);
  assign net_211 = ~(net_2634 & net_2635);
  assign net_2635 = (net_2636 | iq_instr_fn_i[9]);
  assign net_2636 = (net_1781 & net_2637);
  assign net_2637 = (net_2638 & net_2639);
  assign net_2638 = (net_2640 & net_2641);
  assign net_2641 = (net_2642 | net_37);
  assign net_2640 = (net_2201 & net_1304);
  assign net_1304 = (net_2643 | iq_instr_fn_i[23]);
  assign net_2643 = ~(net_2644 | net_2645);
  assign net_2645 = ~(net_87 | net_2646);
  assign net_2646 = ~(net_1669 & net_476);
  assign net_476 = (net_1029 & net_2647);
  assign net_2644 = (net_455 & net_2648);
  assign net_2648 = (net_2649 | net_2650);
  assign net_2650 = (net_2651 & net_1908);
  assign net_2649 = (net_2652 | net_460);
  assign net_460 = ~(net_64 | net_4);
  assign net_2652 = (net_336 & net_2653);
  assign net_2653 = (net_3468 | net_351);
  assign net_2634 = (net_2654 & net_2655);
  assign net_2655 = (net_2656 & net_2657);
  assign net_2654 = (net_2658 & net_309);
  assign net_2658 = (net_2659 & net_2660);
  assign net_2660 = ~(iq_instr_fn_i[9] & net_2661);
  assign net_2661 = (net_2662 | net_2663);
  assign net_2663 = (net_2664 | net_1783);
  assign net_1783 = (net_431 & net_117);
  assign net_117 = (net_346 & net_361);
  assign net_2664 = (net_361 & net_868);
  assign net_2662 = (net_2665 | net_2256);
  assign net_2256 = (net_431 & net_2666);
  assign net_2666 = ~(net_3465 | net_8);
  assign net_2665 = (net_2254 & net_2667);
  assign net_2667 = (net_1560 & net_633);
  assign net_2659 = (net_1343 & net_518);
  assign net_518 = ~(net_2668 & iq_instr_fn_i[4]);
  assign net_1343 = (iq_instr_fn_i[9] | net_2200);
  assign net_2200 = ~(net_2669 & net_2670);
  assign net_2670 = (net_1420 & net_2671);
  assign net_2671 = (net_2672 | net_2673);
  assign net_2673 = ~(net_421 | iq_instr_fn_i[8]);
  assign net_2669 = (net_59 & net_431);
  assign add_neon_fctn_sel[4] = ~(net_192 & net_2674);
  assign net_2674 = (net_2675 & net_2676);
  assign net_2676 = (net_2677 | net_1341);
  assign net_1341 = ~(net_388 & net_263);
  assign net_2675 = (net_1795 & net_2678);
  assign net_192 = (net_1280 & net_2679);
  assign net_2679 = (iq_instr_fn_i[9] | net_2680);
  assign net_2680 = (net_2237 | net_524);
  assign net_524 = (net_74 | iq_instr_fn_i[19]);
  assign net_2237 = ~(net_609 & net_1103);
  assign add_neon_fctn_sel[3] = ~(net_2681 & net_2682);
  assign net_2682 = (net_2683 & net_2684);
  assign net_2684 = (net_2685 & net_2686);
  assign net_2686 = ~(add_neon_mask_sel | net_2687);
  assign net_2687 = ~(net_164 & net_2688);
  assign net_2688 = (net_3469 | net_1713);
  assign net_1713 = ~(net_904 & net_228);
  assign net_164 = (net_2588 & net_2689);
  assign net_2689 = ~(net_252 & net_730);
  assign net_2588 = ~(net_1548 & net_2505);
  assign net_2685 = (net_2690 & net_2691);
  assign net_2691 = (net_3464 | net_1751);
  assign net_1751 = ~(net_2692 & net_653);
  assign net_2690 = (net_1336 & net_2693);
  assign net_2693 = ~(net_2150 | net_2694);
  assign net_2694 = ~(net_2695 & net_2696);
  assign net_2696 = (net_27 | net_2072);
  assign net_2072 = ~(net_2383 & net_1908);
  assign net_1908 = ~(net_47 & net_3469);
  assign net_2383 = (net_455 & net_2697);
  assign net_2150 = (iq_instr_fn_i[9] & net_2698);
  assign net_2698 = ~(net_2699 & net_1517);
  assign net_2699 = (net_2700 & net_2701);
  assign net_2701 = ~(net_1737 & net_2702);
  assign net_2702 = (net_55 & net_1744);
  assign net_2683 = (net_2703 & net_2656);
  assign net_2703 = (net_2704 & net_2705);
  assign net_2705 = (iq_instr_fn_i[9] | net_2706);
  assign net_2706 = ~(net_2707 | net_2708);
  assign net_2708 = (net_2151 | net_2709);
  assign net_2709 = ~(net_2710 & net_2711);
  assign net_2710 = (net_2712 & net_2713);
  assign net_2713 = (net_2714 | iq_instr_fn_i[11]);
  assign net_2714 = ~(net_774 & net_2715);
  assign net_2715 = ~(net_8 & net_2716);
  assign net_2716 = ~(net_2717 & net_21);
  assign net_2712 = (net_2351 & net_2718);
  assign net_2718 = ~(net_1455 & net_2719);
  assign net_2719 = (net_215 | net_2720);
  assign net_2720 = (net_2543 | net_217);
  assign net_217 = ~(vd_eq_vm | net_2721);
  assign net_2721 = ~(decoder_fsm_i[0] & net_2722);
  assign net_215 = (net_55 & net_839);
  assign net_2351 = ~(net_346 & net_2723);
  assign net_2723 = (iq_instr_fn_i[28] & net_2443);
  assign net_2443 = (net_894 & net_455);
  assign net_455 = (net_3467 & net_1669);
  assign net_2151 = ~(net_2639 & net_2724);
  assign net_2724 = (net_2725 & net_2726);
  assign net_2726 = ~(iq_instr_fn_i[8] & net_2547);
  assign net_2725 = (net_95 | net_1471);
  assign net_2639 = (net_2727 & net_2728);
  assign net_2728 = (net_87 | net_2729);
  assign net_2727 = (net_1786 & net_477);
  assign net_477 = ~(net_549 & net_2730);
  assign net_2730 = ~(iq_instr_fn_i[4] | net_1243);
  assign net_1786 = ~(net_431 & net_2731);
  assign net_2731 = ~(net_2598 | net_3);
  assign net_2598 = ~(net_3464 & net_3463);
  assign net_2704 = (net_2732 & net_2733);
  assign net_2733 = (net_2734 & net_2735);
  assign net_2735 = (net_2736 & net_2479);
  assign net_2479 = (net_2327 | net_2142);
  assign net_2142 = ~(net_1686 & net_531);
  assign net_2327 = (iq_instr_fn_i[6] & net_2602);
  assign net_2602 = ~(net_1206 & net_240);
  assign net_240 = (net_72 & net_74);
  assign net_2736 = (net_2737 & net_2738);
  assign net_2738 = ~(net_1579 & net_2739);
  assign net_2739 = (net_1465 & decoder_fsm_i[0]);
  assign net_2737 = ~(net_1591 & net_21);
  assign net_1591 = ~(net_27 | net_2508);
  assign net_2508 = ~(net_466 & net_535);
  assign net_466 = ~(net_3464 | net_3469);
  assign net_2734 = (net_2740 & net_2741);
  assign net_2741 = (net_2742 | iq_instr_fn_i[19]);
  assign net_2742 = (net_2743 & net_2744);
  assign net_2744 = (net_614 | iq_instr_fn_i[18]);
  assign net_614 = ~(iq_instr_fn_i[10] & net_2745);
  assign net_2745 = (net_837 & net_1744);
  assign net_2743 = (net_2746 & net_2747);
  assign net_2747 = (net_2748 | net_2749);
  assign net_2749 = ~(net_1029 & net_95);
  assign net_2748 = ~(iq_instr_fn_i[25] & net_2750);
  assign net_2750 = ~(net_176 & net_2751);
  assign net_2751 = ~(net_664 & net_3468);
  assign net_176 = (net_2752 & net_2753);
  assign net_2753 = (iq_instr_fn_i[11] | net_2754);
  assign net_2754 = ~(net_730 & iq_instr_fn_i[5]);
  assign net_2752 = (net_50 | net_2755);
  assign net_2755 = (net_2756 | net_56);
  assign net_2756 = (iq_instr_fn_i[10] & net_1298);
  assign net_1298 = (iq_instr_fn_i[8] | iq_instr_fn_i[5]);
  assign net_2746 = (net_2757 | net_2758);
  assign net_2758 = ~(net_2338 & net_2759);
  assign net_2759 = ~(net_27 | net_54);
  assign net_2757 = (decoder_fsm_i[0] | vd_eq_vm);
  assign net_2740 = ~(net_2760 | net_2761);
  assign net_2761 = ~(net_991 | net_2762);
  assign net_2762 = ~(net_118 & net_351);
  assign net_991 = ~(iq_instr_fn_i[4] & net_800);
  assign net_2760 = (net_2763 | net_2764);
  assign net_2764 = ~(net_2765 & net_2766);
  assign net_2766 = ~(net_342 & net_2767);
  assign net_2763 = ~(net_20 | net_147);
  assign net_2732 = (net_2768 & net_2769);
  assign net_2769 = (net_3470 | net_2770);
  assign net_2768 = (net_21 | net_1357);
  assign net_1357 = (net_2564 | net_85);
  assign net_2681 = (net_2771 & net_2772);
  assign net_2772 = ~(iq_instr_fn_i[9] & net_1689);
  assign net_2771 = (net_484 & net_2773);
  assign net_2773 = ~(net_2774 | net_2775);
  assign net_2775 = ~(net_2776 & net_2777);
  assign net_2777 = (net_2778 | decoder_fsm_i[0]);
  assign net_2778 = ~(net_1455 & net_2543);
  assign net_2776 = (net_2779 & net_2780);
  assign net_2780 = ~(net_2781 & iq_instr_fn_i[6]);
  assign net_2781 = (net_228 & net_2782);
  assign net_2782 = (iq_instr_fn_i[21] | net_2783);
  assign net_2783 = ~(net_72 | net_127);
  assign net_2779 = ~(net_2411 & net_2647);
  assign net_2647 = (iq_instr_fn_i[28] & net_1868);
  assign net_2411 = (net_2784 & net_2173);
  assign net_2784 = ~(net_93 | net_63);
  assign net_2774 = (net_267 | net_2785);
  assign net_2785 = ~(net_1079 & net_2786);
  assign net_2786 = ~(add_neon_vtst_op_sel | net_1075);
  assign add_neon_vtst_op_sel = (iq_instr_fn_i[4] & net_2787);
  assign net_2787 = (net_2470 & net_118);
  assign net_1079 = ~(net_1031 & net_75);
  assign net_267 = (net_2788 & net_3464);
  assign net_2788 = (net_501 & net_2789);
  assign net_2789 = (net_502 | net_2790);
  assign net_2790 = ~(net_64 | net_59);
  assign net_502 = (net_867 & net_3469);
  assign net_501 = (net_261 & net_932);
  assign net_484 = (net_2791 & net_2657);
  assign net_2657 = (net_2792 | iq_instr_fn_i[10]);
  assign net_2792 = (net_1408 | net_2793);
  assign net_2793 = (net_2794 & net_2795);
  assign net_2795 = ~(net_388 & net_250);
  assign net_2791 = (net_2796 & net_2797);
  assign net_2797 = ~(net_1963 & net_2798);
  assign net_1963 = (net_2268 & net_347);
  assign net_2796 = (net_2799 & net_2076);
  assign net_2076 = ~(net_361 & net_2800);
  assign net_2799 = (net_2801 | iq_instr_fn_i[9]);
  assign net_2801 = (net_2802 & net_2803);
  assign net_2803 = ~(net_431 & net_2425);
  assign net_2425 = (net_1669 & net_800);
  assign net_2802 = (net_2804 & net_2805);
  assign net_2805 = ~(net_2806 & net_2807);
  assign net_2804 = ~(net_1256 & net_1420);
  assign net_1420 = ~(net_47 | iq_instr_fn_i[4]);
  assign net_1256 = ~(iq_instr_fn_i[10] | net_1243);
  assign net_1243 = (iq_instr_fn_i[8] | net_1265);
  assign add_neon_fctn_sel[2] = ~(net_2808 & net_2809);
  assign net_2809 = (net_2810 & net_2811);
  assign net_2811 = (net_3466 | net_2812);
  assign net_2812 = (net_2813 & net_2814);
  assign net_2814 = ~(net_2815 & net_346);
  assign net_2813 = (net_1970 & net_2816);
  assign net_2816 = (net_296 & net_2817);
  assign net_2817 = (net_2236 | net_2818);
  assign net_2818 = ~(net_431 & decoder_fsm_i[0]);
  assign net_2236 = ~(net_536 & net_16);
  assign net_296 = (net_2819 & net_2820);
  assign net_2820 = (net_2821 & net_2822);
  assign net_2822 = ~(net_104 & net_2815);
  assign net_2821 = (net_1517 & net_2823);
  assign net_2819 = (net_2824 & net_2825);
  assign net_2825 = ~(net_260 & net_673);
  assign net_2824 = (net_2826 & net_2827);
  assign net_2827 = ~(net_2668 | net_2828);
  assign net_2828 = ~(net_2098 | net_1449);
  assign net_1449 = ~(net_2597 & net_2829);
  assign net_2829 = (decoder_fsm_i[1] & net_2574);
  assign net_2098 = ~(net_109 & net_1436);
  assign net_2826 = (net_2830 & net_2831);
  assign net_2831 = ~(net_2832 & decoder_fsm_i[0]);
  assign net_2832 = (net_2833 & net_1250);
  assign net_2830 = ~(net_2834 & net_1959);
  assign net_2810 = (net_2835 & net_2836);
  assign net_2836 = ~(net_2837 | net_2838);
  assign net_2838 = (net_2404 | net_2839);
  assign net_2839 = ~(net_2840 & net_1972);
  assign net_1972 = (net_2841 & net_2498);
  assign net_2498 = ~(net_536 & net_1884);
  assign net_1884 = ~(net_2842 | net_85);
  assign net_2842 = (net_30 & net_2843);
  assign net_2843 = ~(net_16 & net_3471);
  assign net_2841 = ~(net_2844 | net_2845);
  assign net_2845 = ~(net_147 | net_2846);
  assign net_2846 = (iq_instr_fn_i[11] | net_2621);
  assign net_2844 = (net_1075 | net_2847);
  assign net_2847 = ~(net_2700 & net_2848);
  assign net_2848 = ~(net_2518 & net_1250);
  assign net_2518 = (net_3465 & net_2833);
  assign net_1075 = (iq_instr_fn_i[11] & net_2849);
  assign net_2849 = (net_2850 & net_2851);
  assign net_2851 = (net_1363 | net_2852);
  assign net_2852 = (net_834 & net_16);
  assign net_2850 = (iq_instr_fn_i[6] & net_536);
  assign net_2840 = (net_2853 & net_2854);
  assign net_2854 = (decoder_fsm_i[0] | net_2855);
  assign net_2855 = (net_3464 | net_2856);
  assign net_2856 = (net_2857 | net_27);
  assign net_2857 = (net_2858 & net_2859);
  assign net_2859 = ~(net_346 & net_535);
  assign net_535 = (net_867 & net_2860);
  assign net_2860 = (net_481 & net_2342);
  assign net_2342 = ~(vd_eq_vm | net_71);
  assign net_2858 = (net_2535 | vd_eq_vm);
  assign net_2853 = (net_2861 & net_2862);
  assign net_2862 = (net_2863 & net_1795);
  assign net_2863 = (net_2864 & net_2865);
  assign net_2865 = ~(net_228 & net_2048);
  assign net_2048 = ~(net_2866 & net_3470);
  assign net_2866 = (net_2867 & net_2868);
  assign net_2868 = ~(iq_instr_fn_i[20] & net_127);
  assign net_2867 = (net_72 | net_904);
  assign net_2864 = ~(net_2528 & net_2254);
  assign net_2861 = (net_2869 & net_2870);
  assign net_2869 = (net_2871 & net_2872);
  assign net_2872 = (net_7 | net_1669);
  assign net_2871 = (net_2873 & net_2874);
  assign net_2874 = ~(net_835 & net_2875);
  assign net_2873 = (net_498 | net_488);
  assign net_488 = (net_2876 & net_2877);
  assign net_2877 = ~(net_551 & net_346);
  assign net_2876 = ~(net_2717 & net_774);
  assign net_2717 = (net_104 & net_907);
  assign net_2404 = ~(net_1374 | net_2878);
  assign net_2878 = ~(net_26 | net_161);
  assign net_2837 = (net_3466 & net_2879);
  assign net_2879 = (net_1897 | net_2880);
  assign net_2880 = (net_2707 | net_1913);
  assign net_1913 = ~(net_2881 & net_7);
  assign net_2881 = (net_2882 & net_2883);
  assign net_2883 = ~(net_432 & iq_instr_fn_i[11]);
  assign net_2882 = (net_1471 | net_147);
  assign net_1471 = ~(net_1465 & net_3467);
  assign net_2707 = ~(net_2884 & net_2885);
  assign net_2885 = ~(net_2886 & net_21);
  assign net_2886 = (net_633 & net_2887);
  assign net_2887 = ~(net_2368 & net_2888);
  assign net_2884 = ~(iq_instr_fn_i[11] & net_1976);
  assign net_1976 = (net_2889 & net_16);
  assign net_2889 = (net_312 & net_904);
  assign net_312 = ~(net_72 | net_56);
  assign net_1897 = (iq_instr_fn_i[19] & net_2890);
  assign net_2835 = (net_2711 & net_2891);
  assign net_2891 = (net_2032 | net_2892);
  assign net_2892 = ~(net_2574 & net_2317);
  assign net_2032 = ~(net_2334 & net_2893);
  assign net_2711 = (net_2894 | decoder_fsm_i[0]);
  assign net_2894 = (net_2529 & net_2895);
  assign net_2895 = (net_1809 | vd_eq_vm);
  assign add_neon_fctn_sel[1] = ~(net_2808 & net_2896);
  assign net_2896 = (net_2897 & net_2898);
  assign net_2898 = (net_2899 & net_2064);
  assign net_2064 = (net_2900 | net_3466);
  assign net_2900 = (net_1970 & net_2901);
  assign net_2901 = (net_2902 | net_902);
  assign net_902 = (net_79 | iq_instr_fn_i[6]);
  assign net_2902 = ~(net_1612 & net_1383);
  assign net_1383 = ~(net_2903 & net_2904);
  assign net_2904 = (net_19 | iq_instr_fn_i[8]);
  assign net_2903 = ~(net_21 & net_19);
  assign net_1970 = (net_95 | net_2027);
  assign net_2899 = (net_2905 & net_2906);
  assign net_2906 = (net_3466 | net_1517);
  assign net_2905 = (net_2907 & net_2908);
  assign net_2908 = (net_2909 & net_2910);
  assign net_2910 = ~(net_1283 & net_3468);
  assign net_1283 = (net_2911 & net_2176);
  assign net_2909 = (net_2912 & net_2913);
  assign net_2913 = ~(net_1649 | net_2914);
  assign net_2914 = ~(net_2678 & net_2915);
  assign net_2915 = (net_2916 | a64_only);
  assign net_2916 = (net_2917 | net_2490);
  assign net_2490 = ~(net_549 & net_2918);
  assign net_2918 = (net_1436 & net_263);
  assign net_2917 = ~(net_2100 | net_2919);
  assign net_2919 = (decoder_fsm_i[1] & decoder_fsm_i[2]);
  assign net_2912 = (net_2920 & net_2921);
  assign net_2921 = ~(net_2922 & net_62);
  assign net_2920 = (net_2245 | iq_instr_fn_i[9]);
  assign net_2245 = ~(net_3465 & net_2547);
  assign net_2907 = (net_2414 & net_2923);
  assign net_2923 = ~(net_894 & net_2924);
  assign net_2924 = (net_347 & net_260);
  assign net_2897 = (net_2925 & net_2926);
  assign net_2926 = (net_2927 | iq_instr_fn_i[6]);
  assign net_2927 = (net_2928 & net_2929);
  assign net_2929 = ~(net_26 | net_2181);
  assign net_2181 = (net_109 & net_536);
  assign net_2928 = (net_159 & net_2931);
  assign net_2931 = (net_1327 | net_2932);
  assign net_2932 = ~(net_867 & net_1455);
  assign net_1327 = ~(net_2933 & net_1346);
  assign net_159 = (net_2007 & net_2934);
  assign net_2934 = ~(net_1205 & net_2299);
  assign net_2299 = (net_395 & net_21);
  assign net_2007 = ~(net_109 & net_2935);
  assign net_2925 = ~(net_2343 | net_2936);
  assign net_2936 = ~(net_2937 & net_2005);
  assign net_2005 = ~(net_200 & net_2938);
  assign net_2938 = (net_1376 & net_2939);
  assign net_2939 = ~(net_2940 & net_2941);
  assign net_2941 = ~(net_2942 & iq_instr_fn_i[24]);
  assign net_2942 = (net_410 & net_1720);
  assign net_2940 = ~(net_2943 & iq_instr_fn_i[23]);
  assign net_1376 = (iq_instr_fn_i[28] & net_1089);
  assign net_200 = ~(net_3464 | iq_instr_fn_i[10]);
  assign net_2937 = (net_2944 & net_2548);
  assign net_2548 = ~(net_834 & net_2945);
  assign net_2945 = ~(net_2946 & net_2947);
  assign net_2947 = ~(net_2806 & iq_instr_fn_i[10]);
  assign net_2806 = (net_373 & net_2948);
  assign net_2948 = (iq_instr_fn_i[20] & net_2949);
  assign net_2949 = (net_2950 | net_2951);
  assign net_2951 = (iq_instr_fn_i[21] & net_2952);
  assign net_2952 = (iq_instr_fn_i[28] & net_2422);
  assign net_2950 = ~(decoder_fsm_i[0] | net_2953);
  assign net_2953 = ~(net_3468 & net_3470);
  assign net_2946 = ~(net_2954 & net_104);
  assign net_2954 = (net_361 & net_2933);
  assign net_2944 = (net_2955 & net_2956);
  assign net_2956 = ~(net_161 & net_2957);
  assign net_2957 = ~(decoder_fsm_i[1] & net_21);
  assign net_2955 = (net_2958 & net_2959);
  assign net_2959 = (net_21 | net_1373);
  assign net_1373 = ~(net_109 & net_2960);
  assign net_2960 = ~(net_653 | net_52);
  assign net_2958 = (net_2102 & net_2961);
  assign net_2961 = (net_141 & net_2962);
  assign net_2962 = (iq_instr_fn_i[17] | net_2963);
  assign net_2963 = ~(net_1458 & net_2933);
  assign net_141 = (net_2729 | net_86);
  assign net_2173 = ~(net_87 | iq_instr_fn_i[9]);
  assign net_2729 = ~(net_1465 & net_61);
  assign net_1465 = (iq_instr_fn_i[25] & net_664);
  assign net_2102 = (net_1280 & net_2964);
  assign net_2964 = (net_29 | net_2965);
  assign net_2965 = (net_2966 | net_2967);
  assign net_2967 = (net_66 | net_1374);
  assign net_1374 = ~(iq_instr_fn_i[6] & decoder_fsm_i[1]);
  assign net_2966 = (net_79 | net_19);
  assign net_1280 = ~(net_269 & net_2968);
  assign net_2968 = (net_1089 & net_2012);
  assign net_2012 = ~(net_9 | net_37);
  assign net_2343 = (net_3466 & net_2969);
  assign net_2969 = ~(net_2970 & net_2509);
  assign net_2509 = ~(net_2971 & net_61);
  assign net_2970 = ~(net_546 | net_2972);
  assign net_2972 = (net_388 & net_2973);
  assign net_2973 = (net_432 | net_2974);
  assign net_2974 = (net_1554 & net_61);
  assign net_1554 = (net_2268 & net_2536);
  assign net_2536 = ~(net_24 & net_2975);
  assign net_2975 = (net_47 | net_31);
  assign net_2808 = (net_2976 & net_2977);
  assign net_2977 = (net_2212 & net_1843);
  assign net_1843 = ~(net_1791 & net_1259);
  assign net_2212 = (net_2978 | net_3466);
  assign net_2978 = (net_295 & net_2979);
  assign net_2979 = (net_147 | net_2612);
  assign net_2612 = (net_2980 & net_2981);
  assign net_2981 = ~(net_2834 & net_261);
  assign net_295 = (net_2982 & net_2983);
  assign net_2982 = (net_2984 & net_2985);
  assign net_2984 = (net_2986 & net_2987);
  assign net_2987 = (net_2988 & net_1051);
  assign net_2986 = (net_2989 & net_1809);
  assign net_1809 = (net_3464 | net_2027);
  assign net_2027 = ~(net_609 & net_2990);
  assign net_2990 = (net_72 & net_2991);
  assign net_2976 = (net_2992 & net_2993);
  assign net_2993 = (iq_instr_fn_i[9] | net_2994);
  assign net_2994 = (net_2995 & net_2996);
  assign net_2996 = ~(net_633 & net_2997);
  assign net_2997 = ~(net_2998 & net_2999);
  assign net_2999 = (net_52 | net_2428);
  assign net_2428 = (net_3000 | net_3001);
  assign net_3000 = ~(net_260 | net_3002);
  assign net_3002 = (iq_instr_fn_i[10] & iq_instr_fn_i[16]);
  assign net_2998 = (net_2229 & net_3003);
  assign net_3003 = ~(net_262 & net_3468);
  assign net_2995 = (net_3004 & net_3005);
  assign net_3005 = (net_1992 & net_3006);
  assign net_3006 = (net_38 | net_3007);
  assign net_3007 = ~(net_3008 | net_3009);
  assign net_3009 = (net_62 & iq_instr_fn_i[10]);
  assign net_1992 = ~(net_664 & net_3008);
  assign net_3008 = (iq_instr_fn_i[20] & net_973);
  assign net_3004 = (net_3010 & net_2523);
  assign net_2523 = ~(net_431 & net_3011);
  assign net_3011 = (net_1436 & net_457);
  assign net_457 = (net_1455 & net_2283);
  assign net_3010 = (net_1781 & net_3012);
  assign net_3012 = (net_2389 | net_3468);
  assign net_2389 = (net_35 | net_1408);
  assign net_1408 = ~(iq_instr_fn_i[4] & net_836);
  assign net_1781 = (iq_instr_fn_i[10] | net_3013);
  assign net_3013 = (net_3014 | net_58);
  assign net_3014 = (net_3015 & net_3016);
  assign net_3016 = ~(iq_instr_fn_i[7] & net_1868);
  assign net_2992 = (net_3017 & net_3018);
  assign net_3018 = (net_327 & net_1539);
  assign net_327 = (net_38 | net_1397);
  assign net_1397 = (net_3467 | net_2629);
  assign net_3017 = (net_3019 & net_2244);
  assign net_3019 = ~(add_neon_mask_sel | net_3020);
  assign net_3020 = ~(iq_instr_fn_i[11] | net_3021);
  assign net_3021 = ~(net_2254 & net_1455);
  assign add_neon_mask_sel = (net_1172 & net_3022);
  assign net_3022 = (net_536 | net_3023);
  assign net_3023 = (net_1250 & net_62);
  assign net_1172 = ~(net_3467 | net_27);
  assign add_neon_fctn_sel[0] = (net_184 | net_3024);
  assign net_3024 = ~(net_2540 & net_3025);
  assign net_3025 = ~(net_3026 | net_2107);
  assign net_2107 = ~(net_3027 & net_3028);
  assign net_3028 = (net_2678 & net_3029);
  assign net_3029 = (net_147 | net_3030);
  assign net_3030 = (net_20 & net_2770);
  assign net_2770 = (net_87 | net_2621);
  assign net_2621 = ~(decoder_fsm_i[0] & net_342);
  assign net_342 = (net_730 & net_347);
  assign net_2922 = (net_958 & net_3031);
  assign net_3031 = (net_1804 & net_2911);
  assign net_2911 = (decoder_fsm_i[1] & net_347);
  assign net_2678 = (net_1365 & net_3032);
  assign net_3032 = (net_3033 | net_3034);
  assign net_3034 = (net_308 | net_48);
  assign net_308 = ~(iq_instr_fn_i[8] & net_337);
  assign net_3033 = (net_3035 & net_3036);
  assign net_3036 = (sf_bit | net_3037);
  assign net_3037 = ~(iq_instr_fn_i[11] & iq_instr_fn_i[27]);
  assign net_3035 = (net_3471 | net_75);
  assign net_1365 = ~(net_3038 & net_337);
  assign net_3027 = ~(net_2491 | net_3039);
  assign net_3039 = ~(net_309 & net_2561);
  assign net_2561 = (a64_only | net_3040);
  assign net_3040 = ~(net_531 & net_3041);
  assign net_3041 = ~(net_3469 | net_93);
  assign net_309 = ~(net_549 & net_3042);
  assign net_3042 = (sf_bit & net_1610);
  assign net_2491 = (iq_instr_fn_i[9] & net_3043);
  assign net_3043 = (net_3044 | net_3045);
  assign net_3045 = (net_633 & net_3046);
  assign net_3046 = (net_2875 | net_3047);
  assign net_3047 = (net_3048 | net_3049);
  assign net_3049 = ~(net_85 | net_1340);
  assign net_3048 = (net_2254 & net_260);
  assign net_2254 = (net_95 & net_262);
  assign net_3044 = ~(net_3050 & net_3051);
  assign net_3051 = (net_3052 & net_3053);
  assign net_3053 = ~(net_1681 & iq_instr_fn_i[25]);
  assign net_1681 = (net_1804 & net_2798);
  assign net_2798 = (decoder_fsm_i[1] & net_2833);
  assign net_3052 = ~(net_1689 | net_1649);
  assign net_1649 = ~(decoder_fsm_i[0] | net_2695);
  assign net_2695 = ~(net_431 & net_557);
  assign net_557 = ~(net_3 | net_58);
  assign net_1689 = (net_546 | net_3054);
  assign net_3054 = (net_3055 | net_1948);
  assign net_1948 = (net_2268 & net_1871);
  assign net_1871 = ~(iq_instr_fn_i[10] | net_3056);
  assign net_3056 = ~(decoder_fsm_i[0] & net_3057);
  assign net_3057 = ~(net_3058 & net_3015);
  assign net_3058 = ~(iq_instr_fn_i[24] & net_3059);
  assign net_3059 = ~(net_95 | net_47);
  assign net_3055 = (net_1560 & net_432);
  assign net_432 = (net_633 & net_536);
  assign net_3050 = (net_2765 & net_3060);
  assign net_3060 = ~(net_2834 & net_2767);
  assign net_2767 = (net_3465 & net_1579);
  assign net_2765 = ~(decoder_fsm_i[1] & net_3061);
  assign net_3061 = ~(net_93 | net_7);
  assign net_3026 = ~(net_3062 & net_3063);
  assign net_3063 = (net_367 | net_2888);
  assign net_2888 = (net_2535 | net_1744);
  assign net_2535 = ~(net_78 & net_2893);
  assign net_3062 = ~(net_3064 | net_3065);
  assign net_3065 = (net_3066 | net_3067);
  assign net_3067 = (net_3068 | net_3069);
  assign net_3069 = ~(net_3070 & net_3071);
  assign net_3071 = ~(net_1259 & net_2253);
  assign net_2253 = ~(iq_instr_fn_i[11] | net_2677);
  assign net_2677 = ~(iq_instr_fn_i[7] & net_262);
  assign net_3070 = (net_1759 & net_2700);
  assign net_2700 = ~(iq_instr_fn_i[21] & net_2890);
  assign net_1759 = ~(net_546 | net_3072);
  assign net_3072 = (net_1956 & net_2232);
  assign net_2232 = (net_973 | net_1560);
  assign net_1956 = (net_1048 & net_536);
  assign net_536 = ~(net_64 | net_56);
  assign net_546 = (net_1838 & net_3073);
  assign net_3073 = (net_1853 | net_3074);
  assign net_3074 = ~(net_3015 | iq_instr_fn_i[28]);
  assign net_3015 = ~(net_3468 & net_494);
  assign net_1853 = (iq_instr_fn_i[25] & net_2833);
  assign net_2833 = ~(net_95 | net_48);
  assign net_1838 = (net_3465 & net_2268);
  assign net_3068 = (net_3075 & net_3466);
  assign net_3075 = ~(net_3076 & net_3077);
  assign net_3077 = (net_21 | net_2529);
  assign net_2529 = ~(net_1950 & net_3078);
  assign net_1950 = ~(net_95 | net_54);
  assign net_3076 = ~(net_138 | net_3079);
  assign net_3079 = ~(net_3080 & net_3081);
  assign net_3081 = ~(net_2875 & net_1455);
  assign net_2875 = (net_261 & net_1580);
  assign net_1580 = (net_1633 & net_1206);
  assign net_1206 = (net_75 & net_2334);
  assign net_3080 = (net_462 & net_2514);
  assign net_2514 = ~(net_2890 & net_61);
  assign net_2890 = (net_2268 & net_1881);
  assign net_1881 = ~(net_3082 | net_85);
  assign net_3082 = (net_24 & net_3083);
  assign net_3083 = (net_47 | net_30);
  assign net_1893 = ~(net_42 | iq_instr_fn_i[28]);
  assign net_462 = (net_517 & net_7);
  assign net_138 = ~(net_3084 & net_3085);
  assign net_3085 = ~(net_1929 & net_269);
  assign net_1929 = (net_351 & net_2218);
  assign net_2218 = ~(net_4 | iq_instr_fn_i[8]);
  assign net_3084 = (net_3086 & net_2201);
  assign net_2201 = ~(net_3087 & net_63);
  assign net_3087 = (net_1399 & net_904);
  assign net_1399 = (iq_instr_fn_i[11] & net_730);
  assign net_3086 = (net_2047 & net_3088);
  assign net_3088 = (net_2317 | net_2642);
  assign net_2642 = ~(net_2971 & net_60);
  assign net_1286 = ~(net_61 | net_346);
  assign net_2971 = (net_730 & net_973);
  assign net_2047 = ~(iq_instr_fn_i[11] & net_2630);
  assign net_2630 = (net_2268 & net_3089);
  assign net_3089 = (net_2574 & net_3090);
  assign net_3090 = ~(net_3091 & net_3092);
  assign net_3092 = (net_64 | net_3465);
  assign net_3091 = (net_37 | net_72);
  assign net_3066 = ~(net_3093 & net_3094);
  assign net_3094 = ~(net_410 & net_161);
  assign net_161 = (net_2591 & net_263);
  assign net_2591 = (net_1686 & net_395);
  assign net_395 = (net_18 & iq_instr_fn_i[11]);
  assign net_3093 = (net_3095 | net_2599);
  assign net_2599 = ~(net_21 & net_18);
  assign net_3095 = ~(net_973 & net_1205);
  assign net_1205 = (iq_instr_fn_i[9] & net_1612);
  assign net_973 = ~(net_3468 | iq_instr_fn_i[6]);
  assign net_3064 = (net_3096 | net_3097);
  assign net_3097 = (net_3098 | net_3099);
  assign net_3099 = ~(net_1904 & net_3100);
  assign net_3100 = (net_3101 & net_3102);
  assign net_3102 = (net_1335 | net_2195);
  assign net_2195 = (net_64 & net_3103);
  assign net_3103 = ~(net_3464 & net_104);
  assign net_1335 = ~(net_834 & net_2197);
  assign net_2197 = (net_373 & net_2933);
  assign net_2933 = (net_21 & net_261);
  assign net_834 = ~(net_3465 | iq_instr_fn_i[9]);
  assign net_3101 = (net_2353 & net_1840);
  assign net_1840 = ~(net_1610 & net_885);
  assign net_885 = ~(net_78 | iq_instr_fn_i[8]);
  assign net_2353 = (iq_instr_fn_i[20] | net_171);
  assign net_171 = ~(net_1571 & net_3104);
  assign net_1571 = (net_1669 & net_649);
  assign net_1904 = (net_2633 & net_3105);
  assign net_3105 = (net_1095 | net_924);
  assign net_924 = (net_3466 | iq_instr_fn_i[11]);
  assign net_1095 = ~(iq_instr_fn_i[23] & net_3106);
  assign net_3106 = (net_3107 | net_3108);
  assign net_3108 = (net_3109 & net_3110);
  assign net_3110 = ~(net_3467 | net_3463);
  assign net_3109 = (net_1868 & net_61);
  assign net_1868 = ~(net_47 | net_42);
  assign net_3107 = ~(net_2338 | net_3111);
  assign net_3111 = ~(net_370 & net_1731);
  assign net_1731 = (net_1089 & net_609);
  assign net_2633 = ~(net_3112 & net_3113);
  assign net_3113 = (net_3467 & net_3114);
  assign net_3114 = (net_3115 | net_3116);
  assign net_3116 = ~(net_3117 | iq_instr_fn_i[21]);
  assign net_3117 = ~(iq_instr_fn_i[4] & net_2312);
  assign net_2312 = ~(net_50 | net_3468);
  assign net_3115 = (net_2943 & net_1113);
  assign net_1113 = (net_3463 & iq_instr_fn_i[21]);
  assign net_2943 = (net_3118 & net_16);
  assign net_3118 = (net_450 & net_1959);
  assign net_1959 = ~(net_72 | net_85);
  assign net_3098 = ~(net_413 | net_2930);
  assign net_2930 = ~(net_549 & net_837);
  assign net_837 = ~(net_52 | net_27);
  assign net_413 = ~(decoder_fsm_i[0] | net_3119);
  assign net_3119 = (net_3465 & net_3464);
  assign net_3096 = (net_2208 | net_3120);
  assign net_3120 = (net_3121 | net_3122);
  assign net_3122 = (net_1276 | net_1918);
  assign net_1918 = (net_2603 | net_2446);
  assign net_2446 = (net_431 & net_3123);
  assign net_3123 = ~(net_27 | net_1340);
  assign net_2603 = (iq_instr_fn_i[8] & net_3124);
  assign net_3124 = ~(net_3125 & net_3126);
  assign net_3126 = ~(net_3127 & net_109);
  assign net_3127 = ~(net_230 | net_2179);
  assign net_230 = (net_3128 & net_3129);
  assign net_3129 = (net_3470 | net_1385);
  assign net_1385 = ~(iq_instr_fn_i[6] & net_410);
  assign net_410 = ~(decoder_fsm_i[0] | decoder_fsm_i[1]);
  assign net_3125 = (net_3130 | iq_instr_fn_i[24]);
  assign net_3130 = ~(net_104 & net_730);
  assign net_1276 = (iq_instr_fn_i[9] & net_3131);
  assign net_3131 = ~(net_2989 & net_3132);
  assign net_3132 = (net_2980 | net_147);
  assign net_2980 = (net_49 | net_46);
  assign net_2989 = (net_46 | net_1873);
  assign net_1873 = ~(iq_instr_fn_i[11] & net_3133);
  assign net_3133 = (net_1548 & net_1869);
  assign net_2208 = (net_3134 & net_3135);
  assign net_3135 = ~(net_2629 & net_3136);
  assign net_3136 = ~(net_3466 & net_62);
  assign net_1820 = (net_95 & net_147);
  assign net_2629 = (net_3469 | net_68);
  assign net_3134 = (iq_instr_fn_i[10] & net_1900);
  assign net_1900 = (net_730 & net_3471);
  assign net_2540 = (net_144 & net_3137);
  assign net_3137 = ~(iq_instr_fn_i[9] & net_1093);
  assign net_1093 = ~(net_2985 & net_3138);
  assign net_3138 = ~(net_1791 & net_1325);
  assign net_1325 = (net_3465 & net_633);
  assign net_1791 = (net_2893 & net_1415);
  assign net_2893 = (iq_instr_fn_i[19] & net_1189);
  assign net_1189 = (net_3467 & net_2991);
  assign net_2985 = ~(net_261 & net_3139);
  assign net_3139 = ~(net_3140 & net_3141);
  assign net_3141 = ~(net_2834 & iq_instr_fn_i[7]);
  assign net_2834 = (iq_instr_fn_i[25] & net_730);
  assign net_3140 = ~(net_1250 & net_1869);
  assign net_1869 = ~(net_50 | net_3469);
  assign net_1250 = ~(net_47 | net_56);
  assign net_144 = ~(net_257 & net_37);
  assign net_257 = (net_228 & net_61);
  assign net_147 = ~(iq_instr_fn_i[21] | iq_instr_fn_i[19]);
  assign net_228 = (net_730 & net_556);
  assign net_184 = ~(net_3142 & net_3143);
  assign net_3143 = ~(net_3144 & net_3145);
  assign net_3145 = (net_2339 & net_2935);
  assign net_2339 = ~(iq_instr_fn_i[11] | vd_eq_vm);
  assign net_3144 = (net_3146 | net_3147);
  assign net_3147 = ~(net_2577 | net_2328);
  assign net_2328 = (net_3471 | net_95);
  assign net_2577 = ~(net_705 & net_2393);
  assign net_2393 = ~(net_3148 & net_3149);
  assign net_3149 = (net_2020 | iq_instr_fn_i[9]);
  assign net_2020 = (iq_instr_fn_i[16] | net_452);
  assign net_452 = (net_72 | net_48);
  assign net_3148 = ~(net_370 & net_16);
  assign net_705 = ~(net_3470 | iq_instr_fn_i[6]);
  assign net_3146 = (net_3150 & net_3151);
  assign net_3151 = ~(net_3464 | net_21);
  assign net_3150 = (net_3152 | net_3153);
  assign net_3153 = (net_2058 & net_2485);
  assign net_2485 = ~(net_27 | iq_instr_fn_i[10]);
  assign net_2058 = (iq_instr_fn_i[19] & net_1415);
  assign net_3152 = (net_3466 & net_3154);
  assign net_3154 = (net_370 & net_250);
  assign net_3142 = (net_2556 & net_3155);
  assign net_3155 = (net_2368 | net_367);
  assign net_367 = (net_21 | net_27);
  assign net_2368 = ~(iq_instr_fn_i[8] & net_2722);
  assign net_2722 = (net_2991 & net_2422);
  assign net_2422 = (net_72 & net_95);
  assign net_2556 = (net_3156 & net_1538);
  assign net_1538 = ~(iq_instr_fn_i[28] & net_649);
  assign net_3156 = (net_2092 & net_3157);
  assign net_3157 = ~(iq_instr_fn_i[9] & net_3158);
  assign net_3158 = ~(net_3159 & net_2240);
  assign net_2240 = (net_3160 & net_2070);
  assign net_2070 = (net_351 | net_517);
  assign net_517 = (net_16 | net_33);
  assign net_3160 = ~(net_3161 | net_2668);
  assign net_2668 = ~(iq_instr_fn_i[8] | net_3162);
  assign net_3162 = (net_49 | net_8);
  assign net_3161 = (net_3163 | net_2028);
  assign net_2028 = ~(iq_instr_fn_i[6] | net_2247);
  assign net_2247 = ~(a64_only & net_2692);
  assign net_2692 = ~(iq_instr_fn_i[23] | net_1241);
  assign net_1241 = ~(net_250 & net_351);
  assign net_3163 = (net_1954 & net_3164);
  assign net_3164 = (net_3165 | net_269);
  assign net_3165 = (iq_instr_fn_i[21] & net_3166);
  assign net_3166 = (net_2324 | net_3167);
  assign net_3167 = ~(net_377 | iq_instr_fn_i[6]);
  assign net_377 = ~(net_1579 & net_450);
  assign net_450 = ~(net_75 | net_77);
  assign net_1579 = ~(net_72 | net_87);
  assign net_2324 = (net_260 & net_370);
  assign net_1954 = ~(net_13 | net_36);
  assign net_3159 = (net_3168 & net_3169);
  assign net_3169 = (net_3170 & net_2870);
  assign net_2870 = (net_21 | net_7);
  assign net_3170 = (net_3171 & net_3172);
  assign net_3172 = ~(net_2547 & net_93);
  assign net_2547 = ~(net_8 | net_80);
  assign net_3171 = (net_1517 & net_2983);
  assign net_2983 = (net_1964 | net_3173);
  assign net_3173 = (iq_instr_fn_i[8] | net_3174);
  assign net_3174 = ~(net_1363 & net_2991);
  assign net_1964 = ~(net_3464 & net_2334);
  assign net_1517 = ~(net_260 & net_3175);
  assign net_3175 = (net_736 & net_1200);
  assign net_1200 = (net_552 & net_1016);
  assign net_1016 = ~(net_3464 | net_13);
  assign net_736 = ~(net_75 | iq_instr_fn_i[16]);
  assign net_3168 = (net_3176 & net_2095);
  assign net_2095 = ~(iq_instr_fn_i[11] & net_3177);
  assign net_3177 = (net_1612 & net_3178);
  assign net_3178 = (net_3179 | net_3180);
  assign net_3180 = ~(iq_instr_fn_i[10] | net_3181);
  assign net_3181 = ~(net_1488 | net_3182);
  assign net_3182 = ~(net_1516 | iq_instr_fn_i[8]);
  assign net_1516 = ~(decoder_fsm_i[2] & net_3183);
  assign net_3183 = ~(iq_instr_fn_i[6] & net_3184);
  assign net_3184 = ~(iq_instr_fn_i[24] & decoder_fsm_i[1]);
  assign net_1488 = (net_3464 & net_1505);
  assign net_1505 = (net_21 & net_2597);
  assign net_2597 = ~(decoder_fsm_i[2] | net_18);
  assign net_3179 = ~(aarch64_state_i | net_3185);
  assign net_3185 = (net_50 | net_21);
  assign net_1612 = ~(net_52 | net_4);
  assign net_3176 = (net_3186 & net_3187);
  assign net_3187 = (net_49 | net_503);
  assign net_503 = (net_8 | net_93);
  assign net_363 = ~(net_50 | net_79);
  assign net_3186 = (net_2403 & net_3188);
  assign net_2403 = ~(net_1447 & net_1504);
  assign net_1504 = (net_351 & net_109);
  assign net_109 = ~(net_79 | net_31);
  assign net_1447 = (iq_instr_fn_i[6] & net_3189);
  assign net_3189 = (decoder_fsm_i[2] & net_3190);
  assign net_3190 = (net_3191 | net_3192);
  assign net_3192 = (decoder_fsm_i[1] & iq_instr_fn_i[8]);
  assign net_3191 = (net_2100 & net_2038);
  assign net_2038 = (net_16 & iq_instr_fn_i[23]);
  assign net_2100 = ~(decoder_fsm_i[1] | net_18);
  assign net_2092 = (net_3193 | net_2458);
  assign net_2458 = ~(iq_instr_fn_i[24] & net_1686);
  assign net_3193 = (iq_instr_fn_i[28] & net_3194);
  assign net_3194 = (net_1684 | net_79);
  assign net_1684 = (net_21 | net_18);
  assign add_fp_op[4] = (net_562 | net_3195);
  assign net_3195 = (net_682 | net_3196);
  assign net_3196 = ~(net_3197 & net_3198);
  assign net_3198 = ~(net_3199 | net_3200);
  assign net_3200 = (net_1439 | net_3201);
  assign net_3201 = ~(net_3202 & net_3203);
  assign net_3202 = (net_3204 & net_3205);
  assign net_3205 = ~(net_3206 & net_3207);
  assign net_3204 = (net_3208 & net_3209);
  assign net_3209 = (net_3210 | net_1140);
  assign net_3210 = (net_1417 & net_3211);
  assign net_3211 = ~(net_370 & net_74);
  assign net_1417 = ~(iq_instr_fn_i[7] & net_652);
  assign net_1439 = (iq_instr_fn_i[21] & net_3212);
  assign net_3199 = (net_1525 | net_3213);
  assign net_3213 = ~(net_585 & net_3214);
  assign net_3214 = ~(iq_instr_fn_i[8] & net_2184);
  assign net_2184 = (net_2334 & net_1506);
  assign net_1506 = (net_263 & net_1317);
  assign net_585 = ~(net_3078 & net_1317);
  assign net_3078 = (net_72 & net_1058);
  assign net_1058 = ~(a64_only | net_35);
  assign net_1525 = (net_593 & net_1259);
  assign net_682 = ~(net_3466 | net_3215);
  assign add_fp_op[3] = (net_3216 | net_3217);
  assign net_3217 = (net_3218 | net_3219);
  assign net_3219 = (net_1491 | net_3220);
  assign net_3220 = ~(net_3221 & net_3222);
  assign net_3222 = (net_659 & net_3208);
  assign net_659 = (net_3223 & net_3224);
  assign net_3224 = ~(net_481 & net_2127);
  assign net_481 = (net_78 & net_1744);
  assign net_3223 = (net_1312 | iq_instr_fn_i[9]);
  assign net_1312 = ~(net_388 & net_201);
  assign net_3221 = (net_2116 & net_282);
  assign net_3218 = (net_3225 | net_3226);
  assign net_3226 = ~(net_2187 & net_3227);
  assign net_3227 = ~(net_562 | net_582);
  assign net_562 = ~(net_3466 | net_1512);
  assign net_1512 = (net_1182 | net_598);
  assign net_598 = ~(net_2334 & net_2127);
  assign net_1182 = ~(net_74 | iq_instr_fn_i[6]);
  assign net_2187 = (net_625 & net_3228);
  assign net_3228 = (net_2533 | net_3229);
  assign net_3229 = ~(net_241 & net_10);
  assign net_2533 = (iq_instr_fn_i[19] | net_419);
  assign net_625 = (net_3230 | net_3466);
  assign net_3230 = (net_1092 & net_3231);
  assign net_3231 = (net_1178 | net_3465);
  assign net_3225 = (net_10 & net_3232);
  assign net_3232 = (net_738 | net_3233);
  assign net_3233 = ~(net_74 | net_73);
  assign net_3216 = (net_3234 | net_3235);
  assign net_3235 = ~(net_3236 & net_3237);
  assign net_3237 = ~(net_3238 & net_74);
  assign net_3234 = (net_3239 & net_3240);
  assign net_3240 = (net_1001 & iq_instr_fn_i[18]);
  assign net_3239 = (net_2935 & iq_instr_fn_i[17]);
  assign net_2935 = (iq_instr_fn_i[20] & net_365);
  assign net_365 = ~(net_59 | net_91);
  assign add_fp_op[2] = ~(net_3241 & net_3242);
  assign net_3242 = ~(net_10 & net_1600);
  assign net_1600 = ~(net_74 | iq_instr_fn_i[17]);
  assign net_3241 = ~(net_1046 | net_3243);
  assign net_3243 = (net_3244 | net_3245);
  assign net_3245 = (net_1146 | net_3246);
  assign net_3246 = ~(net_3197 & net_1054);
  assign net_1054 = (iq_instr_fn_i[8] | net_1178);
  assign net_3197 = ~(net_570 | net_3247);
  assign net_3247 = ~(net_3248 & net_3249);
  assign net_3249 = (net_1184 & net_2116);
  assign net_2116 = ~(net_261 & net_3250);
  assign net_1184 = ~(net_1363 & net_593);
  assign net_1363 = ~(iq_instr_fn_i[10] | net_31);
  assign net_3248 = ~(net_1067 | net_3251);
  assign net_3251 = (net_1687 | net_3252);
  assign net_3252 = ~(net_3253 | net_95);
  assign net_1067 = (net_531 & net_3254);
  assign net_3254 = (net_3255 & net_3256);
  assign net_3256 = (net_904 & iq_instr_fn_i[19]);
  assign net_904 = ~(net_3464 | net_37);
  assign net_3255 = (net_1173 & iq_instr_fn_i[27]);
  assign net_1173 = (iq_instr_fn_i[17] & net_3257);
  assign net_3257 = (net_1436 & net_95);
  assign net_1436 = ~(net_59 | net_66);
  assign net_570 = (net_2505 & net_68);
  assign net_1146 = (net_3258 | net_3259);
  assign net_3259 = (net_582 | net_3260);
  assign net_3260 = ~(net_3261 & net_218);
  assign net_218 = (net_3262 | net_3466);
  assign net_3262 = (net_2988 & net_3263);
  assign net_3263 = (net_2823 & net_3215);
  assign net_3215 = ~(iq_instr_fn_i[8] & net_3264);
  assign net_3264 = (iq_instr_fn_i[16] & net_2183);
  assign net_2823 = (iq_instr_fn_i[8] | net_3265);
  assign net_3265 = (iq_instr_fn_i[4] | net_3266);
  assign net_3266 = ~(net_868 & net_25);
  assign net_868 = (net_3470 & net_269);
  assign net_2988 = ~(net_269 & net_2470);
  assign net_2470 = (net_932 & net_59);
  assign net_932 = (iq_instr_fn_i[27] & net_127);
  assign net_127 = (net_3465 & net_3471);
  assign net_3261 = (net_3267 & net_3268);
  assign net_3268 = ~(iq_instr_fn_i[16] & net_3269);
  assign net_3269 = (net_1458 & net_261);
  assign net_1458 = (net_1633 & net_1259);
  assign net_3267 = ~(net_1048 & net_3270);
  assign net_3270 = (net_262 & net_839);
  assign net_839 = ~(net_3467 | net_95);
  assign net_582 = (net_3271 | net_3272);
  assign net_3272 = ~(net_1511 | net_3466);
  assign net_1511 = (net_3273 & net_3274);
  assign net_3274 = ~(net_2131 & net_2138);
  assign net_2138 = ~(iq_instr_fn_i[18] | net_3275);
  assign net_3275 = (net_23 | net_28);
  assign net_3273 = (net_1055 & net_512);
  assign net_512 = (net_3276 & net_3277);
  assign net_3277 = (net_3467 | net_3278);
  assign net_3278 = (iq_instr_fn_i[4] | net_3279);
  assign net_3279 = ~(net_1720 & net_3280);
  assign net_3280 = ~(net_981 & net_3);
  assign net_981 = (net_33 | iq_instr_fn_i[20]);
  assign net_3276 = (net_2794 | net_6);
  assign net_2794 = ~(iq_instr_fn_i[28] & net_1720);
  assign net_1720 = ~(net_3465 | net_3468);
  assign net_1055 = ~(a64_only & net_654);
  assign net_654 = (net_633 & net_3281);
  assign net_3281 = ~(net_74 | net_67);
  assign net_3271 = (net_3466 & net_3282);
  assign net_3282 = (net_3283 & iq_instr_fn_i[24]);
  assign net_3283 = (net_3284 & net_3285);
  assign net_3285 = (net_942 | net_943);
  assign net_943 = ~(net_3470 | iq_instr_fn_i[8]);
  assign net_942 = ~(net_42 | iq_instr_fn_i[20]);
  assign net_3284 = ~(net_5 | net_3471);
  assign net_3258 = ~(net_3286 & net_3287);
  assign net_3287 = ~(iq_instr_fn_i[9] & net_3288);
  assign net_3286 = (net_282 & net_1539);
  assign net_282 = ~(net_3250 & net_2472);
  assign net_2472 = ~(net_3467 | net_3464);
  assign net_3250 = (net_1610 & net_95);
  assign net_3244 = ~(net_3289 & net_3236);
  assign net_3236 = (net_3290 & net_711);
  assign net_711 = (net_3128 | net_1541);
  assign net_3128 = (net_59 | iq_instr_fn_i[6]);
  assign net_3290 = (net_3291 & net_1785);
  assign net_1785 = ~(a64_only & net_3292);
  assign net_3292 = (net_556 & net_3293);
  assign net_3291 = ~(net_3294 | net_3295);
  assign net_3295 = (net_774 & net_3296);
  assign net_3296 = (net_2800 & net_609);
  assign net_3289 = ~(net_3212 | net_3297);
  assign net_3297 = ~(net_3298 & net_1535);
  assign net_1535 = ~(net_3299 & net_50);
  assign net_3299 = ~(net_1265 | net_5);
  assign net_1265 = ~(iq_instr_fn_i[27] & net_836);
  assign net_3212 = (net_2180 & net_3238);
  assign net_3238 = ~(net_3464 | net_1541);
  assign net_1046 = ~(net_27 | net_2229);
  assign net_2229 = ~(net_1103 & net_1607);
  assign net_1103 = (net_1633 & net_2807);
  assign net_2807 = ~(net_3465 | net_3467);
  assign add_fp_op[1] = (net_1491 | net_3300);
  assign net_3300 = (net_3301 | net_3302);
  assign net_3302 = (net_3303 | net_2185);
  assign net_2185 = ~(net_2656 & net_3304);
  assign net_3304 = (net_3305 & net_1295);
  assign net_1295 = (net_3306 | net_3307);
  assign net_3306 = (net_48 & net_3308);
  assign net_3308 = ~(net_2672 & net_1014);
  assign net_2672 = (net_16 & iq_instr_fn_i[8]);
  assign net_3305 = (net_1364 & net_3309);
  assign net_3309 = (net_3310 | net_3311);
  assign net_3311 = ~(net_261 & net_347);
  assign net_3310 = ~(net_3312 & net_3313);
  assign net_3313 = ~(iq_instr_fn_i[4] & net_21);
  assign net_3312 = (net_894 & iq_instr_fn_i[8]);
  assign net_1364 = (net_3466 | net_3188);
  assign net_3188 = ~(net_2815 & net_1346);
  assign net_2815 = (iq_instr_fn_i[10] & net_551);
  assign net_551 = (iq_instr_fn_i[8] & net_361);
  assign net_2656 = ~(iq_instr_fn_i[9] & net_3314);
  assign net_3314 = ~(net_3315 & net_3316);
  assign net_3316 = ~(net_3317 & iq_instr_fn_i[20]);
  assign net_3317 = (net_3318 & net_3319);
  assign net_3319 = (net_2528 & net_1744);
  assign net_2528 = ~(net_87 | net_31);
  assign net_3318 = (net_1607 & net_867);
  assign net_3315 = ~(net_1560 & net_360);
  assign net_360 = (net_3463 & net_673);
  assign net_673 = ~(net_47 | net_9);
  assign net_1560 = (net_3465 & net_431);
  assign net_3303 = (iq_instr_fn_i[18] & net_3320);
  assign net_3320 = (iq_instr_fn_i[8] & net_1180);
  assign net_1180 = (net_2127 & net_78);
  assign net_3301 = (net_3321 | net_3322);
  assign net_3322 = (net_3323 | net_3324);
  assign net_3324 = ~(net_3325 & net_1795);
  assign net_1795 = (iq_instr_fn_i[8] | net_3326);
  assign net_3326 = ~(net_653 & net_1015);
  assign net_653 = ~(net_3466 | net_16);
  assign net_3325 = (net_3327 & net_3328);
  assign net_3328 = ~(net_2180 & net_14);
  assign net_2180 = ~(net_74 | iq_instr_fn_i[7]);
  assign net_3327 = (net_3208 & net_3329);
  assign net_3329 = (net_3330 & net_3331);
  assign net_3331 = ~(iq_instr_fn_i[20] & net_2136);
  assign net_3330 = (net_3332 & net_3333);
  assign net_3333 = (net_3334 & net_3335);
  assign net_3335 = (net_1548 | net_3336);
  assign net_3336 = ~(net_269 & net_664);
  assign net_664 = ~(net_42 | net_58);
  assign net_1804 = ~(net_59 | net_93);
  assign net_1548 = (net_3470 & net_95);
  assign net_3334 = ~(net_3337 | net_3338);
  assign net_3338 = (net_361 & net_3339);
  assign net_3339 = ~(net_21 | net_3340);
  assign net_3340 = (net_3341 & net_3342);
  assign net_3342 = ~(net_1011 & net_3468);
  assign net_1011 = (net_347 & net_3469);
  assign net_347 = ~(net_3466 | net_47);
  assign net_3341 = ~(net_1014 & net_346);
  assign net_1014 = ~(net_3466 | net_3467);
  assign net_3337 = ~(net_421 | net_3343);
  assign net_3343 = ~(net_737 & net_3344);
  assign net_3344 = (iq_instr_fn_i[19] & net_1607);
  assign net_3332 = ~(net_3121 | net_3345);
  assign net_3345 = ~(net_3346 & net_3347);
  assign net_3347 = (net_2144 | net_3464);
  assign net_2144 = ~(net_1089 & net_649);
  assign net_649 = (net_50 & net_894);
  assign net_3346 = ~(net_3348 & net_3349);
  assign net_3349 = (net_263 & net_1669);
  assign net_3348 = (net_2697 & iq_instr_fn_i[11]);
  assign net_3121 = (iq_instr_fn_i[8] & net_256);
  assign net_256 = ~(net_2564 | net_498);
  assign net_498 = (net_21 | net_80);
  assign net_3208 = ~(net_639 | net_3350);
  assign net_3350 = (net_3351 & net_3352);
  assign net_3352 = (net_703 | net_709);
  assign net_709 = ~(net_33 | net_43);
  assign net_703 = (net_800 & net_50);
  assign net_3351 = ~(iq_instr_fn_i[4] | net_64);
  assign net_639 = (iq_instr_fn_i[20] & net_3353);
  assign net_3353 = (net_678 & net_3104);
  assign net_3104 = ~(net_47 & net_3464);
  assign net_678 = ~(net_421 | net_3354);
  assign net_3354 = ~(net_337 & net_50);
  assign net_421 = ~(iq_instr_fn_i[27] & iq_instr_fn_i[26]);
  assign net_3323 = ~(net_3355 & net_3356);
  assign net_3356 = (net_596 | iq_instr_fn_i[16]);
  assign net_596 = ~(net_370 & net_643);
  assign net_643 = (net_1089 & net_15);
  assign net_3355 = ~(net_3357 | net_569);
  assign net_569 = (net_2334 & net_665);
  assign net_665 = (net_370 & net_737);
  assign net_737 = ~(net_2179 | net_420);
  assign net_420 = ~(net_526 & net_16);
  assign net_2179 = (net_3469 | iq_instr_fn_i[4]);
  assign net_3357 = (net_3358 & net_3359);
  assign net_3359 = (iq_instr_fn_i[19] & net_250);
  assign net_3358 = ~(net_67 | net_16);
  assign net_3321 = ~(net_3360 & net_620);
  assign net_620 = (net_3203 & net_3361);
  assign net_3361 = (net_322 | net_91);
  assign net_322 = ~(net_663 & net_800);
  assign net_800 = ~(net_33 | iq_instr_fn_i[23]);
  assign net_3203 = (net_74 | net_32);
  assign net_3207 = (iq_instr_fn_i[20] & net_675);
  assign net_675 = (net_867 & net_578);
  assign net_3360 = ~(net_1043 | net_3362);
  assign net_3362 = ~(net_3363 & net_2119);
  assign net_2119 = ~(net_1415 & net_2127);
  assign net_2127 = ~(net_31 | net_53);
  assign net_3363 = ~(net_576 | net_3364);
  assign net_3364 = ~(net_3365 & net_3366);
  assign net_3366 = (net_3367 & net_1539);
  assign net_1539 = ~(net_269 & net_268);
  assign net_268 = (net_2317 & net_435);
  assign net_435 = ~(net_9 | net_3463);
  assign net_3367 = (net_3368 & net_3369);
  assign net_3369 = (net_3370 | net_3371);
  assign net_3371 = ~(net_3466 & net_59);
  assign net_3370 = (net_3372 & net_3373);
  assign net_3373 = ~(net_201 & net_3465);
  assign net_201 = (net_250 & net_1477);
  assign net_3372 = ~(net_1551 & net_663);
  assign net_1551 = (iq_instr_fn_i[28] & net_3374);
  assign net_3374 = (net_3463 & net_3375);
  assign net_3375 = (net_907 | net_3376);
  assign net_3376 = (iq_instr_fn_i[24] & net_638);
  assign net_638 = ~(net_3465 | sf_bit);
  assign net_907 = ~(a64_only | iq_instr_fn_i[6]);
  assign net_3368 = (net_3377 | net_3466);
  assign net_3377 = (net_1092 & net_3378);
  assign net_3378 = (net_3379 & net_1336);
  assign net_1336 = (net_87 | net_2564);
  assign net_2564 = ~(net_361 & net_1346);
  assign net_1346 = (net_346 | net_104);
  assign net_104 = ~(net_47 | iq_instr_fn_i[20]);
  assign net_361 = (net_3464 & net_373);
  assign net_373 = (net_16 & net_867);
  assign net_3379 = ~(net_1824 | net_3380);
  assign net_3380 = (net_3038 & net_3381);
  assign net_3381 = (net_110 & net_66);
  assign net_110 = (net_867 & net_3464);
  assign net_867 = ~(net_59 | iq_instr_fn_i[4]);
  assign net_3038 = (net_3468 & net_336);
  assign net_1824 = (net_3382 & net_3383);
  assign net_3383 = (net_836 & net_431);
  assign net_3382 = (net_674 & net_250);
  assign net_1092 = ~(net_663 & net_923);
  assign net_923 = ~(net_9 | net_91);
  assign net_3365 = (net_3384 & net_3385);
  assign net_3385 = (net_1242 | net_3386);
  assign net_3386 = ~(net_1633 & net_263);
  assign net_1242 = ~(iq_instr_fn_i[16] & net_260);
  assign net_260 = ~(net_3465 | net_87);
  assign net_431 = (net_3468 & net_3467);
  assign net_3384 = (net_3387 & net_3388);
  assign net_3388 = ~(net_388 & net_1610);
  assign net_388 = (net_3465 & net_3468);
  assign net_3387 = ~(net_3389 | net_3294);
  assign net_3294 = (iq_instr_fn_i[6] & net_1725);
  assign net_1725 = ~(iq_instr_fn_i[21] | net_1541);
  assign net_3389 = ~(net_3390 & net_3391);
  assign net_3391 = ~(net_575 & net_76);
  assign net_575 = (net_3392 & net_50);
  assign net_3392 = (iq_instr_fn_i[26] & net_3112);
  assign net_3112 = (net_552 & net_1589);
  assign net_1589 = ~(net_59 | net_3464);
  assign net_3390 = ~(net_118 & net_2258);
  assign net_118 = ~(net_79 | iq_instr_fn_i[9]);
  assign net_549 = (net_3467 & iq_instr_fn_i[11]);
  assign net_1043 = (net_2543 & net_835);
  assign net_835 = (iq_instr_fn_i[8] & net_263);
  assign net_263 = ~(net_3466 | net_31);
  assign net_2543 = ~(net_80 | net_1340);
  assign net_1340 = ~(net_1633 & net_241);
  assign net_241 = (net_75 & net_78);
  assign net_1491 = (net_1185 & net_3393);
  assign net_3393 = (net_2060 | net_3466);
  assign net_2060 = ~(net_95 | iq_instr_fn_i[8]);
  assign net_1185 = (net_2183 & net_78);
  assign net_2183 = ~(net_4 | net_53);
  assign add_fp_op[0] = (net_3394 | net_3395);
  assign net_3395 = (net_3396 | net_3397);
  assign net_3397 = (net_1072 | net_1702);
  assign net_1702 = (net_3398 | net_1350);
  assign net_1350 = (net_2334 & net_3399);
  assign net_3399 = ~(iq_instr_fn_i[18] | net_588);
  assign net_588 = ~(net_1317 & net_1259);
  assign net_1259 = ~(net_3466 | net_34);
  assign net_1317 = ~(net_3467 | net_54);
  assign net_2334 = (net_95 & net_78);
  assign net_3398 = (iq_instr_fn_i[18] & net_3400);
  assign net_3400 = ~(net_3307 | net_1418);
  assign net_1418 = ~(net_958 | net_1839);
  assign net_1839 = ~(net_3466 | a64_only);
  assign net_958 = ~(net_50 | iq_instr_fn_i[10]);
  assign net_3307 = ~(iq_instr_fn_i[28] & net_593);
  assign net_593 = ~(net_78 | net_54);
  assign net_2991 = (net_1633 & net_2288);
  assign net_2288 = ~(net_75 | iq_instr_fn_i[11]);
  assign net_1072 = (net_3401 | net_3402);
  assign net_3402 = ~(net_2125 | net_3253);
  assign net_3253 = (net_72 | net_1140);
  assign net_2125 = (net_3465 | net_74);
  assign net_3401 = (net_2198 & net_3403);
  assign net_3403 = (net_252 & net_555);
  assign net_555 = ~(net_91 | net_63);
  assign net_1029 = ~(iq_instr_fn_i[20] | iq_instr_fn_i[21]);
  assign net_252 = (net_3466 & net_269);
  assign net_2198 = (net_336 | net_609);
  assign net_3396 = ~(net_3404 & net_3405);
  assign net_3405 = (net_3406 & net_3407);
  assign net_3407 = (net_3408 & net_3409);
  assign net_3409 = (net_3466 | net_1051);
  assign net_1051 = ~(net_663 & net_1220);
  assign net_1220 = (net_348 & net_3465);
  assign net_3408 = (net_288 & net_3410);
  assign net_3410 = (net_3411 & net_3412);
  assign net_3412 = ~(iq_instr_fn_i[31] & net_1687);
  assign net_1687 = (net_576 | net_2136);
  assign net_2136 = (net_674 & net_3413);
  assign net_3413 = (net_714 & net_3414);
  assign net_3414 = (net_2697 | net_3415);
  assign net_3415 = (net_749 & iq_instr_fn_i[22]);
  assign net_749 = ~(net_47 | iq_instr_fn_i[21]);
  assign net_2697 = ~(net_3470 | iq_instr_fn_i[23]);
  assign net_714 = ~(iq_instr_fn_i[24] | a64_only);
  assign net_674 = ~(net_3463 | iq_instr_fn_i[8]);
  assign net_576 = ~(iq_instr_fn_i[22] | net_691);
  assign net_691 = ~(net_1569 & net_3465);
  assign net_1569 = (net_730 & net_531);
  assign net_3411 = (net_2414 & net_3416);
  assign net_3416 = (net_3417 & net_3418);
  assign net_3418 = ~(net_1455 & net_3419);
  assign net_3419 = (net_1477 & net_556);
  assign net_556 = ~(net_3468 | iq_instr_fn_i[9]);
  assign net_1477 = ~(net_16 | net_3470);
  assign net_3417 = ~(net_729 | net_3420);
  assign net_3420 = (net_2176 & net_3421);
  assign net_3421 = (net_1444 & iq_instr_fn_i[11]);
  assign net_1444 = ~(net_3466 | net_3471);
  assign net_2176 = ~(net_9 | net_93);
  assign net_1669 = ~(net_3463 | net_3465);
  assign net_729 = (iq_instr_fn_i[7] & net_2505);
  assign net_2505 = (net_269 & net_730);
  assign net_730 = ~(net_42 | net_56);
  assign net_2268 = ~(net_3463 | net_59);
  assign net_2414 = ~(net_2258 & net_2800);
  assign net_2800 = ~(net_81 | iq_instr_fn_i[21]);
  assign net_1955 = ~(net_3466 | net_82);
  assign net_2258 = (net_3422 & net_3463);
  assign net_3422 = (net_2317 & net_836);
  assign net_288 = ~(net_2130 & net_3466);
  assign net_2130 = ~(iq_instr_fn_i[18] | net_3423);
  assign net_3423 = ~(net_2338 & net_1610);
  assign net_1610 = (a64_only & net_1015);
  assign net_1015 = (iq_instr_fn_i[23] & net_250);
  assign net_250 = (iq_instr_fn_i[24] & iq_instr_fn_i[27]);
  assign net_2338 = (net_3464 & net_95);
  assign net_3406 = (net_3424 & net_3425);
  assign net_3425 = (net_95 | net_1178);
  assign net_1178 = ~(net_262 & net_1737);
  assign net_1737 = ~(net_80 | net_31);
  assign net_3424 = (net_589 & net_3426);
  assign net_3426 = (net_1140 | net_3427);
  assign net_3427 = (net_3428 & net_3429);
  assign net_3429 = (net_3430 | net_74);
  assign net_3430 = (net_3431 & net_3432);
  assign net_3432 = ~(iq_instr_fn_i[8] & net_652);
  assign net_652 = ~(net_75 | net_78);
  assign net_3431 = (net_3433 | iq_instr_fn_i[19]);
  assign net_3433 = (net_3001 & net_3434);
  assign net_3434 = (net_1778 | net_75);
  assign net_1778 = (net_78 | iq_instr_fn_i[7]);
  assign net_3001 = (net_95 | iq_instr_fn_i[17]);
  assign net_3428 = (net_3435 & net_3436);
  assign net_3436 = ~(iq_instr_fn_i[19] & net_1744);
  assign net_1744 = ~(net_3465 | net_95);
  assign net_3435 = (net_73 | net_419);
  assign net_419 = ~(net_74 & iq_instr_fn_i[7]);
  assign net_370 = ~(net_75 | iq_instr_fn_i[19]);
  assign net_1140 = ~(net_1686 & net_526);
  assign net_589 = (net_1515 | net_3437);
  assign net_3437 = ~(net_1082 & net_3438);
  assign net_3438 = (net_1415 & iq_instr_fn_i[17]);
  assign net_1415 = (net_78 & iq_instr_fn_i[7]);
  assign net_1082 = ~(net_3467 | iq_instr_fn_i[9]);
  assign net_1515 = ~(net_1686 & net_2317);
  assign net_1686 = (net_16 & net_1633);
  assign net_3404 = (net_2244 & net_2117);
  assign net_2117 = ~(net_3466 & net_3439);
  assign net_3439 = (net_1157 | net_3440);
  assign net_3440 = (net_3441 | net_632);
  assign net_632 = (net_3442 & net_3464);
  assign net_3442 = (iq_instr_fn_i[28] & net_3288);
  assign net_3288 = (net_663 & net_348);
  assign net_348 = ~(net_9 | iq_instr_fn_i[4]);
  assign net_894 = (net_16 & net_59);
  assign net_663 = ~(net_3470 | net_82);
  assign net_3441 = (net_1293 & net_269);
  assign net_269 = ~(net_3468 | net_3467);
  assign net_1293 = (net_3443 & net_59);
  assign net_3443 = (net_774 & net_3444);
  assign net_3444 = ~(net_3 & net_3445);
  assign net_3445 = ~(net_23 & net_2651);
  assign net_2651 = ~(net_3470 | net_31);
  assign net_494 = ~(a64_only | net_64);
  assign net_346 = ~(net_3469 | iq_instr_fn_i[21]);
  assign net_774 = (net_3463 & iq_instr_fn_i[8]);
  assign net_1157 = (net_2131 & net_3293);
  assign net_3293 = (net_552 & net_836);
  assign net_552 = ~(net_3469 | net_3471);
  assign net_2244 = ~(net_261 & net_1083);
  assign net_1083 = (net_1455 & net_262);
  assign net_262 = ~(net_52 | net_76);
  assign net_1455 = ~(net_50 | net_35);
  assign net_2317 = ~(net_3471 | iq_instr_fn_i[8]);
  assign net_261 = ~(net_3467 | iq_instr_fn_i[11]);
  assign net_3394 = ~(net_3446 & net_3447);
  assign net_3447 = (net_3298 | net_3465);
  assign net_3298 = ~(net_3448 & net_3206);
  assign net_3206 = ~(iq_instr_fn_i[7] | net_1607);
  assign net_3448 = (net_1633 & net_578);
  assign net_578 = (iq_instr_fn_i[19] & net_1001);
  assign net_1001 = (net_336 & net_526);
  assign net_526 = ~(net_3464 | net_43);
  assign net_531 = ~(net_47 | iq_instr_fn_i[24]);
  assign net_336 = (iq_instr_fn_i[27] & net_3471);
  assign net_1633 = (iq_instr_fn_i[23] & net_1089);
  assign net_3446 = (net_2159 & net_3449);
  assign net_3449 = (net_3450 & net_3451);
  assign net_3451 = ~(iq_instr_fn_i[6] & net_1721);
  assign net_1721 = ~(net_999 | iq_instr_fn_i[24]);
  assign net_999 = ~(iq_instr_fn_i[28] & net_836);
  assign net_836 = ~(net_42 | iq_instr_fn_i[23]);
  assign net_3450 = (net_617 & net_3452);
  assign net_3452 = (net_3453 & net_3454);
  assign net_3454 = (iq_instr_fn_i[20] | net_3455);
  assign net_3455 = (net_1541 | net_59);
  assign net_1541 = (net_4 | iq_instr_fn_i[24]);
  assign net_609 = ~(net_3471 | a64_only);
  assign net_3453 = ~(net_1559 & net_42);
  assign net_1559 = (iq_instr_fn_i[11] & net_1031);
  assign net_1031 = (net_633 & net_337);
  assign net_337 = ~(net_16 | net_59);
  assign net_617 = ~(net_1048 & net_3456);
  assign net_3456 = ~(net_42 | net_5);
  assign net_2131 = ~(net_3468 | net_16);
  assign net_1048 = (net_3466 & net_633);
  assign net_633 = ~(net_50 | net_3471);
  assign net_2159 = ~(net_1089 & net_3457);
  assign net_3457 = (net_224 & net_3458);
  assign net_3458 = ~(net_3459 & net_3460);
  assign net_3460 = ~(net_3461 & net_59);
  assign net_3461 = (iq_instr_fn_i[27] & net_3464);
  assign net_3459 = ~(iq_instr_fn_i[25] & net_3462);
  assign net_3462 = (net_738 & net_1132);
  assign net_1132 = ~(net_59 | net_17);
  assign net_2574 = ~(a64_only | net_3464);
  assign net_738 = (net_2283 & net_74);
  assign net_2283 = (net_95 & net_1607);
  assign net_1607 = ~(net_78 | iq_instr_fn_i[17]);
  assign net_224 = ~(iq_instr_fn_i[24] | iq_instr_fn_i[28]);
  assign net_1089 = (net_3463 & net_351);
  assign net_351 = ~(net_3469 | net_3470);
  assign net_3463 = ~iq_instr_fn_i[4];
  assign net_3464 = ~iq_instr_fn_i[6];
  assign net_3465 = ~iq_instr_fn_i[8];
  assign net_3466 = ~iq_instr_fn_i[9];
  assign net_3467 = ~iq_instr_fn_i[10];
  assign net_3468 = ~iq_instr_fn_i[11];
  assign net_3469 = ~iq_instr_fn_i[20];
  assign net_3470 = ~iq_instr_fn_i[21];
  assign net_3471 = ~iq_instr_fn_i[28];

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  // Do this in an always block to allow extra signals to be added to fp_pipectl
  // without requiring decoder changes
  always @* begin
    fp_mul_ctl = {`CA53_FP_MUL_CTL_W{1'b0}};
    fp_add_ctl = {`CA53_FP_ADD_CTL_W{1'b0}};

    fp_mul_ctl[`CA53_FP_MUL_NEON_OUT_FMT_BITS]      = mul_neon_out_fmt_iss_i;
    fp_mul_ctl[`CA53_FP_MUL_NEON_TYPE_BITS]         = mul_neon_mul_type;
    fp_mul_ctl[`CA53_FP_MUL_NEON_ROUND_BITS]        = mul_neon_round;
    fp_mul_ctl[`CA53_FP_MUL_NEON_SAT_DBL_BITS]      = mul_neon_sat_dbl;
    fp_mul_ctl[`CA53_FP_MUL_NEON_FIXUP_BITS]        = mul_neon_fixup;
    fp_mul_ctl[`CA53_FP_MUL_NEON_INT_OP_BITS]       = mul_neon_int_op;
    fp_mul_ctl[`CA53_FP_MUL_NEON_VECTOR_OP_BITS]    = mul_vector_op;
    fp_mul_ctl[`CA53_FP_MUL_NEON_INV_IS_ZERO_BITS]  = mul_neon_inv_is_zero;
    fp_mul_ctl[`CA53_FP_MUL_FUSED_MAC_BITS]         = mul_fused_mac;
    fp_mul_ctl[`CA53_FP_MUL_PRECISION_BITS]         = mul_precision;
    fp_mul_ctl[`CA53_FP_MUL_DIVIDE_BITS]            = mul_divide;
    fp_mul_ctl[`CA53_FP_MUL_NEG_SQRT_BITS]          = mul_negate | mul_sqrt;

    fp_add_ctl[`CA53_FP_NEON_ADD_MASK_SEL_BITS]     = add_neon_mask_sel;
    fp_add_ctl[`CA53_FP_NEON_ADD_VTST_OP_SEL_BITS]  = add_neon_vtst_op_sel;
    fp_add_ctl[`CA53_FP_NEON_ADD_SAT_OP_SEL_BITS]   = add_neon_sat_op_sel;
    fp_add_ctl[`CA53_FP_NEON_ADD_WIDTH_OP_SEL_BITS] = add_neon_width_op_sel;
    fp_add_ctl[`CA53_FP_NEON_ADD_FCTN_SEL_BITS]     = add_neon_fctn_sel;
    fp_add_ctl[`CA53_FP_NEON_ADD_UNSIGNED_OP_BITS]  = add_neon_unsigned_op;
    fp_add_ctl[`CA53_FP_NEON_ADD_VTB_CYCLE_BITS]    = add_neon_vtb_cycle;
    fp_add_ctl[`CA53_FP_NEON_ADD_PERM_SEL_BITS]     = add_neon_perm_sel;
    fp_add_ctl[`CA53_FP_NEON_ADD_SIZE_SEL_BITS]     = add_neon_size_sel;
    fp_add_ctl[`CA53_FP_NEON_ADD_LU_CTL_BITS]       = add_neon_lu_ctl;
    fp_add_ctl[`CA53_FP_NEON_ADD_NEON_MUX_SEL_BITS] = add_neon_mux_sel;
    fp_add_ctl[`CA53_FP_NEON_ADD_NEON_INT_SEL_BITS] = add_neon_int_sel;
    fp_add_ctl[`CA53_FP_ADD_VECTOR_FP_OP_BITS]      = add_vector_fp_op;
    fp_add_ctl[`CA53_FP_ADD_FP_OP_BITS]             = add_fp_op;
  end

  always @* begin : combine_fp_pipectl
    reg [`CA53_FP_PIPECTL_W-1:0] tmp_pipectl;
    tmp_pipectl = {`CA53_FP_PIPECTL_W{1'b0}};

    // OR the control fields together to allow fields to overlap when they're disjoint
    tmp_pipectl[`CA53_FP_PIPECTL_RMODE_BITS]       = tmp_pipectl[`CA53_FP_PIPECTL_RMODE_BITS] |
                                                     ((rounding_mode == `CA53_FP_RMODE_NEON) ? (aarch64_state_i ? `CA53_FP_RMODE_FPCR
                                                                                                                : `CA53_FP_RMODE_RN)
                                                                                             : rounding_mode);

    tmp_pipectl[`CA53_FP_PIPECTL_FORCE_DN_FZ_BITS] = tmp_pipectl[`CA53_FP_PIPECTL_FORCE_DN_FZ_BITS] |
                                                     (force_dn_fz & ~aarch64_state_i);


    tmp_pipectl[`CA53_FP_PIPECTL_MUL_CTL_BITS]     = tmp_pipectl[`CA53_FP_PIPECTL_MUL_CTL_BITS] | fp_mul_ctl;
    tmp_pipectl[`CA53_FP_PIPECTL_ADD_CTL_BITS]     = tmp_pipectl[`CA53_FP_PIPECTL_ADD_CTL_BITS] | fp_add_ctl;
    tmp_pipectl[`CA53_CRYPTO_OP_W-1:0]             = tmp_pipectl[`CA53_CRYPTO_OP_W-1:0] | crypto_op;

    fp_pipectl_neon_o = tmp_pipectl;
  end

  // ------------------------------------------------------
  // Output aliasing
  // ------------------------------------------------------

  // Force signals to defaults if a nop/undefined instruction occurs
  assign fp_cflag_src_neon_o = exception_valid_iss_i ? {`CA53_FP_CFLAG_SRC_W{1'b0}} : fp_cflag_src_neon;
  assign fp_xflag_src_neon_o = exception_valid_iss_i ? {`CA53_FP_XFLAG_SRC_W{1'b0}} : fp_xflag_src_neon;

endmodule // ca53dpu_dec_late_neon

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53_dpu_dcu_defs.v"
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
