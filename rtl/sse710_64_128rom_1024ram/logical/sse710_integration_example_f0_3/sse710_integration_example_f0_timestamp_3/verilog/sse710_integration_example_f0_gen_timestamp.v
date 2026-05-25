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

module sse710_integration_example_f0_gen_timestamp(
  input  wire         aontop_warmresetn_s_hosts32kcntclkout,
  input  wire         aontop_warmresetn_s_hostcntclkout,  
  input  wire         hostcntclkout,
  input  wire         hosts32kcntclkout,
  input  wire  [63:0] hosts32kcntvalueg,
  output wire  [63:0] hosts32kcntvalueb,
  input  wire  [63:0] hostcntvalueg,
  output wire  [63:0] hostcntvalueb  
  );

  sse710_integration_example_f0_gray_to_bin u_sse710_integration_example_f0_gray_to_bin_s32k (
    .binary_count  (hosts32kcntvalueb),
    .clk           (hosts32kcntclkout),
    .gray_count    (hosts32kcntvalueg),
    .resetn        (aontop_warmresetn_s_hosts32kcntclkout)
    );
  
  sse710_integration_example_f0_gray_to_bin u_sse710_integration_example_f0_gray_to_bin_refclk (
    .binary_count  (hostcntvalueb),
    .clk           (hostcntclkout),
    .gray_count    (hostcntvalueg),
    .resetn        (aontop_warmresetn_s_hostcntclkout)
  );  

endmodule
