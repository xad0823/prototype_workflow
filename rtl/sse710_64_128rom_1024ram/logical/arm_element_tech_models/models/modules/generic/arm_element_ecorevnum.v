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


module arm_element_ecorevnum #(
  parameter             WIDTH = 4,
  parameter [WIDTH-1:0] ECOREVVAL = {WIDTH {1'bx}}
)
(
  output wire [WIDTH-1:0] ecorevnum
);

  genvar i;
  generate
          for (i=0; i<WIDTH; i=i+1) begin: gen_bits
                  arm_idbit_v1 #(
                          .VALUE(ECOREVVAL[i])
                  ) u_idbit_v1 (
                          .y_o(ecorevnum[i])
                  );
          end
  endgenerate

endmodule
