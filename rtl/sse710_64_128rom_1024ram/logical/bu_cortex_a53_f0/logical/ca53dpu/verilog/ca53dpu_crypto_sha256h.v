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
// Abstract: Datapath for SHA256H and SHA256H2
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_crypto_sha256h (
  input  wire [255:0] hash_data_i,
  input  wire  [31:0] schedule_data_i,

  output wire [255:0] sha256h_res_o
);

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
  wire [31: 0] f;
  wire [31: 0] f_prime;
  wire [31: 0] g;
  wire [31: 0] g_prime;
  wire [31: 0] h;
  wire [31: 0] h_prime;
  wire [31: 0] chs;
  wire [31: 0] maj;
  wire [31: 0] t;
  wire [31: 0] s0;
  wire [31: 0] s1;

  // -----------------------------
  // Main code
  // -----------------------------

  assign a = hash_data_i[ 31:  0];
  assign b = hash_data_i[ 63: 32];
  assign c = hash_data_i[ 95: 64];
  assign d = hash_data_i[127: 96];
  assign e = hash_data_i[159:128];
  assign f = hash_data_i[191:160];
  assign g = hash_data_i[223:192];
  assign h = hash_data_i[255:224];

  assign chs = (e & f) | (~e & g);
  assign maj = (a & b) | (b & c) | (c & a);
  assign s0  = {a[1:0], a[31:2]} ^ {a[12:0], a[31:13]} ^ {a[21:0], a[31:22]};
  assign s1  = {e[5:0], e[31:6]} ^ {e[10:0], e[31:11]} ^ {e[24:0], e[31:25]};

  assign t = s1 + chs + schedule_data_i + h;

  assign a_prime = t + s0 + maj;
  assign b_prime = a;
  assign c_prime = b;
  assign d_prime = c;
  assign e_prime = d + t;
  assign f_prime = e;
  assign g_prime = f;
  assign h_prime = g;

  assign sha256h_res_o = {h_prime, g_prime, f_prime, e_prime, d_prime, c_prime, b_prime, a_prime};

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
