// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//               (C) COPYRIGHT 2018-2019 Arm Limited or its affiliates.
//                   ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Mon Jul 8 16:16:13 2019 +0100
//
//      Revision            : 28b24c60
//
//      Release Information : CoreLink SIE-300 Generic Global Bundle r1p2-00rel0
//
// -----------------------------------------------------------------------------

module sie300_arm_or2 (
  input wire                  a_i,
  input wire                  b_i,
  output wire                 y_o
);


  assign y_o = a_i | b_i;


endmodule

