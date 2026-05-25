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
//      Checked In          : $Date: 2013-04-24 15:01:43 +0100 (Wed, 24 Apr 2013) $
//
//      Revision            : $Revision: 245148 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Dual issue branch decoder
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// This block decodes Slot 1 branch instructions.
//
//-----------------------------------------------------------------------------


`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_dec1_br (
  // Inputs
  input wire                           [32:0] iq_instr_dec1_br_i,
  input wire                                  aarch64_state_i,
  input wire                            [1:0] pdtype_i,
  input wire                                  br_taken_i,
  // Outputs                             
  output wire                                 rf_rd_en_r0_dec1_br_o,
  output wire                                 rf_rd_en_r1_dec1_br_o,
  output wire        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_dec1_br_o,
  output wire        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_dec1_br_o,
  output wire                           [4:0] rf_wr_vaddr_w1_dec1_br_o,
  output wire                                 rf_wr_en_w1_dec1_br_o,
  output wire                                 rf_wr_64b_w1_dec1_br_o,
  output wire      [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_dec1_br_o,
  output wire        [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_dec1_br_o,
  output wire         [`CA53_SEL_SHF_A_W-1:0] dp_data_a_sel_dec1_br_o,
  output wire         [`CA53_SEL_SHF_B_W-1:0] dp_data_b_sel_dec1_br_o,
  output wire         [`CA53_SEL_SHF_C_W-1:0] dp_data_c_sel_dec1_br_o,
  output wire         [`CA53_SEL_STR_A_W-1:0] str_data_a_sel_dec1_br_o,
  output wire         [`CA53_SEL_STR_B_W-1:0] str_data_b_sel_dec1_br_o,
  output wire                                 str_b_valid_dec1_br_o,
  output wire                                 ctl_64bit_op_str_dec1_br_o,
  output wire           [`CA53_EX_PIPE_W-1:0] ex_pipe_dec1_br_o,
  output wire          [`CA53_IMM_DATA_W-1:0] imm_data_dec1_br_o,
  output wire         [`CA53_IMM_SHIFT_W-1:0] imm_shift_dec1_br_o,
  output wire        [`CA53_BR_PIPECTL_W-1:0] br_pipectl_dec1_br_o,
  output wire       [`CA53_ALU_PIPECTL_W-1:0] alu_pipectl_dec1_br_o,
  output wire                                 br_btac_dec1_br_o,
  output wire                                 br_return_dec1_br_o,
  output wire                                 rtn_addr_valid_dec1_br_o,
  output wire                                 pred_br_dec1_br_o,
  output reg                           [27:1] br_offset_dec1_br_o,
  output wire                                 br_pred_takenness_dec1_br_o,
  output wire                                 br_call_dec1_br_o,
  output wire                                 br_x_bit_dec1_br_o,

  output wire  [`CA53_SLOT1_INSTR_TYPE_W-1:0] slot1_instr_type_dec1_br_o,
  output wire                                 a64_cond_br_dec1_br_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg     [`CA53_ALU_GEN_CTL_W-1:0] alu_gen_ctl;
  reg     [`CA53_ALU_EX1_CTL_W-1:0] alu_ex1_ctl;
  reg     [`CA53_ALU_EX2_CTL_W-1:0] alu_ex2_ctl;
  reg                               alu_wr_ctl;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                              thumb_execution;
  wire                              sf_bit;
  wire                              set_19_16_i;
  wire                              set_19_16_as_r31;
  wire                              set_15_12_as_r31;
  wire                              a64_only;
  wire                              set_25to23;
  wire                              cc_always;
  wire                              top_wr_vaddr_bit;
  wire                        [2:0] rf_rd_ctl_r0_dec1_br;
  wire                        [2:0] rf_rd_ctl_r1_dec1_br;
  wire     [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_dec1_br;
  wire     [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_dec1_br;
  wire                       [12:0] rf_wr_ctl_w1_dec1_br;
  wire   [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_dec1_br;
  wire     [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_dec1_br;
  wire      [`CA53_SEL_SHF_A_W-1:0] dp_data_a_sel_dec1_br;
  wire      [`CA53_SEL_SHF_B_W-1:0] dp_data_b_sel_dec1_br;
  wire      [`CA53_SEL_SHF_C_W-1:0] dp_data_c_sel_dec1_br;
  wire      [`CA53_SEL_STR_A_W-1:0] str_data_a_sel_dec1_br;
  wire      [`CA53_SEL_STR_B_W-1:0] str_data_b_sel_dec1_br;
  wire         [`CA53_IMM_OT_W-1:0] imm_sel_other_dec1_br;
  wire     [`CA53_BR_PIPECTL_W-1:0] br_pipectl_dec1_br;
  wire                              ctl_64bit_op_dec1_br;
  wire                              ex2_ctl_cbz_bypass_dec1_br;
  wire                        [1:0] ex2_ctl_op_comp_dec1_br;
  wire                        [3:0] ex2_ctl_au_carry_lu_dec1_br;
  wire                        [2:0] ex1_ctl_shift_op_dec1_br;
  wire                              br_btac_dec1_br;
  wire                              br_return_dec1_br;
  wire                              rtn_addr_valid_dec1_br;
  wire                              pred_br_dec1_br;
  wire                        [2:0] br_sel_offset_dec1_br;
  wire                              br_pred_takenness_dec1_br;
  wire                              br_call_dec1_br;
  wire                              br_x_bit_dec1_br;
  wire                              a64_cond_br_dec1_br;
  wire                              alu_valid_dec1_br;
  wire                              str_valid_dec1_br;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Input signals for espresso equations (non-registered)
  // ------------------------------------------------------

  assign thumb_execution  = pdtype_i[1];
  assign set_19_16_i      = (iq_instr_dec1_br_i[19:16] == 4'b1111) & ~aarch64_state_i;
  assign set_19_16_as_r31 = ({iq_instr_dec1_br_i[30], iq_instr_dec1_br_i[19:16]} == 5'b11111) & aarch64_state_i;
  assign set_15_12_as_r31 = ({iq_instr_dec1_br_i[29], iq_instr_dec1_br_i[15:12]} == 5'b11111) & aarch64_state_i;
  assign set_25to23       = iq_instr_dec1_br_i[25:23] == 3'b111;
  assign cc_always        = (iq_instr_dec1_br_i[32:30] == 3'b111) | aarch64_state_i;
  assign a64_only         = (pdtype_i == 2'b01) &  aarch64_state_i;
  assign sf_bit           = iq_instr_dec1_br_i[32] & aarch64_state_i;

  // ------------------------------------------------------
  // Start automatically generated logic
  // ------------------------------------------------------

  wire    net_1, net_2, net_3, net_4, net_5, net_6,
         net_7, net_8, net_9, net_11, net_12, net_13, net_14, net_15, net_16,
         net_17, net_18, net_19, net_20, net_21, net_22, net_23, net_24,
         net_25, net_26, net_27, net_28, net_29, net_30, net_31, net_32,
         net_33, net_34, net_35, net_36, net_37, net_38, net_39, net_40,
         net_41, net_42, net_43, net_44, net_45, net_46, net_47, net_48,
         net_49, net_50, net_51, net_52, net_53, net_54, net_55, net_56,
         net_57, net_58, net_59, net_60, net_61, net_62, net_63, net_64,
         net_65, net_66, net_67, net_68, net_69, net_70, net_71;

  assign ex2_ctl_cbz_bypass_dec1_br = rf_rd_need_r0_dec1_br[2];
  assign dp_data_a_sel_dec1_br[0] = rf_rd_need_r0_dec1_br[2];
  assign ex2_ctl_au_carry_lu_dec1_br[3] = rf_rd_need_r0_dec1_br[2];
  assign rf_wr_src_w1_dec1_br[0] = rf_wr_when_w1_dec1_br[0];
  assign dp_data_a_sel_dec1_br[1] = rf_wr_when_w1_dec1_br[0];
  assign br_call_dec1_br = rf_wr_when_w1_dec1_br[0];
  assign rf_wr_ctl_w1_dec1_br[0] = rf_wr_when_w1_dec1_br[0];
  assign dp_data_b_sel_dec1_br[0] = dp_data_b_sel_dec1_br[1];
  assign dp_data_c_sel_dec1_br[1] = ex1_ctl_shift_op_dec1_br[2];
  assign ex2_ctl_au_carry_lu_dec1_br[0] = ex2_ctl_op_comp_dec1_br[1];
  assign ex2_ctl_au_carry_lu_dec1_br[1] = ex2_ctl_au_carry_lu_dec1_br[2];
  assign br_pipectl_dec1_br[2] = str_valid_dec1_br;
  assign br_pipectl_dec1_br[1] = str_valid_dec1_br;
  assign br_pred_takenness_dec1_br = br_taken_i;
  assign br_sel_offset_dec1_br[2] = a64_only;
  assign str_data_b_sel_dec1_br[1] = 1'b0;
  assign str_data_b_sel_dec1_br[0] = 1'b0;
  assign str_data_a_sel_dec1_br[0] = 1'b0;
  assign rf_wr_when_w1_dec1_br[2] = 1'b0;
  assign rf_wr_when_w1_dec1_br[1] = 1'b0;
  assign rf_wr_src_w1_dec1_br[2] = 1'b0;
  assign rf_wr_src_w1_dec1_br[1] = 1'b0;
  assign rf_wr_ctl_w1_dec1_br[9] = 1'b0;
  assign rf_wr_ctl_w1_dec1_br[8] = 1'b0;
  assign rf_wr_ctl_w1_dec1_br[6] = 1'b0;
  assign rf_wr_ctl_w1_dec1_br[5] = 1'b0;
  assign rf_wr_ctl_w1_dec1_br[4] = 1'b0;
  assign rf_wr_ctl_w1_dec1_br[3] = 1'b0;
  assign rf_wr_ctl_w1_dec1_br[2] = 1'b0;
  assign rf_wr_ctl_w1_dec1_br[1] = 1'b0;
  assign rf_wr_ctl_w1_dec1_br[12] = 1'b0;
  assign rf_wr_ctl_w1_dec1_br[11] = 1'b0;
  assign rf_rd_need_r1_dec1_br[2] = 1'b0;
  assign rf_rd_need_r1_dec1_br[1] = 1'b0;
  assign rf_rd_need_r1_dec1_br[0] = 1'b0;
  assign rf_rd_need_r0_dec1_br[1] = 1'b0;
  assign rf_rd_need_r0_dec1_br[0] = 1'b0;
  assign rf_rd_ctl_r1_dec1_br[1] = 1'b0;
  assign rf_rd_ctl_r0_dec1_br[1] = 1'b0;
  assign ex1_ctl_shift_op_dec1_br[1] = 1'b0;
  assign ex1_ctl_shift_op_dec1_br[0] = 1'b0;
  assign dp_data_c_sel_dec1_br[0] = 1'b0;
  assign dp_data_b_sel_dec1_br[2] = 1'b0;
  assign br_pipectl_dec1_br[3] = 1'b0;
  assign net_1 = ~set_15_12_as_r31;
  assign net_2 = ~net_45;
  assign net_3 = ~net_24;
  assign net_4 = ~br_sel_offset_dec1_br[2];
  assign net_5 = ~str_data_b_sel_dec1_br[2];
  assign net_6 = ~aarch64_state_i;
  assign net_7 = ~thumb_execution;
  assign net_8 = ~iq_instr_dec1_br_i[12];
  assign net_9 = ~iq_instr_dec1_br_i[1];
  assign str_data_a_sel_dec1_br[2] = ~(net_5 & net_11);
  assign net_11 = (net_12 | net_13);
  assign str_data_a_sel_dec1_br[1] = (net_3 & net_12);
  assign rtn_addr_valid_dec1_br = (br_pred_takenness_dec1_br & str_valid_dec1_br);
  assign rf_wr_ctl_w1_dec1_br[10] = (net_14 | net_15);
  assign net_15 = ~(net_16 & net_17);
  assign net_17 = ~(net_18 & net_6);
  assign net_16 = ~(br_x_bit_dec1_br | net_19);
  assign net_19 = (net_20 & thumb_execution);
  assign rf_rd_ctl_r1_dec1_br[2] = (str_data_b_sel_dec1_br[2] & set_19_16_as_r31);
  assign rf_rd_ctl_r1_dec1_br[0] = ~(net_21 & net_22);
  assign net_22 = (net_5 | set_19_16_as_r31);
  assign net_21 = ~(net_23 | net_14);
  assign net_23 = ~(net_24 | net_12);
  assign net_12 = (set_19_16_i & net_9);
  assign rf_rd_ctl_r0_dec1_br[2] = (set_15_12_as_r31 & rf_rd_need_r0_dec1_br[2]);
  assign rf_rd_ctl_r0_dec1_br[0] = (rf_rd_need_r0_dec1_br[2] & net_1);
  assign pred_br_dec1_br = ~(net_25 & net_4);
  assign net_25 = (net_26 | cc_always);
  assign net_26 = (net_27 & net_28);
  assign net_28 = (net_29 | net_8);
  assign net_29 = (iq_instr_dec1_br_i[14] | net_6);
  assign net_27 = (aarch64_state_i | iq_instr_dec1_br_i[27]);
  assign imm_sel_other_dec1_br[1] = (iq_instr_dec1_br_i[27] | net_30);
  assign net_30 = (rf_wr_ctl_w1_dec1_br[7] | net_31);
  assign net_31 = (net_32 | net_33);
  assign net_32 = (net_34 & net_7);
  assign imm_sel_other_dec1_br[0] = (ex1_ctl_shift_op_dec1_br[2] | net_35);
  assign net_35 = (net_36 | net_37);
  assign net_37 = (net_38 & net_39);
  assign net_39 = (iq_instr_dec1_br_i[26] & net_40);
  assign net_38 = (thumb_execution & net_4);
  assign net_36 = (net_20 & net_41);
  assign net_41 = ~(iq_instr_dec1_br_i[27] | net_42);
  assign ex2_ctl_op_comp_dec1_br[0] = ~(net_43 & net_44);
  assign net_44 = ~(ex1_ctl_shift_op_dec1_br[2] & iq_instr_dec1_br_i[24]);
  assign net_43 = ~(iq_instr_dec1_br_i[23] & net_45);
  assign ex2_ctl_au_carry_lu_dec1_br[2] = (iq_instr_dec1_br_i[24] & net_45);
  assign ex2_ctl_op_comp_dec1_br[1] = (iq_instr_dec1_br_i[27] | net_46);
  assign net_46 = (net_47 | net_14);
  assign net_14 = ~(net_48 | net_7);
  assign net_47 = ~(aarch64_state_i | net_49);
  assign net_49 = ~(net_33 | net_34);
  assign net_34 = (iq_instr_dec1_br_i[1] & net_50);
  assign net_33 = (net_20 & net_42);
  assign net_42 = ~(thumb_execution | net_8);
  assign ctl_64bit_op_dec1_br = (net_51 | rf_wr_ctl_w1_dec1_br[7]);
  assign rf_wr_ctl_w1_dec1_br[7] = ~(net_48 & net_52);
  assign net_52 = ~(aarch64_state_i & net_20);
  assign net_51 = (sf_bit & rf_rd_need_r0_dec1_br[2]);
  assign rf_rd_need_r0_dec1_br[2] = (net_53 | ex1_ctl_shift_op_dec1_br[2]);
  assign br_x_bit_dec1_br = (iq_instr_dec1_br_i[27] | net_54);
  assign net_54 = (net_20 & net_8);
  assign net_20 = (iq_instr_dec1_br_i[14] & net_4);
  assign br_sel_offset_dec1_br[1] = ~(net_55 & net_56);
  assign net_56 = (br_sel_offset_dec1_br[2] | net_57);
  assign net_55 = ~(ex1_ctl_shift_op_dec1_br[2] | iq_instr_dec1_br_i[27]);
  assign br_sel_offset_dec1_br[0] = (iq_instr_dec1_br_i[27] | net_58);
  assign net_58 = (net_59 | net_45);
  assign net_59 = (net_60 & net_61);
  assign br_return_dec1_br = ~(iq_instr_dec1_br_i[1] | net_62);
  assign net_62 = ~(net_3 | net_63);
  assign net_63 = ~(net_5 | iq_instr_dec1_br_i[0]);
  assign net_24 = (aarch64_state_i | net_13);
  assign str_valid_dec1_br = ~(net_5 & net_13);
  assign br_pipectl_dec1_br[0] = ~(net_60 & net_64);
  assign net_64 = ~(iq_instr_dec1_br_i[27] | net_61);
  assign net_61 = ~(aarch64_state_i | set_25to23);
  assign br_btac_dec1_br = (br_pred_takenness_dec1_br & net_65);
  assign net_65 = (net_66 | net_67);
  assign net_67 = (iq_instr_dec1_br_i[0] & str_data_b_sel_dec1_br[2]);
  assign net_66 = ~(net_9 | net_13);
  assign net_13 = ~(net_50 & iq_instr_dec1_br_i[26]);
  assign net_50 = (set_25to23 & net_60);
  assign net_60 = (net_57 & net_4);
  assign net_57 = ~(iq_instr_dec1_br_i[12] | iq_instr_dec1_br_i[14]);
  assign alu_valid_dec1_br = (net_53 | dp_data_b_sel_dec1_br[1]);
  assign dp_data_b_sel_dec1_br[1] = (ex1_ctl_shift_op_dec1_br[2] | rf_wr_when_w1_dec1_br[0]);
  assign rf_wr_when_w1_dec1_br[0] = ~(net_68 & net_48);
  assign net_48 = ~(str_data_b_sel_dec1_br[2] & iq_instr_dec1_br_i[1]);
  assign str_data_b_sel_dec1_br[2] = (aarch64_state_i & net_69);
  assign net_69 = ~(br_sel_offset_dec1_br[2] | iq_instr_dec1_br_i[12]);
  assign net_68 = ~(iq_instr_dec1_br_i[27] | net_18);
  assign net_18 = ~(br_sel_offset_dec1_br[2] | net_70);
  assign net_70 = ~(iq_instr_dec1_br_i[14] | net_40);
  assign net_40 = ~(iq_instr_dec1_br_i[12] | net_71);
  assign net_71 = ~(iq_instr_dec1_br_i[1] & set_25to23);
  assign ex1_ctl_shift_op_dec1_br[2] = ~(iq_instr_dec1_br_i[25] | net_4);
  assign net_53 = (br_sel_offset_dec1_br[2] & iq_instr_dec1_br_i[24]);
  assign a64_cond_br_dec1_br = ~(net_2 | iq_instr_dec1_br_i[24]);
  assign net_45 = (br_sel_offset_dec1_br[2] & iq_instr_dec1_br_i[25]);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Create the ALU pipe control bus
  // ------------------------------------------------------

  always @* begin
    alu_wr_ctl  = 1'b0;
    alu_ex2_ctl = {`CA53_ALU_EX2_CTL_W{1'b0}};
    alu_ex1_ctl = {`CA53_ALU_EX1_CTL_W{1'b0}};
    alu_gen_ctl = {`CA53_ALU_GEN_CTL_W{1'b0}};

    alu_ex2_ctl[`CA53_ALU_EX2_CBZ_BYPASS_BITS]       = ex2_ctl_cbz_bypass_dec1_br;
    alu_ex2_ctl[`CA53_ALU_EX2_CTL_OP_COMP_SHF_B_BIT] = ex2_ctl_op_comp_dec1_br[1];
    alu_ex2_ctl[`CA53_ALU_EX2_CTL_OP_COMP_SHF_A_BIT] = ex2_ctl_op_comp_dec1_br[0];
    alu_ex2_ctl[`CA53_ALU_EX2_CTL_LU_CTL_BITS]       = ex2_ctl_au_carry_lu_dec1_br[3:0];

    alu_ex1_ctl[`CA53_ALU_EX1_CTL_SHIFT_OP_BITS]     = ex1_ctl_shift_op_dec1_br[`CA53_SHIFT_OP_W-1:0];

    alu_gen_ctl[`CA53_ALU_CTL_64BIT_OP_BITS]         = ctl_64bit_op_dec1_br;
  end

  assign alu_pipectl_dec1_br_o = {alu_wr_ctl,
                                  alu_ex2_ctl,
                                  alu_ex1_ctl,
                                  alu_gen_ctl};

  assign ex_pipe_dec1_br_o[`CA53_EX_PIPE_ALU_BIT]  = alu_valid_dec1_br;
  assign ex_pipe_dec1_br_o[`CA53_EX_PIPE_MAC_BIT]  = 1'b0;
  assign ex_pipe_dec1_br_o[`CA53_EX_PIPE_BR_BIT]   = 1'b1;
  assign ex_pipe_dec1_br_o[`CA53_EX_PIPE_DCU_BIT]  = 1'b0;
  assign ex_pipe_dec1_br_o[`CA53_EX_PIPE_DIV_BIT]  = 1'b0;
  assign ex_pipe_dec1_br_o[`CA53_EX_PIPE_STR_BIT]  = str_valid_dec1_br;

  // ------------------------------------------------------
  // Data selection mux adjustment to select the PC
  // ------------------------------------------------------
  assign dp_data_a_sel_dec1_br_o = ({`CA53_SEL_SHF_A_W{rf_rd_ctl_r0_dec1_br[`CA53_RD_CTL_PC]}}    & `CA53_SEL_SHF_A_PC)   |
                                   ({`CA53_SEL_SHF_A_W{rf_rd_ctl_r0_dec1_br[`CA53_RD_CTL_ZR]}}    & `CA53_SEL_SHF_A_ZERO) |
                                   ({`CA53_SEL_SHF_A_W{~(rf_rd_ctl_r0_dec1_br[`CA53_RD_CTL_PC] |
                                                         rf_rd_ctl_r0_dec1_br[`CA53_RD_CTL_ZR])}} & dp_data_a_sel_dec1_br[`CA53_SEL_SHF_A_W-1:0]);

  assign dp_data_b_sel_dec1_br_o  = (dp_data_b_sel_dec1_br == `CA53_SEL_SHF_B_R1) ? (rf_rd_ctl_r1_dec1_br[`CA53_RD_CTL_PC] ? `CA53_SEL_SHF_B_PC   :
                                                                                     rf_rd_ctl_r1_dec1_br[`CA53_RD_CTL_ZR] ? `CA53_SEL_SHF_B_ZERO :
                                                                                                                             `CA53_SEL_SHF_B_R1)    :
                                                                                    dp_data_b_sel_dec1_br;

  assign dp_data_c_sel_dec1_br_o  = dp_data_c_sel_dec1_br; // C input Never selects PC

  assign str_data_a_sel_dec1_br_o = (str_data_a_sel_dec1_br == `CA53_SEL_STR_A_R1) ? (rf_rd_ctl_r1_dec1_br[`CA53_RD_CTL_ZR]  ? `CA53_SEL_STR_A_ZERO :
                                                                                      rf_rd_ctl_r1_dec1_br[`CA53_RD_CTL_PC]  ? `CA53_SEL_STR_A_PC   :
                                                                                                                               `CA53_SEL_STR_A_R1)    :
                                                                                     str_data_a_sel_dec1_br;

  assign str_data_b_sel_dec1_br_o = (str_data_a_sel_dec1_br == `CA53_SEL_STR_A_R1) ? (rf_rd_ctl_r1_dec1_br[`CA53_RD_CTL_ZR]  ? `CA53_SEL_STR_A_ZERO :
                                                                                      rf_rd_ctl_r1_dec1_br[`CA53_RD_CTL_PC]  ? `CA53_SEL_STR_A_PC   :
                                                                                                                               str_data_b_sel_dec1_br)   :
                                                                                     str_data_b_sel_dec1_br;

  assign str_b_valid_dec1_br_o      = (str_data_b_sel_dec1_br != `CA53_SEL_STR_B_ZERO);
  assign ctl_64bit_op_str_dec1_br_o = (str_data_b_sel_dec1_br == `CA53_SEL_STR_B_A_H);

  // ------------------------------------------------------
  // Register file address and enable generation
  // ------------------------------------------------------

  // Read enables (address muxing done at De top level)
  assign rf_rd_en_r0_dec1_br_o = rf_rd_ctl_r0_dec1_br[`CA53_RD_CTL_EN];
  assign rf_rd_en_r1_dec1_br_o = rf_rd_ctl_r1_dec1_br[`CA53_RD_CTL_EN];

  // Write addresses
  assign top_wr_vaddr_bit = iq_instr_dec1_br_i[29] & aarch64_state_i; // [11:8] and [15:12] share 5th bit position

  assign rf_wr_vaddr_w1_dec1_br_o = ({5{rf_wr_ctl_w1_dec1_br[`CA53_WR_CTL_15_12]}} & {top_wr_vaddr_bit, iq_instr_dec1_br_i[15:12]}) |
                                    ({5{rf_wr_ctl_w1_dec1_br[`CA53_WR_CTL_11_8] }} & {top_wr_vaddr_bit, iq_instr_dec1_br_i[11:8]})  |
                                    ({5{rf_wr_ctl_w1_dec1_br[`CA53_WR_CTL_R14]  }} & `CA53_VADDR_R14)                               |
                                    ({5{rf_wr_ctl_w1_dec1_br[`CA53_WR_CTL_R30]  }} & `CA53_VADDR_R30);

  // Write enables
  assign rf_wr_en_w1_dec1_br_o  = rf_wr_ctl_w1_dec1_br[`CA53_WR_CTL_EN];
  assign rf_wr_64b_w1_dec1_br_o = ctl_64bit_op_dec1_br;

  // ------------------------------------------------------
  // Immediate generation
  // ------------------------------------------------------

  ca53dpu_dec_imm_other u_dec_imm_other (
    // Inputs
    .imm_sel_other_i      (imm_sel_other_dec1_br[`CA53_IMM_OT_W-1:0]),
    .instr_i              (iq_instr_dec1_br_i[32:0]),
    // Outputs
    .imm_data_other_o     (imm_data_dec1_br_o[`CA53_IMM_DATA_W-1:0]),
    .imm_shift_other_o    (imm_shift_dec1_br_o[`CA53_IMM_SHIFT_W-1:0])
  );

  // ------------------------------------------------------
  // Branch offset generation
  // ------------------------------------------------------

  // The branch offset is too complicated to create in an espresso decoder so is
  // generated here using select signals from the decoder
  always @* begin
    case (br_sel_offset_dec1_br[2:0])
      3'b000  : br_offset_dec1_br_o[27:1] = {27{1'b0}};
      // B (T3 Variant)
      3'b001  : br_offset_dec1_br_o[27:1] = {{7{iq_instr_dec1_br_i[26]}},
                                              iq_instr_dec1_br_i[26],    // S-Bit
                                              iq_instr_dec1_br_i[11],    // J2-Bit
                                              iq_instr_dec1_br_i[13],    // J1-Bit
                                              iq_instr_dec1_br_i[21:16], // Imm6
                                              iq_instr_dec1_br_i[10:0]   // Imm11
                                             };
      // B (T4 Variant), BL, BLX (immediate-Thumb)
      3'b010  : begin
        case ({aarch64_state_i, thumb_execution})
          2'b01 : br_offset_dec1_br_o[27:1] = {{4{iq_instr_dec1_br_i[26]}}, // S-Bit
                                               ~(iq_instr_dec1_br_i[13] ^
                                                 iq_instr_dec1_br_i[26]),   // I1-Bit
                                               ~(iq_instr_dec1_br_i[11] ^
                                                 iq_instr_dec1_br_i[26]),   // I2-Bit
                                               iq_instr_dec1_br_i[25:16],   // Imm10
                                               iq_instr_dec1_br_i[10:0]     // Imm11
                                              };
          2'b00 : br_offset_dec1_br_o[27:1] = {{3{iq_instr_dec1_br_i[26]}}, // S-Bit
                                               ~(iq_instr_dec1_br_i[13] ^
                                                 iq_instr_dec1_br_i[26]),   // I1-Bit
                                               ~(iq_instr_dec1_br_i[11] ^
                                                 iq_instr_dec1_br_i[26]),   // I2-Bit
                                               iq_instr_dec1_br_i[25:16],   // Imm10
                                               iq_instr_dec1_br_i[10:0],    // Imm11
                                               1'b0};
          2'b10 : br_offset_dec1_br_o[27:1] = {iq_instr_dec1_br_i[31],      // i1-Bit
                                               iq_instr_dec1_br_i[30],      // i2-Bit
                                               iq_instr_dec1_br_i[26],      // S-Bit
                                               iq_instr_dec1_br_i[13],      // J1-Bit
                                               iq_instr_dec1_br_i[11],      // J2-Bit
                                               iq_instr_dec1_br_i[25:16],   // Imm10
                                               iq_instr_dec1_br_i[10:0],    // Imm11
                                               1'b0};
          default : br_offset_dec1_br_o[27:1] = {27{1'bx}};
        endcase
      end
      // BLX (immediate-ARM)
      3'b011  : br_offset_dec1_br_o[27:1] = {{2{iq_instr_dec1_br_i[23]}}, iq_instr_dec1_br_i[23:0], iq_instr_dec1_br_i[24]};
      // CBZ/CBNZ
      3'b100  : br_offset_dec1_br_o[27:1] = {{21{1'b0}}, iq_instr_dec1_br_i[9], iq_instr_dec1_br_i[7:3]};
      // A64 conditional branches
      3'b101  : br_offset_dec1_br_o[27:1] = {{7{iq_instr_dec1_br_i[22]}}, iq_instr_dec1_br_i[22:16], iq_instr_dec1_br_i[11:0], 1'b0};
      // A64 test and branch
      3'b110  : br_offset_dec1_br_o[27:1] = {{12{iq_instr_dec1_br_i[17]}}, iq_instr_dec1_br_i[17:16], iq_instr_dec1_br_i[11:0], 1'b0};
      default : br_offset_dec1_br_o[27:1] = {27{1'bx}};
    endcase
  end

  // ------------------------------------------------------
  // Output aliases
  // ------------------------------------------------------

  assign slot1_instr_type_dec1_br_o  = br_x_bit_dec1_br             ? `CA53_SLOT1_INSTR_TYPE_BLX  :
                                       ((|str_data_a_sel_dec1_br) &  // BX is only dec1 instruction which uses store pipe
                                        ~aarch64_state_i)           ? `CA53_SLOT1_INSTR_TYPE_BX   :
                                                                      `CA53_SLOT1_INSTR_TYPE_BRANCH;

  assign rf_rd_need_r0_dec1_br_o     = rf_rd_need_r0_dec1_br;
  assign rf_rd_need_r1_dec1_br_o     = rf_rd_need_r1_dec1_br;
  assign rf_wr_src_w1_dec1_br_o      = rf_wr_src_w1_dec1_br;
  assign rf_wr_when_w1_dec1_br_o     = rf_wr_when_w1_dec1_br;
  assign br_pipectl_dec1_br_o        = br_pipectl_dec1_br;
  assign br_btac_dec1_br_o           = br_btac_dec1_br;
  assign br_return_dec1_br_o         = br_return_dec1_br;
  assign rtn_addr_valid_dec1_br_o    = rtn_addr_valid_dec1_br;
  assign pred_br_dec1_br_o           = pred_br_dec1_br;
  assign br_pred_takenness_dec1_br_o = br_pred_takenness_dec1_br;
  assign br_call_dec1_br_o           = br_call_dec1_br;
  assign br_x_bit_dec1_br_o          = br_x_bit_dec1_br;
  assign a64_cond_br_dec1_br_o       = a64_cond_br_dec1_br;

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
