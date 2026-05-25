//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------

module e_clk_f1_reset_sync_secenc_clk(
  input   wire                          CLK,
  input   wire                          ASYNCRESETn,
  output  wire                          SYNCRESETn,
  input   wire                          DFTRSTDISABLE

);

arm_element_reset_sync u_reset_sync(
  .clk                                  (CLK),
  .resetn_async                         (ASYNCRESETn),
  .resetn_sync                          (SYNCRESETn),
  .dftrstdisable                        (DFTRSTDISABLE)
 
);
  
endmodule
