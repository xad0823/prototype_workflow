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
// Abstract : Neon Permutation Block
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Performs permutation of the input vector operands

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_neon_permutation (
  // Inputs
  input wire   [63:0] frc_opa_f2_i,         // Vn or Vd operand
  input wire   [63:0] frc_opb_f2_i,         // Vm operand
  input wire   [63:0] neon_frc_opc_f2_i,    // Selects the bytes from the input operands to create a new vector
  // Outputs
  output wire  [63:0] neon_perm_opa_f2_o,   // Operand a
  output wire  [63:0] neon_perm_opb_f2_o    // Operand b
);

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  function [7:0] byte_select;
    // Selects a byte from the two input operands
    input [63:0] opa, opb;
    input [3:0] mux_ctl;
    begin
      byte_select = ({8{mux_ctl == 4'hf}} & opb[63:56]) |
                    ({8{mux_ctl == 4'he}} & opb[55:48]) |
                    ({8{mux_ctl == 4'hd}} & opb[47:40]) |
                    ({8{mux_ctl == 4'hc}} & opb[39:32]) |
                    ({8{mux_ctl == 4'hb}} & opb[31:24]) |
                    ({8{mux_ctl == 4'ha}} & opb[23:16]) |
                    ({8{mux_ctl == 4'h9}} & opb[15: 8]) |
                    ({8{mux_ctl == 4'h8}} & opb[ 7: 0]) |
                    ({8{mux_ctl == 4'h7}} & opa[63:56]) |
                    ({8{mux_ctl == 4'h6}} & opa[55:48]) |
                    ({8{mux_ctl == 4'h5}} & opa[47:40]) |
                    ({8{mux_ctl == 4'h4}} & opa[39:32]) |
                    ({8{mux_ctl == 4'h3}} & opa[31:24]) |
                    ({8{mux_ctl == 4'h2}} & opa[23:16]) |
                    ({8{mux_ctl == 4'h1}} & opa[15: 8]) |
                    ({8{mux_ctl == 4'h0}} & opa[ 7: 0]);
    end
  endfunction

  assign neon_perm_opb_f2_o[63:56]  = byte_select(frc_opa_f2_i, frc_opb_f2_i, neon_frc_opc_f2_i[63:60]);
  assign neon_perm_opb_f2_o[55:48]  = byte_select(frc_opa_f2_i, frc_opb_f2_i, neon_frc_opc_f2_i[55:52]);
  assign neon_perm_opb_f2_o[47:40]  = byte_select(frc_opa_f2_i, frc_opb_f2_i, neon_frc_opc_f2_i[47:44]);
  assign neon_perm_opb_f2_o[39:32]  = byte_select(frc_opa_f2_i, frc_opb_f2_i, neon_frc_opc_f2_i[39:36]);
  assign neon_perm_opb_f2_o[31:24]  = byte_select(frc_opa_f2_i, frc_opb_f2_i, neon_frc_opc_f2_i[31:28]);
  assign neon_perm_opb_f2_o[23:16]  = byte_select(frc_opa_f2_i, frc_opb_f2_i, neon_frc_opc_f2_i[23:20]);
  assign neon_perm_opb_f2_o[15:8]   = byte_select(frc_opa_f2_i, frc_opb_f2_i, neon_frc_opc_f2_i[15:12]);
  assign neon_perm_opb_f2_o[7:0]    = byte_select(frc_opa_f2_i, frc_opb_f2_i, neon_frc_opc_f2_i[ 7: 4]);

  assign neon_perm_opa_f2_o[63:56]  = byte_select(frc_opa_f2_i, frc_opb_f2_i, neon_frc_opc_f2_i[59:56]);
  assign neon_perm_opa_f2_o[55:48]  = byte_select(frc_opa_f2_i, frc_opb_f2_i, neon_frc_opc_f2_i[51:48]);
  assign neon_perm_opa_f2_o[47:40]  = byte_select(frc_opa_f2_i, frc_opb_f2_i, neon_frc_opc_f2_i[43:40]);
  assign neon_perm_opa_f2_o[39:32]  = byte_select(frc_opa_f2_i, frc_opb_f2_i, neon_frc_opc_f2_i[35:32]);
  assign neon_perm_opa_f2_o[31:24]  = byte_select(frc_opa_f2_i, frc_opb_f2_i, neon_frc_opc_f2_i[27:24]);
  assign neon_perm_opa_f2_o[23:16]  = byte_select(frc_opa_f2_i, frc_opb_f2_i, neon_frc_opc_f2_i[19:16]);
  assign neon_perm_opa_f2_o[15:8]   = byte_select(frc_opa_f2_i, frc_opb_f2_i, neon_frc_opc_f2_i[11: 8]);
  assign neon_perm_opa_f2_o[7:0]    = byte_select(frc_opa_f2_i, frc_opb_f2_i, neon_frc_opc_f2_i[ 3: 0]);

endmodule // ca53dpu_neon_permutation

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/






