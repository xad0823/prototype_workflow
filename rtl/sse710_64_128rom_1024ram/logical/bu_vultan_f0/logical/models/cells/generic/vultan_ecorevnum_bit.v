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
//   This module creates an ECO modifiable single bit.
//   The arm_element_mux cell must be replaced with suitable equivalent technology
//   cell of sufficient drive strenth to drive the external load.
//   Initially the output will be driven by to zero.
//   In the future, by ECO, the value can be driven to 1 in one of two ways:
//     The i0 and i1 inputs can be swapped
//     The i1 and s inputs can be swapped
//   The cell must be preserved during implementation:
//     set_dont_touch <path>u_vultan_mux
//
//----------------------------------------------------------------------------

module vultan_ecorevnum_bit #(parameter ECOBITVAL = 0)
(
  output wire  ecorevbit
);

  generate
    if (ECOBITVAL == 0) begin: gen_0
      vultan_mux #(.DATA_WIDTH(1)) u_vultan_mux (.in_a(1'b1), .in_b(1'b0), .sel(1'b1), .out_y(ecorevbit));
    end
    else begin: gen_1
      vultan_mux #(.DATA_WIDTH(1)) u_vultan_mux (.in_a(1'b1), .in_b(1'b0), .sel(1'b0), .out_y(ecorevbit));
    end
  endgenerate

endmodule
