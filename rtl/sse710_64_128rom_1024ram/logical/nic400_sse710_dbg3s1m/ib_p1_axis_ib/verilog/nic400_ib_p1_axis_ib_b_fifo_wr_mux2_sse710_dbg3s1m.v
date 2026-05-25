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



module nic400_ib_p1_axis_ib_b_fifo_wr_mux2_sse710_dbg3s1m
(
  din_0,
  din_1,
  sel,

  dout
);

  input  [3:0]    din_0;
  input  [3:0]    din_1;
  input           sel;

  output [3:0]    dout;

nic400_cdc_comb_mux2_sse710_dbg3s1m u_cdc_mux_0
  (
    .din1_async (din_0[0]),
    .din2_async (din_1[0]),
    .sel        (sel),
    .dout_async (dout[0])
  );
nic400_cdc_comb_mux2_sse710_dbg3s1m u_cdc_mux_1
  (
    .din1_async (din_0[1]),
    .din2_async (din_1[1]),
    .sel        (sel),
    .dout_async (dout[1])
  );
nic400_cdc_comb_mux2_sse710_dbg3s1m u_cdc_mux_2
  (
    .din1_async (din_0[2]),
    .din2_async (din_1[2]),
    .sel        (sel),
    .dout_async (dout[2])
  );
nic400_cdc_comb_mux2_sse710_dbg3s1m u_cdc_mux_3
  (
    .din1_async (din_0[3]),
    .din2_async (din_1[3]),
    .sel        (sel),
    .dout_async (dout[3])
  );


endmodule

