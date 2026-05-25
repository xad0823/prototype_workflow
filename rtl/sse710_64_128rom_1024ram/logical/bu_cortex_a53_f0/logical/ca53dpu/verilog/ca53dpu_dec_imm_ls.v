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
//      Checked In          : $Date: 2012-09-26 13:44:53 +0100 (Wed, 26 Sep 2012) $
//
//      Revision            : $Revision: 223828 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Immediate decoder for load-store instructions
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

module ca53dpu_dec_imm_ls (
  // Inputs
  input  wire                   [9:0] imm_sel_ls_i,
  input  wire                  [32:0] instr_i,
  input  wire  [`CA53_SHIFT_OP_W-1:0] ex1_ctl_shift_op_i,
  input  wire                         aarch64_state_i,
  input  wire                   [1:0] ls_elem_size_i,
  input  wire                   [4:0] num_lsm_registers_i,

  // Outputs
  output reg   [`CA53_IMM_DATA_W-1:0] imm_data_ls_o,
  output reg  [`CA53_IMM_SHIFT_W-1:0] imm_shift_ls_o,
  output reg    [`CA53_IMM_SEL_W-1:0] imm_data_sel_ls_o
);

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  always @* begin
    imm_data_ls_o     = {`CA53_IMM_DATA_W{1'b0}};
    imm_shift_ls_o    = {`CA53_IMM_SHIFT_W{1'b0}};
    imm_data_sel_ls_o = `CA53_IMM_SEL_NULL;

    case (imm_sel_ls_i)
      `CA53_IMM_LS_0 : begin
        // Do nothing
      end
      `CA53_IMM_LS_8 : imm_data_ls_o[3:0]  = 4'h8;
      `CA53_IMM_LS_A32_SHIFT : begin
        imm_shift_ls_o[5:0] = (((ex1_ctl_shift_op_i == `CA53_SHIFT_OP_ASR) |
                                (ex1_ctl_shift_op_i == `CA53_SHIFT_OP_LSR)) &
                               (instr_i[11:7] == 5'b00000)) ? 6'd32 : // For LSR and ASR, imm field of zero means shift of 32 bits
                              ( (ex1_ctl_shift_op_i == `CA53_SHIFT_OP_ROR) &
                               (instr_i[11:7] == 5'b00000)) ? 6'd01 : // RRX always uses a shift of 1
                                                              {1'b0, instr_i[11:7]};
      end

      `CA53_IMM_LS_SCALED :
        case (instr_i[22:21] & {2{aarch64_state_i}}) // In A64, immediate is scaled by element size
          2'b00: imm_data_ls_o[11:0] =  instr_i[11:0];
          2'b01: imm_data_ls_o[12:0] = {instr_i[11:0], 1'b0};
          2'b10: imm_data_ls_o[13:0] = {instr_i[11:0], 2'b00};
          2'b11: imm_data_ls_o[14:0] = {instr_i[11:0], 3'b000};
          default: begin
            imm_data_ls_o            = {`CA53_IMM_DATA_W{1'bx}};
            imm_shift_ls_o           = {`CA53_IMM_SHIFT_W{1'bx}};
          end
        endcase

      `CA53_IMM_LS_LDP_STP :
        case ({aarch64_state_i, ls_elem_size_i})
          3'b0_10: imm_data_ls_o[9:0]  = {instr_i[7:0], 2'b00}; // LDC and STC from ARMv4
          3'b1_10: imm_data_ls_o       = { {`CA53_IMM_DATA_W-8{instr_i[6]}}, instr_i[5:0], 2'b00};
          3'b1_11: imm_data_ls_o       = { {`CA53_IMM_DATA_W-9{instr_i[6]}}, instr_i[5:0], 3'b000};
          default: begin
            imm_data_ls_o              = {`CA53_IMM_DATA_W{1'bx}};
            imm_shift_ls_o             = {`CA53_IMM_SHIFT_W{1'bx}};
          end
        endcase

      `CA53_IMM_LS_SIGNED   : imm_data_ls_o       = { {`CA53_IMM_DATA_W-8{instr_i[31] & aarch64_state_i}}, instr_i[7:0]}; // Signed in A64
      `CA53_IMM_LS_IMM4HL   : imm_data_ls_o[7:0]  = {instr_i[11:8], instr_i[3:0]};
      `CA53_IMM_LS_LSM1     : imm_data_ls_o[6:0]  = {num_lsm_registers_i, 2'b00};
      `CA53_IMM_LS_LSM2     : imm_data_ls_o[6:0]  = {(num_lsm_registers_i - 5'b00001), 2'b00};
      `CA53_IMM_LS_A64_LIT  : imm_data_ls_o       = { {`CA53_IMM_DATA_W-20{instr_i[22]}}, instr_i[21:16], instr_i[11:0], 2'b00};
      `CA53_IMM_LS_TBB      : imm_data_sel_ls_o   = `CA53_IMM_SEL_TBB; 
      default : begin
        imm_data_ls_o     = {`CA53_IMM_DATA_W{1'bx}};
        imm_shift_ls_o    = {`CA53_IMM_SHIFT_W{1'bx}};
        imm_data_sel_ls_o = `CA53_IMM_SEL_X;
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
