// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2017 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Mon Sep 18 16:19:37 2017 +0100
//
//      Revision            : e9f2264
//
//      Release Information : Vultan Generic Flash Controller - Global Bundle r0p0-00rel0
//
//-----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// This module should be preserved during implementation
// to ensure that an input whose timing is potentially unsafe does not glitch
// to other logic and cause metastability.
//----------------------------------------------------------------------------

module vultan_xor #(
  parameter DATA_WIDTH = 1
  ) (
  input  wire [DATA_WIDTH-1:0]  in_a,
  input  wire [DATA_WIDTH-1:0]  in_b,
  output wire [DATA_WIDTH-1:0]  out_y
  );


  assign out_y = in_a ^ in_b;



endmodule
