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
function integer firewall_f0_log2;
  input  [31:0] value;
  reg    [31:0] tmp;
  begin
    if (value < 2) begin
      firewall_f0_log2 = 1;
    end
    else begin
      tmp = value - 1;
      for (firewall_f0_log2 = 0; tmp > 0; firewall_f0_log2 = firewall_f0_log2 + 1)
        tmp = tmp >> 1;
    end
  end
endfunction
