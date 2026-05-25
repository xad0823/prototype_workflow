//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2014-2017 Arm Limited or its affiliates.
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
//   Sub-module of css600_apbasyncbridge
//
//----------------------------------------------------------------------------


module css600_apbasyncbridgeslv_async
(
  input wire  pwrqreqn_async_i,
  input wire  pwakeup_i,
  input wire  pwrqacceptn_i,
  input wire  pwrqdeny_i,
  output wire clksqactive_o
);


  wire pwrqreqn_pwrqacceptn_xor;

  wire pwake_pwrqdeny_or;


  css600_xor
  u_xor
  (
    .in_a  (pwrqreqn_async_i),
    .in_b  (pwrqacceptn_i),
    .out_y (pwrqreqn_pwrqacceptn_xor)
  );

  css600_or
  u_or2_pwakeup_pwrqdeny
  (
    .in_a  (pwakeup_i),
    .in_b  (pwrqdeny_i),
    .out_y (pwake_pwrqdeny_or)
  );

  css600_or
  u_or2_qactive
  (
    .in_a  (pwake_pwrqdeny_or),
    .in_b  (pwrqreqn_pwrqacceptn_xor),
    .out_y (clksqactive_o)
  );

endmodule
