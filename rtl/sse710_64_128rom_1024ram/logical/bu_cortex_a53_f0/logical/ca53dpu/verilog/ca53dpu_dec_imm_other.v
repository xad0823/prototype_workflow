//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2015 ARM Limited.
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
// Abstract : Immediate decoder for "Other" instructions
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Uses the imm_sel signal created by the main decoder to select the relevant
// immediate bits from the instruction opcode.
//
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_dec_imm_other (
  // Inputs
  input  wire    [`CA53_IMM_OT_W-1:0] imm_sel_other_i,
  input  wire                  [32:0] instr_i,
  // Outputs
  output reg   [`CA53_IMM_DATA_W-1:0] imm_data_other_o,
  output reg  [`CA53_IMM_SHIFT_W-1:0] imm_shift_other_o
);

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  always @* begin
    imm_data_other_o      = {`CA53_IMM_DATA_W{1'b0}};
    imm_shift_other_o     = {`CA53_IMM_SHIFT_W{1'b0}};

    case (imm_sel_other_i)
      `CA53_IMM_OT_0: begin
        // Do nothing
      end
      `CA53_IMM_OT_B_1: begin
        imm_data_other_o[3:0]  = 4'h1;
        imm_shift_other_o[5:0] = instr_i[23:18];
      end
      `CA53_IMM_OT_B_4: begin
        imm_data_other_o[3:0]  = 4'h4;
      end
      default: begin
        imm_data_other_o       = {`CA53_IMM_DATA_W{1'bx}};
        imm_shift_other_o      = {`CA53_IMM_SHIFT_W{1'bx}};
      end
    endcase
  end

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
