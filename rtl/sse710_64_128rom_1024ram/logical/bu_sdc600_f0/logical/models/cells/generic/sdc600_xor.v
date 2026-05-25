//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2017-2018 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Mon Feb 19 12:27:52 2018 +0000
//
//      Revision            : bdc4508
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//----------------------------------------------------------------------------


module sdc600_xor #(
  parameter DATA_WIDTH = 1
  ) (
  input  wire [DATA_WIDTH-1:0]  in_a,
  input  wire [DATA_WIDTH-1:0]  in_b,
  output wire [DATA_WIDTH-1:0]  out_y
  );

  assign out_y = in_a ^ in_b;


endmodule
