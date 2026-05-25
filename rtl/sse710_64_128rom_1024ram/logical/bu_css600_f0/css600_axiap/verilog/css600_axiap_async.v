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
//   Sub-module of css600_axiap
//
//----------------------------------------------------------------------------


module css600_axiap_async
(
  input  wire pwakeup,
  input  wire itctrl_ime,
  input  wire mstr_tr_in_prog,
  input  wire awvalid,
  input  wire arvalid,
  input  wire wvalid,
  output wire awakeup,
  output wire clk_qactive
);

  wire or1;
  wire or2;

  css600_or u_css600_or1 (.out_y (awakeup),
                          .in_a (wvalid),
                          .in_b (or1));

  css600_or u_css600_or2 (.out_y (or1),
                          .in_a (arvalid),
                          .in_b (awvalid));

  css600_or u_css600_or3 (.out_y (clk_qactive),
                          .in_a (itctrl_ime),
                          .in_b (or2));

  css600_or u_css600_or4 (.out_y (or2),
                          .in_a (pwakeup),
                          .in_b (mstr_tr_in_prog));

endmodule
