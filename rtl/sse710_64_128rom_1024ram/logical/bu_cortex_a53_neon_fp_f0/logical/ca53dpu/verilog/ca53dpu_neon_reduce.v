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
// Abstract : Neon reduction add block
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Sums all the elements of the input vector, producing a result in carry-save form

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_neon_reduce (
  // Inputs
  input  wire         neon_reduce_f2_i,          // Control signal indicating reduction operation
  input  wire         neon_reduce_size_sel_f2_i, // Whether this is a widening operation
  input  wire   [1:0] neon_size_sel_f2_i,        // Size of vector elements (32,16,8)
  input  wire         neon_unsigned_op_f2_i,     // Signed or unsigned comparison
  input  wire  [63:0] fad_a_data_f2_i,           // Lower 64 bits of vector
  input  wire  [63:0] fad_b_data_f2_i,           // Upper 64 bits of vector
  // Outputs
  output reg   [63:0] neon_reduce_opa_f2_o,      // Operand a
  output reg   [63:0] neon_reduce_opb_f2_o       // Operand b
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg  [32:0] stage0_op0;
  reg  [32:0] stage0_op1;
  reg  [32:0] stage0_op2;
  reg  [32:0] stage0_op3;
  reg  [16:0] stage0_op4;
  reg  [16:0] stage0_op5;
  reg  [16:0] stage0_op6;
  reg  [16:0] stage0_op7;
  reg   [8:0] stage0_op8;
  reg   [8:0] stage0_op9;
  reg   [8:0] stage0_op10;
  reg   [8:0] stage0_op11;
  reg   [8:0] stage0_op12;
  reg   [8:0] stage0_op13;
  reg   [8:0] stage0_op14;
  reg   [8:0] stage0_op15;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire  [1:0] mod_neon_size_sel_f2;
  wire [32:0] stage1_op0;
  wire [33:1] stage1_op1;
  wire [16:0] stage1_op2;
  wire [17:1] stage1_op3;
  wire  [8:0] stage1_op4;
  wire  [9:1] stage1_op5;
  wire  [8:0] stage1_op6;
  wire  [9:1] stage1_op7;
  wire [33:0] stage2_op0;
  wire [34:1] stage2_op1;
  wire [17:0] stage2_op2;
  wire [18:1] stage2_op3;
  wire  [9:0] stage2_op4;
  wire [10:1] stage2_op5;
  wire  [9:0] stage2_op6;
  wire [10:1] stage2_op7;
  wire [18:0] stage3_op0;
  wire [18:1] stage3_op1;
  wire [10:0] stage3_op2;
  wire [11:1] stage3_op3;
  wire [18:0] stage4_op0;
  wire [19:1] stage4_op1;
  wire [11:0] stage4_op2;
  wire [12:1] stage4_op3;
  wire [12:0] stage5_op0;
  wire [13:1] stage5_op1;
  wire [13:0] stage6_op0;
  wire [14:1] stage6_op1;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  assign mod_neon_size_sel_f2 = neon_reduce_size_sel_f2_i ? neon_size_sel_f2_i - 1'b1 : neon_size_sel_f2_i;

  // Generate inputs to CSA tree

  always @*
    case ({neon_reduce_f2_i, mod_neon_size_sel_f2})
      3'b1_00: begin
        stage0_op0  = { {21{1'b0}}, {4{~neon_unsigned_op_f2_i & fad_a_data_f2_i[ 7]}}, fad_a_data_f2_i[ 7: 0]};
        stage0_op1  = { {21{1'b0}}, {4{~neon_unsigned_op_f2_i & fad_a_data_f2_i[39]}}, fad_a_data_f2_i[39:32]};
        stage0_op2  = { {21{1'b0}}, {4{~neon_unsigned_op_f2_i & fad_b_data_f2_i[ 7]}}, fad_b_data_f2_i[ 7: 0]};
        stage0_op3  = { {21{1'b0}}, {4{~neon_unsigned_op_f2_i & fad_b_data_f2_i[39]}}, fad_b_data_f2_i[39:32]};
        stage0_op4  = { { 5{1'b0}}, {4{~neon_unsigned_op_f2_i & fad_a_data_f2_i[23]}}, fad_a_data_f2_i[23:16]};
        stage0_op5  = { { 5{1'b0}}, {4{~neon_unsigned_op_f2_i & fad_a_data_f2_i[55]}}, fad_a_data_f2_i[55:48]};
        stage0_op6  = { { 5{1'b0}}, {4{~neon_unsigned_op_f2_i & fad_b_data_f2_i[23]}}, fad_b_data_f2_i[23:16]};
        stage0_op7  = { { 5{1'b0}}, {4{~neon_unsigned_op_f2_i & fad_b_data_f2_i[55]}}, fad_b_data_f2_i[55:48]};
        stage0_op8  = {                ~neon_unsigned_op_f2_i & fad_a_data_f2_i[15],   fad_a_data_f2_i[15: 8]};
        stage0_op9  = {                ~neon_unsigned_op_f2_i & fad_a_data_f2_i[31],   fad_a_data_f2_i[31:24]};
        stage0_op10 = {                ~neon_unsigned_op_f2_i & fad_a_data_f2_i[47],   fad_a_data_f2_i[47:40]};
        stage0_op11 = {                ~neon_unsigned_op_f2_i & fad_a_data_f2_i[63],   fad_a_data_f2_i[63:56]};
        stage0_op12 = {                ~neon_unsigned_op_f2_i & fad_b_data_f2_i[15],   fad_b_data_f2_i[15: 8]};
        stage0_op13 = {                ~neon_unsigned_op_f2_i & fad_b_data_f2_i[31],   fad_b_data_f2_i[31:24]};
        stage0_op14 = {                ~neon_unsigned_op_f2_i & fad_b_data_f2_i[47],   fad_b_data_f2_i[47:40]};
        stage0_op15 = {                ~neon_unsigned_op_f2_i & fad_b_data_f2_i[63],   fad_b_data_f2_i[63:56]};
      end
      3'b1_01: begin
        stage0_op0  = { {14{1'b0}}, {3{~neon_unsigned_op_f2_i & fad_a_data_f2_i[15]}}, fad_a_data_f2_i[15: 0]};
        stage0_op1  = { {14{1'b0}}, {3{~neon_unsigned_op_f2_i & fad_a_data_f2_i[47]}}, fad_a_data_f2_i[47:32]};
        stage0_op2  = { {14{1'b0}}, {3{~neon_unsigned_op_f2_i & fad_b_data_f2_i[15]}}, fad_b_data_f2_i[15: 0]};
        stage0_op3  = { {14{1'b0}}, {3{~neon_unsigned_op_f2_i & fad_b_data_f2_i[47]}}, fad_b_data_f2_i[47:32]};
        stage0_op4  = {                ~neon_unsigned_op_f2_i & fad_a_data_f2_i[31],   fad_a_data_f2_i[31:16]};
        stage0_op5  = {                ~neon_unsigned_op_f2_i & fad_a_data_f2_i[63],   fad_a_data_f2_i[63:48]};
        stage0_op6  = {                ~neon_unsigned_op_f2_i & fad_b_data_f2_i[31],   fad_b_data_f2_i[31:16]};
        stage0_op7  = {                ~neon_unsigned_op_f2_i & fad_b_data_f2_i[63],   fad_b_data_f2_i[63:48]};

        stage0_op8  = { 9{1'b0}};
        stage0_op9  = { 9{1'b0}};
        stage0_op10 = { 9{1'b0}};
        stage0_op11 = { 9{1'b0}};
        stage0_op12 = { 9{1'b0}};
        stage0_op13 = { 9{1'b0}};
        stage0_op14 = { 9{1'b0}};
        stage0_op15 = { 9{1'b0}};
      end
      3'b1_10: begin
        stage0_op0  = {                ~neon_unsigned_op_f2_i & fad_a_data_f2_i[31],   fad_a_data_f2_i[31: 0]};
        stage0_op1  = {                ~neon_unsigned_op_f2_i & fad_a_data_f2_i[63],   fad_a_data_f2_i[63:32]};
        stage0_op2  = {                ~neon_unsigned_op_f2_i & fad_b_data_f2_i[31],   fad_b_data_f2_i[31: 0]};
        stage0_op3  = {                ~neon_unsigned_op_f2_i & fad_b_data_f2_i[63],   fad_b_data_f2_i[63:32]};

        stage0_op4  = {17{1'b0}};
        stage0_op5  = {17{1'b0}};
        stage0_op6  = {17{1'b0}};
        stage0_op7  = {17{1'b0}};
        stage0_op8  = {9{1'b0}};
        stage0_op9  = {9{1'b0}};
        stage0_op10 = {9{1'b0}};
        stage0_op11 = {9{1'b0}};
        stage0_op12 = {9{1'b0}};
        stage0_op13 = {9{1'b0}};
        stage0_op14 = {9{1'b0}};
        stage0_op15 = {9{1'b0}};
      end
      `ca53dpu_sel_0xx: begin // Reduction not active - gate off inputs to CSA tree
        stage0_op0  = {33{1'b0}};
        stage0_op1  = {33{1'b0}};
        stage0_op2  = {33{1'b0}};
        stage0_op3  = {33{1'b0}};
        stage0_op4  = {17{1'b0}};
        stage0_op5  = {17{1'b0}};
        stage0_op6  = {17{1'b0}};
        stage0_op7  = {17{1'b0}};
        stage0_op8  = {9{1'b0}};
        stage0_op9  = {9{1'b0}};
        stage0_op10 = {9{1'b0}};
        stage0_op11 = {9{1'b0}};
        stage0_op12 = {9{1'b0}};
        stage0_op13 = {9{1'b0}};
        stage0_op14 = {9{1'b0}};
        stage0_op15 = {9{1'b0}};
      end
      default: begin
        stage0_op0  = {33{1'bx}};
        stage0_op1  = {33{1'bx}};
        stage0_op2  = {33{1'bx}};
        stage0_op3  = {33{1'bx}};
        stage0_op4  = {17{1'bx}};
        stage0_op5  = {17{1'bx}};
        stage0_op6  = {17{1'bx}};
        stage0_op7  = {17{1'bx}};
        stage0_op8  = {9{1'bx}};
        stage0_op9  = {9{1'bx}};
        stage0_op10 = {9{1'bx}};
        stage0_op11 = {9{1'bx}};
        stage0_op12 = {9{1'bx}};
        stage0_op13 = {9{1'bx}};
        stage0_op14 = {9{1'bx}};
        stage0_op15 = {9{1'bx}};
      end
    endcase

  // Carry-save reduction tree
`define CSA_SUM(a,b,c)   ((a) ^ (b) ^ (c))
`define CSA_CARRY(a,b,c) (((a) & (b)) | ((b) & (c)) | ((c) & (a)))

  // First two stages
  assign stage1_op0[32:0] = `CSA_SUM(stage0_op0[32:0], stage0_op1[32:0], stage0_op2[32:0]);
  assign stage1_op1[33:1] = `CSA_CARRY(stage0_op0[32:0], stage0_op1[32:0], stage0_op2[32:0]);

  assign stage2_op0[33:0] = `CSA_SUM({stage0_op3[32], stage0_op3[32:0]}, {stage1_op0[32], stage1_op0[32:0]}, {stage1_op1[33:1], 1'b0});
  assign stage2_op1[34:1] = `CSA_CARRY({stage0_op3[32], stage0_op3[32:0]}, {stage1_op0[32], stage1_op0[32:0]}, {stage1_op1[33:1], 1'b0});


  assign stage1_op2[16:0] = `CSA_SUM(stage0_op4[16:0], stage0_op5[16:0], stage0_op6[16:0]);
  assign stage1_op3[17:1] = `CSA_CARRY(stage0_op4[16:0], stage0_op5[16:0], stage0_op6[16:0]);

  assign stage2_op2[17:0] = `CSA_SUM({stage0_op7[16], stage0_op7[16:0]}, {stage1_op2[16], stage1_op2[16:0]}, {stage1_op3[17:1], 1'b0});
  assign stage2_op3[18:1] = `CSA_CARRY({stage0_op7[16], stage0_op7[16:0]}, {stage1_op2[16], stage1_op2[16:0]}, {stage1_op3[17:1], 1'b0});


  assign stage1_op4[ 8:0] = `CSA_SUM(stage0_op8[ 8:0], stage0_op9[ 8:0], stage0_op10[ 8:0]);
  assign stage1_op5[ 9:1] = `CSA_CARRY(stage0_op8[ 8:0], stage0_op9[ 8:0], stage0_op10[ 8:0]);

  assign stage2_op4[ 9:0] = `CSA_SUM({stage0_op11[ 8], stage0_op11[ 8:0]}, {stage1_op4[ 8], stage1_op4[ 8:0]}, {stage1_op5[ 9:1], 1'b0});
  assign stage2_op5[10:1] = `CSA_CARRY({stage0_op11[ 8], stage0_op11[ 8:0]}, {stage1_op4[ 8], stage1_op4[ 8:0]}, {stage1_op5[ 9:1], 1'b0});


  assign stage1_op6[ 8:0] = `CSA_SUM(stage0_op12[ 8:0], stage0_op13[ 8:0], stage0_op14[ 8:0]);
  assign stage1_op7[ 9:1] = `CSA_CARRY(stage0_op12[ 8:0], stage0_op13[ 8:0], stage0_op14[ 8:0]);

  assign stage2_op6[ 9:0] = `CSA_SUM({stage0_op15[ 8], stage0_op15[ 8:0]}, {stage1_op6[ 8], stage1_op6[ 8:0]}, {stage1_op7[ 9:1], 1'b0});
  assign stage2_op7[10:1] = `CSA_CARRY({stage0_op15[ 8], stage0_op15[ 8:0]}, {stage1_op6[ 8], stage1_op6[ 8:0]}, {stage1_op7[ 9:1], 1'b0});

  // Middle two stages
  assign stage3_op0[18:0] = `CSA_SUM({stage2_op0[17], stage2_op0[17:0]}, {stage2_op1[18:1], 1'b0}, {stage2_op2[17], stage2_op2[17:0]});
  assign stage3_op1[18:1] = `CSA_CARRY(stage2_op0[17:0], {stage2_op1[17:1], 1'b0}, stage2_op2[17:0]);

  assign stage4_op0[18:0] = `CSA_SUM({stage2_op3[18:1], 1'b0}, stage3_op0[18:0], {stage3_op1[18:1], 1'b0});
  assign stage4_op1[19:1] = `CSA_CARRY({stage2_op3[18:1], 1'b0}, stage3_op0[18:0], {stage3_op1[18:1], 1'b0});


  assign stage3_op2[10:0] = `CSA_SUM({stage2_op4[ 9], stage2_op4[ 9:0]}, {stage2_op5[10:1], 1'b0}, {stage2_op6[ 9], stage2_op6[ 9:0]});
  assign stage3_op3[11:1] = `CSA_CARRY({stage2_op4[ 9], stage2_op4[ 9:0]}, {stage2_op5[10:1], 1'b0}, {stage2_op6[ 9], stage2_op6[ 9:0]});

  assign stage4_op2[11:0] = `CSA_SUM({stage2_op7[10], stage2_op7[10:1], 1'b0}, {stage3_op2[10], stage3_op2[10:0]}, {stage3_op3[11:1], 1'b0});
  assign stage4_op3[12:1] = `CSA_CARRY({stage2_op7[10], stage2_op7[10:1], 1'b0}, {stage3_op2[10], stage3_op2[10:0]}, {stage3_op3[11:1], 1'b0});

  // Final two stages
  assign stage5_op0[12:0] = `CSA_SUM({stage4_op0[11], stage4_op0[11:0]}, {stage4_op1[12:1], 1'b0}, {stage4_op2[11], stage4_op2[11:0]});
  assign stage5_op1[13:1] = `CSA_CARRY({stage4_op0[11], stage4_op0[11:0]}, {stage4_op1[12:1], 1'b0}, {stage4_op2[11], stage4_op2[11:0]});

  assign stage6_op0[13:0] = `CSA_SUM({stage4_op3[12], stage4_op3[12:1], 1'b0}, {stage5_op0[12], stage5_op0[12:0]}, {stage5_op1[13:1], 1'b0});
  assign stage6_op1[14:1] = `CSA_CARRY({stage4_op3[12], stage4_op3[12:1], 1'b0}, {stage5_op0[12], stage5_op0[12:0]}, {stage5_op1[13:1], 1'b0});

  // Generate final results
  always @*
    case (mod_neon_size_sel_f2)
      2'b00: begin
        neon_reduce_opa_f2_o = { {48{1'b0}}, { 2{~neon_unsigned_op_f2_i & stage6_op0[13]}}, stage6_op0[13:0]};
        neon_reduce_opb_f2_o = { {48{1'b0}},     ~neon_unsigned_op_f2_i & stage6_op1[14],   stage6_op1[14:1], 1'b0};
      end
      2'b01: begin
        neon_reduce_opa_f2_o = { {32{1'b0}}, {13{~neon_unsigned_op_f2_i & stage4_op0[18]}}, stage4_op0[18:0]};
        neon_reduce_opb_f2_o = { {32{1'b0}}, {12{~neon_unsigned_op_f2_i & stage4_op1[19]}}, stage4_op1[19:1], 1'b0};
      end
      2'b10: begin
        neon_reduce_opa_f2_o = {             {30{~neon_unsigned_op_f2_i & stage2_op0[33]}}, stage2_op0[33:0]};
        neon_reduce_opb_f2_o = {             {29{~neon_unsigned_op_f2_i & stage2_op1[34]}}, stage2_op1[34:1], 1'b0};
      end
      default: begin
        neon_reduce_opa_f2_o = {64{1'bx}};
        neon_reduce_opb_f2_o = {64{1'bx}};
      end
    endcase

endmodule

/*ARMAUTO_UNDEF*/
`undef CSA_SUM
`undef CSA_CARRY
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
