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
// Abstract : Floating point datapath wrapper module (containing data muxes)
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// This module instantiates the FPU datapath modules and
// contains the muxes used to select data to and from those pipelines.

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_fp_dp `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire                             clk_fp,
  input  wire                             clk_fp_alu0,
  input  wire                             clk_fp_alu1,
  input  wire                             clk_fp_mul0,
  input  wire                             clk_fp_mul1,
  input  wire                             clk_crypto,
  input  wire                             reset_n,
  input  wire                             flush_ret_i,
  input  wire                             stall_wr_i,
  input  wire                             advance_pipeline_i,
  input  wire                       [1:0] rf_rd_en_fr0_f1_i,
  input  wire                       [1:0] rf_rd_en_fr1_f1_i,
  input  wire                       [1:0] rf_rd_en_fr2_f1_i,
  input  wire                       [1:0] rf_rd_en_fr3_f1_i,
  input  wire                       [1:0] rf_rd_en_fr4_f1_i,
  input  wire                       [1:0] rf_rd_en_fr5_f1_i,
  input  wire                       [1:0] rf_rd_en_fr0_f2_i,
  input  wire                       [1:0] rf_rd_en_fr1_f2_i,
  input  wire                       [1:0] rf_rd_en_fr2_f2_i,
  input  wire                       [1:0] rf_rd_en_fr3_f2_i,
  input  wire                       [1:0] rf_rd_en_fr4_f2_i,
  input  wire                       [1:0] rf_rd_en_fr5_f2_i,
  input  wire                      [63:0] rf_rd_data_fr0_f1_i,      // FPU register file read port 0
  input  wire                      [63:0] rf_rd_data_fr1_f1_i,      // FPU register file read port 1
  input  wire                      [63:0] rf_rd_data_fr2_f1_i,      // FPU register file read port 2
  input  wire                      [63:0] rf_rd_data_fr3_f1_i,      // FPU register file read port 3
  input  wire                      [63:0] rf_rd_data_fr4_f1_i,      // FPU register file read port 4
  input  wire                      [63:0] rf_rd_data_fr5_f1_i,      // FPU register file read port 5
  input  wire                       [5:0] fr0_fwd_f1_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr1_fwd_f1_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr2_fwd_f1_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr3_fwd_f1_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr4_fwd_f1_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr5_fwd_f1_i,             // FPU forwarding mux select
  input  wire     [`CA53_SEL_FAD_A_W-1:0] sel_fad0_a_f1_i,           // Mux select signal(s) for FAD_A
  input  wire     [`CA53_SEL_FAD_B_W-1:0] sel_fad0_b_f1_i,           // Mux select signal(s) for FAD_B
  input  wire     [`CA53_SEL_FAD_C_W-1:0] sel_fad0_c_f1_i,           // Mux select signal(s) for FAD_C
  input  wire     [`CA53_SEL_FAD_A_W-1:0] sel_fad1_a_f1_i,           // Mux select signal(s) for FAD_A
  input  wire     [`CA53_SEL_FAD_B_W-1:0] sel_fad1_b_f1_i,           // Mux select signal(s) for FAD_B
  input  wire     [`CA53_SEL_FAD_C_W-1:0] sel_fad1_c_f1_i,           // Mux select signal(s) for FAD_C
  input  wire                             sel_fml0_a_f1_i,           // Mux select signal(s) for FML_A
  input  wire     [`CA53_SEL_FML_B_W-1:0] sel_fml0_b_f1_i,           // Mux select signal(s) for FML_B
  input  wire                             sel_fml0_c_f1_i,           // Mux select signal(s) for FML_C
  input  wire                             sel_fml1_a_f1_i,           // Mux select signal(s) for FML_A
  input  wire     [`CA53_SEL_FML_B_W-1:0] sel_fml1_b_f1_i,           // Mux select signal(s) for FML_B
  input  wire                             sel_fml1_c_f1_i,           // Mux select signal(s) for FML_C
  input  wire                       [5:0] fr0_fwd_f2_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr1_fwd_f2_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr2_fwd_f2_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr3_fwd_f2_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr4_fwd_f2_i,             // FPU forwarding mux select
  input  wire                       [5:0] fr5_fwd_f2_i,             // FPU forwarding mux select
  input  wire                       [1:0] fp_mul_fwd_f2_i,
  input  wire                       [1:0] str0_sel_fp_f1_i,
  input  wire                       [1:0] str1_sel_fp_f1_i,
  input  wire                       [1:0] str0_sel_fp_f2_i,
  input  wire                       [1:0] str1_sel_fp_f2_i,
  input  wire    [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_f3_i,       // Mux select signal(s) for RF write port 0
  input  wire    [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_f4_i,       // Mux select signal(s) for RF write port 0
  input  wire    [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_f5_i,       // Mux select signal(s) for RF write port 0
  input  wire    [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw1_f3_i,       // Mux select signal(s) for RF write port 1
  input  wire    [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw1_f4_i,       // Mux select signal(s) for RF write port 1
  input  wire    [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw1_f5_i,       // Mux select signal(s) for RF write port 1
  input  wire   [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw0_f4_i,
  input  wire   [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw1_f4_i,
  input  wire                             rf_wr_en_fw_f3_i,         //
  input  wire                      [12:0] fp0_imm_data_f1_i,        // FPU immediate data
  input  wire                      [12:0] fp1_imm_data_f1_i,        // FPU immediate data
  input  wire    [`CA53_FP_EX_PIPE_W-1:0] fp_ex_pipe_f1_i,
  input  wire                             crypto_enable_f1_i,
  input  wire    [`CA53_FP_PIPECTL_W-1:0] fp0_pipectl_f1_i,
  input  wire    [`CA53_FP_PIPECTL_W-1:0] fp1_pipectl_f1_i,
  input  wire                       [1:0] fp_div_enb_f1_i,
  input  wire                             alu0_csel_pass_ex2_i,
  input  wire                             instr_is_cp10_cp11_wr_i,
  input  wire  [`CA53_NEON_VLD_CTL_W-1:0] neon_vld_ctl_f3_i,
  input  wire                             cp_fpcr_ahp_i,
  input  wire                             cp_fpcr_dn_i,
  input  wire                             cp_fpcr_fz_i,
  input  wire                       [1:0] cp_fpcr_rmode_i,
  input  wire                             valid_instrs_wr_i,
  input  wire                             issue_to_ex2_fpu_i,
  input  wire                             issue_to_f4_i,
  input  wire                             first_x64_wr_i,
  input  wire                      [63:0] fwd_ld_data_int_wr_i,     // Load data from DCU (not sign extended)
  input  wire                      [63:0] st0_data_ex1_i,           // Data from store pipe
  input  wire                      [63:0] st0_data_wr_i,            // Data from store pipe
  input  wire                      [63:0] st1_data_ex1_i,           // Data from store pipe
  input  wire                      [63:0] st1_data_wr_i,            // Data from store pipe
  input  wire                       [1:0] ls_elem_size_wr_i,        // Size of element data
  // Outputs
  output wire                       [1:0] fp_alu_en_o,
  output wire                       [1:0] fp_mul_en_o,
  output wire                       [1:0] fp_div_busy_nxt_cyc_o,
  output wire                      [63:0] rf_wr_data_fw0_f5_o,      // FPU register file data port 0
  output wire                      [63:0] rf_wr_data_fw1_f5_o,      // FPU register file data port 1
  output reg                       [63:0] fp_str0_data_f1_o,
  output reg                       [63:0] fp_str1_data_f1_o,
  output reg                       [63:0] fp_str0_data_f2_o,
  output reg                       [63:0] fp_str1_data_f2_o,
  output wire                      [63:0] fp_alu0_f2i_res_f3_o,     // Result of A64 float->int conversion
  output wire                      [63:0] fp_alu1_f2i_res_f3_o,     // Result of A64 float->int conversion
  output wire                       [3:0] fp_cflags_add0_f2_o,
  output wire                       [3:0] fp_cflags_add1_f2_o,
  output wire        [`CA53_XFLAGS_W-1:0] fp_xflags_mul0_f5_o,
  output wire        [`CA53_XFLAGS_W-1:0] fp_xflags_mul1_f5_o,
  output wire        [`CA53_XFLAGS_W-1:0] fp_xflags_add0_f5_o,
  output wire        [`CA53_XFLAGS_W-1:0] fp_xflags_add1_f5_o,
  output wire                             fp_dp_en_active_o,
  output wire                             crypto_active_o
);

  // -----------------------------
  // Genvar declarations
  // -----------------------------

  genvar i;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg  [`CA53_FP_ADD_CTL_W-1:0] add0_ctl_f1;
  reg  [`CA53_FP_ADD_CTL_W-1:0] add1_ctl_f1;
  reg                    [63:0] fwd_data_raw_fr0_f1;
  reg                    [63:0] fwd_data_raw_fr1_f1;
  reg                    [63:0] fwd_data_raw_fr2_f1;
  reg                    [63:0] fwd_data_raw_fr3_f1;
  reg                    [63:0] fwd_data_raw_fr4_f1;
  reg                    [63:0] fwd_data_raw_fr5_f1;
  reg                    [63:0] fwd_data_raw_fr0_f2;
  reg                    [63:0] fwd_data_raw_fr1_f2;
  reg                    [63:0] fwd_data_raw_fr2_f2;
  reg                    [63:0] fwd_data_raw_fr3_f2;
  reg                    [63:0] fwd_data_raw_fr4_f2;
  reg                    [63:0] fwd_data_raw_fr5_f2;
  reg                    [63:0] neon_modimm0_data_f1;
  reg                    [63:0] neon_modimm1_data_f1;
  reg                     [7:0] fp0_imm_data_f2;
  reg                     [7:0] fp1_imm_data_f2;
  reg                           en_ls_rt_data_fw0_f5;
  reg                           en_ls_rt_data_fw1_f5;
  reg                    [63:0] ls_rt_data_fw0_f4;
  reg                    [63:0] ls_rt_data_fw1_f4;
  reg                    [63:0] ls_rt_data_fw0_f5;
  reg                    [63:0] ls_rt_data_fw1_f5;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                   [63:0] a0_trans32;
  wire                   [63:0] b0_trans32;
  wire                   [63:0] a0_two;
  wire                   [63:0] a0_three;
  wire                   [63:0] a1_trans32;
  wire                   [63:0] b1_trans32;
  wire                   [63:0] a1_two;
  wire                   [63:0] a1_three;
  wire                   [63:0] fad0_a_data_f1;
  wire                   [63:0] fad0_b_data_f1;
  wire                   [63:0] fad0_c_data_f1;
  wire                   [63:0] fad1_a_data_f1;
  wire                   [63:0] fad1_b_data_f1;
  wire                   [63:0] fad1_c_data_f1;
  wire                   [63:0] fml0_a_data_f1;
  wire                   [63:0] fml0_b_data_f1;
  wire                   [63:0] fml0_c_data_f1;
  wire                   [63:0] fml1_a_data_f1;
  wire                   [63:0] fml1_b_data_f1;
  wire                   [63:0] fml1_c_data_f1;
  wire                  [127:0] crypto_a_data_f1;
  wire                  [127:0] crypto_b_data_f1;
  wire                  [127:0] crypto_c_data_f1;
  wire                   [63:0] ld_data_f3;
  wire                   [63:0] dup_ld_data_f3;
  wire                          ls_rt_data0_en_f5;
  wire                          ls_rt_data1_en_f5;
  wire                    [1:0] mac0_round_mode_f5;
  wire                          mac0_force_dn_fz_f5;
  wire                          mac0_fused_mac_f5;
  wire                    [1:0] mac1_round_mode_f5;
  wire                          mac1_force_dn_fz_f5;
  wire                          mac1_fused_mac_f5;
  wire   [`CA53_FP_RMODE_W-1:0] fp_rm_add0_f1;
  wire   [`CA53_FP_RMODE_W-1:0] fp_rm_add1_f1;
  wire                          add0_force_dn_fz_f1;
  wire                          add0_fused_mac_f1;
  wire                          add1_force_dn_fz_f1;
  wire                          add1_fused_mac_f1;
  wire                   [63:0] fwd_data_fr0_f1;
  wire                   [63:0] fwd_data_fr1_f1;
  wire                   [63:0] fwd_data_fr2_f1;
  wire                   [63:0] fwd_data_fr3_f1;
  wire                   [63:0] fwd_data_fr4_f1;
  wire                   [63:0] fwd_data_fr5_f1;
  wire                   [63:0] fwd_data_fr0_f2;
  wire                   [63:0] fwd_data_fr1_f2;
  wire                   [63:0] fwd_data_fr2_f2;
  wire                   [63:0] fwd_data_fr3_f2;
  wire                   [63:0] fwd_data_fr4_f2;
  wire                   [63:0] fwd_data_fr5_f2;
  wire                    [1:0] fad0_a_fwd_f2;
  wire                    [1:0] fad0_b_fwd_f2;
  wire                    [1:0] fad1_a_fwd_f2;
  wire                    [1:0] fad1_b_fwd_f2;
  wire                   [63:0] ls_rt_data_fw0_f3;
  wire                   [63:0] ls_rt_data_fw1_f3;
  wire                   [63:0] fwd_rf_wr_data_fw0_f3;
  wire                   [63:0] fwd_rf_wr_data_fw1_f3;
  wire                   [63:0] fwd_rf_wr_data_fw0_f4;
  wire                   [63:0] fwd_rf_wr_data_fw1_f4;
  wire                   [63:0] fwd_rf_wr_data_fw0_f5;
  wire                   [63:0] fwd_rf_wr_data_fw1_f5;
  wire                    [1:0] add_enable_f1;
  wire                    [1:0] add_enable_f2;
  wire                    [1:0] add_enable_f3;
  wire                    [1:0] mul_enable_f1;
  wire                    [1:0] mul_enable_f2;
  wire                    [1:0] mul_enable_f3;
  wire [`CA53_FP_MUL_CTL_W-1:0] mul0_ctl_f1;
  wire [`CA53_FP_MUL_CTL_W-1:0] mul1_ctl_f1;
  wire                          fp0_sfmac_f1;
  wire                          fp1_sfmac_f1;
  wire                          fp0_vrsqrts_f1;
  wire                          fp1_vrsqrts_f1;
  wire                          ls_data0_sel_f3;
  wire                          ls_data1_sel_f3;
  wire                          en_ls_rt_data_fw0_f4;
  wire                          en_ls_rt_data_fw1_f4;
  wire   [`CA53_FP_RMODE_W-1:0] fp0_rmode_f1;
  wire                          fp0_force_dn_fz_f1;
  wire   [`CA53_FP_RMODE_W-1:0] fp1_rmode_f1;
  wire                          fp1_force_dn_fz_f1;
  wire                   [63:0] fad0_early_data_f3;
  wire                   [63:0] fad1_early_data_f3;
  wire                   [63:0] fad0_early_data_f4;
  wire                   [63:0] fad1_early_data_f4;
  wire                   [63:0] fad0_data_f5;
  wire                   [63:0] fad1_data_f5;
  wire                   [63:0] fml0_data_f5;
  wire                   [63:0] fml1_data_f5;
  wire                   [63:0] fml0_extra_data_f5;
  wire                   [63:0] fml1_extra_data_f5;
  wire     [`CA53_XFLAGS_W-1:0] fad0_xflags_f5;
  wire     [`CA53_XFLAGS_W-1:0] fad1_xflags_f5;
  wire     [`CA53_XFLAGS_W-1:0] fml0_xflags_f5;
  wire     [`CA53_XFLAGS_W-1:0] fml1_xflags_f5;
  wire                          mul0_dual_fp_f5;
  wire                          mul1_dual_fp_f5;
  wire   [`CA53_FP_RMODE_W-1:0] round_mode_0_f1;
  wire   [`CA53_FP_RMODE_W-1:0] round_mode_1_f1;
  wire  [`CA53_CRYPTO_OP_W-1:0] crypto_op_f1;
  wire                  [127:0] crypto_data_f3;
  wire                  [127:0] crypto_data_f5;
  wire                          div0_fp_busy_nxt_cyc;
  wire                          div1_fp_busy_nxt_cyc;
  wire                          imm_data_f2_en;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  assign fp_alu_en_o = add_enable_f2 | add_enable_f3;
  assign fp_mul_en_o = mul_enable_f2 | mul_enable_f3;

  // ------------------------------------------------------
  // F1 Stage Forwarding muxes
  // ------------------------------------------------------

  generate for (i = 0; i < 2; i = i + 1) begin : g_fwd_f1
    always @*
      case (fr0_fwd_f1_i[i*3+:3])
        `CA53_FWD_FW0_F5 : fwd_data_raw_fr0_f1[i*32+:32] = fwd_rf_wr_data_fw0_f5[i[0]*32+:32];
        `CA53_FWD_FW0_F4 : fwd_data_raw_fr0_f1[i*32+:32] = fwd_rf_wr_data_fw0_f4[i[0]*32+:32];
        `CA53_FWD_FW0_F3 : fwd_data_raw_fr0_f1[i*32+:32] = fwd_rf_wr_data_fw0_f3[i[0]*32+:32];
        `CA53_FWD_FW1_F5 : fwd_data_raw_fr0_f1[i*32+:32] = fwd_rf_wr_data_fw1_f5[i[0]*32+:32];
        `CA53_FWD_FW1_F4 : fwd_data_raw_fr0_f1[i*32+:32] = fwd_rf_wr_data_fw1_f4[i[0]*32+:32];
        `CA53_FWD_FW1_F3 : fwd_data_raw_fr0_f1[i*32+:32] = fwd_rf_wr_data_fw1_f3[i[0]*32+:32];
        `CA53_FWD_ZERO   : fwd_data_raw_fr0_f1[i*32+:32] = {32{1'b0}};
        `CA53_FWD_FNULL  : fwd_data_raw_fr0_f1[i*32+:32] = rf_rd_data_fr0_f1_i[i*32+:32];
        default          : fwd_data_raw_fr0_f1[i*32+:32] = {32{1'bx}};
      endcase

    always @*
      case (fr1_fwd_f1_i[i*3+:3])
        `CA53_FWD_FW0_F5 : fwd_data_raw_fr1_f1[i*32+:32] = fwd_rf_wr_data_fw0_f5[i[0]*32+:32];
        `CA53_FWD_FW0_F4 : fwd_data_raw_fr1_f1[i*32+:32] = fwd_rf_wr_data_fw0_f4[i[0]*32+:32];
        `CA53_FWD_FW0_F3 : fwd_data_raw_fr1_f1[i*32+:32] = fwd_rf_wr_data_fw0_f3[i[0]*32+:32];
        `CA53_FWD_FW1_F5 : fwd_data_raw_fr1_f1[i*32+:32] = fwd_rf_wr_data_fw1_f5[i[0]*32+:32];
        `CA53_FWD_FW1_F4 : fwd_data_raw_fr1_f1[i*32+:32] = fwd_rf_wr_data_fw1_f4[i[0]*32+:32];
        `CA53_FWD_FW1_F3 : fwd_data_raw_fr1_f1[i*32+:32] = fwd_rf_wr_data_fw1_f3[i[0]*32+:32];
        `CA53_FWD_ZERO   : fwd_data_raw_fr1_f1[i*32+:32] = {32{1'b0}};
        `CA53_FWD_FNULL  : fwd_data_raw_fr1_f1[i*32+:32] = rf_rd_data_fr1_f1_i[i*32+:32];
        default          : fwd_data_raw_fr1_f1[i*32+:32] = {32{1'bx}};
      endcase

    always @*
      case (fr2_fwd_f1_i[i*3+:3])
        `CA53_FWD_FW0_F5 : fwd_data_raw_fr2_f1[i*32+:32] = fwd_rf_wr_data_fw0_f5[i[0]*32+:32];
        `CA53_FWD_FW0_F4 : fwd_data_raw_fr2_f1[i*32+:32] = fwd_rf_wr_data_fw0_f4[i[0]*32+:32];
        `CA53_FWD_FW0_F3 : fwd_data_raw_fr2_f1[i*32+:32] = fwd_rf_wr_data_fw0_f3[i[0]*32+:32];
        `CA53_FWD_FW1_F5 : fwd_data_raw_fr2_f1[i*32+:32] = fwd_rf_wr_data_fw1_f5[i[0]*32+:32];
        `CA53_FWD_FW1_F4 : fwd_data_raw_fr2_f1[i*32+:32] = fwd_rf_wr_data_fw1_f4[i[0]*32+:32];
        `CA53_FWD_FW1_F3 : fwd_data_raw_fr2_f1[i*32+:32] = fwd_rf_wr_data_fw1_f3[i[0]*32+:32];
        `CA53_FWD_ZERO   : fwd_data_raw_fr2_f1[i*32+:32] = {32{1'b0}};
        `CA53_FWD_FNULL  : fwd_data_raw_fr2_f1[i*32+:32] = rf_rd_data_fr2_f1_i[i*32+:32];
        default          : fwd_data_raw_fr2_f1[i*32+:32] = {32{1'bx}};
      endcase

    always @*
      case (fr3_fwd_f1_i[i*3+:3])
        `CA53_FWD_FW0_F5 : fwd_data_raw_fr3_f1[i*32+:32] = fwd_rf_wr_data_fw0_f5[i[0]*32+:32];
        `CA53_FWD_FW0_F4 : fwd_data_raw_fr3_f1[i*32+:32] = fwd_rf_wr_data_fw0_f4[i[0]*32+:32];
        `CA53_FWD_FW0_F3 : fwd_data_raw_fr3_f1[i*32+:32] = fwd_rf_wr_data_fw0_f3[i[0]*32+:32];
        `CA53_FWD_FW1_F5 : fwd_data_raw_fr3_f1[i*32+:32] = fwd_rf_wr_data_fw1_f5[i[0]*32+:32];
        `CA53_FWD_FW1_F4 : fwd_data_raw_fr3_f1[i*32+:32] = fwd_rf_wr_data_fw1_f4[i[0]*32+:32];
        `CA53_FWD_FW1_F3 : fwd_data_raw_fr3_f1[i*32+:32] = fwd_rf_wr_data_fw1_f3[i[0]*32+:32];
        `CA53_FWD_ZERO   : fwd_data_raw_fr3_f1[i*32+:32] = {32{1'b0}};
        `CA53_FWD_FNULL  : fwd_data_raw_fr3_f1[i*32+:32] = rf_rd_data_fr3_f1_i[i*32+:32];
        default          : fwd_data_raw_fr3_f1[i*32+:32] = {32{1'bx}};
      endcase

    always @*
      case (fr4_fwd_f1_i[i*3+:3])
        `CA53_FWD_FW0_F5 : fwd_data_raw_fr4_f1[i*32+:32] = fwd_rf_wr_data_fw0_f5[i[0]*32+:32];
        `CA53_FWD_FW0_F4 : fwd_data_raw_fr4_f1[i*32+:32] = fwd_rf_wr_data_fw0_f4[i[0]*32+:32];
        `CA53_FWD_FW0_F3 : fwd_data_raw_fr4_f1[i*32+:32] = fwd_rf_wr_data_fw0_f3[i[0]*32+:32];
        `CA53_FWD_FW1_F5 : fwd_data_raw_fr4_f1[i*32+:32] = fwd_rf_wr_data_fw1_f5[i[0]*32+:32];
        `CA53_FWD_FW1_F4 : fwd_data_raw_fr4_f1[i*32+:32] = fwd_rf_wr_data_fw1_f4[i[0]*32+:32];
        `CA53_FWD_FW1_F3 : fwd_data_raw_fr4_f1[i*32+:32] = fwd_rf_wr_data_fw1_f3[i[0]*32+:32];
        `CA53_FWD_ZERO   : fwd_data_raw_fr4_f1[i*32+:32] = {32{1'b0}};
        `CA53_FWD_FNULL  : fwd_data_raw_fr4_f1[i*32+:32] = rf_rd_data_fr4_f1_i[i*32+:32];
        default          : fwd_data_raw_fr4_f1[i*32+:32] = {32{1'bx}};
      endcase

    always @*
      case (fr5_fwd_f1_i[i*3+:3])
        `CA53_FWD_FW0_F5 : fwd_data_raw_fr5_f1[i*32+:32] = fwd_rf_wr_data_fw0_f5[i[0]*32+:32];
        `CA53_FWD_FW0_F4 : fwd_data_raw_fr5_f1[i*32+:32] = fwd_rf_wr_data_fw0_f4[i[0]*32+:32];
        `CA53_FWD_FW0_F3 : fwd_data_raw_fr5_f1[i*32+:32] = fwd_rf_wr_data_fw0_f3[i[0]*32+:32];
        `CA53_FWD_FW1_F5 : fwd_data_raw_fr5_f1[i*32+:32] = fwd_rf_wr_data_fw1_f5[i[0]*32+:32];
        `CA53_FWD_FW1_F4 : fwd_data_raw_fr5_f1[i*32+:32] = fwd_rf_wr_data_fw1_f4[i[0]*32+:32];
        `CA53_FWD_FW1_F3 : fwd_data_raw_fr5_f1[i*32+:32] = fwd_rf_wr_data_fw1_f3[i[0]*32+:32];
        `CA53_FWD_ZERO   : fwd_data_raw_fr5_f1[i*32+:32] = {32{1'b0}};
        `CA53_FWD_FNULL  : fwd_data_raw_fr5_f1[i*32+:32] = rf_rd_data_fr5_f1_i[i*32+:32];
        default          : fwd_data_raw_fr5_f1[i*32+:32] = {32{1'bx}};
      endcase
  end endgenerate

  assign fwd_data_fr0_f1[ 63:32] = fwd_data_raw_fr0_f1[ 63:32];
  assign fwd_data_fr0_f1[ 31: 0] = (rf_rd_en_fr0_f1_i[1:0] == 2'b10) ? fwd_data_raw_fr0_f1[ 63:32] :
                                                                       fwd_data_raw_fr0_f1[ 31: 0];

  // FR1 needs to be able to replicate the lower word for by-element
  // multiplies
  assign fwd_data_fr1_f1[ 63:32] = (rf_rd_en_fr1_f1_i[1:0] == 2'b01) ? fwd_data_raw_fr1_f1[ 31: 0] :
                                                                       fwd_data_raw_fr1_f1[ 63:32];
  assign fwd_data_fr1_f1[ 31: 0] = (rf_rd_en_fr1_f1_i[1:0] == 2'b10) ? fwd_data_raw_fr1_f1[ 63:32] :
                                                                       fwd_data_raw_fr1_f1[ 31: 0];

  assign fwd_data_fr2_f1[ 63:32] = fwd_data_raw_fr2_f1[ 63:32];
  assign fwd_data_fr2_f1[ 31: 0] = (rf_rd_en_fr2_f1_i[1:0] == 2'b10) ? fwd_data_raw_fr2_f1[ 63:32] :
                                                                       fwd_data_raw_fr2_f1[ 31: 0];

  assign fwd_data_fr3_f1[ 63:32] = fwd_data_raw_fr3_f1[ 63:32];
  assign fwd_data_fr3_f1[ 31: 0] = (rf_rd_en_fr3_f1_i[1:0] == 2'b10) ? fwd_data_raw_fr3_f1[ 63:32] :
                                                                       fwd_data_raw_fr3_f1[ 31: 0];

  // FR1 needs to be able to replicate the lower word for by-element
  // multiplies
  assign fwd_data_fr4_f1[ 63:32] = (rf_rd_en_fr4_f1_i[1:0] == 2'b01) ? fwd_data_raw_fr4_f1[ 31: 0] :
                                                                       fwd_data_raw_fr4_f1[ 63:32];
  assign fwd_data_fr4_f1[ 31: 0] = (rf_rd_en_fr4_f1_i[1:0] == 2'b10) ? fwd_data_raw_fr4_f1[ 63:32] :
                                                                       fwd_data_raw_fr4_f1[ 31: 0];

  assign fwd_data_fr5_f1[ 63:32] = fwd_data_raw_fr5_f1[ 63:32];
  assign fwd_data_fr5_f1[ 31: 0] = (rf_rd_en_fr5_f1_i[1:0] == 2'b10) ? fwd_data_raw_fr5_f1[ 63:32] :
                                                                       fwd_data_raw_fr5_f1[ 31: 0];

  // ------------------------------------------------------
  // Calculate the modified immediate constant
  // ------------------------------------------------------

  always @*
    case (fp0_imm_data_f1_i[12:8])
      // {op, cmode}
      `ca53dpu_sel_x000x : neon_modimm0_data_f1 = {2{ {24{1'b0}}, fp0_imm_data_f1_i[7:0]}};
      `ca53dpu_sel_x001x : neon_modimm0_data_f1 = {2{ {16{1'b0}}, fp0_imm_data_f1_i[7:0], { 8{1'b0}} }};
      `ca53dpu_sel_x010x : neon_modimm0_data_f1 = {2{ { 8{1'b0}}, fp0_imm_data_f1_i[7:0], {16{1'b0}} }};
      `ca53dpu_sel_x011x : neon_modimm0_data_f1 = {2{             fp0_imm_data_f1_i[7:0], {24{1'b0}} }};
      `ca53dpu_sel_x100x : neon_modimm0_data_f1 = {4{ { 8{1'b0}}, fp0_imm_data_f1_i[7:0]}};
      `ca53dpu_sel_x101x : neon_modimm0_data_f1 = {4{fp0_imm_data_f1_i[7:0], {8{1'b0}} }};
      `ca53dpu_sel_x1100 : neon_modimm0_data_f1 = {2{ {16{1'b0}}, fp0_imm_data_f1_i[7:0], { 8{1'b1}} }};
      `ca53dpu_sel_x1101 : neon_modimm0_data_f1 = {2{ { 8{1'b0}}, fp0_imm_data_f1_i[7:0], {16{1'b1}} }};
      5'b01110           : neon_modimm0_data_f1 = {8{fp0_imm_data_f1_i[7:0]}};
      5'b11110           : neon_modimm0_data_f1 = { {8{fp0_imm_data_f1_i[7]}}, {8{fp0_imm_data_f1_i[6]}},
                                                    {8{fp0_imm_data_f1_i[5]}}, {8{fp0_imm_data_f1_i[4]}},
                                                    {8{fp0_imm_data_f1_i[3]}}, {8{fp0_imm_data_f1_i[2]}},
                                                    {8{fp0_imm_data_f1_i[1]}}, {8{fp0_imm_data_f1_i[0]}} };
      5'b01111           : neon_modimm0_data_f1 = {2{fp0_imm_data_f1_i[7], ~fp0_imm_data_f1_i[6], {5{fp0_imm_data_f1_i[6]}},
                                                     fp0_imm_data_f1_i[5:0], {19{1'b0}} }};
      5'b11111           : neon_modimm0_data_f1 = {fp0_imm_data_f1_i[7], ~fp0_imm_data_f1_i[6], {8{fp0_imm_data_f1_i[6]}},
                                                   fp0_imm_data_f1_i[5:0], {48{1'b0}} };
      default            : neon_modimm0_data_f1 = {64{1'bx}};
    endcase

  always @*
    case (fp1_imm_data_f1_i[12:8])
      // {op, cmode}
      `ca53dpu_sel_x000x : neon_modimm1_data_f1 = {2{ {24{1'b0}}, fp1_imm_data_f1_i[7:0]}};
      `ca53dpu_sel_x001x : neon_modimm1_data_f1 = {2{ {16{1'b0}}, fp1_imm_data_f1_i[7:0], { 8{1'b0}} }};
      `ca53dpu_sel_x010x : neon_modimm1_data_f1 = {2{ { 8{1'b0}}, fp1_imm_data_f1_i[7:0], {16{1'b0}} }};
      `ca53dpu_sel_x011x : neon_modimm1_data_f1 = {2{             fp1_imm_data_f1_i[7:0], {24{1'b0}} }};
      `ca53dpu_sel_x100x : neon_modimm1_data_f1 = {4{ { 8{1'b0}}, fp1_imm_data_f1_i[7:0]}};
      `ca53dpu_sel_x101x : neon_modimm1_data_f1 = {4{fp1_imm_data_f1_i[7:0], {8{1'b0}} }};
      `ca53dpu_sel_x1100 : neon_modimm1_data_f1 = {2{ {16{1'b0}}, fp1_imm_data_f1_i[7:0], { 8{1'b1}} }};
      `ca53dpu_sel_x1101 : neon_modimm1_data_f1 = {2{ { 8{1'b0}}, fp1_imm_data_f1_i[7:0], {16{1'b1}} }};
      5'b01110           : neon_modimm1_data_f1 = {8{fp1_imm_data_f1_i[7:0]}};
      5'b11110           : neon_modimm1_data_f1 = { {8{fp1_imm_data_f1_i[7]}}, {8{fp1_imm_data_f1_i[6]}},
                                                    {8{fp1_imm_data_f1_i[5]}}, {8{fp1_imm_data_f1_i[4]}},
                                                    {8{fp1_imm_data_f1_i[3]}}, {8{fp1_imm_data_f1_i[2]}},
                                                    {8{fp1_imm_data_f1_i[1]}}, {8{fp1_imm_data_f1_i[0]}} };
      5'b01111           : neon_modimm1_data_f1 = {2{fp1_imm_data_f1_i[7], ~fp1_imm_data_f1_i[6], {5{fp1_imm_data_f1_i[6]}},
                                                     fp1_imm_data_f1_i[5:0], {19{1'b0}} }};
      5'b11111           : neon_modimm1_data_f1 = {fp1_imm_data_f1_i[7], ~fp1_imm_data_f1_i[6], {8{fp1_imm_data_f1_i[6]}},
                                                   fp1_imm_data_f1_i[5:0], {48{1'b0}} };
      default            : neon_modimm1_data_f1 = {64{1'bx}};
    endcase

  // ------------------------------------------------------
  // Read data muxes
  // ------------------------------------------------------

  // Generate transposed data busses for pairwise operations
  assign a0_trans32 = {fwd_data_fr1_f1[31: 0],
                       fwd_data_fr2_f1[31: 0]};
  assign b0_trans32 = {fwd_data_fr1_f1[63:32],
                       fwd_data_fr2_f1[63:32]};

  assign a1_trans32 = {fwd_data_fr4_f1[31: 0],
                       fwd_data_fr5_f1[31: 0]};
  assign b1_trans32 = {fwd_data_fr4_f1[63:32],
                       fwd_data_fr5_f1[63:32]};

  assign a0_two     = (add0_ctl_f1[`CA53_FP_NEON_ADD_SIZE_SEL_BITS] == 2'b11) ? 64'h4000000000000000
                                                                              : {2{32'h40000000}};
  assign a0_three   = (add0_ctl_f1[`CA53_FP_NEON_ADD_SIZE_SEL_BITS] == 2'b11) ? 64'h4008000000000000
                                                                              : {2{32'h40400000}};

  assign a1_two     = (add1_ctl_f1[`CA53_FP_NEON_ADD_SIZE_SEL_BITS] == 2'b11) ? 64'h4000000000000000
                                                                              : {2{32'h40000000}};
  assign a1_three   = (add1_ctl_f1[`CA53_FP_NEON_ADD_SIZE_SEL_BITS] == 2'b11) ? 64'h4008000000000000
                                                                              : {2{32'h40400000}};

  // Add data selection muxing
  assign fad0_a_data_f1 = ({64{sel_fad0_a_f1_i == `CA53_SEL_FAD_A_FR2}}   & fwd_data_fr2_f1) |
                          ({64{sel_fad0_a_f1_i == `CA53_SEL_FAD_A_TWO}}   & a0_two)          |
                          ({64{sel_fad0_a_f1_i == `CA53_SEL_FAD_A_THREE}} & a0_three)        |
                          ({64{sel_fad0_a_f1_i == `CA53_SEL_FAD_A_TRN32}} & a0_trans32);

  assign fad0_b_data_f1 = ({64{sel_fad0_b_f1_i == `CA53_SEL_FAD_B_FR1}}   & fwd_data_fr1_f1)      |
                          ({64{sel_fad0_b_f1_i == `CA53_SEL_FAD_B_FML_Q}} & fml0_data_f5)         |
                          ({64{sel_fad0_b_f1_i == `CA53_SEL_FAD_B_IMM}}   & neon_modimm0_data_f1) |
                          ({64{sel_fad0_b_f1_i == `CA53_SEL_FAD_B_TRN32}} & b0_trans32)           |
                          ({64{sel_fad0_b_f1_i == `CA53_SEL_FAD_B_STR}}   & st0_data_ex1_i);

  assign fad0_c_data_f1 = ({64{sel_fad0_c_f1_i == `CA53_SEL_FAD_C_FR0}}   & fwd_data_fr0_f1)             |
                          ({64{sel_fad0_c_f1_i == `CA53_SEL_FAD_C_IMM}}   & {8{fp0_imm_data_f1_i[7:0]}}) |
                          ({64{add0_fused_mac_f1}}                        & fml0_extra_data_f5);

  assign fad1_a_data_f1 = ({64{sel_fad1_a_f1_i == `CA53_SEL_FAD_A_FR2}}   & fwd_data_fr5_f1) |
                          ({64{sel_fad1_a_f1_i == `CA53_SEL_FAD_A_TWO}}   & a1_two)          |
                          ({64{sel_fad1_a_f1_i == `CA53_SEL_FAD_A_THREE}} & a1_three)        |
                          ({64{sel_fad1_a_f1_i == `CA53_SEL_FAD_A_TRN32}} & a1_trans32);

  assign fad1_b_data_f1 = ({64{sel_fad1_b_f1_i == `CA53_SEL_FAD_B_FR1}}   & fwd_data_fr4_f1)      |
                          ({64{sel_fad1_b_f1_i == `CA53_SEL_FAD_B_FML_Q}} & fml1_data_f5)         |
                          ({64{sel_fad1_b_f1_i == `CA53_SEL_FAD_B_IMM}}   & neon_modimm1_data_f1) |
                          ({64{sel_fad1_b_f1_i == `CA53_SEL_FAD_B_TRN32}} & b1_trans32)           |
                          ({64{sel_fad1_b_f1_i == `CA53_SEL_FAD_B_STR}}   & st1_data_ex1_i);

  assign fad1_c_data_f1 = ({64{sel_fad1_c_f1_i == `CA53_SEL_FAD_C_FR0}}   & fwd_data_fr3_f1)             |
                          ({64{sel_fad1_c_f1_i == `CA53_SEL_FAD_C_IMM}}   & {8{fp1_imm_data_f1_i[7:0]}}) |
                          ({64{add1_fused_mac_f1}}                        & fml1_extra_data_f5);

  // Multiply data selection muxing
  assign fml0_a_data_f1 =  {64{sel_fml0_a_f1_i == `CA53_SEL_FML_A_FR0}}   & fwd_data_fr0_f1;
  assign fml0_b_data_f1 =  {64{sel_fml0_b_f1_i == `CA53_SEL_FML_B_FR1}}   & fwd_data_fr1_f1;
  assign fml0_c_data_f1 =  {64{sel_fml0_c_f1_i == `CA53_SEL_FML_C_FR2}}   & fwd_data_fr2_f1;

  assign fml1_a_data_f1 =  {64{sel_fml1_a_f1_i == `CA53_SEL_FML_A_FR0}}   & fwd_data_fr3_f1;
  assign fml1_b_data_f1 =  {64{sel_fml1_b_f1_i == `CA53_SEL_FML_B_FR1}}   & fwd_data_fr4_f1;
  assign fml1_c_data_f1 =  {64{sel_fml1_c_f1_i == `CA53_SEL_FML_C_FR2}}   & fwd_data_fr5_f1;

  // Since the crypto logic always reads from registers and has very little
  // logic in F1, drive the forwarded data directly without gating
  assign crypto_a_data_f1 = {fwd_data_fr3_f1, fwd_data_fr0_f1};
  assign crypto_b_data_f1 = {fwd_data_fr4_f1, fwd_data_fr1_f1};
  assign crypto_c_data_f1 = {fwd_data_fr5_f1, fwd_data_fr2_f1};

  // -----------------------------------------------------
  // F2 Stage
  // -----------------------------------------------------
  assign imm_data_f2_en = ~stall_wr_i & issue_to_ex2_fpu_i;

  always @(posedge clk_fp)
    if (imm_data_f2_en) begin
      fp0_imm_data_f2  <= fp0_imm_data_f1_i[7:0];
      fp1_imm_data_f2  <= fp1_imm_data_f1_i[7:0];
    end

  // ------------------------------------------------------
  // Locally generated FPU datapath control signals
  // ------------------------------------------------------

  assign fp0_rmode_f1        = fp0_pipectl_f1_i[`CA53_FP_PIPECTL_RMODE_BITS];
  assign fp0_force_dn_fz_f1  = fp0_pipectl_f1_i[`CA53_FP_PIPECTL_FORCE_DN_FZ_BITS];

  assign fp1_rmode_f1        = fp1_pipectl_f1_i[`CA53_FP_PIPECTL_RMODE_BITS];
  assign fp1_force_dn_fz_f1  = fp1_pipectl_f1_i[`CA53_FP_PIPECTL_FORCE_DN_FZ_BITS];

  assign round_mode_0_f1 = (fp0_rmode_f1 == `CA53_FP_RMODE_FPCR) ? {1'b0, cp_fpcr_rmode_i[1:0]}
                                                                 : fp0_rmode_f1;

  assign round_mode_1_f1 = (fp1_rmode_f1 == `CA53_FP_RMODE_FPCR) ? {1'b0, cp_fpcr_rmode_i[1:0]}
                                                                 : fp1_rmode_f1;

  // Signal the FP ALU datapath that an sFMAC has been inserted
  // so it can use the rounding mode that the multiplier used
  assign fp0_sfmac_f1 = (sel_fad0_b_f1_i == `CA53_SEL_FAD_B_FML_Q);
  assign fp1_sfmac_f1 = (sel_fad1_b_f1_i == `CA53_SEL_FAD_B_FML_Q);

  // A VRSQRTS instruction must decrement the exponent of the final result
  // Signal this instruction to the ALU pipe
  assign fp0_vrsqrts_f1 = (sel_fad0_a_f1_i == `CA53_SEL_FAD_A_THREE);
  assign fp1_vrsqrts_f1 = (sel_fad1_a_f1_i == `CA53_SEL_FAD_A_THREE);

  // ------------------------------------------------------
  // FPU Datapath
  // ------------------------------------------------------

  assign fp_rm_add0_f1       = fp0_sfmac_f1 ? {1'b0, mac0_round_mode_f5} : round_mode_0_f1;
  assign add0_force_dn_fz_f1 = fp0_sfmac_f1 ? mac0_force_dn_fz_f5        : fp0_force_dn_fz_f1;
  assign add0_fused_mac_f1   = fp0_sfmac_f1 & mac0_fused_mac_f5;

  assign fp_rm_add1_f1       = fp1_sfmac_f1 ? {1'b0, mac1_round_mode_f5} : round_mode_1_f1;
  assign add1_force_dn_fz_f1 = fp1_sfmac_f1 ? mac1_force_dn_fz_f5        : fp1_force_dn_fz_f1;
  assign add1_fused_mac_f1   = fp1_sfmac_f1 & mac1_fused_mac_f5;

  // FP add pipe control signals
  assign add_enable_f1  = {fp_ex_pipe_f1_i[`CA53_FP_EX_PIPE_ADD1], fp_ex_pipe_f1_i[`CA53_FP_EX_PIPE_ADD0]};

  always @* begin
    add0_ctl_f1 = fp0_pipectl_f1_i[`CA53_FP_PIPECTL_ADD_CTL_BITS];

    if (fp0_sfmac_f1) begin
      add0_ctl_f1[`CA53_FP_ADD_VECTOR_FP_OP_BITS] = mul0_dual_fp_f5;

      if (fp0_vrsqrts_f1)
        add0_ctl_f1[`CA53_FP_ADD_FP_OP_BITS]      = `CA53_FP_OP_HADD;
    end
  end

  always @* begin
    add1_ctl_f1 = fp1_pipectl_f1_i[`CA53_FP_PIPECTL_ADD_CTL_BITS];

    if (fp1_sfmac_f1) begin
      add1_ctl_f1[`CA53_FP_ADD_VECTOR_FP_OP_BITS] = mul1_dual_fp_f5;

      if (fp1_vrsqrts_f1)
        add1_ctl_f1[`CA53_FP_ADD_FP_OP_BITS]      = `CA53_FP_OP_HADD;
    end
  end

  ca53dpu_fp_alu #(.CRYPTO(CRYPTO), .IS_PIPE0(1'b1)) u_ca53dpu_fp_alu0 (
    .clk_fp_alu           (clk_fp_alu0),
    .reset_n              (reset_n),
    .advance_pipeline_i   (advance_pipeline_i),
    .rm_f1_i              (fp_rm_add0_f1[`CA53_FP_RMODE_W-1:0]),
    .force_dn_fz_f1_i     (add0_force_dn_fz_f1),
    .fpscr_fz_i           (cp_fpcr_fz_i),
    .fpscr_dn_i           (cp_fpcr_dn_i),
    .fpscr_ahp_i          (cp_fpcr_ahp_i),
    .enable_f1_i          (add_enable_f1[0]),
    .add_ctl_f1_i         (add0_ctl_f1),
    .fused_mac_f1_i       (add0_fused_mac_f1),
    .imm_data_f1_i        (fp0_imm_data_f1_i[6:0]),
    .imm_data_f2_i        (fp0_imm_data_f2[7:0]),
    .fad_a_data_f1_i      (fad0_a_data_f1[63:0]),
    .fad_b_data_f1_i      (fad0_b_data_f1[63:0]),
    .fad_c_data_f1_i      (fad0_c_data_f1[63:0]),
    .alu0_csel_pass_ex2_i (alu0_csel_pass_ex2_i),
    .fad_a_fwd_f2_i       (fad0_a_fwd_f2[1:0]),
    .fad_b_fwd_f2_i       (fad0_b_fwd_f2[1:0]),
    .fwd_data_fr1_f2_i    (fwd_data_fr1_f2[63:0]),
    .fwd_data_fr2_f2_i    (fwd_data_fr2_f2[63:0]),
    .add_enable_f2_o      (add_enable_f2[0]),
    .add_enable_f3_o      (add_enable_f3[0]),
    .fp_alu_f2i_res_f3_o  (fp_alu0_f2i_res_f3_o[63:0]),
    .fad_early_data_f3_o  (fad0_early_data_f3[63:0]),
    .fad_early_data_f4_o  (fad0_early_data_f4[63:0]),
    .fad_data_f5_o        (fad0_data_f5[63:0]),
    .add_xflags_f5_o      (fad0_xflags_f5),
    .fp_cmpflags_f2_o     (fp_cflags_add0_f2_o[3:0])
  );

  ca53dpu_fp_alu #(.CRYPTO(CRYPTO), .IS_PIPE0(1'b0)) u_ca53dpu_fp_alu1 (
    .clk_fp_alu           (clk_fp_alu1),
    .reset_n              (reset_n),
    .advance_pipeline_i   (advance_pipeline_i),
    .rm_f1_i              (fp_rm_add1_f1[`CA53_FP_RMODE_W-1:0]),
    .force_dn_fz_f1_i     (add1_force_dn_fz_f1),
    .fpscr_fz_i           (cp_fpcr_fz_i),
    .fpscr_dn_i           (cp_fpcr_dn_i),
    .fpscr_ahp_i          (cp_fpcr_ahp_i),
    .enable_f1_i          (add_enable_f1[1]),
    .add_ctl_f1_i         (add1_ctl_f1),
    .fused_mac_f1_i       (add1_fused_mac_f1),
    .imm_data_f1_i        (fp1_imm_data_f1_i[6:0]),
    .imm_data_f2_i        (fp1_imm_data_f2[7:0]),
    .fad_a_data_f1_i      (fad1_a_data_f1[63:0]),
    .fad_b_data_f1_i      (fad1_b_data_f1[63:0]),
    .fad_c_data_f1_i      (fad1_c_data_f1[63:0]),
    .alu0_csel_pass_ex2_i (1'b0),
    .fad_a_fwd_f2_i       (fad1_a_fwd_f2[1:0]),
    .fad_b_fwd_f2_i       (fad1_b_fwd_f2[1:0]),
    .fwd_data_fr1_f2_i    (fwd_data_fr4_f2[63:0]),
    .fwd_data_fr2_f2_i    (fwd_data_fr5_f2[63:0]),
    .add_enable_f2_o      (add_enable_f2[1]),
    .add_enable_f3_o      (add_enable_f3[1]),
    .fp_alu_f2i_res_f3_o  (fp_alu1_f2i_res_f3_o[63:0]),
    .fad_early_data_f3_o  (fad1_early_data_f3[63:0]),
    .fad_early_data_f4_o  (fad1_early_data_f4[63:0]),
    .fad_data_f5_o        (fad1_data_f5[63:0]),
    .add_xflags_f5_o      (fad1_xflags_f5),
    .fp_cmpflags_f2_o     (fp_cflags_add1_f2_o[3:0])
  );

  assign fp_xflags_add0_f5_o = fad0_xflags_f5;
  assign fp_xflags_add1_f5_o = fad1_xflags_f5;

  // FP multiply pipe control signals
  assign mul_enable_f1  = {fp_ex_pipe_f1_i[`CA53_FP_EX_PIPE_MUL1],  fp_ex_pipe_f1_i[`CA53_FP_EX_PIPE_MUL0]};

  assign mul0_ctl_f1    = fp0_pipectl_f1_i[`CA53_FP_PIPECTL_MUL_CTL_BITS];
  assign mul1_ctl_f1    = fp1_pipectl_f1_i[`CA53_FP_PIPECTL_MUL_CTL_BITS];

  ca53dpu_fp_mul u_ca53dpu_fp_mul0 (
    .clk_fp_mul            (clk_fp_mul0),
    .reset_n               (reset_n),
    .stall_wr_i            (stall_wr_i),
    .flush_ret_i           (flush_ret_i),
    .advance_pipeline_i    (advance_pipeline_i),
    .round_mode_f1_i       (round_mode_0_f1[1:0]),
    .force_dn_fz_f1_i      (fp0_force_dn_fz_f1),
    .fpscr_dn_i            (cp_fpcr_dn_i),
    .fpscr_fz_i            (cp_fpcr_fz_i),
    .mul_enable_f1_i       (mul_enable_f1[0]),
    .mul_ctl_f1_i          (mul0_ctl_f1),
    .collect_div_f1_i      (fp_div_enb_f1_i[0]),
    .fml_a_data_f1_i       (fml0_a_data_f1[63:0]),
    .fml_b_data_f1_i       (fml0_b_data_f1[63:0]),
    .fml_c_data_f1_i       (fml0_c_data_f1[63:0]),
    .fp_mul_fwd_f2_i       (fp_mul_fwd_f2_i[0]),
    .fml_data_f5_o         (fml0_data_f5[63:0]),
    .fml_extra_data_f5_o   (fml0_extra_data_f5[63:0]),
    .mul_enable_f2_o       (mul_enable_f2[0]),
    .mul_enable_f3_o       (mul_enable_f3[0]),
    .mul_xflags_o          (fml0_xflags_f5),
    .mac_round_mode_f5_o   (mac0_round_mode_f5),
    .mac_force_dn_fz_f5_o  (mac0_force_dn_fz_f5),
    .div_fp_busy_nxt_cyc_o (div0_fp_busy_nxt_cyc),
    .fused_mac_f5_o        (mac0_fused_mac_f5),
    .mul_dual_fp_f5_o      (mul0_dual_fp_f5)
  );

  ca53dpu_fp_mul u_ca53dpu_fp_mul1 (
    .clk_fp_mul            (clk_fp_mul1),
    .reset_n               (reset_n),
    .stall_wr_i            (stall_wr_i),
    .flush_ret_i           (flush_ret_i),
    .advance_pipeline_i    (advance_pipeline_i),
    .round_mode_f1_i       (round_mode_1_f1[1:0]),
    .force_dn_fz_f1_i      (fp1_force_dn_fz_f1),
    .fpscr_dn_i            (cp_fpcr_dn_i),
    .fpscr_fz_i            (cp_fpcr_fz_i),
    .mul_enable_f1_i       (mul_enable_f1[1]),
    .mul_ctl_f1_i          (mul1_ctl_f1),
    .collect_div_f1_i      (fp_div_enb_f1_i[1]),
    .fml_a_data_f1_i       (fml1_a_data_f1[63:0]),
    .fml_b_data_f1_i       (fml1_b_data_f1[63:0]),
    .fml_c_data_f1_i       (fml1_c_data_f1[63:0]),
    .fp_mul_fwd_f2_i       (fp_mul_fwd_f2_i[1]),
    .fml_data_f5_o         (fml1_data_f5[63:0]),
    .fml_extra_data_f5_o   (fml1_extra_data_f5[63:0]),
    .mul_enable_f2_o       (mul_enable_f2[1]),
    .mul_enable_f3_o       (mul_enable_f3[1]),
    .mul_xflags_o          (fml1_xflags_f5),
    .mac_round_mode_f5_o   (mac1_round_mode_f5),
    .mac_force_dn_fz_f5_o  (mac1_force_dn_fz_f5),
    .div_fp_busy_nxt_cyc_o (div1_fp_busy_nxt_cyc),
    .fused_mac_f5_o        (mac1_fused_mac_f5),
    .mul_dual_fp_f5_o      (mul1_dual_fp_f5)
  );

  assign fp_xflags_mul0_f5_o = fml0_xflags_f5;
  assign fp_xflags_mul1_f5_o = fml1_xflags_f5;
  assign fp_div_busy_nxt_cyc_o = {div1_fp_busy_nxt_cyc, div0_fp_busy_nxt_cyc};

  // Cryptography pipeline
  assign crypto_op_f1 = fp0_pipectl_f1_i[`CA53_CRYPTO_OP_W-1:0];

  generate if (CRYPTO) begin : g_crypto
    ca53dpu_crypto u_crypto (
      .clk_crypto         (clk_crypto),
      .reset_n            (reset_n),
      .advance_pipeline_i (advance_pipeline_i),
      .crypto_enable_f1_i (crypto_enable_f1_i),
      .crypto_op_f1_i     (crypto_op_f1[`CA53_CRYPTO_OP_W-1:0]),
      .crypto_a_data_f1_i (crypto_a_data_f1[127:0]),
      .crypto_b_data_f1_i (crypto_b_data_f1[127:0]),
      .crypto_c_data_f1_i (crypto_c_data_f1[127:0]),
      .crypto_active_o    (crypto_active_o),
      .crypto_data_f3_o   (crypto_data_f3),
      .crypto_data_f5_o   (crypto_data_f5)
    );

  end else begin : g_crypto_stubs
    assign crypto_active_o = 1'b0;
    assign crypto_data_f3  = {128{1'b0}};
    assign crypto_data_f5  = {128{1'b0}};
  end endgenerate

  // Output F1 FP data for store pipeline
  always @*
    case (str0_sel_fp_f1_i)
      `CA53_STR0_FP_SEL_FR0:      fp_str0_data_f1_o =  fwd_data_fr0_f1[63:0];
      `CA53_STR0_FP_SEL_FR0_FR1:  fp_str0_data_f1_o = {fwd_data_fr1_f1[31:0], fwd_data_fr0_f1[31:0]};
      `CA53_STR0_FP_SEL_FR4:      fp_str0_data_f1_o =  fwd_data_fr4_f1[63:0];
      default:                    fp_str0_data_f1_o = {64{1'bx}};
    endcase

  always @*
    case (str1_sel_fp_f1_i)
      `CA53_STR1_FP_SEL_FR3:      fp_str1_data_f1_o =  fwd_data_fr3_f1[63:0];
      `CA53_STR1_FP_SEL_FR3_FR4:  fp_str1_data_f1_o = {fwd_data_fr4_f1[31:0], fwd_data_fr3_f1[31:0]};
      `CA53_STR1_FP_SEL_FR1:      fp_str1_data_f1_o =  fwd_data_fr1_f1[63:0];
      default:                    fp_str1_data_f1_o = {64{1'bx}};
    endcase

  // ------------------------------------------------------
  // F2 Stage Forwarding muxes
  // ------------------------------------------------------

  generate for (i = 0; i < 2; i = i + 1) begin : g_fwd_f2
    always @*
      case (fr0_fwd_f2_i[i*3+:3])
        `CA53_FWD_FW0_F5 : fwd_data_raw_fr0_f2[i*32+:32] = fwd_rf_wr_data_fw0_f5[i[0]*32+:32];
        `CA53_FWD_FW0_F4 : fwd_data_raw_fr0_f2[i*32+:32] = fwd_rf_wr_data_fw0_f4[i[0]*32+:32];
        `CA53_FWD_FW0_F3 : fwd_data_raw_fr0_f2[i*32+:32] = fwd_rf_wr_data_fw0_f3[i[0]*32+:32];
        `CA53_FWD_FW1_F5 : fwd_data_raw_fr0_f2[i*32+:32] = fwd_rf_wr_data_fw1_f5[i[0]*32+:32];
        `CA53_FWD_FW1_F4 : fwd_data_raw_fr0_f2[i*32+:32] = fwd_rf_wr_data_fw1_f4[i[0]*32+:32];
        `CA53_FWD_FW1_F3 : fwd_data_raw_fr0_f2[i*32+:32] = fwd_rf_wr_data_fw1_f3[i[0]*32+:32];
        default          : fwd_data_raw_fr0_f2[i*32+:32] = {32{1'bx}};
      endcase

    always @*
      case (fr1_fwd_f2_i[i*3+:3])
        `CA53_FWD_FW0_F5 : fwd_data_raw_fr1_f2[i*32+:32] = fwd_rf_wr_data_fw0_f5[i[0]*32+:32];
        `CA53_FWD_FW0_F4 : fwd_data_raw_fr1_f2[i*32+:32] = fwd_rf_wr_data_fw0_f4[i[0]*32+:32];
        `CA53_FWD_FW0_F3 : fwd_data_raw_fr1_f2[i*32+:32] = fwd_rf_wr_data_fw0_f3[i[0]*32+:32];
        `CA53_FWD_FW1_F5 : fwd_data_raw_fr1_f2[i*32+:32] = fwd_rf_wr_data_fw1_f5[i[0]*32+:32];
        `CA53_FWD_FW1_F4 : fwd_data_raw_fr1_f2[i*32+:32] = fwd_rf_wr_data_fw1_f4[i[0]*32+:32];
        `CA53_FWD_FW1_F3 : fwd_data_raw_fr1_f2[i*32+:32] = fwd_rf_wr_data_fw1_f3[i[0]*32+:32];
        default          : fwd_data_raw_fr1_f2[i*32+:32] = {32{1'bx}};
      endcase

    always @*
      case (fr2_fwd_f2_i[i*3+:3])
        `CA53_FWD_FW0_F5 : fwd_data_raw_fr2_f2[i*32+:32] = fwd_rf_wr_data_fw0_f5[i[0]*32+:32];
        `CA53_FWD_FW0_F4 : fwd_data_raw_fr2_f2[i*32+:32] = fwd_rf_wr_data_fw0_f4[i[0]*32+:32];
        `CA53_FWD_FW0_F3 : fwd_data_raw_fr2_f2[i*32+:32] = fwd_rf_wr_data_fw0_f3[i[0]*32+:32];
        `CA53_FWD_FW1_F5 : fwd_data_raw_fr2_f2[i*32+:32] = fwd_rf_wr_data_fw1_f5[i[0]*32+:32];
        `CA53_FWD_FW1_F4 : fwd_data_raw_fr2_f2[i*32+:32] = fwd_rf_wr_data_fw1_f4[i[0]*32+:32];
        `CA53_FWD_FW1_F3 : fwd_data_raw_fr2_f2[i*32+:32] = fwd_rf_wr_data_fw1_f3[i[0]*32+:32];
        default          : fwd_data_raw_fr2_f2[i*32+:32] = {32{1'bx}};
      endcase

    always @*
      case (fr3_fwd_f2_i[i*3+:3])
        `CA53_FWD_FW0_F5 : fwd_data_raw_fr3_f2[i*32+:32] = fwd_rf_wr_data_fw0_f5[i[0]*32+:32];
        `CA53_FWD_FW0_F4 : fwd_data_raw_fr3_f2[i*32+:32] = fwd_rf_wr_data_fw0_f4[i[0]*32+:32];
        `CA53_FWD_FW0_F3 : fwd_data_raw_fr3_f2[i*32+:32] = fwd_rf_wr_data_fw0_f3[i[0]*32+:32];
        `CA53_FWD_FW1_F5 : fwd_data_raw_fr3_f2[i*32+:32] = fwd_rf_wr_data_fw1_f5[i[0]*32+:32];
        `CA53_FWD_FW1_F4 : fwd_data_raw_fr3_f2[i*32+:32] = fwd_rf_wr_data_fw1_f4[i[0]*32+:32];
        `CA53_FWD_FW1_F3 : fwd_data_raw_fr3_f2[i*32+:32] = fwd_rf_wr_data_fw1_f3[i[0]*32+:32];
        default          : fwd_data_raw_fr3_f2[i*32+:32] = {32{1'bx}};
      endcase

    always @*
      case (fr4_fwd_f2_i[i*3+:3])
        `CA53_FWD_FW0_F5 : fwd_data_raw_fr4_f2[i*32+:32] = fwd_rf_wr_data_fw0_f5[i[0]*32+:32];
        `CA53_FWD_FW0_F4 : fwd_data_raw_fr4_f2[i*32+:32] = fwd_rf_wr_data_fw0_f4[i[0]*32+:32];
        `CA53_FWD_FW0_F3 : fwd_data_raw_fr4_f2[i*32+:32] = fwd_rf_wr_data_fw0_f3[i[0]*32+:32];
        `CA53_FWD_FW1_F5 : fwd_data_raw_fr4_f2[i*32+:32] = fwd_rf_wr_data_fw1_f5[i[0]*32+:32];
        `CA53_FWD_FW1_F4 : fwd_data_raw_fr4_f2[i*32+:32] = fwd_rf_wr_data_fw1_f4[i[0]*32+:32];
        `CA53_FWD_FW1_F3 : fwd_data_raw_fr4_f2[i*32+:32] = fwd_rf_wr_data_fw1_f3[i[0]*32+:32];
        default          : fwd_data_raw_fr4_f2[i*32+:32] = {32{1'bx}};
      endcase

    always @*
      case (fr5_fwd_f2_i[i*3+:3])
        `CA53_FWD_FW0_F5 : fwd_data_raw_fr5_f2[i*32+:32] = fwd_rf_wr_data_fw0_f5[i[0]*32+:32];
        `CA53_FWD_FW0_F4 : fwd_data_raw_fr5_f2[i*32+:32] = fwd_rf_wr_data_fw0_f4[i[0]*32+:32];
        `CA53_FWD_FW0_F3 : fwd_data_raw_fr5_f2[i*32+:32] = fwd_rf_wr_data_fw0_f3[i[0]*32+:32];
        `CA53_FWD_FW1_F5 : fwd_data_raw_fr5_f2[i*32+:32] = fwd_rf_wr_data_fw1_f5[i[0]*32+:32];
        `CA53_FWD_FW1_F4 : fwd_data_raw_fr5_f2[i*32+:32] = fwd_rf_wr_data_fw1_f4[i[0]*32+:32];
        `CA53_FWD_FW1_F3 : fwd_data_raw_fr5_f2[i*32+:32] = fwd_rf_wr_data_fw1_f3[i[0]*32+:32];
        default          : fwd_data_raw_fr5_f2[i*32+:32] = {32{1'bx}};
      endcase
  end endgenerate

  assign fwd_data_fr0_f2[63:32] = fwd_data_raw_fr0_f2[63:32];
  assign fwd_data_fr0_f2[31: 0] = (rf_rd_en_fr0_f2_i[1:0] == 2'b10) ? fwd_data_raw_fr0_f2[63:32] :
                                                                      fwd_data_raw_fr0_f2[31: 0];

  assign fwd_data_fr1_f2[63:32] = (rf_rd_en_fr1_f2_i[1:0] == 2'b01) ? fwd_data_raw_fr1_f2[31: 0] :
                                                                      fwd_data_raw_fr1_f2[63:32];
  assign fwd_data_fr1_f2[31: 0] = (rf_rd_en_fr1_f2_i[1:0] == 2'b10) ? fwd_data_raw_fr1_f2[63:32] :
                                                                      fwd_data_raw_fr1_f2[31: 0];

  assign fwd_data_fr2_f2[63:32] = fwd_data_raw_fr2_f2[63:32];
  assign fwd_data_fr2_f2[31: 0] = (rf_rd_en_fr2_f2_i[1:0] == 2'b10) ? fwd_data_raw_fr2_f2[63:32] :
                                                                      fwd_data_raw_fr2_f2[31: 0];

  assign fwd_data_fr3_f2[63:32] = fwd_data_raw_fr3_f2[63:32];
  assign fwd_data_fr3_f2[31: 0] = (rf_rd_en_fr3_f2_i[1:0] == 2'b10) ? fwd_data_raw_fr3_f2[63:32] :
                                                                      fwd_data_raw_fr3_f2[31: 0];

  assign fwd_data_fr4_f2[63:32] = (rf_rd_en_fr4_f2_i[1:0] == 2'b01) ? fwd_data_raw_fr4_f2[31: 0] :
                                                                      fwd_data_raw_fr4_f2[63:32];
  assign fwd_data_fr4_f2[31: 0] = (rf_rd_en_fr4_f2_i[1:0] == 2'b10) ? fwd_data_raw_fr4_f2[63:32] :
                                                                      fwd_data_raw_fr4_f2[31: 0];

  assign fwd_data_fr5_f2[63:32] = fwd_data_raw_fr5_f2[63:32];
  assign fwd_data_fr5_f2[31: 0] = (rf_rd_en_fr5_f2_i[1:0] == 2'b10) ? fwd_data_raw_fr5_f2[63:32] :
                                                                      fwd_data_raw_fr5_f2[31: 0];

  // Controls to add pipes to indicate when to use forwarded data
  assign fad0_b_fwd_f2[1] = (rf_rd_en_fr1_f2_i[1:0] == 2'b01) ? (fr1_fwd_f2_i[2:0] != `CA53_FWD_FNULL) :
                                                                (fr1_fwd_f2_i[5:3] != `CA53_FWD_FNULL);
  assign fad0_b_fwd_f2[0] = (rf_rd_en_fr1_f2_i[1:0] == 2'b10) ? (fr1_fwd_f2_i[5:3] != `CA53_FWD_FNULL) :
                                                                (fr1_fwd_f2_i[2:0] != `CA53_FWD_FNULL);

  assign fad0_a_fwd_f2[1] = (fr2_fwd_f2_i[5:3] != `CA53_FWD_FNULL);
  assign fad0_a_fwd_f2[0] = (fr2_fwd_f2_i[2:0] != `CA53_FWD_FNULL);

  assign fad1_b_fwd_f2[1] = (rf_rd_en_fr4_f2_i[1:0] == 2'b01) ? (fr4_fwd_f2_i[2:0] != `CA53_FWD_FNULL) :
                                                                (fr4_fwd_f2_i[5:3] != `CA53_FWD_FNULL);
  assign fad1_b_fwd_f2[0] = (rf_rd_en_fr4_f2_i[1:0] == 2'b10) ? (fr4_fwd_f2_i[5:3] != `CA53_FWD_FNULL) :
                                                                (fr4_fwd_f2_i[2:0] != `CA53_FWD_FNULL);

  assign fad1_a_fwd_f2[1] = (fr5_fwd_f2_i[5:3] != `CA53_FWD_FNULL);
  assign fad1_a_fwd_f2[0] = (fr5_fwd_f2_i[2:0] != `CA53_FWD_FNULL);

  // Output F2 FP data for store pipeline
  always @*
    case (str0_sel_fp_f2_i)
      `CA53_STR0_FP_SEL_FR0:      fp_str0_data_f2_o =  fwd_data_fr0_f2[63:0];
      `CA53_STR0_FP_SEL_FR0_FR1:  fp_str0_data_f2_o = {fwd_data_fr1_f2[31:0], fwd_data_fr0_f2[31:0]};
      `CA53_STR0_FP_SEL_FR4:      fp_str0_data_f2_o =  fwd_data_fr4_f2[63:0];
      default:                    fp_str0_data_f2_o = {64{1'bx}};
    endcase

  always @*
    case (str1_sel_fp_f2_i)
      `CA53_STR1_FP_SEL_FR3:      fp_str1_data_f2_o =  fwd_data_fr3_f2[63:0];
      `CA53_STR1_FP_SEL_FR3_FR4:  fp_str1_data_f2_o = {fwd_data_fr4_f2[31:0], fwd_data_fr3_f2[31:0]};
      `CA53_STR1_FP_SEL_FR1:      fp_str1_data_f2_o =  fwd_data_fr1_f2[63:0];
      default:                    fp_str1_data_f2_o = {64{1'bx}};
    endcase

  // ------------------------------------------------------
  // F3 datapath (load-store and register transfer)
  // ------------------------------------------------------

  // As the floating point pipeline is skewed any data signals from the integer
  // pipeline that are destined for the FPU register file must be muxed in the F3
  // stage, registered through F4 and then muxed with the FPU datapath signals in
  // the F5 stage before being written to the register file.

  ca53dpu_neon_ld u_dpu_neon_ld (
    .clk_fp                  (clk_fp),
    .reset_n                 (reset_n),
    .stall_wr_i              (stall_wr_i),
    .valid_instrs_wr_i       (valid_instrs_wr_i),
    .first_x64_wr_i          (first_x64_wr_i),
    .neon_vld_ctl_f3_i       (neon_vld_ctl_f3_i),
    .ls_elem_size_wr_i       (ls_elem_size_wr_i),
    .fwd_ld_data_int_wr_i    (fwd_ld_data_int_wr_i),
    .instr_is_cp10_cp11_wr_i (instr_is_cp10_cp11_wr_i),
    .st0_data_wr_i           (st0_data_wr_i[63:0]),
    .ld_data_f3_o            (ld_data_f3),
    .dup_ld_data_f3_o        (dup_ld_data_f3[63:0])
  );

  assign fwd_rf_wr_data_fw0_f3 = ({64{(rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_FAD_Q)}}     & fad0_early_data_f3[63: 0])         |
                                 ({64{(rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_STR)}}       & st0_data_wr_i[63: 0])              |
                                 ({64{(rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_STR_SP) |
                                      (rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_STR_2SP)}}   & {2{st0_data_wr_i[31: 0]}})         |
                                 ({64{(rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_CRYPTO_F3)}} & crypto_data_f3[63: 0]);

  assign fwd_rf_wr_data_fw1_f3 = ({64{(rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_FAD_Q)}}     & fad1_early_data_f3[63: 0])         |
                                 ({64{(rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_STR)}}       & st1_data_wr_i[63: 0])              |
                                 ({64{(rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_STR_SP)}}    & {2{st1_data_wr_i[31:0]}})          |
                                 ({64{(rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_STR_2SP)}}   & {2{st0_data_wr_i[63:32]}})         |
                                 ({64{(rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_CRYPTO_F3)}} & crypto_data_f3[127:64]);

  // Load data is too late for forwarding from F3, so factor in later
  assign ls_rt_data_fw0_f3     = ({64{(rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_DCU_PERM)}}  & {2{ld_data_f3[31: 0]}})            |
                                 ({64{(rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_DCU_SGL) |
                                      (rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_DCU_SGL2)}}  & {2{fwd_ld_data_int_wr_i[31: 0]}})  |
                                 ({64{(rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_DCU_DBL)}}   & fwd_ld_data_int_wr_i[63: 0])       |
                                 ({64{(rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_DCU_DUP) |
                                      (rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_DCU_DUP2)}}  & {2{dup_ld_data_f3[31: 0]}})        |
                                 fwd_rf_wr_data_fw0_f3;
                             
  assign ls_rt_data_fw1_f3     = ({64{(rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_DCU_PERM)}}  & {2{ld_data_f3[63:32]}})            |
                                 ({64{(rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_DCU_SGL)}}   & {2{fwd_ld_data_int_wr_i[31: 0]}})  |
                                 ({64{(rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_DCU_SGL2)}}  & {2{fwd_ld_data_int_wr_i[63:32]}})  |
                                 ({64{(rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_DCU_DBL)}}   & fwd_ld_data_int_wr_i[63: 0])       |
                                 ({64{(rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_DCU_DUP)}}   & {2{dup_ld_data_f3[31: 0]}})        |
                                 ({64{(rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_DCU_DUP2)}}  & {2{dup_ld_data_f3[63:32]}})        |
                                 fwd_rf_wr_data_fw1_f3;
                             
  assign ls_data0_sel_f3 = (rf_wr_en_fw_f3_i &
                            ((rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_DCU_PERM)  |
                             (rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_DCU_SGL)   | 
                             (rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_DCU_SGL2)  | 
                             (rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_DCU_DUP)   |
                             (rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_DCU_DUP2)  | 
                             (rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_STR)       |
                             (rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_STR_SP)    |
                             (rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_STR_2SP)   |
                             (rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_DCU_DBL)   |
                             (rf_wr_src_fw0_f3_i == `CA53_RF_FWR_SRC_CRYPTO_F3)));
  
  assign ls_data1_sel_f3 = (rf_wr_en_fw_f3_i &
                            ((rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_DCU_PERM)  |
                             (rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_DCU_SGL)   | 
                             (rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_DCU_SGL2)  | 
                             (rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_DCU_DUP)   |
                             (rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_DCU_DUP2)  | 
                             (rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_STR)       |
                             (rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_STR_SP)    |
                             (rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_STR_2SP)   |
                             (rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_DCU_DBL)   |
                             (rf_wr_src_fw1_f3_i == `CA53_RF_FWR_SRC_CRYPTO_F3)));
  
  assign en_ls_rt_data_fw0_f4 = ls_data0_sel_f3 & issue_to_f4_i;
  assign en_ls_rt_data_fw1_f4 = ls_data1_sel_f3 & issue_to_f4_i;

  // Datapath registers
  always @(posedge clk_fp)
    if (en_ls_rt_data_fw0_f4)
      ls_rt_data_fw0_f4 <= ls_rt_data_fw0_f3;

  always @(posedge clk_fp)
    if (en_ls_rt_data_fw1_f4)
      ls_rt_data_fw1_f4 <= ls_rt_data_fw1_f3;

  assign fwd_rf_wr_data_fw0_f4 = ((rf_wr_src_fw0_f4_i  == `CA53_RF_FWR_SRC_FAD_Q) &
                                  (rf_wr_when_fw0_f4_i != `CA53_RF_FWR_WHEN_F5)) ? fad0_early_data_f4[63:0]
                                                                                 : ls_rt_data_fw0_f4;
  assign fwd_rf_wr_data_fw1_f4 = ((rf_wr_src_fw1_f4_i  == `CA53_RF_FWR_SRC_FAD_Q) &
                                  (rf_wr_when_fw1_f4_i != `CA53_RF_FWR_WHEN_F5)) ? fad1_early_data_f4[63:0]
                                                                                 : ls_rt_data_fw1_f4;

  // Enable signal for next cycle
  always @(posedge clk_fp or negedge reset_n)
    if (~reset_n) begin
      en_ls_rt_data_fw0_f5 <= 1'b0;
      en_ls_rt_data_fw1_f5 <= 1'b0;
    end else if (advance_pipeline_i) begin
      en_ls_rt_data_fw0_f5 <= en_ls_rt_data_fw0_f4;
      en_ls_rt_data_fw1_f5 <= en_ls_rt_data_fw1_f4;
    end

  // ------------------------------------------------------
  // F4 datapath (load-store and register transfer)
  // ------------------------------------------------------
  assign ls_rt_data0_en_f5 = en_ls_rt_data_fw0_f5 & advance_pipeline_i;
  assign ls_rt_data1_en_f5 = en_ls_rt_data_fw1_f5 & advance_pipeline_i;

  always @(posedge clk_fp)
     if (ls_rt_data0_en_f5)
       ls_rt_data_fw0_f5 <= ls_rt_data_fw0_f4;

  always @(posedge clk_fp)
     if (ls_rt_data1_en_f5)
       ls_rt_data_fw1_f5 <= ls_rt_data_fw1_f4;

  // ------------------------------------------------------
  // F5 datapath
  // ------------------------------------------------------

  assign fwd_rf_wr_data_fw0_f5 = ({64{(rf_wr_src_fw0_f5_i  == `CA53_RF_FWR_SRC_FML_Q)}}       & fml0_data_f5[63:0])   |
                                 ({64{(rf_wr_src_fw0_f5_i  == `CA53_RF_FWR_SRC_FAD_Q)}}       & fad0_data_f5[63:0])   |
                                 ({64{(rf_wr_src_fw0_f5_i  == `CA53_RF_FWR_SRC_FAD_NARROW)}}  & {fad1_data_f5[31:0],
                                                                                                 fad0_data_f5[31:0]}) |
                                 ({64{((rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_STR)       |
                                       (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_STR_SP)    |
                                       (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_STR_2SP)   |
                                       (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_DCU_PERM)  |
                                       (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_DCU_SGL)   |
                                       (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_DCU_SGL2)  |
                                       (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_DCU_DUP)   |
                                       (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_DCU_DUP2)  |
                                       (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_DCU_DBL)   |
                                       (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_CRYPTO_F3))}}  & ls_rt_data_fw0_f5);

  assign fwd_rf_wr_data_fw1_f5 = ({64{(rf_wr_src_fw1_f5_i  == `CA53_RF_FWR_SRC_FML_Q)}}       & fml1_data_f5[63:0])   |
                                 ({64{(rf_wr_src_fw1_f5_i  == `CA53_RF_FWR_SRC_FAD_Q)}}       & fad1_data_f5[63:0])   |
                                 ({64{((rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_STR)       |
                                       (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_STR_SP)    |
                                       (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_STR_2SP)   |
                                       (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_DCU_PERM)  |
                                       (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_DCU_SGL)   |
                                       (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_DCU_SGL2)  |
                                       (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_DCU_DUP)   |
                                       (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_DCU_DUP2)  |
                                       (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_DCU_DBL)   |
                                       (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_CRYPTO_F3))}}  & ls_rt_data_fw1_f5);

  // The data from the F5 output of the cryptography pipeline is too late for forwarding, so mux it in here
  assign rf_wr_data_fw0_f5_o[63:0] = fwd_rf_wr_data_fw0_f5[63:0]    |
                                     ({64{(rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_CRYPTO_F5)}} & crypto_data_f5[63:0]);
  assign rf_wr_data_fw1_f5_o[63:0] = fwd_rf_wr_data_fw1_f5[63:0]    |
                                     ({64{(rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_CRYPTO_F5)}} & crypto_data_f5[127:64]);

  assign fp_dp_en_active_o = ls_data0_sel_f3 | ls_data1_sel_f3 | en_ls_rt_data_fw0_f5 | en_ls_rt_data_fw1_f5;

  //----------------------------------------------------------------------------
  //                     OVL definitions
  //----------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_pipeline_i")
  u_ovl_x_advance_pipeline_i (.clk       (clk_fp),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (advance_pipeline_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_ls_rt_data_fw0_f4")
  u_ovl_x_en_ls_rt_data_fw0_f4 (.clk       (clk_fp),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (en_ls_rt_data_fw0_f4));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_ls_rt_data_fw1_f4")
  u_ovl_x_en_ls_rt_data_fw1_f4 (.clk       (clk_fp),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (en_ls_rt_data_fw1_f4));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: imm_data_f2_en")
  u_ovl_x_imm_data_f2_en (.clk       (clk_fp),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (imm_data_f2_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ls_rt_data0_en_f5")
  u_ovl_x_ls_rt_data0_en_f5 (.clk       (clk_fp),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (ls_rt_data0_en_f5));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ls_rt_data1_en_f5")
  u_ovl_x_ls_rt_data1_en_f5 (.clk       (clk_fp),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (ls_rt_data1_en_f5));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: fp0_sfmac_f1")
  u_ovl_x_fp0_sfmac_f1 (.clk       (clk_fp),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (fp0_sfmac_f1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: fp1_sfmac_f1")
  u_ovl_x_fp1_sfmac_f1 (.clk       (clk_fp),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (fp1_sfmac_f1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: fp0_vrsqrts_f1")
  u_ovl_x_fp0_vrsqrts_f1 (.clk       (clk_fp),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (fp0_vrsqrts_f1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: fp1_vrsqrts_f1")
  u_ovl_x_fp1_vrsqrts_f1 (.clk       (clk_fp),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (fp1_vrsqrts_f1));

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_ill_early_fp_rf_sel_0
  // Checks for illegal early select signal combinations into the FPU RF write
  // port 0
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Illegal early select for data into the fpu RF port 0")
    ovl_ill_early_fp_rf_sel_0 (.clk       (clk_fp),
                               .reset_n   (reset_n),
                               .test_expr ((rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_NONE)        ||
                                           (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_DCU_DUP)     ||
                                           (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_DCU_DUP2)    ||
                                           (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_FAD_Q)       ||
                                           (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_FAD_NARROW)  ||
                                           (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_FML_Q)       ||
                                           (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_DCU_PERM)    ||
                                           (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_DCU_SGL)     ||
                                           (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_DCU_SGL2)    ||
                                           (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_STR)         ||
                                           (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_STR_SP)      ||
                                           (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_STR_2SP)     ||
                                           (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_DCU_DBL)     ||
                                           (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_CRYPTO_F3)   ||
                                           (rf_wr_src_fw0_f5_i == `CA53_RF_FWR_SRC_CRYPTO_F5)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_ill_early_fp_rf_sel_1
  // Checks for illegal early select signal combinations into the FPU RF write
  // port 1
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Illegal early select for data into the fpu RF port 1")
    ovl_ill_early_fp_rf_sel_1 (.clk       (clk_fp),
                               .reset_n   (reset_n),
                               .test_expr ((rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_NONE)        ||
                                           (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_DCU_DUP)     ||
                                           (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_DCU_DUP2)    ||
                                           (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_FAD_Q)       ||
                                           (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_FAD_NARROW)  ||
                                           (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_FML_Q)       ||
                                           (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_DCU_PERM)    ||
                                           (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_DCU_SGL)     ||
                                           (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_DCU_SGL2)    ||
                                           (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_STR)         ||
                                           (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_STR_SP)      ||
                                           (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_STR_2SP)     ||
                                           (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_DCU_DBL)     ||
                                           (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_CRYPTO_F3)   ||
                                           (rf_wr_src_fw1_f5_i == `CA53_RF_FWR_SRC_CRYPTO_F5)));
  // OVL_ASSERT_END

`endif

endmodule // ca53dpu_fp_dp

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
