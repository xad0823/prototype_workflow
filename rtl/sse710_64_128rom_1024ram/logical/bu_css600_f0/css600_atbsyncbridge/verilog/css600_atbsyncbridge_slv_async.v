//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2017 Arm Limited or its affiliates.
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
//   Sub-module of css600_atbsyncbridge
//
//----------------------------------------------------------------------------


module css600_atbsyncbridge_slv_async (
  input  wire atwakeup_s,
  input  wire pwr_qreq_n,
  input  wire pwr_qaccept_n,
  input  wire flush_req,
  input  wire syncreq_req,
  output wire clk_s_qactive
);

  wire pwr_wake;

  css600_xor u_clk_lpi_wake_up_xor (
    .in_a(pwr_qaccept_n),
    .in_b(pwr_qreq_n),
    .out_y(pwr_wake)
  );

  css600_or_tree #(
    .NUM_OR_INPUTS (4)
  ) u_clk_qactive_or
  (
    .or_inputs ({pwr_wake, atwakeup_s, flush_req, syncreq_req}),
    .or_output (clk_s_qactive)
  );

endmodule
