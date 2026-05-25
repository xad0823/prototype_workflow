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


`include "nic400_ib_slave_9_ib_defs_sse710_sys_apb.v"
  
module nic400_ib_slave_9_ib_w_fifo_rd_sse710_sys_apb
  (
  dst_valid,
  rpntr_gry_async,
  rpntr_bin,
  dst_data,

  rclk,
  rresetn,
  src_data,
  wpntr_gry_async,
  dst_ready

  );

  input        rclk;
  input        rresetn;

  input  [1:0]  wpntr_gry_async;
  input  [36:0]    src_data;


  input        dst_ready;
  output       dst_valid;
  output [1:0]  rpntr_gry_async;
  output        rpntr_bin;
  output [36:0]    dst_data;




  reg [1:0]  rpntr_gry;
  reg        rpntr_bin;




  wire [1:0]  next_rpntr_gry;
  wire [1:0]  wpntr_gry_rsync;
  wire [1:0]  rpntr_gry_async;
  wire        next_rpntr_bin;
  wire        fifo_pop;
  wire        empty;
  wire        not_empty;


`include "nic400_ib_slave_9_ib_w_fifo_fn_sse710_sys_apb.v"


  assign dst_valid = ~empty;
  assign fifo_pop = dst_ready & ~empty;
  
  assign not_empty = ~empty;

  nic400_ib_slave_9_ib_w_fifo_sync_sse710_sys_apb u_sync_wr_ptr_gry
  (
    .clk       (rclk),
    .resetn    (rresetn),
    .ptr_async (wpntr_gry_async),
    .ptr_sync  (wpntr_gry_rsync)
  );

  nic400_cdc_launch_gry_sse710_sys_apb #(2) u_cdc_launch_rd_ptr_gry
  (
    .clk       (rclk),
    .resetn    (rresetn),
    .enable    (fifo_pop),
    .in_cdc    (next_rpntr_gry),
    .out_async (rpntr_gry_async));

  nic400_cdc_capt_nosync_sse710_sys_apb #(37) u_cdc_data_capt_nosync
  (
    .valid     (not_empty),
    .d_async   (src_data),
    .q         (dst_data)
  );


  assign next_rpntr_gry = nic400_ib_slave_9_ib_w_fifo_next_gry_fn(rpntr_gry);

  always@(posedge rclk or negedge rresetn)
    begin : p_rpnt_seq
      if(!rresetn)
         rpntr_gry <= {2{1'b0}};
      else if(fifo_pop)
         rpntr_gry <= next_rpntr_gry;
    end


   assign next_rpntr_bin = nic400_ib_slave_9_ib_w_fifo_gry_to_bin_fn(next_rpntr_gry);

   always@(posedge rclk or negedge rresetn)
     begin : p_rpnt_bin_seq
   if(!rresetn)
      rpntr_bin  <= {1{1'b0}};
   else if(fifo_pop)
      rpntr_bin <= next_rpntr_bin;
   end

  assign empty = nic400_ib_slave_9_ib_w_fifo_empty_fn(wpntr_gry_rsync, rpntr_gry);



endmodule


  

`include "nic400_ib_slave_9_ib_undefs_sse710_sys_apb.v"

