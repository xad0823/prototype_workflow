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


module css600_apbasyncbridgemstr_async
(
  input wire  apb_async_req_async_i,
  input wire  apb_async_ack_i,
  output wire clkmqactive_o
);


  css600_or
  u_or2_qactive
  (
    .in_a  (apb_async_req_async_i),
    .in_b  (apb_async_ack_i),
    .out_y (clkmqactive_o)
  );

endmodule
