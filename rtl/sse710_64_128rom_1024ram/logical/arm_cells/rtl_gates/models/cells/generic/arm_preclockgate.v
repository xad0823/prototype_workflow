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

module arm_preclockgate (
  input   wire                          clk_i,
  input   wire                          enable_i,
  output  wire                          clk_o, 
  input   wire                          scan_enable_i
);

  reg clk_enable_lat;

  always @ (clk_i or enable_i or scan_enable_i)
    begin
      if (~clk_i)
        clk_enable_lat <= enable_i | scan_enable_i;
    end

  assign clk_o = clk_i & clk_enable_lat;

endmodule

