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


`include "nic400_ib_hostcpu_axis_ib_defs_sse710_main.v"

  




module nic400_ib_hostcpu_axis_ib_ar_fifo_wr_sse710_main
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
   input  [103:0]             src_data;
   input                      src_valid;
   output [4:0]               wpntr_gry;

   input [4:0]                rpntr_gry;
   input [3:0]                rpntr_bin;
   output [103:0]             dst_data;


    
  


   reg [4:0]      wpntr_gry;
   reg  [103:0]               fifo0;
   reg  [103:0]               fifo1;
   reg  [103:0]               fifo2;
   reg  [103:0]               fifo3;
   reg  [103:0]               fifo4;
   reg  [103:0]               fifo5;
   reg  [103:0]               fifo6;
   reg  [103:0]               fifo7;
   reg  [103:0]               fifo8;
   reg  [103:0]               fifo9;
   reg  [103:0]               fifo10;
   reg  [103:0]               fifo11;
  



   wire [4:0]  next_wpntr_gry;

   wire [3:0]  wpntr_bin;

   wire [11:0]  wpntr_push;
     
   
   wire        full;
   wire        fifo_push;

`include "nic400_ib_hostcpu_axis_ib_ar_fifo_fn_sse710_main.v"


   assign src_ready = ~full;
   assign fifo_push = src_valid & ~full;

   

   always@(posedge wclk or negedge wresetn)
     begin : p_wpnt_seq
        if(!wresetn)
           wpntr_gry <= {5{1'b0}};
        else if (fifo_push)
           wpntr_gry <= next_wpntr_gry;
     end

   assign next_wpntr_gry = nic400_ib_hostcpu_axis_ib_ar_fifo_next_gry_fn(wpntr_gry);

   assign wpntr_bin      = nic400_ib_hostcpu_axis_ib_ar_fifo_gry_to_bin_fn(wpntr_gry);

  
   assign wpntr_push[0] = fifo_push & (wpntr_bin[3:0]  == 4'd0);
  
   assign wpntr_push[1] = fifo_push & (wpntr_bin[3:0]  == 4'd1);
  
   assign wpntr_push[2] = fifo_push & (wpntr_bin[3:0]  == 4'd2);
  
   assign wpntr_push[3] = fifo_push & (wpntr_bin[3:0]  == 4'd3);
  
   assign wpntr_push[4] = fifo_push & (wpntr_bin[3:0]  == 4'd4);
  
   assign wpntr_push[5] = fifo_push & (wpntr_bin[3:0]  == 4'd5);
  
   assign wpntr_push[6] = fifo_push & (wpntr_bin[3:0]  == 4'd6);
  
   assign wpntr_push[7] = fifo_push & (wpntr_bin[3:0]  == 4'd7);
  
   assign wpntr_push[8] = fifo_push & (wpntr_bin[3:0]  == 4'd8);
  
   assign wpntr_push[9] = fifo_push & (wpntr_bin[3:0]  == 4'd9);
  
   assign wpntr_push[10] = fifo_push & (wpntr_bin[3:0]  == 4'd10);
  
   assign wpntr_push[11] = fifo_push & (wpntr_bin[3:0]  == 4'd11);
  
      
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
  
   always@(posedge wclk)
    begin : p_wr_fifo4
      if(wpntr_push[4])
   fifo4 <= src_data;
    end
  
   always@(posedge wclk)
    begin : p_wr_fifo5
      if(wpntr_push[5])
   fifo5 <= src_data;
    end
  
   always@(posedge wclk)
    begin : p_wr_fifo6
      if(wpntr_push[6])
   fifo6 <= src_data;
    end
  
   always@(posedge wclk)
    begin : p_wr_fifo7
      if(wpntr_push[7])
   fifo7 <= src_data;
    end
  
   always@(posedge wclk)
    begin : p_wr_fifo8
      if(wpntr_push[8])
   fifo8 <= src_data;
    end
  
   always@(posedge wclk)
    begin : p_wr_fifo9
      if(wpntr_push[9])
   fifo9 <= src_data;
    end
  
   always@(posedge wclk)
    begin : p_wr_fifo10
      if(wpntr_push[10])
   fifo10 <= src_data;
    end
  
   always@(posedge wclk)
    begin : p_wr_fifo11
      if(wpntr_push[11])
   fifo11 <= src_data;
    end
  

   nic400_ib_hostcpu_axis_ib_ar_fifo_wr_mux_sse710_main u_nic400_ib_hostcpu_axis_ib_ar_fifo_wr_mux
   (
      .in_0  (fifo0),
      .in_1  (fifo1),
      .in_2  (fifo2),
      .in_3  (fifo3),
      .in_4  (fifo4),
      .in_5  (fifo5),
      .in_6  (fifo6),
      .in_7  (fifo7),
      .in_8  (fifo8),
      .in_9  (fifo9),
      .in_10 (fifo10),
      .in_11 (fifo11),

      .sel   (rpntr_bin[3:0] ),
      .d_out (dst_data)
   );


   assign full = nic400_ib_hostcpu_axis_ib_ar_fifo_full_fn(wpntr_gry, rpntr_gry);
  

`ifdef ARM_ASSERT_ON

   assert_always #(0,0,"fifo pointer error")
   ovl_wr_pointer
     (
      .clk              (wclk),
      .reset_n          (wresetn),
      .test_expr        ((wpntr_bin[3:0]  <= 11) && (rpntr_bin[3:0]  <= 11))
     );

  `endif 

endmodule


`include "nic400_ib_hostcpu_axis_ib_undefs_sse710_main.v"

