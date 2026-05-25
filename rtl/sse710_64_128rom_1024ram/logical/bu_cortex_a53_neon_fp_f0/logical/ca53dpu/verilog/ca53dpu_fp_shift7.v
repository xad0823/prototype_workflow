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
// Abstract :
//-----------------------------------------------------------------------------
//
// Overview
// --------
//

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_fp_shift7
(
  // Inputs
  input  wire [105:0] data_i,
  input  wire   [6:0] shift_lo_i,
  input  wire   [6:0] shift_hi_i,
  input  wire         ctl_dual_fp_i,
  // Outputs
  output wire [105:0] result_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg  [72:0] stage1_hi;
  reg  [62:0] stage1_lo;
  reg  [60:0] stage2_hi;
  reg  [50:0] stage2_lo;
  reg  [57:0] stage3_hi;
  reg  [47:0] stage3_lo;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  always @*
    case (shift_hi_i[6:4])
      3'b000:  stage1_hi = {data_i[105:48], data_i[ 47:33] & {15{~ctl_dual_fp_i}} };
      3'b001:  stage1_hi = {data_i[ 89:48], data_i[ 47:17] & {31{~ctl_dual_fp_i}} };
      3'b010:  stage1_hi = {data_i[ 73:48], data_i[ 47: 1] & {47{~ctl_dual_fp_i}} };
      3'b011:  stage1_hi = {data_i[ 57:48], data_i[ 47: 0] & {48{~ctl_dual_fp_i}}, {15{1'b0}} };

      3'b100:  stage1_hi = { {64{1'b0}}, data_i[105:97] };
      3'b101:  stage1_hi = { {48{1'b0}}, data_i[105:81] };
      3'b110:  stage1_hi = { {32{1'b0}}, data_i[105:65] };
      3'b111:  stage1_hi = { {16{1'b0}}, data_i[105:49] };
      default: stage1_hi = {73{1'bx}};
    endcase

  always @*
    case (shift_lo_i[6:4])
      3'b000:  stage1_lo = {data_i[47:0], {15{1'b0}} };
      3'b001:  stage1_lo = {data_i[31:0], {31{1'b0}} };
      3'b010:  stage1_lo = {data_i[15:0], {47{1'b0}} };
      3'b011:  stage1_lo =                {63{1'b0}};

      3'b100:  stage1_lo = { {6{1'b0}}, {57{~ctl_dual_fp_i}} & data_i[105:49]                };
      3'b101:  stage1_lo = {            {48{~ctl_dual_fp_i}} & data_i[ 95:48], data_i[47:33] };
      3'b110:  stage1_lo = {            {32{~ctl_dual_fp_i}} & data_i[ 79:48], data_i[47:17] };
      3'b111:  stage1_lo = {            {16{~ctl_dual_fp_i}} & data_i[ 63:48], data_i[47: 1] };
      default: stage1_lo = {63{1'bx}};
    endcase

  always @*
    case (shift_hi_i[3:2])
      2'b00:   stage2_hi = stage1_hi[72:12];
      2'b01:   stage2_hi = stage1_hi[68: 8];
      2'b10:   stage2_hi = stage1_hi[64: 4];
      2'b11:   stage2_hi = stage1_hi[60: 0];
      default: stage2_hi = {61{1'bx}};
    endcase

  always @*
    case (shift_lo_i[3:2])
      2'b00:   stage2_lo = stage1_lo[62:12];
      2'b01:   stage2_lo = stage1_lo[58: 8];
      2'b10:   stage2_lo = stage1_lo[54: 4];
      2'b11:   stage2_lo = stage1_lo[50: 0];
      default: stage2_lo = {51{1'bx}};
    endcase

  always @*
    case (shift_hi_i[1:0])
      2'b00:   stage3_hi = stage2_hi[60: 3];
      2'b01:   stage3_hi = stage2_hi[59: 2];
      2'b10:   stage3_hi = stage2_hi[58: 1];
      2'b11:   stage3_hi = stage2_hi[57: 0];
      default: stage3_hi = {58{1'bx}};
    endcase

  always @*
    case (shift_lo_i[1:0])
      2'b00:   stage3_lo = stage2_lo[50: 3];
      2'b01:   stage3_lo = stage2_lo[49: 2];
      2'b10:   stage3_lo = stage2_lo[48: 1];
      2'b11:   stage3_lo = stage2_lo[47: 0];
      default: stage3_lo = {48{1'bx}};
    endcase

  assign result_o = {stage3_hi, stage3_lo};

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/

