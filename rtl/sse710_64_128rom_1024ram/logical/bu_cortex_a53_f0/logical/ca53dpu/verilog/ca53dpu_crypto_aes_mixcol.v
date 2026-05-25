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
// Abstract: AES MixColumns/InvMixColumns step
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_crypto_aes_mixcol (
  input  wire         aes_invmixcols_f3_i,
  input  wire  [31:0] crypto_a_data_f3_i,
  output wire  [31:0] aes_mixcol_data_f3_o
);

  wire [10:0] raw_mixcol_com [3:0];
  wire [10:0] raw_mixcol_inv [3:0];
  

  function [10:0] gf_mul_8x4;
    input [3:0] a;
    input [7:0] b;

    gf_mul_8x4 = {        ({8{a[3]}} & b), 3'b000} ^
                 {1'b0,   ({8{a[2]}} & b),  2'b00} ^
                 {2'b00,  ({8{a[1]}} & b),   1'b0} ^
                 {3'b000, ({8{a[0]}} & b)        };
  endfunction

  function [7:0] gf_reduce_11;
    input [10:0] a;

    gf_reduce_11 = a[7:0]
                   ^ ({8{a[ 8]}} & 8'h1b)
                   ^ ({8{a[ 9]}} & 8'h36)
                   ^ ({8{a[10]}} & 8'h6c);
  endfunction

  assign raw_mixcol_com[3] = gf_mul_8x4(4'd3, crypto_a_data_f3_i[ 7: 0]) ^
                             gf_mul_8x4(4'd1, crypto_a_data_f3_i[15: 8]) ^
                             gf_mul_8x4(4'd1, crypto_a_data_f3_i[23:16]) ^
                             gf_mul_8x4(4'd2, crypto_a_data_f3_i[31:24]);

  assign raw_mixcol_com[2] = gf_mul_8x4(4'd1, crypto_a_data_f3_i[ 7: 0]) ^
                             gf_mul_8x4(4'd1, crypto_a_data_f3_i[15: 8]) ^
                             gf_mul_8x4(4'd2, crypto_a_data_f3_i[23:16]) ^
                             gf_mul_8x4(4'd3, crypto_a_data_f3_i[31:24]);

  assign raw_mixcol_com[1] = gf_mul_8x4(4'd1, crypto_a_data_f3_i[ 7: 0]) ^
                             gf_mul_8x4(4'd2, crypto_a_data_f3_i[15: 8]) ^
                             gf_mul_8x4(4'd3, crypto_a_data_f3_i[23:16]) ^
                             gf_mul_8x4(4'd1, crypto_a_data_f3_i[31:24]);

  assign raw_mixcol_com[0] = gf_mul_8x4(4'd2, crypto_a_data_f3_i[ 7: 0]) ^
                             gf_mul_8x4(4'd3, crypto_a_data_f3_i[15: 8]) ^
                             gf_mul_8x4(4'd1, crypto_a_data_f3_i[23:16]) ^
                             gf_mul_8x4(4'd1, crypto_a_data_f3_i[31:24]);

  assign raw_mixcol_inv[3] = gf_mul_8x4(4'd8,  crypto_a_data_f3_i[ 7: 0]) ^
                             gf_mul_8x4(4'd12, crypto_a_data_f3_i[15: 8]) ^
                             gf_mul_8x4(4'd8,  crypto_a_data_f3_i[23:16]) ^
                             gf_mul_8x4(4'd12, crypto_a_data_f3_i[31:24]);

  assign raw_mixcol_inv[2] = gf_mul_8x4(4'd12, crypto_a_data_f3_i[ 7: 0]) ^
                             gf_mul_8x4(4'd8,  crypto_a_data_f3_i[15: 8]) ^
                             gf_mul_8x4(4'd12, crypto_a_data_f3_i[23:16]) ^
                             gf_mul_8x4(4'd8,  crypto_a_data_f3_i[31:24]);

  assign raw_mixcol_inv[1] = gf_mul_8x4(4'd8,  crypto_a_data_f3_i[ 7: 0]) ^
                             gf_mul_8x4(4'd12, crypto_a_data_f3_i[15: 8]) ^
                             gf_mul_8x4(4'd8,  crypto_a_data_f3_i[23:16]) ^
                             gf_mul_8x4(4'd12, crypto_a_data_f3_i[31:24]);

  assign raw_mixcol_inv[0] = gf_mul_8x4(4'd12, crypto_a_data_f3_i[ 7: 0]) ^
                             gf_mul_8x4(4'd8,  crypto_a_data_f3_i[15: 8]) ^
                             gf_mul_8x4(4'd12, crypto_a_data_f3_i[23:16]) ^
                             gf_mul_8x4(4'd8,  crypto_a_data_f3_i[31:24]);

  assign aes_mixcol_data_f3_o[ 7: 0] = gf_reduce_11(raw_mixcol_com[0] ^ ({11{aes_invmixcols_f3_i}} & raw_mixcol_inv[0]));
  assign aes_mixcol_data_f3_o[15: 8] = gf_reduce_11(raw_mixcol_com[1] ^ ({11{aes_invmixcols_f3_i}} & raw_mixcol_inv[1]));
  assign aes_mixcol_data_f3_o[23:16] = gf_reduce_11(raw_mixcol_com[2] ^ ({11{aes_invmixcols_f3_i}} & raw_mixcol_inv[2]));
  assign aes_mixcol_data_f3_o[31:24] = gf_reduce_11(raw_mixcol_com[3] ^ ({11{aes_invmixcols_f3_i}} & raw_mixcol_inv[3]));

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
