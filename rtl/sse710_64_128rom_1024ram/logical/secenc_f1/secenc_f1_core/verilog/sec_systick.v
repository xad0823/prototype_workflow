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


module sec_systick (
  input  wire                s32k_clk,
  input  wire                s32k_rstn,
  input  wire                st_clk,
  input  wire                st_rstn,
  output wire                st_clken
);

  reg   toggle;
  wire  stoggle;
  reg   stoggle_dly;

  always @(posedge s32k_clk or negedge s32k_rstn)
    if (~s32k_rstn)
      toggle <= 1'b0;
    else
      toggle <= ~toggle;

  sec_cdc_capt_sync u_sec_cdc_capt_sync (
    .clk        (st_clk),
    .nreset     (st_rstn),
    .d_async    (toggle),
    .q          (stoggle)
  );

  always @(posedge st_clk or negedge st_rstn)
    if (~st_rstn)
      stoggle_dly <= 1'b0;
    else
      stoggle_dly <= stoggle;

  assign st_clken = stoggle_dly ^ stoggle;

endmodule
