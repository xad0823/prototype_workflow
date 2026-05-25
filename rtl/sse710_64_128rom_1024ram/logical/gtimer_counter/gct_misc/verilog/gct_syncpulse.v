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


module gct_syncpulse
(
  input wire              clk,
  input wire              reset_n,
  input wire              data_i,

  output wire             pulse_o,
  output wire             ack_o
);

  wire              sync_flop2;
  reg               sync_flop3;

  gct_synchronizer  u_gct_synchronizer
  (
    .clk     (clk),
    .reset_n (reset_n),
    .data_i  (data_i),
    .data_o  (sync_flop2)
  );
  
  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
      sync_flop3            <= 1'b0;
    else
      sync_flop3            <= sync_flop2;
  end

  assign pulse_o            = sync_flop3 ^ sync_flop2;

  assign ack_o              = sync_flop3;

endmodule

