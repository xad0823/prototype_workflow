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

module nic400_cdc_capt_sync_sse710_integration_example_f0_flash (clk, resetn, d_async, sync_en, q);

  parameter WIDTH = 4;

  input                clk;
  input                resetn;
  input [WIDTH-1:0]    d_async;     
  input                sync_en;
  output [WIDTH-1:0]   q;


  wire [WIDTH-1:0]     d_noz;
  reg  [WIDTH-1:0]     d_sync1;
  reg  [WIDTH-1:0]     q;

`ifdef ARM_CDC_CHECK

  nic400_cdc_random_sse710_integration_example_f0_flash #(WIDTH) u_cdc_random_z(
                             .din (d_async),
                             .dout (d_noz)
                             );

`else

  assign d_noz = d_async;

`endif

  always @(posedge clk or negedge resetn)
    if (!resetn)
      begin
        d_sync1 <= {WIDTH{1'b0}};
        q <= {WIDTH{1'b0}};
      end
    else if(sync_en)
      begin
        d_sync1 <= d_noz;
        q <= d_sync1;
      end
      
endmodule

