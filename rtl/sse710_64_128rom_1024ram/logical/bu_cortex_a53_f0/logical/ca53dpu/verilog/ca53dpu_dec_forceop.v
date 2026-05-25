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
// Abstract : Force Operation generation in Decode stage.
//-----------------------------------------------------------------------------
//
// Overview
// --------
// Force Operations are inserted on an exception and are used to calculate the
// link address and save it in the appropriate link register (or R14). This is
// done using ALU0, which is does an add or subtract of the PC with an immediate
// value specified here.
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_dec_forceop `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire    [`CA53_FORCEOP_TYPE_W-1:0] forceop_type_i,
  input  wire  [`CA53_FORCEOP_OFFSET_W-1:0] forceop_offset_i,
  input  wire                               forceop_aa64_i,   // Exception taken from AA64 state
  input  wire                               aarch64_state_i,  // Exception taken to AA64 state
  input  wire                         [1:0] dpu_exception_level_i,
  // Outputs
  output wire    [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_force_o,
  output wire                         [4:0] rf_wr_vaddr_w1_force_o,
  output reg                                rf_wr_en_w1_force_o,
  output wire                               rf_wr_64b_w1_force_o,
  output wire      [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_force_o,
  output wire       [`CA53_SEL_SHF_A_W-1:0] dp_data_a_sel_force_o,
  output wire       [`CA53_SEL_SHF_B_W-1:0] dp_data_b_sel_force_o,
  output wire         [`CA53_EX_PIPE_W-1:0] ex_pipe_force_o,
  output wire     [`CA53_ALU_PIPECTL_W-1:0] alu_pipectl_force_o,
  output reg         [`CA53_IMM_DATA_W-1:0] imm_data_force_o,
  output reg                                msr_mrs_reg_wr_force_o,
  output reg                          [5:0] msr_mrs_data_force_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg   [`CA53_ALU_EX2_CTL_W-1:0] dp_ex2_ctl;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Decode type and offset
  // ------------------------------------------------------

  // Control signals for ALU based on type of forceop required
  always @* begin
    dp_ex2_ctl              = {`CA53_ALU_EX2_CTL_W{1'b0}};
    rf_wr_en_w1_force_o     = 1'b0;

    case (forceop_type_i)
      `CA53_FORCEOP_TYPE_NULL : begin
      end
      `CA53_FORCEOP_TYPE_ADD  : begin
        rf_wr_en_w1_force_o                           = 1'b1;
      end
      `CA53_FORCEOP_TYPE_SUB  : begin
        rf_wr_en_w1_force_o                           = 1'b1;
        dp_ex2_ctl[`CA53_ALU_EX2_CTL_LU_CTL_BITS]       = `CA53_LU_CTL_SUB;
        dp_ex2_ctl[`CA53_ALU_EX2_CTL_OP_COMP_SHF_B_BIT] = 1'b1;
      end
      `CA53_FORCEOP_TYPE_EL2  : begin
        rf_wr_en_w1_force_o                           = 1'b1;
        dp_ex2_ctl[`CA53_ALU_EX2_CTL_LU_CTL_BITS]       = `CA53_LU_CTL_SUB;
        dp_ex2_ctl[`CA53_ALU_EX2_CTL_OP_COMP_SHF_B_BIT] = 1'b1;
      end
      default                 : begin
        dp_ex2_ctl              = {`CA53_ALU_EX2_CTL_W{1'bx}};
        rf_wr_en_w1_force_o     = 1'bx;
      end
    endcase
  end

  // When taking exception to AA64, force physical register to be ELR for target
  // exception level. Will have already changed into target mode by time forceop
  // is in De, so can just look at current exception level etc.
  always @* begin
    msr_mrs_reg_wr_force_o = 1'b0;
    msr_mrs_data_force_o   = 6'b000000;
    if (aarch64_state_i) begin
      msr_mrs_reg_wr_force_o = 1'b1;
      case (dpu_exception_level_i)
        `CA53_EL1: msr_mrs_data_force_o = `CA53_ADDR_ELR_EL1;
        `CA53_EL2: msr_mrs_data_force_o = `CA53_ADDR_ELR_EL2;
        `CA53_EL3: msr_mrs_data_force_o = `CA53_ADDR_ELR_EL3;
        default:   msr_mrs_data_force_o = 6'bxxxxxx;
      endcase
    end else begin
      // In AA32, force physical register to be ELR_HYP when going to Hyp mode
      if (forceop_type_i == `CA53_FORCEOP_TYPE_EL2) begin
        msr_mrs_reg_wr_force_o  = 1'b1;
        msr_mrs_data_force_o    = `CA53_ADDR_ELR_HYP;
      end
    end
  end

  // Expand offset calculated by exception logic
  always @* begin
    imm_data_force_o = {`CA53_IMM_DATA_W{1'b0}};

    case (forceop_offset_i)
      `CA53_FORCEOP_OFFSET_0  : imm_data_force_o[3:0] = 4'h0;
      `CA53_FORCEOP_OFFSET_2  : imm_data_force_o[3:0] = 4'h2;
      `CA53_FORCEOP_OFFSET_4  : imm_data_force_o[3:0] = 4'h4;
      `CA53_FORCEOP_OFFSET_8  : imm_data_force_o[3:0] = 4'h8;
      default                 : imm_data_force_o[3:0] = 4'hx;
    endcase
  end

  // ------------------------------------------------------
  // Output signals
  // ------------------------------------------------------

  assign rf_wr_src_w1_force_o   = `CA53_RF_WR_SRC_W1_ALU;
  assign rf_wr_vaddr_w1_force_o = `CA53_VADDR_R14;
  assign rf_wr_64b_w1_force_o   = forceop_aa64_i; // PC is 64-bits if exception taken in AA64 state
  assign dp_data_a_sel_force_o  = `CA53_SEL_SHF_A_PC;
  assign dp_data_b_sel_force_o  = `CA53_SEL_SHF_B_IMM_DATA;
  assign ex_pipe_force_o        = (forceop_type_i == `CA53_FORCEOP_TYPE_NULL) ? `CA53_EX_PIPE_NULL : `CA53_EX_PIPE_ALU;
  assign rf_wr_when_w1_force_o  = `CA53_RF_WR_WHEN_LATE_WR;
  assign alu_pipectl_force_o    = {{`CA53_ALU_WR_CTL_W{1'b0}},   // dp_wr_ctl not used
                                   dp_ex2_ctl,                 // dp_ex2_ctl
                                   {`CA53_ALU_EX1_CTL_W{1'b0}},  // alu_ex1_ctl  not used
                                   forceop_aa64_i};            // dp_gen_ctl (ctl_64bit_op)

endmodule // ca53dpu_dec_forceop

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
