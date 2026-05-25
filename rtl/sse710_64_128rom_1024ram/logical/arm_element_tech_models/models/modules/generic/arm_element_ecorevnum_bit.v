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


module arm_element_ecorevnum_bit #(parameter ECOBITVAL = 0)
(
  output wire  ecorevbit
);

  generate
    if (ECOBITVAL == 0) begin: gen_0
      arm_element_cdc_comb_mux2 u_arm_element_cdc_comb_mux2 (.dout_async(ecorevbit), .din1_async(1'b1), .din2_async(1'b0), .sel(1'b1));
    end
    else begin: gen_1
      arm_element_cdc_comb_mux2 u_arm_element_cdc_comb_mux2 (.dout_async(ecorevbit), .din1_async(1'b1), .din2_async(1'b0), .sel(1'b0));
    end
  endgenerate

endmodule
