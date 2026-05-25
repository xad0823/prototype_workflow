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

  


module nic400_ib_gpio_ahb_m_ib_a_fifo_sync_sse710_integration_example_f0_host_exp
(
   clk,
   resetn,
   ptr_async,

   ptr_sync
);

   input           clk;
   input           resetn;
   input  [3:0]    ptr_async;

   output [3:0]    ptr_sync;




   wire   [3:0]    ptr_corrupt;


   nic400_cdc_corrupt_gry_sse710_integration_example_f0_host_exp #(4) u_cdc_corrupt_ptr
   (
      .clk       (clk), 
      .resetn    (resetn), 
      .sync      (1'b0),
      .d_async   (ptr_async),
      .q_async   (ptr_corrupt)
   );

nic400_cdc_capt_sync_sse710_integration_example_f0_host_exp #(1) u_cdc_capt_sync_ptr_0
   (
      .clk       (clk),
      .resetn    (resetn),
      .sync_en   (1'b1),
      .d_async   (ptr_corrupt[0]),
      .q         (ptr_sync[0])
   );
nic400_cdc_capt_sync_sse710_integration_example_f0_host_exp #(1) u_cdc_capt_sync_ptr_1
   (
      .clk       (clk),
      .resetn    (resetn),
      .sync_en   (1'b1),
      .d_async   (ptr_corrupt[1]),
      .q         (ptr_sync[1])
   );
nic400_cdc_capt_sync_sse710_integration_example_f0_host_exp #(1) u_cdc_capt_sync_ptr_2
   (
      .clk       (clk),
      .resetn    (resetn),
      .sync_en   (1'b1),
      .d_async   (ptr_corrupt[2]),
      .q         (ptr_sync[2])
   );
nic400_cdc_capt_sync_sse710_integration_example_f0_host_exp #(1) u_cdc_capt_sync_ptr_3
   (
      .clk       (clk),
      .resetn    (resetn),
      .sync_en   (1'b1),
      .d_async   (ptr_corrupt[3]),
      .q         (ptr_sync[3])
   );

endmodule


