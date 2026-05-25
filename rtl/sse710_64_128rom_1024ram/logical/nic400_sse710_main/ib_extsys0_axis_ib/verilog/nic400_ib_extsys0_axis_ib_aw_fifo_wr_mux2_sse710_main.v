//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------



module nic400_ib_extsys0_axis_ib_aw_fifo_wr_mux2_sse710_main
(
  din_0,
  din_1,
  sel,

  dout
);

  input  [80:0]   din_0;
  input  [80:0]   din_1;
  input           sel;

  output [80:0]   dout;

nic400_cdc_comb_mux2_sse710_main u_cdc_mux_0
  (
    .din1_async (din_0[0]),
    .din2_async (din_1[0]),
    .sel        (sel),
    .dout_async (dout[0])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_1
  (
    .din1_async (din_0[1]),
    .din2_async (din_1[1]),
    .sel        (sel),
    .dout_async (dout[1])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_2
  (
    .din1_async (din_0[2]),
    .din2_async (din_1[2]),
    .sel        (sel),
    .dout_async (dout[2])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_3
  (
    .din1_async (din_0[3]),
    .din2_async (din_1[3]),
    .sel        (sel),
    .dout_async (dout[3])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_4
  (
    .din1_async (din_0[4]),
    .din2_async (din_1[4]),
    .sel        (sel),
    .dout_async (dout[4])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_5
  (
    .din1_async (din_0[5]),
    .din2_async (din_1[5]),
    .sel        (sel),
    .dout_async (dout[5])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_6
  (
    .din1_async (din_0[6]),
    .din2_async (din_1[6]),
    .sel        (sel),
    .dout_async (dout[6])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_7
  (
    .din1_async (din_0[7]),
    .din2_async (din_1[7]),
    .sel        (sel),
    .dout_async (dout[7])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_8
  (
    .din1_async (din_0[8]),
    .din2_async (din_1[8]),
    .sel        (sel),
    .dout_async (dout[8])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_9
  (
    .din1_async (din_0[9]),
    .din2_async (din_1[9]),
    .sel        (sel),
    .dout_async (dout[9])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_10
  (
    .din1_async (din_0[10]),
    .din2_async (din_1[10]),
    .sel        (sel),
    .dout_async (dout[10])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_11
  (
    .din1_async (din_0[11]),
    .din2_async (din_1[11]),
    .sel        (sel),
    .dout_async (dout[11])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_12
  (
    .din1_async (din_0[12]),
    .din2_async (din_1[12]),
    .sel        (sel),
    .dout_async (dout[12])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_13
  (
    .din1_async (din_0[13]),
    .din2_async (din_1[13]),
    .sel        (sel),
    .dout_async (dout[13])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_14
  (
    .din1_async (din_0[14]),
    .din2_async (din_1[14]),
    .sel        (sel),
    .dout_async (dout[14])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_15
  (
    .din1_async (din_0[15]),
    .din2_async (din_1[15]),
    .sel        (sel),
    .dout_async (dout[15])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_16
  (
    .din1_async (din_0[16]),
    .din2_async (din_1[16]),
    .sel        (sel),
    .dout_async (dout[16])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_17
  (
    .din1_async (din_0[17]),
    .din2_async (din_1[17]),
    .sel        (sel),
    .dout_async (dout[17])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_18
  (
    .din1_async (din_0[18]),
    .din2_async (din_1[18]),
    .sel        (sel),
    .dout_async (dout[18])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_19
  (
    .din1_async (din_0[19]),
    .din2_async (din_1[19]),
    .sel        (sel),
    .dout_async (dout[19])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_20
  (
    .din1_async (din_0[20]),
    .din2_async (din_1[20]),
    .sel        (sel),
    .dout_async (dout[20])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_21
  (
    .din1_async (din_0[21]),
    .din2_async (din_1[21]),
    .sel        (sel),
    .dout_async (dout[21])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_22
  (
    .din1_async (din_0[22]),
    .din2_async (din_1[22]),
    .sel        (sel),
    .dout_async (dout[22])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_23
  (
    .din1_async (din_0[23]),
    .din2_async (din_1[23]),
    .sel        (sel),
    .dout_async (dout[23])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_24
  (
    .din1_async (din_0[24]),
    .din2_async (din_1[24]),
    .sel        (sel),
    .dout_async (dout[24])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_25
  (
    .din1_async (din_0[25]),
    .din2_async (din_1[25]),
    .sel        (sel),
    .dout_async (dout[25])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_26
  (
    .din1_async (din_0[26]),
    .din2_async (din_1[26]),
    .sel        (sel),
    .dout_async (dout[26])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_27
  (
    .din1_async (din_0[27]),
    .din2_async (din_1[27]),
    .sel        (sel),
    .dout_async (dout[27])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_28
  (
    .din1_async (din_0[28]),
    .din2_async (din_1[28]),
    .sel        (sel),
    .dout_async (dout[28])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_29
  (
    .din1_async (din_0[29]),
    .din2_async (din_1[29]),
    .sel        (sel),
    .dout_async (dout[29])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_30
  (
    .din1_async (din_0[30]),
    .din2_async (din_1[30]),
    .sel        (sel),
    .dout_async (dout[30])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_31
  (
    .din1_async (din_0[31]),
    .din2_async (din_1[31]),
    .sel        (sel),
    .dout_async (dout[31])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_32
  (
    .din1_async (din_0[32]),
    .din2_async (din_1[32]),
    .sel        (sel),
    .dout_async (dout[32])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_33
  (
    .din1_async (din_0[33]),
    .din2_async (din_1[33]),
    .sel        (sel),
    .dout_async (dout[33])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_34
  (
    .din1_async (din_0[34]),
    .din2_async (din_1[34]),
    .sel        (sel),
    .dout_async (dout[34])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_35
  (
    .din1_async (din_0[35]),
    .din2_async (din_1[35]),
    .sel        (sel),
    .dout_async (dout[35])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_36
  (
    .din1_async (din_0[36]),
    .din2_async (din_1[36]),
    .sel        (sel),
    .dout_async (dout[36])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_37
  (
    .din1_async (din_0[37]),
    .din2_async (din_1[37]),
    .sel        (sel),
    .dout_async (dout[37])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_38
  (
    .din1_async (din_0[38]),
    .din2_async (din_1[38]),
    .sel        (sel),
    .dout_async (dout[38])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_39
  (
    .din1_async (din_0[39]),
    .din2_async (din_1[39]),
    .sel        (sel),
    .dout_async (dout[39])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_40
  (
    .din1_async (din_0[40]),
    .din2_async (din_1[40]),
    .sel        (sel),
    .dout_async (dout[40])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_41
  (
    .din1_async (din_0[41]),
    .din2_async (din_1[41]),
    .sel        (sel),
    .dout_async (dout[41])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_42
  (
    .din1_async (din_0[42]),
    .din2_async (din_1[42]),
    .sel        (sel),
    .dout_async (dout[42])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_43
  (
    .din1_async (din_0[43]),
    .din2_async (din_1[43]),
    .sel        (sel),
    .dout_async (dout[43])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_44
  (
    .din1_async (din_0[44]),
    .din2_async (din_1[44]),
    .sel        (sel),
    .dout_async (dout[44])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_45
  (
    .din1_async (din_0[45]),
    .din2_async (din_1[45]),
    .sel        (sel),
    .dout_async (dout[45])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_46
  (
    .din1_async (din_0[46]),
    .din2_async (din_1[46]),
    .sel        (sel),
    .dout_async (dout[46])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_47
  (
    .din1_async (din_0[47]),
    .din2_async (din_1[47]),
    .sel        (sel),
    .dout_async (dout[47])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_48
  (
    .din1_async (din_0[48]),
    .din2_async (din_1[48]),
    .sel        (sel),
    .dout_async (dout[48])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_49
  (
    .din1_async (din_0[49]),
    .din2_async (din_1[49]),
    .sel        (sel),
    .dout_async (dout[49])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_50
  (
    .din1_async (din_0[50]),
    .din2_async (din_1[50]),
    .sel        (sel),
    .dout_async (dout[50])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_51
  (
    .din1_async (din_0[51]),
    .din2_async (din_1[51]),
    .sel        (sel),
    .dout_async (dout[51])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_52
  (
    .din1_async (din_0[52]),
    .din2_async (din_1[52]),
    .sel        (sel),
    .dout_async (dout[52])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_53
  (
    .din1_async (din_0[53]),
    .din2_async (din_1[53]),
    .sel        (sel),
    .dout_async (dout[53])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_54
  (
    .din1_async (din_0[54]),
    .din2_async (din_1[54]),
    .sel        (sel),
    .dout_async (dout[54])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_55
  (
    .din1_async (din_0[55]),
    .din2_async (din_1[55]),
    .sel        (sel),
    .dout_async (dout[55])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_56
  (
    .din1_async (din_0[56]),
    .din2_async (din_1[56]),
    .sel        (sel),
    .dout_async (dout[56])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_57
  (
    .din1_async (din_0[57]),
    .din2_async (din_1[57]),
    .sel        (sel),
    .dout_async (dout[57])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_58
  (
    .din1_async (din_0[58]),
    .din2_async (din_1[58]),
    .sel        (sel),
    .dout_async (dout[58])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_59
  (
    .din1_async (din_0[59]),
    .din2_async (din_1[59]),
    .sel        (sel),
    .dout_async (dout[59])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_60
  (
    .din1_async (din_0[60]),
    .din2_async (din_1[60]),
    .sel        (sel),
    .dout_async (dout[60])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_61
  (
    .din1_async (din_0[61]),
    .din2_async (din_1[61]),
    .sel        (sel),
    .dout_async (dout[61])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_62
  (
    .din1_async (din_0[62]),
    .din2_async (din_1[62]),
    .sel        (sel),
    .dout_async (dout[62])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_63
  (
    .din1_async (din_0[63]),
    .din2_async (din_1[63]),
    .sel        (sel),
    .dout_async (dout[63])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_64
  (
    .din1_async (din_0[64]),
    .din2_async (din_1[64]),
    .sel        (sel),
    .dout_async (dout[64])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_65
  (
    .din1_async (din_0[65]),
    .din2_async (din_1[65]),
    .sel        (sel),
    .dout_async (dout[65])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_66
  (
    .din1_async (din_0[66]),
    .din2_async (din_1[66]),
    .sel        (sel),
    .dout_async (dout[66])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_67
  (
    .din1_async (din_0[67]),
    .din2_async (din_1[67]),
    .sel        (sel),
    .dout_async (dout[67])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_68
  (
    .din1_async (din_0[68]),
    .din2_async (din_1[68]),
    .sel        (sel),
    .dout_async (dout[68])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_69
  (
    .din1_async (din_0[69]),
    .din2_async (din_1[69]),
    .sel        (sel),
    .dout_async (dout[69])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_70
  (
    .din1_async (din_0[70]),
    .din2_async (din_1[70]),
    .sel        (sel),
    .dout_async (dout[70])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_71
  (
    .din1_async (din_0[71]),
    .din2_async (din_1[71]),
    .sel        (sel),
    .dout_async (dout[71])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_72
  (
    .din1_async (din_0[72]),
    .din2_async (din_1[72]),
    .sel        (sel),
    .dout_async (dout[72])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_73
  (
    .din1_async (din_0[73]),
    .din2_async (din_1[73]),
    .sel        (sel),
    .dout_async (dout[73])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_74
  (
    .din1_async (din_0[74]),
    .din2_async (din_1[74]),
    .sel        (sel),
    .dout_async (dout[74])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_75
  (
    .din1_async (din_0[75]),
    .din2_async (din_1[75]),
    .sel        (sel),
    .dout_async (dout[75])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_76
  (
    .din1_async (din_0[76]),
    .din2_async (din_1[76]),
    .sel        (sel),
    .dout_async (dout[76])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_77
  (
    .din1_async (din_0[77]),
    .din2_async (din_1[77]),
    .sel        (sel),
    .dout_async (dout[77])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_78
  (
    .din1_async (din_0[78]),
    .din2_async (din_1[78]),
    .sel        (sel),
    .dout_async (dout[78])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_79
  (
    .din1_async (din_0[79]),
    .din2_async (din_1[79]),
    .sel        (sel),
    .dout_async (dout[79])
  );
nic400_cdc_comb_mux2_sse710_main u_cdc_mux_80
  (
    .din1_async (din_0[80]),
    .din2_async (din_1[80]),
    .sel        (sel),
    .dout_async (dout[80])
  );


endmodule

