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
//      Checked In          : Thu Sep 7 10:31:46 2017 +0100
//
//      Revision            : 7406604
//
//      Release Information : Vultan Generic Flash Controller - Global Bundle r0p0-00rel0
//
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//   This module instantiates 4 bits to implement a 4-bit revision code that can
//   be modified for ECO purposes.
//
//----------------------------------------------------------------------------

module vultan_ecorevnum #(
  parameter             WIDTH = 4,
  parameter [WIDTH-1:0] ECOREVVAL = 0
)
(
  output wire [WIDTH-1:0] ecorevnum
);

  genvar i;
  generate
    for (i=0; i<WIDTH; i=i+1) begin: gen_bits

      localparam ECOBITVAL = ECOREVVAL[i] == 1'b1 ? 1 : 0;

      vultan_ecorevnum_bit #(.ECOBITVAL(ECOBITVAL))
                   u_vultan_ecorevnum_bit (.ecorevbit(ecorevnum[i]));

    end
  endgenerate

endmodule

