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
//   Sub-module of css600_atbasyncbridge
//
//----------------------------------------------------------------------------


module css600_atbasyncbridge_slv_async
(
  input  wire pwr_qreq_n,
  input  wire pwr_qaccept_n,
  input  wire pulse_qactive,
  input  wire atwakeup_s,
  input  wire flush_req,
  output wire clk_s_qactive
);

  wire pwr_clock_request;

  css600_xor u_clk_req_xor (
    .in_a(pwr_qreq_n),
    .in_b(pwr_qaccept_n),
    .out_y(pwr_clock_request)
  );

  css600_or_tree #(
    .NUM_OR_INPUTS (4)
  ) u_clk_s_qactive_or
  (
    .or_inputs({pulse_qactive, flush_req, pwr_clock_request, atwakeup_s}),
    .or_output(clk_s_qactive)
  );

endmodule
