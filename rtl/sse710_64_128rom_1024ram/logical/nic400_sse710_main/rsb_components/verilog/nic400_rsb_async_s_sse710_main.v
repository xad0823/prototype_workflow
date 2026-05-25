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

module nic400_rsb_async_s_sse710_main
  (
   sclk,
   sresetn,
   sdata,
   svalid,
   sready,
   rd_ptr_g_async,
   wr_ptr_g_async,
   sreg_0_async
   );

  parameter               DATAWIDTH = 8;

  input                   sclk;
  input                   sresetn;

  input [DATAWIDTH-1:0]   sdata;
  input                   svalid;
  output                  sready;

  input                   rd_ptr_g_async;
  output                  wr_ptr_g_async;
  output [DATAWIDTH-1:0]  sreg_0_async;


  wire                 iwr_ptr_g_async;     
  wire [DATAWIDTH-1:0] sreg_0_async;        



  wire                 isready;            
  wire                 n_fifo_full;            
  wire                 push_data;              
  wire                 rd_ptr_g_corrupt_async; 
  wire                 rd_ptr_g_sync;



  nic400_cdc_corrupt_gry_sse710_main #(1) u_cdc_corrupt_rd_ptr
  (
      .clk       (sclk),
      .resetn    (sresetn),
      .sync      (1'b0),
      .d_async   (rd_ptr_g_async),
      .q_async   (rd_ptr_g_corrupt_async)
  );

  nic400_cdc_capt_sync_sse710_main #(1) u_cdc_sync_rd_ptr
  (
      .clk       (sclk),
      .resetn    (sresetn),
      .sync_en   (1'b1),
      .d_async   (rd_ptr_g_corrupt_async),
      .q         (rd_ptr_g_sync)
  );


  assign n_fifo_full = (iwr_ptr_g_async == rd_ptr_g_sync);


  assign isready = n_fifo_full;
  assign sready = isready;




  assign push_data = svalid & n_fifo_full;

  nic400_cdc_launch_gry_sse710_main #(1) u_cdc_launch_wr_ptr
  (
      .clk       (sclk),
      .resetn    (sresetn),
      .enable    (push_data),
      .in_cdc    (~iwr_ptr_g_async),
      .out_async (iwr_ptr_g_async)
  );
  nic400_cdc_launch_data_sse710_main #(DATAWIDTH) u_cdc_launch_wr_data
  (
     .clk       (sclk),
     .resetn    (sresetn),
     .enable    (push_data),
     .in_cdc    (sdata),
     .out_async (sreg_0_async));


  assign wr_ptr_g_async = iwr_ptr_g_async;

`ifdef ARM_ASSERT_ON


  assert_never #(0, 0, "Overflow - writing when all FIFO slots are full")
  ovlOverflow
  (
   .clk           (sclk),
   .reset_n       (sresetn),
   .test_expr     (isready & svalid & ~n_fifo_full)
   );


`endif

endmodule 


