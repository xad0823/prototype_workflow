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
// Abstract: Block to calculate result for VRECPE and VRSQRTE instructions
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_neon_vrec_est #(parameter EXP_SIZE = 8) (
  // Inputs
  input  wire                 int_op_f3_i,            // Integer or floating-point instruction
  input  wire                 neon_rsqrte_f3_i,       // Selects VRSQRTE instead of VRECPE
  input  wire                 double_prec_f3_i,       // Double precision operation
  input  wire                 fz_f3_i,                // Flush-to-zero mode is enabled
  input  wire  [EXP_SIZE-1:0] a_exp_f3_i,             // Input exponent (for floating-point)
  input  wire          [51:0] a_frac_f3_i,            // Fraction bits
  input  wire           [5:0] mant_lz_f3_i,           // Number of leading zero bits in fraction
  // Outputs
  output wire          [31:0] vrec_est_int_res_f3_o,  // Output fraction bits
  output wire          [10:0] vrec_est_frc_f3_o,      // Output fraction bits
  output wire  [EXP_SIZE+1:0] vrec_est_exp_f3_o,      // Output exponent
  output wire                 vrec_udf_f3_o           // Underflow caused in VRECPE
);

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                int_overflow;
  wire                flt_underflow;
  wire                exp_bit0_f3;    // Bottom bit of exponent
  wire          [7:0] fp_frac_top;
  wire          [7:0] frac_top_f3;    // Top eight bits of fraction
  wire          [7:0] result_frac_f3; // Output top fraction bits
  wire [EXP_SIZE+1:0] recip_exp;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  generate if (EXP_SIZE == 11) begin : g_norm_dual
    wire [51:0] norm_frac;

    assign norm_frac = a_frac_f3_i << mant_lz_f3_i;
    assign fp_frac_top = norm_frac[51:44];
  end else begin : g_norm_sp
    wire [22:0] norm_frac;

    assign norm_frac = a_frac_f3_i[51:29] << mant_lz_f3_i;
    assign fp_frac_top = norm_frac[22:15];
  end endgenerate

  assign exp_bit0_f3 = int_op_f3_i ? ~a_frac_f3_i[51]
                                   : (a_exp_f3_i[0] ^ mant_lz_f3_i[0]);

  assign frac_top_f3 = int_op_f3_i ? (neon_rsqrte_f3_i & ~a_frac_f3_i[51])
                                        ? a_frac_f3_i[49:42]
                                        : a_frac_f3_i[50:43]
                                   : fp_frac_top;

  assign int_overflow = neon_rsqrte_f3_i ? (a_frac_f3_i[51:50] == 2'b00)
                                         : (a_frac_f3_i[51]    == 1'b0);

  generate if (EXP_SIZE == 11) begin : g_dual_prec
    assign recip_exp = (double_prec_f3_i ? (neon_rsqrte_f3_i ? 13'd3068 : 13'd2045)
                                         : (neon_rsqrte_f3_i ? 13'd380  : 13'd253)) - a_exp_f3_i + mant_lz_f3_i;

    assign flt_underflow = ~int_op_f3_i & ~neon_rsqrte_f3_i & fz_f3_i
                            & (double_prec_f3_i ? ((a_exp_f3_i == 11'h7FD) | (a_exp_f3_i == 11'h7FE))
                                                : ((a_exp_f3_i == 11'h0FD) | (a_exp_f3_i == 11'h0FE)));
  end else begin : g_single_prec
    assign recip_exp = (neon_rsqrte_f3_i ? 10'd380 : 10'd253) - a_exp_f3_i + mant_lz_f3_i[4:0];

    assign flt_underflow = ~int_op_f3_i & ~neon_rsqrte_f3_i & fz_f3_i &
                           ((a_exp_f3_i == 8'hFD) | (a_exp_f3_i == 8'hFE));
  end endgenerate

  assign vrec_est_exp_f3_o = neon_rsqrte_f3_i ? {recip_exp[EXP_SIZE+1], recip_exp[EXP_SIZE+1:1]} :
                             flt_underflow    ? {EXP_SIZE+2{1'b0}}                               :
                                                recip_exp[EXP_SIZE+1:0];

  assign vrec_udf_f3_o = flt_underflow;

  // ------------------------------------------------------
  // Start automatically generated logic
  // ------------------------------------------------------

  wire   net_921, net_922, net_923, net_924, net_925, net_926, net_927,
         net_928, net_929, net_930, net_931, net_932, net_933, net_934,
         net_935, net_936, net_937, net_938, net_939, net_940, net_941,
         net_942, net_943, net_944, net_945, net_946, net_947, net_948,
         net_949, net_950, net_951, net_952, net_953, net_954, net_955,
         net_956, net_957, net_958, net_959, net_960, net_961, net_962,
         net_963, net_964, net_965, net_966, net_967, net_968, net_969,
         net_970, net_971, net_972, net_973, net_974, net_975, net_976,
         net_977, net_978, net_979, net_980, net_981, net_982, net_983,
         net_984, net_985, net_986, net_987, net_988, net_989, net_990,
         net_991, net_992, net_993, net_994, net_995, net_996, net_997,
         net_998, net_999, net_1000, net_1001, net_1002, net_1003, net_1004,
         net_1005, net_1006, net_1007, net_1008, net_1009, net_1010, net_1011,
         net_1012, net_1013, net_1014, net_1015, net_1016, net_1017, net_1018,
         net_1019, net_1020, net_1021, net_1022, net_1023, net_1024, net_1025,
         net_1026, net_1027, net_1028, net_1029, net_1030, net_1031, net_1032,
         net_1033, net_1034, net_1035, net_1036, net_1037, net_1038, net_1039,
         net_1040, net_1041, net_1042, net_1043, net_1044, net_1045, net_1046,
         net_1047, net_1048, net_1049, net_1050, net_1051, net_1052, net_1053,
         net_1054, net_1055, net_1056, net_1057, net_1058, net_1059, net_1060,
         net_1061, net_1062, net_1063, net_1064, net_1065, net_1066, net_1067,
         net_1068, net_1069, net_1070, net_1071, net_1072, net_1073, net_1074,
         net_1075, net_1076, net_1077, net_1078, net_1079, net_1080, net_1081,
         net_1082, net_1083, net_1084, net_1085, net_1086, net_1087, net_1088,
         net_1089, net_1090, net_1091, net_1092, net_1093, net_1094, net_1095,
         net_1096, net_1097, net_1098, net_1099, net_1100, net_1101, net_1102,
         net_1103, net_1104, net_1105, net_1106, net_1107, net_1108, net_1109,
         net_1110, net_1111, net_1112, net_1113, net_1114, net_1115, net_1116,
         net_1117, net_1118, net_1119, net_1120, net_1121, net_1122, net_1123,
         net_1124, net_1125, net_1126, net_1127, net_1128, net_1129, net_1130,
         net_1131, net_1132, net_1133, net_1134, net_1135, net_1136, net_1137,
         net_1138, net_1139, net_1140, net_1141, net_1142, net_1143, net_1144,
         net_1145, net_1146, net_1147, net_1148, net_1149, net_1150, net_1151,
         net_1152, net_1153, net_1154, net_1155, net_1156, net_1157, net_1158,
         net_1159, net_1160, net_1161, net_1162, net_1163, net_1164, net_1165,
         net_1166, net_1167, net_1168, net_1169, net_1170, net_1171, net_1172,
         net_1173, net_1174, net_1175, net_1176, net_1177, net_1178, net_1179,
         net_1180, net_1181, net_1182, net_1183, net_1184, net_1185, net_1186,
         net_1187, net_1188, net_1189, net_1190, net_1191, net_1192, net_1193,
         net_1194, net_1195, net_1196, net_1197, net_1198, net_1199, net_1200,
         net_1201, net_1202, net_1203, net_1204, net_1205, net_1206, net_1207,
         net_1208, net_1209, net_1210, net_1211, net_1212, net_1213, net_1214,
         net_1215, net_1216, net_1217, net_1218, net_1219, net_1220, net_1221,
         net_1222, net_1223, net_1224, net_1225, net_1226, net_1227, net_1228,
         net_1229, net_1230, net_1231, net_1232, net_1233, net_1234, net_1235,
         net_1236, net_1237, net_1238, net_1239, net_1240, net_1241, net_1242,
         net_1243, net_1244, net_1245, net_1246, net_1247, net_1248, net_1249,
         net_1250, net_1251, net_1252, net_1253, net_1254, net_1255, net_1256,
         net_1257, net_1258, net_1259, net_1260, net_1261, net_1262, net_1263,
         net_1264, net_1265, net_1266, net_1267, net_1268, net_1269, net_1270,
         net_1271, net_1272, net_1273, net_1274, net_1275, net_1276, net_1277,
         net_1278, net_1279, net_1280, net_1281, net_1282, net_1283, net_1284,
         net_1285, net_1286, net_1287, net_1288, net_1289, net_1290, net_1291,
         net_1292, net_1293, net_1294, net_1295, net_1296, net_1297, net_1298,
         net_1299, net_1300, net_1301, net_1302, net_1303, net_1304, net_1305,
         net_1306, net_1307, net_1308, net_1309, net_1310, net_1311, net_1312,
         net_1313, net_1314, net_1315, net_1316, net_1317, net_1318, net_1319,
         net_1320, net_1321, net_1322, net_1323, net_1324, net_1325, net_1326,
         net_1327, net_1328, net_1329, net_1330, net_1331, net_1332, net_1333,
         net_1334, net_1335, net_1336, net_1337, net_1338, net_1339, net_1340,
         net_1341, net_1342, net_1343, net_1344, net_1345, net_1346, net_1347,
         net_1348, net_1349, net_1350, net_1351, net_1352, net_1353, net_1354,
         net_1355, net_1356, net_1357, net_1358, net_1359, net_1360, net_1361,
         net_1362, net_1363, net_1364, net_1365, net_1366, net_1367, net_1368,
         net_1369, net_1370, net_1371, net_1372, net_1373, net_1374, net_1375,
         net_1376, net_1377, net_1378, net_1379, net_1380, net_1381, net_1382,
         net_1383, net_1384, net_1385, net_1386, net_1387, net_1388, net_1389,
         net_1390, net_1391, net_1392, net_1393, net_1394, net_1395, net_1396,
         net_1397, net_1398, net_1399, net_1400, net_1401, net_1402, net_1403,
         net_1404, net_1405, net_1406, net_1407, net_1408, net_1409, net_1410,
         net_1411, net_1412, net_1413, net_1414, net_1415, net_1416, net_1417,
         net_1418, net_1419, net_1420, net_1421, net_1422, net_1423, net_1424,
         net_1425, net_1426, net_1427, net_1428, net_1429, net_1430, net_1431,
         net_1432, net_1433, net_1434, net_1435, net_1436, net_1437, net_1438,
         net_1439, net_1440, net_1441, net_1442, net_1443, net_1444, net_1445,
         net_1446, net_1447, net_1448, net_1449, net_1450, net_1451, net_1452,
         net_1453, net_1454, net_1455, net_1456, net_1457, net_1458, net_1459,
         net_1460, net_1461, net_1462, net_1463, net_1464, net_1465, net_1466,
         net_1467, net_1468, net_1469, net_1470, net_1471, net_1472, net_1473,
         net_1474, net_1475, net_1476, net_1477, net_1478, net_1479, net_1480,
         net_1481, net_1482, net_1483, net_1484, net_1485, net_1486, net_1487,
         net_1488, net_1489, net_1490, net_1491, net_1492, net_1493, net_1494,
         net_1495, net_1496, net_1497, net_1498, net_1499, net_1500, net_1501,
         net_1502, net_1503, net_1504, net_1505, net_1506, net_1507, net_1508,
         net_1509, net_1510, net_1511, net_1512, net_1513, net_1514, net_1515,
         net_1516, net_1517, net_1518, net_1519, net_1520, net_1521, net_1522,
         net_1523, net_1524, net_1525, net_1526, net_1527, net_1528, net_1529,
         net_1530, net_1531, net_1532, net_1533, net_1534, net_1535, net_1536,
         net_1537, net_1538, net_1539, net_1540, net_1541, net_1542, net_1543,
         net_1544, net_1545, net_1546, net_1547, net_1548, net_1549, net_1550,
         net_1551, net_1552, net_1553, net_1554, net_1555, net_1556, net_1557,
         net_1558, net_1559, net_1560, net_1561, net_1562, net_1563, net_1564,
         net_1565, net_1566, net_1567, net_1568, net_1569, net_1570, net_1571,
         net_1572, net_1573, net_1574, net_1575, net_1576, net_1577, net_1578,
         net_1579, net_1580, net_1581, net_1582, net_1583, net_1584, net_1585,
         net_1586, net_1587, net_1588, net_1589, net_1590, net_1591, net_1592,
         net_1593, net_1594, net_1595, net_1596, net_1597, net_1598, net_1599,
         net_1600, net_1601, net_1602, net_1603, net_1604, net_1605, net_1606,
         net_1607, net_1608, net_1609, net_1610, net_1611, net_1612, net_1613,
         net_1614, net_1615, net_1616, net_1617, net_1618, net_1619, net_1620,
         net_1621, net_1622, net_1623, net_1624, net_1625, net_1626, net_1627,
         net_1628, net_1629, net_1630, net_1631, net_1632, net_1633, net_1634,
         net_1635, net_1636, net_1637, net_1638, net_1639, net_1640, net_1641,
         net_1642, net_1643, net_1644, net_1645, net_1646, net_1647, net_1648,
         net_1649, net_1650, net_1651, net_1652, net_1653, net_1654, net_1655,
         net_1656, net_1657, net_1658, net_1659, net_1660, net_1661, net_1662,
         net_1663, net_1664, net_1665, net_1666, net_1667, net_1668, net_1669,
         net_1670, net_1671, net_1672, net_1673, net_1674, net_1675, net_1676,
         net_1677, net_1678, net_1679, net_1680, net_1681, net_1682, net_1683,
         net_1684, net_1685, net_1686, net_1687, net_1688, net_1689, net_1690,
         net_1691, net_1692, net_1693, net_1694, net_1695, net_1696, net_1697,
         net_1698, net_1699, net_1700, net_1701, net_1702, net_1703, net_1704,
         net_1705, net_1706, net_1707, net_1708, net_1709, net_1710, net_1711,
         net_1712, net_1713, net_1714, net_1715, net_1716, net_1717, net_1718,
         net_1719, net_1720, net_1721, net_1722, net_1723, net_1724, net_1725,
         net_1726, net_1727, net_1728, net_1729, net_1730, net_1731, net_1732,
         net_1733, net_1734, net_1735, net_1736, net_1737, net_1738, net_1739,
         net_1740, net_1741, net_1742, net_1743, net_1744, net_1745, net_1746,
         net_1747, net_1748, net_1749, net_1750, net_1751, net_1752, net_1753,
         net_1754, net_1755;

  assign result_frac_f3[7] = ~(net_921 & net_922);
  assign net_922 = ~(net_923 & net_924);
  assign net_924 = (net_925 | net_926);
  assign net_921 = neon_rsqrte_f3_i ? net_928 : net_927;
  assign net_928 = ~(exp_bit0_f3 & net_929);
  assign net_929 = ~(net_930 & frac_top_f3[7]);
  assign net_930 = (frac_top_f3[6] & net_931);
  assign net_927 = ~(net_932 & net_933);
  assign net_932 = ~(net_934 | frac_top_f3[5]);
  assign result_frac_f3[6] = ~(net_935 & net_936);
  assign net_936 = neon_rsqrte_f3_i ? net_938 : net_937;
  assign net_938 = (net_939 & net_940);
  assign net_940 = ~(net_941 & net_925);
  assign net_939 = (net_942 & net_943);
  assign net_942 = ~(exp_bit0_f3 & net_944);
  assign net_944 = ~(net_945 & net_946);
  assign net_946 = (net_941 | net_947);
  assign net_937 = (net_948 & net_949);
  assign net_949 = ~(net_950 & net_951);
  assign net_948 = (net_952 & net_953);
  assign net_952 = ~(net_954 & net_955);
  assign net_935 = (net_956 & net_957);
  assign net_957 = ~(net_958 & net_923);
  assign net_923 = ~(neon_rsqrte_f3_i | frac_top_f3[7]);
  assign net_956 = (net_959 | net_960);
  assign result_frac_f3[5] = ~(net_961 & net_962);
  assign net_962 = (net_963 & net_964);
  assign net_964 = ~(net_965 & net_941);
  assign net_965 = (net_966 | net_967);
  assign net_963 = (net_968 | net_960);
  assign net_961 = (net_969 & net_970);
  assign net_970 = ~(net_971 & net_951);
  assign net_969 = neon_rsqrte_f3_i ? net_973 : net_972;
  assign net_973 = (net_974 & net_975);
  assign net_975 = exp_bit0_f3 ? net_977 : net_976;
  assign net_977 = (net_978 & net_979);
  assign net_979 = (net_980 & net_981);
  assign net_981 = (net_982 | frac_top_f3[2]);
  assign net_978 = (net_947 & net_983);
  assign net_983 = (net_984 | net_925);
  assign net_976 = (net_985 & net_986);
  assign net_986 = ~(net_987 & net_988);
  assign net_987 = ~(net_989 | net_934);
  assign net_985 = ~(net_990 | net_967);
  assign net_974 = (net_991 & net_992);
  assign net_992 = (net_993 | frac_top_f3[2]);
  assign net_991 = ~(net_994 & net_941);
  assign net_972 = (net_995 & net_996);
  assign net_996 = (net_997 & net_998);
  assign net_998 = (net_999 | net_1000);
  assign net_997 = (net_1001 & net_1002);
  assign net_1001 = ~(net_1003 & net_1004);
  assign net_1004 = ~(net_1005 & net_1006);
  assign net_1006 = ~(net_1007 & net_1008);
  assign net_1005 = (net_984 | net_1009);
  assign net_995 = (net_1010 & net_1011);
  assign net_1010 = net_1014 ? net_1013 : net_1012;
  assign net_1012 = ~(net_1015 & net_1016);
  assign result_frac_f3[4] = ~(net_1017 & net_1018);
  assign net_1018 = (net_1019 & net_1020);
  assign net_1020 = (net_1021 | net_960);
  assign net_1019 = (net_1022 & net_1023);
  assign net_1022 = ~(net_1024 & net_1025);
  assign net_1024 = ~(net_984 | net_1009);
  assign net_1017 = (net_1026 & net_1027);
  assign net_1027 = ~(net_1028 & net_1029);
  assign net_1026 = neon_rsqrte_f3_i ? net_1031 : net_1030;
  assign net_1031 = (net_1032 & net_1033);
  assign net_1033 = (net_982 | net_1034);
  assign net_1032 = exp_bit0_f3 ? net_1036 : net_1035;
  assign net_1036 = (net_1037 & net_1038);
  assign net_1038 = (net_1039 & net_1040);
  assign net_1040 = ~(net_1041 & net_950);
  assign net_1039 = (net_1042 & net_1043);
  assign net_1042 = ~(frac_top_f3[7] & net_1044);
  assign net_1044 = (net_966 | net_950);
  assign net_1037 = (net_1045 & net_1046);
  assign net_1045 = (net_1047 & net_1048);
  assign net_1048 = ~(net_1049 & net_933);
  assign net_1035 = (net_1050 & net_1051);
  assign net_1051 = (net_1052 & net_1053);
  assign net_1053 = (net_1054 & net_1055);
  assign net_1054 = ~(net_1056 & net_1057);
  assign net_1052 = (net_1058 & net_1059);
  assign net_1059 = ~(net_1029 & net_955);
  assign net_955 = (net_1014 | net_1009);
  assign net_1058 = ~(net_1060 & net_1061);
  assign net_1050 = (net_1062 & net_1011);
  assign net_1011 = (net_1063 & net_1064);
  assign net_1064 = ~(net_1015 & frac_top_f3[7]);
  assign net_1063 = ~(net_988 & net_1065);
  assign net_1062 = (net_1066 & net_980);
  assign net_980 = (net_1067 | frac_top_f3[7]);
  assign net_1066 = (net_1068 | net_1069);
  assign net_1030 = (net_1070 & net_1071);
  assign net_1071 = (net_1072 & net_1073);
  assign net_1073 = (net_1074 & net_1075);
  assign net_1074 = ~(net_1076 | net_1077);
  assign net_1072 = (net_1078 & net_1079);
  assign net_1079 = (net_1080 | net_1081);
  assign net_1078 = (net_1082 & net_1083);
  assign net_1083 = ~(net_1084 & net_1085);
  assign net_1084 = (net_1061 & net_1086);
  assign net_1082 = ~(net_1087 & net_1014);
  assign net_1087 = (net_1088 | net_1089);
  assign net_1089 = (net_966 & net_1016);
  assign net_1016 = ~(net_1090 & net_1091);
  assign net_1091 = ~(net_1034 & net_1008);
  assign net_1070 = (net_1092 & net_1093);
  assign net_1093 = (net_1094 & net_1095);
  assign net_1095 = (net_1096 | net_1067);
  assign net_1094 = (net_1097 & net_1098);
  assign net_1098 = ~(frac_top_f3[2] & net_1099);
  assign net_1099 = ~(net_1100 & net_1101);
  assign net_1101 = ~(frac_top_f3[0] & net_1102);
  assign net_1102 = (net_1029 | net_1103);
  assign net_1097 = ~(net_994 & net_951);
  assign net_951 = ~(net_1104 & net_1105);
  assign net_1105 = (net_1069 | frac_top_f3[7]);
  assign net_1092 = (net_1106 & net_1107);
  assign net_1107 = (net_1043 | net_941);
  assign net_1106 = net_1008 ? net_1108 : net_1100;
  assign net_1108 = (net_1109 & net_1110);
  assign net_1110 = ~(net_1111 & net_1112);
  assign net_1112 = (net_1113 | net_1114);
  assign result_frac_f3[3] = ~(net_1115 & net_1116);
  assign net_1116 = (net_1117 & net_1118);
  assign net_1118 = ~(net_1119 & net_988);
  assign net_1119 = ~(net_1043 | net_960);
  assign net_1117 = ~(net_933 & net_1120);
  assign net_1120 = (net_1088 | net_1121);
  assign net_1115 = (net_1122 & net_1123);
  assign net_1123 = ~(exp_bit0_f3 & net_1124);
  assign net_1124 = ~(net_1125 & net_1126);
  assign net_1126 = (net_1080 | net_1013);
  assign net_1122 = neon_rsqrte_f3_i ? net_1128 : net_1127;
  assign net_1128 = (net_1129 & net_1130);
  assign net_1130 = (net_1131 & net_1132);
  assign net_1131 = ~(net_950 & net_1133);
  assign net_1133 = ~(net_1096 & net_1134);
  assign net_1134 = ~(net_933 & frac_top_f3[2]);
  assign net_1129 = (net_1135 & net_1136);
  assign net_1136 = ~(net_1137 & net_1076);
  assign net_1135 = exp_bit0_f3 ? net_1139 : net_1138;
  assign net_1139 = (net_1140 & net_1141);
  assign net_1141 = (net_1142 & net_1143);
  assign net_1143 = ~(net_1144 & net_994);
  assign net_1144 = ~(net_934 | frac_top_f3[3]);
  assign net_1142 = (net_1145 & net_1146);
  assign net_1140 = (net_1147 & net_1148);
  assign net_1148 = net_1034 ? net_1150 : net_1149;
  assign net_1150 = (net_1151 & net_1152);
  assign net_1152 = ~(net_1077 | net_971);
  assign net_1151 = (net_1153 & net_1002);
  assign net_1002 = ~net_1076;
  assign net_1153 = ~(net_988 & frac_top_f3[4]);
  assign net_1147 = (net_1154 & net_1155);
  assign net_1154 = (net_1156 | net_1104);
  assign net_1138 = (net_1157 & net_1158);
  assign net_1158 = (net_1159 & net_1160);
  assign net_1160 = (net_1161 & net_1162);
  assign net_1161 = (net_1163 & net_1164);
  assign net_1159 = (net_1165 & net_945);
  assign net_1165 = ~(net_1166 & net_1029);
  assign net_1157 = (net_1167 & net_1168);
  assign net_1168 = (net_1169 & net_1170);
  assign net_1170 = ~(net_1114 & net_950);
  assign net_1169 = (net_1171 & net_1172);
  assign net_1172 = ~(net_1028 & net_1173);
  assign net_1171 = (net_1055 | frac_top_f3[2]);
  assign net_1167 = (net_1174 & net_1175);
  assign net_1175 = ~(net_1176 & net_958);
  assign net_1127 = (net_1177 & net_1178);
  assign net_1178 = (net_1179 & net_1180);
  assign net_1180 = (net_1181 & net_1182);
  assign net_1182 = ~(net_988 & net_1183);
  assign net_1183 = ~(net_1013 & net_1184);
  assign net_1184 = ~(net_1015 & net_1000);
  assign net_1181 = (net_1185 & net_1125);
  assign net_1185 = ~(net_1186 & net_966);
  assign net_1186 = (frac_top_f3[7] & net_1086);
  assign net_1179 = (net_1187 & net_1188);
  assign net_1188 = ~(net_1113 & net_1173);
  assign net_1187 = (net_1189 & net_1190);
  assign net_1190 = ~(net_1191 & net_1192);
  assign net_1177 = (net_1193 & net_1194);
  assign net_1194 = (net_1195 & net_1196);
  assign net_1196 = net_1198 ? net_945 : net_1197;
  assign net_1197 = (net_984 | net_989);
  assign net_1195 = (net_1199 & net_1200);
  assign net_1200 = ~(net_1176 & net_1003);
  assign net_1193 = (net_1201 & net_1202);
  assign net_1202 = net_960 ? net_982 : net_1203;
  assign net_960 = ~net_1000;
  assign net_1000 = (net_1069 & net_1204);
  assign net_1204 = (net_1008 | net_1034);
  assign net_982 = ~(net_1173 & net_933);
  assign net_1201 = (net_1205 & net_1206);
  assign net_1206 = net_1008 ? net_1208 : net_1207;
  assign net_1208 = (net_1209 & net_1210);
  assign net_1210 = (net_1211 & net_945);
  assign net_1211 = (net_1212 | net_1090);
  assign net_1212 = ~net_1213;
  assign net_1209 = (net_1214 & net_1215);
  assign net_1215 = ~(net_1216 & net_1003);
  assign net_1214 = ~(net_1191 & net_1137);
  assign net_1207 = (net_1217 & net_1218);
  assign net_1218 = (net_1219 & net_1220);
  assign net_1220 = ~(net_1221 & frac_top_f3[7]);
  assign net_1219 = (net_1222 | frac_top_f3[1]);
  assign net_1217 = (net_1223 & net_1224);
  assign net_1224 = ~(net_1225 & net_1003);
  assign net_1223 = ~(net_1103 & net_1137);
  assign net_1205 = net_1034 ? net_1226 : net_1055;
  assign net_1226 = (net_1227 & net_1228);
  assign net_1228 = (net_1013 | net_1061);
  assign net_1055 = ~net_1229;
  assign result_frac_f3[2] = ~(net_1230 & net_1231);
  assign net_1231 = (net_1232 & net_1233);
  assign net_1233 = (net_1234 | net_934);
  assign net_1232 = (net_1235 & net_1236);
  assign net_1236 = ~(net_1137 & net_1237);
  assign net_1237 = ~(net_1145 & net_1238);
  assign net_1238 = ~(net_1239 & net_1061);
  assign net_1239 = (net_1003 & net_1008);
  assign net_1235 = ~(net_1007 & net_971);
  assign net_1230 = (net_1240 & net_1241);
  assign net_1241 = exp_bit0_f3 ? net_1243 : net_1242;
  assign net_1243 = (net_1244 & net_1245);
  assign net_1245 = ~(net_1246 & net_988);
  assign net_1244 = (net_1247 & net_1248);
  assign net_1248 = ~(net_1249 & net_1250);
  assign net_1250 = (neon_rsqrte_f3_i & net_1069);
  assign net_1249 = (net_1061 & net_958);
  assign net_1247 = ~(net_1114 & net_1251);
  assign net_1242 = ~(net_1252 & net_966);
  assign net_1252 = (net_988 & frac_top_f3[2]);
  assign net_1240 = (net_1253 & net_1254);
  assign net_1254 = ~(frac_top_f3[0] & net_1255);
  assign net_1255 = ~(net_1256 & net_1257);
  assign net_1257 = ~(net_1191 & net_1009);
  assign net_1256 = (net_1258 & net_1259);
  assign net_1259 = ~(net_1176 & net_1260);
  assign net_1260 = (net_966 | net_971);
  assign net_1258 = ~(net_1221 & net_988);
  assign net_1253 = neon_rsqrte_f3_i ? net_1262 : net_1261;
  assign net_1262 = (net_1263 & net_1264);
  assign net_1264 = (net_1265 & net_1266);
  assign net_1266 = ~(net_1009 & net_1267);
  assign net_1267 = ~(net_1268 & net_1021);
  assign net_1021 = ~net_1269;
  assign net_1268 = ~(net_1191 | net_1270);
  assign net_1191 = ~(net_1014 | net_1271);
  assign net_1265 = (net_1272 & net_1273);
  assign net_1273 = ~(net_1274 & net_1061);
  assign net_1274 = (net_1173 & net_934);
  assign net_1272 = ~(net_1216 & net_1025);
  assign net_1263 = (net_1275 & net_1276);
  assign net_1276 = exp_bit0_f3 ? net_1278 : net_1277;
  assign net_1278 = (net_1279 & net_1280);
  assign net_1280 = (net_1281 & net_1282);
  assign net_1282 = ~(net_1283 & net_1284);
  assign net_1283 = (net_1015 & net_1198);
  assign net_1281 = ~(net_950 & net_1285);
  assign net_1285 = (net_1216 | net_1286);
  assign net_1286 = (net_1287 & net_933);
  assign net_1216 = (net_1137 & net_941);
  assign net_1279 = (net_1288 & net_1289);
  assign net_1288 = net_1034 ? net_1291 : net_1290;
  assign net_1291 = (net_1292 & net_1293);
  assign net_1293 = (net_1294 & net_1295);
  assign net_1295 = ~net_1296;
  assign net_1294 = ~(net_1297 & net_941);
  assign net_1292 = (net_1298 & net_1299);
  assign net_1299 = (net_984 | frac_top_f3[6]);
  assign net_1298 = ~(net_1085 & frac_top_f3[3]);
  assign net_1290 = (net_1300 & net_1301);
  assign net_1301 = (net_1302 & net_1075);
  assign net_1300 = (net_1303 & net_1304);
  assign net_1304 = ~(net_988 & net_954);
  assign net_1303 = (net_999 | frac_top_f3[3]);
  assign net_1277 = (net_1305 & net_1306);
  assign net_1306 = (net_1307 & net_1308);
  assign net_1308 = (net_1309 & net_1310);
  assign net_1309 = (net_1311 & net_1312);
  assign net_1307 = (net_1313 & net_1314);
  assign net_1314 = ~(net_1166 & net_1060);
  assign net_1313 = (net_1315 & net_1316);
  assign net_1316 = ~(net_1317 & net_1251);
  assign net_1317 = (net_933 & net_1069);
  assign net_1315 = ~(net_1284 & net_1318);
  assign net_1318 = (net_1025 | net_1056);
  assign net_1305 = (net_1319 & net_1320);
  assign net_1320 = (net_1321 & net_1322);
  assign net_1322 = ~(net_1173 & net_1323);
  assign net_1321 = (net_1324 & net_1325);
  assign net_1325 = ~(net_1028 & net_971);
  assign net_1324 = ~(net_1225 & net_1029);
  assign net_1319 = (net_1326 & net_1327);
  assign net_1327 = ~(net_988 & net_1297);
  assign net_1297 = (net_967 | net_1049);
  assign net_1326 = net_1034 ? net_1222 : net_1328;
  assign net_1328 = (net_993 & net_1227);
  assign net_1275 = (net_1329 & net_1330);
  assign net_1330 = ~(net_1331 & net_988);
  assign net_1329 = (net_1332 | net_1067);
  assign net_1261 = (net_1333 & net_1334);
  assign net_1334 = (net_1335 & net_1336);
  assign net_1336 = (net_1337 & net_1338);
  assign net_1338 = (net_1222 | net_1198);
  assign net_1222 = ~(net_1025 & net_933);
  assign net_1337 = (net_1339 & net_1340);
  assign net_1340 = ~(net_1213 & net_1192);
  assign net_1192 = (net_1287 | net_1341);
  assign net_1341 = ~(net_1008 | frac_top_f3[2]);
  assign net_1339 = ~(net_1296 & net_1086);
  assign net_1086 = ~(net_1034 & net_1342);
  assign net_1342 = (net_1008 | net_1198);
  assign net_1335 = (net_1343 & net_1344);
  assign net_1344 = ~(net_1345 & net_1003);
  assign net_1343 = ~(net_1287 & net_1346);
  assign net_1346 = ~(net_1347 & net_1348);
  assign net_1348 = (net_1104 | net_999);
  assign net_1347 = (net_1302 & net_1349);
  assign net_1302 = ~(net_1065 & net_933);
  assign net_1333 = (net_1350 & net_1351);
  assign net_1351 = (net_1352 & net_1353);
  assign net_1353 = ~(net_1009 & net_1354);
  assign net_1354 = ~(net_1355 & net_1356);
  assign net_1356 = (net_941 | net_1271);
  assign net_1355 = (net_1357 & net_959);
  assign net_1352 = ~(net_934 & net_1358);
  assign net_1358 = ~(net_1359 & net_1360);
  assign net_1360 = (net_1361 & net_1362);
  assign net_1362 = ~(net_994 & net_984);
  assign net_1359 = (net_1363 & net_1364);
  assign net_1363 = ~(net_1173 & net_1014);
  assign net_1350 = (net_1365 & net_1366);
  assign net_1366 = net_1034 ? net_1075 : net_1367;
  assign net_1367 = ~net_1368;
  assign net_1365 = net_1008 ? net_1370 : net_1369;
  assign net_1370 = (net_1371 & net_1372);
  assign net_1372 = (net_1373 & net_1374);
  assign net_1374 = ~(net_1007 & frac_top_f3[5]);
  assign net_1007 = (net_1009 & net_933);
  assign net_1373 = (net_1375 & net_1376);
  assign net_1376 = ~(net_1137 & net_1377);
  assign net_1377 = ~(net_943 & net_1378);
  assign net_1378 = ~(net_1061 & net_1015);
  assign net_1375 = ~(frac_top_f3[3] & net_1379);
  assign net_1379 = ~(net_1380 & net_1381);
  assign net_1381 = (net_1090 | net_925);
  assign net_1371 = (net_1382 & net_1383);
  assign net_1383 = (net_1384 | frac_top_f3[7]);
  assign net_1382 = (net_1385 & net_1386);
  assign net_1386 = ~(net_1166 & net_967);
  assign net_1385 = ~(net_1003 & net_1387);
  assign net_1387 = ~(net_1388 & net_1389);
  assign net_1389 = ~(net_1287 & net_1014);
  assign net_1388 = (net_1390 & net_1080);
  assign net_1390 = (net_984 | net_1034);
  assign net_1369 = (net_1391 & net_1392);
  assign net_1392 = (net_1393 & net_1394);
  assign net_1394 = ~(net_1395 & net_967);
  assign net_1393 = (net_1396 & net_1397);
  assign net_1397 = ~(net_1398 & net_1137);
  assign net_1398 = ~(net_1399 | frac_top_f3[3]);
  assign net_1396 = ~(net_1003 & net_1400);
  assign net_1400 = (net_1041 | net_1401);
  assign net_1401 = (net_1287 & net_1061);
  assign net_1391 = (net_1402 & net_1403);
  assign net_1403 = (net_1203 | net_1069);
  assign net_1402 = (net_1404 | net_1034);
  assign result_frac_f3[1] = ~(net_1405 & net_1406);
  assign net_1406 = (net_1407 & net_1408);
  assign net_1408 = ~(net_1409 & net_1410);
  assign net_1409 = (net_1034 & net_1008);
  assign net_1407 = ~(net_1345 & net_967);
  assign net_1405 = (net_1411 & net_1412);
  assign net_1412 = ~(net_988 & net_1413);
  assign net_1413 = ~(net_1414 & net_1415);
  assign net_1415 = ~(net_1287 & net_1251);
  assign net_1414 = (net_1416 & net_1312);
  assign net_1416 = ~(net_1417 & net_1029);
  assign net_1417 = ~(net_1069 | frac_top_f3[0]);
  assign net_1411 = neon_rsqrte_f3_i ? net_1419 : net_1418;
  assign net_1419 = (net_1420 & net_1421);
  assign net_1421 = (net_1422 & net_1423);
  assign net_1423 = ~(net_934 & net_1424);
  assign net_1424 = ~(net_1425 & net_1426);
  assign net_1426 = ~(net_988 & net_1173);
  assign net_1425 = (net_1155 & net_1427);
  assign net_1155 = (net_984 | net_1081);
  assign net_1422 = (net_1428 & net_1429);
  assign net_1429 = ~(net_1287 & net_1269);
  assign net_1269 = (net_966 & net_933);
  assign net_1428 = (net_1080 | net_953);
  assign net_1080 = (net_1430 | frac_top_f3[1]);
  assign net_1420 = (net_1431 & net_1432);
  assign net_1432 = exp_bit0_f3 ? net_1434 : net_1433;
  assign net_1434 = (net_1435 & net_1436);
  assign net_1436 = (net_1437 & net_1438);
  assign net_1438 = (net_1439 & net_1440);
  assign net_1440 = ~(net_1441 & net_1137);
  assign net_1441 = (net_933 & net_1442);
  assign net_1439 = (net_1311 & net_1109);
  assign net_1109 = ~(net_1225 & net_1025);
  assign net_1311 = ~(net_1166 & net_1015);
  assign net_1166 = (net_1061 & frac_top_f3[1]);
  assign net_1437 = (net_1443 & net_1444);
  assign net_1444 = ~(net_1287 & net_1445);
  assign net_1445 = ~(net_1227 & net_1446);
  assign net_1446 = ~(net_1060 & net_988);
  assign net_1227 = (net_1447 | net_1014);
  assign net_1443 = ~(frac_top_f3[3] & net_1448);
  assign net_1448 = ~(net_1384 & net_1047);
  assign net_1047 = (net_953 | net_1034);
  assign net_1435 = (net_1449 & net_1450);
  assign net_1450 = (net_1451 & net_1452);
  assign net_1452 = (net_1162 | net_1034);
  assign net_1451 = (net_1453 & net_1454);
  assign net_1454 = ~(net_1057 & net_1173);
  assign net_1453 = ~(frac_top_f3[7] & net_1455);
  assign net_1455 = ~(net_1456 & net_1457);
  assign net_1457 = ~(net_1137 & net_994);
  assign net_1456 = (net_1458 & net_1459);
  assign net_1459 = (net_989 | net_1034);
  assign net_1458 = (net_1069 | frac_top_f3[6]);
  assign net_1449 = (net_1460 & net_1189);
  assign net_1189 = (net_1461 | net_1069);
  assign net_1460 = ~(net_1009 & net_1462);
  assign net_1462 = ~(net_1463 & net_1464);
  assign net_1464 = ~(net_1296 | net_1465);
  assign net_1296 = (net_988 & net_958);
  assign net_1463 = (net_1466 & net_1467);
  assign net_1466 = net_941 ? net_1081 : net_1447;
  assign net_1447 = ~net_1056;
  assign net_1433 = (net_1468 & net_1469);
  assign net_1469 = (net_1470 & net_1471);
  assign net_1471 = (net_1472 & net_1473);
  assign net_1473 = ~(net_1474 & net_1284);
  assign net_1474 = ~(net_1090 | net_925);
  assign net_1472 = ~(net_1085 & net_1057);
  assign net_1470 = (net_1475 & net_1476);
  assign net_1476 = ~(net_1114 & net_958);
  assign net_1475 = ~(net_1287 & net_1477);
  assign net_1477 = ~(net_1478 & net_1046);
  assign net_1046 = (net_1479 & net_1480);
  assign net_1480 = (net_984 | frac_top_f3[5]);
  assign net_1478 = (net_1481 & net_1013);
  assign net_1481 = ~(net_988 & net_1111);
  assign net_1468 = (net_1482 & net_1483);
  assign net_1483 = (net_1484 & net_1485);
  assign net_1485 = ~(net_1486 & net_941);
  assign net_1486 = ~(net_1487 & net_1488);
  assign net_1488 = (net_1489 & net_1490);
  assign net_1490 = ~(net_1287 & net_1060);
  assign net_1489 = ~(net_1065 & net_1034);
  assign net_1487 = (net_1491 & net_1492);
  assign net_1492 = (net_1068 | net_1090);
  assign net_1491 = ~(net_1137 & net_1173);
  assign net_1484 = ~(net_1493 & net_1137);
  assign net_1482 = (net_1494 & net_1495);
  assign net_1495 = (net_1332 | net_1068);
  assign net_1494 = net_1034 ? net_1162 : net_1496;
  assign net_1162 = (net_984 | net_1067);
  assign net_1496 = (net_1497 & net_1498);
  assign net_1498 = (net_1156 | net_1284);
  assign net_1497 = ~(net_1270 | net_1368);
  assign net_1431 = (net_1499 & net_1500);
  assign net_1500 = (net_1164 | net_1090);
  assign net_1164 = ~net_1103;
  assign net_1499 = ~(net_1137 & net_1501);
  assign net_1501 = ~(net_1502 & net_1503);
  assign net_1503 = (net_1125 & net_1149);
  assign net_1502 = (net_1504 & net_1505);
  assign net_1505 = ~(net_1015 & net_933);
  assign net_1504 = (net_1104 | net_1043);
  assign net_1418 = (net_1506 & net_1507);
  assign net_1507 = (net_1508 & net_1509);
  assign net_1509 = (net_1510 & net_1511);
  assign net_1510 = ~(net_1512 & net_971);
  assign net_1512 = (net_933 & frac_top_f3[1]);
  assign net_1508 = (net_1513 & net_1514);
  assign net_1514 = ~(net_1515 & net_1173);
  assign net_1513 = ~(net_934 & net_1516);
  assign net_1516 = ~(net_1517 & net_1132);
  assign net_1517 = (net_1518 & net_1234);
  assign net_1506 = (net_1519 & net_1520);
  assign net_1520 = net_1008 ? net_1522 : net_1521;
  assign net_1522 = (net_1523 & net_1524);
  assign net_1524 = (net_1525 & net_1526);
  assign net_1526 = (net_1527 & net_1528);
  assign net_1528 = ~(net_1009 & net_1529);
  assign net_1529 = ~(net_1125 & net_1132);
  assign net_1527 = (net_1530 & net_1310);
  assign net_1310 = ~(net_1041 & net_1015);
  assign net_1041 = ~(net_1090 | frac_top_f3[3]);
  assign net_1530 = ~(net_1531 & net_1137);
  assign net_1531 = (net_1056 & net_988);
  assign net_1525 = (net_1532 & net_1533);
  assign net_1533 = ~(net_1287 & net_1534);
  assign net_1534 = (net_1251 | net_1535);
  assign net_1532 = ~(net_1536 & net_1014);
  assign net_1536 = ~(net_1537 & net_1380);
  assign net_1537 = ~net_1331;
  assign net_1523 = (net_1538 & net_1539);
  assign net_1539 = (net_1540 & net_1541);
  assign net_1541 = ~(net_1542 & net_1198);
  assign net_1542 = ~(net_1467 & net_1543);
  assign net_1543 = ~(net_1061 & net_1065);
  assign net_1467 = (net_1013 | net_1014);
  assign net_1540 = (net_1544 & net_1545);
  assign net_1545 = ~(net_1345 & net_925);
  assign net_1345 = (net_1137 & net_1284);
  assign net_1544 = ~(net_1546 & net_1284);
  assign net_1538 = (net_1547 & net_1548);
  assign net_1548 = net_941 ? net_1550 : net_1549;
  assign net_1550 = (net_1198 | net_947);
  assign net_1549 = ~(net_1246 | net_1551);
  assign net_1551 = ~(net_1013 | net_1069);
  assign net_1547 = net_1034 ? net_1552 : net_1100;
  assign net_1552 = (net_1553 & net_1554);
  assign net_1553 = (net_1518 & net_959);
  assign net_1521 = (net_1555 & net_1556);
  assign net_1556 = (net_1557 & net_1558);
  assign net_1558 = (net_1559 & net_1560);
  assign net_1560 = ~(net_1061 & net_1561);
  assign net_1561 = ~(net_1562 & net_1384);
  assign net_1562 = net_1198 ? net_989 : net_1271;
  assign net_1559 = (net_1563 & net_1564);
  assign net_1564 = ~(net_1009 & net_1565);
  assign net_1565 = ~(net_1427 & net_1361);
  assign net_1361 = ~(net_958 & net_941);
  assign net_1563 = ~(net_1225 & net_1015);
  assign net_1225 = (net_1287 & net_941);
  assign net_1557 = (net_1566 & net_1289);
  assign net_1289 = ~(net_1121 & frac_top_f3[3]);
  assign net_1121 = (net_1287 & net_954);
  assign net_1566 = ~(net_988 & net_1567);
  assign net_1567 = ~(net_1568 & net_1569);
  assign net_1569 = ~(net_1287 & net_1056);
  assign net_1568 = net_1198 ? net_1570 : net_953;
  assign net_1570 = ~(net_1029 | net_950);
  assign net_1555 = (net_1571 & net_1572);
  assign net_1572 = (net_1573 & net_1574);
  assign net_1574 = (net_1349 | net_1069);
  assign net_1573 = ~(net_1137 & net_1575);
  assign net_1575 = ~(net_1576 & net_1577);
  assign net_1577 = (net_1578 & net_1156);
  assign net_1578 = ~(net_933 & net_1579);
  assign net_1579 = (frac_top_f3[5] | net_1056);
  assign net_1056 = ~(net_925 | frac_top_f3[4]);
  assign net_1576 = (net_1580 & net_1581);
  assign net_1581 = (net_1043 | net_1014);
  assign net_1580 = ~(net_1173 & net_941);
  assign net_1571 = (net_1582 & net_1583);
  assign net_1583 = (net_1096 | net_1442);
  assign net_1096 = ~net_1113;
  assign net_1582 = (net_1146 | frac_top_f3[2]);
  assign net_1519 = (net_1584 & net_1585);
  assign net_1585 = ~(net_1113 & net_1003);
  assign net_1113 = ~(net_1104 | net_1090);
  assign net_1584 = (net_945 | net_1090);
  assign net_945 = ~(frac_top_f3[3] & net_1065);
  assign result_frac_f3[0] = ~(net_1586 & net_1587);
  assign net_1587 = (net_1588 & net_1589);
  assign net_1589 = ~(net_1590 & net_967);
  assign net_1590 = (net_933 & net_1198);
  assign net_1588 = (net_1591 & net_1023);
  assign net_1023 = ~(net_1592 & net_967);
  assign net_1592 = (net_933 & exp_bit0_f3);
  assign net_1591 = ~(net_1593 & net_1515);
  assign net_1593 = ~(net_1156 | exp_bit0_f3);
  assign net_1586 = (net_1594 & net_1595);
  assign net_1595 = net_1008 ? net_1199 : net_1596;
  assign net_1199 = (net_943 | net_1090);
  assign net_1596 = ~(net_1229 & net_1137);
  assign net_1229 = ~(net_1068 | net_1014);
  assign net_1594 = (net_1597 & net_1598);
  assign net_1598 = (net_1234 | net_1069);
  assign net_1234 = ~net_1410;
  assign net_1410 = (net_1284 & net_1065);
  assign net_1597 = neon_rsqrte_f3_i ? net_1600 : net_1599;
  assign net_1600 = (net_1601 & net_1602);
  assign net_1602 = (net_1603 & net_1604);
  assign net_1604 = (net_1605 & net_1606);
  assign net_1606 = ~(net_1607 & net_1137);
  assign net_1607 = ~(net_989 | net_1014);
  assign net_989 = ~net_954;
  assign net_1605 = ~(net_1608 & net_966);
  assign net_1608 = ~(net_1104 | frac_top_f3[1]);
  assign net_1603 = (net_1609 & net_1610);
  assign net_1610 = ~(net_934 & net_1611);
  assign net_1611 = (net_1612 | net_1076);
  assign net_1076 = ~(net_999 | net_1014);
  assign net_1609 = ~(net_1009 & net_1613);
  assign net_1613 = ~(net_1614 & net_1615);
  assign net_1615 = (net_984 | net_999);
  assign net_1614 = ~(net_1065 & net_1104);
  assign net_1601 = (net_1616 & net_1617);
  assign net_1617 = exp_bit0_f3 ? net_1619 : net_1618;
  assign net_1619 = (net_1620 & net_1621);
  assign net_1621 = (net_1622 & net_1623);
  assign net_1623 = (net_1624 & net_1625);
  assign net_1625 = ~(net_1626 & net_1287);
  assign net_1626 = (net_994 & net_1014);
  assign net_1624 = ~(net_1009 & net_1627);
  assign net_1627 = ~(net_1146 & net_1628);
  assign net_1628 = (net_1014 | net_1081);
  assign net_1622 = (net_1629 & net_1630);
  assign net_1630 = ~(net_1057 & net_954);
  assign net_1629 = ~(net_934 & net_1631);
  assign net_1631 = ~(net_1632 & net_1633);
  assign net_1633 = ~(net_1061 & net_994);
  assign net_1632 = ~(net_1077 | net_1049);
  assign net_1620 = (net_1634 & net_1635);
  assign net_1635 = net_1198 ? net_1637 : net_1636;
  assign net_1637 = (net_1638 & net_1639);
  assign net_1638 = (net_1640 & net_1349);
  assign net_1349 = ~net_1535;
  assign net_1535 = ~(net_1068 | net_941);
  assign net_1640 = (net_1067 | net_1014);
  assign net_1067 = ~net_950;
  assign net_950 = ~(net_1442 | frac_top_f3[5]);
  assign net_1636 = (net_1641 & net_1642);
  assign net_1642 = (net_1430 | net_947);
  assign net_947 = ~(net_994 | net_958);
  assign net_1430 = ~net_988;
  assign net_1641 = ~(net_1213 | net_1103);
  assign net_1103 = ~(net_1643 | frac_top_f3[7]);
  assign net_1213 = (net_1085 & net_988);
  assign net_1634 = (net_1644 & net_1645);
  assign net_1645 = ~(net_1137 & net_1646);
  assign net_1646 = ~(net_1647 & net_1648);
  assign net_1648 = ~(net_988 & net_926);
  assign net_1647 = (net_1649 & net_1149);
  assign net_1149 = (net_1081 | frac_top_f3[3]);
  assign net_1649 = (net_1104 | frac_top_f3[5]);
  assign net_1644 = (net_1312 | frac_top_f3[7]);
  assign net_1312 = (net_1013 | net_1090);
  assign net_1618 = (net_1650 & net_1651);
  assign net_1651 = (net_1652 & net_1653);
  assign net_1653 = (net_1654 & net_1655);
  assign net_1655 = ~(net_1287 & net_1656);
  assign net_1656 = ~(net_1657 & net_1658);
  assign net_1658 = (net_1479 & net_1146);
  assign net_1479 = (net_1104 | net_1081);
  assign net_1657 = (net_1174 & net_1659);
  assign net_1659 = (net_953 | net_1014);
  assign net_1174 = (net_1364 & net_1639);
  assign net_1639 = ~(net_988 & net_1029);
  assign net_1364 = ~(frac_top_f3[4] & net_933);
  assign net_1654 = (net_1660 & net_1661);
  assign net_1661 = ~(net_1065 & net_1662);
  assign net_1662 = (net_1028 | net_1395);
  assign net_1028 = (net_988 & net_1034);
  assign net_1660 = ~(net_1009 & net_1663);
  assign net_1663 = ~(net_959 & net_1664);
  assign net_959 = ~net_1612;
  assign net_1612 = (net_1111 & net_933);
  assign net_1652 = (net_1665 & net_1666);
  assign net_1666 = ~(frac_top_f3[7] & net_1667);
  assign net_1667 = (net_1546 | net_1668);
  assign net_1668 = (net_1137 & net_1085);
  assign net_1665 = ~(net_1114 & net_954);
  assign net_1114 = ~(net_1069 | frac_top_f3[3]);
  assign net_1650 = (net_1669 & net_1670);
  assign net_1670 = (net_1671 & net_1672);
  assign net_1672 = (net_1427 | frac_top_f3[2]);
  assign net_1427 = (net_1068 | frac_top_f3[3]);
  assign net_1068 = ~net_1025;
  assign net_1671 = ~(net_1246 & frac_top_f3[3]);
  assign net_1669 = (net_1673 & net_1674);
  assign net_1674 = ~(net_1137 & net_966);
  assign net_1673 = net_1198 ? net_1145 : net_1675;
  assign net_1675 = (net_1461 & net_1676);
  assign net_1676 = (net_1043 | frac_top_f3[7]);
  assign net_1461 = ~net_1465;
  assign net_1465 = (net_994 & net_933);
  assign net_1616 = (net_1677 & net_1678);
  assign net_1678 = ~(net_1287 & net_1679);
  assign net_1679 = (net_1368 | net_1680);
  assign net_1677 = ~(net_1246 & net_1284);
  assign net_1246 = (net_1137 & net_958);
  assign net_1599 = (net_1681 & net_1682);
  assign net_1682 = (net_1683 & net_1684);
  assign net_1684 = ~(net_1685 & net_1137);
  assign net_1685 = (net_1049 & net_933);
  assign net_1683 = ~(net_1221 & net_941);
  assign net_1221 = (net_967 & net_934);
  assign net_1681 = (net_1686 & net_1687);
  assign net_1687 = ~(net_1515 & net_1025);
  assign net_1515 = (net_1287 & net_1284);
  assign net_1686 = net_1008 ? net_1689 : net_1688;
  assign net_1008 = ~frac_top_f3[0];
  assign net_1689 = (net_1690 & net_1691);
  assign net_1691 = (net_1692 & net_1693);
  assign net_1693 = (net_1694 & net_1695);
  assign net_1695 = ~(net_1025 & net_1696);
  assign net_1696 = (net_1009 | net_1176);
  assign net_1025 = (net_1003 & net_1399);
  assign net_1694 = (net_1511 & net_1163);
  assign net_1163 = ~(net_1697 & net_1029);
  assign net_1697 = ~(net_941 | frac_top_f3[2]);
  assign net_1511 = ~(net_1368 & net_1137);
  assign net_1368 = ~(net_1013 | net_984);
  assign net_1692 = (net_1698 & net_1699);
  assign net_1699 = ~(net_1057 & net_1065);
  assign net_1065 = (net_926 & frac_top_f3[6]);
  assign net_1057 = (net_1061 & net_1034);
  assign net_1698 = ~(net_934 & net_1700);
  assign net_1700 = ~(net_1701 & net_1702);
  assign net_1702 = ~(net_933 & net_1399);
  assign net_1701 = (net_1703 & net_1704);
  assign net_1704 = ~(net_958 & frac_top_f3[7]);
  assign net_1703 = (net_1643 | net_1014);
  assign net_1690 = (net_1705 & net_1706);
  assign net_1706 = (net_1707 & net_1708);
  assign net_1708 = ~(net_1546 & net_933);
  assign net_1546 = ~(net_1043 | net_1034);
  assign net_1707 = ~(net_988 & net_1709);
  assign net_1709 = ~(net_1710 & net_1711);
  assign net_1711 = (net_1380 & net_1384);
  assign net_1384 = ~(net_1085 & net_934);
  assign net_1380 = ~(net_1287 & net_926);
  assign net_1710 = (net_1712 & net_1713);
  assign net_1713 = (net_1090 | frac_top_f3[6]);
  assign net_1090 = ~net_1009;
  assign net_1712 = (net_1156 | frac_top_f3[1]);
  assign net_1705 = (net_1714 & net_1715);
  assign net_1715 = net_1198 ? net_1717 : net_1716;
  assign net_1717 = (net_1075 & net_993);
  assign net_993 = (net_953 | frac_top_f3[3]);
  assign net_953 = ~net_967;
  assign net_1075 = ~(net_1060 & net_1284);
  assign net_1716 = (net_1718 & net_1719);
  assign net_1719 = (net_1720 & net_1132);
  assign net_1132 = ~net_1493;
  assign net_1493 = ~(net_1043 | frac_top_f3[3]);
  assign net_1043 = ~net_971;
  assign net_971 = (net_994 & net_1399);
  assign net_1720 = (net_1404 & net_1100);
  assign net_1100 = ~(net_954 & net_933);
  assign net_954 = ~(frac_top_f3[6] | frac_top_f3[5]);
  assign net_1404 = ~net_1270;
  assign net_1270 = (net_988 & net_994);
  assign net_1718 = (net_1554 & net_1721);
  assign net_1721 = ~(net_1284 & net_958);
  assign net_1554 = (net_999 | frac_top_f3[7]);
  assign net_1714 = net_1034 ? net_1145 : net_1125;
  assign net_1145 = (net_1104 | net_1013);
  assign net_1013 = ~net_1049;
  assign net_1049 = (net_1003 & frac_top_f3[5]);
  assign net_1125 = (net_984 | net_1271);
  assign net_1688 = (net_1722 & net_1723);
  assign net_1723 = (net_1724 & net_1725);
  assign net_1725 = (net_1726 & net_1727);
  assign net_1727 = ~(net_1284 & net_1728);
  assign net_1728 = (net_1331 | net_1088);
  assign net_1088 = (net_967 & net_1034);
  assign net_967 = ~(net_1271 | frac_top_f3[6]);
  assign net_1726 = (net_1729 & net_968);
  assign net_968 = ~net_1680;
  assign net_1680 = (net_958 & net_933);
  assign net_958 = ~(net_1399 | net_925);
  assign net_1729 = ~(net_1730 & net_988);
  assign net_1730 = ~(net_1081 | net_1034);
  assign net_1081 = ~net_1111;
  assign net_1111 = ~(frac_top_f3[6] | frac_top_f3[4]);
  assign net_1724 = (net_1731 & net_1732);
  assign net_1732 = ~(net_1395 & net_1173);
  assign net_1395 = ~(frac_top_f3[7] | frac_top_f3[1]);
  assign net_1731 = ~(net_1009 & net_1733);
  assign net_1733 = ~(net_1734 & net_1735);
  assign net_1735 = ~(net_933 & net_925);
  assign net_1734 = (net_1736 & net_1737);
  assign net_1737 = ~(net_1085 & net_1284);
  assign net_1736 = ~(net_994 & frac_top_f3[3]);
  assign net_1009 = ~(frac_top_f3[2] | frac_top_f3[1]);
  assign net_1722 = (net_1738 & net_1739);
  assign net_1739 = (net_1740 & net_1741);
  assign net_1741 = ~(net_1287 & net_1742);
  assign net_1742 = ~(net_1743 & net_1744);
  assign net_1744 = (net_1745 & net_1203);
  assign net_1203 = ~net_990;
  assign net_990 = ~(net_1104 | net_925);
  assign net_1745 = (net_1518 & net_943);
  assign net_943 = ~net_1077;
  assign net_1077 = (net_933 & net_926);
  assign net_1518 = ~(net_1003 & net_988);
  assign net_1743 = (net_1746 & net_1357);
  assign net_1357 = (net_984 | frac_top_f3[4]);
  assign net_984 = ~net_1284;
  assign net_1284 = ~(net_1014 | net_941);
  assign net_1746 = ~(net_1085 & net_1061);
  assign net_1085 = (frac_top_f3[4] & frac_top_f3[5]);
  assign net_1287 = ~(net_1198 | frac_top_f3[2]);
  assign net_1740 = (net_1747 & net_1748);
  assign net_1748 = ~(net_1137 & net_1749);
  assign net_1749 = ~(net_1750 & net_1751);
  assign net_1751 = (net_1752 & net_999);
  assign net_999 = ~net_1029;
  assign net_1029 = (net_1173 & net_925);
  assign net_1752 = ~(net_1015 & net_941);
  assign net_1015 = (frac_top_f3[5] & net_925);
  assign net_1750 = (net_1664 & net_931);
  assign net_931 = (net_1271 | frac_top_f3[3]);
  assign net_1271 = ~net_926;
  assign net_926 = ~(frac_top_f3[5] | frac_top_f3[4]);
  assign net_1664 = ~(net_988 & net_1399);
  assign net_988 = (frac_top_f3[7] & net_1014);
  assign net_1137 = (frac_top_f3[2] & net_1198);
  assign net_1747 = ~(net_1331 & net_933);
  assign net_933 = (net_941 & net_1014);
  assign net_1331 = (net_1003 & net_934);
  assign net_1003 = (frac_top_f3[4] & net_925);
  assign net_1738 = (net_1753 & net_1754);
  assign net_1754 = ~(net_1060 & net_1323);
  assign net_1323 = ~(net_1332 & net_1755);
  assign net_1755 = (net_1069 | net_1014);
  assign net_1069 = ~net_934;
  assign net_934 = ~(net_1034 | net_1198);
  assign net_1332 = ~net_1176;
  assign net_1176 = ~(net_1104 | net_1034);
  assign net_1034 = ~frac_top_f3[2];
  assign net_1104 = ~net_1061;
  assign net_1061 = ~(net_1014 | frac_top_f3[7]);
  assign net_1014 = ~frac_top_f3[3];
  assign net_1060 = (frac_top_f3[6] & net_1399);
  assign net_1399 = ~frac_top_f3[5];
  assign net_1753 = net_1198 ? net_1146 : net_1156;
  assign net_1198 = ~frac_top_f3[1];
  assign net_1146 = (net_1643 | net_941);
  assign net_941 = ~frac_top_f3[7];
  assign net_1643 = ~net_1251;
  assign net_1251 = (net_994 & frac_top_f3[5]);
  assign net_994 = ~(net_1442 | net_925);
  assign net_925 = ~frac_top_f3[6];
  assign net_1156 = ~net_966;
  assign net_966 = (net_1173 & frac_top_f3[6]);
  assign net_1173 = (frac_top_f3[5] & net_1442);
  assign net_1442 = ~frac_top_f3[4];

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  assign vrec_est_int_res_f3_o = int_overflow ? 32'hFFFFFFFF
                                              : {1'b1, result_frac_f3[7:0], {23{1'b0}} };

  assign vrec_est_frc_f3_o = (recip_exp == {EXP_SIZE+2{1'b1}} ) ? {3'b001, result_frac_f3[7:0]}       :
                             (recip_exp == {EXP_SIZE+2{1'b0}} ) ? {2'b01,  result_frac_f3[7:0], 1'b0} :
                                                                  {1'b1,   result_frac_f3[7:0], 2'b00};

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
