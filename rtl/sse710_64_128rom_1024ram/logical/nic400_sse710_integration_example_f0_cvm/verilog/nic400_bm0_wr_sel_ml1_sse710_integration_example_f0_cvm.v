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


module nic400_bm0_wr_sel_ml1_sse710_integration_example_f0_cvm
  (
    wdata_s0,
    wstrb_s0,   
    wlast_s0,
    wvalid_s0,
    wready_s0,

    wdata_m,
    wstrb_m,
    wlast_m,
    wvalid_m,
    wready_m
  );




  output  [63:0]    wdata_m;
  output  [7:0]     wstrb_m;
  output            wlast_m;
  output            wvalid_m;
  input             wready_m;
  input  [63:0]     wdata_s0;
  input  [7:0]      wstrb_s0;   
  input             wlast_s0;
  input             wvalid_s0;
  output            wready_s0;







    assign wdata_m  = wdata_s0;
    assign wstrb_m  = wstrb_s0;
    assign wlast_m  = wlast_s0;
    assign wvalid_m = wvalid_s0;
    assign wready_s0 = wready_m; 

endmodule


