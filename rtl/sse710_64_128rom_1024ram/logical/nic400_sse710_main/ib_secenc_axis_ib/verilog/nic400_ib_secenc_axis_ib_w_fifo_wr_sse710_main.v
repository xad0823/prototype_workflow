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


`include "nic400_ib_secenc_axis_ib_defs_sse710_main.v"

  




module nic400_ib_secenc_axis_ib_w_fifo_wr_sse710_main
  (
   src_ready,
   dst_data,
   
   wpntr_gry,
   wclk,
   wresetn,
   src_data,
   src_valid,
   rpntr_gry,
   rpntr_bin
   );

   input        wclk;
   input        wresetn;

   output                     src_ready;
   input  [36:0]              src_data;
   input                      src_valid;
   output [2:0]               wpntr_gry;

   input [2:0]                rpntr_gry;
   input [1:0]                rpntr_bin;
   output [36:0]              dst_data;


    
  


   reg [2:0]      wpntr_gry;
   reg  [36:0]                fifo0;
   reg  [36:0]                fifo1;
   reg  [36:0]                fifo2;
   reg  [36:0]                fifo3;
  



   wire [2:0]  next_wpntr_gry;

   wire [1:0]  wpntr_bin;

   wire [3:0]  wpntr_push;
     
   
   wire        full;
   wire        fifo_push;

`include "nic400_ib_secenc_axis_ib_w_fifo_fn_sse710_main.v"


   assign src_ready = ~full;
   assign fifo_push = src_valid & ~full;

   

   always@(posedge wclk or negedge wresetn)
     begin : p_wpnt_seq
        if(!wresetn)
           wpntr_gry <= {3{1'b0}};
        else if (fifo_push)
           wpntr_gry <= next_wpntr_gry;
     end

   assign next_wpntr_gry = nic400_ib_secenc_axis_ib_w_fifo_next_gry_fn(wpntr_gry);

   assign wpntr_bin      = nic400_ib_secenc_axis_ib_w_fifo_gry_to_bin_fn(wpntr_gry);

  
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
  

   nic400_ib_secenc_axis_ib_w_fifo_wr_mux_sse710_main u_nic400_ib_secenc_axis_ib_w_fifo_wr_mux
   (
      .in_0  (fifo0),
      .in_1  (fifo1),
      .in_2  (fifo2),
      .in_3  (fifo3),

      .sel   (rpntr_bin[1:0] ),
      .d_out (dst_data)
   );


   assign full = nic400_ib_secenc_axis_ib_w_fifo_full_fn(wpntr_gry, rpntr_gry);
  

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


`include "nic400_ib_secenc_axis_ib_undefs_sse710_main.v"

