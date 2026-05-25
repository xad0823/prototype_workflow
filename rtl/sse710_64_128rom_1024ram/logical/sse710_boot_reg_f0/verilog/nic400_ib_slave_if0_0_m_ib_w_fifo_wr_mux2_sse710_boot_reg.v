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



module nic400_ib_slave_if0_0_m_ib_w_fifo_wr_mux2_sse710_boot_reg
(
  din_0,
  din_1,
  sel,

  dout
);

  input  [36:0]   din_0;
  input  [36:0]   din_1;
  input           sel;

  output [36:0]   dout;

nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_0
  (
    .din1_async (din_0[0]),
    .din2_async (din_1[0]),
    .sel        (sel),
    .dout_async (dout[0])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_1
  (
    .din1_async (din_0[1]),
    .din2_async (din_1[1]),
    .sel        (sel),
    .dout_async (dout[1])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_2
  (
    .din1_async (din_0[2]),
    .din2_async (din_1[2]),
    .sel        (sel),
    .dout_async (dout[2])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_3
  (
    .din1_async (din_0[3]),
    .din2_async (din_1[3]),
    .sel        (sel),
    .dout_async (dout[3])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_4
  (
    .din1_async (din_0[4]),
    .din2_async (din_1[4]),
    .sel        (sel),
    .dout_async (dout[4])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_5
  (
    .din1_async (din_0[5]),
    .din2_async (din_1[5]),
    .sel        (sel),
    .dout_async (dout[5])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_6
  (
    .din1_async (din_0[6]),
    .din2_async (din_1[6]),
    .sel        (sel),
    .dout_async (dout[6])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_7
  (
    .din1_async (din_0[7]),
    .din2_async (din_1[7]),
    .sel        (sel),
    .dout_async (dout[7])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_8
  (
    .din1_async (din_0[8]),
    .din2_async (din_1[8]),
    .sel        (sel),
    .dout_async (dout[8])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_9
  (
    .din1_async (din_0[9]),
    .din2_async (din_1[9]),
    .sel        (sel),
    .dout_async (dout[9])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_10
  (
    .din1_async (din_0[10]),
    .din2_async (din_1[10]),
    .sel        (sel),
    .dout_async (dout[10])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_11
  (
    .din1_async (din_0[11]),
    .din2_async (din_1[11]),
    .sel        (sel),
    .dout_async (dout[11])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_12
  (
    .din1_async (din_0[12]),
    .din2_async (din_1[12]),
    .sel        (sel),
    .dout_async (dout[12])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_13
  (
    .din1_async (din_0[13]),
    .din2_async (din_1[13]),
    .sel        (sel),
    .dout_async (dout[13])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_14
  (
    .din1_async (din_0[14]),
    .din2_async (din_1[14]),
    .sel        (sel),
    .dout_async (dout[14])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_15
  (
    .din1_async (din_0[15]),
    .din2_async (din_1[15]),
    .sel        (sel),
    .dout_async (dout[15])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_16
  (
    .din1_async (din_0[16]),
    .din2_async (din_1[16]),
    .sel        (sel),
    .dout_async (dout[16])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_17
  (
    .din1_async (din_0[17]),
    .din2_async (din_1[17]),
    .sel        (sel),
    .dout_async (dout[17])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_18
  (
    .din1_async (din_0[18]),
    .din2_async (din_1[18]),
    .sel        (sel),
    .dout_async (dout[18])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_19
  (
    .din1_async (din_0[19]),
    .din2_async (din_1[19]),
    .sel        (sel),
    .dout_async (dout[19])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_20
  (
    .din1_async (din_0[20]),
    .din2_async (din_1[20]),
    .sel        (sel),
    .dout_async (dout[20])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_21
  (
    .din1_async (din_0[21]),
    .din2_async (din_1[21]),
    .sel        (sel),
    .dout_async (dout[21])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_22
  (
    .din1_async (din_0[22]),
    .din2_async (din_1[22]),
    .sel        (sel),
    .dout_async (dout[22])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_23
  (
    .din1_async (din_0[23]),
    .din2_async (din_1[23]),
    .sel        (sel),
    .dout_async (dout[23])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_24
  (
    .din1_async (din_0[24]),
    .din2_async (din_1[24]),
    .sel        (sel),
    .dout_async (dout[24])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_25
  (
    .din1_async (din_0[25]),
    .din2_async (din_1[25]),
    .sel        (sel),
    .dout_async (dout[25])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_26
  (
    .din1_async (din_0[26]),
    .din2_async (din_1[26]),
    .sel        (sel),
    .dout_async (dout[26])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_27
  (
    .din1_async (din_0[27]),
    .din2_async (din_1[27]),
    .sel        (sel),
    .dout_async (dout[27])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_28
  (
    .din1_async (din_0[28]),
    .din2_async (din_1[28]),
    .sel        (sel),
    .dout_async (dout[28])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_29
  (
    .din1_async (din_0[29]),
    .din2_async (din_1[29]),
    .sel        (sel),
    .dout_async (dout[29])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_30
  (
    .din1_async (din_0[30]),
    .din2_async (din_1[30]),
    .sel        (sel),
    .dout_async (dout[30])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_31
  (
    .din1_async (din_0[31]),
    .din2_async (din_1[31]),
    .sel        (sel),
    .dout_async (dout[31])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_32
  (
    .din1_async (din_0[32]),
    .din2_async (din_1[32]),
    .sel        (sel),
    .dout_async (dout[32])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_33
  (
    .din1_async (din_0[33]),
    .din2_async (din_1[33]),
    .sel        (sel),
    .dout_async (dout[33])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_34
  (
    .din1_async (din_0[34]),
    .din2_async (din_1[34]),
    .sel        (sel),
    .dout_async (dout[34])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_35
  (
    .din1_async (din_0[35]),
    .din2_async (din_1[35]),
    .sel        (sel),
    .dout_async (dout[35])
  );
nic400_cdc_comb_mux2_sse710_boot_reg u_cdc_mux_36
  (
    .din1_async (din_0[36]),
    .din2_async (din_1[36]),
    .sel        (sel),
    .dout_async (dout[36])
  );


endmodule

