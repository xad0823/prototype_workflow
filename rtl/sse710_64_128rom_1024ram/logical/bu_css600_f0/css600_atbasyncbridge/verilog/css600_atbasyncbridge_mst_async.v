//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2017-2019 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Sub-module of css600_atbasyncbridge
//
//----------------------------------------------------------------------------


module css600_atbasyncbridge_mst_async
(
  input  wire [3:0] rd_pointer_gray,
  input  wire [3:0] wr_pointer_gray,
  input  wire       afvalid_m,
  input  wire       pulse_qactive,
  input  wire       atwakeup_m,
  input  wire       sync_clear,
  input  wire       sync_done,
  output wire       clk_m_qactive
);

  wire pwr_dwn;
  wire [3:0] empty_n;
  genvar i;

  generate for (i=0; i<4; i=i+1) begin: gen_empty
    css600_xor u_xor_0 (
      .in_a (rd_pointer_gray[i]),
      .in_b (wr_pointer_gray[i]),
      .out_y (empty_n[i])
    );
  end
  endgenerate

  css600_xor u_xor_1 (
    .in_a (sync_clear),
    .in_b (sync_done),
    .out_y (pwr_dwn)
  );

  css600_or_tree #(
    .NUM_OR_INPUTS (8)
  ) u_qactive_or
  (
    .or_inputs ({empty_n, afvalid_m, pulse_qactive, atwakeup_m, pwr_dwn}),
    .or_output (clk_m_qactive)
  );

endmodule
