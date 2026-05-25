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

module nic400_cdc_launch_gry_sse710_boot_reg (
  clk, 
  resetn, 
  enable,
  in_cdc,
  out_async
  );

  parameter WIDTH = 1;
  
  input               clk; 
  input               resetn; 
  input               enable;
  input  [WIDTH-1:0]  in_cdc;
  output [WIDTH-1:0]  out_async;


  reg   [WIDTH-1:0]  out_async;

  always@(posedge clk or negedge resetn)
     begin : p_cdc_launch_seq
        if(!resetn)
           out_async <= {WIDTH{1'b0}};
        else if (enable)
           out_async <= in_cdc;
     end

`ifdef ARM_ASSERT_ON

  ovl_code_distance
    #(0, 1, 1, WIDTH, 0, "Clock domain crossing signal is not correctly gray encoded")
      ovl_gray_enc_check
        (.clock        (clk),
         .reset      (resetn),
         .enable     (1'b1),
         .test_expr1 (in_cdc),
         .test_expr2 (out_async),
         .fire       ());

`endif
  
endmodule
