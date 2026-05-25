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




module nic400_ib_secenc_axis_ib_ar_fifo_wr_mux_sse710_main
(
  in_0,
  in_1,
  in_2,
  in_3,

  sel,

  d_out
);

  input  [89:0]   in_0;
  input  [89:0]   in_1;
  input  [89:0]   in_2;
  input  [89:0]   in_3;

  input  [1:0]    sel;

  output [89:0]   d_out;

      
  wire [89:0]  mux_0_0_out;
  wire [89:0]  mux_1_0_out;

      nic400_ib_secenc_axis_ib_ar_fifo_wr_mux2_sse710_main u_mux2_0_1
  (
    .din_0 (mux_0_0_out),
    .din_1 (mux_1_0_out),
    .sel   (sel[1]),
    .dout  (d_out)
  );
nic400_ib_secenc_axis_ib_ar_fifo_wr_mux2_sse710_main u_mux2_0_0
  (
    .din_0 (in_0),
    .din_1 (in_1),
    .sel   (sel[0]),
    .dout  (mux_0_0_out)
  );
nic400_ib_secenc_axis_ib_ar_fifo_wr_mux2_sse710_main u_mux2_1_0
  (
    .din_0 (in_2),
    .din_1 (in_3),
    .sel   (sel[0]),
    .dout  (mux_1_0_out)
  );


endmodule

