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
// Abstract: Datapath for SHA1C, SHA1P and SHA1M
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_crypto_sha1cpm (
  input  wire [`CA53_CRYPTO_OP_W-1:0] crypto_op_i,
  input  wire                 [159:0] hash_data_i,
  input  wire                  [31:0] schedule_data_i,

  output wire                 [159:0] sha1cpm_res_o
);

  // -----------------------------
  // Reg declaration
  // -----------------------------

  reg  [31: 0] t;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [31: 0] a;
  wire [31: 0] a_prime;
  wire [31: 0] b;
  wire [31: 0] b_prime;
  wire [31: 0] c;
  wire [31: 0] c_prime;
  wire [31: 0] d;
  wire [31: 0] d_prime;
  wire [31: 0] e;
  wire [31: 0] e_prime;

  // -----------------------------
  // Main code
  // -----------------------------

  assign a = hash_data_i[ 31:  0];
  assign b = hash_data_i[ 63: 32];
  assign c = hash_data_i[ 95: 64];
  assign d = hash_data_i[127: 96];
  assign e = hash_data_i[159:128];

  // First round
  always @*
    case (crypto_op_i)
      `CA53_CRYPTO_OP_SHA1C: t = (b & c) | (~b & d);
      `CA53_CRYPTO_OP_SHA1P: t = b ^ c ^ d;
      `CA53_CRYPTO_OP_SHA1M: t = (b & c) | (c & d) | (d & b);
      default:             t = {32{1'bx}};
    endcase

  assign a_prime = e + {a[26:0], a[31:27]} + t + schedule_data_i;
  assign b_prime = a;
  assign c_prime = {b[1:0], b[31:2]};
  assign d_prime = c;
  assign e_prime = d;
  assign sha1cpm_res_o = {e_prime, d_prime, c_prime, b_prime, a_prime};

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
