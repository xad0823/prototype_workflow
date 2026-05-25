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
// Abstract : Renormalisation shift module for FP ALU pipeline
//-----------------------------------------------------------------------------
//
// Overview
// --------
//

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_fp_alu_renorm (
  input  wire [107:0] alu_res_f4_i,
  input  wire [  6:0] shift_lo_i,
  input  wire [  6:0] shift_hi_i,
  input  wire         dual_op_i,
  output wire [107:0] result_o
);

  // -------------------------------
  // Reg declarations
  // -------------------------------

  reg   [107:0] stage1;
  reg   [107:0] stage2;
  reg   [107:0] stage3;

  // -------------------------------
  // Wire declarations
  // -------------------------------

  wire  [107:0] stage0;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // -------------------------------
  // Perform split shift
  // -------------------------------

  assign stage0 = alu_res_f4_i;

  always @*
    case (shift_hi_i[6:4])
      3'b000:  stage1[107:54] =   stage0[107: 54];
      3'b001:  stage1[107:54] = { stage0[ 91: 54], {16{~dual_op_i}} & stage0[53:38]};
      3'b010:  stage1[107:54] = { stage0[ 75: 54], {32{~dual_op_i}} & stage0[53:22]};
      3'b011:  stage1[107:54] = { stage0[ 59: 54], {48{~dual_op_i}} & stage0[53: 6]};
      3'b100:  stage1[107:54] = {                  {44{~dual_op_i}} & stage0[43: 0], {10{1'b0}} };
      3'b101:  stage1[107:54] = {                  {28{~dual_op_i}} & stage0[27: 0], {26{1'b0}} };
      3'b110:  stage1[107:54] = {                  {12{~dual_op_i}} & stage0[11: 0], {42{1'b0}} };
      3'b111:  stage1[107:54] =                                                      {54{1'b0}};
      default: stage1[107:54] = {54{1'bx}};
    endcase

  always @*
    case (shift_lo_i[6:4])
      3'b000:  stage1[ 53: 0] =  stage0[53: 0];
      3'b001:  stage1[ 53: 0] = {stage0[37: 0], {16{1'b0}} };
      3'b010:  stage1[ 53: 0] = {stage0[21: 0], {32{1'b0}} };
      3'b011:  stage1[ 53: 0] = {stage0[ 5: 0], {48{1'b0}} };
      3'b100:  stage1[ 53: 0] =                 {54{1'b0}};
      3'b101:  stage1[ 53: 0] =                 {54{1'b0}};
      3'b110:  stage1[ 53: 0] =                 {54{1'b0}};
      3'b111:  stage1[ 53: 0] =                 {54{1'b0}};
      default: stage1[ 53: 0] = {54{1'bx}};
    endcase

  always @*
    case (shift_hi_i[3:2])
      2'b00:   stage2[107:54] =  stage1[107: 54];
      2'b01:   stage2[107:54] = {stage1[103: 54], { 4{~dual_op_i}} & stage1[53:50]};
      2'b10:   stage2[107:54] = {stage1[ 99: 54], { 8{~dual_op_i}} & stage1[53:46]};
      2'b11:   stage2[107:54] = {stage1[ 95: 54], {12{~dual_op_i}} & stage1[53:42]};
      default: stage2[107:54] = {54{1'bx}};
    endcase

  always @*
    case (shift_lo_i[3:2])
      2'b00:   stage2[ 53: 0] =  stage1[53: 0];
      2'b01:   stage2[ 53: 0] = {stage1[49: 0], { 4{1'b0}} };
      2'b10:   stage2[ 53: 0] = {stage1[45: 0], { 8{1'b0}} };
      2'b11:   stage2[ 53: 0] = {stage1[41: 0], {12{1'b0}} };
      default: stage2[ 53: 0] = {54{1'bx}};
    endcase

  always @*
    case (shift_hi_i[1:0])
      2'b00:   stage3[107:54] =  stage2[107: 54];
      2'b01:   stage3[107:54] = {stage2[106: 54],    ~dual_op_i   & stage2[53]   };
      2'b10:   stage3[107:54] = {stage2[105: 54], {2{~dual_op_i}} & stage2[53:52]};
      2'b11:   stage3[107:54] = {stage2[104: 54], {3{~dual_op_i}} & stage2[53:51]};
      default: stage3[107:54] = {54{1'bx}};
    endcase

  always @*
    case (shift_lo_i[1:0])
      2'b00:   stage3[ 53: 0] =  stage2[53: 0];
      2'b01:   stage3[ 53: 0] = {stage2[52: 0],    1'b0   };
      2'b10:   stage3[ 53: 0] = {stage2[51: 0], {2{1'b0}} };
      2'b11:   stage3[ 53: 0] = {stage2[50: 0], {3{1'b0}} };
      default: stage3[ 53: 0] = {54{1'bx}};
    endcase

  assign result_o = stage3;

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/

