//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2014 ARM Limited.
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
// Abstract : Neon 8-bit polynomial multiplier
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

 // Overview
 // --------
 // This module performs polynomial multiplication

 module ca53dpu_neon_polymul(
  // Inputs
  input  wire  [63:0] neon_opa_f3_i,         // Vn operand
  input  wire  [63:0] neon_opb_f3_i,         // Vm operand
  // Outputs
  output wire  [95:0] neon_polymul_res_f3_o  // Final result
 );

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [15:0] polymul_res0;
  wire [15:0] polymul_res1;
  wire [15:0] polymul_res2;
  wire [15:0] polymul_res3;
  wire  [7:0] polymul_res4;
  wire  [7:0] polymul_res5;
  wire  [7:0] polymul_res6;
  wire  [7:0] polymul_res7;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  function [15:0] polynomial_long;
    input [7:0]  opa, opb;
    reg  [15:0] and7, and6, and5, and4, and3, and2, and1, and0;
    begin
      and7 = {16{opa[7]}} & {1'b0, opb[7:0], 7'b0000000};
      and6 = {16{opa[6]}} & {2'b00, opb[7:0], 6'b000000};
      and5 = {16{opa[5]}} & {3'b000, opb[7:0], 5'b00000};
      and4 = {16{opa[4]}} & {4'b0000, opb[7:0], 4'b0000};
      and3 = {16{opa[3]}} & {5'b00000, opb[7:0], 3'b000};
      and2 = {16{opa[2]}} & {6'b000000, opb[7:0], 2'b00};
      and1 = {16{opa[1]}} & {7'b0000000, opb[7:0], 1'b0};
      and0 = {16{opa[0]}} & {8'b00000000, opb[7:0]};

      polynomial_long = and7 ^ and6 ^ and5 ^ and4 ^ and3 ^ and2 ^ and1 ^ and0;
    end
  endfunction

  function [7:0] polynomial;
    input [7:0]  opa, opb;
    reg  [7:0] and7, and6, and5, and4, and3, and2, and1, and0;
    begin
      and7 = {8{opa[7]}} & {opb[0],   7'b0000000};
      and6 = {8{opa[6]}} & {opb[1:0], 6'b000000};
      and5 = {8{opa[5]}} & {opb[2:0], 5'b00000};
      and4 = {8{opa[4]}} & {opb[3:0], 4'b0000};
      and3 = {8{opa[3]}} & {opb[4:0], 3'b000};
      and2 = {8{opa[2]}} & {opb[5:0], 2'b00};
      and1 = {8{opa[1]}} & {opb[6:0], 1'b0};
      and0 = {8{opa[0]}} &  opb[7:0];

      polynomial = and7 ^ and6 ^ and5 ^ and4 ^ and3 ^ and2 ^ and1 ^ and0;
    end
  endfunction

  assign polymul_res0 = polynomial_long(neon_opa_f3_i[ 7: 0], neon_opb_f3_i[ 7: 0]);
  assign polymul_res1 = polynomial_long(neon_opa_f3_i[15: 8], neon_opb_f3_i[15: 8]);
  assign polymul_res2 = polynomial_long(neon_opa_f3_i[23:16], neon_opb_f3_i[23:16]);
  assign polymul_res3 = polynomial_long(neon_opa_f3_i[31:24], neon_opb_f3_i[31:24]);

  assign polymul_res4 = polynomial(neon_opa_f3_i[39:32], neon_opb_f3_i[39:32]);
  assign polymul_res5 = polynomial(neon_opa_f3_i[47:40], neon_opb_f3_i[47:40]);
  assign polymul_res6 = polynomial(neon_opa_f3_i[55:48], neon_opb_f3_i[55:48]);
  assign polymul_res7 = polynomial(neon_opa_f3_i[63:56], neon_opb_f3_i[63:56]);

  assign neon_polymul_res_f3_o = {polymul_res7, polymul_res6, polymul_res5, polymul_res4,
                                  polymul_res3, polymul_res2, polymul_res1, polymul_res0};

 endmodule // ca53dpu_neon_polymul

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
