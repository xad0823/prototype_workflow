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

module nic400_cdc_bypass_sync_sse710_dbg3s1m
(
  clk,
  resetn,
  sync_en,
  mux_sel,
  d_async,
  q
);


  input          clk;
  input          resetn;
  input          sync_en;
  input          mux_sel;
  input          d_async;
  output         q;


  wire           d_capt;


  nic400_cdc_capt_sync_sse710_dbg3s1m #(1) u_cdc_capt_sync
  (
    .clk     (clk),
    .resetn  (resetn),
    .sync_en (sync_en),
    .d_async (d_async),
    .q       (d_capt)
  );

  nic400_cdc_comb_mux2_sse710_dbg3s1m u_cdc_mux
  (
    .din1_async (d_async),
    .din2_async (d_capt),
    .sel        (mux_sel),
    .dout_async (q)
  );

`ifdef ARM_CDC_CHECK

`ifdef ARM_ASSERT_ON
  assert_never #(0, 0, "Unsafe operation detected across CDC boundary4") uovl011
   (.clk              (clk),
     .reset_n          (resetn),
     .test_expr        (q === 1'bz)
   );
`endif

`endif

endmodule

