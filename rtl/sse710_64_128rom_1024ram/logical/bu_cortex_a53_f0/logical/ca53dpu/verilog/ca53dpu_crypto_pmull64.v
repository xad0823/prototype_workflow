//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract: 64->128-bit polynomial multiply
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_crypto_pmull64 (
  input  wire  [63:0] opa_i,
  input  wire  [63:0] opb_i,

  output reg  [126:0] pmull64_res_o
);

  always @* begin : pmull64_loop
    integer i;
    integer j;
    reg [126:0] tmp_res;

    tmp_res = {127{1'b0}};

    for (i = 0; i < 64; i = i + 1) begin
      for (j = 0; j < 64; j = j + 1) begin
        tmp_res[i + j] = tmp_res[i + j] ^ (opa_i[i] & opb_i[j]);
      end
    end

    pmull64_res_o = tmp_res;
  end

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
