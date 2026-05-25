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
// Abstract : Neon Comparison Block
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Performs comparison of the input vector operands and swap them
// in order the greater to be the operand a

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_neon_vector_maxmin (
  // Inputs
  input wire    [1:0] neon_size_sel_f4_i,       // Size of vector elements (32,16,8)
  input wire          neon_unsigned_op_f4_i,    // Signed or unsigned comparison
  input wire    [2:0] neon_sat_op_sel_f4_i,
  input wire    [7:0] neon_sat_dtect_res_f4_i,
  input wire   [63:0] alu_res_f4_i,
  // Outputs
  output wire  [31:0] neon_vector_maxmin_f4_o
);

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire        min_op;
  wire        op_8bit;
  wire        op_16bit;
  wire        op_32bit;
  wire  [3:0] sel;
  wire  [1:0] sel8_s2;
  wire        sel8_s3;
  wire        sel16_s2;
  wire  [7:0] opa_8bit_stage1;
  wire  [7:0] opb_8bit_stage1;
  wire  [7:0] opc_8bit_stage1;
  wire  [7:0] opd_8bit_stage1;
  wire  [7:0] opa_8bit_stage2;
  wire  [7:0] opb_8bit_stage2;
  wire [15:0] opa_16bit;
  wire [15:0] opb_16bit;
  wire  [7:0] res_8bit;
  wire [15:0] res_16bit;
  wire [31:0] res_32bit;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  function cmp8(input [7:0] b, input [7:0] a, input unsigned_op);
    reg lsb_cmp;
    reg msb_gt;

    begin
      lsb_cmp = b[6:0] > a[6:0];
      msb_gt  = unsigned_op ? (b[7] & ~a[7]) : (~b[7] & a[7]);
      cmp8 = msb_gt | ((b[7] == a[7]) & lsb_cmp);
    end
  endfunction

  function cmp16(input [15:0] b, input [15:0] a, input unsigned_op);
    reg lsb_cmp;
    reg msb_gt;

    begin
      lsb_cmp = b[14:0] > a[14:0];
      msb_gt  = unsigned_op ? (b[15] & ~a[15]) : (~b[15] & a[15]);
      cmp16 = msb_gt | ((b[15] == a[15]) & lsb_cmp);
    end
  endfunction

  // Decode control signals

  assign min_op   = (neon_sat_op_sel_f4_i == `CA53_NEON_SAT_MINV);
  assign op_8bit  = (neon_size_sel_f4_i == 2'b00);
  assign op_16bit = (neon_size_sel_f4_i == 2'b01);
  assign op_32bit = (neon_size_sel_f4_i == 2'b10);

  assign sel[0] = (neon_unsigned_op_f4_i ? neon_sat_dtect_res_f4_i[0] : neon_sat_dtect_res_f4_i[1]) ^ min_op;
  assign sel[1] = (neon_unsigned_op_f4_i ? neon_sat_dtect_res_f4_i[2] : neon_sat_dtect_res_f4_i[3]) ^ min_op;
  assign sel[2] = (neon_unsigned_op_f4_i ? neon_sat_dtect_res_f4_i[4] : neon_sat_dtect_res_f4_i[5]) ^ min_op;
  assign sel[3] = (neon_unsigned_op_f4_i ? neon_sat_dtect_res_f4_i[6] : neon_sat_dtect_res_f4_i[7]) ^ min_op;

  // 8-bit operation
  assign opa_8bit_stage1 = ({8{op_8bit & sel[0]}} & alu_res_f4_i[39:32]) | ({8{op_8bit & ~sel[0]}} & alu_res_f4_i[ 7: 0]);
  assign opb_8bit_stage1 = ({8{op_8bit & sel[1]}} & alu_res_f4_i[47:40]) | ({8{op_8bit & ~sel[1]}} & alu_res_f4_i[15: 8]);
  assign opc_8bit_stage1 = ({8{op_8bit & sel[2]}} & alu_res_f4_i[55:48]) | ({8{op_8bit & ~sel[2]}} & alu_res_f4_i[23:16]);
  assign opd_8bit_stage1 = ({8{op_8bit & sel[3]}} & alu_res_f4_i[63:56]) | ({8{op_8bit & ~sel[3]}} & alu_res_f4_i[31:24]);

  assign sel8_s2[0] = cmp8(opb_8bit_stage1, opa_8bit_stage1, neon_unsigned_op_f4_i) ^ min_op;
  assign sel8_s2[1] = cmp8(opd_8bit_stage1, opc_8bit_stage1, neon_unsigned_op_f4_i) ^ min_op;

  assign opa_8bit_stage2 = sel8_s2[0] ? opb_8bit_stage1 : opa_8bit_stage1;
  assign opb_8bit_stage2 = sel8_s2[1] ? opd_8bit_stage1 : opc_8bit_stage1;

  assign sel8_s3 = cmp8(opb_8bit_stage2, opa_8bit_stage2, neon_unsigned_op_f4_i) ^ min_op;

  assign res_8bit = sel8_s3 ? opb_8bit_stage2 : opa_8bit_stage2;

  // 16-bit operation
  assign opa_16bit = ({16{op_16bit & sel[0]}} & alu_res_f4_i[47:32]) | ({16{op_16bit & ~sel[0]}} & alu_res_f4_i[15: 0]);
  assign opb_16bit = ({16{op_16bit & sel[1]}} & alu_res_f4_i[63:48]) | ({16{op_16bit & ~sel[1]}} & alu_res_f4_i[31:16]);

  assign sel16_s2 = cmp16(opb_16bit, opa_16bit, neon_unsigned_op_f4_i) ^ min_op;

  assign res_16bit = sel16_s2 ? opb_16bit : opa_16bit;

  // 32-bit operation
  assign res_32bit = ({32{op_32bit & sel[0]}} & alu_res_f4_i[63:32]) | ({32{op_32bit & ~sel[0]}} & alu_res_f4_i[31: 0]);

  // Combine results
  assign neon_vector_maxmin_f4_o = res_32bit | { {16{1'b0}}, res_16bit} | { {24{1'b0}}, res_8bit};

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
