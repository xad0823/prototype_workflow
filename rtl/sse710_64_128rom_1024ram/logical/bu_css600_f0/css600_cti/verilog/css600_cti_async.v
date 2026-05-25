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
//   Sub-module of css600_cti
//
//----------------------------------------------------------------------------


module css600_cti_async
(
  input  wire                           cti_en,
  input  wire                           iten,
  input  wire                           psel,
  input  wire                           pwakeup,
  output wire                           cti_active,
  output wire                           clk_qactive
);

  wire enables;
  assign cti_active  = cti_en  |
                       iten    |
                       psel;

  css600_or
  u_css600_or_enables
  (
    .in_a  ( cti_en  ),
    .in_b  ( iten    ),
    .out_y ( enables )
  );
  css600_or
  u_css600_or_qactive
  (
    .in_a  ( enables     ),
    .in_b  ( pwakeup     ),
    .out_y ( clk_qactive )
  );

endmodule

