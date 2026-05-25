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



module nic400_rsb_cdc_air_corrupt_sse710_main (
  d,
  q
  );

  parameter WIDTH = 1;
  parameter destclk = "clk";
  
  input  [WIDTH-1:0]  d;
  output [WIDTH-1:0]  q;


`ifdef ARM_CDC_CHECK

  `include "nic400_closure_sse710_main_defs.v"

  wire                  change;
  reg      [WIDTH-1:0]  d_latch;
  wire     [WIDTH-1:0]  out;
  reg      clk;
  wire     async;
  reg      p1;
  reg      p2;


  `ifdef ARM_CDC_BLOCK_LEVEL
  
    assign async = 1'b1;

    generate
    
            if(destclk == `RSB_A_SLAVE_SRC_CLK) begin : b_block_1
                assign clk = u_rsb.aclk_r;
            end 
            else
            if(destclk == `RSB_A_MASTER_SRC_CLK) begin : b_block_2
                assign clk = u_rsb.aclk_r;
            end 
            else begin : b_block_last
                assign clk = 1'bx;
            end
    
    endgenerate


  `else

    assign async = 1'b1;

    generate
    
            if(destclk == `RSB_A_SLAVE_SRC_CLK) begin : b_sys_1
                assign clk = nic400_sse710_main.aclk_r;
            end 
            else
            if(destclk == `RSB_A_MASTER_SRC_CLK) begin : b_sys_2
                assign clk = nic400_sse710_main.aclk_r;
            end 
            else begin : b_sys_last
                assign clk = 1'bx;
            end 
    
    endgenerate


  `endif


  assign q = (async) ? out : d;

  always @(d)
     d_latch <= d;

  assign change = (d !== d_latch);   

  always @(posedge clk or posedge change)
    begin 
       if (change) begin
          p1 <= 1'b1;
          p2 <= 1'b1;
       end else begin
          p1 <= 1'b0;
          p2 <= p1;
       end
    end

  assign out = (p2) ? {WIDTH{1'bz}} : d;

  `include "nic400_closure_sse710_main_undefs.v"

`else

  assign q = d;

`endif
  
endmodule

