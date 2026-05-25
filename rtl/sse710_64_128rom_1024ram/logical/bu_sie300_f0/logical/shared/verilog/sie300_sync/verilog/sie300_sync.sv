//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2019 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Mon Jul 8 09:27:05 2019 +0100
//
//      Revision            : fa74f2b1
//
//      Release Information : CoreLink SIE-300 Generic Global Bundle r1p2-00rel0
//
//----------------------------------------------------------------------------

module sie300_sync (
      input  wire clk,
      input  wire reset_n,
      input  wire d,
      output wire q
   );


sie300_arm_sdff2yrpq  u_sync (.clk_i(clk), .reset_i(~reset_n), .d_i(d), .q_o(q), .scan_enable_i(1'b0), .scan_i(1'b0));


endmodule
