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
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Masking/Selection Unit for ca53dpu.
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_alu_masksel (
  // Inputs
  input  wire  [63:0] alu_data_a_ex2_i,
  input  wire  [63:0] alu_data_b_ex2_i,
  input  wire  [63:0] alu_mask_data_ex2_i,
  input  wire         alu_ex2_sel_valid_i,
  input  wire   [3:0] geflags_wr_i,
  input  wire         alu_ex2_sign_replicate_i,
  input  wire   [5:0] alu_mskgen_ex2_i,
  // Outputs
  output wire  [63:0] msu_out_ex2_o
  );

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [63:0] mask;
  wire [63:0] operand_a;
  wire [63:0] alu_ex2_data_b_smask;

  // ------------------------------------------------------
  // Sign bit extract unit
  // ------------------------------------------------------

  // This block is used to control sign extension from an arbitrary bit position.
  // It will return the value of bit[n] in the word given the value of n.
  ca53dpu_alu_sbitx u_alu_sbitx (
    // Inputs
    .alu_mskgen_ex2_i       (alu_mskgen_ex2_i[5:0]),
    .alu_data_b_ex2_i       (alu_data_b_ex2_i[63:0]),
    // Outputs
    .alu_ex2_data_b_smask_o (alu_ex2_data_b_smask)
  );

  assign operand_a = alu_ex2_sign_replicate_i ? alu_ex2_data_b_smask : alu_data_a_ex2_i;

  assign mask = alu_ex2_sel_valid_i ? {32'h0000_0000,
                                       {8{~geflags_wr_i[3]}}, {8{~geflags_wr_i[2]}},
                                       {8{~geflags_wr_i[1]}}, {8{~geflags_wr_i[0]}}} : alu_mask_data_ex2_i;

  assign msu_out_ex2_o = (operand_a & ~mask) | (alu_data_b_ex2_i & mask);

endmodule // ca53dpu_alu_masksel

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
