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
// Abstract : Immediate decoder for data-processing instructions
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

module ca53dpu_dec_imm_dp (
  // Inputs
  input  wire          [`CA53_IMM_DP_W-1:0] imm_sel_dp_i,
  input  wire                        [32:0] instr_i,
  input  wire        [`CA53_SHIFT_OP_W-1:0] ex1_ctl_shift_op_i,
  input  wire                               valid_ex1_ctl_shift_rrx_for_0_i,
  input  wire                               ex2_ctl_valid_simd_i,
  input  wire                               aarch64_state_i,
  input  wire                               thumb_execution_i,

  // Outputs
  output reg         [`CA53_IMM_DATA_W-1:0] imm_data_dp_o,
  output reg        [`CA53_IMM_SHIFT_W-1:0] imm_shift_dp_o,
  output reg          [`CA53_IMM_SEL_W-1:0] imm_data_sel_dp_o
);

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  always @* begin
    imm_data_dp_o       = {`CA53_IMM_DATA_W{1'b0}};
    imm_shift_dp_o      = {`CA53_IMM_SHIFT_W{1'b0}};
    imm_data_sel_dp_o   = `CA53_IMM_SEL_NULL;

    case (imm_sel_dp_i)
      `CA53_IMM_DP_0: begin
        // Do nothing
      end

      `CA53_IMM_DP_A32_SHIFT: begin
        imm_data_dp_o[4:0]  = instr_i[20:16];  // Used by saturate instructions (MSK_B)
        imm_shift_dp_o[4:0] = valid_ex1_ctl_shift_rrx_for_0_i ? 5'b00001
                                                              : instr_i[11:7];   // Used by shifter for ARM instruction with shifted register
        imm_shift_dp_o[5]   = ((ex1_ctl_shift_op_i == `CA53_SHIFT_OP_ASR) |
                               (ex1_ctl_shift_op_i == `CA53_SHIFT_OP_LSR)) &
                              (instr_i[11:7] == 5'b00000); // For LSR and ASR, imm field of zero means shift of 32 bits
      end

      `CA53_IMM_DP_T32_SHIFT: begin
        imm_data_dp_o[5:0]  = aarch64_state_i      ? (instr_i[5:0] - {instr_i[26], instr_i[14:12], instr_i[7:6]}) :
                              ex2_ctl_valid_simd_i ? {2'b00, instr_i[3:0]} : // USAT16/SSAT16
                                                     {1'b0, instr_i[4:0]};   // For saturate/bitfield instructions (MSK_B)
        imm_shift_dp_o[4:0] = valid_ex1_ctl_shift_rrx_for_0_i ? 5'b00001
                                                              : {instr_i[14:12], instr_i[7:6]};   // For shifter (SHF_C) DP instructions
        imm_shift_dp_o[5]   = aarch64_state_i ? instr_i[15]
                                              : // For LSR and ASR, imm field of zero means shift of 32 bits
                                                ((ex1_ctl_shift_op_i == `CA53_SHIFT_OP_ASR) |
                                                 (ex1_ctl_shift_op_i == `CA53_SHIFT_OP_LSR)) &
                                                ({instr_i[14:12], instr_i[7:6]} == 5'b00000);
      end

      `CA53_IMM_DP_ADDW: begin  // ADDW, SUBW etc.
        imm_data_dp_o[11:0] = {instr_i[26], instr_i[14:12], instr_i[7:0]};
        imm_shift_dp_o[5:0] = (aarch64_state_i & instr_i[31]) ? `CA53_IMM_LSL_12 : `CA53_IMM_LSL_0;
        imm_data_sel_dp_o   = `CA53_IMM_SEL_LSL;
      end

      `CA53_IMM_DP_T32_IMM: begin // ADD (imm), MOV (imm) etc.
        // If in ARM state or in debug mode then use the ARM immediate values
        case (thumb_execution_i)
          1'b0 : begin
            imm_data_dp_o[7:0]  =  instr_i[7:0];
            imm_shift_dp_o[4:0] = {instr_i[26], instr_i[14:12], 1'b0};
            imm_data_sel_dp_o   = `CA53_IMM_SEL_ROR;
          end
          1'b1 : begin
            case({instr_i[26], instr_i[14]})
              2'b00 : begin
                // For constants of the form 0x00XY00XY,
                // 0xXY00XY00 and 0xXYXYXYXY
                imm_data_dp_o[7:0]  = instr_i[7:0];
                imm_shift_dp_o      = {`CA53_IMM_SHIFT_W{1'b0}};
                imm_data_sel_dp_o   = {1'b0, instr_i[13:12]};
              end
              2'b01, 2'b10, 2'b11 : begin
                // for shifted 8 bit values
                imm_data_dp_o[7:0]  = {1'b1,instr_i[6:0]};
                imm_shift_dp_o[4:0] = {instr_i[26], instr_i[14:12], instr_i[7]};
                imm_data_sel_dp_o   = `CA53_IMM_SEL_ROR;
              end
              default : begin
                imm_data_dp_o       = {`CA53_IMM_DATA_W{1'bx}};
                imm_shift_dp_o      = {`CA53_IMM_SHIFT_W{1'bx}};
                imm_data_sel_dp_o   = `CA53_IMM_SEL_X;
              end
            endcase // case({instr_i[26], instr_i[14]})
          end
          default : begin
            imm_data_dp_o     = {`CA53_IMM_DATA_W{1'bx}};
            imm_shift_dp_o    = {`CA53_IMM_SHIFT_W{1'bx}};
            imm_data_sel_dp_o = `CA53_IMM_SEL_X;
          end
        endcase
      end

      `CA53_IMM_DP_MOVW: begin // MOVT, MOVW, etc..
        imm_data_dp_o[15:0] = {instr_i[19:16], instr_i[26], instr_i[14:12], instr_i[7:0]};
        imm_data_sel_dp_o   = `CA53_IMM_SEL_LSL;
        case (aarch64_state_i)
          1'b0: // AA32: MOVT/MOVW
            case (instr_i[23])
              1'b0   : imm_shift_dp_o[5:0] = `CA53_IMM_LSL_0;  // MOVW
              1'b1   : imm_shift_dp_o[5:0] = `CA53_IMM_LSL_16; // MOVT
              default: imm_shift_dp_o[5:0] = {6{1'bx}};
            endcase
          1'b1: // AA64: MOVN/MOVK/MOVZ
            case(instr_i[31:30])  
              // HW:
              2'b00  : imm_shift_dp_o[5:0] = `CA53_IMM_LSL_0;
              2'b01  : imm_shift_dp_o[5:0] = `CA53_IMM_LSL_16;
              2'b10  : imm_shift_dp_o[5:0] = `CA53_IMM_LSL_32;
              2'b11  : imm_shift_dp_o[5:0] = `CA53_IMM_LSL_48;
              default: imm_shift_dp_o[5:0] = {6{1'bx}};
            endcase
          default: imm_shift_dp_o[5:0] = {6{1'bx}};
        endcase
      end

      `CA53_IMM_DP_EXTEND: begin // Extend instructions (SXTAH etc.)
        imm_shift_dp_o[4:0] = {instr_i[5:4], 3'b000};
      end

      `CA53_IMM_DP_A32_IMM: begin // V4 addressing mode,etc
        imm_shift_dp_o[4:0] = {instr_i[11:8], 1'b0};
        imm_data_dp_o[7:0]  =  instr_i[7:0];
      end

      `CA53_IMM_DP_BFM: begin
        imm_data_dp_o[5:0]  = aarch64_state_i ? (instr_i[5:0] - {instr_i[26], instr_i[14:12], instr_i[7:6]})
                                              : {1'b0, instr_i[4:0]}; // For saturate/bitfield instructions (MSK_B)
        imm_shift_dp_o[5:0] = {instr_i[26], instr_i[14:12], instr_i[7:6]};
      end

      `CA53_IMM_DP_A64_ADR: begin
        imm_data_dp_o[20:0] = {instr_i[22:12], instr_i[7:0], instr_i[24:23]};
        case (instr_i[25])
          1'b1: begin // ADRP - shift immediate by 12 and sign extend
            imm_data_sel_dp_o   = `CA53_IMM_SEL_LSL;
            imm_shift_dp_o[5:0] = `CA53_IMM_LSL_ADRP;
          end
          1'b0: begin // ADR - no shift
            imm_data_sel_dp_o   = `CA53_IMM_SEL_NULL;
          end
          default: begin
            imm_shift_dp_o[5:0] = {6{1'bx}};
            imm_data_sel_dp_o   = `CA53_IMM_SEL_X;
          end
        endcase
      end

      `CA53_IMM_DP_EXT_REG: begin // ADD/Sub extended register
        imm_shift_dp_o[2:0] = instr_i[6:4];
      end

      `CA53_IMM_DP_LOG_IMM: begin // Logical Immediate
        imm_data_dp_o[6:0]  = {instr_i[31], instr_i[5:0]};
        imm_shift_dp_o[5:0] = {instr_i[26], instr_i[7:6], instr_i[14:12]};
        imm_data_sel_dp_o   = `CA53_IMM_SEL_A64_LOG_IMM;
      end

      `CA53_IMM_DP_EXTR: begin // Extract EXTR
        imm_shift_dp_o[5:0] = {instr_i[13:12], instr_i[7:4]};
      end

      `CA53_IMM_DP_CSEL: begin // Conditional select/compare
        imm_data_dp_o[4:0]  = {instr_i[31], instr_i[3:0]}; // {i,imm4}
        imm_shift_dp_o[7:4] = instr_i[11:8];
        imm_shift_dp_o[3:0] = instr_i[7:4];
      end

      `CA53_IMM_DP_CRC32: begin // CRC32
        case (instr_i[5:4])
          2'b00: imm_shift_dp_o[5:0] = 6'd24; // LSL #24
          2'b01: imm_shift_dp_o[5:0] = 6'd16; // LSL #16
          2'b10: imm_shift_dp_o[5:0] = 6'd0;  // nothing
          2'b11: imm_shift_dp_o[5:0] = 6'd32; // ROR #32
          default: imm_shift_dp_o = {`CA53_IMM_SHIFT_W{1'bx}};
        endcase
      end

      default: begin
        imm_data_dp_o     = {`CA53_IMM_DATA_W{1'bx}};
        imm_shift_dp_o    = {`CA53_IMM_SHIFT_W{1'bx}};
        imm_data_sel_dp_o = `CA53_IMM_SEL_X;
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
