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
//      Checked In          : $Date: 2015-02-17 13:54:57 +0000 (Tue, 17 Feb 2015) $
//
//      Revision            : $Revision: 302088 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Detects when there is a hazard which means the instruction
//            in slot 1 should not be dual issued.
//            - If slot 1 reads a register written by slot 0 (RAW hazard),
//              then do not dual issue, as there is no forwarding path
//              between slot 0 and slot 1 (unless the slot 1 instruction is a
//              store).
//            - If slot 1 reads a register written by an instruction
//              currently in iss do not dual issue, as there is no Ex1 to Iss
//              forwarding path (as would be required on the next cycle if
//              the instruction were to dual issue).
//            - RP2 can be used by both slot 0 and slot 1, but not by both at
//              the same time (i.e. there is a structural hazard). This is
//              the only RF port which is shared between both slots.
//-----------------------------------------------------------------------------
`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_iq_dih `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire         iq_instr0_aarch64_i,
  input  wire         iq_instr1_aarch64_i,
  input  wire         iq_instr0_ctl_aarch64_i,
  input  wire         iq_instr1_ctl_aarch64_i,
  input  wire  [32:0] iq_instr1_i,
  input  wire   [1:0] iq_instr1_pdtype_i,
  input  wire   [5:0] iq_instr1_sideband_i,
  input  wire         iq_instr1_is_dp_i,
  input  wire         iq_instr1_is_ls_i,
  input  wire         iq_instr1_is_ot_i,
  input  wire         iq_instr1_is_fn_i,
  input  wire  [32:0] iq_instr0_i,
  input  wire  [29:0] iq_instr0_fn_dih_i,
  input  wire         iq_instr0_fn_dih_32_i,
  input  wire         iq_instr0_fn_dih_pdtype0_i,
  input  wire         iq_instr0_fn_dih_aarch64_i,
  input  wire  [29:0] iq_instr1_fn_dih_i,
  input  wire         iq_instr1_fn_dih_pdtype0_i,
  input  wire         iq_instr1_fn_dih_aarch64_i,
  input  wire         iq_instr0_is_dp_i,
  input  wire         iq_instr0_is_ls_i,
  input  wire         iq_instr0_is_ot_i,
  input  wire         iq_instr0_is_fn_i,
  input  wire   [1:0] iq_instr0_pdtype_i,
  input  wire   [5:0] iq_instr0_sideband_i,
  input  wire         rf_wr_en_w0_iss_i,
  input  wire         rf_wr_en_w1_iss_i,
  input  wire         rf_wr_en_w2_iss_i,
  input  wire   [1:0] rf_wr_when_w0_iss_i,
  input  wire   [1:0] rf_wr_when_w1_iss_i,
  input  wire   [1:0] rf_wr_when_w2_iss_i,
  input  wire   [4:0] rf_wr_vaddr_w0_iss_i,
  input  wire   [4:0] rf_wr_vaddr_w1_iss_i,
  input  wire   [4:0] rf_wr_vaddr_w2_iss_i,
  input  wire         rf_wr_en_w0_ex1_i,
  input  wire         rf_wr_en_w1_ex1_i,
  input  wire         rf_wr_en_w2_ex1_i,
  input  wire   [1:0] rf_wr_when_w0_ex1_i,
  input  wire   [1:0] rf_wr_when_w1_ex1_i,
  input  wire   [1:0] rf_wr_when_w2_ex1_i,
  input  wire   [4:0] rf_wr_vaddr_w0_ex1_i,
  input  wire   [4:0] rf_wr_vaddr_w1_ex1_i,
  input  wire   [4:0] rf_wr_vaddr_w2_ex1_i,
  input  wire   [3:0] rf_wr_en_fw0_iss_i,
  input  wire   [3:0] rf_wr_en_fw1_iss_i,
  input  wire   [3:0] rf_wr_en_fw0_f1_i,
  input  wire   [3:0] rf_wr_en_fw1_f1_i,
  input  wire   [3:0] rf_wr_en_fw0_f2_i,
  input  wire   [3:0] rf_wr_en_fw1_f2_i,
  input  wire   [1:0] rf_wr_when_fw0_iss_i,
  input  wire   [1:0] rf_wr_when_fw1_iss_i,
  input  wire   [1:0] rf_wr_when_fw0_f1_i,
  input  wire   [1:0] rf_wr_when_fw1_f1_i,
  input  wire   [1:0] rf_wr_when_fw0_f2_i,
  input  wire   [1:0] rf_wr_when_fw1_f2_i,
  input  wire   [5:0] rf_wr_addr_fw0_iss_i,
  input  wire   [5:0] rf_wr_addr_fw1_iss_i,
  input  wire   [5:0] rf_wr_addr_fw0_f1_i,
  input  wire   [5:0] rf_wr_addr_fw1_f1_i,
  input  wire   [5:0] rf_wr_addr_fw0_f2_i,
  input  wire   [5:0] rf_wr_addr_fw1_f2_i,
  input  wire   [1:0] adrp_valid_iss_i,
  input  wire         taken_br_instr_iss_i,
  input  wire   [1:0] iss_pc_in_same_page_i,
  input  wire         cp_trap_fp_i,
  input  wire         cp_trap_neon_i,
  // Outputs
  output wire         fn_dcu_valid_instr1_o,
  output wire         iq_instr0_r2_enabled_o,
  output wire         iq_instr0_w0_enabled_o,
  output wire         iq_instr1_br_valid_o,
  output wire         iq_instr1_datapath_resource_hazard_o,
  output wire         iq_instr0_sets_ccflags_o,
  output wire         iq_instr0_d0_uses_dcu_o,
  output wire         iq_instr1_dih_o,
  output wire         iq_instr1_is_aesimc_aesmc_o,
  output wire         iq_skew_instr0_o,
  output wire         iq_skew_instr0_r0_o,
  output wire         iq_skew_instr0_r1_o,
  output wire         iq_skew_instr1_o,
  output wire         iq_skew_instr1_r0_o,
  output wire         iq_skew_instr1_r1_o,
  output wire         iq_instr0_adrp_fwd_o,
  output wire   [2:1] iq_instr0_adrp_fwd_src_o,
  output wire         iq_instr1_adrp_fwd_o,
  output wire   [2:0] iq_instr1_adrp_fwd_src_o
 );

  // -----------------------------
  // Constant declarations
  // -----------------------------

  localparam WHN_NOT_EX1  = 0;
  localparam WHN_NOT_EX2  = 1;

  localparam R19_16 = 0;
  localparam R15_12 = 1;
  localparam R11_8  = 2;
  localparam R3_0   = 3;
  localparam R11_8W = 4; // Interpretation of 11:8 field differs between reads and writes

  localparam VN = 0;
  localparam VD = 1;
  localparam VM = 2;
  localparam VA = 3;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg   [3:0] instr0_ls_imm_mask;
  reg   [3:0] instr1_ls_imm_mask;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire        instr1_r2_enabled;
  wire        instr1_w0_enabled;
  wire        mac_valid_instr1;
  wire        br_valid_instr1;
  wire        dcu_valid_instr1;
  wire        str_valid_instr1;
  wire        str0_valid_instr1;
  wire        instr1_ex1_ctl_shift_rrx_for_0_t;
  wire        instr1_ex1_ctl_shift_rrx_for_0_a;
  wire  [2:0] instr1_ex1_ctl_shift_op;
  wire        instr1_au_uses_cin;
  wire        instr1_shf_imm_field_zero;
  wire        instr1_shf_imm_field_zero_arm;
  wire        instr1_is_ls_rrx;
  wire        instr1_is_dp_rrx;
  wire        instr1_sf_bit;
  wire        instr0_19_16_written;
  wire        instr0_15_12_written;
  wire        instr0_11_8_written;
  wire        instr0_3_0_written;
  wire        instr0_lr_written;
  wire        instr0_11_8_when_not_ex1;
  wire        mod_instr0_11_8_when_not_ex1;
  wire        instr0_11_8_when_not_ex2;
  wire        instr0_r2_enabled;
  wire        instr0_w0_enabled;
  wire        instr0_sets_ccflags;
  wire        mac_valid_instr0;
  wire        br_valid_instr0;
  wire        dcu_valid_instr0;
  wire        div_valid_instr0;
  wire        str_valid_instr0;
  wire        str1_valid_instr0;
  wire        instr0_cc_never;
  wire        instr0_a32_only;
  wire        instr0_a64_only;
  wire        instr0_agu_can_shift;
  wire        instr0_19_16_is_pc;
  wire        instr0_15_12_is_pc;
  wire        instr0_11_8_is_pc;
  wire        instr0_3_0_is_pc;
  wire        instr0_3_0_is_sp;
  wire        instr0_shf_imm_field_zero;
  wire        instr0_shf_type_imm_field_zero;
  wire        instr0_sf_bit;
  wire        instr0_top_3_0;
  wire        instr0_top_11_8_rd;
  wire        instr0_top_11_8_wr;
  wire        instr0_top_15_12;
  wire        instr0_top_19_16;
  wire        instr1_top_3_0;
  wire        instr1_top_11_8;
  wire        instr1_top_15_12;
  wire        instr1_top_19_16;
  wire        instr1_shf_type_imm_field_zero;
  wire        instr1_a32_only;
  wire        instr1_a64_only;
  wire        instr1_cc_never;
  wire        instr1_19_16_is_pc;
  wire        instr1_15_12_is_pc;
  wire        instr1_11_8_is_pc;
  wire        instr1_3_0_is_sp;
  wire        instr1_3_0_is_pc;
  wire        raw_hazard_3_0_de;
  wire        raw_hazard_11_8_de;
  wire        raw_hazard_15_12_de;
  wire        raw_hazard_19_16_de;
  wire        raw_hazard_pc_de;
  wire        raw_hazard_lr_de;
  wire        instr1_reads_pc;
  wire        instr1_cc_hazard;
  wire        ignore_raw_hazard_de;
  wire  [3:0] de_11_8_hz_valid;
  wire  [3:0] instr1_de_w0_iss_match;
  wire  [3:0] instr1_de_w1_iss_match;
  wire  [3:0] instr1_de_w2_iss_match;
  wire  [3:0] instr1_de_w0_ex1_match;
  wire  [3:0] instr1_de_w1_ex1_match;
  wire  [3:0] instr1_de_w2_ex1_match;
  wire  [3:0] instr0_de_w0_iss_match;
  wire  [3:0] instr0_de_w1_iss_match;
  wire  [3:0] instr0_de_w2_iss_match;
  wire  [3:0] instr0_de_w0_ex1_match;
  wire  [3:0] instr0_de_w1_ex1_match;
  wire  [3:0] instr0_de_w2_ex1_match;
  wire        instr1_r2_hazard;
  wire        instr1_w0_hazard;
  wire        instr1_datapath_resource_hazard;
  wire        instr1_is_it;
  wire        instr1_is_aesimc_aesmc;
  wire        instr0_is_aesd_aese;
  wire        can_merge_aes_ops;
  wire        instr1_aes_cannot_merge;
  wire        instr1_selects_pc;
  wire  [3:0] instr1_reads;
  wire  [3:0] instr0_reads;
  wire  [4:0] instr1_reg [3:0];
  wire  [4:0] instr0_reg [4:0];
  wire  [3:0] instr1_need_early_iss;
  wire  [3:0] instr1_need_late_iss;
  wire  [3:0] instr1_need_late_ex1;
  wire  [3:0] instr0_need_early_iss;
  wire  [3:0] instr0_need_late_iss;
  wire  [3:0] instr0_need_late_ex1;
  wire        instr1_skewable;
  wire        instr1_skew_r0;
  wire        instr1_skew_r1;
  wire        instr0_skewable;
  wire        instr0_skew_r0;
  wire        instr0_skew_r1;
  wire  [3:0] instr0_w0_iss_hazard_valid_skew;
  wire  [3:0] instr0_w1_iss_hazard_valid_skew;
  wire  [3:0] instr0_w2_iss_hazard_valid_skew;
  wire        instr0_raw_hazard_w0_iss_skew;
  wire        instr0_raw_hazard_w1_iss_skew;
  wire        instr0_raw_hazard_w2_iss_skew;
  wire  [3:0] instr0_w0_ex1_hazard_valid_skew;
  wire  [3:0] instr0_w1_ex1_hazard_valid_skew;
  wire  [3:0] instr0_w2_ex1_hazard_valid_skew;
  wire        instr0_raw_hazard_w0_ex1_skew;
  wire        instr0_raw_hazard_w1_ex1_skew;
  wire        instr0_raw_hazard_w2_ex1_skew;
  wire        instr0_skew_hazard;
  wire        iq_skew_instr0;
  wire        instr1_raw_hazard_11_8_de_skew;
  wire  [3:0] instr1_w0_iss_hazard_valid_skew;
  wire  [3:0] instr1_w1_iss_hazard_valid_skew;
  wire  [3:0] instr1_w2_iss_hazard_valid_skew;
  wire        instr1_raw_hazard_w0_iss_skew;
  wire        instr1_raw_hazard_w1_iss_skew;
  wire        instr1_raw_hazard_w2_iss_skew;
  wire  [3:0] instr1_w0_ex1_hazard_valid_skew;
  wire  [3:0] instr1_w1_ex1_hazard_valid_skew;
  wire  [3:0] instr1_w2_ex1_hazard_valid_skew;
  wire        instr1_raw_hazard_w0_ex1_skew;
  wire        instr1_raw_hazard_w1_ex1_skew;
  wire        instr1_raw_hazard_w2_ex1_skew;
  wire        instr1_skew_hazard;
  wire        instr1_fn_trap_hazard;
  wire        instr1_interlock_hazard;
  wire  [2:0] instr0_interlock_mask;
  wire  [2:0] instr1_interlock_mask;
  wire  [2:0] instr0_de_w0_iss_mask;
  wire  [2:0] instr0_de_w1_iss_mask;
  wire  [2:0] instr0_de_w2_iss_mask;
  wire  [2:0] instr1_de_w0_iss_mask;
  wire  [2:0] instr1_de_w1_iss_mask;
  wire  [2:0] instr1_de_w2_iss_mask;
  wire  [2:0] instr0_de_w0_ex1_mask;
  wire  [2:0] instr0_de_w1_ex1_mask;
  wire  [2:0] instr0_de_w2_ex1_mask;
  wire  [2:0] instr1_de_w0_ex1_mask;
  wire  [2:0] instr1_de_w1_ex1_mask;
  wire  [2:0] instr1_de_w2_ex1_mask;
  wire  [2:0] instr0_need_de [3:0];
  wire  [2:0] instr1_need_de [3:0];
  wire        instr0_can_adrp_forward;
  wire        instr0_can_adrp_forward_qual;
  wire        instr1_can_adrp_forward;
  wire        instr1_can_adrp_forward_qual;
  wire        instr0_is_adrp;
  wire        instr0_adrp_fwd;
  wire  [2:1] instr0_adrp_fwd_src;
  wire        instr1_adrp_fwd;
  wire  [2:0] instr1_adrp_fwd_src;
  wire  [1:0] adrp_valid_iss_qual;
  wire        instr1_is_neon;
  wire        fn_dcu_valid_instr1;
  wire        fp_raw_hazard_de;
  wire        fp_waw_hazard_de;
  wire        fp_war_hazard_de;
  wire        fp_datapath_resource_hazard;
  wire        instr1_fp_interlock_hazard;

  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------

  // The logic to detect which bits of the slot 1 and slot 0 instruction
  // encoding correspond to a read or write register number (respectively) is
  // generated automatically, as is the logic to detect when each slot is
  // using RP2.

  assign instr1_a32_only     = (iq_instr1_pdtype_i == 2'b01)   & ~iq_instr1_ctl_aarch64_i;
  assign instr1_a64_only     = (iq_instr1_pdtype_i == 2'b01)   &  iq_instr1_ctl_aarch64_i;
  assign instr1_cc_never     = (iq_instr1_i[32:29] == 4'b1111) & ~iq_instr1_ctl_aarch64_i & ~iq_instr1_pdtype_i[1];

  assign instr1_shf_type_imm_field_zero = iq_instr1_ctl_aarch64_i ?  ({iq_instr1_i[15:12], iq_instr1_i[7:6]} == 6'b00_0000)
                                                                  : (({iq_instr1_i[14:12], iq_instr1_i[7:6]} == 5'b0_0000) & (iq_instr1_i[5:4] == 2'b00));

  assign instr1_19_16_is_pc  = (iq_instr1_i[19:16] == 4'b1111) & ~iq_instr1_ctl_aarch64_i;
  assign instr1_15_12_is_pc  = (iq_instr1_i[15:12] == 4'b1111) & ~iq_instr1_ctl_aarch64_i;
  assign instr1_11_8_is_pc   = (iq_instr1_i[11: 8] == 4'b1111) & ~iq_instr1_ctl_aarch64_i;
  assign instr1_3_0_is_pc    = iq_instr1_ctl_aarch64_i ? ~iq_instr1_i[29]                                                        
                                                       : (iq_instr1_i[ 3: 0] == 4'b1111);
  assign instr1_3_0_is_sp    = iq_instr1_ctl_aarch64_i ? (iq_instr1_i[29] & ({iq_instr1_i[31], iq_instr1_i[3:0]}   == 5'b11111)) 
                                                       : (iq_instr1_i[ 3: 0] == 4'b1101);

  assign instr1_sf_bit       = iq_instr1_i[32] & iq_instr1_ctl_aarch64_i;

  // ------------------------------------------------------
  // Start Slot 1 integer automatically generated logic
  // ------------------------------------------------------

  wire    net_0_1, net_0_3, net_0_4, net_0_5, net_0_6, net_0_7, net_0_8,
         net_0_9, net_0_10, net_0_11, net_0_12, net_0_13, net_0_14, net_0_15, net_0_16, net_0_17,
         net_0_18, net_0_20, net_0_21, net_0_22, net_0_23, net_0_24, net_0_25, net_0_26,
         net_0_27, net_0_28, net_0_29, net_0_30, net_0_31, net_0_32, net_0_33, net_0_34,
         net_0_35, net_0_36, net_0_37, net_0_38, net_0_39, net_0_40, net_0_41, net_0_42,
         net_0_43, net_0_44, net_0_45, net_0_46, net_0_47, net_0_48, net_0_49, net_0_50,
         net_0_51, net_0_52, net_0_53, net_0_54, net_0_55, net_0_56, net_0_57, net_0_58,
         net_0_59, net_0_60, net_0_61, net_0_62, net_0_63, net_0_64, net_0_65, net_0_66,
         net_0_67, net_0_68, net_0_69, net_0_70, net_0_71, net_0_72, net_0_73, net_0_74,
         net_0_75, net_0_76, net_0_77, net_0_78, net_0_79, net_0_80, net_0_81, net_0_82,
         net_0_83, net_0_84, net_0_85, net_0_86, net_0_87, net_0_88, net_0_89, net_0_90,
         net_0_91, net_0_92, net_0_93, net_0_94, net_0_95, net_0_96, net_0_97, net_0_98,
         net_0_99, net_0_100, net_0_101, net_0_102, net_0_103, net_0_104, net_0_105, net_0_106,
         net_0_107, net_0_108, net_0_109, net_0_110, net_0_111, net_0_112, net_0_113,
         net_0_114, net_0_115, net_0_116, net_0_117, net_0_118, net_0_119, net_0_120,
         net_0_121, net_0_122, net_0_123, net_0_124, net_0_125, net_0_126, net_0_127,
         net_0_128, net_0_129, net_0_130, net_0_131, net_0_132, net_0_133, net_0_134,
         net_0_135, net_0_136, net_0_137, net_0_138, net_0_139, net_0_140, net_0_141,
         net_0_142, net_0_143, net_0_144, net_0_145, net_0_146, net_0_147, net_0_148,
         net_0_149, net_0_150, net_0_151, net_0_152, net_0_153, net_0_154, net_0_155,
         net_0_156, net_0_157, net_0_158, net_0_159, net_0_160, net_0_161, net_0_162,
         net_0_163, net_0_164, net_0_165, net_0_166, net_0_167, net_0_168, net_0_169,
         net_0_170, net_0_171, net_0_172, net_0_173, net_0_174, net_0_175, net_0_176,
         net_0_177, net_0_178, net_0_179, net_0_180, net_0_181, net_0_182, net_0_183,
         net_0_184, net_0_185, net_0_186, net_0_187, net_0_188, net_0_189, net_0_190,
         net_0_191, net_0_192, net_0_193, net_0_194, net_0_195, net_0_196, net_0_197,
         net_0_198, net_0_199, net_0_200, net_0_201, net_0_202, net_0_203, net_0_204,
         net_0_205, net_0_206, net_0_207, net_0_208, net_0_209, net_0_210, net_0_211,
         net_0_212, net_0_213, net_0_214, net_0_215, net_0_216, net_0_217, net_0_218,
         net_0_219, net_0_220, net_0_221, net_0_222, net_0_223, net_0_224, net_0_225,
         net_0_226, net_0_227, net_0_228, net_0_229, net_0_230, net_0_231, net_0_232,
         net_0_233, net_0_234, net_0_235, net_0_236, net_0_237, net_0_238, net_0_239,
         net_0_240, net_0_241, net_0_242, net_0_243, net_0_244, net_0_245, net_0_246,
         net_0_247, net_0_248, net_0_249, net_0_250, net_0_251, net_0_252, net_0_253,
         net_0_254, net_0_255, net_0_256, net_0_257, net_0_258, net_0_259, net_0_260,
         net_0_261, net_0_262, net_0_263, net_0_264, net_0_265, net_0_266, net_0_267,
         net_0_268, net_0_269, net_0_270, net_0_271, net_0_272, net_0_273, net_0_274,
         net_0_275, net_0_276, net_0_277, net_0_278, net_0_279, net_0_280, net_0_281,
         net_0_282, net_0_283, net_0_284, net_0_285, net_0_286, net_0_287, net_0_288,
         net_0_289, net_0_290, net_0_291, net_0_292, net_0_293, net_0_294, net_0_295,
         net_0_296, net_0_297, net_0_298, net_0_299, net_0_300, net_0_301, net_0_302,
         net_0_303, net_0_304, net_0_305, net_0_306, net_0_307, net_0_308, net_0_309,
         net_0_310, net_0_311, net_0_312, net_0_313, net_0_314, net_0_315, net_0_316,
         net_0_317, net_0_318, net_0_319, net_0_320, net_0_321, net_0_322, net_0_323,
         net_0_324, net_0_325, net_0_326, net_0_327, net_0_328, net_0_329, net_0_330,
         net_0_331, net_0_332, net_0_333, net_0_334, net_0_335, net_0_336, net_0_337,
         net_0_338, net_0_339, net_0_340, net_0_341, net_0_342, net_0_343, net_0_344,
         net_0_345, net_0_346, net_0_347, net_0_348, net_0_349, net_0_350, net_0_351,
         net_0_352, net_0_353, net_0_354, net_0_355, net_0_356, net_0_357, net_0_358,
         net_0_359, net_0_360, net_0_361, net_0_362, net_0_363, net_0_364, net_0_365,
         net_0_366, net_0_367, net_0_370, net_0_371, net_0_372, net_0_373, net_0_374,
         net_0_375, net_0_376, net_0_377, net_0_378, net_0_379, net_0_380, net_0_381,
         net_0_382, net_0_383, net_0_384, net_0_385, net_0_386, net_0_387, net_0_388,
         net_0_390, net_0_392, net_0_393, net_0_394, net_0_395, net_0_396, net_0_397,
         net_0_398, net_0_399, net_0_400, net_0_401, net_0_402, net_0_403, net_0_404,
         net_0_405, net_0_406, net_0_407, net_0_408, net_0_409, net_0_410, net_0_411,
         net_0_412, net_0_413, net_0_414, net_0_415, net_0_416, net_0_417, net_0_418,
         net_0_419, net_0_420, net_0_421, net_0_422, net_0_423, net_0_424, net_0_425,
         net_0_426, net_0_427, net_0_428, net_0_429, net_0_430, net_0_431, net_0_432,
         net_0_433, net_0_434, net_0_435, net_0_436, net_0_437, net_0_438, net_0_439,
         net_0_440, net_0_441, net_0_442, net_0_443, net_0_444, net_0_445, net_0_446,
         net_0_447, net_0_448, net_0_449, net_0_450, net_0_451, net_0_452, net_0_453,
         net_0_454, net_0_455, net_0_456, net_0_457, net_0_458, net_0_459, net_0_460,
         net_0_461, net_0_462, net_0_463, net_0_464, net_0_465, net_0_466, net_0_467,
         net_0_468, net_0_469, net_0_470, net_0_471, net_0_472, net_0_473, net_0_474,
         net_0_475, net_0_476, net_0_477, net_0_478, net_0_479, net_0_480, net_0_481,
         net_0_482, net_0_483, net_0_484, net_0_485, net_0_486, net_0_487, net_0_488,
         net_0_489, net_0_490, net_0_491, net_0_492, net_0_493, net_0_494, net_0_495,
         net_0_496, net_0_497, net_0_498, net_0_499, net_0_500, net_0_501, net_0_502,
         net_0_503, net_0_504, net_0_505, net_0_506, net_0_507, net_0_508, net_0_509,
         net_0_510, net_0_511, net_0_512, net_0_513, net_0_514, net_0_515, net_0_516,
         net_0_517, net_0_518, net_0_519, net_0_520, net_0_521, net_0_522, net_0_523,
         net_0_524, net_0_525, net_0_526, net_0_527, net_0_528, net_0_529, net_0_530,
         net_0_531, net_0_532, net_0_533;

  assign instr1_need_late_ex1[3] = instr1_reads[3];
  assign instr1_need_early_iss[2] = 1'b0;
  assign instr1_need_early_iss[1] = 1'b0;
  assign instr1_ex1_ctl_shift_rrx_for_0_a = 1'b0;
  assign net_0_1 = ~iq_instr1_sideband_i[3];
  assign net_0_3 = ~iq_instr1_sideband_i[1];
  assign net_0_4 = ~net_0_326;
  assign net_0_5 = ~iq_instr1_is_dp_i;
  assign net_0_6 = ~iq_instr1_is_ot_i;
  assign net_0_7 = ~instr1_shf_type_imm_field_zero;
  assign net_0_8 = ~instr1_3_0_is_pc;
  assign net_0_9 = ~iq_instr1_i[28];
  assign net_0_10 = ~net_0_118;
  assign net_0_11 = ~iq_instr1_i[26];
  assign net_0_12 = ~iq_instr1_i[25];
  assign net_0_13 = ~iq_instr1_i[24];
  assign net_0_14 = ~iq_instr1_i[23];
  assign net_0_15 = ~iq_instr1_i[22];
  assign net_0_16 = ~iq_instr1_i[21];
  assign net_0_17 = ~iq_instr1_i[20];
  assign net_0_18 = ~iq_instr1_i[6];
  assign str_valid_instr1 = (net_0_20 | net_0_21);
  assign net_0_21 = (net_0_22 | net_0_23);
  assign net_0_23 = ~(net_0_24 & net_0_25);
  assign net_0_25 = (net_0_26 & net_0_27);
  assign net_0_27 = (net_0_28 | iq_instr1_i[20]);
  assign net_0_26 = (net_0_29 & net_0_30);
  assign net_0_30 = (net_0_31 & net_0_32);
  assign net_0_32 = ~(net_0_33 & iq_instr1_i[20]);
  assign net_0_31 = ~(net_0_34 | net_0_35);
  assign net_0_35 = ~(net_0_36 | net_0_37);
  assign net_0_37 = (net_0_38 | net_0_39);
  assign net_0_29 = (net_0_40 & net_0_41);
  assign net_0_41 = ~(net_0_10 & net_0_42);
  assign net_0_40 = (net_0_43 | instr1_a64_only);
  assign net_0_43 = ~(net_0_44 & net_0_45);
  assign str0_valid_instr1 = ~(net_0_46 & net_0_47);
  assign net_0_47 = (net_0_11 | net_0_48);
  assign net_0_48 = ~(instr1_a64_only & net_0_49);
  assign net_0_49 = (net_0_9 & iq_instr1_i[23]);
  assign net_0_46 = (net_0_50 | net_0_13);
  assign net_0_50 = (net_0_51 & net_0_52);
  assign net_0_52 = ~(iq_instr1_sideband_i[3] & net_0_53);
  assign net_0_51 = ~(net_0_54 & net_0_55);
  assign net_0_55 = (instr1_sf_bit & net_0_17);
  assign instr1_w0_enabled = (net_0_56 | net_0_57);
  assign net_0_57 = (net_0_58 | net_0_59);
  assign net_0_59 = (net_0_60 | net_0_61);
  assign net_0_61 = (net_0_62 | net_0_63);
  assign net_0_63 = (iq_instr1_i[22] & net_0_64);
  assign net_0_64 = (net_0_65 & net_0_54);
  assign net_0_62 = (net_0_15 & net_0_66);
  assign net_0_66 = (mac_valid_instr1 & iq_instr1_i[23]);
  assign net_0_60 = (net_0_67 | net_0_68);
  assign net_0_68 = ~(net_0_69 & net_0_70);
  assign net_0_70 = ~(net_0_71 & net_0_72);
  assign net_0_58 = (iq_instr1_i[20] & net_0_73);
  assign net_0_73 = (net_0_74 | net_0_75);
  assign net_0_75 = (net_0_76 | net_0_33);
  assign net_0_33 = (net_0_77 & net_0_13);
  assign net_0_76 = (net_0_78 | net_0_79);
  assign net_0_79 = (iq_instr1_is_ls_i & net_0_80);
  assign net_0_80 = (net_0_81 | net_0_82);
  assign net_0_82 = (net_0_83 & net_0_11);
  assign net_0_81 = (iq_instr1_i[26] & net_0_84);
  assign net_0_84 = ~(instr1_cc_never & net_0_85);
  assign net_0_85 = (iq_instr1_i[24] | iq_instr1_sideband_i[2]);
  assign net_0_78 = (net_0_15 & net_0_86);
  assign net_0_86 = (net_0_87 | net_0_88);
  assign net_0_88 = (net_0_89 & net_0_90);
  assign net_0_90 = (iq_instr1_sideband_i[4] & net_0_11);
  assign net_0_89 = (iq_instr1_i[9] & net_0_14);
  assign net_0_87 = ~(net_0_91 & net_0_92);
  assign net_0_92 = ~(iq_instr1_i[21] & mac_valid_instr1);
  assign mac_valid_instr1 = (iq_instr1_i[24] & net_0_93);
  assign net_0_91 = (net_0_94 | instr1_15_12_is_pc);
  assign net_0_74 = ~(net_0_38 | net_0_95);
  assign net_0_95 = (iq_instr1_sideband_i[5] | net_0_96);
  assign net_0_96 = ~(net_0_97 & net_0_98);
  assign net_0_56 = ~(net_0_99 & net_0_100);
  assign net_0_100 = (iq_instr1_i[25] | net_0_101);
  assign net_0_99 = ~(net_0_102 | net_0_103);
  assign net_0_102 = (net_0_104 & net_0_105);
  assign net_0_105 = (net_0_106 & iq_instr1_i[28]);
  assign net_0_104 = (net_0_72 & net_0_17);
  assign instr1_skewable = (net_0_107 | net_0_108);
  assign net_0_108 = (net_0_109 | net_0_110);
  assign net_0_110 = ~(net_0_111 & net_0_112);
  assign net_0_112 = ~(instr1_a64_only & net_0_113);
  assign net_0_113 = ~(net_0_114 & net_0_115);
  assign net_0_115 = (net_0_12 | net_0_116);
  assign net_0_114 = ~(iq_instr1_i[8] & net_0_117);
  assign net_0_117 = ~(iq_instr1_i[26] | net_0_118);
  assign net_0_107 = (net_0_119 | net_0_120);
  assign net_0_120 = (net_0_121 | net_0_122);
  assign net_0_121 = (net_0_13 & net_0_123);
  assign net_0_123 = (iq_instr1_is_ls_i & net_0_124);
  assign net_0_124 = ~(net_0_125 & net_0_126);
  assign net_0_126 = ~(net_0_127 & iq_instr1_i[26]);
  assign net_0_125 = (net_0_128 | iq_instr1_i[20]);
  assign net_0_119 = (net_0_54 & net_0_129);
  assign net_0_129 = (net_0_130 | net_0_131);
  assign net_0_131 = ~(iq_instr1_i[23] | net_0_132);
  assign net_0_132 = (iq_instr1_sideband_i[2] | net_0_133);
  assign net_0_133 = ~(iq_instr1_i[11] & iq_instr1_i[8]);
  assign net_0_130 = (net_0_134 & net_0_135);
  assign net_0_135 = (instr1_3_0_is_sp | net_0_8);
  assign net_0_54 = (net_0_98 & net_0_12);
  assign instr1_skew_r1 = (net_0_136 | net_0_137);
  assign net_0_137 = (net_0_138 | net_0_122);
  assign net_0_122 = ~(instr1_a32_only | net_0_139);
  assign net_0_139 = ~(net_0_140 & net_0_141);
  assign net_0_141 = (net_0_142 | iq_instr1_i[21]);
  assign net_0_142 = (net_0_106 & net_0_143);
  assign net_0_143 = ~(iq_instr1_i[4] | iq_instr1_i[5]);
  assign net_0_106 = (iq_instr1_i[22] & net_0_14);
  assign net_0_138 = (iq_instr1_is_dp_i & net_0_144);
  assign instr1_skew_r0 = ~(net_0_111 & net_0_145);
  assign net_0_145 = (iq_instr1_i[22] | net_0_146);
  assign net_0_146 = ~(net_0_147 & net_0_140);
  assign net_0_140 = ~(iq_instr1_i[24] | net_0_148);
  assign net_0_148 = (net_0_7 | net_0_4);
  assign net_0_111 = (net_0_149 & net_0_150);
  assign net_0_150 = ~(iq_instr1_is_dp_i & net_0_151);
  assign net_0_151 = ~(net_0_152 & net_0_153);
  assign net_0_153 = (net_0_154 | instr1_11_8_is_pc);
  assign net_0_152 = ~(net_0_144 | net_0_155);
  assign net_0_155 = (net_0_156 | net_0_157);
  assign net_0_157 = ~(iq_instr1_i[25] | net_0_158);
  assign net_0_158 = ~(iq_instr1_sideband_i[1] & net_0_159);
  assign net_0_159 = (net_0_65 | net_0_83);
  assign net_0_156 = ~(iq_instr1_i[22] | net_0_160);
  assign net_0_160 = ~(iq_instr1_sideband_i[3] & net_0_161);
  assign net_0_144 = (net_0_162 | net_0_163);
  assign net_0_163 = ~(iq_instr1_i[24] | net_0_164);
  assign net_0_164 = ~(net_0_165 & net_0_166);
  assign net_0_166 = ~(iq_instr1_i[7] | iq_instr1_i[4]);
  assign net_0_162 = (net_0_167 & net_0_168);
  assign net_0_168 = ~(iq_instr1_i[28] | instr1_a32_only);
  assign net_0_167 = (instr1_shf_type_imm_field_zero & net_0_169);
  assign net_0_169 = (net_0_170 | net_0_171);
  assign net_0_171 = (iq_instr1_i[22] & net_0_172);
  assign net_0_170 = (net_0_173 & net_0_174);
  assign net_0_173 = ~(iq_instr1_i[22] | instr1_11_8_is_pc);
  assign net_0_149 = (net_0_175 | net_0_154);
  assign net_0_154 = (iq_instr1_i[22] | net_0_176);
  assign net_0_176 = (iq_instr1_i[25] | instr1_a64_only);
  assign net_0_175 = (iq_instr1_i[24] | net_0_177);
  assign net_0_177 = ~(iq_instr1_aarch64_i & net_0_178);
  assign net_0_178 = ~(iq_instr1_is_ls_i | iq_instr1_i[15]);
  assign instr1_selects_pc = ~(net_0_179 & net_0_180);
  assign net_0_180 = (iq_instr1_i[27] | net_0_181);
  assign net_0_181 = (net_0_182 & net_0_183);
  assign net_0_183 = (iq_instr1_is_ls_i | net_0_184);
  assign net_0_182 = (net_0_185 & net_0_186);
  assign net_0_186 = (iq_instr1_sideband_i[1] | net_0_187);
  assign net_0_187 = (net_0_5 | net_0_14);
  assign net_0_185 = (net_0_188 & net_0_189);
  assign net_0_189 = (iq_instr1_i[14] | net_0_190);
  assign net_0_190 = (net_0_191 | iq_instr1_i[15]);
  assign net_0_188 = (instr1_a64_only | net_0_192);
  assign net_0_192 = (instr1_a32_only | net_0_193);
  assign net_0_193 = ~(iq_instr1_i[15] & iq_instr1_i[14]);
  assign net_0_179 = ~(net_0_194 | net_0_195);
  assign net_0_195 = (net_0_103 | net_0_196);
  assign net_0_196 = (net_0_197 | net_0_198);
  assign net_0_198 = ~(net_0_199 & net_0_200);
  assign net_0_199 = (net_0_201 & net_0_202);
  assign net_0_202 = (net_0_203 | iq_instr1_sideband_i[4]);
  assign net_0_203 = (iq_instr1_i[24] | net_0_118);
  assign net_0_201 = (net_0_204 & net_0_205);
  assign net_0_205 = (net_0_206 & net_0_207);
  assign net_0_207 = ~(iq_instr1_is_dp_i & instr1_a64_only);
  assign net_0_206 = ~(iq_instr1_is_ot_i & iq_instr1_i[27]);
  assign net_0_197 = (net_0_34 | net_0_208);
  assign net_0_208 = ~(net_0_209 & net_0_210);
  assign net_0_210 = ~(net_0_211 & net_0_147);
  assign net_0_34 = (iq_instr1_is_ls_i & net_0_212);
  assign net_0_212 = (net_0_134 & net_0_213);
  assign net_0_103 = (iq_instr1_is_ls_i & net_0_214);
  assign net_0_214 = ~(net_0_215 & net_0_216);
  assign net_0_216 = (net_0_217 | iq_instr1_i[25]);
  assign net_0_217 = (instr1_a32_only | net_0_218);
  assign net_0_215 = ~(net_0_219 & net_0_13);
  assign net_0_194 = (net_0_220 | net_0_221);
  assign net_0_220 = (net_0_222 & net_0_223);
  assign net_0_223 = ~(net_0_94 | iq_instr1_aarch64_i);
  assign net_0_222 = ~(iq_instr1_i[22] | net_0_224);
  assign net_0_224 = (instr1_15_12_is_pc | net_0_225);
  assign net_0_225 = ~(iq_instr1_i[20] & instr1_19_16_is_pc);
  assign instr1_reads[2] = (net_0_226 | instr1_need_late_ex1[2]);
  assign instr1_reads[1] = ~(net_0_227 & net_0_228);
  assign net_0_227 = ~(net_0_229 | net_0_230);
  assign net_0_230 = ~(net_0_231 & net_0_232);
  assign net_0_231 = ~(net_0_20 | net_0_233);
  assign net_0_233 = (iq_instr1_is_ls_i & net_0_234);
  assign net_0_234 = (net_0_235 | net_0_236);
  assign net_0_236 = (net_0_53 | net_0_237);
  assign net_0_237 = (net_0_238 | net_0_239);
  assign net_0_239 = (instr1_a32_only & net_0_17);
  assign net_0_53 = (instr1_a64_only & iq_instr1_i[27]);
  assign net_0_20 = ~(instr1_a64_only | net_0_240);
  assign instr1_reads[0] = (net_0_241 | net_0_242);
  assign net_0_242 = (net_0_243 | net_0_244);
  assign net_0_243 = (net_0_45 & net_0_245);
  assign net_0_245 = (net_0_246 | net_0_247);
  assign net_0_247 = ~(instr1_19_16_is_pc | net_0_248);
  assign net_0_248 = ~(net_0_44 & net_0_3);
  assign net_0_44 = ~(iq_instr1_i[14] | net_0_249);
  assign net_0_249 = ~(net_0_250 & net_0_251);
  assign net_0_246 = ~(instr1_a64_only | net_0_252);
  assign net_0_252 = ~(iq_instr1_aarch64_i & iq_instr1_i[8]);
  assign net_0_45 = ~(iq_instr1_i[12] | net_0_6);
  assign net_0_241 = (net_0_221 | net_0_253);
  assign net_0_253 = (net_0_254 | net_0_255);
  assign net_0_254 = (net_0_256 & net_0_172);
  assign net_0_172 = (net_0_257 | net_0_65);
  assign net_0_65 = (iq_instr1_i[24] & net_0_258);
  assign net_0_257 = (net_0_259 & net_0_13);
  assign net_0_221 = (net_0_134 & net_0_260);
  assign net_0_260 = ~(iq_instr1_i[12] | net_0_261);
  assign net_0_261 = (iq_instr1_i[0] | net_0_262);
  assign net_0_262 = ~(iq_instr1_sideband_i[0] & net_0_251);
  assign instr1_r2_enabled = ~(net_0_228 & net_0_263);
  assign net_0_263 = ~(net_0_264 | net_0_265);
  assign net_0_265 = ~(net_0_266 & net_0_267);
  assign net_0_267 = ~(net_0_255 | net_0_268);
  assign net_0_255 = (net_0_269 & net_0_12);
  assign net_0_269 = (iq_instr1_sideband_i[2] & iq_instr1_is_fn_i);
  assign net_0_266 = (net_0_270 & net_0_271);
  assign net_0_271 = (net_0_272 | iq_instr1_i[25]);
  assign net_0_270 = ~(net_0_273 | net_0_226);
  assign net_0_226 = ~(net_0_232 & net_0_274);
  assign net_0_274 = ~(net_0_77 & net_0_11);
  assign net_0_77 = (net_0_9 & net_0_10);
  assign instr1_need_late_iss[3] = (net_0_275 | net_0_276);
  assign net_0_276 = (net_0_277 | net_0_278);
  assign net_0_278 = (net_0_279 | instr1_need_early_iss[3]);
  assign net_0_275 = (net_0_280 | net_0_264);
  assign net_0_280 = ~(iq_instr1_sideband_i[0] | net_0_281);
  assign net_0_281 = ~(iq_instr1_i[27] & net_0_282);
  assign instr1_need_late_iss[0] = (net_0_283 | net_0_284);
  assign net_0_284 = (net_0_268 | net_0_285);
  assign net_0_285 = (net_0_286 | net_0_279);
  assign net_0_279 = (net_0_287 | net_0_67);
  assign net_0_67 = (net_0_288 & net_0_13);
  assign net_0_287 = (net_0_93 & net_0_289);
  assign net_0_289 = (iq_instr1_i[24] | net_0_290);
  assign net_0_286 = (net_0_291 | instr1_need_early_iss[0]);
  assign net_0_291 = (net_0_15 & net_0_292);
  assign net_0_292 = (net_0_293 & iq_instr1_i[4]);
  assign net_0_293 = (net_0_294 & net_0_295);
  assign net_0_295 = (iq_instr1_i[23] & iq_instr1_i[7]);
  assign net_0_294 = (net_0_93 & net_0_17);
  assign net_0_268 = (iq_instr1_is_dp_i & net_0_296);
  assign net_0_283 = (net_0_297 & net_0_298);
  assign net_0_298 = ~(instr1_shf_imm_field_zero & net_0_299);
  assign net_0_299 = ~(iq_instr1_i[22] | instr1_a32_only);
  assign instr1_reads[3] = (net_0_300 | net_0_301);
  assign net_0_301 = (net_0_136 | net_0_302);
  assign net_0_302 = ~(net_0_303 & net_0_304);
  assign net_0_304 = ~(net_0_288 | net_0_305);
  assign net_0_305 = ~(net_0_306 & net_0_307);
  assign net_0_307 = ~(net_0_264 | net_0_308);
  assign net_0_264 = (net_0_309 & net_0_310);
  assign net_0_306 = ~(net_0_311 & net_0_312);
  assign net_0_312 = (iq_instr1_i[27] & iq_instr1_i[15]);
  assign net_0_311 = (net_0_313 & iq_instr1_i[25]);
  assign net_0_136 = (net_0_12 & net_0_314);
  assign net_0_314 = ~(net_0_315 & net_0_101);
  assign net_0_101 = ~(net_0_316 | net_0_317);
  assign net_0_317 = (net_0_318 & iq_instr1_sideband_i[2]);
  assign net_0_318 = (net_0_319 & net_0_320);
  assign net_0_320 = (iq_instr1_sideband_i[4] & iq_instr1_i[5]);
  assign net_0_319 = (iq_instr1_i[6] & net_0_13);
  assign net_0_315 = (net_0_272 & net_0_321);
  assign net_0_321 = (instr1_3_0_is_sp | net_0_322);
  assign net_0_322 = ~(net_0_323 & net_0_98);
  assign net_0_323 = (net_0_8 & net_0_134);
  assign net_0_134 = (iq_instr1_i[24] & net_0_238);
  assign net_0_238 = ~(instr1_a64_only | iq_instr1_i[20]);
  assign net_0_272 = ~(iq_instr1_sideband_i[4] & net_0_324);
  assign net_0_324 = ~(iq_instr1_i[20] | net_0_325);
  assign net_0_300 = (net_0_326 & net_0_327);
  assign net_0_327 = ~(net_0_328 & net_0_329);
  assign net_0_328 = (net_0_330 & net_0_331);
  assign net_0_331 = (net_0_13 | iq_instr1_i[23]);
  assign net_0_330 = (instr1_shf_type_imm_field_zero & net_0_332);
  assign net_0_332 = (net_0_333 & net_0_334);
  assign net_0_334 = ~(net_0_13 & net_0_335);
  assign net_0_333 = (instr1_a32_only & iq_instr1_sideband_i[3]);
  assign instr1_need_late_ex1[2] = (net_0_336 | instr1_need_late_iss[2]);
  assign net_0_336 = (net_0_83 & net_0_337);
  assign net_0_337 = (net_0_338 & net_0_282);
  assign net_0_282 = (iq_instr1_is_dp_i & net_0_258);
  assign instr1_need_late_ex1[1] = (net_0_229 | instr1_need_late_iss[1]);
  assign instr1_need_late_iss[1] = ~(net_0_228 & net_0_339);
  assign net_0_339 = (net_0_340 | net_0_240);
  assign net_0_240 = (net_0_39 | iq_instr1_i[20]);
  assign net_0_39 = ~(net_0_341 & net_0_13);
  assign net_0_341 = (iq_instr1_i[4] & iq_instr1_is_fn_i);
  assign net_0_340 = ~(net_0_342 | net_0_343);
  assign net_0_343 = (net_0_251 & net_0_36);
  assign net_0_36 = (iq_instr1_i[22] | iq_instr1_i[8]);
  assign net_0_228 = ~(net_0_22 | net_0_344);
  assign net_0_344 = ~(net_0_4 | net_0_345);
  assign net_0_345 = ~(net_0_346 | net_0_347);
  assign net_0_22 = (net_0_308 & net_0_1);
  assign net_0_229 = (instr1_a64_only & net_0_348);
  assign net_0_348 = (iq_instr1_sideband_i[0] & iq_instr1_is_ot_i);
  assign instr1_need_late_ex1[0] = (net_0_349 | net_0_244);
  assign net_0_244 = (instr1_need_early_iss[0] | net_0_350);
  assign net_0_350 = (net_0_351 | net_0_352);
  assign net_0_352 = (net_0_353 | net_0_354);
  assign net_0_354 = (net_0_355 | net_0_356);
  assign net_0_356 = ~(net_0_357 & net_0_358);
  assign net_0_357 = (net_0_359 & net_0_360);
  assign net_0_360 = (net_0_4 | net_0_361);
  assign net_0_361 = ~(net_0_15 | net_0_346);
  assign net_0_346 = ~(iq_instr1_i[21] | iq_instr1_sideband_i[3]);
  assign net_0_355 = (net_0_362 | net_0_308);
  assign net_0_308 = (net_0_93 & net_0_3);
  assign net_0_362 = ~(iq_instr1_sideband_i[2] | net_0_363);
  assign net_0_363 = ~(iq_instr1_sideband_i[1] & iq_instr1_is_dp_i);
  assign net_0_351 = (net_0_256 & net_0_364);
  assign net_0_364 = ~(instr1_shf_type_imm_field_zero | net_0_365);
  assign net_0_349 = (net_0_256 & net_0_366);
  assign net_0_366 = (net_0_258 | net_0_259);
  assign net_0_256 = ~(instr1_a32_only | net_0_4);
  assign instr1_need_early_iss[3] = ~(net_0_303 & net_0_367);
  assign net_0_367 = ~(iq_instr1_i[24] & net_0_288);
  assign net_0_69 = (net_0_370 & net_0_200);
  assign net_0_200 = ~(net_0_371 & net_0_372);
  assign net_0_372 = ~(iq_instr1_i[26] | net_0_373);
  assign net_0_373 = ~(iq_instr1_sideband_i[2] & iq_instr1_i[24]);
  assign net_0_370 = (net_0_374 & net_0_375);
  assign net_0_375 = ~(net_0_376 & net_0_377);
  assign net_0_377 = (net_0_72 & net_0_12);
  assign net_0_72 = ~(iq_instr1_sideband_i[1] | net_0_378);
  assign net_0_378 = ~(iq_instr1_i[21] & iq_instr1_sideband_i[2]);
  assign net_0_376 = (net_0_379 | net_0_380);
  assign net_0_380 = ~(net_0_18 | iq_instr1_i[5]);
  assign net_0_379 = (iq_instr1_i[7] & net_0_381);
  assign net_0_381 = ~(iq_instr1_i[22] | iq_instr1_i[6]);
  assign net_0_273 = ~(net_0_382 & net_0_383);
  assign net_0_383 = (iq_instr1_sideband_i[0] | net_0_384);
  assign net_0_384 = (net_0_385 | net_0_116);
  assign net_0_116 = (iq_instr1_i[27] | net_0_386);
  assign net_0_386 = ~(iq_instr1_i[21] & iq_instr1_sideband_i[4]);
  assign net_0_385 = ~(iq_instr1_i[4] & iq_instr1_sideband_i[3]);
  assign net_0_382 = ~(net_0_387 & net_0_388);
  assign net_0_388 = (iq_instr1_i[27] | net_0_250);
  assign net_0_250 = (iq_instr1_i[24] & iq_instr1_i[23]);
  assign net_0_387 = (net_0_309 & iq_instr1_sideband_i[2]);
  assign net_0_209 = ~(net_0_161 & net_0_371);
  assign net_0_371 = (iq_instr1_sideband_i[1] & net_0_393);
  assign net_0_393 = ~(iq_instr1_sideband_i[3] | net_0_17);
  assign net_0_161 = ~(iq_instr1_i[27] | net_0_12);
  assign instr1_need_early_iss[0] = (net_0_109 | net_0_394);
  assign net_0_394 = ~(net_0_395 & net_0_396);
  assign net_0_396 = ~(iq_instr1_is_ls_i & net_0_127);
  assign net_0_127 = ~(iq_instr1_sideband_i[2] | net_0_17);
  assign net_0_395 = (net_0_397 & net_0_374);
  assign net_0_374 = (net_0_218 | net_0_398);
  assign net_0_398 = (net_0_399 | net_0_400);
  assign net_0_400 = (net_0_13 | net_0_17);
  assign net_0_218 = (iq_instr1_i[27] | iq_instr1_i[26]);
  assign net_0_397 = ~(net_0_288 | net_0_401);
  assign net_0_401 = ~(net_0_402 & net_0_28);
  assign net_0_402 = (net_0_24 & net_0_390);
  assign net_0_390 = (net_0_392 | net_0_403);
  assign net_0_403 = ~(iq_instr1_sideband_i[4] & net_0_404);
  assign net_0_404 = (iq_instr1_i[20] & iq_instr1_sideband_i[3]);
  assign net_0_392 = (iq_instr1_i[11] | net_0_118);
  assign net_0_24 = (net_0_232 & net_0_405);
  assign net_0_405 = ~(net_0_309 & net_0_406);
  assign net_0_406 = ~(net_0_407 & net_0_408);
  assign net_0_408 = (net_0_128 | iq_instr1_i[24]);
  assign net_0_128 = ~(instr1_a32_only & net_0_12);
  assign net_0_407 = ~(net_0_310 | net_0_409);
  assign net_0_409 = (net_0_410 | net_0_98);
  assign net_0_410 = ~(instr1_a64_only | net_0_213);
  assign net_0_310 = (net_0_251 & net_0_13);
  assign net_0_251 = (iq_instr1_i[25] & iq_instr1_i[26]);
  assign net_0_309 = (iq_instr1_is_ls_i & net_0_17);
  assign net_0_232 = (iq_instr1_i[28] | net_0_411);
  assign net_0_411 = ~(net_0_313 & net_0_235);
  assign net_0_235 = ~(instr1_a32_only | net_0_11);
  assign net_0_313 = ~(iq_instr1_is_fn_i | iq_instr1_is_ot_i);
  assign net_0_288 = ~(net_0_12 | net_0_399);
  assign net_0_399 = ~(iq_instr1_is_ls_i & iq_instr1_sideband_i[0]);
  assign net_0_109 = (net_0_12 & net_0_412);
  assign net_0_412 = (net_0_316 | net_0_413);
  assign net_0_413 = (iq_instr1_is_ls_i & net_0_347);
  assign net_0_316 = ~(iq_instr1_sideband_i[1] | net_0_325);
  assign net_0_325 = (iq_instr1_i[24] | net_0_414);
  assign net_0_414 = ~(iq_instr1_sideband_i[2] & net_0_415);
  assign net_0_415 = ~(iq_instr1_i[21] | iq_instr1_i[27]);
  assign instr1_ex1_ctl_shift_rrx_for_0_t = (net_0_416 | net_0_417);
  assign net_0_417 = (net_0_326 & net_0_418);
  assign net_0_418 = (net_0_419 | net_0_420);
  assign net_0_420 = ~(instr1_a32_only | net_0_421);
  assign net_0_421 = (net_0_422 & net_0_423);
  assign net_0_423 = (net_0_424 | instr1_shf_type_imm_field_zero);
  assign net_0_424 = (net_0_425 & net_0_426);
  assign net_0_426 = ~(net_0_15 & net_0_427);
  assign net_0_425 = ~(net_0_147 | net_0_428);
  assign net_0_428 = (iq_instr1_i[22] & net_0_429);
  assign net_0_429 = ~(net_0_365 & net_0_16);
  assign net_0_365 = ~(iq_instr1_i[24] | net_0_259);
  assign net_0_259 = ~(iq_instr1_i[23] | instr1_19_16_is_pc);
  assign net_0_419 = (net_0_430 & net_0_431);
  assign net_0_431 = (iq_instr1_i[4] & iq_instr1_i[5]);
  assign net_0_416 = (net_0_432 & net_0_433);
  assign net_0_433 = (net_0_434 & iq_instr1_i[14]);
  assign net_0_432 = (iq_instr1_i[21] & net_0_14);
  assign instr1_ex1_ctl_shift_op[2] = (instr1_need_late_iss[2] | net_0_435);
  assign net_0_435 = (net_0_277 | net_0_436);
  assign net_0_436 = (net_0_437 | net_0_438);
  assign net_0_437 = (net_0_297 & net_0_16);
  assign net_0_277 = (iq_instr1_is_dp_i & net_0_439);
  assign net_0_439 = ~(net_0_440 & net_0_441);
  assign net_0_441 = (iq_instr1_i[28] | net_0_442);
  assign net_0_442 = ~(net_0_443 | net_0_444);
  assign net_0_444 = (net_0_347 | net_0_445);
  assign net_0_445 = ~(net_0_446 & instr1_shf_type_imm_field_zero);
  assign net_0_446 = (net_0_422 & net_0_447);
  assign net_0_447 = (iq_instr1_i[21] | net_0_448);
  assign net_0_448 = (iq_instr1_sideband_i[3] & net_0_449);
  assign net_0_449 = ~(net_0_83 & net_0_335);
  assign net_0_335 = (net_0_450 | iq_instr1_i[23]);
  assign net_0_450 = (instr1_19_16_is_pc & net_0_451);
  assign net_0_451 = (iq_instr1_i[4] | iq_instr1_i[5]);
  assign net_0_347 = (instr1_a32_only & iq_instr1_i[21]);
  assign net_0_443 = ~(iq_instr1_i[22] | net_0_174);
  assign net_0_174 = ~(iq_instr1_i[24] & net_0_452);
  assign net_0_452 = (iq_instr1_i[23] ^ iq_instr1_i[21]);
  assign net_0_440 = ~(net_0_296 | net_0_453);
  assign net_0_453 = (net_0_454 | net_0_455);
  assign net_0_454 = ~(iq_instr1_i[5] | net_0_456);
  assign net_0_456 = ~(iq_instr1_i[7] & net_0_457);
  assign net_0_296 = (iq_instr1_i[15] & net_0_458);
  assign instr1_need_late_iss[2] = ~(net_0_459 & net_0_358);
  assign net_0_358 = ~(net_0_297 & net_0_460);
  assign net_0_460 = (iq_instr1_i[22] & iq_instr1_i[21]);
  assign net_0_459 = ~(net_0_461 & net_0_458);
  assign net_0_458 = (iq_instr1_sideband_i[1] & iq_instr1_sideband_i[0]);
  assign instr1_ex1_ctl_shift_op[1] = (net_0_462 | net_0_463);
  assign net_0_463 = (net_0_438 | net_0_464);
  assign net_0_464 = (net_0_465 | net_0_466);
  assign net_0_465 = (net_0_467 & net_0_434);
  assign net_0_434 = (net_0_83 & net_0_93);
  assign net_0_438 = ~(iq_instr1_i[22] | net_0_468);
  assign net_0_468 = ~(net_0_297 & net_0_469);
  assign net_0_469 = (instr1_a32_only | net_0_470);
  assign net_0_470 = ~(net_0_16 | instr1_shf_imm_field_zero);
  assign net_0_297 = (iq_instr1_is_dp_i & net_0_471);
  assign net_0_462 = (iq_instr1_i[5] & net_0_472);
  assign net_0_472 = (net_0_473 | net_0_353);
  assign net_0_353 = (net_0_258 & net_0_211);
  assign net_0_211 = (net_0_83 & net_0_326);
  assign net_0_258 = ~(iq_instr1_i[21] | net_0_14);
  assign net_0_473 = ~(net_0_474 & net_0_475);
  assign net_0_475 = (net_0_422 | net_0_4);
  assign net_0_474 = ~(net_0_476 | net_0_477);
  assign net_0_476 = ~(iq_instr1_i[28] | net_0_478);
  assign net_0_478 = ~(net_0_479 & net_0_480);
  assign net_0_480 = (iq_instr1_sideband_i[3] & iq_instr1_i[27]);
  assign instr1_ex1_ctl_shift_op[0] = (net_0_481 | net_0_482);
  assign net_0_482 = (net_0_483 | net_0_466);
  assign net_0_466 = (iq_instr1_is_dp_i & net_0_484);
  assign net_0_484 = (net_0_455 | net_0_485);
  assign net_0_485 = (net_0_471 & net_0_486);
  assign net_0_486 = (net_0_329 | net_0_487);
  assign net_0_487 = (iq_instr1_aarch64_i & net_0_3);
  assign net_0_329 = (iq_instr1_i[22] & net_0_16);
  assign net_0_471 = ~(iq_instr1_i[27] | iq_instr1_sideband_i[0]);
  assign net_0_455 = (iq_instr1_i[7] & net_0_488);
  assign net_0_488 = (net_0_489 | net_0_490);
  assign net_0_490 = (net_0_457 & instr1_sf_bit);
  assign net_0_457 = (iq_instr1_i[22] & net_0_165);
  assign net_0_165 = (iq_instr1_i[23] & net_0_98);
  assign net_0_489 = (iq_instr1_i[15] & net_0_491);
  assign net_0_491 = (net_0_492 & iq_instr1_i[28]);
  assign net_0_483 = (net_0_493 & net_0_13);
  assign net_0_493 = (net_0_93 & net_0_494);
  assign net_0_494 = (net_0_290 | net_0_495);
  assign net_0_495 = (net_0_467 & iq_instr1_i[21]);
  assign net_0_467 = ~(iq_instr1_i[7] | net_0_496);
  assign net_0_496 = ~(iq_instr1_i[15] & net_0_14);
  assign net_0_290 = ~(iq_instr1_i[14] | net_0_17);
  assign net_0_93 = (iq_instr1_is_dp_i & net_0_98);
  assign net_0_98 = (iq_instr1_i[27] & iq_instr1_i[28]);
  assign net_0_481 = (iq_instr1_i[4] & net_0_497);
  assign net_0_497 = (net_0_477 | net_0_498);
  assign net_0_498 = (iq_instr1_sideband_i[3] & net_0_499);
  assign net_0_499 = ~(net_0_500 & net_0_501);
  assign net_0_501 = ~(net_0_479 & net_0_461);
  assign net_0_461 = (iq_instr1_i[25] & net_0_502);
  assign net_0_502 = (iq_instr1_i[24] & iq_instr1_is_dp_i);
  assign net_0_479 = (net_0_147 & net_0_7);
  assign net_0_500 = (net_0_422 | iq_instr1_sideband_i[1]);
  assign net_0_477 = (net_0_326 & net_0_503);
  assign net_0_503 = (instr1_a32_only | net_0_504);
  assign net_0_504 = (net_0_505 | net_0_430);
  assign net_0_430 = (net_0_83 & net_0_213);
  assign net_0_83 = (iq_instr1_i[22] & net_0_13);
  assign net_0_505 = ~(instr1_shf_type_imm_field_zero | net_0_506);
  assign net_0_506 = ~(net_0_427 | iq_instr1_i[22]);
  assign net_0_427 = ~(iq_instr1_i[24] & net_0_38);
  assign net_0_38 = (iq_instr1_i[23] | iq_instr1_i[21]);
  assign instr1_can_adrp_forward = ~(net_0_507 & net_0_508);
  assign net_0_508 = ~(iq_instr1_is_fn_i & net_0_219);
  assign net_0_507 = (net_0_94 | net_0_14);
  assign net_0_94 = (iq_instr1_is_fn_i | net_0_118);
  assign net_0_118 = ~(iq_instr1_i[27] & net_0_12);
  assign instr1_au_uses_cin = ~(net_0_359 & net_0_509);
  assign net_0_509 = ~(net_0_510 & net_0_12);
  assign net_0_510 = (net_0_511 & net_0_512);
  assign net_0_512 = (net_0_492 | net_0_342);
  assign net_0_342 = ~(instr1_a64_only | net_0_16);
  assign net_0_492 = (iq_instr1_sideband_i[3] & net_0_14);
  assign net_0_511 = (net_0_97 & iq_instr1_is_dp_i);
  assign net_0_359 = (net_0_513 & net_0_514);
  assign net_0_514 = ~(net_0_97 & net_0_515);
  assign net_0_515 = ~(net_0_4 | iq_instr1_i[23]);
  assign net_0_326 = ~(iq_instr1_i[28] | net_0_5);
  assign net_0_513 = (net_0_422 | net_0_516);
  assign net_0_516 = (iq_instr1_is_ot_i | net_0_191);
  assign net_0_191 = ~(net_0_9 & net_0_219);
  assign net_0_219 = (iq_instr1_i[25] & net_0_11);
  assign net_0_422 = ~(net_0_147 & net_0_97);
  assign net_0_97 = (iq_instr1_i[22] & iq_instr1_i[24]);
  assign net_0_147 = (iq_instr1_i[23] & iq_instr1_i[21]);
  assign dcu_valid_instr1 = (iq_instr1_is_ls_i | net_0_517);
  assign net_0_517 = ~(net_0_518 & net_0_519);
  assign net_0_519 = (net_0_184 | iq_instr1_i[27]);
  assign net_0_184 = ~(net_0_520 & net_0_12);
  assign net_0_518 = (net_0_204 & net_0_28);
  assign net_0_28 = ~(iq_instr1_sideband_i[3] & iq_instr1_is_fn_i);
  assign net_0_204 = (iq_instr1_i[25] | net_0_521);
  assign net_0_521 = (net_0_522 & net_0_523);
  assign net_0_523 = ~(net_0_520 & net_0_524);
  assign net_0_524 = (net_0_71 & net_0_525);
  assign net_0_525 = (net_0_213 & iq_instr1_i[20]);
  assign net_0_213 = (instr1_19_16_is_pc & net_0_16);
  assign net_0_71 = (iq_instr1_i[24] & iq_instr1_i[26]);
  assign net_0_520 = ~(iq_instr1_is_dp_i | iq_instr1_is_ot_i);
  assign net_0_522 = ~(iq_instr1_i[27] & net_0_42);
  assign net_0_42 = ~(iq_instr1_sideband_i[1] | net_0_526);
  assign net_0_526 = (iq_instr1_sideband_i[3] | net_0_527);
  assign net_0_527 = ~(iq_instr1_i[26] & net_0_17);
  assign br_valid_instr1 = (iq_instr1_is_ot_i & net_0_528);
  assign net_0_528 = ~(net_0_338 & net_0_529);
  assign net_0_529 = ~(iq_instr1_i[28] & net_0_3);
  assign net_0_338 = ~(instr1_a64_only | iq_instr1_i[27]);
  assign net_0_530 = (net_0_392 | net_0_11);
  assign net_0_531 = (net_0_209 & net_0_530);
  assign net_0_532 = (net_0_390 & net_0_69);
  assign net_0_533 = ~(net_0_531 & net_0_532);
  assign net_0_303 = ~(net_0_273 | net_0_533);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  assign instr0_cc_never    = (iq_instr0_i[32:29] == 4'b1111) & ~iq_instr0_ctl_aarch64_i & ~iq_instr0_pdtype_i[1];

  assign instr0_19_16_is_pc = (iq_instr0_i[19:16] == 4'b1111) & ~iq_instr0_ctl_aarch64_i;
  assign instr0_15_12_is_pc = (iq_instr0_i[15:12] == 4'b1111) & ~iq_instr0_ctl_aarch64_i;
  assign instr0_11_8_is_pc  = (iq_instr0_i[11: 8] == 4'b1111) & ~iq_instr0_ctl_aarch64_i;
  assign instr0_3_0_is_pc   = iq_instr0_ctl_aarch64_i ? ~iq_instr0_i[29] 
                                                      : (iq_instr0_i[ 3: 0] == 4'b1111);
  assign instr0_3_0_is_sp   = iq_instr0_ctl_aarch64_i ? (iq_instr0_i[29] & ({iq_instr0_i[31], iq_instr0_i[3:0]}   == 5'b11111)) 
                                                      : (iq_instr0_i[ 3: 0] == 4'b1101);

  assign instr0_a32_only    = (iq_instr0_pdtype_i == 2'b01) & ~iq_instr0_ctl_aarch64_i;
  assign instr0_a64_only    = (iq_instr0_pdtype_i == 2'b01) &  iq_instr0_ctl_aarch64_i;

  assign instr0_sf_bit      = iq_instr0_i[32] & iq_instr0_ctl_aarch64_i;

  assign instr0_agu_can_shift = iq_instr0_i[23] &             // Positive offset
                                (iq_instr0_i[11:7] < 5'd4) &  // Shift amount is less than 4
                                (iq_instr0_i[6:5] == 2'b00);  // Shift is LSL

  assign instr0_shf_imm_field_zero      = iq_instr0_ctl_aarch64_i ? ({iq_instr0_i[15:12], iq_instr0_i[7:6]} == 6'b00_0000)
                                                                  : ({iq_instr0_i[14:12], iq_instr0_i[7:6]} == 5'b0_0000);
  assign instr0_shf_type_imm_field_zero = iq_instr0_ctl_aarch64_i ?  ({iq_instr0_i[15:12], iq_instr0_i[7:6]} == 6'b00_0000)
                                                                  : (({iq_instr0_i[14:12], iq_instr0_i[7:6]} == 5'b0_0000) & (iq_instr0_i[5:4] == 2'b00));

  // ------------------------------------------------------
  // Start Slot 0 integer automatically generated logic
  // ------------------------------------------------------

  wire    net_1_1, net_1_2, net_1_3, net_1_4, net_1_5, net_1_6, net_1_7,
         net_1_8, net_1_9, net_1_10, net_1_11, net_1_12, net_1_13, net_1_14, net_1_15, net_1_16,
         net_1_18, net_1_19, net_1_20, net_1_21, net_1_22, net_1_23, net_1_25, net_1_26,
         net_1_27, net_1_28, net_1_29, net_1_30, net_1_31, net_1_32, net_1_33, net_1_34,
         net_1_35, net_1_36, net_1_37, net_1_38, net_1_39, net_1_40, net_1_41, net_1_42,
         net_1_43, net_1_44, net_1_45, net_1_46, net_1_47, net_1_48, net_1_49, net_1_50,
         net_1_51, net_1_52, net_1_53, net_1_54, net_1_55, net_1_56, net_1_57, net_1_58,
         net_1_59, net_1_60, net_1_61, net_1_62, net_1_63, net_1_64, net_1_65, net_1_66,
         net_1_67, net_1_68, net_1_69, net_1_70, net_1_71, net_1_72, net_1_73, net_1_74,
         net_1_75, net_1_76, net_1_77, net_1_78, net_1_79, net_1_80, net_1_81, net_1_82,
         net_1_83, net_1_84, net_1_85, net_1_86, net_1_87, net_1_88, net_1_89, net_1_90,
         net_1_91, net_1_92, net_1_93, net_1_94, net_1_95, net_1_96, net_1_97, net_1_98,
         net_1_99, net_1_100, net_1_101, net_1_102, net_1_103, net_1_104, net_1_105, net_1_106,
         net_1_107, net_1_108, net_1_109, net_1_110, net_1_111, net_1_112, net_1_113,
         net_1_114, net_1_115, net_1_116, net_1_117, net_1_118, net_1_119, net_1_120,
         net_1_121, net_1_122, net_1_123, net_1_124, net_1_125, net_1_126, net_1_127,
         net_1_128, net_1_129, net_1_130, net_1_131, net_1_135, net_1_137, net_1_138,
         net_1_139, net_1_140, net_1_141, net_1_142, net_1_143, net_1_144, net_1_145,
         net_1_146, net_1_147, net_1_148, net_1_149, net_1_150, net_1_151, net_1_152,
         net_1_153, net_1_154, net_1_155, net_1_156, net_1_157, net_1_158, net_1_159,
         net_1_160, net_1_161, net_1_162, net_1_163, net_1_164, net_1_165, net_1_166,
         net_1_167, net_1_168, net_1_169, net_1_170, net_1_171, net_1_172, net_1_173,
         net_1_174, net_1_175, net_1_176, net_1_177, net_1_178, net_1_179, net_1_180,
         net_1_181, net_1_182, net_1_183, net_1_184, net_1_185, net_1_186, net_1_187,
         net_1_188, net_1_189, net_1_190, net_1_191, net_1_192, net_1_193, net_1_194,
         net_1_195, net_1_196, net_1_197, net_1_198, net_1_199, net_1_200, net_1_201,
         net_1_202, net_1_203, net_1_204, net_1_205, net_1_206, net_1_207, net_1_208,
         net_1_209, net_1_210, net_1_211, net_1_212, net_1_213, net_1_214, net_1_215,
         net_1_216, net_1_217, net_1_218, net_1_219, net_1_220, net_1_221, net_1_222,
         net_1_223, net_1_224, net_1_225, net_1_226, net_1_227, net_1_228, net_1_229,
         net_1_230, net_1_231, net_1_232, net_1_233, net_1_234, net_1_235, net_1_236,
         net_1_237, net_1_238, net_1_239, net_1_240, net_1_241, net_1_242, net_1_243,
         net_1_244, net_1_245, net_1_246, net_1_247, net_1_248, net_1_249, net_1_250,
         net_1_251, net_1_252, net_1_253, net_1_254, net_1_255, net_1_256, net_1_257,
         net_1_258, net_1_259, net_1_260, net_1_261, net_1_262, net_1_263, net_1_264,
         net_1_265, net_1_266, net_1_267, net_1_268, net_1_269, net_1_270, net_1_271,
         net_1_272, net_1_273, net_1_274, net_1_275, net_1_276, net_1_277, net_1_278,
         net_1_279, net_1_280, net_1_281, net_1_282, net_1_283, net_1_284, net_1_285,
         net_1_286, net_1_287, net_1_288, net_1_289, net_1_290, net_1_291, net_1_292,
         net_1_293, net_1_294, net_1_295, net_1_296, net_1_297, net_1_298, net_1_299,
         net_1_300, net_1_301, net_1_302, net_1_303, net_1_304, net_1_305, net_1_306,
         net_1_307, net_1_308, net_1_309, net_1_310, net_1_311, net_1_312, net_1_313,
         net_1_314, net_1_315, net_1_316, net_1_317, net_1_318, net_1_319, net_1_320,
         net_1_321, net_1_322, net_1_323, net_1_324, net_1_325, net_1_326, net_1_327,
         net_1_328, net_1_329, net_1_330, net_1_331, net_1_332, net_1_333, net_1_334,
         net_1_335, net_1_336, net_1_337, net_1_338, net_1_339, net_1_340, net_1_341,
         net_1_342, net_1_343, net_1_344, net_1_345, net_1_346, net_1_347, net_1_348,
         net_1_349, net_1_350, net_1_351, net_1_352, net_1_353, net_1_354, net_1_355,
         net_1_356, net_1_357, net_1_358, net_1_359, net_1_360, net_1_361, net_1_362,
         net_1_363, net_1_364, net_1_365, net_1_366, net_1_367, net_1_368, net_1_369,
         net_1_370, net_1_371, net_1_372, net_1_373, net_1_374, net_1_375, net_1_376,
         net_1_377, net_1_378, net_1_379, net_1_380, net_1_381, net_1_382, net_1_383,
         net_1_384, net_1_385, net_1_386, net_1_387, net_1_388, net_1_389, net_1_390,
         net_1_391, net_1_392, net_1_393, net_1_394, net_1_395, net_1_396, net_1_397,
         net_1_398, net_1_399, net_1_400, net_1_401, net_1_402, net_1_403, net_1_404,
         net_1_405, net_1_406, net_1_407, net_1_408, net_1_409, net_1_410, net_1_411,
         net_1_412, net_1_413, net_1_414, net_1_415, net_1_416, net_1_417, net_1_418,
         net_1_419, net_1_420, net_1_421, net_1_422, net_1_423, net_1_424, net_1_425,
         net_1_426, net_1_427, net_1_428, net_1_429, net_1_430, net_1_431, net_1_432,
         net_1_433, net_1_434, net_1_435, net_1_436, net_1_437, net_1_438, net_1_439,
         net_1_440, net_1_441, net_1_442, net_1_443, net_1_444, net_1_445, net_1_446,
         net_1_447, net_1_448, net_1_449, net_1_450, net_1_451, net_1_452, net_1_453,
         net_1_454, net_1_455, net_1_456, net_1_457, net_1_458, net_1_459, net_1_460,
         net_1_461, net_1_462, net_1_463, net_1_464, net_1_465, net_1_466, net_1_467,
         net_1_468, net_1_469, net_1_470, net_1_471, net_1_472, net_1_473, net_1_474,
         net_1_475, net_1_476, net_1_477, net_1_478, net_1_479, net_1_480, net_1_481,
         net_1_482, net_1_483, net_1_484, net_1_485, net_1_486, net_1_487, net_1_488,
         net_1_489, net_1_490, net_1_491, net_1_492, net_1_493, net_1_494, net_1_495,
         net_1_496, net_1_497, net_1_498, net_1_499, net_1_500, net_1_501, net_1_502,
         net_1_503, net_1_504, net_1_505, net_1_506, net_1_507, net_1_508, net_1_509,
         net_1_510, net_1_511, net_1_512, net_1_513, net_1_514, net_1_515, net_1_516,
         net_1_517, net_1_518, net_1_519, net_1_520, net_1_521, net_1_522, net_1_523,
         net_1_524, net_1_525, net_1_526, net_1_527, net_1_528, net_1_529, net_1_530,
         net_1_531, net_1_532, net_1_533, net_1_534, net_1_535, net_1_536, net_1_537,
         net_1_538, net_1_539, net_1_540, net_1_541, net_1_542, net_1_543, net_1_544,
         net_1_545, net_1_546, net_1_547, net_1_548, net_1_549, net_1_550, net_1_551,
         net_1_552, net_1_553, net_1_554, net_1_555, net_1_556, net_1_557, net_1_558,
         net_1_559, net_1_560, net_1_561, net_1_562, net_1_563, net_1_564, net_1_565,
         net_1_566, net_1_567, net_1_568, net_1_569, net_1_570, net_1_571, net_1_572,
         net_1_573, net_1_574, net_1_575, net_1_576, net_1_577, net_1_578, net_1_579,
         net_1_580, net_1_581, net_1_582, net_1_583, net_1_584, net_1_585, net_1_586,
         net_1_587, net_1_588, net_1_589, net_1_590, net_1_591, net_1_592, net_1_593,
         net_1_594, net_1_595, net_1_596, net_1_597, net_1_598, net_1_599, net_1_600,
         net_1_601, net_1_602, net_1_603, net_1_604, net_1_605, net_1_606, net_1_607,
         net_1_608, net_1_609, net_1_610, net_1_611, net_1_612, net_1_613, net_1_614,
         net_1_615, net_1_616, net_1_617, net_1_618, net_1_619, net_1_620, net_1_621,
         net_1_622, net_1_623, net_1_624, net_1_625, net_1_626, net_1_627, net_1_628,
         net_1_629, net_1_630, net_1_631, net_1_632, net_1_633, net_1_634, net_1_635,
         net_1_636, net_1_637, net_1_638, net_1_639, net_1_640, net_1_641, net_1_642,
         net_1_643, net_1_644, net_1_645, net_1_646, net_1_647, net_1_648, net_1_649,
         net_1_650, net_1_651, net_1_652, net_1_653, net_1_654, net_1_655, net_1_656,
         net_1_657, net_1_658, net_1_659, net_1_660, net_1_661, net_1_662, net_1_663,
         net_1_664, net_1_665, net_1_666, net_1_667, net_1_668, net_1_669, net_1_670,
         net_1_671, net_1_672, net_1_673, net_1_674, net_1_675, net_1_676, net_1_677,
         net_1_678, net_1_679, net_1_680, net_1_681, net_1_682, net_1_683, net_1_684,
         net_1_685, net_1_686, net_1_687, net_1_688, net_1_689, net_1_690, net_1_691,
         net_1_692, net_1_693, net_1_694;

  assign instr0_need_late_ex1[3] = instr0_reads[3];
  assign instr0_need_early_iss[2] = 1'b0;
  assign instr0_need_early_iss[1] = 1'b0;
  assign net_1_1 = ~net_1_534;
  assign net_1_2 = ~iq_instr0_sideband_i[3];
  assign net_1_3 = ~iq_instr0_sideband_i[2];
  assign net_1_4 = ~iq_instr0_sideband_i[1];
  assign net_1_5 = ~net_1_298;
  assign net_1_6 = ~iq_instr0_is_dp_i;
  assign net_1_7 = ~net_1_402;
  assign net_1_8 = ~net_1_328;
  assign net_1_9 = ~iq_instr0_is_fn_i;
  assign net_1_10 = ~instr0_a32_only;
  assign net_1_11 = ~net_1_536;
  assign net_1_12 = ~instr0_a64_only;
  assign net_1_13 = ~net_1_473;
  assign net_1_14 = ~iq_instr0_i[28];
  assign net_1_15 = ~iq_instr0_i[27];
  assign net_1_16 = ~iq_instr0_i[25];
  assign net_1_18 = ~net_1_224;
  assign net_1_19 = ~iq_instr0_i[24];
  assign net_1_20 = ~iq_instr0_i[23];
  assign net_1_21 = ~iq_instr0_i[22];
  assign net_1_22 = ~iq_instr0_i[20];
  assign net_1_23 = ~iq_instr0_i[6];
  assign str_valid_instr0 = ~(net_1_25 & net_1_26);
  assign net_1_26 = (net_1_27 & net_1_28);
  assign net_1_28 = ~(net_1_29 & net_1_30);
  assign net_1_27 = (net_1_31 & net_1_32);
  assign net_1_32 = ~(net_1_33 | net_1_34);
  assign net_1_25 = ~(net_1_35 | net_1_36);
  assign net_1_36 = ~(net_1_37 & net_1_38);
  assign net_1_38 = (net_1_39 & net_1_40);
  assign net_1_37 = (net_1_41 | net_1_42);
  assign net_1_41 = ~(net_1_43 | net_1_44);
  assign net_1_44 = ~(iq_instr0_i[11] | net_1_20);
  assign net_1_43 = ~(iq_instr0_i[21] | net_1_45);
  assign net_1_45 = ~(iq_instr0_i[23] | iq_instr0_i[9]);
  assign str1_valid_instr0 = ~(net_1_46 & net_1_47);
  assign net_1_47 = (net_1_48 & net_1_49);
  assign net_1_49 = ~(net_1_50 & net_1_51);
  assign net_1_51 = ~(net_1_52 & net_1_53);
  assign net_1_53 = (net_1_54 | net_1_55);
  assign net_1_54 = ~(net_1_56 & instr0_sf_bit);
  assign net_1_52 = (net_1_57 | net_1_16);
  assign net_1_57 = ~(iq_instr0_i[26] & net_1_30);
  assign net_1_48 = (net_1_39 & net_1_58);
  assign net_1_58 = (net_1_59 & net_1_60);
  assign net_1_60 = (iq_instr0_i[11] | net_1_61);
  assign net_1_61 = (net_1_62 | net_1_19);
  assign net_1_62 = (net_1_12 | net_1_42);
  assign net_1_59 = (net_1_63 | net_1_64);
  assign net_1_64 = ~(net_1_65 & net_1_66);
  assign net_1_66 = ~(iq_instr0_i[21] | net_1_67);
  assign net_1_67 = ~(iq_instr0_i[8] & net_1_68);
  assign net_1_68 = (iq_instr0_i[11] & net_1_12);
  assign net_1_39 = ~(net_1_29 & net_1_69);
  assign net_1_69 = (net_1_70 & net_1_71);
  assign net_1_71 = ~(net_1_72 & net_1_73);
  assign net_1_73 = ~(iq_instr0_i[28] & net_1_74);
  assign net_1_74 = ~(iq_instr0_i[10] | net_1_75);
  assign net_1_72 = (net_1_76 | iq_instr0_i[11]);
  assign net_1_76 = ~(instr0_sf_bit & net_1_12);
  assign instr0_w0_enabled = (net_1_77 | net_1_78);
  assign net_1_78 = (net_1_79 | net_1_80);
  assign net_1_80 = (net_1_81 | instr0_3_0_written);
  assign net_1_79 = (net_1_82 & net_1_83);
  assign net_1_83 = (net_1_84 & net_1_20);
  assign net_1_82 = (net_1_85 & net_1_22);
  assign net_1_77 = ~(net_1_86 & net_1_87);
  assign net_1_87 = (net_1_88 | net_1_89);
  assign net_1_89 = ~(iq_instr0_i[28] & net_1_90);
  assign net_1_88 = ~(net_1_91 | net_1_92);
  assign net_1_92 = (iq_instr0_i[21] & net_1_93);
  assign net_1_93 = ~(net_1_94 | iq_instr0_i[6]);
  assign net_1_91 = (net_1_95 & net_1_96);
  assign net_1_96 = ~(net_1_6 | net_1_21);
  assign net_1_95 = (net_1_70 & iq_instr0_i[27]);
  assign instr0_skewable = (net_1_97 | net_1_98);
  assign net_1_98 = (net_1_99 | net_1_100);
  assign net_1_100 = (net_1_101 | net_1_102);
  assign net_1_102 = ~(net_1_103 & net_1_104);
  assign net_1_99 = (net_1_105 & net_1_106);
  assign net_1_106 = ~(net_1_107 & net_1_108);
  assign net_1_108 = ~(iq_instr0_sideband_i[2] & net_1_109);
  assign instr0_skew_r1 = ~(net_1_110 & net_1_111);
  assign net_1_111 = (net_1_112 & net_1_113);
  assign net_1_113 = ~(iq_instr0_i[5] & net_1_114);
  assign net_1_114 = ~(net_1_23 | net_1_115);
  assign net_1_110 = ~(net_1_97 | net_1_116);
  assign net_1_116 = ~(net_1_117 & net_1_118);
  assign instr0_skew_r0 = (net_1_119 | net_1_120);
  assign net_1_120 = ~(net_1_103 & net_1_121);
  assign net_1_121 = ~(net_1_122 & net_1_123);
  assign net_1_103 = (net_1_124 & net_1_125);
  assign net_1_124 = (net_1_112 & net_1_126);
  assign net_1_126 = (net_1_127 | net_1_6);
  assign net_1_127 = (net_1_128 & net_1_129);
  assign net_1_129 = (net_1_130 | net_1_131);
  assign net_1_130 = ~(iq_instr0_i[24] & net_1_56);
  assign instr0_sets_ccflags = (net_1_138 | net_1_139);
  assign net_1_139 = ~(net_1_140 & net_1_141);
  assign net_1_141 = (net_1_142 | net_1_6);
  assign net_1_140 = ~(net_1_143 | net_1_144);
  assign net_1_144 = (net_1_145 | net_1_146);
  assign net_1_146 = ~(net_1_75 | net_1_147);
  assign net_1_147 = (net_1_11 | net_1_148);
  assign net_1_148 = (net_1_149 | net_1_150);
  assign net_1_150 = ~(iq_instr0_i[5] & iq_instr0_i[28]);
  assign net_1_145 = (net_1_2 & net_1_151);
  assign net_1_151 = (net_1_152 & instr0_a64_only);
  assign net_1_143 = ~(iq_instr0_i[8] | net_1_153);
  assign net_1_153 = ~(net_1_154 & net_1_155);
  assign net_1_155 = (iq_instr0_i[22] & net_1_156);
  assign net_1_138 = (iq_instr0_i[20] & net_1_157);
  assign net_1_157 = (net_1_158 | net_1_159);
  assign net_1_158 = (net_1_160 | net_1_161);
  assign net_1_161 = ~(iq_instr0_i[4] | net_1_162);
  assign net_1_162 = ~(net_1_163 | net_1_164);
  assign net_1_164 = (net_1_165 & net_1_14);
  assign net_1_165 = (net_1_166 & net_1_167);
  assign net_1_167 = ~(net_1_168 | net_1_169);
  assign net_1_169 = ~(net_1_65 & net_1_170);
  assign net_1_170 = (iq_instr0_i[18] & net_1_156);
  assign net_1_65 = (iq_instr0_i[6] & iq_instr0_aarch64_i);
  assign net_1_166 = ~(iq_instr0_i[19] | iq_instr0_i[17]);
  assign net_1_163 = ~(iq_instr0_is_ot_i | net_1_171);
  assign net_1_171 = (net_1_172 | net_1_19);
  assign net_1_172 = (net_1_173 & net_1_174);
  assign net_1_174 = (net_1_175 | net_1_20);
  assign net_1_173 = (instr0_a64_only | net_1_176);
  assign net_1_176 = (iq_instr0_i[21] | net_1_177);
  assign net_1_177 = (net_1_178 | net_1_10);
  assign net_1_178 = (iq_instr0_i[26] | iq_instr0_i[22]);
  assign net_1_160 = (iq_instr0_is_dp_i & net_1_179);
  assign net_1_179 = (net_1_180 | net_1_14);
  assign net_1_180 = ~(net_1_131 & net_1_181);
  assign net_1_181 = ~(net_1_135 & net_1_182);
  assign net_1_182 = (iq_instr0_i[14] & net_1_20);
  assign instr0_reads[2] = (instr0_need_late_ex1[2] | net_1_183);
  assign instr0_reads[1] = (net_1_184 | net_1_185);
  assign net_1_185 = (net_1_186 | net_1_34);
  assign net_1_34 = ~(net_1_187 & net_1_188);
  assign net_1_187 = ~(net_1_189 | net_1_190);
  assign net_1_190 = (net_1_191 & net_1_22);
  assign instr0_reads[0] = (net_1_192 | instr0_need_late_ex1[0]);
  assign instr0_r2_enabled = ~(net_1_193 & net_1_194);
  assign net_1_193 = ~(net_1_186 | net_1_195);
  assign net_1_195 = (net_1_192 | net_1_196);
  assign net_1_196 = (net_1_183 | net_1_197);
  assign net_1_197 = ~(net_1_198 & net_1_199);
  assign net_1_198 = (net_1_200 & net_1_201);
  assign net_1_201 = (net_1_168 | net_1_202);
  assign net_1_202 = (iq_instr0_i[26] | net_1_203);
  assign net_1_203 = (net_1_204 | net_1_205);
  assign net_1_183 = ~(net_1_206 & net_1_188);
  assign net_1_188 = ~(net_1_207 & net_1_4);
  assign net_1_207 = ~(iq_instr0_sideband_i[2] | net_1_208);
  assign net_1_192 = (net_1_209 & net_1_22);
  assign instr0_need_late_iss[3] = (net_1_210 | net_1_211);
  assign net_1_211 = (net_1_212 | net_1_213);
  assign net_1_213 = (net_1_214 | net_1_215);
  assign net_1_214 = (net_1_216 & net_1_217);
  assign net_1_217 = ~(net_1_218 & net_1_219);
  assign net_1_219 = ~(net_1_220 & iq_instr0_i[27]);
  assign net_1_220 = (net_1_221 & net_1_222);
  assign net_1_222 = (net_1_21 & iq_instr0_i[20]);
  assign net_1_218 = ~(net_1_223 & net_1_224);
  assign net_1_223 = (net_1_225 & instr0_sf_bit);
  assign net_1_212 = (net_1_226 | net_1_227);
  assign net_1_227 = (net_1_228 | net_1_229);
  assign net_1_229 = (net_1_230 | net_1_231);
  assign net_1_230 = (net_1_232 | net_1_233);
  assign net_1_233 = (net_1_234 | net_1_235);
  assign net_1_235 = (net_1_236 | net_1_237);
  assign net_1_232 = (net_1_238 & net_1_239);
  assign net_1_239 = (iq_instr0_i[6] & iq_instr0_i[5]);
  assign net_1_238 = (net_1_240 & iq_instr0_i[24]);
  assign net_1_210 = (net_1_241 & net_1_242);
  assign net_1_242 = ~(net_1_20 | net_1_21);
  assign net_1_241 = ~(net_1_243 & net_1_244);
  assign net_1_244 = ~(net_1_245 & iq_instr0_i[21]);
  assign net_1_243 = (net_1_246 | iq_instr0_i[5]);
  assign instr0_need_late_iss[0] = (instr0_need_early_iss[0] | net_1_247);
  assign net_1_247 = (net_1_248 | net_1_249);
  assign net_1_249 = ~(net_1_250 & net_1_251);
  assign net_1_251 = (net_1_252 | iq_instr0_i[15]);
  assign net_1_252 = (iq_instr0_i[26] | net_1_253);
  assign net_1_253 = (net_1_254 | net_1_255);
  assign net_1_255 = (net_1_256 | net_1_19);
  assign net_1_254 = (net_1_257 | net_1_16);
  assign net_1_257 = (net_1_10 & net_1_258);
  assign net_1_258 = (instr0_a64_only | instr0_shf_imm_field_zero);
  assign net_1_248 = ~(iq_instr0_is_ot_i | net_1_259);
  assign net_1_259 = ~(iq_instr0_i[28] & net_1_260);
  assign net_1_260 = (net_1_261 | net_1_262);
  assign net_1_262 = ~(iq_instr0_i[27] | net_1_263);
  assign net_1_263 = ~(iq_instr0_i[22] & net_1_264);
  assign net_1_264 = ~(iq_instr0_sideband_i[0] | iq_instr0_is_ls_i);
  assign net_1_261 = (net_1_265 & net_1_266);
  assign net_1_266 = (iq_instr0_i[7] & iq_instr0_i[23]);
  assign net_1_265 = (net_1_267 & net_1_21);
  assign instr0_reads[3] = (net_1_268 | net_1_269);
  assign net_1_269 = ~(net_1_270 & net_1_271);
  assign net_1_271 = ~(net_1_245 | net_1_231);
  assign net_1_231 = ~(net_1_272 & net_1_273);
  assign net_1_272 = (net_1_274 & net_1_275);
  assign net_1_275 = ~(iq_instr0_i[25] & net_1_276);
  assign net_1_276 = ~(net_1_277 & net_1_278);
  assign net_1_278 = (net_1_279 & net_1_280);
  assign net_1_277 = (net_1_281 & net_1_282);
  assign net_1_282 = (instr0_a64_only | net_1_283);
  assign net_1_283 = (net_1_284 & net_1_285);
  assign net_1_285 = ~(net_1_286 & net_1_287);
  assign net_1_286 = ~(net_1_22 | instr0_cc_never);
  assign net_1_274 = (net_1_288 & net_1_289);
  assign net_1_289 = ~(div_valid_instr0 | net_1_290);
  assign net_1_290 = ~(net_1_194 & net_1_291);
  assign net_1_291 = (net_1_292 | net_1_5);
  assign net_1_194 = ~(iq_instr0_sideband_i[1] & net_1_293);
  assign net_1_293 = (net_1_294 | net_1_295);
  assign net_1_294 = ~(iq_instr0_i[4] | net_1_296);
  assign net_1_296 = ~(net_1_191 & net_1_297);
  assign net_1_245 = ~(net_1_19 | net_1_5);
  assign net_1_270 = (net_1_246 & net_1_299);
  assign net_1_299 = ~(net_1_298 & iq_instr0_i[20]);
  assign net_1_268 = (net_1_300 | net_1_301);
  assign net_1_301 = (net_1_302 | net_1_303);
  assign net_1_303 = ~(net_1_304 & net_1_305);
  assign net_1_304 = (net_1_200 & net_1_306);
  assign net_1_306 = (iq_instr0_i[26] | net_1_307);
  assign net_1_307 = (net_1_308 | net_1_256);
  assign net_1_200 = (iq_instr0_is_ot_i | net_1_309);
  assign net_1_309 = (iq_instr0_sideband_i[0] | net_1_310);
  assign net_1_310 = (iq_instr0_is_fn_i | net_1_311);
  assign net_1_311 = (net_1_312 | iq_instr0_i[20]);
  assign net_1_302 = ~(net_1_313 & net_1_314);
  assign net_1_314 = ~(net_1_315 & iq_instr0_is_dp_i);
  assign net_1_313 = (net_1_117 & net_1_316);
  assign net_1_300 = (net_1_122 & net_1_317);
  assign net_1_317 = (net_1_318 | net_1_319);
  assign net_1_319 = (net_1_320 & iq_instr0_i[22]);
  assign instr0_need_late_ex1[1] = (net_1_184 | instr0_need_late_iss[1]);
  assign instr0_need_late_iss[1] = (net_1_186 | net_1_321);
  assign net_1_321 = (net_1_322 | net_1_323);
  assign net_1_323 = ~(net_1_324 | net_1_325);
  assign net_1_325 = ~(net_1_267 & net_1_326);
  assign net_1_326 = (iq_instr0_i[26] & net_1_4);
  assign net_1_267 = ~(net_1_168 | net_1_327);
  assign net_1_322 = (iq_instr0_i[21] & net_1_189);
  assign net_1_189 = ~(net_1_328 | net_1_327);
  assign net_1_186 = ~(net_1_329 & net_1_330);
  assign net_1_330 = (net_1_331 | iq_instr0_i[28]);
  assign net_1_329 = ~(net_1_33 | net_1_228);
  assign net_1_33 = (net_1_332 & net_1_23);
  assign instr0_need_late_ex1[0] = (net_1_333 | net_1_334);
  assign net_1_334 = (net_1_335 | instr0_need_early_iss[0]);
  assign net_1_335 = (iq_instr0_is_dp_i & net_1_336);
  assign net_1_333 = (net_1_337 | net_1_338);
  assign net_1_338 = (net_1_339 | net_1_340);
  assign net_1_340 = ~(net_1_341 & net_1_316);
  assign net_1_337 = (net_1_226 | net_1_119);
  assign net_1_119 = ~(iq_instr0_i[22] | net_1_342);
  assign net_1_342 = ~(net_1_122 & net_1_343);
  assign net_1_343 = ~(net_1_344 & net_1_345);
  assign net_1_345 = ~(net_1_156 & net_1_22);
  assign net_1_344 = (instr0_11_8_is_pc | iq_instr0_i[24]);
  assign net_1_226 = (net_1_346 & net_1_320);
  assign instr0_need_early_iss[3] = ~(net_1_347 & net_1_288);
  assign net_1_288 = ~(iq_instr0_i[27] & net_1_348);
  assign net_1_348 = ~(net_1_349 & net_1_350);
  assign net_1_350 = (net_1_204 | net_1_351);
  assign net_1_351 = (net_1_352 & net_1_353);
  assign net_1_353 = (iq_instr0_i[26] | net_1_284);
  assign net_1_352 = (net_1_354 & net_1_355);
  assign net_1_355 = (net_1_12 | net_1_75);
  assign net_1_354 = (iq_instr0_i[24] | iq_instr0_is_ls_i);
  assign net_1_204 = (iq_instr0_i[25] | iq_instr0_i[11]);
  assign net_1_347 = ~(net_1_215 | net_1_356);
  assign net_1_356 = ~(net_1_357 & net_1_358);
  assign net_1_358 = (net_1_280 | net_1_16);
  assign net_1_280 = ~(iq_instr0_i[23] & net_1_359);
  assign net_1_359 = (net_1_360 & instr0_agu_can_shift);
  assign net_1_357 = ~(net_1_361 & net_1_362);
  assign net_1_362 = (iq_instr0_i[23] & iq_instr0_is_ls_i);
  assign net_1_361 = (net_1_297 & iq_instr0_sideband_i[3]);
  assign net_1_297 = ~(iq_instr0_sideband_i[0] | net_1_75);
  assign net_1_215 = (iq_instr0_sideband_i[2] & net_1_363);
  assign net_1_363 = (net_1_364 | net_1_365);
  assign net_1_365 = (iq_instr0_i[4] & net_1_366);
  assign net_1_366 = (net_1_367 | net_1_368);
  assign net_1_368 = (iq_instr0_i[24] & net_1_369);
  assign net_1_369 = (iq_instr0_sideband_i[4] & iq_instr0_i[23]);
  assign net_1_367 = ~(iq_instr0_i[5] | net_1_370);
  assign net_1_370 = (iq_instr0_sideband_i[1] | net_1_371);
  assign net_1_371 = ~(iq_instr0_i[21] & net_1_15);
  assign net_1_364 = (net_1_105 & net_1_109);
  assign net_1_109 = (net_1_23 & iq_instr0_sideband_i[3]);
  assign net_1_105 = (net_1_372 & net_1_16);
  assign net_1_372 = (instr0_a32_only & iq_instr0_i[21]);
  assign instr0_need_early_iss[0] = (net_1_373 | net_1_374);
  assign net_1_374 = (net_1_35 | net_1_375);
  assign net_1_375 = (net_1_376 | net_1_377);
  assign net_1_377 = ~(net_1_378 & net_1_379);
  assign net_1_379 = (net_1_380 & net_1_381);
  assign net_1_381 = (net_1_382 | net_1_383);
  assign net_1_380 = (net_1_384 & net_1_385);
  assign net_1_385 = (net_1_386 & net_1_387);
  assign net_1_387 = (net_1_20 | net_1_388);
  assign net_1_386 = (net_1_46 & net_1_389);
  assign net_1_46 = ~(net_1_390 & net_1_30);
  assign net_1_30 = ~(net_1_12 | iq_instr0_i[20]);
  assign net_1_390 = ~(net_1_391 & net_1_392);
  assign net_1_392 = (net_1_393 | iq_instr0_i[28]);
  assign net_1_391 = (net_1_394 | net_1_19);
  assign net_1_384 = (net_1_395 & net_1_396);
  assign net_1_396 = (net_1_397 | net_1_398);
  assign net_1_398 = ~(iq_instr0_i[28] & iq_instr0_sideband_i[4]);
  assign net_1_395 = (net_1_399 & net_1_400);
  assign net_1_400 = (instr0_19_16_is_pc | net_1_401);
  assign net_1_401 = ~(iq_instr0_i[24] & net_1_402);
  assign net_1_378 = (net_1_403 & net_1_404);
  assign net_1_404 = (net_1_349 | net_1_15);
  assign net_1_349 = (iq_instr0_is_fn_i | net_1_405);
  assign net_1_405 = ~(iq_instr0_sideband_i[3] & net_1_406);
  assign net_1_406 = (net_1_4 & net_1_6);
  assign net_1_35 = (net_1_29 & net_1_152);
  assign net_1_152 = ~(iq_instr0_i[23] | net_1_168);
  assign net_1_29 = ~(net_1_2 | net_1_9);
  assign net_1_373 = (net_1_16 & net_1_407);
  assign net_1_407 = (net_1_408 | net_1_409);
  assign net_1_409 = (net_1_410 | net_1_411);
  assign net_1_411 = (iq_instr0_is_fn_i & net_1_412);
  assign net_1_412 = ~(iq_instr0_i[9] | net_1_413);
  assign net_1_410 = ~(iq_instr0_is_ls_i | net_1_414);
  assign net_1_414 = (net_1_168 | iq_instr0_i[11]);
  assign net_1_408 = (net_1_415 | net_1_416);
  assign net_1_416 = (net_1_22 & net_1_417);
  assign net_1_417 = (net_1_418 | net_1_419);
  assign net_1_419 = (instr0_a64_only & net_1_420);
  assign net_1_420 = (iq_instr0_sideband_i[4] & net_1_20);
  assign net_1_418 = (iq_instr0_i[6] & net_1_135);
  assign net_1_135 = ~(iq_instr0_i[7] | net_1_168);
  assign net_1_415 = (net_1_421 & net_1_422);
  assign net_1_422 = ~(iq_instr0_i[28] | instr0_19_16_is_pc);
  assign instr0_lr_written = ~(net_1_423 & net_1_424);
  assign net_1_424 = ~(iq_instr0_i[27] & iq_instr0_is_ot_i);
  assign net_1_423 = (net_1_425 | net_1_426);
  assign net_1_426 = (instr0_a64_only | net_1_427);
  assign net_1_427 = ~(iq_instr0_i[15] & iq_instr0_i[14]);
  assign instr0_can_adrp_forward = (net_1_428 | net_1_429);
  assign net_1_429 = ~(net_1_388 & net_1_430);
  assign net_1_430 = ~(net_1_431 & net_1_432);
  assign net_1_432 = ~(iq_instr0_is_fn_i | net_1_413);
  assign net_1_388 = (net_1_175 | net_1_9);
  assign net_1_428 = ~(iq_instr0_i[23] | net_1_433);
  assign net_1_433 = (net_1_63 | net_1_16);
  assign instr0_3_0_written = ~(net_1_434 & net_1_206);
  assign net_1_206 = (iq_instr0_sideband_i[3] | net_1_435);
  assign net_1_435 = (iq_instr0_i[21] | net_1_436);
  assign net_1_436 = (net_1_55 | net_1_327);
  assign net_1_327 = ~(iq_instr0_i[4] & net_1_22);
  assign net_1_55 = (net_1_168 | net_1_437);
  assign net_1_437 = ~(iq_instr0_i[5] & iq_instr0_is_ls_i);
  assign net_1_434 = (net_1_13 | net_1_438);
  assign net_1_438 = (net_1_397 | net_1_439);
  assign net_1_439 = (net_1_23 | net_1_20);
  assign instr0_19_16_written = ~(net_1_389 & net_1_440);
  assign net_1_440 = ~(net_1_101 | net_1_441);
  assign net_1_441 = ~(net_1_316 & net_1_31);
  assign net_1_316 = ~(iq_instr0_i[28] & net_1_442);
  assign net_1_442 = (net_1_443 & net_1_12);
  assign net_1_101 = ~(net_1_399 & net_1_444);
  assign net_1_444 = (net_1_445 & net_1_446);
  assign net_1_446 = ~(net_1_447 & iq_instr0_i[21]);
  assign net_1_447 = ~(net_1_383 | net_1_448);
  assign net_1_448 = (net_1_382 & net_1_449);
  assign net_1_449 = (net_1_393 | iq_instr0_i[20]);
  assign net_1_393 = ~(iq_instr0_i[26] & iq_instr0_i[23]);
  assign net_1_382 = (iq_instr0_i[4] | iq_instr0_i[23]);
  assign net_1_383 = (net_1_9 | iq_instr0_i[27]);
  assign net_1_445 = ~(net_1_450 | net_1_451);
  assign net_1_451 = (iq_instr0_i[8] & net_1_452);
  assign net_1_452 = (net_1_453 | net_1_454);
  assign net_1_454 = (net_1_443 & instr0_a64_only);
  assign net_1_443 = ~(iq_instr0_sideband_i[1] | net_1_42);
  assign net_1_42 = ~(net_1_431 & net_1_22);
  assign net_1_453 = (iq_instr0_i[28] & net_1_455);
  assign net_1_455 = (net_1_456 | net_1_457);
  assign net_1_457 = (net_1_458 & net_1_16);
  assign net_1_458 = ~(iq_instr0_i[24] | net_1_63);
  assign net_1_456 = (net_1_459 & net_1_3);
  assign net_1_450 = ~(net_1_117 & net_1_460);
  assign net_1_460 = ~(instr0_3_0_is_sp & net_1_461);
  assign net_1_461 = ~(net_1_75 | net_1_397);
  assign net_1_397 = (net_1_394 | net_1_4);
  assign net_1_75 = (iq_instr0_i[20] | net_1_19);
  assign net_1_117 = (instr0_3_0_is_sp | net_1_462);
  assign net_1_462 = ~(iq_instr0_sideband_i[1] & net_1_463);
  assign net_1_463 = ~(instr0_3_0_is_pc | net_1_63);
  assign net_1_63 = (iq_instr0_i[26] | net_1_9);
  assign net_1_399 = (net_1_118 & net_1_464);
  assign net_1_464 = ~(net_1_465 & net_1_402);
  assign net_1_118 = (iq_instr0_i[21] | net_1_115);
  assign net_1_115 = (iq_instr0_i[22] | net_1_466);
  assign net_1_466 = ~(net_1_240 & net_1_19);
  assign net_1_240 = ~(iq_instr0_i[26] | net_1_7);
  assign net_1_389 = (net_1_467 & net_1_468);
  assign net_1_468 = (net_1_107 | net_1_469);
  assign net_1_467 = (net_1_199 & net_1_470);
  assign net_1_470 = ~(iq_instr0_i[21] & net_1_471);
  assign net_1_471 = ~(net_1_7 & net_1_472);
  assign net_1_472 = (net_1_13 | net_1_208);
  assign net_1_208 = ~(iq_instr0_sideband_i[4] & net_1_9);
  assign net_1_199 = (net_1_284 | net_1_11);
  assign net_1_284 = (iq_instr0_i[24] | net_1_205);
  assign net_1_205 = (iq_instr0_sideband_i[0] | net_1_474);
  assign net_1_474 = ~(iq_instr0_sideband_i[3] & iq_instr0_sideband_i[4]);
  assign instr0_15_12_written = ~(net_1_475 & net_1_476);
  assign net_1_476 = ~(net_1_50 & net_1_477);
  assign net_1_477 = ~(net_1_168 | net_1_478);
  assign net_1_478 = (net_1_479 & net_1_480);
  assign net_1_480 = ~(iq_instr0_aarch64_i & net_1_481);
  assign net_1_481 = (iq_instr0_i[25] & net_1_3);
  assign net_1_479 = ~(net_1_482 & iq_instr0_i[8]);
  assign net_1_482 = (iq_instr0_i[26] & iq_instr0_i[20]);
  assign net_1_50 = (iq_instr0_i[4] & net_1_14);
  assign net_1_475 = (net_1_86 & net_1_483);
  assign net_1_483 = (net_1_22 | net_1_40);
  assign net_1_40 = ~(net_1_70 & net_1_484);
  assign net_1_484 = (net_1_154 & net_1_324);
  assign net_1_324 = ~(iq_instr0_i[22] | iq_instr0_i[8]);
  assign net_1_154 = (iq_instr0_i[4] & net_1_8);
  assign net_1_86 = (net_1_485 & net_1_486);
  assign net_1_486 = ~(iq_instr0_is_ls_i & net_1_487);
  assign net_1_487 = ~(iq_instr0_i[26] | net_1_488);
  assign net_1_488 = (net_1_489 & net_1_490);
  assign net_1_490 = (net_1_425 | iq_instr0_i[25]);
  assign net_1_425 = (iq_instr0_i[27] | instr0_a32_only);
  assign net_1_489 = (net_1_469 & net_1_491);
  assign net_1_491 = (net_1_492 | net_1_22);
  assign net_1_492 = (net_1_18 & net_1_493);
  assign net_1_493 = (iq_instr0_i[22] | net_1_494);
  assign net_1_494 = (net_1_495 & net_1_496);
  assign net_1_496 = (net_1_497 | iq_instr0_sideband_i[2]);
  assign net_1_497 = ~(iq_instr0_i[9] & net_1_20);
  assign net_1_495 = ~(net_1_15 & net_1_12);
  assign net_1_469 = (net_1_16 | iq_instr0_i[24]);
  assign net_1_485 = (net_1_498 & net_1_499);
  assign net_1_499 = (net_1_500 & net_1_104);
  assign net_1_104 = ~(iq_instr0_i[21] & net_1_501);
  assign net_1_501 = (iq_instr0_i[20] & net_1_502);
  assign net_1_502 = (net_1_3 & net_1_402);
  assign net_1_402 = (instr0_a32_only & iq_instr0_is_ls_i);
  assign net_1_500 = ~(net_1_503 | net_1_504);
  assign net_1_504 = (iq_instr0_i[26] & net_1_505);
  assign net_1_505 = ~(net_1_308 | instr0_cc_never);
  assign net_1_308 = ~(iq_instr0_i[20] & net_1_191);
  assign net_1_191 = (iq_instr0_is_ls_i & net_1_12);
  assign net_1_503 = ~(iq_instr0_i[22] | net_1_506);
  assign net_1_506 = (instr0_15_12_is_pc | net_1_507);
  assign net_1_507 = ~(net_1_431 & net_1_508);
  assign net_1_498 = (net_1_509 & net_1_1);
  assign net_1_509 = ~(net_1_376 | net_1_510);
  assign net_1_510 = ~(net_1_511 & net_1_512);
  assign net_1_512 = (net_1_16 | net_1_279);
  assign net_1_279 = (net_1_513 & net_1_514);
  assign net_1_514 = ~(iq_instr0_i[21] & net_1_360);
  assign net_1_360 = (net_1_508 & net_1_287);
  assign net_1_287 = ~(iq_instr0_i[27] | net_1_515);
  assign net_1_515 = (net_1_10 | net_1_19);
  assign net_1_513 = (net_1_107 | iq_instr0_i[24]);
  assign net_1_107 = ~(iq_instr0_sideband_i[0] & iq_instr0_is_ls_i);
  assign net_1_511 = (net_1_31 & net_1_516);
  assign net_1_516 = (net_1_137 | net_1_517);
  assign net_1_517 = (net_1_94 | net_1_19);
  assign net_1_94 = ~(net_1_518 & net_1_21);
  assign net_1_137 = (iq_instr0_i[4] | net_1_413);
  assign net_1_31 = ~(iq_instr0_i[20] & net_1_209);
  assign net_1_209 = ~(net_1_328 | iq_instr0_i[25]);
  assign net_1_328 = ~(net_1_519 & net_1_19);
  assign net_1_519 = ~(net_1_9 | instr0_a64_only);
  assign net_1_376 = ~(iq_instr0_i[26] | net_1_520);
  assign net_1_520 = (iq_instr0_i[21] | net_1_521);
  assign net_1_521 = ~(net_1_508 & net_1_522);
  assign net_1_522 = (iq_instr0_i[22] & iq_instr0_sideband_i[4]);
  assign instr0_11_8_written = (net_1_523 | net_1_524);
  assign net_1_524 = (net_1_234 | net_1_525);
  assign net_1_525 = ~(net_1_341 & net_1_526);
  assign net_1_526 = (net_1_527 & net_1_528);
  assign net_1_528 = ~(net_1_529 & net_1_4);
  assign net_1_527 = ~(instr0_need_late_ex1[2] | net_1_530);
  assign instr0_need_late_ex1[2] = (net_1_531 | instr0_need_late_iss[2]);
  assign instr0_need_late_iss[2] = ~(net_1_1 & net_1_532);
  assign net_1_532 = ~(net_1_85 & net_1_533);
  assign net_1_531 = (net_1_533 & net_1_535);
  assign net_1_533 = (net_1_536 & net_1_529);
  assign net_1_529 = ~(net_1_6 | iq_instr0_i[27]);
  assign net_1_341 = (net_1_250 & net_1_537);
  assign net_1_537 = ~(net_1_538 & net_1_539);
  assign net_1_539 = (net_1_540 & net_1_541);
  assign net_1_541 = ~(iq_instr0_i[14] | net_1_11);
  assign net_1_250 = ~(div_valid_instr0 | net_1_542);
  assign net_1_542 = (net_1_236 | net_1_543);
  assign net_1_543 = (net_1_544 | net_1_545);
  assign net_1_544 = (net_1_295 & iq_instr0_sideband_i[1]);
  assign net_1_295 = ~(iq_instr0_sideband_i[3] | net_1_546);
  assign net_1_546 = ~(iq_instr0_is_dp_i & net_1_465);
  assign net_1_465 = (net_1_19 & net_1_3);
  assign net_1_236 = (iq_instr0_i[22] & net_1_547);
  assign net_1_547 = (net_1_221 & net_1_548);
  assign net_1_234 = ~(iq_instr0_i[22] | net_1_549);
  assign net_1_549 = ~(net_1_550 & net_1_551);
  assign net_1_551 = ~(iq_instr0_i[21] ^ net_1_20);
  assign net_1_550 = (iq_instr0_is_dp_i & net_1_421);
  assign net_1_523 = ~(net_1_552 & net_1_553);
  assign net_1_553 = (net_1_6 | net_1_554);
  assign net_1_552 = ~(net_1_555 | net_1_556);
  assign net_1_556 = (net_1_81 | net_1_557);
  assign net_1_557 = (net_1_558 | net_1_97);
  assign net_1_97 = (net_1_122 & net_1_559);
  assign net_1_559 = (net_1_560 | net_1_123);
  assign net_1_123 = (net_1_561 | net_1_562);
  assign net_1_562 = (net_1_224 & net_1_320);
  assign net_1_561 = (net_1_563 & net_1_564);
  assign net_1_564 = ~(iq_instr0_i[23] ^ iq_instr0_i[21]);
  assign net_1_560 = (net_1_19 & net_1_565);
  assign net_1_565 = (net_1_318 | iq_instr0_i[21]);
  assign net_1_122 = (net_1_298 & net_1_566);
  assign net_1_298 = ~(net_1_6 | iq_instr0_i[28]);
  assign net_1_558 = (net_1_473 & net_1_518);
  assign net_1_518 = (net_1_540 & iq_instr0_i[25]);
  assign net_1_81 = ~(net_1_403 & net_1_567);
  assign net_1_567 = (net_1_22 | net_1_568);
  assign net_1_568 = ~(iq_instr0_sideband_i[4] & net_1_569);
  assign net_1_569 = ~(iq_instr0_sideband_i[5] | net_1_12);
  assign net_1_403 = ~(iq_instr0_sideband_i[1] & net_1_570);
  assign net_1_570 = (net_1_473 & net_1_459);
  assign net_1_459 = (iq_instr0_i[27] & net_1_571);
  assign net_1_571 = (iq_instr0_is_ls_i & net_1_20);
  assign net_1_473 = ~(iq_instr0_i[28] | iq_instr0_i[20]);
  assign net_1_555 = ~(net_1_572 & net_1_573);
  assign net_1_573 = ~(net_1_159 & iq_instr0_i[20]);
  assign net_1_159 = (net_1_536 & net_1_574);
  assign net_1_574 = ~(net_1_256 | net_1_575);
  assign net_1_572 = (net_1_273 & net_1_246);
  assign net_1_273 = (iq_instr0_i[28] | net_1_576);
  assign net_1_576 = (net_1_577 & net_1_578);
  assign net_1_578 = (net_1_579 | net_1_18);
  assign net_1_579 = (iq_instr0_i[21] | net_1_580);
  assign net_1_580 = (net_1_581 | net_1_582);
  assign net_1_582 = ~(instr0_19_16_is_pc & iq_instr0_is_dp_i);
  assign net_1_577 = (net_1_331 & net_1_583);
  assign net_1_583 = (instr0_a32_only | net_1_584);
  assign net_1_584 = (instr0_shf_type_imm_field_zero | net_1_585);
  assign net_1_585 = (net_1_175 | instr0_11_8_is_pc);
  assign net_1_175 = (net_1_394 | net_1_16);
  assign net_1_331 = ~(net_1_540 & net_1_586);
  assign net_1_586 = (net_1_587 | net_1_588);
  assign net_1_587 = ~(iq_instr0_sideband_i[3] | net_1_589);
  assign net_1_589 = (net_1_16 | net_1_21);
  assign instr0_11_8_when_not_ex2 = (net_1_590 | net_1_591);
  assign net_1_591 = (net_1_592 | net_1_593);
  assign net_1_593 = (net_1_6 | net_1_594);
  assign net_1_592 = ~(net_1_595 & net_1_596);
  assign net_1_596 = ~(iq_instr0_i[28] & net_1_597);
  assign net_1_597 = (net_1_598 | net_1_599);
  assign net_1_599 = (iq_instr0_i[27] & net_1_600);
  assign net_1_600 = (net_1_601 | net_1_602);
  assign net_1_602 = (net_1_216 & net_1_538);
  assign net_1_538 = ~(iq_instr0_i[22] | iq_instr0_i[20]);
  assign net_1_216 = (iq_instr0_i[7] & net_1_56);
  assign net_1_601 = ~(iq_instr0_i[7] | net_1_603);
  assign net_1_603 = ~(iq_instr0_i[4] & iq_instr0_i[15]);
  assign net_1_590 = ~(net_1_604 & net_1_605);
  assign net_1_605 = ~(net_1_421 & net_1_606);
  assign net_1_606 = (net_1_156 & instr0_11_8_is_pc);
  assign net_1_156 = (iq_instr0_i[21] & iq_instr0_i[23]);
  assign net_1_604 = ~(mac_valid_instr0 | net_1_607);
  assign net_1_607 = (net_1_70 & net_1_608);
  assign net_1_70 = ~(iq_instr0_i[21] | iq_instr0_i[23]);
  assign mac_valid_instr0 = (net_1_545 | net_1_534);
  assign net_1_545 = ~(net_1_16 | net_1_281);
  assign net_1_281 = ~(iq_instr0_i[28] & net_1_609);
  assign instr0_11_8_when_not_ex1 = (net_1_610 | net_1_611);
  assign net_1_611 = ~(net_1_612 & net_1_613);
  assign net_1_613 = ~(net_1_598 | net_1_336);
  assign net_1_336 = ~(net_1_128 & net_1_614);
  assign net_1_614 = (net_1_595 & net_1_615);
  assign net_1_615 = (iq_instr0_i[28] | net_1_616);
  assign net_1_616 = (net_1_292 & net_1_19);
  assign net_1_292 = ~(net_1_224 & net_1_56);
  assign net_1_595 = (net_1_142 & net_1_617);
  assign net_1_617 = ~(instr0_11_8_is_pc & net_1_618);
  assign net_1_618 = ~(iq_instr0_i[25] | iq_instr0_aarch64_i);
  assign net_1_142 = ~(iq_instr0_i[28] & net_1_619);
  assign net_1_619 = (net_1_548 & iq_instr0_i[14]);
  assign net_1_548 = ~(iq_instr0_i[15] | net_1_168);
  assign net_1_128 = (net_1_554 & net_1_620);
  assign net_1_620 = (iq_instr0_i[15] | net_1_621);
  assign net_1_621 = ~(iq_instr0_sideband_i[1] & net_1_622);
  assign net_1_622 = ~(net_1_22 | net_1_16);
  assign net_1_554 = (net_1_623 & net_1_624);
  assign net_1_624 = (iq_instr0_i[20] | net_1_625);
  assign net_1_625 = (net_1_2 | net_1_256);
  assign net_1_256 = ~(net_1_15 & net_1_21);
  assign net_1_623 = (net_1_626 & net_1_627);
  assign net_1_627 = (net_1_312 | instr0_11_8_is_pc);
  assign net_1_626 = (net_1_628 | iq_instr0_i[25]);
  assign net_1_628 = (net_1_18 | net_1_4);
  assign net_1_224 = ~(net_1_21 | iq_instr0_i[24]);
  assign net_1_612 = ~(net_1_315 | net_1_629);
  assign net_1_629 = ~(net_1_630 & net_1_631);
  assign net_1_631 = ~(net_1_632 & net_1_633);
  assign net_1_633 = (iq_instr0_i[5] & iq_instr0_i[4]);
  assign net_1_632 = (instr0_shf_imm_field_zero & iq_instr0_i[27]);
  assign net_1_630 = ~(net_1_6 | net_1_534);
  assign net_1_534 = ~(iq_instr0_i[4] | net_1_634);
  assign net_1_634 = ~(iq_instr0_i[23] & net_1_332);
  assign net_1_332 = (net_1_84 & net_1_2);
  assign net_1_84 = (iq_instr0_sideband_i[2] & net_1_635);
  assign net_1_635 = (net_1_4 & iq_instr0_i[28]);
  assign net_1_315 = (iq_instr0_sideband_i[2] & net_1_636);
  assign net_1_636 = (iq_instr0_i[21] & net_1_19);
  assign net_1_610 = (net_1_637 | net_1_638);
  assign net_1_638 = (net_1_339 | net_1_639);
  assign net_1_639 = ~(net_1_640 & net_1_246);
  assign net_1_246 = ~(iq_instr0_i[7] & net_1_346);
  assign net_1_346 = (iq_instr0_i[28] & net_1_225);
  assign net_1_225 = ~(iq_instr0_i[26] | net_1_641);
  assign net_1_641 = (iq_instr0_is_ot_i | net_1_642);
  assign net_1_642 = ~(iq_instr0_i[15] & net_1_536);
  assign net_1_640 = (net_1_643 & net_1_644);
  assign net_1_644 = ~(net_1_318 & net_1_645);
  assign net_1_645 = (net_1_566 & net_1_14);
  assign net_1_566 = (instr0_shf_type_imm_field_zero & net_1_10);
  assign net_1_318 = (net_1_646 | net_1_563);
  assign net_1_646 = (net_1_20 & net_1_647);
  assign net_1_647 = (net_1_581 & iq_instr0_i[22]);
  assign net_1_581 = ~(iq_instr0_i[4] | iq_instr0_i[5]);
  assign net_1_643 = ~(net_1_648 & net_1_649);
  assign net_1_649 = (net_1_85 | net_1_535);
  assign net_1_535 = (net_1_56 & net_1_19);
  assign net_1_56 = ~(iq_instr0_i[21] | net_1_20);
  assign net_1_85 = (iq_instr0_i[22] & iq_instr0_i[21]);
  assign net_1_648 = (net_1_15 & net_1_536);
  assign net_1_339 = (net_1_237 | net_1_650);
  assign net_1_650 = (net_1_651 | net_1_652);
  assign net_1_652 = (net_1_594 | net_1_530);
  assign net_1_530 = ~(net_1_653 & net_1_125);
  assign net_1_125 = (net_1_575 | net_1_654);
  assign net_1_654 = ~(iq_instr0_aarch64_i & net_1_655);
  assign net_1_655 = ~(iq_instr0_i[24] | net_1_312);
  assign net_1_312 = (iq_instr0_i[22] | net_1_131);
  assign net_1_131 = (iq_instr0_i[25] | instr0_a64_only);
  assign net_1_575 = (iq_instr0_is_ls_i | iq_instr0_i[15]);
  assign net_1_653 = (net_1_305 & net_1_656);
  assign net_1_656 = (instr0_a64_only | net_1_657);
  assign net_1_657 = (net_1_658 | net_1_659);
  assign net_1_659 = (net_1_19 | iq_instr0_is_ls_i);
  assign net_1_658 = (net_1_660 & net_1_661);
  assign net_1_661 = (iq_instr0_is_ot_i | net_1_662);
  assign net_1_662 = ~(net_1_508 & iq_instr0_i[22]);
  assign net_1_508 = (net_1_9 & iq_instr0_i[20]);
  assign net_1_660 = (iq_instr0_sideband_i[2] | net_1_663);
  assign net_1_663 = (iq_instr0_i[15] | net_1_664);
  assign net_1_664 = ~(net_1_15 & net_1_22);
  assign net_1_305 = (net_1_168 | net_1_665);
  assign net_1_665 = (net_1_413 | net_1_666);
  assign net_1_666 = ~(iq_instr0_sideband_i[2] & iq_instr0_sideband_i[0]);
  assign net_1_413 = (net_1_14 | net_1_20);
  assign net_1_594 = (net_1_667 | net_1_228);
  assign net_1_228 = (net_1_540 & net_1_668);
  assign net_1_668 = (instr0_a32_only & net_1_669);
  assign net_1_667 = (net_1_670 & net_1_671);
  assign net_1_671 = ~(net_1_168 | instr0_a32_only);
  assign net_1_168 = (net_1_15 | iq_instr0_i[24]);
  assign net_1_670 = (net_1_669 & iq_instr0_i[10]);
  assign net_1_669 = (iq_instr0_i[20] & net_1_608);
  assign net_1_608 = (instr0_11_8_is_pc & net_1_14);
  assign net_1_651 = (net_1_672 & net_1_673);
  assign net_1_673 = (net_1_588 | net_1_320);
  assign net_1_320 = ~(instr0_19_16_is_pc | iq_instr0_i[23]);
  assign net_1_588 = (instr0_a32_only & net_1_563);
  assign net_1_563 = ~(iq_instr0_i[22] | instr0_11_8_is_pc);
  assign net_1_672 = (net_1_540 & net_1_14);
  assign net_1_540 = ~(iq_instr0_is_ot_i | net_1_394);
  assign net_1_237 = ~(iq_instr0_i[28] | net_1_674);
  assign net_1_674 = (instr0_shf_type_imm_field_zero | net_1_149);
  assign net_1_149 = (net_1_394 | net_1_675);
  assign net_1_675 = (iq_instr0_i[22] | instr0_a32_only);
  assign net_1_394 = (iq_instr0_i[26] | net_1_15);
  assign net_1_637 = (iq_instr0_i[25] & net_1_609);
  assign net_1_609 = ~(iq_instr0_is_ot_i | net_1_676);
  assign net_1_676 = ~(net_1_421 & net_1_677);
  assign net_1_677 = (net_1_9 & net_1_23);
  assign net_1_421 = ~(net_1_15 | net_1_19);
  assign div_valid_instr0 = (net_1_221 & net_1_598);
  assign net_1_598 = (net_1_678 & net_1_90);
  assign net_1_90 = ~(net_1_19 | net_1_22);
  assign net_1_678 = (iq_instr0_i[7] & net_1_536);
  assign net_1_536 = (net_1_12 & iq_instr0_i[25]);
  assign net_1_221 = ~(net_1_14 | net_1_6);
  assign dcu_valid_instr0 = (net_1_679 | net_1_680);
  assign net_1_680 = (net_1_681 | iq_instr0_is_ls_i);
  assign net_1_681 = (net_1_431 & net_1_682);
  assign net_1_682 = ~(iq_instr0_i[11] & net_1_19);
  assign net_1_431 = ~(net_1_15 | iq_instr0_i[25]);
  assign net_1_679 = (iq_instr0_is_fn_i & net_1_683);
  assign net_1_683 = (net_1_684 | net_1_15);
  assign net_1_684 = (iq_instr0_sideband_i[3] | net_1_685);
  assign net_1_685 = ~(iq_instr0_i[26] & net_1_686);
  assign net_1_686 = (net_1_20 | iq_instr0_i[25]);
  assign br_valid_instr0 = (net_1_687 | net_1_184);
  assign net_1_184 = (net_1_688 & net_1_689);
  assign net_1_689 = (iq_instr0_sideband_i[0] & iq_instr0_i[26]);
  assign net_1_688 = ~(net_1_12 | net_1_14);
  assign net_1_687 = (iq_instr0_is_ot_i & net_1_690);
  assign net_1_690 = (net_1_4 | iq_instr0_i[12]);
  assign net_1_691 = ~(net_1_6 | net_1_137);
  assign net_1_692 = ~(net_1_135 & net_1_691);
  assign net_1_693 = ~(iq_instr0_i[22] & net_1_122);
  assign net_1_694 = (net_1_130 | net_1_693);
  assign net_1_112 = (net_1_692 & net_1_694);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  // Decode additional instruction information
  assign instr1_top_3_0     = iq_instr1_i[31] & iq_instr1_ctl_aarch64_i;
  assign instr1_top_11_8    = (iq_instr1_is_dp_i ? iq_instr1_i[29]         : iq_instr1_sideband_i[0]) & iq_instr1_ctl_aarch64_i;
  assign instr1_top_15_12   = (iq_instr1_is_dp_i ? iq_instr1_sideband_i[0] : iq_instr1_i[29])         & iq_instr1_ctl_aarch64_i;
  assign instr1_top_19_16   = iq_instr1_i[30] & iq_instr1_ctl_aarch64_i;

  assign instr0_top_3_0     = iq_instr0_i[31]  & iq_instr0_ctl_aarch64_i;
  assign instr0_top_11_8_rd = (iq_instr0_is_dp_i ? iq_instr0_i[29] : iq_instr0_sideband_i[0]) & iq_instr0_ctl_aarch64_i;
  assign instr0_top_11_8_wr = (iq_instr0_is_dp_i ? iq_instr0_i[29] : iq_instr0_i[31])  & iq_instr0_ctl_aarch64_i;
  assign instr0_top_15_12   = iq_instr0_i[29]  & iq_instr0_ctl_aarch64_i;
  assign instr0_top_19_16   = iq_instr0_i[30]  & iq_instr0_ctl_aarch64_i;
                           
  assign instr1_reg[R3_0  ] = {instr1_top_3_0  , iq_instr1_i[ 3: 0]};
  assign instr1_reg[R11_8 ] = {instr1_top_11_8 , iq_instr1_i[11: 8]};
  assign instr1_reg[R15_12] = {instr1_top_15_12, iq_instr1_i[15:12]};
  assign instr1_reg[R19_16] = {instr1_top_19_16, iq_instr1_i[19:16]};

  assign instr0_reg[R3_0  ] = {instr0_top_3_0    , iq_instr0_i[ 3: 0]};
  assign instr0_reg[R11_8 ] = {instr0_top_11_8_rd, iq_instr0_i[11: 8]};
  assign instr0_reg[R11_8W] = {instr0_top_11_8_wr, iq_instr0_i[11: 8]};
  assign instr0_reg[R15_12] = {instr0_top_15_12  , iq_instr0_i[15:12]};
  assign instr0_reg[R19_16] = {instr0_top_19_16  , iq_instr0_i[19:16]};

  assign instr1_need_de[R3_0  ] = {instr1_need_late_ex1[R3_0  ], instr1_need_late_iss[R3_0  ], instr1_need_early_iss[R3_0  ]};
  assign instr1_need_de[R11_8 ] = {instr1_need_late_ex1[R11_8 ], instr1_need_late_iss[R11_8 ], instr1_need_early_iss[R11_8 ]};
  assign instr1_need_de[R15_12] = {instr1_need_late_ex1[R15_12], instr1_need_late_iss[R15_12], instr1_need_early_iss[R15_12]};
  assign instr1_need_de[R19_16] = {instr1_need_late_ex1[R19_16], instr1_need_late_iss[R19_16], instr1_need_early_iss[R19_16]};

  assign instr0_need_de[R3_0  ] = {instr0_need_late_ex1[R3_0  ], instr0_need_late_iss[R3_0  ], instr0_need_early_iss[R3_0  ]};
  assign instr0_need_de[R11_8 ] = {instr0_need_late_ex1[R11_8 ], instr0_need_late_iss[R11_8 ], instr0_need_early_iss[R11_8 ]};
  assign instr0_need_de[R15_12] = {instr0_need_late_ex1[R15_12], instr0_need_late_iss[R15_12], instr0_need_early_iss[R15_12]};
  assign instr0_need_de[R19_16] = {instr0_need_late_ex1[R19_16], instr0_need_late_iss[R19_16], instr0_need_early_iss[R19_16]};

  // Detect when slot 1 does an RRX type shift
  // - Load store instruction doing RRX
  //   (The only D1 load/store instructions which can do an RRX are post-indexed (LDR|STR){B} (register-ARM))
  assign instr1_is_ls_rrx = iq_instr1_is_ls_i & ~instr1_cc_never &              // PLI is D1 and uses same encoding but is CC Never
                            instr1_a32_only & (iq_instr1_i[26:24] == 3'b110) &  // Post-indexed (LDR|STR){B} (register-ARM)
                            (iq_instr1_i[11:5] == 7'b0000011);                  // Shift type is RRX (encoded as ROR #0)

  // - Data-processing instruction doing RRX
  assign instr1_shf_imm_field_zero      = {iq_instr1_i[14:12], iq_instr1_i[7:6]} == 5'b000_00;
  assign instr1_shf_imm_field_zero_arm  = iq_instr1_i[11:7]  == 5'b00000;
  assign instr1_is_dp_rrx = (instr1_ex1_ctl_shift_op == `CA53_SHIFT_OP_ROR) & ~iq_instr1_ctl_aarch64_i &
                            ((instr1_ex1_ctl_shift_rrx_for_0_a & instr1_shf_imm_field_zero_arm) |
                             (instr1_ex1_ctl_shift_rrx_for_0_t & instr1_shf_imm_field_zero));

  // ------------------------------------------------------
  // Detect a CC flags hazard between slot 1 and slot 0
  // ------------------------------------------------------
  // Generally, a flag setting instruction in slot 0 can dual issue with a
  // conditional instruction in slot 1, as there is logic to forward the result
  // to the CC pass logic at the end of Ex2. This is not true for flag setting
  // multiplies or FP instructions in slot 0 however.
  // When an instruction in slot 1 reads the CC flags (for either an RRX or
  // carry in) then there is no forwarding path, so this cannot dual issue with
  // a flag setting instruction in slot 0. Note there is logic to forward flags
  // from slot 0 to a conditional compare/select, so these do not need to
  // hazard.
  assign instr1_cc_hazard = (instr1_is_dp_rrx | instr1_is_ls_rrx | instr1_au_uses_cin |
                             mac_valid_instr0 | iq_instr0_is_fn_i) &
                            instr0_sets_ccflags;

  // ------------------------------------------------------
  // Detect a register RAW hazard between slot 1 and slot 0
  // ------------------------------------------------------

  // It is possible for a slot 0 ALU operation to forward to
  // a slot 1 ALU operation in the same pipeline stage, as a 
  // special flat forwarding path exists between ALU0 Ex1 and
  // ALU1 Ex1.
  // Similarly, a path exists between ALU0 Ex2 and STR1 Ex2.
  // All ALU operations which can make use of this path specify
  // their destination register in [11:8].
  
  // The "When" from instr0 is modified by skewing and the conditionality of the instruction
  assign mod_instr0_11_8_when_not_ex1 = (instr0_11_8_when_not_ex1 & ~iq_skew_instr0) |
                                        (~iq_instr0_ctl_aarch64_i &
                                         (iq_instr0_i[32:30] != `CA53_CC_AL_or_NV));
  
  assign de_11_8_hz_valid =  instr1_need_late_iss                                      | // Need of Iss (cannot fwd Iss->Iss)
                            (instr1_need_late_ex1 & {4{mod_instr0_11_8_when_not_ex1}}) | // Need of Ex1 and When after Ex1
                                                    {4{instr0_11_8_when_not_ex2}};       // When after Ex2

  assign raw_hazard_3_0_de   = (({instr1_reads[R3_0  ],                           instr1_reg[R3_0  ]} == {1'b1,  instr0_reg[R3_0  ]}) |
                                ({instr1_reads[R11_8 ],                           instr1_reg[R11_8 ]} == {1'b1,  instr0_reg[R3_0  ]}) |
                                ({instr1_reads[R15_12],                           instr1_reg[R15_12]} == {1'b1,  instr0_reg[R3_0  ]}) |
                                ({instr1_reads[R19_16],                           instr1_reg[R19_16]} == {1'b1,  instr0_reg[R3_0  ]})) &
                               instr0_3_0_written;

  assign raw_hazard_11_8_de  = ( ({instr1_reads[R3_0  ], de_11_8_hz_valid[R3_0  ], instr1_reg[R3_0  ]} == {2'b11, instr0_reg[R11_8W]}) |
                                 ({instr1_reads[R11_8 ], de_11_8_hz_valid[R11_8 ], instr1_reg[R11_8 ]} == {2'b11, instr0_reg[R11_8W]}) |
                                 ({instr1_reads[R15_12], de_11_8_hz_valid[R15_12], instr1_reg[R15_12]} == {2'b11, instr0_reg[R11_8W]}) |
                                (({instr1_reads[R19_16], de_11_8_hz_valid[R19_16], instr1_reg[R19_16]} == {2'b11, instr0_reg[R11_8W]})
                                 & ~(instr0_is_adrp & instr1_can_adrp_forward_qual))) &
                               instr0_11_8_written;

  assign raw_hazard_15_12_de = (({instr1_reads[R3_0  ],                           instr1_reg[R3_0  ]} == {1'b1,  instr0_reg[R15_12]}) |
                                ({instr1_reads[R11_8 ],                           instr1_reg[R11_8 ]} == {1'b1,  instr0_reg[R15_12]}) |
                                ({instr1_reads[R15_12],                           instr1_reg[R15_12]} == {1'b1,  instr0_reg[R15_12]}) |
                                ({instr1_reads[R19_16],                           instr1_reg[R19_16]} == {1'b1,  instr0_reg[R15_12]})) &
                               instr0_15_12_written;                         
                                                                             
  assign raw_hazard_19_16_de = (({instr1_reads[R3_0  ],                           instr1_reg[R3_0  ]} == {1'b1,  instr0_reg[R19_16]}) |
                                ({instr1_reads[R11_8 ],                           instr1_reg[R11_8 ]} == {1'b1,  instr0_reg[R19_16]}) |
                                ({instr1_reads[R15_12],                           instr1_reg[R15_12]} == {1'b1,  instr0_reg[R19_16]}) |
                                ({instr1_reads[R19_16],                           instr1_reg[R19_16]} == {1'b1,  instr0_reg[R19_16]})) &
                               instr0_19_16_written;

  // RAW hazards can be ignored when slot 0 and slot 1 are both conditional
  // and have opposite condition codes, so long as the slot 0 instruction is
  // will not set the flags. This is because either the slot 0 instruction
  // will cc fail, and so does not need to forward data to slot 1, or the
  // slot 1 instruction will cc fail and so it does not matter if it reads
  // the wrong data.
  // The ctl block does similar RAW hazard suppression between Iss and later
  // pipeline stages.
  assign ignore_raw_hazard_de = (iq_instr0_i[32:30] == iq_instr1_i[32:30]) &
                                (iq_instr0_i[29]    != iq_instr1_i[29])    &
                                (iq_instr0_i[32:30] != `CA53_CC_AL_or_NV)  &
                                ~instr0_sets_ccflags &
                                ~iq_instr0_ctl_aarch64_i;  // Ignore condition codes in AA64

  // Branches implicitly write the PC (we ignore here whether the branch is
  // predicted not-taken, as factoring this in would affect timing for little
  // performance advantage), so there is a RAW hazard between a branch in slot 0
  // and an instruction in slot 1 which reads the PC.
  // - Note that some NEON instructions can indicate they are reading 3:0, but
  // do not actually do so when 3:0 is 4'b1111.
  assign instr1_reads_pc = ((({instr1_reads[R3_0  ], iq_instr1_is_fn_i, iq_instr1_i[ 3: 0]} == {1'b1, 1'b0, 4'b1111}) |
                             ({instr1_reads[R11_8 ],                    iq_instr1_i[11: 8]} == {1'b1,       4'b1111}) |
                             ({instr1_reads[R15_12],                    iq_instr1_i[15:12]} == {1'b1,       4'b1111}) |
                             ({instr1_reads[R19_16],                    iq_instr1_i[19:16]} == {1'b1,       4'b1111})) & 
                            ~iq_instr1_ctl_aarch64_i) |
                           instr1_selects_pc;

  assign raw_hazard_pc_de = instr1_reads_pc & br_valid_instr0;

  // BL instructions write either R14 or X30, so there is a RAW hazard if slot 0 is a
  // BL and slot 1 reads R14/X30.
  assign raw_hazard_lr_de = (({instr1_reads[R3_0  ], instr1_reg[R3_0  ]} == {1'b1, iq_instr1_ctl_aarch64_i, 4'b1110}) |  // Top bit set if AA64
                             ({instr1_reads[R11_8 ], instr1_reg[R11_8 ]} == {1'b1, iq_instr1_ctl_aarch64_i, 4'b1110}) |
                             ({instr1_reads[R15_12], instr1_reg[R15_12]} == {1'b1, iq_instr1_ctl_aarch64_i, 4'b1110}) |
                             ({instr1_reads[R19_16], instr1_reg[R19_16]} == {1'b1, iq_instr1_ctl_aarch64_i, 4'b1110})) &
                            instr0_lr_written;

  // ------------------------------------------------------
  // FP/Neon
  // ------------------------------------------------------
generate if (NEON_FP) begin : g_fp_dih_present

  wire  [3:0] instr1_fp_reads;
  wire  [3:0] instr0_fp_reads;
  wire  [2:0] instr0_fp_writes;
  wire  [2:0] instr1_fp_writes;
  wire        instr0_fp_uses_pipe1;
  wire  [4:0] instr1_fp_reg [3:0];
  wire  [4:0] instr0_fp_reg [3:0];
  wire  [4:0] instr1_fp_read_q_reg  [3:0];
  wire  [4:0] instr0_fp_read_q_reg  [3:0];
  wire  [4:0] instr1_fp_write_q_reg [2:0];
  wire  [4:0] instr0_fp_write_q_reg  [2:0];
  wire  [3:0] instr1_fp_read_mask [3:0];
  wire  [3:0] instr0_fp_read_mask [3:0];
  wire  [3:0] instr1_fp_write_mask [2:0];
  wire  [3:0] instr0_fp_write_mask [2:0];
  wire  [2:0] q_reg_raw_hazard_fp_de;
  wire  [2:0] mask_raw_hazard_fp_de;
  wire  [2:0] q_reg_waw_hazard_fp_de;
  wire  [2:0] mask_waw_hazard_fp_de;
  wire  [1:0] instr1_fp_write_d_size;
  wire  [1:0] instr1_fp_read_d_size;
  wire  [1:0] instr0_fp_read_d_size;
  wire  [1:0] instr0_fp_write_d_size;
  wire        instr1_fp_write_is_s;
  wire        instr1_fp_read_is_s;
  wire        instr0_fp_read_is_s;
  wire        instr0_fp_write_is_s;
  wire        instr1_fp_need_f1;
  wire        instr0_fp_need_f1;
  wire  [4:0] iss_fw0_q_reg;
  wire  [4:0] iss_fw1_q_reg;
  wire  [4:0] f1_fw0_q_reg;
  wire  [4:0] f1_fw1_q_reg;
  wire  [4:0] f2_fw0_q_reg;
  wire  [4:0] f2_fw1_q_reg;
  wire  [3:0] iss_fw0_write_mask;
  wire  [3:0] iss_fw1_write_mask;
  wire  [3:0] f1_fw0_write_mask;
  wire  [3:0] f1_fw1_write_mask;
  wire  [3:0] f2_fw0_write_mask;
  wire  [3:0] f2_fw1_write_mask;
  wire        instr0_fn_sf_bit;
  wire        instr0_fw0_iss_match;
  wire        instr0_fw1_iss_match;
  wire        instr1_fw0_iss_match;
  wire        instr1_fw1_iss_match;
  wire        instr0_fw0_f1_match;
  wire        instr0_fw1_f1_match;
  wire        instr1_fw0_f1_match;
  wire        instr1_fw1_f1_match;
  wire        instr0_fw0_f2_match;
  wire        instr0_fw1_f2_match;
  wire        instr1_fw0_f2_match;
  wire        instr1_fw1_f2_match;
  wire  [2:0] instr0_fw0_iss_mask;
  wire  [2:0] instr0_fw1_iss_mask;
  wire  [2:0] instr1_fw0_iss_mask;
  wire  [2:0] instr1_fw1_iss_mask;
  wire  [2:0] instr0_fw0_f1_mask;
  wire  [2:0] instr0_fw1_f1_mask;
  wire  [2:0] instr1_fw0_f1_mask;
  wire  [2:0] instr1_fw1_f1_mask;
  wire  [2:0] instr0_fw0_f2_mask;
  wire  [2:0] instr0_fw1_f2_mask;
  wire  [2:0] instr1_fw0_f2_mask;
  wire  [2:0] instr1_fw1_f2_mask;
  wire  [2:0] instr0_fp_interlock_mask;
  wire  [2:0] instr1_fp_interlock_mask;
  wire  [4:0] instr0_fp_read_q_reg_mask;
  wire  [4:0] instr0_fp_write_q_reg_mask;
  wire  [4:0] instr1_fp_read_q_reg_mask;
  wire  [4:0] instr1_fp_write_q_reg_mask;

  assign instr0_fn_sf_bit = iq_instr0_fn_dih_32_i & iq_instr0_fn_dih_aarch64_i;

  // ------------------------------------------------------
  // Start Slot 1 NEON automatically generated logic
  // ------------------------------------------------------

  wire    net_2_1, net_2_2, net_2_3, net_2_4, net_2_5, net_2_6,
         net_2_8, net_2_9, net_2_10, net_2_11, net_2_12, net_2_13, net_2_14, net_2_15, net_2_16,
         net_2_17, net_2_18, net_2_19, net_2_20, net_2_21, net_2_22, net_2_23, net_2_24,
         net_2_25, net_2_26, net_2_27, net_2_28, net_2_29, net_2_30, net_2_31, net_2_32,
         net_2_33, net_2_34, net_2_35, net_2_36, net_2_37, net_2_38, net_2_39, net_2_40,
         net_2_41, net_2_42, net_2_43, net_2_44, net_2_45, net_2_46, net_2_47, net_2_48,
         net_2_49, net_2_50, net_2_51, net_2_52, net_2_53, net_2_54, net_2_55, net_2_56,
         net_2_57, net_2_58, net_2_59, net_2_60, net_2_61, net_2_62, net_2_63, net_2_64,
         net_2_65, net_2_66, net_2_67, net_2_68, net_2_69, net_2_70, net_2_71, net_2_72,
         net_2_73, net_2_74, net_2_78, net_2_80, net_2_81, net_2_82, net_2_83, net_2_84,
         net_2_85, net_2_86, net_2_87, net_2_88, net_2_89, net_2_90, net_2_91, net_2_92,
         net_2_93, net_2_94, net_2_95, net_2_96, net_2_97, net_2_98, net_2_99, net_2_100,
         net_2_101, net_2_102, net_2_103, net_2_104, net_2_105, net_2_106, net_2_107,
         net_2_108, net_2_109, net_2_110, net_2_111, net_2_112, net_2_113, net_2_114,
         net_2_115, net_2_116, net_2_117, net_2_118, net_2_119, net_2_120, net_2_121,
         net_2_122, net_2_123, net_2_124, net_2_125, net_2_126, net_2_127, net_2_128,
         net_2_129, net_2_130, net_2_131, net_2_132, net_2_133, net_2_134, net_2_135,
         net_2_136, net_2_137, net_2_138, net_2_139, net_2_140, net_2_141, net_2_142,
         net_2_143, net_2_144, net_2_145, net_2_146, net_2_147, net_2_148, net_2_149,
         net_2_150, net_2_151, net_2_152, net_2_153, net_2_154, net_2_155, net_2_156,
         net_2_157, net_2_158, net_2_159, net_2_160, net_2_161, net_2_162, net_2_163,
         net_2_164, net_2_165, net_2_166, net_2_167, net_2_168, net_2_169, net_2_170,
         net_2_171, net_2_172, net_2_173, net_2_174, net_2_175, net_2_176, net_2_177,
         net_2_178, net_2_179, net_2_180, net_2_181, net_2_182, net_2_183, net_2_184,
         net_2_185, net_2_186, net_2_187, net_2_188, net_2_189, net_2_190, net_2_191,
         net_2_192, net_2_193, net_2_194, net_2_195, net_2_196, net_2_197, net_2_198,
         net_2_199, net_2_200, net_2_201, net_2_202, net_2_203, net_2_204, net_2_205,
         net_2_206, net_2_207, net_2_208, net_2_209, net_2_210, net_2_211, net_2_212,
         net_2_213, net_2_214, net_2_215, net_2_216, net_2_217, net_2_218, net_2_219,
         net_2_220, net_2_221, net_2_222, net_2_223, net_2_224, net_2_225, net_2_226,
         net_2_227, net_2_228, net_2_229, net_2_230, net_2_231, net_2_232, net_2_233,
         net_2_234, net_2_235, net_2_236, net_2_237, net_2_238, net_2_239, net_2_240,
         net_2_241, net_2_242, net_2_243, net_2_244, net_2_245, net_2_246, net_2_247,
         net_2_248, net_2_249, net_2_250, net_2_251, net_2_252, net_2_253, net_2_254,
         net_2_255, net_2_256, net_2_257, net_2_258, net_2_259, net_2_260, net_2_261,
         net_2_262, net_2_263, net_2_264, net_2_265, net_2_266, net_2_267, net_2_268,
         net_2_269, net_2_270, net_2_271, net_2_272, net_2_273, net_2_274, net_2_275,
         net_2_276;

  assign instr1_fp_read_d_size[0] = instr1_fp_read_d_size[1];
  assign instr1_fp_write_is_s = iq_instr1_sideband_i[0];
  assign instr1_fp_write_d_size[0] = instr1_fp_write_d_size[1];
  assign net_2_1 = ~iq_instr1_fn_dih_pdtype0_i;
  assign net_2_2 = ~net_2_67;
  assign net_2_3 = ~net_2_122;
  assign net_2_4 = ~iq_instr1_fn_dih_i[28];
  assign net_2_5 = ~net_2_89;
  assign net_2_6 = ~iq_instr1_fn_dih_i[25];
  assign net_2_8 = ~iq_instr1_fn_dih_i[23];
  assign net_2_9 = ~iq_instr1_fn_dih_i[21];
  assign net_2_10 = ~iq_instr1_fn_dih_i[20];
  assign net_2_11 = ~iq_instr1_fn_dih_i[17];
  assign net_2_12 = ~iq_instr1_fn_dih_i[9];
  assign net_2_13 = ~iq_instr1_fn_dih_i[5];
  assign net_2_14 = ~iq_instr1_fn_dih_i[4];
  assign instr1_is_neon = (net_2_15 | net_2_16);
  assign net_2_16 = (net_2_17 | net_2_18);
  assign net_2_18 = ~(net_2_19 & net_2_20);
  assign net_2_19 = ~(net_2_21 | net_2_22);
  assign net_2_22 = (net_2_23 | net_2_24);
  assign net_2_24 = (net_2_25 | net_2_26);
  assign net_2_17 = ~(iq_instr1_fn_dih_pdtype0_i | net_2_27);
  assign net_2_27 = ~(iq_instr1_fn_dih_i[10] | net_2_28);
  assign net_2_28 = ~(net_2_29 | net_2_8);
  assign instr1_fp_writes[2] = ~(iq_instr1_fn_dih_i[20] | net_2_30);
  assign instr1_fp_writes[1] = (net_2_31 | net_2_32);
  assign net_2_32 = (instr1_fp_reads[3] | net_2_33);
  assign net_2_33 = (net_2_34 | net_2_35);
  assign net_2_34 = ~(net_2_36 & net_2_37);
  assign net_2_37 = (net_2_38 | iq_instr1_sideband_i[3]);
  assign net_2_36 = ~(net_2_15 | net_2_39);
  assign net_2_39 = (iq_instr1_fn_dih_i[20] & net_2_40);
  assign net_2_40 = ~(net_2_41 & net_2_42);
  assign net_2_42 = ~(iq_instr1_fn_dih_i[23] & net_2_43);
  assign net_2_43 = ~(iq_instr1_fn_dih_i[4] | net_2_44);
  assign net_2_44 = ~(iq_instr1_fn_dih_i[11] & net_2_45);
  assign net_2_45 = ~(iq_instr1_fn_dih_i[6] | iq_instr1_fn_dih_i[10]);
  assign net_2_15 = (iq_instr1_fn_dih_i[24] & net_2_46);
  assign net_2_46 = (net_2_47 | net_2_48);
  assign net_2_48 = (iq_instr1_fn_dih_i[25] & net_2_49);
  assign net_2_49 = (net_2_50 | net_2_51);
  assign net_2_51 = (iq_instr1_fn_dih_i[4] & iq_instr1_fn_dih_i[23]);
  assign instr1_fp_writes[0] = ~(net_2_52 & net_2_53);
  assign net_2_53 = (net_2_54 | iq_instr1_fn_dih_i[23]);
  assign net_2_52 = ~(net_2_26 | net_2_55);
  assign net_2_26 = (net_2_56 & net_2_10);
  assign instr1_fp_write_d_size[1] = (net_2_57 & net_2_58);
  assign net_2_58 = (iq_instr1_fn_dih_i[21] | net_2_59);
  assign net_2_59 = (iq_instr1_fn_dih_i[25] & net_2_8);
  assign instr1_fp_reads[2] = (net_2_60 | net_2_61);
  assign net_2_61 = (net_2_62 | net_2_63);
  assign net_2_63 = (net_2_64 | net_2_55);
  assign net_2_55 = (net_2_65 & net_2_14);
  assign net_2_65 = (net_2_66 & net_2_67);
  assign net_2_64 = (net_2_68 & iq_instr1_fn_dih_pdtype0_i);
  assign net_2_62 = (net_2_69 | net_2_35);
  assign net_2_35 = (net_2_70 | net_2_71);
  assign net_2_71 = (net_2_72 | net_2_73);
  assign net_2_73 = (net_2_74 | net_2_21);
  assign net_2_72 = ~(iq_instr1_fn_dih_i[11] | net_2_81);
  assign net_2_81 = ~(net_2_68 & net_2_82);
  assign net_2_82 = (iq_instr1_fn_dih_i[20] & iq_instr1_fn_dih_i[10]);
  assign net_2_70 = (net_2_83 | net_2_84);
  assign net_2_84 = (net_2_14 & net_2_85);
  assign net_2_85 = (net_2_23 | net_2_86);
  assign net_2_86 = (net_2_87 & net_2_88);
  assign net_2_23 = (net_2_89 & net_2_3);
  assign net_2_83 = ~(iq_instr1_fn_dih_pdtype0_i | net_2_90);
  assign net_2_90 = ~(net_2_91 & iq_instr1_fn_dih_i[6]);
  assign net_2_91 = (net_2_92 | net_2_93);
  assign net_2_93 = (net_2_94 & net_2_95);
  assign net_2_95 = (net_2_96 | net_2_97);
  assign net_2_97 = ~(net_2_11 | iq_instr1_fn_dih_i[19]);
  assign net_2_96 = ~(iq_instr1_fn_dih_i[17] | iq_instr1_fn_dih_i[18]);
  assign net_2_92 = ~(iq_instr1_fn_dih_i[10] | net_2_98);
  assign net_2_98 = ~(iq_instr1_fn_dih_i[28] & iq_instr1_fn_dih_i[11]);
  assign net_2_69 = (iq_instr1_fn_dih_i[20] & net_2_99);
  assign net_2_99 = ~(net_2_100 & net_2_30);
  assign net_2_30 = (iq_instr1_fn_dih_i[24] | net_2_101);
  assign net_2_101 = ~(net_2_1 & net_2_6);
  assign instr1_fp_reads[1] = (net_2_102 | net_2_103);
  assign net_2_103 = (net_2_104 | net_2_105);
  assign net_2_105 = (net_2_106 | net_2_107);
  assign net_2_107 = ~(net_2_108 & net_2_109);
  assign net_2_109 = (net_2_110 | iq_instr1_fn_dih_i[18]);
  assign net_2_110 = (iq_instr1_fn_dih_i[19] | net_2_111);
  assign net_2_111 = ~(instr1_fp_write_is_s & net_2_112);
  assign net_2_112 = (iq_instr1_fn_dih_i[16] & net_2_113);
  assign net_2_108 = ~(net_2_31 | net_2_114);
  assign net_2_114 = (net_2_10 & net_2_115);
  assign net_2_115 = (iq_instr1_sideband_i[3] | net_2_116);
  assign net_2_116 = (iq_instr1_fn_dih_i[26] & net_2_117);
  assign net_2_31 = (net_2_118 & net_2_14);
  assign net_2_118 = (iq_instr1_fn_dih_i[19] & net_2_119);
  assign net_2_119 = (net_2_3 & net_2_113);
  assign net_2_113 = (net_2_120 & net_2_121);
  assign net_2_106 = (net_2_87 & net_2_123);
  assign net_2_123 = ~(net_2_124 & net_2_125);
  assign net_2_125 = (iq_instr1_fn_dih_i[11] | net_2_126);
  assign net_2_126 = ~(net_2_127 & iq_instr1_fn_dih_i[8]);
  assign net_2_127 = ~(net_2_128 & net_2_129);
  assign net_2_129 = (net_2_130 | iq_instr1_fn_dih_i[20]);
  assign net_2_128 = (net_2_14 | iq_instr1_fn_dih_i[10]);
  assign net_2_124 = (net_2_131 & net_2_132);
  assign net_2_132 = (net_2_133 | net_2_134);
  assign net_2_134 = ~(iq_instr1_fn_dih_i[21] & net_2_14);
  assign net_2_133 = (iq_instr1_fn_dih_i[20] & net_2_135);
  assign net_2_135 = (iq_instr1_fn_dih_i[19] | net_2_136);
  assign net_2_136 = (net_2_137 | iq_instr1_fn_dih_i[28]);
  assign net_2_131 = (iq_instr1_fn_dih_i[9] | net_2_138);
  assign net_2_138 = ~(net_2_130 & net_2_139);
  assign net_2_139 = (iq_instr1_fn_dih_i[10] & net_2_140);
  assign net_2_130 = (iq_instr1_fn_dih_i[21] | net_2_141);
  assign net_2_104 = ~(net_2_142 & net_2_143);
  assign net_2_143 = ~(net_2_144 & net_2_145);
  assign net_2_145 = (iq_instr1_fn_dih_i[10] & iq_instr1_fn_dih_i[4]);
  assign net_2_144 = ~(net_2_146 & net_2_147);
  assign net_2_147 = ~(net_2_148 & iq_instr1_fn_dih_i[24]);
  assign net_2_148 = (net_2_67 & net_2_50);
  assign net_2_50 = (iq_instr1_fn_dih_i[20] & net_2_12);
  assign net_2_146 = ~(iq_instr1_fn_dih_i[11] & net_2_149);
  assign net_2_142 = (net_2_150 & net_2_151);
  assign net_2_151 = ~(net_2_47 & iq_instr1_fn_dih_i[24]);
  assign net_2_47 = (iq_instr1_fn_dih_pdtype0_i & net_2_152);
  assign net_2_152 = ~(iq_instr1_fn_dih_i[10] | net_2_2);
  assign net_2_67 = (iq_instr1_fn_dih_i[23] & iq_instr1_fn_dih_i[28]);
  assign net_2_150 = (net_2_122 | net_2_153);
  assign net_2_102 = ~(iq_instr1_fn_dih_i[10] | net_2_154);
  assign net_2_154 = ~(net_2_155 & iq_instr1_fn_dih_i[8]);
  assign net_2_155 = (net_2_156 | net_2_157);
  assign net_2_157 = ~(iq_instr1_fn_dih_i[19] | net_2_158);
  assign net_2_158 = ~(net_2_89 & net_2_159);
  assign net_2_159 = (net_2_10 & net_2_9);
  assign net_2_156 = ~(net_2_160 | net_2_161);
  assign net_2_161 = (iq_instr1_fn_dih_i[23] | iq_instr1_fn_dih_i[9]);
  assign instr1_fp_reads[0] = (net_2_162 | net_2_163);
  assign net_2_163 = ~(net_2_164 & net_2_165);
  assign net_2_165 = (net_2_153 | iq_instr1_fn_dih_pdtype0_i);
  assign net_2_153 = ~(net_2_9 & net_2_94);
  assign net_2_164 = ~(net_2_166 | instr1_fp_reads[3]);
  assign instr1_fp_reads[3] = ~(net_2_8 | net_2_167);
  assign net_2_166 = (net_2_8 & net_2_168);
  assign net_2_168 = (net_2_169 | net_2_170);
  assign net_2_170 = ~(net_2_80 | iq_instr1_sideband_i[2]);
  assign net_2_169 = (net_2_171 | net_2_25);
  assign net_2_25 = (net_2_172 & net_2_173);
  assign net_2_173 = (iq_instr1_fn_dih_i[22] & iq_instr1_fn_dih_i[8]);
  assign net_2_172 = (net_2_68 & iq_instr1_fn_dih_i[4]);
  assign net_2_68 = (iq_instr1_fn_dih_i[25] & iq_instr1_fn_dih_i[26]);
  assign net_2_171 = (iq_instr1_fn_dih_i[8] & net_2_174);
  assign net_2_174 = (net_2_175 & net_2_176);
  assign instr1_fp_read_is_s = (iq_instr1_fn_dih_i[25] & iq_instr1_sideband_i[1]);
  assign instr1_fp_read_d_size[1] = (iq_instr1_fn_dih_i[23] & net_2_177);
  assign net_2_177 = (net_2_178 | net_2_179);
  assign net_2_179 = (iq_instr1_fn_dih_i[28] & net_2_180);
  assign net_2_180 = (iq_instr1_fn_dih_i[17] & net_2_181);
  assign net_2_181 = ~(iq_instr1_fn_dih_i[10] | net_2_182);
  assign net_2_182 = ~(iq_instr1_fn_dih_i[24] & net_2_183);
  assign net_2_183 = ~(iq_instr1_fn_dih_i[4] | iq_instr1_fn_dih_i[16]);
  assign net_2_178 = (net_2_184 & net_2_12);
  assign instr1_fp_need_f1 = ~(net_2_185 & net_2_186);
  assign net_2_186 = (net_2_187 & net_2_188);
  assign net_2_188 = ~(net_2_189 | net_2_74);
  assign net_2_74 = (net_2_190 | net_2_191);
  assign net_2_191 = ~(iq_instr1_fn_dih_pdtype0_i | net_2_192);
  assign net_2_192 = (net_2_193 & net_2_194);
  assign net_2_194 = ~(iq_instr1_fn_dih_i[23] & net_2_195);
  assign net_2_195 = ~(net_2_29 | iq_instr1_fn_dih_i[10]);
  assign net_2_29 = (iq_instr1_fn_dih_i[8] | net_2_78);
  assign net_2_78 = (iq_instr1_fn_dih_i[11] | net_2_9);
  assign net_2_193 = ~(net_2_196 & net_2_94);
  assign net_2_196 = ~(iq_instr1_fn_dih_i[21] & net_2_197);
  assign net_2_197 = ~(iq_instr1_fn_dih_i[19] & net_2_198);
  assign net_2_190 = ~(iq_instr1_sideband_i[3] | net_2_199);
  assign net_2_199 = ~(net_2_94 & net_2_149);
  assign net_2_149 = ~(iq_instr1_fn_dih_i[23] | iq_instr1_fn_dih_i[28]);
  assign net_2_94 = ~(iq_instr1_fn_dih_i[24] | iq_instr1_fn_dih_i[4]);
  assign net_2_189 = (iq_instr1_fn_dih_i[20] & net_2_200);
  assign net_2_200 = ~(net_2_201 & net_2_202);
  assign net_2_202 = (net_2_100 | iq_instr1_fn_dih_pdtype0_i);
  assign net_2_100 = (iq_instr1_fn_dih_i[7] | net_2_5);
  assign net_2_201 = (net_2_203 & net_2_204);
  assign net_2_204 = (net_2_205 & net_2_206);
  assign net_2_206 = ~(net_2_121 | net_2_207);
  assign net_2_207 = (iq_instr1_fn_dih_i[16] & iq_instr1_fn_dih_i[10]);
  assign net_2_121 = (iq_instr1_fn_dih_i[23] & iq_instr1_fn_dih_i[17]);
  assign net_2_205 = ~(net_2_120 & net_2_208);
  assign net_2_208 = (iq_instr1_fn_dih_i[16] | iq_instr1_fn_dih_i[7]);
  assign net_2_120 = (iq_instr1_fn_dih_i[6] & iq_instr1_fn_dih_i[21]);
  assign net_2_203 = ~(iq_instr1_fn_dih_i[9] & net_2_209);
  assign net_2_209 = (iq_instr1_fn_dih_i[22] & net_2_184);
  assign net_2_187 = (net_2_210 & net_2_211);
  assign net_2_211 = ~(net_2_176 & iq_instr1_fn_dih_i[21]);
  assign net_2_210 = (net_2_212 & net_2_213);
  assign net_2_213 = (net_2_167 & net_2_214);
  assign net_2_214 = ~(net_2_215 & net_2_216);
  assign net_2_216 = (net_2_217 & net_2_218);
  assign net_2_215 = (iq_instr1_fn_dih_i[18] & iq_instr1_fn_dih_i[10]);
  assign net_2_167 = (iq_instr1_fn_dih_i[24] | net_2_219);
  assign net_2_219 = (net_2_1 | net_2_80);
  assign net_2_212 = (net_2_20 & net_2_220);
  assign net_2_220 = (net_2_221 | iq_instr1_fn_dih_i[8]);
  assign net_2_221 = ~(iq_instr1_fn_dih_i[26] & net_2_222);
  assign net_2_222 = (iq_instr1_fn_dih_i[28] & net_2_184);
  assign net_2_20 = ~(iq_instr1_fn_dih_i[11] & net_2_223);
  assign net_2_223 = (net_2_224 & net_2_225);
  assign net_2_225 = (iq_instr1_fn_dih_i[26] & net_2_57);
  assign net_2_224 = (net_2_175 & iq_instr1_fn_dih_i[8]);
  assign net_2_175 = ~(net_2_13 | iq_instr1_fn_dih_i[22]);
  assign net_2_185 = (net_2_226 & net_2_227);
  assign net_2_227 = (net_2_228 | iq_instr1_fn_dih_i[23]);
  assign net_2_228 = (net_2_229 & net_2_230);
  assign net_2_230 = ~(net_2_218 & net_2_231);
  assign net_2_231 = ~(net_2_232 & net_2_233);
  assign net_2_233 = (net_2_160 | iq_instr1_fn_dih_i[10]);
  assign net_2_160 = ~(net_2_234 | net_2_235);
  assign net_2_235 = (net_2_217 & iq_instr1_fn_dih_i[11]);
  assign net_2_234 = (net_2_140 & net_2_236);
  assign net_2_236 = (iq_instr1_fn_dih_i[20] | net_2_237);
  assign net_2_237 = (iq_instr1_fn_dih_i[21] & iq_instr1_fn_dih_i[24]);
  assign net_2_140 = (iq_instr1_fn_dih_i[28] & iq_instr1_fn_dih_i[4]);
  assign net_2_232 = ~(net_2_184 & net_2_4);
  assign net_2_184 = (iq_instr1_fn_dih_i[4] & iq_instr1_fn_dih_i[11]);
  assign net_2_218 = (iq_instr1_fn_dih_i[8] & net_2_12);
  assign net_2_229 = (net_2_54 & net_2_238);
  assign net_2_238 = (net_2_239 & net_2_240);
  assign net_2_240 = (net_2_241 | iq_instr1_sideband_i[3]);
  assign net_2_241 = ~(iq_instr1_fn_dih_i[10] | iq_instr1_fn_dih_pdtype0_i);
  assign net_2_239 = (net_2_242 | iq_instr1_fn_dih_pdtype0_i);
  assign net_2_242 = ~(iq_instr1_fn_dih_i[25] & net_2_66);
  assign net_2_54 = ~(iq_instr1_fn_dih_i[25] & net_2_243);
  assign net_2_243 = (net_2_10 & net_2_176);
  assign net_2_176 = (net_2_4 & net_2_57);
  assign net_2_226 = ~(net_2_60 | net_2_162);
  assign net_2_162 = (net_2_244 | net_2_245);
  assign net_2_245 = (net_2_246 | net_2_247);
  assign net_2_247 = (net_2_248 & net_2_249);
  assign net_2_249 = (iq_instr1_fn_dih_i[8] | iq_instr1_fn_dih_aarch64_i);
  assign net_2_248 = (iq_instr1_fn_dih_i[20] & net_2_56);
  assign net_2_56 = (net_2_57 & net_2_87);
  assign net_2_57 = ~(iq_instr1_fn_dih_i[24] | net_2_14);
  assign net_2_246 = (net_2_250 & net_2_251);
  assign net_2_251 = ~(iq_instr1_fn_dih_i[23] | iq_instr1_fn_dih_pdtype0_i);
  assign net_2_250 = ~(iq_instr1_fn_dih_i[6] | net_2_252);
  assign net_2_252 = ~(iq_instr1_fn_dih_i[9] & net_2_253);
  assign net_2_253 = (iq_instr1_fn_dih_i[25] & iq_instr1_fn_dih_i[8]);
  assign net_2_244 = (iq_instr1_fn_dih_i[23] & net_2_254);
  assign net_2_254 = ~(iq_instr1_fn_dih_i[4] | net_2_255);
  assign net_2_255 = (net_2_256 & net_2_257);
  assign net_2_257 = ~(net_2_66 & iq_instr1_fn_dih_i[28]);
  assign net_2_66 = (iq_instr1_fn_dih_i[24] & net_2_258);
  assign net_2_258 = (iq_instr1_fn_dih_i[11] & iq_instr1_fn_dih_i[9]);
  assign net_2_256 = (net_2_259 & net_2_260);
  assign net_2_260 = (net_2_122 | net_2_261);
  assign net_2_122 = ~(iq_instr1_fn_dih_i[27] & net_2_4);
  assign net_2_259 = ~(net_2_88 & net_2_1);
  assign net_2_88 = (iq_instr1_fn_dih_i[21] & net_2_10);
  assign net_2_60 = ~(net_2_262 & net_2_263);
  assign net_2_263 = ~(iq_instr1_fn_dih_i[21] & net_2_264);
  assign net_2_264 = (net_2_265 | net_2_266);
  assign net_2_266 = ~(net_2_267 & net_2_268);
  assign net_2_268 = ~(net_2_269 & iq_instr1_fn_dih_i[10]);
  assign net_2_269 = ~(iq_instr1_fn_dih_i[7] | net_2_80);
  assign net_2_80 = (iq_instr1_sideband_i[3] | net_2_6);
  assign net_2_267 = ~(net_2_270 & net_2_217);
  assign net_2_217 = (net_2_14 & net_2_1);
  assign net_2_270 = ~(iq_instr1_fn_dih_i[16] | net_2_137);
  assign net_2_137 = ~(net_2_198 & iq_instr1_fn_dih_i[18]);
  assign net_2_198 = (iq_instr1_fn_dih_i[6] & net_2_11);
  assign net_2_265 = (net_2_87 & net_2_271);
  assign net_2_271 = ~(iq_instr1_fn_dih_i[10] | iq_instr1_fn_dih_i[9]);
  assign net_2_87 = (net_2_1 & iq_instr1_fn_dih_i[23]);
  assign net_2_262 = ~(iq_instr1_fn_dih_i[4] & net_2_272);
  assign net_2_272 = (net_2_89 & net_2_141);
  assign net_2_141 = (iq_instr1_fn_dih_i[19] | iq_instr1_fn_dih_i[7]);
  assign net_2_89 = ~(net_2_8 | net_2_261);
  assign net_2_261 = ~(iq_instr1_fn_dih_i[24] & iq_instr1_fn_dih_i[25]);
  assign fn_dcu_valid_instr1 = ~(net_2_41 & net_2_38);
  assign net_2_38 = (net_2_1 | iq_instr1_fn_dih_i[25]);
  assign net_2_41 = ~(iq_instr1_sideband_i[3] | net_2_117);
  assign net_2_117 = (iq_instr1_fn_dih_i[24] & net_2_6);
  assign net_2_273 = ~(iq_instr1_fn_dih_pdtype0_i | net_2_78);
  assign net_2_274 = (iq_instr1_fn_dih_i[16] & net_2_273);
  assign net_2_275 = ~(net_2_8 & iq_instr1_fn_dih_i[24]);
  assign net_2_276 = ~(net_2_80 | net_2_275);
  assign net_2_21 = (net_2_276 | net_2_274);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Start Slot 0 NEON automatically generated logic
  // ------------------------------------------------------

  wire    net_3_1, net_3_2, net_3_3,
         net_3_4, net_3_5, net_3_6, net_3_7, net_3_8, net_3_9, net_3_10, net_3_11, net_3_12,
         net_3_13, net_3_14, net_3_15, net_3_16, net_3_17, net_3_18, net_3_19, net_3_20,
         net_3_21, net_3_22, net_3_23, net_3_24, net_3_25, net_3_26, net_3_27, net_3_28,
         net_3_29, net_3_30, net_3_31, net_3_32, net_3_33, net_3_34, net_3_35, net_3_36,
         net_3_37, net_3_38, net_3_39, net_3_40, net_3_41, net_3_42, net_3_43, net_3_44,
         net_3_45, net_3_46, net_3_47, net_3_48, net_3_49, net_3_50, net_3_51, net_3_52,
         net_3_53, net_3_54, net_3_55, net_3_56, net_3_57, net_3_58, net_3_59, net_3_60,
         net_3_61, net_3_62, net_3_63, net_3_64, net_3_65, net_3_66, net_3_67, net_3_68,
         net_3_69, net_3_70, net_3_71, net_3_72, net_3_73, net_3_74, net_3_75, net_3_76,
         net_3_77, net_3_78, net_3_79, net_3_80, net_3_81, net_3_82, net_3_83, net_3_84,
         net_3_85, net_3_86, net_3_87, net_3_88, net_3_89, net_3_90, net_3_91, net_3_92,
         net_3_93, net_3_94, net_3_95, net_3_96, net_3_97, net_3_98, net_3_99, net_3_100,
         net_3_101, net_3_102, net_3_103, net_3_104, net_3_105, net_3_106, net_3_107,
         net_3_108, net_3_109, net_3_110, net_3_111, net_3_112, net_3_113, net_3_114,
         net_3_115, net_3_116, net_3_117, net_3_118, net_3_119, net_3_120, net_3_121,
         net_3_122, net_3_123, net_3_124, net_3_125, net_3_126, net_3_127, net_3_128,
         net_3_129, net_3_130, net_3_131, net_3_132, net_3_133, net_3_134, net_3_135,
         net_3_136, net_3_137, net_3_138, net_3_139, net_3_140, net_3_141, net_3_142,
         net_3_143, net_3_144, net_3_145, net_3_146, net_3_147, net_3_148, net_3_149,
         net_3_150, net_3_151, net_3_152, net_3_153, net_3_154, net_3_155, net_3_156,
         net_3_157, net_3_158, net_3_159, net_3_160, net_3_161, net_3_162, net_3_163,
         net_3_164, net_3_165, net_3_166, net_3_167, net_3_168, net_3_169, net_3_170,
         net_3_171, net_3_172, net_3_173, net_3_174, net_3_175, net_3_176, net_3_177,
         net_3_178, net_3_179, net_3_180, net_3_181, net_3_182, net_3_183, net_3_184,
         net_3_185, net_3_186, net_3_187, net_3_188, net_3_189, net_3_190, net_3_191,
         net_3_192, net_3_193, net_3_194, net_3_195, net_3_196, net_3_197, net_3_198,
         net_3_199, net_3_200, net_3_201, net_3_202, net_3_203, net_3_204, net_3_205,
         net_3_206, net_3_207, net_3_208, net_3_209, net_3_210, net_3_211, net_3_212,
         net_3_213, net_3_214, net_3_215, net_3_216, net_3_217, net_3_218, net_3_219,
         net_3_220, net_3_221, net_3_222, net_3_223, net_3_224, net_3_225, net_3_226,
         net_3_227, net_3_228, net_3_229, net_3_230, net_3_231, net_3_232, net_3_233,
         net_3_234, net_3_235, net_3_236, net_3_237, net_3_238, net_3_239, net_3_240,
         net_3_241, net_3_242, net_3_243, net_3_244, net_3_245, net_3_246, net_3_247,
         net_3_248, net_3_249, net_3_250, net_3_251, net_3_252, net_3_253, net_3_254,
         net_3_255, net_3_256, net_3_257, net_3_258, net_3_259, net_3_260, net_3_261,
         net_3_262, net_3_263, net_3_264, net_3_265, net_3_266, net_3_267, net_3_268,
         net_3_269, net_3_270, net_3_271, net_3_272, net_3_273, net_3_274, net_3_275,
         net_3_276, net_3_277, net_3_278, net_3_279, net_3_280, net_3_281, net_3_282,
         net_3_283, net_3_284, net_3_285, net_3_286, net_3_287, net_3_288, net_3_289,
         net_3_290, net_3_291, net_3_292, net_3_293, net_3_294, net_3_295, net_3_296,
         net_3_297, net_3_298, net_3_299, net_3_300, net_3_301, net_3_302, net_3_303,
         net_3_304, net_3_305, net_3_306, net_3_307, net_3_308, net_3_309, net_3_310,
         net_3_311, net_3_312, net_3_313, net_3_314, net_3_315, net_3_316, net_3_317,
         net_3_318, net_3_319, net_3_320, net_3_321, net_3_322, net_3_323, net_3_324,
         net_3_325, net_3_326, net_3_327, net_3_328, net_3_329, net_3_330, net_3_331,
         net_3_332, net_3_333, net_3_334, net_3_335, net_3_336, net_3_337, net_3_338,
         net_3_339, net_3_340, net_3_341, net_3_342, net_3_343, net_3_344, net_3_345,
         net_3_346, net_3_347, net_3_348, net_3_349, net_3_350, net_3_351, net_3_352,
         net_3_353, net_3_354, net_3_355, net_3_356, net_3_357, net_3_358, net_3_359,
         net_3_360, net_3_361, net_3_362, net_3_363, net_3_364, net_3_365, net_3_366,
         net_3_367, net_3_368, net_3_369, net_3_370, net_3_371, net_3_372, net_3_373,
         net_3_374, net_3_375, net_3_376, net_3_377, net_3_378, net_3_379, net_3_380,
         net_3_381, net_3_382, net_3_383, net_3_384, net_3_385, net_3_386, net_3_387,
         net_3_388, net_3_389, net_3_390, net_3_391, net_3_392, net_3_393, net_3_394,
         net_3_395, net_3_396, net_3_397, net_3_398, net_3_399, net_3_400, net_3_401,
         net_3_402, net_3_403, net_3_404, net_3_405, net_3_406, net_3_407, net_3_408,
         net_3_409, net_3_410, net_3_411, net_3_412, net_3_413, net_3_414, net_3_415,
         net_3_416, net_3_417, net_3_418, net_3_419, net_3_420, net_3_421, net_3_422,
         net_3_423, net_3_424, net_3_425, net_3_426, net_3_427, net_3_428, net_3_429,
         net_3_430, net_3_431, net_3_432, net_3_433, net_3_434, net_3_435, net_3_436,
         net_3_437, net_3_438, net_3_439, net_3_440, net_3_441, net_3_442, net_3_443,
         net_3_444, net_3_445, net_3_446, net_3_447, net_3_448, net_3_449, net_3_450,
         net_3_451, net_3_452, net_3_453, net_3_454, net_3_455, net_3_456, net_3_457,
         net_3_458, net_3_459, net_3_460, net_3_461, net_3_462, net_3_463, net_3_464,
         net_3_465, net_3_466, net_3_467, net_3_468, net_3_469, net_3_470, net_3_471,
         net_3_472, net_3_473, net_3_474, net_3_475, net_3_476, net_3_477, net_3_478,
         net_3_479, net_3_480, net_3_481, net_3_482, net_3_483, net_3_484, net_3_485,
         net_3_486, net_3_487, net_3_488, net_3_489, net_3_490, net_3_491, net_3_492,
         net_3_493, net_3_494, net_3_495, net_3_496, net_3_497, net_3_498, net_3_499,
         net_3_500, net_3_501, net_3_502, net_3_503, net_3_504;

  assign instr0_fp_write_is_s = iq_instr0_sideband_i[0];
  assign instr0_fp_read_d_size[0] = instr0_fp_read_d_size[1];
  assign net_3_1 = ~net_3_254;
  assign net_3_2 = ~iq_instr0_sideband_i[3];
  assign net_3_3 = ~iq_instr0_sideband_i[2];
  assign net_3_4 = ~iq_instr0_fn_dih_pdtype0_i;
  assign net_3_5 = ~net_3_117;
  assign net_3_6 = ~iq_instr0_fn_dih_i[27];
  assign net_3_7 = ~net_3_164;
  assign net_3_8 = ~net_3_43;
  assign net_3_9 = ~iq_instr0_fn_dih_i[24];
  assign net_3_10 = ~net_3_142;
  assign net_3_11 = ~net_3_471;
  assign net_3_12 = ~iq_instr0_fn_dih_i[23];
  assign net_3_13 = ~iq_instr0_fn_dih_i[21];
  assign net_3_14 = ~net_3_57;
  assign net_3_15 = ~iq_instr0_fn_dih_i[20];
  assign net_3_16 = ~iq_instr0_fn_dih_i[17];
  assign net_3_17 = ~net_3_128;
  assign net_3_18 = ~iq_instr0_fn_dih_i[11];
  assign net_3_19 = ~iq_instr0_fn_dih_i[10];
  assign net_3_20 = ~iq_instr0_fn_dih_i[9];
  assign net_3_21 = ~net_3_50;
  assign net_3_22 = ~iq_instr0_fn_dih_i[6];
  assign net_3_23 = ~iq_instr0_fn_dih_i[4];
  assign instr0_fp_writes[2] = (net_3_24 | net_3_25);
  assign net_3_25 = (net_3_26 | net_3_27);
  assign net_3_27 = (net_3_4 & net_3_28);
  assign net_3_28 = ~(net_3_29 & net_3_30);
  assign net_3_30 = ~(net_3_31 & net_3_32);
  assign net_3_26 = (net_3_6 & net_3_33);
  assign net_3_33 = (iq_instr0_fn_dih_i[20] & iq_instr0_fn_dih_i[26]);
  assign instr0_fp_writes[1] = (net_3_34 | net_3_35);
  assign net_3_35 = (net_3_36 | net_3_37);
  assign net_3_37 = ~(net_3_38 & net_3_39);
  assign net_3_39 = (net_3_40 & net_3_41);
  assign net_3_41 = (net_3_1 | net_3_42);
  assign net_3_42 = (net_3_43 & net_3_12);
  assign net_3_36 = (net_3_4 & net_3_44);
  assign net_3_44 = (net_3_45 | net_3_46);
  assign net_3_46 = ~(net_3_10 | net_3_47);
  assign net_3_45 = ~(net_3_48 & net_3_49);
  assign net_3_49 = ~(net_3_50 & net_3_51);
  assign net_3_48 = (net_3_52 & net_3_53);
  assign net_3_52 = (net_3_54 & net_3_55);
  assign net_3_55 = (iq_instr0_fn_dih_i[11] | net_3_56);
  assign net_3_56 = (net_3_13 | net_3_19);
  assign net_3_54 = ~(net_3_57 & net_3_58);
  assign net_3_34 = (net_3_59 | net_3_60);
  assign net_3_60 = ~(net_3_61 & net_3_62);
  assign net_3_62 = ~(iq_instr0_fn_dih_i[20] & net_3_63);
  assign net_3_63 = (iq_instr0_sideband_i[3] & iq_instr0_fn_dih_i[28]);
  assign net_3_59 = (net_3_64 & net_3_65);
  assign net_3_65 = (iq_instr0_fn_dih_i[27] & iq_instr0_fn_dih_i[24]);
  assign net_3_64 = (net_3_66 & net_3_67);
  assign net_3_67 = (iq_instr0_fn_dih_i[11] | net_3_68);
  assign net_3_68 = ~(net_3_20 | iq_instr0_fn_dih_i[8]);
  assign instr0_fp_write_d_size[1] = ~(net_3_69 & net_3_70);
  assign instr0_fp_write_d_size[0] = ~(net_3_69 & net_3_71);
  assign net_3_71 = ~(iq_instr0_fn_dih_i[21] & net_3_72);
  assign net_3_69 = (net_3_73 & net_3_74);
  assign net_3_74 = (net_3_22 | net_3_75);
  assign net_3_75 = ~(net_3_76 & net_3_20);
  assign net_3_73 = (net_3_77 | iq_instr0_fn_dih_i[23]);
  assign net_3_77 = ~(net_3_78 & net_3_79);
  assign instr0_fp_uses_pipe1 = ~(net_3_80 & net_3_81);
  assign net_3_81 = (net_3_82 & net_3_83);
  assign net_3_83 = ~(iq_instr0_fn_dih_i[24] & net_3_84);
  assign net_3_84 = ~(net_3_85 & net_3_86);
  assign net_3_86 = ~(net_3_87 & net_3_88);
  assign net_3_88 = (net_3_89 | net_3_90);
  assign net_3_89 = ~(net_3_91 | iq_instr0_fn_dih_i[8]);
  assign net_3_91 = (net_3_92 | net_3_93);
  assign net_3_92 = (net_3_94 | iq_instr0_fn_dih_i[11]);
  assign net_3_94 = (net_3_16 | net_3_14);
  assign net_3_85 = ~(net_3_95 & net_3_22);
  assign net_3_95 = (net_3_96 & net_3_32);
  assign net_3_32 = (iq_instr0_fn_dih_i[17] & net_3_97);
  assign net_3_97 = ~(iq_instr0_fn_dih_i[7] | net_3_5);
  assign net_3_82 = ~(net_3_4 & net_3_98);
  assign net_3_98 = ~(net_3_99 & net_3_100);
  assign net_3_100 = (net_3_101 & net_3_102);
  assign net_3_102 = (net_3_103 & net_3_104);
  assign net_3_104 = (net_3_105 & net_3_106);
  assign net_3_106 = (iq_instr0_fn_dih_i[8] | net_3_29);
  assign net_3_29 = ~(net_3_107 & net_3_15);
  assign net_3_105 = (iq_instr0_fn_dih_i[25] | net_3_108);
  assign net_3_108 = (net_3_13 | net_3_109);
  assign net_3_103 = (net_3_110 & net_3_111);
  assign net_3_111 = ~(net_3_112 & net_3_51);
  assign net_3_112 = (iq_instr0_fn_dih_aarch64_i & net_3_113);
  assign net_3_113 = (iq_instr0_fn_dih_i[24] & net_3_87);
  assign net_3_110 = ~(net_3_114 & iq_instr0_fn_dih_i[7]);
  assign net_3_101 = ~(iq_instr0_fn_dih_i[9] & net_3_115);
  assign net_3_115 = (net_3_116 | net_3_114);
  assign net_3_114 = (net_3_117 & net_3_31);
  assign net_3_116 = ~(net_3_118 & net_3_119);
  assign net_3_119 = (net_3_120 & net_3_121);
  assign net_3_121 = ~(net_3_122 & net_3_123);
  assign net_3_123 = ~(instr0_fn_sf_bit | net_3_17);
  assign net_3_120 = (iq_instr0_fn_dih_i[8] | net_3_124);
  assign net_3_124 = (net_3_125 & net_3_126);
  assign net_3_126 = ~(net_3_90 & net_3_127);
  assign net_3_127 = (net_3_128 | net_3_129);
  assign net_3_129 = (iq_instr0_fn_dih_i[24] & net_3_130);
  assign net_3_130 = (net_3_131 & iq_instr0_fn_dih_i[23]);
  assign net_3_125 = (iq_instr0_fn_dih_i[4] | net_3_132);
  assign net_3_132 = ~(iq_instr0_fn_dih_i[20] & net_3_133);
  assign net_3_118 = ~(net_3_134 & net_3_135);
  assign net_3_135 = ~(net_3_136 & net_3_137);
  assign net_3_137 = (iq_instr0_fn_dih_i[21] | iq_instr0_fn_dih_aarch64_i);
  assign net_3_136 = ~(iq_instr0_fn_dih_i[8] & net_3_138);
  assign net_3_138 = ~(iq_instr0_fn_dih_i[28] | instr0_fn_sf_bit);
  assign net_3_134 = (net_3_8 & iq_instr0_fn_dih_i[6]);
  assign net_3_99 = (net_3_139 & net_3_140);
  assign net_3_140 = ~(net_3_141 & net_3_22);
  assign net_3_141 = (net_3_142 & net_3_143);
  assign net_3_143 = ~(net_3_144 & net_3_145);
  assign net_3_145 = ~(net_3_146 & net_3_147);
  assign net_3_144 = (iq_instr0_fn_dih_i[8] | net_3_148);
  assign net_3_148 = (net_3_149 | iq_instr0_fn_dih_i[28]);
  assign net_3_149 = (iq_instr0_fn_dih_i[21] | iq_instr0_fn_dih_i[9]);
  assign net_3_139 = ~(net_3_150 & iq_instr0_fn_dih_i[20]);
  assign net_3_150 = (iq_instr0_fn_dih_i[6] & net_3_151);
  assign net_3_151 = ~(net_3_152 & net_3_153);
  assign net_3_153 = (net_3_154 | net_3_155);
  assign net_3_152 = ~(net_3_18 & net_3_156);
  assign net_3_156 = (net_3_76 & iq_instr0_fn_dih_i[7]);
  assign net_3_80 = (net_3_157 & net_3_158);
  assign net_3_158 = (net_3_159 & net_3_160);
  assign net_3_160 = (iq_instr0_fn_dih_i[4] | net_3_161);
  assign net_3_161 = (net_3_162 & net_3_163);
  assign net_3_163 = ~(net_3_164 & net_3_165);
  assign net_3_165 = ~(net_3_166 & net_3_167);
  assign net_3_167 = ~(iq_instr0_fn_dih_i[28] & net_3_13);
  assign net_3_166 = ~(net_3_168 & net_3_15);
  assign net_3_168 = ~(iq_instr0_sideband_i[3] | net_3_169);
  assign net_3_162 = (net_3_170 | net_3_15);
  assign net_3_159 = ~(iq_instr0_fn_dih_i[6] & net_3_171);
  assign net_3_171 = ~(net_3_172 & net_3_173);
  assign net_3_173 = (iq_instr0_sideband_i[3] | net_3_174);
  assign net_3_172 = ~(net_3_175 | net_3_176);
  assign net_3_176 = (net_3_177 | net_3_178);
  assign net_3_178 = (net_3_179 & net_3_180);
  assign net_3_180 = ~(net_3_181 & net_3_182);
  assign net_3_182 = (net_3_14 | net_3_6);
  assign net_3_181 = ~(net_3_183 & iq_instr0_fn_dih_i[28]);
  assign net_3_183 = ~(iq_instr0_sideband_i[3] | net_3_184);
  assign net_3_179 = ~(iq_instr0_fn_dih_i[11] | net_3_154);
  assign net_3_157 = ~(net_3_164 & net_3_185);
  assign net_3_185 = ~(net_3_186 & net_3_187);
  assign net_3_187 = ~(iq_instr0_fn_dih_i[4] & net_3_188);
  assign net_3_188 = (iq_instr0_fn_dih_i[9] & net_3_189);
  assign net_3_189 = (net_3_190 | net_3_51);
  assign net_3_190 = (iq_instr0_fn_dih_i[6] | net_3_191);
  assign net_3_191 = (iq_instr0_fn_dih_i[19] & net_3_131);
  assign net_3_131 = (iq_instr0_fn_dih_i[11] & net_3_19);
  assign net_3_186 = (net_3_21 | net_3_192);
  assign net_3_192 = ~(net_3_147 & net_3_193);
  assign net_3_193 = ~(instr0_fn_sf_bit | net_3_6);
  assign net_3_147 = ~(iq_instr0_fn_dih_i[20] & iq_instr0_fn_dih_i[21]);
  assign instr0_fp_reads[3] = ~(net_3_12 | net_3_194);
  assign instr0_fp_reads[2] = ~(net_3_195 & net_3_196);
  assign net_3_196 = (iq_instr0_fn_dih_pdtype0_i | net_3_197);
  assign net_3_197 = (net_3_198 & net_3_199);
  assign net_3_199 = (net_3_53 & net_3_200);
  assign net_3_53 = (net_3_201 & net_3_202);
  assign net_3_202 = (net_3_203 | iq_instr0_fn_dih_i[4]);
  assign net_3_203 = ~(net_3_204 | net_3_205);
  assign net_3_205 = ~(iq_instr0_fn_dih_i[28] | net_3_206);
  assign net_3_206 = ~(iq_instr0_fn_dih_i[20] & net_3_164);
  assign net_3_204 = (net_3_207 | net_3_208);
  assign net_3_208 = (net_3_209 & net_3_210);
  assign net_3_210 = (net_3_211 | net_3_212);
  assign net_3_212 = ~(iq_instr0_fn_dih_i[17] | iq_instr0_fn_dih_i[18]);
  assign net_3_211 = ~(iq_instr0_fn_dih_i[19] | net_3_16);
  assign net_3_207 = (net_3_146 & net_3_213);
  assign net_3_213 = (net_3_214 | iq_instr0_fn_dih_i[16]);
  assign net_3_201 = (net_3_215 & net_3_216);
  assign net_3_216 = ~(iq_instr0_fn_dih_i[25] & net_3_217);
  assign net_3_215 = (net_3_218 & net_3_219);
  assign net_3_219 = (net_3_220 & net_3_221);
  assign net_3_221 = (net_3_222 | net_3_14);
  assign net_3_222 = ~(iq_instr0_fn_dih_i[10] & iq_instr0_fn_dih_i[23]);
  assign net_3_220 = (net_3_174 | iq_instr0_fn_dih_i[10]);
  assign net_3_174 = (iq_instr0_fn_dih_i[23] | net_3_43);
  assign net_3_198 = (net_3_223 & net_3_224);
  assign net_3_224 = ~(iq_instr0_fn_dih_i[21] & net_3_11);
  assign net_3_223 = (net_3_225 & net_3_226);
  assign net_3_226 = ~(iq_instr0_fn_dih_i[20] & net_3_107);
  assign net_3_107 = ~(iq_instr0_fn_dih_i[24] | iq_instr0_fn_dih_i[25]);
  assign net_3_225 = (net_3_227 & net_3_228);
  assign net_3_228 = (net_3_229 & net_3_230);
  assign net_3_230 = (iq_instr0_fn_dih_i[4] | net_3_47);
  assign net_3_47 = ~(net_3_19 & net_3_231);
  assign net_3_229 = (net_3_14 | net_3_232);
  assign net_3_232 = ~(net_3_58 | iq_instr0_fn_dih_i[4]);
  assign net_3_57 = (net_3_20 & iq_instr0_fn_dih_i[20]);
  assign net_3_227 = (net_3_233 | net_3_234);
  assign net_3_233 = ~(iq_instr0_fn_dih_i[20] | net_3_235);
  assign net_3_235 = (iq_instr0_fn_dih_i[25] & net_3_93);
  assign net_3_195 = ~(net_3_236 | net_3_237);
  assign net_3_237 = ~(net_3_238 & net_3_239);
  assign net_3_238 = (net_3_240 & net_3_241);
  assign net_3_241 = ~(net_3_242 & iq_instr0_fn_dih_i[26]);
  assign net_3_242 = ~(iq_instr0_sideband_i[3] | net_3_243);
  assign net_3_243 = ~(iq_instr0_fn_dih_pdtype0_i | net_3_244);
  assign net_3_244 = (net_3_122 & net_3_245);
  assign net_3_122 = (iq_instr0_fn_dih_i[10] & iq_instr0_fn_dih_i[20]);
  assign net_3_240 = (net_3_246 & net_3_247);
  assign net_3_247 = ~(iq_instr0_fn_dih_i[27] & net_3_248);
  assign net_3_248 = ~(net_3_155 | net_3_249);
  assign net_3_246 = (net_3_250 & net_3_251);
  assign net_3_251 = (net_3_170 | iq_instr0_fn_dih_i[20]);
  assign net_3_170 = (iq_instr0_fn_dih_i[23] | iq_instr0_fn_dih_i[27]);
  assign net_3_250 = (net_3_252 & net_3_253);
  assign net_3_252 = ~(net_3_8 & net_3_254);
  assign instr0_fp_reads[1] = (net_3_255 | net_3_256);
  assign net_3_256 = (net_3_257 | net_3_258);
  assign net_3_258 = (net_3_259 | net_3_260);
  assign net_3_260 = ~(net_3_261 & net_3_262);
  assign net_3_262 = ~(net_3_263 & net_3_264);
  assign net_3_264 = ~(net_3_265 & net_3_266);
  assign net_3_266 = ~(net_3_267 & net_3_23);
  assign net_3_265 = (net_3_19 | net_3_268);
  assign net_3_268 = ~(iq_instr0_fn_dih_i[27] & net_3_269);
  assign net_3_261 = ~(net_3_24 | net_3_270);
  assign net_3_270 = ~(net_3_253 & net_3_271);
  assign net_3_271 = (iq_instr0_sideband_i[2] | net_3_272);
  assign net_3_272 = (iq_instr0_fn_dih_i[25] | net_3_273);
  assign net_3_253 = (iq_instr0_fn_dih_i[4] | net_3_274);
  assign net_3_274 = (iq_instr0_fn_dih_i[27] | net_3_273);
  assign net_3_273 = ~(iq_instr0_fn_dih_i[26] & net_3_15);
  assign net_3_24 = (net_3_275 & net_3_276);
  assign net_3_276 = (net_3_277 & net_3_278);
  assign net_3_278 = (iq_instr0_fn_dih_i[24] & net_3_20);
  assign net_3_277 = (iq_instr0_fn_dih_i[17] & net_3_19);
  assign net_3_275 = (iq_instr0_fn_dih_i[7] & net_3_117);
  assign net_3_259 = (net_3_279 & net_3_12);
  assign net_3_257 = (net_3_280 | net_3_281);
  assign net_3_281 = ~(net_3_282 & net_3_283);
  assign net_3_283 = (net_3_284 | iq_instr0_fn_dih_i[19]);
  assign net_3_284 = (iq_instr0_fn_dih_i[18] | net_3_285);
  assign net_3_285 = ~(instr0_fp_write_is_s & net_3_286);
  assign net_3_286 = (iq_instr0_fn_dih_i[16] & net_3_287);
  assign net_3_282 = (net_3_288 & net_3_289);
  assign net_3_289 = ~(iq_instr0_fn_dih_i[28] & net_3_290);
  assign net_3_290 = (net_3_291 | net_3_292);
  assign net_3_292 = (iq_instr0_fn_dih_pdtype0_i & net_3_293);
  assign net_3_293 = (net_3_294 | net_3_295);
  assign net_3_295 = ~(iq_instr0_fn_dih_i[26] | iq_instr0_fn_dih_i[20]);
  assign net_3_294 = (iq_instr0_fn_dih_i[24] & net_3_58);
  assign net_3_291 = (net_3_296 & net_3_297);
  assign net_3_297 = (net_3_11 & iq_instr0_fn_dih_i[10]);
  assign net_3_296 = ~(net_3_298 & net_3_299);
  assign net_3_299 = ~(net_3_2 & net_3_93);
  assign net_3_298 = ~(iq_instr0_fn_dih_i[24] & iq_instr0_fn_dih_i[20]);
  assign net_3_288 = ~(net_3_31 & net_3_300);
  assign net_3_300 = (net_3_177 | net_3_301);
  assign net_3_301 = (net_3_175 & iq_instr0_fn_dih_i[25]);
  assign net_3_175 = (net_3_146 & net_3_302);
  assign net_3_146 = (iq_instr0_fn_dih_i[26] & net_3_18);
  assign net_3_177 = ~(iq_instr0_fn_dih_i[19] | net_3_303);
  assign net_3_303 = ~(net_3_304 & net_3_15);
  assign net_3_304 = ~(iq_instr0_fn_dih_i[21] | net_3_61);
  assign net_3_280 = (net_3_305 | net_3_306);
  assign net_3_306 = ~(net_3_38 & net_3_307);
  assign net_3_307 = (net_3_308 | iq_instr0_fn_dih_i[8]);
  assign net_3_308 = (net_3_5 | net_3_309);
  assign net_3_309 = ~(net_3_96 & net_3_310);
  assign net_3_310 = ~(iq_instr0_fn_dih_i[17] | net_3_9);
  assign net_3_117 = ~(iq_instr0_fn_dih_i[16] | net_3_311);
  assign net_3_311 = ~(iq_instr0_fn_dih_i[20] & net_3_312);
  assign net_3_38 = (net_3_313 & net_3_314);
  assign net_3_314 = ~(iq_instr0_fn_dih_i[4] & net_3_315);
  assign net_3_315 = (net_3_109 & net_3_316);
  assign net_3_109 = (net_3_214 & net_3_317);
  assign net_3_313 = (net_3_318 | net_3_319);
  assign net_3_319 = (net_3_15 | net_3_155);
  assign net_3_318 = (net_3_320 & net_3_321);
  assign net_3_321 = ~(iq_instr0_fn_dih_i[27] & net_3_267);
  assign net_3_320 = ~(net_3_322 & net_3_287);
  assign net_3_287 = (net_3_245 & net_3_323);
  assign net_3_245 = (iq_instr0_fn_dih_i[17] & iq_instr0_fn_dih_i[23]);
  assign net_3_322 = (iq_instr0_fn_dih_i[19] & net_3_4);
  assign net_3_305 = (net_3_324 & net_3_325);
  assign net_3_325 = (net_3_133 & net_3_51);
  assign net_3_133 = ~(iq_instr0_fn_dih_i[21] | net_3_7);
  assign net_3_324 = (net_3_326 & net_3_22);
  assign net_3_255 = (net_3_4 & net_3_327);
  assign net_3_327 = ~(net_3_328 & net_3_329);
  assign net_3_328 = (net_3_330 & net_3_331);
  assign net_3_331 = ~(iq_instr0_fn_dih_i[8] & net_3_332);
  assign net_3_332 = ~(iq_instr0_fn_dih_i[21] | net_3_333);
  assign net_3_333 = (net_3_334 & net_3_335);
  assign net_3_335 = ~(net_3_96 & net_3_336);
  assign net_3_336 = ~(iq_instr0_fn_dih_i[23] | iq_instr0_fn_dih_i[25]);
  assign net_3_334 = ~(net_3_231 & net_3_337);
  assign net_3_337 = ~(iq_instr0_fn_dih_i[11] | net_3_338);
  assign net_3_338 = (net_3_93 | net_3_12);
  assign net_3_330 = (net_3_339 & net_3_340);
  assign net_3_340 = (net_3_13 | net_3_341);
  assign net_3_341 = (net_3_342 & net_3_343);
  assign net_3_343 = (net_3_344 | net_3_10);
  assign net_3_344 = (net_3_345 & net_3_346);
  assign net_3_346 = (net_3_347 | iq_instr0_fn_dih_i[19]);
  assign net_3_345 = (net_3_348 | iq_instr0_fn_dih_i[20]);
  assign net_3_348 = (iq_instr0_fn_dih_i[24] & net_3_349);
  assign net_3_349 = (iq_instr0_fn_dih_i[10] | iq_instr0_fn_dih_i[6]);
  assign net_3_342 = ~(net_3_11 & net_3_76);
  assign net_3_76 = (iq_instr0_fn_dih_i[10] & iq_instr0_fn_dih_i[28]);
  assign net_3_339 = (net_3_350 & net_3_351);
  assign net_3_351 = (net_3_17 | iq_instr0_fn_dih_i[28]);
  assign net_3_128 = (iq_instr0_fn_dih_i[6] & net_3_18);
  assign net_3_350 = (net_3_200 | iq_instr0_fn_dih_i[4]);
  assign net_3_200 = ~(iq_instr0_fn_dih_i[24] & net_3_352);
  assign net_3_352 = (iq_instr0_fn_dih_i[6] & net_3_353);
  assign instr0_fp_reads[0] = ~(net_3_239 & net_3_354);
  assign net_3_354 = (net_3_355 & net_3_356);
  assign net_3_356 = (net_3_357 & net_3_358);
  assign net_3_357 = (net_3_359 & net_3_360);
  assign net_3_360 = ~(net_3_361 & iq_instr0_fn_dih_i[8]);
  assign net_3_361 = (net_3_362 & net_3_363);
  assign net_3_363 = ~(net_3_364 & net_3_365);
  assign net_3_365 = ~(iq_instr0_fn_dih_i[22] & iq_instr0_fn_dih_i[6]);
  assign net_3_364 = ~(iq_instr0_fn_dih_i[25] & iq_instr0_fn_dih_i[20]);
  assign net_3_359 = (net_3_366 | iq_instr0_fn_dih_i[23]);
  assign net_3_366 = ~(iq_instr0_fn_dih_i[25] & net_3_367);
  assign net_3_367 = ~(net_3_368 & net_3_369);
  assign net_3_369 = ~(net_3_370 & net_3_3);
  assign net_3_368 = ~(iq_instr0_fn_dih_i[8] & net_3_79);
  assign net_3_79 = (iq_instr0_sideband_i[2] & net_3_13);
  assign net_3_355 = (net_3_371 & net_3_40);
  assign net_3_371 = (net_3_372 & net_3_373);
  assign net_3_373 = (iq_instr0_fn_dih_pdtype0_i | net_3_374);
  assign net_3_374 = (net_3_375 | net_3_15);
  assign net_3_372 = ~(net_3_376 & iq_instr0_fn_dih_i[26]);
  assign net_3_376 = (iq_instr0_fn_dih_i[4] & net_3_377);
  assign net_3_377 = ~(net_3_378 & net_3_379);
  assign net_3_379 = ~(net_3_380 & net_3_381);
  assign net_3_381 = (net_3_326 & net_3_323);
  assign net_3_326 = (iq_instr0_fn_dih_i[9] & iq_instr0_fn_dih_i[27]);
  assign net_3_380 = (iq_instr0_fn_dih_i[5] & iq_instr0_fn_dih_i[8]);
  assign net_3_378 = (iq_instr0_fn_dih_i[24] | net_3_382);
  assign net_3_382 = ~(net_3_383 & net_3_384);
  assign net_3_384 = ~(iq_instr0_fn_dih_i[22] | net_3_12);
  assign net_3_239 = (net_3_385 & net_3_386);
  assign net_3_386 = (net_3_387 | net_3_388);
  assign net_3_387 = (net_3_389 & net_3_390);
  assign net_3_390 = (iq_instr0_fn_dih_i[10] | net_3_391);
  assign net_3_391 = (net_3_154 | net_3_21);
  assign instr0_fp_read_is_s = (net_3_392 & net_3_2);
  assign net_3_392 = (iq_instr0_sideband_i[1] & net_3_3);
  assign instr0_fp_read_d_size[1] = ~(net_3_393 & net_3_394);
  assign net_3_394 = ~(iq_instr0_fn_dih_i[11] & net_3_11);
  assign net_3_393 = (iq_instr0_fn_dih_i[10] | net_3_395);
  assign net_3_395 = ~(net_3_184 & net_3_396);
  assign net_3_396 = (iq_instr0_fn_dih_i[9] & net_3_312);
  assign net_3_312 = (net_3_87 & net_3_18);
  assign net_3_184 = ~(iq_instr0_fn_dih_i[16] | net_3_16);
  assign instr0_fp_need_f1 = (net_3_397 | net_3_398);
  assign net_3_398 = ~(net_3_70 & net_3_399);
  assign net_3_399 = ~(net_3_400 | net_3_401);
  assign net_3_401 = ~(net_3_402 & net_3_385);
  assign net_3_385 = (iq_instr0_fn_dih_i[23] | net_3_1);
  assign net_3_402 = ~(net_3_236 | net_3_403);
  assign net_3_403 = ~(net_3_358 & net_3_404);
  assign net_3_404 = (net_3_15 | net_3_405);
  assign net_3_405 = (net_3_406 & net_3_407);
  assign net_3_407 = (iq_instr0_fn_dih_i[9] | net_3_408);
  assign net_3_408 = ~(net_3_409 | net_3_410);
  assign net_3_409 = ~(net_3_411 & net_3_412);
  assign net_3_412 = ~(iq_instr0_fn_dih_i[18] & net_3_214);
  assign net_3_411 = ~(net_3_370 & net_3_58);
  assign net_3_58 = ~(iq_instr0_fn_dih_i[17] | net_3_12);
  assign net_3_370 = (net_3_4 & net_3_19);
  assign net_3_406 = (net_3_413 & net_3_414);
  assign net_3_414 = (net_3_415 & net_3_416);
  assign net_3_416 = ~(iq_instr0_fn_dih_i[16] & net_3_417);
  assign net_3_417 = ~(net_3_418 & net_3_419);
  assign net_3_419 = (net_3_19 | iq_instr0_fn_dih_i[4]);
  assign net_3_418 = (iq_instr0_fn_dih_i[7] | net_3_10);
  assign net_3_415 = (net_3_420 & net_3_421);
  assign net_3_421 = (net_3_9 | net_3_234);
  assign net_3_234 = ~(iq_instr0_fn_dih_i[10] & net_3_302);
  assign net_3_420 = (net_3_20 | net_3_422);
  assign net_3_422 = ~(iq_instr0_fn_dih_i[22] & net_3_269);
  assign net_3_269 = (iq_instr0_fn_dih_i[4] & iq_instr0_fn_dih_i[11]);
  assign net_3_413 = (net_3_423 & net_3_375);
  assign net_3_375 = (net_3_7 | net_3_155);
  assign net_3_155 = (iq_instr0_fn_dih_i[4] | iq_instr0_fn_dih_i[28]);
  assign net_3_423 = (net_3_424 & net_3_425);
  assign net_3_425 = ~(net_3_142 & iq_instr0_fn_dih_i[17]);
  assign net_3_424 = ~(net_3_323 & iq_instr0_fn_dih_i[7]);
  assign net_3_323 = (iq_instr0_fn_dih_i[6] & iq_instr0_fn_dih_i[21]);
  assign net_3_358 = (net_3_426 & net_3_194);
  assign net_3_194 = ~(iq_instr0_fn_dih_i[26] & net_3_427);
  assign net_3_427 = (net_3_254 & net_3_9);
  assign net_3_254 = ~(iq_instr0_sideband_i[3] | net_3_4);
  assign net_3_426 = (net_3_428 & net_3_429);
  assign net_3_429 = (net_3_430 | net_3_431);
  assign net_3_431 = (iq_instr0_fn_dih_i[6] | net_3_432);
  assign net_3_432 = ~(net_3_263 & net_3_78);
  assign net_3_263 = ~(iq_instr0_fn_dih_i[28] | iq_instr0_fn_dih_i[23]);
  assign net_3_430 = ~(iq_instr0_fn_dih_i[11] & iq_instr0_fn_dih_i[27]);
  assign net_3_428 = (net_3_433 | iq_instr0_fn_dih_pdtype0_i);
  assign net_3_433 = (net_3_434 & net_3_435);
  assign net_3_435 = (net_3_249 | net_3_12);
  assign net_3_249 = ~(iq_instr0_fn_dih_i[20] & net_3_267);
  assign net_3_434 = ~(iq_instr0_fn_dih_i[25] & net_3_436);
  assign net_3_436 = ~(net_3_437 & net_3_438);
  assign net_3_438 = ~(net_3_439 & net_3_19);
  assign net_3_437 = ~(net_3_217 | net_3_440);
  assign net_3_440 = (iq_instr0_fn_dih_i[8] & net_3_441);
  assign net_3_441 = (net_3_317 & net_3_23);
  assign net_3_217 = ~(net_3_442 & net_3_443);
  assign net_3_443 = ~(net_3_439 & net_3_169);
  assign net_3_169 = (iq_instr0_fn_dih_i[8] | iq_instr0_fn_dih_i[6]);
  assign net_3_439 = ~(iq_instr0_fn_dih_i[20] | net_3_10);
  assign net_3_442 = (iq_instr0_fn_dih_i[23] | net_3_444);
  assign net_3_444 = ~(iq_instr0_fn_dih_i[10] & net_3_445);
  assign net_3_445 = ~(iq_instr0_fn_dih_i[9] | iq_instr0_fn_dih_i[6]);
  assign net_3_236 = ~(net_3_446 & net_3_447);
  assign net_3_447 = (net_3_448 | net_3_7);
  assign net_3_448 = (net_3_449 & net_3_450);
  assign net_3_450 = ~(iq_instr0_fn_dih_i[4] & net_3_451);
  assign net_3_451 = (iq_instr0_fn_dih_i[7] & net_3_20);
  assign net_3_449 = (net_3_452 | iq_instr0_fn_dih_i[8]);
  assign net_3_452 = ~(net_3_453 | net_3_454);
  assign net_3_454 = (iq_instr0_fn_dih_i[27] & net_3_66);
  assign net_3_453 = (iq_instr0_fn_dih_i[4] & net_3_455);
  assign net_3_455 = (iq_instr0_fn_dih_i[21] | net_3_93);
  assign net_3_446 = (net_3_456 & net_3_457);
  assign net_3_457 = ~(net_3_458 & iq_instr0_fn_dih_i[26]);
  assign net_3_458 = ~(iq_instr0_fn_dih_i[4] | net_3_459);
  assign net_3_459 = (iq_instr0_fn_dih_i[16] | net_3_460);
  assign net_3_460 = (net_3_347 | net_3_6);
  assign net_3_347 = (iq_instr0_fn_dih_i[17] | net_3_461);
  assign net_3_461 = ~(iq_instr0_fn_dih_i[18] & net_3_209);
  assign net_3_209 = (iq_instr0_fn_dih_i[6] & net_3_9);
  assign net_3_456 = (net_3_462 & net_3_40);
  assign net_3_40 = (net_3_463 | net_3_464);
  assign net_3_464 = ~(net_3_2 & net_3_317);
  assign net_3_463 = (net_3_465 & net_3_466);
  assign net_3_466 = (net_3_19 | iq_instr0_fn_dih_i[8]);
  assign net_3_465 = ~(iq_instr0_fn_dih_i[11] & net_3_8);
  assign net_3_462 = (net_3_467 | iq_instr0_fn_dih_pdtype0_i);
  assign net_3_467 = (net_3_468 & net_3_469);
  assign net_3_469 = ~(iq_instr0_fn_dih_i[19] & net_3_470);
  assign net_3_470 = (iq_instr0_fn_dih_i[25] & net_3_11);
  assign net_3_468 = ~(net_3_214 & net_3_472);
  assign net_3_472 = (iq_instr0_fn_dih_i[21] & net_3_410);
  assign net_3_410 = ~(iq_instr0_fn_dih_i[7] | net_3_12);
  assign net_3_214 = (iq_instr0_fn_dih_i[10] & iq_instr0_fn_dih_i[8]);
  assign net_3_400 = (net_3_473 | net_3_474);
  assign net_3_474 = (net_3_475 | instr0_fp_writes[0]);
  assign instr0_fp_writes[0] = ~(net_3_476 & net_3_477);
  assign net_3_477 = (net_3_388 | net_3_389);
  assign net_3_389 = ~(net_3_87 & net_3_96);
  assign net_3_96 = (iq_instr0_fn_dih_i[10] & iq_instr0_fn_dih_i[9]);
  assign net_3_87 = (iq_instr0_fn_dih_i[28] & net_3_142);
  assign net_3_142 = (net_3_23 & iq_instr0_fn_dih_i[23]);
  assign net_3_388 = (iq_instr0_fn_dih_pdtype0_i | net_3_18);
  assign net_3_476 = ~(net_3_362 & net_3_231);
  assign net_3_231 = (iq_instr0_fn_dih_i[25] & net_3_15);
  assign net_3_475 = (net_3_478 & net_3_93);
  assign net_3_93 = (iq_instr0_fn_dih_i[19] | iq_instr0_fn_dih_i[7]);
  assign net_3_478 = ~(net_3_19 | net_3_61);
  assign net_3_61 = ~(iq_instr0_fn_dih_i[4] & net_3_164);
  assign net_3_164 = (iq_instr0_fn_dih_i[23] & net_3_8);
  assign net_3_43 = ~(iq_instr0_fn_dih_i[24] & iq_instr0_fn_dih_i[25]);
  assign net_3_473 = ~(net_3_479 & net_3_480);
  assign net_3_480 = (net_3_154 | net_3_471);
  assign net_3_471 = ~(net_3_20 & net_3_302);
  assign net_3_302 = (iq_instr0_fn_dih_i[4] & iq_instr0_fn_dih_i[23]);
  assign net_3_479 = ~(net_3_279 | net_3_481);
  assign net_3_481 = ~(net_3_482 & net_3_483);
  assign net_3_483 = ~(net_3_484 & iq_instr0_fn_dih_i[26]);
  assign net_3_484 = (net_3_485 & net_3_383);
  assign net_3_383 = ~(iq_instr0_fn_dih_i[8] | net_3_18);
  assign net_3_482 = ~(net_3_486 & net_3_31);
  assign net_3_486 = (net_3_317 & net_3_316);
  assign net_3_316 = ~(iq_instr0_fn_dih_i[11] | iq_instr0_sideband_i[3]);
  assign net_3_317 = (iq_instr0_fn_dih_i[9] & net_3_12);
  assign net_3_279 = ~(net_3_154 | net_3_487);
  assign net_3_487 = ~(net_3_488 & net_3_485);
  assign net_3_154 = ~(iq_instr0_fn_dih_i[24] & iq_instr0_fn_dih_i[21]);
  assign net_3_70 = ~(iq_instr0_fn_dih_i[21] & net_3_362);
  assign net_3_362 = (net_3_72 & net_3_4);
  assign net_3_72 = (iq_instr0_fn_dih_i[4] & net_3_9);
  assign net_3_397 = (net_3_4 & net_3_489);
  assign net_3_489 = ~(net_3_218 & net_3_490);
  assign net_3_490 = (net_3_329 & net_3_491);
  assign net_3_491 = ~(net_3_78 & net_3_267);
  assign net_3_267 = ~(iq_instr0_fn_dih_i[24] | iq_instr0_fn_dih_i[21]);
  assign net_3_78 = (iq_instr0_fn_dih_i[8] & iq_instr0_fn_dih_i[25]);
  assign net_3_329 = ~(net_3_488 & net_3_492);
  assign net_3_492 = ~(net_3_493 & net_3_494);
  assign net_3_494 = ~(net_3_495 & iq_instr0_fn_dih_i[11]);
  assign net_3_495 = ~(net_3_21 | net_3_496);
  assign net_3_496 = ~(net_3_90 | net_3_497);
  assign net_3_497 = (net_3_13 & iq_instr0_fn_dih_i[26]);
  assign net_3_90 = (iq_instr0_fn_dih_i[21] & net_3_15);
  assign net_3_50 = (net_3_23 & net_3_22);
  assign net_3_493 = ~(net_3_498 & iq_instr0_fn_dih_i[20]);
  assign net_3_498 = (net_3_485 & net_3_12);
  assign net_3_485 = (iq_instr0_fn_dih_i[4] & iq_instr0_fn_dih_i[28]);
  assign net_3_488 = (net_3_31 & net_3_20);
  assign net_3_31 = (iq_instr0_fn_dih_i[8] & net_3_19);
  assign net_3_218 = (net_3_499 & net_3_500);
  assign net_3_500 = ~(iq_instr0_fn_dih_i[9] & net_3_353);
  assign net_3_353 = (iq_instr0_fn_dih_i[28] & net_3_51);
  assign net_3_51 = (iq_instr0_fn_dih_i[11] & net_3_66);
  assign net_3_66 = ~(iq_instr0_fn_dih_i[10] | net_3_15);
  assign net_3_499 = (net_3_501 | iq_instr0_fn_dih_i[4]);
  assign net_3_501 = (net_3_502 | iq_instr0_fn_dih_i[24]);
  assign net_3_502 = (iq_instr0_fn_dih_i[23] & net_3_503);
  assign net_3_503 = ~(iq_instr0_fn_dih_i[19] & net_3_504);
  assign net_3_504 = ~(iq_instr0_fn_dih_i[17] | net_3_22);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  assign instr1_fp_reg[VN] = {iq_instr1_fn_dih_i[ 7], iq_instr1_fn_dih_i[19:16]};
  assign instr1_fp_reg[VD] = {iq_instr1_fn_dih_i[22], iq_instr1_fn_dih_i[15:12]};
  assign instr1_fp_reg[VM] = {iq_instr1_fn_dih_i[ 5], iq_instr1_fn_dih_i[ 3: 0]};
  assign instr1_fp_reg[VA] = {iq_instr1_fn_dih_i[29], iq_instr1_fn_dih_i[11: 8]};

  assign instr0_fp_reg[VN] = {iq_instr0_fn_dih_i[ 7], iq_instr0_fn_dih_i[19:16]};
  assign instr0_fp_reg[VD] = {iq_instr0_fn_dih_i[22], iq_instr0_fn_dih_i[15:12]};
  assign instr0_fp_reg[VM] = {iq_instr0_fn_dih_i[ 5], iq_instr0_fn_dih_i[ 3: 0]};
  assign instr0_fp_reg[VA] = {iq_instr0_fn_dih_i[29], iq_instr0_fn_dih_i[11: 8]};

  // Address of q-reg accessed
  // - The address of AA64 registers is modified such that forming the register
  // address can be done just with masking rather than muxing different bits
  // around. This means the resulting address will be different from the
  // register actually accessed by the instruction, but will be consistent in
  // the comparisons and so will produce the correct behaviour.
  // - Need to form separate addresses for slot 1 depending on whether being
  // accessed as read or write, calculate type of access separately for reads
  // and writes as comparators are independent.
  // - Mask off top bits of address depending on how being accessed to form 
  // final address
  assign instr0_fp_read_q_reg_mask  = {iq_instr0_fn_dih_aarch64_i, (iq_instr0_fn_dih_aarch64_i | ~instr0_fp_read_is_s) , 3'b111};
  assign instr0_fp_write_q_reg_mask = {iq_instr0_fn_dih_aarch64_i, (iq_instr0_fn_dih_aarch64_i | ~instr0_fp_write_is_s), 3'b111};
  assign instr1_fp_read_q_reg_mask  = {iq_instr1_fn_dih_aarch64_i, (iq_instr1_fn_dih_aarch64_i | ~instr1_fp_read_is_s) , 3'b111};
  assign instr1_fp_write_q_reg_mask = {iq_instr1_fn_dih_aarch64_i, (iq_instr1_fn_dih_aarch64_i | ~instr1_fp_write_is_s), 3'b111};

  // - Va can only be used in AA64, so do not need to mask the address
  // - Vd uses write_is_s, as can be different from other read fields, but will always be same as write
  assign instr0_fp_read_q_reg[VN]   = {instr0_fp_reg[VN][0], instr0_fp_reg[VN][4:1]} & instr0_fp_read_q_reg_mask;
  assign instr0_fp_read_q_reg[VM]   = {instr0_fp_reg[VM][0], instr0_fp_reg[VM][4:1]} & instr0_fp_read_q_reg_mask;
  assign instr0_fp_read_q_reg[VD]   = {instr0_fp_reg[VD][0], instr0_fp_reg[VD][4:1]} & instr0_fp_write_q_reg_mask;
  assign instr0_fp_read_q_reg[VA]   = {instr0_fp_reg[VA][0], instr0_fp_reg[VA][4:1]};

  assign instr0_fp_write_q_reg[VN]  = {instr0_fp_reg[VN][0], instr0_fp_reg[VN][4:1]} & instr0_fp_write_q_reg_mask;
  assign instr0_fp_write_q_reg[VM]  = {instr0_fp_reg[VM][0], instr0_fp_reg[VM][4:1]} & instr0_fp_write_q_reg_mask;
  assign instr0_fp_write_q_reg[VD]  = {instr0_fp_reg[VD][0], instr0_fp_reg[VD][4:1]} & instr0_fp_write_q_reg_mask;

  assign instr1_fp_read_q_reg[VN]   = {instr1_fp_reg[VN][0], instr1_fp_reg[VN][4:1]} & instr1_fp_read_q_reg_mask;
  assign instr1_fp_read_q_reg[VM]   = {instr1_fp_reg[VM][0], instr1_fp_reg[VM][4:1]} & instr1_fp_read_q_reg_mask;
  assign instr1_fp_read_q_reg[VD]   = {instr1_fp_reg[VD][0], instr1_fp_reg[VD][4:1]} & instr1_fp_write_q_reg_mask;
  assign instr1_fp_read_q_reg[VA]   = {instr1_fp_reg[VA][0], instr1_fp_reg[VA][4:1]};

  assign instr1_fp_write_q_reg[VN]  = {instr1_fp_reg[VN][0], instr1_fp_reg[VN][4:1]} & instr1_fp_write_q_reg_mask;
  assign instr1_fp_write_q_reg[VM]  = {instr1_fp_reg[VM][0], instr1_fp_reg[VM][4:1]} & instr1_fp_write_q_reg_mask;
  assign instr1_fp_write_q_reg[VD]  = {instr1_fp_reg[VD][0], instr1_fp_reg[VD][4:1]} & instr1_fp_write_q_reg_mask;

  // Mask to indicate which 32-bit chunk(s) accessed within q-word
  function [3:0] calc_instr_fp_mask;
    input [4:0] fp_reg;
    input       is_s;
    input [1:0] d_size;
    input       aarch64;

    // Note AA64 writes set all strobes, so can just as well set all on reads
    case ({aarch64, is_s, d_size})
      `ca53dpu_sel_1xxx: calc_instr_fp_mask = 4'b1111;                                                                              // AA64
      `ca53dpu_sel_01xx: calc_instr_fp_mask = { {2{fp_reg[0]}}, {2{~fp_reg[0]}} } & {fp_reg[4], ~fp_reg[4], fp_reg[4], ~fp_reg[4]}; // AA32 S reg
      4'b0_0_00        : calc_instr_fp_mask = { {2{fp_reg[0]}}, {2{~fp_reg[0]}} };                                                  // AA32 D reg
      4'b0_0_01        : calc_instr_fp_mask = 4'b0011;                                                                              // QxLo
      4'b0_0_10        : calc_instr_fp_mask = 4'b1100;                                                                              // QxHi
      4'b0_0_11        : calc_instr_fp_mask = 4'b1111;                                                                              // Qx (only possible on writes)
      default          : calc_instr_fp_mask = 4'bxxxx;
    endcase
  endfunction

  assign instr1_fp_read_mask[VN]  = calc_instr_fp_mask(instr1_fp_reg[VN], instr1_fp_read_is_s,  instr1_fp_read_d_size,  iq_instr1_fn_dih_aarch64_i);
  assign instr1_fp_read_mask[VD]  = calc_instr_fp_mask(instr1_fp_reg[VD], instr1_fp_write_is_s, instr1_fp_write_d_size, iq_instr1_fn_dih_aarch64_i);
  assign instr1_fp_read_mask[VM]  = calc_instr_fp_mask(instr1_fp_reg[VM], instr1_fp_read_is_s,  instr1_fp_read_d_size,  iq_instr1_fn_dih_aarch64_i);
  assign instr1_fp_read_mask[VA]  = calc_instr_fp_mask(instr1_fp_reg[VA], instr1_fp_read_is_s,  instr1_fp_read_d_size,  iq_instr1_fn_dih_aarch64_i);
  assign instr0_fp_read_mask[VN]  = calc_instr_fp_mask(instr0_fp_reg[VN], instr0_fp_read_is_s,  instr0_fp_read_d_size,  iq_instr0_fn_dih_aarch64_i);
  assign instr0_fp_read_mask[VD]  = calc_instr_fp_mask(instr0_fp_reg[VD], instr0_fp_write_is_s, instr0_fp_write_d_size, iq_instr0_fn_dih_aarch64_i);
  assign instr0_fp_read_mask[VM]  = calc_instr_fp_mask(instr0_fp_reg[VM], instr0_fp_read_is_s,  instr0_fp_read_d_size,  iq_instr0_fn_dih_aarch64_i);
  assign instr0_fp_read_mask[VA]  = calc_instr_fp_mask(instr0_fp_reg[VA], instr0_fp_read_is_s,  instr0_fp_read_d_size,  iq_instr0_fn_dih_aarch64_i);
  assign instr1_fp_write_mask[VN] = calc_instr_fp_mask(instr1_fp_reg[VN], instr1_fp_write_is_s, instr1_fp_write_d_size, iq_instr1_fn_dih_aarch64_i);
  assign instr1_fp_write_mask[VD] = calc_instr_fp_mask(instr1_fp_reg[VD], instr1_fp_write_is_s, instr1_fp_write_d_size, iq_instr1_fn_dih_aarch64_i);
  assign instr1_fp_write_mask[VM] = calc_instr_fp_mask(instr1_fp_reg[VM], instr1_fp_write_is_s, instr1_fp_write_d_size, iq_instr1_fn_dih_aarch64_i);
  assign instr0_fp_write_mask[VN] = calc_instr_fp_mask(instr0_fp_reg[VN], instr0_fp_write_is_s, instr0_fp_write_d_size, iq_instr0_fn_dih_aarch64_i);
  assign instr0_fp_write_mask[VD] = calc_instr_fp_mask(instr0_fp_reg[VD], instr0_fp_write_is_s, instr0_fp_write_d_size, iq_instr0_fn_dih_aarch64_i);
  assign instr0_fp_write_mask[VM] = calc_instr_fp_mask(instr0_fp_reg[VM], instr0_fp_write_is_s, instr0_fp_write_d_size, iq_instr0_fn_dih_aarch64_i);

  // ------------------------------------------------------
  // RAW hazards
  // ------------------------------------------------------
  // Compare q-regs accessed
  assign q_reg_raw_hazard_fp_de[VN] = ({instr1_fp_reads[VN], instr1_fp_read_q_reg[VN]} == {1'b1, instr0_fp_write_q_reg[VN]}) |
                                      ({instr1_fp_reads[VD], instr1_fp_read_q_reg[VD]} == {1'b1, instr0_fp_write_q_reg[VN]}) |
                                      ({instr1_fp_reads[VM], instr1_fp_read_q_reg[VM]} == {1'b1, instr0_fp_write_q_reg[VN]}) |
                                      ({instr1_fp_reads[VA], instr1_fp_read_q_reg[VA]} == {1'b1, instr0_fp_write_q_reg[VN]});

  assign q_reg_raw_hazard_fp_de[VD] = ({instr1_fp_reads[VN], instr1_fp_read_q_reg[VN]} == {1'b1, instr0_fp_write_q_reg[VD]}) |
                                      ({instr1_fp_reads[VD], instr1_fp_read_q_reg[VD]} == {1'b1, instr0_fp_write_q_reg[VD]}) |
                                      ({instr1_fp_reads[VM], instr1_fp_read_q_reg[VM]} == {1'b1, instr0_fp_write_q_reg[VD]}) |
                                      ({instr1_fp_reads[VA], instr1_fp_read_q_reg[VA]} == {1'b1, instr0_fp_write_q_reg[VD]});

  assign q_reg_raw_hazard_fp_de[VM] = ({instr1_fp_reads[VN], instr1_fp_read_q_reg[VN]} == {1'b1, instr0_fp_write_q_reg[VM]}) |
                                      ({instr1_fp_reads[VD], instr1_fp_read_q_reg[VD]} == {1'b1, instr0_fp_write_q_reg[VM]}) |
                                      ({instr1_fp_reads[VM], instr1_fp_read_q_reg[VM]} == {1'b1, instr0_fp_write_q_reg[VM]}) |
                                      ({instr1_fp_reads[VA], instr1_fp_read_q_reg[VA]} == {1'b1, instr0_fp_write_q_reg[VM]});

  // Compare 32-bit fields accessed within each q-word
  assign mask_raw_hazard_fp_de[VN]  = (instr1_fp_reads[VN] & (|(instr1_fp_read_mask[VN] & instr0_fp_write_mask[VN]))) |
                                      (instr1_fp_reads[VD] & (|(instr1_fp_read_mask[VD] & instr0_fp_write_mask[VN]))) |
                                      (instr1_fp_reads[VM] & (|(instr1_fp_read_mask[VM] & instr0_fp_write_mask[VN]))) |
                                      (instr1_fp_reads[VA] & (|(instr1_fp_read_mask[VA] & instr0_fp_write_mask[VN])));
                                                                                                         
  assign mask_raw_hazard_fp_de[VD]  = (instr1_fp_reads[VN] & (|(instr1_fp_read_mask[VN] & instr0_fp_write_mask[VD]))) |
                                      (instr1_fp_reads[VD] & (|(instr1_fp_read_mask[VD] & instr0_fp_write_mask[VD]))) |
                                      (instr1_fp_reads[VM] & (|(instr1_fp_read_mask[VM] & instr0_fp_write_mask[VD]))) |
                                      (instr1_fp_reads[VA] & (|(instr1_fp_read_mask[VA] & instr0_fp_write_mask[VD])));
                                                                                                         
  assign mask_raw_hazard_fp_de[VM]  = (instr1_fp_reads[VN] & (|(instr1_fp_read_mask[VN] & instr0_fp_write_mask[VM]))) |
                                      (instr1_fp_reads[VD] & (|(instr1_fp_read_mask[VD] & instr0_fp_write_mask[VM]))) |
                                      (instr1_fp_reads[VM] & (|(instr1_fp_read_mask[VM] & instr0_fp_write_mask[VM]))) |
                                      (instr1_fp_reads[VA] & (|(instr1_fp_read_mask[VA] & instr0_fp_write_mask[VM])));

  // RAW hazard if accessing same q-register and same 32-bit chunk within that register
  assign fp_raw_hazard_de = |(q_reg_raw_hazard_fp_de & mask_raw_hazard_fp_de & instr0_fp_writes) & iq_instr0_is_fn_i & iq_instr1_is_fn_i;

  // ------------------------------------------------------
  // WAW hazards
  // ------------------------------------------------------
  // Unlike integer instructions, where WAW hazards can be resolved by
  // suppressing the earlier write enable, FP instructions can write different
  // portions of the same register, which makes merging WAW hazards difficult.
  // Therefore, if there is a WAW hazard between slot 0 and slot 1, suppress
  // dual issue.

  // Compare q-regs accessed
  assign q_reg_waw_hazard_fp_de[VN] = ({instr1_fp_writes[VN], instr1_fp_write_q_reg[VN]} == {1'b1, instr0_fp_write_q_reg[VN]}) |
                                      ({instr1_fp_writes[VD], instr1_fp_write_q_reg[VD]} == {1'b1, instr0_fp_write_q_reg[VN]}) |
                                      ({instr1_fp_writes[VM], instr1_fp_write_q_reg[VM]} == {1'b1, instr0_fp_write_q_reg[VN]});

  assign q_reg_waw_hazard_fp_de[VD] = ({instr1_fp_writes[VN], instr1_fp_write_q_reg[VN]} == {1'b1, instr0_fp_write_q_reg[VD]}) |
                                      ({instr1_fp_writes[VD], instr1_fp_write_q_reg[VD]} == {1'b1, instr0_fp_write_q_reg[VD]}) |
                                      ({instr1_fp_writes[VM], instr1_fp_write_q_reg[VM]} == {1'b1, instr0_fp_write_q_reg[VD]});

  assign q_reg_waw_hazard_fp_de[VM] = ({instr1_fp_writes[VN], instr1_fp_write_q_reg[VN]} == {1'b1, instr0_fp_write_q_reg[VM]}) |
                                      ({instr1_fp_writes[VD], instr1_fp_write_q_reg[VD]} == {1'b1, instr0_fp_write_q_reg[VM]}) |
                                      ({instr1_fp_writes[VM], instr1_fp_write_q_reg[VM]} == {1'b1, instr0_fp_write_q_reg[VM]});

  // Compare 32-bit fields accessed within each q-word
  assign mask_waw_hazard_fp_de[VN]  = (instr1_fp_writes[VN] & (|(instr1_fp_write_mask[VN] & instr0_fp_write_mask[VN]))) |
                                      (instr1_fp_writes[VD] & (|(instr1_fp_write_mask[VD] & instr0_fp_write_mask[VN]))) |
                                      (instr1_fp_writes[VM] & (|(instr1_fp_write_mask[VM] & instr0_fp_write_mask[VN])));
                                                                                                         
  assign mask_waw_hazard_fp_de[VD]  = (instr1_fp_writes[VN] & (|(instr1_fp_write_mask[VN] & instr0_fp_write_mask[VD]))) |
                                      (instr1_fp_writes[VD] & (|(instr1_fp_write_mask[VD] & instr0_fp_write_mask[VD]))) |
                                      (instr1_fp_writes[VM] & (|(instr1_fp_write_mask[VM] & instr0_fp_write_mask[VD])));
                                                                                                         
  assign mask_waw_hazard_fp_de[VM]  = (instr1_fp_writes[VN] & (|(instr1_fp_write_mask[VN] & instr0_fp_write_mask[VM]))) |
                                      (instr1_fp_writes[VD] & (|(instr1_fp_write_mask[VD] & instr0_fp_write_mask[VM]))) |
                                      (instr1_fp_writes[VM] & (|(instr1_fp_write_mask[VM] & instr0_fp_write_mask[VM])));

  // waw hazard if accessing same q-register and same 32-bit chunk within that register
  assign fp_waw_hazard_de = |(q_reg_waw_hazard_fp_de & mask_waw_hazard_fp_de & instr0_fp_writes) & iq_instr1_is_fn_i & iq_instr0_is_fn_i;

  // ------------------------------------------------------
  // WAR hazards
  // ------------------------------------------------------
  // It is possible for a slot 1 FP write to hazard against a slot 0 FP read in
  // one situation:
  // * When the slot 0 instruction is a multiply accumulate which reads Va on
  // the special (i.e. out of sequence with the first part of the instruction
  // * And slot 1 writes the same register on its first cycle
  //
  // This can only happen in AArch64, so only need to check for Q register
  // hazard, not mask hazard.

  assign fp_war_hazard_de = (({instr1_fp_writes[VN], instr1_fp_write_q_reg[VN]} == {1'b1, instr0_fp_read_q_reg[VA]}) |
                             ({instr1_fp_writes[VD], instr1_fp_write_q_reg[VD]} == {1'b1, instr0_fp_read_q_reg[VA]}) |
                             ({instr1_fp_writes[VM], instr1_fp_write_q_reg[VM]} == {1'b1, instr0_fp_read_q_reg[VA]})) & 
                            instr0_fp_reads[VA] & iq_instr0_is_fn_i & iq_instr1_is_fn_i;

  // ------------------------------------------------------
  // Detect a RAW hazard between De and later in the pipeline
  // ------------------------------------------------------
  // Do not dual issue an instruction if it will interlock with a later pipeline
  // stage, unless slot 0 will interlock anyway.
  //
  // This is calculated by comparing instr0 and instr1 with Iss, F1 and F2 and
  // detecting how many cycles each slot will interlock in Iss. If instr1 would
  // interlock for more cycles than instr0 by dual issuing then instr1 is not
  // dual issues. This means it will be in slot 0 on the next cycle, and so will
  // need to interlock for 1 less cycle and may also be able to dual issue with
  // another instruction in slot 1, improving overall performance.
  //
  // The interlock is calculated by creating a 3 bit mask for instr1 and instr0,
  // indicating how may cycles each would stall in Iss:
  //
  // 000 = No stall
  // 001 = Interlock for 1 cycle
  // 011 = Interlock for 2 cycles
  // 111 = Interlock for 3 cycles
  //
  // These masks are then compared to determine whether to dual issue or not.
  //
  // The calculation only looks as far ahead as F2, as when the instruction
  // currently in De is in F1 (the earliest it would need forwarding to), the
  // instruction currently in F2 will be in F4. For the purposes of this
  // calculation it is assumed all instructions can forward out of F5, as only a
  // few, rare instructions cannot.

  // Calculate register addresses and masks for Iss - F2 pipeline stages
  assign iss_fw0_q_reg = rf_wr_addr_fw0_iss_i[5:1];
  assign iss_fw1_q_reg = rf_wr_addr_fw1_iss_i[5:1];

  assign f1_fw0_q_reg  = rf_wr_addr_fw0_f1_i[5:1];
  assign f1_fw1_q_reg  = rf_wr_addr_fw1_f1_i[5:1];
                                                                                                          
  assign f2_fw0_q_reg  = rf_wr_addr_fw0_f2_i[5:1];                                                                     
  assign f2_fw1_q_reg  = rf_wr_addr_fw1_f2_i[5:1];

  function [3:0] calc_instr_fw_mask;
    input [3:0] wr_en;
    input       aa32_odd;

    case (wr_en)
      4'b0000: calc_instr_fw_mask = 4'b0000;
      4'b0001: calc_instr_fw_mask = aa32_odd ? 4'b0100 : 4'b0001; // AA32 S even
      4'b0010: calc_instr_fw_mask = aa32_odd ? 4'b1000 : 4'b0010; // AA32 S odd
      4'b0011: calc_instr_fw_mask = aa32_odd ? 4'b1100 : 4'b0011; // AA32 D
      4'b0111: calc_instr_fw_mask = 4'b1111;
      4'b1001: calc_instr_fw_mask = 4'b1111;  // AA64 S reg (zeros top)
      4'b1011: calc_instr_fw_mask = 4'b1111;  // AA64 D reg (zeros top)
      4'b1010: calc_instr_fw_mask = 4'b1110;  // AA64 NEON load
      default: calc_instr_fw_mask = 4'bxxxx;
    endcase
  endfunction

  assign iss_fw0_write_mask = calc_instr_fw_mask(rf_wr_en_fw0_iss_i, rf_wr_addr_fw0_iss_i[0]);
  assign iss_fw1_write_mask = calc_instr_fw_mask(rf_wr_en_fw1_iss_i, rf_wr_addr_fw1_iss_i[0]);
  assign f1_fw0_write_mask  = calc_instr_fw_mask(rf_wr_en_fw0_f1_i,  rf_wr_addr_fw0_f1_i[0]);
  assign f1_fw1_write_mask  = calc_instr_fw_mask(rf_wr_en_fw1_f1_i,  rf_wr_addr_fw1_f1_i[0]);
  assign f2_fw0_write_mask  = calc_instr_fw_mask(rf_wr_en_fw0_f2_i,  rf_wr_addr_fw0_f2_i[0]);
  assign f2_fw1_write_mask  = calc_instr_fw_mask(rf_wr_en_fw1_f2_i,  rf_wr_addr_fw1_f2_i[0]);

  // -------------
  // De to Iss
  // -------------
  // De will be in F1 when Iss in F2, F2 when Iss in F3:
  //  De | Iss |  F1 |  F2 |  F3 |  F4 |
  // ----+-----+-----+-----+-----+-----|
  //  D  |  I  |     |     |     |     |
  //     |  D  |  I  |     |     |     |
  //     |     |  D  |  I  |     |     |
  //     |     |     |  D  |  I  |     |

  function [2:0] fp_need_when_mask_iss;
    input       need_f1;
    input [1:0] whn;

    // need |   when   | mask | Interlock         |
    // -----+----------+------+-------------------|
    //  F1  |  F3 (00) |  001 | 1 cycle interlock |
    //  F1  |  F4 (01) |  011 | 2 cycle interlock |
    //  F1  |  F5 (11) |  111 | 3 cycle interlock |
    //  F2  |  F3 (00) |  000 | 0 cycle interlock |
    //  F2  |  F4 (01) |  001 | 1 cycle interlock |
    //  F2  |  F5 (11) |  011 | 2 cycle interlock |

    case (need_f1)
      1'b0   : fp_need_when_mask_iss = {1'b0, whn};
      1'b1   : fp_need_when_mask_iss = {whn, 1'b1};
      default: fp_need_when_mask_iss = 3'bxxx;
    endcase
  endfunction

  // Detect when Iss is writing a register read by De
  assign instr0_fw0_iss_match = (instr0_fp_reads[VA] & (instr0_fp_read_q_reg[VA] == iss_fw0_q_reg) & (|(instr0_fp_read_mask[VA] & iss_fw0_write_mask))) |
                                (instr0_fp_reads[VM] & (instr0_fp_read_q_reg[VM] == iss_fw0_q_reg) & (|(instr0_fp_read_mask[VM] & iss_fw0_write_mask))) |
                                (instr0_fp_reads[VD] & (instr0_fp_read_q_reg[VD] == iss_fw0_q_reg) & (|(instr0_fp_read_mask[VD] & iss_fw0_write_mask))) |
                                (instr0_fp_reads[VN] & (instr0_fp_read_q_reg[VN] == iss_fw0_q_reg) & (|(instr0_fp_read_mask[VN] & iss_fw0_write_mask)));

  assign instr0_fw1_iss_match = (instr0_fp_reads[VA] & (instr0_fp_read_q_reg[VA] == iss_fw1_q_reg) & (|(instr0_fp_read_mask[VA] & iss_fw1_write_mask))) |
                                (instr0_fp_reads[VM] & (instr0_fp_read_q_reg[VM] == iss_fw1_q_reg) & (|(instr0_fp_read_mask[VM] & iss_fw1_write_mask))) |
                                (instr0_fp_reads[VD] & (instr0_fp_read_q_reg[VD] == iss_fw1_q_reg) & (|(instr0_fp_read_mask[VD] & iss_fw1_write_mask))) |
                                (instr0_fp_reads[VN] & (instr0_fp_read_q_reg[VN] == iss_fw1_q_reg) & (|(instr0_fp_read_mask[VN] & iss_fw1_write_mask)));

  assign instr1_fw0_iss_match = (instr1_fp_reads[VA] & (instr1_fp_read_q_reg[VA] == iss_fw0_q_reg) & (|(instr1_fp_read_mask[VA] & iss_fw0_write_mask))) |
                                (instr1_fp_reads[VM] & (instr1_fp_read_q_reg[VM] == iss_fw0_q_reg) & (|(instr1_fp_read_mask[VM] & iss_fw0_write_mask))) |
                                (instr1_fp_reads[VD] & (instr1_fp_read_q_reg[VD] == iss_fw0_q_reg) & (|(instr1_fp_read_mask[VD] & iss_fw0_write_mask))) |
                                (instr1_fp_reads[VN] & (instr1_fp_read_q_reg[VN] == iss_fw0_q_reg) & (|(instr1_fp_read_mask[VN] & iss_fw0_write_mask)));

  assign instr1_fw1_iss_match = (instr1_fp_reads[VA] & (instr1_fp_read_q_reg[VA] == iss_fw1_q_reg) & (|(instr1_fp_read_mask[VA] & iss_fw1_write_mask))) |
                                (instr1_fp_reads[VM] & (instr1_fp_read_q_reg[VM] == iss_fw1_q_reg) & (|(instr1_fp_read_mask[VM] & iss_fw1_write_mask))) |
                                (instr1_fp_reads[VD] & (instr1_fp_read_q_reg[VD] == iss_fw1_q_reg) & (|(instr1_fp_read_mask[VD] & iss_fw1_write_mask))) |
                                (instr1_fp_reads[VN] & (instr1_fp_read_q_reg[VN] == iss_fw1_q_reg) & (|(instr1_fp_read_mask[VN] & iss_fw1_write_mask)));

  // For interlock mask for each instruction, separately for each write port in
  // Iss
  assign instr0_fw0_iss_mask  = {3{instr0_fw0_iss_match}} & fp_need_when_mask_iss(instr0_fp_need_f1, rf_wr_when_fw0_iss_i);
  assign instr0_fw1_iss_mask  = {3{instr0_fw1_iss_match}} & fp_need_when_mask_iss(instr0_fp_need_f1, rf_wr_when_fw1_iss_i);
  assign instr1_fw0_iss_mask  = {3{instr1_fw0_iss_match}} & fp_need_when_mask_iss(instr1_fp_need_f1, rf_wr_when_fw0_iss_i);
  assign instr1_fw1_iss_mask  = {3{instr1_fw1_iss_match}} & fp_need_when_mask_iss(instr1_fp_need_f1, rf_wr_when_fw1_iss_i);

  // -------------
  // De to F1
  // -------------
  // De will be in F1 when F1 in F3, F2 when F1 in F4:
  //
  //  De | Iss |  F1 |  F2 |  F3 |  F4 |
  // ----+-----+-----+-----+-----+-----|
  //  D  |     |  F  |     |     |     |
  //     |  D  |     |  F  |     |     |
  //     |     |  D  |     |  F  |     |
  //     |     |     |  D  |     |  F  |

  function [2:0] fp_need_when_mask_f1;
    input       need_f1;
    input [1:0] whn;

    // need |   when   | mask | Interlock         |
    // -----+----------+------+-------------------|
    //  F1  |  F3 (00) |  000 | 0 cycle interlock |
    //  F1  |  F4 (01) |  001 | 1 cycle interlock |
    //  F1  |  F5 (11) |  011 | 2 cycle interlock |
    //  F2  |  F3 (00) |  000 | 0 cycle interlock |
    //  F2  |  F4 (01) |  000 | 0 cycle interlock |
    //  F2  |  F5 (11) |  001 | 1 cycle interlock |

    case (need_f1)
      1'b0   : fp_need_when_mask_f1 = {2'b00, whn[1]};
      1'b1   : fp_need_when_mask_f1 = { 1'b0, whn};
      default: fp_need_when_mask_f1 = 3'bxxx;
    endcase
  endfunction

  assign instr0_fw0_f1_match  = (instr0_fp_reads[VA] & (instr0_fp_read_q_reg[VA] == f1_fw0_q_reg) & (|(instr0_fp_read_mask[VA] & f1_fw0_write_mask))) |
                                (instr0_fp_reads[VM] & (instr0_fp_read_q_reg[VM] == f1_fw0_q_reg) & (|(instr0_fp_read_mask[VM] & f1_fw0_write_mask))) |
                                (instr0_fp_reads[VD] & (instr0_fp_read_q_reg[VD] == f1_fw0_q_reg) & (|(instr0_fp_read_mask[VD] & f1_fw0_write_mask))) |
                                (instr0_fp_reads[VN] & (instr0_fp_read_q_reg[VN] == f1_fw0_q_reg) & (|(instr0_fp_read_mask[VN] & f1_fw0_write_mask)));
                             
  assign instr0_fw1_f1_match  = (instr0_fp_reads[VA] & (instr0_fp_read_q_reg[VA] == f1_fw1_q_reg) & (|(instr0_fp_read_mask[VA] & f1_fw1_write_mask))) |
                                (instr0_fp_reads[VM] & (instr0_fp_read_q_reg[VM] == f1_fw1_q_reg) & (|(instr0_fp_read_mask[VM] & f1_fw1_write_mask))) |
                                (instr0_fp_reads[VD] & (instr0_fp_read_q_reg[VD] == f1_fw1_q_reg) & (|(instr0_fp_read_mask[VD] & f1_fw1_write_mask))) |
                                (instr0_fp_reads[VN] & (instr0_fp_read_q_reg[VN] == f1_fw1_q_reg) & (|(instr0_fp_read_mask[VN] & f1_fw1_write_mask)));
                             
  assign instr1_fw0_f1_match  = (instr1_fp_reads[VA] & (instr1_fp_read_q_reg[VA] == f1_fw0_q_reg) & (|(instr1_fp_read_mask[VA] & f1_fw0_write_mask))) |
                                (instr1_fp_reads[VM] & (instr1_fp_read_q_reg[VM] == f1_fw0_q_reg) & (|(instr1_fp_read_mask[VM] & f1_fw0_write_mask))) |
                                (instr1_fp_reads[VD] & (instr1_fp_read_q_reg[VD] == f1_fw0_q_reg) & (|(instr1_fp_read_mask[VD] & f1_fw0_write_mask))) |
                                (instr1_fp_reads[VN] & (instr1_fp_read_q_reg[VN] == f1_fw0_q_reg) & (|(instr1_fp_read_mask[VN] & f1_fw0_write_mask)));
                             
  assign instr1_fw1_f1_match  = (instr1_fp_reads[VA] & (instr1_fp_read_q_reg[VA] == f1_fw1_q_reg) & (|(instr1_fp_read_mask[VA] & f1_fw1_write_mask))) |
                                (instr1_fp_reads[VM] & (instr1_fp_read_q_reg[VM] == f1_fw1_q_reg) & (|(instr1_fp_read_mask[VM] & f1_fw1_write_mask))) |
                                (instr1_fp_reads[VD] & (instr1_fp_read_q_reg[VD] == f1_fw1_q_reg) & (|(instr1_fp_read_mask[VD] & f1_fw1_write_mask))) |
                                (instr1_fp_reads[VN] & (instr1_fp_read_q_reg[VN] == f1_fw1_q_reg) & (|(instr1_fp_read_mask[VN] & f1_fw1_write_mask)));
                             
  assign instr0_fw0_f1_mask   = {3{instr0_fw0_f1_match}} & fp_need_when_mask_f1(instr0_fp_need_f1, rf_wr_when_fw0_f1_i);
  assign instr0_fw1_f1_mask   = {3{instr0_fw1_f1_match}} & fp_need_when_mask_f1(instr0_fp_need_f1, rf_wr_when_fw1_f1_i);
  assign instr1_fw0_f1_mask   = {3{instr1_fw0_f1_match}} & fp_need_when_mask_f1(instr1_fp_need_f1, rf_wr_when_fw0_f1_i);
  assign instr1_fw1_f1_mask   = {3{instr1_fw1_f1_match}} & fp_need_when_mask_f1(instr1_fp_need_f1, rf_wr_when_fw1_f1_i);

  // -------------
  // De to F2
  // -------------
  // De will be in F1 when F2 in F4, F2 when F2 in F5:
  //
  //  De | Iss |  F1 |  F2 |  F3 |  F4 |  F5 |
  // ----+-----+-----+-----+-----+-----+-----|
  //  D  |     |     |  F  |     |     |     |
  //     |  D  |     |     |  F  |     |     |
  //     |     |  D  |     |     |  F  |     |
  //     |     |     |  D  |     |     |  F  |

  function [2:0] fp_need_when_mask_f2;
    input       need_f1;
    input [1:0] whn;

    // need |   when   | mask | Interlock         |
    // -----+----------+------+-------------------|
    //  F1  |  F3 (00) |  000 | 0 cycle interlock |
    //  F1  |  F4 (01) |  000 | 0 cycle interlock |
    //  F1  |  F5 (11) |  001 | 1 cycle interlock |
    //  F2  |  F3 (00) |  000 | 0 cycle interlock |
    //  F2  |  F4 (01) |  000 | 0 cycle interlock |
    //  F2  |  F5 (11) |  000 | 0 cycle interlock |

    case (need_f1)
      1'b0   : fp_need_when_mask_f2 = 3'b000;
      1'b1   : fp_need_when_mask_f2 = {2'b00, whn[1]};
      default: fp_need_when_mask_f2 = 3'bxxx;
    endcase
  endfunction

  assign instr0_fw0_f2_match  = (instr0_fp_reads[VA] & (instr0_fp_read_q_reg[VA] == f2_fw0_q_reg) & (|(instr0_fp_read_mask[VA] & f2_fw0_write_mask))) |
                                (instr0_fp_reads[VM] & (instr0_fp_read_q_reg[VM] == f2_fw0_q_reg) & (|(instr0_fp_read_mask[VM] & f2_fw0_write_mask))) |
                                (instr0_fp_reads[VD] & (instr0_fp_read_q_reg[VD] == f2_fw0_q_reg) & (|(instr0_fp_read_mask[VD] & f2_fw0_write_mask))) |
                                (instr0_fp_reads[VN] & (instr0_fp_read_q_reg[VN] == f2_fw0_q_reg) & (|(instr0_fp_read_mask[VN] & f2_fw0_write_mask)));
                             
  assign instr0_fw1_f2_match  = (instr0_fp_reads[VA] & (instr0_fp_read_q_reg[VA] == f2_fw1_q_reg) & (|(instr0_fp_read_mask[VA] & f2_fw1_write_mask))) |
                                (instr0_fp_reads[VM] & (instr0_fp_read_q_reg[VM] == f2_fw1_q_reg) & (|(instr0_fp_read_mask[VM] & f2_fw1_write_mask))) |
                                (instr0_fp_reads[VD] & (instr0_fp_read_q_reg[VD] == f2_fw1_q_reg) & (|(instr0_fp_read_mask[VD] & f2_fw1_write_mask))) |
                                (instr0_fp_reads[VN] & (instr0_fp_read_q_reg[VN] == f2_fw1_q_reg) & (|(instr0_fp_read_mask[VN] & f2_fw1_write_mask)));
                             
  assign instr1_fw0_f2_match  = (instr1_fp_reads[VA] & (instr1_fp_read_q_reg[VA] == f2_fw0_q_reg) & (|(instr1_fp_read_mask[VA] & f2_fw0_write_mask))) |
                                (instr1_fp_reads[VM] & (instr1_fp_read_q_reg[VM] == f2_fw0_q_reg) & (|(instr1_fp_read_mask[VM] & f2_fw0_write_mask))) |
                                (instr1_fp_reads[VD] & (instr1_fp_read_q_reg[VD] == f2_fw0_q_reg) & (|(instr1_fp_read_mask[VD] & f2_fw0_write_mask))) |
                                (instr1_fp_reads[VN] & (instr1_fp_read_q_reg[VN] == f2_fw0_q_reg) & (|(instr1_fp_read_mask[VN] & f2_fw0_write_mask)));
                             
  assign instr1_fw1_f2_match  = (instr1_fp_reads[VA] & (instr1_fp_read_q_reg[VA] == f2_fw1_q_reg) & (|(instr1_fp_read_mask[VA] & f2_fw1_write_mask))) |
                                (instr1_fp_reads[VM] & (instr1_fp_read_q_reg[VM] == f2_fw1_q_reg) & (|(instr1_fp_read_mask[VM] & f2_fw1_write_mask))) |
                                (instr1_fp_reads[VD] & (instr1_fp_read_q_reg[VD] == f2_fw1_q_reg) & (|(instr1_fp_read_mask[VD] & f2_fw1_write_mask))) |
                                (instr1_fp_reads[VN] & (instr1_fp_read_q_reg[VN] == f2_fw1_q_reg) & (|(instr1_fp_read_mask[VN] & f2_fw1_write_mask)));
                             
  assign instr0_fw0_f2_mask   = {3{instr0_fw0_f2_match}} & fp_need_when_mask_f2(instr0_fp_need_f1, rf_wr_when_fw0_f2_i);
  assign instr0_fw1_f2_mask   = {3{instr0_fw1_f2_match}} & fp_need_when_mask_f2(instr0_fp_need_f1, rf_wr_when_fw1_f2_i);
  assign instr1_fw0_f2_mask   = {3{instr1_fw0_f2_match}} & fp_need_when_mask_f2(instr1_fp_need_f1, rf_wr_when_fw0_f2_i);
  assign instr1_fw1_f2_mask   = {3{instr1_fw1_f2_match}} & fp_need_when_mask_f2(instr1_fp_need_f1, rf_wr_when_fw1_f2_i);

  // -------------
  // Final hazard calculation
  // -------------

  // Form final mask for each slot by combining mask for each write port at each
  // pipe stage
  assign instr0_fp_interlock_mask = {3{iq_instr0_is_fn_i}} &
                                    (instr0_fw0_iss_mask | instr0_fw1_iss_mask |
                                     instr0_fw0_f1_mask  | instr0_fw1_f1_mask  |
                                     instr0_fw0_f2_mask  | instr0_fw1_f2_mask);

  assign instr1_fp_interlock_mask = {3{iq_instr1_is_fn_i}} &
                                    (instr1_fw0_iss_mask | instr1_fw1_iss_mask |
                                     instr1_fw0_f1_mask  | instr1_fw1_f1_mask  |
                                     instr1_fw0_f2_mask  | instr1_fw1_f2_mask);

  // Do not dual issue if instr1 would interlock for more cycles than instr0
  assign instr1_fp_interlock_hazard = |(instr1_fp_interlock_mask & ~instr0_fp_interlock_mask);

  // ------------------------------------------------------
  // Other hazards
  // ------------------------------------------------------

  // Detect when a slot 0 instruction needs to use both FPU pipelines, as this
  // means a slot 1 FP instruction cannot dual issue.
  // - ignore the special case when AES instructions can merge
  assign fp_datapath_resource_hazard = iq_instr1_is_fn_i & iq_instr0_is_fn_i & instr0_fp_uses_pipe1 & ~instr1_is_aesimc_aesmc;


end else begin : g_fp_dih_not_preset

  assign instr1_is_neon              = 1'b0;
  assign fn_dcu_valid_instr1         = 1'b0;

  assign fp_raw_hazard_de            = 1'b0;
  assign fp_waw_hazard_de            = 1'b0;
  assign fp_war_hazard_de            = 1'b0;
  assign instr1_fp_interlock_hazard  = 1'b0;
  assign fp_datapath_resource_hazard = 1'b0;

end endgenerate

  // ------------------------------------------------------
  // Detect a RAW hazard between De and later in the pipeline
  // ------------------------------------------------------
  // Do not dual issue an instruction if it will interlock with a later pipeline
  // stage, unless slot 0 will interlock anyway.
  //
  // This is calculated by comparing instr0 and instr1 with Iss, Ex1 and Ex2 and
  // detecting how many cycles each slot will interlock in Iss. If instr1 would
  // interlock for more cycles than instr0 by dual issuing then instr1 is not
  // dual issues. This means it will be in slot 0 on the next cycle, and so will
  // need to interlock for 1 less cycle and may also be able to dual issue with
  // another instruction in slot 1, improving overall performance.
  //
  // The interlock is calculated by creating a 3 bit mask for instr1 and instr0,
  // indicating how may cycles each would stall in Iss:
  //
  // 000 = No stall
  // 001 = Interlock for 1 cycle
  // 011 = Interlock for 2 cycles
  // 111 = Interlock for 3 cycles
  //
  // These masks are then compared to determine whether to dual issue or not.
  //
  // The calculation only looks as far ahead as Ex1, as when the instruction
  // currently in De is in Iss (the earliest it would need forwarding to), the
  // instruction currently in Ex1 will be in Ex2. For the purposes of this
  // calculation it is assumed all instructions can forward out of early Wr, as 
  // only a few, rare instructions cannot.

  // -------------
  // De to Iss
  // -------------
  // Instruction in De will be one stage behind instruction in Iss down the
  // pipeline
  //  De | Iss | Ex1 | Ex2 |  Wr |
  // ----+-----+-----+-----+-----|
  //  D  |  I  |     |     |     |
  //     |  D  |  I  |     |     |
  //     |     |  D  |  I  |     |
  //     |     |     |  D  |  I  |

  function [2:0] need_when_mask_iss;
    input [2:0] need;
    input [1:0] whn;

    // need  | when     | mask | Interlock         |
    // ------+----------+------+-------------------|
    // E_Iss | Ex1 (00) |  001 | 1 cycle interlock |
    // E_Iss | Ex2 (01) |  011 | 2 cycle interlock |
    // E_Iss | Wr  (11) |  111 | 3 cycle interlock |
    //  Iss  | Ex1 (00) |  000 | 0 cycle interlock |
    //  Iss  | Ex2 (01) |  001 | 1 cycle interlock |
    //  Iss  | Wr  (11) |  011 | 2 cycle interlock |
    //  Ex1  | Ex1 (00) |  000 | 0 cycle interlock |
    //  Ex1  | Ex2 (01) |  000 | 0 cycle interlock |
    //  Ex1  | Wr  (11) |  001 | 1 cycle interlock |
    //  Ex2  | Ex1 (00) |  000 | 0 cycle interlock |
    //  Ex2  | Ex2 (01) |  000 | 0 cycle interlock |
    //  Ex2  | Wr  (11) |  000 | 0 cycle interlock |

    case (need)
      `CA53_RF_RD_NEED_EARLY_ISS: need_when_mask_iss = {whn, 1'b1};
      `CA53_RF_RD_NEED_LATE_ISS : need_when_mask_iss = {1'b0, whn};
      `CA53_RF_RD_NEED_EX1      : need_when_mask_iss = {2'b00, whn[1]};
      `CA53_RF_RD_NEED_EX2      : need_when_mask_iss = 3'b000;
      default                   : need_when_mask_iss = 3'bxxx;
    endcase
  endfunction

  // Detect when Iss is writing a register read by De
  assign instr0_de_w0_iss_match = { (instr0_reg[R3_0  ] == rf_wr_vaddr_w0_iss_i),
                                    (instr0_reg[R11_8 ] == rf_wr_vaddr_w0_iss_i),
                                    (instr0_reg[R15_12] == rf_wr_vaddr_w0_iss_i),
                                    (instr0_reg[R19_16] == rf_wr_vaddr_w0_iss_i)}              & {4{rf_wr_en_w0_iss_i}};
                                
  assign instr0_de_w1_iss_match = { (instr0_reg[R3_0  ] == rf_wr_vaddr_w1_iss_i),
                                    (instr0_reg[R11_8 ] == rf_wr_vaddr_w1_iss_i),
                                    (instr0_reg[R15_12] == rf_wr_vaddr_w1_iss_i),
                                   ((instr0_reg[R19_16] == rf_wr_vaddr_w1_iss_i) &
                                    ~(adrp_valid_iss_qual[0] & instr0_can_adrp_forward_qual))} & {4{rf_wr_en_w1_iss_i}};
                                
  assign instr0_de_w2_iss_match = { (instr0_reg[R3_0  ] == rf_wr_vaddr_w2_iss_i),
                                    (instr0_reg[R11_8 ] == rf_wr_vaddr_w2_iss_i),
                                    (instr0_reg[R15_12] == rf_wr_vaddr_w2_iss_i),
                                   ((instr0_reg[R19_16] == rf_wr_vaddr_w2_iss_i) &
                                    ~(adrp_valid_iss_qual[1] & instr0_can_adrp_forward_qual))} & {4{rf_wr_en_w2_iss_i}};

  assign instr1_de_w0_iss_match = { (instr1_reg[R3_0  ] == rf_wr_vaddr_w0_iss_i),
                                    (instr1_reg[R11_8 ] == rf_wr_vaddr_w0_iss_i),
                                    (instr1_reg[R15_12] == rf_wr_vaddr_w0_iss_i),
                                    (instr1_reg[R19_16] == rf_wr_vaddr_w0_iss_i)}              & {4{rf_wr_en_w0_iss_i}};
                                
  assign instr1_de_w1_iss_match = { (instr1_reg[R3_0  ] == rf_wr_vaddr_w1_iss_i),
                                    (instr1_reg[R11_8 ] == rf_wr_vaddr_w1_iss_i),
                                    (instr1_reg[R15_12] == rf_wr_vaddr_w1_iss_i),
                                   ((instr1_reg[R19_16] == rf_wr_vaddr_w1_iss_i) &
                                    ~(adrp_valid_iss_qual[0] & instr1_can_adrp_forward_qual))} & {4{rf_wr_en_w1_iss_i}};
                                
  assign instr1_de_w2_iss_match = { (instr1_reg[R3_0  ] == rf_wr_vaddr_w2_iss_i),
                                    (instr1_reg[R11_8 ] == rf_wr_vaddr_w2_iss_i),
                                    (instr1_reg[R15_12] == rf_wr_vaddr_w2_iss_i),
                                   ((instr1_reg[R19_16] == rf_wr_vaddr_w2_iss_i) &
                                    ~(adrp_valid_iss_qual[1] & instr1_can_adrp_forward_qual))} & {4{rf_wr_en_w2_iss_i}};

  // For interlock mask for each instruction, separately for each write port in
  // Iss
  assign instr0_de_w0_iss_mask  = ({3{instr0_de_w0_iss_match[R3_0  ]}} & need_when_mask_iss(instr0_need_de[R3_0  ], rf_wr_when_w0_iss_i)) |
                                  ({3{instr0_de_w0_iss_match[R11_8 ]}} & need_when_mask_iss(instr0_need_de[R11_8 ], rf_wr_when_w0_iss_i)) |
                                  ({3{instr0_de_w0_iss_match[R15_12]}} & need_when_mask_iss(instr0_need_de[R15_12], rf_wr_when_w0_iss_i)) |
                                  ({3{instr0_de_w0_iss_match[R19_16]}} & need_when_mask_iss(instr0_need_de[R19_16], rf_wr_when_w0_iss_i));

  assign instr0_de_w1_iss_mask  = ({3{instr0_de_w1_iss_match[R3_0  ]}} & need_when_mask_iss(instr0_need_de[R3_0  ], rf_wr_when_w1_iss_i)) |
                                  ({3{instr0_de_w1_iss_match[R11_8 ]}} & need_when_mask_iss(instr0_need_de[R11_8 ], rf_wr_when_w1_iss_i)) |
                                  ({3{instr0_de_w1_iss_match[R15_12]}} & need_when_mask_iss(instr0_need_de[R15_12], rf_wr_when_w1_iss_i)) |
                                  ({3{instr0_de_w1_iss_match[R19_16]}} & need_when_mask_iss(instr0_need_de[R19_16], rf_wr_when_w1_iss_i));

  assign instr0_de_w2_iss_mask  = ({3{instr0_de_w2_iss_match[R3_0  ]}} & need_when_mask_iss(instr0_need_de[R3_0  ], rf_wr_when_w2_iss_i)) |
                                  ({3{instr0_de_w2_iss_match[R11_8 ]}} & need_when_mask_iss(instr0_need_de[R11_8 ], rf_wr_when_w2_iss_i)) |
                                  ({3{instr0_de_w2_iss_match[R15_12]}} & need_when_mask_iss(instr0_need_de[R15_12], rf_wr_when_w2_iss_i)) |
                                  ({3{instr0_de_w2_iss_match[R19_16]}} & need_when_mask_iss(instr0_need_de[R19_16], rf_wr_when_w2_iss_i));

  assign instr1_de_w0_iss_mask  = ({3{instr1_de_w0_iss_match[R3_0  ]}} & need_when_mask_iss(instr1_need_de[R3_0  ], rf_wr_when_w0_iss_i)) |
                                  ({3{instr1_de_w0_iss_match[R11_8 ]}} & need_when_mask_iss(instr1_need_de[R11_8 ], rf_wr_when_w0_iss_i)) |
                                  ({3{instr1_de_w0_iss_match[R15_12]}} & need_when_mask_iss(instr1_need_de[R15_12], rf_wr_when_w0_iss_i)) |
                                  ({3{instr1_de_w0_iss_match[R19_16]}} & need_when_mask_iss(instr1_need_de[R19_16], rf_wr_when_w0_iss_i));

  assign instr1_de_w1_iss_mask  = ({3{instr1_de_w1_iss_match[R3_0  ]}} & need_when_mask_iss(instr1_need_de[R3_0  ], rf_wr_when_w1_iss_i)) |
                                  ({3{instr1_de_w1_iss_match[R11_8 ]}} & need_when_mask_iss(instr1_need_de[R11_8 ], rf_wr_when_w1_iss_i)) |
                                  ({3{instr1_de_w1_iss_match[R15_12]}} & need_when_mask_iss(instr1_need_de[R15_12], rf_wr_when_w1_iss_i)) |
                                  ({3{instr1_de_w1_iss_match[R19_16]}} & need_when_mask_iss(instr1_need_de[R19_16], rf_wr_when_w1_iss_i));

  assign instr1_de_w2_iss_mask  = ({3{instr1_de_w2_iss_match[R3_0  ]}} & need_when_mask_iss(instr1_need_de[R3_0  ], rf_wr_when_w2_iss_i)) |
                                  ({3{instr1_de_w2_iss_match[R11_8 ]}} & need_when_mask_iss(instr1_need_de[R11_8 ], rf_wr_when_w2_iss_i)) |
                                  ({3{instr1_de_w2_iss_match[R15_12]}} & need_when_mask_iss(instr1_need_de[R15_12], rf_wr_when_w2_iss_i)) |
                                  ({3{instr1_de_w2_iss_match[R19_16]}} & need_when_mask_iss(instr1_need_de[R19_16], rf_wr_when_w2_iss_i));

  // -------------
  // De to Ex1
  // -------------
  // Instruction in De will be two stages behind instruction Ex1 down the
  // pipeline
  //  De | Iss | Ex1 | Ex2 |  Wr |
  // ----+-----+-----+-----+-----|
  //  D  |     |  E  |     |     |
  //     |  D  |     |  E  |     |
  //     |     |  D  |     |  E  |

  function [2:0] need_when_mask_ex1;
    input [2:0] need;
    input [1:0] whn;

    // need  | when     | mask | Interlock         |
    // ------+----------+------+-------------------|
    // E_Iss | Ex1 (00) |  000 | 0 cycle interlock |
    // E_Iss | Ex2 (01) |  001 | 1 cycle interlock |
    // E_Iss | Wr  (11) |  011 | 2 cycle interlock |
    //  Iss  | Ex1 (00) |  000 | 0 cycle interlock |
    //  Iss  | Ex2 (01) |  000 | 0 cycle interlock |
    //  Iss  | Wr  (11) |  001 | 1 cycle interlock |
    //  Ex1  | Ex1 (00) |  000 | 0 cycle interlock |
    //  Ex1  | Ex2 (01) |  000 | 0 cycle interlock |
    //  Ex1  | Wr  (11) |  000 | 0 cycle interlock |
    //  Ex2  | Ex1 (00) |  000 | 0 cycle interlock |
    //  Ex2  | Ex2 (01) |  000 | 0 cycle interlock |
    //  Ex2  | Wr  (11) |  000 | 0 cycle interlock |
                           
    case (need)
      `CA53_RF_RD_NEED_EARLY_ISS: need_when_mask_ex1 = {1'b0, whn};
      `CA53_RF_RD_NEED_LATE_ISS : need_when_mask_ex1 = {2'b00, whn[1]};
      `CA53_RF_RD_NEED_EX1      : need_when_mask_ex1 = 3'b000;
      `CA53_RF_RD_NEED_EX2      : need_when_mask_ex1 = 3'b000;
      default                   : need_when_mask_ex1 = 3'bxxx;
    endcase
  endfunction

  // Detect when Iss is writing a register read by De
  assign instr0_de_w0_ex1_match     = {(instr0_reg[R3_0  ] == rf_wr_vaddr_w0_ex1_i),
                                       (instr0_reg[R11_8 ] == rf_wr_vaddr_w0_ex1_i),
                                       (instr0_reg[R15_12] == rf_wr_vaddr_w0_ex1_i),
                                       (instr0_reg[R19_16] == rf_wr_vaddr_w0_ex1_i)} & {4{rf_wr_en_w0_ex1_i}};
                                   
  assign instr0_de_w1_ex1_match     = {(instr0_reg[R3_0  ] == rf_wr_vaddr_w1_ex1_i),
                                       (instr0_reg[R11_8 ] == rf_wr_vaddr_w1_ex1_i),
                                       (instr0_reg[R15_12] == rf_wr_vaddr_w1_ex1_i),
                                       (instr0_reg[R19_16] == rf_wr_vaddr_w1_ex1_i)} & {4{rf_wr_en_w1_ex1_i}};
                                   
  assign instr0_de_w2_ex1_match     = {(instr0_reg[R3_0  ] == rf_wr_vaddr_w2_ex1_i),
                                       (instr0_reg[R11_8 ] == rf_wr_vaddr_w2_ex1_i),
                                       (instr0_reg[R15_12] == rf_wr_vaddr_w2_ex1_i),
                                       (instr0_reg[R19_16] == rf_wr_vaddr_w2_ex1_i)} & {4{rf_wr_en_w2_ex1_i}};

  assign instr1_de_w0_ex1_match     = {(instr1_reg[R3_0  ] == rf_wr_vaddr_w0_ex1_i),
                                       (instr1_reg[R11_8 ] == rf_wr_vaddr_w0_ex1_i),
                                       (instr1_reg[R15_12] == rf_wr_vaddr_w0_ex1_i),
                                       (instr1_reg[R19_16] == rf_wr_vaddr_w0_ex1_i)} & {4{rf_wr_en_w0_ex1_i}};
                                   
  assign instr1_de_w1_ex1_match     = {(instr1_reg[R3_0  ] == rf_wr_vaddr_w1_ex1_i),
                                       (instr1_reg[R11_8 ] == rf_wr_vaddr_w1_ex1_i),
                                       (instr1_reg[R15_12] == rf_wr_vaddr_w1_ex1_i),
                                       (instr1_reg[R19_16] == rf_wr_vaddr_w1_ex1_i)} & {4{rf_wr_en_w1_ex1_i}};
                                   
  assign instr1_de_w2_ex1_match     = {(instr1_reg[R3_0  ] == rf_wr_vaddr_w2_ex1_i),
                                       (instr1_reg[R11_8 ] == rf_wr_vaddr_w2_ex1_i),
                                       (instr1_reg[R15_12] == rf_wr_vaddr_w2_ex1_i),
                                       (instr1_reg[R19_16] == rf_wr_vaddr_w2_ex1_i)} & {4{rf_wr_en_w2_ex1_i}};

  // For interlock mask for each instruction, separately for each write port in
  // Ex1
  assign instr0_de_w0_ex1_mask  = ({3{instr0_de_w0_ex1_match[R3_0  ]}} & need_when_mask_ex1(instr0_need_de[R3_0  ], rf_wr_when_w0_ex1_i)) |
                                  ({3{instr0_de_w0_ex1_match[R11_8 ]}} & need_when_mask_ex1(instr0_need_de[R11_8 ], rf_wr_when_w0_ex1_i)) |
                                  ({3{instr0_de_w0_ex1_match[R15_12]}} & need_when_mask_ex1(instr0_need_de[R15_12], rf_wr_when_w0_ex1_i)) |
                                  ({3{instr0_de_w0_ex1_match[R19_16]}} & need_when_mask_ex1(instr0_need_de[R19_16], rf_wr_when_w0_ex1_i));

  assign instr0_de_w1_ex1_mask  = ({3{instr0_de_w1_ex1_match[R3_0  ]}} & need_when_mask_ex1(instr0_need_de[R3_0  ], rf_wr_when_w1_ex1_i)) |
                                  ({3{instr0_de_w1_ex1_match[R11_8 ]}} & need_when_mask_ex1(instr0_need_de[R11_8 ], rf_wr_when_w1_ex1_i)) |
                                  ({3{instr0_de_w1_ex1_match[R15_12]}} & need_when_mask_ex1(instr0_need_de[R15_12], rf_wr_when_w1_ex1_i)) |
                                  ({3{instr0_de_w1_ex1_match[R19_16]}} & need_when_mask_ex1(instr0_need_de[R19_16], rf_wr_when_w1_ex1_i));

  assign instr0_de_w2_ex1_mask  = ({3{instr0_de_w2_ex1_match[R3_0  ]}} & need_when_mask_ex1(instr0_need_de[R3_0  ], rf_wr_when_w2_ex1_i)) |
                                  ({3{instr0_de_w2_ex1_match[R11_8 ]}} & need_when_mask_ex1(instr0_need_de[R11_8 ], rf_wr_when_w2_ex1_i)) |
                                  ({3{instr0_de_w2_ex1_match[R15_12]}} & need_when_mask_ex1(instr0_need_de[R15_12], rf_wr_when_w2_ex1_i)) |
                                  ({3{instr0_de_w2_ex1_match[R19_16]}} & need_when_mask_ex1(instr0_need_de[R19_16], rf_wr_when_w2_ex1_i));

  assign instr1_de_w0_ex1_mask  = ({3{instr1_de_w0_ex1_match[R3_0  ]}} & need_when_mask_ex1(instr1_need_de[R3_0  ], rf_wr_when_w0_ex1_i)) |
                                  ({3{instr1_de_w0_ex1_match[R11_8 ]}} & need_when_mask_ex1(instr1_need_de[R11_8 ], rf_wr_when_w0_ex1_i)) |
                                  ({3{instr1_de_w0_ex1_match[R15_12]}} & need_when_mask_ex1(instr1_need_de[R15_12], rf_wr_when_w0_ex1_i)) |
                                  ({3{instr1_de_w0_ex1_match[R19_16]}} & need_when_mask_ex1(instr1_need_de[R19_16], rf_wr_when_w0_ex1_i));

  assign instr1_de_w1_ex1_mask  = ({3{instr1_de_w1_ex1_match[R3_0  ]}} & need_when_mask_ex1(instr1_need_de[R3_0  ], rf_wr_when_w1_ex1_i)) |
                                  ({3{instr1_de_w1_ex1_match[R11_8 ]}} & need_when_mask_ex1(instr1_need_de[R11_8 ], rf_wr_when_w1_ex1_i)) |
                                  ({3{instr1_de_w1_ex1_match[R15_12]}} & need_when_mask_ex1(instr1_need_de[R15_12], rf_wr_when_w1_ex1_i)) |
                                  ({3{instr1_de_w1_ex1_match[R19_16]}} & need_when_mask_ex1(instr1_need_de[R19_16], rf_wr_when_w1_ex1_i));

  assign instr1_de_w2_ex1_mask  = ({3{instr1_de_w2_ex1_match[R3_0  ]}} & need_when_mask_ex1(instr1_need_de[R3_0  ], rf_wr_when_w2_ex1_i)) |
                                  ({3{instr1_de_w2_ex1_match[R11_8 ]}} & need_when_mask_ex1(instr1_need_de[R11_8 ], rf_wr_when_w2_ex1_i)) |
                                  ({3{instr1_de_w2_ex1_match[R15_12]}} & need_when_mask_ex1(instr1_need_de[R15_12], rf_wr_when_w2_ex1_i)) |
                                  ({3{instr1_de_w2_ex1_match[R19_16]}} & need_when_mask_ex1(instr1_need_de[R19_16], rf_wr_when_w2_ex1_i));

  // -------------
  // Final hazard calculation
  // -------------

  // Form final mask for each slot by combining mask for each write port at each
  // pipe stage
  assign instr0_interlock_mask = instr0_de_w0_iss_mask | instr0_de_w1_iss_mask | instr0_de_w2_iss_mask |
                                 instr0_de_w0_ex1_mask | instr0_de_w1_ex1_mask | instr0_de_w2_ex1_mask;

  assign instr1_interlock_mask = instr1_de_w0_iss_mask | instr1_de_w1_iss_mask | instr1_de_w2_iss_mask |
                                 instr1_de_w0_ex1_mask | instr1_de_w1_ex1_mask | instr1_de_w2_ex1_mask;

  // Do not dual issue if instr1 would interlock for more cycles than instr0
  assign instr1_interlock_hazard = |(instr1_interlock_mask & ~instr0_interlock_mask);

  // ------------------------------------------------------
  // Detect when the address operand of a load/store
  // instruction can be written when reading the result of
  // an ADRP
  // ------------------------------------------------------

  assign instr0_is_adrp = instr0_a64_only & iq_instr0_i[28:25] == 4'b1001;

  // Qualify the ADRP indication with whether the instructions are in the same
  // page and there are no intervening branches
  assign adrp_valid_iss_qual = adrp_valid_iss_i & iss_pc_in_same_page_i & {2{~br_valid_instr0 & ~taken_br_instr_iss_i}} & {rf_wr_en_w2_iss_i, rf_wr_en_w1_iss_i};

  always @*
    case (iq_instr0_is_fn_i ? {iq_instr0_i[24:23], iq_instr0_i[21]} : {1'b0, iq_instr0_i[22:21]})
      3'b000:  instr0_ls_imm_mask = 4'b0000;
      3'b001:  instr0_ls_imm_mask = 4'b1000;
      3'b010:  instr0_ls_imm_mask = 4'b1100;
      3'b011:  instr0_ls_imm_mask = 4'b1110;
      3'b100:  instr0_ls_imm_mask = 4'b1111;
      default: instr0_ls_imm_mask = {4{1'bx}};
    endcase

  assign instr0_can_adrp_forward_qual = instr0_can_adrp_forward & (instr0_reg[R19_16] != 5'd31) & ((iq_instr0_i[11:8] & instr0_ls_imm_mask) == 4'b0000);

  assign instr0_adrp_fwd_src[1] = instr0_can_adrp_forward_qual & adrp_valid_iss_qual[1] & (instr0_reg[R19_16] == rf_wr_vaddr_w2_iss_i);
  assign instr0_adrp_fwd_src[2] = instr0_can_adrp_forward_qual & adrp_valid_iss_qual[0] & (instr0_reg[R19_16] == rf_wr_vaddr_w1_iss_i) &
                                   ~(|instr0_de_w0_iss_match) & ~(|instr0_de_w2_iss_match);

  assign instr0_adrp_fwd = (|instr0_adrp_fwd_src);

  always @*
    case (iq_instr1_is_fn_i ? {iq_instr1_i[24:23], iq_instr1_i[21]} : {1'b0, iq_instr1_i[22:21]})
      3'b000:  instr1_ls_imm_mask = 4'b0000;
      3'b001:  instr1_ls_imm_mask = 4'b1000;
      3'b010:  instr1_ls_imm_mask = 4'b1100;
      3'b011:  instr1_ls_imm_mask = 4'b1110;
      3'b100:  instr1_ls_imm_mask = 4'b1111;
      default: instr1_ls_imm_mask = {4{1'bx}};
    endcase

  assign instr1_can_adrp_forward_qual = instr1_can_adrp_forward & (instr1_reg[R19_16] != 5'd31) & ((iq_instr1_i[11:8] & instr1_ls_imm_mask) == 4'b0000);

  assign instr1_adrp_fwd_src[0] = instr1_can_adrp_forward_qual & instr0_is_adrp         & (instr1_reg[R19_16] == instr0_reg[R11_8W]);
  assign instr1_adrp_fwd_src[1] = instr1_can_adrp_forward_qual & adrp_valid_iss_qual[1] & (instr1_reg[R19_16] == rf_wr_vaddr_w2_iss_i);
  assign instr1_adrp_fwd_src[2] = instr1_can_adrp_forward_qual & adrp_valid_iss_qual[0] & (instr1_reg[R19_16] == rf_wr_vaddr_w1_iss_i) &
                                   ~(|instr1_de_w0_iss_match) & ~(|instr1_de_w2_iss_match);

  assign instr1_adrp_fwd = (|instr1_adrp_fwd_src);

  // ------------------------------------------------------
  // Detect when can skew an ALU operation into Ex1
  // ------------------------------------------------------
  // Certain ALU operations which normally execute in Ex2 (and so have a need 
  // of late Ex1 and when of Ex2) can be skewed back to execute in Ex1 (and
  // so have a need of late Iss and a when of Ex1). This means they can 
  // forward out sooner, potentially preventing interlocks with later 
  // instructions, but need forwarding in to sooner, and so may interlock with
  // earlier instructions.
  // 
  // Therefore, instructions are skewed back if they will not interlock with 
  // an earlier instruction.
  // 
  // To calculate when instructions would interlock with an earlier instruction,
  // the RAW hazarding is calculated assuming a need of late Iss. If this does
  // not indicate an interlock, the instruction can be skewed back.
  
  // ------
  // Slot 0
  // ------
  assign instr0_w0_iss_hazard_valid_skew = instr0_reads & ({4{rf_wr_when_w0_iss_i[WHN_NOT_EX1]}} | {4{rf_wr_when_w0_iss_i[WHN_NOT_EX2]}});
  assign instr0_w1_iss_hazard_valid_skew = instr0_reads & ({4{rf_wr_when_w1_iss_i[WHN_NOT_EX1]}} | {4{rf_wr_when_w1_iss_i[WHN_NOT_EX2]}});
  assign instr0_w2_iss_hazard_valid_skew = instr0_reads & ({4{rf_wr_when_w2_iss_i[WHN_NOT_EX1]}} | {4{rf_wr_when_w2_iss_i[WHN_NOT_EX2]}});

  assign instr0_raw_hazard_w0_iss_skew   = |(instr0_de_w0_iss_match & instr0_w0_iss_hazard_valid_skew);
  assign instr0_raw_hazard_w1_iss_skew   = |(instr0_de_w1_iss_match & instr0_w1_iss_hazard_valid_skew);
  assign instr0_raw_hazard_w2_iss_skew   = |(instr0_de_w2_iss_match & instr0_w2_iss_hazard_valid_skew);


  assign instr0_w0_ex1_hazard_valid_skew = instr0_reads & {4{rf_wr_when_w0_ex1_i[WHN_NOT_EX2]}};
  assign instr0_w1_ex1_hazard_valid_skew = instr0_reads & {4{rf_wr_when_w1_ex1_i[WHN_NOT_EX2]}};
  assign instr0_w2_ex1_hazard_valid_skew = instr0_reads & {4{rf_wr_when_w2_ex1_i[WHN_NOT_EX2]}};

  assign instr0_raw_hazard_w0_ex1_skew   = |(instr0_de_w0_ex1_match & instr0_w0_ex1_hazard_valid_skew);
  assign instr0_raw_hazard_w1_ex1_skew   = |(instr0_de_w1_ex1_match & instr0_w1_ex1_hazard_valid_skew);
  assign instr0_raw_hazard_w2_ex1_skew   = |(instr0_de_w2_ex1_match & instr0_w2_ex1_hazard_valid_skew);

  assign instr0_skew_hazard = instr0_raw_hazard_w0_iss_skew |
                              instr0_raw_hazard_w1_iss_skew |
                              instr0_raw_hazard_w2_iss_skew |
                              instr0_raw_hazard_w0_ex1_skew |
                              instr0_raw_hazard_w1_ex1_skew |
                              instr0_raw_hazard_w2_ex1_skew;

  assign iq_skew_instr0      = instr0_skewable & ~instr0_skew_hazard;
  assign iq_skew_instr0_o    = iq_skew_instr0;
  // The need should only be changed to late Iss if it is already set to Ex1
  // (i.e. not if the read port is not being used by the skewed instruction)
  assign iq_skew_instr0_r0_o = instr0_skew_r0  & ~instr0_skew_hazard;
  assign iq_skew_instr0_r1_o = instr0_skew_r1  & ~instr0_skew_hazard;

  // ------
  // Slot 1
  // ------
  assign instr1_raw_hazard_11_8_de_skew  = (({instr1_reads[R3_0  ], instr1_reg[R3_0  ]} == {1'b1, instr0_reg[R11_8W]}) |
                                            ({instr1_reads[R11_8 ], instr1_reg[R11_8 ]} == {1'b1, instr0_reg[R11_8W]}) |
                                            ({instr1_reads[R15_12], instr1_reg[R15_12]} == {1'b1, instr0_reg[R11_8W]}) |
                                            ({instr1_reads[R19_16], instr1_reg[R19_16]} == {1'b1, instr0_reg[R11_8W]})) &
                                           instr0_11_8_written;

  assign instr1_w0_iss_hazard_valid_skew = instr1_reads & ({4{rf_wr_when_w0_iss_i[WHN_NOT_EX1]}} | {4{rf_wr_when_w0_iss_i[WHN_NOT_EX2]}});
  assign instr1_w1_iss_hazard_valid_skew = instr1_reads & ({4{rf_wr_when_w1_iss_i[WHN_NOT_EX1]}} | {4{rf_wr_when_w1_iss_i[WHN_NOT_EX2]}});
  assign instr1_w2_iss_hazard_valid_skew = instr1_reads & ({4{rf_wr_when_w2_iss_i[WHN_NOT_EX1]}} | {4{rf_wr_when_w2_iss_i[WHN_NOT_EX2]}});

  assign instr1_raw_hazard_w0_iss_skew   = |(instr1_de_w0_iss_match & instr1_w0_iss_hazard_valid_skew);
  assign instr1_raw_hazard_w1_iss_skew   = |(instr1_de_w1_iss_match & instr1_w1_iss_hazard_valid_skew);
  assign instr1_raw_hazard_w2_iss_skew   = |(instr1_de_w2_iss_match & instr1_w2_iss_hazard_valid_skew);

  assign instr1_w0_ex1_hazard_valid_skew = instr1_reads & {4{rf_wr_when_w0_ex1_i[WHN_NOT_EX2]}};
  assign instr1_w1_ex1_hazard_valid_skew = instr1_reads & {4{rf_wr_when_w1_ex1_i[WHN_NOT_EX2]}};
  assign instr1_w2_ex1_hazard_valid_skew = instr1_reads & {4{rf_wr_when_w2_ex1_i[WHN_NOT_EX2]}};

  assign instr1_raw_hazard_w0_ex1_skew   = |(instr1_de_w0_ex1_match & instr1_w0_ex1_hazard_valid_skew);
  assign instr1_raw_hazard_w1_ex1_skew   = |(instr1_de_w1_ex1_match & instr1_w1_ex1_hazard_valid_skew);
  assign instr1_raw_hazard_w2_ex1_skew   = |(instr1_de_w2_ex1_match & instr1_w2_ex1_hazard_valid_skew);

  assign instr1_skew_hazard = instr1_raw_hazard_11_8_de_skew  |
                              instr1_raw_hazard_w0_iss_skew   |
                              instr1_raw_hazard_w1_iss_skew   |
                              instr1_raw_hazard_w2_iss_skew   |
                              instr1_raw_hazard_w0_ex1_skew   |
                              instr1_raw_hazard_w1_ex1_skew   |
                              instr1_raw_hazard_w2_ex1_skew;

  assign iq_skew_instr1_o    = instr1_skewable & ~instr1_skew_hazard;
  // The need should only be changed to late Iss if it is already set to Ex1
  // (i.e. not if the read port is not being used by the skewed instruction)
  assign iq_skew_instr1_r0_o = instr1_skew_r0  & ~instr1_skew_hazard;
  assign iq_skew_instr1_r1_o = instr1_skew_r1  & ~instr1_skew_hazard;

  // ------------------------------------------------------
  // Detect structural hazards
  // ------------------------------------------------------

  // Slot 0 and Slot 1 cannot use R2 at the same time if either is
  // using it for the shift input to ALU0/1.
  assign instr1_r2_hazard = instr1_r2_enabled & instr0_r2_enabled;

  // Detect if both instructions need to use the W0 write port
  assign instr1_w0_hazard = instr1_w0_enabled & instr0_w0_enabled;

  // Detect when instructions in both slots want to access the same datapath
  // resources:
  // - This can be ignored for the ALU pipe, as the datapath contains one for
  // each slot
  // - There are two store pipes, but both slot 0 and slot 1 can use both, so
  // can still get resource hazard
  // - Dual issue of slot 1 IT over a slot 0 Other instruction suppressed to
  // simplify the muxing in the decoders
  assign instr1_is_it = iq_instr1_is_ot_i & (iq_instr1_i[28] == 1'b0) & (iq_instr1_i[32:29] != 4'b1111);

  assign instr1_datapath_resource_hazard = (dcu_valid_instr1  & dcu_valid_instr0)   |
                                           (br_valid_instr1   & br_valid_instr0)    |
                                           (mac_valid_instr1  & (mac_valid_instr0 |
                                                                 div_valid_instr0)) |
                                           (str_valid_instr1  & str1_valid_instr0)  |
                                           (str0_valid_instr1 & str_valid_instr0)   |
                                           (iq_instr0_is_ot_i & instr1_is_it);

  // Detect if the slot 1 instruction is FP/Neon, but would cause a trap
  // Suppress dual-issue in this case so that the slot 0 exception logic
  // can handle the trap
  assign instr1_fn_trap_hazard = iq_instr1_is_fn_i & 
                                 (cp_trap_fp_i | (instr1_is_neon & cp_trap_neon_i));

  // ------------------------------------------------------
  // Special-case dual-issue for AES instructions
  // ------------------------------------------------------

  // AESIMC and AESMC are marked as dual-issuable, as they can be merged with
  // a preceding AESD or AESE respectively. The logic here suppresses the
  // dual-issue of an AESIMC/AESMC instruction when the prerequisites are not
  // met

  assign instr1_is_aesimc_aesmc = iq_instr1_is_fn_i                 &
                                  (iq_instr1_i[28:23] == 6'b111111) &
                                  (iq_instr1_i[21:16] == 6'b110000) &
                                  (iq_instr1_i[11: 7] == 5'b00111)  &
                                  (iq_instr1_i[ 4]    == 1'b0);

  assign instr0_is_aesd_aese    = iq_instr0_is_fn_i                  &
                                  (iq_instr0_i[28:23] == 6'b111111)  &
                                  (iq_instr0_i[21:16] == 6'b110000)  &
                                  (iq_instr0_i[11: 7] == 5'b00110)   &
                                  (iq_instr0_i[ 4]    == 1'b0);

  assign can_merge_aes_ops = // Instr0 is AESD/AESE
                             instr0_is_aesd_aese                                                              &
                             // Pair is AESD:AESIMC or AESE:AESMC
                             (iq_instr1_i[6] == iq_instr0_i[6])                                               &
                             // Pair have equal condition codes
                             (iq_instr0_ctl_aarch64_i | (iq_instr0_i[32:29] == iq_instr1_i[32:29]))           &
                             // Vm of instr1 == Vd of instr0
                             ({iq_instr1_i[ 5], iq_instr1_i[ 3: 0]} == {iq_instr0_i[22], iq_instr0_i[15:12]}) &
                             // instr1 has Vm == Vd
                             ({iq_instr1_i[ 5], iq_instr1_i[ 3: 0]} == {iq_instr1_i[22], iq_instr1_i[15:12]});

  assign instr1_aes_cannot_merge = instr1_is_aesimc_aesmc & ~can_merge_aes_ops;

  // ------------------------------------------------------
  // Output
  // ------------------------------------------------------
  // Hazard if any hazard detected.
  assign iq_instr1_dih_o = ((raw_hazard_3_0_de   |
                             raw_hazard_11_8_de  |
                             raw_hazard_15_12_de |
                             raw_hazard_19_16_de) & ~ignore_raw_hazard_de) |
                           raw_hazard_pc_de  |
                           raw_hazard_lr_de  |
                           instr1_interlock_hazard  |
                           instr1_cc_hazard |
                           instr1_r2_hazard |
                           instr1_w0_hazard |
                           instr1_datapath_resource_hazard  |
                           instr1_aes_cannot_merge |
                           instr1_fn_trap_hazard |
                           fp_datapath_resource_hazard |
                           fp_waw_hazard_de |
                           fp_war_hazard_de |
                           fp_raw_hazard_de |
                           instr1_fp_interlock_hazard;

  // Indicate when instr0 using AGU
  assign iq_instr0_d0_uses_dcu_o      = dcu_valid_instr0;

  // Indicate when R2/store pipes being used - used for read port muxing
  assign iq_instr0_r2_enabled_o       = instr0_r2_enabled;
  assign iq_instr0_w0_enabled_o       = instr0_w0_enabled;
  assign iq_instr1_br_valid_o         = br_valid_instr1;
  assign fn_dcu_valid_instr1_o        = fn_dcu_valid_instr1;

  assign iq_instr1_datapath_resource_hazard_o = instr1_datapath_resource_hazard;

  // Indicate when Slot 0 sets flags
  assign iq_instr0_sets_ccflags_o     = instr0_sets_ccflags;

  // Indicate when slot 1 contains an AESIMC/AESMC instruction
  assign iq_instr1_is_aesimc_aesmc_o  = instr1_is_aesimc_aesmc;

  // ADRP forwarding controls
  assign iq_instr0_adrp_fwd_o     = instr0_adrp_fwd;
  assign iq_instr0_adrp_fwd_src_o = instr0_adrp_fwd_src;
  assign iq_instr1_adrp_fwd_o     = instr1_adrp_fwd;
  assign iq_instr1_adrp_fwd_src_o = instr1_adrp_fwd_src;

endmodule // ca53dpu_iq_dih

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
