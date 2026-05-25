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
//      Checked In          : $Date: 2012-03-13 15:39:45 +0000 (Tue, 13 Mar 2012) $
//
//      Revision            : $Revision: 204339 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//---------------------------------------------------------------------------
// Ex1 stage extract unit
//
// Used by AA32 extend instructions and AA64 extended register ALU ops.
// 
// The Ex1 copy contains a small shifter and logic to extract the appropriate
// data and zero/sign extend as required. A dedicated shifter is used rather
// than reusing the main Ex1 barrel shifter to improve timing, as only a small
// number of shifts are required.
//
// Ex2 also contains an extract unit which allows instructions which use the
// extract unit but not the ALU to be forwarded into in Ex2.
//--------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_alu_extract_64 (
  // Inputs
  input  wire                                   clk_ex1,
  input  wire                                   reset_n,
  input  wire                                   en_alu_pipe_lo_ex1_i,
  input  wire                                   alu_iss_extract_valid_i,
  input  wire                            [ 4:0] alu_imm_shift_iss_i,
  input  wire                                   shift_op_lsl_iss_i,
  input  wire                                   shift_op_ror_iss_i,
  input  wire                                   alu_ex1_zero_sign_extend_i,
  input  wire  [`CA53_ALU_EX1_XTRACT_TYP_W-1:0] alu_ex1_extract_type_i,
  input  wire                            [63:0] alu_data_b_ex1_i,
  input  wire                            [63:0] shift_mask_ex1_i,
  // Outputs
  output reg                             [63:0] extracted_data_ex1_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg  [ 4:0] alu_imm_shift_ex1;
  reg         shift_op_lsl_ex1;
  reg         shift_op_ror_ex1;
  reg  [63:0] ext_data_mask;
  reg         sign_bit;
  reg  [63:0] shift_lsl;
  reg  [31:0] shift_ror;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire        extract_ex1_en;
  wire [63:0] rotated_data;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Dedicated local shift
  // ------------------------------------------------------
  //
  // Local shift logic for the extract logic which only requires a limited number of shift
  // types and can be done more quickly and in parallel to the main shift
  //
  // LSL : ADD, SUB extended register with a shift of 0-4 inclusive
  // ROR : {S,U}XTAB, {S,U}XTAB16, {S,U}XTAH with a shift of 0, 8, 16, or 24
  
  // Capture the immediate shift value and extract control terms from Iss
  assign extract_ex1_en = en_alu_pipe_lo_ex1_i & alu_iss_extract_valid_i;

  always @(posedge clk_ex1)
    if (extract_ex1_en) begin
      alu_imm_shift_ex1 <= alu_imm_shift_iss_i[4:0];
      shift_op_lsl_ex1  <= shift_op_lsl_iss_i;
      shift_op_ror_ex1  <= shift_op_ror_iss_i;
    end

  // LSL shift path
  always @*
    case (alu_imm_shift_ex1[2:0])
      3'b000  : shift_lsl =  alu_data_b_ex1_i[63:0];
      3'b001  : shift_lsl = {alu_data_b_ex1_i[62:0], 1'b0};
      3'b010  : shift_lsl = {alu_data_b_ex1_i[61:0], 2'b00};
      3'b011  : shift_lsl = {alu_data_b_ex1_i[60:0], 3'b000};
      3'b100  : shift_lsl = {alu_data_b_ex1_i[59:0], 4'b0000};
      default : shift_lsl = {64{1'bx}};
    endcase

  // ROR shift path
  always @*
    case (alu_imm_shift_ex1[4:0])
      5'b00000 : shift_ror =  alu_data_b_ex1_i[31:0];
      5'b01000 : shift_ror = {alu_data_b_ex1_i[ 7:0], alu_data_b_ex1_i[31: 8]}; // ROR 8
      5'b10000 : shift_ror = {alu_data_b_ex1_i[15:0], alu_data_b_ex1_i[31:16]}; // ROR 16
      5'b11000 : shift_ror = {alu_data_b_ex1_i[23:0], alu_data_b_ex1_i[31:24]}; // ROR 24
      default  : shift_ror = {32{1'bx}};
    endcase

  assign rotated_data[63:32] =   {32{shift_op_lsl_ex1}} & shift_lsl[63:32];
  assign rotated_data[31: 0] = (({32{shift_op_lsl_ex1}} & shift_lsl[31:0]) |
                                ({32{shift_op_ror_ex1}} & shift_ror[31:0]));

  // ------------------------------------------------------
  // Extract
  // ------------------------------------------------------

  always @*
    case (alu_ex1_extract_type_i)
      `CA53_EXTRACT_SH_BYTE: begin
        ext_data_mask = {~shift_mask_ex1_i[55:0], 8'h00};
        sign_bit      = alu_ex1_zero_sign_extend_i & alu_data_b_ex1_i[7];
      end

      `CA53_EXTRACT_SH_HWORD: begin
        ext_data_mask = {~shift_mask_ex1_i[47:0], 16'h0000};
        sign_bit      = alu_ex1_zero_sign_extend_i & alu_data_b_ex1_i[15];
      end

      `CA53_EXTRACT_SH_WORD: begin
        ext_data_mask = {~shift_mask_ex1_i[31:0], 32'h0000_0000};
        sign_bit      = alu_ex1_zero_sign_extend_i & alu_data_b_ex1_i[31];
      end

      default: begin
        ext_data_mask = {64{1'bx}};
        sign_bit      = 1'bx;
      end
    endcase

  always @*
    case (alu_ex1_extract_type_i)
      `CA53_EXTRACT_LS_BYTE:
        case (alu_ex1_zero_sign_extend_i)
          1'b0:     extracted_data_ex1_o = {{32{1'b0}}, {24{1'b0}},             rotated_data[ 7: 0]};
          1'b1:     extracted_data_ex1_o = {{32{1'b0}}, {24{rotated_data[ 7]}}, rotated_data[ 7: 0]};
          default:  extracted_data_ex1_o = {64{1'bx}};
        endcase

      `CA53_EXTRACT_LS_HWORD:
        case (alu_ex1_zero_sign_extend_i)
          1'b0:     extracted_data_ex1_o = {{32{1'b0}}, {16{1'b0}},             rotated_data[15: 0]};
          1'b1:     extracted_data_ex1_o = {{32{1'b0}}, {16{rotated_data[15]}}, rotated_data[15: 0]};
          default:  extracted_data_ex1_o = {64{1'bx}};
        endcase

      `CA53_EXTRACT_TWO_BYTES:
        case (alu_ex1_zero_sign_extend_i)
          1'b0:     extracted_data_ex1_o = {{32{1'b0}}, { 8{1'b0}},             rotated_data[23:16],
                                                        { 8{1'b0}},             rotated_data[ 7: 0]};
          1'b1:     extracted_data_ex1_o = {{32{1'b0}}, { 8{rotated_data[23]}}, rotated_data[23:16],
                                                        { 8{rotated_data[ 7]}}, rotated_data[ 7: 0]};
          default:  extracted_data_ex1_o = {64{1'bx}};
        endcase

      `CA53_EXTRACT_SH_BYTE,
      `CA53_EXTRACT_SH_HWORD,
      `CA53_EXTRACT_SH_WORD:
        extracted_data_ex1_o = (rotated_data & ~ext_data_mask) | ({64{sign_bit}} & ext_data_mask);

      `CA53_EXTRACT_SH_XWORD:
        extracted_data_ex1_o = rotated_data;

      default:
        extracted_data_ex1_o = {64{1'bx}};
    endcase

  // ------------------------------------------------------
  // OVL definitions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: extract_ex1_en")
  u_ovl_x_extract_ex1_en (.clk       (clk_ex1),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (extract_ex1_en));

`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
