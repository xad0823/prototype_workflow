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
// Abstract: Datapath for SHA256SU1
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_crypto_sha256su1 (
  input  wire  [63:0] op1_data_i,
  input  wire  [63:0] t0_data_i,
  input  wire  [63:0] t1_data_i,

  output wire  [63:0] sha256su1_res_o
);

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [31:0] elt0_step0;
  wire [31:0] elt0_step1;
  wire [31:0] elt1_step0;
  wire [31:0] elt1_step1;

  // -----------------------------
  // Main code
  // -----------------------------

  assign elt0_step0 = t1_data_i[31: 0];
  assign elt1_step0 = t1_data_i[63:32];

  assign elt0_step1 = {elt0_step0[18:0], elt0_step0[31:19]} ^ {elt0_step0[16:0], elt0_step0[31:17]} ^ {10'h000, elt0_step0[31:10]};
  assign elt1_step1 = {elt1_step0[18:0], elt1_step0[31:19]} ^ {elt1_step0[16:0], elt1_step0[31:17]} ^ {10'h000, elt1_step0[31:10]};

  assign sha256su1_res_o[31: 0] = elt0_step1 + t0_data_i[31: 0] + op1_data_i[31: 0];
  assign sha256su1_res_o[63:32] = elt1_step1 + t0_data_i[63:32] + op1_data_i[63:32];

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
