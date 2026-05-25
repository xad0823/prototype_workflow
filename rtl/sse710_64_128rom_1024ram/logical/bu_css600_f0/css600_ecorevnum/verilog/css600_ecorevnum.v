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
//   Top level of css600_ecorevnum
//
//----------------------------------------------------------------------------


module css600_ecorevnum #(
  parameter             WIDTH = 4,
  parameter [WIDTH-1:0] ECOREVVAL = {WIDTH{1'b0}}
)
(
  output wire [WIDTH-1:0] ecorevnum
);

  genvar i;
  generate
    for (i=0; i<WIDTH; i=i+1) begin: gen_bits

      css600_ecorevnum_bit #(.ECOBITVAL(ECOREVVAL[i +: 1]))
                   u_css600_ecorevnum_bit (.ecorevbit(ecorevnum[i]));

    end
  endgenerate

endmodule
