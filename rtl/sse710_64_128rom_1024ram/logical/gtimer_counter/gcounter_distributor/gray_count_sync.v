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

module gray_count_sync
  #(parameter
      COUNTER_WIDTH = 64
 )
  (
  input   wire                      nreset,
  input   wire                      clk,
  input   wire  [COUNTER_WIDTH-1:0] gray_count_async_i,
  output  wire  [COUNTER_WIDTH-1:0] gray_count_sync_o

  );
 
  genvar i;
  generate
   for (i=0; i<COUNTER_WIDTH; i=i+1)
   begin : COUNTER_SYNC
  gtimer_counter_cdc_capt_sync u_gtimer_countter_cdc_capt_sync_gray_count(
    .clk            (clk),
    .nreset         (nreset),
    .d_async        (gray_count_async_i[i]),
    .q              (gray_count_sync_o[i]));
   end
  endgenerate

endmodule
