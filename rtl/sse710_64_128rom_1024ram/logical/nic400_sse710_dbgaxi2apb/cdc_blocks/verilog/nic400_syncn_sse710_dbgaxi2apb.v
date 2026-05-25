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

module nic400_syncn_sse710_dbgaxi2apb
(
  input  wire clk,
  input  wire resetn,
  input  wire din,
  output wire dout
);

  parameter LEVELS = 2;

  wire [LEVELS-1:0] d_int;

  nic400_sync_flop_sse710_dbgaxi2apb u_sync_flop_async_sse710_dbgaxi2apb
  (
    .clk     (clk),
    .resetn  (resetn),
    .din     (din),
    .dout    (d_int[0])
  );

  genvar i;
  generate
    if (LEVELS>2)
    begin : g_levels_gt_2
      for (i=0 ; i<LEVELS-2 ; i=i+1)
      begin : g_i
        nic400_sync_flop_sse710_dbgaxi2apb u_sync_flop_part_sse710_dbgaxi2apb
        (
          .clk     (clk),
          .resetn  (resetn),
          .din     (d_int[i]),
          .dout    (d_int[i+1])
        );
      end
    end
  endgenerate

  nic400_sync_flop_sse710_dbgaxi2apb u_sync_flop_sync_sse710_dbgaxi2apb
  (
    .clk     (clk),
    .resetn  (resetn),
    .din     (d_int[LEVELS-2]),
    .dout    (d_int[LEVELS-1])
  );

  assign dout = d_int[LEVELS-1];

endmodule

