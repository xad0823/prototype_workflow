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




`include "nic400_rsb_defs_sse710_main.v"

  


module nic400_rsb_async4_s_sse710_main
  (
   src_ready,
   dst_data,
   
  empty_async,
   cactive,
   wpntr_gry_async,
   wclk,
   wresetn,
   src_data,
   src_valid,
   rpntr_gry_async,
   rpntr_bin
   );

   parameter NEXTPORT = "nxtport";

   input                      wclk;
   input                      wresetn;

   output                     src_ready;
   input  [7:0]               src_data;
   input                      src_valid;
  output                     empty_async;
   output                     cactive;
   output [2:0]               wpntr_gry_async;

   input  [2:0]               rpntr_gry_async;
   input  [1:0]               rpntr_bin;
   output [7:0]               dst_data;


   reg [2:0]                  wpntr_gry;
   wire [2:0]                 wpntr_gry_async;
   reg  [7:0]                 fifo0;
   wire [7:0]                 fifo0_corrupt;
   reg  [7:0]                 fifo1;
   wire [7:0]                 fifo1_corrupt;
   reg  [7:0]                 fifo2;
   wire [7:0]                 fifo2_corrupt;
   reg  [7:0]                 fifo3;
   wire [7:0]                 fifo3_corrupt;
  

   wire [2:0]  next_wpntr_gry;

   wire [1:0]  wpntr_bin;
   wire [2:0]  rpntr_gry_wsync;

   wire [3:0]  wpntr_push;
   wire        full;
   wire        fifo_push;
   wire        cactive_i;
   

`include "nic400_rsb_fifo_fn_sse710_main.v"


   assign src_ready = ~full;
   assign fifo_push = src_valid & ~full;

   
   nic400_rsb_fifo_sync_sse710_main u_sync_rd_ptr_gry
   (
      .clk       (wclk),
      .resetn    (wresetn),
      .ptr_async (rpntr_gry_async),
      .ptr_sync  (rpntr_gry_wsync)
   );

   nic400_cdc_launch_gry_sse710_main #(3) u_cdc_launch_wr_ptr_gry
   (
      .clk       (wclk),
      .resetn    (wresetn),
      .enable    (fifo_push),
      .in_cdc    (next_wpntr_gry),
      .out_async (wpntr_gry_async));
  

   always@(posedge wclk or negedge wresetn)
     begin : p_wpnt_seq
        if(!wresetn)
           wpntr_gry <= {3{1'b0}};
        else if (fifo_push)
           wpntr_gry <= next_wpntr_gry;
     end

   assign next_wpntr_gry = nic400_rsb_fifo_next_gry_fn(wpntr_gry);

   assign wpntr_bin      = nic400_rsb_fifo_gry_to_bin_fn(wpntr_gry);

  
   assign wpntr_push[0] = fifo_push & (wpntr_bin[1:0]  == 2'd0);
   assign wpntr_push[1] = fifo_push & (wpntr_bin[1:0]  == 2'd1);
   assign wpntr_push[2] = fifo_push & (wpntr_bin[1:0]  == 2'd2);
   assign wpntr_push[3] = fifo_push & (wpntr_bin[1:0]  == 2'd3);
  
      
   always@(posedge wclk)
    begin : p_wr_fifo0
      if(wpntr_push[0])
        fifo0 <= src_data;
    end
  
   always@(posedge wclk)
    begin : p_wr_fifo1
      if(wpntr_push[1])
        fifo1 <= src_data;
    end
  
   always@(posedge wclk)
    begin : p_wr_fifo2
      if(wpntr_push[2])
        fifo2 <= src_data;
    end
  
   always@(posedge wclk)
    begin : p_wr_fifo3
      if(wpntr_push[3])
        fifo3 <= src_data;
    end
  

   nic400_rsb_cdc_air_corrupt_sse710_main #(8, NEXTPORT) u_cdc_corrupt_fifo_0
   (
      .d   (fifo0),
      .q   (fifo0_corrupt)
   );
  
   nic400_rsb_cdc_air_corrupt_sse710_main #(8, NEXTPORT) u_cdc_corrupt_fifo_1
   (
      .d   (fifo1),
      .q   (fifo1_corrupt)
   );
  
   nic400_rsb_cdc_air_corrupt_sse710_main #(8, NEXTPORT) u_cdc_corrupt_fifo_2
   (
      .d   (fifo2),
      .q   (fifo2_corrupt)
   );
  
   nic400_rsb_cdc_air_corrupt_sse710_main #(8, NEXTPORT) u_cdc_corrupt_fifo_3
   (
      .d   (fifo3),
      .q   (fifo3_corrupt)
   );
  

   nic400_rsb_fifo_wr_mux_sse710_main u_nic400_rsb_fifo_wr_mux
   (
      .in_0  (fifo0_corrupt),
      .in_1  (fifo1_corrupt),
      .in_2  (fifo2_corrupt),
      .in_3  (fifo3_corrupt),

      .sel   (rpntr_bin[1:0] ),
      .d_out (dst_data)
   );


   assign full = nic400_rsb_fifo_full_fn(wpntr_gry, rpntr_gry_wsync);
  


  assign cactive_i = ~(nic400_rsb_fifo_empty_fn(wpntr_gry, rpntr_gry_wsync));

   nic400_cdc_launch_gry_sse710_main #(1) u_cdc_launch_empty_ptr_gry
   (
      .clk       (wclk),
      .resetn    (wresetn),
      .enable    (1'b1),
      .in_cdc    (cactive_i),
      .out_async (empty_async));
      
  assign cactive = cactive_i;
 


`ifdef ARM_ASSERT_ON

   assert_always #(0,0,"fifo pointer error")
   ovl_wr_pointer
     (
      .clk              (wclk),
      .reset_n          (wresetn),
      .test_expr        ((wpntr_bin[1:0]  <= 3) && (rpntr_bin[1:0]  <= 3))
     );

  `endif 

endmodule


`include "nic400_rsb_undefs_sse710_main.v"


