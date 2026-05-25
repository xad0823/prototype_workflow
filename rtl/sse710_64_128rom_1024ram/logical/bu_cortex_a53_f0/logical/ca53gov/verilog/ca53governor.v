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
// Description: Top level of the Governor
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53governor `CA53_GOVERNOR_PARAM_DECL (
  // Inputs
  input  wire                                    CLKIN,
  input  wire                                    DFTSE,
  input  wire                                    DFTRSTDISABLE,
  input  wire [NUM_CPUS-1: 0]                    ncpuporeset,
  input  wire [NUM_CPUS-1: 0]                    ncorereset,
  input  wire                                    nl2reset,
  input  wire                                    nmbistreset,
  input  wire [NUM_CPUS-1: 0]                    cfgend_i,
  input  wire [NUM_CPUS-1: 0]                    vinithi_i,
  input  wire [NUM_CPUS-1: 0]                    cfgte_i,
  input  wire [NUM_CPUS-1: 0]                    cp15sdisable_i,
  input  wire [  7: 0]                           clusteridaff1_i,
  input  wire [  7: 0]                           clusteridaff2_i,
  input  wire [NUM_CPUS-1: 0]                    etm_oslock_i,
  input  wire [NUM_CPUS-1: 0]                    aa64naa32_i,
  input  wire [(`CA53_RVBARADDR_PKDED_W-1): 0]   rvbaraddr_i,
  input  wire [NUM_CPUS-1: 0]                    cryptodisable_i,
  input  wire [NUM_CPUS-1: 0]                    nfiq_i,
  input  wire [NUM_CPUS-1: 0]                    nirq_i,
  input  wire [NUM_CPUS-1: 0]                    nsei_i,
  input  wire [NUM_CPUS-1:0]                     nrei_i,
  input  wire [NUM_CPUS-1: 0]                    nvfiq_i,
  input  wire [NUM_CPUS-1: 0]                    nvirq_i,
  input  wire [NUM_CPUS-1: 0]                    nvsei_i,
  input  wire [ 39:18]                           periphbase_i,
  input  wire                                    giccdisable_i,
  input  wire                                    icdtvalid_i,
  input  wire [ 15: 0]                           icdtdata_i,
  input  wire                                    icdtlast_i,
  input  wire [  1: 0]                           icdtdest_i,
  input  wire                                    icctready_i,
  input  wire [ 63: 0]                           cntvalueb_i,
  input  wire                                    cntclken_i,
  input  wire [ 63: 0]                           tsvalueb_i,
  input  wire                                    clrexmonreq_i,
  input  wire                                    eventi_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_sev_req_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_clr_event_register_i,
  input  wire [(`CA53_EXCP_LEV_PKDED_W-1):0]     dpu_exception_level_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_aarch64_at_el3_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_hcr_el2_fmo_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_hcr_el2_imo_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_hcr_el2_amo_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_monitor_mode_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_rei_level_ack_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_scr_el3_fiq_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_scr_el3_irq_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_scr_el3_ns_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_sei_level_ack_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_vsei_level_ack_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_wfi_req_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_wfe_req_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_irq_pended_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_fiq_pended_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_sei_pended_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_irq_masked_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_fiq_masked_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_sei_masked_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_virq_pended_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_vfiq_pended_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_vsei_pended_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_virq_masked_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_vfiq_masked_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_vsei_masked_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_dbg_double_lock_set_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_ns_state_i,
  input  wire [NUM_CPUS-1: 0]                    stb_wfx_ready_i,
  input  wire [NUM_CPUS-1: 0]                    biu_wfx_ready_i,
  input  wire [NUM_CPUS-1: 0]                    dcu_wfx_ready_i,
  input  wire [NUM_CPUS-1: 0]                    ifu_wfx_ready_i,
  input  wire [NUM_CPUS-1: 0]                    tlb_wfx_ready_i,
  input  wire [NUM_CPUS-1: 0]                    etm_wfx_ready_i,
  input  wire [NUM_CPUS-1: 0]                    scu_wfx_ready_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_imp_abort_pending_i,
  input  wire [(`CA53_RET_CTL_PKDED_W-1): 0]     dpu_cpuectlr_cpu_ret_delay_i,
  input  wire [(`CA53_RET_CTL_PKDED_W-1): 0]     dpu_cpuectlr_neon_ret_delay_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_neon_active_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_smp_en_i,
  input  wire [NUM_CPUS-1: 0]                    cpuqreqn_i,
  input  wire [NUM_CPUS-1: 0]                    neonqreqn_i,
  input  wire                                    l2qreqn_i,
  input  wire                                    scu_l2_retention_ready_i,
  input  wire [(`CA53_ACVALID_PKDED_W-1): 0]     scu_ac_valid_i,
  input  wire [(`CA53_PRDATADBG_PKDED_W-1): 0]   dpu_prdatadbg_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_preadydbg_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_pslverrdbg_i,
  input  wire [(`CA53_PRDATADBG_PKDED_W-1): 0]   etm_prdatadbg_i,
  input  wire [NUM_CPUS-1: 0]                    etm_preadydbg_i,
  input  wire [(`CA53_ETMEXT_PKDED_W-1): 0]      etm_extout_i,
  input  wire [NUM_CPUS-1:0]                     dcu_excl_mon_cleared_i,
  input  wire [(`CA53_CPADDR_PKDED_W-1):0]       dcu_cp_gov_addr_i,
  input  wire [NUM_CPUS-1: 0]                    dcu_cp_gov_ns_i,
  input  wire [NUM_CPUS-1: 0]                    dcu_cp_gov_req_i,
  input  wire [(`CA53_CPSEL_PKDED_W-1):0]        dcu_cp_gov_sel_i,
  input  wire [(`CA53_CPDATA_PKDED_W-1):0]       dcu_cp_gov_wdata_i,
  input  wire [NUM_CPUS-1: 0]                    dcu_cp_gov_wenable_i,
  input  wire                                    npresetdbg,
  input  wire                                    pclkendbg_i,
  input  wire                                    pseldbg_i,
  input  wire [ 21: 2]                           paddrdbg_i,
  input  wire                                    paddrdbg31_i,
  input  wire                                    penabledbg_i,
  input  wire                                    pwritedbg_i,
  input  wire [ 31: 0]                           pwdatadbg_i,
  input  wire [ 39:12]                           dbgromaddr_i,
  input  wire                                    dbgromaddrv_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_warmrstreq_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_dbgtrigger_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_dbgack_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_commrx_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_commtx_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_ncommirq_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_dscr_halted_i,
  input  wire [NUM_CPUS-1: 0]                    edbgrq_i,
  input  wire [NUM_CPUS-1: 0]                    dbgen_i,
  input  wire [NUM_CPUS-1: 0]                    niden_i,
  input  wire [NUM_CPUS-1: 0]                    spiden_i,
  input  wire [NUM_CPUS-1: 0]                    spniden_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_dbgrstreq_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_dbgnopwrdwn_i,
  input  wire [NUM_CPUS-1: 0]                    dbgpwrdup_i,
  input  wire                                    dbgl1rstdisable_i,
  input  wire                                    scu_axierr_i,
  input  wire                                    scu_eccerr_i,
  input  wire                                    scu_l2ecc_valid_i,
  input  wire                                    scu_l2ecc_fatal_i,
  input  wire [  1: 0]                           scu_l2ecc_ramid_i,
  input  wire [  3: 0]                           scu_l2ecc_cpuid_way_i,
  input  wire [ 14: 0]                           scu_l2ecc_index_i,
  input  wire                                    atclken_i,
  input  wire [(`CA53_ATREADYM_PKDED_W-1): 0]    atreadym_i,
  input  wire [(`CA53_AFVALIDM_PKDED_W-1): 0]    afvalidm_i,
  input  wire [(`CA53_ATDATAM_PKDED_W-1): 0]     etm_atdatam_i,
  input  wire [(`CA53_ATVALIDM_PKDED_W-1): 0]    etm_atvalidm_i,
  input  wire [(`CA53_ATBYTESM_PKDED_W-1): 0]    etm_atbytesm_i,
  input  wire [(`CA53_AFREADYM_PKDED_W-1): 0]    etm_afreadym_i,
  input  wire [(`CA53_ATIDM_PKDED_W-1): 0]       etm_atidm_i,
  input  wire [(`CA53_SYNCREQM_PKDED_W-1): 0]    syncreqm_i,
  input  wire [3:0]                              ctichin_i,
  input  wire [3:0]                              ctichoutack_i,
  input  wire [NUM_CPUS-1: 0]                    ctiirqack_i,
  input  wire                                    cisbypass_i,
  input  wire [3:0]                              cihsbypass_i,
  input  wire [NUM_CPUS-1: 0]                    dpu_npmuirq_i,
  input  wire [(`CA53_PMUEVNT_CPU_PKDED_W-1): 0] dpu_pmuevent_i,
  input  wire [NUM_CPUS-1: 0]                    scu_inv_all_ack_i,
  input  wire                                    mbistreq_i,
  input  wire                                    scu_mbistack0_i,
  input  wire                                    scu_mbistack1_i,
  input  wire [(`CA53_MBIST0_ADDR_W-1): 0]       mbistaddr0_i,
  input  wire [(`CA53_MBIST1_ADDR_W-1): 0]       mbistaddr1_i,
  input  wire [(`CA53_MBIST0_DATA_W-1): 0]       mbistindata0_i,
  input  wire [(`CA53_MBIST1_DATA_W-1): 0]       mbistindata1_i,
  input  wire [(`CA53_MBIST0_DATA_W-1): 0]       scu_mbistoutdata0_i,
  input  wire [(`CA53_MBIST1_DATA_W-1): 0]       scu_mbistoutdata1_i,
  input  wire                                    mbistwriteen0_i,
  input  wire                                    mbistwriteen1_i,
  input  wire                                    mbistreaden0_i,
  input  wire                                    mbistreaden1_i,
  input  wire [(`CA53_MBIST0_RAMARRAY_W-1):0]    mbistarray0_i,
  input  wire [(`CA53_MBIST1_RAMARRAY_W-1):0]    mbistarray1_i,
  input  wire [(`CA53_MBIST0_BE_W-1):0]          mbistbe0_i,
  input  wire [(`CA53_MBIST1_BE_W-1):0]          mbistbe1_i,
  input  wire                                    mbistcfg0_i,
  input  wire                                    mbistcfg1_i,
  // Outputs
  output wire [NUM_CPUS-1: 0]                    clk_cpu,
  output wire [NUM_CPUS-1: 0]                    reset_n_cpu,
  output wire [NUM_CPUS-1: 0]                    po_reset_n_cpu,
  output wire [NUM_CPUS-1: 0]                    warmrstreq_o,
  output wire [NUM_CPUS-1: 0]                    gov_cfgend_o,
  output wire [NUM_CPUS-1: 0]                    gov_vinithi_o,
  output wire [NUM_CPUS-1: 0]                    gov_cfgte_o,
  output wire [NUM_CPUS-1: 0]                    gov_cp15sdisable_o,
  output wire [  7: 0]                           gov_clusteridaff1_o,
  output wire [  7: 0]                           gov_clusteridaff2_o,
  output wire [NUM_CPUS-1: 0]                    gov_aa64naa32_o,
  output wire [(`CA53_RVBARADDR_PKDED_W-1): 0]   gov_rvbaraddr_o,
  output wire [NUM_CPUS-1: 0]                    gov_cryptodisable_o,
  output wire [NUM_CPUS-1: 0]                    gov_stall_neon_o,
  output wire [NUM_CPUS-1: 0]                    ncntpsirq_o,
  output wire [NUM_CPUS-1: 0]                    ncntpnsirq_o,
  output wire [NUM_CPUS-1: 0]                    ncnthpirq_o,
  output wire [NUM_CPUS-1: 0]                    ncntvirq_o,
  output wire [NUM_CPUS-1: 0]                    gic_irq_o,
  output wire [NUM_CPUS-1: 0]                    gic_fiq_o,
  output wire [NUM_CPUS-1: 0]                    gic_virq_o,
  output wire [NUM_CPUS-1: 0]                    gic_vfiq_o,
  output wire [NUM_CPUS-1: 0]                    gov_sei_level_req_o,
  output wire [NUM_CPUS-1: 0]                    gov_vsei_level_req_o,
  output wire [NUM_CPUS-1: 0]                    gov_rei_level_req_o,
  output wire [NUM_CPUS-1: 0]                    gov_int_active_o,
  output wire [NUM_CPUS-1: 0]                    gic_icc_sre_el1_ns_sre_o,
  output wire [NUM_CPUS-1: 0]                    gic_icc_sre_el1_s_sre_o,
  output wire [NUM_CPUS-1: 0]                    gic_icc_sre_el2_enable_o,
  output wire [NUM_CPUS-1: 0]                    gic_icc_sre_el2_sre_o,
  output wire [NUM_CPUS-1: 0]                    gic_icc_sre_el3_enable_o,
  output wire [NUM_CPUS-1: 0]                    gic_icc_sre_el3_sre_o,
  output wire [NUM_CPUS-1: 0]                    gic_ich_hcr_el2_tall0_o,
  output wire [NUM_CPUS-1: 0]                    gic_ich_hcr_el2_tall1_o,
  output wire [NUM_CPUS-1: 0]                    gic_ich_hcr_el2_tc_o,
  output wire [NUM_CPUS-1: 0]                    nvcpumntirq_o,
  output wire [ 39:18]                           gov_periphbase_o,
  output wire                                    gov_giccdisable_o,
  output wire                                    icdtready_o,
  output wire                                    icctvalid_o,
  output wire [ 15: 0]                           icctdata_o,
  output wire                                    icctlast_o,
  output wire [  1: 0]                           icctid_o,
  output wire [ 63: 0]                           gov_tsvalueb_o,
  output wire [NUM_CPUS-1: 0]                    gov_standbywfi_o,
  output wire [NUM_CPUS-1: 0]                    gov_standbywfe_o,
  output wire [NUM_CPUS-1: 0]                    standbywfi_o,
  output wire [NUM_CPUS-1: 0]                    standbywfe_o,
  output wire [NUM_CPUS-1: 0]                    gov_wfx_drain_req_o,
  output wire [NUM_CPUS-1: 0]                    gov_wfx_wake_o,
  output wire                                    clrexmonack_o,
  output wire                                    evento_o,
  output wire [NUM_CPUS-1: 0]                    gov_event_reg_o,
  output wire [NUM_CPUS-1: 0]                    gov_smpen_o,
  output wire [NUM_CPUS-1: 0]                    cpuqactive_o,
  output wire [NUM_CPUS-1: 0]                    cpuqdeny_o,
  output wire [NUM_CPUS-1: 0]                    cpuqacceptn_o,
  output wire [NUM_CPUS-1: 0]                    neonqactive_o,
  output wire [NUM_CPUS-1: 0]                    neonqdeny_o,
  output wire [NUM_CPUS-1: 0]                    neonqacceptn_o,
  output wire                                    l2qactive_o,
  output wire                                    l2qdeny_o,
  output wire                                    l2qacceptn_o,
  output wire                                    gov_l2_in_retention_o,
  output wire [(`CA53_PRDATADBG_W-1): 0]         prdatadbg_o,
  output wire                                    preadydbg_o,
  output wire                                    pslverrdbg_o,
  output wire [NUM_CPUS-1: 0]                    gov_pseldbg_dbg_o,
  output wire [NUM_CPUS-1: 0]                    gov_pseldbg_pmu_o,
  output wire [NUM_CPUS-1: 0]                    gov_pseldbg_etm_o,
  output wire [(`CA53_PADDRDBG_PKDED_W-1):0]     gov_paddrdbg_o,
  output wire [NUM_CPUS-1: 0]                    gov_paddrdbg31_o,
  output wire [NUM_CPUS-1: 0]                    gov_penabledbg_o,
  output wire [NUM_CPUS-1: 0]                    gov_pwritedbg_o,
  output wire [(`CA53_PWDATADBG_PKDED_W-1):0]    gov_pwdatadbg_o,
  output wire [ 39:12]                           gov_dbgromaddr_o,
  output wire                                    gov_dbgromaddrv_o,
  output wire [NUM_CPUS-1: 0]                    ncommirq_o,
  output wire [NUM_CPUS-1: 0]                    dbgack_o,
  output wire [NUM_CPUS-1: 0]                    commrx_o,
  output wire [NUM_CPUS-1: 0]                    commtx_o,
  output wire [NUM_CPUS-1: 0]                    gov_edbgrq_o,
  output wire [NUM_CPUS-1: 0]                    gov_dbgen_o,
  output wire [NUM_CPUS-1: 0]                    gov_niden_o,
  output wire [NUM_CPUS-1: 0]                    gov_spiden_o,
  output wire [NUM_CPUS-1: 0]                    gov_spniden_o,
  output wire [NUM_CPUS-1: 0]                    gov_dbgrestart_o,
  output wire [NUM_CPUS-1: 0]                    gov_stall_dsb_o,
  output wire [NUM_CPUS-1: 0]                    gov_cp_ack_o,
  output wire [(`CA53_CPDATA_PKDED_W-1):0]       gov_cp_rdata_o,
  output wire [NUM_CPUS-1: 0]                    gov_pcnt_kernel_access_o,
  output wire [NUM_CPUS-1: 0]                    gov_pcnt_usr_access_o,
  output wire [NUM_CPUS-1: 0]                    gov_vcnt_usr_access_o,
  output wire [NUM_CPUS-1: 0]                    gov_cntp_usr_access_o,
  output wire [NUM_CPUS-1: 0]                    gov_cntv_usr_access_o,
  output wire [NUM_CPUS-1: 0]                    gov_cntp_kernel_access_o,
  output wire [NUM_CPUS-1: 0]                    dbgrstreq_o,
  output wire [NUM_CPUS-1: 0]                    dbgnopwrdwn_o,
  output wire [NUM_CPUS-1: 0]                    gov_dbgpwrupreq_o,
  output wire [NUM_CPUS-1: 0]                    dbgpwrupreq_o,
  output wire [(`CA53_ETMEXT_PKDED_W-1): 0]      gov_extin_o,
  output wire [NUM_CPUS-1: 0]                    gov_edecr_osuce_o,
  output wire [NUM_CPUS-1: 0]                    gov_edecr_rce_o,
  output wire [NUM_CPUS-1: 0]                    gov_edecr_ss_o,
  output wire [NUM_CPUS-1: 0]                    gov_edlsr_slk_o,
  output wire [NUM_CPUS-1: 0]                    gov_pmlsr_slk_o,
  output wire [NUM_CPUS-1: 0]                    gov_etmpdsr_rd_o,
  output wire [NUM_CPUS-1: 0]                    gov_atclken_o,
  output wire [(`CA53_ATREADYM_PKDED_W-1): 0]    gov_atreadym_o,
  output wire [(`CA53_AFVALIDM_PKDED_W-1): 0]    gov_afvalidm_o,
  output wire [(`CA53_ATDATAM_PKDED_W-1): 0]     atdatam_o,
  output wire [(`CA53_ATVALIDM_PKDED_W-1): 0]    atvalidm_o,
  output wire [(`CA53_ATBYTESM_PKDED_W-1): 0]    atbytesm_o,
  output wire [(`CA53_AFREADYM_PKDED_W-1): 0]    afreadym_o,
  output wire [(`CA53_ATIDM_PKDED_W-1): 0]       atidm_o,
  output wire [(`CA53_SYNCREQM_PKDED_W-1): 0]    gov_syncreqm_o,
  output wire [NUM_CPUS-1: 0]                    npmuirq_o,
  output wire [(`CA53_PMUEVNT_PKDED_W-1): 0]     pmuevent_o,
  output wire [3:0]                              ctichout_o,
  output wire [3:0]                              ctichinack_o,
  output wire [NUM_CPUS-1: 0]                    ctiirq_o,
  output wire                                    gov_enable_writeevict_o,
  output wire                                    gov_disable_evict_o,
  output wire [1:0]                              gov_l2victim_ctl_o,
  output wire                                    gov_l2deien_o,
  output wire                                    gov_l2teien_o,
  output wire                                    gov_clear_axierr_o,
  output wire                                    gov_clear_eccerr_o,
  output wire [NUM_CPUS-1: 0]                    gov_inv_all_req_o,
  output wire [NUM_CPUS-1: 0]                    gov_dbgl1rstdisable_o,
  output wire                                    gov_mbistreq_o,
  output wire [NUM_CPUS-1: 0]                    gov_mbistreq_cpu_o,
  output wire                                    mbistack0_o,
  output wire                                    mbistack1_o,
  output wire [(`CA53_MBIST0_ADDR_W-1): 0]       gov_mbistaddr0_o,
  output wire [(`CA53_MBIST1_ADDR_W-1): 0]       gov_mbistaddr1_o,
  output wire [(`CA53_MBIST0_DATA_W-1): 0]       gov_mbistindata0_o,
  output wire [(`CA53_MBIST1_DATA_W-1): 0]       gov_mbistindata1_o,
  output wire [(`CA53_MBIST0_DATA_W-1): 0]       mbistoutdata0_o,
  output wire [(`CA53_MBIST1_DATA_W-1): 0]       mbistoutdata1_o,
  output wire                                    gov_mbistwriteen0_o,
  output wire                                    gov_mbistwriteen1_o,
  output wire                                    gov_mbistreaden0_o,
  output wire                                    gov_mbistreaden1_o,
  output wire [(`CA53_MBIST0_RAMARRAY_W-1):0]    gov_mbistarray0_o,
  output wire [(`CA53_MBIST1_RAMARRAY_W-1):0]    gov_mbistarray1_o,
  output wire [(`CA53_MBIST0_BE_W-1):0]          gov_mbistbe0_o,
  output wire [(`CA53_MBIST1_BE_W-1):0]          gov_mbistbe1_o,
  output wire                                    gov_mbistcfg0_o,
  output wire                                    gov_mbistcfg1_o
);

  // -----------------------------
  // Variable declarations
  // -----------------------------

  genvar cpu;
  genvar cpu_i;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg [(`CA53_PRDATADBG_W-1): 0]         apb_mux_prdatadbg;
  reg                                    apb_mux_preadydbg;
  reg                                    apb_mux_pslverrdbg;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [(NUM_CPUS-1):0]                  apb_dec_pseldbg_dbg;
  wire [(NUM_CPUS-1):0]                  apb_dec_pseldbg_pmu;
  wire [(NUM_CPUS-1):0]                  apb_dec_pseldbg_etm;
  wire [(NUM_CPUS-1):0]                  apb_dec_pseldbg_cti;
  wire                                   apb_dec_pseldbg_rom;
  wire                                   apb_dec_pseldbg_none;
  wire                                   nl2reset_synced_pipelined;
  wire                                   nl2reset_synced;
  wire                                   nmbistreset_synced_pipelined;
  wire                                   nmbistreset_synced;
  wire                                   reset_n_arb;
  wire                                   npresetdbg_gov;
  wire                                   clrexmon_rs;
  wire [63:0]                            cntvalueb_rs;
  wire [63:0]                            tsvalueb_rs;
  wire                                   eventi_rs;
  wire                                   mbistreq_rs;
  wire [(NUM_CPUS-1):0]                  valid_l2_en;
  wire [(`CA53_GOV_CPDATA_PKDED_W-1):0]  cp_gov_wdata_rs;
  wire [(`CA53_GOV_CPADDR_PKDED_W-1):0]  cp_gov_addr_rs;
  wire [(NUM_CPUS-1):0]                  cp_gov_wenable_rs;
  wire [(`CA53_GOV_CPDATA_PKDED_W-1):0]  cp_l2_rdata;
  wire [(`CA53_PRDATADBG_W-1):0]         prdatadbg_rom;
  wire                                   preadydbg_rom;
  wire                                   pslverrdbg_rom;
  wire [(`CA53_PRDATADBG_W-1):0]         prdatadbg_gov[NUM_CPUS-1:0];
  wire [(NUM_CPUS-1):0]                  preadydbg_gov;
  wire [(NUM_CPUS-1):0]                  pslverrdbg_gov;
  wire [(NUM_CPUS-1):0]                  sev_req_rs;
  wire [(NUM_CPUS-1):0]                  sev_req_rs_masked [(NUM_CPUS-1):0];
  wire [(NUM_CPUS-1):0]                  sev_set_event_register;
  wire [21:2]                            apb_bridge_paddrdbg;
  wire                                   apb_bridge_pseldbg;
  wire                                   apb_bridge_paddrdbg31;
  wire [31:0]                            apb_bridge_pwdatadbg;
  wire                                   apb_bridge_pwritedbg;
  wire [(`CA53_CTICH_PKDED_W-1):0]       cti_ctichout;
  wire [(`CA53_CTICH_PKDED_W-1):0]       ctm_ctichin;
  wire [(NUM_CPUS-1):0]                  cti_active;
  wire [3:0]                             ctm_ctichout;
  wire [3:0]                             ctm_ctichinack;
  wire [7:0]                             clusteridaff1_rs;
  wire [7:0]                             clusteridaff2_rs;
  wire                                   gov_giccdisable;
  wire [(NUM_CPUS-1):0]                  gic_arb_ack;
  wire [(`CA53_TDATA_PKDED_W-1):0]       gic_tdata;
  wire [(NUM_CPUS-1):0]                  gic_tlast;
  wire [(NUM_CPUS-1):0]                  gic_tvalid;
  wire [(NUM_CPUS-1):0]                  arb_req;
  wire [31:0]                            arb_data;
  wire [(NUM_CPUS-1):0]                  arb_tready;
  wire [2:0]                             cp_l2ectlr_ret_delay;
  wire [(NUM_CPUS-1):0]                  gov_standbywfi;
  wire [(NUM_CPUS-1):0]                  gov_standbywfe;
  wire [(NUM_CPUS-1):0]                  gov_wfx_wake;
  wire [NUM_CPUS-1:0]                    sel_path_gov;
  wire                                   evnt_scu_err;
  wire                                   evnt_l2_err;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Per CPU Governor blocks
  // ------------------------------------------------------

  generate for (cpu = 0; cpu < NUM_CPUS; cpu = cpu + 1) begin : g_governor_cpu
    ca53governor_cpu `CA53_GOVERNOR_PARAM_INST u_governor_cpu (
      // Inputs
      .CLKIN                         (CLKIN),
      .DFTSE                         (DFTSE),
      .DFTRSTDISABLE                 (DFTRSTDISABLE),
      .ncpuporeset                   (ncpuporeset[cpu]),
      .ncorereset                    (ncorereset[cpu]),
      .nl2reset_synced_pipelined     (nl2reset_synced_pipelined),
      .nl2reset_synced               (nl2reset_synced),
      .nmbistreset_synced_pipelined  (nmbistreset_synced_pipelined),
      .nmbistreset_synced            (nmbistreset_synced),
      .npresetdbg_gov                (npresetdbg_gov),
      .cfgend_i                      (cfgend_i[cpu]),
      .vinithi_i                     (vinithi_i[cpu]),
      .cfgte_i                       (cfgte_i[cpu]),
      .cp15sdisable_i                (cp15sdisable_i[cpu]),
      .cpu_id_i                      (cpu[1:0]),
      .clusteridaff1_rs_i            (clusteridaff1_rs[7:0]),
      .clusteridaff2_rs_i            (clusteridaff2_rs[7:0]),
      .dpu_dscr_halted_i             (dpu_dscr_halted_i[cpu]),
      .etm_oslock_i                  (etm_oslock_i[cpu]),
      .aa64naa32_i                   (aa64naa32_i[cpu]),
      .rvbaraddr_i                   (rvbaraddr_i[((`CA53_RVBARADDR_W * (cpu+1))-1): (`CA53_RVBARADDR_W * cpu)]),
      .cryptodisable_i               (cryptodisable_i[cpu]),
      .cntvalueb_rs_i                (cntvalueb_rs[63:0]),
      .mbistreq_rs_i                 (mbistreq_rs),
      .nfiq_i                        (nfiq_i[cpu]),
      .nirq_i                        (nirq_i[cpu]),
      .nsei_i                        (nsei_i[cpu]),
      .nrei_i                        (nrei_i[cpu]),
      .nvfiq_i                       (nvfiq_i[cpu]),
      .nvirq_i                       (nvirq_i[cpu]),
      .nvsei_i                       (nvsei_i[cpu]),
      .gov_giccdisable_i             (gov_giccdisable),
      .arb_req_i                     (arb_req[cpu]),
      .arb_data_i                    (arb_data[31:0]),
      .arb_tready_i                  (arb_tready[cpu]),
      .clrexmon_rs_i                 (clrexmon_rs),
      .dpu_sev_req_i                 (dpu_sev_req_i[cpu]),
      .sev_set_event_register_i      (sev_set_event_register[cpu]),
      .dpu_clr_event_register_i      (dpu_clr_event_register_i[cpu]),
      .dpu_exception_level_i         (dpu_exception_level_i[((`CA53_EXCP_LEV_W * (cpu+1))-1): (`CA53_EXCP_LEV_W * cpu)]),
      .dpu_aarch64_at_el3_i          (dpu_aarch64_at_el3_i[cpu]),
      .dpu_hcr_el2_fmo_i             (dpu_hcr_el2_fmo_i[cpu]),
      .dpu_hcr_el2_imo_i             (dpu_hcr_el2_imo_i[cpu]),
      .dpu_hcr_el2_amo_i             (dpu_hcr_el2_amo_i[cpu]),
      .dpu_monitor_mode_i            (dpu_monitor_mode_i[cpu]),
      .dpu_rei_level_ack_i           (dpu_rei_level_ack_i[cpu]),
      .dpu_scr_el3_fiq_i             (dpu_scr_el3_fiq_i[cpu]),
      .dpu_scr_el3_irq_i             (dpu_scr_el3_irq_i[cpu]),
      .dpu_scr_el3_ns_i              (dpu_scr_el3_ns_i[cpu]),
      .dpu_sei_level_ack_i           (dpu_sei_level_ack_i[cpu]),
      .dpu_vsei_level_ack_i          (dpu_vsei_level_ack_i[cpu]),
      .dpu_wfi_req_i                 (dpu_wfi_req_i[cpu]),
      .dpu_wfe_req_i                 (dpu_wfe_req_i[cpu]),
      .dpu_irq_pended_i              (dpu_irq_pended_i[cpu]),
      .dpu_fiq_pended_i              (dpu_fiq_pended_i[cpu]),
      .dpu_sei_pended_i              (dpu_sei_pended_i[cpu]),
      .dpu_irq_masked_i              (dpu_irq_masked_i[cpu]),
      .dpu_fiq_masked_i              (dpu_fiq_masked_i[cpu]),
      .dpu_sei_masked_i              (dpu_sei_masked_i[cpu]),
      .dpu_virq_pended_i             (dpu_virq_pended_i[cpu]),
      .dpu_vfiq_pended_i             (dpu_vfiq_pended_i[cpu]),
      .dpu_vsei_pended_i             (dpu_vsei_pended_i[cpu]),
      .dpu_virq_masked_i             (dpu_virq_masked_i[cpu]),
      .dpu_vfiq_masked_i             (dpu_vfiq_masked_i[cpu]),
      .dpu_vsei_masked_i             (dpu_vsei_masked_i[cpu]),
      .dpu_dbg_double_lock_set_i     (dpu_dbg_double_lock_set_i[cpu]),
      .dpu_ns_state_i                (dpu_ns_state_i[cpu]),
      .stb_wfx_ready_i               (stb_wfx_ready_i[cpu]),
      .biu_wfx_ready_i               (biu_wfx_ready_i[cpu]),
      .dcu_wfx_ready_i               (dcu_wfx_ready_i[cpu]),
      .ifu_wfx_ready_i               (ifu_wfx_ready_i[cpu]),
      .tlb_wfx_ready_i               (tlb_wfx_ready_i[cpu]),
      .etm_wfx_ready_i               (etm_wfx_ready_i[cpu]),
      .scu_wfx_ready_i               (scu_wfx_ready_i[cpu]),
      .dpu_imp_abort_pending_i       (dpu_imp_abort_pending_i[cpu]),
      .dpu_cpuectlr_cpu_ret_delay_i  (dpu_cpuectlr_cpu_ret_delay_i[((`CA53_RET_CTL_W * (cpu+1))-1): (`CA53_RET_CTL_W * cpu)]),
      .dpu_cpuectlr_neon_ret_delay_i (dpu_cpuectlr_neon_ret_delay_i[((`CA53_RET_CTL_W * (cpu+1))-1): (`CA53_RET_CTL_W * cpu)]),
      .dpu_neon_active_i             (dpu_neon_active_i[cpu]),
      .dpu_smp_en_i                  (dpu_smp_en_i[cpu]),
      .cpuqreqn_i                    (cpuqreqn_i[cpu]),
      .neonqreqn_i                   (neonqreqn_i[cpu]),
      .scu_ac_valid_i                (scu_ac_valid_i[cpu]),
      .dpu_prdatadbg_i               (dpu_prdatadbg_i[((`CA53_PRDATADBG_W * (cpu+1))-1): (`CA53_PRDATADBG_W * cpu)]),
      .dpu_preadydbg_i               (dpu_preadydbg_i[cpu]),
      .dpu_pslverrdbg_i              (dpu_pslverrdbg_i[cpu]),
      .etm_prdatadbg_i               (etm_prdatadbg_i[((`CA53_PRDATADBG_W * (cpu+1))-1): (`CA53_PRDATADBG_W * cpu)]),
      .etm_preadydbg_i               (etm_preadydbg_i[cpu]),
      .etm_extout_i                  (etm_extout_i[((`CA53_ETMEXT_W * (cpu+1))-1): (`CA53_ETMEXT_W * cpu)]),
      .dcu_excl_mon_cleared_i        (dcu_excl_mon_cleared_i[cpu]),
      .dcu_cp_gov_addr_i             (dcu_cp_gov_addr_i[((`CA53_CPADDR_W * (cpu+1))-1): (`CA53_CPADDR_W * cpu)]),
      .dcu_cp_gov_ns_i               (dcu_cp_gov_ns_i[cpu]),
      .dcu_cp_gov_req_i              (dcu_cp_gov_req_i[cpu]),
      .dcu_cp_gov_sel_i              (dcu_cp_gov_sel_i[((`CA53_CPSEL_W * (cpu+1))-1): (`CA53_CPSEL_W * cpu)]),
      .dcu_cp_gov_wdata_i            (dcu_cp_gov_wdata_i[((`CA53_CPDATA_W * (cpu+1))-1): (`CA53_CPDATA_W * cpu)]),
      .dcu_cp_gov_wenable_i          (dcu_cp_gov_wenable_i[cpu]),
      .cp_l2_rdata_i                 (cp_l2_rdata[((`CA53_GOV_CPDATA_W * (cpu+1))-1): (`CA53_GOV_CPDATA_W * cpu)]),
      .apb_dec_pseldbg_dbg_i         (apb_dec_pseldbg_dbg[cpu]),
      .apb_dec_pseldbg_pmu_i         (apb_dec_pseldbg_pmu[cpu]),
      .apb_dec_pseldbg_etm_i         (apb_dec_pseldbg_etm[cpu]),
      .apb_dec_pseldbg_cti_i         (apb_dec_pseldbg_cti[cpu]),
      .apb_bridge_pseldbg_i          (apb_bridge_pseldbg),
      .apb_bridge_paddrdbg_i         (apb_bridge_paddrdbg[11:2]),
      .apb_bridge_paddrdbg31_i       (apb_bridge_paddrdbg31),
      .apb_bridge_pwritedbg_i        (apb_bridge_pwritedbg),
      .apb_bridge_pwdatadbg_i        (apb_bridge_pwdatadbg[31:0]),
      .dpu_warmrstreq_i              (dpu_warmrstreq_i[cpu]),
      .dpu_dbgtrigger_i              (dpu_dbgtrigger_i[cpu]),
      .dpu_dbgack_i                  (dpu_dbgack_i[cpu]),
      .dpu_commrx_i                  (dpu_commrx_i[cpu]),
      .dpu_commtx_i                  (dpu_commtx_i[cpu]),
      .dpu_ncommirq_i                (dpu_ncommirq_i[cpu]),
      .edbgrq_i                      (edbgrq_i[cpu]),
      .dbgen_i                       (dbgen_i[cpu]),
      .niden_i                       (niden_i[cpu]),
      .spiden_i                      (spiden_i[cpu]),
      .spniden_i                     (spniden_i[cpu]),
      .dpu_dbgrstreq_i               (dpu_dbgrstreq_i[cpu]),
      .dpu_dbgnopwrdwn_i             (dpu_dbgnopwrdwn_i[cpu]),
      .dbgpwrdup_i                   (dbgpwrdup_i[cpu]),
      .dbgl1rstdisable_i             (dbgl1rstdisable_i),
      .atclken_i                     (atclken_i),
      .atreadym_i                    (atreadym_i[((`CA53_ATREADYM_W * (cpu+1))-1): (`CA53_ATREADYM_W * cpu)]),
      .afvalidm_i                    (afvalidm_i[((`CA53_AFVALIDM_W * (cpu+1))-1): (`CA53_AFVALIDM_W * cpu)]),
      .etm_atdatam_i                 (etm_atdatam_i[((`CA53_ATDATAM_W * (cpu+1))-1): (`CA53_ATDATAM_W * cpu)]),
      .etm_atvalidm_i                (etm_atvalidm_i[((`CA53_ATVALIDM_W * (cpu+1))-1): (`CA53_ATVALIDM_W * cpu)]),
      .etm_atbytesm_i                (etm_atbytesm_i[((`CA53_ATBYTESM_W * (cpu+1))-1): (`CA53_ATBYTESM_W * cpu)]),
      .etm_afreadym_i                (etm_afreadym_i[((`CA53_AFREADYM_W * (cpu+1))-1): (`CA53_AFREADYM_W * cpu)]),
      .etm_atidm_i                   (etm_atidm_i[((`CA53_ATIDM_W * (cpu+1))-1): (`CA53_ATIDM_W * cpu)]),
      .syncreqm_i                    (syncreqm_i[((`CA53_SYNCREQM_W * (cpu+1))-1): (`CA53_SYNCREQM_W * cpu)]),
      .ctm_ctichin_i                 (ctm_ctichin[((`CA53_CTICH_W * (cpu+1))-1): (`CA53_CTICH_W * cpu)]),
      .ctiirqack_i                   (ctiirqack_i[cpu]),
      .dpu_npmuirq_i                 (dpu_npmuirq_i[cpu]),
      .dpu_pmuevent_i                (dpu_pmuevent_i[((`CA53_PMUEVNT_CPU_W * (cpu+1))-1): (`CA53_PMUEVNT_CPU_W * cpu)]),
      .scu_inv_all_ack_i             (scu_inv_all_ack_i[cpu]),
      .evnt_scu_err_i                (evnt_scu_err),
      .evnt_l2_err_i                 (evnt_l2_err),
      // Outputs
      .clk_cpu                       (clk_cpu[cpu]),
      .reset_n_cpu                   (reset_n_cpu[cpu]),
      .po_reset_n_cpu                (po_reset_n_cpu[cpu]),
      .warmrstreq_o                  (warmrstreq_o[cpu]),
      .gov_cfgend_o                  (gov_cfgend_o[cpu]),
      .gov_vinithi_o                 (gov_vinithi_o[cpu]),
      .gov_cfgte_o                   (gov_cfgte_o[cpu]),
      .gov_cp15sdisable_o            (gov_cp15sdisable_o[cpu]),
      .gov_aa64naa32_o               (gov_aa64naa32_o[cpu]),
      .gov_rvbaraddr_o               (gov_rvbaraddr_o[((`CA53_RVBARADDR_W * (cpu+1))-1): (`CA53_RVBARADDR_W * cpu)]),
      .gov_cryptodisable_o           (gov_cryptodisable_o[cpu]),
      .gov_stall_neon_o              (gov_stall_neon_o[cpu]),
      .ncntpsirq_o                   (ncntpsirq_o[cpu]),
      .ncntpnsirq_o                  (ncntpnsirq_o[cpu]),
      .ncnthpirq_o                   (ncnthpirq_o[cpu]),
      .ncntvirq_o                    (ncntvirq_o[cpu]),
      .gic_irq_o                     (gic_irq_o[cpu]),
      .gic_fiq_o                     (gic_fiq_o[cpu]),
      .gic_virq_o                    (gic_virq_o[cpu]),
      .gic_vfiq_o                    (gic_vfiq_o[cpu]),
      .gov_sei_level_req_o           (gov_sei_level_req_o[cpu]),
      .gov_vsei_level_req_o          (gov_vsei_level_req_o[cpu]),
      .gov_rei_level_req_o           (gov_rei_level_req_o[cpu]),
      .gov_int_active_o              (gov_int_active_o[cpu]),
      .gic_icc_sre_el1_ns_sre_o      (gic_icc_sre_el1_ns_sre_o[cpu]),
      .gic_icc_sre_el1_s_sre_o       (gic_icc_sre_el1_s_sre_o[cpu]),
      .gic_icc_sre_el2_enable_o      (gic_icc_sre_el2_enable_o[cpu]),
      .gic_icc_sre_el2_sre_o         (gic_icc_sre_el2_sre_o[cpu]),
      .gic_icc_sre_el3_enable_o      (gic_icc_sre_el3_enable_o[cpu]),
      .gic_icc_sre_el3_sre_o         (gic_icc_sre_el3_sre_o[cpu]),
      .gic_ich_hcr_el2_tall0_o       (gic_ich_hcr_el2_tall0_o[cpu]),
      .gic_ich_hcr_el2_tall1_o       (gic_ich_hcr_el2_tall1_o[cpu]),
      .gic_ich_hcr_el2_tc_o          (gic_ich_hcr_el2_tc_o[cpu]),
      .gic_arb_ack_o                 (gic_arb_ack[cpu]),
      .gic_tdata_o                   (gic_tdata[((`CA53_TDATA_W * (cpu+1))-1): (`CA53_TDATA_W * cpu)]),
      .gic_tlast_o                   (gic_tlast[cpu]),
      .gic_tvalid_o                  (gic_tvalid[cpu]),
      .gov_stall_dsb_o               (gov_stall_dsb_o[cpu]),
      .nvcpumntirq_o                 (nvcpumntirq_o[cpu]),
      .gov_standbywfi_o              (gov_standbywfi[cpu]),
      .gov_standbywfe_o              (gov_standbywfe[cpu]),
      .sev_req_rs_o                  (sev_req_rs[cpu]),
      .gov_wfx_drain_req_o           (gov_wfx_drain_req_o[cpu]),
      .gov_wfx_wake_o                (gov_wfx_wake[cpu]),
      .gov_event_reg_o               (gov_event_reg_o[cpu]),
      .gov_smpen_o                   (gov_smpen_o[cpu]),
      .cpuqactive_o                  (cpuqactive_o[cpu]),
      .cpuqdeny_o                    (cpuqdeny_o[cpu]),
      .cpuqacceptn_o                 (cpuqacceptn_o[cpu]),
      .neonqactive_o                 (neonqactive_o[cpu]),
      .neonqdeny_o                   (neonqdeny_o[cpu]),
      .neonqacceptn_o                (neonqacceptn_o[cpu]),
      .prdatadbg_gov_o               (prdatadbg_gov[cpu][(`CA53_PRDATADBG_W-1):0]),
      .preadydbg_gov_o               (preadydbg_gov[cpu]),
      .pslverrdbg_gov_o              (pslverrdbg_gov[cpu]),
      .dbgack_o                      (dbgack_o[cpu]),
      .commrx_o                      (commrx_o[cpu]),
      .commtx_o                      (commtx_o[cpu]),
      .ncommirq_o                    (ncommirq_o[cpu]),
      .gov_edbgrq_o                  (gov_edbgrq_o[cpu]),
      .gov_dbgen_o                   (gov_dbgen_o[cpu]),
      .gov_niden_o                   (gov_niden_o[cpu]),
      .gov_spiden_o                  (gov_spiden_o[cpu]),
      .gov_spniden_o                 (gov_spniden_o[cpu]),
      .gov_dbgrestart_o              (gov_dbgrestart_o[cpu]),
      .gov_cp_ack_o                  (gov_cp_ack_o[cpu]),
      .gov_cp_rdata_o                (gov_cp_rdata_o[((`CA53_CPDATA_W * (cpu+1))-1): (`CA53_CPDATA_W * cpu)]),
      .gov_pcnt_kernel_access_o      (gov_pcnt_kernel_access_o[cpu]),
      .gov_pcnt_usr_access_o         (gov_pcnt_usr_access_o[cpu]),
      .gov_vcnt_usr_access_o         (gov_vcnt_usr_access_o[cpu]),
      .gov_cntp_usr_access_o         (gov_cntp_usr_access_o[cpu]),
      .gov_cntv_usr_access_o         (gov_cntv_usr_access_o[cpu]),
      .gov_cntp_kernel_access_o      (gov_cntp_kernel_access_o[cpu]),
      .valid_l2_en_o                 (valid_l2_en[cpu]),
      .cp_gov_wdata_rs_o             (cp_gov_wdata_rs[((`CA53_GOV_CPDATA_W * (cpu+1))-1): (`CA53_GOV_CPDATA_W * cpu)]),
      .cp_gov_addr_rs_o              (cp_gov_addr_rs[((`CA53_GOV_CPADDR_W * (cpu+1))-1): (`CA53_GOV_CPADDR_W * cpu)]),
      .cp_gov_wenable_rs_o           (cp_gov_wenable_rs[cpu]),
      .dbgrstreq_o                   (dbgrstreq_o[cpu]),
      .dbgnopwrdwn_o                 (dbgnopwrdwn_o[cpu]),
      .gov_pseldbg_dbg_o             (gov_pseldbg_dbg_o[cpu]),
      .gov_pseldbg_pmu_o             (gov_pseldbg_pmu_o[cpu]),
      .gov_pseldbg_etm_o             (gov_pseldbg_etm_o[cpu]),
      .gov_penabledbg_o              (gov_penabledbg_o[cpu]),
      .gov_paddrdbg_o                (gov_paddrdbg_o[((`CA53_PADDRDBG_W * (cpu+1))-1): (`CA53_PADDRDBG_W * cpu)]),
      .gov_paddrdbg31_o              (gov_paddrdbg31_o[cpu]),
      .gov_pwritedbg_o               (gov_pwritedbg_o[cpu]),
      .gov_pwdatadbg_o               (gov_pwdatadbg_o[((`CA53_PWDATADBG_W * (cpu+1))-1): (`CA53_PWDATADBG_W * cpu)]),
      .gov_dbgpwrupreq_o             (gov_dbgpwrupreq_o[cpu]),
      .dbgpwrupreq_o                 (dbgpwrupreq_o[cpu]),
      .gov_extin_o                   (gov_extin_o[((`CA53_ETMEXT_W * (cpu+1))-1): (`CA53_ETMEXT_W * cpu)]),
      .gov_edecr_osuce_o             (gov_edecr_osuce_o[cpu]),
      .gov_edecr_rce_o               (gov_edecr_rce_o[cpu]),
      .gov_edecr_ss_o                (gov_edecr_ss_o[cpu]),
      .gov_edlsr_slk_o               (gov_edlsr_slk_o[cpu]),
      .gov_pmlsr_slk_o               (gov_pmlsr_slk_o[cpu]),
      .gov_etmpdsr_rd_o              (gov_etmpdsr_rd_o[cpu]),
      .gov_atclken_o                 (gov_atclken_o[cpu]),
      .gov_atreadym_o                (gov_atreadym_o[((`CA53_ATREADYM_W * (cpu+1))-1): (`CA53_ATREADYM_W * cpu)]),
      .gov_afvalidm_o                (gov_afvalidm_o[((`CA53_AFVALIDM_W * (cpu+1))-1): (`CA53_AFVALIDM_W * cpu)]),
      .atdatam_o                     (atdatam_o[((`CA53_ATDATAM_W * (cpu+1))-1): (`CA53_ATDATAM_W * cpu)]),
      .atvalidm_o                    (atvalidm_o[((`CA53_ATVALIDM_W * (cpu+1))-1): (`CA53_ATVALIDM_W * cpu)]),
      .atbytesm_o                    (atbytesm_o[((`CA53_ATBYTESM_W * (cpu+1))-1): (`CA53_ATBYTESM_W * cpu)]),
      .afreadym_o                    (afreadym_o[((`CA53_AFREADYM_W * (cpu+1))-1): (`CA53_AFREADYM_W * cpu)]),
      .atidm_o                       (atidm_o[((`CA53_ATIDM_W * (cpu+1))-1): (`CA53_ATIDM_W * cpu)]),
      .gov_syncreqm_o                (gov_syncreqm_o[((`CA53_SYNCREQM_W * (cpu+1))-1): (`CA53_SYNCREQM_W * cpu)]),
      .gov_mbistreq_cpu_o            (gov_mbistreq_cpu_o[cpu]),
      .npmuirq_o                     (npmuirq_o[cpu]),
      .pmuevent_o                    (pmuevent_o[((`CA53_PMUEVNT_W * (cpu+1))-1): (`CA53_PMUEVNT_W * cpu)]),
      .cti_ctichout_o                (cti_ctichout[((`CA53_CTICH_W * (cpu+1))-1): (`CA53_CTICH_W * cpu)]),
      .ctiirq_o                      (ctiirq_o[cpu]),
      .cti_active_o                  (cti_active[cpu]),
      .gov_inv_all_req_o             (gov_inv_all_req_o[cpu]),
      .gov_dbgl1rstdisable_o         (gov_dbgl1rstdisable_o[cpu]));
  end endgenerate

  // ------------------------------------------------------
  // Event generation
  // ------------------------------------------------------

  // Combine the register sliced per-CPU event requests with the external, register sliced event request.
  // The logic is written like this to ensure that one OR structure is created per-CPU to allow routing
  // to go the shortest route to each CPU.  A single OR structure would force all routing to a central
  // point in the floorplan before fanning back to the per-CPU Governor which would not be optimal.
  generate for (cpu = 0; cpu < NUM_CPUS; cpu = cpu + 1) begin : g_sev_req_cpu
    for (cpu_i = 0; cpu_i < NUM_CPUS; cpu_i = cpu_i + 1) begin : g_mask
      if (cpu != cpu_i) begin : g_diff
        assign sev_req_rs_masked[cpu][cpu_i] = sev_req_rs[cpu_i];
      end else begin : g_same
        assign sev_req_rs_masked[cpu][cpu_i] = 1'b0;
      end
    end

    assign sev_set_event_register[cpu] = (|sev_req_rs_masked[cpu]) | eventi_rs;
  end endgenerate

  // ------------------------------------------------------
  // Slice global signals
  // ------------------------------------------------------

  ca53governor_slice `CA53_GOVERNOR_PARAM_INST u_governor_slice (
    // Inputs
    .CLKIN                        (CLKIN),
    .DFTSE                        (DFTSE),
    .DFTRSTDISABLE                (DFTRSTDISABLE),
    .nl2reset                     (nl2reset),
    .nmbistreset                  (nmbistreset),
    .npresetdbg                   (npresetdbg),
    .clusteridaff1_i              (clusteridaff1_i),
    .clusteridaff2_i              (clusteridaff2_i),
    .periphbase_i                 (periphbase_i[39:18]),
    .giccdisable_i                (giccdisable_i),
    .clrexmonreq_i                (clrexmonreq_i),
    .cntvalueb_i                  (cntvalueb_i[63:0]),
    .cntclken_i                   (cntclken_i),
    .tsvalueb_i                   (tsvalueb_i[63:0]),
    .atclken_i                    (atclken_i),
    .eventi_i                     (eventi_i),
    .sev_req_rs_i                 (sev_req_rs[(NUM_CPUS-1):0]),
    .gov_standbywfi_i             (gov_standbywfi[(NUM_CPUS-1):0]),
    .gov_standbywfe_i             (gov_standbywfe[(NUM_CPUS-1):0]),
    .dbgromaddr_i                 (dbgromaddr_i),
    .dbgromaddrv_i                (dbgromaddrv_i),
    .valid_l2_en_i                (valid_l2_en[(NUM_CPUS-1):0]),
    .cp_gov_wdata_rs_i            (cp_gov_wdata_rs[(`CA53_GOV_CPDATA_PKDED_W-1):0]),
    .cp_gov_addr_rs_i             (cp_gov_addr_rs[(`CA53_GOV_CPADDR_PKDED_W-1):0]),
    .cp_gov_wenable_rs_i          (cp_gov_wenable_rs[(NUM_CPUS-1):0]),
    .scu_axierr_i                 (scu_axierr_i),
    .scu_eccerr_i                 (scu_eccerr_i),
    .scu_l2ecc_valid_i            (scu_l2ecc_valid_i),
    .scu_l2ecc_fatal_i            (scu_l2ecc_fatal_i),
    .scu_l2ecc_ramid_i            (scu_l2ecc_ramid_i[1:0]),
    .scu_l2ecc_cpuid_way_i        (scu_l2ecc_cpuid_way_i[3:0]),
    .scu_l2ecc_index_i            (scu_l2ecc_index_i[14:0]),
    .mbistreq_i                   (mbistreq_i),
    .scu_mbistack0_i              (scu_mbistack0_i),
    .scu_mbistack1_i              (scu_mbistack1_i),
    .mbistaddr0_i                 (mbistaddr0_i[(`CA53_MBIST0_ADDR_W-1):0]),
    .mbistaddr1_i                 (mbistaddr1_i[(`CA53_MBIST1_ADDR_W-1):0]),
    .mbistindata0_i               (mbistindata0_i[(`CA53_MBIST0_DATA_W-1):0]),
    .mbistindata1_i               (mbistindata1_i[(`CA53_MBIST1_DATA_W-1):0]),
    .scu_mbistoutdata0_i          (scu_mbistoutdata0_i[(`CA53_MBIST0_DATA_W-1):0]),
    .scu_mbistoutdata1_i          (scu_mbistoutdata1_i[(`CA53_MBIST1_DATA_W-1):0]),
    .mbistwriteen0_i              (mbistwriteen0_i),
    .mbistwriteen1_i              (mbistwriteen1_i),
    .mbistreaden0_i               (mbistreaden0_i),
    .mbistreaden1_i               (mbistreaden1_i),
    .mbistarray0_i                (mbistarray0_i[(`CA53_MBIST0_RAMARRAY_W-1):0]),
    .mbistarray1_i                (mbistarray1_i[(`CA53_MBIST1_RAMARRAY_W-1):0]),
    .mbistbe0_i                   (mbistbe0_i[(`CA53_MBIST0_BE_W-1):0]),
    .mbistbe1_i                   (mbistbe1_i[(`CA53_MBIST1_BE_W-1):0]),
    .mbistcfg0_i                  (mbistcfg0_i),
    .mbistcfg1_i                  (mbistcfg1_i),
    // Outputs
    .nl2reset_synced_pipelined    (nl2reset_synced_pipelined),
    .nl2reset_synced              (nl2reset_synced),
    .nmbistreset_synced_pipelined (nmbistreset_synced_pipelined),
    .nmbistreset_synced           (nmbistreset_synced),
    .reset_n_arb                  (reset_n_arb),
    .npresetdbg_gov               (npresetdbg_gov),
    .clusteridaff1_rs_o           (clusteridaff1_rs[7:0]),
    .clusteridaff2_rs_o           (clusteridaff2_rs[7:0]),
    .gov_periphbase_o             (gov_periphbase_o[39:18]),
    .gov_giccdisable_o            (gov_giccdisable),
    .clrexmon_rs_o                (clrexmon_rs),
    .clrexmonack_o                (clrexmonack_o),
    .cntvalueb_rs_o               (cntvalueb_rs[63:0]),
    .tsvalueb_rs_o                (tsvalueb_rs[63:0]),
    .eventi_rs_o                  (eventi_rs),
    .evento_o                     (evento_o),
    .standbywfi_o                 (standbywfi_o[(NUM_CPUS-1):0]),
    .standbywfe_o                 (standbywfe_o[(NUM_CPUS-1):0]),
    .gov_dbgromaddr_o             (gov_dbgromaddr_o),
    .gov_dbgromaddrv_o            (gov_dbgromaddrv_o),
    .gov_enable_writeevict_o      (gov_enable_writeevict_o),
    .gov_disable_evict_o          (gov_disable_evict_o),
    .gov_l2victim_ctl_o           (gov_l2victim_ctl_o[1:0]),
    .gov_l2deien_o                (gov_l2deien_o),
    .gov_l2teien_o                (gov_l2teien_o),
    .cp_l2ectlr_ret_delay_o       (cp_l2ectlr_ret_delay[2:0]),
    .cp_l2_rdata_o                (cp_l2_rdata[(`CA53_GOV_CPDATA_PKDED_W-1):0]),
    .gov_clear_axierr_o           (gov_clear_axierr_o),
    .gov_clear_eccerr_o           (gov_clear_eccerr_o),
    .evnt_scu_err_o               (evnt_scu_err),
    .evnt_l2_err_o                (evnt_l2_err),
    .mbistreq_rs_o                (mbistreq_rs),
    .mbistack0_o                  (mbistack0_o),
    .mbistack1_o                  (mbistack1_o),
    .gov_mbistaddr0_o             (gov_mbistaddr0_o[(`CA53_MBIST0_ADDR_W-1):0]),
    .gov_mbistaddr1_o             (gov_mbistaddr1_o[(`CA53_MBIST1_ADDR_W-1):0]),
    .gov_mbistindata0_o           (gov_mbistindata0_o[(`CA53_MBIST0_DATA_W-1):0]),
    .gov_mbistindata1_o           (gov_mbistindata1_o[(`CA53_MBIST1_DATA_W-1):0]),
    .mbistoutdata0_o              (mbistoutdata0_o[(`CA53_MBIST0_DATA_W-1):0]),
    .mbistoutdata1_o              (mbistoutdata1_o[(`CA53_MBIST1_DATA_W-1):0]),
    .gov_mbistwriteen0_o          (gov_mbistwriteen0_o),
    .gov_mbistwriteen1_o          (gov_mbistwriteen1_o),
    .gov_mbistreaden0_o           (gov_mbistreaden0_o),
    .gov_mbistreaden1_o           (gov_mbistreaden1_o),
    .gov_mbistarray0_o            (gov_mbistarray0_o[(`CA53_MBIST0_RAMARRAY_W-1):0]),
    .gov_mbistarray1_o            (gov_mbistarray1_o[(`CA53_MBIST1_RAMARRAY_W-1):0]),
    .gov_mbistbe0_o               (gov_mbistbe0_o[(`CA53_MBIST0_BE_W-1):0]),
    .gov_mbistbe1_o               (gov_mbistbe1_o[(`CA53_MBIST1_BE_W-1):0]),
    .gov_mbistcfg0_o              (gov_mbistcfg0_o),
    .gov_mbistcfg1_o              (gov_mbistcfg1_o));

  // ------------------------------------------------------
  // APB Slice (modified bridge)
  // ------------------------------------------------------

  ca53governor_apb_bridge u_governor_apb_bridge (
    // Inputs
    .CLKIN                        (CLKIN),
    .presetn_i                    (npresetdbg_gov),
    .pclkens_i                    (pclkendbg_i),
    .paddrs_i                     (paddrdbg_i[21:2]),
    .paddr31s_i                   (paddrdbg31_i),
    .pwdatas_i                    (pwdatadbg_i[31:0]),
    .pwrites_i                    (pwritedbg_i),
    .penables_i                   (penabledbg_i),
    .psels_i                      (pseldbg_i),
    // Outputs
    .prdatas_o                    (prdatadbg_o),
    .pslverrs_o                   (pslverrdbg_o),
    .preadys_o                    (preadydbg_o),
    // Inputs
    .pclkenm_i                    (1'b1),
    // Outputs
    .paddrm_o                     (apb_bridge_paddrdbg[21:2]),
    .paddr31m_o                   (apb_bridge_paddrdbg31),
    .pwdatam_o                    (apb_bridge_pwdatadbg[31:0]),
    .pwritem_o                    (apb_bridge_pwritedbg),
    .pselm_o                      (apb_bridge_pseldbg),
    // Inputs
    .prdatam_i                    (apb_mux_prdatadbg),
    .pslverrm_i                   (apb_mux_pslverrdbg),
    .preadym_i                    (apb_mux_preadydbg));

  // ------------------------------------------------------
  // APB Decoder
  // ------------------------------------------------------

  ca53governor_apb_dec `CA53_GOVERNOR_PARAM_INST u_governor_apb_dec (
    // Inputs
    .apb_bridge_pseldbg_i         (apb_bridge_pseldbg),
    .apb_bridge_paddrdbg_i        (apb_bridge_paddrdbg[21:12]),
    // Outputs
    .apb_dec_pseldbg_dbg_o        (apb_dec_pseldbg_dbg[(NUM_CPUS-1):0]),
    .apb_dec_pseldbg_pmu_o        (apb_dec_pseldbg_pmu[(NUM_CPUS-1):0]),
    .apb_dec_pseldbg_etm_o        (apb_dec_pseldbg_etm[(NUM_CPUS-1):0]),
    .apb_dec_pseldbg_cti_o        (apb_dec_pseldbg_cti[(NUM_CPUS-1):0]),
    .apb_dec_pseldbg_rom_o        (apb_dec_pseldbg_rom),
    .apb_dec_pseldbg_none_o       (apb_dec_pseldbg_none));

  // ------------------------------------------------------
  // APB Mux
  // ------------------------------------------------------

  // Mux select signal
  generate for (cpu = 0; cpu < NUM_CPUS; cpu = cpu + 1) begin : g_apb_mux_sel
    assign sel_path_gov[cpu] = apb_dec_pseldbg_dbg[cpu] | apb_dec_pseldbg_pmu[cpu] | apb_dec_pseldbg_etm[cpu] | apb_dec_pseldbg_cti[cpu];
  end endgenerate

  // Mux between the APB buses from each CPU Governor
  always @* begin : prdata_cpu_muxing
    integer i;
    reg [31:0]         tmp_prdatadbg;
    reg                tmp_preadydbg;
    reg                tmp_pslverrdbg;

    tmp_prdatadbg  = {32{1'b0}};
    tmp_preadydbg  = 1'b0;
    tmp_pslverrdbg = 1'b0;

    for (i = 0; i < NUM_CPUS; i = i + 1) begin
      // Data muxing
      tmp_prdatadbg  = tmp_prdatadbg[31:0] | ({32{sel_path_gov[i]}} & prdatadbg_gov[i][31:0]);
      tmp_preadydbg  = tmp_preadydbg       | (    sel_path_gov[i]   & preadydbg_gov[i]);
      tmp_pslverrdbg = tmp_pslverrdbg      | (    sel_path_gov[i]   & pslverrdbg_gov[i]);
    end

    apb_mux_prdatadbg  = tmp_prdatadbg  | ({32{apb_dec_pseldbg_rom}} & prdatadbg_rom[31:0]);
    apb_mux_preadydbg  = tmp_preadydbg  | (    apb_dec_pseldbg_rom   & preadydbg_rom)  | apb_dec_pseldbg_none;
    apb_mux_pslverrdbg = tmp_pslverrdbg | (    apb_dec_pseldbg_rom   & pslverrdbg_rom) | apb_dec_pseldbg_none;
  end

  // ------------------------------------------------------
  // APBROM
  // ------------------------------------------------------

  ca53governor_romtable `CA53_GOVERNOR_PARAM_INST u_governor_romtable (
    // Inputs
    .apb_bridge_paddrdbg_i        (apb_bridge_paddrdbg[11:2]),
    .apb_dec_pseldbg_rom_i        (apb_dec_pseldbg_rom),
    // Outputs
    .preadydbg_rom_o              (preadydbg_rom),
    .pslverrdbg_rom_o             (pslverrdbg_rom),
    .prdatadbg_rom_o              (prdatadbg_rom[31:0]));

  // ------------------------------------------------------
  // CTM
  // ------------------------------------------------------

  ca53governor_ctm `CA53_GOVERNOR_PARAM_INST u_governor_ctm (
    // Inputs
    .CLKIN                        (CLKIN),
    .DFTSE                        (DFTSE),
    .npresetdbg_gov               (npresetdbg_gov),
    .apb_dec_pseldbg_cti_i        (apb_dec_pseldbg_cti[(NUM_CPUS-1):0]),
    .cti_active_i                 (cti_active),
    .cisbypass_i                  (cisbypass_i),
    .cihsbypass_i                 (cihsbypass_i[3:0]),
    .cti_ctichout_i               (cti_ctichout[`CA53_CTICH_PKDED_W-1:0]),
    .ctmchin_i                    (ctichin_i[3:0]),
    .ctmchoutack_i                (ctichoutack_i[3:0]),
    // Outputs
    .ctm_ctichin_o                (ctm_ctichin[(`CA53_CTICH_PKDED_W-1):0]),
    .ctm_ctichinack_o             (ctm_ctichinack[3:0]),
    .ctm_ctichout_o               (ctm_ctichout[3:0]));

  // ------------------------------------------------------
  // GIC AXI-Stream bus arbiter
  // ------------------------------------------------------

  ca53gic_arb `CA53_GIC_PARAM_INST u_ca53gic_arb (
    // Inputs
    .clk                          (CLKIN),
    .reset_n                      (reset_n_arb),
    .DFTSE                        (DFTSE),
    .gov_giccdisable_i            (gov_giccdisable),
    .gic_arb_ack_i                (gic_arb_ack[(NUM_CPUS-1):0]),
    .gic_tdata_i                  (gic_tdata[(`CA53_TDATA_PKDED_W-1):0]),
    .gic_tlast_i                  (gic_tlast[(NUM_CPUS-1):0]),
    .gic_tvalid_i                 (gic_tvalid[(NUM_CPUS-1):0]),
    .icctready_i                  (icctready_i),
    .icdtdata_i                   (icdtdata_i[15:0]),
    .icdtdest_i                   (icdtdest_i[1:0]),
    .icdtlast_i                   (icdtlast_i),
    .icdtvalid_i                  (icdtvalid_i),
    // Outputs
    .arb_data_o                   (arb_data[31:0]),
    .arb_req_o                    (arb_req[(NUM_CPUS-1):0]),
    .arb_tready_o                 (arb_tready[(NUM_CPUS-1):0]),
    .icctdata_o                   (icctdata_o[15:0]),
    .icctlast_o                   (icctlast_o),
    .icctid_o                     (icctid_o[1:0]),
    .icctvalid_o                  (icctvalid_o),
    .icdtready_o                  (icdtready_o));

  // ------------------------------------------------------
  // L2 Retention Control
  // ------------------------------------------------------

  ca53governor_power `CA53_GOVERNOR_PARAM_INST u_governor_power (
    // Inputs
    .CLKIN                        (CLKIN),
    .reset_n_arb                  (reset_n_arb),
    .DFTSE                        (DFTSE),
    .cntvalueb_rs_i               (cntvalueb_rs[9:0]),
    .cp_l2ectlr_ret_delay_i       (cp_l2ectlr_ret_delay[2:0]),
    .gov_standbywfi_i             (gov_standbywfi[(NUM_CPUS-1):0]),
    .gov_standbywfe_i             (gov_standbywfe[(NUM_CPUS-1):0]),
    .gov_wfx_wake_i               (gov_wfx_wake[(NUM_CPUS-1):0]),
    .l2qreqn_i                    (l2qreqn_i),
    .scu_l2_retention_ready_i     (scu_l2_retention_ready_i),
    // Outputs
    .gov_l2_in_retention_o        (gov_l2_in_retention_o),
    .l2qactive_o                  (l2qactive_o),
    .l2qdeny_o                    (l2qdeny_o),
    .l2qacceptn_o                 (l2qacceptn_o));

  // ------------------------------------------------------
  // Output assignments
  // ------------------------------------------------------

  assign gov_standbywfi_o    = gov_standbywfi;
  assign gov_standbywfe_o    = gov_standbywfe;
  assign gov_giccdisable_o   = gov_giccdisable;
  assign gov_clusteridaff1_o = clusteridaff1_rs[7:0];
  assign gov_clusteridaff2_o = clusteridaff2_rs[7:0];
  assign gov_tsvalueb_o      = tsvalueb_rs[63:0];
  assign gov_mbistreq_o      = mbistreq_rs;
  assign gov_wfx_wake_o      = gov_wfx_wake;
  assign ctichout_o          = ctm_ctichout;
  assign ctichinack_o        = ctm_ctichinack;

endmodule // ca53governor

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
