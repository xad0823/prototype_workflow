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
// Abstract : Read port address decoder
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Select slot 0 and slot 1 virtual address for each read port and convert to
// physical address.
//
// Decode early version of read port address for AGU to improve timing.
//
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_de_rp_dec (
  // Inputs
  input  wire                             clk,
  input  wire                             reset_n,
  input  wire                             en_decoder_fsm_i,
  input  wire                             nxt_first_cycle_i,
  input  wire                             aarch64_state_i,
  input  wire                       [3:0] iq_instr0_cond_code_i,
  input  wire                             iq_instr0_is_dp_i,
  input  wire                             iq_instr0_is_other_i,
  input  wire                             iq_instr0_is_ls_i,
  input  wire                       [5:0] iq_instr0_sideband_i,
  input  wire                      [28:0] iq_instr0_common_i,
  input  wire                             iq_instr1_is_dp_i,
  input  wire                      [28:0] iq_instr1_common_i,
  input  wire                       [3:0] iq_instr1_cond_code_i,
  input  wire                       [5:0] iq_instr1_sideband_i,
  input  wire                       [4:0] spec_cpsr_mode_iss_i,
  input  wire                      [11:0] exp_cpsr_mode_de_i,
  input  wire                       [7:0] exp_srs_mode_ls_i,
  input  wire                             srs_mode_ctl_ls_i,
  input  wire                       [7:0] nxt_rf_rd_sel_0_r0_subseq_i,
  input  wire                       [5:0] nxt_rf_rd_sel_0_r1_subseq_i,
  input  wire                       [8:0] nxt_rf_rd_sel_0_r2_subseq_i,
  input  wire                       [4:0] nxt_rf_rd_sel_0_r3_subseq_i,
  input  wire                       [5:0] rf_stm_rd_addr_r2_ls_i,
  input  wire                       [5:0] rf_stm_rd_addr_r3_ls_i,
  input  wire                             msr_mrs_reg_rd_other_i,
  input  wire                       [5:0] msr_mrs_data_other_i,
  input  wire                             rf_rd_remap_de_i,

  // Outputs
  output wire                       [5:0] rf_rd_addr_r0_0_de_o,
  output wire                       [5:0] rf_rd_addr_r1_0_de_o,
  output wire                       [5:0] rf_rd_addr_r2_0_de_o,
  output wire                       [5:0] rf_rd_addr_r3_0_de_o,
  output wire                       [5:0] rf_rd_addr_r0_1_de_o,
  output wire                       [5:0] rf_rd_addr_r1_1_de_o,
  output wire                       [5:0] rf_rd_addr_r2_1_de_o,
  output wire                             rf_rd_r0_is_r31_0_de_o,
  output wire                             rf_rd_r0_is_r31_1_de_o,
  output wire  [`CA53_LONG_RF_ADDR_W-1:0] rf_rd_addr_r0_agu_de_o,
  output wire  [`CA53_LONG_RF_ADDR_W-1:0] rf_rd_addr_r1_agu_de_o,
  output wire                       [5:0] rf_r0_for_fwd_check_de_o,
  output wire                       [5:0] rf_r1_for_fwd_check_de_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg         first_cycle;
  reg   [5:0] elr_phys_reg;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire        instr0_top_3_0;
  wire        instr0_top_11_8;
  wire        instr0_top_15_12;
  wire        instr0_top_19_16;
  wire  [7:0] rf_rd_sel_0_r0_first;
  wire  [5:0] rf_rd_sel_0_r1_first;
  wire  [8:0] rf_rd_sel_0_r2_first;
  wire  [4:0] rf_rd_sel_0_r3_first;
  wire  [7:0] rf_rd_sel_0_r0;
  wire  [5:0] rf_rd_sel_0_r1;
  wire  [8:0] rf_rd_sel_0_r2;
  wire  [4:0] rf_rd_sel_0_r3;
  wire  [4:0] rf_rd_vaddr_0_r0;
  wire  [4:0] rf_rd_vaddr_0_r1;
  wire  [4:0] rf_rd_vaddr_0_r2;
  wire  [4:0] rf_rd_vaddr_0_r3;
  wire  [5:0] rf_rd_addr_common_0_r0;
  wire  [5:0] rf_rd_addr_common_0_r2;
  wire  [5:0] rf_rd_addr_common_0_r3;
  wire  [5:0] rf_rd_addr_r13_de;
  wire        instr1_top_3_0;
  wire        instr1_top_11_8;
  wire        instr1_top_15_12;
  wire        instr1_top_19_16;
  wire        ot_is_tbb;
  wire  [4:0] rf_ls_base_addr_de;
  wire  [4:0] rf_ls_offset_addr_de;
  wire  [7:0] exp_srs_mode_de;
  wire        srs_mode_ctl_early_de;
  wire  [4:0] rf_rd_vaddr_1_r0;
  wire  [4:0] rf_rd_vaddr_1_r1;
  wire  [4:0] rf_rd_vaddr_1_r2;
  wire  [7:0] rf_rd_sel_1_r0;
  wire  [5:0] rf_rd_sel_1_r1;
  wire  [8:0] rf_rd_sel_1_r2;
  wire        sel_r2_msr_mrs;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Slot 0 Read port address decode
  // ------------------------------------------------------
  // The addresses for each read port are calculated primarily using the
  // sideband bits. These cannot be used on subsequent cycles of mult-cycle
  // instructions, so each decoder provides an indication of what the source
  // for each read port will be on the next cycle of multicycle instructions.
  // These are muxed down to a single set common to all decoders and then
  // registered, so that the mux enables can be calculated early whether it
  // is the first cylce of an instruction or not.
  //
  // To improve timing, the IQ contains duplicate registers for the 19:16,
  // 15:12, 11:8 and 3:0 bits of the slot 0 entries, so that they can be
  // taken from a single place regardless of the decoder currently being
  // used.
  //
  // Most of the address sources are muxed into a single virtual address for
  // each read port, which are then converted to physical addresses. There
  // are a number of address sources which are already available in their
  // physical format, and so these are muxed in afterwards, using the same
  // mux enable terms.

  // Detect first cycle of instructions by duplicating bottom bit of decoder
  // fsm
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      first_cycle <= 1'b1;
    else if (en_decoder_fsm_i)
      first_cycle <= nxt_first_cycle_i;

  assign instr0_top_3_0   = iq_instr0_cond_code_i[2] & aarch64_state_i;
  assign instr0_top_11_8  = iq_instr0_is_dp_i ? (iq_instr0_cond_code_i[0] & aarch64_state_i)
                                              : (iq_instr0_sideband_i[0]  & aarch64_state_i);
  assign instr0_top_15_12 = iq_instr0_is_dp_i ? (iq_instr0_sideband_i[0]  & aarch64_state_i) // For DP decoder, only used for MAC in AArch64
                                              : (iq_instr0_cond_code_i[0] & aarch64_state_i);
  assign instr0_top_19_16 = iq_instr0_cond_code_i[1] & aarch64_state_i;

  // Form virtual address for each read port
  assign rf_rd_vaddr_0_r0[4:0] = (({5{rf_rd_sel_0_r0[`CA53_RP_RD_3_0]       }} & {instr0_top_3_0,   iq_instr0_common_i[ 3: 0]}) |
                                  ({5{rf_rd_sel_0_r0[`CA53_RP_RD_11_8]      }} & {instr0_top_11_8,  iq_instr0_common_i[11: 8]}) |
                                  ({5{rf_rd_sel_0_r0[`CA53_RP_RD_15_12] |
                                      rf_rd_sel_0_r0[`CA53_RP_RD_MCR]       }} & {instr0_top_15_12, iq_instr0_common_i[15:12]}) |
                                  ({5{rf_rd_sel_0_r0[`CA53_RP_RD_19_16]     }} & {instr0_top_19_16, iq_instr0_common_i[19:16]}) |
                                  ({5{rf_rd_sel_0_r0[`CA53_RP0_RD_2_0]      }} & {2'b00, iq_instr0_common_i[2:0]})              | // Only used by other decoder
                                  ({5{rf_rd_sel_0_r0[`CA53_RP_RD_ERET]      }} & `CA53_VADDR_R14));

  assign rf_rd_vaddr_0_r1[4:0] = (({5{rf_rd_sel_0_r1[`CA53_RP_RD_3_0]       }} & {instr0_top_3_0,   iq_instr0_common_i[ 3: 0]}) |
                                  ({5{rf_rd_sel_0_r1[`CA53_RP_RD_11_8]      }} & {instr0_top_11_8,  iq_instr0_common_i[11: 8]}) |
                                  ({5{rf_rd_sel_0_r1[`CA53_RP_RD_15_12] |
                                      rf_rd_sel_0_r1[`CA53_RP_RD_MCR]       }} & {instr0_top_15_12, iq_instr0_common_i[15:12]}) |
                                  ({5{rf_rd_sel_0_r1[`CA53_RP_RD_19_16]     }} & {instr0_top_19_16, iq_instr0_common_i[19:16]}));

  assign rf_rd_vaddr_0_r2[4:0] = (({5{rf_rd_sel_0_r2[`CA53_RP_RD_3_0]       }} & {instr0_top_3_0,   iq_instr0_common_i[ 3: 0]}) |
                                  ({5{rf_rd_sel_0_r2[`CA53_RP_RD_11_8]      }} & {instr0_top_11_8,  iq_instr0_common_i[11: 8]}) |
                                  ({5{rf_rd_sel_0_r2[`CA53_RP_RD_15_12] |
                                      rf_rd_sel_0_r2[`CA53_RP_RD_MCR]       }} & {instr0_top_15_12, iq_instr0_common_i[15:12]}) |
                                  ({5{rf_rd_sel_0_r2[`CA53_RP_RD_19_16]     }} & {instr0_top_19_16, iq_instr0_common_i[19:16]}) |
                                  ({5{rf_rd_sel_0_r2[`CA53_RP2_RD_R14]      }} & `CA53_VADDR_R14));

  assign rf_rd_vaddr_0_r3[4:0] = (({5{rf_rd_sel_0_r3[`CA53_RP_RD_3_0]       }} & {instr0_top_3_0,   iq_instr0_common_i[ 3: 0]}) |
                                  ({5{rf_rd_sel_0_r3[`CA53_RP_RD_11_8]      }} & {instr0_top_11_8,  iq_instr0_common_i[11: 8]}) |
                                  ({5{rf_rd_sel_0_r3[`CA53_RP_RD_15_12]     }} & {instr0_top_15_12, iq_instr0_common_i[15:12]}) |
                                  ({5{rf_rd_sel_0_r3[`CA53_RP_RD_19_16]     }} & {instr0_top_19_16, iq_instr0_common_i[19:16]}));

  // Logical to physical translation
  ca53dpu_de_reg_trans u_de_regtrans_0_r0 (
    .rf_rd_vaddr_de_i (rf_rd_vaddr_0_r0[4:0]),
    .exp_mode_de_i    (exp_cpsr_mode_de_i[11:0]),
    .rf_rd_addr_de_o  (rf_rd_addr_common_0_r0[5:0])
  );

  ca53dpu_de_reg_trans u_de_regtrans_0_r1 (
    .rf_rd_vaddr_de_i (rf_rd_vaddr_0_r1[4:0]),
    .exp_mode_de_i    (exp_cpsr_mode_de_i[11:0]),
    .rf_rd_addr_de_o  (rf_rd_addr_r1_0_de_o[5:0])
  );

  ca53dpu_de_reg_trans u_de_regtrans_0_r2 (
    .rf_rd_vaddr_de_i (rf_rd_vaddr_0_r2[4:0]),
    .exp_mode_de_i    (exp_cpsr_mode_de_i[11:0]),
    .rf_rd_addr_de_o  (rf_rd_addr_common_0_r2[5:0])
  );

  ca53dpu_de_reg_trans u_de_regtrans_0_r3 (
    .rf_rd_vaddr_de_i (rf_rd_vaddr_0_r3[4:0]),
    .exp_mode_de_i    (exp_cpsr_mode_de_i[11:0]),
    .rf_rd_addr_de_o  (rf_rd_addr_common_0_r3[5:0])
  );

  // - R13 used by SRS, which uses a different mode
  ca53dpu_de_reg_trans u_de_regtrans_r13 (
    .rf_rd_vaddr_de_i (`CA53_VADDR_R13),
    .exp_mode_de_i    ({4'b0000, exp_srs_mode_ls_i[7:0]}),
    .rf_rd_addr_de_o  (rf_rd_addr_r13_de[5:0])
  );

  // Translate ELR
  always @*
    case (spec_cpsr_mode_iss_i)
      `CA53_FULL_MODE_EL1T,
      `CA53_FULL_MODE_EL1H: elr_phys_reg = `CA53_ADDR_ELR_EL1;

      `CA53_FULL_MODE_HYP,
      `CA53_FULL_MODE_EL2T,
      `CA53_FULL_MODE_EL2H: elr_phys_reg = `CA53_ADDR_ELR_EL2;

      `CA53_FULL_MODE_EL3T,
      `CA53_FULL_MODE_EL3H: elr_phys_reg = `CA53_ADDR_ELR_EL3;

      `CA53_FULL_MODE_EL0T: elr_phys_reg = {6{1'b0}}; // Instruction will not be committed, but prevent x-prop issues

      default:              elr_phys_reg = {6{1'bx}};
    endcase

  // Mux in addresses already in logical format
  assign rf_rd_addr_r0_0_de_o[5:0]   = rf_rd_sel_0_r0[`CA53_RP0_RD_R13] ? rf_rd_addr_r13_de[5:0] : rf_rd_addr_common_0_r0[5:0];

  assign sel_r2_msr_mrs = rf_rd_sel_0_r2[`CA53_RP2_RD_RMOD] | (iq_instr0_is_other_i & msr_mrs_reg_rd_other_i);

  assign rf_rd_addr_r2_0_de_o[5:0]   = (({6{rf_rd_sel_0_r2[`CA53_RP_RD_STM]}}     & rf_stm_rd_addr_r2_ls_i[5:0])  |
                                        ({6{rf_rd_sel_0_r2[`CA53_RP_RD_ERET]}}    & elr_phys_reg               )  |
                                        ({6{sel_r2_msr_mrs}}                      & msr_mrs_data_other_i[5:0]  )  |
                                        ({6{~(rf_rd_sel_0_r2[`CA53_RP_RD_STM]   |
                                              rf_rd_sel_0_r2[`CA53_RP_RD_ERET]  |
                                              sel_r2_msr_mrs)}}                   & rf_rd_addr_common_0_r2[5:0]));

  assign rf_rd_addr_r3_0_de_o[5:0]  = rf_rd_sel_0_r3[`CA53_RP_RD_STM]  ? rf_stm_rd_addr_r3_ls_i[5:0] : rf_rd_addr_common_0_r3[5:0];

  // Indicate when slot 0 R0 is selecting R31 - used for stack point selection detection
  assign rf_rd_r0_is_r31_0_de_o = (rf_rd_vaddr_0_r0 == `CA53_VADDR_R31);

  // The logic to calculate the first cycle enables from the sideband
  // encodings is generated automatically. As not all address sources can be
  // enabled on subsequent cycles, the registers for the subsequent cycle
  // selects, and the terms to mux between them and the first cycle signals,
  // are also created automatically, to save implementing redundant logic.

  // ------------------------------------------------------
  // Start slot 0 read port decoder automatically generated logic
  // ------------------------------------------------------

  // Subsequent cycle registers
  reg rf_rd_sel_0_r0_subseq_11, rf_rd_sel_0_r0_subseq_19,
      rf_rd_sel_0_r1_subseq_3, rf_rd_sel_0_r1_subseq_15,
      rf_rd_sel_0_r2_subseq_11, rf_rd_sel_0_r2_subseq_stm,
      rf_rd_sel_0_r2_subseq_15, rf_rd_sel_0_r3_subseq_stm,
      rf_rd_sel_0_r3_subseq_11;

  always @(posedge clk)
    if (en_decoder_fsm_i) begin
      rf_rd_sel_0_r0_subseq_11   <= nxt_rf_rd_sel_0_r0_subseq_i[`CA53_RP_RD_11_8];
      rf_rd_sel_0_r0_subseq_19   <= nxt_rf_rd_sel_0_r0_subseq_i[`CA53_RP_RD_19_16];
      rf_rd_sel_0_r1_subseq_3    <= nxt_rf_rd_sel_0_r1_subseq_i[`CA53_RP_RD_3_0];
      rf_rd_sel_0_r1_subseq_15   <= nxt_rf_rd_sel_0_r1_subseq_i[`CA53_RP_RD_15_12];
      rf_rd_sel_0_r2_subseq_11   <= nxt_rf_rd_sel_0_r2_subseq_i[`CA53_RP_RD_11_8];
      rf_rd_sel_0_r2_subseq_stm  <= nxt_rf_rd_sel_0_r2_subseq_i[`CA53_RP_RD_STM];
      rf_rd_sel_0_r2_subseq_15   <= nxt_rf_rd_sel_0_r2_subseq_i[`CA53_RP_RD_15_12];
      rf_rd_sel_0_r3_subseq_stm  <= nxt_rf_rd_sel_0_r3_subseq_i[`CA53_RP_RD_STM];
      rf_rd_sel_0_r3_subseq_11   <= nxt_rf_rd_sel_0_r3_subseq_i[`CA53_RP_RD_11_8];
    end

  // Select between first and subsequent cycles
  assign rf_rd_sel_0_r0[`CA53_RP_RD_3_0]        = first_cycle & rf_rd_sel_0_r0_first[`CA53_RP_RD_3_0];
  assign rf_rd_sel_0_r0[`CA53_RP_RD_11_8]       = first_cycle ? rf_rd_sel_0_r0_first[`CA53_RP_RD_11_8]       : rf_rd_sel_0_r0_subseq_11;
  assign rf_rd_sel_0_r0[`CA53_RP_RD_15_12]      = first_cycle & rf_rd_sel_0_r0_first[`CA53_RP_RD_15_12];
  assign rf_rd_sel_0_r0[`CA53_RP_RD_19_16]      = first_cycle ? rf_rd_sel_0_r0_first[`CA53_RP_RD_19_16]      : rf_rd_sel_0_r0_subseq_19;
  assign rf_rd_sel_0_r0[`CA53_RP0_RD_2_0]       = first_cycle & rf_rd_sel_0_r0_first[`CA53_RP0_RD_2_0];
  assign rf_rd_sel_0_r0[`CA53_RP_RD_MCR]        = first_cycle & rf_rd_sel_0_r0_first[`CA53_RP_RD_MCR];
  assign rf_rd_sel_0_r0[`CA53_RP_RD_ERET]       = first_cycle & rf_rd_sel_0_r0_first[`CA53_RP_RD_ERET];
  assign rf_rd_sel_0_r0[`CA53_RP0_RD_R13]       = first_cycle & rf_rd_sel_0_r0_first[`CA53_RP0_RD_R13];

  assign rf_rd_sel_0_r1[`CA53_RP_RD_3_0]        = first_cycle ? rf_rd_sel_0_r1_first[`CA53_RP_RD_3_0]        : rf_rd_sel_0_r1_subseq_3;
  assign rf_rd_sel_0_r1[`CA53_RP_RD_11_8]       = 1'b0;
  assign rf_rd_sel_0_r1[`CA53_RP_RD_15_12]      = first_cycle ? rf_rd_sel_0_r1_first[`CA53_RP_RD_15_12]      : rf_rd_sel_0_r1_subseq_15;
  assign rf_rd_sel_0_r1[`CA53_RP_RD_19_16]      = first_cycle & rf_rd_sel_0_r1_first[`CA53_RP_RD_19_16];
  assign rf_rd_sel_0_r1[`CA53_RP_RD_STM]        = 1'b0;
  assign rf_rd_sel_0_r1[`CA53_RP_RD_MCR]        = first_cycle & rf_rd_sel_0_r1_first[`CA53_RP_RD_MCR];

  assign rf_rd_sel_0_r2[`CA53_RP_RD_3_0]        = first_cycle & rf_rd_sel_0_r2_first[`CA53_RP_RD_3_0];
  assign rf_rd_sel_0_r2[`CA53_RP_RD_11_8]       = first_cycle ? rf_rd_sel_0_r2_first[`CA53_RP_RD_11_8]       : rf_rd_sel_0_r2_subseq_11;
  assign rf_rd_sel_0_r2[`CA53_RP_RD_15_12]      = first_cycle ? rf_rd_sel_0_r2_first[`CA53_RP_RD_15_12]      : rf_rd_sel_0_r2_subseq_15;
  assign rf_rd_sel_0_r2[`CA53_RP_RD_19_16]      = first_cycle & rf_rd_sel_0_r2_first[`CA53_RP_RD_19_16];
  assign rf_rd_sel_0_r2[`CA53_RP_RD_STM]        = first_cycle ? rf_rd_sel_0_r2_first[`CA53_RP_RD_STM]        : rf_rd_sel_0_r2_subseq_stm;
  assign rf_rd_sel_0_r2[`CA53_RP_RD_MCR]        = first_cycle & rf_rd_sel_0_r2_first[`CA53_RP_RD_MCR];
  assign rf_rd_sel_0_r2[`CA53_RP_RD_ERET]       = first_cycle & rf_rd_sel_0_r2_first[`CA53_RP_RD_ERET];
  assign rf_rd_sel_0_r2[`CA53_RP2_RD_R14]       = first_cycle & rf_rd_sel_0_r2_first[`CA53_RP2_RD_R14];
  assign rf_rd_sel_0_r2[`CA53_RP2_RD_RMOD]      = first_cycle & rf_rd_sel_0_r2_first[`CA53_RP2_RD_RMOD];

  assign rf_rd_sel_0_r3[`CA53_RP_RD_3_0]        = 1'b0;
  assign rf_rd_sel_0_r3[`CA53_RP_RD_11_8]       = first_cycle ? rf_rd_sel_0_r3_first[`CA53_RP_RD_11_8]       : rf_rd_sel_0_r3_subseq_11;
  assign rf_rd_sel_0_r3[`CA53_RP_RD_15_12]      = 1'b0;
  assign rf_rd_sel_0_r3[`CA53_RP_RD_19_16]      = first_cycle & rf_rd_sel_0_r3_first[`CA53_RP_RD_19_16];
  assign rf_rd_sel_0_r3[`CA53_RP_RD_STM]        = first_cycle ? rf_rd_sel_0_r3_first[`CA53_RP_RD_STM]        : rf_rd_sel_0_r3_subseq_stm;

  // First cycle select netlist
  wire    net_0_rp_1, net_0_rp_2,
         net_0_rp_3, net_0_rp_4, net_0_rp_6, net_0_rp_7, net_0_rp_8, net_0_rp_9, net_0_rp_10, net_0_rp_11, net_0_rp_12,
         net_0_rp_13, net_0_rp_14, net_0_rp_15, net_0_rp_16, net_0_rp_17, net_0_rp_18, net_0_rp_19, net_0_rp_20,
         net_0_rp_21, net_0_rp_22, net_0_rp_23, net_0_rp_24, net_0_rp_25, net_0_rp_26, net_0_rp_27, net_0_rp_28,
         net_0_rp_29, net_0_rp_30, net_0_rp_31, net_0_rp_32, net_0_rp_33, net_0_rp_34, net_0_rp_35, net_0_rp_36,
         net_0_rp_37, net_0_rp_38, net_0_rp_39, net_0_rp_40, net_0_rp_41, net_0_rp_42, net_0_rp_43, net_0_rp_44,
         net_0_rp_45, net_0_rp_46, net_0_rp_47, net_0_rp_48, net_0_rp_49, net_0_rp_50, net_0_rp_51, net_0_rp_52,
         net_0_rp_53, net_0_rp_54, net_0_rp_55, net_0_rp_56, net_0_rp_57, net_0_rp_58, net_0_rp_59, net_0_rp_60,
         net_0_rp_61, net_0_rp_62, net_0_rp_63, net_0_rp_64, net_0_rp_65, net_0_rp_66, net_0_rp_67, net_0_rp_68,
         net_0_rp_69, net_0_rp_70, net_0_rp_71, net_0_rp_72, net_0_rp_73, net_0_rp_74, net_0_rp_75, net_0_rp_76,
         net_0_rp_77, net_0_rp_78;

  assign rf_rd_sel_0_r0_first[7] = rf_rd_sel_0_r2_first[7];
  assign rf_rd_sel_0_r0_first[6] = rf_rd_sel_0_r2_first[6];
  assign rf_rd_sel_0_r1_first[5] = rf_rd_sel_0_r2_first[5];
  assign rf_rd_sel_0_r0_first[5] = rf_rd_sel_0_r2_first[5];
  assign rf_rd_sel_0_r2_first[4] = rf_rd_sel_0_r3_first[4];
  assign rf_rd_sel_0_r3_first[2] = 1'b0;
  assign rf_rd_sel_0_r3_first[0] = 1'b0;
  assign rf_rd_sel_0_r1_first[4] = 1'b0;
  assign rf_rd_sel_0_r1_first[1] = 1'b0;
  assign net_0_rp_1 = ~iq_instr0_sideband_i[5];
  assign net_0_rp_2 = ~iq_instr0_sideband_i[2];
  assign net_0_rp_3 = ~iq_instr0_sideband_i[1];
  assign net_0_rp_4 = ~iq_instr0_sideband_i[0];
  assign rf_rd_sel_0_r3_first[1] = ~(iq_instr0_sideband_i[5] | net_0_rp_6);
  assign net_0_rp_6 = ~(iq_instr0_sideband_i[0] & net_0_rp_7);
  assign net_0_rp_7 = (net_0_rp_8 | net_0_rp_9);
  assign net_0_rp_8 = (iq_instr0_sideband_i[2] & net_0_rp_10);
  assign rf_rd_sel_0_r2_first[8] = (iq_instr0_sideband_i[5] & net_0_rp_11);
  assign net_0_rp_11 = (net_0_rp_12 & net_0_rp_2);
  assign rf_rd_sel_0_r3_first[4] = (net_0_rp_13 & net_0_rp_14);
  assign net_0_rp_14 = ~(iq_instr0_sideband_i[5] | net_0_rp_15);
  assign rf_rd_sel_0_r2_first[3] = (net_0_rp_16 & net_0_rp_17);
  assign net_0_rp_17 = (net_0_rp_12 | net_0_rp_18);
  assign net_0_rp_18 = ~(net_0_rp_15 | net_0_rp_3);
  assign rf_rd_sel_0_r2_first[2] = (rf_rd_sel_0_r3_first[3] | net_0_rp_19);
  assign net_0_rp_19 = ~(iq_instr0_sideband_i[5] | net_0_rp_20);
  assign net_0_rp_20 = (net_0_rp_21 & net_0_rp_22);
  assign net_0_rp_22 = ~(net_0_rp_9 & iq_instr0_sideband_i[0]);
  assign net_0_rp_21 = ~(net_0_rp_23 & net_0_rp_24);
  assign net_0_rp_24 = (iq_instr0_sideband_i[3] ^ net_0_rp_3);
  assign net_0_rp_23 = (iq_instr0_sideband_i[2] & net_0_rp_25);
  assign net_0_rp_25 = ~(iq_instr0_sideband_i[3] ^ iq_instr0_sideband_i[4]);
  assign rf_rd_sel_0_r3_first[3] = (net_0_rp_16 & net_0_rp_26);
  assign rf_rd_sel_0_r2_first[0] = (net_0_rp_12 & net_0_rp_27);
  assign rf_rd_sel_0_r1_first[3] = (net_0_rp_28 | net_0_rp_29);
  assign net_0_rp_29 = ~(net_0_rp_30 & net_0_rp_31);
  assign net_0_rp_31 = ~(net_0_rp_32 & net_0_rp_16);
  assign net_0_rp_32 = ~(iq_instr0_sideband_i[3] | net_0_rp_33);
  assign net_0_rp_30 = ~(net_0_rp_27 & net_0_rp_34);
  assign rf_rd_sel_0_r1_first[2] = (rf_rd_sel_0_r2_first[1] | net_0_rp_35);
  assign net_0_rp_35 = (net_0_rp_36 | net_0_rp_37);
  assign net_0_rp_37 = (net_0_rp_16 & net_0_rp_38);
  assign net_0_rp_38 = ~(net_0_rp_15 & net_0_rp_39);
  assign net_0_rp_39 = ~(net_0_rp_40 | net_0_rp_41);
  assign net_0_rp_36 = (net_0_rp_13 & net_0_rp_42);
  assign rf_rd_sel_0_r2_first[1] = ~(iq_instr0_sideband_i[3] | net_0_rp_43);
  assign net_0_rp_43 = ~(net_0_rp_27 & net_0_rp_40);
  assign net_0_rp_40 = (iq_instr0_sideband_i[4] & net_0_rp_3);
  assign net_0_rp_27 = (net_0_rp_1 & net_0_rp_2);
  assign rf_rd_sel_0_r1_first[0] = ~(net_0_rp_44 & net_0_rp_45);
  assign net_0_rp_45 = ~(net_0_rp_46 & net_0_rp_10);
  assign net_0_rp_10 = ~(net_0_rp_3 | net_0_rp_47);
  assign net_0_rp_44 = (net_0_rp_48 & net_0_rp_49);
  assign net_0_rp_48 = (net_0_rp_50 | iq_instr0_sideband_i[5]);
  assign net_0_rp_50 = (net_0_rp_51 & net_0_rp_52);
  assign net_0_rp_52 = ~(iq_instr0_sideband_i[2] & net_0_rp_53);
  assign net_0_rp_53 = ~(iq_instr0_sideband_i[1] & net_0_rp_54);
  assign net_0_rp_54 = (net_0_rp_47 & net_0_rp_15);
  assign net_0_rp_15 = ~(iq_instr0_sideband_i[4] & net_0_rp_4);
  assign net_0_rp_51 = (iq_instr0_sideband_i[4] | net_0_rp_55);
  assign rf_rd_sel_0_r2_first[7] = (net_0_rp_56 & net_0_rp_41);
  assign net_0_rp_41 = ~(net_0_rp_57 | net_0_rp_58);
  assign rf_rd_sel_0_r2_first[6] = (net_0_rp_9 & net_0_rp_59);
  assign rf_rd_sel_0_r2_first[5] = (net_0_rp_60 & net_0_rp_61);
  assign net_0_rp_61 = (net_0_rp_16 & net_0_rp_4);
  assign net_0_rp_16 = ~(net_0_rp_1 | net_0_rp_2);
  assign net_0_rp_60 = (iq_instr0_sideband_i[3] & net_0_rp_3);
  assign rf_rd_sel_0_r0_first[4] = ~(iq_instr0_sideband_i[4] | net_0_rp_62);
  assign net_0_rp_62 = ~(net_0_rp_13 & net_0_rp_46);
  assign net_0_rp_46 = ~(net_0_rp_1 | iq_instr0_sideband_i[0]);
  assign rf_rd_sel_0_r0_first[3] = (net_0_rp_63 | net_0_rp_64);
  assign net_0_rp_64 = ~(net_0_rp_65 & net_0_rp_66);
  assign net_0_rp_66 = (iq_instr0_sideband_i[3] | net_0_rp_67);
  assign net_0_rp_67 = ~(net_0_rp_68 & net_0_rp_42);
  assign net_0_rp_42 = (iq_instr0_sideband_i[0] & iq_instr0_sideband_i[4]);
  assign net_0_rp_68 = ~(net_0_rp_3 | net_0_rp_2);
  assign net_0_rp_65 = (net_0_rp_49 & net_0_rp_69);
  assign net_0_rp_69 = (iq_instr0_sideband_i[2] | net_0_rp_47);
  assign net_0_rp_47 = ~(iq_instr0_sideband_i[3] & iq_instr0_sideband_i[4]);
  assign net_0_rp_49 = (net_0_rp_55 | net_0_rp_2);
  assign net_0_rp_63 = ~(iq_instr0_sideband_i[5] | net_0_rp_70);
  assign net_0_rp_70 = (net_0_rp_71 & net_0_rp_55);
  assign net_0_rp_55 = (iq_instr0_sideband_i[1] | net_0_rp_57);
  assign net_0_rp_57 = ~(iq_instr0_sideband_i[3] & iq_instr0_sideband_i[0]);
  assign net_0_rp_71 = ~(net_0_rp_72 & net_0_rp_73);
  assign net_0_rp_73 = (iq_instr0_sideband_i[3] | net_0_rp_74);
  assign net_0_rp_74 = ~(iq_instr0_sideband_i[4] ^ net_0_rp_2);
  assign net_0_rp_72 = (iq_instr0_sideband_i[4] | net_0_rp_75);
  assign net_0_rp_75 = (iq_instr0_sideband_i[1] ^ iq_instr0_sideband_i[2]);
  assign rf_rd_sel_0_r0_first[2] = (net_0_rp_13 & net_0_rp_59);
  assign net_0_rp_59 = ~(net_0_rp_1 | net_0_rp_4);
  assign net_0_rp_13 = ~(net_0_rp_3 | net_0_rp_76);
  assign rf_rd_sel_0_r0_first[1] = ~(iq_instr0_sideband_i[5] | net_0_rp_77);
  assign net_0_rp_77 = ~(net_0_rp_28 | net_0_rp_78);
  assign net_0_rp_78 = (net_0_rp_12 & iq_instr0_sideband_i[2]);
  assign net_0_rp_12 = (iq_instr0_sideband_i[0] & net_0_rp_34);
  assign net_0_rp_28 = (net_0_rp_9 & net_0_rp_4);
  assign net_0_rp_9 = ~(net_0_rp_76 | net_0_rp_33);
  assign net_0_rp_33 = (iq_instr0_sideband_i[1] | iq_instr0_sideband_i[4]);
  assign net_0_rp_76 = ~(iq_instr0_sideband_i[3] & net_0_rp_2);
  assign rf_rd_sel_0_r0_first[0] = (net_0_rp_56 & net_0_rp_26);
  assign net_0_rp_26 = (net_0_rp_34 & net_0_rp_4);
  assign net_0_rp_34 = ~(iq_instr0_sideband_i[3] | net_0_rp_58);
  assign net_0_rp_58 = (iq_instr0_sideband_i[4] | net_0_rp_3);
  assign net_0_rp_56 = ~(net_0_rp_2 | iq_instr0_sideband_i[5]);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Slot 1 Read port address decode
  // ------------------------------------------------------

  assign instr1_top_3_0   = iq_instr1_cond_code_i[2] & aarch64_state_i;
  assign instr1_top_11_8  = iq_instr1_is_dp_i ? (iq_instr1_cond_code_i[0] & aarch64_state_i)
                                              : (iq_instr1_sideband_i[0]  & aarch64_state_i);
  assign instr1_top_15_12 = (iq_instr1_is_dp_i ? iq_instr1_sideband_i[0] : iq_instr1_cond_code_i[0]) & aarch64_state_i;
  assign instr1_top_19_16 = iq_instr1_cond_code_i[1] & aarch64_state_i;

  // Form virtual address for each read port
  assign rf_rd_vaddr_1_r0[4:0] = (({5{rf_rd_sel_1_r0[`CA53_RP_RD_3_0]  }} & {instr1_top_3_0,   iq_instr1_common_i[ 3: 0]}) |
                                  ({5{rf_rd_sel_1_r0[`CA53_RP_RD_11_8] }} & {instr1_top_11_8,  iq_instr1_common_i[11: 8]}) |
                                  ({5{rf_rd_sel_1_r0[`CA53_RP_RD_15_12]}} & {instr1_top_15_12, iq_instr1_common_i[15:12]}) |
                                  ({5{rf_rd_sel_1_r0[`CA53_RP_RD_19_16]}} & {instr1_top_19_16, iq_instr1_common_i[19:16]}));

  assign rf_rd_vaddr_1_r1[4:0] = (({5{rf_rd_sel_1_r1[`CA53_RP_RD_3_0]  }} & {instr1_top_3_0,   iq_instr1_common_i[ 3: 0]}) |
                                  ({5{rf_rd_sel_1_r1[`CA53_RP_RD_15_12]}} & {instr1_top_15_12, iq_instr1_common_i[15:12]}) |
                                  ({5{rf_rd_sel_1_r1[`CA53_RP_RD_19_16]}} & {instr1_top_19_16, iq_instr1_common_i[19:16]}));

  assign rf_rd_vaddr_1_r2[4:0] = (({5{rf_rd_sel_1_r2[`CA53_RP_RD_3_0]  }} & {instr1_top_3_0,   iq_instr1_common_i[ 3: 0]}) |
                                  ({5{rf_rd_sel_1_r2[`CA53_RP_RD_11_8] }} & {instr1_top_11_8,  iq_instr1_common_i[11: 8]}) |
                                  ({5{rf_rd_sel_1_r2[`CA53_RP_RD_15_12]}} & {instr1_top_15_12, iq_instr1_common_i[15:12]}) |
                                  ({5{rf_rd_sel_1_r2[`CA53_RP_RD_19_16]}} & {instr1_top_19_16, iq_instr1_common_i[19:16]}));

  // Logical to physical translation
  ca53dpu_de_reg_trans u_de_regtrans_1_r0 (
    .rf_rd_vaddr_de_i (rf_rd_vaddr_1_r0[4:0]),
    .exp_mode_de_i    (exp_cpsr_mode_de_i[11:0]),
    .rf_rd_addr_de_o  (rf_rd_addr_r0_1_de_o[5:0])
  );

  ca53dpu_de_reg_trans u_de_regtrans_1_r1 (
    .rf_rd_vaddr_de_i (rf_rd_vaddr_1_r1[4:0]),
    .exp_mode_de_i    (exp_cpsr_mode_de_i[11:0]),
    .rf_rd_addr_de_o  (rf_rd_addr_r1_1_de_o[5:0])
  );

  ca53dpu_de_reg_trans u_de_regtrans_1_r2 (
    .rf_rd_vaddr_de_i (rf_rd_vaddr_1_r2[4:0]),
    .exp_mode_de_i    (exp_cpsr_mode_de_i[11:0]),
    .rf_rd_addr_de_o  (rf_rd_addr_r2_1_de_o[5:0])
  );

  // Indicate when slot 1 R0 is selecting R31 - used for stack point selection detection
  assign rf_rd_r0_is_r31_1_de_o = (rf_rd_vaddr_1_r0 == `CA53_VADDR_R31);

  // ------------------------------------------------------
  // Start slot 1 read port decoder automatically generated logic
  // ------------------------------------------------------

  wire   net_1_rp_1, net_1_rp_2, net_1_rp_3, net_1_rp_5, net_1_rp_6, net_1_rp_7, net_1_rp_8, net_1_rp_9, net_1_rp_10,
         net_1_rp_11, net_1_rp_12, net_1_rp_13, net_1_rp_14, net_1_rp_15, net_1_rp_16, net_1_rp_17, net_1_rp_18,
         net_1_rp_19, net_1_rp_20, net_1_rp_21, net_1_rp_22, net_1_rp_23, net_1_rp_24, net_1_rp_25, net_1_rp_26,
         net_1_rp_27, net_1_rp_28, net_1_rp_29, net_1_rp_30, net_1_rp_31, net_1_rp_32, net_1_rp_33, net_1_rp_34,
         net_1_rp_35, net_1_rp_36;

  assign rf_rd_sel_1_r2[8] = 1'b0;
  assign rf_rd_sel_1_r2[7] = 1'b0;
  assign rf_rd_sel_1_r2[6] = 1'b0;
  assign rf_rd_sel_1_r2[5] = 1'b0;
  assign rf_rd_sel_1_r2[4] = 1'b0;
  assign rf_rd_sel_1_r1[5] = 1'b0;
  assign rf_rd_sel_1_r1[4] = 1'b0;
  assign rf_rd_sel_1_r1[1] = 1'b0;
  assign rf_rd_sel_1_r0[7] = 1'b0;
  assign rf_rd_sel_1_r0[6] = 1'b0;
  assign rf_rd_sel_1_r0[5] = 1'b0;
  assign rf_rd_sel_1_r0[4] = 1'b0;
  assign net_1_rp_1 = ~iq_instr1_sideband_i[5];
  assign net_1_rp_2 = ~net_1_rp_25;
  assign net_1_rp_3 = ~iq_instr1_sideband_i[2];
  assign rf_rd_sel_1_r2[3] = (iq_instr1_sideband_i[1] & net_1_rp_5);
  assign rf_rd_sel_1_r2[2] = ~(net_1_rp_6 & net_1_rp_7);
  assign net_1_rp_7 = ~(net_1_rp_8 & net_1_rp_9);
  assign net_1_rp_9 = (iq_instr1_sideband_i[3] & iq_instr1_sideband_i[4]);
  assign net_1_rp_6 = (net_1_rp_10 | iq_instr1_sideband_i[3]);
  assign rf_rd_sel_1_r1[3] = (rf_rd_sel_1_r2[0] | net_1_rp_11);
  assign net_1_rp_11 = (net_1_rp_12 & net_1_rp_13);
  assign net_1_rp_13 = ~(iq_instr1_sideband_i[4] | net_1_rp_14);
  assign net_1_rp_12 = (net_1_rp_1 ^ iq_instr1_sideband_i[2]);
  assign rf_rd_sel_1_r2[0] = ~(iq_instr1_sideband_i[2] | net_1_rp_15);
  assign net_1_rp_15 = ~(iq_instr1_sideband_i[0] & net_1_rp_16);
  assign rf_rd_sel_1_r1[2] = (rf_rd_sel_1_r2[1] | net_1_rp_17);
  assign net_1_rp_17 = (iq_instr1_sideband_i[4] & net_1_rp_18);
  assign net_1_rp_18 = (net_1_rp_5 | net_1_rp_19);
  assign net_1_rp_19 = (iq_instr1_sideband_i[3] & net_1_rp_20);
  assign net_1_rp_5 = (iq_instr1_sideband_i[2] & iq_instr1_sideband_i[5]);
  assign rf_rd_sel_1_r2[1] = ~(iq_instr1_sideband_i[1] | net_1_rp_21);
  assign rf_rd_sel_1_r1[0] = ~(net_1_rp_22 & net_1_rp_23);
  assign net_1_rp_23 = (iq_instr1_sideband_i[0] | net_1_rp_24);
  assign net_1_rp_24 = ~(iq_instr1_sideband_i[1] & net_1_rp_25);
  assign net_1_rp_22 = (net_1_rp_10 & net_1_rp_26);
  assign net_1_rp_26 = (net_1_rp_3 | net_1_rp_27);
  assign rf_rd_sel_1_r0[3] = ~(net_1_rp_28 & net_1_rp_10);
  assign net_1_rp_10 = ~(iq_instr1_sideband_i[2] & net_1_rp_29);
  assign net_1_rp_29 = ~(iq_instr1_sideband_i[1] | iq_instr1_sideband_i[5]);
  assign net_1_rp_28 = (net_1_rp_30 & net_1_rp_21);
  assign net_1_rp_21 = (iq_instr1_sideband_i[2] | net_1_rp_27);
  assign net_1_rp_27 = ~(iq_instr1_sideband_i[4] & net_1_rp_1);
  assign net_1_rp_30 = ~(iq_instr1_sideband_i[3] & net_1_rp_31);
  assign net_1_rp_31 = (iq_instr1_sideband_i[4] | net_1_rp_14);
  assign net_1_rp_14 = (iq_instr1_sideband_i[0] & net_1_rp_1);
  assign rf_rd_sel_1_r0[2] = ~(net_1_rp_2 | iq_instr1_sideband_i[4]);
  assign net_1_rp_25 = (iq_instr1_sideband_i[3] & iq_instr1_sideband_i[5]);
  assign rf_rd_sel_1_r0[1] = ~(net_1_rp_32 & net_1_rp_33);
  assign net_1_rp_33 = ~(net_1_rp_20 & iq_instr1_sideband_i[2]);
  assign net_1_rp_20 = (iq_instr1_sideband_i[0] & iq_instr1_sideband_i[1]);
  assign net_1_rp_32 = ~(net_1_rp_34 & iq_instr1_sideband_i[3]);
  assign net_1_rp_34 = ~(iq_instr1_sideband_i[2] | net_1_rp_35);
  assign net_1_rp_35 = (iq_instr1_sideband_i[0] | iq_instr1_sideband_i[4]);
  assign rf_rd_sel_1_r0[0] = (net_1_rp_16 & net_1_rp_8);
  assign net_1_rp_8 = ~(iq_instr1_sideband_i[0] | net_1_rp_3);
  assign net_1_rp_16 = (iq_instr1_sideband_i[1] & net_1_rp_36);
  assign net_1_rp_36 = ~(iq_instr1_sideband_i[3] | iq_instr1_sideband_i[4]);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  // ------------------------------------------------------
  // AGU base & offset register optimizations
  // ------------------------------------------------------
  // The logic below is a timing optimization to pull the base and offset registers
  // out of the instruction opcode for load-store instructions as early as possible
  // for forwarding control and for addressing the register bank.

  assign ot_is_tbb = ~iq_instr0_common_i[26];

  assign rf_ls_base_addr_de[4:0]    = rf_rd_remap_de_i                    ? {instr1_top_19_16, iq_instr1_common_i[19:16]} : // Slot 1 LS
                                      (iq_instr0_is_other_i & ~ot_is_tbb) ? {instr0_top_15_12, iq_instr0_common_i[15:12]} : // Slot 0 CP MVA
                                                                            {instr0_top_19_16, iq_instr0_common_i[19:16]};  // Slot 0 LS/TBB

  assign rf_ls_offset_addr_de[4:0]  = rf_rd_remap_de_i                    ? {instr1_top_3_0,   iq_instr1_common_i[3:0]}   : // Slot 1 LS
                                                                            {instr0_top_3_0,   iq_instr0_common_i[3:0]};    // Slot 0 LS

  assign exp_srs_mode_de        = iq_instr0_is_ls_i ? exp_srs_mode_ls_i[7:0]  : 8'h00;  // Only used on LS decoder load/stores
  assign srs_mode_ctl_early_de  = iq_instr0_is_ls_i ? srs_mode_ctl_ls_i       : 1'b0;   // (not CP ops or FPU/NEON load/stores)

  ca53dpu_de_reg_extract u_reg_extract_r0_1 (
    //Inputs
    .vaddr_base_i               (rf_ls_base_addr_de[4:0]),
    .vaddr_offset_i             (rf_ls_offset_addr_de[4:0]),
    .exp_cpsr_mode_de_i         (exp_cpsr_mode_de_i[11:0]),
    .exp_srs_mode_de_i          (exp_srs_mode_de),
    .srs_mode_ctl_de_i          (srs_mode_ctl_early_de),
    // Outputs
    .rf_r0_for_fwd_check_de_o   (rf_r0_for_fwd_check_de_o[5:0]),
    .rf_r1_for_fwd_check_de_o   (rf_r1_for_fwd_check_de_o[5:0]),
    .rf_rd_addr_r0_agu_de_o     (rf_rd_addr_r0_agu_de_o[`CA53_LONG_RF_ADDR_W-1:0]),
    .rf_rd_addr_r1_agu_de_o     (rf_rd_addr_r1_agu_de_o[`CA53_LONG_RF_ADDR_W-1:0])
  );

  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  //ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_decoder_fsm_i")
  u_ovl_x_en_decoder_fsm_i (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (en_decoder_fsm_i));

`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
