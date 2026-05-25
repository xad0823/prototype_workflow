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
// Abstract : ALU pipeline - all data-processing apart from multiply and
// divide
//-----------------------------------------------------------------------------
//
// This module contains all the registers, and the datapath elements for the
// ALU pipeline, which processes the following instructions:
//
// - Logical operations (AND, BIC, MOV etc)
// - Arithmetic operations (ADD, USUB16 etc)
// - Comparisons (CMP, TEQ etc)
// - Saturation operations (USAT, QADD etc)
// - Bitfield operations (BFI, SXTH etc)
// - Shifter operations (LSR, RRX etc)
// - Other misc operations (RBIT, REV, CLZ)
// - Saturated doubling or halving operations (QDADD, SHSUB16 etc)
//
// Also deals with base-register writeback operations for load and store
// instructions, and moving of data to/from other pipelines - specifically
// the accumulation operand into the MAC pipeline.
//
// The datapath elements are divided between the following stages:
//
// Ex1 Stage:
// - The first arithmetic unit for 'skewing' to allow early results of operations
//   such as ADD to be obtained for forwarding.
// - The 32-bit barrel shifter unit
// - The RBIT unit (permuted wires)
// - The SAT * 2 unit required by {QDADD, QDSUB} instructions
// - The sign extension logic required by the XTEND and XTRACT instructions (one of two)
//
// Ex2 Stage:
// - The second arithmetic unit which is used when early generation of results is not
//   possible or for more complex operations such as shift-ADD
// - The logic unit
// - The Count Leading Zeroes unit
// - The sign extension logic required by the XTEND and XTRACT instructions (two of two)
// - The saturation unit (one of two)
// - CC flag and GE flag generation and setting logic
//
// Wr Stage:
// - The SIMD saturate unit (two of two)

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_alu #(parameter ALU_SLOT_1 = 1'b0, parameter NEON_FP = 1'b0) (
  // Inputs
  input  wire                           clk,
  input  wire                           reset_n,
  input  wire                           DFTSE,
  input  wire                           aarch64_state_i,
  input  wire                    [63:0] alu_data_a_iss_i,
  input  wire                    [63:0] alu_data_b_iss_i,
  input  wire                     [7:0] alu_data_c_iss_i,
  input  wire                     [5:0] alu_mskgen_iss_i,
  input  wire                     [4:0] alu_imm_shift_iss_i,
  input  wire                           alu_imm_sel_c_iss_i,
  input  wire                    [63:0] rf_wr_data_w0_wr_i,
  input  wire                    [63:0] rf_wr_data_w1_wr_i,
  input  wire                    [63:0] rf_wr_data_w2_wr_i,
  input  wire         [`CA53_FWD_W-1:0] alu_a_fwd_ex1_i,
  input  wire         [`CA53_FWD_W-1:0] alu_b_fwd_ex1_i,
  input  wire                           ctl_64bit_op_iss_i,
  input  wire                           flush_ret_i,
  input  wire                           quash_iss_i,
  input  wire                           quash_ex1_i,
  input  wire                           stall_ex1_i,
  input  wire                           stall_ex2_i,
  input  wire                           stall_wr_i,
  input  wire                           use_ex1_alu_iss_i,
  input  wire                           raw_alu_valid_iss_i,
  input  wire                           alu_valid_iss_i,
  input  wire [`CA53_ALU_EX1_CTL_W-1:0] alu_ex1_ctl_iss_i,
  input  wire [`CA53_ALU_EX2_CTL_W-1:0] alu_ex2_ctl_iss_i,
  input  wire                           alu_wr_ctl_iss_i,
  input  wire                    [63:0] alu0_fwd_data_ex1_i,
  input  wire                    [63:0] alu0_fwd_data_ex2_i,
  input  wire                    [63:0] alu1_fwd_data_ex2_i,
  input  wire                           csel_cc_pass_ex2_i,
  input  wire                           csel_cc_pass_early_ex2_i,
  input  wire                     [3:0] geflags_ex2_i,
  input  wire                           cflag_ex2_i,
  input  wire                           vflag_wr_i,
  // Outputs
  output wire                           alu_qbit_wr_o,
  output wire                    [63:0] alu_fwd_data_ex1_o,
  output wire                    [63:0] alu_fwd_data_ex2_o,
  output wire                    [63:0] alu_data_wr_o,
  output wire                    [63:0] alu_data_a_ex2_o,
  output wire                    [63:0] alu_fwd_data_early_ex2_o,
  output wire                    [63:0] alu_fwd_data_early_wr_o,
  output wire                           alu_valid_ex2_o,
  output wire                           alu_au_nout_ex2_o,
  output wire                     [1:0] alu_ex2_flagid_o,
  output wire                           alu_sel_c_flag_ex2_o,
  output wire                           alu_sel_v_flag_ex2_o,
  output wire                     [3:0] new_alu_ccflags_nclear_ex2_o,
  output wire                     [3:0] new_alu_ccflags_nset_ex2_o,
  output wire                     [3:0] new_alu_ccflags_ccmp_ex2_o,
  output wire                           alu_sel_ccmp_flags_ex2_o,
  output wire                     [3:0] alu_csel_cond_ex2_o,
  output wire                     [3:0] new_alu_geflags_ex2_o,
  output wire                           alu_ex2_cbz_bypass_zflag_o,
  output wire                           alu_ex2_cbz_pass_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg         [`CA53_ALU_EX1_CTL_W-1:0] alu_ex1_ctl_ex1;
  reg         [`CA53_ALU_EX2_CTL_W-1:0] alu_ex2_ctl_ex1;
  reg                                   alu_wr_ctl_ex1;
  reg                                   skew_ex1;
  reg                                   skew_ex2;
  reg                                   skew_au_op_ex2;
  reg                                   ctl_64bit_op_ex1;
  reg                                   alu_wr_ctl_ex2;
  reg                                   alu_wr_ctl_wr;
  reg                                   alu_valid_ex1;
  reg                                   alu_valid_ex2;
  reg                                   early_c_flag_ex2;
  reg                                   early_c_flag_valid_ex2;
  reg                                   shift_rrx_ex2;
  reg                                   alu_ex2_zero_sign_extend;
  reg                                   alu_ex2_clz_sel_sign_count;
  reg                                   alu_ex2_clz_sel_zero_count;
  reg                                   nxt_alu_sat_dbl_set_qbit_ex2;
  reg                                   alu_sat_dbl_set_qbit_ex2;
  reg                                   ctl_64bit_op_ex2;
  reg                                   early_qbit_wr;
  reg  [`CA53_ALU_EX1_XTRACT_TYP_W-1:0] alu_ex2_extract_type;
  reg                            [63:0] nxt_alu_data_a_ex2;
  reg                            [63:0] nxt_alu_data_b_ex2;
  reg                            [63:0] alu_data_a_ex1;
  reg                            [63:0] alu_data_a_ex2;
  reg                            [63:0] alu_data_b_ex1;
  reg                            [63:0] alu_data_b_ex2;
  reg                            [63:0] raw_alu_data_wr;
  reg                            [63:0] alu_mask_data_ex2;
  reg                            [63:0] final_alu_data_a_ex1;
  reg                            [23:0] extract_data_ex2;
  reg                             [5:0] alu_mskgen_ex1;
  reg                                   alu_imm_sel_c_ex1;
  reg                             [5:0] alu_mskgen_ex2;
  reg                             [7:0] alu_data_c_ex1;
  reg                             [3:0] simd_sat_overflow_wr;
  reg                             [3:0] simd_sat_direction_wr;
  reg                                   alu_wr_valid_simd;
  reg                                   alu_wr_simd_size;
  reg                                   alu_wr_simd_sign_arth;
  reg                                   raw_alu_ex2_cbz_bypass_zflag;
  reg                                   au_ex2_halving;
  reg                             [1:0] alu_ex2_flagid;
  reg                                   alu_ex2_sel_valid;
  reg                                   alu_ex2_sign_replicate;
  reg                                   alu_ex2_simd_sign_arth;
  reg                                   alu_ex2_simd_size;
  reg                                   alu_ex2_valid_simd;
  reg                                   alu_ex2_no_valid_simd;
  reg                             [3:0] invert_data_a_ex2;
  reg                             [3:0] invert_data_b_ex2;
  reg              [`CA53_LU_CTL_W-1:0] lu_ctl_ex2;
  reg                                   ctl_64bit_op_wr;
  reg                                   au_add_sub_cin_ctl_ex1;
  reg                                   au_cin_ctl_ex1;
  reg                                   au_sel_normal_a_hi_ex1;
  reg                                   au_sel_invert_a_hi_ex1;
  reg                                   au_sel_normal_a_lo_ex1;
  reg                                   au_sel_invert_a_lo_ex1;
  reg                                   au_sel_normal_b_hi_ex1;
  reg                                   au_sel_invert_b_hi_ex1;
  reg                                   au_sel_normal_b_lo_ex1;
  reg                                   au_sel_invert_b_lo_ex1;
  reg                                   au_simd_instr_addsubx_ex1;
  reg                                   au_simd_instr_subaddx_ex1;
  reg                                   au_sub_operation_ex1;
  reg                                   enable_au_ex1;
  reg                                   au_valid_8_bit_simd_ex1;
  reg                                   au_add_sub_cin_ctl_ex2;
  reg                                   au_cin_ctl_ex2;
  reg                                   au_sel_normal_a_hi_ex2;
  reg                                   au_sel_invert_a_hi_ex2;
  reg                                   au_sel_normal_a_lo_ex2;
  reg                                   au_sel_invert_a_lo_ex2;
  reg                                   au_sel_normal_b_hi_ex2;
  reg                                   au_sel_invert_b_hi_ex2;
  reg                                   au_sel_normal_b_lo_ex2;
  reg                                   au_sel_invert_b_lo_ex2;
  reg                                   au_simd_instr_addsubx_ex2;
  reg                                   au_simd_instr_subaddx_ex2;
  reg                                   au_sub_operation_ex2;
  reg                                   au_valid_8_bit_simd_ex2;
  reg                             [2:0] au_simd_forced_carryin_a_ex1;
  reg                             [2:0] au_simd_forced_carryin_b_ex1;
  reg                             [2:0] au_simd_forced_carryin_a_ex2;
  reg                             [2:0] au_simd_forced_carryin_b_ex2;
  reg                             [3:0] skew_geflags_ex2;
  reg                                   early_v_flag_ex2;
  reg                            [63:0] movw_mask_ex1;
  reg                                   aarch64_state_ex1;
  reg                                   aarch64_state_ex2;
  reg                                   shift_op_right_shift_ex1;
  reg                                   shift_op_left_shift_ex1;
  reg                                   shift_op_extr_instr_ex1;
  reg                             [3:0] geflags_wr;
  reg                                   cflag_wr;
                                  
  // -----------------------------
  // Wire declarations
  // -----------------------------
  wire                                  nxt_alu_ex2_clz_sel_sign_count;
  wire                                  nxt_alu_ex2_clz_sel_zero_count;
  wire                                  alu_ex1_extract_valid;
  wire                                  alu_iss_invert_data_a;
  wire                                  alu_iss_invert_data_b;
  wire                                  alu_ex1_zero_sign_extend;
  wire                                  alu_sat_dbl_set_qbit_ex1;
  wire                                  alu_wr_sat_valid;
  wire                                  au_carryin_ex2;
  wire                                  en_alu_pipe_hi_ex1;
  wire                                  en_alu_pipe_lo_ex1;
  wire                                  en_alu_pipe_hi_ex2;
  wire                                  en_alu_pipe_lo_ex2;
  wire                                  en_alu_pipe_hi_wr;
  wire                                  en_alu_pipe_lo_wr;
  wire                                  en_au_ctl_ex1;
  wire                                  en_au_ctl_skew_ex2;
  wire                                  en_au_ctl_noskew_ex2;
  wire                                  c_flag_lu_ex2;
  wire                                  v_flag_lu_ex2;
  wire                                  nxt_alu_valid_ex1;
  wire                                  nxt_alu_valid_ex2;
  wire                                  rrx_bit_ex2;
  wire                                  sel_au_output_ex2;
  wire                                  sel_crc_output_ex2;
  wire                                  sel_clz_output_ex2;
  wire                                  sel_lu_output_ex2;
  wire                                  sel_sat_output_ex2;
  wire                                  sel_msu_output_ex2;
  wire                                  sel_ext_output_ex2;
  wire                                  shift_carry_out_ex1;
  wire                                  c_flag_ex1;
  wire                                  shift_carry_valid_ex1;
  wire                                  c_flag_valid_ex1;
  wire                                  c_flag_au_nclear_ex2;
  wire                                  c_flag_au_nset_ex2;
  wire                                  v_flag_au_nclear_ex2;
  wire                                  v_flag_au_nset_ex2;
  wire                                  z_flag_au_lo_ex2;
  wire                                  z_flag_au_hi_ex2;
  wire                                  z_flag_au_ex2;
  wire                                  z_flag_lu_lo_ex2;
  wire                                  z_flag_lu_hi_ex2;
  wire                                  z_flag_lu_ex2;
  wire                                  n_flag_lu_ex2;
  wire                                  alu_iss_simd_size;
  wire                                  alu_iss_valid_simd;
  wire                                  shift_rrx_ex1;
  wire                                  shift_rrx_for_0_ex1;
  wire                                  gen_sat_overflow_out_ex2;
  wire                                  early_qbit_ex2;
  wire                                  alu_iss_add_sub_x;
  wire                                  alu_ex1_add_sub_x;
  wire                            [5:0] nxt_alu_mskgen_ex1;
  wire [`CA53_ALU_EX1_XTRACT_TYP_W-1:0] alu_ex1_extract_type;
  wire                            [3:0] alu_iss_pipectl;
  wire   [`CA53_ALU_EX1_REV_TYPE_W-1:0] alu_ex1_rev_type;
  wire                            [2:0] shift_op_ex1;
  wire                            [2:0] sel_msk_ex1;
  wire                           [62:0] alu_data_c_ex2;
  wire                           [63:0] alu_data_a_dbl_sat_ex1;
  wire                           [63:0] alu_data_a_rbit_ex1;
  wire                           [31:0] alu_data_a_rbit_32_ex1;
  wire                           [63:0] alu_data_a_rbit_64_ex1;
  wire                           [63:0] alu_data_s_ex2;
  wire                           [63:0] alu_data_simd_sat_wr;
  wire                           [63:0] alu_out_ex2;
  wire                           [63:0] final_alu_out_ex2;
  wire                           [63:0] au_sum_ex1;
  wire                           [63:0] au_sum_ex2;
  wire                           [31:0] crc32_res_ex2;
  wire                            [6:0] clz_out_ex2;
  wire                           [31:0] gen_sat_out_ex2;
  wire                           [63:0] inverted_data_a_ex2;
  wire                           [63:0] inverted_data_b_ex2;
  wire                           [63:0] lu_out_ex1;
  wire                           [63:0] lu_out_ex2;
  wire                           [63:0] msu_out_ex2;
  wire                           [31:0] extracted_data_ex2;
  wire                           [63:0] mask_data_ex1;
  wire                           [63:0] final_alu_data_b_ex1;
  wire                           [63:0] nxt_alu_mask_data_ex2;
  wire                           [63:0] rrxed_data_b_ex2;
  wire                           [63:0] shift_data_out_ex1;
  wire                           [63:0] extracted_data_ex1;
  wire                           [63:0] shift_mask_ex1;
  wire                            [3:0] new_ccflags_lu_ex2;
  wire                            [3:0] new_ccflags_au_nclear_ex2;
  wire                            [3:0] new_ccflags_au_nset_ex2;
  wire                            [3:0] simd_sat_overflow_ex2;
  wire                            [3:0] simd_sat_direction_ex2;
  wire                                  simd_sat_qbit_wr;
  wire                                  alu_ex1_invert_data_a;
  wire                                  alu_ex1_invert_data_b;
  wire                                  sel_lu_flags_ex2;
  wire                                  sel_au_flags_ex2;
  wire                                  sel_a_output_ex2;
  wire                                  alu_valid_ex1_en;
  wire                                  alu_valid_ex2_en;
  wire                                  crc32_valid_ex1;
  wire                                  alu_iss_force_cin;
  wire                                  csel_iss;
  wire                                  csel_ex1;
  wire                                  enable_au_iss;
  wire                                  simd_instr_addsubx_iss;
  wire                                  simd_instr_subaddx_iss;
  wire                                  sel_invert_b_hi_iss;
  wire                                  sel_normal_b_hi_iss;
  wire                                  sel_invert_b_lo_iss;
  wire                                  sel_normal_b_lo_iss;
  wire                                  sel_invert_a_hi_iss;
  wire                                  sel_normal_a_hi_iss;
  wire                                  sel_invert_a_lo_iss;
  wire                                  sel_normal_a_lo_iss;
  wire                                  valid_16_bit_simd_iss;
  wire                                  valid_8_bit_simd_iss;
  wire                                  sub_operation_iss;
  wire                                  cin_ctl_iss;
  wire                                  add_sub_cin_ctl_iss;
  wire                                  au_nout_ex1;
  wire                                  au_nout_ex2;
  wire                            [3:0] au_geflags_ex1;
  wire                            [3:0] new_geflags_ex2;
  wire                                  nxt_sel_invert_b_hi_ex2;
  wire                                  nxt_sel_normal_b_hi_ex2;
  wire                                  nxt_sel_invert_b_lo_ex2;
  wire                                  nxt_sel_normal_b_lo_ex2;
  wire                                  nxt_sel_invert_a_hi_ex2;
  wire                                  nxt_sel_normal_a_hi_ex2;
  wire                                  nxt_sel_invert_a_lo_ex2;
  wire                                  nxt_sel_normal_a_lo_ex2;
  wire                                  nxt_invert_data_b_ex2;
  wire                                  inverted_data_a_top_ex1;
  wire                                  inverted_data_b_top_ex1;
  wire                                  au_c_flag_ex1;
  wire                                  au_v_flag_ex1;
  wire                                  skew_au_op_ex1;
  wire             [`CA53_LU_CTL_W-1:0] nxt_lu_ctl_ex2;
  wire             [`CA53_LU_CTL_W-1:0] lu_op_ex2;
  wire                                  shift_op_lsl_iss;
  wire                                  shift_op_ror_iss;
  wire                                  alu_iss_extract_valid;
  wire                                  shift_op_right_shift_iss;
  wire                                  shift_op_left_shift_iss;
  wire                                  shift_op_extr_instr_iss;
  wire                                  nxt_alu_ex2_valid_simd;
  wire                                  nxt_alu_ex2_no_valid_simd;
  wire                            [2:0] simd_forced_carryin_a_iss;
  wire                            [2:0] simd_forced_carryin_b_iss;
  wire                                  flag_wr_en;
  wire                                  clk_ex1;
  wire                                  clk_ex2;
  wire                                  clk_wr;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Regional clock gates
  // ------------------------------------------------------

  ca53_cell_inter_clkgate u_inter_clkgate_alu_ex1 (
    .clk_i         (clk),
    .clk_enable_i  (raw_alu_valid_iss_i),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_ex1)
  );

  ca53_cell_inter_clkgate u_inter_clkgate_alu_ex2 (
    .clk_i         (clk),
    .clk_enable_i  (alu_valid_ex1),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_ex2)
  );

  ca53_cell_inter_clkgate u_inter_clkgate_alu_wr (
    .clk_i         (clk),
    .clk_enable_i  (alu_valid_ex2),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_wr)
  );

  // ------------------------------------------------------
  // Pipeline valid and enable bits
  // ------------------------------------------------------

  assign nxt_alu_valid_ex1 = alu_valid_iss_i & ~quash_iss_i & ~flush_ret_i;
  assign nxt_alu_valid_ex2 = alu_valid_ex1   & ~quash_ex1_i;

  assign alu_valid_ex1_en  = ~stall_ex1_i;
  assign alu_valid_ex2_en  = ~stall_ex2_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      alu_valid_ex1 <= 1'b0;
    else if (alu_valid_ex1_en)
      alu_valid_ex1 <= nxt_alu_valid_ex1;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      alu_valid_ex2 <= 1'b0;
    else if (alu_valid_ex2_en)
      alu_valid_ex2 <= nxt_alu_valid_ex2;

  assign en_alu_pipe_hi_ex1 = alu_valid_iss_i & ~stall_wr_i & ctl_64bit_op_iss_i;
  assign en_alu_pipe_lo_ex1 = alu_valid_iss_i & ~stall_wr_i;
  assign en_alu_pipe_hi_ex2 = alu_valid_ex1   & ~stall_wr_i & ctl_64bit_op_ex1;
  assign en_alu_pipe_lo_ex2 = alu_valid_ex1   & ~stall_wr_i;
  assign en_alu_pipe_hi_wr  = alu_valid_ex2   & ~stall_wr_i & ctl_64bit_op_ex2;
  assign en_alu_pipe_lo_wr  = alu_valid_ex2   & ~stall_wr_i;

  // Local copy of the Wr C-Flag as it's needed early in the Ex2 stage and therefore it's
  // more efficient to have a copy per-ALU pipeline rather than force the pipe-0/pipe-1 ALUs
  // to be clustered around the centralised flag logic in the DP module.  While it's a Wr
  // stage signal it's consumed in Ex2 and therefore only needs to be clocked when a new
  // operation is clocked in to Ex2.
  //
  // Also capture the GE flags locally as well.  Not so much because they are needed for timing
  // but because it ensures the register will be RTL clock gated rather than use a recirculating
  // mux which would add more gates to the Ex2 C-Flag path.
  assign flag_wr_en = ~stall_wr_i;

  always @(posedge clk_ex2)
    if (flag_wr_en) begin
      geflags_wr <= geflags_ex2_i;
      cflag_wr   <= cflag_ex2_i;
    end

  // ------------------------------------------------------
  // Early decode of shifter control signals
  // ------------------------------------------------------

  // Shift right / left decode
  assign shift_op_right_shift_iss = ((alu_ex1_ctl_iss_i[`CA53_ALU_EX1_CTL_SHIFT_OP_BITS] == `CA53_SHIFT_OP_EXTR) |
                                     (alu_ex1_ctl_iss_i[`CA53_ALU_EX1_CTL_SHIFT_OP_BITS] == `CA53_SHIFT_OP_LSR)  |
                                     (alu_ex1_ctl_iss_i[`CA53_ALU_EX1_CTL_SHIFT_OP_BITS] == `CA53_SHIFT_OP_ASR)  |
                                     (alu_ex1_ctl_iss_i[`CA53_ALU_EX1_CTL_SHIFT_OP_BITS] == `CA53_SHIFT_OP_ROR));

  assign shift_op_left_shift_iss  =  (alu_ex1_ctl_iss_i[`CA53_ALU_EX1_CTL_SHIFT_OP_BITS] == `CA53_SHIFT_OP_LSL);

  // Extr operation
  assign shift_op_extr_instr_iss = alu_ex1_ctl_iss_i[`CA53_ALU_EX1_CTL_SHIFT_OP_BITS] == `CA53_SHIFT_OP_EXTR;

  // ------------------------------------------------------
  // Early decode of Arithmetic Unit control signals
  // ------------------------------------------------------
  // Some of the control signals used by the AU are timing critical and
  // so are decoded in Iss and pipelined to be used in Ex1/Ex2 by each
  // AU.

  // Indicate if we are doing a valid SIMD operation
  assign alu_iss_valid_simd     = alu_ex2_ctl_iss_i[`CA53_ALU_EX2_CTL_VALID_SIMD_BITS];

  // Indicate the size of the SIMD operation
  assign alu_iss_simd_size      = alu_ex2_ctl_iss_i[`CA53_ALU_EX2_CTL_SIMD_SIZE_BITS];

  // Indicate if the carry bit should be forced to 1
  // - Used on CSEL/CCMP operations which need to negate the B operand
  // - Overloads COMP_SHF_A bit of control bus
  assign alu_iss_force_cin      = (alu_iss_pipectl == `CA53_LU_CTL_CSEL) &
                                  alu_ex2_ctl_iss_i[`CA53_ALU_EX2_CTL_OP_COMP_SHF_A_BIT];

  // Indicate if doing an ADDSUBX or SUBADDX or other SIMD operation
  assign alu_iss_add_sub_x      = alu_ex2_ctl_iss_i[`CA53_ALU_EX2_CTL_SIMD_ADD_SUB_X_BITS];

  // Control signals for subtract/carryin
  assign alu_iss_pipectl        = alu_ex2_ctl_iss_i[`CA53_ALU_EX2_CTL_LU_CTL_BITS];
                               
  // AU will be used           
  assign enable_au_iss          = (alu_iss_pipectl == `CA53_LU_CTL_ADD) |
                                  (alu_iss_pipectl == `CA53_LU_CTL_SUB) |
                                  (alu_iss_pipectl == `CA53_LU_CTL_ADC) |
                                  (alu_iss_pipectl == `CA53_LU_CTL_SBC) |
                                  (alu_iss_pipectl == `CA53_LU_CTL_CSEL);
                               
  assign csel_iss               = (alu_iss_pipectl == `CA53_LU_CTL_CSEL) & ~alu_ex2_ctl_iss_i[`CA53_ALU_EX2_CTL_CCMP_BIT];

  assign simd_instr_addsubx_iss = alu_iss_add_sub_x & (alu_iss_pipectl == `CA53_LU_CTL_SUB);
  assign simd_instr_subaddx_iss = alu_iss_add_sub_x & (alu_iss_pipectl == `CA53_LU_CTL_ADD);

  // Find out if we are doing 8-bit/16-bit SIMD and not SUBADDX/ADDSUBX
  assign valid_16_bit_simd_iss  = enable_au_iss &  alu_iss_simd_size & ~alu_iss_add_sub_x;
  assign valid_8_bit_simd_iss   = enable_au_iss & ~alu_iss_simd_size &  alu_iss_valid_simd;

  // Find out if we are doing a subtract
  assign sub_operation_iss      = (alu_iss_pipectl == `CA53_LU_CTL_SUB) & ~alu_iss_add_sub_x;

  // Create carry in control signals
  assign cin_ctl_iss            = (alu_iss_pipectl == `CA53_LU_CTL_ADC) |    // For ADC/SBC/RSC operations
                                  (alu_iss_pipectl == `CA53_LU_CTL_SBC);     // carry comes from APSR
                               
  assign add_sub_cin_ctl_iss    = (alu_iss_pipectl == `CA53_LU_CTL_SUB) |    // Carry in if SUB
                                  alu_iss_force_cin;                         // CSEL/CCMP

  // AU data selection mux controls
  // - Indicate if we are inverting the ALU A Operand
  // - CSEL and CCMP instructions overload this control bit to indicate when
  // to set carry in bit to add, so force to zero on those instructions.
  assign alu_iss_invert_data_a = alu_ex2_ctl_iss_i[`CA53_ALU_EX2_CTL_OP_COMP_SHF_A_BIT] &
                                 ~(alu_iss_pipectl == `CA53_LU_CTL_CSEL);

  // - Indicate if we are inverting the ALU B Operand
  assign alu_iss_invert_data_b = alu_ex2_ctl_iss_i[`CA53_ALU_EX2_CTL_OP_COMP_SHF_B_BIT];

  // - Data gate Ex1 skewed AU if not doing skewed AU operation
  assign sel_invert_b_hi_iss    =  alu_iss_invert_data_b & enable_au_iss & use_ex1_alu_iss_i & ctl_64bit_op_iss_i;
  assign sel_normal_b_hi_iss    = ~alu_iss_invert_data_b & enable_au_iss & use_ex1_alu_iss_i & ctl_64bit_op_iss_i & ~alu_iss_add_sub_x;
  assign sel_invert_b_lo_iss    =  alu_iss_invert_data_b & enable_au_iss & use_ex1_alu_iss_i;
  assign sel_normal_b_lo_iss    = ~alu_iss_invert_data_b & enable_au_iss & use_ex1_alu_iss_i &                      ~alu_iss_add_sub_x;
  assign sel_invert_a_hi_iss    =  alu_iss_invert_data_a & enable_au_iss & use_ex1_alu_iss_i & ~csel_iss & ctl_64bit_op_iss_i;
  assign sel_normal_a_hi_iss    = ~alu_iss_invert_data_a & enable_au_iss & use_ex1_alu_iss_i & ~csel_iss & ctl_64bit_op_iss_i;
  assign sel_invert_a_lo_iss    =  alu_iss_invert_data_a & enable_au_iss & use_ex1_alu_iss_i & ~csel_iss;
  assign sel_normal_a_lo_iss    = ~alu_iss_invert_data_a & enable_au_iss & use_ex1_alu_iss_i & ~csel_iss;

  // SIMD carry control bit generation
  //
  // Interleave SIMD control bits between the operands.  These control bits either
  // kill a carry (a=0, b=0), propagate a carry (a=1, b=0) or create a carry
  // (a=1, b=1).
  //
  //                A-Bot A-Mid A-Top    B-Bot B-Mid B-Top
  // 32-bit Add       1     1     1        0     0     0
  // 16-bit Add       1     0     1        0     0     0
  // 8-bit Add        0     0     0        0     0     0
  //
  // 32-bit Sub       1     1     1        0     0     0
  // 16-bit Sub       1     1     1        0     1     0
  // 8-bit Sub        1     1     1        1     1     1
  //
  // ADDSUBX          1     0     1        0     0     0 (31:16=Add, 15:0=Sub)
  // SUBADDX          1     1     1        0     1     0 (31:16=Sub, 15:0=Add)

  // Create SIMD bits
  assign simd_forced_carryin_a_iss[0] = ~(valid_8_bit_simd_iss   & ~sub_operation_iss);
  assign simd_forced_carryin_a_iss[1] = ~((valid_8_bit_simd_iss  & ~sub_operation_iss) |
                                          (valid_16_bit_simd_iss & ~sub_operation_iss) |
                                          simd_instr_addsubx_iss);
  assign simd_forced_carryin_a_iss[2] = ~(valid_8_bit_simd_iss   & ~sub_operation_iss);

  assign simd_forced_carryin_b_iss[0] = (valid_8_bit_simd_iss    &  sub_operation_iss);
  assign simd_forced_carryin_b_iss[1] = ((valid_8_bit_simd_iss   &  sub_operation_iss) |
                                         (valid_16_bit_simd_iss  &  sub_operation_iss) |
                                         simd_instr_subaddx_iss);
  assign simd_forced_carryin_b_iss[2] = (valid_8_bit_simd_iss    &  sub_operation_iss);

  // ------------------------------------------------------
  // Iss -> Ex1 stage registers
  // ------------------------------------------------------

  assign nxt_alu_mskgen_ex1 = ctl_64bit_op_iss_i ? alu_mskgen_iss_i[5:0]
                                                 : {1'b0, alu_mskgen_iss_i[4:0]};

  always @(posedge clk_ex1)
    if (en_alu_pipe_lo_ex1) begin
      alu_data_a_ex1[31:0]      <= alu_data_a_iss_i[31:0];
      alu_data_b_ex1[31:0]      <= alu_data_b_iss_i[31:0];
      alu_data_c_ex1[ 7:0]      <= alu_data_c_iss_i[7:0];
      alu_mskgen_ex1            <= nxt_alu_mskgen_ex1[5:0];
      alu_imm_sel_c_ex1         <= alu_imm_sel_c_iss_i;
      alu_ex1_ctl_ex1           <= alu_ex1_ctl_iss_i;
      alu_ex2_ctl_ex1           <= alu_ex2_ctl_iss_i;
      alu_wr_ctl_ex1            <= alu_wr_ctl_iss_i;
      ctl_64bit_op_ex1          <= ctl_64bit_op_iss_i;
      shift_op_right_shift_ex1  <= shift_op_right_shift_iss;
      shift_op_left_shift_ex1   <= shift_op_left_shift_iss;
      shift_op_extr_instr_ex1   <= shift_op_extr_instr_iss;
      skew_ex1                  <= use_ex1_alu_iss_i;
      enable_au_ex1             <= enable_au_iss;
      au_sel_normal_a_hi_ex1    <= sel_normal_a_hi_iss;
      au_sel_invert_a_hi_ex1    <= sel_invert_a_hi_iss;
      au_sel_normal_a_lo_ex1    <= sel_normal_a_lo_iss;
      au_sel_invert_a_lo_ex1    <= sel_invert_a_lo_iss;
      au_sel_normal_b_hi_ex1    <= sel_normal_b_hi_iss;
      au_sel_invert_b_hi_ex1    <= sel_invert_b_hi_iss;
      au_sel_normal_b_lo_ex1    <= sel_normal_b_lo_iss;
      au_sel_invert_b_lo_ex1    <= sel_invert_b_lo_iss;
      aarch64_state_ex1         <= aarch64_state_i;
    end

  always @(posedge clk_ex1)
    if (en_alu_pipe_hi_ex1) begin
      alu_data_a_ex1[63:32]     <= alu_data_a_iss_i[63:32];
      alu_data_b_ex1[63:32]     <= alu_data_b_iss_i[63:32];
    end

  assign en_au_ctl_ex1 = en_alu_pipe_lo_ex1 & enable_au_iss;

  always @(posedge clk_ex1)
    if (en_au_ctl_ex1) begin
      au_cin_ctl_ex1               <= cin_ctl_iss;
      au_add_sub_cin_ctl_ex1       <= add_sub_cin_ctl_iss;
      au_simd_instr_addsubx_ex1    <= simd_instr_addsubx_iss;
      au_simd_instr_subaddx_ex1    <= simd_instr_subaddx_iss;
      au_valid_8_bit_simd_ex1      <= valid_8_bit_simd_iss;
      au_sub_operation_ex1         <= sub_operation_iss;
      au_simd_forced_carryin_a_ex1 <= simd_forced_carryin_a_iss[2:0];
      au_simd_forced_carryin_b_ex1 <= simd_forced_carryin_b_iss[2:0];
    end

  // ------------------------------------------------------
  // Ex1 stage RBIT units
  // ------------------------------------------------------

  ca53dpu_alu_rbit u_alu_rbit (
    // Inputs
    .alu_data_a_ex1_i      (alu_data_a_ex1[31:0]),
    // Outputs
    .alu_data_a_rbit_ex1_o (alu_data_a_rbit_32_ex1[31:0])
  );

  ca53dpu_alu_rbit_64 u_alu_rbit_64 (
    // Inputs
    .alu_data_a_ex1_i      (alu_data_a_ex1),
    // Outputs
    .alu_data_a_rbit_ex1_o (alu_data_a_rbit_64_ex1[63:0])
  );

  assign alu_data_a_rbit_ex1 = ctl_64bit_op_ex1 ? alu_data_a_rbit_64_ex1 : {{32{1'b0}}, alu_data_a_rbit_32_ex1};

  // ------------------------------------------------------
  // Ex1 stage SAT * 2 unit
  // ------------------------------------------------------

  ca53dpu_alu_sat_dbl u_alu_sat_dbl (
    // Inputs
    .alu_data_a_ex1_i           (alu_data_a_ex1),
    .ctl_64bit_op_ex1_i         (ctl_64bit_op_ex1),
    // Outputs
    .alu_data_a_dbl_sat_ex1_o   (alu_data_a_dbl_sat_ex1),
    .alu_sat_dbl_set_qbit_ex1_o (alu_sat_dbl_set_qbit_ex1)
  );

  // ------------------------------------------------------
  // Ex1 stage barrel shifter unit
  // ------------------------------------------------------

  // Which of LSL, LSR, ASR, ROR operation we are going to do
  assign shift_op_ex1 = alu_ex1_ctl_ex1[`CA53_ALU_EX1_CTL_SHIFT_OP_BITS];

  // Doing an RRX type of rotate
  assign shift_rrx_for_0_ex1 = alu_ex1_ctl_ex1[`CA53_ALU_EX1_CTL_SHIFT_RRX_FOR_0_BITS];

  ca53dpu_alu_shift u_alu_shift (
    // Inputs
    .aarch64_state_ex1_i        (aarch64_state_ex1),
    .alu_data_a_ex1_i           (alu_data_a_ex1[63:0]),
    .alu_data_b_ex1_i           (alu_data_b_ex1[63:0]),
    .alu_data_c_ex1_i           (alu_data_c_ex1[7:0]),
    .shift_op_right_shift_ex1_i (shift_op_right_shift_ex1),
    .shift_op_left_shift_ex1_i  (shift_op_left_shift_ex1),
    .shift_op_extr_instr_ex1_i  (shift_op_extr_instr_ex1),
    .shift_op_ex1_i             (shift_op_ex1[2:0]),
    .shift_rrx_for_0_ex1_i      (shift_rrx_for_0_ex1),
    .ctl_64bit_op_ex1_i         (ctl_64bit_op_ex1),
    // Outputs
    .shift_rrx_ex1_o            (shift_rrx_ex1),
    .shift_data_out_ex1_o       (shift_data_out_ex1[63:0]),
    .shift_carry_out_ex1_o      (shift_carry_out_ex1),
    .shift_carry_valid_ex1_o    (shift_carry_valid_ex1),
    .shift_mask_ex1_o           (shift_mask_ex1[63:0])
  );

  // ------------------------------------------------------
  // Ex1 stage extract/sign extend unit
  // ------------------------------------------------------

  // Which of LSL or ROR operation we are going to do
  assign shift_op_lsl_iss = alu_ex1_ctl_iss_i[`CA53_ALU_EX1_CTL_SHIFT_OP_BITS] == `CA53_SHIFT_OP_LSL;
  assign shift_op_ror_iss = alu_ex1_ctl_iss_i[`CA53_ALU_EX1_CTL_SHIFT_OP_BITS] == `CA53_SHIFT_OP_ROR;

  // XTEND and XTRACT instruction require a byte or hword or 2 bytes to be extracted
  assign alu_iss_extract_valid = alu_ex1_ctl_iss_i[`CA53_ALU_EX1_XTRCT_VAL_BITS];
  assign alu_ex1_extract_valid = alu_ex1_ctl_ex1[`CA53_ALU_EX1_XTRCT_VAL_BITS];

  // XTEND and XTRACt instructions require zero or sign extension
  assign alu_ex1_zero_sign_extend = alu_ex1_ctl_ex1[`CA53_ALU_EX1_SIGN_XTEND_BITS];

  // Indicate whether we need to extract byte, hword or two bytes
  assign alu_ex1_extract_type = alu_ex1_ctl_ex1[`CA53_ALU_EX1_XTRACT_TYP_BITS];

  ca53dpu_alu_extract_64 u_alu_extract_ex1 (
    // Inputs
    .clk_ex1                    (clk_ex1),
    .reset_n                    (reset_n),
    .en_alu_pipe_lo_ex1_i       (en_alu_pipe_lo_ex1),
    .alu_iss_extract_valid_i    (alu_iss_extract_valid),
    .alu_imm_shift_iss_i        (alu_imm_shift_iss_i[4:0]),
    .shift_op_lsl_iss_i         (shift_op_lsl_iss),
    .shift_op_ror_iss_i         (shift_op_ror_iss),
    .alu_ex1_zero_sign_extend_i (alu_ex1_zero_sign_extend),
    .alu_ex1_extract_type_i     (alu_ex1_extract_type[(`CA53_ALU_EX1_XTRACT_TYP_W-1):0]),
    .alu_data_b_ex1_i           (alu_data_b_ex1[63:0]),
    .shift_mask_ex1_i           (shift_mask_ex1[63:0]),
    // Outputs
    .extracted_data_ex1_o       (extracted_data_ex1[63:0]));

  // ------------------------------------------------------
  // Ex1 stage skewed logic unit
  // ------------------------------------------------------
  
  ca53dpu_alu_lu u_alu_lu_ex1 (
    // Inputs
    .lu_ctl_i   (alu_ex2_ctl_ex1[`CA53_ALU_EX2_CTL_LU_CTL_BITS]),
    .data_a_i   (alu_data_a_ex1[63:0]),
    .data_b_i   (alu_data_b_ex1[63:0]),
    // Outputs
    .lu_out_o   (lu_out_ex1[63:0])
  );

  // ------------------------------------------------------
  // Ex1 stage skewed arithmetic unit
  // ------------------------------------------------------

  ca53dpu_alu_au u_alu_au_ex1 (
    // Inputs
    .alu_data_a_i               (alu_data_a_ex1[63:0]),
    .alu_data_b_i               (alu_data_b_ex1[63:0]),
    .ctl_64bit_op_i             (ctl_64bit_op_ex1),
    .au_shift_rrx_i             (1'b0), // Flag reading operations never skew
    .cflag_wr_i                 (1'b0),
    .au_cin_ctl_i               (1'b0),
    .au_add_sub_cin_ctl_i       (au_add_sub_cin_ctl_ex1),
    .au_simd_instr_addsubx_i    (au_simd_instr_addsubx_ex1),
    .au_simd_instr_subaddx_i    (au_simd_instr_subaddx_ex1),
    .au_sel_normal_a_hi_i       (au_sel_normal_a_hi_ex1),
    .au_sel_invert_a_hi_i       (au_sel_invert_a_hi_ex1),
    .au_sel_normal_a_lo_i       (au_sel_normal_a_lo_ex1),
    .au_sel_invert_a_lo_i       (au_sel_invert_a_lo_ex1),
    .au_sel_normal_b_hi_i       (au_sel_normal_b_hi_ex1),
    .au_sel_invert_b_hi_i       (au_sel_invert_b_hi_ex1),
    .au_sel_normal_b_lo_i       (au_sel_normal_b_lo_ex1),
    .au_sel_invert_b_lo_i       (au_sel_invert_b_lo_ex1),
    .au_valid_8_bit_simd_i      (au_valid_8_bit_simd_ex1),
    .au_simd_forced_carryin_a_i (au_simd_forced_carryin_a_ex1[2:0]),
    .au_simd_forced_carryin_b_i (au_simd_forced_carryin_b_ex1[2:0]),
    .au_sub_operation_i         (au_sub_operation_ex1),
    .au_valid_simd_i            (alu_ex2_ctl_ex1[`CA53_ALU_EX2_CTL_VALID_SIMD_BITS]),
    .au_simd_size_i             (alu_ex2_ctl_ex1[`CA53_ALU_EX2_CTL_SIMD_SIZE_BITS]),
    .au_halving_i               (alu_ex2_ctl_ex1[`CA53_ALU_EX2_CTL_HALVING_BITS]),
    .au_simd_sign_arth_i        (alu_ex2_ctl_ex1[`CA53_ALU_EX2_SIMD_SIGN_ARTH_BITS]),
    // Outputs               
    .au_nout_o                  (au_nout_ex1),
    .au_sum_o                   (au_sum_ex1[63:0]),
    .au_carryin_o               (), // Used for generating Z flag, but reuse LU generation in Ex2
    .au_new_geflags_o           (au_geflags_ex1),
    .au_simd_sat_overflow_o     (), // Only used by saturating, which cannot skew
    .au_simd_sat_direction_o    ()  // " "
  );

  // AU flag generation
  // - For skewed LU operations, the Ex2 stage LU flag generation is reused, as
  // skewed operations are converted to logical ORR operations in Ex2. This
  // means that the N and Z flags for skewed AU operations can also be
  // calculated in Ex2, as these will be correctly generated by the ORR.
  // Therefore, in Ex1 we just need to generate the C and V flags for AU
  // operations.
  assign inverted_data_a_top_ex1 = alu_ex1_invert_data_a ^ (ctl_64bit_op_ex1 ? alu_data_a_ex1[63] : alu_data_a_ex1[31]);
  assign inverted_data_b_top_ex1 = alu_ex1_invert_data_b ^ (ctl_64bit_op_ex1 ? alu_data_b_ex1[63] : alu_data_b_ex1[31]);

  assign au_c_flag_ex1 = au_nout_ex1 ? (inverted_data_a_top_ex1 & inverted_data_b_top_ex1)
                                     : (inverted_data_a_top_ex1 | inverted_data_b_top_ex1);

  // Check the sign bit of both operands and the sign bit of the result. If
  // the sign bits of both operands are the same, but the sign bit of the
  // result is opposite to the operands, then an overflow has occured.
  assign au_v_flag_ex1 = au_nout_ex1 ? (~inverted_data_a_top_ex1 & ~inverted_data_b_top_ex1)
                                     : ( inverted_data_a_top_ex1 &  inverted_data_b_top_ex1);

  // The C flag can come from shift operations as well as skewed AU operations.
  assign c_flag_valid_ex1 = skew_au_op_ex1 | alu_imm_sel_c_ex1 | (shift_carry_valid_ex1 & ~aarch64_state_ex1);  // Shift C flag not valid in AA64
  assign c_flag_ex1       = skew_au_op_ex1    ? au_c_flag_ex1       : // Skewed AU operation can do imm shift, and AU C flag has priority
                            alu_imm_sel_c_ex1 ? alu_data_b_ex1[31]  : // C flag for shifted immediate
                                                shift_carry_out_ex1;

  // ------------------------------------------------------
  // Ex1 stage mask generator unit
  // ------------------------------------------------------

  ca53dpu_alu_maskgen u_alu_maskgen (
    // Inputs
    .mask_gen_data_ex1_i  (alu_mskgen_ex1[5:0]),
    // Outputs
    .mask_data_ex1_o      (mask_data_ex1[63:0]));

  // The mask generated by the alu_maskgen block may need to be
  // combined with the mask generated in the alu_shift block for
  // certain bitfield instructions. This is done here.
  assign sel_msk_ex1 = alu_ex1_ctl_ex1[`CA53_ALU_EX1_MASK_SEL_BITS];

  // MOVW instructions insert a 16-bit immediate at a 16-bit aligned position
  // within a 64-bit value.
  always @*
    case (alu_data_c_ex1[5:0])
      `CA53_IMM_LSL_0 : movw_mask_ex1 = 64'h0000_0000_0000_FFFF;
      `CA53_IMM_LSL_16: movw_mask_ex1 = 64'h0000_0000_FFFF_0000;
      `CA53_IMM_LSL_32: movw_mask_ex1 = 64'h0000_FFFF_0000_0000;
      `CA53_IMM_LSL_48: movw_mask_ex1 = 64'hFFFF_0000_0000_0000;
      default         : movw_mask_ex1 = 64'hxxxx_xxxx_xxxx_xxxx;
    endcase

  assign nxt_alu_mask_data_ex2 = ({64{sel_msk_ex1 == `CA53_MASK_COMB}} & mask_data_ex1 & ~shift_mask_ex1)            |
                                 ({64{sel_msk_ex1 == `CA53_MASK_SNGL}} & mask_data_ex1)                              |
                                 ({64{sel_msk_ex1 == `CA53_MASK_TOP }} & 64'h0000_0000_FFFF_0000)                    |
                                 ({64{sel_msk_ex1 == `CA53_MASK_BOT }} & 64'h0000_0000_0000_FFFF)                    |
                                 ({64{sel_msk_ex1 == `CA53_MASK_C   }} & {{56{1'b0}}, alu_data_c_ex1[7:0]})          |
                                 ({64{sel_msk_ex1 == `CA53_MASK_MOVW}} & movw_mask_ex1);

  // ------------------------------------------------------
  // Ex1 stage muxing for A operand
  // ------------------------------------------------------
  // Select between different Ex1 A results, and perform reversing of operand
  // for REV instructions.
  assign alu_ex1_rev_type = alu_ex1_ctl_ex1[`CA53_ALU_EX1_REV_TYPE_BITS];

  always @* begin
    nxt_alu_sat_dbl_set_qbit_ex2 = 1'b0;
    case (alu_ex1_rev_type)
      `CA53_REV_MUX_NORMAL  : final_alu_data_a_ex1[63:0] = alu_data_a_ex1[63:0];
      // REV implements REV32 in AArch64
      `CA53_REV_MUX_REV     : final_alu_data_a_ex1[63:0] = {alu_data_a_ex1[39:32],
                                                            alu_data_a_ex1[47:40],
                                                            alu_data_a_ex1[55:48],
                                                            alu_data_a_ex1[63:56],
                                                            alu_data_a_ex1[7:0],
                                                            alu_data_a_ex1[15:8],
                                                            alu_data_a_ex1[23:16],
                                                            alu_data_a_ex1[31:24]};
      `CA53_REV_MUX_REV16   : final_alu_data_a_ex1[63:0] = {alu_data_a_ex1[55:48],
                                                            alu_data_a_ex1[63:56],
                                                            alu_data_a_ex1[39:32],
                                                            alu_data_a_ex1[47:40],
                                                            alu_data_a_ex1[23:16],
                                                            alu_data_a_ex1[31:24],
                                                            alu_data_a_ex1[7:0],
                                                            alu_data_a_ex1[15:8]};
      // Used for REV of 64bit registers in AArch64
      `CA53_REV_MUX_REVSH   : final_alu_data_a_ex1[63:0] = ctl_64bit_op_ex1 ? {alu_data_a_ex1[7:0],
                                                                               alu_data_a_ex1[15:8],
                                                                               alu_data_a_ex1[23:16],
                                                                               alu_data_a_ex1[31:24],
                                                                               alu_data_a_ex1[39:32],
                                                                               alu_data_a_ex1[47:40],
                                                                               alu_data_a_ex1[55:48],
                                                                               alu_data_a_ex1[63:56]}
                                                                            : {32'h0000_0000,
                                                                               {16{alu_data_a_ex1[7]}},
                                                                               alu_data_a_ex1[7:0],
                                                                               alu_data_a_ex1[15:8]};
      `CA53_REV_MUX_RBIT    : final_alu_data_a_ex1[63:0] = alu_data_a_rbit_ex1[63:0];
      `CA53_REV_MUX_SAT_DBL : begin
                                final_alu_data_a_ex1[63:0]    = alu_data_a_dbl_sat_ex1[63:0];
                                nxt_alu_sat_dbl_set_qbit_ex2  = alu_sat_dbl_set_qbit_ex1;
                              end
      `CA53_REV_MUX_ZERO    : final_alu_data_a_ex1[63:0] = {64{1'b0}};
      default               : begin
                                final_alu_data_a_ex1[63:0]    = {64{1'bx}};
                                nxt_alu_sat_dbl_set_qbit_ex2  = 1'bx;
                              end
    endcase
  end

  // ------------------------------------------------------
  // Ex1 stage muxing for B operand
  // ------------------------------------------------------
  // Select between the skewed AU and LU, the Ex1 stage extration logic and the
  // shifter. Note that cannot skew a shift or extract operation.

  assign final_alu_data_b_ex1 = ({64{skew_ex1 &  enable_au_ex1          }} & au_sum_ex1)          |
                                ({64{skew_ex1 & ~enable_au_ex1          }} & lu_out_ex1)          |
                                ({64{alu_ex1_extract_valid              }} & extracted_data_ex1)  |
                                ({64{~(skew_ex1 | alu_ex1_extract_valid)}} & shift_data_out_ex1);

  // ------------------------------------------------------
  // Ex1 stage A-operand forwarding
  // ------------------------------------------------------

  always @*
    case (alu_a_fwd_ex1_i)
      `CA53_FWD_W0:       nxt_alu_data_a_ex2 = rf_wr_data_w0_wr_i;
      `CA53_FWD_W1:       nxt_alu_data_a_ex2 = rf_wr_data_w1_wr_i;
      `CA53_FWD_W2:       nxt_alu_data_a_ex2 = rf_wr_data_w2_wr_i;
      `CA53_FWD_ALU0_EX2: nxt_alu_data_a_ex2 = alu0_fwd_data_ex2_i;
      `CA53_FWD_ALU1_EX2: nxt_alu_data_a_ex2 = alu1_fwd_data_ex2_i;
      `CA53_FWD_ALU0_EX1: if (ALU_SLOT_1)
                            nxt_alu_data_a_ex2 = alu0_fwd_data_ex1_i;
                          else
                            nxt_alu_data_a_ex2 = {64{1'bx}};
      `CA53_FWD_NULL:     nxt_alu_data_a_ex2 = final_alu_data_a_ex1;
      default:            nxt_alu_data_a_ex2 = {64{1'bx}};
    endcase

  // ------------------------------------------------------
  // Ex1 stage B-operand forwarding
  // ------------------------------------------------------

  always @*
    case (alu_b_fwd_ex1_i)
      `CA53_FWD_W0:       nxt_alu_data_b_ex2 = rf_wr_data_w0_wr_i;
      `CA53_FWD_W1:       nxt_alu_data_b_ex2 = rf_wr_data_w1_wr_i;
      `CA53_FWD_W2:       nxt_alu_data_b_ex2 = rf_wr_data_w2_wr_i;
      `CA53_FWD_ALU0_EX2: nxt_alu_data_b_ex2 = alu0_fwd_data_ex2_i;
      `CA53_FWD_ALU1_EX2: nxt_alu_data_b_ex2 = alu1_fwd_data_ex2_i;
      `CA53_FWD_ALU0_EX1: if (ALU_SLOT_1)
                            nxt_alu_data_b_ex2 = alu0_fwd_data_ex1_i;
                          else
                            nxt_alu_data_b_ex2 = {64{1'bx}};
      `CA53_FWD_NULL:     nxt_alu_data_b_ex2 = final_alu_data_b_ex1;
      default:            nxt_alu_data_b_ex2 = {64{1'bx}};
    endcase

  // ------------------------------------------------------
  // Ex1 -> Ex2 stage registers
  // ------------------------------------------------------

  // AU data selection mux controls
  assign alu_ex1_invert_data_a = alu_ex2_ctl_ex1[`CA53_ALU_EX2_CTL_OP_COMP_SHF_A_BIT] & ~(alu_ex2_ctl_ex1[`CA53_ALU_EX2_CTL_LU_CTL_BITS] == `CA53_LU_CTL_CSEL);
  assign alu_ex1_invert_data_b = alu_ex2_ctl_ex1[`CA53_ALU_EX2_CTL_OP_COMP_SHF_B_BIT];
  assign alu_ex1_add_sub_x     = alu_ex2_ctl_ex1[`CA53_ALU_EX2_CTL_SIMD_ADD_SUB_X_BITS];
  assign csel_ex1              = (alu_ex2_ctl_ex1[`CA53_ALU_EX2_CTL_LU_CTL_BITS] == `CA53_LU_CTL_CSEL) & ~alu_ex2_ctl_ex1[`CA53_ALU_EX2_CTL_CCMP_BIT];

  // Register duplication to ease timing paths due to fanout in Ex2
  assign nxt_alu_ex2_valid_simd    =  alu_ex2_ctl_ex1[`CA53_ALU_EX2_CTL_VALID_SIMD_BITS];
  assign nxt_alu_ex2_no_valid_simd = ~alu_ex2_ctl_ex1[`CA53_ALU_EX2_CTL_VALID_SIMD_BITS];

  // - Data gate Ex2 AU if not doing Ex2 AU operation
  assign nxt_sel_invert_b_hi_ex2 =  alu_ex1_invert_data_b & enable_au_ex1 & ~skew_ex1 & ctl_64bit_op_ex1;
  assign nxt_sel_normal_b_hi_ex2 = ~alu_ex1_invert_data_b & enable_au_ex1 & ~skew_ex1 & ctl_64bit_op_ex1 & ~alu_ex1_add_sub_x;
  assign nxt_sel_invert_b_lo_ex2 =  alu_ex1_invert_data_b & enable_au_ex1 & ~skew_ex1;
  assign nxt_sel_normal_b_lo_ex2 = ~alu_ex1_invert_data_b & enable_au_ex1 & ~skew_ex1 &                    ~alu_ex1_add_sub_x;
  assign nxt_sel_invert_a_hi_ex2 =  alu_ex1_invert_data_a & enable_au_ex1 & ~skew_ex1 & ~csel_ex1 & ctl_64bit_op_ex1;
  assign nxt_sel_normal_a_hi_ex2 = ~alu_ex1_invert_data_a & enable_au_ex1 & ~skew_ex1 & ~csel_ex1 & ctl_64bit_op_ex1;
  assign nxt_sel_invert_a_lo_ex2 =  alu_ex1_invert_data_a & enable_au_ex1 & ~skew_ex1 & ~csel_ex1;
  assign nxt_sel_normal_a_lo_ex2 = ~alu_ex1_invert_data_a & enable_au_ex1 & ~skew_ex1 & ~csel_ex1;

  // - Do not invert B operation in Ex2 if skewed (as used for forwarding and B
  // operand has result of operation).
  assign nxt_invert_data_b_ex2   = alu_ex1_invert_data_b & ~skew_ex1;

  always @(posedge clk_ex2 or negedge reset_n)
    if (~reset_n) begin
      invert_data_a_ex2[0]    <= 1'b0;
      invert_data_a_ex2[1]    <= 1'b1; // Opposing reset value to invert_data_a_ex2[0] to prevent synthesis optimising away
      invert_data_b_ex2[0]    <= 1'b0;
      invert_data_b_ex2[1]    <= 1'b1; // Opposing reset value to invert_data_b_ex2[0] to prevent synthesis optimising away
    end else if (en_alu_pipe_lo_ex2) begin
      invert_data_a_ex2[0]    <= alu_ex1_invert_data_a;
      invert_data_a_ex2[1]    <= alu_ex1_invert_data_a;
      invert_data_b_ex2[0]    <= nxt_invert_data_b_ex2;
      invert_data_b_ex2[1]    <= nxt_invert_data_b_ex2;
    end

  // Because operation changed between Ex1 and Ex2, need to pipeline whether
  // skewed operation is AU or LU from Ex1.
  assign skew_au_op_ex1 = skew_ex1 & enable_au_ex1;
  assign nxt_lu_ctl_ex2 = skew_ex1 ? `CA53_LU_CTL_ORR : alu_ex2_ctl_ex1[`CA53_ALU_EX2_CTL_LU_CTL_BITS];

  // Gate both CLZ data select mux controls when not using CLZ
  assign nxt_alu_ex2_clz_sel_sign_count = (nxt_lu_ctl_ex2 == `CA53_LU_CTL_CLZ) &  alu_ex1_zero_sign_extend;
  assign nxt_alu_ex2_clz_sel_zero_count = (nxt_lu_ctl_ex2 == `CA53_LU_CTL_CLZ) & ~alu_ex1_zero_sign_extend;

  always @(posedge clk_ex2)
    if (en_alu_pipe_lo_ex2) begin
      alu_data_a_ex2[31:0]         <= nxt_alu_data_a_ex2[31:0];
      alu_data_b_ex2[31:0]         <= nxt_alu_data_b_ex2[31:0];
      alu_mask_data_ex2[31:0]      <= nxt_alu_mask_data_ex2[31:0];
      early_c_flag_ex2             <= c_flag_ex1;
      alu_sat_dbl_set_qbit_ex2     <= nxt_alu_sat_dbl_set_qbit_ex2;
      alu_ex2_zero_sign_extend     <= alu_ex1_zero_sign_extend;
      alu_ex2_clz_sel_sign_count   <= nxt_alu_ex2_clz_sel_sign_count;
      alu_ex2_clz_sel_zero_count   <= nxt_alu_ex2_clz_sel_zero_count;
      alu_ex2_extract_type         <= alu_ex1_extract_type[`CA53_ALU_EX1_XTRACT_TYP_W-1:0];
      alu_mskgen_ex2               <= alu_mskgen_ex1[5:0];
      alu_ex2_simd_sign_arth       <= alu_ex2_ctl_ex1[`CA53_ALU_EX2_SIMD_SIGN_ARTH_BITS];
      alu_ex2_valid_simd           <= nxt_alu_ex2_valid_simd;
      alu_ex2_no_valid_simd        <= nxt_alu_ex2_no_valid_simd;
      alu_ex2_simd_size            <= alu_ex2_ctl_ex1[`CA53_ALU_EX2_CTL_SIMD_SIZE_BITS];
      lu_ctl_ex2                   <= nxt_lu_ctl_ex2;
      alu_ex2_sign_replicate       <= alu_ex2_ctl_ex1[`CA53_ALU_EX2_SIGN_REPLICATE_BITS];
      alu_ex2_sel_valid            <= alu_ex2_ctl_ex1[`CA53_ALU_EX2_SEL_VALID_BITS];
      raw_alu_ex2_cbz_bypass_zflag <= alu_ex2_ctl_ex1[`CA53_ALU_EX2_CBZ_BYPASS_BITS];
      alu_ex2_flagid               <= alu_ex2_ctl_ex1[`CA53_ALU_EX2_CTL_FLAG_ID_BITS];
      alu_wr_ctl_ex2               <= alu_wr_ctl_ex1;
      ctl_64bit_op_ex2             <= ctl_64bit_op_ex1;
      skew_ex2                     <= skew_ex1;
      skew_au_op_ex2               <= skew_au_op_ex1;
      au_sel_normal_a_hi_ex2       <= nxt_sel_normal_a_hi_ex2;
      au_sel_invert_a_hi_ex2       <= nxt_sel_invert_a_hi_ex2;
      au_sel_normal_a_lo_ex2       <= nxt_sel_normal_a_lo_ex2;
      au_sel_invert_a_lo_ex2       <= nxt_sel_invert_a_lo_ex2;
      au_sel_normal_b_hi_ex2       <= nxt_sel_normal_b_hi_ex2;
      au_sel_invert_b_hi_ex2       <= nxt_sel_invert_b_hi_ex2;
      au_sel_normal_b_lo_ex2       <= nxt_sel_normal_b_lo_ex2;
      au_sel_invert_b_lo_ex2       <= nxt_sel_invert_b_lo_ex2;
      aarch64_state_ex2            <= aarch64_state_i;
      shift_rrx_ex2                <= shift_rrx_ex1;
      early_c_flag_valid_ex2       <= c_flag_valid_ex1;
    end

  always @(posedge clk_ex2 or negedge reset_n)
    if (~reset_n) begin
      invert_data_a_ex2[2]         <= 1'b0;
      invert_data_a_ex2[3]         <= 1'b1; // Opposing reset value to invert_data_a_ex2[2] to prevent synthesis optimising away
      invert_data_b_ex2[2]         <= 1'b0;
      invert_data_b_ex2[3]         <= 1'b1; // Opposing reset value to invert_data_b_ex2[2] to prevent synthesis optimising away
    end else if (en_alu_pipe_hi_ex2) begin
      invert_data_a_ex2[2]         <= alu_ex1_invert_data_a;
      invert_data_a_ex2[3]         <= alu_ex1_invert_data_a;
      invert_data_b_ex2[2]         <= nxt_invert_data_b_ex2;
      invert_data_b_ex2[3]         <= nxt_invert_data_b_ex2;
    end

  always @(posedge clk_ex2)
    if (en_alu_pipe_hi_ex2) begin
      alu_data_a_ex2[63:32]        <= nxt_alu_data_a_ex2[63:32];
      alu_data_b_ex2[63:32]        <= nxt_alu_data_b_ex2[63:32];
      alu_mask_data_ex2[63:32]     <= nxt_alu_mask_data_ex2[63:32];
    end

  // Only pipeline flags from skewed AU if skewing AU operation, and only
  // pipeline Ex2 AU control signals if haven't done operation in Ex1
  assign en_au_ctl_skew_ex2   = en_alu_pipe_lo_ex2 & enable_au_ex1 &  skew_ex1;
  assign en_au_ctl_noskew_ex2 = en_alu_pipe_lo_ex2 & enable_au_ex1 & ~skew_ex1;

  always @(posedge clk_ex2)
    if (en_au_ctl_skew_ex2) begin
      skew_geflags_ex2          <= au_geflags_ex1;
      early_v_flag_ex2          <= au_v_flag_ex1;
    end

  always @(posedge clk_ex2)
    if (en_au_ctl_noskew_ex2) begin
      au_cin_ctl_ex2               <= au_cin_ctl_ex1;
      au_add_sub_cin_ctl_ex2       <= au_add_sub_cin_ctl_ex1;
      au_simd_instr_addsubx_ex2    <= au_simd_instr_addsubx_ex1;
      au_simd_instr_subaddx_ex2    <= au_simd_instr_subaddx_ex1;
      au_valid_8_bit_simd_ex2      <= au_valid_8_bit_simd_ex1;
      au_sub_operation_ex2         <= au_sub_operation_ex1;
      au_ex2_halving               <= alu_ex2_ctl_ex1[`CA53_ALU_EX2_CTL_HALVING_BITS];
      au_simd_forced_carryin_a_ex2 <= au_simd_forced_carryin_a_ex1[2:0];
      au_simd_forced_carryin_b_ex2 <= au_simd_forced_carryin_b_ex1[2:0];
    end

  // ------------------------------------------------------
  // Ex2 stage operand manipulation prior to units
  // ------------------------------------------------------

  // For DP addressing mode: "Rm, RRX", we have to factor in CFlag
  // for bit 31 of the B operand
  assign rrx_bit_ex2 = shift_rrx_ex2 ? cflag_wr : alu_data_b_ex2[31];

  // New B operand is the modified bit 31 and the original bits 30:0
  assign rrxed_data_b_ex2[63:0] = {alu_data_b_ex2[63:32], rrx_bit_ex2, alu_data_b_ex2[30:0]};

  // The 1's complement is achieved by selecting between the inverted
  // and non-inverted versions
  assign inverted_data_a_ex2[63:48] = invert_data_a_ex2[3] ? ~alu_data_a_ex2[63:48]   : alu_data_a_ex2[63:48];
  assign inverted_data_a_ex2[47:32] = invert_data_a_ex2[2] ? ~alu_data_a_ex2[47:32]   : alu_data_a_ex2[47:32];
  assign inverted_data_a_ex2[31:16] = invert_data_a_ex2[1] ? ~alu_data_a_ex2[31:16]   : alu_data_a_ex2[31:16];
  assign inverted_data_a_ex2[15: 0] = invert_data_a_ex2[0] ? ~alu_data_a_ex2[15: 0]   : alu_data_a_ex2[15: 0];

  assign inverted_data_b_ex2[63:48] = invert_data_b_ex2[3] ? ~rrxed_data_b_ex2[63:48] : rrxed_data_b_ex2[63:48];
  assign inverted_data_b_ex2[47:32] = invert_data_b_ex2[2] ? ~rrxed_data_b_ex2[47:32] : rrxed_data_b_ex2[47:32];
  assign inverted_data_b_ex2[31:16] = invert_data_b_ex2[1] ? ~rrxed_data_b_ex2[31:16] : rrxed_data_b_ex2[31:16];
  assign inverted_data_b_ex2[15: 0] = invert_data_b_ex2[0] ? ~rrxed_data_b_ex2[15: 0] : rrxed_data_b_ex2[15: 0];

  // ------------------------------------------------------
  // Ex2 stage arithmetic unit
  // ------------------------------------------------------

  ca53dpu_alu_au u_alu_au_ex2 (
    // Inputs
    .alu_data_a_i               (alu_data_a_ex2[63:0]),
    .alu_data_b_i               (alu_data_b_ex2[63:0]),
    .ctl_64bit_op_i             (ctl_64bit_op_ex2),
    .cflag_wr_i                 (cflag_wr),
    .au_cin_ctl_i               (au_cin_ctl_ex2),
    .au_add_sub_cin_ctl_i       (au_add_sub_cin_ctl_ex2),
    .au_simd_instr_addsubx_i    (au_simd_instr_addsubx_ex2),
    .au_simd_instr_subaddx_i    (au_simd_instr_subaddx_ex2),
    .au_sel_normal_a_hi_i       (au_sel_normal_a_hi_ex2),
    .au_sel_invert_a_hi_i       (au_sel_invert_a_hi_ex2),
    .au_sel_normal_a_lo_i       (au_sel_normal_a_lo_ex2),
    .au_sel_invert_a_lo_i       (au_sel_invert_a_lo_ex2),
    .au_sel_normal_b_hi_i       (au_sel_normal_b_hi_ex2),
    .au_sel_invert_b_hi_i       (au_sel_invert_b_hi_ex2),
    .au_sel_normal_b_lo_i       (au_sel_normal_b_lo_ex2),
    .au_sel_invert_b_lo_i       (au_sel_invert_b_lo_ex2),
    .au_valid_8_bit_simd_i      (au_valid_8_bit_simd_ex2),
    .au_simd_forced_carryin_a_i (au_simd_forced_carryin_a_ex2[2:0]),
    .au_simd_forced_carryin_b_i (au_simd_forced_carryin_b_ex2[2:0]),
    .au_sub_operation_i         (au_sub_operation_ex2),
    .au_valid_simd_i            (alu_ex2_valid_simd),
    .au_simd_size_i             (alu_ex2_simd_size),
    .au_halving_i               (au_ex2_halving),
    .au_simd_sign_arth_i        (alu_ex2_simd_sign_arth),
    .au_shift_rrx_i             (shift_rrx_ex2),
    // Outputs              
    .au_nout_o                  (au_nout_ex2),
    .au_sum_o                   (au_sum_ex2[63:0]),
    .au_carryin_o               (au_carryin_ex2),
    .au_new_geflags_o           (new_geflags_ex2[3:0]),
    .au_simd_sat_overflow_o     (simd_sat_overflow_ex2[3:0]),
    .au_simd_sat_direction_o    (simd_sat_direction_ex2[3:0])
  );

  // The AU NZCV flags are ignored in Ex2 for skewed operations, as the LU flags
  // are used to indicated the flags for the skewed operation. The GE flags
  // however are used for both skewed and non-skewed operations, so select
  // between the Ex2 and skewed versions.
  assign new_alu_geflags_ex2_o  = skew_au_op_ex2 ? skew_geflags_ex2 : new_geflags_ex2;
  assign alu_au_nout_ex2_o      = au_nout_ex2;

  // ------------------------------------------------------
  // Ex2 stage logic unit
  // ------------------------------------------------------

  // When skewing, the A operand may need to be preserving for base
  // register restoring, so the actual operation performed by the LU needs to be
  // forced to MOVB, even though LU_CTL is set to ORR.
  assign lu_op_ex2 = skew_ex2 ? `CA53_LU_CTL_MOVB : lu_ctl_ex2[`CA53_LU_CTL_W-1:0];

  ca53dpu_alu_lu u_alu_lu_ex2 (
    // Inputs
    .lu_ctl_i   (lu_op_ex2),
    .data_a_i   (alu_data_a_ex2[63:0]),
    .data_b_i   (rrxed_data_b_ex2[63:0]),
    // Outputs
    .lu_out_o   (lu_out_ex2[63:0])
  );

  // ------------------------------------------------------
  // Ex2 stage masking/selection unit
  // ------------------------------------------------------

  ca53dpu_alu_masksel u_alu_masksel (
    // Inputs
    .alu_data_a_ex2_i         (alu_data_a_ex2[63:0]),
    .alu_data_b_ex2_i         (alu_data_b_ex2[63:0]),
    .alu_mask_data_ex2_i      (alu_mask_data_ex2[63:0]),
    .alu_ex2_sel_valid_i      (alu_ex2_sel_valid),
    .geflags_wr_i             (geflags_wr[3:0]),
    .alu_ex2_sign_replicate_i (alu_ex2_sign_replicate),
    .alu_mskgen_ex2_i         (alu_mskgen_ex2[5:0]),
    // Outputs
    .msu_out_ex2_o            (msu_out_ex2[63:0])
  );

  // ------------------------------------------------------
  // Ex2 stage extract/sign extend unit
  // ------------------------------------------------------

  // The extraction and sign/zero extension unit is replicated from the Ex1
  // stage. This is for cases of the XTEND and XTRACT instructions (see above),
  // when no add is taking place.
  //
  // Doing the extraction and zero/sign extension in the Ex2 stage removes one
  // pipeline bubble, since a following instruction which has a source operand
  // dependency on the XTEND instruction can have the source data forwarded
  // from the Alu back to the input stage registers of Ex2 stage.
  //
  // The inversion control signals are reused as the rotation control.
  //
  // This logic is also used for Neon VMOV scalar to ARM.

  always @*
    case ({invert_data_b_ex2[0], invert_data_a_ex2[0]})
      2'b00:    extract_data_ex2 =  alu_data_a_ex2[23: 0];
      2'b01:    extract_data_ex2 = {alu_data_a_ex2[31: 8]};
      2'b10:    extract_data_ex2 = {alu_data_a_ex2[ 7: 0], alu_data_a_ex2[31:16]};
      2'b11:    extract_data_ex2 = {alu_data_a_ex2[15: 0], alu_data_a_ex2[31:24]};
      default:  extract_data_ex2 = {24{1'bx}};
    endcase

  ca53dpu_alu_extract u_alu_extract_ex2 (
    // Inputs
    .extract_type_i     (alu_ex2_extract_type[`CA53_ALU_EX1_XTRACT_TYP_W-1:0]),
    .zero_sign_extend_i (alu_ex2_zero_sign_extend),
    .rotated_data_i     (extract_data_ex2[23:0]),
    // Outputs
    .extracted_data_o   (extracted_data_ex2[31:0])
  );

  // ------------------------------------------------------
  // Ex2 stage CRC32 unit
  // ------------------------------------------------------

  assign crc32_valid_ex1 = (alu_ex2_ctl_ex1[`CA53_ALU_EX2_CTL_LU_CTL_BITS] == `CA53_LU_CTL_CRC32);

  ca53dpu_alu_crc32 u_alu_crc32 (
    // Inputs
    .clk                      (clk),
    .reset_n                  (reset_n),
    .alu_data_a_ex2_i         (alu_data_a_ex2[31:0]),
    .alu_data_b_ex2_i         (alu_data_b_ex2[63:0]),
    .alu_data_c_ex1_i         (alu_data_c_ex1[5:3]),
    .crc32_valid_ex1_i        (crc32_valid_ex1),
    .en_alu_pipe_lo_ex2_i     (en_alu_pipe_lo_ex2),
    .alu_ex2_simd_sign_arth_i (alu_ex2_simd_sign_arth),  // SIMD control overloaded to distinguish between CRC32 and CRC32C  
    // Outputs
    .crc32_res_o              (crc32_res_ex2[31:0])
  );

  // ------------------------------------------------------
  // Ex2 stage CLZ unit
  // ------------------------------------------------------

  ca53dpu_alu_clz u_alu_clz (
    // Inputs
    .data_i           (alu_data_a_ex2[63:0]),
    .ctl_64bit_op_i   (ctl_64bit_op_ex2),
    .sel_sign_count_i (alu_ex2_clz_sel_sign_count),
    .sel_zero_count_i (alu_ex2_clz_sel_zero_count),
    // Outputs
    .clz_res_o        (clz_out_ex2[6:0])
  );

  // ------------------------------------------------------
  // Ex2 stage general purpose saturation unit
  // ------------------------------------------------------

  ca53dpu_alu_gen_sat u_alu_gen_sat (
    // Inputs
    .alu_ex2_simd_sign_arth_i   (alu_ex2_simd_sign_arth),
    .alu_ex2_no_valid_simd_i    (alu_ex2_no_valid_simd),
    .alu_data_b_ex2_i           (alu_data_b_ex2[31:0]),
    .alu_mask_data_ex2_i        (alu_mask_data_ex2[31:0]),
    // Outputs
    .gen_sat_out_ex2_o          (gen_sat_out_ex2[31:0]),
    .gen_sat_overflow_out_ex2_o (gen_sat_overflow_out_ex2)
  );

  // ------------------------------------------------------
  // Flag generation logic
  // ------------------------------------------------------

  // AU flags

  // The N, C and V bits of the AU depend on the full result of the adder,
  // which is fairly late. Compute the possible values for both N=0 and N=1,
  // and then choose between them later

  // The zero flag is evaluated in parallel with the operation performed in
  // the arithmetic unit for timing reasons. This uses carry save form to
  // avoid the need to wait for a carry chain.

  // Note that only non-skewed AU operations use the Ex2 AU flags, as the
  // operands are modified between Ex1 and Ex2 for skewed operations.

  assign alu_data_s_ex2    = (inverted_data_a_ex2 ^ inverted_data_b_ex2);

  assign alu_data_c_ex2    = (inverted_data_a_ex2[62:0] | inverted_data_b_ex2[62:0]);

  assign z_flag_au_hi_ex2  = alu_data_s_ex2[63:32] == alu_data_c_ex2[62:31];
  assign z_flag_au_lo_ex2  = alu_data_s_ex2[31:0]  == {alu_data_c_ex2[30:0], au_carryin_ex2};

  assign z_flag_au_ex2     = ctl_64bit_op_ex2 ? (z_flag_au_hi_ex2 & z_flag_au_lo_ex2) : z_flag_au_lo_ex2;

  assign c_flag_au_nclear_ex2 = ctl_64bit_op_ex2 ? (inverted_data_a_ex2[63] | inverted_data_b_ex2[63])
                                                 : (inverted_data_a_ex2[31] | inverted_data_b_ex2[31]);

  assign c_flag_au_nset_ex2   = ctl_64bit_op_ex2 ? (inverted_data_a_ex2[63] & inverted_data_b_ex2[63])
                                                 : (inverted_data_a_ex2[31] & inverted_data_b_ex2[31]);

  // Check the sign bit of both operands and the sign bit of the result. If
  // the sign bits of both operands are the same, but the sign bit of the
  // result is opposite to the operands, then an overflow has occured.
  assign v_flag_au_nclear_ex2 = ctl_64bit_op_ex2 ? ( inverted_data_a_ex2[63] &  inverted_data_b_ex2[63])
                                                 : ( inverted_data_a_ex2[31] &  inverted_data_b_ex2[31]);

  assign v_flag_au_nset_ex2   = ctl_64bit_op_ex2 ? (~inverted_data_a_ex2[63] & ~inverted_data_b_ex2[63])
                                                 : (~inverted_data_a_ex2[31] & ~inverted_data_b_ex2[31]);

  assign new_ccflags_au_nclear_ex2 = {1'b0, z_flag_au_ex2, c_flag_au_nclear_ex2, v_flag_au_nclear_ex2};
  assign new_ccflags_au_nset_ex2   = {1'b1, z_flag_au_ex2, c_flag_au_nset_ex2,   v_flag_au_nset_ex2};

  // LU flags

  assign n_flag_lu_ex2    = ctl_64bit_op_ex2 ? lu_out_ex2[63] : lu_out_ex2[31];

  assign z_flag_lu_hi_ex2  = ~|lu_out_ex2[63:32];
  assign z_flag_lu_lo_ex2  = ~|lu_out_ex2[31:0];
  assign z_flag_lu_ex2     = ctl_64bit_op_ex2 ? (z_flag_lu_hi_ex2 & z_flag_lu_lo_ex2) : z_flag_lu_lo_ex2;


  // Choose cflag from Ex1 for TEQ, TST and MOV instructions, and skewed AU operations. All other
  // instructions that can produce the cflag (ADC, ADD, CMN, CMP, RSB, RSC, SBC, SUB)
  // resolve in the Ex2 stage.
  assign c_flag_lu_ex2 = early_c_flag_valid_ex2 ? early_c_flag_ex2 : (cflag_wr & ~aarch64_state_ex2);

  // Choose vflag from Ex1 for skewed AU operations.
  assign v_flag_lu_ex2 = skew_au_op_ex2         ? early_v_flag_ex2 : (vflag_wr_i & ~aarch64_state_ex2);

  assign new_ccflags_lu_ex2 = {n_flag_lu_ex2, z_flag_lu_ex2, c_flag_lu_ex2, v_flag_lu_ex2};

  // Choose new flags
  // - The flags for a CCMP instruction are muxed at the DP top level, to
  // allow the late N outputs from the AUs to be factored in as late as
  // possible for ALU1.

  // - Select non-CCMP flags between AU and LU flags
  assign sel_lu_flags_ex2 = (lu_ctl_ex2 == `CA53_LU_CTL_AND) |
                            (lu_ctl_ex2 == `CA53_LU_CTL_ORR) |
                            (lu_ctl_ex2 == `CA53_LU_CTL_ORN) |
                            (lu_ctl_ex2 == `CA53_LU_CTL_EOR) |
                            (lu_ctl_ex2 == `CA53_LU_CTL_BIC);

  assign sel_au_flags_ex2 = (lu_ctl_ex2 == `CA53_LU_CTL_ADD) |
                            (lu_ctl_ex2 == `CA53_LU_CTL_SUB) |
                            (lu_ctl_ex2 == `CA53_LU_CTL_ADC) |
                            (lu_ctl_ex2 == `CA53_LU_CTL_SBC) |
                            (lu_ctl_ex2 == `CA53_LU_CTL_CSEL); // CCMP will use either CCMP or AU flags

  assign new_alu_ccflags_nclear_ex2_o = ({4{sel_lu_flags_ex2}}    & new_ccflags_lu_ex2[3:0])        |
                                        ({4{sel_au_flags_ex2}}    & new_ccflags_au_nclear_ex2[3:0]);

  assign new_alu_ccflags_nset_ex2_o   = ({4{sel_lu_flags_ex2}}    & new_ccflags_lu_ex2[3:0])        |
                                        ({4{sel_au_flags_ex2}}    & new_ccflags_au_nset_ex2[3:0]);

  // Indicate to DP top level when doing a CCMP and what the condition/NZCV
  // fields for the instruction are
  assign alu_sel_ccmp_flags_ex2_o     = (lu_ctl_ex2 == `CA53_LU_CTL_CSEL); // No need to exclude CSEL, as result not used on those instructions

  assign new_alu_ccflags_ccmp_ex2_o   = alu_mask_data_ex2[7:4]; // Condition and NZCV reuse mask_data bus in Ex2
  assign alu_csel_cond_ex2_o          = alu_mask_data_ex2[3:0];

  // Indicate which flags operation affects if flag setting (always write
  // N and Z)
  // - C flag:
  //   - Always in AArch64 state (set to 0 if not relevant to instruction)
  //   - Always on Arithmetic Unit operations (skewed or not)
  //   - On Logic Unit operations which do a shift
  assign alu_sel_c_flag_ex2_o = aarch64_state_ex2                |
                                early_c_flag_valid_ex2           |
                                (lu_ctl_ex2 == `CA53_LU_CTL_ADD) |
                                (lu_ctl_ex2 == `CA53_LU_CTL_SUB) |
                                (lu_ctl_ex2 == `CA53_LU_CTL_ADC) |
                                (lu_ctl_ex2 == `CA53_LU_CTL_SBC);

  // - V flag:
  //   - Always in AArch64 state (set to 0 if not relevant to instruction)
  //   - Always on Arithment Unit operations (skewed or not)
  //   - Never on Logic Unit operations
  assign alu_sel_v_flag_ex2_o = aarch64_state_ex2                |
                                skew_au_op_ex2                   |
                                (lu_ctl_ex2 == `CA53_LU_CTL_ADD) |
                                (lu_ctl_ex2 == `CA53_LU_CTL_SUB) |
                                (lu_ctl_ex2 == `CA53_LU_CTL_ADC) |
                                (lu_ctl_ex2 == `CA53_LU_CTL_SBC);

  // ------------------------------------------------------
  // Ex2 stage data selection
  // ------------------------------------------------------

  // Generate data select signals from the encoded buses
  //
  // The LU_CTL bus is being overload for use by the CLZ and
  // the Bitfield instructions. Therefore, we need to do a decode
  // to determine exactly when there is an LU operation in Ex2.
  //
  // The decode is being done as such to provide greater readability
  // leaving the boolean optimisation to the synthesis tool.
  assign sel_lu_output_ex2  = (lu_ctl_ex2 == `CA53_LU_CTL_BIC) |
                              (lu_ctl_ex2 == `CA53_LU_CTL_EOR) |
                              (lu_ctl_ex2 == `CA53_LU_CTL_AND) |
                              (lu_ctl_ex2 == `CA53_LU_CTL_EON) |
                              (lu_ctl_ex2 == `CA53_LU_CTL_ORR) |
                              (lu_ctl_ex2 == `CA53_LU_CTL_ORN);

  assign sel_crc_output_ex2 = (lu_ctl_ex2 == `CA53_LU_CTL_CRC32);

  assign sel_clz_output_ex2 = (lu_ctl_ex2 == `CA53_LU_CTL_CLZ);

  assign sel_sat_output_ex2 = (lu_ctl_ex2 == `CA53_LU_CTL_GEN_SAT);

  assign sel_msu_output_ex2 = (lu_ctl_ex2 == `CA53_LU_CTL_MASKSEL);

  assign sel_ext_output_ex2 = (lu_ctl_ex2 == `CA53_LU_CTL_EXTRACT);

  assign sel_au_output_ex2  = (lu_ctl_ex2 == `CA53_LU_CTL_ADD) |
                              (lu_ctl_ex2 == `CA53_LU_CTL_SUB) |
                              (lu_ctl_ex2 == `CA53_LU_CTL_ADC) |
                              (lu_ctl_ex2 == `CA53_LU_CTL_SBC) |
                              ((lu_ctl_ex2 == `CA53_LU_CTL_CSEL) & // Select modified second operand if condition fails
                               ~csel_cc_pass_early_ex2_i);

  assign sel_a_output_ex2   = (lu_ctl_ex2 == `CA53_LU_CTL_CSEL) &  // Select first operand if condition passes
                              csel_cc_pass_early_ex2_i;

  // Main ALU output data bus
  assign alu_out_ex2[31: 0] = ({32{sel_lu_output_ex2}}  & lu_out_ex2[31:0])          | // Logic unit
                              ({32{sel_crc_output_ex2}} & crc32_res_ex2[31:0])       | // CRC32 unit
                              ({32{sel_clz_output_ex2}} & {{25{1'b0}}, clz_out_ex2}) | // CLZ unit
                              ({32{sel_sat_output_ex2}} & gen_sat_out_ex2[31:0])     | // Sat unit. Only required for AArch32
                              ({32{sel_msu_output_ex2}} & msu_out_ex2[31:0])         | // Mask/sel unit
                              ({32{sel_ext_output_ex2}} & extracted_data_ex2[31:0])  | // Extract/extend unit
                              ({32{sel_au_output_ex2}}  & au_sum_ex2[31:0])          | // Add unit
                              ({32{sel_a_output_ex2}}   & alu_data_a_ex2[31:0]);       // A input

  assign alu_out_ex2[63:32] = ({32{(sel_lu_output_ex2  & ctl_64bit_op_ex2)}} & lu_out_ex2[63:32])         | // Logic unit
                              ({32{(sel_msu_output_ex2 & ctl_64bit_op_ex2)}} & msu_out_ex2[63:32])        | // Mask/sel unit
                              ({32{(sel_au_output_ex2  & ctl_64bit_op_ex2)}} & au_sum_ex2[63:32])         | // Add unit
                              ({32{(sel_a_output_ex2   & ctl_64bit_op_ex2)}} & alu_data_a_ex2[63:32]);      // A input

  // Q flag output from gen_sat module
  assign early_qbit_ex2 = (gen_sat_overflow_out_ex2 & sel_sat_output_ex2) | alu_sat_dbl_set_qbit_ex2;

  // Mux CSEL result in using full version of csel_cc_pass for ALU1. Must be
  // done after forwarding out point as signal is too late to include there.
generate if (ALU_SLOT_1) begin : g_final_alu_out_ex2_alu1
  wire sel_csel_pass;
  wire sel_csel_fail;
  wire sel_alu_out;

  assign sel_csel_pass = (lu_ctl_ex2 == `CA53_LU_CTL_CSEL) &  csel_cc_pass_ex2_i;
  assign sel_csel_fail = (lu_ctl_ex2 == `CA53_LU_CTL_CSEL) & ~csel_cc_pass_ex2_i;
  assign sel_alu_out   = (lu_ctl_ex2 != `CA53_LU_CTL_CSEL);

  assign final_alu_out_ex2[63:32] = ({32{sel_csel_fail & ctl_64bit_op_ex2}} & au_sum_ex2[63:32])      |
                                    ({32{sel_csel_pass & ctl_64bit_op_ex2}} & alu_data_a_ex2[63:32])  |
                                    ({32{sel_alu_out   & ctl_64bit_op_ex2}} & alu_out_ex2[63:32]);

  assign final_alu_out_ex2[31:0]  = ({32{sel_csel_fail                   }} & au_sum_ex2[31:0])       |
                                    ({32{sel_csel_pass                   }} & alu_data_a_ex2[31:0])   |
                                    ({32{sel_alu_out                     }} & alu_out_ex2[31:0]);

end else begin : g_final_alu_out_ex2_alu0
  // In ALU0, final data is same as forwarded data
  assign final_alu_out_ex2 = alu_out_ex2;

end endgenerate

  // ------------------------------------------------------
  // Ex2 -> Wr stage registers
  // ------------------------------------------------------

  always @(posedge clk_wr)
    if (en_alu_pipe_lo_wr) begin
      alu_wr_valid_simd       <= alu_ex2_valid_simd;
      alu_wr_simd_size        <= alu_ex2_simd_size;
      alu_wr_simd_sign_arth   <= alu_ex2_simd_sign_arth;
      raw_alu_data_wr[31:0]   <= final_alu_out_ex2[31:0];
      simd_sat_overflow_wr    <= simd_sat_overflow_ex2;
      simd_sat_direction_wr   <= simd_sat_direction_ex2;
      early_qbit_wr           <= early_qbit_ex2;
      alu_wr_ctl_wr           <= alu_wr_ctl_ex2;
      ctl_64bit_op_wr         <= ctl_64bit_op_ex2;
    end

  always @(posedge clk_wr)
    if (en_alu_pipe_hi_wr)
      raw_alu_data_wr[63:32]  <= final_alu_out_ex2[63:32];

  // ------------------------------------------------------
  // Wr stage SIMD saturation
  // ------------------------------------------------------

  // Indicate if we need to do any saturation or not
  assign alu_wr_sat_valid = alu_wr_ctl_wr;

  ca53dpu_alu_simd_sat u_alu_simd_sat (
    // Inputs
    .alu_wr_sat_valid_i         (alu_wr_sat_valid),
    .alu_wr_valid_simd_i        (alu_wr_valid_simd),
    .alu_wr_simd_size_i         (alu_wr_simd_size),
    .alu_wr_simd_sign_arth_i    (alu_wr_simd_sign_arth),
    .raw_alu_data_wr_i          (raw_alu_data_wr[31:0]),
    .simd_sat_overflow_wr_i     (simd_sat_overflow_wr[3:0]),
    .simd_sat_direction_wr_i    (simd_sat_direction_wr[3:0]),
    // Outputs
    .alu_data_simd_sat_wr_o     (alu_data_simd_sat_wr[31:0]),
    .simd_sat_qbit_wr_o         (simd_sat_qbit_wr)
  );

  // Saturation not required for AArch64 so bypass for upper bits
  assign alu_data_simd_sat_wr[63:32] = raw_alu_data_wr[63:32];

  // ------------------------------------------------------
  // Aliasing for the output ports
  // ------------------------------------------------------

  assign alu_valid_ex2_o            = alu_valid_ex2;
  assign alu_ex2_flagid_o           = alu_ex2_flagid;
  assign alu_ex2_cbz_bypass_zflag_o = raw_alu_ex2_cbz_bypass_zflag & alu_valid_ex2;
  assign alu_ex2_cbz_pass_o         = z_flag_lu_ex2 ^ invert_data_a_ex2[1];
  assign alu_data_a_ex2_o           = {{32{ctl_64bit_op_ex2}}, 32'hFFFF_FFFF} & alu_data_a_ex2;
  assign alu_fwd_data_ex1_o         = {{32{ctl_64bit_op_ex1}}, 32'hFFFF_FFFF} & final_alu_data_b_ex1;
  assign alu_fwd_data_ex2_o         = {{32{ctl_64bit_op_ex2}}, 32'hFFFF_FFFF} & alu_out_ex2;
  assign alu_fwd_data_early_ex2_o   = {{32{ctl_64bit_op_ex2}}, 32'hFFFF_FFFF} & inverted_data_b_ex2[63:0];
  assign alu_fwd_data_early_wr_o    = {{32{ctl_64bit_op_wr}},  32'hFFFF_FFFF} & raw_alu_data_wr;
  assign alu_data_wr_o              = {{32{ctl_64bit_op_wr}},  32'hFFFF_FFFF} & alu_data_simd_sat_wr[63:0];
  assign alu_qbit_wr_o              = early_qbit_wr | simd_sat_qbit_wr;

  // ------------------------------------------------------
  // OVL definitions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_au_ctl_ex1")
  u_ovl_x_en_au_ctl_ex1 (.clk       (clk_ex1),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_au_ctl_ex1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_au_ctl_noskew_ex2")
  u_ovl_x_en_au_ctl_noskew_ex2 (.clk       (clk_ex2),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (en_au_ctl_noskew_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_au_ctl_skew_ex2")
  u_ovl_x_en_au_ctl_skew_ex2 (.clk       (clk_ex2),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (en_au_ctl_skew_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: flag_wr_en")
  u_ovl_x_flag_wr_en (.clk       (clk_ex2),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (flag_wr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: alu_valid_ex1_en")
  u_ovl_x_alu_valid_ex1_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (alu_valid_ex1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: alu_valid_ex2_en")
  u_ovl_x_alu_valid_ex2_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (alu_valid_ex2_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_alu_pipe_hi_ex1")
  u_ovl_x_en_alu_pipe_hi_ex1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (en_alu_pipe_hi_ex1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_alu_pipe_lo_ex1")
  u_ovl_x_en_alu_pipe_lo_ex1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (en_alu_pipe_lo_ex1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_alu_pipe_hi_ex2")
  u_ovl_x_en_alu_pipe_hi_ex2 (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (en_alu_pipe_hi_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_alu_pipe_lo_ex2")
  u_ovl_x_en_alu_pipe_lo_ex2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (en_alu_pipe_lo_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_alu_pipe_hi_wr")
  u_ovl_x_en_alu_pipe_hi_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (en_alu_pipe_hi_wr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_alu_pipe_lo_wr")
  u_ovl_x_en_alu_pipe_lo_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (en_alu_pipe_lo_wr));

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_dpu_alu_bad_fwd_path_a
  // Check forwarding path for ALU_A is valid
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Invalid forwarding path specified for ALU_A")
    ovl_dpu_alu_bad_fwd_path_a (
      .clk       (clk),
      .reset_n   (reset_n),
      .test_expr ( (alu_a_fwd_ex1_i == `CA53_FWD_W0)  |
                   (alu_a_fwd_ex1_i == `CA53_FWD_W1)  |
                   (alu_a_fwd_ex1_i == `CA53_FWD_W2)  |
                   (alu_a_fwd_ex1_i == `CA53_FWD_ALU0_EX2) |
                   (alu_a_fwd_ex1_i == `CA53_FWD_ALU1_EX2) |
                  ((alu_a_fwd_ex1_i == `CA53_FWD_ALU0_EX1) && ALU_SLOT_1) |
                   (alu_a_fwd_ex1_i == `CA53_FWD_NULL)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_dpu_alu_bad_fwd_path_b
  // Check forwarding path for ALU_B is valid
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Invalid forwarding path specified for ALU_B")
    ovl_dpu_alu_bad_fwd_path_b (
      .clk       (clk),
      .reset_n   (reset_n),
      .test_expr ( (alu_b_fwd_ex1_i == `CA53_FWD_W0)  |
                   (alu_b_fwd_ex1_i == `CA53_FWD_W1)  |
                   (alu_b_fwd_ex1_i == `CA53_FWD_W2)  |
                   (alu_b_fwd_ex1_i == `CA53_FWD_ALU0_EX2) |
                   (alu_b_fwd_ex1_i == `CA53_FWD_ALU1_EX2) |
                  ((alu_b_fwd_ex1_i == `CA53_FWD_ALU0_EX1) && ALU_SLOT_1) |
                   (alu_b_fwd_ex1_i == `CA53_FWD_NULL)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Check that alu_ex1_rev_type has a valid encoding
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication
    #(`OVL_FATAL,`OVL_ASSERT,"alu_ex1_rev_type has invalid encoding")
      ovl_check_rev_type (
        .clk              (clk),
        .reset_n          (reset_n),
        .antecedent_expr  (alu_valid_ex1),
        .consequent_expr  ((           alu_ex1_rev_type == `CA53_REV_MUX_NORMAL)   |
                           (           alu_ex1_rev_type == `CA53_REV_MUX_REV)      |
                           (           alu_ex1_rev_type == `CA53_REV_MUX_REV16)    |
                           (           alu_ex1_rev_type == `CA53_REV_MUX_REVSH)    |
                           (           alu_ex1_rev_type == `CA53_REV_MUX_RBIT)     |
                           (           alu_ex1_rev_type == `CA53_REV_MUX_SAT_DBL)  |
                           (           alu_ex1_rev_type == `CA53_REV_MUX_ZERO)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Check that alu_ex1_extract_type has a valid encoding
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg seen_en_alu_pipe_lo_ex1;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      seen_en_alu_pipe_lo_ex1 <= 1'b0;
    else if (~seen_en_alu_pipe_lo_ex1)
      seen_en_alu_pipe_lo_ex1 <= en_alu_pipe_lo_ex1;

  assert_implication
    #(`OVL_FATAL,`OVL_ASSERT,"alu_ex1_extract_type has invalid encoding")
      ovl_check_ex1_extract_type (
        .clk              (clk),
        .reset_n          (reset_n),
        .antecedent_expr  (seen_en_alu_pipe_lo_ex1 & alu_ex1_extract_valid),
        .consequent_expr  ((alu_ex1_extract_type == `CA53_EXTRACT_LS_BYTE)   |
                           (alu_ex1_extract_type == `CA53_EXTRACT_LS_HWORD)  |
                           (alu_ex1_extract_type == `CA53_EXTRACT_TWO_BYTES) |
                           (alu_ex1_extract_type == `CA53_EXTRACT_SH_BYTE)   |
                           (alu_ex1_extract_type == `CA53_EXTRACT_SH_HWORD)  |
                           (alu_ex1_extract_type == `CA53_EXTRACT_SH_WORD)   |
                           (alu_ex1_extract_type == `CA53_EXTRACT_SH_XWORD)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Check that alu_ex2_extract_type has a valid encoding
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg seen_en_alu_pipe_lo_ex2;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      seen_en_alu_pipe_lo_ex2 <= 1'b0;
    else if (~seen_en_alu_pipe_lo_ex2)
      seen_en_alu_pipe_lo_ex2 <= en_alu_pipe_lo_ex2;

  assert_implication
    #(`OVL_FATAL,`OVL_ASSERT,"alu_ex2_extract_type has invalid encoding")
      ovl_check_ex2_extract_type (
        .clk              (clk),
        .reset_n          (reset_n),
        .antecedent_expr  (seen_en_alu_pipe_lo_ex2 & sel_ext_output_ex2),
        .consequent_expr  ((alu_ex2_extract_type == `CA53_EXTRACT_LS_BYTE)   |
                           (alu_ex2_extract_type == `CA53_EXTRACT_LS_HWORD)  |
                           (alu_ex2_extract_type == `CA53_EXTRACT_TWO_BYTES)));
  // OVL_ASSERT_END

`endif

endmodule // ca53dpu_alu

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
