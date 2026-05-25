//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2025 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//-----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Fri Mar 29 11:15:40 2019 +0000
//
//      Revision            : 08e988e
//
//      Release Information : CoreLink XHB-500 Generic Global Bundle r0p0-00rel0
//
module xhb500_bypass_regd_slice_empty
#(
  parameter PAYLD_WIDTH = 2
)
(
  output     logic                     empty,

  input wire logic                     valid_src,
  input wire logic [PAYLD_WIDTH-1:0]   payload_src,
  output     logic                     ready_src,

  input wire logic                     ready_dst,
  output     logic                     valid_dst,
  output     logic [PAYLD_WIDTH-1:0]   payload_dst
);

  assign valid_dst    = valid_src;
  assign ready_src    = ready_dst;
  assign payload_dst  = payload_src;
  assign empty        = 1'b1;

endmodule

