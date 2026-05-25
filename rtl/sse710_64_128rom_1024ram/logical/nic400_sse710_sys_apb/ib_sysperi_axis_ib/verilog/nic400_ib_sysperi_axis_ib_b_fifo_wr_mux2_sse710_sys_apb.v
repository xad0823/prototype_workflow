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



module nic400_ib_sysperi_axis_ib_b_fifo_wr_mux2_sse710_sys_apb
(
  din_0,
  din_1,
  sel,

  dout
);

  input  [13:0]   din_0;
  input  [13:0]   din_1;
  input           sel;

  output [13:0]   dout;

nic400_cdc_comb_mux2_sse710_sys_apb u_cdc_mux_0
  (
    .din1_async (din_0[0]),
    .din2_async (din_1[0]),
    .sel        (sel),
    .dout_async (dout[0])
  );
nic400_cdc_comb_mux2_sse710_sys_apb u_cdc_mux_1
  (
    .din1_async (din_0[1]),
    .din2_async (din_1[1]),
    .sel        (sel),
    .dout_async (dout[1])
  );
nic400_cdc_comb_mux2_sse710_sys_apb u_cdc_mux_2
  (
    .din1_async (din_0[2]),
    .din2_async (din_1[2]),
    .sel        (sel),
    .dout_async (dout[2])
  );
nic400_cdc_comb_mux2_sse710_sys_apb u_cdc_mux_3
  (
    .din1_async (din_0[3]),
    .din2_async (din_1[3]),
    .sel        (sel),
    .dout_async (dout[3])
  );
nic400_cdc_comb_mux2_sse710_sys_apb u_cdc_mux_4
  (
    .din1_async (din_0[4]),
    .din2_async (din_1[4]),
    .sel        (sel),
    .dout_async (dout[4])
  );
nic400_cdc_comb_mux2_sse710_sys_apb u_cdc_mux_5
  (
    .din1_async (din_0[5]),
    .din2_async (din_1[5]),
    .sel        (sel),
    .dout_async (dout[5])
  );
nic400_cdc_comb_mux2_sse710_sys_apb u_cdc_mux_6
  (
    .din1_async (din_0[6]),
    .din2_async (din_1[6]),
    .sel        (sel),
    .dout_async (dout[6])
  );
nic400_cdc_comb_mux2_sse710_sys_apb u_cdc_mux_7
  (
    .din1_async (din_0[7]),
    .din2_async (din_1[7]),
    .sel        (sel),
    .dout_async (dout[7])
  );
nic400_cdc_comb_mux2_sse710_sys_apb u_cdc_mux_8
  (
    .din1_async (din_0[8]),
    .din2_async (din_1[8]),
    .sel        (sel),
    .dout_async (dout[8])
  );
nic400_cdc_comb_mux2_sse710_sys_apb u_cdc_mux_9
  (
    .din1_async (din_0[9]),
    .din2_async (din_1[9]),
    .sel        (sel),
    .dout_async (dout[9])
  );
nic400_cdc_comb_mux2_sse710_sys_apb u_cdc_mux_10
  (
    .din1_async (din_0[10]),
    .din2_async (din_1[10]),
    .sel        (sel),
    .dout_async (dout[10])
  );
nic400_cdc_comb_mux2_sse710_sys_apb u_cdc_mux_11
  (
    .din1_async (din_0[11]),
    .din2_async (din_1[11]),
    .sel        (sel),
    .dout_async (dout[11])
  );
nic400_cdc_comb_mux2_sse710_sys_apb u_cdc_mux_12
  (
    .din1_async (din_0[12]),
    .din2_async (din_1[12]),
    .sel        (sel),
    .dout_async (dout[12])
  );
nic400_cdc_comb_mux2_sse710_sys_apb u_cdc_mux_13
  (
    .din1_async (din_0[13]),
    .din2_async (din_1[13]),
    .sel        (sel),
    .dout_async (dout[13])
  );


endmodule

