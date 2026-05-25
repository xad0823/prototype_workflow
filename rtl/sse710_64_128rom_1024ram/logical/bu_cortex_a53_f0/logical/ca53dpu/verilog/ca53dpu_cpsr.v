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
// Abstract :Defines the CPSR pipeline.
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Architectural CPSR bit assignment.
// | 3332 |2| 22 |2| 22  | 2 | 2 | 1111 | 111111 | | | | | |     |
// | 2109 |8| 76 |5| 32  | 1 | 0 | 9876 | 543210 |9|8|7|6|5|43210|
// +------+-+----+-+-----+---+---+------+--------+-+-+-+-+-+-----+
// |      | |    | |     |   |   |      |        | | | | | |     |
// |{NZCV}|Q| IT |J| RES |SS |IL | GE   | IT     |E|A|I|F|T|Mode |
// |      | | 1:0| |     |   |   | [3:0]| [7:2]  | | | | | |[4:0]|
// |      | |    | |     |   |   |      | Mask   | | | | | |     |
// |      | |    | |     |   |   |      | [3:2]  | | | | | |     |
// +------+-+----+-+-----+---+---+------+--------+-+-+-+-+-+-----+
//
// Internal CPSR bit assignment.
//         | 2222 |2| 22 | 2 | 2 | 1111 | 111111 | | | | | |     |
//         | 8765 |4| 32 | 1 | 0 | 9876 | 543210 |9|8|7|6|5|43210|
//         +------+-+----+---+---+------+--------+-+-+-+-+-+-----+
//         |      | |    |   |   |      |        | | | | | |     |
//         |{NZCV}|Q| IT |SS |IL | GE   | IT     |E|A|I|F|T|Mode |
//         |      | | 1:0|   |   | [3:0]| [7:2]  | | | | | |[4:0]|
//         |      | |    |   |   |      | Mask   | | | | | |     |
//         |      | |    |   |   |      | [3:2]  | | | | | |     |
//         +------+-+----+---+---+------+--------+-+-+-+-+-+-----+

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_cpsr `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire                             clk,
  input  wire                             reset_n,
  input  wire                             DFTSE,
  input  wire   [`CA53_SEL_CPSR_EN_W-1:0] expt_cpsr_wr_en_ret_i,
  input  wire  [`CA53_SEL_CPSR_SRC_W-1:0] expt_cpsr_wr_src_ret_i,
  input  wire                       [4:0] expt_cpsr_mode_ret_i,
  input  wire                             insert_forceop_wr_i,    // Indicates a valid force operation
  input  wire                             insert_forceop_ret_i,   // Indicates a valid force operation
  input  wire                             issue_to_iss_i,
  input  wire                             cpsr_ebit_value_de_i,   // New Ebit value for SETEND instruction
  input  wire                       [3:0] ccflags_wr_i,           // CC flags from write-back stage
  input  wire                       [3:0] geflags_wr_i,           // GE flags from write-back stage
  input  wire                       [3:1] aarch64_at_el_i,
  input  wire                             sctlr_endian_el3_i,
  input  wire                             sctlr_endian_el2_i,
  input  wire                             sctlr_endian_el1_i,
  input  wire                             sctlr_el1_e0e_i,        // Endianness at EL0 in AArch64
  input  wire                             sctlr_el3_itd_i,
  input  wire                             sctlr_el2_itd_i,
  input  wire                             sctlr_el1_itd_i,
  input  wire                             hsctlr_te_i,            // CP15 TE bit in HYP mode
  input  wire                             sctlr_ns_te_i,          // CP15 TE bit (NS)
  input  wire                             sctlr_s_te_i,           // CP15 TE bit (S)
  input  wire                             it_cpsr_v_de_i,         // IT instruction/block being decoded
  input  wire                       [7:0] it_cpsr_mask_de_i,      // IT mask value
  input  wire                       [5:0] cpsr_aifbits_val_i,     // CPSR values for CPS instruction
  input  wire                             stall_slot0_iss_i,      // Suppress the instruction in slot 0 of Iss
  input  wire                             stall_iss_i,            // Stall from Iss stage
  input  wire                             stall_wr_i,             // Stall from Wr stage
  input  wire                       [5:0] alu0_fwd_data_early_ex2_i,
  input  wire                      [31:0] alu0_fwd_data_early_wr_i,
  input  wire                      [31:0] rfe_data_wr_i,          // Load data from swizzle unit
  input  wire                             mul_qbit_wr_i,          // Multiply operation updating q-bit
  input  wire                             alu0_qbit_wr_i,         // ALU0: V5E Saturation has occured, so set the Q-bit.
  input  wire                             alu1_qbit_wr_i,         // ALU1: V5E Saturation has occured, so set the Q-bit.
  input  wire                             end_instr_wr_i,
  input  wire                             pre_end_instr_wr_i,
  input  wire                       [1:0] valid_instrs_wr_i,      // Number of valid instructions in Wr
  input  wire                             cc_pass_instr0_wr_i,    // Instr 0 has passed its conditions codes
  input  wire                             cc_pass_instr1_wr_i,    // Instr 1 has passed its condition codes
  input  wire                             flush_wr_i,             // Global signal. DPU flush in Wr-stage
  input  wire                             advance_pipeline_i,     // Main pipeline advance signal from ctl block
  input  wire                             quash_wr_i,             // Kill current instruction in Wr-stage
  input  wire                             quash_slot0_wr_i,       // Supress updating of the IT bits
  input  wire                             br_flush_wr_i,
  input  wire                             expt_slot1_wr_i,
  input  wire                             ld_t_bit_wr_i,          // The new t-bit from the load data packet
  input  wire                             prefetch_flush_wr_i,
  input  wire                             in_halt_i,              // Core is in HALT mode
  input  wire                       [3:0] cpsr_flag_update_nzcv_i,// Flags to be updated in CPSR-ret
  input  wire                             hcr_tge_i,
  input  wire                             scr_ea_i,
  input  wire                             scr_fiq_i,
  input  wire                             scr_irq_i,
  input  wire                             ns_scr_i,
  input  wire                             wr_scr_i,
  input  wire                             ns_state_i,
  input  wire                             nxt_ns_scr_i,
  input  wire                       [3:0] msr_mrs_data_wr_i,
  input  wire                             psr_wr_operation_de_i,
  input  wire                       [5:0] psr_wr_en_de_i,
  input  wire                       [3:0] psr_wr_src_de_i,
  input  wire                             slot1_blx_ex2_i,
  input  wire                             slot1_bx_wr_i,
  input  wire                             slot1_blx_wr_i,
  input  wire                             slot1_mul_wr_i,
  input  wire [`CA53_FLAGEN_INSTR1_W-1:0] flag_en_instr1_wr_i,
  input  wire                       [8:0] raw_cp_decode_wr_i,
  input  wire                             cp14_wr_dspsr_i,
  input  wire                      [31:0] mcr_data_wr_i,
  input  wire                             dbg_starting_i,
  input  wire                       [1:0] exception_level_debug_i,
  input  wire                       [3:0] debug_enabled_from_el_i,
  input  wire                             mdscr_el1_ss_i,
  // Outputs
  output wire                      [31:0] cpsr_ret_o,             // CPSR retired state value
  output wire                      [31:0] spsr_ret_o,             // SPSR retired state value
  output wire                      [31:0] cpsr_masked_ret_o,
  output wire                      [31:0] psr_cp_rd_data_o,
  output wire                             cpsr_ssbit_ret_o,
  output wire                             cpsr_ilbit_ret_o,
  output wire                             cpsr_dbit_ret_o,        // CPSR D-bit in Ret-stage
  output wire                             cpsr_ibit_ret_o,        // CPSR I-bit in Ret-stage
  output wire                             cpsr_fbit_ret_o,        // CPSR F-bit in Ret-stage
  output wire                             cpsr_abit_ret_o,
  output wire                             cpsr_tbit_wr_o,
  output wire                             nxt_cpsr_tbit_ret_pre_o,
  output wire                       [1:0] dpu_fe_isa_wr_o,
  output wire                       [1:0] dpu_fe_isa_ret_o,
  output wire                       [7:0] dpu_fe_itstate_ret_o,
  output wire                       [4:0] spec_cpsr_mode_iss_o,
  output wire                             spec_cpsr_mode_usr_iss_o,
  output wire                             spec_cpsr_mode_sys_iss_o,
  output wire                             spec_cpsr_mode_mon_iss_o,
  output wire                             spec_cpsr_mode_hyp_iss_o,
  output wire                             nxt_mon_el3_mode_ret_o,
  output wire                       [1:0] dpu_exception_level_o,
  output wire                             cpsr_tbit_ret_o,
  output wire                             isa_switch_br_ex2_o,
  output wire                             branch_align_pc_wr_o,
  output wire                             debug_exit_aa32_o,
  output wire                             expt_rtn_wr_o,
  output wire                             expt_rtn_ret_o,
  output wire                             spec_endianness_iss_o,
  output wire                             spec_endianness_ex2_o,
  output wire      [`CA53_CPSR_RET_W-1:0] dspsr_reg_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                   [4:0] nxt_spec_cpsr_mode_iss;
  reg                         nxt_spec_cpsr_mode_usr_iss;
  reg                         nxt_spec_cpsr_mode_sys_iss;
  reg                         nxt_spec_cpsr_mode_mon_iss;
  reg                         nxt_spec_cpsr_mode_hyp_iss;
  reg                         force_ebit_iss;
  reg                         force_aifbits_iss;
  reg                   [4:0] force_modebits_iss;
  reg                   [4:0] spec_cpsr_mode_iss;
  reg                         spec_cpsr_mode_usr_iss;
  reg                         spec_cpsr_mode_sys_iss;
  reg                         spec_cpsr_mode_mon_iss;
  reg                         spec_cpsr_mode_hyp_iss;
  reg                   [7:0] it_cpsr_mask_iss;
  reg                         it_cpsr_v_iss;
  reg                         force_ebit_ex1;
  reg                         force_aifbits_ex1;
  reg                   [4:0] force_modebits_ex1;
  reg                   [7:0] it_cpsr_mask_ex1;
  reg                         it_cpsr_v_ex1;
  reg                         force_ebit_ex2;
  reg                         force_aifbits_ex2;
  reg                   [4:0] force_modebits_ex2;
  reg                   [7:0] it_cpsr_mask_ex2;
  reg                         it_cpsr_v_ex2;
  reg                         force_ebit_wr;
  reg                         force_aifbits_wr;
  reg                   [4:0] force_modebits_wr;
  reg                   [7:0] it_cpsr_mask_wr;
  reg                         raw_it_cpsr_v_wr;
  reg                   [3:0] nxt_cpsr_nzcvbits_ret;
  reg                         nxt_cpsr_qbit_ret_slot0;
  reg                   [7:0] nxt_cpsr_itbits_ret_pre;
  reg                         nxt_cpsr_ssbit_ret;
  reg                         nxt_cpsr_ilbit_ret_pre;
  reg                   [3:0] nxt_cpsr_gebits_ret_pre;
  reg                         nxt_cpsr_edbit_ret;
  reg                         nxt_cpsr_abit_ret;
  reg                         nxt_cpsr_ibit_ret;
  reg                         nxt_cpsr_fbit_ret;
  reg                         nxt_cpsr_tbit_ret_pre;
  reg  [`CA53_SPSR_RET_W-1:0] nxt_spsr_ret;
  reg                   [4:0] prefix_cpsr_modebits_wr;
  reg                         illegal_target_mode_wr;
  reg                         cpsr_valid_iss;
  reg                         cpsr_valid_ex1;
  reg                         cpsr_valid_ex2;
  reg                         cpsr_valid_wr;
  reg                         alu_tbit_wr;
  reg                   [4:0] alu_mbits_wr;
  reg                   [5:0] psr_wr_en_iss;
  reg                   [5:0] psr_wr_en_ex1;
  reg                   [5:0] psr_wr_en_ex2;
  reg                   [5:0] raw_psr_wr_en_wr;
  reg                   [3:0] psr_wr_src_iss;
  reg                   [3:0] psr_wr_src_ex1;
  reg                   [3:0] psr_wr_src_ex2;
  reg                   [3:0] raw_psr_wr_src_wr;
  reg                         expt_rtn_ret;
  reg                   [1:0] nxt_dpu_exception_level;
  reg                   [1:0] dpu_exception_level;
  reg                         aarch64_endianness;
  reg                         spec_endianness_ex2;
  reg                         early_psr_ctl_clock_en;
  reg                         nxt_sctlr_itd;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                  [7:0] force_itbits_wr;
  wire [`CA53_CPSR_RET_W-1:0] nxt_cpsr_ret;
  wire [`CA53_CPSR_RET_W-1:0] nxt_dspsr_ret;
  wire [`CA53_CPSR_RET_W-1:0] cpsr_ret_reg;
  wire [`CA53_CPSR_RET_W-1:0] dspsr_ret_reg;
  wire                 [31:0] cpsr_ret_full;
  wire [`CA53_SPSR_RET_W-1:0] spsr_ret_reg;
  wire                 [31:0] spsr_ret_full;
  wire                        eld_is_aarch64;
  wire                        step_disabled_at_current;
  wire                        step_enabled_at_target;
  wire                        spsr_ss_mask;
  wire                        dspsr_ss_mask;
  wire                        ctlr_ed_bit;
  wire                        ctlr_a_bit;
  wire                        ctlr_i_bit;
  wire                        ctlr_f_bit;
  wire                        ctlr_te_bit;
  wire                        it_cpsr_v_wr;
  wire                  [3:0] it_mask_ret;
  wire                  [3:0] it_cond_ret;
  wire                        nxt_it_cpsr_v_iss;
  wire                        cpsr_valid_iss_en;
  wire                        it_cpsr_mask_iss_en;
  wire                        it_cpsr_mask_ex1_en;
  wire                        it_cpsr_mask_ex2_en;
  wire                        it_cpsr_mask_wr_en;
  wire                        nxt_it_cpsr_v_ex1;
  wire                        nxt_it_cpsr_v_ex2;
  wire                  [5:0] psr_wr_en_wr;
  wire                  [3:0] psr_wr_src_wr;
  wire                        nxt_it_cpsr_v_wr;
  wire                        nxt_cpsr_qbit_ret_pre;
  wire                        nxt_cpsr_qbit_ret;
  wire                        nxt_cpsr_ilbit_ret;
  wire                  [7:0] nxt_cpsr_itbits_ret;
  wire                  [3:0] nxt_cpsr_gebits_ret;
  wire                        nxt_cpsr_tbit_ret;
  wire                  [3:0] sel_cpsr_nzcvbits_wr;
  wire                  [3:0] sel_cpsr_qbits_wr;
  wire                  [3:0] sel_cpsr_ssbit_wr;
  wire                  [3:0] sel_cpsr_ilbit_wr;
  wire                  [3:0] sel_cpsr_gebits_wr;
  wire                  [3:0] sel_cpsr_itbits_wr;
  wire                  [3:0] sel_cpsr_tbit_wr;
  wire                  [3:0] sel_cpsr_edbit_wr;
  wire                  [3:0] sel_cpsr_abit_wr;
  wire                  [3:0] sel_cpsr_ibit_wr;
  wire                  [3:0] sel_cpsr_fbit_wr;
  wire                  [3:0] sel_cpsr_modebits_wr;
  wire                        illegal_hyp_exit_wr;
  wire                        illegal_mode_change_wr;
  wire                  [4:0] nxt_cpsr_modebits_ret;
  wire                  [3:0] sel_spsr_ex2;
  wire                  [3:0] sel_spsr_wr;
  wire                  [3:0] spsr_mask_wr;
  wire                        spsr_regfile_en_wr;
  wire                        cpsr_regfile_en_wr;
  wire                        dspsr_regfile_en_wr;
  wire                        active_it_block_wr;
  wire                        nxt_cpsr_valid_iss;
  wire                        nxt_cpsr_valid_ex1;
  wire                        nxt_cpsr_valid_ex2;
  wire                        nxt_cpsr_valid_wr;
  wire                        priv_or_debug_ret;
  wire                        halting_debug;
  wire                 [31:0] cpsr_read_mask;
  wire                        single_issue_valid_wr;
  wire                        dual_issue_valid_wr;
  wire                  [3:0] new_it_mask_wr;
  wire                  [3:0] new_it_cond_wr;
  wire                        cpsr_tbit_wr;
  wire                        sel_ebit_iss;
  wire                        sel_ebit_ex1;
  wire                        sel_ebit_ex2;
  wire                        endianness_ret;
  wire                        nxt_spec_endianness_ex2;
  wire                        bx_instr1_v_wr;
  wire                        blx_instr1_v_wr;
  wire                        expt_rtn_wr;
  wire                        nxt_expt_rtn_ret;
  wire                        nxt_hyp_mode_ret;
  wire                        advance_cpsr_pipeline;
  wire                        dpu_exception_level_en;
  wire                        nxt_early_psr_ctl_clock_en;
  wire                        psr_ctl_clock_en;
  wire                        clk_psr_ctl;
  wire                        spsr_clock_en_ex2;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Regional clock gate
  // ------------------------------------------------------

  // Clock gate the control pipeline from Ex1 -> Wr
  assign nxt_early_psr_ctl_clock_en = (cpsr_valid_iss | cpsr_valid_ex1 | cpsr_valid_ex2 | cpsr_valid_wr | expt_rtn_ret |
                                       it_cpsr_v_iss  | it_cpsr_v_ex1  | it_cpsr_v_ex2  | raw_it_cpsr_v_wr);

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      early_psr_ctl_clock_en <= 1'b1;
    else
      early_psr_ctl_clock_en <= nxt_early_psr_ctl_clock_en;

  assign psr_ctl_clock_en = early_psr_ctl_clock_en | cpsr_valid_iss | it_cpsr_v_iss;

  ca53_cell_inter_clkgate u_inter_clkgate_psr_ctl (
    .clk_i         (clk),
    .clk_enable_i  (psr_ctl_clock_en),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_psr_ctl)
  );

  // ------------------------------------------------------
  // Pipeline advancement
  // ------------------------------------------------------

  assign advance_cpsr_pipeline = ~stall_wr_i | flush_wr_i;

  // ------------------------------------------------------
  // CPSR speculative bit setting
  // ------------------------------------------------------

  // Indicate the mode/state of the processor to suppress certain CPSR operations
  assign priv_or_debug_ret = (cpsr_ret_reg[`CA53_CPSR_RET_MODE_BITS] != `CA53_FULL_MODE_USR) | halting_debug;

  // Indicate that the processor is in debug state
  assign halting_debug = in_halt_i;

  // Create the speculative CPSR mode for the decoders to use in the next cycle
  always @*
    if (cpsr_regfile_en_wr) begin
      nxt_spec_cpsr_mode_iss     = nxt_cpsr_modebits_ret;
      nxt_spec_cpsr_mode_usr_iss = (nxt_cpsr_modebits_ret == `CA53_FULL_MODE_USR) | (nxt_cpsr_modebits_ret == `CA53_FULL_MODE_EL0T);
      nxt_spec_cpsr_mode_sys_iss = (nxt_cpsr_modebits_ret == `CA53_FULL_MODE_SYS);
      nxt_spec_cpsr_mode_mon_iss = (nxt_cpsr_modebits_ret == `CA53_FULL_MODE_MON);
      nxt_spec_cpsr_mode_hyp_iss = (nxt_cpsr_modebits_ret == `CA53_FULL_MODE_HYP);
    end else begin
      nxt_spec_cpsr_mode_iss     = cpsr_ret_reg[`CA53_CPSR_RET_MODE_BITS];
      nxt_spec_cpsr_mode_usr_iss = spec_cpsr_mode_usr_iss;
      nxt_spec_cpsr_mode_sys_iss = spec_cpsr_mode_sys_iss;
      nxt_spec_cpsr_mode_mon_iss = spec_cpsr_mode_mon_iss;
      nxt_spec_cpsr_mode_hyp_iss = spec_cpsr_mode_hyp_iss;
    end

  // Select signals for the speculative CPSR E-bit to the decoders.  This is for
  // the SETEND instruction.
  assign sel_ebit_iss = (psr_wr_en_iss == `CA53_SEL_CPSR_EN_E);
  assign sel_ebit_ex1 = (psr_wr_en_ex1 == `CA53_SEL_CPSR_EN_E);
  assign sel_ebit_ex2 = (psr_wr_en_ex2 == `CA53_SEL_CPSR_EN_E);

  always @*
    case (dpu_exception_level)
      `CA53_EL0: aarch64_endianness = sctlr_el1_e0e_i;
      `CA53_EL1: aarch64_endianness = sctlr_endian_el1_i;
      `CA53_EL2: aarch64_endianness = sctlr_endian_el2_i;
      `CA53_EL3: aarch64_endianness = sctlr_endian_el3_i;
      default: aarch64_endianness = 1'bx;
    endcase

  assign endianness_ret = cpsr_ret_reg[4] ? cpsr_ret_reg[`CA53_CPSR_RET_E_BITS] : aarch64_endianness;

generate if (NEON_FP) begin : FPU1
  reg  spec_endianness_iss;
  wire nxt_spec_endianness_iss;

  // Create the speculative CPSR E-bit for the FPU/Neon control logic to use in the iss stage
  assign nxt_spec_endianness_iss = (sel_ebit_iss & cpsr_valid_iss) ? force_ebit_iss     :
                                   (sel_ebit_ex1 & cpsr_valid_ex1) ? force_ebit_ex1     :
                                                                     nxt_spec_endianness_ex2;

  always @(posedge clk)
    if (advance_cpsr_pipeline)
      spec_endianness_iss <= nxt_spec_endianness_iss;

  assign spec_endianness_iss_o = spec_endianness_iss;

end else begin : FPU1_STUBS
  assign spec_endianness_iss_o = 1'b0;
end endgenerate

  assign nxt_spec_endianness_ex2 = (sel_ebit_ex2 & cpsr_valid_ex2)        ? force_ebit_ex2      :
                                   (cpsr_ret_reg[4] & cpsr_regfile_en_wr) ? nxt_cpsr_edbit_ret
                                                                          : endianness_ret;

  always @(posedge clk)
    if (advance_cpsr_pipeline)
      spec_endianness_ex2 <= nxt_spec_endianness_ex2;

  assign spec_endianness_ex2_o = spec_endianness_ex2;

  // ------------------------------------------------------
  // CPSR Wr Stage, IT and IT block execution
  // ------------------------------------------------------

  assign it_mask_ret = {cpsr_ret_reg[`CA53_CPSR_RET_IT_HIGH_BITS], cpsr_ret_reg[`CA53_CPSR_RET_IT_LOW_BITS]};
  assign it_cond_ret =  cpsr_ret_reg[`CA53_CPSR_RET_IT_COND_BITS];

  // If the IT bits in cpsr_ret_reg are not all zero, then we are currently
  // executing instructions from an IT block.
  assign active_it_block_wr = (|it_mask_ret[3:0]);

  // IT block instructions can be dual issued. Thus we need to shift
  // the cond mask by LSL 2, else if single issue, then LSL 1
  assign dual_issue_valid_wr = pre_end_instr_wr_i & valid_instrs_wr_i[1] & ~expt_slot1_wr_i; // Do not update based on dual issued instruction if it aborts

  // If an instruction in slot 1 aborts, force an update for the slot 0
  // instruction (which may not have end signaled due to the slot 1
  // instruction being x64)
  // If a slot 0 branch is dual-issued with a load or store which is x64,
  // then pre_end_instr_wr may not be set, so force update if the branch
  // flushes
  assign single_issue_valid_wr = pre_end_instr_wr_i | expt_slot1_wr_i | br_flush_wr_i;

  assign new_it_mask_wr = (dual_issue_valid_wr   ? {it_mask_ret[1:0], 2'b00} : // Dual issued IT block
                           single_issue_valid_wr ? {it_mask_ret[2:0], 1'b0}  : // Single issued IT block
                                                    it_mask_ret[3:0]);         // Pipeline bubble

  assign new_it_cond_wr = (dual_issue_valid_wr   ? ({4{|it_mask_ret[1:0]}} & {it_cond_ret[3:1], it_mask_ret[2]}) : // Dual issued IT block
                           single_issue_valid_wr ? ({4{|it_mask_ret[2:0]}} & {it_cond_ret[3:1], it_mask_ret[3]}) : // Single issued IT block
                                                   ({4{|it_mask_ret[3:0]}} &  it_cond_ret[3:0]));                  // Pipeline bubble

  // If dual issued, the branch will be the second instruction
  assign it_cpsr_v_wr = raw_it_cpsr_v_wr & (dual_issue_valid_wr ? cc_pass_instr1_wr_i : cc_pass_instr0_wr_i);

  assign force_itbits_wr = (it_cpsr_v_wr ? it_cpsr_mask_wr : {new_it_cond_wr, new_it_mask_wr});

  // ------------------------------------------------------
  // Iss stage registers
  // ------------------------------------------------------

  assign nxt_cpsr_valid_iss = issue_to_iss_i & psr_wr_operation_de_i;
  assign nxt_it_cpsr_v_iss  = it_cpsr_v_de_i & ~flush_wr_i;
  assign cpsr_valid_iss_en  = ~stall_iss_i | flush_wr_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      cpsr_valid_iss          <= 1'b0;
      it_cpsr_v_iss           <= 1'b0;
    end else if (cpsr_valid_iss_en) begin
      cpsr_valid_iss          <= nxt_cpsr_valid_iss;
      it_cpsr_v_iss           <= nxt_it_cpsr_v_iss;
    end

  always @(posedge clk)
    if (nxt_cpsr_valid_iss) begin
      psr_wr_src_iss      <= psr_wr_src_de_i;
      force_ebit_iss      <= cpsr_ebit_value_de_i;
      force_aifbits_iss   <= cpsr_aifbits_val_i[5];
      force_modebits_iss  <= cpsr_aifbits_val_i[4:0];
      psr_wr_en_iss       <= psr_wr_en_de_i;
    end

  assign it_cpsr_mask_iss_en = it_cpsr_v_de_i & issue_to_iss_i;

  always @(posedge clk)
    if (it_cpsr_mask_iss_en)
      it_cpsr_mask_iss <= it_cpsr_mask_de_i;

  // Need to initialise the speculative mode bits at reset (to supervisor mode),
  // since this value is exported to the IFU
  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      spec_cpsr_mode_iss     <= `CA53_FULL_MODE_SVC;
      spec_cpsr_mode_usr_iss <= 1'b0;
      spec_cpsr_mode_sys_iss <= 1'b0;
      spec_cpsr_mode_mon_iss <= 1'b0;
      spec_cpsr_mode_hyp_iss <= 1'b0;
    end else begin
      spec_cpsr_mode_iss     <= nxt_spec_cpsr_mode_iss;
      spec_cpsr_mode_usr_iss <= nxt_spec_cpsr_mode_usr_iss;
      spec_cpsr_mode_sys_iss <= nxt_spec_cpsr_mode_sys_iss;
      spec_cpsr_mode_mon_iss <= nxt_spec_cpsr_mode_mon_iss;
      spec_cpsr_mode_hyp_iss <= nxt_spec_cpsr_mode_hyp_iss;
    end

  // ------------------------------------------------------
  // Ex1 stage registers
  // ------------------------------------------------------

  assign nxt_cpsr_valid_ex1 = cpsr_valid_iss & ~flush_wr_i & ~stall_slot0_iss_i;
  assign nxt_it_cpsr_v_ex1  = it_cpsr_v_iss  & ~flush_wr_i & ~stall_slot0_iss_i;

  always @(posedge clk_psr_ctl or negedge reset_n)
    if (~reset_n) begin
      cpsr_valid_ex1     <= 1'b0;
      it_cpsr_v_ex1      <= 1'b0;
    end else if (advance_cpsr_pipeline) begin
      cpsr_valid_ex1     <= nxt_cpsr_valid_ex1;
      it_cpsr_v_ex1      <= nxt_it_cpsr_v_ex1;
    end

  always @(posedge clk_psr_ctl)
    if (nxt_cpsr_valid_ex1) begin
      psr_wr_src_ex1     <= psr_wr_src_iss;
      force_ebit_ex1     <= force_ebit_iss;
      force_aifbits_ex1  <= force_aifbits_iss;
      force_modebits_ex1 <= force_modebits_iss;
      psr_wr_en_ex1      <= psr_wr_en_iss;
    end

  assign it_cpsr_mask_ex1_en = it_cpsr_v_iss & ~stall_wr_i;

  always @(posedge clk_psr_ctl)
    if (it_cpsr_mask_ex1_en)
      it_cpsr_mask_ex1   <= it_cpsr_mask_iss;

  // ------------------------------------------------------
  // Ex2 stage registers
  // ------------------------------------------------------

  assign nxt_cpsr_valid_ex2 = cpsr_valid_ex1 & ~flush_wr_i & ~stall_wr_i;
  assign nxt_it_cpsr_v_ex2  = it_cpsr_v_ex1  & ~flush_wr_i;

  always @(posedge clk_psr_ctl or negedge reset_n)
    if (~reset_n) begin
      cpsr_valid_ex2     <= 1'b0;
      it_cpsr_v_ex2      <= 1'b0;
    end else if (advance_cpsr_pipeline) begin
      cpsr_valid_ex2     <= nxt_cpsr_valid_ex2;
      it_cpsr_v_ex2      <= nxt_it_cpsr_v_ex2;
    end

  always @(posedge clk_psr_ctl)
    if (nxt_cpsr_valid_ex2) begin
      psr_wr_src_ex2     <= psr_wr_src_ex1;
      force_ebit_ex2     <= force_ebit_ex1;
      force_aifbits_ex2  <= force_aifbits_ex1;
      force_modebits_ex2 <= force_modebits_ex1;
      psr_wr_en_ex2      <= psr_wr_en_ex1;
    end

  assign it_cpsr_mask_ex2_en = it_cpsr_v_ex1 & ~stall_wr_i;

  always @(posedge clk_psr_ctl)
    if (it_cpsr_mask_ex2_en)
      it_cpsr_mask_ex2  <= it_cpsr_mask_ex1;

  // ------------------------------------------------------
  // Wr stage registers
  // ------------------------------------------------------

  assign nxt_cpsr_valid_wr = cpsr_valid_ex2 & ~flush_wr_i & ~stall_wr_i;
  assign nxt_it_cpsr_v_wr  = it_cpsr_v_ex2  & ~flush_wr_i;

  always @(posedge clk_psr_ctl or negedge reset_n)
    if (~reset_n) begin
      cpsr_valid_wr     <= 1'b0;
      raw_it_cpsr_v_wr  <= 1'b0;
    end
    else if (advance_pipeline_i) begin
      cpsr_valid_wr     <= nxt_cpsr_valid_wr;
      raw_it_cpsr_v_wr  <= nxt_it_cpsr_v_wr;
    end

  always @(posedge clk_psr_ctl)
    if (nxt_cpsr_valid_wr) begin
      raw_psr_wr_src_wr <= psr_wr_src_ex2;
      force_ebit_wr     <= force_ebit_ex2;
      force_aifbits_wr  <= force_aifbits_ex2;
      force_modebits_wr <= force_modebits_ex2;
      alu_tbit_wr       <= alu0_fwd_data_early_ex2_i[5];
      alu_mbits_wr      <= alu0_fwd_data_early_ex2_i[4:0];
      raw_psr_wr_en_wr  <= psr_wr_en_ex2;
    end

  assign it_cpsr_mask_wr_en = it_cpsr_v_ex2 & ~stall_wr_i;

  always @(posedge clk_psr_ctl)
    if (it_cpsr_mask_wr_en)
      it_cpsr_mask_wr   <= it_cpsr_mask_ex2;

  // ------------------------------------------------------
  // Final Wr stage CPSR bus
  // ------------------------------------------------------

  // Combine all the parts of the CPSR to form the next value for the
  // register.  Note: bit-positions are marked, two values are given, one is
  // the bit position in the actual register, the other is the bit position
  // in the architectural CPSR
  assign nxt_cpsr_ret = {nxt_cpsr_nzcvbits_ret[3:0],   // [28:25] [31:28]
                         nxt_cpsr_qbit_ret,            // [24]    [27]
                         nxt_cpsr_itbits_ret[1:0],     // [23:22] [26:25]
                         // J bit                                 [24]
                         // Two reserved bits                     [23:22]
                         nxt_cpsr_ssbit_ret,           // [21]    [21]
                         nxt_cpsr_ilbit_ret,           // [20]    [20]
                         nxt_cpsr_gebits_ret[3:0],     // [19:16] [19:16]
                         nxt_cpsr_itbits_ret[7:2],     // [15:10] [15:10]
                         nxt_cpsr_edbit_ret,           // [9]     [9]
                         nxt_cpsr_abit_ret,            // [8]     [8]
                         nxt_cpsr_ibit_ret,            // [7]     [7]
                         nxt_cpsr_fbit_ret,            // [6]     [6]
                         nxt_cpsr_tbit_ret,            // [5]     [5]
                         nxt_cpsr_modebits_ret};       // [4:0]   [4:0]

  assign psr_wr_en_wr  = insert_forceop_ret_i ? expt_cpsr_wr_en_ret_i  : ({6{cpsr_valid_wr & cc_pass_instr0_wr_i}} & raw_psr_wr_en_wr);
  assign psr_wr_src_wr = insert_forceop_ret_i ? expt_cpsr_wr_src_ret_i : raw_psr_wr_src_wr;

  // ------------------------------------------------------
  // Final Wr stage SPSR bus
  // ------------------------------------------------------

  assign sel_spsr_wr = ((psr_wr_en_wr[5:4] == 2'b11)              |
                        (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETIM)  |
                        (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIM) |
                        (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIFM)) ? psr_wr_src_wr[3:0] : `CA53_SEL_CPSR_SRC_SPSR;

  always @*
    case (sel_spsr_wr)
      `CA53_SEL_CPSR_SRC_CPSR,
      `CA53_SEL_CPSR_SRC_FORCE : nxt_spsr_ret = cpsr_ret_reg;
      `CA53_SEL_CPSR_SRC_DP    : nxt_spsr_ret = {alu0_fwd_data_early_wr_i[`CA53_PSR_ARCH_NZCVQ_BITS],   // Flags
                                                 alu0_fwd_data_early_wr_i[`CA53_PSR_ARCH_IT_LOW_BITS],  // IT
                                                 alu0_fwd_data_early_wr_i[`CA53_PSR_ARCH_SS_BITS],      // SS
                                                 alu0_fwd_data_early_wr_i[`CA53_PSR_ARCH_IL_BITS],      // IL
                                                 alu0_fwd_data_early_wr_i[`CA53_PSR_ARCH_GE_BITS],      // GE
                                                 alu0_fwd_data_early_wr_i[`CA53_PSR_ARCH_IT_HICM_BITS], // IT
                                                 alu0_fwd_data_early_wr_i[`CA53_PSR_ARCH_EAIF_BITS],    // Ctl
                                                 alu_tbit_wr,                                           // T
                                                 alu_mbits_wr};                                         // Mode
      default                  : nxt_spsr_ret = {`CA53_SPSR_RET_W{1'bx}};
    endcase

  // The MSR mask
  assign spsr_mask_wr[3:0] = (psr_wr_en_wr[5:4] == 2'b11) ? psr_wr_en_wr[3:0] : 4'b1111;

  // ------------------------------------------------------
  // NZCV Flag-bits update
  // ------------------------------------------------------
  // If instr1 wants to update the flags force the encoding to instr1
  assign sel_cpsr_nzcvbits_wr = (psr_wr_src_wr[3:0] & {4{(psr_wr_en_wr == `CA53_SEL_CPSR_EN_CC)   |
                                                         (psr_wr_en_wr == `CA53_SEL_CPSR_EN_SPSR) |
                                                         (psr_wr_en_wr[5:3] == 3'b011)}})       |
                                {4{(flag_en_instr1_wr_i == `CA53_FLAGEN_INSTR1_CC) & ~quash_wr_i & ~br_flush_wr_i}};

  always @*
    case (sel_cpsr_nzcvbits_wr)
      `CA53_SEL_CPSR_SRC_CPSR    : nxt_cpsr_nzcvbits_ret = cpsr_ret_reg[`CA53_CPSR_RET_NZCV_BITS];
      `CA53_SEL_CPSR_SRC_SPSR    : nxt_cpsr_nzcvbits_ret = spsr_ret_reg[`CA53_SPSR_RET_NZCV_BITS];
      `CA53_SEL_CPSR_SRC_DSPSR   : nxt_cpsr_nzcvbits_ret = dspsr_ret_reg[`CA53_SPSR_RET_NZCV_BITS];
      `CA53_SEL_CPSR_SRC_DP      : nxt_cpsr_nzcvbits_ret = alu0_fwd_data_early_wr_i[`CA53_PSR_ARCH_NZCV_BITS];
      `CA53_SEL_CPSR_SRC_CCFLAGS : nxt_cpsr_nzcvbits_ret = ccflags_wr_i;
      `CA53_SEL_CPSR_SRC_RFE     : nxt_cpsr_nzcvbits_ret = rfe_data_wr_i[`CA53_PSR_ARCH_NZCV_BITS];
      `CA53_SEL_CPSR_SRC_DSCR    : nxt_cpsr_nzcvbits_ret = cpsr_flag_update_nzcv_i;
      `CA53_SEL_CPSR_SRC_INSTR1  : nxt_cpsr_nzcvbits_ret = ccflags_wr_i;
      default                    : nxt_cpsr_nzcvbits_ret = 4'bxxxx;
    endcase

  // ------------------------------------------------------
  // Q Flag-bit update
  // ------------------------------------------------------

  assign sel_cpsr_qbits_wr = (psr_wr_src_wr[3:0] & {4{(psr_wr_en_wr == `CA53_SEL_CPSR_EN_Q)    |
                                                      (psr_wr_en_wr == `CA53_SEL_CPSR_EN_SPSR) |
                                                      (psr_wr_en_wr[5:3] == 3'b011)}});

  always @*
    case (sel_cpsr_qbits_wr)
      `CA53_SEL_CPSR_SRC_CPSR   : nxt_cpsr_qbit_ret_slot0 = cpsr_ret_reg[`CA53_CPSR_RET_Q_BITS];
      `CA53_SEL_CPSR_SRC_SPSR   : nxt_cpsr_qbit_ret_slot0 = spsr_ret_reg[`CA53_SPSR_RET_Q_BITS];
      `CA53_SEL_CPSR_SRC_DSPSR  : nxt_cpsr_qbit_ret_slot0 = dspsr_ret_reg[`CA53_SPSR_RET_Q_BITS];
      `CA53_SEL_CPSR_SRC_MUL    : nxt_cpsr_qbit_ret_slot0 = mul_qbit_wr_i | cpsr_ret_reg[`CA53_CPSR_RET_Q_BITS];
      `CA53_SEL_CPSR_SRC_DP     : nxt_cpsr_qbit_ret_slot0 = alu0_fwd_data_early_wr_i[`CA53_PSR_ARCH_Q_BITS];
      `CA53_SEL_CPSR_SRC_QFLAG  : nxt_cpsr_qbit_ret_slot0 = alu0_qbit_wr_i | cpsr_ret_reg[`CA53_CPSR_RET_Q_BITS];
      `CA53_SEL_CPSR_SRC_RFE    : nxt_cpsr_qbit_ret_slot0 = rfe_data_wr_i[`CA53_PSR_ARCH_Q_BITS];
      default                   : nxt_cpsr_qbit_ret_slot0 = 1'bx;
    endcase

  assign nxt_cpsr_qbit_ret_pre = ((flag_en_instr1_wr_i == `CA53_FLAGEN_INSTR1_Q) &
                                  ~quash_wr_i & ~br_flush_wr_i) ? ((slot1_mul_wr_i ? mul_qbit_wr_i : alu1_qbit_wr_i) | 
                                                                   nxt_cpsr_qbit_ret_slot0)
                                                                : nxt_cpsr_qbit_ret_slot0;

  // Q bit is zero in AArch64
  assign nxt_cpsr_qbit_ret = nxt_cpsr_qbit_ret_pre & nxt_cpsr_modebits_ret[4];

  // ------------------------------------------------------
  // SS-bit update
  // ------------------------------------------------------

  assign eld_is_aarch64 = ((exception_level_debug_i == `CA53_EL2) & aarch64_at_el_i[2]) |
                          ((exception_level_debug_i == `CA53_EL1) & aarch64_at_el_i[1]);

  assign step_disabled_at_current = ~debug_enabled_from_el_i[dpu_exception_level] |
                                    in_halt_i |
                                    ((dpu_exception_level == exception_level_debug_i) &
                                     cpsr_ret_reg[`CA53_CPSR_RET_D_BITS]);

  assign step_enabled_at_target = debug_enabled_from_el_i[nxt_dpu_exception_level] &
                                  (~in_halt_i | (insert_forceop_ret_i & (psr_wr_src_wr == `CA53_SEL_CPSR_SRC_DSPSR))) &
                                  (((nxt_dpu_exception_level == exception_level_debug_i) & ~nxt_cpsr_edbit_ret) |
                                    (nxt_dpu_exception_level <  exception_level_debug_i));

  assign spsr_ss_mask  = mdscr_el1_ss_i & eld_is_aarch64 & step_disabled_at_current & step_enabled_at_target;
  assign dspsr_ss_mask = mdscr_el1_ss_i & eld_is_aarch64 & step_enabled_at_target;

  assign sel_cpsr_ssbit_wr = psr_wr_src_wr[3:0] &
                              {4{(psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETIM)   |
                                 (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIM)  |
                                 (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIFM) |
                                 (psr_wr_en_wr == `CA53_SEL_CPSR_EN_SPSR)}};

  always @*
    case (sel_cpsr_ssbit_wr)
      `CA53_SEL_CPSR_SRC_CPSR   : nxt_cpsr_ssbit_ret = cpsr_ret_reg[`CA53_CPSR_RET_SS_BITS] & ~end_instr_wr_i; // Zero on executing an instruction
      `CA53_SEL_CPSR_SRC_SPSR   : nxt_cpsr_ssbit_ret = spsr_ret_reg[`CA53_SPSR_RET_SS_BITS]  & spsr_ss_mask;
      `CA53_SEL_CPSR_SRC_DSPSR  : nxt_cpsr_ssbit_ret = dspsr_ret_reg[`CA53_SPSR_RET_SS_BITS] & dspsr_ss_mask;
      `CA53_SEL_CPSR_SRC_RFE    : nxt_cpsr_ssbit_ret = 1'b0;
      `CA53_SEL_CPSR_SRC_FORCE  : nxt_cpsr_ssbit_ret = 1'b0;
      default                   : nxt_cpsr_ssbit_ret = 1'bx;
    endcase

  // ------------------------------------------------------
  // IL-bit update
  // ------------------------------------------------------

  assign sel_cpsr_ilbit_wr = psr_wr_src_wr[3:0] &
                              {4{(psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETIM)   |
                                 (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIM)  |
                                 (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIFM) |
                                 (psr_wr_en_wr == `CA53_SEL_CPSR_EN_SPSR)}};

  always @*
    case (sel_cpsr_ilbit_wr)
      `CA53_SEL_CPSR_SRC_CPSR   : nxt_cpsr_ilbit_ret_pre = cpsr_ret_reg[`CA53_CPSR_RET_IL_BITS];
      `CA53_SEL_CPSR_SRC_SPSR   : nxt_cpsr_ilbit_ret_pre = spsr_ret_reg[`CA53_SPSR_RET_IL_BITS];
      `CA53_SEL_CPSR_SRC_DSPSR  : nxt_cpsr_ilbit_ret_pre = dspsr_ret_reg[`CA53_SPSR_RET_IL_BITS];
      `CA53_SEL_CPSR_SRC_RFE    : nxt_cpsr_ilbit_ret_pre = rfe_data_wr_i[`CA53_PSR_ARCH_IL_BITS];
      `CA53_SEL_CPSR_SRC_FORCE  : nxt_cpsr_ilbit_ret_pre = 1'b0;
      default                   : nxt_cpsr_ilbit_ret_pre = 1'bx;
    endcase

  // Factor in if an illegal mode change was attempted
  assign nxt_cpsr_ilbit_ret = nxt_cpsr_ilbit_ret_pre | illegal_mode_change_wr;

  // ------------------------------------------------------
  // GE-bits update
  // ------------------------------------------------------

  assign sel_cpsr_gebits_wr = (psr_wr_src_wr[3:0] & {4{ (psr_wr_en_wr == `CA53_SEL_CPSR_EN_GE)   |
                                                        (psr_wr_en_wr == `CA53_SEL_CPSR_EN_SPSR) |
                                                       ((psr_wr_en_wr[5:4] == 2'b01) & psr_wr_en_wr[2])}}) |
                              {4{(flag_en_instr1_wr_i == `CA53_FLAGEN_INSTR1_GE) & ~quash_wr_i & ~br_flush_wr_i}};

  always @*
    case (sel_cpsr_gebits_wr)
      `CA53_SEL_CPSR_SRC_CPSR    : nxt_cpsr_gebits_ret_pre = cpsr_ret_reg[`CA53_CPSR_RET_GE_BITS];
      `CA53_SEL_CPSR_SRC_SPSR    : nxt_cpsr_gebits_ret_pre = spsr_ret_reg[`CA53_SPSR_RET_GE_BITS];
      `CA53_SEL_CPSR_SRC_DSPSR   : nxt_cpsr_gebits_ret_pre = dspsr_ret_reg[`CA53_SPSR_RET_GE_BITS];
      `CA53_SEL_CPSR_SRC_DP      : nxt_cpsr_gebits_ret_pre = alu0_fwd_data_early_wr_i[`CA53_PSR_ARCH_GE_BITS];
      `CA53_SEL_CPSR_SRC_CCFLAGS : nxt_cpsr_gebits_ret_pre = geflags_wr_i;
      `CA53_SEL_CPSR_SRC_RFE     : nxt_cpsr_gebits_ret_pre = rfe_data_wr_i[`CA53_PSR_ARCH_GE_BITS];
      `CA53_SEL_CPSR_SRC_INSTR1  : nxt_cpsr_gebits_ret_pre = geflags_wr_i;
      default                    : nxt_cpsr_gebits_ret_pre = 4'bxxxx;
    endcase

  // GE bits are zero in AArch64
  assign nxt_cpsr_gebits_ret = nxt_cpsr_gebits_ret_pre & {4{nxt_cpsr_modebits_ret[4]}};

  // ------------------------------------------------------
  // IT-bits update
  // ------------------------------------------------------

  assign sel_cpsr_itbits_wr = (psr_wr_src_wr[3:0] &
                               {4{(psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETIM)   |
                                  (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIM)  |
                                  (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIFM) |
                                  (psr_wr_en_wr == `CA53_SEL_CPSR_EN_SPSR)   |
                                  (psr_wr_en_wr == `CA53_SEL_CPSR_EN_IT)}});

  always @*
    case (sel_cpsr_itbits_wr)
      `CA53_SEL_CPSR_SRC_CPSR      : nxt_cpsr_itbits_ret_pre = force_itbits_wr[7:0];
      `CA53_SEL_CPSR_SRC_SPSR      : nxt_cpsr_itbits_ret_pre = {spsr_ret_reg[`CA53_SPSR_RET_IT_HICM_BITS],
                                                                spsr_ret_reg[`CA53_SPSR_RET_IT_LOW_BITS]} & {8{~in_halt_i}};
      `CA53_SEL_CPSR_SRC_DSPSR     : nxt_cpsr_itbits_ret_pre = {dspsr_ret_reg[`CA53_SPSR_RET_IT_HICM_BITS],
                                                                dspsr_ret_reg[`CA53_SPSR_RET_IT_LOW_BITS]};
      `CA53_SEL_CPSR_SRC_RFE       : nxt_cpsr_itbits_ret_pre = {rfe_data_wr_i[`CA53_PSR_ARCH_IT_HICM_BITS],
                                                                rfe_data_wr_i[`CA53_PSR_ARCH_IT_LOW_BITS]};
      `CA53_SEL_CPSR_SRC_FORCE     : nxt_cpsr_itbits_ret_pre = {8{1'b0}};
      default                      : nxt_cpsr_itbits_ret_pre = {8{1'bx}};
    endcase

  // The source IT state (from load data or the SPSR) is the _pre version.
  // This must be modified so that the IT state is zero if we are changing
  // into ARM state (IT is Thumb only) or if the value indicates that an IT
  // block has just completed execution (mask bits are 0000), or if the ITD
  // bit is set and the mask indicates more than one instruction (not x000)
  always @*
    case (prefix_cpsr_modebits_wr)
      `CA53_FULL_MODE_USR,
      `CA53_FULL_MODE_FIQ,
      `CA53_FULL_MODE_IRQ,
      `CA53_FULL_MODE_SVC,
      `CA53_FULL_MODE_ABT,
      `CA53_FULL_MODE_UND,
      `CA53_FULL_MODE_SYS:    nxt_sctlr_itd = (~aarch64_at_el_i[3] & ~nxt_ns_scr_i) ? sctlr_el3_itd_i : sctlr_el1_itd_i;

      `CA53_FULL_MODE_HYP:    nxt_sctlr_itd = sctlr_el2_itd_i;

      `CA53_FULL_MODE_MON:    nxt_sctlr_itd = sctlr_el3_itd_i;

      default:                nxt_sctlr_itd = 1'bx;
    endcase
  
  assign nxt_cpsr_itbits_ret = nxt_cpsr_itbits_ret_pre &
                               ~{8{illegal_mode_change_wr |
                                   ~nxt_cpsr_tbit_ret |
                                   (nxt_cpsr_itbits_ret_pre[3:0] == 4'b0000) |
                                   (nxt_sctlr_itd & (nxt_cpsr_itbits_ret_pre[2:0] != 3'b000) & (sel_cpsr_itbits_wr != `CA53_SEL_CPSR_SRC_CPSR)) | 
                                   (nxt_sctlr_itd & (nxt_cpsr_itbits_ret_pre[3:0] != 4'b0000) & cc_pass_instr0_wr_i & prefetch_flush_wr_i)}};

  // ------------------------------------------------------
  // E/D-bit update
  // ------------------------------------------------------
  // Bit [9] is the E bit in AArch32 and the D bit in AArch64

  assign ctlr_ed_bit = (~expt_cpsr_mode_ret_i[4])                                          ? 1'b1               :
                       (expt_cpsr_mode_ret_i == `CA53_FULL_MODE_HYP)                       ? sctlr_endian_el2_i :
                       (expt_cpsr_mode_ret_i == `CA53_FULL_MODE_MON)                       ? sctlr_endian_el3_i :
                       ((aarch64_at_el_i[3] & expt_cpsr_mode_ret_i[4]) | ns_state_i)       ? sctlr_endian_el1_i :
                                                                                             sctlr_endian_el3_i;

  assign sel_cpsr_edbit_wr = (psr_wr_src_wr[3:0] &
                              {4{ (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETIM)                                                   |
                                  (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIM)                                                  |
                                 ((psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIFM) & (~dbg_starting_i | ~expt_cpsr_mode_ret_i[4])) |
                                  (psr_wr_en_wr == `CA53_SEL_CPSR_EN_E)                                                      |
                                 ((psr_wr_en_wr == `CA53_SEL_CPSR_EN_SPSR))                                                  |
                                 ((psr_wr_en_wr[5:4] == 2'b10) & psr_wr_en_wr[3] & ~cpsr_ret_reg[4])                         |
                                 ((psr_wr_en_wr[5:4] == 2'b01) & psr_wr_en_wr[1])}});

  always @*
    case (sel_cpsr_edbit_wr)
      `CA53_SEL_CPSR_SRC_CPSR  : nxt_cpsr_edbit_ret = cpsr_ret_reg[`CA53_CPSR_RET_E_BITS];
      `CA53_SEL_CPSR_SRC_SPSR  : nxt_cpsr_edbit_ret = spsr_ret_reg[`CA53_SPSR_RET_E_BITS] | (in_halt_i & ~nxt_cpsr_modebits_ret[4]);
      `CA53_SEL_CPSR_SRC_DSPSR : nxt_cpsr_edbit_ret = dspsr_ret_reg[`CA53_SPSR_RET_E_BITS];
      `CA53_SEL_CPSR_SRC_DP    : nxt_cpsr_edbit_ret = alu0_fwd_data_early_wr_i[`CA53_PSR_ARCH_E_BITS];
      `CA53_SEL_CPSR_SRC_CPS   : nxt_cpsr_edbit_ret = force_ebit_wr;
      `CA53_SEL_CPSR_SRC_FORCE : nxt_cpsr_edbit_ret = ctlr_ed_bit;
      `CA53_SEL_CPSR_SRC_RFE   : nxt_cpsr_edbit_ret = rfe_data_wr_i[`CA53_PSR_ARCH_E_BITS];
      default                  : nxt_cpsr_edbit_ret = 1'bx;
    endcase

  // ------------------------------------------------------
  // A-bit update
  // ------------------------------------------------------

  // Exceptions into Hyp mode should not write A if SCR.EA is set
  assign ctlr_a_bit = (nxt_hyp_mode_ret & scr_ea_i) ? cpsr_ret_reg[`CA53_CPSR_RET_A_BITS] : 1'b1;

  assign sel_cpsr_abit_wr = psr_wr_src_wr[3:0] &
                            ({4{ (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIM)                           |
                                 (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIFM)                          |
                                 (psr_wr_en_wr == `CA53_SEL_CPSR_EN_SPSR)                            |
                                ((psr_wr_en_wr[5:4] == 2'b10) & psr_wr_en_wr[2])                     |
                                ((psr_wr_en_wr[5:4] == 2'b01) & psr_wr_en_wr[1] & priv_or_debug_ret)}});

  always @*
      case (sel_cpsr_abit_wr)
        `CA53_SEL_CPSR_SRC_CPSR  : nxt_cpsr_abit_ret = cpsr_ret_reg[`CA53_CPSR_RET_A_BITS];
        `CA53_SEL_CPSR_SRC_SPSR  : nxt_cpsr_abit_ret = spsr_ret_reg[`CA53_SPSR_RET_A_BITS] | in_halt_i;
        `CA53_SEL_CPSR_SRC_DSPSR : nxt_cpsr_abit_ret = dspsr_ret_reg[`CA53_SPSR_RET_A_BITS];
        `CA53_SEL_CPSR_SRC_DP    : nxt_cpsr_abit_ret = alu0_fwd_data_early_wr_i[`CA53_PSR_ARCH_A_BITS];
        `CA53_SEL_CPSR_SRC_FORCE : nxt_cpsr_abit_ret = ctlr_a_bit | in_halt_i;
        `CA53_SEL_CPSR_SRC_CPS   : nxt_cpsr_abit_ret = force_aifbits_wr;
        `CA53_SEL_CPSR_SRC_RFE   : nxt_cpsr_abit_ret = rfe_data_wr_i[`CA53_PSR_ARCH_A_BITS];
        default                  : nxt_cpsr_abit_ret = 1'bx;
      endcase

  // ------------------------------------------------------
  // I-bit update
  // ------------------------------------------------------

  // Exceptions into Hyp mode should not write I if SCR.IRQ is set
  assign ctlr_i_bit = (nxt_hyp_mode_ret & scr_irq_i) ? cpsr_ret_reg[`CA53_CPSR_RET_I_BITS] : 1'b1;

  assign sel_cpsr_ibit_wr = psr_wr_src_wr[3:0] &
                            ({4{ (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETIM)                            |
                                 (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIM)                           |
                                 (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIFM)                          |
                                 (psr_wr_en_wr == `CA53_SEL_CPSR_EN_SPSR)                            |
                                ((psr_wr_en_wr[5:4] == 2'b10) & psr_wr_en_wr[1])                     |
                                ((psr_wr_en_wr[5:4] == 2'b01) & psr_wr_en_wr[0] & priv_or_debug_ret)}});


  always @*
    case (sel_cpsr_ibit_wr)
      `CA53_SEL_CPSR_SRC_CPSR  : nxt_cpsr_ibit_ret = cpsr_ret_reg[`CA53_CPSR_RET_I_BITS];
      `CA53_SEL_CPSR_SRC_SPSR  : nxt_cpsr_ibit_ret = spsr_ret_reg[`CA53_SPSR_RET_I_BITS] | in_halt_i;
      `CA53_SEL_CPSR_SRC_DSPSR : nxt_cpsr_ibit_ret = dspsr_ret_reg[`CA53_SPSR_RET_I_BITS];
      `CA53_SEL_CPSR_SRC_DP    : nxt_cpsr_ibit_ret = alu0_fwd_data_early_wr_i[`CA53_PSR_ARCH_I_BITS];
      `CA53_SEL_CPSR_SRC_FORCE : nxt_cpsr_ibit_ret = ctlr_i_bit | in_halt_i;
      `CA53_SEL_CPSR_SRC_CPS   : nxt_cpsr_ibit_ret = force_aifbits_wr;
      `CA53_SEL_CPSR_SRC_RFE   : nxt_cpsr_ibit_ret = rfe_data_wr_i[`CA53_PSR_ARCH_I_BITS];
      default                  : nxt_cpsr_ibit_ret = 1'bx;
    endcase

  // ------------------------------------------------------
  // F-bit update
  // ------------------------------------------------------

  // Exceptions into Hyp mode should not write F if SCR.FIQ is set
  assign ctlr_f_bit = (nxt_hyp_mode_ret & scr_fiq_i) ? cpsr_ret_reg[`CA53_CPSR_RET_F_BITS] : 1'b1;

  assign sel_cpsr_fbit_wr = psr_wr_src_wr[3:0] &
                            ({4{ (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIFM)                           |
                                 (psr_wr_en_wr == `CA53_SEL_CPSR_EN_SPSR)                             |
                                ((psr_wr_en_wr[5:4] == 2'b10) & psr_wr_en_wr[0])                      |
                                ((psr_wr_en_wr[5:4] == 2'b01) & psr_wr_en_wr[0] & priv_or_debug_ret)}});

  always @*
      case (sel_cpsr_fbit_wr)
        `CA53_SEL_CPSR_SRC_CPSR  : nxt_cpsr_fbit_ret = cpsr_ret_reg[`CA53_CPSR_RET_F_BITS];
        `CA53_SEL_CPSR_SRC_SPSR  : nxt_cpsr_fbit_ret = spsr_ret_reg[`CA53_SPSR_RET_F_BITS] | in_halt_i;
        `CA53_SEL_CPSR_SRC_DSPSR : nxt_cpsr_fbit_ret = dspsr_ret_reg[`CA53_SPSR_RET_F_BITS];
        `CA53_SEL_CPSR_SRC_DP    : nxt_cpsr_fbit_ret = alu0_fwd_data_early_wr_i[`CA53_PSR_ARCH_F_BITS];
        `CA53_SEL_CPSR_SRC_FORCE : nxt_cpsr_fbit_ret = ctlr_f_bit | in_halt_i;
        `CA53_SEL_CPSR_SRC_CPS   : nxt_cpsr_fbit_ret = force_aifbits_wr;
        `CA53_SEL_CPSR_SRC_RFE   : nxt_cpsr_fbit_ret = rfe_data_wr_i[`CA53_PSR_ARCH_F_BITS];
        default                  : nxt_cpsr_fbit_ret = 1'bx;
      endcase

  // ------------------------------------------------------
  // T-bit update
  // ------------------------------------------------------

  assign blx_instr1_v_wr = slot1_blx_wr_i & valid_instrs_wr_i[1] & cc_pass_instr1_wr_i;
  assign bx_instr1_v_wr  = slot1_bx_wr_i  & valid_instrs_wr_i[1] & cc_pass_instr1_wr_i;

  // When in Hyp mode the t-bit must be read from HSCTLR register
  assign ctlr_te_bit = ~expt_cpsr_mode_ret_i[4]                       ? 1'b0          :
                       (expt_cpsr_mode_ret_i == `CA53_FULL_MODE_HYP)  ? hsctlr_te_i   :
                       (expt_cpsr_mode_ret_i == `CA53_FULL_MODE_MON)  ? sctlr_s_te_i  :
                       (aarch64_at_el_i[3] | ns_state_i)              ? sctlr_ns_te_i :
                                                                        sctlr_s_te_i;

  assign sel_cpsr_tbit_wr = bx_instr1_v_wr  ? `CA53_SEL_CPSR_SRC_LOAD_DATA  :
                            blx_instr1_v_wr ? `CA53_SEL_CPSR_SRC_BLX        :
                                              (psr_wr_src_wr[3:0] &
                                               ({4{ (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETIM)    |
                                                    (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIM)   |
                                                    (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIFM)  |
                                                    (psr_wr_en_wr == `CA53_SEL_CPSR_EN_T)       |
                                                   ((psr_wr_en_wr == `CA53_SEL_CPSR_EN_SPSR))}}));

  always @*
    case (sel_cpsr_tbit_wr)
      `CA53_SEL_CPSR_SRC_CPSR      : nxt_cpsr_tbit_ret_pre = cpsr_ret_reg[`CA53_CPSR_RET_T_BITS];
      `CA53_SEL_CPSR_SRC_SPSR      : nxt_cpsr_tbit_ret_pre = spsr_ret_reg[`CA53_SPSR_RET_T_BITS] | in_halt_i;
      `CA53_SEL_CPSR_SRC_DSPSR     : nxt_cpsr_tbit_ret_pre = dspsr_ret_reg[`CA53_SPSR_RET_T_BITS];
      `CA53_SEL_CPSR_SRC_DP        : nxt_cpsr_tbit_ret_pre = alu_tbit_wr;
      `CA53_SEL_CPSR_SRC_BLX       : nxt_cpsr_tbit_ret_pre = ~cpsr_ret_reg[`CA53_CPSR_RET_T_BITS];
      `CA53_SEL_CPSR_SRC_FORCE     : nxt_cpsr_tbit_ret_pre = ctlr_te_bit | in_halt_i;
      `CA53_SEL_CPSR_SRC_LOAD_DATA : nxt_cpsr_tbit_ret_pre = ld_t_bit_wr_i;
      `CA53_SEL_CPSR_SRC_RFE       : nxt_cpsr_tbit_ret_pre = rfe_data_wr_i[`CA53_PSR_ARCH_T_BITS];
      default                      : nxt_cpsr_tbit_ret_pre = 1'bx;
    endcase

  assign nxt_cpsr_tbit_ret = nxt_cpsr_tbit_ret_pre & nxt_cpsr_modebits_ret[4];

  // Generate a cut down version of the T-bit for the IFU that only includes the required signals
  assign cpsr_tbit_wr = (((psr_wr_src_wr == `CA53_SEL_CPSR_SRC_BLX) & cpsr_valid_wr & cc_pass_instr0_wr_i) | blx_instr1_v_wr) ?
                        ~cpsr_ret_reg[`CA53_CPSR_RET_T_BITS] : cpsr_ret_reg[`CA53_CPSR_RET_T_BITS];

  // ------------------------------------------------------
  // Mode-bits update
  // ------------------------------------------------------

  assign sel_cpsr_modebits_wr = psr_wr_src_wr[3:0] &
                                {4{ (psr_wr_en_wr == `CA53_SEL_CPSR_EN_M0)                              |
                                    (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETIM)                            |
                                    (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIM)                           |
                                    (psr_wr_en_wr == `CA53_SEL_CPSR_EN_ETAIFM)                          |
                                    (psr_wr_en_wr == `CA53_SEL_CPSR_EN_SPSR)                            |
                                   ((psr_wr_en_wr[5:4] == 2'b10) & psr_wr_en_wr[3] & cpsr_ret_reg[4])   |  // CPS instruction - only in AArch32
                                   ((psr_wr_en_wr[5:4] == 2'b01) & psr_wr_en_wr[0] & priv_or_debug_ret)    // MSR instruction (6'b01xxxC)
                                    }};
  always @*
    case (sel_cpsr_modebits_wr)
      `CA53_SEL_CPSR_SRC_CPSR  : prefix_cpsr_modebits_wr = cpsr_ret_reg[`CA53_CPSR_RET_MODE_BITS];
      `CA53_SEL_CPSR_SRC_SPSR  : prefix_cpsr_modebits_wr = spsr_ret_reg[`CA53_SPSR_RET_MODE_BITS];
      `CA53_SEL_CPSR_SRC_DSPSR : prefix_cpsr_modebits_wr = dspsr_ret_reg[`CA53_SPSR_RET_MODE_BITS];
      `CA53_SEL_CPSR_SRC_DP    : prefix_cpsr_modebits_wr = (psr_wr_en_wr == `CA53_SEL_CPSR_EN_M0) ? {cpsr_ret_reg[4:1], alu_mbits_wr[0]}
                                                                                                  : alu_mbits_wr;
      `CA53_SEL_CPSR_SRC_FORCE : prefix_cpsr_modebits_wr = expt_cpsr_mode_ret_i;
      `CA53_SEL_CPSR_SRC_CPS   : prefix_cpsr_modebits_wr = (psr_wr_en_wr == `CA53_SEL_CPSR_EN_M0) ? {cpsr_ret_reg[4:1], force_modebits_wr[0]}
                                                                                                  : force_modebits_wr;
      `CA53_SEL_CPSR_SRC_RFE   : prefix_cpsr_modebits_wr = rfe_data_wr_i[`CA53_PSR_ARCH_MODE_BITS];
      default                  : prefix_cpsr_modebits_wr = 5'bxxxxx;
    endcase

  // ------------------------------------------------------
  // Modefix
  // ------------------------------------------------------

  // Writeback stage modefix
  always @*
    case (prefix_cpsr_modebits_wr[4:0])
      // User mode always accessible, but illegal to do a debug exit from el0t -> user
      `CA53_FULL_MODE_USR    : illegal_target_mode_wr = (cpsr_ret_reg[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_EL0T);

      // AArch64 EL0 only available if higher exception levels are AArch64
      // Illegal to do a debug exit from user -> el0t
      `CA53_FULL_MODE_EL0T   : illegal_target_mode_wr = ~aarch64_at_el_i[1] | (cpsr_ret_reg[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_USR);

      // Register width must match that configured in SCR_EL3/HCR_EL2
      // Non-secure EL1 only available if HCR_EL2.TGE not set
      `CA53_FULL_MODE_FIQ,
      `CA53_FULL_MODE_IRQ,
      `CA53_FULL_MODE_SVC,
      `CA53_FULL_MODE_ABT,
      `CA53_FULL_MODE_UND,
      `CA53_FULL_MODE_SYS    : illegal_target_mode_wr =  aarch64_at_el_i[1] | (dpu_exception_level < `CA53_EL1) | (ns_scr_i & hcr_tge_i);

      `CA53_FULL_MODE_EL1T,
      `CA53_FULL_MODE_EL1H   : illegal_target_mode_wr = ~aarch64_at_el_i[1] | (dpu_exception_level < `CA53_EL1) | (ns_scr_i & hcr_tge_i);

      // Can only enter EL2 from EL2/3 or an exception
      // Register width must match SCR_EL3.RW
      // EL2 not available when SCR_EL3.NS = 0
      `CA53_FULL_MODE_HYP    : illegal_target_mode_wr = ~ns_scr_i |  aarch64_at_el_i[2] | (dpu_exception_level < `CA53_EL2) |
                                                        ((cpsr_ret_reg[`CA53_CPSR_RET_MODE_BITS] != `CA53_FULL_MODE_HYP) &
                                                         ((psr_wr_src_wr == `CA53_SEL_CPSR_SRC_DP) |   // Cannot enter Hyp mode from
                                                          (psr_wr_src_wr == `CA53_SEL_CPSR_SRC_CPS))); // Mon mode using CPS/MSR

      `CA53_FULL_MODE_EL2T,
      `CA53_FULL_MODE_EL2H   : illegal_target_mode_wr = ~ns_scr_i | ~aarch64_at_el_i[2] | (dpu_exception_level < `CA53_EL2);

      // Can only enter EL3 from EL3 or an exception
      // Register width must match EL3 register width
      `CA53_FULL_MODE_MON    : illegal_target_mode_wr =  aarch64_at_el_i[3] | (dpu_exception_level < `CA53_EL3);

      `CA53_FULL_MODE_EL3T,
      `CA53_FULL_MODE_EL3H   : illegal_target_mode_wr = ~aarch64_at_el_i[3] | (dpu_exception_level < `CA53_EL3);

      // Invalid encoding causes illegal exception return behaviour
      `CA53_FULL_MODE_NONUSE : illegal_target_mode_wr = 1'b1;
      default                : illegal_target_mode_wr = 1'bx;
    endcase

  // Attempting to leave Hyp mode without an exception or exception return
  // is illegal
  assign illegal_hyp_exit_wr = (cpsr_ret_reg[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_HYP) &
                               (prefix_cpsr_modebits_wr != `CA53_FULL_MODE_HYP) &
                               ~expt_rtn_wr & ~insert_forceop_ret_i;

  assign illegal_mode_change_wr = (illegal_target_mode_wr & ~(insert_forceop_ret_i & (psr_wr_src_wr != `CA53_SEL_CPSR_SRC_DSPSR))) | illegal_hyp_exit_wr;

  // Suppress the mode update if this is an illegal mode change
  assign nxt_cpsr_modebits_ret = illegal_mode_change_wr ? cpsr_ret_reg[`CA53_CPSR_RET_MODE_BITS]
                                                        : prefix_cpsr_modebits_wr;

  assign nxt_hyp_mode_ret = nxt_cpsr_modebits_ret == `CA53_FULL_MODE_HYP;

  always @*
    case (nxt_cpsr_modebits_ret)
      `CA53_FULL_MODE_USR,
      `CA53_FULL_MODE_EL0T: nxt_dpu_exception_level = `CA53_EL0;

      `CA53_FULL_MODE_FIQ,
      `CA53_FULL_MODE_IRQ,
      `CA53_FULL_MODE_SVC,
      `CA53_FULL_MODE_ABT,
      `CA53_FULL_MODE_UND,
      `CA53_FULL_MODE_SYS:  nxt_dpu_exception_level = (~aarch64_at_el_i[3] & ~nxt_ns_scr_i) ? `CA53_EL3 : `CA53_EL1;

      `CA53_FULL_MODE_EL1T,
      `CA53_FULL_MODE_EL1H: nxt_dpu_exception_level = `CA53_EL1;

      `CA53_FULL_MODE_HYP,
      `CA53_FULL_MODE_EL2T,
      `CA53_FULL_MODE_EL2H: nxt_dpu_exception_level = `CA53_EL2;

      `CA53_FULL_MODE_MON,
      `CA53_FULL_MODE_EL3T,
      `CA53_FULL_MODE_EL3H: nxt_dpu_exception_level = `CA53_EL3;

      default:              nxt_dpu_exception_level = 2'bxx;
    endcase

  assign dpu_exception_level_en = cpsr_regfile_en_wr | wr_scr_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      dpu_exception_level <= `CA53_EL3;
    else if (dpu_exception_level_en)
      dpu_exception_level <= nxt_dpu_exception_level;

  // ------------------------------------------------------
  // CPSR/SPSR register file write/read
  // ------------------------------------------------------

  // Note: CPS and SETEND inside an IT block are UNPREDICTABLE. For CortexA53
  // the UNPREDICTABLE behaviour is to execute these instructions
  // unconditionally - i.e. exactly as they would execute outside an IT
  // block. To do this, the condition code passed to the CC eval logic in the
  // ALU pipeline in the Ex2 stage is forced to AL for these two
  // instructions. The MUX that does this can be found in the ca53dpu_dec
  // module
  // CPSR update is masked when instruction is quashed during HALT mode.
  assign cpsr_regfile_en_wr = (((cpsr_valid_wr & (psr_wr_en_wr[5:4] != 2'b11))
                                   | it_cpsr_v_wr | (active_it_block_wr & (end_instr_wr_i | expt_slot1_wr_i | br_flush_wr_i))
                                   | (cpsr_ret_reg[`CA53_CPSR_RET_SS_BITS] & end_instr_wr_i)) &
                                  valid_instrs_wr_i[0] &
                                  (~quash_slot0_wr_i &
                                   ~stall_wr_i &
                                   // If a valid IT or IT block instruction in the wr stage of the
                                   // CPSR, then even if it fails its ccodes, we need to update the
                                   // CPSR to update the rolling value of the it bits.
                                   // The fact that the IT instruction has failed its ccodes means
                                   // that the RF write will not happen.
                                   (active_it_block_wr | cpsr_ret_reg[`CA53_CPSR_RET_SS_BITS] | cc_pass_instr0_wr_i)))          |
                                 // updates due to instr1 can use normal quash
                                 (blx_instr1_v_wr & ~stall_wr_i & ~quash_wr_i)                                                  |
                                 (bx_instr1_v_wr & ~stall_wr_i & ~quash_wr_i)                                                   |
                                 ((flag_en_instr1_wr_i != `CA53_FLAGEN_INSTR1_NONE) & ~stall_wr_i & ~quash_wr_i & ~br_flush_wr_i) |
                                 (insert_forceop_ret_i & (psr_wr_en_wr != `CA53_SEL_CPSR_EN_NULL));

  // Early SPSR register file write enable for regional gating
  assign sel_spsr_ex2 = ((psr_wr_en_ex2[5:4] == 2'b11)              |
                         (psr_wr_en_ex2 == `CA53_SEL_CPSR_EN_ETIM)  |
                         (psr_wr_en_ex2 == `CA53_SEL_CPSR_EN_ETAIM) |
                         (psr_wr_en_ex2 == `CA53_SEL_CPSR_EN_ETAIFM)) ? psr_wr_src_ex2[3:0] : `CA53_SEL_CPSR_SRC_SPSR;

  assign spsr_clock_en_ex2 = insert_forceop_wr_i | (cpsr_valid_ex2 & (sel_spsr_ex2 != `CA53_SEL_CPSR_SRC_SPSR));

  // SPSR register file write enable final control
  assign spsr_regfile_en_wr = (cpsr_valid_wr & cc_pass_instr0_wr_i & (sel_spsr_wr != `CA53_SEL_CPSR_SRC_SPSR) & ~quash_wr_i) |
                              (insert_forceop_ret_i & ~in_halt_i & (psr_wr_en_wr != `CA53_SEL_CPSR_EN_NULL));

  assign dspsr_regfile_en_wr = (dbg_starting_i & insert_forceop_ret_i) | cp14_wr_dspsr_i;
  assign nxt_dspsr_ret       = cp14_wr_dspsr_i ? {mcr_data_wr_i[31:25], mcr_data_wr_i[21:0]} : cpsr_ret_reg;

  // CPSR SPSR and DSPSR register bank
  ca53dpu_psr_regfile u_psr_rf (
    // Inputs
    .clk                      (clk),
    .reset_n                  (reset_n),
    .DFTSE                    (DFTSE),
    .spsr_regfile_en_wr_i     (spsr_regfile_en_wr),
    .cpsr_regfile_en_wr_i     (cpsr_regfile_en_wr),
    .dspsr_regfile_en_wr_i    (dspsr_regfile_en_wr),
    .spsr_regfile_mask_wr_i   (spsr_mask_wr[3:0]),
    .spsr_clock_en_ex2_i      (spsr_clock_en_ex2),
    .insert_forceop_ret_i     (insert_forceop_ret_i),
    .in_halt_i                (in_halt_i),
    .msr_mrs_data_wr_i        (msr_mrs_data_wr_i[3:0]),
    .nxt_spsr_ret_i           (nxt_spsr_ret[(`CA53_SPSR_RET_W-1):0]),
    .nxt_cpsr_ret_i           (nxt_cpsr_ret[(`CA53_CPSR_RET_W-1):0]),
    .nxt_dspsr_ret_i          (nxt_dspsr_ret[(`CA53_CPSR_RET_W-1):0]),
    // Outputs
    .spsr_ret_reg_o           (spsr_ret_reg[(`CA53_SPSR_RET_W-1):0]),
    .cpsr_ret_reg_o           (cpsr_ret_reg[(`CA53_CPSR_RET_W-1):0]),
    .dspsr_ret_reg_o          (dspsr_ret_reg[(`CA53_CPSR_RET_W-1):0])
  );

  // CPSR value passed to IFU for ret-stage forces
  assign dpu_fe_isa_ret_o[1]        = ~cpsr_ret_reg[4];
  assign dpu_fe_isa_ret_o[0]        = cpsr_ret_reg[`CA53_CPSR_RET_T_BITS];
  assign dpu_fe_itstate_ret_o[7:4]  = cpsr_ret_reg[`CA53_CPSR_RET_IT_COND_BITS];
  assign dpu_fe_itstate_ret_o[3:0]  = {cpsr_ret_reg[`CA53_CPSR_RET_IT_HIGH_BITS], cpsr_ret_reg[`CA53_CPSR_RET_IT_LOW_BITS]};

  // The ARM ARM states that the execution state bits must be read as zero
  // unless in halting debug mode.  The execution state bits in this context
  // are {T,J, IT_COND, IT_MASK, IL}.

  // Mask out execution state bits
  assign cpsr_read_mask = {5'b1111_1,   // 31:27
                           3'b00_0,     // Mask out IT[1:0] & J-bit [26:24]
                           2'b11,       // [23:22]
                           1'b0,        // Mask out SS
                           1'b0,        // Mask out IL
                           4'b1111,     // [19:16]
                           6'b000000,   // Mask out IT[7:2]
                           4'b1111,     // [9:6]
                           1'b0,        // Mask out T-bit [5]
                           5'b11111};   // [4:0]

  // Indicate if a ret-stage force should align the PC value
  // Don't align if this is an interworking branch, or if this is a branch in
  // AArch64 (unless a return to AArch32 was attempted)
  assign branch_align_pc_wr_o = (psr_wr_src_wr != `CA53_SEL_CPSR_SRC_LOAD_DATA) & ~bx_instr1_v_wr &
                                ~(~cpsr_ret_reg[4] & ~prefix_cpsr_modebits_wr[4]);

  // Indicate if a debug state exit is to AArch32 and should zero the top
  // 32 bits of the PC
  assign debug_exit_aa32_o = insert_forceop_ret_i & (psr_wr_src_wr == `CA53_SEL_CPSR_SRC_DSPSR) & (dspsr_ret_reg[4] | cpsr_ret_reg[4]);

  // ------------------------------------------------------
  // Exception return indicator
  // ------------------------------------------------------
  //
  // The exception return signal is used to set the event register and
  // inside the performance monitors.  It needs to be set precisely which
  // can be interesting due to the lateness of some of the signals.
  assign expt_rtn_wr = ((psr_wr_src_wr == `CA53_SEL_CPSR_SRC_SPSR) |
                        (psr_wr_src_wr == `CA53_SEL_CPSR_SRC_RFE)) & cpsr_valid_wr & valid_instrs_wr_i[0];

  assign nxt_expt_rtn_ret = expt_rtn_wr & cc_pass_instr0_wr_i & ~stall_wr_i & ~quash_wr_i;

  always @(posedge clk_psr_ctl)
    expt_rtn_ret <= nxt_expt_rtn_ret;

  // ------------------------------------------------------
  // Output signal alias
  // ------------------------------------------------------

  assign psr_cp_rd_data_o = ({32{raw_cp_decode_wr_i == {1'b0, `CA53_CRN4_SPSEL} }}     & { {31{1'b0}}, cpsr_ret_reg[0]})                                    |
                            ({32{raw_cp_decode_wr_i == {1'b0, `CA53_CRN4_DAIF} }}      & { {22{1'b0}}, cpsr_ret_reg[`CA53_CPSR_RET_EAIF_BITS], {6{1'b0}} }) |
                            ({32{raw_cp_decode_wr_i == {1'b0, `CA53_CRN4_CURRENTEL} }} & { {28{1'b0}}, cpsr_ret_reg[3:2], 2'b00})                           |
                            ({32{raw_cp_decode_wr_i == {1'b0, `CA53_CRN4_NZCV} }}      & { cpsr_ret_reg[`CA53_CPSR_RET_NZCV_BITS], {28{1'b0}} });


  // 32bit format of CPSR
  assign cpsr_ret_full             = {cpsr_ret_reg[`CA53_CPSR_RET_NZCVQ_BITS],    // {N,Z,C,V,Q flags}
                                      cpsr_ret_reg[`CA53_CPSR_RET_IT_LOW_BITS],   // IT[1:0]
                                      1'b0,                                       // J
                                      2'b00,                                      // Reserved
                                      cpsr_ret_reg[`CA53_CPSR_RET_SS_BITS],       // SS
                                      cpsr_ret_reg[`CA53_CPSR_RET_IL_BITS],       // IL
                                      cpsr_ret_reg[`CA53_CPSR_RET_GE_BITS],       // GE[3:0]
                                      cpsr_ret_reg[`CA53_CPSR_RET_IT_COND_BITS],  // IT cond
                                      cpsr_ret_reg[`CA53_CPSR_RET_IT_HIGH_BITS],  // IT Mask high
                                      cpsr_ret_reg[`CA53_CPSR_RET_EAIF_BITS],     // E,A,I,F
                                      cpsr_ret_reg[`CA53_CPSR_RET_T_BITS],        // T
                                      cpsr_ret_reg[`CA53_CPSR_RET_MODE_BITS]};    // Mode
  assign cpsr_ret_o                = cpsr_ret_full;
  assign dpu_fe_isa_wr_o           = {~cpsr_ret_reg[4], // AArch64
                                      cpsr_tbit_wr};    // T-bit
  assign spec_cpsr_mode_iss_o      = spec_cpsr_mode_iss;
  assign spec_cpsr_mode_usr_iss_o  = spec_cpsr_mode_usr_iss;
  assign spec_cpsr_mode_sys_iss_o  = spec_cpsr_mode_sys_iss;
  assign spec_cpsr_mode_mon_iss_o  = spec_cpsr_mode_mon_iss;
  assign spec_cpsr_mode_hyp_iss_o  = spec_cpsr_mode_hyp_iss;
  assign cpsr_tbit_wr_o            = cpsr_tbit_wr;
  assign nxt_cpsr_tbit_ret_pre_o   = nxt_cpsr_tbit_ret_pre;
  assign isa_switch_br_ex2_o       = ((psr_wr_src_ex2 == `CA53_SEL_CPSR_SRC_BLX) & cpsr_valid_ex2) | slot1_blx_ex2_i;
  assign expt_rtn_wr_o             = expt_rtn_wr;
  assign expt_rtn_ret_o            = expt_rtn_ret;
  assign cpsr_ssbit_ret_o          = cpsr_ret_full[`CA53_PSR_ARCH_SS_BITS];
  assign cpsr_ilbit_ret_o          = cpsr_ret_full[`CA53_PSR_ARCH_IL_BITS];
  assign cpsr_tbit_ret_o           = cpsr_ret_full[`CA53_PSR_ARCH_T_BITS];
  assign cpsr_ibit_ret_o           = cpsr_ret_full[`CA53_PSR_ARCH_I_BITS];
  assign cpsr_fbit_ret_o           = cpsr_ret_full[`CA53_PSR_ARCH_F_BITS];
  assign cpsr_abit_ret_o           = cpsr_ret_full[`CA53_PSR_ARCH_A_BITS];
  assign cpsr_dbit_ret_o           = cpsr_ret_full[`CA53_PSR_ARCH_D_BITS] & ~cpsr_ret_reg[4]; // D bit is only present in AArch64
  assign spsr_ret_full             = {spsr_ret_reg[`CA53_SPSR_RET_NZCVQ_BITS],  // {N,Z,C,V,Q flags}
                                      spsr_ret_reg[`CA53_SPSR_RET_IT_LOW_BITS], // IT[1:0]
                                      1'b0,                                     // J
                                      2'b00,                                    // Reserved
                                      spsr_ret_reg[`CA53_SPSR_RET_SS_BITS],     // SS
                                      spsr_ret_reg[`CA53_SPSR_RET_IL_BITS],     // IL
                                      spsr_ret_reg[`CA53_SPSR_RET_GE_BITS],     // GE[3:0]
                                      spsr_ret_reg[`CA53_SPSR_RET_IT_HICM_BITS],// IT[7:2]
                                      spsr_ret_reg[`CA53_SPSR_RET_EAIF_BITS],   // E,A,I,F
                                      spsr_ret_reg[`CA53_SPSR_RET_T_BITS],      // T
                                      spsr_ret_reg[`CA53_SPSR_RET_MODE_BITS]};  // Mode[4:0]
  assign spsr_ret_o                = spsr_ret_full;
  assign nxt_mon_el3_mode_ret_o    = (nxt_cpsr_modebits_ret == `CA53_FULL_MODE_MON) |
                                     (nxt_cpsr_modebits_ret == `CA53_FULL_MODE_EL3H) |
                                     (nxt_cpsr_modebits_ret == `CA53_FULL_MODE_EL3T);
  assign dpu_exception_level_o     = dpu_exception_level;
  assign cpsr_masked_ret_o         = cpsr_ret_full & cpsr_read_mask;
  assign dspsr_reg_o               = dspsr_ret_reg;

  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_cpsr_pipeline")
  u_ovl_x_advance_cpsr_pipeline (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (advance_cpsr_pipeline));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_pipeline_i")
  u_ovl_x_advance_pipeline_i (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (advance_pipeline_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cpsr_regfile_en_wr")
  u_ovl_x_cpsr_regfile_en_wr (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (cpsr_regfile_en_wr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cpsr_valid_iss_en")
  u_ovl_x_cpsr_valid_iss_en (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (cpsr_valid_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dpu_exception_level_en")
  u_ovl_x_dpu_exception_level_en (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (dpu_exception_level_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: it_cpsr_mask_ex1_en")
  u_ovl_x_it_cpsr_mask_ex1_en (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (it_cpsr_mask_ex1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: it_cpsr_mask_ex2_en")
  u_ovl_x_it_cpsr_mask_ex2_en (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (it_cpsr_mask_ex2_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: it_cpsr_mask_iss_en")
  u_ovl_x_it_cpsr_mask_iss_en (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (it_cpsr_mask_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: it_cpsr_mask_wr_en")
  u_ovl_x_it_cpsr_mask_wr_en (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (it_cpsr_mask_wr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: nxt_cpsr_valid_ex1")
  u_ovl_x_nxt_cpsr_valid_ex1 (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (nxt_cpsr_valid_ex1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: nxt_cpsr_valid_ex2")
  u_ovl_x_nxt_cpsr_valid_ex2 (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (nxt_cpsr_valid_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: nxt_cpsr_valid_iss")
  u_ovl_x_nxt_cpsr_valid_iss (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (nxt_cpsr_valid_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: nxt_cpsr_valid_wr")
  u_ovl_x_nxt_cpsr_valid_wr (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (nxt_cpsr_valid_wr));


  // -----------------------------------------------------------------
  // OVL_ASSERT: Checks for illegal CPSR select of the NZCV Flag-bits
  // -----------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Illegal select for CPSR NZCV bits")
    ovl_illegal_cpsr_select_nzcvbits (.clk       (clk),
                                      .reset_n   (reset_n),
                                      .test_expr ((sel_cpsr_nzcvbits_wr == `CA53_SEL_CPSR_SRC_CPSR)    |
                                                  (sel_cpsr_nzcvbits_wr == `CA53_SEL_CPSR_SRC_SPSR)    |
                                                  (sel_cpsr_nzcvbits_wr == `CA53_SEL_CPSR_SRC_DSPSR)   |
                                                  (sel_cpsr_nzcvbits_wr == `CA53_SEL_CPSR_SRC_DP)      |
                                                  (sel_cpsr_nzcvbits_wr == `CA53_SEL_CPSR_SRC_CCFLAGS) |
                                                  (sel_cpsr_nzcvbits_wr == `CA53_SEL_CPSR_SRC_RFE)     |
                                                  (sel_cpsr_nzcvbits_wr == `CA53_SEL_CPSR_SRC_DSCR)    |
                                                  (sel_cpsr_nzcvbits_wr == `CA53_SEL_CPSR_SRC_INSTR1)));
  // OVL_ASSERT_END

  // ----------------------------------------------------------
  // OVL_ASSERT: Checks for illegal CPSR select of the Q bit
  // ----------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Illegal select for CPSR Q bit")
    ovl_illegal_cpsr_select_qbit (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .test_expr ((sel_cpsr_qbits_wr == `CA53_SEL_CPSR_SRC_CPSR)  |
                                              (sel_cpsr_qbits_wr == `CA53_SEL_CPSR_SRC_SPSR)  |
                                              (sel_cpsr_qbits_wr == `CA53_SEL_CPSR_SRC_DSPSR) |
                                              (sel_cpsr_qbits_wr == `CA53_SEL_CPSR_SRC_MUL)   |
                                              (sel_cpsr_qbits_wr == `CA53_SEL_CPSR_SRC_DP)    |
                                              (sel_cpsr_qbits_wr == `CA53_SEL_CPSR_SRC_QFLAG) |
                                              (sel_cpsr_qbits_wr == `CA53_SEL_CPSR_SRC_RFE)   |
                                              (sel_cpsr_qbits_wr == `CA53_SEL_CPSR_SRC_INSTR1)));
  // OVL_ASSERT_END

  // ----------------------------------------------------------
  // OVL_ASSERT: Checks for illegal CPSR select of the SS bit
  // ----------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Illegal select for CPSR SS bit")
    ovl_illegal_cpsr_select_ssbit (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .test_expr ((sel_cpsr_ssbit_wr == `CA53_SEL_CPSR_SRC_CPSR)    |
                                               (sel_cpsr_ssbit_wr == `CA53_SEL_CPSR_SRC_SPSR)    |
                                               (sel_cpsr_ssbit_wr == `CA53_SEL_CPSR_SRC_DSPSR)   |
                                               (sel_cpsr_ssbit_wr == `CA53_SEL_CPSR_SRC_RFE)     |
                                               (sel_cpsr_ssbit_wr == `CA53_SEL_CPSR_SRC_FORCE)));
  // OVL_ASSERT_END

  // ----------------------------------------------------------
  // OVL_ASSERT: Checks for illegal CPSR select of the IL bit
  // ----------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Illegal select for CPSR IL bit")
    ovl_illegal_cpsr_select_ilbit (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .test_expr ((sel_cpsr_ilbit_wr == `CA53_SEL_CPSR_SRC_CPSR)    |
                                               (sel_cpsr_ilbit_wr == `CA53_SEL_CPSR_SRC_SPSR)    |
                                               (sel_cpsr_ilbit_wr == `CA53_SEL_CPSR_SRC_DSPSR)   |
                                               (sel_cpsr_ilbit_wr == `CA53_SEL_CPSR_SRC_RFE)     |
                                               (sel_cpsr_ilbit_wr == `CA53_SEL_CPSR_SRC_FORCE)));
  // OVL_ASSERT_END

  // ----------------------------------------------------------
  // OVL_ASSERT: Checks for illegal CPSR select of the GE bits
  // ----------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Illegal select for CPSR GE bits")
    ovl_illegal_cpsr_select_gebits (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .test_expr ((sel_cpsr_gebits_wr == `CA53_SEL_CPSR_SRC_CPSR)    |
                                                (sel_cpsr_gebits_wr == `CA53_SEL_CPSR_SRC_SPSR)    |
                                                (sel_cpsr_gebits_wr == `CA53_SEL_CPSR_SRC_DSPSR)   |
                                                (sel_cpsr_gebits_wr == `CA53_SEL_CPSR_SRC_DP)      |
                                                (sel_cpsr_gebits_wr == `CA53_SEL_CPSR_SRC_CCFLAGS) |
                                                (sel_cpsr_gebits_wr == `CA53_SEL_CPSR_SRC_RFE)     |
                                                (sel_cpsr_gebits_wr == `CA53_SEL_CPSR_SRC_INSTR1)));
  // OVL_ASSERT_END

  // ----------------------------------------------------------
  // OVL_ASSERT: Checks for illegal CPSR select of the IT bits
  // ----------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Illegal select for CPSR IT bits")
    ovl_illegal_cpsr_select_itbits (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .test_expr ((sel_cpsr_itbits_wr == `CA53_SEL_CPSR_SRC_CPSR)  |
                                                (sel_cpsr_itbits_wr == `CA53_SEL_CPSR_SRC_SPSR)  |
                                                (sel_cpsr_itbits_wr == `CA53_SEL_CPSR_SRC_DSPSR) |
                                                (sel_cpsr_itbits_wr == `CA53_SEL_CPSR_SRC_DP)    |
                                                (sel_cpsr_itbits_wr == `CA53_SEL_CPSR_SRC_RFE)   |
                                                (sel_cpsr_itbits_wr == `CA53_SEL_CPSR_SRC_BLX)   |
                                                (sel_cpsr_itbits_wr == `CA53_SEL_CPSR_SRC_FORCE) |
                                                (sel_cpsr_itbits_wr == `CA53_SEL_CPSR_SRC_LOAD_DATA)));
  // OVL_ASSERT_END

  // ----------------------------------------------------------
  // OVL_ASSERT: Checks for illegal CPSR select of E/D bit
  // ----------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Illegal select for CPSR E/D bit")
    ovl_illegal_cpsr_select_edbit (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .test_expr ((sel_cpsr_edbit_wr == `CA53_SEL_CPSR_SRC_CPSR)  |
                                               (sel_cpsr_edbit_wr == `CA53_SEL_CPSR_SRC_SPSR)  |
                                               (sel_cpsr_edbit_wr == `CA53_SEL_CPSR_SRC_DSPSR) |
                                               (sel_cpsr_edbit_wr == `CA53_SEL_CPSR_SRC_DP)    |
                                               (sel_cpsr_edbit_wr == `CA53_SEL_CPSR_SRC_CPS)   |
                                               (sel_cpsr_edbit_wr == `CA53_SEL_CPSR_SRC_FORCE) |
                                               (sel_cpsr_edbit_wr == `CA53_SEL_CPSR_SRC_RFE)));
  // OVL_ASSERT_END

  // ----------------------------------------------------------
  // OVL_ASSERT: Checks for illegal CPSR select of the A bit
  // ---------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Illegal select for CPSR A bit")
    ovl_illegal_cpsr_select_abit (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .test_expr ((sel_cpsr_abit_wr == `CA53_SEL_CPSR_SRC_CPSR)  |
                                              (sel_cpsr_abit_wr == `CA53_SEL_CPSR_SRC_SPSR)  |
                                              (sel_cpsr_abit_wr == `CA53_SEL_CPSR_SRC_DSPSR) |
                                              (sel_cpsr_abit_wr == `CA53_SEL_CPSR_SRC_DP)    |
                                              (sel_cpsr_abit_wr == `CA53_SEL_CPSR_SRC_FORCE) |
                                              (sel_cpsr_abit_wr == `CA53_SEL_CPSR_SRC_CPS)   |
                                              (sel_cpsr_abit_wr == `CA53_SEL_CPSR_SRC_RFE)));
  // OVL_ASSERT_END

  // ----------------------------------------------------------
  // OVL_ASSERT: Checks for illegal CPSR select of the I bit
  // ----------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Illegal select for CPSR I bit")
    ovl_illegal_cpsr_select_ibit (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .test_expr ((sel_cpsr_ibit_wr == `CA53_SEL_CPSR_SRC_CPSR)  |
                                              (sel_cpsr_ibit_wr == `CA53_SEL_CPSR_SRC_SPSR)  |
                                              (sel_cpsr_ibit_wr == `CA53_SEL_CPSR_SRC_DSPSR) |
                                              (sel_cpsr_ibit_wr == `CA53_SEL_CPSR_SRC_DP)    |
                                              (sel_cpsr_ibit_wr == `CA53_SEL_CPSR_SRC_FORCE) |
                                              (sel_cpsr_ibit_wr == `CA53_SEL_CPSR_SRC_CPS)   |
                                              (sel_cpsr_ibit_wr == `CA53_SEL_CPSR_SRC_RFE)));
  // OVL_ASSERT_END

  // ----------------------------------------------------------
  // OVL_ASSERT: Checks for illegal CPSR select of the F bit
  // ----------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Illegal select for CPSR F bit")
    ovl_illegal_cpsr_select_fbit (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .test_expr ((sel_cpsr_fbit_wr == `CA53_SEL_CPSR_SRC_CPSR)  |
                                              (sel_cpsr_fbit_wr == `CA53_SEL_CPSR_SRC_SPSR)  |
                                              (sel_cpsr_fbit_wr == `CA53_SEL_CPSR_SRC_DSPSR) |
                                              (sel_cpsr_fbit_wr == `CA53_SEL_CPSR_SRC_DP)    |
                                              (sel_cpsr_fbit_wr == `CA53_SEL_CPSR_SRC_FORCE) |
                                              (sel_cpsr_fbit_wr == `CA53_SEL_CPSR_SRC_CPS)   |
                                              (sel_cpsr_fbit_wr == `CA53_SEL_CPSR_SRC_RFE)));
  // OVL_ASSERT_END

  // ----------------------------------------------------------
  // OVL_ASSERT: Checks for illegal CPSR select of the T bit
  // ----------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Illegal select for CPSR T bit")
    ovl_illegal_cpsr_select_tbit (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .test_expr ((sel_cpsr_tbit_wr == `CA53_SEL_CPSR_SRC_CPSR)      |
                                              (sel_cpsr_tbit_wr == `CA53_SEL_CPSR_SRC_SPSR)      |
                                              (sel_cpsr_tbit_wr == `CA53_SEL_CPSR_SRC_DSPSR)     |
                                              (sel_cpsr_tbit_wr == `CA53_SEL_CPSR_SRC_DP)        |
                                              (sel_cpsr_tbit_wr == `CA53_SEL_CPSR_SRC_BLX)       |
                                              (sel_cpsr_tbit_wr == `CA53_SEL_CPSR_SRC_FORCE)     |
                                              (sel_cpsr_tbit_wr == `CA53_SEL_CPSR_SRC_LOAD_DATA) |
                                              (sel_cpsr_tbit_wr == `CA53_SEL_CPSR_SRC_RFE)       |
                                              (sel_cpsr_tbit_wr == `CA53_SEL_CPSR_SRC_INSTR1)));
  // OVL_ASSERT_END

  // ----------------------------------------------------------
  // OVL_ASSERT: Checks for illegal CPSR select of the mode bits
  // ----------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Illegal select for CPSR MODE bits")
    ovl_illegal_cpsr_select_modebits (.clk       (clk),
                                      .reset_n   (reset_n),
                                      .test_expr ((sel_cpsr_modebits_wr == `CA53_SEL_CPSR_SRC_CPSR)  |
                                                  (sel_cpsr_modebits_wr == `CA53_SEL_CPSR_SRC_SPSR)  |
                                                  (sel_cpsr_modebits_wr == `CA53_SEL_CPSR_SRC_DSPSR) |
                                                  (sel_cpsr_modebits_wr == `CA53_SEL_CPSR_SRC_DP)    |
                                                  (sel_cpsr_modebits_wr == `CA53_SEL_CPSR_SRC_FORCE) |
                                                  (sel_cpsr_modebits_wr == `CA53_SEL_CPSR_SRC_CPS)   |
                                                  (sel_cpsr_modebits_wr == `CA53_SEL_CPSR_SRC_RFE)));
  // OVL_ASSERT_END

  // ----------------------------------------------------------
  // OVL_ASSERT: Checks for illegal SPSR select
  // ----------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Illegal select for SPSR")
    ovl_illegal_spsr_select (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr ((sel_spsr_wr == `CA53_SEL_CPSR_SRC_SPSR)  |
                                         (sel_spsr_wr == `CA53_SEL_CPSR_SRC_CPSR)  |
                                         (sel_spsr_wr == `CA53_SEL_CPSR_SRC_DSPSR) |
                                         (sel_spsr_wr == `CA53_SEL_CPSR_SRC_FORCE) |
                                         (sel_spsr_wr == `CA53_SEL_CPSR_SRC_DP)));
  // OVL_ASSERT_END

`endif

endmodule // ca53dpu_cpsr

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
