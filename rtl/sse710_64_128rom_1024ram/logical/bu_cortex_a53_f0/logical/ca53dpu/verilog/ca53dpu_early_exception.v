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
// Abstract : Initial detection and routing of instruction exceptions in Iss
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_early_exception (
  // Inputs
  input  wire                               clk,
  input  wire                               reset_n,
  input  wire                               DFTSE,
  input  wire                               aarch64_state_i,
  input  wire                               ns_state_i,
  input  wire                         [1:0] dpu_exception_level_i,
  input  wire  [`CA53_EXPT_INSTR_BUS_W-1:0] expt_instr_data_de_i,
  input  wire [`CA53_EXPT_INSTR_TYPE_W-1:0] expt_instr_type_de_i,
  input  wire                               early_expt_enable_de_i,
  input  wire                         [1:0] expt_cpacr_el1_fpen_i,
  input  wire                               expt_cpacr_asedis_i,
  input  wire                               expt_cptr_el2_tfp_i,
  input  wire                               expt_hcptr_tase_i,
  input  wire                               expt_cptr_el2_tcpac_i,
  input  wire                               flush_ret_i,
  input  wire                               instr_size_ex1_i,
  input  wire                         [3:0] cond_code_instr0_ex1_i,
  input  wire                               stall_iss_i,
  input  wire                               ilock_stall_iss_i,
  input  wire                               stall_wr_i,
  input  wire                               exception_valid_ex1_i,
  input  wire                               exception_valid_ex2_i,
  input  wire                               valid_instrs_de_i,
  input  wire                               valid_iss_en_i,
  input  wire                               quash_de_i,
  input  wire                               head_instr0_iss_i,
  input  wire                         [6:0] ifu_ifsr_i,
  input  wire                         [1:0] ifu_ifsr_stage2_i,
  input  wire                         [3:1] aarch64_at_el_i,
  input  wire                         [4:0] cpsr_mode_ret_i,
  input  wire                               cpsr_ilbit_ret_i,
  input  wire                               in_halt_i,
  input  wire                               dbg_hlt_en_i,
  input  wire                               dbg_bkpt_wpt_en_i,
  input  wire                               dbg_halting_allowed_i,
  input  wire                               dbg_os_lock_synced_i,
  input  wire                               dbg_double_lock_set_i,
  input  wire                         [3:0] pmn_useren_i,
  input  wire                               mdscr_el1_tdcc_i,
  input  wire                               hdcr_tdra_i,
  input  wire                               hdcr_tdosa_i,
  input  wire                               hdcr_tda_i,
  input  wire                               hdcr_tde_i,
  input  wire                               hdcr_tpm_i,
  input  wire                               hdcr_tpmcr_i,
  input  wire                               mdcr_el3_tdosa_i,
  input  wire                               mdcr_el3_tda_i,
  input  wire                               mdcr_el3_tpm_i,
  input  wire                               hcr_trvm_i,
  input  wire                               hcr_tdz_i,
  input  wire                               hcr_tge_i,
  input  wire                               hcr_tvm_i,
  input  wire                               hcr_ttlb_i,
  input  wire                               hcr_tpu_i,
  input  wire                               hcr_tpc_i,
  input  wire                               hcr_tsw_i,
  input  wire                               hcr_tacr_i,
  input  wire                               hcr_tidcp_i,
  input  wire                               hcr_tsc_i,
  input  wire                               hcr_tid3_i,
  input  wire                               hcr_tid2_i,
  input  wire                               hcr_tid1_i,
  input  wire                               hcr_tid0_i,
  input  wire                               hcr_twe_i,
  input  wire                               hcr_twi_i,
  input  wire                               hcr_amo_i,
  input  wire                               hcr_imo_i,
  input  wire                               hcr_fmo_i,
  input  wire                        [13:0] hstr_trap_i,
  input  wire                               cpuactlr_el3_i,
  input  wire                               cpuectlr_el3_i,
  input  wire                               l2ctlr_el3_i,
  input  wire                               l2ectlr_el3_i,
  input  wire                               l2actlr_el3_i,
  input  wire                               cpuactlr_el2_i,
  input  wire                               cpuectlr_el2_i,
  input  wire                               l2ctlr_el2_i,
  input  wire                               l2ectlr_el2_i,
  input  wire                               l2actlr_el2_i,
  input  wire                               cptr_el3_tcpac_i,
  input  wire                               cptr_el3_tfp_i,
  input  wire                               cp_fpexc_en_i,
  input  wire                               sctlr_ntwe_i,
  input  wire                               sctlr_ntwi_i,
  input  wire                               sctlr_cp15ben_i,
  input  wire                               sctlr_sed_i,
  input  wire                               sctlr_el1_uci_i,
  input  wire                               sctlr_el1_uct_i,
  input  wire                               sctlr_el1_uma_i,
  input  wire                               sctlr_el1_dze_i,
  input  wire                               scr_el3_twi_i,
  input  wire                               scr_el3_twe_i,
  input  wire                               scr_el3_st_i,
  input  wire                               scr_el3_hce_i,
  input  wire                               scr_el3_smd_i,
  input  wire                               scr_el3_ea_i,
  input  wire                               scr_el3_irq_i,
  input  wire                               scr_el3_fiq_i,
  input  wire                               edscr_sdd_i,
  input  wire                               edscr_tda_i,
  input  wire                               gov_cntkctl_el1_el0pcten_i,
  input  wire                               gov_cntkctl_el1_el0vcten_i,
  input  wire                               gov_cntkctl_el1_el0pten_i,
  input  wire                               gov_cntkctl_el1_el0vten_i,
  input  wire                               gov_cnthctl_el2_el1pcen_i,
  input  wire                               gov_cnthctl_el2_el1pcten_i,
  input  wire                               gic_icc_sre_el1_ns_sre_i,
  input  wire                               gic_icc_sre_el1_s_sre_i,
  input  wire                               gic_icc_sre_el2_enable_i,
  input  wire                               gic_icc_sre_el2_sre_i,
  input  wire                               gic_icc_sre_el3_enable_i,
  input  wire                               gic_icc_sre_el3_sre_i,
  input  wire                               gic_ich_hcr_el2_tall0_i,
  input  wire                               gic_ich_hcr_el2_tall1_i,
  input  wire                               gic_ich_hcr_el2_tc_i,
  input  wire                               cryptodisable_i,
  // Outputs
  output wire                               expt_full_pc_iss_o,
  output wire                               exception_valid_iss_o,
  output wire        [`CA53_EXPT_BUS_W-1:0] exception_data_wr_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------
  reg                                     hstr_trap_match_iss;
  reg                               [5:0] exception_class_ex1;
  reg                              [25:0] exception_syndrome_ex1;
  reg                               [1:0] exception_el_iss;
  reg                               [4:0] exception_mode_iss;
  reg                                     exception_aa64_iss;
  reg                                     exception_aa64_ex1;
  reg       [`CA53_EXPT_INSTR_TYPE_W-1:0] expt_instr_type_iss;
  reg   [`CA53_EXPT_INSTR_TYPE_EX1_W-1:0] expt_instr_type_ex1;
  reg                                     cntkctl_el1_el0pcten_rs;
  reg                                     cntkctl_el1_el0vcten_rs;
  reg                                     cntkctl_el1_el0pten_rs;
  reg                                     cntkctl_el1_el0vten_rs;
  reg                                     cnthctl_el2_el1pcen_rs;
  reg                                     cnthctl_el2_el1pcten_rs;
  reg                                     icc_sre_el1_ns_sre_rs;
  reg                                     icc_sre_el1_s_sre_rs;
  reg                                     icc_sre_el2_enable_rs;
  reg                                     icc_sre_el2_sre_rs;
  reg                                     icc_sre_el3_enable_rs;
  reg                                     icc_sre_el3_sre_rs;
  reg                                     ich_hcr_el2_tall0_rs;
  reg                                     ich_hcr_el2_tall1_rs;
  reg                                     ich_hcr_el2_tc_rs;
  reg                                     sctlr_ntwe_rs;
  reg                                     sctlr_ntwi_rs;
  reg                                     sctlr_cp15ben_rs;
  reg                                     sctlr_sed_rs;
  reg                                     sctlr_el1_uci_rs;
  reg                                     sctlr_el1_uct_rs;
  reg                                     sctlr_el1_uma_rs;
  reg                                     sctlr_el1_dze_rs;
  reg                              [27:0] instr_iss;
  reg                                     instr_d_bit_iss;
  reg                                     instr_is_ls_iss;
  reg                                     instr_misc_iss;
  reg                                     instr_is_other_iss;
  reg                              [27:0] instr_ex1;
  reg                                     instr_d_bit_ex1;
  reg                                     instr_is_ls_ex1;
  reg                                     instr_misc_ex1;
  reg                                     take_tge_trap_ex1;
  reg                                     pmu_user_trap_iss;
  reg                                     gic_el2_trap_iss;
  reg                                     gic_el3_trap_iss;
  reg                                     ns_state_rs;
  reg                               [1:0] expt_cpacr_el1_fpen_rs;
  reg                                     expt_cpacr_asedis_rs;
  reg                                     expt_cptr_el2_tfp_rs;
  reg                                     expt_hcptr_tase_rs;
  reg                                     expt_cptr_el2_tcpac_rs;
  reg                               [3:1] aarch64_at_el_rs;
  reg                                     aarch64_state_rs;
  reg                                     monitor_mode;
  reg                                     in_halt_rs;
  reg                                     dbg_hlt_en_rs;
  reg                                     dbg_bkpt_wpt_en_rs;
  reg                                     dbg_halting_allowed_rs;
  reg                                     dbg_lock_set_rs;
  reg                               [6:0] ifu_ifsr_rs;
  reg                               [1:0] ifu_ifsr_stage2_rs;
  reg             [`CA53_SYND_TYPE_W-1:0] syndrome_type_ex1;
  reg                                     high_priority_ex1;
  reg                                     enter_halt_ex1;
  reg                               [4:2] expt_vec_offset_ex1;
  reg                               [1:0] cpsr_wr_en_ex1;
  reg                                     quash_ex1;
  reg                               [1:0] exception_el_ex1;
  reg                               [4:0] exception_mode_ex1;
  reg   [`CA53_FORCEOP_OFFSET_TYPE_W-1:0] forceop_offset_aa32_ex1;
  reg            [`CA53_DBG_STATUS_W-1:0] debug_status_ex1;
  reg             [`CA53_EXPT_TYPE_W-1:0] expt_type_ex1;
  reg              [`CA53_EXPT_BUS_W-1:0] exception_data_ex2;
  reg              [`CA53_EXPT_BUS_W-1:0] exception_data_wr;

  // -----------------------------
  // Wire declarations
  // -----------------------------
  wire  [`CA53_EXPT_INSTR_TYPE_EX1_W-1:0] nxt_expt_instr_type_ex1;
  wire                              [1:0] pre_target_el_iss;
  wire                              [4:0] pre_target_mode_iss;
  wire  [`CA53_FORCEOP_OFFSET_TYPE_W-1:0] pre_forceop_offset_aa32_iss;
  wire  [`CA53_FORCEOP_OFFSET_TYPE_W-1:0] forceop_offset_aa32_iss;
  wire            [`CA53_SYND_TYPE_W-1:0] pre_syndrome_type_iss;
  wire                                    pre_exception_valid_iss;
  wire                                    pre_quash_iss;
  wire     [`CA53_CPSR_WR_EN_EARLY_W-1:0] pre_cpsr_wr_en_iss;
  wire                              [4:0] pre_expt_vec_offset_iss;
  wire                                    high_priority_iss;
  wire                                    mcr_mrc_width_iss;
  wire                                    mcr_mrc_width_ex1;
  wire                                    mcr_mrc_type_iss;
  wire                                    mcr_mrc_type_ex1;
  wire                              [3:0] cond_ex1;
  wire                              [3:0] cp_primary_reg_iss;
  wire                                    crypto_undef_iss;
  wire                                    take_il_trap_iss;
  wire                                    take_hstr_trap_iss;
  wire                                    tidcp_match_aa32_iss;
  wire                                    tidcp_match_aa64_iss;
  wire                                    take_tidcp_trap_iss;
  wire            [`CA53_SYND_TYPE_W-1:0] syndrome_type_iss;
  wire                              [1:0] target_el_iss;
  wire                              [4:0] target_mode_iss;
  wire                              [4:0] expt_vec_offset_iss;
  wire     [`CA53_CPSR_WR_EN_EARLY_W-1:0] cpsr_wr_en_iss;
  wire                                    quash_iss;
  wire                                    nxt_monitor_mode;
  wire                                    nxt_dbg_lock_set;
  wire                                    pre_enter_halt_iss;
  wire                                    enter_halt_iss;
  wire                                    take_tge_trap_iss;
  wire                                    hcr_tge_valid;
  wire                                    take_sdd_trap_iss;
  wire                                    take_fp_id_grp_trap_iss;
  wire                                    fpexc_en_qual;
  wire      [`CA53_EXPT_INSTR_TYPE_W-1:0] expt_instr_type_int_iss;
  wire            [`CA53_EXPT_TYPE_W-1:0] pre_expt_type_iss;
  wire            [`CA53_EXPT_TYPE_W-1:0] expt_type_iss;
  wire           [`CA53_DBG_STATUS_W-1:0] debug_status_iss;
  wire                                    trapping_to_el2;
  wire                              [4:0] aa64_reg_15_12_ex1;
  wire                              [4:0] aa64_reg_19_16_ex1;
  wire                              [4:0] reg_15_12_ex1;
  wire                              [4:0] reg_19_16_ex1;
  wire                                    exception_at_same_el_ex1;
  wire                                    aarch64_at_el3;
  wire                                    external_iabort;
  wire                                    iabort_alignment;
  wire                                    icc_sre_el2_sre_qual;
  wire                                    icc_sre_el1_s_sre_qual;
  wire                                    icc_sre_el1_ns_sre_qual;
  wire                                    expt_instr_ctl_iss_en;
  wire                                    expt_instr_dp_iss_en;
  wire                                    expt_instr_type_iss_en;
  wire      [`CA53_EXPT_INSTR_TYPE_W-1:0] nxt_expt_instr_type_iss;
  wire                                    exception_en_ex1;
  wire                                    exception_en_ex2;
  wire                                    exception_valid_iss;
  wire                                    exception_data_ex1_en;
  wire             [`CA53_EXPT_BUS_W-1:0] exception_data_ex1;
  wire                                    expt_clock_en;
  wire                                    clk_expt;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Register slice external inputs
  // ------------------------------------------------------

  // Pre-compute values that can be registered prior to the decoder.  Most of these signals come from the
  // system registers, but some come from CPSR so updated on a flush.
  assign nxt_monitor_mode = cpsr_mode_ret_i == `CA53_FULL_MODE_MON;
  assign nxt_dbg_lock_set = dbg_os_lock_synced_i | dbg_double_lock_set_i;

  assign expt_instr_ctl_iss_en = flush_ret_i | early_expt_enable_de_i | in_halt_i;

  always @(posedge clk)
    if (expt_instr_ctl_iss_en) begin
      aarch64_at_el_rs        <= aarch64_at_el_i[3:1];
      aarch64_state_rs        <= aarch64_state_i;
      ns_state_rs             <= ns_state_i;
      monitor_mode            <= nxt_monitor_mode;
      ifu_ifsr_rs             <= ifu_ifsr_i[6:0];
      ifu_ifsr_stage2_rs      <= ifu_ifsr_stage2_i[1:0];
      expt_cpacr_el1_fpen_rs  <= expt_cpacr_el1_fpen_i[1:0];
      expt_cpacr_asedis_rs    <= expt_cpacr_asedis_i;
      expt_cptr_el2_tfp_rs    <= expt_cptr_el2_tfp_i;
      expt_hcptr_tase_rs      <= expt_hcptr_tase_i;
      expt_cptr_el2_tcpac_rs  <= expt_cptr_el2_tcpac_i;
      in_halt_rs              <= in_halt_i;
      dbg_hlt_en_rs           <= dbg_hlt_en_i;
      dbg_bkpt_wpt_en_rs      <= dbg_bkpt_wpt_en_i;
      dbg_halting_allowed_rs  <= dbg_halting_allowed_i;
      dbg_lock_set_rs         <= nxt_dbg_lock_set;
      cntkctl_el1_el0pcten_rs <= gov_cntkctl_el1_el0pcten_i;
      cntkctl_el1_el0vcten_rs <= gov_cntkctl_el1_el0vcten_i;
      cntkctl_el1_el0pten_rs  <= gov_cntkctl_el1_el0pten_i;
      cntkctl_el1_el0vten_rs  <= gov_cntkctl_el1_el0vten_i;
      cnthctl_el2_el1pcen_rs  <= gov_cnthctl_el2_el1pcen_i;
      cnthctl_el2_el1pcten_rs <= gov_cnthctl_el2_el1pcten_i;
      icc_sre_el1_ns_sre_rs   <= gic_icc_sre_el1_ns_sre_i;
      icc_sre_el1_s_sre_rs    <= gic_icc_sre_el1_s_sre_i;
      icc_sre_el2_enable_rs   <= gic_icc_sre_el2_enable_i;
      icc_sre_el2_sre_rs      <= gic_icc_sre_el2_sre_i;
      icc_sre_el3_enable_rs   <= gic_icc_sre_el3_enable_i;
      icc_sre_el3_sre_rs      <= gic_icc_sre_el3_sre_i;
      ich_hcr_el2_tall0_rs    <= gic_ich_hcr_el2_tall0_i;
      ich_hcr_el2_tall1_rs    <= gic_ich_hcr_el2_tall1_i;
      ich_hcr_el2_tc_rs       <= gic_ich_hcr_el2_tc_i;
      sctlr_ntwe_rs           <= sctlr_ntwe_i;
      sctlr_ntwi_rs           <= sctlr_ntwi_i;
      sctlr_cp15ben_rs        <= sctlr_cp15ben_i;
      sctlr_sed_rs            <= sctlr_sed_i;
      sctlr_el1_uci_rs        <= sctlr_el1_uci_i;
      sctlr_el1_uct_rs        <= sctlr_el1_uct_i;
      sctlr_el1_uma_rs        <= sctlr_el1_uma_i;
      sctlr_el1_dze_rs        <= sctlr_el1_dze_i;
    end

  // ------------------------------------------------------
  // Unpack and register De stage signals
  // ------------------------------------------------------

  // Register slice data from the decoder
  assign expt_instr_dp_iss_en = valid_instrs_de_i & ~stall_iss_i & early_expt_enable_de_i;

  always @(posedge clk)
    if (expt_instr_dp_iss_en) begin
      instr_misc_iss     <= expt_instr_data_de_i[`CA53_EXPT_INSTR_BUS_MISC_BIT];
      instr_is_other_iss <= expt_instr_data_de_i[`CA53_EXPT_INSTR_BUS_IS_OTHER_BIT];
      instr_is_ls_iss    <= expt_instr_data_de_i[`CA53_EXPT_INSTR_BUS_IS_LS_BIT];
      instr_d_bit_iss    <= expt_instr_data_de_i[`CA53_EXPT_INSTR_BUS_INSTR_D_BIT];
      instr_iss          <= expt_instr_data_de_i[`CA53_EXPT_INSTR_BUS_INSTR_BITS];
    end

  // Register slice control from the decoder which needs to run more freely
  assign expt_instr_type_iss_en = valid_iss_en_i & ((expt_instr_type_iss  != `CA53_EXPT_INSTR_TYPE_NULL) | early_expt_enable_de_i);

  assign nxt_expt_instr_type_iss = expt_instr_type_de_i & {`CA53_EXPT_INSTR_TYPE_W{~quash_de_i}};

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      expt_instr_type_iss <= `CA53_EXPT_INSTR_TYPE_NULL;
    else if (expt_instr_type_iss_en)
      expt_instr_type_iss <= nxt_expt_instr_type_iss;

  // ------------------------------------------------------
  // Iss stage
  // ------------------------------------------------------

  // Variables used by automatically generated logic
  assign aarch64_at_el3    = aarch64_at_el_rs[3];
  assign fpexc_en_qual     = cp_fpexc_en_i | aarch64_at_el_rs[1] | aarch64_state_rs; // FPEXC.EN has no effect in AArch64 (including AArch32 EL0 under AArch64 EL1)
  assign external_iabort   = `CA53_FAULT_GEN_EXT(ifu_ifsr_rs);
  assign iabort_alignment  = (ifu_ifsr_rs == `CA53_FAULT_LPAE_ALIGNMENT);
  assign hcr_tge_valid     = hcr_tge_i & ns_state_rs;
  assign mcr_mrc_width_iss = ~(instr_iss[27:24] == 4'b1110);  // 0 => MCR/MRC
                                                              // 1 => MCRR/MRRC
  assign mcr_mrc_type_iss  = instr_iss[20]; // 1 => MRC
                                            // 0 => MCR

  // Calculate EL0 permissions for PMU register accesses
  always @*
    case (expt_instr_type_iss)
      `CA53_EXPT_INSTR_TYPE_PMU_PMCR,
      `CA53_EXPT_INSTR_TYPE_PMU_REG     : pmu_user_trap_iss = (dpu_exception_level_i == `CA53_EL0) & ~pmn_useren_i[0];
      `CA53_EXPT_INSTR_TYPE_PMU_SWINC   : pmu_user_trap_iss = (dpu_exception_level_i == `CA53_EL0) & ~pmn_useren_i[0] & ~pmn_useren_i[1];
      `CA53_EXPT_INSTR_TYPE_PMU_CCNT_RD : pmu_user_trap_iss = (dpu_exception_level_i == `CA53_EL0) & ~pmn_useren_i[0] & ~pmn_useren_i[2];
      `CA53_EXPT_INSTR_TYPE_PMU_EVREG   : pmu_user_trap_iss = (dpu_exception_level_i == `CA53_EL0) & ~pmn_useren_i[0] & ~pmn_useren_i[3];
      `CA53_EXPT_INSTR_TYPE_PMU_USERENR : pmu_user_trap_iss = 1'b0; // Reads of PMUSERENR never trap
      default                           : pmu_user_trap_iss = 1'bx;
    endcase

  // Calculate GIC permissions
  assign icc_sre_el2_sre_qual    = icc_sre_el3_sre_rs & (icc_sre_el2_sre_rs | icc_sre_el1_s_sre_rs);
  assign icc_sre_el1_s_sre_qual  = icc_sre_el3_sre_rs & icc_sre_el1_s_sre_rs;
  assign icc_sre_el1_ns_sre_qual = icc_sre_el2_sre_qual & (icc_sre_el1_ns_sre_rs | ((~hcr_amo_i | ~hcr_imo_i | ~hcr_fmo_i) & icc_sre_el1_s_sre_rs));
                    
  always @*
    case (expt_instr_type_iss)
      `CA53_EXPT_INSTR_TYPE_GIC_GROUP0: begin
        gic_el2_trap_iss = ich_hcr_el2_tall0_rs;
        gic_el3_trap_iss = scr_el3_fiq_i & ~(ns_state_rs & (dpu_exception_level_i < `CA53_EL2) & hcr_fmo_i);
      end
      `CA53_EXPT_INSTR_TYPE_GIC_GROUP1: begin
        gic_el2_trap_iss = ich_hcr_el2_tall1_rs;
        gic_el3_trap_iss = scr_el3_irq_i & ~(ns_state_rs & (dpu_exception_level_i < `CA53_EL2) & hcr_imo_i);
      end
      `CA53_EXPT_INSTR_TYPE_GIC_SGI: begin
        gic_el2_trap_iss = ich_hcr_el2_tc_rs | (ns_state_rs & (dpu_exception_level_i < `CA53_EL2) & (hcr_fmo_i | hcr_imo_i));
        gic_el3_trap_iss = scr_el3_fiq_i & scr_el3_irq_i;
      end
      `CA53_EXPT_INSTR_TYPE_GIC_COMMON: begin
        gic_el2_trap_iss = ich_hcr_el2_tc_rs;
        gic_el3_trap_iss = scr_el3_fiq_i & scr_el3_irq_i & ~(ns_state_rs & (dpu_exception_level_i < `CA53_EL2) & (hcr_fmo_i | hcr_imo_i));
      end
      default: begin
        gic_el2_trap_iss = 1'bx;
        gic_el3_trap_iss = 1'bx;
      end
    endcase

  // Convert FP_IDx instr_iss types to be FP_ID for auto-generated logic, so that
  // the traps which apply to all FP_ID regs can be calculated. The traps
  // which apply to the specific ID groups are applied later.
  // Also map PMU encodings onto PMU_REG - user permissions are handled
  // via pmu_user_trap
  // Similarly group GIC accesses
  assign expt_instr_type_int_iss =  (expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_CRYPTO)       ? `CA53_EXPT_INSTR_TYPE_NEON    :
                                   ((expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_FP_ID0)      |
                                    (expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_FP_ID3))      ? `CA53_EXPT_INSTR_TYPE_FP_ID   :
                                   ((expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_PMU_SWINC)   |
                                    (expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_PMU_EVREG)   |
                                    (expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_PMU_CCNT_RD) |
                                    (expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_PMU_USERENR)) ? `CA53_EXPT_INSTR_TYPE_PMU_REG :
                                   ((expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_GIC_GROUP0)  |
                                    (expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_GIC_GROUP1)  |
                                    (expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_GIC_SGI))     ? `CA53_EXPT_INSTR_TYPE_GIC_COMMON :
                                                                                                   expt_instr_type_iss;

  // ------------------------------------------------------
  // Start automatically generated logic
  // ------------------------------------------------------

  wire    net_1, net_4, net_5, net_6, net_7, net_8,
         net_9, net_10, net_11, net_12, net_13, net_14, net_15, net_16, net_17,
         net_18, net_19, net_20, net_21, net_22, net_23, net_25, net_26,
         net_27, net_28, net_29, net_30, net_31, net_32, net_33, net_34,
         net_35, net_36, net_37, net_38, net_39, net_40, net_41, net_42,
         net_43, net_44, net_45, net_46, net_47, net_48, net_50, net_51,
         net_52, net_53, net_54, net_55, net_56, net_57, net_58, net_59,
         net_61, net_62, net_63, net_64, net_65, net_66, net_68, net_69,
         net_70, net_71, net_72, net_73, net_74, net_75, net_76, net_77,
         net_78, net_79, net_80, net_81, net_82, net_83, net_84, net_85,
         net_86, net_88, net_89, net_90, net_91, net_92, net_93, net_94,
         net_95, net_96, net_97, net_98, net_99, net_100, net_101, net_102,
         net_103, net_104, net_105, net_106, net_107, net_108, net_109,
         net_110, net_111, net_112, net_113, net_114, net_115, net_116,
         net_117, net_118, net_119, net_120, net_121, net_122, net_123,
         net_124, net_125, net_126, net_127, net_128, net_129, net_130,
         net_131, net_132, net_133, net_134, net_135, net_136, net_137,
         net_138, net_139, net_140, net_141, net_142, net_143, net_144,
         net_145, net_146, net_147, net_148, net_149, net_150, net_151,
         net_152, net_153, net_154, net_155, net_156, net_157, net_158,
         net_159, net_160, net_161, net_162, net_163, net_164, net_165,
         net_166, net_167, net_168, net_169, net_170, net_171, net_172,
         net_173, net_174, net_175, net_176, net_177, net_178, net_179,
         net_180, net_181, net_182, net_183, net_184, net_185, net_186,
         net_187, net_188, net_189, net_190, net_191, net_192, net_193,
         net_194, net_195, net_196, net_197, net_198, net_199, net_200,
         net_201, net_202, net_203, net_204, net_205, net_206, net_207,
         net_208, net_209, net_210, net_211, net_212, net_213, net_214,
         net_215, net_216, net_217, net_218, net_219, net_220, net_221,
         net_222, net_223, net_224, net_225, net_226, net_227, net_228,
         net_229, net_230, net_231, net_232, net_233, net_234, net_235,
         net_236, net_237, net_238, net_239, net_240, net_241, net_242,
         net_243, net_244, net_245, net_246, net_247, net_248, net_249,
         net_250, net_251, net_252, net_253, net_254, net_255, net_256,
         net_257, net_258, net_259, net_260, net_261, net_262, net_263,
         net_264, net_265, net_266, net_267, net_268, net_269, net_270,
         net_271, net_272, net_273, net_274, net_275, net_276, net_277,
         net_278, net_279, net_280, net_281, net_282, net_283, net_284,
         net_285, net_286, net_287, net_288, net_289, net_290, net_291,
         net_292, net_293, net_294, net_295, net_296, net_297, net_298,
         net_299, net_300, net_301, net_302, net_303, net_304, net_305,
         net_306, net_307, net_308, net_309, net_310, net_311, net_312,
         net_313, net_314, net_315, net_316, net_317, net_318, net_319,
         net_320, net_321, net_322, net_323, net_324, net_325, net_326,
         net_327, net_328, net_329, net_330, net_331, net_332, net_333,
         net_334, net_335, net_336, net_337, net_338, net_339, net_340,
         net_341, net_342, net_343, net_344, net_345, net_346, net_347,
         net_348, net_349, net_350, net_351, net_352, net_353, net_354,
         net_355, net_356, net_357, net_358, net_359, net_360, net_361,
         net_362, net_363, net_364, net_365, net_366, net_367, net_368,
         net_369, net_370, net_371, net_372, net_373, net_374, net_375,
         net_381, net_383, net_384, net_385, net_386, net_387, net_388,
         net_389, net_390, net_391, net_392, net_393, net_394, net_395,
         net_396, net_397, net_398, net_399, net_400, net_401, net_402,
         net_403, net_404, net_405, net_406, net_407, net_408, net_409,
         net_410, net_411, net_412, net_413, net_414, net_415, net_416,
         net_417, net_418, net_419, net_420, net_421, net_422, net_423,
         net_424, net_425, net_426, net_427, net_428, net_429, net_430,
         net_431, net_432, net_433, net_434, net_435, net_436, net_440,
         net_441, net_442, net_443, net_444, net_445, net_446, net_447,
         net_448, net_449, net_450, net_451, net_452, net_455, net_456,
         net_457, net_458, net_459, net_460, net_461, net_462, net_463,
         net_464, net_465, net_466, net_467, net_468, net_469, net_470,
         net_471, net_472, net_473, net_474, net_475, net_476, net_477,
         net_478, net_479, net_480, net_481, net_482, net_483, net_484,
         net_485, net_486, net_487, net_488, net_489, net_490, net_491,
         net_492, net_493, net_494, net_495, net_500, net_501, net_502,
         net_503, net_504, net_505, net_509, net_510, net_511, net_512,
         net_513, net_514, net_515, net_516, net_517, net_518, net_519,
         net_520, net_521, net_522, net_523, net_524, net_525, net_526,
         net_527, net_528, net_529, net_530, net_531, net_532, net_533,
         net_534, net_535, net_536, net_537, net_538, net_539, net_540,
         net_541, net_542, net_543, net_544, net_545, net_546, net_547,
         net_548, net_549, net_550, net_551, net_552, net_553, net_554,
         net_555, net_556, net_557, net_558, net_559, net_560, net_561,
         net_562, net_563, net_564, net_565, net_566, net_567, net_568,
         net_569, net_570, net_571, net_572, net_573, net_574, net_575,
         net_576, net_577, net_578, net_579, net_580, net_581, net_582,
         net_583, net_584, net_585, net_586, net_587, net_588, net_589,
         net_590, net_591, net_592, net_593, net_594, net_595, net_596,
         net_597, net_598, net_599, net_600, net_601, net_602, net_603,
         net_604, net_605, net_606, net_607, net_608, net_609, net_610,
         net_611, net_612, net_613, net_614, net_615, net_616, net_617,
         net_618, net_619, net_620, net_621, net_622, net_623, net_624,
         net_625, net_626, net_627, net_628, net_629, net_630, net_631,
         net_632, net_633, net_634, net_635, net_636, net_637, net_638,
         net_639, net_640, net_641, net_642, net_643, net_644, net_645,
         net_646, net_647, net_648, net_649, net_650, net_651, net_652,
         net_653, net_654, net_655, net_656, net_657, net_658, net_659,
         net_660, net_661, net_662, net_663, net_664, net_665, net_666,
         net_667, net_668, net_669, net_670, net_671, net_672, net_673,
         net_674, net_675, net_676, net_677, net_678, net_679, net_680,
         net_681, net_682, net_683, net_684, net_685, net_686, net_687,
         net_688, net_689, net_690, net_691, net_692, net_693, net_694,
         net_695, net_696, net_697, net_698, net_699, net_700, net_701,
         net_702, net_703, net_704, net_705, net_706, net_707, net_708,
         net_709, net_710, net_711, net_712, net_713, net_714, net_715,
         net_716, net_717, net_718, net_719, net_720, net_721, net_722,
         net_723, net_724, net_725, net_726, net_727, net_728, net_729,
         net_730, net_731, net_732, net_733, net_734, net_735, net_736,
         net_737, net_738, net_739, net_740, net_741, net_742, net_743,
         net_744, net_745, net_746, net_747, net_748, net_749, net_750,
         net_751, net_752, net_753, net_754, net_755, net_756, net_757,
         net_758, net_759, net_760, net_761, net_762, net_763, net_764,
         net_765, net_766, net_767, net_768, net_769, net_770, net_771,
         net_772, net_773, net_774, net_775, net_776, net_777, net_778,
         net_779, net_780, net_781, net_782, net_783, net_784, net_785,
         net_786, net_787, net_788, net_789, net_790, net_791, net_792,
         net_793, net_794, net_795, net_796, net_797, net_798, net_799,
         net_800, net_801, net_802, net_803, net_804, net_805, net_806,
         net_807, net_808, net_809, net_810, net_811, net_812, net_813,
         net_814, net_815, net_816, net_817, net_818, net_819, net_820,
         net_821, net_822, net_823, net_824, net_825, net_826, net_827,
         net_828, net_829, net_830, net_831, net_832, net_833, net_834,
         net_835, net_836, net_837, net_838, net_839, net_840, net_841,
         net_842, net_843, net_844, net_845, net_846, net_847, net_848,
         net_849, net_850, net_851, net_852, net_853, net_854, net_855,
         net_856, net_857, net_858, net_859, net_860, net_861, net_862,
         net_863, net_864, net_865, net_866, net_867, net_868, net_869,
         net_870, net_871, net_872, net_873, net_874, net_875, net_876,
         net_877, net_878, net_879, net_880, net_881, net_882, net_883,
         net_884, net_885, net_886, net_887, net_888, net_889, net_890,
         net_891, net_892, net_893, net_894, net_895, net_896, net_897,
         net_898, net_899, net_900, net_901, net_902, net_903, net_904,
         net_905, net_906, net_907, net_908, net_909, net_910, net_911,
         net_912, net_913, net_914, net_915, net_916, net_917, net_918,
         net_919, net_920, net_921, net_922, net_923, net_924, net_925,
         net_926, net_927, net_928, net_929, net_930, net_931, net_932,
         net_933, net_934, net_935, net_936, net_937, net_938, net_939,
         net_940, net_941, net_942, net_943, net_944, net_945, net_946,
         net_947, net_948, net_949, net_950, net_951, net_952, net_953,
         net_954, net_955, net_956, net_957, net_958, net_959, net_960,
         net_961, net_962, net_963, net_964, net_965, net_966, net_967,
         net_968, net_969, net_970, net_971, net_972, net_973, net_974,
         net_975, net_976, net_977, net_978, net_979, net_980, net_981,
         net_982, net_983, net_984, net_985, net_986, net_987, net_988,
         net_989, net_990, net_991, net_992, net_993, net_994, net_995,
         net_996, net_997, net_998, net_999, net_1000, net_1001, net_1002,
         net_1003, net_1004, net_1005, net_1006, net_1007, net_1008, net_1009,
         net_1010, net_1011, net_1012, net_1013, net_1014, net_1015, net_1016,
         net_1017, net_1018, net_1019, net_1020, net_1021, net_1022, net_1023,
         net_1024, net_1025, net_1026, net_1027, net_1028, net_1029, net_1030,
         net_1031, net_1032, net_1033, net_1034, net_1035, net_1036, net_1037,
         net_1038, net_1039, net_1040, net_1041, net_1042, net_1043, net_1044,
         net_1045, net_1046, net_1047, net_1048, net_1049, net_1050, net_1051,
         net_1052, net_1053, net_1054, net_1055, net_1056, net_1057, net_1058,
         net_1059, net_1060, net_1061, net_1062, net_1063, net_1064, net_1065,
         net_1066, net_1067, net_1068, net_1069, net_1070, net_1071, net_1072,
         net_1073, net_1074, net_1075, net_1076, net_1077, net_1078, net_1079,
         net_1080, net_1081, net_1082, net_1083, net_1084, net_1085, net_1086,
         net_1087, net_1088, net_1089, net_1090, net_1091, net_1092, net_1093,
         net_1094, net_1095, net_1096, net_1097, net_1098, net_1099, net_1100,
         net_1101, net_1102, net_1103, net_1104, net_1105, net_1106, net_1107,
         net_1108, net_1109, net_1110, net_1111, net_1112, net_1113, net_1114,
         net_1115, net_1116, net_1117, net_1118, net_1119, net_1120, net_1121,
         net_1122, net_1123, net_1124, net_1125, net_1126, net_1127, net_1128,
         net_1129, net_1130, net_1131, net_1132, net_1133, net_1134, net_1135,
         net_1136, net_1137, net_1138, net_1139, net_1140, net_1141, net_1142,
         net_1143, net_1144, net_1145, net_1146, net_1147, net_1148, net_1149,
         net_1150, net_1151, net_1152, net_1153, net_1154, net_1155, net_1156,
         net_1157, net_1158, net_1159, net_1160, net_1161, net_1162, net_1163,
         net_1164, net_1165, net_1166, net_1167, net_1168, net_1169, net_1170,
         net_1171, net_1172, net_1173, net_1174, net_1175, net_1176, net_1177,
         net_1178, net_1179, net_1180, net_1181, net_1182, net_1183, net_1184,
         net_1185, net_1186, net_1187, net_1188, net_1189, net_1190, net_1191,
         net_1192, net_1193, net_1194, net_1195, net_1196, net_1197, net_1198,
         net_1199, net_1200, net_1201, net_1202, net_1203, net_1204, net_1205,
         net_1206, net_1207, net_1208, net_1209, net_1210, net_1211, net_1212,
         net_1213, net_1214, net_1215, net_1216, net_1217, net_1218, net_1219,
         net_1220, net_1221, net_1222, net_1223, net_1224, net_1225, net_1226,
         net_1227, net_1228, net_1229, net_1230, net_1231, net_1232, net_1233,
         net_1234, net_1235, net_1236, net_1237, net_1238, net_1239, net_1240,
         net_1241, net_1242, net_1243, net_1244, net_1245, net_1246, net_1247,
         net_1248, net_1249, net_1250, net_1251, net_1252, net_1253, net_1254,
         net_1255, net_1256, net_1257, net_1258, net_1259, net_1260, net_1261,
         net_1262, net_1263, net_1264, net_1265, net_1266, net_1267, net_1268,
         net_1269, net_1270, net_1271, net_1272, net_1273, net_1274, net_1275,
         net_1276, net_1277, net_1278, net_1279, net_1280, net_1281, net_1282,
         net_1283, net_1284, net_1285, net_1286, net_1287, net_1288, net_1289,
         net_1290, net_1291, net_1292, net_1293, net_1294, net_1295, net_1296,
         net_1297, net_1298, net_1299, net_1300, net_1301, net_1302, net_1303,
         net_1304, net_1305, net_1306, net_1307, net_1308, net_1309, net_1310,
         net_1311, net_1312, net_1313, net_1314, net_1315, net_1316, net_1317,
         net_1318, net_1319, net_1320, net_1321, net_1322, net_1323, net_1324,
         net_1325, net_1326, net_1327, net_1328, net_1329, net_1330, net_1331,
         net_1332, net_1333, net_1334, net_1335, net_1336, net_1337, net_1338,
         net_1339, net_1340, net_1341, net_1342, net_1343, net_1344, net_1345,
         net_1346, net_1347, net_1348, net_1349, net_1350, net_1351, net_1352,
         net_1353, net_1354, net_1355, net_1356, net_1357, net_1358, net_1359,
         net_1360, net_1361, net_1362, net_1363, net_1364, net_1365, net_1366,
         net_1367, net_1368, net_1369, net_1370, net_1371, net_1372, net_1373,
         net_1374, net_1375, net_1376, net_1377, net_1378, net_1379, net_1380,
         net_1381, net_1382, net_1383, net_1384, net_1385, net_1386, net_1387,
         net_1388, net_1389, net_1390, net_1391, net_1392, net_1393, net_1394,
         net_1395, net_1396, net_1397, net_1398, net_1399, net_1400, net_1401,
         net_1402, net_1403, net_1404, net_1405, net_1406, net_1407, net_1408,
         net_1409, net_1410, net_1411, net_1412, net_1413, net_1414, net_1415,
         net_1416, net_1417, net_1418, net_1419, net_1420, net_1421, net_1422,
         net_1423, net_1424, net_1425, net_1426, net_1427, net_1428, net_1429,
         net_1430, net_1431, net_1432, net_1433, net_1434, net_1435, net_1436,
         net_1437, net_1438, net_1439, net_1440, net_1441, net_1442, net_1443,
         net_1444, net_1445, net_1446, net_1447, net_1448, net_1449, net_1450,
         net_1451, net_1452, net_1453, net_1454, net_1455, net_1456, net_1457,
         net_1458, net_1459, net_1460, net_1461, net_1462, net_1463, net_1464,
         net_1465, net_1466, net_1467, net_1468, net_1469, net_1470, net_1471,
         net_1472, net_1473, net_1474, net_1475, net_1476, net_1477, net_1478,
         net_1479, net_1480, net_1481, net_1482, net_1483, net_1484, net_1485,
         net_1486, net_1487, net_1488, net_1489, net_1490, net_1491, net_1492,
         net_1493, net_1494, net_1495, net_1496, net_1497, net_1498, net_1499,
         net_1500, net_1501, net_1502, net_1503, net_1504, net_1505, net_1506,
         net_1507, net_1508, net_1509, net_1510, net_1511, net_1512, net_1513,
         net_1514, net_1515, net_1516, net_1517, net_1518, net_1519, net_1520,
         net_1521, net_1522, net_1523, net_1524, net_1525, net_1526, net_1527,
         net_1528, net_1529, net_1530, net_1531, net_1532, net_1533, net_1534,
         net_1535, net_1536, net_1537, net_1538, net_1539, net_1540, net_1541,
         net_1542, net_1543, net_1544, net_1545, net_1546, net_1547, net_1548,
         net_1549, net_1550, net_1551, net_1552, net_1553, net_1554, net_1555,
         net_1556, net_1557, net_1558, net_1559, net_1560, net_1561, net_1562,
         net_1563, net_1564, net_1565, net_1566, net_1567, net_1568, net_1569,
         net_1570, net_1571, net_1572, net_1573, net_1574, net_1575, net_1576,
         net_1577, net_1578, net_1579, net_1580, net_1581, net_1582, net_1583,
         net_1584, net_1585, net_1586, net_1587, net_1588, net_1589, net_1590,
         net_1591, net_1592, net_1593, net_1594, net_1595, net_1596, net_1597,
         net_1598, net_1599, net_1600, net_1601, net_1602, net_1603, net_1604,
         net_1605, net_1606, net_1607, net_1608, net_1609, net_1610, net_1611,
         net_1612, net_1613, net_1614, net_1615, net_1616, net_1617, net_1618,
         net_1619, net_1620, net_1621, net_1622, net_1623, net_1624, net_1625,
         net_1626, net_1627, net_1628, net_1629, net_1630, net_1631, net_1632,
         net_1633, net_1634, net_1635, net_1636, net_1637, net_1638, net_1639,
         net_1640, net_1641, net_1642, net_1643, net_1644, net_1645, net_1646,
         net_1647, net_1648, net_1649, net_1650, net_1651, net_1652, net_1653,
         net_1654, net_1655, net_1656, net_1657, net_1658, net_1659, net_1660,
         net_1661, net_1662, net_1663, net_1664, net_1665, net_1666, net_1667,
         net_1668, net_1669, net_1670, net_1671, net_1672, net_1673, net_1674,
         net_1675, net_1676, net_1677, net_1678, net_1679, net_1680, net_1681,
         net_1682, net_1683, net_1684, net_1685, net_1686, net_1687, net_1688,
         net_1689, net_1690, net_1691, net_1692, net_1693, net_1694, net_1695,
         net_1696, net_1697, net_1698, net_1699, net_1700, net_1701, net_1702,
         net_1703, net_1704, net_1705, net_1706, net_1707, net_1708, net_1709,
         net_1710, net_1711, net_1712, net_1713, net_1714, net_1715, net_1716,
         net_1717, net_1718, net_1719, net_1720, net_1721, net_1722, net_1723,
         net_1724, net_1725, net_1726, net_1727, net_1728, net_1729, net_1730,
         net_1731, net_1732, net_1733, net_1734, net_1735, net_1736, net_1737,
         net_1738, net_1739, net_1740, net_1741, net_1742, net_1743, net_1744,
         net_1745, net_1746, net_1747, net_1748, net_1749, net_1750, net_1751,
         net_1752, net_1753, net_1754, net_1755, net_1756, net_1757, net_1758,
         net_1759, net_1760, net_1761, net_1762, net_1763, net_1764, net_1765,
         net_1766, net_1767, net_1768, net_1769, net_1770, net_1771, net_1772,
         net_1773, net_1774, net_1775, net_1776, net_1777, net_1778, net_1779,
         net_1780, net_1781, net_1782, net_1783, net_1784, net_1785, net_1786,
         net_1787, net_1788, net_1789, net_1790, net_1791, net_1792, net_1793,
         net_1794, net_1795, net_1796, net_1797, net_1798, net_1799, net_1800,
         net_1801, net_1802, net_1803, net_1804, net_1805, net_1806, net_1807,
         net_1808, net_1809, net_1810, net_1811, net_1812, net_1813, net_1814,
         net_1815, net_1816, net_1817, net_1818, net_1819, net_1820, net_1821,
         net_1822, net_1823, net_1824, net_1825, net_1826, net_1827, net_1828,
         net_1829, net_1830, net_1831, net_1832, net_1833, net_1834, net_1835,
         net_1836, net_1837, net_1838, net_1839, net_1840, net_1841, net_1842,
         net_1843, net_1844, net_1845, net_1846, net_1847, net_1848, net_1849,
         net_1850, net_1851, net_1852, net_1853, net_1854, net_1855, net_1856,
         net_1857, net_1858, net_1859, net_1860, net_1861, net_1862, net_1863,
         net_1864, net_1865, net_1866, net_1867, net_1868, net_1869, net_1870,
         net_1871, net_1872, net_1873, net_1874, net_1875, net_1876, net_1877,
         net_1878, net_1879, net_1880, net_1881, net_1882, net_1883, net_1884,
         net_1885, net_1886, net_1887, net_1888, net_1889, net_1890, net_1891,
         net_1892, net_1893, net_1894, net_1895, net_1896, net_1897, net_1898,
         net_1899, net_1900, net_1901, net_1902, net_1903, net_1904, net_1905,
         net_1906, net_1907, net_1908, net_1909, net_1910, net_1911, net_1912,
         net_1913, net_1914, net_1915, net_1916, net_1917, net_1918, net_1919,
         net_1920, net_1921, net_1922, net_1923, net_1924, net_1925, net_1926,
         net_1927, net_1928, net_1929, net_1930, net_1931, net_1932, net_1933,
         net_1934, net_1935, net_1936, net_1937, net_1938, net_1939, net_1940,
         net_1941, net_1942, net_1943, net_1944, net_1945, net_1946, net_1947,
         net_1948, net_1949, net_1950, net_1951, net_1952, net_1953, net_1954,
         net_1955, net_1956, net_1957, net_1958, net_1959, net_1960, net_1961,
         net_1962, net_1963, net_1964, net_1965, net_1966, net_1967, net_1968,
         net_1969, net_1970, net_1971, net_1972, net_1973, net_1974, net_1975,
         net_1976, net_1977, net_1978, net_1979, net_1980, net_1981, net_1982,
         net_1983, net_1984, net_1985, net_1986, net_1987, net_1988, net_1989,
         net_1990, net_1991, net_1992, net_1993, net_1994, net_1995, net_1996,
         net_1997, net_1998, net_1999, net_2000, net_2001, net_2002, net_2003,
         net_2004, net_2005, net_2006, net_2007, net_2008, net_2009, net_2010,
         net_2011, net_2012, net_2013, net_2014, net_2015, net_2016, net_2017,
         net_2018, net_2019, net_2020, net_2021, net_2022, net_2023, net_2024,
         net_2025, net_2026, net_2027, net_2028, net_2029, net_2030, net_2031,
         net_2032, net_2033, net_2034, net_2035, net_2036, net_2037, net_2038,
         net_2039, net_2040, net_2041, net_2042, net_2043, net_2044, net_2045,
         net_2046, net_2047, net_2048, net_2049, net_2050, net_2051, net_2052,
         net_2053, net_2054, net_2055, net_2056, net_2057, net_2058, net_2059,
         net_2060, net_2061, net_2062, net_2063, net_2064, net_2065, net_2066,
         net_2067, net_2068, net_2069, net_2070, net_2071, net_2072, net_2073,
         net_2074, net_2075, net_2076, net_2077, net_2078, net_2079, net_2080,
         net_2081, net_2082, net_2083, net_2084, net_2085, net_2086, net_2087,
         net_2088, net_2089, net_2090;

  assign pre_target_mode_iss[1] = pre_target_mode_iss[4];
  assign pre_forceop_offset_aa32_iss[1] = 1'b0;
  assign pre_expt_vec_offset_iss[1] = 1'b0;
  assign pre_expt_vec_offset_iss[0] = 1'b0;
  assign net_1 = ~net_163;
  assign net_4 = ~net_538;
  assign net_5 = ~net_358;
  assign net_6 = ~net_637;
  assign net_7 = ~net_322;
  assign net_8 = ~net_204;
  assign net_9 = ~net_1070;
  assign net_10 = ~net_1028;
  assign net_11 = ~net_218;
  assign net_12 = ~net_1072;
  assign net_13 = ~net_164;
  assign net_14 = ~net_949;
  assign net_15 = ~net_132;
  assign net_16 = ~net_1216;
  assign net_17 = ~net_552;
  assign net_18 = ~net_803;
  assign net_19 = ~net_1285;
  assign net_20 = ~net_244;
  assign net_21 = ~net_1786;
  assign net_22 = ~net_585;
  assign net_23 = ~net_654;
  assign net_25 = ~net_1403;
  assign net_26 = ~net_1405;
  assign net_27 = ~net_715;
  assign net_28 = ~net_224;
  assign net_29 = ~net_1127;
  assign net_30 = ~net_911;
  assign net_31 = ~net_136;
  assign net_32 = ~net_105;
  assign net_33 = ~net_113;
  assign net_34 = ~expt_instr_type_int_iss[3];
  assign net_35 = ~net_309;
  assign net_36 = ~net_184;
  assign net_37 = ~net_1687;
  assign net_38 = ~net_298;
  assign net_39 = ~net_2049;
  assign net_40 = ~net_739;
  assign net_41 = ~net_275;
  assign net_42 = ~net_1181;
  assign net_43 = ~net_713;
  assign net_44 = ~net_1177;
  assign net_45 = ~net_226;
  assign net_46 = ~net_125;
  assign net_47 = ~net_1681;
  assign net_48 = ~expt_instr_type_int_iss[1];
  assign net_50 = ~aarch64_state_rs;
  assign net_51 = ~net_1690;
  assign net_52 = ~net_1842;
  assign net_53 = ~net_464;
  assign net_54 = ~net_236;
  assign net_55 = ~net_504;
  assign net_56 = ~net_556;
  assign net_57 = ~net_375;
  assign net_58 = ~net_990;
  assign net_59 = ~net_208;
  assign net_61 = ~net_419;
  assign net_62 = ~net_862;
  assign net_63 = ~net_494;
  assign net_64 = ~net_473;
  assign net_65 = ~net_1568;
  assign net_66 = ~net_1244;
  assign net_68 = ~net_802;
  assign net_69 = ~dpu_exception_level_i[0];
  assign net_70 = ~net_765;
  assign net_71 = ~aarch64_at_el3;
  assign net_72 = ~hdcr_tda_i;
  assign net_73 = ~mdcr_el3_tda_i;
  assign net_74 = ~hcr_tvm_i;
  assign net_75 = ~l2ectlr_el3_i;
  assign net_76 = ~cpuactlr_el2_i;
  assign net_77 = ~l2ectlr_el2_i;
  assign net_78 = ~expt_cpacr_asedis_rs;
  assign net_79 = ~expt_cptr_el2_tfp_rs;
  assign net_80 = ~scr_el3_hce_i;
  assign net_81 = ~scr_el3_smd_i;
  assign net_82 = ~cntkctl_el1_el0vcten_rs;
  assign net_83 = ~net_617;
  assign net_84 = ~icc_sre_el2_sre_qual;
  assign net_85 = ~icc_sre_el1_ns_sre_qual;
  assign net_86 = ~in_halt_rs;
  assign pre_target_mode_iss[3] = ~(net_88 & net_89);
  assign net_88 = (net_90 & net_91);
  assign net_91 = ~(net_92 & ns_state_rs);
  assign net_92 = (net_2090 & net_93);
  assign net_93 = ~(net_94 & net_95);
  assign net_95 = (net_96 & net_97);
  assign net_97 = (net_98 & net_99);
  assign net_99 = (net_100 & net_101);
  assign net_100 = (net_102 & net_103);
  assign net_103 = (net_2088 | net_104);
  assign net_102 = (net_105 | net_106);
  assign net_98 = (net_107 & net_108);
  assign net_108 = (net_109 | dpu_exception_level_i[1]);
  assign net_109 = (net_110 & net_111);
  assign net_111 = (net_112 | net_113);
  assign net_110 = (net_114 & net_115);
  assign net_115 = (expt_instr_type_int_iss[0] | net_116);
  assign net_116 = (net_34 | net_117);
  assign net_114 = ~(net_118 | net_119);
  assign net_119 = ~(scr_el3_ea_i | net_120);
  assign net_120 = ~(net_121 & net_122);
  assign net_118 = (net_123 | net_124);
  assign net_124 = (net_125 & net_126);
  assign net_123 = ~(net_20 | net_127);
  assign net_127 = ~(net_30 & hcr_tge_i);
  assign net_107 = (net_128 & net_129);
  assign net_129 = (net_130 | net_131);
  assign net_131 = ~(net_132 & net_33);
  assign net_128 = (net_133 & net_134);
  assign net_134 = (net_135 | net_136);
  assign net_133 = ~(net_137 & net_69);
  assign net_96 = ~(hdcr_tde_i & net_138);
  assign net_138 = ~(net_139 & net_140);
  assign net_140 = (net_141 | expt_instr_type_int_iss[4]);
  assign net_90 = ~(net_142 | net_143);
  assign net_143 = ~(net_144 & net_145);
  assign net_145 = (net_146 & net_147);
  assign net_146 = (net_148 & net_149);
  assign net_149 = (net_150 | net_151);
  assign net_148 = (net_152 | aarch64_at_el3);
  assign net_144 = (net_153 & net_154);
  assign net_154 = ~(net_155 & net_156);
  assign net_153 = (net_157 & net_158);
  assign net_158 = (net_159 & net_160);
  assign net_160 = (net_161 | net_162);
  assign net_161 = ~(net_163 & net_164);
  assign net_159 = (net_165 & net_166);
  assign net_166 = (net_167 & net_168);
  assign net_168 = (net_4 | net_169);
  assign net_169 = (net_170 & net_171);
  assign net_170 = (net_172 & net_173);
  assign net_173 = (net_174 | net_175);
  assign net_172 = (net_176 | net_177);
  assign net_167 = ~(net_178 & net_179);
  assign net_179 = (net_180 | net_181);
  assign net_181 = (net_182 & ifu_ifsr_stage2_rs[1]);
  assign net_182 = ~(net_183 | net_184);
  assign net_180 = (net_125 & net_185);
  assign net_185 = ~(net_66 & net_186);
  assign net_157 = (net_187 & net_188);
  assign net_188 = (net_189 | net_190);
  assign net_190 = ~(net_71 | net_2086);
  assign pre_target_mode_iss[2] = (net_191 | net_192);
  assign net_192 = (net_193 | net_194);
  assign net_194 = (net_5 & net_195);
  assign net_195 = (net_196 | net_197);
  assign net_197 = (scr_el3_twe_i & net_198);
  assign net_198 = ~(net_199 | net_200);
  assign net_200 = ~(net_201 | net_202);
  assign net_202 = (net_203 & net_204);
  assign net_201 = ~(net_205 & net_206);
  assign net_206 = ~(net_207 & net_208);
  assign net_205 = (net_209 | net_210);
  assign net_196 = (net_211 | net_212);
  assign net_212 = (net_28 | net_213);
  assign net_213 = (net_214 | net_215);
  assign net_215 = ~(net_216 & net_217);
  assign net_217 = ~(net_218 & dbg_bkpt_wpt_en_rs);
  assign net_216 = (net_219 | net_210);
  assign net_214 = ~(net_220 & net_221);
  assign net_221 = ~(net_16 & net_222);
  assign net_220 = (net_223 | ns_state_rs);
  assign net_193 = (net_225 & net_226);
  assign net_191 = (net_227 | net_228);
  assign net_228 = (net_229 | net_230);
  assign net_230 = ~(net_231 & net_232);
  assign net_232 = ~(net_163 & net_233);
  assign net_233 = (net_234 | net_235);
  assign net_235 = ~(net_236 | net_237);
  assign net_234 = (net_238 & net_239);
  assign net_229 = ~(net_240 | net_241);
  assign net_241 = (net_242 | net_71);
  assign net_240 = ~(net_156 | net_243);
  assign net_243 = (net_2087 & net_244);
  assign net_227 = (net_2090 & net_245);
  assign net_245 = (net_246 | net_247);
  assign net_247 = (net_12 & net_248);
  assign pre_target_mode_iss[4] = (net_249 | net_250);
  assign net_250 = (net_251 | net_252);
  assign net_252 = ~(net_253 & net_254);
  assign net_251 = (net_2090 & net_255);
  assign net_255 = ~(net_256 & net_257);
  assign net_256 = (net_258 & net_259);
  assign net_259 = (expt_instr_type_int_iss[5] | net_260);
  assign net_260 = (net_261 & net_262);
  assign net_261 = (net_263 & net_264);
  assign net_264 = (net_113 | net_265);
  assign net_265 = (net_266 & net_267);
  assign net_267 = ~(net_268 & net_269);
  assign net_269 = ~(net_48 | net_270);
  assign net_266 = (net_271 & net_272);
  assign net_272 = (net_273 & net_274);
  assign net_274 = (net_275 | net_276);
  assign net_276 = (net_177 & net_277);
  assign net_273 = (net_278 | net_279);
  assign net_263 = (net_280 & net_281);
  assign net_281 = (net_282 & net_283);
  assign net_283 = (net_284 | net_285);
  assign net_285 = ~(net_286 | net_51);
  assign net_282 = (net_287 & net_288);
  assign net_288 = (net_289 | net_57);
  assign net_287 = (net_290 & net_291);
  assign net_291 = (net_292 & net_293);
  assign net_293 = (net_162 | net_294);
  assign net_294 = ~(net_30 & net_295);
  assign net_292 = ~(net_51 & net_296);
  assign net_296 = ~(net_136 | net_47);
  assign net_290 = (net_297 | expt_instr_type_int_iss[4]);
  assign net_297 = (net_298 & net_299);
  assign net_299 = (net_300 | net_57);
  assign net_300 = ~(net_125 & hcr_ttlb_i);
  assign net_280 = (net_301 | net_136);
  assign net_301 = (net_302 & net_303);
  assign net_303 = (net_39 | net_304);
  assign net_302 = (net_305 | net_47);
  assign net_305 = (net_306 & net_307);
  assign net_307 = ~(net_308 & net_309);
  assign net_258 = (net_310 & net_311);
  assign net_311 = (net_312 | net_112);
  assign net_312 = (expt_instr_type_int_iss[4] | net_57);
  assign net_310 = (net_313 & net_314);
  assign net_249 = ~(net_315 & net_316);
  assign net_316 = (net_317 & net_318);
  assign net_318 = (net_319 & net_320);
  assign net_320 = ~(net_155 & net_238);
  assign net_155 = ~(net_1 | net_63);
  assign net_319 = (net_321 | net_322);
  assign net_317 = (net_323 & net_324);
  assign net_324 = (net_10 | net_325);
  assign net_323 = (net_326 & net_327);
  assign net_327 = (net_328 & net_329);
  assign net_329 = ~(net_156 & net_330);
  assign net_330 = ~(cntkctl_el1_el0vten_rs | net_331);
  assign net_328 = (net_332 & net_333);
  assign net_326 = ~(net_334 & net_335);
  assign net_335 = ~(net_336 & net_337);
  assign net_337 = (net_56 | l2actlr_el2_i);
  assign net_315 = (net_338 & net_339);
  assign pre_target_mode_iss[0] = ~(net_340 & net_341);
  assign net_341 = (net_342 & net_343);
  assign net_343 = ~(net_2090 & net_344);
  assign net_342 = (net_345 & net_346);
  assign net_346 = ~(net_347 | net_348);
  assign net_348 = ~(net_349 & net_350);
  assign net_350 = ~(net_351 & net_71);
  assign net_349 = (net_352 & net_353);
  assign net_353 = (expt_instr_type_int_iss[6] | net_354);
  assign net_345 = (net_355 & net_356);
  assign net_356 = (net_357 | net_358);
  assign net_355 = (net_359 & net_360);
  assign net_360 = ~(net_156 & net_361);
  assign net_361 = (net_163 & net_362);
  assign net_362 = (net_2086 | net_363);
  assign net_363 = (dpu_exception_level_i[0] & net_71);
  assign net_359 = (net_364 & net_187);
  assign net_187 = ~(net_51 & net_365);
  assign net_365 = ~(net_366 | net_367);
  assign net_364 = (ifu_ifsr_stage2_rs[1] | net_368);
  assign net_368 = (net_369 | net_370);
  assign net_370 = (net_4 | net_371);
  assign net_369 = (external_iabort & net_372);
  assign net_372 = (scr_el3_ea_i | net_373);
  assign net_373 = (net_374 & net_375);
  assign net_384 = (net_12 & net_385);
  assign net_385 = (ifu_ifsr_stage2_rs[1] | net_183);
  assign net_383 = (ns_state_rs & net_386);
  assign net_386 = (net_387 | net_388);
  assign net_388 = (net_389 | net_390);
  assign net_390 = ~(net_391 | net_392);
  assign net_392 = ~(expt_cptr_el2_tfp_rs & net_393);
  assign net_393 = (net_31 & expt_cpacr_el1_fpen_rs[0]);
  assign net_391 = (net_394 & net_395);
  assign net_395 = (net_141 | net_396);
  assign net_396 = ~(fpexc_en_qual & expt_cpacr_el1_fpen_rs[1]);
  assign net_394 = (net_397 | net_61);
  assign net_397 = (net_11 & net_398);
  assign net_398 = ~(fpexc_en_qual & net_399);
  assign net_389 = (net_2086 & net_400);
  assign net_400 = (net_401 | net_402);
  assign net_401 = ~(net_403 & net_404);
  assign net_404 = ~(net_405 & expt_instr_type_int_iss[1]);
  assign net_403 = ~(net_121 & net_12);
  assign net_387 = (net_406 | net_407);
  assign net_407 = ~(net_408 & net_409);
  assign net_409 = (net_8 | net_410);
  assign net_408 = ~(net_411 | net_412);
  assign net_412 = (net_413 | net_414);
  assign net_414 = ~(net_415 & net_416);
  assign net_416 = ~(net_417 & net_132);
  assign net_415 = ~(net_418 & hdcr_tde_i);
  assign net_413 = (net_419 & net_420);
  assign net_420 = (net_126 & net_421);
  assign net_411 = ~(net_422 & net_423);
  assign net_423 = ~(net_424 & net_425);
  assign net_422 = (net_426 | net_86);
  assign net_406 = (net_32 & net_427);
  assign net_427 = ~(net_428 & net_429);
  assign net_428 = (net_106 & net_430);
  assign net_430 = (net_431 | net_432);
  assign net_432 = ~(net_41 & hcr_tdz_i);
  assign net_431 = ~(net_132 & net_433);
  assign net_106 = (net_434 & net_435);
  assign net_435 = ~(net_436 & net_419);
  assign net_436 = ~(cpuectlr_el2_i | net_17);
  assign net_434 = ~(net_16 & hdcr_tde_i);
  assign net_440 = (net_442 & net_443);
  assign net_443 = (net_62 | net_309);
  assign net_442 = (net_444 | net_445);
  assign net_445 = ~(expt_cpacr_el1_fpen_rs[0] & net_446);
  assign net_446 = (dpu_exception_level_i[0] | expt_cpacr_el1_fpen_rs[1]);
  assign net_444 = (net_447 & net_448);
  assign net_448 = (expt_instr_type_int_iss[2] | net_449);
  assign net_447 = (net_450 | expt_cpacr_asedis_rs);
  assign net_450 = (net_451 & net_452);
  assign net_452 = ~(net_375 & net_309);
  assign net_456 = (net_457 | net_458);
  assign net_458 = ~(net_459 & net_231);
  assign net_459 = (net_460 & net_461);
  assign net_461 = ~(sctlr_ntwe_rs & net_462);
  assign net_462 = ~(net_463 | net_464);
  assign net_460 = (net_465 & net_466);
  assign net_466 = ~(net_7 & net_467);
  assign net_467 = ~(net_11 | net_468);
  assign net_468 = ~(net_469 | net_470);
  assign net_470 = ~(net_449 | net_471);
  assign net_471 = ~(expt_cpacr_el1_fpen_rs[0] & dpu_exception_level_i[0]);
  assign net_469 = (cptr_el3_tfp_i & net_472);
  assign net_472 = (net_473 | net_474);
  assign net_465 = (net_475 | net_476);
  assign net_476 = (net_477 | scr_el3_smd_i);
  assign net_477 = (net_478 & net_479);
  assign net_457 = (net_480 | net_481);
  assign net_480 = (net_156 & net_482);
  assign net_482 = ~(net_483 | net_63);
  assign net_455 = (net_484 & net_485);
  assign net_485 = (net_486 | net_487);
  assign net_484 = (net_488 & net_489);
  assign net_491 = ~(net_492 & net_53);
  assign net_492 = ~(net_13 | net_493);
  assign net_490 = ~(net_494 & net_495);
  assign net_501 = ~(net_502 & net_503);
  assign net_503 = (net_63 | net_84);
  assign net_502 = ~(icc_sre_el1_s_sre_qual & net_504);
  assign net_242 = (net_64 | net_483);
  assign net_509 = ~(net_510 & net_511);
  assign net_511 = ~(net_512 & net_2090);
  assign net_512 = ~(net_513 | net_514);
  assign net_514 = ~(mdcr_el3_tda_i & net_515);
  assign net_515 = (net_516 | net_517);
  assign net_510 = ~(net_495 & net_419);
  assign net_519 = (net_520 | net_521);
  assign net_521 = (expt_instr_type_int_iss[6] & net_522);
  assign net_522 = (net_33 & net_164);
  assign net_520 = (net_5 & net_523);
  assign pre_target_el_iss[0] = (net_524 | net_525);
  assign net_525 = (net_526 | net_527);
  assign net_527 = (net_351 | net_528);
  assign net_528 = (net_529 | net_530);
  assign net_530 = ~(net_531 & net_532);
  assign net_532 = (net_533 & net_534);
  assign net_534 = (net_535 | net_536);
  assign net_533 = (net_537 | net_331);
  assign net_331 = (net_358 | net_66);
  assign net_529 = (net_538 & net_539);
  assign net_539 = (net_540 | net_541);
  assign net_541 = ~(net_542 & net_543);
  assign net_542 = ~(net_544 | net_545);
  assign net_545 = ~(net_176 | net_546);
  assign net_546 = (scr_el3_hce_i & net_516);
  assign net_540 = (net_547 & net_548);
  assign net_548 = (net_549 | net_550);
  assign net_550 = ~(net_275 | ns_state_rs);
  assign net_549 = ~(hdcr_tpm_i | net_551);
  assign net_551 = ~(net_552 | net_553);
  assign net_553 = ~(net_40 | hdcr_tpmcr_i);
  assign net_547 = (net_554 & net_555);
  assign net_351 = ~(gic_el2_trap_iss | net_152);
  assign net_152 = ~(net_556 & net_505);
  assign net_526 = (net_7 & net_557);
  assign net_557 = ~(net_558 & net_559);
  assign net_559 = (net_39 | net_560);
  assign net_558 = ~(net_561 | net_562);
  assign net_562 = (net_563 | net_564);
  assign net_564 = ~(net_565 & net_566);
  assign net_566 = ~(net_567 & net_494);
  assign net_565 = ~(net_568 | net_569);
  assign net_569 = ~(net_570 & net_571);
  assign net_571 = (net_572 & net_573);
  assign net_570 = (net_574 & net_575);
  assign net_575 = ~(net_576 & net_577);
  assign net_574 = ~(net_578 & expt_instr_type_int_iss[2]);
  assign net_563 = ~(net_579 & net_580);
  assign net_580 = ~(net_581 & net_582);
  assign net_579 = (net_583 | net_584);
  assign net_561 = (net_585 & net_586);
  assign net_586 = ~(net_587 & net_588);
  assign net_588 = (net_589 & net_306);
  assign net_524 = (net_590 | net_591);
  assign net_591 = (net_592 | net_593);
  assign net_593 = (net_594 | net_595);
  assign net_595 = ~(net_596 & net_597);
  assign net_597 = (net_2090 | net_339);
  assign net_596 = ~(net_347 | net_598);
  assign net_598 = (net_599 | net_600);
  assign net_600 = (net_601 | net_602);
  assign net_602 = ~(net_603 & net_604);
  assign net_604 = (cpuactlr_el3_i | net_605);
  assign net_605 = ~(net_5 & net_606);
  assign net_606 = (net_607 & net_608);
  assign net_608 = (net_54 | net_609);
  assign net_609 = ~(net_61 | net_76);
  assign net_601 = (net_505 & net_610);
  assign net_599 = ~(net_611 & net_612);
  assign net_612 = ~(expt_instr_type_int_iss[0] & net_613);
  assign net_613 = ~(net_614 | net_615);
  assign net_611 = (net_616 | net_617);
  assign net_616 = ~(net_618 & net_9);
  assign net_347 = (net_619 | net_620);
  assign net_620 = ~(net_621 & net_622);
  assign net_622 = ~(net_623 & net_85);
  assign net_623 = (net_556 & net_624);
  assign net_621 = ~(net_5 & net_625);
  assign net_619 = (net_2087 & net_626);
  assign net_626 = ~(net_627 & net_628);
  assign net_628 = (aarch64_at_el3 | net_189);
  assign net_189 = ~(net_163 & net_629);
  assign net_627 = (net_630 & net_631);
  assign net_631 = ~(net_632 & net_538);
  assign net_630 = (net_633 & net_634);
  assign net_634 = ~(net_635 & net_244);
  assign net_633 = (net_636 | monitor_mode);
  assign net_594 = (net_637 & net_638);
  assign net_638 = (net_639 | net_211);
  assign net_211 = (net_576 & net_640);
  assign net_640 = ~(cpuectlr_el3_i | net_641);
  assign net_641 = ~(net_642 | net_643);
  assign net_643 = (expt_instr_type_int_iss[2] & net_504);
  assign net_642 = (net_41 & net_644);
  assign net_644 = (net_494 | net_645);
  assign net_639 = ~(net_357 & net_646);
  assign net_646 = ~(net_26 & net_647);
  assign net_647 = (net_648 | net_649);
  assign net_648 = (scr_el3_twe_i & net_650);
  assign net_650 = (net_651 | net_652);
  assign net_652 = ~(net_59 | expt_instr_type_int_iss[0]);
  assign net_357 = (net_29 & net_653);
  assign net_653 = ~(net_654 & net_222);
  assign net_592 = (net_163 & net_655);
  assign net_655 = ~(net_656 & net_657);
  assign net_657 = ~(net_658 & expt_instr_type_int_iss[5]);
  assign net_658 = (net_659 & net_660);
  assign net_660 = ~(ns_state_rs & net_77);
  assign net_659 = (net_419 & net_661);
  assign net_656 = (net_662 & net_663);
  assign net_662 = (net_664 & net_665);
  assign net_665 = (net_666 & net_667);
  assign net_667 = (net_668 & net_669);
  assign net_669 = (net_670 | net_63);
  assign net_668 = (net_671 & net_18);
  assign net_666 = (net_672 & net_673);
  assign net_673 = (net_55 | net_674);
  assign net_674 = (l2actlr_el3_i | net_675);
  assign net_672 = (net_13 | net_676);
  assign net_676 = ~(cptr_el3_tcpac_i & net_677);
  assign net_677 = ~(net_63 & net_678);
  assign net_678 = (net_61 | expt_cptr_el2_tcpac_rs);
  assign net_664 = (net_679 & net_680);
  assign net_680 = (net_21 | net_681);
  assign net_681 = (net_682 | l2ctlr_el3_i);
  assign net_682 = (net_683 & net_55);
  assign net_683 = (net_684 | net_48);
  assign net_684 = (net_63 & net_685);
  assign net_685 = ~(net_419 & l2ctlr_el2_i);
  assign net_679 = (net_686 & net_687);
  assign net_687 = ~(net_688 & net_63);
  assign net_686 = (net_689 | net_20);
  assign net_590 = ~(net_690 & net_691);
  assign net_691 = ~(aarch64_at_el3 & net_692);
  assign net_692 = (net_693 | net_694);
  assign net_694 = (net_695 | net_696);
  assign net_696 = ~(net_697 & net_698);
  assign net_698 = ~(expt_instr_type_int_iss[0] & net_699);
  assign net_699 = (mdcr_el3_tda_i & net_700);
  assign net_700 = (net_701 | net_702);
  assign net_702 = (net_703 & net_2087);
  assign net_701 = ~(net_704 & net_705);
  assign net_705 = (net_63 | net_614);
  assign net_704 = (net_473 | net_706);
  assign net_706 = (net_707 & net_708);
  assign net_708 = (ns_state_rs | net_614);
  assign net_614 = (net_709 & net_710);
  assign net_707 = (net_711 & net_712);
  assign net_712 = (net_710 | hdcr_tda_i);
  assign net_710 = (net_4 | net_713);
  assign net_711 = (net_709 | hdcr_tdra_i);
  assign net_709 = (net_45 | net_322);
  assign net_697 = (net_55 | net_714);
  assign net_695 = (net_715 & net_716);
  assign net_716 = (net_717 & net_518);
  assign net_693 = (net_494 & net_718);
  assign net_718 = (net_719 | net_9);
  assign net_719 = (net_538 & net_720);
  assign net_720 = (net_721 | net_722);
  assign net_722 = (net_156 & mdcr_el3_tdosa_i);
  assign net_721 = (net_723 & net_14);
  assign net_723 = (net_41 & mdcr_el3_tpm_i);
  assign net_690 = ~(net_724 & net_2090);
  assign net_724 = (net_725 | net_726);
  assign net_726 = (net_344 | net_727);
  assign net_727 = ~(net_728 & net_729);
  assign net_728 = (net_730 & net_731);
  assign net_731 = (net_10 | net_732);
  assign net_732 = ~(net_733 | net_734);
  assign net_733 = (net_735 | net_736);
  assign net_736 = ~(net_175 & net_737);
  assign net_737 = ~(net_738 | net_739);
  assign net_738 = (net_36 & net_248);
  assign net_248 = (net_740 | net_183);
  assign net_740 = ~(ifu_ifsr_stage2_rs[1] | net_741);
  assign net_741 = (net_121 & net_375);
  assign net_121 = (external_iabort & net_374);
  assign net_374 = (hcr_tge_valid & net_69);
  assign net_735 = ~(net_742 | net_743);
  assign net_743 = ~(net_226 & net_268);
  assign net_730 = (net_744 & net_745);
  assign net_745 = (net_746 | net_747);
  assign net_744 = (net_748 & net_749);
  assign net_748 = ~(net_750 & net_239);
  assign net_344 = ~(net_751 & net_752);
  assign net_751 = (net_753 | net_27);
  assign net_753 = (net_219 & net_754);
  assign net_754 = (ns_state_rs | net_755);
  assign net_219 = (hdcr_tde_i | net_756);
  assign net_725 = (net_34 & net_757);
  assign net_757 = (net_758 | net_759);
  assign net_759 = ~(net_760 | net_761);
  assign net_761 = (net_762 & net_763);
  assign net_763 = (net_375 | net_764);
  assign net_764 = ~(net_765 & net_69);
  assign net_762 = (hdcr_tda_i | net_65);
  assign net_758 = (net_766 | net_767);
  assign net_767 = ~(net_768 & net_769);
  assign net_769 = ~(net_770 & net_771);
  assign net_766 = (net_772 & net_773);
  assign net_773 = ~(hdcr_tdosa_i & ns_state_rs);
  assign net_772 = (net_419 & net_774);
  assign net_774 = (net_156 & net_775);
  assign pre_syndrome_type_iss[2] = ~(net_776 & net_777);
  assign net_776 = (net_778 & net_779);
  assign net_779 = ~(net_7 & net_780);
  assign net_780 = (net_781 | net_782);
  assign net_782 = (net_783 | net_784);
  assign net_784 = ~(net_176 | net_785);
  assign net_785 = ~(fpexc_en_qual & net_786);
  assign net_786 = ~(net_787 & net_788);
  assign net_788 = (net_789 & net_790);
  assign net_790 = (expt_instr_type_int_iss[2] | net_791);
  assign net_789 = (net_792 & net_793);
  assign net_793 = (expt_cpacr_asedis_rs | net_794);
  assign net_794 = (net_795 & net_796);
  assign net_795 = (net_473 | net_797);
  assign net_797 = ~(expt_hcptr_tase_rs & net_798);
  assign net_798 = (expt_instr_type_int_iss[2] & ns_state_rs);
  assign net_792 = ~(net_309 & net_494);
  assign net_783 = (net_799 & net_2089);
  assign net_781 = ~(net_800 & net_801);
  assign net_801 = ~(net_425 & net_802);
  assign net_800 = ~(net_803 & net_582);
  assign net_778 = ~(net_381 | net_804);
  assign net_804 = ~(net_805 & net_806);
  assign net_806 = (net_2090 | net_807);
  assign net_805 = ~(net_808 | net_809);
  assign net_809 = ~(net_810 & net_811);
  assign net_811 = (net_1 | net_812);
  assign net_810 = (net_813 & net_814);
  assign net_814 = (net_4 | net_815);
  assign net_815 = (net_816 & net_817);
  assign net_817 = (net_818 | net_819);
  assign net_816 = (net_171 & net_820);
  assign net_813 = (net_821 & net_822);
  assign net_822 = (net_823 & net_824);
  assign net_824 = (net_825 | net_826);
  assign net_825 = (net_358 | net_17);
  assign net_823 = (net_827 & net_828);
  assign net_808 = (net_829 | net_830);
  assign net_830 = ~(net_831 & net_832);
  assign net_832 = (net_833 | net_358);
  assign net_381 = ~(net_834 & net_835);
  assign net_835 = ~(net_2090 & net_836);
  assign net_836 = ~(net_837 & net_838);
  assign net_837 = (net_839 & net_840);
  assign net_840 = ~(net_841 & net_552);
  assign net_839 = (net_842 & net_843);
  assign net_843 = (net_844 | net_845);
  assign net_845 = (net_136 | net_176);
  assign pre_syndrome_type_iss[1] = ~(net_846 & net_828);
  assign net_828 = ~(net_51 & net_847);
  assign net_847 = ~(net_322 | net_176);
  assign net_846 = (net_848 & net_849);
  assign net_849 = ~(net_850 & net_851);
  assign net_850 = ~(net_441 | net_852);
  assign net_852 = ~(net_494 | net_853);
  assign net_853 = (net_78 & net_375);
  assign net_441 = ~(fpexc_en_qual & net_7);
  assign net_848 = ~(net_854 | net_855);
  assign net_854 = ~(net_367 | net_856);
  assign net_856 = ~(net_857 | net_858);
  assign net_858 = (net_799 | net_859);
  assign net_859 = ~(net_860 & net_861);
  assign net_861 = (net_844 | net_47);
  assign net_844 = ~(net_473 & cptr_el3_tfp_i);
  assign net_860 = ~(net_862 & net_38);
  assign net_799 = ~(net_863 & net_864);
  assign net_864 = ~(net_38 & net_865);
  assign net_865 = (net_866 | net_867);
  assign net_867 = ~(net_868 & net_869);
  assign net_869 = (net_69 | net_791);
  assign net_868 = (net_587 & net_870);
  assign net_870 = (expt_cpacr_el1_fpen_rs[0] | net_61);
  assign net_587 = (net_63 | net_79);
  assign net_863 = (net_47 | net_589);
  assign net_857 = (fpexc_en_qual & net_871);
  assign net_871 = (net_872 | net_873);
  assign net_873 = ~(net_44 | net_791);
  assign net_791 = (net_449 & net_796);
  assign net_872 = ~(net_787 | net_47);
  assign net_787 = (net_62 & net_874);
  assign net_874 = (expt_cpacr_asedis_rs | net_451);
  assign pre_syndrome_type_iss[0] = ~(net_875 & net_876);
  assign net_876 = (net_877 & net_878);
  assign net_878 = (expt_instr_type_int_iss[6] | net_879);
  assign net_879 = (net_880 & net_842);
  assign net_842 = (net_881 & net_882);
  assign net_882 = (net_883 & net_884);
  assign net_881 = (net_885 & net_886);
  assign net_885 = ~(net_887 | net_888);
  assign net_888 = ~(net_889 | net_890);
  assign net_890 = ~(net_30 & ns_state_rs);
  assign net_889 = (net_891 & net_892);
  assign net_892 = (net_893 | net_894);
  assign net_891 = (net_895 & net_896);
  assign net_896 = (net_897 & net_898);
  assign net_898 = ~(net_899 & net_204);
  assign net_897 = ~(net_900 & net_552);
  assign net_887 = (net_33 & net_901);
  assign net_901 = ~(net_902 & net_903);
  assign net_880 = (net_904 & net_905);
  assign net_905 = (net_906 & net_907);
  assign net_907 = ~(net_418 | net_908);
  assign net_908 = ~(net_909 & net_910);
  assign net_910 = (net_812 | net_911);
  assign net_909 = (net_912 & net_913);
  assign net_913 = (net_10 | net_914);
  assign net_914 = (net_915 & net_916);
  assign net_916 = (net_917 | net_479);
  assign net_479 = (net_2086 | ns_state_rs);
  assign net_915 = (net_918 & net_919);
  assign net_912 = (net_920 & net_921);
  assign net_418 = ~(net_34 | net_139);
  assign net_906 = (net_922 & net_923);
  assign net_923 = (net_924 | net_925);
  assign net_925 = ~(net_556 & net_30);
  assign net_904 = (net_926 & net_927);
  assign net_927 = (net_928 & net_929);
  assign net_929 = (net_105 | net_930);
  assign net_930 = (net_931 & net_932);
  assign net_932 = ~(net_933 & net_82);
  assign net_931 = (net_934 & net_935);
  assign net_928 = (net_936 | net_513);
  assign net_513 = (net_937 & net_938);
  assign net_938 = (net_818 | net_113);
  assign net_926 = (net_939 & net_940);
  assign net_940 = (net_113 | net_941);
  assign net_941 = (net_942 & net_820);
  assign net_942 = ~(net_943 | net_944);
  assign net_944 = ~(net_945 & net_946);
  assign net_946 = (net_56 | net_947);
  assign net_945 = (net_948 | net_949);
  assign net_948 = (net_950 & net_951);
  assign net_951 = ~(net_41 & net_952);
  assign net_950 = ~(net_544 | net_953);
  assign net_953 = (net_954 & net_955);
  assign net_955 = ~(net_57 | pmu_user_trap_iss);
  assign net_939 = (net_956 & net_957);
  assign net_957 = ~(aarch64_state_rs & net_958);
  assign net_958 = (net_959 | net_960);
  assign net_960 = ~(net_961 | net_962);
  assign net_962 = ~(net_963 | net_964);
  assign net_964 = ~(net_965 | dpu_exception_level_i[1]);
  assign net_963 = ~(net_8 | net_966);
  assign net_959 = (net_31 & net_967);
  assign net_967 = (net_803 & net_968);
  assign net_956 = (net_57 | net_969);
  assign net_877 = (net_970 & net_971);
  assign net_971 = ~(ns_state_rs & net_972);
  assign net_970 = (net_2090 | net_338);
  assign pre_quash_iss = ~(net_973 & net_974);
  assign net_974 = (net_975 & net_976);
  assign net_976 = (expt_instr_type_int_iss[6] | net_977);
  assign net_977 = (net_978 & net_979);
  assign net_979 = (net_980 & net_981);
  assign net_980 = (net_982 & net_983);
  assign net_983 = (net_984 & net_985);
  assign net_985 = (net_986 & net_987);
  assign net_987 = (net_988 | net_819);
  assign net_986 = (net_989 | net_990);
  assign net_984 = (net_991 & net_992);
  assign net_992 = (net_113 | net_993);
  assign net_991 = (net_176 | net_746);
  assign net_746 = (expt_instr_type_int_iss[4] | net_994);
  assign net_994 = (sctlr_el1_dze_rs | net_66);
  assign net_982 = (net_995 & net_838);
  assign net_838 = ~(expt_instr_type_int_iss[5] & net_996);
  assign net_996 = (net_997 & net_952);
  assign net_952 = (net_555 & net_998);
  assign net_998 = (net_554 | net_494);
  assign net_995 = (net_999 & net_1000);
  assign net_1000 = (net_903 | expt_instr_type_int_iss[3]);
  assign net_903 = ~(net_156 & net_1001);
  assign net_999 = (net_1002 & net_1003);
  assign net_978 = (net_1004 & net_1005);
  assign net_1005 = (net_1006 | net_57);
  assign net_1006 = (net_1007 & net_1008);
  assign net_1008 = ~(net_1009 | net_1010);
  assign net_1010 = ~(net_1011 & net_1012);
  assign net_1012 = (net_69 | net_1013);
  assign net_1011 = (net_112 | expt_instr_type_int_iss[4]);
  assign net_1007 = (net_1014 & net_1015);
  assign net_1015 = ~(net_1016 & dpu_exception_level_i[0]);
  assign net_1014 = (net_1017 & net_1018);
  assign net_1018 = ~(net_1019 | net_1020);
  assign net_1020 = ~(net_1021 & net_1022);
  assign net_1022 = (net_11 | net_1023);
  assign net_1017 = (net_1024 & net_1025);
  assign net_1025 = (net_46 | net_1026);
  assign net_1026 = ~(net_1027 | net_126);
  assign net_126 = (net_1028 & hcr_tsc_i);
  assign net_1024 = (net_1029 & net_1030);
  assign net_1030 = (net_176 | net_1031);
  assign net_1031 = ~(net_32 & hcr_tdz_i);
  assign net_1004 = (net_1032 & net_1033);
  assign net_1033 = (net_2087 | net_1034);
  assign net_1032 = (net_1035 & net_1036);
  assign net_1036 = (net_1037 & net_1038);
  assign net_1038 = (net_257 & net_1039);
  assign net_1037 = (net_1040 & net_1041);
  assign net_1035 = (net_1042 & net_1043);
  assign net_1043 = (net_34 | net_1044);
  assign net_1042 = (net_749 & net_1045);
  assign net_1045 = (net_1046 & net_1047);
  assign net_1047 = (net_1048 | net_1049);
  assign net_1046 = (net_1050 & net_1051);
  assign net_1051 = (net_1052 & net_1053);
  assign net_1053 = (net_186 | net_1054);
  assign net_1054 = (net_10 | net_46);
  assign net_186 = ~(scr_el3_smd_i & net_1055);
  assign net_1052 = (net_1056 & net_1057);
  assign net_749 = (net_1058 & net_1059);
  assign net_1059 = ~(net_494 & net_750);
  assign net_975 = (net_1060 & net_1061);
  assign net_1061 = (net_1062 & net_1063);
  assign net_1063 = (net_10 | net_1064);
  assign net_1062 = (net_1065 & net_1066);
  assign net_1066 = (net_1067 & net_1068);
  assign net_1068 = ~(net_495 & net_1069);
  assign net_495 = ~(net_2090 | net_1070);
  assign net_1067 = (net_339 & net_1071);
  assign net_339 = (net_1072 | net_1073);
  assign net_1060 = ~(net_142 | net_1074);
  assign net_1074 = (net_1075 & net_1076);
  assign net_1076 = ~(net_2089 | net_1);
  assign pre_forceop_offset_aa32_iss[0] = ~(net_147 & net_1077);
  assign net_1077 = (net_1078 & net_1079);
  assign net_1079 = (net_1080 & net_1081);
  assign net_1081 = (net_1082 & net_1083);
  assign net_1083 = (net_358 | net_1084);
  assign net_1082 = (net_603 & net_827);
  assign net_827 = ~(net_1085 & net_1086);
  assign net_1086 = (net_1087 & net_1088);
  assign net_603 = (net_10 | net_1089);
  assign net_1080 = (net_1090 & net_1091);
  assign net_1091 = (net_1092 & net_1093);
  assign net_1093 = ~(net_1094 & net_556);
  assign net_1092 = (net_1095 & net_1096);
  assign net_1096 = ~(net_489 & net_1097);
  assign net_489 = ~(net_14 | net_4);
  assign net_1095 = (net_463 | net_742);
  assign net_463 = ~(net_26 & net_1098);
  assign net_1090 = (net_1099 & net_333);
  assign net_1099 = (net_1100 & net_1101);
  assign net_1101 = (net_68 | net_150);
  assign net_1100 = (net_56 | net_1102);
  assign net_1078 = (net_1103 & net_1104);
  assign net_1103 = (net_1105 & net_1106);
  assign net_1106 = (expt_instr_type_int_iss[6] | net_1107);
  assign net_1107 = (net_1108 & net_729);
  assign net_1108 = (net_1109 & net_1110);
  assign net_1109 = (net_1111 & net_354);
  assign net_354 = (net_1112 & net_1113);
  assign net_1113 = ~(net_1114 & net_1028);
  assign net_1112 = (net_1115 & net_1116);
  assign net_1116 = (net_113 | net_1117);
  assign net_1115 = (net_1118 & net_1119);
  assign net_1105 = (net_1120 & net_1121);
  assign net_1121 = (net_1122 | net_367);
  assign net_367 = (net_322 | expt_instr_type_int_iss[5]);
  assign net_147 = (net_340 & net_1123);
  assign net_1123 = ~(net_1124 | net_1125);
  assign net_1125 = ~(dbg_hlt_en_rs | net_1126);
  assign net_1126 = ~(net_1127 & net_5);
  assign net_1124 = (net_1128 | net_829);
  assign net_829 = (net_1129 & net_2090);
  assign net_1129 = ~(net_2089 | net_313);
  assign net_1128 = ~(net_1130 | net_1131);
  assign net_1131 = ~(net_7 & net_851);
  assign net_340 = (net_1132 & net_1133);
  assign net_1133 = (net_1134 | expt_instr_type_int_iss[6]);
  assign net_1134 = (net_1135 & net_1136);
  assign net_1136 = (net_911 | net_1137);
  assign net_1135 = (net_1138 & net_1139);
  assign net_1139 = (net_1140 & net_1141);
  assign net_1138 = (net_1142 & net_1143);
  assign net_1142 = (net_1144 & net_1145);
  assign net_1145 = ~(net_494 & net_1146);
  assign net_1146 = (net_851 & net_31);
  assign net_1132 = (net_1147 | net_535);
  assign net_1147 = (net_1148 & net_1149);
  assign net_1149 = ~(net_1150 & net_1151);
  assign net_1148 = (net_1152 & net_1153);
  assign net_1153 = ~(net_1154 & net_1155);
  assign net_1155 = ~(net_63 | icc_sre_el2_sre_qual);
  assign pre_expt_vec_offset_iss[4] = ~(net_1156 & net_1065);
  assign net_1065 = (net_56 | net_1157);
  assign net_1156 = (net_1158 & net_1159);
  assign net_1159 = ~(net_163 & net_1160);
  assign net_1158 = ~(net_481 | net_1161);
  assign net_1161 = (net_1162 & net_1163);
  assign net_1163 = (net_1164 | net_1165);
  assign net_1164 = ~(net_1166 & net_1167);
  assign net_1167 = (net_410 | expt_instr_type_int_iss[5]);
  assign net_410 = (expt_instr_type_int_iss[4] | net_1168);
  assign net_1168 = (net_1169 & net_1170);
  assign net_1170 = (net_1171 | net_1172);
  assign net_1172 = ~(sctlr_ntwi_rs & net_1173);
  assign net_1169 = (net_1174 | net_34);
  assign net_1174 = (net_1175 & net_1176);
  assign net_1176 = ~(net_1177 & hdcr_tde_i);
  assign net_1175 = ~(net_1178 | net_1179);
  assign net_1179 = ~(net_199 | net_1180);
  assign net_1180 = ~(net_1181 & hcr_twe_i);
  assign net_1166 = ~(net_1182 | net_1183);
  assign net_1183 = ~(net_1184 & net_1185);
  assign net_1185 = ~(net_424 & net_164);
  assign net_424 = (net_1186 & net_68);
  assign net_1184 = (net_1187 & net_1021);
  assign net_1021 = ~(net_30 & net_1188);
  assign net_1187 = ~(net_402 | net_1189);
  assign net_1189 = ~(net_1190 | net_1191);
  assign net_1191 = (net_210 | net_911);
  assign net_402 = ~(net_23 | net_1192);
  assign net_1192 = ~(net_33 & net_1193);
  assign net_1193 = (net_1194 | net_1195);
  assign net_1195 = ~(cnthctl_el2_el1pcen_rs | net_1196);
  assign net_1196 = ~(expt_instr_type_int_iss[0] & net_1197);
  assign net_1197 = (dpu_exception_level_i[0] | cntkctl_el1_el0pten_rs);
  assign net_1194 = ~(cnthctl_el2_el1pcten_rs | net_1198);
  assign net_1198 = ~(net_2088 & net_1199);
  assign net_1199 = (dpu_exception_level_i[0] | cntkctl_el1_el0pcten_rs);
  assign net_1182 = (expt_instr_type_int_iss[0] & net_1200);
  assign net_1200 = (net_405 | net_1201);
  assign net_1201 = (net_417 & net_2089);
  assign net_417 = (net_30 & net_1202);
  assign net_405 = ~(net_1203 | net_1204);
  assign net_1204 = ~(hdcr_tda_i & net_68);
  assign net_1162 = ~(expt_instr_type_int_iss[6] | net_57);
  assign net_481 = ~(net_1205 & net_1206);
  assign net_1206 = ~(net_1207 & net_538);
  assign net_1207 = (net_943 & net_68);
  assign net_943 = ~(net_818 | net_771);
  assign net_1205 = ~(net_1208 & gic_el2_trap_iss);
  assign net_1208 = (net_624 & net_500);
  assign net_500 = (icc_sre_el1_ns_sre_qual & net_556);
  assign pre_expt_vec_offset_iss[3] = ~(net_1209 & net_1210);
  assign net_1210 = (net_139 | net_6);
  assign net_1209 = ~(net_855 | net_1211);
  assign net_1211 = (net_5 & net_1212);
  assign net_1212 = ~(net_1213 & net_429);
  assign net_1213 = (net_1214 & net_1215);
  assign net_1215 = (hdcr_tde_i | net_141);
  assign net_1214 = (net_1216 & net_1217);
  assign net_1217 = ~(net_399 & net_2087);
  assign net_855 = (net_178 & net_1218);
  assign net_1218 = ~(net_1219 & net_918);
  assign net_918 = (net_1220 & net_1221);
  assign net_1220 = ~(net_1222 & net_1223);
  assign net_1222 = ~(net_1224 & net_1225);
  assign net_1225 = (net_478 | scr_el3_smd_i);
  assign pre_expt_vec_offset_iss[2] = ~(net_253 & net_1226);
  assign net_1226 = (net_1227 & net_1228);
  assign net_1228 = (expt_instr_type_int_iss[6] | net_1229);
  assign net_1229 = ~(net_1230 | net_1231);
  assign net_1231 = ~(net_1111 & net_1232);
  assign net_1232 = (net_1040 & net_1233);
  assign net_1040 = (net_1234 & net_1144);
  assign net_1144 = ~(net_80 & net_137);
  assign net_1234 = (net_1118 & net_1235);
  assign net_1235 = (net_113 | net_1236);
  assign net_1236 = (net_171 & net_1237);
  assign net_1237 = (in_halt_rs | net_1238);
  assign net_1238 = (net_1239 | net_1240);
  assign net_1240 = ~(expt_instr_type_int_iss[1] & net_949);
  assign net_171 = ~(expt_instr_type_int_iss[5] & net_544);
  assign net_1118 = (net_1241 & net_1242);
  assign net_1242 = (net_755 | net_1243);
  assign net_1243 = ~(net_1028 & net_1244);
  assign net_1241 = ~(net_137 & net_1245);
  assign net_137 = ~(net_113 | net_176);
  assign net_1111 = (net_1246 & net_1247);
  assign net_1247 = ~(net_1248 & net_1249);
  assign net_1248 = ~(net_1250 | net_57);
  assign net_1250 = (net_1251 & net_1252);
  assign net_1252 = ~(net_1181 & hcr_tge_i);
  assign net_1251 = (net_1253 | net_69);
  assign net_1253 = (net_1254 & net_1255);
  assign net_1255 = (net_1256 | l2ctlr_el2_i);
  assign net_1254 = (l2actlr_el2_i | net_39);
  assign net_1246 = (net_883 & net_1257);
  assign net_1257 = (net_1057 & net_1258);
  assign net_1258 = (net_426 | net_1259);
  assign net_1259 = (net_1260 & net_1261);
  assign net_426 = ~(net_30 & net_629);
  assign net_629 = (expt_instr_type_int_iss[0] & net_244);
  assign net_1057 = ~(net_1262 & net_2087);
  assign net_1262 = (net_33 & net_632);
  assign net_883 = (net_1263 | net_478);
  assign net_1263 = (net_1264 & net_1265);
  assign net_1265 = (net_237 | net_911);
  assign net_237 = ~(net_576 & net_1266);
  assign net_1266 = ~(net_1267 & net_1268);
  assign net_1268 = (net_184 | l2ctlr_el3_i);
  assign net_1267 = (net_275 | l2actlr_el3_i);
  assign net_1227 = (net_89 & net_1269);
  assign net_1269 = (net_1270 & net_1271);
  assign net_1271 = (net_1071 & net_831);
  assign net_831 = ~(net_538 & net_1272);
  assign net_1272 = ~(net_57 | net_112);
  assign net_1071 = ~(net_1273 & net_1274);
  assign net_1270 = (net_1275 & net_1276);
  assign net_1275 = (net_1277 & net_1278);
  assign net_1278 = (net_1 | net_1279);
  assign net_1279 = (net_1137 & net_1280);
  assign net_1280 = ~(net_375 & net_1188);
  assign net_1188 = (net_949 & net_1281);
  assign net_1137 = (net_1282 & net_671);
  assign net_671 = ~(net_86 & net_244);
  assign net_1282 = (net_1283 & net_1284);
  assign net_1284 = ~(net_803 & edscr_sdd_i);
  assign net_1283 = ~(net_1285 & net_2088);
  assign net_1277 = ~(net_178 & net_1114);
  assign net_1114 = (scr_el3_smd_i & net_734);
  assign net_734 = (net_125 & net_1286);
  assign net_89 = (net_834 & net_1287);
  assign net_1287 = (net_333 | net_2090);
  assign net_333 = (net_1288 | net_636);
  assign net_1288 = (net_56 & net_1289);
  assign net_1289 = (net_1290 & net_63);
  assign net_834 = ~(ns_state_rs & net_1291);
  assign net_1291 = (net_1292 | net_1293);
  assign net_1293 = (net_419 & net_1294);
  assign net_1294 = ~(net_1102 & net_1157);
  assign net_1157 = ~(expt_instr_type_int_iss[6] & net_1094);
  assign net_1102 = (net_1295 & net_1296);
  assign net_1296 = (net_1 | net_924);
  assign net_924 = ~(net_77 & net_1297);
  assign net_1292 = (net_2086 & net_1298);
  assign net_1298 = (net_1165 & net_2090);
  assign net_1165 = (net_1009 | net_1299);
  assign net_1299 = ~(net_1300 & net_1301);
  assign net_1301 = ~(net_1302 & net_33);
  assign net_1302 = ~(net_69 | net_947);
  assign net_1300 = (net_969 & net_1303);
  assign net_1303 = ~(net_1027 & net_421);
  assign net_1027 = (net_1304 & net_2089);
  assign net_969 = ~(net_1019 & net_2089);
  assign net_1019 = (net_30 & net_1305);
  assign net_1009 = ~(net_1306 & net_1307);
  assign net_1307 = (net_1308 | expt_instr_type_int_iss[5]);
  assign net_1308 = ~(net_1223 & net_1309);
  assign net_1309 = (net_1310 | net_1311);
  assign net_1311 = (net_30 & net_1312);
  assign net_1312 = (net_1313 | net_1314);
  assign net_1314 = (hcr_tid1_i & net_48);
  assign net_1313 = (expt_instr_type_int_iss[1] & hcr_tid3_i);
  assign net_1310 = (net_32 & net_1315);
  assign net_1315 = ~(expt_instr_type_int_iss[1] | net_1316);
  assign net_1306 = (net_1317 | pmu_user_trap_iss);
  assign net_1317 = ~(net_33 & net_1318);
  assign net_1318 = (expt_instr_type_int_iss[5] & net_1319);
  assign net_1319 = (net_954 | net_1320);
  assign net_1320 = (net_739 & hdcr_tpmcr_i);
  assign net_253 = (net_1321 & net_1322);
  assign net_1322 = (net_1323 | aarch64_at_el3);
  assign net_1323 = (net_1324 | net_1325);
  assign net_1324 = (net_56 & net_1326);
  assign net_1326 = (net_2086 | net_1327);
  assign net_1321 = (net_1328 & net_1329);
  assign net_1329 = (net_1330 | expt_instr_type_int_iss[6]);
  assign net_1330 = ~(net_1331 | net_1332);
  assign net_1332 = ~(net_105 | net_1044);
  assign net_1331 = (net_1333 | net_1334);
  assign net_1334 = (net_1335 | net_122);
  assign net_122 = ~(net_10 | net_184);
  assign net_1335 = (net_33 & net_1336);
  assign net_1336 = ~(net_371 & net_1337);
  assign net_1337 = (net_1338 | net_174);
  assign net_1338 = (net_175 & net_1339);
  assign net_1339 = (net_184 | in_halt_rs);
  assign net_1333 = ~(net_13 | net_1340);
  assign net_1340 = ~(net_375 & net_1186);
  assign pre_expt_type_iss[4] = ~(net_1341 & net_1342);
  assign net_1342 = ~(scr_el3_smd_i & net_1343);
  assign net_1341 = (net_1344 & net_1345);
  assign net_1345 = ~(net_16 & net_7);
  assign net_1344 = (net_1346 | net_1347);
  assign net_1347 = (net_1072 | expt_instr_type_int_iss[6]);
  assign pre_expt_type_iss[3] = ~(net_1348 & net_1349);
  assign net_1348 = ~(net_142 | net_1350);
  assign net_1350 = ~(net_1351 & net_1352);
  assign net_1351 = (net_875 & net_1353);
  assign net_1353 = (expt_instr_type_int_iss[6] | net_1354);
  assign net_1354 = (net_1355 & net_1356);
  assign net_1356 = (net_1357 & net_1233);
  assign net_1233 = (net_1358 & net_1359);
  assign net_1359 = (net_257 & net_1141);
  assign net_1141 = (net_1360 & net_1361);
  assign net_1360 = (net_1362 | net_136);
  assign net_1362 = (net_1363 & net_1364);
  assign net_1364 = (net_1365 & net_321);
  assign net_321 = ~(expt_instr_type_int_iss[5] & net_1366);
  assign net_1366 = ~(net_1367 & net_1368);
  assign net_1368 = ~(net_739 & sctlr_sed_rs);
  assign net_1367 = (net_1256 | sctlr_cp15ben_rs);
  assign net_1365 = (net_1369 & net_1370);
  assign net_1370 = (net_304 | net_747);
  assign net_747 = (net_14 | net_275);
  assign net_1369 = (net_306 | net_176);
  assign net_257 = (net_1371 & net_1372);
  assign net_1371 = (net_1373 & net_1374);
  assign net_1374 = (net_1375 | net_34);
  assign net_1375 = (net_1376 & net_1377);
  assign net_1377 = ~(net_399 & net_58);
  assign net_1358 = (net_1378 & net_1379);
  assign net_1379 = (net_1380 | net_136);
  assign net_1380 = (net_1381 & net_1382);
  assign net_1382 = ~(net_851 & net_308);
  assign net_851 = ~(net_35 | net_176);
  assign net_176 = (net_14 | expt_instr_type_int_iss[1]);
  assign net_309 = ~(net_79 & net_1383);
  assign net_1383 = ~(expt_hcptr_tase_rs & expt_instr_type_int_iss[2]);
  assign net_1381 = (net_1384 & net_1385);
  assign net_1385 = (expt_instr_type_int_iss[5] | net_1122);
  assign net_1122 = (net_1386 & net_1387);
  assign net_1387 = (net_449 | net_175);
  assign net_1386 = (net_1388 & net_1389);
  assign net_1389 = (net_451 | net_47);
  assign net_1388 = (net_583 | net_366);
  assign net_366 = (net_298 & net_47);
  assign net_1378 = (net_1390 & net_1391);
  assign net_1391 = (net_1392 & net_1393);
  assign net_1392 = (net_1394 & net_921);
  assign net_921 = ~(net_1395 & net_688);
  assign net_688 = ~(net_21 | expt_instr_type_int_iss[0]);
  assign net_1395 = ~(net_1396 | net_1397);
  assign net_1396 = (net_1398 & net_1399);
  assign net_1399 = (net_1400 | cntkctl_el1_el0pcten_rs);
  assign net_1400 = ~(net_82 & expt_instr_type_int_iss[1]);
  assign net_1398 = (expt_instr_type_int_iss[1] | cntkctl_el1_el0vten_rs);
  assign net_1394 = (net_1401 | net_105);
  assign net_1401 = (net_1216 & net_1402);
  assign net_1402 = (net_23 | dbg_hlt_en_rs);
  assign net_1390 = (net_1003 & net_139);
  assign net_139 = (net_25 | dbg_bkpt_wpt_en_rs);
  assign net_1003 = (net_884 & net_1404);
  assign net_1404 = (net_1405 | net_1406);
  assign net_1357 = (net_1407 & net_1408);
  assign net_1408 = (net_10 | net_1409);
  assign net_1409 = (net_1410 & net_1411);
  assign net_1411 = (net_1412 & net_1413);
  assign net_1413 = ~(net_36 & net_1346);
  assign net_1412 = (net_1414 & net_1415);
  assign net_1415 = (net_1416 & net_1417);
  assign net_1417 = (net_279 | net_1418);
  assign net_1418 = (net_1419 & net_1420);
  assign net_1420 = ~(expt_instr_type_int_iss[0] & net_2086);
  assign net_1419 = (net_277 & net_270);
  assign net_1416 = (net_1421 & net_1422);
  assign net_1422 = (net_175 & net_1423);
  assign net_1423 = (net_130 | net_1424);
  assign net_1424 = ~(expt_instr_type_int_iss[0] & net_375);
  assign net_130 = ~(expt_instr_type_int_iss[2] & net_1173);
  assign net_1173 = (hcr_twi_i & net_86);
  assign net_1410 = (net_1425 & net_1426);
  assign net_1426 = ~(net_295 & net_1427);
  assign net_1425 = (net_917 | dpu_exception_level_i[1]);
  assign net_1407 = ~(net_1428 | net_1429);
  assign net_1429 = ~(net_1430 & net_1431);
  assign net_1431 = (net_65 | net_937);
  assign net_937 = (net_1432 | net_48);
  assign net_1432 = (net_1203 & net_1433);
  assign net_1433 = ~(net_949 & net_1434);
  assign net_1203 = (net_113 | net_19);
  assign net_1430 = (net_1435 | net_34);
  assign net_1435 = ~(net_1230 | net_1436);
  assign net_1436 = ~(net_57 | net_117);
  assign net_117 = ~(net_26 & hcr_twe_i);
  assign net_1355 = (net_1437 & net_1438);
  assign net_1437 = (net_1439 & net_1440);
  assign net_1440 = (expt_instr_type_int_iss[3] | net_768);
  assign net_768 = (net_1441 & net_1442);
  assign net_1442 = (net_760 | net_615);
  assign net_760 = ~(net_1443 & net_1444);
  assign net_1444 = (net_1445 | net_2088);
  assign net_1441 = (net_902 & net_812);
  assign net_902 = (net_1446 | net_18);
  assign net_1439 = (net_1050 & net_1447);
  assign net_1447 = (net_1448 & net_1449);
  assign net_1449 = (net_1450 & net_1451);
  assign net_1450 = (net_1452 & net_1453);
  assign net_1453 = ~(net_1454 & net_1297);
  assign net_1452 = (net_1455 & net_1456);
  assign net_1456 = (net_920 & net_1457);
  assign net_1457 = ~(net_30 & net_1458);
  assign net_1458 = (net_238 & net_494);
  assign net_920 = ~(net_1459 & net_841);
  assign net_841 = ~(net_105 | net_1460);
  assign net_1448 = (net_1461 & net_886);
  assign net_1461 = (net_1462 | net_18);
  assign net_1462 = (net_1463 & net_1464);
  assign net_1464 = (net_771 | expt_instr_type_int_iss[3]);
  assign net_1050 = (net_1465 & net_1466);
  assign net_1466 = (net_44 | net_1467);
  assign net_1467 = (net_113 | net_819);
  assign net_1465 = (net_1468 & net_1469);
  assign net_1469 = (net_675 | net_1470);
  assign net_1470 = (net_336 | net_911);
  assign net_336 = (l2actlr_el3_i | net_61);
  assign net_875 = (net_1471 & net_1472);
  assign net_1471 = (net_1473 & net_1474);
  assign net_1474 = (net_714 | net_1475);
  assign net_1475 = (net_61 | net_71);
  assign net_1473 = (net_1476 & net_1477);
  assign net_1477 = (net_2087 | net_1478);
  assign net_1478 = (net_1479 & net_1480);
  assign net_1480 = (net_61 | net_1481);
  assign net_1481 = (net_1482 & net_1483);
  assign net_1483 = ~(net_1459 & net_1484);
  assign net_1484 = ~(cpuectlr_el2_i | net_358);
  assign net_1482 = (net_1295 & net_714);
  assign net_714 = ~(net_9 | net_1485);
  assign net_1485 = ~(net_1256 | net_1486);
  assign net_1486 = ~(gic_el3_trap_iss & net_1487);
  assign net_1295 = ~(net_5 & net_1488);
  assign net_1488 = (net_76 & net_1297);
  assign net_1479 = (net_1489 & net_1490);
  assign net_1490 = ~(net_1491 | net_1492);
  assign net_1492 = ~(net_1493 & net_1494);
  assign net_1494 = (net_150 | net_72);
  assign net_150 = ~(expt_instr_type_int_iss[1] & net_703);
  assign net_1489 = ~(net_1495 | net_1496);
  assign net_1496 = (net_421 & net_1497);
  assign net_1497 = ~(net_8 | net_1498);
  assign net_1498 = (net_1499 & net_1500);
  assign net_1500 = ~(hcr_tid3_i & net_163);
  assign net_1499 = ~(net_5 & hcr_ttlb_i);
  assign net_1495 = ~(net_1501 | net_112);
  assign net_112 = (cnthctl_el2_el1pcten_rs | net_29);
  assign net_1476 = ~(net_9 & net_1502);
  assign net_142 = (ns_state_rs & net_1503);
  assign net_1503 = (net_1504 | net_1505);
  assign net_1505 = (net_1506 | net_1507);
  assign net_1507 = (net_900 & net_334);
  assign net_334 = ~(net_1 | net_675);
  assign net_675 = ~(net_576 & net_48);
  assign net_900 = ~(l2actlr_el2_i | net_61);
  assign net_1506 = (net_1087 & net_1508);
  assign net_1508 = (hcr_tacr_i & net_1509);
  assign net_1509 = (net_34 & net_38);
  assign net_1504 = (net_635 & net_1510);
  assign net_1510 = (hcr_tsw_i & net_1177);
  assign pre_expt_type_iss[2] = ~(net_1511 & net_821);
  assign net_821 = (expt_instr_type_int_iss[6] | net_1512);
  assign net_1512 = ~(net_1445 & net_1513);
  assign net_1513 = ~(net_1514 | expt_instr_type_int_iss[5]);
  assign net_1514 = (net_1515 & net_1516);
  assign net_1516 = (net_1517 | net_1518);
  assign net_1518 = ~(expt_instr_type_int_iss[3] & net_1181);
  assign net_1515 = (net_1239 | net_1171);
  assign net_1239 = ~(net_1519 | net_1520);
  assign net_1520 = ~(sctlr_ntwi_rs & net_1521);
  assign net_1521 = ~(scr_el3_twi_i & net_53);
  assign net_1511 = ~(pre_enter_halt_iss | net_1522);
  assign net_1522 = (net_81 & net_1343);
  assign net_1343 = ~(net_475 | net_1224);
  assign net_1224 = ~(net_556 & hcr_tsc_i);
  assign net_475 = ~(net_421 & net_178);
  assign pre_expt_type_iss[1] = ~(net_1523 & net_254);
  assign net_254 = (net_1352 & net_1524);
  assign net_1524 = (net_1 | net_1525);
  assign net_1523 = (net_1526 & net_1527);
  assign net_1527 = ~(net_1528 & net_2090);
  assign net_1528 = ~(net_1529 & net_1530);
  assign net_1530 = (net_833 | expt_instr_type_int_iss[4]);
  assign net_833 = ~(net_1531 & net_1532);
  assign net_1529 = (net_1533 & net_1534);
  assign net_1526 = (net_1535 & net_1536);
  assign net_1536 = (net_777 & net_531);
  assign net_531 = (net_1349 & net_1537);
  assign net_1537 = ~(net_1085 & net_1538);
  assign net_777 = (net_1539 & net_165);
  assign net_165 = (net_1540 | net_2087);
  assign net_1540 = (net_1541 & net_1542);
  assign net_1542 = (net_1501 | net_1543);
  assign net_1541 = (net_1493 & net_1544);
  assign net_1544 = ~(net_1538 & net_1545);
  assign net_1538 = (net_5 & net_425);
  assign net_425 = ~(net_15 | net_45);
  assign net_1493 = ~(expt_instr_type_int_iss[1] & net_1546);
  assign net_1546 = (net_132 & net_1547);
  assign net_1547 = (net_1548 | net_1549);
  assign net_1549 = (hdcr_tdra_i & net_1550);
  assign net_1548 = ~(expt_instr_type_int_iss[2] | net_1551);
  assign net_1551 = ~(net_1552 | net_1553);
  assign net_1553 = (hcr_tid0_i & net_163);
  assign net_1552 = (net_1554 & net_1555);
  assign net_1555 = ~(net_2090 | net_69);
  assign net_1554 = (net_33 & net_1556);
  assign net_1539 = (net_1557 & net_1558);
  assign net_1558 = (expt_instr_type_int_iss[6] | net_1559);
  assign net_1559 = (net_1560 & net_1561);
  assign net_1561 = (net_113 | net_1562);
  assign net_1560 = (net_1563 & net_1564);
  assign net_1564 = (net_1565 | net_136);
  assign net_1565 = (net_1566 & net_1567);
  assign net_1567 = ~(net_164 & net_1568);
  assign net_1566 = ~(net_862 & net_218);
  assign net_1557 = (net_1472 & net_1569);
  assign net_1569 = (net_1570 & net_1571);
  assign net_1571 = ~(net_1572 & expt_instr_type_int_iss[0]);
  assign net_1572 = (net_1573 & net_1285);
  assign net_1573 = ~(net_4 | net_819);
  assign net_1570 = ~(net_505 & net_618);
  assign net_1472 = (net_1574 | net_535);
  assign net_1574 = (net_1575 & net_1576);
  assign net_1576 = ~(net_1577 & expt_instr_type_int_iss[2]);
  assign net_1575 = (net_1152 & net_1578);
  assign net_1578 = ~(net_1150 & net_610);
  assign net_1150 = (gic_el3_trap_iss & net_37);
  assign net_1535 = (net_1579 & net_1580);
  assign net_1580 = (net_1581 | net_4);
  assign net_1581 = (net_1582 & net_1583);
  assign net_1583 = (net_298 | net_1584);
  assign net_1582 = (net_1585 & net_1586);
  assign net_1586 = (net_175 | net_819);
  assign net_1585 = (net_371 | net_1346);
  assign net_1346 = ~(iabort_alignment & net_1587);
  assign net_1587 = ~(external_iabort | ifu_ifsr_stage2_rs[1]);
  assign net_371 = (expt_instr_type_int_iss[2] | net_14);
  assign net_1579 = (net_1588 & net_1589);
  assign net_1589 = ~(net_7 & net_1590);
  assign net_1590 = ~(net_1591 & net_1384);
  assign net_1384 = ~(net_218 & net_286);
  assign net_286 = ~(net_1592 & net_796);
  assign net_796 = (net_79 | net_57);
  assign net_1591 = (net_1593 & net_1594);
  assign net_1594 = ~(net_582 & net_38);
  assign net_1593 = (net_1363 & net_1595);
  assign net_1595 = (net_1596 & net_1597);
  assign net_1597 = ~(net_578 & net_41);
  assign net_578 = (expt_instr_type_int_iss[5] & sctlr_sed_rs);
  assign net_1596 = ~(net_1598 & net_585);
  assign net_1588 = (net_1599 & net_1600);
  assign net_1600 = (net_663 | net_1);
  assign net_663 = ~(net_1181 & net_1601);
  assign net_1599 = (net_1104 & net_1602);
  assign net_1104 = ~(net_717 & net_1230);
  assign net_1230 = (net_715 & net_1577);
  assign net_717 = ~(net_48 | net_6);
  assign pre_expt_type_iss[0] = ~(net_1603 & net_1604);
  assign net_1604 = (net_1605 & net_1606);
  assign net_1606 = ~(net_178 & net_1607);
  assign net_1607 = ~(net_1608 & net_1609);
  assign net_1609 = (net_917 | net_1610);
  assign net_1608 = (net_1221 & net_1219);
  assign net_1219 = (net_1611 & net_1612);
  assign net_1612 = (net_917 | net_689);
  assign net_917 = ~(net_81 & net_1223);
  assign net_1611 = (net_1256 & net_919);
  assign net_919 = (net_40 & net_1613);
  assign net_1613 = ~(net_488 & net_486);
  assign net_1221 = ~(net_488 & net_487);
  assign net_487 = (ns_state_rs & net_516);
  assign net_488 = (net_41 & scr_el3_hce_i);
  assign net_178 = ~(net_10 | expt_instr_type_int_iss[6]);
  assign net_1605 = (net_483 | net_1614);
  assign net_1614 = (net_1615 & net_1616);
  assign net_1616 = ~(net_156 & net_1617);
  assign net_1617 = ~(hcr_tge_i & net_375);
  assign net_1615 = (net_1618 | net_20);
  assign net_1618 = (net_1619 & net_1620);
  assign net_1620 = ~(ns_state_rs & expt_instr_type_int_iss[0]);
  assign net_1619 = (net_71 | net_64);
  assign net_1603 = ~(net_1621 | net_1622);
  assign net_1622 = ~(net_1623 & net_1624);
  assign net_1624 = (net_1625 & net_1626);
  assign net_1626 = ~(net_1627 & net_1628);
  assign net_1628 = ~(expt_instr_type_int_iss[0] | net_1517);
  assign net_1517 = (sctlr_ntwe_rs & net_1629);
  assign net_1629 = (net_1630 & net_1631);
  assign net_1631 = ~(scr_el3_twe_i & net_53);
  assign net_1630 = ~(hcr_twe_i & net_375);
  assign net_1623 = (net_1632 & net_231);
  assign net_231 = ~(net_803 & net_1633);
  assign net_1633 = ~(edscr_sdd_i | net_483);
  assign net_483 = (net_1 | net_86);
  assign net_1632 = ~(net_1634 | net_1635);
  assign net_1635 = ~(net_322 | net_1636);
  assign net_1636 = ~(net_1459 | net_654);
  assign pre_exception_valid_iss = ~(net_1637 & net_1352);
  assign net_1352 = ~(ns_state_rs & net_1638);
  assign net_1638 = ~(net_1639 & net_1640);
  assign net_1640 = (expt_instr_type_int_iss[6] | net_1641);
  assign net_1641 = (net_1642 & net_1643);
  assign net_1643 = (net_61 | net_1013);
  assign net_1013 = (expt_instr_type_int_iss[3] | net_947);
  assign net_947 = ~(net_156 & hdcr_tdosa_i);
  assign net_156 = (net_2088 & net_244);
  assign net_1642 = (net_94 & net_1034);
  assign net_94 = (expt_instr_type_int_iss[3] | net_895);
  assign net_895 = ~(net_132 & net_1281);
  assign net_1281 = (net_41 & net_1644);
  assign net_1644 = (hcr_tid2_i & net_1645);
  assign net_1639 = ~(net_972 | net_1646);
  assign net_1646 = ~(net_1647 & net_1648);
  assign net_1648 = ~(net_1649 & net_954);
  assign net_954 = (net_41 & hdcr_tpm_i);
  assign net_1647 = ~(net_1305 & net_635);
  assign net_635 = (net_2086 & net_163);
  assign net_1305 = (net_1650 & net_961);
  assign net_1650 = (net_1181 & hcr_tpc_i);
  assign net_972 = ~(net_1651 & net_1652);
  assign net_1652 = ~(net_419 & net_1094);
  assign net_1094 = ~(net_83 | net_1653);
  assign net_1651 = (net_1654 | net_40);
  assign net_1654 = (net_1655 & net_1656);
  assign net_1656 = ~(net_1649 & hdcr_tpmcr_i);
  assign net_1649 = (net_554 & net_538);
  assign net_1655 = ~(net_1087 & net_1657);
  assign net_1657 = ~(net_1658 & net_1659);
  assign net_1659 = ~(hcr_tid1_i & net_34);
  assign net_1658 = (expt_instr_type_int_iss[4] | net_1316);
  assign net_1316 = (net_1660 & net_1661);
  assign net_1661 = ~(hcr_trvm_i & mcr_mrc_type_iss);
  assign net_1660 = (net_74 | mcr_mrc_type_iss);
  assign net_1087 = (net_2090 & net_204);
  assign net_1637 = (net_1662 & net_1663);
  assign net_1663 = (expt_instr_type_int_iss[6] | net_1664);
  assign net_1664 = (net_1665 & net_981);
  assign net_981 = (net_1666 & net_1667);
  assign net_1667 = ~(expt_instr_type_int_iss[0] & net_1668);
  assign net_1668 = (net_1434 & net_1669);
  assign net_1669 = (net_1670 | net_1671);
  assign net_1671 = ~(net_48 | net_936);
  assign net_936 = (net_615 & net_65);
  assign net_1670 = ~(expt_instr_type_int_iss[1] | net_1672);
  assign net_1672 = ~(net_51 | net_1598);
  assign net_1666 = (net_1673 | expt_instr_type_int_iss[5]);
  assign net_1673 = (net_1674 & net_1675);
  assign net_1675 = (net_1676 & net_1677);
  assign net_1677 = (net_1678 | net_136);
  assign net_1678 = (net_1679 & net_1680);
  assign net_1680 = (net_44 | net_449);
  assign net_1679 = ~(net_1681 & net_866);
  assign net_866 = ~(expt_cpacr_el1_fpen_rs[0] | net_52);
  assign net_1676 = (net_1682 & net_1683);
  assign net_1683 = (expt_instr_type_int_iss[4] | net_1684);
  assign net_1684 = (net_298 & net_1685);
  assign net_1685 = ~(aarch64_at_el3 & net_1686);
  assign net_1686 = (net_36 & net_518);
  assign net_518 = ~(aarch64_state_rs | net_55);
  assign net_1682 = (net_113 | net_1687);
  assign net_1674 = (net_1688 | net_284);
  assign net_284 = (net_34 | net_298);
  assign net_1688 = (net_1592 & net_1689);
  assign net_1689 = (net_583 & net_449);
  assign net_583 = ~(net_51 | net_862);
  assign net_1665 = (net_1691 & net_1692);
  assign net_1692 = (net_262 | expt_instr_type_int_iss[5]);
  assign net_262 = ~(net_1445 & net_1693);
  assign net_1693 = ~(net_1694 & net_1695);
  assign net_1695 = (net_1696 | expt_instr_type_int_iss[2]);
  assign net_1696 = (net_1049 & net_1697);
  assign net_1697 = (net_1406 | expt_instr_type_int_iss[1]);
  assign net_1406 = ~(net_1698 & net_53);
  assign net_1694 = (net_1699 | expt_instr_type_int_iss[3]);
  assign net_1699 = (net_1700 & net_1701);
  assign net_1701 = ~(expt_instr_type_int_iss[2] & net_1519);
  assign net_1519 = (net_375 & hcr_twi_i);
  assign net_1700 = (sctlr_ntwi_rs | net_1702);
  assign net_1702 = (net_2088 | net_48);
  assign net_1691 = (net_1041 & net_1703);
  assign net_1703 = (net_1704 & net_1705);
  assign net_1705 = (net_1706 & net_1534);
  assign net_1534 = (net_1707 & net_1708);
  assign net_1708 = (net_1709 & net_1039);
  assign net_1039 = (net_1710 & net_1711);
  assign net_1711 = (net_989 | net_1712);
  assign net_989 = (net_136 | net_39);
  assign net_1710 = (net_886 & net_1713);
  assign net_1713 = (net_1714 & net_1715);
  assign net_1715 = (net_1716 | net_136);
  assign net_1716 = (net_1717 | net_22);
  assign net_1717 = (net_62 & net_1718);
  assign net_1718 = (aarch64_state_rs | fpexc_en_qual);
  assign net_1714 = (net_1719 & net_1110);
  assign net_1110 = (expt_instr_type_int_iss[3] | net_812);
  assign net_812 = ~(net_1720 & net_1531);
  assign net_1531 = ~(net_15 | net_275);
  assign net_1720 = ~(net_1645 | net_50);
  assign net_1645 = (dpu_exception_level_i[0] | sctlr_el1_uct_rs);
  assign net_886 = ~(net_31 & net_568);
  assign net_568 = ~(scr_el3_st_i | net_1721);
  assign net_1721 = ~(net_419 & net_207);
  assign net_207 = (net_2089 & net_1181);
  assign net_1709 = ~(net_1428 | net_1722);
  assign net_1722 = ~(net_1723 & net_1724);
  assign net_1724 = (net_10 | net_1421);
  assign net_1421 = ~(net_41 & net_1725);
  assign net_1725 = (ns_state_rs | net_1726);
  assign net_1726 = ~(net_494 & scr_el3_hce_i);
  assign net_1723 = (net_884 & net_1002);
  assign net_1002 = ~(net_31 & net_1727);
  assign net_884 = ~(net_30 & net_1160);
  assign net_1160 = ~(net_1728 | net_13);
  assign net_1728 = (net_162 & net_1729);
  assign net_1729 = ~(cptr_el3_tcpac_i & net_516);
  assign net_162 = ~(net_419 & expt_cptr_el2_tcpac_rs);
  assign net_1428 = (net_997 & net_1730);
  assign net_1730 = (net_1731 | net_1732);
  assign net_1732 = (net_555 & net_1733);
  assign net_1733 = (net_554 | net_1734);
  assign net_1734 = ~(net_63 | net_949);
  assign net_554 = ~(dpu_exception_level_i[1] | pmu_user_trap_iss);
  assign net_555 = (aarch64_at_el3 & mdcr_el3_tpm_i);
  assign net_997 = ~(net_275 | net_113);
  assign net_1707 = (net_1735 & net_1438);
  assign net_1438 = (expt_instr_type_int_iss[3] | net_1736);
  assign net_1736 = ~(expt_instr_type_int_iss[5] & net_1737);
  assign net_1737 = ~(net_1738 & net_1739);
  assign net_1739 = ~(expt_instr_type_int_iss[4] & net_1075);
  assign net_1738 = ~(net_1181 & net_1001);
  assign net_1001 = (net_775 & net_516);
  assign net_775 = (aarch64_at_el3 & mdcr_el3_tdosa_i);
  assign net_1735 = (net_1740 & net_1741);
  assign net_1741 = ~(ns_state_rs & net_1742);
  assign net_1742 = (net_1743 | net_1744);
  assign net_1744 = ~(dpu_exception_level_i[1] | net_1745);
  assign net_1745 = ~(net_1746 | net_1747);
  assign net_1747 = ~(net_289 | expt_instr_type_int_iss[5]);
  assign net_289 = (expt_instr_type_int_iss[3] | net_1748);
  assign net_1748 = ~(net_421 & hcr_tid3_i);
  assign net_1746 = (net_421 & net_1749);
  assign net_1749 = (net_1304 | net_1750);
  assign net_1750 = ~(net_113 | cnthctl_el2_el1pcten_rs);
  assign net_1304 = (net_32 & hcr_ttlb_i);
  assign net_1743 = (net_419 & net_1751);
  assign net_1751 = (net_1752 | net_1016);
  assign net_1740 = (net_1753 & net_1754);
  assign net_1754 = (net_271 | net_10);
  assign net_271 = ~(net_1223 & net_1055);
  assign net_1753 = (net_1755 & net_1361);
  assign net_1361 = ~(net_33 & net_1756);
  assign net_1756 = (net_421 & net_1757);
  assign net_1706 = (net_1372 & net_1758);
  assign net_1758 = ~(expt_instr_type_int_iss[0] & net_1759);
  assign net_1759 = ~(net_70 | net_1760);
  assign net_1760 = (net_1761 | expt_instr_type_int_iss[3]);
  assign net_1761 = (net_1762 & net_1763);
  assign net_1763 = (net_1764 | expt_instr_type_int_iss[4]);
  assign net_1764 = ~(net_69 & net_43);
  assign net_1762 = ~(net_2086 & net_244);
  assign net_1372 = (expt_instr_type_int_iss[4] | net_1765);
  assign net_1704 = (net_1766 & net_313);
  assign net_313 = ~(net_38 & net_1767);
  assign net_1767 = (net_32 & net_1768);
  assign net_1766 = (net_1769 & net_1770);
  assign net_1770 = (net_1373 & net_1455);
  assign net_1455 = (net_65 | net_988);
  assign net_988 = (expt_instr_type_int_iss[3] | net_18);
  assign net_1373 = (net_1771 & net_922);
  assign net_922 = (expt_instr_type_int_iss[4] | net_1562);
  assign net_1771 = ~(expt_instr_type_int_iss[3] & net_1772);
  assign net_1772 = ~(net_1773 & net_1774);
  assign net_1774 = (net_141 | expt_cpacr_el1_fpen_rs[0]);
  assign net_141 = (net_15 | net_713);
  assign net_1773 = ~(net_1598 & net_399);
  assign net_1598 = ~(fpexc_en_qual | net_473);
  assign net_1769 = (net_1775 & net_1451);
  assign net_1451 = (expt_instr_type_int_iss[4] | net_934);
  assign net_934 = ~(net_632 & net_1532);
  assign net_1532 = ~(net_433 & net_1776);
  assign net_1776 = ~(ns_state_rs & hcr_tdz_i);
  assign net_433 = (dpu_exception_level_i[0] | sctlr_el1_dze_rs);
  assign net_632 = (net_48 & net_132);
  assign net_132 = (net_2086 & net_949);
  assign net_1775 = (net_1777 & net_1778);
  assign net_1778 = (net_1029 | net_57);
  assign net_1029 = ~(net_295 & net_1186);
  assign net_1186 = (net_31 & hdcr_tdra_i);
  assign net_1777 = (net_1779 & net_1780);
  assign net_1780 = (net_1781 & net_1782);
  assign net_1782 = (net_464 | net_1783);
  assign net_1783 = (net_10 | net_279);
  assign net_464 = (net_278 & net_270);
  assign net_278 = (dpu_exception_level_i[1] & net_277);
  assign net_277 = ~(net_69 & ns_state_rs);
  assign net_1781 = (net_1468 & net_1784);
  assign net_1784 = (expt_instr_type_int_iss[3] | net_1785);
  assign net_1785 = (net_818 | net_174);
  assign net_818 = ~(net_1786 & net_1787);
  assign net_1468 = ~(net_1601 & net_1088);
  assign net_1088 = ~(net_965 & net_966);
  assign net_966 = (net_911 | net_42);
  assign net_965 = ~(net_295 & net_32);
  assign net_1601 = (net_2086 & net_1085);
  assign net_1085 = ~(net_961 | net_50);
  assign net_1779 = (net_1788 | net_1023);
  assign net_1023 = (net_34 | net_79);
  assign net_1788 = (net_429 & net_1789);
  assign net_1789 = (net_223 | net_57);
  assign net_1041 = ~(expt_instr_type_int_iss[5] & net_1790);
  assign net_1790 = ~(net_1791 & net_1792);
  assign net_1792 = (net_1793 & net_1794);
  assign net_1794 = (net_1795 & net_1796);
  assign net_1796 = ~(net_1797 & net_1181);
  assign net_1797 = ~(cntkctl_el1_el0vten_rs | net_1397);
  assign net_1795 = ~(sctlr_sed_rs & net_1434);
  assign net_1434 = (expt_instr_type_int_iss[2] & net_31);
  assign net_1793 = (net_1798 | net_298);
  assign net_1798 = (net_1463 & net_1799);
  assign net_1799 = (expt_instr_type_int_iss[3] | net_1584);
  assign net_1584 = (net_1800 & net_1446);
  assign net_1446 = (net_73 | net_55);
  assign net_1463 = ~(expt_instr_type_int_iss[4] & net_582);
  assign net_582 = (aarch64_state_rs & net_968);
  assign net_968 = ~(sctlr_el1_uma_rs | net_66);
  assign net_1791 = ~(expt_instr_type_int_iss[3] & net_1801);
  assign net_1801 = ~(net_45 & net_1802);
  assign net_1802 = ~(net_1803 & expt_instr_type_int_iss[4]);
  assign net_1803 = (expt_instr_type_int_iss[0] & net_577);
  assign net_577 = (expt_instr_type_int_iss[2] | net_1804);
  assign net_1804 = ~(sctlr_cp15ben_rs | net_48);
  assign net_1662 = (net_1805 & net_1806);
  assign net_1806 = (net_1807 & net_973);
  assign net_973 = (net_1328 & net_1808);
  assign net_1808 = (net_1325 | net_1809);
  assign net_1809 = ~(net_610 | net_618);
  assign net_610 = (dpu_exception_level_i[1] & net_1810);
  assign net_1810 = ~(dpu_exception_level_i[0] & net_1811);
  assign net_1325 = ~(net_12 & gic_el3_trap_iss);
  assign net_1328 = ~(ns_state_rs & net_1812);
  assign net_1812 = (net_1813 | net_1814);
  assign net_1814 = (net_1815 | net_1491);
  assign net_1491 = ~(dpu_exception_level_i[1] | net_1816);
  assign net_1816 = ~(net_1817 | net_1818);
  assign net_1818 = ~(net_1819 | expt_instr_type_int_iss[6]);
  assign net_1819 = (expt_instr_type_int_iss[4] | net_1543);
  assign net_1543 = (cnthctl_el2_el1pcen_rs | net_1216);
  assign net_1817 = (net_5 & net_1178);
  assign net_1178 = (net_295 & net_1545);
  assign net_1545 = (hcr_tpu_i & net_961);
  assign net_961 = (dpu_exception_level_i[0] | sctlr_el1_uci_rs);
  assign net_1815 = (net_12 & net_1820);
  assign net_1813 = ~(dpu_exception_level_i[1] | net_1821);
  assign net_1821 = ~(net_1822 | net_1823);
  assign net_1823 = (net_1824 & net_949);
  assign net_1824 = (net_1825 & net_1202);
  assign net_1202 = (net_36 & hcr_tid0_i);
  assign net_1825 = (net_2090 & net_34);
  assign net_1822 = (net_1627 & hcr_twe_i);
  assign net_1807 = (net_1826 & net_1827);
  assign net_1827 = (net_4 | net_993);
  assign net_993 = (in_halt_rs | net_1828);
  assign net_1828 = (net_1687 | net_819);
  assign net_819 = (net_65 & net_174);
  assign net_1568 = ~(net_70 | net_473);
  assign net_765 = ~(net_71 | net_73);
  assign net_1826 = (net_39 | net_1829);
  assign net_1829 = (net_990 | net_322);
  assign net_1805 = (net_1830 & net_1276);
  assign net_1276 = (expt_instr_type_int_iss[3] | net_1831);
  assign net_1831 = (net_1832 | expt_instr_type_int_iss[5]);
  assign net_1832 = (net_1833 & net_1834);
  assign net_1834 = (net_1525 | expt_instr_type_int_iss[6]);
  assign net_1525 = ~(net_375 & net_899);
  assign net_899 = ~(expt_instr_type_int_iss[2] | net_1190);
  assign net_1190 = (net_1835 & net_1836);
  assign net_1836 = ~(hcr_tacr_i & net_125);
  assign net_1835 = ~(net_1681 & hcr_tsw_i);
  assign net_1833 = (net_1837 | expt_instr_type_int_iss[4]);
  assign net_1837 = (net_1064 & net_1838);
  assign net_1838 = (net_1256 | net_1073);
  assign net_1256 = (net_2088 | net_184);
  assign net_1064 = (net_325 & net_1089);
  assign net_1089 = ~(expt_instr_type_int_iss[6] & net_1839);
  assign net_1839 = (net_226 & net_1577);
  assign net_1577 = (net_1840 & net_1841);
  assign net_1841 = ~(net_52 | net_71);
  assign net_1840 = ~(net_1260 | net_2088);
  assign net_325 = ~(expt_instr_type_int_iss[1] & net_1843);
  assign net_1843 = (net_1844 & net_1274);
  assign net_1274 = ~(net_1687 & net_1845);
  assign net_1845 = ~(expt_instr_type_int_iss[6] & net_1223);
  assign net_1830 = (net_807 & net_1846);
  assign net_1846 = (net_6 | net_1847);
  assign net_1847 = (net_1376 & net_1044);
  assign net_1044 = ~(net_1459 & net_1848);
  assign net_1459 = (expt_instr_type_int_iss[2] & net_576);
  assign net_1376 = ~(net_933 & net_1849);
  assign net_1849 = ~(net_1850 & net_1851);
  assign net_1851 = (expt_instr_type_int_iss[5] | expt_cpacr_el1_fpen_rs[1]);
  assign net_1850 = (expt_instr_type_int_iss[4] | cntkctl_el1_el0vcten_rs);
  assign net_933 = ~(net_44 | net_66);
  assign net_1177 = ~(net_2088 | net_713);
  assign net_807 = (net_338 & net_1602);
  assign net_1602 = ~(net_9 & net_1069);
  assign net_1069 = (net_1502 | net_618);
  assign net_618 = (net_419 & net_1261);
  assign net_1502 = ~(net_63 & net_1811);
  assign net_338 = ~(net_1273 & net_1154);
  assign pre_enter_halt_iss = (net_1634 | debug_status_iss[3]);
  assign net_1634 = ~(net_6 | net_752);
  assign pre_cpsr_wr_en_iss[1] = (debug_status_iss[3] | net_1852);
  assign net_1852 = (net_1853 | net_1854);
  assign net_1854 = (net_1855 | net_1856);
  assign net_1856 = ~(net_1857 & net_1858);
  assign net_1857 = ~(expt_instr_type_int_iss[1] & net_225);
  assign net_225 = ~(net_1859 | net_493);
  assign net_493 = ~(net_538 & net_1860);
  assign net_1860 = (sctlr_ntwi_rs & net_268);
  assign net_1859 = (net_1861 | net_14);
  assign net_1861 = (net_742 & net_1862);
  assign net_1862 = (dpu_exception_level_i[1] | hcr_twi_i);
  assign net_1855 = (net_1863 | net_1864);
  assign net_1864 = ~(net_1865 & net_1866);
  assign net_1866 = ~(net_1867 & net_637);
  assign net_1867 = ~(cpuectlr_el3_i | net_1868);
  assign net_1868 = ~(net_552 & net_1869);
  assign net_1869 = (net_54 | net_645);
  assign net_645 = (net_419 & cpuectlr_el2_i);
  assign net_1865 = ~(net_1870 & net_1871);
  assign net_1870 = ~(net_1 | net_236);
  assign net_163 = ~(expt_instr_type_int_iss[6] | net_911);
  assign net_1863 = (net_1872 & net_1873);
  assign net_1873 = ~(net_199 | net_27);
  assign net_199 = ~(sctlr_ntwe_rs & net_86);
  assign net_1872 = (net_1098 & net_1874);
  assign net_1874 = ~(net_742 & net_1875);
  assign net_1875 = (dpu_exception_level_i[1] | hcr_twe_i);
  assign net_742 = ~(net_208 | net_651);
  assign net_1098 = (net_637 & net_1876);
  assign net_1876 = (scr_el3_twe_i & net_2088);
  assign net_1853 = (net_2090 & net_1877);
  assign net_1877 = (net_1878 | net_12);
  assign net_1878 = (net_1879 | net_246);
  assign net_246 = ~(net_1880 & net_1881);
  assign net_1881 = (net_1264 | net_236);
  assign net_1264 = ~(net_1297 & net_1882);
  assign net_1882 = (net_1883 | net_1884);
  assign net_1884 = (net_75 & net_30);
  assign net_1880 = ~(net_1885 | net_1886);
  assign net_1886 = ~(scr_el3_smd_i | net_1887);
  assign net_1887 = ~(net_1888 & net_1889);
  assign net_1889 = ~(net_1610 & net_689);
  assign net_1610 = (net_63 & net_1890);
  assign net_1890 = (hcr_tsc_i | net_61);
  assign net_1888 = (net_1028 & net_421);
  assign net_1885 = (net_419 & net_1891);
  assign net_1891 = (net_1892 | net_1893);
  assign net_1893 = (cpuactlr_el2_i & net_1894);
  assign net_1894 = (net_1883 & net_1297);
  assign net_1892 = (net_30 & net_1895);
  assign net_1895 = (net_1896 | net_1897);
  assign net_1897 = ~(net_77 | net_670);
  assign net_670 = ~(net_75 & net_1297);
  assign net_1297 = ~(net_2089 | net_40);
  assign net_1896 = (l2ctlr_el2_i & net_1871);
  assign net_1871 = ~(l2ctlr_el3_i | net_893);
  assign net_1879 = (net_750 & net_1898);
  assign net_1898 = (net_54 | net_239);
  assign net_239 = (net_419 & l2actlr_el2_i);
  assign net_236 = ~(net_494 | net_504);
  assign net_504 = ~(ns_state_rs | net_61);
  assign pre_cpsr_wr_en_iss[0] = ~(net_1899 & net_1900);
  assign net_1900 = (net_1901 | expt_instr_type_int_iss[6]);
  assign net_1901 = (net_1755 & net_1902);
  assign net_1902 = (net_1903 & net_1904);
  assign net_1904 = (net_1905 & net_1906);
  assign net_1906 = ~(net_556 & net_1752);
  assign net_1752 = (expt_instr_type_int_iss[4] & net_1907);
  assign net_1907 = ~(l2actlr_el2_i | net_17);
  assign net_1905 = (net_729 & net_1140);
  assign net_1140 = (net_1908 & net_1909);
  assign net_1909 = (net_136 | net_572);
  assign net_572 = (net_1592 | net_11);
  assign net_1592 = (dpu_exception_level_i[0] | net_474);
  assign net_474 = (net_79 & dpu_exception_level_i[1]);
  assign net_1908 = (net_1910 & net_1911);
  assign net_1911 = (net_113 | net_543);
  assign net_543 = (net_1562 & net_1912);
  assign net_1912 = ~(net_1427 & net_164);
  assign net_164 = ~(net_14 | net_45);
  assign net_1427 = ~(in_halt_rs | sctlr_ntwi_rs);
  assign net_1562 = ~(net_16 & net_1913);
  assign net_1913 = ~(cntkctl_el1_el0pten_rs | net_66);
  assign net_1910 = (net_1393 & net_1563);
  assign net_1563 = (net_1397 | net_537);
  assign net_537 = (net_1914 | net_20);
  assign net_244 = ~(expt_instr_type_int_iss[1] | net_21);
  assign net_1914 = (net_1915 & net_1916);
  assign net_1916 = (expt_instr_type_int_iss[0] | cntkctl_el1_el0vten_rs);
  assign net_1915 = ~(net_82 & expt_instr_type_int_iss[0]);
  assign net_1397 = (net_66 | net_105);
  assign net_1393 = (net_1405 | net_1049);
  assign net_1049 = ~(expt_instr_type_int_iss[3] & net_649);
  assign net_649 = ~(expt_instr_type_int_iss[0] | sctlr_ntwe_rs);
  assign net_729 = ~(net_204 & net_1917);
  assign net_1917 = (net_1445 & net_1918);
  assign net_1918 = ~(net_1919 & net_1920);
  assign net_1920 = ~(net_203 & net_1698);
  assign net_1698 = (expt_instr_type_int_iss[3] & scr_el3_twe_i);
  assign net_203 = ~(hcr_twe_i | net_42);
  assign net_1181 = (net_2088 & net_43);
  assign net_1919 = ~(net_1921 & scr_el3_twi_i);
  assign net_1921 = ~(hcr_twi_i | net_1171);
  assign net_1171 = ~(net_295 & net_34);
  assign net_295 = ~(net_2088 | net_45);
  assign net_1445 = ~(expt_instr_type_int_iss[4] | in_halt_rs);
  assign net_1903 = (net_1922 & net_1923);
  assign net_1923 = (net_10 | net_1924);
  assign net_1924 = (net_1925 & net_1414);
  assign net_1414 = ~(net_1223 & net_1286);
  assign net_1286 = ~(net_1926 & net_1927);
  assign net_1927 = (dpu_exception_level_i[1] | hcr_tsc_i);
  assign net_1926 = (dpu_exception_level_i[0] & ns_state_rs);
  assign net_1925 = (net_1928 & net_1929);
  assign net_1929 = ~(net_183 & net_36);
  assign net_183 = (external_iabort & scr_el3_ea_i);
  assign net_1928 = ~(net_1097 | net_1930);
  assign net_1930 = ~(net_1931 | net_275);
  assign net_1931 = ~(net_1245 | net_1932);
  assign net_1932 = ~(net_66 & net_1260);
  assign net_1245 = ~(aarch64_state_rs | net_64);
  assign net_1097 = ~(net_1933 | net_279);
  assign net_279 = ~(expt_instr_type_int_iss[2] & net_268);
  assign net_268 = (scr_el3_twi_i & net_86);
  assign net_1933 = (net_1260 & net_1934);
  assign net_1934 = (net_48 | net_1935);
  assign net_1935 = (net_59 & net_270);
  assign net_1922 = (net_1936 & net_1937);
  assign net_1937 = (net_2087 | net_1938);
  assign net_1938 = (net_1939 & net_1940);
  assign net_1940 = ~(hdcr_tde_i & net_1941);
  assign net_1941 = ~(net_756 | net_27);
  assign net_756 = (net_46 & net_1942);
  assign net_1942 = ~(net_2086 & net_1681);
  assign net_1939 = (net_101 & net_1034);
  assign net_1034 = (net_1943 & net_104);
  assign net_104 = ~(net_30 & net_1944);
  assign net_1944 = (net_1786 & net_1945);
  assign net_1945 = ~(expt_instr_type_int_iss[1] & net_894);
  assign net_894 = (l2ctlr_el2_i | net_61);
  assign net_1943 = (net_1946 | net_1947);
  assign net_1947 = (l2ectlr_el2_i | net_1948);
  assign net_1948 = ~(net_419 & net_1249);
  assign net_101 = (expt_instr_type_int_iss[4] | net_429);
  assign net_429 = ~(net_494 & net_399);
  assign net_1936 = (net_1533 & net_314);
  assign net_314 = (net_1949 & net_1950);
  assign net_1950 = (net_1951 | scr_el3_hce_i);
  assign net_1951 = (net_275 | net_10);
  assign net_1949 = (net_1952 & net_1953);
  assign net_1953 = (net_1954 & net_1955);
  assign net_1955 = ~(net_1016 & net_556);
  assign net_1016 = (net_32 & net_1956);
  assign net_1956 = (net_76 & net_607);
  assign net_1954 = (net_1719 & net_1957);
  assign net_1957 = (net_1958 & net_1959);
  assign net_1959 = ~(net_1249 & net_1075);
  assign net_1075 = (net_1960 | net_1961);
  assign net_1961 = (net_1962 | net_1963);
  assign net_1963 = (net_43 & net_1964);
  assign net_1964 = (net_63 | net_1965);
  assign net_1965 = (net_71 | net_86);
  assign net_1962 = (net_661 & net_516);
  assign net_661 = ~(l2ectlr_el3_i | net_1946);
  assign net_1946 = ~(net_2088 & net_48);
  assign net_1960 = ~(expt_instr_type_int_iss[2] | net_1966);
  assign net_1966 = (expt_instr_type_int_iss[0] & net_1967);
  assign net_1967 = (net_1968 | l2ctlr_el3_i);
  assign net_1968 = (net_61 & net_1969);
  assign net_1249 = ~(net_2089 | net_911);
  assign net_911 = ~(expt_instr_type_int_iss[4] & net_34);
  assign net_1958 = (net_1058 & net_1119);
  assign net_1119 = (net_1970 | net_113);
  assign net_1970 = ~(net_544 | net_1971);
  assign net_1971 = (net_739 & net_2089);
  assign net_544 = (net_41 & net_1731);
  assign net_1731 = (pmu_user_trap_iss & net_1244);
  assign net_1058 = (expt_instr_type_int_iss[4] | net_820);
  assign net_820 = ~(net_1757 & net_1127);
  assign net_1719 = ~(net_607 & net_1454);
  assign net_1454 = (net_1883 & net_516);
  assign net_1883 = ~(cpuactlr_el3_i | net_105);
  assign net_1952 = (net_136 | net_1363);
  assign net_1363 = ~(net_949 & net_1972);
  assign net_1972 = (net_1244 & net_1973);
  assign net_1973 = ~(net_1974 & net_1975);
  assign net_1975 = ~(mdscr_el1_tdcc_i & net_226);
  assign net_1974 = (expt_instr_type_int_iss[1] | expt_cpacr_el1_fpen_rs[1]);
  assign net_1533 = (net_1976 & net_1977);
  assign net_1977 = (net_752 & net_1143);
  assign net_1143 = (net_10 | net_175);
  assign net_752 = ~(dbg_bkpt_wpt_en_rs & net_1403);
  assign net_1976 = (net_1978 & net_1979);
  assign net_1979 = (net_1980 | net_136);
  assign net_136 = ~(expt_instr_type_int_iss[3] & expt_instr_type_int_iss[4]);
  assign net_1980 = ~(net_1981 | net_1982);
  assign net_1982 = ~(net_584 | net_1690);
  assign net_1690 = (expt_cpacr_el1_fpen_rs[0] | net_177);
  assign net_1981 = ~(net_1983 & net_1984);
  assign net_1984 = (net_893 | sctlr_cp15ben_rs);
  assign net_893 = ~(expt_instr_type_int_iss[0] & net_1443);
  assign net_1443 = ~(net_48 | net_21);
  assign net_1983 = (net_17 & net_1985);
  assign net_1985 = (net_573 & net_1986);
  assign net_1986 = (net_22 | net_990);
  assign net_990 = ~(expt_cptr_el2_tfp_rs & net_308);
  assign net_573 = (net_449 | net_223);
  assign net_223 = (expt_instr_type_int_iss[5] | net_175);
  assign net_1978 = (net_1056 & net_1987);
  assign net_1987 = (net_34 | net_1988);
  assign net_1988 = (net_29 & net_1084);
  assign net_1084 = ~(net_552 & net_1848);
  assign net_1848 = ~(net_826 & net_1460);
  assign net_1460 = (net_478 | cpuectlr_el3_i);
  assign net_478 = (net_69 ^ dpu_exception_level_i[1]);
  assign net_826 = (cpuectlr_el2_i | net_56);
  assign net_1056 = ~(net_32 & net_625);
  assign net_625 = (net_1768 & net_581);
  assign net_581 = ~(net_2089 | net_46);
  assign net_1768 = (net_82 & net_1757);
  assign net_1757 = ~(cntkctl_el1_el0pcten_rs | net_66);
  assign net_105 = (expt_instr_type_int_iss[4] | net_34);
  assign net_1755 = ~(net_750 & net_516);
  assign net_516 = ~(net_69 ^ dpu_exception_level_i[1]);
  assign net_750 = (expt_instr_type_int_iss[4] & net_238);
  assign net_238 = ~(l2actlr_el3_i | net_17);
  assign net_552 = (net_41 & net_576);
  assign net_1899 = (net_1989 & net_1990);
  assign net_1990 = (net_352 & net_1120);
  assign net_1120 = (net_1991 | net_2087);
  assign net_1991 = (net_1992 & net_1993);
  assign net_1993 = (net_1994 | net_61);
  assign net_1994 = ~(net_71 & net_505);
  assign net_1992 = (net_1995 & net_1996);
  assign net_1996 = ~(net_624 & net_1820);
  assign net_1820 = (net_419 & net_1556);
  assign net_1556 = (gic_el2_trap_iss | net_85);
  assign net_419 = ~(net_69 | dpu_exception_level_i[1]);
  assign net_1995 = (net_322 | net_135);
  assign net_135 = ~(net_204 & net_1997);
  assign net_1997 = ~(net_298 | net_79);
  assign net_204 = ~(dpu_exception_level_i[1] | expt_instr_type_int_iss[5]);
  assign net_352 = (net_1998 & net_1999);
  assign net_1999 = (net_2000 | net_68);
  assign net_2000 = ~(expt_instr_type_int_iss[0] & net_703);
  assign net_703 = ~(net_1501 | net_19);
  assign net_1285 = ~(net_21 | in_halt_rs);
  assign net_1501 = (net_4 | dpu_exception_level_i[1]);
  assign net_1998 = (net_2001 | net_617);
  assign net_617 = ~(icc_sre_el2_enable_rs | net_84);
  assign net_2001 = (net_56 | net_636);
  assign net_556 = ~(net_69 | net_57);
  assign net_1989 = (net_2002 & net_2003);
  assign net_2003 = ~(net_2004 & scr_el3_twe_i);
  assign net_2004 = (net_1627 & net_2005);
  assign net_2005 = ~(net_209 & net_59);
  assign net_208 = ~(net_2087 | net_63);
  assign net_209 = ~(net_2088 & net_651);
  assign net_651 = ~(net_270 & net_1260);
  assign net_1260 = (ns_state_rs | dpu_exception_level_i[1]);
  assign net_270 = (net_69 | net_1811);
  assign net_1627 = ~(net_6 | net_1405);
  assign net_1405 = (expt_instr_type_int_iss[1] | net_1048);
  assign net_1048 = ~(net_86 & net_715);
  assign net_2002 = (net_2006 & net_2007);
  assign net_2007 = (net_535 | net_1152);
  assign net_1152 = (net_536 & net_2008);
  assign net_2008 = (net_1073 | net_1687);
  assign net_1073 = (icc_sre_el1_s_sre_qual | net_2009);
  assign net_2009 = ~(net_2010 & net_2011);
  assign net_2011 = ~(net_689 | net_2012);
  assign net_2012 = (dpu_exception_level_i[1] & monitor_mode);
  assign net_689 = (net_69 | ns_state_rs);
  assign net_2010 = ~(net_2086 ^ aarch64_at_el3);
  assign net_536 = ~(net_1844 & net_1154);
  assign net_1154 = ~(net_2088 ^ expt_instr_type_int_iss[2]);
  assign net_1844 = ~(icc_sre_el3_sre_rs | net_64);
  assign net_535 = ~(expt_instr_type_int_iss[1] & net_1487);
  assign net_1487 = ~(net_2090 | net_10);
  assign net_2006 = (net_2013 & net_2014);
  assign net_2014 = (net_2015 & net_2016);
  assign net_2016 = (net_4 | net_1117);
  assign net_1117 = (net_615 | net_175);
  assign net_175 = (expt_instr_type_int_iss[2] | net_755);
  assign net_755 = (net_2088 ^ expt_instr_type_int_iss[1]);
  assign net_615 = ~(net_2086 & net_802);
  assign net_2015 = (net_1349 & net_2017);
  assign net_2017 = (net_2018 & net_2019);
  assign net_2019 = (net_63 | net_636);
  assign net_636 = ~(net_71 & net_9);
  assign net_2018 = (net_2020 & net_2021);
  assign net_2021 = (net_2022 & net_2023);
  assign net_2023 = (net_1811 | net_1070);
  assign net_1070 = (icc_sre_el3_enable_rs | net_1653);
  assign net_1653 = ~(net_1028 & net_2024);
  assign net_2024 = (net_739 & icc_sre_el3_sre_rs);
  assign net_739 = (net_2088 & net_41);
  assign net_1811 = (monitor_mode | net_1261);
  assign net_2022 = (net_222 | net_332);
  assign net_332 = ~(net_5 & net_654);
  assign net_654 = ~(net_2089 | net_45);
  assign net_222 = ~(ns_state_rs & hdcr_tde_i);
  assign net_2020 = (net_2025 & net_2026);
  assign net_2026 = ~(net_2027 & net_38);
  assign net_2027 = (net_2028 & net_2029);
  assign net_2029 = (net_2030 | net_2031);
  assign net_2031 = (net_2032 & net_69);
  assign net_2030 = (net_2033 | net_2034);
  assign net_2034 = (net_2035 | net_2036);
  assign net_2035 = (net_771 & net_73);
  assign net_771 = ~(net_375 & hdcr_tda_i);
  assign net_375 = (net_2086 & ns_state_rs);
  assign net_2028 = ~(net_4 | net_1800);
  assign net_2025 = ~(net_505 & net_1151);
  assign net_1151 = ~(net_1327 | net_2037);
  assign net_1327 = (dpu_exception_level_i[0] & net_1290);
  assign net_1290 = (ns_state_rs | monitor_mode);
  assign net_505 = (gic_el3_trap_iss & net_624);
  assign net_624 = ~(net_2090 | net_1072);
  assign net_1072 = ~(net_33 & net_523);
  assign net_523 = ~(net_14 | net_184);
  assign net_184 = (expt_instr_type_int_iss[2] | net_48);
  assign net_1349 = ~(net_1273 & net_2038);
  assign net_2038 = (net_1223 | net_2039);
  assign net_2039 = (net_37 & expt_instr_type_int_iss[6]);
  assign net_1687 = (expt_instr_type_int_iss[2] | net_2088);
  assign net_1273 = (net_1028 & net_2040);
  assign net_2040 = ~(icc_sre_el2_sre_qual | net_1969);
  assign net_1969 = (net_48 | net_63);
  assign net_1028 = ~(expt_instr_type_int_iss[5] | net_113);
  assign net_2013 = ~(net_7 & net_2041);
  assign net_2041 = ~(net_2042 & net_2043);
  assign net_2043 = (net_62 | net_584);
  assign net_584 = ~(net_585 | net_218);
  assign net_218 = ~(net_298 | expt_instr_type_int_iss[5]);
  assign net_298 = (expt_instr_type_int_iss[2] | net_46);
  assign net_862 = (dpu_exception_level_i[1] & cptr_el3_tfp_i);
  assign net_2042 = ~(net_1727 | net_2044);
  assign net_2044 = ~(net_2045 & net_2046);
  assign net_2046 = ~(sctlr_sed_rs & net_607);
  assign net_607 = (expt_instr_type_int_iss[5] & net_1223);
  assign net_1223 = (expt_instr_type_int_iss[2] & net_2088);
  assign net_2045 = (net_2047 & net_2048);
  assign net_2048 = (net_306 | net_22);
  assign net_585 = ~(net_47 | net_1786);
  assign net_1681 = (net_48 & expt_instr_type_int_iss[0]);
  assign net_306 = (fpexc_en_qual | net_486);
  assign net_486 = (aarch64_state_rs & net_473);
  assign net_2047 = (net_39 | net_1712);
  assign net_1712 = (net_560 & net_589);
  assign net_589 = (expt_cpacr_el1_fpen_rs[1] | net_66);
  assign net_1244 = (net_69 & net_2086);
  assign net_560 = (net_304 & net_451);
  assign net_451 = (expt_hcptr_tase_rs | net_449);
  assign net_449 = ~(cptr_el3_tfp_i & net_79);
  assign net_304 = (net_78 | net_177);
  assign net_177 = ~(net_2086 | net_1842);
  assign net_1842 = ~(aarch64_state_rs | net_69);
  assign net_1727 = (net_567 & net_308);
  assign net_308 = ~(net_63 & net_1130);
  assign net_1130 = (net_2087 | net_473);
  assign net_494 = (net_69 & dpu_exception_level_i[1]);
  assign net_567 = (expt_hcptr_tase_rs & net_2049);
  assign net_2049 = ~(net_2088 | net_275);
  assign net_275 = ~(expt_instr_type_int_iss[2] & net_48);
  assign debug_status_iss[3] = ~(net_2050 & net_1625);
  assign debug_status_iss[2] = ~(net_2051 & net_1625);
  assign net_1625 = ~(net_2052 & net_770);
  assign net_770 = ~(net_1800 | net_18);
  assign net_803 = ~(net_21 | net_46);
  assign net_1786 = ~(expt_instr_type_int_iss[2] | net_2089);
  assign net_1800 = (dbg_lock_set_rs | net_2053);
  assign net_2053 = ~(edscr_tda_i & dbg_halting_allowed_rs);
  assign net_2052 = (net_538 & net_2054);
  assign net_2054 = ~(net_2055 & net_2056);
  assign net_2056 = (net_2057 & net_2058);
  assign net_2058 = ~(net_517 & net_2032);
  assign net_2032 = ~(net_1261 & net_2059);
  assign net_1261 = ~(net_2087 & net_71);
  assign net_517 = ~(dpu_exception_level_i[0] | mdscr_el1_tdcc_i);
  assign net_2057 = ~(net_2036 & dpu_exception_level_i[0]);
  assign net_2036 = ~(net_2087 | net_2059);
  assign net_2059 = (aarch64_at_el3 | hdcr_tda_i);
  assign net_2055 = ~(net_2033 | net_2060);
  assign net_2060 = (net_73 & net_174);
  assign net_174 = (dpu_exception_level_i[1] | net_151);
  assign net_151 = (net_68 & net_2061);
  assign net_2061 = ~(hdcr_tda_i & ns_state_rs);
  assign net_802 = (mdscr_el1_tdcc_i & net_69);
  assign net_2033 = ~(net_64 & net_2037);
  assign net_2037 = ~(net_71 & dpu_exception_level_i[1]);
  assign net_538 = ~(expt_instr_type_int_iss[6] | net_113);
  assign net_113 = (expt_instr_type_int_iss[3] | expt_instr_type_int_iss[4]);
  assign net_2051 = (net_2062 & net_2063);
  assign net_2063 = ~(net_16 & net_5);
  assign net_2062 = ~(net_7 & net_1127);
  assign debug_status_iss[1] = (net_5 & net_2064);
  assign net_2064 = ~(net_1765 & net_224);
  assign net_358 = (expt_instr_type_int_iss[4] | net_6);
  assign debug_status_iss[0] = ~(net_2050 & net_1858);
  assign net_1858 = ~(net_637 & net_2065);
  assign net_2065 = (net_1403 | net_2066);
  assign net_2066 = ~(expt_instr_type_int_iss[4] | net_935);
  assign net_935 = (net_1216 & net_1765);
  assign net_1765 = ~(net_399 & net_1055);
  assign net_1055 = (net_2087 | net_64);
  assign net_473 = ~(net_69 | net_2086);
  assign net_399 = ~(net_14 | net_713);
  assign net_713 = (expt_instr_type_int_iss[1] | expt_instr_type_int_iss[2]);
  assign net_949 = ~(expt_instr_type_int_iss[5] | net_2088);
  assign net_1216 = ~(net_226 & net_576);
  assign net_576 = ~(net_2088 | net_2089);
  assign net_226 = (expt_instr_type_int_iss[1] & expt_instr_type_int_iss[2]);
  assign net_1403 = (net_715 & net_125);
  assign net_715 = ~(expt_instr_type_int_iss[4] | net_210);
  assign net_210 = (expt_instr_type_int_iss[5] | expt_instr_type_int_iss[2]);
  assign net_2050 = ~(net_1621 | high_priority_iss);
  assign high_priority_iss = (expt_instr_type_int_iss[5] & net_2067);
  assign net_2067 = (net_1550 & net_1787);
  assign net_1787 = ~(net_2088 ^ expt_instr_type_int_iss[1]);
  assign net_1550 = (expt_instr_type_int_iss[2] & net_7);
  assign net_322 = ~(expt_instr_type_int_iss[4] & net_637);
  assign net_1621 = ~(net_6 | net_224);
  assign net_224 = ~(net_1127 & dbg_hlt_en_rs);
  assign net_1127 = (expt_instr_type_int_iss[5] & net_421);
  assign net_421 = (expt_instr_type_int_iss[2] & net_125);
  assign net_125 = ~(net_48 | expt_instr_type_int_iss[0]);
  assign net_637 = ~(net_34 | expt_instr_type_int_iss[6]);
  assign net_2068 = (net_518 & net_519);
  assign net_2069 = ~(net_509 | net_2068);
  assign net_2070 = (net_20 | net_242);
  assign net_2071 = ~(net_2069 & net_2070);
  assign net_2072 = (net_500 | net_501);
  assign net_2073 = (net_505 & net_2072);
  assign net_2074 = (net_2073 | net_2071);
  assign net_2075 = ~(net_490 & net_491);
  assign net_2076 = (net_455 | net_2075);
  assign net_2077 = (net_456 | net_2076);
  assign net_2078 = (net_441 | net_176);
  assign net_2079 = ~(net_440 | net_2078);
  assign net_2080 = (net_2079 | net_2077);
  assign net_2081 = (net_384 | net_383);
  assign net_2082 = (net_2090 & net_2081);
  assign net_2083 = (net_2082 | net_2080);
  assign net_2084 = (aarch64_at_el3 & net_2074);
  assign net_2085 = (net_2084 | net_381);
  assign pre_target_el_iss[1] = (net_2083 | net_2085);
  assign net_2086 = ~dpu_exception_level_i[1];
  assign net_2087 = ~ns_state_rs;
  assign net_2088 = ~expt_instr_type_int_iss[0];
  assign net_2089 = ~expt_instr_type_int_iss[5];
  assign net_2090 = ~expt_instr_type_int_iss[6];

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Detect exception due to CPSR.IL being set
  // ------------------------------------------------------

  assign take_il_trap_iss = cpsr_ilbit_ret_i &
                            (expt_instr_type_iss != `CA53_EXPT_INSTR_TYPE_HW_BKPT)     &
                            (expt_instr_type_iss != `CA53_EXPT_INSTR_TYPE_RESET_CATCH) &
                            (expt_instr_type_iss != `CA53_EXPT_INSTR_TYPE_EXPT_CATCH)  &
                            (expt_instr_type_iss != `CA53_EXPT_INSTR_TYPE_VECT_CATCH)  &
                            (expt_instr_type_iss != `CA53_EXPT_INSTR_TYPE_FABORT);

  // Taking IL trap prevents entering halt
  assign enter_halt_iss = pre_enter_halt_iss & ~take_il_trap_iss;

  // ------------------------------------------------------
  // Detect exception due to cryptography instructions
  // when crypto is configured out or CRYPTODISABLE is set
  // ------------------------------------------------------

  assign crypto_undef_iss = (expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_CRYPTO) & cryptodisable_i;

  // ------------------------------------------------------
  // Detect and route additional traps to Hyp/EL2 manually
  // ------------------------------------------------------

  // Generic trapping of CP15 functionality based on HSTR value.
  // A set of generic trap bits (15, 13:5, 3:0) located in HSTR
  // register provide traps for each of the "primary" CP15 registers.
  assign cp_primary_reg_iss = mcr_mrc_width_iss ? instr_iss[3:0]  : // MCRR/MRRC - CRm
                                                  instr_iss[19:16]; // MCR/MRC   - CRn

  always @*
    case (cp_primary_reg_iss)
      4'b0000  : hstr_trap_match_iss = hstr_trap_i[0];
      4'b0001  : hstr_trap_match_iss = hstr_trap_i[1];
      4'b0010  : hstr_trap_match_iss = hstr_trap_i[2];
      4'b0011  : hstr_trap_match_iss = hstr_trap_i[3];
      4'b0100  : hstr_trap_match_iss = 1'b0;
      4'b0101  : hstr_trap_match_iss = hstr_trap_i[4];
      4'b0110  : hstr_trap_match_iss = hstr_trap_i[5];
      4'b0111  : hstr_trap_match_iss = hstr_trap_i[6];
      4'b1000  : hstr_trap_match_iss = hstr_trap_i[7];
      4'b1001  : hstr_trap_match_iss = hstr_trap_i[8];
      4'b1010  : hstr_trap_match_iss = hstr_trap_i[9];
      4'b1011  : hstr_trap_match_iss = hstr_trap_i[10];
      4'b1100  : hstr_trap_match_iss = hstr_trap_i[11];
      4'b1101  : hstr_trap_match_iss = hstr_trap_i[12];
      4'b1110  : hstr_trap_match_iss = 1'b0;
      4'b1111  : hstr_trap_match_iss = hstr_trap_i[13];
      default  : hstr_trap_match_iss = 1'bx;
    endcase

  // Note: instr_misc_iss register
  //
  // As well as the instruction type and opcode, the exception logic needs to know on
  // load/store instructions whether the instruction is a CP14 LDC literal, and
  // on Other instructions whether the instruction was decoded with mcr_mrc_valid set.
  // This information must be pipelined from De, but since the two signals are
  // mutually exclusive they can share a flop. The meaning of the bit is then
  // inferred based on where it is used.
  assign take_hstr_trap_iss = hstr_trap_match_iss &                                             // CRn/CRm value is being trapped
                              (expt_instr_type_iss != `CA53_EXPT_INSTR_TYPE_PD_UNDEF) &         // Not pre-decoded as undef
                              instr_is_other_iss &
                              ({instr_iss[27:26], instr_iss[8]} == 3'b11_1) &                   // MRC/MRRC/MCR/MCRR instruction to/from CP15
                              ns_state_rs & ~aarch64_state_rs &                                 // Only applies in non-secure AA32
                              ( (dpu_exception_level_i == `CA53_EL1) |                          // Always applies in EL1
                               ((dpu_exception_level_i == `CA53_EL0) & instr_misc_iss &         // - or in EL0 when register is valid
                                ~(pre_exception_valid_iss & (pre_target_el_iss < `CA53_EL2)))); // - and not taking exception to lower EL

  // For AArch32, match:
  // All CP15, CRn==9,  Opcode1=={0-7}, CRm=={c0-c2, c5-c8},   opcode2 == {0-7}
  // All CP15, CRn==10, Opcode1=={0-7}, CRm=={c0, c1, c4, c8}, opcode2 == {0-7}
  // All CP15, CRn==11, Opcode1=={0-7}, CRm=={c0-c8, c15},     opcode2 == {0-7}
  assign tidcp_match_aa32_iss = instr_iss[8] &
                                (((instr_iss[19:16] == 4'b1001) & ((instr_iss[3:0] == 4'b0000) |
                                                                   (instr_iss[3:0] == 4'b0001) |
                                                                   (instr_iss[3:0] == 4'b0010) |
                                                                   (instr_iss[3:0] == 4'b0101) |
                                                                   (instr_iss[3:0] == 4'b0110) |
                                                                   (instr_iss[3:0] == 4'b0111) |
                                                                   (instr_iss[3:0] == 4'b1000))) |
                                 ((instr_iss[19:16] == 4'b1010) & ((instr_iss[3:0] == 4'b0000) |
                                                                   (instr_iss[3:0] == 4'b0001) |
                                                                   (instr_iss[3:0] == 4'b0100) |
                                                                   (instr_iss[3:0] == 4'b1000))) |
                                 ((instr_iss[19:16] == 4'b1011) & ((instr_iss[3]   == 1'b0)    |
                                                                   (instr_iss[3:0] == 4'b1000) |
                                                                   (instr_iss[3:0] == 4'b1111))));

  // For AArch64:
  // CRn of c11 and c15, for op0=1-3 (including SYS/SYSL)
  assign tidcp_match_aa64_iss = (instr_iss[19:16] == 4'b1011) |
                                (instr_iss[19:16] == 4'b1111);

  assign take_tidcp_trap_iss = hcr_tidcp_i &
                               (aarch64_state_rs ? tidcp_match_aa64_iss : tidcp_match_aa32_iss) &
                               (expt_instr_type_iss != `CA53_EXPT_INSTR_TYPE_PD_UNDEF) &    // Not pre-decoded as undef
                               instr_is_other_iss &
                               (instr_iss[27:25] == 3'b111) &                               // MRC/MCR instruction (or MRS/MSR/SYS/SYSL in A64)
                               ns_state_rs &                                                // Only applies in non-secure state
                               ( (dpu_exception_level_i == `CA53_EL1) |                     // Always applies in EL1
                                ((dpu_exception_level_i == `CA53_EL0) & instr_misc_iss &    // - or in EL0 when register is valid
                                 ~pre_exception_valid_iss));                                        // - and no higher priority exception
                                                                                            // (on Other instructions, instr_misc_iss is mcr_mrc_valid)

  // Trap all exceptions which target EL1 when HCR.TGE is set and valid
  assign take_tge_trap_iss = hcr_tge_valid & (pre_target_el_iss == `CA53_EL1) & (dpu_exception_level_i == `CA53_EL0);

  // Trap all exceptions which target EL3 when in debug state and EDSCR.SDD is set
  assign take_sdd_trap_iss = in_halt_i & edscr_sdd_i & (pre_target_el_iss == `CA53_EL3);

  // ID group trap on FP registers
  assign take_fp_id_grp_trap_iss = ~pre_exception_valid_iss &
                                   (dpu_exception_level_i != `CA53_EL2) & ns_state_rs &
                                   (((expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_FP_ID0) & hcr_tid0_i) |
                                    ((expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_FP_ID3) & hcr_tid3_i));

  // ------------------------------------------------------
  // Combine auto-generated and manual traps
  // ------------------------------------------------------

  // Set exception data when taking manually detected trap, and override syndrome type
  // generated by auto-generated logic where required.
  assign syndrome_type_iss        = take_il_trap_iss                                ? `CA53_SYND_TYPE_IL_BIT  :
                                    (take_hstr_trap_iss | take_tidcp_trap_iss | 
                                     take_fp_id_grp_trap_iss)                       ? `CA53_SYND_TYPE_SYS_REG :
                                    (take_sdd_trap_iss | crypto_undef_iss)          ? `CA53_SYND_TYPE_UNSPEC  :
                                    (take_tge_trap_iss & ~exception_aa64_iss &   
                                     (pre_target_mode_iss == `CA53_FULL_MODE_UND))  ? `CA53_SYND_TYPE_UNSPEC  :
                                                                                      pre_syndrome_type_iss;
                                                                                       
  assign expt_type_iss            = (take_il_trap_iss    | take_sdd_trap_iss  |
                                     crypto_undef_iss    | take_hstr_trap_iss |                       
                                     take_tidcp_trap_iss | take_fp_id_grp_trap_iss) ? `CA53_EXPT_TYPE_TRAP :
                                                                                      pre_expt_type_iss;
                                                                                 
  assign target_el_iss            = (take_il_trap_iss | crypto_undef_iss)           ? (hcr_tge_valid ? `CA53_EL2 : `CA53_EL1) :
                                    (take_hstr_trap_iss  |                       
                                     take_tge_trap_iss   |                       
                                     take_tidcp_trap_iss |                       
                                     take_fp_id_grp_trap_iss)                       ? `CA53_EL2                               :
                                    take_sdd_trap_iss                               ? (hcr_tge_valid ? `CA53_EL2 : `CA53_EL1) :
                                                                                      pre_target_el_iss;
                                                                                 
  assign target_mode_iss          = (take_il_trap_iss | crypto_undef_iss)           ? (hcr_tge_valid ? `CA53_FULL_MODE_HYP : `CA53_FULL_MODE_UND) :
                                    (take_hstr_trap_iss  |                       
                                     take_tge_trap_iss   |                       
                                     take_tidcp_trap_iss |                       
                                     take_fp_id_grp_trap_iss)                       ? `CA53_FULL_MODE_HYP :
                                    take_sdd_trap_iss                               ? (hcr_tge_valid ? `CA53_FULL_MODE_HYP : `CA53_FULL_MODE_UND) :
                                                                                      pre_target_mode_iss;
                                                                                 
  assign expt_vec_offset_iss      = trapping_to_el2                                 ? 5'h14 :
                                    (take_il_trap_iss | take_sdd_trap_iss |
                                     crypto_undef_iss)                              ? 5'h04 :
                                                                                      pre_expt_vec_offset_iss;
                                                                                         
  assign forceop_offset_aa32_iss  = (expt_type_iss == `CA53_EXPT_TYPE_CALL)         ? pre_forceop_offset_aa32_iss   :
                                    (exception_el_iss == `CA53_EL2)                 ? `CA53_FORCEOP_OFFSET_TYPE_4_8 :
                                    take_il_trap_iss                                ? `CA53_FORCEOP_OFFSET_TYPE_2_4 :
                                    (take_hstr_trap_iss  |                         
                                     take_tge_trap_iss   |                         
                                     take_tidcp_trap_iss |                         
                                     take_fp_id_grp_trap_iss)                       ? `CA53_FORCEOP_OFFSET_TYPE_0_4 :
                                    (take_sdd_trap_iss | crypto_undef_iss)          ? `CA53_FORCEOP_OFFSET_TYPE_2_4 :
                                                                                      pre_forceop_offset_aa32_iss;
                                                                                         
  assign cpsr_wr_en_iss           = (exception_el_iss == `CA53_EL2)                 ? `CA53_CPSR_WR_EN_EARLY_AIFM :  // Exceptions to EL2 always set all mask bits
                                    (take_il_trap_iss | take_sdd_trap_iss |
                                     crypto_undef_iss)                              ? `CA53_CPSR_WR_EN_EARLY_IM   :
                                                                                      pre_cpsr_wr_en_iss;

  assign quash_iss            = pre_quash_iss |
                                (trapping_to_el2 & (pre_expt_type_iss != `CA53_EXPT_TYPE_CALL)) |
                                take_il_trap_iss    |
                                crypto_undef_iss    |
                                take_hstr_trap_iss  |
                                take_tidcp_trap_iss | 
                                take_fp_id_grp_trap_iss;

  // Only pipeline instruction information if may cause exception, so qualify exception valid to prevent x-propagation
  assign exception_valid_iss  = ((crypto_undef_iss        |
                                  take_hstr_trap_iss      |
                                  take_tge_trap_iss       |
                                  take_tidcp_trap_iss     |
                                  take_fp_id_grp_trap_iss | 
                                  pre_exception_valid_iss) &
                                 (expt_instr_type_iss != `CA53_EXPT_INSTR_TYPE_NULL)) |
                                (take_il_trap_iss & head_instr0_iss_i);

  // ------------------------------------------------------
  // Route exception
  // ------------------------------------------------------

  // Exception can never cause entry into lower exception level, so if target
  // is lower than current then stay in current
  //
  // Current EL | Current Mode  | Current AA  || Target EL  | Target Mode ||   Final EL   |  Final Mode
  // -----------------------------------------------------------------------------------------------------
  //    EL3     |      xxx      |      64     ||    xxx     |     xxx     ||    EL3       |     EL3H
  //    EL3     |      xxx      |      32     ||    xxx     |     xxx     ||    EL3       |   target_mode
  //            |               |             ||            |             ||              |
  //    EL2     |     (Hyp)     |      xx     ||    EL3     |     xxx     || (target_el)  |   target_mode
  //    EL2     |     (Hyp)     |      xx     ||    EL2     |    (Hyp)    || (target_el)  |  (target_mode)
  //    EL2     |     (Hyp)     |      xx     ||    EL1     |     xxx     ||    EL2       |     (Hyp)
  //            |               |             ||            |             ||              |
  //    EL0/1   |      xxx      |      xx     ||    xxx     |     xxx     ||  target_el   |   target_mode
  //
  always @* begin
    case (dpu_exception_level_i)
      `CA53_EL3: begin
        // Always stay in EL3
        exception_el_iss   = `CA53_EL3;
        // If EL3 is AA32, can go to target mode, as all secure kernel
        // modes are implemented at EL3
        exception_mode_iss = aarch64_at_el_rs[3] ? `CA53_FULL_MODE_EL3H : target_mode_iss;
      end
      `CA53_EL2: begin
        case (target_el_iss)
          `CA53_EL3: begin
            // Target is higher, so can change
            exception_el_iss   = `CA53_EL3;
            exception_mode_iss = aarch64_at_el_rs[3] ? `CA53_FULL_MODE_EL3H : target_mode_iss;
          end
          `CA53_EL2: begin
            // Target is current, so can change
            exception_el_iss   = `CA53_EL2;
            exception_mode_iss = aarch64_at_el_rs[2] ? `CA53_FULL_MODE_EL2H : target_mode_iss;
          end
          `CA53_EL1: begin
            // Target is lower, so stay in EL2
            exception_el_iss   = `CA53_EL2;
            exception_mode_iss = aarch64_at_el_rs[2] ? `CA53_FULL_MODE_EL2H : `CA53_FULL_MODE_HYP;
          end
          default: begin
            exception_el_iss   = 2'bxx;
            exception_mode_iss = 5'bxxxxx;
          end
        endcase
      end
      `CA53_EL1,
      `CA53_EL0: begin
        // Target will always be same or lower, so can always go to target
        case (target_el_iss)
          `CA53_EL3: begin
            exception_el_iss   = `CA53_EL3;
            exception_mode_iss = aarch64_at_el_rs[3]       ? `CA53_FULL_MODE_EL3H 
                                                           : target_mode_iss;
          end
          `CA53_EL2: begin 
            exception_el_iss   = (~aarch64_at_el_rs[3] & ~ns_state_rs) ? `CA53_EL3            : target_el_iss;
            exception_mode_iss = aarch64_at_el_rs[2]                   ? `CA53_FULL_MODE_EL2H : target_mode_iss;
          end
          `CA53_EL1: begin 
            exception_el_iss   = (~aarch64_at_el_rs[3] & ~ns_state_rs) ? `CA53_EL3            : target_el_iss;
            exception_mode_iss = aarch64_at_el_rs[1]                   ? `CA53_FULL_MODE_EL1H : target_mode_iss;
          end
          default:  begin
            exception_el_iss   = 2'bxx;
            exception_mode_iss = 5'bxxxxx;
          end
        endcase
      end
      default: begin
        exception_el_iss   = 2'bxx;
        exception_mode_iss = 5'bxxxxx;
      end
    endcase
  end

  assign trapping_to_el2 = (exception_el_iss == `CA53_EL2) & (dpu_exception_level_i != `CA53_EL2);

  always @*
    case (exception_el_iss)
      `CA53_EL1: exception_aa64_iss = aarch64_at_el_rs[1];
      `CA53_EL2: exception_aa64_iss = aarch64_at_el_rs[2];
      `CA53_EL3: exception_aa64_iss = aarch64_at_el_rs[3];
      default:   exception_aa64_iss = 1'bx;
    endcase


  // ------------------------------------------------------
  // Pipeline exception data to Ex1
  // ------------------------------------------------------

  // Since the exception type in Ex1 is qualified with syndrome_type, not all
  // bits of the signal need pipelining, and encodings can overlap. For most
  // exception types it is possible to just take the bottom bits of the Iss
  // stage signal directly, but for FP/NEON encodings the value must be
  // overridden, as there are multiple FP types (IDs etc.).
  assign nxt_expt_instr_type_ex1 = (syndrome_type_iss == `CA53_SYND_TYPE_FP_NEON) 
                                    ? (((expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_NEON) |
                                        (expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_CRYPTO)) ? `CA53_EXPT_INSTR_TYPE_EX1_NEON
                                                                                               : `CA53_EXPT_INSTR_TYPE_EX1_FP)
                                    : expt_instr_type_iss[1:0];

  // Exception data
  // - only pipeline when there is an exception detected in Iss
  assign exception_data_ex1_en = exception_valid_iss & ~ilock_stall_iss_i;

  always @(posedge clk)
    if (exception_data_ex1_en) begin
      // Exception bus data calculated in Iss
      expt_type_ex1           <= expt_type_iss[`CA53_EXPT_TYPE_W-1:0];
      high_priority_ex1       <= high_priority_iss;
      enter_halt_ex1          <= enter_halt_iss;
      expt_vec_offset_ex1     <= expt_vec_offset_iss[4:2];
      cpsr_wr_en_ex1          <= cpsr_wr_en_iss[1:0];
      quash_ex1               <= quash_iss;
      exception_el_ex1        <= exception_el_iss[1:0];
      exception_mode_ex1      <= exception_mode_iss[4:0];
      forceop_offset_aa32_ex1 <= forceop_offset_aa32_iss[`CA53_FORCEOP_OFFSET_TYPE_W-1:0];
      debug_status_ex1        <= debug_status_iss;
      // Instruction information to form final exception data bus bits in Ex1
      instr_ex1               <= instr_iss[27:0];
      instr_d_bit_ex1         <= instr_d_bit_iss;
      instr_is_ls_ex1         <= instr_is_ls_iss;
      instr_misc_ex1          <= instr_misc_iss;
      syndrome_type_ex1       <= syndrome_type_iss;
      take_tge_trap_ex1       <= take_tge_trap_iss;
      expt_instr_type_ex1     <= nxt_expt_instr_type_ex1;
      exception_aa64_ex1      <= exception_aa64_iss;
    end


  // ------------------------------------------------------
  // Form syndrome information in Ex1
  // ------------------------------------------------------

  // Where an AA32 register is reported on an exception taken in AA64, the
  // register number must be converted to the AA64 view of the register.
  ca53dpu_ctl_reg_aa32_aa64 u_reg_aa32_aa64_15_12 (
    .aa32_addr_i      (instr_ex1[15:12]),
    .cpsr_mode_ret_i  (cpsr_mode_ret_i),
    .aa64_addr_o      (aa64_reg_15_12_ex1)
  );

  ca53dpu_ctl_reg_aa32_aa64 u_reg_aa32_aa64_19_16 (
    .aa32_addr_i      (instr_ex1[19:16]),
    .cpsr_mode_ret_i  (cpsr_mode_ret_i),
    .aa64_addr_o      (aa64_reg_19_16_ex1)
  );

  assign reg_15_12_ex1 = exception_aa64_ex1 ? aa64_reg_15_12_ex1 : {1'b0, instr_ex1[15:12]};
  assign reg_19_16_ex1 = exception_aa64_ex1 ? aa64_reg_19_16_ex1 : {1'b0, instr_ex1[19:16]};

  assign exception_at_same_el_ex1 = (exception_el_ex1 == dpu_exception_level_i);

  assign mcr_mrc_width_ex1 = ~(instr_ex1[27:24] == 4'b1110);  // 0 => MCR/MRC
                                                              // 1 => MCRR/MRRC
  assign mcr_mrc_type_ex1 = instr_ex1[20]; // 1 => MRC
                                           // 0 => MCR

  assign cond_ex1 = (cond_code_instr0_ex1_i == `CA53_CC_NV) ? `CA53_CC_AL
                                                            : cond_code_instr0_ex1_i;

  always @* begin
    exception_syndrome_ex1 = {26{1'b0}};

    case (syndrome_type_ex1)
      `CA53_SYND_TYPE_UNSPEC: begin  // Unknown or Uncategorised Reason
        exception_class_ex1 = 6'h00;

        exception_syndrome_ex1 = {1'b1, {25{1'b0}}};
      end

      `CA53_SYND_TYPE_WFX: begin  // Trapped WFI/WFE
        exception_class_ex1 = 6'h01;

        exception_syndrome_ex1[25]    = instr_size_ex1_i;
        exception_syndrome_ex1[24]    = 1'b1; // Cond is valid
        exception_syndrome_ex1[23:20] = cond_ex1;
        exception_syndrome_ex1[0]     = (expt_instr_type_ex1 == `CA53_EXPT_INSTR_TYPE_EX1_WFE);
      end

      `CA53_SYND_TYPE_SYS_REG: begin
        exception_class_ex1 = aarch64_state_rs              ? 6'h18                               :
                              instr_is_ls_ex1               ? 6'h06                               :
                              (instr_ex1[11:8] == 4'b1010)  ? 6'h08                               :
                              (instr_ex1[11:8] == 4'b1110)  ? (mcr_mrc_width_ex1 ? 6'h0C : 6'h05) :
                                                              (mcr_mrc_width_ex1 ? 6'h04 : 6'h03);

        case ({aarch64_state_rs, instr_is_ls_ex1, mcr_mrc_width_ex1})
          `ca53dpu_sel_1x0: begin // System reg access from AArch64
            exception_syndrome_ex1[25]    = instr_size_ex1_i;
            exception_syndrome_ex1[21:20] = instr_ex1[9:8];                       // Op0
            exception_syndrome_ex1[19:17] = instr_ex1[7:5];                       // Op2
            exception_syndrome_ex1[16:14] = instr_ex1[23:21];                     // Op1
            exception_syndrome_ex1[13:10] = instr_ex1[19:16];                     // CRn
            exception_syndrome_ex1[9:5]   = {instr_d_bit_ex1, instr_ex1[15:12]};  // Rt (Rt[4] is stored in d_bit)
            exception_syndrome_ex1[4:1]   = instr_ex1[3:0];                       // CRm
            exception_syndrome_ex1[0]     = instr_ex1[20];                        // Direction
          end
          `ca53dpu_sel_1x1: begin // PSTATE field access (DAIFset or DAIFclr)
            exception_syndrome_ex1[25]    = instr_size_ex1_i;
            exception_syndrome_ex1[21:20] = 2'b00;                                // Op0
            exception_syndrome_ex1[19:17] = {2'b11, ~instr_ex1[9]};               // Op2
            exception_syndrome_ex1[16:14] = 3'b011;                               // Op1
            exception_syndrome_ex1[13:10] = 4'b0100;                              // CRn
            exception_syndrome_ex1[9:5]   = 5'b11111;                             // Rt
            exception_syndrome_ex1[4:1]   = instr_ex1[8:5];                       // CRm
            exception_syndrome_ex1[0]     = 1'b0;                                 // Direction
          end
          `ca53dpu_sel_01x: begin // LDC/STC to CP14
            // Note that on LS instructions, instr_misc is ls_cp14_ldc_literal
            exception_syndrome_ex1[25]    = instr_size_ex1_i;
            exception_syndrome_ex1[24]    = 1'b1;                                 // Cond is valid
            exception_syndrome_ex1[23:20] = cond_ex1;                             // Condition
            exception_syndrome_ex1[19:12] = instr_ex1[7:0];                       // imm8
            exception_syndrome_ex1[9:5]   = {5{~instr_misc_ex1}} & reg_19_16_ex1; // Rn
            exception_syndrome_ex1[4]     = instr_ex1[23];                        // Offset sign
            exception_syndrome_ex1[3]     = instr_misc_ex1;                       // Addressing mode
            exception_syndrome_ex1[2]     = instr_ex1[24];                        // " "
            exception_syndrome_ex1[1]     = instr_ex1[21] &
                                            (instr_ex1[19:16] != 4'b1111);        // " " (writeback is suppressed if Rn == r15)
            exception_syndrome_ex1[0]     = instr_ex1[20];                        // Direction
          end
          3'b001          : begin // MCRR/MRRC to CP14/15 from AArch32
            exception_syndrome_ex1[25]    = instr_size_ex1_i;
            exception_syndrome_ex1[24]    = 1'b1;                                 // Cond is valid
            exception_syndrome_ex1[23:20] = cond_ex1;                             // Condition
            exception_syndrome_ex1[19:16] = instr_ex1[7:4];                       // opc1
            exception_syndrome_ex1[14:10] = reg_19_16_ex1;                        // Rt2
            exception_syndrome_ex1[9:5]   = reg_15_12_ex1;                        // Rt
            exception_syndrome_ex1[4:1]   = instr_ex1[3:0];                       // CRm
            exception_syndrome_ex1[0]     = mcr_mrc_type_ex1;                     // Direction
          end
          3'b000          : begin // MCR/MRC to CP10/14/15 from AArch32
            exception_syndrome_ex1[25]    = instr_size_ex1_i;
            exception_syndrome_ex1[24]    = 1'b1;                                 // Cond is valid
            exception_syndrome_ex1[23:20] = cond_ex1;                             // Condition
            exception_syndrome_ex1[19:17] = instr_ex1[7:5];                       // opc2
            exception_syndrome_ex1[16:14] = instr_ex1[23:21];                     // opc1
            exception_syndrome_ex1[13:10] = instr_ex1[19:16];                     // CRn
            exception_syndrome_ex1[9:5]   = reg_15_12_ex1;                        // Rt
            exception_syndrome_ex1[4:1]   = instr_ex1[3:0];                       // CRm
            exception_syndrome_ex1[0]     = mcr_mrc_type_ex1;                     // Direction
          end
          default: begin
            exception_syndrome_ex1 = {26{1'bx}};
          end
        endcase
      end

      `CA53_SYND_TYPE_FP_NEON: begin  // Exceptions from access to AdvSIMD/FP regs
        case (take_tge_trap_ex1)
          1'b1: begin
            exception_class_ex1 = 6'h00;

            exception_syndrome_ex1[25]    = 1'b1;
          end
          1'b0: begin
            exception_class_ex1 = 6'h07;

            exception_syndrome_ex1[25]    = instr_size_ex1_i;
            exception_syndrome_ex1[24]    = 1'b1;                                                   // Cond is valid
            exception_syndrome_ex1[23:20] = cond_ex1;                                               // Condition
            exception_syndrome_ex1[5]     = expt_instr_type_ex1[0] & ~exception_aa64_ex1;           // Trapped NEON (not valid in AA64 ESR)
            exception_syndrome_ex1[3:0]   = (expt_instr_type_ex1[0] | exception_aa64_ex1) ? 4'h0 :  // Copro - not valid on NEON or AA64 ESR
                                                                                            4'ha;   // - 0xA on FP
          end
          default: begin
            exception_class_ex1    = {6{1'bx}};
            exception_syndrome_ex1 = {26{1'bx}};
          end
        endcase
      end

      `CA53_SYND_TYPE_CALL: begin
        case ({aarch64_state_rs, expt_instr_type_ex1})
          {1'b0, `CA53_EXPT_INSTR_TYPE_EX1_SVC}: begin  // SVC executed in AArch32
            exception_class_ex1 = 6'h11;

            exception_syndrome_ex1[25]    = instr_size_ex1_i;
            exception_syndrome_ex1[15:0]  = {instr_ex1[23:16], instr_ex1[7:0]};   // imm16
          end
          {1'b0, `CA53_EXPT_INSTR_TYPE_EX1_HVC}: begin  // HVC executed in AA32
            exception_class_ex1 = 6'h12;

            exception_syndrome_ex1[25]    = instr_size_ex1_i;
            exception_syndrome_ex1[15:0]  = {instr_ex1[19:16], instr_ex1[11:0]};  // imm16
          end
          {1'b0, `CA53_EXPT_INSTR_TYPE_EX1_SMC}: begin  // SMC executed in AA32
            exception_class_ex1 = 6'h13;

            exception_syndrome_ex1[25]    = instr_size_ex1_i;
          end
          {1'b1, `CA53_EXPT_INSTR_TYPE_EX1_SVC}: begin  // SVC executed in AA64
            exception_class_ex1 = 6'h15;

            exception_syndrome_ex1[25]    = instr_size_ex1_i;
            exception_syndrome_ex1[15:0]  = {instr_ex1[23:16], instr_ex1[7:0]};   // imm16
          end
          {1'b1, `CA53_EXPT_INSTR_TYPE_EX1_HVC}: begin  // HVC executed in AA64
            exception_class_ex1 = 6'h16;

            exception_syndrome_ex1[25]    = instr_size_ex1_i;
            exception_syndrome_ex1[15:0]  = {instr_ex1[19:16], instr_ex1[11:0]};  // imm16
          end
          {1'b1, `CA53_EXPT_INSTR_TYPE_EX1_SMC}: begin  // SMC executed in AA64
            exception_class_ex1 = 6'h17;

            exception_syndrome_ex1[25]    = instr_size_ex1_i;
            exception_syndrome_ex1[15:0]  = {instr_ex1[19:16], instr_ex1[11:0]};  // imm16
          end
          default: begin
            exception_class_ex1    = {6{1'bx}};
            exception_syndrome_ex1 = {26{1'bx}};
          end
        endcase
      end

      `CA53_SYND_TYPE_FABORT: begin  // Instruction abort
        exception_syndrome_ex1[25]    = 1'b1;

        if (iabort_alignment) begin
          exception_class_ex1 = 6'h22;
        end else begin
          exception_class_ex1 = exception_at_same_el_ex1 ? 6'h21 : 6'h20;

          exception_syndrome_ex1[9]   = ifu_ifsr_rs[6];        // EA
          exception_syndrome_ex1[7]   = ifu_ifsr_stage2_rs[0]; // S1PTW
          exception_syndrome_ex1[5:0] = ifu_ifsr_rs[5:0];      // IFSC
        end
      end

      `CA53_SYND_TYPE_DEBUG: begin
        case ({exception_aa64_ex1, expt_instr_type_ex1})
          {1'b1, `CA53_EXPT_INSTR_TYPE_EX1_HW_BKPT}: begin
            exception_class_ex1 = exception_at_same_el_ex1 ? 6'h31 : 6'h30;

            exception_syndrome_ex1[25]   = 1'b1;
            exception_syndrome_ex1[5:0]  = 6'b100010;
          end
          {1'b1, `CA53_EXPT_INSTR_TYPE_EX1_BKPT}: begin // AArch64 BRK/AArch32 BKPT instruction
            exception_class_ex1 = aarch64_state_rs ? 6'h3C : 6'h38;

            exception_syndrome_ex1[25]   = instr_size_ex1_i;
            exception_syndrome_ex1[15:0] = {instr_ex1[23:16], instr_ex1[7:0]};
          end
          {1'b1, `CA53_EXPT_INSTR_TYPE_EX1_VECT_CATCH}: begin
            exception_class_ex1 = 6'h3A;

            exception_syndrome_ex1[25]   = 1'b1;
            exception_syndrome_ex1[5:0]  = 6'b100010;
          end
          `ca53dpu_sel_0xx: begin
            exception_class_ex1 = exception_at_same_el_ex1 ? 6'h21 : 6'h20;

            exception_syndrome_ex1[25]   = 1'b1;
            exception_syndrome_ex1[5:0]  = 6'b100010;
          end
          default: begin
            exception_class_ex1    = {6{1'bx}};
            exception_syndrome_ex1 = {26{1'bx}};
          end
        endcase
      end

      `CA53_SYND_TYPE_IL_BIT: begin  // Illegal instruction set state
        exception_class_ex1 = 6'h0E;

        exception_syndrome_ex1[25]   = 1'b1;
      end

      default: begin
        exception_class_ex1    = {6{1'bx}};
        exception_syndrome_ex1 = {26{1'bx}};
      end
    endcase
  end

  // ------------------------------------------------------
  // Ex1->Wr Exception pipeline
  // ------------------------------------------------------

  // Pack exception data onto exception bus
  assign exception_data_ex1[`CA53_EXPT_BUS_EXPT_TYPE_BITS]   = expt_type_ex1[`CA53_EXPT_TYPE_W-1:0];
  assign exception_data_ex1[`CA53_EXPT_BUS_HIGH_PRI_BIT]     = high_priority_ex1;
  assign exception_data_ex1[`CA53_EXPT_BUS_ENTER_HALT_BIT]   = enter_halt_ex1;
  assign exception_data_ex1[`CA53_EXPT_BUS_VEC_OFFSET_BITS]  = expt_vec_offset_ex1[4:2];
  assign exception_data_ex1[`CA53_EXPT_BUS_CPSR_BITS]        = cpsr_wr_en_ex1[1:0];
  assign exception_data_ex1[`CA53_EXPT_BUS_QUASH_BIT]        = quash_ex1;
  assign exception_data_ex1[`CA53_EXPT_BUS_TARGET_EL_BITS]   = exception_el_ex1[1:0];
  assign exception_data_ex1[`CA53_EXPT_BUS_TARGET_MODE_BITS] = exception_mode_ex1[4:0];
  assign exception_data_ex1[`CA53_EXPT_BUS_FORCEOP_BITS]     = forceop_offset_aa32_ex1[`CA53_FORCEOP_OFFSET_TYPE_W-1:0];
  assign exception_data_ex1[`CA53_EXPT_BUS_DBG_STATUS_BITS]  = debug_status_ex1;
  assign exception_data_ex1[`CA53_EXPT_BUS_EC_BITS]          = exception_class_ex1[5:0];
  assign exception_data_ex1[`CA53_EXPT_BUS_ESR_BITS]         = exception_syndrome_ex1[25:0];

  // Regionally gate the Ex1/Ex2 exception pipeline registers
  assign expt_clock_en = exception_valid_ex1_i | exception_valid_ex2_i;

  ca53_cell_inter_clkgate u_inter_clkgate_expt (
    .clk_i         (clk),
    .clk_enable_i  (expt_clock_en),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_expt));

  // Pipeline registers
  assign exception_en_ex1 = exception_valid_ex1_i & ~stall_wr_i;
  assign exception_en_ex2 = exception_valid_ex2_i & ~stall_wr_i;

  always @(posedge clk_expt)
    if (exception_en_ex1)
      exception_data_ex2 <= exception_data_ex1;

  always @(posedge clk_expt)
    if (exception_en_ex2)
      exception_data_wr <= exception_data_ex2;

  // ------------------------------------------------------
  // Outputs
  // ------------------------------------------------------

  assign exception_data_wr_o = exception_data_wr;

  // Indicate fetch aborts
  assign expt_full_pc_iss_o = (expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_FABORT)      |
                              (expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_RESET_CATCH) |
                              (expt_instr_type_iss == `CA53_EXPT_INSTR_TYPE_EXPT_CATCH);

  assign exception_valid_iss_o = exception_valid_iss;

  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  reg ovl_exception_valid_ex1;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_exception_valid_ex1 <= 1'b0;
    else if (~ilock_stall_iss_i)
      ovl_exception_valid_ex1 <= exception_valid_iss & ~flush_ret_i;

  //----------------------------------------------------------------------------
  // Automatically generated x-check assertions on register enables
  //----------------------------------------------------------------------------
  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: exception_data_ex1_en")
  u_ovl_x_exception_data_ex1_en (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (exception_data_ex1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: exception_en_ex1")
  u_ovl_x_exception_en_ex1 (.clk       (clk_expt),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (exception_en_ex1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: exception_en_ex2")
  u_ovl_x_exception_en_ex2 (.clk       (clk_expt),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (exception_en_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: expt_instr_ctl_iss_en")
  u_ovl_x_expt_instr_ctl_iss_en (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (expt_instr_ctl_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: expt_instr_dp_iss_en")
  u_ovl_x_expt_instr_iss_en (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (expt_instr_dp_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: expt_instr_type_iss_en")
  u_ovl_x_expt_instr_type_iss_en (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (expt_instr_type_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: iabort_alignment")
  u_ovl_x_iabort_alignment (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (iabort_alignment));
  
  //----------------------------------------------------------------------------
  // The exception class should always be a valid value
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"exception class not valid value")
    ovl_ec_valid       (.clk              (clk),
                        .reset_n          (reset_n),
                        .antecedent_expr  (ovl_exception_valid_ex1 & ~flush_ret_i),
                        .consequent_expr  ((exception_class_ex1 == 6'h00) |
                                           (exception_class_ex1 == 6'h01) |
                                           (exception_class_ex1 == 6'h03) |
                                           (exception_class_ex1 == 6'h04) |
                                           (exception_class_ex1 == 6'h05) |
                                           (exception_class_ex1 == 6'h06) |
                                           (exception_class_ex1 == 6'h07) |
                                           (exception_class_ex1 == 6'h08) |
                                           (exception_class_ex1 == 6'h0C) |
                                           (exception_class_ex1 == 6'h0E) |
                                           (exception_class_ex1 == 6'h11) |
                                           (exception_class_ex1 == 6'h12) |
                                           (exception_class_ex1 == 6'h13) |
                                           (exception_class_ex1 == 6'h15) |
                                           (exception_class_ex1 == 6'h16) |
                                           (exception_class_ex1 == 6'h17) |
                                           (exception_class_ex1 == 6'h18) |
                                           (exception_class_ex1 == 6'h20) |
                                           (exception_class_ex1 == 6'h21) |
                                           (exception_class_ex1 == 6'h22) |
                                           (exception_class_ex1 == 6'h30) |
                                           (exception_class_ex1 == 6'h31) |
                                           (exception_class_ex1 == 6'h38) |
                                           (exception_class_ex1 == 6'h3A) |
                                           (exception_class_ex1 == 6'h3C)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Signals used in if statements should not be X when used
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "exception_aa64_iss X when looked at in exception_syndrome_ex1 case statement")
  u_ovl_expt_expt_aa64_x     (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (syndrome_type_iss == `CA53_SYND_TYPE_DEBUG),
                              .test_expr (exception_aa64_iss));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Default branch of exception_syndrome_ex1 case statement should never be reached
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 26, `OVL_ASSERT, "exception_syndrome_ex1 x-assignment should not be reached")
  u_ovl_expt_synd_x          (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (ovl_exception_valid_ex1 & ~flush_ret_i),
                              .test_expr (exception_syndrome_ex1));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Should never try and take an exception at a lower exception level than current
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Iss is trying to go to lower exception level than current")
    ovl_el_lower       (.clk              (clk),
                        .reset_n          (reset_n),
                        .antecedent_expr  (exception_valid_iss_o),
                        .consequent_expr  (exception_el_iss >= dpu_exception_level_i));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Should never try and take an exception at EL0
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Iss is trying to take exception in EL0")
    ovl_el0            (.clk              (clk),
                        .reset_n          (reset_n),
                        .antecedent_expr  (exception_valid_iss_o),
                        .consequent_expr  (exception_el_iss != `CA53_EL0));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Final target EL should always be higher than EL0
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Iss is trying to target EL0")
    ovl_el0_target     (.clk              (clk),
                        .reset_n          (reset_n),
                        .antecedent_expr  (exception_valid_iss_o),
                        .consequent_expr  (target_el_iss != `CA53_EL0));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Should never try and go to AA32 mode on exception taken in AA64
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Iss is trying to go from AA64 to AA32")
    ovl_el_aa64_to_aa32(.clk              (clk),
                        .reset_n          (reset_n),
                        .antecedent_expr  (exception_valid_iss_o & aarch64_state_i),
                        .consequent_expr  (~exception_mode_iss[4]));  // Mode[4] specifies AA32/64
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Mode should be consistent with exception level
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Iss: Mode not consistent with target exception level of AA64 EL1")
    ovl_mode_el_aa64_el1 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (exception_valid_iss_o & ~flush_ret_i & (exception_el_iss == `CA53_EL1) & aarch64_at_el_rs[1] &
                                             (pre_expt_type_iss != `CA53_EXPT_TYPE_DEBUG_HLT) & (pre_expt_type_iss != `CA53_EXPT_TYPE_ECC_REEXEC)),
                          .consequent_expr  (exception_mode_iss == `CA53_FULL_MODE_EL1H));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Iss: Mode not consistent with target exception level of AA32 EL1")
    ovl_mode_el_aa32_el1 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (exception_valid_iss_o & ~flush_ret_i & (exception_el_iss == `CA53_EL1) & ~aarch64_at_el_rs[1] &
                                             (pre_expt_type_iss != `CA53_EXPT_TYPE_DEBUG_HLT) & (pre_expt_type_iss != `CA53_EXPT_TYPE_ECC_REEXEC)),
                          .consequent_expr  ((exception_mode_iss == `CA53_FULL_MODE_SVC) |
                                             (exception_mode_iss == `CA53_FULL_MODE_ABT) |
                                             (exception_mode_iss == `CA53_FULL_MODE_UND)));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Iss: Mode not consistent with target exception level of AA64 EL2")
    ovl_mode_el_aa64_el2 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (exception_valid_iss_o & ~flush_ret_i & (exception_el_iss == `CA53_EL2) & aarch64_at_el_rs[2] &
                                             (pre_expt_type_iss != `CA53_EXPT_TYPE_DEBUG_HLT) & (pre_expt_type_iss != `CA53_EXPT_TYPE_ECC_REEXEC)),
                          .consequent_expr  (exception_mode_iss == `CA53_FULL_MODE_EL2H));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Iss: Mode not consistent with target exception level of AA32 EL2")
    ovl_mode_el_aa32_el2 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (exception_valid_iss_o & ~flush_ret_i & (exception_el_iss == `CA53_EL2) & ~aarch64_at_el_rs[2] &
                                             (pre_expt_type_iss != `CA53_EXPT_TYPE_DEBUG_HLT) & (pre_expt_type_iss != `CA53_EXPT_TYPE_ECC_REEXEC)),
                          .consequent_expr  (exception_mode_iss == `CA53_FULL_MODE_HYP));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Iss: Mode not consistent with target exception level of AA64 EL3")
    ovl_mode_el_aa64_el3 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (exception_valid_iss_o & ~flush_ret_i & (exception_el_iss == `CA53_EL3) & aarch64_at_el_rs[3] &
                                             (pre_expt_type_iss != `CA53_EXPT_TYPE_DEBUG_HLT) & (pre_expt_type_iss != `CA53_EXPT_TYPE_ECC_REEXEC)),
                          .consequent_expr  (exception_mode_iss == `CA53_FULL_MODE_EL3H));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Iss: Mode not consistent with target exception level of AA32 EL3")
    ovl_mode_el_aa32_el3 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (exception_valid_iss_o & ~flush_ret_i & (exception_el_iss == `CA53_EL3) & ~aarch64_at_el_rs[3] &
                                             (pre_expt_type_iss != `CA53_EXPT_TYPE_DEBUG_HLT) & (pre_expt_type_iss != `CA53_EXPT_TYPE_ECC_REEXEC)),
                          .consequent_expr  ((exception_mode_iss == `CA53_FULL_MODE_SVC) |
                                             (exception_mode_iss == `CA53_FULL_MODE_ABT) |
                                             (exception_mode_iss == `CA53_FULL_MODE_UND) |
                                             (exception_mode_iss == `CA53_FULL_MODE_MON)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Default branch of exception_mode_iss/exception_el_iss case statement should never be reached
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 5, `OVL_ASSERT, "exception_mode_iss x-assignment should not be reached")
  u_ovl_expt_mode_x          (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (exception_valid_iss_o),
                              .test_expr (exception_mode_iss));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "exception_el_iss x-assignment should not be reached")
  u_ovl_expt_el_x            (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (exception_valid_iss_o),
                              .test_expr (exception_el_iss));
  // OVL_ASSERT_END

`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
