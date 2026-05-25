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
//   Sub-module of css600_ahbap
//
//----------------------------------------------------------------------------


module css600_ahbap_async
(
  input  wire       pwakeup_s,
  input  wire       itctrl_ime,
  input  wire [1:0] mstr_state,
  output wire       clk_qactive
);

  wire or1;
  wire or2;

  css600_or u_css600_or1 (.out_y (clk_qactive),
                          .in_a (or1),
                          .in_b (or2));

  css600_or u_css600_or2 (.out_y (or1),
                          .in_a (pwakeup_s),
                          .in_b (itctrl_ime));

  css600_or u_css600_or3 (.out_y (or2),
                          .in_a (mstr_state[0]),
                          .in_b (mstr_state[1]));

endmodule
