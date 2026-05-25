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

module gray_decode_async
  #(parameter
      COUNTER_WIDTH = 64
 )
  (
  input   wire                      nreset,
  input   wire                      clk,
  input   wire  [COUNTER_WIDTH-1:0] gray_count,
  output  wire   [COUNTER_WIDTH-1:0] binary_count

  );
 
  wire   [COUNTER_WIDTH-1:0] gray_count_dd;

  gray_count_sync   #(
    .COUNTER_WIDTH                (COUNTER_WIDTH)
  )
  u_gray_sync
  (
    .nreset                       (nreset),
    .clk                          (clk),
    .gray_count_async_i           (gray_count),
    .gray_count_sync_o            (gray_count_dd)
  );
  
 gray_comb_decode   #(
    .COUNTER_WIDTH                (COUNTER_WIDTH)
  )
  u_gray_comb_decode_scp
  (
    .gray_count                   (gray_count_dd),
    .binary_count                 (binary_count)
  );


  
endmodule
