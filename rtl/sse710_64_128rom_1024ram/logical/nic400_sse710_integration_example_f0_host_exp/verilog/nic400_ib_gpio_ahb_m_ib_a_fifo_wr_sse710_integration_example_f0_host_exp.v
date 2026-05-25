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


`include "nic400_ib_gpio_ahb_m_ib_defs_sse710_integration_example_f0_host_exp.v"

  




module nic400_ib_gpio_ahb_m_ib_a_fifo_wr_sse710_integration_example_f0_host_exp
  (
   src_ready,
   dst_data,
   
   wpntr_gry_async,
   wclk,
   wresetn,
   src_data,
   src_valid,
   rpntr_gry_async,
   rpntr_bin
   );

   input        wclk;
   input        wresetn;

   output                     src_ready;
   input  [88:0]              src_data;
   input                      src_valid;
   output [3:0]               wpntr_gry_async;

   input [3:0]                rpntr_gry_async;
   input [2:0]                rpntr_bin;
   output [88:0]              dst_data;


    
  


   reg [3:0]      wpntr_gry;
  wire [3:0]      wpntr_gry_async;
   reg  [88:0]                fifo0;
   wire [88:0]                fifo0_corrupt;
   reg  [88:0]                fifo1;
   wire [88:0]                fifo1_corrupt;
   reg  [88:0]                fifo2;
   wire [88:0]                fifo2_corrupt;
   reg  [88:0]                fifo3;
   wire [88:0]                fifo3_corrupt;
   reg  [88:0]                fifo4;
   wire [88:0]                fifo4_corrupt;
   reg  [88:0]                fifo5;
   wire [88:0]                fifo5_corrupt;
  



   wire [3:0]  next_wpntr_gry;

   wire [2:0]  wpntr_bin;
   wire [3:0]  rpntr_gry_wsync;


   wire [5:0]  wpntr_push;
     
   
   wire        full;
   wire        fifo_push;

`include "nic400_ib_gpio_ahb_m_ib_a_fifo_fn_sse710_integration_example_f0_host_exp.v"


   assign src_ready = ~full;
   assign fifo_push = src_valid & ~full;

   
   nic400_ib_gpio_ahb_m_ib_a_fifo_sync_sse710_integration_example_f0_host_exp u_sync_rd_ptr_gry
   (
      .clk       (wclk),
      .resetn    (wresetn),
      .ptr_async (rpntr_gry_async),
      .ptr_sync  (rpntr_gry_wsync)
   );

   nic400_cdc_launch_gry_sse710_integration_example_f0_host_exp #(4) u_cdc_launch_wr_ptr_gry
   (
      .clk       (wclk),
      .resetn    (wresetn),
      .enable    (fifo_push),
      .in_cdc    (next_wpntr_gry),
      .out_async (wpntr_gry_async));
  

   always@(posedge wclk or negedge wresetn)
     begin : p_wpnt_seq
        if(!wresetn)
           wpntr_gry <= {4{1'b0}};
        else if (fifo_push)
           wpntr_gry <= next_wpntr_gry;
     end

   assign next_wpntr_gry = nic400_ib_gpio_ahb_m_ib_a_fifo_next_gry_fn(wpntr_gry);

   assign wpntr_bin      = nic400_ib_gpio_ahb_m_ib_a_fifo_gry_to_bin_fn(wpntr_gry);

  
   assign wpntr_push[0] = fifo_push & (wpntr_bin[2:0]  == 3'd0);
  
   assign wpntr_push[1] = fifo_push & (wpntr_bin[2:0]  == 3'd1);
  
   assign wpntr_push[2] = fifo_push & (wpntr_bin[2:0]  == 3'd2);
  
   assign wpntr_push[3] = fifo_push & (wpntr_bin[2:0]  == 3'd3);
  
   assign wpntr_push[4] = fifo_push & (wpntr_bin[2:0]  == 3'd4);
  
   assign wpntr_push[5] = fifo_push & (wpntr_bin[2:0]  == 3'd5);
  
      
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
  
  
  nic400_ib_gpio_ahb_m_ib_cdc_air_corrupt_sse710_integration_example_f0_host_exp #(89,"fwd") u_cdc_corrupt_fifo_0
   (
      .d   (fifo0),
      .q   (fifo0_corrupt)
   );
  
  nic400_ib_gpio_ahb_m_ib_cdc_air_corrupt_sse710_integration_example_f0_host_exp #(89,"fwd") u_cdc_corrupt_fifo_1
   (
      .d   (fifo1),
      .q   (fifo1_corrupt)
   );
  
  nic400_ib_gpio_ahb_m_ib_cdc_air_corrupt_sse710_integration_example_f0_host_exp #(89,"fwd") u_cdc_corrupt_fifo_2
   (
      .d   (fifo2),
      .q   (fifo2_corrupt)
   );
  
  nic400_ib_gpio_ahb_m_ib_cdc_air_corrupt_sse710_integration_example_f0_host_exp #(89,"fwd") u_cdc_corrupt_fifo_3
   (
      .d   (fifo3),
      .q   (fifo3_corrupt)
   );
  
  nic400_ib_gpio_ahb_m_ib_cdc_air_corrupt_sse710_integration_example_f0_host_exp #(89,"fwd") u_cdc_corrupt_fifo_4
   (
      .d   (fifo4),
      .q   (fifo4_corrupt)
   );
  
  nic400_ib_gpio_ahb_m_ib_cdc_air_corrupt_sse710_integration_example_f0_host_exp #(89,"fwd") u_cdc_corrupt_fifo_5
   (
      .d   (fifo5),
      .q   (fifo5_corrupt)
   );
  

   nic400_ib_gpio_ahb_m_ib_a_fifo_wr_mux_sse710_integration_example_f0_host_exp u_nic400_ib_gpio_ahb_m_ib_a_fifo_wr_mux
   (
      .in_0  (fifo0_corrupt),
      .in_1  (fifo1_corrupt),
      .in_2  (fifo2_corrupt),
      .in_3  (fifo3_corrupt),
      .in_4  (fifo4_corrupt),
      .in_5  (fifo5_corrupt),

      .sel   (rpntr_bin[2:0] ),
      .d_out (dst_data)
   );


   assign full = nic400_ib_gpio_ahb_m_ib_a_fifo_full_fn(wpntr_gry, rpntr_gry_wsync);
  

`ifdef ARM_ASSERT_ON

   assert_always #(0,0,"fifo pointer error")
   ovl_wr_pointer
     (
      .clk              (wclk),
      .reset_n          (wresetn),
      .test_expr        ((wpntr_bin[2:0]  <= 5) && (rpntr_bin[2:0]  <= 5))
     );

  `endif 

endmodule


`include "nic400_ib_gpio_ahb_m_ib_undefs_sse710_integration_example_f0_host_exp.v"

