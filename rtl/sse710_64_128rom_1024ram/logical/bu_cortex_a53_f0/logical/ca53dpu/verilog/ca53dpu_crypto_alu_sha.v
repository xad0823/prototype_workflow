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
// Abstract: Datapath for initial step of SHA256SU0
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_crypto_alu_sha #(parameter IS_PIPE0 = 1) (
  input  wire  [63:0] fad_a_data_f2_i,
  input  wire  [63:0] fad_b_data_f2_i,
  input  wire  [63:0] fad_c_data_f2_i,

  output wire  [63:0] sha1h_res_f2_o,
  output wire  [63:0] sha1su0_opa_f2_o,
  output wire  [63:0] sha1su0_opb_f2_o,
  output wire  [63:0] sha256su0_opa_f2_o,
  output wire  [63:0] sha256su0_opb_f2_o
);

  // -----------------------------
  // Main code
  // -----------------------------

  generate if (IS_PIPE0) begin : g_sha1h_low
    assign sha1h_res_f2_o = { {32{1'b0}}, fad_a_data_f2_i[1:0], fad_a_data_f2_i[31:2]};
  end else begin : g_sha1h_high
    assign sha1h_res_f2_o = {64{1'b0}};
  end endgenerate

  assign sha1su0_opa_f2_o = fad_a_data_f2_i;
  assign sha1su0_opb_f2_o = fad_b_data_f2_i ^ fad_c_data_f2_i;

  assign sha256su0_opa_f2_o[31: 0] = {fad_a_data_f2_i[49:32], fad_a_data_f2_i[63:50]} ^ {fad_a_data_f2_i[38:32], fad_a_data_f2_i[63:39]} ^ {3'b000, fad_a_data_f2_i[63:35]};
  assign sha256su0_opa_f2_o[63:32] = {fad_b_data_f2_i[17: 0], fad_b_data_f2_i[31:18]} ^ {fad_b_data_f2_i[ 6: 0], fad_b_data_f2_i[31: 7]} ^ {3'b000, fad_b_data_f2_i[31: 3]};

  assign sha256su0_opb_f2_o = fad_a_data_f2_i;

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
