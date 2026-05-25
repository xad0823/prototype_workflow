// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2018 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Mon Jun 18 12:26:53 2018 +0100
//
//      Revision            : 42b0335
//
//      Release Information : CoreLink XHB-500 Generic Global Bundle r0p0-00rel0
//
//-----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// This module should be preserved during implementation
// to ensure that an input whose timing is potentially unsafe does not glitch
// to other logic and cause metastability.
//----------------------------------------------------------------------------

module xhb500_or #(
  parameter DATA_WIDTH = 1
  ) (
  input  wire [DATA_WIDTH-1:0]  in_a,
  input  wire [DATA_WIDTH-1:0]  in_b,
  output wire [DATA_WIDTH-1:0]  out_y
  );


  assign out_y = in_a | in_b;


endmodule
