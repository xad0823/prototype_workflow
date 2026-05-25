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




module nic400_ib_dbg_axim_ib_w_fifo_wr_mux_sse710_dbg3s1m
(
  in_0,
  in_1,
  in_2,
  in_3,
  in_4,
  in_5,
  in_6,
  in_7,

  sel,

  d_out
);

  input  [72:0]   in_0;
  input  [72:0]   in_1;
  input  [72:0]   in_2;
  input  [72:0]   in_3;
  input  [72:0]   in_4;
  input  [72:0]   in_5;
  input  [72:0]   in_6;
  input  [72:0]   in_7;

  input  [2:0]    sel;

  output [72:0]   d_out;

      
  wire [72:0]  mux_0_1_out;
  wire [72:0]  mux_1_1_out;
  wire [72:0]  mux_0_0_out;
  wire [72:0]  mux_1_0_out;
  wire [72:0]  mux_2_0_out;
  wire [72:0]  mux_3_0_out;

      nic400_ib_dbg_axim_ib_w_fifo_wr_mux2_sse710_dbg3s1m u_mux2_0_2
  (
    .din_0 (mux_0_1_out),
    .din_1 (mux_1_1_out),
    .sel   (sel[2]),
    .dout  (d_out)
  );
nic400_ib_dbg_axim_ib_w_fifo_wr_mux2_sse710_dbg3s1m u_mux2_0_1
  (
    .din_0 (mux_0_0_out),
    .din_1 (mux_1_0_out),
    .sel   (sel[1]),
    .dout  (mux_0_1_out)
  );
nic400_ib_dbg_axim_ib_w_fifo_wr_mux2_sse710_dbg3s1m u_mux2_0_0
  (
    .din_0 (in_0),
    .din_1 (in_1),
    .sel   (sel[0]),
    .dout  (mux_0_0_out)
  );
nic400_ib_dbg_axim_ib_w_fifo_wr_mux2_sse710_dbg3s1m u_mux2_1_0
  (
    .din_0 (in_2),
    .din_1 (in_3),
    .sel   (sel[0]),
    .dout  (mux_1_0_out)
  );
nic400_ib_dbg_axim_ib_w_fifo_wr_mux2_sse710_dbg3s1m u_mux2_1_1
  (
    .din_0 (mux_2_0_out),
    .din_1 (mux_3_0_out),
    .sel   (sel[1]),
    .dout  (mux_1_1_out)
  );
nic400_ib_dbg_axim_ib_w_fifo_wr_mux2_sse710_dbg3s1m u_mux2_2_0
  (
    .din_0 (in_4),
    .din_1 (in_5),
    .sel   (sel[0]),
    .dout  (mux_2_0_out)
  );
nic400_ib_dbg_axim_ib_w_fifo_wr_mux2_sse710_dbg3s1m u_mux2_3_0
  (
    .din_0 (in_6),
    .din_1 (in_7),
    .sel   (sel[0]),
    .dout  (mux_3_0_out)
  );


endmodule

