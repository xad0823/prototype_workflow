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

  


module nic400_ib_slave_if0_0_m_ib_a_fifo_sync_sse710_boot_reg
(
   clk,
   resetn,
   ptr_async,

   ptr_sync
);

   input           clk;
   input           resetn;
   input  [1:0]    ptr_async;

   output [1:0]    ptr_sync;




   wire   [1:0]    ptr_corrupt;


   nic400_cdc_corrupt_gry_sse710_boot_reg #(2) u_cdc_corrupt_ptr
   (
      .clk       (clk), 
      .resetn    (resetn), 
      .sync      (1'b0),
      .d_async   (ptr_async),
      .q_async   (ptr_corrupt)
   );

nic400_cdc_capt_sync_sse710_boot_reg #(1) u_cdc_capt_sync_ptr_0
   (
      .clk       (clk),
      .resetn    (resetn),
      .sync_en   (1'b1),
      .d_async   (ptr_corrupt[0]),
      .q         (ptr_sync[0])
   );
nic400_cdc_capt_sync_sse710_boot_reg #(1) u_cdc_capt_sync_ptr_1
   (
      .clk       (clk),
      .resetn    (resetn),
      .sync_en   (1'b1),
      .d_async   (ptr_corrupt[1]),
      .q         (ptr_sync[1])
   );

endmodule


