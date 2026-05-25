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

module nic400_rsb_async_m_sse710_main
  (
   mclk,
   mresetn,
   mdata,
   mvalid,
   mready,
   rd_ptr_g_async,
   wr_ptr_g_async,
   sreg_0_async
   );

  parameter               DATAWIDTH = 8;

  input                   mclk;
  input                   mresetn;

  output [DATAWIDTH-1:0]  mdata;
  output                  mvalid;
  input                   mready;

  output                  rd_ptr_g_async;
  input                   wr_ptr_g_async;
  input [DATAWIDTH-1:0]   sreg_0_async;


  wire                 ird_ptr_g_async;     


  wire                 imvalid;            
  wire                 n_fifo_empty;       
  wire                 pop_data;               
  wire                 wr_ptr_g_corrupt_async; 
  wire                 wr_ptr_g_sync;



  nic400_cdc_corrupt_gry_sse710_main #(1) u_cdc_corrupt_wr_ptr
  (
      .clk       (mclk),
      .resetn    (mresetn),
      .sync      (1'b0),
      .d_async   (wr_ptr_g_async),
      .q_async   (wr_ptr_g_corrupt_async)
  );

  nic400_cdc_capt_sync_sse710_main #(1) u_cdc_sync_wr_ptr
  (
      .clk       (mclk),
      .resetn    (mresetn),
      .sync_en   (1'b1),
      .d_async   (wr_ptr_g_corrupt_async),
      .q         (wr_ptr_g_sync)
  );


  assign n_fifo_empty = (wr_ptr_g_sync !=  ird_ptr_g_async);



  assign imvalid = n_fifo_empty;
  assign mvalid = imvalid;



  assign pop_data = mready & n_fifo_empty;

  nic400_cdc_launch_gry_sse710_main #(1) u_cdc_launch_rd_ptr
  (
      .clk       (mclk),
      .resetn    (mresetn),
      .enable    (pop_data),
      .in_cdc    (~ird_ptr_g_async),
      .out_async (ird_ptr_g_async)
  );

  nic400_cdc_capt_nosync_sse710_main #(DATAWIDTH) u_cdc_nosync_mdata
  (
      .valid     (imvalid),
      .d_async   (sreg_0_async),
      .q         (mdata)
  );


  assign rd_ptr_g_async = ird_ptr_g_async;

`ifdef ARM_ASSERT_ON


  assert_never #(0, 0, "Underflow - reading when all FIFO slots are empty")
  ovlUnderflow
  (
   .clk           (mclk),
   .reset_n       (mresetn),
   .test_expr     (mready & imvalid & ~n_fifo_empty)
   );


`endif

endmodule 


