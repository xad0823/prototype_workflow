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
// Description: CPU level of the Governor
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53governor_cpu `CA53_GOVERNOR_PARAM_DECL (
  // Inputs
  input  wire                                  CLKIN,
  input  wire                                  DFTSE,
  input  wire                                  DFTRSTDISABLE,
  input  wire                                  ncpuporeset,
  input  wire                                  ncorereset,
  input  wire                                  nl2reset_synced_pipelined,
  input  wire                                  nl2reset_synced,
  input  wire                                  nmbistreset_synced_pipelined,
  input  wire                                  nmbistreset_synced,
  input  wire                                  npresetdbg_gov,
  input  wire                                  cfgend_i,
  input  wire                                  vinithi_i,
  input  wire                                  cfgte_i,
  input  wire                                  cp15sdisable_i,
  input  wire [  1: 0]                         cpu_id_i,
  input  wire [  7: 0]                         clusteridaff1_rs_i,
  input  wire [  7: 0]                         clusteridaff2_rs_i,
  input  wire                                  etm_oslock_i,
  input  wire                                  aa64naa32_i,
  input  wire [ 39: 2]                         rvbaraddr_i,
  input  wire                                  cryptodisable_i,
  input  wire [ 63: 0]                         cntvalueb_rs_i,
  input  wire                                  mbistreq_rs_i,
  input  wire                                  nfiq_i,
  input  wire                                  nirq_i,
  input  wire                                  nsei_i,
  input  wire                                  nrei_i,
  input  wire                                  nvfiq_i,
  input  wire                                  nvirq_i,
  input  wire                                  nvsei_i,
  input  wire                                  gov_giccdisable_i,
  input  wire                                  arb_req_i,
  input  wire [ 31:0]                          arb_data_i,
  input  wire                                  arb_tready_i,
  input  wire                                  clrexmon_rs_i,
  input  wire                                  dpu_sev_req_i,
  input  wire                                  sev_set_event_register_i,
  input  wire                                  dpu_clr_event_register_i,
  input  wire [  1: 0]                         dpu_exception_level_i,
  input  wire                                  dpu_aarch64_at_el3_i,
  input  wire                                  dpu_hcr_el2_fmo_i,
  input  wire                                  dpu_hcr_el2_imo_i,
  input  wire                                  dpu_hcr_el2_amo_i,
  input  wire                                  dpu_monitor_mode_i,
  input  wire                                  dpu_rei_level_ack_i,
  input  wire                                  dpu_scr_el3_fiq_i,
  input  wire                                  dpu_scr_el3_irq_i,
  input  wire                                  dpu_scr_el3_ns_i,
  input  wire                                  dpu_sei_level_ack_i,
  input  wire                                  dpu_vsei_level_ack_i,
  input  wire                                  dpu_wfi_req_i,
  input  wire                                  dpu_wfe_req_i,
  input  wire                                  dpu_irq_pended_i,
  input  wire                                  dpu_fiq_pended_i,
  input  wire                                  dpu_sei_pended_i,
  input  wire                                  dpu_irq_masked_i,
  input  wire                                  dpu_fiq_masked_i,
  input  wire                                  dpu_sei_masked_i,
  input  wire                                  dpu_virq_pended_i,
  input  wire                                  dpu_vfiq_pended_i,
  input  wire                                  dpu_vsei_pended_i,
  input  wire                                  dpu_virq_masked_i,
  input  wire                                  dpu_vfiq_masked_i,
  input  wire                                  dpu_vsei_masked_i,
  input  wire                                  dpu_dbg_double_lock_set_i,
  input  wire                                  dpu_ns_state_i,
  input  wire                                  stb_wfx_ready_i,
  input  wire                                  biu_wfx_ready_i,
  input  wire                                  dcu_wfx_ready_i,
  input  wire                                  ifu_wfx_ready_i,
  input  wire                                  tlb_wfx_ready_i,
  input  wire                                  etm_wfx_ready_i,
  input  wire                                  scu_wfx_ready_i,
  input  wire                                  dpu_imp_abort_pending_i,
  input  wire [(`CA53_RET_CTL_W-1): 0]         dpu_cpuectlr_cpu_ret_delay_i,
  input  wire [(`CA53_RET_CTL_W-1): 0]         dpu_cpuectlr_neon_ret_delay_i,
  input  wire                                  dpu_neon_active_i,
  input  wire                                  dpu_smp_en_i,
  input  wire                                  cpuqreqn_i,
  input  wire                                  neonqreqn_i,
  input  wire                                  scu_ac_valid_i,
  input  wire [(`CA53_PRDATADBG_W-1): 0]       dpu_prdatadbg_i,
  input  wire                                  dpu_preadydbg_i,
  input  wire                                  dpu_pslverrdbg_i,
  input  wire [(`CA53_PRDATADBG_W-1): 0]       etm_prdatadbg_i,
  input  wire                                  etm_preadydbg_i,
  input  wire [  3: 0]                         etm_extout_i,
  input  wire                                  dcu_excl_mon_cleared_i,
  input  wire [(`CA53_CPADDR_W-1):0]           dcu_cp_gov_addr_i,
  input  wire                                  dcu_cp_gov_ns_i,
  input  wire                                  dcu_cp_gov_req_i,
  input  wire [(`CA53_CPSEL_W-1):0]            dcu_cp_gov_sel_i,
  input  wire [(`CA53_CPDATA_W-1):0]           dcu_cp_gov_wdata_i,
  input  wire                                  dcu_cp_gov_wenable_i,
  input  wire [(`CA53_GOV_CPDATA_W-1):0]       cp_l2_rdata_i,
  input  wire                                  apb_dec_pseldbg_dbg_i,
  input  wire                                  apb_dec_pseldbg_pmu_i,
  input  wire                                  apb_dec_pseldbg_etm_i,
  input  wire                                  apb_dec_pseldbg_cti_i,
  input  wire                                  apb_bridge_pseldbg_i,
  input  wire [ 11: 2]                         apb_bridge_paddrdbg_i,
  input  wire                                  apb_bridge_paddrdbg31_i,
  input  wire                                  apb_bridge_pwritedbg_i,
  input  wire [ 31: 0]                         apb_bridge_pwdatadbg_i,
  input  wire                                  dpu_warmrstreq_i,
  input  wire                                  dpu_dbgtrigger_i,
  input  wire                                  dpu_dbgack_i,
  input  wire                                  dpu_commrx_i,
  input  wire                                  dpu_commtx_i,
  input  wire                                  dpu_ncommirq_i,
  input  wire                                  edbgrq_i,
  input  wire                                  dbgen_i,
  input  wire                                  niden_i,
  input  wire                                  spiden_i,
  input  wire                                  spniden_i,
  input  wire                                  dpu_dbgrstreq_i,
  input  wire                                  dpu_dbgnopwrdwn_i,
  input  wire                                  dbgpwrdup_i,
  input  wire                                  dbgl1rstdisable_i,
  input  wire                                  atclken_i,
  input  wire                                  atreadym_i,
  input  wire                                  afvalidm_i,
  input  wire [(`CA53_ATDATAM_W-1): 0]         etm_atdatam_i,
  input  wire                                  etm_atvalidm_i,
  input  wire [(`CA53_ATBYTESM_W-1): 0]        etm_atbytesm_i,
  input  wire                                  etm_afreadym_i,
  input  wire [(`CA53_ATIDM_W-1): 0]           etm_atidm_i,
  input  wire                                  syncreqm_i,
  input  wire [  3: 0]                         ctm_ctichin_i,
  input  wire                                  ctiirqack_i,
  input  wire                                  dpu_npmuirq_i,
  input  wire [(`CA53_PMUEVNT_CPU_W-1): 0]     dpu_pmuevent_i,
  input  wire                                  dpu_dscr_halted_i,
  input  wire                                  scu_inv_all_ack_i,
  input  wire                                  evnt_scu_err_i,
  input  wire                                  evnt_l2_err_i,
  // Outputs
  output wire                                  clk_cpu,
  output wire                                  reset_n_cpu,
  output wire                                  po_reset_n_cpu,
  output wire                                  warmrstreq_o,
  output wire                                  gov_cfgend_o,
  output wire                                  gov_vinithi_o,
  output wire                                  gov_cfgte_o,
  output wire                                  gov_cp15sdisable_o,
  output wire                                  gov_aa64naa32_o,
  output wire [ 39: 2]                         gov_rvbaraddr_o,
  output wire                                  gov_cryptodisable_o,
  output wire                                  gov_stall_neon_o,
  output wire                                  ncntpsirq_o,
  output wire                                  ncntpnsirq_o,
  output wire                                  ncnthpirq_o,
  output wire                                  ncntvirq_o,
  output wire                                  gic_irq_o,
  output wire                                  gic_fiq_o,
  output wire                                  gic_virq_o,
  output wire                                  gic_vfiq_o,
  output wire                                  gov_sei_level_req_o,
  output wire                                  gov_vsei_level_req_o,
  output wire                                  gov_rei_level_req_o,
  output wire                                  gov_int_active_o,
  output wire                                  gic_icc_sre_el1_ns_sre_o,
  output wire                                  gic_icc_sre_el1_s_sre_o,
  output wire                                  gic_icc_sre_el2_enable_o,
  output wire                                  gic_icc_sre_el2_sre_o,
  output wire                                  gic_icc_sre_el3_enable_o,
  output wire                                  gic_icc_sre_el3_sre_o,
  output wire                                  gic_ich_hcr_el2_tall0_o,
  output wire                                  gic_ich_hcr_el2_tall1_o,
  output wire                                  gic_ich_hcr_el2_tc_o,
  output wire                                  gic_arb_ack_o,
  output wire [(`CA53_TDATA_W-1):0]            gic_tdata_o,
  output wire                                  gic_tlast_o,
  output wire                                  gic_tvalid_o,
  output wire                                  gov_stall_dsb_o,
  output wire                                  nvcpumntirq_o,
  output wire                                  gov_standbywfi_o,
  output wire                                  gov_standbywfe_o,
  output wire                                  gov_wfx_drain_req_o,
  output wire                                  gov_wfx_wake_o,
  output wire                                  sev_req_rs_o,
  output wire                                  gov_event_reg_o,
  output wire                                  gov_smpen_o,
  output wire                                  cpuqactive_o,
  output wire                                  cpuqdeny_o,
  output wire                                  cpuqacceptn_o,
  output wire                                  neonqactive_o,
  output wire                                  neonqdeny_o,
  output wire                                  neonqacceptn_o,
  output wire [(`CA53_PRDATADBG_W-1): 0]       prdatadbg_gov_o,
  output wire                                  preadydbg_gov_o,
  output wire                                  pslverrdbg_gov_o,
  output wire                                  dbgack_o,
  output wire                                  commrx_o,
  output wire                                  commtx_o,
  output wire                                  ncommirq_o,
  output wire                                  gov_edbgrq_o,
  output wire                                  gov_dbgen_o,
  output wire                                  gov_niden_o,
  output wire                                  gov_spiden_o,
  output wire                                  gov_spniden_o,
  output wire                                  gov_dbgrestart_o,
  output wire                                  gov_cp_ack_o,
  output wire [(`CA53_CPDATA_W-1):0]           gov_cp_rdata_o,
  output wire                                  gov_pcnt_kernel_access_o,
  output wire                                  gov_pcnt_usr_access_o,
  output wire                                  gov_vcnt_usr_access_o,
  output wire                                  gov_cntp_usr_access_o,
  output wire                                  gov_cntv_usr_access_o,
  output wire                                  gov_cntp_kernel_access_o,
  output wire                                  valid_l2_en_o,
  output wire [(`CA53_GOV_CPDATA_W-1):0]       cp_gov_wdata_rs_o,
  output wire [(`CA53_GOV_CPADDR_W-1):0]       cp_gov_addr_rs_o,
  output wire                                  cp_gov_wenable_rs_o,
  output wire                                  dbgrstreq_o,
  output wire                                  dbgnopwrdwn_o,
  output wire                                  gov_pseldbg_dbg_o,
  output wire                                  gov_pseldbg_pmu_o,
  output wire                                  gov_pseldbg_etm_o,
  output wire                                  gov_penabledbg_o,
  output wire [ 11: 2]                         gov_paddrdbg_o,
  output wire                                  gov_paddrdbg31_o,
  output wire                                  gov_pwritedbg_o,
  output wire [ 31: 0]                         gov_pwdatadbg_o,
  output wire                                  gov_dbgpwrupreq_o,
  output wire                                  dbgpwrupreq_o,
  output wire [3:0]                            gov_extin_o,
  output wire                                  gov_edecr_osuce_o,
  output wire                                  gov_edecr_rce_o,
  output wire                                  gov_edecr_ss_o,
  output wire                                  gov_edlsr_slk_o,
  output wire                                  gov_pmlsr_slk_o,
  output wire                                  gov_etmpdsr_rd_o,
  output wire                                  gov_atclken_o,
  output wire                                  gov_atreadym_o,
  output wire                                  gov_afvalidm_o,
  output wire [(`CA53_ATDATAM_W-1): 0]         atdatam_o,
  output wire                                  atvalidm_o,
  output wire [(`CA53_ATBYTESM_W-1): 0]        atbytesm_o,
  output wire                                  afreadym_o,
  output wire [(`CA53_ATIDM_W-1): 0]           atidm_o,
  output wire                                  gov_syncreqm_o,
  output wire                                  gov_mbistreq_cpu_o,
  output wire                                  npmuirq_o,
  output wire [(`CA53_PMUEVNT_W-1): 0]         pmuevent_o,
  output wire [  3: 0]                         cti_ctichout_o,
  output wire                                  ctiirq_o,
  output wire                                  cti_active_o,
  output wire                                  gov_inv_all_req_o,
  output wire                                  gov_dbgl1rstdisable_o
);

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                                   reset_n_gov;
  wire                                   po_reset_n_gov;
  wire                                   cross_halt;
  wire [(`CA53_PRDATADBG_W-1): 0]        cti_prdatadbg;
  wire                                   cti_preadydbg;
  wire                                   edbgrq_rs;
  wire                                   gov_aa64naa32;
  wire                                   gov_dbgen;
  wire                                   gov_niden;
  wire                                   gov_spiden;
  wire                                   gov_spniden;
  wire                                   gov_edbgrq;
  wire                                   dbgack_rs;
  wire                                   excl_mon_cleared;
  wire                                   commrx_rs;
  wire                                   commtx_rs;
  wire                                   ctiirqack_rs;
  wire                                   ncommirq_rs;
  wire                                   etm_oslock_rs;
  wire [7:0]                             ctitrigin;
  wire [7:0]                             ctitrigout;
  wire [7:0]                             ctitrigoutack;
  wire                                   gate_clk_req;
  wire                                   nfiq_rs;
  wire                                   nirq_rs;
  wire                                   nvfiq_rs;
  wire                                   nvirq_rs;
  wire                                   sei_level_req;
  wire                                   vsei_level_req;
  wire                                   rei_level_req;
  wire                                   gic_irq;
  wire                                   gic_fiq;
  wire                                   gic_virq;
  wire                                   gic_vfiq;
  wire                                   gic_nxt_int_active;
  wire                                   timer_wfe_event;
  wire [(`CA53_CPADDR_W-1):0]            cp_gov_addr_rs;
  wire                                   cp_gov_ns_rs;
  wire                                   cp_gov_req_rs;
  wire [(`CA53_CPSEL_W-1):0]             cp_gov_sel_rs;
  wire [(`CA53_CPDATA_W-1):0]            cp_gov_wdata_rs;
  wire                                   cp_gov_wenable_rs;
  wire                                   gic_cp_ack;
  wire [(`CA53_CPDATA_W-1):0]            gic_cp_rdata;
  wire [(`CA53_CPDATA_W-1):0]            timer_cp_rdata;
  wire                                   valid_timer_en;
  wire                                   gov_pseldbg_cti;
  wire                                   gov_penabledbg;
  wire [ 11: 2]                          gov_paddrdbg;
  wire                                   gov_paddrdbg31;
  wire                                   gov_pwritedbg;
  wire [ 31: 0]                          gov_pwdatadbg;
  wire                                   npmuirq_rs;
  wire [  1: 0]                          gov_exception_level;
  wire                                   gov_aarch64_at_el3;
  wire                                   gov_hcr_el2_fmo;
  wire                                   gov_hcr_el2_imo;
  wire                                   gov_hcr_el2_amo;
  wire                                   gov_monitor_mode;
  wire                                   gov_scr_el3_irq;
  wire                                   gov_scr_el3_fiq;
  wire                                   gov_scr_el3_ns;
  wire                                   atvalidm;
  wire                                   gov_cryptodisable;
  wire                                   event_cpu_ret;
  wire                                   event_neon_ret;
  wire                                   cpu_in_retention;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                                    dbgtrigger;
  reg                                    dbgtrigger_req;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Clock and Reset Block
  // ------------------------------------------------------

  ca53governor_cpu_clk_reset u_governor_cpu_clk_reset (
    // Inputs
    .CLKIN                         (CLKIN),
    .DFTSE                         (DFTSE),
    .DFTRSTDISABLE                 (DFTRSTDISABLE),
    .ncpuporeset                   (ncpuporeset),
    .ncorereset                    (ncorereset),
    .nl2reset_synced_pipelined     (nl2reset_synced_pipelined),
    .nl2reset_synced               (nl2reset_synced),
    .nmbistreset_synced_pipelined  (nmbistreset_synced_pipelined),
    .nmbistreset_synced            (nmbistreset_synced),
    .gate_clk_req_i                (gate_clk_req),
    .mbistreq_rs_i                 (mbistreq_rs_i),
    // Outputs
    .clk_cpu                       (clk_cpu),
    .reset_n_cpu                   (reset_n_cpu),
    .reset_n_gov                   (reset_n_gov),
    .po_reset_n_cpu                (po_reset_n_cpu),
    .po_reset_n_gov                (po_reset_n_gov));

  // ------------------------------------------------------
  // Architectural Timer Block
  // ------------------------------------------------------

  ca53governor_cpu_timers u_governor_cpu_timers (
    // Inputs
    .CLKIN                         (CLKIN),
    .DFTSE                         (DFTSE),
    .clk_cpu                       (clk_cpu),
    .reset_n_gov                   (reset_n_gov),
    .valid_timer_en_i              (valid_timer_en),
    .cp_gov_addr_rs_i              (cp_gov_addr_rs[(`CA53_GOV_CPADDR_W-1):0]),
    .cp_gov_wdata_rs_i             (cp_gov_wdata_rs[(`CA53_CPDATA_W-1):0]),
    .cp_gov_wenable_rs_i           (cp_gov_wenable_rs),
    .cntvalueb_rs_i                (cntvalueb_rs_i[63:0]),
    .dcu_cp_gov_req_i              (dcu_cp_gov_req_i),
    .dcu_cp_gov_sel_i              (dcu_cp_gov_sel_i[2]),
    // Outputs
    .timer_cp_rdata_o              (timer_cp_rdata[63:0]),
    .gov_pcnt_kernel_access_o      (gov_pcnt_kernel_access_o),
    .gov_pcnt_usr_access_o         (gov_pcnt_usr_access_o),
    .gov_vcnt_usr_access_o         (gov_vcnt_usr_access_o),
    .gov_cntp_usr_access_o         (gov_cntp_usr_access_o),
    .gov_cntv_usr_access_o         (gov_cntv_usr_access_o),
    .gov_cntp_kernel_access_o      (gov_cntp_kernel_access_o),
    .ncntpsirq_o                   (ncntpsirq_o),
    .ncntpnsirq_o                  (ncntpnsirq_o),
    .ncnthpirq_o                   (ncnthpirq_o),
    .ncntvirq_o                    (ncntvirq_o),
    .timer_wfe_event_o             (timer_wfe_event));

  // ------------------------------------------------------
  // CPU Power Control Block
  // ------------------------------------------------------

  ca53governor_cpu_power u_governor_cpu_power (
    // Inputs
    .CLKIN                         (CLKIN),
    .DFTSE                         (DFTSE),
    .clk_cpu                       (clk_cpu),
    .reset_n_gov                   (reset_n_gov),
    .cntvalueb_rs_i                (cntvalueb_rs_i[9:0]),
    .sev_set_event_register_i      (sev_set_event_register_i),
    .excl_mon_cleared_i            (excl_mon_cleared),
    .dpu_clr_event_register_i      (dpu_clr_event_register_i),
    .dpu_wfi_req_i                 (dpu_wfi_req_i),
    .dpu_wfe_req_i                 (dpu_wfe_req_i),
    .dpu_exception_level_i         (dpu_exception_level_i[1:0]),
    .dpu_aarch64_at_el3_i          (dpu_aarch64_at_el3_i),
    .dpu_irq_pended_i              (dpu_irq_pended_i),
    .dpu_fiq_pended_i              (dpu_fiq_pended_i),
    .dpu_sei_pended_i              (dpu_sei_pended_i),
    .dpu_irq_masked_i              (dpu_irq_masked_i),
    .dpu_fiq_masked_i              (dpu_fiq_masked_i),
    .dpu_sei_masked_i              (dpu_sei_masked_i),
    .dpu_virq_pended_i             (dpu_virq_pended_i),
    .dpu_vfiq_pended_i             (dpu_vfiq_pended_i),
    .dpu_vsei_pended_i             (dpu_vsei_pended_i),
    .dpu_virq_masked_i             (dpu_virq_masked_i),
    .dpu_vfiq_masked_i             (dpu_vfiq_masked_i),
    .dpu_vsei_masked_i             (dpu_vsei_masked_i),
    .dpu_hcr_el2_fmo_i             (dpu_hcr_el2_fmo_i),
    .dpu_hcr_el2_imo_i             (dpu_hcr_el2_imo_i),
    .dpu_hcr_el2_amo_i             (dpu_hcr_el2_amo_i),
    .dpu_monitor_mode_i            (dpu_monitor_mode_i),
    .dpu_scr_el3_irq_i             (dpu_scr_el3_irq_i),
    .dpu_scr_el3_fiq_i             (dpu_scr_el3_fiq_i),
    .dpu_scr_el3_ns_i              (dpu_scr_el3_ns_i),
    .dpu_dbg_double_lock_set_i     (dpu_dbg_double_lock_set_i),
    .dpu_ns_state_i                (dpu_ns_state_i),
    .dpu_cpuectlr_cpu_ret_delay_i  (dpu_cpuectlr_cpu_ret_delay_i[2:0]),
    .dpu_cpuectlr_neon_ret_delay_i (dpu_cpuectlr_neon_ret_delay_i[2:0]),
    .dpu_neon_active_i             (dpu_neon_active_i),
    .stb_wfx_ready_i               (stb_wfx_ready_i),
    .biu_wfx_ready_i               (biu_wfx_ready_i),
    .dcu_wfx_ready_i               (dcu_wfx_ready_i),
    .ifu_wfx_ready_i               (ifu_wfx_ready_i),
    .tlb_wfx_ready_i               (tlb_wfx_ready_i),
    .etm_wfx_ready_i               (etm_wfx_ready_i),
    .scu_wfx_ready_i               (scu_wfx_ready_i),
    .dpu_imp_abort_pending_i       (dpu_imp_abort_pending_i),
    .timer_wfe_event_i             (timer_wfe_event),
    .clrexmon_rs_i                 (clrexmon_rs_i),
    .gov_dbgen_i                   (gov_dbgen),
    .gov_giccdisable_i             (gov_giccdisable_i),
    .gov_spiden_i                  (gov_spiden),
    .gov_edbgrq_i                  (gov_edbgrq),
    .gic_irq_i                     (gic_irq),
    .gic_fiq_i                     (gic_fiq),
    .gic_virq_i                    (gic_virq),
    .gic_vfiq_i                    (gic_vfiq),
    .sei_level_req_i               (sei_level_req),
    .vsei_level_req_i              (vsei_level_req),
    .rei_level_req_i               (rei_level_req),
    .cpuqreqn_i                    (cpuqreqn_i),
    .neonqreqn_i                   (neonqreqn_i),
    .scu_ac_valid_i                (scu_ac_valid_i),
    .atvalidm_i                    (atvalidm),
    .apb_bridge_pseldbg_i          (apb_bridge_pseldbg_i),
    // Outputs
    .gov_event_reg_o               (gov_event_reg_o),
    .gov_standbywfi_o              (gov_standbywfi_o),
    .gov_standbywfe_o              (gov_standbywfe_o),
    .gov_wfx_drain_req_o           (gov_wfx_drain_req_o),
    .gov_wfx_wake_o                (gov_wfx_wake_o),
    .gate_clk_req_o                (gate_clk_req),
    .cpuqactive_o                  (cpuqactive_o),
    .cpuqdeny_o                    (cpuqdeny_o),
    .cpuqacceptn_o                 (cpuqacceptn_o),
    .neonqactive_o                 (neonqactive_o),
    .neonqdeny_o                   (neonqdeny_o),
    .neonqacceptn_o                (neonqacceptn_o),
    .event_cpu_ret_o               (event_cpu_ret),
    .event_neon_ret_o              (event_neon_ret),
    .cpu_in_retention_o            (cpu_in_retention),
    .gov_stall_neon_o              (gov_stall_neon_o),
    .gov_exception_level_o         (gov_exception_level[1:0]),
    .gov_aarch64_at_el3_o          (gov_aarch64_at_el3),
    .gov_hcr_el2_fmo_o             (gov_hcr_el2_fmo),
    .gov_hcr_el2_imo_o             (gov_hcr_el2_imo),
    .gov_hcr_el2_amo_o             (gov_hcr_el2_amo),
    .gov_monitor_mode_o            (gov_monitor_mode),
    .gov_scr_el3_irq_o             (gov_scr_el3_irq),
    .gov_scr_el3_fiq_o             (gov_scr_el3_fiq),
    .gov_scr_el3_ns_o              (gov_scr_el3_ns));

  // ------------------------------------------------------
  // ATB bridge
  // ------------------------------------------------------

  ca53governor_cpu_atb_bridge u_governor_cpu_atb_bridge (
    // Inputs
    .CLKIN                         (CLKIN),
    .clk_cpu                       (clk_cpu),
    .po_reset_n_gov                (po_reset_n_gov),
    .atclken_i                     (atclken_i),
    .atreadym_i                    (atreadym_i),
    .afvalidm_i                    (afvalidm_i),
    .etm_atdatam_i                 (etm_atdatam_i[(`CA53_ATDATAM_W-1):0]),
    .etm_atvalidm_i                (etm_atvalidm_i),
    .etm_atbytesm_i                (etm_atbytesm_i[(`CA53_ATBYTESM_W-1):0]),
    .etm_afreadym_i                (etm_afreadym_i),
    .etm_atidm_i                   (etm_atidm_i[(`CA53_ATIDM_W-1):0]),
    .syncreqm_i                    (syncreqm_i),
    // Outputs
    .gov_atclken_o                 (gov_atclken_o),
    .gov_atreadym_o                (gov_atreadym_o),
    .gov_afvalidm_o                (gov_afvalidm_o),
    .atdatam_o                     (atdatam_o[(`CA53_ATDATAM_W-1):0]),
    .atvalidm_o                    (atvalidm),
    .atbytesm_o                    (atbytesm_o[(`CA53_ATBYTESM_W-1):0]),
    .afreadym_o                    (afreadym_o),
    .atidm_o                       (atidm_o[(`CA53_ATIDM_W-1):0]),
    .gov_syncreqm_o                (gov_syncreqm_o));

  // ------------------------------------------------------
  // Register Slice
  // ------------------------------------------------------

  ca53governor_cpu_slice `CA53_GOVERNOR_PARAM_INST u_governor_cpu_slice (
    // Inputs
    .CLKIN                         (CLKIN),
    .clk_cpu                       (clk_cpu),
    .reset_n_gov                   (reset_n_gov),
    .po_reset_n_gov                (po_reset_n_gov),
    .dpu_warmrstreq_i              (dpu_warmrstreq_i),
    .nfiq_i                        (nfiq_i),
    .nirq_i                        (nirq_i),
    .nsei_i                        (nsei_i),
    .nrei_i                        (nrei_i),
    .nvfiq_i                       (nvfiq_i),
    .nvirq_i                       (nvirq_i),
    .nvsei_i                       (nvsei_i),
    .dpu_rei_level_ack_i           (dpu_rei_level_ack_i),
    .dpu_sei_level_ack_i           (dpu_sei_level_ack_i),
    .dpu_vsei_level_ack_i          (dpu_vsei_level_ack_i),
    .cfgend_i                      (cfgend_i),
    .vinithi_i                     (vinithi_i),
    .cfgte_i                       (cfgte_i),
    .cp15sdisable_i                (cp15sdisable_i),
    .aa64naa32_i                   (aa64naa32_i),
    .rvbaraddr_i                   (rvbaraddr_i[39:2]),
    .cryptodisable_i               (cryptodisable_i),
    .dcu_excl_mon_cleared_i        (dcu_excl_mon_cleared_i),
    .dpu_sev_req_i                 (dpu_sev_req_i),
    .dpu_smp_en_i                  (dpu_smp_en_i),
    .dpu_dbgack_i                  (dpu_dbgack_i),
    .dbgen_i                       (dbgen_i),
    .niden_i                       (niden_i),
    .spiden_i                      (spiden_i),
    .spniden_i                     (spniden_i),
    .dpu_dbgrstreq_i               (dpu_dbgrstreq_i),
    .dpu_dbgnopwrdwn_i             (dpu_dbgnopwrdwn_i),
    .dpu_commrx_i                  (dpu_commrx_i),
    .dpu_commtx_i                  (dpu_commtx_i),
    .dpu_ncommirq_i                (dpu_ncommirq_i),
    .edbgrq_i                      (edbgrq_i),
    .dcu_cp_gov_addr_i             (dcu_cp_gov_addr_i[(`CA53_CPADDR_W-1):0]),
    .dcu_cp_gov_ns_i               (dcu_cp_gov_ns_i),
    .dcu_cp_gov_req_i              (dcu_cp_gov_req_i),
    .dcu_cp_gov_sel_i              (dcu_cp_gov_sel_i[(`CA53_CPSEL_W-1):0]),
    .dcu_cp_gov_wdata_i            (dcu_cp_gov_wdata_i[(`CA53_CPDATA_W-1):0]),
    .dcu_cp_gov_wenable_i          (dcu_cp_gov_wenable_i),
    .cp_l2_rdata_i                 (cp_l2_rdata_i[(`CA53_GOV_CPDATA_W-1):0]),
    .gic_cp_ack_i                  (gic_cp_ack),
    .gic_cp_rdata_i                (gic_cp_rdata[(`CA53_CPDATA_W-1):0]),
    .timer_cp_rdata_i              (timer_cp_rdata[(`CA53_CPDATA_W-1):0]),
    .etm_oslock_i                  (etm_oslock_i),
    .dpu_npmuirq_i                 (dpu_npmuirq_i),
    .dpu_pmuevent_i                (dpu_pmuevent_i[(`CA53_PMUEVNT_CPU_W-1):0]),
    .gic_nxt_int_active_i          (gic_nxt_int_active),
    .ctiirqack_i                   (ctiirqack_i),
    .event_cpu_ret_i               (event_cpu_ret),
    .event_neon_ret_i              (event_neon_ret),
    .scu_inv_all_ack_i             (scu_inv_all_ack_i),
    .evnt_scu_err_i                (evnt_scu_err_i),
    .evnt_l2_err_i                 (evnt_l2_err_i),
    .mbistreq_rs_i                 (mbistreq_rs_i),
    .dbgl1rstdisable_i             (dbgl1rstdisable_i),
    // Outputs
    .warmrstreq_o                  (warmrstreq_o),
    .nfiq_rs_o                     (nfiq_rs),
    .nirq_rs_o                     (nirq_rs),
    .nvfiq_rs_o                    (nvfiq_rs),
    .nvirq_rs_o                    (nvirq_rs),
    .sei_level_req_o               (sei_level_req),
    .vsei_level_req_o              (vsei_level_req),
    .rei_level_req_o               (rei_level_req),
    .gov_int_active_o              (gov_int_active_o),
    .gov_cfgend_o                  (gov_cfgend_o),
    .gov_vinithi_o                 (gov_vinithi_o),
    .gov_cfgte_o                   (gov_cfgte_o),
    .gov_cp15sdisable_o            (gov_cp15sdisable_o),
    .gov_aa64naa32_o               (gov_aa64naa32),
    .gov_rvbaraddr_o               (gov_rvbaraddr_o[39:2]),
    .gov_cryptodisable_o           (gov_cryptodisable),
    .gov_smpen_o                   (gov_smpen_o),
    .excl_mon_cleared_o            (excl_mon_cleared),
    .sev_req_rs_o                  (sev_req_rs_o),
    .dbgack_rs_o                   (dbgack_rs),
    .gov_dbgen_o                   (gov_dbgen),
    .gov_niden_o                   (gov_niden),
    .gov_spiden_o                  (gov_spiden),
    .gov_spniden_o                 (gov_spniden),
    .dbgrstreq_o                   (dbgrstreq_o),
    .dbgnopwrdwn_o                 (dbgnopwrdwn_o),
    .commrx_rs_o                   (commrx_rs),
    .commtx_rs_o                   (commtx_rs),
    .ncommirq_rs_o                 (ncommirq_rs),
    .edbgrq_rs_o                   (edbgrq_rs),
    .cp_gov_addr_rs_o              (cp_gov_addr_rs[(`CA53_CPADDR_W-1):0]),
    .cp_gov_ns_rs_o                (cp_gov_ns_rs),
    .cp_gov_req_rs_o               (cp_gov_req_rs),
    .cp_gov_sel_rs_o               (cp_gov_sel_rs[(`CA53_CPSEL_W-1):0]),
    .cp_gov_wdata_rs_o             (cp_gov_wdata_rs[(`CA53_CPDATA_W-1):0]),
    .cp_gov_wenable_rs_o           (cp_gov_wenable_rs),
    .gov_cp_ack_o                  (gov_cp_ack_o),
    .gov_cp_rdata_o                (gov_cp_rdata_o[(`CA53_CPDATA_W-1):0]),
    .valid_timer_en_o              (valid_timer_en),
    .etm_oslock_rs_o               (etm_oslock_rs),
    .valid_l2_en_o                 (valid_l2_en_o),
    .ctiirqack_rs_o                (ctiirqack_rs),
    .npmuirq_rs_o                  (npmuirq_rs),
    .pmuevent_o                    (pmuevent_o[(`CA53_PMUEVNT_W-1):0]),
    .gov_inv_all_req_o             (gov_inv_all_req_o),
    .gov_dbgl1rstdisable_o         (gov_dbgl1rstdisable_o),
    .gov_mbistreq_cpu_o            (gov_mbistreq_cpu_o));

  // ------------------------------------------------------
  // Debug Over Power Down Block
  // ------------------------------------------------------

  ca53governor_cpu_debug `CA53_GOVERNOR_PARAM_INST u_governor_cpu_debug (
    // Inputs
    .CLKIN                         (CLKIN),
    .DFTSE                         (DFTSE),
    .npresetdbg_gov                (npresetdbg_gov),
    .po_reset_n_gov                (po_reset_n_gov),
    .gov_dbgen_i                   (gov_dbgen),
    .gov_niden_i                   (gov_niden),
    .gov_spiden_i                  (gov_spiden),
    .gov_spniden_i                 (gov_spniden),
    .dbgpwrdup_i                   (dbgpwrdup_i),
    .apb_dec_pseldbg_dbg_i         (apb_dec_pseldbg_dbg_i),
    .apb_dec_pseldbg_pmu_i         (apb_dec_pseldbg_pmu_i),
    .apb_dec_pseldbg_etm_i         (apb_dec_pseldbg_etm_i),
    .apb_dec_pseldbg_cti_i         (apb_dec_pseldbg_cti_i),
    .apb_bridge_paddrdbg_i         (apb_bridge_paddrdbg_i[11:2]),
    .apb_bridge_paddrdbg31_i       (apb_bridge_paddrdbg31_i),
    .apb_bridge_pwritedbg_i        (apb_bridge_pwritedbg_i),
    .apb_bridge_pwdatadbg_i        (apb_bridge_pwdatadbg_i[31:0]),
    .dpu_preadydbg_i               (dpu_preadydbg_i),
    .dpu_pslverrdbg_i              (dpu_pslverrdbg_i),
    .dpu_prdatadbg_i               (dpu_prdatadbg_i[31:0]),
    .etm_preadydbg_i               (etm_preadydbg_i),
    .etm_prdatadbg_i               (etm_prdatadbg_i[31:0]),
    .cti_preadydbg_i               (cti_preadydbg),
    .cti_prdatadbg_i               (cti_prdatadbg[31:0]),
    .cpu_id_i                      (cpu_id_i[1:0]),
    .clusteridaff1_rs_i            (clusteridaff1_rs_i[7:0]),
    .clusteridaff2_rs_i            (clusteridaff2_rs_i[7:0]),
    .gov_cryptodisable_i           (gov_cryptodisable),
    .gov_giccdisable_i             (gov_giccdisable_i),
    .etm_oslock_rs_i               (etm_oslock_rs),
    .dpu_dscr_halted_i             (dpu_dscr_halted_i),
    .cpu_in_retention_i            (cpu_in_retention),
    // Outputs
    .gov_pseldbg_dbg_o             (gov_pseldbg_dbg_o),
    .gov_pseldbg_pmu_o             (gov_pseldbg_pmu_o),
    .gov_pseldbg_etm_o             (gov_pseldbg_etm_o),
    .gov_pseldbg_cti_o             (gov_pseldbg_cti),
    .gov_penabledbg_o              (gov_penabledbg),
    .gov_paddrdbg_o                (gov_paddrdbg[11:2]),
    .gov_paddrdbg31_o              (gov_paddrdbg31),
    .gov_pwritedbg_o               (gov_pwritedbg),
    .gov_pwdatadbg_o               (gov_pwdatadbg[31:0]),
    .gov_edecr_osuce_o             (gov_edecr_osuce_o),
    .gov_edecr_rce_o               (gov_edecr_rce_o),
    .gov_edecr_ss_o                (gov_edecr_ss_o),
    .gov_edlsr_slk_o               (gov_edlsr_slk_o),
    .gov_pmlsr_slk_o               (gov_pmlsr_slk_o),
    .gov_etmpdsr_rd_o              (gov_etmpdsr_rd_o),
    .gov_dbgpwrupreq_o             (gov_dbgpwrupreq_o),
    .dbgpwrupreq_o                 (dbgpwrupreq_o),
    .preadydbg_gov_o               (preadydbg_gov_o),
    .pslverrdbg_gov_o              (pslverrdbg_gov_o),
    .prdatadbg_gov_o               (prdatadbg_gov_o[31:0]));

  // ------------------------------------------------------
  // CTI
  // ------------------------------------------------------

  always @(posedge CLKIN) begin
    dbgtrigger     <= dpu_dbgtrigger_i;
    dbgtrigger_req <= dbgtrigger;
  end

  assign cross_halt = dbgtrigger & ~dbgtrigger_req;

  // The CTI TRIGIN mapping for CortexA53
  assign ctitrigin[7] = etm_extout_i[3]; // [7] <- Output from the ETM
  assign ctitrigin[6] = etm_extout_i[2]; // [6] <- Output from the ETM
  assign ctitrigin[5] = etm_extout_i[1]; // [5] <- Output from the ETM
  assign ctitrigin[4] = etm_extout_i[0]; // [4] <- Output from the ETM
  assign ctitrigin[3] = 1'b0;            // [3] <- Tie-off
  assign ctitrigin[2] = 1'b0;            // [2] <- Tie-off
  assign ctitrigin[1] = ~npmuirq_rs;     // [1] <- Registered in the Governor (nPMUIRQ inverted)
  assign ctitrigin[0] = cross_halt;      // [0] <- Registered in the Governor

  // The CTI TRIGOUT mapping for CortexA53
  assign gov_extin_o[3:0] = ctitrigout[7:4];
  assign ctiirq_o         = ctitrigout[2];
  assign gov_dbgrestart_o = ctitrigout[1];
  assign gov_edbgrq       = ctitrigout[0] | edbgrq_rs;

  // The CTI TRIGOUTACK mapping for CortexA53
  assign ctitrigoutack[7:3] = {5{1'b0}};
  assign ctitrigoutack[  2] = ctiirqack_rs;
  assign ctitrigoutack[1:0] = {2{1'b0}};

  ca53cti #(
    .ECT_TR_WIDTH                  (8),
    .ECT_CH_WIDTH                  (4),
    .ECT_GATE_CHIN                 (1),
    .ECT_CLAIM_CNT                 (4),
    .TIHSBYPASS                    (8'b11110010),
    .INTRIG_USED                   (8'b11110011),
    .OUTTRIG_USED                  (8'b11110111)
  ) u_cti (
    // Inputs
    .clk                           (CLKIN),
    .reset_n                       (npresetdbg_gov),
    .DFTSE                         (DFTSE),
    .pseldbg_i                     (gov_pseldbg_cti),
    .penabledbg_i                  (gov_penabledbg),
    .paddrdbg_i                    (gov_paddrdbg[11:2]),
    .paddrdbg31_i                  (gov_paddrdbg31),
    .pwritedbg_i                   (gov_pwritedbg),
    .pwdatadbg_i                   (gov_pwdatadbg[31:0]),
    .ctichin_i                     (ctm_ctichin_i[3:0]),
    .ctitrigin_i                   (ctitrigin[7:0]),
    .ctitrigoutack_i               (ctitrigoutack[7:0]),
    // Outputs
    .preadydbg_o                   (cti_preadydbg),
    .prdatadbg_o                   (cti_prdatadbg[31:0]),
    .ctitrigout_o                  (ctitrigout[7:0]),
    .ctichout_o                    (cti_ctichout_o[3:0]),
    .cti_active_o                  (cti_active_o)
  );

  // ------------------------------------------------------
  // GIC CPU Interface Block
  // ------------------------------------------------------

  ca53gic_cpu u_ca53gic_cpu (
    // Inputs
    .clk                           (CLKIN),
    .reset_n                       (reset_n_gov),
    .DFTSE                         (DFTSE),
    .arb_data_i                    (arb_data_i[31:0]),
    .arb_req_i                     (arb_req_i),
    .arb_tready_i                  (arb_tready_i),
    .cp_gov_addr_i                 (cp_gov_addr_rs[(`CA53_CPADDR_W-1):0]),
    .cp_gov_ns_i                   (cp_gov_ns_rs),
    .cp_gov_req_i                  (cp_gov_req_rs),
    .cp_gov_sel_i                  (cp_gov_sel_rs[(`CA53_CPSEL_W-1):0]),
    .cp_gov_wdata_i                (cp_gov_wdata_rs[63:0]),
    .cp_gov_wenable_i              (cp_gov_wenable_rs),
    .gov_aarch64_at_el3_i          (gov_aarch64_at_el3),
    .gov_exception_level_i         (gov_exception_level[1:0]),
    .gov_giccdisable_i             (gov_giccdisable_i),
    .gov_hcr_el2_amo_i             (gov_hcr_el2_amo),
    .gov_hcr_el2_fmo_i             (gov_hcr_el2_fmo),
    .gov_hcr_el2_imo_i             (gov_hcr_el2_imo),
    .gov_monitor_mode_i            (gov_monitor_mode),
    .gov_scr_el3_fiq_i             (gov_scr_el3_fiq),
    .gov_scr_el3_irq_i             (gov_scr_el3_irq),
    .gov_scr_el3_ns_i              (gov_scr_el3_ns),
    .nfiq_rs_i                     (nfiq_rs),
    .nirq_rs_i                     (nirq_rs),
    .nvfiq_rs_i                    (nvfiq_rs),
    .nvirq_rs_i                    (nvirq_rs),
    // Outputs
    .gic_arb_ack_o                 (gic_arb_ack_o),
    .gic_cp_ack_o                  (gic_cp_ack),
    .gic_cp_rdata_o                (gic_cp_rdata[63:0]),
    .gic_fiq_o                     (gic_fiq),
    .gic_icc_sre_el1_ns_sre_o      (gic_icc_sre_el1_ns_sre_o),
    .gic_icc_sre_el1_s_sre_o       (gic_icc_sre_el1_s_sre_o),
    .gic_icc_sre_el2_enable_o      (gic_icc_sre_el2_enable_o),
    .gic_icc_sre_el2_sre_o         (gic_icc_sre_el2_sre_o),
    .gic_icc_sre_el3_enable_o      (gic_icc_sre_el3_enable_o),
    .gic_icc_sre_el3_sre_o         (gic_icc_sre_el3_sre_o),
    .gic_ich_hcr_el2_tall0_o       (gic_ich_hcr_el2_tall0_o),
    .gic_ich_hcr_el2_tall1_o       (gic_ich_hcr_el2_tall1_o),
    .gic_ich_hcr_el2_tc_o          (gic_ich_hcr_el2_tc_o),
    .gic_irq_o                     (gic_irq),
    .gic_nxt_int_active_o          (gic_nxt_int_active),
    .gic_stall_dsb_o               (gov_stall_dsb_o),
    .gic_tdata_o                   (gic_tdata_o[(`CA53_TDATA_W-1):0]),
    .gic_tlast_o                   (gic_tlast_o),
    .gic_tvalid_o                  (gic_tvalid_o),
    .gic_vfiq_o                    (gic_vfiq),
    .gic_virq_o                    (gic_virq),
    .nvcpumntirq_o                 (nvcpumntirq_o)
  );

  // ------------------------------------------------------
  // Output assignments
  // ------------------------------------------------------

  assign atvalidm_o           = atvalidm;
  assign gov_aa64naa32_o      = gov_aa64naa32;
  assign gov_dbgen_o          = gov_dbgen;
  assign gov_niden_o          = gov_niden;
  assign gov_spiden_o         = gov_spiden;
  assign gov_spniden_o        = gov_spniden;
  assign gov_edbgrq_o         = gov_edbgrq;
  assign dbgack_o             = dbgack_rs;
  assign commrx_o             = commrx_rs;
  assign commtx_o             = commtx_rs;
  assign ncommirq_o           = ncommirq_rs;
  assign npmuirq_o            = npmuirq_rs;
  assign gov_penabledbg_o     = gov_penabledbg;
  assign gov_paddrdbg_o       = gov_paddrdbg;
  assign gov_paddrdbg31_o     = gov_paddrdbg31;
  assign gov_pwritedbg_o      = gov_pwritedbg;
  assign gov_pwdatadbg_o      = gov_pwdatadbg;
  assign gic_irq_o            = gic_irq;
  assign gic_fiq_o            = gic_fiq;
  assign gic_virq_o           = gic_virq;
  assign gic_vfiq_o           = gic_vfiq;
  assign gov_sei_level_req_o  = sei_level_req;
  assign gov_vsei_level_req_o = vsei_level_req;
  assign gov_rei_level_req_o  = rei_level_req;
  assign cp_gov_wdata_rs_o    = cp_gov_wdata_rs[(`CA53_GOV_CPDATA_W-1):0];
  assign cp_gov_addr_rs_o     = cp_gov_addr_rs[(`CA53_GOV_CPADDR_W-1):0];
  assign cp_gov_wenable_rs_o  = cp_gov_wenable_rs;
  assign gov_cryptodisable_o  = gov_cryptodisable;

  //----------------------------------------------------------------------------
  //                     OVL definitions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // Instantiate block interface checker modules. These are
  // automatically generated from the machine readable block
  // interface specifications

  ca53_gic_gov u_ca53_gic_gov (
    // Inputs
    .clk                      (CLKIN),
    .reset_n                  (reset_n_gov),
    .cp_gov_addr_i            (cp_gov_addr_rs),
    .cp_gov_ns_i              (cp_gov_ns_rs),
    .cp_gov_req_i             (cp_gov_req_rs),
    .cp_gov_sel_i             (cp_gov_sel_rs),
    .cp_gov_wdata_i           (cp_gov_wdata_rs),
    .cp_gov_wenable_i         (cp_gov_wenable_rs),
    .gic_cp_ack_i             (gic_cp_ack),
    .gic_cp_rdata_i           (gic_cp_rdata),
    .gic_fiq_i                (gic_fiq),
    .gic_icc_sre_el1_ns_sre_i (gic_icc_sre_el1_ns_sre_o),
    .gic_icc_sre_el1_s_sre_i  (gic_icc_sre_el1_s_sre_o),
    .gic_icc_sre_el2_enable_i (gic_icc_sre_el2_enable_o),
    .gic_icc_sre_el2_sre_i    (gic_icc_sre_el2_sre_o),
    .gic_icc_sre_el3_enable_i (gic_icc_sre_el3_enable_o),
    .gic_icc_sre_el3_sre_i    (gic_icc_sre_el3_sre_o),
    .gic_ich_hcr_el2_tall0_i  (gic_ich_hcr_el2_tall0_o),
    .gic_ich_hcr_el2_tall1_i  (gic_ich_hcr_el2_tall1_o),
    .gic_ich_hcr_el2_tc_i     (gic_ich_hcr_el2_tc_o),
    .gic_irq_i                (gic_irq),
    .gic_nxt_int_active_i     (gic_nxt_int_active),
    .gic_stall_dsb_i          (gov_stall_dsb_o),
    .gic_vfiq_i               (gic_vfiq),
    .gic_virq_i               (gic_virq),
    .gov_aarch64_at_el3_i     (gov_aarch64_at_el3),
    .gov_exception_level_i    (gov_exception_level),
    .gov_giccdisable_i        (gov_giccdisable_i),
    .gov_hcr_el2_amo_i        (gov_hcr_el2_amo),
    .gov_hcr_el2_fmo_i        (gov_hcr_el2_fmo),
    .gov_hcr_el2_imo_i        (gov_hcr_el2_imo),
    .gov_monitor_mode_i       (gov_monitor_mode),
    .gov_scr_el3_fiq_i        (gov_scr_el3_fiq),
    .gov_scr_el3_irq_i        (gov_scr_el3_irq),
    .gov_scr_el3_ns_i         (gov_scr_el3_ns),
    .nfiq_rs_i                (nfiq_rs),
    .nirq_rs_i                (nirq_rs),
    .nvfiq_rs_i               (nvfiq_rs),
    .nvirq_rs_i               (nvirq_rs)
  ); // u_ca53_gic_gov

`endif

endmodule // ca53governor_cpu

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
