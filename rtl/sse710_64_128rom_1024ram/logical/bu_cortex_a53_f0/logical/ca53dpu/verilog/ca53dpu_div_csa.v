//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2012-09-03 09:54:05 +0100 (Mon, 03 Sep 2012) $
//
//      Revision            : $Revision: 220916 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Integer SRT Radix-4 quotient selection logic
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Selects the next result digit for a div operation
//

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_div_csa #(parameter CSA_WIDTH = 66) (
  input  wire [CSA_WIDTH-4:0] csa_plus_i,
  input  wire [CSA_WIDTH-4:0] csa_minus_i,
  input  wire [CSA_WIDTH-2:0] rem_sum_i,
  input  wire [CSA_WIDTH-2:0] rem_carry_i,

  output wire [CSA_WIDTH-2:0] rem_sum_zero_o,
  output wire [CSA_WIDTH-2:0] rem_carry_zero_o,
  output wire [CSA_WIDTH-2:0] rem_sum_minus_d_o,
  output wire [CSA_WIDTH-2:0] rem_carry_minus_d_o,
  output wire [CSA_WIDTH-2:0] rem_sum_plus_d_o,
  output wire [CSA_WIDTH-2:0] rem_carry_plus_d_o
);

  generate if (CSA_WIDTH>3) begin : g_csa_full_width
    // CSA 1: result = rem_sum + rem_carry
    assign rem_sum_zero_o[(CSA_WIDTH-2):0]   = {2'b01,
                                              rem_sum_i[(CSA_WIDTH-4):0] ^
                                              rem_carry_i[(CSA_WIDTH-4):0]};

    assign rem_carry_zero_o[(CSA_WIDTH-2):0] = {1'b1,
                                            (rem_sum_i[(CSA_WIDTH-4):0]  &
                                             rem_carry_i[(CSA_WIDTH-4):0]),
                                            1'b0};

    // CSA 2: result = rem_sum + rem_carry + csa_plus_i
    assign rem_sum_plus_d_o[(CSA_WIDTH-4):0] = rem_sum_i    [(CSA_WIDTH-4):0] ^
                                             rem_carry_i    [(CSA_WIDTH-4):0] ^
                                             csa_plus_i [(CSA_WIDTH-4):0];

    assign rem_carry_plus_d_o[(CSA_WIDTH-3):0] =
      {(rem_sum_i  [(CSA_WIDTH-4):0] & rem_carry_i       [(CSA_WIDTH-4):0]) |
       (rem_sum_i  [(CSA_WIDTH-4):0] & csa_plus_i    [(CSA_WIDTH-4):0]) |
       (rem_carry_i  [(CSA_WIDTH-4):0] & csa_plus_i    [(CSA_WIDTH-4):0]),
       1'b0};

    // CSA 3: result = rem_sum + rem_carry + csa_minus_i
    assign rem_sum_minus_d_o[(CSA_WIDTH-4):0] = rem_sum_i    [(CSA_WIDTH-4):0] ^
                                              rem_carry_i    [(CSA_WIDTH-4):0] ^
                                              ~csa_minus_i[(CSA_WIDTH-4):0];

    assign rem_carry_minus_d_o[(CSA_WIDTH-3):0] =
      {(rem_sum_i  [(CSA_WIDTH-4):0] & rem_carry_i    [(CSA_WIDTH-4):0]) |
       (rem_sum_i  [(CSA_WIDTH-4):0] & ~csa_minus_i[(CSA_WIDTH-4):0]) |
       (rem_carry_i  [(CSA_WIDTH-4):0] & ~csa_minus_i[(CSA_WIDTH-4):0]),
       1'b1};
  end else begin : g_csa_narrow
    assign rem_sum_zero_o[1:0] = 2'b01;
    assign rem_carry_zero_o[1:0] = 2'b10;
    assign rem_carry_plus_d_o[0] = 1'b0;
    assign rem_carry_minus_d_o[0] = 1'b1;
  end endgenerate

 // Logic to calculate MSBs of adder - compresses result to prevent wordlength
 // growth and ensure only 3 bits are needed for future comparisons.
 // This is possible because we know the output value can only be within
 // a certain range (+/- csa_plus_i)
  assign rem_carry_minus_d_o[CSA_WIDTH-2] =
    (~rem_sum_i[CSA_WIDTH-2] & ~rem_sum_i[CSA_WIDTH-3] & ~rem_carry_i[CSA_WIDTH-2] & ~rem_carry_i[CSA_WIDTH-3]) |
    ( rem_sum_i[CSA_WIDTH-2] & ~rem_sum_i[CSA_WIDTH-3] &  rem_carry_i[CSA_WIDTH-2] & ~rem_carry_i[CSA_WIDTH-3]) |
    ( rem_sum_i[CSA_WIDTH-2] &  rem_sum_i[CSA_WIDTH-3] & ~rem_carry_i[CSA_WIDTH-2] &  rem_carry_i[CSA_WIDTH-3]) |
    (~rem_sum_i[CSA_WIDTH-2] &  rem_sum_i[CSA_WIDTH-3] &  rem_carry_i[CSA_WIDTH-2] &  rem_carry_i[CSA_WIDTH-3]) |
    (~rem_sum_i[CSA_WIDTH-2] &  rem_sum_i[CSA_WIDTH-3] & ~rem_carry_i[CSA_WIDTH-2] & ~rem_carry_i[CSA_WIDTH-3]) |
    ( rem_sum_i[CSA_WIDTH-2] &  rem_sum_i[CSA_WIDTH-3] &  rem_carry_i[CSA_WIDTH-2] & ~rem_carry_i[CSA_WIDTH-3]) |
    (~rem_sum_i[CSA_WIDTH-2] & ~rem_sum_i[CSA_WIDTH-3] & ~rem_carry_i[CSA_WIDTH-2] &  rem_carry_i[CSA_WIDTH-3]) |
    ( rem_sum_i[CSA_WIDTH-2] & ~rem_sum_i[CSA_WIDTH-3] &  rem_carry_i[CSA_WIDTH-2] &  rem_carry_i[CSA_WIDTH-3]);

  assign rem_sum_minus_d_o[CSA_WIDTH-2] = 1'b0;

  assign rem_sum_minus_d_o[CSA_WIDTH-3] =
    (~rem_sum_i[CSA_WIDTH-2] &  rem_sum_i[CSA_WIDTH-3] & ~rem_carry_i[CSA_WIDTH-2] & ~rem_carry_i[CSA_WIDTH-3]) |
    ( rem_sum_i[CSA_WIDTH-2] &  rem_sum_i[CSA_WIDTH-3] &  rem_carry_i[CSA_WIDTH-2] & ~rem_carry_i[CSA_WIDTH-3]) |
    (~rem_sum_i[CSA_WIDTH-2] & ~rem_sum_i[CSA_WIDTH-3] & ~rem_carry_i[CSA_WIDTH-2] &  rem_carry_i[CSA_WIDTH-3]) |
    ( rem_sum_i[CSA_WIDTH-2] & ~rem_sum_i[CSA_WIDTH-3] &  rem_carry_i[CSA_WIDTH-2] &  rem_carry_i[CSA_WIDTH-3]) |
    ( rem_sum_i[CSA_WIDTH-2] &  rem_sum_i[CSA_WIDTH-3] & ~rem_carry_i[CSA_WIDTH-2] & ~rem_carry_i[CSA_WIDTH-3]) |
    (~rem_sum_i[CSA_WIDTH-2] &  rem_sum_i[CSA_WIDTH-3] &  rem_carry_i[CSA_WIDTH-2] & ~rem_carry_i[CSA_WIDTH-3]) |
    ( rem_sum_i[CSA_WIDTH-2] & ~rem_sum_i[CSA_WIDTH-3] & ~rem_carry_i[CSA_WIDTH-2] &  rem_carry_i[CSA_WIDTH-3]) |
    (~rem_sum_i[CSA_WIDTH-2] & ~rem_sum_i[CSA_WIDTH-3] &  rem_carry_i[CSA_WIDTH-2] &  rem_carry_i[CSA_WIDTH-3]);

  assign rem_carry_plus_d_o[CSA_WIDTH-2] =
    (~rem_sum_i[CSA_WIDTH-2] &  rem_sum_i[CSA_WIDTH-3] & ~rem_carry_i[CSA_WIDTH-2] & ~rem_carry_i[CSA_WIDTH-3]) |
    ( rem_sum_i[CSA_WIDTH-2] &  rem_sum_i[CSA_WIDTH-3] &  rem_carry_i[CSA_WIDTH-2] & ~rem_carry_i[CSA_WIDTH-3]) |
    (~rem_sum_i[CSA_WIDTH-2] & ~rem_sum_i[CSA_WIDTH-3] & ~rem_carry_i[CSA_WIDTH-2] &  rem_carry_i[CSA_WIDTH-3]) |
    ( rem_sum_i[CSA_WIDTH-2] & ~rem_sum_i[CSA_WIDTH-3] &  rem_carry_i[CSA_WIDTH-2] &  rem_carry_i[CSA_WIDTH-3]) |
    ( rem_sum_i[CSA_WIDTH-2] &  rem_sum_i[CSA_WIDTH-3] & ~rem_carry_i[CSA_WIDTH-2] & ~rem_carry_i[CSA_WIDTH-3]) |
    (~rem_sum_i[CSA_WIDTH-2] &  rem_sum_i[CSA_WIDTH-3] &  rem_carry_i[CSA_WIDTH-2] & ~rem_carry_i[CSA_WIDTH-3]) |
    ( rem_sum_i[CSA_WIDTH-2] & ~rem_sum_i[CSA_WIDTH-3] & ~rem_carry_i[CSA_WIDTH-2] &  rem_carry_i[CSA_WIDTH-3]) |
    (~rem_sum_i[CSA_WIDTH-2] & ~rem_sum_i[CSA_WIDTH-3] &  rem_carry_i[CSA_WIDTH-2] &  rem_carry_i[CSA_WIDTH-3]) |
    (                          ~rem_sum_i[CSA_WIDTH-3] &                             ~rem_carry_i[CSA_WIDTH-3]) |
    (                           rem_sum_i[CSA_WIDTH-3] &                              rem_carry_i[CSA_WIDTH-3]);

  assign rem_sum_plus_d_o[CSA_WIDTH-2] =
    (~rem_sum_i[CSA_WIDTH-2] & ~rem_sum_i[CSA_WIDTH-3] & ~rem_carry_i[CSA_WIDTH-2] & ~rem_carry_i[CSA_WIDTH-3]) |
    ( rem_sum_i[CSA_WIDTH-2] & ~rem_sum_i[CSA_WIDTH-3] &  rem_carry_i[CSA_WIDTH-2] & ~rem_carry_i[CSA_WIDTH-3]) |
    ( rem_sum_i[CSA_WIDTH-2] &  rem_sum_i[CSA_WIDTH-3] & ~rem_carry_i[CSA_WIDTH-2] &  rem_carry_i[CSA_WIDTH-3]) |
    (~rem_sum_i[CSA_WIDTH-2] &  rem_sum_i[CSA_WIDTH-3] &  rem_carry_i[CSA_WIDTH-2] &  rem_carry_i[CSA_WIDTH-3]) |
    ( rem_sum_i[CSA_WIDTH-2] &  rem_sum_i[CSA_WIDTH-3] & ~rem_carry_i[CSA_WIDTH-2] & ~rem_carry_i[CSA_WIDTH-3]) |
    (~rem_sum_i[CSA_WIDTH-2] &  rem_sum_i[CSA_WIDTH-3] &  rem_carry_i[CSA_WIDTH-2] & ~rem_carry_i[CSA_WIDTH-3]) |
    ( rem_sum_i[CSA_WIDTH-2] & ~rem_sum_i[CSA_WIDTH-3] & ~rem_carry_i[CSA_WIDTH-2] &  rem_carry_i[CSA_WIDTH-3]) |
    (~rem_sum_i[CSA_WIDTH-2] & ~rem_sum_i[CSA_WIDTH-3] &  rem_carry_i[CSA_WIDTH-2] &  rem_carry_i[CSA_WIDTH-3]);

  assign rem_sum_plus_d_o[CSA_WIDTH-3] = (~rem_sum_i[CSA_WIDTH-3] & ~rem_carry_i[CSA_WIDTH-3]) |
                                         ( rem_sum_i[CSA_WIDTH-3] &  rem_carry_i[CSA_WIDTH-3]);


endmodule


/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
