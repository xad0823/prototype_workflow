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
//   Shared sub-module of css600_ecorevnum
//
//----------------------------------------------------------------------------


module css600_ecorevnum_bit #(parameter ECOBITVAL = 1'b0)
(
  output wire  ecorevbit
);

  generate
    if (ECOBITVAL == 1'b0) begin: gen_0
      css600_mux2 u_css600_mux2 (.dout_async(ecorevbit), .din1_async(1'b1), .din2_async(1'b0), .sel(1'b1));
    end
    else begin: gen_1
      css600_mux2 u_css600_mux2 (.dout_async(ecorevbit), .din1_async(1'b1), .din2_async(1'b0), .sel(1'b0));
    end
  endgenerate

endmodule
