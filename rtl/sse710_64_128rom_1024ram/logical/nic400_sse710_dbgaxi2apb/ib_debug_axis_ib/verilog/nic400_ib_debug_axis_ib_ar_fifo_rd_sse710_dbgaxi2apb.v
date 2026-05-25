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


`include "nic400_ib_debug_axis_ib_defs_sse710_dbgaxi2apb.v"
  
module nic400_ib_debug_axis_ib_ar_fifo_rd_sse710_dbgaxi2apb
  (
  dst_valid,
  rpntr_gry,
  rpntr_bin,

  rclk,
  rresetn,
  wpntr_gry,
  dst_ready

  );

  input        rclk;
  input        rresetn;

  input  [2:0]  wpntr_gry;


  input        dst_ready;
  output       dst_valid;
  output [2:0]  rpntr_gry;
  output [1:0]  rpntr_bin;




  reg [2:0]  rpntr_gry;





  wire [2:0]  next_rpntr_gry;

  wire        fifo_pop;
  wire        empty;


`include "nic400_ib_debug_axis_ib_ar_fifo_fn_sse710_dbgaxi2apb.v"


  assign dst_valid = ~empty;
  assign fifo_pop = dst_ready & ~empty;
  

  assign next_rpntr_gry = nic400_ib_debug_axis_ib_ar_fifo_next_gry_fn(rpntr_gry);

  always@(posedge rclk or negedge rresetn)
    begin : p_rpnt_seq
      if(!rresetn)
         rpntr_gry <= {3{1'b0}};
      else if(fifo_pop)
         rpntr_gry <= next_rpntr_gry;
    end


  assign rpntr_bin = nic400_ib_debug_axis_ib_ar_fifo_gry_to_bin_fn(rpntr_gry);

  assign empty = nic400_ib_debug_axis_ib_ar_fifo_empty_fn(wpntr_gry, rpntr_gry);



endmodule


  

`include "nic400_ib_debug_axis_ib_undefs_sse710_dbgaxi2apb.v"

